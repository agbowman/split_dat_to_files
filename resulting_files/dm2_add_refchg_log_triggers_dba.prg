CREATE PROGRAM dm2_add_refchg_log_triggers:dba
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
 DECLARE check_concurrent_snapshot(sbr_ccs_mode=c1) = i2
 DECLARE dir_row_count(rrc_table_name=vc,rrc_row_cnt=f8(ref)) = i2
 DECLARE dm2_get_appl_status(gas_appl_id=vc) = c1
 DECLARE dir_row_count(rrc_table_name=vc,rrc_row_cnt=f8(ref)) = i2
 DECLARE dir_ddl_token_replacement(ddtr_text_str=vc(ref)) = i2
 DECLARE dm2_fill_seq_list(alias=vc,col_name=vc) = vc
 DECLARE dir_add_silmode_entry(entry_name=vc,entry_filename=vc) = i2
 DECLARE dm2_cleanup_stranded_appl() = i2
 DECLARE dir_setup_batch_queue(dsbq_queue_name=vc) = i2
 DECLARE dir_sea_sch_files(directory=vc,file_prefix=vc,schema_date=vc(ref)) = i2
 DECLARE dm2_val_sch_date_str(sbr_datestr=vc) = i2
 DECLARE dm2_fill_sch_except(sbr_dfse_from=vc) = i2
 DECLARE dm2_push_adm_maint(sbr_maint_str=vc) = i2
 DECLARE dm2_setup_dbase_env(null) = i2
 DECLARE dm2_get_suffixed_tablename(tbl_name=vc) = i2
 DECLARE prompt_for_host(sbr_host_db=vc) = i2
 DECLARE dm2_val_file_prefix(sbr_file_prefix=vc) = i2
 DECLARE dm2_toolset_usage(null) = i2
 DECLARE dir_get_obsolete_objects(null) = i2
 DECLARE dir_find_data_file(dfdf_file_found=i2(ref)) = i2
 DECLARE dir_dm2_tables_tspace_assign(null) = i2
 DECLARE dir_get_debug_trace_data(null) = i2
 DECLARE dir_managed_ddl_setup(dmds_runid=f8) = i2
 DECLARE dir_perform_wait_interval(null) = i2
 DECLARE dir_get_storage_type(dgst_db_link=vc) = i2
 DECLARE dir_check_in_parse(dcp_owner=vc,dcp_table_name=vc,dcp_in_parse_ind=i2(ref),dcp_ret_msg=vc(
   ref)) = i2
 DECLARE dir_get_ddl_gen_retry(dgr_retry_ceiling=i2(ref)) = i2
 DECLARE dir_load_users_pwds(dlup_user_pwd=vc) = i2
 DECLARE dir_check_dm_ocd_setup_admin(dcdosa_requires_execution=i2(ref),dcdosa_install_mode=vc) = i2
 DECLARE dir_check_for_package(dcfp_valid_ind=i2(ref),dcfp_env_id=f8(ref)) = i2
 DECLARE dir_get_dg_data(dgdd_assign_dg_ind=i2,dgdd_dg_override=vc,dgdd_dg_out=vc(ref)) = i2
 DECLARE dir_submit_jobs(dsj_plan_id=f8,dsj_install_mode=vc,dsj_user=vc,dsj_pword=vc,dsj_cnnct_str=vc,
  dsj_queue_name=vc,dsj_background_ind=i2) = i2
 DECLARE dir_get_adm_appl_status(dgaps_dblink=vc,dgaps_audsid=vc,dgaps_status=vc(ref)) = i2
 DECLARE dir_upd_adm_upgrade_info(null) = i2
 DECLARE dir_get_custom_constraints(null) = i2
 DECLARE dir_alert_killed_appl(daka_load_ind=i2,daka_fmt_appl_id=vc,daka_kill_ind=i2(ref)) = i2
 DECLARE dir_get_admin_db_link(dgadl_report_fail_ind=i2,dgadl_admin_db_link=vc(ref),dgadl_fail_ind=i2
  (ref)) = i2
 IF (validate(dm2_db_options->lob_build_ind," ")=" ")
  FREE RECORD dm2_db_options
  RECORD dm2_db_options(
    1 load_ind = i2
    1 dm2_toolset_usage = vc
    1 cursor_commit_cnt = vc
    1 new_tspace_type = vc
    1 dmt_freelist_grp = vc
    1 lob_storage_bp = vc
    1 lob_pctversion = vc
    1 lob_build_ind = vc
    1 lob_chunk = vc
    1 lob_cache = vc
    1 lob_securefile_ind = vc
    1 lob_retention = vc
    1 lob_maxsize = vc
    1 table_monitoring = vc
    1 table_monitoring_maxretry = vc
    1 db_optimizer_category = vc
    1 dbstats_gather_method = vc
    1 cbf_maxrangegroups = vc
    1 resource_busy_maxretry = vc
    1 dbstats_chk_rpt = vc
    1 readme_space_calc = vc
    1 recompile_after_alter_tbl = vc
    1 add_nn_col_nobf_ind = vc
    1 create_index_invisible = vc
    1 use_initprm_assign_dg_ind = vc
    1 assign_dg_override = vc
    1 degree_of_parallel_max = vc
    1 degree_of_parallel = vc
  )
  SET dm2_db_options->load_ind = 0
  SET dm2_db_options->dm2_toolset_usage = "NOT_SET"
  SET dm2_db_options->cursor_commit_cnt = "NOT_SET"
  SET dm2_db_options->dmt_freelist_grp = "NOT_SET"
  SET dm2_db_options->lob_pctversion = "NOT_SET"
  SET dm2_db_options->lob_chunk = "NOT_SET"
  SET dm2_db_options->lob_cache = "NOT_SET"
  SET dm2_db_options->lob_build_ind = "NOT_SET"
  SET dm2_db_options->new_tspace_type = "NOT_SET"
  SET dm2_db_options->lob_storage_bp = "NOT_SET"
  SET dm2_db_options->table_monitoring = "NOT_SET"
  SET dm2_db_options->table_monitoring_maxretry = "NOT_SET"
  SET dm2_db_options->db_optimizer_category = "NOT_SET"
  SET dm2_db_options->dbstats_gather_method = "NOT_SET"
  SET dm2_db_options->cbf_maxrangegroups = "NOT_SET"
  SET dm2_db_options->resource_busy_maxretry = "NOT_SET"
  SET dm2_db_options->dbstats_chk_rpt = "NOT_SET"
  SET dm2_db_options->readme_space_calc = "NOT_SET"
  SET dm2_db_options->recompile_after_alter_tbl = "NOT_SET"
  SET dm2_db_options->add_nn_col_nobf_ind = "NOT_SET"
  SET dm2_db_options->create_index_invisible = "NOT_SET"
  SET dm2_db_options->lob_securefile_ind = "NOT_SET"
  SET dm2_db_options->lob_retention = "NOT_SET"
  SET dm2_db_options->lob_maxsize = "NOT_SET"
  SET dm2_db_options->use_initprm_assign_dg_ind = "NOT_SET"
  SET dm2_db_options->assign_dg_override = "NOT_SET"
  SET dm2_db_options->degree_of_parallel_max = "NOT_SET"
  SET dm2_db_options->degree_of_parallel = "NOT_SET"
 ENDIF
 IF (validate(dm2_table->full_table_name," ")=" ")
  FREE RECORD dm2_table
  RECORD dm2_table(
    1 full_table_name = vc
    1 suffixed_table_name = vc
    1 table_suffix = vc
  )
  SET dm2_table->full_table_name = " "
  SET dm2_table->suffixed_table_name = " "
  SET dm2_table->table_suffix = " "
 ENDIF
 IF (validate(dm2_common1->snapshot_id,5)=5)
  FREE RECORD dm2_common1
  RECORD dm2_common1(
    1 snapshot_id = i2
  )
  SET dm2_common1->snapshot_id = 0
 ENDIF
 IF (validate(dm2_sch_except->tcnt,- (1)) < 0)
  FREE RECORD dm2_sch_except
  RECORD dm2_sch_except(
    1 tcnt = i4
    1 tbl[*]
      2 tbl_name = vc
    1 seq_cnt = i4
    1 seq[*]
      2 seq_name = vc
  )
  SET dm2_sch_except->tcnt = 0
  SET dm2_sch_except->seq_cnt = 0
 ENDIF
 IF ((validate(dm2_install_rec->snapshot_dt_tm,- (1))=- (1)))
  FREE RECORD dm2_install_rec
  RECORD dm2_install_rec(
    1 snapshot_dt_tm = f8
  )
 ENDIF
 IF (validate(dir_install_misc->ddl_failed_ind,1)=1
  AND validate(dir_install_misc->ddl_failed_ind,2)=2)
  FREE RECORD dir_install_misc
  RECORD dir_install_misc(
    1 ddl_failed_ind = i2
  )
  SET dir_install_misc->ddl_failed_ind = 0
 ENDIF
 IF ((validate(dir_silmode_requested_ind,- (1))=- (1))
  AND (validate(dir_silmode_requested_ind,- (2))=- (2)))
  DECLARE dir_silmode_requested_ind = i2 WITH public, noconstant(0)
 ENDIF
 IF (validate(dir_silmode->cnt,1)=1
  AND validate(dir_silmode->cnt,2)=2)
  FREE RECORD dir_silmode
  RECORD dir_silmode(
    1 cnt = i4
    1 qual[*]
      2 name = vc
      2 filename = vc
  )
  SET dir_silmode->cnt = 0
 ENDIF
 IF (validate(dir_batch_queue,"X")="X"
  AND validate(dir_batch_queue,"Y")="Y")
  DECLARE dir_batch_queue = vc WITH public, constant(cnvtlower(build("INSTALL$",logical("environment"
      ))))
 ENDIF
 IF (validate(dm_ocd_setup_admin_data->dm_ocd_setup_admin_date,1.0)=1.0
  AND validate(dm_ocd_setup_admin_data->dm_ocd_setup_admin_date,2.0)=2.0)
  FREE RECORD dm_ocd_setup_admin_data
  RECORD dm_ocd_setup_admin_data(
    1 dm_ocd_setup_admin_date = dq8
    1 dm2_create_system_defs = dq8
    1 dm2_set_adm_cbo = f8
  )
 ENDIF
 IF ((validate(dir_obsolete_objects->tbl_cnt,- (2))=- (2))
  AND (validate(dir_obsolete_objects->tbl_cnt,- (1))=- (1)))
  FREE RECORD dir_obsolete_objects
  RECORD dir_obsolete_objects(
    1 tbl_cnt = i4
    1 tbl[*]
      2 table_name = vc
    1 ind_cnt = i4
    1 ind[*]
      2 index_name = vc
    1 con_cnt = i4
    1 con[*]
      2 constraint_name = vc
  )
 ENDIF
 IF ((validate(dir_dropped_objects->obj_cnt,- (1))=- (1))
  AND (validate(dir_dropped_objects->obj_cnt,- (2))=- (2)))
  FREE RECORD dir_dropped_objects
  RECORD dir_dropped_objects(
    1 obj_cnt = i4
    1 rpt_drp_obj_ind = i2
    1 obj[*]
      2 table_name = vc
      2 name = vc
      2 type = vc
      2 reason = vc
  )
 ENDIF
 IF ((validate(dir_env_maint_rs->src_env_id,- (1))=- (1))
  AND (validate(dir_env_maint_rs->src_env_id,- (2))=- (2)))
  FREE RECORD dir_env_maint_rs
  RECORD dir_env_maint_rs(
    1 src_env_id = f8
    1 tgt_env_id = f8
    1 tgt_hist_fnd = i2
    1 process = vc
  )
  SET dir_env_maint_rs->src_env_id = 0
  SET dir_env_maint_rs->tgt_env_id = 0
  SET dir_env_maint_rs->tgt_hist_fnd = 0
  SET dir_env_maint_rs->process = "DM2NOTSET"
 ENDIF
 IF (validate(dir_tools_tspaces->data_tspace,"X")="X"
  AND validate(dir_tools_tspaces->data_tspace,"Y")="Y")
  FREE RECORD dir_tools_tspaces
  RECORD dir_tools_tspaces(
    1 data_tspace = vc
    1 index_tspace = vc
    1 lob_tspace = vc
  )
  SET dir_tools_tspaces->data_tspace = "NONE"
  SET dir_tools_tspaces->index_tspace = "NONE"
  SET dir_tools_tspaces->lob_tspace = "NONE"
 ENDIF
 IF (validate(dir_managed_ddl->setup_complete,1)=1
  AND validate(dir_managed_ddl->setup_complete,2)=2)
  FREE RECORD dir_managed_ddl
  RECORD dir_managed_ddl(
    1 setup_complete = i2
    1 managed_ddl_ind = i2
    1 oraversion = vc
    1 priority_cnt = i4
    1 priorities[*]
      2 priority = i4
    1 table_cnt = i4
    1 tables[*]
      2 table_name = vc
  )
  SET dir_managed_ddl->setup_complete = 0
  SET dir_managed_ddl->managed_ddl_ind = 0
  SET dir_managed_ddl->oraversion = "DM2NOTSET"
  SET dir_managed_ddl->priority_cnt = 0
  SET dir_managed_ddl->table_cnt = 0
 ENDIF
 IF (validate(dir_ui_misc->dm_process_event_id,1)=1
  AND validate(dir_ui_misc->dm_process_event_id,2)=2)
  FREE RECORD dir_ui_misc
  RECORD dir_ui_misc(
    1 dm_process_event_id = f8
    1 parent_script_name = vc
    1 background_ind = i2
    1 install_status = i2
    1 auto_install_ind = i2
    1 tspace_dg = vc
    1 debug_level = i4
    1 trace_flag = i2
  )
 ENDIF
 IF (validate(dir_storage_misc->src_storage_type,"x")="x"
  AND validate(dir_storage_misc->src_storage_type,"y")="y")
  FREE RECORD dir_storage_misc
  RECORD dir_storage_misc(
    1 src_storage_type = vc
    1 tgt_storage_type = vc
    1 cur_storage_type = vc
  )
  SET dir_storage_misc->src_storage_type = "DM2NOTSET"
  SET dir_storage_misc->tgt_storage_type = "DM2NOTSET"
  SET dir_storage_misc->cur_storage_type = "DM2NOTSET"
 ENDIF
 IF (validate(dir_db_users_pwds->cnt,1)=1
  AND validate(dir_db_users_pwds->cnt,2)=2)
  FREE RECORD dir_db_users_pwds
  RECORD dir_db_users_pwds(
    1 cnt = i4
    1 qual[*]
      2 user = vc
      2 pwd = vc
  )
  SET dir_db_users_pwds->cnt = 0
 ENDIF
 IF (validate(dir_custom_constraints->con_cnt,1)=1
  AND validate(dir_custom_constraints->con_cnt,2)=2)
  FREE RECORD dir_custom_constraints
  RECORD dir_custom_constraints(
    1 con_cnt = i4
    1 con[*]
      2 constraint_name = vc
  )
  SET dir_custom_constraints->con_cnt = 0
 ENDIF
 IF (validate(dir_killed_appl->appl_cnt,1)=1
  AND validate(dir_killed_appl->appl_cnt,2)=2)
  FREE RECORD dir_killed_appl
  RECORD dir_killed_appl(
    1 appl_cnt = i4
    1 appl[*]
      2 appl_id = vc
  )
  SET dir_killed_appl->appl_cnt = 0
 ENDIF
 IF (validate(dm2_dft_extsize,- (1)) < 0)
  DECLARE dm2_dft_extsize = i4 WITH public, constant(163840)
  DECLARE dm2_dft_clin_tspace = vc WITH public, constant("D_A_SMALL")
  DECLARE dm2_dft_clin_itspace = vc WITH public, constant("I_A_SMALL")
  DECLARE dm2_dft_clin_ltspace = vc WITH public, constant("L_A_SMALL")
 ENDIF
 IF (validate(dir_kill_clause,"z")="z"
  AND validate(dir_kill_clause,"y")="y")
  DECLARE dir_kill_clause = vc WITH public, constant(
   "Session was killed by V500.DM2MONPKG.KILL_IF_BLOCKING procedure.")
 ENDIF
 SUBROUTINE dir_dm2_tables_tspace_assign(null)
   IF ((dir_tools_tspaces->data_tspace != "NONE")
    AND (dir_tools_tspaces->index_tspace != "NONE")
    AND (dir_tools_tspaces->lob_tspace != "NONE"))
    RETURN(1)
   ENDIF
   IF ((dir_tools_tspaces->data_tspace="NONE"))
    SET dm_err->eproc =
    "Determining data_tspace from dm2_user_tables for DM2_DDL_OPS1/DM2_DDL_OPS_LOG1."
    SELECT INTO "nl:"
     FROM dm2_user_tables dut
     WHERE dut.table_name IN ("DM2_DDL_OPS1", "DM2_DDL_OPS_LOG1")
     ORDER BY dut.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->data_tspace = dut.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_tools_tspaces->data_tspace="NONE"))
    SET dm_err->eproc = "Determining data_tspace from dm2_user_tables for DM_INFO/DM_ENVIRONMENT."
    SELECT INTO "nl:"
     FROM dm2_user_tables dut
     WHERE dut.table_name IN ("DM_INFO", "DM_ENVIRONMENT")
     ORDER BY dut.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->data_tspace = dut.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_tools_tspaces->data_tspace="NONE"))
    SET dm_err->eproc = "Determining data_tspace from dm2_user_tablespaces."
    SELECT INTO "nl:"
     FROM dm2_user_tablespaces dut
     WHERE dut.tablespace_name IN ("D_TOOLKIT", "D_SYS_MGMT", "D_A_SMALL")
     ORDER BY dut.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->data_tspace = dut.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_tools_tspaces->data_tspace="NONE"))
    RETURN(1)
   ENDIF
   IF ((dir_tools_tspaces->index_tspace="NONE"))
    SET dm_err->eproc =
    "Determining index_tspace from dm2_user_indexes for DM2_DDL_OPS1/DM2_DDL_OPS_LOG1."
    SELECT INTO "nl:"
     FROM dm2_user_indexes dui
     WHERE dui.table_name IN ("DM2_DDL_OPS1", "DM2_DDL_OPS_LOG1")
     ORDER BY dui.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->index_tspace = dui.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_tools_tspaces->index_tspace="NONE"))
    SET dm_err->eproc = "Determining index_tspace from dm2_user_indexes for DM_INFO/DM_ENVIRONMENT."
    SELECT INTO "nl:"
     FROM dm2_user_indexes dui
     WHERE dui.table_name IN ("DM_INFO", "DM_ENVIRONMENT")
     ORDER BY dui.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->index_tspace = dui.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_tools_tspaces->index_tspace="NONE"))
    SET dm_err->eproc = "Determining index_tspace from dm2_user_tablespaces."
    SELECT INTO "nl:"
     FROM dm2_user_tablespaces dut
     WHERE dut.tablespace_name IN ("I_TOOLKIT", "I_SYS_MGMT", "I_A_SMALL")
     ORDER BY dut.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->index_tspace = dut.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_tools_tspaces->index_tspace="NONE"))
    RETURN(1)
   ENDIF
   IF ((dir_tools_tspaces->lob_tspace="NONE"))
    SET dir_tools_tspaces->lob_tspace = dir_tools_tspaces->data_tspace
    SET dm_err->eproc = "Determining lob_tspace from dm2_user_tablespaces."
    SELECT INTO "nl:"
     FROM dm2_user_tablespaces dut
     WHERE dut.tablespace_name IN ("L_SYS_MGMT", "L_A_SMALL")
     ORDER BY dut.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->lob_tspace = dut.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_debug_trace_data(null)
   SET dir_ui_misc->debug_level = 0
   SET dir_ui_misc->trace_flag = 0
   SET dm_err->eproc = "Query for debug flag/level"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info i
    WHERE i.info_domain="DM2_AUTO_INSTALL"
     AND i.info_name="DEBUG_FLAG"
    DETAIL
     dir_ui_misc->debug_level = i.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Query for trace status"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info i
    WHERE i.info_domain="DM2_AUTO_INSTALL"
     AND i.info_name="TRACE_FLAG"
    DETAIL
     IF (i.info_char="ON")
      dir_ui_misc->trace_flag = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_obsolete_objects(null)
   SET dm_err->eproc = "Selecting obsolete tables and indexes from dm_info."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE "OBSOLETE_OBJECT"=di.info_domain
    ORDER BY di.info_name
    HEAD REPORT
     dir_obsolete_objects->tbl_cnt = 0, stat = alterlist(dir_obsolete_objects->tbl,
      dir_obsolete_objects->tbl_cnt), dir_obsolete_objects->ind_cnt = 0,
     stat = alterlist(dir_obsolete_objects->ind,dir_obsolete_objects->ind_cnt)
    DETAIL
     CASE (build(di.info_char))
      OF "TABLE":
       dir_obsolete_objects->tbl_cnt = (dir_obsolete_objects->tbl_cnt+ 1),
       IF (mod(dir_obsolete_objects->tbl_cnt,10)=1)
        stat = alterlist(dir_obsolete_objects->tbl,(dir_obsolete_objects->tbl_cnt+ 9))
       ENDIF
       ,dir_obsolete_objects->tbl[dir_obsolete_objects->tbl_cnt].table_name = di.info_name
      OF "INDEX":
       dir_obsolete_objects->ind_cnt = (dir_obsolete_objects->ind_cnt+ 1),
       IF (mod(dir_obsolete_objects->ind_cnt,10)=1)
        stat = alterlist(dir_obsolete_objects->ind,(dir_obsolete_objects->ind_cnt+ 9))
       ENDIF
       ,dir_obsolete_objects->ind[dir_obsolete_objects->ind_cnt].index_name = di.info_name
     ENDCASE
    FOOT REPORT
     stat = alterlist(dir_obsolete_objects->tbl,dir_obsolete_objects->tbl_cnt), stat = alterlist(
      dir_obsolete_objects->ind,dir_obsolete_objects->ind_cnt)
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Selecting obsolete constraints from dm_info."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE "OBSOLETE_CONSTRAINT"=di.info_domain
    ORDER BY di.info_name
    HEAD REPORT
     dir_obsolete_objects->con_cnt = 0, stat = alterlist(dir_obsolete_objects->con,
      dir_obsolete_objects->con_cnt)
    DETAIL
     dir_obsolete_objects->con_cnt = (dir_obsolete_objects->con_cnt+ 1)
     IF (mod(dir_obsolete_objects->con_cnt,10)=1)
      stat = alterlist(dir_obsolete_objects->con,(dir_obsolete_objects->con_cnt+ 9))
     ENDIF
     dir_obsolete_objects->con[dir_obsolete_objects->con_cnt].constraint_name = di.info_name
    FOOT REPORT
     stat = alterlist(dir_obsolete_objects->con,dir_obsolete_objects->con_cnt)
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(dir_obsolete_objects)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_fill_sch_except(sbr_dfse_from)
   IF ( NOT (cnvtupper(sbr_dfse_from) IN ("REMOTE", "LOCAL")))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid from table indicator (should be either REMOTE or LOCAL)."
    SET dm_err->eproc = "Building exception list of tables"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm2_sch_except->tcnt=0))
    IF (dm2_set_autocommit(1)=0)
     RETURN(0)
    ENDIF
    IF (cnvtupper(sbr_dfse_from)="REMOTE")
     SELECT INTO "nl:"
      t.table_name
      FROM dm2_src_tables t
      WHERE ((t.table_name IN ("DM2_DDL_OPS*", "DM2_TSPACE_SIZE*", "DM2_TSPACE_OBJ_SIZE*")) OR (t
      .table_name="DM_STAT_TABLE"))
      DETAIL
       dm2_sch_except->tcnt = (dm2_sch_except->tcnt+ 1), stat = alterlist(dm2_sch_except->tbl,
        dm2_sch_except->tcnt), dm2_sch_except->tbl[dm2_sch_except->tcnt].tbl_name = t.table_name
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      t.table_name
      FROM dm2_user_tables t
      WHERE ((t.table_name IN ("DM2_DDL_OPS*", "DM2_TSPACE_SIZE*", "DM2_TSPACE_OBJ_SIZE*")) OR (t
      .table_name="DM_STAT_TABLE"))
      DETAIL
       dm2_sch_except->tcnt = (dm2_sch_except->tcnt+ 1), stat = alterlist(dm2_sch_except->tbl,
        dm2_sch_except->tcnt), dm2_sch_except->tbl[dm2_sch_except->tcnt].tbl_name = t.table_name
      WITH nocounter
     ;end select
    ENDIF
    IF (check_error("Determining tables that should be in dm2_sch_except record structure")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dm2_set_autocommit(0)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm2_sch_except->seq_cnt=0))
    SET dm2_sch_except->seq_cnt = 1
    SET stat = alterlist(dm2_sch_except->seq,1)
    SET dm2_sch_except->seq[1].seq_name = "DM_SEQ"
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_val_sch_date_str(sbr_datestr)
   DECLARE bad_sd_ind = i2 WITH protect, noconstant(0)
   DECLARE cnvt_datestr = vc WITH protect, noconstant(cnvtupper(sbr_datestr))
   IF (textlen(cnvt_datestr) != 11)
    SET bad_sd_ind = 1
   ELSEIF (substring(3,1,cnvt_datestr) != "-")
    SET bad_sd_ind = 1
   ELSEIF (substring(7,1,cnvt_datestr) != "-")
    SET bad_sd_ind = 1
   ELSEIF (cnvtint(substring(1,2,cnvt_datestr)) > 31)
    SET bad_sd_ind = 1
   ELSEIF (cnvtint(substring(1,2,cnvt_datestr)) <= 0)
    SET bad_sd_ind = 1
   ELSEIF (cnvtint(substring(8,4,cnvt_datestr)) <= 0)
    SET bad_sd_ind = 1
   ENDIF
   IF (bad_sd_ind=1)
    SET dm_err->eproc = "Validating schema date"
    SET dm_err->err_ind = 1
    SET dm_err->user_action =
    'Please specify a valid date in the format "DD-MON-YYYY", e.g. "15-JAN-2002" '
    CALL disp_msg(concat('Invalid schema date of "',sbr_datestr,'" was passed in'),dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_ddl_token_replacement(ddtr_text_str)
   DECLARE ddtr_pword = vc WITH protect, noconstant("NONE")
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("Before token replacement",ddtr_text_str))
   ENDIF
   IF (currdbuser="CDBA")
    IF ( NOT ((dm2_install_schema->cdba_p_word="NONE")))
     SET ddtr_pword = dm2_install_schema->cdba_p_word
    ENDIF
   ELSE
    IF ( NOT ((dm2_install_schema->v500_p_word="NONE")))
     SET ddtr_pword = dm2_install_schema->v500_p_word
    ENDIF
   ENDIF
   SET ddtr_text_str = replace(ddtr_text_str,"%DCL1%","",0)
   SET ddtr_text_str = replace(ddtr_text_str,"%DCL2%","",0)
   SET ddtr_text_str = replace(ddtr_text_str,"%DCL3%","",0)
   SET ddtr_text_str = replace(ddtr_text_str,"%FLOC%",dm2_install_schema->cer_install,0)
   SET ddtr_text_str = replace(ddtr_text_str,"%FLOC2%",dm2_install_schema->ccluserdir,0)
   IF ((dm2_install_schema->servername != "NONE"))
    SET ddtr_text_str = replace(ddtr_text_str,"%SNAME%",dm2_install_schema->servername,0)
   ENDIF
   SET ddtr_text_str = replace(ddtr_text_str,"%UNAME%",trim(currdbuser),0)
   IF (ddtr_pword != "NONE")
    SET ddtr_text_str = replace(ddtr_text_str,"%PWD%",ddtr_pword,0)
   ENDIF
   SET ddtr_text_str = replace(ddtr_text_str,"%DBASE%",trim(validate(currdbname," ")),0)
   IF ( NOT ((dm2_install_schema->src_v500_p_word="NONE")))
    SET ddtr_text_str = replace(ddtr_text_str,"%SRCPWD%",dm2_install_schema->src_v500_p_word,0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("After token replacement",ddtr_text_str))
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE check_concurrent_snapshot(sbr_ccs_mode)
   DECLARE ccs_appl_id = vc WITH protect, noconstant(" ")
   DECLARE ccs_appl_status = vc WITH protect, noconstant(" ")
   IF (cnvtupper(sbr_ccs_mode)="I")
    SET dm_err->eproc = "Determining if another upgrade process is running."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DM2 INSTALL PROCESS"
      AND di.info_name="CONCURRENCY CHECKPOINT"
     DETAIL
      ccs_appl_id = di.info_char
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual > 0)
     IF ((ccs_appl_id=dm2_install_schema->appl_id))
      SET dm_err->eproc = "Deleting concurrency row from dm_info - same application is restart mode."
      CALL disp_msg(" ",dm_err->logfile,0)
      DELETE  FROM dm_info di
       WHERE di.info_domain="DM2 INSTALL PROCESS"
        AND di.info_name="CONCURRENCY CHECKPOINT"
       WITH nocounter
      ;end delete
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN(0)
      ELSE
       COMMIT
      ENDIF
     ELSE
      SET dm_err->eproc = "Determining if upgrade process found in dm_info is still active."
      CALL disp_msg(" ",dm_err->logfile,0)
      SET ccs_appl_status = dm2_get_appl_status(ccs_appl_id)
      IF (ccs_appl_status="E")
       RETURN(0)
      ELSE
       IF (ccs_appl_status="A")
        SET dm_err->err_ind = 1
        SET dm_err->emsg = "Another upgrade process is currently taking a schema snapshot."
        SET dm_err->eproc = "Determining if upgrade process found in dm_info is still active."
        SET dm_err->user_action = "Please wait until other process completes and try again."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        RETURN(0)
       ELSE
        SET dm_err->eproc = "Deleting concurrency row from dm_info - process inactive."
        CALL disp_msg(" ",dm_err->logfile,0)
        DELETE  FROM dm_info di
         WHERE di.info_domain="DM2 INSTALL PROCESS"
          AND di.info_name="CONCURRENCY CHECKPOINT"
         WITH nocounter
        ;end delete
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         ROLLBACK
         RETURN(0)
        ELSE
         COMMIT
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    SET dm2_install_rec->snapshot_dt_tm = cnvtdatetime(curdate,curtime3)
    IF ((dm_err->debug_flag > 0))
     CALL echo(build("Time of snapshot = ",format(dm2_install_rec->snapshot_dt_tm,
        "mm/dd/yyyy hh:mm:ss;;d")))
    ENDIF
    SET dm_err->eproc = "Inserting concurrency row in dm_info."
    CALL disp_msg(" ",dm_err->logfile,0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2 INSTALL PROCESS", di.info_name = "CONCURRENCY CHECKPOINT", di
      .info_char = dm2_install_schema->appl_id,
      di.info_date = cnvtdatetime(dm2_install_rec->snapshot_dt_tm), di.updt_dt_tm = cnvtdatetime(
       curdate,curtime3), di.updt_applctx = 0,
      di.updt_cnt = 0, di.updt_id = 0, di.updt_task = 0
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ELSE
    SET dm_err->eproc = "Deleting concurrency row from dm_info."
    CALL disp_msg(" ",dm_err->logfile,0)
    DELETE  FROM dm_info di
     WHERE di.info_domain="DM2 INSTALL PROCESS"
      AND di.info_name="CONCURRENCY CHECKPOINT"
     WITH nocounter
    ;end delete
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_row_count(rrc_table_name,rrc_row_cnt)
   DECLARE rrc_local_row_cnt = f8 WITH protect, noconstant(0.0)
   SET dm_err->eproc = concat("Retrieving row count for table ",trim(rrc_table_name),".")
   SELECT INTO "nl:"
    FROM dm_user_tables_actual_stats t
    WHERE t.table_name=rrc_table_name
    DETAIL
     rrc_local_row_cnt = t.num_rows
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET rrc_row_cnt = 0.0
   ELSE
    SET rrc_row_cnt = rrc_local_row_cnt
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_setup_dbase_env(null)
   DECLARE max_env_id = f8 WITH protect, noconstant(0.0)
   DECLARE new_env_id = f8 WITH protect, noconstant(0.0)
   DECLARE dsdes_connect_str = vc WITH protect, noconstant(" ")
   IF (currdb="ORACLE")
    SET dsdes_cnnct_str = cnvtlower(build("v500","/",dm2_install_schema->v500_p_word,"@",
      dm2_install_schema->v500_connect_str))
   ELSE
    SET dsdes_cnnct_str = build("v500","/",dm2_install_schema->v500_p_word,"/",dm2_install_schema->
     v500_connect_str)
   ENDIF
   SET dm_err->eproc = "Determining if environment already set up."
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_environment e
    WHERE cnvtupper(e.environment_name)=cnvtupper(dm2_install_schema->target_env_name)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = "Determining next environment id."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (currdb="ORACLE")
     SELECT INTO "nl:"
      y = seq(dm_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_env_id = cnvtreal(y)
      WITH format, nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF ((dm_err->debug_flag > 0))
      CALL echo(dm_err->asterisk_line)
      CALL echo(build("new_env_id=",new_env_id))
      CALL echo(dm_err->asterisk_line)
     ENDIF
    ELSE
     SELECT INTO "nl:"
      FROM dm_environment e
      FOOT REPORT
       max_env_id = max(e.environment_id)
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET new_env_id = (max_env_id+ 1)
     IF ((dm_err->debug_flag > 0))
      CALL echo(dm_err->asterisk_line)
      CALL echo(build("max_env_id=",max_env_id))
      CALL echo(build("new_env_id=",new_env_id))
      CALL echo(dm_err->asterisk_line)
     ENDIF
    ENDIF
    SET dm_err->eproc = concat("Inserting dm_environment row for database ",dm2_install_schema->
     target_dbase_name,".")
    CALL disp_msg(" ",dm_err->logfile,0)
    SET adm_maint_str = concat("insert into dm_environment de ",
     " set de.environment_id =  new_env_id ",
     ", de.environment_name =  cnvtupper(dm2_install_schema->target_env_name)",
     ", de.database_name = ' '",", de.admin_dbase_link_name = 'ADMIN1'",
     ", de.schema_version = 0.0",", de.from_schema_version = 0.0",
     ", de.v500_connect_string = dsdes_cnnct_str",", de.volume_group = 'N/A'",
     ", de.root_dir_name = 'N/A'",
     ", de.target_operating_system = dm2_sys_misc->cur_db_os ",", de.updt_applctx = 0 ",
     ", de.updt_dt_tm = cnvtdatetime(curdate,curtime3) ",", de.updt_cnt = 0 ",", de.updt_id = 0 ",
     ", de.updt_task = 0 ","  with nocounter go")
    IF (dm2_push_adm_maint(adm_maint_str)=0)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ELSE
    SET dm_err->eproc = "Updating environment id with current information."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET adm_maint_str = concat("update from dm_environment de ",
     "set  de.admin_dbase_link_name = 'ADMIN1'",", de.schema_version = 0.0",
     ", de.from_schema_version = 0.0",", de.v500_connect_string =  dsdes_cnnct_str",
     ", de.updt_dt_tm = cnvtdatetime(curdate,curtime3) ",", de.updt_cnt = 0 ",", de.updt_id = 0 ",
     ", de.updt_task = 0 ",
     "  where de.environment_name = cnvtupper(dm2_install_schema->target_env_name) ",
     "  with nocounter go")
    IF (dm2_push_adm_maint(adm_maint_str)=0)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Prompt to confirm environment name"
   CALL disp_msg(" ",dm_err->logfile,0)
   EXECUTE dm_set_env_id
   SET message = nowindow
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Determining if 'INHOUSE DOMAIN' dm_info row exists."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="INHOUSE DOMAIN"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (curqual > 0)
    SET dm_err->eproc = "Deleting 'INHOUSE DOMAIN' row from dm_info."
    CALL disp_msg(" ",dm_err->logfile,0)
    DELETE  FROM dm_info di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="INHOUSE DOMAIN"
     WITH nocounter
    ;end delete
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE prompt_for_host(sbr_host_db)
   DECLARE pfah_choice = vc WITH protect, noconstant(" ")
   SET message = window
   SET width = 132
   CALL clear(1,1)
   CALL video(n)
   CALL text(2,1,concat("Creating a database connection to the ",cnvtupper(sbr_host_db)," database: "
     ),w)
   IF (currdb IN ("ORACLE", "DB2UDB"))
    CALL text(4,1,
     ">>> In the Host Name field, type the database server system's host name or IP address.")
   ELSE
    CALL text(4,1,
     ">>> In the Host Name field, type the database's server name (include named instance).")
   ENDIF
   CALL box(6,5,8,120)
   CALL text(7,7,"Host Name: ")
   CALL text(10,1,">>> Enter 'C' to continue or 'Q' to quit (C or Q) :")
   CALL accept(7,18,"P(100);C"," "
    WHERE  NOT (curaccept=" "))
   SET dm2_install_schema->hostname = trim(curaccept,3)
   CALL accept(10,53,"A;cu","C"
    WHERE curaccept IN ("Q", "C"))
   SET pfah_choice = curaccept
   SET message = nowindow
   IF (pfah_choice="Q")
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_val_file_prefix(sbr_file_prefix)
   DECLARE sbr_vfp_sch_date_fmt = f8 WITH protect
   DECLARE sbr_vfp_dir = vc WITH protect
   IF ((dm2_install_schema->process_option="DDL GEN"))
    SET dm2_install_schema->schema_prefix = ""
    SET dm2_install_schema->file_prefix = sbr_file_prefix
   ELSEIF (findstring("-",sbr_file_prefix) IN (0, 1))
    SET dm2_install_schema->schema_prefix = "dm2o"
    SET dm2_install_schema->file_prefix = sbr_file_prefix
   ELSE
    IF ((dm2_install_schema->process_option IN ("ADMIN CREATE", "ADMIN UPGRADE")))
     SET dm2_install_schema->schema_prefix = "dm2a"
    ELSE
     SET dm2_install_schema->schema_prefix = "dm2c"
    ENDIF
    IF (dm2_val_sch_date_str(sbr_file_prefix)=0)
     RETURN(0)
    ELSE
     SET sbr_vfp_sch_date_fmt = cnvtdate2(sbr_file_prefix,"DD-MMM-YYYY")
     SET dm2_install_schema->file_prefix = cnvtalphanum(format(sbr_vfp_sch_date_fmt,"MM/DD/YYYY;;D"))
    ENDIF
   ENDIF
   IF ((((dm2_install_schema->schema_prefix="dm2o")) OR ((dm2_install_schema->process_option IN (
   "DDL GEN", "INHOUSE")))) )
    SET sbr_vfp_dir = dm2_install_schema->ccluserdir
    SET dm2_install_schema->schema_loc = "ccluserdir"
   ELSE
    SET sbr_vfp_dir = dm2_install_schema->cer_install
    SET dm2_install_schema->schema_loc = "cer_install"
   ENDIF
   IF ((dm2_install_schema->schema_prefix="dm2a"))
    IF (findfile(build(sbr_vfp_dir,cnvtlower(trim(dm2_install_schema->schema_prefix)),cnvtlower(trim(
        dm2_install_schema->file_prefix)),"_t.csv"))=0)
     SET dm_err->emsg = concat("CSV Schema files not found for file prefix ",sbr_file_prefix," in ",
      sbr_vfp_dir)
     SET dm_err->eproc = "File Prefix Validation"
     SET dm_err->user_action = "CSV Schema files not found.  Please enter a valid file prefix."
     RETURN(0)
    ENDIF
   ELSE
    IF (findfile(build(sbr_vfp_dir,cnvtlower(trim(dm2_install_schema->schema_prefix)),cnvtlower(trim(
        dm2_install_schema->file_prefix)),cnvtlower(dm2_sch_file->qual[1].file_suffix),".dat"))=0)
     SET dm_err->emsg = concat("Schema files not found for file prefix ",sbr_file_prefix," in ",
      sbr_vfp_dir)
     SET dm_err->eproc = "File Prefix Validation"
     SET dm_err->user_action = "Schema files not found.  Please enter a valid file prefix."
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_toolset_usage(null)
   DECLARE dtu_use_dm2_toolset = i2
   DECLARE dtu_use_dm_toolset = i2
   SET dtu_use_dm2_toolset = 1
   SET dtu_use_dm_toolset = 2
   SET dm_err->eproc = "Determining if DM_INFO exists."
   SELECT INTO "nl:"
    FROM user_tab_columns utc
    WHERE utc.table_name="DM_INFO"
    WITH nocounter
   ;end select
   SET dm_err->ecode = error(dm_err->emsg,1)
   IF ((dm_err->ecode != 0))
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF (curqual > 0
    AND checkdic("DM_INFO","T",0)=2)
    SET dm_err->eproc = "Determining if database option exists."
    FREE RECORD dtu_db_option
    RECORD dtu_db_option(
      1 info_char = vc
      1 info_date = dq8
    )
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain=concat("DM2_",trim(currdb),"_DB_OPTION")
      AND d.info_name="DM2_TOOLSET_USAGE"
     DETAIL
      dtu_db_option->info_char = d.info_char, dtu_db_option->info_date = d.info_date
     WITH nocounter
    ;end select
    SET dm_err->ecode = error(dm_err->emsg,1)
    IF ((dm_err->ecode != 0))
     SET dm_err->err_ind = 1
     FREE RECORD dtu_db_option
     RETURN(0)
    ENDIF
    IF (curqual=1)
     IF ((dtu_db_option->info_char IN ("Y", "N"))
      AND (dtu_db_option->info_date=cnvtdatetime("22-JUN-1996 00:00:00")))
      IF ((dtu_db_option->info_char="Y"))
       FREE RECORD dtu_db_option
       IF ((dm_err->debug_flag > 0))
        CALL echo("Using DM2 toolset because database option designates dm2 toolset usage")
       ENDIF
       RETURN(dtu_use_dm2_toolset)
      ELSE
       FREE RECORD dtu_db_option
       IF ((dm_err->debug_flag > 0))
        CALL echo("Using DM toolset because database option designates dm toolset usage")
       ENDIF
       RETURN(dtu_use_dm_toolset)
      ENDIF
     ELSE
      IF ((dtu_db_option->info_char != "CERNER_DEFAULT"))
       IF ((dm_err->debug_flag > 0))
        CALL echo("Not using the database option because it is not set up correctly.")
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo("Defaulting to DM2 toolset")
   ENDIF
   RETURN(dtu_use_dm2_toolset)
 END ;Subroutine
 SUBROUTINE dm2_get_suffixed_tablename(tbl_name)
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   DECLARE dm2_str = vc WITH protect, noconstant(" ")
   SET dm2_str = concat("select into 'nl:'"," from dm_tables_doc dtd ",
    " where dtd.table_name = cnvtupper('",tbl_name,"')",
    " detail"," dm2_table->suffixed_table_name = dtd.suffixed_table_name",
    " dm2_table->table_suffix = dtd.table_suffix"," dm2_table->full_table_name = dtd.full_table_name",
    " with nocounter",
    " go")
   IF ( NOT (dm2_push_cmd(dm2_str,1)))
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_push_adm_maint(sbr_maint_str)
   DECLARE adm_maint_err = i4 WITH protect, noconstant(1)
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   SET adm_maint_err = dm2_push_cmd(sbr_maint_str,1)
   IF (adm_maint_err=0)
    ROLLBACK
   ELSE
    COMMIT
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
   RETURN(adm_maint_err)
 END ;Subroutine
 SUBROUTINE dm2_get_appl_status(gas_appl_id)
   DECLARE gas_error_status = c1 WITH protect, constant("E")
   DECLARE gas_active_status = c1 WITH protect, constant("A")
   DECLARE gas_inactive_status = c1 WITH protect, constant("I")
   DECLARE gas_text = vc WITH protect, noconstant(" ")
   DECLARE gas_currdblink = vc WITH protect, noconstant(cnvtupper(trim(currdblink,3)))
   DECLARE gas_appl_id_cvt = vc WITH protect, noconstant(" ")
   IF (currdb="DB2UDB")
    SET gas_appl_id_cvt = replace(trim(gas_appl_id,3),"*","\*",0)
    SELECT INTO "nl:"
     FROM dm2_user_views
     WHERE view_name="DM2_SNAP_APPL_INFO"
     WITH nocounter
    ;end select
    IF (check_error("Selecting from dm2_user_views in subroutine DM2_GET_APPL_STATUS")=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ENDIF
    IF (curqual=0)
     SET gas_text = concat("RDB ASIS (^ ","CREATE VIEW DM2_SNAP_APPL_INFO AS ",
      " ( SELECT * FROM TABLE(SNAPSHOT_APPL_INFO('",gas_currdblink,"',-1 )) AS SNAPSHOT_APPL_INFO )",
      " ^) GO ")
     IF (dm2_push_cmd(gas_text,1) != 1)
      ROLLBACK
      RETURN(gas_error_status)
     ELSE
      COMMIT
      EXECUTE oragen3 "DM2_SNAP_APPL_INFO"
      IF ((dm_err->err_ind=1))
       RETURN(gas_error_status)
      ENDIF
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     FROM dtable
     WHERE table_name="DM2_SNAP_APPL_INFO"
     WITH nocounter
    ;end select
    IF (check_error("Selecting from dtable in subroutine DM2_GET_APPL_STATUS")=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ENDIF
    IF (curqual != 1)
     EXECUTE oragen3 "DM2_SNAP_APPL_INFO"
     IF ((dm_err->err_ind=1))
      RETURN(gas_error_status)
     ENDIF
    ENDIF
    SET gas_text = concat('select into "nl:" from DM2_SNAP_APPL_INFO where appl_id = "',
     gas_appl_id_cvt,'" with nocounter go')
    IF (dm2_push_cmd(gas_text,1) != 1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ENDIF
    IF (curqual=1)
     RETURN(gas_active_status)
    ELSE
     RETURN(gas_inactive_status)
    ENDIF
   ELSEIF (currdb="SQLSRV")
    DECLARE gas_str_loc1 = i4 WITH protect, noconstant(0)
    DECLARE gas_str_loc2 = i4 WITH protect, noconstant(0)
    DECLARE gas_str_loc3 = i4 WITH protect, noconstant(0)
    DECLARE gas_spid = i4 WITH protect, noconstant(0)
    DECLARE gas_login_date = vc WITH protect, noconstant(" ")
    DECLARE gas_login_time = i4 WITH protect, noconstant(0)
    SET gas_str_loc1 = findstring("-",trim(gas_appl_id,3),1,0)
    SET gas_str_loc2 = findstring(" ",trim(gas_appl_id,3),1,1)
    SET gas_str_loc3 = findstring(":",trim(gas_appl_id,3),1,1)
    IF (((gas_str_loc1=0) OR (((gas_str_loc2=0) OR (gas_str_loc3=0)) )) )
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Invalid application handle"
     SET dm_err->eproc =
     "Parsing through application handle to determine spid and login date and time"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ELSE
     SET gas_spid = cnvtint(build(substring(1,(gas_str_loc1 - 1),trim(gas_appl_id,3))))
     SET gas_login_date = cnvtupper(cnvtalphanum(substring((gas_str_loc1+ 1),(gas_str_loc2 -
        gas_str_loc1),trim(gas_appl_id,3))))
     SET gas_login_time = cnvtint(cnvtalphanum(substring(gas_str_loc2,(gas_str_loc3 - gas_str_loc2),
        trim(gas_appl_id,3))))
    ENDIF
    SELECT INTO "nl:"
     FROM sysprocesses p
     WHERE p.spid=gas_spid
      AND p.login_time=cnvtdatetime(cnvtdate2(gas_login_date,"DDMMMYYYY"),gas_login_time)
     WITH nocounter
    ;end select
    IF (check_error("Selecting from sysprocesses in subroutine DM2_GET_APPL_STATUS")=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ELSEIF (curqual=0)
     RETURN(gas_inactive_status)
    ELSE
     RETURN(gas_active_status)
    ENDIF
   ELSE
    IF (cnvtupper(gas_appl_id)="-15301")
     RETURN(gas_active_status)
    ENDIF
    SELECT INTO "nl:"
     FROM gv$session s
     WHERE s.audsid=cnvtint(gas_appl_id)
     WITH nocounter
    ;end select
    IF (check_error("Selecting from gv$session in subroutine DM2_GET_APPL_STATUS")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ELSEIF (curqual=0)
     SELECT INTO "nl:"
      FROM v$session s
      WHERE s.audsid=cnvtint(gas_appl_id)
      WITH nocounter
     ;end select
     IF (check_error("Selecting from v$session in subroutine DM2_GET_APPL_STATUS")=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(gas_error_status)
     ENDIF
     IF (curqual > 0)
      RETURN(gas_active_status)
     ELSE
      RETURN(gas_inactive_status)
     ENDIF
    ELSE
     RETURN(gas_active_status)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_fill_seq_list(alias,col_name)
   DECLARE in_clause = vc WITH protect, noconstant("")
   SET in_clause = concat(alias,".",col_name," IN ('DM_PLAN_ID_SEQ', 'REPORT_SEQUENCE','DM_SEQ') ")
   RETURN(in_clause)
 END ;Subroutine
 SUBROUTINE dir_add_silmode_entry(entry_name,entry_filename)
   SET dir_silmode->cnt = (dir_silmode->cnt+ 1)
   SET stat = alterlist(dir_silmode->qual,dir_silmode->cnt)
   SET dir_silmode->qual[dir_silmode->cnt].name = entry_name
   SET dir_silmode->qual[dir_silmode->cnt].filename = entry_filename
 END ;Subroutine
 SUBROUTINE dm2_cleanup_stranded_appl(null)
   DECLARE dcsa_applx = i4 WITH protect, noconstant(0)
   DECLARE dcsa_fmt_appl_id = vc WITH protect, noconstant(" ")
   DECLARE dcsa_error_msg = vc WITH protect, noconstant(" ")
   DECLARE dcsa_load_ind = i2 WITH protect, noconstant(1)
   DECLARE dcsa_kill_ind = i2 WITH protect, noconstant(0)
   FREE RECORD dcsa_appl_rs
   RECORD dcsa_appl_rs(
     1 dcsa_appl_cnt = i4
     1 dcsa_appl[*]
       2 dcsa_appl_id = vc
   )
   SELECT INTO "nl:"
    FROM dm2_user_tables ut
    WHERE ut.table_name="DM2_DDL_OPS_LOG*"
    WITH nocounter
   ;end select
   IF (check_error("Find_Stranded_Runner - DDL_OPS_LOG table existence check")=true)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(false)
   ENDIF
   IF (curqual=0)
    CALL echo(
     "dm2_ddl_ops_log table not found in dm2_user_tables, bypassing dm2_cleanup_stranded_appl logic..."
     )
    RETURN(1)
   ELSE
    IF ((dm_err->debug_flag > 1))
     CALL echo("Curqual from user_tables for dm2_ddl_ops_log* returned != 0")
    ENDIF
   ENDIF
   SELECT DISTINCT INTO "nl:"
    ddol_appl_id = ddol.appl_id
    FROM dm2_ddl_ops_log ddol
    WHERE ddol.status IN ("RUNNING", null)
     AND ddol.op_type != "*(REMOTE)*"
    HEAD REPORT
     dcsa_applx = 0
    DETAIL
     dcsa_applx = (dcsa_applx+ 1)
     IF (mod(dcsa_applx,10)=1)
      stat = alterlist(dcsa_appl_rs->dcsa_appl,(dcsa_applx+ 9))
     ENDIF
     dcsa_appl_rs->dcsa_appl[dcsa_applx].dcsa_appl_id = ddol_appl_id
    FOOT REPORT
     dcsa_appl_rs->dcsa_appl_cnt = dcsa_applx, stat = alterlist(dcsa_appl_rs->dcsa_appl,dcsa_applx)
    WITH nocounter
   ;end select
   IF (check_error("Find_Stranded_Runner - Select")=true)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(false)
   ENDIF
   IF ((dcsa_appl_rs->dcsa_appl_cnt > 0))
    SET dcsa_applx = 1
    WHILE ((dcsa_applx <= dcsa_appl_rs->dcsa_appl_cnt))
      SET dcsa_fmt_appl_id = dcsa_appl_rs->dcsa_appl[dcsa_applx].dcsa_appl_id
      CASE (dm2_get_appl_status(value(dcsa_appl_rs->dcsa_appl[dcsa_applx].dcsa_appl_id)))
       OF "I":
        IF (dir_alert_killed_appl(dcsa_load_ind,dcsa_fmt_appl_id,dcsa_kill_ind)=0)
         RETURN(0)
        ENDIF
        SET dcsa_load_ind = 0
        IF (dcsa_kill_ind=1)
         SET dcsa_error_msg = dir_kill_clause
        ELSE
         SET dcsa_error_msg = concat("Application ID ",trim(dcsa_fmt_appl_id)," is no longer active."
          )
        ENDIF
        UPDATE  FROM dm2_ddl_ops_log ddol
         SET ddol.status = "ERROR", ddol.error_msg =
          "IMPORT operation set to ERROR since session executing no longer exists.", ddol.end_dt_tm
           = cnvtdatetime(curdate,curtime3)
         WHERE ddol.appl_id=dcsa_fmt_appl_id
          AND ddol.status="RUNNING"
          AND ddol.op_type="IMPORT*"
          AND ddol.op_type != "*(REMOTE)*"
        ;end update
        UPDATE  FROM dm2_ddl_ops_log ddol
         SET ddol.status = "ERROR", ddol.error_msg = dcsa_error_msg, ddol.end_dt_tm = cnvtdatetime(
           curdate,curtime3)
         WHERE ddol.appl_id=dcsa_fmt_appl_id
          AND ddol.status IN (null, "RUNNING")
          AND ddol.op_type != "*(REMOTE)*"
        ;end update
        IF (check_error("Find_Stranded_Processes - Update")=true)
         ROLLBACK
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(false)
        ELSE
         COMMIT
        ENDIF
       OF "A":
        IF ((dm_err->debug_flag > 0))
         CALL echo(build("Application Id ",dcsa_fmt_appl_id," is active."))
        ENDIF
       OF "E":
        IF ((dm_err->debug_flag > 0))
         CALL echo("Error Detected in dm2_get_appl_status")
        ENDIF
        RETURN(false)
      ENDCASE
      SET dcsa_applx = (dcsa_applx+ 1)
    ENDWHILE
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo("********** No Application Ids Detected **********")
    ENDIF
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE dir_alert_killed_appl(daka_load_ind,daka_fmt_appl_id,daka_kill_ind)
   DECLARE daka_audsid = vc WITH protect, noconstant(" ")
   DECLARE daka_audsid_start = i4 WITH protect, noconstant(0)
   DECLARE daka_audsid_end = i4 WITH protect, noconstant(0)
   DECLARE daka_applx = i4 WITH protect, noconstant(0)
   DECLARE daka_info_exists = i4 WITH protect, noconstant(0)
   SET daka_kill_ind = 0
   IF (daka_load_ind=1)
    IF (dm2_table_and_ccldef_exists("DM_INFO",daka_info_exists)=0)
     RETURN(0)
    ELSEIF (daka_info_exists=0)
     RETURN(1)
    ENDIF
    SELECT DISTINCT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="DM2MONPKG_LOGGER"
      AND d.updt_dt_tm BETWEEN cnvtdatetime((curdate - 7),curtime3) AND cnvtdatetime(curdate,curtime3
      )
      AND d.info_char="*AUDSID:*"
     HEAD REPORT
      dir_killed_appl->appl_cnt = 0
     DETAIL
      daka_audsid_start = findstring("AUDSID:",d.info_char,1,0), daka_audsid_end = findstring(",",d
       .info_char,daka_audsid_start,0)
      IF (daka_audsid_end=0)
       daka_audsid = substring(daka_audsid_start,((size(d.info_char)+ 1) - daka_audsid_start),d
        .info_char)
      ELSE
       daka_audsid = substring(daka_audsid_start,(daka_audsid_end - daka_audsid_start),d.info_char)
      ENDIF
      daka_audsid = trim(replace(daka_audsid,"AUDSID:","",0),3)
      IF (isnumeric(daka_audsid))
       dir_killed_appl->appl_cnt += 1
       IF (mod(dir_killed_appl->appl_cnt,10)=1)
        stat = alterlist(dir_killed_appl->appl,(dir_killed_appl->appl_cnt+ 9))
       ENDIF
       dir_killed_appl->appl[dir_killed_appl->appl_cnt].appl_id = daka_audsid
      ENDIF
     FOOT REPORT
      stat = alterlist(dir_killed_appl->appl,dir_killed_appl->appl_cnt)
     WITH nocounter
    ;end select
    IF (check_error("Obtain killed application IDs.")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_killed_appl->appl_cnt > 0))
    SET daka_applx = locateval(daka_applx,1,dir_killed_appl->appl_cnt,daka_fmt_appl_id,
     dir_killed_appl->appl[daka_applx].appl_id)
    IF (daka_applx > 0)
     SET daka_kill_ind = 1
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(dir_killed_appl)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_setup_batch_queue(dsbq_queue_name)
   DECLARE dsbq_env_name = vc WITH protect, noconstant(" ")
   DECLARE dsbq_cmd = vc WITH protect, noconstant(" ")
   DECLARE dsbq_start_pos = i4 WITH protect, noconstant(0)
   DECLARE dsbq_end_pos = i4 WITH protect, noconstant(0)
   DECLARE dsbq_domain_user = vc WITH protect, noconstant(" ")
   DECLARE dsbq_err_str = vc WITH protect, constant("no such queue")
   IF ((dm2_sys_misc->cur_os != "AXP"))
    RETURN(1)
   ENDIF
   IF (((dsbq_queue_name=" ") OR (dsbq_queue_name="")) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating input batch queue name."
    SET dm_err->emsg = "Invalid batch queue name."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dsbq_env_name = logical("environment")
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("Environment Name = ",dsbq_env_name))
   ENDIF
   IF (((dsbq_env_name=" ") OR (dsbq_env_name="")) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating environment name."
    SET dm_err->emsg = "Invalid environment name."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dsbq_cmd = concat("lreg -getp environment\",dsbq_env_name,
    " LocalUserName ;show symbol LREG_RESULT")
   IF ((dm_err->debug_flag > 0))
    CALL echo("*")
    CALL echo(concat("call dcl executing: ",dsbq_cmd))
    CALL echo("*")
   ENDIF
   SET dm_err->disp_dcl_err_ind = 0
   IF (dm2_push_dcl(dsbq_cmd)=0)
    IF ((dm_err->err_ind=1))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   SET dm_err->errtext = replace(dm_err->errtext,'LREG_RESULT = "',"",0)
   SET dm_err->errtext = replace(dm_err->errtext,'"',"",1)
   IF (findstring("%DCL-W-UNDSYM",dm_err->errtext) > 0)
    SET dsbq_domain_user = " "
   ELSE
    SET dsbq_domain_user = trim(dm_err->errtext,3)
   ENDIF
   IF (dsbq_domain_user=" ")
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Retreiving domain user from registry."
    SET dm_err->emsg = "Unable to retrieive domain user from registry."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (cnvtupper(curuser) != cnvtupper(dsbq_domain_user))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Making sure current user is the domain user."
    SET dm_err->emsg = "Current user is not the domain user."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dsbq_cmd = concat("sho queue /full ",dsbq_queue_name)
   SET dm_err->disp_dcl_err_ind = 0
   IF (dm2_push_dcl(dsbq_cmd)=0)
    IF ((dm_err->err_ind=1))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   IF (findstring(dsbq_err_str,cnvtlower(dm_err->errtext),1,0) > 0)
    SET dsbq_queue_fnd = 0
   ELSEIF (findstring(cnvtlower(dsbq_queue_name),cnvtlower(dm_err->errtext),1,0)=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Determining if queue ",dsbq_queue_name," exists.")
    SET dm_err->emsg = dm_err->errtext
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    SET dsbq_queue_fnd = 1
   ENDIF
   IF (dsbq_queue_fnd=1)
    IF (findstring("idle",cnvtlower(dm_err->errtext),1,0)=0
     AND findstring("executing",cnvtlower(dm_err->errtext),1,0)=0)
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Make sure queue ",dsbq_queue_name,
      " is idle or is currently executing jobs.")
     SET dm_err->emsg = dm_err->errtext
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    SET dsbq_cmd = concat("init/queue/batch/start/job_limit=20 ",dsbq_queue_name)
    IF ((dm_err->debug_flag > 0))
     CALL echo("*")
     CALL echo(concat("call dcl executing: ",dsbq_cmd))
     CALL echo("*")
    ENDIF
    IF (dm2_push_dcl(dsbq_cmd)=0)
     RETURN(0)
    ENDIF
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echo(concat("Results of create queue command: ",dm_err->errtext))
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_sea_sch_files(directory,file_prefix,schema_date)
   DECLARE dgns_dcl_find = vc WITH protect, noconstant("")
   DECLARE dgns_err_str = vc WITH protect, noconstant("")
   SET schema_date = "01-JAN-1800"
   IF ( NOT (file_prefix IN ("dm2a", "dm2o", "dm2c")))
    SET dm_err->eproc = "Validating file_prefix."
    SET dm_err->emsg = "file_prefix must be IN ('dm2a', 'dm2o', 'dm2c')"
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    IF (file_prefix="dm2a")
     SET dgns_dcl_find = concat("dir/columns=1  ",build(directory),file_prefix,"%%%2*")
    ELSE
     SET dgns_dcl_find = concat("dir/columns=1  ",build(directory),file_prefix,"*")
    ENDIF
    SET dgns_err_str = "no files found"
   ELSEIF ((dm2_sys_misc->cur_os="WIN"))
    IF (file_prefix="dm2a")
     SET dgns_dcl_find = concat("dir ",build(directory),"\",file_prefix,"???3????_*")
    ELSE
     SET dgns_dcl_find = concat("dir ",build(directory),"\",file_prefix,"*")
    ENDIF
    SET dgns_err_str = "file not found"
   ELSE
    IF (file_prefix="dm2a")
     IF ((dm2_sys_misc->cur_os="LNX"))
      SET dgns_dcl_find = concat("ls -t ",build(directory),"/",file_prefix,"???4* | wc -w")
     ELSE
      SET dgns_dcl_find = concat("ls -t ",build(directory),"/",file_prefix,"???1* | wc -w")
     ENDIF
    ELSE
     SET dgns_dcl_find = concat("ls -t ",build(directory),"/",file_prefix,"* | wc -w")
    ENDIF
    SET dgns_err_str = "0"
   ENDIF
   IF (dm2_push_dcl(dgns_dcl_find)=0)
    IF (findstring(dgns_err_str,cnvtlower(dm_err->errtext)) > 0)
     SET dm_err->eproc = "Find schema date."
     SET dm_err->emsg = "No schema date was found."
     SET dm_err->err_ind = 0
     RETURN(1)
    ENDIF
    RETURN(0)
   ELSE
    IF ((dm2_sys_misc->cur_os IN ("AIX", "HPX", "LNX")))
     IF (file_prefix="dm2a")
      IF ((dm2_sys_misc->cur_os="LNX"))
       SET dgns_dcl_find = concat("ls -l ",build(directory),"/",file_prefix,"???4* ")
      ELSE
       SET dgns_dcl_find = concat("ls -l ",build(directory),"/",file_prefix,"???1* ")
      ENDIF
     ELSE
      SET dgns_dcl_find = concat("ls - ",build(directory),"/",file_prefix,"* ")
     ENDIF
     SET dm_err->eproc = "Building list of schema files to gather schema date"
     IF (dm2_push_dcl(dgns_dcl_find)=0)
      RETURN(0)
     ENDIF
    ENDIF
    FREE DEFINE rtl
    FREE SET file_loc
    SET logical file_loc value(dm_err->errfile)
    DEFINE rtl "file_loc"
    SELECT INTO "nl:"
     r.line
     FROM rtlt r
     HEAD REPORT
      compare_date = cnvtdate("01011800"), stripped_date = cnvtdate("01011800")
     DETAIL
      IF ((dm2_sys_misc->cur_os="AXP"))
       starting_pos = findstring(cnvtupper(file_prefix),r.line)
      ELSE
       starting_pos = findstring(file_prefix,r.line)
      ENDIF
      stripped_date = cnvtdate(substring((starting_pos+ 4),8,r.line))
      IF (stripped_date > compare_date)
       schema_date = format(stripped_date,"DD-MMM-YYYY;;d"), compare_date = stripped_date
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
 SUBROUTINE dir_get_list_of_files(dglf_prefix)
   DECLARE dglf_str = vc WITH protect
   SET dm_err->eproc = "Getting help list of schema files to select from."
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dglf_str = concat("dir/version=1/columns=1 cer_install:",dglf_prefix,"*_h.dat ")
   ELSEIF ((dm2_sys_misc->cur_os="WIN"))
    SET dglf_str = concat("dir ",dm2_install_schema->cer_install,"\",dglf_prefix,"*_h.dat /B")
   ELSE
    SET dglf_str = concat('find $cer_install -name "',dglf_prefix,'*_h.dat" -print')
   ENDIF
   IF (dm2_push_dcl(value(dglf_str))=0)
    RETURN(0)
   ENDIF
   FREE DEFINE rtl
   FREE SET file_loc
   SET logical file_loc value(dm_err->errfile)
   DEFINE rtl "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtlt r
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET message = nowindow
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_find_data_file(dfdf_file_found)
   DECLARE dtd_data_file = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Finding data files"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_data_files ddf
    DETAIL
     dtd_data_file = ddf.file_name
    WITH maxqual(ddf,1), nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dfdf_file_found = findfile(dtd_data_file)
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("file found ind =",dfdf_file_found))
    CALL echo(build("file name =",dtd_data_file))
   ENDIF
   IF (dfdf_file_found=0)
    SET dm_err->eproc = "Datafile not visible at operating system level"
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_managed_ddl_setup(dmds_runid)
   DECLARE dmds_rowcnt = f8 WITH protect, noconstant(0.0)
   DECLARE dmds_ndx = i4 WITH protect, noconstant(0)
   DECLARE dmds_priority = i4 WITH protect, noconstant(0)
   SET dir_managed_ddl->setup_complete = 0
   IF (dm2_get_rdbms_version(null)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Check if Managed DDL oracle version"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_MANAGED_DDL_ORAVER"
    DETAIL
     IF (d.info_name=build(dm2_rdbms_version->level1,".",dm2_rdbms_version->level2,".",
      dm2_rdbms_version->level3,
      ".",dm2_rdbms_version->level4))
      dir_managed_ddl->oraversion = d.info_name, dir_managed_ddl->managed_ddl_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dir_managed_ddl->managed_ddl_ind=1))
    SET dm_err->eproc = "Check for row_cnt override for Managed DDL"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="DM2_MANAGED_DDL_ROWCNT"
     DETAIL
      dmds_rowcnt = d.info_number
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dmds_rowcnt > 0.0)
     SET dm_err->eproc = concat("Managed DDL Rowcnt Override: ",build(dmds_rowcnt))
     CALL disp_msg("",dm_err->logfile,0)
    ELSE
     SET dmds_rowcnt = 10000
    ENDIF
    SET dm_err->eproc = "Load Managed DDL Priorities"
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm2_ddl_ops_log d,
      dm_dba_tables_actual_stats t
     WHERE d.run_id=dmds_runid
      AND d.op_type IN (
     (SELECT
      di.info_name
      FROM dm_info di
      WHERE di.info_domain="DM2_MANAGED_DDL_OP_TYPE"))
      AND d.table_name != "DM*"
      AND d.table_name=t.table_name
      AND t.num_rows > dmds_rowcnt
      AND (( EXISTS (
     (SELECT
      "x"
      FROM dm_info di
      WHERE di.info_domain="DM2_MIXED_TABLE-EXPORT-REFERENCE"
       AND di.info_name=d.table_name))) OR ( EXISTS (
     (SELECT
      "x"
      FROM dm_tables_doc dtd
      WHERE dtd.reference_ind=0
       AND dtd.table_name=d.table_name))))
      AND ((d.status != "COMPLETE") OR (d.status = null))
     ORDER BY d.priority, d.table_name
     HEAD d.priority
      dmds_ndx = 0, dmds_priority = d.priority
      IF ((dir_managed_ddl->priority_cnt > 0))
       dmds_ndx = locateval(dmds_ndx,1,dir_managed_ddl->priority_cnt,dmds_priority,dir_managed_ddl->
        priorities[dmds_ndx].priority)
      ENDIF
      IF (dmds_ndx=0)
       dir_managed_ddl->priority_cnt = (dir_managed_ddl->priority_cnt+ 1)
       IF (mod(dir_managed_ddl->priority_cnt,100)=1)
        stat = alterlist(dir_managed_ddl->priorities,(dir_managed_ddl->priority_cnt+ 99))
       ENDIF
       dir_managed_ddl->priorities[dir_managed_ddl->priority_cnt].priority = d.priority
      ENDIF
     HEAD d.table_name
      dmds_ndx = 0
      IF ((dir_managed_ddl->table_cnt > 0))
       dmds_ndx = locateval(dmds_ndx,1,dir_managed_ddl->table_cnt,d.table_name,dir_managed_ddl->
        tables[dmds_ndx].table_name)
      ENDIF
      IF (dmds_ndx=0)
       dir_managed_ddl->table_cnt = (dir_managed_ddl->table_cnt+ 1)
       IF (mod(dir_managed_ddl->table_cnt,100)=1)
        stat = alterlist(dir_managed_ddl->tables,(dir_managed_ddl->table_cnt+ 99))
       ENDIF
       dir_managed_ddl->tables[dir_managed_ddl->table_cnt].table_name = d.table_name
      ENDIF
     FOOT REPORT
      stat = alterlist(dir_managed_ddl->tables,dir_managed_ddl->table_cnt), stat = alterlist(
       dir_managed_ddl->priorities,dir_managed_ddl->priority_cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET dir_managed_ddl->managed_ddl_ind = 0
    ENDIF
   ENDIF
   SET dir_managed_ddl->setup_complete = 1
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dir_managed_ddl)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_perform_wait_interval(null)
   DECLARE dpwi_pause_interval = i4 WITH protect, noconstant(1)
   SET dm_err->eproc = "Obtain pause interval"
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_INSTALL_PKG"
     AND d.info_name="PAUSE_INTERVAL"
    DETAIL
     dpwi_pause_interval = d.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Pausing for ",build(dpwi_pause_interval)," minutes.")
   CALL disp_msg("",dm_err->logfile,0)
   CALL pause((dpwi_pause_interval * 60))
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_storage_type(dgst_db_link)
   IF ((dm2_sys_misc->cur_db_os="AXP"))
    SET dir_storage_misc->cur_storage_type = "AXP"
    SET dir_storage_misc->tgt_storage_type = "AXP"
    SET dir_storage_misc->src_storage_type = "AXP"
   ELSE
    IF (dgst_db_link > " "
     AND dgst_db_link != "DM2NOTSET")
     SET dm_err->eproc = "Determine source storage type from dba_data_files"
     CALL disp_msg("",dm_err->logfile,0)
     SELECT INTO "nl:"
      FROM (parser(concat("dba_data_files@",dgst_db_link)) ddf)
      WHERE ddf.tablespace_name="SYSTEM"
       AND ddf.file_name=patstring("/dev/*")
      DETAIL
       dir_storage_misc->src_storage_type = "RAW"
      WITH nocounter, maxqual = 1
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (curqual=0)
      SET dir_storage_misc->src_storage_type = "ASM"
     ENDIF
    ENDIF
    SET dm_err->eproc = "Determine target storage type from dba_data_files"
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dba_data_files ddf
     WHERE ddf.tablespace_name="SYSTEM"
     DETAIL
      IF (ddf.file_name=patstring("/dev/*"))
       dir_storage_misc->cur_storage_type = "RAW", dir_storage_misc->tgt_storage_type = "RAW"
      ELSEIF (ddf.file_name=patstring("+*"))
       dir_storage_misc->cur_storage_type = "ASM", dir_storage_misc->tgt_storage_type = "ASM"
      ELSE
       dir_storage_misc->cur_storage_type = "RAW", dir_storage_misc->tgt_storage_type = "RAW"
      ENDIF
     WITH nocounter, maxqual = 1
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dir_storage_misc)
   ENDIF
   IF (validate(dm2_tgt_storage_type,"XXX") IN ("RAW", "ASM"))
    SET dir_storage_misc->cur_storage_type = dm2_tgt_storage_type
    SET dir_storage_misc->tgt_storage_type = dm2_tgt_storage_type
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dir_storage_misc)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_check_dm_ocd_setup_admin(dcdosa_requires_execution,dcdosa_install_mode)
   DECLARE dcdosa_compare_date = vc WITH protect, noconstant("")
   DECLARE dcdosa_cer_install = vc WITH protect, noconstant("")
   DECLARE dcdosa_schema_date = i4 WITH protect, noconstant(0)
   DECLARE dcdosa_dm_info_dm_ocd_setup_admin_date = dq8 WITH protect, noconstant(0.0)
   DECLARE dcdosa_dm_info_dm2_create_system_defs_date = dq8 WITH protect, noconstant(0.0)
   DECLARE dcdosa_dm_info_schema_date = i4 WITH protect, noconstant(0)
   DECLARE dcdosa_dm_info_dm2_set_adm_cbo_date = dq8 WITH protect, noconstant(0.0)
   SET dcdosa_requires_execution = 0
   IF (currdb != "ORACLE")
    SET dm_err->eproc = "Admin Setup Bypassed - Database must be on Oracle to perform Admin setup."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    RETURN(1)
   ELSEIF ( NOT ((dm2_sys_misc->cur_os IN ("HPX", "AIX", "AXP", "LNX", "WIN"))))
    SET dm_err->eproc =
    "Admin Setup Bypassed - o/s must be HPX, AIX, VMS, LNX or WIN to perform Admin Setup."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    RETURN(1)
   ELSEIF ( NOT (dcdosa_install_mode IN ("UPTIME", "BATCHUP", "PREVIEW", "BATCHPREVIEW", "EXPRESS",
   "BATCHEXPRESS")))
    SET dm_err->eproc = "Checking install mode"
    SET dm_err->eproc = concat("Admin Setup Bypassed - Install mode needs to be ",
     " UPTIME, BATCHUP, PREVIEW, BATCHPREVIEW, EXPRESS or BATCHEXPRESS to perform Admin Setup.")
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    RETURN(1)
   ENDIF
   IF (dm2_get_rdbms_version(null)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("clinical database version : ",dm2_rdbms_version->level1))
   ENDIF
   SET dm_err->eproc = "Selecting dm_info rows."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM_OCD_SETUP_ADMIN COMPLETE"
     AND di.info_name IN ("SCHEMA_DATE", "DM_OCD_SETUP_ADMIN_DATE", "DM2_CREATE_SYSTEM_DEFS_DATE",
    "DM2_SET_ADM_CBO_DATE")
    HEAD REPORT
     dcdosa_dm_info_schema_date = 0, dcdosa_dm_info_dm_ocd_setup_admin_date = 0.0,
     dcdosa_dm_info_dm2_create_system_defs_date = 0.0,
     dcdosa_dm_info_dm2_set_adm_cbo_date = 0.0
    DETAIL
     CASE (di.info_name)
      OF "SCHEMA_DATE":
       dcdosa_dm_info_schema_date = cnvtdate2(di.info_char,"DD-MMM-YYYY")
      OF "DM_OCD_SETUP_ADMIN_DATE":
       dcdosa_dm_info_dm_ocd_setup_admin_date = cnvtdatetime(di.info_char)
      OF "DM2_CREATE_SYSTEM_DEFS_DATE":
       dcdosa_dm_info_dm2_create_system_defs_date = cnvtdatetime(di.info_char)
      OF "DM2_SET_ADM_CBO_DATE":
       dcdosa_dm_info_dm2_set_adm_cbo_date = cnvtdatetime(di.info_char)
     ENDCASE
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Finding newest schema file."
   CALL disp_msg("",dm_err->logfile,0)
   SET dcdosa_cer_install = cnvtlower(trim(logical("cer_install"),3))
   IF (dcfr_sea_csv_files(dcdosa_cer_install,"dm2a",dcdosa_compare_date)=0)
    RETURN(0)
   ELSE
    IF (dcdosa_compare_date="01-JAN-1800")
     SET dm_err->eproc = "Searching for Schema files."
     SET dm_err->emsg = "No schema files present in cer_install."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     SET dcdosa_schema_date = cnvtdate2(dcdosa_compare_date,"DD-MMM-YYYY")
    ENDIF
   ENDIF
   SET dm_err->eproc = "Selecting date/timestamps from dprotect."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dprotect dp
    WHERE dp.object="P"
     AND dp.object_name IN ("DM_OCD_SETUP_ADMIN", "DM2_CREATE_SYSTEM_DEFS", "DM2_SET_ADM_CBO")
    DETAIL
     CASE (dp.object_name)
      OF "DM_OCD_SETUP_ADMIN":
       dm_ocd_setup_admin_data->dm_ocd_setup_admin_date = cnvtdatetime(dp.datestamp,dp.timestamp)
      OF "DM2_CREATE_SYSTEM_DEFS":
       dm_ocd_setup_admin_data->dm2_create_system_defs = cnvtdatetime(dp.datestamp,dp.timestamp)
      OF "DM2_SET_ADM_CBO":
       dm_ocd_setup_admin_data->dm2_set_adm_cbo = cnvtdatetime(dp.datestamp,dp.timestamp)
     ENDCASE
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echo(build("dcdosa_dm_info_schema_date:",dcdosa_dm_info_schema_date))
    CALL echo(build("dcdosa_schema_date:",dcdosa_schema_date))
    CALL echo(build("dcdosa_dm_info_dm_ocd_setup_admin_date:",dcdosa_dm_info_dm_ocd_setup_admin_date)
     )
    CALL echo(build("dm_ocd_setup_admin_data->dm_ocd_setup_admin_date:",dm_ocd_setup_admin_data->
      dm_ocd_setup_admin_date))
    CALL echo(build("dcdosa_dm_info_dm2_create_system_defs_date:",
      dcdosa_dm_info_dm2_create_system_defs_date))
    CALL echo(build("dm_ocd_setup_admin_data->dm2_create_system_defs:",dm_ocd_setup_admin_data->
      dm2_create_system_defs))
    CALL echo(build("dcdosa_dm_info_dm2_set_adm_cbo_date:",dcdosa_dm_info_dm2_set_adm_cbo_date))
    CALL echo(build("dm_ocd_setup_admin_data->dm2_set_adm_cbo:",dm_ocd_setup_admin_data->
      dm2_set_adm_cbo))
   ENDIF
   IF ((dm2_rdbms_version->level1 < 11))
    IF (((dcdosa_dm_info_schema_date < dcdosa_schema_date) OR ((((
    dcdosa_dm_info_dm_ocd_setup_admin_date < dm_ocd_setup_admin_data->dm_ocd_setup_admin_date)) OR ((
    dcdosa_dm_info_dm2_create_system_defs_date < dm_ocd_setup_admin_data->dm2_create_system_defs)))
    )) )
     SET dcdosa_requires_execution = 1
     RETURN(1)
    ENDIF
   ELSE
    IF (((dcdosa_dm_info_schema_date < dcdosa_schema_date) OR ((((
    dcdosa_dm_info_dm_ocd_setup_admin_date < dm_ocd_setup_admin_data->dm_ocd_setup_admin_date)) OR (
    (((dcdosa_dm_info_dm2_create_system_defs_date < dm_ocd_setup_admin_data->dm2_create_system_defs))
     OR ((dcdosa_dm_info_dm2_set_adm_cbo_date < dm_ocd_setup_admin_data->dm2_set_adm_cbo))) )) )) )
     SET dcdosa_requires_execution = 1
    ENDIF
    RETURN(1)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_check_for_package(dcfp_valid_ind,dcfp_env_id)
   SET dcfp_valid_ind = 0
   SET dcfp_env_id = 0.0
   IF (currdbuser != "V500")
    IF ((dm_err->debug_flag > 1))
     CALL echo("Bypassing check for package history.")
    ENDIF
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Find environment id."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info i
    WHERE i.info_domain="DATA MANAGEMENT"
     AND i.info_name="DM_ENV_ID"
    DETAIL
     dcfp_env_id = i.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dcfp_valid_ind = 0
    RETURN(1)
   ENDIF
   SET dm_err->eproc = build("Look for package history for environment id :",dcfp_env_id)
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_ocd_log l
    WHERE l.environment_id=dcfp_env_id
    WITH nocounter, maxqual(l,1)
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dcfp_valid_ind = 0
   ELSE
    SET dcfp_valid_ind = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_dg_data(dgdd_assign_dg_ind,dgdd_dg_override,dgdd_dg_out)
   DECLARE dgdd_dskgrp_name = vc WITH protect, noconstant("")
   DECLARE dgdd_dskgrp_state = vc WITH protect, noconstant("")
   DECLARE dgdd_chck = i2 WITH protect, noconstant(1)
   SET dm_err->eproc = "Get diskgroup information"
   CALL disp_msg("",dm_err->logfile,0)
   SET dgdd_dg_out = "NOT_SET"
   IF ((dm_err->debug_flag >= 2))
    CALL echo(build("Use initprm assign dg ind->",dgdd_assign_dg_ind))
    CALL echo(build("Diskgroup override->",dgdd_dg_override))
   ENDIF
   IF (dgdd_dg_override != "NOT_SET")
    SET dm_err->eproc = "Query for state of disk group "
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM v$asm_diskgroup v
     WHERE v.name=dgdd_dg_override
     DETAIL
      dgdd_dskgrp_state = cnvtupper(v.state)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dgdd_dskgrp_state IN ("MOUNTED", "CONNECTED"))
     SET dgdd_dg_out = dgdd_dg_override
     SET dgdd_chck = 0
    ENDIF
   ENDIF
   IF (dgdd_assign_dg_ind=1
    AND dgdd_chck=1)
    SET dm_err->eproc = "Query for disk group using db_create_file_dest"
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM v$parameter v
     WHERE v.name="db_create_file_dest"
     DETAIL
      dgdd_dskgrp_name = cnvtupper(v.value)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (findstring("+",dgdd_dskgrp_name,1,0) > 0)
     SET dgdd_dskgrp_name = trim(replace(dgdd_dskgrp_name,"+","",1),3)
    ENDIF
    SET dm_err->eproc = "Query to validate diskgroup"
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM v$asm_diskgroup v
     WHERE v.name=dgdd_dskgrp_name
     DETAIL
      dgdd_dskgrp_state = cnvtupper(v.state)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dgdd_dskgrp_state IN ("MOUNTED", "CONNECTED"))
     SET dgdd_dg_out = dgdd_dskgrp_name
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag >= 2))
    CALL echo(build("Determined diskgroup->",dgdd_dg_out))
   ENDIF
   IF (dgdd_dg_out != "NOT_SET")
    SET dir_ui_misc->tspace_dg = dgdd_dg_out
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_submit_jobs(dsj_plan_id,dsj_install_mode,dsj_user,dsj_pword,dsj_cnnct_str,
  dsj_queue_name,dsj_background_ind)
   DECLARE dsj_wait_time_minutes = i2 WITH protect, noconstant(15)
   DECLARE dsj_wait_timestamp = f8 WITH protect, noconstant(0.0)
   DECLARE dsj_wait_for_start = i2 WITH protect, noconstant(0)
   FREE RECORD dsj_request
   RECORD dsj_request(
     1 plan_id = f8
     1 install_mode = vc
   )
   FREE RECORD dsj_reply
   RECORD dsj_reply(
     1 install_status = vc
     1 event = vc
     1 install_mode_ret = vc
     1 message = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET dsj_request->plan_id = dsj_plan_id
   SET dsj_request->install_mode = "CURRENT"
   SET dsj_wait_timestamp = cnvtdatetime(curdate,curtime3)
   SET dm_err->eproc = "Get the status of auto installation"
   CALL disp_msg(" ",dm_err->logfile,0)
   EXECUTE dm2_auto_install_status  WITH replace("REQUEST",dsj_request), replace("REPLY",dsj_reply)
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ELSE
    IF ((dsj_reply->install_status="EXECUTING"))
     SET dm_err->eproc = "Checking the status of the auto install process"
     SET dm_err->emsg = concat("Active package install running for ",dsj_reply->install_mode_ret)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "submit the package install to background"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (drr_submit_background_process(dsj_user,dsj_pword,dsj_cnnct_str,dsj_queue_name,
    dpl_package_install,
    dsj_plan_id,dsj_install_mode)=0)
    RETURN(0)
   ENDIF
   IF (dsj_install_mode="*ABG")
    SET dsj_install_mode = replace(dsj_install_mode,"ABG","",2)
   ENDIF
   SET dm_err->eproc = "Waiting for background installation process to begin."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dm_err->eproc = "Check for wait time override"
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_SUBMIT_TIME_WAIT"
     AND d.info_name="MINUTES"
    DETAIL
     dsj_wait_time_minutes = d.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dsj_wait_for_start = 1
   WHILE (dsj_wait_for_start=1)
     IF (drr_cleanup_dm_info_runners(null)=0)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = "Wait for install to begin execution."
     SELECT INTO "nl:"
      FROM dm_process dp,
       dm_process_event dpe,
       dm_process_event_dtl dped1,
       dm_process_event_dtl dped2
      PLAN (dpe
       WHERE dpe.install_plan_id=dsj_plan_id
        AND dpe.begin_dt_tm >= cnvtdatetime(dsj_wait_timestamp))
       JOIN (dp
       WHERE dp.dm_process_id=dpe.dm_process_id
        AND dp.process_name=dpl_package_install
        AND dp.action_type=dpl_execution)
       JOIN (dped1
       WHERE dpe.dm_process_event_id=dped1.dm_process_event_id
        AND dped1.detail_type="INSTALL_MODE"
        AND dped1.detail_text=dsj_install_mode)
       JOIN (dped2
       WHERE dped1.dm_process_event_id=dped2.dm_process_event_id
        AND dped2.detail_type="UNATTENDED_IND")
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
     IF (curqual > 0)
      SET dsj_wait_for_start = 0
     ENDIF
     IF (datetimediff(cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)),cnvtdatetimeutc(cnvtdatetime(
        dsj_wait_timestamp)),4) > dsj_wait_time_minutes
      AND dsj_wait_for_start=1)
      SET dm_err->err_ind = 1
      SET dm_err->emsg = "Wait time expired. Unable to detect background install process."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     CALL pause(5)
   ENDWHILE
   IF (drr_submit_background_process(dsj_user,dsj_pword,dsj_cnnct_str,dsj_queue_name,
    dpl_install_monitor,
    dsj_plan_id,dsj_install_mode)=0)
    RETURN(0)
   ENDIF
   IF (dsj_background_ind=0)
    SET width = 132
    SET message = window
    CALL clear(1,1)
    CALL text(1,1,concat("The ",dsj_install_mode,
      " Installation is now submitted as a background process."))
    CALL text(3,1,"This session/connection is no longer required.")
    CALL text(5,1,"Notification emails about Installation events will be sent as they occur.")
    CALL text(8,1,concat("To monitor, stop or pause the execution of the background ",
      dsj_install_mode," Installation process,"))
    CALL text(9,1,"you can execute the following in CCL:")
    CALL text(11,1,"ccl> dm2_install_plan_menu go ")
    CALL text(13,3,"Enter 'C' to continue.")
    CALL accept(13,34,"p;cduh"," "
     WHERE curaccept IN ("C"))
    CALL clear(1,1)
    SET message = nowindow
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_check_in_parse(dcp_owner,dcp_table_name,dcp_in_parse_ind,dcp_ret_msg)
   SET dcp_in_parse_ind = 0
   SET dcp_ret_msg = ""
   SET dm_err->eproc = concat("Check if ",dcp_table_name," table is involved in a hard parse event.")
   SELECT INTO "nl:"
    FROM dm2_objects_in_parse d
    WHERE d.to_owner=dcp_owner
     AND d.to_name=dcp_table_name
    DETAIL
     dcp_in_parse_ind = 1, dcp_ret_msg = concat("Encountered parse event against ",trim(dcp_owner),
      ".",dcp_table_name,". SQL_ID = ",
      trim(d.sql_id),", Session_Id:",trim(cnvtstring(d.session_id)),", Serial#: ",trim(cnvtstring(d
        .session_serial#)),
      ".")
    WITH nocounter, maxqual(d,1)
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_ddl_gen_retry(dgr_retry_ceiling)
   DECLARE dgr_di_exists = i2 WITH protect, noconstant(0)
   SET dgr_retry_ceiling = 10
   IF (dm2_table_and_ccldef_exists("DM_INFO",dgr_di_exists)=0)
    RETURN(0)
   ENDIF
   IF (dgr_di_exists=1)
    SET dm_err->eproc = "Check for retry ceiling override."
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="DM2_DDL_GEN"
      AND d.info_name="RETRY CEILING"
     DETAIL
      dgr_retry_ceiling = d.info_number
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dgr_retry_ceiling <= 0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Retry ceiling is invalid (must be greater than zero)."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_load_users_pwds(dlup_users_for_pwd)
   DECLARE dlup_user = vc WITH protect, noconstant("")
   DECLARE dlup_notfnd = vc WITH protect, constant("<not_found>")
   DECLARE dlup_num = i4 WITH protect, noconstant(1)
   DECLARE dlup_idx = i2 WITH protect, noconstant(0)
   DECLARE dlup_choice = vc WITH protect, noconstant("")
   IF (size(dlup_users_for_pwd)=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Loading users into record structure for password prompt."
    SET dm_err->emsg = "No user specified."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Loading users into record structure for password prompt."
   CALL disp_msg(" ",dm_err->logfile,0)
   WHILE (dlup_user != dlup_notfnd)
     SET dlup_user = piece(dlup_users_for_pwd,",",dlup_num,dlup_notfnd)
     SET dlup_num = (dlup_num+ 1)
     IF (dlup_user != dlup_notfnd)
      SET dlup_idx = locateval(dlup_idx,1,dir_db_users_pwds->cnt,dlup_user,dir_db_users_pwds->qual[
       dlup_idx].user)
      IF (dlup_idx=0)
       SET dir_db_users_pwds->cnt = (dir_db_users_pwds->cnt+ 1)
       SET stat = alterlist(dir_db_users_pwds->qual,dir_db_users_pwds->cnt)
       SET dir_db_users_pwds->qual[dir_db_users_pwds->cnt].user = dlup_user
       CALL clear(1,1)
       CALL text(6,2,concat("Please enter password for user ",dir_db_users_pwds->qual[
         dir_db_users_pwds->cnt].user,": "))
       CALL text(10,1,"Enter 'C' to continue or 'Q' to exit process. (C or Q): ")
       CALL accept(6,50,"P(30);C"," "
        WHERE  NOT (curaccept=" "))
       SET dir_db_users_pwds->qual[dir_db_users_pwds->cnt].pwd = build(curaccept)
       CALL accept(10,60,"A;cu"," "
        WHERE curaccept IN ("Q", "C"))
       SET dlup_choice = curaccept
       IF (dlup_choice="Q")
        SET message = nowindow
        SET dm_err->err_ind = 1
        SET dm_err->emsg = "User quit process.  "
        SET dm_err->eproc = "Prompting for database user password."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
   ENDWHILE
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dir_db_users_pwds)
   ENDIF
   IF ((dir_db_users_pwds->cnt=0))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating user/password list."
    SET dm_err->emsg = "Database user/password not loaded into memory."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_adm_appl_status(dgaps_dblink,dgaps_audsid,dgaps_status)
   SET dgaps_status = "ACTIVE"
   IF (cnvtupper(dgaps_audsid)="-15301")
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    FROM (value(concat("GV$SESSION@",dgaps_dblink)) s)
    WHERE s.audsid=cnvtint(dgaps_audsid)
    WITH nocounter
   ;end select
   IF (check_error("Selecting from gv$session in subroutine dir_get_adm_appl_status")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SELECT INTO "nl:"
     FROM (value(concat("V$SESSION@",dgaps_dblink)) s)
     WHERE s.audsid=cnvtint(dgaps_audsid)
     WITH nocounter
    ;end select
    IF (check_error("Selecting from v$session in subroutine dir_get_adm_appl_status")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET dgaps_status = "INACTIVE"
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_upd_adm_upgrade_info(null)
   DECLARE duaui_schema_date = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Deleting from dm_info for dm_ocd_setup_admin."
   CALL disp_msg(" ",dm_err->logfile,0)
   DELETE  FROM dm_info di
    WHERE di.info_domain="DM_OCD_SETUP_ADMIN COMPLETE"
     AND di.info_name IN ("SCHEMA_DATE", "DM_OCD_SETUP_ADMIN_DATE", "DM2_CREATE_SYSTEM_DEFS_DATE",
    "DM2_SET_ADM_CBO_DATE")
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   IF (dcfr_sea_csv_files(cnvtlower(trim(logical("cer_install"),3)),"dm2a",duaui_schema_date)=0)
    RETURN(0)
   ELSE
    IF (duaui_schema_date="01-JAN-1800")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("Schema Date: ",duaui_schema_date))
   ENDIF
   SET dm_err->eproc = "Selecting date/timestamps from dprotect."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dprotect dp
    WHERE dp.object="P"
     AND dp.object_name IN ("DM_OCD_SETUP_ADMIN", "DM2_CREATE_SYSTEM_DEFS", "DM2_SET_ADM_CBO")
    DETAIL
     CASE (dp.object_name)
      OF "DM_OCD_SETUP_ADMIN":
       dm_ocd_setup_admin_data->dm_ocd_setup_admin_date = cnvtdatetime(dp.datestamp,dp.timestamp)
      OF "DM2_CREATE_SYSTEM_DEFS":
       dm_ocd_setup_admin_data->dm2_create_system_defs = cnvtdatetime(dp.datestamp,dp.timestamp)
      OF "DM2_SET_ADM_CBO":
       dm_ocd_setup_admin_data->dm2_set_adm_cbo = cnvtdatetime(dp.datestamp,dp.timestamp)
     ENDCASE
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Inserting schema_date row into dm_info."
   CALL disp_msg(" ",dm_err->logfile,0)
   INSERT  FROM dm_info di
    SET di.info_domain = "DM_OCD_SETUP_ADMIN COMPLETE", di.info_name = "SCHEMA_DATE", di.info_char =
     duaui_schema_date,
     di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = 0, di.updt_cnt = 0,
     di.updt_id = 0, di.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Inserting dm_ocd_setup_admin_date row into dm_info."
   CALL disp_msg(" ",dm_err->logfile,0)
   INSERT  FROM dm_info di
    SET di.info_domain = "DM_OCD_SETUP_ADMIN COMPLETE", di.info_name = "DM_OCD_SETUP_ADMIN_DATE", di
     .info_char = format(dm_ocd_setup_admin_data->dm_ocd_setup_admin_date,"DD-MMM-YYYY HH:MM:SS;;q"),
     di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = 0, di.updt_cnt = 0,
     di.updt_id = 0, di.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Inserting dm2_create_system_defs_date row into dm_info."
   CALL disp_msg(" ",dm_err->logfile,0)
   INSERT  FROM dm_info di
    SET di.info_domain = "DM_OCD_SETUP_ADMIN COMPLETE", di.info_name = "DM2_CREATE_SYSTEM_DEFS_DATE",
     di.info_char = format(dm_ocd_setup_admin_data->dm2_create_system_defs,"DD-MMM-YYYY HH:MM:SS;;q"),
     di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = 0, di.updt_cnt = 0,
     di.updt_id = 0, di.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Inserting dm2_set_adm_cbo_date row into dm_info."
   CALL disp_msg(" ",dm_err->logfile,0)
   INSERT  FROM dm_info di
    SET di.info_domain = "DM_OCD_SETUP_ADMIN COMPLETE", di.info_name = "DM2_SET_ADM_CBO_DATE", di
     .info_char = format(dm_ocd_setup_admin_data->dm2_set_adm_cbo,"DD-MMM-YYYY HH:MM:SS;;q"),
     di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = 0, di.updt_cnt = 0,
     di.updt_id = 0, di.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_custom_constraints(null)
   DECLARE dgcc_constraint_index = i2 WITH protect, noconstant(0)
   SET dir_custom_constraints->con_cnt = 0
   SET stat = initrec(dir_custom_constraints)
   SET dm_err->eproc = "Retrieving custom constraints"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_CUSTOM_CONSTRAINTS"
    DETAIL
     dgcc_constraint_index = (dgcc_constraint_index+ 1)
     IF (mod(dgcc_constraint_index,10)=1)
      stat = alterlist(dir_custom_constraints->con,(dgcc_constraint_index+ 9))
     ENDIF
     dir_custom_constraints->con[dgcc_constraint_index].constraint_name = di.info_name
    FOOT REPORT
     stat = alterlist(dir_custom_constraints->con,dgcc_constraint_index), dir_custom_constraints->
     con_cnt = dgcc_constraint_index
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dgcc_constraint_index=0)
    SET stat = alterlist(dir_custom_constraints->con,2)
    SET dir_custom_constraints->con[1].constraint_name = "CUCIM_ACQUIRED_STUDY"
    SET dir_custom_constraints->con[2].constraint_name = "CUCIM_SERIES"
    SET dir_custom_constraints->con_cnt = 2
   ELSE
    SET dgcc_constraint_index = 0
    IF (locateval(dgcc_constraint_index,1,dir_custom_constraints->con_cnt,"CUCIM_ACQUIRED_STUDY",
     dir_custom_constraints->con[dgcc_constraint_index].constraint_name)=0)
     SET dir_custom_constraints->con_cnt = (dir_custom_constraints->con_cnt+ 1)
     SET stat = alterlist(dir_custom_constraints->con,dir_custom_constraints->con_cnt)
     SET dir_custom_constraints->con[dir_custom_constraints->con_cnt].constraint_name =
     "CUCIM_ACQUIRED_STUDY"
    ENDIF
    SET dgcc_constraint_index = 0
    IF (locateval(dgcc_constraint_index,1,dir_custom_constraints->con_cnt,"CUCIM_SERIES",
     dir_custom_constraints->con[dgcc_constraint_index].constraint_name)=0)
     SET dir_custom_constraints->con_cnt = (dir_custom_constraints->con_cnt+ 1)
     SET stat = alterlist(dir_custom_constraints->con,dir_custom_constraints->con_cnt)
     SET dir_custom_constraints->con[dir_custom_constraints->con_cnt].constraint_name =
     "CUCIM_SERIES"
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_admin_db_link(dgadl_report_fail_ind,dgadl_admin_db_link,dgadl_fail_ind)
   DECLARE dgadl_admin_env_id = f8 WITH protect, noconstant(0.0)
   DECLARE dgadl_admin_link_match = i2 WITH protect, noconstant(0)
   SET dgadl_fail_ind = 0
   SET dm_err->eproc = "Obtain Admin database link name"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_environment de,
     dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="DM_ENV_ID"
     AND de.environment_id=di.info_number
    DETAIL
     dgadl_admin_db_link = de.admin_dbase_link_name, dgadl_admin_env_id = de.environment_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (textlen(dgadl_admin_db_link)=0)
    SET dgadl_fail_ind = 1
    IF (dgadl_report_fail_ind=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Admin database link is not valued in DM_ENVIRONMENT.admin_dbase_link_name."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dgadl_fail_ind=0)
    SET dm_err->eproc = "Validate Admin database link name"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (parser(concat("cdba.dm_environment@",dgadl_admin_db_link)) de)
     WHERE de.environment_id=dgadl_admin_env_id
     DETAIL
      IF (cnvtupper(dgadl_admin_db_link)=cnvtupper(de.admin_dbase_link_name))
       dgadl_admin_link_match = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->err_ind = 0
    ENDIF
    IF (dgadl_admin_link_match=0)
     SET dgadl_fail_ind = 1
     IF (dgadl_report_fail_ind=0)
      SET dm_err->err_ind = 1
      SET dm_err->emsg =
      "Admin database link does not exist in database or is causing data inconsistency when used."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 IF ( NOT (validate(dguc_request,0)))
  FREE RECORD dguc_request
  RECORD dguc_request(
    1 what_tables = vc
    1 is_ref_ind = i2
    1 is_mrg_ind = i2
    1 only_special_ind = i2
    1 current_remote_db = i2
    1 local_tables_ind = i2
    1 db_link = vc
    1 req_special[*]
      2 sp_tbl = vc
  )
 ENDIF
 IF ( NOT (validate(dguc_reply,0)))
  FREE RECORD dguc_reply
  RECORD dguc_reply(
    1 rs_tbl_cnt = i4
    1 dguc_err_ind = i2
    1 dguc_err_msg = vc
    1 dtd_hold[*]
      2 tbl_name = vc
      2 tbl_suffix = vc
      2 pk_cnt = i4
      2 pk_hold[*]
        3 pk_datatype = vc
        3 pk_name = vc
  )
 ENDIF
 IF (validate(derg_request->env_id,- (1)) < 0)
  FREE RECORD derg_request
  RECORD derg_request(
    1 env_id = f8
    1 relationship_type = vc
  )
 ENDIF
 IF (validate(derg_reply->err_num,- (1)) < 0)
  FREE RECORD derg_reply
  RECORD derg_reply(
    1 parent_env_list[*]
      2 env_id = f8
      2 env_name = vc
      2 relationship_type = vc
      2 pre_link_name = vc
      2 post_link_name = vc
      2 no_log_ind = i2
    1 child_env_list[*]
      2 env_id = f8
      2 env_name = vc
      2 relationship_type = vc
      2 pre_link_name = vc
      2 post_link_name = vc
      2 no_log_ind = i2
    1 err_num = i4
    1 err_msg = vc
  )
 ENDIF
 FREE RECORD dyn_ui_search
 RECORD dyn_ui_search(
   1 qual[*]
     2 pk_value = f8
     2 other = vc
 )
 IF (validate(drdm_sequence->qual[1].seq_val,- (1)) < 0)
  FREE RECORD drdm_sequence
  RECORD drdm_sequence(
    1 qual[*]
      2 seq_name = vc
      2 seq_val = f8
  )
 ENDIF
 IF (validate(dm2_rdds_rec->mode,"NONE")="NONE")
  FREE RECORD dm2_rdds_rec
  RECORD dm2_rdds_rec(
    1 mode = vc
    1 main_process = vc
  )
 ENDIF
 IF (validate(ui_query_rec->table_name,"NONE")="NONE")
  FREE RECORD ui_query_rec
  RECORD ui_query_rec(
    1 table_name = vc
    1 dom = vc
    1 usage = vc
    1 qual[*]
      2 qtype = vc
      2 where_clause = vc
      2 cqual[*]
        3 query_idx = i2
      2 other_pk_col[*]
        3 col_name = vc
  )
  FREE RECORD ui_query_eval_rec
  RECORD ui_query_eval_rec(
    1 qual[*]
      2 root_entity_attr = f8
      2 additional_attr = vc
  )
 ENDIF
 IF (validate(select_merge_translate_rec->type,"NONE")="NONE")
  FREE RECORD select_merge_translate_rec
  RECORD select_merge_translate_rec(
    1 type = vc
  )
 ENDIF
 DECLARE find_p_e_col(sbr_p_e_name=vc,sbr_p_e_col=i4) = vc
 DECLARE dm_translate(sbr_tbl_name=vc,sbr_col_name=vc,sbr_from_val=vc) = vc
 DECLARE dm_trans2(sbr_tbl_name=vc,sbr_col_name=vc,sbr_from_val=vc,sbr_src_ind=i2) = vc
 DECLARE dm_trans3(sbr_tbl_name=vc,sbr_col_name=vc,sbr_from_val=f8,sbr_src_ind=i2,sbr_pe_tbl_name=vc)
  = vc
 DECLARE insert_update_row(iur_temp_tbl_cnt=i4,iur_perm_col_cnt=i4) = i2
 DECLARE query_target(qt_temp_tbl_cnt=i4,qt_perm_col_cnt=i4) = f8 WITH public
 DECLARE merge_audit(action=vc,text=vc,audit_type=i4) = null
 DECLARE parse_statements(parser_cnt=i4) = null
 DECLARE insert_merge_translate(sbr_from=f8,sbr_to=f8,sbr_table=vc) = i2
 DECLARE select_merge_translate(sbr_f_value=vc,sbr_t_name=vc) = vc
 DECLARE del_chg_log(sbr_table_name=vc,sbr_log_type=vc,sbr_target_id=f8) = null
 DECLARE report_missing(sbr_table_name=vc,sbr_column_name=vc,sbr_value=f8) = vc
 DECLARE rdds_del_except(sbr_table_name=vc,sbr_value=f8) = null
 DECLARE version_exception(sbr_table_name=vc,sbr_column_name=vc,sbr_value=f8) = null
 DECLARE orphan_child_tab(sbr_table_name=vc,sbr_log_type=vc) = i2
 DECLARE dm2_rdds_get_tbl_alias(sbr_tbl_suffix=vc) = vc
 DECLARE dm2_get_rdds_tname(sbr_tname=vc) = vc
 DECLARE exec_ui_query(exec_tbl_cnt=i4,exec_perm_col_cnt=i4) = f8 WITH public
 DECLARE evaluate_exec_ui_query(sbr_current_qual=i4,eval_tbl_cnt=i4,eval_perm_col_cnt=i4) = f8 WITH
 public
 DECLARE insert_noxlat(sbr_table_name=vc,sbr_column_name=vc,sbr_value=f8,sbr_orphan_ind=i2) = i2
 DECLARE add_rs_values(sbr_table_name=vc,sbr_column_name=vc,sbr_value=f8) = i4
 DECLARE trigger_proc_call(tpc_table_name=vc,tpc_pk_where=vc,tpc_context=vc,tpc_col_name=vc,tpc_value
  =f8) = i2
 DECLARE filter_proc_call(fpc_table_name=vc,fpc_pk_where=vc) = i2
 DECLARE replace_carrot_symbol(rcs_string=vc) = vc
 SUBROUTINE query_target(qt_temp_tbl_cnt,qt_perm_col_cnt)
   DECLARE sbr_active_value = i2
   DECLARE sbr_effective_date = f8
   DECLARE sbr_end_effective_date = f8
   DECLARE sbr_returned_value = f8
   DECLARE sbr_cur_date = f8
   DECLARE sbr_rec_size = i4
   DECLARE sbr_null_beg_ind = i2
   DECLARE sbr_null_end_ind = i2
   SET sbr_cur_date = cnvtdatetime(curdate,curtime3)
   SET sbr_table_name = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name
   SET drdm_return_var = 0
   IF ((dm2_ref_data_doc->tbl_qual[qt_temp_tbl_cnt].merge_delete_ind=1))
    RETURN(- (3))
   ELSE
    SET dm_err->eproc = "Query Target"
    CALL echo("")
    CALL echo("")
    CALL echo("*******************QUERY TARGET***************************")
    CALL echo("")
    CALL echo("")
    SET sbr_rec_size = 1
    SET stat = alterlist(ui_query_rec->qual,sbr_rec_size)
    SET ui_query_rec->table_name = sbr_table_name
    SET ui_query_rec->usage = ""
    SET ui_query_rec->dom = "TO"
    SET ui_query_rec->qual[sbr_rec_size].qtype = "UIONLY"
    IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].active_ind_ind=1))
     SET sbr_rec_size = (sbr_rec_size+ 1)
     SET stat = alterlist(ui_query_rec->qual,sbr_rec_size)
     SET sbr_active_value = cnvtreal(get_value(sbr_table_name,"ACTIVE_IND","FROM"))
     IF (sbr_active_value=1)
      SET ui_query_rec->qual[sbr_rec_size].qtype = "ACTIVE"
     ELSE
      SET ui_query_rec->qual[sbr_rec_size].qtype = "INACTIVE"
     ENDIF
    ENDIF
    IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].effective_col_ind=1))
     SET sbr_null_beg_ind = get_nullind(sbr_table_name,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
      beg_col_name)
     SET sbr_null_end_ind = get_nullind(sbr_table_name,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
      end_col_name)
     IF (((sbr_null_beg_ind=1) OR (sbr_null_end_ind=1)) )
      SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].effective_col_ind = 0
     ELSE
      SET sbr_rec_size = (sbr_rec_size+ 1)
      SET stat = alterlist(ui_query_rec->qual,sbr_rec_size)
      CALL parser(concat("set sbr_effective_date = RS_",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
        suffix,"->from_values.",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].beg_col_name," go "),1)
      CALL parser(concat("set sbr_end_effective_date = RS_",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
        suffix,"->from_values.",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].end_col_name," go "),1)
      IF (sbr_effective_date <= sbr_cur_date
       AND sbr_end_effective_date >= sbr_cur_date)
       SET ui_query_rec->qual[sbr_rec_size].qtype = "EFFECTIVE"
      ELSE
       SET ui_query_rec->qual[sbr_rec_size].qtype = "END_EFFECTIVE"
      ENDIF
     ENDIF
     IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].active_ind_ind=1)
      AND (dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].effective_col_ind=1))
      SET sbr_rec_size = (sbr_rec_size+ 1)
      SET stat = alterlist(ui_query_rec->qual,sbr_rec_size)
      SET ui_query_rec->qual[sbr_rec_size].qtype = "COMBO"
      SET stat = alterlist(ui_query_rec->qual[sbr_rec_size].cqual,2)
      SET ui_query_rec->qual[sbr_rec_size].cqual[1].query_idx = 2
      SET ui_query_rec->qual[sbr_rec_size].cqual[2].query_idx = 3
     ENDIF
    ENDIF
    SET sbr_returned_value = exec_ui_query(qt_temp_tbl_cnt,qt_perm_col_cnt)
    SET stat = alterlist(ui_query_rec->qual[sbr_rec_size].other_pk_col,0)
    RETURN(sbr_returned_value)
   ENDIF
 END ;Subroutine
 SUBROUTINE exec_ui_query(exec_tbl_cnt,exec_perm_col_cnt)
   DECLARE sbr_while_loop = i2
   DECLARE sbr_done_select = i2
   DECLARE sbr_loop = i2
   DECLARE sbr_other_loop = i2
   DECLARE query_cnt = i4
   DECLARE sbr_eff_date = f8
   DECLARE sbr_end_eff_date = f8
   DECLARE sbr_cur_date = f8
   DECLARE query_return = f8
   DECLARE rs_tab_prefix = vc
   DECLARE sbr_domain = vc
   DECLARE add_ndx = i4
   DECLARE ndx_loop = i4
   DECLARE add_col_name = vc
   DECLARE add_d_type = vc
   DECLARE euq_ord_col = vc
   SET rs_tab_prefix = concat("RS_",dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].suffix)
   SET sbr_cur_date = cnvtdatetime(curdate,curtime3)
   SET euq_ord_col = ""
   FOR (sbr_loop = 1 TO size(ui_query_eval_rec->qual,5))
     SET ui_query_eval_rec->qual[sbr_loop].additional_attr = ""
   ENDFOR
   SET sbr_loop = 1
   SET sbr_done_select = 0
   IF ((ui_query_rec->dom="FROM"))
    SET sbr_domain = "FROM"
   ELSE
    SET sbr_domain = "TO"
   ENDIF
   WHILE (sbr_loop <= size(ui_query_rec->qual,5)
    AND sbr_done_select=0)
     SET stat = alterlist(ui_query_eval_rec->qual,0)
     SET query_cnt = 0
     IF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].merge_ui_query_ni=1))
      IF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].root_entity_name=
      dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].table_name)
       AND (dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].root_entity_attr=
      dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].column_name)
       AND (dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].pk_ind=1))
       SET drdm_parser->statement[1].frag = concat("select into 'NL:' dc.",value(dm2_ref_data_doc->
         tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].root_entity_attr))
      ELSE
       SET drdm_parser->statement[1].frag = "select into 'NL:' "
      ENDIF
      SET drdm_parser->statement[2].frag = concat(" from ",value(ui_query_rec->table_name)," dc ",
       " where ")
      SET drdm_parser_cnt = 3
      FOR (drdm_loop_cnt = 1 TO exec_perm_col_cnt)
        IF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[drdm_loop_cnt].unique_ident_ind=1))
         SET no_unique_ident = 1
         IF (drdm_parser_cnt > 3)
          SET drdm_parser->statement[drdm_parser_cnt].frag = " and "
          SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
         ENDIF
         SET drdm_col_name = dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[drdm_loop_cnt].
         column_name
         SET drdm_from_con = concat(rs_tab_prefix,"->",sbr_domain,"_values.",drdm_col_name)
         IF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[drdm_loop_cnt].check_null=1))
          IF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[drdm_loop_cnt].data_type IN ("DQ8",
          "F8", "I4", "I2")))
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = NULL")
          ELSE
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" (dc.",drdm_col_name,
            " = null or ",drdm_col_name," = ' ')")
          ENDIF
          SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
         ELSEIF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[drdm_loop_cnt].check_space=1))
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" (dc.",drdm_col_name,
           " = ' ' or ",drdm_col_name," = null)")
          SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
         ELSE
          CASE (dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[drdm_loop_cnt].data_type)
           OF "DQ8":
            SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name,
             " =  cnvtdatetime(",drdm_from_con,")")
            SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           ELSE
            SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = ",
             drdm_from_con)
            SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
          ENDCASE
         ENDIF
        ENDIF
      ENDFOR
      IF (no_unique_ident=0)
       SET insert_update_reason = "There were no unique_ident_ind's for log_id "
       SET no_insert_update = 1
       SET dm2_ref_data_reply->error_ind = 1
       SET dm2_ref_data_reply->error_msg = concat(dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].
        custom_script,": There were no unique_ident_ind's")
       RETURN(- (2))
      ENDIF
      SET sbr_current_date = cnvtdatetime(curdate,curtime3)
      CASE (ui_query_rec->qual[sbr_loop].qtype)
       OF "UIONLY":
       OF patstring("ORDER*",0):
        SET ui_query_rec->qual[sbr_loop].where_clause = ""
       OF "ACTIVE":
        SET ui_query_rec->qual[sbr_loop].where_clause = " AND dc.ACTIVE_IND = 1"
       OF "INACTIVE":
        SET ui_query_rec->qual[sbr_loop].where_clause = " AND dc.ACTIVE_IND = 0"
       OF "EFFECTIVE":
        SET ui_query_rec->qual[sbr_loop].where_clause = concat(" AND dc.",dm2_ref_data_doc->tbl_qual[
         temp_tbl_cnt].beg_col_name,"<=  cnvtdatetime(sbr_cur_date) AND dc.",dm2_ref_data_doc->
         tbl_qual[temp_tbl_cnt].end_col_name,">= cnvtdatetime(sbr_cur_date)")
       OF "END_EFFECTIVE":
        SET ui_query_rec->qual[sbr_loop].where_clause = concat(" AND dc.",dm2_ref_data_doc->tbl_qual[
         temp_tbl_cnt].beg_col_name,">=  cnvtdatetime(sbr_cur_date) OR dc.",dm2_ref_data_doc->
         tbl_qual[temp_tbl_cnt].end_col_name,"<= cnvtdatetime(sbr_cur_date)")
       OF "COMBO":
        FOR (sbr_other_loop = 1 TO size(ui_query_rec->qual[sbr_loop].cqual,5))
          SET ui_query_rec->qual[sbr_loop].where_clause = concat(ui_query_rec->qual[sbr_loop].
           where_clause,ui_query_rec->qual[ui_query_rec->qual[sbr_loop].cqual[sbr_other_loop].
           query_idx].where_clause)
        ENDFOR
      ENDCASE
      IF ((ui_query_rec->qual[sbr_loop].where_clause != ""))
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(ui_query_rec->qual[sbr_loop].
        where_clause)
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ENDIF
      IF ((ui_query_rec->qual[sbr_loop].qtype="ORDER:*"))
       SET euq_ord_col = substring((findstring(":",ui_query_rec->qual[sbr_loop].qtype,1,0)+ 1),(size(
         ui_query_rec->qual[sbr_loop].qtype) - findstring(":",ui_query_rec->qual[sbr_loop].qtype,1,0)
        ),ui_query_rec->qual[sbr_loop].qtype)
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" ORDER BY dc.",euq_ord_col)
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ENDIF
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" head report",
       " stat = alterlist(ui_query_eval_rec->qual, 10)"," query_cnt = 0")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" detail query_cnt = query_cnt + 1 ")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(
       "if (mod(query_cnt,10) = 1 and query_cnt != 1)")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(
       " stat = alterlist(ui_query_eval_rec->qual, query_cnt + 9)")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" endif")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      IF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].root_entity_name=
      dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].table_name)
       AND (dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].root_entity_attr=
      dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].column_name)
       AND (dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].pk_ind=1))
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(
        "ui_query_eval_rec->qual[query_cnt]->root_entity_attr = dc.",value(dm2_ref_data_doc->
         tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].root_entity_attr))
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ENDIF
      IF (size(ui_query_rec->qual[sbr_loop].other_pk_col,5) > 0)
       IF ((ui_query_rec->qual[sbr_loop].other_pk_col[1].col_name != ""))
        SET add_col_name = ui_query_rec->qual[sbr_loop].other_pk_col[1].col_name
        SET add_ndx = locateval(ndx_loop,1,dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_cnt,
         add_col_name,dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[ndx_loop].column_name)
        IF (add_ndx > 0)
         SET add_d_type = dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[add_ndx].data_type
         IF ( NOT (add_d_type IN ("VC", "C*")))
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(
           " ui_query_eval_rec->qual[query_cnt]->additional_attr = cnvtstring(dc.",add_col_name,")")
         ELSE
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(
           " ui_query_eval_rec->qual[query_cnt]->additional_attr = dc.",add_col_name)
         ENDIF
         SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        ENDIF
       ENDIF
      ENDIF
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" foot report",
       " stat = alterlist(ui_query_eval_rec->qual, query_cnt)"," with nocounter go")
      CALL parse_statements(drdm_parser_cnt)
      IF (nodelete_ind=1)
       SET query_return = - (1)
       SET sbr_done_select = 1
      ELSEIF ((query_return != - (1)))
       SET query_return = evaluate_exec_ui_query(query_cnt,exec_tbl_cnt,exec_perm_col_cnt)
      ENDIF
      IF ((((query_return=- (3))) OR (query_return >= 0)) )
       SET sbr_done_select = 1
      ELSE
       SET sbr_loop = (sbr_loop+ 1)
      ENDIF
     ENDIF
   ENDWHILE
   IF ((query_return=- (2))
    AND (ui_query_rec->usage != "VERSION"))
    SET insert_update_reason = "Multiple values returned with unique indicator query for log_id "
    SET no_insert_update = 1
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = "NOMV06"
    SET drdm_mini_loop_status = "NOMV06"
    ROLLBACK
    CALL orphan_child_tab(sbr_table_name,"NOMV06")
    COMMIT
   ENDIF
   RETURN(query_return)
 END ;Subroutine
 SUBROUTINE evaluate_exec_ui_query(sbr_current_qual,eval_tbl_cnt,eval_perm_col_cnt)
   DECLARE sbr_eval_loop = i4
   DECLARE sbr_trans_val = vc
   DECLARE sbr_table_name = vc
   DECLARE sbr_root_entity_attr_val = f8
   DECLARE sbr_not_translated_count = i4
   DECLARE sbr_value_pos = i4
   DECLARE sbr_temp_pk_value = f8
   SET sbr_table_name = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name
   SET sbr_eval_loop = 1
   SET sbr_not_translated_count = 0
   IF (sbr_current_qual=0)
    RETURN(- (3))
   ELSEIF (sbr_current_qual=1)
    IF ((((ui_query_rec->usage="VERSION")
     AND sbr_temp_pk_value != 0) OR ((ui_query_rec->usage != "VERSION"))) )
     SET sbr_temp_pk_value = ui_query_eval_rec->qual[sbr_eval_loop].root_entity_attr
     SET select_merge_translate_rec->type = "TO"
     SET sbr_trans_val = select_merge_translate(cnvtstring(sbr_temp_pk_value),sbr_table_name)
     SET select_merge_translate_rec->type = "FROM"
     IF (sbr_trans_val="No Trans")
      SET sbr_root_entity_attr_val = value(ui_query_eval_rec->qual[sbr_eval_loop].root_entity_attr)
      RETURN(sbr_root_entity_attr_val)
     ELSE
      IF ((ui_query_rec->usage="VERSION"))
       SET sbr_root_entity_attr_val = value(ui_query_eval_rec->qual[sbr_eval_loop].root_entity_attr)
       RETURN(sbr_root_entity_attr_val)
      ELSE
       RETURN(- (3))
      ENDIF
     ENDIF
    ELSE
     SET sbr_root_entity_attr_val = value(ui_query_eval_rec->qual[sbr_eval_loop].root_entity_attr)
     RETURN(sbr_root_entity_attr_val)
    ENDIF
   ELSE
    IF ((ui_query_rec->usage="VERSION"))
     RETURN(- (2))
    ELSE
     FOR (sbr_eval_loop = 1 TO sbr_current_qual)
       SET sbr_temp_pk_value = ui_query_eval_rec->qual[sbr_eval_loop].root_entity_attr
       SET select_merge_translate_rec->type = "TO"
       SET sbr_trans_val = select_merge_translate(cnvtstring(sbr_temp_pk_value),sbr_table_name)
       IF (sbr_trans_val="No Trans")
        SET sbr_not_translated_count = (sbr_not_translated_count+ 1)
        SET sbr_val_pos = sbr_eval_loop
       ENDIF
     ENDFOR
     SET select_merge_translate_rec->type = "FROM"
     IF (sbr_not_translated_count=0)
      RETURN(- (3))
     ELSEIF (sbr_not_translated_count=1)
      SET current_qual = ui_query_eval_rec->qual[sbr_val_pos].root_entity_attr
      RETURN(current_qual)
     ELSE
      RETURN(- (2))
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE insert_update_row(iur_temp_tbl_cnt,iur_perm_col_cnt)
   DECLARE first_where = i2
   DECLARE active_in = i2
   DECLARE drdm_col_name = vc
   DECLARE drdm_table_name = vc
   DECLARE p_tab_ind = i2
   DECLARE sbr_data_type = vc
   DECLARE no_update_ind = i2
   DECLARE non_key_ind = i2
   DECLARE pk_cnt = i4
   DECLARE iur_tgt_pk_where = vc
   DECLARE iur_del_loop = i4
   DECLARE iur_del_ind = i2
   DECLARE iur_child_loop = i4
   DECLARE iur_child_pk_cnt = i4
   DECLARE src_pk_where = vc
   DECLARE iur_tbl_alias = vc
   SET iur_del_ind = 0
   SET drdm_table_name = concat("RS_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix)
   SET dm_err->eproc = concat("Inserting or Updating Row ",cnvtstring(drdm_chg->log[drdm_log_loop].
     log_id))
   CALL echo("")
   CALL echo("")
   CALL echo("*******************INSERTING OR UPDATING ROW******************")
   CALL echo("")
   CALL echo("")
   IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].merge_delete_ind=1)
    AND (drdm_chg->log[drdm_log_loop].md_delete_ind=1))
    IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].parent_flag=2))
     SET drdm_parser_cnt = 1
     FOR (iur_child_loop = 1 TO size(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].parent_qual,5))
       SET drdm_parser->statement[1].frag = concat("delete from ",dm2_ref_data_doc->tbl_qual[
        iur_temp_tbl_cnt].parent_qual[iur_child_loop].child_name," where ")
       IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].parent_qual[iur_child_loop].parent_tab_col
        != ""))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat(dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].parent_qual[iur_child_loop].parent_tab_col," = '",dm2_ref_data_doc->
         tbl_qual[iur_temp_tbl_cnt].table_name,"' and ")
       ENDIF
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(dm2_ref_data_doc->tbl_qual[
        iur_temp_tbl_cnt].parent_qual[iur_child_loop].parent_id_col," in (select ")
       FOR (iur_del_loop = 1 TO perm_col_cnt)
         IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].pk_ind=1))
          SET iur_child_pk_cnt = (iur_child_pk_cnt+ 1)
          IF (iur_child_pk_cnt=1)
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" c.",dm2_ref_data_doc->
            tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name)
          ENDIF
         ENDIF
       ENDFOR
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" from ",dm2_ref_data_doc->tbl_qual[
        iur_temp_tbl_cnt].table_name," c where ")
       FOR (iur_del_loop = 1 TO perm_col_cnt)
         IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].merge_delete_ind=1)
         )
          IF (iur_del_ind=1)
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = " and "
          ENDIF
          IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="DQ8"))
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
            iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, rs_",
            dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
            tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
          ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="VC"
          ))
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
            iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, evaluate(",
            trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
              check_space)),", 1, ' ', 0,rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,
            "->to_values.",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
            column_name,
            "))")
          ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="C*"
          ))
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
            iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, evaluate(",
            trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
              check_space)),", 1, ' ', 0,notrim(rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].
            suffix,"->to_values.",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop]
            .column_name,
            ")))")
          ELSE
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
            iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, rs_",
            dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
            tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
          ENDIF
          SET iur_del_ind = 1
         ENDIF
       ENDFOR
       FOR (iur_del_loop = 1 TO perm_col_cnt)
         IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].pk_ind=1)
          AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name=dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].root_entity_name)
          AND dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name
          AND dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].root_entity_attr)
          SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" and c.",dm2_ref_data_doc->
           tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," != 0 ")
         ENDIF
       ENDFOR
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = ") with nocounter go"
       IF (iur_del_ind=1
        AND iur_child_pk_cnt=1)
        CALL parse_statements(drdm_parser_cnt)
        IF (drdm_mini_loop_status="NOMV08")
         CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV08")
         COMMIT
         RETURN(1)
        ENDIF
       ENDIF
     ENDFOR
     SET iur_del_ind = 0
     SET iur_child_pk_cnt = 0
    ENDIF
    SET drdm_parser->statement[1].frag = concat("delete from ",dm2_ref_data_doc->tbl_qual[
     iur_temp_tbl_cnt].table_name," c where ")
    SET drdm_parser_cnt = 1
    FOR (iur_del_loop = 1 TO perm_col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].merge_delete_ind=1))
       IF (iur_del_ind=1)
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = " and "
       ENDIF
       IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="DQ8"))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, rs_",
         dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
         tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
       ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="VC"))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, evaluate(",
         trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
           check_space)),", 1, ' ', 0,rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,
         "->to_values.",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
         column_name,
         "))")
       ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="C*"))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, evaluate(",
         trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
           check_space)),", 1, ' ', 0,notrim(rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,
         "->to_values.",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
         column_name,
         ")))")
       ELSE
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, rs_",
         dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
         tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
       ENDIF
       SET iur_del_ind = 1
      ENDIF
    ENDFOR
    FOR (iur_del_loop = 1 TO perm_col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].pk_ind=1)
       AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name=dm2_ref_data_doc->tbl_qual[
      iur_temp_tbl_cnt].col_qual[iur_del_loop].root_entity_name)
       AND dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name
       AND dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].root_entity_attr)
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" and c.",dm2_ref_data_doc->
        tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," != 0 ")
      ENDIF
    ENDFOR
    SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
    SET drdm_parser->statement[drdm_parser_cnt].frag = "with nocounter go"
    CALL parse_statements(drdm_parser_cnt)
    IF (drdm_mini_loop_status="NOMV08")
     CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV08")
     COMMIT
     RETURN(1)
    ENDIF
   ENDIF
   SET iur_del_ind = 0
   IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].merge_delete_ind=1))
    IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].parent_flag=2))
     SET drdm_parser_cnt = 1
     FOR (iur_child_loop = 1 TO size(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].parent_qual,5))
       SET drdm_parser->statement[1].frag = concat("delete from ",dm2_ref_data_doc->tbl_qual[
        iur_temp_tbl_cnt].parent_qual[iur_child_loop].child_name," where ")
       IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].parent_qual[iur_child_loop].parent_tab_col
        != ""))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat(dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].parent_qual[iur_child_loop].parent_tab_col," = '",dm2_ref_data_doc->
         tbl_qual[iur_temp_tbl_cnt].table_name,"' and ")
       ENDIF
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(dm2_ref_data_doc->tbl_qual[
        iur_temp_tbl_cnt].parent_qual[iur_child_loop].parent_id_col," = ")
       FOR (iur_del_loop = 1 TO perm_col_cnt)
         IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].pk_ind=1))
          IF (iur_del_ind >= 1)
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = " and "
          ENDIF
          IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="DQ8"))
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",
            dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
          ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="VC"
          ))
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, evaluate(",trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].
              col_qual[iur_del_loop].check_space)),", 1, ' ', 0,rs_",
            dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
            tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,"))")
          ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="C*"
          ))
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, evaluate(",trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].
              col_qual[iur_del_loop].check_space)),", 1, ' ', 0,notrim(rs_",
            dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
            tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")))")
          ELSE
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",
            dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
          ENDIF
          SET iur_del_ind = (iur_del_ind+ 1)
         ENDIF
       ENDFOR
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = " with nocounter go"
       IF (iur_del_ind=1)
        CALL parse_statements(drdm_parser_cnt)
        IF (drdm_mini_loop_status="NOMV08")
         CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV08")
         COMMIT
         RETURN(1)
        ENDIF
       ENDIF
     ENDFOR
     SET iur_del_ind = 0
    ENDIF
    SET drdm_parser->statement[1].frag = concat("delete from ",dm2_ref_data_doc->tbl_qual[
     iur_temp_tbl_cnt].table_name," c where ")
    SET drdm_parser_cnt = 1
    FOR (iur_del_loop = 1 TO perm_col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].pk_ind=1))
       IF (iur_del_ind=1)
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = " and "
       ENDIF
       IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="DQ8"))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, rs_",
         dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
         tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
       ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="VC"))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, evaluate(",
         trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
           check_space)),", 1, ' ', 0,rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,
         "->to_values.",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
         column_name,
         "))")
       ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="C*"))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, evaluate(",
         trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
           check_space)),", 1, ' ', 0,notrim(rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,
         "->to_values.",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
         column_name,
         ")))")
       ELSE
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, rs_",
         dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
         tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
       ENDIF
       SET iur_del_ind = 1
      ENDIF
    ENDFOR
    FOR (iur_del_loop = 1 TO perm_col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].pk_ind=1)
       AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name=dm2_ref_data_doc->tbl_qual[
      iur_temp_tbl_cnt].col_qual[iur_del_loop].root_entity_name)
       AND dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name
       AND dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].root_entity_attr)
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" and c.",dm2_ref_data_doc->
        tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," != 0 ")
      ENDIF
    ENDFOR
    SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
    SET drdm_parser->statement[drdm_parser_cnt].frag = "with nocounter go"
    CALL parse_statements(drdm_parser_cnt)
    IF (drdm_mini_loop_status="NOMV08")
     CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV08")
     COMMIT
     RETURN(1)
    ENDIF
   ENDIF
   IF (nodelete_ind=1)
    RETURN(1)
   ENDIF
   SET p_tab_ind = 0
   SET first_where = 0
   SET no_update_ind = 0
   SET short_string = ""
   SET drdm_parser->statement[1].frag = concat("select into 'NL:' from ",value(dm2_ref_data_doc->
     tbl_qual[iur_temp_tbl_cnt].table_name)," dc where ")
   SET drdm_parser_cnt = 2
   IF ((((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].merge_delete_ind=0)) OR ((dm2_ref_data_doc->
   tbl_qual[iur_temp_tbl_cnt].lob_process_type="LOB_LOB"))) )
    SET pk_cnt = 0
    FOR (ins_upd_loop = 1 TO iur_perm_col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].pk_ind=1))
       SET pk_cnt = (pk_cnt+ 1)
       SET sbr_data_type = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].
       data_type
       SET drdm_col_name = value(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].
        column_name)
       SET drdm_from_con = concat(drdm_table_name,"->To_values.",drdm_col_name)
       IF (drdm_parser_cnt > 2)
        SET iur_tgt_pk_where = concat(iur_tgt_pk_where," and ")
        SET drdm_parser->statement[drdm_parser_cnt].frag = " and "
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       ENDIF
       IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].check_null=1)
        AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].nullable="Y"))
        IF (sbr_data_type IN ("DQ8", "I4", "F8", "I2"))
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = null")
        ELSE
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" (dc.",drdm_col_name,
          " = null or dc.",drdm_col_name," = ' ')")
        ENDIF
        SET iur_tgt_pk_where = concat(iur_tgt_pk_where,drdm_parser->statement[drdm_parser_cnt].frag)
       ELSEIF (sbr_data_type="DQ8")
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name,
         " = cnvtdatetime(",drdm_from_con,")")
        SET iur_tgt_pk_where = concat(iur_tgt_pk_where,drdm_parser->statement[drdm_parser_cnt].frag)
       ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].check_space=1))
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" (dc.",drdm_col_name,
         " = null or dc.",drdm_col_name," = ' ')")
        SET iur_tgt_pk_where = concat(iur_tgt_pk_where,drdm_parser->statement[drdm_parser_cnt].frag)
       ELSE
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = ",
         drdm_from_con)
        SET iur_tgt_pk_where = concat(iur_tgt_pk_where,drdm_parser->statement[drdm_parser_cnt].frag)
       ENDIF
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ELSE
       SET non_key_ind = 1
      ENDIF
    ENDFOR
    IF (pk_cnt=0)
     SET nodelete_ind = 1
     SET dm_err->emsg = "The table has no primary_key information, check to see if it is mergeable."
    ELSE
     SET drdm_parser->statement[drdm_parser_cnt].frag = " go"
     CALL parse_statements(drdm_parser_cnt)
    ENDIF
   ENDIF
   IF (curqual > 0
    AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].merge_delete_ind=0))
    IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].insert_only_ind=1))
     CALL merge_audit("FAILREASON",
      "This table is marked as insert only, so this row will not be updated.",3)
     RETURN(0)
    ELSE
     IF (new_seq_ind=1
      AND drdm_override_ind=0)
      SET no_update_ind = 1
      CALL merge_audit("FAILREASON",
       "A new sequence was created for the table, but the sequence value already exists in the target table",
       3)
      SET nodelete_ind = 1
      SET drdm_mini_loop_status = "NOMV99"
     ELSE
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name != "PERSON")
       AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name != "PERSON4859"))
       IF (non_key_ind=1)
        SET drdm_parser->statement[1].frag = concat("update into ",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].table_name,"  dc set ")
        SET drdm_parser_cnt = 2
        FOR (update_loop = 1 TO iur_perm_col_cnt)
          IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].db_data_type !=
          "*LOB"))
           IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].pk_ind=0))
            IF (drdm_parser_cnt > 2)
             SET drdm_parser->statement[drdm_parser_cnt].frag = ", "
             SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
            ENDIF
            SET drdm_col_name = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].
            column_name
            SET drdm_from_con = concat(drdm_table_name,"->to_values.",drdm_col_name)
            IF (drdm_col_name="ACTIVE_IND")
             IF (drdm_active_ind_merge=0)
              CALL parser(concat("set active_in = ",drdm_table_name,"->from_values.active_ind go"),1)
              IF (((active_in=0) OR ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[
              update_loop].exception_flg=8))) )
               IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].check_null=1)
                AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].nullable="Y")
               )
                SET drdm_parser->statement[drdm_parser_cnt].frag = " dc.ACTIVE_IND = null"
               ELSE
                SET drdm_parser->statement[drdm_parser_cnt].frag = " dc.ACTIVE_IND = active_in"
               ENDIF
              ELSE
               IF (((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_cnt - pk_cnt)=1))
                SET no_update_ind = 1
               ELSE
                IF (drdm_parser_cnt=2)
                 SET drdm_parser_cnt = (drdm_parser_cnt - 1)
                ELSE
                 SET drdm_parser_cnt = (drdm_parser_cnt - 2)
                ENDIF
               ENDIF
              ENDIF
             ELSE
              IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].check_null=1)
               AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].nullable="Y"))
               SET drdm_parser->statement[drdm_parser_cnt].frag = " dc.ACTIVE_IND = null"
              ELSE
               SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.ACTIVE_IND = ",
                drdm_from_con)
              ENDIF
             ENDIF
            ELSEIF (drdm_col_name="UPDT_TASK")
             SET drdm_parser->statement[drdm_parser_cnt].frag = " dc.UPDT_TASK = 4310001"
            ELSEIF (drdm_col_name="UPDT_DT_TM")
             SET drdm_parser->statement[drdm_parser_cnt].frag =
             " dc.UPDT_DT_TM = cnvtdatetime(curdate, curtime3)"
            ELSEIF (drdm_col_name="UPDT_CNT")
             SET drdm_parser->statement[drdm_parser_cnt].frag = "dc.UPDT_CNT = dc.UPDT_CNT + 1"
            ELSE
             IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].check_null=1)
              AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].nullable="Y"))
              SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name,
               " = null")
             ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].data_type=
             "DQ8"))
              SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name,
               " = cnvtdatetime(",drdm_from_con,")")
             ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].check_space=
             1))
              SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = ' '"
               )
             ELSE
              SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = ",
               drdm_from_con)
             ENDIF
            ENDIF
            SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           ENDIF
          ENDIF
        ENDFOR
        IF (no_update_ind=0)
         SET drdm_parser->statement[drdm_parser_cnt].frag = " where "
         SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
         SET drdm_parser->statement[drdm_parser_cnt].frag = iur_tgt_pk_where
         SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        ENDIF
        SET current_merges = (current_merges+ 1)
        SET child_merge_audit->num[current_merges].action = "UPDATE"
        SET child_merge_audit->num[current_merges].text = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt
        ].table_name
       ENDIF
       SET ins_ind = 0
      ELSE
       SET p_tab_ind = 1
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET ins_ind = 1
    SET drdm_parser->statement[1].frag = concat("insert into ",dm2_ref_data_doc->tbl_qual[
     iur_temp_tbl_cnt].table_name," dc set ")
    SET drdm_parser_cnt = 2
    FOR (insert_loop = 1 TO iur_perm_col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].db_data_type != "*LOB")
      )
       SET drdm_col_name = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].
       column_name
       SET drdm_from_con = concat(drdm_table_name,"->to_values.",drdm_col_name)
       IF (drdm_parser_cnt > 2)
        SET drdm_parser->statement[drdm_parser_cnt].frag = ", "
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       ENDIF
       IF (drdm_col_name="UPDT_TASK")
        SET drdm_parser->statement[drdm_parser_cnt].frag = " dc.UPDT_TASK = 4310001"
       ELSEIF (drdm_col_name="UPDT_DT_TM")
        SET drdm_parser->statement[drdm_parser_cnt].frag =
        " dc.UPDT_DT_TM = cnvtdatetime(curdate, curtime3)"
       ELSEIF (drdm_col_name="UPDT_CNT")
        SET drdm_parser->statement[drdm_parser_cnt].frag = "dc.UPDT_CNT = 0"
       ELSE
        IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].check_null=1)
         AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].nullable="Y"))
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = null ")
        ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].data_type="DQ8"))
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name,
          " = cnvtdatetime(",drdm_from_con,")")
        ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].check_space=1))
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = ' '")
        ELSE
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = ",
          drdm_from_con)
        ENDIF
       ENDIF
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ENDIF
    ENDFOR
    SET current_merges = (current_merges+ 1)
    SET child_merge_audit->num[current_merges].action = "INSERT"
    SET child_merge_audit->num[current_merges].text = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].
    table_name
   ENDIF
   SET drdm_parser->statement[drdm_parser_cnt].frag = " go"
   IF (p_tab_ind=0
    AND no_update_ind=0)
    IF (ins_ind=0
     AND non_key_ind=0)
     CALL echo("No update will be done on this table because there are no non-key columns")
    ELSE
     CALL parse_statements(drdm_parser_cnt)
     IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].lob_process_type="LOB_LOB"))
      SET drdm_parser->statement[1].frag = concat("update into ",dm2_ref_data_doc->tbl_qual[
       iur_temp_tbl_cnt].table_name," dc set ")
      SET drdm_parser_cnt = 2
      FOR (insert_loop = 1 TO iur_perm_col_cnt)
        IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].db_data_type="*LOB"))
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",dm2_ref_data_doc->tbl_qual[
          iur_temp_tbl_cnt].col_qual[insert_loop].column_name," = (select ")
         SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" ",dm2_rdds_get_tbl_alias(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix),".",dm2_ref_data_doc->tbl_qual[
          iur_temp_tbl_cnt].col_qual[insert_loop].column_name)
         SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        ENDIF
      ENDFOR
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" from ",dm2_get_rdds_tname(
        dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name)," ",dm2_rdds_get_tbl_alias(
        dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix)," where ")
      SET iur_tbl_alias = concat(" ",dm2_rdds_get_tbl_alias(dm2_ref_data_doc->tbl_qual[
        iur_temp_tbl_cnt].suffix))
      SET src_pk_where = " "
      SET pk_cnt = 0
      SET iur_perm_col_cnt = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_cnt
      FOR (ins_upd_loop = 1 TO iur_perm_col_cnt)
        IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].pk_ind=1))
         SET pk_cnt = (pk_cnt+ 1)
         SET sbr_data_type = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].
         data_type
         SET drdm_col_name = value(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop
          ].column_name)
         SET drdm_from_con = concat(drdm_table_name,"->from_values.",drdm_col_name)
         IF (pk_cnt > 1)
          SET iur_tgt_pk_where = concat(src_pk_where," and ")
         ENDIF
         IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].check_null=1)
          AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].nullable="Y"))
          IF (sbr_data_type IN ("DQ8", "I4", "F8", "I2"))
           SET src_pk_where = concat(src_pk_where,iur_tbl_alias,".",drdm_col_name," = null")
          ELSE
           SET src_pk_where = concat(src_pk_where," (",iur_tbl_alias,".",drdm_col_name,
            " = null or ",iur_tbl_alias,".",drdm_col_name," = ' ')")
          ENDIF
         ELSEIF (sbr_data_type="DQ8")
          SET src_pk_where = concat(src_pk_where,iur_tbl_alias,".",drdm_col_name," = cnvtdatetime(",
           drdm_from_con,")")
         ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].check_space=1))
          SET src_pk_where = concat(src_pk_where," (",iur_tbl_alias,".",drdm_col_name,
           iur_tbl_alias,".",drdm_col_name," = ' ')")
         ELSE
          SET src_pk_where = concat(src_pk_where,iur_tbl_alias,".",drdm_col_name," = ",
           drdm_from_con)
         ENDIF
        ENDIF
      ENDFOR
      IF (pk_cnt=0)
       SET nodelete_ind = 1
       SET dm_err->emsg =
       "The table has no primary_key information, check to see if it is mergeable."
       RETURN(1)
      ENDIF
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(src_pk_where,")")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" where ",iur_tgt_pk_where,
       " with nocounter go")
      CALL parse_statements(drdm_parser_cnt)
     ENDIF
    ENDIF
   ENDIF
   FREE SET first_where
   FREE SET p_tab_ind
   FREE SET active_in
   FREE SET drdm_table_name
   IF (nodelete_ind=1)
    IF ((dm_err->ecode=288))
     SET drdm_mini_loop_status = "NOMV02"
     CALL merge_audit("FAILREASON","The row recieved a constraint violation when merged into target",
      1)
     CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV02")
     COMMIT
    ELSEIF ((dm_err->ecode=284))
     IF (findstring("ORA-20500:",dm_err->emsg) > 0)
      SET drdm_mini_loop_status = "NOMV01"
      CALL merge_audit("FAILREASON","The row is related to a person that has been combined away",1)
      CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV01")
      COMMIT
     ENDIF
     IF (findstring("ORA-20100:",dm_err->emsg) > 0)
      SET drdm_mini_loop_status = "NOMV08"
      CALL merge_audit("FAILREASON","The row is trying to update the default row in target",1)
      CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV08")
      COMMIT
     ENDIF
    ENDIF
    SET dm2_ref_data_reply->error_msg = dm_err->emsg
    SET dm2_ref_data_reply->error_ind = 1
    RETURN(1)
   ELSE
    SET drdm_chg->log[drdm_log_loop].reprocess_ind = 0
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE parse_statements(drdm_parser_cnt)
   FOR (parse_loop = 1 TO drdm_parser_cnt)
     IF (parse_loop=drdm_parser_cnt)
      SET drdm_go_ind = 1
     ELSE
      SET drdm_go_ind = 0
     ENDIF
     IF ((drdm_parser->statement[parse_loop].frag=""))
      CALL echo("")
      CALL echo("")
      CALL echo("A DYNAMIC STATEMENT WAS IMPROPERLY LOADED")
      CALL echo("")
      CALL echo("")
     ENDIF
     CALL parser(drdm_parser->statement[parse_loop].frag,drdm_go_ind)
     SET drdm_parser->statement[parse_loop].frag = ""
     IF (check_error(dm_err->eproc)=1)
      IF (findstring("ORA-20100:",dm_err->emsg) > 0)
       SET drdm_mini_loop_status = "NOMV08"
       CALL merge_audit("FAILREASON",
        "The row is trying to update/insert/delete the default row in target",1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
      ELSE
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
       SET nodelete_ind = 1
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE dm_translate(sbr_tbl_name,sbr_col_name,sbr_from_val)
   DECLARE to_val = vc
   DECLARE index_var = i4
   DECLARE dt_temp_tbl_cnt = i4
   DECLARE dt_temp_col_cnt = i4
   SET to_val = "NOXLAT"
   SET dt_temp_tbl_cnt = locateval(index_var,1,perm_tbl_cnt,sbr_tbl_name,dm2_ref_data_doc->tbl_qual[
    index_var].table_name)
   SET dt_temp_col_cnt = locateval(index_var,1,perm_col_cnt,sbr_col_name,dm2_ref_data_doc->tbl_qual[
    dt_temp_tbl_cnt].col_qual[index_var].column_name)
   SET to_val = select_merge_translate(sbr_from_val,dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].
    col_qual[dt_temp_col_cnt].root_entity_name)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
   ENDIF
   IF (to_val="No Trans")
    SET to_val = report_missing(dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt]
     .root_entity_name,dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].
     root_entity_attr,cnvtreal(sbr_from_val))
   ENDIF
   RETURN(to_val)
 END ;Subroutine
 SUBROUTINE dm_trans2(sbr_tbl_name,sbr_col_name,sbr_from_val,sbr_src_ind)
   DECLARE to_val = vc
   DECLARE index_var = i4
   DECLARE dt_temp_tbl_cnt = i4
   DECLARE dt_temp_col_cnt = i4
   IF (sbr_src_ind=0)
    SET to_val = "NOXLAT"
    SET dt_temp_tbl_cnt = locateval(index_var,1,perm_tbl_cnt,sbr_tbl_name,dm2_ref_data_doc->tbl_qual[
     index_var].table_name)
    SET dt_temp_col_cnt = locateval(index_var,1,perm_col_cnt,sbr_col_name,dm2_ref_data_doc->tbl_qual[
     dt_temp_tbl_cnt].col_qual[index_var].column_name)
    IF ((dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].exception_flg=1))
     RETURN(sbr_from_val)
    ELSE
     IF ((dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].root_entity_name IN (
     "", " ")))
      SET to_val = "BADLOG"
     ELSE
      IF ((dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].root_entity_name=
      "PERSON")
       AND (dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].table_name != "PRSNL"))
       SET dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].root_entity_name =
       "PRSNL"
      ENDIF
      SET to_val = select_merge_translate(sbr_from_val,dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].
       col_qual[dt_temp_col_cnt].root_entity_name)
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
      ENDIF
      IF (to_val != "No Trans"
       AND findstring(".0",to_val)=0)
       SET to_val = concat(to_val,".0")
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET to_val = sbr_from_val
   ENDIF
   SET dt_root_tbl_cnt = locateval(index_var,1,perm_tbl_cnt,dm2_ref_data_doc->tbl_qual[
    dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].root_entity_name,dm2_ref_data_doc->tbl_qual[index_var]
    .table_name)
   IF ((dm2_ref_data_doc->tbl_qual[dt_root_tbl_cnt].mergeable_ind=0))
    SET to_val = "NOMV04"
   ENDIF
   IF (to_val="No Trans")
    SET to_val = report_missing(dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt]
     .root_entity_name,dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].
     root_entity_attr,cnvtreal(sbr_from_val))
   ENDIF
   RETURN(to_val)
 END ;Subroutine
 SUBROUTINE select_merge_translate(sbr_f_value,sbr_t_name)
   DECLARE sbr_return_val = vc
   DECLARE drdm_dmt_scr = vc
   DECLARE except_tab = vc
   DECLARE smt_loop = i4
   DECLARE smt_tbl_pos = i4
   DECLARE smt_seq_name = vc
   DECLARE smt_seq_num = f8
   DECLARE smt_cur_table = i4
   DECLARE smt_seq_loop = i4
   DECLARE smt_seq_val = i4
   DECLARE smt_xlat_env_tgt_id = f8
   SET smt_xlat_env_tgt_id = dm2_ref_data_doc->mock_target_id
   SET sbr_return_val = "No Trans"
   SET except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   SET smt_tbl_pos = locateval(smt_loop,1,dm2_ref_data_doc->tbl_cnt,sbr_t_name,dm2_ref_data_doc->
    tbl_qual[smt_loop].table_name)
   IF (smt_tbl_pos=0)
    SET smt_cur_table = temp_tbl_cnt
    SET smt_tbl_pos = fill_rs("TABLE",sbr_t_name)
    SET temp_tbl_cnt = smt_cur_table
   ENDIF
   IF (smt_tbl_pos=0)
    RETURN(sbr_return_val)
   ENDIF
   IF ((dm2_ref_data_doc->tbl_qual[smt_tbl_pos].skip_seqmatch_ind != 1))
    IF (sbr_t_name="REF_TEXT_RELTN")
     SET smt_seq_name = "REFERENCE_SEQ"
    ELSE
     FOR (smt_loop = 1 TO dm2_ref_data_doc->tbl_qual[smt_tbl_pos].col_cnt)
       IF ((dm2_ref_data_doc->tbl_qual[smt_tbl_pos].col_qual[smt_loop].pk_ind=1)
        AND (dm2_ref_data_doc->tbl_qual[smt_tbl_pos].col_qual[smt_loop].root_entity_name=sbr_t_name))
        SET smt_seq_name = dm2_ref_data_doc->tbl_qual[smt_tbl_pos].col_qual[smt_loop].sequence_name
       ENDIF
     ENDFOR
    ENDIF
    IF (smt_seq_name="")
     CALL disp_msg("No Valid sequence was found",dm_err->logfile,1)
     SET dm2_ref_data_reply->error_ind = 1
     SET dm2_ref_data_reply->error_msg = "No Valid sequence was found"
     SET dm_err->err_ind = 0
     CALL merge_audit("FAILREASON","No Valid sequence was found",3)
     RETURN(sbr_return_val)
    ENDIF
    SET smt_seq_val = locateval(smt_seq_loop,1,size(drdm_sequence->qual,5),smt_seq_name,drdm_sequence
     ->qual[smt_seq_loop].seq_name)
    IF (smt_seq_val=0)
     SELECT
      IF ((dm2_rdds_rec->mode="OS"))
       WHERE d.info_domain="MERGE00SEQMATCH"
        AND d.info_name=smt_seq_name
      ELSE
       WHERE d.info_domain=concat("MERGE",trim(cnvtstring(dm2_ref_data_doc->env_source_id)),trim(
         cnvtstring(smt_xlat_env_tgt_id)),"SEQMATCH")
        AND d.info_name=smt_seq_name
      ENDIF
      INTO "NL:"
      FROM dm_info d
      DETAIL
       smt_seq_num = d.info_number
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm2_ref_data_reply->error_ind = 1
      SET dm2_ref_data_reply->error_msg = dm_err->emsg
      SET dm_err->err_ind = 0
     ENDIF
     IF (((curqual=0) OR ((smt_seq_num=- (1)))) )
      SET smt_cur_table = temp_tbl_cnt
      EXECUTE dm2_find_sequence_match smt_seq_name, dm2_ref_data_doc->env_source_id
      SET temp_tbl_cnt = smt_cur_table
      IF ((dm_err->err_ind=1))
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm2_ref_data_reply->error_ind = 1
       SET dm2_ref_data_reply->error_msg = dm_err->emsg
       SET dm_err->err_ind = 1
       SET drdm_error_ind = 1
       RETURN(sbr_return_val)
      ENDIF
      SELECT
       IF ((dm2_rdds_rec->mode="OS"))
        WHERE d.info_domain="MERGE00SEQMATCH"
         AND d.info_name=smt_seq_name
       ELSE
        WHERE d.info_domain=concat("MERGE",trim(cnvtstring(dm2_ref_data_doc->env_source_id)),trim(
          cnvtstring(smt_xlat_env_tgt_id)),"SEQMATCH")
         AND d.info_name=smt_seq_name
       ENDIF
       INTO "NL:"
       FROM dm_info d
       DETAIL
        smt_seq_num = d.info_number
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm2_ref_data_reply->error_ind = 1
       SET dm2_ref_data_reply->error_msg = dm_err->emsg
      ENDIF
      IF (curqual=0)
       SET drdm_error_out_ind = 1
       SET dm2_ref_data_reply->error_ind = 1
       SET dm2_ref_data_reply->error_msg = "A sequence match could not be found in DM_INFO"
       CALL disp_msg("A sequence match could not be found in DM_INFO",dm_err->logfile,1)
       RETURN("No Trans")
      ENDIF
     ENDIF
     SET stat = alterlist(drdm_sequence->qual,(size(drdm_sequence->qual,5)+ 1))
     SET drdm_sequence->qual[size(drdm_sequence->qual,5)].seq_name = smt_seq_name
     SET drdm_sequence->qual[size(drdm_sequence->qual,5)].seq_val = smt_seq_num
    ELSE
     SET smt_seq_num = drdm_sequence->qual[smt_seq_val].seq_val
    ENDIF
   ELSE
    SET smt_seq_num = 0
   ENDIF
   IF (cnvtreal(sbr_f_value) <= smt_seq_num)
    RETURN(sbr_f_value)
   ELSE
    SELECT
     IF ( NOT (sbr_t_name IN ("PRSNL", "PERSON"))
      AND (select_merge_translate_rec->type != "TO"))
      WHERE dm.from_value=cnvtreal(sbr_f_value)
       AND dm.table_name=sbr_t_name
       AND (dm.env_source_id=dm2_ref_data_doc->env_source_id)
       AND dm.env_target_id=smt_xlat_env_tgt_id
     ELSEIF (sbr_t_name IN ("PRSNL", "PERSON")
      AND (select_merge_translate_rec->type != "TO"))
      WHERE dm.from_value=cnvtreal(sbr_f_value)
       AND dm.table_name IN ("PRSNL", "PERSON")
       AND (dm.env_source_id=dm2_ref_data_doc->env_source_id)
       AND dm.env_target_id=smt_xlat_env_tgt_id
     ELSEIF ( NOT (sbr_t_name IN ("PRSNL", "PERSON"))
      AND (select_merge_translate_rec->type="TO"))
      WHERE dm.to_value=cnvtreal(sbr_f_value)
       AND dm.table_name=sbr_t_name
       AND (dm.env_source_id=dm2_ref_data_doc->env_source_id)
       AND dm.env_target_id=smt_xlat_env_tgt_id
     ELSEIF (sbr_t_name IN ("PRSNL", "PERSON")
      AND (select_merge_translate_rec->type="TO"))
      WHERE dm.to_value=cnvtreal(sbr_f_value)
       AND dm.table_name IN ("PRSNL", "PERSON")
       AND (dm.env_source_id=dm2_ref_data_doc->env_source_id)
       AND dm.env_target_id=smt_xlat_env_tgt_id
     ELSE
     ENDIF
     INTO "NL:"
     FROM dm_merge_translate dm
     DETAIL
      IF ((select_merge_translate_rec->type="TO"))
       sbr_return_val = cnvtstring(dm.from_value)
      ELSE
       sbr_return_val = cnvtstring(dm.to_value)
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm2_ref_data_reply->error_ind = 1
     SET dm2_ref_data_reply->error_msg = dm_err->emsg
     SET dm_err->err_ind = 0
    ENDIF
    IF (sbr_return_val="No Trans"
     AND (global_mover_rec->loop_back_ind=1))
     SET source_table_name = dm2_get_rdds_tname("DM_MERGE_TRANSLATE")
     SELECT
      IF ( NOT (sbr_t_name IN ("PRSNL", "PERSON"))
       AND (select_merge_translate_rec->type != "TO"))
       WHERE dm.to_value=cnvtreal(sbr_f_value)
        AND dm.table_name=sbr_t_name
        AND dm.env_source_id=smt_xlat_env_tgt_id
        AND (dm.env_target_id=dm2_ref_data_doc->env_source_id)
      ELSEIF (sbr_t_name IN ("PRSNL", "PERSON")
       AND (select_merge_translate_rec->type != "TO"))
       WHERE dm.to_value=cnvtreal(sbr_f_value)
        AND dm.table_name IN ("PRSNL", "PERSON")
        AND dm.env_source_id=smt_xlat_env_tgt_id
        AND (dm.env_target_id=dm2_ref_data_doc->env_source_id)
      ELSEIF ( NOT (sbr_t_name IN ("PRSNL", "PERSON"))
       AND (select_merge_translate_rec->type="TO"))
       WHERE dm.from_value=cnvtreal(sbr_f_value)
        AND dm.table_name=sbr_t_name
        AND dm.env_source_id=smt_xlat_env_tgt_id
        AND (dm.env_target_id=dm2_ref_data_doc->env_source_id)
      ELSEIF (sbr_t_name IN ("PRSNL", "PERSON")
       AND (select_merge_translate_rec->type="TO"))
       WHERE dm.from_value=cnvtreal(sbr_f_value)
        AND dm.table_name IN ("PRSNL", "PERSON")
        AND dm.env_source_id=smt_xlat_env_tgt_id
        AND (dm.env_target_id=dm2_ref_data_doc->env_source_id)
      ELSE
      ENDIF
      INTO "NL:"
      FROM (parser(source_table_name) dm)
      DETAIL
       IF ((select_merge_translate_rec->type != "TO"))
        sbr_return_val = cnvtstring(dm.from_value)
       ELSE
        sbr_return_val = cnvtstring(dm.to_value)
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm2_ref_data_reply->error_ind = 1
      SET dm2_ref_data_reply->error_msg = dm_err->emsg
      SET dm_err->err_ind = 0
     ENDIF
    ENDIF
   ENDIF
   IF (sbr_return_val != "No Trans")
    CALL rdds_del_except(sbr_t_name,cnvtreal(sbr_f_value))
   ENDIF
   RETURN(sbr_return_val)
 END ;Subroutine
 SUBROUTINE del_chg_log(sbr_table_name,sbr_log_type,sbr_target_id)
   FREE RECORD dcl_rec_parse
   RECORD dcl_rec_parse(
     1 qual[*]
       2 parse_stmts = vc
   )
   SET stat = alterlist(dcl_rec_parse->qual,3)
   DECLARE sbr_tname_flex = vc
   DECLARE sbr_flex_pos = i4
   DECLARE sbr_look_ahead = vc WITH noconstant(build(global_mover_rec->refchg_buffer,"MIN"))
   SET drdm_any_translated = 1
   SET dm_err->eproc = "Updating DM_CHG_LOG Table drdm_chg->log[drdm_log_loop].log_id"
   SET update_cnt = 0
   SET sbr_tname_flex = dm2_get_rdds_tname("DM_CHG_LOG")
   SET dcl_rec_parse->qual[1].parse_stmts = concat("select into 'nl:' from ",sbr_tname_flex)
   SET dcl_rec_parse->qual[2].parse_stmts = " d where log_id = drdm_chg->log[drdm_log_loop].log_id"
   SET dcl_rec_parse->qual[3].parse_stmts = " detail update_cnt = d.updt_cnt with nocounter go"
   EXECUTE dm_rdds_parse_stmts  WITH replace("REQUEST","DCL_REC_PARSE")
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
    SET nodelete_ind = 1
   ENDIF
   SET stat = alterlist(dcl_rec_parse->qual,0)
   SET stat = alterlist(dcl_rec_parse->qual,8)
   IF ((((update_cnt=drdm_chg->log[drdm_log_loop].updt_cnt)) OR (sbr_log_type="REFCHG")) )
    IF ((drdm_chg->log[drdm_log_loop].par_location > 0))
     SET sbr_flex_pos = drdm_chg->log[drdm_log_loop].par_location
    ELSE
     SET sbr_flex_pos = drdm_log_loop
    ENDIF
    SET dcl_rec_parse->qual[1].parse_stmts = concat(" update into ",sbr_tname_flex,
     " d1, (dummyt d with seq = size(drdm_pair_info->qual)) ")
    SET dcl_rec_parse->qual[2].parse_stmts = " set d1.log_type = sbr_log_type, "
    SET dcl_rec_parse->qual[3].parse_stmts = " d1.rdbhandle = NULL, "
    IF (sbr_log_type="REFCHG")
     SET dcl_rec_parse->qual[4].parse_stmts = concat(
      " d1.updt_dt_tm = cnvtlookahead(sbr_look_ahead, cnvtdatetime(curdate,curtime3)),")
    ELSE
     SET dcl_rec_parse->qual[4].parse_stmts = "d1.updt_dt_tm = cnvtdatetime(curdate,curtime3),"
    ENDIF
    SET dcl_rec_parse->qual[5].parse_stmts = concat(" d1.updt_cnt = d1.updt_cnt + 1 plan d where",
     " drdm_pair_info->qual[d.seq].log_id > 0 ")
    SET dcl_rec_parse->qual[6].parse_stmts = concat(" join d1 where d1.log_id = ",
     " drdm_pair_info->qual[d.seq].log_id")
    IF (sbr_log_type="REFCHG")
     SET dcl_rec_parse->qual[7].parse_stmts = " and d1.log_type = 'PROCES'"
    ELSE
     SET dcl_rec_parse->qual[7].parse_stmts = concat(" and d1.updt_cnt = ",
      " drdm_pair_info->qual[d.seq].updt_cnt")
    ENDIF
    SET dcl_rec_parse->qual[8].parse_stmts = " with nocounter go"
    EXECUTE dm_rdds_parse_stmts  WITH replace("REQUEST","DCL_REC_PARSE")
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
    ENDIF
   ELSE
    SET nodelete_msg = concat("Could not process log_id ",trim(cnvtstring(drdm_chg->log[drdm_log_loop
       ].log_id)),
     " because it has been updated since the mover picked it up. It will be merged next pass.")
    CALL echo("")
    CALL echo("")
    CALL echo(nodelete_msg)
    CALL echo("")
    CALL echo("")
    CALL merge_audit("FAILREASON",nodelete_msg,1)
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE insert_merge_translate(sbr_from,sbr_to,sbr_table)
   DECLARE imt_seq_name = vc
   DECLARE imt_seq_num = f8
   DECLARE imt_seq_loop = i4
   DECLARE imt_seq_cnt = i4
   DECLARE imt_rs_cnt = i4
   DECLARE imt_return = i2
   DECLARE imt_except_tab = vc
   DECLARE imt_pk_pos = i4
   DECLARE imt_xlat_env_tgt_id = f8
   SET imt_xlat_env_tgt_id = dm2_ref_data_doc->mock_target_id
   SET imt_return = 0
   SET dm_err->eproc = "Inserting Translation"
   IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].skip_seqmatch_ind=0))
    FOR (imt_seq_loop = 1 TO size(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual,5))
      IF ((sbr_table=dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[imt_seq_loop].root_entity_name
      )
       AND (dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[imt_seq_loop].pk_ind=1))
       SET imt_pk_pos = imt_seq_loop
       SET imt_seq_name = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[imt_seq_loop].
       sequence_name
      ENDIF
    ENDFOR
    SET imt_seq_cnt = locateval(imt_seq_loop,1,size(drdm_sequence->qual,5),imt_seq_name,drdm_sequence
     ->qual[imt_seq_loop].seq_name)
    SET imt_seq_num = drdm_sequence->qual[imt_seq_cnt].seq_val
    IF (sbr_to < imt_seq_num)
     SET imt_return = 1
    ENDIF
   ENDIF
   SELECT INTO "NL:"
    FROM dm_merge_translate dmt
    WHERE dmt.to_value=sbr_to
     AND concat(dmt.table_name,"")=sbr_table
     AND (dmt.env_source_id=dm2_ref_data_doc->env_source_id)
     AND dmt.env_target_id=imt_xlat_env_tgt_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET no_insert_update = 1
    SET dm_err->err_ind = 0
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET imt_return = 1
   ENDIF
   IF (imt_return=0)
    INSERT  FROM dm_merge_translate dm
     SET dm.from_value = sbr_from, dm.to_value = sbr_to, dm.table_name = sbr_table,
      dm.env_source_id = dm2_ref_data_doc->env_source_id, dm.status_flg = drdm_chg->log[drdm_log_loop
      ].status_flg, dm.log_id = drdm_chg->log[drdm_log_loop].log_id,
      dm.updt_dt_tm = cnvtdatetime(curdate,curtime3), dm.env_target_id = imt_xlat_env_tgt_id
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET nodelete_ind = 1
     SET no_insert_update = 1
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
    ELSE
     IF (nvp_commit_ind=1
      AND (global_mover_rec->one_pass_ind=0))
      COMMIT
     ENDIF
    ENDIF
    CALL rdds_del_except(sbr_table,sbr_from)
   ELSE
    ROLLBACK
    SET imt_except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
    IF (sbr_table IN ("DCP_FORMS_REF", "DCP_SECTION_REF"))
     UPDATE  FROM (parser(imt_except_tab) d)
      SET d.log_type = "BADTRN"
      WHERE d.table_name=sbr_table
       AND d.from_value=sbr_from
       AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
      WITH nocounter
     ;end update
    ELSE
     UPDATE  FROM (parser(imt_except_tab) d)
      SET d.log_type = "BADTRN"
      WHERE d.table_name=sbr_table
       AND (d.column_name=dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[imt_pk_pos].column_name)
       AND d.from_value=sbr_from
       AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
      WITH nocounter
     ;end update
    ENDIF
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET nodelete_ind = 1
     SET no_insert_update = 1
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
    ENDIF
    IF (curqual=0)
     IF (sbr_table IN ("DCP_FORMS_REF", "DCP_SECTION_REF"))
      INSERT  FROM (parser(imt_except_tab) d)
       SET d.log_type = "BADTRN", d.table_name = sbr_table, d.from_value = sbr_from,
        d.target_env_id = dm2_ref_data_doc->env_target_id
       WITH nocounter
      ;end insert
     ELSE
      INSERT  FROM (parser(imt_except_tab) d)
       SET d.log_type = "BADTRN", d.table_name = sbr_table, d.column_name = dm2_ref_data_doc->
        tbl_qual[temp_tbl_cnt].col_qual[imt_pk_pos].column_name,
        d.from_value = sbr_from, d.target_env_id = dm2_ref_data_doc->env_target_id
       WITH nocounter
      ;end insert
     ENDIF
    ENDIF
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET nodelete_ind = 1
     SET no_insert_update = 1
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
    ELSE
     COMMIT
    ENDIF
    SET nodelete_ind = 1
    SET no_insert_update = 1
    SET fail_merges = (fail_merges+ 1)
    SET fail_merge_audit->num[fail_merges].action = "FAILREASON"
    SET fail_merge_audit->num[fail_merges].text = "Preventing a 2 into 1 translation"
    CALL merge_audit(fail_merge_audit->num[fail_merges].action,fail_merge_audit->num[fail_merges].
     text,1)
    IF (drdm_error_out_ind=1)
     ROLLBACK
    ENDIF
   ENDIF
   RETURN(imt_return)
 END ;Subroutine
 SUBROUTINE find_p_e_col(sbr_p_e_name,sbr_p_e_col)
   DECLARE p_e_name = vc
   DECLARE r_e_name = vc
   DECLARE p_e_col = vc
   DECLARE tbl_loop = i4
   DECLARE kickout = i4
   DECLARE p_e_tbl_pos = i4
   DECLARE p_e_col_pos = i4
   DECLARE p_e_where_str = vc
   DECLARE pk_pos = i4
   DECLARE temp_name = vc
   DECLARE mult_cnt = i4
   DECLARE pk_num = i4
   DECLARE good_pk = i4
   DECLARE pk_name = vc
   DECLARE id_ind = i2
   DECLARE info_alias = vc
   DECLARE i_domain = vc
   DECLARE i_name = vc
   DECLARE p_e_dummy_cnt = i4
   DECLARE temp_r_e_name = vc
   SET p_e_name = "INVALIDTABLE"
   SET r_e_name = sbr_p_e_name
   SET info_alias = ""
   SET id_ind = 0
   SET pk_num = 0
   SET pk_name = ""
   SET good_pk = 0
   WHILE (p_e_name != r_e_name)
     SET p_e_name = r_e_name
     SET r_e_name = "INVALIDTABLE"
     SET pk_pos = 0
     SET pk_pos = locateval(tbl_loop,1,dguc_reply->rs_tbl_cnt,p_e_name,dguc_reply->dtd_hold[tbl_loop]
      .tbl_name)
     IF (pk_pos=0)
      SELECT INTO "NL:"
       FROM dtable d
       WHERE d.table_name=p_e_name
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET i_domain = concat("RDDS_PE_ABBREV:",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name)
       SET i_name = concat(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[sbr_p_e_col].
        parent_entity_col,":",p_e_name)
       SELECT INTO "NL:"
        FROM dm_info d
        WHERE d.info_domain="RDDS_PE_ABBREVIATIONS"
         AND d.info_name=p_e_name
        DETAIL
         info_alias = d.info_char
        WITH nocounter
       ;end select
       SELECT INTO "NL:"
        FROM dm_info d
        WHERE d.info_domain=i_domain
         AND d.info_name=i_name
        DETAIL
         info_alias = d.info_char
        WITH nocounter
       ;end select
       IF (info_alias="")
        SET p_e_name = "INVALIDTABLE"
        SET r_e_name = p_e_name
        CALL echo("Parent_entity_col could not be found")
       ELSE
        SET p_e_name = info_alias
        SET pk_pos = locateval(tbl_loop,1,dguc_reply->rs_tbl_cnt,p_e_name,dguc_reply->dtd_hold[
         tbl_loop].tbl_name)
        IF (pk_pos=0)
         SET p_e_name = "INVALIDTABLE"
         SET r_e_name = p_e_name
         CALL echo("Parent_entity_col could not be found")
        ENDIF
       ENDIF
      ELSE
       CALL echo(concat("The following table is activity: ",p_e_name))
       SET p_e_name = "INVALIDTABLE"
       SET r_e_name = p_e_name
      ENDIF
     ENDIF
     IF (pk_pos != 0)
      IF ((dguc_reply->dtd_hold[tbl_loop].pk_cnt > 1))
       FOR (mult_cnt = 1 TO dguc_reply->dtd_hold[tbl_loop].pk_cnt)
         IF ((((dguc_reply->dtd_hold[tbl_loop].pk_hold[mult_cnt].pk_name="*ID")) OR ((((dguc_reply->
         dtd_hold[tbl_loop].pk_hold[mult_cnt].pk_name="*CD")) OR ((dguc_reply->dtd_hold[tbl_loop].
         pk_hold[mult_cnt].pk_name="CODE_VALUE"))) )) )
          IF ((dguc_reply->dtd_hold[tbl_loop].pk_hold[mult_cnt].pk_name="*ID"))
           SET id_ind = 1
          ENDIF
          SET pk_num = (pk_num+ 1)
          SET good_pk = mult_cnt
         ENDIF
       ENDFOR
       IF (pk_num > 1)
        IF (id_ind=1)
         CALL echo("This Parent_Entity Table has more than a single Primary Key")
         SET p_e_name = "INVALIDTABLE"
         SET r_e_name = p_e_name
        ELSE
         SET pk_name = dguc_reply->dtd_hold[tbl_loop].pk_hold[good_pk].pk_name
        ENDIF
       ELSE
        SET pk_name = dguc_reply->dtd_hold[tbl_loop].pk_hold[good_pk].pk_name
       ENDIF
      ELSE
       SET pk_name = dguc_reply->dtd_hold[tbl_loop].pk_hold[1].pk_name
      ENDIF
      IF (p_e_name != "INVALIDTABLE")
       SET p_e_col = pk_name
       SET p_e_tbl_pos = 0
       SET p_e_tbl_pos = locateval(tbl_loop,1,dm2_ref_data_doc->tbl_cnt,p_e_name,dm2_ref_data_doc->
        tbl_qual[tbl_loop].table_name)
       IF (p_e_tbl_pos=0)
        SET p_e_dummy_cnt = temp_tbl_cnt
        SET p_e_tbl_pos = fill_rs("TABLE",p_e_name)
        SET temp_tbl_cnt = p_e_dummy_cnt
        IF (p_e_tbl_pos=0)
         CALL echo("Information not found for table level meta-data")
         SET p_e_name = "INVALIDTABLE"
         SET r_e_name = p_e_name
        ELSE
         SET temp_r_e_name = r_e_name
         FOR (p_e_dummy_cnt = 1 TO dm2_ref_data_doc->tbl_qual[p_e_tbl_pos].col_cnt)
           IF ((dm2_ref_data_doc->tbl_qual[p_e_tbl_pos].col_qual[p_e_dummy_cnt].column_name=p_e_col))
            SET r_e_name = dm2_ref_data_doc->tbl_qual[p_e_tbl_pos].col_qual[p_e_dummy_cnt].
            root_entity_name
           ENDIF
         ENDFOR
         IF (temp_r_e_name=r_e_name)
          CALL echo("Information not found for table level meta-data")
          SET p_e_name = "INVALIDTABLE"
          SET r_e_name = p_e_name
         ENDIF
        ENDIF
       ENDIF
       IF (p_e_tbl_pos != 0)
        SET p_e_col_pos = 0
        SET p_e_col_pos = locateval(tbl_loop,1,dm2_ref_data_doc->tbl_qual[p_e_tbl_pos].col_cnt,
         p_e_col,dm2_ref_data_doc->tbl_qual[p_e_tbl_pos].col_qual[tbl_loop].column_name)
        IF (p_e_col_pos=0)
         CALL echo("Information not found in dm_columns_doc for column")
         SET p_e_name = "INVALIDTABLE"
         SET r_e_name = p_e_name
        ELSE
         SET r_e_name = dm2_ref_data_doc->tbl_qual[p_e_tbl_pos].col_qual[p_e_col_pos].
         root_entity_name
        ENDIF
       ENDIF
       SET kickout = (kickout+ 1)
       IF (kickout=5)
        CALL echo("Searched through 5 Parent_entity_columns")
        SET p_e_name = "INVALIDTABLE"
        SET r_e_name = p_e_name
       ENDIF
      ENDIF
     ENDIF
   ENDWHILE
   IF (p_e_name="INVALIDTABLE")
    ROLLBACK
    SET drdm_mini_loop_status = "NOMV99"
    CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name,"NOMV99")
    COMMIT
   ENDIF
   RETURN(p_e_name)
 END ;Subroutine
 SUBROUTINE merge_audit(action,text,audit_type)
   DECLARE aud_seq = i4
   DECLARE ma_log_id = f8
   DECLARE ma_next_seq = f8
   DECLARE ma_del_ind = i2
   DECLARE ma_table_name = vc
   IF (drdm_log_level=1
    AND  NOT (action IN ("INSERT", "UPDATE", "FAILREASON", "BATCH END")))
    RETURN(null)
   ELSE
    SET ma_del_ind = 0
    SET ma_log_id = drdm_chg->log[drdm_log_loop].log_id
    IF (temp_tbl_cnt=0)
     SET ma_table_name = "NONE"
    ELSE
     SET ma_table_name = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name
    ENDIF
    IF ((((global_mover_rec->one_pass_ind=1)
     AND audit_type=1) OR ((global_mover_rec->one_pass_ind=0)
     AND audit_type < 3)) )
     ROLLBACK
    ENDIF
    SELECT INTO "NL:"
     y = seq(dm_merge_audit_seq,nextval)
     FROM dual
     DETAIL
      ma_next_seq = y
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
     SET drdm_error_out_ind = 1
    ELSE
     UPDATE  FROM dm_chg_log_audit dm
      SET dm.audit_dt_tm = cnvtdatetime(curdate,curtime3), dm.log_id = ma_log_id, dm.action = action,
       dm.text = text, dm.table_name = ma_table_name, dm.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE dm.dm_chg_log_audit_id=ma_next_seq
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm_err->err_ind = 0
      SET drdm_error_out_ind = 1
     ENDIF
     IF (curqual=0)
      INSERT  FROM dm_chg_log_audit dm
       SET dm.audit_dt_tm = cnvtdatetime(curdate,curtime3), dm.log_id = ma_log_id, dm.action = action,
        dm.text = text, dm.table_name = ma_table_name, dm.dm_chg_log_audit_id = ma_next_seq,
        dm.updt_dt_tm = cnvtdatetime(curdate,curtime3)
       WITH nocounter
      ;end insert
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
       SET drdm_error_out_ind = 1
      ENDIF
     ENDIF
    ENDIF
    IF ((((global_mover_rec->one_pass_ind=1)
     AND audit_type=1) OR ((global_mover_rec->one_pass_ind=0)
     AND audit_type < 3)) )
     IF (drdm_error_out_ind=0)
      COMMIT
     ENDIF
    ENDIF
    RETURN(1)
   ENDIF
   FREE SET aud_seq
   FREE SET ma_log_id
 END ;Subroutine
 SUBROUTINE report_missing(sbr_table_name,sbr_column_name,sbr_value)
   DECLARE except_tab = vc
   DECLARE except_log_type = vc
   DECLARE missing_cnt = i4
   DECLARE source_tab_name = vc
   DECLARE insert_log_type = vc
   SET except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   SET source_tab_name = dm2_get_rdds_tname(sbr_table_name)
   SET except_log_type = "NOXLAT"
   IF (sbr_table_name IN ("DCP_FORMS_REF", "DCP_SECTION_REF"))
    SET sbr_column_name = ""
   ENDIF
   SELECT
    IF (sbr_table_name IN ("DCP_FORMS_REF", "DCP_SECTION_REF"))
     WHERE (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.table_name=sbr_table_name
      AND d.from_value=sbr_value
    ELSE
     WHERE (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.table_name=sbr_table_name
      AND d.column_name=sbr_column_name
      AND d.from_value=sbr_value
    ENDIF
    INTO "NL:"
    FROM (parser(except_tab) d)
    DETAIL
     except_log_type = d.log_type
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET no_insert_update = 1
    SET drdm_error_out_ind = 1
    SET dm_err->err_ind = 0
   ELSE
    IF (curqual=0)
     CALL parser(concat("select into 'NL:' from ",source_tab_name," r "),0)
     IF (sbr_table_name="DCP_FORMS_REF")
      CALL parser(" where r.dcp_forms_ref_id = sbr_value or r.dcp_form_instance_id = sbr_value ",0)
     ELSEIF (sbr_table_name="DCP_SECTION_REF")
      CALL parser(" where r.dcp_section_ref_id = sbr_value or r.dcp_section_instance_id = sbr_value ",
       0)
     ELSE
      CALL parser(concat(" where r.",sbr_column_name," = sbr_value"),0)
     ENDIF
     CALL parser(" with nocounter go",1)
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET nodelete_ind = 1
      SET no_insert_update = 1
      SET drdm_error_out_ind = 1
      SET dm_err->err_ind = 0
     ELSE
      IF (curqual=0)
       SET except_log_type = "ORPHAN"
       INSERT  FROM (parser(except_tab) d)
        SET d.log_type = "ORPHAN", d.table_name = sbr_table_name, d.column_name = sbr_column_name,
         d.from_value = sbr_value, d.target_env_id = dm2_ref_data_doc->env_target_id
        WITH nocounter
       ;end insert
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        SET nodelete_ind = 1
        SET no_insert_update = 1
        SET drdm_error_out_ind = 1
        SET dm_err->err_ind = 0
       ENDIF
      ENDIF
     ENDIF
     SET missing_cnt = add_rs_values(sbr_table_name,sbr_column_name,sbr_value)
     IF (missing_cnt > 0)
      IF (except_log_type="ORPHAN")
       SET missing_xlats->qual[missing_cnt].orphan_ind = 1
       SET missing_xlats->qual[missing_cnt].processed_ind = 1
      ELSE
       SET missing_xlats->qual[missing_cnt].orphan_ind = 0
       SET missing_xlats->qual[missing_cnt].processed_ind = 0
      ENDIF
     ENDIF
     RETURN(except_log_type)
    ELSE
     IF (except_log_type IN ("ORPHAN", "OLDVER", "NOMV*"))
      RETURN(except_log_type)
     ELSE
      CALL parser(concat("select into 'NL:' from ",source_tab_name," r "),0)
      IF (sbr_table_name="DCP_FORMS_REF")
       CALL parser(" where r.dcp_forms_ref_id = sbr_value or r.dcp_form_instance_id = sbr_value ",0)
      ELSEIF (sbr_table_name="DCP_SECTION_REF")
       CALL parser(
        " where r.dcp_section_ref_id = sbr_value or r.dcp_section_instance_id = sbr_value ",0)
      ELSE
       CALL parser(concat(" where r.",sbr_column_name," = sbr_value"),0)
      ENDIF
      CALL parser(" with nocounter go",1)
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET nodelete_ind = 1
       SET no_insert_update = 1
       SET drdm_error_out_ind = 1
       SET dm_err->err_ind = 0
      ELSE
       IF (curqual=0)
        UPDATE  FROM (parser(except_tab) d)
         SET d.log_type = "ORPHAN"
         WHERE d.table_name=sbr_table_name
          AND d.from_value=sbr_value
          AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
         WITH nocounter
        ;end update
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         SET nodelete_ind = 1
         SET no_insert_update = 1
         SET drdm_error_out_ind = 1
         SET dm_err->err_ind = 0
        ENDIF
        RETURN("ORPHAN")
       ELSE
        SET missing_cnt = add_rs_values(sbr_table_name,sbr_column_name,sbr_value)
        IF (missing_cnt > 0)
         SET missing_xlats->qual[missing_cnt].processed_ind = 0
         SET missing_xlats->qual[missing_cnt].orphan_ind = 0
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   RETURN(except_log_type)
 END ;Subroutine
 SUBROUTINE version_exception(sbr_table_name,sbr_column_name,sbr_value)
   DECLARE except_tab = vc
   DECLARE except_log_type = vc
   IF ((global_mover_rec->one_pass_ind=0))
    ROLLBACK
   ENDIF
   SET except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   IF (sbr_table_name IN ("DCP_FORMS_REF", "DCP_SECTION_REF"))
    SET sbr_column_name = ""
   ENDIF
   SELECT
    IF (sbr_table_name IN ("DCP_FORMS_REF", "DCP_SECTION_REF"))
     WHERE (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.table_name=sbr_table_name
      AND d.from_value=sbr_value
    ELSE
     WHERE (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.table_name=sbr_table_name
      AND d.column_name=sbr_column_name
      AND d.from_value=sbr_value
    ENDIF
    INTO "NL:"
    FROM (parser(except_tab) d)
    DETAIL
     except_log_type = d.log_type
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET no_insert_update = 1
    SET drdm_error_out_ind = 1
    SET dm_err->err_ind = 0
   ELSE
    IF (curqual=0)
     INSERT  FROM (parser(except_tab) d)
      SET d.log_type = "OLDVER", d.table_name = sbr_table_name, d.column_name = sbr_column_name,
       d.from_value = sbr_value, d.target_env_id = dm2_ref_data_doc->env_target_id
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET nodelete_ind = 1
      SET no_insert_update = 1
      SET drdm_error_out_ind = 1
      SET dm_err->err_ind = 0
     ELSE
      IF ((global_mover_rec->one_pass_ind=0))
       COMMIT
      ENDIF
     ENDIF
    ELSEIF (except_log_type != "OLDVER")
     UPDATE  FROM (parser(except_tab) d)
      SET d.log_type = "OLDVER"
      WHERE d.table_name=sbr_table_name
       AND d.column_name=sbr_column_name
       AND d.from_value=sbr_value
       AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET nodelete_ind = 1
      SET no_insert_update = 1
      SET drdm_error_out_ind = 1
      SET dm_err->err_ind = 0
     ELSE
      IF ((global_mover_rec->one_pass_ind=0))
       COMMIT
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE rdds_del_except(sbr_table_name,sbr_value)
   DECLARE except_tab = vc
   SET except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   DELETE  FROM (parser(except_tab) d)
    WHERE (d.target_env_id=dm2_ref_data_doc->env_target_id)
     AND d.table_name=sbr_table_name
     AND d.from_value=sbr_value
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET no_insert_update = 1
    SET drdm_error_out_ind = 1
    SET dm_err->err_ind = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_get_rdds_tname(sbr_tname)
   DECLARE return_tname = vc
   IF ((dm2_rdds_rec->mode="OS"))
    SET return_tname = concat(trim(substring(1,28,sbr_tname)),"$F")
   ELSEIF ((dm2_rdds_rec->main_process="EXTRACTOR")
    AND (dm2_rdds_rec->mode="DATABASE"))
    SET return_tname = sbr_tname
   ELSEIF ((dm2_rdds_rec->main_process="MOVER")
    AND (dm2_rdds_rec->mode="DATABASE"))
    SET return_tname = concat(dm2_ref_data_doc->pre_link_name,sbr_tname,dm2_ref_data_doc->
     post_link_name)
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "The main_process and/or mode were invalid"
   ENDIF
   RETURN(return_tname)
 END ;Subroutine
 SUBROUTINE orphan_child_tab(sbr_table_name,sbr_log_type)
   DECLARE oct_tab_cnt = i4
   DECLARE oct_tab_loop = i4
   DECLARE oct_col_cnt = i4
   DECLARE oct_pk_value = f8
   DECLARE oct_excptn_tab = vc
   DECLARE oct_col_name = vc
   IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name != sbr_table_name))
    SET oct_tab_cnt = locateval(oct_tab_loop,1,size(dm2_ref_data_doc->tbl_qual,5),sbr_table_name,
     dm2_ref_data_doc->tbl_qual[oct_tab_loop].table_name)
    IF (oct_tab_cnt=0)
     SET dm_err->err_msg = "The table name could not be found in the meta-data record structure"
     SET nodelete_ind = 1
    ENDIF
   ELSE
    SET oct_tab_cnt = temp_tbl_cnt
   ENDIF
   SET oct_col_cnt = 0
   FOR (oct_tab_loop = 1 TO size(dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual,5))
     IF ((dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual[oct_tab_loop].pk_ind=1)
      AND (dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual[oct_tab_loop].root_entity_name=
     sbr_table_name))
      SET oct_col_cnt = oct_tab_loop
     ENDIF
   ENDFOR
   IF (oct_col_cnt=0)
    RETURN(0)
   ENDIF
   CALL parser(concat("set oct_pk_value = RS_",dm2_ref_data_doc->tbl_qual[oct_tab_cnt].suffix,
     "->from_values.",dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual[oct_col_cnt].column_name,
     " go "),1)
   SET oct_excptn_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   IF (sbr_table_name IN ("DCP_SECTION_REF", "DCP_FORMS_REF"))
    SELECT INTO "NL:"
     FROM (parser(oct_excptn_tab) d)
     WHERE d.table_name=sbr_table_name
      AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.from_value=oct_pk_value
     DETAIL
      oct_col_name = d.column_name
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "NL:"
     FROM (parser(oct_excptn_tab) d)
     WHERE d.table_name=sbr_table_name
      AND (d.column_name=dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual[oct_col_cnt].column_name)
      AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.from_value=oct_pk_value
     WITH nocounter
    ;end select
    SET oct_col_name = dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual[oct_col_cnt].column_name
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET drdm_error_out_ind = 1
    SET dm_err->err_ind = 0
   ENDIF
   IF (curqual=0)
    INSERT  FROM (parser(oct_excptn_tab) d)
     SET d.table_name = sbr_table_name, d.column_name = dm2_ref_data_doc->tbl_qual[oct_tab_cnt].
      col_qual[oct_col_cnt].column_name, d.target_env_id = dm2_ref_data_doc->env_target_id,
      d.from_value = oct_pk_value, d.log_type = sbr_log_type
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET nodelete_ind = 1
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
    ENDIF
   ELSE
    UPDATE  FROM (parser(oct_excptn_tab) d)
     SET d.log_type = sbr_log_type
     WHERE d.table_name=sbr_table_name
      AND d.column_name=oct_col_name
      AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.from_value=oct_pk_value
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET nodelete_ind = 1
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_rdds_get_tbl_alias(sbr_tbl_suffix)
   DECLARE sbr_rgta_rtn = vc
   SET sbr_rgta_rtn = build("t",sbr_tbl_suffix)
   RETURN(sbr_rgta_rtn)
 END ;Subroutine
 SUBROUTINE insert_noxlat(sbr_table_name,sbr_column_name,sbr_value,sbr_orphan_ind)
   DECLARE inx_except_tab = vc
   DECLARE inx_log_type = vc
   DECLARE inx_col_name = vc
   SET inx_except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   IF (sbr_table_name IN ("DCP_SECTION_REF", "DCP_FORMS_REF"))
    SELECT INTO "NL:"
     FROM (parser(inx_except_tab) d)
     WHERE d.table_name=sbr_table_name
      AND d.from_value=sbr_value
      AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
     DETAIL
      inx_col_name = d.column_name
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "NL:"
     FROM (parser(inx_except_tab) d)
     WHERE d.table_name=sbr_table_name
      AND d.column_name=sbr_column_name
      AND d.from_value=sbr_value
      AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
     WITH nocounter
    ;end select
    SET inx_col_name = sbr_column_name
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET no_insert_update = 1
    RETURN(1)
   ENDIF
   IF (curqual=0)
    IF (sbr_orphan_ind=1)
     SET inx_log_type = "ORPHAN"
    ELSE
     SET inx_log_type = "NOXLAT"
    ENDIF
    INSERT  FROM (parser(inx_except_tab) d)
     SET d.log_type = inx_log_type, d.table_name = sbr_table_name, d.column_name = sbr_column_name,
      d.from_value = sbr_value, d.target_env_id = dm2_ref_data_doc->env_target_id
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET nodelete_ind = 1
     SET no_insert_update = 1
     SET drdm_error_out_ind = 1
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE add_rs_values(sbr_table_name,sbr_column_name,sbr_value)
   DECLARE arv_loop = i4
   DECLARE arv_cnt = i4
   DECLARE arv_found = i2
   SET arv_cnt = size(missing_xlats->qual,5)
   SET arv_found = 0
   FOR (arv_loop = 1 TO arv_cnt)
     IF ((missing_xlats->qual[arv_loop].table_name=sbr_table_name)
      AND (missing_xlats->qual[arv_loop].column_name=sbr_column_name)
      AND (missing_xlats->qual[arv_loop].missing_value=sbr_value))
      SET arv_found = 1
     ENDIF
   ENDFOR
   IF (arv_found=0)
    SET arv_cnt = (arv_cnt+ 1)
    SET stat = alterlist(missing_xlats->qual,arv_cnt)
    SET missing_xlats->qual[arv_cnt].table_name = sbr_table_name
    SET missing_xlats->qual[arv_cnt].column_name = sbr_column_name
    SET missing_xlats->qual[arv_cnt].missing_value = sbr_value
    RETURN(arv_cnt)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm_trans3(sbr_tbl_name,sbr_col_name,sbr_from_val,sbr_src_ind,sbr_pe_tbl_name)
   DECLARE to_val = vc
   DECLARE index_var = i4
   DECLARE dt3_temp_tbl_cnt = i4
   DECLARE dt3_temp_col_cnt = i4
   DECLARE dt3_from_con = vc
   DECLARE dt3_domain = vc
   DECLARE dt3_name = vc
   DECLARE dt3_find = i4
   DECLARE dt3_pk_column = vc
   DECLARE dt3_pk_tab_name = vc
   DECLARE dt3_root_tbl_cnt = i4
   IF (sbr_from_val=0)
    RETURN("0")
   ENDIF
   IF (sbr_src_ind=0)
    SET to_val = "NOXLAT"
    SET dt3_temp_tbl_cnt = locateval(index_var,1,perm_tbl_cnt,sbr_tbl_name,dm2_ref_data_doc->
     tbl_qual[index_var].table_name)
    SET dt3_temp_col_cnt = locateval(index_var,1,perm_col_cnt,sbr_col_name,dm2_ref_data_doc->
     tbl_qual[dt3_temp_tbl_cnt].col_qual[index_var].column_name)
    IF ((dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].col_qual[dt3_temp_col_cnt].exception_flg=1))
     RETURN(cnvtstring(sbr_from_val))
    ELSE
     IF ((dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].col_qual[dt3_temp_col_cnt].root_entity_name
      IN ("", " ")))
      IF (sbr_pe_tbl_name != ""
       AND sbr_pe_tbl_name != " ")
       SET dt3_pk_tab_name = find_p_e_col(sbr_pe_tbl_name,dt3_temp_col_cnt)
      ELSE
       SET dt3_pk_tab_name = "INVALIDTABLE"
       SET dt3_domain = concat("RDDS_PE_ABBREV:",sbr_tbl_name)
       SET dt3_name = concat(sbr_col_name,":",dt3_pk_tab_name)
       SELECT INTO "NL:"
        FROM dm_info d
        WHERE d.info_domain=dt3_domain
         AND d.info_name=dt3_name
        DETAIL
         dt3_pk_tab_name = d.info_char
        WITH nocounter
       ;end select
      ENDIF
      IF (dt3_pk_tab_name != "")
       IF (dt3_pk_tab_name != "INVALIDTABLE")
        IF (dt3_pk_tab_name="PERSON")
         SET dt3_pk_tab_name = "PRSNL"
        ENDIF
        SET to_val = select_merge_translate(cnvtstring(sbr_from_val),dt3_pk_tab_name)
       ENDIF
      ENDIF
      IF (to_val="No Trans")
       SET dt3_root_tbl_cnt = locateval(index_var,1,perm_tbl_cnt,dt3_pk_tab_name,dm2_ref_data_doc->
        tbl_qual[index_var].table_name)
       IF ((dm2_ref_data_doc->tbl_qual[dt3_root_tbl_cnt].mergeable_ind=0))
        SET to_val = "NOMV04"
       ELSE
        SET dt3_find = locateval(dt3_find,1,size(dm2_ref_data_doc->tbl_qual,5),dt3_pk_tab_name,
         dm2_ref_data_doc->tbl_qual[dt3_find].table_name)
        FOR (dt3_i = 1 TO size(dm2_ref_data_doc->tbl_qual[dt3_find].col_qual,5))
          IF ((dm2_ref_data_doc->tbl_qual[dt3_find].col_qual[dt3_i].pk_ind=1)
           AND (dm2_ref_data_doc->tbl_qual[dt3_find].col_qual[dt3_i].column_name=dm2_ref_data_doc->
          tbl_qual[dt3_find].col_qual[dt3_i].root_entity_attr)
           AND (dm2_ref_data_doc->tbl_qual[dt3_find].col_qual[dt3_i].root_entity_name=
          dm2_ref_data_doc->tbl_qual[dt3_find].table_name))
           SET dt3_pk_column = dm2_ref_data_doc->tbl_qual[dt3_find].col_qual[dt3_i].column_name
          ENDIF
        ENDFOR
        SET to_val = report_missing(dt3_pk_tab_name,dt3_pk_column,sbr_from_val)
       ENDIF
      ELSE
       IF (findstring(".0",to_val)=0)
        SET to_val = concat(to_val,".0")
       ENDIF
      ENDIF
     ELSE
      IF ((dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].col_qual[dt3_temp_col_cnt].root_entity_name=
      "PERSON")
       AND (dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].table_name != "PRSNL"))
       SET dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].col_qual[dt3_temp_col_cnt].root_entity_name
        = "PRSNL"
      ENDIF
      SET to_val = select_merge_translate(cnvtstring(sbr_from_val),dm2_ref_data_doc->tbl_qual[
       dt3_temp_tbl_cnt].col_qual[dt3_temp_col_cnt].root_entity_name)
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
      ENDIF
      IF (to_val="No Trans")
       SET dt3_root_tbl_cnt = locateval(index_var,1,perm_tbl_cnt,dm2_ref_data_doc->tbl_qual[
        dt3_temp_tbl_cnt].col_qual[dt3_temp_col_cnt].root_entity_name,dm2_ref_data_doc->tbl_qual[
        index_var].table_name)
       IF ((dm2_ref_data_doc->tbl_qual[dt3_root_tbl_cnt].mergeable_ind=0))
        SET to_val = "NOMV04"
       ELSE
        SET to_val = report_missing(dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].col_qual[
         dt3_temp_col_cnt].root_entity_name,dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].col_qual[
         dt3_temp_col_cnt].root_entity_attr,sbr_from_val)
       ENDIF
      ELSE
       IF (findstring(".0",to_val)=0)
        SET to_val = concat(to_val,".0")
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET to_val = cnvtstring(sbr_from_val)
   ENDIF
   RETURN(to_val)
 END ;Subroutine
 SUBROUTINE trigger_proc_call(tpc_table_name,tpc_pk_where,tpc_context,tpc_col_name,tpc_value)
   DECLARE tpc_pk_where_vc = vc
   DECLARE tpc_pktbl_cnt = i4
   DECLARE tpc_tbl_loop = i4
   DECLARE tpc_error_ind = i2
   DECLARE tpc_col_loop = i4
   DECLARE tpc_col_pos = i4
   DECLARE tpc_suffix = vc
   DECLARE tpc_pk_proc_name = vc
   DECLARE tpc_proc_name = vc
   DECLARE tpc_f8_var = f8
   DECLARE tpc_i4_var = i4
   DECLARE tpc_vc_var = vc
   DECLARE tpc_row_cnt = i4
   DECLARE tpc_row_loop = i4
   DECLARE tpc_src_tab_name = vc
   DECLARE tpc_main_proc = vc
   DECLARE tpc_uo_tname = vc
   DECLARE tpc_pkw_tab_name = vc
   SET tpc_pk_where_vc = tpc_pk_where
   SET tpc_proc_name = ""
   SET tpc_pktbl_cnt = 0
   SET tpc_pktbl_cnt = locateval(tpc_tbl_loop,1,size(pk_where_parm->qual,5),tpc_table_name,
    pk_where_parm->qual[tpc_tbl_loop].table_name)
   IF (tpc_pktbl_cnt=0)
    SET tpc_pktbl_cnt = (size(pk_where_parm->qual,5)+ 1)
    SET stat = alterlist(pk_where_parm->qual,tpc_pktbl_cnt)
    SET pk_where_parm->qual[tpc_pktbl_cnt].table_name = tpc_table_name
    SET tpc_tbl_loop = 0
    SET tpc_pkw_tab_name = dm2_get_rdds_tname("DM_REFCHG_PKW_PARM")
    SELECT INTO "NL:"
     FROM (parser(tpc_pkw_tab_name) d)
     WHERE d.table_name=tpc_table_name
     ORDER BY parm_nbr
     DETAIL
      tpc_tbl_loop = (tpc_tbl_loop+ 1), stat = alterlist(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,
       tpc_tbl_loop), pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name = d
      .column_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET tpc_error_ind = 1
    ENDIF
   ENDIF
   SET temp_tbl_cnt = locateval(tpc_tbl_loop,1,dm2_ref_data_doc->tbl_cnt,tpc_table_name,
    dm2_ref_data_doc->tbl_qual[tpc_tbl_loop].table_name)
   IF (temp_tbl_cnt=0)
    SET temp_tbl_cnt = fill_rs("TABLE",tpc_table_name)
   ENDIF
   FREE RECORD cust_cs_rows
   CALL parser("record cust_cs_rows (",0)
   CALL parser(" 1 qual[*]",0)
   FOR (tpc_tbl_loop = 1 TO size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5))
     SET tpc_col_pos = locateval(tpc_col_loop,1,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt,
      pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name,dm2_ref_data_doc->tbl_qual[
      temp_tbl_cnt].col_qual[tpc_col_loop].column_name)
     CALL parser(concat(" 2 ",pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name,
       " = ",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[tpc_col_pos].data_type),0)
     CALL parser(concat(" 2 ",pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name,
       "_NULLIND = i2 "),0)
   ENDFOR
   CALL parser(") go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET tpc_error_ind = 1
   ENDIF
   SET tpc_suffix = concat("t",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix)
   IF (tpc_pk_where_vc="")
    SET tpc_pk_where_vc = concat("WHERE t",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix,".",
     tpc_col_name," = tpc_value")
   ENDIF
   IF (((size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5) != 1) OR ((pk_where_parm->qual[
   tpc_pktbl_cnt].col_qual[1].col_name != tpc_col_name))) )
    SET tpc_src_tab_name = dm2_get_rdds_tname(tpc_table_name)
    SET tpc_row_cnt = 0
    CALL parser("select into 'NL:' ",0)
    FOR (tpc_tbl_loop = 1 TO size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5))
     IF (tpc_tbl_loop > 1)
      CALL parser(" , ",0)
     ENDIF
     CALL parser(concat("var",cnvtstring(tpc_tbl_loop)," = nullind(",tpc_suffix,".",
       pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name,")"),0)
    ENDFOR
    CALL parser(concat("from ",tpc_src_tab_name," ",tpc_suffix," ",
      tpc_pk_where_vc,
      " detail  tpc_row_cnt = tpc_row_cnt + 1 stat = alterlist(cust_cs_rows->qual, tpc_row_cnt) "),0)
    FOR (tpc_tbl_loop = 1 TO size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5))
     CALL parser(concat(" cust_cs_rows->qual[tpc_row_cnt].",pk_where_parm->qual[tpc_pktbl_cnt].
       col_qual[tpc_tbl_loop].col_name," = ",tpc_suffix,".",
       pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name),0)
     CALL parser(concat(" cust_cs_rows->qual[tpc_row_cnt].",pk_where_parm->qual[tpc_pktbl_cnt].
       col_qual[tpc_tbl_loop].col_name,"_NULLIND = var",cnvtstring(tpc_tbl_loop)),0)
    ENDFOR
    CALL parser("with nocounter go",1)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET tpc_error_ind = 1
    ENDIF
    IF (tpc_row_cnt=0)
     RETURN(0)
    ENDIF
   ELSE
    SET tpc_row_cnt = 1
    SET stat = alterlist(cust_cs_rows->qual,1)
    CALL parser(concat("set cust_cs_rows->qual[1].",tpc_col_name," = tpc_value go"),0)
   ENDIF
   SET tpc_pk_proc_name = concat("REFCHG_PK_WHERE_",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix,
    "*")
   SET tpc_uo_tname = dm2_get_rdds_tname("USER_OBJECTS")
   SELECT INTO "NL:"
    FROM (parser(tpc_uo_tname) u)
    WHERE u.object_name=patstring(tpc_pk_proc_name)
    DETAIL
     tpc_proc_name = u.object_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET tpc_error_ind = 1
   ENDIF
   IF (tpc_proc_name="")
    SET dm_err->emsg = concat("A trigger procedure is not built: ",tpc_pk_proc_name)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET drdm_error_out_ind = 1
    RETURN(1)
   ELSE
    SET tpc_main_proc = dm2_get_rdds_tname("PROC_REFCHG_INS_LOG")
    SET tpc_proc_name = dm2_get_rdds_tname(tpc_proc_name)
    FOR (tpc_row_loop = 1 TO tpc_row_cnt)
      SET drdm_parser->statement[1].frag = concat("RDB ASIS(^ BEGIN ",tpc_main_proc,"('",
       tpc_table_name,"',^)")
      SET drdm_parser->statement[2].frag = concat(" ASIS (^",tpc_proc_name,"('INS/UPD'^)")
      SET drdm_parser_cnt = 3
      FOR (tpc_tbl_loop = 1 TO size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5))
        CALL parser(concat("set tpc_col_nullind = cust_cs_rows->qual[tpc_row_loop].",pk_where_parm->
          qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name,"_NULLIND go"),1)
        IF (tpc_col_nullind=1)
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^ , NULL ^)")
         SET drdm_parser->statement[((drdm_parser_cnt+ 2)+ size(pk_where_parm->qual[tpc_pktbl_cnt].
          col_qual,5))].frag = concat("ASIS (^ , NULL ^)")
        ELSE
         SET tpc_col_pos = locateval(tpc_col_loop,1,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt,
          pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name,dm2_ref_data_doc->
          tbl_qual[temp_tbl_cnt].col_qual[tpc_col_loop].column_name)
         IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[tpc_col_pos].data_type IN ("F8")))
          CALL parser(concat("set tpc_f8_var = cust_cs_rows->qual[tpc_row_loop].",pk_where_parm->
            qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^ , ",cnvtstring(
            tpc_f8_var,15),"^)")
          SET drdm_parser->statement[((drdm_parser_cnt+ 2)+ size(pk_where_parm->qual[tpc_pktbl_cnt].
           col_qual,5))].frag = concat("ASIS (^ , ",cnvtstring(tpc_f8_var,15),"^)")
         ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[tpc_col_pos].data_type IN ("Q8",
         "DQ8")))
          CALL parser(concat("set tpc_f8_var = cust_cs_rows->qual[tpc_row_loop].",pk_where_parm->
            qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^ ,to_date('",format(
            tpc_f8_var,"DD-MMM-YYYY HH:MM:SS;;D"),"','DD-MON-YYYY HH24:MI:SS')^)")
          SET drdm_parser->statement[((drdm_parser_cnt+ 2)+ size(pk_where_parm->qual[tpc_pktbl_cnt].
           col_qual,5))].frag = concat("ASIS (^ ,to_date('",format(tpc_f8_var,
            "DD-MMM-YYYY HH:MM:SS;;D"),"','DD-MON-YYYY HH24:MI:SS')^)")
         ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[tpc_col_pos].data_type IN ("I4",
         "I2")))
          CALL parser(concat("set tpc_i4_var = cust_cs_rows->qual[tpc_row_loop].",pk_where_parm->
            qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^ , ",cnvtstring(
            tpc_i4_var),"^)")
          SET drdm_parser->statement[((drdm_parser_cnt+ 2)+ size(pk_where_parm->qual[tpc_pktbl_cnt].
           col_qual,5))].frag = concat("ASIS (^ , ",cnvtstring(tpc_i4_var),"^)")
         ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[tpc_col_pos].data_type="C*"))
          CALL parser(concat("declare tpc_c_var = C",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
            col_qual[tpc_col_pos].data_length," go"),1)
          CALL parser(concat("set tpc_c_var = cust_cs_rows->qual[tpc_row_loop].",pk_where_parm->qual[
            tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^ , '",tpc_c_var,"'^)")
          SET drdm_parser->statement[((drdm_parser_cnt+ 2)+ size(pk_where_parm->qual[tpc_pktbl_cnt].
           col_qual,5))].frag = concat("ASIS (^ , '",tpc_c_var,"'^)")
         ELSE
          CALL parser(concat("set tpc_vc_var = cust_cs_rows->qual[tpc_row_loop].",pk_where_parm->
            qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name," go"),1)
          SET tpc_vc_var = replace_carrot_symbol(tpc_vc_var)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^ , ",tpc_vc_var,"^)")
          SET drdm_parser->statement[((drdm_parser_cnt+ 2)+ size(pk_where_parm->qual[tpc_pktbl_cnt].
           col_qual,5))].frag = concat("ASIS (^ , ",tpc_vc_var,"^)")
         ENDIF
        ENDIF
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ENDFOR
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(
       "ASIS (^), dbms_utility.get_hash_value(^)")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^",tpc_proc_name,
       "('INS/UPD'^)")
      SET drdm_parser_cnt = ((drdm_parser_cnt+ 1)+ size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5
       ))
      SET drdm_parser->statement[drdm_parser_cnt].frag = "ASIS (^),0,1073741824.0), ^)"
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^'REFCHG',0,",cnvtstring(
        reqinfo->updt_id,15),",",cnvtstring(reqinfo->updt_task),",",
       cnvtstring(reqinfo->updt_applctx),", ^)")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^'",tpc_context,"',",
       cnvtstring(dm2_ref_data_doc->env_target_id,15),"); END; ^) GO")
      CALL parse_statements(drdm_parser_cnt)
      IF (nodelete_ind=1)
       SET tpc_error_ind = 1
       SET tpc_row_loop = tpc_row_cnt
      ENDIF
    ENDFOR
   ENDIF
   RETURN(tpc_error_ind)
 END ;Subroutine
 SUBROUTINE filter_proc_call(fpc_table_name,fpc_pk_where)
   DECLARE fpc_loop = i4
   DECLARE fpc_filter_pos = i4
   DECLARE fpc_col_cnt = i4
   DECLARE fpc_tbl_loop = i4
   DECLARE fpc_col_loop = i4
   DECLARE fpc_col_pos = i4
   DECLARE fpc_error_ind = i2
   DECLARE fpc_suffix = vc
   DECLARE fpc_row_cnt = i4
   DECLARE fpc_row_loop = i4
   DECLARE fpc_col_nullind = i2
   DECLARE fpc_proc_name = vc
   DECLARE fpc_filter_proc_name = vc
   DECLARE fpc_src_tab_name = vc
   DECLARE fpc_f8_var = f8
   DECLARE fpc_i4_var = i4
   DECLARE fpc_vc_var = vc
   DECLARE fpc_return_var = i2
   DECLARE fpc_uo_tname = vc
   DECLARE fpc_filter_tab_name = vc
   SET fpc_filter_pos = locateval(fpc_loop,1,size(filter_parm->qual,5),fpc_table_name,filter_parm->
    qual[fpc_loop].table_name)
   IF (fpc_filter_pos=0)
    SET fpc_filter_pos = (size(filter_parm->qual,5)+ 1)
    SET fpc_col_cnt = 0
    SET fpc_filter_tab_name = dm2_get_rdds_tname("DM_REFCHG_FILTER_PARM")
    SELECT INTO "NL:"
     FROM (parser(fpc_filter_tab_name) d)
     WHERE d.table_name=fpc_table_name
      AND d.active_ind=1
     ORDER BY d.parm_nbr
     HEAD REPORT
      stat = alterlist(filter_parm->qual,fpc_filter_pos), filter_parm->qual[fpc_filter_pos].
      table_name = fpc_table_name
     DETAIL
      fpc_col_cnt = (fpc_col_cnt+ 1), stat = alterlist(filter_parm->qual[fpc_filter_pos].col_qual,
       fpc_col_cnt), filter_parm->qual[fpc_filter_pos].col_qual[fpc_col_cnt].col_name = d.column_name
     WITH nocounter
    ;end select
    IF (curqual=0)
     RETURN(1)
    ENDIF
   ENDIF
   SET temp_tbl_cnt = locateval(fpc_tbl_loop,1,dm2_ref_data_doc->tbl_cnt,fpc_table_name,
    dm2_ref_data_doc->tbl_qual[fpc_tbl_loop].table_name)
   IF (temp_tbl_cnt=0)
    SET temp_tbl_cnt = fill_rs("TABLE",fpc_table_name)
   ENDIF
   FREE RECORD cust_cs_rows
   CALL parser("record cust_cs_rows (",0)
   CALL parser(" 1 qual[*]",0)
   FOR (fpc_tbl_loop = 1 TO size(filter_parm->qual[fpc_filter_pos].col_qual,5))
     SET fpc_col_pos = locateval(fpc_col_loop,1,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt,
      filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name,dm2_ref_data_doc->tbl_qual[
      temp_tbl_cnt].col_qual[fpc_col_loop].column_name)
     CALL parser(concat(" 2 ",filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," = ",
       dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fpc_col_pos].data_type),0)
     CALL parser(concat(" 2 ",filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name,
       "_NULLIND = i2 "),0)
   ENDFOR
   CALL parser(") go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET fpc_error_ind = 1
   ENDIF
   SET fpc_suffix = concat("t",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix)
   SET fpc_row_cnt = 0
   SET fpc_src_tab_name = dm2_get_rdds_tname(fpc_table_name)
   CALL parser("select into 'NL:' ",0)
   FOR (fpc_tbl_loop = 1 TO size(filter_parm->qual[fpc_filter_pos].col_qual,5))
    IF (fpc_tbl_loop > 1)
     CALL parser(" , ",0)
    ENDIF
    CALL parser(concat("var",cnvtstring(fpc_tbl_loop)," = nullind(",fpc_suffix,".",
      filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name,")"),0)
   ENDFOR
   CALL parser(concat("from ",fpc_src_tab_name," ",fpc_suffix," ",
     fpc_pk_where,
     " detail  fpc_row_cnt = fpc_row_cnt + 1 stat = alterlist(cust_cs_rows->qual, fpc_row_cnt) "),0)
   FOR (fpc_tbl_loop = 1 TO size(filter_parm->qual[fpc_filter_pos].col_qual,5))
    CALL parser(concat(" cust_cs_rows->qual[fpc_row_cnt].",filter_parm->qual[fpc_filter_pos].
      col_qual[fpc_tbl_loop].col_name," = ",fpc_suffix,".",
      filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name),0)
    CALL parser(concat(" cust_cs_rows->qual[fpc_row_cnt].",filter_parm->qual[fpc_filter_pos].
      col_qual[fpc_tbl_loop].col_name,"_NULLIND = var",cnvtstring(fpc_tbl_loop)),0)
   ENDFOR
   CALL parser("with nocounter go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET fpc_error_ind = 0
   ENDIF
   IF (fpc_row_cnt=0)
    RETURN(1)
   ENDIF
   SET fpc_uo_tname = dm2_get_rdds_tname("USER_OBJECTS")
   SET fpc_proc_name = ""
   SET fpc_filter_proc_name = concat("REFCHG_FILTER_",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix,
    "*")
   SELECT INTO "NL:"
    FROM (parser(fpc_uo_tname) u)
    WHERE u.object_name=patstring(fpc_filter_proc_name)
    DETAIL
     fpc_proc_name = u.object_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET fpc_error_ind = 1
   ENDIF
   IF (fpc_proc_name="")
    SET dm_err->emsg = concat("A filter procedure is not built: ",fpc_filter_proc_name)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET drdm_error_out_ind = 1
    RETURN(1)
   ELSE
    SET fpc_proc_name = dm2_get_rdds_tname(fpc_proc_name)
    CALL parser(concat(" declare ",fpc_proc_name,"() = i2 go"),0)
    FOR (fpc_row_loop = 1 TO fpc_row_cnt)
      SET drdm_parser->statement[1].frag = concat("select into 'NL:' ret_val = ",fpc_proc_name,
       "('UPD'")
      SET drdm_parser_cnt = 2
      FOR (fpc_tbl_loop = 1 TO size(filter_parm->qual[fpc_filter_pos].col_qual,5))
        CALL parser(concat("set fpc_col_nullind = cust_cs_rows->qual[fpc_row_loop].",filter_parm->
          qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name,"_NULLIND go"),1)
        IF (fpc_col_nullind=1)
         SET drdm_parser->statement[drdm_parser_cnt].frag = ", NULL, NULL "
        ELSE
         SET fpc_col_pos = locateval(fpc_col_loop,1,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt,
          filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name,dm2_ref_data_doc->
          tbl_qual[temp_tbl_cnt].col_qual[fpc_col_loop].column_name)
         IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fpc_col_pos].data_type IN ("F8")))
          CALL parser(concat("set fpc_f8_var = cust_cs_rows->qual[fpc_row_loop].",filter_parm->qual[
            fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(",",cnvtstring(fpc_f8_var,15),
           " , ",cnvtstring(fpc_f8_var,15))
         ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fpc_col_pos].data_type IN ("Q8",
         "DQ8")))
          CALL parser(concat("set fpc_f8_var = cust_cs_rows->qual[fpc_row_loop].",filter_parm->qual[
            fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" ,to_date('",format(fpc_f8_var,
            "DD-MMM-YYYY SS:MM:SS;;D"),"','DD-MON-YYYY HH24:MI:SS'),","to_date('",format(fpc_f8_var,
            "DD-MMM-YYYY SS:MM:SS;;D"),
           "','DD-MON-YYYY HH24:MI:SS')")
         ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fpc_col_pos].data_type IN ("I4",
         "I2")))
          CALL parser(concat("set fpc_i4_var = cust_cs_rows->qual[fpc_row_loop].",filter_parm->qual[
            fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(",",cnvtstring(fpc_i4_var)," , ",
           cnvtstring(fpc_i4_var))
         ELSE
          CALL parser(concat("set fpc_vc_var = cust_cs_rows->qual[fpc_row_loop].",filter_parm->qual[
            fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," go"),1)
          SET fpc_vc_var = replace(fpc_vc_var,"'","''",0)
          SET fpc_vc_var = concat("'",fpc_vc_var,"'")
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(",",fpc_vc_var," , ",fpc_vc_var)
         ENDIF
        ENDIF
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ENDFOR
      SET drdm_parser->statement[drdm_parser_cnt].frag =
      ") from dual detail fpc_return_var = ret_val with nocounter go"
      CALL parse_statements(drdm_parser_cnt)
      IF (nodelete_ind=1)
       SET fpc_error_ind = 1
       SET fpc_row_loop = fpc_row_cnt
      ENDIF
      IF (fpc_return_var=0)
       SET fpc_row_loop = fpc_row_cnt
      ENDIF
    ENDFOR
   ENDIF
   RETURN(fpc_return_var)
 END ;Subroutine
 SUBROUTINE replace_carrot_symbol(rcs_string)
   DECLARE rcs_start_idx = i4
   DECLARE rcs_pos = i4
   DECLARE rcs_return = vc
   DECLARE rcs_temp_val = vc
   DECLARE rcs_concat = vc
   SET rcs_temp_val = replace(rcs_string,"'",'"',0)
   SET rcs_start_idx = 1
   SET rcs_pos = findstring("^",rcs_temp_val,1,0)
   IF (rcs_pos=0)
    SET rcs_return = concat("'",rcs_temp_val,"'")
   ELSE
    WHILE (rcs_pos > 0)
      IF (rcs_start_idx=1)
       IF (rcs_pos=1)
        SET rcs_return = "chr(94)"
       ELSE
        SET rcs_return = concat("'",substring(rcs_start_idx,(rcs_pos - 1),rcs_temp_val),"'||chr(94)")
       ENDIF
      ELSE
       SET rcs_return = concat(rcs_return,"||'",substring(rcs_start_idx,(rcs_pos - rcs_start_idx),
         rcs_temp_val),"'||chr(94)")
      ENDIF
      SET rcs_start_idx = (rcs_pos+ 1)
      SET rcs_pos = findstring("^",rcs_temp_val,rcs_start_idx,0)
    ENDWHILE
    IF (rcs_start_idx <= size(rcs_temp_val))
     SET rcs_pos = findstring("^",rcs_temp_val,1,1)
     SET rcs_return = concat(rcs_return,"||'",substring(rcs_start_idx,(size(rcs_temp_val) - rcs_pos),
       rcs_temp_val),"'")
    ENDIF
   ENDIF
   RETURN(rcs_return)
 END ;Subroutine
 DECLARE cl_parse_cnt = i4
 SET cl_parse_cnt = 0
 IF (validate(dm2_cl_trg_rec->refchg_context_chk,"NO")="NO")
  FREE RECORD dm2_cl_trg_rec
  RECORD dm2_cl_trg_rec(
    1 refchg_context_chk = vc
    1 refchg_mvr_context_chk = vc
  )
  SET dm2_cl_trg_rec->refchg_context_chk =
  "(NVL(SYS_CONTEXT('CERNER','FIRE_REFCHG_TRG'),'DM2NULLVAL')!='NO')"
  SET dm2_cl_trg_rec->refchg_mvr_context_chk = concat(
   "((NVL(SYS_CONTEXT('CERNER','FIRE_REFCHG_TRG_MVR'),'DM2NULLVAL')!='NO')AND ",
   "(NVL(SYS_CONTEXT('CERNER','FIRE_REFCHG_TRG_MVR'),'DM2NULLVAL')!=to_char(envid_tbl(ct))))")
 ENDIF
 IF ((validate(dm2_cl_trg_updt_cols->tbl_cnt,- (1))=- (1)))
  IF ((validate(dm2_cl_trg_updt_cols->tbl_cnt,- (5))=- (5)))
   FREE RECORD dm2_cl_trg_updt_cols
   RECORD dm2_cl_trg_updt_cols(
     1 tbl_cnt = i4
     1 qual[*]
       2 tname = vc
       2 updt_task_exist_ind = i2
       2 updt_id_exist_ind = i2
       2 updt_applctx_exist_ind = i2
   )
  ENDIF
 ENDIF
 IF ((validate(cl_hold_buff->bg_err,- (1))=- (1)))
  FREE RECORD cl_hold_buffer
  RECORD cl_hold_buffer(
    1 bg_err = i2
    1 bg_hold[*]
      2 bg_buffer = vc
  )
 ENDIF
 IF ( NOT (validate(dcltr_circ)))
  FREE RECORD dcltr_circ
  RECORD dcltr_circ(
    1 tbl_cnt = i4
    1 tbl_qual[*]
      2 table_name = vc
      2 pk_col = vc
      2 circ_cnt = i4
      2 circ_qual[*]
        3 circ_tab = vc
        3 circ_id_col = vc
        3 circ_name_col = vc
        3 circ_exist_ind = i2
        3 circ_r_tab = vc
        3 fk_name_col = vc
        3 fk_id_col = vc
        3 fk_exist_ind = i2
  )
 ENDIF
 DECLARE refchg_trg_bld_std_when(s_rtbsw_trigger_type=vc,s_rtbsw_br_flg=i2,s_rtbsw_updt_task_exist=i2,
  s_rtbsw_flex=vc) = i2 WITH public
 DECLARE cl_push(p_text=vc) = null WITH public
 DECLARE dm2_trg_updt_cols_check(s_table_name=vc) = i2 WITH public
 DECLARE dm2_cl_trg_updt_cols(s_ctuc_tname=vc) = i2 WITH public
 DECLARE rc_push(p_text=vc) = null WITH public
 DECLARE flex_push(rc_cl_flex=vc,flex_text=vc) = null WITH public
 DECLARE binsearch_refchg(i_key=vc) = i4 WITH public
 DECLARE dcltr_get_circ_tab(dgct_table_name=vc) = i2
 SUBROUTINE refchg_trg_bld_std_when(s_rtbsw_trigger_type,s_rtbsw_br_flg,s_rtbsw_updt_task_exist,
  s_rtbsw_flex)
   DECLARE s_rtbsw_return_int = i2
   SET s_rtbsw_return_int = 1
   IF (currdb="ORACLE")
    CALL flex_push(s_rtbsw_flex,concat('ASIS(" when ( ',dm2_cl_trg_rec->refchg_context_chk,'")'))
    IF (s_rtbsw_trigger_type IN ("UPD", "ADD")
     AND s_rtbsw_updt_task_exist=1)
     CALL flex_push(s_rtbsw_flex,concat('ASIS(" and new.updt_task not in ( 15301)")'))
    ENDIF
    IF (s_rtbsw_br_flg=1)
     CALL flex_push(s_rtbsw_flex,concat('ASIS(" and ( ',dm2_cl_trg_rec->refchg_mvr_context_chk,'")'))
    ENDIF
   ENDIF
   RETURN(s_rtbsw_return_int)
 END ;Subroutine
 SUBROUTINE cl_push(p_text)
   SET cl_parse_cnt = (cl_parse_cnt+ 1)
   IF (mod(cl_parse_cnt,100)=1)
    SET stat = alterlist(cl_hold_buffer->bg_hold,(cl_parse_cnt+ 99))
   ENDIF
   SET cl_hold_buffer->bg_hold[cl_parse_cnt].bg_buffer = p_text
 END ;Subroutine
 SUBROUTINE rc_push(p_text)
   SET rc_parse_cnt = (rc_parse_cnt+ 1)
   IF (mod(rc_parse_cnt,100)=1)
    SET stat = alterlist(rc_hold_buffer->bg_hold,(rc_parse_cnt+ 99))
   ENDIF
   SET rc_hold_buffer->bg_hold[rc_parse_cnt].bg_buffer = p_text
 END ;Subroutine
 SUBROUTINE flex_push(rc_cl_flex,flex_text)
   IF (rc_cl_flex="RC")
    CALL rc_push(flex_text)
   ELSEIF (rc_cl_flex="CL")
    CALL cl_push(flex_text)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_trg_updt_cols_check(s_table_name)
   SET dm2_cl_trg_updt_cols->tbl_cnt = (dm2_cl_trg_updt_cols->tbl_cnt+ 1)
   SET stat = alterlist(dm2_cl_trg_updt_cols->qual,dm2_cl_trg_updt_cols->tbl_cnt)
   SET dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].tname = s_table_name
   SET dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_task_exist_ind = 0
   SET dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_id_exist_ind = 0
   SET dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_applctx_exist_ind = 0
   SELECT INTO "nl:"
    FROM dtableattr dta,
     dtableattrl dtal
    PLAN (dta
     WHERE dta.table_name=s_table_name)
     JOIN (dtal
     WHERE dtal.structtype="F"
      AND btest(dtal.stat,11)=0
      AND dtal.attr_name IN ("UPDT_TASK", "UPDT_ID", "UPDT_APPLCTX"))
    DETAIL
     IF (dtal.attr_name="UPDT_TASK")
      dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_task_exist_ind = 1
     ELSEIF (dtal.attr_name="UPDT_ID")
      dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_id_exist_ind = 1
     ELSEIF (dtal.attr_name="UPDT_APPLCTX")
      dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_applctx_exist_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(- (1))
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_cl_trg_updt_cols(s_ctuc_tname)
   DECLARE s_dctuc_return_int = i2
   DECLARE s_where_str = vc
   SET dm2_cl_trg_updt_cols->tbl_cnt = 0
   SET s_dctuc_return_int = 0
   SET stat = alterlist(dm2_cl_trg_updt_cols->qual,0)
   IF (s_ctuc_tname=char(42))
    SET s_where_str = "1=1"
   ELSE
    SET s_where_str = "ut.table_name = patstring(s_ctuc_tname)"
   ENDIF
   SELECT INTO "nl:"
    FROM user_tab_columns utc
    WHERE utc.table_name IN (
    (SELECT
     ut.table_name
     FROM user_tables ut
     WHERE parser(s_where_str)))
    ORDER BY utc.table_name
    HEAD REPORT
     stat = alterlist(dm2_cl_trg_updt_cols->qual,10)
    HEAD utc.table_name
     dm2_cl_trg_updt_cols->tbl_cnt = (dm2_cl_trg_updt_cols->tbl_cnt+ 1)
     IF (mod(dm2_cl_trg_updt_cols->tbl_cnt,10)=1
      AND (dm2_cl_trg_updt_cols->tbl_cnt != 1))
      stat = alterlist(dm2_cl_trg_updt_cols->qual,(dm2_cl_trg_updt_cols->tbl_cnt+ 9))
     ENDIF
     dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].tname = utc.table_name,
     dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_task_exist_ind = 0,
     dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_id_exist_ind = 0,
     dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_applctx_exist_ind = 0
    DETAIL
     IF (utc.column_name="UPDT_TASK")
      dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_task_exist_ind = 1
     ENDIF
     IF (utc.column_name="UPDT_ID")
      dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_id_exist_ind = 1
     ENDIF
     IF (utc.column_name="UPDT_APPLCTX")
      dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_applctx_exist_ind = 1
     ENDIF
    FOOT REPORT
     stat = alterlist(dm2_cl_trg_updt_cols->qual,dm2_cl_trg_updt_cols->tbl_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=0)
    IF ((dm_err->debug_flag != 0))
     CALL echo(concat("Obtained column information for: ",cnvtstring(dm2_cl_trg_updt_cols->tbl_cnt),
       " table/s"))
    ENDIF
    RETURN(s_dctuc_return_int)
   ELSE
    SET s_dctuc_return_int = 1
   ENDIF
   RETURN(s_dctuc_return_int)
 END ;Subroutine
 SUBROUTINE binsearch_refchg(i_key)
   DECLARE v_low = i4 WITH noconstant(0)
   DECLARE v_mid = i4 WITH noconstant(0)
   DECLARE v_high = i4
   SET v_high = size(refchg_tab_r->child,5)
   IF (v_high > 0)
    WHILE (((v_high - v_low) > 1))
     SET v_mid = cnvtint(((v_high+ v_low)/ 2))
     IF ((i_key <= refchg_tab_r->child[v_mid].child_table))
      SET v_high = v_mid
     ELSE
      SET v_low = v_mid
     ENDIF
    ENDWHILE
    IF (trim(i_key,3)=trim(refchg_tab_r->child[v_high].child_table,3))
     RETURN(v_high)
    ELSE
     RETURN(0)
    ENDIF
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE dcltr_get_circ_tab(dgct_table_name)
   DECLARE dgct_info_name = vc WITH protect, noconstant(" ")
   DECLARE dgct_temp = vc WITH protect, noconstant(" ")
   DECLARE dgct_idx = i4 WITH protect, noconstant(0)
   DECLARE dgct_col_pos = i4 WITH protect, noconstant(0)
   DECLARE dgct_col_pos2 = i4 WITH protect, noconstant(0)
   DECLARE dgct_start = i4 WITH protect, noconstant(0)
   DECLARE dgct_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgct_temp2 = vc WITH protect, noconstant(" ")
   DECLARE dgct_tab_pos = i4 WITH protect, noconstant(0)
   DECLARE dgct_temp_tab = vc WITH protect, noconstant(" ")
   DECLARE dgct_num = i4 WITH protect, noconstant(0)
   FREE RECORD dgct_tabs
   RECORD dgct_tabs(
     1 cnt = i4
     1 qual[*]
       2 table_name = vc
       2 column_name = vc
       2 suffix = vc
       2 r_table_name = vc
       2 val_table_name = vc
       2 exist_ind = i2
   )
   SET dgct_info_name = concat(dgct_table_name,":*")
   SET dgct_start = (dcltr_circ->tbl_cnt+ 1)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="RDDS 7 CIRCULAR:*"
     AND di.info_name=patstring(dgct_info_name)
    ORDER BY di.info_name
    HEAD di.info_name
     dgct_col_pos = findstring(":",di.info_name), dgct_temp = substring(1,(dgct_col_pos - 1),di
      .info_name), dgct_idx = locateval(dgct_idx,1,dcltr_circ->tbl_cnt,dgct_temp,dcltr_circ->
      tbl_qual[dgct_idx].table_name)
     IF (dgct_idx=0)
      dcltr_circ->tbl_cnt = (dcltr_circ->tbl_cnt+ 1), stat = alterlist(dcltr_circ->tbl_qual,
       dcltr_circ->tbl_cnt), dgct_idx = dcltr_circ->tbl_cnt,
      dcltr_circ->tbl_qual[dgct_idx].table_name = dgct_temp
     ENDIF
    DETAIL
     dgct_col_pos = findstring(":",di.info_domain), dgct_col_pos2 = findstring(":",di.info_domain,(
      dgct_col_pos+ 1)), dgct_temp = substring((dgct_col_pos+ 1),((dgct_col_pos2 - dgct_col_pos) - 1),
      di.info_domain),
     dgct_temp2 = substring((dgct_col_pos2+ 1),30,di.info_domain), dgct_tab_pos = locateval(
      dgct_tab_pos,1,dgct_tabs->cnt,dgct_temp,dgct_tabs->qual[dgct_tab_pos].table_name,
      dgct_temp2,dgct_tabs->qual[dgct_tab_pos].column_name)
     IF (dgct_tab_pos=0)
      dgct_tabs->cnt = (dgct_tabs->cnt+ 1), stat = alterlist(dgct_tabs->qual,dgct_tabs->cnt),
      dgct_tabs->qual[dgct_tabs->cnt].table_name = dgct_temp,
      dgct_tabs->qual[dgct_tabs->cnt].column_name = dgct_temp2, dgct_tabs->qual[dgct_tabs->cnt].
      val_table_name = dgct_tabs->qual[dgct_tabs->cnt].table_name
     ENDIF
     dgct_cnt = locateval(dgct_cnt,1,dcltr_circ->tbl_qual[dgct_idx].circ_cnt,dgct_temp,dcltr_circ->
      tbl_qual[dgct_idx].circ_qual[dgct_cnt].circ_tab,
      dgct_temp2,dcltr_circ->tbl_qual[dgct_idx].circ_qual[dgct_cnt].circ_id_col)
     IF (dgct_cnt=0)
      dcltr_circ->tbl_qual[dgct_idx].circ_cnt = (dcltr_circ->tbl_qual[dgct_idx].circ_cnt+ 1),
      dgct_cnt = dcltr_circ->tbl_qual[dgct_idx].circ_cnt, stat = alterlist(dcltr_circ->tbl_qual[
       dgct_idx].circ_qual,dgct_cnt),
      dcltr_circ->tbl_qual[dgct_idx].circ_qual[dgct_cnt].circ_tab = dgct_temp, dcltr_circ->tbl_qual[
      dgct_idx].circ_qual[dgct_cnt].circ_id_col = dgct_temp2, dcltr_circ->tbl_qual[dgct_idx].
      circ_qual[dgct_cnt].circ_name_col = di.info_char,
      dgct_col_pos = findstring(":",di.info_name,1), dgct_col_pos2 = findstring(":",di.info_name,(
       dgct_col_pos+ 1))
      IF (dgct_col_pos2 > 0)
       dcltr_circ->tbl_qual[dgct_idx].circ_qual[dgct_cnt].fk_id_col = substring((dgct_col_pos+ 1),((
        dgct_col_pos2 - dgct_col_pos) - 1),di.info_name), dcltr_circ->tbl_qual[dgct_idx].circ_qual[
       dgct_cnt].fk_name_col = substring((dgct_col_pos2+ 1),(size(trim(di.info_name)) - dgct_col_pos2
        ),di.info_name)
      ELSE
       dcltr_circ->tbl_qual[dgct_idx].circ_qual[dgct_cnt].fk_id_col = substring((dgct_col_pos+ 1),(
        size(trim(di.info_name)) - dgct_col_pos),di.info_name)
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(- (1))
   ELSEIF (curqual=0)
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_tables_doc_local d
    WHERE expand(dgct_cnt,1,dgct_tabs->cnt,d.table_name,dgct_tabs->qual[dgct_cnt].table_name)
     AND d.table_name=d.full_table_name
    DETAIL
     FOR (dgct_idx = 1 TO dgct_tabs->cnt)
       IF ((d.table_name=dgct_tabs->qual[dgct_idx].table_name))
        dgct_tabs->qual[dgct_idx].suffix = d.table_suffix
       ENDIF
     ENDFOR
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(- (1))
   ENDIF
   FOR (dgct_idx = 1 TO dgct_tabs->cnt)
     SET dgct_tabs->qual[dgct_idx].r_table_name = cutover_tab_name(dgct_tabs->qual[dgct_idx].
      table_name,dgct_tabs->qual[dgct_idx].suffix)
   ENDFOR
   SELECT INTO "nl:"
    FROM user_tables ut
    WHERE expand(dgct_cnt,1,dgct_tabs->cnt,ut.table_name,dgct_tabs->qual[dgct_cnt].r_table_name)
    DETAIL
     FOR (dgct_idx = 1 TO dgct_tabs->cnt)
       IF ((ut.table_name=dgct_tabs->qual[dgct_idx].r_table_name))
        dgct_tabs->qual[dgct_idx].val_table_name = ut.table_name
       ENDIF
     ENDFOR
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(- (1))
   ENDIF
   SELECT INTO "nl:"
    FROM user_tab_columns utc
    WHERE expand(dgct_num,1,dgct_tabs->cnt,utc.table_name,dgct_tabs->qual[dgct_num].val_table_name,
     utc.column_name,dgct_tabs->qual[dgct_num].column_name)
    DETAIL
     dgct_cnt = locateval(dgct_cnt,1,dgct_tabs->cnt,utc.table_name,dgct_tabs->qual[dgct_cnt].
      val_table_name,
      utc.column_name,dgct_tabs->qual[dgct_cnt].column_name), dgct_tabs->qual[dgct_cnt].exist_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(- (1))
   ENDIF
   IF ((dcltr_circ->tbl_cnt >= dgct_start))
    SELECT INTO "nl:"
     FROM dm_columns_doc_local d
     WHERE expand(dgct_cnt,dgct_start,dcltr_circ->tbl_cnt,d.table_name,dcltr_circ->tbl_qual[dgct_cnt]
      .table_name)
      AND d.table_name=d.root_entity_name
      AND d.column_name=d.root_entity_attr
      AND  EXISTS (
     (SELECT
      "x"
      FROM user_tab_columns u
      WHERE u.table_name=d.table_name
       AND u.column_name=d.column_name))
     DETAIL
      dgct_cnt = locateval(dgct_cnt,dgct_start,dcltr_circ->tbl_cnt,d.table_name,dcltr_circ->tbl_qual[
       dgct_cnt].table_name), dcltr_circ->tbl_qual[dgct_cnt].pk_col = d.column_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     RETURN(- (1))
    ENDIF
   ENDIF
   FOR (dgct_idx = dgct_start TO dcltr_circ->tbl_cnt)
     FOR (dgct_cnt = 1 TO dcltr_circ->tbl_qual[dgct_idx].circ_cnt)
       SET dgct_tab_pos = locateval(dgct_tab_pos,1,dgct_tabs->cnt,dcltr_circ->tbl_qual[dgct_idx].
        circ_qual[dgct_cnt].circ_tab,dgct_tabs->qual[dgct_tab_pos].table_name,
        dcltr_circ->tbl_qual[dgct_idx].circ_qual[dgct_cnt].circ_id_col,dgct_tabs->qual[dgct_tab_pos].
        column_name)
       SET dcltr_circ->tbl_qual[dgct_idx].circ_qual[dgct_cnt].circ_r_tab = dgct_tabs->qual[
       dgct_tab_pos].r_table_name
       SET dcltr_circ->tbl_qual[dgct_idx].circ_qual[dgct_cnt].circ_exist_ind = dgct_tabs->qual[
       dgct_tab_pos].exist_ind
       IF ((dcltr_circ->tbl_qual[dgct_idx].circ_qual[dgct_cnt].fk_name_col > " "))
        SELECT INTO "nl:"
         FROM user_tab_columns utc
         WHERE (utc.table_name=dcltr_circ->tbl_qual[dgct_idx].table_name)
          AND (utc.column_name=dcltr_circ->tbl_qual[dgct_idx].circ_qual[dgct_cnt].fk_name_col)
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         RETURN(- (1))
        ELSEIF (curqual > 0)
         SET dcltr_circ->tbl_qual[dgct_idx].circ_qual[dgct_cnt].fk_exist_ind = 1
        ENDIF
       ELSE
        SET dcltr_circ->tbl_qual[dgct_idx].circ_qual[dgct_cnt].fk_exist_ind = 1
       ENDIF
     ENDFOR
   ENDFOR
   RETURN(1)
 END ;Subroutine
 DECLARE rc_hold_spot = i4
 DECLARE rc_drop_cnt = i4
 SET rc_drop_cnt = 0
 FREE RECORD rc_drop
 RECORD rc_drop(
   1 qual[*]
     2 rc_stmt = vc
 )
 FREE RECORD chg_log_request
 RECORD chg_log_request(
   1 remote_env_id = f8
 )
 IF (check_logfile("dm2_refchg_trig_",".log","DM2REFCHG_TRGR LOG FILE...") != 1)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to Create Log File"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Starting dm2_add_refchg_log_triggers..."
 CALL disp_msg("",dm_err->logfile,0)
 IF ((validate(request->remote_env_id,- (1))=- (1)))
  SET chg_log_request->remote_env_id = 0
 ELSE
  SET chg_log_request->remote_env_id = request->remote_env_id
 ENDIF
 SET dm_err->eproc = "Executing dm2_add_chg_log_triggers to generate REFCHG triggers."
 CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
 EXECUTE dm2_add_chg_log_triggers "*", "REFCHG" WITH replace("REQUEST","CHG_LOG_REQUEST")
 IF ((dguc_reply->dguc_err_ind=1))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Error returned from dm2_add_chg_log_triggers, view log_file for details."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Returned from dm2_add_chg_log_triggers."
 CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
#exit_program
 IF ((dm_err->err_ind=1))
  SET dm_err->eproc = "ERROR TRAPPED"
  CALL disp_msg(" ",dm_err->logfile,0)
 ELSE
  SET dm_err->eproc = "...Ending dm2_add_refchg_log_triggers"
  CALL final_disp_msg("dm2_refchg_trig_")
 ENDIF
 FREE RECORD dguc_reply
END GO
