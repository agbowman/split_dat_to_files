CREATE PROGRAM dm_rmc_xlats_to_admin:dba
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
 DECLARE get_chain_id(i_chain_name=vc) = f8
 DECLARE dm_check_syn(null) = vc
 DECLARE xta_dbl_hlv(i_gap=f8) = f8
 SUBROUTINE get_chain_id(i_chain_name)
   DECLARE gci_chain_name = vc
   DECLARE gci_chain_id = f8
   SET gci_chain_name = trim(cnvtupper(i_chain_name),3)
   SET dm_err->eproc = concat("Obtaining chain id for chain name: ",gci_chain_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_rdds_chain drc
    WHERE drc.chain_name=gci_chain_name
    DETAIL
     gci_chain_id = drc.dm_rdds_chain_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = concat("Inserting dm_rdds_chain row for chain name: ",gci_chain_name)
    CALL disp_msg(" ",dm_err->logfile,0)
    INSERT  FROM dm_rdds_chain drc
     SET drc.dm_rdds_chain_id = seq(dm_seq,nextval), drc.chain_name = gci_chain_name, drc.rdbhandle
       = currdbhandle,
      drc.state_flag = 0, drc.action_dt_tm = sysdate, drc.rows_to_process = 0,
      drc.rows_processed = 0, drc.updt_id = reqinfo->updt_id, drc.updt_dt_tm = sysdate,
      drc.updt_task = reqinfo->updt_task, drc.updt_applctx = reqinfo->updt_applctx, drc.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     ROLLBACK
     RETURN(- (1))
    ELSE
     COMMIT
    ENDIF
    SET dm_err->eproc = concat("Obtaining chain id for chain name: ",gci_chain_name)
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_rdds_chain drc
     WHERE drc.chain_name=gci_chain_name
     DETAIL
      gci_chain_id = drc.dm_rdds_chain_id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     ROLLBACK
     RETURN(- (1))
    ENDIF
   ENDIF
   RETURN(gci_chain_id)
 END ;Subroutine
 SUBROUTINE dm_check_syn(null)
   SET dm_err->eproc = "Verify if DM_RDDS_DMT has a synonym"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM all_synonyms a
    WHERE a.table_name="DM_RDDS_DMT"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("F")
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = "Create synonym for DM_RDDS_DMT"
    CALL disp_msg(" ",dm_err->logfile,0)
    EXECUTE dm2_create_admin_nicknames "DM_RDDS_DMT", "CDBA"
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN("F")
    ENDIF
   ENDIF
   SET dm_err->eproc = "Verify if DM_RDDS_CHAIN has a synonym"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM all_synonyms a
    WHERE a.table_name="DM_RDDS_CHAIN"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("F")
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = "Create synonym for DM_RDDS_CHAIN"
    CALL disp_msg(" ",dm_err->logfile,0)
    EXECUTE dm2_create_admin_nicknames "DM_RDDS_CHAIN", "CDBA"
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN("F")
    ENDIF
   ENDIF
   SET dm_err->eproc = "Verify if DM_RDDS_CHAIN_CHILD has a synonym"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM all_synonyms a
    WHERE a.table_name="DM_RDDS_CHAIN_CHILD"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("F")
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = "Create synonym for DM_RDDS_CHAIN_CHILD"
    CALL disp_msg(" ",dm_err->logfile,0)
    EXECUTE dm2_create_admin_nicknames "DM_RDDS_CHAIN_CHILD", "CDBA"
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN("F")
    ENDIF
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE xta_dbl_hlv(i_gap)
   DECLARE xdh_gap = f8
   IF (check_error(dm_err->eproc)=1)
    IF (((findstring("ORA-01555",dm_err->emsg) != 0) OR (((findstring("ORA-01650",dm_err->emsg) != 0)
     OR (((findstring("ORA-01562",dm_err->emsg) != 0) OR (((findstring("ORA-30036",dm_err->emsg) != 0
    ) OR (((findstring("ORA-30027",dm_err->emsg) != 0) OR (findstring("ORA-01581",dm_err->emsg) != 0
    )) )) )) )) )) )
     IF (((i_gap/ 2) > 20))
      ROLLBACK
      CALL echo("TRAPPED ROLLBACK SEGMENT ERROR..")
      SET dm_err->err_ind = 0
      SET dm_err->emsg = ""
      SET xdh_gap = (i_gap/ 2)
     ELSE
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(- (1))
     ENDIF
    ELSE
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(- (1))
    ENDIF
   ELSE
    SET xdh_gap = (i_gap * 2)
   ENDIF
   RETURN(xdh_gap)
 END ;Subroutine
 IF (check_logfile("DM_RMC_XLATS_TO_ADM",".log","DM_RMC_XLATS_TO_ADM LogFile")=0)
  SET dm_err->err_ind = 1
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO end_program
 ENDIF
 IF ((validate(request->src_env_id1,- (99))=- (99)))
  FREE RECORD request
  RECORD request(
    1 src_env_id1 = f8
    1 src_env_id2 = f8
    1 trg_env_id = f8
    1 chain_id = f8
    1 chain_seq = i4
  )
  SET request->src_env_id1 =  $1
  SET request->src_env_id2 =  $2
  SET request->trg_env_id =  $3
  SET request->chain_id =  $4
  SET request->chain_seq =  $5
 ENDIF
 DECLARE xta_ret = vc
 DECLARE xta_cc_id = f8
 DECLARE xta_logging_val = i4
 DECLARE xta_row_cnt = i4
 DECLARE xta_qual = i4
 DECLARE xta_continue_ind = i2
 DECLARE xta_row_qual = i4
 DECLARE xta_low = f8
 DECLARE xta_max = f8
 DECLARE xta_high = f8
 DECLARE xta_gap = f8
 DECLARE xta_tot_rows = i4
 DECLARE xta_rows_to_process = i4
 SET xta_logging_val = 204
 SET xta_ret = dm_check_syn(null)
 IF (xta_ret="F")
  SET dm_err->eproc = "Error occured while checking synonyms"
  CALL disp_msg(" ",dm_err->logfile,0)
  GO TO end_program
 ENDIF
 SET dm_err->eproc = "Updating dm_rdds_chain row to state_flag = 4"
 CALL disp_msg(" ",dm_err->logfile,0)
 UPDATE  FROM dm_rdds_chain drc
  SET drc.state_flag = 4
  WHERE (drc.dm_rdds_chain_id=request->chain_id)
  WITH nocounter
 ;end update
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  ROLLBACK
  GO TO end_program
 ELSE
  COMMIT
 ENDIF
 IF (curqual=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Invalid dm_rdds_chain_id passed to script"
  GO TO end_program
 ENDIF
 SET dm_err->eproc = "Updating dm_rdds_chain_child row to state_flag = 4"
 CALL disp_msg(" ",dm_err->logfile,0)
 UPDATE  FROM dm_rdds_chain_child drcc
  SET drcc.state_flag = 4, drcc.rows_to_process = 0, drcc.rows_processed = 0,
   drcc.chain_seq = request->chain_seq
  WHERE (drcc.dm_rdds_chain_id=request->chain_id)
   AND (drcc.from_env_id=request->src_env_id1)
   AND (drcc.to_env_id=request->trg_env_id)
  WITH nocounter
 ;end update
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  ROLLBACK
  GO TO end_program
 ELSE
  COMMIT
 ENDIF
 IF (curqual=0)
  SET dm_err->eproc = "Inserting dm_rdds_chain_child row to state_flag = 4"
  CALL disp_msg(" ",dm_err->logfile,0)
  INSERT  FROM dm_rdds_chain_child drcc
   SET drcc.dm_rdds_chain_child_id = seq(dm_seq,nextval), drcc.dm_rdds_chain_id = request->chain_id,
    drcc.chain_seq = request->chain_seq,
    drcc.from_env_id = request->src_env_id1, drcc.to_env_id = request->trg_env_id, drcc.rdbhandle =
    currdbhandle,
    drcc.state_flag = 4, drcc.action_dt_tm = sysdate, drcc.updt_id = reqinfo->updt_id,
    drcc.updt_dt_tm = sysdate, drcc.updt_task = reqinfo->updt_task, drcc.updt_applctx = reqinfo->
    updt_applctx,
    drcc.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   ROLLBACK
   GO TO end_program
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET dm_err->eproc = "Obtain the dm_rdds_chain_child_id for the row just inserted/updated"
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM dm_rdds_chain_child drcc
  WHERE (drcc.dm_rdds_chain_id=request->chain_id)
   AND (drcc.chain_seq=request->chain_seq)
   AND (drcc.from_env_id=request->src_env_id1)
   AND (drcc.to_env_id=request->trg_env_id)
   AND drcc.state_flag=4
  DETAIL
   xta_cc_id = drcc.dm_rdds_chain_child_id
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO end_program
 ENDIF
 SET dm_err->eproc = "Checking to see if dm_rmc_seqmatch_xlats_rdm has finished for source 1"
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE ((d.info_domain=concat("MERGE",trim(cnvtstring(request->src_env_id1)),trim(cnvtstring(request
     ->trg_env_id)),"SEQMATCH")
   AND d.info_number > 0
   AND d.info_name IN (
  (SELECT DISTINCT
   dcd.sequence_name
   FROM dm_columns_doc dcd,
    dm_tables_doc dtd
   WHERE ((dtd.reference_ind=1) OR (dtd.table_name IN (
   (SELECT
    rt.table_name
    FROM dm_rdds_refmrg_tables rt))))
    AND dtd.table_name=dtd.full_table_name
    AND dtd.table_name=dcd.table_name
    AND dcd.table_name=dcd.root_entity_name
    AND dcd.column_name=dcd.root_entity_attr
    AND trim(dcd.sequence_name) > " "))) OR (d.info_domain=concat("MERGE",trim(cnvtstring(request->
     src_env_id1)),trim(cnvtstring(request->trg_env_id)),"SEQMATCH")
   AND  NOT (d.info_name IN (
  (SELECT
   di.info_name
   FROM dm_info di
   WHERE di.info_domain=concat("MERGE",trim(cnvtstring(request->src_env_id1)),trim(cnvtstring(request
      ->trg_env_id)),"SEQMATCHDONE2"))))
   AND d.info_name IN (
  (SELECT DISTINCT
   dcd.sequence_name
   FROM dm_columns_doc dcd,
    dm_tables_doc dtd
   WHERE ((dtd.reference_ind=1) OR (dtd.table_name IN (
   (SELECT
    rt.table_name
    FROM dm_rdds_refmrg_tables rt))))
    AND dtd.table_name=dtd.full_table_name
    AND dtd.table_name=dcd.table_name
    AND dcd.table_name=dcd.root_entity_name
    AND dcd.column_name=dcd.root_entity_attr
    AND trim(dcd.sequence_name) > " "))))
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO end_program
 ENDIF
 IF (curqual > 0)
  SET dm_err->emsg = concat(
   "The backfill for translations below sequence match has not been completed for source: ",
   cnvtstring(request->src_env_id1))
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO end_program
 ENDIF
 IF ((request->src_env_id2 > 0))
  SET dm_err->eproc = "Checking to see if dm_rmc_seqmatch_xlats_rdm has finished for source 2"
  CALL disp_msg(" ",dm_err->logfile,0)
  SELECT INTO "nl:"
   FROM dm_info d
   WHERE ((d.info_domain=concat("MERGE",trim(cnvtstring(request->src_env_id2)),trim(cnvtstring(
      request->trg_env_id)),"SEQMATCH")
    AND d.info_number > 0
    AND d.info_name IN (
   (SELECT DISTINCT
    dcd.sequence_name
    FROM dm_columns_doc dcd,
     dm_tables_doc dtd
    WHERE ((dtd.reference_ind=1) OR (dtd.table_name IN (
    (SELECT
     rt.table_name
     FROM dm_rdds_refmrg_tables rt))))
     AND dtd.table_name=dtd.full_table_name
     AND dtd.table_name=dcd.table_name
     AND dcd.table_name=dcd.root_entity_name
     AND dcd.column_name=dcd.root_entity_attr
     AND trim(dcd.sequence_name) > " "))) OR (d.info_domain=concat("MERGE",trim(cnvtstring(request->
      src_env_id2)),trim(cnvtstring(request->trg_env_id)),"SEQMATCH")
    AND  NOT (d.info_name IN (
   (SELECT
    di.info_name
    FROM dm_info di
    WHERE di.info_domain=concat("MERGE",trim(cnvtstring(request->src_env_id2)),trim(cnvtstring(
       request->trg_env_id)),"SEQMATCHDONE2"))))
    AND d.info_name IN (
   (SELECT DISTINCT
    dcd.sequence_name
    FROM dm_columns_doc dcd,
     dm_tables_doc dtd
    WHERE ((dtd.reference_ind=1) OR (dtd.table_name IN (
    (SELECT
     rt.table_name
     FROM dm_rdds_refmrg_tables rt))))
     AND dtd.table_name=dtd.full_table_name
     AND dtd.table_name=dcd.table_name
     AND dcd.table_name=dcd.root_entity_name
     AND dcd.column_name=dcd.root_entity_attr
     AND trim(dcd.sequence_name) > " "))))
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   GO TO end_program
  ENDIF
  IF (curqual > 0)
   SET dm_err->emsg = concat(
    "The backfill for translations below sequence match has not been completed for source: ",
    cnvtstring(request->src_env_id2))
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO end_program
  ENDIF
 ENDIF
 SET dm_err->eproc = "Obtaining translation count for source 1"
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
  y = count(*)
  FROM dm_merge_translate dmt
  WHERE (dmt.env_source_id=request->src_env_id1)
   AND (dmt.env_target_id=request->trg_env_id)
   AND dmt.from_value != 0
   AND  NOT (dmt.table_name IN (
  (SELECT
   di.info_name
   FROM dm_info di
   WHERE di.info_domain="RDDS BACKFILL EXCLUSION")))
  DETAIL
   xta_row_cnt = y
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO end_program
 ENDIF
 IF ((request->src_env_id2 > 0))
  SET dm_err->eproc = "Obtaining translation count for source 2"
  CALL disp_msg(" ",dm_err->logfile,0)
  SELECT INTO "nl:"
   y = count(*)
   FROM dm_merge_translate dmt
   WHERE (dmt.env_source_id=request->src_env_id2)
    AND (dmt.env_target_id=request->trg_env_id)
    AND dmt.from_value != 0
    AND  NOT (dmt.table_name IN (
   (SELECT
    di.info_name
    FROM dm_info di
    WHERE di.info_domain="RDDS BACKFILL EXCLUSION")))
   DETAIL
    xta_row_cnt = (xta_row_cnt+ y)
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   GO TO end_program
  ENDIF
 ENDIF
 SET dm_err->eproc = "Inserting rows to process in dm_rdds_chain"
 CALL disp_msg(" ",dm_err->logfile,0)
 UPDATE  FROM dm_rdds_chain drc
  SET drc.rows_to_process = (drc.rows_to_process+ xta_row_cnt), drc.action_dt_tm = sysdate
  WHERE (drc.dm_rdds_chain_id=request->chain_id)
  WITH nocounter
 ;end update
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  ROLLBACK
  GO TO end_program
 ELSE
  COMMIT
 ENDIF
 SET dm_err->eproc = "Inserting rows to process in dm_rdds_chain_child"
 CALL disp_msg(" ",dm_err->logfile,0)
 UPDATE  FROM dm_rdds_chain_child drcc
  SET drcc.rows_to_process = xta_row_cnt, drcc.action_dt_tm = sysdate
  WHERE drcc.dm_rdds_chain_child_id=xta_cc_id
  WITH nocounter
 ;end update
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  ROLLBACK
  GO TO end_program
 ELSE
  COMMIT
 ENDIF
 SET xta_continue_ind = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="RDDS_REPLICATE"
   AND di.info_name="ROW_QUAL"
  DETAIL
   IF (di.info_number < 2000000000)
    xta_row_qual = di.info_number
   ELSE
    xta_row_qual = 2000000000
   ENDIF
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO end_program
 ENDIF
 IF (((curqual=0) OR (xta_row_qual < 100)) )
  SET xta_row_qual = 100000
 ENDIF
 WHILE (xta_continue_ind=0)
   SET dm_err->eproc = "Cleaning up partial/old transfer to admin for the current chain env_ids"
   CALL disp_msg(" ",dm_err->logfile,0)
   DELETE  FROM dm_rdds_dmt drd
    WHERE (drd.dm_rdds_chain_id=request->chain_id)
     AND (drd.env_source_id=request->src_env_id1)
     AND (drd.env_target_id=request->trg_env_id)
    WITH maxqual(drd,value(xta_row_qual)), nocounter
   ;end delete
   SET xta_qual = curqual
   IF (check_error(dm_err->eproc)=1)
    SET xta_row_qual = xta_dbl_hlv(cnvtreal(xta_row_qual))
    IF (xta_row_qual <= 0)
     GO TO end_program
    ENDIF
   ELSE
    IF (xta_qual < xta_row_qual)
     SET xta_continue_ind = 1
    ENDIF
    COMMIT
   ENDIF
 ENDWHILE
 IF ((request->src_env_id2 > 0))
  SET xta_continue_ind = 0
  WHILE (xta_continue_ind=0)
    SET dm_err->eproc = "Cleaning up partial/old transfer to admin for the current chain"
    CALL disp_msg(" ",dm_err->logfile,0)
    DELETE  FROM dm_rdds_dmt drd
     WHERE (drd.dm_rdds_chain_id=request->chain_id)
      AND (drd.env_source_id=request->src_env_id2)
      AND (drd.env_target_id=request->trg_env_id)
     WITH maxqual(drd,value(xta_row_qual)), nocounter
    ;end delete
    SET xta_qual = curqual
    IF (check_error(dm_err->eproc)=1)
     SET xta_row_qual = xta_dbl_hlv(cnvtreal(xta_row_qual))
     IF (xta_row_qual <= 0)
      GO TO end_program
     ENDIF
    ELSE
     IF (xta_qual < xta_row_qual)
      SET xta_continue_ind = 1
     ENDIF
     COMMIT
    ENDIF
  ENDWHILE
 ENDIF
 SET dm_err->eproc = "Obtaining value to determine max row inserted"
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="RDDS_REPLICATE"
   AND di.info_name="INSERT_INTO_ADMIN"
  DETAIL
   xta_tot_rows = di.info_number
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO end_program
 ENDIF
 IF (((curqual=0) OR (xta_tot_rows < 100)) )
  SET xta_tot_rows = 200000
 ENDIF
 SET xta_low = 0
 SET xta_max = 0
 SET dm_err->eproc = concat("Obtaining min from_value for source: ",cnvtstring(request->src_env_id1))
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
  y = min(dmt.from_value)
  FROM dm_merge_translate dmt
  WHERE (dmt.env_source_id=request->src_env_id1)
   AND (dmt.env_target_id=request->trg_env_id)
   AND dmt.from_value != 0
  DETAIL
   xta_low = y
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO end_program
 ENDIF
 SET dm_err->eproc = concat("Obtaining max from_value for source: ",cnvtstring(request->src_env_id1))
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
  y = max(dmt.from_value)
  FROM dm_merge_translate dmt
  WHERE (dmt.env_source_id=request->src_env_id1)
   AND (dmt.env_target_id=request->trg_env_id)
  DETAIL
   xta_max = y
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO end_program
 ENDIF
 SET xta_high = 0
 SET xta_gap = 10000
 SET xta_continue_ind = 0
 SET xta_high = (xta_low+ xta_gap)
 WHILE (xta_continue_ind=0)
   INSERT  FROM dm_rdds_dmt drd
    (drd.dm_rdds_dmt_id, drd.dm_rdds_chain_id, drd.from_value,
    drd.table_name, drd.env_source_id, drd.env_target_id,
    drd.to_value, drd.translation_type_flag, drd.updt_id,
    drd.updt_dt_tm, drd.updt_task, drd.updt_applctx,
    drd.updt_cnt)(SELECT
     seq(dm_seq,nextval), request->chain_id, dmt.from_value,
     dmt.table_name, request->src_env_id1, request->trg_env_id,
     dmt.to_value, 1, reqinfo->updt_id,
     sysdate, reqinfo->updt_task, reqinfo->updt_applctx,
     0
     FROM dm_merge_translate dmt
     WHERE (dmt.env_source_id=request->src_env_id1)
      AND (dmt.env_target_id=request->trg_env_id)
      AND  NOT (dmt.table_name IN (
     (SELECT
      di.info_name
      FROM dm_info di
      WHERE di.info_domain="RDDS BACKFILL EXCLUSION")))
      AND dmt.from_value >= xta_low
      AND dmt.from_value < xta_high)
    WITH nocounter
   ;end insert
   SET xta_qual = curqual
   IF (check_error(dm_err->eproc)=1)
    SET xta_gap = xta_dbl_hlv(xta_gap)
    IF ((xta_gap=- (1)))
     GO TO end_program
    ENDIF
    SET xta_high = (xta_low+ xta_gap)
   ELSE
    COMMIT
    IF (xta_qual > 0)
     SET dm_err->eproc = "Inserting status for rows processed in dm_rdds_chain"
     CALL disp_msg(" ",dm_err->logfile,0)
     UPDATE  FROM dm_rdds_chain drc
      SET drc.rows_processed = (drc.rows_processed+ xta_qual), drc.action_dt_tm = sysdate
      WHERE (drc.dm_rdds_chain_id=request->chain_id)
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      ROLLBACK
     ELSE
      COMMIT
     ENDIF
     SET dm_err->eproc = "Inserting status for rows processed in dm_rdds_chain_child"
     CALL disp_msg(" ",dm_err->logfile,0)
     UPDATE  FROM dm_rdds_chain_child drcc
      SET drcc.rows_processed = (drcc.rows_processed+ xta_qual), drcc.action_dt_tm = sysdate
      WHERE drcc.dm_rdds_chain_child_id=xta_cc_id
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      ROLLBACK
     ELSE
      COMMIT
     ENDIF
    ENDIF
    SET dm_err->eproc = "Check to see if the script needs to stop"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     drcc.state_flag
     FROM dm_rdds_chain_child drcc
     WHERE drcc.dm_rdds_chain_child_id=xta_cc_id
     DETAIL
      IF (drcc.state_flag=99)
       xta_logging_val = 304
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     GO TO end_program
    ENDIF
    IF (xta_logging_val=304)
     GO TO end_program
    ENDIF
    IF (xta_high > xta_max)
     SET xta_continue_ind = 1
    ENDIF
    IF (xta_qual < xta_tot_rows)
     SET xta_gap = xta_dbl_hlv(xta_gap)
     SET xta_low = xta_high
     SET xta_high = (xta_high+ xta_gap)
    ELSE
     SET xta_low = xta_high
     SET xta_high = (xta_high+ xta_gap)
    ENDIF
   ENDIF
 ENDWHILE
 IF ((request->src_env_id2 > 0))
  SET xta_low = 0
  SET xta_max = 0
  SET dm_err->eproc = concat("Obtaining min from_value for source: ",cnvtstring(request->src_env_id2)
   )
  CALL disp_msg(" ",dm_err->logfile,0)
  SELECT INTO "nl:"
   y = min(dmt.from_value)
   FROM dm_merge_translate dmt
   WHERE (dmt.env_source_id=request->src_env_id2)
    AND (dmt.env_target_id=request->trg_env_id)
    AND dmt.from_value != 0
   DETAIL
    xta_low = y
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   GO TO end_program
  ENDIF
  SET dm_err->eproc = concat("Obtaining max from_value for source: ",cnvtstring(request->src_env_id2)
   )
  CALL disp_msg(" ",dm_err->logfile,0)
  SELECT INTO "nl:"
   y = max(dmt.from_value)
   FROM dm_merge_translate dmt
   WHERE (dmt.env_source_id=request->src_env_id2)
    AND (dmt.env_target_id=request->trg_env_id)
   DETAIL
    xta_max = y
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   GO TO end_program
  ENDIF
  SET xta_high = 0
  SET xta_gap = 10000
  SET xta_continue_ind = 0
  SET xta_high = (xta_low+ xta_gap)
  WHILE (xta_continue_ind=0)
    INSERT  FROM dm_rdds_dmt drd
     (drd.dm_rdds_dmt_id, drd.dm_rdds_chain_id, drd.from_value,
     drd.table_name, drd.env_source_id, drd.env_target_id,
     drd.to_value, drd.translation_type_flag, drd.updt_id,
     drd.updt_dt_tm, drd.updt_task, drd.updt_applctx,
     drd.updt_cnt)(SELECT
      seq(dm_seq,nextval), request->chain_id, dmt.from_value,
      dmt.table_name, request->src_env_id2, request->trg_env_id,
      dmt.to_value, 1, reqinfo->updt_id,
      sysdate, reqinfo->updt_task, reqinfo->updt_applctx,
      0
      FROM dm_merge_translate dmt
      WHERE (dmt.env_source_id=request->src_env_id2)
       AND (dmt.env_target_id=request->trg_env_id)
       AND  NOT (dmt.table_name IN (
      (SELECT
       di.info_name
       FROM dm_info di
       WHERE di.info_domain="RDDS BACKFILL EXCLUSION")))
       AND dmt.from_value >= xta_low
       AND dmt.from_value < xta_high)
     WITH nocounter
    ;end insert
    SET xta_qual = curqual
    IF (check_error(dm_err->eproc)=1)
     SET xta_gap = xta_dbl_hlv(xta_gap)
     IF ((xta_gap=- (1)))
      GO TO end_program
     ENDIF
     SET xta_high = (xta_low+ xta_gap)
    ELSE
     COMMIT
     IF (xta_qual > 0)
      SET dm_err->eproc = "Inserting status for rows processed in dm_rdds_chain"
      CALL disp_msg(" ",dm_err->logfile,0)
      UPDATE  FROM dm_rdds_chain drc
       SET drc.rows_processed = (drc.rows_processed+ xta_qual), drc.action_dt_tm = sysdate
       WHERE (drc.dm_rdds_chain_id=request->chain_id)
       WITH nocounter
      ;end update
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       ROLLBACK
      ELSE
       COMMIT
      ENDIF
      SET dm_err->eproc = "Inserting status for rows processed in dm_rdds_chain_child"
      CALL disp_msg(" ",dm_err->logfile,0)
      UPDATE  FROM dm_rdds_chain_child drcc
       SET drcc.rows_processed = (drcc.rows_processed+ xta_qual), drcc.action_dt_tm = sysdate
       WHERE drcc.dm_rdds_chain_child_id=xta_cc_id
       WITH nocounter
      ;end update
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       ROLLBACK
      ELSE
       COMMIT
      ENDIF
     ENDIF
     SET dm_err->eproc = "Check to see if the script needs to stop"
     CALL disp_msg(" ",dm_err->logfile,0)
     SELECT INTO "nl:"
      drcc.state_flag
      FROM dm_rdds_chain_child drcc
      WHERE drcc.dm_rdds_chain_child_id=xta_cc_id
      DETAIL
       IF (drcc.state_flag=99)
        xta_logging_val = 304
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      GO TO end_program
     ENDIF
     IF (xta_logging_val=304)
      GO TO end_program
     ENDIF
     IF (xta_high > xta_max)
      SET xta_continue_ind = 1
     ENDIF
     IF (xta_qual < xta_tot_rows)
      SET xta_gap = xta_dbl_hlv(xta_gap)
      SET xta_low = xta_high
      SET xta_high = (xta_high+ xta_gap)
     ENDIF
    ENDIF
  ENDWHILE
 ENDIF
 SET xta_logging_val = 104
#end_program
 IF (xta_logging_val != 104)
  SET xta_rows_to_process = xta_row_cnt
 ELSE
  SET xta_rows_to_process = 0
 ENDIF
 UPDATE  FROM dm_rdds_chain drc
  SET drc.state_flag = xta_logging_val, drc.error_msg = substring(1,255,dm_err->emsg), drc
   .action_dt_tm = sysdate,
   drc.rows_to_process = (drc.rows_to_process - xta_rows_to_process)
  WHERE (drc.dm_rdds_chain_id=request->chain_id)
  WITH nocounter
 ;end update
 COMMIT
 UPDATE  FROM dm_rdds_chain_child drcc
  SET drcc.state_flag = xta_logging_val, drcc.error_msg = substring(1,255,dm_err->emsg), drcc
   .action_dt_tm = sysdate
  WHERE drcc.dm_rdds_chain_child_id=xta_cc_id
  WITH nocounter
 ;end update
 COMMIT
END GO
