CREATE PROGRAM dm2_create_install_templates:dba
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
 DECLARE create_token_template(null) = i2
 DECLARE create_delete_template(null) = i2
 DECLARE create_restore_template(null) = i2
 IF (check_logfile("dm2_inst_templates",".log","DM2_CREATE_INSTALL_TEMPLATES LOGFILE")=0)
  GO TO exit_program
 ENDIF
 IF (create_token_template(null)=0)
  GO TO exit_program
 ENDIF
 IF (create_delete_template(null)=0)
  GO TO exit_program
 ENDIF
 IF (create_restore_template(null)=0)
  GO TO exit_program
 ENDIF
 IF (currdbuser != "CDBA")
  EXECUTE dm2_get_package_history
  IF ((dm_err->err_ind=1))
   GO TO exit_program
  ENDIF
 ENDIF
 GO TO exit_program
 SUBROUTINE create_token_template(null)
   DECLARE cltt_filename = vc WITH protect, noconstant("dm2_ni_dbca_tokens.txt")
   SET dm_err->eproc = concat("Writing ",cltt_filename,".")
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO value(cltt_filename)
    FROM dual
    DETAIL
     col 0, "#!/usr/bin/ksh", row + 1,
     col 0, "export DB_HOME=<oracle home>", row + 1,
     col 0, "export ASM_HOME=<asm_home>", row + 1,
     col 0, "export ORACLE_BASE=<oracle_base>", row + 1,
     col 0, "export DNAME=<dname>", row + 1,
     col 0, "export NODE_LIST=<node_list>   # no spaces, separated by commas", row + 1,
     col 0, "export NODE_LIST_SN=`echo ${NODE_LIST} | cut -d '.' -f 1`", row + 1,
     col 0, "export SYSPWD=<syspwd>	  # properly need to handle where password contains $ sign", row
      + 1,
     col 0, "export SYSTEMPWD=<systempwd>  # properly need to handle where password contains $ sign",
     row + 1,
     col 0, "export ASM_SID=<asm_sid>", row + 1,
     col 0, "export STORAGE_DISK_GROUP=<storage_disk_group>", row + 1,
     col 0, "export RECOVERY_DISK_GROUP=<recovery_disk_group>", row + 1,
     col 0, "export LOG_ARCHIVE_DEST_1=<log_archive_dest_1>", row + 1,
     col 0, "export DBCA_TEMPLATE=<dbca_template_name>", row + 1,
     col 0, "export ASM_SYSDBA_PWD=<asmsysdbapwd>", row + 1,
     col 0, "export HASUSER=<hasuser>", row + 1,
     col 0, "export CRS_HOME=<crs_home>", row + 1,
     col 0, "export CRS_STATE=<crs_state>", row + 1,
     col 0, "export RAC_OPTION=<rac_option>", row + 1,
     col 0, "export DB_ORA_VER=<db_ora_ver>", row + 1
    WITH nocounter, format = variable, formfeed = none,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE create_delete_template(null)
   DECLARE cldt_filename = vc WITH protect, noconstant("dm2_ni_dbca_delete_database.txt")
   SET dm_err->eproc = concat("Writing ",cldt_filename,".")
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO value(cldt_filename)
    FROM dual
    DETAIL
     col 0, "#!/usr/bin/ksh", row + 1,
     col 0, ". /tmp/<dname>_database_tokens.ksh", row + 1,
     col 0, "export ORACLE_HOME=${DB_HOME}", row + 1,
     col 0, "echo 'Issuing dbca command to delete database...'", row + 1,
     col 0, "$ORACLE_HOME/bin/dbca -silent -deletedatabase -sourcedb ${DNAME}1", row + 1,
     col 0, "export ORACLE_SID=${ASM_SID}", row + 1,
     col 0, "export ORACLE_HOME=${ASM_HOME}", row + 1,
     col 0, "echo 'Issuing asmcmd commands to remove database related disk group content...'", row +
     1,
     col 0, "$ORACLE_HOME/bin/asmcmd rm -rf  ${STORAGE_DISK_GROUP}/${DNAME}", row + 1,
     col 0, "$ORACLE_HOME/bin/asmcmd rm -rf  ${RECOVERY_DISK_GROUP}/${DNAME}", row + 1,
     col 0, "echo 'Issuing rm commands to remove database related files...'", row + 1,
     col 0, "rm -Rf $ORACLE_BASE/admin/${DNAME}", row + 1,
     col 0, "rm -rf $DB_HOME/dbs/*${DNAME}*", row + 1,
     col 0, "export ORACLE_SID=${DNAME}1", row + 1,
     col 0, "export ORACLE_HOME=${DB_HOME}", row + 1,
     col 0, "echo 'Issuing srvctl command to remove instance...'", row + 1,
     col 0, "$DB_HOME/bin/srvctl remove instance -d ${DNAME} -i ${DNAME}1 <<endSRV", row + 1,
     col 0, "Y", row + 1,
     col 0, "endSRV", row + 1,
     col 0, "echo 'Issuing srvctl command to remove database...'", row + 1,
     col 0, "$DB_HOME/bin/srvctl remove database -d ${DNAME} <<endSRV", row + 1,
     col 0, "Y", row + 1,
     col 0, 'if [[ ${RAC_OPTION} = "Y" ]]', row + 1,
     col 0, "then", row + 1,
     col 0, "  DCIT_DNAME=${DNAME}", row + 1,
     col 0, "else", row + 1,
     col 0, "  DCIT_DNAME=${DNAME}1", row + 1,
     col 0, "fi", row + 1,
     col 0,
     "if [[ `sed 's/\ //g' /etc/oratab | grep -i '^'${DCIT_DNAME}':' | cut -d':' -f1 | wc -l` -gt 0 ]]",
     row + 1,
     col 0, "then", row + 1,
     col 0, "  cp /etc/oratab /tmp/oratab_backup$$", row + 1,
     col 0, '  echo "${DCIT_DNAME} exists in /etc/oratab. Removing entry from /etc/oratab."', row + 1,
     col 0,
     "  dcit_line_nbr=`sed 's/\ //g' /etc/oratab | grep -ni '^'${DCIT_DNAME}':' | cut -d':' -f1`",
     row + 1,
     col 0, "  sed ${dcit_line_nbr}d /etc/oratab | cat > /tmp/oratab_tmp", row + 1,
     col 0, "  cp /tmp/oratab_tmp /etc/oratab", row + 1,
     col 0, "fi", row + 1
    WITH nocounter, format = variable, formfeed = none,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE create_restore_template(null)
   DECLARE clrt_filename = vc WITH protect, noconstant("dm2_ni_dbca_restore_database.txt")
   SET dm_err->eproc = concat("Writing ",clrt_filename,".")
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO value(clrt_filename)
    FROM dual
    DETAIL
     col 0, "#!/usr/bin/ksh", row + 1,
     col 0, ". /tmp/<dname>_database_tokens.ksh", row + 1,
     col 0, "export ORACLE_HOME=${DB_HOME}", row + 1,
     CALL print("export DBCA_LOGGING_DIR=${ORACLE_BASE}/cfgtoollogs/dbca/${DNAME}"), row + 1,
     CALL print('echo "`date`: Removing previous DBCA logging information for ${DNAME}"'),
     row + 1,
     CALL print("rm -Rf ${DBCA_LOGGING_DIR}"), row + 1,
     CALL print('DBCA_NODE_STR=" "'), row + 1,
     CALL print("DBCA_SID=${DNAME}1"),
     row + 1,
     CALL print(
     "#If HASUSER is 'UNKNOWN' (11.2 kernel NOT installed), CRS_STATE is 'HEALTHY' and RAC on..."),
     row + 1,
     CALL print("# then DBCA call needs to pass database name for  -sid and specify -nodelist..."),
     row + 1,
     CALL print('if [[ ${HASUSER} = "UNKNOWN" && ${CRS_STATE} = "HEALTHY"  && ${RAC_OPT} = "Y" ]]'),
     row + 1,
     CALL print("then"), row + 1,
     CALL print('  DBCA_NODE_STR="-nodelist ${NODE_LIST_SN}"'), row + 1,
     CALL print("  DBCA_SID=${DNAME}"),
     row + 1,
     CALL print("fi"), row + 1,
     CALL print(concat(
      "#IF HASUSER is 'ROOT' (11.2 GRID Infrastructure installed) and RAC_OPT is 'Y', ",
      "creating 11.1 shell, and nodes in cluster is 1...")), row + 1,
     CALL print("# then DBCA call needs to pass database name for  -sid and specify -nodelist... "),
     row + 1,
     CALL print('if [[ ${HASUSER} = "ROOT" && ${RAC_OPTION} = "Y"  && ${DB_ORA_VER} = "11.1" ]]'),
     row + 1,
     CALL print("then"), row + 1,
     CALL print("  if [[ `${CRS_HOME}/bin/olsnodes | grep -i ${NODE_LIST_SN} | wc -l` -gt 0 ]]"),
     row + 1,
     CALL print("  then"), row + 1,
     CALL print("    if [[ `${CRS_HOME}/bin/olsnodes | grep -v ${NODE_LIST_SN} | wc -l` -eq 0 ]]"),
     row + 1,
     CALL print("    then"),
     row + 1,
     CALL print('        DBCA_NODE_STR="-nodelist ${NODE_LIST_SN}"'), row + 1,
     CALL print("        DBCA_SID=${DNAME}"), row + 1,
     CALL print("    fi"),
     row + 1,
     CALL print("  fi"), row + 1,
     CALL print("fi"), row + 1,
     CALL print(concat('echo "`date`: Creating database: ${DNAME}". ',
      "DBCA output logged to /tmp/${DNAME}_dbca_restore_log.log on `hostname`")),
     row + 1, col 0, "$ORACLE_HOME/bin/dbca -silent -createDatabase \",
     row + 1, col 0, " -templateName ${DBCA_TEMPLATE} \",
     row + 1, col 0, " -gdbName ${DNAME}.world \",
     row + 1, col 0, " -sid ${DBCA_SID}  ${DBCA_NODE_STR} \",
     row + 1, col 0, " -sysPassword ${SYSPWD} \",
     row + 1, col 0, " -systemPassword ${SYSTEMPWD} \",
     row + 1, col 0, " -storageType ASM \ ",
     row + 1,
     CALL print(concat(" -asmSysPassword ${ASM_SYSDBA_PWD} -diskGroupName ${STORAGE_DISK_GROUP} ",
      "-recoveryGroupName ${RECOVERY_DISK_GROUP}  \ ")), row + 1,
     col 0, "-initParams \ ", row + 1,
     col 0, 'db_create_online_log_dest_1="+${STORAGE_DISK_GROUP}",\', row + 1,
     col 0, 'db_create_online_log_dest_2="+${RECOVERY_DISK_GROUP}" \', row + 1,
     col 0, ">> /tmp/${DNAME}_dbca_restore_log.log ", row + 1,
     CALL print("export ORACLE_SID=${DNAME}1"), row + 1,
     CALL print("if [[ ! -d ${DBCA_LOGGING_DIR} ]]"),
     row + 1,
     CALL print("then"), row + 1,
     CALL print("  mkdir ${DBCA_LOGGING_DIR}"), row + 1,
     CALL print("  #if unable to find log, create one with mock error message"),
     row + 1,
     CALL print("  if [[ ! -f /tmp/${DNAME}_dbca_restore_log.log ]]"), row + 1,
     CALL print("  then"), row + 1,
     CALL print(
     '    echo "No log file generated by DBCA. Restore is incomplete." > /tmp/${DNAME}_dbca_restore_log.log'
     ),
     row + 1,
     CALL print("  fi"), row + 1,
     CALL print(
     "  #copy the restore log to the oracle error log. This will result in restore being marked as failed"
     ), row + 1,
     CALL print(
     "  #dbca should create a logging dir, and failure to do so is treated as a error condition"),
     row + 1,
     CALL print(
     "  cp /tmp/${DNAME}_dbca_restore_log.log ${DBCA_LOGGING_DIR}/${DNAME}_dbca_ora_err.log"), row +
     1,
     CALL print("fi"), row + 1,
     CALL print(
     'echo "`date`: Scanning DBCA logging directory for any ORA errors during DBCA execution ..."'),
     row + 1,
     CALL print("if [[ -f ${DBCA_LOGGING_DIR}/${DNAME}.log ]]"), row + 1,
     CALL print("then"), row + 1,
     CALL print(
     '  grep "ORA-" ${DBCA_LOGGING_DIR}/${DNAME}.log >> ${DBCA_LOGGING_DIR}/${DNAME}_dbca_ora_err.log'
     ),
     row + 1,
     CALL print("fi  "), row + 1,
     CALL print("rm -f /tmp/${DNAME}_dbca_ora_err.log"), row + 1,
     CALL print(
     "if [[ -s ${DBCA_LOGGING_DIR}/${DNAME}_dbca_ora_err.log && ! -f /tmp/${DNAME}_ignore_dbca_errors.dat ]]"
     ),
     row + 1,
     CALL print("then"), row + 1,
     CALL print("  cp ${DBCA_LOGGING_DIR}/${DNAME}_dbca_ora_err.log /tmp/${DNAME}_dbca_ora_err.log"),
     row + 1,
     CALL print("fi"),
     row + 1,
     CALL print("if [[ -f /tmp/${DNAME}_dbca_ora_err.log ]]"), row + 1,
     CALL print("then"), row + 1,
     CALL print(
     '  echo "CER-00000: error - Oracle errors detected during dbca call.  Exiting ksh execution."'),
     row + 1,
     CALL print("  exit 1"), row + 1,
     CALL print("fi"), row + 1,
     CALL print("################################################################################"),
     row + 1,
     CALL print("#Issue CRS/GRID server control commands..."), row + 1,
     CALL print("################################################################################"),
     row + 1,
     CALL print("if [[ ${CRS_STATE} = 'HEALTHY' ]]"),
     row + 1,
     CALL print("then"), row + 1,
     CALL print(^  if [[ ${HASUSER} = 'ORACLE' && ${DB_ORA_VER} = "11.1" ]]^), row + 1,
     CALL print("  then"),
     row + 1,
     CALL print(
     '    echo "11.2 GRID Restart installed and creating 11.1 database.  Skipping srvctl commands."'),
     row + 1,
     CALL print("  else"), row + 1,
     CALL print(
     '    if [[ `${ORACLE_HOME}/bin/srvctl config database | grep -i "${DNAME}" | wc -l` -gt 0 ]]'),
     row + 1,
     CALL print("    then"), row + 1,
     CALL print('      echo "srvctl returned an entry for database :${DNAME}."'), row + 1,
     CALL print("    else"),
     row + 1,
     CALL print("      if [[ ${HASUSER} = 'ORACLE' ]]  # and db_ora_ver = 11.2"), row + 1,
     CALL print("      then"), row + 1,
     CALL print(
     '        echo "11.2 GRID Restart installed and creating 11.2 database.  Issuing srvctl commands..."'
     ),
     row + 1,
     CALL print('        echo "Issuing srvctl add database command..."'), row + 1,
     CALL print("        ${ORACLE_HOME}/bin/srvctl add database -d ${DNAME} -o ${ORACLE_HOME} \ "),
     row + 1,
     CALL print("        -p +${STORAGE_DISK_GROUP}/${DNAME}/spfile${DNAME}.ora -i ${ORACLE_SID} "),
     row + 1,
     CALL print('        echo "Issuing srvctl start database command..."'), row + 1,
     CALL print("        ${ORACLE_HOME}/bin/srvctl start database -d ${DNAME}"), row + 1,
     CALL print("      else"),
     row + 1,
     CALL print(^        if [[ ${HASUSER} = 'ROOT' && ${DB_ORA_VER} = "11.2" ]]^), row + 1,
     CALL print("        then"), row + 1,
     CALL print(concat(
      '          echo "11.2 GRID Infrastructure installed and creating 11.2 database.  ',
      'Issuing srvctl commands..."')),
     row + 1,
     CALL print('          echo "Issuing srvctl add database command..."'), row + 1,
     CALL print("          ${ORACLE_HOME}/bin/srvctl add database -d ${DNAME} -o ${ORACLE_HOME} \ "),
     row + 1,
     CALL print("          -p +${STORAGE_DISK_GROUP}/${DNAME}/spfile${DNAME}.ora"),
     row + 1,
     CALL print('          echo "Issuing srvctl add instance command..."'), row + 1,
     CALL print(
     "          ${ORACLE_HOME}/bin/srvctl add instance -d ${DNAME} -i ${ORACLE_SID} -n ${NODE_LIST_SN}"
     ), row + 1,
     CALL print('          echo "Issuing srvctl start database command..."'),
     row + 1,
     CALL print("          ${ORACLE_HOME}/bin/srvctl start database -d ${DNAME}"), row + 1,
     CALL print("        else"), row + 1,
     CALL print("          # db_ora_ver = 11.1..."),
     row + 1,
     CALL print("          if [[ ${HASUSER} = 'ROOT' ]]"), row + 1,
     CALL print("          then"), row + 1,
     CALL print(concat(
      '            echo "11.2 GRID Infrastructure installed and creating 11.1 database.  ',
      'Issuing srvctl commands..."')),
     row + 1,
     CALL print("          else"), row + 1,
     CALL print(
     '            echo "11.2 not installed and creating 11.1 database.  Issuing srvctl commands..."'),
     row + 1,
     CALL print("          fi"),
     row + 1,
     CALL print('          echo "Issuing srvctl add database command..."'), row + 1,
     CALL print("          ${ORACLE_HOME}/bin/srvctl add database -d ${DNAME} -o ${ORACLE_HOME} \ "),
     row + 1,
     CALL print("          -p +${STORAGE_DISK_GROUP}/${DNAME}/spfile${DNAME}.ora"),
     row + 1,
     CALL print('          echo "Issuing srvctl add instance command..."'), row + 1,
     CALL print(
     "          ${ORACLE_HOME}/bin/srvctl add instance -d ${DNAME} -i ${ORACLE_SID} -n ${NODE_LIST_SN}"
     ), row + 1,
     CALL print('          echo "Issuing srvctl modify instance command..."'),
     row + 1,
     CALL print(
     "          ${ORACLE_HOME}/bin/srvctl modify instance -d ${DNAME} -i ${ORACLE_SID} -s ${ASM_SID}"
     ), row + 1,
     CALL print('          echo "Issuing srvctl start database command..."'), row + 1,
     CALL print("          ${ORACLE_HOME}/bin/srvctl start database -d ${DNAME}"),
     row + 1,
     CALL print("        fi"), row + 1,
     CALL print("      fi"), row + 1,
     CALL print("    fi"),
     row + 1,
     CALL print("  fi"), row + 1,
     CALL print("fi"), row + 1,
     CALL print(concat("$ORACLE_HOME/bin/sqlplus -S -L / as sysdba <<endSQL | grep ORA- >> ",
      "${DBCA_LOGGING_DIR}/${DNAME}_dbca_ora_err.log ")),
     row + 1,
     CALL print('echo "`date`: Setting password Case Sensitivity to FALSE ..."'), row + 1,
     CALL print("alter system set sec_case_sensitive_logon=false scope=both sid='*';"), row + 1,
     CALL print("alter system set log_archive_dest_1='${LOG_ARCHIVE_DEST_1}' scope=spfile;"),
     row + 1,
     CALL print('alter system set log_archive_format="${DNAME}_%T_%S_%r.arc" scope=spfile;'), row
      + 1,
     CALL print('alter system set audit_trail="NONE" scope=spfile;'), row + 1,
     CALL print("shutdown immediate"),
     row + 1,
     CALL print("startup"), row + 1,
     CALL print("alter user xdb identified by ${SYSPWD} account unlock;"), row + 1,
     CALL print("exit"),
     row + 1,
     CALL print("endSQL"), row + 1
    WITH nocounter, format = variable, formfeed = none,
     maxrow = 1, maxcol = 200
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_program
 SET dm_err->eproc = "DM2_CREATE_INSTALL_TEMPLATES COMPLETED"
 CALL final_disp_msg("dm2_inst_templates")
END GO
