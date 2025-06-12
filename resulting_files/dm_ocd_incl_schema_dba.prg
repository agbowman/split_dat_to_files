CREATE PROGRAM dm_ocd_incl_schema:dba
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
 IF (validate(cur_sch->tbl_cnt,- (1)) < 0)
  FREE RECORD cur_sch
  RECORD cur_sch(
    1 rdbms = vc
    1 mviews_active_ind = i2
    1 dm_info_exists_ind = i2
    1 tbl_cnt = i4
    1 tbl[*]
      2 tbl_name = vc
      2 tspace_name = vc
      2 long_tspace = vc
      2 long_tspace_ni = i2
      2 pct_increase = f8
      2 pct_used = f8
      2 pct_free = f8
      2 init_ext = f8
      2 next_ext = f8
      2 capture_ind = i2
      2 schema_date = dq8
      2 schema_instance = i4
      2 bytes_allocated = f8
      2 bytes_used = f8
      2 row_cnt = f8
      2 ext_mgmt = c1
      2 lext_mgmt = c1
      2 max_ext = f8
      2 reference_ind = i2
      2 mview_flag = i2
      2 mview_exists_ind = i2
      2 mview_syn_status = vc
      2 ddl_excl_ind = i2
      2 rowdeps_ind = i2
      2 tbl_col_cnt = i4
      2 partitioned_ind = i2
      2 tbl_col[*]
        3 col_name = vc
        3 col_seq = i4
        3 data_type = vc
        3 data_length = i4
        3 data_default = vc
        3 data_default_ni = i2
        3 nullable = c1
        3 bytes_allocated = f8
        3 bytes_used = f8
        3 virtual_column = vc
        3 hidden_column = vc
      2 ind_cnt = i4
      2 ind_tspace = vc
      2 ind_tspace_ni = i2
      2 ind[*]
        3 ind_name = vc
        3 full_ind_name = vc
        3 tspace_name = vc
        3 tspace_name_ni = i2
        3 pct_increase = f8
        3 pct_free = f8
        3 init_ext = f8
        3 next_ext = f8
        3 unique_ind = i2
        3 bytes_allocated = f8
        3 bytes_used = f8
        3 index_type = vc
        3 ind_col_cnt = i4
        3 pk_change_ind = i2
        3 ext_mgmt = c1
        3 max_ext = f8
        3 visibility = vc
        3 ind_col[*]
          4 col_name = vc
          4 col_position = i2
        3 ddl_excl_ind = i2
        3 partitioned_ind = i2
        3 cur_cons_idx = i4
        3 cur_tmp_cons_idx = i4
      2 cons_cnt = i4
      2 cons[*]
        3 cons_name = vc
        3 full_cons_name = vc
        3 cons_type = c1
        3 r_constraint_name = vc
        3 orig_r_cons_name = vc
        3 parent_table = vc
        3 status_ind = i2
        3 parent_table_columns = vc
        3 delete_rule = vc
        3 cons_col_cnt = i4
        3 cons_col[*]
          4 col_name = vc
          4 col_position = i2
        3 fk_cnt = i4
        3 fk[*]
          4 tbl_ndx = i4
          4 cons_ndx = i4
    1 tspace_cnt = i4
    1 tspace[*]
      2 tspace_name = vc
      2 initial_extent = f8
      2 next_extent = f8
      2 ext_mgmt = c1
      2 pct_increase = f8
      2 tspace_type = vc
      2 tspace_type_ni = i2
      2 pagesize = i4
      2 nodegroup = vc
      2 nodegroup_ni = i2
      2 bufferpool_name = vc
      2 bufferpool_name_ni = i2
    1 sequence_cnt = i4
    1 sequence[*]
      2 seq_name = vc
      2 min_val = f8
      2 max_val = f8
      2 cycle_flag = c1
      2 increment_by = f8
      2 last_number = f8
      2 capture_ind = i2
  )
  SET cur_sch->tbl_cnt = 0
 ENDIF
 IF (validate(tgtsch->tbl_cnt,- (1)) < 0)
  FREE RECORD tgtsch
  RECORD tgtsch(
    1 source_rdbms = vc
    1 schema_date = dq8
    1 alpha_feature_nbr = i4
    1 diff_ind = i2
    1 warn_ind = i2
    1 tbl_cnt = i4
    1 ddl_excl_ind = i2
    1 tbl[*]
      2 tbl_name = vc
      2 longlob_col_cnt = i4
      2 gtt_flag = i2
      2 last_analyzed_dt_tm = dq8
      2 orig_tbl_name = vc
      2 full_tbl_name = vc
      2 suff_tbl_name = vc
      2 new_ind = i2
      2 diff_ind = i2
      2 warn_ind = i2
      2 combine_ind = i2
      2 reference_ind = i4
      2 child_tbl_ind = i2
      2 tspace_name = vc
      2 cur_idx = i4
      2 row_cnt = f8
      2 cur_bytes_allocated = f8
      2 cur_bytes_used = f8
      2 pct_increase = f8
      2 pct_used = f8
      2 pct_free = f8
      2 init_ext = f8
      2 next_ext = f8
      2 size = f8
      2 ind_size = f8
      2 long_size = f8
      2 total_space = f8
      2 free_space = f8
      2 schema_date = dq8
      2 schema_instance = i4
      2 alpha_feature_nbr = i4
      2 feature_number = i4
      2 updt_dt_tm = dq8
      2 long_tspace = vc
      2 dext_mgmt = c1
      2 iext_mgmt = c1
      2 lext_mgmt = c1
      2 ttspace_new_ind = i2
      2 itspace_new_ind = i2
      2 ltspace_new_ind = i2
      2 table_suffix = vc
      2 logical_rowid_column_ind = i2
      2 bytes_allocated = f8
      2 bytes_used = f8
      2 afd_schema_instance = i4
      2 pull_from_afd = i2
      2 rowid_col_fnd = i2
      2 xrid_ind_fnd = i2
      2 ttsp_set_ind = i2
      2 itsp_set_ind = i2
      2 ltsp_set_ind = i2
      2 new_lob_col_ind = i2
      2 ttspace_assignment_choice = vc
      2 itspace_assignment_choice = vc
      2 ltspace_assignment_choice = vc
      2 tbl_col_cnt = i4
      2 max_ext = f8
      2 ind_rename_cnt = i4
      2 ind_replace_cnt = i4
      2 ddl_excl_ind = i2
      2 clu_idx = i2
      2 rowdeps_ind = i2
      2 metadata_loc_flg = i2
      2 part_ind = i2
      2 part_active_ind = i2
      2 partitioning_type = vc
      2 subpartitioning_type = vc
      2 partition_count = i4
      2 subpartition_count = i4
      2 interval = vc
      2 autolist = vc
      2 indexing_off_ind = i2
      2 row_mvmnt_ind = i2
      2 part_col_cnt = i4
      2 part_col[*]
        3 column_name = vc
        3 position = i2
      2 subpart_col_cnt = i4
      2 subpart_col[*]
        3 column_name = vc
        3 position = i2
      2 part_tsp_cnt = i4
      2 part_tsp[*]
        3 tablespace_name = vc
      2 subpart_tsp_cnt = i4
      2 subpart_tsp[*]
        3 tablespace_name = vc
      2 part_cnt = i4
      2 part[*]
        3 template_ind = i2
        3 indexing_off_ind = i2
        3 partition_name = vc
        3 subpartition_name = vc
        3 high_value = vc
        3 partition_position = i2
        3 subpartition_position = i2
        3 tablespace_name = vc
      2 ind_rename[*]
        3 cur_ind_name = vc
        3 temp_ind_name = vc
        3 final_ind_name = vc
        3 drop_cur_ind = i2
        3 drop_temp_ind = i2
        3 rename_cur_ind = i2
        3 rename_temp_ind = i2
        3 cur_ind_tspace_name = vc
        3 cur_ind_idx = i4
        3 drop_early_ind = i2
        3 ddl_excl_ind = i2
        3 rename_with_drop_ind = i2
      2 ind_replace[*]
        3 ind_name = vc
        3 temp_ind_name = vc
      2 ind_rebuild_cnt = i4
      2 ind_rebuild[*]
        3 initial_ind_name = vc
        3 interm_ind_name = vc
        3 final_ind_name = vc
        3 cons_name = vc
      2 tbl_col[*]
        3 col_name = vc
        3 col_seq = i4
        3 data_type = vc
        3 data_length = i4
        3 data_default = vc
        3 data_default_ni = i2
        3 nullable = c1
        3 new_ind = i2
        3 diff_dtype_ind = i2
        3 diff_dlength_ind = i2
        3 diff_nullable_ind = i2
        3 null_to_notnull_ind = i2
        3 diff_default_ind = i2
        3 cur_idx = i4
        3 size = f8
        3 diff_backfill = i2
        3 backfill_op_exists = i2
        3 virtual_column = vc
        3 part_ind = i2
        3 part_active_ind = i2
        3 lob_part_cnt = i4
        3 lob_part[*]
          4 template_ind = i2
          4 partition_name = vc
          4 subpartition_name = vc
          4 partition_position = i2
          4 subpartition_position = i2
          4 tablespace_name = vc
      2 ind_tspace = vc
      2 ind_cnt = i4
      2 ind[*]
        3 ind_name = vc
        3 full_ind_name = vc
        3 pct_increase = f8
        3 pct_free = f8
        3 init_ext = f8
        3 next_ext = f8
        3 size = f8
        3 unique_ind = i2
        3 cur_bytes_allocated = f8
        3 cur_bytes_used = f8
        3 bytes_allocated = f8
        3 bytes_used = f8
        3 index_type = vc
        3 ind_col_cnt = i4
        3 pk_ind = i2
        3 visibility_change_ind = i2
        3 part_ind = i2
        3 rebuild_ind = i2
        3 part_active_ind = i2
        3 partitioning_type = vc
        3 subpartitioning_type = vc
        3 partition_count = i4
        3 subpartition_count = i4
        3 interval = vc
        3 autolist = vc
        3 locality = vc
        3 partial_ind = i2
        3 part_col_cnt = i4
        3 part_col[*]
          4 column_name = vc
          4 position = i2
        3 part_tsp_cnt = i4
        3 part_tsp[*]
          4 tablespace_name = vc
        3 subpart_tsp_cnt = i4
        3 subpart_tsp[*]
          4 tablespace_name = vc
        3 part_cnt = i4
        3 part[*]
          4 partition_name = vc
          4 subpartition_name = vc
          4 high_value = vc
          4 partition_position = i2
          4 subpartition_position = i2
          4 tablespace_name = vc
        3 ind_col[*]
          4 col_name = vc
          4 col_position = i2
        3 new_ind = i2
        3 drop_ind = i2
        3 diff_name_ind = i2
        3 diff_unique_ind = i2
        3 diff_col_ind = i2
        3 diff_cons_ind = i2
        3 diff_type_ind = i2
        3 build_ind = i2
        3 cur_idx = i4
        3 rename_ind = i2
        3 replace_ind = i2
        3 temp_ind = i2
        3 tspace_name = vc
        3 ext_mgmt = c1
        3 max_ext = f8
        3 ddl_excl_ind = i2
      2 ind_drop_cnt = i4
      2 ind_drop[*]
        3 ind_name = vc
      2 cons_cnt = i4
      2 cons[*]
        3 cons_name = vc
        3 full_cons_name = vc
        3 cons_type = c1
        3 parent_table = vc
        3 status_ind = i2
        3 parent_table_columns = vc
        3 r_constraint_name = vc
        3 index_idx = i4
        3 delete_rule = vc
        3 cons_col_cnt = i4
        3 cons_col[*]
          4 col_name = vc
          4 col_position = i2
        3 new_ind = i2
        3 drop_ind = i2
        3 diff_name_ind = i2
        3 diff_col_ind = i2
        3 diff_status_ind = i2
        3 diff_parent_ind = i2
        3 diff_ind_ind = i2
        3 build_ind = i2
        3 cur_idx = i4
        3 fk_cnt = i4
        3 ddl_excl_ind = i2
      2 cons_drop_cnt = i4
      2 cons_drop[*]
        3 cons_name = vc
        3 cons_type = c1
        3 cur_cons_idx = i4
        3 ddl_excl_ind = i2
      2 mview_flag = i2
      2 mview_cc_build_ind = i2
      2 mview_build_ind = i2
      2 mview_log_cnt = i2
      2 mview_logs[*]
        3 table_name = vc
      2 mview_piece_cnt = i2
      2 mview_piece[*]
        3 txt = vc
    1 tspace_cnt = i4
    1 tspace[*]
      2 tspace_name = vc
      2 initial_extent = f8
      2 next_extent = f8
      2 pct_increase = f8
      2 new_ind = i2
      2 cur_idx = i4
      2 tspace_type = vc
      2 tspace_type_ni = i2
      2 pagesize = i4
      2 nodegroup = vc
      2 nodegroup_ni = i2
      2 bufferpool_name = vc
      2 bufferpool_name_ni = i2
      2 bytes_free_reqd = f8
      2 min_total_bytes = f8
    1 backfill_ops_cnt = i4
    1 backfill_ops[*]
      2 op_id = f8
      2 gen_dt_tm = dq8
      2 status = vc
      2 reset_backfill = i2
      2 delete_row = i2
      2 table_name = vc
      2 tgt_tbl_idx = i4
      2 col_cnt = i4
      2 col[*]
        3 tgt_col_idx = i4
        3 col_name = vc
      2 backfill_method = vc
    1 sequence_cnt = i4
    1 sequence[*]
      2 seq_name = vc
      2 min_val = f8
      2 max_val = f8
      2 cycle_flag = c1
      2 increment_by = f8
      2 last_number = f8
      2 new_ind = i2
      2 diff_ind = i2
    1 tspace_diff_ind = i2
    1 user_cnt = i4
    1 user[*]
      2 new_ind = i2
      2 diff_ind = i2
      2 user_name = vc
      2 instance = i4
      2 cur_instance = i4
      2 pull_from_admin = i2
      2 default_tspace = vc
      2 default_tspace_size = f8
      2 temp_tspace = vc
      2 temp_tspace_size = f8
      2 priv_cnt = i4
      2 privs[*]
        3 priv_name = vc
      2 quota_cnt = i4
      2 quota[*]
        3 tspace_name = vc
    1 clu_cnt = i4
    1 clu[*]
      2 cluster_name = vc
      2 table_name = vc
      2 cluster_tsp_name = vc
      2 index_name = vc
      2 cluster_index_tsp_name = vc
      2 col_list_def = vc
      2 new_ind = i2
      2 clucol_cnt = i4
      2 clucol[*]
        3 column_name = vc
        3 data_type = vc
        3 data_length = i4
        3 col_pos = i2
  )
  SET tgtsch->tbl_cnt = 0
  SET tgtsch->backfill_ops_cnt = 0
  SET tgtsch->user_cnt = 0
  SET tgtsch->tspace_cnt = 0
 ENDIF
 DECLARE dbai_err_ind = i2 WITH public, noconstant(0)
 DECLARE dbai_err_msg = c132 WITH public, noconstant(" ")
 DECLARE dbai_backfill_pkg(dbp_ocd=i4) = i4
 DECLARE dbai_backfill_pkg_tbl(dbpt_ocd=i4,dbpt_tbl=vc) = i4
 DECLARE dbai_error(null) = i4
 FREE RECORD dbai_afd_instance
 RECORD dbai_afd_instance(
   1 qual[*]
     2 ocd = i4
     2 table_name = vc
     2 schema_instance = i4
   1 cnt = i4
 )
 SUBROUTINE dbai_backfill_pkg(dbp_ocd)
   SELECT INTO "nl:"
    t.alpha_feature_nbr, t.table_name, i.info_number
    FROM dm_info i,
     dm_afd_tables t
    PLAN (t
     WHERE t.alpha_feature_nbr=dbp_ocd
      AND t.schema_instance=0)
     JOIN (i
     WHERE i.info_domain=concat("AFD_SCHEMA_INSTANCE ",t.table_name)
      AND i.info_name=cnvtstring(t.alpha_feature_nbr))
    ORDER BY t.alpha_feature_nbr, t.table_name
    DETAIL
     dbai_afd_instance->cnt = (dbai_afd_instance->cnt+ 1), stat = alterlist(dbai_afd_instance->qual,
      dbai_afd_instance->cnt), dbai_afd_instance->qual[dbai_afd_instance->cnt].ocd = t
     .alpha_feature_nbr,
     dbai_afd_instance->qual[dbai_afd_instance->cnt].table_name = t.table_name, dbai_afd_instance->
     qual[dbai_afd_instance->cnt].schema_instance = i.info_number
    WITH nocounter
   ;end select
   IF (dbai_error(null)=0)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    UPDATE  FROM dm_afd_tables t,
      (dummyt d  WITH seq = dbai_afd_instance->cnt)
     SET t.seq = 1, t.schema_instance = dbai_afd_instance->qual[d.seq].schema_instance
     PLAN (d)
      JOIN (t
      WHERE (t.alpha_feature_nbr=dbai_afd_instance->qual[d.seq].ocd)
       AND (t.table_name=dbai_afd_instance->qual[d.seq].table_name))
     WITH nocounter
    ;end update
    IF (dbai_error(null)=0)
     RETURN(0)
    ENDIF
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dbai_backfill_pkg_tbl(dbpt_ocd,dbpt_tbl)
   SELECT INTO "nl:"
    t.alpha_feature_nbr, t.table_name, i.info_number
    FROM dm_info i,
     dm_afd_tables t
    PLAN (t
     WHERE t.alpha_feature_nbr=dbpt_ocd
      AND t.table_name=dbpt_tbl
      AND t.schema_instance=0)
     JOIN (i
     WHERE i.info_domain=concat("AFD_SCHEMA_INSTANCE ",t.table_name)
      AND i.info_name=cnvtstring(t.alpha_feature_nbr))
    ORDER BY t.alpha_feature_nbr, t.table_name
    DETAIL
     dbai_afd_instance->cnt = (dbai_afd_instance->cnt+ 1), stat = alterlist(dbai_afd_instance->qual,
      dbai_afd_instance->cnt), dbai_afd_instance->qual[dbai_afd_instance->cnt].ocd = t
     .alpha_feature_nbr,
     dbai_afd_instance->qual[dbai_afd_instance->cnt].table_name = t.table_name, dbai_afd_instance->
     qual[dbai_afd_instance->cnt].schema_instance = i.info_number
    WITH nocounter
   ;end select
   IF (dbai_error(null)=0)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    UPDATE  FROM dm_afd_tables t,
      (dummyt d  WITH seq = dbai_afd_instance->cnt)
     SET t.seq = 1, t.schema_instance = dbai_afd_instance->qual[d.seq].schema_instance
     PLAN (d)
      JOIN (t
      WHERE (t.alpha_feature_nbr=dbai_afd_instance->qual[d.seq].ocd)
       AND (t.table_name=dbai_afd_instance->qual[d.seq].table_name))
     WITH nocounter
    ;end update
    IF (dbai_error(null)=0)
     RETURN(0)
    ENDIF
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dbai_error(null)
   SET dbai_err_ind = error(dbai_err_msg,1)
   IF (dbai_err_ind > 0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#main_start
 SET width = 132
 SET reqinfo->updt_task = dm2_install_schema->dm2_updt_task_value
 IF ((dm_err->debug_flag > 0))
  CALL echo(dm_err->asterisk_line)
  CALL echo(build("reqinfo->updt_task=",reqinfo->updt_task))
  CALL echo(dm_err->asterisk_line)
 ENDIF
 EXECUTE FROM initialize TO initialize_end
 IF (call_script != "DM_OCD_MENU")
  CALL start_status(concat("Checking user privileges in CCL for ",curuser),env_id,ocd_number)
  SELECT INTO "nl:"
   d.group
   FROM duaf d
   WHERE cnvtupper(d.user_name)=cnvtupper(curuser)
    AND d.group=0
   WITH nocounter
  ;end select
  IF (curqual=0
   AND cnvtupper(curuser) != "P30INS")
   CALL end_status(concat("Current user, ",curuser,", does not have CCL DBA privileges required",
     " to run ocd_incl_schema.  Please contact your system administrator."),env_id,ocd_number)
   GO TO program_end
  ENDIF
 ENDIF
 CALL echo(asterick_line)
 CALL echo("Checking domain setup for OCD installations.")
 CALL echo(asterick_line)
 IF (currdb="ORACLE")
  EXECUTE dm_ocd_bld_adm_list
 ENDIF
 IF (currdb="ORACLE")
  EXECUTE dm_ocd_check_domain
  IF ((((docd_reply->status="F")) OR ((docd_reply->status="L"))) )
   CALL echo(asterick_line)
   CALL echo("Fatal error. This domain is not configured properly for OCD installation.")
   CALL echo("Can't access the dm_environment table in ADMIN from this domain or no rows")
   CALL echo("were found in the dm_environment table.")
   CALL echo(docd_reply->err_msg)
   IF ((docd_reply->status="L"))
    CALL echo("Make sure admin db and Oracle listener are up.")
    CALL echo("Run dm_cdba_synonym if admin dblink shown above is wrong.")
   ENDIF
   CALL echo("To run dm_cdba_synonym, type the following in ccl: dm_cdba_synonym go")
   CALL echo(asterick_line)
   GO TO program_end
  ELSEIF ((docd_reply->status="D"))
   CALL end_status(concat("Another OCD is currently executing OCD setup steps for this domain. ",
     "Please run ocd_incl_schema again in a few minutes."),env_id,ocd_number)
   GO TO program_end
  ELSEIF ((docd_reply->status="Z"))
   CALL echo(asterick_line)
   CALL echo("Performing the steps necessary to install OCDs in this domain.")
   CALL echo(docd_reply->err_msg)
   CALL echo(asterick_line)
   IF (call_script != "DM_OCD_MENU")
    EXECUTE dm_set_env_id
   ENDIF
   SET message = nowindow
   CALL start_status("Setting up synoyms necessary for OCDs.",env_id,ocd_number)
   EXECUTE dm_ocd_create_synonyms
   IF ((docd_reply->status="F"))
    CALL echo(asterick_line)
    CALL echo("Fatal error. This domain is not configured properly for OCD installation.")
    CALL echo(docd_reply->err_msg)
    CALL echo(asterick_line)
    GO TO program_end
   ENDIF
   EXECUTE dm_add_cki_cv
   EXECUTE dm_ocd_fix_tables_doc_local
   CALL end_status("Domain setup completed.",env_id,ocd_number)
  ELSE
   IF (call_script != "DM_OCD_MENU")
    EXECUTE dm_set_env_id
    SET message = nowindow
   ENDIF
  ENDIF
 ELSE
  EXECUTE dm2_ocd_val_domain
  IF ((dm_err->err_ind=1))
   GO TO program_end
  ENDIF
  IF (call_script != "DM_OCD_MENU")
   IF (dm2_set_autocommit(1)=0)
    GO TO program_end
   ENDIF
   EXECUTE dm_set_env_id
   SET message = nowindow
   IF (dm2_set_autocommit(0)=0)
    GO TO program_end
   ENDIF
  ENDIF
 ENDIF
 EXECUTE FROM initialize2 TO initialize2_end
 IF (currdb="ORACLE")
  SET docd_reply->status = "F"
  CALL start_status("Checking for recent space summary report...",env_id,ocd_number)
  EXECUTE dm_ocd_space_report_check
  SET message = nowindow
  IF ((docd_reply->status="S"))
   CALL end_status("Recent space summary report found",env_id,ocd_number)
  ELSEIF ((docd_reply->status IN ("C", "Q")))
   CALL end_status(concat("Recent space summary report not found! ",docd_reply->err_msg),env_id,
    ocd_number)
   IF ((docd_reply->status="Q"))
    GO TO program_end
   ENDIF
  ENDIF
 ENDIF
 CALL start_status(concat("Executing in ",ocd_install_mode," mode."),env_id,ocd_number)
 IF (call_script="DM_OCD_MENU")
  CALL start_status("Running from DM_OCD_MENU",env_id,ocd_number)
 ENDIF
 CASE (cnvtupper(trim(ocd_install_mode,3)))
  OF "PREVIEW":
   CALL check_include_ccl_step(0)
   CALL install_schema_step(cnvtupper(ocd_install_mode))
   CALL readme_estimate_step(0)
   CALL disp_tasks_step("P")
  OF "UPTIME":
   IF (currdb="SQLSRV")
    SET ocd_install_mode = "UTSCHEMA"
    CALL install_schema_step("UPTIME")
   ELSE
    CALL check_include_ccl_step(0)
    CALL readme_estimate_step(0)
    CALL code_value_step(main_dummy)
    CALL readme_step("PREUP")
    CALL install_schema_step(cnvtupper(ocd_install_mode))
    CALL atr_step(main_dummy)
    CALL disp_tasks_step("R")
    CALL readme_step("POSTUP")
   ENDIF
  OF "DOWNTIME":
   CALL readme_estimate_step(0)
   CALL readme_step("PREDOWN")
   CALL install_schema_step(cnvtupper(ocd_install_mode))
   CALL dm_util_steps(main_dummy)
   CALL readme_step("POSTDOWN")
  OF "POSTINST":
   CALL readme_estimate_step(0)
   CALL readme_step("UP")
  OF "MANUAL":
   CALL check_include_ccl_step(0)
   CALL readme_estimate_step(0)
   CALL code_value_step(main_dummy)
   CALL readme_step("PREUP")
   CALL install_schema_step("UPTIME")
   CALL atr_step(main_dummy)
   CALL disp_tasks_step("R")
   CALL readme_step("POSTUP")
   CALL readme_step("PREDOWN")
   CALL install_schema_step("DOWNTIME")
   CALL dm_util_steps(main_dummy)
   CALL readme_step("POSTDOWN")
   CALL readme_step("UP")
  OF "EXPRESS":
   CALL check_include_ccl_step(0)
   CALL readme_estimate_step(0)
   CALL code_value_step(main_dummy)
   CALL readme_step("PREUP")
   CALL install_schema_step("UPTIME")
   CALL atr_step(main_dummy)
   CALL disp_tasks_step("R")
   CALL readme_step("POSTUP")
   CALL readme_step("PREDOWN")
   CALL install_schema_step("DOWNTIME")
   CALL dm_util_steps(main_dummy)
   CALL readme_step("POSTDOWN")
   CALL readme_step("UP")
  OF "MANUALNOLOAD":
   CALL readme_estimate_step(0)
   CALL code_value_step(main_dummy)
   CALL readme_step("PREUP")
   CALL install_schema_step("UPTIME")
   CALL atr_step(main_dummy)
   CALL disp_tasks_step("R")
   CALL readme_step("POSTUP")
   CALL readme_step("PREDOWN")
   CALL install_schema_step("DOWNTIME")
   CALL dm_util_steps(main_dummy)
   CALL readme_step("POSTDOWN")
   CALL readme_step("UP")
  OF "SCHEMA":
   CALL install_schema_step("UPTIME")
   CALL install_schema_step("DOWNTIME")
   CALL dm_util_steps(main_dummy)
  OF "UTSCHEMA":
   CALL install_schema_step("UPTIME")
  OF "DTSCHEMA":
   CALL install_schema_step("DOWNTIME")
   CALL dm_util_steps(main_dummy)
  OF "PREREADME":
   CALL readme_step("PRE")
  OF "LOAD":
   CALL check_include_ccl_step(0)
  OF "DIFF":
   CALL install_schema_step("PREVIEW")
  OF "POSTREADME":
   CALL readme_step("POST")
  OF "CS":
   CALL code_value_step(main_dummy)
  OF "ATR":
   CALL atr_step(main_dummy)
   CALL disp_tasks_step("R")
  OF "PREUTS":
   CALL readme_estimate_step(0)
   CALL readme_step("PREUP")
  OF "POSTUTS":
   CALL readme_estimate_step(0)
   CALL readme_step("POSTUP")
  OF "PREDTS":
   CALL readme_estimate_step(0)
   CALL readme_step("PREDOWN")
  OF "POSTDTS":
   CALL readme_estimate_step(0)
   CALL readme_step("POSTDOWN")
  OF "CHECK":
   SELECT INTO "nl:"
    FROM dm_alpha_features daf
    WHERE daf.alpha_feature_nbr=ocd_number
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL display_msg("CHECK mode failed because package has not been loaded.","NONE")
    GO TO program_end
   ENDIF
   CALL install_schema_step("CHECK")
  OF "BATCHCHECK":
   IF (currdb IN ("DB2UDB", "SQLSRV"))
    CALL display_msg(concat(cnvtupper(trim(ocd_install_mode,3)),
      " mode is currently not supported for this RDBMS."),"NONE")
    GO TO program_end
   ENDIF
   SELECT INTO "nl:"
    FROM dm_alpha_features daf
    WHERE daf.alpha_feature_nbr=batch_package_number
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL display_msg("BATCHCHECK mode failed because install plan has not been created.","NONE")
    GO TO program_end
   ENDIF
   CALL install_schema_step("CHECK")
  OF "BATCHPREVIEW":
   IF (currdb IN ("DB2UDB", "SQLSRV"))
    CALL display_msg(concat(cnvtupper(trim(ocd_install_mode,3)),
      " mode is currently not supported for this RDBMS."),"NONE")
    GO TO program_end
   ENDIF
   CALL batch_include_ccl_step(0)
   SELECT INTO "nl:"
    FROM dm_alpha_features daf
    WHERE daf.alpha_feature_nbr=batch_package_number
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET create_batch = batch_afd_rows_step(0)
    IF ( NOT (create_batch))
     GO TO program_end
    ENDIF
   ENDIF
   CALL install_schema_step("PREVIEW")
   CALL readme_estimate_step(0)
   CALL disp_tasks_step("P")
  OF "BATCHUP":
   IF (currdb IN ("DB2UDB", "SQLSRV"))
    CALL display_msg(concat(cnvtupper(trim(ocd_install_mode,3)),
      " mode is currently not supported for this RDBMS."),"NONE")
    GO TO program_end
   ENDIF
   CALL batch_include_ccl_step(0)
   SELECT INTO "nl:"
    "X"
    FROM dm_alpha_features daf
    WHERE daf.alpha_feature_nbr=batch_package_number
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET create_batch = batch_afd_rows_step(0)
    IF ( NOT (create_batch))
     GO TO program_end
    ENDIF
   ENDIF
   CALL readme_estimate_step(0)
   IF ( NOT (batch_populate_install_log(olo_readme_report)))
    GO TO program_end
   ENDIF
   CALL code_value_step(main_dummy)
   IF ( NOT (batch_populate_install_log(olo_code_sets)))
    GO TO program_end
   ENDIF
   CALL readme_step("PREUP")
   IF ( NOT (batch_populate_install_log(olo_pre_uts)))
    GO TO program_end
   ENDIF
   IF ( NOT (batch_populate_readme_log(0)))
    GO TO program_end
   ENDIF
   CALL install_schema_step("UPTIME")
   IF ( NOT (batch_populate_install_log(olo_uptime_schema)))
    GO TO program_end
   ENDIF
   CALL atr_step(main_dummy)
   CALL disp_tasks_step("R")
   IF ( NOT (batch_populate_install_log(olo_atrs)))
    GO TO program_end
   ENDIF
   CALL readme_step("POSTUP")
   IF ( NOT (batch_populate_install_log(olo_post_uts)))
    GO TO program_end
   ENDIF
   IF ( NOT (batch_populate_readme_log(0)))
    GO TO program_end
   ENDIF
  OF "BATCHDOWN":
   IF (currdb IN ("DB2UDB", "SQLSRV"))
    CALL display_msg(concat(cnvtupper(trim(ocd_install_mode,3)),
      " mode is currently not supported for this RDBMS."),"NONE")
    GO TO program_end
   ENDIF
   CALL readme_estimate_step(0)
   IF ( NOT (batch_populate_install_log(olo_readme_report)))
    GO TO program_end
   ENDIF
   CALL readme_step("PREDOWN")
   IF ( NOT (batch_populate_install_log(olo_pre_dts)))
    GO TO program_end
   ENDIF
   IF ( NOT (batch_populate_readme_log(0)))
    GO TO program_end
   ENDIF
   CALL install_schema_step("DOWNTIME")
   IF ( NOT (batch_populate_install_log(olo_downtime_schema)))
    GO TO program_end
   ENDIF
   CALL dm_util_steps(main_dummy)
   CALL readme_step("POSTDOWN")
   IF ( NOT (batch_populate_install_log(olo_post_dts)))
    GO TO program_end
   ENDIF
   IF ( NOT (batch_populate_readme_log(0)))
    GO TO program_end
   ENDIF
  OF "BATCHPOST":
   IF (currdb IN ("DB2UDB", "SQLSRV"))
    CALL display_msg(concat(cnvtupper(trim(ocd_install_mode,3)),
      " mode is currently not supported for this RDBMS."),"NONE")
    GO TO program_end
   ENDIF
   CALL readme_estimate_step(0)
   CALL readme_step("UP")
   IF ( NOT (batch_populate_install_log(olo_post_inst)))
    GO TO program_end
   ENDIF
   IF ( NOT (batch_populate_readme_log(0)))
    GO TO program_end
   ENDIF
  OF "UTBATCH":
   IF (currdb IN ("DB2UDB", "SQLSRV"))
    CALL display_msg(concat(cnvtupper(trim(ocd_install_mode,3)),
      " mode is currently not supported for this RDBMS."),"NONE")
    GO TO program_end
   ENDIF
   CALL install_schema_step("UPTIME")
   IF ( NOT (batch_populate_install_log(olo_uptime_schema)))
    GO TO program_end
   ENDIF
  OF "BATCHEXPRESS":
   IF (currdb IN ("DB2UDB", "SQLSRV"))
    CALL display_msg(concat(cnvtupper(trim(ocd_install_mode,3)),
      " mode is currently not supported for this RDBMS."),"NONE")
    GO TO program_end
   ENDIF
   CALL batch_include_ccl_step(0)
   SELECT INTO "nl:"
    FROM dm_alpha_features daf
    WHERE daf.alpha_feature_nbr=batch_package_number
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET create_batch = batch_afd_rows_step(0)
    IF ( NOT (create_batch))
     GO TO program_end
    ENDIF
   ENDIF
   CALL readme_estimate_step(0)
   IF ( NOT (batch_populate_install_log(olo_readme_report)))
    GO TO program_end
   ENDIF
   CALL code_value_step(main_dummy)
   IF ( NOT (batch_populate_install_log(olo_code_sets)))
    GO TO program_end
   ENDIF
   CALL readme_step("PREUP")
   IF ( NOT (batch_populate_install_log(olo_pre_uts)))
    GO TO program_end
   ENDIF
   IF ( NOT (batch_populate_readme_log(0)))
    GO TO program_end
   ENDIF
   CALL install_schema_step("UPTIME")
   IF ( NOT (batch_populate_install_log(olo_uptime_schema)))
    GO TO program_end
   ENDIF
   CALL atr_step(main_dummy)
   CALL disp_tasks_step("R")
   IF ( NOT (batch_populate_install_log(olo_atrs)))
    GO TO program_end
   ENDIF
   CALL readme_step("POSTUP")
   IF ( NOT (batch_populate_install_log(olo_post_uts)))
    GO TO program_end
   ENDIF
   IF ( NOT (batch_populate_readme_log(0)))
    GO TO program_end
   ENDIF
   CALL readme_step("PREDOWN")
   IF ( NOT (batch_populate_install_log(olo_pre_dts)))
    GO TO program_end
   ENDIF
   IF ( NOT (batch_populate_readme_log(0)))
    GO TO program_end
   ENDIF
   CALL install_schema_step("DOWNTIME")
   IF ( NOT (batch_populate_install_log(olo_downtime_schema)))
    GO TO program_end
   ENDIF
   CALL dm_util_steps(main_dummy)
   CALL readme_step("POSTDOWN")
   IF ( NOT (batch_populate_install_log(olo_post_dts)))
    GO TO program_end
   ENDIF
   IF ( NOT (batch_populate_readme_log(0)))
    GO TO program_end
   ENDIF
   CALL readme_step("UP")
   IF ( NOT (batch_populate_install_log(olo_post_inst)))
    GO TO program_end
   ENDIF
   IF ( NOT (batch_populate_readme_log(0)))
    GO TO program_end
   ENDIF
  OF "BATCHSCHEMA":
   IF (currdb IN ("DB2UDB", "SQLSRV"))
    CALL display_msg(concat(cnvtupper(trim(ocd_install_mode,3)),
      " mode is currently not supported for this RDBMS."),"NONE")
    GO TO program_end
   ENDIF
   CALL install_schema_step("UPTIME")
   IF ( NOT (batch_populate_install_log(olo_uptime_schema)))
    GO TO program_end
   ENDIF
   CALL install_schema_step("DOWNTIME")
   IF ( NOT (batch_populate_install_log(olo_downtime_schema)))
    GO TO program_end
   ENDIF
   CALL dm_util_steps(main_dummy)
  OF "DTBATCH":
   IF (currdb IN ("DB2UDB", "SQLSRV"))
    CALL display_msg(concat(cnvtupper(trim(ocd_install_mode,3)),
      " mode is currently not supported for this RDBMS."),"NONE")
    GO TO program_end
   ENDIF
   CALL install_schema_step("DOWNTIME")
   IF ( NOT (batch_populate_install_log(olo_downtime_schema)))
    GO TO program_end
   ENDIF
   CALL dm_util_steps(main_dummy)
  ELSE
   CALL end_status(concat(ocd_install_mode,": unknown mode of OCD installation! OCD not installed."),
    env_id,ocd_number)
   GO TO program_end
 ENDCASE
 IF (ocd_install_mode IN ("DIFF", "PREVIEW", "BATCHPREVIEW", "CHECK", "BATCHCHECK"))
  CALL end_status(concat(ocd_install_mode,
    " mode successful! If no diff report was displayed, no schema differences found."),env_id,
   ocd_number)
 ELSE
  IF (currdb IN ("DB2UDB", "SQLSRV"))
   CALL end_status(concat(" Logfile name for this execution was : ",dm_err->logfile,
     " and can be found in CCLUSERDIR."),env_id,ocd_number)
  ENDIF
  IF (ocd_install_mode="*BATCH*")
   CALL end_status(concat(ocd_install_mode," mode install of Install Plan ",trim(cnvtstring(abs(
        ocd_number)))," successful!"),env_id,ocd_number)
  ELSE
   CALL end_status(concat(ocd_install_mode," mode install of Package ",ocd_string," successful!"),
    env_id,ocd_number)
  ENDIF
 ENDIF
 IF (cnvtupper(trim(ocd_install_mode,3))="PREVIEW")
  CALL del_preview_step(env_id,ocd_number)
 ENDIF
 IF (cnvtupper(trim(ocd_install_mode,3))="BATCHPREVIEW")
  FOR (d_item = 1 TO size(batch_list->qual,5))
    SET ocd_number = batch_list->qual[d_item].package_number
    SET ocd_string = cnvtstring(batch_list->qual[d_item].package_number)
    SET ocd_string_padded = format(ocd_string,"######;P0")
    CALL del_preview_step(env_id,ocd_number)
  ENDFOR
  SET ocd_number = batch_package_number
  SET ocd_string = trim(cnvtstring(batch_package_number))
  IF (batch_package_number < 0)
   SET ocd_string_padded = build("-",format(abs(batch_package_number),"######;P0"))
  ELSE
   CALL display_msg("Fatal Error: Install Plan was not a valid number.","NONE")
   GO TO program_end
  ENDIF
  CALL del_preview_step(env_id,ocd_number)
 ENDIF
 GO TO program_end
#main_end
 SUBROUTINE install_schema_step(schema_install_mode)
   CASE (schema_install_mode)
    OF "PREVIEW":
     SET ocd_op->pre_op = olo_load_ccl_file
     SET ocd_op->cur_op = olo_schema_report
     SET ocd_op->msg = "Attempting to display schema reports.."
    OF "UPTIME":
     SET ocd_op->pre_op = olo_pre_uts
     SET ocd_op->cur_op = olo_uptime_schema
     SET ocd_op->msg = "Attempting to install uptime schema.."
     SET ocd_op->next_op = olo_atrs
    OF "DOWNTIME":
     SET ocd_op->pre_op = olo_pre_dts
     SET ocd_op->cur_op = olo_downtime_schema
     SET ocd_op->msg = "Attempting to install downtime schema.."
     SET ocd_op->next_op = olo_post_dts
    OF "CHECK":
     SET ocd_op->pre_op = olo_none
     SET ocd_op->cur_op = olo_schema_report
     SET ocd_op->msg = "Attempting to display schema reports..."
   ENDCASE
   IF (currdb != "SQLSRV")
    IF (dm_ocd_chk_op(ocd_op->pre_op)=0)
     CALL dm_ocd_bad_op(ocd_op->cur_op,ocd_op->pre_op)
     GO TO program_end
    ENDIF
   ENDIF
   CALL dm_ocd_log_op(ocd_op->cur_op,ols_start,ocd_op->msg)
   CASE (schema_install_mode)
    OF "PREVIEW":
     CALL start_status("Attempting to preview schema...",env_id,ocd_number)
    OF "UPTIME":
     CALL start_status("Attempting to install uptime schema...",env_id,ocd_number)
    OF "DOWNTIME":
     CALL start_status("Attempting to install schema...",env_id,ocd_number)
   ENDCASE
   IF (currdb IN ("DB2UDB", "SQLSRV"))
    IF (schema_install_mode != "DOWNTIME")
     IF (dm2_setup_step(null)=0)
      CALL dm_ocd_log_op(ocd_op->cur_op,ols_error,"Failed checking for DM2 schema files!")
      CALL start_status("Failed checking for DM2 schema files!",env_id,ocd_number)
      SET docd_reply->err_msg = concat(" Log file ",dm_err->logfile,
       " can be used to view more details.")
      CALL end_status(docd_reply->err_msg,env_id,ocd_number)
      GO TO program_end
     ENDIF
     IF (dm2_schema_files_exist=1)
      IF (cursys="AIX")
       DECLARE ois_cmd = vc
       IF (findfile(concat(dm2_install_schema->ccluserdir,"dm2o",ocd_string_padded,"_h.dat"))=1)
        SET ois_cmd = concat("rm -f ",dm2_install_schema->ccluserdir,"dm2o",ocd_string_padded,"*")
        CALL echo(concat("ois_cmd: ",ois_cmd))
        IF (dm2_push_dcl(ois_cmd)=0)
         CALL dm_ocd_log_op(ocd_op->cur_op,ols_error,"Failed copying DM2 schema files!")
         CALL start_status("Failed copying DM2 schema files!",env_id,ocd_number)
         SET docd_reply->err_msg = concat(" Log file ",dm_err->logfile,
          " can be used to view more details.")
         CALL end_status(docd_reply->err_msg,env_id,ocd_number)
         GO TO program_end
        ENDIF
       ENDIF
       SET ois_cmd = concat("cp -f ",trim(cerocd),"/",ocd_string_padded,"/dm2o",
        ocd_string_padded,"*"," ",dm2_install_schema->ccluserdir)
       IF (dm2_push_dcl(ois_cmd)=0)
        CALL dm_ocd_log_op(ocd_op->cur_op,ols_error,"Failed copying DM2 schema files!")
        CALL start_status("Failed copying DM2 schema files!",env_id,ocd_number)
        SET docd_reply->err_msg = concat(" Log file ",dm_err->logfile,
         " can be used to view more details.")
        CALL end_status(docd_reply->err_msg,env_id,ocd_number)
        GO TO program_end
       ENDIF
       SET ois_cmd = concat("chmod 777 ",dm2_install_schema->ccluserdir,"dm2o",ocd_string_padded,"*")
       IF (dm2_push_dcl(ois_cmd)=0)
        CALL dm_ocd_log_op(ocd_op->cur_op,ols_error,
         "Failed modifying permissions on DM2 schema files!")
        CALL start_status("Failed modifying permissions on DM2 schema files!",env_id,ocd_number)
        SET docd_reply->err_msg = concat(" Log file ",dm_err->logfile,
         " can be used to view more details.")
        CALL end_status(docd_reply->err_msg,env_id,ocd_number)
        GO TO program_end
       ENDIF
      ENDIF
      DECLARE dm2_is_mode = vc
      DECLARE dm2_dbname = vc
      DECLARE dm2_cnnct_str = vc
      CASE (schema_install_mode)
       OF "PREVIEW":
        SET dm2_is_mode = "PREVIEW"
       OF "UPTIME":
        SET dm2_is_mode = "CLIN UPGRADE"
      ENDCASE
      IF (currdb="SQLSRV")
       SET dm2_dbname = currdbname
       SET dm2_cnnct_str = currdblink
      ELSE
       SET dm2_dbname = currdblink
       SET dm2_cnnct_str = "NONE"
      ENDIF
      EXECUTE dm2_install_schema dm2_is_mode, ocd_string_padded, dm2_dbname,
      "NONE", "NONE", dm2_install_schema->v500_p_word,
      dm2_cnnct_str
      IF ((dm_err->err_ind=0)
       AND ((schema_install_mode="PREVIEW") OR ((tgtsch->diff_ind=0))) )
       CALL dm_ocd_log_op(ocd_op->cur_op,ols_complete,concat(schema_install_mode,
         " schema successful."))
       CALL end_status(concat(schema_install_mode," schema successful."),env_id,ocd_number)
       SET schema_diff_ind = 0
       RETURN(0)
      ELSE
       CALL dm_ocd_log_op(ocd_op->cur_op,ols_error,concat(schema_install_mode," schema failed!"))
       CALL start_status(concat(schema_install_mode," schema FAILED!"),env_id,ocd_number)
       SET docd_reply->err_msg = concat(" Log file ",dm_err->logfile,
        " can be used to view more details.")
       CALL end_status(docd_reply->err_msg,env_id,ocd_number)
       GO TO program_end
      ENDIF
     ELSE
      CALL dm_ocd_log_op(ocd_op->cur_op,ols_complete,"No schema to install for this package.")
      CALL end_status("No schema to install for this package.",env_id,ocd_number)
     ENDIF
    ELSE
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_complete,"No downtime schema to install.")
     CALL end_status("No downtime schema to install.",env_id,ocd_number)
    ENDIF
   ELSEIF (currdb="ORACLE")
    SELECT INTO "nl:"
     d.table_name
     FROM dm_afd_tables d
     WHERE d.alpha_feature_nbr=ocd_number
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_complete,"No schema to install for this OCD")
     CALL start_status("No schema to install for this OCD.",env_id,ocd_number)
     SET no_schema_ind = 1
     RETURN(0)
    ENDIF
    SET install_schema_status = exec_install_schema(schema_install_mode)
    CASE (install_schema_status)
     OF "F":
      CALL start_status("Fatal error encountered during dm_install_schema2",env_id,ocd_number)
      CALL end_status(docd_reply->err_msg,env_id,ocd_number)
      CALL dm_ocd_log_op(ocd_op->cur_op,ols_error,docd_reply->err_msg)
      GO TO program_end
     OF "C":
      CALL start_status("Fatal error while checking tablespace sizes.",env_id,ocd_number)
      CALL end_status(docd_reply->err_msg,env_id,ocd_number)
      CALL dm_ocd_log_op(ocd_op->cur_op,ols_error,docd_reply->err_msg)
      GO TO program_end
     OF "D":
      CALL start_status(docd_reply->err_msg,env_id,ocd_number)
      CALL dm_ocd_log_op(ocd_op->cur_op,ols_running,"Only downtime schema differences exist")
      SET schema_diff_ind = 1
     OF "U":
      CALL start_status(docd_reply->err_msg,env_id,ocd_number)
      CALL dm_ocd_log_op(ocd_op->cur_op,ols_running,"Only uptime schema differences exist")
      SET schema_diff_ind = 1
     OF "B":
      CALL start_status(docd_reply->err_msg,env_id,ocd_number)
      CALL dm_ocd_log_op(ocd_op->cur_op,ols_running,"Uptime and downtime schema differences exist")
      SET schema_diff_ind = 1
     OF "N":
      CALL start_status(docd_reply->err_msg,env_id,ocd_number)
      CALL dm_ocd_log_op(ocd_op->cur_op,ols_running,"No schema differences found")
      SET schema_diff_ind = 0
     OF "W":
      CALL start_status(docd_reply->err_msg,env_id,ocd_number)
      CALL dm_ocd_log_op(ocd_op->cur_op,ols_running,
       "No schema differences found; some warnings exist")
      SET schema_diff_ind = 0
     ELSE
      CALL start_status(build("ERROR! (",install_schema_status,
        ") UKNOWN RETURN STATUS FROM DM_INSTALL_SCHEMA"),env_id,ocd_number)
      CALL echo("**")
      CALL echo("**")
      CALL echo(build("ERROR! (",install_schema_status,
        ") UKNOWN RETURN STATUS FROM DM_INSTALL_SCHEMA"))
      CALL echo("**")
      CALL echo("**")
    ENDCASE
    IF (cnvtupper(schema_install_mode) IN ("PREVIEW", "BATCHPREVIEW", "CHECK", "BATCHCHECK"))
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_complete,concat(cnvtupper(schema_install_mode),
       " mode complete"))
     RETURN(0)
    ENDIF
    IF (check_schema_ddl_files(0))
     CALL start_status("Executing DDL files now...",env_id,ocd_number)
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_running,"Executing DDL files now...")
     SET runner_ocd = fs_proc->ocd_number
     EXECUTE dm_ocd_schema_runner
     CALL wait_schema_ddl_files(0)
    ENDIF
    CALL start_status("Updating CCL definition of all tables on this OCD",env_id,ocd_number)
    CALL dm_ocd_log_op(ocd_op->cur_op,ols_running,"Updating CCL definition of all tables on this OCD"
     )
    EXECUTE dm_ocd_oragen_all ocd_number
    IF (validate(dm_err->err_ind,- (1)) > 0)
     SET ois_tmp_msg = fillstring(255," ")
     SET ois_tmp_msg = concat(
      "Installation Failed. See the following log file in CCLUSERDIR for details: ",dm_err->logfile)
     CALL end_status(ois_tmp_msg,env_id,ocd_number)
     GO TO program_end
    ENDIF
    CALL end_status("Finished updating CCL definition of all tables on this OCD",env_id,ocd_number)
    CALL start_status("Compiling invalid objects",env_id,ocd_number)
    EXECUTE dm_ocd_compile_objects value(ocd_number)
    CALL start_status("Finished compiling invalid objects",env_id,ocd_number)
    IF (install_schema_status="N")
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_complete,concat(schema_install_mode," mode complete. ",
       "No schema differences found."))
     RETURN(0)
    ELSEIF (install_schema_status="W")
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_complete,concat(schema_install_mode," mode complete. ",
       "No schema differences found. Some warnings exist."))
     RETURN(0)
    ENDIF
    CALL start_status("Checking schema install...",env_id,ocd_number)
    CALL dm_ocd_log_op(ocd_op->cur_op,ols_running,"Checking schema install...")
    SET check_schema_status = exec_install_schema("CHECK")
    CASE (check_schema_status)
     OF "F":
      CALL start_status("Fatal error encountered while checking schema.",env_id,ocd_number)
      CALL end_status(docd_reply->err_msg,env_id,ocd_number)
      CALL dm_ocd_log_op(ocd_op->cur_op,ols_error,docd_reply->err_msg)
      GO TO program_end
     OF "C":
      CALL start_status("Fatal error while checking tablespace sizes.",env_id,ocd_number)
      CALL end_status(docd_reply->err_msg,env_id,ocd_number)
      CALL dm_ocd_log_op(ocd_op->cur_op,ols_error,docd_reply->err_msg)
      GO TO program_end
     OF "D":
      CASE (schema_install_mode)
       OF "UPTIME":
        CALL dm_ocd_log_op(ocd_op->cur_op,ols_complete,
         "Uptime schema install successful. Only downtime schema differences exist")
        CALL end_status("Uptime schema installed successfully",env_id,ocd_number)
       OF "DOWNTIME":
        CALL dm_ocd_log_op(ocd_op->cur_op,ols_error,
         "Downtime schema install failed! Downtime schema differences remain")
        CALL start_status("Downtime schema install FAILED!",env_id,ocd_number)
        SET docd_reply->err_msg = concat(docd_reply->err_msg," Please use 'dm_ocd_schema_log ",trim(
          cnvtstring(ocd_number))," go' to view schema errors.")
        CALL end_status(docd_reply->err_msg,env_id,ocd_number)
        GO TO program_end
      ENDCASE
     OF "U":
      CASE (schema_install_mode)
       OF "UPTIME":
        CALL dm_ocd_log_op(ocd_op->cur_op,ols_complete,
         "Uptime schema install failed! Uptime schema differences remain")
        CALL start_status("Uptime schema install FAILED!",env_id,ocd_number)
        SET docd_reply->err_msg = concat(docd_reply->err_msg," Please use 'dm_ocd_schema_log ",trim(
          cnvtstring(ocd_number))," go' to view schema errors.")
        CALL end_status(docd_reply->err_msg,env_id,ocd_number)
        GO TO program_end
       OF "DOWNTIME":
        CALL dm_ocd_log_op(ocd_op->cur_op,ols_error,
         "Downtime schema install failed! Uptime schema differences remain")
        CALL start_status("Downtime schema install FAILED!",env_id,ocd_number)
        SET docd_reply->err_msg = concat(docd_reply->err_msg," Please use 'dm_ocd_schema_log ",trim(
          cnvtstring(ocd_number))," go' to view schema errors.")
        CALL end_status(docd_reply->err_msg,env_id,ocd_number)
        GO TO program_end
      ENDCASE
     OF "B":
      CASE (schema_install_mode)
       OF "UPTIME":
        CALL dm_ocd_log_op(ocd_op->cur_op,ols_complete,
         "Uptime schema install failed! Uptime/Downtime schema differences remain")
        CALL start_status("Uptime schema install FAILED!",env_id,ocd_number)
        SET docd_reply->err_msg = concat(docd_reply->err_msg," Please use 'dm_ocd_schema_log ",trim(
          cnvtstring(ocd_number))," go' to view schema errors.")
        CALL end_status(docd_reply->err_msg,env_id,ocd_number)
        GO TO program_end
       OF "DOWNTIME":
        CALL dm_ocd_log_op(ocd_op->cur_op,ols_error,
         "Downtime schema install failed! Uptime/Downtime schema differences remain")
        CALL start_status("Downtime schema install FAILED!",env_id,ocd_number)
        SET docd_reply->err_msg = concat(docd_reply->err_msg," Please use 'dm_ocd_schema_log ",trim(
          cnvtstring(ocd_number))," go' to view schema errors.")
        CALL end_status(docd_reply->err_msg,env_id,ocd_number)
        GO TO program_end
      ENDCASE
     OF "N":
      IF (cnvtupper(schema_install_mode) IN ("UPTIME", "DOWNTIME"))
       CALL dm_ocd_log_op(ocd_op->cur_op,ols_complete,concat(schema_install_mode,
         " schema install successful. ","No schema differences found"))
       CALL end_status(build(schema_install_mode," Schema install successful"),env_id,ocd_number)
      ENDIF
     OF "W":
      IF (cnvtupper(schema_install_mode) IN ("UPTIME", "DOWNTIME"))
       CALL dm_ocd_log_op(ocd_op->cur_op,ols_complete,concat(schema_install_mode,
         " schema install successful. ","No schema differences found; some warnings exist"))
       CALL end_status(build(schema_install_mode," Schema install successful"),env_id,ocd_number)
      ENDIF
     ELSE
      CALL start_status(build("ERROR! (",check_schema_status,
        ") UKNOWN RETURN STATUS FROM DM_INSTALL_SCHEMA"),env_id,ocd_number)
      CALL echo("**")
      CALL echo("**")
      CALL echo(build("ERROR! (",check_schema_status,") UKNOWN RETURN STATUS FROM DM_INSTALL_SCHEMA")
       )
      CALL echo("**")
      CALL echo("**")
    ENDCASE
   ENDIF
 END ;Subroutine
 SUBROUTINE exec_install_schema(inst_sch_mode)
   SET tgt_ocd_str = cnvtstring(ocd_number)
   IF (ocd_number < 0)
    SET ocd_file_prefix = build("bi",abs(ocd_number))
   ELSE
    SET ocd_file_prefix = build("ocd",ocd_number)
   ENDIF
   CALL echo(build("dm_install_schema2 '",ocd_file_prefix,"', '",tgt_ocd_str,"', '",
     inst_sch_mode,"'"))
   EXECUTE dm_install_schema2 ocd_file_prefix, tgt_ocd_str, inst_sch_mode
   RETURN(docd_reply->status)
 END ;Subroutine
 SUBROUTINE code_value_step(dummy)
   IF (cnvtupper(trim(ocd_install_mode,3))="MANUALNOLOAD")
    SET ocd_op->pre_op = olo_none
    SET ocd_op->cur_op = olo_code_sets
    SET ocd_op->next_op = olo_pre_uts
   ELSE
    SET ocd_op->pre_op = olo_load_ccl_file
    SET ocd_op->cur_op = olo_code_sets
    SET ocd_op->next_op = olo_pre_uts
    IF (dm_ocd_chk_op(ocd_op->pre_op)=0)
     CALL dm_ocd_bad_op(ocd_op->cur_op,ocd_op->pre_op)
     GO TO program_end
    ENDIF
   ENDIF
   CALL dm_ocd_log_op(ocd_op->cur_op,ols_start,"Checking for code sets on this OCD...")
   CALL start_status("Checking to see if this OCD has any code sets on it",env_id,ocd_number)
   SET code_values_exist = 0
   SELECT INTO "nl:"
    FROM dm_afd_code_value_set dacvs
    WHERE dacvs.alpha_feature_nbr=ocd_number
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL dm_ocd_log_op(ocd_op->cur_op,ols_complete,"No code sets found on this OCD")
    CALL end_status("No code sets found on this OCD.",env_id,ocd_number)
    SET docd_reply->status = "0"
   ELSE
    CALL end_status("Code sets found on this OCD.",env_id,ocd_number)
    SET docd_reply->status = "S"
   ENDIF
   IF ((docd_reply->status="S"))
    SET include_file_name = build("ccluserdir:dm_ocd_install_cvs_",ocd_string,".dat")
    CALL dm_ocd_log_op(ocd_op->cur_op,ols_running,"Installing CODE_VALUE_SET rows...")
    CALL start_status("Load the CODE_VALUE_SET rows.",env_id,ocd_number)
    SET error_check = error(errormsg,1)
    EXECUTE dm_ocd_install_cvs
    SET error_check = error(errormsg,1)
    IF (error_check != 0)
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_error,concat("Installing CODE_VALUE_SET failed!",trim(
        errormsg)))
     CALL end_status("Error loading CODE_VALUE_SET rows.",env_id,ocd_number)
     CALL end_status(errormsg,env_id,ocd_number)
     SET docd_reply->status = "F"
     GO TO program_end
    ELSE
     SET docd_reply->status = "S"
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_running,"Installing CODE_VALUE_SET complete")
     CALL end_status("Finished loading CODE_VALUE_SET rows.",env_id,ocd_number)
    ENDIF
    SET include_file_name = build("ccluserdir:dm_ocd_install_cdf_",ocd_string,".dat")
    CALL dm_ocd_log_op(ocd_op->cur_op,ols_running,"Installing COMMON_DATA_FOUNDATION rows...")
    CALL start_status("Load the COMMON_DATA_FOUNDATION rows.",env_id,ocd_number)
    SET error_check = error(errormsg,1)
    EXECUTE dm_ocd_install_cdf
    SET error_check = error(errormsg,1)
    IF (error_check != 0)
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_error,concat("Installing COMMON_DATA_FOUNDATION failed!",
       trim(errormsg)))
     CALL end_status("Error loading COMMON_DATA_FOUNDATION rows.",env_id,ocd_number)
     CALL end_status(errormsg,env_id,ocd_number)
     SET docd_reply->status = "F"
     GO TO program_end
    ELSE
     SET docd_reply->status = "S"
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_running,"Installing COMMON_DATA_FOUNDATION complete")
     CALL end_status("Finished loading COMMON_DATA_FOUNDATION rows.",env_id,ocd_number)
    ENDIF
    SET include_file_name = build("ccluserdir:dm_ocd_install_cse_",ocd_string,".dat")
    CALL dm_ocd_log_op(ocd_op->cur_op,ols_running,"Installing CODE_SET_EXTENSION rows...")
    CALL start_status("Load the CODE_SET_EXTENSION rows.",env_id,ocd_number)
    SET error_check = error(errormsg,1)
    EXECUTE dm_ocd_install_cse
    SET error_check = error(errormsg,1)
    IF (error_check != 0)
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_error,concat("Installing CODE_SET_EXTENSION failed!",trim(
        errormsg)))
     CALL end_status("Error loading CODE_SET_EXTENSION rows.",env_id,ocd_number)
     CALL end_status(errormsg,env_id,ocd_number)
     SET docd_reply->status = "F"
     GO TO program_end
    ELSE
     SET docd_reply->status = "S"
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_running,"Installing CODE_SET_EXTENSION complete")
     CALL end_status("Finished loading CODE_SET_EXTENSION rows.",env_id,ocd_number)
    ENDIF
    SET include_file_name = build("ccluserdir:dm_ocd_install_cv_",ocd_string,".dat")
    CALL dm_ocd_log_op(ocd_op->cur_op,ols_running,"Installing CODE_VALUE rows...")
    CALL start_status("Load the CODE_VALUE rows.",env_id,ocd_number)
    SET error_check = error(errormsg,1)
    EXECUTE dm_ocd_install_cv
    SET error_check = error(errormsg,1)
    IF (error_check != 0)
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_error,concat("Installing CODE_VALUE failed!",trim(errormsg
        )))
     CALL end_status("Error loading CODE_VALUE rows.",env_id,ocd_number)
     CALL end_status(errormsg,env_id,ocd_number)
     SET docd_reply->status = "F"
     GO TO program_end
    ELSE
     SET docd_reply->status = "S"
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_running,"Installing CODE_VALUE complete")
     CALL end_status("Finished loading CODE_VALUE rows.",env_id,ocd_number)
    ENDIF
    IF ((docd_reply->status="F"))
     GO TO program_end
    ENDIF
    SET include_file_name = build("ccluserdir:dm_ocd_install_cva_",ocd_string,".dat")
    CALL dm_ocd_log_op(ocd_op->cur_op,ols_running,"Installing CODE_VALUE_ALIAS rows...")
    CALL start_status("Load the CODE_VALUE_ALIAS rows.",env_id,ocd_number)
    SET error_check = error(errormsg,1)
    EXECUTE dm_ocd_install_cva
    SET error_check = error(errormsg,1)
    IF (error_check != 0)
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_error,concat("Installing CODE_VALUE_ALIAS failed!",trim(
        errormsg)))
     CALL end_status("Error loading CODE_VALUE_ALIAS rows.",env_id,ocd_number)
     CALL end_status(errormsg,env_id,ocd_number)
     SET docd_reply->status = "F"
     GO TO program_end
    ELSE
     SET docd_reply->status = "S"
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_running,"Installing CODE_VALUE_ALIAS complete")
     CALL end_status("Finished loading CODE_VALUE_ALIAS rows.",env_id,ocd_number)
    ENDIF
    SET include_file_name = build("ccluserdir:dm_ocd_install_cve_",ocd_string,".dat")
    CALL dm_ocd_log_op(ocd_op->cur_op,ols_running,"Installing CODE_VALUE_EXTENSION rows...")
    CALL start_status("Load the CODE_VALUE_EXTENSION rows.",env_id,ocd_number)
    SET error_check = error(errormsg,1)
    EXECUTE dm_ocd_install_cve
    SET error_check = error(errormsg,1)
    IF (error_check != 0)
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_error,concat("Installing CODE_VALUE_EXTENSION failed!",
       trim(errormsg)))
     CALL end_status("Error loading CODE_VALUE_EXTENSION rows.",env_id,ocd_number)
     CALL end_status(errormsg,env_id,ocd_number)
     SET docd_reply->status = "F"
     GO TO program_end
    ELSE
     SET docd_reply->status = "S"
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_running,"Installing CODE_VALUE_EXTENSION complete")
     CALL end_status("Finished loading CODE_VALUE_EXTENSION rows.",env_id,ocd_number)
    ENDIF
    SET include_file_name = build("ccluserdir:dm_ocd_install_cvg_",ocd_string,".dat")
    CALL dm_ocd_log_op(ocd_op->cur_op,ols_running,"Installing CODE_VALUE_GROUP rows...")
    CALL start_status("Load the CODE_VALUE_GROUP rows.",env_id,ocd_number)
    SET error_check = error(errormsg,1)
    EXECUTE dm_ocd_install_cvg
    SET error_check = error(errormsg,1)
    IF (error_check != 0)
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_error,concat("Installing CODE_VALUE_GROUP failed!",trim(
        errormsg)))
     CALL end_status("Error loading CODE_VALUE_GROUP rows.",env_id,ocd_number)
     CALL end_status(errormsg,env_id,ocd_number)
     SET docd_reply->status = "F"
     GO TO program_end
    ELSE
     SET docd_reply->status = "S"
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_running,"Installing CODE_VALUE_GROUP complete")
     CALL end_status("Finished loading CODE_VALUE_GROUP rows.",env_id,ocd_number)
    ENDIF
    CALL dm_ocd_log_op(ocd_op->cur_op,ols_running,"Checking code sets installation...")
    EXECUTE dm_ocd_cs_error_check
    IF ((docd_reply->status="F"))
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_error,concat("Code sets installation failed!",trim(
        docd_reply->err_msg)))
     CALL end_status(docd_reply->err_msg,env_id,ocd_number)
     GO TO program_end
    ELSE
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_complete,"Code sets installation successful")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE atr_step(dummy)
   SET ocd_op->pre_op = olo_uptime_schema
   SET ocd_op->cur_op = olo_atrs
   SET ocd_op->next_op = olo_post_uts
   IF (dm_ocd_chk_op(ocd_op->pre_op)=0)
    CALL dm_ocd_bad_op(ocd_op->cur_op,ocd_op->pre_op)
    GO TO program_end
   ENDIF
   CALL dm_ocd_log_op(ocd_op->cur_op,ols_start,"Installing ATRs from this OCD...")
   CALL start_status("Installing the ATR rows (Phase1).",env_id,ocd_number)
   EXECUTE dm_ocd_install_atr
   IF ((docd_reply->status="S"))
    CALL dm_ocd_log_op(ocd_op->cur_op,ols_complete,"Installing ATRs (Phase1) successful!")
    CALL end_status("ATR rows (Phase1) installed successfully.",env_id,ocd_number)
   ELSEIF ((docd_reply->status="F"))
    CALL dm_ocd_log_op(ocd_op->cur_op,ols_error,"Installing ATRs (Phase1) failed!")
    CALL end_status("ATR rows (Phase1) were not installed successfully!",env_id,ocd_number)
    GO TO program_end
   ENDIF
   CALL start_status("Installing the ATR rows (Phase2).",env_id,ocd_number)
   EXECUTE dm2_atr_primtosub
   IF ((dm_err->err_ind=1))
    CALL dm_ocd_log_op(ocd_op->cur_op,ols_error,"Error executing dm2_atr_primtosub!")
    CALL end_status("Error executing dm2_atr_primtosub!",env_id,ocd_number)
    GO TO program_end
   ENDIF
   IF ((docd_reply->status="S"))
    CALL dm_ocd_log_op(ocd_op->cur_op,ols_complete,"Installing ATRs (Phase2) successful!")
    CALL end_status("ATR rows (Phase2) installed successfully.",env_id,ocd_number)
   ELSEIF ((docd_reply->status="C"))
    CALL dm_ocd_log_op(ocd_op->cur_op,ols_complete,"Installing ATRs (Phase2) with warnning!")
    CALL end_status("ATR rows (Phase2) installed with warnning.",env_id,ocd_number)
   ELSEIF ((docd_reply->status="F"))
    CALL dm_ocd_log_op(ocd_op->cur_op,ols_error,"Installing ATRs (Phase2) failed!")
    CALL end_status("ATR rows (Phase2) were not installed successfully!",env_id,ocd_number)
    GO TO program_end
   ENDIF
 END ;Subroutine
