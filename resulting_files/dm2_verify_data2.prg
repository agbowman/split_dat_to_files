CREATE PROGRAM dm2_verify_data2
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
 IF ((validate(dmvd->rows_to_compare,- (1))=- (1))
  AND validate(dmvd->rows_to_compare,99)=99)
  FREE RECORD dmvd
  RECORD dmvd(
    1 db_link = vc
    1 owner = vc
    1 table_name = vc
    1 rows_to_compare = i4
    1 rows_to_compare_all = i4
    1 timeout = i4
    1 tbl_cnt = i4
    1 appl_id = vc
    1 ranges_per_compare = i4
    1 uow_threshold = f8
    1 tgt_to_src = i2
    1 compare_start_dt_tm = dq8
    1 final_row_ind = i2
    1 use_verify2_ind = i2
    1 tbls[*]
      2 owner = vc
      2 table_name = vc
      2 last_analyzed = dq8
      2 num_rows = f8
      2 num_distinct = f8
      2 monitoring = i2
      2 master_id = f8
      2 updt_ind = i2
      2 status = vc
      2 scui_ind = i2
      2 tgt_exists_ind = i2
      2 excl_flag = i2
      2 excl_reason = vc
      2 col_list = vc
      2 data_type_list = vc
      2 full_col_list = vc
      2 keyid_col_name = vc
      2 exclude_ind = i2
      2 src_object_id = f8
      2 max_src_keyid = f8
      2 range_start_keyid = f8
      2 range_beg_keyid = f8
      2 range_end_keyid = f8
      2 compare_keyid_min = f8
      2 compare_keyid_max = f8
      2 last_range_keyid_min = f8
      2 last_range_keyid_max = f8
      2 last_src_mod_dt_tm = dq8
      2 cur_src_mod_dt_tm = dq8
      2 beg_dt_tm = dq8
      2 mismatch_event_cnt = i4
      2 last_match_dt_tm = dq8
      2 last_compare_dt_tm = dq8
      2 last_compare_cnt = f8
      2 last_match_cnt = f8
      2 rows_to_compare = f8
      2 last_mm_beg_keyid = f8
      2 last_mm_end_keyid = f8
      2 mm_beg_keyid = f8
      2 mm_end_keyid = f8
      2 mm_cnt = i4
      2 last_mm_cnt = i4
      2 mm_cnt_scui = f8
      2 last_mm_cnt_scui = f8
      2 date_col_exists = i2
      2 date_col_name = vc
      2 last_mm_rowid = vc
      2 last_ui_str = vc
      2 mm_rowid_min = vc
      2 ui_str = vc
      2 mm_rowid_dt_tm_min = dq8
      2 mm_pull_key = i4
      2 compare_where = vc
      2 col_cnt = i4
      2 cols[*]
        3 col_name = vc
        3 data_type = vc
        3 data_value = vc
      2 mms[*]
        3 keyid = f8
        3 mm_rowid = vc
        3 mm_rowid_dt_tm = dq8
  )
  SET dmvd->db_link = "DM2NOTSET"
  SET dmvd->owner = "DM2NOTSET"
  SET dmvd->table_name = "DM2NOTSET"
  SET dmvd->rows_to_compare = 0
  SET dmvd->tbl_cnt = 0
  SET dmvd->uow_threshold = 50000
  SET dmvd->rows_to_compare_all = 2000000
  SET dmvd->appl_id = "DM2NOTSET"
  SET dmvd->timeout = 120
 ENDIF
 IF ( NOT (validate(dvdr_user_list->cnt)))
  FREE RECORD dvdr_user_list
  RECORD dvdr_user_list(
    1 change_ind = i2
    1 cnt = i4
    1 qual[*]
      2 user = vc
  )
 ENDIF
 IF ( NOT (validate(dvdr_rpt_dtl_info->owner)))
  FREE RECORD dvdr_rpt_dtl_info
  RECORD dvdr_rpt_dtl_info(
    1 owner = vc
    1 table_name = vc
    1 src_db_name = vc
    1 tgt_db_name = vc
    1 db_link = vc
    1 tbl_cnt = i4
    1 tbls_compared = i4
    1 tbls_matched = i4
    1 tbls_complete = i4
    1 comparing_cnt = i4
    1 yet_to_be_compared = i4
    1 yet_to_be_compared_pct = f8
    1 tbls_mm_cnt = i4
    1 tbls_mm_down_cnt = i4
    1 tbls_excluded = i4
    1 mtch_pct = f8
    1 mismatch_pct = f8
    1 downtime_mm_pct = f8
    1 complete_pct = f8
    1 num_owners = i4
    1 owners_list = vc
    1 comp_dt_max = dq8
    1 comp_dt_min = dq8
    1 final_row_dt_tm = dq8
    1 tbls[*]
      2 owner = vc
      2 table_name = vc
      2 master_id = f8
      2 status = vc
      2 last_analyzed = dq8
      2 monitoring = i2
      2 keyid_col_name = vc
      2 src_object_id = f8
      2 max_src_keyid = f8
      2 orig_start_key = f8
      2 last_comp_keyid_min = f8
      2 last_comp_keyid_max = f8
      2 last_mismatch_keyid_min = f8
      2 last_compare_dt_tm = dq8
      2 last_src_mod_dt_tm = dq8
      2 cur_src_mod_dt_tm = dq8
      2 last_rows_compared = f8
      2 last_rows_mismatched = f8
      2 last_match_dt_tm = dq8
      2 mismatch_event_cnt = i4
      2 total_rows_compared = f8
      2 key_range_remaining = f8
      2 excl_reason = vc
  )
  SET dvdr_rpt_dtl_info->owner = "DM2NOTSET"
  SET dvdr_rpt_dtl_info->table_name = "DM2NOTSET"
  SET dvdr_rpt_dtl_info->db_link = "DM2NOTSET"
  SET dvdr_rpt_dtl_info->src_db_name = "DM2NOTSET"
  SET dvdr_rpt_dtl_info->tgt_db_name = "DM2NOTSET"
  SET dvdr_rpt_dtl_info->tbls_compared = 0
  SET dvdr_rpt_dtl_info->tbls_matched = 0
  SET dvdr_rpt_dtl_info->tbls_excluded = 0
  SET dvdr_rpt_dtl_info->num_owners = 0
  SET dvdr_rpt_dtl_info->owners_list = "DM2NOTSET"
 ENDIF
 DECLARE dvdr_uow_status = vc WITH protect, constant("NOCOMP-UOW")
 DECLARE dvdr_nocomp_size = vc WITH protect, constant("NOCOMP-SIZE")
 DECLARE dvdr_exclude = vc WITH protect, constant("EXCLUDE")
 DECLARE dvdr_comparing = vc WITH protect, constant("COMPARING")
 DECLARE dvdr_match = vc WITH protect, constant("MATCH")
 DECLARE dvdr_error = vc WITH protect, constant("ERROR")
 DECLARE dvdr_mismatch = vc WITH protect, constant("MISMATCH")
 DECLARE dvdr_ready = vc WITH protect, constant("READY")
 DECLARE dvdr_complete = vc WITH protect, constant("COMPLETE")
 DECLARE dvdr_progressupdate = vc WITH protect, constant("PROGRESSUPDATE")
 DECLARE dvdr_statusupdate = vc WITH protect, constant("STATUSUPDATE")
 DECLARE dvdr_get_user_connect_info(dguci_is_mig_flag=i2) = i2
 DECLARE dvdr_get_selected_user_list(dgsul_user=vc) = i2
 DECLARE dvdr_get_data_verification_info(dgdvi_is_mig=i2) = i2
 DECLARE dvdr_populate_table_list(dptl_is_mig_flag=i2) = i2
 DECLARE dvdr_get_tblmod(dgt_mode=vc) = i2
 DECLARE dvdr_setup_tables_for_compare(null) = i2
 DECLARE dvdr_write_exclusion_rows(null) = i2
 DECLARE dvdr_write_dminfo_rows(null) = i2
 DECLARE dvdr_get_verify_data_rpt_info(dgvdri_return=i2,dgvdri_quit=i2(ref)) = i2
 DECLARE dvdr_get_vdata_rpt_env_info(null) = i2
 DECLARE dvdr_load_rpt_record(null) = i2
 DECLARE dvdr_get_cur_max_src_keyid(null) = i2
 DECLARE dvdr_appid_work(daw_just_check=i2,daw_appl=vc,daw_continue=i2(ref)) = i2
 DECLARE dvdr_load_master(dlm_masterid) = i2
 DECLARE dvdr_check_stop(dcs_stop=i2(ref)) = i2
 DECLARE dvdr_get_table(dgt_masterid_out=f8(ref)) = i2
 DECLARE dvdr_cleanup_stranded(null) = i2
 DECLARE dvdr_get_verify2(null) = i2
 DECLARE dvdr_get_old_lag(dgol_lag_out=dq8(ref)) = i2
 DECLARE dvdr_parse_list(dpl_type=vc,dpl_delim=vc,dpl_str_in=vc,dpl_tbl_ndx=i2) = i2
 SUBROUTINE dvdr_parse_list(dpl_type,dpl_delim,dpl_str_in,dpl_tbl_ndx)
   IF ((dm_err->debug_flag > 0))
    CALL echo(dpl_type)
    CALL echo(dpl_str_in)
   ENDIF
   SET dpl_start_pt = 0
   SET dpl_end_pt = 0
   SET dpl_rep_cnt = 0
   IF (dpl_type="COLUMN")
    SET dmvd->tbls[dpl_tbl_ndx].col_cnt = 0
    SET stat = alterlist(dmvd->tbls[dpl_tbl_ndx].cols,0)
   ENDIF
   IF (findstring(dpl_delim,dpl_str_in,1,0)=0)
    IF (dpl_type="COLUMN")
     SET dmvd->tbls[dpl_tbl_ndx].col_cnt = (dmvd->tbls[dpl_tbl_ndx].col_cnt+ 1)
     SET stat = alterlist(dmvd->tbls[dpl_tbl_ndx].cols,1)
     SET dmvd->tbls[dpl_tbl_ndx].cols[1].col_name = dpl_str_in
    ELSEIF (dpl_type="DATATYPE")
     SET dmvd->tbls[dpl_tbl_ndx].cols[1].data_type = dpl_str_in
    ELSE
     SET dmvd->tbls[dpl_tbl_ndx].cols[1].data_value = dpl_str_in
    ENDIF
   ELSE
    IF (size(dpl_delim) > 1)
     SET dpl_start_pt = (size(dpl_delim)+ 1)
    ELSE
     SET dpl_start_pt = size(dpl_delim)
    ENDIF
    SET dpl_end_pt = 1
    WHILE (dpl_end_pt > 0)
      SET dpl_rep_cnt = (dpl_rep_cnt+ 1)
      SET dpl_end_pt = findstring(dpl_delim,dpl_str_in,dpl_start_pt,0)
      IF (dpl_end_pt=0
       AND dpl_type IN ("COLUMN", "DATATYPE"))
       IF (dpl_type="COLUMN")
        SET dmvd->tbls[dpl_tbl_ndx].col_cnt = (dmvd->tbls[dpl_tbl_ndx].col_cnt+ 1)
        SET stat = alterlist(dmvd->tbls[dpl_tbl_ndx].cols,dpl_rep_cnt)
        SET dmvd->tbls[dpl_tbl_ndx].cols[dpl_rep_cnt].col_name = substring(dpl_start_pt,(textlen(
          dpl_str_in) - (dpl_start_pt - size(dpl_delim))),dpl_str_in)
       ELSEIF (dpl_type="DATATYPE")
        SET dmvd->tbls[dpl_tbl_ndx].cols[dpl_rep_cnt].data_type = substring(dpl_start_pt,(textlen(
          dpl_str_in) - (dpl_start_pt - size(dpl_delim))),dpl_str_in)
       ENDIF
      ELSE
       IF (dpl_end_pt > 0)
        IF (dpl_type="COLUMN")
         SET dmvd->tbls[dpl_tbl_ndx].col_cnt = (dmvd->tbls[dpl_tbl_ndx].col_cnt+ 1)
         SET stat = alterlist(dmvd->tbls[dpl_tbl_ndx].cols,dpl_rep_cnt)
         SET dmvd->tbls[dpl_tbl_ndx].cols[dpl_rep_cnt].col_name = substring(dpl_start_pt,(dpl_end_pt
           - dpl_start_pt),dpl_str_in)
        ELSEIF (dpl_type="DATATYPE")
         SET dmvd->tbls[dpl_tbl_ndx].cols[dpl_rep_cnt].data_type = substring(dpl_start_pt,(dpl_end_pt
           - dpl_start_pt),dpl_str_in)
        ELSE
         SET dmvd->tbls[dpl_tbl_ndx].cols[dpl_rep_cnt].data_value = notrim(substring(dpl_start_pt,(
           dpl_end_pt - dpl_start_pt),dpl_str_in))
        ENDIF
       ENDIF
      ENDIF
      SET dpl_start_pt = (dpl_end_pt+ size(dpl_delim))
    ENDWHILE
   ENDIF
 END ;Subroutine
 SUBROUTINE dvdr_check_stop(dcs_stop)
   SET dcs_stop = 0
   SET dm_err->eproc = "Check if compare has been marked to stop."
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_VDATA_INFO"
     AND d.info_name="DM2_VDATA_STOP_COMPARE"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dcs_stop = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_cleanup_stranded(null)
   DECLARE dcs_status_ret = vc WITH protect, noconstant("")
   FREE RECORD dcs_appid
   RECORD dcs_appid(
     1 appid_cnt = i4
     1 qual[*]
       2 appl_id = vc
   )
   SET dm_err->eproc = "Gather appids for rows in COMPARING status"
   SELECT DISTINCT INTO "nl:"
    d.appl_ident
    FROM dm_vdata_master d
    WHERE d.compare_status=dvdr_comparing
    DETAIL
     dcs_appid->appid_cnt = (dcs_appid->appid_cnt+ 1), stat = alterlist(dcs_appid->qual,dcs_appid->
      appid_cnt), dcs_appid->qual[dcs_appid->appid_cnt].appl_id = d.appl_ident
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    RETURN(1)
   ENDIF
   FOR (dcs_cnt = 1 TO dcs_appid->appid_cnt)
    SET dcs_status_ret = dm2_get_appl_status(dcs_appid->qual[dcs_cnt].appl_id)
    CASE (dcs_status_ret)
     OF "A":
      SET dm_err->eproc = concat(dcs_appid->qual[dcs_cnt].appl_id," is currently Active.")
      CALL disp_msg("",dm_err->logfile,10)
      RETURN(1)
     OF "I":
      SET dm_err->eproc = concat(dcs_appid->qual[dcs_cnt].appl_id," is currently Inactive.")
      CALL disp_msg("",dm_err->logfile,10)
      SET dm_err->eproc = "Set status to error due to expired appl_id."
      UPDATE  FROM dm_vdata_master d
       SET d.compare_status = dvdr_error, d.message_txt = concat(dcs_appid->qual[dcs_cnt].appl_id,
         " is currently Inactive.")
       WHERE (d.appl_ident=dcs_appid->qual[dcs_cnt].appl_id)
        AND d.compare_status=dvdr_comparing
       WITH nocounter
      ;end update
      IF (check_error(dm_err->eproc)=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      COMMIT
     OF "E":
      RETURN(0)
    ENDCASE
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_get_table(dgt_masterid_out)
   DECLARE dgt_have_table = i2 WITH protect, noconstant(0)
   DECLARE dgt_cnt = i2 WITH protect, noconstant(0)
   DECLARE dgt_compare_hold = f8 WITH protect, noconstant(cnvtdatetime("01-JAN-1899"))
   SET dgt_masterid_out = 0
   WHILE (dgt_have_table=0)
     SET dgt_cnt = (dgt_cnt+ 1)
     SET dm_err->eproc = "Find table to compare."
     SELECT INTO "nl:"
      FROM dm_vdata_master d
      WHERE  NOT (d.compare_status IN (dvdr_exclude, dvdr_uow_status, dvdr_comparing, dvdr_complete,
      dvdr_nocomp_size))
       AND d.updt_dt_tm > cnvtdatetime(dgt_compare_hold)
       AND  NOT ( EXISTS (
      (SELECT
       "x"
       FROM dm_vdata_exclude_dtl e
       WHERE d.dm_vdata_master_id=e.dm_vdata_master_id)))
      ORDER BY d.updt_dt_tm, d.owner_name, d.table_name
      DETAIL
       dgt_masterid_out = d.dm_vdata_master_id, dgt_compare_hold = d.last_compare_dt_tm
      WITH maxqual(d,1)
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (curqual=0)
      SET dgt_masterid_out = 0
      RETURN(1)
     ENDIF
     IF (dgt_masterid_out > 0)
      SET dm_err->eproc = "Set candidate table status to COMPARING."
      UPDATE  FROM dm_vdata_master d
       SET d.compare_status = dvdr_comparing, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d
        .appl_ident = currdbhandle
       WHERE d.dm_vdata_master_id=dgt_masterid_out
        AND d.compare_status != "COMPARING"
       WITH nocounter
      ;end update
      IF (curqual > 0)
       SET dgt_have_table = 1
      ELSE
       SET dgt_masterid_out = 0
      ENDIF
      IF (check_error(dm_err->eproc)=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      COMMIT
     ENDIF
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_get_old_lag(dgol_lag_out)
   SET dgol_lag_out = cnvtdatetime("01-JAN-1900")
   SET dm_err->eproc = "Obtain delivery lag time from Admin"
   SELECT INTO "nl:"
    mintime = min(d.info_date)
    FROM dm2_admin_dm_info d
    WHERE d.info_domain="DM2MIG_DELDATA"
     AND d.info_name="DELIV*LAG"
    DETAIL
     dgol_lag_out = cnvtdatetime(mintime)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_get_user_connect_info(dguci_is_mig_flag)
   SET dm_err->eproc = "Getting user connection data for source and target"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   IF (dguci_is_mig_flag=0)
    SET dm_err->eproc = "Getting Source Connect Information."
    SET dm2_install_schema->dbase_name = '"SOURCE"'
    SET dm2_install_schema->u_name = "V500"
    SET dm2_force_connect_string = 1
    EXECUTE dm2_connect_to_dbase "PC"
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    SET dm2_force_connect_string = 0
    SET dm2_install_schema->src_dbase_name = trim(cnvtupper(currdbname))
    SET dm2_install_schema->src_v500_p_word = dm2_install_schema->p_word
    SET dm2_install_schema->src_v500_connect_str = dm2_install_schema->connect_str
    SET dm_err->eproc = "Getting Target Connect Information."
    SET dm2_install_schema->dbase_name = '"TARGET"'
    SET dm2_install_schema->u_name = cnvtupper(currdbuser)
    EXECUTE dm2_connect_to_dbase "PC"
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    SET dm2_install_schema->target_dbase_name = trim(cnvtupper(currdbname))
    IF (cnvtupper(currdbuser)="V500")
     SET dm2_install_schema->v500_p_word = dm2_install_schema->p_word
     SET dm2_install_schema->v500_connect_str = dm2_install_schema->connect_str
    ENDIF
   ELSE
    SET dm2_install_schema->src_dbase_name = dmr_mig_data->src_db_name
    SET dm2_install_schema->src_v500_p_word = dmr_mig_data->src_v500_pwd
    SET dm2_install_schema->src_v500_connect_str = dmr_mig_data->src_v500_cnct_str
    SET dm2_install_schema->target_dbase_name = dmr_mig_data->tgt_db_name
    IF (cnvtupper(currdbuser)="V500")
     SET dm2_install_schema->v500_p_word = dmr_mig_data->tgt_v500_pwd
     SET dm2_install_schema->v500_connect_str = dmr_mig_data->tgt_v500_cnct_str
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_get_data_verification_info(dgdvi_is_mig)
   DECLARE dgdvi_verify_data_setup_cont = i2 WITH protect, noconstant(1)
   DECLARE dgdvi_error = i2 WITH protect, noconstant(0)
   DECLARE dgdvi_default = vc WITH protect, noconstant("C")
   DECLARE dgdvi_dblink = vc WITH protect, noconstant("REF_DATA_LINK")
   DECLARE dgdvi_owner = vc WITH protect, noconstant(currdbuser)
   DECLARE dgdvi_table_name = vc WITH protect, noconstant("*")
   DECLARE dgdvi_num_rows = i4 WITH protect, noconstant(500000)
   SET dm_err->eproc = "Collecting data verification setup information"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SET dm_err->eproc = "Setting default values for data verification variables"
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_VDATA_INFO"
     AND di.info_name IN ("DM2_VDATA_DBLINK", "DM2_VDATA_OWNER", "DM2_VDATA_TABLE_NAME",
    "DM2_VDATA_NUMROWS", "DM2_VDATA_NUMROWS_ALL",
    "DM2_VDATA_TIMEOUT", "DM2_VDATA_TGT_TO_SRC", "DM2_VDATA_UOW_THRESHOLD")
    DETAIL
     IF (di.info_name="DM2_VDATA_DBLINK"
      AND (dmvd->db_link="DM2NOTSET"))
      dgdvi_dblink = di.info_char
     ENDIF
     IF (di.info_name="DM2_VDATA_OWNER"
      AND (dmvd->owner="DM2NOTSET"))
      dgdvi_owner = di.info_char
     ENDIF
     IF (di.info_name="DM2_VDATA_TABLE_NAME"
      AND (dmvd->table_name="DM2NOTSET"))
      dgdvi_table_name = di.info_char
     ENDIF
     IF (di.info_name="DM2_VDATA_NUMROWS"
      AND (dmvd->rows_to_compare=0))
      dgdvi_num_rows = di.info_number
     ENDIF
     IF (di.info_name="DM2_VDATA_NUMROWS_ALL")
      dmvd->rows_to_compare_all = di.info_number
     ENDIF
     IF (di.info_name="DM2_VDATA_UOW_THRESHOLD")
      dmvd->uow_threshold = di.info_number
     ENDIF
     IF (di.info_name="DM2_VDATA_TIMEOUT")
      dmvd->timeout = di.info_number
     ENDIF
     IF (di.info_name="DM2_VDATA_TGT_TO_SRC")
      dmvd->tgt_to_src = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Validating default DB LINK"
   SELECT INTO "nl:"
    FROM dba_db_links ddl
    WHERE ddl.db_link=concat(trim(dgdvi_dblink),".WORLD")
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->err_ind = 1
    RETURN(0)
   ELSEIF (curqual=0)
    SET dgdvi_dblink = ""
   ENDIF
   WHILE (dgdvi_verify_data_setup_cont=1)
     SET width = 132
     IF ((dm_err->debug_flag != 511))
      SET message = window
     ENDIF
     CALL clear(1,1)
     CALL box(1,1,24,131)
     CALL text(2,2,"Setup Data Verification")
     IF (dgdvi_is_mig=0)
      CALL text(5,2,"Source DB Link: ")
      CALL text(7,2,"Owner: ")
      CALL text(9,2,"Table Name: ")
      IF (dgdvi_error=1)
       CALL text(13,2,concat("The DB Link given (",dmvd->db_link,
         ".WORLD) was not found. Please modify."))
       SET dgdvi_default = "M"
       SET dgdvi_error = 0
      ENDIF
     ENDIF
     CALL text(11,2,"Rows to Compare: ")
     CALL text(15,2,"(C)ontinue, (M)odify, (Q)uit: ")
     IF (dgdvi_is_mig=0)
      CALL accept(5,30,"P(30);cu",dgdvi_dblink
       WHERE  NOT (trim(curaccept)=""))
      SET dgdvi_dblink = build(curaccept)
      SET accept = nopatcheck
      CALL accept(7,30,"P(30);cu",dgdvi_owner
       WHERE  NOT (trim(curaccept)=""))
      SET dgdvi_owner = build(curaccept)
      CALL accept(9,30,"P(30);cu",dgdvi_table_name
       WHERE  NOT (trim(curaccept)=""))
      SET dgdvi_table_name = build(curaccept)
     ENDIF
     CALL accept(11,30,"99999999;",dgdvi_num_rows
      WHERE curaccept > 0)
     SET dgdvi_num_rows = curaccept
     CALL accept(15,33,"A;CU",dgdvi_default
      WHERE curaccept IN ("M", "C", "Q"))
     CASE (curaccept)
      OF "C":
       SET dgdvi_verify_data_setup_cont = 0
       SET dmvd->db_link = dgdvi_dblink
       SET dmvd->owner = dgdvi_owner
       SET dmvd->table_name = dgdvi_table_name
       SET dmvd->rows_to_compare = dgdvi_num_rows
       SET dm_err->eproc = "Checking to see if db_link provided is valid"
       SELECT INTO "nl:"
        FROM dba_db_links ddl
        WHERE ddl.db_link=concat(cnvtupper(dmvd->db_link),".WORLD")
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc) != 0)
        SET dm_err->err_ind = 1
        RETURN(0)
       ELSEIF (curqual=0)
        SET dgdvi_error = 1
        SET dgdvi_verify_data_setup_cont = 1
       ENDIF
      OF "Q":
       SET dm_err->err_ind = 1
       SET dm_err->emsg = "User Quit Process"
       RETURN(0)
     ENDCASE
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_get_selected_user_list(dgsul_user)
   SET dm_err->eproc = "Retrieving list of users from matching selection criteria."
   SELECT INTO "nl:"
    user = trim(substring(1,30,au.username))
    FROM all_users au
    WHERE  NOT (au.username IN ("CTXSYS", "DBSNMP", "LBACSYS", "MDDATA", "MDSYS",
    "DMSYS", "OLAPSYS", "ORDPLUGINS", "ORDSYS", "OUTLN",
    "SI_INFORMTN_SCHEMA", "SYS", "SYSMAN", "SYSTEM"))
     AND au.username=patstring(trim(dgsul_user))
    ORDER BY user
    HEAD REPORT
     dvdr_user_list->cnt = 0, stat = alterlist(dvdr_user_list->qual,0), dvdr_user_list->change_ind =
     0
    DETAIL
     dvdr_user_list->cnt = (dvdr_user_list->cnt+ 1), stat = alterlist(dvdr_user_list->qual,
      dvdr_user_list->cnt), dvdr_user_list->qual[dvdr_user_list->cnt].user = user
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_save_user_list(dsul_is_mig_flag)
   DECLARE dsul_user_cnt = i4 WITH protect, noconstant(0)
   DECLARE dsul_user_list = vc WITH protect, noconstant("")
   DECLARE dsul_cnt = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Writing dm_info row to save user list"
   IF (dsul_is_mig_flag=1)
    SET dsul_user_cnt = dmr_user_list->cnt
    SET dsul_user_list = dmr_user_list->qual[1].user
    FOR (dsul_cnt = 2 TO dmr_user_list->cnt)
      SET dsul_user_list = concat(dsul_user_list,",",dmr_user_list->qual[dsul_cnt].user)
    ENDFOR
   ELSE
    SET dsul_user_cnt = dvdr_user_list->cnt
    SET dsul_user_list = dvdr_user_list->qual[1].user
    FOR (dsul_cnt = 2 TO dvdr_user_list->cnt)
      SET dsul_user_list = concat(dsul_user_list,", ",dvdr_user_list->qual[dsul_cnt].user)
    ENDFOR
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_VDATA_INFO"
     AND di.info_name="DM2_VDATA_USERLIST"
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_VDATA_INFO", di.info_name = "DM2_VDATA_USERLIST", di.info_number =
      dsul_user_cnt,
      di.info_char = dsul_user_list
     WITH nocounter
    ;end insert
   ELSE
    UPDATE  FROM dm_info di
     SET di.info_number = dsul_user_cnt, di.info_char = dsul_user_list
     WHERE di.info_domain="DM2_VDATA_INFO"
      AND di.info_name="DM2_VDATA_USERLIST"
     WITH nocounter
    ;end update
   ENDIF
   IF (check_error(dm_err->eproc) != 0)
    ROLLBACK
    SET dm_err->err_ind = 1
    RETURN(0)
   ELSE
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_perform_vdat_cleanup(null)
   SET dm_err->eproc = "Deleting rows from data verification tables"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SET dm_err->eproc = "Deleting rows from Master Table"
   DELETE  FROM dm_vdata_master dvm
    WHERE dvm.dm_vdata_master_id > 0
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc) != 0)
    ROLLBACK
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Deleting rows from Exclude Detail Table"
   DELETE  FROM dm_vdata_exclude_dtl dved
    WHERE dved.dm_vdata_exclude_dtl_id > 0
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc) != 0)
    ROLLBACK
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Deleting rows from Mismatch Table"
   DELETE  FROM dm_vdata_mismatch dvm
    WHERE dvm.dm_vdata_mismatch_id > 0
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc) != 0)
    ROLLBACK
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_populate_table_list(dptl_is_mig_flag)
   DECLARE dptl_master_id_is_null = i2 WITH protect, noconstant(0)
   DECLARE dptl_tbl_cnt = i4 WITH protect, noconstant(0)
   DECLARE dptl_tbl_ndx = i4 WITH protect, noconstant(0)
   DECLARE dptl_excl_clause = vc WITH protect, noconstant("")
   DECLARE dptl_tbl = vc WITH protect, noconstant("")
   DECLARE dptl_owner = vc WITH protect, noconstant("")
   DECLARE dptl_mngd_tables = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Populating dm2_fill_sch_except record structure"
   IF ( NOT (dm2_fill_sch_except("LOCAL")))
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF ((dm2_sch_except->tcnt > 0))
    SET dm_err->eproc = "Generating table exclusion list from dm2_sch_except record structure."
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(dm2_sch_except->tcnt))
     DETAIL
      IF (d.seq=1)
       dptl_excl_clause = concat("ao.object_name NOT IN ('",dm2_sch_except->tbl[d.seq].tbl_name,"'")
      ELSE
       dptl_excl_clause = concat(dptl_excl_clause,",'",dm2_sch_except->tbl[d.seq].tbl_name,"'")
      ENDIF
     FOOT REPORT
      dptl_excl_clause = concat(dptl_excl_clause,")")
     WITH nocounter, nullreport
    ;end select
    IF (check_error(dm_err->eproc))
     SET dm_err->err_ind = 1
     RETURN(0)
    ENDIF
   ENDIF
   SET dptl_mngd_tables = ""
   IF (dmr_load_managed_tables(dptl_mngd_tables)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Populating the dmvd record structure with the list of tables to be verified"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SELECT INTO "nl:"
    nullind_dvm_dm_vdata_master_id = nullind(dvm.dm_vdata_master_id)
    FROM (value(concat("DBA_OBJECTS@",dmvd->db_link)) ao),
     dm_vdata_master dvm
    WHERE ao.object_type="TABLE"
     AND ao.owner=patstring(cnvtupper(dmvd->owner))
     AND ao.object_name=patstring(dmvd->table_name)
     AND parser(dptl_excl_clause)
     AND parser(concat(" ao.object_name not in (",dptl_mngd_tables,")"))
     AND outerjoin(ao.owner)=dvm.owner_name
     AND outerjoin(ao.object_name)=dvm.table_name
    ORDER BY ao.owner, ao.object_name
    HEAD REPORT
     dmvd->tbl_cnt = 0, stat = alterlist(dmvd->tbls,0), dptl_tbl_cnt = 0
    DETAIL
     dptl_tbl_cnt = (dptl_tbl_cnt+ 1)
     IF (mod(dptl_tbl_cnt,500)=1)
      stat = alterlist(dmvd->tbls,(dptl_tbl_cnt+ 499))
     ENDIF
     dmvd->tbls[dptl_tbl_cnt].owner = ao.owner, dmvd->tbls[dptl_tbl_cnt].table_name = ao.object_name,
     dmvd->tbls[dptl_tbl_cnt].master_id = evaluate(nullind_dvm_dm_vdata_master_id,0,dvm
      .dm_vdata_master_id,0),
     dmvd->tbls[dptl_tbl_cnt].src_object_id = ao.object_id, dmvd->tbls[dptl_tbl_cnt].date_col_name =
     "DM2NOTSET"
     IF (textlen(cnvtstring(dmvd->tbls[dptl_tbl_cnt].src_object_id)) > 13)
      dmvd->tbls[dptl_tbl_cnt].excl_flag = 40, dmvd->tbls[dptl_tbl_cnt].excl_reason =
      "Length of Object ID exceeds limit"
     ENDIF
     IF ((dmvd->tbls[dptl_tbl_cnt].table_name=patstring("DM_VDAT*")))
      dmvd->tbls[dptl_tbl_cnt].excl_flag = 70, dmvd->tbls[dptl_tbl_cnt].excl_reason =
      "Table used for Compare Process. Not eligible for comparison"
     ENDIF
    FOOT REPORT
     dmvd->tbl_cnt = dptl_tbl_cnt, stat = alterlist(dmvd->tbls,dmvd->tbl_cnt)
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    RETURN(0)
   ELSEIF ((dmvd->tbl_cnt=0))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "No valid tables returned!"
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Checking if tables being compared exist in TARGET."
   SELECT INTO "nl:"
    FROM dba_tables d
    DETAIL
     IF (locateval(dptl_tbl_ndx,1,dmvd->tbl_cnt,d.owner,dmvd->tbls[dptl_tbl_ndx].owner,
      d.table_name,dmvd->tbls[dptl_tbl_ndx].table_name) > 0)
      dmvd->tbls[dptl_tbl_ndx].tgt_exists_ind = 1
      IF (d.temporary="Y")
       dmvd->tbls[dptl_tbl_ndx].excl_flag = 60, dmvd->tbls[dptl_tbl_ndx].excl_reason =
       "Temporary Table: Not Verified"
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF (dptl_is_mig_flag=1)
    SET dm_err->eproc = "Exclude from compare if excluded from migration."
    SELECT INTO "nl:"
     FROM (value(concat("DM_INFO@",dmvd->db_link)) di)
     WHERE ((di.info_domain="DM2_MIG_EXCL"
      AND di.info_number <= 20) OR (((di.info_domain="DM2_MIG_NONGG_REP") OR (di.info_domain=
     "DM2_MIG_ALLOW_NOPK"
      AND di.info_number=0)) ))
     DETAIL
      dptl_tbl = trim(substring((findstring(".",di.info_name,1,1)+ 1),(textlen(trim(di.info_name)) -
        findstring(".",di.info_name,1,1)),di.info_name),3), dptl_owner = substring(1,(findstring(".",
        di.info_name,1,1) - 1),di.info_name)
      IF (locateval(dptl_tbl_ndx,1,dmvd->tbl_cnt,dptl_owner,dmvd->tbls[dptl_tbl_ndx].owner,
       dptl_tbl,dmvd->tbls[dptl_tbl_ndx].table_name) > 0)
       IF (di.info_domain="DM2_MIG_NONGG_REP")
        dmvd->tbls[dptl_tbl_ndx].excl_flag = 90, dmvd->tbls[dptl_tbl_ndx].excl_reason =
        "DB Migration - Manual Compare"
       ELSEIF (di.info_domain="DM2_MIG_ALLOW_NOPK")
        dmvd->tbls[dptl_tbl_ndx].excl_flag = 90, dmvd->tbls[dptl_tbl_ndx].excl_reason =
        "DB Migration - Compare Exclusion"
       ELSE
        IF ((dmvd->tbls[dptl_tbl_ndx].excl_flag=0))
         dmvd->tbls[dptl_tbl_ndx].excl_flag = di.info_number
         CASE (di.info_number)
          OF 15:
           dmvd->tbls[dptl_tbl_ndx].excl_reason = "DB Migration - Manual Exclusion",dmvd->tbls[
           dptl_tbl_ndx].excl_flag = 30
          OF 16:
           dmvd->tbls[dptl_tbl_ndx].excl_reason = "DB Migration - Materialized View Exclusion"
          OF 17:
           dmvd->tbls[dptl_tbl_ndx].excl_reason = "DB Migration - Materialized View Exclusion"
          OF 18:
           dmvd->tbls[dptl_tbl_ndx].excl_reason =
           "DB Migration - Table contains column names which are duplicated."
          OF 19:
           dmvd->tbls[dptl_tbl_ndx].excl_reason =
           "DB Migration - Table contains column names which have same name as oracle data type."
          OF 20:
           dmvd->tbls[dptl_tbl_ndx].excl_reason = "DB Migration - Invalid Data Type Exclusion"
         ENDCASE
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     SET dm_err->err_ind = 1
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_setup_tables_for_compare(null)
   DECLARE dstfc_cnt = i4 WITH protect, noconstant(0)
   DECLARE dstfc_num = i4 WITH protect, noconstant(0)
   DECLARE dstfc_pos = i4 WITH protect, noconstant(0)
   DECLARE dstfc_pos2 = i4 WITH protect, noconstant(0)
   DECLARE dstfc_full_col_list = vc WITH protect, noconstant("")
   DECLARE dstfc_data_type_list = vc WITH protect, noconstant("")
   DECLARE dstfc_full_tname = vc WITH protect, noconstant("")
   DECLARE dstfc_ndx = i4 WITH protect, noconstant(0)
   DECLARE dstfc_lag_time = dq8 WITH protect, noconstant(0.0)
   SET dm_err->eproc = "Setting up tables for compare"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   FREE RECORD dstfc_index
   RECORD dstfc_index(
     1 ind_cnt = i4
     1 qual[*]
       2 table_name = vc
       2 owner = vc
       2 index_name = vc
   )
   FREE RECORD dstfc_col_list
   RECORD dstfc_col_list(
     1 col_cnt = i4
     1 qual[*]
       2 owner_name = vc
       2 table_name = vc
       2 col_name = vc
   )
   SET dm2_install_schema->u_name = "V500"
   SET dm2_install_schema->dbase_name = dm2_install_schema->src_dbase_name
   SET dm2_install_schema->connect_str = dm2_install_schema->src_v500_connect_str
   SET dm2_install_schema->p_word = dm2_install_schema->src_v500_p_word
   EXECUTE dm2_connect_to_dbase "CO"
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF (dmr_load_di_filter(null)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Obtain single column unique indexes"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SELECT DISTINCT INTO "nl:"
    x = concat(trim(dtc.owner),".",trim(dtc.table_name)), dtc.column_name
    FROM dba_tab_columns dtc,
     dba_ind_columns dic
    WHERE dtc.table_name=dic.table_name
     AND dtc.column_name=dic.column_name
     AND dtc.owner=dic.table_owner
     AND dtc.table_name=patstring(dmvd->table_name)
     AND dic.table_name=patstring(dmvd->table_name)
     AND list(dic.index_name,dic.table_owner) IN (
    (SELECT
     dic2.index_name, dic2.table_owner
     FROM dba_ind_columns dic2,
      dba_indexes di
     WHERE dic2.index_name=di.index_name
      AND di.uniqueness="UNIQUE"
      AND dic2.index_owner=di.owner
      AND expand(dstfc_num,1,dvdr_user_list->cnt,dic2.table_owner,dvdr_user_list->qual[dstfc_num].
      user)
     GROUP BY dic2.index_name, dic2.table_owner
     HAVING count(dic2.column_name)=1))
    ORDER BY x, dtc.column_name
    DETAIL
     dstfc_pos = locateval(dstfc_cnt,1,dmvd->tbl_cnt,dtc.owner,dmvd->tbls[dstfc_cnt].owner,
      dtc.table_name,dmvd->tbls[dstfc_cnt].table_name)
     IF (dstfc_pos > 0)
      IF ((dmvd->tbls[dstfc_pos].scui_ind != 1))
       IF (trim(dtc.data_type) IN ("NUMBER", "FLOAT"))
        dmvd->tbls[dstfc_pos].scui_ind = 1
       ELSE
        dmvd->tbls[dstfc_pos].scui_ind = 3
       ENDIF
       dmvd->tbls[dstfc_pos].keyid_col_name = dtc.column_name, dmvd->tbls[dstfc_pos].col_list = dmvd
       ->tbls[dstfc_pos].keyid_col_name, dmvd->tbls[dstfc_pos].data_type_list = trim(dtc.data_type)
      ENDIF
     ENDIF
    WITH nocounter, noheading
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Obtain multiple column unique indexes with highest distinct column value"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SELECT DISTINCT INTO "nl:"
    x = concat(trim(dtc.owner),".",trim(dtc.table_name)), dtc.column_name, nd_null = nullind(dtc
     .num_distinct)
    FROM dm_dba_columns_actual_stats dtc,
     dba_ind_columns dic
    WHERE dtc.table_name=dic.table_name
     AND dtc.column_name=dic.column_name
     AND dtc.owner=dic.table_owner
     AND dic.column_position=1
     AND dtc.table_name=patstring(dmvd->table_name)
     AND dic.table_name=patstring(dmvd->table_name)
     AND list(dic.index_name,dic.table_owner) IN (
    (SELECT
     dic2.index_name, dic2.table_owner
     FROM dba_ind_columns dic2,
      dba_indexes di
     WHERE dic2.index_name=di.index_name
      AND di.uniqueness="UNIQUE"
      AND dic2.index_owner=di.owner
      AND expand(dstfc_num,1,dvdr_user_list->cnt,dic2.table_owner,dvdr_user_list->qual[dstfc_num].
      user)
     GROUP BY dic2.index_name, dic2.table_owner
     HAVING count(dic2.column_name) > 1))
    ORDER BY x, dtc.num_distinct DESC, dic.index_name,
     dic.column_position
    HEAD x
     dstfc_pos = locateval(dstfc_cnt,1,dmvd->tbl_cnt,dtc.owner,dmvd->tbls[dstfc_cnt].owner,
      dtc.table_name,dmvd->tbls[dstfc_cnt].table_name)
     IF (dstfc_pos > 0)
      IF ((dmvd->tbls[dstfc_pos].scui_ind=0))
       dmvd->tbls[dstfc_pos].num_distinct = evaluate(nd_null,1,- (1),dtc.num_distinct)
       IF (dtc.data_type IN ("NUMBER", "FLOAT"))
        dmvd->tbls[dstfc_pos].scui_ind = 2, dmvd->tbls[dstfc_pos].keyid_col_name = dtc.column_name
       ELSE
        dmvd->tbls[dstfc_pos].keyid_col_name = dtc.column_name, dmvd->tbls[dstfc_pos].scui_ind = 3
       ENDIF
       dstfc_index->ind_cnt = (dstfc_index->ind_cnt+ 1)
       IF (mod(dstfc_index->ind_cnt,100)=1)
        stat = alterlist(dstfc_index->qual,(dstfc_index->ind_cnt+ 99))
       ENDIF
       dstfc_index->qual[dstfc_index->ind_cnt].owner = dtc.owner, dstfc_index->qual[dstfc_index->
       ind_cnt].index_name = dic.index_name, dstfc_index->qual[dstfc_index->ind_cnt].table_name = dic
       .table_name
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(dstfc_index->qual,dstfc_index->ind_cnt)
    WITH nocounter, noheading, orahint("ALL_ROWS"),
     orahintcbo("ALL_ROWS")
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 3))
    CALL echorecord(dstfc_index)
   ENDIF
   SET dm_err->eproc = "Obtain column list for unique indexes with highest distinct value"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SELECT INTO "nl:"
    x = concat(dic.table_owner,".",dic.table_name)
    FROM dba_ind_columns dic,
     dba_tab_columns dtc
    WHERE expand(dstfc_num,1,dvdr_user_list->cnt,dic.table_owner,dvdr_user_list->qual[dstfc_num].user
     )
     AND dic.table_owner=dtc.owner
     AND dic.table_name=dtc.table_name
     AND dtc.table_name=patstring(dmvd->table_name)
     AND dic.table_name=patstring(dmvd->table_name)
     AND dic.column_name=dtc.column_name
    ORDER BY x, dic.index_name, dic.column_position
    DETAIL
     dstfc_pos = locateval(dstfc_cnt,1,dstfc_index->ind_cnt,dic.table_owner,dstfc_index->qual[
      dstfc_cnt].owner,
      dic.table_name,dstfc_index->qual[dstfc_cnt].table_name,dic.index_name,dstfc_index->qual[
      dstfc_cnt].index_name)
     IF (dstfc_pos > 0)
      dstfc_pos2 = locateval(dstfc_cnt,1,dmvd->tbl_cnt,dic.table_owner,dmvd->tbls[dstfc_cnt].owner,
       dic.table_name,dmvd->tbls[dstfc_cnt].table_name)
      IF (dstfc_pos2 > 0)
       IF ((dmvd->tbls[dstfc_pos2].scui_ind IN (2, 3)))
        IF ((dmvd->tbls[dstfc_pos2].col_list=""))
         dmvd->tbls[dstfc_pos2].col_list = dic.column_name, dmvd->tbls[dstfc_pos2].data_type_list =
         dtc.data_type
        ELSE
         dmvd->tbls[dstfc_pos2].col_list = concat(dmvd->tbls[dstfc_pos2].col_list,",",dic.column_name
          ), dmvd->tbls[dstfc_pos2].data_type_list = concat(dmvd->tbls[dstfc_pos2].data_type_list,",",
          dtc.data_type)
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter, noheading
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Generating column lists for all tables"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_tab_columns dtc,
     (dummyt d  WITH seq = value(dmvd->tbl_cnt))
    PLAN (d
     WHERE d.seq > 0)
     JOIN (dtc
     WHERE (dtc.owner=dmvd->tbls[d.seq].owner)
      AND (dtc.table_name=dmvd->tbls[d.seq].table_name)
      AND  NOT (dtc.data_type IN ("LONG*", "*LOB*", "RAW")))
    ORDER BY dtc.owner, dtc.table_name
    HEAD dtc.owner
     dstfc_full_col_list = ""
    HEAD dtc.table_name
     dstfc_full_col_list = "", dstfc_data_type_list = ""
    DETAIL
     IF ((dmvd->tbls[d.seq].scui_ind=0)
      AND (dmvd->tbls[d.seq].keyid_col_name=""))
      dmvd->tbls[d.seq].keyid_col_name = dtc.column_name
     ENDIF
     IF (dstfc_full_col_list="")
      dstfc_full_col_list = dtc.column_name, dstfc_data_type_list = dtc.data_type
     ELSE
      dstfc_full_col_list = concat(dstfc_full_col_list,",",dtc.column_name), dstfc_data_type_list =
      concat(dstfc_data_type_list,",",dtc.data_type)
     ENDIF
     IF (dtc.column_name="UPDT_DT_TM"
      AND dtc.data_type="DATE")
      dmvd->tbls[d.seq].date_col_exists = 1, dmvd->tbls[d.seq].date_col_name = "UPDT_DT_TM"
     ENDIF
     IF (dtc.data_type="DATE")
      dstfc_col_list->col_cnt = (dstfc_col_list->col_cnt+ 1), stat = alterlist(dstfc_col_list->qual,
       dstfc_col_list->col_cnt), dstfc_col_list->qual[dstfc_col_list->col_cnt].col_name = dtc
      .column_name,
      dstfc_col_list->qual[dstfc_col_list->col_cnt].table_name = dtc.table_name, dstfc_col_list->
      qual[dstfc_col_list->col_cnt].owner_name = dtc.owner
     ENDIF
    FOOT  dtc.table_name
     IF ((dmvd->tbls[d.seq].scui_ind=0))
      dmvd->tbls[d.seq].col_list = dstfc_full_col_list, dmvd->tbls[d.seq].data_type_list =
      dstfc_data_type_list
     ENDIF
     dmvd->tbls[d.seq].full_col_list = dstfc_full_col_list,
     CALL dvdr_parse_list("COLUMN",",",dmvd->tbls[d.seq].col_list,d.seq),
     CALL dvdr_parse_list("DATATYPE",",",dmvd->tbls[d.seq].data_type_list,d.seq)
    FOOT  dtc.owner
     IF ((dmvd->tbls[d.seq].scui_ind=0))
      dmvd->tbls[d.seq].col_list = dstfc_full_col_list, dmvd->tbls[d.seq].data_type_list =
      dstfc_data_type_list
     ENDIF
     dmvd->tbls[d.seq].full_col_list = dstfc_full_col_list,
     CALL dvdr_parse_list("COLUMN",",",dmvd->tbls[d.seq].col_list,d.seq),
     CALL dvdr_parse_list("DATATYPE",",",dmvd->tbls[d.seq].data_type_list,d.seq)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 3))
    CALL echorecord(dmvd)
   ENDIF
   SET dm2_install_schema->u_name = "V500"
   SET dm2_install_schema->dbase_name = dm2_install_schema->target_dbase_name
   SET dm2_install_schema->connect_str = dm2_install_schema->v500_connect_str
   SET dm2_install_schema->p_word = dm2_install_schema->v500_p_word
   EXECUTE dm2_connect_to_dbase "CO"
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF (dmr_load_di_filter(null)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Obtain check column overrides"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info d,
     (dummyt dt  WITH seq = value(dmvd->tbl_cnt))
    PLAN (dt)
     JOIN (d
     WHERE d.info_domain IN ("DM2_MIG_CHKCOL_OVERRIDE", "DM2_MIG_NOUSE_CHKCOL",
     "DM2_MIG_COMPARE_WHERE")
      AND d.info_name=concat(dmvd->tbls[dt.seq].owner,".",dmvd->tbls[dt.seq].table_name))
    DETAIL
     IF (d.info_domain="DM2_MIG_COMPARE_WHERE")
      dmvd->tbls[dt.seq].compare_where = d.info_char
     ELSE
      IF (((d.info_domain="DM2_MIG_NOUSE_CHKCOL") OR (locateval(dstfc_ndx,1,dstfc_col_list->col_cnt,
       dmvd->tbls[dt.seq].owner,dstfc_col_list->qual[dstfc_ndx].owner_name,
       dmvd->tbls[dt.seq].table_name,dstfc_col_list->qual[dstfc_ndx].table_name,d.info_char,
       dstfc_col_list->qual[dstfc_ndx].col_name)=0)) )
       CALL echo(concat(dmvd->tbls[dt.seq].owner,".",dmvd->tbls[dt.seq].table_name,".",trim(d
         .info_char),
        " will not be used.")), dmvd->tbls[dt.seq].date_col_exists = 0, dmvd->tbls[dt.seq].
       date_col_name = "DM2NOTSET"
      ELSE
       CALL echo(concat(dmvd->tbls[dt.seq].owner,".",dmvd->tbls[dt.seq].table_name,".",trim(d
         .info_char),
        " will be used.")), dmvd->tbls[dt.seq].date_col_exists = 1, dmvd->tbls[dt.seq].date_col_name
        = d.info_char
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF (validate(dm2_mig_bypass_di_cmp_wh,- (1))=1)
    SET dm_err->eproc = "Bypassing dynamic migration dm_info compare where logic."
    CALL disp_msg(" ",dm_err->logfile,0)
   ELSE
    SET dstfc_pos = locateval(dstfc_pos,1,dmvd->tbl_cnt,"V500",dmvd->tbls[dstfc_pos].owner,
     "DM_INFO",dmvd->tbls[dstfc_pos].table_name)
    IF (dstfc_pos > 0)
     SET dmvd->tbls[dstfc_pos].compare_where = concat(
      "where INFO_DOMAIN not in (SELECT a.info_domain ",
      "FROM (select info_name from V500.DM_INFO@ref_data_link where info_domain = 'DM2_MIG_DI_FILTER') p join ",
      "dm_info@ref_data_link a on a.info_domain like p.info_name)")
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 5))
    CALL echorecord(dmvd)
   ENDIF
   FOR (dstfc_cnt = 1 TO dmvd->tbl_cnt)
    IF ((dmvd->tbls[dstfc_cnt].tgt_exists_ind != 1))
     SET dmvd->tbls[dstfc_cnt].excl_flag = 50
     SET dmvd->tbls[dstfc_cnt].excl_reason = "Table exists in source but not in target"
    ENDIF
    IF ((dmvd->tbls[dstfc_cnt].excl_flag IN (0, 50)))
     CALL echo(concat("View ",build(dstfc_cnt)," of ",build(dmvd->tbl_cnt)))
     EXECUTE dm2_verify_data_genviews dstfc_cnt
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ENDIF
   ENDFOR
   SET dm2_install_schema->u_name = "V500"
   SET dm2_install_schema->dbase_name = dm2_install_schema->src_dbase_name
   SET dm2_install_schema->connect_str = dm2_install_schema->src_v500_connect_str
   SET dm2_install_schema->p_word = dm2_install_schema->src_v500_p_word
   EXECUTE dm2_connect_to_dbase "CO"
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Retrieving max and min uids for all tables with eligible index"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   FOR (dstfc_cnt = 1 TO dmvd->tbl_cnt)
    CALL echo(concat("Min/Max ",build(dstfc_cnt)," of ",build(dmvd->tbl_cnt)))
    IF ((dmvd->tbls[dstfc_cnt].scui_ind IN (1, 2))
     AND (dmvd->tbls[dstfc_cnt].excl_flag=0))
     SET dstfc_full_tname = trim(cnvtupper(concat(dmvd->tbls[dstfc_cnt].owner,".",dmvd->tbls[
        dstfc_cnt].table_name)))
     SET dm_err->eproc = concat("Retrieving MIN and MAX  for ",dstfc_full_tname)
     CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
     SELECT INTO "nl:"
      val_max = t1.max_id
      FROM (
       (
       (SELECT
        max_id = parser(concat("max(t.",dmvd->tbls[dstfc_cnt].keyid_col_name,")"))
        FROM (value(dstfc_full_tname) t)
        WITH sqltype("F8")))
       t1)
      DETAIL
       IF (val_max < 0)
        dmvd->tbls[dstfc_cnt].max_src_keyid = 0
       ELSE
        dmvd->tbls[dstfc_cnt].max_src_keyid = val_max
       ENDIF
      WITH nocounter, orahint("ALL_ROWS"), orahintcbo("ALL_ROWS")
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      SET dm_err->err_ind = 1
      RETURN(0)
     ENDIF
     SELECT INTO "nl:"
      val_min = t1.min_id
      FROM (
       (
       (SELECT
        min_id = parser(concat("min(t.",dmvd->tbls[dstfc_cnt].keyid_col_name,")"))
        FROM (value(dstfc_full_tname) t)
        WHERE parser(concat("t.",dmvd->tbls[dstfc_cnt].keyid_col_name," > 0"))
        WITH sqltype("F8")))
       t1)
      DETAIL
       dmvd->tbls[dstfc_cnt].range_start_keyid = val_min
      WITH nocounter, orahint("ALL_ROWS"), orahintcbo("ALL_ROWS")
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      SET dm_err->err_ind = 1
      RETURN(0)
     ENDIF
    ENDIF
   ENDFOR
   SET dm2_install_schema->u_name = "V500"
   SET dm2_install_schema->dbase_name = dm2_install_schema->target_dbase_name
   SET dm2_install_schema->connect_str = dm2_install_schema->v500_connect_str
   SET dm2_install_schema->p_word = dm2_install_schema->v500_p_word
   EXECUTE dm2_connect_to_dbase "CO"
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Retrieving src mode date times for all tables"
   IF (dvdr_get_tblmod("SETUP")=0)
    RETURN(0)
   ENDIF
   FOR (dstfc_cnt = 1 TO dmvd->tbl_cnt)
     CASE (dmvd->tbls[dstfc_cnt].scui_ind)
      OF 1:
       SET dmvd->tbls[dstfc_cnt].rows_to_compare = dmvd->rows_to_compare
      OF 2:
       IF ((((dmvd->tbls[dstfc_cnt].num_rows=- (1))) OR ((dmvd->tbls[dstfc_cnt].num_distinct=- (1))
       )) )
        SET dmvd->tbls[dstfc_cnt].rows_to_compare = dmvd->uow_threshold
       ELSEIF (((dmvd->tbls[dstfc_cnt].num_rows/ dmvd->tbls[dstfc_cnt].num_distinct) > dmvd->
       rows_to_compare))
        SET dmvd->tbls[dstfc_cnt].status = dvdr_uow_status
       ELSEIF ((dmvd->tbls[dstfc_cnt].num_rows <= dmvd->rows_to_compare))
        SET dmvd->tbls[dstfc_cnt].rows_to_compare = dmvd->rows_to_compare
       ELSE
        SET dmvd->tbls[dstfc_cnt].rows_to_compare = dm2ceil((dmvd->rows_to_compare/ (dmvd->tbls[
         dstfc_cnt].num_rows/ dmvd->tbls[dstfc_cnt].num_distinct)))
       ENDIF
      ELSE
       SET dmvd->tbls[dstfc_cnt].rows_to_compare = dmvd->rows_to_compare_all
     ENDCASE
   ENDFOR
   IF (dvdr_get_old_lag(dstfc_lag_time)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 3))
    CALL echorecord(dmvd)
   ENDIF
   SET dm_err->eproc = "Updating rows in master table"
   UPDATE  FROM dm_vdata_master dvm,
     (dummyt d  WITH seq = value(dmvd->tbl_cnt))
    SET dvm.rows_to_compare = dmvd->tbls[d.seq].rows_to_compare, dvm.row_dt_tm_col_name = dmvd->tbls[
     d.seq].date_col_name, dvm.compare_status =
     IF ((dmvd->tbls[d.seq].status=dvdr_uow_status)) dmvd->tbls[d.seq].status
     ELSE evaluate(dmvd->tbls[d.seq].excl_flag,0,dvdr_ready,dvdr_exclude)
     ENDIF
    PLAN (d
     WHERE d.seq > 0
      AND (dmvd->tbls[d.seq].master_id != 0))
     JOIN (dvm
     WHERE (dvm.owner_name=dmvd->tbls[d.seq].owner)
      AND (dvm.table_name=dmvd->tbls[d.seq].table_name))
    WITH nocounter, maxcommit = 10000
   ;end update
   IF (check_error(dm_err->eproc) != 0)
    ROLLBACK
    SET dm_err->err_ind = 1
    RETURN(0)
   ELSE
    COMMIT
   ENDIF
   SET dm_err->eproc = "Inserting rows in master table"
   INSERT  FROM dm_vdata_master dvm,
     (dummyt d  WITH seq = value(dmvd->tbl_cnt))
    SET dvm.dm_vdata_master_id = seq(dm_clinical_seq,nextval), dvm.owner_name = dmvd->tbls[d.seq].
     owner, dvm.table_name = dmvd->tbls[d.seq].table_name,
     dvm.rows_to_compare = dmvd->tbls[d.seq].rows_to_compare, dvm.compare_status =
     IF ((dmvd->tbls[d.seq].status=dvdr_uow_status)) dmvd->tbls[d.seq].status
     ELSE evaluate(dmvd->tbls[d.seq].excl_flag,0,dvdr_ready,dvdr_exclude)
     ENDIF
     , dvm.column_list = dmvd->tbls[d.seq].col_list,
     dvm.data_type_list = dmvd->tbls[d.seq].data_type_list, dvm.keyid_column_name = dmvd->tbls[d.seq]
     .keyid_col_name, dvm.range_start_keyid =
     IF ((dmvd->tbls[d.seq].scui_ind IN (1, 2))) dmvd->tbls[d.seq].range_start_keyid
     ELSE 0
     ENDIF
     ,
     dvm.max_src_keyid = dmvd->tbls[d.seq].max_src_keyid, dvm.range_beg_keyid = 0, dvm
     .range_end_keyid = 0,
     dvm.object_id_src = dmvd->tbls[d.seq].src_object_id, dvm.last_src_mod_dt_tm = cnvtdatetime(
      greatest(dmvd->tbls[d.seq].last_analyzed,dmvd->tbls[d.seq].cur_src_mod_dt_tm)), dvm
     .last_compare_dt_tm = cnvtdatetime("01-JAN-1900"),
     dvm.mismatch_row_dt_tm = cnvtdatetime("01-JAN-1900"), dvm.updt_applctx = dmvd->tbls[d.seq].
     scui_ind, dvm.row_dt_tm_col_name = dmvd->tbls[d.seq].date_col_name,
     dvm.mm_pull_key_from_src_ind = 1, dvm.lag_dt_tm = cnvtdatetime(dstfc_lag_time)
    PLAN (d
     WHERE d.seq > 0
      AND (dmvd->tbls[d.seq].master_id=0))
     JOIN (dvm)
    WITH nocounter, maxcommit = 10000
   ;end insert
   IF (check_error(dm_err->eproc) != 0)
    ROLLBACK
    SET dm_err->err_ind = 1
    RETURN(0)
   ELSE
    COMMIT
   ENDIF
   SELECT INTO "nl:"
    FROM dm_vdata_master dvm,
     (dummyt d  WITH seq = value(dmvd->tbl_cnt))
    PLAN (d
     WHERE d.seq > 0)
     JOIN (dvm
     WHERE (dmvd->tbls[d.seq].owner=dvm.owner_name)
      AND (dmvd->tbls[d.seq].table_name=dvm.table_name))
    DETAIL
     dmvd->tbls[d.seq].master_id = dvm.dm_vdata_master_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_get_tblmod(dgt_mode)
   DECLARE dgt_ndx = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Retrieve table mod date/time for source tables."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT
    IF (dgt_mode="COMPARE")
     FROM (value(concat("DM_DBA_TABLES_ACTUAL_STATS@",dmvd->db_link)) d),
      (value(concat("ALL_TAB_MODIFICATIONS@",dmvd->db_link)) m)
     WHERE (d.owner=dmvd->tbls[1].owner)
      AND (d.table_name=dmvd->tbls[1].table_name)
      AND outerjoin(concat(d.owner,".",d.table_name))=concat(m.table_owner,".",m.table_name)
    ELSE
     FROM (value(concat("DM_DBA_TABLES_ACTUAL_STATS@",dmvd->db_link)) d),
      (value(concat("ALL_TAB_MODIFICATIONS@",dmvd->db_link)) m)
     WHERE outerjoin(concat(d.owner,".",d.table_name))=concat(m.table_owner,".",m.table_name)
    ENDIF
    INTO "nl:"
    mon_time_null = nullind(m.timestamp), anyl_time_null = nullind(d.last_analyzed), nr_null =
    nullind(d.num_rows)
    DETAIL
     IF (locateval(dgt_ndx,1,dmvd->tbl_cnt,d.owner,dmvd->tbls[dgt_ndx].owner,
      d.table_name,dmvd->tbls[dgt_ndx].table_name) > 0)
      dmvd->tbls[dgt_ndx].cur_src_mod_dt_tm = evaluate(mon_time_null,1,cnvtdatetime("01-JAN-1900"),m
       .timestamp), dmvd->tbls[dgt_ndx].last_analyzed = evaluate(anyl_time_null,1,cnvtdatetime(
        "01-JAN-1900"),d.last_analyzed), dmvd->tbls[dgt_ndx].monitoring = evaluate(d.monitoring,"YES",
       1,0),
      dmvd->tbls[dgt_ndx].num_rows = evaluate(nr_null,1,- (1),d.num_rows)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_write_exclusion_rows(null)
   SET dm_err->eproc = "Writing exclusion rows for tables"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_vdata_exclude_dtl dved,
     (dummyt d  WITH seq = value(dmvd->tbl_cnt))
    PLAN (d
     WHERE d.seq > 0)
     JOIN (dved
     WHERE (dved.dm_vdata_master_id=dmvd->tbls[d.seq].master_id)
      AND (dved.exclude_reason_flag=dmvd->tbls[d.seq].excl_flag))
    DETAIL
     dmvd->tbls[d.seq].exclude_ind = 1
    WITH nocounter
   ;end select
   INSERT  FROM dm_vdata_exclude_dtl dved,
     (dummyt d  WITH seq = value(dmvd->tbl_cnt))
    SET dved.dm_vdata_exclude_dtl_id = seq(dm_clinical_seq,nextval), dved.dm_vdata_master_id = dmvd->
     tbls[d.seq].master_id, dved.exclude_reason_flag = dmvd->tbls[d.seq].excl_flag,
     dved.exclude_reason_txt = dmvd->tbls[d.seq].excl_reason
    PLAN (d
     WHERE (dmvd->tbls[d.seq].excl_flag != 0)
      AND (dmvd->tbls[d.seq].exclude_ind != 1))
     JOIN (dved)
    WITH nocounter, maxcommit = 10000
   ;end insert
   IF (check_error(dm_err->eproc) != 0)
    ROLLBACK
    SET dm_err->err_ind = 1
    RETURN(0)
   ELSE
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_write_dminfo_rows(null)
   SET dm_err->eproc = "Writing dm_info rows for current data verification parameters"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_VDATA_INFO"
     AND di.info_name="DM2_VDATA_DBLINK"
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_VDATA_INFO", di.info_name = "DM2_VDATA_DBLINK", di.info_char =
      cnvtupper(dmvd->db_link)
     WITH nocounter
    ;end insert
   ELSE
    UPDATE  FROM dm_info di
     SET di.info_char = cnvtupper(dmvd->db_link)
     WHERE di.info_domain="DM2_VDATA_INFO"
      AND di.info_name="DM2_VDATA_DBLINK"
     WITH nocounter
    ;end update
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_VDATA_INFO"
     AND di.info_name="DM2_VDATA_SRCDB"
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_VDATA_INFO", di.info_name = "DM2_VDATA_SRCDB", di.info_char =
      cnvtupper(dm2_install_schema->src_dbase_name)
     WITH nocounter
    ;end insert
   ELSE
    UPDATE  FROM dm_info di
     SET di.info_char = cnvtupper(dm2_install_schema->src_dbase_name)
     WHERE di.info_domain="DM2_VDATA_INFO"
      AND di.info_name="DM2_VDATA_SRCDB"
     WITH nocounter
    ;end update
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_VDATA_INFO"
     AND di.info_name="DM2_VDATA_TGTDB"
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_VDATA_INFO", di.info_name = "DM2_VDATA_TGTDB", di.info_char =
      cnvtupper(dm2_install_schema->target_dbase_name)
     WITH nocounter
    ;end insert
   ELSE
    UPDATE  FROM dm_info di
     SET di.info_char = cnvtupper(dm2_install_schema->target_dbase_name)
     WHERE di.info_domain="DM2_VDATA_INFO"
      AND di.info_name="DM2_VDATA_TGTDB"
     WITH nocounter
    ;end update
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_VDATA_INFO"
     AND di.info_name="DM2_VDATA_OWNER"
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_VDATA_INFO", di.info_name = "DM2_VDATA_OWNER", di.info_char =
      cnvtupper(dmvd->owner)
     WITH nocounter
    ;end insert
   ELSE
    UPDATE  FROM dm_info di
     SET di.info_char = cnvtupper(dmvd->owner)
     WHERE di.info_domain="DM2_VDATA_INFO"
      AND di.info_name="DM2_VDATA_OWNER"
     WITH nocounter
    ;end update
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_VDATA_INFO"
     AND di.info_name="DM2_VDATA_TABLE_NAME"
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_VDATA_INFO", di.info_name = "DM2_VDATA_TABLE_NAME", di.info_char =
      cnvtupper(dmvd->table_name)
     WITH nocounter
    ;end insert
   ELSE
    UPDATE  FROM dm_info di
     SET di.info_char = cnvtupper(dmvd->table_name)
     WHERE di.info_domain="DM2_VDATA_INFO"
      AND di.info_name="DM2_VDATA_TABLE_NAME"
     WITH nocounter
    ;end update
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_VDATA_INFO"
     AND di.info_name="DM2_VDATA_NUMROWS"
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_VDATA_INFO", di.info_name = "DM2_VDATA_NUMROWS", di.info_number = dmvd
      ->rows_to_compare
     WITH nocounter
    ;end insert
   ELSE
    UPDATE  FROM dm_info di
     SET di.info_number = dmvd->rows_to_compare
     WHERE di.info_domain="DM2_VDATA_INFO"
      AND di.info_name="DM2_VDATA_NUMROWS"
     WITH nocounter
    ;end update
   ENDIF
   IF (check_error(dm_err->eproc) != 0)
    ROLLBACK
    SET dm_err->err_ind = 1
    RETURN(0)
   ELSE
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_get_verify_data_rpt_info(dgvdri_return,dgvdri_quit)
   DECLARE dgvdri_verify_data_setup_rpt = i2 WITH protect, noconstant(1)
   DECLARE dgvdri_owner = vc WITH protect, noconstant(currdbuser)
   DECLARE dgvdri_table_name = vc WITH protect, noconstant(" ")
   SET dm_err->eproc = "Collecting data verification report information"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SET width = 132
   IF ((dm_err->debug_flag != 511))
    SET message = window
   ENDIF
   IF (dgvdri_return=1)
    CALL clear(1,1)
    CALL box(1,1,24,131)
    CALL text(2,2,"Data Verification Process (Mismatch Detail Report)")
    CALL text(5,2,"(C)hoose Another Table, (Q)uit: ")
    CALL accept(5,34,"A;CU","C"
     WHERE curaccept IN ("C", "Q"))
    CASE (curaccept)
     OF "C":
      SET dgvdri_owner = dvdr_rpt_dtl_info->owner
      SET dgvdri_table_name = dvdr_rpt_dtl_info->table_name
     OF "Q":
      SET dgvdri_quit = 1
      RETURN(1)
    ENDCASE
   ENDIF
   WHILE (dgvdri_verify_data_setup_rpt=1)
     CALL clear(1,1)
     CALL box(1,1,24,131)
     CALL text(2,2,"Data Verification Process (Mismatch Detail Report)")
     CALL text(5,2,"Owner: ")
     CALL text(7,2,"Table Name: ")
     CALL text(5,80,"List of Valid Owners:")
     SELECT INTO "nl:"
      FROM dm_info di
      WHERE di.info_domain="DM2_VDATA_INFO"
       AND di.info_name="DM2_VDATA_USERLIST"
      DETAIL
       dvdr_rpt_dtl_info->num_owners = di.info_number, dvdr_rpt_dtl_info->owners_list = di.info_char
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc))
      SET dm_err->err_ind = 1
      RETURN(0)
     ENDIF
     CALL text(6,80,dvdr_rpt_dtl_info->owners_list)
     CALL text(9,2,"(C)ontinue, (M)odify, (Q)uit: ")
     CALL accept(5,30,"P(30);cu",dgvdri_owner
      WHERE  NOT (trim(curaccept)=""))
     SET dgvdri_owner = build(trim(curaccept))
     CALL accept(7,30,"P(30);cu",dgvdri_table_name
      WHERE  NOT (trim(curaccept)=""))
     SET dgvdri_table_name = build(trim(curaccept))
     CALL accept(9,33,"A;CU","C"
      WHERE curaccept IN ("M", "C", "Q"))
     CASE (curaccept)
      OF "C":
       SET dgvdri_verify_data_setup_rpt = 0
       SET dvdr_rpt_dtl_info->owner = dgvdri_owner
       SET dvdr_rpt_dtl_info->table_name = dgvdri_table_name
      OF "Q":
       SET dgvdri_quit = 1
       RETURN(1)
     ENDCASE
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_get_vdata_rpt_env_info(null)
   SET dm_err->eproc = "Getting environment data for source and target"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_VDATA_INFO"
     AND di.info_name IN ("DM2_VDATA_DBLINK", "DM2_VDATA_SRCDB", "DM2_VDATA_TGTDB")
    DETAIL
     IF (di.info_name="DM2_VDATA_DBLINK")
      dvdr_rpt_dtl_info->db_link = di.info_char
     ENDIF
     IF (di.info_name="DM2_VDATA_SRCDB")
      dvdr_rpt_dtl_info->src_db_name = di.info_char
     ENDIF
     IF (di.info_name="DM2_VDATA_TGTDB")
      dvdr_rpt_dtl_info->tgt_db_name = di.info_char
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_load_rpt_record(null)
   DECLARE dlrr_tot_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlrr_cmp_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlrr_complete_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlrr_mtch_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlrr_excl_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlrr_get_cur_max = i2 WITH protect, noconstant(1)
   DECLARE dlrr_unabletocompare_cnt = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Loading verification data into the reporting record structure"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SET dm_err->eproc = "Getting Summary Info"
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_VDATA_INFO"
     AND di.info_name="DM2_VDATA_USERLIST"
    DETAIL
     dvdr_rpt_dtl_info->num_owners = di.info_number, dvdr_rpt_dtl_info->owners_list = di.info_char
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Getting Table Verification Information"
   SELECT INTO "nl:"
    nullind_dved_dm_vdata_master_id = nullind(dved.dm_vdata_master_id)
    FROM dm_vdata_master dvm,
     dm_vdata_exclude_dtl dved
    PLAN (dvm)
     JOIN (dved
     WHERE outerjoin(dvm.dm_vdata_master_id)=dved.dm_vdata_master_id)
    ORDER BY dvm.mismatch_event_cnt DESC, dvm.last_match_cnt DESC, dvm.owner_name,
     dvm.table_name
    HEAD REPORT
     dvdr_rpt_dtl_info->tbl_cnt = 0, stat = alterlist(dvdr_rpt_dtl_info->tbls,0)
    DETAIL
     IF (dvm.compare_status IN (dvdr_match, dvdr_mismatch))
      IF ((dvdr_rpt_dtl_info->comp_dt_max < dvm.last_compare_dt_tm))
       dvdr_rpt_dtl_info->comp_dt_max = dvm.last_compare_dt_tm
      ENDIF
      IF ((((dvdr_rpt_dtl_info->comp_dt_min > dvm.last_compare_dt_tm)) OR ((dvdr_rpt_dtl_info->
      comp_dt_min=0))) )
       dvdr_rpt_dtl_info->comp_dt_min = dvm.last_compare_dt_tm
      ENDIF
     ENDIF
     dlrr_tot_cnt = (dlrr_tot_cnt+ 1)
     IF (dvm.compare_status=dvdr_complete)
      dlrr_complete_cnt = (dlrr_complete_cnt+ 1)
     ELSEIF (dvm.compare_status=dvdr_match
      AND (dvdr_rpt_dtl_info->final_row_dt_tm > 0.0))
      dvdr_rpt_dtl_info->yet_to_be_compared = (dvdr_rpt_dtl_info->yet_to_be_compared+ 1)
     ELSEIF (dvm.compare_status=dvdr_match)
      dlrr_mtch_cnt = (dlrr_mtch_cnt+ 1)
     ELSEIF ((dvdr_rpt_dtl_info->final_row_dt_tm > 0.0)
      AND dvm.compare_status=dvdr_mismatch
      AND (cnvtdatetime(dvm.last_compare_dt_tm) > dvdr_rpt_dtl_info->final_row_dt_tm))
      dvdr_rpt_dtl_info->tbls_mm_down_cnt = (dvdr_rpt_dtl_info->tbls_mm_down_cnt+ 1)
     ELSEIF ((dvdr_rpt_dtl_info->final_row_dt_tm > 0.0)
      AND dvm.compare_status=dvdr_mismatch
      AND (cnvtdatetime(dvm.last_compare_dt_tm) < dvdr_rpt_dtl_info->final_row_dt_tm))
      dvdr_rpt_dtl_info->yet_to_be_compared = (dvdr_rpt_dtl_info->yet_to_be_compared+ 1)
     ELSEIF (dvm.compare_status=dvdr_mismatch)
      dvdr_rpt_dtl_info->tbls_mm_cnt = (dvdr_rpt_dtl_info->tbls_mm_cnt+ 1)
     ELSEIF (((dvm.compare_status IN (dvdr_exclude, dvdr_error)) OR (nullind_dved_dm_vdata_master_id=
     0)) )
      dlrr_excl_cnt = (dlrr_excl_cnt+ 1)
     ELSEIF (dvm.compare_status IN (dvdr_uow_status, dvdr_nocomp_size))
      dlrr_unabletocompare_cnt = (dlrr_unabletocompare_cnt+ 1)
     ELSEIF (dvm.compare_status=dvdr_ready
      AND nullind_dved_dm_vdata_master_id=1)
      dvdr_rpt_dtl_info->yet_to_be_compared = (dvdr_rpt_dtl_info->yet_to_be_compared+ 1)
     ENDIF
     dvdr_rpt_dtl_info->tbl_cnt = (dvdr_rpt_dtl_info->tbl_cnt+ 1), stat = alterlist(dvdr_rpt_dtl_info
      ->tbls,dvdr_rpt_dtl_info->tbl_cnt), dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].owner
      = dvm.owner_name,
     dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].table_name = dvm.table_name,
     dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].master_id = dvm.dm_vdata_master_id,
     dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].status = dvm.compare_status,
     dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].keyid_col_name = dvm.keyid_column_name,
     dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].src_object_id = dvm.object_id_src,
     dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].mismatch_event_cnt = dvm.mismatch_event_cnt,
     dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].last_rows_mismatched = dvm.last_match_cnt,
     dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].last_compare_dt_tm = dvm.last_compare_dt_tm
     IF (dvm.updt_applctx IN (3, 0))
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].orig_start_key = - (1), dvdr_rpt_dtl_info->
      tbls[dvdr_rpt_dtl_info->tbl_cnt].last_comp_keyid_min = - (1), dvdr_rpt_dtl_info->tbls[
      dvdr_rpt_dtl_info->tbl_cnt].last_comp_keyid_max = - (1),
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].last_mismatch_keyid_min = - (1),
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].last_rows_compared = - (1),
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].total_rows_compared = - (1),
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].key_range_remaining = - (1),
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].max_src_keyid = - (1), dvdr_rpt_dtl_info->
      tbls[dvdr_rpt_dtl_info->tbl_cnt].last_src_mod_dt_tm = dvm.last_src_mod_dt_tm
     ELSE
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].max_src_keyid = dvm.max_src_keyid,
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].orig_start_key = dvm.range_start_keyid,
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].last_comp_keyid_min = dvm.range_beg_keyid,
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].last_comp_keyid_max = dvm.range_end_keyid,
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].last_mismatch_keyid_min = dvm
      .mismatch_beg_keyid, dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].last_src_mod_dt_tm =
      - (1),
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].key_range_remaining = (dvm.max_src_keyid -
      dvm.range_end_keyid)
      IF (dvm.updt_applctx=2)
       dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].last_rows_compared = - (1),
       dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].total_rows_compared = - (1)
      ELSE
       dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].last_rows_compared = dvm.last_compare_cnt,
       dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].total_rows_compared = dvm
       .ttl_rows_compared
      ENDIF
     ENDIF
     IF (((dvm.compare_status=dvdr_exclude) OR (nullind_dved_dm_vdata_master_id=0)) )
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].excl_reason = dved.exclude_reason_txt
     ELSEIF (dvm.compare_status=dvdr_error)
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].excl_reason =
      "An error occured during comparison"
     ELSEIF (dvm.compare_status=dvdr_comparing)
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].excl_reason =
      "Table currently being compared", dvdr_rpt_dtl_info->comparing_cnt = (dvdr_rpt_dtl_info->
      comparing_cnt+ 1)
     ELSEIF (dvm.compare_status=dvdr_nocomp_size)
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].excl_reason =
      "Table size is too large (or unknown) to compare with current unique index options"
     ELSEIF (dvm.compare_status=dvdr_uow_status)
      dvdr_rpt_dtl_info->tbls[dvdr_rpt_dtl_info->tbl_cnt].excl_reason =
      "Distinct values for leading column of composite index used is too low"
     ENDIF
    FOOT REPORT
     dlrr_cmp_cnt = (dlrr_tot_cnt - dlrr_excl_cnt), dvdr_rpt_dtl_info->yet_to_be_compared_pct = ((
     cnvtreal(dvdr_rpt_dtl_info->yet_to_be_compared)/ cnvtreal(dlrr_cmp_cnt)) * 100.0),
     dvdr_rpt_dtl_info->mtch_pct = ((cnvtreal(dlrr_mtch_cnt)/ cnvtreal(dlrr_cmp_cnt)) * 100.0),
     dvdr_rpt_dtl_info->mismatch_pct = ((cnvtreal(dvdr_rpt_dtl_info->tbls_mm_cnt)/ cnvtreal(
      dlrr_cmp_cnt)) * 100.0)
     IF ((dvdr_rpt_dtl_info->final_row_dt_tm > 0.0))
      dvdr_rpt_dtl_info->downtime_mm_pct = ((cnvtreal(dvdr_rpt_dtl_info->tbls_mm_down_cnt)/ cnvtreal(
       dlrr_cmp_cnt)) * 100.0), dvdr_rpt_dtl_info->complete_pct = ((cnvtreal(dlrr_complete_cnt)/
      cnvtreal(dlrr_cmp_cnt)) * 100.0)
     ENDIF
    WITH nocounter
   ;end select
   SET dvdr_rpt_dtl_info->tbls_compared = dlrr_cmp_cnt
   SET dvdr_rpt_dtl_info->tbls_matched = dlrr_mtch_cnt
   SET dvdr_rpt_dtl_info->tbls_complete = dlrr_complete_cnt
   SET dvdr_rpt_dtl_info->tbls_excluded = dlrr_excl_cnt
   IF (check_error(dm_err->eproc))
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_VDATA_INFO"
     AND d.info_name="DM2_VDATA_GET_CUR_MAX"
    DETAIL
     dlrr_get_cur_max = d.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF (dlrr_get_cur_max=1)
    SET dm_err->eproc = "Retrieving Current Max Src Keyid for all tables"
    IF (dvdr_get_cur_max_src_keyid(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_get_cur_max_src_keyid(null)
   DECLARE dgcmsk_full_tname = vc WITH protect, noconstant("")
   DECLARE dgcmsk_ndx = i4 WITH protect, noconstant(0)
   DECLARE dgcmsk_no_src = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Loading Current Max Keyid values into the reporting record structure"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SET dm_err->eproc = "Retrieve table mod date/time for source tables."
   SELECT INTO "nl:"
    nullind_m_timestamp = nullind(m.timestamp), nullind_d_last_analyzed = nullind(d.last_analyzed)
    FROM (value(concat("DBA_TABLES@",dvdr_rpt_dtl_info->db_link)) d),
     (value(concat("ALL_TAB_MODIFICATIONS@",dvdr_rpt_dtl_info->db_link)) m),
     dm_vdata_master v
    WHERE v.owner_name=d.owner
     AND v.table_name=d.table_name
     AND outerjoin(concat(d.owner,".",d.table_name))=concat(m.table_owner,".",m.table_name)
    DETAIL
     IF (locateval(dgcmsk_ndx,1,dvdr_rpt_dtl_info->tbl_cnt,d.owner,dvdr_rpt_dtl_info->tbls[dgcmsk_ndx
      ].owner,
      d.table_name,dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].table_name) > 0)
      dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].cur_src_mod_dt_tm = evaluate(nullind_m_timestamp,1,
       cnvtdatetime("01-JAN-1900"),m.timestamp), dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].last_analyzed =
      evaluate(nullind_d_last_analyzed,1,cnvtdatetime("01-JAN-1900"),d.last_analyzed),
      dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].monitoring = evaluate(d.monitoring,"YES",1,0)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Setting default values for data verification variables"
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_VDATA_INFO"
     AND di.info_name="DM2_VDATA_TGT_TO_SRC"
    DETAIL
     dgcmsk_no_src = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   FOR (dgcmsk_ndx = 1 TO dvdr_rpt_dtl_info->tbl_cnt)
     IF ((dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].max_src_keyid > 0))
      IF ((((dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].last_src_mod_dt_tm < greatest(dvdr_rpt_dtl_info->
       tbls[dgcmsk_ndx].cur_src_mod_dt_tm,dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].last_analyzed))) OR ((
      dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].monitoring=0)))
       AND  NOT ((dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].status IN (dvdr_exclude, dvdr_error))))
       SET dgcmsk_full_tname = trim(cnvtupper(concat(dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].owner,".",
          dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].table_name)))
       SET dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].last_src_mod_dt_tm = cnvtdatetime(greatest(
         dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].cur_src_mod_dt_tm,dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].
         last_analyzed))
       SET dm_err->eproc = concat("Retrieving SRC max uid for ",dgcmsk_full_tname)
       SELECT INTO "nl:"
        val_max = t1.max_id
        FROM (
         (
         (SELECT
          max_id = parser(concat("max(t.",dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].keyid_col_name,")"))
          FROM (value(concat("DM2VDATS",trim(cnvtstring(dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].
               src_object_id)))) t)
          WITH sqltype("F8")))
         t1)
        DETAIL
         dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].max_src_keyid = greatest(dvdr_rpt_dtl_info->tbls[
          dgcmsk_ndx].max_src_keyid,val_max), dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].key_range_remaining
          = (dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].max_src_keyid - dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].
         last_comp_keyid_max)
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc) != 0)
        SET dm_err->err_ind = 1
        RETURN(0)
       ENDIF
       IF (dgcmsk_no_src=1)
        SET dm_err->eproc = concat("Retrieving TGT max uid for ",dgcmsk_full_tname)
        SELECT INTO "nl:"
         val_max = t1.max_id
         FROM (
          (
          (SELECT
           max_id = parser(concat("max(t.",dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].keyid_col_name,")"))
           FROM (value(concat("DM2VDATT",trim(cnvtstring(dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].
                src_object_id)))) t)
           WITH sqltype("F8")))
          t1)
         DETAIL
          dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].max_src_keyid = greatest(dvdr_rpt_dtl_info->tbls[
           dgcmsk_ndx].max_src_keyid,val_max), dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].
          key_range_remaining = (dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].max_src_keyid -
          dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].last_comp_keyid_max)
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc) != 0)
         SET dm_err->err_ind = 1
         RETURN(0)
        ENDIF
       ENDIF
       SET dm_err->eproc = concat("Updating master table entry for ",dgcmsk_full_tname)
       UPDATE  FROM dm_vdata_master dvm
        SET dvm.max_src_keyid = dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].max_src_keyid, dvm
         .last_src_mod_dt_tm = cnvtdatetime(dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].last_src_mod_dt_tm)
        WHERE (dvm.owner_name=dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].owner)
         AND (dvm.table_name=dvdr_rpt_dtl_info->tbls[dgcmsk_ndx].table_name)
        WITH nocounter
       ;end update
       IF (check_error(dm_err->eproc) != 0)
        ROLLBACK
        SET dm_err->err_ind = 1
        RETURN(0)
       ELSE
        COMMIT
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_load_master(dlm_masterid)
   DECLARE dlm_ndx = i4 WITH protect, noconstant(0)
   DECLARE dlm_cnt = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Retrieve master level information."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    comp_dt_null = nullind(d.last_compare_dt_tm)
    FROM dm_vdata_master d
    WHERE d.dm_vdata_master_id=dlm_masterid
    DETAIL
     dmvd->tbl_cnt = (dmvd->tbl_cnt+ 1), stat = alterlist(dmvd->tbls,dmvd->tbl_cnt), dmvd->tbls[dmvd
     ->tbl_cnt].owner = d.owner_name,
     dmvd->tbls[dmvd->tbl_cnt].table_name = d.table_name, dmvd->tbls[dmvd->tbl_cnt].master_id = d
     .dm_vdata_master_id, dmvd->tbls[dmvd->tbl_cnt].status = d.compare_status,
     dmvd->tbls[dmvd->tbl_cnt].keyid_col_name = d.keyid_column_name, dmvd->tbls[dmvd->tbl_cnt].
     src_object_id = d.object_id_src, dmvd->tbls[dmvd->tbl_cnt].max_src_keyid = d.max_src_keyid,
     dmvd->tbls[dmvd->tbl_cnt].range_start_keyid = d.range_start_keyid, dmvd->tbls[dmvd->tbl_cnt].
     mm_beg_keyid = d.mismatch_beg_keyid, dmvd->tbls[dmvd->tbl_cnt].mm_end_keyid = d
     .mismatch_end_keyid,
     dmvd->tbls[dmvd->tbl_cnt].compare_keyid_min = d.range_beg_keyid, dmvd->tbls[dmvd->tbl_cnt].
     compare_keyid_max = d.range_end_keyid, dmvd->tbls[dmvd->tbl_cnt].last_range_keyid_min = d
     .range_beg_keyid,
     dmvd->tbls[dmvd->tbl_cnt].last_range_keyid_max = d.range_end_keyid, dmvd->tbls[dmvd->tbl_cnt].
     last_src_mod_dt_tm = d.last_src_mod_dt_tm, dmvd->tbls[dmvd->tbl_cnt].mismatch_event_cnt = d
     .mismatch_event_cnt,
     dmvd->tbls[dmvd->tbl_cnt].last_match_dt_tm = d.last_match_dt_tm, dmvd->tbls[dmvd->tbl_cnt].
     last_compare_cnt = d.last_compare_cnt, dmvd->tbls[dmvd->tbl_cnt].last_match_cnt = d
     .last_match_cnt,
     dmvd->tbls[dmvd->tbl_cnt].last_mm_rowid = d.mismatch_rowid, dmvd->tbls[dmvd->tbl_cnt].
     last_ui_str = d.mismatch_unique_key_txt, dmvd->tbls[dmvd->tbl_cnt].last_mm_cnt = d
     .curr_mismatch_row_cnt,
     dmvd->tbls[dmvd->tbl_cnt].last_mm_cnt_scui = d.last_match_cnt, dmvd->tbls[dmvd->tbl_cnt].
     rows_to_compare = d.rows_to_compare, dmvd->tbls[dmvd->tbl_cnt].scui_ind = d.updt_applctx,
     dmvd->tbls[dmvd->tbl_cnt].last_compare_dt_tm = evaluate(comp_dt_null,1,cnvtdatetime(
       "01-JAN-1900"),d.last_compare_dt_tm), dmvd->tbls[dmvd->tbl_cnt].date_col_name = d
     .row_dt_tm_col_name
     IF ((dmvd->tbls[dmvd->tbl_cnt].date_col_name != "DM2NOTSET"))
      dmvd->tbls[dmvd->tbl_cnt].date_col_exists = 1
     ELSE
      dmvd->tbls[dmvd->tbl_cnt].date_col_exists = 0
     ENDIF
     dmvd->tbls[dmvd->tbl_cnt].mm_rowid_dt_tm_min = cnvtdatetime(d.mismatch_row_dt_tm), dmvd->tbls[
     dmvd->tbl_cnt].mm_pull_key = d.mm_pull_key_from_src_ind,
     CALL dvdr_parse_list("COLUMN",",",d.column_list,dmvd->tbl_cnt),
     CALL dvdr_parse_list("DATATYPE",",",d.data_type_list,dmvd->tbl_cnt),
     CALL dvdr_parse_list("UNIQUESTR","<#>",d.mismatch_unique_key_txt,dmvd->tbl_cnt)
    FOOT REPORT
     stat = alterlist(dmvd->tbls,dmvd->tbl_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_appid_work(daw_just_check,daw_appl,daw_continue)
   DECLARE daw_status_ret = vc WITH protect, noconstant("")
   DECLARE daw_applid_chk = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Check if compare currently running"
   CALL disp_msg("",dm_err->logfile,10)
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM_VDATA_INFO"
     AND d.info_name="DM_VDATA_APPID"
    DETAIL
     daw_applid_chk = d.info_char
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual > 0
    AND daw_applid_chk > " ")
    SET dm_err->eproc = concat("Check status of APPL_ID:",daw_applid_chk)
    CALL disp_msg("",dm_err->logfile,10)
    SET daw_status_ret = dm2_get_appl_status(daw_applid_chk)
    CASE (daw_status_ret)
     OF "A":
      SET daw_continue = 0
      SET dm_err->eproc = concat(daw_applid_chk," is currently Active.")
      CALL disp_msg("",dm_err->logfile,10)
      RETURN(1)
     OF "I":
      SET dm_err->eproc = concat(daw_applid_chk," is currently Inactive.")
      CALL disp_msg("",dm_err->logfile,10)
      SET daw_continue = 1
     OF "E":
      SET daw_continue = 0
      RETURN(0)
    ENDCASE
   ENDIF
   IF (daw_just_check=0)
    SET dm_err->eproc = concat("Remove APPL_ID checkpoint from DM_INFO")
    CALL disp_msg("",dm_err->logfile,10)
    DELETE  FROM dm_info d
     WHERE d.info_domain="DM_VDATA_INFO"
      AND d.info_name="DM_VDATA_APPID"
     WITH nocounter
    ;end delete
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = concat("Log running compare for APPL_ID:",daw_appl)
    CALL disp_msg("",dm_err->logfile,10)
    INSERT  FROM dm_info d
     SET d.info_domain = "DM_VDATA_INFO", d.info_name = "DM_VDATA_APPID", d.info_char = daw_appl
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    COMMIT
    SET daw_continue = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr_get_verify2(null)
  SET dmvd->use_verify2_ind = 1
  RETURN(1)
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
 IF (check_logfile("dm2_verify_data2",".log","dm2_verify_data2")=0)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Starting DM2_VERIFY_DATA2"
 CALL disp_msg(" ",dm_err->logfile,0)
 DECLARE dvd_prelim(null) = i2
 DECLARE dvd_evaluate_compare(dec_ndx=i4,dec_compare=i2(ref)) = i2
 DECLARE dvd_setup_keys(dsk_ndx=i4) = i2
 DECLARE dvd_compare_table(dct_ndx=i4) = i2
 DECLARE dvd_log_status(dls_ndx=i4,dls_mode=vc) = i2
 DECLARE dvd_format_value(dfv_tbl_ndx=i4,dfv_col_ndx=i4) = vc
 DECLARE dvd_get_numrows(dcs_numrows=f8(ref),dcs_table=vc,dcs_owner=vc) = i2
 DECLARE dvd_get_uow(dgu_uow=f8(ref),dgu_master_id=f8) = i2
 DECLARE dvd_cycle = i4 WITH protect, noconstant(0)
 DECLARE dvd_cnt = i4 WITH protect, noconstant(0)
 DECLARE dvd_status_ret = i4 WITH protect, noconstant(0)
 DECLARE dvc_loc_ndx = i4 WITH protect, noconstant(0)
 DECLARE dvd_compare = i2 WITH protect, noconstant(0)
 DECLARE dvd_out = i2 WITH protect, noconstant(0)
 DECLARE dvd_chk_stop = i2 WITH protect, noconstant(0)
 DECLARE dvd_numrows = f8 WITH protect, noconstant(0.0)
 DECLARE dvd_uow = f8 WITH protect, noconstant(0.0)
 DECLARE dvd_last_row_time = dq8 WITH protect, noconstant(0.0)
 DECLARE dvd_lag_time = dq8 WITH protect, noconstant(0.0)
 IF (dvd_prelim(null)=0)
  GO TO exit_program
 ENDIF
 FOR (dvd_cnt = 1 TO dmvd->tbl_cnt)
   SET dm_err->eproc = concat("Starting table:",dmvd->tbls[dvd_cnt].owner,".",dmvd->tbls[dvd_cnt].
    table_name)
   CALL disp_msg("",dm_err->logfile,0)
   IF (validate(dvd_comp_single_table,"x") != "x"
    AND validate(dvd_comp_single_table,"y") != "y")
    SET dmvd->tbls[dvd_cnt].status = dvdr_comparing
    IF (dvd_log_status(dvd_cnt,dvdr_comparing)=0)
     GO TO exit_program
    ENDIF
   ENDIF
   IF ((dmvd->tbls[dvd_cnt].scui_ind IN (1, 2)))
    EXECUTE dm2_verify_data_child dvd_cnt, "MAX"
    IF ((dm_err->err_ind > 0))
     GO TO exit_program
    ENDIF
   ENDIF
   SET dmvd->tbls[dvd_cnt].beg_dt_tm = cnvtdatetime(curdate,curtime3)
   IF (dvd_get_numrows(dvd_numrows,dmvd->tbls[dvd_cnt].table_name,dmvd->tbls[dvd_cnt].owner)=0)
    GO TO exit_program
   ENDIF
   SET dmvd->tbls[dvd_cnt].num_rows = dvd_numrows
   SET dvd_cycle = 1
   WHILE (dvd_cycle=1)
     SET dvd_chk_stop = 0
     IF (dvdr_check_stop(dvd_chk_stop)=0)
      GO TO exit_program
     ENDIF
     IF (dvd_chk_stop=1)
      SET dm_err->eproc = "Compare has been marked to stop"
      CALL disp_msg("",dm_err->logfile,0)
      IF ((dmvd->tbls[dvd_cnt].last_compare_dt_tm=cnvtdatetime("01-JAN-1900")))
       SET dmvd->tbls[dvd_cnt].status = dvdr_ready
       CALL dvd_log_status(dvd_cnt,dvdr_statusupdate)
      ENDIF
      GO TO exit_program
     ENDIF
     IF (dvd_get_uow(dvd_uow,dmvd->tbls[dvd_cnt].master_id)=0)
      GO TO exit_program
     ENDIF
     IF ((dvd_uow != dmvd->tbls[dvd_cnt].rows_to_compare)
      AND dvd_uow > 0)
      SET dmvd->tbls[dvd_cnt].rows_to_compare = dvd_uow
     ENDIF
     IF (dvd_evaluate_compare(dvd_cnt,dvd_compare)=0)
      GO TO exit_program
     ENDIF
     IF (dvd_compare=1)
      IF (dvdr_get_old_lag(dvd_lag_time)=0)
       GO TO exit_program
      ENDIF
      IF (dvd_setup_keys(dvd_cnt)=0)
       GO TO exit_program
      ENDIF
      IF (dvd_compare_table(dvd_cnt)=0)
       SET dm_err->err_ind = 0
       SET dvd_cycle = 0
       SET dmvd->tbls[dvd_cnt].status = dvdr_error
       CALL dvd_log_status(dvd_cnt,dvdr_error)
      ENDIF
      IF ((dmvd->tbls[dvd_cnt].mismatch_event_cnt > 0))
       SET dvd_cycle = 0
      ELSE
       IF ((dmvd->tbls[dvd_cnt].status != dvdr_error))
        SET dmvd->tbls[dvd_cnt].last_match_dt_tm = dmvd->tbls[dvd_cnt].beg_dt_tm
        SET dmvd->tbls[dvd_cnt].last_compare_dt_tm = dmvd->tbls[dvd_cnt].beg_dt_tm
        IF ((dmvd->tbls[dvd_cnt].scui_ind IN (0, 3)))
         SET dmvd->tbls[dvd_cnt].status = dvdr_match
         CALL dvd_log_status(dvd_cnt,dvdr_match)
         SET dvd_cycle = 0
        ENDIF
       ENDIF
      ENDIF
     ELSE
      IF ((dmvd->tbls[dvd_cnt].status=dvdr_complete))
       IF (dvd_log_status(dvd_cnt,dvdr_complete)=0)
        GO TO exit_program
       ENDIF
      ELSE
       IF (dvd_log_status(dvd_cnt,dvdr_match)=0)
        GO TO exit_program
       ENDIF
      ENDIF
      SET dvd_cycle = 0
      SET dm_err->eproc = concat("Table compare not required:",dmvd->tbls[dvd_cnt].owner,".",dmvd->
       tbls[dvd_cnt].table_name)
      IF ((dm_err->debug_flag > 0))
       CALL disp_msg("",dm_err->logfile,0)
      ENDIF
     ENDIF
     IF ((dmvd->ranges_per_compare > 0))
      SET dvd_out = (dvd_out+ 1)
      IF ((dvd_out > dmvd->ranges_per_compare))
       SET dvd_cycle = 0
      ENDIF
     ENDIF
     IF ((datetimediff(cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)),cnvtdatetimeutc(cnvtdatetime(
        dmvd->compare_start_dt_tm)),4) > dmvd->timeout))
      SET dm_err->eproc = concat(build(dmvd->timeout),
       " minute run time expired, ending DM2_VERIFY_DATA:",dmvd->tbls[dvd_cnt].owner,".",dmvd->tbls[
       dvd_cnt].table_name)
      CALL disp_msg("",dm_err->logfile,0)
      SET dvd_cycle = 0
      IF ((dmvd->tbls[dvd_cnt].status=dvdr_match))
       CALL dvd_log_status(dvd_cnt,dvdr_match)
      ENDIF
     ENDIF
   ENDWHILE
   SET dm_err->eproc = concat("Finished table:",dmvd->tbls[dvd_cnt].owner,".",dmvd->tbls[dvd_cnt].
    table_name)
   CALL disp_msg("",dm_err->logfile,0)
 ENDFOR
 SUBROUTINE dvd_get_numrows(dcs_numrows,dcs_table,dcs_owner)
   SET dm_err->eproc = "Get numrows for table."
   SELECT INTO "nl:"
    nr_null = nullind(d.num_rows)
    FROM (value(concat("DM_DBA_TABLES_ACTUAL_STATS@",dmvd->db_link)) d)
    WHERE d.owner=dcs_owner
     AND d.table_name=dcs_table
    DETAIL
     dcs_numrows = evaluate(nr_null,1,- (1),d.num_rows)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvd_get_uow(dgu_uow,dgu_master_id)
   SET dm_err->eproc = "Get UOW for table."
   SELECT INTO "nl:"
    FROM dm_vdata_master d
    WHERE d.dm_vdata_master_id=dgu_master_id
    DETAIL
     dgu_uow = d.rows_to_compare
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvd_prelim(null)
   DECLARE dp_stop = i2 WITH protect, noconstant(0)
   DECLARE dp_masterid_single = f8 WITH protect, noconstant(0.0)
   SET dp_stop = 0
   IF (dvdr_check_stop(dp_stop)=0)
    RETURN(0)
   ENDIF
   IF (dp_stop=1)
    SET dm_err->eproc = "Compare has been marked to stop"
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(0)
   ENDIF
   IF ((dmvd->appl_id="DM2NOTSET"))
    SET dmvd->appl_id = currdbhandle
   ENDIF
   SET dm_err->eproc = "Retrieve parameter information for compare."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SET dmvd->tgt_to_src = 0
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_VDATA_INFO"
     AND d.info_name IN ("DM2_VDATA_DBLINK", "DM2_VDATA_RANGES_PER_COMPARE", "DM2_VDATA_TIMEOUT")
    DETAIL
     CASE (d.info_name)
      OF "DM2_VDATA_DBLINK":
       dmvd->db_link = d.info_char
      OF "DM2_VDATA_RANGES_PER_COMPARE":
       dmvd->ranges_per_compare = d.info_number
      OF "DM2_VDATA_TIMEOUT":
       dmvd->timeout = d.info_number
     ENDCASE
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dmvd->db_link="DM2NOTSET"))
    SET dmvd->db_link = "REF_DATA_LINK"
   ENDIF
   IF ((dmvd->tbl_cnt=0))
    IF (validate(dvd_comp_single_table,"x") != "x"
     AND validate(dvd_comp_single_table,"y") != "y")
     SET dm_err->eproc = concat("Compare single table:",dvd_comp_single_table)
     CALL disp_msg("",dm_err->logfile,0)
     SELECT INTO "nl:"
      FROM dm_vdata_master d
      WHERE d.table_name=cnvtupper(dvd_comp_single_table)
       AND d.owner_name=dvd_comp_single_table_owner
      DETAIL
       dp_masterid_single = d.dm_vdata_master_id
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (curqual > 0)
      SET dmvd->compare_start_dt_tm = cnvtdatetime(curdate,curtime3)
      IF (dvdr_load_master(dp_masterid_single)=0)
       RETURN(0)
      ELSE
       IF ((dmvd->tbl_cnt=0))
        SET dm_err->emsg = "No tables to compare."
        SET dm_err->err_ind = 1
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
     ELSE
      SET dm_err->emsg = "No tables to compare."
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF ((dmvd->tbls[1].scui_ind IN (0, 3)))
    IF (dvdr_get_tblmod("COMPARE")=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvd_evaluate_compare(dec_ndx,dec_compare)
   DECLARE dec_final_row_ind = i4 WITH protect, noconstant(0)
   SET dec_compare = 0
   IF ((dmvd->final_row_ind=0))
    SET dm_err->eproc = "Check for final row in DM_INFO"
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="DATABASE MIGRATION"
      AND d.info_name="FINAL TRANSACTION"
     DETAIL
      IF (d.updt_applctx=722)
       dmvd->final_row_ind = 1, dvd_last_row_time = cnvtdatetime(d.updt_dt_tm)
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual > 0
     AND (dmvd->final_row_ind=0))
     SET dvd_last_row_time = cnvtdatetime(curdate,curtime3)
     SET dm_err->eproc = "Update final row in DM_INFO"
     UPDATE  FROM dm_info d
      SET d.updt_dt_tm = cnvtdatetime(dvd_last_row_time), d.updt_applctx = 722
      WHERE d.info_domain="DATABASE MIGRATION"
       AND d.info_name="FINAL TRANSACTION"
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ELSE
      SET dmvd->final_row_ind = 1
      COMMIT
     ENDIF
     SET dmvd->final_row_ind = 1
     SET dm_err->eproc =
     "Final transaction row located. Logging COMPLETE status for MATCHED tables which are fully compared."
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
   ENDIF
   IF (dec_compare=0
    AND (((dmvd->tbls[dec_ndx].last_compare_dt_tm=cnvtdatetime("01-JAN-1900"))) OR ((dmvd->tbls[
   dec_ndx].mismatch_event_cnt > 0))) )
    SET dec_compare = 1
   ENDIF
   IF (dec_compare=0
    AND (dmvd->tbls[dec_ndx].scui_ind IN (1, 2))
    AND (dmvd->tbls[dec_ndx].max_src_keyid > dmvd->tbls[dec_ndx].last_range_keyid_max))
    SET dec_compare = 1
   ELSEIF (dec_compare=0
    AND (dmvd->tbls[dec_ndx].scui_ind IN (1, 2))
    AND (dmvd->tbls[dec_ndx].max_src_keyid <= dmvd->tbls[dec_ndx].last_range_keyid_max)
    AND (dmvd->final_row_ind=1))
    SET dmvd->tbls[dec_ndx].status = dvdr_complete
    SET dec_compare = 0
    RETURN(1)
   ENDIF
   IF (dec_compare=0
    AND (dmvd->tbls[dec_ndx].scui_ind IN (0, 3))
    AND (dmvd->final_row_ind=1)
    AND (dmvd->tbls[dec_ndx].last_compare_dt_tm >= dvd_last_row_time))
    SET dmvd->tbls[dec_ndx].status = dvdr_complete
    SET dec_compare = 0
    RETURN(1)
   ELSEIF (dec_compare=0
    AND (dmvd->tbls[dec_ndx].scui_ind IN (0, 3))
    AND (((dmvd->tbls[dec_ndx].last_src_mod_dt_tm < greatest(dmvd->tbls[dec_ndx].cur_src_mod_dt_tm,
    dmvd->tbls[dec_ndx].last_analyzed))) OR ((dmvd->tbls[dec_ndx].last_analyzed=cnvtdatetime(
    "01-JAN-1900")))) )
    SET dec_compare = 1
   ENDIF
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc = concat("MIS_EVNT_CNT:",build(dmvd->tbls[dvd_cnt].mismatch_event_cnt),
     ", LST_MOD:",format(dmvd->tbls[dvd_cnt].last_src_mod_dt_tm,cclfmt->shortdatetime),", CUR_MOD:",
     format(dmvd->tbls[dvd_cnt].cur_src_mod_dt_tm,cclfmt->shortdatetime),", MAX_SRC:",build(dmvd->
      tbls[dvd_cnt].max_src_keyid),", LAST_MAX:",build(dmvd->tbls[dvd_cnt].last_range_keyid_max))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvd_log_status(dls_ndx,dls_mode)
  CASE (dls_mode)
   OF dvdr_statusupdate:
    SET dm_err->eproc = "Update table to COMPARING status."
    UPDATE  FROM dm_vdata_master d
     SET d.compare_status = dmvd->tbls[dls_ndx].status
     WHERE (d.dm_vdata_master_id=dmvd->tbls[dls_ndx].master_id)
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    COMMIT
   OF dvdr_error:
    UPDATE  FROM dm_vdata_master d
     SET d.compare_status = dls_mode, d.begin_dt_tm = cnvtdatetime(curdate,curtime3), d.message_txt
       = substring(1,3900,concat(dm_err->eproc,":",dm_err->emsg)),
      d.appl_ident = dmvd->appl_id
     WHERE (d.dm_vdata_master_id=dmvd->tbls[dls_ndx].master_id)
     WITH nocounter
    ;end update
    COMMIT
   OF dvdr_comparing:
    SET dm_err->eproc = "Update table to COMPARING status."
    UPDATE  FROM dm_vdata_master d
     SET d.compare_status = dls_mode, d.begin_dt_tm = cnvtdatetime(curdate,curtime3), d.appl_ident =
      dmvd->appl_id
     WHERE (d.dm_vdata_master_id=dmvd->tbls[dls_ndx].master_id)
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    COMMIT
   OF dvdr_mismatch:
    IF ((dmvd->tbls[dls_ndx].mm_pull_key=0))
     SET dmvd->tbls[dls_ndx].mismatch_event_cnt = (dmvd->tbls[dls_ndx].mismatch_event_cnt+ 1)
    ELSE
     IF ((((dmvd->tbls[dls_ndx].last_mm_rowid=dmvd->tbls[dls_ndx].mm_rowid_min)
      AND (dmvd->tbls[dls_ndx].mm_rowid_min > " ")) OR ((dmvd->tbls[dls_ndx].mm_rowid_min=""))) )
      SET dmvd->tbls[dls_ndx].mismatch_event_cnt = (dmvd->tbls[dls_ndx].mismatch_event_cnt+ 1)
     ELSE
      SET dmvd->tbls[dls_ndx].mismatch_event_cnt = 1
     ENDIF
    ENDIF
    IF ((((dmvd->tbls[dls_ndx].mm_rowid_min="")) OR ((dmvd->tbls[dls_ndx].mm_pull_key=0))) )
     SET dm_err->eproc = "Update master row to MISMATCH without rowid"
     UPDATE  FROM dm_vdata_master d
      SET d.compare_status = dls_mode, d.range_beg_keyid = dmvd->tbls[dls_ndx].last_range_keyid_min,
       d.range_end_keyid = dmvd->tbls[dls_ndx].last_range_keyid_max,
       d.mismatch_beg_keyid = dmvd->tbls[dls_ndx].mm_beg_keyid, d.mismatch_end_keyid = dmvd->tbls[
       dls_ndx].mm_end_keyid, d.last_src_mod_dt_tm = cnvtdatetime(greatest(dmvd->tbls[dls_ndx].
         last_analyzed,dmvd->tbls[dls_ndx].cur_src_mod_dt_tm)),
       d.max_src_keyid = evaluate(dmvd->tbls[dls_ndx].max_src_keyid,0.0,d.max_src_keyid,dmvd->tbls[
        dls_ndx].max_src_keyid), d.mismatch_event_cnt = dmvd->tbls[dls_ndx].mismatch_event_cnt, d
       .begin_dt_tm = cnvtdatetime(dmvd->tbls[dls_ndx].beg_dt_tm),
       d.end_dt_tm = cnvtdatetime(curdate,curtime3), d.last_compare_cnt = dmvd->tbls[dls_ndx].
       last_compare_cnt, d.ttl_rows_compared = ((dmvd->tbls[dls_ndx].last_range_keyid_max - dmvd->
       tbls[dls_ndx].range_start_keyid)+ 1),
       d.curr_mismatch_row_cnt = dmvd->tbls[dls_ndx].mm_cnt, d.prev_mismatch_row_cnt = dmvd->tbls[
       dls_ndx].last_mm_cnt, d.last_compare_dt_tm = cnvtdatetime(dmvd->tbls[dls_ndx].beg_dt_tm),
       d.mismatch_row_dt_tm = cnvtdatetime(dmvd->tbls[dls_ndx].mm_rowid_dt_tm_min), d.mismatch_rowid
        = null, d.mismatch_unique_key_txt = dmvd->tbls[dls_ndx].ui_str,
       d.appl_ident = dmvd->appl_id, d.lag_dt_tm = cnvtdatetime(dvd_lag_time)
      WHERE (d.dm_vdata_master_id=dmvd->tbls[dls_ndx].master_id)
      WITH nocounter
     ;end update
    ELSE
     SET dm_err->eproc = "Update master row to MISMATCH"
     UPDATE  FROM dm_vdata_master d
      SET d.compare_status = dls_mode, d.range_beg_keyid = dmvd->tbls[dls_ndx].last_range_keyid_min,
       d.range_end_keyid = dmvd->tbls[dls_ndx].last_range_keyid_max,
       d.mismatch_beg_keyid = dmvd->tbls[dls_ndx].mm_beg_keyid, d.mismatch_end_keyid = dmvd->tbls[
       dls_ndx].mm_end_keyid, d.last_src_mod_dt_tm = cnvtdatetime(greatest(dmvd->tbls[dls_ndx].
         last_analyzed,dmvd->tbls[dls_ndx].cur_src_mod_dt_tm)),
       d.max_src_keyid = evaluate(dmvd->tbls[dls_ndx].max_src_keyid,0.0,d.max_src_keyid,dmvd->tbls[
        dls_ndx].max_src_keyid), d.mismatch_event_cnt = dmvd->tbls[dls_ndx].mismatch_event_cnt, d
       .begin_dt_tm = cnvtdatetime(dmvd->tbls[dls_ndx].beg_dt_tm),
       d.end_dt_tm = cnvtdatetime(curdate,curtime3), d.last_compare_cnt = dmvd->tbls[dls_ndx].
       last_compare_cnt, d.ttl_rows_compared = ((dmvd->tbls[dls_ndx].last_range_keyid_max - dmvd->
       tbls[dls_ndx].range_start_keyid)+ 1),
       d.curr_mismatch_row_cnt = dmvd->tbls[dls_ndx].mm_cnt, d.prev_mismatch_row_cnt = dmvd->tbls[
       dls_ndx].last_mm_cnt, d.last_compare_dt_tm = cnvtdatetime(dmvd->tbls[dls_ndx].beg_dt_tm),
       d.mismatch_row_dt_tm = cnvtdatetime(dmvd->tbls[dls_ndx].mm_rowid_dt_tm_min), d.mismatch_rowid
        = evaluate(dmvd->tbls[dls_ndx].mismatch_event_cnt,1,dmvd->tbls[dls_ndx].mm_rowid_min,d
        .mismatch_rowid), d.mismatch_unique_key_txt = dmvd->tbls[dls_ndx].ui_str,
       d.appl_ident = dmvd->appl_id, d.lag_dt_tm = cnvtdatetime(dvd_lag_time)
      WHERE (d.dm_vdata_master_id=dmvd->tbls[dls_ndx].master_id)
      WITH nocounter
     ;end update
    ENDIF
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    COMMIT
   OF dvdr_complete:
   OF dvdr_match:
    SET dmvd->tbls[dls_ndx].mm_rowid_dt_tm_min = cnvtdatetime("01-JAN-1900")
    SET dmvd->tbls[dls_ndx].mm_rowid_min = ""
    SET dmvd->tbls[dls_ndx].last_mm_rowid = ""
    SET dmvd->tbls[dls_ndx].mismatch_event_cnt = 0
    SET dmvd->tbls[dls_ndx].last_mm_beg_keyid = 0
    SET dmvd->tbls[dls_ndx].last_mm_end_keyid = 0
    SET dmvd->tbls[dls_ndx].ui_str = ""
    SET dm_err->eproc = "Update table to MATCH or COMPLETE status."
    UPDATE  FROM dm_vdata_master d
     SET d.compare_status = dls_mode, d.range_beg_keyid = dmvd->tbls[dls_ndx].last_range_keyid_min, d
      .range_end_keyid = dmvd->tbls[dls_ndx].last_range_keyid_max,
      d.mismatch_beg_keyid = 0, d.mismatch_end_keyid = 0, d.last_src_mod_dt_tm = cnvtdatetime(
       greatest(dmvd->tbls[dls_ndx].cur_src_mod_dt_tm,dmvd->tbls[dls_ndx].last_analyzed)),
      d.max_src_keyid = evaluate(dmvd->tbls[dls_ndx].max_src_keyid,0.0,d.max_src_keyid,dmvd->tbls[
       dls_ndx].max_src_keyid), d.mismatch_event_cnt = 0, d.begin_dt_tm = cnvtdatetime(dmvd->tbls[
       dls_ndx].beg_dt_tm),
      d.end_dt_tm = cnvtdatetime(curdate,curtime3), d.last_match_dt_tm = cnvtdatetime(dmvd->tbls[
       dls_ndx].beg_dt_tm), d.last_compare_cnt = dmvd->tbls[dls_ndx].last_compare_cnt,
      d.ttl_rows_compared = ((dmvd->tbls[dls_ndx].last_range_keyid_max - dmvd->tbls[dls_ndx].
      range_start_keyid)+ 1), d.last_match_cnt = 0, d.last_compare_dt_tm = cnvtdatetime(dmvd->tbls[
       dls_ndx].beg_dt_tm),
      d.curr_mismatch_row_cnt = 0, d.prev_mismatch_row_cnt = 0, d.mismatch_rowid = null,
      d.mismatch_row_dt_tm = cnvtdatetime("01-JAN-1900"), d.mismatch_unique_key_txt = dmvd->tbls[
      dls_ndx].ui_str, d.appl_ident = dmvd->appl_id,
      d.lag_dt_tm = cnvtdatetime(dvd_lag_time)
     WHERE (d.dm_vdata_master_id=dmvd->tbls[dls_ndx].master_id)
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    COMMIT
   OF dvdr_progressupdate:
    SET dmvd->tbls[dls_ndx].mm_rowid_dt_tm_min = cnvtdatetime("01-JAN-1900")
    SET dmvd->tbls[dls_ndx].mm_rowid_min = ""
    SET dmvd->tbls[dls_ndx].last_mm_rowid = ""
    SET dmvd->tbls[dls_ndx].mismatch_event_cnt = 0
    SET dmvd->tbls[dls_ndx].last_mm_beg_keyid = 0
    SET dmvd->tbls[dls_ndx].last_mm_end_keyid = 0
    SET dmvd->tbls[dls_ndx].ui_str = ""
    SET dm_err->eproc = "Update compare progress."
    UPDATE  FROM dm_vdata_master d
     SET d.range_beg_keyid = dmvd->tbls[dls_ndx].last_range_keyid_min, d.range_end_keyid = dmvd->
      tbls[dls_ndx].last_range_keyid_max, d.mismatch_beg_keyid = 0,
      d.mismatch_end_keyid = 0, d.last_src_mod_dt_tm = cnvtdatetime(greatest(dmvd->tbls[dls_ndx].
        cur_src_mod_dt_tm,dmvd->tbls[dls_ndx].last_analyzed)), d.max_src_keyid = evaluate(dmvd->tbls[
       dls_ndx].max_src_keyid,0.0,d.max_src_keyid,dmvd->tbls[dls_ndx].max_src_keyid),
      d.mismatch_event_cnt = 0, d.begin_dt_tm = cnvtdatetime(dmvd->tbls[dls_ndx].beg_dt_tm), d
      .end_dt_tm = cnvtdatetime(curdate,curtime3),
      d.last_match_dt_tm = cnvtdatetime(dmvd->tbls[dls_ndx].beg_dt_tm), d.last_compare_cnt = dmvd->
      tbls[dls_ndx].last_compare_cnt, d.ttl_rows_compared = ((dmvd->tbls[dls_ndx].
      last_range_keyid_max - dmvd->tbls[dls_ndx].range_start_keyid)+ 1),
      d.last_match_cnt = 0, d.last_compare_dt_tm = cnvtdatetime(dmvd->tbls[dls_ndx].beg_dt_tm), d
      .curr_mismatch_row_cnt = 0,
      d.prev_mismatch_row_cnt = 0, d.mismatch_rowid = null, d.mismatch_row_dt_tm = cnvtdatetime(
       "01-JAN-1900"),
      d.mismatch_unique_key_txt = dmvd->tbls[dls_ndx].ui_str, d.appl_ident = dmvd->appl_id, d
      .lag_dt_tm = cnvtdatetime(dvd_lag_time)
     WHERE (d.dm_vdata_master_id=dmvd->tbls[dls_ndx].master_id)
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    COMMIT
  ENDCASE
  RETURN(1)
 END ;Subroutine
 SUBROUTINE dvd_format_value(dfv_tbl_ndx,dfv_col_ndx)
   DECLARE dfv_delim = vc WITH protect, noconstant(" ")
   DECLARE dfv_ret = vc WITH protect, noconstant(" ")
   CASE (dmvd->tbls[dfv_tbl_ndx].cols[dfv_col_ndx].data_type)
    OF "BINARY_FLOAT":
    OF "BINARY_DOUBLE":
    OF "FLOAT":
    OF "NUMBER":
     IF (findstring(".",dmvd->tbls[dfv_tbl_ndx].cols[dfv_col_ndx].data_value,1,1)=0)
      SET dfv_ret = concat(dmvd->tbls[dfv_tbl_ndx].cols[dfv_col_ndx].data_value,".0")
     ELSE
      IF (findstring(".",substring(1,1,dmvd->tbls[dfv_tbl_ndx].cols[dfv_col_ndx].data_value),1,1)=0)
       SET dfv_ret = dmvd->tbls[dfv_tbl_ndx].cols[dfv_col_ndx].data_value
      ELSE
       SET dfv_ret = concat("0",dmvd->tbls[dfv_tbl_ndx].cols[dfv_col_ndx].data_value)
      ENDIF
     ENDIF
    OF "DATE":
     SET dfv_ret = concat("cnvtdatetimeutc('",dmvd->tbls[dfv_tbl_ndx].cols[dfv_col_ndx].data_value,
      "')")
    ELSE
     IF (findstring("^",dmvd->tbls[dfv_tbl_ndx].cols[dfv_col_ndx].data_value,1,0)=0)
      SET dfv_delim = "^"
     ELSEIF (findstring('"',dmvd->tbls[dfv_tbl_ndx].cols[dfv_col_ndx].data_value,1,0)=0)
      SET dfv_delim = '"'
     ELSEIF (findstring("'",dmvd->tbls[dfv_tbl_ndx].cols[dfv_col_ndx].data_value,1,0)=0)
      SET dfv_delim = "'"
     ELSE
      SET dfv_delim = "~"
     ENDIF
     SET dfv_ret = concat("notrim(nopatstring(",dfv_delim,dmvd->tbls[dfv_tbl_ndx].cols[dfv_col_ndx].
      data_value,dfv_delim,"))")
   ENDCASE
   IF ((dm_err->debug_flag > 0))
    CALL echo(dfv_ret)
   ENDIF
   RETURN(dfv_ret)
 END ;Subroutine
 SUBROUTINE dvd_compare_table(dct_ndx)
   DECLARE dct_str_ret = vc WITH protect, noconstant(" ")
   DECLARE dct_cnt = i4 WITH protect, noconstant(0)
   DECLARE dct_where_clause = vc WITH protect, noconstant(" ")
   DECLARE dct_loc_ndx = i4 WITH protect, noconstant(0)
   DECLARE dct_found_rowid = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = concat("Compare ",dmvd->tbls[dct_ndx].owner,".",dmvd->tbls[dct_ndx].table_name,
    " using ",
    dmvd->tbls[dct_ndx].keyid_col_name," from ",build(dmvd->tbls[dct_ndx].compare_keyid_min)," to ",
    build(dmvd->tbls[dct_ndx].compare_keyid_max))
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SET dmvd->tbls[dct_ndx].mm_beg_keyid = 0
   SET dmvd->tbls[dct_ndx].mm_end_keyid = 0
   SET dmvd->tbls[dct_ndx].mm_cnt = 0
   SET dm_err->eproc = "Query DMVDAT1 view."
   IF ((dmvd->tbls[dct_ndx].scui_ind IN (0, 3)))
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       uni_str = t1.unique_str
       FROM (value(concat("DM2VDAT",trim(cnvtstring(dmvd->tbls[dct_ndx].src_object_id)),"1")) t1)
       WHERE rownum < 2
       WITH sqltype("VC4000")))
      t)
     DETAIL
      dmvd->tbls[dct_ndx].ui_str = t.uni_str,
      CALL dvdr_parse_list("UNIQUESTR","<#>",dmvd->tbls[dct_ndx].ui_str,dct_ndx), dmvd->tbls[dct_ndx]
      .mm_cnt = 1
     WITH nocounter, orahint("ALL_ROWS"), orahintcbo("ALL_ROWS")
    ;end select
   ELSEIF ((dmvd->tbls[dct_ndx].scui_ind=2))
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       uni_id = t1.unique_id, uni_str = t1.unique_str
       FROM (value(concat("DM2VDAT",trim(cnvtstring(dmvd->tbls[dct_ndx].src_object_id)),"1")) t1)
       WHERE t1.unique_id BETWEEN dmvd->tbls[dct_ndx].compare_keyid_min AND dmvd->tbls[dct_ndx].
       compare_keyid_max
        AND rownum < 2
       WITH sqltype("F8","VC4000")))
      t)
     DETAIL
      dmvd->tbls[dct_ndx].ui_str = t.uni_str, dmvd->tbls[dct_ndx].mm_cnt = 1, dmvd->tbls[dct_ndx].
      mm_beg_keyid = t.uni_id,
      dmvd->tbls[dct_ndx].mm_end_keyid = dmvd->tbls[dct_ndx].compare_keyid_max,
      CALL dvdr_parse_list("UNIQUESTR","<#>",dmvd->tbls[dct_ndx].ui_str,dct_ndx)
     WITH nocounter, orahint("ALL_ROWS"), orahintcbo("ALL_ROWS")
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       uni_id = t1.unique_id
       FROM (value(concat("DM2VDAT",trim(cnvtstring(dmvd->tbls[dct_ndx].src_object_id)),"1")) t1)
       WHERE t1.unique_id BETWEEN dmvd->tbls[dct_ndx].compare_keyid_min AND dmvd->tbls[dct_ndx].
       compare_keyid_max
        AND rownum < 2
       WITH sqltype("F8")))
      t)
     DETAIL
      dmvd->tbls[dct_ndx].ui_str = build(t.uni_id), dmvd->tbls[dct_ndx].mm_beg_keyid = t.uni_id, dmvd
      ->tbls[dct_ndx].mm_end_keyid = dmvd->tbls[dct_ndx].compare_keyid_max,
      dmvd->tbls[dct_ndx].cols[1].data_value = dmvd->tbls[dct_ndx].ui_str, dmvd->tbls[dct_ndx].mm_cnt
       = 1
     WITH nocounter, orahint("ALL_ROWS"), orahintcbo("ALL_ROWS")
    ;end select
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dmvd->tbls[dct_ndx].mm_cnt > 0))
    IF ((dmvd->tbls[dct_ndx].mm_pull_key=1))
     FOR (dct_cnt = 1 TO size(dmvd->tbls[dct_ndx].cols,5))
       IF ((dm_err->debug_flag > 0))
        CALL echo(build("bgtest:",dct_cnt))
        CALL echo(concat("where:",dct_where_clause))
       ENDIF
       IF (dct_cnt > 1)
        SET dct_where_clause = concat(dct_where_clause," and ")
       ENDIF
       IF ((dmvd->tbls[dct_ndx].cols[dct_cnt].data_value="")
        AND  NOT ((dmvd->tbls[dct_ndx].cols[dct_cnt].data_type IN ("NUMBER", "FLOAT", "DATE",
       "BINARY_FLOAT", "BINARY_DOUBLE",
       "TIMESTAMP"))))
        SET dct_where_clause = concat(dct_where_clause," (t.",dmvd->tbls[dct_ndx].cols[dct_cnt].
         col_name," is null or ",dmvd->tbls[dct_ndx].cols[dct_cnt].col_name,
         " = char(0))")
       ELSEIF ((dmvd->tbls[dct_ndx].cols[dct_cnt].data_value=""))
        SET dct_where_clause = concat(dct_where_clause," t.",dmvd->tbls[dct_ndx].cols[dct_cnt].
         col_name," is null ")
       ELSE
        SET dct_where_clause = concat(dct_where_clause," t.",dmvd->tbls[dct_ndx].cols[dct_cnt].
         col_name,"=",dvd_format_value(dct_ndx,dct_cnt))
       ENDIF
     ENDFOR
     SET dct_found_rowid = 0
     IF ((dmvd->tbls[dct_ndx].date_col_exists=1))
      SET dm_err->eproc = "Obtain date/time and rowid for mismatch data."
      SELECT INTO "nl:"
       val_rowid = t1.row_rowid, val_time = t1.rowtime
       FROM (
        (
        (SELECT
         row_rowid = t.rowid, rowtime = parser(concat(" t.",dmvd->tbls[dct_ndx].date_col_name))
         FROM (value(concat(dmvd->tbls[dct_ndx].owner,".",dmvd->tbls[dct_ndx].table_name,"@",dmvd->
            db_link)) t)
         WHERE parser(dct_where_clause)
         WITH sqltype("VC100","DQ8")))
        t1)
       DETAIL
        dct_found_rowid = 1, dmvd->tbls[dct_ndx].mm_rowid_min = val_rowid, dmvd->tbls[dct_ndx].
        mm_rowid_dt_tm_min = cnvtdatetime(val_time)
       WITH nocounter, orahint("ALL_ROWS"), orahintcbo("ALL_ROWS")
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ELSE
      SET dm_err->eproc = "Obtain rowid for mismatch data."
      SELECT INTO "nl:"
       val_rowid = t1.row_rowid
       FROM (
        (
        (SELECT
         row_rowid = t.rowid
         FROM (value(concat(dmvd->tbls[dct_ndx].owner,".",dmvd->tbls[dct_ndx].table_name,"@",dmvd->
            db_link)) t)
         WHERE parser(dct_where_clause)
         WITH sqltype("VC100")))
        t1)
       DETAIL
        dct_found_rowid = 1, dmvd->tbls[dct_ndx].mm_rowid_min = val_rowid, dmvd->tbls[dct_ndx].
        mm_rowid_dt_tm_min = cnvtdatetime("01-JAN-1900")
       WITH nocounter, orahint("ALL_ROWS"), orahintcbo("ALL_ROWS")
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
     IF (dct_found_rowid=0)
      CALL dvd_log_status(dct_ndx,dvdr_mismatch)
      SET dm_err->eproc = concat("[",trim(cnvtstring(dmvd->tbls[dct_ndx].mismatch_event_cnt)),
       "]Obtain ROWID for MISMATCH:")
      SET dm_err->emsg = concat("Unable to find ROWID for <",dct_where_clause,">")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm_err->err_ind = 1
      RETURN(0)
     ENDIF
    ELSE
     SET dmvd->tbls[dct_ndx].mm_rowid_min = dmvd->tbls[dct_ndx].last_mm_rowid
    ENDIF
    IF ((dm_err->debug_flag > 0))
     SET dm_err->eproc = concat(dmvd->tbls[dct_ndx].owner,".",dmvd->tbls[dct_ndx].table_name,
      " has MISMATCHED rows")
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SET dmvd->tbls[dct_ndx].status = dvdr_mismatch
    IF (dvd_log_status(dct_ndx,dvdr_mismatch)=0)
     RETURN(0)
    ENDIF
   ELSE
    IF ((dm_err->debug_flag > 0))
     SET dm_err->eproc = concat(dmvd->tbls[dct_ndx].owner,".",dmvd->tbls[dct_ndx].table_name,
      " matched using ",dmvd->tbls[dct_ndx].keyid_col_name,
      " from ",build(dmvd->tbls[dct_ndx].compare_keyid_min)," to ",build(dmvd->tbls[dct_ndx].
       compare_keyid_max))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SET dmvd->tbls[dct_ndx].status = dvdr_match
    IF (dvd_log_status(dct_ndx,dvdr_progressupdate)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvd_setup_keys(dsk_ndx)
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc = "Retrieve table key information."
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   IF ((dmvd->tbls[dsk_ndx].mismatch_event_cnt > 0))
    IF ((dm_err->debug_flag > 0))
     CALL echo(concat("Getting compare ranges for previous mismatch:",dmvd->tbls[dsk_ndx].table_name)
      )
    ENDIF
    SET dmvd->tbls[dsk_ndx].compare_keyid_min = dmvd->tbls[dsk_ndx].mm_beg_keyid
    SET dmvd->tbls[dsk_ndx].compare_keyid_max = dmvd->tbls[dsk_ndx].mm_end_keyid
    SET dmvd->tbls[dsk_ndx].last_mm_beg_keyid = dmvd->tbls[dsk_ndx].mm_beg_keyid
    SET dmvd->tbls[dsk_ndx].last_mm_end_keyid = dmvd->tbls[dsk_ndx].mm_end_keyid
   ELSEIF ((dmvd->tbls[dsk_ndx].last_compare_dt_tm=cnvtdatetime("01-JAN-1900")))
    IF ((dm_err->debug_flag > 0))
     CALL echo(concat("Getting compare ranges for first time compare:",dmvd->tbls[dsk_ndx].table_name
       ))
    ENDIF
    IF ((dmvd->tbls[dsk_ndx].num_rows < dmvd->tbls[dsk_ndx].rows_to_compare)
     AND (dmvd->tbls[dsk_ndx].num_rows != - (1)))
     SET dmvd->tbls[dsk_ndx].compare_keyid_min = dmvd->tbls[dsk_ndx].range_start_keyid
     SET dmvd->tbls[dsk_ndx].compare_keyid_max = dmvd->tbls[dsk_ndx].max_src_keyid
     SET dmvd->tbls[dsk_ndx].last_range_keyid_min = dmvd->tbls[dsk_ndx].compare_keyid_min
     SET dmvd->tbls[dsk_ndx].last_range_keyid_max = dmvd->tbls[dsk_ndx].compare_keyid_max
    ELSE
     SET dmvd->tbls[dsk_ndx].last_range_keyid_min = dmvd->tbls[dsk_ndx].range_start_keyid
     IF (((dmvd->tbls[dsk_ndx].last_range_keyid_min+ dmvd->tbls[dsk_ndx].rows_to_compare) >= dmvd->
     tbls[dsk_ndx].max_src_keyid))
      SET dmvd->tbls[dsk_ndx].last_range_keyid_max = dmvd->tbls[dsk_ndx].max_src_keyid
     ELSE
      SET dmvd->tbls[dsk_ndx].last_range_keyid_max = ((dmvd->tbls[dsk_ndx].last_range_keyid_min+ dmvd
      ->tbls[dsk_ndx].rows_to_compare) - 1)
     ENDIF
     SET dmvd->tbls[dsk_ndx].compare_keyid_min = dmvd->tbls[dsk_ndx].last_range_keyid_min
     SET dmvd->tbls[dsk_ndx].compare_keyid_max = dmvd->tbls[dsk_ndx].last_range_keyid_max
    ENDIF
   ELSEIF ((dmvd->tbls[dsk_ndx].last_compare_dt_tm > cnvtdatetime("01-JAN-1900")))
    IF ((dm_err->debug_flag > 0))
     CALL echo(concat("Getting compare ranges for next range:",dmvd->tbls[dsk_ndx].table_name))
    ENDIF
    IF ((dmvd->tbls[dsk_ndx].num_rows < dmvd->tbls[dsk_ndx].rows_to_compare)
     AND (dmvd->tbls[dsk_ndx].num_rows != - (1))
     AND (dmvd->tbls[dsk_ndx].scui_ind != 1))
     SET dmvd->tbls[dsk_ndx].compare_keyid_min = dmvd->tbls[dsk_ndx].range_start_keyid
     SET dmvd->tbls[dsk_ndx].compare_keyid_max = dmvd->tbls[dsk_ndx].max_src_keyid
     SET dmvd->tbls[dsk_ndx].last_range_keyid_min = dmvd->tbls[dsk_ndx].compare_keyid_min
     SET dmvd->tbls[dsk_ndx].last_range_keyid_max = dmvd->tbls[dsk_ndx].compare_keyid_max
    ELSE
     SET dmvd->tbls[dsk_ndx].last_range_keyid_min = (dmvd->tbls[dsk_ndx].last_range_keyid_max+ 1)
     IF (((dmvd->tbls[dsk_ndx].last_range_keyid_min+ dmvd->tbls[dsk_ndx].rows_to_compare) >= dmvd->
     tbls[dsk_ndx].max_src_keyid))
      SET dmvd->tbls[dsk_ndx].last_range_keyid_max = dmvd->tbls[dsk_ndx].max_src_keyid
     ELSE
      SET dmvd->tbls[dsk_ndx].last_range_keyid_max = (dmvd->tbls[dsk_ndx].last_range_keyid_min+ (dmvd
      ->tbls[dsk_ndx].rows_to_compare - 1))
     ENDIF
     SET dmvd->tbls[dsk_ndx].compare_keyid_min = dmvd->tbls[dsk_ndx].last_range_keyid_min
     SET dmvd->tbls[dsk_ndx].compare_keyid_max = dmvd->tbls[dsk_ndx].last_range_keyid_max
    ENDIF
   ENDIF
   SET dmvd->tbls[dsk_ndx].last_compare_cnt = ((dmvd->tbls[dsk_ndx].compare_keyid_max - dmvd->tbls[
   dsk_ndx].compare_keyid_min)+ 1)
   RETURN(1)
 END ;Subroutine
#exit_program
 IF ((dm_err->debug_flag > 2))
  CALL echorecord(dmvd)
 ENDIF
 IF ((dm_err->err_ind > 0)
  AND dvd_cnt > 0)
  CALL dvd_log_status(dvd_cnt,dvdr_error)
 ENDIF
 SET dm_err->eproc = "DM2_VERIFY_DATA2 completed"
 CALL final_disp_msg("DM2_VERIFY_DATA2")
END GO
