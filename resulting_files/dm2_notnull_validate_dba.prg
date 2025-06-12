CREATE PROGRAM dm2_notnull_validate:dba
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
 DECLARE dpq_process_queue_row(null) = i2
 DECLARE dpq_update_queue_row(duqr_success=i2(ref)) = i2
 DECLARE dpq_cleanup_old_procs(dcop_proc_type=vc,dcop_maxcommit=i4) = i2
 DECLARE dpq_execute_command(dec_success=i2(ref)) = i2
 DECLARE dpq_populate_queue_rows(dpqr_proc_type=vc) = i2
 DECLARE dpq_lock_queue_row(dlqr_success=i2(ref)) = i2
 DECLARE dpq_check_end_time(dcet_beg_dt_tm=dq8,dcet_proc=vc,dcet_continue_ind=i2(ref)) = i2
 DECLARE dpq_manage_end_time(dmet_prompt_ind=i2,dmet_proc_type=vc,dmet_end_time=i4) = i2
 DECLARE dpq_remove_procs(drp_proc_type=vc,drp_status=vc,drp_maxcommit=i4) = i2
 IF ((validate(dpq_process_queue->dm_process_queue_id,- (1))=- (1))
  AND (validate(dpq_process_queue->dm_process_queue_id,- (2))=- (2)))
  FREE RECORD dpq_process_queue
  RECORD dpq_process_queue(
    1 dm_process_queue_id = f8
    1 process_type = vc
    1 op_type = vc
    1 owner_name = vc
    1 object_type = vc
    1 object_name = vc
    1 operation_txt = vc
    1 process_status = vc
    1 message_txt = vc
    1 op_method = vc
    1 priority = i4
    1 routine_tasks_ind = i2
  )
 ENDIF
 IF ((validate(dpq_proc_list->proc_cnt,- (1))=- (1))
  AND (validate(dpq_proc_list->proc_cnt,- (2))=- (2)))
  FREE RECORD dpq_proc_list
  RECORD dpq_proc_list(
    1 proc_cnt = i4
    1 qual[*]
      2 dm_process_queue_id = f8
      2 process_type = vc
      2 operation_txt = vc
      2 op_method = vc
  )
  DECLARE dpq_statistics = vc WITH protect, constant("STATISTICS")
  DECLARE dpq_freq_statistics = vc WITH protect, constant("STATISTICS_FREQ_GATHER")
  DECLARE dpq_notnull_validate = vc WITH protect, constant("NOTNULL_VALIDATION")
  DECLARE dpq_routine_tasks = vc WITH protect, constant("ROUTINE_TASKS")
  DECLARE dpq_index_coalesce = vc WITH protect, constant("INDEX_COALESCE")
  DECLARE dpq_clinical_ranges = vc WITH protect, constant("CLINICAL_RANGES")
  DECLARE dpq_gather = vc WITH protect, constant("GATHER")
  DECLARE dpq_validate = vc WITH protect, constant("VALIDATE")
  DECLARE dpq_coalesce = vc WITH protect, constant("COALESCE")
  DECLARE dpq_queued = vc WITH protect, constant("QUEUED")
  DECLARE dpq_executing = vc WITH protect, constant("EXECUTING")
  DECLARE dpq_failure = vc WITH protect, constant("FAILURE")
  DECLARE dpq_success = vc WITH protect, constant("SUCCESS")
  DECLARE dpq_table = vc WITH protect, constant("TABLE")
  DECLARE dpq_index = vc WITH protect, constant("INDEX")
  DECLARE dpq_schema = vc WITH protect, constant("SCHEMA")
  DECLARE dpq_constraint = vc WITH protect, constant("CONSTRAINT")
  DECLARE dpq_db = vc WITH protect, constant("DB")
  DECLARE dpq_dcl = vc WITH protect, constant("DCL")
 ENDIF
 SUBROUTINE dpq_process_queue_row(null)
   SET dm_err->eproc = "Validating inputs for dpq_process_queue_row"
   IF ("" IN (trim(dpq_process_queue->process_type), trim(dpq_process_queue->op_type), trim(
    dpq_process_queue->owner_name), trim(dpq_process_queue->object_type), trim(dpq_process_queue->
    object_name),
   trim(dpq_process_queue->operation_txt)))
    SET dm_err->emsg =
    "Must populate PROC_TYPE, OP_TYPE, owner_name, OBJECT_TYPE, operation_txt and OBJECT_NAME"
    CALL disp_msg(dm_err->eproc,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Checking for an existing row from dm_process_queue."
   SELECT INTO "nl:"
    FROM dm_process_queue dpq
    WHERE (dpq.process_type=dpq_process_queue->process_type)
     AND (dpq.op_type=dpq_process_queue->op_type)
     AND (dpq.owner_name=dpq_process_queue->owner_name)
     AND (dpq.object_type=dpq_process_queue->object_type)
     AND (dpq.object_name=dpq_process_queue->object_name)
    DETAIL
     dpq_process_queue->dm_process_queue_id = dpq.dm_process_queue_id, dpq_process_queue->
     process_status = dpq.process_status
    WITH nocounter, maxqual(dpq,1)
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual
    AND (dpq_process_queue->process_status != dpq_executing))
    SET dm_err->eproc = "Updating dm_process_queue row."
    UPDATE  FROM dm_process_queue dpq
     SET dpq.process_status = dpq_queued, dpq.operation_txt = dpq_process_queue->operation_txt, dpq
      .op_method = dpq_process_queue->op_method,
      dpq.message_txt = "", dpq.audsid = "", dpq.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      dpq.priority = evaluate(dpq_process_queue->priority,0,dpq.priority,dpq_process_queue->priority),
      dpq.routine_tasks_ind = dpq_process_queue->routine_tasks_ind
     WHERE (dpq.dm_process_queue_id=dpq_process_queue->dm_process_queue_id)
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    COMMIT
   ELSEIF (curqual
    AND (dpq_process_queue->process_status=dpq_executing))
    UPDATE  FROM dm_process_queue dpq
     SET dpq.updt_dt_tm = cnvtdatetime(curdate,curtime3), dpq.priority = evaluate(dpq_process_queue->
       priority,0,dpq.priority,dpq_process_queue->priority), dpq.routine_tasks_ind =
      dpq_process_queue->routine_tasks_ind
     WHERE (dpq.dm_process_queue_id=dpq_process_queue->dm_process_queue_id)
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    COMMIT
   ELSE
    SET dm_err->eproc = "Selecting new dm_process_queue_id from dual"
    SELECT INTO "nl:"
     new_id = seq(dm_clinical_seq,nextval)
     FROM dual d
     DETAIL
      dpq_process_queue->dm_process_queue_id = new_id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Inserting dm_process_queue row."
    INSERT  FROM dm_process_queue dpq
     SET dpq.process_type = dpq_process_queue->process_type, dpq.dm_process_queue_id =
      dpq_process_queue->dm_process_queue_id, dpq.op_type = dpq_process_queue->op_type,
      dpq.owner_name = dpq_process_queue->owner_name, dpq.object_type = dpq_process_queue->
      object_type, dpq.object_name = dpq_process_queue->object_name,
      dpq.operation_txt = dpq_process_queue->operation_txt, dpq.op_method = dpq_process_queue->
      op_method, dpq.process_status = dpq_queued,
      dpq.priority = evaluate(dpq_process_queue->priority,0,100,dpq_process_queue->priority), dpq
      .routine_tasks_ind = dpq_process_queue->routine_tasks_ind, dpq.gen_dt_tm = cnvtdatetime(curdate,
       curtime3),
      dpq.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpq_update_queue_row(duqr_success)
   SET dm_err->eproc = "Updating dm_process_queue row"
   SET duqr_success = 0
   UPDATE  FROM dm_process_queue dpq
    SET dpq.process_status = dpq_process_queue->process_status, dpq.message_txt = evaluate(trim(
       dpq_process_queue->message_txt),"",dpq.message_txt,dpq_process_queue->message_txt), dpq.audsid
      = "",
     dpq.end_dt_tm = cnvtdatetime(curdate,curtime3), dpq.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (dpq.dm_process_queue_id=dpq_process_queue->dm_process_queue_id)
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc))
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (curqual)
    SET duqr_success = 1
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpq_cleanup_old_procs(dcop_proc_type,dcop_maxcommit)
   DECLARE dcop_continue_ind = i2 WITH protect, noconstant(1)
   DECLARE dcop_tmp_where_clause = vc WITH protect, noconstant("")
   IF (dcop_proc_type=dpq_routine_tasks)
    SET dcop_tmp_where_clause = "dpq.routine_tasks_ind = 1"
   ELSE
    SET dcop_tmp_where_clause = "dpq.process_type = value(dcop_proc_type)"
   ENDIF
   SET dm_err->eproc = "Updating queued rows from DM_PROCESS_QUEUE"
   WHILE (dcop_continue_ind)
     UPDATE  FROM dm_process_queue dpq
      SET dpq.process_status = dpq_queued, dpq.priority = sqlpassthru(
        "least(dpq.priority + 1, floor(dpq.priority/10)*10 + 9)"), dpq.message_txt = ""
      WHERE parser(dcop_tmp_where_clause)
       AND ((dpq.process_status=dpq_failure) OR (dpq.process_status=dpq_executing
       AND (( NOT (dpq.audsid IN (
      (SELECT
       cnvtstring(gvs.audsid)
       FROM gv$session gvs)))) OR (dpq.audsid=currdbhandle)) ))
      WITH nocounter, maxqual(dpq,value(dcop_maxcommit))
     ;end update
     IF (check_error(dm_err->eproc))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN(0)
     ENDIF
     SET dcop_continue_ind = curqual
     COMMIT
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpq_lock_queue_row(dlqr_success)
   SET dlqr_success = 0
   SET dm_err->eproc = "Attempting to update DM_PROCESS_QUEUE row to executing."
   UPDATE  FROM dm_process_queue dpq
    SET dpq.process_status = dpq_executing, dpq.begin_dt_tm = cnvtdatetime(curdate,curtime3), dpq
     .audsid = currdbhandle
    WHERE (dpq.dm_process_queue_id=dpq_process_queue->dm_process_queue_id)
     AND dpq.process_status=dpq_queued
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ELSEIF (curqual)
    SET dlqr_success = 1
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpq_populate_queue_rows(dpqr_proc_type)
   DECLARE dpqr_tmp = i4 WITH protect, noconstant(0)
   DECLARE dpqr_tmp_where_clause = vc WITH protect, noconstant("")
   IF (dpqr_proc_type=dpq_routine_tasks)
    SET dpqr_tmp_where_clause = "dpq.routine_tasks_ind = 1"
   ELSE
    SET dpqr_tmp_where_clause = "dpq.process_type = value(dpqr_proc_type)"
   ENDIF
   IF (validate(dpqrs_exec_ind,- (1))=1)
    IF ( NOT (validate(dpqrs_dpq_id,- (1)) <= 0.0))
     SET dpqr_tmp_where_clause = concat(dpqr_tmp_where_clause,
      " and dpq.dm_process_queue_id = value(dpqrs_dpq_id)")
    ELSE
     SET dm_err->eproc =
     "DPQ_POPULATE_QUEUE_ROWS was called via dm2_process_queue_runner_single with no valid dpq_id"
     CALL disp_msg(" ",dm_err->logfile,0)
     RETURN(1)
    ENDIF
   ENDIF
   SET dpq_proc_list->proc_cnt = 0
   SET stat = alterlist(dpq_proc_list->qual,0)
   SET dm_err->eproc = "Loading operations to run from DM_PROCESS_QUEUE"
   SELECT INTO "nl:"
    FROM dm_process_queue dpq
    WHERE dpq.process_status=dpq_queued
     AND parser(dpqr_tmp_where_clause)
    ORDER BY dpq.priority, dpq.gen_dt_tm
    DETAIL
     dpq_proc_list->proc_cnt = (dpq_proc_list->proc_cnt+ 1)
     IF ((dpq_proc_list->proc_cnt > dpqr_tmp))
      dpqr_tmp = (dpqr_tmp+ 50), stat = alterlist(dpq_proc_list->qual,dpqr_tmp)
     ENDIF
     dpq_proc_list->qual[dpq_proc_list->proc_cnt].dm_process_queue_id = dpq.dm_process_queue_id,
     dpq_proc_list->qual[dpq_proc_list->proc_cnt].process_type = dpq.process_type, dpq_proc_list->
     qual[dpq_proc_list->proc_cnt].operation_txt = dpq.operation_txt,
     dpq_proc_list->qual[dpq_proc_list->proc_cnt].op_method = dpq.op_method
    FOOT REPORT
     stat = alterlist(dpq_proc_list->qual,dpq_proc_list->proc_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpq_execute_command(dec_success)
   SET dm_err->eproc = "Validating inputs for dpq_execute_command"
   IF ("" IN (trim(dpq_process_queue->op_method), trim(dpq_process_queue->operation_txt)))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "DPQ_EXECUTE_COMMAND was called with no operation_txt or op_method"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dpq_process_queue->process_status = dpq_failure
    SET dpq_process_queue->message_txt = dm_err->emsg
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Executing operation_txt: ",dpq_process_queue->op_method,":",
    dpq_process_queue->operation_txt)
   IF ((dpq_process_queue->op_method=dpq_db))
    SET dec_success = dm2_push_cmd(dpq_process_queue->operation_txt,1)
    IF (dm_err->err_ind)
     SET dec_success = 0
    ENDIF
   ELSEIF ((dpq_process_queue->op_method=dpq_dcl))
    SET dec_success = dm2_push_dcl(dpq_process_queue->operation_txt)
    IF (dm_err->err_ind)
     SET dec_success = 0
    ENDIF
   ENDIF
   IF (dec_success)
    SET dpq_process_queue->process_status = dpq_success
    SET dpq_process_queue->message_txt = ""
   ELSE
    SET dpq_process_queue->process_status = dpq_failure
    SET dpq_process_queue->message_txt = dm_err->emsg
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpq_check_end_time(dcet_beg_dt_tm,dcet_proc,dcet_continue_ind)
   DECLARE dcet_tgt_end_time = dq8 WITH protect, noconstant(cnvtdatetime(curdate,cnvttime(360)))
   DECLARE dcet_fallout_ind = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Selecting end_time from DM_INFO"
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain IN ("DM_PROCESS_QUEUE_RUNNER_END_TIME", "DM_PROCESS_QUEUE_RUNNER_FALLOUT")
     AND di.info_name=dcet_proc
    DETAIL
     IF (di.info_domain="DM_PROCESS_QUEUE_RUNNER_FALLOUT")
      dcet_fallout_ind = 1
     ELSE
      IF ((di.info_number=- (1)))
       dcet_tgt_end_time = datetimeadd(cnvtdatetime(curdate,curtime3),1)
      ELSE
       dcet_tgt_end_time = cnvtdatetime(curdate,cnvttime(di.info_number))
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dcet_beg_dt_tm > dcet_tgt_end_time)
    SET dcet_tgt_end_time = datetimeadd(dcet_tgt_end_time,1)
   ENDIF
   IF (((cnvtdatetime(curdate,curtime3) > dcet_tgt_end_time) OR (dcet_fallout_ind=1)) )
    IF (dcet_fallout_ind=1)
     SET dm_err->eproc =
     "Ending dm2_process_queue_runner because Fallout Indicator row was found in dm_info"
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SET dcet_continue_ind = 0
   ELSE
    SET dcet_continue_ind = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpq_manage_end_time(dmet_prompt_ind,dmet_proc_type,dmet_end_time)
   DECLARE dmet_new_end_time = i4 WITH protect, noconstant(dmet_end_time)
   DECLARE dmet_update_ind = i2 WITH protect, noconstant(0)
   DECLARE dmet_menu_select = vc WITH protect, noconstant("M")
   IF (dmet_prompt_ind)
    SET dmet_new_end_time = 360
   ENDIF
   SET dm_err->eproc = "Checking for existence of end_time row from DM_INFO"
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM_PROCESS_QUEUE_RUNNER_END_TIME"
     AND di.info_name=dmet_proc_type
    DETAIL
     IF (dmet_prompt_ind)
      dmet_new_end_time = di.info_number
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    SET dmet_update_ind = curqual
   ENDIF
   WHILE (true)
    IF (dmet_prompt_ind)
     SET message = window
     SET width = 132
     CALL clear(1,1)
     CALL box(1,1,24,131)
     CALL text(2,2,concat(dmet_proc_type,notrim(" job menu")))
     CALL text(5,10,concat("Input the hour you want the ",dmet_proc_type,
       " job to stop at (0-23) [use -1 for no end time]:"))
     CALL text(6,10,concat("Hours:",evaluate(dmet_new_end_time,- (1),"Unlimited",cnvtstring(floor((
          dmet_new_end_time/ 60))))))
     CALL text(7,10,concat("Input the minutes you want the ",dmet_proc_type,notrim(
        " job to stop at (0-59):")))
     CALL text(8,10,concat("Minutes:",cnvtstring(evaluate(dmet_new_end_time,- (1),0,mod(
          dmet_new_end_time,60)))))
     CALL text(10,10,"(C)ontinue, (M)odify, (Q)uit:")
     CALL accept(10,41,"A;CU",dmet_menu_select
      WHERE curaccept IN ("C", "M", "Q"))
     SET dmet_menu_select = curaccept
     IF (dmet_menu_select="C")
      SET message = nowindow
      CALL clear(1,1)
     ENDIF
    ELSE
     SET dmet_menu_select = "C"
    ENDIF
    CASE (dmet_menu_select)
     OF "Q":
      RETURN(1)
     OF "C":
      IF (dmet_update_ind)
       SET dm_err->eproc = "Updating end_time row into DM_INFO"
       UPDATE  FROM dm_info di
        SET di.info_number = dmet_new_end_time
        WHERE di.info_domain="DM_PROCESS_QUEUE_RUNNER_END_TIME"
         AND di.info_name=dmet_proc_type
        WITH nocounter
       ;end update
       IF (check_error(dm_err->eproc))
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        RETURN(0)
       ELSE
        COMMIT
       ENDIF
      ELSE
       SET dm_err->eproc = "Inserting end_time row into DM_INFO"
       INSERT  FROM dm_info di
        SET di.info_domain = "DM_PROCESS_QUEUE_RUNNER_END_TIME", di.info_name = dmet_proc_type, di
         .info_number = dmet_new_end_time
        WITH nocounter
       ;end insert
       IF (check_error(dm_err->eproc))
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        RETURN(0)
       ELSE
        COMMIT
       ENDIF
      ENDIF
      RETURN(1)
     OF "M":
      SET dmet_menu_select = "C"
      CALL accept(6,16,"NN;",evaluate(dmet_new_end_time,- (1),- (1),floor((dmet_new_end_time/ 60)))
       WHERE curaccept BETWEEN - (1) AND 23)
      SET dmet_new_end_time = evaluate(curaccept,- (1),- (1),(60 * curaccept))
      IF ((dmet_new_end_time != - (1)))
       CALL accept(8,18,"99;",0
        WHERE curaccept BETWEEN 0 AND 59)
       SET dmet_new_end_time = (dmet_new_end_time+ curaccept)
      ENDIF
    ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE dpq_remove_procs(drp_proc_type,drp_status,drp_maxcommit)
   DECLARE drp_continue_ind = i2 WITH protect, noconstant(1)
   DECLARE drp_tmp_where_clause = vc WITH protect, noconstant("")
   IF (drp_proc_type=dpq_routine_tasks)
    SET drp_tmp_where_clause = "dpq.routine_tasks_ind = 1"
   ELSE
    SET drp_tmp_where_clause = "dpq.process_type = value(drp_proc_type)"
   ENDIF
   SET dm_err->eproc = concat("Clearing out ",drp_proc_type," rows with status of ",drp_status)
   CALL disp_msg("",dm_err->logfile,0)
   WHILE (drp_continue_ind)
     DELETE  FROM dm_process_queue dpq
      WHERE dpq.process_status=drp_status
       AND parser(drp_tmp_where_clause)
      WITH nocounter, maxqual(dpq,value(drp_maxcommit))
     ;end delete
     IF (check_error(dm_err->eproc))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN(0)
     ENDIF
     COMMIT
     SET drp_continue_ind = curqual
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpq_cleanup_stranded_procs(dcsp_proc_type,dcsp_maxcommit)
   DECLARE dcsp_continue_ind = i2 WITH protect, noconstant(1)
   DECLARE dcsp_tmp_where_clause = vc WITH protect, noconstant("")
   IF (dcsp_proc_type=dpq_routine_tasks)
    SET dcsp_tmp_where_clause = "dpq.routine_tasks_ind = 1"
   ELSE
    SET dcsp_tmp_where_clause = "dpq.process_type = value(dcsp_proc_type)"
   ENDIF
   SET dm_err->eproc = "Updating stranded rows from DM_PROCESS_QUEUE"
   WHILE (dcsp_continue_ind)
     UPDATE  FROM dm_process_queue dpq
      SET dpq.process_status = dpq_failure, dpq.priority = sqlpassthru(
        "least(dpq.priority + 1, floor(dpq.priority/10)*10 + 9)")
      WHERE parser(dcsp_tmp_where_clause)
       AND dpq.process_status=dpq_executing
       AND (( NOT (dpq.audsid IN (
      (SELECT
       cnvtstring(gvs.audsid)
       FROM gv$session gvs)))) OR (dpq.audsid=currdbhandle))
      WITH nocounter, maxqual(dpq,value(dcsp_maxcommit))
     ;end update
     IF (check_error(dm_err->eproc))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN(0)
     ENDIF
     SET dcsp_continue_ind = curqual
     COMMIT
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 DECLARE dm2_get_program_details(null) = vc
 SUBROUTINE dm2_get_program_details(null)
   DECLARE dgpd_param_num = i2 WITH protect, noconstant(1)
   DECLARE dgpd_param_type = vc WITH protect, noconstant("")
   DECLARE dgpd_param_cnt = i2 WITH protect, noconstant(0)
   DECLARE dgpd_details = vc WITH protect, noconstant("~")
   WHILE (dgpd_param_num)
    IF (assign(dgpd_param_type,reflect(parameter(dgpd_param_num,0)))="")
     SET dgpd_param_cnt = (dgpd_param_num - 1)
     SET dgpd_param_num = 0
     IF (dgpd_param_cnt=0)
      RETURN("")
     ELSE
      RETURN(substring(3,size(dgpd_details),dgpd_details))
     ENDIF
    ELSE
     SET dgpd_details = build(dgpd_details,",")
     IF (substring(1,1,dgpd_param_type)="C")
      SET dgpd_details = build(dgpd_details,'"',parameter(dgpd_param_num,0),'"')
     ELSE
      SET dgpd_details = build(dgpd_details,parameter(dgpd_param_num,0))
     ENDIF
    ENDIF
    SET dgpd_param_num = (dgpd_param_num+ 1)
   ENDWHILE
 END ;Subroutine
 DECLARE dm2_process_log_row(process_name=vc,action_type=vc,prev_log_id=f8,ignore_errors=i2) = i2
 DECLARE dm2_process_log_dtl_row(dpldr_event_log_id=f8,ignore_errors=i2) = i2
 DECLARE dm2_process_log_add_detail_text(detail_type=vc,detail_text=vc) = null
 DECLARE dm2_process_log_add_detail_date(detail_type=vc,detail_date=dq8) = null
 DECLARE dm2_process_log_add_detail_number(detail_type=vc,detail_number=f8) = null
 DECLARE dpl_upd_dped_last_status(dudls_event_id=f8,dudls_text=vc,dudls_number=f8,dudls_date=dq8) =
 i2
 DECLARE dpl_ui_chk(duc_process_name=vc) = i2
 IF ((validate(dm2_process_rs->cnt,- (1))=- (1))
  AND (validate(dm2_process_rs->cnt,- (2))=- (2)))
  FREE RECORD dm2_process_rs
  RECORD dm2_process_rs(
    1 dbase_name = vc
    1 table_exists_ind = i2
    1 filled_ind = i2
    1 dm_process_id = f8
    1 process_name = vc
    1 cnt = i4
    1 qual[*]
      2 dm_process_id = f8
      2 process_name = vc
      2 program_name = vc
      2 action_type = vc
      2 search_string = vc
  )
  FREE RECORD dm2_process_event_rs
  RECORD dm2_process_event_rs(
    1 dm_process_event_id = f8
    1 status = vc
    1 message = vc
    1 ui_allowed_ind = i2
    1 install_plan_id = f8
    1 begin_dt_tm = dq8
    1 end_dt_tm = dq8
    1 detail_cnt = i4
    1 itinerary_key = vc
    1 itinerary_process_event_id = f8
    1 details[*]
      2 detail_type = vc
      2 detail_number = f8
      2 detail_text = vc
      2 detail_date = dq8
  )
  SET dm2_process_event_rs->ui_allowed_ind = 0
 ENDIF
 IF (validate(dpl_index_monitoring,"X")="X"
  AND validate(dpl_index_monitoring,"Y")="Y")
  DECLARE dpl_username = vc WITH protect, constant(curuser)
  DECLARE dpl_no_prev_id = f8 WITH protect, constant(0.0)
  DECLARE dpl_success = vc WITH protect, constant("SUCCESS")
  DECLARE dpl_failure = vc WITH protect, constant("FAILURE")
  DECLARE dpl_failed = vc WITH protect, constant("FAILED")
  DECLARE dpl_complete = vc WITH protect, constant("COMPLETE")
  DECLARE dpl_executing = vc WITH protect, constant("EXECUTING")
  DECLARE dpl_paused = vc WITH protect, constant("PAUSED")
  DECLARE dpl_confirmation = vc WITH protect, constant("CONFIRMATION")
  DECLARE dpl_decline = vc WITH protect, constant("DECLINE")
  DECLARE dpl_stopped = vc WITH protect, constant("STOPPED")
  DECLARE dpl_statistics = vc WITH protect, constant("DATABASE STATISTICS GATHERING")
  DECLARE dpl_cbo = vc WITH protect, constant("CBO IMPLEMENTER")
  DECLARE dpl_db_services = vc WITH protect, constant("DATABASE SERVICES")
  DECLARE dpl_package_install = vc WITH protect, constant("PACKAGE INSTALL")
  DECLARE dpl_install_runner = vc WITH protect, constant("INSTALL RUNNER")
  DECLARE dpl_background_runner = vc WITH protect, constant("BACKGROUND RUNNER")
  DECLARE dpl_install_monitor = vc WITH protect, constant("INSTALL MONITOR")
  DECLARE dpl_status_change = vc WITH protect, constant("STATUS CHANGE")
  DECLARE dpl_notnull_validate = vc WITH protect, constant("NOTNULL_VALIDATION")
  DECLARE dpl_process_queue_runner = vc WITH protect, constant("DM_PROCESS_QUEUE RUNNER")
  DECLARE dpl_process_queue_single = vc WITH protect, constant("DM_PROCESS_QUEUE SINGLE")
  DECLARE dpl_process_queue_wrapper = vc WITH protect, constant("DM_PROCESS_QUEUE WRAPPER")
  DECLARE dpl_routine_tasks = vc WITH protect, constant("ROUTINE TASKS")
  DECLARE dpl_coalesce = vc WITH protect, constant("INDEX COALESCING")
  DECLARE dpl_custom_user_mgmt = vc WITH protect, constant("CUSTOM USERS MANAGEMENT")
  DECLARE dpl_xnt_clinical_ranges = vc WITH protect, constant(
   "ESTABLISH EXTRACT & TRANSFORM(XNT) CLINICAL RANGES")
  DECLARE dpl_cbo_stats = vc WITH protect, constant("CBO STATISTICS MANAGEMENT")
  DECLARE dpl_oragen3 = vc WITH protect, constant("ORAGEN3")
  DECLARE dpl_cap_desired_schema = vc WITH protect, constant("CAPTURE DESIRED SCHEMA")
  DECLARE dpl_app_desired_schema = vc WITH protect, constant("APPLY DESIRED SCHEMA")
  DECLARE dpl_ccl_grant = vc WITH protect, constant("CCL GRANTS")
  DECLARE dpl_plan_control = vc WITH protect, constant("PLAN CONTROL")
  DECLARE dpl_cleanup_stats_rows = vc WITH protect, constant("CLEANUP STATS ROWS")
  DECLARE dpl_index_monitoring = vc WITH protect, constant("INDEX MONITORING")
  DECLARE dpl_admin_upgrade = vc WITH protect, constant("ADMIN UPGRADE")
  DECLARE dpl_execution = vc WITH protect, constant("EXECUTION")
  DECLARE dpl_enable_table_monitoring = vc WITH protect, constant("TABLE MONITORING ENABLE")
  DECLARE dpl_table_stats_gathering = vc WITH protect, constant("GATHER TABLE STATS")
  DECLARE dpl_index_stats_gathering = vc WITH protect, constant("GATHER INDEX STATS")
  DECLARE dpl_system_stats_gathering = vc WITH protect, constant("GATHER SYSTEM STATS")
  DECLARE dpl_schema_stats_gathering = vc WITH protect, constant("GATHER SCHEMA STATS")
  DECLARE dpl_itinerary_event = vc WITH protect, constant("ITINERARY EVENT")
  DECLARE dpl_alter_index_monitoring = vc WITH protect, constant("ALTER_INDEX_MONITORING")
  DECLARE dpl_cbo_reset_script_manual = vc WITH protect, constant("CBO RESET SCRIPT MANUAL")
  DECLARE dpl_cbo_reset_script_recompile = vc WITH protect, constant("CBO RESET SCRIPT RECOMPILE")
  DECLARE dpl_cbo_reset_query_manual = vc WITH protect, constant("CBO RESET QUERY MANUAL")
  DECLARE dpl_cbo_reset_all = vc WITH protect, constant("CBO RESET ALL")
  DECLARE dpl_cbo_enable = vc WITH protect, constant("CBO ENABLED")
  DECLARE dpl_cbo_disable = vc WITH protect, constant("CBO DISABLE")
  DECLARE dpl_cbo_monitoring_init = vc WITH protect, constant("CBO MONITORING INITIATED")
  DECLARE dpl_cbo_monitoring_complete = vc WITH protect, constant("CBO MONITORING COMPLETE")
  DECLARE dpl_cbo_tuning_change = vc WITH protect, constant("CBO TUNING CHANGE")
  DECLARE dpl_cbo_tuning_nochange = vc WITH protect, constant("CBO TUNING NOCHANGE")
  DECLARE dpl_data_dump = vc WITH protect, constant("CBO DATA DUMP")
  DECLARE dpl_data_dump_purge = vc WITH protect, constant("CBO DATA DUMP PURGE")
  DECLARE dpl_activate_all = vc WITH protect, constant("ACTIVATE ALL SERVICES")
  DECLARE dpl_instance_activation = vc WITH protect, constant("ACTIVATE SERVICES BY INSTANCE")
  DECLARE dpl_tns_deployment = vc WITH protect, constant("TNS DEPLOYMENT")
  DECLARE dpl_svc_reg_upd = vc WITH protect, constant("REGISTRY SERVER UPDATE")
  DECLARE dpl_notification = vc WITH protect, constant("NOTIFICATION")
  DECLARE dpl_auditlog = vc WITH protect, constant("AUDITLOG")
  DECLARE dpl_snapshot = vc WITH protect, constant("SNAPSHOT")
  DECLARE dpl_purge = vc WITH protect, constant("CUSTOM-DELETE")
  DECLARE dpl_table = vc WITH protect, constant("TABLE")
  DECLARE dpl_index = vc WITH protect, constant("INDEX")
  DECLARE dpl_system = vc WITH protect, constant("SYSTEM")
  DECLARE dpl_schema = vc WITH protect, constant("SCHEMA")
  DECLARE dpl_cmd = vc WITH protect, constant("COMMAND")
  DECLARE dpl_est_pct = vc WITH protect, constant("ESTIMATE PERCENT")
  DECLARE dpl_owner = vc WITH protect, constant("OWNER")
  DECLARE dpl_method_opt = vc WITH protect, constant("METHOD OPT")
  DECLARE dpl_num_attempts = vc WITH protect, constant("NUM ATTEMPTS")
  DECLARE dpl_dm_sql_id = vc WITH protect, constant("DM_SQL_ID")
  DECLARE dpl_script_name = vc WITH protect, constant("SCRIPT NAME")
  DECLARE dpl_query_nbr = vc WITH protect, constant("QUERY_NBR")
  DECLARE dpl_query_nbr_text = vc WITH protect, constant("QUERY_NBR_TEXT")
  DECLARE dpl_sqltext_hash_value = vc WITH protect, constant("SQLTEXT_HASH_VALUE")
  DECLARE dpl_host_name = vc WITH protect, constant("HOST NAME")
  DECLARE dpl_inst_name = vc WITH protect, constant("INSTANCE NAME")
  DECLARE dpl_oracle_version = vc WITH protect, constant("ORACLE VERSION")
  DECLARE dpl_constraint = vc WITH protect, constant("CONSTRAINT")
  DECLARE dpl_column = vc WITH protect, constant("COLUMN")
  DECLARE dpl_proc_queue_runner_type = vc WITH protect, constant("DM_PROCESS_QUEUE RUNNER TYPE")
  DECLARE dpl_dpq_id = vc WITH protect, constant("DM_PROCESS_QUEUE_ID")
  DECLARE dpl_level = vc WITH protect, constant("LEVEL")
  DECLARE dpl_step_number = vc WITH protect, constant("STEP_NUMBER")
  DECLARE dpl_step_name = vc WITH protect, constant("STEP_NAME")
  DECLARE dpl_install_mode = vc WITH protect, constant("INSTALL_MODE")
  DECLARE dpl_parent_step_name = vc WITH protect, constant("PARENT_STEP_NAME")
  DECLARE dpl_parent_level_number = vc WITH protect, constant("PARENT_LEVEL_NUMBER")
  DECLARE dpl_configuration_changed = vc WITH protect, constant("CONFIGURATION CHANGED")
  DECLARE dpl_instsched_used = vc WITH protect, constant("INSTALLATION SCHEDULER USED")
  DECLARE dpl_silmode = vc WITH protect, constant("SILENT MODE USED")
  DECLARE dpl_audsid = vc WITH protect, constant("AUDSID")
  DECLARE dpl_logfilemain = vc WITH protect, constant("LOGFILE:MAIN")
  DECLARE dpl_logfilerunner = vc WITH protect, constant("LOGFILE:RUNNER")
  DECLARE dpl_logfilebackground = vc WITH protect, constant("LOGFILE:BACKGROUND")
  DECLARE dpl_logfilemonitor = vc WITH protect, constant("LOGFILE:MONITOR")
  DECLARE dpl_unattended = vc WITH protect, constant("UNATTENDED_IND")
  DECLARE dpl_itinerary_key = vc WITH protect, constant("ITINERARY_KEY")
  DECLARE dpl_report = vc WITH protect, constant("REPORT")
  DECLARE dpl_actionreq = vc WITH protect, constant("ACTIONREQ")
  DECLARE dpl_progress = vc WITH protect, constant("PROGRESS")
  DECLARE dpl_warning = vc WITH protect, constant("WARNING")
  DECLARE dpl_execution_dpe_id = vc WITH protect, constant("EXECUTION_DPE_ID")
  DECLARE dpl_itinerary_dpe_id = vc WITH protect, constant("ITINERARY_DPE_ID")
  DECLARE dpl_itinerary_key_name = vc WITH protect, constant("ITINERARY_KEY_NAME")
  DECLARE dpl_audit_name = vc WITH protect, constant("AUDIT_NAME")
  DECLARE dpl_audit_type = vc WITH protect, constant("AUDIT_TYPE")
  DECLARE dpl_sample = vc WITH protect, constant("SAMPLE")
  DECLARE dpl_drivergen_runner = vc WITH protect, constant("DM2_ADS_DRIVER_GEN:AUDSID")
  DECLARE dpl_childest_runner = vc WITH protect, constant("DM2_ADS_CHILDEST_GEN:AUDSID")
  DECLARE dpl_ads_runner = vc WITH protect, constant("DM2_ADS_RUNNER:AUDSID")
  DECLARE dpl_byconfig = vc WITH protect, constant("BYCONFIG")
  DECLARE dpl_full = vc WITH protect, constant("ALL")
  DECLARE dpl_interval = vc WITH protect, constant("EVERYNTH")
  DECLARE dpl_intervalpct = vc WITH protect, constant("EVERYNTHPCT")
  DECLARE dpl_recent = vc WITH protect, constant("RECENT")
  DECLARE dpl_none = vc WITH protect, constant("NONE")
  DECLARE dpl_custom = vc WITH protect, constant("CUSTOM")
  DECLARE dpl_static = vc WITH protect, constant("STATIC")
  DECLARE dpl_nomove = vc WITH protect, constant("NOMOVE")
  DECLARE dpl_multiple = vc WITH protect, constant("MULTIPLE")
  DECLARE dpl_driverkeygen = vc WITH protect, constant("DRIVERKEYGEN")
  DECLARE dpl_childestgen = vc WITH protect, constant("CHILDESTGEN")
  DECLARE dpl_define = vc WITH protect, constant("DEFINE")
  DECLARE dpl_invalid_schema = vc WITH protect, constant("INVALID - SCHEMA")
  DECLARE dpl_invalid_stats = vc WITH protect, constant("INVALID - STATS")
  DECLARE dpl_invalid_table = vc WITH protect, constant("INVALID - TABLE")
  DECLARE dpl_invalid_data = vc WITH protect, constant("INVALID - NO SAMPLE METADATA")
  DECLARE dpl_custom_table = vc WITH protect, constant("CUSTOM TABLE")
  DECLARE dpl_new_table = vc WITH protect, constant("NEW TABLE")
  DECLARE dpl_ready = vc WITH protect, constant("READY")
  DECLARE dpl_needsbuild = vc WITH protect, constant("NEEDSBUILD")
  DECLARE dpl_incomplete = vc WITH protect, constant("INCOMPLETE")
  DECLARE dpl_new = vc WITH protect, constant("NEW")
  DECLARE dpl_config_extract_id = vc WITH protect, constant("CONFIG_EXTRACT_ID")
  DECLARE dpl_dynselect_holder = vc WITH protect, constant("<<DYNBYCONFIG>>")
  DECLARE dpl_tgtdblink_holder = vc WITH protect, constant("<<TGTDBLINK>>")
  DECLARE dpl_ads_metadata = vc WITH protect, constant("DM2_ADS_METADATA")
  DECLARE dpl_ads_scramble_method = vc WITH protect, constant("DM2_SCRAMBLE_METHOD")
  DECLARE dpl_act = vc WITH protect, constant("ACTIVITY")
  DECLARE dpl_ref = vc WITH protect, constant("REFERENCE")
  DECLARE dpl_ref_mix = vc WITH protect, constant("REFERENCE-MIXED")
  DECLARE dpl_act_mix = vc WITH protect, constant("ACTIVITY-MIXED")
  DECLARE dpl_mix = vc WITH protect, constant("MIXED")
  DECLARE dpl_action = vc WITH protect, constant("ACTION")
  DECLARE dpl_grant_method = vc WITH protect, constant("GRANT METHOD")
  DECLARE dpl_script = vc WITH protect, constant("SCRIPT NAME")
  DECLARE dpl_query = vc WITH protect, constant("QUERY NUMBER")
  DECLARE dpl_name = vc WITH protect, constant("USER NAME")
  DECLARE dpl_email = vc WITH protect, constant("EMAIL ADDRESS")
  DECLARE dpl_reason = vc WITH protect, constant("REASON FOR ACTION")
  DECLARE dpl_sr_nbr = vc WITH protect, constant("SR NUMBER")
  DECLARE dpl_sql_id = vc WITH protect, constant("SQL ID")
  DECLARE dpl_grant_exists = vc WITH protect, constant("GRANT EXISTS")
  DECLARE dpl_bl_exists = vc WITH protect, constant("BASELINE EXISTS")
  DECLARE dpl_grant_str = vc WITH protect, constant("GRANT OUTSTRING")
  DECLARE dpl_grant_cmd = vc WITH protect, constant("GRANT COMMAND")
  DECLARE dpl_bl_query_nbr = vc WITH protect, constant("BASELINE QUERY NUMBER")
  DECLARE dpl_bl_sql_handle = vc WITH protect, constant("BASELINE SQL HANDLE")
  DECLARE dpl_bl_sql_text = vc WITH protect, constant("BASELINE SQL TEXT")
  DECLARE dpl_bl_creator = vc WITH protect, constant("BASELINE CREATOR")
  DECLARE dpl_bl_desc = vc WITH protect, constant("BASELINE DESCRIPTION")
  DECLARE dpl_bl_enabled = vc WITH protect, constant("BASELINE ENABLED")
  DECLARE dpl_bl_accepted = vc WITH protect, constant("BASELINE ACCEPTED")
  DECLARE dpl_bl_plan_name = vc WITH protect, constant("BASELINE PLAN NAME")
  DECLARE dpl_bl_created = vc WITH protect, constant("BASELINE CREATED DT/TM")
  DECLARE dpl_bl_last_mod = vc WITH protect, constant("BASELINE LAST MODIFIED DT/TM")
  DECLARE dpl_bl_last_exec = vc WITH protect, constant("BASELINE LAST EXECUTED DT/TM")
 ENDIF
 SUBROUTINE dpl_upd_dped_last_status(dudls_event_id,dudls_text,dudls_number,dudls_date)
   DECLARE dudls_emsg = vc WITH protect, noconstant(dm_err->emsg)
   DECLARE dudls_eproc = vc WITH protect, noconstant(dm_err->eproc)
   DECLARE dudls_err_ind = i4 WITH protect, noconstant(dm_err->err_ind)
   IF (dudls_err_ind=1)
    SET dm_err->err_ind = 0
   ENDIF
   IF ((dm2_process_event_rs->ui_allowed_ind=0))
    RETURN(1)
   ENDIF
   SET dm_err->eproc = concat("Existance check for Event_Id",build(dudls_event_id))
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_process_event d
    WHERE d.dm_process_event_id=dudls_event_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET dm_err->eproc =
    "Unable to find the event_id in DM_PROCESS_EVENT. Bypass inserting of new details."
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   CALL dm2_process_log_add_detail_text("LAST_STATUS_MESSAGE",dudls_text)
   SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_date = dudls_date
   SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_number = dudls_number
   CALL dm2_process_log_dtl_row(dudls_event_id,1)
   IF (dudls_err_ind=1)
    SET dm_err->err_ind = dudls_err_ind
    SET dm_err->eproc = dudls_eproc
    SET dm_err->emsg = dudls_emsg
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpl_ui_chk(duc_process_name)
   DECLARE duc_event_col_exists = i2 WITH protect, noconstant(0)
   DECLARE duc_col_oradef_ind = i2 WITH protect, noconstant(0)
   DECLARE duc_col_ccldef_ind = i2 WITH protect, noconstant(0)
   DECLARE duc_data_type = vc WITH protect, noconstant("")
   IF ((dm2_process_event_rs->ui_allowed_ind >= 0)
    AND currdbuser="V500"
    AND (dm2_process_rs->dbase_name=currdbname))
    IF ((dm_err->debug_flag > 0))
     CALL echo(concat("Unattended install previously set:",build(dm2_process_event_rs->ui_allowed_ind
        )))
    ENDIF
    RETURN(1)
   ELSE
    IF ( NOT (currdbuser IN ("V500", "STATS", "CERN_DBSTATS")))
     SET dm2_process_event_rs->ui_allowed_ind = 0
     SET dm2_process_rs->table_exists_ind = 0
     SET dm2_process_rs->dbase_name = currdbname
     SET dm2_process_rs->filled_ind = 0
     IF ((dm_err->debug_flag > 0))
      CALL echo(concat("Unattended install not allowed. Current user is not V500. Current user is ",
        currdbuser))
     ENDIF
     RETURN(1)
    ENDIF
    SET dm2_process_event_rs->ui_allowed_ind = 1
    IF ( NOT (duc_process_name IN (dpl_notification, dpl_package_install, dpl_install_runner,
    dpl_background_runner, dpl_install_monitor)))
     SET dm2_process_event_rs->ui_allowed_ind = 0
     IF ((dm_err->debug_flag > 0))
      CALL echo(concat("Unattended install not allowed for ",duc_process_name))
     ENDIF
    ENDIF
    IF ((((dm2_process_rs->table_exists_ind=0)) OR ((dm2_process_rs->dbase_name != currdbname))) )
     SET dm2_process_rs->dbase_name = currdbname
     SET dm2_process_rs->filled_ind = 0
     SET duc_event_col_exists = 0
     SET duc_col_oradef_ind = 0
     SET dm_err->eproc = "Existance check for INSTALL_PLAN_ID and DETAIL_DT_TM"
     SELECT INTO "nl:"
      FROM dm2_user_tab_cols utc
      WHERE utc.table_name IN ("DM_PROCESS_EVENT", "DM_PROCESS_EVENT_DTL")
       AND utc.column_name IN ("INSTALL_PLAN_ID", "DETAIL_DT_TM")
      DETAIL
       IF (utc.table_name="DM_PROCESS_EVENT"
        AND utc.column_name="INSTALL_PLAN_ID")
        duc_col_oradef_ind = (duc_col_oradef_ind+ 1)
       ELSEIF (utc.table_name="DM_PROCESS_EVENT_DTL"
        AND utc.column_name="DETAIL_DT_TM")
        duc_col_oradef_ind = (duc_col_oradef_ind+ 1)
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (duc_col_oradef_ind=2)
      SET duc_col_ccldef_ind = 0
      SET duc_col_oradef_ind = 0
      IF (dm2_table_column_exists("","DM_PROCESS_EVENT","INSTALL_PLAN_ID",0,1,
       1,duc_col_oradef_ind,duc_col_ccldef_ind,duc_data_type)=0)
       RETURN(0)
      ENDIF
      IF (duc_col_ccldef_ind=1)
       SET duc_event_col_exists = (duc_event_col_exists+ 1)
      ENDIF
      SET duc_col_ccldef_ind = 0
      SET duc_col_oradef_ind = 0
      IF (dm2_table_column_exists("","DM_PROCESS_EVENT_DTL","DETAIL_DT_TM",0,1,
       1,duc_col_oradef_ind,duc_col_ccldef_ind,duc_data_type)=0)
       RETURN(0)
      ENDIF
      IF (duc_col_ccldef_ind=1)
       SET duc_event_col_exists = (duc_event_col_exists+ 1)
      ENDIF
     ENDIF
     IF (duc_event_col_exists < 2)
      IF ((dm_err->debug_flag > 0))
       CALL echo("Unattended install not allowed. Required schema does not yet exist")
      ENDIF
      SET dm2_process_event_rs->ui_allowed_ind = 0
      SET dm2_process_rs->table_exists_ind = 0
     ELSE
      SET dm2_process_rs->table_exists_ind = 1
     ENDIF
    ENDIF
    IF ((dm2_process_rs->table_exists_ind=1))
     SET dm_err->eproc = "Existance check for DM_CLINICAL_SEQ"
     SELECT INTO "nl:"
      FROM dba_sequences
      WHERE sequence_owner="V500"
       AND sequence_name="DM_CLINICAL_SEQ"
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (curqual=0)
      IF ((dm_err->debug_flag > 0))
       CALL echo("Unattended install not allowed. Required sequence does not yet exist")
      ENDIF
      SET dm2_process_event_rs->ui_allowed_ind = 0
      SET dm2_process_rs->table_exists_ind = 0
     ENDIF
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("Unattended install allowed:",build(dm2_process_event_rs->ui_allowed_ind)))
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_process_log_dtl_row(dpldr_event_log_id,ignore_errors)
   IF ((dm2_process_rs->table_exists_ind=0))
    RETURN(1)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm2_process_event_rs)
   ENDIF
   IF ((dm2_process_event_rs->detail_cnt > 0))
    SET dm_err->eproc = "Removing logging detail from dm_process_event_dtl."
    DELETE  FROM dm_process_event_dtl dtl,
      (dummyt d  WITH seq = value(dm2_process_event_rs->detail_cnt))
     SET dtl.seq = 0
     PLAN (d)
      JOIN (dtl
      WHERE dtl.dm_process_event_id=dpldr_event_log_id
       AND (dtl.detail_type=dm2_process_event_rs->details[d.seq].detail_type))
     WITH nocounter
    ;end delete
    IF (dpl_check_error(null))
     RETURN((1 - dm_err->err_ind))
    ENDIF
    SET dm_err->eproc = "Inserting logging detail into dm_process_event_dtl."
    INSERT  FROM dm_process_event_dtl dped,
      (dummyt d  WITH seq = value(dm2_process_event_rs->detail_cnt))
     SET dped.dm_process_event_dtl_id = seq(dm_clinical_seq,nextval), dped.dm_process_event_id =
      dpldr_event_log_id, dped.detail_type = dm2_process_event_rs->details[d.seq].detail_type,
      dped.detail_number = dm2_process_event_rs->details[d.seq].detail_number, dped.detail_text =
      dm2_process_event_rs->details[d.seq].detail_text, dped.detail_dt_tm = cnvtdatetime(
       dm2_process_event_rs->details[d.seq].detail_date)
     PLAN (d)
      JOIN (dped)
     WITH nocounter
    ;end insert
    IF (dpl_check_error(null))
     RETURN((1 - dm_err->err_ind))
    ENDIF
    COMMIT
   ENDIF
   SET dm2_process_event_rs->status = ""
   SET dm2_process_event_rs->message = ""
   SET dm2_process_event_rs->detail_cnt = 0
   SET dm2_process_event_rs->end_dt_tm = cnvtdatetime("01-JAN-1900")
   SET dm2_process_event_rs->begin_dt_tm = cnvtdatetime("01-JAN-1900")
   SET stat = alterlist(dm2_process_event_rs->details,0)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_process_log_row(process_name,action_type,prev_log_id,ignore_errors)
   IF (dpl_ui_chk(process_name)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_process_rs->table_exists_ind=0))
    RETURN(1)
   ENDIF
   DECLARE dplr_search = i4 WITH protect, noconstant(0)
   DECLARE dplr_event_id = f8 WITH protect, noconstant(prev_log_id)
   DECLARE dplr_stack = vc WITH protect, constant(dm2_get_program_stack(null))
   DECLARE dplr_process_name = vc WITH protect, constant(evaluate(dm2_process_rs->process_name,"",
     process_name,dm2_process_rs->process_name))
   DECLARE dplr_program_details = vc WITH protect, constant(curprog)
   DECLARE dplr_search_string = vc WITH protect, constant(build(dplr_process_name,"#",curprog,"#",
     action_type))
   SET dm2_process_rs->process_name = dplr_process_name
   IF ( NOT (dm2_process_rs->filled_ind))
    SET dm_err->eproc = "Querying for list of logged processes from dm_process."
    SELECT INTO "nl:"
     FROM dm_process dp
     HEAD REPORT
      dm2_process_rs->filled_ind = 1, dm2_process_rs->cnt = 0, stat = alterlist(dm2_process_rs->qual,
       0)
     DETAIL
      dm2_process_rs->cnt = (dm2_process_rs->cnt+ 1)
      IF (mod(dm2_process_rs->cnt,10)=1)
       stat = alterlist(dm2_process_rs->qual,(dm2_process_rs->cnt+ 9))
      ENDIF
      dm2_process_rs->qual[dm2_process_rs->cnt].dm_process_id = dp.dm_process_id, dm2_process_rs->
      qual[dm2_process_rs->cnt].process_name = dp.process_name, dm2_process_rs->qual[dm2_process_rs->
      cnt].program_name = dp.program_name,
      dm2_process_rs->qual[dm2_process_rs->cnt].action_type = dp.action_type, dm2_process_rs->qual[
      dm2_process_rs->cnt].search_string = build(dp.process_name,"#",dp.program_name,"#",dp
       .action_type)
     FOOT REPORT
      stat = alterlist(dm2_process_rs->qual,dm2_process_rs->cnt)
     WITH nocounter, nullreport
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (prev_log_id=0)
    IF ( NOT (assign(dplr_search,locateval(dplr_search,1,dm2_process_rs->cnt,dplr_search_string,
      dm2_process_rs->qual[dplr_search].search_string))))
     SET dm_err->eproc = "Getting next sequence for new process from dm_clinical_seq."
     SELECT INTO "nl:"
      id = seq(dm_clinical_seq,nextval)
      FROM dual
      DETAIL
       dm2_process_rs->dm_process_id = id
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = "Inserting new process into dm_process."
     INSERT  FROM dm_process dp
      SET dp.dm_process_id = dm2_process_rs->dm_process_id, dp.process_name = dm2_process_rs->
       process_name, dp.program_name = curprog,
       dp.action_type = action_type
      WITH nocounter
     ;end insert
     IF (dpl_check_error(null))
      RETURN((1 - dm_err->err_ind))
     ENDIF
     COMMIT
     SET dm2_process_rs->cnt = (dm2_process_rs->cnt+ 1)
     SET stat = alterlist(dm2_process_rs->qual,dm2_process_rs->cnt)
     SET dm2_process_rs->qual[dm2_process_rs->cnt].dm_process_id = dm2_process_rs->dm_process_id
     SET dm2_process_rs->qual[dm2_process_rs->cnt].process_name = dm2_process_rs->process_name
     SET dm2_process_rs->qual[dm2_process_rs->cnt].program_name = curprog
     SET dm2_process_rs->qual[dm2_process_rs->cnt].action_type = action_type
     SET dm2_process_rs->qual[dm2_process_rs->cnt].search_string = dplr_search_string
     SET dplr_search = dm2_process_rs->cnt
    ENDIF
    SET dm2_process_rs->dm_process_id = dm2_process_rs->qual[dplr_search].dm_process_id
    SET dm_err->eproc = "Getting next sequence for log row."
    SELECT INTO "nl:"
     id = seq(dm_clinical_seq,nextval)
     FROM dual
     DETAIL
      dplr_event_id = id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Inserting logging row into dm_process_event."
    INSERT  FROM dm_process_event dpe
     SET dpe.dm_process_event_id = dplr_event_id, dpe.install_plan_id = dm2_process_event_rs->
      install_plan_id, dpe.dm_process_id = dm2_process_rs->dm_process_id,
      dpe.program_stack = dplr_stack, dpe.program_details = dplr_program_details, dpe.begin_dt_tm =
      IF (process_name=dpl_package_install
       AND action_type=dpl_itinerary_event) cnvtdatetime(dm2_process_event_rs->begin_dt_tm)
      ELSE cnvtdatetime(curdate,curtime3)
      ENDIF
      ,
      dpe.username = dpl_username, dpe.event_status = dm2_process_event_rs->status, dpe.message_txt
       = dm2_process_event_rs->message
     WITH nocounter
    ;end insert
    IF (dpl_check_error(null))
     RETURN((1 - dm_err->err_ind))
    ENDIF
    IF (action_type=dpl_auditlog
     AND process_name IN (dpl_package_install, dpl_install_monitor, dpl_background_runner,
    dpl_install_runner))
     IF ((dir_ui_misc->dm_process_event_id > 0))
      CALL dm2_process_log_add_detail_number(dpl_execution_dpe_id,dir_ui_misc->dm_process_event_id)
     ENDIF
     IF ((dm2_process_event_rs->itinerary_process_event_id > 0))
      CALL dm2_process_log_add_detail_number(dpl_itinerary_dpe_id,dm2_process_event_rs->
       itinerary_process_event_id)
     ENDIF
     IF (trim(dm2_process_event_rs->itinerary_key) > "")
      CALL dm2_process_log_add_detail_text(dpl_itinerary_key_name,dm2_process_event_rs->itinerary_key
       )
     ENDIF
    ENDIF
    IF ((dm2_process_event_rs->detail_cnt > 0))
     SET dm_err->eproc = "Inserting logging detail into dm_process_event_dtl."
     INSERT  FROM dm_process_event_dtl dped,
       (dummyt d  WITH seq = value(dm2_process_event_rs->detail_cnt))
      SET dped.dm_process_event_dtl_id = seq(dm_clinical_seq,nextval), dped.dm_process_event_id =
       dplr_event_id, dped.detail_type = dm2_process_event_rs->details[d.seq].detail_type,
       dped.detail_number = dm2_process_event_rs->details[d.seq].detail_number, dped.detail_text =
       dm2_process_event_rs->details[d.seq].detail_text, dped.detail_dt_tm = cnvtdatetime(
        dm2_process_event_rs->details[d.seq].detail_date)
      PLAN (d)
       JOIN (dped)
      WITH nocounter
     ;end insert
    ENDIF
    IF (dpl_check_error(null))
     RETURN((1 - dm_err->err_ind))
    ENDIF
    COMMIT
   ELSE
    SET dm_err->eproc = "Updating existing logging row in dm_process_event."
    UPDATE  FROM dm_process_event dpe
     SET dpe.end_dt_tm =
      IF (cnvtdatetime(dm2_process_event_rs->end_dt_tm)=cnvtdatetime("01-JAN-1900")
       AND process_name=dpl_package_install
       AND action_type=dpl_itinerary_event) dpe.end_dt_tm
      ELSEIF (cnvtdatetime(dm2_process_event_rs->end_dt_tm) > cnvtdatetime("01-JAN-1900")
       AND process_name=dpl_package_install
       AND action_type=dpl_itinerary_event) cnvtdatetime(dm2_process_event_rs->end_dt_tm)
      ELSE cnvtdatetime(curdate,curtime3)
      ENDIF
      , dpe.begin_dt_tm =
      IF (cnvtdatetime(dm2_process_event_rs->begin_dt_tm)=cnvtdatetime("01-JAN-1900")
       AND process_name=dpl_package_install
       AND action_type=dpl_itinerary_event) dpe.begin_dt_tm
      ELSEIF (cnvtdatetime(dm2_process_event_rs->begin_dt_tm) > cnvtdatetime("01-JAN-1900")
       AND process_name=dpl_package_install
       AND action_type=dpl_itinerary_event) cnvtdatetime(dm2_process_event_rs->begin_dt_tm)
      ELSEIF (process_name=dpl_package_install
       AND action_type=dpl_itinerary_event) cnvtdatetime(curdate,curtime3)
      ELSE dpe.begin_dt_tm
      ENDIF
      , dpe.event_status = evaluate(dm2_process_event_rs->status,"",dpe.event_status,
       dm2_process_event_rs->status),
      dpe.message_txt = evaluate(dm2_process_event_rs->message,"",dpe.message_txt,
       dm2_process_event_rs->message), dpe.program_details = dplr_program_details
     WHERE dpe.dm_process_event_id=dplr_event_id
     WITH nocounter
    ;end update
    IF (dpl_check_error(null))
     RETURN((1 - dm_err->err_ind))
    ENDIF
    COMMIT
   ENDIF
   SET dm2_process_event_rs->dm_process_event_id = dplr_event_id
   SET dm2_process_event_rs->status = ""
   SET dm2_process_event_rs->message = ""
   SET dm2_process_event_rs->detail_cnt = 0
   SET dm2_process_event_rs->end_dt_tm = 0
   SET dm2_process_event_rs->begin_dt_tm = 0
   SET dm2_process_event_rs->install_plan_id = 0.0
   SET stat = alterlist(dm2_process_event_rs->details,0)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpl_check_error(null)
   IF (check_error(dm_err->eproc))
    ROLLBACK
    IF ( NOT (ignore_errors))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ELSE
     SET dm_err->err_ind = 0
     CALL echo("The above error is ignorable.")
    ENDIF
   ENDIF
   IF (dm_err->err_ind)
    SET dm2_process_event_rs->status = ""
    SET dm2_process_event_rs->message = ""
    SET dm2_process_event_rs->detail_cnt = 0
    SET stat = alterlist(dm2_process_event_rs->details,0)
    SET dm2_process_event_rs->dm_process_event_id = 0.0
   ENDIF
   RETURN(dm_err->err_ind)
 END ;Subroutine
 SUBROUTINE dm2_process_log_add_detail_text(detail_type,detail_text)
   SET dm2_process_event_rs->detail_cnt = (dm2_process_event_rs->detail_cnt+ 1)
   SET stat = alterlist(dm2_process_event_rs->details,dm2_process_event_rs->detail_cnt)
   SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_type = detail_type
   SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_text = detail_text
 END ;Subroutine
 SUBROUTINE dm2_process_log_add_detail_date(detail_type,detail_date)
   SET dm2_process_event_rs->detail_cnt = (dm2_process_event_rs->detail_cnt+ 1)
   SET stat = alterlist(dm2_process_event_rs->details,dm2_process_event_rs->detail_cnt)
   SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_type = detail_type
   SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_date = detail_date
 END ;Subroutine
 SUBROUTINE dm2_process_log_add_detail_number(detail_type,detail_number)
   SET dm2_process_event_rs->detail_cnt = (dm2_process_event_rs->detail_cnt+ 1)
   SET stat = alterlist(dm2_process_event_rs->details,dm2_process_event_rs->detail_cnt)
   SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_type = detail_type
   SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_number = detail_number
 END ;Subroutine
 DECLARE der_email_setup(des_process_name=vc) = i2
 DECLARE der_fill_email_list(dfel_process_name=vc) = i2
 DECLARE der_send_email(process_name=vc,subject=vc,file_name=vc) = i2
 DECLARE der_send_test_emails(dste_process_name=vc) = i2
 IF ((validate(der_emails->cnt,- (1))=- (1))
  AND validate(der_emails->cnt,1)=1)
  FREE RECORD der_emails
  RECORD der_emails(
    1 change_ind = i2
    1 email_list = vc
    1 cnt = i4
    1 qual[*]
      2 email_address = vc
  )
  SET der_emails->cnt = 0
 ENDIF
 SUBROUTINE der_email_setup(des_process_name)
   DECLARE des_iter = i4 WITH protect, noconstant(0)
   DECLARE des_index = i4 WITH protect, noconstant(0)
   DECLARE des_remove_location = i4 WITH protect, noconstant(0)
   IF (der_fill_email_list(des_process_name)=0)
    RETURN(0)
   ENDIF
   WHILE (true)
     SET width = 132
     IF ((dm_err->debug_flag != 722))
      SET message = window
     ENDIF
     CALL clear(1,1)
     CALL box(1,1,24,131)
     CALL text(2,2,"Setup Email Addresses")
     FOR (des_index = 1 TO least(15,der_emails->cnt))
       CALL text((3+ des_index),4,concat(build(des_index),".  ",der_emails->qual[des_index].
         email_address))
     ENDFOR
     IF ((der_emails->cnt=0))
      CALL text(23,2,"(A)dd new email address, (Q)uit without saving: ")
      CALL accept(23,50,"A;CU","A"
       WHERE curaccept IN ("A", "Q"))
     ELSEIF (textlen(der_emails->email_list) > 255)
      CALL text(20,2,concat("Combined length of email addresses is: ",build(textlen(der_emails->
          email_list)),". Max allowable length is 255."))
      CALL text(21,2,concat("Please remove some email addresses or create a distribution list."))
      CALL text(23,2,concat("(R)emove existing email address, (Q)uit without saving: "))
      CALL accept(23,59,"A;CU","R"
       WHERE curaccept IN ("R", "Q"))
     ELSEIF ((der_emails->cnt=1))
      CALL text(23,2,
       "(A)dd new email address, (S)ave and Exit, (T)est email addresses, (Q)uit without saving: ")
      CALL accept(23,91,"A;CU","A"
       WHERE curaccept IN ("A", "S", "T", "Q"))
     ELSEIF ((der_emails->cnt < 15))
      CALL text(23,2,concat(
        "(A)dd new email address, (R)emove existing email address, (S)ave and Exit,",
        " (T)est email addresses, (Q)uit without saving: "))
      CALL accept(23,124,"A;CU","S"
       WHERE curaccept IN ("A", "R", "S", "T", "Q"))
     ELSE
      CALL text(23,2,
       "(R)emove existing email address, (S)ave and Exit, (T)est email addresses, (Q)uit without saving: "
       )
      CALL accept(23,99,"A;CU","Q"
       WHERE curaccept IN ("R", "S", "T", "Q"))
     ENDIF
     CASE (curaccept)
      OF "A":
       CALL clear(21,2,129)
       CALL text(21,2,"Email Address to Add:")
       CALL accept(21,24,"P(80);CHU","NONE"
        WHERE ((findstring("@",curaccept) > 0
         AND findstring(".",curaccept) > 0
         AND findstring("@",curaccept) < findstring(".",curaccept,1,1)) OR (curaccept="NONE")) )
       IF (curaccept != "NONE"
        AND locateval(des_index,1,der_emails->cnt,curaccept,der_emails->qual[des_index].email_address
        )=0)
        SET der_emails->cnt = (der_emails->cnt+ 1)
        SET stat = alterlist(der_emails->qual,der_emails->cnt)
        SET der_emails->qual[der_emails->cnt].email_address = curaccept
        SET der_emails->change_ind = 1
       ENDIF
       CALL clear(21,2,129)
      OF "R":
       CALL clear(21,2,129)
       CALL text(21,2,"Email Address to Remove, by number:")
       CALL accept(21,38,"99;H",0
        WHERE curaccept BETWEEN 0 AND der_emails->cnt)
       SET des_remove_location = curaccept
       IF (des_remove_location > 0)
        FOR (des_iter = des_remove_location TO (der_emails->cnt - 1))
          SET der_emails->qual[des_iter].email_address = der_emails->qual[(des_iter+ 1)].
          email_address
        ENDFOR
        SET stat = alterlist(der_emails->qual,(der_emails->cnt - 1))
        SET der_emails->cnt = (der_emails->cnt - 1)
        SET der_emails->change_ind = 1
       ENDIF
       CALL clear(21,2,129)
      OF "S":
       IF ((der_emails->change_ind=1))
        SET dm_err->eproc = "Deleting existing email rows from dm_info."
        DELETE  FROM dm_info di
         WHERE di.info_domain=value(build("DM2_EMAIL:",des_process_name))
         WITH nocounter
        ;end delete
        IF (check_error(dm_err->eproc)=1)
         ROLLBACK
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
        IF ((der_emails->cnt > 0))
         SET dm_err->eproc = "Inserting new email rows into dm_info."
         INSERT  FROM dm_info di,
           (dummyt d  WITH seq = value(der_emails->cnt))
          SET di.info_domain = value(build("DM2_EMAIL:",des_process_name)), di.info_name = der_emails
           ->qual[d.seq].email_address
          PLAN (d)
           JOIN (di)
          WITH nocounter
         ;end insert
         IF (check_error(dm_err->eproc)=1)
          ROLLBACK
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          RETURN(0)
         ENDIF
        ENDIF
        COMMIT
       ENDIF
       CALL clear(23,2,129)
       CALL text(23,2,"Changes have been saved.  Would you like to send a test email?")
       CALL accept(23,65,"A;CU","Y"
        WHERE curaccept IN ("Y", "N"))
       CASE (curaccept)
        OF "Y":
         RETURN(der_send_test_emails(des_process_name))
        OF "N":
         RETURN(1)
       ENDCASE
      OF "T":
       IF (der_send_test_emails(des_process_name)=0)
        RETURN(0)
       ENDIF
       CALL text(21,2,"A test email has been sent.  Press <enter> to continue.")
       CALL accept(21,58,"A;CH"," ")
       CALL clear(21,2,129)
      OF "Q":
       RETURN(1)
     ENDCASE
     FOR (des_iter = 1 TO der_emails->cnt)
       IF (des_iter=1)
        SET der_emails->email_list = der_emails->qual[des_iter].email_address
       ELSE
        SET der_emails->email_list = concat(der_emails->email_list,",",der_emails->qual[des_iter].
         email_address)
       ENDIF
     ENDFOR
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE der_fill_email_list(dfel_process_name)
   SET dm_err->eproc = "Querying for list of email addresses from dm_info."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=value(build("DM2_EMAIL:",dfel_process_name))
    ORDER BY di.info_name
    HEAD REPORT
     der_emails->change_ind = 0, der_emails->cnt = 0, stat = alterlist(der_emails->qual,der_emails->
      cnt),
     der_emails->email_list = ""
    DETAIL
     der_emails->cnt = (der_emails->cnt+ 1), stat = alterlist(der_emails->qual,der_emails->cnt),
     der_emails->qual[der_emails->cnt].email_address = di.info_name
     IF ((der_emails->cnt=1))
      der_emails->email_list = di.info_name
     ELSE
      der_emails->email_list = concat(der_emails->email_list,",",di.info_name)
     ENDIF
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE der_send_email(process_name,subject,file_name)
   IF (((trim(subject)="") OR (trim(file_name)="")) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Verifying input parameters."
    SET dm_err->emsg = "Input parameters <Subject, File Name> can not be blank."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((der_emails->cnt > 0))
    IF ((dm2_sys_misc->cur_os="AXP"))
     IF (dm2_push_dcl(concat('MAIL/SUBJECT="',build(subject),'" ',build(file_name),' "',
       build(der_emails->email_list),'"'))=0)
      RETURN(0)
     ENDIF
    ELSEIF ((dm2_sys_misc->cur_os IN ("AIX", "LNX")))
     IF (dm2_push_dcl(concat('mail -s "',subject,'" "',der_emails->email_list,'" < ',
       file_name))=0)
      RETURN(0)
     ENDIF
    ELSEIF ((dm2_sys_misc->cur_os="HPX"))
     IF (dm2_push_dcl(concat('mailx -s "',subject,'" "',der_emails->email_list,'" < ',
       file_name))=0)
      RETURN(0)
     ENDIF
    ENDIF
   ELSE
    SET dm_err->eproc = "Unable to retrieve list of email addresses to send error notification."
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE der_send_test_emails(dste_process_name)
   DECLARE dste_test_file_name = vc WITH protect, noconstant("")
   DECLARE dste_iter = i4 WITH protect, noconstant(0)
   DECLARE dste_email_list = vc WITH protect, noconstant("")
   SET dste_test_file_name = build(logical("CCLUSERDIR"),evaluate(dm2_sys_misc->cur_os,"AXP",
     "dm2_email_test.txt","/dm2_email_test.txt"))
   SET dm_err->eproc = "Attempting to create a test file to be emailed."
   SELECT INTO value(dste_test_file_name)
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     row + 1, "This is a test email"
    WITH nocounter, maxcol = 100, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   FOR (dste_iter = 1 TO der_emails->cnt)
     IF (dste_iter=1)
      SET der_emails->email_list = der_emails->qual[dste_iter].email_address
     ELSE
      SET der_emails->email_list = concat(der_emails->email_list,",",der_emails->qual[dste_iter].
       email_address)
     ENDIF
   ENDFOR
   RETURN(der_send_email(dste_process_name,"Test email",dste_test_file_name))
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
 DECLARE dnv_data_type = vc WITH protect, noconstant("")
 DECLARE dnv_data_default = vc WITH protect, noconstant("")
 DECLARE dnv_cont = i2 WITH protect, noconstant(1)
 DECLARE dnv_time_window_ind = i2 WITH protect, noconstant(0)
 DECLARE dnv_log_id = f8 WITH protect, noconstant(0.0)
 DECLARE dnv_err_ind = i2 WITH protect, noconstant(0)
 DECLARE dnv_err_msg = vc WITH protect, noconstant("")
 DECLARE dnv_owner = vc WITH protect, noconstant("")
 DECLARE dnv_table_name = vc WITH protect, noconstant("")
 DECLARE dnv_column_name = vc WITH protect, noconstant("")
 DECLARE dnv_constraint_name = vc WITH protect, noconstant("")
 DECLARE dnv_dr_trigger_name = vc WITH protect, noconstant("")
 DECLARE dnv_begin_dt_tm = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE dnv_parent = vc WITH protect, noconstant("")
 DECLARE dnv_email_emsg = vc WITH protect, noconstant("")
 DECLARE dnv_email_eproc = vc WITH protect, noconstant("")
 DECLARE dnv_email_type = vc WITH protect, noconstant("")
 DECLARE dnv_sql_stmt = vc WITH protect, noconstant("")
 DECLARE dnv_trg_stmt = vc WITH protect, noconstant("")
 DECLARE dnv_env_name = vc WITH protect, noconstant("N/A")
 DECLARE dnv_client_mnemonic = vc WITH protect, noconstant("N/A")
 DECLARE dnv_ignore_err = i2 WITH protect, noconstant(0)
 DECLARE dnv_retry_cnt = i4 WITH protect, noconstant(0)
 DECLARE dnv_retry_limit = i4 WITH protect, noconstant(0)
 DECLARE dnv_retry_ind = i2 WITH protect, noconstant(0)
 DECLARE dnv_handle_dr_trg_error(null) = i2
 DECLARE dnv_show_query_preview(null) = i2
 IF (check_logfile("dm2_notnull_validate",".log","dm2_notnull_validate LOGFILE")=0)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Beginning dm2_notnull_validate."
 CALL disp_msg(" ",dm_err->logfile,0)
 SET dm_err->eproc = "Verifying and storing input parameters."
 SET dnv_owner = cnvtupper( $1)
 SET dnv_table_name = cnvtupper( $2)
 SET dnv_column_name = cnvtupper( $3)
 SET dnv_constraint_name = cnvtupper( $4)
 IF (check_error(dm_err->eproc)=1)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat(
   "Parameter usage: dm2_notnull_validate '<owner>','<table_name>','<column_name>','<constraint_name>'"
   )
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Validating <user> input parameter."
 IF (dnv_owner != cnvtupper(currdbuser))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = build("Owner parameter must be set to current user <",currdbuser,">")
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (dm2_get_rdbms_version(null)=0)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Retrieve NNV operation retry limit from dm_info"
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DM2_NOTNULL_VALIDATE"
   AND di.info_name="OPERATION_RETRY_LIMIT"
  DETAIL
   dnv_retry_limit = di.info_number
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (curqual=0)
  SET dnv_retry_limit = 2400
 ENDIF
 SET dm2_process_rs->process_name = dpl_notnull_validate
 SET dm2_process_event_rs->status = dpl_executing
 CALL dm2_process_log_add_detail_text(dpl_constraint,dnv_constraint_name)
 CALL dm2_process_log_add_detail_text(dpl_owner,dnv_owner)
 CALL dm2_process_log_add_detail_text(dpl_table,dnv_table_name)
 CALL dm2_process_log_add_detail_text(dpl_column,dnv_column_name)
 IF (dm2_process_log_row(dpl_notnull_validate,dpl_execution,dpl_no_prev_id,1)=0)
  GO TO exit_program
 ENDIF
 SET dnv_log_id = dm2_process_event_rs->dm_process_event_id
 SET dm_err->eproc = concat("Attempting to validate constraint <",dnv_constraint_name,
  "> for column <",dnv_column_name,"> on table <",
  dnv_table_name,">")
 CALL disp_msg("",dm_err->logfile,0)
 IF ((program_stack_rs->qual[1].name="DM2_ROUTINE_TASKS"))
  SET dnv_parent = dpq_routine_tasks
 ELSE
  SET dnv_parent = dpq_notnull_validate
 ENDIF
 IF (dpq_check_end_time(dnv_begin_dt_tm,dnv_parent,dnv_time_window_ind)=0)
  GO TO exit_program
 ELSEIF ( NOT (dnv_time_window_ind))
  SET dm_err->eproc = "End time window reached, ending dm2_notnull_validate"
  CALL disp_msg("",dm_err->logfile,0)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = concat("Gathering data default for column ",dnv_column_name," on table ",
  dnv_table_name)
 IF ((dm_err->debug_flag > 0))
  CALL disp_msg("",dm_err->logfile,0)
 ENDIF
 SELECT INTO "nl:"
  FROM user_tab_columns utc
  WHERE utc.table_name=dnv_table_name
   AND utc.column_name=dnv_column_name
  DETAIL
   dnv_data_type = utc.data_type
   IF (((nullind(utc.data_default)) OR (((cnvtupper(utc.data_default)="NULL") OR (((utc.data_default=
   "' '") OR (utc.data_default='" "')) )) )) )
    IF (((utc.data_type="FLOAT") OR (utc.data_type="NUMBER")) )
     dnv_data_default = "0"
    ELSEIF (utc.data_type="DATE")
     dnv_data_default = "to_date('1/1/1900','MM/DD/YYYY')"
    ELSE
     dnv_data_default = "' '"
    ENDIF
   ELSE
    dnv_data_default = utc.data_default
   ENDIF
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (dnv_data_type IN ("LONG", "LONG RAW", "BLOB", "CLOB"))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat(dnv_data_type," data type is NOT supported for the current operation")
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = concat("Get constraint exception details from dm_constraint_exceptions for: ",
  dnv_constraint_name)
 IF ((dm_err->debug_flag > 0))
  CALL disp_msg("",dm_err->logfile,0)
 ENDIF
 SELECT INTO "nl:"
  FROM dm_constraint_exceptions dce
  WHERE dce.owner=dnv_owner
   AND dce.table_name=dnv_table_name
   AND dce.constraint=dnv_constraint_name
  WITH nocounter, maxqual = 1
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (curqual > 0)
  IF ((validate(dm2_only_preview_op,- (1))=- (1)))
   SET dnv_cont = 1
   SET dnv_sql_stmt = concat("rdb asis(^UPDATE ",dnv_owner,".",dnv_table_name," SET ",
    dnv_column_name," = ",dnv_data_default," WHERE ",dnv_column_name,
    " is NULL and rowid in "," (SELECT ROW_ID FROM DM_CONSTRAINT_EXCEPTIONS "," WHERE OWNER = '",
    dnv_owner,"' AND TABLE_NAME = '",
    dnv_table_name,"'"," AND CONSTRAINT = '",dnv_constraint_name,"')",
    " AND ROWNUM <= 10000","^) go")
   WHILE (dnv_cont=1)
     IF (dpq_check_end_time(dnv_begin_dt_tm,dnv_parent,dnv_time_window_ind)=0)
      GO TO exit_program
     ELSEIF ( NOT (dnv_time_window_ind))
      SET dm_err->eproc = "End time window reached, ending dm2_notnull_validate"
      CALL disp_msg("",dm_err->logfile,0)
      GO TO exit_program
     ENDIF
     SET dm_err->eproc = concat("Updating rows in ",dnv_table_name,"with data default for ",
      dnv_column_name)
     EXECUTE dm2_notnull_validate_c value(dnv_sql_stmt)
     IF ((dm_err->err_ind=1))
      ROLLBACK
      IF (findstring("ORA-20100",dm_err->emsg) > 0)
       SET dm_err->eproc = concat("The ORA-20100 (default row trigger) error for <",dnv_table_name,
        "> is acceptable. Fixing errors.")
       CALL disp_msg("",dm_err->logfile,0)
       SET dm_err->err_ind = 0
       CALL dm2_process_log_add_detail_text("DEFAULT_ROW_NULL_PK_COL",build(dnv_table_name,":",
         dnv_column_name))
       CALL dm2_process_log_dtl_row(dnv_log_id,0)
       SET dm_err->eproc = concat("Retrieve default row trigger for ",dnv_table_name)
       SELECT INTO "nl:"
        FROM user_triggers ut
        WHERE ut.table_name=value(dnv_table_name)
         AND ut.trigger_name=patstring("TRG_*_DR_UPDT_DEL")
        DETAIL
         dnv_dr_trigger_name = ut.trigger_name
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_program
       ENDIF
       IF (dnv_dr_trigger_name > " ")
        SET dm_err->eproc = concat("Disable default row trigger for ",dnv_table_name)
        SET dnv_trg_stmt = concat("rdb asis(^ALTER TRIGGER ",dnv_dr_trigger_name," DISABLE","^) go")
        EXECUTE dm2_notnull_validate_c value(dnv_trg_stmt)
        IF ((dm_err->err_ind=1))
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         GO TO exit_program
        ENDIF
        SET dm_err->eproc = concat("Updating rows in ",dnv_table_name,"with data default for ",
         dnv_column_name)
        EXECUTE dm2_notnull_validate_c value(dnv_sql_stmt)
        IF ((dm_err->err_ind=1))
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         ROLLBACK
         GO TO exit_program
        ENDIF
        COMMIT
        SET dm_err->eproc = concat("Enable default row trigger for ",dnv_table_name)
        SET dnv_trg_stmt = concat("rdb asis(^ALTER TRIGGER ",dnv_dr_trigger_name," ENABLE","^) go")
        EXECUTE dm2_notnull_validate_c value(dnv_trg_stmt)
        IF ((dm_err->err_ind=1))
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         GO TO exit_program
        ENDIF
        SET dnv_dr_trigger_name = ""
       ELSE
        SET dm_err->err_ind = 1
        SET dm_err->emsg = concat("Unable to identify default row trigger for: ",dnv_table_name)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_program
       ENDIF
      ELSE
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       GO TO exit_program
      ENDIF
     ENDIF
     COMMIT
     IF (curqual=0)
      SET dnv_cont = 0
     ENDIF
   ENDWHILE
   SET dnv_cont = 1
   SET dnv_sql_stmt = concat("rdb asis(^DELETE FROM DM_CONSTRAINT_EXCEPTIONS DCE",
    " WHERE DCE.OWNER = '",dnv_owner,"'"," AND DCE.TABLE_NAME = '",
    dnv_table_name,"'"," AND DCE.CONSTRAINT = '",dnv_constraint_name,"'",
    " AND ROWNUM <= 10000","^) go")
   WHILE (dnv_cont=1)
     SET dm_err->eproc = concat(
      "Deleting rows in dm_constraint_exceptions corresponding to rows updated in ",dnv_table_name)
     EXECUTE dm2_notnull_validate_c value(dnv_sql_stmt)
     IF ((dm_err->err_ind=1))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      GO TO exit_program
     ENDIF
     COMMIT
     IF (curqual=0)
      SET dnv_cont = 0
     ENDIF
   ENDWHILE
  ENDIF
 ENDIF
 IF ((validate(dm2_only_preview_op,- (1))=- (1)))
  SET dnv_retry_ind = 1
  SET dnv_retry_cnt = 0
  WHILE (dnv_retry_ind=1
   AND dnv_retry_cnt < dnv_retry_limit)
    SET dnv_retry_ind = 0
    SET dm_err->err_ind = 0
    SET dm_err->eproc = concat("Validating constraint <",dnv_constraint_name,"> on table <",
     dnv_table_name,">")
    CALL disp_msg("",dm_err->logfile,0)
    SET dnv_sql_stmt = concat("rdb asis(^ALTER TABLE ",dnv_table_name," MODIFY CONSTRAINT ",
     dnv_constraint_name," VALIDATE EXCEPTIONS INTO DM_CONSTRAINT_EXCEPTIONS",
     "^) go")
    EXECUTE dm2_notnull_validate_c value(dnv_sql_stmt)
    IF ((dm_err->err_ind=1))
     IF (findstring("ORA-02293",dm_err->emsg)=0)
      IF (findstring("ORA-00054",dm_err->emsg)=0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_program
      ELSE
       SET dnv_retry_ind = 1
       SET dnv_retry_cnt = (dnv_retry_cnt+ 1)
      ENDIF
     ELSE
      SET dm_err->eproc = "Above ORA-02293 Error is acceptable"
      CALL disp_msg("",dm_err->logfile,0)
      SET dnv_ignore_err = 1
     ENDIF
    ENDIF
  ENDWHILE
 ELSE
  IF (dnv_show_query_preview(null)=0)
   GO TO exit_program
  ENDIF
 ENDIF
 GO TO exit_program
 SUBROUTINE dnv_show_query_preview(null)
   DECLARE dnv_query_file = vc WITH protect, noconstant("")
   SET dm_err->eproc = build("Create not null validate query preview file for constraint ",
    dnv_constraint_name)
   CALL disp_msg("",dm_err->logfile,0)
   IF (get_unique_file(build("dnv_",dnv_constraint_name),".dat")=0)
    RETURN(0)
   ELSE
    SET dnv_query_file = dm_err->unique_fname
   ENDIF
   SET dm_err->eproc = "Creating file for Not Null Validate query preview"
   SELECT INTO value(dnv_query_file)
    FROM dummyt d
    DETAIL
     row + 1, col 0,
     CALL print(concat("CONSTRAINT VALIDATION:")),
     row + 1, col 0,
     CALL print(concat(
      "The constraint is validated as follows. Exceptions are logged to dm_constraint_exceptions")),
     row + 1, row + 1, col 3,
     CALL print(concat("rdb ALTER TABLE ",dnv_table_name)), row + 1, col 3,
     CALL print(concat("MODIFY CONSTRAINT ",dnv_constraint_name)), row + 1, col 3,
     CALL print(concat("VALIDATE EXCEPTIONS INTO DM_CONSTRAINT_EXCEPTIONS go")), row + 1, row + 1,
     col 0,
     CALL print(concat("COLUMN BACKFILL:")), row + 1,
     col 0,
     CALL print(concat("If constraint violations occur, ",
      "the following update will be run in a loop until no more null rows exist")), row + 1,
     row + 1, col 3,
     CALL print(concat("rdb UPDATE ",dnv_owner,".",dnv_table_name," ")),
     row + 1, col 3,
     CALL print(concat("SET ",dnv_column_name," = ",dnv_data_default)),
     row + 1, col 3,
     CALL print(concat("WHERE ",dnv_column_name," is NULL and rowid in (")),
     row + 1, col 3,
     CALL print(concat("  SELECT ROW_ID FROM DM_CONSTRAINT_EXCEPTIONS ")),
     row + 1, col 3,
     CALL print(concat("  WHERE OWNER = '",dnv_owner,"' AND TABLE_NAME = '",dnv_table_name,"'")),
     row + 1, col 3,
     CALL print(concat("  AND CONSTRAINT = '",dnv_constraint_name,"')")),
     row + 1, col 3,
     CALL print(concat("AND ROWNUM <= 10000")),
     row + 1, col 3,
     CALL print("go"),
     row + 1, row + 1, col 0,
     CALL print(concat("EXCEPTION REMOVAL:")), row + 1, col 0,
     CALL print(concat(
      "After the column backfill the corresponding exception rows will be deleted as follows")), row
      + 1, row + 1,
     col 3,
     CALL print(concat("rdb DELETE FROM DM_CONSTRAINT_EXCEPTIONS DCE")), row + 1,
     col 3,
     CALL print(concat("WHERE DCE.OWNER = '",dnv_owner,"'")), row + 1,
     col 3,
     CALL print(concat("AND DCE.TABLE_NAME = '",dnv_table_name,"'")), row + 1,
     col 3,
     CALL print(concat("AND DCE.CONSTRAINT = '",dnv_constraint_name,"'")), row + 1,
     col 3,
     CALL print(concat("AND ROWNUM <= 10000")), row + 1,
     col 3,
     CALL print("go"), row + 1
    WITH nocounter, maxcol = 500, formfeed = none,
     format = variable
   ;end select
   IF (check_error(dm_err->eproc))
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Displaying Not Null Validate File"
   IF (dm2_disp_file(dnv_query_file,build("Not-Null Validation Query for: ",dnv_constraint_name))=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_program
 IF ((dm_err->err_ind=1)
  AND dnv_ignore_err=0)
  SET dnv_email_eproc = dm_err->eproc
  SET dnv_email_emsg = dm_err->emsg
  SET dm_err->err_ind = 0
  CALL der_fill_email_list(dpq_notnull_validate)
  IF ((der_emails->cnt > 0))
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name IN ("DM_ENV_NAME", "CLIENT MNEMONIC")
    DETAIL
     IF (di.info_name="DM_ENV_NAME")
      dnv_env_name = di.info_char
     ELSEIF (di.info_name="CLIENT MNEMONIC")
      dnv_client_mnemonic = di.info_char
     ENDIF
    WITH nocounter
   ;end select
   CALL get_unique_file("dm2_nnv_err",".dat")
   SELECT INTO value(dm_err->unique_fname)
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     col 0,
     CALL print(concat("CLIENT: ",dnv_client_mnemonic)), row + 1,
     col 0,
     CALL print(concat("EMAIL_DT_TM: ",format(cnvtdatetime(curdate,curtime3),";;Q"))), row + 1,
     row + 1, col 0,
     CALL print("An error occured when attempting to validate the following constraint:"),
     row + 1, col 3,
     CALL print(concat("TABLE NAME:      ",dnv_table_name)),
     row + 1, col 3,
     CALL print(concat("COLUMN NAME:     ",dnv_column_name)),
     row + 1, col 3,
     CALL print(concat("CONSTRAINT NAME: ",dnv_constraint_name)),
     row + 1, row + 1, col 0,
     CALL print("The following operation was attempted:"), row + 1, col 3,
     CALL print(dnv_email_eproc), row + 1, row + 1,
     col 0,
     CALL print("The following error was received:"), row + 1,
     col 3,
     CALL print(dnv_email_emsg), row + 1,
     row + 1
     IF ((dm2_rdbms_version->level1 >= 11))
      dnv_email_type = dpl_actionreq, col 0,
      CALL print(concat("Not null constraint validation is required for ",
       "Oracles Cost Based Optimizer to function optimally.")),
      row + 1
     ELSE
      dnv_email_type = dpl_warning, col 0,
      CALL print(concat("Not null constraint validation is recommended to prepare ",
       "the database for conversion to Oracles Cost Based Optimizer.")),
      row + 1
     ENDIF
     row + 1, col 0,
     CALL print(
     "An Oracle Database Administrator should be engaged to troubleshoot any ORA- related errors."),
     row + 1, col 0,
     CALL print("Cerner support should be engaged for any other types of reported errors."),
     row + 1
    WITH nocounter, maxcol = 1000, format = variable
   ;end select
   CALL der_send_email(dpq_notnull_validate,concat(dpq_notnull_validate," | MSGTYPE: ",dnv_email_type,
     " | STATUS: ERROR"," | ENV: ",
     dnv_env_name),dm_err->unique_fname)
  ENDIF
  SET dm_err->err_ind = 1
  SET dm_err->emsg = dnv_email_emsg
  IF (dnv_dr_trigger_name > " ")
   SET dnv_trg_stmt = concat("rdb asis(^ALTER TRIGGER ",dnv_dr_trigger_name," ENABLE","^) go")
   EXECUTE dm2_notnull_validate_c value(dnv_trg_stmt)
  ENDIF
 ENDIF
 SET dm2_process_event_rs->status = evaluate(dm_err->err_ind,1,dpl_failure,dpl_success)
 SET dm2_process_event_rs->message = evaluate(dm_err->err_ind,1,dm_err->emsg,"")
 SET dnv_err_ind = dm_err->err_ind
 SET dnv_err_msg = dm_err->emsg
 SET dm_err->err_ind = 0
 CALL dm2_process_log_row(dpl_notnull_validate,dpl_execution,dnv_log_id,1)
 SET dm2_process_rs->process_name = ""
 SET dm_err->err_ind = dnv_err_ind
 SET dm_err->emsg = dnv_err_msg
 SET dm_err->eproc = "Ending dm2_notnull_validate."
 CALL final_disp_msg("dm2_notnull_validate")
END GO
