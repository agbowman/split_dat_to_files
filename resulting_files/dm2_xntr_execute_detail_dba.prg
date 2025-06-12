CREATE PROGRAM dm2_xntr_execute_detail:dba
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
 DECLARE dxrc_update_detail(dud_xntr_detail_id=f8,dud_xntr_status=vc,dud_commit_ind=i2) = i2
 DECLARE dxrc_rollback_extract(dre_extract_id=f8,dre_detail_id=f8,dre_commit_ind=i2) = i2
 DECLARE dxrc_update_job(duj_job_id=f8,duj_status=vc,duj_status_msg=vc,duj_commit_ind=i2) = i2
 DECLARE dxrc_update_extract(due_extract_id=f8,due_status=vc,due_status_msg=vc,due_commit_ind=i2) =
 i2
 DECLARE dxrc_check_stop_time(dcst_start_time=f8) = i2
 DECLARE dxrc_requeue_errors(dre_job_error_id=f8,dre_extract_error_id=f8) = i2
 SUBROUTINE dxrc_update_detail(dud_xntr_detail_id,dud_xntr_status,dud_commit_ind)
   DECLARE dud_prev_err_ind = i2 WITH protect, noconstant
   SET dud_xntr_status = cnvtupper(dud_xntr_status)
   SET dud_prev_err_ind = dm_err->err_ind
   SET dm_err->err_ind = 0
   IF (dud_xntr_status IN ("ERROR", "FINISHED"))
    UPDATE  FROM dm_xntr_detail d
     SET d.status = dud_xntr_status, d.status_msg = evaluate(dud_xntr_status,"FINISHED",
       "Detail work completed successfully","ERROR",dm_err->emsg), d.end_dt_tm = cnvtdatetime(curdate,
       curtime3),
      d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_applctx = reqinfo->updt_applctx, d
      .updt_task = reqinfo->updt_task,
      d.updt_cnt = (d.updt_cnt+ 1), d.updt_id = reqinfo->updt_id
     WHERE d.dm_xntr_detail_id=dud_xntr_detail_id
     WITH nocounter
    ;end update
   ELSEIF (dud_xntr_status="RUNNING")
    UPDATE  FROM dm_xntr_detail d
     SET d.status = dud_xntr_status, d.start_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      d.updt_applctx = reqinfo->updt_applctx, d.updt_task = reqinfo->updt_task, d.updt_cnt = (d
      .updt_cnt+ 1),
      d.updt_id = reqinfo->updt_id
     WHERE d.dm_xntr_detail_id=dud_xntr_detail_id
     WITH nocounter
    ;end update
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->emsg = build("Invalid status passed into DXRC_UPDATE_DETAIL: ",dud_xntr_status)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   IF (check_error("Updating DM_XNTR_DETAIL") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(1)
   ELSE
    SET dm_err->err_ind = dud_prev_err_ind
   ENDIF
   IF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = build("No row found in DM_XNTR_DETAIL for ID: ",dud_xntr_detail_id)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   IF (dud_commit_ind=1)
    COMMIT
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dxrc_rollback_extract(dre_extract_id,dre_detail_id,dre_commit_ind)
   DECLARE dre_tab_loop = i4 WITH protect, noconstant(0)
   DECLARE dre_msg = vc WITH protect, noconstant("")
   DECLARE dre_mismatch_cnt = i4 WITH protect, noconstant(0)
   DECLARE dre_orig_e_ind = i4 WITH protect, noconstant(0)
   DECLARE dre_err_msg = vc WITH protect, noconstant(" ")
   FREE RECORD dre_tab_list
   RECORD dre_tab_list(
     1 table_cnt = i4
     1 table_qual[*]
       2 table_name = vc
       2 delete_cnt = i4
   )
   ROLLBACK
   SET dre_orig_e_ind = dm_err->err_ind
   SET dm_err->err_ind = 0
   SET dre_msg = dm_err->emsg
   SELECT INTO "NL:"
    FROM dm_xntr_extract d
    WHERE d.dm_xntr_extract_id=dre_extract_id
    WITH nocounter
   ;end select
   IF (check_error("Validating DM_XNTR_EXTRACT_ID") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   IF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = build("No row found in DM_XNTR_EXTRACT for ID: ",dre_extract_id)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   IF (dre_detail_id > 0)
    SET dm_err->emsg = dre_msg
    IF (dxrc_update_detail(dre_detail_id,"ERROR",dre_commit_ind)=1)
     RETURN(1)
    ENDIF
   ENDIF
   SELECT DISTINCT INTO "NL:"
    d.table_name
    FROM dm_xntr_extract_row_data d
    WHERE d.extract_id=dre_extract_id
    DETAIL
     dre_tab_list->table_cnt = (dre_tab_list->table_cnt+ 1), stat = alterlist(dre_tab_list->
      table_qual,dre_tab_list->table_cnt), dre_tab_list->table_qual[dre_tab_list->table_cnt].
     table_name = d.table_name
    WITH nocounter
   ;end select
   IF (check_error("Gathering table names from DM_XNTR_EXTRACT_ROW_DATA") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   IF ((dre_tab_list->table_cnt > 0))
    FOR (dre_tab_loop = 1 TO dre_tab_list->table_cnt)
      DELETE  FROM (parser(dre_tab_list->table_qual[dre_tab_loop].table_name) d)
       WHERE d.rowid IN (
       (SELECT
        d1.new_rowid
        FROM dm_xntr_extract_row_data d1
        WHERE d1.extract_id=dre_extract_id
         AND (d1.table_name=dre_tab_list->table_qual[dre_tab_loop].table_name)))
       WITH nocounter
      ;end delete
      IF (check_error(build("Deleting data from ",dre_tab_list->table_qual[dre_tab_loop].table_name))
       != 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN(1)
      ENDIF
      SET dre_tab_list->table_qual[dre_tab_loop].delete_cnt = curqual
      UPDATE  FROM dm_xntr_extract_cnt d
       SET d.deleted_row_cnt = dre_tab_list->table_qual[dre_tab_loop].delete_cnt, d.updt_cnt = (d
        .updt_cnt+ 1), d.updt_applctx = reqinfo->updt_applctx,
        d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task, d.updt_dt_tm = cnvtdatetime(
         curdate,curtime3)
       WHERE dm_xntr_extract_id=dre_extract_id
        AND (retrieved_row_cnt=dre_tab_list->table_qual[dre_tab_loop].delete_cnt)
        AND (table_name=dre_tab_list->table_qual[dre_tab_loop].table_name)
       WITH nocounter
      ;end update
      IF (check_error("Recording delete in DM_XNTR_EXTRACT_CNT") != 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN(1)
      ENDIF
      IF (curqual=0)
       SET dm_err->err_ind = 1
       SET dm_err->emsg = "Could not update the DM_XNTR_EXTRACT_CNT table"
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN(1)
      ENDIF
    ENDFOR
    SELECT INTO "NL:"
     cnt = count(*)
     FROM dm_xntr_extract_cnt d
     WHERE d.dm_xntr_extract_id=dre_extract_id
      AND d.deleted_row_cnt != d.retrieved_row_cnt
     DETAIL
      dre_mismatch_cnt = cnt
     WITH nocounter
    ;end select
    IF (check_error("Looking for mismatched rows in DM_XNTR_EXTRACT_CNT") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(1)
    ENDIF
    IF (dre_mismatch_cnt > 0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "There were inserts reported in DM_XNTR_EXTRACT_CNT that weren't deleted."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(1)
    ENDIF
   ENDIF
   SET dre_err_msg = evaluate(dre_detail_id,0.0,dre_msg,concat(
     "An error occured during the transform: ",trim(cnvtstring(dre_detail_id,20),3)))
   IF (dxrc_update_extract(dre_extract_id,"ERROR",dre_err_msg,dre_commit_ind) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Deleting rows that were rolled back from dm_xntr_extract_row_data."
   DELETE  FROM dm_xntr_extract_row_data d
    WHERE d.extract_id=dre_extract_id
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(1)
   ENDIF
   IF (dre_commit_ind=1)
    COMMIT
   ENDIF
   SET dm_err->err_ind = dre_orig_e_ind
   SET dm_err->emsg = dre_msg
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dxrc_update_job(duj_job_id,duj_status,duj_status_msg,duj_commit_ind)
   DECLARE duj_prev_err_ind = i2 WITH protect, noconstant
   SET duj_status = cnvtupper(duj_status)
   SET duj_prev_err_ind = dm_err->err_ind
   SET dm_err->err_ind = 0
   IF (duj_status IN ("ERROR", "FINISHED"))
    UPDATE  FROM dm_xntr_job d
     SET d.status = duj_status, d.status_msg = duj_status_msg, d.job_end_dt_tm = cnvtdatetime(curdate,
       curtime3),
      d.audit_sid = null, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_applctx = reqinfo->
      updt_applctx,
      d.updt_task = reqinfo->updt_task, d.updt_cnt = (d.updt_cnt+ 1), d.updt_id = reqinfo->updt_id
     WHERE d.dm_xntr_job_id=duj_job_id
     WITH nocounter
    ;end update
   ELSEIF (duj_status="RUNNING")
    UPDATE  FROM dm_xntr_job d
     SET d.status = duj_status, d.status_msg = null, d.job_start_dt_tm = cnvtdatetime(curdate,
       curtime3),
      d.audit_sid = currdbhandle, d.log_file = dm_err->logfile, d.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      d.updt_applctx = reqinfo->updt_applctx, d.updt_task = reqinfo->updt_task, d.updt_cnt = (d
      .updt_cnt+ 1),
      d.updt_id = reqinfo->updt_id
     WHERE d.dm_xntr_job_id=duj_job_id
     WITH nocounter
    ;end update
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->emsg = build("Invalid status passed into DXRC_UPDATE_JOB: ",duj_status)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   IF (check_error("Updating DM_XNTR_JOB") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(1)
   ELSE
    SET dm_err->err_ind = duj_prev_err_ind
   ENDIF
   IF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = build("No row found in DM_XNTR_JOB for ID: ",duj_job_id)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   IF (duj_commit_ind=1)
    COMMIT
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dxrc_update_extract(due_extract_id,due_status,due_status_msg,due_commit_ind)
   DECLARE due_prev_err_ind = i2 WITH protect, noconstant
   FREE RECORD due_stmt
   RECORD due_stmt(
     1 stmt[*]
       2 str = vc
   )
   SET due_status = cnvtupper(due_status)
   SET due_prev_err_ind = dm_err->err_ind
   SET dm_err->err_ind = 0
   IF (due_status IN ("ERROR", "FINISHED"))
    UPDATE  FROM dm_xntr_extract d
     SET d.status = due_status, d.status_msg = due_status_msg, d.extract_stop_dt_tm = cnvtdatetime(
       curdate,curtime3),
      d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_applctx = reqinfo->updt_applctx, d
      .updt_task = reqinfo->updt_task,
      d.updt_cnt = (d.updt_cnt+ 1), d.updt_id = reqinfo->updt_id
     WHERE d.dm_xntr_extract_id=due_extract_id
     WITH nocounter
    ;end update
   ELSEIF (due_status="RETRIEVE")
    UPDATE  FROM dm_xntr_extract d
     SET d.status = due_status, d.status_msg = null, d.extract_start_dt_tm = cnvtdatetime(curdate,
       curtime3),
      d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_applctx = reqinfo->updt_applctx, d
      .updt_task = reqinfo->updt_task,
      d.updt_cnt = (d.updt_cnt+ 1), d.updt_id = reqinfo->updt_id
     WHERE d.dm_xntr_extract_id=due_extract_id
     WITH nocounter
    ;end update
   ELSEIF (due_status IN ("PARSE", "INSERT", "SYNCHRONIZE"))
    SET stat = alterlist(due_stmt->stmt,1)
    SET due_stmt->stmt[1].str = concat("rdb asis(^ BEGIN XNTR_UPDATE_EXTRACT_AUTON('",due_status,
     "','",due_status_msg,"',",
     trim(cnvtstring(due_extract_id,20),3),",'",format(cnvtdatetime(curdate,curtime3),";;q"),
     "'); END; ^) go")
    EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","DUE_STMT")
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->emsg = build("Invalid status passed into DXRC_UPDATE_EXTRACT: ",due_status)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   IF (check_error("Updating DM_XNTR_EXTRACT") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(1)
   ELSE
    SET dm_err->err_ind = due_prev_err_ind
   ENDIF
   IF (due_commit_ind=1)
    COMMIT
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dxrc_check_stop_time(dcst_start_time)
   DECLARE dcst_stop_ind = i2 WITH protect, noconstant(0)
   SELECT INTO "NL:"
    cnt = count(*)
    FROM dm_info d
    WHERE d.info_domain="DATA MANAGEMENT"
     AND d.info_name="XNTR STOP TIME"
     AND d.info_date > cnvtdatetime(dcst_start_time)
    DETAIL
     dcst_stop_ind = cnt
    WITH nocounter
   ;end select
   IF (check_error("Checking Stop Time") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   RETURN(dcst_stop_ind)
 END ;Subroutine
 SUBROUTINE dxrc_requeue_errors(dre_job_error_id,dre_extract_error_id)
   FREE RECORD dre_requeue
   RECORD dre_requeue(
     1 cnt = i4
     1 qual[*]
       2 job_id = f8
   )
   DECLARE dre_loop = i4 WITH protect, noconstant(0)
   IF (dre_job_error_id=0.0
    AND dre_extract_error_id=0.0)
    SELECT INTO "NL:"
     FROM dm_xntr_job d
     WHERE d.status="ERROR"
     DETAIL
      dre_requeue->cnt = (dre_requeue->cnt+ 1), stat = alterlist(dre_requeue->qual,dre_requeue->cnt),
      dre_requeue->qual[dre_requeue->cnt].job_id = d.dm_xntr_job_id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
   ELSEIF (dre_job_error_id > 0.0)
    SET stat = alterlist(dre_requeue->qual,1)
    SET dre_requeue->cnt = 1
    SET dre_requeue->qual[1].job_id = dre_job_error_id
   ELSEIF (dre_extract_error_id > 0.0)
    SELECT INTO "NL:"
     FROM dm_xntr_job d
     WHERE d.status="ERROR"
      AND d.dm_xntr_job_id IN (
     (SELECT
      dm_xntr_job_id
      FROM dm_xntr_extract
      WHERE dm_xntr_extract_id=dre_extract_error_id))
     DETAIL
      dre_requeue->cnt = (dre_requeue->cnt+ 1), stat = alterlist(dre_requeue->qual,dre_requeue->cnt),
      dre_requeue->qual[dre_requeue->cnt].job_id = d.dm_xntr_job_id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
   ENDIF
   IF ((dre_requeue->cnt=0))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Could not identify any errors"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   DELETE  FROM dm_xntr_detail d
    WHERE d.dm_xntr_extract_id IN (
    (SELECT
     e.dm_xntr_extract_id
     FROM dm_xntr_extract e
     WHERE expand(dre_loop,1,dre_requeue->cnt,e.dm_xntr_job_id,dre_requeue->qual[dre_loop].job_id)
      AND e.status != "FINISHED"))
    WITH nocounter, expand = 1
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   DELETE  FROM dm_xntr_extract_cnt d
    WHERE d.dm_xntr_extract_id IN (
    (SELECT
     e.dm_xntr_extract_id
     FROM dm_xntr_extract e
     WHERE expand(dre_loop,1,dre_requeue->cnt,e.dm_xntr_job_id,dre_requeue->qual[dre_loop].job_id)
      AND e.status != "FINISHED"))
    WITH nocounter, expand = 1
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   DELETE  FROM dm_xntr_extract d
    WHERE expand(dre_loop,1,dre_requeue->cnt,d.dm_xntr_job_id,dre_requeue->qual[dre_loop].job_id)
     AND d.status != "FINISHED"
    WITH nocounter, expand = 1
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   UPDATE  FROM dm_xntr_job j
    SET j.status = "QUEUED", j.status_msg = null, j.audit_sid = null,
     j.job_start_dt_tm = null, j.job_end_dt_tm = null, j.log_file = null,
     j.updt_id = reqinfo->updt_id, j.updt_cnt = (j.updt_cnt+ 1), j.updt_applctx = reqinfo->
     updt_applctx,
     j.updt_task = reqinfo->updt_task, j.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE expand(dre_loop,1,dre_requeue->cnt,j.dm_xntr_job_id,dre_requeue->qual[dre_loop].job_id)
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   COMMIT
   RETURN(0)
 END ;Subroutine
 IF (validate(request->transaction_type,"ABCDEFGH")="ABCDEFGH"
  AND validate(request->transaction_type,"HGFEDCBA")="HGFEDCBA")
  FREE SET request
  RECORD request(
    1 parent_table = c50
    1 cmb_mode = c20
    1 error_message = c132
    1 transaction_type = c8
    1 reverse_cmb_ind = i2
    1 xxx_combine[*]
      2 xxx_combine_id = f8
      2 from_xxx_id = f8
      2 from_mrn = c200
      2 from_alias_pool_cd = f8
      2 from_alias_type_cd = f8
      2 to_xxx_id = f8
      2 to_mrn = c200
      2 to_alias_pool_cd = f8
      2 to_alias_type_cd = f8
      2 encntr_id = f8
      2 application_flag = i2
      2 combine_weight = f8
    1 xxx_combine_det[*]
      2 xxx_combine_det_id = f8
      2 xxx_combine_id = f8
      2 entity_name = c32
      2 entity_id = f8
      2 entity_pk[*]
        3 col_name = c30
        3 data_type = c30
        3 data_char = c100
        3 data_number = f8
        3 data_date = dq8
      2 combine_action_cd = f8
      2 attribute_name = c32
      2 prev_active_ind = i2
      2 prev_active_status_cd = f8
      2 prev_end_eff_dt_tm = dq8
      2 combine_desc_cd = f8
      2 to_record_ind = i2
  )
 ENDIF
 IF (validate(reply->status_data.status,"A")="A"
  AND validate(reply->status_data.status,"H")="H")
  FREE SET reply
  RECORD reply(
    1 xxx_combine_id[*]
      2 combine_id = f8
      2 parent_table = c50
      2 from_xxx_id = f8
      2 to_xxx_id = f8
      2 encntr_id = f8
    1 error[*]
      2 create_dt_tm = dq8
      2 parent_table = c50
      2 from_id = f8
      2 to_id = f8
      2 encntr_id = f8
      2 error_table = c32
      2 error_type = vc
      2 error_msg = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 DECLARE prep_rcb_request(rcb_cmb_type=vc,rcb_cmb_from_id=f8,rcb_cmb_to_id=f8,rcb_cmb_encntr_id=f8,
  rcb_cmb_table_id=f8) = null
 SUBROUTINE prep_rcb_request(rcb_cmb_type,rcb_cmb_from_id,rcb_cmb_to_id,rcb_cmb_encntr_id,
  rcb_cmb_table_id)
   DECLARE rcb_cmb_parent = vc WITH protect, noconstant(" ")
   CASE (rcb_cmb_type)
    OF "P":
     SET rcb_cmb_parent = "PERSON"
    OF "E":
     SET rcb_cmb_parent = "ENCOUNTER"
    OF "L":
     SET rcb_cmb_parent = "LOCATION"
    OF "H":
     SET rcb_cmb_parent = "HEALTH_PLAN"
    OF "O":
     SET rcb_cmb_parent = "ORGANIZATION"
    ELSE
     SET rcb_cmb_parent = rcb_cmb_type
   ENDCASE
   SELECT INTO "nl:"
    p.person_id
    FROM prsnl p
    WHERE p.username=curuser
    DETAIL
     reqinfo->updt_id = p.person_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN
   ENDIF
   SET stat = alterlist(request->xxx_combine,1)
   SET request->parent_table = rcb_cmb_parent
   SET request->cmb_mode = "RE-CMB"
   SET request->transaction_type = curuser
   IF (rcb_cmb_parent="PERSON")
    SELECT INTO "nl:"
     FROM combine_det_value cd,
      person_combine pc
     WHERE pc.person_combine_id=rcb_cmb_table_id
      AND cd.combine_id=pc.person_combine_id
      AND cd.entity_id=pc.to_person_id
      AND cd.entity_name="PERSON"
      AND cd.column_name="PERSON_ID"
      AND cd.combine_parent="PERSON_COMBINE"
     DETAIL
      request->reverse_cmb_ind = 1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN
    ENDIF
   ENDIF
   SET request->xxx_combine[1].from_xxx_id = rcb_cmb_from_id
   SET request->xxx_combine[1].to_xxx_id = rcb_cmb_to_id
   SET request->xxx_combine[1].encntr_id = rcb_cmb_encntr_id
   SET request->xxx_combine[1].application_flag = 5
   SET request->xxx_combine[1].xxx_combine_id = rcb_cmb_table_id
 END ;Subroutine
 IF (validate(request->cmb_mode,"ABCDEFGH")="ABCDEFGH"
  AND validate(request->cmb_mode,"HGFEDCBA")="HGFEDCBA")
  FREE SET request
  RECORD request(
    1 parent_table = c50
    1 cmb_mode = vc
    1 error_message = vc
    1 xxx_uncombine[*]
      2 xxx_combine_id = f8
      2 from_xxx_id = f8
      2 from_mrn = c200
      2 from_alias_pool_cd = f8
      2 from_alias_type_cd = f8
      2 to_xxx_id = f8
      2 to_mrn = c200
      2 to_alias_pool_cd = f8
      2 to_alias_type_cd = f8
      2 encntr_id = f8
      2 application_flag = i2
    1 xxx_combine[*]
      2 xxx_combine_id = f8
      2 from_xxx_id = f8
      2 from_mrn = c200
      2 from_alias_pool_cd = f8
      2 from_alias_type_cd = f8
      2 to_xxx_id = f8
      2 to_mrn = c200
      2 to_alias_pool_cd = f8
      2 to_alias_type_cd = f8
      2 encntr_id = f8
      2 application_flag = i2
      2 combine_weight = f8
    1 xxx_combine_det[*]
      2 xxx_combine_det_id = f8
      2 xxx_combine_id = f8
      2 entity_name = c32
      2 entity_id = f8
      2 entity_pk[*]
        3 col_name = c30
        3 data_type = c30
        3 data_char = c100
        3 data_number = f8
        3 data_date = dq8
      2 combine_action_cd = f8
      2 attribute_name = c32
      2 prev_active_ind = i2
      2 prev_active_status_cd = f8
      2 prev_end_eff_dt_tm = dq8
      2 combine_desc_cd = f8
      2 to_record_ind = i2
    1 transaction_type = c8
  )
 ENDIF
 IF (validate(reply->status_data.status,"A")="A"
  AND validate(reply->status_data.status,"H")="H")
  FREE SET reply
  RECORD reply(
    1 xxx_combine_id[*]
      2 combine_id = f8
      2 parent_table = c50
      2 from_xxx_id = f8
      2 to_xxx_id = f8
      2 encntr_id = f8
    1 error[*]
      2 create_dt_tm = dq8
      2 parent_table = c50
      2 from_id = f8
      2 to_id = f8
      2 encntr_id = f8
      2 error_table = c32
      2 error_type = vc
      2 error_msg = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 DECLARE prep_rub_request(rub_cmb_type=vc,rub_cmb_from_id=f8,rub_cmb_to_id=f8,rub_cmb_encntr_id=f8,
  rub_cmb_table_id=f8) = null
 DECLARE activate_rub_details(rub_cmb_type=vc,rub_cmb_table_id=f8,rub_extract_id=f8) = i4
 SUBROUTINE prep_rub_request(rub_cmb_type,rub_cmb_from_id,rub_cmb_to_id,rub_cmb_encntr_id,
  rub_cmb_table_id)
   DECLARE rub_cmb_parent = vc WITH protect, noconstant(" ")
   CASE (rub_cmb_type)
    OF "P":
     SET rub_cmb_parent = "PERSON"
    OF "E":
     SET rub_cmb_parent = "ENCOUNTER"
    OF "L":
     SET rub_cmb_parent = "LOCATION"
    OF "H":
     SET rub_cmb_parent = "HEALTH_PLAN"
    OF "O":
     SET rub_cmb_parent = "ORGANIZATION"
    ELSE
     SET rub_cmb_parent = rub_cmb_type
   ENDCASE
   SELECT INTO "nl:"
    p.person_id
    FROM prsnl p
    WHERE p.username=curuser
    DETAIL
     reqinfo->updt_id = p.person_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN
   ENDIF
   SET stat = alterlist(request->xxx_uncombine,1)
   SET request->parent_table = rub_cmb_parent
   SET request->cmb_mode = "RE-UCB"
   SET request->transaction_type = curuser
   SET request->xxx_uncombine[1].from_xxx_id = rub_cmb_from_id
   SET request->xxx_uncombine[1].to_xxx_id = rub_cmb_to_id
   SET request->xxx_uncombine[1].encntr_id = rub_cmb_encntr_id
   SET request->xxx_uncombine[1].application_flag = 5
   SET request->xxx_uncombine[1].xxx_combine_id = rub_cmb_table_id
 END ;Subroutine
 SUBROUTINE activate_rub_details(rub_cmb_type,rub_cmb_table_id,rub_extract_id)
   DECLARE rub_cmb_parent = vc WITH protect, noconstant(" ")
   DECLARE rub_activate_cnt = i4 WITH public, noconstant(0)
   DECLARE ruberrmsg = vc WITH protect, noconstant(" ")
   DECLARE ruberrcode = i4 WITH protect, noconstant(0)
   DECLARE norows = i2 WITH protect, noconstant(0)
   CASE (rub_cmb_type)
    OF "P":
     SET rub_cmb_parent = "PERSON"
    OF "E":
     SET rub_cmb_parent = "ENCOUNTER"
    OF "L":
     SET rub_cmb_parent = "LOCATION"
    OF "H":
     SET rub_cmb_parent = "HEALTH_PLAN"
    OF "O":
     SET rub_cmb_parent = "ORGANIZATION"
    ELSE
     SET rub_cmb_parent = rub_cmb_type
   ENDCASE
   FREE RECORD xntr_reucb
   RECORD xntr_reucb(
     1 list[*]
       2 table_name = vc
       2 pk_column = vc
       2 details[*]
         3 ucb_detail_id = f8
         3 entity_id = f8
   )
   FREE RECORD xntr_reucb_activate
   RECORD xntr_reucb_activate(
     1 list[*]
       2 ucb_detail_id = f8
   )
   IF (rub_cmb_parent="PERSON")
    SET dm_err->eproc = "Gathering person_combine_det information."
    SELECT INTO "nl:"
     pcd.entity_name, pcd.person_combine_det_id, pcd.entity_id
     FROM person_combine_det pcd
     WHERE pcd.person_combine_id=rub_cmb_table_id
      AND  EXISTS (
     (SELECT
      1
      FROM dm_xntr_extract_row_data dxerd
      WHERE dxerd.table_name=pcd.entity_name
       AND dxerd.extract_id=rub_extract_id))
     ORDER BY pcd.entity_name, pcd.entity_id
     HEAD REPORT
      tablecnt = 0, rowcnt = 0
     HEAD pcd.entity_name
      tablecnt = (tablecnt+ 1), stat = alterlist(xntr_reucb->list,tablecnt), xntr_reucb->list[
      tablecnt].table_name = pcd.entity_name,
      xntr_reucb->list[tablecnt].pk_column = "NONE", rowcnt = 0
     DETAIL
      rowcnt = (rowcnt+ 1), stat = alterlist(xntr_reucb->list[tablecnt].details,rowcnt), xntr_reucb->
      list[tablecnt].details[rowcnt].ucb_detail_id = pcd.person_combine_det_id,
      xntr_reucb->list[tablecnt].details[rowcnt].entity_id = pcd.entity_id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(1)
    ENDIF
   ELSEIF (rub_cmb_parent="ENCOUNTER")
    SET dm_err->eproc = "Gathering ENCNTR_COMBINE_DET information"
    SELECT INTO "nl:"
     ecd.entity_name, ecd.encntr_combine_det_id, ecd.entity_id
     FROM encntr_combine_det ecd
     WHERE ecd.encntr_combine_id=rub_cmb_table_id
      AND  EXISTS (
     (SELECT
      1
      FROM dm_xntr_extract_row_data dxerd
      WHERE dxerd.table_name=ecd.entity_name
       AND dxerd.extract_id=rub_extract_id))
     ORDER BY ecd.entity_name, ecd.entity_id
     HEAD REPORT
      tablecnt = 0, rowcnt = 0
     HEAD ecd.entity_name
      tablecnt = (tablecnt+ 1), stat = alterlist(xntr_reucb->list,tablecnt), xntr_reucb->list[
      tablecnt].table_name = ecd.entity_name,
      xntr_reucb->list[tablecnt].pk_column = "NONE", rowcnt = 0
     DETAIL
      rowcnt = (rowcnt+ 1), stat = alterlist(xntr_reucb->list[tablecnt].details,rowcnt), xntr_reucb->
      list[tablecnt].details[rowcnt].ucb_detail_id = ecd.encntr_combine_det_id,
      xntr_reucb->list[tablecnt].details[rowcnt].entity_id = ecd.entity_id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(1)
    ENDIF
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->emsg = build2(rub_cmb_parent," combines are not yet supported")
    RETURN(1)
   ENDIF
   IF (size(xntr_reucb->list,5) > 0)
    DECLARE tblfoundcnt = i4 WITH public, noconstant(0)
    SET dm_err->eproc = "Querying for primary_key information from dm_cmb_children"
    SELECT DISTINCT INTO "nl:"
     dcc.child_table, dcc.child_pk
     FROM dm_cmb_children dcc,
      (dummyt d  WITH seq = value(size(xntr_reucb->list,5)))
     PLAN (d)
      JOIN (dcc
      WHERE dcc.parent_table=rub_cmb_parent
       AND (dcc.child_table=xntr_reucb->list[d.seq].table_name))
     DETAIL
      tblfoundcnt = (tblfoundcnt+ 1), xntr_reucb->list[d.seq].pk_column = dcc.child_pk
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(1)
    ENDIF
    IF (tblfoundcnt < size(xntr_reucb->list,5))
     SELECT INTO "nl:"
      uc.table_name, uc.constraint_name, ucc.column_name
      FROM user_cons_columns ucc,
       user_constraints uc,
       (dummyt d  WITH seq = value(size(xntr_reucb->list,5)))
      PLAN (d
       WHERE (xntr_reucb->list[d.seq].pk_column="NONE"))
       JOIN (uc
       WHERE (uc.table_name=xntr_reucb->list[d.seq].table_name)
        AND uc.owner=currdbuser
        AND uc.constraint_type="P")
       JOIN (ucc
       WHERE uc.owner=ucc.owner
        AND uc.constraint_name=ucc.constraint_name
        AND uc.table_name=ucc.table_name
        AND ucc.position=1
        AND  NOT ( EXISTS (
       (SELECT
        "x"
        FROM user_cons_columns ucc2
        WHERE ucc2.constraint_name=ucc.constraint_name
         AND ucc2.table_name=ucc.table_name
         AND ucc2.position=2)))
        AND  EXISTS (
       (SELECT
        "x"
        FROM user_tab_columns utc
        WHERE utc.table_name=ucc.table_name
         AND utc.column_name=ucc.column_name
         AND utc.data_type IN ("NUMBER", "FLOAT"))))
      DETAIL
       xntr_reucb->list[d.seq].pk_column = ucc.column_name
      WITH nocounter
     ;end select
    ENDIF
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(1)
    ENDIF
    FOR (i = 1 TO size(xntr_reucb->list,5))
     SELECT INTO "nl:"
      key_value = parser(concat("live_tbl.",xntr_reucb->list[i].pk_column))
      FROM (value(xntr_reucb->list[i].table_name) live_tbl)
      WHERE live_tbl.rowid IN (
      (SELECT
       dxerd.new_rowid
       FROM dm_xntr_extract_row_data dxerd
       WHERE (dxerd.table_name=xntr_reucb->list[i].table_name)
        AND dxerd.extract_id=rub_extract_id))
      DETAIL
       j = - (1), findpos = - (1), findpos = locateval(j,1,size(xntr_reucb->list[i].details,5),
        key_value,xntr_reucb->list[i].details[j].entity_id)
       IF (findpos > 0)
        rub_activate_cnt = (rub_activate_cnt+ 1), stat = alterlist(xntr_reucb_activate->list,
         rub_activate_cnt), xntr_reucb_activate->list[rub_activate_cnt].ucb_detail_id = xntr_reucb->
        list[i].details[findpos].ucb_detail_id
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(1)
     ENDIF
    ENDFOR
    IF (rub_activate_cnt > 0)
     IF (rub_cmb_parent="PERSON")
      UPDATE  FROM person_combine_det pcd,
        (dummyt d  WITH seq = value(size(xntr_reucb_activate->list,5)))
       SET pcd.active_ind = 1
       PLAN (d)
        JOIN (pcd
        WHERE (pcd.person_combine_det_id=xntr_reucb_activate->list[d.seq].ucb_detail_id))
       WITH nocounter
      ;end update
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       ROLLBACK
       RETURN(1)
      ENDIF
     ELSE
      UPDATE  FROM encntr_combine_det ecd,
        (dummyt d  WITH seq = value(size(xntr_reucb_activate->list,5)))
       SET ecd.active_ind = 1
       PLAN (d)
        JOIN (ecd
        WHERE (ecd.encntr_combine_det_id=xntr_reucb_activate->list[d.seq].ucb_detail_id))
       WITH nocounter
      ;end update
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       ROLLBACK
       RETURN(1)
      ENDIF
     ENDIF
    ELSE
     SET norows = 1
    ENDIF
   ELSE
    SET norows = 1
   ENDIF
   IF (rub_cmb_parent="PERSON")
    DECLARE prsnl_ucb_id = f8 WITH public, noconstant(0.0)
    DECLARE iloop = i4 WITH public, noconstant(0)
    DECLARE jloop = i4 WITH public, noconstant(0)
    DECLARE kloop = i4 WITH public, noconstant(0)
    DECLARE kloopstr = vc WITH public, noconstant(" ")
    SELECT INTO "nl:"
     pcd.entity_id
     FROM person_combine_det pcd
     WHERE pcd.person_combine_id=rub_cmb_table_id
      AND pcd.entity_name="PRSNL_COMBINE"
     DETAIL
      prsnl_ucb_id = pcd.entity_id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(1)
    ENDIF
    IF (prsnl_ucb_id > 0.0)
     FREE RECORD xntr_reucb
     RECORD xntr_reucb(
       1 list[*]
         2 table_name = vc
         2 details[*]
           3 ucb_detail_id = f8
           3 entity_id = f8
           3 num_ed_fields = i4
           3 entity_details[*]
             4 column_name = vc
             4 data_type = vc
             4 data_number = f8
             4 data_char = vc
             4 data_date = dq8
     )
     FREE RECORD xntr_reucb_activate
     RECORD xntr_reucb_activate(
       1 list[*]
         2 ucb_detail_id = f8
     )
     SET rub_activate_cnt = 0
     SET dm_err->eproc = "Gathering relevant rows from COMBINE_DETAIL"
     SELECT INTO "nl:"
      cd.entity_name, cd.combine_detail_id, cd.entity_id
      FROM combine_detail cd
      WHERE cd.combine_id=prsnl_ucb_id
       AND  EXISTS (
      (SELECT
       1
       FROM dm_xntr_extract_row_data dxerd
       WHERE dxerd.table_name=cd.entity_name
        AND dxerd.extract_id=rub_extract_id))
      ORDER BY cd.entity_name, cd.entity_id
      HEAD REPORT
       tablecnt = 0, rowcnt = 0
      HEAD cd.entity_name
       tablecnt = (tablecnt+ 1), stat = alterlist(xntr_reucb->list,tablecnt), xntr_reucb->list[
       tablecnt].table_name = cd.entity_name,
       rowcnt = 0
      DETAIL
       rowcnt = (rowcnt+ 1), stat = alterlist(xntr_reucb->list[tablecnt].details,rowcnt), xntr_reucb
       ->list[tablecnt].details[rowcnt].ucb_detail_id = cd.combine_detail_id,
       xntr_reucb->list[tablecnt].details[rowcnt].entity_id = cd.entity_id
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(1)
     ENDIF
     IF (size(xntr_reucb->list,5) > 0)
      DECLARE rub_ucb_where_clause = vc WITH public, noconstant(" ")
      FOR (iloop = 1 TO size(xntr_reucb->list,5))
        FOR (jloop = 1 TO size(xntr_reucb->list[iloop].details,5))
          SET dm_err->eproc = "Gather required columns from ENTITY_DETAIL"
          SELECT INTO "nl:"
           ed.*
           FROM entity_detail ed
           WHERE (ed.entity_id=xntr_reucb->list[iloop].details[jloop].entity_id)
           HEAD REPORT
            xntr_reucb->list[iloop].details[jloop].num_ed_fields = 0
           DETAIL
            xntr_reucb->list[iloop].details[jloop].num_ed_fields = (xntr_reucb->list[iloop].details[
            jloop].num_ed_fields+ 1), stat = alterlist(xntr_reucb->list[iloop].details[jloop].
             entity_details,xntr_reucb->list[iloop].details[jloop].num_ed_fields), xntr_reucb->list[
            iloop].details[jloop].entity_details[xntr_reucb->list[iloop].details[jloop].num_ed_fields
            ].column_name = ed.column_name,
            xntr_reucb->list[iloop].details[jloop].entity_details[xntr_reucb->list[iloop].details[
            jloop].num_ed_fields].data_type = ed.data_type, xntr_reucb->list[iloop].details[jloop].
            entity_details[xntr_reucb->list[iloop].details[jloop].num_ed_fields].data_number = ed
            .data_number, xntr_reucb->list[iloop].details[jloop].entity_details[xntr_reucb->list[
            iloop].details[jloop].num_ed_fields].data_char = ed.data_char,
            xntr_reucb->list[iloop].details[jloop].entity_details[xntr_reucb->list[iloop].details[
            jloop].num_ed_fields].data_date = cnvtdatetime(ed.data_date)
           WITH nocounter
          ;end select
          IF (check_error(dm_err->eproc)=1)
           CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
           RETURN(1)
          ENDIF
          SET rub_ucb_where_clause = " "
          SET kloop = 0
          FOR (kloop = 1 TO xntr_reucb->list[iloop].details[jloop].num_ed_fields)
            SET kloopstr = trim(cnvtstring(kloop))
            IF (kloop > 1)
             SET rub_ucb_where_clause = concat(rub_ucb_where_clause," and live_tbl.")
            ELSE
             SET rub_ucb_where_clause = "live_tbl."
            ENDIF
            SET rub_ucb_where_clause = concat(rub_ucb_where_clause,xntr_reucb->list[iloop].details[
             jloop].entity_details[kloop].column_name," = ")
            CASE (xntr_reucb->list[iloop].details[jloop].entity_details[kloop].data_type)
             OF "INTEGER":
             OF "DOUBLE":
             OF "BIGINT":
             OF "FLOAT":
             OF "NUMBER":
              SET rub_ucb_where_clause = concat(rub_ucb_where_clause,
               "xntr_reucb->list[iLoop].details[jLoop].entity_details[",kloopstr,"].data_number")
             OF "VARCHAR":
             OF "VARCHAR2":
             OF "CHAR":
              SET rub_ucb_where_clause = concat(rub_ucb_where_clause,
               "xntr_reucb->list[iLoop].details[jLoop].entity_details[",kloopstr,"].data_char")
             OF "TIME":
             OF "TIMESTAMP":
             OF "DATE":
              SET rub_ucb_where_clause = concat(rub_ucb_where_clause,
               "cnvtdatetime(xntr_reucb->list[iLoop].details[jLoop].entity_details[",kloopstr,
               "].data_date)")
            ENDCASE
          ENDFOR
          SET dm_err->eproc = "Determining if there are rows that need to be reactivated"
          SELECT INTO "nl:"
           live_tbl.rowid
           FROM (value(xntr_reucb->list[iloop].table_name) live_tbl)
           WHERE live_tbl.rowid IN (
           (SELECT
            dxerd.new_rowid
            FROM dm_xntr_extract_row_data dxerd
            WHERE (dxerd.table_name=xntr_reucb->list[iloop].table_name)
             AND dxerd.extract_id=rub_extract_id))
            AND parser(rub_ucb_where_clause)
           DETAIL
            rub_activate_cnt = (rub_activate_cnt+ 1), stat = alterlist(xntr_reucb_activate->list,
             rub_activate_cnt), xntr_reucb_activate->list[rub_activate_cnt].ucb_detail_id =
            xntr_reucb->list[iloop].details[jloop].ucb_detail_id
           WITH nocounter
          ;end select
          IF (check_error(dm_err->eproc)=1)
           CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
           RETURN(1)
          ENDIF
        ENDFOR
      ENDFOR
      IF (rub_activate_cnt > 0)
       UPDATE  FROM combine_detail cd,
         (dummyt d  WITH seq = value(size(xntr_reucb_activate->list,5)))
        SET cd.active_ind = 1
        PLAN (d)
         JOIN (cd
         WHERE (cd.combine_detail_id=xntr_reucb_activate->list[d.seq].ucb_detail_id))
        WITH nocounter
       ;end update
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        RETURN(1)
       ENDIF
       SET dm_err->eproc = "Re-activating PRSNL_COMBINE row"
       UPDATE  FROM person_combine_det pcd
        SET pcd.active_ind = 1
        WHERE pcd.person_combine_id=rub_cmb_table_id
         AND pcd.entity_name="PRSNL_COMBINE"
        WITH nocounter
       ;end update
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        RETURN(1)
       ENDIF
       IF (norows=1)
        SET norows = 0
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (norows=1)
    RETURN(2)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 IF (validate(xntr_rows->use_alt,"Z")="Z")
  FREE RECORD xntr_rows
  RECORD xntr_rows(
    1 use_alt = c1
    1 extract_id = f8
  )
  SET xntr_rows->use_alt = "N"
  SET xntr_rows->extract_id = 0.0
 ENDIF
 DECLARE xntr_append_where(xntr_table_name=vc,xntr_alias=vc) = vc
 DECLARE xntr_repalce_where(xntr_orig_where=vc,xntr_table_name=vc,xntr_alias=vc) = vc
 DECLARE xntr_alt_min_id(null) = f8
 DECLARE xntr_alt_max_id(null) = f8
 DECLARE xntr_bypass_readme_status(null) = i2
 DECLARE xntr_add_metadata(xntr_readme_id=f8,xntr_instance=i4,xntr_table_name=vc) = i2
 IF ((validate(xntr_default_id,- (99.0))=- (99.0)))
  DECLARE xntr_default_id = f8 WITH public, constant(- (1.0))
 ENDIF
 IF ((validate(xntr_constant_min_val,- (99.0))=- (99.0)))
  DECLARE xntr_constant_min_val = f8 WITH public, constant(5.0)
 ENDIF
 IF ((validate(xntr_constant_max_val,- (99.0))=- (99.0)))
  DECLARE xntr_constant_max_val = f8 WITH public, constant(10.0)
 ENDIF
 SUBROUTINE xntr_append_where(xntr_table_name,xntr_alias)
   IF (validate(xntr_rows->use_alt,"Q")="Q")
    RETURN("1 = 1")
   ENDIF
   IF ((xntr_rows->use_alt != "Y"))
    RETURN("1 = 1")
   ENDIF
   IF (size(trim(xntr_table_name,3),1)=0)
    RETURN("1 = 1")
   ENDIF
   IF ((xntr_rows->extract_id=0.0))
    RETURN("1 = 1")
   ENDIF
   DECLARE xntrdyninclause = vc WITH public, noconstant("")
   IF (size(trim(xntr_alias,3),1) > 0)
    SET xntrdyninclause = concat(trim(xntr_alias,3),".rowid in (")
   ELSE
    SET xntrdyninclause = "rowid in ("
   ENDIF
   SET xntrdyninclause = concat(xntrdyninclause,
    "select dxerd.new_rowid from dm_xntr_extract_row_data dxerd"," where dxerd.table_name = '",
    xntr_table_name,"' and dxerd.extract_id = ",
    trim(cnvtstring(xntr_rows->extract_id)),")")
   RETURN(xntrdyninclause)
 END ;Subroutine
 SUBROUTINE xntr_replace_where(xntr_orig_where,xntr_table_name,xntr_alias)
   IF (validate(xntr_rows->use_alt,"Q")="Q")
    RETURN(xntr_orig_where)
   ENDIF
   IF ((xntr_rows->use_alt != "Y"))
    RETURN(xntr_orig_where)
   ENDIF
   IF (size(trim(xntr_table_name,3),1)=0)
    RETURN(xntr_orig_where)
   ENDIF
   IF ((xntr_rows->extract_id=0.0))
    RETURN("1 = 1")
   ENDIF
   DECLARE xntrdyninclause = vc WITH public, noconstant("")
   IF (size(trim(xntr_alias,3),1) > 0)
    SET xntrdyninclause = concat(trim(xntr_alias,3),".rowid in (")
   ELSE
    SET xntrdyninclause = "rowid in ("
   ENDIF
   SET xntrdyninclause = concat(xntrdyninclause,
    "select dxerd.new_rowid from dm_xntr_extract_row_data dxerd"," where dxerd.table_name = '",
    xntr_table_name,"' and dxerd.extract_id = ",
    trim(cnvtstring(xntr_rows->extract_id)),")")
   RETURN(xntrdyninclause)
 END ;Subroutine
 SUBROUTINE xntr_alt_min_id(null)
   IF (validate(xntr_rows->use_alt,"Q")="Q")
    RETURN(xntr_default_id)
   ENDIF
   IF ((xntr_rows->use_alt != "Y"))
    RETURN(xntr_default_id)
   ENDIF
   RETURN(xntr_constant_min_val)
 END ;Subroutine
 SUBROUTINE xntr_alt_max_id(null)
   IF (validate(xntr_rows->use_alt,"Q")="Q")
    RETURN(xntr_default_id)
   ENDIF
   IF ((xntr_rows->use_alt != "Y"))
    RETURN(xntr_default_id)
   ENDIF
   RETURN(xntr_constant_max_val)
 END ;Subroutine
 SUBROUTINE xntr_bypass_readme_status(null)
   IF (validate(xntr_rows->use_alt,"Q")="Q")
    RETURN(0)
   ENDIF
   IF ((xntr_rows->use_alt != "Y"))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE xntr_add_metadata(xntr_readme_id,xntr_instance,xntr_table_name)
   DECLARE xntr_dxrt_exists_ind = i2 WITH public, noconstant(0)
   DECLARE xntr_dxrt_errmsg = vc WITH protect, noconstant(" ")
   DECLARE xntr_ccl_def_ind = i2 WITH public, noconstant(0)
   DECLARE xntr_ora_tbl_ind = i2 WITH public, noconstant(0)
   IF (validate(xntr_rows->use_alt,"Q")="Y")
    RETURN(0)
   ENDIF
   IF (xntr_readme_id <= 0.0)
    SET readme_data->status = "F"
    SET readme_data->message = "Failed to pass a valid readme_id to xntr_add_metadata()"
    RETURN(1)
   ENDIF
   IF (xntr_instance <= 0)
    SET readme_data->status = "F"
    SET readme_data->message = "Failed to pass a valid instance to xntr_add_metadata()"
    RETURN(1)
   ENDIF
   IF (size(trim(xntr_table_name,3),1)=0)
    SET readme_data->status = "F"
    SET readme_data->message = "Failed to pass a valid table_name to xntr_add_metadata()"
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    dta.table_name
    FROM dtableattr dta
    WHERE dta.table_name="DM_XNTR_README_TABLE"
    DETAIL
     xntr_ccl_def_ind = 1
    WITH nocounter
   ;end select
   IF (error(xntr_dxrt_errmsg,0) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to find CCL Definition:",xntr_dxrt_errmsg)
    RETURN(1)
   ENDIF
   IF (xntr_ccl_def_ind=0)
    SELECT INTO "nl:"
     utcol.table_name
     FROM user_tab_columns utcol
     WHERE utcol.table_name="DM_XNTR_README_TABLE"
     DETAIL
      xntr_ora_tbl_ind = 1
     WITH nocounter
    ;end select
    IF (error(xntr_dxrt_errmsg,0) != 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("Failed to find Orable Table:",xntr_dxrt_errmsg)
     RETURN(1)
    ENDIF
    IF (xntr_ora_tbl_ind=1)
     EXECUTE oragen3 "DM_XNTR_README_TABLE"
    ELSE
     RETURN(0)
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    dxrt.table_name
    FROM dm_xntr_readme_table dxrt
    WHERE dxrt.readme_id=xntr_readme_id
     AND dxrt.readme_instance=xntr_instance
     AND dxrt.table_name=xntr_table_name
    DETAIL
     xntr_dxrt_exists_ind = 1
    WITH nocounter
   ;end select
   IF (error(xntr_dxrt_errmsg,0) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to Query DM_README_XNTR_TABLE:",xntr_dxrt_errmsg)
    RETURN(1)
   ENDIF
   IF (xntr_dxrt_exists_ind=0)
    INSERT  FROM dm_xntr_readme_table dxrt
     SET dxrt.dm_xntr_readme_table_id = seq(dm_clinical_seq,nextval), dxrt.readme_id = xntr_readme_id,
      dxrt.readme_instance = xntr_instance,
      dxrt.table_name = xntr_table_name, dxrt.updt_applctx = reqinfo->updt_applctx, dxrt.updt_cnt = 0,
      dxrt.updt_dt_tm = cnvtdatetime(curdate,curtime3), dxrt.updt_id = reqinfo->updt_id, dxrt
      .updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (error(xntr_dxrt_errmsg,0) != 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("Failed to Insert to DM_XNTR_README_TABLE:",xntr_dxrt_errmsg)
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 DECLARE dxed_detail_id = f8 WITH protect, noconstant(0.0)
 DECLARE dxed_entity_id = f8 WITH protect, noconstant(0.0)
 DECLARE dxed_entity_name = vc WITH protect, noconstant("")
 DECLARE dxed_instance_nbr = i4 WITH protect, noconstant(0)
 DECLARE dxed_done_ind = i2 WITH protect, noconstant(0)
 DECLARE dxed_active_ind = i2 WITH protect, noconstant(0)
 DECLARE dxed_from_id = f8 WITH protect, noconstant(0.0)
 DECLARE dxed_to_id = f8 WITH protect, noconstant(0.0)
 DECLARE dxed_encntr_id = f8 WITH protect, noconstant(0.0)
 DECLARE dxed_cmb_type = vc WITH protect, noconstant("")
 DECLARE dxed_ucb_val = i4 WITH protect, noconstant(0)
 IF (validate(dxed_reply->status,"abc")="abc"
  AND validate(dxed_reply->status,"def")="def")
  FREE RECORD dxed_reply
  RECORD dxed_reply(
    1 status = vc
    1 status_msg = vc
    1 detail_id = f8
  )
 ENDIF
 IF ((validate(dxed_request->extract_id,- (1.0))=- (1.0))
  AND (validate(dxed_request->extract_id,- (2.0))=- (2.0)))
  FREE RECORD dxed_request
  RECORD dxed_request(
    1 extract_id = f8
  )
  IF (reflect(parameter(1,0)) != "I*"
   AND reflect(parameter(1,0)) != "F*")
   SET dm_err->err_ind = 1
   SET dm_err->emsg = "Expected syntax: dm2_xntr_execute_detail <EXTRACT_ID>"
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   SET dxed_reply->status = "F"
   SET dxed_reply->status_msg = "Expected syntax: dm2_xntr_execute_detail <EXTRACT_ID>"
   GO TO exit_exec_det
  ELSE
   SET dxed_request->extract_id =  $1
  ENDIF
 ENDIF
 CALL check_logfile("dm2_xntr_exec_det",".log","DM2_XNTR_EXECUTE_DETAIL LOGFILE")
 SET dm_err->eproc = "Beginning dm2_xntr_execute_detail"
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "NL:"
  FROM dm_xntr_detail d
  WHERE (d.dm_xntr_extract_id=dxed_request->extract_id)
   AND d.status="QUEUED"
  WITH nocounter, maxqual(d,1)
 ;end select
 IF (check_error("Identifying detail row") != 0)
  ROLLBACK
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET dxed_reply->status = "F"
  SET dxed_reply->status_msg = dm_err->emsg
  GO TO exit_exec_det
 ENDIF
 IF (curqual=0)
  GO TO exit_exec_det
 ENDIF
 WHILE (dxed_done_ind=0)
   SELECT INTO "NL:"
    FROM dm_xntr_detail d
    WHERE (d.dm_xntr_extract_id=dxed_request->extract_id)
     AND d.sequence_nbr IN (
    (SELECT
     min(a.sequence_nbr)
     FROM dm_xntr_detail a
     WHERE (a.dm_xntr_extract_id=dxed_request->extract_id)
      AND a.status="QUEUED"))
    DETAIL
     dxed_detail_id = d.dm_xntr_detail_id, dxed_entity_id = d.task_entity_id, dxed_entity_name = d
     .task_entity_name,
     dxed_instance_nbr = d.instance_nbr
    WITH nocounter
   ;end select
   IF (check_error("Identifying detail row") != 0)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dxed_reply->status = "F"
    SET dxed_reply->status_msg = dm_err->emsg
    GO TO exit_exec_det
   ENDIF
   IF (curqual=0)
    SET dxed_done_ind = 1
    GO TO exit_exec_det
   ENDIF
   IF (dxrc_update_detail(dxed_detail_id,"RUNNING",1)=1)
    ROLLBACK
    SET dxed_reply->status = "F"
    SET dxed_reply->status_msg = dm_err->emsg
    GO TO exit_exec_det
   ENDIF
   SET dxed_reply->detail_id = dxed_detail_id
   IF (dxed_entity_name="DM_XNTR_README_DATA")
    FREE RECORD readme_data
    RECORD readme_data(
      1 ocd = i4
      1 readme_id = f8
      1 instance = i4
      1 readme_type = vc
      1 description = vc
      1 script = vc
      1 check_script = vc
      1 data_file = vc
      1 par_file = vc
      1 blocks = i4
      1 log_rowid = vc
      1 log_rowid = vc
      1 status = vc
      1 message = c255
      1 options = vc
      1 driver = vc
      1 batch_dt_tm = dq8
    )
    SELECT INTO "nl:"
     dxrd.readme_id, dxrd.readme_instance, dxrd.script
     FROM dm_xntr_readme_data dxrd
     WHERE dxrd.readme_id=dxed_entity_id
      AND dxrd.readme_instance=dxed_instance_nbr
     DETAIL
      readme_data->readme_id = dxrd.readme_id, readme_data->instance = dxrd.readme_instance,
      readme_data->script = dxrd.script
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET dxed_reply->status = "F"
     SET dxed_reply->status_msg = concat("DM_XNTR_DETAIL_ID: ",trim(cnvtstring(dxed_detail_id,20)),
      " has no DM_XNTR_README_DATA row.")
     GO TO exit_exec_det
    ENDIF
    SET xntr_rows->use_alt = "Y"
    SET xntr_rows->extract_id = dxed_request->extract_id
    EXECUTE value(cnvtupper(readme_data->script))
    IF ((readme_data->status="F"))
     SET dxed_reply->status = "F"
     SET dxed_reply->status_msg = concat("DM_XNTR_DETAIL_ID: ",trim(cnvtstring(dxed_detail_id,20)),
      " Readme ",trim(cnvtstring(readme_data->readme_id))," failed:",
      readme_data->message)
     GO TO exit_exec_det
    ELSE
     IF (dxrc_update_detail(dxed_detail_id,"FINISHED",1)=1)
      ROLLBACK
      SET dxed_reply->status = "F"
      SET dxed_reply->status_msg = dm_err->emsg
      GO TO exit_exec_det
     ENDIF
    ENDIF
   ELSE
    IF (dxed_entity_name="ENCNTR_COMBINE")
     SELECT INTO "NL:"
      FROM encntr_combine e
      WHERE e.encntr_combine_id=dxed_entity_id
      DETAIL
       dxed_active_ind = e.active_ind, dxed_from_id = e.from_encntr_id, dxed_to_id = e.to_encntr_id,
       dxed_encntr_id = 0.0, dxed_cmb_type = "ENCOUNTER"
      WITH nocounter
     ;end select
    ELSEIF (dxed_entity_name="PERSON_COMBINE")
     SELECT INTO "NL:"
      FROM person_combine p
      WHERE p.person_combine_id=dxed_entity_id
      DETAIL
       dxed_active_ind = p.active_ind, dxed_from_id = p.from_person_id, dxed_to_id = p.to_person_id,
       dxed_encntr_id = p.encntr_id, dxed_cmb_type = "PERSON"
      WITH nocounter
     ;end select
    ELSE
     SET dxed_reply->status = "F"
     SET dxed_reply->status_msg = concat("DM_XNTR_DETAIL_ID: ",trim(cnvtstring(dxed_detail_id,20)),
      " has an unrecognized TASK_ENTITY_NAME")
     GO TO exit_exec_det
    ENDIF
    IF (check_error("Obtaining COMBINE information row") != 0)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dxed_reply->status = "F"
     SET dxed_reply->status_msg = dm_err->emsg
     GO TO exit_exec_det
    ENDIF
    IF (curqual=0)
     SET dxed_reply->status = "F"
     SET dxed_reply->status_msg = concat("No information found in ",dxed_entity_name," for ID ",trim(
       cnvtstring(dxed_entity_id,20)))
     GO TO exit_exec_det
    ENDIF
    IF (dxed_active_ind=1)
     FREE RECORD request
     RECORD request(
       1 parent_table = c50
       1 cmb_mode = c20
       1 error_message = c132
       1 transaction_type = c8
       1 reverse_cmb_ind = i2
       1 xxx_combine[*]
         2 xxx_combine_id = f8
         2 from_xxx_id = f8
         2 from_mrn = c200
         2 from_alias_pool_cd = f8
         2 from_alias_type_cd = f8
         2 to_xxx_id = f8
         2 to_mrn = c200
         2 to_alias_pool_cd = f8
         2 to_alias_type_cd = f8
         2 encntr_id = f8
         2 application_flag = i2
         2 combine_weight = f8
       1 xxx_combine_det[*]
         2 xxx_combine_det_id = f8
         2 xxx_combine_id = f8
         2 entity_name = c32
         2 entity_id = f8
         2 entity_pk[*]
           3 col_name = c30
           3 data_type = c30
           3 data_char = c100
           3 data_number = f8
           3 data_date = dq8
         2 combine_action_cd = f8
         2 attribute_name = c32
         2 prev_active_ind = i2
         2 prev_active_status_cd = f8
         2 prev_end_eff_dt_tm = dq8
         2 combine_desc_cd = f8
         2 to_record_ind = i2
     )
     FREE RECORD reply
     RECORD reply(
       1 xxx_combine_id[*]
         2 combine_id = f8
         2 parent_table = c50
         2 from_xxx_id = f8
         2 to_xxx_id = f8
         2 encntr_id = f8
       1 error[*]
         2 create_dt_tm = dq8
         2 parent_table = c50
         2 from_id = f8
         2 to_id = f8
         2 encntr_id = f8
         2 error_table = c32
         2 error_type = vc
         2 error_msg = vc
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c8
           3 operationstatus = c1
           3 targetobjectname = c15
           3 targetobjectvalue = c100
     )
     CALL prep_rcb_request(dxed_cmb_type,dxed_from_id,dxed_to_id,dxed_encntr_id,dxed_entity_id)
     EXECUTE dm_call_combine  WITH replace("REQUEST","REQUEST"), replace("REPLY","REPLY")
     IF ((reply->status_data.status != "S"))
      SET dxed_reply->status = "F"
      IF (size(reply->error,5) > 0)
       SET dxed_reply->status_msg = reply->error[1].error_msg
      ELSE
       SET dxed_reply->status_msg = "Error occurred calling DM_COMBINE"
      ENDIF
      GO TO exit_exec_det
     ELSE
      IF (dxrc_update_detail(dxed_detail_id,"FINISHED",1)=1)
       ROLLBACK
       SET dxed_reply->status = "F"
       SET dxed_reply->status_msg = dm_err->emsg
       GO TO exit_exec_det
      ENDIF
     ENDIF
    ELSE
     FREE RECORD request
     RECORD request(
       1 parent_table = c50
       1 cmb_mode = vc
       1 error_message = vc
       1 xxx_uncombine[*]
         2 xxx_combine_id = f8
         2 from_xxx_id = f8
         2 from_mrn = c200
         2 from_alias_pool_cd = f8
         2 from_alias_type_cd = f8
         2 to_xxx_id = f8
         2 to_mrn = c200
         2 to_alias_pool_cd = f8
         2 to_alias_type_cd = f8
         2 encntr_id = f8
         2 application_flag = i2
       1 xxx_combine[*]
         2 xxx_combine_id = f8
         2 from_xxx_id = f8
         2 from_mrn = c200
         2 from_alias_pool_cd = f8
         2 from_alias_type_cd = f8
         2 to_xxx_id = f8
         2 to_mrn = c200
         2 to_alias_pool_cd = f8
         2 to_alias_type_cd = f8
         2 encntr_id = f8
         2 application_flag = i2
         2 combine_weight = f8
       1 xxx_combine_det[*]
         2 xxx_combine_det_id = f8
         2 xxx_combine_id = f8
         2 entity_name = c32
         2 entity_id = f8
         2 entity_pk[*]
           3 col_name = c30
           3 data_type = c30
           3 data_char = c100
           3 data_number = f8
           3 data_date = dq8
         2 combine_action_cd = f8
         2 attribute_name = c32
         2 prev_active_ind = i2
         2 prev_active_status_cd = f8
         2 prev_end_eff_dt_tm = dq8
         2 combine_desc_cd = f8
         2 to_record_ind = i2
       1 transaction_type = c8
     )
     FREE RECORD reply
     RECORD reply(
       1 xxx_combine_id[*]
         2 combine_id = f8
         2 parent_table = c50
         2 from_xxx_id = f8
         2 to_xxx_id = f8
         2 encntr_id = f8
       1 error[*]
         2 create_dt_tm = dq8
         2 parent_table = c50
         2 from_id = f8
         2 to_id = f8
         2 encntr_id = f8
         2 error_table = c32
         2 error_type = vc
         2 error_msg = vc
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c8
           3 operationstatus = c1
           3 targetobjectname = c15
           3 targetobjectvalue = c100
     )
     SET dxed_ucb_val = activate_rub_details(dxed_cmb_type,dxed_entity_id,dxed_request->extract_id)
     IF (dxed_ucb_val=1)
      SET dxed_reply->status = "F"
      SET dxed_reply->status_msg = "Some error message from inc file"
      GO TO exit_exec_det
     ELSEIF (dxed_ucb_val=0)
      CALL prep_rub_request(dxed_cmb_type,dxed_from_id,dxed_to_id,dxed_encntr_id,dxed_entity_id)
      EXECUTE dm_call_uncombine  WITH replace("REQUEST","REQUEST"), replace("REPLY","REPLY")
      IF ((reply->status_data.status != "S"))
       SET dxed_reply->status = "F"
       IF (size(reply->error,5) > 0)
        SET dxed_reply->status_msg = reply->error[1].error_msg
       ELSE
        SET dxed_reply->status_msg = "Error occurred calling DM_CALL_UNCOMBINE"
       ENDIF
       GO TO exit_exec_det
      ELSE
       IF (dxrc_update_detail(dxed_detail_id,"FINISHED",1)=1)
        ROLLBACK
        SET dxed_reply->status = "F"
        SET dxed_reply->status_msg = dm_err->emsg
        GO TO exit_exec_det
       ENDIF
      ENDIF
     ELSE
      IF (dxrc_update_detail(dxed_detail_id,"FINISHED",1)=1)
       ROLLBACK
       SET dxed_reply->status = "F"
       SET dxed_reply->status_msg = dm_err->emsg
       GO TO exit_exec_det
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 ENDWHILE
#exit_exec_det
 IF ((dxed_reply->status != "F"))
  SET dxed_reply->status = "S"
  SET dxed_reply->status_msg = "All detail rows successfully executed"
  SET dxed_reply->detail_id = 0.0
 ENDIF
END GO
