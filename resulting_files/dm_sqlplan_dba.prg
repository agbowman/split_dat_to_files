CREATE PROGRAM dm_sqlplan:dba
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
 IF ((validate(daic_rac_inst_data->instance_cnt,- (999))=- (999))
  AND validate(daic_rac_inst_data->instance_cnt,999)=999)
  FREE RECORD daic_rac_inst_data
  RECORD daic_rac_inst_data(
    1 instance_cnt = i4
    1 qual[*]
      2 inst_id = i4
      2 instance_name = vc
      2 host_name = vc
      2 partial_host_name = vc
      2 thread_number = i4
  )
 ENDIF
 DECLARE dm2_active_instance_count(instance_count=i4(ref)) = i2
 SUBROUTINE dm2_active_instance_count(instance_count)
   IF ((daic_rac_inst_data->instance_cnt > 0))
    SET daic_rac_inst_data->instance_cnt = 0
    SET stat = alterlist(daic_rac_inst_data->qual,0)
   ENDIF
   SET dm_err->eproc = "Determining how many instances are running, from v$thread/gv$instance."
   SELECT INTO "nl:"
    FROM v$thread vt,
     gv$instance vi
    WHERE vt.status="OPEN"
     AND vt.thread#=vi.thread#
    ORDER BY vi.inst_id
    DETAIL
     daic_rac_inst_data->instance_cnt = (daic_rac_inst_data->instance_cnt+ 1)
     IF (mod(daic_rac_inst_data->instance_cnt,10)=1)
      stat = alterlist(daic_rac_inst_data->qual,(daic_rac_inst_data->instance_cnt+ 9))
     ENDIF
     daic_rac_inst_data->qual[daic_rac_inst_data->instance_cnt].inst_id = vi.inst_id,
     daic_rac_inst_data->qual[daic_rac_inst_data->instance_cnt].instance_name = vi.instance_name,
     daic_rac_inst_data->qual[daic_rac_inst_data->instance_cnt].host_name = vi.host_name,
     daic_rac_inst_data->qual[daic_rac_inst_data->instance_cnt].partial_host_name = substring(1,
      evaluate(findstring(".",vi.host_name),0,size(vi.host_name),(findstring(".",vi.host_name) - 1)),
      vi.host_name), daic_rac_inst_data->qual[daic_rac_inst_data->instance_cnt].thread_number = vi
     .thread#
    FOOT REPORT
     stat = alterlist(daic_rac_inst_data->qual,daic_rac_inst_data->instance_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET instance_count = curqual
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(daic_rac_inst_data)
   ENDIF
   RETURN(1)
 END ;Subroutine
 IF ((validate(dcr_optvalues->force_ind,- (1))=- (1))
  AND (validate(dcr_optvalues->force_ind,- (2))=- (2)))
  FREE RECORD dcr_optvalues
  RECORD dcr_optvalues(
    1 session_opt_mode = vc
    1 implementer_opt_mode = vc
    1 force_ind = i2
  )
 ENDIF
 DECLARE dcr_get_optimizer_settings(null) = i2
 DECLARE dcr_get_purge_size(block_size=i4(ref)) = i2
 DECLARE dcr_get_newest_snapshot(snapshot_id=f8(ref)) = i2
 DECLARE dcr_get_bg_exec_threshold(threshold=f8(ref)) = i2
 DECLARE dcr_get_nearness_factor(factor=f8(ref)) = i2
 DECLARE dcr_get_opt_mode_by_num(opt_num=i4) = vc
 DECLARE dcr_get_opt_mode_by_name(opt_name=vc) = i4
 SUBROUTINE dcr_get_optimizer_settings(null)
   DECLARE dgos_info_exists = i2 WITH protect, noconstant(0)
   IF ((dcr_optvalues->force_ind=1))
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Selecting current optimizer_mode from v$parameter."
   SELECT INTO "nl:"
    FROM v$parameter vp
    WHERE vp.name="optimizer_mode"
    DETAIL
     dcr_optvalues->session_opt_mode = cnvtupper(vp.value)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dcr_optvalues->implementer_opt_mode = dcr_optvalues->session_opt_mode
   IF (dm2_table_and_ccldef_exists("DM_INFO",dgos_info_exists)=0)
    RETURN(0)
   ENDIF
   IF (dgos_info_exists=1)
    SET dm_err->eproc = "Selecting current optimizer mode from dm_info via info_name."
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DM_SET_SESSION_PARAMETERS"
      AND di.info_name="OPTIMIZER_MODE"
     DETAIL
      start = findstring("=",di.info_char), dcr_optvalues->implementer_opt_mode = cnvtupper(trim(
        substring((start+ 1),(size(di.info_char) - start),di.info_char),3))
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET dm_err->eproc = "Selecting current optimizer mode from dm_info via info_char."
     SELECT INTO "nl:"
      FROM dm_info di
      WHERE di.info_domain="DM_SET_SESSION_PARAMETERS"
       AND cnvtupper(di.info_char)="*OPTIMIZER_MODE*"
      DETAIL
       start = findstring("=",di.info_char), dcr_optvalues->implementer_opt_mode = cnvtupper(trim(
         substring((start+ 1),(size(di.info_char) - start),di.info_char),3))
      WITH nocounter, nullreport
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcr_get_purge_size(block_size)
   SET dm_err->eproc = "Selecting purge batch rows from dm_info."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE "DATA MANAGEMENT"=di.info_domain
     AND "PURGE BATCH ROWS"=di.info_name
    HEAD REPORT
     block_size = 5000
    DETAIL
     block_size = cnvtint(di.info_number)
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcr_get_newest_snapshot(snapshot_id)
   SET dm_err->eproc = "Selecting newest snapshot."
   SELECT INTO "nl:"
    FROM dm_sql_mgmt dsm
    WHERE "COMPLETE"=dsm.status
    ORDER BY dsm.snap_end_dt_tm DESC
    DETAIL
     snapshot_id = dsm.snapshot_id,
     CALL cancel(1)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcr_get_bg_exec_threshold(threshold)
   SET dm_err->eproc = "Selecting DM CBO IMPLEMENTER->GETS PER EXECUTE MAX threshold from dm_info."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM_CBO_IMPLEMENTER"
     AND di.info_name="BG_EX_THRESHOLD"
    HEAD REPORT
     threshold = 3000.0
    DETAIL
     threshold = di.info_number
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcr_get_nearness_factor(factor)
   SET dm_err->eproc = "Selecting nearness factor from dm_info"
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM_CBO_IMPLEMENTER"
     AND di.info_name="NEARNESS_FACTOR"
    HEAD REPORT
     factor = 1
    DETAIL
     IF (di.info_number >= 0.0
      AND di.info_number <= 100.0)
      factor = (1+ (di.info_number/ 100))
     ENDIF
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcr_get_opt_mode_by_num(opt_num)
   RETURN(evaluate(opt_num,1,"RULE",2,"CHOOSE",
    3,"FIRST_ROWS_1",4,"FIRST_ROWS_10",5,
    "FIRST_ROWS_100",6,"FIRST_ROWS_1000",7,"FIRST_ROWS",
    8,"ALL_ROWS","UNKNOWN"))
 END ;Subroutine
 SUBROUTINE dcr_get_opt_mode_by_name(opt_name)
   RETURN(evaluate(opt_name,"RULE",1,"CHOOSE",2,
    "FIRST_ROWS_1",3,"FIRST_ROWS_10",4,"FIRST_ROWS_100",
    5,"FIRST_ROWS_1000",6,"FIRST_ROWS",7,
    "ALL_ROWS",8,0))
 END ;Subroutine
 DECLARE ml_expand_num = i4 WITH protect, noconstant(0)
 DECLARE ml_num_loops = i4 WITH protect, noconstant(0)
 DECLARE ml_loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_start_val = i4 WITH protect, noconstant(0)
 DECLARE ml_cur_list_size = i4 WITH protect, noconstant(0)
 DECLARE ml_new_list_size = i4 WITH protect, noconstant(0)
 DECLARE mn_can_use_expand = i2 WITH protect, noconstant(0)
 DECLARE ds_active_inst_cnt = i4 WITH protect, noconstant(0)
 DECLARE ds_search = i4 WITH protect, noconstant(0)
 DECLARE ds_max_items = i4 WITH protect, noconstant(0)
 DECLARE ds_script_name = vc WITH protect, noconstant("")
 DECLARE mn_batch_size = i2 WITH protect, constant(50)
 DECLARE ms_sqlplan_version = vc WITH protect, constant("1.1")
 FREE RECORD instance_list
 RECORD instance_list(
   1 cnt = i4
   1 qual[*]
     2 inst_id = f8
     2 inst_name = vc
     2 host_name = vc
 )
 DECLARE delim_check(sbr_vc_string=vc) = i4
 DECLARE dgui_short_stmts(sbr_text=vc) = null
 IF (check_logfile("dm_sqlplan",".log","DM_SQLPLAN LOGFILE")=0)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Beginning DM_SQLPLAN"
 CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
 SET width = 132
 SET message = window
 CALL video(l)
 CALL text(1,1,"Enter the number of queries to be analyzed:")
 CALL accept(1,45,"999",25)
 SET prompt_val1 = curaccept
 CALL text(2,1,"Enter in the name of the script to be analyzed:")
 CALL accept(2,49,"p(40);cu","*")
 SET prompt_val2 = curaccept
 IF (prompt_val2 > " ")
  SET ds_script_name = build("*",cnvtupper(trim(prompt_val2)),"*")
 ELSE
  SET ds_script_name = "*"
 ENDIF
 SET ds_max_items = prompt_val1
 IF (((((currev * 10000)+ (currevminor * 100))+ currevminor2) >= 80203))
  SET mn_can_use_expand = 1
 ENDIF
 SET dm_err->eproc = "Getting list of instances from gv$instance."
 SELECT INTO "nl:"
  FROM gv$instance vi
  ORDER BY vi.instance_number
  HEAD REPORT
   instance_list->cnt = 0, stat = alterlist(instance_list->qual,0)
  DETAIL
   instance_list->cnt = (instance_list->cnt+ 1), stat = alterlist(instance_list->qual,instance_list->
    cnt), instance_list->qual[instance_list->cnt].inst_id = vi.instance_number,
   instance_list->qual[instance_list->cnt].inst_name = vi.instance_name, instance_list->qual[
   instance_list->cnt].host_name = vi.host_name
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF (dcr_get_optimizer_settings(null)=0)
  GO TO exit_script
 ENDIF
 CALL dm2_get_rdbms_version(null)
 SET prompt3_text = concat("Enter sort criteria (1 = Buffer Gets, 2 = Disk Reads, 3 = Buffer Ratio,",
  " 4 = Executions, 5 = Score):")
 CALL text(3,1,prompt3_text)
 CALL accept(3,(findstring(":",prompt3_text)+ 2),"9",1)
 SET prompt_val3 = curaccept
 IF (dm2_set_inhouse_domain(null)=0)
  GO TO exit_script
 ENDIF
 IF ((inhouse_misc->inhouse_domain=1))
  IF ((dm2_rdbms_version->level1 < 10))
   CALL text(4,1,"Enter Oracle Optimizer mode (C = Cost, R = Rule):")
   CALL accept(4,51,"P;CU","R"
    WHERE curaccept IN ("C", "R"))
   IF (curaccept="R")
    IF (dm2_push_cmd("rdb alter session set optimizer_mode = rule go",1)=0)
     GO TO exit_script
    ENDIF
   ELSE
    IF ((dcr_optvalues->implementer_opt_mode="RULE"))
     IF (dm2_push_cmd("rdb alter session set optimizer_mode = ALL_ROWS go",1)=0)
      GO TO exit_script
     ENDIF
    ELSE
     IF (dm2_push_cmd(concat("rdb alter session set optimizer_mode = ",dcr_optvalues->
       implementer_opt_mode," go"),1)=0)
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 SET message = nowindow
 SET width = 132
 DECLARE file_name = vc
 FREE SET sql_text
 RECORD sql_text(
   1 text_cnt = i4
   1 qual[*]
     2 inst_id = f8
     2 parse_calls = f8
     2 loads = f8
     2 users_executing = f8
     2 sorts = f8
     2 parsing_user_id = f8
     2 address = gc4
     2 hash_value = f8
     2 buff = f8
     2 exec = f8
     2 disk = f8
     2 first_time = c19
     2 rat = f8
     2 drat = f8
     2 piece_cnt = i4
     2 stmt = vc
     2 stmt_len = i4
     2 stmt_flag = i2
     2 flag = i4
     2 score = f8
     2 sharable_mem = f8
     2 cpu_time = f8
     2 optimizer_mode = vc
     2 qual[*]
       3 text = vc
     2 plan_in_oracle_ind = i2
     2 oracle_plan_rows[*]
       3 operation = vc
       3 options = vc
       3 object_node = vc
       3 object_owner = vc
       3 object_name = vc
       3 object_instance = i4
       3 optimizer = vc
       3 search_columns = i4
       3 id = i4
       3 parent_id = f8
       3 position = i4
       3 cost = i4
       3 cardinality = i4
       3 bytes = i4
       3 other_tag = vc
       3 other = vc
       3 index_columns = vc
 )
 FREE SET stmt
 RECORD stmt(
   1 stmt_cnt = i4
   1 qual[*]
     2 stmt_id = vc
     2 unique_id = f8
 )
 FREE SET errors
 RECORD errors(
   1 list[*]
     2 err_msg = c132
 )
 FREE SET dgui_short_stmts
 RECORD dgui_short_stmts(
   1 qual[*]
     2 stmt = vc
 )
 RECORD m_dm2_seq_stat(
   1 n_status = i4
   1 s_error_msg = vc
 ) WITH protect
 SET dm_err->eproc = "Determining qualifying queries from gv$sqlarea."
 SELECT
  IF (((prompt_val3=1) OR (prompt_val3=0)) )
   ORDER BY a.buffer_gets DESC, a.disk_reads DESC, a.address
  ELSEIF (prompt_val3=2)
   ORDER BY a.disk_reads DESC, a.buffer_gets DESC, a.address
  ELSEIF (prompt_val3=3)
   ORDER BY ratio DESC, a.buffer_gets DESC, a.disk_reads DESC
  ELSEIF (prompt_val3=4)
   ORDER BY a.executions DESC, a.buffer_gets DESC, a.disk_reads DESC
  ELSEIF (prompt_val3=5)
   ORDER BY a_score DESC, a.buffer_gets DESC, a.disk_reads DESC
  ELSE
  ENDIF
  INTO "nl:"
  ratio = (a.buffer_gets/ a.executions), dratio = (a.disk_reads/ a.executions), a_score = ((a
  .buffer_gets+ (a.executions * 200))+ (a.disk_reads * 200))
  FROM gv$sqlarea a
  WHERE 0 < a.buffer_gets
   AND 0 < a.executions
   AND a.first_load_time >= ""
   AND a.sql_text != "*CCLSQLAREA*"
   AND a.sql_text != "*DM_SQLAREA*"
   AND a.sql_text != "*DM_SQLPLAN*"
   AND a.sql_text != "*DM_SQL_PLAN*"
   AND a.sql_text != "*V$SQLAREA*"
   AND a.sql_text != "*PLAN_TABLE*"
   AND a.sql_text=patstring(ds_script_name)
  HEAD REPORT
   sql_text->text_cnt = 0, script_cnt = 0
  DETAIL
   script_cnt = (script_cnt+ 1)
   IF (script_cnt <= ds_max_items)
    sql_text->text_cnt = (sql_text->text_cnt+ 1), stat = alterlist(sql_text->qual,sql_text->text_cnt),
    sql_text->qual[sql_text->text_cnt].piece_cnt = 0,
    sql_text->qual[sql_text->text_cnt].address = a.address, sql_text->qual[sql_text->text_cnt].
    hash_value = a.hash_value, sql_text->qual[sql_text->text_cnt].buff = a.buffer_gets,
    sql_text->qual[sql_text->text_cnt].exec = a.executions, sql_text->qual[sql_text->text_cnt].disk
     = a.disk_reads, sql_text->qual[sql_text->text_cnt].first_time = a.first_load_time,
    sql_text->qual[sql_text->text_cnt].rat = ratio, sql_text->qual[sql_text->text_cnt].drat = dratio,
    sql_text->qual[sql_text->text_cnt].parse_calls = a.parse_calls,
    sql_text->qual[sql_text->text_cnt].loads = a.loads, sql_text->qual[sql_text->text_cnt].
    users_executing = a.users_executing, sql_text->qual[sql_text->text_cnt].sorts = a.sorts,
    sql_text->qual[sql_text->text_cnt].parsing_user_id = a.parsing_user_id, sql_text->qual[sql_text->
    text_cnt].stmt_flag = 0, sql_text->qual[sql_text->text_cnt].score = a_score,
    sql_text->qual[sql_text->text_cnt].stmt_len = textlen(trim(a.sql_text)), sql_text->qual[sql_text
    ->text_cnt].sharable_mem = a.sharable_mem, sql_text->qual[sql_text->text_cnt].cpu_time = validate
    (a.cpu_time,- (1)),
    sql_text->qual[sql_text->text_cnt].optimizer_mode = trim(a.optimizer_mode), sql_text->qual[
    sql_text->text_cnt].inst_id = a.inst_id
    IF ((sql_text->qual[sql_text->text_cnt].stmt_len >= 990))
     sql_text->qual[sql_text->text_cnt].stmt_flag = 1, sql_text->qual[sql_text->text_cnt].stmt = " "
    ELSE
     sql_text->qual[sql_text->text_cnt].stmt = trim(a.sql_text)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF ((sql_text->text_cnt > 0))
  SET dm_err->eproc = "Retrieving sql_text data from gv$sqltext when sql_text length >= 990."
  SELECT INTO "nl:"
   FROM gv$sqltext t,
    (dummyt d  WITH seq = value(sql_text->text_cnt))
   PLAN (d
    WHERE (sql_text->qual[d.seq].stmt_flag=1))
    JOIN (t
    WHERE (t.hash_value=sql_text->qual[d.seq].hash_value)
     AND (t.inst_id=sql_text->qual[d.seq].inst_id))
   ORDER BY t.inst_id, t.hash_value, t.piece
   HEAD t.inst_id
    row + 0
   HEAD t.hash_value
    sql_text->qual[d.seq].piece_cnt = 0, stat = alterlist(sql_text->qual[d.seq].qual,0), sql_text->
    qual[d.seq].stmt_flag = 0
   DETAIL
    sql_text->qual[d.seq].piece_cnt = (sql_text->qual[d.seq].piece_cnt+ 1), stat = alterlist(sql_text
     ->qual[d.seq].qual,sql_text->qual[d.seq].piece_cnt), sql_text->qual[d.seq].qual[sql_text->qual[d
    .seq].piece_cnt].text = t.sql_text
    IF ((sql_text->qual[d.seq].piece_cnt=1))
     sql_text->qual[d.seq].stmt = t.sql_text
    ELSE
     IF (substring(64,1,sql_text->qual[d.seq].qual[(sql_text->qual[d.seq].piece_cnt - 1)].text)=" ")
      sql_text->qual[d.seq].stmt = concat(sql_text->qual[d.seq].stmt," ",t.sql_text)
     ELSE
      sql_text->qual[d.seq].stmt = concat(sql_text->qual[d.seq].stmt,t.sql_text)
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((sql_text->text_cnt=0))
  SET dm_err->eproc = "No Data Found For This Object"
  CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Generating statement ids"
 CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
 EXECUTE dm2_install_get_bulk_seq "stmt->qual", value(sql_text->text_cnt), "unique_id",
 1, "DM_CLINICAL_SEQ"
 IF ((m_dm2_seq_stat->n_status != 1))
  SET dm_err->err_ind = 1
  SET dm_err->eproc = "Call to DM2_INSTALL_GET_BULK_SEQ"
  SET dm_err->emsg = m_dm2_seq_stat->s_error_msg
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 FOR (cntx = 1 TO size(stmt->qual,5))
   SET stmt->qual[cntx].stmt_id = trim(cnvtstring(stmt->qual[cntx].unique_id),3)
 ENDFOR
 SET dm_err->eproc = "Deleting statements from dm_sql_plan if they exist"
 CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
 IF (mn_can_use_expand=1)
  SET ml_cur_list_size = size(stmt->qual,5)
  SET ml_num_loops = ceil((cnvtreal(ml_cur_list_size)/ mn_batch_size))
  SET ml_new_list_size = (ml_num_loops * mn_batch_size)
  SET stat = alterlist(stmt->qual,ml_new_list_size)
  FOR (ml_loop_cnt = (ml_cur_list_size+ 1) TO ml_new_list_size)
    SET stmt->qual[ml_loop_cnt].stmt_id = stmt->qual[ml_cur_list_size].stmt_id
  ENDFOR
  SET ml_start_val = 1
  SET dm_err->eproc = "Deleting existing rows from dm_sql_plan by statement_id for CCL >= 8.2.03."
  DELETE  FROM dm_sql_plan ds,
    (dummyt d  WITH seq = value(ml_num_loops))
   SET ds.seq = 1
   PLAN (d
    WHERE initarray(ml_start_val,evaluate(d.seq,1,1,(ml_start_val+ mn_batch_size))))
    JOIN (ds
    WHERE expand(ml_expand_num,ml_start_val,(ml_start_val+ (mn_batch_size - 1)),ds.statement_id,stmt
     ->qual[ml_expand_num].stmt_id))
   WITH nocounter
  ;end delete
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  SET stat = alterlist(stmt->qual,ml_cur_list_size)
 ELSE
  SET dm_err->eproc = "Deleting existing rows from dm_sql_plan by statement_id for CCL < 8.2.03."
  DELETE  FROM dm_sql_plan ds,
    (dummyt d  WITH seq = value(size(stmt->qual,5)))
   SET ds.seq = 1
   PLAN (d)
    JOIN (ds
    WHERE (ds.statement_id=stmt->qual[d.seq].stmt_id))
   WITH nocounter
  ;end delete
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((dm2_rdbms_version->level1 >= 9))
  SET dm_err->eproc = "Determining if statement exists on gv$sql_plan"
  CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
  IF (mn_can_use_expand=1)
   SET ml_cur_list_size = size(sql_text->qual,5)
   SET ml_num_loops = ceil((cnvtreal(ml_cur_list_size)/ mn_batch_size))
   SET ml_new_list_size = (ml_num_loops * mn_batch_size)
   SET stat = alterlist(sql_text->qual,ml_new_list_size)
   FOR (ml_loop_cnt = (ml_cur_list_size+ 1) TO ml_new_list_size)
    SET sql_text->qual[ml_loop_cnt].hash_value = sql_text->qual[ml_cur_list_size].hash_value
    SET sql_text->qual[ml_loop_cnt].inst_id = sql_text->qual[ml_cur_list_size].inst_id
   ENDFOR
   SET ml_start_val = 1
   SELECT INTO "nl:"
    FROM gv$sql_plan vsp,
     (dummyt d  WITH seq = value(ml_num_loops))
    PLAN (d
     WHERE initarray(ml_start_val,evaluate(d.seq,1,1,(ml_start_val+ mn_batch_size))))
     JOIN (vsp
     WHERE expand(ml_expand_num,ml_start_val,(ml_start_val+ (mn_batch_size - 1)),vsp.hash_value,
      sql_text->qual[ml_expand_num].hash_value,
      vsp.inst_id,sql_text->qual[ml_expand_num].inst_id))
    ORDER BY vsp.hash_value, vsp.inst_id
    HEAD REPORT
     mn_idx = 0, ml_loop_idx = 0
    HEAD vsp.hash_value
     row + 0
    HEAD vsp.inst_id
     mn_cnt = 0, mn_idx = locateval(ml_loop_idx,1,ml_cur_list_size,vsp.hash_value,sql_text->qual[
      ml_loop_idx].hash_value,
      vsp.inst_id,sql_text->qual[ml_loop_idx].inst_id)
     IF (mn_idx > 0)
      sql_text->qual[mn_idx].plan_in_oracle_ind = 1
     ENDIF
    DETAIL
     IF (mn_idx > 0)
      mn_cnt = (mn_cnt+ 1)
      IF (mod(mn_cnt,10)=1)
       stat = alterlist(sql_text->qual[mn_idx].oracle_plan_rows,(mn_cnt+ 9))
      ENDIF
      sql_text->qual[mn_idx].oracle_plan_rows[mn_cnt].bytes = vsp.bytes, sql_text->qual[mn_idx].
      oracle_plan_rows[mn_cnt].cardinality = vsp.cardinality, sql_text->qual[mn_idx].
      oracle_plan_rows[mn_cnt].cost = vsp.cost,
      sql_text->qual[mn_idx].oracle_plan_rows[mn_cnt].id = vsp.id, sql_text->qual[mn_idx].
      oracle_plan_rows[mn_cnt].object_name = vsp.object_name, sql_text->qual[mn_idx].
      oracle_plan_rows[mn_cnt].object_node = vsp.object_node,
      sql_text->qual[mn_idx].oracle_plan_rows[mn_cnt].object_owner = vsp.object_owner, sql_text->
      qual[mn_idx].oracle_plan_rows[mn_cnt].operation = vsp.operation, sql_text->qual[mn_idx].
      oracle_plan_rows[mn_cnt].optimizer = vsp.optimizer,
      sql_text->qual[mn_idx].oracle_plan_rows[mn_cnt].options = vsp.options, sql_text->qual[mn_idx].
      oracle_plan_rows[mn_cnt].other = vsp.other, sql_text->qual[mn_idx].oracle_plan_rows[mn_cnt].
      other_tag = vsp.other_tag,
      sql_text->qual[mn_idx].oracle_plan_rows[mn_cnt].parent_id = vsp.parent_id, sql_text->qual[
      mn_idx].oracle_plan_rows[mn_cnt].position = vsp.position, sql_text->qual[mn_idx].
      oracle_plan_rows[mn_cnt].search_columns = vsp.search_columns
     ENDIF
    FOOT  vsp.inst_id
     IF (mn_idx > 0)
      stat = alterlist(sql_text->qual[mn_idx].oracle_plan_rows,mn_cnt)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_script
   ENDIF
   SET stat = alterlist(sql_text->qual,ml_cur_list_size)
  ELSE
   SELECT INTO "nl:"
    FROM gv$sql_plan vsp,
     (dummyt d  WITH seq = value(sql_text->text_cnt))
    PLAN (d)
     JOIN (vsp
     WHERE (vsp.hash_value=sql_text->qual[d.seq].hash_value)
      AND (vsp.inst_id=sql_text->qual[d.seq].inst_id))
    ORDER BY vsp.hash_value, vsp.inst_id
    HEAD REPORT
     mn_cnt = 0
    HEAD vsp.hash_value
     row + 0
    HEAD vsp.inst_id
     mn_cnt = 0, sql_text->qual[d.seq].plan_in_oracle_ind = 1
    DETAIL
     mn_cnt = (mn_cnt+ 1)
     IF (mod(mn_cnt,10)=1)
      stat = alterlist(sql_text->qual[d.seq].oracle_plan_rows,(mn_cnt+ 9))
     ENDIF
     sql_text->qual[d.seq].oracle_plan_rows[mn_cnt].bytes = vsp.bytes, sql_text->qual[d.seq].
     oracle_plan_rows[mn_cnt].cardinality = vsp.cardinality, sql_text->qual[d.seq].oracle_plan_rows[
     mn_cnt].cost = vsp.cost,
     sql_text->qual[d.seq].oracle_plan_rows[mn_cnt].id = vsp.id, sql_text->qual[d.seq].
     oracle_plan_rows[mn_cnt].object_name = vsp.object_name, sql_text->qual[d.seq].oracle_plan_rows[
     mn_cnt].object_node = vsp.object_node,
     sql_text->qual[d.seq].oracle_plan_rows[mn_cnt].object_owner = vsp.object_owner, sql_text->qual[d
     .seq].oracle_plan_rows[mn_cnt].operation = vsp.operation, sql_text->qual[d.seq].
     oracle_plan_rows[mn_cnt].optimizer = vsp.optimizer,
     sql_text->qual[d.seq].oracle_plan_rows[mn_cnt].options = vsp.options, sql_text->qual[d.seq].
     oracle_plan_rows[mn_cnt].other = vsp.other, sql_text->qual[d.seq].oracle_plan_rows[mn_cnt].
     other_tag = vsp.other_tag,
     sql_text->qual[d.seq].oracle_plan_rows[mn_cnt].parent_id = vsp.parent_id, sql_text->qual[d.seq].
     oracle_plan_rows[mn_cnt].position = vsp.position, sql_text->qual[d.seq].oracle_plan_rows[mn_cnt]
     .search_columns = vsp.search_columns
    FOOT  vsp.inst_id
     stat = alterlist(sql_text->qual[d.seq].oracle_plan_rows,mn_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_script
   ENDIF
  ENDIF
  SET dm_err->eproc = "Inserting plans to dm_sql_plan"
  CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
  INSERT  FROM dm_sql_plan dsp,
    (dummyt d1  WITH seq = value(sql_text->text_cnt)),
    (dummyt d2  WITH seq = 1)
   SET dsp.statement_id = stmt->qual[d1.seq].stmt_id, dsp.bytes = sql_text->qual[d1.seq].
    oracle_plan_rows[d2.seq].bytes, dsp.cardinality = sql_text->qual[d1.seq].oracle_plan_rows[d2.seq]
    .cardinality,
    dsp.cost = sql_text->qual[d1.seq].oracle_plan_rows[d2.seq].cost, dsp.id = sql_text->qual[d1.seq].
    oracle_plan_rows[d2.seq].id, dsp.object_name = sql_text->qual[d1.seq].oracle_plan_rows[d2.seq].
    object_name,
    dsp.object_node = sql_text->qual[d1.seq].oracle_plan_rows[d2.seq].object_node, dsp.object_owner
     = sql_text->qual[d1.seq].oracle_plan_rows[d2.seq].object_owner, dsp.operation = sql_text->qual[
    d1.seq].oracle_plan_rows[d2.seq].operation,
    dsp.optimizer = sql_text->qual[d1.seq].oracle_plan_rows[d2.seq].optimizer, dsp.options = sql_text
    ->qual[d1.seq].oracle_plan_rows[d2.seq].options, dsp.other = sql_text->qual[d1.seq].
    oracle_plan_rows[d2.seq].other,
    dsp.other_tag = sql_text->qual[d1.seq].oracle_plan_rows[d2.seq].other_tag, dsp.parent_id =
    sql_text->qual[d1.seq].oracle_plan_rows[d2.seq].parent_id, dsp.position = sql_text->qual[d1.seq].
    oracle_plan_rows[d2.seq].position,
    dsp.search_columns = sql_text->qual[d1.seq].oracle_plan_rows[d2.seq].search_columns
   PLAN (d1
    WHERE maxrec(d2,size(sql_text->qual[d1.seq].oracle_plan_rows,5))
     AND (sql_text->qual[d1.seq].plan_in_oracle_ind=1))
    JOIN (d2)
    JOIN (dsp)
   WITH nocounter
  ;end insert
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  COMMIT
 ENDIF
 SET dm_err->eproc = "Generating explain plans for remaining statements (errors are normal)"
 CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
 FOR (cntx = 1 TO sql_text->text_cnt)
   IF ((sql_text->qual[cntx].stmt_flag != 1)
    AND (sql_text->qual[cntx].plan_in_oracle_ind=0))
    CALL dgui_short_stmts(sql_text->qual[cntx].stmt)
    SET file_name = concat(trim(stmt->qual[cntx].stmt_id,3),".sql")
    IF (size(dgui_short_stmts->qual,5) > 0)
     SET dm_err->eproc = "Writing to file for explain plan to be made."
     SELECT INTO value(file_name)
      FROM (dummyt d  WITH seq = value(size(dgui_short_stmts->qual,5)))
      HEAD REPORT
       col 0, "EXPLAIN PLAN SET STATEMENT_ID = '", stmt->qual[cntx].stmt_id,
       "' INTO DM_SQL_PLAN FOR ", row + 1
      DETAIL
       col 0, dgui_short_stmts->qual[d.seq].stmt, row + 1
      FOOT REPORT
       col 0, ";", row + 1,
       col 0, "COMMIT;", row + 1,
       row + 1
      WITH nocounter, maxcol = 135
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_script
     ENDIF
     IF (dm2_push_cmd(concat('rdb read "',trim(file_name,3),'" end go'),1)=0)
      SET sql_text->qual[cntx].flag = 1
      SET dm_err->err_ind = 0
     ENDIF
     SET stat = remove(file_name)
     SET stat = alterlist(errors->list,cntx)
     SET errors->list[cntx].err_msg = dm_err->emsg
    ENDIF
   ENDIF
 ENDFOR
 FREE SET ind_rec
 RECORD ind_rec(
   1 ind_cnt = i4
   1 qual[*]
     2 index_name = vc
     2 column_str = vc
 )
 SET dm_err->eproc = "Gathering index columns for index names on dm_sql_plan"
 CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
 SELECT DISTINCT INTO "nl:"
  uic.index_name, uic.column_name, uic.column_position
  FROM dm_sql_plan dsp,
   user_ind_columns uic
  WHERE "INDEX"=dsp.operation
   AND dsp.index_columns = null
   AND "V500"=dsp.object_owner
   AND uic.index_name=dsp.object_name
  ORDER BY dsp.object_name, uic.column_position
  HEAD REPORT
   ind_rec->ind_cnt = 0, i = 0
  HEAD dsp.object_name
   ind_rec->ind_cnt = (ind_rec->ind_cnt+ 1), stat = alterlist(ind_rec->qual,ind_rec->ind_cnt),
   ind_rec->qual[ind_rec->ind_cnt].index_name = dsp.object_name,
   ind_rec->qual[ind_rec->ind_cnt].column_str = "", i = 0
  DETAIL
   i = (i+ 1)
   IF (i > 1)
    ind_rec->qual[ind_rec->ind_cnt].column_str = build(ind_rec->qual[ind_rec->ind_cnt].column_str,
     ", ",uic.column_name)
   ELSE
    ind_rec->qual[ind_rec->ind_cnt].column_str = uic.column_name
   ENDIF
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF ((ind_rec->ind_cnt > 0))
  SET dm_err->eproc = "Updating index_columns on dm_sql_plan"
  CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
  UPDATE  FROM dm_sql_plan dsp,
    (dummyt d2  WITH seq = value(ind_rec->ind_cnt))
   SET dsp.index_columns = ind_rec->qual[d2.seq].column_str
   PLAN (d2)
    JOIN (dsp
    WHERE (dsp.object_name=ind_rec->qual[d2.seq].index_name)
     AND "INDEX"=dsp.operation)
   WITH nocounter
  ;end update
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
 ENDIF
 COMMIT
 SET num_id = size(stmt->qual,5)
 SET cnt_p = 0
 IF (dm2_active_instance_count(ds_active_inst_cnt)=0)
  GO TO exit_script
 ENDIF
 IF (num_id > 0)
  SET dm_err->eproc = "Creating report"
  CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
  SELECT INTO "mine"
   FROM dm_sql_plan p,
    (dummyt d  WITH seq = value(num_id))
   PLAN (d)
    JOIN (p
    WHERE (p.statement_id=stmt->qual[d.seq].stmt_id)
     AND " " < trim(p.operation,3))
   ORDER BY d.seq, p.statement_id, p.id,
    p.parent_id, p.object_name
   HEAD REPORT
    cnt_p = (cnt_p+ 1)
    IF ((sql_text->qual[1].cpu_time > - (1)))
     line = fillstring(266,"="), line1 = fillstring(266,"-"), line2 = fillstring(266,"*")
    ELSE
     line = fillstring(250,"="), line1 = fillstring(250,"-"), line2 = fillstring(250,"*")
    ENDIF
    CALL center(concat("DM SQLPLAN OUTPUT (ver: ",ms_sqlplan_version,")"),1,140), row + 1,
    CALL center(concat("Oracle Version: ",dm2_rdbms_version->version),1,140),
    row + 1, row + 1, col 56,
    "Report Time: ", col + 1,
    CALL print(format(cnvtdatetime(curdate,curtime3),"MM/DD/YYYY HH:MM;;Q"))
    IF (ds_active_inst_cnt > 1)
     row + 1, col 0,
     "Note:  For RAC configurations, a SQL statement can be present multiple times in this report."
    ENDIF
   HEAD d.seq
    row + 1, col 0, line,
    row + 1, row + 1
    IF ((((sql_text->qual[d.seq].flag=1)) OR ((sql_text->qual[d.seq].stmt_flag=1))) )
     CALL center(
     "***** An Oracle execution plan could not be obtained for the following SQL statement. *****",0,
     100)
    ELSE
     col 0, "Plan statement for: ", p.statement_id,
     col 35, "Hash Value: ", sql_text->qual[d.seq].hash_value
     IF (ds_active_inst_cnt > 1
      AND assign(ds_search,locateval(ds_search,1,instance_list->cnt,sql_text->qual[d.seq].inst_id,
       instance_list->qual[ds_search].inst_id)) > 0)
      col 65, "Instance Name: ", instance_list->qual[ds_search].inst_name,
      col 100, "Host Name: ", instance_list->qual[ds_search].host_name
     ENDIF
    ENDIF
    row + 1, row + 1
    FOR (i = 0 TO floor((textlen(sql_text->qual[d.seq].stmt)/ 125.0)))
     CALL print(substring(((i * 125)+ 1),125,sql_text->qual[d.seq].stmt)),row + 1
    ENDFOR
    CALL center("Statistics",1,140), row + 1, col 0,
    line1, row + 1, col 0,
    "Buffer Gets: ", col 30, "Executions: ",
    col 60, "Buffer Ratio: ", col 87,
    "Disk Reads: ", col 111, "Disk Ratio: ",
    col 134, "First Load Time:", col 169,
    "Score: ", col 190, "Hash Value: ",
    col 208, "Sharable Mem: ", col 225,
    "Optimizer Mode: "
    IF ((sql_text->qual[d.seq].cpu_time > - (1)))
     col 252, "CPU Time(sec): "
    ENDIF
    row + 1, col 0, line1,
    row + 1, col 0, sql_text->qual[d.seq].buff,
    col 27, sql_text->qual[d.seq].exec, col 55,
    sql_text->qual[d.seq].rat, col 85, sql_text->qual[d.seq].disk,
    col 109, sql_text->qual[d.seq].drat, col 134,
    sql_text->qual[d.seq].first_time, col 164, sql_text->qual[d.seq].score,
    col 190, sql_text->qual[d.seq].hash_value, col 207,
    sql_text->qual[d.seq].sharable_mem, col 225, sql_text->qual[d.seq].optimizer_mode
    IF ((sql_text->qual[d.seq].cpu_time > - (1)))
     col 252,
     CALL print((sql_text->qual[d.seq].cpu_time/ 1000000))
    ENDIF
    row + 1
    IF ((((sql_text->qual[d.seq].flag=1)) OR ((sql_text->qual[d.seq].stmt_flag=1))) )
     row + 1, line1
     IF ((sql_text->qual[d.seq].flag=1))
      row + 1, col 8, "Error: ",
      errors->list[d.seq].err_msg
     ELSE
      row + 1, col 8, "Error: Could not grab the full sqltext, thus unable to obtain a plan"
     ENDIF
     row + 1, line, row + 1
    ELSE
     row + 1, row + 1,
     CALL center("SQL Plan Info",1,140),
     row + 1, col 0, line1,
     row + 1, col 0, "Operation",
     col 31, "Options", col 62,
     "Object Name", col 93, "Index Columns",
     row + 1, col 0, line1,
     row + 1
    ENDIF
   DETAIL
    p.operation, col + 1, p.options,
    col + 1, p.object_name, col + 1,
    CALL print(trim(p.index_columns,3)), row + 1
   WITH outerjoin = d, maxcol = 270, formfeed = none,
    nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
 ENDIF
 SUBROUTINE delim_check(sbr_vc_string)
   DECLARE delim_loop = i4
   DECLARE dtick_cnt = i4
   DECLARE tick_cnt = i4
   DECLARE carrot_cnt = i4
   DECLARE delim_cnt = i4
   DECLARE high_val = i4 WITH constant(135)
   SET delim_cnt = 0
   SET delim_loop = 2
   WHILE (delim_loop=2)
     SET dtick_cnt = 0
     SET tick_cnt = 0
     SET carrot_cnt = 0
     SET dtick_cnt = findstring('"',sbr_vc_string,(delim_cnt+ 1),0)
     SET tick_cnt = findstring("'",sbr_vc_string,(delim_cnt+ 1),0)
     SET carrot_cnt = findstring("^",sbr_vc_string,(delim_cnt+ 1),0)
     IF (dtick_cnt=0)
      SET dtick_cnt = high_val
     ENDIF
     IF (tick_cnt=0)
      SET tick_cnt = high_val
     ENDIF
     IF (carrot_cnt=0)
      SET carrot_cnt = high_val
     ENDIF
     SET delim_cnt = minval(dtick_cnt,tick_cnt,carrot_cnt)
     IF (delim_cnt=high_val)
      SET delim_loop = 0
     ELSE
      SET delim_cnt = findstring(substring(delim_cnt,1,sbr_vc_string),sbr_vc_string,(delim_cnt+ 1),0)
      IF (delim_cnt=0)
       SET delim_loop = 1
      ENDIF
     ENDIF
   ENDWHILE
   RETURN(delim_loop)
 END ;Subroutine
 SUBROUTINE dgui_short_stmts(sbr_text)
   DECLARE pnt = i4
   DECLARE text_str = vc
   DECLARE seg_cnt = i4
   DECLARE dgui_done = i2
   DECLARE str_len = i4
   DECLARE delim_check_ind = i2
   SET str_len = 110
   SET text_str = sbr_text
   SET seg_cnt = 0
   SET stat = alterlist(dgui_short_stmts->qual,0)
   IF (size(text_str) > 125)
    SET dgui_done = 0
    WHILE (dgui_done != 1)
      SET pnt = 0
      SET pnt = findstring(" ",text_str,str_len,0)
      IF (((pnt=0) OR (pnt > 132)) )
       SET pnt = findstring(",",text_str,str_len,0)
      ENDIF
      IF (pnt > 0
       AND pnt <= 132)
       SET delim_check_ind = delim_check(substring(1,pnt,text_str))
       IF (delim_check_ind=1)
        SET str_len = (str_len - 10)
       ELSE
        SET seg_cnt = (seg_cnt+ 1)
        SET stat = alterlist(dgui_short_stmts->qual,seg_cnt)
        SET dgui_short_stmts->qual[seg_cnt].stmt = trim(substring(1,pnt,text_str))
        SET text_str = substring((pnt+ 1),size(text_str),text_str)
        SET str_len = 110
        IF (size(text_str) <= 110)
         SET seg_cnt = (seg_cnt+ 1)
         SET stat = alterlist(dgui_short_stmts->qual,seg_cnt)
         SET dgui_short_stmts->qual[seg_cnt].stmt = text_str
         SET dgui_done = 1
        ENDIF
       ENDIF
      ELSE
       SET str_len = (str_len - 10)
      ENDIF
      IF (str_len < 10)
       SET stat = alterlist(dgui_short_stmts->qual,1)
       SET dgui_short_stmts->qual[1].stmt = "ERROR"
       SET dgui_done = 1
      ENDIF
    ENDWHILE
   ELSE
    SET seg_cnt = (seg_cnt+ 1)
    SET stat = alterlist(dgui_short_stmts->qual,seg_cnt)
    SET dgui_short_stmts->qual[seg_cnt].stmt = text_str
   ENDIF
   RETURN(null)
 END ;Subroutine
#exit_script
 IF (size(stmt->qual,5) > 0)
  SET dm_err->eproc = "Deleting dm_sql_plan data"
  CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
  IF (mn_can_use_expand=1)
   SET ml_cur_list_size = size(stmt->qual,5)
   SET ml_num_loops = ceil((cnvtreal(ml_cur_list_size)/ mn_batch_size))
   SET ml_new_list_size = (ml_num_loops * mn_batch_size)
   SET stat = alterlist(stmt->qual,ml_new_list_size)
   FOR (ml_loop_cnt = (ml_cur_list_size+ 1) TO ml_new_list_size)
     SET stmt->qual[ml_loop_cnt].stmt_id = stmt->qual[ml_cur_list_size].stmt_id
   ENDFOR
   SET ml_start_val = 1
   SET dm_err->eproc = "Deleting generated rows from dm_sql_plan by statement_id for CCL >= 8.2.03"
   DELETE  FROM dm_sql_plan ds,
     (dummyt d  WITH seq = value(ml_num_loops))
    SET ds.seq = 1
    PLAN (d
     WHERE initarray(ml_start_val,evaluate(d.seq,1,1,(ml_start_val+ mn_batch_size))))
     JOIN (ds
     WHERE expand(ml_expand_num,ml_start_val,(ml_start_val+ (mn_batch_size - 1)),ds.statement_id,stmt
      ->qual[ml_expand_num].stmt_id))
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
   ENDIF
   COMMIT
  ELSE
   SET dm_err->eproc = "Deleting generated rows from dm_sql_plan by statement_id for CCL < 8.2.03"
   DELETE  FROM dm_sql_plan ds,
     (dummyt d  WITH seq = value(size(stmt->qual,5)))
    SET ds.seq = 1
    PLAN (d)
     JOIN (ds
     WHERE (ds.statement_id=stmt->qual[d.seq].stmt_id))
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
   ENDIF
   COMMIT
  ENDIF
 ENDIF
 IF (dm2_push_cmd(concat("rdb alter session set optimizer_mode = ",dcr_optvalues->session_opt_mode,
   " go"),1)=0)
  GO TO exit_script
 ENDIF
 COMMIT
 IF ((dm_err->err_ind=0))
  SET dm_err->eproc = "Ending DM_SQLPLAN"
  CALL final_disp_msg("dm_sqlplan")
  SET stat = remove(dm_err->logfile)
 ENDIF
END GO
