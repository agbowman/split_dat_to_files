CREATE PROGRAM dm2_space_summary:dba
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
 IF ((validate(dmt_min_ext_size,- (1))=- (1)))
  DECLARE dmt_min_ext_size = f8 WITH public, constant(163840.0)
 ENDIF
 IF ((validate(dm2_block_size,- (1))=- (1))
  AND (validate(dm2_block_size,- (2))=- (2)))
  IF (currdb="ORACLE")
   DECLARE dm2_block_size = f8 WITH public, constant(8192.0)
  ELSEIF (currdb="DB2UDB")
   DECLARE dm2_block_size = f8 WITH public, constant(16384.0)
  ELSE
   DECLARE dm2_block_size = f8 WITH public, constant(8192.0)
  ENDIF
 ENDIF
 IF ((validate(rtspace->rtspace_cnt,- (1))=- (1)))
  FREE RECORD rtspace
  RECORD rtspace(
    1 dbname = vc
    1 tmp_table_name = vc
    1 rtspace_cnt = i4
    1 sql_size_mb = f8
    1 sql_filegrowth_mb = f8
    1 install_type = vc
    1 install_type_value = vc
    1 mode = vc
    1 ddl_report_fname = vc
    1 commands_written_ind = i2
    1 database_remote = i2
    1 unique_nbr = vc
    1 temp_tspace_name = vc
    1 temp_tspace_file_type = vc
    1 temp_tspace_ttl_mb = i4
    1 temp_tspace_reserved_pct = i4
    1 temp_tspace_reserved_mb = i4
    1 temp_tspace_ttl_needed_mb = i4
    1 temp_tspace_ratio = f8
    1 temp_tspace_indexlist[*]
      2 tbl_name = vc
      2 ind_name = vc
      2 size_mb = i4
    1 qual[*]
      2 tspace_name = vc
      2 chunk_size = f8
      2 chunks_needed = i4
      2 ext_mgmt = c1
      2 tspace_id = i4
      2 cur_bytes_allocated = f8
      2 bytes_needed = f8
      2 user_bytes_to_add = f8
      2 final_bytes_to_add = f8
      2 new_ind = i2
      2 extend_ind = i2
      2 init_ext = f8
      2 next_ext = f8
      2 cont_complete_ind = i4
      2 cont_cnt = i4
      2 ct_err_msg = vc
      2 ct_err_ind = i2
      2 asm_disk_group = vc
      2 commands[*]
        3 cmd_type = vc
        3 cmd = vc
        3 lv_file = vc
        3 lv_exist_chk = i2
      2 cont[*]
        3 volume_label = vc
        3 disk_name = vc
        3 disk_idx = i4
        3 vg_name = vc
        3 pp_size_mb = f8
        3 pps_to_add = f8
        3 add_ext_ind = c1
        3 cont_tspace_rel_key = i4
        3 space_to_add = f8
        3 delete_ind = i2
        3 cont_size_mb = f8
        3 lv_file = vc
        3 new_ind = i2
        3 mwc_flag = i2
      2 temp_ind = i2
      2 user_tspace_ind = i2
  )
  SET rtspace->install_type = "DM2NOTSET"
  SET rtspace->install_type_value = "DM2NOTSET"
  SET rtspace->mode = "DM2NOTSET"
  SET rtspace->ddl_report_fname = "DM2NOTSET"
  SET rtspace->unique_nbr = ""
 ENDIF
 IF ((validate(ddtsp->tsp_cnt,- (1))=- (1)))
  FREE RECORD ddtsp
  RECORD ddtsp(
    1 nonstd_ind = i2
    1 nonstd_tgt_ind = i2
    1 tsp_cnt = i4
    1 qual[*]
      2 tspace_name = vc
      2 ext_mgmt = c1
      2 alloc_type = vc
      2 seg_space_mgmt = vc
      2 bigfile = c3
      2 nonstd_ind = i2
      2 nonstd_tgt_ind = i2
      2 lmt_ora8_ind = i2
      2 lmt_uniform_ind = i2
      2 lmt_and_not_assm = i2
      2 lmt_bigfile = i2
      2 datafile_not_ae = i2
      2 datafile_not_unlimited = i2
      2 datafile_not_assm = i2
      2 lmt_and_not_ae = i2
  )
  SET ddtsp->nonstd_ind = 0
  SET ddtsp->nonstd_tgt_ind = 0
 ENDIF
 IF ((validate(dm2_ind_tspace_assign->cnt,- (1))=- (1)))
  FREE SET dm2_ind_tspace_assign
  RECORD dm2_ind_tspace_assign(
    1 cnt = i4
    1 qual[*]
      2 table_name = vc
      2 index_tspace = vc
      2 index_tspace_cnt = i4
      2 tspace_cnt = i4
      2 tspace[*]
        3 tspace_name = vc
        3 ind_cnt = i4
  )
  SET dm2_ind_tspace_assign->cnt = 0
 ENDIF
 IF ((validate(das_dtp->dtp_cnt,- (1))=- (1)))
  FREE RECORD das_dtp
  RECORD das_dtp(
    1 dtp_cnt = i4
    1 qual[*]
      2 tname = vc
      2 prec_cnt = i2
      2 prec[*]
        3 precedence = i2
        3 data_tspace = vc
        3 data_extent_size = f8
        3 ind_tspace = vc
        3 index_extent_size = f8
        3 long_tspace = vc
  )
  SET das_dtp->dtp_cnt = 0
 ENDIF
 IF ((validate(dtr_tspace_misc->recalc_space_needs,- (1))=- (1))
  AND (validate(dtr_tspace_misc->recalc_space_needs,- (2))=- (2)))
  FREE RECORD dtr_tspace_misc
  RECORD dtr_tspace_misc(
    1 recalc_space_needs = i2
    1 gen_id = f8
  )
  SET dtr_tspace_misc->recalc_space_needs = 0
  SET dtr_tspace_misc->gen_id = 0.0
 ENDIF
 IF ((validate(dtrt->cnt,- (1))=- (1)))
  FREE RECORD dtrt
  RECORD dtrt(
    1 cnt = i4
    1 qual[*]
      2 tspace_name = vc
  )
  SET dtrt->cnt = 0
 ENDIF
 IF ((validate(dcs_long_tspace->tspace_count,- (1))=- (1)))
  FREE SET dcs_long_tspace
  RECORD dcs_long_tspace(
    1 tspace_count = i4
    1 tspace[*]
      2 tspace_name = vc
      2 bytes = f8
      2 tbl_cnt = i4
      2 tbl[*]
        3 table_name = vc
        3 column_name = vc
  )
  SET dcs_long_tspace->tspace_count = 0
 ENDIF
 DECLARE dtr_lob_size = f8 WITH protect, constant(163840.0)
 DECLARE dtr_load_tspaces(dlt_process=vc) = i2
 DECLARE dtr_rpt_nonstd_tspace(drnt_file=vc,drnt_mode=i2) = i2
 DECLARE dtr_find_tspace(dft_tspace=vc) = i2
 DECLARE dtr_eval_nonstd_tgt_tspace(sbr_tsp_idx=i4) = i2
 DECLARE d2tr_get_man_inst_type_val(null) = i2
 DECLARE dm2_adj_size(d_adj_size=f8,d_adj_mult=f8) = f8
 DECLARE dm2_adj_init_next_ext(daine_data_to_move=vc,daine_table_type=i2,daine_table_name=vc,
  daine_init_ext=f8(ref),daine_next_ext=f8(ref)) = null
 DECLARE dtr_load_clin_tspaces(null) = i2
 SUBROUTINE dm2_adj_size(d_adj_size,d_adj_mult)
   DECLARE das_ceil_factor = f8 WITH protect, noconstant(0.0)
   DECLARE das_ret = f8 WITH protect, noconstant(0.0)
   IF (d_adj_mult > 0.0)
    SET das_ceil_factor = dm2ceil((d_adj_size/ d_adj_mult))
    SET das_ret = (d_adj_mult * das_ceil_factor)
   ELSE
    SET das_ret = d_adj_size
   ENDIF
   RETURN(das_ret)
 END ;Subroutine
 SUBROUTINE d2tr_get_man_inst_type_val(null)
   DECLARE dgmitv_info_num_hold = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Getting Manual Install_Type_Value from DM_INFO."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_TSPACE_SIZE-MAX VALUE"
     AND d.info_name="MANUAL"
    DETAIL
     dgmitv_info_num_hold = d.info_number
    WITH forupdatewait(d)
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   CASE (curqual)
    OF 1:
     SET rtspace->install_type_value = cnvtstring((dgmitv_info_num_hold+ 1))
     SET dm_err->eproc = concat("Updating Manual Install_Type_Value in DM_INFO to:",rtspace->
      install_type_value)
     CALL disp_msg("",dm_err->logfile,0)
     UPDATE  FROM dm_info d
      SET d.info_number = cnvtint(rtspace->install_type_value)
      WHERE d.info_domain="DM2_TSPACE_SIZE-MAX VALUE"
       AND d.info_name="MANUAL"
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
    OF 0:
     SET rtspace->install_type_value = "1"
     SET dm_err->eproc = "Inserting Manual Install_Type_Value into DM_INFO."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
     INSERT  FROM dm_info d
      SET d.info_domain = "DM2_TSPACE_SIZE-MAX VALUE", d.info_name = "MANUAL", d.info_number =
       cnvtint(rtspace->install_type_value)
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_find_tspace(dft_tspace)
   DECLARE dft_idx = i4 WITH protect, noconstant(0)
   SET dft_idx = locateval(dft_idx,1,ddtsp->tsp_cnt,dft_tspace,ddtsp->qual[dft_idx].tspace_name)
   RETURN(dft_idx)
 END ;Subroutine
 SUBROUTINE dtr_rpt_nonstd_tspace(drnt_file,drnt_mode)
   DECLARE drnt_nonstd_found = i2 WITH protect, noconstant(0)
   SELECT
    IF (drnt_mode=0)
     FROM (dummyt d  WITH seq = ddtsp->tsp_cnt)
     WHERE (ddtsp->qual[d.seq].nonstd_tgt_ind=1)
    ELSE
     FROM (dummyt d  WITH seq = ddtsp->tsp_cnt)
     WHERE (ddtsp->qual[d.seq].nonstd_ind=1)
    ENDIF
    INTO value(drnt_file)
    HEAD REPORT
     row + 2,
     CALL center("Unsupported Tablespace Configuration Report",1,126), row + 2,
     col 1,
     "The following tablespaces have been found with an unsupported configuration in the current database.",
     row + 2
    DETAIL
     col 1, "Tablespace Name:", col 20,
     ddtsp->qual[d.seq].tspace_name, row + 1, col 11,
     "Issue:"
     IF ((ddtsp->qual[d.seq].lmt_ora8_ind=1))
      col 20, "Tablespace is locally managed on Oracle 8", row + 1,
      drnt_nonstd_found = 1
     ENDIF
     IF ((ddtsp->qual[d.seq].lmt_uniform_ind=1))
      col 20, "Tablespace is locally managed with uniform extents", row + 1,
      drnt_nonstd_found = 1
     ENDIF
     IF ((ddtsp->qual[d.seq].lmt_and_not_assm=1))
      col 20, "Tablespace is locally managed without automatic segment-space management", row + 1,
      drnt_nonstd_found = 1
     ENDIF
     IF ((ddtsp->qual[d.seq].datafile_not_ae=1))
      col 20, "Tablespace contains datafiles that are not autoextensible", row + 1,
      drnt_nonstd_found = 1
     ENDIF
     IF (ddtsp->qual[d.seq].datafile_not_unlimited)
      col 20, "Tablespace contains datafiles defined with a limited maxsize (not UNLIMITED)", row + 1,
      drnt_nonstd_found = 1
     ENDIF
     row + 2
    FOOT REPORT
     IF (drnt_nonstd_found=0)
      col 1, "No unsupported tablespaces returned.", row + 1
     ENDIF
    WITH nocounter, format = variable, nullreport,
     formfeed = none, maxcol = 512, append
   ;end select
   IF (check_error("Displaying Unsupported Tablespace Configuration Report") != 0)
    CALL disp_msg(" ",dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_eval_nonstd_tgt_tspace(sbr_tsp_idx)
  IF ((ddtsp->qual[sbr_tsp_idx].nonstd_ind=1))
   SET ddtsp->qual[sbr_tsp_idx].nonstd_tgt_ind = 1
   SET ddtsp->nonstd_tgt_ind = 1
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_adj_init_next_ext(daine_data_to_move,daine_table_type,daine_table_name,daine_init_ext,
  daine_next_ext)
   IF (daine_next_ext=0.0)
    SET daine_init_ext = 0.0
   ENDIF
   IF (daine_data_to_move="REF"
    AND daine_table_type=0
    AND daine_init_ext > 0.0)
    SET daine_init_ext = dmt_min_ext_size
   ENDIF
   IF (((daine_data_to_move="REF"
    AND daine_table_type IN (1, 2)) OR (daine_data_to_move="ALL"))
    AND daine_init_ext > 0.0
    AND (daine_init_ext > (5 * dm2_block_size)))
    SET daine_init_ext = dm2_adj_size(daine_init_ext,(5 * dm2_block_size))
   ENDIF
   IF (daine_data_to_move="REF"
    AND daine_table_type=0
    AND daine_next_ext > 0.0)
    SET daine_next_ext = dmt_min_ext_size
   ENDIF
   IF (((daine_data_to_move="REF"
    AND daine_table_type IN (1, 2)) OR (daine_data_to_move="ALL"))
    AND daine_next_ext > 0.0
    AND (daine_next_ext > (5 * dm2_block_size)))
    SET daine_next_ext = dm2_adj_size(daine_next_ext,(5 * dm2_block_size))
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE dtr_load_tspaces(dlt_process)
   DECLARE dlt_fatal_error = i2 WITH protect, noconstant(0)
   DECLARE dlt_ndx = i2 WITH protect, noconstant(0)
   DECLARE dlt_31g = f8 WITH protect, noconstant((((31.0 * 1024.0) * 1024.0) * 1024.0))
   IF (dm2_get_rdbms_version(null)=0)
    GO TO exit_script
   ENDIF
   SET dm_err->eproc = "Load tablespace content."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT
    IF (dlt_process="CLIN COPY")
     FROM dm2_dba_tablespaces dbt
    ELSEIF (dlt_process="REPORT")
     FROM dm2_dba_tablespaces dbt
     WHERE dbt.tablespace_name != "SYSTEM"
      AND  NOT (dbt.contents IN ("UNDO", "TEMPORARY"))
    ELSEIF ( NOT (currdbuser IN ("V500", "CDBA")))
     FROM dm2_dba_tablespaces dbt
     WHERE ((dbt.status = null) OR (dbt.status != "OFFLINE"))
    ELSE
     FROM dm2_dba_tablespaces dbt
     WHERE ((dbt.status = null) OR (dbt.status != "OFFLINE"))
      AND substring(1,2,dbt.tablespace_name) IN ("D_", "I_", "L_")
    ENDIF
    INTO "nl:"
    HEAD REPORT
     ddtsp->nonstd_ind = 0, ddtsp->nonstd_tgt_ind = 0, ddtsp->tsp_cnt = 0
    DETAIL
     IF (dlt_fatal_error=0)
      ddtsp->tsp_cnt = (ddtsp->tsp_cnt+ 1)
      IF (mod(ddtsp->tsp_cnt,50)=1)
       stat = alterlist(ddtsp->qual,(ddtsp->tsp_cnt+ 49))
      ENDIF
      CASE (trim(dbt.extent_management))
       OF "DICTIONARY":
        ddtsp->qual[ddtsp->tsp_cnt].ext_mgmt = "D"
       OF "LOCAL":
        ddtsp->qual[ddtsp->tsp_cnt].ext_mgmt = "L"
       ELSE
        ddtsp->qual[ddtsp->tsp_cnt].ext_mgmt = " ",
        IF (currdb="ORACLE")
         dlt_fatal_error = 1
        ENDIF
      ENDCASE
      ddtsp->qual[ddtsp->tsp_cnt].tspace_name = trim(dbt.tablespace_name), ddtsp->qual[ddtsp->tsp_cnt
      ].alloc_type = trim(dbt.allocation_type), ddtsp->qual[ddtsp->tsp_cnt].seg_space_mgmt = dbt
      .segment_space_management,
      ddtsp->qual[ddtsp->tsp_cnt].nonstd_ind = 0, ddtsp->qual[ddtsp->tsp_cnt].nonstd_tgt_ind = 0,
      ddtsp->qual[ddtsp->tsp_cnt].lmt_ora8_ind = 0,
      ddtsp->qual[ddtsp->tsp_cnt].lmt_uniform_ind = 0, ddtsp->qual[ddtsp->tsp_cnt].lmt_and_not_assm
       = 0, ddtsp->qual[ddtsp->tsp_cnt].lmt_uniform_ind = 0,
      ddtsp->qual[ddtsp->tsp_cnt].lmt_bigfile = 0, ddtsp->qual[ddtsp->tsp_cnt].datafile_not_assm = 0,
      ddtsp->qual[ddtsp->tsp_cnt].datafile_not_unlimited = 0,
      ddtsp->qual[ddtsp->tsp_cnt].lmt_and_not_ae = 0
      IF ((ddtsp->qual[ddtsp->tsp_cnt].ext_mgmt="L")
       AND (dm2_rdbms_version->level1=8))
       ddtsp->qual[ddtsp->tsp_cnt].nonstd_ind = 1, ddtsp->qual[ddtsp->tsp_cnt].lmt_ora8_ind = 1,
       ddtsp->nonstd_ind = 1
      ENDIF
      IF ((ddtsp->qual[ddtsp->tsp_cnt].ext_mgmt="L")
       AND (ddtsp->qual[ddtsp->tsp_cnt].alloc_type="UNIFORM"))
       ddtsp->qual[ddtsp->tsp_cnt].nonstd_ind = 1, ddtsp->qual[ddtsp->tsp_cnt].lmt_uniform_ind = 1,
       ddtsp->nonstd_ind = 1
      ENDIF
      IF ((ddtsp->qual[ddtsp->tsp_cnt].ext_mgmt="L")
       AND (ddtsp->qual[ddtsp->tsp_cnt].seg_space_mgmt != "AUTO"))
       ddtsp->qual[ddtsp->tsp_cnt].lmt_and_not_assm = 1, ddtsp->qual[ddtsp->tsp_cnt].nonstd_ind = 1,
       ddtsp->nonstd_ind = 1
      ENDIF
      IF ((ddtsp->qual[ddtsp->tsp_cnt].ext_mgmt="L")
       AND dbt.bigfile="YES")
       ddtsp->qual[ddtsp->tsp_cnt].lmt_bigfile = 1, ddtsp->qual[ddtsp->tsp_cnt].nonstd_ind = 1, ddtsp
       ->nonstd_ind = 1
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(ddtsp->qual,ddtsp->tsp_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 10))
    CALL echorecord(ddtsp)
   ENDIF
   IF (dlt_fatal_error=1)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Unknown extent_management value returned from dm2_dba_tablespaces"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dir_storage_misc->tgt_storage_type="ASM"))
    SET dm_err->eproc = "Load datafile content."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SELECT
     IF ((dm2_install_schema->process_option="CLIN COPY"))
      FROM dm2_dba_data_files dbt
     ELSE
      FROM dm2_dba_data_files dbt
      WHERE substring(1,2,dbt.tablespace_name) IN ("D_", "I_", "L_")
       AND ((dbt.autoextensible="NO") OR (dbt.maxbytes < dlt_31g))
     ENDIF
     INTO "nl:"
     ORDER BY dbt.tablespace_name
     HEAD dbt.tablespace_name
      dlt_ndx = locateval(dlt_ndx,1,ddtsp->tsp_cnt,dbt.tablespace_name,ddtsp->qual[dlt_ndx].
       tspace_name)
      IF (dlt_ndx > 0)
       IF (dbt.autoextensible="NO")
        ddtsp->qual[dlt_ndx].nonstd_ind = 1, ddtsp->qual[dlt_ndx].datafile_not_ae = 1, ddtsp->
        nonstd_ind = 1
       ENDIF
       IF (dbt.maxbytes < dlt_31g)
        ddtsp->qual[dlt_ndx].nonstd_ind = 1, ddtsp->qual[dlt_ndx].datafile_not_unlimited = 1, ddtsp->
        nonstd_ind = 1
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_load_clin_tspaces(null)
   DECLARE dlt_ndx = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Load 'clinical' tablespace content."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT DISTINCT INTO "nl:"
    tspace_name = d.data_tablespace
    FROM dm_ts_precedence d
    WHERE ((d.owner="V500") UNION (
    (SELECT DISTINCT
     tspace_name = i.index_tablespace
     FROM dm_ts_precedence i
     WHERE ((i.owner="V500") UNION (
     (SELECT DISTINCT
      tspace_name = l.long_tablespace
      FROM dm_ts_precedence l
      WHERE l.owner="V500"))) )))
    ORDER BY tspace_name
    HEAD REPORT
     dtrt->cnt = 0
    DETAIL
     dtrt->cnt = (dtrt->cnt+ 1)
     IF (mod(dtrt->cnt,50)=1)
      stat = alterlist(dtrt->qual,(dtrt->cnt+ 49))
     ENDIF
     dtrt->qual[dtrt->cnt].tspace_name = trim(tspace_name)
    FOOT REPORT
     stat = alterlist(dtrt->qual,dtrt->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Load 'clinical' tablespace mapping content."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT DISTINCT INTO "nl:"
    d.info_char
    FROM dm_info d
    WHERE d.info_domain="DM2_TABLESPACE_MAPPING"
    ORDER BY d.info_char
    DETAIL
     dtrt->cnt = (dtrt->cnt+ 1), stat = alterlist(dtrt->qual,dtrt->cnt), dtrt->qual[dtrt->cnt].
     tspace_name = trim(d.info_char)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(dtrt)
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE dm2ss_dminfolog(dd_info_domain=vc,dd_info_name=vc,dd_info_char=vc,dd_info_date=dq8) = i2
 DECLARE dm2ss_new_collection_setup(dncs_report_name=vc,dncs_report_event_id=f8(ref)) = i2
 DECLARE dm2ss_verify_synonym(null) = i2
 SUBROUTINE dm2ss_dminfolog(dd_info_domain,dd_info_name,dd_info_char,dd_info_date)
   DECLARE dd_old_eproc = vc WITH protect, constant(dm_err->eproc)
   DECLARE dd_old_emsg = vc WITH protect, constant(dm_err->emsg)
   DECLARE dd_old_err_ind = i2 WITH protect, constant(dm_err->err_ind)
   SET dm_err->emsg = ""
   SET dm_err->err_ind = 0
   SET dm_err->eproc = "Selecting from dm_info to see if row exists."
   SELECT INTO "nl:"
    FROM dm_info
    WHERE info_domain=dd_info_domain
     AND info_name=dd_info_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->eproc = dd_old_eproc
    SET dm_err->emsg = dd_old_emsg
    SET dm_err->err_ind = dd_old_err_ind
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dm_err->eproc = "Updating into dm_info."
    UPDATE  FROM dm_info di
     SET di.info_char = dd_info_char, di.info_date = cnvtdatetime(dd_info_date), di.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      di.updt_cnt = (di.updt_cnt+ 1), di.updt_task = reqinfo->updt_task, di.updt_applctx = reqinfo->
      updt_applctx,
      di.updt_id = reqinfo->updt_id
     WHERE info_domain=dd_info_domain
      AND info_name=dd_info_name
    ;end update
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->eproc = dd_old_eproc
     SET dm_err->emsg = dd_old_emsg
     SET dm_err->err_ind = dd_old_err_ind
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->eproc = "Inserting into dm_info."
    INSERT  FROM dm_info di
     SET di.info_domain = dd_info_domain, di.info_name = dd_info_name, di.info_char = dd_info_char,
      di.info_date = cnvtdatetime(dd_info_date), di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di
      .updt_cnt = 0,
      di.updt_task = reqinfo->updt_task, di.updt_applctx = reqinfo->updt_applctx, di.updt_id =
      reqinfo->updt_id
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->eproc = dd_old_eproc
     SET dm_err->emsg = dd_old_emsg
     SET dm_err->err_ind = dd_old_err_ind
     RETURN(0)
    ENDIF
   ENDIF
   COMMIT
   SET dm_err->eproc = dd_old_eproc
   SET dm_err->emsg = dd_old_emsg
   SET dm_err->err_ind = dd_old_err_ind
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2ss_new_collection_setup(dncs_report_name,dncs_report_event_id)
   DECLARE dncs_report_id = f8 WITH protect, noconstant(0.0)
   DECLARE dncs_env_id = f8 WITH protect, noconstant(0.0)
   DECLARE dncs_requestor_os = vc WITH protect, noconstant(" ")
   DECLARE dncs_instance_id = f8 WITH protect, noconstant(0.0)
   IF (dm2ss_verify_synonym(null)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Checking to see if the dncs_report_name passed in exists in ref_user_report."
   SELECT INTO "nl:"
    FROM ref_user_report rur
    WHERE rur.report_name=dncs_report_name
     AND rur.report_cd=1
    DETAIL
     dncs_report_id = rur.report_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->emsg = concat("The report name [",build(dncs_report_name),
     "] doesn't exists in ref_user_report.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    CALL dm2ss_dminfolog("DM2_SPACE_SUMMARY",dncs_report_name,dm_err->emsg,cnvtdatetime(curdate,
      curtime3))
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Generating a row in ref_report_event for this report."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="DM_ENV_ID"
    DETAIL
     dncs_env_id = di.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM v$session vs
    WHERE vs.sid IN (
    (SELECT
     vm.sid
     FROM v$mystat vm))
    DETAIL
     dncs_requestor_os = vs.osuser
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    y = seq(report_sequence,nextval)
    FROM dual
    DETAIL
     dncs_report_event_id = y
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM ref_instance_id rii
    WHERE rii.environment_id=dncs_env_id
    DETAIL
     dncs_instance_id = rii.instance_cd
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   INSERT  FROM ref_report_event rre
    SET rre.report_event_id = dncs_report_event_id, rre.report_name = dncs_report_name, rre.report_cd
      = 1,
     rre.environment_id = dncs_env_id, rre.instance_id = dncs_instance_id, rre.status = null,
     rre.status_message = null, rre.begin_dt_tm = cnvtdatetime(curdate,curtime3), rre.end_dt_tm =
     null,
     rre.requestor_os = dncs_requestor_os, rre.updt_dt_tm = cnvtdatetime(curdate,curtime3), rre
     .updt_cnt = 0,
     rre.updt_task = reqinfo->updt_task, rre.updt_applctx = reqinfo->updt_applctx, rre.updt_id =
     reqinfo->updt_id
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   SET dm_err->eproc =
   "Generating a row in ref_report_event_parms for each row in ref_user_report_parms for this particular report."
   INSERT  FROM ref_report_event_parms rrep
    (rrep.report_event_parm_id, rrep.report_event_id, rrep.parm_cd,
    rrep.parm_seq, rrep.parm_value, rrep.updt_dt_tm,
    rrep.updt_cnt, rrep.updt_task, rrep.updt_applctx,
    rrep.updt_id)(SELECT
     seq(report_sequence,nextval), dncs_report_event_id, rurp.parm_cd,
     rurp.parm_seq, rurp.parm_value, cnvtdatetime(curdate,curtime3),
     0, reqinfo->updt_task, reqinfo->updt_applctx,
     reqinfo->updt_id
     FROM ref_user_report_parms rurp
     WHERE rurp.report_id=dncs_report_id)
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2ss_verify_synonym(null)
   SET dm_err->eproc =
   "Verifying that the report_sequence public synonym exists in dm2_dba_synonyms."
   SELECT INTO "nl:"
    FROM dm2_dba_synonyms
    WHERE synonym_name="REPORT_SEQUENCE"
     AND owner="PUBLIC"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    EXECUTE dm2_create_admin_nicknames "REPORT_SEQUENCE", "NONE"
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 FREE RECORD report_event
 RECORD report_event(
   1 parm_cnt = i4
   1 parms[*]
     2 parm_cd = f8
     2 parm_value = vc
 )
 SET report_event->parm_cnt = 0
 FREE RECORD table_stats
 RECORD table_stats(
   1 table_cnt = i4
   1 tables[*]
     2 table_name = vc
     2 num_rows = f8
     2 num_rows_null_ind = i2
     2 last_analyzed = dq8
     2 monitoring = vc
     2 table_mods = f8
 )
 SET table_stats->table_cnt = 0
 FREE RECORD tablespace_stats
 RECORD tablespace_stats(
   1 tablespace_cnt = i4
   1 tablespaces[*]
     2 tablespace_name = vc
     2 extent_management = vc
     2 segment_space_management = vc
     2 num_objects = f8
     2 total_extents = f8
     2 blocks_free = f8
     2 blocks_allocated = f8
     2 pct_free = f8
     2 max_alloc_next_ext_blocks = f8
     2 num_free_chunks = f8
     2 max_free_chunk_size = f8
     2 status = vc
     2 contents = vc
 )
 SET tablespace_stats->tablespace_cnt = 0
 FREE RECORD object_stats
 RECORD object_stats(
   1 object_cnt = i4
   1 objects[*]
     2 tablespace_name = vc
     2 object_name = vc
     2 object_type = vc
     2 next_extent_size_blocks = f8
     2 max_alloc_next_ext_blocks = f8
     2 extents_allocated = f8
     2 max_extents = f8
     2 blocks_allocated = f8
     2 num_rows = f8
     2 num_rows_null_ind = i2
     2 last_analyzed = dq8
     2 monitoring = vc
     2 table_mods = f8
     2 table_name = vc
 )
 SET object_stats->object_cnt = 0
 FREE RECORD file_stats
 RECORD file_stats(
   1 file_cnt = i4
   1 files[*]
     2 tablespace_name = vc
     2 file_id = f8
     2 blocks_allocated = f8
     2 blocks_free = f8
     2 num_free_chunks = f8
     2 max_free_chunk_size = f8
     2 file_name = vc
     2 status = vc
     2 autoextensible = vc
 )
 SET file_stats->file_cnt = 0
 DECLARE dss_collection_name = vc WITH protect, noconstant(" ")
 DECLARE dss_collection_id = f8 WITH protect, noconstant(0.0)
 DECLARE dss_where_clause = vc WITH protect, noconstant(" ")
 DECLARE dss_instance_id = f8 WITH protect, noconstant(0.0)
 DECLARE dss_forcount = i4 WITH protect, noconstant(0)
 DECLARE dss_locateval = i4 WITH protect, noconstant(0)
 DECLARE dss_locateval_temp = i4 WITH protect, noconstant(0)
 DECLARE dss_cur_tablespace = i4 WITH protect, noconstant(0)
 DECLARE dss_row_exists = i2 WITH protect, noconstant(0)
 DECLARE dss_old_eproc = vc WITH protect, noconstant(" ")
 DECLARE dss_old_emsg = vc WITH protect, noconstant(" ")
 SET dss_collection_name =  $1
 IF (check_logfile("dm2_space_summary",".log","DM2_SPACE_SUMMARY LOGFILE")=0)
  IF (dm2ss_dminfolog("DM2_SPACE_SUMMARY",dss_collection_name,dm_err->emsg,cnvtdatetime(curdate,
    curtime3))=0)
   GO TO exit_script
  ENDIF
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Beginning DM2_SPACE_SUMMARY"
 CALL disp_msg(" ",dm_err->logfile,0)
 IF (currdbuser != "V500")
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "DM2_SPACE_SUMMARY can only be run under 'V500'"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  IF (dm2ss_dminfolog("DM2_SPACE_SUMMARY",dss_collection_name,dm_err->emsg,cnvtdatetime(curdate,
    curtime3))=0)
   GO TO exit_script
  ENDIF
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Creating a new report_event for this space summary."
 IF (dm2ss_new_collection_setup(dss_collection_name,dss_collection_id)=0)
  SET dss_row_exists = 0
  IF (dm2ss_dminfolog("DM2_SPACE_SUMMARY",dss_collection_name,dm_err->emsg,cnvtdatetime(curdate,
    curtime3))=0)
   GO TO exit_script
  ENDIF
  GO TO exit_script
 ENDIF
 SET dss_row_exists = 1
 SET dm_err->eproc = "Update the ref_report_event.status = 'RUNNING'"
 UPDATE  FROM ref_report_event rre
  SET rre.status = "RUNNING", rre.begin_dt_tm = cnvtdatetime(curdate,curtime3), rre.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   rre.updt_cnt = (rre.updt_cnt+ 1), rre.updt_task = reqinfo->updt_task, rre.updt_applctx = reqinfo->
   updt_applctx,
   rre.updt_id = reqinfo->updt_id
  WHERE rre.report_event_id=dss_collection_id
  WITH nocounter
 ;end update
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  IF (dm2ss_dminfolog("DM2_SPACE_SUMMARY",dss_collection_name,dm_err->emsg,cnvtdatetime(curdate,
    curtime3))=0)
   GO TO exit_script
  ENDIF
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Get the instance_id for the environment_id for the current environment."
 SELECT INTO "nl:"
  rii.instance_cd
  FROM ref_instance_id rii,
   dm_info di
  WHERE rii.environment_id=di.info_number
   AND di.info_domain="DATA MANAGEMENT"
   AND di.info_name="DM_ENV_ID"
  DETAIL
   dss_instance_id = rii.instance_cd
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  EXECUTE dm2_ss_setup
  IF ((dm_err->err_ind=1))
   GO TO exit_script
  ENDIF
 ENDIF
 SET dm_err->eproc = "Build user where clause criteria for space gathering."
 SELECT INTO "nl:"
  FROM ref_report_event_parms rrep
  WHERE rrep.report_event_id=dss_collection_id
  HEAD REPORT
   report_event->parm_cnt = 0
  DETAIL
   report_event->parm_cnt = (report_event->parm_cnt+ 1), stat = alterlist(report_event->parms,
    report_event->parm_cnt), report_event->parms[report_event->parm_cnt].parm_value = rrep.parm_value,
   report_event->parms[report_event->parm_cnt].parm_cd = rrep.parm_cd
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 CASE (report_event->parms[1].parm_cd)
  OF 3:
   SET dss_where_clause = concat(dss_where_clause,"dt.tablespace_name = patstring('",report_event->
    parms[1].parm_value,"')")
 ENDCASE
 FOR (dss_forcount = 2 TO report_event->parm_cnt)
   CASE (report_event->parms[dss_forcount].parm_cd)
    OF 3:
     SET dss_where_clause = concat(dss_where_clause," OR dt.tablespace_name = patstring('",
      report_event->parms[dss_forcount].parm_value,"')")
   ENDCASE
 ENDFOR
 SET dm_err->eproc = "Gather Table statistics data"
 SELECT INTO "nl:"
  ut.table_name, ut.num_rows, ut.last_analyzed,
  ut.monitoring, table_mods = nullval(((utm.inserts+ utm.updates)+ utm.deletes),0.0),
  num_rows_null_ind = nullind(ut.num_rows)
  FROM dm_user_tables_actual_stats ut,
   user_tab_modifications utm
  WHERE outerjoin(ut.table_name)=utm.table_name
  ORDER BY ut.table_name
  HEAD REPORT
   table_stats->table_cnt = 0
  DETAIL
   table_stats->table_cnt = (table_stats->table_cnt+ 1)
   IF (mod(table_stats->table_cnt,100)=1)
    stat = alterlist(table_stats->tables,(table_stats->table_cnt+ 99))
   ENDIF
   table_stats->tables[table_stats->table_cnt].table_name = ut.table_name, table_stats->tables[
   table_stats->table_cnt].num_rows = ut.num_rows, table_stats->tables[table_stats->table_cnt].
   num_rows_null_ind = num_rows_null_ind,
   table_stats->tables[table_stats->table_cnt].last_analyzed = ut.last_analyzed, table_stats->tables[
   table_stats->table_cnt].monitoring = ut.monitoring, table_stats->tables[table_stats->table_cnt].
   table_mods = table_mods
  FOOT REPORT
   stat = alterlist(table_stats->tables,table_stats->table_cnt)
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Gather Tablespaces data"
 SELECT DISTINCT INTO "nl:"
  dt.tablespace_name
  FROM dba_tablespaces dt
  WHERE parser(dss_where_clause)
  ORDER BY dt.tablespace_name
  HEAD REPORT
   dss_cur_tablespace = 0
  DETAIL
   dss_cur_tablespace = (dss_cur_tablespace+ 1)
   IF (mod(dss_cur_tablespace,20)=1)
    stat = alterlist(tablespace_stats->tablespaces,(dss_cur_tablespace+ 19))
   ENDIF
   tablespace_stats->tablespaces[dss_cur_tablespace].tablespace_name = dt.tablespace_name,
   tablespace_stats->tablespaces[dss_cur_tablespace].extent_management = dt.extent_management,
   tablespace_stats->tablespaces[dss_cur_tablespace].segment_space_management = validate(dt
    .segment_space_management," "),
   tablespace_stats->tablespaces[dss_cur_tablespace].num_objects = 0, tablespace_stats->tablespaces[
   dss_cur_tablespace].total_extents = 0, tablespace_stats->tablespaces[dss_cur_tablespace].
   blocks_free = 0,
   tablespace_stats->tablespaces[dss_cur_tablespace].blocks_allocated = 0, tablespace_stats->
   tablespaces[dss_cur_tablespace].pct_free = 0, tablespace_stats->tablespaces[dss_cur_tablespace].
   max_alloc_next_ext_blocks = 0,
   tablespace_stats->tablespaces[dss_cur_tablespace].num_free_chunks = 0, tablespace_stats->
   tablespaces[dss_cur_tablespace].max_free_chunk_size = 0, tablespace_stats->tablespaces[
   dss_cur_tablespace].status = dt.status,
   tablespace_stats->tablespaces[dss_cur_tablespace].contents = dt.contents
  FOOT REPORT
   stat = alterlist(tablespace_stats->tablespaces,dss_cur_tablespace), tablespace_stats->
   tablespace_cnt = dss_cur_tablespace
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Populate table objects and adjust tablespaces stats for tables."
 SELECT INTO "nl:"
  FROM dba_segments ds,
   dba_extents de
  WHERE ds.segment_name=de.segment_name
   AND ds.segment_type=cnvtupper("TABLE")
  ORDER BY ds.tablespace_name, ds.owner, ds.segment_name,
   de.extent_id
  HEAD ds.tablespace_name
   dss_cur_tablespace = 0, dss_cur_tablespace = locateval(dss_locateval_temp,1,tablespace_stats->
    tablespace_cnt,ds.tablespace_name,tablespace_stats->tablespaces[dss_locateval_temp].
    tablespace_name), dss_locateval = 0
  HEAD ds.segment_name
   IF (dss_cur_tablespace > 0)
    IF (ds.owner=value(currdbuser))
     object_stats->object_cnt = (object_stats->object_cnt+ 1)
     IF (mod(object_stats->object_cnt,100)=1)
      stat = alterlist(object_stats->objects,(object_stats->object_cnt+ 99))
     ENDIF
     object_stats->objects[object_stats->object_cnt].tablespace_name = ds.tablespace_name,
     object_stats->objects[object_stats->object_cnt].object_name = ds.segment_name, object_stats->
     objects[object_stats->object_cnt].object_type = ds.segment_type,
     object_stats->objects[object_stats->object_cnt].next_extent_size_blocks = dm2_adj_size((ds
      .next_extent/ dm2_block_size),5.0), object_stats->objects[object_stats->object_cnt].
     extents_allocated = ds.extents, object_stats->objects[object_stats->object_cnt].max_extents = ds
     .max_extents,
     object_stats->objects[object_stats->object_cnt].blocks_allocated = ds.blocks, object_stats->
     objects[object_stats->object_cnt].table_name = ds.segment_name, dss_locateval = locateval(
      dss_locateval_temp,1,table_stats->table_cnt,ds.segment_name,table_stats->tables[
      dss_locateval_temp].table_name)
     IF (dss_locateval > 0)
      object_stats->objects[object_stats->object_cnt].num_rows = table_stats->tables[dss_locateval].
      num_rows, object_stats->objects[object_stats->object_cnt].num_rows_null_ind = table_stats->
      tables[dss_locateval].num_rows_null_ind, object_stats->objects[object_stats->object_cnt].
      last_analyzed = table_stats->tables[dss_locateval].last_analyzed,
      object_stats->objects[object_stats->object_cnt].monitoring = table_stats->tables[dss_locateval]
      .monitoring, object_stats->objects[object_stats->object_cnt].table_mods = table_stats->tables[
      dss_locateval].table_mods
     ELSE
      dm_err->err_ind = 1, dm_err->emsg = "Segment_name not matching any table names."
     ENDIF
    ENDIF
    tablespace_stats->tablespaces[dss_cur_tablespace].num_objects = (tablespace_stats->tablespaces[
    dss_cur_tablespace].num_objects+ 1), tablespace_stats->tablespaces[dss_cur_tablespace].
    total_extents = (tablespace_stats->tablespaces[dss_cur_tablespace].total_extents+ ds.extents),
    tablespace_stats->tablespaces[dss_cur_tablespace].blocks_allocated = (tablespace_stats->
    tablespaces[dss_cur_tablespace].blocks_allocated+ ds.blocks)
   ENDIF
  DETAIL
   IF (dss_cur_tablespace > 0)
    IF ((tablespace_stats->tablespaces[dss_cur_tablespace].extent_management="LOCAL"))
     IF (de.extent_id > 0)
      tablespace_stats->tablespaces[dss_cur_tablespace].max_alloc_next_ext_blocks = greatest(
       tablespace_stats->tablespaces[dss_cur_tablespace].max_alloc_next_ext_blocks,de.blocks)
      IF (ds.owner=value(currdbuser))
       object_stats->objects[object_stats->object_cnt].max_alloc_next_ext_blocks = greatest(
        object_stats->objects[object_stats->object_cnt].max_alloc_next_ext_blocks,de.blocks)
      ENDIF
     ENDIF
    ELSE
     tablespace_stats->tablespaces[dss_cur_tablespace].max_alloc_next_ext_blocks = greatest(
      tablespace_stats->tablespaces[dss_cur_tablespace].max_alloc_next_ext_blocks,dm2_adj_size((ds
       .next_extent/ dm2_block_size),5.0))
     IF (ds.owner=value(currdbuser))
      object_stats->objects[object_stats->object_cnt].max_alloc_next_ext_blocks = object_stats->
      objects[object_stats->object_cnt].next_extent_size_blocks
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Populate index objects and adjust tablespaces stats for indexes."
 SELECT INTO "nl:"
  num_rows_null_ind = nullind(di.num_rows)
  FROM dba_segments ds,
   dba_extents de,
   dm_dba_indexes_actual_stats di
  WHERE ds.segment_name=de.segment_name
   AND di.index_name=ds.segment_name
   AND ds.segment_type=cnvtupper("INDEX")
  ORDER BY ds.tablespace_name, ds.owner, di.index_name,
   de.extent_id
  HEAD ds.tablespace_name
   dss_cur_tablespace = 0, dss_cur_tablespace = locateval(dss_locateval_temp,1,tablespace_stats->
    tablespace_cnt,ds.tablespace_name,tablespace_stats->tablespaces[dss_locateval_temp].
    tablespace_name), dss_locateval = 0
  HEAD di.index_name
   IF (dss_cur_tablespace > 0)
    IF (ds.owner=value(currdbuser))
     object_stats->object_cnt = (object_stats->object_cnt+ 1)
     IF (mod(object_stats->object_cnt,100)=1)
      stat = alterlist(object_stats->objects,(object_stats->object_cnt+ 99))
     ENDIF
     object_stats->objects[object_stats->object_cnt].tablespace_name = ds.tablespace_name,
     object_stats->objects[object_stats->object_cnt].object_name = ds.segment_name, object_stats->
     objects[object_stats->object_cnt].object_type = ds.segment_type,
     object_stats->objects[object_stats->object_cnt].next_extent_size_blocks = dm2_adj_size((ds
      .next_extent/ dm2_block_size),5.0), object_stats->objects[object_stats->object_cnt].
     extents_allocated = ds.extents, object_stats->objects[object_stats->object_cnt].max_extents = ds
     .max_extents,
     object_stats->objects[object_stats->object_cnt].blocks_allocated = ds.blocks, object_stats->
     objects[object_stats->object_cnt].table_name = di.table_name, object_stats->objects[object_stats
     ->object_cnt].num_rows = di.num_rows,
     object_stats->objects[object_stats->object_cnt].num_rows_null_ind = num_rows_null_ind,
     object_stats->objects[object_stats->object_cnt].last_analyzed = di.last_analyzed, dss_locateval
      = locateval(dss_locateval_temp,1,table_stats->table_cnt,di.table_name,table_stats->tables[
      dss_locateval_temp].table_name)
     IF (dss_locateval > 0)
      object_stats->objects[object_stats->object_cnt].monitoring = table_stats->tables[dss_locateval]
      .monitoring, object_stats->objects[object_stats->object_cnt].table_mods = table_stats->tables[
      dss_locateval].table_mods
     ELSE
      dm_err->err_ind = 1, dm_err->emsg = "Segment_name not matching any table names."
     ENDIF
    ENDIF
    tablespace_stats->tablespaces[dss_cur_tablespace].num_objects = (tablespace_stats->tablespaces[
    dss_cur_tablespace].num_objects+ 1), tablespace_stats->tablespaces[dss_cur_tablespace].
    total_extents = (tablespace_stats->tablespaces[dss_cur_tablespace].total_extents+ ds.extents),
    tablespace_stats->tablespaces[dss_cur_tablespace].blocks_allocated = (tablespace_stats->
    tablespaces[dss_cur_tablespace].blocks_allocated+ ds.blocks)
   ENDIF
  DETAIL
   IF (dss_cur_tablespace > 0)
    IF ((tablespace_stats->tablespaces[dss_cur_tablespace].extent_management="LOCAL"))
     IF (de.extent_id > 0)
      tablespace_stats->tablespaces[dss_cur_tablespace].max_alloc_next_ext_blocks = greatest(
       tablespace_stats->tablespaces[dss_cur_tablespace].max_alloc_next_ext_blocks,de.blocks)
      IF (ds.owner=value(currdbuser))
       object_stats->objects[object_stats->object_cnt].max_alloc_next_ext_blocks = greatest(
        object_stats->objects[object_stats->object_cnt].max_alloc_next_ext_blocks,de.blocks)
      ENDIF
     ENDIF
    ELSE
     tablespace_stats->tablespaces[dss_cur_tablespace].max_alloc_next_ext_blocks = greatest(
      tablespace_stats->tablespaces[dss_cur_tablespace].max_alloc_next_ext_blocks,dm2_adj_size((ds
       .next_extent/ dm2_block_size),5.0))
     IF (ds.owner=value(currdbuser))
      object_stats->objects[object_stats->object_cnt].max_alloc_next_ext_blocks = object_stats->
      objects[object_stats->object_cnt].next_extent_size_blocks
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Populate LOB objects and adjust tablespaces stats for LOBs."
 SELECT INTO "nl:"
  FROM dba_segments ds,
   dba_extents de,
   dba_lobs dl
  WHERE ds.segment_name=de.segment_name
   AND ((dl.segment_name=ds.segment_name) OR (dl.index_name=ds.segment_name))
   AND ((ds.segment_type=cnvtupper("LOBSEGMENT")) OR (ds.segment_type=cnvtupper("LOBINDEX")))
  ORDER BY ds.tablespace_name, ds.owner, dl.table_name,
   dl.column_name, ds.segment_type DESC, de.extent_id
  HEAD REPORT
   row + 0
  HEAD ds.tablespace_name
   dss_cur_tablespace = 0, dss_cur_tablespace = locateval(dss_locateval_temp,1,tablespace_stats->
    tablespace_cnt,ds.tablespace_name,tablespace_stats->tablespaces[dss_locateval_temp].
    tablespace_name), dss_locateval = 0
  HEAD ds.owner
   row + 0
  HEAD dl.table_name
   row + 0
  HEAD dl.column_name
   IF (dss_cur_tablespace > 0)
    IF (ds.owner=value(currdbuser))
     object_stats->object_cnt = (object_stats->object_cnt+ 1)
     IF (mod(object_stats->object_cnt,20)=1)
      stat = alterlist(object_stats->objects,(object_stats->object_cnt+ 19))
     ENDIF
     object_stats->objects[object_stats->object_cnt].tablespace_name = ds.tablespace_name,
     object_stats->objects[object_stats->object_cnt].object_name = dl.column_name, object_stats->
     objects[object_stats->object_cnt].object_type = concat("LOB COLUMN:",ds.segment_name),
     object_stats->objects[object_stats->object_cnt].next_extent_size_blocks = dm2_adj_size((ds
      .next_extent/ dm2_block_size),5.0), object_stats->objects[object_stats->object_cnt].max_extents
      = ds.max_extents, object_stats->objects[object_stats->object_cnt].table_name = dl.table_name,
     dss_locateval = locateval(dss_locateval_temp,1,table_stats->table_cnt,dl.table_name,table_stats
      ->tables[dss_locateval_temp].table_name)
     IF (dss_locateval > 0)
      object_stats->objects[object_stats->object_cnt].monitoring = table_stats->tables[dss_locateval]
      .monitoring, object_stats->objects[object_stats->object_cnt].table_mods = table_stats->tables[
      dss_locateval].table_mods, object_stats->objects[object_stats->object_cnt].num_rows =
      table_stats->tables[dss_locateval].num_rows,
      object_stats->objects[object_stats->object_cnt].num_rows_null_ind = table_stats->tables[
      dss_locateval].num_rows_null_ind, object_stats->objects[object_stats->object_cnt].last_analyzed
       = table_stats->tables[dss_locateval].last_analyzed
     ELSE
      dm_err->err_ind = 1, dm_err->emsg = "Segment_name not matching any table names."
     ENDIF
    ENDIF
   ENDIF
  HEAD ds.segment_type
   IF (dss_cur_tablespace > 0)
    tablespace_stats->tablespaces[dss_cur_tablespace].num_objects = (tablespace_stats->tablespaces[
    dss_cur_tablespace].num_objects+ 1)
   ENDIF
  DETAIL
   IF (dss_cur_tablespace > 0)
    IF (ds.owner=value(currdbuser))
     object_stats->objects[object_stats->object_cnt].extents_allocated = (object_stats->objects[
     object_stats->object_cnt].extents_allocated+ 1), object_stats->objects[object_stats->object_cnt]
     .blocks_allocated = (object_stats->objects[object_stats->object_cnt].blocks_allocated+ de.blocks
     )
    ENDIF
    tablespace_stats->tablespaces[dss_cur_tablespace].total_extents = (tablespace_stats->tablespaces[
    dss_cur_tablespace].total_extents+ 1), tablespace_stats->tablespaces[dss_cur_tablespace].
    blocks_allocated = (tablespace_stats->tablespaces[dss_cur_tablespace].blocks_allocated+ de.blocks
    )
    IF ((tablespace_stats->tablespaces[dss_cur_tablespace].extent_management="LOCAL"))
     IF (de.extent_id > 0)
      tablespace_stats->tablespaces[dss_cur_tablespace].max_alloc_next_ext_blocks = greatest(
       tablespace_stats->tablespaces[dss_cur_tablespace].max_alloc_next_ext_blocks,de.blocks)
      IF (ds.owner=value(currdbuser))
       object_stats->objects[object_stats->object_cnt].max_alloc_next_ext_blocks = greatest(
        object_stats->objects[object_stats->object_cnt].max_alloc_next_ext_blocks,de.blocks)
      ENDIF
     ENDIF
    ELSE
     tablespace_stats->tablespaces[dss_cur_tablespace].max_alloc_next_ext_blocks = greatest(
      tablespace_stats->tablespaces[dss_cur_tablespace].max_alloc_next_ext_blocks,dm2_adj_size((ds
       .next_extent/ dm2_block_size),5.0))
     IF (ds.owner=value(currdbuser))
      object_stats->objects[object_stats->object_cnt].max_alloc_next_ext_blocks = object_stats->
      objects[object_stats->object_cnt].next_extent_size_blocks
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(object_stats->objects,object_stats->object_cnt)
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Gather Tablespace File_ID data"
 SELECT INTO "nl:"
  FROM dba_data_files ddf
  ORDER BY ddf.tablespace_name, ddf.file_id
  HEAD REPORT
   row + 0
  HEAD ddf.tablespace_name
   dss_cur_tablespace = 0, dss_cur_tablespace = locateval(dss_locateval_temp,1,tablespace_stats->
    tablespace_cnt,ddf.tablespace_name,tablespace_stats->tablespaces[dss_locateval_temp].
    tablespace_name)
  DETAIL
   IF (dss_cur_tablespace > 0)
    file_stats->file_cnt = (file_stats->file_cnt+ 1)
    IF (mod(file_stats->file_cnt,20)=1)
     stat = alterlist(file_stats->files,(file_stats->file_cnt+ 19))
    ENDIF
    file_stats->files[file_stats->file_cnt].tablespace_name = ddf.tablespace_name, file_stats->files[
    file_stats->file_cnt].file_id = ddf.file_id, file_stats->files[file_stats->file_cnt].file_name =
    ddf.file_name,
    file_stats->files[file_stats->file_cnt].status = ddf.status, file_stats->files[file_stats->
    file_cnt].autoextensible = ddf.autoextensible, file_stats->files[file_stats->file_cnt].
    blocks_allocated = ddf.blocks
   ENDIF
  FOOT REPORT
   stat = alterlist(file_stats->files,file_stats->file_cnt)
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Gather Tablespace Free Space and File_ID data."
 SELECT INTO "nl:"
  FROM dba_free_space dfs
  ORDER BY dfs.tablespace_name, dfs.file_id
  HEAD dfs.tablespace_name
   dss_cur_tablespace = 0, dss_cur_tablespace = locateval(dss_locateval_temp,1,tablespace_stats->
    tablespace_cnt,dfs.tablespace_name,tablespace_stats->tablespaces[dss_locateval_temp].
    tablespace_name)
  HEAD dfs.file_id
   dss_locateval = 0
   IF (dss_cur_tablespace > 0)
    dss_locateval = locateval(dss_locateval_temp,1,file_stats->file_cnt,dfs.file_id,file_stats->
     files[dss_locateval_temp].file_id)
   ENDIF
  DETAIL
   IF (dss_cur_tablespace > 0
    AND dss_locateval > 0)
    file_stats->files[dss_locateval].blocks_free = (file_stats->files[dss_locateval].blocks_free+ dfs
    .blocks), file_stats->files[dss_locateval].num_free_chunks = (file_stats->files[dss_locateval].
    num_free_chunks+ 1), file_stats->files[dss_locateval].max_free_chunk_size = greatest(file_stats->
     files[dss_locateval].max_free_chunk_size,dfs.blocks),
    tablespace_stats->tablespaces[dss_cur_tablespace].blocks_free = (tablespace_stats->tablespaces[
    dss_cur_tablespace].blocks_free+ dfs.blocks), tablespace_stats->tablespaces[dss_cur_tablespace].
    num_free_chunks = (tablespace_stats->tablespaces[dss_cur_tablespace].num_free_chunks+ 1),
    tablespace_stats->tablespaces[dss_cur_tablespace].max_free_chunk_size = greatest(tablespace_stats
     ->tablespaces[dss_cur_tablespace].max_free_chunk_size,dfs.blocks)
   ENDIF
  FOOT  dfs.tablespace_name
   IF (dss_cur_tablespace > 0)
    tablespace_stats->tablespaces[dss_cur_tablespace].pct_free = ((tablespace_stats->tablespaces[
    dss_cur_tablespace].blocks_free/ (tablespace_stats->tablespaces[dss_cur_tablespace].blocks_free+
    tablespace_stats->tablespaces[dss_cur_tablespace].blocks_allocated)) * 100)
   ENDIF
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF ((tablespace_stats->tablespace_cnt > 0))
  SET dm_err->eproc = "Insert data into space_files."
  INSERT  FROM space_files sf,
    (dummyt d  WITH seq = value(file_stats->file_cnt))
   SET sf.report_seq = dss_collection_id, sf.instance_cd = dss_instance_id, sf.file_id = file_stats->
    files[d.seq].file_id,
    sf.tablespace_name = file_stats->files[d.seq].tablespace_name, sf.file_name = file_stats->files[d
    .seq].file_name, sf.status = file_stats->files[d.seq].status,
    sf.autoextensible = file_stats->files[d.seq].autoextensible, sf.total_space = file_stats->files[d
    .seq].blocks_allocated, sf.free_space = file_stats->files[d.seq].blocks_free,
    sf.num_chunks = file_stats->files[d.seq].num_free_chunks, sf.max_contig = file_stats->files[d.seq
    ].max_free_chunk_size, sf.min_contig = null,
    sf.avg_contig = null, sf.updt_id = reqinfo->updt_id, sf.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    sf.updt_task = reqinfo->updt_task, sf.updt_applctx = reqinfo->updt_applctx, sf.updt_cnt = 0
   PLAN (d)
    JOIN (sf)
   WITH nocounter, maxcommit = 500
  ;end insert
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  SET dm_err->eproc = "Insert data into space_objects."
  INSERT  FROM space_objects so,
    (dummyt d  WITH seq = value(object_stats->object_cnt))
   SET so.report_seq = dss_collection_id, so.instance_cd = dss_instance_id, so.owner = value(
     currdbuser),
    so.segment_name = object_stats->objects[d.seq].object_name, so.segment_type = object_stats->
    objects[d.seq].object_type, so.tablespace_name = object_stats->objects[d.seq].tablespace_name,
    so.total_space = object_stats->objects[d.seq].blocks_allocated, so.free_space = null, so.extents
     = object_stats->objects[d.seq].extents_allocated,
    so.next_extent = object_stats->objects[d.seq].next_extent_size_blocks, so.pctincrease = null, so
    .row_count = evaluate(object_stats->objects[d.seq].num_rows_null_ind,0,object_stats->objects[d
     .seq].num_rows,null),
    so.pct_free = null, so.next_flag = null, so.free_flag = null,
    so.failure_flag = null, so.analyze_flag = null, so.end_dt_tm = cnvtdatetime(object_stats->
     objects[d.seq].last_analyzed),
    so.max_alloc_next_ext = object_stats->objects[d.seq].max_alloc_next_ext_blocks, so.max_extents =
    object_stats->objects[d.seq].max_extents, so.monitoring = object_stats->objects[d.seq].monitoring,
    so.table_name = object_stats->objects[d.seq].table_name, so.table_mods = evaluate(object_stats->
     objects[d.seq].monitoring,"YES",object_stats->objects[d.seq].table_mods,null), so.updt_id =
    reqinfo->updt_id,
    so.updt_dt_tm = cnvtdatetime(curdate,curtime3), so.updt_task = reqinfo->updt_task, so
    .updt_applctx = reqinfo->updt_applctx,
    so.updt_cnt = 0
   PLAN (d)
    JOIN (so)
   WITH nocounter, maxcommit = 500
  ;end insert
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  SET dm_err->eproc = "Insert data into space_tablespaces."
  INSERT  FROM space_tablespaces st,
    (dummyt d  WITH seq = value(tablespace_stats->tablespace_cnt))
   SET st.report_event_id = dss_collection_id, st.tablespace_name = tablespace_stats->tablespaces[d
    .seq].tablespace_name, st.extent_management = tablespace_stats->tablespaces[d.seq].
    extent_management,
    st.contents = tablespace_stats->tablespaces[d.seq].contents, st.status = tablespace_stats->
    tablespaces[d.seq].status, st.num_objects = tablespace_stats->tablespaces[d.seq].num_objects,
    st.total_extents = tablespace_stats->tablespaces[d.seq].total_extents, st.blocks_free =
    tablespace_stats->tablespaces[d.seq].blocks_free, st.blocks_allocated = tablespace_stats->
    tablespaces[d.seq].blocks_allocated,
    st.pct_free = tablespace_stats->tablespaces[d.seq].pct_free, st.max_alloc_next_ext =
    tablespace_stats->tablespaces[d.seq].max_alloc_next_ext_blocks, st.num_free_chunks =
    tablespace_stats->tablespaces[d.seq].num_free_chunks,
    st.max_free_chunk_size = tablespace_stats->tablespaces[d.seq].max_free_chunk_size, st
    .segment_space_management = evaluate(tablespace_stats->tablespaces[d.seq].extent_management,
     "LOCAL",tablespace_stats->tablespaces[d.seq].segment_space_management,null), st.updt_id =
    reqinfo->updt_id,
    st.updt_dt_tm = cnvtdatetime(curdate,curtime3), st.updt_task = reqinfo->updt_task, st
    .updt_applctx = reqinfo->updt_applctx,
    st.updt_cnt = 0
   PLAN (d)
    JOIN (st)
   WITH nocounter, maxcommit = 500
  ;end insert
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
 ENDIF
 SET dm_err->eproc = "Update the ref_report_event.status = 'COMPLETE'"
 UPDATE  FROM ref_report_event rre
  SET rre.status = "COMPLETE", rre.end_dt_tm = cnvtdatetime(curdate,curtime3), rre.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   rre.updt_cnt = (rre.updt_cnt+ 1), rre.updt_task = reqinfo->updt_task, rre.updt_applctx = reqinfo->
   updt_applctx,
   rre.updt_id = reqinfo->updt_id
  WHERE rre.report_event_id=dss_collection_id
  WITH nocounter
 ;end update
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  IF (dm2ss_dminfolog("DM2_SPACE_SUMMARY",dss_collection_name,dm_err->emsg,cnvtdatetime(curdate,
    curtime3))=0)
   GO TO exit_script
  ENDIF
  GO TO exit_script
 ENDIF
#exit_script
 IF ((dm_err->err_ind=1)
  AND dss_row_exists=1)
  SET dss_old_eproc = dm_err->eproc
  SET dss_old_emsg = dm_err->emsg
  SET dm_err->err_ind = 0
  SET dm_err->eproc = "Update the ref_report_event.status = 'ERROR'"
  UPDATE  FROM ref_report_event rre
   SET rre.status = "ERROR", rre.status_message = dm_err->emsg, rre.end_dt_tm = cnvtdatetime(curdate,
     curtime3),
    rre.updt_dt_tm = cnvtdatetime(curdate,curtime3), rre.updt_cnt = (rre.updt_cnt+ 1), rre.updt_task
     = reqinfo->updt_task,
    rre.updt_applctx = reqinfo->updt_applctx, rre.updt_id = reqinfo->updt_id
   WHERE rre.report_event_id=dss_collection_id
   WITH nocounter
  ;end update
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  ENDIF
  SET dm_err->eproc = dss_old_eproc
  SET dm_err->emsg = dss_old_emsg
  SET dm_err->err_ind = 1
 ENDIF
 SET dm_err->eproc = "Ending DM2_SPACE_SUMMARY"
 CALL final_disp_msg("dm2_space_summary")
 COMMIT
END GO
