CREATE PROGRAM dm2_verify_data_rpt2
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
 DECLARE dmr_get_node_name(null) = i2
 DECLARE dmr_get_queue_contents(batch_queue=vc) = i2
 DECLARE dmr_check_directory(directory=vc) = i2
 DECLARE dmr_get_unique_file_name(directory=vc,file_prefix=vc,file_suffix=vc) = i2
 DECLARE dmr_fill_email_list(null) = i2
 DECLARE dmr_send_email(subject=vc,address_list=vc,file_name=vc) = i2
 DECLARE dmr_get_user_list(null) = i2
 DECLARE dmr_verify_v500_user(exists_ind=i2(ref)) = i2
 DECLARE dmr_initialize_mig_data(null) = null
 DECLARE dmr_prompt_connect_data(dpcd_db_type=vc,dpcd_db_user=vc,dpcd_cnct_opt=vc) = i2
 DECLARE dmr_prompt_retrieve_mig_data(dprmd_adm_db_ind=i2,dprmd_src_db_ind=i2,dprmd_tgt_db_ind=i2,
  dprmd_sys_db_ind=i2) = i2
 DECLARE dmr_chk_mig_ora_version(dcmov_error_flag=i2(ref)) = i2
 DECLARE dmr_issue_summary_screen(diss_src_db_ind=i2,diss_tgt_db_ind=i2,diss_msg=vc) = i2
 DECLARE dmr_load_mig_data(null) = i2
 DECLARE dmr_store_off_mig_data(null) = i2
 DECLARE dmr_get_gg_dir(null) = i2
 DECLARE dmr_set_gg_files(dsgf_report_capture=i2,dsgf_report_delivery=i2) = null
 DECLARE dmr_directory_prompt(mode) = i2
 DECLARE dmr_check_batch_queue(dcbq_queue_name=vc,dcbq_queue_fnd_ret=i2(ref)) = i2
 DECLARE dmr_setup_batch_queue(dsbq_queue_name=vc) = i2
 DECLARE dmr_validate_src_and_tgt(dvst_src_ind=i2,dvst_tgt_ind=i2) = i2
 DECLARE dmr_stop_job(job_type=vc,job_mode=i2) = i2
 DECLARE dmr_get_storage_type(dgst_storage_ret=vc(ref)) = i2
 DECLARE dmr_load_managed_tables(dlmt_mng_ret=vc(ref)) = i2
 DECLARE dmr_mig_setup_gg_dir(null) = i2
 DECLARE dmr_load_di_filter(null) = i2
 DECLARE dmr_get_di_filter(null) = i2
 DECLARE dmr_create_di_macro(dcdm_in_dir=vc,dcdm_gg_version=i2) = i2
 DECLARE dmr_get_db_info(dgd_db_name=vc(ref),dgd_created_date=f8(ref)) = i2
 IF (validate(dmr_batch_queue,"X")="X"
  AND validate(dmr_batch_queue,"Y")="Y")
  DECLARE dmr_batch_queue = vc WITH public, constant(cnvtlower(build("migration$",logical(
      "environment"))))
 ENDIF
 FREE RECORD dmr_node
 RECORD dmr_node(
   1 cnt = i4
   1 qual[*]
     2 node_name = vc
     2 instance_number = f8
     2 instance_name = vc
 )
 IF ((validate(dmr_queue->cnt,- (1))=- (1))
  AND validate(dmr_queue->cnt,1)=1)
  FREE RECORD dmr_queue
  RECORD dmr_queue(
    1 cnt = i4
    1 qual[*]
      2 entry = i4
      2 jobname = vc
      2 username = vc
      2 status = vc
  )
 ENDIF
 IF ((validate(dmr_emails->cnt,- (1))=- (1))
  AND validate(dmr_emails->cnt,1)=1)
  FREE RECORD dmr_emails
  RECORD dmr_emails(
    1 change_ind = i2
    1 email_list = vc
    1 cnt = i4
    1 qual[*]
      2 email_address = vc
  )
 ENDIF
 IF ((validate(dmr_user_list->cnt,- (1))=- (1))
  AND validate(dmr_user_list->cnt,1)=1)
  FREE RECORD dmr_user_list
  RECORD dmr_user_list(
    1 change_ind = i2
    1 cnt = i4
    1 qual[*]
      2 user = vc
  )
 ENDIF
 IF ((validate(dmr_expimp->prompt_done,- (1))=- (1))
  AND validate(dmr_expimp->prompt_done,99)=99)
  FREE RECORD dmr_expimp
  RECORD dmr_expimp(
    1 prompt_done = i2
    1 mode = vc
    1 process = vc
    1 step = vc
    1 step_ready = i2
    1 src_ora_home = vc
    1 src_nls_lang = vc
    1 src_ksh_loc = vc
    1 tgt_ora_home = vc
    1 tgt_nls_lang = vc
    1 tgt_file_loc = vc
    1 ora_username = vc
    1 user_prefix = vc
    1 file_prefix = vc
    1 export_prefix = vc
    1 sqlplus_prefix = vc
    1 import_prefix = vc
    1 nohup_prefix = vc
    1 exp_utility_location = vc
    1 imp_utility_location = vc
    1 read_only_mode = i2
    1 data_chunk_size = f8
    1 diff_ora_version = i2
    1 stg_v500_p_word = vc
    1 stg_v500_cnct_str = vc
    1 stg_db_name = vc
    1 stg_node_name = vc
    1 stg_created_date = f8
    1 expimp_user_cnt = i2
    1 users[*]
      2 expimp_user = vc
  )
  SET dmr_expimp->data_chunk_size = 1000000.0
 ENDIF
 IF (validate(dmr_mig_data->dm2_mig_log,"X")="X"
  AND validate(dmr_mig_data->dm2_mig_log,"Z")="Z")
  FREE RECORD dmr_mig_data
  RECORD dmr_mig_data(
    1 dm2_mig_log = vc
    1 adm_cdba_pwd = vc
    1 adm_cdba_cnct_str = vc
    1 cur_db_type = vc
    1 tgt_v500_pwd = vc
    1 tgt_v500_cnct_str = vc
    1 tgt_sys_pwd = vc
    1 tgt_sys_cnct_str = vc
    1 tgt_storage_type = vc
    1 src_storage_type = vc
    1 src_v500_pwd = vc
    1 src_v500_cnct_str = vc
    1 src_sys_pwd = vc
    1 src_sys_cnct_str = vc
    1 src_db_name = vc
    1 src_created_date = f8
    1 src_db_os = vc
    1 src_ora_version = vc
    1 src_ora_level1 = i2
    1 src_ora_level2 = i2
    1 src_ora_level3 = i2
    1 src_ora_level4 = i2
    1 src_node_cnt = i4
    1 src_nodes[*]
      2 node_name = vc
      2 instance_number = f8
      2 instance_name = vc
    1 tgt_db_name = vc
    1 tgt_created_date = f8
    1 tgt_db_os = vc
    1 tgt_ora_version = vc
    1 tgt_ora_level1 = i2
    1 tgt_ora_level2 = i2
    1 tgt_ora_level3 = i2
    1 tgt_ora_level4 = i2
    1 tgt_node_cnt = i4
    1 tgt_nodes[*]
      2 node_name = vc
      2 instance_number = f8
      2 instance_name = vc
    1 report_all = i2
    1 report_capture = i2
    1 report_delivery = i2
    1 cap_dir = vc
    1 cap_mgr_rpt = vc
    1 cap_rpt = vc
    1 cap_err_rpt = vc
    1 del_dir = vc
    1 del_mgr_rpt = vc
    1 del_rpt = vc
    1 del_err_rpt = vc
    1 gg_capture_dir = vc
    1 gg_delivery_dir = vc
  )
  CALL dmr_initialize_mig_data(null)
 ENDIF
 IF ((validate(dmr_di_filter->cnt,- (1))=- (1))
  AND validate(dmr_di_filter->cnt,1)=1)
  RECORD dmr_di_filter(
    1 cnt = i4
    1 qual[*]
      2 name = vc
  )
 ENDIF
 SUBROUTINE dmr_initialize_mig_data(null)
   IF (cursys="AXP")
    SET dmr_mig_data->dm2_mig_log = logical("cer_install")
   ELSE
    SET dmr_mig_data->dm2_mig_log = concat(trim(logical("cer_install")),"/")
   ENDIF
   SET dmr_mig_data->adm_cdba_pwd = "DM2NOTSET"
   SET dmr_mig_data->cur_db_type = "DM2NOTSET"
   SET dmr_mig_data->adm_cdba_cnct_str = "DM2NOTSET"
   SET dmr_mig_data->tgt_v500_pwd = "DM2NOTSET"
   SET dmr_mig_data->tgt_v500_cnct_str = "DM2NOTSET"
   SET dmr_mig_data->src_v500_pwd = "DM2NOTSET"
   SET dmr_mig_data->src_v500_cnct_str = "DM2NOTSET"
   SET dmr_mig_data->src_sys_pwd = "DM2NOTSET"
   SET dmr_mig_data->src_sys_cnct_str = "DM2NOTSET"
   SET dmr_mig_data->src_db_name = "DM2NOTSET"
   SET dmr_mig_data->src_created_date = 0.0
   SET dmr_mig_data->src_db_os = "DM2NOTSET"
   SET dmr_mig_data->src_ora_version = "DM2NOTSET"
   SET stat = alterlist(dmr_mig_data->src_nodes,0)
   SET dmr_mig_data->src_node_cnt = 0
   SET dmr_mig_data->tgt_db_name = "DM2NOTSET"
   SET dmr_mig_data->tgt_created_date = 0.0
   SET dmr_mig_data->tgt_db_os = "DM2NOTSET"
   SET dmr_mig_data->tgt_ora_version = "DM2NOTSET"
   SET stat = alterlist(dmr_mig_data->tgt_nodes,0)
   SET dmr_mig_data->tgt_node_cnt = 0
   SET dmr_mig_data->report_all = 0
   SET dmr_mig_data->report_capture = 0
   SET dmr_mig_data->report_delivery = 0
   SET dmr_mig_data->cap_dir = "DM2NOTSET"
   SET dmr_mig_data->cap_mgr_rpt = "DM2NOTSET"
   SET dmr_mig_data->cap_rpt = "DM2NOTSET"
   SET dmr_mig_data->cap_err_rpt = "DM2NOTSET"
   SET dmr_mig_data->del_dir = "DM2NOTSET"
   SET dmr_mig_data->del_mgr_rpt = "DM2NOTSET"
   SET dmr_mig_data->del_rpt = "DM2NOTSET"
   SET dmr_mig_data->del_err_rpt = "DM2NOTSET"
 END ;Subroutine
 SUBROUTINE dmr_get_db_info(dgdi_db_name,dgdi_created_date)
   SET dm_err->eproc = "Get databse name and created date"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM v$database v
    DETAIL
     dgdi_db_name = trim(cnvtupper(currdbname)), dgdi_created_date = v.created
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_load_mig_data(null)
   DECLARE dlmd_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlmd_file = vc WITH protect, noconstant(concat(dmr_mig_data->dm2_mig_log,
     "dm2_mig_config.txt"))
   FREE RECORD dlmd_cmd
   RECORD dlmd_cmd(
     1 qual[*]
       2 rs_item = vc
       2 rs_item_value = vc
   )
   IF (dm2_findfile(dlmd_file)=0)
    RETURN(1)
   ENDIF
   SET dm_err->eproc = concat("Attempting to access ",dlmd_file)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET logical dlmd_config_file dlmd_file
   FREE DEFINE rtl
   DEFINE rtl "dlmd_config_file"
   SELECT INTO "nl:"
    t.line
    FROM rtlt t
    WHERE t.line > " "
    DETAIL
     dlmd_cnt = (dlmd_cnt+ 1), stat = alterlist(dlmd_cmd->qual,dlmd_cnt), dlmd_cmd->qual[dlmd_cnt].
     rs_item = substring(1,(findstring(",",t.line,1,0) - 1),t.line),
     dlmd_cmd->qual[dlmd_cnt].rs_item_value = substring((findstring(",",t.line,1,0)+ 1),(size(t.line)
       - findstring(",",t.line,1,0)),t.line)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dlmd_cmd)
   ENDIF
   SET dlmd_cnt = 0
   FOR (dlmd_cnt = 1 TO size(dlmd_cmd->qual,5))
     IF (findstring("_pwd",dlmd_cmd->qual[dlmd_cnt].rs_item,1,1)=0)
      CALL parser(concat("set dmr_mig_data->",dlmd_cmd->qual[dlmd_cnt].rs_item," = ",dlmd_cmd->qual[
        dlmd_cnt].rs_item_value," go"),1)
     ELSE
      CALL parser(concat("set dmr_mig_data->",dlmd_cmd->qual[dlmd_cnt].rs_item," = ",dlmd_cmd->qual[
        dlmd_cnt].rs_item_value," go"),1)
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_store_off_mig_data(null)
   DECLARE dsomd_file = vc WITH protect, noconstant(concat(dmr_mig_data->dm2_mig_log,
     "dm2_mig_config.txt"))
   SET dm_err->eproc = concat("Checking if ",dsomd_file," exists.")
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (dm2_findfile(dsomd_file) > 0)
    SET dm_err->eproc = concat("Attempting to remove ",dsomd_file)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    IF (remove(dsomd_file)=0)
     SET dm_err->emsg = concat("Unable to remove ",dsomd_file)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   SET logical dsomd_config_file dsomd_file
   SET dm_err->eproc = concat("Creating ",dsomd_file)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO dsomd_config_file
    DETAIL
     IF ((dmr_mig_data->adm_cdba_pwd != "DM2NOTSET"))
      CALL print(concat('adm_cdba_pwd,"',dmr_mig_data->adm_cdba_pwd,'"')), row + 1
     ENDIF
     IF ((dmr_mig_data->adm_cdba_cnct_str != "DM2NOTSET"))
      CALL print(concat('adm_cdba_cnct_str,"',dmr_mig_data->adm_cdba_cnct_str,'"')), row + 1
     ENDIF
     IF ((dmr_mig_data->src_v500_pwd != "DM2NOTSET"))
      CALL print(concat('src_v500_pwd,"',dmr_mig_data->src_v500_pwd,'"')), row + 1
     ENDIF
     IF ((dmr_mig_data->src_v500_cnct_str != "DM2NOTSET"))
      CALL print(concat('src_v500_cnct_str,"',dmr_mig_data->src_v500_cnct_str,'"')), row + 1
     ENDIF
     IF ((dmr_mig_data->src_sys_pwd != "DM2NOTSET"))
      CALL print(concat('src_sys_pwd,"',dmr_mig_data->src_sys_pwd,'"')), row + 1
     ENDIF
     IF ((dmr_mig_data->src_sys_cnct_str != "DM2NOTSET"))
      CALL print(concat('src_sys_cnct_str,"',dmr_mig_data->src_sys_cnct_str,'"')), row + 1
     ENDIF
     IF ((dmr_mig_data->tgt_v500_pwd != "DM2NOTSET"))
      CALL print(concat('tgt_v500_pwd,"',dmr_mig_data->tgt_v500_pwd,'"')), row + 1
     ENDIF
     IF ((dmr_mig_data->tgt_v500_cnct_str != "DM2NOTSET"))
      CALL print(concat('tgt_v500_cnct_str,"',dmr_mig_data->tgt_v500_cnct_str,'"')), row + 1
     ENDIF
    WITH nocounter, maxcol = 500, format = variable,
     formfeed = none, maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_chk_mig_ora_version(dcmov_error_flag)
   SET dcmov_error_flag = 0
   IF ((dmr_mig_data->tgt_ora_level1 < dmr_mig_data->src_ora_level1))
    SET dcmov_error_flag = 1
    RETURN(1)
   ELSEIF ((dmr_mig_data->tgt_ora_level1 > dmr_mig_data->src_ora_level1))
    RETURN(1)
   ELSE
    IF ((dmr_mig_data->tgt_ora_level2 < dmr_mig_data->src_ora_level2))
     SET dcmov_error_flag = 1
     RETURN(1)
    ELSEIF ((dmr_mig_data->tgt_ora_level2 > dmr_mig_data->src_ora_level2))
     RETURN(1)
    ELSE
     IF ((dmr_mig_data->tgt_ora_level3 < dmr_mig_data->src_ora_level3))
      SET dcmov_error_flag = 1
      RETURN(1)
     ELSEIF ((dmr_mig_data->tgt_ora_level3 > dmr_mig_data->src_ora_level3))
      RETURN(1)
     ELSE
      IF ((dmr_mig_data->tgt_ora_level4 < dmr_mig_data->src_ora_level4))
       SET dcmov_error_flag = 1
       RETURN(1)
      ELSEIF ((dmr_mig_data->tgt_ora_level4 > dmr_mig_data->src_ora_level4))
       RETURN(1)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   SET dcmov_error_flag = 0
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_prompt_connect_data(dpcd_db_type,dpcd_db_user,dpcd_cnct_opt)
   DECLARE dpcd_db_pwd = vc WITH protect, noconstant("")
   DECLARE dpcd_cnct_str = vc WITH protect, noconstant("")
   IF ( NOT (dpcd_db_type IN ("ADMIN", "TARGET", "SOURCE")))
    SET dm_err->emsg = concat("Database Type ",dpcd_db_type,
     " is invalid. Type must be ADMIN, TARGET or SOURCE")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((dpcd_db_type="ADMIN"
    AND dpcd_db_user != "CDBA") OR (((dpcd_db_type="TARGET"
    AND  NOT (dpcd_db_user IN ("V500", "SYS"))) OR (dpcd_db_type="SOURCE"
    AND  NOT (dpcd_db_user IN ("V500", "SYS")))) )) )
    SET dm_err->emsg = concat("Database Username ",dpcd_db_user,
     " is invalid. User must be CDBA, V500 or SYS")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ( NOT (dpcd_cnct_opt IN ("CO", "PC")))
    SET dm_err->emsg = concat("Connect option ",dpcd_cnct_opt,
     " is invalid. Connect option must be PC or CO.")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dpcd_cnct_opt="CO")
    CASE (dpcd_db_type)
     OF "TARGET":
      IF (dpcd_db_user="SYS")
       SET dpcd_db_pwd = dmr_mig_data->tgt_sys_pwd
       SET dpcd_cnct_str = dmr_mig_data->tgt_sys_cnct_str
      ELSE
       SET dpcd_db_pwd = dmr_mig_data->tgt_v500_pwd
       SET dpcd_cnct_str = dmr_mig_data->tgt_v500_cnct_str
      ENDIF
     OF "SOURCE":
      IF (dpcd_db_user="SYS")
       SET dpcd_db_pwd = dmr_mig_data->src_sys_pwd
       SET dpcd_cnct_str = dmr_mig_data->src_sys_cnct_str
      ELSE
       SET dpcd_db_pwd = dmr_mig_data->src_v500_pwd
       SET dpcd_cnct_str = dmr_mig_data->src_v500_cnct_str
      ENDIF
     OF "ADMIN":
      SET dpcd_db_pwd = dmr_mig_data->adm_cdba_pwd
      SET dpcd_cnct_str = dmr_mig_data->adm_cdba_cnct_str
    ENDCASE
    IF (dpcd_db_pwd IN ("", "DM2NOTSET"))
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
     SET dm_err->emsg = "Password must be supplied with CO option"
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dpcd_cnct_str IN ("", "DM2NOTSET"))
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
     SET dm_err->emsg = "Connect string must be supplied with CO option"
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(dpcd_db_type)
    CALL echo(dpcd_db_user)
   ENDIF
   SET dm2_force_connect_string = 1
   SET dm2_install_schema->dbase_name = dpcd_db_type
   SET dm2_install_schema->u_name = dpcd_db_user
   SET dm2_install_schema->p_word = dpcd_db_pwd
   SET dm2_install_schema->connect_str = dpcd_cnct_str
   EXECUTE dm2_connect_to_dbase dpcd_cnct_opt
   SET dm2_force_connect_string = 0
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET dmr_mig_data->cur_db_type = dpcd_db_type
   IF (dpcd_cnct_opt="PC")
    IF (dpcd_db_type="ADMIN")
     SET dmr_mig_data->adm_cdba_pwd = dm2_install_schema->p_word
     SET dmr_mig_data->adm_cdba_cnct_str = dm2_install_schema->connect_str
     SET dm2_install_schema->cdba_p_word = dm2_install_schema->p_word
     SET dm2_install_schema->cdba_connect_str = dm2_install_schema->connect_str
    ELSEIF (dpcd_db_type="SOURCE")
     IF (dpcd_db_user="V500")
      SET dmr_mig_data->src_v500_pwd = dm2_install_schema->p_word
      SET dmr_mig_data->src_v500_cnct_str = dm2_install_schema->connect_str
      SET dm2_install_schema->src_v500_p_word = dm2_install_schema->p_word
      SET dm2_install_schema->src_v500_connect_str = dm2_install_schema->connect_str
     ELSE
      SET dmr_mig_data->src_sys_pwd = dm2_install_schema->p_word
      SET dmr_mig_data->src_sys_cnct_str = dm2_install_schema->connect_str
     ENDIF
    ELSEIF (dpcd_db_type="TARGET")
     IF (dpcd_db_user="V500")
      SET dmr_mig_data->tgt_v500_pwd = dm2_install_schema->p_word
      SET dmr_mig_data->tgt_v500_cnct_str = dm2_install_schema->connect_str
      SET dm2_install_schema->v500_p_word = dm2_install_schema->p_word
      SET dm2_install_schema->v500_connect_str = dm2_install_schema->connect_str
     ELSE
      SET dmr_mig_data->tgt_sys_pwd = dm2_install_schema->p_word
      SET dmr_mig_data->tgt_sys_cnct_str = dm2_install_schema->connect_str
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_prompt_retrieve_mig_data(dprmd_adm_db_ind,dprmd_src_db_ind,dprmd_tgt_db_ind,
  dprmd_sys_db_ind)
   DECLARE dprmd_db = vc WITH protect, noconstant("")
   DECLARE dprmd_confirm = i2 WITH protect, noconstant(0)
   DECLARE dprmd_cnt = i4 WITH protect, noconstant(0)
   DECLARE dprmd_error_ret = i2 WITH protect, noconstant(0)
   DECLARE dprmd_storage_type = vc WITH protect, noconstant("")
   IF ((( NOT (dprmd_adm_db_ind IN (0, 1))) OR ((( NOT (dprmd_src_db_ind IN (0, 1))) OR ((( NOT (
   dprmd_tgt_db_ind IN (0, 1))) OR ( NOT (dprmd_sys_db_ind IN (0, 1)))) )) )) )
    SET dm_err->emsg =
    "Invalid parameter value. Please verify that correct values are being used for available parameters."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dmr_load_mig_data(null)=0)
    RETURN(0)
   ENDIF
   IF (dprmd_adm_db_ind=1)
    IF ((((dmr_mig_data->adm_cdba_pwd="DM2NOTSET")) OR ((dmr_mig_data->adm_cdba_cnct_str="DM2NOTSET")
    )) )
     IF (dmr_prompt_connect_data("ADMIN","CDBA","PC")=0)
      RETURN(0)
     ENDIF
     SET dprmd_db = "ADMIN"
    ENDIF
   ENDIF
   IF (dprmd_src_db_ind=1)
    IF ((((dmr_mig_data->src_v500_pwd="DM2NOTSET")) OR ((dmr_mig_data->src_v500_cnct_str="DM2NOTSET")
    )) )
     IF (dmr_prompt_connect_data("SOURCE","V500","PC")=0)
      RETURN(0)
     ENDIF
     SET dprmd_db = "SOURCE"
     SET dprmd_confirm = 1
    ENDIF
    IF ((((dmr_mig_data->src_db_name="DM2NOTSET")) OR ((((dmr_mig_data->src_created_date=0.0)) OR (((
    (dmr_mig_data->src_db_os="DM2NOTSET")) OR ((((dmr_mig_data->src_ora_version="DM2NOTSET")) OR ((
    dmr_mig_data->src_node_cnt=0))) )) )) )) )
     IF (dprmd_db != "SOURCE")
      IF (dmr_prompt_connect_data("SOURCE","V500","CO")=0)
       RETURN(0)
      ENDIF
      SET dprmd_db = "SOURCE"
     ENDIF
     IF (dmr_get_db_info(dmr_mig_data->src_db_name,dmr_mig_data->src_created_date)=0)
      RETURN(0)
     ENDIF
     SET dmr_mig_data->src_db_os = dm2_sys_misc->cur_db_os
     IF (dm2_get_rdbms_version(null)=0)
      RETURN(0)
     ENDIF
     SET dmr_mig_data->src_ora_version = dm2_rdbms_version->version
     SET dmr_mig_data->src_ora_level1 = dm2_rdbms_version->level1
     SET dmr_mig_data->src_ora_level2 = dm2_rdbms_version->level2
     SET dmr_mig_data->src_ora_level3 = dm2_rdbms_version->level3
     SET dmr_mig_data->src_ora_level4 = dm2_rdbms_version->level4
     IF (dmr_get_node_name(null)=0)
      RETURN(0)
     ENDIF
     SET dmr_mig_data->src_node_cnt = dmr_node->cnt
     SET stat = alterlist(dmr_mig_data->src_nodes,dmr_node->cnt)
     FOR (dprmd_cnt = 1 TO dmr_node->cnt)
       SET dmr_mig_data->src_nodes[dprmd_cnt].node_name = cnvtlower(dmr_node->qual[dprmd_cnt].
        node_name)
       SET dmr_mig_data->src_nodes[dprmd_cnt].instance_number = dmr_node->qual[dprmd_cnt].
       instance_number
       SET dmr_mig_data->src_nodes[dprmd_cnt].instance_name = cnvtlower(dmr_node->qual[dprmd_cnt].
        instance_name)
     ENDFOR
     SET dprmd_storage_type = ""
     IF (dmr_get_storage_type(dprmd_storage_type)=0)
      RETURN(0)
     ENDIF
     SET dmr_mig_data->src_storage_type = dprmd_storage_type
    ENDIF
    IF ((((dmr_mig_data->src_sys_pwd="DM2NOTSET")) OR ((dmr_mig_data->src_sys_cnct_str="DM2NOTSET")
    ))
     AND dprmd_sys_db_ind=1)
     IF (dmr_prompt_connect_data("SOURCE","SYS","PC")=0)
      RETURN(0)
     ENDIF
     SET dprmd_db = "SOURCE"
    ENDIF
   ENDIF
   IF (dprmd_tgt_db_ind=1)
    IF ((((dmr_mig_data->tgt_v500_pwd="DM2NOTSET")) OR ((dmr_mig_data->tgt_v500_cnct_str="DM2NOTSET")
    )) )
     IF (dmr_prompt_connect_data("TARGET","V500","PC")=0)
      RETURN(0)
     ENDIF
     SET dprmd_db = "TARGET"
     SET dprmd_confirm = 1
    ENDIF
    IF ((((dmr_mig_data->tgt_db_name="DM2NOTSET")) OR ((((dmr_mig_data->tgt_created_date=0.0)) OR (((
    (dmr_mig_data->tgt_db_os="DM2NOTSET")) OR ((((dmr_mig_data->tgt_ora_version="DM2NOTSET")) OR ((
    dmr_mig_data->tgt_node_cnt=0))) )) )) )) )
     IF (dprmd_db != "TARGET")
      IF (dmr_prompt_connect_data("TARGET","V500","CO")=0)
       RETURN(0)
      ENDIF
      SET dprmd_db = "TARGET"
     ENDIF
     IF (dmr_get_db_info(dmr_mig_data->tgt_db_name,dmr_mig_data->tgt_created_date)=0)
      RETURN(0)
     ENDIF
     SET dmr_mig_data->tgt_db_os = dm2_sys_misc->cur_db_os
     IF (dm2_get_rdbms_version(null)=0)
      RETURN(0)
     ENDIF
     SET dmr_mig_data->tgt_ora_version = dm2_rdbms_version->version
     SET dmr_mig_data->tgt_ora_level1 = dm2_rdbms_version->level1
     SET dmr_mig_data->tgt_ora_level2 = dm2_rdbms_version->level2
     SET dmr_mig_data->tgt_ora_level3 = dm2_rdbms_version->level3
     SET dmr_mig_data->tgt_ora_level4 = dm2_rdbms_version->level4
     IF (dmr_get_node_name(null)=0)
      RETURN(0)
     ENDIF
     SET dmr_mig_data->tgt_node_cnt = dmr_node->cnt
     SET stat = alterlist(dmr_mig_data->tgt_nodes,dmr_node->cnt)
     FOR (dprmd_cnt = 1 TO dmr_node->cnt)
       SET dmr_mig_data->tgt_nodes[dprmd_cnt].node_name = cnvtlower(dmr_node->qual[dprmd_cnt].
        node_name)
       SET dmr_mig_data->tgt_nodes[dprmd_cnt].instance_number = dmr_node->qual[dprmd_cnt].
       instance_number
       SET dmr_mig_data->tgt_nodes[dprmd_cnt].instance_name = cnvtlower(dmr_node->qual[dprmd_cnt].
        instance_name)
     ENDFOR
     SET dprmd_storage_type = ""
     IF (dmr_get_storage_type(dprmd_storage_type)=0)
      RETURN(0)
     ENDIF
     SET dmr_mig_data->tgt_storage_type = dprmd_storage_type
    ENDIF
   ENDIF
   IF (dmr_chk_mig_ora_version(dprmd_error_ret)=0)
    RETURN(0)
   ENDIF
   IF (dprmd_src_db_ind=1)
    IF ((dmr_mig_data->src_ora_level1 < 9))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Check SOURCE Oracle version."
     SET dm_err->emsg = concat("SOURCE database Oracle version (",dmr_mig_data->src_ora_version,
      ") has to be 9 and higher.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dprmd_tgt_db_ind=1)
    IF ((dmr_mig_data->tgt_ora_level1 < 9))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Check Target Oracle version."
     SET dm_err->emsg = concat("Target database Oracle version (",dmr_mig_data->tgt_ora_version,
      ") has to be 9 and higher.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dmr_mig_data->tgt_db_os="AXP"))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Check Target domain OS."
     SET dm_err->emsg = "Target database can not be VMS."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dprmd_src_db_ind=1
    AND dprmd_tgt_db_ind=1
    AND validate(dm2_skip_create_date_check,0) != 1)
    IF ((dmr_mig_data->tgt_created_date < dmr_mig_data->src_created_date))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Compare Source created date with Target created date."
     SET dm_err->emsg =
     "Target database created date may not be lower than Source database created date."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dprmd_error_ret=1)
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Compare Source oracle version with Target oracle version."
     SET dm_err->emsg = concat("Target oracle version ",dmr_mig_data->tgt_ora_version,
      " can not be lower than Source oracle version ",dmr_mig_data->src_ora_version)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dmr_mig_data)
   ENDIF
   IF (dprmd_confirm=1)
    IF (dmr_issue_summary_screen(dprmd_src_db_ind,dprmd_tgt_db_ind,"")=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_issue_summary_screen(diss_src_db_ind,diss_tgt_db_ind,diss_msg)
   DECLARE diss_node_list = vc WITH protect, noconstant("")
   DECLARE diss_cnt = i4 WITH protect, noconstant(0)
   DECLARE diss_row_cnt = i4 WITH protect, noconstant(0)
   DECLARE diss_col_num = i4 WITH protect, noconstant(0)
   DECLARE diss_length = i4 WITH protect, noconstant(0)
   DECLARE diss_rows_max = i4 WITH protect, constant(21)
   DECLARE diss_col_max = i4 WITH protect, constant(40)
   SET diss_col_num = 2
   SET message = window
   CALL clear(1,1)
   CALL text(1,1,"DATABASE MIGRATION SUMMARY SCREEN")
   IF (diss_src_db_ind=1)
    CALL text(3,diss_col_num,"SOURCE")
    CALL text(4,diss_col_num,concat("Database Name : ",trim(dmr_mig_data->src_db_name)))
    CALL text(5,diss_col_num,concat("Database Create Date : ",format(dmr_mig_data->src_created_date,
       "mm-dd-yyyy;;d")))
    CALL text(6,diss_col_num,concat("Database Operating System : ",trim(dmr_mig_data->src_db_os)))
    CALL text(7,diss_col_num,concat("Database Oracle Version : ",trim(dmr_mig_data->src_ora_version))
     )
    CALL text(8,diss_col_num,"Database Nodes : ")
    SET diss_node_list = ""
    FOR (diss_cnt = 1 TO dmr_mig_data->src_node_cnt)
      IF ((dmr_mig_data->src_node_cnt > 1)
       AND diss_cnt != 1)
       SET diss_node_list = concat(diss_node_list,", ",dmr_mig_data->src_nodes[diss_cnt].node_name)
      ELSE
       SET diss_node_list = dmr_mig_data->src_nodes[diss_cnt].node_name
      ENDIF
    ENDFOR
    SET diss_cnt = 0
    SET diss_row_cnt = 9
    WHILE (diss_cnt < size(diss_node_list)
     AND diss_row_cnt < diss_rows_max)
      IF (size(diss_node_list) < diss_col_max)
       CALL text(diss_row_cnt,(diss_col_num+ 2),trim(substring((diss_cnt+ 1),diss_col_max,
          diss_node_list)))
       SET diss_length = diss_col_max
      ELSE
       SET diss_length = findstring(",",substring((diss_cnt+ 1),diss_col_max,diss_node_list),(
        diss_cnt+ 1),1)
       IF (diss_length=0)
        SET diss_length = diss_col_max
       ENDIF
       CALL text(diss_row_cnt,(diss_col_num+ 2),trim(substring((diss_cnt+ 1),diss_length,
          diss_node_list)))
      ENDIF
      SET diss_cnt = (diss_cnt+ diss_length)
      SET diss_row_cnt = (diss_row_cnt+ 1)
    ENDWHILE
   ENDIF
   IF (diss_tgt_db_ind=1)
    SET diss_col_num = evaluate(diss_src_db_ind,1,60,2)
    CALL text(3,diss_col_num,"TARGET")
    CALL text(4,diss_col_num,concat("Database Name : ",trim(dmr_mig_data->tgt_db_name)))
    CALL text(5,diss_col_num,concat("Database Create Date : ",format(dmr_mig_data->tgt_created_date,
       "mm-dd-yyyy;;d")))
    CALL text(6,diss_col_num,concat("Database Operating System : ",trim(dmr_mig_data->tgt_db_os)))
    CALL text(7,diss_col_num,concat("Database Oracle Version : ",trim(dmr_mig_data->tgt_ora_version))
     )
    CALL text(8,diss_col_num,"Database Nodes : ")
    SET diss_node_list = ""
    FOR (diss_cnt = 1 TO dmr_mig_data->tgt_node_cnt)
      IF ((dmr_mig_data->tgt_node_cnt > 1)
       AND diss_cnt != 1)
       SET diss_node_list = concat(diss_node_list,", ",dmr_mig_data->tgt_nodes[diss_cnt].node_name)
      ELSE
       SET diss_node_list = dmr_mig_data->tgt_nodes[diss_cnt].node_name
      ENDIF
    ENDFOR
    SET diss_cnt = 0
    SET diss_row_cnt = 9
    WHILE (diss_cnt < size(diss_node_list)
     AND diss_row_cnt < diss_rows_max)
      IF (size(diss_node_list) < diss_col_max)
       CALL text(diss_row_cnt,(diss_col_num+ 2),trim(substring((diss_cnt+ 1),diss_col_max,
          diss_node_list)))
       SET diss_length = diss_col_max
      ELSE
       SET diss_length = findstring(",",substring((diss_cnt+ 1),diss_col_max,diss_node_list),(
        diss_cnt+ 1),1)
       IF (diss_length=0)
        SET diss_length = diss_col_max
       ENDIF
       CALL text(diss_row_cnt,(diss_col_num+ 2),trim(substring((diss_cnt+ 1),diss_length,
          diss_node_list)))
      ENDIF
      SET diss_cnt = (diss_cnt+ diss_length)
      SET diss_row_cnt = (diss_row_cnt+ 1)
    ENDWHILE
   ENDIF
   CALL video(r)
   CALL text(22,2,"PLEASE PREVIEW ALL THE VALUES BEFORE CONTINUING!")
   IF (diss_msg > "")
    CALL text(23,2,diss_msg)
   ENDIF
   CALL video(n)
   CALL text(24,2,"Enter 'C' to continue or 'Q' to quit (C or Q) :")
   CALL accept(24,50,"p;cu"," "
    WHERE curaccept IN ("C", "Q"))
   SET message = nowindow
   IF (curaccept="Q")
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Prompt for Summary Information."
    SET dm_err->emsg = "User elected to quit at Database Migration Summary Screen."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curaccept="C")
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE dmr_get_node_name(null)
   IF ((dmr_node->cnt > 0))
    SET dmr_node->cnt = 0
    SET stat = alterlist(dmr_node->qual,0)
   ENDIF
   SET dm_err->eproc = "Determining all the node names that database resides on"
   SELECT INTO "nl:"
    FROM v$thread vt,
     gv$instance vi
    PLAN (vt)
     JOIN (vi
     WHERE vt.thread#=vi.thread#)
    ORDER BY vi.instance_number
    DETAIL
     dmr_node->cnt = (dmr_node->cnt+ 1)
     IF (mod(dmr_node->cnt,10)=1)
      stat = alterlist(dmr_node->qual,(dmr_node->cnt+ 9))
     ENDIF
     dmr_node->qual[dmr_node->cnt].instance_name = vi.instance_name, dmr_node->qual[dmr_node->cnt].
     instance_number = vi.instance_number, dmr_node->qual[dmr_node->cnt].node_name = vi.host_name
    FOOT REPORT
     stat = alterlist(dmr_node->qual,dmr_node->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 4))
    CALL echorecord(dmr_node)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_get_queue_contents(batch_queue)
   DECLARE dgqc_temp_line = vc WITH protect, noconstant("")
   DECLARE dgqc_field_num = i4 WITH protect, noconstant(1)
   DECLARE dgqc_start_pos = i4 WITH protect, noconstant(1)
   DECLARE dgqc_end_pos = i4 WITH protect, noconstant(1)
   DECLARE dgqc_continue = i4 WITH protect, noconstant(1)
   DECLARE dgqc_iter = i4 WITH protect, noconstant(0)
   IF (dm2_push_dcl(concat("SHOW QUEUE ",batch_queue))=0)
    RETURN(0)
   ENDIF
   FREE DEFINE rtl
   DEFINE rtl build("CCLUSERDIR:",dm_err->errfile)
   SET dm_err->eproc = "Parsing queue contents."
   SELECT INTO "nl:"
    r.line
    FROM rtlt r
    HEAD REPORT
     dmr_queue->cnt = 0, stat = alterlist(dmr_queue->qual,0)
    DETAIL
     dgqc_temp_line = trim(r.line,3)
     FOR (dgqc_iter = 1 TO 5)
       dgqc_temp_line = replace(dgqc_temp_line,"  "," ",0)
     ENDFOR
     dgqc_start_pos = 1, dgqc_continue = 1
     IF (dgqc_temp_line != ""
      AND dgqc_temp_line != "Entry*"
      AND dgqc_temp_line != "-----*"
      AND dgqc_temp_line != "Batch queue*")
      WHILE (dgqc_continue=1)
        IF (dgqc_field_num <= 3
         AND findstring(" ",dgqc_temp_line,dgqc_start_pos) > 0)
         dgqc_end_pos = least(findstring(" ",dgqc_temp_line,dgqc_start_pos),(size(dgqc_temp_line)+ 1)
          )
        ELSE
         dgqc_end_pos = (size(dgqc_temp_line)+ 1)
        ENDIF
        CASE (dgqc_field_num)
         OF 1:
          dmr_queue->cnt = (dmr_queue->cnt+ 1),stat = alterlist(dmr_queue->qual,dmr_queue->cnt),
          dmr_queue->qual[dmr_queue->cnt].entry = cnvtint(substring(dgqc_start_pos,(dgqc_end_pos -
            dgqc_start_pos),dgqc_temp_line))
         OF 2:
          dmr_queue->qual[dmr_queue->cnt].jobname = substring(dgqc_start_pos,(dgqc_end_pos -
           dgqc_start_pos),dgqc_temp_line)
         OF 3:
          dmr_queue->qual[dmr_queue->cnt].username = substring(dgqc_start_pos,(dgqc_end_pos -
           dgqc_start_pos),dgqc_temp_line)
         OF 4:
          dmr_queue->qual[dmr_queue->cnt].status = substring(dgqc_start_pos,(dgqc_end_pos -
           dgqc_start_pos),dgqc_temp_line)
        ENDCASE
        dgqc_start_pos = (dgqc_end_pos+ 1), dgqc_field_num = (dgqc_field_num+ 1)
        IF (dgqc_start_pos >= size(dgqc_temp_line))
         dgqc_continue = 0
        ENDIF
        IF (dgqc_field_num=5)
         dgqc_field_num = 1, dgqc_continue = 0
        ENDIF
      ENDWHILE
     ENDIF
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dmr_queue)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_check_directory(directory)
   IF (get_unique_file("dm2wrtprvtst",".dat")=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Determining if ",directory," is valid with write privs.")
   SELECT INTO value(build(directory,cnvtlower(dm_err->unique_fname)))
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     row + 1, "This is a test of writing to ", directory
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    IF (dm2_push_dcl(concat("DELETE ",directory,cnvtlower(dm_err->unique_fname),";",char(42)))=0)
     RETURN(0)
    ENDIF
   ELSE
    IF (dm2_push_dcl(concat("rm ",directory,cnvtlower(dm_err->unique_fname)))=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_get_unique_file_name(directory,file_prefix,file_suffix)
   DECLARE dgufn_continue = i2 WITH protect, noconstant(1)
   DECLARE dgufn_file_name = vc WITH protect, noconstant("")
   DECLARE dgufn_unique_tempstr = vc WITH protect, noconstant("")
   SET dm_err->eproc = concat("Getting unique file name using directory: ",directory," prefix: ",
    file_prefix," and ext: ",
    file_suffix)
   IF (textlen(concat(file_prefix,file_suffix)) > 24)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Combination of file prefix and extension exceeded length limit of 24."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   WHILE (dgufn_continue=1)
     SET dgufn_unique_tempstr = substring(1,6,cnvtstring((datetimediff(cnvtdatetime(curdate,curtime3),
        cnvtdatetime(curdate,000000)) * 864000)))
     IF (directory > "")
      SET dgufn_file_name = build(directory,file_prefix,dgufn_unique_tempstr,file_suffix)
     ELSE
      SET dgufn_file_name = build(file_prefix,dgufn_unique_tempstr,file_suffix)
     ENDIF
     IF (findfile(dgufn_file_name)=0)
      SET dgufn_continue = 0
      SET dm_err->unique_fname = dgufn_file_name
     ENDIF
   ENDWHILE
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   CALL echo(concat("**Unique filename = ",dm_err->unique_fname))
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_fill_email_list(null)
   SET dm_err->eproc = "Querying for list of email addresses from dm_info."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_MIG_EMAILS"
    ORDER BY di.info_name
    HEAD REPORT
     dmr_emails->change_ind = 0, dmr_emails->cnt = 0, stat = alterlist(dmr_emails->qual,dmr_emails->
      cnt),
     dmr_emails->email_list = ""
    DETAIL
     dmr_emails->cnt = (dmr_emails->cnt+ 1), stat = alterlist(dmr_emails->qual,dmr_emails->cnt),
     dmr_emails->qual[dmr_emails->cnt].email_address = di.info_name
     IF ((dmr_emails->cnt=1))
      dmr_emails->email_list = di.info_name
     ELSE
      dmr_emails->email_list = concat(dmr_emails->email_list,",",di.info_name)
     ENDIF
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_send_email(subject,address_list,file_name)
   IF (((trim(subject)="") OR (((trim(address_list)="") OR (trim(file_name)="")) )) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Verifying input parameters."
    SET dm_err->emsg = "Input parameters can not be blank."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    IF (dm2_push_dcl(concat('MAIL/SUBJECT="',build(subject),'" ',build(file_name),' "',
      build(address_list),'"'))=0)
     RETURN(0)
    ENDIF
   ELSEIF ((dm2_sys_misc->cur_os IN ("AIX", "LNX")))
    IF (dm2_push_dcl(concat('mail -s "',subject,'" "',address_list,'" < ',
      file_name))=0)
     RETURN(0)
    ENDIF
   ELSEIF ((dm2_sys_misc->cur_os="HPX"))
    IF (dm2_push_dcl(concat('mailx -s "',subject,'" "',address_list,'" < ',
      file_name))=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_get_user_list(null)
   SET dm_err->eproc = "Querying for list of users from dm_info."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_MIG_USER"
    ORDER BY di.info_name
    HEAD REPORT
     dmr_user_list->cnt = 0, stat = alterlist(dmr_user_list->qual,0), dmr_user_list->change_ind = 0
    DETAIL
     dmr_user_list->cnt = (dmr_user_list->cnt+ 1), stat = alterlist(dmr_user_list->qual,dmr_user_list
      ->cnt), dmr_user_list->qual[dmr_user_list->cnt].user = di.info_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_verify_v500_user(exists_ind)
   SET dm_err->eproc = "Querying for list of users from dm_info."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_MIG_USER"
     AND di.info_name="V500"
    HEAD REPORT
     exists_ind = 0
    DETAIL
     exists_ind = 1
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_get_gg_dir(null)
   DECLARE dggd_cap_dir = vc WITH protect, noconstant("/ggcapture")
   DECLARE dggd_del_dir = vc WITH protect, noconstant("/ggdelivery")
   SET dmr_mig_data->report_all = 0
   SET dmr_mig_data->report_capture = 0
   SET dmr_mig_data->report_delivery = 0
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dggd_cap_dir = "GGCAPTURE:[000000]"
    SET dggd_del_dir = "GGDELIVERY:[000000]"
   ENDIF
   IF (dm2_find_dir(dggd_cap_dir)=1)
    SET dmr_mig_data->report_capture = 1
   ELSEIF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF (dm2_find_dir(dggd_del_dir)=1)
    SET dmr_mig_data->report_delivery = 1
   ELSEIF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF ((dmr_mig_data->report_delivery=1)
    AND (dmr_mig_data->report_capture=1))
    SET dmr_mig_data->report_all = 1
   ENDIF
   CALL dmr_set_gg_files(dmr_mig_data->report_capture,dmr_mig_data->report_delivery)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_set_gg_files(dsgf_report_capture,dsgf_report_delivery)
   SET dmr_mig_data->cap_dir = "DM2NOTSET"
   SET dmr_mig_data->cap_mgr_rpt = "DM2NOTSET"
   SET dmr_mig_data->cap_rpt = "DM2NOTSET"
   SET dmr_mig_data->cap_err_rpt = "DM2NOTSET"
   SET dmr_mig_data->del_dir = "DM2NOTSET"
   SET dmr_mig_data->del_mgr_rpt = "DM2NOTSET"
   SET dmr_mig_data->del_rpt = "DM2NOTSET"
   SET dmr_mig_data->del_err_rpt = "DM2NOTSET"
   IF ((dm2_sys_misc->cur_os="AXP")
    AND dsgf_report_capture=1)
    SET dmr_mig_data->cap_dir = "GGCAPTURE:[000000]"
    SET dmr_mig_data->cap_mgr_rpt = "GGCAPTURE:[DIRRPT]$MGR.$RPT"
    SET dmr_mig_data->cap_rpt = "GGCAPTURE:[DIRRPT]$CAPTURE.$RPT"
    SET dmr_mig_data->cap_err_rpt = "GGCAPTURE:[000000]GGSERR.LOG"
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP")
    AND dsgf_report_delivery=1)
    SET dmr_mig_data->del_dir = "GGDELIVERY:[000000]"
    SET dmr_mig_data->del_mgr_rpt = "GGDELIVERY:[DIRRPT]$MGR.$RPT"
    SET dmr_mig_data->del_rpt = "GGDELIVERY:[DIRRPT]$DELIVERY.$RPT"
    SET dmr_mig_data->del_err_rpt = "GGDELIVERY:[000000]GGSERR.LOG"
   ENDIF
   IF ((dm2_sys_misc->cur_os IN ("AIX", "HPX", "LNX"))
    AND dsgf_report_capture=1)
    SET dmr_mig_data->cap_dir = "/ggcapture"
    SET dmr_mig_data->cap_mgr_rpt = "/ggcapture/dirrpt/mgr.rpt"
    SET dmr_mig_data->cap_rpt = "/ggcapture/dirrpt/capture.rpt"
    SET dmr_mig_data->cap_err_rpt = "/ggcapture/ggserr.log"
   ENDIF
   IF ((dm2_sys_misc->cur_os IN ("AIX", "HPX", "LNX"))
    AND dsgf_report_delivery=1)
    SET dmr_mig_data->del_dir = "/ggdelivery"
    SET dmr_mig_data->del_mgr_rpt = "/ggdelivery/dirrpt/mgr.rpt"
    SET dmr_mig_data->del_rpt = "/ggdelivery/dirrpt/delivery.rpt"
    SET dmr_mig_data->del_err_rpt = "/ggdelivery/ggserr.log"
   ENDIF
 END ;Subroutine
 SUBROUTINE dmr_directory_prompt(mode)
   DECLARE ddp_dir_acceptable_ind = i2 WITH protect, noconstant(0)
   DECLARE ddp_src_ora_home_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE ddp_tgt_ora_home_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE ddp_src_file_loc_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE ddp_tgt_file_loc_exists_ind = i2 WITH protect, noconstant(0)
   IF ( NOT (dm2_find_dir(evaluate(dm2_sys_misc->cur_os,"AXP","GGDELIVERY:[DIRTMP]",
     "/ggdelivery/dirtmp"))))
    SET dmr_expimp->src_ksh_loc = " "
   ELSE
    SET dmr_expimp->src_ksh_loc = evaluate(dm2_sys_misc->cur_os,"AXP","GGDELIVERY:[DIRTMP]",
     "/ggdelivery/dirtmp")
   ENDIF
   SET dm_err->eproc = "Gathering existing bulk data move rows from dm_info."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_MIG_BULK_DATA_MOVE"
     AND di.info_name IN ("SOURCE_ORACLE_HOME", "TARGET_ORACLE_HOME", "LOCAL_DIR", "TARGET_DB_DIR")
    DETAIL
     CASE (di.info_name)
      OF "SOURCE_ORACLE_HOME":
       dmr_expimp->src_ora_home = di.info_char,ddp_src_ora_home_exists_ind = 1
      OF "TARGET_ORACLE_HOME":
       dmr_expimp->tgt_ora_home = di.info_char,ddp_tgt_ora_home_exists_ind = 1
      OF "LOCAL_DIR":
       dmr_expimp->src_ksh_loc = di.info_char,ddp_src_file_loc_exists_ind = 1
      OF "TARGET_DB_DIR":
       dmr_expimp->tgt_file_loc = di.info_char,ddp_tgt_file_loc_exists_ind = 1
     ENDCASE
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (mode=2)
    RETURN(1)
   ENDIF
   IF ((dmr_mig_data->src_ora_version != dmr_mig_data->tgt_ora_version))
    SET dmr_expimp->diff_ora_version = 1
   ENDIF
   SET dm_err->eproc = "Display Create Export/Import Files Prompts."
   CALL disp_msg("",dm_err->logfile,0)
   SET width = 132
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,24,131)
   CALL text(2,2,"Database Migration Default Directory Locations")
   CALL text(6,2,concat("Oracle Home for Oracle ",trim(cnvtstring(dmr_mig_data->src_ora_level1)),
     " on node ",dmr_mig_data->tgt_nodes[1].node_name))
   CALL text(7,2,concat("(compatible with SOURCE database Oracle ",trim(dmr_mig_data->src_ora_version
      ),"):"))
   CALL accept(7,60,"P(50);C",dmr_expimp->src_ora_home
    WHERE  NOT (curaccept=" "))
   SET dmr_expimp->src_ora_home = trim(curaccept)
   IF (substring(size(dmr_expimp->src_ora_home),1,dmr_expimp->src_ora_home)="/")
    SET dmr_expimp->src_ora_home = replace(dmr_expimp->src_ora_home,"/","",2)
   ENDIF
   IF (ddp_src_ora_home_exists_ind)
    SET dm_err->eproc = "Updating existing SOURCE_ORACLE_HOME row in dm_info."
    UPDATE  FROM dm_info di
     SET di.info_char = dmr_expimp->src_ora_home
     WHERE di.info_domain="DM2_MIG_BULK_DATA_MOVE"
      AND di.info_name="SOURCE_ORACLE_HOME"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->eproc = "Inserting new SOURCE_ORACLE_HOME row into dm_info."
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_MIG_BULK_DATA_MOVE", di.info_name = "SOURCE_ORACLE_HOME", di.info_char
       = dmr_expimp->src_ora_home
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   CALL text(9,2,concat("Oracle Home for Oracle ",trim(cnvtstring(dmr_mig_data->tgt_ora_level1)),
     " on node ",dmr_mig_data->tgt_nodes[1].node_name))
   CALL text(10,2,concat("(compatible with TARGET database Oracle ",trim(dmr_mig_data->
      tgt_ora_version),"):"))
   IF ((dmr_expimp->diff_ora_version=1))
    CALL accept(10,60,"P(50);C",dmr_expimp->tgt_ora_home
     WHERE  NOT (curaccept=" "))
    SET dmr_expimp->tgt_ora_home = trim(curaccept)
    IF (substring(size(dmr_expimp->tgt_ora_home),1,dmr_expimp->tgt_ora_home)="/")
     SET dmr_expimp->tgt_ora_home = replace(dmr_expimp->tgt_ora_home,"/","",2)
    ENDIF
   ELSE
    SET dmr_expimp->tgt_ora_home = dmr_expimp->src_ora_home
    CALL text(10,60,dmr_expimp->tgt_ora_home)
   ENDIF
   IF (ddp_tgt_ora_home_exists_ind)
    SET dm_err->eproc = "Updating existing TARGET_ORACLE_HOME row in dm_info."
    UPDATE  FROM dm_info di
     SET di.info_char = dmr_expimp->tgt_ora_home
     WHERE di.info_domain="DM2_MIG_BULK_DATA_MOVE"
      AND di.info_name="TARGET_ORACLE_HOME"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->eproc = "Inserting new TARGET_ORACLE_HOME row into dm_info."
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_MIG_BULK_DATA_MOVE", di.info_name = "TARGET_ORACLE_HOME", di.info_char
       = dmr_expimp->tgt_ora_home
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   CALL text(12,2,concat("Local Directory Location:"))
   CALL text(13,4,"(where ksh/par files will be created on this node)")
   SET ddp_dir_acceptable_ind = 1
   WHILE (ddp_dir_acceptable_ind)
    IF ((dm2_sys_misc->cur_os="AXP"))
     CALL accept(12,29,"P(60);CU",dmr_expimp->src_ksh_loc
      WHERE curaccept != ""
       AND substring(size(trim(curaccept)),1,trim(curaccept))="]")
    ELSE
     CALL accept(12,29,"P(60);C",dmr_expimp->src_ksh_loc
      WHERE curaccept != ""
       AND substring(1,1,curaccept)="/")
    ENDIF
    IF ((curaccept != dmr_expimp->src_ksh_loc))
     SET dmr_expimp->src_ksh_loc = curaccept
     IF (substring(size(dmr_expimp->src_ksh_loc),1,dmr_expimp->src_ksh_loc)="/")
      SET dmr_expimp->src_ksh_loc = replace(dmr_expimp->src_ksh_loc,"/","",2)
     ENDIF
     IF (dm2_find_dir(dmr_expimp->src_ksh_loc))
      SET ddp_dir_acceptable_ind = 0
      CALL clear(23,1,129)
     ELSE
      CALL text(23,2,"The directory entered does not exist.")
     ENDIF
    ELSE
     SET ddp_dir_acceptable_ind = 0
    ENDIF
   ENDWHILE
   IF (ddp_src_file_loc_exists_ind)
    SET dm_err->eproc = "Updating existing LOCAL_DIR row in dm_info."
    UPDATE  FROM dm_info di
     SET di.info_char = dmr_expimp->src_ksh_loc
     WHERE di.info_domain="DM2_MIG_BULK_DATA_MOVE"
      AND di.info_name="LOCAL_DIR"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->eproc = "Inserting new LOCAL_DIR row into dm_info."
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_MIG_BULK_DATA_MOVE", di.info_name = "LOCAL_DIR", di.info_char =
      dmr_expimp->src_ksh_loc
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   CALL text(15,2,concat("Target Database Node Directory Location:"))
   CALL text(16,4,"(where ksh files will be copied to and executed from)")
   CALL accept(15,44,"P(60);C",dmr_expimp->tgt_file_loc
    WHERE curaccept != ""
     AND substring(1,1,curaccept)="/")
   SET dmr_expimp->tgt_file_loc = curaccept
   IF (substring(size(dmr_expimp->tgt_file_loc),1,dmr_expimp->tgt_file_loc)="/")
    SET dmr_expimp->tgt_file_loc = replace(dmr_expimp->tgt_file_loc,"/","",2)
   ENDIF
   IF (ddp_tgt_file_loc_exists_ind)
    SET dm_err->eproc = "Updating existing TARGET_DB_DIR row in dm_info."
    UPDATE  FROM dm_info di
     SET di.info_char = dmr_expimp->tgt_file_loc
     WHERE di.info_domain="DM2_MIG_BULK_DATA_MOVE"
      AND di.info_name="TARGET_DB_DIR"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->eproc = "Inserting new TARGET_DB_DIR row into dm_info."
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_MIG_BULK_DATA_MOVE", di.info_name = "TARGET_DB_DIR", di.info_char =
      dmr_expimp->tgt_file_loc
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   CALL text(23,2,"Enter 'C' to continue or 'Q' to quit (C or Q): ")
   CALL accept(23,50,"P;CU"," "
    WHERE curaccept IN ("C", "Q"))
   IF (curaccept="Q")
    ROLLBACK
    RETURN(0)
   ELSE
    COMMIT
    SET message = nowindow
    CALL clear(1,1)
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE dmr_setup_batch_queue(dsbq_queue_name)
   DECLARE dsbq_env_name = vc WITH protect, noconstant(" ")
   DECLARE dsbq_cmd = vc WITH protect, noconstant(" ")
   DECLARE dsbq_start_pos = i4 WITH protect, noconstant(0)
   DECLARE dsbq_end_pos = i4 WITH protect, noconstant(0)
   DECLARE dsbq_domain_user = vc WITH protect, noconstant(" ")
   DECLARE dsbq_err_str = vc WITH protect, constant("no such queue")
   DECLARE dsbq_queue_fnd_ret = i2 WITH protect, noconstant(0)
   DECLARE dsbq_job_limit_str = vc WITH protect, noconstant(" ")
   DECLARE dsbq_job_limit = i2 WITH protect, noconstant(1)
   DECLARE dsbq_job_limit_accept = i2 WITH protect, noconstant(0)
   DECLARE dsbq_job_limit_fnd = i2 WITH protect, noconstant(0)
   DECLARE dsbq_temp_line = vc WITH protect, noconstant(" ")
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
   IF (dmr_check_batch_queue(dsbq_queue_name,dsbq_queue_fnd_ret)=0)
    RETURN(0)
   ENDIF
   IF (dsbq_queue_fnd_ret=1)
    SET dsbq_job_limit = 0
    SET dsbq_job_limit_fnd = 0
    IF (dm2_push_dcl(concat("SHOW QUEUE /full ",dsbq_queue_name))=0)
     RETURN(0)
    ENDIF
    FREE DEFINE rtl
    DEFINE rtl build("CCLUSERDIR:",dm_err->errfile)
    SET dm_err->eproc = "Parsing queue contents for job_limit."
    SELECT INTO "nl:"
     r.line
     FROM rtlt r
     DETAIL
      dsbq_temp_line = trim(r.line,3)
      FOR (dgqc_iter = 1 TO 5)
        dsbq_temp_line = replace(dsbq_temp_line,"  "," ",0)
      ENDFOR
      dsbq_start_pos = findstring("JOB_LIMIT",cnvtupper(dsbq_temp_line),1)
      IF (dsbq_start_pos > 0)
       dsbq_job_limit_fnd = 1, dsbq_end_pos = findstring(" ",dsbq_temp_line,dsbq_start_pos)
       IF (dsbq_end_pos > 0)
        dsbq_job_limit_str = trim(substring((dsbq_start_pos+ 10),(dsbq_end_pos - (dsbq_start_pos+ 10)
          ),dsbq_temp_line),3),
        CALL cancel(1)
       ELSE
        dm_err->err_ind = 1, dm_err->emsg = "Failed to parse out job_limit from queue data",
        CALL cancel(1)
       ENDIF
      ENDIF
     WITH nocounter, nullreport
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (((dsbq_job_limit_fnd=0) OR (isnumeric(dsbq_job_limit_str) != 1)) )
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Failed to parse out job_limit for queue data."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     SET dsbq_job_limit = cnvtint(dsbq_job_limit_str)
    ENDIF
   ENDIF
   SET message = window
   SET width = 132
   CALL clear(1,1)
   CALL video(n)
   CALL text(2,1,"Provide a job limit (1-20) for migration batch queue (0 to Quit): ")
   CALL accept(2,67,"99",dsbq_job_limit
    WHERE curaccept BETWEEN 0 AND 20)
   SET dsbq_job_limit_accept = curaccept
   SET message = nowindow
   IF (dsbq_job_limit_accept=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Migration Batch Queue Job Limit Prompt."
    SET dm_err->emsg = "User choose to Quit."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dsbq_queue_fnd_ret=0)
    SET dsbq_cmd = concat(build("init/queue/batch/start/job_limit=",dsbq_job_limit_accept)," ",
     dsbq_queue_name)
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
   ELSEIF (dsbq_queue_fnd_ret=1
    AND dsbq_job_limit_accept != dsbq_job_limit)
    SET dsbq_cmd = concat(build("set queue/job_limit=",dsbq_job_limit_accept)," ",dsbq_queue_name)
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
 SUBROUTINE dmr_check_batch_queue(dcbq_queue_name,dcbq_queue_fnd_ret)
   DECLARE dcbq_env_name = vc WITH protect, noconstant(" ")
   DECLARE dcbq_cmd = vc WITH protect, noconstant(" ")
   DECLARE dcbq_start_pos = i4 WITH protect, noconstant(0)
   DECLARE dcbq_end_pos = i4 WITH protect, noconstant(0)
   DECLARE dcbq_domain_user = vc WITH protect, noconstant(" ")
   DECLARE dcbq_err_str = vc WITH protect, constant("no such queue")
   SET dcbq_queue_fnd_ret = 0
   IF ((dm2_sys_misc->cur_os != "AXP"))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating current operating system is AXP."
    SET dm_err->emsg = "Invalid current operating system."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((dcbq_queue_name=" ") OR (dcbq_queue_name="")) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating input batch queue name."
    SET dm_err->emsg = "Invalid batch queue name."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dcbq_cmd = concat("sho queue /full ",dcbq_queue_name)
   SET dm_err->disp_dcl_err_ind = 0
   IF (dm2_push_dcl(dcbq_cmd)=0)
    IF ((dm_err->err_ind=1))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   IF (findstring(dcbq_err_str,cnvtlower(dm_err->errtext),1,0) > 0)
    SET dcbq_queue_fnd_ret = 0
   ELSEIF (findstring(cnvtlower(dcbq_queue_name),cnvtlower(dm_err->errtext),1,0)=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Determining if queue ",dcbq_queue_name," exists.")
    SET dm_err->emsg = dm_err->errtext
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    SET dcbq_queue_fnd_ret = 1
   ENDIF
   IF (dcbq_queue_fnd_ret=1)
    IF (findstring("idle",cnvtlower(dm_err->errtext),1,0)=0
     AND findstring("executing",cnvtlower(dm_err->errtext),1,0)=0)
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Make sure queue ",dcbq_queue_name,
      " is idle or is currently executing jobs.")
     SET dm_err->emsg = dm_err->errtext
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_validate_src_and_tgt(dvst_src_ind,dvst_tgt_ind)
   DECLARE dvsat_db = vc WITH protect, noconstant("")
   DECLARE dvsat_cnt = i4 WITH protect, noconstant(0)
   DECLARE dvsat_str = vc WITH protect, noconstant("")
   IF (dvst_src_ind=1)
    IF (dmr_prompt_connect_data("SOURCE","V500","PC")=0)
     RETURN(0)
    ENDIF
    SET dvsat_db = "SOURCE"
    IF (dmr_get_db_info(dmr_mig_data->src_db_name,dmr_mig_data->src_created_date)=0)
     RETURN(0)
    ENDIF
    SET dmr_mig_data->src_db_os = dm2_sys_misc->cur_db_os
    IF (dm2_get_rdbms_version(null)=0)
     RETURN(0)
    ENDIF
    SET dmr_mig_data->src_ora_version = dm2_rdbms_version->version
    SET dmr_mig_data->src_ora_level1 = dm2_rdbms_version->level1
    SET dmr_mig_data->src_ora_level2 = dm2_rdbms_version->level2
    SET dmr_mig_data->src_ora_level3 = dm2_rdbms_version->level3
    SET dmr_mig_data->src_ora_level4 = dm2_rdbms_version->level4
    SET dvsat_str = ""
    IF (dmr_get_storage_type(dvsat_str)=0)
     RETURN(0)
    ENDIF
    SET dmr_mig_data->src_storage_type = dvsat_str
    IF (dmr_get_node_name(null)=0)
     RETURN(0)
    ENDIF
    SET dmr_mig_data->src_node_cnt = dmr_node->cnt
    SET stat = alterlist(dmr_mig_data->src_nodes,dmr_node->cnt)
    FOR (dvsat_cnt = 1 TO dmr_node->cnt)
      SET dmr_mig_data->src_nodes[dvsat_cnt].node_name = cnvtlower(dmr_node->qual[dvsat_cnt].
       node_name)
      SET dmr_mig_data->src_nodes[dvsat_cnt].instance_number = dmr_node->qual[dvsat_cnt].
      instance_number
      SET dmr_mig_data->src_nodes[dvsat_cnt].instance_name = cnvtlower(dmr_node->qual[dvsat_cnt].
       instance_name)
    ENDFOR
   ENDIF
   IF (dvst_tgt_ind=1)
    IF (dmr_prompt_connect_data("TARGET","V500","PC")=0)
     RETURN(0)
    ENDIF
    SET dvsat_db = "TARGET"
    SET dm_err->eproc = "Get databse name and created date"
    IF (dmr_get_db_info(dmr_mig_data->tgt_db_name,dmr_mig_data->tgt_created_date)=0)
     RETURN(0)
    ENDIF
    SET dmr_mig_data->tgt_db_os = dm2_sys_misc->cur_db_os
    IF (dm2_get_rdbms_version(null)=0)
     RETURN(0)
    ENDIF
    SET dmr_mig_data->tgt_ora_version = dm2_rdbms_version->version
    SET dmr_mig_data->tgt_ora_level1 = dm2_rdbms_version->level1
    SET dmr_mig_data->tgt_ora_level2 = dm2_rdbms_version->level2
    SET dmr_mig_data->tgt_ora_level3 = dm2_rdbms_version->level3
    SET dmr_mig_data->tgt_ora_level4 = dm2_rdbms_version->level4
    SET dvsat_str = ""
    IF (dmr_get_storage_type(dvsat_str)=0)
     RETURN(0)
    ENDIF
    SET dmr_mig_data->tgt_storage_type = dvsat_str
    IF (dmr_get_node_name(null)=0)
     RETURN(0)
    ENDIF
    SET dmr_mig_data->tgt_node_cnt = dmr_node->cnt
    SET stat = alterlist(dmr_mig_data->tgt_nodes,dmr_node->cnt)
    FOR (dvsat_cnt = 1 TO dmr_node->cnt)
      SET dmr_mig_data->tgt_nodes[dvsat_cnt].node_name = cnvtlower(dmr_node->qual[dvsat_cnt].
       node_name)
      SET dmr_mig_data->tgt_nodes[dvsat_cnt].instance_number = dmr_node->qual[dvsat_cnt].
      instance_number
      SET dmr_mig_data->tgt_nodes[dvsat_cnt].instance_name = cnvtlower(dmr_node->qual[dvsat_cnt].
       instance_name)
    ENDFOR
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dmr_mig_data)
   ENDIF
   IF (dmr_issue_summary_screen(dvst_src_ind,dvst_tgt_ind,"")=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_stop_job(job_type,job_mode)
   DECLARE dsj_found_ind = i2 WITH protect, noconstant(0)
   DECLARE dsj_iter = i4 WITH protect, noconstant(0)
   DECLARE dsj_info_name = vc WITH protect, noconstant("")
   IF ((dm_err->debug_flag=722))
    CALL echorecord(dmr_mig_data)
   ENDIF
   IF ((((dmr_mig_data->report_all=1)) OR ((dmr_mig_data->report_capture=1))) )
    SET dsj_info_name = "STOP_CAPTURE_MONITORING"
   ELSEIF ((dmr_mig_data->report_delivery=1))
    SET dsj_info_name = "STOP_DELIVERY_MONITORING"
   ELSE
    IF (job_mode=1)
     SET message = nowindow
    ENDIF
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Checking execution status"
    SET dm_err->emsg = "GGDELIVERY or GGCAPTURE do not exist. Unable to stop job."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    IF (dmr_get_queue_contents(dmr_batch_queue)=0)
     RETURN(0)
    ENDIF
    FOR (dsj_iter = 1 TO dmr_queue->cnt)
      IF ((dmr_queue->qual[dsj_iter].jobname=evaluate(job_type,"ARCH","DM2_MIG_COPY_ARCHIVELOGS",
       "MON","DM2_MIG_MONITORING")))
       SET dsj_found_ind = 1
      ENDIF
    ENDFOR
   ELSE
    IF (dm2_push_dcl("ps -ef | grep dm2_mig_monitoring.ksh")=0)
     RETURN(0)
    ENDIF
    FREE DEFINE rtl
    DEFINE rtl build("CCLUSERDIR:",dm_err->errfile)
    SET dm_err->eproc = "Determining if there were any results obtainted from the ps command."
    SELECT INTO "nl:"
     FROM rtlt r
     DETAIL
      IF (trim(r.line,3) != "* grep *")
       dsj_found_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dsj_found_ind)
    SET dm_err->eproc = concat("Determining if STOP row exists for ",job_type," from dm_info.")
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DM2_MIG_DATA"
      AND di.info_name=value(evaluate(job_type,"ARCH","STOP_ARCHIVE_COPY","MON",dsj_info_name))
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET dm_err->eproc = concat("Inserting STOP row for ",job_type," into dm_info.")
     INSERT  FROM dm_info di
      SET di.info_domain = "DM2_MIG_DATA", di.info_name = value(evaluate(job_type,"ARCH",
         "STOP_ARCHIVE_COPY","MON",dsj_info_name))
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     COMMIT
    ENDIF
    IF (job_mode=1)
     CALL text(21,10,
      "The job has been marked for deletion. Please monitor with Status of Job menu option. Press <enter> to continue."
      )
     CALL accept(21,122,"A;CH"," ")
     CALL clear(21,2,129)
    ENDIF
   ELSE
    IF (job_mode=1)
     CALL text(21,10,"No matching jobs were found.  Press <enter> to continue.")
     CALL accept(21,67,"A;CH"," ")
     CALL clear(21,2,129)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_get_storage_type(dgst_storage_ret)
  IF ((dm2_sys_misc->cur_db_os="AXP"))
   SET dgst_storage_ret = "AXP"
  ELSE
   SET dm_err->eproc = "Determine target storage type from dba_data_files"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_data_files ddf
    WHERE ddf.tablespace_name="SYSTEM"
     AND ddf.file_name=patstring("/dev/*")
    DETAIL
     dgst_storage_ret = "RAW"
    WITH nocounter, maxqual = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dgst_storage_ret = "ASM"
   ENDIF
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_load_managed_tables(dlmt_mng_ret)
   DECLARE dlmt_dm_info_exists = i2 WITH protect, noconstant(0)
   SET dlmt_mng_ret = "'DM_STAT_TABLE','PLAN_TABLE','DM_CONSTRAINT_EXCEPTIONS'"
   IF (dm2_table_and_ccldef_exists("DM_INFO",dlmt_dm_info_exists)=0)
    RETURN(0)
   ENDIF
   IF (dlmt_dm_info_exists=1)
    SET dm_err->eproc = "Loading list of managed tables from dm_info."
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DM2_MIGRATION"
      AND di.info_name="MANAGED TABLES"
     DETAIL
      dlmt_mng_ret = di.info_char
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_mig_setup_gg_dir(null)
   DECLARE dmsgd_gg_cap_dir_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE dmsgd_gg_del_dir_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE dmsgd_gg_cap_loc = vc WITH protect, noconstant("")
   DECLARE dmsgd_gg_del_loc = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Determining if Directory setup row already exists in dm_info."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_MIG_GG_DATA"
     AND di.info_name IN ("GG_CAP_DIR", "GG_DEL_DIR")
    DETAIL
     IF (di.info_name="GG_CAP_DIR")
      dmsgd_gg_cap_loc = di.info_char, dmsgd_gg_cap_dir_exists_ind = 1
     ELSE
      dmsgd_gg_del_loc = di.info_char, dmsgd_gg_del_dir_exists_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET width = 132
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,24,131)
   CALL text(2,2,"Database Migration Capture/Delivery Directory Locations")
   CALL text(6,2,concat("Capture Directory Location:"))
   IF ((dm2_sys_misc->cur_os="AXP"))
    CALL accept(6,29,"P(90);CU",dmsgd_gg_cap_loc
     WHERE curaccept != ""
      AND substring(size(trim(curaccept)),1,trim(curaccept))="]")
   ELSE
    CALL accept(6,29,"P(90);C",dmsgd_gg_cap_loc
     WHERE curaccept != ""
      AND substring(1,1,curaccept)="/")
   ENDIF
   SET dmsgd_gg_cap_loc = curaccept
   IF (substring(size(dmsgd_gg_cap_loc),1,dmsgd_gg_cap_loc)="/")
    SET dmsgd_gg_cap_loc = trim(replace(dmsgd_gg_cap_loc,"/","",2),3)
   ENDIF
   IF (dmsgd_gg_cap_dir_exists_ind)
    SET dm_err->eproc = "Updating existing Capture DIR row in dm_info."
    UPDATE  FROM dm_info di
     SET di.info_char = dmsgd_gg_cap_loc
     WHERE di.info_domain="DM2_MIG_GG_DATA"
      AND di.info_name="GG_CAP_DIR"
     WITH nocounter
    ;end update
   ELSE
    SET dm_err->eproc = "Inserting new Capture DIR row into dm_info."
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_MIG_GG_DATA", di.info_name = "GG_CAP_DIR", di.info_char =
      dmsgd_gg_cap_loc
     WITH nocounter
    ;end insert
   ENDIF
   IF (check_error(dm_err->eproc))
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   COMMIT
   CALL text(8,2,concat("Delivery Directory Location:"))
   IF ((dm2_sys_misc->cur_os="AXP"))
    CALL accept(8,30,"P(90);CU",dmsgd_gg_del_loc
     WHERE curaccept != ""
      AND substring(size(trim(curaccept)),1,trim(curaccept))="]")
   ELSE
    CALL accept(8,30,"P(90);C",dmsgd_gg_del_loc
     WHERE curaccept != ""
      AND substring(1,1,curaccept)="/")
   ENDIF
   SET dmsgd_gg_del_loc = curaccept
   IF (substring(size(dmsgd_gg_del_loc),1,dmsgd_gg_del_loc)="/")
    SET dmsgd_gg_del_loc = trim(replace(dmsgd_gg_del_loc,"/","",2),3)
   ENDIF
   IF (dmsgd_gg_del_dir_exists_ind)
    SET dm_err->eproc = "Updating existing Delivery DIR row in dm_info."
    UPDATE  FROM dm_info di
     SET di.info_char = dmsgd_gg_del_loc
     WHERE di.info_domain="DM2_MIG_GG_DATA"
      AND di.info_name="GG_DEL_DIR"
     WITH nocounter
    ;end update
   ELSE
    SET dm_err->eproc = "Inserting new Delivery DIR row into dm_info."
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_MIG_GG_DATA", di.info_name = "GG_DEL_DIR", di.info_char =
      dmsgd_gg_del_loc
     WITH nocounter
    ;end insert
   ENDIF
   IF (check_error(dm_err->eproc))
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_load_di_filter(null)
   DECLARE dldf_cnt = i4 WITH protect, noconstant(0)
   SET dldf_cnt = 0
   SET dmr_di_filter->cnt = 19
   SET stat = alterlist(dmr_di_filter->qual,dmr_di_filter->cnt)
   SET dmr_di_filter->qual[1].name = "STATS LOCK"
   SET dmr_di_filter->qual[2].name = "QUEUE DBSTATS LOCK"
   SET dmr_di_filter->qual[3].name = "FREQUENT STATS GATHER LOCK"
   SET dmr_di_filter->qual[4].name = "DM2_DBSTATS_ADJUSTMENT"
   SET dmr_di_filter->qual[5].name = "DM_HIGHLOW_MOD"
   SET dmr_di_filter->qual[6].name = "DM_HIGHLOW_MOD_HISTOGRAM"
   SET dmr_di_filter->qual[7].name = "DM2 INSTALL PROCESS"
   SET dmr_di_filter->qual[8].name = "DM2_UTC_SCHEMA_RUNNER"
   SET dmr_di_filter->qual[9].name = "DM2_MIG_DI_FILTER"
   SET dmr_di_filter->qual[10].name = "DM2_BACKGROUND_RUNNER"
   SET dmr_di_filter->qual[11].name = "DM2_INSTALL_RUNNER"
   SET dmr_di_filter->qual[12].name = "DM2_SCHEMA_RUNNER"
   SET dmr_di_filter->qual[13].name = "DM2_README_RUNNER"
   SET dmr_di_filter->qual[14].name = "DM2_SET_READY_TO_RUN"
   SET dmr_di_filter->qual[15].name = "DM2_INSTALL_PKG"
   SET dmr_di_filter->qual[16].name = "DM2_INSTALL_MONITOR"
   SET dmr_di_filter->qual[17].name = "DM2_FLEX_SCHED_USAGE"
   SET dmr_di_filter->qual[18].name = "DM2GDBS%"
   SET dmr_di_filter->qual[19].name = "DM2_MIG_STATUS_MARKER"
   SET dm_err->eproc = "Remove DM_INFO info name filter rows."
   CALL disp_msg("",dm_err->logfile,0)
   DELETE  FROM dm_info di
    WHERE di.info_domain="DM2_MIG_DI_FILTER"
     AND expand(dldf_cnt,1,dmr_di_filter->cnt,di.info_name,dmr_di_filter->qual[dldf_cnt].name)
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Add DM_INFO info name filter rows."
   CALL disp_msg("",dm_err->logfile,0)
   INSERT  FROM dm_info di,
     (dummyt d  WITH seq = value(size(dmr_di_filter->qual,5)))
    SET di.info_domain = "DM2_MIG_DI_FILTER", di.info_name = dmr_di_filter->qual[d.seq].name, di
     .updt_dt_tm = cnvtdatetime(curdate,curtime3)
    PLAN (d
     WHERE d.seq > 0)
     JOIN (di)
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_get_di_filter(null)
   DECLARE dgdf_fail_ind = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Get DM_INFO info name filter rows."
   CALL disp_msg("",dm_err->logfile,0)
   SET dmr_di_filter->cnt = 0
   SET stat = alterlist(dmr_di_filter->qual,dmr_di_filter->cnt)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_MIG_DI_FILTER"
    DETAIL
     IF (findstring("%",di.info_name,1,0) > 0)
      IF (((findstring("%",di.info_name,1,0) != findstring("%",di.info_name,1,1)) OR (findstring(
       "%",di.info_name,1,0) != size(trim(di.info_name)))) )
       dgdf_fail_ind = 1
      ENDIF
     ENDIF
     dmr_di_filter->cnt = (dmr_di_filter->cnt+ 1), stat = alterlist(dmr_di_filter->qual,dmr_di_filter
      ->cnt), dmr_di_filter->qual[dmr_di_filter->cnt].name = di.info_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dgdf_fail_ind=1)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid name value."
    SET dm_err->eproc = "Verify DM_INFO filter rows."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dmr_di_filter->cnt=0))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("No DM_INFO filter rows found.")
    SET dm_err->eproc = "Verify DM_INFO filter rows."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_create_di_macro(dcdm_in_dir,dcdm_gg_version)
   DECLARE dcdm_fname = vc WITH protect, noconstant("")
   DECLARE dcdm_parm_loc = vc WITH protect, noconstant("")
   DECLARE dmuss_locndx = i4 WITH protect, noconstant(0)
   DECLARE dcdm_name = vc WITH protect, noconstant("")
   DECLARE dcdm_cmd = vc WITH protect, noconstant("")
   DECLARE dcdm_delim = vc WITH protect, noconstant("")
   IF (dcdm_gg_version > 11)
    SET dcdm_delim = "'"
   ELSE
    SET dcdm_delim = '"'
   ENDIF
   SET dm_err->eproc = "Create DM_INFO delivery filter macro."
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dmr_di_filter->cnt=0))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("No DM_INFO filter rows found.")
    SET dm_err->eproc = "Verify DM_INFO filter rows."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(dmr_di_filter)
   ENDIF
   SET dcdm_parm_loc = dcdm_in_dir
   IF (dm2_find_dir(dcdm_parm_loc)=0)
    SET message = window
    CALL clear(1,1)
    CALL box(1,1,15,120)
    CALL text(3,2,"Enter Delivery parameter file directory location :")
    CALL accept(3,70,"P(30);C",dcdm_parm_loc
     WHERE curaccept != "")
    SET dcdm_parm_loc = trim(curaccept)
    SET message = nowindow
   ENDIF
   IF (dm2_find_dir(dcdm_parm_loc)=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Delivery parm directory entered [",dcdm_parm_loc,"] does not exist.")
    SET dm_err->eproc = "Verify delivery parm directory exists."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (substring(size(dcdm_parm_loc),1,dcdm_parm_loc) != "/")
    SET dcdm_parm_loc = concat(trim(dcdm_parm_loc),"/")
   ENDIF
   SET dcdm_fname = concat(trim(dcdm_parm_loc),"difilter.mac")
   SELECT INTO value(dcdm_fname)
    FROM (dummyt d  WITH d.seq = 1)
    DETAIL
     col 0,
     CALL print("MACRO #difilter"), row + 1,
     col 0,
     CALL print("BEGIN"), row + 1,
     col 0,
     CALL print("FILTER ( &"), row + 1
     FOR (dmuss_locndx = 1 TO dmr_di_filter->cnt)
       IF (dmuss_locndx=1)
        dcdm_cmd = "      ("
       ELSE
        dcdm_cmd = "  AND ("
       ENDIF
       IF (findstring("%",dmr_di_filter->qual[dmuss_locndx].name) > 0)
        dcdm_name = trim(replace(dmr_di_filter->qual[dmuss_locndx].name,"%","")), dcdm_cmd = concat(
         dcdm_cmd,"@STRNCMP(INFO_DOMAIN, ",dcdm_delim,dcdm_name,dcdm_delim,
         ", ",trim(cnvtstring(size(dcdm_name))),") <> 0) &")
       ELSE
        dcdm_name = trim(dmr_di_filter->qual[dmuss_locndx].name), dcdm_cmd = concat(dcdm_cmd,
         "@STRCMP (INFO_DOMAIN, ",dcdm_delim,dcdm_name,dcdm_delim,
         ") <> 0) &")
       ENDIF
       col 0,
       CALL print(dcdm_cmd), row + 1
     ENDFOR
     col 0,
     CALL print(")"), row + 1,
     col 0,
     CALL print("END;"), row + 1
    WITH nocounter, maxrow = 1, format = lfstream,
     noformfeed, maxcol = 2000
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
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
 FREE RECORD dvdr2_rpt_s1
 RECORD dvdr2_rpt_s1(
   1 cnt = i4
   1 pct_of_ttl = f8
   1 tbls[*]
     2 owner_name = vc
     2 table_name = vc
     2 message_txt = vc
 )
 FREE RECORD dvdr2_rpt_s2
 RECORD dvdr2_rpt_s2(
   1 cnt = i4
   1 pct_of_ttl = f8
   1 tbls[*]
     2 owner_name = vc
     2 table_name = vc
     2 consec_mm_cnt = i4
     2 row_id_txt = vc
     2 row_updt_dt_tm = dq8
     2 max_lag_dt_tm = dq8
     2 compare_dt_tm = dq8
 )
 FREE RECORD dvdr2_rpt_s3
 RECORD dvdr2_rpt_s3(
   1 cnt = i4
   1 pct_of_ttl = f8
   1 tbls[*]
     2 owner_name = vc
     2 table_name = vc
     2 consec_mm_cnt = i4
     2 mm_pull_key_from_src_ind = i2
     2 row_id_txt = vc
     2 max_lag_dt_tm = dq8
     2 compare_dt_tm = dq8
 )
 FREE RECORD dvdr2_rpt_s4
 RECORD dvdr2_rpt_s4(
   1 cnt = i4
   1 pct_of_ttl = f8
   1 tbls[*]
     2 owner_name = vc
     2 table_name = vc
     2 consec_mm_cnt = i4
     2 row_id_txt = vc
     2 row_updt_dt_tm = dq8
     2 max_lag_dt_tm = dq8
     2 compare_dt_tm = dq8
 )
 FREE RECORD dvdr2_rpt_s5
 RECORD dvdr2_rpt_s5(
   1 cnt = i4
   1 pct_of_ttl = f8
   1 tbls[*]
     2 owner_name = vc
     2 table_name = vc
     2 compare_dt_tm = dq8
 )
 FREE RECORD dvdr2_rpt_s6
 RECORD dvdr2_rpt_s6(
   1 cnt = i4
   1 pct_of_ttl = f8
   1 tbls[*]
     2 owner_name = vc
     2 table_name = vc
     2 compare_dt_tm = dq8
 )
 FREE RECORD dvdr2_rpt_s7
 RECORD dvdr2_rpt_s7(
   1 cnt = i4
   1 pct_of_ttl = f8
   1 table_list = vc
   1 tbls[*]
     2 owner_name = vc
     2 table_name = vc
 )
 DECLARE dvdr2_load_vdata(null) = i2
 DECLARE dvdr2_load_vdata_final(null) = i2
 DECLARE dvdr2_cnt = i4 WITH protect, noconstant(0)
 DECLARE dvdr2_rpt_file = vc WITH protect, noconstant("")
 DECLARE dvdr2_final_row_ind = i2 WITH protect, noconstant(0)
 DECLARE dvdr2_total_table_cnt = i4 WITH protect, noconstant(0)
 DECLARE dvdr2_lag_offset = f8 WITH protect, noconstant(240.0)
 DECLARE dvdr2_star_132 = vc WITH protect, constant(fillstring(132,"*"))
 DECLARE dvdr2_dash_132 = vc WITH protect, constant(fillstring(132,"-"))
 DECLARE dvdr2_dash_45 = vc WITH protect, constant(fillstring(45,"-"))
 DECLARE dvdr2_dash_60 = vc WITH protect, constant(fillstring(60,"-"))
 DECLARE dvdr2_txn_excl_ind = i2 WITH protect, noconstant(0)
 DECLARE dvdr2_txn_1hr_ind = i2 WITH protect, noconstant(0)
 DECLARE dvdr2_job_status = vc WITH protect, noconstant("")
 DECLARE dvdr2_job_fail_cnt = i4 WITH protect, noconstant(0)
 DECLARE dvdr2_job_status_t = vc WITH protect, noconstant("")
 DECLARE dvdr2_job_fail_cnt_t = i4 WITH protect, noconstant(0)
 DECLARE dvdr2_job_last_run_t = dq8
 DECLARE dvdr2_job_next_run_t = dq8
 DECLARE dvdr2_job_last_run = vc WITH protect, noconstant("")
 DECLARE dvdr2_job_next_run = vc WITH protect, noconstant("")
 DECLARE dvdr2_nanos_dt = vc WITH protect, noconstant("")
 DECLARE dvdr2_curr_time = dq8
 DECLARE dvdr2_nano_time = dq8
 DECLARE dvdr2_diff_time = i4 WITH protect, noconstant(0)
 IF (check_logfile("dm2_vdata_rpt2",".log","dm2_vdata_rpt2 LOGFILE")=0)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Obtaining Verify Data Reporting Information"
 CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
 IF (dvdr_get_vdata_rpt_env_info(null)=0)
  GO TO exit_script
 ENDIF
 IF ((((dvdr_rpt_dtl_info->src_db_name="DM2NOTSET")) OR ((dvdr_rpt_dtl_info->tgt_db_name="DM2NOTSET")
 )) )
  SET dm_err->err_ind = 1
  SET dm_err->emsg =
  "No valid verification data was returned. Make sure that user is connected to target DB"
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Check for final row in DM_INFO"
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="DATABASE MIGRATION"
   AND d.info_name="FINAL TRANSACTION"
   AND d.updt_applctx=722
  DETAIL
   dvdr_rpt_dtl_info->final_row_dt_tm = cnvtdatetime(d.updt_dt_tm)
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF (curqual > 0)
  SET dvdr2_final_row_ind = 1
  SET dm_err->eproc = "Final transaction row located."
  CALL disp_msg("",dm_err->logfile,0)
 ENDIF
 SET dm_err->eproc = "Getting Migration Owner list from DM_INFO."
 CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DM2_VDATA_INFO"
   AND di.info_name="DM2_VDATA_USERLIST"
  DETAIL
   dvdr_rpt_dtl_info->num_owners = di.info_number, dvdr_rpt_dtl_info->owners_list = di.info_char
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc))
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Getting Cycle Time Data from DM_VDATA_MASTER"
 CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
 SELECT INTO "nl:"
  xmin = min(dvm.last_compare_dt_tm), xmax = max(dvm.last_compare_dt_tm)
  FROM dm_vdata_master dvm
  WHERE dvm.compare_status IN (dvdr_match, dvdr_mismatch)
  FOOT REPORT
   dvdr_rpt_dtl_info->comp_dt_min = xmin, dvdr_rpt_dtl_info->comp_dt_max = xmax
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc))
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Obtaining Lag offset override"
 CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="DM2_VDATA_INFO"
   AND d.info_name="COMPARE GG LAG OFFSET"
  DETAIL
   dvdr2_lag_offset = d.info_number
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc))
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF (dvdr2_final_row_ind=0)
  IF (dvdr2_load_vdata(null)=0)
   GO TO exit_script
  ENDIF
 ELSE
  IF (dvdr2_load_vdata_final(null)=0)
   GO TO exit_script
  ENDIF
 ENDIF
 SET dvdr2_total_table_cnt = ((((dvdr2_rpt_s2->cnt+ dvdr2_rpt_s3->cnt)+ dvdr2_rpt_s4->cnt)+
 dvdr2_rpt_s5->cnt)+ dvdr2_rpt_s6->cnt)
 IF (dvdr2_total_table_cnt > 0)
  CALL echo("Calculating pcts...")
  SET dvdr2_rpt_s2->pct_of_ttl = ((cnvtreal(dvdr2_rpt_s2->cnt)/ cnvtreal(dvdr2_total_table_cnt)) *
  100)
  SET dvdr2_rpt_s3->pct_of_ttl = ((cnvtreal(dvdr2_rpt_s3->cnt)/ cnvtreal(dvdr2_total_table_cnt)) *
  100)
  SET dvdr2_rpt_s4->pct_of_ttl = ((cnvtreal(dvdr2_rpt_s4->cnt)/ cnvtreal(dvdr2_total_table_cnt)) *
  100)
  SET dvdr2_rpt_s5->pct_of_ttl = ((cnvtreal(dvdr2_rpt_s5->cnt)/ cnvtreal(dvdr2_total_table_cnt)) *
  100)
  SET dvdr2_rpt_s6->pct_of_ttl = ((cnvtreal(dvdr2_rpt_s6->cnt)/ cnvtreal(dvdr2_total_table_cnt)) *
  100)
 ELSE
  CALL echo("Defaulting pcts to 0.0  ...")
  SET dvdr2_rpt_s1->pct_of_ttl = 0.0
  SET dvdr2_rpt_s2->pct_of_ttl = 0.0
  SET dvdr2_rpt_s3->pct_of_ttl = 0.0
  SET dvdr2_rpt_s4->pct_of_ttl = 0.0
  SET dvdr2_rpt_s5->pct_of_ttl = 0.0
  SET dvdr2_rpt_s6->pct_of_ttl = 0.0
 ENDIF
 IF ((dm_err->debug_flag=511))
  CALL echo("************Record structure data***************")
  CALL echo(build("dvdr2_final_row_ind:",dvdr2_final_row_ind))
  CALL echorecord(dvdr_rpt_dtl_info)
  CALL echo(build("dvdr2_total_table_cnt:",dvdr2_total_table_cnt))
  CALL echorecord(dvdr2_rpt_s1)
  CALL echorecord(dvdr2_rpt_s2)
  CALL echorecord(dvdr2_rpt_s3)
  CALL echorecord(dvdr2_rpt_s4)
  CALL echorecord(dvdr2_rpt_s5)
  CALL echorecord(dvdr2_rpt_s6)
  CALL echorecord(dvdr2_rpt_s7)
 ENDIF
 SET dm_err->eproc = "Check for EXCLUDE_DM_TXN_TRACKING row in DM_INFO"
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="DM2_MIG_DTT_EXCL"
   AND d.info_name="EXCLUDE_DM_TXN_TRACKING"
   AND d.info_number=1
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF (curqual > 0)
  SET dvdr2_txn_excl_ind = 1
  SET dm_err->eproc = "Exclude TXN tracking row located."
  CALL disp_msg("",dm_err->logfile,0)
 ENDIF
 IF (dvdr2_txn_excl_ind=0)
  SET dm_err->eproc = "Determining nanos date from dm_info"
  SELECT INTO "nl:"
   FROM dm_info d
   WHERE info_domain="DM2_MIG_INS_DTT"
    AND info_name="RANGE_MAX"
   DETAIL
    dvdr2_nanos_dt = d.info_char
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  SET dvdr2_curr_time = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3))
  SET dvdr2_nano_time = cnvtdatetimeutc3(dvdr2_nanos_dt,"MM-DD-YYYY HH:MM:SS")
  SET dvdr2_diff_time = datetimediff(dvdr2_curr_time,dvdr2_nano_time,5)
  IF (dvdr2_diff_time > 60)
   SET dvdr2_txn_1hr_ind = 1
  ENDIF
  IF (dvdr2_txn_1hr_ind=1)
   SET dm_err->eproc = "Determining values for DM2MIGJ_INS_DTT scheduler jobs."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO noforms
    p.*
    FROM (
     (
     (SELECT
      dvdr2_job_last_run_t = sqlpassthru(
       "nvl(to_char(d.last_start_date,'mm/dd/yyyy hh24:mi:ss'),'01/01/1900 00:00:00')"),
      dvdr2_job_next_run_t = sqlpassthru(
       "nvl(to_char(d.next_run_date,'mm/dd/yyyy hh24:mi:ss'),'01/01/1900 00:00:00')"),
      dvdr2_job_status_t = d.state,
      dvdr2_job_fail_cnt_t = d.failure_count
      FROM dba_scheduler_jobs d
      WHERE d.job_name="DM2MIGJ_INS_DTT"
       AND d.owner="V500"
      WITH sqltype("C30","C30","vc","i4")))
     p)
    DETAIL
     dvdr2_job_last_run = p.dvdr2_job_last_run_t, dvdr2_job_next_run = p.dvdr2_job_next_run_t,
     dvdr2_job_status = p.dvdr2_job_status_t,
     dvdr2_job_fail_cnt = p.dvdr2_job_fail_cnt_t
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET dm_err->eproc = "Generating Data Verification Summary Report"
 CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
 IF (get_unique_file("dm2_vdata_rpt2a",".rpt")=0)
  GO TO exit_script
 ELSE
  SET dvdr2_rpt_file = dm_err->unique_fname
 ENDIF
 SELECT INTO value(dvdr2_rpt_file)
  FROM dummyt d
  HEAD REPORT
   row + 1,
   CALL print(concat("Data Verification Summary Report as of ",format(cnvtdatetime(curdate,curtime3),
     "DD-MMM-YY HH:MM:SS;;D"))), row + 1,
   row + 1, "Row matching was performed for tables between:", row + 1,
   CALL print(concat("  Source Database: ",dvdr_rpt_dtl_info->src_db_name,"@",dvdr_rpt_dtl_info->
    db_link)), row + 1,
   CALL print(concat("  Target Database: ",dvdr_rpt_dtl_info->tgt_db_name)),
   row + 2, col 0, "Owners Compared: ",
   col 19,
   CALL print(concat(trim(cnvtstring(dvdr_rpt_dtl_info->num_owners))," --> ",dvdr_rpt_dtl_info->
    owners_list)), row + 1,
   row + 1
   IF (dvdr2_txn_excl_ind=0
    AND dvdr2_txn_1hr_ind=1)
    col 0, "DM_TXN_TRACKING Replication:", row + 1,
    CALL print(dvdr2_dash_45), row + 1, col 0,
    "INVESTIGATION REQUIRED", row + 1, col 0,
    "DM2MIGJ_INS_DTT - Status:", col 27,
    CALL print(dvdr2_job_status),
    col 58, "Job Failures:", col 80,
    CALL print(dvdr2_job_fail_cnt), row + 1, col 0,
    "Last Run:", col 27,
    CALL print(dvdr2_job_last_run),
    col 58, "Last Date Processed:", col 80,
    CALL print(dvdr2_nanos_dt), row + 1, col 0,
    "Next Run:", col 27,
    CALL print(dvdr2_job_next_run),
    row + 1, row + 1
   ENDIF
   CALL print(dvdr2_star_132), row + 1, col 0,
   "COMPARE STATISTICS:", row + 1,
   CALL print(dvdr2_star_132),
   row + 1
   IF (dvdr2_final_row_ind=1)
    row + 1, col 0, "Final Compare Start DT/TM: ",
    col 28,
    CALL print(format(dvdr_rpt_dtl_info->final_row_dt_tm,"DD-MMM-YY HH:MM:SS;;D")), row + 2
   ENDIF
   IF ((dvdr2_rpt_s1->cnt > 0))
    IF (dvdr2_final_row_ind=1)
     col 0, "FINAL COMPARE ALERTS                  :"
    ELSE
     col 0, "COMPARE ALERTS                        :"
    ENDIF
    col 41,
    CALL print(cnvtstring(dvdr2_rpt_s1->cnt)), row + 1
   ELSE
    CALL print(" "), row + 1
   ENDIF
   IF (dvdr2_final_row_ind=0)
    col 0, "MISMATCH - INVESTIGATION REQUIRED     :"
   ELSE
    col 0, "FINAL COMPARE MISMATCHED              :"
   ENDIF
   col 41,
   CALL print(cnvtstring(dvdr2_rpt_s2->cnt)), col 50,
   CALL print(concat("(",build(dvdr2_rpt_s2->pct_of_ttl),"%)"))
   IF ((dvdr_rpt_dtl_info->comp_dt_min > 0.0))
    col 70, "CYCLE TIME START     :", col 94,
    CALL print(format(dvdr_rpt_dtl_info->comp_dt_min,"DD-MMM-YY HH:MM;;D"))
   ENDIF
   row + 1
   IF (dvdr2_final_row_ind=0)
    col 0, "MISMATCH - MONITOR                    :", col 41,
    CALL print(cnvtstring(dvdr2_rpt_s3->cnt)), col 50,
    CALL print(concat("(",build(dvdr2_rpt_s3->pct_of_ttl),"%)"))
    IF ((dvdr_rpt_dtl_info->comp_dt_min > 0.0))
     col 70, "CYCLE TIME END       :", col 94,
     CALL print(format(dvdr_rpt_dtl_info->comp_dt_max,"DD-MMM-YY HH:MM;;D"))
    ENDIF
    row + 1
   ENDIF
   IF (dvdr2_final_row_ind=0)
    col 0, "MISMATCH - NO CURRENT ACTION REQUIRED :", col 41,
    CALL print(cnvtstring(dvdr2_rpt_s4->cnt)), col 50,
    CALL print(concat("(",build(dvdr2_rpt_s4->pct_of_ttl),"%)"))
    IF ((dvdr_rpt_dtl_info->comp_dt_min > 0.0))
     col 70, "CYCLE TIME (MINUTES) :", col 94,
     CALL print(format(datetimediff(dvdr_rpt_dtl_info->comp_dt_max,dvdr_rpt_dtl_info->comp_dt_min,4),
      ";L"))
    ENDIF
    row + 1
   ELSE
    col 0, "FINAL COMPARE PENDING                 :", col 41,
    CALL print(cnvtstring(dvdr2_rpt_s5->cnt)), col 50,
    CALL print(concat("(",build(dvdr2_rpt_s5->pct_of_ttl),"%)"))
    IF ((dvdr_rpt_dtl_info->comp_dt_min > 0.0))
     col 70, "CYCLE TIME END       :", col 94,
     CALL print(format(dvdr_rpt_dtl_info->comp_dt_max,"DD-MMM-YY HH:MM;;D"))
    ENDIF
    row + 1
   ENDIF
   IF (dvdr2_final_row_ind=0)
    col 0, "PENDING INITIAL COMPARE               :", col 41,
    CALL print(cnvtstring(dvdr2_rpt_s5->cnt)), col 50,
    CALL print(concat("(",build(dvdr2_rpt_s5->pct_of_ttl),"%)")),
    row + 1, col 0, "MATCHED                               :",
    col 41,
    CALL print(cnvtstring(dvdr2_rpt_s6->cnt)), col 50,
    CALL print(concat("(",build(dvdr2_rpt_s6->pct_of_ttl),"%)")), row + 1
   ELSE
    col 0, "FINAL COMPARE MATCHED                 :", col 41,
    CALL print(cnvtstring(dvdr2_rpt_s6->cnt)), col 50,
    CALL print(concat("(",build(dvdr2_rpt_s6->pct_of_ttl),"%)"))
    IF ((dvdr_rpt_dtl_info->comp_dt_min > 0.0))
     col 70, "CYCLE TIME (MINUTES) :", col 94,
     CALL print(format(datetimediff(dvdr_rpt_dtl_info->comp_dt_max,dvdr_rpt_dtl_info->comp_dt_min,4),
      ";L"))
    ENDIF
    row + 1
   ENDIF
   col 0, "CURRENTLY COMPARING                   :", col 41,
   CALL print(cnvtstring(dvdr2_rpt_s7->cnt)), row + 1
   IF ((dvdr2_rpt_s7->cnt > 0))
    FOR (dvdr2_cnt = 1 TO dvdr2_rpt_s7->cnt)
      col 4,
      CALL print(build(dvdr2_rpt_s7->tbls[dvdr2_cnt].owner_name,".",dvdr2_rpt_s7->tbls[dvdr2_cnt].
       table_name)), row + 1
    ENDFOR
   ENDIF
   row + 2,
   CALL print(dvdr2_star_132), row + 1,
   col 0, "TABLE DETAILS", row + 1,
   CALL print(dvdr2_star_132), row + 1
   IF ((dvdr2_rpt_s1->cnt > 0))
    col 0,
    CALL print(dvdr2_dash_45), row + 1,
    col 0, "COMPARE ALERTS: ", col 16,
    CALL print(trim(cnvtstring(dvdr2_rpt_s1->cnt))), row + 1, col 0,
    CALL print(dvdr2_dash_45), row + 1, col 0,
    "OWNER.TABLE_NAME", col 41, "| MESSAGE",
    row + 1, col 0,
    CALL print(dvdr2_dash_132),
    row + 1
    FOR (dvdr2_cnt = 1 TO dvdr2_rpt_s1->cnt)
      col 0,
      CALL print(build(dvdr2_rpt_s1->tbls[dvdr2_cnt].owner_name,".",dvdr2_rpt_s1->tbls[dvdr2_cnt].
       table_name)), col 41,
      "|", col 43,
      CALL print(trim(substring(1,950,dvdr2_rpt_s1->tbls[dvdr2_cnt].message_txt))),
      row + 1
    ENDFOR
   ELSE
    row + 1
   ENDIF
   row + 1, col 0,
   CALL print(dvdr2_dash_45),
   row + 1
   IF (dvdr2_final_row_ind=1)
    col 0, "FINAL COMPARE MISMATCHED: "
   ELSE
    col 0, "MISMATCH - INVESTIGATION REQUIRED: "
   ENDIF
   col 35,
   CALL print(trim(cnvtstring(dvdr2_rpt_s2->cnt))), row + 1,
   col 0,
   CALL print(dvdr2_dash_45), row + 1,
   col 40, "| CONSEC.  |", col 51,
   "|", col 72, "|",
   col 93, "|", col 114,
   "|", row + 1, col 40,
   "| MISMATCH ", col 51, "| ROW ",
   col 72, "| ROW", col 93,
   "| DELIVERY", col 114, "| COMPARE",
   row + 1, col 0, "OWNER.TABLE_NAME",
   col 40, "| COUNT", col 51,
   "| IDENTIFIER", col 72, "| LAST UPDATE DT/TM",
   col 93, "| MAX LAG DT/TM", col 114,
   "| DT/TM", row + 1, col 0,
   CALL print(dvdr2_dash_132), row + 1
   IF ((dvdr2_rpt_s2->cnt > 0))
    FOR (dvdr2_cnt = 1 TO dvdr2_rpt_s2->cnt)
      col 0,
      CALL print(build(dvdr2_rpt_s2->tbls[dvdr2_cnt].owner_name,".",dvdr2_rpt_s2->tbls[dvdr2_cnt].
       table_name)), col 40,
      "| ",
      CALL print(format(dvdr2_rpt_s2->tbls[dvdr2_cnt].consec_mm_cnt,";L")), col 51,
      "| ",
      CALL print(dvdr2_rpt_s2->tbls[dvdr2_cnt].row_id_txt)
      IF ((dvdr2_rpt_s2->tbls[dvdr2_cnt].row_updt_dt_tm=0))
       col 72, "|        NULL "
      ELSE
       col 72, "| ",
       CALL print(format(dvdr2_rpt_s2->tbls[dvdr2_cnt].row_updt_dt_tm,"DD-MMM-YY HH:MM:SS;;D"))
      ENDIF
      col 93, "| ",
      CALL print(format(dvdr2_rpt_s2->tbls[dvdr2_cnt].max_lag_dt_tm,"DD-MMM-YY HH:MM:SS;;D")),
      col 114, "| ",
      CALL print(format(dvdr2_rpt_s2->tbls[dvdr2_cnt].compare_dt_tm,"DD-MMM-YY HH:MM:SS;;D")),
      row + 1
    ENDFOR
   ELSE
    row + 1
   ENDIF
   IF (dvdr2_final_row_ind=0)
    row + 1, col 0,
    CALL print(dvdr2_dash_45),
    row + 1, col 0, "MISMATCH - MONITOR: ",
    col 20,
    CALL print(trim(cnvtstring(dvdr2_rpt_s3->cnt))), row + 1,
    col 0,
    CALL print(dvdr2_dash_45), row + 1,
    col 40, "| CONSEC.  |", col 51,
    "|", col 72, "|",
    col 93, "|", col 114,
    "|", row + 1, col 40,
    "| MISMATCH ", col 51, "| ROW ",
    col 72, "| ROW", col 93,
    "| DELIVERY", col 114, "| COMPARE",
    row + 1, col 0, "OWNER.TABLE_NAME",
    col 40, "| COUNT", col 51,
    "| IDENTIFIER", col 72, "| LAST UPDATE DT/TM",
    col 93, "| MAX LAG DT/TM", col 114,
    "| DT/TM", row + 1, col 0,
    CALL print(dvdr2_dash_132), row + 1
    IF ((dvdr2_rpt_s3->cnt > 0))
     FOR (dvdr2_cnt = 1 TO dvdr2_rpt_s3->cnt)
       col 0,
       CALL print(build(dvdr2_rpt_s3->tbls[dvdr2_cnt].owner_name,".",dvdr2_rpt_s3->tbls[dvdr2_cnt].
        table_name)), col 40,
       "| ",
       CALL print(format(dvdr2_rpt_s3->tbls[dvdr2_cnt].consec_mm_cnt,";L"))
       IF ((dvdr2_rpt_s3->tbls[dvdr2_cnt].mm_pull_key_from_src_ind=0))
        col 51, "|  NO SOURCE DATA", col 72,
        "|  NO SOURCE DATA"
       ELSE
        col 51, "| ",
        CALL print(dvdr2_rpt_s3->tbls[dvdr2_cnt].row_id_txt),
        col 72, "|        N/A"
       ENDIF
       col 93, "| ",
       CALL print(format(dvdr2_rpt_s3->tbls[dvdr2_cnt].max_lag_dt_tm,"DD-MMM-YY HH:MM:SS;;D")),
       col 114, "| ",
       CALL print(format(dvdr2_rpt_s3->tbls[dvdr2_cnt].compare_dt_tm,"DD-MMM-YY HH:MM:SS;;D")),
       row + 1
     ENDFOR
    ELSE
     row + 1
    ENDIF
    row + 1, col 0,
    CALL print(dvdr2_dash_45),
    row + 1, col 0, "MISMATCH - NO CURRENT ACTION REQUIRED: ",
    col 43,
    CALL print(trim(cnvtstring(dvdr2_rpt_s4->cnt))), row + 1,
    col 0,
    CALL print(dvdr2_dash_45), row + 1,
    col 40, "| CONSEC.  |", col 51,
    "|", col 72, "|",
    col 93, "|", col 114,
    "|", row + 1, col 40,
    "| MISMATCH ", col 51, "| ROW ",
    col 72, "| ROW", col 93,
    "| DELIVERY", col 114, "| COMPARE",
    row + 1, col 0, "OWNER.TABLE_NAME",
    col 40, "| COUNT", col 51,
    "| IDENTIFIER", col 72, "| LAST UPDATE DT/TM",
    col 93, "| MAX LAG DT/TM", col 114,
    "| DT/TM", row + 1, col 0,
    CALL print(dvdr2_dash_132), row + 1
    IF ((dvdr2_rpt_s4->cnt > 0))
     FOR (dvdr2_cnt = 1 TO dvdr2_rpt_s4->cnt)
       col 0,
       CALL print(build(dvdr2_rpt_s4->tbls[dvdr2_cnt].owner_name,".",dvdr2_rpt_s4->tbls[dvdr2_cnt].
        table_name)), col 40,
       "| ",
       CALL print(format(dvdr2_rpt_s4->tbls[dvdr2_cnt].consec_mm_cnt,";L")), col 51,
       "| ",
       CALL print(dvdr2_rpt_s4->tbls[dvdr2_cnt].row_id_txt), col 72,
       "| ",
       CALL print(format(dvdr2_rpt_s4->tbls[dvdr2_cnt].row_updt_dt_tm,"DD-MMM-YY HH:MM:SS;;D")), col
       93,
       "| ",
       CALL print(format(dvdr2_rpt_s4->tbls[dvdr2_cnt].max_lag_dt_tm,"DD-MMM-YY HH:MM:SS;;D")), col
       114,
       "| ",
       CALL print(format(dvdr2_rpt_s4->tbls[dvdr2_cnt].compare_dt_tm,"DD-MMM-YY HH:MM:SS;;D")), row
        + 1
     ENDFOR
    ELSE
     row + 1
    ENDIF
   ENDIF
   row + 1, col 0,
   CALL print(dvdr2_dash_60),
   row + 1
   IF (dvdr2_final_row_ind=1)
    col 0, "FINAL COMPARE PENDING : "
   ELSE
    col 0, "Pending Initial Compare: "
   ENDIF
   col 25,
   CALL print(trim(cnvtstring(dvdr2_rpt_s5->cnt))), row + 1,
   col 0,
   CALL print(dvdr2_dash_60), row + 1,
   col 0, "OWNER.TABLE_NAME"
   IF (dvdr2_final_row_ind=1)
    col 40, "| LAST COMPARE DT/TM"
   ENDIF
   row + 1, col 0,
   CALL print(dvdr2_dash_60),
   row + 1, row + 1
   IF ((dvdr2_rpt_s5->cnt > 0))
    FOR (dvdr2_cnt = 1 TO dvdr2_rpt_s5->cnt)
      col 0,
      CALL print(build(dvdr2_rpt_s5->tbls[dvdr2_cnt].owner_name,".",dvdr2_rpt_s5->tbls[dvdr2_cnt].
       table_name))
      IF (dvdr2_final_row_ind=1)
       col 40, "| ",
       CALL print(format(dvdr2_rpt_s5->tbls[dvdr2_cnt].compare_dt_tm,"DD-MMM-YY HH:MM:SS;;D"))
      ENDIF
      row + 1
    ENDFOR
   ELSE
    row + 1
   ENDIF
   row + 1, col 0,
   CALL print(dvdr2_dash_60),
   row + 1
   IF (dvdr2_final_row_ind=0)
    col 0, "Matched: ", col 10,
    CALL print(trim(cnvtstring(dvdr2_rpt_s6->cnt))), row + 1
   ELSE
    col 0, "FINAL COMPARE MATCHED : ", col 24,
    CALL print(trim(cnvtstring(dvdr2_rpt_s6->cnt))), row + 1
   ENDIF
   col 0,
   CALL print(dvdr2_dash_60), row + 1,
   col 0, "OWNER.TABLE_NAME", col 40,
   "| LAST COMPARE DT/TM", row + 1, col 0,
   CALL print(dvdr2_dash_60), row + 1, row + 1
   IF ((dvdr2_rpt_s6->cnt > 0))
    FOR (dvdr2_cnt = 1 TO dvdr2_rpt_s6->cnt)
      col 0,
      CALL print(build(dvdr2_rpt_s6->tbls[dvdr2_cnt].owner_name,".",dvdr2_rpt_s6->tbls[dvdr2_cnt].
       table_name)), col 40,
      "| ",
      CALL print(format(dvdr2_rpt_s6->tbls[dvdr2_cnt].compare_dt_tm,"DD-MMM-YY HH:MM:SS;;D")), row +
      1
    ENDFOR
   ENDIF
  WITH nocounter, maxcol = 1000, formfeed = none,
   format = variable
 ;end select
 IF (check_error(dm_err->eproc))
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Displaying Data Verification Summary Report"
 IF (dm2_disp_file(dvdr2_rpt_file,"Data Verification Summary Report")=0)
  GO TO exit_script
 ENDIF
 GO TO exit_script
 SUBROUTINE dvdr2_load_vdata(null)
   SET dm_err->eproc = "Get UPTIME Mismatched Tables by ROW update date/time from DM_VDATA_MASTER..."
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_vdata_master dvm
    WHERE dvm.mismatch_event_cnt > 0
     AND dvm.row_dt_tm_col_name != "DM2NOTSET"
     AND dvm.mm_pull_key_from_src_ind=1
     AND ((dvm.mismatch_row_dt_tm < dvm.lag_dt_tm) OR (dvm.mismatch_row_dt_tm = null))
    ORDER BY dvm.mismatch_row_dt_tm, dvm.owner_name, dvm.table_name
    HEAD REPORT
     dvdr2_rpt_s2->cnt = 0
    DETAIL
     dvdr2_rpt_s2->cnt = (dvdr2_rpt_s2->cnt+ 1), stat = alterlist(dvdr2_rpt_s2->tbls,dvdr2_rpt_s2->
      cnt), dvdr2_rpt_s2->tbls[dvdr2_rpt_s2->cnt].owner_name = dvm.owner_name,
     dvdr2_rpt_s2->tbls[dvdr2_rpt_s2->cnt].table_name = dvm.table_name, dvdr2_rpt_s2->tbls[
     dvdr2_rpt_s2->cnt].consec_mm_cnt = dvm.mismatch_event_cnt, dvdr2_rpt_s2->tbls[dvdr2_rpt_s2->cnt]
     .row_id_txt = dvm.mismatch_rowid,
     dvdr2_rpt_s2->tbls[dvdr2_rpt_s2->cnt].row_updt_dt_tm = dvm.mismatch_row_dt_tm, dvdr2_rpt_s2->
     tbls[dvdr2_rpt_s2->cnt].max_lag_dt_tm = datetimeadd(dvm.lag_dt_tm,- ((dvdr2_lag_offset/ 1440.0))
      ), dvdr2_rpt_s2->tbls[dvdr2_rpt_s2->cnt].compare_dt_tm = dvm.last_compare_dt_tm
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   SET dm_err->eproc =
   "Get UPTIME Mismatched Tables by Consecutive Mismatch Count from DM_VDATA_MASTER..."
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_vdata_master dvm
    WHERE dvm.mismatch_event_cnt > 0
    ORDER BY dvm.mismatch_event_cnt DESC, dvm.owner_name, dvm.table_name
    HEAD REPORT
     dvdr2_rpt_s3->cnt = 0, dvdr2_rpt_s4->cnt = 0
    DETAIL
     IF (((dvm.row_dt_tm_col_name="DM2NOTSET") OR (dvm.mm_pull_key_from_src_ind=0)) )
      dvdr2_rpt_s3->cnt = (dvdr2_rpt_s3->cnt+ 1), stat = alterlist(dvdr2_rpt_s3->tbls,dvdr2_rpt_s3->
       cnt), dvdr2_rpt_s3->tbls[dvdr2_rpt_s3->cnt].owner_name = dvm.owner_name,
      dvdr2_rpt_s3->tbls[dvdr2_rpt_s3->cnt].table_name = dvm.table_name, dvdr2_rpt_s3->tbls[
      dvdr2_rpt_s3->cnt].consec_mm_cnt = dvm.mismatch_event_cnt, dvdr2_rpt_s3->tbls[dvdr2_rpt_s3->cnt
      ].row_id_txt = dvm.mismatch_rowid,
      dvdr2_rpt_s3->tbls[dvdr2_rpt_s3->cnt].mm_pull_key_from_src_ind = dvm.mm_pull_key_from_src_ind,
      dvdr2_rpt_s3->tbls[dvdr2_rpt_s3->cnt].max_lag_dt_tm = datetimeadd(dvm.lag_dt_tm,- ((
       dvdr2_lag_offset/ 1440.0))), dvdr2_rpt_s3->tbls[dvdr2_rpt_s3->cnt].compare_dt_tm = dvm
      .last_compare_dt_tm
     ELSEIF (dvm.row_dt_tm_col_name != "DM2NOTSET"
      AND dvm.mismatch_row_dt_tm IS NOT null
      AND dvm.mismatch_row_dt_tm >= dvm.lag_dt_tm)
      dvdr2_rpt_s4->cnt = (dvdr2_rpt_s4->cnt+ 1), stat = alterlist(dvdr2_rpt_s4->tbls,dvdr2_rpt_s4->
       cnt), dvdr2_rpt_s4->tbls[dvdr2_rpt_s4->cnt].owner_name = dvm.owner_name,
      dvdr2_rpt_s4->tbls[dvdr2_rpt_s4->cnt].table_name = dvm.table_name, dvdr2_rpt_s4->tbls[
      dvdr2_rpt_s4->cnt].consec_mm_cnt = dvm.mismatch_event_cnt, dvdr2_rpt_s4->tbls[dvdr2_rpt_s4->cnt
      ].row_updt_dt_tm = dvm.mismatch_row_dt_tm,
      dvdr2_rpt_s4->tbls[dvdr2_rpt_s4->cnt].row_id_txt = dvm.mismatch_rowid, dvdr2_rpt_s4->tbls[
      dvdr2_rpt_s4->cnt].max_lag_dt_tm = datetimeadd(dvm.lag_dt_tm,- ((dvdr2_lag_offset/ 1440.0))),
      dvdr2_rpt_s4->tbls[dvdr2_rpt_s4->cnt].compare_dt_tm = dvm.last_compare_dt_tm
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    RETURN(0)
   ENDIF
   SET dm_err->eproc =
   "Get UPTIME Status= Match, Pending Compare, Comparing, Error Tables from DM_VDATA_MASTER..."
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_vdata_master dvm
    WHERE dvm.compare_status IN (dvdr_ready, dvdr_match, dvdr_comparing, dvdr_error)
    ORDER BY dvm.owner_name, dvm.table_name
    HEAD REPORT
     dvdr2_rpt_s1->cnt = 0, dvdr2_rpt_s5->cnt = 0, dvdr2_rpt_s6->cnt = 0,
     dvdr2_rpt_s7->cnt = 0
    DETAIL
     IF (((dvm.compare_status=dvdr_ready) OR (dvm.compare_status=dvdr_error
      AND dvm.last_compare_dt_tm=cnvtdatetime("01-JAN-1900"))) )
      dvdr2_rpt_s5->cnt = (dvdr2_rpt_s5->cnt+ 1), stat = alterlist(dvdr2_rpt_s5->tbls,dvdr2_rpt_s5->
       cnt), dvdr2_rpt_s5->tbls[dvdr2_rpt_s5->cnt].owner_name = dvm.owner_name,
      dvdr2_rpt_s5->tbls[dvdr2_rpt_s5->cnt].table_name = dvm.table_name
     ELSEIF (dvm.mismatch_event_cnt=0
      AND dvm.last_compare_dt_tm > cnvtdatetime("01-JAN-1900"))
      dvdr2_rpt_s6->cnt = (dvdr2_rpt_s6->cnt+ 1), stat = alterlist(dvdr2_rpt_s6->tbls,dvdr2_rpt_s6->
       cnt), dvdr2_rpt_s6->tbls[dvdr2_rpt_s6->cnt].owner_name = dvm.owner_name,
      dvdr2_rpt_s6->tbls[dvdr2_rpt_s6->cnt].table_name = dvm.table_name, dvdr2_rpt_s6->tbls[
      dvdr2_rpt_s6->cnt].compare_dt_tm = dvm.last_compare_dt_tm
     ENDIF
     IF (dvm.compare_status=dvdr_comparing)
      dvdr2_rpt_s7->cnt = (dvdr2_rpt_s7->cnt+ 1), stat = alterlist(dvdr2_rpt_s7->tbls,dvdr2_rpt_s7->
       cnt), dvdr2_rpt_s7->tbls[dvdr2_rpt_s7->cnt].owner_name = dvm.owner_name,
      dvdr2_rpt_s7->tbls[dvdr2_rpt_s7->cnt].table_name = dvm.table_name
     ENDIF
     IF (dvm.compare_status=dvdr_error
      AND dvm.message_txt != "*is currently Inactive*")
      dvdr2_rpt_s1->cnt = (dvdr2_rpt_s1->cnt+ 1), stat = alterlist(dvdr2_rpt_s1->tbls,dvdr2_rpt_s1->
       cnt), dvdr2_rpt_s1->tbls[dvdr2_rpt_s1->cnt].owner_name = dvm.owner_name,
      dvdr2_rpt_s1->tbls[dvdr2_rpt_s1->cnt].table_name = dvm.table_name, dvdr2_rpt_s1->tbls[
      dvdr2_rpt_s1->cnt].message_txt = dvm.message_txt
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dvdr2_load_vdata_final(null)
   SET dm_err->eproc = "Get all DM_VDATA_MASTER data and categorize for FINAL compare"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_vdata_master dvm
    WHERE  NOT (dvm.compare_status IN (dvdr_exclude, dvdr_nocomp_size, dvdr_uow_status))
    ORDER BY dvm.owner_name, dvm.table_name
    HEAD REPORT
     dvdr2_rpt_s1->cnt = 0, dvdr2_rpt_s6->cnt = 0, dvdr2_rpt_s2->cnt = 0,
     dvdr2_rpt_s5->cnt = 0, dvdr2_rpt_s7->cnt = 0
    DETAIL
     IF (dvm.compare_status=dvdr_error)
      dvdr2_rpt_s1->cnt = (dvdr2_rpt_s1->cnt+ 1), stat = alterlist(dvdr2_rpt_s1->tbls,dvdr2_rpt_s1->
       cnt), dvdr2_rpt_s1->tbls[dvdr2_rpt_s1->cnt].owner_name = dvm.owner_name,
      dvdr2_rpt_s1->tbls[dvdr2_rpt_s1->cnt].table_name = dvm.table_name, dvdr2_rpt_s1->tbls[
      dvdr2_rpt_s1->cnt].message_txt = dvm.message_txt
     ELSEIF (dvm.compare_status=dvdr_complete)
      dvdr2_rpt_s6->cnt = (dvdr2_rpt_s6->cnt+ 1), stat = alterlist(dvdr2_rpt_s6->tbls,dvdr2_rpt_s6->
       cnt), dvdr2_rpt_s6->tbls[dvdr2_rpt_s6->cnt].owner_name = dvm.owner_name,
      dvdr2_rpt_s6->tbls[dvdr2_rpt_s6->cnt].table_name = dvm.table_name, dvdr2_rpt_s6->tbls[
      dvdr2_rpt_s6->cnt].compare_dt_tm = dvm.last_compare_dt_tm
     ELSEIF ((dvm.last_compare_dt_tm >= dvdr_rpt_dtl_info->final_row_dt_tm)
      AND dvm.mismatch_event_cnt > 0)
      dvdr2_rpt_s2->cnt = (dvdr2_rpt_s2->cnt+ 1), stat = alterlist(dvdr2_rpt_s2->tbls,dvdr2_rpt_s2->
       cnt), dvdr2_rpt_s2->tbls[dvdr2_rpt_s2->cnt].owner_name = dvm.owner_name,
      dvdr2_rpt_s2->tbls[dvdr2_rpt_s2->cnt].table_name = dvm.table_name, dvdr2_rpt_s2->tbls[
      dvdr2_rpt_s2->cnt].consec_mm_cnt = dvm.mismatch_event_cnt, dvdr2_rpt_s2->tbls[dvdr2_rpt_s2->cnt
      ].row_id_txt = dvm.mismatch_rowid,
      dvdr2_rpt_s2->tbls[dvdr2_rpt_s2->cnt].row_updt_dt_tm = dvm.mismatch_row_dt_tm, dvdr2_rpt_s2->
      tbls[dvdr2_rpt_s2->cnt].max_lag_dt_tm = datetimeadd(dvm.lag_dt_tm,- ((dvdr2_lag_offset/ 1440.0)
       )), dvdr2_rpt_s2->tbls[dvdr2_rpt_s2->cnt].compare_dt_tm = dvm.last_compare_dt_tm
     ELSE
      dvdr2_rpt_s5->cnt = (dvdr2_rpt_s5->cnt+ 1), stat = alterlist(dvdr2_rpt_s5->tbls,dvdr2_rpt_s5->
       cnt), dvdr2_rpt_s5->tbls[dvdr2_rpt_s5->cnt].owner_name = dvm.owner_name,
      dvdr2_rpt_s5->tbls[dvdr2_rpt_s5->cnt].table_name = dvm.table_name, dvdr2_rpt_s5->tbls[
      dvdr2_rpt_s5->cnt].compare_dt_tm = dvm.last_compare_dt_tm
     ENDIF
     IF (dvm.compare_status=dvdr_comparing)
      dvdr2_rpt_s7->cnt = (dvdr2_rpt_s7->cnt+ 1), stat = alterlist(dvdr2_rpt_s7->tbls,dvdr2_rpt_s7->
       cnt), dvdr2_rpt_s7->tbls[dvdr2_rpt_s7->cnt].owner_name = dvm.owner_name,
      dvdr2_rpt_s7->tbls[dvdr2_rpt_s7->cnt].table_name = dvm.table_name
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_script
 IF ((dm_err->err_ind=0))
  SET dm_err->eproc = "dm2_verify_data_rpt2 completed successfully."
 ELSE
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
 ENDIF
 CALL final_disp_msg("dm2_verify_data_rpt2")
END GO
