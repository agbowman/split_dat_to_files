CREATE PROGRAM dm2_xnt_plsql_gen:dba
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
 DECLARE put_plsql_head(i_pos=i4,io_table_pair=vc(ref),io_table_list=vc(ref),io_stmts=vc(ref),
  i_table_name=vc,
  i_templ_nbr=i4) = i2
 DECLARE put_plsql_body(i_pos=i4,io_table_pair=vc(ref),io_table_list=vc(ref),io_stmts=vc(ref),
  i_table_name=vc) = null
 DECLARE put_plsql_stmt(i_pos=i4,io_stmt_rs=vc(ref),i_str=vc) = null
 DECLARE put_plsql_end(i_pos=i4,io_table_pair=vc(ref),io_table_list=vc(ref),io_stmts=vc(ref),
  i_table_name=vc) = null
 DECLARE dxp_crt_cld_parms(i_cld_ocl=vc,i_cld_dt=vc,i_str=vc(ref)) = null
 DECLARE m_last_gen_dt = f8 WITH protect, noconstant(cnvtdatetime((curdate - 10000),0))
 DECLARE m_xnt_pl_template_loop = i4 WITH protect, noconstant(0)
 DECLARE m_xnt_pl_pair_loop = i4 WITH protect, noconstant(0)
 DECLARE m_xnt_pl_idx = i4 WITH protect, noconstant(0)
 DECLARE m_xnt_pl_idx2 = i4 WITH protect, noconstant(0)
 DECLARE m_xnt_ret = i2 WITH protect, noconstant(0)
 DECLARE m_xnt_par_tbl_idx = i4 WITH protect, noconstant(0)
 DECLARE m_xnt_cld_tbl_idx = i4 WITH protect, noconstant(0)
 FREE RECORD m_xnt_pl_templates
 RECORD m_xnt_pl_templates(
   1 cnt = i4
   1 list[*]
     2 template_nbr = i4
     2 master_table = vc
 ) WITH protect
 FREE RECORD m_dxxp_request
 RECORD m_dxxp_request(
   1 cnt = i4
   1 qual[*]
     2 str = vc
 ) WITH protect
 FREE RECORD m_xnt_pl_table_pair
 RECORD m_xnt_pl_table_pair(
   1 cnt = i4
   1 qual[*]
     2 parent_table = vc
     2 child_table = vc
     2 child_where = vc
     2 parent_col1 = vc
     2 parent_col2 = vc
     2 parent_col3 = vc
     2 parent_col4 = vc
     2 parent_col5 = vc
     2 child_col1 = vc
     2 child_col2 = vc
     2 child_col3 = vc
     2 child_col4 = vc
     2 child_col5 = vc
     2 skip_ind = i2
 ) WITH protect
 FREE RECORD m_xnt_pl_table_list
 RECORD m_xnt_pl_table_list(
   1 tab_cnt = i4
   1 list[*]
     2 table_name = vc
     2 table_suffix = vc
     2 rec_col = vc
     2 table_skip_ind = i2
     2 col_cnt = i4
     2 qual[*]
       3 col_name = vc
       3 col_data_type = vc
 ) WITH protect
 FREE RECORD m_xnt_pl_stmts
 RECORD m_xnt_pl_stmts(
   1 cnt = i4
   1 list[*]
     2 table_name = vc
     2 type = vc
     2 skip_ind = i2
     2 stmt_cnt = i4
     2 qual[*]
       3 stmt_str = vc
 ) WITH protect
 FREE RECORD m_xnt_recompile
 RECORD m_xnt_recompile(
   1 cnt = i4
   1 list[*]
     2 alter_stmt = vc
 ) WITH protect
 IF (check_logfile("dm2_xnt_plsql",".log","DM2_XNT_PLSQL LogFile...") != 1)
  SET dm_err->err_ind = 1
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 EXECUTE dm2_xnt_xml_plsql
 IF ((dm_err->err_ind=1))
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Obtain all XNT templates"
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT DISTINCT INTO "nl:"
  dpt.template_nbr
  FROM dm_purge_template dpt
  WHERE cnvtupper(trim(dpt.program_str,3))="XNT"
   AND dpt.active_ind=1
  DETAIL
   m_xnt_pl_templates->cnt = (m_xnt_pl_templates->cnt+ 1), stat = alterlist(m_xnt_pl_templates->list,
    m_xnt_pl_templates->cnt), m_xnt_pl_templates->list[m_xnt_pl_templates->cnt].template_nbr = dpt
   .template_nbr
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 FOR (m_xnt_pl_template_loop = 1 TO m_xnt_pl_templates->cnt)
   SET dm_err->eproc = concat("Obtain top level table for template #: ",cnvtstring(m_xnt_pl_templates
     ->list[m_xnt_pl_template_loop].template_nbr))
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    dpt.parent_table
    FROM dm_purge_table dpt
    WHERE (dpt.template_nbr=m_xnt_pl_templates->list[m_xnt_pl_template_loop].template_nbr)
     AND dpt.purge_type_flag=5
     AND (dpt.schema_dt_tm=
    (SELECT
     max(pt1.schema_dt_tm)
     FROM dm_purge_table pt1
     WHERE (pt1.template_nbr=m_xnt_pl_templates->list[m_xnt_pl_template_loop].template_nbr)
      AND pt1.purge_type_flag=5))
    DETAIL
     m_xnt_pl_templates->list[m_xnt_pl_template_loop].master_table = dpt.parent_table
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    GO TO exit_program
   ENDIF
   IF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Could not resolve top level table for template #: ",cnvtstring(
      m_xnt_pl_templates->list[m_xnt_pl_template_loop].template_nbr))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    GO TO exit_program
   ENDIF
   SET dm_err->eproc = concat("Obtain table list for template #: ",cnvtstring(m_xnt_pl_templates->
     list[m_xnt_pl_template_loop].template_nbr))
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_purge_table dpt
    WHERE (dpt.template_nbr=m_xnt_pl_templates->list[m_xnt_pl_template_loop].template_nbr)
     AND dpt.purge_type_flag=6
     AND (dpt.schema_dt_tm=
    (SELECT
     max(pt1.schema_dt_tm)
     FROM dm_purge_table pt1
     WHERE (pt1.template_nbr=m_xnt_pl_templates->list[m_xnt_pl_template_loop].template_nbr)
      AND pt1.purge_type_flag=6))
    HEAD REPORT
     m_xnt_pl_table_list->tab_cnt = 0, m_xnt_pl_table_pair->cnt = 0, stat = alterlist(
      m_xnt_pl_table_pair->qual,0),
     stat = alterlist(m_xnt_pl_table_list->list,0)
    DETAIL
     m_xnt_pl_table_pair->cnt = (m_xnt_pl_table_pair->cnt+ 1), stat = alterlist(m_xnt_pl_table_pair->
      qual,m_xnt_pl_table_pair->cnt), m_xnt_pl_table_pair->qual[m_xnt_pl_table_pair->cnt].
     parent_table = dpt.parent_table,
     m_xnt_pl_table_pair->qual[m_xnt_pl_table_pair->cnt].child_table = dpt.child_table,
     m_xnt_pl_table_pair->qual[m_xnt_pl_table_pair->cnt].child_where = dpt.child_where,
     m_xnt_pl_table_pair->qual[m_xnt_pl_table_pair->cnt].parent_col1 = dpt.parent_col1,
     m_xnt_pl_table_pair->qual[m_xnt_pl_table_pair->cnt].parent_col2 = dpt.parent_col2,
     m_xnt_pl_table_pair->qual[m_xnt_pl_table_pair->cnt].parent_col3 = dpt.parent_col3,
     m_xnt_pl_table_pair->qual[m_xnt_pl_table_pair->cnt].parent_col4 = dpt.parent_col4,
     m_xnt_pl_table_pair->qual[m_xnt_pl_table_pair->cnt].parent_col5 = dpt.parent_col5,
     m_xnt_pl_table_pair->qual[m_xnt_pl_table_pair->cnt].child_col1 = dpt.child_col1,
     m_xnt_pl_table_pair->qual[m_xnt_pl_table_pair->cnt].child_col2 = dpt.child_col2,
     m_xnt_pl_table_pair->qual[m_xnt_pl_table_pair->cnt].child_col3 = dpt.child_col3,
     m_xnt_pl_table_pair->qual[m_xnt_pl_table_pair->cnt].child_col4 = dpt.child_col4,
     m_xnt_pl_table_pair->qual[m_xnt_pl_table_pair->cnt].child_col5 = dpt.child_col5,
     m_xnt_pl_idx = locateval(m_xnt_pl_idx2,1,m_xnt_pl_table_list->tab_cnt,dpt.parent_table,
      m_xnt_pl_table_list->list[m_xnt_pl_idx2].table_name)
     IF (m_xnt_pl_idx=0)
      m_xnt_pl_table_list->tab_cnt = (m_xnt_pl_table_list->tab_cnt+ 1), stat = alterlist(
       m_xnt_pl_table_list->list,m_xnt_pl_table_list->tab_cnt), m_xnt_pl_table_list->list[
      m_xnt_pl_table_list->tab_cnt].table_name = dpt.parent_table,
      m_xnt_pl_table_list->list[m_xnt_pl_table_list->tab_cnt].table_skip_ind = 1
     ENDIF
     m_xnt_pl_idx = locateval(m_xnt_pl_idx2,1,m_xnt_pl_table_list->tab_cnt,dpt.child_table,
      m_xnt_pl_table_list->list[m_xnt_pl_idx2].table_name)
     IF (m_xnt_pl_idx=0)
      m_xnt_pl_table_list->tab_cnt = (m_xnt_pl_table_list->tab_cnt+ 1), stat = alterlist(
       m_xnt_pl_table_list->list,m_xnt_pl_table_list->tab_cnt), m_xnt_pl_table_list->list[
      m_xnt_pl_table_list->tab_cnt].table_name = dpt.child_table,
      m_xnt_pl_table_list->list[m_xnt_pl_table_list->tab_cnt].table_skip_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    GO TO exit_program
   ENDIF
   SET dm_err->eproc = concat(
    "Obtain table suffix, and verify existence, for the tables found in template #: ",cnvtstring(
     m_xnt_pl_templates->list[m_xnt_pl_template_loop].template_nbr))
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di,
     user_tables ut
    WHERE expand(m_xnt_pl_idx2,1,m_xnt_pl_table_list->tab_cnt,ut.table_name,m_xnt_pl_table_list->
     list[m_xnt_pl_idx2].table_name)
     AND di.info_name=ut.table_name
     AND di.info_domain="DM_TABLES_DOC_TABLE_SUFFIX"
    DETAIL
     m_xnt_pl_idx = locateval(m_xnt_pl_idx2,1,m_xnt_pl_table_list->tab_cnt,di.info_name,
      m_xnt_pl_table_list->list[m_xnt_pl_idx2].table_name), m_xnt_pl_table_list->list[m_xnt_pl_idx].
     table_suffix = di.info_char, m_xnt_pl_table_list->list[m_xnt_pl_idx].table_skip_ind = 0
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    GO TO exit_program
   ENDIF
   SET dm_err->eproc = concat("Obtain recursive tables in template #: ",cnvtstring(m_xnt_pl_templates
     ->list[m_xnt_pl_template_loop].template_nbr))
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2XNT_REC_COL"
     AND expand(m_xnt_pl_idx2,1,m_xnt_pl_table_list->tab_cnt,di.info_name,m_xnt_pl_table_list->list[
     m_xnt_pl_idx2].table_name)
    DETAIL
     m_xnt_pl_idx = locateval(m_xnt_pl_idx2,1,m_xnt_pl_table_list->tab_cnt,di.info_name,
      m_xnt_pl_table_list->list[m_xnt_pl_idx2].table_name), m_xnt_pl_table_list->list[m_xnt_pl_idx].
     rec_col = di.info_char
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    GO TO exit_program
   ENDIF
   SET dm_err->eproc = concat("Obtain columns for the tables found in template #: ",cnvtstring(
     m_xnt_pl_templates->list[m_xnt_pl_template_loop].template_nbr))
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM user_tab_cols utc
    WHERE expand(m_xnt_pl_idx2,1,m_xnt_pl_table_list->tab_cnt,utc.table_name,m_xnt_pl_table_list->
     list[m_xnt_pl_idx2].table_name)
     AND utc.virtual_column="NO"
     AND utc.hidden_column="NO"
    ORDER BY utc.table_name, utc.column_name
    HEAD utc.table_name
     m_xnt_pl_idx = locateval(m_xnt_pl_idx2,1,m_xnt_pl_table_list->tab_cnt,utc.table_name,
      m_xnt_pl_table_list->list[m_xnt_pl_idx2].table_name)
    DETAIL
     m_xnt_pl_table_list->list[m_xnt_pl_idx].col_cnt = (m_xnt_pl_table_list->list[m_xnt_pl_idx].
     col_cnt+ 1), stat = alterlist(m_xnt_pl_table_list->list[m_xnt_pl_idx].qual,m_xnt_pl_table_list->
      list[m_xnt_pl_idx].col_cnt), m_xnt_pl_table_list->list[m_xnt_pl_idx].qual[m_xnt_pl_table_list->
     list[m_xnt_pl_idx].col_cnt].col_name = utc.column_name,
     m_xnt_pl_table_list->list[m_xnt_pl_idx].qual[m_xnt_pl_table_list->list[m_xnt_pl_idx].col_cnt].
     col_data_type = utc.data_type
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    GO TO exit_program
   ENDIF
   FOR (m_xnt_pl_pair_loop = 1 TO m_xnt_pl_table_pair->cnt)
     SET m_xnt_par_tbl_idx = locateval(m_xnt_pl_idx,1,m_xnt_pl_table_list->tab_cnt,
      m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].parent_table,m_xnt_pl_table_list->list[
      m_xnt_pl_idx].table_name)
     SET m_xnt_cld_tbl_idx = locateval(m_xnt_pl_idx,1,m_xnt_pl_table_list->tab_cnt,
      m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].child_table,m_xnt_pl_table_list->list[
      m_xnt_pl_idx].table_name)
     IF ((((m_xnt_pl_table_list->list[m_xnt_par_tbl_idx].table_skip_ind=1)) OR ((m_xnt_pl_table_list
     ->list[m_xnt_cld_tbl_idx].table_skip_ind=1))) )
      SET m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].skip_ind = 1
     ENDIF
     IF ((m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].skip_ind != 1))
      IF (size(trim(m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].parent_col1,3)) > 0
       AND size(trim(m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].child_col1,3)) > 0)
       SET m_xnt_pl_idx2 = locateval(m_xnt_pl_idx,1,m_xnt_pl_table_list->list[m_xnt_par_tbl_idx].
        col_cnt,m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].parent_col1,m_xnt_pl_table_list->list[
        m_xnt_par_tbl_idx].qual[m_xnt_pl_idx].col_name)
       IF (m_xnt_pl_idx2=0)
        SET m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].skip_ind = 1
       ENDIF
       SET m_xnt_pl_idx2 = locateval(m_xnt_pl_idx,1,m_xnt_pl_table_list->list[m_xnt_cld_tbl_idx].
        col_cnt,m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].child_col1,m_xnt_pl_table_list->list[
        m_xnt_cld_tbl_idx].qual[m_xnt_pl_idx].col_name)
       IF (m_xnt_pl_idx2=0)
        SET m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].skip_ind = 1
       ENDIF
      ELSEIF (((size(trim(m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].parent_col1,3)) > 0) OR (size
      (trim(m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].child_col1,3)) > 0)) )
       SET m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].skip_ind = 1
      ENDIF
     ENDIF
     IF ((m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].skip_ind != 1))
      IF (size(trim(m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].parent_col2,3)) > 0
       AND size(trim(m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].child_col2,3)) > 0)
       SET m_xnt_pl_idx2 = locateval(m_xnt_pl_idx,1,m_xnt_pl_table_list->list[m_xnt_par_tbl_idx].
        col_cnt,m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].parent_col2,m_xnt_pl_table_list->list[
        m_xnt_par_tbl_idx].qual[m_xnt_pl_idx].col_name)
       IF (m_xnt_pl_idx2=0)
        SET m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].skip_ind = 1
       ENDIF
       SET m_xnt_pl_idx2 = locateval(m_xnt_pl_idx,1,m_xnt_pl_table_list->list[m_xnt_cld_tbl_idx].
        col_cnt,m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].child_col2,m_xnt_pl_table_list->list[
        m_xnt_cld_tbl_idx].qual[m_xnt_pl_idx].col_name)
       IF (m_xnt_pl_idx2=0)
        SET m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].skip_ind = 1
       ENDIF
      ELSEIF (((size(trim(m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].parent_col2,3)) > 0) OR (size
      (trim(m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].child_col2,3)) > 0)) )
       SET m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].skip_ind = 1
      ENDIF
     ENDIF
     IF ((m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].skip_ind != 1))
      IF (size(trim(m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].parent_col3,3)) > 0
       AND size(trim(m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].child_col3,3)) > 0)
       SET m_xnt_pl_idx2 = locateval(m_xnt_pl_idx,1,m_xnt_pl_table_list->list[m_xnt_par_tbl_idx].
        col_cnt,m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].parent_col3,m_xnt_pl_table_list->list[
        m_xnt_par_tbl_idx].qual[m_xnt_pl_idx].col_name)
       IF (m_xnt_pl_idx2=0)
        SET m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].skip_ind = 1
       ENDIF
       SET m_xnt_pl_idx2 = locateval(m_xnt_pl_idx,1,m_xnt_pl_table_list->list[m_xnt_cld_tbl_idx].
        col_cnt,m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].child_col3,m_xnt_pl_table_list->list[
        m_xnt_cld_tbl_idx].qual[m_xnt_pl_idx].col_name)
       IF (m_xnt_pl_idx2=0)
        SET m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].skip_ind = 1
       ENDIF
      ELSEIF (((size(trim(m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].parent_col3,3)) > 0) OR (size
      (trim(m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].child_col3,3)) > 0)) )
       SET m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].skip_ind = 1
      ENDIF
     ENDIF
     IF ((m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].skip_ind != 1))
      IF (size(trim(m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].parent_col4,3)) > 0
       AND size(trim(m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].child_col4,3)) > 0)
       SET m_xnt_pl_idx2 = locateval(m_xnt_pl_idx,1,m_xnt_pl_table_list->list[m_xnt_par_tbl_idx].
        col_cnt,m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].parent_col4,m_xnt_pl_table_list->list[
        m_xnt_par_tbl_idx].qual[m_xnt_pl_idx].col_name)
       IF (m_xnt_pl_idx2=0)
        SET m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].skip_ind = 1
       ENDIF
       SET m_xnt_pl_idx2 = locateval(m_xnt_pl_idx,1,m_xnt_pl_table_list->list[m_xnt_cld_tbl_idx].
        col_cnt,m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].child_col4,m_xnt_pl_table_list->list[
        m_xnt_cld_tbl_idx].qual[m_xnt_pl_idx].col_name)
       IF (m_xnt_pl_idx2=0)
        SET m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].skip_ind = 1
       ENDIF
      ELSEIF (((size(trim(m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].parent_col4,3)) > 0) OR (size
      (trim(m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].child_col4,3)) > 0)) )
       SET m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].skip_ind = 1
      ENDIF
     ENDIF
     IF ((m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].skip_ind != 1))
      IF (size(trim(m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].parent_col5,3)) > 0
       AND size(trim(m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].child_col5,3)) > 0)
       SET m_xnt_pl_idx2 = locateval(m_xnt_pl_idx,1,m_xnt_pl_table_list->list[m_xnt_par_tbl_idx].
        col_cnt,m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].parent_col5,m_xnt_pl_table_list->list[
        m_xnt_par_tbl_idx].qual[m_xnt_pl_idx].col_name)
       IF (m_xnt_pl_idx2=0)
        SET m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].skip_ind = 1
       ENDIF
       SET m_xnt_pl_idx2 = locateval(m_xnt_pl_idx,1,m_xnt_pl_table_list->list[m_xnt_cld_tbl_idx].
        col_cnt,m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].child_col5,m_xnt_pl_table_list->list[
        m_xnt_cld_tbl_idx].qual[m_xnt_pl_idx].col_name)
       IF (m_xnt_pl_idx2=0)
        SET m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].skip_ind = 1
       ENDIF
      ELSEIF (((size(trim(m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].parent_col5,3)) > 0) OR (size
      (trim(m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].child_col5,3)) > 0)) )
       SET m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].skip_ind = 1
      ENDIF
     ENDIF
     IF ((m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].skip_ind=1))
      SET m_xnt_pl_table_list->list[m_xnt_cld_tbl_idx].table_skip_ind = 1
     ENDIF
   ENDFOR
   IF (put_plsql_head(0,m_xnt_pl_table_pair,m_xnt_pl_table_list,m_xnt_pl_stmts,m_xnt_pl_templates->
    list[m_xnt_pl_template_loop].master_table,
    m_xnt_pl_templates->list[m_xnt_pl_template_loop].template_nbr)=0)
    GO TO exit_program
   ENDIF
   FOR (m_xnt_pl_pair_loop = 1 TO m_xnt_pl_table_pair->cnt)
     IF ((m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].skip_ind != 1))
      IF (put_plsql_head(m_xnt_pl_pair_loop,m_xnt_pl_table_pair,m_xnt_pl_table_list,m_xnt_pl_stmts,
       m_xnt_pl_templates->list[m_xnt_pl_template_loop].master_table,
       m_xnt_pl_templates->list[m_xnt_pl_template_loop].template_nbr)=0)
       GO TO exit_program
      ENDIF
     ENDIF
   ENDFOR
   FOR (m_xnt_pl_pair_loop = 1 TO m_xnt_pl_table_pair->cnt)
     IF ((m_xnt_pl_table_pair->qual[m_xnt_pl_pair_loop].skip_ind != 1))
      CALL put_plsql_body(m_xnt_pl_pair_loop,m_xnt_pl_table_pair,m_xnt_pl_table_list,m_xnt_pl_stmts,
       m_xnt_pl_templates->list[m_xnt_pl_template_loop].master_table)
     ENDIF
   ENDFOR
   FOR (m_xnt_pl_pair_loop = 1 TO m_xnt_pl_stmts->cnt)
     CALL put_plsql_end(m_xnt_pl_pair_loop,m_xnt_pl_table_pair,m_xnt_pl_table_list,m_xnt_pl_stmts,
      m_xnt_pl_templates->list[m_xnt_pl_template_loop].master_table)
   ENDFOR
   FOR (m_xnt_pl_idx = 1 TO m_xnt_pl_stmts->cnt)
     SET m_dxxp_request->cnt = 0
     SET stat = alterlist(m_dxxp_request->qual,(m_xnt_pl_stmts->list[m_xnt_pl_idx].stmt_cnt+ 1))
     FOR (m_xnt_pl_idx2 = 1 TO m_xnt_pl_stmts->list[m_xnt_pl_idx].stmt_cnt)
      SET m_dxxp_request->cnt = (m_dxxp_request->cnt+ 1)
      IF (m_xnt_pl_idx2=1)
       SET m_dxxp_request->qual[m_dxxp_request->cnt].str = concat("rdb asis(^",m_xnt_pl_stmts->list[
        m_xnt_pl_idx].qual[m_xnt_pl_idx2].stmt_str,char(10),"^)")
      ELSE
       SET m_dxxp_request->qual[m_dxxp_request->cnt].str = concat(" asis(^",m_xnt_pl_stmts->list[
        m_xnt_pl_idx].qual[m_xnt_pl_idx2].stmt_str,char(10),"^)")
      ENDIF
     ENDFOR
     SET m_dxxp_request->cnt = (m_dxxp_request->cnt+ 1)
     SET m_dxxp_request->qual[m_dxxp_request->cnt].str = " end go "
     EXECUTE dm2_xnt_xml_parser  WITH replace("DXXP_REQUEST","M_DXXP_REQUEST")
     IF ((dm_err->err_ind=1))
      IF (findstring("24344",dm_err->emsg,1,0) > 0)
       SET dm_err->err_ind = 0
       SET dm_err->eproc = "Ignore the above ORA- error"
       CALL disp_msg("",dm_err->logfile,0)
      ELSE
       GO TO exit_program
      ENDIF
     ENDIF
   ENDFOR
   SET m_xnt_pl_stmts->cnt = 0
   SET stat = alterlist(m_xnt_pl_stmts->list,0)
 ENDFOR
 SET dm_err->eproc = "Validating Procedures"
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM user_objects uo
  WHERE uo.object_name="DM_XNT*"
   AND uo.object_type="PROCEDURE"
   AND uo.status="INVALID"
  HEAD REPORT
   m_xnt_recompile->cnt = 0
  DETAIL
   m_xnt_recompile->cnt = (m_xnt_recompile->cnt+ 1), stat = alterlist(m_xnt_recompile->list,
    m_xnt_recompile->cnt), m_xnt_recompile->list[m_xnt_recompile->cnt].alter_stmt = concat(
    " rdb alter procedure ",trim(uo.object_name)," compile go ")
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 FOR (m_xnt_pl_idx = 1 TO m_xnt_recompile->cnt)
   CALL dm2_push_cmd(m_xnt_recompile->list[m_xnt_pl_idx].alter_stmt,1)
 ENDFOR
 SELECT INTO "nl:"
  FROM user_objects uo
  WHERE uo.object_name="DM_XNT*"
   AND uo.object_type="PROCEDURE"
   AND uo.status="INVALID"
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 IF (curqual > 0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Found an INVALID DM_XNT* procedure"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 SUBROUTINE dxp_crt_cld_parms(i_cld_col,i_cld_dt,i_str)
  IF (size(trim(i_str))=0)
   SET i_str = concat("     ||' where ",trim(i_cld_col)," ='")
  ELSE
   SET i_str = concat(i_str," ||' and ",trim(i_cld_col)," = '")
  ENDIF
  IF (i_cld_dt IN ("FLOAT", "NUMBER"))
   SET i_str = concat(i_str,"|| i_",trim(i_cld_col)," ")
  ELSEIF (i_cld_dt IN ("CHAR", "VARCHAR2"))
   SET i_str = concat(i_str,"''|| i_",trim(i_cld_col),"||'''' ")
  ELSE
   SET i_str = concat(i_str,"can not handle datatype")
  ENDIF
 END ;Subroutine
 SUBROUTINE put_plsql_head(i_pos,io_table_pair,io_table_list,io_stmts,i_table_name,i_templ_nbr)
   DECLARE s_pph_table_name = vc WITH protect, noconstant(" ")
   DECLARE s_pph_top_tbl_ind = i2 WITH protect, noconstant(0)
   DECLARE s_pph_idx = i4 WITH protect, noconstant(0)
   DECLARE s_pph_table_list_loc = i4 WITH protect, noconstant(0)
   DECLARE s_pph_stmt_loc = i4 WITH protect, noconstant(0)
   DECLARE s_pph_col_loc = i4 WITH protect, noconstant(0)
   DECLARE s_pph_temp_str = vc WITH protect, noconstant(" ")
   DECLARE s_pph_str = vc WITH protect, noconstant(" ")
   DECLARE s_pph_col_loop = i4 WITH protect, noconstant(0)
   DECLARE s_pph_extra_loop = i4 WITH protect, noconstant(0)
   DECLARE s_pph_pk_col = vc WITH protect, noconstant(" ")
   DECLARE s_pph_rec_logic_ind = i2 WITH protect, noconstant(0)
   DECLARE s_pph_rec_col_name = vc WITH protect, noconstant(" ")
   FREE RECORD s_pph_extra_parms
   RECORD s_pph_extra_parms(
     1 cnt = i4
     1 list[*]
       2 parm_str = vc
   )
   IF (i_pos > 0)
    SET s_pph_table_name = trim(io_table_pair->qual[i_pos].child_table)
    IF ((io_table_pair->qual[i_pos].child_table=io_table_pair->qual[i_pos].parent_table))
     SET s_pph_rec_logic_ind = 1
    ENDIF
   ELSE
    SET s_pph_table_name = trim(i_table_name)
    SET s_pph_top_tbl_ind = 1
   ENDIF
   SET s_pph_table_list_loc = locateval(s_pph_idx,1,io_table_list->tab_cnt,s_pph_table_name,
    io_table_list->list[s_pph_idx].table_name)
   IF (size(trim(io_table_list->list[s_pph_table_list_loc].rec_col,3)) > 0)
    SET s_pph_rec_col_name = trim(io_table_list->list[s_pph_table_list_loc].rec_col,3)
    SET s_pph_rec_logic_ind = 1
   ELSE
    IF (s_pph_rec_logic_ind=1)
     SET dm_err->emsg = concat(
      "Recursive logic expected, but could not find recursive column for table : ",s_pph_table_name)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     ROLLBACK
     RETURN(0)
    ENDIF
   ENDIF
   IF (s_pph_rec_logic_ind=0)
    IF ((io_table_pair->qual[i_pos].parent_table="CLINICAL_EVENT"))
     SET s_pph_rec_logic_ind = 2
     SET s_pph_rec_col_name = io_table_pair->qual[i_pos].child_col1
    ENDIF
   ENDIF
   SET s_pph_stmt_loc = locateval(s_pph_idx,1,io_stmts->cnt,s_pph_table_name,io_stmts->list[s_pph_idx
    ].table_name)
   IF (s_pph_top_tbl_ind != 1)
    IF (s_pph_stmt_loc > 0
     AND (io_stmts->list[s_pph_stmt_loc].type="P"))
     SET s_pph_stmt_loc = 0
    ENDIF
   ENDIF
   IF (s_pph_stmt_loc=0)
    SET io_stmts->cnt = (io_stmts->cnt+ 1)
    SET stat = alterlist(io_stmts->list,io_stmts->cnt)
    SET io_stmts->list[io_stmts->cnt].table_name = s_pph_table_name
    SET io_stmts->list[io_stmts->cnt].skip_ind = 0
    IF (s_pph_top_tbl_ind=1)
     SET io_stmts->list[io_stmts->cnt].type = "P"
     SET s_pph_temp_str = "procedure dm_xnt_"
    ELSE
     SET io_stmts->list[io_stmts->cnt].type = "F"
     SET s_pph_temp_str = concat("function dm_xnt_",trim(i_table_name,3),"_")
    ENDIF
    SET s_pph_str = concat(" create or replace ",s_pph_temp_str,trim(io_table_list->list[
      s_pph_table_list_loc].table_suffix),"( ")
    CALL put_plsql_stmt(io_stmts->cnt,io_stmts,s_pph_str)
    CALL put_plsql_stmt(io_stmts->cnt,io_stmts," i_dm_xnt_log_id number, ")
    CALL put_plsql_stmt(io_stmts->cnt,io_stmts," i_delete_ind number, ")
    CALL put_plsql_stmt(io_stmts->cnt,io_stmts," i_person_id number ")
    IF (s_pph_top_tbl_ind=1)
     IF (s_pph_table_name="ORDERS")
      CALL put_plsql_stmt(io_stmts->cnt,io_stmts,", i_status_cd varchar2 ")
     ENDIF
     SET dm_err->eproc = "Obtaining special tokens"
     CALL disp_msg(" ",dm_err->logfile,0)
     SET s_pph_extra_parms->cnt = 0
     SELECT INTO "nl:"
      FROM dm_purge_token dpt
      WHERE dpt.template_nbr=i_templ_nbr
       AND  NOT (dpt.token_str IN ("EXTRACT_AGE", "EXTRACT_FREQUENCY", "EXTRACT_NAME", "JOBNAME"))
       AND (dpt.schema_dt_tm=
      (SELECT
       max(p1.schema_dt_tm)
       FROM dm_purge_token p1
       WHERE p1.template_nbr=i_templ_nbr))
      ORDER BY dpt.token_str
      DETAIL
       s_pph_extra_parms->cnt = (s_pph_extra_parms->cnt+ 1), stat = alterlist(s_pph_extra_parms->list,
        s_pph_extra_parms->cnt), s_pph_extra_parms->list[s_pph_extra_parms->cnt].parm_str = concat(
        ", i_",cnvtlower(trim(dpt.token_str,3)))
       IF (dpt.data_type_flag=3)
        s_pph_extra_parms->list[s_pph_extra_parms->cnt].parm_str = concat(s_pph_extra_parms->list[
         s_pph_extra_parms->cnt].parm_str," varchar2 ")
       ELSEIF (dpt.data_type_flag=1)
        s_pph_extra_parms->list[s_pph_extra_parms->cnt].parm_str = concat(s_pph_extra_parms->list[
         s_pph_extra_parms->cnt].parm_str," number ")
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      ROLLBACK
      RETURN(0)
     ENDIF
     IF ((s_pph_extra_parms->cnt > 0))
      FOR (s_pph_extra_loop = 1 TO s_pph_extra_parms->cnt)
        IF (s_pph_table_name != "ORDERS")
         CALL put_plsql_stmt(io_stmts->cnt,io_stmts,s_pph_extra_parms->list[s_pph_extra_loop].
          parm_str)
        ELSE
         IF (s_pph_extra_loop=1)
          CALL put_plsql_stmt(io_stmts->cnt,io_stmts,", i_xnt_extra varchar2 ")
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
     CALL put_plsql_stmt(io_stmts->cnt,io_stmts,", i_updt_dt_tm date ) as ")
    ELSE
     SET s_pph_temp_str = ""
     IF (size(trim(io_table_pair->qual[i_pos].child_col1)) != 0)
      SET s_pph_col_loc = locateval(s_pph_idx,1,io_table_list->list[s_pph_table_list_loc].col_cnt,
       io_table_pair->qual[i_pos].child_col1,io_table_list->list[s_pph_table_list_loc].qual[s_pph_idx
       ].col_name)
      SET s_pph_str = concat(", i_",trim(io_table_pair->qual[i_pos].child_col1)," ",trim(
        io_table_list->list[s_pph_table_list_loc].qual[s_pph_col_loc].col_data_type))
      CALL put_plsql_stmt(io_stmts->cnt,io_stmts,s_pph_str)
      CALL dxp_crt_cld_parms(io_table_pair->qual[i_pos].child_col1,io_table_list->list[
       s_pph_table_list_loc].qual[s_pph_col_loc].col_data_type,s_pph_temp_str)
     ENDIF
     IF (size(trim(io_table_pair->qual[i_pos].child_col2)) != 0)
      SET s_pph_col_loc = locateval(s_pph_idx,1,io_table_list->list[s_pph_table_list_loc].col_cnt,
       io_table_pair->qual[i_pos].child_col2,io_table_list->list[s_pph_table_list_loc].qual[s_pph_idx
       ].col_name)
      SET s_pph_str = concat(" ,i_",trim(io_table_pair->qual[i_pos].child_col2)," ",trim(
        io_table_list->list[s_pph_table_list_loc].qual[s_pph_col_loc].col_data_type))
      CALL put_plsql_stmt(io_stmts->cnt,io_stmts,s_pph_str)
      CALL dxp_crt_cld_parms(io_table_pair->qual[i_pos].child_col2,io_table_list->list[
       s_pph_table_list_loc].qual[s_pph_col_loc].col_data_type,s_pph_temp_str)
     ENDIF
     IF (size(trim(io_table_pair->qual[i_pos].child_col3)) != 0)
      SET s_pph_col_loc = locateval(s_pph_idx,1,io_table_list->list[s_pph_table_list_loc].col_cnt,
       io_table_pair->qual[i_pos].child_col3,io_table_list->list[s_pph_table_list_loc].qual[s_pph_idx
       ].col_name)
      SET s_pph_str = concat(" ,i_",trim(io_table_pair->qual[i_pos].child_col3)," ",trim(
        io_table_list->list[s_pph_table_list_loc].qual[s_pph_col_loc].col_data_type))
      CALL put_plsql_stmt(io_stmts->cnt,io_stmts,s_pph_str)
      CALL dxp_crt_cld_parms(io_table_pair->qual[i_pos].child_col3,io_table_list->list[
       s_pph_table_list_loc].qual[s_pph_col_loc].col_data_type,s_pph_temp_str)
     ENDIF
     IF (size(trim(io_table_pair->qual[i_pos].child_col4)) != 0)
      SET s_pph_col_loc = locateval(s_pph_idx,1,io_table_list->list[s_pph_table_list_loc].col_cnt,
       io_table_pair->qual[i_pos].child_col4,io_table_list->list[s_pph_table_list_loc].qual[s_pph_idx
       ].col_name)
      SET s_pph_str = concat(" ,i_",trim(io_table_pair->qual[i_pos].child_col4)," ",trim(
        io_table_list->list[s_pph_table_list_loc].qual[s_pph_col_loc].col_data_type))
      CALL put_plsql_stmt(io_stmts->cnt,io_stmts,s_pph_str)
      CALL dxp_crt_cld_parms(io_table_pair->qual[i_pos].child_col4,io_table_list->list[
       s_pph_table_list_loc].qual[s_pph_col_loc].col_data_type,s_pph_temp_str)
     ENDIF
     IF (size(trim(io_table_pair->qual[i_pos].child_col5)) != 0)
      SET s_pph_col_loc = locateval(s_pph_idx,1,io_table_list->list[s_pph_table_list_loc].col_cnt,
       io_table_pair->qual[i_pos].child_col5,io_table_list->list[s_pph_table_list_loc].qual[s_pph_idx
       ].col_name)
      SET s_pph_str = concat(" ,i_",trim(io_table_pair->qual[i_pos].child_col5)," ",trim(
        io_table_list->list[s_pph_table_list_loc].qual[s_pph_col_loc].col_data_type))
      CALL put_plsql_stmt(io_stmts->cnt,io_stmts,s_pph_str)
      CALL dxp_crt_cld_parms(io_table_pair->qual[i_pos].child_col5,io_table_list->list[
       s_pph_table_list_loc].qual[s_pph_col_loc].col_data_type,s_pph_temp_str)
     ENDIF
     IF (size(trim(io_table_pair->qual[i_pos].child_where)) != 0)
      CALL put_plsql_stmt(io_stmts->cnt,io_stmts," ,i_child_where varchar2 ")
      SET s_pph_temp_str = concat(s_pph_temp_str," ||' and '||i_child_where ")
     ENDIF
     CALL put_plsql_stmt(io_stmts->cnt,io_stmts," ,i_par_tbl varchar2 ")
     CALL put_plsql_stmt(io_stmts->cnt,io_stmts," ) return number as")
    ENDIF
    CALL put_plsql_stmt(io_stmts->cnt,io_stmts,"    rows_found number; ")
    CALL put_plsql_stmt(io_stmts->cnt,io_stmts,"    rows_deleted number; ")
    CALL put_plsql_stmt(io_stmts->cnt,io_stmts,"    TYPE gencur IS REF CURSOR; ")
    CALL put_plsql_stmt(io_stmts->cnt,io_stmts,"    rows_cs gencur; ")
    CALL put_plsql_stmt(io_stmts->cnt,io_stmts,"    del_str varchar2(1000); ")
    CALL put_plsql_stmt(io_stmts->cnt,io_stmts,"    sel_str varchar2(1000); ")
    CALL put_plsql_stmt(io_stmts->cnt,io_stmts,concat("    item ",s_pph_table_name,"%ROWTYPE; "))
    CALL put_plsql_stmt(io_stmts->cnt,io_stmts,"    BEGIN ")
    CALL put_plsql_stmt(io_stmts->cnt,io_stmts,"      rows_found:=0; ")
    IF (s_pph_top_tbl_ind=1)
     SET dm_err->eproc = "Obtaining person_select query"
     CALL disp_msg(" ",dm_err->logfile,0)
     SET s_pph_str = "     sel_str := ' select m.* from "
     SET s_pph_temp_str = "      del_str := ' delete from "
     SELECT INTO "nl:"
      FROM dm_info di
      WHERE di.info_domain="DM2XNT_SQL*"
       AND di.info_name=trim(cnvtupper(s_pph_table_name),3)
      DETAIL
       IF (di.info_domain="DM2XNT_SQL_SELECT")
        s_pph_str = concat(s_pph_str,di.info_char)
       ELSE
        s_pph_temp_str = concat(s_pph_temp_str,di.info_char)
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      ROLLBACK
      RETURN(0)
     ENDIF
     IF (((size(trim(s_pph_str,3))=0) OR (size(trim(s_pph_temp_str,3))=0)) )
      SET dm_err->err_ind = 1
      SET dm_err->emsg = concat("Could not find sql_select or sql_delete for ",s_pph_table_name)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      ROLLBACK
      RETURN(0)
     ENDIF
     CALL put_plsql_stmt(io_stmts->cnt,io_stmts,s_pph_str)
     CALL put_plsql_stmt(io_stmts->cnt,io_stmts,s_pph_temp_str)
     CALL put_plsql_stmt(io_stmts->cnt,io_stmts,
      "      dm_xnt_xml_put.xml_seq_id:= dm_xnt_xml_put.init_var; ")
    ELSE
     CALL put_plsql_stmt(io_stmts->cnt,io_stmts,concat("    del_str:='delete from ",s_pph_table_name,
       "' "))
     CALL put_plsql_stmt(io_stmts->cnt,io_stmts,concat(s_pph_temp_str,";"))
     IF (s_pph_rec_logic_ind=1)
      SET s_pph_temp_str = concat(s_pph_temp_str," ||' and ",s_pph_rec_col_name,
       " not in (select dxi.xnt_id from "," dm_xnt_ids_gttd dxi where dxi.table_name = ''",
       s_pph_rec_col_name,"'')'")
     ENDIF
     IF (s_pph_rec_logic_ind=2)
      SET s_pph_temp_str = concat(s_pph_temp_str," ||' and ",s_pph_rec_col_name,
       " not in (select dxi.xnt_id from "," dm_xnt_ids_gttd dxi where dxi.table_name = ''",
       s_pph_table_name,"'')'")
     ENDIF
     CALL put_plsql_stmt(io_stmts->cnt,io_stmts,concat("    sel_str:='select * from ",
       s_pph_table_name,"' "))
     CALL put_plsql_stmt(io_stmts->cnt,io_stmts,concat(s_pph_temp_str,";"))
    ENDIF
    CALL put_plsql_stmt(io_stmts->cnt,io_stmts,"      dbms_output.put_line(sel_str); ")
    CALL put_plsql_stmt(io_stmts->cnt,io_stmts,"      OPEN rows_cs FOR sel_str; ")
    CALL put_plsql_stmt(io_stmts->cnt,io_stmts,"       LOOP ")
    CALL put_plsql_stmt(io_stmts->cnt,io_stmts,"         FETCH rows_cs INTO item; ")
    CALL put_plsql_stmt(io_stmts->cnt,io_stmts,"         EXIT WHEN rows_cs%NOTFOUND; ")
    CALL put_plsql_stmt(io_stmts->cnt,io_stmts,
     "       IF (rows_found = 0 and i_delete_ind = 0) THEN ")
    CALL put_plsql_stmt(io_stmts->cnt,io_stmts,
     "         dm_xnt_xml_put.put_str_data('<table_data>');")
    CALL put_plsql_stmt(io_stmts->cnt,io_stmts,concat(
      "         dm_xnt_xml_put.put_str_data('<table_name>",s_pph_table_name,"</table_name>');"))
    CALL put_plsql_stmt(io_stmts->cnt,io_stmts,
     "         dm_xnt_xml_put.put_str_data('<table_rows>');")
    CALL put_plsql_stmt(io_stmts->cnt,io_stmts,"       END IF; ")
    CALL put_plsql_stmt(io_stmts->cnt,io_stmts,"       rows_found:= rows_found + 1; ")
    SELECT INTO "nl:"
     FROM user_constraints uc,
      user_cons_columns ucc
     WHERE uc.table_name=s_pph_table_name
      AND uc.constraint_type="P"
      AND ucc.constraint_name=uc.constraint_name
     DETAIL
      s_pph_pk_col = trim(ucc.column_name,3)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     ROLLBACK
     RETURN(0)
    ENDIF
    IF (((s_pph_top_tbl_ind=1) OR (s_pph_table_name="CLINICAL_EVENT")) )
     CALL put_plsql_stmt(io_stmts->cnt,io_stmts,"       IF (i_delete_ind = 1) THEN ")
     CALL put_plsql_stmt(io_stmts->cnt,io_stmts,concat("         dm_xnt_xml_put.put_id_data(item.",
       s_pph_pk_col,",'",s_pph_table_name,"');"))
     CALL put_plsql_stmt(io_stmts->cnt,io_stmts,"       END IF; ")
    ENDIF
    IF (s_pph_rec_logic_ind=1)
     CALL put_plsql_stmt(io_stmts->cnt,io_stmts,concat("       dm_xnt_xml_put.put_id_data(item.",
       s_pph_rec_col_name,",'",s_pph_rec_col_name,"');"))
    ENDIF
    IF (s_pph_rec_logic_ind=2)
     CALL put_plsql_stmt(io_stmts->cnt,io_stmts,concat("       dm_xnt_xml_put.put_id_data(item.",
       s_pph_rec_col_name,",'",s_pph_table_name,"');"))
    ENDIF
    CALL put_plsql_stmt(io_stmts->cnt,io_stmts,"       IF (i_delete_ind = 0) THEN ")
    CALL put_plsql_stmt(io_stmts->cnt,io_stmts,"         dm_xnt_xml_put.put_str_data('<row_data>');")
    FOR (s_pph_col_loop = 1 TO io_table_list->list[s_pph_table_list_loc].col_cnt)
      IF ((io_table_list->list[s_pph_table_list_loc].qual[s_pph_col_loop].col_data_type="CLOB"))
       CALL put_plsql_stmt(io_stmts->cnt,io_stmts,concat(
         "         dm_xnt_xml_put.get_xnt_clob_data('",s_pph_table_name,"','",trim(io_table_list->
          list[s_pph_table_list_loc].qual[s_pph_col_loop].col_name),"','",
         s_pph_pk_col,"',item.",s_pph_pk_col,"); "))
      ELSEIF ((io_table_list->list[s_pph_table_list_loc].qual[s_pph_col_loop].col_data_type="LONG"))
       CALL put_plsql_stmt(io_stmts->cnt,io_stmts,concat(
         "         dm_xnt_xml_put.get_xnt_long_data('",s_pph_table_name,"','",trim(io_table_list->
          list[s_pph_table_list_loc].qual[s_pph_col_loop].col_name),"','",
         s_pph_pk_col,"',item.",s_pph_pk_col,"); "))
      ELSEIF ((io_table_list->list[s_pph_table_list_loc].qual[s_pph_col_loop].col_data_type=
      "TIMESTAMP*"))
       CALL put_plsql_stmt(io_stmts->cnt,io_stmts,concat("         dm_xnt_xml_put.put_column_data('",
         trim(io_table_list->list[s_pph_table_list_loc].qual[s_pph_col_loop].col_name),
         "', to_char(item.",trim(io_table_list->list[s_pph_table_list_loc].qual[s_pph_col_loop].
          col_name),",'DD-MM-YYYY HH24:MI:SS:FF9')); "))
      ELSE
       CALL put_plsql_stmt(io_stmts->cnt,io_stmts,concat("         dm_xnt_xml_put.put_column_data('",
         trim(io_table_list->list[s_pph_table_list_loc].qual[s_pph_col_loop].col_name),"', item.",
         trim(io_table_list->list[s_pph_table_list_loc].qual[s_pph_col_loop].col_name),"); "))
      ENDIF
    ENDFOR
    CALL put_plsql_stmt(io_stmts->cnt,io_stmts,"       END IF; ")
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE put_plsql_body(i_pos,io_table_pair,io_table_list,io_stmts,i_table_name)
   DECLARE s_ppb_top_tbl_ind = i2 WITH protect, noconstant(0)
   DECLARE s_ppb_table_list_loc = i4 WITH protect, noconstant(0)
   DECLARE s_ppb_stmt_loc = i4 WITH protect, noconstant(0)
   DECLARE s_ppb_idx = i4 WITH protect, noconstant(0)
   DECLARE s_ppb_table_name = vc WITH protect, noconstant(" ")
   DECLARE s_ppb_str = vc WITH protect, noconstant(" ")
   DECLARE s_ppb_rec_col = vc WITH protect, noconstant(" ")
   DECLARE s_ppb_stmt_loc_fun = i4 WITH protect, noconstant(0)
   DECLARE s_ppb_rec_ind = i2 WITH protect, noconstant(0)
   DECLARE s_ppb_table_list_parent_loc = i4 WITH protect, noconstant(0)
   SET s_ppb_table_name = trim(io_table_pair->qual[i_pos].parent_table,3)
   IF (s_ppb_table_name=trim(i_table_name))
    SET s_ppb_top_tbl_ind = 1
   ENDIF
   SET s_ppb_table_list_loc = locateval(s_ppb_idx,1,io_table_list->tab_cnt,io_table_pair->qual[i_pos]
    .child_table,io_table_list->list[s_ppb_idx].table_name)
   SET s_ppb_table_list_parent_loc = locateval(s_ppb_idx,1,io_table_list->tab_cnt,s_ppb_table_name,
    io_table_list->list[s_ppb_idx].table_name)
   IF ((io_table_list->list[s_ppb_table_list_parent_loc].table_skip_ind=0))
    SET s_ppb_rec_col = trim(io_table_list->list[s_ppb_table_list_parent_loc].rec_col,3)
    IF (size(s_ppb_rec_col) > 0)
     SET s_ppb_rec_ind = 1
    ENDIF
    SET s_ppb_stmt_loc = locateval(s_ppb_idx,1,io_stmts->cnt,s_ppb_table_name,io_stmts->list[
     s_ppb_idx].table_name)
    IF (s_ppb_top_tbl_ind=1
     AND s_ppb_rec_ind=1)
     SET s_ppb_stmt_loc_fun = locateval(s_ppb_idx,(s_ppb_stmt_loc+ 1),io_stmts->cnt,s_ppb_table_name,
      io_stmts->list[s_ppb_idx].table_name)
    ENDIF
    SET s_ppb_str = concat("     IF (dm_xnt_",trim(i_table_name,3),"_",trim(io_table_list->list[
      s_ppb_table_list_loc].table_suffix),"( i_dm_xnt_log_id,i_delete_ind, i_person_id")
    IF (size(trim(io_table_pair->qual[i_pos].parent_col1)) != 0)
     SET s_ppb_str = concat(s_ppb_str,",item.",trim(io_table_pair->qual[i_pos].parent_col1))
    ENDIF
    IF (size(trim(io_table_pair->qual[i_pos].parent_col2)) != 0)
     SET s_ppb_str = concat(s_ppb_str,",item.",trim(io_table_pair->qual[i_pos].parent_col2))
    ENDIF
    IF (size(trim(io_table_pair->qual[i_pos].parent_col3)) != 0)
     SET s_ppb_str = concat(s_ppb_str,",item.",trim(io_table_pair->qual[i_pos].parent_col3))
    ENDIF
    IF (size(trim(io_table_pair->qual[i_pos].parent_col4)) != 0)
     SET s_ppb_str = concat(s_ppb_str,",item.",trim(io_table_pair->qual[i_pos].parent_col4))
    ENDIF
    IF (size(trim(io_table_pair->qual[i_pos].parent_col5)) != 0)
     SET s_ppb_str = concat(s_ppb_str,",item.",trim(io_table_pair->qual[i_pos].parent_col5))
    ENDIF
    IF (size(trim(io_table_pair->qual[i_pos].child_where)) != 0)
     SET s_ppb_str = concat(s_ppb_str,",'",io_table_pair->qual[i_pos].child_where,"'")
    ENDIF
    SET s_ppb_str = concat(s_ppb_str,",'",s_ppb_table_name,"')=0) THEN ")
    CALL put_plsql_stmt(s_ppb_stmt_loc,io_stmts,s_ppb_str)
    IF (s_ppb_stmt_loc_fun > 0)
     CALL put_plsql_stmt(s_ppb_stmt_loc_fun,io_stmts,s_ppb_str)
    ENDIF
    IF (s_ppb_top_tbl_ind=0)
     CALL put_plsql_stmt(s_ppb_stmt_loc,io_stmts,"          return 0;")
    ELSE
     SET s_ppb_str = concat(
      "      raise_application_error(-20101,sqlerrm||' Error detected in dm_xnt_",trim(i_table_name,3
       ),"_",trim(io_table_list->list[s_ppb_table_list_loc].table_suffix),"');")
     CALL put_plsql_stmt(s_ppb_stmt_loc,io_stmts,s_ppb_str)
     IF (s_ppb_stmt_loc_fun > 0)
      CALL put_plsql_stmt(s_ppb_stmt_loc_fun,io_stmts,"          return 0;")
     ENDIF
    ENDIF
    CALL put_plsql_stmt(s_ppb_stmt_loc,io_stmts,"       END IF;")
    IF (s_ppb_stmt_loc_fun > 0)
     CALL put_plsql_stmt(s_ppb_stmt_loc_fun,io_stmts,"       END IF;")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE put_plsql_end(i_pos,io_table_pair,io_table_list,io_stmts,i_table_name)
   DECLARE s_ppe_table_list_loc = i4 WITH protect, noconstant(0)
   DECLARE s_ppe_idx = i4 WITH protect, noconstant(0)
   DECLARE s_ppe_top_tbl_ind = i2 WITH protect, noconstant(0)
   DECLARE s_ppe_pair_loc = i4 WITH protect, noconstant(0)
   DECLARE s_ppe_table_name = vc WITH protect, noconstant(" ")
   DECLARE s_ppe_str = vc WITH protect, noconstant(" ")
   DECLARE s_ppe_temp_str = vc WITH protect, noconstant(" ")
   SET s_ppe_table_name = trim(io_stmts->list[i_pos].table_name)
   IF (s_ppe_table_name=trim(i_table_name)
    AND (io_stmts->list[i_pos].type="P"))
    SET s_ppe_top_tbl_ind = 1
   ENDIF
   SET s_ppe_table_list_loc = locateval(s_ppe_idx,1,io_table_list->tab_cnt,s_ppe_table_name,
    io_table_list->list[s_ppe_idx].table_name)
   SET s_ppe_pair_loc = locateval(s_ppe_idx,1,io_table_pair->cnt,s_ppe_table_name,io_table_pair->
    qual[s_ppe_idx].child_table)
   IF ((io_table_list->list[s_ppe_table_list_loc].table_skip_ind=0))
    CALL put_plsql_stmt(i_pos,io_stmts,"       IF (i_delete_ind = 0) THEN ")
    CALL put_plsql_stmt(i_pos,io_stmts,"         dm_xnt_xml_put.put_str_data('</row_data>');")
    CALL put_plsql_stmt(i_pos,io_stmts,"       END IF; ")
    CALL put_plsql_stmt(i_pos,io_stmts,"       END LOOP; ")
    CALL put_plsql_stmt(i_pos,io_stmts,"       CLOSE rows_cs; ")
    CALL put_plsql_stmt(i_pos,io_stmts,"       IF (rows_found > 0 and i_delete_ind = 0) THEN ")
    CALL put_plsql_stmt(i_pos,io_stmts,"         dm_xnt_xml_put.put_str_data('</table_rows>'); ")
    CALL put_plsql_stmt(i_pos,io_stmts,"         dm_xnt_xml_put.put_str_data('</table_data>'); ")
    CALL put_plsql_stmt(i_pos,io_stmts,"       END IF; ")
    CALL put_plsql_stmt(i_pos,io_stmts,"       IF (i_delete_ind = 0) THEN ")
    IF (s_ppe_top_tbl_ind=1)
     CALL put_plsql_stmt(i_pos,io_stmts,concat(
       "         dm_xnt_xml_put.put_xnt_log_cnt(i_dm_xnt_log_id,'",s_ppe_table_name,"','",
       s_ppe_table_name,"',rows_found,0);"))
    ELSE
     CALL put_plsql_stmt(i_pos,io_stmts,concat(
       "         dm_xnt_xml_put.put_xnt_log_cnt(i_dm_xnt_log_id,'",s_ppe_table_name,
       "',i_par_tbl,rows_found,0);"))
    ENDIF
    CALL put_plsql_stmt(i_pos,io_stmts,"       ELSE ")
    CALL put_plsql_stmt(i_pos,io_stmts,"          EXECUTE IMMEDIATE del_str;")
    CALL put_plsql_stmt(i_pos,io_stmts,"          rows_deleted:=sql%rowcount;")
    IF (s_ppe_top_tbl_ind=1)
     CALL put_plsql_stmt(i_pos,io_stmts,concat(
       "         dm_xnt_xml_put.put_xnt_log_cnt(i_dm_xnt_log_id,'",s_ppe_table_name,"','",
       s_ppe_table_name,"',rows_deleted,1);"))
    ELSE
     CALL put_plsql_stmt(i_pos,io_stmts,concat(
       "         dm_xnt_xml_put.put_xnt_log_cnt(i_dm_xnt_log_id,'",s_ppe_table_name,
       "',i_par_tbl,rows_deleted,1);"))
    ENDIF
    CALL put_plsql_stmt(i_pos,io_stmts,"       END IF; ")
    IF (s_ppe_top_tbl_ind=0)
     CALL put_plsql_stmt(i_pos,io_stmts,"            return 1; ")
    ENDIF
    CALL put_plsql_stmt(i_pos,io_stmts,"     EXCEPTION")
    CALL put_plsql_stmt(i_pos,io_stmts,"     WHEN OTHERS THEN")
    SET s_ppe_temp_str = " "
    IF (s_ppe_top_tbl_ind=1
     AND (io_stmts->list[i_pos].type="P"))
     SET s_ppe_temp_str = "' i_updt_dt_tm = ' || to_char(i_updt_dt_tm,'DD-MM-YYYYY HH24:MI:SS') || "
    ELSE
     IF (size(trim(io_table_pair->qual[s_ppe_pair_loc].child_col1)) != 0)
      SET s_ppe_temp_str = concat(" ' ",trim(io_table_pair->qual[s_ppe_pair_loc].child_col1),
       "= ' || i_",trim(io_table_pair->qual[s_ppe_pair_loc].child_col1),"||  ' ' ||")
     ENDIF
     IF (size(trim(io_table_pair->qual[s_ppe_pair_loc].child_col2)) != 0)
      SET s_ppe_temp_str = concat(s_ppe_temp_str," ' ",trim(io_table_pair->qual[s_ppe_pair_loc].
        child_col2),"= ' || i_",trim(io_table_pair->qual[s_ppe_pair_loc].child_col2),
       " ||  ' ' ||")
     ENDIF
     IF (size(trim(io_table_pair->qual[s_ppe_pair_loc].child_col3)) != 0)
      SET s_ppe_temp_str = concat(s_ppe_temp_str," ' ",trim(io_table_pair->qual[s_ppe_pair_loc].
        child_col3),"= ' || i_",trim(io_table_pair->qual[s_ppe_pair_loc].child_col3),
       " ||  ' ' ||")
     ENDIF
     IF (size(trim(io_table_pair->qual[s_ppe_pair_loc].child_col4)) != 0)
      SET s_ppe_temp_str = concat(s_ppe_temp_str," ' ",trim(io_table_pair->qual[s_ppe_pair_loc].
        child_col4),"= ' || i_",trim(io_table_pair->qual[s_ppe_pair_loc].child_col4),
       " ||  ' ' ||")
     ENDIF
     IF (size(trim(io_table_pair->qual[s_ppe_pair_loc].child_col5)) != 0)
      SET s_ppe_temp_str = concat(s_ppe_temp_str," ' ",trim(io_table_pair->qual[s_ppe_pair_loc].
        child_col5),"= ' || i_",trim(io_table_pair->qual[s_ppe_pair_loc].child_col5),
       " ||  ' ' ||")
     ENDIF
    ENDIF
    SET s_ppe_str = concat(
     "     dm_xnt_xml_put.put_xnt_log_dtl_err(i_dm_xnt_log_id,substr(sqlerrm||' Error encountered in dm_xnt_",
     io_table_list->list[s_ppe_table_list_loc].table_suffix,"' || ",s_ppe_temp_str,"' ',1,1000));")
    CALL put_plsql_stmt(i_pos,io_stmts,s_ppe_str)
    IF (s_ppe_top_tbl_ind=0)
     CALL put_plsql_stmt(i_pos,io_stmts,"            return 0; ")
    ELSE
     CALL put_plsql_stmt(i_pos,io_stmts,"            raise_application_error(-20101, sqlerrm); ")
    ENDIF
    CALL put_plsql_stmt(i_pos,io_stmts," END; ")
   ENDIF
 END ;Subroutine
 SUBROUTINE put_plsql_stmt(i_pos,io_stmt_rs,i_str)
   SET io_stmts->list[i_pos].stmt_cnt = (io_stmts->list[i_pos].stmt_cnt+ 1)
   SET stat = alterlist(io_stmts->list[i_pos].qual,io_stmts->list[i_pos].stmt_cnt)
   SET io_stmts->list[i_pos].qual[io_stmts->list[i_pos].stmt_cnt].stmt_str = i_str
 END ;Subroutine
#exit_program
 IF ((dm_err->err_ind != 0))
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  ROLLBACK
 ELSE
  UPDATE  FROM dm_info di
   SET di.info_date = cnvtdatetime(curdate,curtime3)
   WHERE di.info_domain="DATA MANAGEMENT"
    AND di.info_name="XNT_PLSQL_GEN"
   WITH nocounter
  ;end update
  IF (curqual=0)
   INSERT  FROM dm_info di
    SET di.info_date = cnvtdatetime(curdate,curtime3), di.info_domain = "DATA MANAGEMENT", di
     .info_name = "XNT_PLSQL_GEN"
    WITH nocounter
   ;end insert
  ENDIF
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   ROLLBACK
  ELSE
   COMMIT
  ENDIF
 ENDIF
END GO