#initialize
 RECORD docd_reply(
   1 status = c1
   1 err_msg = vc
 )
 SET log_fname = fillstring(132," ")
 SET ocd_string = fillstring(6," ")
 SET ocd_string_padded = fillstring(6," ")
 SET errormsg = fillstring(132," ")
 SET cerocd = logical("cer_ocd")
 SET include_file_name = fillstring(132," ")
 SET asterick_line = fillstring(80,"*")
 SET dash_line = fillstring(80,"-")
 SET env_id = 0
 SET env_name = fillstring(20," ")
 SET sch_ver = 0.000
 SET no_schema_ind = 0
 SET schema_diff_ind = 0
 SET user_sel_load = 0
 FREE RECORD misc
 RECORD misc(
   1 str = vc
 )
 IF (cnvtupper( $2)="*BATCH*")
  FREE RECORD batch_list
  RECORD batch_list(
    1 package_cnt = i4
    1 qual[*]
      2 package_number = f8
      2 rm_qual[*]
        3 readme_id = f8
        3 instance = i4
  )
  SET install_plan_id =  $1
  SET batch_package_number = ( $1 * - (1))
  SET ocd_number = batch_package_number
  SET ocd_string = trim(cnvtstring(batch_package_number))
  IF (batch_package_number < 0)
   SET ocd_string_padded = build("-",format(abs(batch_package_number),"######;P0"))
  ELSE
   CALL display_msg("Fatal Error: Install Plan was not a valid number.","NONE")
   GO TO program_end
  ENDIF
  SET parent_install_mode = cnvtupper( $2)
  SET get_list = get_batch_list(0)
  IF ( NOT (get_list))
   GO TO program_end
  ENDIF
 ELSE
  SET ocd_string = cnvtstring( $1)
  SET ocd_string_padded = format(cnvtstring( $1),"######;P0")
  SET ocd_number =  $1
 ENDIF
 SET fix_schema_include_file = build("dm_ocd_fix_schema2_",ocd_string,".dat")
 SET fix_schema_error_file = build("dm_ocd_fix_schema3_",ocd_string,".dat")
 SET ois_logfilename = concat("ois",ocd_string_padded,"_")
 IF (currdb IN ("DB2UDB", "SQLSRV"))
  IF (check_logfile(ois_logfilename,".log","OCD_INDLUDE_SCHEMA2 LOGFILE")=0)
   GO TO program_end
  ENDIF
 ENDIF
 SET log_fname = trim(build("ocd_schema_",ocd_string,".log"))
 SELECT INTO value(log_fname)
  d.*
  FROM dual d
  DETAIL
   row + 2, curdate"mm/dd/yyyy;;d", " ",
   curtime3"hh:mm;;m", row + 1, "ocd_incl_schema output log",
   row + 1, "Installing schema, code values and ATRs for OCD ", ocd_string,
   row + 3
  WITH nocounter, format = stream, formfeed = none,
   maxrow = 1
 ;end select
 SET ocd_install_mode = cnvtupper( $2)
 IF (validate(call_script,"Z")="Z")
  SET call_script = "OCD_INCL_SCHEMA"
 ENDIF
 SET main_dummy = 0
 SET schema_differences_found = 0
 SET dm2_schema_files_exist = 0
 IF (validate(curdb->tbl_cnt,- (1)) < 0)
  FREE RECORD curdb
  RECORD curdb(
    1 tbl_cnt = i4
    1 tbl[*]
      2 tbl_name = vc
      2 reference_ind = i4
      2 tspace_name = vc
      2 bad_tspace_ind = i2
      2 pct_increase = f8
      2 tbl_col_cnt = i4
      2 init_ext = f8
      2 next_ext = f8
      2 tbl_col[*]
        3 col_name = vc
        3 col_seq = i4
        3 data_type = vc
        3 data_length = i4
        3 data_default = vc
        3 nullable = c1
      2 ind_cnt = i4
      2 ind[*]
        3 ind_name = vc
        3 tspace_name = vc
        3 pct_increase = f8
        3 init_ext = f8
        3 next_ext = f8
        3 unique_ind = i2
        3 ind_col_cnt = i4
        3 ind_col[*]
          4 col_name = vc
          4 col_position = i2
        3 bad_tspace_ind = i2
        3 drop_ind = i2
        3 downtime_ind = i2
        3 rename_ind = i2
        3 temp_name = vc
      2 cons_cnt = i4
      2 cons[*]
        3 cons_name = vc
        3 cons_type = c1
        3 r_constraint_name = vc
        3 parent_table = vc
        3 parent_table_columns = vc
        3 status_ind = i2
        3 cons_col_cnt = i4
        3 cons_col[*]
          4 col_name = vc
          4 col_position = i2
        3 drop_ind = i2
        3 downtime_ind = i2
        3 fk_cnt = i4
        3 fk[*]
          4 tbl_name = vc
          4 cons_name = vc
          4 tbl_ndx = i4
          4 cons_ndx = i4
    1 tspace_cnt = i4
    1 tspace[*]
      2 tspace_name = vc
      2 initial_extent = f8
      2 next_extent = f8
      2 pct_increase = f8
      2 min_extents = f8
      2 max_extents = f8
      2 status = vc
      2 contents = vc
  )
  SET curdb->tbl_cnt = 0
 ENDIF
 IF (validate(tgtdb->tbl_cnt,- (1)) < 0)
  FREE RECORD tgtdb
  RECORD tgtdb(
    1 diff_ind = i2
    1 warn_ind = i2
    1 downtime_ind = i2
    1 tbl_cnt = i4
    1 tbl[*]
      2 tbl_name = vc
      2 new_ind = i2
      2 diff_ind = i2
      2 warn_ind = i2
      2 downtime_ind = i2
      2 uptime_ind = i2
      2 combine_ind = i2
      2 reference_ind = i4
      2 sql_cursor_ind = i2
      2 zero_row_ind = i2
      2 active_trigger_ind = i2
      2 synonym_ind = i2
      2 tspace_name = vc
      2 minimum_extent = f8
      2 tgt_tspace_name = vc
      2 diff_tspace_ind = i2
      2 cur_idx = i4
      2 fname = vc
      2 row_cnt = f8
      2 file_idx = i4
      2 pct_used = i4
      2 pct_free = i4
      2 init_ext = f8
      2 next_ext = f8
      2 size = f8
      2 total_space = f8
      2 free_space = f8
      2 schema_date = dq8
      2 alpha_feature_nbr = i4
      2 tbl_col_cnt = i4
      2 tbl_col[*]
        3 col_name = vc
        3 col_seq = i4
        3 data_type = vc
        3 data_length = i4
        3 data_default = vc
        3 nullable = c1
        3 new_ind = i2
        3 diff_dtype_ind = i2
        3 diff_dlength_ind = i2
        3 diff_nullable_ind = i2
        3 null_to_notnull_ind = i2
        3 diff_default_ind = i2
        3 downtime_ind = i2
        3 cur_idx = i4
      2 ind_cnt = i4
      2 ind[*]
        3 ind_name = vc
        3 tspace_name = vc
        3 minimum_extent = f8
        3 tgt_tspace_name = vc
        3 pct_increase = vc
        3 pct_free = vc
        3 init_ext = f8
        3 next_ext = f8
        3 size = f8
        3 unique_ind = i2
        3 ind_col_cnt = i4
        3 ind_col[*]
          4 col_name = vc
          4 col_position = i2
        3 new_ind = i2
        3 diff_name_ind = i2
        3 diff_unique_ind = i2
        3 diff_col_ind = i2
        3 diff_cons_ind = i2
        3 diff_tspace_ind = i2
        3 build_ind = i2
        3 downtime_ind = i2
        3 cur_idx = i4
        3 rename_ind = i2
        3 temp_name = vc
      2 cons_cnt = i4
      2 cons[*]
        3 cons_name = vc
        3 cons_type = c1
        3 parent_table = vc
        3 status_ind = i2
        3 parent_table_columns = vc
        3 r_constraint_name = vc
        3 cons_col_cnt = i4
        3 cons_col[*]
          4 col_name = vc
          4 col_position = i2
        3 new_ind = i2
        3 diff_name_ind = i2
        3 diff_col_ind = i2
        3 diff_status_ind = i2
        3 diff_parent_ind = i2
        3 diff_ind_ind = i2
        3 build_ind = i2
        3 downtime_ind = i2
        3 cur_idx = i4
        3 fk_cnt = i4
        3 fk[*]
          4 tbl_ndx = i4
          4 cons_ndx = i4
    1 tspace_cnt = i4
    1 tspace[*]
      2 tspace_name = vc
      2 initial_extent = f8
      2 next_extent = f8
      2 pct_increase = f8
      2 weighting = i4
      2 new_ind = i2
      2 cur_idx = i4
    1 sequence_cnt = i4
    1 sequence[*]
      2 seq_name = vc
      2 build_ind = i2
  )
  SET tgtdb->tbl_cnt = 0
 ENDIF
 IF (validate(fs_proc->id,- (1)) < 0)
  FREE RECORD fs_proc
  RECORD fs_proc(
    1 id = f8
    1 file_prefix = vc
    1 target_schema_str = vc
    1 install_mode = vc
    1 schema_date = dq8
    1 ocd_number = i4
    1 ocd_ind = i2
    1 inhouse_ind = i2
    1 inhouse_table_name = vc
    1 online_ind = i2
    1 online_table_name = vc
    1 log_filename = vc
    1 diff_filename = vc
    1 table_filename = vc
    1 tspace_filename = vc
    1 ora_version = i4
    1 ora_complete_version = vc
    1 index_online = c1
    1 col_novalidate = c1
    1 ind_unrecover = c1
    1 freelist_groups = f8
    1 env[1]
      2 id = f8
      2 name = c20
      2 envset_str = vc
      2 connect_str = vc
      2 oper_sys = vc
      2 schema_version = f8
      2 max_file_size = f8
      2 partition_size = f8
      2 db_name = vc
    1 space_summary[1]
      2 report_seq = f8
      2 report_date = dq8
      2 instance_cd = i4
    1 db[1]
      2 name = vc
      2 block_size = f8
  )
  SET fs_proc->id = 0
  FREE RECORD rfiles
  RECORD rfiles(
    1 fcnt = i4
    1 qual[*]
      2 fname = vc
      2 file1com = vc
      2 file1log = vc
      2 file1dcom = vc
      2 file1dlog = vc
      2 file2 = vc
      2 file2d = vc
      2 file3 = vc
      2 file3d = vc
      2 file4 = vc
      2 file4d = vc
      2 ddl_up_ind = i2
      2 ddl_dn_ind = i2
      2 compile_ind = i2
      2 init_up_ind = i2
      2 init_dn_ind = i2
  )
 ENDIF
 IF ( NOT (validate(dm_schema_log,0)))
  FREE SET dm_schema_log
  RECORD dm_schema_log(
    1 env_id = f8
    1 run_id = f8
    1 ocd = i4
    1 schema_date = dq8
    1 operation = vc
    1 file_name = vc
    1 table_name = vc
    1 object_name = vc
    1 column_name = vc
    1 op_id = f8
    1 options = vc
  )
  SELECT INTO "nl:"
   i.info_number
   FROM dm_info i
   WHERE i.info_domain="DATA MANAGEMENT"
    AND i.info_name="DM_ENV_ID"
    AND i.info_number > 0.0
   DETAIL
    dm_schema_log->env_id = i.info_number
   WITH nocounter
  ;end select
 ENDIF
 SUBROUTINE row_count(rc_table)
   SET rc_count = 0
   SELECT INTO "nl:"
    o.row_count
    FROM ref_report_log l,
     ref_report_parms_log p,
     space_objects o,
     ref_instance_id i
    PLAN (l
     WHERE l.report_cd=1
      AND l.end_date IS NOT null)
     JOIN (p
     WHERE (p.report_seq=(l.report_seq+ 0))
      AND p.parm_cd=1)
     JOIN (i
     WHERE (i.environment_id=dm_schema_log->env_id)
      AND cnvtstring(i.instance_cd)=p.parm_value)
     JOIN (o
     WHERE o.segment_name=rc_table
      AND ((o.report_seq+ 0)=l.report_seq))
    ORDER BY l.begin_date
    DETAIL
     rc_count = o.row_count
    WITH nocounter
   ;end select
   RETURN(rc_count)
 END ;Subroutine
 SUBROUTINE table_missing(tm_dummy)
   SET tm_flag = 1
   SELECT INTO "nl:"
    a.table_name
    FROM dtableattr a
    WHERE a.table_name="DM_SCHEMA_LOG"
    DETAIL
     tm_flag = 0
    WITH nocounter
   ;end select
   RETURN(tm_flag)
 END ;Subroutine
 DECLARE open_sch_files(sbr_for_modify=i4) = i4
 DECLARE create_sch_files(null) = i4
 DECLARE close_sch_files(null) = i4
 DECLARE copy_sch_files(null) = i4
 DECLARE open_sch_file(sbr_osf_modind=i4,sbr_osf_fname=vc,sbr_osf_rndx=i4) = i4
 DECLARE val_sch_file_ver(sbr_vsf_rndx=i4) = i4
 DECLARE make_sch_file_defs(sbr_msf_rndx=i4) = i4
 DECLARE del_sch_file(sbr_dsf_ffname=vc,sbr_dsf_fname=vc) = i4
 DECLARE del_sch_files(null) = i2
 DECLARE copy_sch_file(sbr_src_fname=vc,sbr_tgt_fname=vc) = i4
 DECLARE check_sch_files(null) = i4
 DECLARE prep_sch_file(rec_ndx=i4) = i4
 DECLARE gen_sch_files(null) = i4
 DECLARE dsfi_load_schema_file_defs(dsfi_schema_set=vc) = i4
 DECLARE dsfi_load_schema_files(dlsf_desc=vc,dlsf_process_option=vc) = i2
 DECLARE dsfi_pop_dmheader(sfidx=i4) = null
 DECLARE dsfi_pop_dmtable(sfidx=i4) = null
 DECLARE dsfi_pop_dmcolumn(sfidx=i4) = null
 DECLARE dsfi_pop_dmindex(sfidx=i4) = null
 DECLARE dsfi_pop_dmindcol(sfidx=i4) = null
 DECLARE dsfi_pop_dmcons(sfidx=i4) = null
 DECLARE dsfi_pop_dmconscol(sfidx=i4) = null
 DECLARE dsfi_pop_dmseq(sfidx=i4) = null
 DECLARE dsfi_pop_dmtbldoc(sfidx=i4) = null
 DECLARE dsfi_pop_dmcoldoc(sfidx=i4) = null
 DECLARE dsfi_pop_dmtdprec(sfidx=i4) = null
 DECLARE dsfi_pop_dmtspace(sfidx=i4) = null
 IF ((validate(dm2_sch_file->file_cnt,- (1))=- (1)))
  RECORD dm2_sch_file(
    1 sf_ver = i4
    1 file_cnt = i4
    1 src_dir_osfmt = vc
    1 dest_dir_cclfmt = vc
    1 dest_dir_osfmt = vc
    1 ending_punct = vc
    1 file_prefix = vc
    1 qual[*]
      2 file_suffix = vc
      2 table_name = vc
      2 db_name = vc
      2 size = vc
      2 data_size = vc
      2 key_size = vc
      2 db_key = vc
      2 key_cnt = i4
      2 kqual[*]
        3 key_col = vc
      2 data_cnt = i4
      2 dqual[*]
        3 data_col = vc
  )
  SET dm2_sch_file->sf_ver = 1
  CASE (dm2_sys_misc->cur_os)
   OF "AXP":
    SET dm2_sch_file->ending_punct = " "
   OF "WIN":
    SET dm2_sch_file->ending_punct = "\"
   ELSE
    SET dm2_sch_file->ending_punct = "/"
  ENDCASE
  IF (dsfi_load_schema_file_defs("TABLE_INFO") != 1)
   SET dm_err->err_ind = 1
  ENDIF
 ENDIF
 SUBROUTINE create_sch_files(null)
   DECLARE csf_concurrency_cnt = i4 WITH noconstant(0)
   DECLARE sch_file_status = i4
   DECLARE di_insert_ind = i2 WITH noconstant(0)
   DECLARE pause_length = i2 WITH noconstant(60)
   DECLARE csf_done_ind = i2 WITH noconstant(0)
   DECLARE csf_retry_cnt = i2 WITH noconstant(0)
   DECLARE csf_skip_ind = i2 WITH noconstant(0)
   SET dm2_sch_file->dest_dir_osfmt = build(logical(dm2_sch_file->dest_dir_cclfmt),dm2_sch_file->
    ending_punct)
   WHILE (csf_done_ind=0
    AND (dm_err->err_ind=0))
     SET csf_done_ind = 1
     SET csf_skip_ind = 0
     IF ((dm2_sch_file->qual[1].table_name != "DMTSPACE"))
      WHILE (csf_concurrency_cnt < 2
       AND (dm_err->err_ind=0))
        IF (dm2_set_autocommit(1)=1)
         SELECT INTO "nl:"
          FROM dm_info d
          WHERE d.info_domain="DM2 TOOLS"
           AND d.info_name="CREATING SCHEMA FILES"
          WITH nocounter
         ;end select
         IF (curqual > 0)
          SET csf_concurrency_cnt = (csf_concurrency_cnt+ 1)
          IF (csf_concurrency_cnt=2)
           SET dm_err->emsg =
           "Another process is currently generating schema file definitions, please try again later."
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           SET dm_err->err_ind = 1
          ELSE
           SET dm_err->eproc = concat(
            "Another process is currently generating schema file definitions.  Pausing ",trim(
             cnvtstring(pause_length))," seconds before trying again. Please wait.")
           CALL disp_msg(" ",dm_err->logfile,0)
           CALL pause(pause_length)
          ENDIF
         ELSE
          IF (check_error("Checking for concurrency row in dm_info ")=1)
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          ENDIF
          SET csf_concurrency_cnt = 2
         ENDIF
        ENDIF
      ENDWHILE
     ENDIF
     IF ((dm_err->err_ind=0))
      SET sch_file_status = check_sch_files(null)
      CASE (sch_file_status)
       OF 0:
        SET dm_err->err_ind = 1
       OF 1:
        SET dm_err->eproc = "ALL CORE SCHEMA FILE COMPONENTS EXIST"
        CALL disp_msg(" ",dm_err->logfile,0)
        FOR (csf_file_cnt = 1 TO dm2_sch_file->file_cnt)
          IF (prep_sch_file(csf_file_cnt)=0)
           SET dm_err->err_ind = 1
           SET csf_file_cnt = dm2_sch_file->file_cnt
          ENDIF
        ENDFOR
       OF 2:
        IF ((dm2_sch_file->qual[1].table_name != "DMTSPACE"))
         SET dm_err->eproc = "INSERT CONCURRENCY ROW INTO DM_INFO"
         CALL disp_msg(" ",dm_err->logfile,0)
         INSERT  FROM dm_info d
          SET d.info_domain = "DM2 TOOLS", d.info_name = "CREATING SCHEMA FILES", d.info_date = null,
           d.info_char = " ", d.info_number = 0.0, d.info_long_id = 0.0,
           d.updt_applctx = 0, d.updt_task = 0.0, d.updt_cnt = 0,
           d.updt_id = 0.0, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
          WITH nocounter
         ;end insert
         IF (check_error("Inserting dm_info row for concurrency ")=1)
          IF (findstring("ORA-00001",dm_err->emsg,1,0) > 0)
           SET csf_retry_cnt = (csf_retry_cnt+ 1)
           IF (csf_retry_cnt < 2)
            SET dm_err->err_ind = 0
            SET csf_done_ind = 0
            SET csf_skip_ind = 1
            SET dm_err->eproc = concat(
             "Another process is currently generating schema file definitions.  Pausing ",trim(
              cnvtstring(pause_length))," seconds before trying again. Please wait.")
            CALL disp_msg(" ",dm_err->logfile,0)
            CALL pause(pause_length)
           ELSE
            SET dm_err->emsg =
            "Another process is currently generating schema file definitions, please try again later."
            CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           ENDIF
          ELSE
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           ROLLBACK
          ENDIF
         ELSE
          COMMIT
          SET di_insert_ind = 1
         ENDIF
        ENDIF
        IF ((dm_err->err_ind=0)
         AND csf_skip_ind=0)
         SET dm_err->eproc = "REGENERATE CORE SCHEMA FILE COMPONENTS"
         CALL disp_msg(" ",dm_err->logfile,0)
         CALL gen_sch_files(null)
        ENDIF
      ENDCASE
     ENDIF
   ENDWHILE
   IF (di_insert_ind=1)
    SET dm_err->eproc = "REMOVE CONCURRENCY ROW FROM DM_INFO"
    CALL disp_msg(" ",dm_err->logfile,0)
    DELETE  FROM dm_info d
     WHERE d.info_domain="DM2 TOOLS"
      AND d.info_name="CREATING SCHEMA FILES"
     WITH nocounter
    ;end delete
    COMMIT
    IF ((dm_err->err_ind=0))
     IF (check_error("Deleting dm_info row for concurrency ")=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ENDIF
    ENDIF
   ENDIF
   CALL dm2_set_autocommit(0)
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE open_sch_file(sbr_osf_modind,sbr_osf_fname,sbr_osf_rndx)
   DECLARE osf_tempstr = vc WITH noconstant(" ")
   IF (dm2_push_cmd(concat("free define ",dm2_sch_file->qual[sbr_osf_rndx].db_name," go"),1)=0)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   CALL dm2_push_cmd(concat("define ",dm2_sch_file->qual[sbr_osf_rndx].db_name," is ",build("'",
      sbr_osf_fname,"'")),0)
   IF (sbr_osf_modind=1)
    CALL dm2_push_cmd(" with modify",0)
    SET osf_tempstr = " with modify"
   ENDIF
   IF (dm2_push_cmd(" go",1)=0)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE open_sch_files(sbr_for_modify)
   DECLARE file_name_for_open = vc
   DECLARE dsfi = i4 WITH public, noconstant(0)
   FOR (dsfi = 1 TO dm2_sch_file->file_cnt)
     SET file_name_for_open = build(dm2_sch_file->dest_dir_cclfmt,":",cnvtlower(dm2_sch_file->
       file_prefix),cnvtlower(dm2_sch_file->qual[dsfi].file_suffix),".dat")
     IF (val_sch_file_ver(dsfi)=0)
      IF ((dm_err->err_ind=1))
       RETURN(0)
      ELSEIF (make_sch_file_defs(dsfi)=0)
       SET dm_err->err_ind = 1
       RETURN(0)
      ENDIF
     ENDIF
     IF ((dm_err->debug_flag=1))
      SET dm_err->eproc = concat("Opening ",file_name_for_open)
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     IF (open_sch_file(sbr_for_modify,file_name_for_open,dsfi)=0)
      SET dm_err->err_ind = 1
      RETURN(0)
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE val_sch_file_ver(sbr_vsf_rndx)
   DECLARE vsfv_datacnt = i4 WITH noconstant(0)
   DECLARE vsfv_keycnt = i4 WITH noconstant(0)
   DECLARE vsfv_match_col_ind = i2 WITH noconstant(0)
   DECLARE vsfv_match_db_ind = i2 WITH noconstant(0)
   DECLARE vsfv_temp_str = vc WITH noconstant("")
   SELECT INTO "nl:"
    d.table_name
    FROM dtable d
    WHERE (d.file_name=dm2_sch_file->qual[sbr_vsf_rndx].db_name)
     AND (d.table_name=dm2_sch_file->qual[sbr_vsf_rndx].table_name)
    DETAIL
     vsfv_match_db_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(concat("Checking for ",dm2_sch_file->qual[sbr_vsf_rndx].table_name,
     " in CCL dictionary"))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    l.attr_name
    FROM dtableattr a,
     dtableattrl l
    WHERE (a.table_name=dm2_sch_file->qual[sbr_vsf_rndx].table_name)
     AND l.structtype="F"
     AND btest(l.stat,11)=0
    HEAD REPORT
     start_pos = 0, end_pos = 0, x = 0,
     y = 0
    DETAIL
     FOR (x = 1 TO dm2_sch_file->qual[sbr_vsf_rndx].data_cnt)
      end_pos = findstring("=",dm2_sch_file->qual[sbr_vsf_rndx].dqual[x].data_col),
      IF (trim(l.attr_name,3)=substring(1,(end_pos - 1),dm2_sch_file->qual[sbr_vsf_rndx].dqual[x].
       data_col))
       end_pos = 0
       IF (trim(l.attr_name,3)="FILLER")
        start_pos = findstring("FILLER = c",dm2_sch_file->qual[sbr_vsf_rndx].dqual[x].data_col),
        start_pos = (start_pos+ 10), end_pos = findstring(" CCL(FILLER)",dm2_sch_file->qual[
         sbr_vsf_rndx].dqual[x].data_col)
        IF (l.len=cnvtint(substring(start_pos,(end_pos - start_pos),dm2_sch_file->qual[sbr_vsf_rndx].
          dqual[x].data_col)))
         vsfv_datacnt = (vsfv_datacnt+ 1), x = dm2_sch_file->qual[sbr_vsf_rndx].data_cnt
        ENDIF
       ELSE
        vsfv_datacnt = (vsfv_datacnt+ 1), x = dm2_sch_file->qual[sbr_vsf_rndx].data_cnt
       ENDIF
      ENDIF
     ENDFOR
     FOR (y = 1 TO dm2_sch_file->qual[sbr_vsf_rndx].key_cnt)
      end_pos = findstring("=",dm2_sch_file->qual[sbr_vsf_rndx].kqual[y].key_col),
      IF (trim(l.attr_name,3)=substring(1,(end_pos - 1),dm2_sch_file->qual[sbr_vsf_rndx].kqual[y].
       key_col))
       end_pos = 0, vsfv_keycnt = (vsfv_keycnt+ 1), y = dm2_sch_file->qual[sbr_vsf_rndx].key_cnt
      ENDIF
     ENDFOR
    WITH nocounter
   ;end select
   IF (check_error(concat("Checking for columns on ",dm2_sch_file->qual[sbr_vsf_rndx].table_name,
     " in CCL dictionary"))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
    CALL echo(build("dm_err->err_ind = ",dm_err->err_ind))
   ENDIF
   IF ((vsfv_datacnt=dm2_sch_file->qual[sbr_vsf_rndx].data_cnt)
    AND (vsfv_keycnt=dm2_sch_file->qual[sbr_vsf_rndx].key_cnt))
    SET vsfv_match_col_ind = 1
   ENDIF
   IF (vsfv_match_col_ind=1
    AND vsfv_match_db_ind=1)
    RETURN(1)
   ELSE
    CALL disp_msg(concat(dm2_sch_file->qual[sbr_vsf_rndx].table_name,
      " definition not correct in CCL dictionary"),dm_err->logfile,0)
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE make_sch_file_defs(sbr_msf_rndx)
   DECLARE current_db = vc
   DECLARE msfd_estr = vc
   DECLARE msfd_ret_val = i2 WITH noconstant(0)
   DECLARE drop_needed = i2 WITH noconstant(0)
   IF ((dm_err->debug_flag=1))
    SET dm_err->eproc = concat("Making CCL definition for ",dm2_sch_file->qual[sbr_msf_rndx].
     table_name)
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dtable d
    WHERE (d.table_name=dm2_sch_file->qual[sbr_msf_rndx].table_name)
    DETAIL
     drop_needed = 1, current_db = d.file_name
    WITH nocounter
   ;end select
   IF (drop_needed=1)
    IF (dm2_push_cmd(concat("drop table ",dm2_sch_file->qual[sbr_msf_rndx].table_name," go"),1)=0)
     RETURN(0)
    ENDIF
    IF (dm2_push_cmd(concat("drop ddlrecord ",dm2_sch_file->qual[sbr_msf_rndx].table_name,
      " from database ",current_db," WITH DEPS_DELETED go"),1)=0)
     RETURN(0)
    ENDIF
    IF (dm2_push_cmd(concat("drop database ",current_db," with deps_deleted go"),1)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET drop_needed = 0
   SELECT INTO "nl:"
    FROM dfile d
    WHERE (d.file_name=dm2_sch_file->qual[sbr_msf_rndx].db_name)
    DETAIL
     drop_needed = 1
    WITH nocounter
   ;end select
   IF (drop_needed=1)
    IF (dm2_push_cmd(concat("drop database ",dm2_sch_file->qual[sbr_msf_rndx].db_name,
      " with deps_deleted go"),1)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dm2_push_cmd(concat("create database ",dm2_sch_file->qual[sbr_msf_rndx].db_name,
     " organization(indexed) format(variable) size(",dm2_sch_file->qual[sbr_msf_rndx].size,") ",
     dm2_sch_file->qual[sbr_msf_rndx].db_key," go"),1)=0)
    RETURN(0)
   ENDIF
   CALL dm2_push_cmd(concat("create ddlrecord ",dm2_sch_file->qual[sbr_msf_rndx].table_name,
     " from database ",dm2_sch_file->qual[sbr_msf_rndx].db_name," table ",
     dm2_sch_file->qual[sbr_msf_rndx].table_name),0)
   CALL dm2_push_cmd(" 1 key1 ",0)
   FOR (i = 1 TO dm2_sch_file->qual[sbr_msf_rndx].key_cnt)
     CALL dm2_push_cmd(concat(" 2 ",dm2_sch_file->qual[sbr_msf_rndx].kqual[i].key_col),0)
   ENDFOR
   CALL dm2_push_cmd(" 1 data ",0)
   FOR (i = 1 TO dm2_sch_file->qual[sbr_msf_rndx].data_cnt)
     CALL dm2_push_cmd(concat(" 2 ",dm2_sch_file->qual[sbr_msf_rndx].dqual[i].data_col),0)
   ENDFOR
   IF (dm2_push_cmd(concat("end table ",dm2_sch_file->qual[sbr_msf_rndx].table_name," go"),1)=0)
    RETURN(0)
   ENDIF
   SET msfd_estr = concat("Making def for ",dm2_sch_file->qual[sbr_msf_rndx].table_name)
   SET msfd_ret_val = val_sch_file_ver(sbr_msf_rndx)
   IF (msfd_ret_val=0)
    IF ((dm_err->err_ind=0))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = msfd_estr
     CALL disp_msg(" ",dm_err->logfile,1)
    ENDIF
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE close_sch_files(null)
   FOR (close_cnt = 1 TO dm2_sch_file->file_cnt)
     IF (dm2_push_cmd(concat("free define ",dm2_sch_file->qual[close_cnt].db_name," go"),1)=0)
      SET dm_err->err_ind = 1
      RETURN(0)
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE copy_sch_files(null)
  DECLARE target_name = vc
  FOR (csfi = 1 TO dm2_sch_file->file_cnt)
    SET target_name = build(dm2_sch_file->file_prefix,cnvtlower(dm2_sch_file->qual[csfi].file_suffix)
     )
    IF ( NOT ((dm2_sys_misc->cur_os IN ("AXP"))))
     IF (del_sch_file(build(dm2_sch_file->dest_dir_osfmt,target_name,".dat"))=0)
      SET dm_err->err_ind = 1
      RETURN(0)
     ENDIF
     IF (del_sch_file(build(dm2_sch_file->dest_dir_osfmt,target_name,".idx"))=0)
      SET dm_err->err_ind = 1
      RETURN(0)
     ENDIF
    ENDIF
    IF (copy_sch_file(build(dm2_sch_file->src_dir_osfmt,target_name,".dat"),build(dm2_sch_file->
      dest_dir_osfmt,target_name,".dat"))=0)
     SET dm_err->err_ind = 1
     RETURN(0)
    ENDIF
    IF ( NOT ((dm2_sys_misc->cur_os IN ("AXP"))))
     IF (copy_sch_file(build(dm2_sch_file->src_dir_osfmt,target_name,".idx"),build(dm2_sch_file->
       dest_dir_osfmt,target_name,".idx"))=0)
      SET dm_err->err_ind = 1
      RETURN(0)
     ENDIF
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE del_sch_file(sbr_dsf_fname)
  IF ((dm2_sys_misc->cur_os="WIN"))
   IF (findfile(sbr_dsf_fname)=1)
    IF (dm2_push_dcl(concat("del ",sbr_dsf_fname))=0)
     RETURN(0)
    ENDIF
   ENDIF
  ELSEIF ((dm2_sys_misc->cur_os="AXP"))
   IF (findfile(sbr_dsf_fname)=1)
    IF (dm2_push_dcl(concat("del ",sbr_dsf_fname,";\*"))=0)
     RETURN(0)
    ENDIF
   ENDIF
  ELSE
   IF (findfile(sbr_dsf_fname)=1)
    IF (dm2_push_dcl(concat("rm ",sbr_dsf_fname))=0)
     RETURN(0)
    ENDIF
   ENDIF
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE copy_sch_file(sbr_src_fname,sbr_tgt_fname)
  IF ((dm2_sys_misc->cur_os IN ("HPX", "AIX", "LNX")))
   IF (dm2_push_dcl(concat("cp ",sbr_src_fname," ",sbr_tgt_fname))=0)
    RETURN(0)
   ENDIF
   IF (dm2_push_dcl(concat("chmod 777 ",sbr_tgt_fname))=0)
    RETURN(0)
   ENDIF
  ELSE
   IF (dm2_push_dcl(concat("copy ",sbr_src_fname," ",sbr_tgt_fname))=0)
    RETURN(0)
   ENDIF
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE check_sch_files(null)
   DECLARE csf_file_name = vc WITH noconstant("")
   DECLARE csf_val_ver_ind = i2 WITH noconstant(0)
   FOR (csf_file_cnt = 1 TO dm2_sch_file->file_cnt)
     SET csf_file_name = concat(dm2_install_schema->ccluserdir,dm2_sch_file->qual[csf_file_cnt].
      table_name)
     IF ((dm2_sys_misc->cur_os="AXP"))
      IF ( NOT (findfile(concat(trim(csf_file_name,3),".dat"))))
       RETURN(2)
      ENDIF
     ELSE
      IF ( NOT (findfile(concat(trim(csf_file_name,3),".dat"))))
       RETURN(2)
      ELSEIF ( NOT (findfile(concat(trim(csf_file_name,3),".idx"))))
       RETURN(2)
      ENDIF
     ENDIF
     IF (val_sch_file_ver(csf_file_cnt)=0)
      IF ((dm_err->err_ind=1))
       RETURN(0)
      ELSE
       SET csf_val_ver_ind = 1
      ENDIF
     ENDIF
   ENDFOR
   IF (csf_val_ver_ind=1)
    RETURN(2)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE prep_sch_file(rec_ndx)
   DECLARE psf_target_name = vc
   DECLARE psf_target_name2 = vc
   DECLARE psf_estr = vc
   DECLARE psf_fext = vc
   IF ((dm2_sys_misc->cur_os IN ("HPX", "AIX", "LNX")))
    SET psf_fext = ".dat/.idx"
   ELSEIF ((dm2_sys_misc->cur_os="WIN"))
    SET psf_fext = ".dat/.idx"
   ELSE
    SET psf_fext = ".dat"
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("dm2_sch_file->dest_dir_osfmt=",dm2_sch_file->dest_dir_osfmt))
    CALL echo(build("size(dm2_sch_file->dest_dir_osfmt,1)=",size(dm2_sch_file->dest_dir_osfmt,1)))
    CALL echo(concat("dm2_sch_file->file_prefix=",dm2_sch_file->file_prefix))
    CALL echo(concat("dm2_sch_file->qual[rec_ndx]->file_suffix=",dm2_sch_file->qual[rec_ndx].
      file_suffix))
   ENDIF
   SET psf_target_name = build(dm2_sch_file->dest_dir_osfmt,cnvtlower(dm2_sch_file->file_prefix),
    cnvtlower(dm2_sch_file->qual[rec_ndx].file_suffix),".dat")
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("psf_target_name=",psf_target_name))
   ENDIF
   IF ((dm2_sys_misc->cur_os != "AXP"))
    SET psf_target_name2 = build(dm2_sch_file->dest_dir_osfmt,cnvtlower(dm2_sch_file->file_prefix),
     cnvtlower(dm2_sch_file->qual[rec_ndx].file_suffix),".idx")
   ENDIF
   IF ((dm2_sys_misc->cur_os IN ("HPX", "AIX", "WIN", "LNX")))
    IF (del_sch_file(psf_target_name)=0)
     RETURN(0)
    ENDIF
    IF (del_sch_file(psf_target_name2)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (copy_sch_file(concat(dm2_install_schema->ccluserdir,cnvtlower(build(dm2_sch_file->qual[rec_ndx
       ].table_name,".dat"))),psf_target_name)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os != "AXP"))
    IF (copy_sch_file(concat(dm2_install_schema->ccluserdir,cnvtlower(build(dm2_sch_file->qual[
        rec_ndx].table_name,".idx"))),psf_target_name2)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (open_sch_file(1,build(dm2_sch_file->dest_dir_cclfmt,":",cnvtlower(dm2_sch_file->file_prefix),
     cnvtlower(dm2_sch_file->qual[rec_ndx].file_suffix),".dat"),rec_ndx)=0)
    RETURN(0)
   ENDIF
   IF (dm2_push_cmd(concat("delete from ",dm2_sch_file->qual[rec_ndx].table_name," where 1=1 go"),1)=
   0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gen_sch_files(null)
   DECLARE gsf_fext = vc
   IF ((dm2_sys_misc->cur_os IN ("HPX", "AIX", "LNX")))
    SET gsf_fext = ".dat/.idx"
   ELSEIF ((dm2_sys_misc->cur_os="WIN"))
    SET gsf_fext = ".dat/.idx"
   ELSE
    SET gsf_fext = ".dat"
   ENDIF
   FOR (gsf_cnt = 1 TO dm2_sch_file->file_cnt)
     IF ((dm2_sys_misc->cur_os != "AXP"))
      IF (del_sch_file(concat(dm2_install_schema->ccluserdir,cnvtlower(build(dm2_sch_file->qual[
          gsf_cnt].table_name,".dat"))))=0)
       RETURN(0)
      ENDIF
      IF (del_sch_file(concat(dm2_install_schema->ccluserdir,cnvtlower(build(dm2_sch_file->qual[
          gsf_cnt].table_name,".idx"))))=0)
       RETURN(0)
      ENDIF
     ENDIF
     IF (dm2_push_cmd(concat('select into table "',dm2_sch_file->qual[gsf_cnt].table_name,'"',
       " key1=fillstring(",dm2_sch_file->qual[gsf_cnt].key_size,
       '," "),'," data=fillstring(",dm2_sch_file->qual[gsf_cnt].data_size,'," ") ',
       " from dummyt order key1 with organization=indexed GO"),1)=0)
      RETURN(0)
     ENDIF
     IF (dm2_push_cmd(concat("drop table ",dm2_sch_file->qual[gsf_cnt].table_name," go"),1)=0)
      RETURN(0)
     ENDIF
     IF (dm2_push_cmd(concat("drop ddlrecord ",dm2_sch_file->qual[gsf_cnt].table_name,
       " from database ",dm2_sch_file->qual[gsf_cnt].table_name," with deps_deleted go"),1)=0)
      RETURN(0)
     ENDIF
     IF (dm2_push_cmd(concat("drop database ",dm2_sch_file->qual[gsf_cnt].table_name,
       " with deps_deleted go"),1)=0)
      RETURN(0)
     ENDIF
     IF (make_sch_file_defs(gsf_cnt)=0)
      RETURN(0)
     ENDIF
     IF (prep_sch_file(gsf_cnt)=0)
      RETURN(0)
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsfi_load_schema_file_defs(dsfi_schema_set)
  CASE (cnvtupper(dsfi_schema_set))
   OF "TABLE_INFO":
    SET dm2_sch_file->file_cnt = 11
    SET stat = alterlist(dm2_sch_file->qual,dm2_sch_file->file_cnt)
    CALL dsf_pop_dmheader(1)
    CALL dsf_pop_dmtable(2)
    CALL dsf_pop_dmcolumn(3)
    CALL dsf_pop_dmindex(4)
    CALL dsf_pop_dmindcol(5)
    CALL dsf_pop_dmcons(6)
    CALL dsf_pop_dmconscol(7)
    CALL dsf_pop_dmseq(8)
    CALL dsf_pop_dmtbldoc(9)
    CALL dsf_pop_dmcoldoc(10)
    CALL dsf_pop_dmtsprec(11)
   OF "TSPACE":
    SET dm2_sch_file->file_cnt = 1
    SET stat = alterlist(dm2_sch_file->qual,dm2_sch_file->file_cnt)
    CALL dsf_pop_dmtspace(1)
  ENDCASE
  RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmheader(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_h"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMHEADER"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1058"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1028"
   SET dm2_sch_file->qual[dsfcnt].key_size = "30"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 30)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 1
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "DESCRIPTION = c30 CCL(DESCRIPTION)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 4
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "SOURCE_RDBMS = c20 CCL(SOURCE_RDBMS)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "ADMIN_LOAD_IND = i4 CCL(ADMIN_LOAD_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "SF_VERSION = i4 CCL(SF_VERSION)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col = "FILLER = c1000 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmtable(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_t"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMTABLE"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1208"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1178"
   SET dm2_sch_file->qual[dsfcnt].key_size = "30"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 30)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 1
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "TABLE_NAME = c30  CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 21
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "TABLESPACE_NAME = c30 CCL(TABLESPACE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "INDEX_TSPACE = c30 CCL(INDEX_TSPACE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "INDEX_TSPACE_NI = i2 CCL(INDEX_TSPACE_NI)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col = "LONG_TSPACE = c30 CCL(LONG_TSPACE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[5].data_col = "LONG_TSPACE_NI = i2 CCL(LONG_TSPACE_NI)"
   SET dm2_sch_file->qual[dsfcnt].dqual[6].data_col = "INIT_EXT = f8 CCL(INIT_EXT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[7].data_col = "NEXT_EXT = f8 CCL(NEXT_EXT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[8].data_col = "PCT_INCREASE = f8 CCL(PCT_INCREASE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[9].data_col = "PCT_USED = f8 CCL(PCT_USED)"
   SET dm2_sch_file->qual[dsfcnt].dqual[10].data_col = "PCT_FREE = f8 CCL(PCT_FREE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[11].data_col = "BYTES_ALLOCATED = f8 CCL(BYTES_ALLOCATED)"
   SET dm2_sch_file->qual[dsfcnt].dqual[12].data_col = "BYTES_USED = f8 CCL(BYTES_USED)"
   SET dm2_sch_file->qual[dsfcnt].dqual[13].data_col = "SCHEMA_DATE = dq8 CCL(SCHEMA_DATE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[14].data_col =
   "ALPHA_FEATURE_NBR = i4 CCL(ALPHA_FEATURE_NBR)"
   SET dm2_sch_file->qual[dsfcnt].dqual[15].data_col = "FEATURE_NUMBER = i4 CCL(FEATURE_NUMBER)"
   SET dm2_sch_file->qual[dsfcnt].dqual[16].data_col = "UPDT_DT_TM = dq8 CCL(UPDT_DT_TM)"
   SET dm2_sch_file->qual[dsfcnt].dqual[17].data_col = "SCHEMA_INSTANCE = i4 CCL(SCHEMA_INSTANCE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[18].data_col = "TSPACE_TYPE = c1 CCL(TSPACE_TYPE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[19].data_col = "LONG_TSPACE_TYPE = c1 CCL(LONG_TSPACE_TYPE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[20].data_col = "MAX_EXT = f8 CCL(MAX_EXT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[21].data_col = "FILLER = c990 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmcolumn(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_tc"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMCOLUMN"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1343"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1283"
   SET dm2_sch_file->qual[dsfcnt].key_size = "60"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 60)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 2
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "TABLE_NAME = c30 CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].kqual[2].key_col = "COLUMN_NAME = c30 CCL(COLUMN_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 9
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "COLUMN_SEQ = i4 CCL(COLUMN_SEQ)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "DATA_TYPE = c18 CCL(DATA_TYPE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "DATA_LENGTH = i4 CCL(DATA_LENGTH)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col = "NULLABLE = c1 CCL(NULLABLE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[5].data_col = "DATA_DEFAULT = c254 CCL(DATA_DEFAULT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[6].data_col = "DATA_DEFAULT_NI = i2 CCL(DATA_DEFAULT_NI)"
   SET dm2_sch_file->qual[dsfcnt].dqual[7].data_col = "DATA_DEFAULT2 = c500 CCL(DATA_DEFAULT2)"
   SET dm2_sch_file->qual[dsfcnt].dqual[8].data_col = "VIRTUAL_COLUMN = c3 CCL(VIRTUAL_COLUMN)"
   SET dm2_sch_file->qual[dsfcnt].dqual[9].data_col = "FILLER = c497 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmindex(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_i"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMINDEX"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1140"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1080"
   SET dm2_sch_file->qual[dsfcnt].key_size = "60"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 60)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 2
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "TABLE_NAME =  c30 CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].kqual[2].key_col = "INDEX_NAME = c30 CCL(INDEX_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 13
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "FULL_IND_NAME = c30 CCL(FULL_IND_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "PCT_INCREASE = f8 CCL(PCT_INCREASE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "PCT_FREE = f8 CCL(PCT_FREE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col = "INIT_EXT = f8 CCL(INIT_EXT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[5].data_col = "NEXT_EXT = f8 CCL(NEXT_EXT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[6].data_col = "UNIQUE_IND = i2 CCL(UNIQUE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[7].data_col = "BYTES_ALLOCATED = f8 CCL(BYTES_ALLOCATED)"
   SET dm2_sch_file->qual[dsfcnt].dqual[8].data_col = "BYTES_USED = f8 CCL(BYTES_USED)"
   SET dm2_sch_file->qual[dsfcnt].dqual[9].data_col = "TSPACE_NAME = c30 CCL(TSPACE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[10].data_col = "TSPACE_TYPE = c1 CCL(TSPACE_TYPE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[11].data_col = "INDEX_TYPE = c30 CCL(INDEX_TYPE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[12].data_col = "MAX_EXT = f8 CCL(MAX_EXT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[13].data_col = "FILLER = c931 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmindcol(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_ic"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMINDCOL"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1094"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1034"
   SET dm2_sch_file->qual[dsfcnt].key_size = "60"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 60)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 2
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "INDEX_NAME = c30 CCL(INDEX_NAME)"
   SET dm2_sch_file->qual[dsfcnt].kqual[2].key_col = "COLUMN_NAME = c30 CCL(COLUMN_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 3
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "TABLE_NAME = c30 CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "COLUMN_POSITION = i4 CCL(COLUMN_POSITION)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "FILLER = c1000 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmcons(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_c"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMCONS"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1408"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1348"
   SET dm2_sch_file->qual[dsfcnt].key_size = "60"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 60)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 2
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "TABLE_NAME = c30 CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].kqual[2].key_col = "CONSTRAINT_NAME = c30 CCL(CONSTRAINT_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 8
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "FULL_CONS_NAME = c30 CCL(FULL_CONS_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "CONSTRAINT_TYPE = c1 CCL(CONSTRAINT_TYPE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "STATUS_IND = i2 CCL(STATUS_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col =
   "R_CONSTRAINT_NAME = c30 CCL(R_CONSTRAINT_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[5].data_col =
   "PARENT_TABLE_NAME = c30 CCL(PARENT_TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[6].data_col =
   "PARENT_TABLE_COLUMNS = c255 CCL(PARENT_TABLE_COLUMNS)"
   SET dm2_sch_file->qual[dsfcnt].dqual[7].data_col = "DELETE_RULE = c9 CCL(DELETE_RULE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[8].data_col = "FILLER = c991 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmconscol(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_cc"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMCONSCOL"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1094"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1034"
   SET dm2_sch_file->qual[dsfcnt].key_size = "60"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 60)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 2
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "CONSTRAINT_NAME = c30 CCL(CONSTRAINT_NAME)"
   SET dm2_sch_file->qual[dsfcnt].kqual[2].key_col = "COLUMN_NAME = c30 CCL(COLUMN_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 3
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "TABLE_NAME = c30 CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "POSITION =  i4 CCL(POSITION)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "FILLER = c1000 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmseq(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_sq"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMSEQ"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1079"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1049"
   SET dm2_sch_file->qual[dsfcnt].key_size = "30"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 30)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 1
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "SEQUENCE_NAME = c30 CCL(SEQUENCE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 9
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "MIN_VALUE = f8  CCL(MIN_VALUE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "MAX_VALUE = f8 CCL(MAX_VALUE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "INCREMENT_BY = f8 CCL(INCREMENT_BY)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col = "CYCLE_FLAG = c1 CCL(CYCLE_FLAG)"
   SET dm2_sch_file->qual[dsfcnt].dqual[5].data_col = "LAST_NUMBER = f8 CCL(LAST_NUMBER)"
   SET dm2_sch_file->qual[dsfcnt].dqual[6].data_col = "ALPHA_FEATURE_NBR = i4 CCL(ALPHA_FEATURE_NBR)"
   SET dm2_sch_file->qual[dsfcnt].dqual[7].data_col = "FEATURE_NUMBER = i4 CCL(FEATURE_NUMBER)"
   SET dm2_sch_file->qual[dsfcnt].dqual[8].data_col = "UPDT_DT_TM = dq8 CCL(UPDT_DT_TM)"
   SET dm2_sch_file->qual[dsfcnt].dqual[9].data_col = "FILLER = c1000 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmtbldoc(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_td"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMTBLDOC"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "2041"
   SET dm2_sch_file->qual[dsfcnt].data_size = "2011"
   SET dm2_sch_file->qual[dsfcnt].key_size = "30"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 30)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 1
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "TABLE_NAME = c30 CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 20
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col =
   "DATA_MODEL_SECTION = c80 CCL(DATA_MODEL_SECTION)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "DESCRIPTION = c80 CCL(DESCRIPTION)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "DEFINITION = c500 CCL(DEFINITION)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col = "STATIC_ROWS = i4 CCL(STATIC_ROWS)"
   SET dm2_sch_file->qual[dsfcnt].dqual[5].data_col = "UPDT_CNT = i4 CCL(UPDT_CNT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[6].data_col = "REFERENCE_IND = i2 CCL(REFERENCE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[7].data_col = "HUMAN_REQD_IND = i2 CCL(HUMAN_REQD_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[8].data_col = "DROP_IND = i2 CCL(DROP_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[9].data_col = "TABLE_SUFFIX = c4 CCL(TABLE_SUFFIX)"
   SET dm2_sch_file->qual[dsfcnt].dqual[10].data_col = "FULL_TABLE_NAME = c30 CCL(FULL_TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[11].data_col =
   "SUFFIXED_TABLE_NAME = c18 CCL(SUFFIXED_TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[12].data_col = "DEFAULT_ROW_IND = i2 CCL(DEFAULT_ROW_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[13].data_col =
   "PERSON_CMB_TRIGGER_TYPE = c10 CCL(PERSON_CMB_TRIGGER_TYPE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[14].data_col =
   "ENCNTR_CMB_TRIGGER_TYPE = c10 CCL(ENCNTR_CMB_TRIGGER_TYPE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[15].data_col = "MERGE_UI_QUERY = c255 CCL(MERGE_UI_QUERY)"
   SET dm2_sch_file->qual[dsfcnt].dqual[16].data_col = "MERGEABLE_IND  = i2 CCL(MERGEABLE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[17].data_col = "MERGE_DELETE_IND = i2 CCL(MERGE_DELETE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[18].data_col = "MERGE_ACTIVE_IND = i2 CCL(MERGE_ACTIVE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[19].data_col = "DATA_DISP_FLAG = i2 CCL(DATA_DISP_FLAG)"
   SET dm2_sch_file->qual[dsfcnt].dqual[20].data_col = "FILLER = c1000 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmcoldoc(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_cd"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMCOLDOC"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "2043"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1983"
   SET dm2_sch_file->qual[dsfcnt].key_size = "60"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 60)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 2
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "TABLE_NAME = c30 CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].kqual[2].key_col = "COLUMN_NAME = c30 CCL(COLUMN_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 19
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "SEQUENCE_NAME = c30 CCL(SEQUENCE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "CODE_SET = i4 CCL(CODE_SET)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "DESCRIPTION = c80 CCL(DESCRIPTION)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col = "DEFINITION = c500 CCL(DEFINITION)"
   SET dm2_sch_file->qual[dsfcnt].dqual[5].data_col = "FLAG_IND = i2 CCL(FLAG_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[6].data_col = "UPDT_CNT = i4 CCL(UPDT_CNT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[7].data_col = "UNIQUE_IDENT_IND = i2 CCL(UNIQUE_IDENT_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[8].data_col = "ROOT_ENTITY_NAME = c30 CCL(ROOT_ENTITY_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[9].data_col = "ROOT_ENTITY_ATTR = c30 CCL(ROOT_ENTITY_ATTR)"
   SET dm2_sch_file->qual[dsfcnt].dqual[10].data_col = "CONSTANT_VALUE = c255 CCL(CONSTANT_VALUE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[11].data_col =
   "PARENT_ENTITY_COL = c30 CCL(PARENT_ENTITY_COL)"
   SET dm2_sch_file->qual[dsfcnt].dqual[12].data_col = "EXCEPTION_FLG = i4 CCL(EXCEPTION_FLG)"
   SET dm2_sch_file->qual[dsfcnt].dqual[13].data_col =
   "DEFINING_ATTRIBUTE_IND = i2 CCL(DEFINING_ATTRIBUTE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[14].data_col =
   "MERGE_UPDATEABLE_IND = i2 CCL(MERGE_UPDATEABLE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[15].data_col = "NLS_COL_IND = i2 CCL(NLS_COL_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[16].data_col =
   "ABSOLUTE_DATE_IND = i2 CCL(ABSOLUTE_DATE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[17].data_col = "MERGE_DELETE_IND = I2 CCL(MERGE_DELETE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[18].data_col = "TZ_RULE_FLAG = I2 CCL(TZ_RULE_FLAG)"
   SET dm2_sch_file->qual[dsfcnt].dqual[19].data_col = "FILLER = c1000 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmtsprec(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_tp"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMTSPREC"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1152"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1118"
   SET dm2_sch_file->qual[dsfcnt].key_size = "34"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 34)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 2
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "TABLE_NAME = c30 CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].kqual[2].key_col = "PRECEDENCE = i4 CCL(PRECEDENCE)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 8
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "DATA_TABLESPACE = c30 CCL(DATA_TABLESPACE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "DATA_EXTENT_SIZE = f8 CCL(DATA_EXTENT_SIZE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "INDEX_TABLESPACE = c30 CCL(INDEX_TABLESPACE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col = "INDEX_EXTENT_SIZE = f8 CCL(INDEX_EXTENT_SIZE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[5].data_col = "LONG_TABLESPACE = c30 CCL(LONG_TABLESPACE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[6].data_col = "LONG_EXTENT_SIZE = f8 CCL(LONG_EXTENT_SIZE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[7].data_col = "UPDT_CNT = i4 CCL(UPDT_CNT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[8].data_col = "FILLER = c1000 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmtspace(dsfcnt)
   SET dm2_sch_file->qual[1].file_suffix = "_ts"
   SET dm2_sch_file->qual[1].table_name = "DMTSPACE"
   SET dm2_sch_file->qual[1].db_name = build(dm2_sch_file->qual[1].table_name,dm2_sch_file->sf_ver)
   SET dm2_sch_file->qual[1].size = "1056"
   SET dm2_sch_file->qual[1].data_size = "1026"
   SET dm2_sch_file->qual[1].key_size = "30"
   SET dm2_sch_file->qual[1].db_key = "unique key 1 (0, 30)"
   SET dm2_sch_file->qual[1].key_cnt = 1
   SET stat = alterlist(dm2_sch_file->qual[1].kqual,dm2_sch_file->qual[1].key_cnt)
   SET dm2_sch_file->qual[1].kqual[1].key_col = "TSPACE_NAME = c30  CCL(TSPACE_NAME)"
   SET dm2_sch_file->qual[1].data_cnt = 4
   SET stat = alterlist(dm2_sch_file->qual[1].dqual,dm2_sch_file->qual[1].data_cnt)
   SET dm2_sch_file->qual[1].dqual[1].data_col = "BYTES_NEEDED = f8  CCL(BYTES_NEEDED)"
   SET dm2_sch_file->qual[1].dqual[2].data_col = "EXT_MGMT = c10 CCL(EXT_MGMT)"
   SET dm2_sch_file->qual[1].dqual[3].data_col = "UPDT_DT_TM = dq8 CCL(UPDT_DT_TM)"
   SET dm2_sch_file->qual[1].dqual[4].data_col = "FILLER = c1000 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsfi_load_schema_files(dlsf_desc,dlsf_process_option)
   DECLARE dlsf_tbl_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlsf_max_tc_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlsf_max_i_cnt = i2 WITH protect, noconstant(0)
   DECLARE dlsf_max_ic_cnt = i2 WITH protect, noconstant(0)
   DECLARE dlsf_max_c_cnt = i2 WITH protect, noconstant(0)
   DECLARE dlsf_max_cc_cnt = i2 WITH protect, noconstant(0)
   DECLARE dlsf_tc_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlsf_ind_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlsf_icol_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlsf_cons_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlsf_ccol_cnt = i4 WITH protect, noconstant(0)
   IF ((cur_sch->tbl_cnt <= 0))
    SET dm_err->eproc = "NO TABLES IN CURRENT SCHEMA"
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "No tables found for the schema snapshot."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   FOR (dlsf_tbl_cnt = 1 TO value(cur_sch->tbl_cnt))
     SET cur_sch->tbl[dlsf_tbl_cnt].capture_ind = 1
   ENDFOR
   SET dm_err->eproc = "POPULATE DMHEADER SCHEMA FILE WITH HEADER INFO"
   CALL disp_msg(" ",dm_err->logfile,0)
   INSERT  FROM dmheader dh
    SET dh.description = dlsf_desc, dh.admin_load_ind = 0, dh.source_rdbms = currdb,
     dh.sf_version = 1
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "POPULATE DMTABLE SCHEMA FILE WITH TABLE INFO"
   CALL disp_msg(" ",dm_err->logfile,0)
   INSERT  FROM dmtable t,
     (dummyt d  WITH seq = value(cur_sch->tbl_cnt))
    SET t.seq = 1, t.table_name = cur_sch->tbl[d.seq].tbl_name, t.tablespace_name = cur_sch->tbl[d
     .seq].tspace_name,
     t.index_tspace = dm2_dft_clin_itspace, t.index_tspace_ni = 0, t.long_tspace = cur_sch->tbl[d.seq
     ].long_tspace,
     t.long_tspace_ni = cur_sch->tbl[d.seq].long_tspace_ni, t.init_ext = cur_sch->tbl[d.seq].init_ext,
     t.next_ext = cur_sch->tbl[d.seq].next_ext,
     t.pct_increase = cur_sch->tbl[d.seq].pct_increase, t.pct_used = cur_sch->tbl[d.seq].pct_used, t
     .pct_free = cur_sch->tbl[d.seq].pct_free,
     t.bytes_allocated = cur_sch->tbl[d.seq].bytes_allocated, t.bytes_used = cur_sch->tbl[d.seq].
     bytes_used, t.schema_date = cur_sch->tbl[d.seq].schema_date,
     t.schema_instance = cur_sch->tbl[d.seq].schema_instance, t.alpha_feature_nbr = 0, t
     .feature_number = 0,
     t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.tspace_type = cur_sch->tbl[d.seq].ext_mgmt, t
     .long_tspace_type = cur_sch->tbl[d.seq].lext_mgmt,
     t.max_ext = cur_sch->tbl[d.seq].max_ext
    PLAN (d
     WHERE (cur_sch->tbl[d.seq].capture_ind=1))
     JOIN (t
     WHERE (cur_sch->tbl[d.seq].tbl_name=t.table_name))
    WITH nocounter, outerjoin = d, dontexist
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "POPULATE DMCOLUMN SCHEMA FILE WITH COLUMN INFO"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(cur_sch->tbl_cnt))
    PLAN (d)
    DETAIL
     IF ((cur_sch->tbl[d.seq].tbl_col_cnt > dlsf_max_tc_cnt))
      dlsf_max_tc_cnt = cur_sch->tbl[d.seq].tbl_col_cnt
     ENDIF
     dlsf_tc_cnt = (dlsf_tc_cnt+ cur_sch->tbl[d.seq].tbl_col_cnt)
    WITH nocounter
   ;end select
   IF (dlsf_max_tc_cnt > 0)
    INSERT  FROM dmcolumn tc,
      (dummyt d  WITH seq = value(cur_sch->tbl_cnt)),
      (dummyt d2  WITH seq = value(dlsf_max_tc_cnt))
     SET tc.seq = 1, tc.table_name = cur_sch->tbl[d.seq].tbl_name, tc.column_name = cur_sch->tbl[d
      .seq].tbl_col[d2.seq].col_name,
      tc.column_seq = cur_sch->tbl[d.seq].tbl_col[d2.seq].col_seq, tc.data_type = cur_sch->tbl[d.seq]
      .tbl_col[d2.seq].data_type, tc.data_length = cur_sch->tbl[d.seq].tbl_col[d2.seq].data_length,
      tc.nullable = cur_sch->tbl[d.seq].tbl_col[d2.seq].nullable, tc.data_default = cur_sch->tbl[d
      .seq].tbl_col[d2.seq].data_default, tc.data_default_ni = cur_sch->tbl[d.seq].tbl_col[d2.seq].
      data_default_ni,
      tc.data_default2 = cur_sch->tbl[d.seq].tbl_col[d2.seq].data_default, tc.virtual_column =
      cur_sch->tbl[d.seq].tbl_col[d2.seq].virtual_column
     PLAN (d
      WHERE (cur_sch->tbl[d.seq].capture_ind=1))
      JOIN (d2
      WHERE (d2.seq <= cur_sch->tbl[d.seq].tbl_col_cnt))
      JOIN (tc
      WHERE (cur_sch->tbl[d.seq].tbl_name=tc.table_name)
       AND (cur_sch->tbl[d.seq].tbl_col[d2.seq].col_name=tc.column_name))
     WITH nocounter, outerjoin = d2, dontexist
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->err_ind = 1
    CALL disp_msg("No column information found for tables.",dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "POPULATE DMINDEX SCHEMA FILE WITH INDEX INFO"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(cur_sch->tbl_cnt))
    PLAN (d)
    DETAIL
     IF ((cur_sch->tbl[d.seq].ind_cnt > dlsf_max_i_cnt))
      dlsf_max_i_cnt = cur_sch->tbl[d.seq].ind_cnt
     ENDIF
     dlsf_ind_cnt = (dlsf_ind_cnt+ cur_sch->tbl[d.seq].ind_cnt)
    WITH nocounter
   ;end select
   IF (dlsf_max_i_cnt > 0)
    INSERT  FROM dmindex i,
      (dummyt d  WITH seq = value(cur_sch->tbl_cnt)),
      (dummyt d2  WITH seq = value(dlsf_max_i_cnt))
     SET i.seq = 1, i.table_name = cur_sch->tbl[d.seq].tbl_name, i.index_name = cur_sch->tbl[d.seq].
      ind[d2.seq].ind_name,
      i.full_ind_name = cur_sch->tbl[d.seq].ind[d2.seq].full_ind_name, i.pct_increase = cur_sch->tbl[
      d.seq].ind[d2.seq].pct_increase, i.pct_free = cur_sch->tbl[d.seq].ind[d2.seq].pct_free,
      i.init_ext = cur_sch->tbl[d.seq].ind[d2.seq].init_ext, i.next_ext = cur_sch->tbl[d.seq].ind[d2
      .seq].next_ext, i.bytes_allocated = cur_sch->tbl[d.seq].ind[d2.seq].bytes_allocated,
      i.bytes_used = cur_sch->tbl[d.seq].ind[d2.seq].bytes_used, i.unique_ind = cur_sch->tbl[d.seq].
      ind[d2.seq].unique_ind, i.tspace_name = cur_sch->tbl[d.seq].ind[d2.seq].tspace_name,
      i.tspace_type = cur_sch->tbl[d.seq].ind[d2.seq].ext_mgmt, i.index_type = cur_sch->tbl[d.seq].
      ind[d2.seq].index_type, i.max_ext = cur_sch->tbl[d.seq].ind[d2.seq].max_ext
     PLAN (d
      WHERE (cur_sch->tbl[d.seq].capture_ind=1))
      JOIN (d2
      WHERE (d2.seq <= cur_sch->tbl[d.seq].ind_cnt))
      JOIN (i
      WHERE (cur_sch->tbl[d.seq].tbl_name=i.table_name)
       AND (cur_sch->tbl[d.seq].ind[d2.seq].ind_name=i.index_name))
     WITH nocounter, outerjoin = d2, dontexist
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "POPULATE DMINDCOL SCHEMA FILE WITH INDEX COLUMN INFO"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     d.seq
     FROM (dummyt d  WITH seq = value(cur_sch->tbl_cnt)),
      (dummyt d2  WITH seq = value(dlsf_max_i_cnt))
     PLAN (d)
      JOIN (d2
      WHERE (d2.seq <= cur_sch->tbl[d.seq].ind_cnt))
     DETAIL
      IF ((cur_sch->tbl[d.seq].ind[d2.seq].ind_col_cnt > dlsf_max_ic_cnt))
       dlsf_max_ic_cnt = cur_sch->tbl[d.seq].ind[d2.seq].ind_col_cnt
      ENDIF
      dlsf_icol_cnt = (dlsf_icol_cnt+ cur_sch->tbl[d.seq].ind[d2.seq].ind_col_cnt)
     WITH nocounter
    ;end select
    IF (dlsf_max_ic_cnt > 0)
     INSERT  FROM dmindcol ic,
       (dummyt d  WITH seq = value(cur_sch->tbl_cnt)),
       (dummyt d2  WITH seq = value(dlsf_max_i_cnt)),
       (dummyt d3  WITH seq = value(dlsf_max_ic_cnt))
      SET ic.seq = 1, ic.table_name = cur_sch->tbl[d.seq].tbl_name, ic.index_name = cur_sch->tbl[d
       .seq].ind[d2.seq].ind_name,
       ic.column_name = cur_sch->tbl[d.seq].ind[d2.seq].ind_col[d3.seq].col_name, ic.column_position
        = cur_sch->tbl[d.seq].ind[d2.seq].ind_col[d3.seq].col_position
      PLAN (d
       WHERE (cur_sch->tbl[d.seq].capture_ind=1))
       JOIN (d2
       WHERE (d2.seq <= cur_sch->tbl[d.seq].ind_cnt))
       JOIN (d3
       WHERE (d3.seq <= cur_sch->tbl[d.seq].ind[d2.seq].ind_col_cnt))
       JOIN (ic
       WHERE (cur_sch->tbl[d.seq].tbl_name=ic.table_name)
        AND (cur_sch->tbl[d.seq].ind[d2.seq].ind_name=ic.index_name)
        AND (cur_sch->tbl[d.seq].ind[d2.seq].ind_col[d3.seq].col_name=ic.column_name))
      WITH nocounter, outerjoin = d3, dontexist
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ELSE
     SET dm_err->err_ind = 1
     CALL disp_msg("No column information found for indexes.",dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "POPULATE DMCONS SCHEMA FILE WITH CONSTRAINT INFO"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(cur_sch->tbl_cnt))
    PLAN (d)
    DETAIL
     IF ((cur_sch->tbl[d.seq].cons_cnt > dlsf_max_c_cnt))
      dlsf_max_c_cnt = cur_sch->tbl[d.seq].cons_cnt
     ENDIF
     dlsf_cons_cnt = (dlsf_cons_cnt+ cur_sch->tbl[d.seq].cons_cnt)
    WITH nocounter
   ;end select
   IF (dlsf_max_c_cnt > 0)
    INSERT  FROM dmcons c,
      (dummyt d  WITH seq = value(cur_sch->tbl_cnt)),
      (dummyt d2  WITH seq = value(dlsf_max_c_cnt))
     SET c.seq = 1, c.table_name = cur_sch->tbl[d.seq].tbl_name, c.constraint_name = cur_sch->tbl[d
      .seq].cons[d2.seq].cons_name,
      c.full_cons_name = cur_sch->tbl[d.seq].cons[d2.seq].full_cons_name, c.constraint_type = cur_sch
      ->tbl[d.seq].cons[d2.seq].cons_type, c.status_ind = cur_sch->tbl[d.seq].cons[d2.seq].status_ind,
      c.r_constraint_name = cur_sch->tbl[d.seq].cons[d2.seq].r_constraint_name, c.parent_table_name
       = cur_sch->tbl[d.seq].cons[d2.seq].parent_table, c.parent_table_columns = cur_sch->tbl[d.seq].
      cons[d2.seq].parent_table_columns,
      c.delete_rule = cur_sch->tbl[d.seq].cons[d2.seq].delete_rule
     PLAN (d
      WHERE (cur_sch->tbl[d.seq].capture_ind=1))
      JOIN (d2
      WHERE (d2.seq <= cur_sch->tbl[d.seq].cons_cnt))
      JOIN (c
      WHERE (cur_sch->tbl[d.seq].tbl_name=c.table_name)
       AND (cur_sch->tbl[d.seq].cons[d2.seq].cons_name=c.constraint_name))
     WITH nocounter, outerjoin = d2, dontexist
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "POPULATE DMCONSCOL SCHEMA FILE WITH CONSTRAINT COLUMN INFO"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     d.seq
     FROM (dummyt d  WITH seq = value(cur_sch->tbl_cnt)),
      (dummyt d2  WITH seq = value(dlsf_max_c_cnt))
     PLAN (d)
      JOIN (d2
      WHERE (d2.seq <= cur_sch->tbl[d.seq].cons_cnt))
     DETAIL
      IF ((cur_sch->tbl[d.seq].cons[d2.seq].cons_col_cnt > dlsf_max_cc_cnt))
       dlsf_max_cc_cnt = cur_sch->tbl[d.seq].cons[d2.seq].cons_col_cnt
      ENDIF
      dlsf_ccol_cnt = (dlsf_ccol_cnt+ cur_sch->tbl[d.seq].cons[d2.seq].cons_col_cnt)
     WITH nocounter
    ;end select
    IF (dlsf_max_cc_cnt > 0)
     INSERT  FROM dmconscol cc,
       (dummyt d  WITH seq = value(cur_sch->tbl_cnt)),
       (dummyt d2  WITH seq = value(dlsf_max_c_cnt)),
       (dummyt d3  WITH seq = value(dlsf_max_cc_cnt))
      SET cc.seq = 1, cc.table_name = cur_sch->tbl[d.seq].tbl_name, cc.constraint_name = cur_sch->
       tbl[d.seq].cons[d2.seq].cons_name,
       cc.column_name = cur_sch->tbl[d.seq].cons[d2.seq].cons_col[d3.seq].col_name, cc.position =
       cur_sch->tbl[d.seq].cons[d2.seq].cons_col[d3.seq].col_position
      PLAN (d
       WHERE (cur_sch->tbl[d.seq].capture_ind=1))
       JOIN (d2
       WHERE (d2.seq <= cur_sch->tbl[d.seq].cons_cnt))
       JOIN (d3
       WHERE (d3.seq <= cur_sch->tbl[d.seq].cons[d2.seq].cons_col_cnt))
       JOIN (cc
       WHERE (cur_sch->tbl[d.seq].tbl_name=cc.table_name)
        AND (cur_sch->tbl[d.seq].cons[d2.seq].cons_name=cc.constraint_name)
        AND (cur_sch->tbl[d.seq].cons[d2.seq].cons_col[d3.seq].col_name=cc.column_name))
      WITH nocounter, outerjoin = d3, dontexist
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ELSE
     SET dm_err->err_ind = 1
     CALL disp_msg("No column information found for constraints.",dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE del_sch_files(null)
   DECLARE dsf_cnt = i4 WITH protect, noconstant(0)
   DECLARE dsf_name = vc WITH protect, noconstant("")
   FOR (dsf_cnt = 1 TO dm2_sch_file->file_cnt)
     SET dsf_name = build(dm2_sch_file->file_prefix,cnvtlower(dm2_sch_file->qual[dsf_cnt].file_suffix
       ))
     IF (del_sch_file(build(dm2_sch_file->dest_dir_osfmt,dsf_name,".dat"))=0)
      SET dm_err->err_ind = 1
      RETURN(0)
     ENDIF
     IF ((dm2_sys_misc->cur_os != "AXP"))
      IF (del_sch_file(build(dm2_sch_file->dest_dir_osfmt,dsf_name,".idx"))=0)
       SET dm_err->err_ind = 1
       RETURN(0)
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
#end_sch_files_inc
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
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
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 IF ( NOT (validate(rb_data,0)))
  FREE SET rb_data
  RECORD rb_data(
    1 in_house = i2
    1 batch_dt_tm = dq8
    1 env_id = f8
    1 execution = vc
    1 manual_readme_id = f8
    1 low_proj_name = vc
    1 high_proj_name = vc
    1 readme[*]
      2 id = i4
      2 instance = i4
      2 name = vc
      2 description = vc
      2 ocd = i4
      2 driver_table = vc
      2 driver_count = i4
      2 estimated_time = f8
      2 skip = i2
      2 execution = vc
    1 inactive[*]
      2 name = vc
      2 instance = i4
  )
 ENDIF
 IF ( NOT (validate(readme_error,0)))
  FREE SET readme_error
  RECORD readme_error(
    1 readme[*]
      2 readme_id = f8
      2 instance = i4
      2 description = vc
      2 message = vc
      2 ocd = i4
      2 options = vc
  )
 ENDIF
 IF (validate(dm2_rr_misc->dm2_toolset_usage," ")=" "
  AND validate(dm2_rr_misc->dm2_toolset_usage,"1")="1")
  FREE RECORD dm2_rr_misc
  RECORD dm2_rr_misc(
    1 dm2_toolset_usage = vc
    1 readme_errors_ind = i2
    1 env_id = f8
    1 batch_dt_tm = dq8
    1 process_type = c2
    1 package_number = i4
    1 execution = vc
    1 manual_readme_id = f8
    1 low_proj_name = vc
    1 high_proj_name = vc
  )
  SET dm2_rr_misc->dm2_toolset_usage = "NOT_SET"
  SET dm2_rr_misc->readme_errors_ind = 0
  SET dm2_rr_misc->env_id = 0.0
  SET dm2_rr_misc->batch_dt_tm = cnvtdatetimeutc("01-JAN-1800")
  SET dm2_rr_misc->process_type = ""
  SET dm2_rr_misc->package_number = 0
  SET dm2_rr_misc->execution = "NOT_SET"
  SET dm2_rr_misc->low_proj_name = ""
  SET dm2_rr_misc->high_proj_name = ""
 ENDIF
 IF ((validate(dm2_rr_spcchk->readme_cnt,- (1))=- (1))
  AND (validate(dm2_rr_spcchk->readme_cnt,- (2))=- (2)))
  FREE SET dm2_rr_spcchk
  RECORD dm2_rr_spcchk(
    1 space_needed = i2
    1 preup_space_needed = i2
    1 readme_cnt = i4
    1 readme_list[*]
      2 readme_id = f8
      2 spcchk_readme_id = f8
      2 script = vc
      2 tbl_cnt = i4
      2 tbl_list[*]
        3 table_name = vc
        3 large_data_loaded = i2
        3 insert_row_cnt = f8
        3 col_updt_cnt = i4
        3 col_updt[*]
          4 update_row_cnt = f8
          4 column_name = vc
  )
  SET dm2_rr_spcchk->readme_cnt = 0
  SET dm2_rr_spcchk->preup_space_needed = 0
  SET dm2_rr_spcchk->space_needed = 0
 ENDIF
 IF ((validate(dm2_rr_spc_needs->tbl_cnt,- (1))=- (1))
  AND (validate(dm2_rr_spc_needs->tbl_cnt,- (2))=- (2)))
  FREE SET dm2_rr_spc_needs
  RECORD dm2_rr_spc_needs(
    1 space_needed = i2
    1 tbl_cnt = i4
    1 tbl[*]
      2 table_name = vc
      2 skip_ind = i2
      2 large_data_loaded = i2
      2 insert_row_cnt = f8
      2 col_updt_cnt = i4
      2 col_updt[*]
        3 update_row_cnt = f8
        3 column_name = vc
      2 tgt_idx = i4
      2 cur_idx = i4
      2 space_needed = f8
      2 ind_cnt = i4
      2 ind[*]
        3 ind_name = vc
        3 tgt_idx = i4
        3 cur_idx = i4
        3 space_needed = f8
  )
  SET dm2_rr_spc_needs->tbl_cnt = 0
 ENDIF
 IF (validate(drr_readmes_to_run->readme_cnt,0)=0
  AND validate(drr_readmes_to_run->readme_cnt,1)=1)
  FREE RECORD drr_readmes_to_run
  RECORD drr_readmes_to_run(
    1 readme_cnt = i4
    1 readme[*]
      2 readme_id = f8
      2 instance = i4
      2 name = vc
      2 description = c50
      2 ocd = i4
      2 execution = vc
      2 execution_order = vc
      2 category = vc
      2 driver_table = vc
      2 execution_time = f8
      2 status = vc
      2 start_dt_tm = dq8
      2 end_dt_tm = dq8
      2 skip = i2
      2 driver_count = i4
      2 estimated_time = f8
      2 spchk_readme_cnt = i4
      2 spchk_readme[*]
        3 readme_id = f8
        3 instance = i4
        3 ocd = i4
        3 execution = vc
        3 script = vc
        3 skip = i2
    1 timer_readme_cnt = i4
    1 timer_readme[*]
      2 parent_readme_id = f8
      2 readme_id = f8
      2 instance = i4
      2 ocd = i4
      2 execution = vc
      2 script = vc
      2 skip = i2
    1 inactive_cnt = i4
    1 inactive[*]
      2 name = vc
      2 instance = i4
  )
 ENDIF
 IF ((validate(dm2_rr_defined,- (1))=- (1))
  AND (validate(dm2_rr_defined,- (2))=- (2)))
  DECLARE dm2_rr_defined = i2 WITH public, constant(1)
  DECLARE dm2_rr_error = i2 WITH public, constant(0)
  DECLARE dm2_rr_warning = i2 WITH public, constant(1)
  DECLARE dm2_rr_info = i2 WITH public, constant(2)
  DECLARE dm2_rr_readme = vc WITH public, constant("README")
  DECLARE dm2_rr_dbimport = vc WITH public, constant("DBIMPORT")
  DECLARE dm2_rr_oracle = vc WITH public, constant("ORACLE")
  DECLARE dm2_rr_oracle_ref = vc WITH public, constant("ORACLEREF")
  DECLARE dm2_rr_ccl_dbimport = vc WITH public, constant("CCLDBIMPORT")
  DECLARE dm2_rr_tbl_import = vc WITH public, constant("TABLEIMPORT")
  DECLARE dm2_rr_readme_rback = vc WITH public, constant("README:RBACK")
  DECLARE dm2_rr_running = vc WITH public, constant("RUNNING")
  DECLARE dm2_rr_done = vc WITH public, constant("SUCCESS")
  DECLARE dm2_rr_failed = vc WITH public, constant("FAILED")
  DECLARE dm2_rr_reset = vc WITH public, constant("RESET")
  DECLARE dm2_rr_pre_schema_up = vc WITH public, constant("PREUP")
  DECLARE dm2_rr_post_schema_up = vc WITH public, constant("POSTUP")
  DECLARE dm2_rr_post_schema_up2 = vc WITH public, constant("POSTUP2")
  DECLARE dm2_rr_pre_cycle = vc WITH public, constant("PRECYCLE")
  DECLARE dm2_rr_pre_schema_down = vc WITH public, constant("PREDOWN")
  DECLARE dm2_rr_post_schema_down = vc WITH public, constant("POSTDOWN")
  DECLARE dm2_rr_uptime = vc WITH public, constant("UP")
  DECLARE dm2_rr_timer = vc WITH public, constant("RDMTIMER")
 ENDIF
 IF (validate(drr_killed_appl->appl_cnt,1)=1
  AND validate(drr_killed_appl->appl_cnt,2)=2)
  FREE RECORD drr_killed_appl
  RECORD drr_killed_appl(
    1 appl_cnt = i4
    1 appl[*]
      2 appl_id = vc
  )
  SET drr_killed_appl->appl_cnt = 0
 ENDIF
 DECLARE dm2_rr_toolset_usage(null) = i2
 DECLARE dm2_rr_clean_stranded_readmes(drcsr_env_id=f8) = i2
 DECLARE drr_load_readmes_to_run(null) = i2
 DECLARE drr_load_space_chk_readmes(dlscr_execution=vc,dlscr_spcchk_flag=i2(ref)) = i2
 DECLARE drr_load_timing_readmes(null) = i2
 DECLARE drr_alert_killed_appl(daka_load_ind=i2,daka_fmt_appl_id=vc,daka_kill_ind=i2(ref)) = i2
 SUBROUTINE dm2_rr_toolset_usage(null)
   DECLARE drtu_found_ind = i2 WITH protect, noconstant(0)
   IF ((dm2_rr_misc->dm2_toolset_usage != "NOT_SET"))
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Determining if DM_INFO exists."
   IF ((dm_err->debug_flag > 0))
    CALL echo(dm_err->eproc)
   ENDIF
   IF (dm2_table_and_ccldef_exists("DM_INFO",drtu_found_ind)=0)
    RETURN(0)
   ENDIF
   IF (drtu_found_ind=0)
    SET dm2_rr_misc->dm2_toolset_usage = "Y"
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Check for DM_README_TOOLSET row."
   IF ((dm_err->debug_flag > 0))
    CALL echo(dm_err->eproc)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DATA MANAGEMENT"
     AND d.info_name="DM_README_TOOLSET"
    WITH nocounter
   ;end select
   SET dm_err->ecode = error(dm_err->emsg,1)
   IF ((dm_err->ecode != 0))
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dm2_rr_misc->dm2_toolset_usage = "N"
   ELSEIF (curqual=0)
    SET dm2_rr_misc->dm2_toolset_usage = "Y"
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_rr_clean_stranded_readmes(drcsr_env_id)
   DECLARE rcsr_cnt = i4 WITH protect, noconstant(0)
   DECLARE rcsr_fmt_appl_id = vc WITH protect, noconstant(" ")
   DECLARE rcsr_error_msg = vc WITH protect, noconstant(" ")
   DECLARE rcsr_load_ind = i2 WITH protect, noconstant(1)
   DECLARE rcsr_kill_ind = i2 WITH protect, noconstant(0)
   FREE RECORD rcsr_appl_rs
   RECORD rcsr_appl_rs(
     1 rcsr_appl_cnt = i4
     1 rcsr_appl[*]
       2 rcsr_appl_id = vc
       2 rcsr_validity = vc
   )
   SET dm_err->eproc = "Get distinct application ids."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT DISTINCT INTO "nl:"
    l.appl_ident
    FROM dm_ocd_log l
    WHERE l.environment_id=drcsr_env_id
     AND l.project_type=dm2_rr_readme
     AND ((l.status=dm2_rr_running) OR (l.status=null))
    HEAD REPORT
     rcsr_cnt = 0
    DETAIL
     rcsr_cnt = (rcsr_cnt+ 1)
     IF (mod(rcsr_cnt,10)=1)
      stat = alterlist(rcsr_appl_rs->rcsr_appl,(rcsr_cnt+ 9))
     ENDIF
     IF (isnumeric(l.appl_ident)=0)
      rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_validity = "INVALID"
     ELSE
      rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_validity = "VALID"
     ENDIF
     rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_appl_id = l.appl_ident
    FOOT REPORT
     rcsr_appl_rs->rcsr_appl_cnt = rcsr_cnt, stat = alterlist(rcsr_appl_rs->rcsr_appl,rcsr_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((rcsr_appl_rs->rcsr_appl_cnt > 0))
    SET rcsr_cnt = 0
    FOR (rcsr_cnt = 1 TO rcsr_appl_rs->rcsr_appl_cnt)
      IF ((rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_validity="INVALID"))
       SET rcsr_error_msg = "Session executing readme is no longer active"
       SET dm_err->eproc = "Update stranded readme process to failed."
       IF ((dm_err->debug_flag > 0))
        CALL disp_msg(" ",dm_err->logfile,0)
       ENDIF
       UPDATE  FROM dm_ocd_log l
        SET l.status = dm2_rr_failed, l.message = rcsr_error_msg, l.start_dt_tm = evaluate(nullind(l
           .start_dt_tm),1,cnvtdatetime(curdate,curtime3),l.start_dt_tm)
        WHERE l.environment_id=drcsr_env_id
         AND l.project_type=dm2_rr_readme
         AND ((l.status=dm2_rr_running) OR (l.status = null))
         AND ((l.appl_ident = null) OR ((l.appl_ident=rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_appl_id)
        ))
        WITH nocounter
       ;end update
       IF (check_error(dm_err->eproc)=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        RETURN(0)
       ELSE
        COMMIT
       ENDIF
      ELSE
       CASE (dm2_get_appl_status(value(rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_appl_id)))
        OF "I":
         SET dm_err->eproc = "Update inactive readme process to failed."
         SET rcsr_fmt_appl_id = rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_appl_id
         IF (drr_alert_killed_appl(rcsr_load_ind,rcsr_fmt_appl_id,rcsr_kill_ind)=0)
          RETURN(0)
         ENDIF
         SET rcsr_load_ind = 0
         IF (rcsr_kill_ind=1)
          SET rcsr_error_msg = dir_kill_clause
         ELSE
          SET rcsr_error_msg = "Session executing readme is no longer active."
         ENDIF
         IF ((dm_err->debug_flag > 0))
          CALL disp_msg(" ",dm_err->logfile,0)
         ENDIF
         UPDATE  FROM dm_ocd_log l
          SET l.status = dm2_rr_failed, l.message = rcsr_error_msg, l.start_dt_tm = evaluate(nullind(
             l.start_dt_tm),1,cnvtdatetime(curdate,curtime3),l.start_dt_tm)
          WHERE l.environment_id=drcsr_env_id
           AND l.appl_ident=value(rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_appl_id)
           AND l.project_type=dm2_rr_readme
           AND ((l.status=dm2_rr_running) OR (l.status = null))
          WITH nocounter
         ;end update
         IF (check_error(dm_err->eproc)=1)
          ROLLBACK
          CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
          RETURN(0)
         ELSE
          COMMIT
         ENDIF
        OF "A":
         IF ((dm_err->debug_flag > 0))
          CALL echo(build("Application Id ",rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_appl_id,
            " is active."))
         ENDIF
        OF "E":
         IF ((dm_err->debug_flag > 0))
          CALL echo("Error Detected in dm2_get_appl_status")
         ENDIF
         RETURN(0)
       ENDCASE
      ENDIF
    ENDFOR
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo("********** No application IDs associated with stranded readmes **********")
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_load_readmes_to_run(null)
   DECLARE dlrr_cnt = i4 WITH protect, noconstant(0)
   FREE RECORD drr_readmes_on_pkg
   RECORD drr_readmes_on_pkg(
     1 cnt = i4
     1 qual[*]
       2 readme_id = f8
       2 instance = i4
       2 ocd = f8
       2 skip = i2
       2 run_once_ind = i2
       2 name = vc
       2 description = c50
       2 execution = vc
       2 category = vc
       2 driver_table = vc
       2 execution_time = f8
       2 skip = i2
       2 driver_count = i4
       2 estimated_time = f8
   )
   IF ((drr_readmes_to_run->readme_cnt > 0))
    SET drr_readmes_to_run->readme_cnt = 0
    SET stat = alterlist(drr_readmes_to_run->readme,0)
   ENDIF
   IF ((drr_readmes_to_run->inactive_cnt > 0))
    SET drr_readmes_to_run->inactive_cnt = 0
    SET stat = alterlist(drr_readmes_to_run->inactive,0)
   ENDIF
   IF ( NOT ((dm2_rr_misc->process_type IN ("PI", "IH", "MM"))))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating process type."
    SET dm_err->emsg = "Unrecognized process type."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm2_rr_misc->env_id=0))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating environment ID."
    SET dm_err->emsg = "Invalid environment_id."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm2_rr_misc->process_type="PI"))
    IF ((dm2_rr_misc->package_number=0))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validating package number."
     SET dm_err->emsg =
     "Package number or batch number was 0.  Cannot process readmes for package install."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ELSEIF ( NOT ((dm2_rr_misc->execution IN ("ALL", "PREUP", "POSTUP", "POSTUP2", "PRECYCLE",
    "PREDOWN", "POSTDOWN", "UP"))))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validating process type."
     SET dm_err->emsg = "Unrecognized process type.  Cannot process readmes."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ELSEIF ((dm2_rr_misc->process_type="IH")
    AND ((cnvtint(dm2_rr_misc->low_proj_name) < 0) OR (cnvtint(dm2_rr_misc->high_proj_name) <= 0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating inhouse project range."
    SET dm_err->emsg = "Invalid project range.  Cannot process inhouse readmes."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ELSEIF ((dm2_rr_misc->process_type="MM")
    AND  NOT ((dm2_rr_misc->execution IN ("ALL", "PREUP", "POSTUP", "PREDOWN", "POSTDOWN",
   "UP"))))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating process type."
    SET dm_err->emsg = "Unrecognized process type.  Cannot process readmes."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET rdm_cnt = 0
   SET inactive_cnt = 0
   IF ((dm2_rr_misc->process_type="PI"))
    SET dm_err->eproc = "Gathering list of readmes on plan..."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_ocd_readme o
     WHERE (o.ocd=dm2_rr_misc->package_number)
     ORDER BY o.readme_id
     DETAIL
      rdm_cnt = (rdm_cnt+ 1)
      IF (mod(rdm_cnt,100)=1)
       stat = alterlist(drr_readmes_on_pkg->qual,(rdm_cnt+ 99))
      ENDIF
      drr_readmes_on_pkg->qual[rdm_cnt].readme_id = o.readme_id, drr_readmes_on_pkg->qual[rdm_cnt].
      name = trim(cnvtstring(o.readme_id),3), drr_readmes_on_pkg->qual[rdm_cnt].ocd = o.ocd,
      drr_readmes_on_pkg->qual[rdm_cnt].instance = o.instance
     FOOT REPORT
      stat = alterlist(drr_readmes_on_pkg->qual,rdm_cnt), drr_readmes_on_pkg->cnt = rdm_cnt
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF ((drr_readmes_on_pkg->cnt=0))
     SET dm_err->eproc = "No readmes found to run."
     CALL disp_msg("",dm_err->logfile,0)
     RETURN(1)
    ENDIF
    SELECT INTO "nl:"
     FROM dm_readme r,
      dm_ocd_readme o,
      dm_alpha_features_env a,
      (dummyt d  WITH seq = value(drr_readmes_on_pkg->cnt))
     PLAN (d)
      JOIN (r
      WHERE r.owner=currdbuser
       AND (r.readme_id=drr_readmes_on_pkg->qual[d.seq].readme_id)
       AND (r.instance > drr_readmes_on_pkg->qual[d.seq].instance))
      JOIN (o
      WHERE o.readme_id=r.readme_id
       AND o.ocd > 0
       AND o.instance=r.instance)
      JOIN (a
      WHERE a.alpha_feature_nbr=o.ocd
       AND (a.environment_id=dm2_rr_misc->env_id)
       AND  NOT (a.inst_mode IN ("PREVIEW", "BATCHPREVIEW")))
     ORDER BY r.readme_id, r.instance DESC
     HEAD r.readme_id
      IF (r.active_ind=0)
       CALL echo(concat("Instance ",build(r.instance)," from ",build(o.ocd)," for readme ",
        build(o.readme_id)," will be skipped due to being inactive on highest instance.")),
       drr_readmes_on_pkg->qual[d.seq].skip = 1
      ELSE
       CALL echo(concat("Replacing Instance ",build(drr_readmes_on_pkg->qual[d.seq].instance),
        " with instance ",build(r.instance)," from ",
        build(o.ocd)," for readme ",build(o.readme_id))), drr_readmes_on_pkg->qual[d.seq].instance =
       r.instance, drr_readmes_on_pkg->qual[d.seq].ocd = o.ocd
      ENDIF
     FOOT  r.readme_id
      row + 0
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Marking completed readmes as SKIPPED."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_ocd_log l,
      (dummyt d  WITH seq = value(drr_readmes_on_pkg->cnt))
     PLAN (d)
      JOIN (l
      WHERE (l.environment_id=dm2_rr_misc->env_id)
       AND l.project_type=dm2_rr_readme
       AND (l.project_name=drr_readmes_on_pkg->qual[d.seq].name)
       AND (l.ocd=drr_readmes_on_pkg->qual[d.seq].ocd)
       AND l.status=dm2_rr_done
       AND l.active_ind=1)
     DETAIL
      drr_readmes_on_pkg->qual[d.seq].skip = 1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Loading readme metadata."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_readme r,
      (dummyt d  WITH seq = value(drr_readmes_on_pkg->cnt))
     PLAN (d
      WHERE (drr_readmes_on_pkg->qual[d.seq].skip=0))
      JOIN (r
      WHERE (drr_readmes_on_pkg->qual[d.seq].readme_id=r.readme_id)
       AND (drr_readmes_on_pkg->qual[d.seq].instance=r.instance)
       AND r.owner=currdbuser)
     ORDER BY r.readme_id
     HEAD r.readme_id
      drr_readmes_on_pkg->qual[d.seq].readme_id = r.readme_id, drr_readmes_on_pkg->qual[d.seq].
      instance = r.instance, drr_readmes_on_pkg->qual[d.seq].name = trim(cnvtstring(r.readme_id),3),
      drr_readmes_on_pkg->qual[d.seq].execution = cnvtupper(trim(r.execution,3)), drr_readmes_on_pkg
      ->qual[d.seq].description = r.description, drr_readmes_on_pkg->qual[d.seq].driver_table =
      cnvtupper(trim(r.driver_table,3)),
      drr_readmes_on_pkg->qual[d.seq].execution_time = r.execution_time, drr_readmes_on_pkg->qual[d
      .seq].run_once_ind = r.run_once_ind, drr_readmes_on_pkg->qual[d.seq].estimated_time = 0,
      drr_readmes_on_pkg->qual[d.seq].driver_count = 0, drr_readmes_on_pkg->qual[d.seq].skip =
      evaluate(r.active_ind,0,1,0)
      IF ((drr_readmes_on_pkg->qual[d.seq].skip=1))
       CALL echo(concat("Skipping inactive readme ",build(r.readme_id)," instance ",build(r.instance)
        ))
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Skipping RUN ONCE Readmes"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_ocd_log l,
      (dummyt d  WITH seq = value(drr_readmes_on_pkg->cnt))
     PLAN (d
      WHERE (drr_readmes_on_pkg->qual[d.seq].skip=0)
       AND (drr_readmes_on_pkg->qual[d.seq].run_once_ind=1))
      JOIN (l
      WHERE (l.environment_id=dm2_rr_misc->env_id)
       AND l.project_type=dm2_rr_readme
       AND (l.project_name=drr_readmes_on_pkg->qual[d.seq].name)
       AND l.status=dm2_rr_done
       AND l.active_ind=1
       AND (l.project_instance=drr_readmes_on_pkg->qual[d.seq].instance))
     DETAIL
      drr_readmes_on_pkg->qual[d.seq].skip = 1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 1))
     CALL echorecord(drr_readmes_on_pkg)
    ENDIF
    SET rdm_cnt = 0
    FOR (dlrr_cnt = 1 TO drr_readmes_on_pkg->cnt)
      IF ((((dm2_rr_misc->execution != "ALL")
       AND (drr_readmes_on_pkg->qual[dlrr_cnt].execution=dm2_rr_misc->execution)) OR ((dm2_rr_misc->
      execution="ALL")
       AND (drr_readmes_on_pkg->qual[dlrr_cnt].execution IN ("PREUP", "POSTUP", "POSTUP2", "PRECYCLE",
      "PREDOWN",
      "POSTDOWN", "UP")))) )
       IF ((drr_readmes_on_pkg->qual[dlrr_cnt].skip=1)
        AND (drr_readmes_on_pkg->qual[dlrr_cnt].run_once_ind=1))
        CALL echo(concat("Skip run once readme:",drr_readmes_on_pkg->qual[dlrr_cnt].name))
       ELSE
        SET rdm_cnt = (rdm_cnt+ 1)
        SET stat = alterlist(drr_readmes_to_run->readme,rdm_cnt)
        SET drr_readmes_to_run->readme[rdm_cnt].readme_id = drr_readmes_on_pkg->qual[dlrr_cnt].
        readme_id
        SET drr_readmes_to_run->readme[rdm_cnt].instance = drr_readmes_on_pkg->qual[dlrr_cnt].
        instance
        SET drr_readmes_to_run->readme[rdm_cnt].name = drr_readmes_on_pkg->qual[dlrr_cnt].name
        SET drr_readmes_to_run->readme[rdm_cnt].execution = drr_readmes_on_pkg->qual[dlrr_cnt].
        execution
        SET drr_readmes_to_run->readme[rdm_cnt].description = drr_readmes_on_pkg->qual[dlrr_cnt].
        description
        SET drr_readmes_to_run->readme[rdm_cnt].ocd = drr_readmes_on_pkg->qual[dlrr_cnt].ocd
        SET drr_readmes_to_run->readme[rdm_cnt].driver_table = drr_readmes_on_pkg->qual[dlrr_cnt].
        driver_table
        SET drr_readmes_to_run->readme[rdm_cnt].execution_time = drr_readmes_on_pkg->qual[dlrr_cnt].
        execution_time
        SET drr_readmes_to_run->readme[rdm_cnt].estimated_time = drr_readmes_on_pkg->qual[dlrr_cnt].
        estimated_time
        SET drr_readmes_to_run->readme[rdm_cnt].driver_count = drr_readmes_on_pkg->qual[dlrr_cnt].
        driver_count
        SET drr_readmes_to_run->readme[rdm_cnt].skip = drr_readmes_on_pkg->qual[dlrr_cnt].skip
        SET drr_readmes_to_run->readme_cnt = rdm_cnt
       ENDIF
      ENDIF
    ENDFOR
    IF ((dm_err->debug_flag > 1))
     CALL echorecord(drr_readmes_to_run)
    ENDIF
    IF ((drr_readmes_to_run->readme_cnt=0))
     SET dm_err->eproc = "No readmes found to run."
     CALL disp_msg("",dm_err->logfile,0)
     RETURN(1)
    ENDIF
    SET rdm_cnt = 0
    FOR (rdm_cnt = 1 TO drr_readmes_to_run->readme_cnt)
      IF ((drr_readmes_to_run->readme[rdm_cnt].skip=0))
       CALL echo(concat("Readme ",build(drr_readmes_to_run->readme[rdm_cnt].readme_id)," will run."))
      ENDIF
    ENDFOR
   ELSEIF ((dm2_rr_misc->process_type="IH"))
    SET dm_err->eproc = "Getting list of readmes for inhouse processing."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     r.readme_id
     FROM dm_project_status_env s,
      dm_readme r
     PLAN (s
      WHERE (s.environment_id=dm2_rr_misc->env_id)
       AND s.proj_type=dm2_rr_readme
       AND cnvtint(s.proj_name) > 0
       AND s.proj_name BETWEEN dm2_rr_misc->low_proj_name AND dm2_rr_misc->high_proj_name
       AND s.dm_status = null)
      JOIN (r
      WHERE r.readme_id=cnvtint(s.proj_name)
       AND r.instance=s.source_set_instance
       AND r.owner=currdbuser)
     ORDER BY r.readme_id, r.instance DESC
     HEAD r.readme_id
      IF (r.active_ind)
       rdm_cnt = (rdm_cnt+ 1)
       IF (mod(rdm_cnt,10)=1)
        stat = alterlist(drr_readmes_to_run->readme,(rdm_cnt+ 9))
       ENDIF
       drr_readmes_to_run->readme[rdm_cnt].readme_id = r.readme_id, drr_readmes_to_run->readme[
       rdm_cnt].instance = r.instance, drr_readmes_to_run->readme[rdm_cnt].name = trim(cnvtstring(r
         .readme_id),3),
       drr_readmes_to_run->readme[rdm_cnt].execution = cnvtupper(trim(r.execution,3)),
       drr_readmes_to_run->readme[rdm_cnt].description = trim(r.description,3), drr_readmes_to_run->
       readme[rdm_cnt].driver_table = cnvtupper(trim(r.driver_table,3)),
       drr_readmes_to_run->readme[rdm_cnt].execution_time = r.execution_time, drr_readmes_to_run->
       readme[rdm_cnt].estimated_time = 0, drr_readmes_to_run->readme[rdm_cnt].driver_count = 0
       IF ((drr_readmes_to_run->readme[rdm_cnt].execution IN ("PRESPCHK", "POSTSPCHK", "RDMTIMER")))
        drr_readmes_to_run->readme[rdm_cnt].skip = 1
       ENDIF
      ELSE
       inactive_cnt = (inactive_cnt+ 1)
       IF (mod(inactive_cnt,10)=1)
        stat = alterlist(drr_readmes_to_run->inactive,(inactive_cnt+ 9))
       ENDIF
       drr_readmes_to_run->inactive[inactive_cnt].name = trim(cnvtstring(r.readme_id),3),
       drr_readmes_to_run->inactive[inactive_cnt].instance = r.instance
      ENDIF
     FOOT REPORT
      stat = alterlist(drr_readmes_to_run->inactive,inactive_cnt), stat = alterlist(
       drr_readmes_to_run->readme,rdm_cnt), drr_readmes_to_run->readme_cnt = rdm_cnt,
      drr_readmes_to_run->inactive_cnt = inactive_cnt
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ELSEIF ((dm2_rr_misc->process_type="MM"))
    SET dm_err->eproc = "Gathering list of readmes to run..."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (validate(doc->source_ocd_cnt,- (1)) > 0)
     SELECT INTO "nl:"
      FROM dm_ocd_readme o,
       dm_readme r,
       (dummyt d  WITH seq = value(doc->source_ocd_cnt))
      PLAN (d)
       JOIN (o
       WHERE (o.ocd=doc->qual[d.seq].ocd_nbr))
       JOIN (r
       WHERE r.readme_id=o.readme_id
        AND r.instance=o.instance
        AND  NOT ( EXISTS (
       (SELECT
        l.project_name
        FROM dm_ocd_log l,
         dm_readme x
        WHERE x.readme_id=r.readme_id
         AND x.run_once_ind=1
         AND (l.environment_id=dm2_rr_misc->env_id)
         AND l.project_type=dm2_rr_readme
         AND l.ocd > 0
         AND l.project_name=trim(cnvtstring(x.readme_id),3)
         AND l.project_instance >= r.instance
         AND l.status=dm2_rr_done
         AND l.active_ind=1))))
      ORDER BY r.readme_id, r.instance DESC, o.ocd DESC
      HEAD REPORT
       row + 0
      HEAD r.readme_id
       IF (r.active_ind=1
        AND (r.execution=dm2_rr_misc->execution))
        rdm_cnt = (rdm_cnt+ 1)
        IF (mod(rdm_cnt,10)=1)
         stat = alterlist(drr_readmes_to_run->readme,(rdm_cnt+ 9))
        ENDIF
        drr_readmes_to_run->readme[rdm_cnt].readme_id = r.readme_id, drr_readmes_to_run->readme[
        rdm_cnt].instance = r.instance, drr_readmes_to_run->readme[rdm_cnt].name = trim(cnvtstring(r
          .readme_id),3),
        drr_readmes_to_run->readme[rdm_cnt].description = r.description, drr_readmes_to_run->readme[
        rdm_cnt].ocd = o.ocd, drr_readmes_to_run->readme[rdm_cnt].driver_table = cnvtupper(trim(r
          .driver_table,3)),
        drr_readmes_to_run->readme[rdm_cnt].execution_time = r.execution_time, drr_readmes_to_run->
        readme[rdm_cnt].estimated_time = 0, drr_readmes_to_run->readme[rdm_cnt].driver_count = 0
       ENDIF
      FOOT REPORT
       stat = alterlist(drr_readmes_to_run->readme,rdm_cnt), drr_readmes_to_run->readme_cnt = rdm_cnt
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = "Marking completed readmes as SKIPPED."
     CALL disp_msg(" ",dm_err->logfile,0)
     SELECT INTO "nl:"
      l.status
      FROM dm_ocd_log l,
       (dummyt d  WITH seq = value(rdm_cnt))
      PLAN (d)
       JOIN (l
       WHERE (l.environment_id=dm2_rr_misc->env_id)
        AND l.project_type=dm2_rr_readme
        AND (l.project_name=drr_readmes_to_run->readme[d.seq].name)
        AND (l.ocd=drr_readmes_to_run->readme[d.seq].ocd)
        AND l.status=dm2_rr_done
        AND l.active_ind=1)
      DETAIL
       drr_readmes_to_run->readme[d.seq].skip = 1
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
    ELSE
     SELECT INTO "nl:"
      status = decode(l.seq,l.status,"NOT RUN"), start_dt_tm = decode(l.seq,l.start_dt_tm,
       cnvtdatetime(curdate,curtime)), end_dt_tm = decode(l.seq,l.end_dt_tm,cnvtdatetime(curdate,
        curtime))
      FROM dm_alpha_features_env a,
       dm_ocd_readme o,
       dm_readme r,
       dm_ocd_log l,
       dummyt d
      PLAN (a
       WHERE (a.environment_id=dm2_rr_misc->env_id)
        AND a.curr_migration_ind=1)
       JOIN (o
       WHERE o.ocd=a.alpha_feature_nbr)
       JOIN (r
       WHERE r.readme_id=o.readme_id
        AND r.instance=o.instance
        AND  NOT ( EXISTS (
       (SELECT
        m.project_name
        FROM dm_ocd_log m,
         dm_readme x
        WHERE x.readme_id=r.readme_id
         AND x.run_once_ind=1
         AND (m.environment_id=dm2_rr_misc->env_id)
         AND m.project_type=dm2_rr_readme
         AND m.project_name=trim(cnvtstring(x.readme_id),3)
         AND m.status=dm2_rr_done
         AND m.ocd != o.ocd))))
       JOIN (d)
       JOIN (l
       WHERE (l.environment_id=dm2_rr_misc->env_id)
        AND l.project_type=dm2_rr_readme
        AND trim(cnvtstring(r.readme_id),3)=l.project_name
        AND l.ocd=o.ocd
        AND l.project_instance=r.instance)
      ORDER BY r.readme_id, r.instance DESC, o.ocd DESC
      HEAD r.readme_id
       IF (r.active_ind=1)
        rdm_cnt = (rdm_cnt+ 1)
        IF (mod(rdm_cnt,10)=1)
         stat = alterlist(drr_readmes_to_run->readme,(rdm_cnt+ 9))
        ENDIF
        drr_readmes_to_run->readme[rdm_cnt].readme_id = r.readme_id, drr_readmes_to_run->readme[
        rdm_cnt].instance = r.instance, drr_readmes_to_run->readme[rdm_cnt].description = trim(r
         .description),
        drr_readmes_to_run->readme[rdm_cnt].ocd = o.ocd, drr_readmes_to_run->readme[rdm_cnt].
        execution = cnvtupper(trim(r.execution,3)), drr_readmes_to_run->readme[rdm_cnt].driver_table
         = cnvtupper(trim(r.driver_table,3)),
        drr_readmes_to_run->readme[rdm_cnt].execution_time = r.execution_time, drr_readmes_to_run->
        readme[rdm_cnt].status = status, drr_readmes_to_run->readme[rdm_cnt].start_dt_tm =
        start_dt_tm,
        drr_readmes_to_run->readme[rdm_cnt].end_dt_tm = end_dt_tm, drr_readmes_to_run->readme[rdm_cnt
        ].estimated_time = 0, drr_readmes_to_run->readme[rdm_cnt].driver_count = 0
       ENDIF
      FOOT REPORT
       stat = alterlist(drr_readmes_to_run->readme,rdm_cnt), drr_readmes_to_run->readme_cnt = rdm_cnt
      WITH nocounter, outerjoin = d
     ;end select
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag >= 2))
    CALL echorecord(drr_readmes_to_run)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_load_space_chk_readmes(dlscr_execution,dlscr_spcchk_flag)
   DECLARE dlscr_dyn_where = vc WITH protect, noconstant("")
   IF (dlscr_execution="ALL")
    SET dlscr_dyn_where = "r.execution in ('PRESPCHK', 'POSTSPCHK')"
   ELSE
    SET dlscr_dyn_where = concat('r.execution = "',trim(dlscr_execution),'"')
   ENDIF
   SET dm_err->eproc = "Find readmes that require space check."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_readme r,
     dm_ocd_readme o,
     dm_alpha_features_env a,
     (dummyt d  WITH seq = value(drr_readmes_to_run->readme_cnt))
    PLAN (d
     WHERE (drr_readmes_to_run->readme[d.seq].skip=0))
     JOIN (r
     WHERE (r.parent_readme_id=drr_readmes_to_run->readme[d.seq].readme_id)
      AND parser(dlscr_dyn_where)
      AND r.owner=currdbuser)
     JOIN (o
     WHERE o.readme_id=r.readme_id
      AND o.ocd > 0
      AND o.instance=r.instance)
     JOIN (a
     WHERE a.alpha_feature_nbr=o.ocd
      AND (a.environment_id=dm2_rr_misc->env_id))
    ORDER BY r.readme_id, r.instance DESC, o.ocd DESC
    HEAD r.readme_id
     IF (r.active_ind=1)
      dlscr_spcchk_flag = 1, drr_readmes_to_run->readme[d.seq].spchk_readme_cnt = (drr_readmes_to_run
      ->readme[d.seq].spchk_readme_cnt+ 1), stat = alterlist(drr_readmes_to_run->readme[d.seq].
       spchk_readme,drr_readmes_to_run->readme[d.seq].spchk_readme_cnt),
      drr_readmes_to_run->readme[d.seq].spchk_readme[drr_readmes_to_run->readme[d.seq].
      spchk_readme_cnt].readme_id = r.readme_id, drr_readmes_to_run->readme[d.seq].spchk_readme[
      drr_readmes_to_run->readme[d.seq].spchk_readme_cnt].instance = r.instance, drr_readmes_to_run->
      readme[d.seq].spchk_readme[drr_readmes_to_run->readme[d.seq].spchk_readme_cnt].ocd = o.ocd,
      drr_readmes_to_run->readme[d.seq].spchk_readme[drr_readmes_to_run->readme[d.seq].
      spchk_readme_cnt].execution = r.execution, drr_readmes_to_run->readme[d.seq].spchk_readme[
      drr_readmes_to_run->readme[d.seq].spchk_readme_cnt].script = cnvtupper(r.script),
      drr_readmes_to_run->readme[d.seq].spchk_readme[drr_readmes_to_run->readme[d.seq].
      spchk_readme_cnt].skip = 0
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_load_timing_readmes(null)
   SET dm_err->eproc = "Gathering timing readme data"
   CALL disp_msg("",dm_err->logfile,0)
   SET timer_cnt = 0
   IF ((drr_readmes_to_run->timer_readme_cnt > 0))
    SET drr_readmes_to_run->timer_readme_cnt = 0
    SET stat = alterlist(drr_readmes_to_run->timer_readme,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_ocd_readme o,
     dm_readme r
    PLAN (o
     WHERE (o.ocd=dm2_rr_misc->package_number))
     JOIN (r
     WHERE r.owner=currdbuser
      AND r.readme_id=o.readme_id
      AND r.instance=o.instance
      AND r.execution="RDMTIMER")
    ORDER BY r.readme_id, r.instance DESC, o.ocd DESC
    HEAD REPORT
     row + 0
    HEAD r.readme_id
     IF (r.active_ind=1)
      timer_cnt = (timer_cnt+ 1)
      IF (mod(timer_cnt,10)=1)
       stat = alterlist(drr_readmes_to_run->timer_readme,(timer_cnt+ 9))
      ENDIF
      drr_readmes_to_run->timer_readme[timer_cnt].readme_id = r.readme_id
      IF (r.parent_readme_id > 0)
       drr_readmes_to_run->timer_readme[timer_cnt].parent_readme_id = r.parent_readme_id
      ELSE
       drr_readmes_to_run->timer_readme[timer_cnt].parent_readme_id = 0
      ENDIF
      drr_readmes_to_run->timer_readme[timer_cnt].instance = r.instance, drr_readmes_to_run->
      timer_readme[timer_cnt].ocd = o.ocd, drr_readmes_to_run->timer_readme[timer_cnt].execution = r
      .execution,
      drr_readmes_to_run->timer_readme[timer_cnt].script = cnvtupper(r.script), drr_readmes_to_run->
      timer_readme[timer_cnt].skip = 0
     ENDIF
    FOOT REPORT
     stat = alterlist(drr_readmes_to_run->timer_readme,timer_cnt), drr_readmes_to_run->
     timer_readme_cnt = timer_cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Find highest instance of timing readmes"
   CALL disp_msg("",dm_err->logfile,0)
   IF ((drr_readmes_to_run->timer_readme_cnt=0))
    SET dm_err->eproc = "No Category 8 readmes found to run."
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(1)
   ELSE
    SELECT INTO "nl:"
     FROM dm_readme r,
      dm_ocd_readme o,
      dm_alpha_features_env a,
      (dummyt d  WITH seq = value(drr_readmes_to_run->timer_readme_cnt))
     PLAN (d)
      JOIN (r
      WHERE (r.readme_id=drr_readmes_to_run->timer_readme[d.seq].readme_id)
       AND (r.instance > drr_readmes_to_run->timer_readme[d.seq].instance))
      JOIN (o
      WHERE o.readme_id=r.readme_id
       AND o.ocd > 0
       AND o.instance=r.instance)
      JOIN (a
      WHERE a.alpha_feature_nbr=o.ocd
       AND (a.environment_id=dm2_rr_misc->env_id))
     ORDER BY r.readme_id, r.instance DESC
     HEAD r.readme_id
      IF (r.active_ind=0)
       drr_readmes_to_run->timer_readme[d.seq].skip = 1
      ELSE
       drr_readmes_to_run->timer_readme[d.seq].instance = r.instance, drr_readmes_to_run->
       timer_readme[d.seq].ocd = o.ocd
      ENDIF
     FOOT  r.readme_id
      row + 0
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Update skip flag on timing readmes"
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(drr_readmes_to_run->timer_readme_cnt)),
      (dummyt d2  WITH seq = value(drr_readmes_to_run->readme_cnt))
     PLAN (d
      WHERE (drr_readmes_to_run->timer_readme[d.seq].parent_readme_id > 0))
      JOIN (d2
      WHERE (drr_readmes_to_run->timer_readme[d.seq].parent_readme_id=drr_readmes_to_run->readme[d2
      .seq].readme_id))
     DETAIL
      drr_readmes_to_run->timer_readme[d.seq].skip = drr_readmes_to_run->readme[d2.seq].skip
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag >= 2))
    CALL echorecord(drr_readmes_to_run)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_alert_killed_appl(daka_load_ind,daka_fmt_appl_id,daka_kill_ind)
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
      drr_killed_appl->appl_cnt = 0
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
       drr_killed_appl->appl_cnt += 1
       IF (mod(drr_killed_appl->appl_cnt,10)=1)
        stat = alterlist(drr_killed_appl->appl,(drr_killed_appl->appl_cnt+ 9))
       ENDIF
       drr_killed_appl->appl[drr_killed_appl->appl_cnt].appl_id = daka_audsid
      ENDIF
     FOOT REPORT
      stat = alterlist(drr_killed_appl->appl,drr_killed_appl->appl_cnt)
     WITH nocounter
    ;end select
    IF (check_error("Obtain killed application IDs.")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((drr_killed_appl->appl_cnt > 0))
    SET daka_applx = locateval(daka_applx,1,drr_killed_appl->appl_cnt,daka_fmt_appl_id,
     drr_killed_appl->appl[daka_applx].appl_id)
    IF (daka_applx > 0)
     SET daka_kill_ind = 1
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(drr_killed_appl)
   ENDIF
   RETURN(1)
 END ;Subroutine
 FREE RECORD radm
 RECORD radm(
   1 qual[*]
     2 tname = vc
     2 syn_exist = i2
     2 def_exist = i2
     2 col_cnt = i2
     2 col[*]
       3 cname = vc
   1 tcnt = i2
 )
 SET radm->tcnt = 0
 FREE DEFINE ocd_op
 RECORD ocd_op(
   1 cur_op = vc
   1 pre_op = vc
   1 next_op = vc
   1 bad_op = vc
   1 status = vc
   1 msg = vc
 )
 SET olo_none = "None"
 SET olo_load_ccl_file = "Load CCL File"
 SET olo_schema_report = "Display Schema Report"
 SET olo_readme_report = "Display Readme Report"
 SET olo_code_sets = "Code Sets"
 SET olo_pre_uts = "Pre-UTS Readmes"
 SET olo_uptime_schema = "Uptime Schema"
 SET olo_post_uts = "Post-UTS Readmes"
 SET olo_pre_dts = "Pre-DTS Readmes"
 SET olo_downtime_schema = "Downtime Schema"
 SET olo_post_dts = "Post-DTS Readmes"
 SET olo_atrs = "ATRs"
 SET olo_post_inst = "Post-INST Readmes"
 SET ols_start = "START"
 SET ols_begin = "START"
 SET ols_running = "RUNNING"
 SET ols_error = "ERROR"
 SET ols_failed = "ERROR"
 SET ols_complete = "COMPLETE"
 SET ols_end = "COMPLETE"
 SET ols_finish = "COMPLETE"
 SUBROUTINE dm_ocd_log_op(ol_operation,ol_status,ol_message)
   CALL dm2_set_autocommit(1)
   UPDATE  FROM dm_ocd_log d
    SET d.status = evaluate(cnvtupper(ol_status),ols_start,ols_running,cnvtupper(ol_status)), d
     .message = substring(1,255,ol_message), d.start_dt_tm = evaluate(cnvtupper(ol_status),ols_start,
      cnvtdatetime(curdate,curtime3),d.start_dt_tm),
     d.end_dt_tm = evaluate(cnvtupper(ol_status),ols_complete,cnvtdatetime(curdate,curtime3),
      ols_error,cnvtdatetime(curdate,curtime3),
      null), d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE d.environment_id=env_id
     AND d.project_type="INSTALL LOG"
     AND d.project_name=cnvtupper(ol_operation)
     AND d.project_instance=1
     AND d.ocd=ocd_number
    WITH nocounter
   ;end update
   IF (curqual=0)
    INSERT  FROM dm_ocd_log d
     SET d.environment_id = env_id, d.project_type = "INSTALL LOG", d.project_name = cnvtupper(
       ol_operation),
      d.project_instance = 1, d.ocd = ocd_number, d.batch_dt_tm = cnvtdatetime(curdate,curtime3),
      d.status = evaluate(cnvtupper(ol_status),ols_start,ols_running,cnvtupper(ol_status)), d.message
       = substring(1,255,ol_message), d.start_dt_tm = cnvtdatetime(curdate,curtime3),
      d.end_dt_tm = null, d.driver_count = null, d.estimated_time = null,
      d.active_ind = 1, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
   ENDIF
   IF (curqual)
    COMMIT
   ELSE
    CALL echo("***")
    CALL echo("ERROR! Unable to log status to dm_ocd_log table")
    CALL echo("***")
   ENDIF
   CALL dm2_set_autocommit(0)
 END ;Subroutine
 SUBROUTINE dm_ocd_chk_op(ol_operation)
   IF (cnvtupper(ol_operation)="NONE")
    RETURN(1)
   ENDIF
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_ocd_log d
    WHERE d.environment_id=env_id
     AND d.project_type="INSTALL LOG"
     AND d.project_name=cnvtupper(ol_operation)
     AND d.project_instance=1
     AND d.ocd=ocd_number
     AND d.status="COMPLETE"
    WITH nocounter
   ;end select
   IF (curqual)
    IF (dm2_set_autocommit(0)=0)
     RETURN(0)
    ENDIF
    RETURN(1)
   ELSE
    CALL dm2_set_autocommit(0)
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm_ocd_bad_op(ol_bad_op,ol_pre_op)
   CALL end_status(build("Cannot execute '",ol_bad_op,"' operation until '",ol_pre_op,
     "' operation is complete. Install FAILED."),env_id,ocd_number)
 END ;Subroutine
 SUBROUTINE dm_ocd_del_all_op(null)
   IF (dm2_set_autocommit(1)=0)
    RETURN(1)
   ENDIF
   DELETE  FROM dm_ocd_log d
    WHERE d.environment_id=env_id
     AND d.project_type="INSTALL LOG"
     AND d.ocd=ocd_number
    WITH nocounter
   ;end delete
   COMMIT
   SELECT INTO "nl:"
    FROM dm_ocd_log d
    WHERE d.environment_id=env_id
     AND d.project_type="INSTALL LOG"
     AND d.ocd=ocd_number
    WITH nocounter
   ;end select
   IF (curqual > 0)
    CALL dm2_set_autocommit(0)
    RETURN(1)
   ELSE
    IF (dm2_set_autocommit(0)=0)
     RETURN(1)
    ENDIF
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm_ocd_chk_op_all(doc_op)
   SET doc_comp_cnt = 0
   SET doc_tot_cnt = 0
   IF (dm2_set_autocommit(1)=0)
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    val = decode(d.ocd,1,0)
    FROM dm_ocd_log d,
     dm_alpha_features_env a,
     (dummyt dt  WITH seq = 1)
    PLAN (a
     WHERE a.alpha_feature_nbr > 0
      AND a.environment_id=env_id
      AND a.curr_migration_ind=1)
     JOIN (dt)
     JOIN (d
     WHERE d.environment_id=env_id
      AND d.project_type="INSTALL LOG"
      AND d.project_name=cnvtupper(doc_op)
      AND d.project_instance=1
      AND a.alpha_feature_nbr=d.ocd
      AND d.status="COMPLETE")
    HEAD REPORT
     row + 0
    DETAIL
     doc_tot_cnt = (doc_tot_cnt+ 1)
    FOOT REPORT
     doc_comp_cnt = sum(val)
    WITH nocounter, outerjoin = dt
   ;end select
   IF (doc_comp_cnt=doc_tot_cnt)
    IF (dm2_set_autocommit(0)=0)
     RETURN(0)
    ENDIF
    RETURN(1)
   ELSEIF (doc_comp_cnt=0)
    CALL dm2_set_autocommit(0)
    RETURN(- (1))
   ELSE
    CALL dm2_set_autocommit(0)
    RETURN(0)
   ENDIF
 END ;Subroutine
#initialize_end
#initialize2
 CALL echo(asterick_line)
 CALL echo("Initializing the env_id and env_name variables.")
 CALL echo(asterick_line)
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE info_domain="DATA MANAGEMENT"
   AND info_name="DM_ENV_ID"
  DETAIL
   env_id = di.info_number
  WITH nocounter
 ;end select
 IF (dm2_set_autocommit(1)=0)
  GO TO program_end
 ENDIF
 SELECT INTO "nl:"
  FROM dm_environment de
  WHERE de.environment_id=env_id
  DETAIL
   env_name = de.environment_name, sch_ver = round(de.schema_version,3)
  WITH nocounter
 ;end select
 IF (dm2_set_autocommit(0)=0)
  GO TO program_end
 ENDIF
 CALL echo(asterick_line)
 CALL echo(concat("env_id =",cnvtstring(env_id)," and env_name =",env_name))
 CALL echo(asterick_line)
 IF (dm2_set_autocommit(1)=0)
  GO TO program_end
 ENDIF
 UPDATE  FROM dm_alpha_features_env defa
  SET defa.status = "Begin installation", defa.start_dt_tm = cnvtdatetime(curdate,curtime3), defa
   .end_dt_tm = null,
   defa.inst_mode = ocd_install_mode, defa.calling_script = call_script
  WHERE defa.environment_id=env_id
   AND defa.alpha_feature_nbr=ocd_number
  WITH nocounter
 ;end update
 IF (curqual=0)
  INSERT  FROM dm_alpha_features_env defa
   SET defa.status = "Begin installation", defa.start_dt_tm = cnvtdatetime(curdate,curtime3), defa
    .end_dt_tm = null,
    defa.environment_id = env_id, defa.alpha_feature_nbr = ocd_number, defa.inst_mode =
    ocd_install_mode,
    defa.calling_script = call_script, defa.curr_migration_ind = 0
   WITH nocounter
  ;end insert
 ENDIF
 IF (dm2_set_autocommit(0)=0)
  GO TO program_end
 ENDIF
 COMMIT
#initialize2_end
 SUBROUTINE check_include_ccl_step(dummy2)
   SET ocd_op->cur_op = olo_load_ccl_file
   SET ocd_op->pre_op = olo_none
   CALL start_status("Check archive date and load OCD schema CCL file",env_id,ocd_number)
   CALL dm_ocd_log_op(ocd_op->cur_op,ols_start,"Check archive date of ccl file before loading")
   IF (ocd_install_mode="LOAD")
    SET docd_reply->status = "L"
   ELSE
    SET docd_reply->status = "F"
    EXECUTE dm_ocd_include_check_date ocd_number
   ENDIF
   CASE (docd_reply->status)
    OF "F":
     CALL end_status(concat("User decided to abort installation of lower version.",
       "CCL file archive date is older than admin archive date."),env_id,ocd_number)
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_error,concat(
       "User decided to abort installation of lower version.",
       "CCL file archive date is older than admin archive date"))
     GO TO program_end
    OF "L":
     IF (user_sel_load=1)
      CALL dm_ocd_log_op(ocd_op->cur_op,ols_running,concat(
        "User decided to install a lower version of the package.","Loading OCD schema ccl file."))
     ELSE
      CALL dm_ocd_log_op(ocd_op->cur_op,ols_running,"Loading OCD schema ccl file")
     ENDIF
     CALL include_ccl_step(0)
     IF (ocd_install_mode != "LOAD")
      DELETE  FROM dm_ocd_log d
       WHERE d.environment_id=env_id
        AND d.project_type="INSTALL LOG"
        AND d.ocd=ocd_number
       WITH nocounter
      ;end delete
      COMMIT
     ENDIF
     IF (user_sel_load=1)
      CALL dm_ocd_log_op(ocd_op->cur_op,ols_running,concat(
        "User decided to install a lower version of the package.",
        "Verifying load of OCD schema ccl file"))
     ELSE
      CALL dm_ocd_log_op(ocd_op->cur_op,ols_running,"Verifying load of OCD schema ccl file")
     ENDIF
     SET docd_reply->status = "F"
     EXECUTE dm_ocd_include_check ocd_number
     CASE (docd_reply->status)
      OF "F":
       IF (user_sel_load=1)
        CALL end_status(concat("User decided to install a lower version of the package.",
          "Loading OCD schema CCL file failed!"),env_id,ocd_number)
        CALL dm_ocd_log_op(ocd_op->cur_op,ols_error,concat(
          "User decided to install a lower version of the package.",
          "Loading of OCD schema ccl file failed row count error check"))
       ELSE
        CALL end_status("Loading OCD schema CCL file failed!",env_id,ocd_number)
        CALL dm_ocd_log_op(ocd_op->cur_op,ols_error,
         "Loading of OCD schema ccl file failed row count error check")
       ENDIF
       GO TO program_end
      OF "S":
       IF (dbai_backfill_pkg(ocd_number)=0)
        CALL end_status("Failed to update schema instance on DM_AFD_TABLES",env_id,ocd_number)
        CALL dm_ocd_log_op(ocd_op->cur_op,ols_error,
         "Updating schema instance on DM_AFD_TABLES failed.")
        GO TO program_end
       ENDIF
       IF (user_sel_load=1)
        CALL end_status(concat("User decided to install a lower version of the package.",
          "Loading OCD schema CCL file successful"),env_id,ocd_number)
        CALL dm_ocd_log_op(ocd_op->cur_op,ols_complete,concat(
          "User decided to install a lower version of the package.",
          "Loading of OCD schema ccl file successful"))
       ELSE
        CALL end_status("Loading OCD schema CCL file successful",env_id,ocd_number)
        CALL dm_ocd_log_op(ocd_op->cur_op,ols_complete,"Loading of OCD schema ccl file successful")
       ENDIF
     ENDCASE
    OF "N":
     CALL end_status("OCD schema CCL file does not need to be loaded",env_id,ocd_number)
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_complete,
      "Loading of OCD schema ccl file not needed. Success")
   ENDCASE
 END ;Subroutine
 SUBROUTINE include_ccl_step(dummy)
   SET fn = build("ocd_schema_",ocd_string,".ccl")
   IF (cursys="AIX")
    SET location = concat(trim(cerocd,3),"/",trim(ocd_string_padded),"/",trim(fn,3))
   ELSE
    SET len = findstring("]",cerocd)
    SET location = concat(substring(1,(len - 1),trim(cerocd)),trim(ocd_string_padded),"]",trim(fn,3))
   ENDIF
   IF (findfile(location)=0)
    DELETE  FROM dm_ocd_log d
     WHERE d.environment_id=env_id
      AND d.project_type="INSTALL LOG"
      AND d.ocd=ocd_number
     WITH nocounter
    ;end delete
    COMMIT
    CALL start_status(concat("OCD schema CCL file ",trim(fn,3)," not found!"," OCD install FAILED"),
     env_id,ocd_number)
    GO TO program_end
   ENDIF
   SET trace_file = build("ocd_compile_",ocd_number,".dat")
   CALL start_status(concat("Including filename = ",trim(location,3)),env_id,ocd_number)
   EXECUTE dm_ocd_incl_file location
   IF ((docd_reply->status="F"))
    CALL echo("***")
    CALL echo(concat("Fatal error while including CCL file ",trim(location)))
    CALL echo("***")
    CALL end_status(concat("Fatal error while including CCL file ",trim(location)),env_id,ocd_number)
    GO TO program_end
   ELSE
    CALL end_status(concat("Filename = ",trim(location,3)," included successfully."),env_id,
     ocd_number)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm_util_steps(dummy)
   IF (currdb="ORACLE")
    IF (sch_ver > 7.003
     AND sch_ver < 99.01
     AND sch_ver < 7.008)
     CALL start_status(build("Rev=",sch_ver,". Checking to see if combine temp tbls need refreshing."
       ),env_id,ocd_number)
     SET cmb_temp_date = cnvtdatetime(curdate,curtime3)
     SET last_updt_date = cnvtdatetime(curdate,curtime3)
     SELECT INTO "nl:"
      d.updt_dt_tm
      FROM dm_cmb_constraints d
      DETAIL
       cmb_temp_date = d.updt_dt_tm
      WITH maxqual(d,1), nocounter
     ;end select
     CALL start_status(concat("Combine temp tables last refreshed on ",format(cmb_temp_date,
        "dd-mmm-yyyy hh:mm:ss;;d")),env_id,ocd_number)
     SELECT INTO "nl:"
      i.info_date
      FROM dm_info i
      WHERE i.info_name="USERLASTUPDT"
      DETAIL
       last_updt_date = i.info_date
      WITH nocounter
     ;end select
     CALL start_status(concat("Schema last updated on ",format(last_updt_date,
        "dd-mmm-yyyy hh:mm:ss;;d")),env_id,ocd_number)
     IF (last_updt_date > cmb_temp_date)
      CALL start_status("Combine temp tables being refreshed.",env_id,ocd_number)
      EXECUTE dm_cmb_bld_tmp_tbls
     ELSE
      CALL start_status("Combine temp tables do not need to be refreshed.",env_id,ocd_number)
     ENDIF
    ELSEIF (abs((sch_ver - 2000.01)) < 0.001)
     EXECUTE dm_ins_user_cmb_children
    ELSE
     CALL start_status("Rev is 7.8 or higher. Combine temp tables do not need to be refreshed.",
      env_id,ocd_number)
    ENDIF
    CALL start_status("Add zero row, active_ind trigger and public synonym...",env_id,ocd_number)
    EXECUTE dm_chk_for_synonym "ALLTABLES"
    FOR (t_tbl = 1 TO tgtdb->tbl_cnt)
      SET tgtdb->tbl[t_tbl].zero_row_ind = 0
      EXECUTE dm2_add_default_rows tgtdb->tbl[t_tbl].tbl_name
      IF (validate(dm_err->err_ind,- (1)) > 0)
       SET ois_tmp_msg = fillstring(255," ")
       SET ois_tmp_msg = concat(
        "Installation Failed. See the following log file in CCLUSERDIR for details: ",dm_err->logfile
        )
       CALL end_status(ois_tmp_msg,env_id,ocd_number)
       GO TO program_end
      ENDIF
      SET tgtdb->tbl[t_tbl].active_trigger_ind = 0
      FREE RECORD act_reply
      RECORD act_reply(
        1 status = c1
        1 active_trigger_ind = i2
      )
      EXECUTE dm_chk_for_active_trigger tgtdb->tbl[t_tbl].tbl_name
      IF ((act_reply->status="S"))
       SET tgtdb->tbl[t_tbl].active_trigger_ind = act_reply->active_trigger_ind
      ENDIF
      IF ((tgtdb->tbl[t_tbl].active_trigger_ind=1))
       EXECUTE dm_create_active_trigger tgtdb->tbl[t_tbl].tbl_name
      ENDIF
      IF ((tgtdb->tbl[t_tbl].synonym_ind=1))
       EXECUTE dm_create_object_synonym tgtdb->tbl[t_tbl].tbl_name, "TABLE"
      ENDIF
    ENDFOR
    CALL start_status("Finished adding zero row, active_ind trigger and public synonym...",env_id,
     ocd_number)
   ENDIF
 END ;Subroutine
 SUBROUTINE start_status(install_status,e_id,o_number)
   RECORD str(
     1 str = vc
   )
   IF (dm2_set_autocommit(1)=0)
    GO TO program_end
   ENDIF
   UPDATE  FROM dm_alpha_features_env defa
    SET defa.status = substring(1,100,install_status), defa.start_dt_tm = cnvtdatetime(curdate,
      curtime3), defa.end_dt_tm = null
    WHERE defa.environment_id=e_id
     AND defa.alpha_feature_nbr=o_number
   ;end update
   COMMIT
   IF (dm2_set_autocommit(0)=0)
    GO TO program_end
   ENDIF
   SELECT INTO value(log_fname)
    d.*
    FROM dual d
    DETAIL
     curdate"mm/dd/yyyy;;d", " ", curtime3"hh:mm;;m",
     row + 1, str->str = substring(1,130,install_status), str->str,
     row + 1
    WITH nocounter, format = stream, formfeed = none,
     append, maxrow = 1
   ;end select
   CALL echo("*")
   CALL echo("*")
   CALL echo("*")
   CALL echo("*")
   CALL echo(asterick_line)
   CALL echo("*")
   CALL echo("*")
   CALL echo(install_status)
   CALL echo("*")
   CALL echo("*")
   CALL echo(asterick_line)
   CALL echo("*")
   CALL echo("*")
   CALL echo("*")
   CALL echo("*")
 END ;Subroutine
 SUBROUTINE end_status(install_status,e_id,o_number)
   RECORD str(
     1 str = vc
   )
   IF (dm2_set_autocommit(1)=0)
    GO TO program_end
   ENDIF
   UPDATE  FROM dm_alpha_features_env defa
    SET defa.status = substring(1,100,install_status), defa.end_dt_tm = cnvtdatetime(curdate,curtime3
      )
    WHERE defa.environment_id=e_id
     AND defa.alpha_feature_nbr=o_number
   ;end update
   COMMIT
   IF (dm2_set_autocommit(0)=0)
    GO TO program_end
   ENDIF
   SELECT INTO value(log_fname)
    d.*
    FROM dual d
    DETAIL
     curdate"mm/dd/yyyy;;d", " ", curtime3"hh:mm;;m",
     row + 1, str->str = substring(1,130,install_status), str->str,
     row + 1
    WITH nocounter, format = stream, formfeed = none,
     append, maxrow = 1
   ;end select
   CALL echo("*")
   CALL echo("*")
   CALL echo("*")
   CALL echo("*")
   CALL echo(asterick_line)
   CALL echo("*")
   CALL echo("*")
   CALL echo(install_status)
   CALL echo("*")
   CALL echo("*")
   CALL echo(asterick_line)
   CALL echo("*")
   CALL echo("*")
   CALL echo("*")
   CALL echo("*")
 END ;Subroutine
 SUBROUTINE log(l_status,l_message)
   IF (cnvtupper(trim(l_status,3))="S")
    CALL start_status(l_message,env_id,ocd_number)
   ELSE
    CALL end_status(l_message,env_id,ocd_number)
   ENDIF
 END ;Subroutine
 SUBROUTINE new_readme(nr_mode)
   CALL log("S",concat("Preparing to execute '",nr_mode," new-style readmes'."))
   IF ( NOT (table_exists("DM_README")))
    CALL log("E",concat("DM_README table not found.  No '",nr_mode,"' new-style readme' attempted."))
    RETURN(0)
   ENDIF
   CALL log("S",concat("Executing DM_README_BATCH for '",nr_mode,"' new-style readmes'."))
   SET rb_ocd = ocd_number
   FREE SET rb_execution
   SET rb_execution = nr_mode
   IF (dm2_rr_toolset_usage(null)=0)
    CALL log("E",concat(dm_err->eproc,"  ",dm_err->emsg))
    GO TO program_end
   ENDIF
   IF ((dm2_rr_misc->dm2_toolset_usage="Y"))
    EXECUTE dm2_readme_batch 0
    IF ((dm_err->err_ind=1))
     GO TO program_end
    ENDIF
    IF ((dm2_rr_misc->readme_errors_ind=1))
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_error,concat(
       "One or more readmes failed during installation of ",trim(ocd_op->cur_op),". ",
       "Please type 'DM_README_OCD_LOG ",trim(cnvtstring(ocd_number)),
       " go' to view the status of all readmes on this OCD."))
     SET dm_err->err_ind = 1
     GO TO program_end
    ELSE
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_complete,concat("Finished executing all ",trim(ocd_op->
        cur_op)," steps"))
    ENDIF
   ELSE
    EXECUTE dm_readme_batch 0
    CALL wait_readme_steps(0)
    SET err_readme_id = 0
    SET err_readme_id = check_readme_errors(ocd_op->cur_op,cnvtupper(nr_mode))
    IF (err_readme_id)
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_error,concat("Readme step ",trim(cnvtstring(err_readme_id)
        )," failed! ","Please type 'DM_README_OCD_LOG ",trim(cnvtstring(ocd_number)),
       " go' to view the status of all readmes on this OCD."))
     GO TO program_end
    ELSE
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_complete,concat("Finished executing all ",trim(ocd_op->
        cur_op)," steps"))
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE old_readme(or_mode)
   FREE SET or_script
   SET or_script = build("OCD_",or_mode,"_SCHEMA_",ocd_string)
   CALL log("S",concat("Determining whether a '",or_mode," old-style readme' needs to be executed."))
   IF ( NOT (script_exists(or_script)))
    CALL log("E",concat("No script named '",or_script,"' found.  No '",or_mode,
      " old-style readme' attempted."))
    RETURN(0)
   ENDIF
   CALL log("S",concat("Starting '",or_mode," old-style readme' script (",or_script,")."))
   EXECUTE value(or_script)
   SET trace = norecpersist
   CALL log("E",concat("Finished executing '",or_mode," old-style readme' script (",or_script,")."))
   RETURN(1)
 END ;Subroutine
 SUBROUTINE product_area_readme(par_mode)
   FREE SET par_temp
   RECORD par_temp(
     1 script = vc
   )
   CALL log("S",concat("Determining whether a '",par_mode,
     " product area readme' needs to be executed."))
   IF ( NOT (table_exists("DM_OCD_PRODUCT_AREA")))
    CALL log("E",concat("DM_OCD_PRODUCT_AREA table not found.  No '",par_mode,
      " product area readme' attempted."))
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    o.product_area
    FROM dm_ocd_product_area o
    WHERE o.ocd=ocd_number
     AND o.product_area_number > 0
    DETAIL
     IF (par_mode="PRE")
      par_temp->script = concat("PRE_README_",trim(cnvtstring(o.product_area_number),3))
     ELSE
      par_temp->script = concat("POST_README_",trim(cnvtstring(o.product_area_number),3))
     ENDIF
    WITH nocounter
   ;end select
   IF ( NOT (curqual))
    CALL log("E",concat("No product area number found for this OCD.  No '",par_mode,
      " product area readme' attempted."))
    RETURN(0)
   ENDIF
   IF ( NOT (script_exists(par_temp->script)))
    CALL log("E",concat("No script named '",par_temp->script,"' found.  No '",par_mode,
      " product area readme' attempted."))
    RETURN(0)
   ENDIF
   CALL log("S",concat("Starting '",par_mode," product area readme' script (",par_temp->script,")."))
   EXECUTE value(par_temp->script)
   SET trace = norecpersist
   CALL log("E",concat("Finished executing '",par_mode," product area readme' script (",par_temp->
     script,")."))
   RETURN(1)
 END ;Subroutine
 SUBROUTINE script_exists(se_script)
   SET se_flag = 0
   SELECT INTO "nl:"
    p.object_name
    FROM dprotect p
    WHERE p.object="P"
     AND p.object_name=cnvtupper(trim(se_script,3))
    DETAIL
     se_flag = 1
    WITH nocounter
   ;end select
   RETURN(se_flag)
 END ;Subroutine
 SUBROUTINE readme_step(rs_mode)
   CASE (cnvtupper(trim(rs_mode,3)))
    OF "PRE":
     IF (call_script != "DM_OCD_MENU")
      CALL new_readme("PREUP")
      CALL new_readme("PREDOWN")
     ENDIF
    OF "POST":
     IF (call_script != "DM_OCD_MENU")
      CALL new_readme("POSTUP")
      CALL new_readme("POSTDOWN")
      CALL new_readme("UP")
     ENDIF
    OF "PREUP":
     SET ocd_op->pre_op = olo_code_sets
     SET ocd_op->cur_op = olo_pre_uts
     SET ocd_op->next_op = olo_uptime_schema
     IF (dm_ocd_chk_op(ocd_op->pre_op)=0)
      CALL dm_ocd_bad_op(ocd_op->cur_op,ocd_op->pre_op)
      GO TO program_end
     ENDIF
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_start,"Executing pre-uts readme steps...")
     IF (call_script != "DM_OCD_MENU")
      CALL new_readme("PREUP")
     ENDIF
    OF "POSTUP":
     SET ocd_op->pre_op = olo_atrs
     SET ocd_op->cur_op = olo_post_uts
     SET ocd_op->next_op = olo_pre_dts
     IF (dm_ocd_chk_op(ocd_op->pre_op)=0)
      CALL dm_ocd_bad_op(ocd_op->cur_op,ocd_op->pre_op)
      GO TO program_end
     ENDIF
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_start,"Executing post-uts readme steps...")
     CALL new_readme("POSTUP")
    OF "PREDOWN":
     SET ocd_op->pre_op = olo_post_uts
     SET ocd_op->cur_op = olo_pre_dts
     SET ocd_op->next_op = olo_downtime_schema
     IF (dm_ocd_chk_op(ocd_op->pre_op)=0)
      CALL dm_ocd_bad_op(ocd_op->cur_op,ocd_op->pre_op)
      GO TO program_end
     ENDIF
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_start,"Executing pre-dts readme steps...")
     CALL new_readme("PREDOWN")
    OF "POSTDOWN":
     SET ocd_op->pre_op = olo_downtime_schema
     SET ocd_op->cur_op = olo_post_dts
     SET ocd_op->next_op = olo_post_inst
     IF (dm_ocd_chk_op(ocd_op->pre_op)=0)
      CALL dm_ocd_bad_op(ocd_op->cur_op,ocd_op->pre_op)
      GO TO program_end
     ENDIF
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_start,"Executing post-dts readme steps...")
     IF (call_script != "DM_OCD_MENU")
      CALL new_readme("POSTDOWN")
     ENDIF
    OF "UP":
     SET ocd_op->pre_op = olo_post_dts
     SET ocd_op->cur_op = olo_post_inst
     SET ocd_op->next_op = olo_none
     IF (dm_ocd_chk_op(ocd_op->pre_op)=0)
      CALL dm_ocd_bad_op(ocd_op->cur_op,ocd_op->pre_op)
      GO TO program_end
     ENDIF
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_start,"Executing post-inst readme steps...")
     CALL new_readme("UP")
   ENDCASE
 END ;Subroutine
 SUBROUTINE table_exists(te_table)
   SET te_flag = 0
   SELECT INTO "nl:"
    a.table_name
    FROM dtableattr a
    WHERE a.table_name=cnvtupper(trim(te_table,3))
    DETAIL
     te_flag = 1
    WITH nocounter
   ;end select
   RETURN(te_flag)
 END ;Subroutine
 SUBROUTINE readme_estimate_step(re_dummy)
   IF (cnvtupper(trim(ocd_install_mode,3))="MANUALNOLOAD")
    SET ocd_op->pre_op = olo_none
    SET ocd_op->cur_op = olo_readme_report
   ELSE
    SET ocd_op->pre_op = olo_load_ccl_file
    SET ocd_op->cur_op = olo_readme_report
    IF (dm_ocd_chk_op(ocd_op->pre_op)=0)
     CALL dm_ocd_bad_op(ocd_op->cur_op,ocd_op->pre_op)
     GO TO program_end
    ENDIF
   ENDIF
   IF (dm2_rr_toolset_usage(null)=0)
    CALL log("E",concat(dm_err->eproc,"  ",dm_err->emsg))
    GO TO program_end
   ENDIF
   CALL dm_ocd_log_op(ocd_op->cur_op,ols_start,"Displaying README estimate report...")
   CALL start_status("Displaying README estimate report...",env_id,ocd_number)
   SET rm_estimator_ocd = ocd_number
   IF ((dm2_rr_misc->dm2_toolset_usage="Y"))
    EXECUTE dm2_readme_estimator rm_estimator_ocd
    IF ((dm_err->err_ind=1))
     GO TO program_end
    ENDIF
   ELSE
    EXECUTE dm_readme_estimator
   ENDIF
   CALL dm_ocd_log_op(ocd_op->cur_op,ols_complete,"Finished displaying README estimate report")
   CALL end_status("Finished displaying README estimate report",env_id,ocd_number)
 END ;Subroutine
 SUBROUTINE check_schema_ddl_files(sdf_dummy)
  SELECT INTO "nl:"
   FROM dm_ocd_log d
   WHERE d.environment_id=env_id
    AND d.project_type="SCHEMA DDL"
    AND d.ocd=ocd_number
    AND d.status=null
   WITH nocounter
  ;end select
  IF (curqual)
   RETURN(1)
  ELSE
   RETURN(0)
  ENDIF
 END ;Subroutine
 SUBROUTINE wait_schema_ddl_files(sdf_dummy)
   SET sdf_done = 0
   SET sdf_ddl_file = fillstring(35," ")
   WHILE (sdf_done=0)
    SELECT INTO "nl:"
     FROM dm_ocd_log d
     WHERE d.environment_id=env_id
      AND d.project_type="SCHEMA DDL"
      AND d.ocd=ocd_number
      AND ((d.status=ols_running) OR (d.status = null))
     ORDER BY d.start_dt_tm DESC
     DETAIL
      sdf_ddl_file = d.project_name
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET sdf_done = 1
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_running,"Finished executing all DDL files")
     CALL start_status("Finished executing all DDL files",env_id,ocd_number)
    ELSE
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_running,build(
       "Waiting for DDL file(s) to finish processing (",sdf_ddl_file,")"))
     CALL start_status(build("Waiting for DDL file(s) to finish processing (",sdf_ddl_file,")"),
      env_id,ocd_number)
     CALL pause(30)
    ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE wait_readme_steps(wrs_dummy)
   SET wrs_done = 0
   SET wrs_readme = fillstring(35," ")
   WHILE (wrs_done=0)
    SELECT INTO "nl:"
     FROM dm_ocd_log d
     WHERE d.environment_id=env_id
      AND d.project_type="README"
      AND d.ocd=ocd_number
      AND ((d.status=ols_running) OR (d.status = null))
     ORDER BY d.start_dt_tm DESC
     DETAIL
      wrs_readme = d.project_name
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET wrs_done = 1
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_running,build("Finished executing all '",ocd_op->cur_op,
       "' steps"))
     CALL start_status(build("Finished executing all '",ocd_op->cur_op,"' steps"),env_id,ocd_number)
    ELSE
     CALL dm_ocd_log_op(ocd_op->cur_op,ols_running,build(
       "Waiting for readme step(s) to finish processing (",wrs_readme,")"))
     CALL start_status(build("Waiting for readme step(s) to finish processing (",wrs_readme,")"),
      env_id,ocd_number)
     CALL pause(60)
    ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE check_readme_errors(cre_ocd_op,cre_readme_mode)
   FREE RECORD cre_readme
   RECORD cre_readme(
     1 readme_id = i4
     1 error_msg = vc
   )
   SET cre_readme->readme_id = 0
   SELECT INTO "nl:"
    FROM dm_ocd_log l,
     dm_readme r
    PLAN (l
     WHERE l.environment_id=env_id
      AND l.project_type="README"
      AND l.ocd=ocd_number
      AND l.status="FAILED")
     JOIN (r
     WHERE r.readme_id=cnvtreal(l.project_name)
      AND r.instance=l.project_instance
      AND r.execution=cre_readme_mode
      AND r.active_ind=1)
    ORDER BY l.start_dt_tm DESC
    DETAIL
     cre_readme->readme_id = cnvtint(l.project_name), cre_readme->error_msg = l.message
    WITH nocounter
   ;end select
   IF (curqual=0)
    RETURN(0)
   ENDIF
   CALL disp_readme_error(cre_ocd_op,cre_readme->readme_id,cre_readme->error_msg)
   RETURN(cre_readme->readme_id)
 END ;Subroutine
 SUBROUTINE disp_readme_error(dre_op,dre_readme_id,dre_message)
   CALL log("E",concat("An error occurred while running '",dre_op,"'.  ","Readme ID: ",trim(
      cnvtstring(dre_readme_id),3),
     ".  ","Message: ",dre_message))
   CALL echo("*")
   CALL echo("*")
   CALL echo("*")
   CALL echo(asterick_line)
   CALL echo("*")
   CALL echo("*")
   CALL echo("One or more readmes failed during installation.")
   CALL echo(concat("Please type 'DM_README_OCD_LOG ",trim(cnvtstring(ocd_number),3),
     " go' from the CCL prompt"))
   CALL echo("to view the status of all of the readmes on this OCD.")
   CALL echo("*")
   CALL echo("*")
   CALL echo(asterick_line)
   CALL echo("*")
   CALL echo("*")
   CALL echo("*")
 END ;Subroutine
 SUBROUTINE disp_tasks_step(dts_mode)
   IF (validate(call_script,"X") != "DM_OCD_MENU")
    CALL start_status("Displaying new ATR report...",env_id,ocd_number)
    SET ocd_apps_mode = dts_mode
    EXECUTE dm_ocd_apps
    SET message = nowindow
    SET ocd_tasks_mode = dts_mode
    EXECUTE dm_ocd_tasks
    SET message = nowindow
    CALL end_status("Displaying new ATR report complete",env_id,ocd_number)
   ENDIF
 END ;Subroutine
 SUBROUTINE del_preview_step(dps_env_id,dps_ocd_nbr)
   SET uptime_mode_ind = dm_ocd_chk_op(olo_uptime_schema)
   SET downtime_mode_ind = dm_ocd_chk_op(olo_downtime_schema)
   SET postinst_mode_ind = dm_ocd_chk_op(olo_post_inst)
   IF (uptime_mode_ind=0
    AND downtime_mode_ind=0
    AND postinst_mode_ind=0)
    DELETE  FROM dm_alpha_features_env d
     WHERE d.environment_id=dps_env_id
      AND d.alpha_feature_nbr=dps_ocd_nbr
    ;end delete
    COMMIT
    SELECT INTO "nl:"
     FROM dm_alpha_features_env d
     WHERE d.environment_id=dps_env_id
      AND d.alpha_feature_nbr=dps_ocd_nbr
    ;end select
    IF (curqual > 0)
     CALL end_status(
      "Delete from dm_alpha_features_env failed. Run OCD_INCL_SCHEMA2 again in PREVIEW mode.")
    ELSE
     IF (dm_ocd_del_all_op(null)=1)
      CALL end_status("Delete from dm_ocd_log failed. Run OCD_INCL_SCHEMA2 again in PREVIEW mode.")
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_setup_step(null)
  IF (currdb IN ("DB2UDB", "SQLSRV"))
   CASE (dm2_val_file_prefix(ocd_string_padded))
    OF 0:
     IF ((dm_err->err_ind=1))
      CALL dm_ocd_log_op(ocd_op->cur_op,ols_error,"Error occurred when checking for DM2 schema files"
       )
      CALL start_status("Check for DM2 schema files FAILED!",env_id,ocd_number)
      SET docd_reply->err_msg = concat(" Log file ",dm_err->logfile,
       " can be used to view more details.")
      CALL end_status(docd_reply->err_msg,env_id,ocd_number)
      RETURN(0)
     ELSE
      SET dm2_schema_files_exist = 0
     ENDIF
    OF 1:
     SET dm2_schema_files_exist = 1
     SET dm2_install_schema->dbase_name = currdblink
     SET dm2_install_schema->u_name = "V500"
     EXECUTE dm2_connect_to_dbase "PO"
     IF ((dm_err->err_ind=1))
      CALL dm_ocd_log_op(ocd_op->cur_op,ols_error,"Error occurred when prompting for V500 password")
      CALL start_status("Error occurred when prompting for V500 password",env_id,ocd_number)
      SET docd_reply->err_msg = concat(" Log file ",dm_err->logfile,
       " can be used to view more details.")
      CALL end_status(docd_reply->err_msg,env_id,ocd_number)
      RETURN(0)
     ENDIF
     SET dm2_install_schema->v500_p_word = dm2_install_schema->p_word
   ENDCASE
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE get_batch_list(gbl_dummy)
   DECLARE gbl_error = i4
   DECLARE gbl_msg = c132
   DECLARE rmcnt = i4
   SET gbl_error = 0
   SET gbl_msg = fillstring(132," ")
   SET gbl_error = error(gbl_msg,1)
   SELECT INTO "nl:"
    dip.package_number
    FROM dm_install_plan dip
    WHERE dip.install_plan_id=install_plan_id
    HEAD REPORT
     dipcnt = 0, stat = alterlist(batch_list->qual,100)
    DETAIL
     dipcnt = (dipcnt+ 1)
     IF (mod(dipcnt,100)=1
      AND dipcnt != 1)
      stat = alterlist(batch_list->qual,(dipcnt+ 99))
     ENDIF
     batch_list->qual[dipcnt].package_number = dip.package_number
    FOOT REPORT
     batch_list->package_cnt = dipcnt, stat = alterlist(batch_list->qual,dipcnt)
    WITH nocounter
   ;end select
   SET gbl_error = error(gbl_msg,0)
   IF (gbl_error > 0)
    CALL display_msg(build("FATAL ERROR:  Failed to select packages associated with plan ID <",
      install_plan_id,">."),gbl_msg)
    RETURN(0)
   ENDIF
   IF ((batch_list->package_cnt=0))
    CALL display_msg(build("FATAL ERROR:  No packages associated with plan ID <",install_plan_id,">."
      ),"NONE")
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_ocd_readme dor,
     (dummyt d  WITH seq = value(batch_list->package_cnt))
    PLAN (d)
     JOIN (dor
     WHERE (dor.ocd=batch_list->qual[d.seq].package_number))
    ORDER BY dor.ocd, dor.readme_id
    HEAD dor.ocd
     rmcnt = 0
    DETAIL
     rmcnt = (rmcnt+ 1)
     IF (mod(rmcnt,10)=1)
      stat = alterlist(batch_list->qual[d.seq].rm_qual,(rmcnt+ 9))
     ENDIF
     batch_list->qual[d.seq].rm_qual[rmcnt].readme_id = dor.readme_id, batch_list->qual[d.seq].
     rm_qual[rmcnt].instance = dor.instance
    FOOT  dor.ocd
     stat = alterlist(batch_list->qual[d.seq].rm_qual,rmcnt)
    WITH nocounter
   ;end select
   SET gbl_error = error(gbl_msg,0)
   IF (gbl_error > 0)
    CALL display_msg(build("FATAL ERROR:  Failed to select readmes associated with plan ID <",
      install_plan_id,">."),gbl_msg)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE batch_include_ccl_step(bics_dummy)
   DECLARE bics_error = i4
   DECLARE bics_msg = c132
   SET bics_error = 0
   SET bics_msg = fillstring(132," ")
   SET bics_error = error(bics_msg,1)
   FOR (b_item = 1 TO batch_list->package_cnt)
     SET ocd_number = batch_list->qual[b_item].package_number
     SET ocd_string = cnvtstring(batch_list->qual[b_item].package_number)
     SET ocd_string_padded = format(ocd_string,"######;P0")
     CALL check_include_ccl_step(0)
     SET bics_error = error(bics_msg,0)
     IF (bics_error > 0)
      CALL display_msg("Failed including CCL files.",bics_msg)
      GO TO program_end
     ENDIF
     UPDATE  FROM dm_alpha_features_env defa
      SET defa.status = "Begin installation", defa.start_dt_tm = cnvtdatetime(curdate,curtime3), defa
       .end_dt_tm = null,
       defa.inst_mode = ocd_install_mode, defa.calling_script = call_script
      WHERE defa.environment_id=env_id
       AND (defa.alpha_feature_nbr=batch_list->qual[b_item].package_number)
      WITH nocounter
     ;end update
     SET bics_error = error(bics_msg,0)
     IF (bics_error > 0)
      CALL display_msg("Failed updating from DM_ALPHA_FEATURES_ENV.",bics_msg)
      GO TO program_end
     ENDIF
     IF (curqual=0)
      INSERT  FROM dm_alpha_features_env defa
       SET defa.status = "Begin installation", defa.start_dt_tm = cnvtdatetime(curdate,curtime3),
        defa.end_dt_tm = null,
        defa.environment_id = env_id, defa.alpha_feature_nbr = batch_list->qual[b_item].
        package_number, defa.inst_mode = ocd_install_mode,
        defa.calling_script = call_script, defa.curr_migration_ind = 0
       WITH nocounter
      ;end insert
     ENDIF
     SET bics_error = error(bics_msg,0)
     IF (bics_error > 0)
      CALL display_msg("Failed inserting into DM_ALPHA_FEATURES_ENV.",bics_msg)
      GO TO program_end
     ENDIF
   ENDFOR
   SET ocd_number = batch_package_number
   SET ocd_string = trim(cnvtstring(batch_package_number))
   IF (batch_package_number < 0)
    SET ocd_string_padded = build("-",format(abs(batch_package_number),"######;P0"))
   ELSE
    CALL display_msg("Fatal Error: Install Plan was not a valid number.","NONE")
    GO TO program_end
   ENDIF
   SET ocd_op->pre_op = olo_none
   SET ocd_op->cur_op = olo_load_ccl_file
   CALL end_status("Loading OCD schema CCL file successful",env_id,ocd_number)
   CALL dm_ocd_log_op(ocd_op->cur_op,ols_complete,"Loading of OCD schema ccl file successful")
   SET bics_error = error(bics_msg,0)
   IF (bics_error > 0)
    CALL display_msg("Failed writing to DM_OCD_LOG.",bics_msg)
    GO TO program_end
   ENDIF
   UPDATE  FROM dm_alpha_features_env defa
    SET defa.status = "Begin installation", defa.start_dt_tm = cnvtdatetime(curdate,curtime3), defa
     .end_dt_tm = null,
     defa.inst_mode = ocd_install_mode, defa.calling_script = call_script
    WHERE defa.environment_id=env_id
     AND defa.alpha_feature_nbr=batch_package_number
    WITH nocounter
   ;end update
   SET bics_error = error(bics_msg,0)
   IF (bics_error > 0)
    CALL display_msg("Failed updating from DM_ALPHA_FEATURES_ENV.",bics_msg)
    GO TO program_end
   ENDIF
   IF (curqual=0)
    INSERT  FROM dm_alpha_features_env defa
     SET defa.status = "Begin installation", defa.start_dt_tm = cnvtdatetime(curdate,curtime3), defa
      .end_dt_tm = null,
      defa.environment_id = env_id, defa.alpha_feature_nbr = batch_package_number, defa.inst_mode =
      ocd_install_mode,
      defa.calling_script = call_script, defa.curr_migration_ind = 0
     WITH nocounter
    ;end insert
   ENDIF
   SET bics_error = error(bics_msg,0)
   IF (bics_error > 0)
    CALL display_msg("Failed inserting into DM_ALPHA_FEATURES_ENV.",bics_msg)
    GO TO program_end
   ENDIF
 END ;Subroutine
 SUBROUTINE batch_afd_rows_step(bars_dummy)
   EXECUTE dm2_get_batch_components value(abs(batch_package_number))
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE batch_populate_readme_log(bprl_exec)
   SET bprl_readme = "README"
   SET bprl_done = "SUCCESS"
   DECLARE bprl_err_cd = i4
   DECLARE bprl_err_msg = c132
   DECLARE pkg_cnt = i4
   DECLARE rm_cnt = i4
   DECLARE lr_found = i2
   DECLARE rm_found = i2
   DECLARE rm_batch_dt_tm = dq8
   SET bprl_err_cd = 0
   SET bprl_err_msg = fillstring(132," ")
   SET pkg_cnt = 0
   SET rm_cnt = 0
   SET lr_found = 0
   SET rm_found = 0
   SET rm_msg = "This readme was automatically marked successful as part of a batch installation."
   SET bprl_err_cd = error(bprl_err_msg,1)
   FOR (pkg_cnt = 1 TO batch_list->package_cnt)
     FOR (rm_cnt = 1 TO size(batch_list->qual[pkg_cnt].rm_qual,5))
       SET lr_found = 0
       SET rm_found = 0
       SELECT INTO "nl:"
        "x"
        FROM dm_ocd_log dol
        WHERE dol.project_type=bprl_readme
         AND dol.project_name=cnvtstring(batch_list->qual[pkg_cnt].rm_qual[rm_cnt].readme_id)
         AND dol.ocd=batch_package_number
         AND dol.status=bprl_done
        DETAIL
         rm_found = 1, rm_batch_dt_tm = dol.batch_dt_tm
        WITH nocounter
       ;end select
       SET bprl_err_cd = error(bprl_err_msg,0)
       IF (bprl_err_cd)
        CALL display_msg("Fatal Error:  Failed selecting from DM_OCD_LOG.",bprl_err_msg)
        RETURN(0)
       ENDIF
       IF (rm_found)
        UPDATE  FROM dm_ocd_log l
         SET l.status = bprl_done, l.start_dt_tm = cnvtdatetime(curdate,curtime3), l.end_dt_tm =
          cnvtdatetime(curdate,curtime3),
          l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.message = rm_msg, l.batch_dt_tm =
          cnvtdatetime(rm_batch_dt_tm),
          l.active_ind = 1
         WHERE l.environment_id=env_id
          AND l.project_type=bprl_readme
          AND (l.ocd=batch_list->qual[pkg_cnt].package_number)
          AND l.project_name=cnvtstring(batch_list->qual[pkg_cnt].rm_qual[rm_cnt].readme_id)
          AND (l.project_instance=batch_list->qual[pkg_cnt].rm_qual[rm_cnt].instance)
         WITH nocounter
        ;end update
        SET bprl_err_cd = error(bprl_err_msg,0)
        IF (bprl_err_cd)
         CALL display_msg("Fatal Error:  Failed updating from DM_OCD_LOG.",bprl_err_msg)
         RETURN(0)
        ENDIF
        IF (curqual=0)
         INSERT  FROM dm_ocd_log l
          SET l.status = bprl_done, l.start_dt_tm = cnvtdatetime(curdate,curtime3), l.end_dt_tm =
           cnvtdatetime(curdate,curtime3),
           l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.message = rm_msg, l.project_type =
           bprl_readme,
           l.project_name = cnvtstring(batch_list->qual[pkg_cnt].rm_qual[rm_cnt].readme_id), l
           .environment_id = env_id, l.project_instance = batch_list->qual[pkg_cnt].rm_qual[rm_cnt].
           instance,
           l.ocd = batch_list->qual[pkg_cnt].package_number, l.batch_dt_tm = cnvtdatetime(
            rm_batch_dt_tm), l.active_ind = 1
          WITH nocounter
         ;end insert
         SET bprl_err_cd = error(bprl_err_msg,0)
         IF (bprl_err_cd)
          CALL display_msg("Fatal Error:  Failed updating from DM_OCD_LOG.",bprl_err_msg)
          RETURN(0)
         ENDIF
        ENDIF
        SELECT INTO "nl:"
         "x"
         FROM dm_ocd_log do
         WHERE do.environment_id=env_id
          AND do.project_type=bprl_readme
          AND (do.ocd=batch_list->qual[pkg_cnt].package_number)
          AND do.project_name=cnvtstring(batch_list->qual[pkg_cnt].rm_qual[rm_cnt].readme_id)
          AND do.status=bprl_done
          AND (do.project_instance=batch_list->qual[pkg_cnt].rm_qual[rm_cnt].instance)
         DETAIL
          lr_found = 1
         WITH nocounter
        ;end select
        IF ( NOT (lr_found))
         CALL display_msg("Fatal Error: Readme log row could not be confirmed.","NONE")
         RETURN(0)
        ENDIF
        SET bprl_err_cd = error(bprl_err_msg,0)
        IF (bprl_err_cd)
         CALL display_msg("Fatal Error:  Failed on select check from DM_OCD_LOG.",bprl_err_msg)
         RETURN(0)
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE batch_populate_install_log(bpil_op)
   CASE (bpil_op)
    OF olo_load_ccl_file:
     SET bcpl_msg = "Loading of OCD schema ccl file successful"
    OF olo_readme_report:
     SET bcpl_msg = "Finished displaying README estimate report"
    OF olo_code_sets:
     SET bcpl_msg = "Code sets installation successful"
    OF olo_pre_uts:
     SET bcpl_msg = "Finished executing all Pre-UTS Readmes steps"
    OF olo_uptime_schema:
     SET bcpl_msg = "UPTIME mode complete."
    OF olo_atrs:
     SET bcpl_msg = "Installing ATRs successful!"
    OF olo_post_uts:
     SET bcpl_msg = "Finished executing all Post-UTS Readmes steps"
    OF olo_pre_dts:
     SET bcpl_msg = "Finished executing all Pre-DTS Readmes steps"
    OF olo_downtime_schema:
     SET bcpl_msg = "DOWNTIME mode complete."
    OF olo_post_dts:
     SET bcpl_msg = "Finished executing all Post-DTS Readmes steps"
    OF olo_post_inst:
     SET bcpl_msg = "Finished executing all Post-INST Readmes steps"
    ELSE
     CALL display_msg("Failed: Unknown operation specified for batch logging.","NONE")
     RETURN(0)
   ENDCASE
   FOR (p_item = 1 TO size(batch_list->qual,5))
     SET ocd_number = batch_list->qual[p_item].package_number
     SET ocd_string = cnvtstring(batch_list->qual[p_item].package_number)
     SET ocd_string_padded = format(cnvtstring(batch_list->qual[p_item].package_number),"######;P0")
     CALL dm_ocd_log_op(bpil_op,ols_complete,bcpl_msg)
     IF ( NOT (dm_ocd_chk_op(bpil_op)))
      RETURN(0)
     ENDIF
     CALL end_status(bcpl_msg,env_id,ocd_number)
   ENDFOR
   SET ocd_number = batch_package_number
   SET ocd_string = trim(cnvtstring(batch_package_number))
   IF (batch_package_number < 0)
    SET ocd_string_padded = build("-",format(abs(batch_package_number),"######;P0"))
   ELSE
    CALL display_msg("Fatal Error: Install Plan was not a valid number.","NONE")
    GO TO program_end
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE display_msg(sbr_msg,sbr_errmsg)
   IF (sbr_errmsg="NONE")
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
    CALL echo(asterick_line)
    CALL echo("*")
    CALL echo("*")
    CALL echo(sbr_msg)
    CALL echo("*")
    CALL echo("*")
    CALL echo(asterick_line)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
   ELSE
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
    CALL echo(asterick_line)
    CALL echo("*")
    CALL echo(sbr_msg)
    CALL echo("*")
    CALL echo(concat("Error Message: ",sbr_errmsg))
    CALL echo("*")
    CALL echo(asterick_line)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
   ENDIF
 END ;Subroutine
#program_end
END GO
