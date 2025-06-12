CREATE PROGRAM dm_rmc_mvract_mon:dba
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
 IF ((validate(dmam_rs->cur_id,- (123.0))=- (123.0)))
  FREE RECORD dmam_rs
  RECORD dmam_rs(
    1 cur_id = f8
    1 cur_name = vc
    1 src_id = f8
    1 src_name = vc
    1 oe_name = vc
    1 oe_dt_tm = f8
    1 refresh_time = vc
    1 num_procs = i4
    1 cycle_time = vc
    1 cur_rs_pos = i4
    1 max_lines = i4
    1 no_qual_msg = vc
    1 cnt = i4
    1 qual[*]
      2 table_name = vc
      2 action = vc
      2 act_count = i4
      2 act_hour = vc
      2 action_dt = dq8
    1 det_cnt = i4
    1 det[*]
      2 table_name = vc
      2 action = vc
      2 action_dt = vc
      2 action_text = vc
      2 audsid = f8
      2 process = vc
      2 logfile = vc
  )
 ENDIF
 DECLARE dmam_gather_data(dgd_rs=vc(ref)) = null
 SUBROUTINE dmam_gather_data(dgd_rs,dgd_audsid)
   DECLARE dgd_pos = i4 WITH protect, noconstant(0)
   DECLARE dgd_ind = i2 WITH protect, noconstant(0)
   DECLARE dgd_idx = i4 WITH protect, noconstant(0)
   DECLARE dgd_lvidx = i4 WITH protect, noconstant(0)
   IF ((dgd_rs->cur_id=0.0))
    SET dm_err->eproc = "Getting current environment_id."
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="DM_ENV_ID"
     DETAIL
      dgd_rs->cur_id = di.info_number
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN
    ENDIF
    IF (curqual=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "No local environment_id set.  Please use DM_SET_ENV_ID to set one."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN
    ENDIF
   ENDIF
   IF ((dgd_rs->src_id=0.0))
    SET dm_err->eproc = "Getting environment_id of open event."
    SELECT INTO "NL:"
     FROM dm_rdds_event_log d
     WHERE (d.cur_environment_id=dgd_rs->cur_id)
      AND d.rdds_event_key="BEGINREFERENCEDATASYNC"
      AND  NOT (list(d.paired_environment_id,d.event_reason) IN (
     (SELECT
      d1.paired_environment_id, d1.event_reason
      FROM dm_rdds_event_log d1
      WHERE (d1.cur_environment_id=dgd_rs->cur_id)
       AND d1.rdds_event_key="ENDREFERENCEDATASYNC")))
     DETAIL
      dgd_rs->src_id = d.paired_environment_id, dgd_rs->oe_name = concat(trim(d.event_reason),"(",
       format(d.event_dt_tm,"dd-mmm-yy HH:MM:SS;;q"),")"), dgd_rs->oe_dt_tm = d.event_dt_tm
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN
    ENDIF
    IF (curqual=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("No open event detected for target environment ",dgd_rs->cur_name,
      ". The mover activity report will not run.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN
    ENDIF
   ENDIF
   IF ((((dgd_rs->src_name <= " ")) OR ((dgd_rs->cur_name <= " "))) )
    SET dm_err->eproc = "Getting getting source environment name."
    SELECT INTO "NL:"
     FROM dm_environment d
     WHERE d.environment_id IN (dgd_rs->src_id, dgd_rs->cur_id)
     DETAIL
      IF ((d.environment_id=dgd_rs->cur_id))
       dgd_rs->cur_name = d.environment_name
      ELSE
       dgd_rs->src_name = d.environment_name
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN
    ENDIF
   ENDIF
   IF ((dgd_rs->cur_name <= " "))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "No environment_id in DM_ENVIORNMENT.  Please use DM_SET_ENV_ID to set one."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ELSEIF ((dgd_rs->src_name <= " "))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("No environment_id in DM_ENVIORNMENT for source environment_id ",trim(
      cnvtstring(dgd_rs->src_id)))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   SET dgd_rs->refresh_time = concat("As of ",format(cnvtdatetime(curdate,curtime3),
     "dd-mmm-yy HH:MM:SS;;q")," (auto refresh in 30 sec)")
   IF ((dgd_rs->oe_dt_tm > 0.0))
    SET dm_err->eproc = "Query for Mover Activity"
    SET dgd_rs->cnt = 0
    SET stat = alterlist(dgd_rs->qual,0)
    SELECT INTO "nl:"
     act_hour = format(d.audit_dt_tm,"DD-MMM-YYYY HH;;D"), d.action, d.table_name,
     cnt = count(*), ord_dt = max(d.audit_dt_tm)
     FROM dm_chg_log_audit d
     WHERE d.action IN ("INSERT", "UPDATE", "BATCH END", "RTBLCREATE", "FAILREASON",
     "BATCH START", "DELETE")
      AND d.audit_dt_tm >= cnvtdatetime(dgd_rs->oe_dt_tm)
     GROUP BY format(d.audit_dt_tm,"DD-MMM-YYYY HH;;D"), d.table_name, d.action
     ORDER BY ord_dt DESC, d.action, d.table_name
     DETAIL
      dgd_ind = 0
      IF (d.action="BATCH*")
       dgd_pos = locateval(dgd_pos,1,dgd_rs->cnt,d.action,dgd_rs->qual[dgd_pos].action,
        act_hour,dgd_rs->qual[dgd_pos].act_hour)
       IF (dgd_pos > 0)
        dgd_rs->qual[dgd_pos].act_count = (dgd_rs->qual[dgd_pos].act_count+ cnt), dgd_ind = 1
       ENDIF
      ENDIF
      IF (dgd_ind=0)
       dgd_rs->cnt = (dgd_rs->cnt+ 1)
       IF (mod(dgd_rs->cnt,10)=1)
        stat = alterlist(dgd_rs->qual,(dgd_rs->cnt+ 9))
       ENDIF
       dgd_rs->qual[dgd_rs->cnt].table_name = d.table_name, dgd_rs->qual[dgd_rs->cnt].action = d
       .action
       IF (d.action="BATCH*")
        dgd_rs->qual[dgd_rs->cnt].table_name = " "
       ELSEIF (d.action="FAILREASON")
        dgd_rs->qual[dgd_rs->cnt].action = "NO MERGE"
       ELSEIF (d.action="RTBLCREATE")
        dgd_rs->qual[dgd_rs->cnt].action = "TEMP TABLE CREATED"
       ELSEIF (d.action IN ("INSERT", "UPDATE"))
        dgd_rs->qual[dgd_rs->cnt].action = "INSERT/UPDATE"
       ENDIF
       dgd_rs->qual[dgd_rs->cnt].act_hour = act_hour, dgd_rs->qual[dgd_rs->cnt].act_count = cnt,
       dgd_rs->qual[dgd_rs->cnt].action_dt = ord_dt
      ENDIF
     FOOT REPORT
      stat = alterlist(dgd_rs->qual,dgd_rs->cnt), dgd_rs->qual[1].act_hour = concat(dgd_rs->qual[1].
       act_hour,"**"), dgd_rs->qual[dgd_rs->cnt].act_hour = concat(act_hour,"**")
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN
    ENDIF
   ENDIF
   SET dm_err->eproc = "Query for number of mover processes"
   SELECT INTO "NL:"
    cnt = count(*)
    FROM dm_refchg_process d
    WHERE d.refchg_type="MOVER PROCESS"
     AND  NOT (d.refchg_status IN ("WRITING HANG FILE", "ORPHANED MOVER", "HANGING MOVER"))
     AND (d.env_source_id=dgd_rs->src_id)
     AND d.rdbhandle_value IN (
    (SELECT
     audsid
     FROM gv$session))
    DETAIL
     dgd_rs->num_procs = cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   IF (dgd_audsid > 0)
    SET dgd_rs->det_cnt = 0
    SET stat = alterlist(dgd_rs->det,0)
    SELECT INTO "nl:"
     FROM dm_chg_log_audit d
     WHERE d.action IN ("INSERT", "UPDATE", "BATCH END", "RTBLCREATE", "FAILREASON",
     "BATCH START", "DELETE")
      AND d.audit_dt_tm >= cnvtdatetime(dgd_rs->oe_dt_tm)
      AND d.updt_applctx=dgd_audsid
     ORDER BY d.audit_dt_tm DESC, d.action, d.table_name
     DETAIL
      dgd_rs->det_cnt = (dgd_rs->det_cnt+ 1)
      IF (mod(dgd_rs->det_cnt,10)=1)
       stat = alterlist(dgd_rs->det,(dgd_rs->det_cnt+ 9))
      ENDIF
      dgd_rs->det[dgd_rs->det_cnt].table_name = d.table_name, dgd_rs->det[dgd_rs->det_cnt].action = d
      .action
      IF (d.action="BATCH*")
       dgd_rs->det[dgd_rs->det_cnt].table_name = " "
      ELSEIF (d.action="FAILREASON")
       dgd_rs->det[dgd_rs->det_cnt].action = "NO MERGE"
      ELSEIF (d.action="RTBLCREATE")
       dgd_rs->det[dgd_rs->det_cnt].action = "TEMP TABLE CREATED"
      ELSEIF (d.action IN ("INSERT", "UPDATE"))
       dgd_rs->det[dgd_rs->det_cnt].action = "INSERT/UPDATE"
      ENDIF
      dgd_rs->det[dgd_rs->det_cnt].action_dt = format(d.audit_dt_tm,"dd-mmm-yy HH:MM:SS;;q"), dgd_rs
      ->det[dgd_rs->det_cnt].action_text = d.text, dgd_rs->det[dgd_rs->det_cnt].audsid = d
      .updt_applctx,
      dgd_rs->det[dgd_rs->det_cnt].process = "Not Active", dgd_rs->det[dgd_rs->det_cnt].logfile =
      "Not Available"
     FOOT REPORT
      stat = alterlist(dgd_rs->det,dgd_rs->det_cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN
    ENDIF
    SET dm_err->eproc = "Query for mover process ids"
    SELECT INTO "NL:"
     FROM v$session v
     WHERE v.audsid=dgd_audsid
     DETAIL
      FOR (dgd_lvidx = 1 TO dgd_rs->det_cnt)
        dgd_rs->det[dgd_lvidx].process = v.process
      ENDFOR
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN
    ENDIF
    SET dm_err->eproc = "Query for mover log files"
    SELECT INTO "NL:"
     FROM dm_refchg_process drp
     WHERE drp.rdbhandle_value=dgd_audsid
     DETAIL
      FOR (dgd_lvidx = 1 TO dgd_rs->det_cnt)
        dgd_rs->det[dgd_lvidx].logfile = drp.log_file
      ENDFOR
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN
    ENDIF
   ENDIF
   SET dm_err->eproc = "Checking last cycle time"
   SELECT INTO "NL:"
    FROM dm_info d
    WHERE d.info_domain="DATA MANAGEMENT"
     AND d.info_name="RDDS STOP TIME"
    DETAIL
     dgd_rs->cycle_time = concat(trim(cnvtstring(datetimediff(cnvtdatetime(curdate,curtime3),d
         .info_date,4)))," minutes ago")
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ELSEIF (curqual=0)
    SET dgd_rs->cycle_time = "Not Yet Cycled"
   ENDIF
 END ;Subroutine
 DECLARE drdc_wrap_menu_lines(dwml_str=vc,dwml_cur_row_pos=i4,dwml_cur_col_pos=i4,
  dwml_multi_line_buffer=vc,dwml_max_lines=i4,
  dwml_max_col=i4) = i4
 DECLARE drdc_get_name(dgn_name=vc,dgn_file=vc) = vc
 DECLARE drdc_file_success(dfs_name=vc,dfs_file_name=vc,dfs_error_ind=i2) = null
 IF ((validate(dclm_rs->cur_id,- (123.0))=- (123.0)))
  FREE RECORD dclm_rs
  RECORD dclm_rs(
    1 cur_id = f8
    1 cur_name = vc
    1 src_id = f8
    1 src_name = vc
    1 oe_name = vc
    1 db_link = vc
    1 refresh_time = vc
    1 cur_tier = i4
    1 del_row_ind = i2
    1 max_tier = i4
    1 num_procs = i4
    1 nomv_ind = i2
    1 mover_stale_ind = i2
    1 cycle_time = vc
    1 cur_rs_pos = i4
    1 max_lines = i4
    1 no_qual_msg = vc
    1 ctp_str = vc
    1 cts_str = vc
    1 group_ind = i2
    1 cnt = i4
    1 qual[*]
      2 table_name = vc
      2 log_type = vc
      2 row_cnt = i4
      2 context_name = vc
      2 nomv_ind = i2
    1 reporting_cnt = i4
    1 reporting_qual[*]
      2 log_type = vc
    1 context_cnt = i4
    1 context_qual[*]
      2 values = vc
    1 audit_cnt = i4
    1 audit_qual[*]
      2 log_type = vc
    1 non_ctxt_cnt = i4
    1 non_ctxt_qual[*]
      2 values = vc
  )
 ENDIF
 IF ((validate(dclm_all->cur_id,- (123.0))=- (123.0)))
  FREE RECORD dclm_all
  RECORD dclm_all(
    1 cur_id = f8
    1 cur_name = vc
    1 src_id = f8
    1 src_name = vc
    1 oe_name = vc
    1 db_link = vc
    1 refresh_time = vc
    1 cur_rs_pos = i4
    1 max_lines = i4
    1 no_qual_msg = vc
    1 cnt = i4
    1 qual[*]
      2 table_name = vc
      2 log_type = vc
      2 row_cnt = i4
      2 context_name = vc
      2 nomv_ind = i2
    1 audit_cnt = i4
    1 audit_qual[*]
      2 log_type = vc
    1 type_cnt = i4
    1 lt_qual[*]
      2 log_type = vc
      2 lt_cnt = i4
  )
 ENDIF
 IF ((validate(dclm_issues->cur_id,- (123.0))=- (123.0)))
  FREE RECORD dclm_issues
  RECORD dclm_issues(
    1 cur_id = f8
    1 cur_name = vc
    1 src_id = f8
    1 src_name = vc
    1 oe_name = vc
    1 db_link = vc
    1 refresh_time = vc
    1 max_lines = i4
    1 cur_rs_pos = i4
    1 ctp_str = vc
    1 sort_flag = i4
    1 cur_flag = i4
    1 context_cnt = i4
    1 context_qual[*]
      2 values = vc
    1 lt_cnt = i4
    1 lt_qual[*]
      2 log_type = vc
      2 inv_ind = i2
      2 log_msg = vc
      2 child_type = vc
      2 log_type_sum = i4
      2 child_cnt_sum = i4
      2 tab_cnt = i4
      2 tab_qual[*]
        3 table_name = vc
        3 row_cnt = i4
  )
 ENDIF
 SUBROUTINE drdc_wrap_menu_lines(dwml_str,dwml_cur_row_pos,dwml_cur_col_pos,dwml_multi_line_buffer,
  dwml_max_lines,dwml_max_col)
   DECLARE dwml_temp_str = vc WITH protect, noconstant("")
   DECLARE dwml_done_ind = i2 WITH protect, noconstant(0)
   DECLARE dwml_partial_str = vc WITH protect, noconstant("")
   DECLARE dwml_stop_pos = i4 WITH protect, noconstant(0)
   DECLARE dwml_line_cnt = i4 WITH protect, noconstant(0)
   DECLARE dwml_max_val = i4 WITH protect, noconstant(0)
   SET dwml_max_val = dwml_max_col
   IF (dwml_max_val=0)
    SET dwml_max_val = 132
   ENDIF
   SET dwml_temp_str = dwml_str
   SET dwml_done_ind = 0
   WHILE (dwml_done_ind=0)
     IF (size(dwml_temp_str) < dwml_max_val)
      SET dwml_partial_str = dwml_temp_str
      SET dwml_done_ind = 1
     ELSE
      SET dwml_partial_str = substring(1,value(dwml_max_val),dwml_temp_str)
      SET dwml_stop_pos = findstring(" ",dwml_partial_str,1,1)
      IF (dwml_stop_pos=0)
       SET dwml_stop_pos = dwml_max_val
      ENDIF
      SET dwml_partial_str = substring(1,dwml_stop_pos,dwml_temp_str)
      IF (dwml_multi_line_buffer >= " ")
       SET dwml_temp_str = concat(dwml_multi_line_buffer,substring((dwml_stop_pos+ 1),(size(
          dwml_temp_str) - dwml_stop_pos),dwml_temp_str))
      ELSE
       SET dwml_temp_str = substring((dwml_stop_pos+ 1),(size(dwml_temp_str) - dwml_stop_pos),
        dwml_temp_str)
      ENDIF
     ENDIF
     IF (((dwml_line_cnt+ 1)=dwml_max_lines)
      AND dwml_done_ind=0
      AND dwml_max_lines > 0)
      SET dwml_partial_str = concat(substring(1,(dwml_max_val - 3),dwml_partial_str),"...")
      SET dwml_done_ind = 1
     ENDIF
     CALL text(dwml_cur_row_pos,dwml_cur_col_pos,dwml_partial_str)
     SET dwml_cur_row_pos = (dwml_cur_row_pos+ 1)
     SET dwml_line_cnt = (dwml_line_cnt+ 1)
   ENDWHILE
   RETURN(dwml_cur_row_pos)
 END ;Subroutine
 SUBROUTINE drdc_get_name(dgn_name,dgn_file)
   SET dm_err->eproc = "Getting report file name"
   DECLARE dgn_file_name = vc WITH protect, noconstant("")
   DECLARE dgn_done_ind = i2 WITH protect, noconstant(0)
   DECLARE dgn_title = vc WITH protect, noconstant("")
   SET dgn_title = concat("*** ",dgn_name," ***")
   WHILE (dgn_done_ind=0)
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,4,132)
     CALL text(3,(66 - ceil((size(dgn_title)/ 2))),dgn_title)
     CALL text(6,3,concat("Please enter a file name for the ",dgn_name,
       " report to extract into. (0 to exit): "))
     CALL accept(7,15,"P(30);CU",value(dgn_file))
     SET dgn_file_name = curaccept
     SET dgn_file_name = cnvtlower(dgn_file_name)
     IF (dgn_file_name="0")
      RETURN("-1")
      CALL text(20,3,"No extract will be made")
      CALL pause(3)
      SET dgn_done_ind = 1
     ENDIF
     IF (findstring(".",dgn_file_name)=0)
      SET dgn_file_name = concat(dgn_file_name,".csv")
      SET dgn_done_ind = 1
     ENDIF
     IF (substring(findstring(".",dgn_file_name),size(dgn_file_name,1),dgn_file_name) != ".csv")
      CALL text(20,3,"Invalid file type, file extension must be .csv")
      CALL pause(3)
     ELSE
      SET dgn_done_ind = 1
     ENDIF
   ENDWHILE
   RETURN(dgn_file_name)
 END ;Subroutine
 SUBROUTINE drdc_file_success(dfs_name,dfs_file_name,dfs_error_ind)
   DECLARE dfs_title = vc WITH protect, noconstant("")
   DECLARE dfs_pos = i4 WITH protect, noconstant(0)
   SET dfs_title = concat("*** ",dfs_name," ***")
   IF (dfs_error_ind=0)
    CALL clear(1,1)
    SET width = 132
    CALL box(1,1,4,132)
    CALL text(3,(66 - ceil((size(dfs_title)/ 2))),dfs_title)
    CALL text(6,3,"Report complete!")
    CALL text(7,3,
     "For optimal viewing, the following file needs to be moved from CCLUSERDIR to a PC:")
    CALL text(8,3,"-----------------------------")
    CALL text(9,3,dfs_file_name)
    CALL text(10,3,"-----------------------------")
    CALL text(12,3,"Press enter to return:")
    CALL accept(12,26,"X;CUS","E")
   ELSE
    CALL clear(1,1)
    SET width = 132
    CALL box(1,1,4,132)
    CALL text(3,(66 - ceil((size(dfs_title)/ 2))),dfs_title)
    CALL text(6,3,"Report was not successful.  The following error occurred!")
    SET dfs_pos = drdc_wrap_menu_lines(dm_err->emsg,7,3,"   ",0,
     120)
    CALL text((dfs_pos+ 1),3,"Press enter to return:")
    CALL accept((dfs_pos+ 1),26,"X;CUS","E")
   ENDIF
   RETURN(null)
 END ;Subroutine
 DECLARE dmam_show_help(dsh_rs=vc(ref),dsh_ind=i4) = null
 DECLARE dmam_refresh_screen(rs_rec=vc(ref)) = null
 DECLARE dmam_gather_mvr_pid(dgmp_rs=vc(ref)) = null
 DECLARE dmam_show_detail(dsd_rs=vc(ref),dsd_det=f8,dsd_pos=i4,dsd_process=vc) = i4
 DECLARE drmm_start = i4 WITH protect, noconstant(0)
 DECLARE dmam_det = f8 WITH protect, noconstant(0.0)
 SET dm_err->eproc = "Starting dm_rmc_mvract_mon"
 IF (check_logfile("dm_rmc_mvract_mon",".log","DM_RMC_MVRACT_MON LOG")=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to Create Log File"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_mon
 ENDIF
 IF ((dmam_rs->cur_name <= " "))
  SELECT INTO "nl:"
   FROM dm_info a,
    dm_environment b
   PLAN (a
    WHERE a.info_name="DM_ENV_ID"
     AND a.info_domain="DATA MANAGEMENT")
    JOIN (b
    WHERE a.info_number=b.environment_id)
   DETAIL
    dmam_rs->cur_id = b.environment_id, dmam_rs->cur_name = b.environment_name
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET dm_err->eproc = "Fatal Error: current environment id not found"
   CALL disp_msg(" ",dm_err->logfile,0)
   GO TO exit_mon
  ENDIF
 ENDIF
 SET message = window
 CALL clear(1,1)
 SET width = 132
 CALL text(1,54,"RDDS Mover Activity Monitor")
 CALL text(2,1,"Env: ")
 CALL text(2,30,"Source:")
 CALL text(2,81,"Open Event:")
 CALL text(3,1,"Number of Movers Currently Running:")
 CALL text(3,81,"Last Cycle Time:")
 CALL text(5,1,fillstring(132,"-"))
 CALL video(b)
 CALL text(10,56,"Generating Report...")
 CALL text(24,1,"Gathering Environment information...")
 SET dmam_rs->max_lines = 15
 CALL dmam_gather_data(dmam_rs,0)
 IF ((dm_err->err_ind=1))
  GO TO exit_mon
 ENDIF
 WHILE (true)
   CALL video(n)
   SET accept = time(30)
   SET accept = scroll
   CALL dmam_refresh_screen(dmam_rs)
   CALL accept(24,18,"X;CUS","R"
    WHERE curaccept IN ("R", "E", "D", "H"))
   CASE (curscroll)
    OF 0:
     CASE (curaccept)
      OF "R":
       SET dmam_rs->cur_rs_pos = 0
       CALL video(b)
       CALL dmam_gather_data(dmam_rs,0)
       IF ((dm_err->err_ind=1))
        GO TO exit_mon
       ENDIF
      OF "E":
       GO TO exit_mon
      OF "H":
       SET accept = notime
       SET accept = noscroll
       CALL dmam_show_help(dmam_rs,0)
       SET accept = time(30)
       SET accept = scroll
      OF "D":
       CALL dmam_gather_mvr_pid(dmam_rs)
       IF ((dm_err->err_ind=1))
        GO TO exit_mon
       ENDIF
     ENDCASE
    OF 1:
    OF 6:
     IF (((dmam_rs->cur_rs_pos+ dmam_rs->max_lines) <= dmam_rs->cnt))
      SET dmam_rs->cur_rs_pos = (dmam_rs->cur_rs_pos+ dmam_rs->max_lines)
     ENDIF
    OF 2:
    OF 5:
     SET dmam_rs->cur_rs_pos = greatest((dmam_rs->cur_rs_pos - dmam_rs->max_lines),0)
   ENDCASE
 ENDWHILE
 SUBROUTINE dmam_refresh_screen(rs_rec)
   DECLARE rs_start = i4 WITH protect, noconstant(4)
   DECLARE rs_done_ind = i2 WITH protect, noconstant(0)
   DECLARE rs_temp_str = vc WITH protect, noconstant("")
   DECLARE rs_partial_str = vc WITH protect, noconstant("")
   DECLARE rs_stop_pos = i4 WITH protect, noconstant(0)
   SET message = window
   SET width = 132
   CALL clear(1,1)
   CALL text(1,43,"RDDS Mover Activity Monitor - Hourly Summary")
   CALL text(2,1,concat("Env: ",rs_rec->cur_name))
   CALL text(2,30,concat("Source: ",rs_rec->src_name))
   CALL text(2,(132 - size(concat("Open Event: ",rs_rec->oe_name))),concat("Open Event: ",rs_rec->
     oe_name))
   CALL text(3,1,concat("Number of Movers Currently Running: ",trim(cnvtstring(rs_rec->num_procs))))
   CALL text(3,(132 - size(concat("Open Event: ",rs_rec->oe_name))),concat("Last Cycle Time: ",rs_rec
     ->cycle_time))
   SET rs_start = 4
   CALL text(rs_start,1,fillstring(132,"-"))
   IF ((rs_rec->cur_rs_pos > 1))
    CALL text((rs_start+ 1),85,"More data up...")
   ENDIF
   SET rs_start = (rs_start+ 1)
   IF ((rs_rec->no_qual_msg=""))
    CALL text(rs_start,1,"HOUR")
    CALL text(rs_start,18,"ACTION")
    CALL text(rs_start,37,"TABLE_NAME")
    CALL text(rs_start,70,"COUNT")
    SET rs_rec->max_lines = (22 - rs_start)
    FOR (rs_stop_pos = 1 TO rs_rec->max_lines)
      IF (((rs_stop_pos+ rs_rec->cur_rs_pos) <= rs_rec->cnt))
       CALL text((rs_stop_pos+ rs_start),1,rs_rec->qual[(rs_stop_pos+ rs_rec->cur_rs_pos)].act_hour)
       CALL text((rs_stop_pos+ rs_start),18,rs_rec->qual[(rs_stop_pos+ rs_rec->cur_rs_pos)].action)
       CALL text((rs_stop_pos+ rs_start),37,rs_rec->qual[(rs_stop_pos+ rs_rec->cur_rs_pos)].
        table_name)
       CALL text((rs_stop_pos+ rs_start),70,build(rs_rec->qual[(rs_stop_pos+ rs_rec->cur_rs_pos)].
         act_count))
      ENDIF
    ENDFOR
    IF (((rs_rec->max_lines+ rs_rec->cur_rs_pos) <= rs_rec->cnt))
     CALL text((rs_start+ rs_rec->max_lines),85,"More data down...")
    ENDIF
   ELSE
    SET rs_start = (rs_start+ 3)
    SET rs_start = drdc_wrap_menu_lines(rs_rec->no_qual_msg,rs_start,6,"",0,
     120)
   ENDIF
   SET rs_temp_str = concat(fillstring(value(((132 - size(rs_rec->refresh_time))/ 2)),"-"),rs_rec->
    refresh_time,fillstring(value(((132 - size(rs_rec->refresh_time))/ 2)),"-"))
   CALL text(23,1,rs_temp_str)
   CALL text(24,1,concat("Command Options: __ (R)efresh, (H)elp, (D)etail by Mover, (E)xit"))
 END ;Subroutine
 SUBROUTINE dmam_show_help(dsh_rec,dsh_ind)
   DECLARE dsh_start = i4 WITH protect, noconstant(4)
   DECLARE dsh_done_ind = i2 WITH protect, noconstant(0)
   DECLARE dsh_temp_str = vc WITH protect, noconstant("")
   DECLARE dsh_partial_str = vc WITH protect, noconstant("")
   DECLARE dsh_stop_pos = i4 WITH protect, noconstant(0)
   SET message = window
   CALL clear(1,1)
   SET width = 132
   IF (dsh_ind=0)
    CALL text(1,43,"RDDS Mover Activity Monitor - Hourly Summary")
   ELSE
    CALL text(1,43,"RDDS Mover Activity Monitor - Detail by Mover")
   ENDIF
   CALL text(2,1,concat("Env: ",dsh_rec->cur_name))
   CALL text(2,30,concat("Source: ",dsh_rec->src_name))
   CALL text(2,(132 - size(concat("Open Event: ",dsh_rec->oe_name))),concat("Open Event: ",dsh_rec->
     oe_name))
   CALL text(3,1,concat("Number of Movers Currently Running: ",trim(cnvtstring(dsh_rec->num_procs))))
   CALL text(3,(132 - size(concat("Open Event: ",dsh_rec->oe_name))),concat("Last Cycle Time: ",
     dsh_rec->cycle_time))
   CALL text(4,1,fillstring(132,"-"))
   SET dsh_start = (dsh_start+ 1)
   IF (dsh_ind=0)
    CALL text(dsh_start,1,
     "This report displays an hourly summary of RDDS mover actions by table in the target domain.")
   ELSE
    CALL text(dsh_start,1,
     "This report displays a summary of RDDS mover actions by table for a single mover in the target domain."
     )
   ENDIF
   CALL text((dsh_start+ 1),1,concat(
     "This report should be used when actively running movers in target domain so that progress of RDDS ",
     "movers can be monitored."))
   SET dsh_start = (dsh_start+ 2)
   CALL text(dsh_start,1,
    "An RDDS Event must be open in current target environment before using this report.")
   IF (dsh_ind=0)
    CALL text((dsh_start+ 2),1,
     "**Mover activity displayed during this hour may not be all activity that occurred during the hour."
     )
    SET dsh_start = (dsh_start+ 4)
   ELSE
    SET dsh_start = (dsh_start+ 2)
   ENDIF
   CALL text(dsh_start,1,"The following actions from the mover are included in the report:")
   CALL text((dsh_start+ 1),5,
    "- INSERT/UPDATE: A row has been marked for insert or update in the temporary tables")
   CALL text((dsh_start+ 2),5,"- DELETE: A row has been marked for delete in the temporary tables")
   CALL text((dsh_start+ 3),5,
    "- NO MERGE: A row could not be processed to a merged status at this time")
   CALL text((dsh_start+ 4),5,
    "- BATCH START: An RDDS mover has gathered a new batch of change log rows from source to process"
    )
   CALL text((dsh_start+ 5),5,
    "- BATCH END: An RDDS mover has finished processing its current batch of change log rows from source"
    )
   CALL text((dsh_start+ 6),5,
    "- TEMP TABLE CREATED: the RDDS mover created an additional temporary table")
   SET dsh_start = (dsh_start+ 8)
   CALL text(dsh_start,1,"Press Enter to (E)xit __")
   CALL accept(dsh_start,23,"X;CUS","E"
    WHERE curaccept IN ("E"))
 END ;Subroutine
 SUBROUTINE dmam_gather_mvr_pid(dgmp_rs)
   DECLARE dgmp_start = i4 WITH protect, noconstant(4)
   DECLARE dgmp_done_ind = i2 WITH protect, noconstant(0)
   DECLARE dgmp_temp_str = vc WITH protect, noconstant("")
   DECLARE dgmp_partial_str = vc WITH protect, noconstant("")
   DECLARE dgmp_stop_pos = i4 WITH protect, noconstant(0)
   DECLARE dgmp_num = vc WITH protect, noconstant("")
   DECLARE dgmp_ret = f8 WITH protect, noconstant(0.0)
   DECLARE dgmp_ind = i2 WITH protect, noconstant(0)
   DECLARE dgmp_idx = i4 WITH protect, noconstant(0)
   DECLARE dgmp_lvidx = i4 WITH protect, noconstant(0)
   DECLARE dgmp_col = i4 WITH protect, noconstant(0)
   DECLARE dgmp_max = vc WITH protect, noconstant("")
   DECLARE dgmp_val = i2 WITH protect, noconstant(0)
   FREE RECORD dgmp_rec
   RECORD dgmp_rec(
     1 cnt = i4
     1 qual[*]
       2 audsid = f8
       2 process = vc
       2 audit_dt_tm = vc
   )
   SET dm_err->eproc = "Gathering mover data..."
   SELECT INTO "nl:"
    d.updt_applctx, audit_max = max(d.audit_dt_tm)
    FROM dm_chg_log_audit d
    WHERE d.action IN ("INSERT", "UPDATE", "BATCH END", "RTBLCREATE", "FAILREASON",
    "BATCH START", "DELETE")
     AND d.audit_dt_tm >= cnvtdatetime(dgmp_rs->oe_dt_tm)
     AND d.updt_applctx > 0.0
    GROUP BY d.updt_applctx
    ORDER BY audit_max DESC
    DETAIL
     dgmp_rec->cnt = (dgmp_rec->cnt+ 1), stat = alterlist(dgmp_rec->qual,dgmp_rec->cnt), dgmp_rec->
     qual[dgmp_rec->cnt].audsid = d.updt_applctx,
     dgmp_rec->qual[dgmp_rec->cnt].audit_dt_tm = format(audit_max,"dd-mmm-yy HH:MM:SS;;q"), dgmp_rec
     ->qual[dgmp_rec->cnt].process = "Not Active"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   SELECT INTO "nl:"
    FROM v$session v
    WHERE expand(dgmp_idx,1,dgmp_rec->cnt,v.audsid,dgmp_rec->qual[dgmp_idx].audsid)
    DETAIL
     dgmp_lvidx = locateval(dgmp_lvidx,1,dgmp_rec->cnt,v.audsid,dgmp_rec->qual[dgmp_lvidx].audsid)
     IF (dgmp_lvidx > 0)
      dgmp_rec->qual[dgmp_lvidx].process = v.process
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN
   ENDIF
   WHILE (dgmp_ind=0)
     CALL video(n)
     SET accept = notime
     SET accept = scroll
     SET message = window
     SET width = 132
     CALL clear(1,1)
     CALL text(1,43,"RDDS Mover Activity Monitor - Detail by Mover")
     CALL text(2,1,concat("Env: ",dgmp_rs->cur_name))
     CALL text(2,30,concat("Source: ",dgmp_rs->src_name))
     CALL text(2,(132 - size(concat("Open Event: ",dgmp_rs->oe_name))),concat("Open Event: ",dgmp_rs
       ->oe_name))
     CALL text(3,1,concat("Number of Movers Currently Running: ",trim(cnvtstring(dgmp_rs->num_procs))
       ))
     CALL text(3,(132 - size(concat("Open Event: ",dgmp_rs->oe_name))),concat("Last Cycle Time: ",
       dgmp_rs->cycle_time))
     SET dgmp_start = 4
     CALL text(dgmp_start,1,fillstring(132,"-"))
     IF ((dgmp_rs->cur_rs_pos > 1))
      CALL text((dgmp_start+ 1),85,"More data up...")
     ENDIF
     SET dgmp_start = (dgmp_start+ 1)
     CALL text(dgmp_start,1,"Please Choose a Mover to view Activity Details:")
     SET dgmp_start = (dgmp_start+ 1)
     CALL text(dgmp_start,3,"MOVER (PROCESS ID)")
     CALL text(dgmp_start,30,"LAST ACTION DATE/TIME")
     SET dgmp_rs->max_lines = (22 - dgmp_start)
     SET dgmp_num = trim(cnvtstring(((dgmp_stop_pos+ dgmp_rs->cur_rs_pos)+ 1)))
     FOR (dgmp_stop_pos = 1 TO dgmp_rs->max_lines)
       IF (((dgmp_stop_pos+ dgmp_rs->cur_rs_pos) <= dgmp_rec->cnt))
        IF (((dgmp_stop_pos+ dgmp_rs->cur_rs_pos) < 10))
         SET dgmp_col = 5
        ELSE
         SET dgmp_col = 4
        ENDIF
        CALL text((dgmp_stop_pos+ dgmp_start),dgmp_col,concat(trim(cnvtstring((dgmp_stop_pos+ dgmp_rs
            ->cur_rs_pos))),"   (",dgmp_rec->qual[(dgmp_stop_pos+ dgmp_rs->cur_rs_pos)].process,")"))
        CALL text((dgmp_stop_pos+ dgmp_start),30,dgmp_rec->qual[(dgmp_stop_pos+ dgmp_rs->cur_rs_pos)]
         .audit_dt_tm)
       ENDIF
     ENDFOR
     IF (((dgmp_rs->max_lines+ dgmp_rs->cur_rs_pos) < dgmp_rec->cnt))
      CALL text((dgmp_start+ dgmp_rs->max_lines),85,"More data down...")
     ENDIF
     SET dgmp_temp_str = fillstring(132,"-")
     CALL text(23,1,dgmp_temp_str)
     IF ((((dgmp_stop_pos+ dgmp_rs->cur_rs_pos) - 1) > dgmp_rec->cnt))
      SET dgmp_max = trim(cnvtstring(dgmp_rec->cnt))
     ELSE
      SET dgmp_max = trim(cnvtstring(((dgmp_stop_pos+ dgmp_rs->cur_rs_pos) - 1)))
     ENDIF
     CALL text(24,1,concat("Command Options: __ (",trim(cnvtstring(((dgmp_stop_pos+ dgmp_rs->
         cur_rs_pos) - dgmp_rs->max_lines))),"-",dgmp_max,") Detail by Mover, (H)elp, (E)xit"))
     SET dgmp_num = trim(cnvtstring((dgmp_stop_pos+ dgmp_rs->cur_rs_pos)))
     CALL accept(24,18,"XX;CUS","E"
      WHERE ((curaccept IN ("E", "H")) OR ((cnvtint(curaccept) >= ((dgmp_stop_pos+ dgmp_rs->
      cur_rs_pos) - dgmp_rs->max_lines))
       AND cnvtint(curaccept) <= cnvtint(dgmp_max))) )
     CASE (curscroll)
      OF 0:
       CASE (curaccept)
        OF "E":
         SET dgmp_ret = 0
         SET dgmp_ind = 1
         RETURN
        OF "H":
         SET accept = notime
         SET accept = noscroll
         CALL dmam_show_help(dgmp_rs,1)
         SET dgmp_rs->cur_rs_pos = 0
         SET accept = time(30)
         SET accept = scroll
        ELSE
         SET dgmp_pos = cnvtint(curaccept)
         SET dgmp_ret = dgmp_rec->qual[dgmp_pos].audsid
         SET dgmp_val = dmam_show_detail(dgmp_rs,dgmp_ret,dgmp_pos,dgmp_rec->qual[dgmp_pos].process)
         SET dgmp_ret = 0
         IF (dgmp_val=0)
          SET dgmp_ind = 1
         ENDIF
       ENDCASE
      OF 1:
      OF 6:
       IF (((dgmp_rs->cur_rs_pos+ dgmp_rs->max_lines) < dgmp_rec->cnt))
        SET dgmp_rs->cur_rs_pos = (dgmp_rs->cur_rs_pos+ dgmp_rs->max_lines)
       ENDIF
      OF 2:
      OF 5:
       SET dgmp_rs->cur_rs_pos = greatest((dgmp_rs->cur_rs_pos - dgmp_rs->max_lines),0)
     ENDCASE
   ENDWHILE
   RETURN
 END ;Subroutine
 SUBROUTINE dmam_show_detail(dsd_rec,dsd_det,dsd_pos,dsd_process)
   DECLARE dsd_start = i4 WITH protect, noconstant(5)
   DECLARE dsd_done_ind = i2 WITH protect, noconstant(0)
   DECLARE dsd_temp_str = vc WITH protect, noconstant("")
   DECLARE dsd_partial_str = vc WITH protect, noconstant("")
   DECLARE dsd_stop_pos = i4 WITH protect, noconstant(0)
   DECLARE dsd_ind = i2 WITH protect, noconstant(0)
   CALL dmam_gather_data(dsd_rec,dsd_det)
   SET dsd_rec->cur_rs_pos = 0
   WHILE (dsd_ind=0)
     SET accept = time(30)
     SET accept = scroll
     SET message = window
     SET width = 132
     CALL clear(1,1)
     CALL text(1,43,"RDDS Mover Activity Monitor - Detail by Mover")
     CALL text(2,1,concat("Env: ",dsd_rec->cur_name))
     CALL text(2,30,concat("Source: ",dsd_rec->src_name))
     CALL text(2,(132 - size(concat("Open Event: ",dsd_rec->oe_name))),concat("Open Event: ",dsd_rec
       ->oe_name))
     CALL text(3,1,concat("Number of Movers Currently Running: ",trim(cnvtstring(dsd_rec->num_procs))
       ))
     CALL text(3,(132 - size(concat("Open Event: ",dsd_rec->oe_name))),concat("Last Cycle Time: ",
       dsd_rec->cycle_time))
     CALL text(4,1,concat("Detail Activity for Mover ",trim(cnvtstring(dsd_pos))," (",dsd_process,")"
       ))
     CALL text(4,(132 - size(concat("Open Event: ",dsd_rec->oe_name))),concat("Log File: ",dsd_rec->
       det[1].logfile))
     SET dsd_start = 5
     CALL text(dsd_start,1,fillstring(132,"-"))
     IF ((dsd_rec->cur_rs_pos > 1))
      CALL text((dsd_start+ 1),100,"More data up...")
     ENDIF
     SET dsd_start = (dsd_start+ 1)
     CALL text(dsd_start,1,"AUDIT DATE/TIME")
     CALL text(dsd_start,20,"ACTION")
     CALL text(dsd_start,40,"TABLE_NAME")
     CALL text(dsd_start,75,"ACTION DETAIL")
     SET dsd_rec->max_lines = (22 - dsd_start)
     FOR (dsd_stop_pos = 1 TO dsd_rec->max_lines)
       IF (((dsd_stop_pos+ dsd_rec->cur_rs_pos) <= dsd_rec->det_cnt))
        CALL text((dsd_stop_pos+ dsd_start),1,dsd_rec->det[(dsd_stop_pos+ dsd_rec->cur_rs_pos)].
         action_dt)
        CALL text((dsd_stop_pos+ dsd_start),20,dsd_rec->det[(dsd_stop_pos+ dsd_rec->cur_rs_pos)].
         action)
        CALL text((dsd_stop_pos+ dsd_start),40,dsd_rec->det[(dsd_stop_pos+ dsd_rec->cur_rs_pos)].
         table_name)
        IF ((dsd_rec->det[(dsd_stop_pos+ dsd_rec->cur_rs_pos)].action="NO MERGE"))
         SET dsd_stop_pos = drdc_wrap_menu_lines(dsd_rec->det[(dsd_stop_pos+ dsd_rec->cur_rs_pos)].
          action_text,(dsd_stop_pos+ dsd_start),75,"",dsd_rec->max_lines,
          55)
         SET dsd_stop_pos = ((dsd_stop_pos - dsd_start) - 1)
        ENDIF
       ENDIF
     ENDFOR
     IF (((dsd_rec->max_lines+ dsd_rec->cur_rs_pos) <= dsd_rec->det_cnt))
      SET dsd_len = ((132 - size(dsd_rec->refresh_time))/ 2)
      SET dsd_len2 = ((dsd_len - size("More data down..."))/ 2)
      SET dsd_temp_str = concat(fillstring(value(dsd_len),"-"),dsd_rec->refresh_time,fillstring(value
        (dsd_len2),"-"),"More data down...",fillstring(value(dsd_len2),"-"))
     ELSE
      SET dsd_temp_str = concat(fillstring(value(((132 - size(dsd_rec->refresh_time))/ 2)),"-"),
       dsd_rec->refresh_time,fillstring(value(((132 - size(dsd_rec->refresh_time))/ 2)),"-"))
     ENDIF
     CALL text(23,1,dsd_temp_str)
     CALL text(24,1,concat("Command Options: __ (R)efresh, (H)elp, (D)etail by Mover, (E)xit"))
     CALL accept(24,18,"X;CUS","R"
      WHERE curaccept IN ("R", "E", "D", "H"))
     CASE (curscroll)
      OF 0:
       CASE (curaccept)
        OF "R":
         SET dsd_rec->cur_rs_pos = 0
         CALL dmam_gather_data(dsd_rec,dsd_det)
         IF ((dm_err->err_ind=1))
          GO TO exit_mon
         ENDIF
        OF "E":
         SET dsd_rec->cur_rs_pos = 0
         SET dsd_ind = 1
         RETURN(0)
        OF "H":
         SET accept = notime
         SET accept = noscroll
         CALL dmam_show_help(dsd_rec,1)
         SET dsd_rec->cur_rs_pos = 0
         SET accept = time(30)
         SET accept = scroll
        OF "D":
         SET dsd_rec->cur_rs_pos = 0
         SET dsd_ind = 1
         RETURN(1)
       ENDCASE
      OF 1:
      OF 6:
       IF (((dsd_rec->cur_rs_pos+ dsd_rec->max_lines) <= dsd_rec->det_cnt))
        SET dsd_rec->cur_rs_pos = (dsd_rec->cur_rs_pos+ dsd_rec->max_lines)
       ENDIF
      OF 2:
      OF 5:
       SET dsd_rec->cur_rs_pos = greatest((dsd_rec->cur_rs_pos - dsd_rec->max_lines),0)
     ENDCASE
   ENDWHILE
   RETURN(0)
 END ;Subroutine
#exit_mon
 IF ((dm_err->err_ind=1))
  SET message = window
  CALL clear(1,1)
  CALL video(n)
  SET width = 132
  CALL text(1,54,"RDDS Mover Activity Monitor")
  CALL text(2,1,"Env: ")
  CALL text(2,30,"Source:")
  CALL text(2,81,"Open Event:")
  CALL text(3,1,"Number of Movers Currently Running:")
  CALL text(3,81,"Last Cycle Time:")
  CALL text(5,1,fillstring(132,"-"))
  SET drmm_start = drdc_wrap_menu_lines(dm_err->emsg,7,1," ",20,
   120)
  SET drmm_start = (drmm_start+ 1)
  CALL text(drmm_start,1,"Press Enter to (E)xit __")
  CALL accept(drmm_start,23,"X;CUS","E"
   WHERE curaccept IN ("E"))
 ENDIF
END GO
