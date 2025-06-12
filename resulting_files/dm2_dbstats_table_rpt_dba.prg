CREATE PROGRAM dm2_dbstats_table_rpt:dba
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
 IF ((validate(dcr_plan_data->cnt,- (1))=- (1)))
  FREE RECORD dcr_plan_data
  RECORD dcr_plan_data(
    1 cnt = i4
    1 qual[*]
      2 sql_id = vc
      2 env_id = f8
      2 env_name = vc
      2 sql_text_cnt = i4
      2 sql_text[*]
        3 txt = vc
      2 plan_cnt = i4
      2 plans[*]
        3 plan_hash_value = f8
        3 child_number = f8
        3 first_load_dt_tm = dq8
        3 first_gets_exec = f8
        3 last_load_dt_tm = dq8
        3 last_gets_exec = f8
        3 plan_text_cnt = i4
        3 plan_text[*]
          4 txt = vc
  )
 ENDIF
 IF ((validate(dcr_sql->bind_cnt,- (1))=- (1)))
  FREE RECORD dcr_sql
  RECORD dcr_sql(
    1 sqlid = vc
    1 full_txt = vc
    1 instance_id = i4
    1 full_txt_with_binds = vc
    1 bind_cnt = i4
    1 bind[*]
      2 name = vc
      2 datatype = vc
      2 val_str = vc
    1 txt_cnt = i4
    1 txt[*]
      2 sql_txt_with_binds = vc
  )
 ENDIF
 IF ((validate(dcr_hist_vals->hist_cnt,- (1))=- (1)))
  FREE RECORD dcr_hist_vals
  RECORD dcr_hist_vals(
    1 tbl_name = vc
    1 col_name = vc
    1 ccl_data_type = vc
    1 hist_cnt = i4
    1 hist_type = vc
    1 hist[*]
      2 col_val = vc
      2 rows_per_key = f8
  )
 ENDIF
 IF ((validate(dcr_sqlplan->sql_cnt,- (1))=- (1)))
  FREE RECORD dcr_sqlplan
  RECORD dcr_sqlplan(
    1 sql_cnt = i4
    1 mode = vc
    1 output = vc
    1 sql[*]
      2 sqltext = vc
      2 child_cnt = i4
      2 sql_id = vc
      2 child[*]
        3 child_number = i4
        3 plan_hash = f8
        3 users_executing = f8
        3 rows_processed = f8
        3 fetches = f8
        3 parse_calls = f8
        3 actual_rows_processed = f8
        3 sorts = f8
        3 buff = f8
        3 exec = f8
        3 disk = f8
        3 first_time = c19
        3 rat = f8
        3 drat = f8
        3 cpu_time = f8
        3 crat = f8
        3 ela_time = f8
        3 erat = f8
        3 optimizer_mode = vc
        3 optimizer_cost = f8
        3 plan_line_cnt = i4
        3 bind_sensitive = vc
        3 bind_aware = vc
        3 exec_plan[*]
          4 plan_line = vc
        3 obj_cnt = i4
        3 objects[*]
          4 object_name = vc
  )
 ENDIF
 IF ((validate(dcrstrrec->break_str_cnt,- (1))=- (1)))
  FREE RECORD dcrstrrec
  RECORD dcrstrrec(
    1 break_str_cnt = i4
    1 break_str[*]
      2 token = vc
    1 orig_str_cnt = i4
    1 orig_str[*]
      2 str_full = vc
      2 piece_cnt = i4
      2 piece[*]
        3 str = vc
  )
 ENDIF
 IF ((validate(dcr_sql->exec_cnt,- (1))=- (1)))
  FREE RECORD dcr_sql
  RECORD dcr_sql(
    1 sqlid = vc
    1 full_txt = vc
    1 instance_id = i4
    1 exec_cnt = i4
    1 exec_full_txt = vc
    1 exec[*]
      2 sql_txt_exec = vc
    1 full_txt_with_binds = vc
    1 bind_cnt = i4
    1 bind[*]
      2 name = vc
      2 datatype = vc
      2 val_str = vc
      2 data_length = vc
    1 txt_cnt = i4
    1 txt[*]
      2 sql_txt_with_binds = vc
  )
 ENDIF
 IF ((validate(dcrdata->req_cnt,- (1))=- (1)))
  FREE RECORD dcrdata
  RECORD dcrdata(
    1 prompt_mode = vc
    1 destination = vc
    1 cur_env = vc
    1 cur_db = vc
    1 table_criteria = vc
    1 req_cnt = i4
    1 req_list[*]
      2 tbl_name = vc
    1 table_cnt = i4
    1 stat_type = vc
    1 tables[*]
      2 table_name = vc
      2 num_rows = f8
      2 blocks = f8
      2 avg_row_length = i4
      2 sample_size = f8
      2 last_analyzed = dq8
      2 last_analyzed_null_ind = i2
      2 global_stats = vc
      2 user_stats = vc
      2 table_mods_null_ind = i2
      2 inserts = f8
      2 updates = f8
      2 deletes = f8
      2 timestamp = dq8
      2 truncated = vc
      2 index_column_concat = vc
      2 column_cnt = i4
      2 columns[*]
        3 column_name = vc
        3 stat_null_ind = i2
        3 num_distinct = f8
        3 density = f8
        3 num_nulls = f8
        3 num_buckets = i4
        3 sample_size = f8
        3 avg_column_length = i4
        3 global_stats = vc
        3 user_stats = vc
        3 last_analyzed = dq8
        3 lit_column_ind = i2
        3 ccl_data_type = vc
        3 histogram_type = vc
        3 histogram_cnt = i4
        3 histogram[*]
          4 col_val = vc
          4 rows_per_key = f8
      2 index_cnt = i4
      2 indexes[*]
        3 index_name = vc
        3 num_rows = f8
        3 distinct_keys = f8
        3 b_lvl = i4
        3 leaf_blocks = i4
        3 avg_leaf_blocks_per_key = f8
        3 avg_data_blocks_per_key = f8
        3 clustering_factor = f8
        3 sample_size = f8
        3 last_analyzed = dq8
        3 last_analyzed_null_ind = i2
        3 global_stats = vc
        3 user_stats = vc
        3 index_column_cnt = i4
        3 index_columns[*]
          4 column_name = vc
          4 column_position = i2
  )
 ENDIF
 IF ((validate(dcr_sql_txt_ndx,- (1))=- (1))
  AND (validate(dcr_sql_txt_ndx,- (2))=- (2)))
  DECLARE dcr_sql_txt_ndx = i4 WITH protect, noconstant(0)
  DECLARE dcr_sql_id_ndx = i4 WITH protect, noconstant(0)
  DECLARE dcr_plan_data_ndx = i4 WITH protect, noconstant(0)
  DECLARE dcr_dst_curpos = i4 WITH protect, noconstant(0)
  DECLARE dcr_dst_nextpos = i4 WITH protect, noconstant(0)
  DECLARE dcr_dst_work_str = vc WITH protect, noconstant("")
  DECLARE dcr_dst_loop_cnt = i4 WITH protect, noconstant(0)
  DECLARE dcr_dst_break_cnt = i4 WITH protect, noconstant(0)
  DECLARE dcr_dst_sql_cnt = i4 WITH protect, noconstant(0)
  DECLARE dcr_dapt_plan_txt_cnt = i4 WITH protect, noconstant(0)
  DECLARE dcr_dapt_write_txt = i4 WITH protect, noconstant(0)
 ENDIF
 DECLARE dcr_add_sql_txt(dast_sqlid_in=vc,dast_envid_in=f8,dast_sqltxt_in=vc,dast_reset=i2) = i2
 DECLARE dcr_add_sql_id(dasi_sqlid_in=vc,dasi_envid_in=f8,dasi_reset=i2) = i2
 DECLARE dcr_add_plan_txt(dapt_sqlid=vc,dapt_plan_hash=f8,dapt_child_nbr=f8,dapt_envid=f8,
  dapt_plan_txt=vc,
  dapt_reset=i2) = i2
 DECLARE dcr_add_plan_data(dapd_sqlid=vc,dapd_envid=f8,dapd_plan_hash=f8,dapd_first_load=dq8,
  dapd_last_load=dq8,
  dapd_first_gets_exec=f8,dapd_last_gets_exec=f8,dapd_reset=i2) = i2
 DECLARE dcr_add_child_number(dacn_sqlid=vc,dacn_plan_hash=f8,dacn_child_nbr=f8,dacn_envid=f8) = i2
 DECLARE dcr_add_orig_str(dao_str_in=vc,dao_reset=i2) = i2
 DECLARE dcr_add_break_str(dabs_str_in=vc,dabs_reset=i2) = i2
 DECLARE dcr_add_piece(daes_str_in=vc,daes_orig_ndx=i4,daes_reset=i2) = i2
 DECLARE dcr_split_text(null) = i2
 DECLARE dcr_get_plan(dgp_ndx1=i4,dgp_ndx2=i4) = i2
 DECLARE dcr_init_sqlplan(null) = i2
 DECLARE dcr_get_dict_hist_vals(null) = i2
 DECLARE dcr_init_dict_hist_vals(null) = i2
 DECLARE dcr_get_instance_info(dgii_instance_name=vc(ref),dgii_instance_nbr=i4(ref)) = i2
 SUBROUTINE dcr_init_dict_hist_vals(null)
   SET dcr_hist_vals->tbl_name = ""
   SET dcr_hist_vals->col_name = ""
   SET dcr_hist_vals->ccl_data_type = ""
   SET dcr_hist_vals->hist_type = ""
   SET dcr_hist_vals->hist_cnt = 0
   SET stat = alterlist(dcr_hist_vals->hist,dcr_hist_vals->hist_cnt)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcr_get_dict_hist_vals(null)
   SET dm_err->eproc = concat("Gather HISTOGRAM values for ",dcr_hist_vals->tbl_name,".",
    dcr_hist_vals->col_name)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    h.endpt_val, frequency = (endpoint_number - nullval(prev_number,0.0)), h.histogram
    FROM (
     (
     (SELECT
      endpt_val = evaluate(dcr_hist_vals->ccl_data_type,"DQ8",sqlpassthru(
        "to_char(to_date(trunc(u.endpoint_value),'J'),'DD-MON-YYYY')"),"F8",trim(cnvtstring(u
         .endpoint_value,17,2)),
       "VC",u.endpoint_actual_value), endpoint_number, prev_number = sqlpassthru(
       "lag(endpoint_number,1) over(order by endpoint_number)"),
      uc.histogram
      FROM user_tab_histograms u,
       user_tab_columns uc
      WHERE (u.table_name=dcr_hist_vals->tbl_name)
       AND (u.column_name=dcr_hist_vals->col_name)
       AND u.table_name=uc.table_name
       AND u.column_name=uc.column_name
      ORDER BY (endpoint_number - nullval(prev_number,0.0)) DESC
      WITH sqltype("VC","F8","F8","VC")))
     h)
    HEAD REPORT
     dcr_hist_vals->hist_cnt = 0, dcr_hist_vals->hist_type = h.histogram
    DETAIL
     dcr_hist_vals->hist_cnt = (dcr_hist_vals->hist_cnt+ 1), stat = alterlist(dcr_hist_vals->hist,
      dcr_hist_vals->hist_cnt), dcr_hist_vals->hist[dcr_hist_vals->hist_cnt].col_val = h.endpt_val,
     dcr_hist_vals->hist[dcr_hist_vals->hist_cnt].rows_per_key = frequency
    FOOT REPORT
     stat = alterlist(dcr_hist_vals->hist,dcr_hist_vals->hist_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dcr_hist_vals->hist_type=""))
    SET dcr_hist_vals->hist_type = "NONE"
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcr_hist_vals)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcr_add_child_number(dacn_sqlid,dacn_plan_hash,dacn_child_nbr,dacn_envid)
   SET dcr_plan_data_ndx = 0
   SET dcr_sql_id_ndx = 0
   IF ((dcr_plan_data->cnt > 0))
    SET dcr_sql_id_ndx = locateval(dcr_sql_id_ndx,1,dcr_plan_data->cnt,dacn_sqlid,dcr_plan_data->
     qual[dcr_sql_id_ndx].sql_id,
     dacn_envid,dcr_plan_data->qual[dcr_sql_id_ndx].env_id)
    IF (dcr_sql_id_ndx > 0
     AND (dcr_plan_data->qual[dcr_sql_id_ndx].plan_cnt > 0))
     SET dcr_plan_data_ndx = locateval(dcr_plan_data_ndx,1,dcr_plan_data->qual[dcr_sql_id_ndx].
      plan_cnt,dacn_plan_hash,dcr_plan_data->qual[dcr_sql_id_ndx].plans[dcr_plan_data_ndx].
      plan_hash_value)
    ENDIF
   ENDIF
   IF (((dcr_sql_id_ndx=0) OR (dcr_plan_data_ndx=0)) )
    IF ((dm_err->debug_flag > 0))
     CALL echo(build("DACN_SQLID:",dacn_sqlid))
     CALL echo(build("DACN_PLANHASH:",dacn_plan_hash))
     CALL echo(build("DACN_CHILDNUMBER:",dacn_child_nbr))
     CALL echo(build("DACN_ENVID:",dacn_envid))
     CALL echo("No sqlid found or plan_data found")
    ENDIF
   ELSE
    SET dcr_plan_data->qual[dcr_sql_id_ndx].plans[dcr_plan_data_ndx].child_number = dacn_child_nbr
   ENDIF
 END ;Subroutine
 SUBROUTINE dcr_add_plan_txt(dapt_sqlid,dapt_plan_hash,dapt_child_nbr,dapt_envid,dapt_plan_txt,
  dapt_reset)
   IF ((dm_err->debug_flag > 2))
    CALL echo(build("PlanTextSQLID:",dapt_sqlid))
    CALL echo(build("PlanTextPLANHASH:",dapt_plan_hash))
    CALL echo(build("PlanTextCHILDNUMBER:",dapt_child_nbr))
    CALL echo(build("PlanTextENVID:",dapt_envid))
    CALL echo(build("PlanTextTEXT:",dapt_plan_txt))
    CALL echo(build("PlanTextRESET:",dapt_reset))
   ENDIF
   SET dcr_plan_data_ndx = 0
   SET dcr_sql_id_ndx = 0
   IF ((dcr_plan_data->cnt > 0))
    SET dcr_sql_id_ndx = locateval(dcr_sql_id_ndx,1,dcr_plan_data->cnt,dapt_sqlid,dcr_plan_data->
     qual[dcr_sql_id_ndx].sql_id,
     dapt_envid,dcr_plan_data->qual[dcr_sql_id_ndx].env_id)
    IF (dcr_sql_id_ndx > 0
     AND (dcr_plan_data->qual[dcr_sql_id_ndx].plan_cnt > 0))
     SET dcr_plan_data_ndx = locateval(dcr_plan_data_ndx,1,dcr_plan_data->qual[dcr_sql_id_ndx].
      plan_cnt,dapt_plan_hash,dcr_plan_data->qual[dcr_sql_id_ndx].plans[dcr_plan_data_ndx].
      plan_hash_value)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echo(build("PlanTextSQLIDNDX:",dcr_sql_id_ndx))
    CALL echo(build("PlanTextPLANDATADX:",dcr_plan_data_ndx))
   ENDIF
   IF (dcr_sql_id_ndx=0
    AND dcr_plan_data_ndx=0)
    IF ((dm_err->debug_flag > 0))
     CALL echo("No sqlid found or plan_hash_value found")
    ENDIF
   ELSE
    IF (dapt_reset=1)
     SET dcr_plan_data->qual[dcr_sql_id_ndx].plans[dcr_plan_data_ndx].plan_text_cnt = 0
     SET stat = alterlist(dcr_plan_data->qual[dcr_sql_id_ndx].plans[dcr_plan_data_ndx].plan_text,
      dcr_plan_data->qual[dcr_sql_id_ndx].plans[dcr_plan_data_ndx].plan_text_cnt)
    ELSE
     SET dcr_plan_data->qual[dcr_sql_id_ndx].plans[dcr_plan_data_ndx].plan_text_cnt = (dcr_plan_data
     ->qual[dcr_sql_id_ndx].plans[dcr_plan_data_ndx].plan_text_cnt+ 1)
     SET stat = alterlist(dcr_plan_data->qual[dcr_sql_id_ndx].plans[dcr_plan_data_ndx].plan_text,
      dcr_plan_data->qual[dcr_sql_id_ndx].plans[dcr_plan_data_ndx].plan_text_cnt)
     SET dcr_plan_data->qual[dcr_sql_id_ndx].plans[dcr_plan_data_ndx].plan_text[dcr_plan_data->qual[
     dcr_sql_id_ndx].plans[dcr_plan_data_ndx].plan_text_cnt].txt = dapt_plan_txt
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE dcr_add_plan_data(dapd_sqlid,dapd_envid,dapd_plan_hash,dapd_first_load,dapd_last_load,
  dapd_first_gets_exec,dapd_last_gets_exec,dapd_reset)
   SET dcr_plan_data_ndx = 0
   IF ((dcr_plan_data->cnt > 0))
    SET dcr_plan_data_ndx = locateval(dcr_plan_data_ndx,1,dcr_plan_data->cnt,dapd_sqlid,dcr_plan_data
     ->qual[dcr_plan_data_ndx].sql_id,
     dapd_envid,dcr_plan_data->qual[dcr_plan_data_ndx].env_id)
   ENDIF
   IF (dapd_reset=1)
    IF (dcr_plan_data_ndx > 0)
     SET dcr_plan_data->qual[dcr_plan_data_ndx].plan_cnt = 0
     SET stat = alterlist(dcr_plan_data->qual[dcr_plan_data_ndx].plans,dcr_plan_data->qual[
      dcr_plan_data_ndx].plan_cnt)
    ENDIF
   ELSE
    IF (dcr_plan_data_ndx > 0)
     SET dcr_plan_data->qual[dcr_plan_data_ndx].plan_cnt = (dcr_plan_data->qual[dcr_plan_data_ndx].
     plan_cnt+ 1)
     SET stat = alterlist(dcr_plan_data->qual[dcr_plan_data_ndx].plans,dcr_plan_data->qual[
      dcr_plan_data_ndx].plan_cnt)
     SET dcr_plan_data->qual[dcr_plan_data_ndx].plans[dcr_plan_data->qual[dcr_plan_data_ndx].plan_cnt
     ].plan_hash_value = dapd_plan_hash
     SET dcr_plan_data->qual[dcr_plan_data_ndx].plans[dcr_plan_data->qual[dcr_plan_data_ndx].plan_cnt
     ].first_load_dt_tm = dapd_first_load
     SET dcr_plan_data->qual[dcr_plan_data_ndx].plans[dcr_plan_data->qual[dcr_plan_data_ndx].plan_cnt
     ].last_load_dt_tm = dapd_last_load
     SET dcr_plan_data->qual[dcr_plan_data_ndx].plans[dcr_plan_data->qual[dcr_plan_data_ndx].plan_cnt
     ].first_gets_exec = dapd_first_gets_exec
     SET dcr_plan_data->qual[dcr_plan_data_ndx].plans[dcr_plan_data->qual[dcr_plan_data_ndx].plan_cnt
     ].last_gets_exec = dapd_last_gets_exec
    ELSE
     IF ((dm_err->debug_flag > 0))
      CALL echo("No sqlid found")
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE dcr_add_sql_id(dasi_sqlid_in,dasi_envid_in,dasi_reset)
  SET dcr_sql_id_ndx = 0
  IF (dasi_reset=1)
   SET dcr_plan_data->cnt = 0
   SET stat = alterlist(dcr_plan_data->qual,dcr_plan_data->cnt)
  ELSE
   IF ((dcr_plan_data->cnt > 0))
    SET dcr_sql_id_ndx = locateval(dcr_sql_id_ndx,1,dcr_plan_data->cnt,dasi_sqlid_in,dcr_plan_data->
     qual[dcr_sql_id_ndx].sql_id,
     dasi_envid_in,dcr_plan_data->qual[dcr_sql_id_ndx].env_id)
   ENDIF
   IF (dcr_sql_id_ndx=0)
    SET dcr_plan_data->cnt = (dcr_plan_data->cnt+ 1)
    SET stat = alterlist(dcr_plan_data->qual,dcr_plan_data->cnt)
    SET dcr_sql_id_ndx = dcr_plan_data->cnt
    SET dcr_plan_data->qual[dcr_sql_id_ndx].sql_id = dasi_sqlid_in
    SET dcr_plan_data->qual[dcr_sql_id_ndx].env_id = dasi_envid_in
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE dcr_add_sql_txt(dast_sqlid_in,dast_envid_in,dast_sqltxt_in,dast_reset)
   SET dcr_sql_txt_ndx = 0
   IF ((dm_err->debug_flag > 2))
    CALL echo(build("DAST_SQLID:",dast_sqlid_in))
    CALL echo(build("DAST_ENV:",dast_envid_in))
    CALL echo(build("DAST_SQLTXT:",dast_sqltxt_in))
    CALL echo(build("DAST_RESET:",dast_reset))
   ENDIF
   IF ((dcr_plan_data->cnt > 0))
    SET dcr_sql_txt_ndx = locateval(dcr_sql_txt_ndx,1,dcr_plan_data->cnt,dast_sqlid_in,dcr_plan_data
     ->qual[dcr_sql_txt_ndx].sql_id,
     dast_envid_in,dcr_plan_data->qual[dcr_sql_txt_ndx].env_id)
   ENDIF
   IF (dast_reset=1)
    IF (dcr_sql_txt_ndx > 0)
     SET dcr_plan_data->qual[dcr_sql_txt_ndx].sql_text_cnt = 0
     SET stat = alterlist(dcr_plan_data->qual[dcr_sql_txt_ndx].sql_text,dcr_plan_data->qual[
      dcr_sql_txt_ndx].sql_text_cnt)
    ENDIF
   ELSE
    IF (dcr_sql_txt_ndx > 0)
     SET dcr_plan_data->qual[dcr_sql_txt_ndx].sql_text_cnt = (dcr_plan_data->qual[dcr_sql_txt_ndx].
     sql_text_cnt+ 1)
     SET stat = alterlist(dcr_plan_data->qual[dcr_sql_txt_ndx].sql_text,dcr_plan_data->qual[
      dcr_sql_txt_ndx].sql_text_cnt)
     SET dcr_plan_data->qual[dcr_sql_txt_ndx].sql_text[dcr_plan_data->qual[dcr_sql_txt_ndx].
     sql_text_cnt].txt = dast_sqltxt_in
    ELSE
     IF ((dm_err->debug_flag > 0))
      CALL echo("No sqlid found")
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE dcr_add_orig_str(dao_str_in,dao_reset)
   IF (dao_reset=1)
    SET dcrstrrec->orig_str_cnt = 0
    SET stat = alterlist(dcrstrrec->orig_str,dcrstrrec->orig_str_cnt)
   ELSE
    SET dcrstrrec->orig_str_cnt = (dcrstrrec->orig_str_cnt+ 1)
    SET stat = alterlist(dcrstrrec->orig_str,dcrstrrec->orig_str_cnt)
    SET dcrstrrec->orig_str[dcrstrrec->orig_str_cnt].str_full = dao_str_in
   ENDIF
 END ;Subroutine
 SUBROUTINE dcr_add_break_str(dabs_str_in,dabs_reset)
   IF (dabs_reset=1)
    SET dcrstrrec->break_str_cnt = 0
    SET stat = alterlist(dcrstrrec->break_str,dcrstrrec->break_str_cnt)
   ELSE
    SET dcrstrrec->break_str_cnt = (dcrstrrec->break_str_cnt+ 1)
    SET stat = alterlist(dcrstrrec->break_str,dcrstrrec->break_str_cnt)
    SET dcrstrrec->break_str[dcrstrrec->break_str_cnt].token = notrim(dabs_str_in)
   ENDIF
 END ;Subroutine
 SUBROUTINE dcr_add_piece(dap_str_in,dap_orig_ndx,dap_reset)
   IF (dap_reset=1)
    SET dcrstrrec->orig_str[dap_orig_ndx].piece_cnt = 0
    SET stat = alterlist(dcrstrrec->orig_str[dap_orig_ndx].piece,dcrstrrec->orig_str[dap_orig_ndx].
     piece_cnt)
   ELSE
    SET dcrstrrec->orig_str[dap_orig_ndx].piece_cnt = (dcrstrrec->orig_str[dap_orig_ndx].piece_cnt+ 1
    )
    SET stat = alterlist(dcrstrrec->orig_str[dap_orig_ndx].piece,dcrstrrec->orig_str[dap_orig_ndx].
     piece_cnt)
    SET dcrstrrec->orig_str[dap_orig_ndx].piece[dcrstrrec->orig_str[dap_orig_ndx].piece_cnt].str =
    dap_str_in
   ENDIF
 END ;Subroutine
 SUBROUTINE dcr_split_text(null)
   FOR (dcr_dst_sql_cnt = 1 TO dcrstrrec->orig_str_cnt)
     CALL dcr_add_piece("",0,1)
     SET dcr_dst_break_cnt = 0
     SET dcr_dst_loop_cnt = 0
     SET dcr_dst_nextpos = 0
     SET dcr_dst_curpos = 1
     WHILE (dcr_dst_curpos < size(dcrstrrec->orig_str[dcr_dst_sql_cnt].str_full)
      AND dcr_dst_loop_cnt < 200)
       SET dcr_dst_loop_cnt = (dcr_dst_loop_cnt+ 1)
       IF (size(dcrstrrec->orig_str[dcr_dst_sql_cnt].str_full) < 120)
        SET dcr_dst_nextpos = (size(dcrstrrec->orig_str[dcr_dst_sql_cnt].str_full)+ 1)
       ELSE
        SET dcr_dst_work_str = substring(dcr_dst_curpos,120,dcrstrrec->orig_str[dcr_dst_sql_cnt].
         str_full)
        SET dcr_dst_nextpos = 0
        FOR (dcr_dst_break_cnt = 1 TO dcrstrrec->break_str_cnt)
         SET dcr_dst_nextpos = greatest(dcr_dst_nextpos,findstring(dcrstrrec->break_str[
           dcr_dst_break_cnt].token,dcr_dst_work_str,1,1))
         IF ((dm_err->debug_flag > 1))
          CALL echo(concat("Found ",dcrstrrec->break_str[dcr_dst_break_cnt].token," at ",build(
             dcr_dst_nextpos)))
         ENDIF
        ENDFOR
        IF ((dm_err->debug_flag > 1))
         CALL echo(build("PRECurpos:",dcr_dst_curpos,":PRENextpos:",dcr_dst_nextpos))
        ENDIF
        IF (dcr_dst_nextpos > 0)
         IF (((dcr_dst_curpos+ 120) > size(dcrstrrec->orig_str[dcr_dst_sql_cnt].str_full)))
          SET dcr_dst_nextpos = (dcr_dst_curpos+ 120)
         ELSE
          SET dcr_dst_nextpos = (dcr_dst_curpos+ dcr_dst_nextpos)
         ENDIF
        ELSE
         SET dcr_dst_nextpos = (dcr_dst_curpos+ 120)
        ENDIF
       ENDIF
       IF ((dm_err->debug_flag > 1))
        CALL echo(build("Curpos:",dcr_dst_curpos,":Nextpos:",dcr_dst_nextpos))
        CALL echo(dcr_dst_work_str)
        CALL echo(substring(dcr_dst_curpos,(dcr_dst_nextpos - dcr_dst_curpos),dcrstrrec->orig_str[
          dcr_dst_sql_cnt].str_full))
       ENDIF
       CALL dcr_add_piece(substring(dcr_dst_curpos,(dcr_dst_nextpos - dcr_dst_curpos),dcrstrrec->
         orig_str[dcr_dst_sql_cnt].str_full),dcr_dst_sql_cnt,0)
       SET dcr_dst_curpos = dcr_dst_nextpos
     ENDWHILE
   ENDFOR
 END ;Subroutine
 SUBROUTINE dcr_init_sqlplan(null)
   SET stat = alterlist(dcr_sqlplan->sql,0)
   SET dcr_sqlplan->sql_cnt = 0
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcr_get_plan(dgp_ndx1,dgp_ndx2)
   DECLARE dcp_cnt = i4 WITH protect, noconstant(0)
   DECLARE dcp_cnt2 = i4 WITH protect, noconstant(0)
   DECLARE dcp_start_pt = i4 WITH protect, noconstant(0)
   DECLARE dcp_end_pt = i4 WITH protect, noconstant(0)
   DECLARE dcp_str = vc WITH protect, noconstant("")
   SET dm_err->eproc = concat("Arrange plan data for reporting.SQL_ID:",dcr_sqlplan->sql[dgp_ndx1].
    sql_id," Child Number: ",trim(cnvtstring(dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].child_number)
     ))
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   CALL parser(concat(
     'rdb asis("Insert into shared_txt_gttd (source_entity_txt)(SELECT * FROM table(DBMS_XPLAN.DISPLAY_CURSOR',
     "('",dcr_sqlplan->sql[dgp_ndx1].sql_id,"',",trim(cnvtstring(dcr_sqlplan->sql[dgp_ndx1].child[
       dgp_ndx2].child_number)),
     ",'",dcr_sqlplan->mode,^')))") go^),1)
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SELECT INTO "nl"
    FROM shared_txt_gttd s
    HEAD REPORT
     dcp_cnt2 = 0, dcp_cnt = 0, dcp_str = ""
    DETAIL
     IF ((dm_err->debug_flag > 3))
      CALL echo(s.source_entity_txt)
     ENDIF
     dcp_cnt = (dcp_cnt+ 1), stat = alterlist(dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].exec_plan,
      dcp_cnt), dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].exec_plan[dcp_cnt].plan_line = s
     .source_entity_txt,
     dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].plan_line_cnt = dcp_cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   ROLLBACK
   SELECT INTO "nl:"
    ratio = (a.buffer_gets/ a.executions), dratio = (a.disk_reads/ a.executions)
    FROM v$sqlarea a
    WHERE (a.sql_id=dcr_sqlplan->sql[dgp_ndx1].sql_id)
     AND (a.plan_hash_value=dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].plan_hash)
     AND a.executions > 0
    DETAIL
     dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].buff = a.buffer_gets, dcr_sqlplan->sql[dgp_ndx1].
     child[dgp_ndx2].exec = a.executions, dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].disk = a
     .disk_reads,
     dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].first_time = a.first_load_time, dcr_sqlplan->sql[
     dgp_ndx1].child[dgp_ndx2].rat = ratio, dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].drat = dratio,
     dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].users_executing = a.users_executing, dcr_sqlplan->
     sql[dgp_ndx1].child[dgp_ndx2].fetches = a.fetches, dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].
     parse_calls = a.parse_calls,
     dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].actual_rows_processed = (a.rows_processed/ a
     .executions), dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].rows_processed = a.rows_processed,
     dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].sorts = a.sorts,
     dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].ela_time = a.elapsed_time, dcr_sqlplan->sql[dgp_ndx1]
     .child[dgp_ndx2].erat = ((a.elapsed_time/ 1000000)/ a.executions), dcr_sqlplan->sql[dgp_ndx1].
     child[dgp_ndx2].cpu_time = validate(a.cpu_time,- (1))
     IF ((dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].cpu_time != - (1)))
      dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].crat = ((a.cpu_time/ 1000000)/ a.executions)
     ENDIF
     dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].optimizer_mode = trim(a.optimizer_mode), dcr_sqlplan
     ->sql[dgp_ndx1].child[dgp_ndx2].optimizer_cost = a.optimizer_cost, dcr_sqlplan->sql[dgp_ndx1].
     child[dgp_ndx2].bind_sensitive = a.is_bind_sensitive,
     dcr_sqlplan->sql[dgp_ndx1].child[dgp_ndx2].bind_aware = a.is_bind_aware
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcr_get_instance_info(dgii_instance_name,dgii_instance_nbr)
   SET dm_err->eproc = "Retrieve instance info from v$instance"
   SELECT INTO "nl:"
    FROM v$instance vi
    DETAIL
     dgii_instance_name = vi.instance_name, dgii_instance_nbr = vi.instance_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 FREE RECORD literal_columns
 RECORD literal_columns(
   1 cnt = i4
   1 qual[*]
     2 table_column_name = vc
 )
 DECLARE ddtr_menu_driver = i2 WITH protect, noconstant(0)
 DECLARE ddtr_iter = i4 WITH protect, noconstant(0)
 DECLARE ddtr_iter2 = i4 WITH protect, noconstant(0)
 DECLARE ddtr_ndx = i4 WITH protect, noconstant(0)
 DECLARE ddtr_iter3 = i4 WITH protect, noconstant(0)
 DECLARE ddtr_msg = vc WITH protect, noconstant("")
 DECLARE ddtr_first_time = i2 WITH protect, noconstant(1)
 DECLARE ddtr_disp_hist = vc WITH protect, noconstant("YES")
 DECLARE ddtr_generate_table_report(null) = i2
 DECLARE ddtr_clear_screen_and_repopulate(null) = null
 IF (check_logfile("dm2_dbstats_tbl_rpt",".log","DM2_DBSTATS_TABLE_RPT LOGFILE")=0)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Beginning DM2_DBSTATS_TABLE_RPT"
 CALL disp_msg(" ",dm_err->logfile,0)
 SET dm_err->eproc = "Verifying and storing input parameters."
 SET dcrdata->prompt_mode = trim(cnvtupper( $1),3)
 SET dcrdata->table_criteria = trim(cnvtupper( $2),3)
 SET dcrdata->destination = trim(cnvtlower( $3),3)
 SET dcrdata->stat_type = trim(cnvtupper( $4),3)
 SET ddtr_disp_hist = trim(cnvtupper( $5),3)
 IF (check_error(dm_err->eproc)=1)
  SET dm_err->emsg =
  "Parameter usage: dm2_dbstats_table_rpt '<prompt_mode>', '<table criteria>', '<destination>'"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Validating <prompt_mode> input parameter."
 IF ( NOT ((dcrdata->prompt_mode IN ("PROMPT", "NOPROMPT"))))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Valid values are 'PROMPT' and 'NOPROMPT'"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF ((dcrdata->prompt_mode="NOPROMPT"))
  SET dm_err->eproc = "Validating <stat_type> input parameter."
  IF ( NOT ((dcrdata->stat_type IN ("GOLDAVG", "LIVE", "ACTUAL"))))
   SET dm_err->err_ind = 1
   SET dm_err->emsg = "Valid values are 'GOLDAVG','LIVE' and 'ACTUAL'"
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  SET dm_err->eproc = "Validating <table_criteria> input parameter."
  IF ((dcrdata->table_criteria=""))
   SET dm_err->err_ind = 1
   SET dm_err->emsg = "<table_criteria> cannot be blank in NOPROMPT mode."
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  SET dm_err->eproc = "Validating <destination> input parameter."
  IF ((dcrdata->destination=""))
   SET dm_err->err_ind = 1
   SET dm_err->emsg = "<destination> cannot be blank in NOPROMPT mode."
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  SET dm_err->eproc = "Validating <Display Histogram> input parameter."
  IF ( NOT (ddtr_disp_hist IN ("YES", "NO")))
   SET dm_err->err_ind = 1
   SET dm_err->emsg = "Valid values are 'YES','NO'"
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
 ENDIF
 SET dcrdata->cur_db = trim(cnvtupper(currdbname))
 SET dm_err->eproc = "Select environment name from dm_info."
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="DM_ENV_NAME"
  DETAIL
   dcrdata->cur_env = build(di.info_char)
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF ((dcrdata->prompt_mode="PROMPT")
  AND (dcrdata->destination != "temp"))
  SET dcrdata->destination = "MINE"
  WHILE (true)
    SET ddtr_table_name_accept = 0
    WHILE (ddtr_table_name_accept=0)
      CALL ddtr_clear_screen_and_repopulate(null)
      CALL accept(8,18,"P(30);CU",dcrdata->table_criteria)
      IF (trim(curaccept,3)="")
       SET ddtr_table_name_accept = 1
       SET ddtr_first_time = 0
      ELSE
       SET dm_err->eproc = "Checking if table criteria matches in user_tables."
       SELECT INTO "nl:"
        FROM user_tables ut
        WHERE ut.table_name=patstring(trim(curaccept,3))
        HEAD REPORT
         ddtr_msg = "Table criteria results in no matches in the database."
        DETAIL
         ddtr_table_name_accept = 1, ddtr_msg = ""
        WITH nocounter, nullreport, maxqual(ut,1)
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_script
       ENDIF
      ENDIF
    ENDWHILE
    SET dcrdata->table_criteria = trim(curaccept,3)
    CALL accept(10,30,"P(3);CU",ddtr_disp_hist
     WHERE curaccept IN ("YES", "NO"))
    SET ddtr_disp_hist = trim(curaccept)
    SET ddtr_menu_driver = 1
    WHILE (ddtr_menu_driver=1)
      CALL ddtr_clear_screen_and_repopulate(null)
      SET ddtr_msg = ""
      IF (ddtr_first_time=1)
       CALL accept(21,37,"A;CU","C"
        WHERE curaccept IN ("M", "C", "Q"))
      ELSE
       CALL accept(21,37,"A;CU","Q"
        WHERE curaccept IN ("M", "C", "Q"))
      ENDIF
      CASE (curaccept)
       OF "Q":
        GO TO exit_script
       OF "M":
        SET ddtr_menu_driver = 0
        SET ddtr_first_time = 1
       OF "C":
        SET message = nowindow
        CALL clear(1,1)
        IF (ddtr_generate_table_report(null)=0)
         SET ddtr_msg = concat("Error occurred.  Please see log file [",build(dm_err->logfile),
          "] for details.")
        ENDIF
        SET ddtr_first_time = 0
      ENDCASE
    ENDWHILE
  ENDWHILE
 ELSE
  IF (ddtr_generate_table_report(null)=0)
   SET ddtr_msg = concat("Error occurred.  Please see log file [",build(dm_err->logfile),
    "] for details.")
  ENDIF
 ENDIF
 SUBROUTINE ddtr_clear_screen_and_repopulate(null)
   SET width = 132
   SET message = window
   SET accept = nopatcheck
   CALL clear(1,1)
   CALL box(1,1,24,131)
   CALL text(2,2,"View Table Statistics")
   CALL text(4,2,"Environment Name:")
   CALL text(4,20,dcrdata->cur_env)
   CALL text(6,2,"Database Name:")
   CALL text(6,20,dcrdata->cur_db)
   CALL text(8,2,"Table Criteria:")
   CALL text(8,18,dcrdata->table_criteria)
   CALL text(10,2,"Display Historgram (YES/NO):")
   CALL text(10,30,ddtr_disp_hist)
   CALL text(21,2,"(M)odify, (C)reate Report, (Q)uit:")
   CALL text(23,3,ddtr_msg)
 END ;Subroutine
 SUBROUTINE ddtr_generate_table_report(null)
   DECLARE dgtr_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgtr_cnt2 = i4 WITH protect, noconstant(0)
   DECLARE dgtr_cnt3 = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Selecting literal columns for oragen from dm_info rows."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="ORAGEN3:COLUMN_LITERAL"
    HEAD REPORT
     literal_columns->cnt = 0, stat = alterlist(literal_columns->qual,literal_columns->cnt)
    DETAIL
     literal_columns->cnt = (literal_columns->cnt+ 1), stat = alterlist(literal_columns->qual,
      literal_columns->cnt), literal_columns->qual[literal_columns->cnt].table_column_name = di
     .info_name
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    SET message = nowindow
    CALL clear(1,1)
    CALL echorecord(literal_columns)
    SET message = window
   ENDIF
   SET dm_err->eproc =
   "Selecting data from user_tables/user_tab_modifications/user_tab_columns/user_tab_col_statistics."
   SELECT
    IF ((dcrdata->stat_type="LIVE")
     AND (dcrdata->table_criteria != "DM2REQLIST"))
     FROM user_tables ut,
      user_tab_modifications utm,
      user_tab_columns utc
     WHERE outerjoin(ut.table_name)=utm.table_name
      AND ut.table_name=utc.table_name
      AND ut.table_name=patstring(dcrdata->table_criteria)
     ORDER BY ut.table_name, utc.column_name
    ELSEIF ((dcrdata->stat_type="ACTUAL")
     AND (dcrdata->table_criteria != "DM2REQLIST"))
     FROM dm_user_tables_actual_stats ut,
      user_tab_modifications utm,
      dm_user_columns_actual_stats utc
     WHERE outerjoin(ut.table_name)=utm.table_name
      AND ut.table_name=utc.table_name
      AND ut.table_name=patstring(dcrdata->table_criteria)
     ORDER BY ut.table_name, utc.column_name
    ELSEIF ((dcrdata->stat_type="GOLDAVG")
     AND (dcrdata->table_criteria != "DM2REQLIST"))
     FROM dm_user_tables_goldavg_stats ut,
      user_tab_modifications utm,
      dm_user_columns_goldavg_stats utc
     WHERE outerjoin(ut.table_name)=utm.table_name
      AND ut.table_name=utc.table_name
      AND ut.table_name=patstring(dcrdata->table_criteria)
     ORDER BY ut.table_name, utc.column_name
    ELSEIF ((dcrdata->stat_type="LIVE"))
     FROM user_tables ut,
      user_tab_modifications utm,
      user_tab_columns utc
     WHERE outerjoin(ut.table_name)=utm.table_name
      AND ut.table_name=utc.table_name
      AND expand(ddtr_ndx,1,dcrdata->req_cnt,ut.table_name,dcrdata->req_list[ddtr_ndx].tbl_name)
     ORDER BY ut.table_name, utc.column_name
    ELSEIF ((dcrdata->stat_type="ACTUAL"))
     FROM dm_user_tables_actual_stats ut,
      user_tab_modifications utm,
      dm_user_columns_actual_stats utc
     WHERE outerjoin(ut.table_name)=utm.table_name
      AND ut.table_name=utc.table_name
      AND expand(ddtr_ndx,1,dcrdata->req_cnt,ut.table_name,dcrdata->req_list[ddtr_ndx].tbl_name)
     ORDER BY ut.table_name, utc.column_name
    ELSEIF ((dcrdata->stat_type="GOLDAVG"))
     FROM dm_user_tables_goldavg_stats ut,
      user_tab_modifications utm,
      dm_user_columns_goldavg_stats utc
     WHERE outerjoin(ut.table_name)=utm.table_name
      AND ut.table_name=utc.table_name
      AND expand(ddtr_ndx,1,dcrdata->req_cnt,ut.table_name,dcrdata->req_list[ddtr_ndx].tbl_name)
     ORDER BY ut.table_name, utc.column_name
    ELSE
    ENDIF
    INTO "nl:"
    last_analyzed_null_ind_col = nullind(ut.last_analyzed), table_mods_null_ind_col = nullind(utm
     .inserts)
    HEAD REPORT
     found = 0, found2 = 0, dcrdata->table_cnt = 0,
     stat = alterlist(dcrdata->tables,dcrdata->table_cnt)
    HEAD ut.table_name
     dcrdata->table_cnt = (dcrdata->table_cnt+ 1), stat = alterlist(dcrdata->tables,dcrdata->
      table_cnt), dcrdata->tables[dcrdata->table_cnt].table_name = ut.table_name,
     dcrdata->tables[dcrdata->table_cnt].num_rows = ut.num_rows, dcrdata->tables[dcrdata->table_cnt].
     blocks = ut.blocks, dcrdata->tables[dcrdata->table_cnt].avg_row_length = ut.avg_row_len,
     dcrdata->tables[dcrdata->table_cnt].sample_size = ut.sample_size, dcrdata->tables[dcrdata->
     table_cnt].last_analyzed = ut.last_analyzed, dcrdata->tables[dcrdata->table_cnt].
     last_analyzed_null_ind = last_analyzed_null_ind_col,
     dcrdata->tables[dcrdata->table_cnt].global_stats = ut.global_stats, dcrdata->tables[dcrdata->
     table_cnt].user_stats = ut.user_stats, dcrdata->tables[dcrdata->table_cnt].table_mods_null_ind
      = table_mods_null_ind_col,
     dcrdata->tables[dcrdata->table_cnt].inserts = utm.inserts, dcrdata->tables[dcrdata->table_cnt].
     updates = utm.updates, dcrdata->tables[dcrdata->table_cnt].deletes = utm.deletes,
     dcrdata->tables[dcrdata->table_cnt].timestamp = utm.timestamp, dcrdata->tables[dcrdata->
     table_cnt].truncated = utm.truncated
    HEAD utc.column_name
     dcrdata->tables[dcrdata->table_cnt].column_cnt = (dcrdata->tables[dcrdata->table_cnt].column_cnt
     + 1), stat = alterlist(dcrdata->tables[dcrdata->table_cnt].columns,dcrdata->tables[dcrdata->
      table_cnt].column_cnt), dcrdata->tables[dcrdata->table_cnt].columns[dcrdata->tables[dcrdata->
     table_cnt].column_cnt].column_name = utc.column_name,
     dcrdata->tables[dcrdata->table_cnt].columns[dcrdata->tables[dcrdata->table_cnt].column_cnt].
     stat_null_ind = last_analyzed_null_ind_col, dcrdata->tables[dcrdata->table_cnt].columns[dcrdata
     ->tables[dcrdata->table_cnt].column_cnt].last_analyzed = utc.last_analyzed, dcrdata->tables[
     dcrdata->table_cnt].columns[dcrdata->tables[dcrdata->table_cnt].column_cnt].num_distinct = utc
     .num_distinct,
     dcrdata->tables[dcrdata->table_cnt].columns[dcrdata->tables[dcrdata->table_cnt].column_cnt].
     density = utc.density, dcrdata->tables[dcrdata->table_cnt].columns[dcrdata->tables[dcrdata->
     table_cnt].column_cnt].num_nulls = utc.num_nulls, dcrdata->tables[dcrdata->table_cnt].columns[
     dcrdata->tables[dcrdata->table_cnt].column_cnt].num_buckets = utc.num_buckets,
     dcrdata->tables[dcrdata->table_cnt].columns[dcrdata->tables[dcrdata->table_cnt].column_cnt].
     sample_size = utc.sample_size, dcrdata->tables[dcrdata->table_cnt].columns[dcrdata->tables[
     dcrdata->table_cnt].column_cnt].avg_column_length = utc.avg_col_len, dcrdata->tables[dcrdata->
     table_cnt].columns[dcrdata->tables[dcrdata->table_cnt].column_cnt].global_stats = utc
     .global_stats,
     dcrdata->tables[dcrdata->table_cnt].columns[dcrdata->tables[dcrdata->table_cnt].column_cnt].
     user_stats = utc.user_stats
     CASE (utc.data_type)
      OF "NUMBER":
      OF "FLOAT":
       dcrdata->tables[dcrdata->table_cnt].columns[dcrdata->tables[dcrdata->table_cnt].column_cnt].
       ccl_data_type = "F8"
      OF "CHAR":
      OF "VARCHAR":
      OF "VARCHAR2":
      OF "ROWID":
       dcrdata->tables[dcrdata->table_cnt].columns[dcrdata->tables[dcrdata->table_cnt].column_cnt].
       ccl_data_type = "VC"
      OF "DATE":
       dcrdata->tables[dcrdata->table_cnt].columns[dcrdata->tables[dcrdata->table_cnt].column_cnt].
       ccl_data_type = "DQ8"
     ENDCASE
     IF ((literal_columns->cnt > 0))
      found2 = 0, found2 = locateval(ddtr_iter,1,literal_columns->cnt,build(ut.table_name,":",utc
        .column_name),literal_columns->qual[ddtr_iter].table_column_name)
      IF (found2 > 0)
       dcrdata->tables[dcrdata->table_cnt].columns[dcrdata->tables[dcrdata->table_cnt].column_cnt].
       lit_column_ind = 1
      ENDIF
     ENDIF
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Selecting data from user_indexes/user_ind_columns."
   SELECT
    IF ((dcrdata->stat_type="LIVE")
     AND (dcrdata->table_criteria != "DM2REQLIST"))
     FROM user_indexes ui,
      user_ind_columns uic
     WHERE ui.index_name=uic.index_name
      AND ui.table_name=patstring(dcrdata->table_criteria)
     ORDER BY ui.table_name, ui.index_name, uic.column_position
    ELSEIF ((dcrdata->stat_type="ACTUAL")
     AND (dcrdata->table_criteria != "DM2REQLIST"))
     FROM dm_user_indexes_actual_stats ui,
      user_ind_columns uic
     WHERE ui.index_name=uic.index_name
      AND ui.table_name=patstring(dcrdata->table_criteria)
     ORDER BY ui.table_name, ui.index_name, uic.column_position
    ELSEIF ((dcrdata->stat_type="GOLDAVG")
     AND (dcrdata->table_criteria != "DM2REQLIST"))
     FROM dm_user_indexes_goldavg_stats ui,
      user_ind_columns uic
     WHERE ui.index_name=uic.index_name
      AND ui.table_name=patstring(dcrdata->table_criteria)
     ORDER BY ui.table_name, ui.index_name, uic.column_position
    ELSEIF ((dcrdata->stat_type="LIVE"))
     FROM user_indexes ui,
      user_ind_columns uic
     WHERE ui.index_name=uic.index_name
      AND expand(ddtr_ndx,1,dcrdata->req_cnt,ui.table_name,dcrdata->req_list[ddtr_ndx].tbl_name)
     ORDER BY ui.table_name, ui.index_name, uic.column_position
    ELSEIF ((dcrdata->stat_type="ACTUAL"))
     FROM dm_user_indexes_actual_stats ui,
      user_ind_columns uic
     WHERE ui.index_name=uic.index_name
      AND expand(ddtr_ndx,1,dcrdata->req_cnt,ui.table_name,dcrdata->req_list[ddtr_ndx].tbl_name)
     ORDER BY ui.table_name, ui.index_name, uic.column_position
    ELSEIF ((dcrdata->stat_type="GOLDAVG"))
     FROM dm_user_indexes_goldavg_stats ui,
      user_ind_columns uic
     WHERE ui.index_name=uic.index_name
      AND expand(ddtr_ndx,1,dcrdata->req_cnt,ui.table_name,dcrdata->req_list[ddtr_ndx].tbl_name)
     ORDER BY ui.table_name, ui.index_name, uic.column_position
    ELSE
    ENDIF
    INTO "nl:"
    last_analyzed_null_ind_col = nullind(ui.last_analyzed)
    HEAD REPORT
     found = 0, found2 = 0
    HEAD ui.table_name
     found = 0, found = locateval(ddtr_iter,1,dcrdata->table_cnt,ui.table_name,dcrdata->tables[
      ddtr_iter].table_name)
    HEAD ui.index_name
     IF (found > 0)
      dcrdata->tables[found].index_cnt = (dcrdata->tables[found].index_cnt+ 1), stat = alterlist(
       dcrdata->tables[found].indexes,dcrdata->tables[found].index_cnt), dcrdata->tables[found].
      indexes[dcrdata->tables[found].index_cnt].index_name = ui.index_name,
      dcrdata->tables[found].indexes[dcrdata->tables[found].index_cnt].num_rows = ui.num_rows,
      dcrdata->tables[found].indexes[dcrdata->tables[found].index_cnt].distinct_keys = ui
      .distinct_keys, dcrdata->tables[found].indexes[dcrdata->tables[found].index_cnt].b_lvl = ui
      .blevel,
      dcrdata->tables[found].indexes[dcrdata->tables[found].index_cnt].leaf_blocks = ui.leaf_blocks,
      dcrdata->tables[found].indexes[dcrdata->tables[found].index_cnt].avg_leaf_blocks_per_key = ui
      .avg_leaf_blocks_per_key, dcrdata->tables[found].indexes[dcrdata->tables[found].index_cnt].
      avg_data_blocks_per_key = ui.avg_data_blocks_per_key,
      dcrdata->tables[found].indexes[dcrdata->tables[found].index_cnt].clustering_factor = ui
      .clustering_factor, dcrdata->tables[found].indexes[dcrdata->tables[found].index_cnt].
      sample_size = ui.sample_size, dcrdata->tables[found].indexes[dcrdata->tables[found].index_cnt].
      last_analyzed = ui.last_analyzed,
      dcrdata->tables[found].indexes[dcrdata->tables[found].index_cnt].last_analyzed_null_ind =
      last_analyzed_null_ind_col, dcrdata->tables[found].indexes[dcrdata->tables[found].index_cnt].
      global_stats = ui.global_stats, dcrdata->tables[found].indexes[dcrdata->tables[found].index_cnt
      ].user_stats = ui.user_stats
     ENDIF
    HEAD uic.column_position
     IF (found > 0)
      dcrdata->tables[found].indexes[dcrdata->tables[found].index_cnt].index_column_cnt = (dcrdata->
      tables[found].indexes[dcrdata->tables[found].index_cnt].index_column_cnt+ 1), stat = alterlist(
       dcrdata->tables[found].indexes[dcrdata->tables[found].index_cnt].index_columns,dcrdata->
       tables[found].indexes[dcrdata->tables[found].index_cnt].index_column_cnt), dcrdata->tables[
      found].indexes[dcrdata->tables[found].index_cnt].index_columns[dcrdata->tables[found].indexes[
      dcrdata->tables[found].index_cnt].index_column_cnt].column_name = uic.column_name,
      dcrdata->tables[found].indexes[dcrdata->tables[found].index_cnt].index_columns[dcrdata->tables[
      found].indexes[dcrdata->tables[found].index_cnt].index_column_cnt].column_position = uic
      .column_position
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dcrdata->stat_type="LIVE"))
    FOR (dgtr_cnt = 1 TO dcrdata->table_cnt)
      FOR (dgtr_cnt2 = 1 TO dcrdata->tables[dgtr_cnt].column_cnt)
        IF (dcr_init_dict_hist_vals(null)=0)
         RETURN(0)
        ENDIF
        SET dcr_hist_vals->tbl_name = dcrdata->tables[dgtr_cnt].table_name
        SET dcr_hist_vals->col_name = dcrdata->tables[dgtr_cnt].columns[dgtr_cnt2].column_name
        SET dcr_hist_vals->ccl_data_type = dcrdata->tables[dgtr_cnt].columns[dgtr_cnt2].ccl_data_type
        IF (dcr_get_dict_hist_vals(null)=0)
         RETURN(0)
        ENDIF
        SET dcrdata->tables[dgtr_cnt].columns[dgtr_cnt2].histogram_cnt = dcr_hist_vals->hist_cnt
        SET stat = alterlist(dcrdata->tables[dgtr_cnt].columns[dgtr_cnt2].histogram,dcr_hist_vals->
         hist_cnt)
        SET dcrdata->tables[dgtr_cnt].columns[dgtr_cnt2].histogram_type = dcr_hist_vals->hist_type
        FOR (dgtr_cnt3 = 1 TO dcr_hist_vals->hist_cnt)
         SET dcrdata->tables[dgtr_cnt].columns[dgtr_cnt2].histogram[dgtr_cnt3].col_val =
         dcr_hist_vals->hist[dgtr_cnt3].col_val
         SET dcrdata->tables[dgtr_cnt].columns[dgtr_cnt2].histogram[dgtr_cnt3].rows_per_key =
         dcr_hist_vals->hist[dgtr_cnt3].rows_per_key
        ENDFOR
      ENDFOR
    ENDFOR
   ENDIF
   IF ((dm_err->debug_flag > 2))
    SET message = nowindow
    CALL clear(1,1)
    CALL echorecord(dcrdata)
    SET message = window
   ENDIF
   IF ((dcrdata->destination="temp"))
    SET dm_err->eproc = "Finished loading statistics information."
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   IF ((dcrdata->table_cnt=0))
    SET dm_err->eproc = "Generating empty report as no tables qualified."
    SELECT INTO value(dcrdata->destination)
     FROM (dummyt d  WITH seq = value(dcrdata->table_cnt))
     HEAD REPORT
      col 0, "TABLE STATISTIC REPORT",
      CALL center(concat("Report Date/Time: ",format(cnvtdatetime(curdate,curtime3),
        "MM/DD/YYYY HH:MM:SS;;Q")),0,132),
      row + 2, col 0, "Environment Name:",
      col 20, dcrdata->cur_env, row + 1,
      col 0, "Database Name:", col 20,
      dcrdata->cur_db, row + 1, col 0,
      "Table Criteria:"
      IF ((dcrdata->table_criteria="DM2REQLIST"))
       FOR (ddtr_cnt = 1 TO dcrdata->req_cnt)
         col 20, dcrdata->req_list[ddtr_cnt].tbl_name, row + 1
       ENDFOR
      ELSE
       col 20, dcrdata->table_criteria
      ENDIF
      row + 2, col 0, "^^^^^^^^^^^^^^^^ Table does not exist ^^^^^^^^^^^^^^^^"
     FOOT REPORT
      row + 1,
      CALL center("*** END OF REPORT ***",1,132)
     WITH nocounter, nullreport, maxcol = 132,
      format = variable, formfeed = none
    ;end select
   ELSE
    SET dm_err->eproc = "Generating report from record structure."
    SELECT INTO value(dcrdata->destination)
     FROM (dummyt d  WITH seq = value(dcrdata->table_cnt))
     HEAD REPORT
      col 0, "TABLE STATISTIC REPORT",
      CALL center(concat("Report Date/Time: ",format(cnvtdatetime(curdate,curtime3),
        "MM/DD/YYYY HH:MM:SS;;Q")),0,132),
      row + 2, col 0, "Environment Name:",
      col 20, dcrdata->cur_env, row + 1,
      col 0, "Database Name:", col 20,
      dcrdata->cur_db, row + 1, col 0,
      "Table Criteria:"
      IF ((dcrdata->table_criteria="DM2REQLIST"))
       FOR (ddtr_cnt = 1 TO dcrdata->req_cnt)
         col 20, dcrdata->req_list[ddtr_cnt].tbl_name, row + 1
       ENDFOR
      ELSE
       col 20, dcrdata->table_criteria
      ENDIF
     DETAIL
      row + 2, col 0, "Table Name:",
      col 12, dcrdata->tables[d.seq].table_name, row + 2,
      col 0, "|------------------Table Statistics-----------------|", col 66,
      "|----------------Table Modifications----------------|", row + 1, col 22,
      "   Avg", row + 1, col 22,
      "   Row", row + 1, col 0,
      "  Num_Rows", col 11, "    Blocks",
      col 22, "Length", col 31,
      "Last_Analyzed", col 66, "   Inserts",
      col 77, "   Updates", col 88,
      "   Deletes", col 99, "     Timestamp",
      col 114, "Trunc", row + 1
      IF ((dcrdata->tables[d.seq].last_analyzed_null_ind=0))
       IF ((dcrdata->tables[d.seq].num_rows < 9999999999.0))
        col 0, dcrdata->tables[d.seq].num_rows"##########"
       ELSE
        col 0, "**********"
       ENDIF
       IF ((dcrdata->tables[d.seq].blocks < 9999999999.0))
        col 11, dcrdata->tables[d.seq].blocks"##########"
       ELSE
        col 11, "**********"
       ENDIF
       col 22, dcrdata->tables[d.seq].avg_row_length"######", col 31,
       dcrdata->tables[d.seq].last_analyzed"MM/DD/YY HH:MM;;Q"
      ELSE
       col 0, "^^^^^^^^^^^^^^^^ No Table Statistics ^^^^^^^^^^^^^^^^"
      ENDIF
      IF ((dcrdata->tables[d.seq].table_mods_null_ind=0))
       IF ((dcrdata->tables[d.seq].inserts < 9999999999.0))
        col 66, dcrdata->tables[d.seq].inserts"##########"
       ELSE
        col 66, "**********"
       ENDIF
       IF ((dcrdata->tables[d.seq].updates < 9999999999.0))
        col 77, dcrdata->tables[d.seq].updates"##########"
       ELSE
        col 77, "**********"
       ENDIF
       IF ((dcrdata->tables[d.seq].deletes < 9999999999.0))
        col 88, dcrdata->tables[d.seq].deletes"##########"
       ELSE
        col 88, "**********"
       ENDIF
       col 99, dcrdata->tables[d.seq].timestamp"MM/DD/YY HH:MM;;Q", col 114,
       dcrdata->tables[d.seq].truncated"#####;R"
      ELSE
       col 66, "^^^^^^^^^^^^^^^ No Table Modifications ^^^^^^^^^^^^^^"
      ENDIF
      row + 2,
      CALL print(fillstring(126,"-")), row + 1
      FOR (ddtr_iter2 = 1 TO dcrdata->tables[d.seq].index_cnt)
        IF (mod(ddtr_iter2,7)=1)
         row + 1, col 66, " Avg",
         col 71, " Avg", row + 1,
         col 66, "Leaf", col 71,
         "Data", row + 1, col 42,
         "  Distinct", col 53, "  B",
         col 57, "    Leaf", col 66,
         "Blk/", col 71, "Blk/",
         col 76, "  Cluster", row + 1,
         col 0, "Index Name", col 31,
         "  Num_Rows", col 42, "      Keys",
         col 53, "LVL", col 57,
         "  Blocks", col 66, " Key",
         col 71, " Key", col 76,
         "   Factor", col 89, " Last_Analyzed",
         row + 1
        ENDIF
        row + 1, col 0, dcrdata->tables[d.seq].indexes[ddtr_iter2].index_name
        "##############################"
        IF ((dcrdata->tables[d.seq].indexes[ddtr_iter2].last_analyzed_null_ind=0))
         IF ((dcrdata->tables[d.seq].indexes[ddtr_iter2].num_rows < 9999999999.0))
          col 31, dcrdata->tables[d.seq].indexes[ddtr_iter2].num_rows"##########"
         ELSE
          col 31, "**********"
         ENDIF
         IF ((dcrdata->tables[d.seq].indexes[ddtr_iter2].distinct_keys < 9999999999.0))
          col 42, dcrdata->tables[d.seq].indexes[ddtr_iter2].distinct_keys"##########"
         ELSE
          col 42, "**********"
         ENDIF
         col 53, dcrdata->tables[d.seq].indexes[ddtr_iter2].b_lvl"###", col 57,
         dcrdata->tables[d.seq].indexes[ddtr_iter2].leaf_blocks"########", col 66, dcrdata->tables[d
         .seq].indexes[ddtr_iter2].avg_leaf_blocks_per_key"####",
         col 71, dcrdata->tables[d.seq].indexes[ddtr_iter2].avg_data_blocks_per_key"####"
         IF ((dcrdata->tables[d.seq].indexes[ddtr_iter2].clustering_factor < 999999999.0))
          col 76, dcrdata->tables[d.seq].indexes[ddtr_iter2].clustering_factor"#########"
         ELSE
          col 76, "*********"
         ENDIF
         col 89, dcrdata->tables[d.seq].indexes[ddtr_iter2].last_analyzed"MM/DD/YY HH:MM;;Q"
        ELSE
         col 31, "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ No Index Statistics ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
        ENDIF
        FOR (ddtr_iter3 = 1 TO dcrdata->tables[d.seq].indexes[ddtr_iter2].index_column_cnt)
          IF (ddtr_iter3=1)
           dcrdata->tables[d.seq].index_column_concat = "("
          ENDIF
          dcrdata->tables[d.seq].index_column_concat = notrim(concat(dcrdata->tables[d.seq].
            index_column_concat,dcrdata->tables[d.seq].indexes[ddtr_iter2].index_columns[ddtr_iter3].
            column_name," | "))
          IF ((ddtr_iter3=dcrdata->tables[d.seq].indexes[ddtr_iter2].index_column_cnt))
           dcrdata->tables[d.seq].index_column_concat = concat(substring(1,(size(dcrdata->tables[d
              .seq].index_column_concat) - 3),dcrdata->tables[d.seq].index_column_concat),")")
          ENDIF
        ENDFOR
        IF (size(dcrdata->tables[d.seq].index_column_concat) >= 123)
         dcrdata->tables[d.seq].index_column_concat = concat(substring(1,120,dcrdata->tables[d.seq].
           index_column_concat),"...)")
        ENDIF
        row + 1, col 2, dcrdata->tables[d.seq].index_column_concat
      ENDFOR
      row + 2,
      CALL print(fillstring(126,"-")), row + 1,
      row + 1, col 0, "* = CCL using literals for this column"
      FOR (ddtr_iter2 = 1 TO dcrdata->tables[d.seq].column_cnt)
        IF (mod(ddtr_iter2,16)=1)
         row + 1, col 71, "   Avg",
         row + 1, col 32, "       Num",
         col 54, "       Num", col 65,
         "  Num", col 71, "Column",
         row + 1, col 1, "Column Name",
         col 32, "  Distinct", col 44,
         "  Density", col 54, "     Nulls",
         col 65, "Bckts", col 71,
         "Length", col 83, "Last Analyzed",
         row + 1
        ENDIF
        IF ((dcrdata->tables[d.seq].columns[ddtr_iter2].lit_column_ind=1))
         row + 1, col 0, "*",
         dcrdata->tables[d.seq].columns[ddtr_iter2].column_name"##############################"
        ELSE
         row + 1, col 0, " ",
         dcrdata->tables[d.seq].columns[ddtr_iter2].column_name"##############################"
        ENDIF
        IF ((dcrdata->tables[d.seq].columns[ddtr_iter2].stat_null_ind=0))
         IF ((dcrdata->tables[d.seq].columns[ddtr_iter2].num_distinct < 9999999999.0))
          col 32, dcrdata->tables[d.seq].columns[ddtr_iter2].num_distinct"##########"
         ELSE
          col 32, "**********"
         ENDIF
         col 44, dcrdata->tables[d.seq].columns[ddtr_iter2].density"#.#######;;F"
         IF ((dcrdata->tables[d.seq].columns[ddtr_iter2].num_nulls < 9999999999.0))
          col 54, dcrdata->tables[d.seq].columns[ddtr_iter2].num_nulls"##########"
         ELSE
          col 54, "**********"
         ENDIF
         col 65, dcrdata->tables[d.seq].columns[ddtr_iter2].num_buckets"#####", col 71,
         dcrdata->tables[d.seq].columns[ddtr_iter2].avg_column_length"######", col 83, dcrdata->
         tables[d.seq].columns[ddtr_iter2].last_analyzed"MM/DD/YY HH:MM;;Q"
         IF ((dcrdata->stat_type="LIVE")
          AND (dcrdata->tables[d.seq].columns[ddtr_iter2].histogram_type != "NONE")
          AND ddtr_disp_hist="YES")
          row + 2, col 1,
          CALL print(concat(dcrdata->tables[d.seq].columns[ddtr_iter2].histogram_type,
           " histogram for ",dcrdata->tables[d.seq].columns[ddtr_iter2].column_name)),
          row + 1
          IF ((dcrdata->tables[d.seq].columns[ddtr_iter2].histogram_type="HEIGHT BALANCED"))
           col 1, "Endpoint Value", col 35,
           "No. of buckets consumed", row + 1
           FOR (dgtr_cnt3 = 1 TO dcrdata->tables[d.seq].columns[ddtr_iter2].histogram_cnt)
             col 1,
             CALL print(substring(1,30,dcrdata->tables[d.seq].columns[ddtr_iter2].histogram[dgtr_cnt3
              ].col_val)), col 35,
             CALL print(cnvtstring(dcrdata->tables[d.seq].columns[ddtr_iter2].histogram[dgtr_cnt3].
              rows_per_key)), row + 1
           ENDFOR
           row + 1
          ELSE
           col 1, "Column Value", col 35,
           "Frequency", row + 1
           FOR (dgtr_cnt3 = 1 TO dcrdata->tables[d.seq].columns[ddtr_iter2].histogram_cnt)
             col 1,
             CALL print(substring(1,30,dcrdata->tables[d.seq].columns[ddtr_iter2].histogram[dgtr_cnt3
              ].col_val)), col 35,
             CALL print(cnvtstring(dcrdata->tables[d.seq].columns[ddtr_iter2].histogram[dgtr_cnt3].
              rows_per_key)), row + 1
           ENDFOR
          ENDIF
          IF (mod((ddtr_iter2+ 1),16) != 1)
           row + 1, col 71, "   Avg",
           row + 1, col 32, "       Num",
           col 54, "       Num", col 65,
           "  Num", col 71, "Column",
           row + 1, col 1, "Column Name",
           col 32, "  Distinct", col 44,
           "  Density", col 54, "     Nulls",
           col 65, "Bckts", col 71,
           "Length", col 83, " Last Analyzed",
           row + 1
          ENDIF
         ENDIF
        ELSE
         col 31, "^^^^^^^^^^^^^^^^^ No Column Statistics ^^^^^^^^^^^^^^^^"
        ENDIF
      ENDFOR
      row + 2,
      CALL print(fillstring(126,"-")), row + 1
     FOOT REPORT
      row + 1,
      CALL center("*** END OF REPORT ***",1,132)
     WITH nocounter, nullreport, maxcol = 132,
      format = variable, formfeed = none
    ;end select
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_script
 CALL clear(1,1)
 SET message = nowindow
 IF ((dm_err->err_ind=1))
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
 ENDIF
 SET dm_err->eproc = "Ending DM2_DBSTATS_TABLE_RPT."
 CALL final_disp_msg("dm2_dbstats_tbl_rpt")
END GO
