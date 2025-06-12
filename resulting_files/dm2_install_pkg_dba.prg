CREATE PROGRAM dm2_install_pkg:dba
 SET trace progcachesize 255
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
 IF (validate(dm2_install_pkg->process_option,"NOT_SET")="NOT_SET")
  RECORD dm2_install_pkg(
    1 process_option = vc
    1 description = vc
    1 source_rdbms = vc
    1 admin_load_ind = i4
    1 num_of_pkgs = i4
  )
  SET dm2_install_pkg->process_option = "NORMAL"
  SET dm2_install_pkg->description = " "
  SET dm2_install_pkg->source_rdbms = " "
  SET dm2_install_pkg->admin_load_ind = - (1)
  SET dm2_install_pkg->num_of_pkgs = 0
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
 IF (validate(drr_flex_sched->sched_set_up,8)=8
  AND validate(drr_flex_sched->sched_set_up,9)=9)
  FREE RECORD drr_flex_sched
  RECORD drr_flex_sched(
    1 sched_set_up = i2
    1 status = i2
    1 max_runners = i2
    1 runner_time_limit = i2
    1 readme_time_periods = i2
    1 schema_time_periods = i2
    1 readme_schedule[*]
      2 time_period = vc
      2 start_time = f8
      2 end_time = f8
      2 num_of_runners = i2
      2 start_time_hh = i2
      2 start_time_am_pm = c2
      2 end_time_hh = i2
      2 end_time_am_pm = c2
      2 start_time_hhmm = f8
      2 end_time_hhmm = f8
    1 schema_schedule[*]
      2 time_period = vc
      2 start_time = f8
      2 end_time = f8
      2 num_of_runners = i2
      2 start_time_hh = i2
      2 start_time_am_pm = c2
      2 end_time_hh = i2
      2 end_time_am_pm = c2
      2 start_time_hhmm = f8
      2 end_time_hhmm = f8
    1 pkg_using_schedule = i2
    1 pkg_number = vc
    1 pkg_install_mode = vc
    1 num_sched_runners = i2
    1 num_active_runners = i2
    1 num_stopping_runners = i2
    1 tot_num_runners = i2
    1 num_runners_to_stop = i2
    1 num_runners_to_start = i2
  )
  SET drr_flex_sched->sched_set_up = 0
  SET drr_flex_sched->status = 0
  SET drr_flex_sched->max_runners = 10
  SET drr_flex_sched->runner_time_limit = - (1)
  SET drr_flex_sched->readme_time_periods = 0
  SET drr_flex_sched->schema_time_periods = 0
  SET drr_flex_sched->pkg_using_schedule = 0
  SET drr_flex_sched->pkg_number = "DM2NOTSET"
  SET drr_flex_sched->pkg_install_mode = "DM2NOTSET"
  SET drr_flex_sched->num_sched_runners = 0
  SET drr_flex_sched->num_active_runners = 0
  SET drr_flex_sched->num_stopping_runners = 0
  SET drr_flex_sched->tot_num_runners = 0
  SET drr_flex_sched->num_runners_to_stop = 0
  SET drr_flex_sched->num_runners_to_start = 0
 ENDIF
 IF (validate(drr_runner_misc->mode,"X")="X"
  AND validate(drr_runner_misc->mode,"Y")="Y")
  FREE RECORD drr_runner_misc
  RECORD drr_runner_misc(
    1 mode = vc
    1 runner_identifier = vc
  )
  SET drr_runner_misc->mode = "DM2NOTSET"
  SET drr_runner_misc->runner_identifier = "DM2NOTSET"
 ENDIF
 DECLARE time_periods = i2
 DECLARE drr_submit_background_process(dsbp_user=vc,dsbp_pword=vc,dsbp_cnnect_str=vc,dsbp_queue_name=
  vc,dsbp_process_type=vc,
  dsbp_plan_id=f8,dsbp_install_mode=vc) = i2
 DECLARE drr_get_process_status(dgps_process_type=vc,dgps_plan_id=f8,dgps_status_out=i2(ref)) = i2
 DECLARE drr_cleanup_process_event() = i2
 DECLARE drr_cleanup_dm_info_runners() = i2
 DECLARE drr_cleanup_dm_info_sched_usage() = i2
 DECLARE drr_stop_installs_using_flex_sched() = i2
 DECLARE drr_stop_runners(dsr_mode=vc,dsr_number=i2) = i2
 DECLARE drr_start_runners(dstr_num_runners=i2,dstr_user=vc,dstr_pword=vc,dstr_cnnect_str=vc,
  dstr_queue_name=vc) = i2
 DECLARE drr_get_flexible_schedule() = i2
 DECLARE drr_use_flexible_schedule(dufs_prompt_ind=i2,dufs_pkg_number=vc,dufs_install_mode=vc,
  dufs_sel_ret=vc(ref)) = i2
 DECLARE drr_maintain_runners(dmr_user=vc,dmr_pword=vc,dmr_cnnect_str=vc,dmr_queue_name=vc,dm_process
  =vc) = i2
 DECLARE drr_check_pkg_appl_status(dcpas_appl_id=vc,dcpas_pkg_status=i2(ref)) = i2
 DECLARE drr_check_runner_status(dcrs_runner_type=vc,dcrs_appl_id=vc,dcrs_status=i2(ref)) = i2
 DECLARE drr_insert_runner_row(dirr_runner_type=vc,dirr_appl_id=vc,dirr_desc=vc,dirr_status=i2,
  dirr_plan_id=f8) = i2
 DECLARE drr_assign_file_to_installs(dafi_detail_type=vc,dafi_file_name=vc,dafi_event_id=f8) = i2
 DECLARE drr_remove_runner_row(drrr_runner_type=vc,drrr_appl_id=vc) = i2
 DECLARE drr_modify_install_status(dmis_plan_id=f8,dmis_appl_id=vc,dmis_status=i2,dmis_reason=vc,
  dmis_requester=vc) = i2
 DECLARE drr_rr_insert_runner_row(drirr_runner_identifier=vc,drirr_appl_id=vc) = i2
 DECLARE drr_rr_check_runner_status(drcrs_runner_identifier=vc,drcrs_appl_id=vc,drcrs_status=i2(ref))
  = i2
 DECLARE drr_rr_cleanup_dm_info_runners(null) = i2
 DECLARE drr_rr_remove_runner_row(drrrr_runner_identifier=vc,drrrr_appl_id=vc) = i2
 DECLARE drr_rr_maintain_runners(drmr_user=vc,drmr_pword=vc,drmr_cnnct_str=vc,drmr_runners=i2,
  drmr_runner_identifier=vc) = i2
 DECLARE drr_rr_start_runners(drstr_num_runners=i2,drstr_user=vc,drstr_pword=vc,drstr_cnnct_str=vc,
  drstr_identifier=vc) = i2
 DECLARE drr_cleanup_adm_dm_info_runners(dcadir_dblink=vc) = i2
 DECLARE drr_chk_active_runners(dcar_dblink=vc,dcar_count=i4(ref)) = i2
 SET modify curaliasreuse 1
 SUBROUTINE drr_submit_background_process(dsbp_user,dsbp_pword,dsbp_cnnct_str,dsbp_queue_name,
  dsbp_process_type,dsbp_plan_id,dsbp_install_mode)
   DECLARE dsbp_connect_string = vc WITH protect, noconstant(" ")
   DECLARE dsbp_file_name = vc WITH protect, noconstant(" ")
   DECLARE dsbp_logfile_name = vc WITH protect, noconstant(" ")
   DECLARE dsbp_exec_cmd = vc WITH protect, noconstant(" ")
   DECLARE dsbp_chmod_cmd = vc WITH protect, noconstant(" ")
   DECLARE dsbp_loop_cnt = i2 WITH protect, noconstant(0)
   DECLARE dsbp_debug_flag = vc WITH protect, noconstant("0")
   DECLARE dsbp_stat = i4 WITH protect, noconstant(0)
   DECLARE dsbp_file_prefix = vc WITH protect, noconstant(" ")
   DECLARE dsbp_plan_id_str = vc WITH protect, noconstant(trim(cnvtstring(abs(dsbp_plan_id))))
   DECLARE dsbp_pkg_install_mode = vc WITH protect, noconstant(" ")
   DECLARE dsbp_mtr_install_mode = vc WITH protect, noconstant(" ")
   IF (((dsbp_user=" ") OR (dsbp_pword=" ")) )
    SET dm_err->err_ind = 1
    SET dm_err->emsg =
    "Invalid database connection information for subroutine drr_submit_background_process"
    SET dm_err->eproc = "Validating connection information passed into subroutine."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (dsbp_cnnct_str > " "
    AND dsbp_cnnct_str != "NONE")
    SET dsbp_connect_string = build("'",dsbp_user,"/",dsbp_pword,"@",
     dsbp_cnnct_str,"'")
   ELSE
    SET dsbp_connect_string = build("'",dsbp_user,"/",dsbp_pword,"'")
   ENDIF
   SET dsbp_debug_flag = cnvtstring(dm_err->debug_flag)
   IF (dsbp_process_type=dpl_package_install)
    SET dsbp_file_prefix = "dm2obb"
   ELSEIF (dsbp_process_type=dpl_install_monitor)
    SET dsbp_file_prefix = "dm2obm"
   ELSEIF (dsbp_process_type=dpl_admin_upgrade)
    SET dsbp_file_prefix = "dm2ob_admupg"
   ENDIF
   IF (get_unique_file(concat(dsbp_file_prefix,dsbp_plan_id_str),".log")=0)
    RETURN(0)
   ENDIF
   SET dsbp_logfile_name = dm_err->unique_fname
   SET dsbp_file_name = replace(dsbp_logfile_name,".log",".ksh",0)
   IF (dsbp_process_type=dpl_package_install)
    SET dsbp_file_prefix = "dm2obb"
   ELSEIF (dsbp_process_type=dpl_install_monitor)
    SET dsbp_file_prefix = "dm2obm"
   ELSEIF (dsbp_process_type=dpl_admin_upgrade)
    SET dsbp_file_prefix = "dm2ob_admupg"
   ENDIF
   SET dsbp_pkg_install_mode = dsbp_install_mode
   SET dsbp_mtr_install_mode = dsbp_install_mode
   IF (((dsbp_install_mode="*ABG"
    AND dsbp_process_type=dpl_package_install) OR (dsbp_process_type=dpl_admin_upgrade)) )
    IF (dir_get_debug_trace_data(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dsbp_install_mode="*ABG")
    SET dsbp_mtr_install_mode = replace(dsbp_install_mode,"ABG","",2)
   ELSE
    SET dsbp_pkg_install_mode = concat(dsbp_install_mode,"BG")
   ENDIF
   SET dm_err->eproc = "Creating job to execute background process."
   SELECT INTO trim(dsbp_file_name)
    DETAIL
     col 0, "#!/usr/bin/ksh", row + 1,
     col 0, "# Executing Background Runner...", row + 1,
     col 0, "#", row + 1,
     col 0, ". $cer_mgr/",
     CALL print(trim(cnvtlower(logical("environment")))),
     "_environment.ksh", row + 1, col 0,
     "ccl <<!", row + 1, col 0,
     "SET TRACE NORANGECACHE 0 go", row + 1, col 0,
     "free define oraclesystem go", row + 1, col 0,
     "define oraclesystem ", dsbp_connect_string, " go"
     IF (((dsbp_install_mode="*ABG"
      AND dsbp_process_type=dpl_package_install) OR (dsbp_process_type=dpl_admin_upgrade)) )
      IF ((dir_ui_misc->debug_level > 0))
       row + 1, col 0, "set dm2_debug_flag = ",
       dir_ui_misc->debug_level, " go"
      ENDIF
      IF ((dir_ui_misc->trace_flag=1))
       row + 1, col 0, "set trace rdbdebug go",
       row + 1, col 0, "set trace rdbbind go",
       row + 1, col 0, "set trace rdbbind2 go"
      ENDIF
     ELSE
      row + 1, col 0, "set dm2_debug_flag = ",
      dsbp_debug_flag, " go"
     ENDIF
     row + 1
     IF (dsbp_process_type=dpl_admin_upgrade)
      col 0, "declare dm2_admin_upgrade_os_session_logfile = vc with public,noconstant('",
      dsbp_logfile_name,
      "') go"
     ELSE
      col 0, "declare dm2_package_os_session_logfile = vc with public,noconstant('",
      dsbp_logfile_name,
      "') go"
     ENDIF
     row + 1
     IF (dsbp_process_type=dpl_package_install)
      col 0, "ocd_incl_Schema2 ", dsbp_plan_id_str,
      ", '", dsbp_pkg_install_mode, "' go"
     ELSEIF (dsbp_process_type=dpl_install_monitor)
      col 0, "dm2_install_monitor ", dsbp_plan_id_str,
      ",'", dsbp_mtr_install_mode, "' go"
     ELSEIF (dsbp_process_type=dpl_admin_upgrade)
      col 0, "dm_ocd_setup_admin go"
     ENDIF
     row + 1, col 0, "exit",
     row + 1, col 0, "!",
     row + 1, col 0, "sleep 30"
    WITH nocounter, maxrow = 1, format = variable,
     formfeed = none
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dsbp_chmod_cmd = concat("chmod 777 $CCLUSERDIR/",dsbp_file_name)
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc = concat("drr_submit_background_process changing permissions for ",
     dsbp_file_name,".")
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (dm2_push_dcl(dsbp_chmod_cmd)=0)
    RETURN(0)
   ENDIF
   SET dsbp_exec_cmd = concat("nohup ","$CCLUSERDIR/",dsbp_file_name," > $CCLUSERDIR/",
    dsbp_logfile_name,
    " 2>&1 &")
   SET dm_err->eproc = concat("Executing ",trim(dsbp_file_name)," - results will be logged to ",trim(
     dsbp_logfile_name),".")
   CALL disp_msg(" ",dm_err->logfile,0)
   CALL dcl(dsbp_exec_cmd,size(dsbp_exec_cmd),dsbp_stat)
   IF (dsbp_stat=0)
    IF (parse_errfile(dsbp_logfile_name)=0)
     RETURN(0)
    ENDIF
    SET dm_err->disp_msg_emsg = dm_err->errtext
    SET dm_err->emsg = dm_err->disp_msg_emsg
    SET dm_err->eproc = concat("dm2_push_dcl executing: ",dsbp_exec_cmd)
    SET dm_err->err_ind = 1
    CALL disp_msg("dm_err->disp_msg_emsg",dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dsbp_exec_cmd = concat("ps -ef | grep ",dsbp_file_name," | grep -v grep")
   SET dm_err->disp_dcl_err_ind = 0
   IF (dm2_push_dcl(dsbp_exec_cmd)=0)
    IF ((dm_err->err_ind=1))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   IF (findstring(dsbp_file_name,dm_err->errtext)=0)
    SET dm_err->disp_msg_emsg = "Unable to locate process for this job."
    SET dm_err->emsg = dm_err->disp_msg_emsg
    SET dm_err->eproc = concat("Validating ",trim(dsbp_file_name)," was successfully executed.")
    SET dm_err->err_ind = 1
    CALL disp_msg("dm_err->disp_msg_emsg",dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_get_process_status(dgps_process_type,dgps_plan_id,dgps_status_out)
   DECLARE dgps_dm_info_exists = i2 WITH protect, noconstant(0)
   IF (dm2_table_and_ccldef_exists("DM_INFO",dgps_dm_info_exists)=0)
    RETURN(0)
   ENDIF
   IF (dgps_dm_info_exists != 1)
    SET dm_err->eproc = "DM_INFO does not exist. Setting status to execute by default."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dgps_status_out = 1
    RETURN(1)
   ENDIF
   IF (drr_cleanup_dm_info_runners(null)=0)
    RETURN(0)
   ENDIF
   SET dgps_status_out = 0
   SET dm_err->eproc = "Query for process status"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain=cnvtupper(dgps_process_type)
     AND d.info_char=trim(cnvtstring(dgps_plan_id))
    DETAIL
     dgps_status_out = d.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_assign_file_to_installs(dafi_detail_type,dafi_file_name,dafi_event_id)
   DECLARE dfsi_cnt = i4 WITH protect, noconstant(0)
   DECLARE dsfi_ndx = i4 WITH protect, noconstant(0)
   DECLARE dfsi_optimizer_hint = vc WITH protect, noconstant("")
   SET dfsi_optimizer_hint = concat(" LEADING(DP DPE)","INDEX(DP XAK1DM_PROCESS)",
    "INDEX(DPE XIE1DM_PROCESS_EVENT)")
   FREE RECORD dsfi_id
   RECORD dsfi_id(
     1 id_cnt = i4
     1 qual[*]
       2 event_id = f8
       2 found = i2
   )
   IF (drr_cleanup_dm_info_runners(null)=0)
    RETURN(0)
   ENDIF
   IF (dafi_event_id=0)
    SET dm_err->eproc = "Gather any active Package Install event ids"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dm_process dp,
      dm_process_event dpe
     WHERE dp.dm_process_id=dpe.dm_process_id
      AND dp.process_name=dpl_package_install
      AND dp.action_type=dpl_execution
      AND (( NOT (dpe.event_status IN (dpl_failed, dpl_complete, dpl_failure, dpl_success))) OR (dpe
     .event_status = null))
     DETAIL
      dsfi_id->id_cnt = (dsfi_id->id_cnt+ 1), stat = alterlist(dsfi_id->qual,dsfi_id->id_cnt),
      dsfi_id->qual[dsfi_id->id_cnt].event_id = dpe.dm_process_event_id
     WITH nocounter, orahintcbo(value(dfsi_optimizer_hint))
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF ((dsfi_id->id_cnt=0))
     RETURN(1)
    ENDIF
   ELSE
    SET dsfi_id->id_cnt = (dsfi_id->id_cnt+ 1)
    SET stat = alterlist(dsfi_id->qual,dsfi_id->id_cnt)
    SET dsfi_id->qual[dsfi_id->id_cnt].event_id = dafi_event_id
   ENDIF
   SET dm_err->eproc = "Query for event details"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_process_event_dtl dped,
     (dummyt d  WITH seq = value(dsfi_id->id_cnt))
    PLAN (d
     WHERE d.seq > 0)
     JOIN (dped
     WHERE (dped.dm_process_event_id=dsfi_id->qual[d.seq].event_id)
      AND dped.detail_type=cnvtupper(dafi_detail_type))
    DETAIL
     dsfi_id->qual[d.seq].found = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dsfi_id)
   ENDIF
   IF (locateval(dsfi_ndx,1,dsfi_id->id_cnt,0,dsfi_id->qual[dsfi_ndx].found) > 0)
    FOR (dsfi_cnt = 1 TO dsfi_id->id_cnt)
      IF ((dsfi_id->qual[dsfi_cnt].found=0))
       CALL dm2_process_log_add_detail_text(cnvtupper(dafi_detail_type),dafi_file_name)
       SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_number = 0
       SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_date = cnvtdatetime
       (curdate,curtime3)
       IF (dm2_process_log_dtl_row(dsfi_id->qual[dsfi_cnt].event_id,0)=0)
        RETURN(0)
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_cleanup_dm_info_runners(null)
   DECLARE dcdir_dm_info_fnd_ind = i2 WITH protect, noconstant(0)
   DECLARE dcdir_applx = i4 WITH protect, noconstant(0)
   FREE RECORD dcdir_appl_rs
   RECORD dcdir_appl_rs(
     1 cnt = i4
     1 qual[*]
       2 appl_id = vc
   )
   IF (dm2_table_and_ccldef_exists("DM_INFO",dcdir_dm_info_fnd_ind)=0)
    RETURN(0)
   ENDIF
   IF (dcdir_dm_info_fnd_ind=0)
    IF ((dm_err->debug_flag > 0))
     CALL echo(
      "DM_INFO table not found in dm2_user_tables, bypassing dm2_cleanup_dm_info_runners logic...")
    ENDIF
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Getting a distinct list of appl ids attached to a runner..."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT DISTINCT INTO "nl:"
    di.info_name
    FROM dm_info di
    WHERE di.info_domain IN ("DM2_BACKGROUND_RUNNER", "DM2_INSTALL_RUNNER", "DM2_SCHEMA_RUNNER",
    "DM2_README_RUNNER", "DM2_SET_READY_TO_RUN",
    "DM2_INSTALL_PKG", "DM2_INSTALL_MONITOR", "DM2_ADS_DRIVER_GEN:AUDSID",
    "DM2_ADS_CHILDEST_GEN:AUDSID")
    HEAD REPORT
     dcdir_applx = 0
    DETAIL
     dcdir_applx = (dcdir_applx+ 1)
     IF (mod(dcdir_applx,10)=1)
      stat = alterlist(dcdir_appl_rs->qual,(dcdir_applx+ 9))
     ENDIF
     dcdir_appl_rs->qual[dcdir_applx].appl_id = trim(di.info_name,3)
    FOOT REPORT
     dcdir_appl_rs->cnt = dcdir_applx, stat = alterlist(dcdir_appl_rs->qual,dcdir_applx)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dcdir_appl_rs->cnt > 0))
    SET dcdir_applx = 1
    WHILE ((dcdir_applx <= dcdir_appl_rs->cnt))
     CASE (dm2_get_appl_status(value(dcdir_appl_rs->qual[dcdir_applx].appl_id)))
      OF "I":
       IF ((dm_err->debug_flag > 1))
        CALL echo(concat("Application Id ",dcdir_appl_rs->qual[dcdir_applx].appl_id," is not active."
          ))
       ENDIF
       DELETE  FROM dm_info di
        WHERE di.info_domain IN ("DM2_BACKGROUND_RUNNER", "DM2_INSTALL_RUNNER", "DM2_SCHEMA_RUNNER",
        "DM2_README_RUNNER", "DM2_SET_READY_TO_RUN",
        "DM2_INSTALL_PKG", "DM2_INSTALL_MONITOR", "DM2_ADS_DRIVER_GEN:AUDSID",
        "DM2_ADS_CHILDEST_GEN:AUDSID")
         AND (di.info_name=dcdir_appl_rs->qual[dcdir_applx].appl_id)
        WITH nocounter
       ;end delete
       IF (check_error("Removing dm_info runner row(s) - appl id no longer active.")=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ELSE
        COMMIT
       ENDIF
      OF "A":
       IF ((dm_err->debug_flag > 1))
        CALL echo(concat("Application Id ",dcdir_appl_rs->qual[dcdir_applx].appl_id," is active."))
       ENDIF
      OF "E":
       IF ((dm_err->debug_flag > 1))
        CALL echo("Error Detected in dm2_get_appl_status")
       ENDIF
       RETURN(0)
     ENDCASE
     SET dcdir_applx = (dcdir_applx+ 1)
    ENDWHILE
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo("********** No Application Ids Detected **********")
    ENDIF
   ENDIF
   IF (dpl_ui_chk(dm2_process_rs->process_name)=0)
    RETURN(0)
   ENDIF
   IF ((((dm2_process_event_rs->ui_allowed_ind=1)) OR ((dm2_process_rs->process_name=dpl_sample))) )
    IF (drr_cleanup_process_event(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_cleanup_process_event(null)
   DECLARE dcpe_cnt = i4 WITH protect, noconstant(0)
   DECLARE dcpe_ndx = i4 WITH protect, noconstant(0)
   DECLARE dcpe_optimize_hint = vc WITH protect, noconstant("")
   DECLARE dcpe_optimize_hint1 = vc WITH protect, noconstant("")
   SET dcpe_optimize_hint = concat(" LEADING(DP DPE DPED)","INDEX(DP XAK1DM_PROCESS)",
    "INDEX(DPE XIE1DM_PROCESS_EVENT)","INDEX(DPED XIE1DM_PROCESS_EVENT_DTL) ")
   SET dcpe_optimize_hint1 = concat(" LEADING(DP DPE)","INDEX(DP XAK1DM_PROCESS)",
    "INDEX(DPE XIE1DM_PROCESS_EVENT)")
   IF (dpl_ui_chk(dm2_process_rs->process_name)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_process_event_rs->ui_allowed_ind=0)
    AND (dm2_process_rs->process_name != dpl_sample))
    RETURN(1)
   ENDIF
   FREE RECORD dcpe_appl
   RECORD dcpe_appl(
     1 cnt = i4
     1 qual[*]
       2 appl_id = vc
       2 plan_id = f8
       2 event_id = f8
       2 process_name = vc
       2 active_ind = i2
   )
   SET dm_err->eproc = "Getting distinct list of active processes in DM_PROCESS_EVENT..."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_process dp,
     dm_process_event dpe,
     dm_process_event_dtl dped
    WHERE dp.dm_process_id=dpe.dm_process_id
     AND dpe.dm_process_event_id=dped.dm_process_event_id
     AND dp.process_name IN (dpl_package_install, dpl_background_runner, dpl_install_runner,
    dpl_install_monitor, dpl_sample)
     AND (( NOT (dpe.event_status IN (dpl_failed, dpl_complete, dpl_failure, dpl_success))) OR (dpe
    .event_status = null))
     AND dped.detail_type=dpl_audsid
    HEAD REPORT
     dcpe_appl->cnt = 0, stat = alterlist(dcpe_appl->qual,dcpe_appl->cnt)
    DETAIL
     dcpe_appl->cnt = (dcpe_appl->cnt+ 1), stat = alterlist(dcpe_appl->qual,dcpe_appl->cnt),
     dcpe_appl->qual[dcpe_appl->cnt].appl_id = dped.detail_text,
     dcpe_appl->qual[dcpe_appl->cnt].plan_id = dpe.install_plan_id, dcpe_appl->qual[dcpe_appl->cnt].
     event_id = dpe.dm_process_event_id, dcpe_appl->qual[dcpe_appl->cnt].process_name = dp
     .process_name,
     dcpe_appl->qual[dcpe_appl->cnt].active_ind = 1
    WITH nocounter, nullreport, orahintcbo(value(dcpe_optimize_hint))
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcpe_appl)
   ENDIF
   IF ((dcpe_appl->cnt > 0))
    FOR (dcpe_cnt = 1 TO dcpe_appl->cnt)
      IF ((dcpe_appl->qual[dcpe_cnt].active_ind=1))
       CASE (dm2_get_appl_status(value(dcpe_appl->qual[dcpe_cnt].appl_id)))
        OF "I":
         IF ((dm_err->debug_flag > 1))
          CALL echo(concat("Application Id for event ",dcpe_appl->qual[dcpe_cnt].appl_id,
            " is not active."))
         ENDIF
         SET dm_err->eproc = "Mark appl_id for event as inactive"
         SELECT INTO "nl:"
          FROM (dummyt d  WITH seq = value(dcpe_appl->cnt))
          PLAN (d
           WHERE d.seq > 0
            AND (dcpe_appl->qual[d.seq].appl_id=dcpe_appl->qual[dcpe_cnt].appl_id))
          DETAIL
           dcpe_appl->qual[d.seq].active_ind = 0
          WITH nocounter
         ;end select
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          RETURN(0)
         ENDIF
        OF "A":
         IF ((dm_err->debug_flag > 1))
          CALL echo(concat("Application Id for event ",dcpe_appl->qual[dcpe_cnt].appl_id,
            " is active."))
         ENDIF
        OF "E":
         IF ((dm_err->debug_flag > 1))
          CALL echo("Error Detected in drr_cleanup_process_event")
         ENDIF
         RETURN(0)
       ENDCASE
      ENDIF
    ENDFOR
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo("********** No active processes found in DM_PROCESS_EVENT **********")
    ENDIF
    RETURN(1)
   ENDIF
   IF (locateval(dcpe_ndx,1,dcpe_appl->cnt,0,dcpe_appl->qual[dcpe_ndx].active_ind) > 0)
    SET dm_err->eproc = "Marking DM_PROCESS_EVENT rows as inactive"
    UPDATE  FROM dm_process_event dpe,
      (dummyt d  WITH seq = value(dcpe_appl->cnt))
     SET dpe.event_status = dpl_failed, dpe.message_txt = concat(dpe.message_txt,
       ": ACTIVE STATUS FOUND WITHOUT ACTIVE EVENT PROCESS")
     PLAN (d
      WHERE (dcpe_appl->qual[d.seq].active_ind=0))
      JOIN (dpe
      WHERE (dpe.dm_process_event_id=dcpe_appl->qual[d.seq].event_id)
       AND (( NOT (dpe.event_status IN (dpl_complete, dpl_failed))) OR (dpe.event_status = null))
       AND dpe.begin_dt_tm IS NOT null
       AND dpe.begin_dt_tm > cnvtdatetime("01-JAN-1900"))
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
    IF (locateval(dcpe_ndx,1,dcpe_appl->cnt,dpl_package_install,dcpe_appl->qual[dcpe_ndx].
     process_name) > 0)
     FOR (dcpe_cnt = 1 TO dcpe_appl->cnt)
       IF ((dcpe_appl->qual[dcpe_ndx].process_name=dpl_package_install)
        AND (dcpe_appl->qual[dcpe_ndx].active_ind=0))
        SET dm_err->eproc =
        "Mark any package installs as inactive for package installs without active events "
        UPDATE  FROM dm_process_event dpe1
         SET dpe1.event_status = dpl_failed, dpe1.message_txt = concat(dpe1.message_txt,
           ": ACTIVE STATUS FOUND WITHOUT ACTIVE EVENT PROCESS")
         WHERE dpe1.dm_process_event_id IN (
         (SELECT
          dpe.dm_process_event_id
          FROM dm_process dp,
           dm_process_event dpe
          WHERE dp.process_name=dpl_package_install
           AND action_type=dpl_itinerary_event
           AND (dpe.install_plan_id=dcpe_appl->qual[dcpe_ndx].plan_id)
           AND (( NOT (dpe.event_status IN (dpl_complete, dpl_failed, dpl_success, dpl_failure))) OR
          (dpe.event_status = null))
           AND dpe.begin_dt_tm IS NOT null
           AND dpe.begin_dt_tm > cnvtdatetime("01-JAN-1900")
          WITH orahintcbo(value(dcpe_optimize_hint1))))
         WITH nocounter
        ;end update
        IF (check_error(dm_err->eproc)=1)
         ROLLBACK
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ELSE
         COMMIT
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_cleanup_dm_info_sched_usage(null)
   DECLARE dcdisu_applx = i4 WITH protect, noconstant(0)
   FREE RECORD dcdisu_appl_rs
   RECORD dcdisu_appl_rs(
     1 cnt = i4
     1 qual[*]
       2 appl_id = vc
   )
   SET dm_err->eproc =
   "Getting a distinct list of appl ids attached to a package install using installation schedule..."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT DISTINCT INTO "nl:"
    di.info_char
    FROM dm_info di
    WHERE di.info_domain="DM2_FLEX_SCHED_USAGE"
    HEAD REPORT
     dcdisu_applx = 0
    DETAIL
     dcdisu_applx = (dcdisu_applx+ 1)
     IF (mod(dcdisu_applx,10)=1)
      stat = alterlist(dcdisu_appl_rs->qual,(dcdisu_applx+ 9))
     ENDIF
     dcdisu_appl_rs->qual[dcdisu_applx].appl_id = trim(di.info_char,3)
    FOOT REPORT
     dcdisu_appl_rs->cnt = dcdisu_applx, stat = alterlist(dcdisu_appl_rs->qual,dcdisu_applx)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dcdisu_appl_rs->cnt > 0))
    SET dcdisu_applx = 1
    WHILE ((dcdisu_applx <= dcdisu_appl_rs->cnt))
     CASE (dm2_get_appl_status(value(dcdisu_appl_rs->qual[dcdisu_applx].appl_id)))
      OF "I":
       IF ((dm_err->debug_flag > 1))
        CALL echo(build("Application Id ",dcdisu_appl_rs->qual[dcdisu_applx].appl_id,
          " is not active."))
       ENDIF
       DELETE  FROM dm_info di
        WHERE di.info_domain="DM2_FLEX_SCHED_USAGE"
         AND (di.info_char=dcdisu_appl_rs->qual[dcdisu_applx].appl_id)
        WITH nocounter
       ;end delete
       IF (check_error("Removing dm_info pkg row(s) - appl id no longer active.")=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ELSE
        COMMIT
       ENDIF
      OF "A":
       IF ((dm_err->debug_flag > 1))
        CALL echo(concat("Application Id ",dcdisu_appl_rs->qual[dcdisu_applx].appl_id," is active."))
       ENDIF
      OF "E":
       IF ((dm_err->debug_flag > 1))
        CALL echo("Error Detected in dm2_get_appl_status")
       ENDIF
       RETURN(0)
     ENDCASE
     SET dcdisu_applx = (dcdisu_applx+ 1)
    ENDWHILE
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo("********** No Application Ids Detected **********")
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_stop_installs_using_flex_sched(null)
   DECLARE dsiufs_cnt = i4 WITH protect, noconstant(0)
   FREE RECORD dsiufs_work
   RECORD dsiufs_work(
     1 cnt = i4
     1 qual[*]
       2 plan_id = f8
       2 appl_id = vc
   )
   SET dm_err->eproc = "Stopping (inactivating) all package installs using installation schedule..."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_FLEX_SCHED_USAGE"
     AND di.info_number > 0
    DETAIL
     dsiufs_work->cnt = (dsiufs_work->cnt+ 1), stat = alterlist(dsiufs_work->qual,dsiufs_work->cnt),
     dsiufs_work->qual[dsiufs_work->cnt].plan_id = abs(cnvtreal(di.info_name)),
     dsiufs_work->qual[dsiufs_work->cnt].appl_id = di.info_char
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    FOR (dsiufs_cnt = 1 TO dsiufs_work->cnt)
     IF (drr_modify_install_status(dsiufs_work->qual[dsiufs_cnt].plan_id,dsiufs_work->qual[dsiufs_cnt
      ].appl_id,0,concat("User ",curuser," requested stop of all Installs"),"STOP ALL INSTALLS")=0)
      RETURN(0)
     ENDIF
     IF ((dnotify->status=1)
      AND (dm2_process_event_rs->ui_allowed_ind=1))
      SET dnotify->process = "INSTALLPLAN"
      SET dnotify->plan_id = abs(dsiufs_work->qual[dsiufs_cnt].plan_id)
      SET dnotify->install_status = "STOPPED"
      SET dnotify->event = "Stopping All Active Install Plans"
      SET dnotify->msgtype = dpl_warning
      CALL dn_add_body_text(concat("User ",curuser,
        " has requested all Install Plans using the Installation ","Scheduler to Stop at ",format(
         cnvtdatetime(curdate,curtime3),";;q")),1)
      CALL dn_add_body_text(" ",0)
      CALL dn_add_body_text(concat("Install Plan ",trim(cnvtstring(dsiufs_work->qual[dsiufs_cnt].
          plan_id))," has been stopped"),0)
      SET dm2_process_event_rs->begin_dt_tm = cnvtdatetime(curdate,curtime3)
      SET dm2_process_event_rs->end_dt_tm = cnvtdatetime(curdate,curtime3)
      SET dm2_process_event_rs->install_plan_id = abs(dsiufs_work->qual[dsiufs_cnt].plan_id)
      SET dm2_process_event_rs->status = dpl_complete
      CALL dm2_process_log_add_detail_text(dpl_audit_name,"EMAIL:STOP_FLEXSCHED_INSTALL")
      CALL dm2_process_log_add_detail_text(dpl_audit_type,dpl_progress)
      IF (dn_notify(null)=0)
       RETURN(0)
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_modify_install_status(dmis_plan_id,dmis_appl_id,dmis_status,dmis_reason,
  dmis_requester)
   DECLARE dmis_cur_status = i2 WITH protect, noconstant(- (1))
   DECLARE dmis_cur_applid = vc WITH protect, noconstant("")
   DECLARE dmis_msg = vc WITH protect, noconstant("")
   DECLARE dmis_event_id = f8 WITH protect, noconstant(0.0)
   DECLARE dmis_status_changed_ind = i2 WITH protect, noconstant(0)
   IF (drr_get_process_status("DM2_INSTALL_PKG",dmis_plan_id,dmis_cur_status)=0)
    RETURN(0)
   ENDIF
   IF (dmis_cur_status=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Install in a Stop status. Exiting.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Obtain current appl_id for plan_id ",build(dmis_plan_id))
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_INSTALL_PKG"
     AND cnvtreal(di.info_char)=dmis_plan_id
    DETAIL
     dmis_cur_applid = di.info_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dmis_cur_status != dmis_status)
    SET dm_err->eproc = concat("Update DM2_INSTALL_PKG status for plan_id ",build(dmis_plan_id),
     " to ",build(dmis_status))
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
    ENDIF
    UPDATE  FROM dm_info di
     SET di.info_number = dmis_status, di.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)
       )
     WHERE di.info_domain="DM2_INSTALL_PKG"
      AND di.info_name=dmis_cur_applid
      AND cnvtreal(di.info_char)=dmis_plan_id
      AND di.info_number != dmis_status
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual > 0)
     SET dmis_status_changed_ind = 1
    ELSE
     SET dm_err->eproc = concat("Install status for ",build(dmis_plan_id)," already set to ",build(
       dmis_status))
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
     ENDIF
     RETURN(1)
    ENDIF
    IF (dmis_status_changed_ind=1)
     SET dm_err->eproc = concat("Update install status for plan_id ",build(dmis_plan_id)," to ",build
      (dmis_status))
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
     ENDIF
     UPDATE  FROM dm_info di
      SET di.info_number = dmis_status, di.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3
         ))
      WHERE di.info_domain="DM2_FLEX_SCHED_USAGE"
       AND di.info_name=dmis_cur_applid
       AND di.info_char=trim(cnvtstring(dmis_plan_id))
       AND di.info_number != dmis_status
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (dpl_ui_chk(dpl_package_install)=0)
      RETURN(0)
     ENDIF
     IF ((dm2_process_event_rs->ui_allowed_ind=1))
      SET dm_err->eproc = "Query for the process event id"
      IF ((dm_err->debug_flag > 0))
       CALL disp_msg("",dm_err->logfile,0)
      ENDIF
      SELECT INTO "nl:"
       FROM dm_process dp,
        dm_process_event dpe,
        dm_process_event_dtl dped
       WHERE dp.dm_process_id=dpe.dm_process_id
        AND dpe.dm_process_event_id=dped.dm_process_event_id
        AND dp.process_name=dpl_package_install
        AND dp.action_type=dpl_execution
        AND dped.detail_type="AUDSID"
        AND dped.detail_text=dmis_appl_id
        AND dpe.install_plan_id=dmis_plan_id
       DETAIL
        dmis_event_id = dpe.dm_process_event_id
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      CASE (dmis_status)
       OF 2:
        SET dmis_msg = "PAUSED"
       OF 0:
        SET dmis_msg = "STOPPED"
       OF 1:
        SET dmis_msg = "EXECUTING"
      ENDCASE
      SET dm_err->eproc = "Update the process event for the event status change"
      IF ((dm_err->debug_flag > 0))
       CALL disp_msg("",dm_err->logfile,0)
      ENDIF
      UPDATE  FROM dm_process_event dpe1
       SET dpe1.event_status = dmis_msg
       WHERE dpe1.dm_process_event_id=dmis_event_id
       WITH nocounter
      ;end update
      IF (check_error(dm_err->eproc)=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      IF (dmis_status=2)
       SET dm_err->eproc = "Update status change reason"
       IF ((dm_err->debug_flag > 0))
        CALL disp_msg("",dm_err->logfile,0)
       ENDIF
       UPDATE  FROM dm_process_event_dtl dtl
        SET dtl.detail_text = dmis_reason
        WHERE dtl.dm_process_event_id=dmis_event_id
         AND dtl.detail_type="LAST_STATUS_MESSAGE"
        WITH nocounter
       ;end update
       IF (check_error(dm_err->eproc)=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       IF (curqual=0)
        CALL dm2_process_log_add_detail_text("LAST_STATUS_MESSAGE",dmis_reason)
        SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_date =
        cnvtdatetime(curdate,curtime3)
        IF (dm2_process_log_dtl_row(dmis_event_id,0)=0)
         ROLLBACK
         RETURN(0)
        ENDIF
       ENDIF
      ENDIF
      COMMIT
      SET dm_err->eproc = "Log installation status change event"
      IF ((dm_err->debug_flag > 0))
       CALL disp_msg("",dm_err->logfile,0)
      ENDIF
      SET dm2_process_event_rs->begin_dt_tm = cnvtdatetime(curdate,curtime3)
      SET dm2_process_event_rs->end_dt_tm = cnvtdatetime(curdate,curtime3)
      SET dm2_process_event_rs->install_plan_id = dmis_plan_id
      SET dm2_process_event_rs->status = dpl_complete
      CALL dm2_process_log_add_detail_text(dpl_audit_name,"MODIFY_INSTALL_STATUS")
      CALL dm2_process_log_add_detail_text(dpl_audit_type,dpl_progress)
      CALL dm2_process_log_add_detail_text("NEW_STATUS",cnvtstring(dmis_status))
      CALL dm2_process_log_add_detail_text("OLD_STATUS",cnvtstring(dmis_cur_status))
      CALL dm2_process_log_add_detail_text("MENU_NAME",dmis_requester)
      CALL dm2_process_log_add_detail_text("STATUS_CHANGE_REASON",dmis_reason)
      IF (dm2_process_log_row(dpl_package_install,dpl_auditlog,dpl_no_prev_id,0)=0)
       RETURN(0)
      ENDIF
      CALL dpl_upd_dped_last_status(dmis_event_id,dmis_reason,0.0,cnvtdatetime(curdate,curtime3))
     ENDIF
    ENDIF
    IF (dmis_status IN (0, 2))
     IF (drr_stop_runners("ALL",0)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_stop_runners(dsr_mode,dsr_number)
   IF ( NOT (cnvtupper(dsr_mode) IN ("ALL", "LONG_RUNNING", "NUM_RUNNERS")))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid input mode for subroutine drr_stop_runners"
    SET dm_err->eproc = "Validating input mode."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (dsr_mode IN ("LONG_RUNNING", "NUM_RUNNERS")
    AND dsr_number=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid input number for subroutine drr_stop_runners"
    SET dm_err->eproc = "Validating input number."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   DECLARE dsr_applx = i4 WITH protect, noconstant(0)
   DECLARE dsr_interval = vc WITH protect, noconstant(" ")
   FREE RECORD dsr_appl_rs
   RECORD dsr_appl_rs(
     1 cnt = i4
     1 qual[*]
       2 appl_id = vc
   )
   IF (cnvtupper(dsr_mode)="ALL")
    SET dm_err->eproc = "Stopping (inactivating) all runners..."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    UPDATE  FROM dm_info di
     SET di.info_number = 0, di.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3))
     WHERE di.info_domain IN ("DM2_BACKGROUND_RUNNER", "DM2_INSTALL_RUNNER", "DM2_SCHEMA_RUNNER",
     "DM2_README_RUNNER")
      AND di.info_number=1
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ELSEIF (cnvtupper(dsr_mode)="LONG_RUNNING")
    SET dsr_interval = build(dsr_number,"H")
    SET dm_err->eproc = concat(
     "Getting a distinct list of appl ids attached to runners that have been running longer than ",
     trim(cnvtstring(dsr_number),3)," hour(s)...")
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SELECT DISTINCT INTO "nl:"
     di.info_name
     FROM dm_info di
     WHERE di.info_domain IN ("DM2_BACKGROUND_RUNNER", "DM2_INSTALL_RUNNER", "DM2_SCHEMA_RUNNER",
     "DM2_README_RUNNER")
      AND di.info_number=1
      AND di.info_date <= cnvtdatetimeutc(cnvtdatetime(cnvtlookbehind(dsr_interval)))
     HEAD REPORT
      dsr_applx = 0
     DETAIL
      dsr_applx = (dsr_applx+ 1)
      IF (mod(dsr_applx,10)=1)
       stat = alterlist(dsr_appl_rs->qual,(dsr_applx+ 9))
      ENDIF
      dsr_appl_rs->qual[dsr_applx].appl_id = trim(di.info_name,3)
     FOOT REPORT
      dsr_appl_rs->cnt = dsr_applx, stat = alterlist(dsr_appl_rs->qual,dsr_appl_rs->cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dsr_appl_rs->cnt > 0))
     SET dm_err->eproc = concat(
      "Stopping (inactivating) all runners that have been running longer than ",trim(cnvtstring(
        dsr_number),3)," hour(s)...")
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     UPDATE  FROM dm_info di,
       (dummyt d  WITH seq = value(dsr_appl_rs->cnt))
      SET di.info_number = 0, di.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3))
      PLAN (d)
       JOIN (di
       WHERE di.info_domain IN ("DM2_BACKGROUND_RUNNER", "DM2_INSTALL_RUNNER", "DM2_SCHEMA_RUNNER",
       "DM2_README_RUNNER")
        AND (di.info_name=dsr_appl_rs->qual[d.seq].appl_id))
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
    ENDIF
   ELSE
    SET dm_err->eproc = concat("Getting the ",trim(cnvtstring(dsr_number))," oldest runner(s).")
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SELECT DISTINCT INTO "nl:"
     di.info_name
     FROM dm_info di
     WHERE di.info_domain IN ("DM2_BACKGROUND_RUNNER", "DM2_INSTALL_RUNNER", "DM2_SCHEMA_RUNNER",
     "DM2_README_RUNNER")
      AND di.info_number=1
     ORDER BY di.info_date
     HEAD REPORT
      dsr_applx = 0
     DETAIL
      IF (dsr_applx < dsr_number)
       dsr_applx = (dsr_applx+ 1)
       IF (mod(dsr_applx,10)=1)
        stat = alterlist(dsr_appl_rs->qual,(dsr_applx+ 9))
       ENDIF
       dsr_appl_rs->qual[dsr_applx].appl_id = trim(di.info_name,3)
      ENDIF
     FOOT REPORT
      dsr_appl_rs->cnt = dsr_applx, stat = alterlist(dsr_appl_rs->qual,dsr_appl_rs->cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 2))
     CALL echorecord(dsr_appl_rs)
    ENDIF
    IF ((dsr_appl_rs->cnt > 0))
     SET dm_err->eproc = concat("Stopping the ",trim(cnvtstring(dsr_number))," oldest runner(s).")
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     UPDATE  FROM dm_info di,
       (dummyt d  WITH seq = value(dsr_appl_rs->cnt))
      SET di.info_number = 0, di.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3))
      PLAN (d)
       JOIN (di
       WHERE di.info_domain IN ("DM2_BACKGROUND_RUNNER", "DM2_INSTALL_RUNNER", "DM2_SCHEMA_RUNNER",
       "DM2_README_RUNNER")
        AND (di.info_name=dsr_appl_rs->qual[d.seq].appl_id))
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_start_runners(dstr_num_runners,dstr_user,dstr_pword,dstr_cnnct_str,dstr_queue_name)
   DECLARE dstr_connect_string = vc WITH protect, noconstant(" ")
   DECLARE dstr_file_name = vc WITH protect, noconstant(" ")
   DECLARE dstr_logfile_name = vc WITH protect, noconstant(" ")
   DECLARE dstr_exec_cmd = vc WITH protect, noconstant(" ")
   DECLARE dstr_chmod_cmd = vc WITH protect, noconstant(" ")
   DECLARE dstr_loop_cnt = i2 WITH protect, noconstant(0)
   DECLARE dstr_debug_flag = vc WITH protect, noconstant("0")
   DECLARE dstr_stat = i4 WITH protect, noconstant(0)
   IF (dstr_num_runners <= 0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid input number for subroutine drr_start_runners"
    SET dm_err->eproc = "Validating input number - number of runners to start."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (((dstr_user=" ") OR (dstr_pword=" ")) )
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid database connection information for subroutine drr_start_runners"
    SET dm_err->eproc = "Validating connection information passed into subroutine."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (dstr_cnnct_str > " "
    AND dstr_cnnct_str != "NONE")
    SET dstr_connect_string = build("'",dstr_user,"/",dstr_pword,"@",
     dstr_cnnct_str,"'")
   ELSE
    SET dstr_connect_string = build("'",dstr_user,"/",dstr_pword,"'")
   ENDIF
   IF ((dir_ui_misc->auto_install_ind=1))
    IF (dir_get_debug_trace_data(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET dstr_debug_flag = cnvtstring(dm_err->debug_flag)
   FOR (dstr_loop_cnt = 1 TO dstr_num_runners)
     IF (get_unique_file("dm2_bckgrnd_runner_",".log")=0)
      RETURN(0)
     ENDIF
     SET dstr_logfile_name = dm_err->unique_fname
     SET dstr_file_name = replace(dstr_logfile_name,".log",".ksh",0)
     SET dm_err->eproc = "Creating job to execute background runner."
     SELECT INTO trim(dstr_file_name)
      DETAIL
       col 0, "#!/usr/bin/ksh", row + 1,
       col 0, "# Executing Background Runner...", row + 1,
       col 0, "#", row + 1,
       col 0, ". $cer_mgr/",
       CALL print(trim(cnvtlower(logical("environment")))),
       "_environment.ksh", row + 1, col 0,
       "ccl <<!", row + 1, col 0,
       "SET TRACE NORANGECACHE 0 go", row + 1, col 0,
       "free define oraclesystem go", row + 1, col 0,
       "define oraclesystem ", dstr_connect_string, " go"
       IF ((dir_ui_misc->auto_install_ind=1))
        IF ((dir_ui_misc->debug_level > 0))
         row + 1, col 0, "set dm2_debug_flag = ",
         dir_ui_misc->debug_level, " go"
        ENDIF
        IF ((dir_ui_misc->trace_flag=1))
         row + 1, col 0, "set trace rdbdebug go",
         row + 1, col 0, "set trace rdbbind go",
         row + 1, col 0, "set trace rdbbind2 go"
        ENDIF
       ELSE
        row + 1, col 0, "set dm2_debug_flag = ",
        dstr_debug_flag, " go"
       ENDIF
       row + 1, col 0, "dm2_background_runner '",
       dstr_user, "', '", dstr_pword,
       "', '", dstr_cnnct_str, "', 'PACKAGE' go",
       row + 1, col 0, "exit",
       row + 1, col 0, "!",
       row + 1, col 0, "sleep 30"
      WITH nocounter, maxrow = 1, format = variable,
       formfeed = none
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET dstr_chmod_cmd = concat("chmod 777 $CCLUSERDIR/",dstr_file_name)
     IF ((dm_err->debug_flag > 0))
      SET dm_err->eproc = concat("drr_start_runners changing permissions for ",dstr_file_name,".")
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     IF (dm2_push_dcl(dstr_chmod_cmd)=0)
      RETURN(0)
     ENDIF
     SET dstr_exec_cmd = concat("nohup ","$CCLUSERDIR/",dstr_file_name," > $CCLUSERDIR/",
      dstr_logfile_name,
      " 2>&1 &")
     SET dm_err->eproc = concat("Executing ",trim(dstr_file_name)," - results will be logged to ",
      trim(dstr_logfile_name),".")
     CALL disp_msg(" ",dm_err->logfile,0)
     CALL dcl(dstr_exec_cmd,size(dstr_exec_cmd),dstr_stat)
     IF (dstr_stat=0)
      IF (parse_errfile(dstr_logfile_name)=0)
       RETURN(0)
      ENDIF
      SET dm_err->disp_msg_emsg = dm_err->errtext
      SET dm_err->emsg = dm_err->disp_msg_emsg
      SET dm_err->eproc = concat("dm2_push_dcl executing: ",dstr_exec_cmd)
      SET dm_err->err_ind = 1
      CALL disp_msg("dm_err->disp_msg_emsg",dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET dstr_exec_cmd = concat("ps -ef | grep ",dstr_file_name," | grep -v grep")
     SET dm_err->disp_dcl_err_ind = 0
     IF (dm2_push_dcl(dstr_exec_cmd)=0)
      IF ((dm_err->err_ind=1))
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
     IF (parse_errfile(dm_err->errfile)=0)
      RETURN(0)
     ENDIF
     IF (findstring(dstr_file_name,dm_err->errtext)=0)
      SET dm_err->disp_msg_emsg = "Unable to locate process for this job."
      SET dm_err->emsg = dm_err->disp_msg_emsg
      SET dm_err->eproc = concat("Validating ",trim(dstr_file_name)," was successfully executed.")
      SET dm_err->err_ind = 1
      CALL disp_msg("dm_err->disp_msg_emsg",dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF ((dm_err->debug_flag < 3))
      IF (remove(dstr_file_name)=0)
       SET dm_err->err_ind = 1
       SET dm_err->emsg = concat("Could not remove ",dstr_file_name," from ccluserdir.")
       SET dm_err->eproc = "Removing background ksh/com file from ccluserdir."
       CALL disp_msg((dm_err - emsg),dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_get_flexible_schedule(null)
   DECLARE dgfs_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgfs_idx = i4 WITH protect, noconstant(0)
   DECLARE dgfs_time_period = vc WITH protect, noconstant(" ")
   DECLARE dgfs_process = vc WITH protect, noconstant(" ")
   SET stat = alterlist(drr_flex_sched->readme_schedule,0)
   SET stat = alterlist(drr_flex_sched->schema_schedule,0)
   SET drr_flex_sched->readme_time_periods = 0
   SET drr_flex_sched->schema_time_periods = 0
   SET dm_err->eproc = "Getting installation schedule data..."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   INSERT  FROM dm_info di
    (di.info_domain, di.info_name, di.info_date,
    di.info_char, di.info_number)(SELECT
     "DM2_FLEXIBLE_SCHEDULE_README", do.info_name, do.info_date,
     do.info_char, do.info_number
     FROM dm_info do
     WHERE do.info_domain="DM2_FLEXIBLE_SCHEDULE"
      AND  NOT (do.info_name IN ("STATUS", "RUNNER TIME LIMIT")))
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   INSERT  FROM dm_info di
    (di.info_domain, di.info_name, di.info_date,
    di.info_char, di.info_number)(SELECT
     "DM2_FLEXIBLE_SCHEDULE_SCHEMA", do.info_name, do.info_date,
     do.info_char, do.info_number
     FROM dm_info do
     WHERE do.info_domain="DM2_FLEXIBLE_SCHEDULE"
      AND  NOT (do.info_name IN ("STATUS", "RUNNER TIME LIMIT")))
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   DELETE  FROM dm_info di
    WHERE di.info_domain="DM2_FLEXIBLE_SCHEDULE"
     AND  NOT (di.info_name IN ("STATUS", "RUNNER TIME LIMIT"))
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   COMMIT
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_FLEXIBLE_SCHEDULE*"
    ORDER BY di.info_domain, di.updt_cnt
    HEAD di.info_domain
     dgfs_cnt = 0, dgfs_process = substring(23,textlen(di.info_domain),di.info_domain)
    DETAIL
     IF (di.info_name="STATUS")
      drr_flex_sched->sched_set_up = 1, drr_flex_sched->status = evaluate(cnvtupper(di.info_char),
       "ON",1,0)
     ENDIF
     IF (di.info_name="RUNNER TIME LIMIT")
      drr_flex_sched->runner_time_limit = di.info_number
     ENDIF
     IF (di.info_name="TIME PERIOD*")
      dgfs_time_period = trim(cnvtupper(substring(1,(findstring("-",di.info_name) - 1),di.info_name))
       )
      IF (dgfs_process="README")
       dgfs_idx = 0
       IF (dgfs_cnt > 0)
        dgfs_idx = locateval(dgfs_idx,1,dgfs_cnt,dgfs_time_period,drr_flex_sched->readme_schedule[
         dgfs_idx].time_period)
       ENDIF
       IF (dgfs_idx=0)
        dgfs_cnt = (dgfs_cnt+ 1)
        IF (mod(dgfs_cnt,5)=1)
         stat = alterlist(drr_flex_sched->readme_schedule,(dgfs_cnt+ 4))
        ENDIF
        dgfs_idx = dgfs_cnt
       ENDIF
       drr_flex_sched->readme_schedule[dgfs_idx].time_period = dgfs_time_period
       IF (findstring("START",cnvtupper(di.info_name)) > 0)
        drr_flex_sched->readme_schedule[dgfs_idx].start_time = di.info_number
       ELSEIF (findstring("END",cnvtupper(di.info_name)) > 0)
        drr_flex_sched->readme_schedule[dgfs_idx].end_time = di.info_number
       ELSE
        drr_flex_sched->readme_schedule[dgfs_idx].num_of_runners = di.info_number
       ENDIF
      ELSEIF (dgfs_process="SCHEMA")
       dgfs_idx = 0
       IF (dgfs_cnt > 0)
        dgfs_idx = locateval(dgfs_idx,1,dgfs_cnt,dgfs_time_period,drr_flex_sched->schema_schedule[
         dgfs_idx].time_period)
       ENDIF
       IF (dgfs_idx=0)
        dgfs_cnt = (dgfs_cnt+ 1)
        IF (mod(dgfs_cnt,5)=1)
         stat = alterlist(drr_flex_sched->schema_schedule,(dgfs_cnt+ 4))
        ENDIF
        dgfs_idx = dgfs_cnt
       ENDIF
       drr_flex_sched->schema_schedule[dgfs_idx].time_period = dgfs_time_period
       IF (findstring("START",cnvtupper(di.info_name)) > 0)
        drr_flex_sched->schema_schedule[dgfs_idx].start_time = di.info_number
       ELSEIF (findstring("END",cnvtupper(di.info_name)) > 0)
        drr_flex_sched->schema_schedule[dgfs_idx].end_time = di.info_number
       ELSE
        drr_flex_sched->schema_schedule[dgfs_idx].num_of_runners = di.info_number
       ENDIF
      ENDIF
     ENDIF
    FOOT  di.info_domain
     IF (dgfs_process="README")
      drr_flex_sched->readme_time_periods = dgfs_cnt, stat = alterlist(drr_flex_sched->
       readme_schedule,drr_flex_sched->readme_time_periods)
     ELSEIF (dgfs_process="SCHEMA")
      drr_flex_sched->schema_time_periods = dgfs_cnt, stat = alterlist(drr_flex_sched->
       schema_schedule,drr_flex_sched->schema_time_periods)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET drr_flex_sched->sched_set_up = 0
    SET drr_flex_sched->status = 0
   ENDIF
   IF ((drr_flex_sched->runner_time_limit=- (1)))
    SET drr_flex_sched->runner_time_limit = 10
   ENDIF
   IF ((dm_err->debug_flag > 3))
    CALL echorecord(drr_flex_sched)
   ENDIF
   IF ((dm_err->debug_flag > 622))
    SET message = nowindow
    CALL disp_msg(" ",dm_err->logfile,0)
    CALL echorecord(drr_flex_sched)
    SET message = window
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_use_flexible_schedule(dufs_prompt_ind,dufs_pkg_number,dufs_install_mode,dufs_sel_ret)
   DECLARE dufs_line_cnt = i4 WITH protect, noconstant(0)
   DECLARE dufs_choice = vc WITH protect, noconstant(" ")
   DECLARE dufs_idx = i2 WITH protect, noconstant(0)
   DECLARE dufs_hold_time = vc WITH protect, noconstant("")
   SET dufs_sel_ret = ""
   IF ((( NOT (dufs_prompt_ind IN (0, 1))) OR (((dufs_install_mode=" ") OR (dufs_pkg_number=" ")) ))
   )
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid input for subroutine drr_use_flexible_schedule"
    SET dm_err->eproc = "Validating information passed into subroutine."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((drr_flex_sched->pkg_number="DM2NOTSET"))
    SET drr_flex_sched->pkg_number = dufs_pkg_number
   ENDIF
   IF ((drr_flex_sched->pkg_install_mode="DM2NOTSET"))
    SET drr_flex_sched->pkg_install_mode = dufs_install_mode
   ENDIF
   IF (currdb != "ORACLE")
    SET dm_err->eproc =
    "Package will not attempt to use installation schedule because RDBMS is not Oracle"
    CALL disp_msg(" ",dm_err->logfile,0)
    SET drr_flex_sched->pkg_using_schedule = 0
    RETURN(1)
   ENDIF
   IF ( NOT ((drr_flex_sched->pkg_install_mode IN ("BATCHUP", "BATCHPRECYCLE", "BATCHDOWN",
   "BATCHPOST", "BATCHEXPRESS"))))
    SET dm_err->eproc = "Package will not attempt to use installation schedule due to install mode."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET drr_flex_sched->pkg_using_schedule = 0
    RETURN(1)
   ENDIF
   IF (drr_cleanup_dm_info_sched_usage(null)=0)
    RETURN(0)
   ENDIF
   IF (drr_get_flexible_schedule(null)=0)
    RETURN(0)
   ENDIF
   IF ((drr_flex_sched->status=0))
    SET dm_err->eproc =
    "Package will not use installation schedule because it's not set up or currently turned on."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET drr_flex_sched->pkg_using_schedule = 0
    RETURN(1)
   ENDIF
   IF (dm2_rr_toolset_usage(null)=0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm2_rr_misc->dm2_toolset_usage="N"))
    SET dm_err->eproc =
    "Package will not use installation schedule because old dm tools being used for readme processing"
    CALL disp_msg(" ",dm_err->logfile,0)
    SET drr_flex_sched->pkg_using_schedule = 0
    RETURN(1)
   ENDIF
   IF (dufs_prompt_ind=1)
    WHILE ( NOT (dufs_choice IN ("C", "Q")))
      SET message = window
      SET width = 132
      CALL clear(1,1)
      CALL video(n)
      CALL text(2,1,"Installation Scheduler: ",w)
      CALL text(4,1,concat("Please confirm Installation Scheduler configuration:"))
      CALL text(6,1,concat("Status:",evaluate(drr_flex_sched->status,0,"OFF","ON")))
      CALL text(6,12,"README(R) SCHEMA(S)")
      CALL text(9,1,"(R)")
      SET dufs_line_cnt = 8
      CALL text(dufs_line_cnt,5,"Time Slot")
      CALL text(dufs_line_cnt,18,"Start Time")
      CALL text(dufs_line_cnt,34,"End Time")
      CALL text(dufs_line_cnt,49,"Num Runners")
      FOR (dufs_idx = 1 TO drr_flex_sched->readme_time_periods)
        SET dufs_line_cnt = (dufs_line_cnt+ 1)
        SET drr_flex_sched->readme_schedule[dufs_idx].time_period = cnvtstring(dufs_idx)
        SET drr_flex_sched->readme_schedule[dufs_idx].start_time_hhmm = drr_flex_sched->
        readme_schedule[dufs_idx].start_time
        SET dufs_hold_time = cnvtupper(format(drr_flex_sched->readme_schedule[dufs_idx].
          start_time_hhmm,"HH;;s"))
        SET drr_flex_sched->readme_schedule[dufs_idx].start_time_hh = cnvtint(trim(replace(replace(
            dufs_hold_time,"AM","",0),"PM","",0),3))
        IF ((drr_flex_sched->readme_schedule[dufs_idx].start_time_hh=0))
         SET drr_flex_sched->readme_schedule[dufs_idx].start_time_hh = 12
        ENDIF
        IF (findstring("AM",dufs_hold_time) > 0)
         SET drr_flex_sched->readme_schedule[dufs_idx].start_time_am_pm = "AM"
        ELSE
         SET drr_flex_sched->readme_schedule[dufs_idx].start_time_am_pm = "PM"
        ENDIF
        SET drr_flex_sched->readme_schedule[dufs_idx].end_time_hhmm = drr_flex_sched->
        readme_schedule[dufs_idx].end_time
        SET dufs_hold_time = cnvtupper(format(drr_flex_sched->readme_schedule[dufs_idx].end_time_hhmm,
          "HH;;s"))
        SET drr_flex_sched->readme_schedule[dufs_idx].end_time_hh = cnvtint(trim(replace(replace(
            dufs_hold_time,"AM","",0),"PM","",0),3))
        IF ((drr_flex_sched->readme_schedule[dufs_idx].end_time_hh=0))
         SET drr_flex_sched->readme_schedule[dufs_idx].end_time_hh = 12
        ENDIF
        IF (findstring("AM",dufs_hold_time) > 0)
         SET drr_flex_sched->readme_schedule[dufs_idx].end_time_am_pm = "AM"
        ELSE
         SET drr_flex_sched->readme_schedule[dufs_idx].end_time_am_pm = "PM"
        ENDIF
        SET drr_flex_sched->readme_schedule[dufs_idx].num_of_runners = drr_flex_sched->
        readme_schedule[dufs_idx].num_of_runners
        CALL text(dufs_line_cnt,5,cnvtstring(dufs_idx))
        CALL text(dufs_line_cnt,19,cnvtstring(drr_flex_sched->readme_schedule[dufs_idx].start_time_hh
          ))
        CALL text(dufs_line_cnt,22,drr_flex_sched->readme_schedule[dufs_idx].start_time_am_pm)
        CALL text(dufs_line_cnt,34,cnvtstring(drr_flex_sched->readme_schedule[dufs_idx].end_time_hh))
        CALL text(dufs_line_cnt,37,drr_flex_sched->readme_schedule[dufs_idx].end_time_am_pm)
        CALL text(dufs_line_cnt,49,cnvtstring(drr_flex_sched->readme_schedule[dufs_idx].
          num_of_runners))
      ENDFOR
      SET dufs_line_cnt = (dufs_line_cnt+ 1)
      CALL text(dufs_line_cnt,1,"(S)")
      FOR (dufs_idx = 1 TO drr_flex_sched->schema_time_periods)
        IF (dufs_idx != 1)
         SET dufs_line_cnt = (dufs_line_cnt+ 1)
        ENDIF
        SET drr_flex_sched->schema_schedule[dufs_idx].time_period = cnvtstring(dufs_idx)
        SET drr_flex_sched->schema_schedule[dufs_idx].start_time_hhmm = drr_flex_sched->
        schema_schedule[dufs_idx].start_time
        SET dufs_hold_time = cnvtupper(format(drr_flex_sched->schema_schedule[dufs_idx].
          start_time_hhmm,"HH;;s"))
        SET drr_flex_sched->schema_schedule[dufs_idx].start_time_hh = cnvtint(trim(replace(replace(
            dufs_hold_time,"AM","",0),"PM","",0),3))
        IF ((drr_flex_sched->schema_schedule[dufs_idx].start_time_hh=0))
         SET drr_flex_sched->schema_schedule[dufs_idx].start_time_hh = 12
        ENDIF
        IF (findstring("AM",dufs_hold_time) > 0)
         SET drr_flex_sched->schema_schedule[dufs_idx].start_time_am_pm = "AM"
        ELSE
         SET drr_flex_sched->schema_schedule[dufs_idx].start_time_am_pm = "PM"
        ENDIF
        SET drr_flex_sched->schema_schedule[dufs_idx].end_time_hhmm = drr_flex_sched->
        schema_schedule[dufs_idx].end_time
        SET dufs_hold_time = cnvtupper(format(drr_flex_sched->schema_schedule[dufs_idx].end_time_hhmm,
          "HH;;s"))
        SET drr_flex_sched->schema_schedule[dufs_idx].end_time_hh = cnvtint(trim(replace(replace(
            dufs_hold_time,"AM","",0),"PM","",0),3))
        IF ((drr_flex_sched->schema_schedule[dufs_idx].end_time_hh=0))
         SET drr_flex_sched->schema_schedule[dufs_idx].end_time_hh = 12
        ENDIF
        IF (findstring("AM",dufs_hold_time) > 0)
         SET drr_flex_sched->schema_schedule[dufs_idx].end_time_am_pm = "AM"
        ELSE
         SET drr_flex_sched->schema_schedule[dufs_idx].end_time_am_pm = "PM"
        ENDIF
        SET drr_flex_sched->schema_schedule[dufs_idx].num_of_runners = drr_flex_sched->
        schema_schedule[dufs_idx].num_of_runners
        CALL text(dufs_line_cnt,5,cnvtstring(dufs_idx))
        CALL text(dufs_line_cnt,19,cnvtstring(drr_flex_sched->schema_schedule[dufs_idx].start_time_hh
          ))
        CALL text(dufs_line_cnt,22,drr_flex_sched->schema_schedule[dufs_idx].start_time_am_pm)
        CALL text(dufs_line_cnt,34,cnvtstring(drr_flex_sched->schema_schedule[dufs_idx].end_time_hh))
        CALL text(dufs_line_cnt,37,drr_flex_sched->schema_schedule[dufs_idx].end_time_am_pm)
        CALL text(dufs_line_cnt,49,cnvtstring(drr_flex_sched->schema_schedule[dufs_idx].
          num_of_runners))
      ENDFOR
      SET dufs_line_cnt = (dufs_line_cnt+ 2)
      CALL text(dufs_line_cnt,1,concat("(C)ontinue with above schedule, (M)odify, (Q)uit :"))
      CALL accept(dufs_line_cnt,53,"A;cu"," "
       WHERE curaccept IN ("Q", "C", "M"))
      SET dufs_choice = curaccept
      SET dufs_sel_ret = dufs_choice
      SET message = nowindow
      IF (dufs_choice="M")
       EXECUTE dm2_flexible_schedule_menu
       IF ((dm_err->err_ind > 0))
        RETURN(0)
       ENDIF
       IF (drr_get_flexible_schedule(null)=0)
        RETURN(0)
       ENDIF
      ENDIF
    ENDWHILE
   ENDIF
   IF ((drr_flex_sched->status=1))
    SET dm_err->eproc =
    "Determining if DM_INFO row to denote the package is using the installation schedule exists..."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    UPDATE  FROM dm_info di
     SET di.info_date = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)), di.info_char = currdbhandle,
      di.info_number = 1,
      di.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)), di.updt_applctx = 0, di
      .updt_cnt = 0,
      di.updt_id = 0, di.updt_task = reqinfo->updt_task
     WHERE di.info_domain="DM2_FLEX_SCHED_USAGE"
      AND (di.info_name=drr_flex_sched->pkg_number)
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (curqual=0)
     SET dm_err->eproc =
     "Inserting DM_INFO row to denote the package is using the installation schedule..."
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     INSERT  FROM dm_info di
      SET di.info_domain = "DM2_FLEX_SCHED_USAGE", di.info_name = drr_flex_sched->pkg_number, di
       .info_date = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)),
       di.info_char = currdbhandle, di.info_number = 1, di.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(
         curdate,curtime3)),
       di.updt_applctx = 0, di.updt_cnt = 0, di.updt_id = 0,
       di.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
    ELSE
     COMMIT
    ENDIF
    SET drr_flex_sched->pkg_using_schedule = 1
   ELSE
    SET drr_flex_sched->pkg_using_schedule = 0
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_maintain_runners(dmr_user,dmr_pword,dmr_cnnct_str,dmr_queue_name,dm_process)
   DECLARE dmr_curtime_hhmm = f8 WITH protect, noconstant(0.0)
   DECLARE dmr_cnt = i4 WITH protect, noconstant(0)
   DECLARE dmr_env_name = vc WITH protect, noconstant(" ")
   DECLARE dmr_time_fnd_ind = i2 WITH protect, noconstant(0)
   DECLARE dmr_process_status = i2 WITH protect, noconstant(0)
   SET drr_flex_sched->num_sched_runners = 0
   SET drr_flex_sched->num_active_runners = 0
   SET drr_flex_sched->num_runners_to_stop = 0
   SET drr_flex_sched->num_runners_to_start = 0
   SET drr_flex_sched->num_stopping_runners = 0
   SET drr_flex_sched->tot_num_runners = 0
   IF (((dmr_user=" ") OR (dmr_pword=" ")) )
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid database connection information for subroutine drr_maintain_runners"
    SET dm_err->eproc = "Validating connection information passed into subroutine."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((drr_flex_sched->pkg_using_schedule=1)
    AND (dm2_process_event_rs->ui_allowed_ind=1))
    IF (drr_get_process_status("DM2_INSTALL_MONITOR",abs(cnvtreal(drr_flex_sched->pkg_number)),
     dmr_process_status)=0)
     RETURN(0)
    ENDIF
    IF (dmr_process_status=0)
     IF (drr_submit_background_process(dm2_install_schema->u_name,dm2_install_schema->p_word,
      dm2_install_schema->connect_str,dmr_queue_name,dpl_install_monitor,
      cnvtreal(drr_flex_sched->pkg_number),drr_flex_sched->pkg_install_mode)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF (drr_cleanup_dm_info_runners(null)=0)
    RETURN(0)
   ENDIF
   IF (drr_get_flexible_schedule(null)=0)
    RETURN(0)
   ENDIF
   IF (drr_stop_runners("LONG_RUNNING",drr_flex_sched->runner_time_limit)=0)
    RETURN(0)
   ENDIF
   SET dmr_curtime_hhmm = curtime
   IF ((dm_err->debug_flag > 2))
    CALL echo(build("CUrrent time in HHMM = ",dmr_curtime_hhmm))
   ENDIF
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc =
    "Determining how many runners should be running based on installation schedule..."
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (dm_process="README")
    SET time_periods = drr_flex_sched->readme_time_periods
   ELSEIF (dm_process="SCHEMA")
    SET time_periods = drr_flex_sched->schema_time_periods
   ENDIF
   FOR (dmr_cnt = 1 TO time_periods)
    IF (dm_process="README")
     SET curalias schedule drr_flex_sched->readme_schedule[dmr_cnt]
    ELSEIF (dm_process="SCHEMA")
     SET curalias schedule drr_flex_sched->schema_schedule[dmr_cnt]
    ENDIF
    IF ((schedule->start_time=schedule->end_time))
     SET drr_flex_sched->num_sched_runners = schedule->num_of_runners
     SET dmr_cnt = time_periods
     SET dmr_time_fnd_ind = 1
    ELSEIF ((schedule->start_time < schedule->end_time))
     IF ((dmr_curtime_hhmm >= schedule->start_time)
      AND (dmr_curtime_hhmm < schedule->end_time))
      SET drr_flex_sched->num_sched_runners = schedule->num_of_runners
      SET dmr_cnt = time_periods
      SET dmr_time_fnd_ind = 1
     ENDIF
    ELSE
     IF ((((dmr_curtime_hhmm >= schedule->start_time)
      AND dmr_curtime_hhmm < 2400) OR (dmr_curtime_hhmm >= 0000
      AND (dmr_curtime_hhmm < schedule->end_time))) )
      SET drr_flex_sched->num_sched_runners = schedule->num_of_runners
      SET dmr_cnt = time_periods
      SET dmr_time_fnd_ind = 1
     ENDIF
    ENDIF
   ENDFOR
   IF (dmr_time_fnd_ind=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Number of runners could not be retrieved for current time."
    SET dm_err->eproc = "Retrieving number of runners to execute from installation schedule."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ELSE
    IF ((dm_err->debug_flag > 0))
     SET dm_err->eproc = concat(trim(cnvtstring(drr_flex_sched->num_sched_runners)),
      " runner(s) should be running.")
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Determining how many runners are actively running..."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_BACKGROUND_RUNNER"
    DETAIL
     IF (di.info_number=1)
      drr_flex_sched->num_active_runners = (drr_flex_sched->num_active_runners+ 1)
     ELSE
      drr_flex_sched->num_stopping_runners = (drr_flex_sched->num_stopping_runners+ 1)
     ENDIF
     drr_flex_sched->tot_num_runners = (drr_flex_sched->tot_num_runners+ 1)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc = concat(trim(cnvtstring(drr_flex_sched->num_active_runners)),
     " runner(s) currently running.")
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF ((drr_flex_sched->tot_num_runners=drr_flex_sched->num_sched_runners))
    IF ((dm_err->debug_flag > 0))
     SET dm_err->eproc =
     "Currently running the specified number of runners from installation schedule..."
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    RETURN(1)
   ENDIF
   IF ((drr_flex_sched->tot_num_runners > drr_flex_sched->num_sched_runners))
    IF ((drr_flex_sched->num_active_runners=0))
     IF ((dm_err->debug_flag > 0))
      SET dm_err->eproc = concat(
       "No active runners to stop at this time: All existing runners have been marked to stop.")
      CALL disp_msg(" ",dm_err->logfile,0)
      RETURN(1)
     ENDIF
    ELSEIF ((drr_flex_sched->num_active_runners < drr_flex_sched->tot_num_runners))
     IF ((drr_flex_sched->num_active_runners <= drr_flex_sched->num_sched_runners))
      SET drr_flex_sched->num_runners_to_stop = drr_flex_sched->num_active_runners
      IF ((dm_err->debug_flag > 0))
       SET dm_err->eproc = concat("Need to stop ",trim(cnvtstring(drr_flex_sched->num_runners_to_stop
          ))," active runner(s)...")
       CALL disp_msg(" ",dm_err->logfile,0)
      ENDIF
      IF (drr_stop_runners("NUM_RUNNERS",drr_flex_sched->num_runners_to_stop)=0)
       RETURN(0)
      ENDIF
     ELSE
      SET drr_flex_sched->num_runners_to_stop = (drr_flex_sched->num_active_runners - (drr_flex_sched
      ->num_sched_runners - drr_flex_sched->num_stopping_runners))
      IF ((dm_err->debug_flag > 0))
       SET dm_err->eproc = concat("Need to stop ",trim(cnvtstring(drr_flex_sched->num_runners_to_stop
          ))," active runner(s)...")
       CALL disp_msg(" ",dm_err->logfile,0)
      ENDIF
      IF (drr_stop_runners("NUM_RUNNERS",drr_flex_sched->num_runners_to_stop)=0)
       RETURN(0)
      ENDIF
     ENDIF
    ELSEIF ((drr_flex_sched->num_active_runners=drr_flex_sched->tot_num_runners))
     SET drr_flex_sched->num_runners_to_stop = (drr_flex_sched->num_active_runners - drr_flex_sched->
     num_sched_runners)
     IF ((dm_err->debug_flag > 0))
      SET dm_err->eproc = concat("Need to stop ",trim(cnvtstring(drr_flex_sched->num_runners_to_stop)
        )," active runner(s)...")
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     IF (drr_stop_runners("NUM_RUNNERS",drr_flex_sched->num_runners_to_stop)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ELSE
    SET drr_flex_sched->num_runners_to_start = (drr_flex_sched->num_sched_runners - drr_flex_sched->
    tot_num_runners)
    IF ((dm_err->debug_flag > 0))
     SET dm_err->eproc = concat("Need to start ",trim(cnvtstring(drr_flex_sched->num_runners_to_start
        ))," runner(s)...")
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    IF (drr_start_runners(drr_flex_sched->num_runners_to_start,dmr_user,dmr_pword,dmr_cnnct_str,
     dmr_queue_name)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
   SET curalias schedule off
 END ;Subroutine
 SUBROUTINE drr_check_pkg_appl_status(dcpas_appl_id,dcpas_pkg_status)
   SET dm_err->eproc =
   "Determining if appl id attached to a package install using installation schedule is active."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_FLEX_SCHED_USAGE"
     AND di.info_char=dcpas_appl_id
     AND di.info_number=1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dcpas_pkg_status = 1
   ELSE
    SET dcpas_pkg_status = 0
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_check_runner_status(dcrs_runner_type,dcrs_appl_id,dcrs_status)
   SET dm_err->eproc = "Evaluating whether the runner has been marked to stop."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET dcrs_status = 0
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=dcrs_runner_type
     AND di.info_name=dcrs_appl_id
    DETAIL
     dcrs_status = di.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_insert_runner_row(dirr_runner_type,dirr_appl_id,dirr_desc,dirr_status,dirr_plan_id)
   DECLARE dirr_process_name = vc WITH protect, noconstant("NOTSET")
   CASE (dirr_runner_type)
    OF "DM2_INSTALL_RUNNER":
     SET dirr_process_name = dpl_install_runner
    OF "DM2_BACKGROUND_RUNNER":
     SET dirr_process_name = dpl_background_runner
    OF "DM2_INSTALL_PKG":
     SET dirr_process_name = dpl_package_install
    OF "DM2_INSTALL_MONITOR":
     SET dirr_process_name = dpl_install_monitor
    OF "DM2_ADS_DRIVER_GEN:AUDSID":
     SET dirr_process_name = dpl_sample
    OF "DM2_ADS_CHILDEST_GEN:AUDSID":
     SET dirr_process_name = dpl_sample
    OF "DM2_ADS_RUNNER:AUDSID":
     SET dirr_process_name = dpl_sample
   ENDCASE
   IF (dpl_ui_chk(dirr_process_name)=0)
    RETURN(0)
   ENDIF
   IF (drr_cleanup_dm_info_runners(null)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_process_event_rs->ui_allowed_ind=1)
    AND dirr_process_name != "NOTSET")
    SET dm2_process_event_rs->install_plan_id = dirr_plan_id
    SET dm2_process_event_rs->status = dpl_executing
    CALL dm2_process_log_add_detail_text(dpl_logfilemain,dm_err->logfile)
    SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_date = cnvtdatetime(
     curdate,curtime3)
    CALL dm2_process_log_add_detail_text(dpl_audsid,currdbhandle)
    CASE (dirr_process_name)
     OF dpl_install_runner:
      CALL dm2_process_log_add_detail_number("BACKGROUND_IND",0.0)
      CALL dm2_process_log_add_detail_number("SCHEDULER_IND",0.0)
     OF dpl_background_runner:
      CALL dm2_process_log_add_detail_number("BACKGROUND_IND",1.0)
      CALL dm2_process_log_add_detail_number("SCHEDULER_IND",1.0)
     OF dpl_install_monitor:
      CALL dm2_process_log_add_detail_number("BACKGROUND_IND",1.0)
    ENDCASE
    SET dm2_process_rs->process_name = dirr_process_name
    CALL dm2_process_log_row(dirr_process_name,dpl_execution,dpl_no_prev_id,1)
    SET dir_ui_misc->dm_process_event_id = dm2_process_event_rs->dm_process_event_id
    SET dm2_process_event_rs->begin_dt_tm = cnvtdatetime(curdate,curtime3)
    SET dm2_process_event_rs->end_dt_tm = cnvtdatetime(curdate,curtime3)
    SET dm2_process_event_rs->install_plan_id = dirr_plan_id
    SET dm2_process_event_rs->status = dpl_complete
    CALL dm2_process_log_add_detail_text(dpl_audit_name,concat(dirr_process_name,"-STARTED"))
    CALL dm2_process_log_add_detail_text(dpl_audit_type,dpl_progress)
    IF (dm2_process_log_row(dpl_package_install,dpl_auditlog,dpl_no_prev_id,0)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dirr_process_name=dpl_sample)
    SET dm2_process_event_rs->status = dpl_executing
    CALL dm2_process_log_add_detail_text(dpl_logfilemain,dm_err->logfile)
    SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_date = cnvtdatetime(
     curdate,curtime3)
    CALL dm2_process_log_add_detail_text(dpl_audsid,currdbhandle)
    SET dm2_process_rs->process_name = dirr_process_name
    CALL dm2_process_log_row(dirr_process_name,dpl_execution,dpl_no_prev_id,1)
    SET dir_ui_misc->dm_process_event_id = dm2_process_event_rs->dm_process_event_id
   ENDIF
   SET dm_err->eproc = concat("Determining if DM_INFO runner row for ",trim(dirr_runner_type,3),
    " and appl id ",trim(dirr_appl_id,3)," exists.")
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=dirr_runner_type
     AND di.info_name=dirr_appl_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = concat("Inserting DM_INFO runner row for ",trim(dirr_runner_type,3),
     " and appl id ",trim(dirr_appl_id,3),"...")
    CALL disp_msg(" ",dm_err->logfile,0)
    INSERT  FROM dm_info di
     SET di.info_domain = dirr_runner_type, di.info_name = dirr_appl_id, di.info_date =
      cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)),
      di.info_char =
      IF (dirr_runner_type IN ("DM2_INSTALL_PKG", "DM2_INSTALL_MONITOR")) trim(cnvtstring(
         dirr_plan_id))
      ELSE dirr_desc
      ENDIF
      , di.info_number = dirr_status, di.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)),
      di.updt_applctx = 0, di.updt_cnt = 0, di.updt_id = 0,
      di.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
   ELSE
    SET dm_err->eproc = concat("Updating DM_INFO runner row for ",trim(dirr_runner_type,3),
     " and appl id ",trim(dirr_appl_id,3),"...")
    CALL disp_msg(" ",dm_err->logfile,0)
    UPDATE  FROM dm_info di
     SET di.info_date = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)), di.info_char =
      IF (dirr_runner_type IN ("DM2_INSTALL_PKG", "DM2_INSTALL_MONITOR")) trim(cnvtstring(
         dirr_plan_id))
      ELSE dirr_desc
      ENDIF
      , di.info_number = dirr_status,
      di.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)), di.updt_applctx = 0, di
      .updt_cnt = 0,
      di.updt_id = 0, di.updt_task = reqinfo->updt_task
     WHERE di.info_domain=dirr_runner_type
      AND di.info_name=dirr_appl_id
     WITH nocounter
    ;end update
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_remove_runner_row(drrr_runner_type,drrr_appl_id)
   DECLARE drrr_process_name = vc WITH protect, noconstant("")
   DECLARE drrr_install_plan_number = f8 WITH protect, noconstant(0.0)
   DECLARE drrr_err_ind = i2 WITH protect, noconstant(0)
   DECLARE drrr_emsg = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE drrr_eproc = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE drrr_optimizer_hint = vc WITH protect, noconstant("")
   SET drrr_err_ind = dm_err->err_ind
   SET drrr_emsg = dm_err->emsg
   SET drrr_eproc = dm_err->eproc
   SET dm_err->err_ind = 0
   SET dm_err->emsg = ""
   SET dm_err->eproc = ""
   SET drrr_optimizer_hint = concat(" LEADING(DP DPE )","INDEX(DP XAK1DM_PROCESS)",
    "INDEX(DPE XIE1DM_PROCESS_EVENT)")
   CASE (drrr_runner_type)
    OF "DM2_INSTALL_RUNNER":
     SET drrr_process_name = dpl_install_runner
    OF "DM2_BACKGROUND_RUNNER":
     SET drrr_process_name = dpl_background_runner
    OF "DM2_INSTALL_PKG":
     SET drrr_process_name = dpl_package_install
    OF "DM2_INSTALL_MONITOR":
     SET drrr_process_name = dpl_install_monitor
    OF "DM2_ADS_DRIVER_GEN:AUDSID":
     SET drrr_process_name = dpl_sample
    OF "DM2_ADS_CHILDEST_GEN:AUDSID":
     SET drrr_process_name = dpl_sample
    OF "DM2_ADS_RUNNER:AUDSID":
     SET drrr_process_name = dpl_sample
   ENDCASE
   IF (drrr_process_name=dpl_sample)
    IF ((((dm_err->err_ind=0)) OR ((dm_err->debug_flag > 0))) )
     SET dm_err->eproc = "Update process event to appropriate status"
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    UPDATE  FROM dm_process_event dpe
     SET dpe.event_status = evaluate(drrr_err_ind,1,"FAILED","COMPLETE"), dpe.message_txt = evaluate(
       drrr_err_ind,1,substring(1,1900,drrr_emsg),"Removed runner row")
     WHERE (dpe.dm_process_event_id=dir_ui_misc->dm_process_event_id)
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   CALL dpl_ui_chk(drrr_process_name)
   IF ((dm2_process_event_rs->ui_allowed_ind=1))
    IF ((((dm_err->err_ind=0)) OR ((dm_err->debug_flag > 0))) )
     SET dm_err->eproc = "Update process event to appropriate status"
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    UPDATE  FROM dm_process_event dpe
     SET dpe.event_status = evaluate(drrr_err_ind,1,"FAILED","COMPLETE"), dpe.message_txt = evaluate(
       drrr_err_ind,1,substring(1,1900,drrr_emsg),"Removed runner row")
     WHERE (dpe.dm_process_event_id=dir_ui_misc->dm_process_event_id)
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ELSE
     COMMIT
    ENDIF
    IF (drrr_err_ind=1
     AND drrr_process_name=dpl_package_install)
     IF ((dm_err->err_ind=0))
      SET dm_err->eproc = "Obtain the Install_Plan_Id for the AudSid"
      IF ((dm_err->debug_flag > 0))
       CALL disp_msg("",dm_err->logfile,0)
      ENDIF
      SELECT INTO "nl:"
       FROM dm_info di
       WHERE di.info_domain="DM2_INSTALL_PKG"
        AND di.info_name=drrr_appl_id
       DETAIL
        drrr_install_plan_number = cnvtreal(di.info_char)
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ENDIF
     ENDIF
     IF (curqual > 0)
      IF ((dm_err->err_ind=0))
       SET dm_err->eproc = "Update the event status for the removed runners"
       IF ((dm_err->debug_flag > 0))
        CALL disp_msg("",dm_err->logfile,0)
       ENDIF
       UPDATE  FROM dm_process_event dpe1
        SET dpe1.event_status = dpl_failed, dpe1.message_txt = dm_err->emsg
        WHERE dpe1.dm_process_event_id IN (
        (SELECT
         dpe.dm_process_event_id
         FROM dm_process dp,
          dm_process_event dpe
         WHERE dp.dm_process_id=dpe.dm_process_id
          AND dp.process_name=dpl_package_install
          AND dp.action_type=dpl_itinerary_event
          AND dpe.install_plan_id=drrr_install_plan_number
          AND (( NOT (dpe.event_status IN (dpl_success, dpl_complete, dpl_failure, dpl_failed))) OR (
         dpe.event_status = null))
          AND dpe.begin_dt_tm > cnvtdatetime("01-JAN-1900")
          AND dpe.begin_dt_tm IS NOT null
         WITH orahintcbo(value(drrr_optimizer_hint))))
        WITH nocounter
       ;end update
       IF (check_error(dm_err->eproc)=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ELSE
        COMMIT
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    IF ((dm_err->err_ind=0))
     SET dm_err->eproc = "Obtain the Install_Plan_Id from DM_PROCESS_EVENT"
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     SELECT INTO "nl:"
      FROM dm_process_event dpe
      WHERE (dpe.dm_process_event_id=dir_ui_misc->dm_process_event_id)
      DETAIL
       drrr_install_plan_number = dpe.install_plan_id
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ENDIF
    ENDIF
    IF ((dm_err->err_ind=0))
     IF (curqual > 0)
      SET dm2_process_event_rs->begin_dt_tm = cnvtdatetime(curdate,curtime3)
      SET dm2_process_event_rs->end_dt_tm = cnvtdatetime(curdate,curtime3)
      SET dm2_process_event_rs->install_plan_id = drrr_install_plan_number
      SET dm2_process_event_rs->status = dpl_complete
      CALL dm2_process_log_add_detail_text(dpl_audit_name,concat(drrr_process_name,evaluate(
         drrr_err_ind,0,"-COMPLETE","-FAILED")))
      CALL dm2_process_log_add_detail_text(dpl_audit_type,dpl_progress)
      CALL dm2_process_log_row(dpl_package_install,dpl_auditlog,dpl_no_prev_id,0)
     ENDIF
    ENDIF
   ENDIF
   IF ((dm_err->err_ind=0))
    SET dm_err->eproc = concat("Remove DM_INFO runner row for ",trim(drrr_runner_type,3),
     " and appl id ",trim(drrr_appl_id,3))
    CALL disp_msg(" ",dm_err->logfile,0)
    DELETE  FROM dm_info di
     WHERE di.info_domain=drrr_runner_type
      AND di.info_name=drrr_appl_id
     WITH nocounter
    ;end delete
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   SET dm_err->err_ind = drrr_err_ind
   SET dm_err->emsg = drrr_emsg
   SET dm_err->eproc = drrr_eproc
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_rr_insert_runner_row(drirr_runner_identifier,drirr_appl_id)
   IF (drr_rr_cleanup_dm_info_runners(null)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Determining if Admin DM_INFO runner row for ",trim(
     drirr_runner_identifier,3)," and appl id ",trim(drirr_appl_id,3)," exists.")
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info di
    WHERE di.info_domain=drirr_runner_identifier
     AND di.info_name=drirr_appl_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = concat("Inserting Admin DM_INFO runner row for ",trim(drirr_runner_identifier,
      3)," and appl id ",trim(drirr_appl_id,3),"...")
    CALL disp_msg(" ",dm_err->logfile,0)
    INSERT  FROM dm2_admin_dm_info di
     SET di.info_domain = drirr_runner_identifier, di.info_name = drirr_appl_id, di.info_date =
      cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)),
      di.info_number = 1, di.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)), di
      .updt_applctx = 0,
      di.updt_cnt = 0, di.updt_id = 0, di.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
   ELSE
    SET dm_err->eproc = concat("Updating Admin DM_INFO runner row for ",trim(drirr_runner_identifier,
      3)," and appl id ",trim(drirr_appl_id,3),"...")
    CALL disp_msg(" ",dm_err->logfile,0)
    UPDATE  FROM dm2_admin_dm_info di
     SET di.info_date = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)), di.info_number = 1, di
      .updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)),
      di.updt_applctx = 0, di.updt_cnt = 0, di.updt_id = 0,
      di.updt_task = reqinfo->updt_task
     WHERE di.info_domain=drirr_runner_identifier
      AND di.info_name=drirr_appl_id
     WITH nocounter
    ;end update
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_rr_check_runner_status(drcrs_runner_identifier,drcrs_appl_id,drcrs_status)
   SET dm_err->eproc = concat("Evaluating whether main/runner session (",drcrs_runner_identifier,
    ") has been marked to stop.")
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET drcrs_status = 0
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info di
    WHERE di.info_domain=drcrs_runner_identifier
     AND di.info_name=drcrs_appl_id
    DETAIL
     drcrs_status = di.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_rr_cleanup_dm_info_runners(null)
   DECLARE drcdir_applx = i4 WITH protect, noconstant(0)
   FREE RECORD drcdir_appl_rs
   RECORD drcdir_appl_rs(
     1 cnt = i4
     1 qual[*]
       2 appl_id = vc
   )
   SET dm_err->eproc = "Getting a distinct list of appl ids attached to a replicate runner..."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT DISTINCT INTO "nl:"
    di.info_name
    FROM dm2_admin_dm_info di
    WHERE di.info_domain IN ("RR_RUNNER*", "RR_MAIN*")
    HEAD REPORT
     drcdir_applx = 0
    DETAIL
     drcdir_applx = (drcdir_applx+ 1)
     IF (mod(drcdir_applx,10)=1)
      stat = alterlist(drcdir_appl_rs->qual,(drcdir_applx+ 9))
     ENDIF
     drcdir_appl_rs->qual[drcdir_applx].appl_id = trim(di.info_name,3)
    FOOT REPORT
     drcdir_appl_rs->cnt = drcdir_applx, stat = alterlist(drcdir_appl_rs->qual,drcdir_applx)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((drcdir_appl_rs->cnt > 0))
    SET drcdir_applx = 1
    WHILE ((drcdir_applx <= drcdir_appl_rs->cnt))
     CASE (dm2_get_appl_status(value(drcdir_appl_rs->qual[drcdir_applx].appl_id)))
      OF "I":
       IF ((dm_err->debug_flag > 1))
        CALL echo(concat("Application Id ",drcdir_appl_rs->qual[drcdir_applx].appl_id,
          " is not active."))
       ENDIF
       DELETE  FROM dm2_admin_dm_info di
        WHERE di.info_domain IN ("RR_RUNNER*", "RR_MAIN*")
         AND (di.info_name=drcdir_appl_rs->qual[drcdir_applx].appl_id)
        WITH nocounter
       ;end delete
       IF (check_error("Removing Admin dm_info runner row(s) - appl id no longer active.")=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ELSE
        COMMIT
       ENDIF
      OF "A":
       IF ((dm_err->debug_flag > 1))
        CALL echo(concat("Application Id ",drcdir_appl_rs->qual[drcdir_applx].appl_id," is active."))
       ENDIF
      OF "E":
       IF ((dm_err->debug_flag > 1))
        CALL echo("Error Detected in dm2_get_appl_status")
       ENDIF
       RETURN(0)
     ENDCASE
     SET drcdir_applx = (drcdir_applx+ 1)
    ENDWHILE
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo("********** No Application Ids Detected **********")
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_rr_remove_runner_row(drrrr_runner_identifier,drrrr_appl_id)
   DECLARE drrrr_err_ind = i2 WITH protect, noconstant(0)
   DECLARE drrrr_emsg = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE drrrr_eproc = vc WITH protect, noconstant("DM2NOTSET")
   SET drrrr_err_ind = dm_err->err_ind
   SET drrrr_emsg = dm_err->emsg
   SET drrrr_eproc = dm_err->eproc
   SET dm_err->err_ind = 0
   SET dm_err->emsg = ""
   SET dm_err->eproc = ""
   SET dm_err->eproc = concat("Remove Admin DM_INFO runner row for ",trim(drrrr_runner_identifier,3),
    " and appl id ",trim(drrrr_appl_id,3))
   CALL disp_msg(" ",dm_err->logfile,0)
   DELETE  FROM dm2_admin_dm_info di
    WHERE di.info_domain=drrrr_runner_identifier
     AND di.info_name=drrrr_appl_id
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ELSE
    COMMIT
   ENDIF
   SET dm_err->err_ind = drrrr_err_ind
   SET dm_err->emsg = drrrr_emsg
   SET dm_err->eproc = drrrr_eproc
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_rr_maintain_runners(drmr_user,drmr_pword,drmr_cnnct_str,drmr_runners,
  drmr_runner_identifier)
   DECLARE drmr_active_runners = i2 WITH protect, noconstant(0)
   DECLARE drmr_stopping_runners = i2 WITH protect, noconstant(0)
   DECLARE drmr_total_runners = i2 WITH protect, noconstant(0)
   DECLARE drmr_num_runners_to_start = i2 WITH protect, noconstant(0)
   IF (drr_rr_cleanup_dm_info_runners(null)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    SET dm_err->eproc = concat(trim(cnvtstring(drmr_runners))," runner(s) should be running.")
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET dm_err->eproc = "Determining how many background runners are running..."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info di
    WHERE di.info_domain=drmr_runner_identifier
    DETAIL
     IF (di.info_number=1)
      drmr_active_runners = (drmr_active_runners+ 1)
     ELSE
      drmr_stopping_runners = (drmr_stopping_runners+ 1)
     ENDIF
     drmr_total_runners = (drmr_total_runners+ 1)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echo(concat("Total Runners:    ",trim(cnvtstring(drmr_total_runners))))
    CALL echo(concat("Active Runners:   ",trim(cnvtstring(drmr_active_runners))))
    CALL echo(concat("Stopping Runners: ",trim(cnvtstring(drmr_stopping_runners))))
   ENDIF
   IF (drmr_stopping_runners > 0)
    SET dm_err->eproc = "Validating status of replicate background runners."
    SET dm_err->emsg = "Background runners have been marked to stop, exiting process."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (drmr_total_runners=drmr_runners)
    IF ((dm_err->debug_flag > 0))
     SET dm_err->eproc = "Currently running the specified number of runners..."
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    RETURN(1)
   ENDIF
   IF (drmr_total_runners < drmr_runners)
    SET drmr_num_runners_to_start = (drmr_runners - drmr_total_runners)
    IF ((dm_err->debug_flag > 0))
     SET dm_err->eproc = concat("Need to start ",trim(cnvtstring(drmr_num_runners_to_start)),
      " runner(s)...")
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    IF (drr_rr_start_runners(drmr_num_runners_to_start,drmr_user,drmr_pword,drmr_cnnct_str,
     drmr_runner_identifier)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_rr_start_runners(drstr_num_runners,drstr_user,drstr_pword,drstr_cnnct_str,
  drstr_identifier)
   DECLARE drstr_connect_string = vc WITH protect, noconstant(" ")
   DECLARE drstr_file_name = vc WITH protect, noconstant(" ")
   DECLARE drstr_logfile_name = vc WITH protect, noconstant(" ")
   DECLARE drstr_exec_cmd = vc WITH protect, noconstant(" ")
   DECLARE drstr_chmod_cmd = vc WITH protect, noconstant(" ")
   DECLARE drstr_loop_cnt = i2 WITH protect, noconstant(0)
   DECLARE drstr_debug_flag = vc WITH protect, noconstant("0")
   DECLARE drstr_stat = i4 WITH protect, noconstant(0)
   DECLARE drstr_logfile_ident = vc WITH protect, noconstant(" ")
   DECLARE drstr_name = vc WITH protect, noconstant(" ")
   IF (drstr_num_runners <= 0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid input number for subroutine drr_rr_start_runners"
    SET dm_err->eproc = "Validating input number - number of runners to start."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (((drstr_user=" ") OR (((drstr_pword=" ") OR (drstr_identifier=" ")) )) )
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid input for subroutine drr_start_runners"
    SET dm_err->eproc = "Validating input passed into subroutine."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (drstr_cnnct_str > " "
    AND drstr_cnnct_str != "NONE")
    SET drstr_connect_string = build("'",drstr_user,"/",drstr_pword,"@",
     drstr_cnnct_str,"'")
   ELSE
    SET drstr_connect_string = build("'",drstr_user,"/",drstr_pword,"'")
   ENDIF
   CALL echo(concat("connect string = ",drstr_connect_string))
   SET drstr_debug_flag = cnvtstring(dm_err->debug_flag)
   FOR (drstr_loop_cnt = 1 TO drstr_num_runners)
     IF (findstring("ccluserdir",drrr_misc_data->active_dir,1,1) > 0)
      SET drstr_name = "dm2_rrr_bckgrnd_"
     ELSE
      SET drstr_name = "dm2_rrr_background_"
     ENDIF
     IF (get_unique_file(drstr_name,".ksh")=0)
      RETURN(0)
     ENDIF
     SET drstr_logfile_name = replace(dm_err->unique_fname,".ksh",".log",0)
     SET drstr_logfile_ident = replace(dm_err->unique_fname,drstr_name,"",0)
     SET drstr_logfile_ident = build("'",trim(replace(drstr_logfile_ident,".log","",0),3),"'")
     SET drstr_file_name = dm_err->unique_fname
     SET drstr_logfile_name = build(drrr_misc_data->active_dir,drstr_logfile_name)
     SET dm_err->eproc = concat("Creating job (",drstr_file_name,") to execute background runner.")
     SELECT INTO trim(drstr_file_name)
      DETAIL
       col 0, "#!/usr/bin/ksh", row + 1,
       col 0, "# Executing Replicate/Refresh Background Runner...", row + 1,
       col 0, "#", row + 1,
       col 0, ". $cer_mgr/",
       CALL print(trim(cnvtlower(logical("environment")))),
       "_environment.ksh", row + 1, col 0,
       "ccl <<!", row + 1, col 0,
       "free define oraclesystem go", row + 1, col 0,
       "define oraclesystem ", drstr_connect_string, " go",
       row + 1, col 0, "set dm2_debug_flag = ",
       drstr_debug_flag, " go", row + 1,
       col 0, "set dm2_rrr_log_identifier = ", drstr_logfile_ident,
       " go", row + 1, col 0,
       "dm2_background_runner '", drstr_user, "', '",
       drstr_pword, "', '", drstr_cnnct_str,
       "', '", drstr_identifier, "' go",
       row + 1, col 0, "exit",
       row + 1, col 0, "!",
       row + 1, col 0, "sleep 30"
      WITH nocounter, maxrow = 1, format = variable,
       formfeed = none
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET drstr_chmod_cmd = concat("chmod 777 $CCLUSERDIR/",drstr_file_name)
     IF ((dm_err->debug_flag > 0))
      SET dm_err->eproc = concat("drr_rr_start_runners changing permissions for ",drstr_file_name,"."
       )
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     IF (dm2_push_dcl(drstr_chmod_cmd)=0)
      RETURN(0)
     ENDIF
     SET drstr_exec_cmd = concat("nohup ","$CCLUSERDIR/",drstr_file_name," > ",drstr_logfile_name,
      " 2>&1 &")
     CALL echo(concat("exec_cmd = ",drstr_exec_cmd))
     SET dm_err->eproc = concat("Executing ",trim(drstr_file_name)," - results will be logged to ",
      trim(drstr_logfile_name),".")
     CALL disp_msg(" ",dm_err->logfile,0)
     CALL dcl(drstr_exec_cmd,size(drstr_exec_cmd),drstr_stat)
     IF (drstr_stat=0)
      IF (parse_errfile(drstr_logfile_name)=0)
       RETURN(0)
      ENDIF
      SET dm_err->disp_msg_emsg = dm_err->errtext
      SET dm_err->emsg = dm_err->disp_msg_emsg
      SET dm_err->eproc = concat("dm2_push_dcl executing: ",drstr_exec_cmd)
      SET dm_err->err_ind = 1
      CALL disp_msg("dm_err->disp_msg_emsg",dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET drstr_exec_cmd = concat("ps -ef | grep ",drstr_file_name," | grep -v grep")
     SET dm_err->disp_dcl_err_ind = 0
     IF (dm2_push_dcl(drstr_exec_cmd)=0)
      IF ((dm_err->err_ind=1))
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
     IF (parse_errfile(dm_err->errfile)=0)
      RETURN(0)
     ENDIF
     IF (findstring(drstr_file_name,dm_err->errtext)=0)
      SET dm_err->disp_msg_emsg = "Unable to locate process for this job."
      SET dm_err->emsg = dm_err->disp_msg_emsg
      SET dm_err->eproc = concat("Validating ",trim(drstr_file_name)," was successfully executed.")
      SET dm_err->err_ind = 1
      CALL disp_msg("dm_err->disp_msg_emsg",dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF ((dm_err->debug_flag < 3))
      IF (remove(drstr_file_name)=0)
       SET dm_err->err_ind = 1
       SET dm_err->emsg = concat("Could not remove ",drstr_file_name," from ccluserdir.")
       SET dm_err->eproc = "Removing replicate/refresh background ksh file from ccluserdir."
       CALL disp_msg((dm_err - emsg),dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_cleanup_adm_dm_info_runners(dcadir_dblink)
   DECLARE dcadir_dm_info_fnd_ind = i2 WITH protect, noconstant(0)
   DECLARE dcadir_applx = i4 WITH protect, noconstant(0)
   DECLARE dcadir_appl_status = vc WITH protect, noconstant("")
   RECORD dcadir_appl_rs(
     1 cnt = i4
     1 qual[*]
       2 appl_id = vc
   )
   SET dm_err->eproc = "Getting a distinct list of admin appl ids attached to a runner."
   IF ((dm_err->debug_flag > 1))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT DISTINCT INTO "nl:"
    di.info_name
    FROM (value(concat("DM_INFO@",dcadir_dblink)) di)
    WHERE di.info_domain IN ("DM2_ADMIN_RUNNER")
    HEAD REPORT
     dcadir_applx = 0
    DETAIL
     dcadir_applx = (dcadir_applx+ 1)
     IF (mod(dcadir_applx,10)=1)
      stat = alterlist(dcadir_appl_rs->qual,(dcadir_applx+ 9))
     ENDIF
     dcadir_appl_rs->qual[dcadir_applx].appl_id = trim(di.info_name,3)
    FOOT REPORT
     dcadir_appl_rs->cnt = dcadir_applx, stat = alterlist(dcadir_appl_rs->qual,dcadir_applx)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dcadir_appl_rs->cnt > 0))
    SET dcadir_applx = 1
    WHILE ((dcadir_applx <= dcadir_appl_rs->cnt))
      IF (dir_get_adm_appl_status(dcadir_dblink,value(dcadir_appl_rs->qual[dcadir_applx].appl_id),
       dcadir_appl_status)=0)
       RETURN(0)
      ENDIF
      CASE (dcadir_appl_status)
       OF "INACTIVE":
        IF ((dm_err->debug_flag > 1))
         CALL echo(concat("Admin Application Id is",dcadir_appl_rs->qual[dcadir_applx].appl_id,
           " is not active."))
        ENDIF
        SET dm_err->eproc = "Removing dm_info runner row(s) - admin appl id no longer active.."
        IF ((dm_err->debug_flag > 1))
         CALL disp_msg(" ",dm_err->logfile,0)
        ENDIF
        DELETE  FROM (value(concat("DM_INFO@",dcadir_dblink)) di)
         WHERE di.info_domain IN ("DM2_ADMIN_RUNNER")
          AND (di.info_name=dcadir_appl_rs->qual[dcadir_applx].appl_id)
         WITH nocounter
        ;end delete
        IF (check_error(dm_err->eproc)=1)
         ROLLBACK
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ELSE
         COMMIT
        ENDIF
       OF "ACTIVE":
        IF ((dm_err->debug_flag > 1))
         CALL echo(concat("Admin Application Id is",dcadir_appl_rs->qual[dcadir_applx].appl_id,
           " is active."))
        ENDIF
      ENDCASE
      SET dcadir_applx = (dcadir_applx+ 1)
    ENDWHILE
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo("********** No Application Ids Detected **********")
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_chk_active_runners(dcar_dblink,dcar_count_ind)
   SET dcar_count_ind = 0
   IF (drr_cleanup_dm_info_runners(null)=0)
    RETURN(0)
   ENDIF
   IF (drr_cleanup_adm_dm_info_runners(dcar_dblink)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Check for active background runners"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain IN ("DM2_SCHEMA_RUNNER", "DM2_README_RUNNER")
    WITH nocounter, maxqual(di,1)
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dcar_count_ind = 1
   ELSE
    SET dm_err->eproc = "Check for active admin background runners"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (value(concat("DM_INFO@",dcar_dblink)) di)
     WHERE di.info_domain IN ("DM2_ADMIN_RUNNER")
     WITH nocounter, maxqual(di,1)
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF (curqual > 0)
     SET dcar_count_ind = 1
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 IF (validate(dm2_etu->mode," ")=" ")
  FREE RECORD dm2_etu
  RECORD dm2_etu(
    1 mode = vc
    1 tbl_name = vc
    1 pkg_num = i4
  )
  SET dm2_etu->mode = "NOT_DEFINED"
  SET dm2_etu->tbl_name = " "
  SET dm2_etu->pkg_num = 0
 ENDIF
 DECLARE log_package_op(sbr_lpo_operation=vc,sbr_lpo_status=vc,sbr_lpo_message=vc,sbr_lpo_eid=f8,
  sbr_lpo_pkg_int=i4) = i2
 DECLARE check_package_op(sbr_cpo_operation=vc,sbr_cpo_package_int=i4,sbr_cpo_eid=f8) = i2
 DECLARE bad_package_op(sbr_bpo_bad_op=vc,sbr_bpo_pre_op=vc,sbr_bpo_eid=f8,sbr_bpo_pkg_int=i4) = null
 DECLARE del_all_package_op(sbr_dapo_eid=f8,sbr_dapo_pkg_int=i4) = i2
 DECLARE check_for_compl_row(i_cfcr_operation=vc,i_cfcr_pkg=i4,i_cfcr_eid=f8,o_updt_dt_tm=f8(ref)) =
 i2
 DECLARE write_dol_row(wdr_environtment_id=f8,wdr_project_type=vc,wdr_project_name=vc,
  wdr_project_instance=i4,wdr_ocd=i4,
  wdr_batch_dt_tm=f8,wdr_status=vc,wdr_start_dt_tm=f8,wdr_end_dt_tm=f8,wdr_driver_count=i4,
  wdr_elapsed_time=f8,wdr_message=vc,wdr_active_ind=i2) = i2
 DECLARE check_dol_row(cdr_environment_id=f8,cdr_project_type=vc,cdr_project_name=vc,
  cdr_project_instance=i4,cdr_ocd=i4,
  cdr_status=vc,cdr_curqual=i4(ref)) = i2
 DECLARE maintain_archive_dt_op(mado_environment_id=f8,mado_pkg_int=i4) = i2
 DECLARE start_status(sbr_ss_install_status=vc,sbr_ss_eid=f8,sbr_ss_package_int=i4) = null
 DECLARE end_status(sbr_es_install_status=vc,sbr_es_eid=f8,sbr_es_package_int=i4) = null
 DECLARE log_package_op_event(null) = i2
 IF ((validate(lpoe->environment_id,- (1))=- (1))
  AND validate(lpoe->environment_id,1)=1)
  FREE RECORD lpoe
  RECORD lpoe(
    1 environment_id = f8
    1 project_type = vc
    1 project_name = vc
    1 project_instance = i4
    1 ocd = i4
    1 batch_dt_tm = dq8
    1 status = vc
    1 start_dt_tm = dq8
    1 end_dt_tm = dq8
    1 message = vc
  )
 ENDIF
 IF (validate(olo_none,"X")="X")
  FREE DEFINE ocd_op
  RECORD ocd_op(
    1 cur_op = vc
    1 pre_op = vc
    1 next_op = vc
    1 bad_op = vc
    1 status = vc
    1 msg = vc
  )
  DECLARE olo_none = vc WITH public, constant("None")
  DECLARE olo_load_ccl_file = vc WITH public, constant("Load CCL File")
  DECLARE olo_batchload_ccl_files = vc WITH public, constant("Load CCL Files for Batch Install")
  DECLARE olo_schema_report = vc WITH public, constant("Display Schema Report")
  DECLARE olo_readme_report = vc WITH public, constant("Display Readme Report")
  DECLARE olo_code_sets = vc WITH public, constant("Code Sets")
  DECLARE olo_pre_uts = vc WITH public, constant("Pre-UTS Readmes")
  DECLARE olo_uptime_schema = vc WITH public, constant("Uptime Schema")
  DECLARE olo_post_uts = vc WITH public, constant("Post-UTS Readmes")
  DECLARE olo_pre_cycle = vc WITH public, constant("Pre-CYCLE Readmes")
  DECLARE olo_pre_dts = vc WITH public, constant("Pre-DTS Readmes")
  DECLARE olo_downtime_schema = vc WITH public, constant("Downtime Schema")
  DECLARE olo_post_dts = vc WITH public, constant("Post-DTS Readmes")
  DECLARE olo_atrs = vc WITH public, constant("ATRs")
  DECLARE olo_post_inst = vc WITH public, constant("Post-INST Readmes")
  DECLARE olo_preview_complete = vc WITH public, constant("Preview Mode Completed")
  DECLARE olo_adm_archive_dt = vc WITH public, constant("Admin Archive Date")
  DECLARE olo_readme_spchk = vc WITH public, constant("PREVIEW OF README SPACE CHECKS")
  DECLARE olo_load_dma_data = vc WITH public, constant("Load DMA_SQL_OBJ_INST Data")
  DECLARE ols_start = vc WITH public, constant("START")
  DECLARE ols_begin = vc WITH public, constant("START")
  DECLARE ols_running = vc WITH public, constant("RUNNING")
  DECLARE ols_error = vc WITH public, constant("ERROR")
  DECLARE ols_failed = vc WITH public, constant("ERROR")
  DECLARE ols_complete = vc WITH public, constant("COMPLETE")
  DECLARE ols_end = vc WITH public, constant("COMPLETE")
  DECLARE ols_finish = vc WITH public, constant("COMPLETE")
  DECLARE olpt_install_info = vc WITH public, constant("INSTALL_INFO")
  DECLARE olpt_install_plan = vc WITH public, constant("INSTALL_PLAN")
  DECLARE olpt_install_log = vc WITH public, constant("INSTALL LOG")
 ENDIF
 SUBROUTINE log_package_op(sbr_lpo_operation,sbr_lpo_status,sbr_lpo_message,sbr_lpo_eid,
  sbr_lpo_pkg_int)
   DECLARE sbr_lpo_prev_err_ind = i2 WITH noconstant(0)
   IF ((dm_err->err_ind=1))
    SET sbr_lpo_prev_err_ind = 1
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("previous error indicator:",sbr_lpo_prev_err_ind))
   ENDIF
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   UPDATE  FROM dm_ocd_log d
    SET d.status = evaluate(cnvtupper(sbr_lpo_status),ols_start,ols_running,cnvtupper(sbr_lpo_status)
      ), d.message = substring(1,255,sbr_lpo_message), d.start_dt_tm = evaluate(cnvtupper(
       sbr_lpo_status),ols_start,cnvtdatetime(curdate,curtime3),d.start_dt_tm),
     d.end_dt_tm = evaluate(cnvtupper(sbr_lpo_status),ols_complete,cnvtdatetime(curdate,curtime3),
      ols_error,cnvtdatetime(curdate,curtime3),
      null), d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE d.environment_id=sbr_lpo_eid
     AND d.project_type="INSTALL LOG"
     AND d.project_name=cnvtupper(sbr_lpo_operation)
     AND d.project_instance=1
     AND d.ocd=sbr_lpo_pkg_int
    WITH nocounter
   ;end update
   IF (curqual=0)
    INSERT  FROM dm_ocd_log d
     SET d.environment_id = sbr_lpo_eid, d.project_type = "INSTALL LOG", d.project_name = cnvtupper(
       sbr_lpo_operation),
      d.project_instance = 1, d.ocd = sbr_lpo_pkg_int, d.batch_dt_tm = cnvtdatetime(curdate,curtime3),
      d.status = evaluate(cnvtupper(sbr_lpo_status),ols_start,ols_running,cnvtupper(sbr_lpo_status)),
      d.message = substring(1,255,sbr_lpo_message), d.start_dt_tm = cnvtdatetime(curdate,curtime3),
      d.end_dt_tm = evaluate(cnvtupper(sbr_lpo_status),ols_complete,cnvtdatetime(curdate,curtime3),
       ols_error,cnvtdatetime(curdate,curtime3),
       null), d.driver_count = null, d.estimated_time = null,
      d.active_ind = 1, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Recording operation in the log table."
     SET dm_err->emsg = "Installation Failed. Unable to log status to dm_ocd_log table."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     ROLLBACK
     RETURN(0)
    ENDIF
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
   IF (check_error("Inserting or updating package status in log table.")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    IF (sbr_lpo_prev_err_ind=1)
     COMMIT
    ELSE
     ROLLBACK
    ENDIF
    RETURN(0)
   ELSE
    COMMIT
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE check_package_op(sbr_cpo_operation,sbr_cpo_package_int,sbr_cpo_eid)
   IF (cnvtupper(sbr_cpo_operation)="NONE")
    RETURN(1)
   ENDIF
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_ocd_log d
    WHERE d.environment_id=sbr_cpo_eid
     AND d.project_type="INSTALL LOG"
     AND d.project_name=cnvtupper(sbr_cpo_operation)
     AND d.project_instance=1
     AND d.ocd=sbr_cpo_package_int
     AND d.status="COMPLETE"
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL dm2_set_autocommit(0)
    RETURN(0)
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
   IF (check_error("Checking for operation in the log table.")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE bad_package_op(sbr_bpo_bad_op,sbr_bpo_pre_op,sbr_bpo_eid,sbr_bpo_pkg_int)
   CALL end_status(build("Cannot execute '",sbr_bpo_bad_op,"' operation until '",sbr_bpo_pre_op,
     "' operation is complete. Install FAILED."),sbr_bpo_eid,sbr_bpo_pkg_int)
 END ;Subroutine
 SUBROUTINE del_all_package_op(sbr_dapo_eid,sbr_dapo_pkg_int)
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   DELETE  FROM dm_ocd_log d
    WHERE d.environment_id=sbr_dapo_eid
     AND d.project_type="INSTALL LOG"
     AND d.ocd=sbr_dapo_pkg_int
     AND d.project_name != cnvtupper(olo_load_ccl_file)
    WITH nocounter
   ;end delete
   IF (check_error("Deleting INSTALL LOG rows from the log table.")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    ROLLBACK
    RETURN(0)
   ELSE
    COMMIT
   ENDIF
   SELECT INTO "nl:"
    FROM dm_ocd_log d
    WHERE d.environment_id=sbr_dapo_eid
     AND d.project_type="INSTALL LOG"
     AND d.ocd=sbr_dapo_pkg_int
     AND d.project_name != cnvtupper(olo_load_ccl_file)
    WITH nocounter
   ;end select
   IF (curqual > 0)
    CALL dm2_set_autocommit(0)
    RETURN(0)
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
   IF (check_error("Verifying deletion of INSTALL LOG rows from the log table.")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE check_for_compl_row(i_cfcr_operation,i_cfcr_pkg,i_cfcr_eid,o_cfcr_updt_dt_tm)
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Checking for complete row for operation: ",i_cfcr_operation)
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_ocd_log d
    WHERE d.environment_id=i_cfcr_eid
     AND d.project_type="INSTALL LOG"
     AND d.project_name=cnvtupper(i_cfcr_operation)
     AND d.project_instance=1
     AND d.ocd=i_cfcr_pkg
     AND d.status=ols_complete
    DETAIL
     o_cfcr_updt_dt_tm = d.updt_dt_tm
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    CALL dm2_set_autocommit(0)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET o_cfcr_updt_dt_tm = 0.0
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE write_dol_row(wdr_environment_id,wdr_project_type,wdr_project_name,wdr_project_instance,
  wdr_ocd,wdr_batch_dt_tm,wdr_status,wdr_start_dt_tm,wdr_end_dt_tm,wdr_driver_count,
  wdr_estimated_time,wdr_message,wdr_active_ind)
   DECLARE wdr_lpo_prev_err_ind = i2 WITH noconstant(0)
   DECLARE wdr_error_ind = i2 WITH noconstant(0)
   DECLARE wdr_prev_emsg = vc WITH noconstant(" ")
   SET wdr_lpo_prev_err_ind = dm_err->err_ind
   SET wdr_prev_emsg = dm_err->emsg
   IF (wdr_lpo_prev_err_ind=1)
    SET dm_err->err_ind = 0
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("wdr: previous error indicator:",wdr_lpo_prev_err_ind))
    CALL echo(build("wdr: previous error message:",wdr_prev_emsg))
   ENDIF
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   UPDATE  FROM dm_ocd_log d
    SET d.batch_dt_tm = cnvtdatetime(wdr_batch_dt_tm), d.status = wdr_status, d.start_dt_tm =
     cnvtdatetime(wdr_start_dt_tm),
     d.end_dt_tm = cnvtdatetime(wdr_end_dt_tm), d.driver_count = wdr_driver_count, d.estimated_time
      = wdr_estimated_time,
     d.message = substring(1,255,wdr_message), d.active_ind = wdr_active_ind, d.updt_dt_tm =
     cnvtdatetime(curdate,curtime3)
    WHERE d.environment_id=wdr_environment_id
     AND d.project_type=cnvtupper(wdr_project_type)
     AND d.project_name=cnvtupper(wdr_project_name)
     AND d.project_instance=wdr_project_instance
     AND d.ocd=wdr_ocd
    WITH nocounter
   ;end update
   IF (check_error("Updating dm_ocd_log table from write_dol_row.")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    SET wdr_error_ind = 1
   ENDIF
   IF (wdr_error_ind=0
    AND curqual=0)
    INSERT  FROM dm_ocd_log d
     SET d.batch_dt_tm = cnvtdatetime(wdr_batch_dt_tm), d.status = wdr_status, d.start_dt_tm =
      cnvtdatetime(wdr_start_dt_tm),
      d.end_dt_tm = cnvtdatetime(wdr_end_dt_tm), d.driver_count = wdr_driver_count, d.estimated_time
       = wdr_estimated_time,
      d.message = substring(1,255,wdr_message), d.active_ind = wdr_active_ind, d.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      d.environment_id = wdr_environment_id, d.project_type = cnvtupper(wdr_project_type), d
      .project_name = cnvtupper(wdr_project_name),
      d.project_instance = wdr_project_instance, d.ocd = wdr_ocd
     WITH nocounter
    ;end insert
    IF (check_error("Updating dm_ocd_log table from write_dol_row.")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     SET wdr_error_ind = 1
    ENDIF
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
   IF (wdr_lpo_prev_err_ind=1)
    SET dm_err->err_ind = wdr_lpo_prev_err_ind
    SET dm_err->err_msg = wdr_prev_emsg
   ENDIF
   IF (wdr_error_ind=1)
    ROLLBACK
    RETURN(0)
   ELSE
    COMMIT
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE check_dol_row(cdr_environment_id,cdr_project_type,cdr_project_name,cdr_project_instance,
  cdr_ocd,cdr_status,cdr_curqual)
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_ocd_log d
    WHERE d.environment_id=cdr_environment_id
     AND d.project_type=cnvtupper(cdr_project_type)
     AND d.project_name=cnvtupper(cdr_project_name)
     AND d.project_instance=cdr_project_instance
     AND d.ocd=cdr_ocd
     AND d.status=cdr_status
    WITH nocounter
   ;end select
   IF (check_error("Verifying dm_ocd_log row existance in check_dol_row.")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    SET cdr_curqual = 0
    CALL dm2_set_autocommit(0)
    RETURN(0)
   ELSE
    SET cdr_curqual = curqual
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE maintain_archive_dt_op(mado_environment_id,mado_pkg_int)
   DECLARE mado_archive_dt_tm = dq8 WITH protect, noconstant(0.00)
   DECLARE mado_output_str = vc WITH protect, noconstant(build("package <",mado_pkg_int,">"))
   DECLARE mado_updt_ind = i2 WITH protect, noconstant(1)
   SET dm_err->eproc = concat("Getting archive date and time for ",mado_output_str,".")
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    a.archive_dt_tm
    FROM dm_alpha_features a
    WHERE a.alpha_feature_nbr=mado_pkg_int
     AND a.owner=currdbuser
    DETAIL
     mado_archive_dt_tm = a.archive_dt_tm
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ELSEIF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("No DM_ALPHA_FEATURES row found for ",mado_output_str,".")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Updating Admin Archive Date row for ",mado_output_str,".")
   CALL disp_msg("",dm_err->logfile,0)
   UPDATE  FROM dm_ocd_log d
    SET d.batch_dt_tm = cnvtdatetime(mado_archive_dt_tm), d.updt_dt_tm = evaluate(datetimediff(
       cnvtdatetime(mado_archive_dt_tm),d.batch_dt_tm),0.0,d.updt_dt_tm,cnvtdatetime(curdate,curtime3
       ))
    WHERE d.environment_id=mado_environment_id
     AND d.project_type="INSTALL LOG"
     AND d.project_name=cnvtupper(olo_adm_archive_dt)
     AND d.project_instance=1
     AND d.ocd=mado_pkg_int
     AND d.status="COMPLETE"
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = concat("Existing row not found. Inserting Admin Archive Date row for ",
     mado_output_str,".")
    CALL disp_msg("",dm_err->logfile,0)
    INSERT  FROM dm_ocd_log d
     SET d.environment_id = mado_environment_id, d.project_type = "INSTALL LOG", d.project_name =
      cnvtupper(olo_adm_archive_dt),
      d.project_instance = 1, d.ocd = mado_pkg_int, d.batch_dt_tm = cnvtdatetime(mado_archive_dt_tm),
      d.status = cnvtupper(ols_complete), d.message = " ", d.start_dt_tm = cnvtdatetime(curdate,
       curtime3),
      d.end_dt_tm = cnvtdatetime(curdate,curtime3), d.driver_count = null, d.estimated_time = null,
      d.active_ind = 1, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   COMMIT
   SET dm_err->eproc = concat("Finished maintaining Admin Archive Date row for ",mado_output_str,".")
   CALL disp_msg("",dm_err->logfile,0)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE start_status(sbr_ss_install_status,sbr_ss_eid,sbr_ss_package_int)
   IF (dm2_set_autocommit(1)=0)
    SET dm_err->err_ind = 1
    RETURN(null)
   ENDIF
   SET dm_err->eproc = "Recording process status in DM_ALPHA_FEATURES_ENV."
   UPDATE  FROM dm_alpha_features_env defa
    SET defa.status = substring(1,100,sbr_ss_install_status), defa.start_dt_tm = cnvtdatetime(curdate,
      curtime3), defa.end_dt_tm = null
    WHERE defa.environment_id=sbr_ss_eid
     AND defa.alpha_feature_nbr=sbr_ss_package_int
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(null)
   ENDIF
   IF ( NOT (curqual))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Installation Failed.  No row found for this installation."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(null)
   ELSE
    COMMIT
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    SET dm_err->err_ind = 1
    RETURN(null)
   ENDIF
   IF ((validate(dir_ui_misc->dm_process_event_id,- (1)) != - (1))
    AND (validate(dir_ui_misc->dm_process_event_id,- (2)) != - (2)))
    IF ((dir_ui_misc->dm_process_event_id > 0))
     CALL dpl_upd_dped_last_status(dir_ui_misc->dm_process_event_id,sbr_ss_install_status,0.0,
      cnvtdatetime(curdate,curtime3))
    ENDIF
   ENDIF
   SET dm_err->eproc = sbr_ss_install_status
   CALL disp_msg(" ",dm_err->logfile,0)
 END ;Subroutine
 SUBROUTINE end_status(sbr_es_install_status,sbr_es_eid,sbr_es_package_int)
   DECLARE sbr_es_prev_err_ind = i2 WITH public, constant(dm_err->err_ind)
   IF (dm2_set_autocommit(1)=0)
    SET dm_err->err_ind = 1
    RETURN(null)
   ENDIF
   SET dm_err->eproc = sbr_es_install_status
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   UPDATE  FROM dm_alpha_features_env defa
    SET defa.status = substring(1,100,sbr_es_install_status), defa.end_dt_tm = cnvtdatetime(curdate,
      curtime3)
    WHERE defa.environment_id=sbr_es_eid
     AND defa.alpha_feature_nbr=sbr_es_package_int
    WITH nocounter
   ;end update
   IF (check_error("END_STATUS subroutine: Updating row in DM_ALPHA_FEATURES_ENV.")=1)
    IF (sbr_es_prev_err_ind=0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     ROLLBACK
    ELSE
     COMMIT
    ENDIF
    RETURN(null)
   ENDIF
   IF ( NOT (curqual))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Installation Failed.  No row found for this installation."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(null)
   ELSE
    COMMIT
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    SET dm_err->err_ind = 1
    RETURN(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE log_package_op_event(null)
   DECLARE sbr_lpoe_prev_err_ind = i2 WITH noconstant(0)
   IF ((dm_err->err_ind=1))
    SET sbr_lpoe_prev_err_ind = 1
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("previous error indicator:",sbr_lpoe_prev_err_ind))
   ENDIF
   IF ((lpoe->environment_id=0))
    SET dm_err->eproc = "Inserting or updating package op event in log table."
    CALL disp_msg("log_package_op_event bypassed due to lpoe->environment_id = 0",dm_err->logfile,1)
    RETURN(1)
   ENDIF
   UPDATE  FROM dm_ocd_log d
    SET d.status = lpoe->status, d.message = substring(1,255,lpoe->message), d.start_dt_tm = evaluate
     (cnvtupper(lpoe->status),ols_start,cnvtdatetime(curdate,curtime3),d.start_dt_tm),
     d.end_dt_tm = evaluate(cnvtupper(lpoe->status),ols_complete,cnvtdatetime(curdate,curtime3),
      ols_error,cnvtdatetime(curdate,curtime3),
      null), d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (d.environment_id=lpoe->environment_id)
     AND (d.project_type=lpoe->project_type)
     AND d.project_name=cnvtupper(lpoe->project_name)
     AND d.project_instance=1
     AND (d.ocd=lpoe->ocd)
     AND d.batch_dt_tm=cnvtdatetime(lpoe->batch_dt_tm)
    WITH nocounter
   ;end update
   IF (curqual=0)
    INSERT  FROM dm_ocd_log d
     SET d.environment_id = lpoe->environment_id, d.project_type = lpoe->project_type, d.project_name
       = cnvtupper(lpoe->project_name),
      d.project_instance = 1, d.ocd = lpoe->ocd, d.batch_dt_tm = cnvtdatetime(lpoe->batch_dt_tm),
      d.status = lpoe->status, d.message = substring(1,255,lpoe->message), d.start_dt_tm =
      cnvtdatetime(curdate,curtime3),
      d.end_dt_tm = evaluate(cnvtupper(lpoe->status),ols_complete,cnvtdatetime(curdate,curtime3),
       ols_error,cnvtdatetime(curdate,curtime3),
       null), d.driver_count = null, d.estimated_time = null,
      d.active_ind = 1, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
   ENDIF
   IF (check_error("Inserting or updating package status in log table.")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    IF (sbr_lpoe_prev_err_ind=1)
     COMMIT
    ELSE
     ROLLBACK
    ENDIF
    RETURN(0)
   ELSE
    COMMIT
    RETURN(1)
   ENDIF
 END ;Subroutine
 DECLARE dac_get_pkgdir(dgp_pkg=i4,dgp_pkg_loc=vc(ref)) = i2
 DECLARE dac_chk_batchover(dcb_batchcnt=i4(ref)) = i2
 DECLARE dac_pop_coldic_rec(dpcr_tab_in=vc) = i2
 DECLARE dac_prelim(dp_pkg=i4,dp_loc_ret=vc(ref),dp_batch_ret=i4(ref)) = i2
 DECLARE load_package_schema_csv(lpsc_eid=f8,lpsc_pkg_int=i4) = i2
 DECLARE determine_admin_load_method(dalm_pkg_in=i4,dalm_meth_out=i2(ref)) = i2
 DECLARE dac_parse_load_data_csv(pldc_pkg_in=f8,pldc_load_all_ind=i2) = i2
 DECLARE dac_load_cload(lc_pkg_in=f8) = i2
 DECLARE dac_aload_method_override_val = vc WITH protect, noconstant("NOT SET")
 DECLARE dac_aload_csv_file_loc = vc WITH protect, noconstant("")
 DECLARE ic_cnt = i4 WITH protect, noconstant(0)
 DECLARE init_csvcontentrow(ic_init_value=vc) = i2
 IF (validate(dac_ocd_txt_data->pkg,- (1)) < 0)
  FREE RECORD dac_ocd_txt_data
  RECORD dac_ocd_txt_data(
    1 pkg = i4
    1 file = vc
    1 archive_date = dq8
    1 type[*]
      2 name = vc
      2 rows = i4
  )
  SET dac_ocd_txt_data->file = "DM2NOTSET"
  SET dac_ocd_txt_data->pkg = 0
  SET dac_ocd_txt_data->archive_date = 0
 ENDIF
 IF (validate(dac_col_list->tbl,"-x")="-x"
  AND validate(dac_col_list->tbl,"-y")="-y")
  FREE RECORD dac_col_list
  RECORD dac_col_list(
    1 tbl = vc
    1 col[*]
      2 col_name = vc
      2 col_type = vc
  )
 ENDIF
 IF ((validate(csvcontent->csv_txt_version,- (1))=- (1))
  AND (validate(csvcontent->csv_txt_version,- (2))=- (2)))
  FREE RECORD csvcontent
  RECORD csvcontent(
    1 csv_txt_version = i4
    1 csv_packaging_field_cnt = i4
    1 csv_installation_field_cnt = i4
    1 prev_sch_inst_on_pkg = i4
    1 qual[*]
      2 table_name = vc
      2 filename = vc
      2 fileversion = vc
      2 loadscript = vc
      2 row_count = vc
      2 passive_ind = vc
      2 owner = vc
  )
 ENDIF
 SUBROUTINE init_csvcontentrow(ic_init_value)
   SET ic_cnt = 0
   SET ic_cnt = (size(csvcontent->qual,5)+ 1)
   SET stat = alterlist(csvcontent->qual,ic_cnt)
   SET csvcontent->qual[ic_cnt].table_name = ic_init_value
   SET csvcontent->qual[ic_cnt].filename = ic_init_value
   SET csvcontent->qual[ic_cnt].fileversion = ic_init_value
   SET csvcontent->qual[ic_cnt].loadscript = ic_init_value
   SET csvcontent->qual[ic_cnt].row_count = ic_init_value
   SET csvcontent->qual[ic_cnt].passive_ind = ic_init_value
   SET csvcontent->qual[ic_cnt].owner = ic_init_value
 END ;Subroutine
 SUBROUTINE dac_pop_coldic_rec(dpcr_tab_in)
   DECLARE dpcr_cnt = i4 WITH protect, noconstant(0)
   DECLARE dpcr_idx = i4 WITH protect, noconstant(0)
   DECLARE dcpr_col_oradef_ind = i2 WITH protect, noconstant(0)
   DECLARE dcpr_col_ccldef_ind = i2 WITH protect, noconstant(0)
   DECLARE dpcr_data_type = vc WITH protect, noconstant("")
   SET stat = alterlist(dac_col_list->col,0)
   SET dac_col_list->tbl = ""
   SET dac_col_list->tbl = cnvtupper(dpcr_tab_in)
   SET dm_err->eproc = concat("Get list of columns in dictionary for ",dac_col_list->tbl)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   FOR (dpcr_idx = 1 TO size(columns_1->list_1,5))
     SET dcpr_col_oradef_ind = 0
     SET dcpr_col_ccldef_ind = 0
     SET dpcr_data_type = ""
     IF (dm2_table_column_exists("",dac_col_list->tbl,columns_1->list_1[dpcr_idx].field_name,0,1,
      2,dcpr_col_oradef_ind,dcpr_col_ccldef_ind,dpcr_data_type)=0)
      RETURN(0)
     ENDIF
     IF (dcpr_col_ccldef_ind=1)
      SET dpcr_cnt = (dpcr_cnt+ 1)
      SET stat = alterlist(dac_col_list->col,dpcr_cnt)
      SET dac_col_list->col[dpcr_cnt].col_name = columns_1->list_1[dpcr_idx].field_name
      SET dac_col_list->col[dpcr_cnt].col_type = substring(1,1,dpcr_data_type)
     ENDIF
   ENDFOR
   IF (size(dac_col_list->col,5)=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("No rows identified according to dictionary for ",dac_col_list->tbl)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dac_col_list)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dac_chk_batchover(dcb_batchcnt)
   DECLARE dcb_batch_qual = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_ALOAD"
     AND d.info_name="BATCH_SIZE"
    DETAIL
     dcb_batch_qual = d.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(dcb_batch_qual)
   ENDIF
   SET dcb_batchcnt = dcb_batch_qual
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dac_get_pkgdir(dgp_pkg,dgp_pkg_loc)
   DECLARE dgp_text = vc WITH protect, noconstant("")
   DECLARE dgp_num = i4 WITH protect, noconstant(0)
   SET dgp_text = cnvtlower(trim(logical("cer_ocd"),3))
   IF (cursys="AXP")
    SET dgp_num = findstring("]",dgp_text)
    IF (dgp_num > 0)
     SET dgp_text = substring(1,(dgp_num - 1),dgp_text)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(dgp_num)
    CALL echo(dgp_text)
   ENDIF
   IF (cursys="AIX")
    SET dgp_pkg_loc = concat(dgp_text,"/",trim(format(dgp_pkg,"######;P0"),3),"/")
   ELSEIF (cursys="WIN")
    SET dgp_pkg_loc = concat(dgp_text,"\",trim(format(dgp_pkg,"######;P0"),3),"\")
   ELSE
    SET dgp_pkg_loc = concat(dgp_text,trim(format(dgp_pkg,"######;P0"),3),"]")
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dac_prelim(dp_pkg,dp_loc_ret,dp_batch_ret)
   DECLARE dp_loc_hold = vc WITH protect, noconstant("")
   DECLARE dp_batch_hold = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Get pkg directory."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (dac_get_pkgdir(dp_pkg,dp_loc_hold)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Check if batch cnt should be overwritten"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (dac_chk_batchover(dp_batch_hold)=0)
    RETURN(0)
   ENDIF
   SET dp_loc_ret = dp_loc_hold
   SET dp_batch_ret = dp_batch_hold
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dac_build_col_list(null)
  DECLARE dbcl_cnt = i4 WITH protect, noconstant(0)
  FOR (dbcl_cnt = 1 TO size(dac_col_list->col,5))
   CASE (dac_col_list->col[dbcl_cnt].col_type)
    OF "C":
     CALL dm2_push_cmd(concat("dcv.",dac_col_list->col[dbcl_cnt].col_name," = ",
       "evaluate(requestin->list_0[d.seq].",dac_col_list->col[dbcl_cnt].col_name,
       ",'::DM2NULLVALUE::',","null, requestin->list_0[d.seq].",dac_col_list->col[dbcl_cnt].col_name,
       ")"),0)
    OF "Q":
     CALL dm2_push_cmd(concat("dcv.",dac_col_list->col[dbcl_cnt].col_name," = ",
       "evaluate(requestin->list_0[d.seq].",dac_col_list->col[dbcl_cnt].col_name,
       ",'::DM2NULLVALUE::',","null, cnvtdatetime(requestin->list_0[d.seq].",dac_col_list->col[
       dbcl_cnt].col_name,"))"),0)
    OF "I":
     CALL dm2_push_cmd(concat("dcv.",dac_col_list->col[dbcl_cnt].col_name," = ",
       "evaluate(requestin->list_0[d.seq].",dac_col_list->col[dbcl_cnt].col_name,
       ",'::DM2NULLVALUE::',","null, cnvtint(requestin->list_0[d.seq].",dac_col_list->col[dbcl_cnt].
       col_name,"))"),0)
    OF "F":
     CALL dm2_push_cmd(concat("dcv.",dac_col_list->col[dbcl_cnt].col_name," = ",
       "evaluate(requestin->list_0[d.seq].",dac_col_list->col[dbcl_cnt].col_name,
       ",'::DM2NULLVALUE::',","null, cnvtreal(requestin->list_0[d.seq].",dac_col_list->col[dbcl_cnt].
       col_name,"))"),0)
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("Column Name:",dac_col_list->col[dbcl_cnt].col_name,". Data_Type:",
      dac_col_list->col[dbcl_cnt].col_type," is not recognizable by load script.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
   ENDCASE
   IF (dbcl_cnt != size(dac_col_list->col,5))
    CALL dm2_push_cmd(",",0)
   ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE load_package_schema_csv(lpsc_eid,lpsc_pkg_int)
   DECLARE lpsc_cnt = i4 WITH protect, noconstant(0)
   DECLARE lpsc_script_call = vc WITH protect, noconstant("")
   DECLARE lpsc_script_log_op = vc WITH protect, noconstant("")
   SET dip_ccl_load_ind = 1
   SET ocd_op->cur_op = olo_load_ccl_file
   SET ocd_op->pre_op = olo_none
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc = "Entering LOAD_PACKAGE_SCHEMA_CSV."
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   CALL start_status(dm_err->eproc,lpsc_eid,lpsc_pkg_int)
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF (log_package_op(ocd_op->cur_op,ols_running,dm_err->eproc,lpsc_eid,lpsc_pkg_int)=0)
    RETURN(0)
   ENDIF
   FOR (lpsc_cnt = 1 TO size(csvcontent->qual,5))
     IF (((cnvtupper(csvcontent->qual[lpsc_cnt].owner)=currdbuser) OR (cnvtupper(csvcontent->qual[
      lpsc_cnt].owner)="ALL")) )
      SET lpsc_script_log_op = concat("Load Script:",csvcontent->qual[lpsc_cnt].loadscript," OCD:",
       trim(cnvtstring(lpsc_pkg_int)))
      IF (findfile(concat(dac_aload_csv_file_loc,csvcontent->qual[lpsc_cnt].filename))=0)
       DELETE  FROM dm_ocd_log d
        WHERE d.environment_id=lpsc_eid
         AND d.project_type="INSTALL LOG"
         AND d.ocd=lpsc_pkg_int
        WITH nocounter
       ;end delete
       COMMIT
       SET dm_err->eproc = concat("Installation Failed. Package schema CSV file ",
        dac_aload_csv_file_loc,csvcontent->qual[lpsc_cnt].filename," not found in CER_OCD.")
       CALL log_package_op(ocd_op->cur_op,ols_error,dm_err->eproc,lpsc_eid,lpsc_pkg_int)
       CALL end_status(dm_err->eproc,lpsc_eid,lpsc_pkg_int)
       SET dm_err->err_ind = 1
       RETURN(0)
      ENDIF
      IF (checkprg(csvcontent->qual[lpsc_cnt].loadscript)=0)
       DELETE  FROM dm_ocd_log d
        WHERE d.environment_id=lpsc_eid
         AND d.project_type="INSTALL LOG"
         AND d.ocd=lpsc_pkg_int
        WITH nocounter
       ;end delete
       COMMIT
       SET dm_err->eproc = concat("Installation Failed. Executable script ",csvcontent->qual[lpsc_cnt
        ].loadscript," not found in dictionary.")
       CALL log_package_op(ocd_op->cur_op,ols_error,dm_err->eproc,lpsc_eid,lpsc_pkg_int)
       CALL end_status(dm_err->eproc,lpsc_eid,lpsc_pkg_int)
       SET dm_err->err_ind = 1
       RETURN(0)
      ENDIF
      IF ((csvcontent->qual[lpsc_cnt].loadscript IN ("DM2_ALOAD_DM_FLAGS",
      "DM2_ALOAD_OCD_README_COMP")))
       SET lpsc_script_call = concat(" execute ",csvcontent->qual[lpsc_cnt].loadscript," ",build(
         lpsc_pkg_int),',"',
        csvcontent->qual[lpsc_cnt].filename,'",',csvcontent->qual[lpsc_cnt].passive_ind,",",
        csvcontent->qual[lpsc_cnt].row_count,
        " go")
      ELSE
       SET lpsc_script_call = concat(" execute ",csvcontent->qual[lpsc_cnt].loadscript," ",build(
         lpsc_pkg_int),',"',
        csvcontent->qual[lpsc_cnt].filename,'",',csvcontent->qual[lpsc_cnt].row_count," go")
      ENDIF
      SET dm_err->eproc = concat("EXECUTING LOAD SCRIPT:",lpsc_script_call)
      CALL log_package_op(lpsc_script_log_op,ols_start,dm_err->eproc,lpsc_eid,lpsc_pkg_int)
      CALL dm2_push_cmd(lpsc_script_call,1)
      IF ((dm_err->err_ind=1))
       CALL log_package_op(ocd_op->cur_op,ols_error,dm_err->eproc,lpsc_eid,lpsc_pkg_int)
       CALL log_package_op(lpsc_script_log_op,ols_error,dm_err->eproc,lpsc_eid,lpsc_pkg_int)
       CALL end_status(dm_err->eproc,lpsc_eid,lpsc_pkg_int)
       RETURN(0)
      ENDIF
      CALL log_package_op(lpsc_script_log_op,ols_complete,lpsc_script_call,lpsc_eid,lpsc_pkg_int)
     ENDIF
   ENDFOR
   SET dm_err->eproc = "Operation Successful. CSV Load Scripts included successfully."
   IF (log_package_op(ocd_op->cur_op,ols_complete,dm_err->eproc,lpsc_eid,lpsc_pkg_int)=0)
    RETURN(0)
   ENDIF
   CALL end_status(dm_err->eproc,lpsc_eid,lpsc_pkg_int)
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc = "Leaving LOAD_PACKAGE_SCHEMA_CSV."
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE determine_admin_load_method(dalm_pkg_in,dalm_meth_out)
   IF (dac_aload_method_override_val="NOT SET")
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="DM2_INSTALL_PKG"
      AND d.info_name="ADMIN_LOAD_METHOD"
     DETAIL
      dac_aload_method_override_val = d.info_char
     WITH nocounter
    ;end select
    IF (check_error("Determining admin load method.")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF (dac_aload_method_override_val="0"
     AND currdbuser != "V500")
     SET dm_err->eproc = concat("Evaluating admin load method override for current database user ",
      currdbuser)
     SET dm_err->emsg = concat("Cannot force use of .ccl file for current database user.")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dac_aload_method_override_val="0")
    SET dalm_meth_out = 0
    RETURN(1)
   ENDIF
   IF (dac_parse_load_data_csv(dalm_pkg_in,1)=0)
    RETURN(0)
   ENDIF
   IF ((csvcontent->csv_txt_version >= 1))
    SET dalm_meth_out = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dac_parse_load_data_csv(pldc_pkg_in,pldc_load_all_ind)
   DECLARE pldc_txt_file = vc WITH protect, noconstant("")
   DECLARE pldc_txt = vc WITH protect, noconstant("")
   DECLARE pldc_num1 = i4 WITH protect, noconstant(0)
   DECLARE pldc_num2 = i4 WITH protect, noconstant(0)
   DECLARE pldc_cnt = i4 WITH protect, noconstant(0)
   DECLARE pldc_abs_end = i4 WITH protect, noconstant(0)
   DECLARE pldc_rep_cnt = i4 WITH protect, noconstant(0)
   DECLARE pldc_line = vc WITH protect, noconstant("")
   DECLARE pldc_str = vc WITH protect, noconstant("")
   SET pldc_txt = cnvtlower(trim(logical("cer_ocd"),3))
   SET pldc_num1 = findstring("]",pldc_txt)
   IF (pldc_num1 > 0)
    SET pldc_txt = substring(1,(pldc_num1 - 1),pldc_txt)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET pldc_txt_file = concat(pldc_txt,trim(format(pldc_pkg_in,"######;P0"),3),"]")
   ELSEIF ((dm2_sys_misc->cur_os="WIN"))
    SET pldc_txt_file = concat(pldc_txt,"\",trim(format(pldc_pkg_in,"######;P0"),3),"\")
   ELSE
    SET pldc_txt_file = concat(pldc_txt,"/",trim(format(pldc_pkg_in,"######;P0"),3),"/")
   ENDIF
   SET dac_aload_csv_file_loc = pldc_txt_file
   SET pldc_txt_file = concat(pldc_txt_file,"ocd_schema_",trim(cnvtstring(pldc_pkg_in),3),".txt")
   SET dm_err->eproc = concat("Check for existence of ",pldc_txt_file)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF ( NOT (findfile(pldc_txt_file)))
    SET dm_err->emsg = concat(pldc_txt_file," not found. Unable to open.")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET stat = alterlist(csvcontent->qual,0)
   SET csvcontent->csv_txt_version = 0
   SET csvcontent->csv_packaging_field_cnt = 0
   SET csvcontent->csv_installation_field_cnt = 7
   FREE DEFINE rtl2
   SET logical pldc_file value(pldc_txt_file)
   DEFINE rtl2 "pldc_file"
   SET dm_err->eproc = "Read the .TXT file for CsvContent."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    DETAIL
     pldc_num2 = 0, pldc_num1 = 0, pldc_line = trim(check(r.line," "))
     IF (findstring("$ALOAD$DM2ALOADVERSION,",pldc_line) > 0)
      pldc_num1 = (findstring(",",pldc_line)+ 1), csvcontent->csv_txt_version = cnvtint(substring(
        pldc_num1,(textlen(pldc_line) - (pldc_num1 - 1)),pldc_line))
     ELSEIF (findstring("$ALOAD$DM2ALOADFIELDCNT,",pldc_line) > 0)
      pldc_num1 = (findstring(",",pldc_line)+ 1), csvcontent->csv_packaging_field_cnt = cnvtint(
       substring(pldc_num1,(textlen(pldc_line) - (pldc_num1 - 1)),pldc_line))
     ELSEIF (((((findstring("$ALOAD$",pldc_line) > 0) OR (((findstring("$ALOAD2$",pldc_line) > 0) OR
     (((findstring("$ALOAD3$",pldc_line) > 0) OR (findstring("$ALOAD4$",pldc_line) > 0)) )) ))
      AND pldc_load_all_ind=1) OR (((findstring("$CLOAD$",pldc_line) > 0) OR (findstring(
      "$ALOAD$DM_TABLE_RELATIONSHIPS",pldc_line) > 0)) )) )
      CALL init_csvcontentrow("DM2PNOTSET"), pldc_cnt = size(csvcontent->qual,5), pldc_rep_cnt = 0,
      pldc_num1 = 0, pldc_abs_end = least(csvcontent->csv_installation_field_cnt,csvcontent->
       csv_packaging_field_cnt)
      IF (findstring("$ALOAD$",pldc_line) > 0)
       pldc_num2 = (findstring("$ALOAD$",pldc_line)+ 6)
      ELSEIF (findstring("$ALOAD2$",pldc_line) > 0)
       pldc_num2 = (findstring("$ALOAD2$",pldc_line)+ 7)
      ELSEIF (findstring("$ALOAD3$",pldc_line) > 0)
       pldc_num2 = (findstring("$ALOAD3$",pldc_line)+ 7)
      ELSEIF (findstring("$CLOAD$",pldc_line) > 0)
       pldc_num2 = (findstring("$CLOAD$",pldc_line)+ 6)
      ELSEIF (findstring("$ALOAD4$",pldc_line) > 0)
       pldc_num2 = (findstring("$ALOAD4$",pldc_line)+ 7)
      ENDIF
      WHILE (pldc_rep_cnt < pldc_abs_end)
        pldc_rep_cnt = (pldc_rep_cnt+ 1), pldc_num1 = pldc_num2, pldc_num2 = findstring(",",pldc_line,
         (pldc_num1+ 1),0)
        IF (pldc_num2=0)
         pldc_str = substring((pldc_num1+ 1),(textlen(pldc_line) - pldc_num1),pldc_line)
        ELSE
         pldc_str = substring((pldc_num1+ 1),((pldc_num2 - pldc_num1) - 1),pldc_line)
        ENDIF
        IF ((dm_err->debug_flag > 0))
         CALL echo("*****"),
         CALL echo(pldc_line),
         CALL echo(pldc_str),
         CALL echo(pldc_num1),
         CALL echo(pldc_num2),
         CALL echo(pldc_abs_end)
        ENDIF
        CASE (pldc_rep_cnt)
         OF 1:
          csvcontent->qual[pldc_cnt].table_name = pldc_str
         OF 2:
          csvcontent->qual[pldc_cnt].filename = pldc_str
         OF 3:
          csvcontent->qual[pldc_cnt].fileversion = pldc_str
         OF 4:
          csvcontent->qual[pldc_cnt].loadscript = pldc_str
         OF 5:
          csvcontent->qual[pldc_cnt].row_count = pldc_str
         OF 6:
          csvcontent->qual[pldc_cnt].passive_ind = pldc_str
         OF 7:
          csvcontent->qual[pldc_cnt].owner = cnvtupper(pldc_str)
        ENDCASE
      ENDWHILE
      IF ((csvcontent->qual[pldc_cnt].owner="DM2PNOTSET"))
       csvcontent->qual[pldc_cnt].owner = "V500"
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error("Parsing .txt file for CSVCONTENT.")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(csvcontent)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dac_load_cload(lc_pkg_in)
   IF (dac_parse_load_data_csv(lc_pkg_in,0)=0)
    RETURN(0)
   ENDIF
 END ;Subroutine
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
 DECLARE dipr_setup_install_itinerary(dsit_plan_id=f8,dsit_plan_type=vc) = i2
 DECLARE dipr_add_itin_step(dais_mode=vc,dais_level=i2,dais_step_nbr=i2,dais_step_name=vc,
  dais_itin_key=vc) = i2
 DECLARE dipr_get_install_itinerary(dgit_plan_id=f8) = i2
 DECLARE dipr_update_install_itinerary(duit_status=i2,duit_itin_id=f8,duit_plan_id=f8) = i2
 DECLARE dipr_get_cur_dpe_data(dgcdd_install_plan=f8) = i2
 DECLARE dipr_get_plan_nbr(null) = i2
 DECLARE dipr_disp_error_msg(null) = i2
 IF ((validate(dip_itin_rs->itin_cnt,- (1))=- (1))
  AND (validate(dip_itin_rs->itin_cnt,- (2))=- (2)))
  FREE RECORD dip_itin_rs
  RECORD dip_itin_rs(
    1 install_plan_id = f8
    1 itin_cnt = i4
    1 itin_step[*]
      2 dm_process_event_id = f8
      2 event_status = vc
      2 begin_dt_tm = dq8
      2 end_dt_tm = dq8
      2 message_txt = vc
      2 itinerary_key = vc
      2 install_mode = vc
      2 level_number = i2
      2 step_number = i4
      2 step_name = vc
      2 parent_step_name = vc
      2 parent_level_number = i2
  )
 ENDIF
 IF ((validate(dipm_misc_data->install_plan_id,- (1))=- (1))
  AND (validate(dipm_misc_data->install_plan_id,- (2))=- (2)))
  FREE RECORD dipm_misc_data
  RECORD dipm_misc_data(
    1 install_plan_id = f8
    1 cur_dpe_id = f8
    1 cur_mode = vc
    1 cur_itin_dpe_id = f8
    1 cur_appl_id = f8
    1 cur_method = vc
    1 cur_dpe_status = vc
    1 cur_install_event = vc
  )
  SET dipm_misc_data->install_plan_id = 0.0
  SET dipm_misc_data->cur_dpe_id = 0.0
  SET dipm_misc_data->cur_mode = "DM2NOTSET"
  SET dipm_misc_data->cur_itin_dpe_id = 0.0
  SET dipm_misc_data->cur_appl_id = 0.0
  SET dipm_misc_data->cur_method = "DM2NOTSET"
  SET dipm_misc_data->cur_dpe_status = "DM2NOTSET"
  SET dipm_misc_data->cur_install_event = "DM2NOTSET"
 ENDIF
 SUBROUTINE dipr_update_install_itinerary(duit_status,duit_itin_id,duit_plan_id)
   DECLARE duit_msg = vc WITH protect, noconstant("")
   DECLARE duit_optimizer_hint = vc WITH protect, noconstant("")
   SET duit_optimizer_hint = concat(" LEADING(DP DPE)","INDEX(DP XAK1DM_PROCESS)",
    "INDEX(DPE XIE1DM_PROCESS_EVENT)")
   CASE (duit_status)
    OF 2:
     SET duit_msg = "PAUSED"
    OF 0:
     SET duit_msg = "STOPPED"
    OF 1:
     SET duit_msg = "EXECUTING"
   ENDCASE
   IF (duit_itin_id=0)
    SET dm_err->eproc = "Update itinerary status"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    UPDATE  FROM dm_process_event dpe1
     SET dpe1.event_status = duit_msg, dpe1.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE dpe1.dm_process_event_id IN (
     (SELECT
      dpe.dm_process_event_id
      FROM dm_process dp,
       dm_process_event dpe
      WHERE dp.dm_process_id=dpe.dm_process_id
       AND dp.process_name=dpl_package_install
       AND dp.action_type=dpl_itinerary_event
       AND dpe.install_plan_id=duit_plan_id
       AND  NOT (dpe.event_status IN (dpl_failed, dpl_complete, dpl_success, dpl_failure))
       AND ((dpe.begin_dt_tm > cnvtdatetime("01-JAN-1900")) OR (dpe.begin_dt_tm = null))
      WITH orahintcbo(value(duit_optimizer_hint))))
      AND dpe1.event_status != duit_msg
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ELSE
    SET dm_err->eproc = "Update itinerary status for event_id"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    UPDATE  FROM dm_process_event dpe
     SET dpe.event_status = duit_msg, dpe.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE dpe.dm_process_event_id=duit_itin_id
      AND dpe.event_status != duit_msg
     WITH nocounter
    ;end update
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
 SUBROUTINE dipr_setup_install_itinerary(dsit_plan_id,dsit_plan_type)
   DECLARE dsit_cnt = i4 WITH protect, noconstant(0)
   DECLARE dsit_ndx = i4 WITH protect, noconstant(0)
   SET dip_itin_rs->itin_cnt = 0
   SET stat = alterlist(dip_itin_rs->itin_step,dip_itin_rs->itin_cnt)
   SET dip_itin_rs->install_plan_id = dsit_plan_id
   SET stat = alterlist(dip_itin_rs->itin_step,9)
   CALL dipr_add_itin_step("BATCHUP",1,1,"Setup","BATCHUP:SETUP")
   CALL dipr_add_itin_step("BATCHUP",1,2,"Code Sets","BATCHUP:CODE_SETS")
   CALL dipr_add_itin_step("BATCHUP",1,3,"Pre-Schema Readmes","BATCHUP:PRE-SCHEMA_READMES")
   CALL dipr_add_itin_step("BATCHUP",1,4,"Schema","BATCHUP:SCHEMA")
   CALL dipr_add_itin_step("BATCHUP",1,5,"Application / Task / Request (ATRs)","BATCHUP:ATRS")
   CALL dipr_add_itin_step("BATCHUP",1,6,"Purge Templates","BATCHUP:PURGE_TEMPLATES")
   CALL dipr_add_itin_step("BATCHUP",1,7,"Post-Schema Readmes","BATCHUP:POST-SCHEMA_READMES")
   IF (dsit_plan_type="NO-DT")
    CALL dipr_add_itin_step("BATCHPRECYCLE",1,2,"Readmes","BATCHPRECYCLE:READMES")
   ENDIF
   IF (dsit_plan_type != "NO-DT")
    CALL dipr_add_itin_step("BATCHDOWN",1,2,"Readmes","BATCHDOWN:READMES")
   ENDIF
   CALL dipr_add_itin_step("BATCHPOST",1,2,"Readmes","BATCHPOST:READMES")
   SET dm_err->eproc = "Query for itinerary information"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_process dp,
     dm_process_event dpe,
     dm_process_event_dtl dped
    WHERE dp.process_name=dpl_package_install
     AND dp.action_type=dpl_itinerary_event
     AND dpe.dm_process_id=dp.dm_process_id
     AND (dpe.install_plan_id=dip_itin_rs->install_plan_id)
     AND dped.dm_process_event_id=dpe.dm_process_event_id
     AND dped.detail_type="ITINERARY_KEY"
    DETAIL
     dsit_ndx = locateval(dsit_ndx,1,dip_itin_rs->itin_cnt,dped.detail_text,dip_itin_rs->itin_step[
      dsit_ndx].itinerary_key)
     IF (dsit_ndx > 0)
      dip_itin_rs->itin_step[dsit_ndx].dm_process_event_id = dpe.dm_process_event_id
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dip_itin_rs)
   ENDIF
   FOR (dsit_cnt = 1 TO dip_itin_rs->itin_cnt)
     IF ((dip_itin_rs->itin_step[dsit_cnt].dm_process_event_id=0))
      SET dm2_process_event_rs->begin_dt_tm = cnvtdatetime("01-JAN-1900")
      SET dm2_process_event_rs->end_dt_tm = cnvtdatetime("01-JAN-1900")
      SET dm2_process_event_rs->install_plan_id = dsit_plan_id
      CALL dm2_process_log_add_detail_text("ITINERARY_KEY",dip_itin_rs->itin_step[dsit_cnt].
       itinerary_key)
      CALL dm2_process_log_add_detail_text("INSTALL_MODE",dip_itin_rs->itin_step[dsit_cnt].
       install_mode)
      CALL dm2_process_log_add_detail_text("STEP_NAME",dip_itin_rs->itin_step[dsit_cnt].step_name)
      CALL dm2_process_log_add_detail_number("STEP_NUMBER",cnvtreal(dip_itin_rs->itin_step[dsit_cnt].
        step_number))
      CALL dm2_process_log_add_detail_number("LEVEL_NUMBER",cnvtreal(dip_itin_rs->itin_step[dsit_cnt]
        .level_number))
      IF (dm2_process_log_row(dpl_package_install,dpl_itinerary_event,dpl_no_prev_id,1)=0)
       RETURN(0)
      ENDIF
      SET dip_itin_rs->itin_step[dsit_cnt].dm_process_event_id = dm2_process_event_rs->
      dm_process_event_id
     ENDIF
   ENDFOR
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dip_itin_rs)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dipr_add_itin_step(dais_mode,dais_level,dais_step_nbr,dais_step_name,dais_itin_key)
   SET dip_itin_rs->itin_cnt = (dip_itin_rs->itin_cnt+ 1)
   SET stat = alterlist(dip_itin_rs->itin_step,dip_itin_rs->itin_cnt)
   SET dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].install_mode = dais_mode
   SET dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].level_number = dais_level
   SET dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].step_number = dais_step_nbr
   SET dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].step_name = dais_step_name
   SET dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].itinerary_key = dais_itin_key
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dipr_get_install_itinerary(dgit_plan_id)
   SET dip_itin_rs->install_plan_id = dgit_plan_id
   SET dm_err->eproc = "Load itinerary data from process tables"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_process dp,
     dm_process_event dpe,
     dm_process_event_dtl dped
    WHERE dp.dm_process_id=dpe.dm_process_id
     AND dp.process_name=dpl_package_install
     AND dp.action_type=dpl_itinerary_event
     AND (dpe.install_plan_id=dip_itin_rs->install_plan_id)
     AND dpe.dm_process_event_id=dped.dm_process_event_id
    ORDER BY dpe.dm_process_event_id, dped.detail_type
    HEAD REPORT
     dip_itin_rs->itin_cnt = 0
    HEAD dpe.dm_process_event_id
     dip_itin_rs->itin_cnt = (dip_itin_rs->itin_cnt+ 1), stat = alterlist(dip_itin_rs->itin_step,
      dip_itin_rs->itin_cnt), dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].dm_process_event_id = dpe
     .dm_process_event_id
    DETAIL
     CASE (dped.detail_type)
      OF dpl_install_mode:
       dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].install_mode = dped.detail_text,
       IF (cnvtdatetime(dpe.begin_dt_tm) > cnvtdatetime("01-JAN-1900"))
        dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].begin_dt_tm = cnvtdatetime(dpe.begin_dt_tm)
       ENDIF
       ,
       IF (cnvtdatetime(dpe.end_dt_tm) > cnvtdatetime("01-JAN-1900"))
        dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].end_dt_tm = cnvtdatetime(dpe.end_dt_tm)
       ENDIF
       ,dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].event_status = dpe.event_status
      OF dpl_itinerary_key:
       dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].itinerary_key = dped.detail_text
      OF dpl_step_number:
       dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].step_number = dped.detail_number
      OF dpl_level:
       dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].level_number = dped.detail_number
      OF dpl_step_name:
       dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].step_name = dped.detail_text
      OF dpl_parent_step_name:
       dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].parent_step_name = dped.detail_text
      OF dpl_parent_level_number:
       dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].parent_level_number = dped.detail_number
     ENDCASE
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dip_itin_rs)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dipr_get_plan_nbr(null)
   DECLARE dgpn_continue = i2 WITH protect, noconstant(1)
   DECLARE dgpn_invalid = i2 WITH protect, noconstant(0)
   DECLARE dgpn_notfound = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Obtaining Plan ID"
   WHILE (dgpn_continue=1)
     SET message = window
     CALL clear(1,1)
     CALL box(1,1,3,132)
     CALL text(2,2,"INSTALL PLAN MENU [GET PLAN]")
     IF (dgpn_invalid=1)
      CALL text(4,2,concat(drr_flex_sched->pkg_number," is an Invalid Plan ID. Please Retry."))
      SET dgpn_invalid = 0
     ELSEIF (dgpn_notfound=1)
      CALL text(4,2,concat("Install activity not found for Install Plan Number: ",drr_flex_sched->
        pkg_number,". Please Retry"))
      SET dgpn_notfound = 0
     ENDIF
     CALL text(5,2,"Install Plan ID: ")
     SET help = pos(5,50,10,60)
     SET help =
     SELECT DISTINCT INTO "nl:"
      plan_id = install_plan_id
      FROM dm_install_plan
      ORDER BY install_plan_id DESC
      WITH nocounter
     ;end select
     CALL accept(5,20,"9(11);F")
     SET drr_flex_sched->pkg_number = cnvtstring(abs(curaccept))
     CALL text(7,2,"(C)ontinue, (M)odify, (B)ack :")
     CALL accept(7,34,"p;cu","C"
      WHERE curaccept IN ("C", "M", "B"))
     SET message = nowindow
     CASE (curaccept)
      OF "B":
       SET dm_err->emsg = "Plan ID was not provided"
       SET dm_err->err_ind = 1
       SET dgpn_continue = 0
      OF "C":
       CALL text(8,2,"Validating Install Plan...")
       SET dm_err->eproc = "Verifying that Install Plan ID exists"
       SELECT INTO "nl:"
        FROM dm_install_plan dip
        WHERE dip.install_plan_id=cnvtreal(drr_flex_sched->pkg_number)
        WITH nocounter, maxqual(dip,1)
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL dipr_disp_error_msg(null)
        RETURN(0)
       ENDIF
       IF (curqual=0)
        SET dgpn_invalid = 1
       ELSE
        SET dm_err->eproc = "Verifying that Install Plan ID has current activity"
        SELECT INTO "nl:"
         FROM dm_process dp,
          dm_process_event dpe
         PLAN (dp
          WHERE dp.process_name=value(dpl_package_install)
           AND dp.action_type=value(dpl_execution)
           AND dp.program_name="DM2_INSTALL_PKG")
          JOIN (dpe
          WHERE dp.dm_process_id=dpe.dm_process_id
           AND dpe.install_plan_id=cnvtreal(drr_flex_sched->pkg_number))
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         CALL dipr_disp_error_msg(null)
         RETURN(0)
        ENDIF
        IF (curqual > 0)
         SET dgpn_continue = 0
        ELSE
         SET dgpn_notfound = 1
        ENDIF
       ENDIF
      OF "M":
       SET dgpn_continue = 1
     ENDCASE
   ENDWHILE
   SET dipm_misc_data->install_plan_id = cnvtreal(drr_flex_sched->pkg_number)
   IF (check_error(dm_err->eproc)=1)
    CALL dipr_disp_error_msg(null)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dipr_disp_error_msg(null)
   SET message = nowindow
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   RETURN(null)
 END ;Subroutine
 SUBROUTINE dipr_get_cur_dpe_data(dgcdd_install)
   SET dipm_misc_data->cur_mode = "DM2NOTSET"
   SET dm_err->eproc = "Retrieving most recent dm_process_event row for package install execution"
   IF ((dm_err->debug_flag > 0))
    CALL dipr_disp_error_msg(null)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_process dp,
     dm_process_event dpe,
     dm_process_event_dtl dped
    PLAN (dpe
     WHERE dpe.install_plan_id=dgcdd_install)
     JOIN (dp
     WHERE dpe.dm_process_id=dp.dm_process_id
      AND dp.process_name=value(dpl_package_install)
      AND dp.action_type=value(dpl_execution)
      AND dp.program_name="DM2_INSTALL_PKG")
     JOIN (dped
     WHERE dpe.dm_process_event_id=dped.dm_process_event_id
      AND dped.detail_type=value(dpl_install_mode))
    ORDER BY dpe.begin_dt_tm DESC
    HEAD REPORT
     cur_dpe_set = 0
    DETAIL
     IF (cur_dpe_set=0)
      IF (cnvtupper(trim(dped.detail_text)) != "BATCHPREVIEW")
       cur_dpe_set = 1
      ENDIF
      IF (cnvtupper(dipm_misc_data->cur_mode) != cnvtupper(trim(dped.detail_text)))
       dipm_misc_data->cur_dpe_id = dpe.dm_process_event_id, dir_ui_misc->dm_process_event_id = dpe
       .dm_process_event_id, dipm_misc_data->cur_dpe_status = dpe.event_status,
       dipm_misc_data->cur_mode = cnvtupper(trim(dped.detail_text))
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL dipr_disp_error_msg(null)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->emsg = "Unable to retrieve current package install execution"
    SET dm_err->err_ind = 1
    CALL dipr_disp_error_msg(null)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE dn_test_file_name = vc WITH protect, noconstant("DM2NOTSET")
 IF ((dm2_sys_misc->cur_os="AXP"))
  SET dn_test_file_name = build(logical("CCLUSERDIR"),"dm2_install_plan_notify_test.txt")
 ELSE
  SET dn_test_file_name = build(logical("CCLUSERDIR"),"/dm2_install_plan_notify_test.txt")
 ENDIF
 IF ((validate(dnotify->status,- (99))=- (99))
  AND validate(dnotify->status,722)=722)
  FREE RECORD dnotify
  RECORD dnotify(
    1 status = i2
    1 install_method = vc
    1 file_name = vc
    1 email_address_list = vc
    1 email_subject = vc
    1 process = vc
    1 plan_id = f8
    1 client = vc
    1 mode = vc
    1 install_status = vc
    1 env_name = vc
    1 event = vc
    1 msgtype = vc
    1 test_single_ind = i2
    1 test_email_failed = i2
    1 suppression_flag = i4
    1 body_cnt = i4
    1 body[*]
      2 txt = vc
    1 email_cnt = i4
    1 email[*]
      2 address = vc
      2 new_ind = i2
  )
  SET dnotify->status = 0
  SET dnotify->install_method = "ATTENDED"
  SET dnotify->file_name = "DM2NOTSET"
  SET dnotify->email_subject = "DM2NOTSET"
  SET dnotify->email_address_list = "DM2NOTSET"
  SET dnotify->process = "DM2NOTSET"
  SET dnotify->plan_id = - (1)
  SET dnotify->client = "DM2NOTSET"
  SET dnotify->mode = "DM2NOTSET"
  SET dnotify->install_status = "DM2NOTSET"
  SET dnotify->env_name = "DM2NOTSET"
  SET dnotify->event = "DM2NOTSET"
  SET dnotify->msgtype = "DM2NOTSET"
  SET dnotify->test_single_ind = 0
  SET dnotify->test_email_failed = 0
  SET dnotify->body_cnt = 0
  SET dnotify->email_cnt = 0
  SET dnotify->suppression_flag = 0
 ENDIF
 DECLARE dn_get_notify_settings(null) = i2
 DECLARE dn_save_notify_settings(null) = i2
 DECLARE dn_confirm_install_notification(dcin_ret_action=c1(ref)) = i2
 DECLARE dn_notify(null) = i2
 DECLARE dn_add_body_text(dabt_in_text=vc,dabt_in_reset_ind=i2) = null
 DECLARE dn_reset_pre_err(drpe_emsg=vc,drpe_eproc=vc,drpe_user_action=vc) = null
 SUBROUTINE dn_get_notify_settings(null)
   DECLARE dgns_type = vc WITH protect, noconstant("")
   DECLARE dgns_error_reset_ind = i2 WITH protect, noconstant(0)
   DECLARE dgns_emsg = vc WITH protect, noconstant("")
   DECLARE dgns_eproc = vc WITH protect, noconstant("")
   DECLARE dgns_user_action = vc WITH protect, noconstant("")
   IF ((dm_err->err_ind=1))
    SET dgns_error_reset_ind = 1
    SET dgns_emsg = dm_err->emsg
    SET dgns_eproc = dm_err->eproc
    SET dgns_user_action = dm_err->user_action
    SET dm_err->err_ind = 0
    SET dm_err->emsg = ""
   ENDIF
   IF ((dnotify->client="DM2NOTSET"))
    SET dm_err->eproc = "Get Client Mnemonic."
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="DATA MANAGEMENT"
      AND d.info_name="CLIENT MNEMONIC"
     DETAIL
      dnotify->client = trim(cnvtupper(d.info_char))
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Failed to retrieve Client Mnemonic."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     IF (dgns_error_reset_ind=1)
      CALL dn_reset_pre_err(dgns_emsg,dgns_eproc,dgns_user_action)
     ENDIF
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dnotify->env_name="DM2NOTSET"))
    SET dm_err->eproc = "Get Environment Name."
    SELECT INTO "nl:"
     d.info_name
     FROM dm_info d
     WHERE d.info_domain="DATA MANAGEMENT"
      AND d.info_name="DM_ENV_NAME"
     DETAIL
      dnotify->env_name = trim(cnvtupper(d.info_char))
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Failed to retrieve Environment Name."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     IF (dgns_error_reset_ind=1)
      CALL dn_reset_pre_err(dgns_emsg,dgns_eproc,dgns_user_action)
     ENDIF
     RETURN(0)
    ENDIF
   ENDIF
   SET dnotify->email_cnt = 0
   SET stat = alterlist(dnotify->email,0)
   SET dnotify->email_address_list = ""
   SET dnotify->status = 0
   SET dnotify->test_single_ind = 0
   SET dnotify->test_email_failed = 0
   SET dm_err->eproc = "Retrieve current automated notification settings from DM_INFO."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info i
    WHERE i.info_domain="DM2NOTIFY"
    ORDER BY i.info_name
    DETAIL
     dgns_type = i.info_name
     IF (substring(1,5,dgns_type)="EMAIL")
      dgns_type = "EMAIL"
     ENDIF
     CASE (dgns_type)
      OF "STATUS":
       dnotify->status = i.info_number
      OF "EMAIL":
       IF (trim(dnotify->email_address_list,3)="")
        dnotify->email_address_list = trim(cnvtupper(i.info_char),3)
       ELSE
        dnotify->email_address_list = concat(dnotify->email_address_list,",",trim(cnvtupper(i
           .info_char),3))
       ENDIF
       ,dnotify->email_cnt = (dnotify->email_cnt+ 1),stat = alterlist(dnotify->email,dnotify->
        email_cnt),dnotify->email[dnotify->email_cnt].address = trim(cnvtupper(i.info_char),3)
      OF "SUPPRESSION_FLAG":
       dnotify->suppression_flag = i.info_number
     ENDCASE
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg("",dm_err->logfile,1)
    IF (dgns_error_reset_ind=1)
     CALL dn_reset_pre_err(dgns_emsg,dgns_eproc,dgns_user_action)
    ENDIF
    RETURN(0)
   ENDIF
   IF (dgns_error_reset_ind=1)
    CALL dn_reset_pre_err(dgns_emsg,dgns_eproc,dgns_user_action)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dn_save_notify_settings(null)
   IF ((dm_err->debug_flag=722))
    SET message = nowindow
   ENDIF
   DECLARE dsns_email_cnt = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Delete existing automated notification settings from DM_INFO."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   DELETE  FROM dm_info
    WHERE info_domain="DM2NOTIFY"
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg("",dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Write current automated notification settings to DM_INFO."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   INSERT  FROM dm_info i
    SET i.info_domain = "DM2NOTIFY", i.info_name = "STATUS", i.info_number = dnotify->status,
     i.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg("",dm_err->logfile,1)
    RETURN(0)
   ENDIF
   INSERT  FROM dm_info i
    SET i.info_domain = "DM2NOTIFY", i.info_name = "METHOD", i.info_char = trim(dnotify->
      install_method,3),
     i.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg("",dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dnotify->email_address_list = ""
   FOR (dsns_email_cnt = 1 TO dnotify->email_cnt)
     INSERT  FROM dm_info i
      SET i.info_domain = "DM2NOTIFY", i.info_name = concat("EMAIL",cnvtstring(dsns_email_cnt)), i
       .info_char = dnotify->email[dsns_email_cnt].address,
       i.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg("",dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF ((dnotify->email[dsns_email_cnt].new_ind=1))
      IF (trim(dnotify->email_address_list,3)="")
       SET dnotify->email_address_list = trim(dnotify->email[dsns_email_cnt].address,3)
      ELSE
       SET dnotify->email_address_list = concat(dnotify->email_address_list,",",trim(dnotify->email[
         dsns_email_cnt].address,3))
      ENDIF
     ENDIF
   ENDFOR
   INSERT  FROM dm_info i
    SET i.info_domain = "DM2NOTIFY", i.info_name = "SUPPRESSION_FLAG", i.info_number = dnotify->
     suppression_flag,
     i.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg("",dm_err->logfile,1)
    RETURN(0)
   ENDIF
   COMMIT
   SET dm2_process_event_rs->install_plan_id = 0
   SET dm2_process_event_rs->status = dpl_complete
   SET dm2_process_event_rs->begin_dt_tm = cnvtdatetime(curdate,curtime3)
   SET dm2_process_event_rs->end_dt_tm = cnvtdatetime(curdate,curtime3)
   CALL dm2_process_log_add_detail_text(dpl_audit_name,"NOTIFICATION_CHANGED")
   CALL dm2_process_log_add_detail_text(dpl_audit_type,dpl_progress)
   CALL dm2_process_log_add_detail_number("STATUS",cnvtreal(dnotify->status))
   FOR (dsns_email_cnt = 1 TO dnotify->email_cnt)
     CALL dm2_process_log_add_detail_text(concat("EMAIL",cnvtstring(dsns_email_cnt)),dnotify->email[
      dsns_email_cnt].address)
   ENDFOR
   CALL dm2_process_log_row(dpl_notification,dpl_auditlog,dpl_no_prev_id,1)
   SET dnotify->test_single_ind = 1
   SET dnotify->process = "TEST NOTIFICATION"
   SET dnotify->install_status = "N/A"
   SET dnotify->msgtype = "N/A"
   SET dnotify->file_name = dn_test_file_name
   CALL dn_add_body_text("This is a test email.",1)
   SET dm2_process_event_rs->install_plan_id = 0
   SET dm2_process_event_rs->status = dpl_complete
   SET dm2_process_event_rs->begin_dt_tm = cnvtdatetime(curdate,curtime3)
   SET dm2_process_event_rs->end_dt_tm = cnvtdatetime(curdate,curtime3)
   CALL dm2_process_log_add_detail_text(dpl_audit_name,"EMAIL: NOTIFICATION_CHANGED")
   CALL dm2_process_log_add_detail_text(dpl_audit_type,dpl_progress)
   IF (dn_notify(null)=0)
    SET dnotify->test_email_failed = 1
   ENDIF
   FOR (dsns_email_cnt = 1 TO dnotify->email_cnt)
     IF ((dnotify->email[dsns_email_cnt].new_ind=1))
      SET dnotify->email[dsns_email_cnt].new_ind = 0
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dn_confirm_install_notification(dcin_ret_action)
   DECLARE dcin_row = i4 WITH protect, noconstant(0)
   DECLARE dcin_email_cnt = i4 WITH protect, noconstant(0)
   DECLARE dcin_error_reset_ind = i2 WITH protect, noconstant(0)
   DECLARE dcin_emsg = vc WITH protect, noconstant("")
   DECLARE dcin_eproc = vc WITH protect, noconstant("")
   DECLARE dcin_user_action = vc WITH protect, noconstant("")
   DECLARE dcin_continue = i2 WITH protect, noconstant(0)
   IF ((dm_err->err_ind=1))
    SET dcin_error_reset_ind = 1
    SET dcin_emsg = dm_err->emsg
    SET dcin_eproc = dm_err->eproc
    SET dcin_user_action = dm_err->user_action
    SET dm_err->err_ind = 0
    SET dm_err->emsg = ""
   ENDIF
   SET dcin_continue = 1
   WHILE (dcin_continue)
     SET dm_err->eproc = "Confirm automated notification settings."
     CALL disp_msg("",dm_err->logfile,0)
     IF (dn_get_notify_settings(null)=0)
      IF (dcin_error_reset_ind=1)
       CALL dn_reset_pre_err(dcin_emsg,dcin_eproc,dcin_user_action)
      ENDIF
      RETURN(0)
     ENDIF
     SET width = 132
     IF ((dm_err->debug_flag != 722))
      SET message = window
     ENDIF
     CALL clear(1,1)
     CALL box(1,1,24,131)
     CALL text(2,2,"Please modify any Automated Notification Settings at this time.")
     SET dcin_row = 2
     IF ((dnotify->status=0)
      AND (dnotify->install_method="UNATTENDED"))
      SET dcin_row = (dcin_row+ 2)
      CALL text(dcin_row,2,"For Unattended Installs, Automated Notification Status must be ON.")
     ENDIF
     SET dcin_row = (dcin_row+ 2)
     CALL text(dcin_row,2,concat("Status : ",evaluate(dnotify->status,1,"ON","OFF")))
     IF ((dnotify->status=1))
      SET dcin_row = (dcin_row+ 1)
      CALL text(dcin_row,2,concat("DDL retry alert Status : ",evaluate(dnotify->suppression_flag,0,
         "ON","OFF")))
     ENDIF
     SET dcin_row = (dcin_row+ 1)
     CALL text(dcin_row,2,"Email addresses :")
     FOR (dcin_email_cnt = 1 TO dnotify->email_cnt)
       IF (dcin_email_cnt < 14)
        SET dcin_row = (dcin_row+ 1)
        CALL text(dcin_row,2,concat(trim(cnvtstring(dcin_email_cnt)),") ",trim(dnotify->email[
           dcin_email_cnt].address)))
       ELSE
        SET dcin_row = (dcin_row+ 1)
        CALL text(dcin_row,2,"Please use (M) option to review all email addresses...")
       ENDIF
     ENDFOR
     CALL text(23,2,"(C)ontinue, (M)odify Notification Settings, (Q)uit: ")
     CALL accept(23,60,"P;CU"," "
      WHERE curaccept IN ("C", "M", "Q"))
     IF (curaccept="M")
      SET dcin_ret_action = "M"
      EXECUTE dm2_install_plan_menu_notify
      IF ((dm_err->err_ind=1))
       IF (dcin_error_reset_ind=1)
        CALL dn_reset_pre_err(dcin_emsg,dcin_eproc,dcin_user_action)
       ENDIF
       RETURN(0)
      ENDIF
     ELSEIF (curaccept="C")
      SET dcin_ret_action = "C"
      SET dcin_continue = 0
     ELSEIF (curaccept="Q")
      SET dcin_ret_action = "Q"
      SET dcin_continue = 0
      SET dm_err->eproc = "Confirm automated notification settings."
      SET dm_err->err_ind = 1
      SET dm_err->emsg = "User choose to Quit."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      IF (dcin_error_reset_ind=1)
       CALL dn_reset_pre_err(dcin_emsg,dcin_eproc,dcin_user_action)
      ENDIF
      RETURN(0)
     ENDIF
   ENDWHILE
   IF (dcin_error_reset_ind=1)
    CALL dn_reset_pre_err(dcin_emsg,dcin_eproc,dcin_user_action)
   ENDIF
   SET message = nowindow
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dn_notify(null)
   IF ((dm_err->debug_flag=722))
    SET message = nowindow
   ENDIF
   DECLARE dn_line = vc WITH protect, noconstant("")
   DECLARE dn_cnt = i4 WITH protect, noconstant(0)
   DECLARE dn_error_reset_ind = i2 WITH protect, noconstant(0)
   DECLARE dn_emsg = vc WITH protect, noconstant("")
   DECLARE dn_eproc = vc WITH protect, noconstant("")
   DECLARE dn_user_action = vc WITH protect, noconstant("")
   DECLARE dn_dclcmd = vc WITH protect, noconstant("")
   DECLARE dn_status = i4 WITH protect, noconstant(0)
   IF ((dm_err->err_ind=1))
    SET dn_error_reset_ind = 1
    SET dn_emsg = dm_err->emsg
    SET dn_eproc = dm_err->eproc
    SET dn_user_action = dm_err->user_action
    SET dm_err->err_ind = 0
    SET dm_err->emsg = ""
   ENDIF
   IF ((dnotify->test_single_ind=0))
    IF (dn_get_notify_settings(null)=0)
     IF (dn_error_reset_ind=1)
      CALL dn_reset_pre_err(dn_emsg,dn_eproc,dn_user_action)
     ENDIF
     RETURN(0)
    ENDIF
   ENDIF
   IF ((((dnotify->email_address_list="")) OR ((dnotify->email_address_list="DM2NOTSET"))) )
    SET dm_err->emsg = concat(
     "Notification is bypassed due to notification email is not set up.  Subject: ",dnotify->
     email_subject)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    IF (dm2_process_log_row(dpl_package_install,dpl_auditlog,dpl_no_prev_id,0)=0)
     IF (dn_error_reset_ind=1)
      CALL dn_reset_pre_err(dn_emsg,dn_eproc,dn_user_action)
     ENDIF
     RETURN(0)
    ENDIF
    IF (dn_error_reset_ind=1)
     CALL dn_reset_pre_err(dn_emsg,dn_eproc,dn_user_action)
    ENDIF
    RETURN(1)
   ENDIF
   SET dnotify->email_subject = concat(evaluate(dnotify->process,"DM2NOTSET","N/A",trim(dnotify->
      process)),", MSGTYPE: ",evaluate(dnotify->msgtype,"DM2NOTSET","N/A",trim(dnotify->msgtype)),
    ", STATUS: ",evaluate(dnotify->install_status,"DM2NOTSET","N/A",trim(dnotify->install_status)),
    ", ENV: ",evaluate(dnotify->env_name,"DM2NOTSET","N/A",trim(dnotify->env_name)))
   IF ((dm_err->debug_flag > 0))
    CALL echo(dnotify->email_subject)
   ENDIF
   SET dm_err->eproc = "Generate email notification."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   IF ((dnotify->status != 1))
    SET dm_err->emsg = concat(
     "Notification is bypassed due to notification status is OFF.  Subject: ",dnotify->email_subject)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    IF (dm2_process_log_row(dpl_package_install,dpl_auditlog,dpl_no_prev_id,0)=0)
     IF (dn_error_reset_ind=1)
      CALL dn_reset_pre_err(dn_emsg,dn_eproc,dn_user_action)
     ENDIF
     RETURN(0)
    ENDIF
    IF (dn_error_reset_ind=1)
     CALL dn_reset_pre_err(dn_emsg,dn_eproc,dn_user_action)
    ENDIF
    RETURN(1)
   ENDIF
   IF (((trim(dnotify->file_name)="") OR (trim(dnotify->file_name)="DM2NOTSET")) )
    IF (get_unique_file("dm2notify",".dat")=0)
     IF (dn_error_reset_ind=1)
      CALL dn_reset_pre_err(dn_emsg,dn_eproc,dn_user_action)
     ENDIF
     RETURN(0)
    ENDIF
    SET dnotify->file_name = dm_err->unique_fname
   ENDIF
   SET dm_err->eproc = concat("Generate file ",dnotify->file_name)
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO value(dnotify->file_name)
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     IF ((dnotify->test_single_ind=0))
      dn_line = concat("PLAN_ID: ",evaluate(cnvtstring(dnotify->plan_id),"-1","N/A",trim(cnvtstring(
          dnotify->plan_id))),", CLIENT: ",evaluate(dnotify->client,"DM2NOTSET","N/A",trim(dnotify->
         client)),", MODE: ",
       evaluate(dnotify->mode,"DM2NOTSET","N/A",trim(dnotify->mode)),", EVENT: ",evaluate(dnotify->
        event,"DM2NOTSET","N/A",trim(dnotify->event)),", EMAIL DT/TM: ",format(cnvtdatetime(curdate,
         curtime3),";;q")),
      CALL print(dn_line), row + 1,
      row + 2
     ENDIF
     FOR (dn_cnt = 1 TO dnotify->body_cnt)
      CALL print(dnotify->body[dn_cnt].txt),row + 1
     ENDFOR
    WITH nocounter, maxcol = 2000, format = variable,
     formfeed = none, maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Failed to create file ",dnotify->file_name)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    IF (dn_error_reset_ind=1)
     CALL dn_reset_pre_err(dn_emsg,dn_eproc,dn_user_action)
    ENDIF
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dn_dclcmd = concat('MAIL/SUBJECT="',build(dnotify->email_subject),'" ',build(dnotify->
      file_name),' "',
     build(dnotify->email_address_list),'"')
   ELSEIF ((dm2_sys_misc->cur_os IN ("AIX", "LNX")))
    SET dn_dclcmd = concat('mail -s "',dnotify->email_subject,'" "',dnotify->email_address_list,
     '" < ',
     dnotify->file_name)
   ELSEIF ((dm2_sys_misc->cur_os="HPX"))
    SET dn_dclcmd = concat('mailx -s "',dnotify->email_subject,'" "',dnotify->email_address_list,
     '" < ',
     dnotify->file_name)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("email command : ",dn_dclcmd))
    CALL echorecord(dnotify)
   ENDIF
   SET dn_status = 0
   CALL dcl(dn_dclcmd,size(dn_dclcmd),dn_status)
   IF (dn_status=0)
    SET dm_err->eproc = concat("Email ",dnotify->file_name," to address : ",dnotify->
     email_address_list)
    SET dm_err->emsg = "Failed to send email notification."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    IF (dn_error_reset_ind=1)
     CALL dn_reset_pre_err(dn_emsg,dn_eproc,dn_user_action)
    ELSE
     SET dm_err->err_ind = 1
    ENDIF
    RETURN(0)
   ELSE
    CALL dm2_process_log_add_detail_text("EMAIL_SUBJECT",dn_line)
    FOR (dn_cnt = 1 TO dnotify->body_cnt)
      SET dm2_process_event_rs->detail_cnt = (dm2_process_event_rs->detail_cnt+ 1)
      SET stat = alterlist(dm2_process_event_rs->details,dm2_process_event_rs->detail_cnt)
      SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_type = "BODY"
      SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_text = trim(
       substring(1,1500,dnotify->body[dn_cnt].txt))
      SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_number = dn_cnt
    ENDFOR
    IF (dm2_process_log_row(dpl_package_install,dpl_auditlog,dpl_no_prev_id,0)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET dnotify->email_subject = "DM2NOTSET"
   SET dnotify->process = "DM2NOTSET"
   SET dnotify->install_status = "DM2NOTSET"
   SET dnotify->event = "DM2NOTSET"
   SET dnotify->msgtype = "DM2NOTSET"
   SET stat = alterlist(dnotify->body,0)
   SET dnotify->body_cnt = 0
   IF (dn_error_reset_ind=1)
    CALL dn_reset_pre_err(dn_emsg,dn_eproc,dn_user_action)
   ENDIF
   SET dnotify->test_single_ind = 0
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dn_add_body_text(dabt_in_text,dabt_in_reset_ind)
   IF (dabt_in_reset_ind=1)
    SET dnotify->body_cnt = 1
    SET stat = alterlist(dnotify->body,1)
    SET dnotify->body[dnotify->body_cnt].txt = dabt_in_text
   ELSE
    SET dnotify->body_cnt = (dnotify->body_cnt+ 1)
    SET stat = alterlist(dnotify->body,dnotify->body_cnt)
    SET dnotify->body[dnotify->body_cnt].txt = dabt_in_text
   ENDIF
 END ;Subroutine
 SUBROUTINE dn_reset_pre_err(drpe_emsg,drpe_eproc,drpe_user_action)
   SET dm_err->err_ind = 1
   SET dm_err->emsg = drpe_emsg
   SET dm_err->eproc = drpe_eproc
   SET dm_err->user_action = drpe_user_action
 END ;Subroutine
 DECLARE dipma_check_db_arch_mode(null) = i2
 DECLARE dipma_get_arch_dest_space(io_destination=vc(ref),io_space=f8(ref)) = i2
 DECLARE dipma_get_arch_thresholds(io_pause_val=f8(ref),io_notify_val=f8(ref)) = i2
 DECLARE dipma_get_two_dec(i_value=vc) = vc
 SUBROUTINE dipma_get_two_dec(i_value)
   DECLARE dgtd_temp_str = vc WITH protect, noconstant(" ")
   DECLARE dgtd_dec_pos = i4 WITH protect, noconstant(0)
   SET dgtd_temp_str = i_value
   SET dgtd_dec_pos = findstring(".",dgtd_temp_str,1,0)
   IF (dgtd_dec_pos=0)
    SET dgtd_temp_str = trim(concat(trim(dgtd_temp_str),".00"))
   ELSE
    SET dgtd_temp_str = trim(substring(1,(dgtd_dec_pos+ 2),dgtd_temp_str))
   ENDIF
   RETURN(dgtd_temp_str)
 END ;Subroutine
 SUBROUTINE dipma_get_arch_thresholds(io_pause_val,io_notify_val)
   SET dm_err->eproc = "Obtain archivelog monitor settings from dm_info"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_INSTALL_MONITOR:ARCHLOG"
     AND di.info_name="SETTINGS"
    DETAIL
     io_notify_val = di.info_number, io_pause_val = di.info_long_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dipma_get_arch_dest_space(io_destination,io_space)
   DECLARE dgads_qual_cnt = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Obtain archivelog destination from v$archive_dest"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM v$archive_dest ad
    WHERE ad.status="VALID"
     AND ad.target="PRIMARY"
    DETAIL
     dgads_qual_cnt = (dgads_qual_cnt+ 1), io_destination = ad.destination
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dgads_qual_cnt > 1)
    SET io_destination = "Multiple destinations"
   ENDIF
   SET dm_err->eproc = "Obtain current archive space used from v$archvied_log"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    y = sum(((((blocks * block_size)/ 1024)/ 1024)/ 1024))
    FROM v$archived_log al
    WHERE al.dest_id IN (
    (SELECT
     ad.dest_id
     FROM v$archive_dest ad
     WHERE ad.status="VALID"
      AND ad.target="PRIMARY"))
     AND al.deleted="NO"
    DETAIL
     io_space = y
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dipma_check_db_arch_mode(null)
   SET dm_err->eproc = "Check to see if v$database.log_mode = 'ARCHIVELOG'"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM v$database db
    WHERE db.log_mode="ARCHIVELOG"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 IF ((validate(dm2scramble->method_flag,- (99))=- (99))
  AND validate(dm2scramble->method_flag,511)=511)
  FREE RECORD dm2scramble
  RECORD dm2scramble(
    01 method_flag = i2
    01 mode_ind = i2
    01 in_text = vc
    01 out_text = vc
  )
  SET dm2scramble->method_flag = 0
 ENDIF
 DECLARE ds_scramble_init(null) = i2
 DECLARE ds_scramble(null) = i2
 SUBROUTINE ds_scramble_init(null)
   SET dm_err->eproc = "Initializing scramble dm_info data"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=dpl_ads_metadata
     AND di.info_name=dpl_ads_scramble_method
    DETAIL
     dm2scramble->method_flag = di.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = "Inserting scramble initialization row into dm_info"
    INSERT  FROM dm_info di
     SET di.info_domain = dpl_ads_metadata, di.info_name = dpl_ads_scramble_method, di.info_number =
      dm2scramble->method_flag
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ds_scramble(null)
   DECLARE dss_cnt = i4 WITH protect, noconstant(0)
   DECLARE dss_char = vc WITH protect, noconstant("")
   DECLARE dss_init = i2 WITH protect, noconstant(0)
   DECLARE dss_num = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = concat("Beginning scramble operation with Method: ",build(dm2scramble->
     method_flag)," and Mode: ",build(dm2scramble->mode_ind))
   IF ((dm_err->debug_flag=511))
    CALL echo(build2("Input Text: ",dm2scramble->in_text))
   ENDIF
   IF ((dm2scramble->method_flag=0)
    AND (dm2scramble->in_text > ""))
    SET dm2scramble->out_text = ""
    IF ((dm2scramble->mode_ind=1))
     SET dm_err->eproc = "Encrypting In-Text"
     FOR (dss_cnt = 1 TO textlen(dm2scramble->in_text))
      SET dss_num = ichar(substring(dss_cnt,1,dm2scramble->in_text))
      IF (dss_num < 255
       AND dss_num > 0)
       IF (((dss_num > 43
        AND dss_num < 58) OR (((dss_num > 64
        AND dss_num < 91) OR (dss_num > 96
        AND dss_num < 123)) )) )
        SET dss_char = notrim(char((dss_num+ 1)))
        IF (dss_init=1)
         SET dm2scramble->out_text = dss_char
         SET dss_init = 0
        ELSE
         SET dm2scramble->out_text = notrim(concat(dm2scramble->out_text,dss_char))
        ENDIF
       ELSE
        IF (dss_init=1)
         SET dm2scramble->out_text = substring(dss_cnt,1,dm2scramble->in_text)
         SET dss_init = 0
        ELSE
         SET dm2scramble->out_text = notrim(concat(dm2scramble->out_text,substring(dss_cnt,1,
            dm2scramble->in_text)))
        ENDIF
       ENDIF
      ENDIF
     ENDFOR
    ELSEIF ((dm2scramble->mode_ind=0))
     SET dm_err->eproc = "Decrypting In-Text"
     SET dss_init = 1
     FOR (dss_cnt = 1 TO textlen(dm2scramble->in_text))
      SET dss_num = ichar(substring(dss_cnt,1,dm2scramble->in_text))
      IF (dss_num < 255
       AND dss_num > 0)
       IF (((dss_num > 44
        AND dss_num < 59) OR (((dss_num > 65
        AND dss_num < 92) OR (dss_num > 97
        AND dss_num < 124)) )) )
        SET dss_char = notrim(char((dss_num - 1)))
        IF (dss_init=1)
         SET dm2scramble->out_text = dss_char
         SET dss_init = 0
        ELSE
         SET dm2scramble->out_text = notrim(concat(dm2scramble->out_text,dss_char))
        ENDIF
       ELSE
        IF (dss_init=1)
         SET dm2scramble->out_text = substring(dss_cnt,1,dm2scramble->in_text)
         SET dss_init = 0
        ELSE
         SET dm2scramble->out_text = notrim(concat(dm2scramble->out_text,substring(dss_cnt,1,
            dm2scramble->in_text)))
        ENDIF
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   ELSE
    SET dm2scramble->out_text = dm2scramble->in_text
   ENDIF
   SET dm2scramble->out_text = check(dm2scramble->out_text," ")
   IF ((dm_err->debug_flag=511))
    CALL echo(build2("Output Text: ",dm2scramble->out_text))
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE dad_get_admin_conn(i_conn_info=vc(ref)) = i2
 SUBROUTINE dad_get_admin_conn(i_conn_info)
   IF (ds_scramble_init(null)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Obtain admin connection info"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT
    IF (currdbuser="CDBA")
     FROM dm_info di
    ELSE
     FROM dm2_admin_dm_info di
    ENDIF
    INTO "nl:"
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="ADMIN_CONNECT_STRING"
    DETAIL
     dm2scramble->in_text = di.info_char, dm2scramble->mode_ind = 0
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Could not retrieve ADMIN connect information"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(2)
   ENDIF
   IF (ds_scramble(null)=0)
    RETURN(0)
   ENDIF
   SET i_conn_info = dm2scramble->out_text
   RETURN(1)
 END ;Subroutine
 IF ((validate(dum_utc_data->uptime_run_id,- (999))=- (999)))
  FREE RECORD dum_utc_data
  RECORD dum_utc_data(
    1 schema_date = dq8
    1 uptime_run_id = f8
    1 downtime_run_id = f8
    1 appl_id = vc
    1 in_process = i2
    1 status = vc
    1 status_desc = vc
    1 schema_changed = i2
    1 offset = i4
    1 dst_ind = i2
    1 mig_utc_pkg_instll_ind = i2
  )
  SET dum_utc_data->uptime_run_id = 0.0
  SET dum_utc_data->downtime_run_id = 0.0
  SET dum_utc_data->appl_id = "DM2NOTSET"
  SET dum_utc_data->in_process = 0
  SET dum_utc_data->status = "DM2NOTSET"
  SET dum_utc_data->status_desc = "DM2NOTSET"
  SET dum_utc_data->schema_changed = 0
  SET dum_utc_data->offset = 0
  SET dum_utc_data->dst_ind = 0
  SET dum_utc_data->mig_utc_pkg_instll_ind = 0
 ENDIF
 IF ((validate(dus_dst_accept->cnt,- (999))=- (999)))
  FREE RECORD dus_dst_accept
  RECORD dus_dst_accept(
    1 cnt = i4
    1 start_year = i4
    1 end_year = i4
    1 method = vc
    1 qual[*]
      2 year = vc
      2 start_dt_tm = dq8
      2 end_dt_tm = dq8
  )
  SET dus_dst_accept->method = "DM2NOTSET"
 ENDIF
 IF ((validate(dus_user_list->own_cnt,- (1))=- (1))
  AND (validate(dus_user_list->own_cnt,- (2))=- (2)))
  FREE RECORD dus_user_list
  RECORD dus_user_list(
    1 own_cnt = i2
    1 own[*]
      2 owner_name = vc
    1 cnt = i2
    1 qual[*]
      2 owner_name = vc
      2 table_name = vc
  )
  SET dus_user_list->own_cnt = 0
  SET dus_user_list->cnt = 0
 ENDIF
 IF ((validate(dum_utc_invalid_tables->cnt,- (999))=- (999)))
  FREE RECORD dum_utc_invalid_tables
  RECORD dum_utc_invalid_tables(
    1 cnt = i4
    1 qual[*]
      2 table_name = vc
  )
  SET dum_utc_invalid_tables->cnt = 0
 ENDIF
 IF ((validate(dus_std_convert_list->tbl_cnt,- (999))=- (999)))
  FREE RECORD dus_std_convert_list
  RECORD dus_std_convert_list(
    1 tbl_cnt = i2
    1 tbl[*]
      2 table_name = vc
      2 col_cnt = i4
      2 col[*]
        3 column_name = vc
        3 no_convert_ind = i2
  )
  SET dus_std_convert_list->tbl_cnt = 0
 ENDIF
 IF ((validate(dus_date_cols->cnt,- (999))=- (999)))
  FREE RECORD dus_date_cols
  RECORD dus_date_cols(
    1 cnt = i4
    1 qual[*]
      2 tbl_name = vc
      2 col_name = vc
      2 tbl_col_name = vc
      2 dt_type_flag = i2
  )
  SET dus_date_cols->cnt = 0
 ENDIF
 IF ((validate(dus_adm_date_cols->cnt,- (999))=- (999)))
  FREE RECORD dus_adm_date_cols
  RECORD dus_adm_date_cols(
    1 cnt = i4
    1 qual[*]
      2 tbl_name = vc
      2 col_name = vc
      2 tbl_col_name = vc
      2 dt_type_flag = i2
  )
  SET dus_adm_date_cols->cnt = 0
 ENDIF
 IF ((validate(dus_v500_cust->tbl_cnt,- (999))=- (999)))
  FREE RECORD dus_v500_cust
  RECORD dus_v500_cust(
    1 tbl_cnt = i4
    1 tbl[*]
      2 table_name = vc
  )
  SET dus_v500_cust->tbl_cnt = 0
 ENDIF
 DECLARE dum_check_concurrent_snapshot(dcc_mode=c1) = i2
 DECLARE dum_generate_schema_execution_script(dgs_run_id=f8,dgs_pswd=vc,dgs_constr=vc,dgs_file_name=
  vc(ref)) = i2
 DECLARE dum_stop_conversion_runner(dsc_appl_id=vc) = i2
 DECLARE dum_cleanup_stranded_appl_id(null) = i2
 DECLARE dum_check_for_new_run_id(dcf_run_id=f8,dcf_new_id_fnd=i2(ref),dcf_dbname=vc) = i2
 DECLARE dum_auto_dst_date(dadd_beg_year=i4,dadd_end_year=i4) = i2
 DECLARE dum_gen_auto_dst_file(null) = i2
 DECLARE dum_disp_dst_rpt(null) = i2
 DECLARE dum_set_timezone(dst_timezone_name=vc(ref)) = i2
 DECLARE dum_fill_user_list(dful_dbname=vc) = i2
 DECLARE ducm_status_chk(dsc_dbname=vc) = i2
 DECLARE dus_load_spec_cols(dlsc_dbname=vc) = i2
 DECLARE dum_mng_spec_cols(dmsc_dbname=vc) = i2
 DECLARE dum_load_date_columns(dldc_mode=vc,dldc_dbname=vc) = i2
 DECLARE dum_fill_v500_cust(dfvc_dbname=vc) = i2
 DECLARE dum_cust_incl_abort_gen(dciag_tgt_dbname=vc,dciag_src_orcl_ver=vc,dciag_tgt_orcl_ver=vc) =
 i2
 DECLARE dum_daylight_offset = i4 WITH protect, noconstant(0)
 DECLARE dum_offset_sign = c1 WITH protect, noconstant(" ")
 SUBROUTINE dum_check_concurrent_snapshot(dcc_mode)
   DECLARE dcc_appl_id = vc WITH protect, noconstant(" ")
   DECLARE dcc_appl_status = vc WITH protect, noconstant(" ")
   IF (cnvtupper(dcc_mode)="I")
    SET dm_err->eproc = "Determining if another upgrade process is running."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DM2 INSTALL PROCESS"
      AND di.info_name="CONCURRENCY CHECKPOINT"
     DETAIL
      dcc_appl_id = di.info_char
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual > 0)
     IF ((dcc_appl_id=dum_utc_data->appl_id))
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
      SET dcc_appl_status = dm2_get_appl_status(dcc_appl_id)
      IF (dcc_appl_status="E")
       RETURN(0)
      ELSE
       IF (dcc_appl_status="A")
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
    SET is_snapshot_dt_tm = cnvtdatetime(curdate,curtime3)
    IF ((dm_err->debug_flag > 0))
     CALL echo(build("Time of snapshot = ",format(is_snapshot_dt_tm,"mm/dd/yyyy hh:mm:ss;;d")))
    ENDIF
    SET dm_err->eproc = "Inserting concurrency row in dm_info."
    CALL disp_msg(" ",dm_err->logfile,0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2 INSTALL PROCESS", di.info_name = "CONCURRENCY CHECKPOINT", di
      .info_char = currdbhandle,
      di.info_date = cnvtdatetime(is_snapshot_dt_tm), di.updt_applctx = 0, di.updt_cnt = 0,
      di.updt_id = 0, di.updt_task = 0
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
 SUBROUTINE dum_generate_schema_execution_script(dgs_run_id,dgs_pswd,dgs_constr,dgs_file_name)
   DECLARE dgs_file_loc = vc WITH protect, noconstant(" ")
   DECLARE dgs_str1 = vc WITH protect, noconstant(" ")
   DECLARE dgs_str2 = vc WITH protect, noconstant(" ")
   DECLARE dgs_str3 = vc WITH protect, noconstant(" ")
   DECLARE dgs_str4 = vc WITH protect, noconstant(" ")
   DECLARE dgs_str5 = vc WITH protect, noconstant(" ")
   DECLARE dgs_str6 = vc WITH protect, constant(logical("cer_exe"))
   DECLARE dgs_debug_flag = vc WITH protect, noconstant(" ")
   DECLARE dgs_rdbdebug_flag = i2 WITH protect, noconstant(0)
   DECLARE dgs_rdbbind_flag = i2 WITH protect, noconstant(0)
   SET dgs_rdbdebug_flag = trace("RDBDEBUG")
   SET dgs_rdbbind_flag = trace("RDBBIND")
   IF (cursys="AIX")
    SET dgs_file_name = build("ccluserdir:dm2_utc_main_runner_runid",cnvtint(dgs_run_id),".ksh")
   ELSEIF (cursys="AXP")
    SET dgs_file_name = build("ccluserdir:dm2_utc_main_runner_runid",cnvtint(dgs_run_id),".com")
   ENDIF
   SET dgs_debug_flag = cnvtstring(dm_err->debug_flag)
   SET dm_err->eproc = concat("Generate script ",dgs_file_name)
   CALL disp_msg("",dm_err->logfile,0)
   FREE SET dgs_file_loc
   SET logical dgs_file_loc value(dgs_file_name)
   SELECT INTO dgs_file_loc
    FROM (dummyt t  WITH seq = 1)
    DETAIL
     dgs_str1 = concat("Executing schema for run id ",cnvtstring(dgs_run_id)), dgs_str2 =
     "free define oraclesystem go"
     IF (dgs_constr > " ")
      dgs_str3 = concat("define oraclesystem 'v500/",dgs_pswd,"@",dgs_constr,"' go")
     ELSE
      dgs_str3 = concat("define oraclesystem 'v500/",dgs_pswd,"' go")
     ENDIF
     dgs_str4 = concat("execute dm2_utc_execute_schema ",cnvtstring(dgs_run_id)," go")
     IF (cursys="AIX")
      col 0, "#!/usr/bin/ksh", row + 1,
      col 0, "#", row + 1,
      dgs_str5 = concat("# ",trim(dgs_str1)), col 0, dgs_str5,
      row + 1, col 0, "#",
      row + 1, col 0, ". $cer_mgr/",
      CALL print(trim(cnvtlower(logical("environment")))), "_environment.ksh", row + 1,
      col 0, "ccl <<!", row + 1,
      col 0, dgs_str2, row + 1,
      col 0, dgs_str3, row + 1,
      col 0, "set dm2_debug_flag = ", dgs_debug_flag,
      " go", row + 1
      IF (dgs_rdbdebug_flag=1)
       col 0, "set trace rdbdebug go", row + 1
      ENDIF
      IF (dgs_rdbbind_flag=1)
       col 0, "set trace rdbbind go", row + 1
      ENDIF
      row + 1, col 0, "set dm2_utc_process_option = '",
      dm2_install_schema->process_option, "' go", row + 1,
      col 0, dgs_str4, row + 1,
      col 0, dgs_str2, row + 1,
      col 0, "exit", row + 1,
      col 0, "!", row + 1,
      col 0, "sleep 30"
     ELSEIF (cursys="AXP")
      col 0, "$!", row + 1,
      dgs_str5 = concat("$! ",trim(dgs_str1)), col 0, dgs_str5,
      row + 1, col 0, "$!",
      row + 1, col 0, '$CCL :== "$CER_EXE:CCLORA.EXE"',
      row + 1, col 0, "$CCL",
      row + 1, col 0, dgs_str2,
      row + 1, col 0, dgs_str3,
      row + 1, col 0, "set dm2_debug_flag = ",
      dgs_debug_flag, " go", row + 1
      IF (dgs_rdbdebug_flag=1)
       col 0, "set trace rdbdebug go", row + 1
      ENDIF
      IF (dgs_rdbbind_flag=1)
       col 0, "set trace rdbbind go", row + 1
      ENDIF
      row + 1, col 0, "set dm2_utc_process_option = '",
      dm2_install_schema->process_option, "' go", row + 1,
      col 0, dgs_str4, row + 1,
      col 0, "exit", row + 1,
      col 0, "$WAIT 00:00:30"
     ENDIF
    FOOT REPORT
     row + 0
    WITH nocounter, maxrow = 1, format = variable,
     formfeed = none
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_stop_conversion_runner(dsc_appl_id)
   SET dm_err->eproc = concat("Stop conversion runners ",dsc_appl_id)
   CALL disp_msg("",dm_err->logfile,0)
   DECLARE dsc_runner_active = i2 WITH protect, noconstant(0)
   DECLARE dsc_app_str = vc WITH protect, noconstant(" ")
   DECLARE dsc_app_status = c1 WITH protect, noconstant(" ")
   IF ( NOT (dsc_appl_id IN ("ALL", "PARALLEL", "MAIN")))
    SET dsc_app_status = dm2_get_appl_status(dsc_appl_id)
    IF (dsc_app_status="I")
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Stop conversion runners ",dsc_appl_id)
     SET dm_err->emsg = concat("Application ID ",dsc_appl_id," passed in is inactive.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (dsc_app_status="E")
     RETURN(0)
    ENDIF
   ENDIF
   IF (dsc_appl_id="ALL")
    SET dm_err->eproc = "Get application ids need to be inactivated for all UTC conversion runners."
    SELECT INTO "nl:"
     d.info_name
     FROM dm_info d
     WHERE d.info_domain="DM2_UTC_SCHEMA_RUNNER"
     HEAD REPORT
      row + 0
     DETAIL
      dsc_app_str = concat(dsc_app_str,"'",trim(d.info_name),"',")
     FOOT REPORT
      dsc_app_str = replace(dsc_app_str,",","",2)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (curqual=0)
     RETURN(1)
    ENDIF
    SET dm_err->eproc = "Inactivate application ids for all UTC conversion runners."
    UPDATE  FROM dm_info di
     SET di.info_number = 0
     WHERE di.info_domain="DM2_UTC_SCHEMA_RUNNER"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ELSEIF (dsc_appl_id="PARALLEL")
    SET dm_err->eproc =
    "Get application ids need to be inactivated for parallel UTC conversion runners."
    SELECT INTO "nl:"
     d.info_name
     FROM dm_info d
     WHERE d.info_domain="DM2_UTC_SCHEMA_RUNNER"
      AND d.info_char="PARALLEL_RUNNER"
     HEAD REPORT
      row + 0
     DETAIL
      dsc_app_str = concat(dsc_app_str,"'",trim(d.info_name),"',")
     FOOT REPORT
      dsc_app_str = replace(dsc_app_str,",","",2)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (curqual=0)
     RETURN(1)
    ENDIF
    SET dm_err->eproc = "Inactivate application ids for parallel UTC conversion runners."
    UPDATE  FROM dm_info di
     SET di.info_number = 0
     WHERE di.info_domain="DM2_UTC_SCHEMA_RUNNER"
      AND di.info_char="PARALLEL_RUNNER"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ELSEIF (dsc_appl_id="MAIN")
    SET dm_err->eproc = "Get application ids need to be inactivated for main UTC conversion runners."
    SELECT INTO "nl:"
     d.info_name
     FROM dm_info d
     WHERE d.info_domain="DM2_UTC_SCHEMA_RUNNER"
      AND d.info_char="MAIN_RUNNER"
     HEAD REPORT
      row + 0
     DETAIL
      dsc_app_str = concat(dsc_app_str,"'",trim(d.info_name),"',")
     FOOT REPORT
      dsc_app_str = replace(dsc_app_str,",","",2)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (curqual=0)
     RETURN(1)
    ENDIF
    SET dm_err->eproc = "Inactivate application ids for main UTC conversion runners."
    UPDATE  FROM dm_info di
     SET di.info_number = 0
     WHERE di.info_domain="DM2_UTC_SCHEMA_RUNNER"
      AND di.info_char="MAIN_RUNNER"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ELSE
    SET dm_err->eproc = "Get application id need to be inactivated."
    SELECT INTO "nl:"
     d.info_name
     FROM dm_info d
     WHERE d.info_domain="DM2_UTC_SCHEMA_RUNNER"
      AND d.info_name=dsc_appl_id
     HEAD REPORT
      row + 0
     DETAIL
      dsc_app_str = concat(dsc_app_str,"'",trim(d.info_name),"',")
     FOOT REPORT
      dsc_app_str = replace(dsc_app_str,",","",2)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (curqual=0)
     RETURN(1)
    ENDIF
    SET dm_err->eproc = concat("Inactivate application id ",dsc_appl_id,".")
    UPDATE  FROM dm_info di
     SET di.info_number = 0
     WHERE di.info_domain="DM2_UTC_SCHEMA_RUNNER"
      AND di.info_name=dsc_appl_id
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   SET dsc_runner_active = 1
   WHILE (dsc_runner_active=1)
     IF (dum_cleanup_stranded_appl_id(null)=0)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = concat("Verify application id ",dsc_app_str," have been removed.")
     SELECT INTO "nl:"
      FROM dm_info di
      WHERE di.info_domain="DM2_UTC_SCHEMA_RUNNER"
       AND parser(concat("di.info_name in (",dsc_app_str,")"))
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (curqual > 0)
      CALL echo("**************************************************")
      CALL echo(
       "Waiting on current DDL operations the conversion runner(s) is working on to finish executing..."
       )
      CALL echo("**************************************************")
      CALL pause(15)
     ELSE
      SET dsc_runner_active = 0
     ENDIF
   ENDWHILE
   IF (dsc_appl_id IN ("ALL", "PARALLEL", "MAIN"))
    SET dm_err->eproc = concat("Stopped ",dsc_appl_id," UTC conversion runners successfully.")
   ELSE
    SET dm_err->eproc = concat("Stopped UTC conversion runner with application id ",dsc_appl_id,
     " successfully.")
   ENDIF
   CALL disp_msg("",dm_err->logfile,0)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_cleanup_stranded_appl_id(null)
   SET dm_err->eproc = "Remove inactive application id for UTC Conversion runners."
   CALL disp_msg("",dm_err->logfile,0)
   FREE RECORD dcs_app
   RECORD dcs_app(
     1 cnt = i4
     1 qual[*]
       2 app_id = vc
       2 active_ind = i2
   )
   DECLARE dcs_app_status = c1 WITH protect, noconstant(" ")
   DECLARE dcs_inactive_fnd = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Query dm_info for a distinct list of application ids."
   SELECT DISTINCT INTO "nl:"
    di.info_name
    FROM dm_info di
    WHERE di.info_domain="DM2_UTC_SCHEMA_RUNNER"
    HEAD REPORT
     dcs_app->cnt = 0
    DETAIL
     dcs_app->cnt = (dcs_app->cnt+ 1)
     IF (mod(dcs_app->cnt,10)=1)
      stat = alterlist(dcs_app->qual,(dcs_app->cnt+ 9))
     ENDIF
     dcs_app->qual[dcs_app->cnt].app_id = trim(di.info_name), dcs_app->qual[dcs_app->cnt].active_ind
      = 0
    FOOT REPORT
     stat = alterlist(dcs_app->qual,dcs_app->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   FOR (dcs_i = 1 TO dcs_app->cnt)
    SET dcs_app_status = dm2_get_appl_status(dcs_app->qual[dcs_i].app_id)
    IF (dcs_app_status="A")
     SET dcs_app->qual[dcs_i].active_ind = 1
    ELSEIF (dcs_app_status="I")
     SET dcs_inactive_fnd = 1
    ELSEIF (dcs_app_status="E")
     RETURN(0)
    ENDIF
   ENDFOR
   IF (dcs_inactive_fnd=1)
    SET dm_err->eproc = "Delete inactive application id from DM_INFO table."
    DELETE  FROM dm_info di,
      (dummyt t  WITH seq = value(dcs_app->cnt))
     SET di.seq = 1
     PLAN (t
      WHERE (dcs_app->qual[t.seq].active_ind=0))
      JOIN (di
      WHERE di.info_domain="DM2_UTC_SCHEMA_RUNNER"
       AND (di.info_name=dcs_app->qual[t.seq].app_id))
     WITH nocounter
    ;end delete
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_check_for_new_run_id(dcf_run_id,dcf_new_id_fnd,dcf_dbname)
   DECLARE dcf_max_run_id = f8 WITH protect, noconstant(0.0)
   SET dcf_new_id_fnd = 0
   SET dm_err->eproc = build("Find max run_id that is greater than ",dcf_run_id,
    " in DM2_DDL_OPS table.")
   SELECT
    IF ((dm2_install_schema->process_option="MIGRATION/UTC"))
     FROM dm2_ddl_ops@ref_data_link d
     ORDER BY d.run_id
    ELSE
     FROM dm2_ddl_ops d
     WHERE d.run_id > dcf_run_id
     ORDER BY d.run_id
    ENDIF
    INTO "nl:"
    HEAD REPORT
     row + 0
    FOOT REPORT
     dcf_max_run_id = d.run_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dm_err->eproc = "Determine if new_run_id is found."
    SELECT INTO "nl:"
     FROM dm2_admin_dm_info di
     WHERE di.info_domain=patstring(cnvtupper(build(dcf_dbname,"_UTC_DATA")))
      AND di.info_name="POST_UTC_RUN_IDS"
      AND di.info_number >= dcf_max_run_id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET dcf_new_id_fnd = 1
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_auto_dst_date(dadd_beg_year,dadd_end_year)
   DECLARE dadd_spr_beg_month = vc WITH protect, constant("MAR")
   DECLARE dadd_spr_end_month = i2 WITH protect, constant(6)
   DECLARE dadd_fall_beg_month = vc WITH protect, constant("SEP")
   DECLARE dadd_fall_end_month = i2 WITH protect, constant(12)
   DECLARE dadd_continue = i2 WITH protect, noconstant(0)
   DECLARE dadd_loop = i2 WITH protect, noconstant(0)
   DECLARE dadd_fnd_dst_beg = i2 WITH protect, noconstant(0)
   DECLARE dadd_fnd_dst_end = i2 WITH protect, noconstant(0)
   DECLARE dadd_temp_year = i2 WITH protect, noconstant(0)
   DECLARE dadd_beg_date = dq8 WITH protect, noconstant(0.0)
   DECLARE dadd_end_date = dq8 WITH protect, noconstant(0.0)
   DECLARE dadd_hr1 = i2 WITH protect, noconstant(0)
   DECLARE dadd_hr2 = i2 WITH protect, noconstant(0)
   SET dus_dst_accept->cnt = 0
   SET stat = alterlist(dus_dst_accept->qual,0)
   SET dus_dst_accept->start_year = dadd_beg_year
   SET dus_dst_accept->end_year = dadd_end_year
   SET dus_dst_accept->method = "AUTO_DETECT"
   SET dadd_continue = 1
   SET dadd_temp_year = dadd_beg_year
   SET dm_err->eproc = "Auto detecting DST datetime range."
   IF ((dm_err->debug_flag > 0))
    SET message = nowindow
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   WHILE (dadd_continue=1)
     IF ((dm_err->debug_flag > 0))
      CALL echo("-----------------------------------------------------------------")
      CALL echo(concat(trim(cnvtstring(dadd_temp_year)),"..."))
     ENDIF
     SET dadd_loop = 1
     SET dadd_fnd_dst_beg = 0
     SET dadd_beg_date = cnvtdatetime(build("01-",trim(dadd_spr_beg_month),"-",dadd_temp_year,
       " 00:00:00"))
     WHILE (dadd_loop=1)
      IF (cnvtdatetimeutc(dadd_beg_date,3)=cnvtdatetimeutc(cnvtlookahead("1,H",cnvtdatetimeutc(
         dadd_beg_date,0)),3))
       SET dadd_fnd_dst_beg = 1
       SET dadd_loop = 0
       IF ((dm_err->debug_flag > 0))
        CALL echo(concat("  Local Start Date: ",format(cnvtdatetime(dadd_beg_date),";;q")))
        CALL echo(concat("  Local Start Date (UTC): ",format(cnvtdatetimeutc(dadd_beg_date,3),";;q"))
         )
        CALL echo(concat("  Local Start Date +1 hour (UTC): ",format(cnvtdatetimeutc(cnvtlookahead(
             "1,H",cnvtdatetimeutc(dadd_beg_date,0)),3),";;q")))
       ENDIF
       SET dadd_beg_date = cnvtlookahead("1,H",cnvtdatetimeutc(dadd_beg_date,0))
      ENDIF
      IF (dadd_fnd_dst_beg=0)
       SET dadd_beg_date = cnvtlookahead("1,H",cnvtdatetimeutc(dadd_beg_date,0))
       IF (month(dadd_beg_date)=dadd_spr_end_month)
        SET dadd_loop = 0
       ENDIF
      ENDIF
     ENDWHILE
     SET dadd_loop = 1
     SET dadd_fnd_dst_end = 0
     SET dadd_end_date = cnvtdatetime(build("02-",trim(dadd_fall_beg_month),"-",dadd_temp_year,
       " 00:00:00"))
     IF (dadd_fnd_dst_beg=1)
      WHILE (dadd_loop=1)
        SET dadd_hr1 = hour(cnvtdatetimeutc(cnvtlookahead("1,H",cnvtdatetimeutc(dadd_end_date,0)),3))
        SET dadd_hr2 = hour(cnvtdatetimeutc(dadd_end_date,3))
        IF (((dadd_hr1 - dadd_hr2)=2))
         SET dadd_fnd_dst_end = 1
         SET dadd_loop = 0
         IF ((dm_err->debug_flag > 0))
          CALL echo(concat("  Local End Date: ",format(cnvtdatetime(dadd_end_date),";;q")))
          CALL echo(concat("  Local End Date (UTC): ",format(cnvtdatetimeutc(dadd_end_date,3),";;q"))
           )
          CALL echo(concat("  Local End Date +1 hour (UTC): ",format(cnvtdatetimeutc(cnvtlookahead(
               "1,H",cnvtdatetimeutc(dadd_end_date,0)),3),";;q")))
         ENDIF
         SET dadd_end_date = cnvtlookahead("1,H",cnvtdatetimeutc(dadd_end_date,0))
         SET dadd_end_date = cnvtlookbehind("1,S",cnvtdatetimeutc(dadd_end_date,0))
        ENDIF
        IF (dadd_fnd_dst_end=0)
         SET dadd_end_date = cnvtlookahead("1,H",cnvtdatetimeutc(dadd_end_date,0))
         IF (month(dadd_end_date)=dadd_fall_end_month)
          SET dadd_loop = 0
         ENDIF
        ENDIF
      ENDWHILE
     ENDIF
     IF (dadd_fnd_dst_beg=1
      AND dadd_fnd_dst_end=1)
      SET dus_dst_accept->cnt = (dus_dst_accept->cnt+ 1)
      SET stat = alterlist(dus_dst_accept->qual,dus_dst_accept->cnt)
      SET dus_dst_accept->qual[dus_dst_accept->cnt].year = trim(cnvtstring(dadd_temp_year))
      SET dus_dst_accept->qual[dus_dst_accept->cnt].start_dt_tm = dadd_beg_date
      SET dus_dst_accept->qual[dus_dst_accept->cnt].end_dt_tm = dadd_end_date
      IF ((dm_err->debug_flag > 0))
       CALL echo(concat(trim(cnvtstring(dadd_temp_year)),"...DST starts at ",format(cnvtdatetime(
           dadd_beg_date),";;q")," and ends at ",format(cnvtdatetime(dadd_end_date),";;q")))
      ENDIF
     ELSEIF (dadd_fnd_dst_beg=0
      AND dadd_fnd_dst_end=0)
      IF ((dm_err->debug_flag > 0))
       CALL echo(concat(trim(cnvtstring(dadd_temp_year)),"...did not observe DST during this year"))
      ENDIF
     ELSE
      SET dm_err->err_ind = 1
      SET dm_err->emsg = concat("Failed to find DST end datetime for year ",trim(cnvtstring(
         dadd_temp_year))," when DST begin datetime is found.")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (dadd_temp_year=dadd_end_year)
      SET dadd_continue = 0
     ELSE
      SET dadd_temp_year = (dadd_temp_year+ 1)
     ENDIF
   ENDWHILE
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(dus_dst_accept)
   ENDIF
   IF ((dus_dst_accept->cnt > 0))
    IF (dum_gen_auto_dst_file(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_gen_auto_dst_file(null)
   DECLARE dgadf_file_name = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dgadf_str = vc WITH protect, noconstant("")
   IF (get_unique_file("dm2_utc_dst_input",".dat")=0)
    RETURN(0)
   ENDIF
   SET dgadf_file_name = concat(dm2_install_schema->ccluserdir,dm_err->unique_fname)
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("file_name = ",dgadf_file_name))
   ENDIF
   SET dm_err->eproc = concat("Generate file ",dgadf_file_name,".")
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO value(dgadf_file_name)
    FROM (dummyt t  WITH seq = 1)
    HEAD REPORT
     cnt = 0
    DETAIL
     col 0, "YEAR,START_DT_TM,END_DT_TM", row + 1
     FOR (cnt = 1 TO dus_dst_accept->cnt)
       dgadf_str = concat(dus_dst_accept->qual[cnt].year,",",format(cnvtdatetime(dus_dst_accept->
          qual[cnt].start_dt_tm),"DD-MMM-YYYY HH:MM:SS;;D"),",",format(cnvtdatetime(dus_dst_accept->
          qual[cnt].end_dt_tm),"DD-MMM-YYYY HH:MM:SS;;D"))
       IF ((dm_err->debug_flag > 0))
        CALL echo(dgadf_str)
       ENDIF
       col 0, dgadf_str, row + 1
     ENDFOR
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_disp_dst_rpt(dddr_timezone_name)
   DECLARE dddr_str = vc WITH protect, noconstant(" ")
   SET dm_err->eproc = "UTC Conversion Daylight Savings Time Setting Confirmation"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO mine
    FROM (dummyt d  WITH seq = value(dus_dst_accept->cnt))
    ORDER BY dus_dst_accept->qual[d.seq].year
    HEAD REPORT
     col 0, "UTC Conversion Daylight Savings Time Setting Confirmation", row + 2,
     col 0, "TIME ZONE : ", col 13,
     dddr_timezone_name, col 50, "STANDARD OFFSET : ",
     dddr_str = concat(dum_offset_sign,format(cnvttime(abs(dum_utc_data->offset)),"HH:MM;;M")), col
     68, dddr_str,
     row + 2, col 0,
     "Please scroll through each Daylight Savings Time (DST) begin and end date/times and review for accuracy.",
     row + 2, col 0, "YEAR",
     col 10, "DST Begin Date Time", col 40,
     "DST End Date Time", row + 1
    DETAIL
     col 0, dus_dst_accept->qual[d.seq].year, dddr_str = format(dus_dst_accept->qual[d.seq].
      start_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D"),
     col 10, dddr_str, dddr_str = format(dus_dst_accept->qual[d.seq].end_dt_tm,
      "DD-MMM-YYYY HH:MM:SS;;D"),
     col 40, dddr_str, row + 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_set_timezone(dst_timezone_name)
   SET dst_timezone_name = datetimezonebyindex(curtimezonesys,dum_utc_data->offset,
    dum_daylight_offset)
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("dst_timezone_name = ",dst_timezone_name))
   ENDIF
   IF (dst_timezone_name=" "
    AND (dum_utc_data->offset=0))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Failed to retrieve Time Zone Name."
    SET dm_err->emsg =
    "Problem with ccl version or the curtimezonesys variable does not have a valid timezone index."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    SET dum_utc_data->offset = ((dum_utc_data->offset/ 1000)/ 60)
    IF ((dum_utc_data->offset < 0))
     SET dum_offset_sign = "-"
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echo(build("offset = ",dum_utc_data->offset))
     CALL echo(concat(dum_offset_sign,format(cnvttime(abs(dum_utc_data->offset)),"HH:MM;;M")))
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_fill_user_list(dful_dbname)
   DECLARE dum_pos = i4 WITH protect, noconstant(0)
   DECLARE dum_loc = i4 WITH protect, noconstant(0)
   DECLARE dum_own_name = vc WITH protect, noconstant(" ")
   DECLARE dum_tbl_name = vc WITH protect, noconstant(" ")
   SET dus_user_list->own_cnt = 1
   SET stat = alterlist(dus_user_list->own,dus_user_list->own_cnt)
   SET dus_user_list->own[dus_user_list->own_cnt].owner_name = "V500"
   SET dm_err->eproc = "Loading Non-V500 Users and tables from dm_info."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info di
    WHERE di.info_domain=patstring(cnvtupper(build(dful_dbname,
       "_UTC_DATA - NON-V500 USERS AND TABLES LIST")))
    DETAIL
     dum_loc = findstring("/",di.info_name,1,1)
     IF (dum_loc=0)
      dm_err->err_ind = 1, dm_err->emsg =
      "Missing / in dm2_admin_dm_info row. Valid dm2_admin_dm_info row format is USER/TABLE.",
      CALL cancel(1)
     ENDIF
     dum_own_name = substring(1,(dum_loc - 1),di.info_name), dum_tbl_name = substring((dum_loc+ 1),
      size(di.info_name),di.info_name), dum_pos = 0,
     dum_pos = locateval(dum_pos,1,dus_user_list->own_cnt,trim(cnvtupper(dum_own_name)),dus_user_list
      ->own[dum_pos].owner_name)
     IF (dum_pos=0)
      dus_user_list->own_cnt = (dus_user_list->own_cnt+ 1), stat = alterlist(dus_user_list->own,
       dus_user_list->own_cnt), dus_user_list->own[dus_user_list->own_cnt].owner_name = dum_own_name
     ENDIF
     dus_user_list->cnt = (dus_user_list->cnt+ 1), stat = alterlist(dus_user_list->qual,dus_user_list
      ->cnt), dus_user_list->qual[dus_user_list->cnt].owner_name = dum_own_name,
     dus_user_list->qual[dus_user_list->cnt].table_name = dum_tbl_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(dus_user_list)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ducm_status_chk(dsc_dbname)
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info di
    WHERE di.info_domain=patstring(cnvtupper(build(dsc_dbname,"_UTC_DATA")))
     AND di.info_name="SOURCE*"
    DETAIL
     dsc_info_name = di.info_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Check for Source Environment/Database ADMIN dm_info row."
    SET dm_err->emsg = "Info_name for Source Environment/Database ADMIN dm_info row does not exist."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_load_spec_cols(dlsc_dbname)
   DECLARE dls_tbl_name = vc WITH protect, noconstant(" ")
   DECLARE dls_col_name = vc WITH protect, noconstant(" ")
   DECLARE dls_pos = i4 WITH protect, noconstant(0)
   DECLARE dls_tbl_idx = i4 WITH protect, noconstant(0)
   DECLARE dls_col_cnt = i4 WITH protect, noconstant(0)
   SET dus_std_convert_list->tbl_cnt = 0
   SET stat = alterlist(dus_std_convert_list->tbl,dus_std_convert_list->tbl_cnt)
   SET dm_err->eproc =
   "Load V500 table/columns requiring special conversion logic from ADMIN DM_INFO table to record."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info i
    WHERE i.info_domain=patstring(cnvtupper(build(dlsc_dbname,"_UTC_DATA - APPLY STD CONVERSION ONLY"
       )))
    HEAD REPORT
     dls_tbl_idx = 0
    DETAIL
     dls_pos = findstring("/",i.info_name,1,1), dls_tbl_name = substring(1,(dls_pos - 1),i.info_name),
     dls_col_name = substring((dls_pos+ 1),size(i.info_name),i.info_name),
     dls_tbl_idx = 0, dls_tbl_idx = locateval(dls_tbl_idx,1,dus_std_convert_list->tbl_cnt,
      dls_tbl_name,dus_std_convert_list->tbl[dls_tbl_idx].table_name)
     IF (dls_tbl_idx=0)
      dus_std_convert_list->tbl_cnt = (dus_std_convert_list->tbl_cnt+ 1)
      IF (mod(dus_std_convert_list->tbl_cnt,10)=1)
       stat = alterlist(dus_std_convert_list->tbl,(dus_std_convert_list->tbl_cnt+ 9))
      ENDIF
      dus_std_convert_list->tbl[dus_std_convert_list->tbl_cnt].table_name = dls_tbl_name,
      dus_std_convert_list->tbl[dus_std_convert_list->tbl_cnt].col_cnt = 1, stat = alterlist(
       dus_std_convert_list->tbl[dus_std_convert_list->tbl_cnt].col,1),
      dus_std_convert_list->tbl[dus_std_convert_list->tbl_cnt].col[1].column_name = dls_col_name,
      dus_std_convert_list->tbl[dus_std_convert_list->tbl_cnt].col[1].no_convert_ind = i.info_number
     ELSE
      dus_std_convert_list->tbl[dls_tbl_idx].col_cnt = (dus_std_convert_list->tbl[dls_tbl_idx].
      col_cnt+ 1), dls_col_cnt = dus_std_convert_list->tbl[dls_tbl_idx].col_cnt, stat = alterlist(
       dus_std_convert_list->tbl[dls_tbl_idx].col,dls_col_cnt),
      dus_std_convert_list->tbl[dls_tbl_idx].col[dls_col_cnt].column_name = dls_col_name,
      dus_std_convert_list->tbl[dls_tbl_idx].col[dls_col_cnt].no_convert_ind = i.info_number
     ENDIF
    FOOT REPORT
     stat = alterlist(dus_std_convert_list->tbl,dus_std_convert_list->tbl_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(dus_std_convert_list)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_mng_spec_cols(dmsc_dbname)
   FREE RECORD load_excl_cols
   RECORD load_excl_cols(
     1 cnt = i4
     1 qual[*]
       2 tbl_col_name = vc
       2 info_char = vc
       2 info_num = i2
   )
   DECLARE dmsc_idx = i4 WITH protect, noconstant(0)
   SET stat = alterlist(load_excl_cols->qual,0)
   SET load_excl_cols->cnt = 0
   SET dm_err->eproc = "Load Admin master V500 table/columns exclusions from ADMIN DM_INFO."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info di
    WHERE di.info_domain=patstring(cnvtupper(build(dmsc_dbname,"_UTC_DATA - MASTER DATE COLUMN LIST")
      ))
     AND di.info_number != 1
    HEAD REPORT
     load_excl_cols->cnt = 0
    DETAIL
     load_excl_cols->cnt = (load_excl_cols->cnt+ 1)
     IF (mod(load_excl_cols->cnt,1000)=1)
      stat = alterlist(load_excl_cols->qual,(load_excl_cols->cnt+ 999))
     ENDIF
     load_excl_cols->qual[load_excl_cols->cnt].tbl_col_name = di.info_name, load_excl_cols->qual[
     load_excl_cols->cnt].info_num = 1, load_excl_cols->qual[load_excl_cols->cnt].info_char =
     "LOADED FROM CSV"
    FOOT REPORT
     stat = alterlist(load_excl_cols->qual,load_excl_cols->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((load_excl_cols->cnt=0))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Verify load of Admin master date list.")
    SET dm_err->emsg = build("Admin master date list does not include any exclusion dates.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Load V500 table/columns exclusions from ADMIN DM_INFO."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info di
    WHERE di.info_domain=patstring(cnvtupper(build(dmsc_dbname,
       "_UTC_DATA - APPLY STD CONVERSION ONLY")))
    HEAD REPORT
     dmsc_idx = 0
    DETAIL
     dmsc_idx = 0, dmsc_idx = locateval(dmsc_idx,1,load_excl_cols->cnt,cnvtupper(di.info_name),
      load_excl_cols->qual[dmsc_idx].tbl_col_name)
     IF (dmsc_idx > 0)
      IF (di.info_number != 1)
       dm_err->err_ind = 1, dm_err->emsg = concat("Invalid Admin DM_INFO row for ",di.info_name,
        "Info_number should always be 1."),
       CALL cancel(1)
      ENDIF
     ELSE
      IF (cnvtupper(di.info_char) != "LOADED FROM CSV")
       load_excl_cols->cnt = (load_excl_cols->cnt+ 1), stat = alterlist(load_excl_cols->qual,
        load_excl_cols->cnt), load_excl_cols->qual[load_excl_cols->cnt].tbl_col_name = di.info_name,
       load_excl_cols->qual[load_excl_cols->cnt].info_num = di.info_number
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(load_excl_cols)
   ENDIF
   SET dm_err->eproc = "Deleting Exclusion rows from Admin DM_INFO."
   CALL disp_msg(" ",dm_err->logfile,0)
   DELETE  FROM dm2_admin_dm_info i
    WHERE i.info_domain=patstring(cnvtupper(build(dmsc_dbname,"_UTC_DATA - APPLY STD CONVERSION ONLY"
       )))
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc) != 0)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Inserting Exclusion rows into Admin DM_INFO."
   CALL disp_msg(" ",dm_err->logfile,0)
   INSERT  FROM dm2_admin_dm_info di,
     (dummyt d  WITH seq = value(size(load_excl_cols->qual,5)))
    SET di.info_domain = patstring(cnvtupper(build(dmsc_dbname,
        "_UTC_DATA - APPLY STD CONVERSION ONLY"))), di.info_name = load_excl_cols->qual[d.seq].
     tbl_col_name, di.info_number = load_excl_cols->qual[d.seq].info_num,
     di.info_char = load_excl_cols->qual[d.seq].info_char, di.updt_dt_tm = cnvtdatetime(curdate,
      curtime3)
    PLAN (d)
     JOIN (di
     WHERE (load_excl_cols->qual[d.seq].tbl_col_name=di.info_name))
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_load_date_columns(dldc_mode,dldc_dbname)
   DECLARE dvdc_csv_loc = vc WITH public, constant(concat(dm2_install_schema->cer_install,
     "dm2_date_column_list.csv"))
   DECLARE dvdc_1st_comma_pos = i2 WITH protect, noconstant(0)
   DECLARE dvdc_2nd_comma_pos = i2 WITH protect, noconstant(0)
   DECLARE dvdc_tbl_name = vc WITH protect, noconstant(" ")
   DECLARE dvdc_col_name = vc WITH protect, noconstant(" ")
   DECLARE dvdc_dt_type_flag = i2 WITH protect, noconstant(0)
   DECLARE dvdc_csv_rows = i4 WITH protect, noconstant(0)
   DECLARE dvdc_adm_rows_fnd = i2 WITH protect, noconstant(0)
   DECLARE dvdc_tbl_col_name = vc WITH protect, noconstant(" ")
   DECLARE dvdc_col_missing_cnt = i4 WITH protect, noconstant(0)
   DECLARE dvdc_col_mismatch_cnt = i4 WITH protect, noconstant(0)
   DECLARE dvdc_col_exists_cnt = i4 WITH protect, noconstant(0)
   DECLARE dvdc_col_missing_adm_cnt = i4 WITH protect, noconstant(0)
   DECLARE dvdc_idx = i4 WITH protect, noconstant(0)
   DECLARE dvdc_loop = i4 WITH protect, noconstant(0)
   DECLARE dvdc_tbl_fnd = i4 WITH protect, noconstant(0)
   DECLARE dvdc_col_fnd = i4 WITH protect, noconstant(0)
   SET stat = alterlist(dus_date_cols->qual,0)
   SET dus_date_cols->cnt = 0
   IF ( NOT (dldc_mode IN ("V", "C", "I", "U")))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Verify load date columns mode entered."
    SET dm_err->emsg = concat("Mode ",dldc_mode," is not valid. Valid modes are V, C, I and U.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dldc_mode IN ("C", "I", "U")
    AND size(trim(dldc_dbname,3))=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Verify load date columns database name entered."
    SET dm_err->emsg = concat("Database name [",trim(dldc_dbname),
     "] is not valid. Must specify value for check/insert/update mode.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Managing master date columns (",evaluate(dldc_mode,"V","VERIFY","C",
     "CHECK",
     "I","INSERT","UPDATE")," Mode).")
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dm2_findfile(dvdc_csv_loc)=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Verify file ",dvdc_csv_loc," exists.")
    SET dm_err->emsg = concat(dvdc_csv_loc," is not found.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Load master date column list from csv ",dvdc_csv_loc," into memory.")
   CALL disp_msg(" ",dm_err->logfile,0)
   FREE DEFINE rtl
   FREE SET file_loc
   SET logical file_loc value(dvdc_csv_loc)
   DEFINE rtl "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtlt r
    HEAD REPORT
     dus_date_cols->cnt = 0
    DETAIL
     dvdc_csv_rows = (dvdc_csv_rows+ 1)
     IF (r.line != "TABLE_NAME,COLUMN_NAME,DATE_TYPE_FLAG"
      AND findstring(",",r.line,1,0) != findstring(",",r.line,1,1))
      dvdc_1st_comma_pos = findstring(",",r.line,1,0), dvdc_tbl_name = trim(cnvtupper(substring(1,(
         dvdc_1st_comma_pos - 1),r.line)),3), dvdc_2nd_comma_pos = findstring(",",r.line,1,1),
      dvdc_col_name = trim(cnvtupper(substring((dvdc_1st_comma_pos+ 1),((dvdc_2nd_comma_pos -
         dvdc_1st_comma_pos) - 1),r.line)),3), dvdc_dt_type_flag = cnvtint(substring((
        dvdc_2nd_comma_pos+ 1),size(r.line),r.line)), dvdc_tbl_col_name = trim(build(dvdc_tbl_name,
        "/",dvdc_col_name)),
      dvdc_idx = 0, dvdc_idx = locateval(dvdc_idx,1,dus_date_cols->cnt,dvdc_tbl_col_name,
       dus_date_cols->qual[dvdc_idx].tbl_col_name)
      IF (dvdc_idx=0)
       dus_date_cols->cnt = (dus_date_cols->cnt+ 1)
       IF (mod(dus_date_cols->cnt,1000)=1)
        stat = alterlist(dus_date_cols->qual,(dus_date_cols->cnt+ 999))
       ENDIF
       dus_date_cols->qual[dus_date_cols->cnt].tbl_name = dvdc_tbl_name, dus_date_cols->qual[
       dus_date_cols->cnt].col_name = dvdc_col_name, dus_date_cols->qual[dus_date_cols->cnt].
       dt_type_flag = dvdc_dt_type_flag,
       dus_date_cols->qual[dus_date_cols->cnt].tbl_col_name = dvdc_tbl_col_name
      ENDIF
     ENDIF
     IF ((dm_err->debug_flag > 4))
      CALL echo(r.line)
     ENDIF
    FOOT REPORT
     stat = alterlist(dus_date_cols->qual,dus_date_cols->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 3))
    CALL echorecord(dus_date_cols)
   ENDIF
   IF ((dus_date_cols->cnt=0))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Verify load of CSV master date list.")
    SET dm_err->emsg = build("CSV file empty.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((dvdc_csv_rows - 1) != dus_date_cols->cnt))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat(
     "Verify number of rows in CSV matches with the count loaded into record structure.")
    SET dm_err->emsg = build("CSV content invalid or duplicates exist.  CSV count:",(dvdc_csv_rows -
     1)," Record structure count: ",dus_date_cols->cnt)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dldc_mode="V")
    RETURN(1)
   ENDIF
   IF (dldc_mode IN ("C", "I", "U"))
    SET dm_err->eproc = "Load master date column list from ADMIN DM_INFO into memory."
    CALL disp_msg("",dm_err->logfile,0)
    SET stat = alterlist(dus_adm_date_cols->qual,0)
    SET dus_adm_date_cols->cnt = 0
    SELECT INTO "nl:"
     FROM dm2_admin_dm_info di
     WHERE di.info_domain=patstring(cnvtupper(build(dldc_dbname,"_UTC_DATA - MASTER DATE COLUMN LIST"
        )))
     HEAD REPORT
      dus_adm_date_cols->cnt = 0
     DETAIL
      dus_adm_date_cols->cnt = (dus_adm_date_cols->cnt+ 1)
      IF (mod(dus_adm_date_cols->cnt,1000)=1)
       stat = alterlist(dus_adm_date_cols->qual,(dus_adm_date_cols->cnt+ 999))
      ENDIF
      dus_adm_date_cols->qual[dus_adm_date_cols->cnt].tbl_col_name = di.info_name, dus_adm_date_cols
      ->qual[dus_adm_date_cols->cnt].tbl_name = substring(1,(findstring("/",di.info_name,1,1) - 1),di
       .info_name), dus_adm_date_cols->qual[dus_adm_date_cols->cnt].col_name = substring((findstring(
        "/",di.info_name,1,1)+ 1),size(di.info_name),di.info_name),
      dus_adm_date_cols->qual[dus_adm_date_cols->cnt].dt_type_flag = di.info_number
     FOOT REPORT
      stat = alterlist(dus_adm_date_cols->qual,dus_adm_date_cols->cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 2))
     CALL echorecord(dus_adm_date_cols)
    ENDIF
   ENDIF
   IF (dldc_mode IN ("C", "U"))
    IF ((dus_adm_date_cols->cnt=0))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Verify context of master list."
     SET dm_err->emsg = "CHECK and UPDATE mode requires existence of Admin master date list rows."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    FOR (dvdc_loop = 1 TO dus_date_cols->cnt)
      SET dvdc_idx = 0
      SET dvdc_idx = locateval(dvdc_idx,1,dus_adm_date_cols->cnt,dus_date_cols->qual[dvdc_loop].
       tbl_col_name,dus_adm_date_cols->qual[dvdc_idx].tbl_col_name)
      IF (dvdc_idx > 0)
       IF ((dus_date_cols->qual[dvdc_loop].dt_type_flag != dus_adm_date_cols->qual[dvdc_idx].
       dt_type_flag)
        AND (((dus_date_cols->qual[dvdc_loop].dt_type_flag=1)) OR ((dus_adm_date_cols->qual[dvdc_idx]
       .dt_type_flag=1))) )
        SET dm_err->eproc = concat("[UTC Conversion] Table/column date type flag mismatch [",trim(
          dus_date_cols->qual[dvdc_loop].tbl_col_name),"; csv - ",trim(cnvtstring(dus_date_cols->
           qual[dvdc_loop].dt_type_flag)),", admin - ",
         trim(cnvtstring(dus_adm_date_cols->qual[dvdc_idx].dt_type_flag)),"].")
        CALL disp_msg("",dm_err->logfile,0)
        SET dvdc_col_mismatch_cnt = (dvdc_col_mismatch_cnt+ 1)
       ENDIF
      ELSE
       SET dm_err->eproc = concat("[UTC Conversion] Table/column missing [",dus_date_cols->qual[
        dvdc_loop].tbl_col_name,"].")
       CALL disp_msg("",dm_err->logfile,0)
       SET dvdc_col_missing_cnt = (dvdc_col_missing_cnt+ 1)
       IF (dldc_mode="U")
        SET dm_err->eproc = concat("Check db existence of missing master date table/column [",
         dus_date_cols->qual[dvdc_loop].tbl_col_name,"].")
        CALL disp_msg("",dm_err->logfile,0)
        SELECT INTO "nl:"
         FROM user_tab_columns uc
         WHERE (uc.table_name=dus_date_cols->qual[dvdc_loop].tbl_name)
          AND (uc.column_name=dus_date_cols->qual[dvdc_loop].col_name)
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
        IF (curqual > 0)
         SET dm_err->eproc = concat("[UTC Conversion] Table/column ",trim(dus_date_cols->qual[
           dvdc_loop].tbl_col_name)," already exists in database.")
         CALL disp_msg("",dm_err->logfile,0)
         SET dvdc_col_exists_cnt = (dvdc_col_exists_cnt+ 1)
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
    IF (dldc_mode="C")
     IF (((dvdc_col_mismatch_cnt > 0) OR (dvdc_col_missing_cnt > 0)) )
      SET dm_err->err_ind = 1
      SET dm_err->eproc = "Verify master date list csv file and Admin master date list match."
      SET dm_err->emsg = concat("Table/columns missing or mismatch on date type flag.  [Missing: ",
       trim(cnvtstring(dvdc_col_missing_cnt)),"  Mismatch: ",trim(cnvtstring(dvdc_col_mismatch_cnt)),
       "].  Review logfile for complete list of missing/mismatch table/columns.")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF ((dus_adm_date_cols->cnt > dus_date_cols->cnt))
      SET dm_err->err_ind = 1
      SET dm_err->eproc = "Verify context of master list."
      SET dm_err->emsg = concat("CHECK mode requires the master date list count in csv file (",trim(
        cnvtstring(dus_date_cols->cnt)),") to match count of Admin master date list (",trim(
        cnvtstring(dus_adm_date_cols->cnt)),").")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    IF (dldc_mode="U"
     AND ((dvdc_col_mismatch_cnt > 0) OR (dvdc_col_exists_cnt > 0)) )
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Verify master date list csv file and Admin master date list match."
     SET dm_err->emsg = concat(
      "Table/columns mismatch on date type flag or already exist in database.  [Mismatch: ",trim(
       cnvtstring(dvdc_col_mismatch_cnt)),"  Exists in DB: ",trim(cnvtstring(dvdc_col_exists_cnt)),
      "].  Review logfile for complete list of missing/mismatch table/columns.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dldc_mode="C")
     IF (dus_load_spec_cols(dldc_dbname)=0)
      RETURN(0)
     ENDIF
     FOR (dvdc_loop = 1 TO dus_date_cols->cnt)
       IF ((dus_date_cols->qual[dvdc_loop].dt_type_flag != 1))
        SET dvdc_tbl_fnd = 0
        SET dvdc_tbl_fnd = locateval(dvdc_tbl_fnd,1,dus_std_convert_list->tbl_cnt,dus_date_cols->
         qual[dvdc_loop].tbl_name,dus_std_convert_list->tbl[dvdc_tbl_fnd].table_name)
        IF (dvdc_tbl_fnd > 0)
         SET dvdc_col_fnd = 0
         SET dvdc_col_fnd = locateval(dvdc_col_fnd,1,dus_std_convert_list->tbl[dvdc_tbl_fnd].col_cnt,
          dus_date_cols->qual[dvdc_loop].col_name,dus_std_convert_list->tbl[dvdc_tbl_fnd].col[
          dvdc_col_fnd].column_name)
        ENDIF
        IF (((dvdc_tbl_fnd=0) OR (dvdc_col_fnd=0)) )
         SET dm_err->eproc = concat(
          "[UTC Conversion] Table/column exclusion date missing from Admin exclusions [",
          dus_date_cols->qual[dvdc_loop].tbl_col_name,"].")
         CALL disp_msg("",dm_err->logfile,0)
         SET dvdc_col_missing_adm_cnt = (dvdc_col_missing_adm_cnt+ 1)
        ENDIF
       ENDIF
     ENDFOR
     IF (dvdc_col_missing_adm_cnt > 0)
      SET dm_err->err_ind = 1
      SET dm_err->eproc =
      "Verify master date exclusions from csv file and Admin exclusion date list match."
      SET dm_err->emsg = concat("Table/columns missing from Admin exclusions.  [Missing: ",trim(
        cnvtstring(dvdc_col_missing_adm_cnt)),
       "].  Review logfile for complete list of Admin exclusions missing table/columns.")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF (dldc_mode="I"
    AND (dus_adm_date_cols->cnt > 0))
    SET dm_err->eproc =
    "Insert mode on restart.  Skipping work to complete initial load of Admin DM_INFO master date column list."
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (((dldc_mode="I"
    AND (dus_adm_date_cols->cnt=0)) OR (dldc_mode="U")) )
    IF (dldc_mode="U")
     SET dm_err->eproc = "Deleting Master Date Columns into Admin DM_INFO."
     CALL disp_msg(" ",dm_err->logfile,0)
     DELETE  FROM dm2_admin_dm_info i
      WHERE i.info_domain=patstring(cnvtupper(build(dldc_dbname,"_UTC_DATA - MASTER DATE COLUMN LIST"
         )))
      WITH nocounter
     ;end delete
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    SET dm_err->eproc = "Inserting Master Date Columns into Admin DM_INFO."
    CALL disp_msg(" ",dm_err->logfile,0)
    INSERT  FROM dm2_admin_dm_info di,
      (dummyt d  WITH seq = value(size(dus_date_cols->qual,5)))
     SET di.info_domain = patstring(cnvtupper(build(dldc_dbname,"_UTC_DATA - MASTER DATE COLUMN LIST"
         ))), di.info_name = dus_date_cols->qual[d.seq].tbl_col_name, di.info_number = dus_date_cols
      ->qual[d.seq].dt_type_flag,
      di.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     PLAN (d)
      JOIN (di
      WHERE (dus_date_cols->qual[d.seq].tbl_col_name=di.info_name))
     WITH nocounter, rdbarrayinsert = 100
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    COMMIT
    IF (dum_mng_spec_cols(dldc_dbname)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_fill_v500_cust(dfvc_dbname)
   DECLARE dfvc_pos = i4 WITH protect, noconstant(0)
   DECLARE dfvc_loc = i4 WITH protect, noconstant(0)
   DECLARE dfvc_own_name = vc WITH protect, noconstant(" ")
   DECLARE dfvc_tbl_name = vc WITH protect, noconstant(" ")
   SET dm_err->eproc = "Loading V500 Custom tables from ADMIN DM_INFO."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info i
    WHERE i.info_domain=patstring(cnvtupper(build(dfvc_dbname,"_UTC_DATA - V500 CUST TABLES LIST")))
    DETAIL
     dus_v500_cust->tbl_cnt = (dus_v500_cust->tbl_cnt+ 1), stat = alterlist(dus_v500_cust->tbl,
      dus_v500_cust->tbl_cnt), dus_v500_cust->tbl[dus_v500_cust->tbl_cnt].table_name = i.info_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(dus_v500_cust)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_cust_incl_abort_gen(dciag_tgt_dbname,dciag_src_orcl_ver,dciag_tgt_orcl_ver)
   DECLARE dciag_fname = vc WITH protect, noconstant("")
   DECLARE dciag_parm_loc = vc WITH protect, noconstant("")
   DECLARE dciag_iter = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Create utc delivery custom tables inclusion abort file for custom tables."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dciag_parm_loc = "/ggdelivery/dirprm"
   IF (dm2_find_dir(dciag_parm_loc)=0)
    SET message = window
    CALL clear(1,1)
    CALL box(1,1,15,120)
    CALL text(3,2,"Enter Delivery parameter file directory location :")
    CALL accept(3,70,"P(30);C",dciag_parm_loc
     WHERE curaccept != "")
    SET dciag_parm_loc = trim(curaccept)
    SET message = nowindow
   ENDIF
   IF (dm2_find_dir(dciag_parm_loc)=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Delivery parm directory entered [",dciag_parm_loc,"] does not exist.")
    SET dm_err->eproc = "Verify delivery parm directory exists."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (substring(size(dciag_parm_loc),1,dciag_parm_loc) != "/")
    SET dciag_parm_loc = concat(trim(dciag_parm_loc),"/")
   ENDIF
   SET dciag_fname = concat(trim(dciag_parm_loc),"custtbls_abort.mac")
   SELECT INTO value(dciag_fname)
    FROM dummyt d
    HEAD REPORT
     col 0,
     CALL print("MACRO #custtbls_abort"), row + 1,
     col 0,
     CALL print("BEGIN"), row + 1
    DETAIL
     IF ((dus_v500_cust->tbl_cnt > 0))
      IF (dciag_src_orcl_ver < 12
       AND dciag_tgt_orcl_ver > 11)
       FOR (dciag_iter = 1 TO dus_v500_cust->tbl_cnt)
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE ALTER OBJTYPE TABLE OBJNAME ",dciag_tgt_dbname,
          ".V500.",trim(dus_v500_cust->tbl[dciag_iter].table_name),
          ^ INSTRWORDS '" ADD "' EVENTACTIONS (DISCARD, ABORT) &^)), row + 1,
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE CREATE OBJTYPE TABLE OBJNAME ",dciag_tgt_dbname,
          ".V500.",trim(dus_v500_cust->tbl[dciag_iter].table_name)," EVENTACTIONS (DISCARD, ABORT) &"
          )), row + 1,
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE DROP OBJTYPE TABLE OBJNAME ",dciag_tgt_dbname,
          ".V500.",trim(dus_v500_cust->tbl[dciag_iter].table_name)," EVENTACTIONS (DISCARD, ABORT) &"
          )), row + 1
       ENDFOR
      ELSE
       FOR (dciag_iter = 1 TO dus_v500_cust->tbl_cnt)
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE ALTER OBJTYPE TABLE OBJNAME V500.",trim(
           dus_v500_cust->tbl[dciag_iter].table_name),
          ^ INSTRWORDS '" ADD "' EVENTACTIONS (DISCARD, ABORT) &^)), row + 1,
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE CREATE OBJTYPE TABLE OBJNAME V500.",trim(
           dus_v500_cust->tbl[dciag_iter].table_name)," EVENTACTIONS (DISCARD, ABORT) &")), row + 1,
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE DROP OBJTYPE TABLE OBJNAME V500.",trim(
           dus_v500_cust->tbl[dciag_iter].table_name)," EVENTACTIONS (DISCARD, ABORT) &")), row + 1
       ENDFOR
      ENDIF
     ENDIF
     IF ((dus_user_list->cnt > 0))
      IF (dciag_src_orcl_ver < 12
       AND dciag_tgt_orcl_ver > 11)
       FOR (dciag_iter = 1 TO dus_user_list->cnt)
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE ALTER OBJTYPE TABLE OBJNAME ",dciag_tgt_dbname,".",
          trim(dus_user_list->qual[dciag_iter].owner_name),".",
          trim(dus_user_list->qual[dciag_iter].table_name),
          ^ INSTRWORDS '" ADD "' EVENTACTIONS (DISCARD, ABORT) &^)), row + 1,
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE CREATE OBJTYPE TABLE OBJNAME ",dciag_tgt_dbname,".",
          trim(dus_user_list->qual[dciag_iter].owner_name),".",
          trim(dus_user_list->qual[dciag_iter].table_name)," EVENTACTIONS (DISCARD, ABORT) &")), row
          + 1,
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE DROP OBJTYPE TABLE OBJNAME ",dciag_tgt_dbname,".",
          trim(dus_user_list->qual[dciag_iter].owner_name),".",
          trim(dus_user_list->qual[dciag_iter].table_name)," EVENTACTIONS (DISCARD, ABORT) &")), row
          + 1
       ENDFOR
      ELSE
       FOR (dciag_iter = 1 TO dus_user_list->cnt)
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE ALTER OBJTYPE TABLE OBJNAME ",trim(dus_user_list->
           qual[dciag_iter].owner_name),".",trim(dus_user_list->qual[dciag_iter].table_name),
          ^ INSTRWORDS '" ADD "' EVENTACTIONS (DISCARD, ABORT) &^)), row + 1,
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE CREATE OBJTYPE TABLE OBJNAME ",trim(dus_user_list->
           qual[dciag_iter].owner_name),".",trim(dus_user_list->qual[dciag_iter].table_name),
          " EVENTACTIONS (DISCARD, ABORT) &")), row + 1,
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE DROP OBJTYPE TABLE OBJNAME ",trim(dus_user_list->
           qual[dciag_iter].owner_name),".",trim(dus_user_list->qual[dciag_iter].table_name),
          " EVENTACTIONS (DISCARD, ABORT) &")), row + 1
       ENDFOR
      ENDIF
     ENDIF
    FOOT REPORT
     IF (dciag_src_orcl_ver < 12
      AND dciag_tgt_orcl_ver > 11)
      col 0,
      CALL print(concat("INCLUDE MAPPED OPTYPE CREATE OBJTYPE TABLE OBJNAME ",dciag_tgt_dbname,
       ".V500.DM2_MIG_FAKE_BATCH"," EVENTACTIONS (DISCARD, ABORT) ")), row + 1
     ELSE
      col 0,
      CALL print(concat("INCLUDE MAPPED OPTYPE CREATE OBJTYPE TABLE OBJNAME V500.DM2_MIG_FAKE_BATCH",
       " EVENTACTIONS (DISCARD, ABORT) ")), row + 1
     ENDIF
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
 DECLARE dan_insert_app_nodes(null) = i2
 DECLARE dan_get_app_nodes(null) = i2
 DECLARE dan_get_missing_cron_node(null) = vc
 DECLARE dan_bypass_node_check(dbnc_bypass_check=i4(ref)) = i2
 IF ((validate(dan_nodes_list->cnt,- (1))=- (1))
  AND (validate(dan_nodes_list->cnt,- (2))=- (2)))
  RECORD dan_nodes_list(
    1 cnt = i2
    1 domain_name = vc
    1 qual[*]
      2 node_name = vc
  )
 ENDIF
 SUBROUTINE dan_insert_app_nodes(null)
   DECLARE dan_file = vc WITH protect, noconstant("")
   DECLARE dan_cmd = vc WITH protect, noconstant("")
   DECLARE dan_found_start = i2 WITH protect, noconstant(0)
   DECLARE dan_found_node_name = i2 WITH protect, noconstant(0)
   DECLARE dan_errfile = vc WITH protect, noconstant("")
   DECLARE dan_found_curnode = i2 WITH protect, noconstant(0)
   DECLARE dan_idx = i4 WITH protect, noconstant(0)
   DECLARE dan_pos = i4 WITH protect, noconstant(0)
   DECLARE dan_str = vc WITH protect, noconstant("")
   DECLARE dan_domain = vc WITH protect, noconstant("")
   FREE RECORD dian_list
   RECORD dian_list(
     1 cnt = i4
     1 qual[*]
       2 node_name = vc
   )
   IF (get_unique_file("get_nodes",evaluate(dm2_sys_misc->cur_os,"AXP",".com",".ksh"))=0)
    RETURN(0)
   ELSE
    SET dan_file = dm_err->unique_fname
   ENDIF
   SET dan_domain = cnvtupper(trim(logical("environment")))
   SET dm_err->eproc = concat("Create file to obtain listing of nodes from DNS:",dan_file)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO value(dan_file)
    DETAIL
     CALL print(concat("$cer_exe/testdns ",dan_domain)), row + 1
    WITH nocounter, maxcol = 500, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dm2_push_dcl(concat("chmod 777 $CCLUSERDIR/",dan_file))=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Obtain node listing from DNS."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dan_cmd = concat(". $CCLUSERDIR/",dan_file)
   IF (dm2_push_dcl(dan_cmd)=0)
    RETURN(0)
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm_err)
   ENDIF
   IF (((findstring("bad command",dm_err->errtext,1,1) > 0) OR (findstring("Domain lookup failed",
    dm_err->errtext,1,1) > 0)) )
    SET dm_err->emsg = concat("Error getting ",dan_domain," nodes from DNS:",dan_cmd)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dan_errfile = dm_err->errfile
   SET dm_err->eproc = concat("Parse node listing from:",dan_errfile)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET logical dgnd_data_file dan_errfile
   FREE DEFINE rtl
   DEFINE rtl "dgnd_data_file"
   SELECT INTO "nl:"
    t.line
    FROM rtlt t
    WHERE t.line > " "
    DETAIL
     IF ((dm_err->debug_flag > 0))
      CALL echo(t.line)
     ENDIF
     IF (dan_found_node_name=1)
      IF (findstring(".",t.line,dan_pos,0) > 0)
       dan_str = trim(cnvtupper(substring(1,(findstring(".",t.line,dan_pos,0) - dan_pos),t.line)))
      ELSE
       dan_str = substring(dan_pos,(findstring(" ",t.line,dan_pos,0) - dan_pos),t.line)
      ENDIF
      dian_list->cnt = (dian_list->cnt+ 1), stat = alterlist(dian_list->qual,dian_list->cnt),
      dian_list->qual[dian_list->cnt].node_name = cnvtupper(trim(dan_str,3))
      IF (trim(cnvtupper(dan_str))=trim(cnvtupper(curnode)))
       dan_found_curnode = 1
      ENDIF
     ENDIF
     IF (dan_found_start=1
      AND dan_found_node_name=0)
      dan_pos = findstring("Node Name",t.line,1,0)
      IF (dan_pos > 0)
       dan_found_node_name = 1
      ENDIF
     ENDIF
     IF (findstring("DNS SRV lookup for Cerner domain",t.line,1,1) > 0)
      dan_found_start = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dian_list)
   ENDIF
   IF (dan_found_curnode=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Current node,",cnvtupper(trim(curnode)),
     " not found via testdns command.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Delete existing node list and node count information in dm_info"
   CALL disp_msg(" ",dm_err->logfile,0)
   DELETE  FROM dm_info
    WHERE info_domain=concat("DM2_APP_NODES_",dan_domain)
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ELSE
    COMMIT
   ENDIF
   FOR (dan_idx = 1 TO dian_list->cnt)
     SET dm_err->eproc = "Add node list information into dm_info"
     INSERT  FROM dm_info
      SET info_domain = concat("DM2_APP_NODES_",dan_domain), info_name = cnvtupper(dian_list->qual[
        dan_idx].node_name), updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dan_get_app_nodes(null)
   DECLARE dgan_row_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgan_idx = i4 WITH protect, noconstant(0)
   DECLARE dgan_pos = i4 WITH protect, noconstant(0)
   DECLARE dgan_override_ind = i4 WITH protect, noconstant(0)
   IF ((dan_nodes_list->cnt > 0))
    SET dan_nodes_list->cnt = 0
    SET dan_nodes_list->domain_name = ""
    SET stat = alterlist(dan_nodes_list->qual,0)
   ENDIF
   SET dan_nodes_list->domain_name = cnvtupper(trim(logical("environment")))
   SET dm_err->eproc = concat("Querying node override information into dm_info")
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dgan_idx = 0
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain=concat("DM2_APP_NODES_OVERRIDE_",dan_nodes_list->domain_name)
    DETAIL
     dgan_pos = locateval(dgan_idx,1,dan_nodes_list->cnt,cnvtupper(d.info_name),cnvtupper(
       dan_nodes_list->qual[dgan_idx].node_name))
     IF (dgan_pos=0)
      dan_nodes_list->cnt = (dan_nodes_list->cnt+ 1), stat = alterlist(dan_nodes_list->qual,
       dan_nodes_list->cnt), dan_nodes_list->qual[dan_nodes_list->cnt].node_name = cnvtupper(d
       .info_name),
      dgan_override_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dan_nodes_list)
   ENDIF
   IF (dgan_override_ind=0)
    SET dgan_idx = 0
    SET dm_err->eproc = concat("Loading nodes in to global record dan_nodes_list")
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain=concat("DM2_APP_NODES_",dan_nodes_list->domain_name)
     DETAIL
      dgan_pos = locateval(dgan_idx,1,dan_nodes_list->cnt,cnvtupper(d.info_name),cnvtupper(
        dan_nodes_list->qual[dgan_idx].node_name))
      IF (dgan_pos=0)
       dan_nodes_list->cnt = (dan_nodes_list->cnt+ 1), stat = alterlist(dan_nodes_list->qual,
        dan_nodes_list->cnt), dan_nodes_list->qual[dan_nodes_list->cnt].node_name = cnvtupper(d
        .info_name)
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dan_nodes_list)
   ENDIF
   IF ((dan_nodes_list->cnt=0))
    SET dm_err->emsg = "No dm_info rows found to load into global record."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dan_nodes_list->cnt=1)
    AND (dan_nodes_list->qual[dan_nodes_list->cnt].node_name != cnvtupper(curnode)))
    SET dm_err->emsg = "Override node name does not match the curnode."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dan_get_missing_cron_node(null)
   DECLARE dmcn_nodes = vc WITH protect, noconstant("")
   DECLARE dmcn_cnt = i4 WITH protect, noconstant(0)
   DECLARE dmcn_dt_tm = f8 WITH protect, noconstant(0.0)
   DECLARE dmcn_idx = i4 WITH protect, noconstant(0)
   IF ((dan_nodes_list->cnt=0))
    IF (dan_get_app_nodes(null)=0)
     SET dmcn_nodes = "ERROR"
     RETURN(dmcn_nodes)
    ENDIF
   ENDIF
   FOR (dmcn_idx = 1 TO dan_nodes_list->cnt)
     SET dm_err->eproc = concat("Check dm_info for cronjob entry for node- ",cnvtupper(dan_nodes_list
       ->qual[dmcn_idx].node_name))
     CALL disp_msg(" ",dm_err->logfile,0)
     SELECT INTO "nl:"
      FROM dm_info di
      WHERE di.info_domain=concat("DM2_SYNC_APP_TABLEDEF_",dan_nodes_list->domain_name)
       AND di.info_name=cnvtupper(dan_nodes_list->qual[dmcn_idx].node_name)
      DETAIL
       dmcn_dt_tm = cnvtdatetime(di.info_date)
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dmcn_nodes = "ERROR"
      RETURN(dmcn_nodes)
     ENDIF
     IF (((curqual=0) OR (datetimediff(cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)),
      cnvtdatetimeutc(cnvtdatetime(dmcn_dt_tm)),4) > 60)) )
      IF (dmcn_cnt=0)
       SET dmcn_nodes = cnvtupper(dan_nodes_list->qual[dmcn_idx].node_name)
       SET dmcn_cnt = (dmcn_cnt+ 1)
      ELSE
       SET dmcn_nodes = concat(dmcn_nodes,",",cnvtupper(dan_nodes_list->qual[dmcn_idx].node_name))
      ENDIF
     ENDIF
     SET dmcn_dt_tm = 0.0
   ENDFOR
   RETURN(dmcn_nodes)
 END ;Subroutine
 SUBROUTINE dan_bypass_node_check(dbnc_bypass_check)
   DECLARE dbnc_domain = vc WITH protect, noconstant("")
   SET dbnc_domain = cnvtupper(trim(logical("environment")))
   SET dbnc_bypass_check = 0
   IF (dbnc_domain="ADMIN")
    SET dm_err->eproc = concat("Query dm_info for bypass value for domain ",dbnc_domain)
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain=concat("DM2_BYPASS_NODE_CHECK_",dbnc_domain)
      AND di.info_number=1
     DETAIL
      dbnc_bypass_check = di.info_number
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE dcfr_get_header_info(dghi_file_loc=vc,dghi_file_name=vc) = i2
 DECLARE dcfr_get_csv_row_cnt(dgcrc_file_name=vc,dgcrc_row_cnt=i4(ref)) = i2
 DECLARE dcfr_pop_coldic_rec(dpcr_table_in=vc) = i2
 DECLARE dcfr_build_col_list(null) = i2
 DECLARE dcfr_sea_csv_files(dssf_dir=vc,dssf_file_prefix=vc,dssf_schema_date=vc(ref)) = i2
 DECLARE dcfr_fix_afd(null) = i2
 IF ((validate(dcfr_csv_file->file_cnt,- (1))=- (1)))
  RECORD dcfr_csv_file(
    1 sf_ver = i4
    1 file_cnt = i4
    1 qual[*]
      2 file_suffix = vc
      2 file_desc = vc
      2 target_table = vc
      2 data_cnt = i4
  )
  SET dcfr_csv_file->sf_ver = 1
  SET dcfr_csv_file->file_cnt = 8
  SET stat = alterlist(dcfr_csv_file->qual,dcfr_csv_file->file_cnt)
  SET dcfr_csv_file->qual[1].file_suffix = "_h"
  SET dcfr_csv_file->qual[1].file_desc = "HEADER"
  SET dcfr_csv_file->qual[1].target_table = ""
  SET dcfr_csv_file->qual[1].data_cnt = 4
  SET dcfr_csv_file->qual[2].file_suffix = "_t"
  SET dcfr_csv_file->qual[2].file_desc = "TABLE"
  SET dcfr_csv_file->qual[2].target_table = "DM_AFD_TABLES"
  SET dcfr_csv_file->qual[2].data_cnt = 0
  SET dcfr_csv_file->qual[3].file_suffix = "_tc"
  SET dcfr_csv_file->qual[3].file_desc = "COLUMN"
  SET dcfr_csv_file->qual[3].target_table = "DM_AFD_COLUMNS"
  SET dcfr_csv_file->qual[3].data_cnt = 0
  SET dcfr_csv_file->qual[4].file_suffix = "_i"
  SET dcfr_csv_file->qual[4].file_desc = "INDEX"
  SET dcfr_csv_file->qual[4].target_table = "DM_AFD_INDEXES"
  SET dcfr_csv_file->qual[4].data_cnt = 0
  SET dcfr_csv_file->qual[5].file_suffix = "_ic"
  SET dcfr_csv_file->qual[5].file_desc = "INDCOL"
  SET dcfr_csv_file->qual[5].target_table = "DM_AFD_INDEX_COLUMNS"
  SET dcfr_csv_file->qual[5].data_cnt = 0
  SET dcfr_csv_file->qual[6].file_suffix = "_c"
  SET dcfr_csv_file->qual[6].file_desc = "CONS"
  SET dcfr_csv_file->qual[6].target_table = "DM_AFD_CONSTRAINTS"
  SET dcfr_csv_file->qual[6].data_cnt = 0
  SET dcfr_csv_file->qual[7].file_suffix = "_cc"
  SET dcfr_csv_file->qual[7].file_desc = "CONSCOL"
  SET dcfr_csv_file->qual[7].target_table = "DM_AFD_CONS_COLUMNS"
  SET dcfr_csv_file->qual[7].data_cnt = 0
  SET dcfr_csv_file->qual[8].file_suffix = "_sq"
  SET dcfr_csv_file->qual[8].file_desc = "SEQUENCE"
  SET dcfr_csv_file->qual[8].target_table = ""
  SET dcfr_csv_file->qual[8].data_cnt = 0
 ENDIF
 IF ((validate(dcfr_csv_header_info->admin_load_ind,- (1))=- (1)))
  RECORD dcfr_csv_header_info(
    1 admin_load_ind = i4
    1 source_rdbms = vc
    1 desc = vc
    1 sf_version = i4
  )
  SET dcfr_csv_header_info->admin_load_ind = 0
  SET dcfr_csv_header_info->source_rdbms = "DM2NOTSET"
  SET dcfr_csv_header_info->desc = "DM2NOTSET"
  SET dcfr_csv_header_info->sf_version = 0
 ENDIF
 IF (validate(dcfr_col_list->tbl,"-x")="-x"
  AND validate(dcfr_col_list->tbl,"-y")="-y")
  FREE RECORD dcfr_col_list
  RECORD dcfr_col_list(
    1 tbl = vc
    1 col[*]
      2 col_name = vc
      2 col_type = vc
  )
 ENDIF
 SUBROUTINE dcfr_get_header_info(dghi_file_name)
   DECLARE dghi_csv_rows = i4 WITH protect, noconstant(0)
   DECLARE dghi_found_str = vc WITH protect, noconstant(" ")
   DECLARE dghi_line_str = vc WITH protect, noconstant(" ")
   DECLARE dghi_field_number = i4 WITH protect, noconstant(1)
   DECLARE dghi_check_pos = i4 WITH protect, noconstant(0)
   DECLARE dghi_line_cnt = i4 WITH protect, noconstant(0)
   DECLARE dghi_line_len = i4 WITH protect, noconstant(0)
   SET dghi_csv_rows = 0
   IF (dcfr_get_csv_row_cnt(dghi_file_name,dghi_csv_rows)=0)
    RETURN(0)
   ENDIF
   IF (dghi_csv_rows=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("CSV Header File is empty")
    SET dm_err->eproc = "CSV Header File Validation"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Parsing data from csv file ",dghi_file_name)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   FREE SET file_loc
   SET logical file_loc value(dghi_file_name)
   FREE DEFINE rtl2
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    t.line
    FROM rtl2t t
    WHERE t.line > " "
    HEAD REPORT
     delim = ",", dghi_line_str = " ", dghi_line_cnt = 0
    DETAIL
     dghi_line_cnt = (dghi_line_cnt+ 1)
     IF (dghi_line_cnt=2)
      dghi_line_str = t.line, dghi_line_len = textlen(trim(dghi_line_str)), dghi_field_number = 1,
      dghi_check_pos = 0
      WHILE ((dghi_field_number <= dcfr_csv_file->qual[1].data_cnt))
        IF ('"""'=substring(1,3,dghi_line_str))
         dghi_check_pos = findstring('""",',substring(2,dghi_line_len,dghi_line_str)), dghi_found_str
          = substring(4,(dghi_check_pos - 3),dghi_line_str), dghi_line_str = substring((
          dghi_check_pos+ 5),dghi_line_len,dghi_line_str)
        ELSE
         dghi_check_pos = findstring(delim,dghi_line_str), dghi_found_str = substring(1,(
          dghi_check_pos - 1),dghi_line_str), dghi_line_str = substring((dghi_check_pos+ 1),
          dghi_line_len,dghi_line_str)
        ENDIF
        IF (dghi_field_number=1)
         dcfr_csv_header_info->desc = dghi_found_str
        ELSEIF (dghi_field_number=2)
         dcfr_csv_header_info->source_rdbms = dghi_found_str
        ELSEIF (dghi_field_number=3)
         dcfr_csv_header_info->admin_load_ind = cnvtint(dghi_found_str)
        ELSEIF (dghi_field_number=4)
         dcfr_csv_header_info->sf_version = cnvtint(dghi_found_str)
        ENDIF
        dghi_field_number = (dghi_field_number+ 1)
      ENDWHILE
     ENDIF
    WITH nocounter, maxcol = 32768
   ;end select
   FREE DEFINE rtl2
   FREE SET file_loc
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dcfr_csv_header_info->desc=" "))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Description is invalid."
    SET dm_err->eproc = "Validating Header description."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dcfr_csv_header_info->source_rdbms != "ORACLE"))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat(trim(dcfr_csv_header_info->source_rdbms)," is an invalid RDBMS.")
    SET dm_err->eproc = "Validating Header source RDBMS."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dcfr_csv_header_info->admin_load_ind != 0))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Admin load indicator is invalid."
    SET dm_err->eproc = "Validating Header admin load indicator."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcfr_get_csv_row_cnt(dgcrc_file_name,dgcrc_row_cnt)
   SET dgcrc_row_cnt = 0
   SET dm_err->eproc = concat("Determine rows in csv file ",dgcrc_file_name)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   FREE SET file_loc
   SET logical file_loc value(dgcrc_file_name)
   FREE DEFINE rtl2
   DEFINE rtl2 "file_loc"
   SELECT INTO "NL:"
    FROM rtl2t t
    WHERE t.line > " "
    DETAIL
     dgcrc_row_cnt = (dgcrc_row_cnt+ 1)
    WITH nocounter
   ;end select
   FREE DEFINE rtl2
   FREE SET file_loc
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dgcrc_row_cnt = 0
    RETURN(0)
   ENDIF
   SET dgcrc_row_cnt = (dgcrc_row_cnt - 1)
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("Numbers of rows to process: ",dgcrc_row_cnt))
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcfr_pop_coldic_rec(dpcr_table_in)
   DECLARE dpcr_cnt = i4 WITH protect, noconstant(0)
   DECLARE dpcr_idx = i4 WITH protect, noconstant(0)
   DECLARE dcpr_col_oradef_ind = i2 WITH protect, noconstant(0)
   DECLARE dcpr_col_ccldef_ind = i2 WITH protect, noconstant(0)
   DECLARE dpcr_data_type = vc WITH protect, noconstant("")
   SET dcfr_col_list->tbl = ""
   SET stat = alterlist(dcfr_col_list->col,0)
   SET dcfr_col_list->tbl = cnvtupper(dpcr_table_in)
   SET dm_err->eproc = concat("Get list of columns in dictionary for ",dcfr_col_list->tbl)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   FOR (dpcr_idx = 1 TO size(columns_1->list_1,5))
     SET dcpr_col_oradef_ind = 0
     SET dcpr_col_ccldef_ind = 0
     SET dpcr_data_type = ""
     IF (dm2_table_column_exists("",dcfr_col_list->tbl,columns_1->list_1[dpcr_idx].field_name,0,1,
      2,dcpr_col_oradef_ind,dcpr_col_ccldef_ind,dpcr_data_type)=0)
      RETURN(0)
     ENDIF
     IF (dcpr_col_ccldef_ind=1)
      SET dpcr_cnt = (dpcr_cnt+ 1)
      SET stat = alterlist(dcfr_col_list->col,dpcr_cnt)
      SET dcfr_col_list->col[dpcr_cnt].col_name = trim(columns_1->list_1[dpcr_idx].field_name)
      SET dcfr_col_list->col[dpcr_cnt].col_type = substring(1,1,dpcr_data_type)
     ENDIF
   ENDFOR
   IF (size(dcfr_col_list->col,5)=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("No rows identified according to dictionary for ",dcfr_col_list->tbl)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcfr_col_list)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcfr_build_col_list(null)
  DECLARE dbcl_cnt = i4 WITH protect, noconstant(0)
  FOR (dbcl_cnt = 1 TO size(dcfr_col_list->col,5))
   CASE (dcfr_col_list->col[dbcl_cnt].col_type)
    OF "C":
     CALL dm2_push_cmd(concat("dcv.",dcfr_col_list->col[dbcl_cnt].col_name," = ",
       "evaluate(requestin->list_0[d.seq].",dcfr_col_list->col[dbcl_cnt].col_name,
       ",'::DM2NULLVALUE::',","null, requestin->list_0[d.seq].",dcfr_col_list->col[dbcl_cnt].col_name,
       ")"),0)
    OF "Q":
     CALL dm2_push_cmd(concat("dcv.",dcfr_col_list->col[dbcl_cnt].col_name," = ",
       "evaluate(requestin->list_0[d.seq].",dcfr_col_list->col[dbcl_cnt].col_name,
       ",'::DM2NULLVALUE::',","null, cnvtdatetime(requestin->list_0[d.seq].",dcfr_col_list->col[
       dbcl_cnt].col_name,"))"),0)
    OF "I":
     CALL dm2_push_cmd(concat("dcv.",dcfr_col_list->col[dbcl_cnt].col_name," = ",
       "evaluate(requestin->list_0[d.seq].",dcfr_col_list->col[dbcl_cnt].col_name,
       ",'::DM2NULLVALUE::',","null, cnvtint(requestin->list_0[d.seq].",dcfr_col_list->col[dbcl_cnt].
       col_name,"))"),0)
    OF "F":
     CALL dm2_push_cmd(concat("dcv.",dcfr_col_list->col[dbcl_cnt].col_name," = ",
       "evaluate(requestin->list_0[d.seq].",dcfr_col_list->col[dbcl_cnt].col_name,
       ",'::DM2NULLVALUE::',","null, cnvtreal(requestin->list_0[d.seq].",dcfr_col_list->col[dbcl_cnt]
       .col_name,"))"),0)
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("Column Name:",dcfr_col_list->col[dbcl_cnt].col_name,". Data_Type:",
      dcfr_col_list->col[dbcl_cnt].col_type," is not recognizable by load script.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
   ENDCASE
   IF (dbcl_cnt != size(dcfr_col_list->col,5))
    CALL dm2_push_cmd(",",0)
   ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE dcfr_sea_csv_files(dssf_dir,dssf_file_prefix,dssf_schema_date)
   DECLARE dcfr_dcl_find = vc WITH protect, noconstant("")
   DECLARE dcfr_err_str = vc WITH protect, noconstant("")
   SET dssf_schema_date = "01-JAN-1800"
   IF (dssf_file_prefix != "dm2a")
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating file_prefix."
    SET dm_err->emsg = "File_prefix must be 'dm2a'"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dcfr_dcl_find = concat("dir/columns=1  ",build(dssf_dir),dssf_file_prefix,"*.csv")
    SET dcfr_err_str = "no files found"
   ELSEIF ((dm2_sys_misc->cur_os="WIN"))
    SET dcfr_dcl_find = concat("dir ",build(dssf_dir),"\",dssf_file_prefix,"*.csv")
    SET dcfr_err_str = "file not found"
   ELSE
    SET dcfr_dcl_find = concat("find ",build(dssf_dir),' -name "',dssf_file_prefix,
     '*.csv" -print | wc -w')
    SET dcfr_err_str = "0"
   ENDIF
   IF (dm2_push_dcl(dcfr_dcl_find)=0)
    IF (findstring(dcfr_err_str,cnvtlower(dm_err->errtext)) > 0)
     SET dm_err->eproc = "Find schema date."
     SET dm_err->emsg = "No schema date was found."
     SET dm_err->err_ind = 0
     RETURN(1)
    ENDIF
    RETURN(0)
   ELSE
    IF ((dm2_sys_misc->cur_os IN ("AIX", "HPX", "LNX")))
     SET dcfr_dcl_find = concat("find ",build(dssf_dir),' -name "',dssf_file_prefix,'*.csv" -print')
     SET dm_err->eproc = "Building list of schema files to gather schema date"
     IF (dm2_push_dcl(dcfr_dcl_find)=0)
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
       starting_pos = findstring(cnvtupper(dssf_file_prefix),r.line)
      ELSE
       starting_pos = findstring(dssf_file_prefix,r.line)
      ENDIF
      stripped_date = cnvtdate(substring((starting_pos+ 4),8,r.line))
      IF (stripped_date > compare_date)
       dssf_schema_date = format(stripped_date,"DD-MMM-YYYY;;d"), compare_date = stripped_date
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
 SUBROUTINE dcfr_fix_afd(null)
   DECLARE dfa_idx1 = i4 WITH protect, noconstant(0)
   DECLARE dfa_idx2 = i4 WITH protect, noconstant(0)
   DECLARE dfa_col_oradef_ind = i2 WITH protect, noconstant(0)
   DECLARE dfa_col_ccldef_ind = i2 WITH protect, noconstant(0)
   DECLARE dfa_data_type = vc WITH protect, noconstant("")
   FREE RECORD dfa_tbls
   RECORD dfa_tbls(
     1 cnt = i4
     1 list[*]
       2 exist_ind = i2
       2 tbl_name = vc
       2 stmt = vc
   ) WITH protect
   SET dm_err->eproc = "Verify which tables exist in database"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM user_tables ut
    WHERE ut.table_name IN ("DM_AFD_TABLES", "DM_AFD_COLUMNS", "DM_AFD_INDEXES",
    "DM_AFD_INDEX_COLUMNS", "DM_AFD_CONSTRAINTS",
    "DM_AFD_CONS_COLUMNS")
    HEAD REPORT
     dfa_tbls->cnt = 0
    DETAIL
     dfa_tbls->cnt = (dfa_tbls->cnt+ 1), stat = alterlist(dfa_tbls->list,dfa_tbls->cnt), dfa_tbls->
     list[dfa_tbls->cnt].tbl_name = trim(ut.table_name),
     dfa_tbls->list[dfa_tbls->cnt].exist_ind = 0, dfa_tbls->list[dfa_tbls->cnt].stmt = concat(
      " rdb alter table ",trim(ut.table_name)," add OWNER varchar2(30) null go ")
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Verify which tables need the column"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM user_tab_columns utc
    WHERE expand(dfa_idx1,1,dfa_tbls->cnt,utc.table_name,dfa_tbls->list[dfa_idx1].tbl_name)
     AND utc.column_name="OWNER"
    DETAIL
     dfa_idx2 = locateval(dfa_idx1,1,dfa_tbls->cnt,utc.table_name,dfa_tbls->list[dfa_idx1].tbl_name)
     IF (dfa_idx2 != 0)
      dfa_tbls->list[dfa_idx2].exist_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dfa_tbls->cnt > 0))
    FOR (dfa_idx1 = 1 TO dfa_tbls->cnt)
      IF ((dfa_tbls->list[dfa_idx1].exist_ind=0))
       IF (dm2_push_cmd(dfa_tbls->list[dfa_idx1].stmt,1)=0)
        RETURN(0)
       ENDIF
      ENDIF
      SET dfa_col_ccldef_ind = 0
      IF (dm2_table_column_exists("",dfa_tbls->list[dfa_idx1].tbl_name,"OWNER",0,1,
       1,dfa_col_oradef_ind,dfa_col_ccldef_ind,dfa_data_type)=0)
       RETURN(0)
      ENDIF
      IF (dfa_col_ccldef_ind=0)
       EXECUTE oragen3 dfa_tbls->list[dfa_idx1].tbl_name
       IF ((dm_err->err_ind != 0))
        RETURN(0)
       ENDIF
      ENDIF
    ENDFOR
    IF ((dm_err->debug_flag > 1))
     CALL echorecord(dfa_tbls)
    ENDIF
    SET dm_err->eproc = "Validate that tables got the column"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM user_tab_columns utc
     WHERE expand(dfa_idx1,1,dfa_tbls->cnt,utc.table_name,dfa_tbls->list[dfa_idx1].tbl_name)
      AND utc.column_name="OWNER"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((curqual != dfa_tbls->cnt))
     SET dm_err->emsg = "Validation failed for OWNER in AFD tables"
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
#end_csv_file_routines_inc
 IF (validate(dm2_server_link->wrapper," ")=" ")
  FREE RECORD dm2_server_link
  RECORD dm2_server_link(
    1 wrapper = vc
    1 server_name = vc
    1 drop_server_ind = i2
    1 server_rdbms = vc
    1 server_type = vc
    1 server_version = vc
    1 user = vc
    1 password = vc
    1 node = vc
    1 dbase = vc
    1 hostname = vc
    1 option_vntb = vc
  )
  SET dm2_server_link->wrapper = "NONE"
  SET dm2_server_link->option_vntb = "N"
 ENDIF
 IF (validate(dm2_nickname_info->nickname," ")=" ")
  FREE RECORD dm2_nickname_info
  RECORD dm2_nickname_info(
    1 nickname = vc
    1 drop_ind = i2
    1 create_ind = i2
    1 create_view_ind = i2
    1 local_owner = vc
    1 server = vc
    1 remote_table = vc
    1 remote_owner = vc
    1 link_server = vc
    1 col_list1 = vc
    1 col_list2 = vc
  )
  SET dm2_nickname_info->nickname = "NONE"
 ENDIF
 IF (validate(dsl_dmtools_adm_tables->cnt,1)=1
  AND validate(dsl_dmtools_adm_tables->cnt,2)=2)
  FREE RECORD dsl_dmtools_adm_tables
  RECORD dsl_dmtools_adm_tables(
    1 cnt = i4
    1 tbl[*]
      2 synonym_name = vc
      2 table_name = vc
      2 drop_ind = i2
  )
  SET dsl_dmtools_adm_tables->cnt = 6
  SET stat = alterlist(dsl_dmtools_adm_tables->tbl,6)
  SET dsl_dmtools_adm_tables->tbl[1].table_name = "DM_TABLES_DOC"
  SET dsl_dmtools_adm_tables->tbl[1].synonym_name = build(dsl_dmtools_adm_tables->tbl[1].table_name,
   "_ALL")
  SET dsl_dmtools_adm_tables->tbl[2].table_name = "DM_COLUMNS_DOC"
  SET dsl_dmtools_adm_tables->tbl[2].synonym_name = build(dsl_dmtools_adm_tables->tbl[2].table_name,
   "_ALL")
  SET dsl_dmtools_adm_tables->tbl[3].table_name = "DM_TS_PRECEDENCE"
  SET dsl_dmtools_adm_tables->tbl[3].synonym_name = build(dsl_dmtools_adm_tables->tbl[3].table_name,
   "_ALL")
  SET dsl_dmtools_adm_tables->tbl[4].table_name = "DM_INDEXES_DOC"
  SET dsl_dmtools_adm_tables->tbl[4].synonym_name = build(dsl_dmtools_adm_tables->tbl[4].table_name,
   "_ALL")
  SET dsl_dmtools_adm_tables->tbl[5].table_name = "DM_FLAGS"
  SET dsl_dmtools_adm_tables->tbl[5].synonym_name = build(dsl_dmtools_adm_tables->tbl[5].table_name,
   "_ALL")
  SET dsl_dmtools_adm_tables->tbl[6].table_name = "DM_SEQUENCES"
  SET dsl_dmtools_adm_tables->tbl[6].synonym_name = build(dsl_dmtools_adm_tables->tbl[6].table_name,
   "_ALL")
 ENDIF
 DECLARE dm2_create_nickname(null) = i2
 DECLARE check_dm2tools_nicknames(sbr_cdn_drop_ind=i2) = i2
 DECLARE dm2_get_db_link(null) = vc
 DECLARE dm2_fill_nick_except(sbr_alias=vc) = vc
 DECLARE dsl_create_spec_admin_synonyms(sbr_csas_idx=i2) = i2
 DECLARE dsl_create_dm_flags_objs(null) = i2
 SUBROUTINE dm2_fill_nick_except(sbr_alias)
   DECLARE dfne_in_clause = vc WITH public, noconstant("")
   SET dfne_in_clause = concat("substring(1,3,",sbr_alias,".table_name) != 'DM2' ")
   SET dfne_in_clause = concat(dfne_in_clause," and ",sbr_alias,".table_name not in ('DM_INFO',",
    "'DM_SEGMENTS',",
    "'DM_TABLE_LIST',","'DM_USER_CONSTRAINTS',","'DM_USER_CONS_COLUMNS',","'DM_USER_IND_COLUMNS',",
    "'DM_USER_TAB_COLS',",
    "'EXPLAIN_ARGUMENT',","'EXPLAIN_INSTANCE',","'EXPLAIN_OBJECT',","'EXPLAIN_OPERATOR',",
    "'EXPLAIN_PREDICATE',",
    "'EXPLAIN_STATEMENT',","'EXPLAIN_STREAM',","'PLAN_TABLE') ")
   RETURN(dfne_in_clause)
 END ;Subroutine
 SUBROUTINE dm2_create_nickname(null)
   DECLARE dcn_push_str = vc WITH protect, noconstant(" ")
   DECLARE dcn_grp_str1 = vc WITH protect, noconstant(" ")
   DECLARE dcn_grp_str2 = vc WITH protect, noconstant(" ")
   DECLARE dcn_table_exists_ind = i2 WITH protect, noconstant(0)
   IF (dm2_table_and_ccldef_exists("DM_FLAGS_LOCAL",dcn_table_exists_ind)=0)
    RETURN(0)
   ENDIF
   IF ((((dm2_nickname_info->nickname="DM_FLAGS")) OR ((dm2_nickname_info->nickname="DM_FLAGS_ALL")
   ))
    AND dcn_table_exists_ind=1)
    SET dm_err->eproc = concat("Creating view/synonym ",dm2_nickname_info->nickname,
     " as DM_FLAGS_LOCAL exists.")
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    IF (dsl_create_dm_flags_objs(null)=0)
     RETURN(0)
    ENDIF
    RETURN(1)
   ENDIF
   IF ((dm2_nickname_info->create_view_ind=1))
    SET dm_err->eproc = concat("Creating view ",dm2_nickname_info->nickname,
     " with owner rows equal to ",currdbuser)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SET dcn_push_str = concat("rdb create or replace view ",dm2_nickname_info->nickname,
     " as select * from ",build(dm2_nickname_info->remote_owner,".",dm2_nickname_info->remote_table,
      "@",dm2_nickname_info->server)," where owner = USER go")
    IF (dm2_push_cmd(dcn_push_str,1)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm2_nickname_info->drop_ind=1))
    SET dm_err->eproc = concat("Dropping nickname ",dm2_nickname_info->nickname)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SET dcn_push_str = concat("rdb drop public synonym  ",dm2_nickname_info->nickname," go")
    IF (dm2_push_cmd(dcn_push_str,1)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm2_nickname_info->create_ind=1))
    SET dm_err->eproc = concat("Creating nickname ",dm2_nickname_info->nickname)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SET dcn_push_str = concat("rdb create public synonym  ",dm2_nickname_info->nickname," for ",build
     (dm2_nickname_info->remote_owner,".",dm2_nickname_info->remote_table,"@",dm2_nickname_info->
      server)," go")
    IF (dm2_push_cmd(dcn_push_str,1)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE check_dm2tools_nicknames(sbr_cdn_drop_ind)
   DECLARE cdn_admin_tables_drop_ind = i2 WITH protect, noconstant(0)
   DECLARE cdn_admin_tab_col_drop_ind = i2 WITH protect, noconstant(0)
   DECLARE cdn_admin_dm_info_drop_ind = i2 WITH protect, noconstant(0)
   DECLARE cdn_admin_seq_drop_ind = i2 WITH protect, noconstant(0)
   DECLARE cdn_admin_tables_cre_ind = i2 WITH protect, noconstant(1)
   DECLARE cdn_admin_tab_col_cre_ind = i2 WITH protect, noconstant(1)
   DECLARE cdn_admin_dm_info_cre_ind = i2 WITH protect, noconstant(1)
   DECLARE cdn_admin_seq_cre_ind = i2 WITH protect, noconstant(1)
   DECLARE cdn_db_link = vc WITH protect, noconstant(" ")
   DECLARE cdn_admin_tables_def_ind = i2 WITH protect, noconstant(0)
   DECLARE cdn_admin_tab_col_def_ind = i2 WITH protect, noconstant(0)
   DECLARE cdn_admin_dm_info_def_ind = i2 WITH protect, noconstant(0)
   DECLARE cdn_admin_seq_def_ind = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = concat("Determining if DM2_ADMIN_TABLES, ","DM2_ADMIN_TAB_COLUMNS, ",
    "DM2_ADMIN_SEQUENCES, ","and DM2_ADMIN_DM_INFO nicknames exists.")
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("server_name=",dm2_server_link->server_name))
    CALL echo(build("server_link=",dm2_server_link->user))
    CALL echo(build("dbase =",dm2_server_link->dbase))
   ENDIF
   SELECT INTO "nl:"
    FROM dba_synonyms ds
    WHERE cnvtupper(ds.synonym_name) IN ("DM2_ADMIN_SEQUENCES", "DM2_ADMIN_TABLES",
    "DM2_ADMIN_TAB_COLUMNS", "DM2_ADMIN_DM_INFO")
     AND ds.owner="PUBLIC"
    DETAIL
     IF (ds.synonym_name="DM2_ADMIN_DM_INFO")
      cdn_pos = findstring(".",ds.db_link,1)
      IF (cdn_pos > 0)
       cdn_db_link = substring(1,(cdn_pos - 1),ds.db_link)
      ELSE
       cdn_db_link = ds.db_link
      ENDIF
      IF (cnvtupper(cdn_db_link)=cnvtupper(dm2_server_link->server_name))
       cdn_admin_dm_info_drop_ind = sbr_cdn_drop_ind, cdn_admin_dm_info_cre_ind = sbr_cdn_drop_ind
      ELSE
       cdn_admin_dm_info_drop_ind = 1, cdn_admin_dm_info_cre_ind = 1
      ENDIF
     ENDIF
     IF (ds.synonym_name="DM2_ADMIN_TABLES")
      cdn_pos = findstring(".",ds.db_link,1)
      IF (cdn_pos > 0)
       cdn_db_link = substring(1,(cdn_pos - 1),ds.db_link)
      ELSE
       cdn_db_link = ds.db_link
      ENDIF
      IF (cnvtupper(cdn_db_link)=cnvtupper(dm2_server_link->server_name))
       cdn_admin_tables_drop_ind = sbr_cdn_drop_ind, cdn_admin_tables_cre_ind = sbr_cdn_drop_ind
      ELSE
       cdn_admin_tables_drop_ind = 1, cdn_admin_tables_cre_ind = 1
      ENDIF
     ENDIF
     IF (ds.synonym_name="DM2_ADMIN_TAB_COLUMNS")
      cdn_pos = findstring(".",ds.db_link,1)
      IF (cdn_pos > 0)
       cdn_db_link = substring(1,(cdn_pos - 1),ds.db_link)
      ELSE
       cdn_db_link = ds.db_link
      ENDIF
      IF (cnvtupper(cdn_db_link)=cnvtupper(dm2_server_link->server_name))
       cdn_admin_tab_col_drop_ind = sbr_cdn_drop_ind, cdn_admin_tab_col_cre_ind = sbr_cdn_drop_ind
      ELSE
       cdn_admin_tab_col_drop_ind = 1, cdn_admin_tab_col_cre_ind = 1
      ENDIF
     ENDIF
     IF (ds.synonym_name="DM2_ADMIN_SEQUENCES")
      cdn_pos = findstring(".",ds.db_link,1)
      IF (cdn_pos > 0)
       cdn_db_link = substring(1,(cdn_pos - 1),ds.db_link)
      ELSE
       cdn_db_link = ds.db_link
      ENDIF
      IF (cnvtupper(cdn_db_link)=cnvtupper(dm2_server_link->server_name))
       cdn_admin_seq_drop_ind = sbr_cdn_drop_ind, cdn_admin_seq_cre_ind = sbr_cdn_drop_ind
      ELSE
       cdn_admin_seq_drop_ind = 1, cdn_admin_seq_cre_ind = 1
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET cdn_admin_tables_cre_ind = 1
    SET cdn_admin_tab_col_cre_ind = 1
    SET cdn_admin_dm_info_cre_ind = 1
    SET cdn_admin_seq_cre_ind = 1
   ENDIF
   IF (((cdn_admin_tables_cre_ind=0) OR (((cdn_admin_tab_col_cre_ind=0) OR (((
   cdn_admin_dm_info_cre_ind=0) OR (cdn_admin_seq_cre_ind=0)) )) )) )
    IF (checkdic("DM2_ADMIN_TABLES","T",0)=2)
     SET cdn_admin_tables_def_ind = 1
    ENDIF
    IF (checkdic("DM2_ADMIN_TAB_COLUMNS","T",0)=2)
     SET cdn_admin_tab_col_def_ind = 1
    ENDIF
    IF (checkdic("DM2_ADMIN_DM_INFO","T",0)=2)
     SET cdn_admin_dm_info_def_ind = 1
    ENDIF
    IF (checkdic("DM2_ADMIN_SEQUENCES","T",0)=2)
     SET cdn_admin_seq_def_ind = 1
    ENDIF
   ENDIF
   SET dm2_nickname_info->nickname = "DM2_ADMIN_TABLES"
   SET dm2_nickname_info->drop_ind = cdn_admin_tables_drop_ind
   SET dm2_nickname_info->create_ind = cdn_admin_tables_cre_ind
   SET dm2_nickname_info->local_owner = currdbuser
   SET dm2_nickname_info->remote_table = "DM2_USER_TABLES"
   SET dm2_nickname_info->col_list1 = "NONE"
   SET dm2_nickname_info->col_list2 = "NONE"
   SET dm2_nickname_info->server = dm2_server_link->server_name
   SET dm2_nickname_info->remote_owner = dm2_server_link->user
   IF ((((dm2_nickname_info->drop_ind=1)) OR ((dm2_nickname_info->create_ind=1))) )
    SET dm_err->eproc = "(Re)creating DM2_ADMIN_TABLES nickname to access remote ADMIN tables."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (dm2_create_nickname(null)=0)
     RETURN(0)
    ELSE
     IF ((dm2_nickname_info->create_ind=1))
      EXECUTE oragen3 "DM2_ADMIN_TABLES"
      IF ((dm_err->err_ind=1))
       RETURN(0)
      ENDIF
     ENDIF
    ENDIF
   ELSE
    IF (cdn_admin_tables_def_ind=0)
     EXECUTE oragen3 "DM2_ADMIN_TABLES"
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   SET dm2_nickname_info->nickname = "DM2_ADMIN_TAB_COLUMNS"
   SET dm2_nickname_info->drop_ind = cdn_admin_tab_col_drop_ind
   SET dm2_nickname_info->create_ind = cdn_admin_tab_col_cre_ind
   SET dm2_nickname_info->local_owner = currdbuser
   SET dm2_nickname_info->remote_table = "DM2_USER_TAB_COLUMNS"
   SET dm2_nickname_info->col_list1 = "NONE"
   SET dm2_nickname_info->col_list2 = "NONE"
   SET dm2_nickname_info->server = dm2_server_link->server_name
   SET dm2_nickname_info->remote_owner = dm2_server_link->user
   IF ((((dm2_nickname_info->drop_ind=1)) OR ((dm2_nickname_info->create_ind=1))) )
    SET dm_err->eproc = "(Re)creating DM2_ADMIN_TAB_COLUMNS nickname to access remote ADMIN tables."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (dm2_create_nickname(null)=0)
     RETURN(0)
    ELSE
     IF ((dm2_nickname_info->create_ind=1))
      EXECUTE oragen3 "DM2_ADMIN_TAB_COLUMNS"
      IF ((dm_err->err_ind=1))
       RETURN(0)
      ENDIF
     ENDIF
    ENDIF
   ELSE
    IF (cdn_admin_tab_col_def_ind=0)
     EXECUTE oragen3 "DM2_ADMIN_TAB_COLUMNS"
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   SET dm2_nickname_info->nickname = "DM2_ADMIN_SEQUENCES"
   SET dm2_nickname_info->drop_ind = cdn_admin_seq_drop_ind
   SET dm2_nickname_info->create_ind = cdn_admin_seq_cre_ind
   SET dm2_nickname_info->local_owner = currdbuser
   SET dm2_nickname_info->remote_table = "DM2_USER_SEQUENCES"
   SET dm2_nickname_info->col_list1 = "NONE"
   SET dm2_nickname_info->col_list2 = "NONE"
   SET dm2_nickname_info->server = dm2_server_link->server_name
   SET dm2_nickname_info->remote_owner = dm2_server_link->user
   IF ((((dm2_nickname_info->drop_ind=1)) OR ((dm2_nickname_info->create_ind=1))) )
    SET dm_err->eproc = "(Re)creating DM2_ADMIN_SEQUENCES nickname to access remote ADMIN tables."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (dm2_create_nickname(null)=0)
     RETURN(0)
    ELSE
     IF ((dm2_nickname_info->create_ind=1))
      EXECUTE oragen3 "DM2_ADMIN_SEQUENCES"
      IF ((dm_err->err_ind=1))
       RETURN(0)
      ENDIF
     ENDIF
    ENDIF
   ELSE
    IF (cdn_admin_seq_def_ind=0)
     EXECUTE oragen3 "DM2_ADMIN_SEQUENCES"
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   SET dm2_nickname_info->nickname = "DM2_ADMIN_DM_INFO"
   SET dm2_nickname_info->drop_ind = cdn_admin_dm_info_drop_ind
   SET dm2_nickname_info->create_ind = cdn_admin_dm_info_cre_ind
   SET dm2_nickname_info->local_owner = currdbuser
   SET dm2_nickname_info->remote_table = "DM_INFO"
   SET dm2_nickname_info->col_list1 = "NONE"
   SET dm2_nickname_info->col_list2 = "NONE"
   SET dm2_nickname_info->server = dm2_server_link->server_name
   SET dm2_nickname_info->remote_owner = dm2_server_link->user
   IF ((((dm2_nickname_info->drop_ind=1)) OR ((dm2_nickname_info->create_ind=1))) )
    SET dm_err->eproc = "(Re)creating DM_INFO nickname to access remote ADMIN tables."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (dm2_create_nickname(null)=0)
     RETURN(0)
    ELSE
     IF ((dm2_nickname_info->create_ind=1))
      IF ((dm2_install_schema->process_option != "CLIN COPY"))
       EXECUTE oragen3 "DM2_ADMIN_DM_INFO"
       IF ((dm_err->err_ind=1))
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ELSE
    IF (cdn_admin_dm_info_def_ind=0
     AND (dm2_install_schema->process_option != "CLIN COPY"))
     EXECUTE oragen3 "DM2_ADMIN_DM_INFO"
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_get_db_link(null)
   DECLARE dgdbl_link = vc WITH protect, noconstant(" ")
   SET dm_err->eproc = "Getting admin db link from existing synonyms"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_synonyms ds
    WHERE ds.table_name="DM_ENVIRONMENT"
    DETAIL
     dgdbl_link = cnvtlower(substring(1,(findstring(".",ds.db_link) - 1),ds.db_link))
     IF (dgdbl_link="")
      dgdbl_link = ds.db_link
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    SET dgdbl_link = "DM2_ERROR"
   ELSEIF (curqual=0)
    SET dgdbl_link = "DM2_UNKNOWN"
   ELSE
    SET dm_err->eproc =
    "Making sure admin db/listener is up and that synonyms point to correct admin db"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_environment de
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     SET dgdbl_link = "DM2_ERROR"
    ENDIF
   ENDIF
   RETURN(dgdbl_link)
 END ;Subroutine
 SUBROUTINE dsl_create_spec_admin_synonyms(sbr_csas_idx)
   DECLARE dm2_dm2tools_special_nickname = vc WITH protect, noconstant("DM2NOTSET")
   SET dm2_nickname_info->nickname = dsl_dmtools_adm_tables->tbl[sbr_csas_idx].synonym_name
   SET dm2_nickname_info->drop_ind = dsl_dmtools_adm_tables->tbl[sbr_csas_idx].drop_ind
   SET dm2_nickname_info->create_ind = 1
   SET dm2_nickname_info->local_owner = currdbuser
   SET dm2_nickname_info->remote_table = dsl_dmtools_adm_tables->tbl[sbr_csas_idx].table_name
   SET dm2_nickname_info->col_list1 = "NONE"
   SET dm2_nickname_info->col_list2 = "NONE"
   SET dm2_nickname_info->server = dm2_server_link->server_name
   SET dm2_nickname_info->remote_owner = dm2_server_link->user
   SET dm2_nickname_info->create_view_ind = 0
   SET dm2_dm2tools_special_nickname = dm2_nickname_info->nickname
   SET dm_err->eproc = concat("(Re)creating ",dm2_nickname_info->nickname,
    " synonym to access remote ADMIN table ",dm2_nickname_info->remote_table)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dm2_create_nickname(null)=0)
    RETURN(0)
   ELSE
    IF ((dm2_nickname_info->create_ind=1))
     EXECUTE oragen3 build("cdba.",dm2_nickname_info->remote_table,"@",dm2_nickname_info->server)
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   SET dm2_dm2tools_special_nickname = "DM2NOTSET"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsl_create_dm_flags_objs(null)
   DECLARE dcdfv_ddl_stmt = vc WITH noconstant("")
   DECLARE dcdfv_df_tab_local = i2 WITH protect, noconstant(0)
   DECLARE dcdfv_dfa_tab_local = i2 WITH protect, noconstant(0)
   DECLARE dcdfv_df_view_txt = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM all_synonyms a
    WHERE a.synonym_name IN ("DM_FLAGS", "DM_FLAGS_ALL")
     AND a.table_name="DM_FLAGS_LOCAL"
     AND a.owner="PUBLIC"
    DETAIL
     IF (a.synonym_name="DM_FLAGS")
      dcdfv_df_tab_local = 1
     ELSEIF (a.synonym_name="DM_FLAGS_ALL")
      dcdfv_dfa_tab_local = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (dcdfv_df_tab_local=0)
    SET dm_err->eproc = "Re-creating public dm_flags synonym to point to dm_flags_local."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SET dcdfv_ddl_stmt = concat(
     "rdb create or replace public synonym DM_FLAGS for v500.dm_flags_local go")
    IF (dm2_push_cmd(dcdfv_ddl_stmt,1)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dcdfv_dfa_tab_local=0)
    SET dm_err->eproc = "Re-creating public dm_flags_all synonym to point to dm_flags_local."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SET dcdfv_ddl_stmt = concat(
     "rdb create or replace public synonym DM_FLAGS_ALL for v500.dm_flags_local go")
    IF (dm2_push_cmd(dcdfv_ddl_stmt,1)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    av.text
    FROM all_views av
    WHERE av.view_name="DM_FLAGS"
     AND av.owner="V500"
    DETAIL
     dcdfv_df_view_txt = av.text
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (findstring("FROM V500 . DM_FLAGS_LOCAL",dcdfv_df_view_txt,1,0)=0)
    SET dm_err->eproc = "Re-creating v500.dm_flags view to point to dm_flags_local."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SET dcdfv_ddl_stmt = concat("rdb create or replace view DM_FLAGS as ",
     "select * from v500.dm_flags_local where owner = USER go")
    IF (dm2_push_cmd(dcdfv_ddl_stmt,1)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (checkdic("DM_FLAGS","T",0)=0)
    SET dm_err->eproc = "Running oragen for dm_flags."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    EXECUTE oragen3 "DM_FLAGS"
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (checkdic("DM_FLAGS_ALL","T",0)=0)
    SET dm_err->eproc = "Running oragen for dm_flags_all."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    EXECUTE oragen3 "DM_FLAGS_ALL"
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE dsr_sd_in_use_check(dsiuc_db_link=vc,dsiuc_sd_in_use_ind=i2(ref)) = i2
 DECLARE dsr_usage_prep(dup_db_link=vc) = i2
 DECLARE dsr_sd_get_trigger_version(dsgtv_owner=vc,dsgtv_trigger_name=vc,dsgtv_table_name=vc,
  dsgtv_when_clause=vc,dsgtv_trig_version=i4(ref)) = i2
 DECLARE dsr_check_object_state(dcos_owner=vc,dcos_object_type=vc,dcos_object_name=vc,dcos_state=vc,
  dcos_obj_drop_ind=i2(ref)) = i2
 DECLARE dsr_chk_sd_in_process(dcsip_db_group=vc,dcsip_owner=vc,dcsip_sd_in_process=i2(ref)) = i2
 IF ((validate(dsr_obj_state->cnt,- (1))=- (1))
  AND (validate(dsr_obj_state->cnt,- (2))=- (2)))
  FREE RECORD dsr_obj_state
  RECORD dsr_obj_state(
    1 obj_owner = vc
    1 obj_type = vc
    1 state = vc
    1 cnt = i4
    1 qual[*]
      2 obj_name = vc
  )
 ENDIF
 IF (validate(dsr_sd_misc->ccl_tbldef_sync_ind,0)=0
  AND validate(dsr_sd_misc->ccl_tbldef_sync_ind,1)=1)
  FREE RECORD dsr_sd_misc
  RECORD dsr_sd_misc(
    1 ccl_tbldef_sync_ind = i2
  )
  SET dsr_sd_misc->ccl_tbldef_sync_ind = 0
 ENDIF
 SUBROUTINE dsr_sd_in_use_check(dsiuc_db_link,dsiuc_sd_in_use_ind)
   DECLARE dsiuc_qry_stats = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dsiuc_sd_tbl_v_ind = i2 WITH protect, noconstant(0)
   DECLARE dsiuc_qry_sd_tbl_cnt = i4 WITH protect, noconstant(0)
   DECLARE dsiuc_sd_tbl_ind = i2 WITH protect, noconstant(0)
   DECLARE dsiuc_pkg_qry_cnt = i4 WITH protect, noconstant(0)
   DECLARE dsiuc_pkg_valid_cnt = i4 WITH protect, noconstant(0)
   DECLARE dsiuc_sd_pkg_ind = i2 WITH protect, noconstant(0)
   DECLARE dsiuc_dm_info_fnd_ind = i2 WITH protect, noconstant(0)
   DECLARE dsiuc_dm_info_cnt = i2 WITH protect, noconstant(0)
   DECLARE dsiuc_dm_info_in_view_ind = i2 WITH protect, noconstant(0)
   DECLARE dsiuc_use_link_ind = i2 WITH protect, noconstant(0)
   DECLARE dsiuc_db_link_new = vc WITH protect, noconstant("")
   DECLARE dsiuc_mill_cds_ind = i2 WITH protect, noconstant(0)
   DECLARE dsiuc_sd_param_table = vc WITH noconstant("")
   SET dsiuc_sd_in_use_ind = 0
   IF (trim(dsiuc_db_link,3) > ""
    AND dsiuc_db_link != "DM2NOTSET")
    IF (substring(1,1,dsiuc_db_link)="@")
     SET dsiuc_db_link_new = substring(2,(size(trim(dsiuc_db_link,3)) - 1),dsiuc_db_link)
    ELSE
     SET dsiuc_db_link_new = dsiuc_db_link
    ENDIF
    SET dsiuc_use_link_ind = 1
   ENDIF
   IF (currdbuser != "V500")
    SET dsiuc_sd_in_use_ind = 0
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Check to see if CERADM schema exists."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT
    IF (dsiuc_use_link_ind=1)
     FROM (parser(concat("dba_users@",dsiuc_db_link_new)) d)
     WHERE d.username="CERADM"
    ELSE
     FROM dba_users d
     WHERE d.username="CERADM"
    ENDIF
    INTO "nl:"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (curqual=0)
    IF ((dm_err->debug_flag > 5))
     CALL echo("SD framework is not in use.")
    ENDIF
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Check to see if SD_PARAM exists."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT
    IF (dsiuc_use_link_ind=1)
     FROM (parser(concat("dba_tables@",dsiuc_db_link_new)) t)
     WHERE t.owner="CERADM"
      AND t.table_name="SD_PARAM"
    ELSE
     FROM dba_tables t
     WHERE t.owner="CERADM"
      AND t.table_name="SD_PARAM"
    ENDIF
    INTO "nl:"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (curqual=0)
    IF ((dm_err->debug_flag > 5))
     CALL echo("SD_PARAM do not exists.")
    ENDIF
    SET dsiuc_sd_in_use_ind = 0
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Check to see if Millennium-CDS in use."
   CALL disp_msg("",dm_err->logfile,0)
   IF (dsiuc_use_link_ind=1)
    SET dsiuc_sd_param_table = concat("CERADM.SD_PARAM@",dsiuc_db_link_new)
   ELSE
    SET dsiuc_sd_param_table = "CERADM.SD_PARAM"
   ENDIF
   SELECT INTO "nl:"
    x = sqlpassthru(concat(asis("(select count(*) from "),dsiuc_sd_param_table," SDP ",asis(
       "where SDP.PTYPE  = 'CDS_GLOBAL_CONFIG'"),asis(
       "  and SDP.PNAME  = 'MILLENNIUM_CDS_IN_USE') as rowsCnt")),0)
    FROM dual
    DETAIL
     dsiuc_mill_cds_ind = x
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (dsiuc_mill_cds_ind=0)
    IF ((dm_err->debug_flag > 5))
     CALL echo("Millennium-CDS is not in use.")
    ENDIF
    SET dsiuc_sd_in_use_ind = 0
    RETURN(1)
   ENDIF
   IF ((dm_err->debug_flag > 5))
    CALL echo("Millennium-CDS is in use.")
   ENDIF
   SET dm_err->eproc = "Check to see if dm_info exists or not."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT
    IF (dsiuc_use_link_ind=1)
     dsiuc_tmp_qry_cnt = count(*)
     FROM (parser(concat("dba_tables@",dsiuc_db_link_new)) d)
     WHERE d.owner=currdbuser
      AND d.table_name="DM_INFO"
    ELSE
     dsiuc_tmp_qry_cnt = count(*)
     FROM dba_tables d
     WHERE d.owner=currdbuser
      AND d.table_name="DM_INFO"
    ENDIF
    INTO "nl:"
    DETAIL
     dsiuc_dm_info_fnd_ind = dsiuc_tmp_qry_cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dsiuc_dm_info_fnd_ind=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "DM_INFO does not exist"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Check to see if sd not in use due to dm_info override."
   SELECT
    IF (dsiuc_use_link_ind=1)
     FROM (parser(concat("DM_INFO@",dsiuc_db_link_new)) di)
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="SD_NOT_IN_USE_OVERRIDE"
    ELSE
     FROM dm_info di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="SD_NOT_IN_USE_OVERRIDE"
    ENDIF
    INTO "nl:"
    DETAIL
     dsiuc_dm_info_cnt = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (dsiuc_dm_info_cnt > 0)
    CALL echo("SD not in use due to DM_INFO override")
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Check to see if Schema Deployment SD_TABLE_VERSION_V view exists or not."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT
    IF (dsiuc_use_link_ind)
     FROM (parser(concat("dba_objects@",dsiuc_db_link_new)) d)
     WHERE d.owner="CERADM"
      AND d.object_name="SD_TABLE_VERSION_V"
      AND d.object_type="VIEW"
    ELSE
     FROM dba_objects d
     WHERE d.owner="CERADM"
      AND d.object_name="SD_TABLE_VERSION_V"
      AND d.object_type="VIEW"
    ENDIF
    INTO "nl:"
    DETAIL
     dsiuc_qry_stats = d.status
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dsiuc_qry_stats="VALID")
    SET dm_err->eproc = "Check to see if dm_info is union of SD view or not."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT
     IF (dsiuc_use_link_ind)
      FROM (parser(concat("dba_views@",dsiuc_db_link_new)) v)
      WHERE v.owner="CERADM"
       AND v.view_name="SD_TABLE_VERSION_V"
     ELSE
      FROM dba_views v
      WHERE v.owner="CERADM"
       AND v.view_name="SD_TABLE_VERSION_V"
     ENDIF
     INTO "nl:"
     DETAIL
      IF (cnvtlower(v.text)="*union all*"
       AND cnvtlower(v.text)="*v500*dm_info*")
       dsiuc_dm_info_in_view_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) > 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dsiuc_dm_info_in_view_ind=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "No union of V500.DM_INFO in SD view"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dsiuc_sd_tbl_v_ind = 1
   ELSEIF (dsiuc_qry_stats="INVALID")
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid Schema deployment Objects exists."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Check to see if Schema Deployment tables exists or not."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT
    IF (dsiuc_use_link_ind)
     dsiuc_tbl_tmp_cnt = count(*)
     FROM (parser(concat("dba_tables@",dsiuc_db_link_new)) t)
     WHERE t.owner="CERADM"
      AND t.table_name IN ("SD_TABLES", "SD_TABLE_COLS", "SD_TABLE_INDS", "SD_TABLE_IND_COLS",
     "SD_TABLE_CONS",
     "SD_TABLE_CON_COLS", "SD_TABLE_GROUP", "SD_DDL_OPS", "SD_OBJECT_VERSION", "SD_OBJECT_STATE",
     "SD_PROCESS_EVENT")
    ELSE
     dsiuc_tbl_tmp_cnt = count(*)
     FROM dba_tables t
     WHERE t.owner="CERADM"
      AND t.table_name IN ("SD_TABLES", "SD_TABLE_COLS", "SD_TABLE_INDS", "SD_TABLE_IND_COLS",
     "SD_TABLE_CONS",
     "SD_TABLE_CON_COLS", "SD_TABLE_GROUP", "SD_DDL_OPS", "SD_OBJECT_VERSION", "SD_OBJECT_STATE",
     "SD_PROCESS_EVENT")
    ENDIF
    INTO "nl:"
    DETAIL
     dsiuc_qry_sd_tbl_cnt = dsiuc_tbl_tmp_cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dsiuc_qry_sd_tbl_cnt=11)
    SET dsiuc_sd_tbl_ind = 1
   ELSEIF (dsiuc_qry_sd_tbl_cnt > 0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Incomplete SD table(s) exists."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc =
   "Check to see if Schema Deployment SD_OBJECT_VERSION_PKG package exists or not"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT
    IF (dsiuc_use_link_ind)
     FROM (parser(concat("dba_objects@",dsiuc_db_link_new)) o)
     WHERE o.owner="CERADM"
      AND o.object_name="SD_OBJECT_VERSION_PKG"
      AND o.object_type IN ("PACKAGE", "PACKAGE BODY")
    ELSE
     FROM dba_objects o
     WHERE o.owner="CERADM"
      AND o.object_name="SD_OBJECT_VERSION_PKG"
      AND o.object_type IN ("PACKAGE", "PACKAGE BODY")
    ENDIF
    INTO "nl:"
    DETAIL
     dsiuc_pkg_qry_cnt = (dsiuc_pkg_qry_cnt+ 1)
     IF (o.status="VALID")
      dsiuc_pkg_valid_cnt = (dsiuc_pkg_valid_cnt+ 1)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dsiuc_pkg_valid_cnt=2)
    SET dsiuc_sd_pkg_ind = 1
   ELSEIF (dsiuc_pkg_qry_cnt > 0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid Schema deployment SD_OBJECT_VERSION_PKG package exists."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dsiuc_sd_tbl_v_ind=1
    AND dsiuc_sd_tbl_ind=1
    AND dsiuc_sd_pkg_ind=1)
    CALL echo("SD framework is in use")
    SET dsiuc_sd_in_use_ind = 1
   ELSEIF (dsiuc_sd_tbl_v_ind=0
    AND dsiuc_sd_tbl_ind=0
    AND dsiuc_sd_pkg_ind=0)
    CALL echo("SD framework is not in use")
    SET dsiuc_sd_in_use_ind = 0
   ELSE
    SET dm_err->eproc = "Check if SD objects exists or not"
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Incomplete Schema Deployment framework."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsr_usage_prep(dup_db_link)
   FREE RECORD dsr_ceradm_rs
   RECORD dsr_ceradm_rs(
     1 tbl_cnt = i4
     1 tbl[*]
       2 tbl_name = vc
       2 ccl_def_ind = i2
       2 col_cnt = i4
       2 col[*]
         3 col_name = vc
   )
   DECLARE dup_use_link_ind = i2 WITH protect, noconstant(0)
   DECLARE dup_db_link_new = vc WITH protect, noconstant("")
   DECLARE dup_tblx = i4 WITH protect, noconstant(0)
   DECLARE dup_colx = i4 WITH protect, noconstant(0)
   DECLARE dup_col_fnd_ind = i2 WITH protect, noconstant(0)
   DECLARE dup_coldef_fnd_ind = i2 WITH protect, noconstant(0)
   DECLARE dup_data_type = vc WITH protect, noconstant("")
   IF (trim(dup_db_link,3) > ""
    AND dup_db_link != "DM2NOTSET")
    IF (substring(1,1,dup_db_link)="@")
     SET dup_db_link_new = substring(2,(size(trim(dup_db_link,3)) - 1),dup_db_link)
    ELSE
     SET dup_db_link_new = dup_db_link
    ENDIF
    SET dup_use_link_ind = 1
   ENDIF
   IF (currdbuser != "V500")
    RETURN(1)
   ENDIF
   IF (validate(dsr_sd_misc->ccl_tbldef_sync_ind,0)=1)
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Loading CERADM Record Structure"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT
    IF (dup_use_link_ind=1)
     FROM (parser(concat("dba_tab_columns@",dup_db_link_new)) dtc)
     WHERE dtc.owner="CERADM"
      AND dtc.table_name="SD*"
     ORDER BY dtc.table_name, dtc.column_name
    ELSE
     FROM dba_tab_columns dtc
     WHERE dtc.owner="CERADM"
      AND dtc.table_name="SD*"
     ORDER BY dtc.table_name, dtc.column_name
    ENDIF
    INTO "nl:"
    HEAD REPORT
     dup_tblx = 0
    HEAD dtc.table_name
     dup_colx = 0, dup_tblx = (dup_tblx+ 1)
     IF (mod(dup_tblx,10)=1)
      stat = alterlist(dsr_ceradm_rs->tbl,(dup_tblx+ 9))
     ENDIF
     dsr_ceradm_rs->tbl[dup_tblx].tbl_name = dtc.table_name, dsr_ceradm_rs->tbl[dup_tblx].ccl_def_ind
      = 0
    DETAIL
     dup_colx = (dup_colx+ 1)
     IF (mod(dup_colx,10)=1)
      stat = alterlist(dsr_ceradm_rs->tbl[dup_tblx].col,(dup_colx+ 9))
     ENDIF
     dsr_ceradm_rs->tbl[dup_tblx].col[dup_colx].col_name = dtc.column_name
    FOOT  dtc.table_name
     stat = alterlist(dsr_ceradm_rs->tbl[dup_tblx].col,dup_colx), dsr_ceradm_rs->tbl[dup_tblx].
     col_cnt = dup_colx
    FOOT REPORT
     stat = alterlist(dsr_ceradm_rs->tbl,dup_tblx), dsr_ceradm_rs->tbl_cnt = dup_tblx
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Comparing CCL Definitions to CERADM Record Structure"
   CALL disp_msg("",dm_err->logfile,0)
   FOR (dup_tblx = 1 TO dsr_ceradm_rs->tbl_cnt)
     IF (checkdic(cnvtupper(dsr_ceradm_rs->tbl[dup_tblx].tbl_name),"T",0)=2)
      FOR (dup_colx = 1 TO dsr_ceradm_rs->tbl[dup_tblx].col_cnt)
        SET dup_coldef_fnd_ind = 0
        IF (dm2_table_column_exists("",cnvtupper(dsr_ceradm_rs->tbl[dup_tblx].tbl_name),cnvtupper(
          dsr_ceradm_rs->tbl[dup_tblx].col[dup_colx].col_name),0,1,
         1,dup_col_fnd_ind,dup_coldef_fnd_ind,dup_data_type)=0)
         RETURN(0)
        ENDIF
        IF (dup_coldef_fnd_ind=0)
         SET dsr_ceradm_rs->tbl[dup_tblx].ccl_def_ind = 1
         SET dup_colx = dsr_ceradm_rs->tbl[dup_tblx].col_cnt
        ENDIF
      ENDFOR
     ELSE
      SET dsr_ceradm_rs->tbl[dup_tblx].ccl_def_ind = 1
     ENDIF
   ENDFOR
   SET dup_tblx = 0
   SET dup_tblx = locateval(dup_tblx,1,dsr_ceradm_rs->tbl_cnt,1,dsr_ceradm_rs->tbl[dup_tblx].
    ccl_def_ind)
   IF (dup_tblx > 0)
    SET dm_err->eproc = "Create CCL definitions for SD tables"
    CALL disp_msg("",dm_err->logfile,0)
    FOR (dup_tblx = 1 TO dsr_ceradm_rs->tbl_cnt)
     IF ((dsr_ceradm_rs->tbl[dup_tblx].ccl_def_ind=1))
      IF (dup_use_link_ind=1)
       EXECUTE oragen3 cnvtupper(concat("CERADM.",dsr_ceradm_rs->tbl[dup_tblx].tbl_name,"@",
         dup_db_link_new))
      ELSE
       EXECUTE oragen3 cnvtupper(concat("CERADM.",dsr_ceradm_rs->tbl[dup_tblx].tbl_name))
      ENDIF
     ENDIF
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ENDFOR
   ENDIF
   IF (validate(dsr_sd_misc->ccl_tbldef_sync_ind,- (1))=0)
    SET dsr_sd_misc->ccl_tbldef_sync_ind = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsr_check_object_state(dcos_owner,dcos_object_type,dcos_object_name,dcos_state,
  dcos_obj_drop_ind)
   DECLARE dcos_obj_idx = i4 WITH protect, noconstant(0)
   SET dcos_obj_drop_ind = 0
   IF ((((dsr_obj_state->cnt=0)) OR ((((dsr_obj_state->obj_type != dcos_object_type)) OR ((
   dsr_obj_state->state != dcos_state))) )) )
    SET stat = alterlist(dsr_obj_state->qual,0)
    SET dsr_obj_state->cnt = 0
    SET dsr_obj_state->obj_owner = dcos_owner
    SET dsr_obj_state->obj_type = dcos_object_type
    SET dsr_obj_state->state = dcos_state
    SET dm_err->eproc = "Check to see if object is in dropped state or not."
    SELECT INTO "nl:"
     FROM (ceradm.sd_object_state sos)
     WHERE sos.object_owner=dcos_owner
      AND sos.object_type=dcos_object_type
      AND sos.state=dcos_state
     DETAIL
      dsr_obj_state->cnt = (dsr_obj_state->cnt+ 1), stat = alterlist(dsr_obj_state->qual,
       dsr_obj_state->cnt), dsr_obj_state->qual[dsr_obj_state->cnt].obj_name = sos.object_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) > 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dsr_obj_state->cnt > 0))
    SET dcos_obj_idx = locateval(dcos_obj_idx,1,dsr_obj_state->cnt,dcos_object_name,dsr_obj_state->
     qual[dcos_obj_idx].obj_name)
   ENDIF
   IF (dcos_obj_idx > 0)
    SET dcos_obj_drop_ind = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsr_sd_get_trigger_version(dsgtv_owner,dsgtv_trigger_name,dsgtv_table_name,
  dsgtv_when_clause,dsgtv_trig_version)
   DECLARE dsgtv_qry_cnt = i4 WITH protect, noconstant(0)
   DECLARE regexp_replace() = c300
   SET dm_err->eproc = "Retrieving from dba_triggers to pull the trigger version."
   SELECT
    IF (dsgtv_when_clause != "DM2NOTSET")
     tmp_version = regexp_replace(dt.description,"(.*/\*version_)(\d+)(\*/.*)","\2",1,0,
      "in")
     FROM dba_triggers dt
     WHERE dt.trigger_name=patstring(dsgtv_trigger_name)
      AND dt.table_name=dsgtv_table_name
      AND cnvtupper(dt.when_clause)=patstring(cnvtupper(dsgtv_when_clause))
      AND dt.owner=dsgtv_owner
    ELSE
     tmp_version = regexp_replace(dt.description,"(.*/\*version_)(\d+)(\*/.*)","\2",1,0,
      "in")
     FROM dba_triggers dt
     WHERE dt.trigger_name=dsgtv_trigger_name
      AND dt.table_name=dsgtv_table_name
      AND dt.owner=dsgtv_owner
    ENDIF
    INTO "nl:"
    DETAIL
     dsgtv_qry_cnt = (dsgtv_qry_cnt+ 1), dsgtv_trig_version = cnvtint(tmp_version)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Check to see if multiple rows are qualified from dba_triggers"
   IF (dsgtv_qry_cnt > 1)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "failed due to the multiple rows are qualified from dba_triggers"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dsgtv_trig_version <= 0)
    SET dsgtv_trig_version = - (1)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsr_chk_sd_in_process(dcsip_db_group,dcsip_owner,dcsip_sd_in_process)
   DECLARE dcsip_get_session_status(session_ident=vc) = i2 WITH sql =
   "CERADM.SD_DDL_MANAGE_PKG.session_is_alive", parameter
   DECLARE dcsip_pvalue_ind = i2 WITH protect, noconstant(0)
   DECLARE dcsip_ret_value = i2 WITH protect, noconstant(0)
   DECLARE dcsip_sessidx = i4 WITH protect, noconstant(0)
   FREE RECORD dcsip_session
   RECORD dcsip_session(
     1 cnt = i4
     1 session[*]
       2 sess_id = vc
   )
   SET dcsip_sd_in_process = 0
   SET stat = alterlist(dcsip_session->session,0)
   SET dcsip_session->cnt = 0
   SET dm_err->eproc = "Checking if schema deployment is actively running"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT DISTINCT INTO "nl:"
    spe.session_ident
    FROM (ceradm.sd_process_event spe)
    WHERE spe.db_group=dcsip_db_group
     AND spe.owner=dcsip_owner
     AND spe.process_name="INSTALLER"
     AND spe.event_name="SCHEMA UPDATE"
     AND spe.status="RUNNING"
    DETAIL
     dcsip_session->cnt = (dcsip_session->cnt+ 1), stat = alterlist(dcsip_session->session,
      dcsip_session->cnt), dcsip_session->session[dcsip_session->cnt].sess_id = spe.session_ident
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dcsip_session->cnt > 0))
    SET dm_err->eproc =
    "Evaluating if there's an override with schema deployment to evaluate only active event sessions."
    SELECT INTO "nl:"
     FROM (ceradm.sd_param sp)
     WHERE sp.pname="PROCESS_EVENT_CHK_ACTIVE_SESSIONS_ONLY"
      AND sp.ptype="CONFIG"
     DETAIL
      IF (sp.pvalue="YES")
       dcsip_pvalue_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) > 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dcsip_pvalue_ind=0)
     SET dcsip_sd_in_process = 1
    ELSE
     SET dm_err->eproc = "Evaluating if session is alive or dead"
     FOR (dcsip_sessidx = 1 TO dcsip_session->cnt)
      SELECT INTO "nl:"
       ret_value_tmp = dcsip_get_session_status(dcsip_session->session[dcsip_sessidx].sess_id)
       FROM dual
       DETAIL
        IF (ret_value_tmp=1)
         dcsip_sd_in_process = 1, dcsip_sessidx = dcsip_session->cnt
        ENDIF
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc) > 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDFOR
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE program_initialization(null) = i2
 DECLARE prep_dm2_schema(sbr_pds_eid=f8,sbr_pds_package_str=vc) = i2
 DECLARE load_package_schema(sbr_lps_eid=f8,sbr_lps_package_str=vc) = null
 DECLARE check_ccl_file(sbr_ccf_inst_mode=vc,sbr_ccf_eid=f8,sbr_ccf_package_str=vc,sbr_lm_ind=i2(ref)
  ) = null
 DECLARE install_package_schema(sbr_ips_install_mode=vc,sbr_ips_eid=f8,sbr_ips_package_str=vc) = null
 DECLARE dip_sd_eval(sbr_dse_sd_in_process=i2(ref)) = i2
 DECLARE update_table_definitions(sbr_utd_mode=vc,sbr_utd_eid=f8,sbr_utd_package_int=i4) = i2
 DECLARE install_code_sets(sbr_ics_ename=vc,sbr_ics_eid=f8,sbr_ics_package_int=i4) = null
 DECLARE install_atr(sbr_ia_eid=f8,sbr_ia_package_int=i4) = null
 DECLARE display_atr_reports(sbr_dar_mode=vc,sbr_dar_eid=f8,sbr_dar_package_int=i4) = null
 DECLARE display_readme_est_report(sbr_drer_mode=vc,sbr_drer_eid=f8,sbr_drer_package_int=i4) = null
 DECLARE process_readmes(sbr_pr_mode=vc,sbr_pr_eid=f8,sbr_pr_package_int=i4) = null
 DECLARE execute_readmes(sbr_er_mode=vc,sbr_er_eid=f8,sbr_er_package_int=i4) = null
 DECLARE wait_for_readmes(sbr_wfr_eid=f8,sbr_wfr_package_int=i4) = null
 DECLARE check_readme_errors(sbr_cre_ocd_op=vc,sbr_cre_readme_mode=vc,sbr_cre_eid=f8,
  sbr_cre_package_int=i4) = i4
 DECLARE disp_readme_error(sbr_dre_op=vc,sbr_dre_readme_id=f8,sbr_dre_message=vc,sbr_dre_eid=f8,
  sbr_dre_package_int=i4) = null
 DECLARE get_batch_list(sbr_gbl_plan_id=i4) = null
 DECLARE get_batch_list_readme(gbl_batch_id=i4) = null
 DECLARE load_batch_package_schema(sbr_lbps_inst_mode=vc,sbr_lbps_plan_str=vc,sbr_lbps_eid=f8) = null
 DECLARE create_batch_schema(sbr_cbs_eid=f8,sbr_cbs_package_int=i4) = null
 DECLARE populate_batch_install_log(sbr_pbil_op=vc,sbr_pbil_eid=f8,sbr_pbil_plan_id=i4) = null
 DECLARE populate_batch_readme_log(sbr_pbrl_eid=f8,sbr_pbrl_pkg_int=i4) = null
 DECLARE validate_load(sbr_vl_package_int=i4) = i2
 DECLARE delete_preview_log(sbr_dpl_eid=f8,sbr_dpl_package_int=i4) = null
 DECLARE upd_dm_ocd_log(null) = i2
 DECLARE load_batch_cclfiles(sbr_lbc_inst_mode=vc,sbr_lbc_plan_str=vc,sbr_lbc_eid=f8) = null
 DECLARE silmode_prompt(sp_user_choice=i2(ref),sp_env_id=f8,sp_package_int=i4,sp_install_mode=vc) =
 i2
 DECLARE silmode_summary(ss_install_status=vc,ss_environment_id=f8,ss_package_int=i4,
  ss_logfile_prefix=vc) = i2
 DECLARE dip_load_target(dlt_install_mode=vc,dlt_eid=f8,dlt_package_str=vc) = i2
 DECLARE dip_process_readme_spc_needs(dpr_install_mode=vc,dpr_eid=f8,dpr_package_int=i4,
  dpr_readme_chk_mode=vc) = i2
 DECLARE code_set_instance_init(csii_pkg_int=i4) = i2
 DECLARE dip_pre_install_schema_sync(dpis_package_int=i4) = i2
 DECLARE dip_ui_validation(duv_valid_ind=i2(ref)) = i2
 DECLARE dip_unattended_install_prompt(duip_unattended_allowed_ind=i2(ref),duip_user_response=vc(ref)
  ) = i2
 DECLARE dip_register_install_process(null) = i2
 DECLARE dip_update_itinerary_step(duis_step=vc,duis_begin_dt_tm=dq8,duis_end_dt_tm=dq8,duis_plan_id=
  f8,duis_status=vc) = i2
 DECLARE dip_confirm_monitor_settings(dcms_user_choice=vc(ref)) = i2
 DECLARE dip_set_ccl_traces(null) = i2
 DECLARE dip_reset_ccl_traces(null) = i2
 DECLARE dip_recyclebin_check(drc_recyclebin_choice=vc(ref)) = i2
 DECLARE dip_disp_missing_cvg_rpt(null) = i2
 DECLARE dip_admin_upgrade(dau_install_mode=vc,dau_package_abs_float=f8) = i2
 DECLARE dip_install_mode = vc WITH protect, noconstant("NOT_SET")
 DECLARE dip_dm2_schfiles_exist_ind = i2 WITH public, noconstant(0)
 DECLARE dip_package_str = vc WITH protect, noconstant
 DECLARE dip_package_int = i4 WITH protect, noconstant
 DECLARE cerocd = vc WITH protect, constant(logical("cer_ocd"))
 DECLARE dip_env_id = f8 WITH protect, noconstant(0.0)
 DECLARE dip_env_name = vc WITH protect, noconstant("NOT_SET")
 DECLARE dip_stats_daysold = i2 WITH protect, constant(30)
 DECLARE dip_logfile_prefix = vc WITH noconstant("NOT_SET")
 DECLARE sbr_pds_pkg_dir_hold = vc WITH protect, noconstant("")
 DECLARE dip_emsg = vc WITH protect, noconstant(" ")
 DECLARE daso_skip_session_overrides_ind = i2 WITH protect, noconstant(0)
 DECLARE dip_ccl_load_ind = i2 WITH protect, noconstant(0)
 DECLARE dip_install_plan_type = vc WITH protect, noconstant("MANAGED-DT")
 DECLARE dip_predown_on_plan_ind = i2 WITH protect, noconstant(0)
 DECLARE dip_postdown_on_plan_ind = i2 WITH protect, noconstant(0)
 DECLARE dip_exec_readme_postdown_ind = i2 WITH protect, noconstant(0)
 DECLARE dip_exec_readme_predown_ind = i2 WITH protect, noconstant(0)
 DECLARE dip_exec_readme_precycle_ind = i2 WITH protect, noconstant(0)
 DECLARE dip_exec_dt_readmes_ind = i2 WITH protect, noconstant(1)
 DECLARE dip_autosuccess_batchdown_ind = i2 WITH protect, noconstant(0)
 DECLARE dip_start_dt_tm = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE dip_unattended_install_ind = i2 WITH protect, noconstant(0)
 DECLARE dip_user_response = c1 WITH protect, noconstant(" ")
 DECLARE dip_allow_old_modes = i2 WITH protect, noconstant(0)
 DECLARE dip_install_start_dt_tm = dq8 WITH protect, noconstant(0.0)
 DECLARE dip_ndx = i4 WITH protect, noconstant(0)
 DECLARE dip_breakout_ind = i2 WITH protect, noconstant(0)
 DECLARE dip_accept = vc WITH protect, noconstant("")
 DECLARE dip_install_status = i2 WITH protect, noconstant(0)
 DECLARE dip_package_abs_int = i4 WITH protect, noconstant(0)
 DECLARE dip_package_abs_float = f8 WITH protect, noconstant(0.0)
 DECLARE dip_package_float = f8 WITH protect, noconstant(0.0)
 DECLARE dip_wait_for_start = i2 WITH protect, noconstant(0)
 DECLARE dip_wait_time_minutes = i2 WITH protect, noconstant(15)
 DECLARE dip_wait_timestamp = f8 WITH protect, noconstant(0.0)
 DECLARE dip_adm_conn_inf = vc WITH protect, noconstant(" ")
 DECLARE dip_lm_ind = i2 WITH protect, noconstant(0)
 DECLARE dip_date_mode = vc WITH protect, noconstant("NOT SET")
 DECLARE dip_cvg_rpt_file = vc WITH protect, noconstant("")
 DECLARE dip_package_list_cnt = i4 WITH protect, noconstant(0)
 DECLARE dip_package_list = vc WITH protect, noconstant("")
 FREE RECORD dip_final_msg
 RECORD dip_final_msg(
   1 error_ind = i2
   1 emsg = vc
   1 eproc = vc
   1 user_action = vc
 )
 RECORD docd_reply(
   1 status = c1
   1 err_msg = vc
 )
 FREE RECORD misc
 RECORD misc(
   1 str = vc
 )
 FREE RECORD batch_list
 RECORD batch_list(
   1 package_cnt = i4
   1 qual[*]
     2 package_number = i4
     2 load_method = i2
     2 rm_qual[*]
       3 readme_id = i4
       3 instance = i4
 )
 FREE RECORD ccl_trace_list
 RECORD ccl_trace_list(
   1 trace_cnt = i4
   1 qual[*]
     2 trace_name = vc
     2 active_status_orig = i2
     2 active_status_new = i2
 )
 FREE RECORD dip_cvg_rs
 RECORD dip_cvg_rs(
   1 cnt = i4
   1 qual[*]
     2 pkg_nbr = i4
     2 parent_cs = i4
     2 parent_cv = f8
     2 child_cs = i4
     2 child_cv = f8
 )
 IF (program_initialization(null)=0)
  GO TO exit_program
 ENDIF
 IF ((dir_ui_misc->background_ind=0))
  IF (upd_dm_ocd_log(null)=0)
   GO TO exit_program
  ENDIF
 ENDIF
 IF ((dir_ui_misc->background_ind=1))
  IF (dn_get_notify_settings(null)=0)
   GO TO exit_program
  ENDIF
  IF ((dnotify->status != 1))
   SET dm_err->emsg = "Background Installs request active notification"
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
 ENDIF
 IF ((dm2_process_event_rs->ui_allowed_ind=1))
  IF (dipr_setup_install_itinerary(dip_package_abs_float,dip_install_plan_type)=0)
   GO TO exit_program
  ENDIF
 ENDIF
 IF ((dir_ui_misc->background_ind=1))
  IF (drr_use_flexible_schedule(0,dip_package_str,dip_install_mode,dip_accept)=0)
   GO TO exit_program
  ENDIF
 ENDIF
 IF ((dir_storage_misc->tgt_storage_type="DM2NOTSET"))
  IF (dir_get_storage_type(" ")=0)
   GO TO exit_program
  ENDIF
 ENDIF
 IF (dip_unattended_install_ind=1
  AND (dir_ui_misc->background_ind=0))
  IF (cnvtupper(trim(dip_install_mode,3)) IN ("BATCHUP", "BATCHPOST"))
   SET dm2_rr_misc->process_type = "PI"
   SET dm2_rr_misc->package_number = dip_package_int
   SET dm2_rr_misc->env_id = dip_env_id
   SET dm2_rr_misc->execution = "ALL"
  ENDIF
  IF ((dm_err->debug_flag > 0))
   CALL echorecord(dir_ui_misc)
   CALL echorecord(dm2_rr_misc)
  ENDIF
  CASE (cnvtupper(trim(dip_install_mode,3)))
   OF "BATCHUP":
    CALL dip_process_readme_spc_needs(cnvtupper(dip_install_mode),dip_env_id,dip_package_int,
     "PRESPCHK")
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
    CALL dip_process_readme_spc_needs(cnvtupper(dip_install_mode),dip_env_id,dip_package_int,
     "POSTSPCHK")
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   OF "BATCHPOST":
    CALL dip_process_readme_spc_needs(cnvtupper(dip_install_mode),dip_env_id,dip_package_int,
     "POSTSPCHK")
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
  ENDCASE
 ENDIF
 IF ((dir_ui_misc->background_ind=0)
  AND dip_unattended_install_ind=1)
  IF (dir_submit_jobs(dip_package_abs_float,dip_install_mode,dm2_install_schema->u_name,
   dm2_install_schema->p_word,dm2_install_schema->connect_str,
   dir_batch_queue,dir_ui_misc->background_ind)=0)
   GO TO exit_program
  ENDIF
  GO TO exit_program
 ENDIF
 IF (dip_register_install_process(null)=0)
  GO TO exit_program
 ENDIF
 IF ((drr_flex_sched->pkg_using_schedule=1)
  AND (dir_ui_misc->background_ind=0)
  AND  NOT (dip_install_mode IN ("BATCHPREVIEW"))
  AND (dm2_process_event_rs->ui_allowed_ind=1))
  IF (drr_submit_background_process(dm2_install_schema->u_name,dm2_install_schema->p_word,
   dm2_install_schema->connect_str,dir_batch_queue,dpl_install_monitor,
   dip_package_abs_float,dip_install_mode)=0)
   GO TO exit_program
  ENDIF
 ENDIF
 IF ((dir_ui_misc->background_ind=1)
  AND validate(dm2_package_os_session_logfile,"x") != "x")
  IF (drr_assign_file_to_installs(concat(dpl_logfilebackground,currdbhandle),
   dm2_package_os_session_logfile,dir_ui_misc->dm_process_event_id)=0)
   GO TO exit_program
  ENDIF
 ENDIF
 SET dip_install_start_dt_tm = cnvtdatetime(curdate,curtime3)
 CASE (cnvtupper(trim(dip_install_mode,3)))
  OF "PREVIEW":
   IF (dip_allow_old_modes=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat(dip_install_mode," mode is no longer supported.")
    SET dm_err->user_action = "Please execute BATCHPREVIEW mode instead."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   CALL check_ccl_file(dip_install_mode,dip_env_id,dip_package_str,dip_lm_ind)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL display_readme_est_report(dip_install_mode,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL dip_load_target(dip_install_mode,dip_env_id,dip_package_str)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL install_package_schema(cnvtupper(dip_install_mode),dip_env_id,dip_package_str)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL display_atr_reports("P",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
  OF "UPTIME":
   IF (dip_allow_old_modes=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat(dip_install_mode," mode is no longer supported.")
    SET dm_err->user_action = "Please execute BATCHUP mode instead."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (currdb="SQLSRV")
    CALL dip_load_target(cnvtupper(dip_install_mode),dip_env_id,dip_package_str)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
    CALL install_package_schema("UPTIME",dip_env_id,dip_package_str)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ELSE
    CALL check_ccl_file(dip_install_mode,dip_env_id,dip_package_str,dip_lm_ind)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
    CALL dip_pre_install_schema_sync(dip_package_int)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
    CALL display_readme_est_report(dip_install_mode,dip_env_id,dip_package_int)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
    CALL dip_process_readme_spc_needs(cnvtupper(dip_install_mode),dip_env_id,dip_package_int,
     "PRESPCHK")
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
    CALL install_code_sets(dip_env_name,dip_env_id,dip_package_int)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
    CALL process_readmes("PREUP",dip_env_id,dip_package_int)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
    CALL dip_load_target(dip_install_mode,dip_env_id,dip_package_str)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
    CALL install_package_schema(cnvtupper(dip_install_mode),dip_env_id,dip_package_str)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
    CALL dip_process_readme_spc_needs(cnvtupper(dip_install_mode),dip_env_id,dip_package_int,
     "POSTSPCHK")
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
    CALL install_atr(dip_env_id,dip_package_int)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
    CALL display_atr_reports("R",dip_env_id,dip_package_int)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
    IF (currdbuser="V500")
     EXECUTE dm2_install_purge_templates value(dip_package_int)
     IF ((dm_err->err_ind=1))
      GO TO exit_program
     ENDIF
     EXECUTE dm2_purge_template_rpt value(dip_package_int)
     IF ((dm_err->err_ind=1))
      GO TO exit_program
     ENDIF
    ENDIF
    CALL process_readmes("POSTUP",dip_env_id,dip_package_int)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
    IF (currdbuser="V500")
     EXECUTE dm2_code_value_rpt dip_package_int
     IF ((dm_err->err_ind=1))
      GO TO exit_program
     ENDIF
    ENDIF
   ENDIF
  OF "DOWNTIME":
   IF (dip_allow_old_modes=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat(dip_install_mode," mode is no longer supported.")
    SET dm_err->user_action = "Please execute BATCHDOWN mode instead."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   CALL display_readme_est_report(dip_install_mode,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL dip_process_readme_spc_needs(cnvtupper(dip_install_mode),dip_env_id,dip_package_int,
    "POSTSPCHK")
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL process_readmes("PREDOWN",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL install_package_schema(cnvtupper(dip_install_mode),dip_env_id,dip_package_str)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL process_readmes("POSTDOWN",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
  OF "MANUAL":
   IF (dip_allow_old_modes=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat(dip_install_mode," mode is no longer supported.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   CALL check_ccl_file(dip_install_mode,dip_env_id,dip_package_str,dip_lm_ind)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL display_readme_est_report(dip_install_mode,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL install_code_sets(dip_env_name,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL process_readmes("PREUP",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL dip_load_target("UPTIME",dip_env_id,dip_package_str)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL install_package_schema("UPTIME",dip_env_id,dip_package_str)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL install_atr(dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL display_atr_reports("R",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   IF (currdbuser="V500")
    EXECUTE dm2_install_purge_templates value(dip_package_int)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
    EXECUTE dm2_purge_template_rpt value(dip_package_int)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
   CALL process_readmes("POSTUP",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   IF (currdbuser="V500")
    EXECUTE dm2_code_value_rpt dip_package_int
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
   CALL process_readmes("PREDOWN",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL install_package_schema("DOWNTIME",dip_env_id,dip_package_str)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL process_readmes("POSTDOWN",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL process_readmes("UP",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
  OF "EXPRESS":
   IF (dip_allow_old_modes=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat(dip_install_mode," mode is no longer supported.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   CALL check_ccl_file(dip_install_mode,dip_env_id,dip_package_str,dip_lm_ind)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL display_readme_est_report(dip_install_mode,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL dip_process_readme_spc_needs(cnvtupper(dip_install_mode),dip_env_id,dip_package_int,
    "PRESPCHK")
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL install_code_sets(dip_env_name,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL process_readmes("PREUP",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL dip_load_target("UPTIME",dip_env_id,dip_package_str)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL install_package_schema("UPTIME",dip_env_id,dip_package_str)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL dip_process_readme_spc_needs(cnvtupper(dip_install_mode),dip_env_id,dip_package_int,
    "POSTSPCHK")
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL install_atr(dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL display_atr_reports("R",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   IF (currdbuser="V500")
    EXECUTE dm2_install_purge_templates value(dip_package_int)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
    EXECUTE dm2_purge_template_rpt value(dip_package_int)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
   CALL process_readmes("POSTUP",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   IF (currdbuser="V500")
    EXECUTE dm2_code_value_rpt dip_package_int
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
   CALL process_readmes("PREDOWN",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL install_package_schema("DOWNTIME",dip_env_id,dip_package_str)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL process_readmes("POSTDOWN",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL process_readmes("UP",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
  OF "MANUALNOLOAD":
   IF (dip_allow_old_modes=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat(dip_install_mode," mode is no longer supported.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   CALL display_readme_est_report(dip_install_mode,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL install_code_sets(dip_env_name,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL process_readmes("PREUP",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL dip_load_target("UPTIME",dip_env_id,dip_package_str)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL install_package_schema("UPTIME",dip_env_id,dip_package_str)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL install_atr(dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL display_atr_reports("R",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   IF (currdbuser="V500")
    EXECUTE dm2_install_purge_templates value(dip_package_int)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
    EXECUTE dm2_purge_template_rpt value(dip_package_int)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
   CALL process_readmes("POSTUP",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   IF (currdbuser="V500")
    EXECUTE dm2_code_value_rpt dip_package_int
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
   CALL process_readmes("PREDOWN",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL install_package_schema("DOWNTIME",dip_env_id,dip_package_str)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL process_readmes("POSTDOWN",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL process_readmes("UP",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
  OF "SCHEMA":
   IF (dip_allow_old_modes=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat(dip_install_mode," mode is no longer supported.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (update_table_definitions(dip_install_mode,dip_env_id,dip_package_int)=0)
    GO TO exit_program
   ENDIF
  OF "UTSCHEMA":
   IF (dip_allow_old_modes=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat(dip_install_mode," mode is no longer supported.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (update_table_definitions(dip_install_mode,dip_env_id,dip_package_int)=0)
    GO TO exit_program
   ENDIF
  OF "DTSCHEMA":
   IF (dip_allow_old_modes=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat(dip_install_mode," mode is no longer supported.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (update_table_definitions(dip_install_mode,dip_env_id,dip_package_int)=0)
    GO TO exit_program
   ENDIF
  OF "ALLSCHEMA":
   IF (dip_allow_old_modes=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat(dip_install_mode," mode is no longer supported.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (validate_load(dip_package_int)=0)
    IF ((dm_err->err_ind=0))
     SET dm_err->user_action = "You must first run OCD_INCL_SCHEMA2 in PREVIEW or UPTIME mode."
     SET dm_err->emsg = "Installation Failed.  No package has been loaded."
    ENDIF
    GO TO exit_program
   ENDIF
   CALL dip_load_target("UPTIME",dip_env_id,dip_package_str)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL install_package_schema("UPTIME",dip_env_id,dip_package_str)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL install_package_schema("DOWNTIME",dip_env_id,dip_package_str)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   IF (update_table_definitions(dip_install_mode,dip_env_id,dip_package_int)=0)
    GO TO exit_program
   ENDIF
  OF "ALLBATCHSCHEMA":
   IF (dip_allow_old_modes=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat(dip_install_mode," mode is no longer supported.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (validate_load(dip_package_int)=0)
    IF ((dm_err->err_ind=0))
     SET dm_err->user_action = "You must first run OCD_INCL_SCHEMA2 in BATCHPREVIEW or BATCHUP mode."
     SET dm_err->emsg = "Installation Failed.  No package has been loaded."
    ENDIF
    GO TO exit_program
   ENDIF
   CALL dip_load_target("UPTIME",dip_env_id,dip_package_str)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL install_package_schema("UPTIME",dip_env_id,dip_package_str)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL install_package_schema("DOWNTIME",dip_env_id,dip_package_str)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   IF (update_table_definitions(dip_install_mode,dip_env_id,dip_package_int)=0)
    GO TO exit_program
   ENDIF
  OF "PREREADME":
   IF (dip_allow_old_modes=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat(dip_install_mode," mode is no longer supported.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   CALL process_readmes("PRE",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
  OF "LOAD":
   IF (dip_allow_old_modes=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat(dip_install_mode," mode is no longer supported.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   CALL check_ccl_file(dip_install_mode,dip_env_id,dip_package_str,dip_lm_ind)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
  OF "DIFF":
   IF (dip_allow_old_modes=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat(dip_install_mode," mode is no longer supported.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (validate_load(dip_package_int)=0)
    IF ((dm_err->err_ind=0))
     SET dm_err->user_action = "You must first run OCD_INCL_SCHEMA2 in PREVIEW or UPTIME mode."
     SET dm_err->emsg = "Installation Failed.  No package has been loaded."
    ENDIF
    GO TO exit_program
   ENDIF
   CALL dip_load_target("CHECK",dip_env_id,dip_package_str)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL install_package_schema("CHECK",dip_env_id,dip_package_str)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
  OF "POSTREADME":
   IF (dip_allow_old_modes=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat(dip_install_mode," mode is no longer supported.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   CALL process_readmes("POST",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
  OF "CS":
   IF (dip_allow_old_modes=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat(dip_install_mode," mode is no longer supported.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   CALL install_code_sets(dip_env_name,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
  OF "ATR":
   IF (dip_allow_old_modes=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat(dip_install_mode," mode is no longer supported.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   CALL install_atr(dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL display_atr_reports("R",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
  OF "PREUTS":
   IF (dip_allow_old_modes=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat(dip_install_mode," mode is no longer supported.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   CALL display_readme_est_report(dip_install_mode,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL process_readmes("PREUP",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
  OF "POSTUTS":
   IF (dip_allow_old_modes=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat(dip_install_mode," mode is no longer supported.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   CALL display_readme_est_report(dip_install_mode,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL process_readmes("POSTUP",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
  OF "PREDTS":
   IF (dip_allow_old_modes=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat(dip_install_mode," mode is no longer supported.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   CALL display_readme_est_report(dip_install_mode,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL process_readmes("PREDOWN",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
  OF "POSTDTS":
   IF (dip_allow_old_modes=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat(dip_install_mode," mode is no longer supported.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   CALL display_readme_est_report(dip_install_mode,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL process_readmes("POSTDOWN",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
  OF "POSTINST":
   IF (dip_allow_old_modes=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat(dip_install_mode," mode is no longer supported.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   CALL display_readme_est_report(dip_install_mode,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL dip_process_readme_spc_needs(cnvtupper(dip_install_mode),dip_env_id,dip_package_int,
    "POSTSPCHK")
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL process_readmes("UP",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
  OF "CHECK":
   IF (dip_allow_old_modes=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat(dip_install_mode," mode is no longer supported.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (validate_load(dip_package_int)=0)
    IF ((dm_err->err_ind=0))
     SET dm_err->user_action = "You must first run OCD_INCL_SCHEMA2 in PREVIEW or UPTIME mode."
     SET dm_err->emsg = "Installation Failed.  No package has been loaded."
    ENDIF
    GO TO exit_program
   ENDIF
   CALL dip_load_target("CHECK",dip_env_id,dip_package_str)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL install_package_schema("CHECK",dip_env_id,dip_package_str)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
  OF "BATCHCHECK":
   IF (validate_load(dip_package_int)=0)
    IF ((dm_err->err_ind=0))
     SET dm_err->user_action = "You must first run OCD_INCL_SCHEMA2 in BATCHPREVIEW or BATCHUP mode."
     SET dm_err->emsg = "Installation Failed.  No package has been loaded."
    ENDIF
    GO TO exit_program
   ENDIF
   CALL dip_load_target("CHECK",dip_env_id,dip_package_str)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL install_package_schema("CHECK",dip_env_id,dip_package_str)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
  OF "BATCHPREVIEW":
   IF (dip_set_ccl_traces(null)=0)
    GO TO exit_program
   ENDIF
   IF (validate_load(dip_package_int)=0)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
    CALL create_batch_schema(dip_env_id,dip_package_int)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
   CALL display_readme_est_report(dip_install_mode,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL dip_load_target("PREVIEW",dip_env_id,dip_package_str)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL install_package_schema("PREVIEW",dip_env_id,dip_package_str)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL display_atr_reports("P",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   IF (dip_reset_ccl_traces(null)=0)
    GO TO exit_program
   ENDIF
  OF "BATCHLOAD":
   CALL load_batch_cclfiles(dip_install_mode,dip_package_str,dip_env_id)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
  OF "BATCHUP":
   IF (dip_update_itinerary_step("BATCHUP:SETUP",dip_install_start_dt_tm,cnvtdatetime("01-JAN-1900"),
    dip_package_abs_float,dpl_executing)=0)
    GO TO exit_program
   ENDIF
   IF ((dir_ui_misc->auto_install_ind=1))
    IF (dip_admin_upgrade(dip_install_mode,dip_package_abs_float)=0)
     GO TO exit_program
    ENDIF
    SET dm_err->eproc = "Checking domain configuration for Package installation."
    CALL disp_msg(" ",dm_err->logfile,0)
    EXECUTE dm2_ocd_val_domain
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
    CALL load_batch_package_schema(dip_install_mode,dip_package_str,dip_env_id)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
   IF (validate_load(dip_package_int)=0)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
    CALL create_batch_schema(dip_env_id,dip_package_int)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
   CALL dip_pre_install_schema_sync(dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL get_batch_list_readme(dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL display_readme_est_report(dip_install_mode,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL populate_batch_install_log(olo_readme_report,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   IF (dip_unattended_install_ind=0
    AND (dir_ui_misc->auto_install_ind=0))
    CALL dip_process_readme_spc_needs(cnvtupper(dip_install_mode),dip_env_id,dip_package_int,
     "PRESPCHK")
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
   IF (dip_update_itinerary_step("BATCHUP:SETUP",cnvtdatetime("01-JAN-1900"),cnvtdatetime(curdate,
     curtime3),dip_package_abs_float,dpl_complete)=0)
    GO TO exit_program
   ENDIF
   SET dip_breakout_ind = 0
   WHILE (dip_breakout_ind=0)
    CALL drr_get_process_status("DM2_INSTALL_PKG",dip_package_abs_float,dip_install_status)
    IF (dip_install_status=1)
     CALL install_code_sets(dip_env_name,dip_env_id,dip_package_int)
     IF ((dm_err->err_ind=1))
      GO TO exit_program
     ELSE
      SET dip_breakout_ind = 1
     ENDIF
    ELSEIF (dip_install_status=2)
     IF (dir_perform_wait_interval(null)=0)
      GO TO exit_program
     ENDIF
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat(dm2_process_event_rs->itinerary_key,
      " Install in a Stop status. Exiting.")
     GO TO exit_program
    ENDIF
   ENDWHILE
   CALL populate_batch_install_log(olo_code_sets,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   SET dip_breakout_ind = 0
   WHILE (dip_breakout_ind=0)
    CALL drr_get_process_status("DM2_INSTALL_PKG",dip_package_abs_float,dip_install_status)
    IF (dip_install_status=1)
     IF (dip_update_itinerary_step("BATCHUP:PRE-SCHEMA_READMES",cnvtdatetime(curdate,curtime3),
      cnvtdatetime("01-JAN-1900"),dip_package_abs_float,dpl_executing)=0)
      GO TO exit_program
     ENDIF
     CALL process_readmes("PREUP",dip_env_id,dip_package_int)
     IF ((dm_err->err_ind=1))
      GO TO exit_program
     ENDIF
     CALL populate_batch_install_log(olo_pre_uts,dip_env_id,dip_package_int)
     IF ((dm_err->err_ind=1))
      GO TO exit_program
     ENDIF
     CALL populate_batch_readme_log(dip_env_id,dip_package_int)
     IF ((dm_err->err_ind=1))
      GO TO exit_program
     ELSE
      SET dip_breakout_ind = 1
     ENDIF
    ELSEIF (dip_install_status=2)
     IF (dir_perform_wait_interval(null)=0)
      GO TO exit_program
     ENDIF
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat(dm2_process_event_rs->itinerary_key,
      " Install in a Stop status. Exiting.")
     GO TO exit_program
    ENDIF
   ENDWHILE
   IF (checkprg("DM_DAF_INSTALL_PRE_SCHEMA") > 0
    AND currdbuser="V500")
    EXECUTE dm_daf_install_pre_schema
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
   IF (dip_update_itinerary_step("BATCHUP:PRE-SCHEMA_READMES",cnvtdatetime("01-JAN-1900"),
    cnvtdatetime(curdate,curtime3),dip_package_abs_float,dpl_complete)=0)
    GO TO exit_program
   ENDIF
   IF (dip_set_ccl_traces(null)=0)
    GO TO exit_program
   ENDIF
   SET dip_breakout_ind = 0
   WHILE (dip_breakout_ind=0)
    CALL drr_get_process_status("DM2_INSTALL_PKG",dip_package_abs_float,dip_install_status)
    IF (dip_install_status=1)
     IF (dip_update_itinerary_step("BATCHUP:SCHEMA",cnvtdatetime(curdate,curtime3),cnvtdatetime(
       "01-JAN-1900"),dip_package_abs_float,dpl_executing)=0)
      GO TO exit_program
     ENDIF
     CALL dip_load_target("UPTIME",dip_env_id,dip_package_str)
     IF ((dm_err->err_ind=1))
      GO TO exit_program
     ENDIF
     CALL install_package_schema("UPTIME",dip_env_id,dip_package_str)
     IF ((dm_err->err_ind=1))
      GO TO exit_program
     ENDIF
     CALL populate_batch_install_log(olo_uptime_schema,dip_env_id,dip_package_int)
     IF ((dm_err->err_ind=1))
      GO TO exit_program
     ELSE
      SET dip_breakout_ind = 1
     ENDIF
     EXECUTE dm2_dm_flags_local_load dip_package_abs_float
     IF ((dm_err->err_ind=1))
      GO TO exit_program
     ENDIF
    ELSEIF (dip_install_status=2)
     IF (dir_perform_wait_interval(null)=0)
      GO TO exit_program
     ENDIF
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat(dm2_process_event_rs->itinerary_key,
      " Install in a Stop status. Exiting.")
     GO TO exit_program
    ENDIF
   ENDWHILE
   IF (dip_update_itinerary_step("BATCHUP:SCHEMA",cnvtdatetime("01-JAN-1900"),cnvtdatetime(curdate,
     curtime3),dip_package_abs_float,dpl_complete)=0)
    GO TO exit_program
   ENDIF
   IF (dip_reset_ccl_traces(null)=0)
    GO TO exit_program
   ENDIF
   IF ((dir_ui_misc->auto_install_ind=0))
    CALL dip_process_readme_spc_needs(cnvtupper(dip_install_mode),dip_env_id,dip_package_int,
     "POSTSPCHK")
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
   SET dip_breakout_ind = 0
   WHILE (dip_breakout_ind=0)
    CALL drr_get_process_status("DM2_INSTALL_PKG",dip_package_abs_float,dip_install_status)
    IF (dip_install_status=1)
     CALL install_atr(dip_env_id,dip_package_int)
     IF ((dm_err->err_ind=1))
      GO TO exit_program
     ENDIF
     CALL display_atr_reports("R",dip_env_id,dip_package_int)
     IF ((dm_err->err_ind=1))
      GO TO exit_program
     ENDIF
     CALL populate_batch_install_log(olo_atrs,dip_env_id,dip_package_int)
     IF ((dm_err->err_ind=1))
      GO TO exit_program
     ELSE
      SET dip_breakout_ind = 1
     ENDIF
    ELSEIF (dip_install_status=2)
     IF (dir_perform_wait_interval(null)=0)
      GO TO exit_program
     ENDIF
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat(dm2_process_event_rs->itinerary_key,
      " Install in a Stop status. Exiting.")
     GO TO exit_program
    ENDIF
   ENDWHILE
   IF (currdbuser="V500")
    SET dip_breakout_ind = 0
    WHILE (dip_breakout_ind=0)
     CALL drr_get_process_status("DM2_INSTALL_PKG",dip_package_abs_float,dip_install_status)
     IF (dip_install_status=1)
      IF (dip_update_itinerary_step("BATCHUP:PURGE_TEMPLATES",cnvtdatetime(curdate,curtime3),
       cnvtdatetime("01-JAN-1900"),dip_package_abs_float,dpl_executing)=0)
       GO TO exit_program
      ENDIF
      CALL dpl_upd_dped_last_status(dir_ui_misc->dm_process_event_id,
       "Performing Purge Template installation.",0.0,cnvtdatetime(curdate,curtime3))
      EXECUTE dm2_install_purge_templates value(dip_package_int)
      IF ((dm_err->err_ind=1))
       GO TO exit_program
      ENDIF
      EXECUTE dm2_purge_template_rpt value(dip_package_int)
      IF ((dm_err->err_ind=1))
       GO TO exit_program
      ELSE
       SET dip_breakout_ind = 1
      ENDIF
     ELSEIF (dip_install_status=2)
      IF (dir_perform_wait_interval(null)=0)
       GO TO exit_program
      ENDIF
     ELSE
      SET dm_err->err_ind = 1
      SET dm_err->emsg = concat(dm2_process_event_rs->itinerary_key,
       " Install in a Stop status. Exiting.")
      GO TO exit_program
     ENDIF
    ENDWHILE
    IF (dip_update_itinerary_step("BATCHUP:PURGE_TEMPLATES",cnvtdatetime("01-JAN-1900"),cnvtdatetime(
      curdate,curtime3),dip_package_abs_float,dpl_complete)=0)
     GO TO exit_program
    ENDIF
   ENDIF
   SET dip_breakout_ind = 0
   WHILE (dip_breakout_ind=0)
    CALL drr_get_process_status("DM2_INSTALL_PKG",dip_package_abs_float,dip_install_status)
    IF (dip_install_status=1)
     IF (dip_update_itinerary_step("BATCHUP:POST-SCHEMA_READMES",cnvtdatetime(curdate,curtime3),
      cnvtdatetime("01-JAN-1900"),dip_package_abs_float,dpl_executing)=0)
      GO TO exit_program
     ENDIF
     IF (checkprg("DM_DAF_INSTALL_POST_SCHEMA") > 0
      AND currdbuser="V500")
      EXECUTE dm_daf_install_post_schema
      IF ((dm_err->err_ind=1))
       GO TO exit_program
      ENDIF
     ENDIF
     CALL process_readmes("POSTUP",dip_env_id,dip_package_int)
     IF ((dm_err->err_ind=1))
      GO TO exit_program
     ENDIF
     CALL populate_batch_install_log(olo_post_uts,dip_env_id,dip_package_int)
     IF ((dm_err->err_ind=1))
      GO TO exit_program
     ENDIF
     CALL populate_batch_readme_log(dip_env_id,dip_package_int)
     IF ((dm_err->err_ind=1))
      GO TO exit_program
     ELSE
      SET dip_breakout_ind = 1
     ENDIF
    ELSEIF (dip_install_status=2)
     IF (dir_perform_wait_interval(null)=0)
      GO TO exit_program
     ENDIF
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat(dm2_process_event_rs->itinerary_key,
      " Install in a Stop status. Exiting.")
     GO TO exit_program
    ENDIF
   ENDWHILE
   IF (dip_update_itinerary_step("BATCHUP:POST-SCHEMA_READMES",cnvtdatetime("01-JAN-1900"),
    cnvtdatetime(curdate,curtime3),dip_package_abs_float,dpl_complete)=0)
    GO TO exit_program
   ENDIF
   IF (checkprg("EHI_LOAD_COL_EXP") > 0
    AND currdbuser="V500")
    EXECUTE ehi_load_col_exp "PACKAGE", dip_package_abs_int
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ELSE
    IF ((dm_err->debug_flag > 0))
     SET dm_err->eproc = concat(
      "Skipping load of ehi column exclusions as necessary load script does not exist ",
      "and/or current user is not V500.")
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
   ENDIF
   IF (currdbuser="V500")
    EXECUTE dm2_code_value_rpt dip_package_int
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
  OF "BATCHPRECYCLE":
   IF (dip_install_plan_type="NO-DT")
    IF (dip_update_itinerary_step("BATCHPRECYCLE:READMES",cnvtdatetime(curdate,curtime3),cnvtdatetime
     ("01-JAN-1900"),dip_package_abs_float,dpl_executing)=0)
     GO TO exit_program
    ENDIF
    CALL get_batch_list_readme(dip_package_int)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
    CALL display_readme_est_report(dip_install_mode,dip_env_id,dip_package_int)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
    CALL process_readmes("PRECYCLE",dip_env_id,dip_package_int)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
    CALL populate_batch_install_log(olo_pre_cycle,dip_env_id,dip_package_int)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
    CALL populate_batch_readme_log(dip_env_id,dip_package_int)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
    IF (dip_update_itinerary_step("BATCHPRECYCLE:READMES",cnvtdatetime("01-JAN-1900"),cnvtdatetime(
      curdate,curtime3),dip_package_abs_float,dpl_complete)=0)
     GO TO exit_program
    ENDIF
   ENDIF
  OF "BATCHDOWN":
   IF (dip_update_itinerary_step("BATCHDOWN:READMES",cnvtdatetime(curdate,curtime3),cnvtdatetime(
     "01-JAN-1900"),dip_package_abs_float,dpl_executing)=0)
    GO TO exit_program
   ENDIF
   IF (dip_install_plan_type="NO-DT")
    SET dm_err->err_ind = 1
    SET dm_err->eproc = build("BATCHDOWN mode improperly requested for No Downtime Plan <",
     dip_package_int,">.  Exiting.")
    SET dm_err->emsg = build("BATCHDOWN mode improperly requested for No Downtime Plan <",
     dip_package_int,">.  Exiting.")
    CALL end_status(dm_err->eproc,dip_env_id,dip_package_int)
    GO TO exit_program
   ENDIF
   SET ocd_op->pre_op = olo_post_uts
   SET ocd_op->cur_op = olo_pre_dts
   SET ocd_op->next_op = olo_downtime_schema
   IF (check_package_op(ocd_op->pre_op,dip_package_int,dip_env_id)=0)
    SET dm_err->err_ind = 1
    CALL bad_package_op(ocd_op->cur_op,ocd_op->pre_op,dip_env_id,dip_package_int)
    GO TO exit_program
   ENDIF
   IF (checkprg("DM_DAF_INSTALL_PRE_BATCHDOWN") > 0
    AND currdbuser="V500")
    EXECUTE dm_daf_install_pre_batchdown
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
   CALL dpl_upd_dped_last_status(dir_ui_misc->dm_process_event_id,"Loading readme information.",0.0,
    cnvtdatetime(curdate,curtime3))
   CALL get_batch_list_readme(dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   IF (((dip_predown_on_plan_ind=1) OR (dip_postdown_on_plan_ind=1)) )
    SET dm2_rr_misc->package_number = dip_package_int
    SET dm2_rr_misc->execution = "ALL"
    SET dm2_rr_misc->process_type = "PI"
    SET dm2_rr_misc->env_id = dip_env_id
    IF (drr_load_readmes_to_run(null)=0)
     GO TO exit_program
    ENDIF
   ENDIF
   CALL dpl_upd_dped_last_status(dir_ui_misc->dm_process_event_id,
    "Determining if readmes are available to execute.",0.0,cnvtdatetime(curdate,curtime3))
   SET dm_err->eproc = "Determining if there are any PRECYCLE readmes to run."
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(drr_readmes_to_run->readme_cnt))
    WHERE (drr_readmes_to_run->readme[d.seq].skip=0)
     AND (drr_readmes_to_run->readme[d.seq].execution="PRECYCLE")
    DETAIL
     dip_exec_readme_precycle_ind = 1
    WITH nocounter, maxqual(d,1)
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    GO TO exit_program
   ENDIF
   SET dm_err->eproc = "Determining if there are any PREDOWN readmes to run."
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(drr_readmes_to_run->readme_cnt))
    WHERE (drr_readmes_to_run->readme[d.seq].skip=0)
     AND (drr_readmes_to_run->readme[d.seq].execution="PREDOWN")
    DETAIL
     dip_exec_readme_predown_ind = 1
    WITH nocounter, maxqual(d,1)
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    GO TO exit_program
   ENDIF
   SET dm_err->eproc = "Determining if there are any POSTDOWN readmes to run."
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(drr_readmes_to_run->readme_cnt))
    WHERE (drr_readmes_to_run->readme[d.seq].skip=0)
     AND (drr_readmes_to_run->readme[d.seq].execution="POSTDOWN")
    DETAIL
     dip_exec_readme_postdown_ind = 1
    WITH nocounter, maxqual(d,1)
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    GO TO exit_program
   ENDIF
   CALL populate_batch_install_log(olo_readme_report,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL dpl_upd_dped_last_status(dir_ui_misc->dm_process_event_id,"Processing readmes.",0.0,
    cnvtdatetime(curdate,curtime3))
   IF (dip_exec_readme_precycle_ind=1)
    CALL process_readmes("PRECYCLE",dip_env_id,dip_package_int)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ELSE
    CALL log_package_op(olo_pre_cycle,ols_complete,"Finished executing all PRECYCLE Readmes steps",
     dip_env_id,dip_package_int)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
    CALL end_status("Finished executing all PRECYCLE Readmes steps",dip_env_id,dip_package_int)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
   CALL populate_batch_install_log(olo_pre_cycle,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL populate_batch_readme_log(dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   IF (dip_exec_readme_predown_ind=1)
    CALL process_readmes("PREDOWN",dip_env_id,dip_package_int)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ELSE
    CALL log_package_op(olo_pre_dts,ols_complete,"Finished executing all Pre-DTS Readmes steps",
     dip_env_id,dip_package_int)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
    CALL end_status("Finished executing all Pre-DTS Readmes steps",dip_env_id,dip_package_int)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
   CALL populate_batch_install_log(olo_pre_dts,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL populate_batch_readme_log(dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL install_package_schema("DOWNTIME",dip_env_id,dip_package_str)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL populate_batch_install_log(olo_downtime_schema,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   IF (dip_exec_readme_postdown_ind=1)
    CALL process_readmes("POSTDOWN",dip_env_id,dip_package_int)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ELSE
    CALL log_package_op(olo_post_dts,ols_complete,"Finished executing all Post-DTS Readmes steps",
     dip_env_id,dip_package_int)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
    CALL end_status("Finished executing all Post-DTS Readmes steps",dip_env_id,dip_package_int)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
   CALL populate_batch_install_log(olo_post_dts,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL populate_batch_readme_log(dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   IF (checkprg("DM_DAF_INSTALL_POST_BATCHDOWN") > 0
    AND currdbuser="V500")
    EXECUTE dm_daf_install_post_batchdown
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
   IF (dip_update_itinerary_step("BATCHDOWN:READMES",cnvtdatetime("01-JAN-1900"),cnvtdatetime(curdate,
     curtime3),dip_package_abs_float,dpl_complete)=0)
    GO TO exit_program
   ENDIF
  OF "BATCHPOST":
   IF (dip_update_itinerary_step("BATCHPOST:READMES",cnvtdatetime(curdate,curtime3),cnvtdatetime(
     "01-JAN-1900"),dip_package_abs_float,dpl_executing)=0)
    GO TO exit_program
   ENDIF
   IF (checkprg("DM_DAF_INSTALL_PRE_BATCHPOST") > 0
    AND currdbuser="V500")
    EXECUTE dm_daf_install_pre_batchpost
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
   IF (dip_autosuccess_batchdown_ind=1)
    CALL autosuccess_downtime_ops(dip_env_id,dip_package_int)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
   CALL get_batch_list_readme(dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL display_readme_est_report(dip_install_mode,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   IF (dip_unattended_install_ind=0
    AND (dir_ui_misc->auto_install_ind=0))
    CALL dip_process_readme_spc_needs(cnvtupper(dip_install_mode),dip_env_id,dip_package_int,
     "POSTSPCHK")
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
   CALL process_readmes("UP",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL populate_batch_install_log(olo_post_inst,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL populate_batch_readme_log(dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   IF (checkprg("DM_DAF_INSTALL_POST_BATCHPOST") > 0
    AND currdbuser="V500")
    EXECUTE dm_daf_install_post_batchpost
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
   IF (dip_update_itinerary_step("BATCHPOST:READMES",cnvtdatetime("01-JAN-1900"),cnvtdatetime(curdate,
     curtime3),dip_package_abs_float,dpl_complete)=0)
    GO TO exit_program
   ENDIF
  OF "UTBATCH":
   IF (checkprg("DM_DAF_INSTALL_PRE_UTBATCH") > 0
    AND currdbuser="V500")
    EXECUTE dm_daf_install_pre_utbatch
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
   IF (update_table_definitions(dip_install_mode,dip_env_id,dip_package_int)=0)
    GO TO exit_program
   ENDIF
   IF (checkprg("DM_DAF_INSTALL_POST_UTBATCH") > 0
    AND currdbuser="V500")
    EXECUTE dm_daf_install_post_utbatch
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
  OF "BATCHEXPRESS":
   IF (validate_load(dip_package_int)=0)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
    CALL create_batch_schema(dip_env_id,dip_package_int)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
   CALL get_batch_list_readme(dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL display_readme_est_report(dip_install_mode,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL populate_batch_install_log(olo_readme_report,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL dip_process_readme_spc_needs(cnvtupper(dip_install_mode),dip_env_id,dip_package_int,
    "PRESPCHK")
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL install_code_sets(dip_env_name,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL populate_batch_install_log(olo_code_sets,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL process_readmes("PREUP",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL populate_batch_install_log(olo_pre_uts,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL populate_batch_readme_log(dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   IF (checkprg("DM_DAF_INSTALL_PRE_SCHEMA") > 0
    AND currdbuser="V500")
    EXECUTE dm_daf_install_pre_schema
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
   CALL dip_load_target("UPTIME",dip_env_id,dip_package_str)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL install_package_schema("UPTIME",dip_env_id,dip_package_str)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL populate_batch_install_log(olo_uptime_schema,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   IF (checkprg("DM_DAF_INSTALL_POST_SCHEMA") > 0
    AND currdbuser="V500")
    EXECUTE dm_daf_install_post_schema
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
   CALL dip_process_readme_spc_needs(cnvtupper(dip_install_mode),dip_env_id,dip_package_int,
    "POSTSPCHK")
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL install_atr(dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL display_atr_reports("R",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL populate_batch_install_log(olo_atrs,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   IF (currdbuser="V500")
    EXECUTE dm2_install_purge_templates value(dip_package_int)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
    EXECUTE dm2_purge_template_rpt value(dip_package_int)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
   CALL process_readmes("POSTUP",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL populate_batch_install_log(olo_post_uts,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL populate_batch_readme_log(dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   IF (currdbuser="V500")
    EXECUTE dm2_code_value_rpt dip_package_int
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
   CALL process_readmes("PRECYCLE",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL populate_batch_install_log(olo_pre_cycle,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL populate_batch_readme_log(dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   IF (checkprg("DM_DAF_INSTALL_PRE_BATCHDOWN") > 0
    AND currdbuser="V500")
    EXECUTE dm_daf_install_pre_batchdown
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
   CALL process_readmes("PREDOWN",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL populate_batch_install_log(olo_pre_dts,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL populate_batch_readme_log(dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL install_package_schema("DOWNTIME",dip_env_id,dip_package_str)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL populate_batch_install_log(olo_downtime_schema,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL process_readmes("POSTDOWN",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL populate_batch_install_log(olo_post_dts,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL populate_batch_readme_log(dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   IF (checkprg("DM_DAF_INSTALL_POST_BATCHDOWN") > 0
    AND currdbuser="V500")
    EXECUTE dm_daf_install_post_batchdown
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
   IF (checkprg("DM_DAF_INSTALL_PRE_BATCHPOST") > 0
    AND currdbuser="V500")
    EXECUTE dm_daf_install_pre_batchpost
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
   CALL process_readmes("UP",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL populate_batch_install_log(olo_post_inst,dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL populate_batch_readme_log(dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   IF (checkprg("DM_DAF_INSTALL_POST_BATCHPOST") > 0
    AND currdbuser="V500")
    EXECUTE dm_daf_install_post_batchpost
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
  OF "BATCHSCHEMA":
   IF (update_table_definitions(dip_install_mode,dip_env_id,dip_package_int)=0)
    GO TO exit_program
   ENDIF
  OF "DTBATCH":
   CALL echo("Auto Success DTBATCH mode.")
  ELSE
   CALL end_status(concat("Installation Failed. ",dip_install_mode,
     "is not a valid mode of installation."),dip_env_id,dip_package_int)
   GO TO exit_program
 ENDCASE
 IF (cnvtupper(trim(dip_install_mode,3)) IN ("PREVIEW", "BATCHPREVIEW"))
  IF (cnvtupper(trim(dip_install_mode,3))="BATCHPREVIEW")
   DECLARE d_item = i4 WITH public, noconstant(0)
   FOR (d_item = 1 TO size(batch_list->qual,5))
    CALL delete_preview_log(dip_env_id,batch_list->qual[d_item].package_number)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDFOR
  ENDIF
  CALL delete_preview_log(dip_env_id,dip_package_int)
  IF ((dm_err->err_ind=1))
   GO TO exit_program
  ENDIF
  SET dm_err->eproc = concat(dip_install_mode," mode successful."," If no diff report was displayed,",
   " no schema differences found.")
  CALL disp_msg(" ",dm_err->logfile,0)
  IF (write_dol_row(dip_env_id,olpt_install_info,olo_preview_complete,1,dip_package_int,
   cnvtdatetime(curdate,curtime3),ols_complete,null,cnvtdatetime(curdate,curtime3),0,
   0.0,concat("Mode:",dip_install_mode),1)=0)
   GO TO exit_program
  ENDIF
 ELSEIF (dip_install_mode IN ("DIFF", "CHECK", "BATCHCHECK"))
  CALL end_status(concat(dip_install_mode,
    " mode successful. If no diff report was displayed, no schema differences found."),dip_env_id,
   dip_package_int)
 ELSE
  IF ((dm2_install_pkg->process_option="SINGLEPKG"))
   CALL end_status(concat(dip_install_mode," mode was successful for Package ",dip_package_str,"."),
    dip_env_id,dip_package_int)
   IF (dir_silmode_requested_ind=1)
    IF (silmode_summary(concat(dip_install_mode," mode was successful for Package ",dip_package_str,
      "."),dip_env_id,dip_package_int,dip_logfile_prefix)=0)
     GO TO exit_program
    ENDIF
   ENDIF
  ELSE
   CALL end_status(concat(dip_install_mode," mode was successful for Plan ID ",build(
      dip_package_abs_int),"."),dip_env_id,dip_package_int)
   IF ((dnotify->status=1)
    AND (dm2_process_event_rs->ui_allowed_ind=1))
    FREE RECORD dip_inst_rpt
    RECORD dip_inst_rpt(
      1 rpt_cnt = i2
      1 rpt[*]
        2 rpt_title = vc
        2 rpt_name = vc
    )
    IF (dip_install_mode="BATCHUP")
     SET dm_err->eproc = "Gather installation reports."
     SELECT INTO "nl:"
      FROM dm_process_event_dtl dtl
      WHERE (dtl.dm_process_event_id=dir_ui_misc->dm_process_event_id)
       AND dtl.detail_type IN ("RPT:*")
      DETAIL
       IF (dtl.detail_type="RPT:APPLICATIONS INSTALLED")
        dip_inst_rpt->rpt_cnt = (dip_inst_rpt->rpt_cnt+ 1), stat = alterlist(dip_inst_rpt->rpt,
         dip_inst_rpt->rpt_cnt), dip_inst_rpt->rpt[dip_inst_rpt->rpt_cnt].rpt_title =
        "APPLICATIONS INSTALLED (assign Millennium authorization for new applications)",
        dip_inst_rpt->rpt[dip_inst_rpt->rpt_cnt].rpt_name = dtl.detail_text
       ELSEIF (dtl.detail_type="RPT:TASKS INSTALLED")
        dip_inst_rpt->rpt_cnt = (dip_inst_rpt->rpt_cnt+ 1), stat = alterlist(dip_inst_rpt->rpt,
         dip_inst_rpt->rpt_cnt), dip_inst_rpt->rpt[dip_inst_rpt->rpt_cnt].rpt_title =
        "TASKS INSTALLED (assign Millennium authorization for new tasks)",
        dip_inst_rpt->rpt[dip_inst_rpt->rpt_cnt].rpt_name = dtl.detail_text
       ELSEIF (dtl.detail_type="RPT:CODE VALUES INSTALLED")
        dip_inst_rpt->rpt_cnt = (dip_inst_rpt->rpt_cnt+ 1), stat = alterlist(dip_inst_rpt->rpt,
         dip_inst_rpt->rpt_cnt), dip_inst_rpt->rpt[dip_inst_rpt->rpt_cnt].rpt_title =
        "CODE SETS INSTALLED",
        dip_inst_rpt->rpt[dip_inst_rpt->rpt_cnt].rpt_name = dtl.detail_text
       ELSEIF (dtl.detail_type="RPT:PURGE TEMPLATES INSTALLED")
        dip_inst_rpt->rpt_cnt = (dip_inst_rpt->rpt_cnt+ 1), stat = alterlist(dip_inst_rpt->rpt,
         dip_inst_rpt->rpt_cnt), dip_inst_rpt->rpt[dip_inst_rpt->rpt_cnt].rpt_title =
        "PURGE TEMPLATES INSTALLED (to configure and (re)activate modified or new Purge Templates)",
        dip_inst_rpt->rpt[dip_inst_rpt->rpt_cnt].rpt_name = dtl.detail_text
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      GO TO exit_program
     ENDIF
    ENDIF
    SET dnotify->process = "INSTALLPLAN"
    SET dnotify->install_status = dpl_complete
    SET dnotify->event = dip_install_mode
    SET dnotify->mode = dip_install_mode
    SET dnotify->plan_id = dip_package_abs_float
    SET dnotify->msgtype = dpl_progress
    CALL dn_add_body_text(concat(dip_install_mode," Installation is complete for Plan ",trim(
       cnvtstring(dip_package_abs_float)),", Environment ",dip_env_name,
      " at ",format(cnvtdatetime(curdate,curtime3),";;q")),1)
    IF ((dip_inst_rpt->rpt_cnt > 0))
     CALL dn_add_body_text(" ",0)
     CALL dn_add_body_text("Installation Reports can be viewed at the following location:",0)
     CALL dn_add_body_text(" ",0)
     CALL dn_add_body_text(concat(" ccl | dm2_install_plan_menu go | Select Plan ",trim(cnvtstring(
         dip_package_abs_float))," | Installation Reports | View ALL Install Reports"),0)
     CALL dn_add_body_text(" ",0)
     CALL dn_add_body_text("The following Install Reports should be reviewed for potential action:",0
      )
     CALL dn_add_body_text(" ",0)
     FOR (d_item = 1 TO dip_inst_rpt->rpt_cnt)
      CALL dn_add_body_text(dip_inst_rpt->rpt[d_item].rpt_title,0)
      CALL dn_add_body_text(concat("   ",dip_inst_rpt->rpt[d_item].rpt_name),0)
     ENDFOR
    ENDIF
    SET dm2_process_event_rs->begin_dt_tm = cnvtdatetime(curdate,curtime3)
    SET dm2_process_event_rs->status = dpl_complete
    SET dm2_process_event_rs->end_dt_tm = cnvtdatetime(curdate,curtime3)
    SET dm2_process_event_rs->install_plan_id = dip_package_abs_int
    CALL dm2_process_log_add_detail_text(dpl_audit_name,concat("EMAIL:",dip_install_mode,"-COMPLETE")
     )
    CALL dm2_process_log_add_detail_text(dpl_audit_type,dpl_progress)
    IF (dn_notify(null)=0)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dip_inst_rpt)
    ENDIF
    FREE RECORD dip_inst_rpt
    SET dm2_process_event_rs->begin_dt_tm = cnvtdatetime(curdate,curtime3)
    SET dm2_process_event_rs->status = dpl_complete
    SET dm2_process_event_rs->end_dt_tm = cnvtdatetime(curdate,curtime3)
    SET dm2_process_event_rs->install_plan_id = dip_package_abs_int
    CALL dm2_process_log_add_detail_text(dpl_audit_name,concat(dip_install_mode," COMPLETE"))
    CALL dm2_process_log_add_detail_text(dpl_audit_type,dpl_progress)
    CALL dm2_process_log_row(dpl_package_install,dpl_auditlog,dpl_no_prev_id,1)
   ELSE
    IF (dir_silmode_requested_ind=1
     AND dip_install_mode != "BATCHDOWN")
     IF (silmode_summary(concat(dip_install_mode," mode was successful for Plan ID ",build(
        dip_package_abs_int),"."),dip_env_id,dip_package_int,dip_logfile_prefix)=0)
      GO TO exit_program
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 GO TO exit_program
 SUBROUTINE program_initialization(null)
   RECORD pi_reply(
     1 auto_install_ind = i2
     1 check_list_cnt = i4
     1 check_list[*]
       2 check_name = vc
       2 check_passed_ind = i2
       2 check_txt = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   DECLARE pi_pkg_str_tmp = vc WITH protect, noconstant("")
   DECLARE pi_install_plan_type = vc WITH protect, noconstant("")
   DECLARE pi_u_name = vc WITH protect, noconstant("")
   DECLARE pi_cs = vc WITH protect, noconstant("")
   DECLARE pi_idx = i4 WITH protect, noconstant(0)
   DECLARE pi_src_envname = vc WITH protect, noconstant("")
   DECLARE pi_tmp_info_name = vc WITH protect, noconstant("")
   DECLARE pi_tmp_info_domain = vc WITH protect, noconstant("")
   DECLARE pi_tmp_status = vc WITH protect, noconstant("")
   DECLARE pi_tmp_mode = vc WITH protect, noconstant("")
   DECLARE pi_bypass_node_check = i2 WITH protect, noconstant(0)
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc = concat("curprog is ",dm2_install_schema->curprog,".")
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (cnvtupper(dm2_install_schema->curprog) != "OCD_INCL_SCHEMA2")
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Verifying that DM2_INSTALL_PKG was called by OCD_INCL_SCHEMA2."
    SET dm_err->emsg = "This program cannot be executed directly."
    SET dm_err->user_action = "Please use OCD_INCL_SCHEMA2 instead."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Beginning initialization steps. Validating input."
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (( $1 <= 0))
    SET dm_err->emsg = "Installation Failed. Install Plan or Package Number was not a valid number."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dip_install_mode = cnvtupper( $2)
   IF (dip_install_mode="*BATCH*")
    SET dip_package_str = build("-", $1)
    SET dip_package_int = ( $1 * - (1))
    SET pi_pkg_str_tmp = build("b", $1)
    SET dm2_install_pkg->process_option = "BATCHPKG"
   ELSE
    SET dip_package_str = format( $1,"######;P0")
    SET dip_package_int =  $1
    SET pi_pkg_str_tmp = build("s", $1)
    SET dm2_install_pkg->process_option = "SINGLEPKG"
   ENDIF
   SET dip_package_abs_int = abs(dip_package_int)
   SET dip_package_abs_float = cnvtreal(abs(dip_package_int))
   SET dip_package_float = cnvtreal(dip_package_int)
   SET dir_ui_misc->auto_install_ind = 0
   IF (dip_install_mode="*BG")
    IF (dip_install_mode="*ABG")
     SET dir_ui_misc->auto_install_ind = 1
     SET dip_install_mode = replace(dip_install_mode,"ABG","",2)
    ELSE
     SET dip_install_mode = replace(dip_install_mode,"BG","",2)
    ENDIF
    SET dir_ui_misc->background_ind = 1
    SET dip_unattended_install_ind = 1
    SET dir_silmode_requested_ind = 1
   ELSE
    SET dir_ui_misc->auto_install_ind = 0
    SET dir_ui_misc->background_ind = 0
   ENDIF
   IF ((dir_ui_misc->auto_install_ind=1))
    EXECUTE dm2_auto_install_verify  WITH replace("REPLY","PI_REPLY")
    IF ((dm_err->err_ind=1))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF ((pi_reply->auto_install_ind=0))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validating dm2_auto_install_verify"
     SET dm_err->emsg = "Please account for all pre_requisites to initiate Auto Installation"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_ui_misc->auto_install_ind=1))
    IF (dctx_set_context("FIRE_LUTS_TRG","YES")=0)
     RETURN(0)
    ENDIF
    IF (dctx_set_context("DBARCH_PACK_INST","YES")=0)
     RETURN(0)
    ENDIF
    IF (dctx_set_context("FIRE_EA_TRG","NO")=0)
     RETURN(0)
    ENDIF
    IF (dctx_set_context("FIRE_REFCHG_TRG","NO")=0)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 1))
     CALL echo("After turning triggers off...")
     SELECT INTO noforms
      namespace, attribute, val = substring(1,30,value)
      FROM v$context
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   SET dm2_install_schema->schema_prefix = "dm2o"
   SET dm2_install_schema->file_prefix = dip_package_str
   CASE (dip_install_mode)
    OF "*PREVIEW":
     SET dm2_install_schema->process_option = "PREVIEW"
    OF "*CHECK":
     SET dm2_install_schema->process_option = "CHECK"
    OF "DIFF":
     SET dm2_install_schema->process_option = "CHECK"
    ELSE
     SET dm2_install_schema->process_option = "CLIN UPGRADE"
   ENDCASE
   SET dip_logfile_prefix = concat("dm2installpkg",pi_pkg_str_tmp,"_")
   IF (check_logfile(dip_logfile_prefix,".log","DM2_INSTALL_PKG LOGFILE")=0)
    RETURN(0)
   ENDIF
   SET dm2_install_schema->logfile_prefix = substring(1,(findstring(".",dm_err->logfile) - 1),dm_err
    ->logfile)
   SET dm_err->eproc = "Beginning package installation."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET width = 132
   SET reqinfo->updt_task = dm2_install_schema->dm2_updt_task_value
   IF ((dm_err->debug_flag > 0))
    CALL echo(dm_err->asterisk_line)
    CALL echo(build("reqinfo->updt_task=",reqinfo->updt_task))
    CALL echo(dm_err->asterisk_line)
   ENDIF
   IF (validate(call_script,"Z")="Z")
    SET call_script = "OCD_INCL_SCHEMA"
   ENDIF
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc = concat("CALL_SCRIPT initialized to ",call_script)
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (call_script != "DM_OCD_MENU")
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE info_domain="DM2INSTALLPKG:CCL_TRACE"
     HEAD REPORT
      lvidx = 0
     DETAIL
      lvidx = locateval(lvidx,1,ccl_trace_list->trace_cnt,cnvtupper(di.info_name),ccl_trace_list->
       qual[lvidx].trace_name)
      IF (lvidx > 0)
       ccl_trace_list->qual[lvidx].active_status_new = di.info_number
      ELSE
       ccl_trace_list->trace_cnt = (ccl_trace_list->trace_cnt+ 1), stat = alterlist(ccl_trace_list->
        qual,ccl_trace_list->trace_cnt), ccl_trace_list->qual[ccl_trace_list->trace_cnt].trace_name
        = cnvtupper(di.info_name),
       ccl_trace_list->qual[ccl_trace_list->trace_cnt].active_status_new = di.info_number
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error("Error getting ccl trace overrides from DM_INFO.")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    FOR (pi_idx = 1 TO ccl_trace_list->trace_cnt)
      SET ccl_trace_list->qual[pi_idx].active_status_orig = trace(ccl_trace_list->qual[pi_idx].
       trace_name)
    ENDFOR
    CALL echorecord(ccl_trace_list)
    SET dm2_install_schema->target_dbase_name = currdbname
    SET dm2_install_schema->dbase_name = dm2_install_schema->target_dbase_name
    SET pi_u_name = currdbuser
    SET dm2_install_schema->u_name = pi_u_name
    IF ((dir_ui_misc->background_ind=1))
     SET dm_err->eproc = "Obtain connection information."
     SELECT INTO "nl:"
      FROM dm_environment d
      WHERE d.environment_id IN (
      (SELECT
       di.info_number
       FROM dm_info di
       WHERE di.info_domain="DATA MANAGEMENT"
        AND di.info_name="DM_ENV_ID"))
      DETAIL
       dm2_install_schema->p_word = substring((findstring("/",d.v500_connect_string,1,0)+ 1),((
        findstring("@",d.v500_connect_string,1,0) - findstring("/",d.v500_connect_string,1,0)) - 1),d
        .v500_connect_string), dm2_install_schema->connect_str = substring((findstring("@",d
         .v500_connect_string,1,0)+ 1),((textlen(trim(d.v500_connect_string)) - findstring("@",d
         .v500_connect_string,1,0))+ 1),d.v500_connect_string)
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (((curqual=0) OR ((((dm2_install_schema->v500_p_word="")) OR ((dm2_install_schema->
     v500_connect_str=""))) )) )
      IF ((dm_err->debug_flag > 0))
       CALL echorecord(dm2_install_schema)
      ENDIF
      SET dm_err->err_ind = 1
      SET dm_err->emsg = "Unable to obtain connection information."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET dm2_force_connect_string = 1
     EXECUTE dm2_connect_to_dbase "CO"
     SET dm2_force_connect_string = 0
    ELSE
     IF ((((dm2_install_schema->target_dbase_name="NONE")) OR ((((dm2_install_schema->v500_p_word=
     "NONE")) OR ((dm2_install_schema->v500_connect_str="NONE"))) )) )
      SET dm2_force_connect_string = 1
      EXECUTE dm2_connect_to_dbase "PC"
      SET dm2_force_connect_string = 0
     ENDIF
    ENDIF
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    SET dm2_install_schema->v500_p_word = dm2_install_schema->p_word
    SET dm2_install_schema->v500_connect_str = dm2_install_schema->connect_str
    IF (val_user_privs(0)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm2_process_event_rs->ui_allowed_ind = 0
   IF ((dir_ui_misc->auto_install_ind=1))
    SET dm2_process_rs->dbase_name = ""
   ENDIF
   IF (dpl_ui_chk(dpl_package_install)=0)
    RETURN(0)
   ENDIF
   CALL drr_get_process_status("DM2_INSTALL_PKG",dip_package_abs_float,dip_install_status)
   SET dir_ui_misc->install_status = dip_install_status
   IF ((dir_ui_misc->install_status > 0))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Installation currently active for Plan ",build(dip_package_abs_int),
     ".  Exiting.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ( NOT (dip_install_mode IN ("BATCHPRECYCLE", "DTBATCH", "DOWNTIME", "BATCHDOWN", "DTSCHEMA"))
    AND (dir_ui_misc->background_ind=0))
    SET dm_err->eproc = "Checking domain configuration for Package installation."
    CALL disp_msg(" ",dm_err->logfile,0)
    EXECUTE dm2_ocd_val_domain
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    IF (ds_scramble_init(null)=0)
     RETURN(0)
    ENDIF
    IF ((dm2_install_schema->cdba_p_word="NONE")
     AND (dm2_install_schema->cdba_connect_str="NONE"))
     SET dm2scramble->mode_ind = 0
     IF (dad_get_admin_conn(dip_adm_conn_inf)=0)
      RETURN(0)
     ENDIF
     SET dm_err->err_ind = 0
     SET dm2_install_schema->dbase_name = "ADMIN"
     SET dm2_install_schema->u_name = "CDBA"
     SET dm2_install_schema->p_word = substring((findstring("/",dip_adm_conn_inf,1,0)+ 1),((
      findstring("@",dip_adm_conn_inf,1,0) - findstring("/",dip_adm_conn_inf,1,0)) - 1),
      dip_adm_conn_inf)
     SET dm2_install_schema->connect_str = substring((findstring("@",dip_adm_conn_inf,1,0)+ 1),((
      textlen(trim(dip_adm_conn_inf)) - findstring("@",dip_adm_conn_inf,1,0))+ 1),dip_adm_conn_inf)
     EXECUTE dm2_connect_to_dbase "CO"
     IF ((dm_err->err_ind=1))
      SET dm_err->err_ind = 0
      SET dm2_force_connect_string = 1
      EXECUTE dm2_connect_to_dbase "PC"
      SET dm2_force_connect_string = 0
     ENDIF
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
     SET dm2_install_schema->cdba_p_word = dm2_install_schema->p_word
     SET dm2_install_schema->cdba_connect_str = dm2_install_schema->connect_str
    ENDIF
    SET dm2scramble->mode_ind = 1
    SET dm2scramble->in_text = concat("CDBA/",trim(dm2_install_schema->cdba_p_word,3),"@",trim(
      dm2_install_schema->cdba_connect_str,3))
    IF (ds_scramble(null)=0)
     RETURN(0)
    ENDIF
    SET dm2scramble->out_text = replace(check(dm2scramble->out_text," ")," ","",0)
    SET dm2_install_schema->dbase_name = dm2_install_schema->target_dbase_name
    SET dm2_install_schema->u_name = pi_u_name
    SET dm2_install_schema->p_word = dm2_install_schema->v500_p_word
    SET dm2_install_schema->connect_str = dm2_install_schema->v500_connect_str
    EXECUTE dm2_connect_to_dbase "CO"
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Logging ADMIN connection info"
    CALL disp_msg(" ",dm_err->logfile,0)
    UPDATE  FROM dm2_admin_dm_info di
     SET di.info_char = dm2scramble->out_text
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="ADMIN_CONNECT_STRING"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     ROLLBACK
     RETURN(0)
    ENDIF
    IF (curqual=0)
     INSERT  FROM dm2_admin_dm_info di
      SET di.info_domain = "DATA MANAGEMENT", di.info_name = "ADMIN_CONNECT_STRING", di.info_char =
       dm2scramble->out_text
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      ROLLBACK
      RETURN(0)
     ENDIF
    ENDIF
    COMMIT
   ENDIF
   IF (call_script != "DM_OCD_MENU"
    AND (dir_ui_misc->background_ind=0))
    IF (checkprg("DM2_SET_ENV_ID") > 0)
     EXECUTE dm2_set_env_id
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ELSE
     EXECUTE dm_set_env_id
     SET message = nowindow
     IF (check_error("Executing DM_SET_ENV_ID to verify environment ID.")=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   SET dm_err->eproc = "Getting environment ID and Name."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name IN ("DM_ENV_ID", "DM_ENV_NAME")
    DETAIL
     IF (di.info_name="DM_ENV_ID")
      dip_env_id = di.info_number
     ELSE
      pi_src_envname = di.info_char
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error("Installation Failed. Error getting the environment ID/Name from DM_INFO.")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ( NOT (curqual))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Installation Failed.  No environment ID/Name found."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET lpoe->project_type = olpt_install_log
   IF (dip_install_mode IN ("UTBATCH", "UTSCHEMA", "DTSCHEMA", "SCHEMA", "BATCHSCHEMA"))
    SET lpoe->project_name = concat(dip_install_mode,":",curnode)
   ELSE
    SET lpoe->project_name = dip_install_mode
   ENDIF
   SET lpoe->environment_id = dip_env_id
   SET lpoe->ocd = dip_package_int
   SET lpoe->project_instance = 1
   SET lpoe->batch_dt_tm = dip_start_dt_tm
   SET lpoe->start_dt_tm = dip_start_dt_tm
   SET lpoe->status = ols_running
   SET lpoe->message = concat(dip_install_mode," Mode begins")
   IF (log_package_op_event(null)=0)
    RETURN(0)
   ENDIF
   IF (dip_install_mode != "BATCHPREVIEW")
    SET dm_err->eproc = "Evaluate database migration context."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DM2_MIG_STATUS_MARKER"
      AND di.info_name="SCHEMA_FREEZE"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF (curqual=1)
     SET dm_err->err_ind = 1
     SET dm_err->emsg =
     "This process cannot continue because in schema freeze of a database migration."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   SET pi_tmp_info_name = cnvtupper(build("SOURCE_",pi_src_envname,"_",dm2_install_schema->
     target_dbase_name))
   SET pi_tmp_info_domain = ""
   SET dm_err->eproc =
   "Query ADMIN dm_info to find row matching Source env/db name participating in migration/utc conversion."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info di
    WHERE di.info_domain="*UTC_DATA"
     AND di.info_name=pi_tmp_info_name
    DETAIL
     pi_tmp_info_domain = di.info_domain
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual > 1)
    SET dm_err->err_ind = 1
    SET dm_err->emsg =
    "Found more than 1 row for Source env/db name participating in migration/utc conversion."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (pi_tmp_info_domain > " ")
    SET dm_err->eproc = "Checking for UTC conversion."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm2_admin_dm_info di
     WHERE di.info_domain=patstring(cnvtupper(build(pi_tmp_info_domain,"_STATUS")))
     DETAIL
      pi_tmp_status = di.info_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF (pi_tmp_status != "COMPLETE")
     SET dm_err->eproc = "Checking for UTC conversion mode."
     CALL disp_msg(" ",dm_err->logfile,0)
     SELECT INTO "nl:"
      FROM dm2_admin_dm_info di
      WHERE di.info_domain=cnvtupper(pi_tmp_info_domain)
       AND di.info_name="MODE*"
      DETAIL
       pi_tmp_mode = di.info_name
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF (pi_tmp_status != "COMPLETE"
    AND pi_tmp_mode="MODE_MIGRATION/UTC")
    SET dum_utc_data->mig_utc_pkg_instll_ind = 1
   ENDIF
   SET dm_err->eproc = "Check if UTC migration is in progress"
   IF (validate(dm2_mig_utc_status,"-1")="-1")
    DECLARE dm2_mig_utc_status = vc WITH protect, noconstant("")
   ENDIF
   EXECUTE dm2_mig_status_check
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF (cnvtupper(dm2_mig_utc_status)="ERROR")
    SET dm_err->eproc = "Check UTC migration status."
    SET dm_err->emsg = "Unexpected error occurred in DM2_MIG_STATUS_CHECK"
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (cnvtupper(dm2_mig_utc_status)="ON")
    SET dip_date_mode = cnvtupper(trim(logical("DATE_MODE")))
    IF (dip_date_mode="UTC")
     SET dm_err->eproc = "Check for UTC Conversion date mode as UTC override."
     SELECT INTO "nl:"
      FROM dm_info d
      WHERE d.info_domain="DM2_MIG_UTC_DATE_MODE_CHK"
       AND d.info_name="BYPASS_CHECK"
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
     IF (curqual > 0)
      SET dm_err->eproc = "UTC Conversion date mode as UTC override found"
      CALL disp_msg("",dm_err->logfile,0)
     ELSE
      SET dm_err->err_ind = 1
      SET dm_err->emsg = "Environment date mode not supported."
      SET dm_err->eproc =
      "Verify date_mode of package installation while UTC Conversion taking place"
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF ((dir_ui_misc->background_ind=0))
    SET pi_cs = build(cnvtupper(currdbuser),"/",dm2_install_schema->v500_p_word,"@",
     dm2_install_schema->v500_connect_str)
    SET dm_err->eproc = "Updating clinical user connect string in dm_environment."
    UPDATE  FROM dm_environment de
     SET de.v500_connect_string = pi_cs
     WHERE de.environment_id=dip_env_id
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ENDIF
    COMMIT
   ENDIF
   SET dm_err->eproc = "Getting environment name."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_environment de
    WHERE de.environment_id=dip_env_id
    DETAIL
     dip_env_name = de.environment_name, sch_ver = round(de.schema_version,3)
    WITH nocounter
   ;end select
   IF (check_error("Installation Failed. Error getting the environment name from DM_ENVIRONMENT.")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ( NOT (curqual))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Installation Failed.  No environment name found."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc = concat("Initialized: dip_env_id =<",trim(cnvtstring(dip_env_id)),
     "> and dip_env_name =<",dip_env_name,">.")
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   EXECUTE dm2_set_db_options
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF (dip_install_mode IN ("UPTIME", "POSTINST", "EXPRESS", "BATCHUP", "BATCHPOST",
   "BATCHEXPRESS", "MANUAL")
    AND (dm2_db_options->readme_space_calc="Y"))
    EXECUTE dm2_exec_ddlops
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   IF (dip_install_mode IN ("UTSCHEMA", "SCHEMA", "UTBATCH", "BATCHSCHEMA"))
    SET dm2_oragen_system_defs = 1
    EXECUTE dm2_create_system_defs
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    SET dm2_oragen_system_defs = 0
   ENDIF
   SET dm_err->eproc = "Inserting or Updating row in DM_ALPHA_FEATURES_ENV."
   SELECT INTO "nl:"
    FROM dm_alpha_features_env defa
    WHERE defa.environment_id=dip_env_id
     AND defa.alpha_feature_nbr=dip_package_int
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual)
    UPDATE  FROM dm_alpha_features_env defa
     SET defa.status = "Begin installation.", defa.start_dt_tm = cnvtdatetime(curdate,curtime3), defa
      .end_dt_tm = null,
      defa.inst_mode = dip_install_mode, defa.calling_script = "DM2_INSTALL_PKG"
     WHERE defa.environment_id=dip_env_id
      AND defa.alpha_feature_nbr=dip_package_int
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
    INSERT  FROM dm_alpha_features_env defa
     SET defa.status = "Begin installation.", defa.start_dt_tm = cnvtdatetime(curdate,curtime3), defa
      .end_dt_tm = null,
      defa.environment_id = dip_env_id, defa.alpha_feature_nbr = dip_package_int, defa.inst_mode =
      dip_install_mode,
      defa.calling_script = "DM2_INSTALL_PKG", defa.curr_migration_ind = 0
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   IF ((dm2_install_pkg->process_option="BATCHPKG"))
    IF ((dm_err->debug_flag > 1))
     CALL echo("Before get_batch_list.")
     CALL trace(7)
    ENDIF
    CALL get_batch_list(dip_package_abs_int)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 1))
     CALL echo("After get_batch_list.")
     CALL trace(7)
    ENDIF
    SET dm_err->eproc = concat("Installing schema, code sets, and ATRs for Packages in Install Plan ",
     trim(cnvtstring(dip_package_abs_int))," using DM2_INSTALL_PKG.")
   ELSE
    SET dm_err->eproc = concat("Installing schema, code sets, and ATRs for Distribution Package ",
     dip_package_str," using DM2_INSTALL_PKG.")
   ENDIF
   CALL disp_msg(" ",dm_err->logfile,0)
   CALL end_status("Domain setup completed.",dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF (currdb="ORACLE"
    AND cnvtupper(trim(dip_install_mode,3)) IN ("BATCHPREVIEW", "BATCHUP", "BATCHEXPRESS")
    AND (dir_ui_misc->background_ind=0))
    SET docd_reply->status = "F"
    CALL start_status("Checking for current database statistics.",dip_env_id,dip_package_int)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 2))
     CALL echo("Before dm2_dbstats_chk_rpt.")
     CALL trace(7)
    ENDIF
    EXECUTE dm2_dbstats_chk_rpt "*", value(dip_stats_daysold)
    SET message = nowindow
    IF ((dm_err->debug_flag > 2))
     CALL echo("After dm2_dbstats_chk_rpt.")
     CALL trace(7)
    ENDIF
    IF (check_error("Error executing dm2_dbstats_chk_rpt.")=1)
     CALL end_status(dm_err->eproc,dip_env_id,dip_package_int)
     RETURN(0)
    ENDIF
    IF ((docd_reply->status="S"))
     CALL end_status("Database statistics are current.",dip_env_id,dip_package_int)
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ELSEIF ((docd_reply->status="C"))
     CALL end_status(concat("Database statistics are not current or check has been bypassed. ",
       docd_reply->err_msg),dip_env_id,dip_package_int)
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ELSEIF ((docd_reply->status="Q"))
     CALL end_status(concat("Database statistics are not current or user elected to quit. ",
       docd_reply->err_msg),dip_env_id,dip_package_int)
     SET dm_err->eproc = "Database statistics are not current. User elected to quit. "
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "User elected to quit from Database Statistics Check. "
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (checkprg("DM2_ADS_CHK_RPT") > 0)
     CALL start_status("Checking for ADS copy.",dip_env_id,dip_package_int)
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
     EXECUTE dm2_ads_chk_rpt
     SET message = nowindow
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
     IF ((docd_reply->status="S"))
      CALL end_status("Database is not ADS copy.",dip_env_id,dip_package_int)
      IF ((dm_err->err_ind=1))
       RETURN(0)
      ENDIF
     ELSEIF ((docd_reply->status="C"))
      CALL end_status(concat("Database is ADS copy and ",docd_reply->err_msg),dip_env_id,
       dip_package_int)
     ELSEIF ((docd_reply->status="Q"))
      CALL end_status(concat("Database is ADS copy and ",docd_reply->err_msg),dip_env_id,
       dip_package_int)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF (cnvtupper(trim(dip_install_mode,3)) IN ("BATCHUP", "BATCHPREVIEW")
    AND currdbuser="V500")
    IF (dan_bypass_node_check(pi_bypass_node_check)=0)
     RETURN(0)
    ENDIF
    IF (pi_bypass_node_check=0)
     IF (dan_insert_app_nodes(null)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF (currdb="ORACLE"
    AND dip_install_mode="BATCHPREVIEW"
    AND (dir_ui_misc->background_ind=0))
    SET dip_user_response = " "
    IF (dip_recyclebin_check(dip_user_response)=0)
     RETURN(0)
    ENDIF
    IF (dip_user_response="C")
     CALL end_status(concat("Recyclebin check completed. User has elected to continue. ",docd_reply->
       err_msg),dip_env_id,dip_package_int)
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ELSEIF (dip_user_response="Q")
     SET dm_err->eproc = "Recyclebin check completed. User has elected to quit. "
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "User elected to quit from Recyclebin Check "
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   CALL start_status(concat("Executing in ",dip_install_mode," mode."),dip_env_id,dip_package_int)
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF (dip_install_mode="BATCH*")
    SELECT INTO "nl:"
     FROM dm_ocd_log dol
     WHERE dol.environment_id IN (0, dip_env_id)
      AND dol.project_type="INSTALL PLAN"
      AND dol.ocd=dip_package_int
     DETAIL
      IF (dol.project_name="TYPE"
       AND dol.status="NO-DT")
       dip_install_plan_type = "NO-DT"
      ENDIF
      IF (dol.project_name="DT-READMES"
       AND dol.status="NO")
       dip_exec_dt_readmes_ind = 0
      ENDIF
     WITH nocounter
    ;end select
    IF (((dip_install_plan_type="NO-DT") OR (dip_exec_dt_readmes_ind=0)) )
     SET dip_autosuccess_batchdown_ind = 1
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag >= 0))
    SET dm_err->eproc = concat("Install Plan Type <",dip_install_plan_type,"> in use.")
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SET dm_err->eproc = "Check DM_INFO for override to allow old Install Modes"
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="PACKAGE INSTALLATION OLD MODE"
     AND di.info_name="ALLOW_OLD_MODES"
    DETAIL
     dip_allow_old_modes = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dir_ui_misc->background_ind=0))
    IF ((dm2_process_event_rs->ui_allowed_ind=1)
     AND dip_install_mode IN ("BATCHUP", "BATCHPRECYCLE", "BATCHDOWN", "BATCHPOST"))
     SET dip_unattended_install_ind = 0
     IF (dip_unattended_install_prompt(dip_unattended_install_ind,dip_user_response)=0)
      RETURN(0)
     ELSEIF (dip_user_response="Q")
      SET dm_err->err_ind = 1
      SET dm_err->emsg = "User elected to quit from unattended install prompt."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ELSE
     SET dip_unattended_install_ind = 0
    ENDIF
   ENDIF
   IF ((((dir_ui_misc->auto_install_ind=1)) OR ((dir_ui_misc->background_ind=0))) )
    SET dm_err->eproc = "Verify AFE information is available."
    SELECT INTO "nl:"
     FROM dm_alpha_features_env defa
     WHERE defa.environment_id=dip_env_id
      AND defa.alpha_feature_nbr=dip_package_int
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     INSERT  FROM dm_alpha_features_env defa
      SET defa.status = "Begin installation.", defa.start_dt_tm = cnvtdatetime(curdate,curtime3),
       defa.end_dt_tm = null,
       defa.environment_id = dip_env_id, defa.alpha_feature_nbr = dip_package_int, defa.inst_mode =
       dip_install_mode,
       defa.calling_script = "DM2_INSTALL_PKG", defa.curr_migration_ind = 0
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
    ENDIF
   ENDIF
   IF ((dir_ui_misc->background_ind=0))
    IF (dip_install_mode IN ("BATCHPREVIEW", "BATCHUP", "BATCHEXPRESS"))
     CALL load_batch_package_schema(dip_install_mode,dip_package_str,dip_env_id)
     IF ((dm_err->err_ind=1))
      GO TO exit_program
     ENDIF
    ENDIF
   ENDIF
   IF ((dir_ui_misc->auto_install_ind=1))
    IF (drr_use_flexible_schedule(0,dip_package_str,dip_install_mode,dip_accept)=0)
     RETURN(0)
    ENDIF
    IF ((drr_flex_sched->status=0))
     SET dm_err->eproc = "Validating Installation scheduler"
     SET dm_err->emsg = "Installation scheduler is disabled"
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSEIF ((dir_ui_misc->background_ind=0))
    IF (call_script != "DM_OCD_MENU"
     AND dip_unattended_install_ind=0
     AND dip_install_mode IN ("BATCHUP", "BATCHPRECYCLE", "BATCHDOWN", "BATCHPOST"))
     IF (drr_use_flexible_schedule(1,dip_package_str,dip_install_mode,dip_accept)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF ((dir_ui_misc->background_ind=0))
    IF (call_script != "DM_OCD_MENU")
     IF (((dip_install_mode="BATCHDOWN") OR (dip_unattended_install_ind=1)) )
      SET dir_silmode_requested_ind = 1
     ELSEIF (dip_install_mode IN ("BATCHPREVIEW", "UTBATCH", "BATCHSCHEMA"))
      SET dir_silmode_requested_ind = 0
     ELSEIF (silmode_prompt(dir_silmode_requested_ind,dip_env_id,dip_package_int,dip_install_mode)=0)
      RETURN(0)
     ENDIF
    ENDIF
    IF (dip_unattended_install_ind=0
     AND (dm2_process_event_rs->ui_allowed_ind=1)
     AND dip_install_mode IN ("BATCHPREVIEW", "BATCHUP", "BATCHPRECYCLE", "BATCHDOWN", "BATCHPOST"))
     SET dip_user_response = " "
     SET dnotify->install_method = "ATTENDED"
     IF (dn_confirm_install_notification(dip_user_response)=0)
      RETURN(0)
     ENDIF
     IF (dip_user_response="Q")
      SET dm_err->err_ind = 1
      SET dm_err->emsg = "User elected to quit from notification setup prompt."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    IF ((drr_flex_sched->pkg_using_schedule=1)
     AND (dir_ui_misc->background_ind=0)
     AND dip_install_mode IN ("BATCHPREVIEW", "BATCHUP", "BATCHPRECYCLE", "BATCHDOWN", "BATCHPOST")
     AND (dm2_process_event_rs->ui_allowed_ind=1))
     SET dip_user_response = " "
     IF (dip_confirm_monitor_settings(dip_user_response)=0)
      RETURN(0)
     ENDIF
     IF (dip_user_response="Q")
      SET dm_err->err_ind = 1
      SET dm_err->emsg =
      "User elected to quit from Installation Plan Monitoring - Settings Confirmation"
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET dm2_process_rs->process_name = ""
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dip_register_install_process(null)
   IF (dpl_ui_chk(dpl_package_install)=0)
    RETURN(0)
   ENDIF
   IF (drr_insert_runner_row("DM2_INSTALL_PKG",currdbhandle," ",1,dip_package_abs_float)=0)
    RETURN(0)
   ENDIF
   SET dir_ui_misc->parent_script_name = "DM2_INSTALL_PKG"
   IF ((dm2_process_event_rs->ui_allowed_ind=1))
    CALL dm2_process_log_add_detail_text(dpl_install_mode,dip_install_mode)
    CALL dm2_process_log_add_detail_number(dpl_instsched_used,cnvtreal(drr_flex_sched->
      pkg_using_schedule))
    CALL dm2_process_log_add_detail_number(dpl_silmode,cnvtreal(dir_silmode_requested_ind))
    CALL dm2_process_log_add_detail_number(dpl_unattended,cnvtreal(dir_ui_misc->background_ind))
    IF (dm2_process_log_dtl_row(dir_ui_misc->dm_process_event_id,1)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dip_update_itinerary_step(duis_step,duis_begin_dt_tm,duis_end_dt_tm,duis_plan_id,
  duis_status)
   DECLARE duis_ndx = i4 WITH protect, noconstant(0)
   DECLARE duis_audit_name = vc WITH protect, noconstant(" ")
   IF ((dm2_process_event_rs->ui_allowed_ind=1))
    SET dm2_process_event_rs->itinerary_key = duis_step
    SET dm2_process_event_rs->begin_dt_tm = duis_begin_dt_tm
    SET dm2_process_event_rs->status = duis_status
    SET dm2_process_event_rs->end_dt_tm = duis_end_dt_tm
    SET dm2_process_event_rs->install_plan_id = duis_plan_id
    SET duis_ndx = locateval(duis_ndx,1,dip_itin_rs->itin_cnt,duis_step,dip_itin_rs->itin_step[
     duis_ndx].itinerary_key)
    SET dm2_process_event_rs->itinerary_process_event_id = dip_itin_rs->itin_step[duis_ndx].
    dm_process_event_id
    IF (dm2_process_log_row(dpl_package_install,dpl_itinerary_event,dm2_process_event_rs->
     itinerary_process_event_id,0)=0)
     RETURN(0)
    ENDIF
    SET dm2_process_event_rs->begin_dt_tm = cnvtdatetime(curdate,curtime3)
    SET dm2_process_event_rs->status = dpl_complete
    SET dm2_process_event_rs->end_dt_tm = cnvtdatetime(curdate,curtime3)
    SET dm2_process_event_rs->install_plan_id = duis_plan_id
    SET duis_audit_name = concat(duis_step,"_",duis_status)
    CALL dm2_process_log_add_detail_text(dpl_audit_name,duis_audit_name)
    CALL dm2_process_log_add_detail_text(dpl_audit_type,dpl_progress)
    IF (dm2_process_log_row(dpl_package_install,dpl_auditlog,dpl_no_prev_id,0)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (duis_status=dpl_executing)
    CALL dpl_upd_dped_last_status(dir_ui_misc->dm_process_event_id,concat("Starting ",dip_itin_rs->
      itin_step[duis_ndx].step_name," at ",format(cnvtdatetime(curdate,curtime3),";;q"),"."),0.0,
     cnvtdatetime(curdate,curtime3))
   ELSEIF (duis_status=dpl_complete)
    CALL dpl_upd_dped_last_status(dir_ui_misc->dm_process_event_id,concat("Completed ",dip_itin_rs->
      itin_step[duis_ndx].step_name," at ",format(cnvtdatetime(curdate,curtime3),";;q"),"."),0.0,
     cnvtdatetime(curdate,curtime3))
   ENDIF
   IF ((dnotify->status=1)
    AND (dm2_process_event_rs->ui_allowed_ind=1))
    SET dnotify->process = "INSTALLPLAN"
    SET dnotify->install_status = dpl_executing
    SET dnotify->event = duis_step
    SET dnotify->mode = dip_install_mode
    SET dnotify->plan_id = dip_package_abs_float
    SET dnotify->msgtype = dpl_progress
    IF (duis_status=dpl_executing)
     CALL dn_add_body_text(concat(dip_install_mode," started ",dip_itin_rs->itin_step[duis_ndx].
       step_name," at ",format(cnvtdatetime(curdate,curtime3),";;q"),
       "."),1)
    ELSEIF (duis_status=dpl_complete)
     CALL dn_add_body_text(concat(dip_install_mode," completed ",dip_itin_rs->itin_step[duis_ndx].
       step_name," at ",format(cnvtdatetime(curdate,curtime3),";;q"),
       "."),1)
    ENDIF
    CALL dn_add_body_text(" ",0)
    CALL dn_add_body_text(
     "Please go to the following location if you would like to actively monitor or manage the Installation:",
     0)
    CALL dn_add_body_text("  ccl | dm2_install_plan_menu go",0)
    CALL dm2_process_log_add_detail_text(dpl_audit_name,concat("EMAIL:",duis_audit_name))
    CALL dm2_process_log_add_detail_text(dpl_audit_type,dpl_progress)
    IF (dn_notify(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dip_unattended_install_prompt(duip_unattended_allowed_ind,duip_user_response)
   DECLARE duip_valid_ind = i2 WITH protect, noconstant(0)
   SET duip_unattended_allowed_ind = 0
   SET duip_user_response = " "
   WHILE (duip_unattended_allowed_ind=0
    AND  NOT (duip_user_response IN ("A", "Q")))
     SET width = 132
     SET message = window
     CALL clear(1,1)
     CALL video(n)
     CALL text(2,1,"Unattended Installation Selection Prompt",w)
     CALL text(4,1,concat("Please select the installation method for ",dip_install_mode))
     CALL text(6,1,"Unattended")
     CALL text(7,1,"----------")
     CALL text(8,1,concat("This method will execute the remainder of the ",dip_install_mode,
       " installation as a background server "))
     CALL text(9,1,"process so that this session may be disconnected from the system")
     CALL text(11,1,"Attended")
     CALL text(12,1,"----------")
     CALL text(13,1,concat("This method will execute the ",dip_install_mode,
       " installation from this session/connection. if this "))
     CALL text(14,1,concat("session loses connectivity before completing the install successfully, ",
       "the installation will need to be restarted"))
     CALL text(16,1,"(U)nattended, (A)ttended, (Q)uit :")
     CALL accept(16,37,"A;cu"," "
      WHERE curaccept IN ("Q", "U", "A"))
     SET duip_user_response = curaccept
     CALL clear(1,1)
     SET message = nowindow
     IF (duip_user_response IN ("A", "Q"))
      SET duip_unattended_allowed_ind = 0
      RETURN(1)
     ENDIF
     SET duip_valid_ind = 0
     IF (dip_ui_validation(duip_valid_ind)=0)
      RETURN(0)
     ENDIF
     IF (duip_valid_ind=0)
      SET duip_unattended_allowed_ind = 0
     ELSE
      SET duip_unattended_allowed_ind = 1
     ENDIF
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dip_ui_validation(duv_valid_ind)
   DECLARE duv_continue = i2 WITH protect, noconstant(0)
   DECLARE duv_accept = vc WITH protect, noconstant("")
   SET duv_valid_ind = 0
   SET dm_err->eproc = "Verify BATCHPREVIEW has been executed."
   SELECT INTO "nl:"
    FROM dm_ocd_log l
    WHERE l.ocd=dip_package_int
     AND l.environment_id=dip_env_id
     AND l.project_type=olpt_install_info
     AND l.project_name=cnvtupper(olo_preview_complete)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET duv_valid_ind = 0
    SET dm_err->eproc = "UI validation failed due to missing execution of BATCHPREVIEW"
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
    SET width = 132
    SET message = window
    CALL clear(1,1)
    CALL text(1,1,"A successful execution of BATCHPREVIEW is required for Unattended Installs")
    CALL text(3,1,
     "Please first execute the following before proceeding with the BATCHUP mode of installation:")
    CALL text(5,1,concat("ccl> ocd_incl_schema2 ",trim(cnvtstring(dip_package_abs_int)),
      ',"BATCHPREVIEW" go'))
    CALL text(7,3,"Enter 'C' to continue.")
    CALL accept(7,34,"p;cduh"," "
     WHERE curaccept IN ("C"))
    CALL clear(1,1)
    SET message = nowindow
    RETURN(1)
   ENDIF
   SET duv_continue = 0
   WHILE (duv_continue=0)
     SET dm_err->eproc = "Verify that required tablespaces were created for this install"
     SELECT INTO "nl:"
      FROM dm2_tspace_size dts
      WHERE dts.install_type="PACKAGE"
       AND dts.install_type_value=dip_package_str
       AND dts.new_ind=1
       AND  NOT ( EXISTS (
      (SELECT
       "x"
       FROM user_tablespaces dt
       WHERE dt.tablespace_name=dts.tspace_name)))
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
     IF (curqual > 0)
      SET duv_valid_ind = 0
      SET dm_err->eproc = "UI validation failed due to required tablespaces not existing"
      CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
      SET width = 132
      SET message = window
      CALL clear(1,1)
      CALL text(1,1,"New tablespaces were identified as being needed, but have not been created.")
      CALL text(2,1,"This may cause schema failures during Unattended Install.")
      CALL text(4,1,"Please execute the following to process tablespace needs before proceeding:")
      CALL text(6,1,concat("ccl> ocd_incl_schema2 ",trim(cnvtstring(dip_package_abs_int)),
        ',"BATCHPREVIEW" go'))
      CALL text(8,3,"(R)echeck, (Q)uit: ")
      CALL accept(8,25,"A;cu"," "
       WHERE curaccept IN ("Q", "R"))
      SET duv_accept = curaccept
      CALL clear(1,1)
      SET message = nowindow
      IF (duv_accept="Q")
       SET duv_valid_ind = 0
       RETURN(1)
      ENDIF
     ELSE
      SET duv_continue = 1
     ENDIF
   ENDWHILE
   SET duv_accept = ""
   IF (drr_use_flexible_schedule(0,dip_package_str,dip_install_mode,duv_accept)=0)
    SET width = 132
    SET message = window
    CALL clear(1,1)
    CALL text(1,1,"The Installation Scheduler validation had the following error:")
    CALL text(3,1,substring(1,129,dm_err->emsg))
    CALL text(7,3,"Press <Enter> to return to Unattended Installation Selection Prompt.")
    CALL accept(7,75,"p;cduh","E"
     WHERE curaccept IN ("E"))
    CALL clear(1,1)
    SET message = nowindow
    SET dm_err->eproc = "UI validation failed due to scheduler ON verification"
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
    SET duv_valid_ind = 0
    RETURN(1)
   ENDIF
   SET duv_accept = ""
   IF ((drr_flex_sched->status=0))
    SET duv_continue = 0
    WHILE (duv_continue=0)
      SET width = 132
      SET message = window
      CALL clear(1,1)
      CALL text(1,1,"The Installation Scheduler must be ON for Unattended Installs.")
      CALL text(3,3,"(M)odify Installation Scheduler, (Q)uit: ")
      CALL accept(3,47,"A;cu"," "
       WHERE curaccept IN ("M", "Q"))
      SET duv_accept = curaccept
      CALL clear(1,1)
      SET message = nowindow
      IF (duv_accept="Q")
       SET dm_err->eproc =
       "UI validation failed due to user choosing quit from scheduler ON modification"
       CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
       SET duv_valid_ind = 0
       RETURN(1)
      ELSEIF (duv_accept="M")
       EXECUTE dm2_flexible_schedule_menu
       IF ((dm_err->err_ind=1))
        RETURN(0)
       ENDIF
      ENDIF
      IF ((drr_flex_sched->status != 0))
       SET duv_continue = 1
      ENDIF
    ENDWHILE
   ENDIF
   SET duv_accept = ""
   IF (drr_use_flexible_schedule(1,dip_package_str,dip_install_mode,duv_accept)=0)
    SET width = 132
    SET message = window
    CALL clear(1,1)
    CALL text(1,1,"The Installation Scheduler validation had the following error:")
    CALL text(3,1,substring(1,129,dm_err->emsg))
    CALL text(7,3,"Press <Enter> to return to Unattended Installation Selection Prompt.")
    CALL accept(7,75,"p;cduh","E"
     WHERE curaccept IN ("E"))
    CALL clear(1,1)
    SET message = nowindow
    SET dm_err->eproc = "UI validation failed due to schedule setup error"
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
    SET duv_valid_ind = 0
    RETURN(1)
   ENDIF
   IF (duv_accept != "C")
    SET dm_err->eproc =
    "UI validation failed due to user selecting continue from scheduler validation"
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
    SET duv_valid_ind = 0
    RETURN(1)
   ENDIF
   SET duv_accept = ""
   SET dnotify->install_method = "UNATTENDED"
   SET duv_continue = 0
   WHILE (duv_continue=0)
     IF (dn_confirm_install_notification(duv_accept)=0)
      RETURN(0)
     ENDIF
     CALL clear(1,1)
     SET message = nowindow
     SET duv_continue = 1
     IF ((((dnotify->status=0)) OR (duv_accept="Q")) )
      SET duv_continue = 0
     ENDIF
   ENDWHILE
   IF (duv_accept != "C")
    SET dm_err->eproc = "UI validation failed due to user selecting quit from notification setup"
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
    SET duv_valid_ind = 0
    RETURN(1)
   ENDIF
   SET duv_valid_ind = 1
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dip_sd_eval(sbr_dse_sd_in_process)
   DECLARE dse_retry_ceiling = i4 WITH protect, noconstant(3600)
   DECLARE dse_sleep_time = i4 WITH protect, noconstant(300)
   DECLARE dse_retry_cnt = i4 WITH protect, noconstant(0)
   DECLARE dse_retry_max = i4 WITH protect, noconstant(0)
   DECLARE dse_pause_ind = i2 WITH protect, noconstant(0)
   DECLARE dse_sbr_loop = i4 WITH protect, noconstant(1)
   DECLARE dse_sd_in_use_ind = i2 WITH protect, noconstant(0)
   DECLARE dse_sd_in_process = i2 WITH protect, noconstant(0)
   SET sbr_dse_sd_in_process = 0
   IF (dsr_sd_in_use_check("DM2NOTSET",dse_sd_in_use_ind)=0)
    RETURN(0)
   ENDIF
   IF (dse_sd_in_use_ind=1)
    IF (dsr_usage_prep("DM2NOTSET")=0)
     RETURN(0)
    ENDIF
    WHILE (dse_sbr_loop=1)
     IF (dsr_chk_sd_in_process("MILL",currdbuser,dse_sd_in_process)=0)
      RETURN(0)
     ENDIF
     IF (dse_sd_in_process=0)
      SET dse_sbr_loop = 0
     ELSE
      IF (dse_retry_max=0)
       SET dm_err->eproc = "Retreiving concurrent timeout and retry intervals"
       SELECT INTO "nl:"
        FROM (ceradm.sd_param sp)
        WHERE sp.pname IN ("CONCURRENT_SCHEMA_RETRY_CEILING", "CONCURRENT_SCHEMA_RETRY_INTERVAL")
         AND sp.ptype="CONFIG"
        DETAIL
         IF (sp.pname="CONCURRENT_SCHEMA_RETRY_CEILING")
          dse_retry_ceiling = cnvtint(sp.pvalue)
         ELSEIF (sp.pname="CONCURRENT_SCHEMA_RETRY_INTERVAL")
          dse_sleep_time = evaluate(cnvtint(sp.pvalue),0,1,cnvtint(sp.pvalue))
         ENDIF
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc) > 0)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       SET dse_retry_max = ceil((dse_retry_ceiling/ dse_sleep_time))
      ENDIF
      IF (dse_retry_cnt >= dse_retry_max)
       SET dse_sbr_loop = 0
       SET sbr_dse_sd_in_process = dse_sd_in_process
      ELSE
       CALL dpl_upd_dped_last_status(dir_ui_misc->dm_process_event_id,
        "Install uptime schema paused due to another active schema installation.",0.0,cnvtdatetime(
         curdate,curtime3))
       SET dm_err->eproc = concat("Waiting on other schema installation to end or max ",trim(
         cnvtstring(dse_retry_ceiling))," seconds wait reached.  Elapsed time: ",trim(cnvtstring((
          dse_retry_cnt * dse_sleep_time)))," seconds")
       CALL disp_msg(" ",dm_err->logfile,0)
       IF ((dnotify->status=1)
        AND (dm2_process_event_rs->ui_allowed_ind=1))
        SET dnotify->process = "INSTALLPLAN"
        SET dnotify->install_status = dpl_executing
        SET dnotify->event = "BATCHUP:SCHEMA"
        SET dnotify->mode = dip_install_mode
        SET dnotify->plan_id = dip_package_abs_float
        SET dnotify->msgtype = dpl_progress
        SET dm2_process_event_rs->install_plan_id = dip_package_abs_int
        SET dm2_process_event_rs->status = dpl_progress
        SET dm2_process_event_rs->message = dm_err->eproc
        CALL dm2_process_log_add_detail_text(dpl_audit_name,concat("EMAIL:",dip_install_mode,
          "-PAUSED"))
        CALL dm2_process_log_add_detail_text(dpl_audit_type,dpl_progress)
        CALL dn_add_body_text(concat(
          "Install uptime schema paused due to another active schema installation."),1)
        CALL dn_add_body_text(" ",0)
        CALL dn_add_body_text(dm2_process_event_rs->message,0)
        IF (dn_notify(null)=0)
         RETURN(0)
        ENDIF
       ENDIF
       SET dse_retry_cnt = (dse_retry_cnt+ 1)
       CALL pause(dse_sleep_time)
       SET dse_pause_ind = 1
      ENDIF
     ENDIF
    ENDWHILE
    IF (dse_sd_in_process=0
     AND dse_pause_ind=1)
     CALL dpl_upd_dped_last_status(dir_ui_misc->dm_process_event_id,
      "Install uptime schema resumed after another active schema installation completed.",0.0,
      cnvtdatetime(curdate,curtime3))
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE install_package_schema(sbr_ips_install_mode,sbr_ips_eid,sbr_ips_package_str)
   DECLARE sbr_ips_package_int = i4 WITH public, noconstant(0)
   DECLARE sbr_ips_schema_ind = i2 WITH public, noconstant(0)
   DECLARE sbr_b_idx = i4 WITH public, noconstant(0)
   DECLARE sbr_ips_sd_in_process = i2 WITH protect, noconstant(0)
   DECLARE sbr_ips_dm2_is_mode = vc WITH public, noconstant("NOT_SET")
   DECLARE sbr_ips_dm2_dbname = vc WITH public, noconstant("NOT_SET")
   DECLARE sbr_ips_dm2_cnnct_str = vc WITH public, noconstant("NOT_SET")
   SET sbr_ips_package_int = cnvtint(sbr_ips_package_str)
   IF ( NOT (sbr_ips_install_mode IN ("PREVIEW", "DOWNTIME", "UPTIME", "CHECK")))
    SET dm_err->eproc = "Validating install mode."
    SET dm_err->emsg = "Installation Failed. Invalid mode received by install_package_schema."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(null)
   ENDIF
   CASE (sbr_ips_install_mode)
    OF "PREVIEW":
     SET ocd_op->pre_op = olo_load_ccl_file
     SET ocd_op->cur_op = olo_schema_report
     SET ocd_op->msg = "Attempting to display schema reports."
    OF "UPTIME":
     SET ocd_op->pre_op = olo_pre_uts
     SET ocd_op->cur_op = olo_uptime_schema
     SET ocd_op->msg = "Attempting to install uptime schema."
     SET ocd_op->next_op = olo_atrs
    OF "DOWNTIME":
     SET ocd_op->pre_op = olo_pre_dts
     SET ocd_op->cur_op = olo_downtime_schema
     SET ocd_op->msg = "No downtime schema to install."
     SET ocd_op->next_op = olo_post_dts
    OF "CHECK":
     SET ocd_op->pre_op = olo_none
     SET ocd_op->cur_op = olo_schema_report
     SET ocd_op->msg = "Attempting to display schema reports."
   ENDCASE
   IF (currdb != "SQLSRV")
    IF (check_package_op(ocd_op->pre_op,sbr_ips_package_int,sbr_ips_eid)=0)
     CALL bad_package_op(ocd_op->cur_op,ocd_op->pre_op,sbr_ips_eid,sbr_ips_package_int)
     SET dm_err->err_ind = 1
     RETURN(null)
    ENDIF
   ENDIF
   IF (sbr_ips_install_mode="DOWNTIME")
    CALL log_package_op(ocd_op->cur_op,ols_complete,ocd_op->msg,sbr_ips_eid,sbr_ips_package_int)
    CALL end_status(ocd_op->msg,sbr_ips_eid,sbr_ips_package_int)
    RETURN(null)
   ENDIF
   CALL log_package_op(ocd_op->cur_op,ols_start,ocd_op->msg,sbr_ips_eid,sbr_ips_package_int)
   CASE (sbr_ips_install_mode)
    OF "PREVIEW":
     CALL start_status("Attempting to preview schema.",sbr_ips_eid,sbr_ips_package_int)
    OF "UPTIME":
     CALL start_status("Attempting to install uptime schema.",sbr_ips_eid,sbr_ips_package_int)
    OF "CHECK":
     CALL start_status("Attempting to check schema differences.",sbr_ips_eid,sbr_ips_package_int)
   ENDCASE
   IF ((tgtsch->tbl_cnt=0))
    SET dm_err->eproc = "Operation successful.  No schema to install."
    CALL log_package_op(ocd_op->cur_op,ols_complete,dm_err->eproc,sbr_ips_eid,sbr_ips_package_int)
    CALL end_status(dm_err->eproc,sbr_ips_eid,sbr_ips_package_int)
    RETURN(null)
   ENDIF
   CASE (sbr_ips_install_mode)
    OF "PREVIEW":
     SET sbr_ips_dm2_is_mode = "PREVIEW"
    OF "UPTIME":
     SET sbr_ips_dm2_is_mode = "CLIN UPGRADE"
    ELSE
     SET sbr_ips_dm2_is_mode = cnvtupper(sbr_ips_install_mode)
   ENDCASE
   IF (check_error("Checking for errors before running DM2_INSTALL_SCHEMA.")=1)
    CALL end_status(dm_err->eproc,sbr_ips_eid,sbr_ips_package_int)
    RETURN(null)
   ENDIF
   IF (sbr_ips_install_mode="UPTIME")
    IF (dip_sd_eval(sbr_ips_sd_in_process)=0)
     SET dm_err->eproc = "Validating uptime schema status"
     SET dm_err->emsg = "Installation failed evaluating for schema deployment usage/in-progress."
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     SET dm_err->eproc = "Installation failed evaluating for schema deployment usage/in-progress."
     CALL log_package_op(ocd_op->cur_op,ols_error,dm_err->eproc,sbr_ips_eid,sbr_ips_package_int)
     CALL end_status(dm_err->eproc,sbr_ips_eid,sbr_ips_package_int)
     RETURN(null)
    ENDIF
    IF (sbr_ips_sd_in_process=1)
     SET dm_err->eproc = "Validating uptime schema status"
     SET dm_err->emsg =
     "Install uptime schema stopped due to another active schema installation in progress"
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     SET dm_err->eproc =
     "Install uptime schema stopped due to another active schema installation in progress."
     CALL log_package_op(ocd_op->cur_op,ols_error,dm_err->eproc,sbr_ips_eid,sbr_ips_package_int)
     CALL end_status(dm_err->eproc,sbr_ips_eid,sbr_ips_package_int)
     RETURN(null)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    DECLARE sbr_ips_dbg_str = vc
    SET sbr_ips_dbg_str = concat("execute ","dm2_install_schema ",sbr_ips_dm2_is_mode," ",
     sbr_ips_package_str,
     " ",sbr_ips_dm2_dbname," ","'NONE', 'NONE', ",dm2_install_schema->v500_p_word,
     " ",sbr_ips_dm2_cnnct_str)
    CALL disp_msg(" ",dm_err->logfile,0)
    FREE SET sbr_ips_dbg_str
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echo("Before install schema.")
    CALL trace(7)
   ENDIF
   EXECUTE dm2_install_schema sbr_ips_dm2_is_mode, sbr_ips_package_str, dm2_install_schema->
   target_dbase_name,
   "NONE", "NONE", dm2_install_schema->v500_p_word,
   dm2_install_schema->v500_connect_str
   SET dm2_etu->mode = "NOT_DEFINED"
   SET dm2_etu->tbl_name = " "
   SET dm2_etu->pkg_num = 0
   IF ((dm_err->debug_flag > 1))
    CALL echo("After install schema.")
    CALL trace(7)
   ENDIF
   IF ((dm_err->err_ind=0)
    AND ((sbr_ips_install_mode IN ("PREVIEW", "CHECK")) OR ((tgtsch->diff_ind=0))) )
    SET dm_err->eproc = concat("Operation successful. ",sbr_ips_install_mode," schema successful.")
    CALL log_package_op(ocd_op->cur_op,ols_complete,dm_err->eproc,sbr_ips_eid,sbr_ips_package_int)
    CALL end_status(dm_err->eproc,sbr_ips_eid,sbr_ips_package_int)
    RETURN(null)
   ELSE
    IF (cnvtupper(dm_err->emsg)="*ONE OR MORE KILLED*")
     SET dm_err->eproc = concat("Installation Failed. ",sbr_ips_install_mode,
      " schema failed/killed. See the log file for details.")
    ELSE
     SET dm_err->eproc = concat("Installation Failed. ",sbr_ips_install_mode,
      " schema failed. See the log file for details.")
    ENDIF
    SET dip_final_msg->emsg = dm_err->emsg
    CALL log_package_op(ocd_op->cur_op,ols_error,dm_err->eproc,sbr_ips_eid,sbr_ips_package_int)
    CALL end_status(dip_final_msg->emsg,sbr_ips_eid,sbr_ips_package_int)
    RETURN(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE update_table_definitions(sbr_utd_mode,sbr_utd_eid,sbr_utd_package_int)
   DECLARE sbr_utd_prev_mode = vc WITH noconstant("NOT_SET")
   SET dm_err->eproc = concat("Checking for the completion of uptime schema while executing ",
    sbr_utd_mode," mode.")
   CALL start_status(dm_err->eproc,sbr_utd_eid,sbr_utd_package_int)
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET ocd_op->pre_op = olo_uptime_schema
   WHILE (check_package_op(ocd_op->pre_op,sbr_utd_package_int,sbr_utd_eid)=0)
     SET message = window
     SET width = 132
     CALL clear(1,1)
     CALL box(1,1,3,132)
     CALL text(2,3,"P A C K A G E   I N S T A L L A T I O N")
     CALL text(5,3,
      "This mode of package installation updates the table definitions on secondary nodes (nodes not hosting"
      )
     CALL text(6,3,
      "the database).  Before this step can begin, the uptime schema changes must be completed on the       "
      )
     CALL text(7,3,
      "primary node.  According to the log, uptime schema changes are not yet complete on the primary node. "
      )
     CALL text(9,3,
      "Every 20 seconds, this program will check for the completion of uptime schema.  Once uptime schema is"
      )
     CALL text(10,3,
      "complete, the program will update table definitions.  You can allow this program to continue until   "
      )
     CALL text(11,3,
      "the table definitions are updated, or you can choose to exit the program early.                      "
      )
     CALL text(13,3,
      "Note: If you choose to exit now, you MUST reexecute this mode after the uptime schema changes are    "
      )
     CALL text(14,3,
      "      complete on the primary node.                                                                  "
      )
     SET accept = time(20)
     CALL text(16,3,
      "Enter 'X' to exit, 'C' to continue (continues automatically in 20 seconds if no response):")
     CALL accept(16,94,"A;CU","C"
      WHERE curaccept IN ("C", "X", "c", "x"))
     SET accept = notime
     IF (cnvtupper(curaccept)="X")
      SET dm_err->emsg = "User chose not to wait for uptime schema to complete."
      SET dm_err->user_action = concat("Please execute ",sbr_utd_mode,
       " mode after uptime schema is complete.")
      SET dm_err->err_ind = 1
      CALL end_status(dm_err->eproc,sbr_utd_eid,sbr_utd_package_int)
      RETURN(0)
     ENDIF
     CALL clear(1,1)
     SET message = nowindow
   ENDWHILE
   SELECT INTO "nl:"
    FROM dm_afd_tables d,
     dm2_user_tables u
    WHERE d.alpha_feature_nbr=sbr_utd_package_int
     AND d.owner=u.owner
     AND d.table_name=u.table_name
    WITH nocounter
   ;end select
   IF (check_error("Error encountered while checking if tables on package are available for ORAGEN.")
   =1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = "No tables on package exist in USER_TABLES, bypassing ORAGEN3."
    CALL start_status(dm_err->eproc,sbr_utd_eid,sbr_utd_package_int)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->eproc = "Executing ORAGEN3 to update table definitions on the secondary node."
    CALL start_status(dm_err->eproc,sbr_utd_eid,sbr_utd_package_int)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 1))
     CALL echo("Before oragen of tables in package.")
     CALL trace(7)
    ENDIF
    SET dm2_etu->pkg_num = sbr_utd_package_int
    SET dm2_etu->tbl_name = ""
    SET dm2_etu->mode = "PACKAGE"
    IF ((dm_err->debug_flag > 1))
     CALL echorecord(dm2_etu)
    ENDIF
    EXECUTE oragen3 build(dm2_etu->pkg_num)
    IF ((dm_err->debug_flag > 1))
     CALL echo("After oragen of tables in package.")
     CALL trace(7)
    ENDIF
    IF (check_error("Error encountered while executing ORAGEN3.")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE install_code_sets(sbr_ics_ename,sbr_ics_eid,sbr_ics_package_int)
   IF (currdbuser != "V500")
    IF ((dm_err->debug_flag > 1))
     CALL echo("Bypass code set installation - current user not V500.")
    ENDIF
    RETURN(null)
   ENDIF
   DECLARE ocd_number = i4 WITH public, noconstant(sbr_ics_package_int)
   DECLARE env_name = vc WITH public, noconstant(sbr_ics_ename)
   DECLARE ics_start_dt_tm = f8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
   DECLARE ics_cs_timestamp = f8 WITH protect, noconstant(0.0)
   DECLARE ics_ccl_load_timestamp = f8 WITH protect, noconstant(0.0)
   RECORD ics_cs(
     1 cnt = i4
     1 qual[*]
       2 code_set = f8
       2 afd_instance = i4
       2 afd_updt_dt_tm = dq8
       2 di_instance = i4
   )
   IF (cnvtupper(trim(dip_install_mode,3))="MANUALNOLOAD")
    SET ocd_op->pre_op = olo_none
    SET ocd_op->cur_op = olo_code_sets
    SET ocd_op->next_op = olo_pre_uts
   ELSE
    SET ocd_op->pre_op = olo_load_ccl_file
    SET ocd_op->cur_op = olo_code_sets
    SET ocd_op->next_op = olo_pre_uts
    IF (check_package_op(ocd_op->pre_op,sbr_ics_package_int,sbr_ics_eid)=0)
     SET dm_err->err_ind = 1
     CALL bad_package_op(ocd_op->cur_op,ocd_op->pre_op,sbr_ics_eid,sbr_ics_package_int)
     RETURN(null)
    ENDIF
   ENDIF
   IF ( NOT (cnvtupper(trim(dip_install_mode,3)) IN ("CS", "MANUALNOLOAD")))
    IF (check_for_compl_row(ocd_op->cur_op,sbr_ics_package_int,sbr_ics_eid,ics_cs_timestamp)=0)
     RETURN(null)
    ENDIF
    IF (ics_cs_timestamp > 0)
     IF (sbr_ics_package_int < 0)
      IF (check_for_compl_row(olo_load_ccl_file,sbr_ics_package_int,sbr_ics_eid,
       ics_ccl_load_timestamp)=0)
       RETURN(null)
      ENDIF
     ELSE
      IF (check_for_compl_row(olo_adm_archive_dt,sbr_ics_package_int,sbr_ics_eid,
       ics_ccl_load_timestamp)=0)
       RETURN(null)
      ENDIF
     ENDIF
     IF (ics_ccl_load_timestamp=0)
      SET dm_err->err_ind = 1
      SET dm_err->emsg = "No log row found for the load of the CCL file."
      CALL end_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
      RETURN(null)
     ELSEIF (ics_cs_timestamp > ics_ccl_load_timestamp)
      SET dm_err->eproc = "Operation complete.  Code set installation successful in previous run."
      CALL end_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
      IF ((dnotify->status=1)
       AND (dm2_process_event_rs->ui_allowed_ind=1))
       SET dnotify->process = "INSTALLPLAN"
       SET dnotify->install_status = dpl_executing
       SET dnotify->event = "CODE SETS"
       SET dnotify->mode = dip_install_mode
       SET dnotify->plan_id = dip_package_abs_float
       SET dnotify->msgtype = dpl_progress
       CALL dn_add_body_text(concat(dip_install_mode," CODE SETS bypassed at ",format(cnvtdatetime(
           curdate,curtime3),";;q"),". They were installed successfully on a ","previous execution."),
        1)
       SET dm2_process_event_rs->begin_dt_tm = cnvtdatetime(curdate,curtime3)
       SET dm2_process_event_rs->status = dpl_complete
       SET dm2_process_event_rs->end_dt_tm = cnvtdatetime(curdate,curtime3)
       SET dm2_process_event_rs->install_plan_id = dip_package_abs_float
       CALL dm2_process_log_add_detail_text(dpl_audit_name,"EMAIL: CODE SETS bypassed")
       CALL dm2_process_log_add_detail_text(dpl_audit_type,dpl_progress)
       IF (dn_notify(null)=0)
        RETURN(0)
       ENDIF
      ENDIF
      RETURN(null)
     ELSE
      SET dm_err->eproc = "Reloading code sets."
     ENDIF
    ELSE
     SET dm_err->eproc = "Loading code sets."
    ENDIF
   ELSE
    SET dm_err->eproc = "Loading code sets."
   ENDIF
   SET dm_err->eproc = "Checking for code sets to load."
   CALL start_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_afd_code_value_set dacvs
    WHERE dacvs.alpha_feature_nbr=sbr_ics_package_int
    WITH nocounter
   ;end select
   IF (check_error("Error while checking for code sets to load.")=1)
    CALL end_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
    RETURN(null)
   ENDIF
   IF (curqual=0)
    IF (dip_update_itinerary_step("BATCHUP:CODE_SETS",cnvtdatetime(ics_start_dt_tm),cnvtdatetime(
      curdate,curtime3),dip_package_abs_float,dpl_complete)=0)
     RETURN(null)
    ENDIF
    SET dm_err->eproc = "Operation complete. No code sets found to load."
    CALL log_package_op(ocd_op->cur_op,ols_complete,dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
    CALL end_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
    RETURN(null)
   ENDIF
   IF (dip_update_itinerary_step("BATCHUP:CODE_SETS",cnvtdatetime(ics_start_dt_tm),cnvtdatetime(
     "01-JAN-1900"),dip_package_abs_float,dpl_executing)=0)
    RETURN(null)
   ENDIF
   IF (log_package_op(ocd_op->cur_op,ols_start,dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)=0)
    RETURN(null)
   ENDIF
   CALL start_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echo("Before code sets.")
    CALL trace(7)
   ENDIF
   EXECUTE dm_ocd_install_cvs
   IF ((dm_err->debug_flag > 1))
    CALL echo("After code sets.")
    CALL trace(7)
   ENDIF
   IF (check_error("Installation Failed. Error while loading code sets.")=1)
    CALL log_package_op(ocd_op->cur_op,ols_error,concat(dm_err->eproc," See ",dm_err->logfile,
      " in CCLUSERDIR for more information."),sbr_ics_eid,sbr_ics_package_int)
    CALL end_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
    RETURN(null)
   ENDIF
   SET dm_err->eproc = "Verifying all code sets are loaded."
   IF (log_package_op(ocd_op->cur_op,ols_running,dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)=0)
    RETURN(null)
   ENDIF
   CALL start_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   SELECT INTO "nl:"
    a.code_set
    FROM dm_afd_code_value_set a
    WHERE a.alpha_feature_nbr=sbr_ics_package_int
     AND  NOT ( EXISTS (
    (SELECT
     "X"
     FROM code_value_set b
     WHERE a.code_set=b.code_set)))
    WITH nocounter
   ;end select
   IF (check_error("Error while verifying code sets.")=1)
    CALL log_package_op(ocd_op->cur_op,ols_error,"Error while verifying code sets.",sbr_ics_eid,
     sbr_ics_package_int)
    CALL end_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
    RETURN(null)
   ENDIF
   IF (curqual > 0)
    SET dip_emsg = "Installation Failed. Not all code sets were loaded."
    CALL log_package_op(ocd_op->cur_op,ols_error,dip_emsg,sbr_ics_eid,sbr_ics_package_int)
    CALL end_status(dip_emsg,sbr_ics_eid,sbr_ics_package_int)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Verifying all code sets are loaded."
    SET dm_err->emsg = dip_emsg
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(null)
   ENDIF
   SET dm_err->eproc = "Finished loading code sets."
   IF (log_package_op(ocd_op->cur_op,ols_running,dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)=0)
    RETURN(null)
   ENDIF
   CALL end_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
   SET dm_err->eproc = "Loading COMMON_DATA_FOUNDATION rows."
   IF (log_package_op(ocd_op->cur_op,ols_running,dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)=0)
    RETURN(null)
   ENDIF
   CALL start_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
   IF ((dm_err->debug_flag > 1))
    CALL echo("Before cdf_meaning.")
    CALL trace(7)
   ENDIF
   EXECUTE dm_ocd_install_cdf
   IF ((dm_err->debug_flag > 1))
    CALL echo("After cdf_meaning.")
    CALL trace(7)
   ENDIF
   IF (check_error("Installation Failed. Error while loading COMMON_DATA_FOUNDATION rows.")=1)
    CALL log_package_op(ocd_op->cur_op,ols_error,concat(dm_err->eproc," See ",dm_err->logfile,
      " in CCLUSERDIR for more information."),sbr_ics_eid,sbr_ics_package_int)
    CALL end_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
    RETURN(null)
   ENDIF
   SET dm_err->eproc = "Verifying all COMMON_DATA_FOUNDATION rows are loaded."
   IF (log_package_op(ocd_op->cur_op,ols_running,dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)=0)
    RETURN(null)
   ENDIF
   CALL start_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   SELECT INTO "nl:"
    a.cdf_meaning
    FROM dm_afd_common_data_foundation a
    WHERE a.alpha_feature_nbr=sbr_ics_package_int
     AND  NOT ( EXISTS (
    (SELECT
     "X"
     FROM common_data_foundation b
     WHERE a.code_set=b.code_set
      AND a.cdf_meaning=b.cdf_meaning)))
    WITH nocounter
   ;end select
   IF (check_error("Error while verifying COMMON_DATA_FOUNDATION rows.")=1)
    CALL log_package_op(ocd_op->cur_op,ols_error,"Error while verifying COMMON_DATA_FOUNDATION rows.",
     sbr_ics_eid,sbr_ics_package_int)
    CALL end_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
    RETURN(null)
   ENDIF
   IF (curqual > 0)
    SET dip_emsg = "Installation Failed. Not all COMMON_DATA_FOUNDATION rows were loaded."
    CALL log_package_op(ocd_op->cur_op,ols_error,dip_emsg,sbr_ics_eid,sbr_ics_package_int)
    CALL end_status(dip_emsg,sbr_ics_eid,sbr_ics_package_int)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Verifying all COMMON_DATA_FOUNDATION rows are loaded."
    SET dm_err->emsg = dip_emsg
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(null)
   ENDIF
   SET dm_err->eproc = "Finished loading COMMON_DATA_FOUNDATION rows."
   IF (log_package_op(ocd_op->cur_op,ols_running,dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)=0)
    RETURN(null)
   ENDIF
   CALL end_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   SET dm_err->eproc = "Loading code set extensions."
   IF (log_package_op(ocd_op->cur_op,ols_running,dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)=0)
    RETURN(null)
   ENDIF
   CALL start_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echo("Before code set extensions.")
    CALL trace(7)
   ENDIF
   EXECUTE dm_ocd_install_cse
   IF ((dm_err->debug_flag > 1))
    CALL echo("After code set extensions.")
    CALL trace(7)
   ENDIF
   IF (check_error("Installation Failed. Error while loading code set extensions.")=1)
    CALL log_package_op(ocd_op->cur_op,ols_error,concat(dm_err->eproc," See ",dm_err->logfile,
      " in CCLUSERDIR for more information."),sbr_ics_eid,sbr_ics_package_int)
    CALL end_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
    RETURN(null)
   ENDIF
   SET dm_err->eproc = "Verifying all code set extensions are loaded."
   IF (log_package_op(ocd_op->cur_op,ols_running,dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)=0)
    RETURN(null)
   ENDIF
   CALL start_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   SELECT INTO "nl:"
    a.field_name
    FROM dm_afd_code_set_extension a
    WHERE a.alpha_feature_nbr=sbr_ics_package_int
     AND  NOT ( EXISTS (
    (SELECT
     "X"
     FROM code_set_extension b
     WHERE a.code_set=b.code_set
      AND a.field_name=b.field_name)))
    WITH nocounter
   ;end select
   IF (check_error("Error while verifying code set extensions.")=1)
    CALL log_package_op(ocd_op->cur_op,ols_error,"Error while verifying code set extensions.",
     sbr_ics_eid,sbr_ics_package_int)
    CALL end_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
    RETURN(null)
   ENDIF
   IF (curqual > 0)
    SET dip_emsg = "Installation Failed. Not all code set extensions were loaded."
    CALL log_package_op(ocd_op->cur_op,ols_error,dip_emsg,sbr_ics_eid,sbr_ics_package_int)
    CALL end_status(dip_emsg,sbr_ics_eid,sbr_ics_package_int)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Verifying all code set extensions are loaded."
    SET dm_err->emsg = dip_emsg
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(null)
   ENDIF
   SET dm_err->eproc = "Finished loading code set extensions."
   IF (log_package_op(ocd_op->cur_op,ols_running,dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)=0)
    RETURN(null)
   ENDIF
   CALL end_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   SET dm_err->eproc = "Loading code values."
   IF (log_package_op(ocd_op->cur_op,ols_running,dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)=0)
    RETURN(null)
   ENDIF
   CALL start_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echo("Before code values.")
    CALL trace(7)
   ENDIF
   EXECUTE dm_ocd_install_cv
   IF ((dm_err->debug_flag > 1))
    CALL echo("After code values.")
    CALL trace(7)
   ENDIF
   IF (check_error("Installation Failed. Error while loading code values.")=1)
    CALL log_package_op(ocd_op->cur_op,ols_error,concat(dm_err->eproc," See ",dm_err->logfile,
      " in CCLUSERDIR for more information."),sbr_ics_eid,sbr_ics_package_int)
    CALL end_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
    RETURN(null)
   ENDIF
   SET dm_err->eproc = "Verifying all code values are loaded."
   IF (log_package_op(ocd_op->cur_op,ols_running,dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)=0)
    RETURN(null)
   ENDIF
   CALL start_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   SELECT INTO "nl:"
    a.code_value
    FROM dm_afd_code_value a
    WHERE a.alpha_feature_nbr=sbr_ics_package_int
     AND a.cki IS NOT null
     AND  NOT ( EXISTS (
    (SELECT
     "X"
     FROM code_value b
     WHERE a.code_set=b.code_set
      AND a.cki=b.cki)))
    WITH nocounter
   ;end select
   IF (check_error("Error while verifying code values.")=1)
    CALL log_package_op(ocd_op->cur_op,ols_error,"Error while verifying code values.",sbr_ics_eid,
     sbr_ics_package_int)
    CALL end_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
    RETURN(null)
   ENDIF
   IF (curqual > 0)
    SET dip_emsg = "Installation Failed. Not all code values were loaded."
    CALL log_package_op(ocd_op->cur_op,ols_error,dip_emsg,sbr_ics_eid,sbr_ics_package_int)
    CALL end_status(dip_emsg,sbr_ics_eid,sbr_ics_package_int)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Verifying all code values are loaded."
    SET dm_err->emsg = dip_emsg
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(null)
   ENDIF
   SET dm_err->eproc = "Finished loading code values."
   IF (log_package_op(ocd_op->cur_op,ols_running,dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)=0)
    RETURN(null)
   ENDIF
   CALL end_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   SET dm_err->eproc = "Loading code value aliases."
   IF (log_package_op(ocd_op->cur_op,ols_running,dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)=0)
    RETURN(null)
   ENDIF
   CALL start_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echo("Before code value aliases.")
    CALL trace(7)
   ENDIF
   EXECUTE dm_ocd_install_cva
   IF ((dm_err->debug_flag > 1))
    CALL echo("After code value aliases.")
    CALL trace(7)
   ENDIF
   IF (check_error("Installation Failed. Error while loading code value aliases.")=1)
    CALL log_package_op(ocd_op->cur_op,ols_error,concat(dm_err->eproc," See ",dm_err->logfile,
      " in CCLUSERDIR for more information."),sbr_ics_eid,sbr_ics_package_int)
    CALL end_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
    RETURN(null)
   ENDIF
   SET dm_err->eproc = "Verifying all code value aliases are loaded."
   IF (log_package_op(ocd_op->cur_op,ols_running,dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)=0)
    RETURN(null)
   ENDIF
   CALL start_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   SELECT INTO "nl:"
    a.alias
    FROM dm_afd_code_value_alias a
    WHERE a.alpha_feature_nbr=sbr_ics_package_int
     AND  NOT ( EXISTS (
    (SELECT
     "X"
     FROM code_value_alias b
     WHERE a.code_set=b.code_set
      AND a.alias=b.alias)))
    WITH nocounter
   ;end select
   IF (check_error("Error while verifying code value aliases.")=1)
    CALL log_package_op(ocd_op->cur_op,ols_error,"Error while verifying code value aliases.",
     sbr_ics_eid,sbr_ics_package_int)
    CALL end_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
    RETURN(null)
   ENDIF
   IF (curqual > 0)
    SET dip_emsg = "Installation Failed. Not all code value aliases were loaded."
    CALL log_package_op(ocd_op->cur_op,ols_error,dip_emsg,sbr_ics_eid,sbr_ics_package_int)
    CALL end_status(dip_emsg,sbr_ics_eid,sbr_ics_package_int)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Verifying all code value aliases are loaded."
    SET dm_err->emsg = dip_emsg
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(null)
   ENDIF
   SET dm_err->eproc = "Finished loading code value aliases."
   IF (log_package_op(ocd_op->cur_op,ols_running,dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)=0)
    RETURN(null)
   ENDIF
   CALL end_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   SET dm_err->eproc = "Loading code value extensions."
   IF (log_package_op(ocd_op->cur_op,ols_running,dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)=0)
    RETURN(null)
   ENDIF
   CALL start_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echo("Before code value extensions.")
    CALL trace(7)
   ENDIF
   EXECUTE dm_ocd_install_cve
   IF ((dm_err->debug_flag > 1))
    CALL echo("After code value extensions.")
    CALL trace(7)
   ENDIF
   IF (check_error("Installation Failed. Error while loading code value aliases.")=1)
    CALL log_package_op(ocd_op->cur_op,ols_error,concat(dm_err->eproc," See ",dm_err->logfile,
      " in CCLUSERDIR for more information."),sbr_ics_eid,sbr_ics_package_int)
    CALL end_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
    RETURN(null)
   ENDIF
   SET dm_err->eproc = "Verifying all code value extensions are loaded."
   IF (log_package_op(ocd_op->cur_op,ols_running,dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)=0)
    RETURN(null)
   ENDIF
   CALL start_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   SELECT INTO "nl:"
    a.*
    FROM dm_afd_code_value_extension a
    WHERE a.alpha_feature_nbr=sbr_ics_package_int
     AND  NOT ( EXISTS (
    (SELECT
     "X"
     FROM code_value_extension b
     WHERE a.code_set=b.code_set
      AND a.field_name=b.field_name)))
    WITH nocounter
   ;end select
   IF (check_error("Error while verifying code value extensions.")=1)
    CALL log_package_op(ocd_op->cur_op,ols_error,"Error while verifying code value extensions.",
     sbr_ics_eid,sbr_ics_package_int)
    CALL end_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
    RETURN(null)
   ENDIF
   IF (curqual > 0)
    SET dip_emsg = "Installation Failed. Not all code value extensions were loaded."
    CALL log_package_op(ocd_op->cur_op,ols_error,dip_emsg,sbr_ics_eid,sbr_ics_package_int)
    CALL end_status(dip_emsg,sbr_ics_eid,sbr_ics_package_int)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Verifying all code value extensions are loaded."
    SET dm_err->emsg = dip_emsg
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(null)
   ENDIF
   SET dm_err->eproc = "Loading code value groups."
   CALL log_package_op(ocd_op->cur_op,ols_running,dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
   CALL start_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
   IF ((dm_err->debug_flag > 1))
    CALL echo("Before code value groups.")
    CALL trace(7)
   ENDIF
   EXECUTE dm_ocd_install_cvg
   IF ((dm_err->debug_flag > 1))
    CALL echo("After code value groups.")
    CALL trace(7)
   ENDIF
   IF (check_error("Installation Failed. Error while loading code value group.")=1)
    CALL log_package_op(ocd_op->cur_op,ols_error,concat(dm_err->eproc," See ",dm_err->logfile,
      " in CCLUSERDIR for more information."),sbr_ics_eid,sbr_ics_package_int)
    CALL end_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
    RETURN(null)
   ENDIF
   SET dm_err->eproc = "Verifying all code value groups are loaded."
   IF (log_package_op(ocd_op->cur_op,ols_running,dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)=0)
    RETURN(null)
   ENDIF
   CALL start_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info d
    WHERE d.info_domain="DM2_PKG_INSTALL_DATA"
     AND d.info_name="PERFORM_CVG_CHILD_CHECK"
    WITH nocounter
   ;end select
   IF (check_error("Error while identifying CVG check row in dm2_admin_dm_info")=1)
    CALL log_package_op(ocd_op->cur_op,ols_error,
     "Error while identifying CVG check row in dm2_admin_dm_info",sbr_ics_eid,sbr_ics_package_int)
    CALL end_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
    RETURN(null)
   ENDIF
   IF (curqual=0)
    SELECT INTO "nl:"
     FROM dm_afd_code_value_group ag
     WHERE ag.alpha_feature_nbr=sbr_ics_package_int
      AND  NOT ( EXISTS (
     (SELECT
      "x"
      FROM dm_afd_code_value ac,
       dm_alpha_features_env de
      WHERE ag.child_code_value=ac.code_value
       AND ac.alpha_feature_nbr=de.alpha_feature_nbr
       AND de.environment_id=sbr_ics_eid)))
     DETAIL
      dip_cvg_rs->cnt = (dip_cvg_rs->cnt+ 1), stat = alterlist(dip_cvg_rs->qual,dip_cvg_rs->cnt),
      dip_cvg_rs->qual[dip_cvg_rs->cnt].parent_cs = ag.code_set,
      dip_cvg_rs->qual[dip_cvg_rs->cnt].parent_cv = ag.parent_code_value, dip_cvg_rs->qual[dip_cvg_rs
      ->cnt].child_cs = ag.child_code_set, dip_cvg_rs->qual[dip_cvg_rs->cnt].child_cv = ag
      .child_code_value
     WITH nocounter
    ;end select
    IF (check_error("Error while verifying child code value groups.")=1)
     CALL log_package_op(ocd_op->cur_op,ols_error,"Error while verifying child code value groups.",
      sbr_ics_eid,sbr_ics_package_int)
     CALL end_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
     RETURN(null)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dip_cvg_rs)
    ENDIF
    IF (curqual > 0)
     IF (dip_disp_missing_cvg_rpt(null)=1)
      SET dip_emsg = concat(
       "Installation Failed. Not all code value group were loaded (Missing child code values).",
       "Please see Installation report: $CCLUSERDIR : ",dip_cvg_rpt_file)
     ELSE
      SET dip_emsg =
      "Installation Failed. Not all code value group were loaded (Missing child code values) ."
     ENDIF
     CALL log_package_op(ocd_op->cur_op,ols_error,dip_emsg,sbr_ics_eid,sbr_ics_package_int)
     CALL end_status(dip_emsg,sbr_ics_eid,sbr_ics_package_int)
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Verifying child code values exist for all code value groups."
     SET dm_err->emsg = dip_emsg
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(null)
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    a.*
    FROM dm_afd_code_value_group a,
     dm_afd_code_value ac1,
     dm_afd_code_value ac2
    PLAN (a
     WHERE a.alpha_feature_nbr=sbr_ics_package_int)
     JOIN (ac1
     WHERE ac1.alpha_feature_nbr=a.alpha_feature_nbr
      AND ac1.code_set=a.code_set
      AND ac1.code_value=a.parent_code_value)
     JOIN (ac2
     WHERE ac2.code_set=a.child_code_set
      AND ac2.code_value=a.child_code_value
      AND ac2.cki IS NOT null
      AND  NOT ( EXISTS (
     (SELECT
      "X"
      FROM code_value_group b,
       code_value cv1,
       code_value cv2
      WHERE b.parent_code_value=cv1.code_value
       AND b.child_code_value=cv2.code_value
       AND cv1.cki=ac1.cki
       AND cv2.cki=ac2.cki))))
    WITH maxqual(a,1), nocounter
   ;end select
   IF (check_error("Error while verifying code value groups.")=1)
    CALL log_package_op(ocd_op->cur_op,ols_error,"Error while verifying code value groups.",
     sbr_ics_eid,sbr_ics_package_int)
    CALL end_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
    RETURN(null)
   ENDIF
   IF (curqual > 0)
    SET dip_emsg = "Installation Failed. Not all code value group were loaded."
    CALL log_package_op(ocd_op->cur_op,ols_error,dip_emsg,sbr_ics_eid,sbr_ics_package_int)
    CALL end_status(dip_emsg,sbr_ics_eid,sbr_ics_package_int)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Verifying all code value groups are loaded."
    SET dm_err->emsg = dip_emsg
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(null)
   ENDIF
   IF (code_set_instance_init(sbr_ics_package_int)=0)
    RETURN(0)
   ENDIF
   FOR (ics_cs_cnt = 1 TO ics_cs->cnt)
     UPDATE  FROM dm_info di
      SET di.info_number = ics_cs->qual[ics_cs_cnt].afd_instance, di.info_date = cnvtdatetime(ics_cs
        ->qual[ics_cs_cnt].afd_updt_dt_tm), di.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       di.updt_id = 0, di.updt_applctx = sbr_ics_package_int, di.updt_task = reqinfo->updt_task,
       di.updt_cnt = (di.updt_cnt+ 1)
      WHERE di.info_domain="DM2-CODE-SET-INSTANCE"
       AND di.info_name=cnvtstring(ics_cs->qual[ics_cs_cnt].code_set)
      WITH nocounter
     ;end update
     IF (check_error("Error while updating code set instance row.")=1)
      ROLLBACK
      CALL log_package_op(ocd_op->cur_op,ols_error,"Error while updating code set instance row.",
       sbr_ics_eid,sbr_ics_package_int)
      CALL end_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
      RETURN(null)
     ENDIF
     IF (curqual=0)
      INSERT  FROM dm_info di
       SET di.info_domain = "DM2-CODE-SET-INSTANCE", di.info_name = cnvtstring(ics_cs->qual[
         ics_cs_cnt].code_set), di.info_number = ics_cs->qual[ics_cs_cnt].afd_instance,
        di.info_date = cnvtdatetime(ics_cs->qual[ics_cs_cnt].afd_updt_dt_tm), di.updt_dt_tm =
        cnvtdatetime(curdate,curtime3), di.updt_id = 0,
        di.updt_applctx = sbr_ics_package_int, di.updt_task = reqinfo->updt_task, di.updt_cnt = 0
       WITH nocounter
      ;end insert
      IF (check_error("Error while inserting code set instance row.")=1)
       ROLLBACK
       CALL log_package_op(ocd_op->cur_op,ols_error,"Error while inserting code set instance row.",
        sbr_ics_eid,sbr_ics_package_int)
       CALL end_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
       RETURN(null)
      ENDIF
     ENDIF
     IF (mod(ics_cs_cnt,1000)=0)
      COMMIT
     ENDIF
   ENDFOR
   COMMIT
   SET dm_err->eproc = "Operation complete. Code set installation successful."
   IF (log_package_op(ocd_op->cur_op,ols_complete,dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)=0)
    RETURN(null)
   ENDIF
   CALL end_status(dm_err->eproc,sbr_ics_eid,sbr_ics_package_int)
   IF (dip_update_itinerary_step("BATCHUP:CODE_SETS",cnvtdatetime(ics_start_dt_tm),cnvtdatetime(
     curdate,curtime3),dip_package_abs_float,dpl_complete)=0)
    RETURN(null)
   ENDIF
   FREE SET ocd_number
   FREE SET env_name
 END ;Subroutine
 SUBROUTINE install_atr(sbr_ia_eid,sbr_ia_package_int)
   IF (currdbuser != "V500")
    IF ((dm_err->debug_flag > 1))
     CALL echo("Bypass atr installation - current user not V500.")
    ENDIF
    RETURN(null)
   ENDIF
   DECLARE ocd_number = i4 WITH public, noconstant(sbr_ia_package_int)
   DECLARE ia_atr_timestamp = f8 WITH protect, noconstant(0.0)
   DECLARE ia_ccl_load_timestamp = f8 WITH protect, noconstant(0.0)
   SET ocd_op->pre_op = olo_uptime_schema
   SET ocd_op->cur_op = olo_atrs
   SET ocd_op->next_op = olo_post_uts
   IF (check_package_op(ocd_op->pre_op,sbr_ia_package_int,sbr_ia_eid)=0)
    CALL bad_package_op(ocd_op->cur_op,ocd_op->pre_op,sbr_ia_eid,sbr_ia_package_int)
    SET dm_err->err_ind = 1
    RETURN(null)
   ENDIF
   IF ( NOT (cnvtupper(trim(dip_install_mode,3)) IN ("ATR", "MANUALNOLOAD")))
    IF (check_for_compl_row(ocd_op->cur_op,sbr_ia_package_int,sbr_ia_eid,ia_atr_timestamp)=0)
     RETURN(null)
    ENDIF
    IF (ia_atr_timestamp > 0)
     IF (sbr_ia_package_int < 0)
      IF (check_for_compl_row(olo_load_ccl_file,sbr_ia_package_int,sbr_ia_eid,ia_ccl_load_timestamp)=
      0)
       RETURN(null)
      ENDIF
     ELSE
      IF (check_for_compl_row(olo_adm_archive_dt,sbr_ia_package_int,sbr_ia_eid,ia_ccl_load_timestamp)
      =0)
       RETURN(null)
      ENDIF
     ENDIF
     IF (ia_ccl_load_timestamp=0)
      SET dm_err->err_ind = 1
      SET dm_err->emsg = "No log row found for the load of the CCL file."
      CALL end_status(dm_err->eproc,sbr_ia_eid,sbr_ia_package_int)
      RETURN(null)
     ELSEIF (ia_atr_timestamp > ia_ccl_load_timestamp)
      SET dm_err->eproc = "Operation complete. ATR installation successful in previous run."
      CALL end_status(dm_err->eproc,sbr_ia_eid,sbr_ia_package_int)
      IF ((dnotify->status=1)
       AND (dm2_process_event_rs->ui_allowed_ind=1))
       SET dnotify->process = "INSTALLPLAN"
       SET dnotify->install_status = dpl_executing
       SET dnotify->event = "ATRs"
       SET dnotify->mode = dip_install_mode
       SET dnotify->plan_id = dip_package_abs_float
       SET dnotify->msgtype = dpl_progress
       CALL dn_add_body_text(concat(dip_install_mode,
         " ATRs (Applications / Tasks / Requests) bypassed at ",format(cnvtdatetime(curdate,curtime3),
          ";;q"),". They were installed successfully on a previous execution."),1)
       SET dm2_process_event_rs->begin_dt_tm = cnvtdatetime(curdate,curtime3)
       SET dm2_process_event_rs->status = dpl_complete
       SET dm2_process_event_rs->end_dt_tm = cnvtdatetime(curdate,curtime3)
       SET dm2_process_event_rs->install_plan_id = dip_package_abs_float
       CALL dm2_process_log_add_detail_text(dpl_audit_name,"EMAIL: ATRs bypassed.")
       CALL dm2_process_log_add_detail_text(dpl_audit_type,dpl_progress)
       IF (dn_notify(null)=0)
        RETURN(0)
       ENDIF
      ENDIF
      RETURN(null)
     ELSE
      SET dm_err->eproc = "Reinstalling the ATR rows."
     ENDIF
    ELSE
     SET dm_err->eproc = "Installing the ATR rows."
    ENDIF
   ELSE
    SET dm_err->eproc = "Installing the ATR rows."
   ENDIF
   IF (dip_update_itinerary_step("BATCHUP:ATRS",cnvtdatetime(curdate,curtime3),cnvtdatetime(
     "01-JAN-1900"),dip_package_abs_float,dpl_executing)=0)
    GO TO exit_program
   ENDIF
   IF (log_package_op(ocd_op->cur_op,ols_start,dm_err->eproc,sbr_ia_eid,sbr_ia_package_int)=0)
    RETURN(null)
   ENDIF
   CALL start_status(dm_err->eproc,sbr_ia_eid,sbr_ia_package_int)
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echo("Before dm_ocd_install_atr.")
    CALL trace(7)
   ENDIF
   EXECUTE dm_ocd_install_atr
   IF ((dm_err->debug_flag > 1))
    CALL echo("After dm_ocd_install_atr.")
    CALL trace(7)
   ENDIF
   IF (check_error("Installation Failed. Error while executing DM_OCD_INSTALL_ATR.")=1)
    CALL log_package_op(ocd_op->cur_op,ols_error,dm_err->eproc,sbr_ia_eid,sbr_ia_package)
    CALL end_status(dm_err->eproc,sbr_ia_eid,sbr_ia_package)
    RETURN(null)
   ENDIF
   IF ((docd_reply->status="S"))
    SET dm_err->eproc = "Operation Successful. ATR rows installed successfully."
    CALL log_package_op(ocd_op->cur_op,ols_complete,dm_err->eproc,sbr_ia_eid,sbr_ia_package_int)
    CALL end_status(dm_err->eproc,sbr_ia_eid,sbr_ia_package_int)
    IF (dip_update_itinerary_step("BATCHUP:ATRS",cnvtdatetime("01-JAN-1900"),cnvtdatetime(curdate,
      curtime3),dip_package_abs_float,dpl_complete)=0)
     GO TO exit_program
    ENDIF
    RETURN(null)
   ELSEIF ((docd_reply->status="F"))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Installation Failed. Not all ATR rows were installed successfully."
    SET dm_err->emsg = "Failed to verify the installation of ATR rows."
    CALL log_package_op(ocd_op->cur_op,ols_error,dm_err->eproc,sbr_ia_eid,sbr_ia_package_int)
    CALL end_status(dm_err->eproc,sbr_ia_eid,sbr_ia_package_int)
    RETURN(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE check_ccl_file(sbr_ccf_inst_mode,sbr_ccf_eid,sbr_ccf_package_str,sbr_ccf_lm_ind)
   DECLARE ccf_aload_method = i4 WITH public, noconstant(0)
   DECLARE sbr_ccf_package_int = i4 WITH public, constant(cnvtint(sbr_ccf_package_str))
   DECLARE user_sel_load = i2 WITH public, noconstant(0)
   SET sbr_ccf_lm_ind = - (1)
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc = build("sbr_ccf_package_int = ",sbr_ccf_package_int)
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET ocd_op->cur_op = olo_load_ccl_file
   SET ocd_op->pre_op = olo_none
   SET dm_err->eproc = "Checking the archive date of the schema file before loading."
   CALL start_status(dm_err->eproc,sbr_ccf_eid,sbr_ccf_package_int)
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   IF (sbr_ccf_inst_mode="LOAD")
    SET docd_reply->status = "L"
   ELSE
    SET docd_reply->status = "F"
    IF ((dm_err->debug_flag > 1))
     CALL echo("Before check date.")
     CALL trace(7)
    ENDIF
    EXECUTE dm_ocd_include_check_date sbr_ccf_package_int
    IF ((dm_err->debug_flag > 1))
     CALL echo("After check date.")
     CALL trace(7)
    ENDIF
    IF (check_error("Installation Failed.  Error executing DM_OCD_INCLUDE_CHECK_DATE.")=1)
     CALL log_package_op(ocd_op->cur_op,ols_error,dm_err->eproc,sbr_ccf_eid,sbr_ccf_package_int)
     CALL end_status(dm_err->eproc,sbr_ccf_eid,sbr_ccf_package_int)
     RETURN(null)
    ENDIF
   ENDIF
   CASE (docd_reply->status)
    OF "F":
     IF ((dir_ui_misc->auto_install_ind=0))
      SET dm_err->err_ind = 1
      SET dm_err->eproc = concat("User decided to abort installation of lower version.",
       "Schema file archive date is older than admin archive date.")
      CALL end_status(dm_err->eproc,sbr_ccf_eid,sbr_ccf_package_int)
      CALL log_package_op(ocd_op->cur_op,ols_error,dm_err->eproc,sbr_ccf_eid,sbr_ccf_package_int)
      RETURN(null)
     ELSE
      IF (dip_package_list_cnt=0)
       SET dip_package_list = build(sbr_ccf_package_int)
       SET dip_package_list_cnt = (dip_package_list_cnt+ 1)
      ELSE
       SET dip_package_list = trim(concat(dip_package_list,",",build(sbr_ccf_package_int)))
       SET dip_package_list_cnt = (dip_package_list_cnt+ 1)
      ENDIF
      RETURN(null)
     ENDIF
    OF "C":
     SET dm_err->eproc = "Loading Package schema file, clinical only."
     IF (log_package_op(ocd_op->cur_op,ols_start,dm_err->eproc,sbr_ccf_eid,sbr_ccf_package_int)=0)
      RETURN(null)
     ENDIF
     IF (dac_load_cload(sbr_ccf_package_int)=0)
      RETURN(null)
     ENDIF
     IF (load_package_schema_csv(sbr_ccf_eid,sbr_ccf_package_int)=0)
      RETURN(null)
     ENDIF
     SET dm_err->eproc = "Schema file loaded successfully for clinical data."
     CALL end_status(dm_err->eproc,sbr_ccf_eid,sbr_ccf_package_int)
     IF ((dm_err->err_ind=1))
      RETURN(null)
     ENDIF
     IF (log_package_op(ocd_op->cur_op,ols_complete,dm_err->eproc,sbr_ccf_eid,sbr_ccf_package_int)=0)
      RETURN(null)
     ENDIF
    OF "L":
     IF (user_sel_load=1)
      SET dm_err->eproc = concat("User decided to install a lower version of the package.",
       "Loading Package schema file.")
      IF (log_package_op(ocd_op->cur_op,ols_start,dm_err->eproc,sbr_ccf_eid,sbr_ccf_package_int)=0)
       RETURN(null)
      ENDIF
     ELSE
      SET dm_err->eproc = "Loading Package schema file."
      IF (log_package_op(ocd_op->cur_op,ols_running,dm_err->eproc,sbr_ccf_eid,sbr_ccf_package_int)=0)
       RETURN(null)
      ENDIF
     ENDIF
     IF (determine_admin_load_method(sbr_ccf_package_int,ccf_aload_method)=0)
      RETURN(null)
     ENDIF
     SET sbr_ccf_lm_ind = ccf_aload_method
     IF (ccf_aload_method=1)
      IF (load_package_schema_csv(sbr_ccf_eid,sbr_ccf_package_int)=0)
       RETURN(null)
      ENDIF
     ELSE
      CALL load_package_schema(sbr_ccf_eid,sbr_ccf_package_str)
      IF ((dm_err->err_ind=1))
       RETURN(null)
      ENDIF
     ENDIF
     SET dm_err->eproc = "Verifying schema file load."
     IF ((dm_err->debug_flag > 0))
      CALL echo(concat("sbr_ccf_inst_mode = ",sbr_ccf_inst_mode))
     ENDIF
     IF (user_sel_load=1)
      SET dm_err->eproc = concat("User decided to install a lower version of the package. ",
       "Verifying that schema file was loaded correctly.")
      IF (log_package_op(ocd_op->cur_op,ols_running,dm_err->eproc,sbr_ccf_eid,sbr_ccf_package_int)=0)
       RETURN(null)
      ENDIF
     ELSE
      SET dm_err->eproc = "Verifying that schema file was loaded correctly."
      CALL end_status(dm_err->eproc,sbr_ccf_eid,sbr_ccf_package_int)
      IF (log_package_op(ocd_op->cur_op,ols_running,dm_err->eproc,sbr_ccf_eid,sbr_ccf_package_int)=0)
       RETURN(null)
      ENDIF
     ENDIF
     IF ((dm_err->debug_flag > 0))
      SET dm_err->eproc = "Executing dm_ocd_include_check."
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     SET docd_reply->status = "F"
     IF ((dm_err->debug_flag > 1))
      CALL echo("Before include check.")
      CALL trace(7)
     ENDIF
     EXECUTE dm_ocd_include_check sbr_ccf_package_int
     IF ((dm_err->debug_flag > 1))
      CALL echo("After include check.")
      CALL trace(7)
     ENDIF
     IF (check_error("Installation Failed. Error executing dm_ocd_include_check.")=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(null)
     ENDIF
     IF ((dm_err->debug_flag > 0))
      SET dm_err->eproc = concat("After dm_ocd_include_check, docd_reply->status =.",docd_reply->
       status)
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     CASE (docd_reply->status)
      OF "F":
       SET dm_err->err_ind = 1
       SET dm_err->emsg = docd_reply->err_msg
       IF (user_sel_load=1)
        SET dm_err->eproc = "Installation Failed. Failed loading a lower version of the package."
        SET dm_err->emsg = "Load of schema file failed row count error check."
        CALL end_status(dm_err->eproc,sbr_ccf_eid,sbr_ccf_package_int)
        CALL log_package_op(ocd_op->cur_op,ols_error,dm_err->eproc,sbr_ccf_eid,sbr_ccf_package_int)
       ELSE
        SET dm_err->eproc = "Installation Failed.  Failed loading the Package schema file."
        SET dm_err->emsg = "Load of schema file failed row count error check."
        CALL end_status(dm_err->eproc,sbr_ccf_eid,sbr_ccf_package_int)
        CALL log_package_op(ocd_op->cur_op,ols_error,dm_err->eproc,sbr_ccf_eid,sbr_ccf_package_int)
       ENDIF
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       RETURN(null)
      OF "S":
       IF (user_sel_load=1)
        SET dm_err->eproc = concat("User decided to install a lower version of the package. ",
         "Schema file loaded successfully.")
        CALL end_status(dm_err->eproc,sbr_ccf_eid,sbr_ccf_package_int)
        IF ((dm_err->err_ind=1))
         RETURN(null)
        ENDIF
        IF (log_package_op(ocd_op->cur_op,ols_complete,dm_err->eproc,sbr_ccf_eid,sbr_ccf_package_int)
        =0)
         RETURN(null)
        ENDIF
       ELSE
        SET dm_err->eproc = "Schema file loaded successfully."
        CALL end_status(dm_err->eproc,sbr_ccf_eid,sbr_ccf_package_int)
        IF ((dm_err->err_ind=1))
         RETURN(null)
        ENDIF
        IF (log_package_op(ocd_op->cur_op,ols_complete,dm_err->eproc,sbr_ccf_eid,sbr_ccf_package_int)
        =0)
         RETURN(null)
        ENDIF
       ENDIF
     ENDCASE
    OF "N":
     SET dm_err->eproc = "Package schema file does not need to be loaded."
     CALL end_status(dm_err->eproc,sbr_ccf_eid,sbr_ccf_package_int)
     IF ((dm_err->err_ind=1))
      RETURN(null)
     ENDIF
     IF (log_package_op(ocd_op->cur_op,ols_complete,dm_err->eproc,sbr_ccf_eid,sbr_ccf_package_int)=0)
      RETURN(null)
     ENDIF
   ENDCASE
   IF (maintain_archive_dt_op(sbr_ccf_eid,sbr_ccf_package_int)=0)
    RETURN(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE load_package_schema(sbr_lps_eid,sbr_lps_package_str)
   DECLARE sbr_lps_package_int = i4 WITH public, noconstant(cnvtint(sbr_lps_package_str))
   DECLARE sbr_lps_file_str = vc WITH public
   DECLARE sbr_lps_loc_str = vc WITH public
   DECLARE sbr_lps_len_int = i4 WITH public
   SET dip_ccl_load_ind = 1
   SET ocd_op->cur_op = olo_load_ccl_file
   SET ocd_op->pre_op = olo_none
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc = "Entering LOAD_PACKAGE_SCHEMA."
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET sbr_lps_file_str = build("ocd_schema_",sbr_lps_package_int,".ccl")
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc = build("sbr_lps_package_int = ",sbr_lps_package_int)
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET sbr_lps_len_int = findstring("]",cerocd)
    SET sbr_lps_loc_str = concat(substring(1,(sbr_lps_len_int - 1),trim(cerocd)),trim(
      sbr_lps_package_str),"]",trim(sbr_lps_file_str,3))
   ELSE
    SET sbr_lps_loc_str = concat(trim(cerocd,3),"/",trim(sbr_lps_package_str),"/",trim(
      sbr_lps_file_str,3))
   ENDIF
   IF (findfile(sbr_lps_loc_str)=0)
    DELETE  FROM dm_ocd_log d
     WHERE d.environment_id=sbr_lps_eid
      AND d.project_type="INSTALL LOG"
      AND d.ocd=sbr_lps_package_int
     WITH nocounter
    ;end delete
    COMMIT
    CALL start_status(concat("Installation Failed. Package schema CCL file ",trim(sbr_lps_file_str,3),
      " not found."),sbr_lps_eid,sbr_lps_package_int)
    SET dm_err->err_ind = 1
    RETURN(null)
   ENDIF
   SET dm_err->eproc = concat("Including CCL file <",trim(sbr_lps_loc_str),">.")
   CALL start_status(dm_err->eproc,sbr_lps_eid,sbr_lps_package_int)
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   IF (log_package_op(ocd_op->cur_op,ols_running,dm_err->eproc,sbr_lps_eid,sbr_lps_package_int)=0)
    RETURN(null)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echo("Before include file.")
    CALL trace(7)
   ENDIF
   EXECUTE dm_ocd_incl_file sbr_lps_loc_str
   IF ((dm_err->debug_flag > 1))
    CALL echo("After include file.")
    CALL trace(7)
   ENDIF
   IF (check_error("Error executing DM_OCD_INCL_FILE.")=1)
    CALL log_package_op(ocd_op->cur_op,ols_error,dm_err->eproc,sbr_lps_eid,sbr_lps_package_int)
    CALL end_status(dm_err->eproc,sbr_lps_eid,sbr_lps_package_int)
    RETURN(null)
   ENDIF
   IF ((docd_reply->status="F"))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Installation Failed. Error while including CCL file <",trim(
      sbr_lps_loc_str),">.")
    CALL end_status(dm_err->eproc,sbr_lps_eid,sbr_lps_package_int)
    CALL log_package_op(ocd_op->cur_op,ols_error,dm_err->eproc,sbr_lps_eid,sbr_lps_package_int)
    RETURN(null)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc = concat("status=",docd_reply->status)
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET dm_err->eproc = concat("Operation Successful. CCL file ",trim(sbr_lps_loc_str,3),
    " included successfully.")
   IF (log_package_op(ocd_op->cur_op,ols_complete,dm_err->eproc,sbr_lps_eid,sbr_lps_package_int)=0)
    RETURN(null)
   ENDIF
   CALL end_status(dm_err->eproc,sbr_lps_eid,sbr_lps_package_int)
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc = "Leaving LOAD_PACKAGE_SCHEMA."
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
 END ;Subroutine
 SUBROUTINE execute_readmes(sbr_er_mode,sbr_er_eid,sbr_er_package_int)
   DECLARE rb_ocd = i4 WITH public, noconstant(sbr_er_package_int)
   DECLARE rb_execution = vc WITH public, noconstant(sbr_er_mode)
   SET dm_err->eproc = concat("Preparing to execute '",sbr_er_mode," readmes'.")
   CALL start_status(dm_err->eproc,sbr_er_eid,sbr_er_package_int)
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   IF (checkdic("DM_README","T",0)=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("DM_README table not found. No ",sbr_er_mode," readmes attempted.")
    SET dm_err->emsg = "The DM_README table does not exist."
    CALL end_status(dm_err->eproc,sbr_er_eid,sbr_er_package_int)
    RETURN(null)
   ENDIF
   IF (dm2_rr_toolset_usage(null)=0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(null)
   ENDIF
   IF ((dm2_rr_misc->dm2_toolset_usage="Y"))
    SET dm_err->eproc = concat("Executing DM2_README_BATCH for ",sbr_er_mode," readmes.")
    CALL start_status(dm_err->eproc,sbr_er_eid,sbr_er_package_int)
    IF ((dm_err->debug_flag > 1))
     CALL echo("Before dm2 readme batch.")
     CALL trace(7)
    ENDIF
    EXECUTE dm2_readme_batch 0
    IF ((dm_err->debug_flag > 1))
     CALL echo("After dm2 readme batch.")
     CALL trace(7)
    ENDIF
    IF ((dm_err->err_ind=1)
     AND (dm2_rr_misc->readme_errors_ind=0))
     RETURN(null)
    ENDIF
    IF ((dm2_rr_misc->readme_errors_ind=1))
     SET dip_final_msg->error_ind = 1
     SET dm_err->eproc = concat("Executing ",sbr_er_mode," readmes. ")
     SET dip_final_msg->eproc = dm_err->eproc
     IF (cnvtupper(dm_err->emsg)="*ONE OR MORE KILLED*")
      SET dm_err->emsg = concat("One or more readmes failed/killed during installation of ",
       sbr_er_mode," readmes. ")
     ELSE
      SET dm_err->emsg = concat("One or more readmes failed during installation of ",sbr_er_mode,
       " readmes. ")
     ENDIF
     SET dip_final_msg->emsg = dm_err->emsg
     SET dm_err->user_action = concat("Please type 'DM_README_OCD_LOG ",trim(cnvtstring(
        sbr_er_package_int),3)," go' from the CCL prompt to view the ",
      "status of all readmes on this Package or Plan.")
     SET dip_final_msg->user_action = dm_err->user_action
     CALL log_package_op(ocd_op->cur_op,ols_error,concat(dm_err->emsg,dm_err->user_action),sbr_er_eid,
      sbr_er_package_int)
     CALL end_status(dip_final_msg->emsg,sbr_er_eid,sbr_er_package_int)
     SET dm_err->err_ind = 1
     RETURN(null)
    ELSE
     SET dm_err->eproc = concat("Finished executing all ",trim(ocd_op->cur_op),".")
     CALL log_package_op(ocd_op->cur_op,ols_complete,dm_err->eproc,sbr_er_eid,sbr_er_package_int)
     CALL end_status(dm_err->eproc,sbr_er_eid,sbr_er_package_int)
    ENDIF
   ELSE
    SET dm_err->eproc = concat("Executing DM_README_BATCH for ",sbr_er_mode," readmes.")
    CALL start_status(dm_err->eproc,sbr_er_eid,sbr_er_package_int)
    EXECUTE dm_readme_batch 0
    IF ((dm_err->debug_flag > 1))
     CALL echo("After dm readme batch.")
     CALL trace(7)
    ENDIF
    IF (check_error("Installation Failed. Error while executing DM_README_BATCH.")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(null)
    ENDIF
    CALL wait_for_readmes(sbr_er_eid,sbr_er_package_int)
    IF ((dm_err->err_ind=1))
     RETURN(null)
    ENDIF
    DECLARE err_readme_id = i4 WITH public, noconstant(0)
    SET err_readme_id = check_readme_errors(ocd_op->cur_op,cnvtupper(sbr_er_mode),sbr_er_eid,
     sbr_er_package_int)
    IF ((dm_err->err_ind=1))
     RETURN(null)
    ENDIF
    IF (err_readme_id)
     SET dip_final_msg->error_ind = 1
     SET dm_err->eproc = concat("Installation Failed. Readme step ",trim(cnvtstring(err_readme_id)),
      " failed.")
     SET dip_final_msg->eproc = dm_err->eproc
     SET dip_final_msg->emsg = dm_err->eproc
     SET dm_err->user_action = concat(" Please type 'DM_README_OCD_LOG ",trim(cnvtstring(
        sbr_er_package_int))," go' to view the status of all readmes for the Package or Plan.")
     SET dip_final_msg->user_action = dm_err->user_action
     CALL log_package_op(ocd_op->cur_op,ols_error,concat(dm_err->eproc,dm_err->user_action),
      sbr_er_eid,sbr_er_package_int)
     CALL end_status(dm_err->eproc,sbr_er_eid,sbr_er_package_int)
     SET dm_err->err_ind = 1
     RETURN(null)
    ELSE
     SET dm_err->eproc = concat("Finished executing all ",trim(ocd_op->cur_op),".")
     CALL log_package_op(ocd_op->cur_op,ols_complete,dm_err->eproc,sbr_er_eid,sbr_er_package_int)
     CALL end_status(dm_err->eproc,sbr_er_eid,sbr_er_package_int)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE process_readmes(sbr_pr_mode,sbr_pr_eid,sbr_pr_package_int)
  CASE (cnvtupper(trim(sbr_pr_mode,3)))
   OF "PREUP":
    IF (currdbuser="V500")
     SET ocd_op->pre_op = olo_code_sets
    ELSE
     SET ocd_op->pre_op = olo_load_ccl_file
    ENDIF
    SET ocd_op->cur_op = olo_pre_uts
    SET ocd_op->next_op = olo_uptime_schema
    IF (check_package_op(ocd_op->pre_op,sbr_pr_package_int,sbr_pr_eid)=0)
     SET dm_err->err_ind = 1
     CALL bad_package_op(ocd_op->cur_op,ocd_op->pre_op,sbr_pr_eid,sbr_pr_package_int)
     RETURN(null)
    ENDIF
    SET dm_err->eproc = "Executing pre-uts readme steps."
    IF (log_package_op(ocd_op->cur_op,ols_start,dm_err->eproc,sbr_pr_eid,sbr_pr_package_int)=0)
     RETURN(null)
    ENDIF
    CALL start_status(dm_err->eproc,sbr_pr_eid,sbr_pr_package_int)
    IF ((dm_err->err_ind=1))
     RETURN(null)
    ENDIF
    CALL execute_readmes("PREUP",sbr_pr_eid,sbr_pr_package_int)
   OF "POSTUP":
    IF (currdbuser="V500")
     SET ocd_op->pre_op = olo_atrs
    ELSE
     SET ocd_op->pre_op = olo_uptime_schema
    ENDIF
    SET ocd_op->cur_op = olo_post_uts
    SET ocd_op->next_op = olo_pre_dts
    IF (check_package_op(ocd_op->pre_op,sbr_pr_package_int,sbr_pr_eid)=0)
     SET dm_err->err_ind = 1
     CALL bad_package_op(ocd_op->cur_op,ocd_op->pre_op,sbr_pr_eid,sbr_pr_package_int)
     RETURN(null)
    ENDIF
    SET dm_err->eproc = "Executing post-uts readme steps."
    IF (log_package_op(ocd_op->cur_op,ols_start,dm_err->eproc,sbr_pr_eid,sbr_pr_package_int)=0)
     RETURN(null)
    ENDIF
    CALL start_status(dm_err->eproc,sbr_pr_eid,sbr_pr_package_int)
    IF ((dm_err->err_ind=1))
     RETURN(null)
    ENDIF
    CALL execute_readmes("POSTUP",sbr_pr_eid,sbr_pr_package_int)
    IF ((dm_err->err_ind=1))
     RETURN(null)
    ENDIF
    CALL execute_readmes("POSTUP2",sbr_pr_eid,sbr_pr_package_int)
    IF (currdbuser="V500")
     EXECUTE dm2_updt_cv_actind_log sbr_pr_package_int
    ENDIF
   OF "PRECYCLE":
    SET ocd_op->pre_op = olo_post_uts
    SET ocd_op->cur_op = olo_pre_cycle
    SET ocd_op->next_op = olo_pre_dts
    IF (check_package_op(ocd_op->pre_op,sbr_pr_package_int,sbr_pr_eid)=0)
     SET dm_err->err_ind = 1
     CALL bad_package_op(ocd_op->cur_op,ocd_op->pre_op,sbr_pr_eid,sbr_pr_package_int)
     RETURN(null)
    ENDIF
    SET dm_err->eproc = "Executing precycle readme steps."
    IF (log_package_op(ocd_op->cur_op,ols_start,dm_err->eproc,sbr_pr_eid,sbr_pr_package_int)=0)
     RETURN(null)
    ENDIF
    CALL start_status(dm_err->eproc,sbr_pr_eid,sbr_pr_package_int)
    IF ((dm_err->err_ind=1))
     RETURN(null)
    ENDIF
    CALL execute_readmes("PRECYCLE",sbr_pr_eid,sbr_pr_package_int)
   OF "PREDOWN":
    SET ocd_op->pre_op = olo_pre_cycle
    SET ocd_op->cur_op = olo_pre_dts
    SET ocd_op->next_op = olo_downtime_schema
    IF (check_package_op(ocd_op->pre_op,sbr_pr_package_int,sbr_pr_eid)=0)
     SET dm_err->err_ind = 1
     CALL bad_package_op(ocd_op->cur_op,ocd_op->pre_op,sbr_pr_eid,sbr_pr_package_int)
     RETURN(null)
    ENDIF
    SET dm_err->eproc = "Executing pre-dts readme steps."
    IF (log_package_op(ocd_op->cur_op,ols_start,dm_err->eproc,sbr_pr_eid,sbr_pr_package_int)=0)
     RETURN(null)
    ENDIF
    CALL start_status(dm_err->eproc,sbr_pr_eid,sbr_pr_package_int)
    IF ((dm_err->err_ind=1))
     RETURN(null)
    ENDIF
    CALL execute_readmes("PREDOWN",sbr_pr_eid,sbr_pr_package_int)
   OF "POSTDOWN":
    SET ocd_op->pre_op = olo_downtime_schema
    SET ocd_op->cur_op = olo_post_dts
    SET ocd_op->next_op = olo_post_inst
    IF (check_package_op(ocd_op->pre_op,sbr_pr_package_int,sbr_pr_eid)=0)
     SET dm_err->err_ind = 1
     CALL bad_package_op(ocd_op->cur_op,ocd_op->pre_op,sbr_pr_eid,sbr_pr_package_int)
     RETURN(null)
    ENDIF
    SET dm_err->eproc = "Executing post-dts readme steps."
    IF (log_package_op(ocd_op->cur_op,ols_start,dm_err->eproc,sbr_pr_eid,sbr_pr_package_int)=0)
     RETURN(null)
    ENDIF
    CALL start_status(dm_err->eproc,sbr_pr_eid,sbr_pr_package_int)
    IF ((dm_err->err_ind=1))
     RETURN(null)
    ENDIF
    CALL execute_readmes("POSTDOWN",sbr_pr_eid,sbr_pr_package_int)
   OF "UP":
    SET ocd_op->pre_op = olo_post_dts
    SET ocd_op->cur_op = olo_post_inst
    SET ocd_op->next_op = olo_none
    IF (check_package_op(ocd_op->pre_op,sbr_pr_package_int,sbr_pr_eid)=0)
     SET dm_err->err_ind = 1
     CALL bad_package_op(ocd_op->cur_op,ocd_op->pre_op,sbr_pr_eid,sbr_pr_package_int)
     RETURN(null)
    ENDIF
    SET dm_err->eproc = "Executing post-inst readme steps."
    IF (log_package_op(ocd_op->cur_op,ols_start,dm_err->eproc,sbr_pr_eid,sbr_pr_package_int)=0)
     RETURN(null)
    ENDIF
    CALL start_status(dm_err->eproc,sbr_pr_eid,sbr_pr_package_int)
    IF ((dm_err->err_ind=1))
     RETURN(null)
    ENDIF
    CALL execute_readmes("UP",sbr_pr_eid,sbr_pr_package_int)
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Installation Failed. Error while processing readmes."
    SET dm_err->emsg = concat("Unexpected readme mode ",cnvtupper(trim(sbr_pr_mode,3))," found.")
    CALL end_status(dm_err->eproc,sbr_pr_eid,sbr_pr_package_int)
    RETURN(null)
  ENDCASE
  IF ((dm_err->err_ind=1))
   RETURN(null)
  ENDIF
 END ;Subroutine
 SUBROUTINE display_readme_est_report(sbr_drer_mode,sbr_drer_eid,sbr_drer_package_int)
   DECLARE rm_estimator_ocd = i4 WITH public, noconstant(sbr_drer_package_int)
   DECLARE drer_exec_str = vc WITH protect, noconstant("EXECUTIONS INCLUDE:")
   DECLARE drer_execution = vc WITH protect, noconstant("")
   DECLARE drer_rspchk_ind = i2 WITH protect, noconstant(0)
   DECLARE drer_readme = i2 WITH protect, noconstant(0)
   IF (cnvtupper(trim(dip_install_mode,3))="MANUALNOLOAD")
    SET ocd_op->pre_op = olo_none
    SET ocd_op->cur_op = olo_readme_report
   ELSE
    SET ocd_op->pre_op = olo_load_ccl_file
    SET ocd_op->cur_op = olo_readme_report
    IF (check_package_op(ocd_op->pre_op,sbr_drer_package_int,sbr_drer_eid)=0)
     SET dm_err->err_ind = 1
     CALL bad_package_op(ocd_op->cur_op,ocd_op->pre_op,sbr_drer_eid,sbr_drer_package_int)
     RETURN(null)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Displaying README estimate report."
   IF (log_package_op(ocd_op->cur_op,ols_start,dm_err->eproc,sbr_drer_eid,sbr_drer_package_int)=0)
    RETURN(null)
   ENDIF
   CALL start_status(dm_err->eproc,sbr_drer_eid,sbr_drer_package_int)
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   IF (dm2_rr_toolset_usage(null)=0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(null)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echo("Before readme estimator.")
    CALL trace(7)
   ENDIF
   IF ((dm2_rr_misc->dm2_toolset_usage="Y"))
    EXECUTE dm2_readme_estimator rm_estimator_ocd
    IF ((dm_err->err_ind=1))
     RETURN(null)
    ENDIF
    IF (sbr_drer_mode IN ("PREVIEW", "BATCHPREVIEW"))
     FOR (drer_readme = 1 TO drr_readmes_to_run->readme_cnt)
       IF ((drr_readmes_to_run->readme[drer_readme].spchk_readme_cnt > 0))
        SET drer_execution = build("<",cnvtupper(drr_readmes_to_run->readme[drer_readme].execution),
         ">")
        IF (findstring(drer_execution,drer_exec_str)=0)
         SET drer_exec_str = build(drer_exec_str,drer_execution)
        ENDIF
       ENDIF
     ENDFOR
     IF (check_dol_row(sbr_drer_eid,olpt_install_plan,olo_readme_spchk,1,sbr_drer_package_int,
      ols_complete,drer_rspchk_ind)=0)
      RETURN(null)
     ENDIF
     IF (drer_execution="")
      IF (drer_rspchk_ind=1)
       DELETE  FROM dm_ocd_log d
        WHERE d.environment_id=sbr_drer_eid
         AND d.project_type=cnvtupper(olpt_install_plan)
         AND d.project_name=cnvtupper(olo_readme_spchk)
         AND d.project_instance=1
         AND d.ocd=sbr_drer_package_int
        WITH nocounter
       ;end delete
       IF (check_error("Delete readme space check row from dm_ocd_log table.")=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        ROLLBACK
        RETURN(null)
       ELSE
        COMMIT
       ENDIF
      ENDIF
     ELSE
      IF (write_dol_row(sbr_drer_eid,olpt_install_plan,olo_readme_spchk,1,sbr_drer_package_int,
       cnvtdatetime(curdate,curtime3),ols_complete,null,cnvtdatetime(curdate,curtime3),0,
       0.0,drer_exec_str,1)=0)
       RETURN(null)
      ENDIF
     ENDIF
    ENDIF
   ELSE
    EXECUTE dm_readme_estimator
    IF (check_error("Installation Failed. Error while displaying README estimate report.")=1)
     SET dm_err->err_ind = 1
     CALL log_package_op(ocd_op->cur_op,ols_error,dm_err->eproc,sbr_drer_eid,sbr_drer_package_int)
     CALL end_status(dm_err->eproc,sbr_drer_eid,sbr_drer_package_int)
     RETURN(null)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echo("After readme estimator.")
    CALL trace(7)
   ENDIF
   SET dm_err->eproc = "Finished displaying README estimate report."
   IF (log_package_op(ocd_op->cur_op,ols_complete,dm_err->eproc,sbr_drer_eid,sbr_drer_package_int)=0)
    RETURN(null)
   ENDIF
   CALL end_status(dm_err->eproc,sbr_drer_eid,sbr_drer_package_int)
 END ;Subroutine
 SUBROUTINE wait_for_readmes(sbr_wfr_eid,sbr_wfr_package_int)
   DECLARE sbr_wfr_done = i2 WITH public, noconstant(0)
   DECLARE sbr_wfr_readme = vc WITH public, noconstant("NOT_SET")
   WHILE (sbr_wfr_done=0)
     SELECT INTO "nl:"
      FROM dm_ocd_log d
      WHERE d.environment_id=sbr_wfr_eid
       AND d.project_type="README"
       AND d.ocd=sbr_wfr_package_int
       AND ((d.status=ols_running) OR (d.status = null))
      ORDER BY d.start_dt_tm DESC
      DETAIL
       sbr_wfr_readme = d.project_name
      WITH nocounter
     ;end select
     IF (check_error("Installation Failed. Error while waiting for readmes to finish.")=1)
      CALL end_status(dm_err->eproc,sbr_wfr_eid,sbr_wfr_package_int)
      RETURN(null)
     ENDIF
     IF (curqual=0)
      SET sbr_wfr_done = 1
      SET dm_err->eproc = concat("Finished executing all ",ocd_op->cur_op,".")
      CALL log_package_op(ocd_op->cur_op,ols_running,dm_err->eproc,sbr_wfr_eid,sbr_wfr_package_int)
      CALL start_status(dm_err->eproc,sbr_wfr_eid,sbr_wfr_package_int)
      IF ((dm_err->err_ind=1))
       RETURN(null)
      ENDIF
     ELSE
      SET dm_err->eproc = concat("Waiting for readme step(s) to finish processing (",trim(
        sbr_wfr_readme),")")
      CALL log_package_op(ocd_op->cur_op,ols_running,dm_err->eproc,sbr_wfr_eid,sbr_wfr_package_int)
      CALL start_status(dm_err->eproc,sbr_wfr_eid,sbr_wfr_package_int)
      IF ((dm_err->err_ind=1))
       RETURN(null)
      ENDIF
      CALL pause(60)
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE check_readme_errors(sbr_cre_ocd_op,sbr_cre_readme_mode,sbr_cre_eid,sbr_cre_package_int)
   FREE RECORD cre_readme
   RECORD cre_readme(
     1 readme_id = f8
     1 error_msg = vc
   )
   SET cre_readme->readme_id = 0
   SELECT INTO "nl:"
    FROM dm_ocd_log l,
     dm_readme r
    PLAN (l
     WHERE l.environment_id=sbr_cre_eid
      AND l.project_type="README"
      AND l.ocd=sbr_cre_package_int
      AND l.status="FAILED")
     JOIN (r
     WHERE r.readme_id=cnvtreal(l.project_name)
      AND r.instance=l.project_instance
      AND r.execution=sbr_cre_readme_mode
      AND r.active_ind=1)
    ORDER BY l.start_dt_tm DESC
    DETAIL
     cre_readme->readme_id = cnvtint(l.project_name), cre_readme->error_msg = l.message
    WITH nocounter
   ;end select
   IF (check_error("Installation Failed. Error while getting readme errors from DM_OCD_LOG.")=1)
    CALL end_status(dm_err->eproc,sbr_cre_eid,sbr_cre_package_int)
    RETURN(0)
   ENDIF
   IF ((cre_readme->readme_id=0))
    RETURN(0)
   ELSE
    CALL disp_readme_error(sbr_cre_ocd_op,cre_readme->readme_id,cre_readme->error_msg,sbr_cre_eid,
     sbr_cre_package_int)
    RETURN(cre_readme->readme_id)
   ENDIF
 END ;Subroutine
 SUBROUTINE disp_readme_error(sbr_dre_op,sbr_dre_readme_id,sbr_dre_message,sbr_dre_eid,
  sbr_dre_package_int)
   SET dm_err->eproc = "One or more readmes failed during installation."
   SET dm_err->emsg = concat("An error occurred while running ",sbr_dre_op,". ","Readme ID: ",trim(
     cnvtstring(sbr_dre_readme_id),3),
    ". ","Message: ",sbr_dre_message)
   SET dm_err->user_action = concat("Please type 'DM_README_OCD_LOG ",trim(cnvtstring(
      sbr_dre_package_int),3)," go' from the CCL prompt to view the ",
    "status of all readmes on this Package or Plan.")
   CALL end_status(dm_err->emsg,sbr_dre_eid,sbr_dre_package_int)
 END ;Subroutine
 SUBROUTINE display_atr_reports(sbr_dar_mode,sbr_dar_eid,sbr_dar_package_int)
   DECLARE ocd_apps_mode = vc WITH public, noconstant(sbr_dar_mode)
   DECLARE ocd_tasks_mode = vc WITH public, noconstant(sbr_dar_mode)
   DECLARE ocd_number = i4 WITH public, noconstant(sbr_dar_package_int)
   IF (currdbuser != "V500")
    IF ((dm_err->debug_flag > 1))
     CALL echo("Bypass atr reporting - current user not V500.")
    ENDIF
    RETURN(null)
   ENDIF
   IF (validate(call_script,"X") != "DM_OCD_MENU")
    CALL start_status("Displaying new ATR report.",sbr_dar_eid,sbr_dar_package_int)
    IF ((dm_err->err_ind=1))
     RETURN(null)
    ENDIF
    IF ((dm_err->debug_flag > 1))
     CALL echo("Before dm_ocd_apps.")
     CALL trace(7)
    ENDIF
    EXECUTE dm_ocd_apps
    SET message = nowindow
    IF ((dm_err->debug_flag > 1))
     CALL echo("After dm_ocd_apps.")
     CALL trace(7)
    ENDIF
    IF (check_error("Installation Failed. Error while executing DM_OCD_APPS.")=1)
     CALL end_status(dm_err->eproc,sbr_dar_eid,sbr_dar_package_int)
     RETURN(null)
    ENDIF
    IF ((dm_err->debug_flag > 1))
     CALL echo("Before dm_ocd_tasks.")
     CALL trace(7)
    ENDIF
    EXECUTE dm_ocd_tasks
    SET message = nowindow
    IF ((dm_err->debug_flag > 1))
     CALL echo("After dm_ocd_tasks.")
     CALL trace(7)
    ENDIF
    IF (check_error("Installation Failed. Error while executing DM_OCD_TASKS.")=1)
     CALL end_status(dm_err->eproc,sbr_dar_eid,sbr_dar_package_int)
     RETURN(null)
    ENDIF
    CALL end_status("Displaying new ATR report complete",sbr_dar_eid,sbr_dar_package_int)
    IF ((dm_err->err_ind=1))
     RETURN(null)
    ENDIF
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo("Bypassing call of dm_ocd_apps/tasks in dm2_install_pkg, called from dm_ocd_menu.")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE delete_preview_log(sbr_dpl_eid,sbr_dpl_package_int)
   DECLARE sbr_dpl_ut_mode_ind = i2 WITH public, noconstant(0)
   DECLARE sbr_dpl_dt_mode_ind = i2 WITH public, noconstant(0)
   DECLARE sbr_dpl_pi_mode_ind = i2 WITH public, noconstant(0)
   SET sbr_dpl_ut_mode_ind = check_package_op(olo_code_sets,sbr_dpl_package_int,sbr_dpl_eid)
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   SET sbr_dpl_dt_mode_ind = check_package_op(olo_pre_dts,sbr_dpl_package_int,sbr_dpl_eid)
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   SET sbr_dpl_pi_mode_ind = check_package_op(olo_post_inst,sbr_dpl_package_int,sbr_dpl_eid)
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   IF (sbr_dpl_ut_mode_ind=0
    AND sbr_dpl_dt_mode_ind=0
    AND sbr_dpl_pi_mode_ind=0)
    DELETE  FROM dm_alpha_features_env d
     WHERE d.environment_id=sbr_dpl_eid
      AND d.alpha_feature_nbr=sbr_dpl_package_int
     WITH nocounter
    ;end delete
    COMMIT
    IF (check_error("Installation Failed. Error while deleting log rows from preview.")=1)
     SET dm_err->user_action = "Run OCD_INCL_SCHEMA2 again in PREVIEW mode."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(null)
    ENDIF
    IF (del_all_package_op(sbr_dpl_eid,sbr_dpl_package_int)=0)
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Delete from dm_ocd_log failed. Run OCD_INCL_SCHEMA2 again in PREVIEW mode."
     CALL end_status(dm_err->eproc,sbr_dpl_eid,sbr_dpl_package_int)
     RETURN(null)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE prep_dm2_schema(sbr_pds_eid,sbr_pds_package_str)
   DECLARE sbr_pds_package_int = i4 WITH public, noconstant(0)
   DECLARE sbr_pds_return_val = i2 WITH public, noconstant(0)
   DECLARE sbr_pds_ois_cmd = vc WITH protect, noconstant("")
   DECLARE sbr_pds_copy_ind = i2 WITH protect, noconstant(0)
   SET sbr_pds_package_int = cnvtint(sbr_pds_package_str)
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm2_install_schema)
   ENDIF
   CASE (dm2_val_file_prefix(sbr_pds_package_str))
    OF 0:
     IF ((dm_err->err_ind=1))
      SET dm_err->eproc = "Installation Failed. Error occurred when checking for DM2 schema files."
      CALL log_package_op(ocd_op->cur_op,ols_error,dm_err->eproc,sbr_pds_eid,sbr_pds_package_int)
      CALL end_status(dm_err->eproc,sbr_pds_eid,sbr_pds_package_int)
      RETURN(0)
     ENDIF
    OF 1:
     SET sbr_pds_return_val = 1
   ENDCASE
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(dm2_install_schema)
   ENDIF
   IF (sbr_pds_return_val=1)
    SET dm_err->eproc = "Removing existing schema files from CCLUSERDIR."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET sbr_pds_ois_cmd = concat("delete ",dm2_install_schema->ccluserdir,"dm2o",sbr_pds_package_str,
      "*.*;*")
     IF ((dm_err->debug_flag > 1))
      CALL echo(concat("sbr_pds_ois_cmd: ",sbr_pds_ois_cmd))
     ENDIF
     IF (dm2_push_dcl(sbr_pds_ois_cmd)=0)
      CALL log_package_op(ocd_op->cur_op,ols_error,concat(dm_err->eproc,dm_err->user_action),
       sbr_pds_eid,sbr_pds_package_int)
      CALL end_status(dm_err->eproc,sbr_pds_eid,sbr_pds_package_int)
      RETURN(0)
     ENDIF
    ELSE
     SET sbr_pds_ois_cmd = concat("rm -f ",dm2_install_schema->ccluserdir,"dm2o",sbr_pds_package_str,
      "*")
     IF ((dm_err->debug_flag > 1))
      CALL echo(concat("sbr_pds_ois_cmd: ",sbr_pds_ois_cmd))
     ENDIF
     IF (dm2_push_dcl(sbr_pds_ois_cmd)=0)
      CALL log_package_op(ocd_op->cur_op,ols_error,concat(dm_err->eproc,dm_err->user_action),
       sbr_pds_eid,sbr_pds_package_int)
      CALL end_status(dm_err->eproc,sbr_pds_eid,sbr_pds_package_int)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET sbr_pds_pkg_dir_hold = concat(substring(1,(findstring("]",cerocd) - 1),trim(cerocd)),trim(
      sbr_pds_package_str),"]")
   ELSE
    SET sbr_pds_pkg_dir_hold = concat(cerocd,"/",sbr_pds_package_str,"/")
   ENDIF
   SET sbr_pds_copy_ind = findfile(concat(sbr_pds_pkg_dir_hold,"dm2o",sbr_pds_package_str,"_h.dat"))
   IF ((dm_err->debug_flag > 1))
    CALL echo(concat(sbr_pds_pkg_dir_hold,"dm2o",sbr_pds_package_str,"_h.dat"))
    CALL echo("COPY Check for Schema Files in Cer_ocd.")
    CALL echo(sbr_pds_copy_ind)
   ENDIF
   IF (sbr_pds_copy_ind=1)
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET sbr_pds_ois_cmd = concat("copy ",sbr_pds_pkg_dir_hold,"dm2o*.* ",dm2_install_schema->
      ccluserdir)
     IF ((dm_err->debug_flag > 1))
      CALL echo(concat("sbr_pds_ois_cmd: ",sbr_pds_ois_cmd))
     ENDIF
     SET dm_err->eproc = "Copying files from CER_OCD to CCLUSERDIR."
     CALL disp_msg(" ",dm_err->logfile,0)
     IF (dm2_push_dcl(sbr_pds_ois_cmd)=0)
      CALL log_package_op(ocd_op->cur_op,ols_error,concat(dm_err->eproc,dm_err->user_action),
       sbr_pds_eid,sbr_pds_package_int)
      CALL end_status(dm_err->eproc,sbr_pds_eid,sbr_pds_package_int)
      RETURN(0)
     ENDIF
    ELSE
     SET sbr_pds_ois_cmd = concat("cp -f ",sbr_pds_pkg_dir_hold,"dm2o",sbr_pds_package_str,"*",
      " ",dm2_install_schema->ccluserdir)
     IF ((dm_err->debug_flag > 1))
      CALL echo(concat("sbr_pds_ois_cmd: ",sbr_pds_ois_cmd))
     ENDIF
     SET dm_err->eproc = "Copying files from CER_OCD to CCLUSERDIR."
     CALL disp_msg(" ",dm_err->logfile,0)
     IF (dm2_push_dcl(sbr_pds_ois_cmd)=0)
      CALL log_package_op(ocd_op->cur_op,ols_error,concat(dm_err->eproc,dm_err->user_action),
       sbr_pds_eid,sbr_pds_package_int)
      CALL end_status(dm_err->eproc,sbr_pds_eid,sbr_pds_package_int)
      RETURN(0)
     ENDIF
     SET sbr_pds_ois_cmd = concat("chmod 777 ",dm2_install_schema->ccluserdir,"dm2o",
      sbr_pds_package_str,"*")
     IF ((dm_err->debug_flag > 1))
      CALL echo(concat("sbr_pds_ois_cmd: ",sbr_pds_ois_cmd))
     ENDIF
     SET dm_err->eproc = "Changing permissions on DM2 schema files."
     CALL disp_msg(" ",dm_err->logfile,0)
     IF (dm2_push_dcl(sbr_pds_ois_cmd)=0)
      CALL log_package_op(ocd_op->cur_op,ols_error,concat(dm_err->eproc,dm_err->user_action),
       sbr_pds_eid,sbr_pds_package_int)
      CALL end_status(dm_err->eproc,sbr_pds_eid,sbr_pds_package_int)
      RETURN(0)
     ENDIF
    ENDIF
    SET sbr_pds_return_val = 1
   ELSE
    SET dm_err->eproc = concat("There is no Schema associated with package ",sbr_pds_package_str,".")
    CALL disp_msg(" ",dm_err->logfile,0)
    SET sbr_pds_return_val = 2
   ENDIF
   RETURN(sbr_pds_return_val)
 END ;Subroutine
 SUBROUTINE get_batch_list(sbr_gbl_plan_id)
   SET dm_err->eproc = build("Getting the list of packages in install plan <",sbr_gbl_plan_id,">.")
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    dip.package_number
    FROM dm_install_plan dip
    WHERE dip.install_plan_id=sbr_gbl_plan_id
    HEAD REPORT
     dipcnt = 0, stat = alterlist(batch_list->qual,100)
    DETAIL
     dipcnt = (dipcnt+ 1)
     IF (mod(dipcnt,100)=1
      AND dipcnt != 1)
      stat = alterlist(batch_list->qual,(dipcnt+ 99))
     ENDIF
     batch_list->qual[dipcnt].package_number = dip.package_number, batch_list->qual[dipcnt].
     load_method = - (1)
    FOOT REPORT
     batch_list->package_cnt = dipcnt, stat = alterlist(batch_list->qual,dipcnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(null)
   ENDIF
   IF ((batch_list->package_cnt=0))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = build("Installation Failed. No packages found for plan ID <",sbr_gbl_plan_id,
     ">.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(null)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(batch_list)
   ENDIF
 END ;Subroutine
 SUBROUTINE get_batch_list_readme(gbl_batch_id)
   SET dm_err->eproc = build("Getting the list of readmes for the packages in install plan <",
    gbl_batch_id,">.")
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_install_plan dip,
     dm_ocd_readme dor,
     dm_ocd_readme dor2,
     dm_readme dr
    WHERE (dip.install_plan_id=(gbl_batch_id * - (1)))
     AND dip.package_number=dor.ocd
     AND dor2.ocd=gbl_batch_id
     AND dor.readme_id=dor2.readme_id
     AND dor.instance=dor2.instance
     AND dr.readme_id=dor.readme_id
     AND dr.readme_id=dor2.readme_id
     AND dr.instance=dor.instance
     AND dr.instance=dor2.instance
     AND dr.owner=currdbuser
    ORDER BY dor.ocd, dor.readme_id
    HEAD dor.ocd
     bqual = 0, bqual = locateval(bqual,1,batch_list->package_cnt,dor.ocd,batch_list->qual[bqual].
      package_number), rmcnt = 0
    DETAIL
     IF (bqual > 0)
      rmcnt = (rmcnt+ 1)
      IF (mod(rmcnt,10)=1)
       stat = alterlist(batch_list->qual[bqual].rm_qual,(rmcnt+ 9))
      ENDIF
      batch_list->qual[bqual].rm_qual[rmcnt].readme_id = dor.readme_id, batch_list->qual[bqual].
      rm_qual[rmcnt].instance = dor.instance
      IF (dr.execution="PREDOWN")
       dip_predown_on_plan_ind = 1
      ELSEIF (dr.execution="POSTDOWN")
       dip_postdown_on_plan_ind = 1
      ENDIF
     ENDIF
    FOOT  dor.ocd
     IF (bqual > 0)
      stat = alterlist(batch_list->qual[bqual].rm_qual,rmcnt)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(null)
   ENDIF
   SET dm_err->eproc = "Finished getting the list of readmes."
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(batch_list)
   ENDIF
 END ;Subroutine
 SUBROUTINE load_batch_cclfiles(sbr_lbc_inst_mode,sbr_lbc_plan_str,sbr_lbc_eid)
   DECLARE sbr_lbc_plan_int = i4 WITH public, noconstant(0)
   DECLARE sbr_lbc_package_int = i4 WITH public, noconstant(0)
   DECLARE sbr_lbc_package_str = vc WITH public, noconstant("NONE")
   DECLARE sbr_lbc_item = i4 WITH public, noconstant(0)
   DECLARE sbr_lbc_lm_ind = i2 WITH protect, noconstant(0)
   SET sbr_lbc_plan_int = cnvtint(sbr_lbc_plan_str)
   SET ocd_op->pre_op = olo_none
   SET ocd_op->cur_op = olo_batchload_ccl_files
   SET dm_err->eproc = concat("Begin to batchload ccl files for batch ",sbr_lbc_plan_str)
   CALL start_status(dm_err->eproc,sbr_lbc_eid,sbr_lbc_plan_int)
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   IF (log_package_op(ocd_op->cur_op,ols_start,dm_err->eproc,sbr_lbc_eid,sbr_lbc_plan_int)=0)
    RETURN(null)
   ENDIF
   FOR (sbr_lbc_item = 1 TO batch_list->package_cnt)
     SET sbr_lbc_package_str = format(batch_list->qual[sbr_lbc_item].package_number,"######;P0")
     SET dm_err->eproc = concat("Beginning to batchload ccl file for package ",sbr_lbc_package_str,
      ".")
     CALL end_status(dm_err->eproc,sbr_lbc_eid,sbr_lbc_plan_int)
     IF ((dm_err->err_ind=1))
      RETURN(null)
     ENDIF
     IF (log_package_op(olo_batchload_ccl_files,ols_running,dm_err->eproc,sbr_lbc_eid,
      sbr_lbc_plan_int)=0)
      RETURN(null)
     ENDIF
     SET dm_err->eproc = concat(
      "Inserting or updating log information in DM_ALPHA_FEATURES_ENV for package ",
      sbr_lbc_package_str,".")
     SELECT INTO "nl:"
      FROM dm_alpha_features_env defa
      WHERE defa.environment_id=sbr_lbc_eid
       AND (defa.alpha_feature_nbr=batch_list->qual[sbr_lbc_item].package_number)
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL end_status(dm_err->eproc,sbr_lbc_eid,sbr_lbc_plan_int)
      CALL log_package_op(olo_batchload_ccl_files,ols_error,dm_err->emsg,sbr_lbc_eid,sbr_lbc_plan_int
       )
      CALL log_package_op(olo_load_ccl_file,ols_error,dm_err->emsg,sbr_lbc_eid,sbr_lbc_plan_int)
      RETURN(null)
     ENDIF
     IF (curqual=0)
      INSERT  FROM dm_alpha_features_env defa
       SET defa.status = "Begin installation.", defa.start_dt_tm = cnvtdatetime(curdate,curtime3),
        defa.end_dt_tm = null,
        defa.environment_id = sbr_lbc_eid, defa.alpha_feature_nbr = batch_list->qual[sbr_lbc_item].
        package_number, defa.inst_mode = sbr_lbc_inst_mode,
        defa.calling_script = "DM2_INSTALL_PKG", defa.curr_migration_ind = 0
       WITH nocounter
      ;end insert
      IF (check_error(dm_err->eproc)=1)
       CALL end_status(dm_err->eproc,sbr_lbc_eid,sbr_lbc_plan_int)
       CALL log_package_op(olo_batchload_ccl_files,ols_error,dm_err->emsg,sbr_lbc_eid,
        sbr_lbc_plan_int)
       CALL log_package_op(olo_load_ccl_file,ols_error,dm_err->emsg,sbr_lbc_eid,sbr_lbc_plan_int)
       RETURN(null)
      ENDIF
     ELSE
      UPDATE  FROM dm_alpha_features_env defa
       SET defa.status = "Begin installation.", defa.start_dt_tm = cnvtdatetime(curdate,curtime3),
        defa.end_dt_tm = null,
        defa.inst_mode = sbr_lbc_inst_mode, defa.calling_script = "DM2_INSTALL_PKG"
       WHERE defa.environment_id=sbr_lbc_eid
        AND (defa.alpha_feature_nbr=batch_list->qual[sbr_lbc_item].package_number)
       WITH nocounter
      ;end update
      IF (check_error(dm_err->eproc)=1)
       CALL end_status(dm_err->eproc,sbr_lbc_eid,sbr_lbc_plan_int)
       CALL log_package_op(olo_batchload_ccl_files,ols_error,dm_err->emsg,sbr_lbc_eid,
        sbr_lbc_plan_int)
       CALL log_package_op(olo_load_ccl_file,ols_error,dm_err->emsg,sbr_lbc_eid,sbr_lbc_plan_int)
       RETURN(null)
      ENDIF
     ENDIF
     SET sbr_lbc_lm_ind = - (1)
     CALL check_ccl_file(sbr_lbc_inst_mode,sbr_lbc_eid,sbr_lbc_package_str,sbr_lbc_lm_ind)
     IF (check_error(dm_err->eproc)=1)
      CALL end_status(dm_err->eproc,sbr_lbc_eid,sbr_lbc_plan_int)
      CALL log_package_op(olo_batchload_ccl_files,ols_error,dm_err->eproc,sbr_lbc_eid,
       sbr_lbc_plan_int)
      CALL log_package_op(olo_load_ccl_file,ols_error,dm_err->emsg,sbr_lbc_eid,sbr_lbc_plan_int)
      RETURN(null)
     ENDIF
     SET batch_list->qual[sbr_lbc_item].load_method = sbr_lbc_lm_ind
   ENDFOR
   IF ((dir_ui_misc->auto_install_ind=1)
    AND dip_package_list_cnt > 0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Failing installation due to older archive date version than admin: ",
     dip_package_list)
    CALL end_status(dm_err->emsg,sbr_lbc_eid,sbr_lbc_plan_int)
    CALL log_package_op(olo_batchload_ccl_files,ols_error,dm_err->emsg,sbr_lbc_eid,sbr_lbc_plan_int)
    CALL log_package_op(olo_load_ccl_file,ols_error,dm_err->emsg,sbr_lbc_eid,sbr_lbc_plan_int)
    RETURN(null)
   ENDIF
   IF (dip_ccl_load_ind=1)
    SET dm_err->eproc = "Batchload CCL files successfully."
    CALL end_status(dm_err->eproc,sbr_lbc_eid,sbr_lbc_plan_int)
    IF (log_package_op(olo_batchload_ccl_files,ols_complete,dm_err->eproc,sbr_lbc_eid,
     sbr_lbc_plan_int)=0)
     RETURN(null)
    ENDIF
    IF (log_package_op(olo_load_ccl_file,ols_complete,dm_err->eproc,sbr_lbc_eid,sbr_lbc_plan_int)=0)
     RETURN(null)
    ENDIF
    SET dm_err->eproc = build(
     "insert or update the list of Millennium Sequences in DM_INFO from DM_COLUMNS_DOC")
    CALL disp_msg(" ",dm_err->logfile,0)
    MERGE INTO dm_info di
    USING (SELECT DISTINCT
     sequence_name = cnvtupper(sequence_name)
     FROM dm_columns_doc
     WHERE sequence_name > " ")
    SN ON (sn.sequence_name=di.info_name
     AND di.info_domain="DM2_MILLENNIUM_SEQUENCE")
    WHEN MATCHED THEN
    (UPDATE
     SET di.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE 1=1
    ;end update
    )
    WHEN NOT MATCHED THEN
    (INSERT  FROM di
     (di.info_domain, di.info_name)
     VALUES("DM2_MILLENNIUM_SEQUENCE", sn.sequence_name)
    ;end insert
    )
    WITH nocounter
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL end_status(dm_err->eproc,sbr_lbc_eid,sbr_lbc_plan_int)
     CALL log_package_op(olo_batchload_ccl_files,ols_error,dm_err->emsg,sbr_lbc_eid,sbr_lbc_plan_int)
     CALL log_package_op(olo_load_ccl_file,ols_error,dm_err->emsg,sbr_lbc_eid,sbr_lbc_plan_int)
     RETURN(null)
    ELSE
     COMMIT
    ENDIF
   ELSE
    SET dm_err->eproc = "Package schema file does not need to be loaded."
    CALL end_status(dm_err->eproc,sbr_lbc_eid,sbr_lbc_plan_int)
    IF (check_package_op(olo_load_ccl_file,sbr_lbc_plan_int,sbr_lbc_eid)=0)
     IF (log_package_op(olo_load_ccl_file,ols_complete,dm_err->eproc,sbr_lbc_eid,sbr_lbc_plan_int)=0)
      RETURN(null)
     ENDIF
    ENDIF
    IF (log_package_op(olo_batchload_ccl_files,ols_complete,dm_err->eproc,sbr_lbc_eid,
     sbr_lbc_plan_int)=0)
     RETURN(null)
    ENDIF
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE load_batch_package_schema(sbr_lbps_inst_mode,sbr_lbps_plan_str,sbr_lbps_eid)
   DECLARE sbr_lbps_plan_int = i4 WITH public, noconstant(0)
   DECLARE sbr_lbps_package_int = i4 WITH public, noconstant(0)
   DECLARE sbr_lbps_package_str = vc WITH public, noconstant("NONE")
   DECLARE sbr_lbps_schema_ind = i2 WITH public, noconstant(0)
   DECLARE sbr_lbps_b_item = i4 WITH public, noconstant(0)
   SET sbr_lbps_plan_int = cnvtint(sbr_lbps_plan_str)
   CALL load_batch_cclfiles(sbr_lbps_inst_mode,sbr_lbps_plan_str,sbr_lbps_eid)
   IF ((dm_err->err_ind > 0))
    RETURN(null)
   ENDIF
   SET ocd_op->pre_op = olo_none
   SET ocd_op->cur_op = olo_load_ccl_file
   FOR (sbr_lbps_b_item = 1 TO batch_list->package_cnt)
     IF ((batch_list->qual[sbr_lbps_b_item].load_method=0))
      SET sbr_lbps_package_str = format(batch_list->qual[sbr_lbps_b_item].package_number,"######;P0")
      SET sbr_lbps_schema_ind = prep_dm2_schema(sbr_lbps_eid,sbr_lbps_package_str)
      IF (sbr_lbps_schema_ind=0)
       RETURN(null)
      ENDIF
      IF (sbr_lbps_schema_ind=1)
       IF ((dm_err->debug_flag > 1))
        CALL echo("Before translate load.")
        CALL trace(7)
       ENDIF
       EXECUTE dm2_translate_load "LOAD"
       IF ((dm_err->debug_flag > 1))
        CALL echo("After translate load.")
        CALL trace(7)
       ENDIF
       IF ((dm_err->err_ind=1))
        SET dm_err->eproc = "Installation Failed. Error executing DM2_TRANSLATE_LOAD."
        CALL log_package_op(ocd_op->cur_op,ols_error,dm_err->eproc,sbr_lbps_eid,sbr_lbps_plan_int)
        RETURN(null)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   IF (check_error("Installation Failed. Error writing to DM_OCD_LOG.")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(null)
   ENDIF
   SET dm_err->eproc = "Schema files for packages in the Install Plan loaded successfully."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_alpha_features_env defa
    WHERE defa.environment_id=sbr_lbps_eid
     AND defa.alpha_feature_nbr=sbr_lbps_plan_int
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL end_status(dm_err->eproc,sbr_lbps_eid,sbr_lbps_plan_int)
    CALL log_package_op(ocd_op->cur_op,ols_error,dm_err->emsg,sbr_lbps_eid,sbr_lbps_plan_int)
    RETURN(null)
   ENDIF
   IF (curqual=0)
    INSERT  FROM dm_alpha_features_env defa
     SET defa.status = "Begin installation.", defa.start_dt_tm = cnvtdatetime(curdate,curtime3), defa
      .end_dt_tm = null,
      defa.environment_id = sbr_lbps_eid, defa.alpha_feature_nbr = sbr_lbps_plan_int, defa.inst_mode
       = sbr_lbps_inst_mode,
      defa.calling_script = "DM2_INSTALL_PKG", defa.curr_migration_ind = 0
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL end_status(dm_err->eproc,sbr_lbps_eid,sbr_lbps_plan_int)
     CALL log_package_op(ocd_op->cur_op,ols_error,dm_err->emsg,sbr_lbps_eid,sbr_lbps_plan_int)
     RETURN(null)
    ENDIF
    IF (curqual=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Failed to insert a row in DM_ALPHA_FEATURES_ENV."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(null)
    ENDIF
   ELSE
    UPDATE  FROM dm_alpha_features_env defa
     SET defa.status = "Begin installation.", defa.start_dt_tm = cnvtdatetime(curdate,curtime3), defa
      .end_dt_tm = null,
      defa.inst_mode = sbr_lbps_inst_mode, defa.calling_script = "DM2_INSTALL_PKG"
     WHERE defa.environment_id=sbr_lbps_eid
      AND defa.alpha_feature_nbr=sbr_lbps_plan_int
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     CALL end_status(dm_err->eproc,sbr_lbps_eid,sbr_lbps_plan_int)
     CALL log_package_op(ocd_op->cur_op,ols_error,dm_err->emsg,sbr_lbps_eid,sbr_lbps_plan_int)
     RETURN(null)
    ENDIF
    IF (curqual=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Failed to update a row in DM_ALPHA_FEATURES_ENV."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(null)
    ENDIF
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    ROLLBACK
    RETURN(null)
   ELSE
    COMMIT
   ENDIF
   FREE SET sbr_lbps_plan_int
   FREE SET sbr_lbps_package_int
   FREE SET sbr_lbps_package_str
   FREE SET sbr_lbps_schema_ind
   FREE SET sbr_lbps_b_item
   IF ((dm_err->debug_flag > 1))
    CALL echo("End load batch package schema.")
    CALL trace(7)
   ENDIF
 END ;Subroutine
 SUBROUTINE create_batch_schema(sbr_cbs_eid,sbr_cbs_package_int)
   EXECUTE dm2_get_batch_components value(abs(sbr_cbs_package_int))
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE populate_batch_readme_log(sbr_pbrl_eid,sbr_pbrl_pkg_int)
   DECLARE pbrl_readme = vc WITH public, constant("README")
   DECLARE pbrl_done = vc WITH public, constant("SUCCESS")
   DECLARE sbr_pbrl_rm_msg = vc WITH public, constant(
    "This readme was automatically marked successful as part of a batch installation.")
   DECLARE sbr_pbrl_pkg_cnt = i4 WITH public, noconstant(0)
   DECLARE sbr_pbrl_rm_cnt = i4 WITH public, noconstant(0)
   DECLARE sbr_pbrl_lr_found = i2 WITH public, noconstant(0)
   DECLARE sbr_pbrl_rm_found = i2 WITH public, noconstant(0)
   DECLARE sbr_pbrl_rm_batch_dt_tm = dq8 WITH public
   FOR (sbr_pbrl_pkg_cnt = 1 TO batch_list->package_cnt)
     FOR (sbr_pbrl_rm_cnt = 1 TO size(batch_list->qual[sbr_pbrl_pkg_cnt].rm_qual,5))
       SET sbr_pbrl_lr_found = 0
       SET sbr_pbrl_rm_found = 0
       SELECT INTO "nl:"
        "x"
        FROM dm_ocd_log dol
        WHERE dol.project_type=pbrl_readme
         AND dol.project_name=cnvtstring(batch_list->qual[sbr_pbrl_pkg_cnt].rm_qual[sbr_pbrl_rm_cnt].
         readme_id)
         AND dol.environment_id=sbr_pbrl_eid
         AND dol.ocd=sbr_pbrl_pkg_int
         AND dol.status=pbrl_done
        DETAIL
         sbr_pbrl_rm_found = 1, sbr_pbrl_rm_batch_dt_tm = dol.batch_dt_tm
        WITH nocounter
       ;end select
       IF (check_error("Installation Failed. Error while looking for successful readmes.")=1)
        CALL end_status(dm_err->eproc,sbr_pbrl_eid,sbr_pbrl_pkg_int)
        RETURN(null)
       ENDIF
       SET dm_err->eproc = "Inserting or updating in the readme log for packages in the plan."
       IF (sbr_pbrl_rm_found)
        UPDATE  FROM dm_ocd_log l
         SET l.status = pbrl_done, l.start_dt_tm = cnvtdatetime(curdate,curtime3), l.end_dt_tm =
          cnvtdatetime(curdate,curtime3),
          l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.message = sbr_pbrl_rm_msg, l.batch_dt_tm
           = cnvtdatetime(sbr_pbrl_rm_batch_dt_tm),
          l.active_ind = 1
         WHERE l.environment_id=sbr_pbrl_eid
          AND l.project_type=pbrl_readme
          AND (l.ocd=batch_list->qual[sbr_pbrl_pkg_cnt].package_number)
          AND l.project_name=cnvtstring(batch_list->qual[sbr_pbrl_pkg_cnt].rm_qual[sbr_pbrl_rm_cnt].
          readme_id)
          AND (l.project_instance=batch_list->qual[sbr_pbrl_pkg_cnt].rm_qual[sbr_pbrl_rm_cnt].
         instance)
         WITH nocounter
        ;end update
        IF (curqual=0)
         INSERT  FROM dm_ocd_log l
          SET l.status = pbrl_done, l.start_dt_tm = cnvtdatetime(curdate,curtime3), l.end_dt_tm =
           cnvtdatetime(curdate,curtime3),
           l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.message = sbr_pbrl_rm_msg, l.project_type
            = pbrl_readme,
           l.project_name = cnvtstring(batch_list->qual[sbr_pbrl_pkg_cnt].rm_qual[sbr_pbrl_rm_cnt].
            readme_id), l.environment_id = sbr_pbrl_eid, l.project_instance = batch_list->qual[
           sbr_pbrl_pkg_cnt].rm_qual[sbr_pbrl_rm_cnt].instance,
           l.ocd = batch_list->qual[sbr_pbrl_pkg_cnt].package_number, l.batch_dt_tm = cnvtdatetime(
            sbr_pbrl_rm_batch_dt_tm), l.active_ind = 1
          WITH nocounter
         ;end insert
         IF (curqual=0)
          SET dm_err->err_ind = 1
          SET dm_err->emsg = "Failed to insert a log row in DM_OCD_LOG table."
          CALL end_status(dm_err->eproc,sbr_pbrl_eid,sbr_pbrl_pkg_int)
          RETURN(null)
         ENDIF
        ENDIF
        IF (check_error(
         "Installation Failed. Error while logging successful readmes for packages in the plan.")=1)
         CALL end_status(dm_err->eproc,sbr_pbrl_eid,sbr_pbrl_pkg_int)
         RETURN(null)
        ENDIF
        SET dm_err->eproc = "Verifying readme log row for packages in the plan."
        SELECT INTO "nl:"
         "x"
         FROM dm_ocd_log do
         WHERE do.environment_id=sbr_pbrl_eid
          AND do.project_type=pbrl_readme
          AND (do.ocd=batch_list->qual[sbr_pbrl_pkg_cnt].package_number)
          AND do.project_name=cnvtstring(batch_list->qual[sbr_pbrl_pkg_cnt].rm_qual[sbr_pbrl_rm_cnt].
          readme_id)
          AND do.status=pbrl_done
          AND (do.project_instance=batch_list->qual[sbr_pbrl_pkg_cnt].rm_qual[sbr_pbrl_rm_cnt].
         instance)
         DETAIL
          sbr_pbrl_lr_found = 1
         WITH nocounter
        ;end select
        IF ( NOT (sbr_pbrl_lr_found))
         SET dm_err->err_ind = 1
         SET dm_err->emsg = "Installation Failed. Readme log row could not be confirmed."
         CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
         RETURN(null)
        ENDIF
        IF (check_error("Installation Failed. Error while verifying log rows for successful readmes."
         )=1)
         CALL end_status(dm_err->eproc,sbr_pbrl_eid,sbr_pbrl_pkg_int)
         RETURN(null)
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE populate_batch_install_log(sbr_pbil_op,sbr_pbil_eid,sbr_pbil_plan_id)
   DECLARE sbr_pbil_msg = vc WITH public, noconstant("NOT_SET")
   IF (sbr_pbil_op IN (olo_code_sets, olo_atrs)
    AND currdbuser != "V500")
    IF ((dm_err->debug_flag > 1))
     CALL echo(concat("Bypass writing to install log for ",trim(sbr_pbil_op),
       " operation - current user not V500."))
    ENDIF
    RETURN(null)
   ENDIF
   CASE (sbr_pbil_op)
    OF olo_load_ccl_file:
     SET sbr_pbil_msg = "Loading of OCD schema ccl file successful"
    OF olo_readme_report:
     SET sbr_pbil_msg = "Finished displaying README estimate report"
    OF olo_code_sets:
     SET sbr_pbil_msg = "Code sets installation successful"
    OF olo_pre_uts:
     SET sbr_pbil_msg = "Finished executing all Pre-UTS Readmes steps"
    OF olo_uptime_schema:
     SET sbr_pbil_msg = "UPTIME mode complete."
    OF olo_atrs:
     SET sbr_pbil_msg = "Installing ATRs successful!"
    OF olo_post_uts:
     SET sbr_pbil_msg = "Finished executing all Post-UTS Readmes steps"
    OF olo_pre_cycle:
     SET sbr_pbil_msg = "Finished executing all Pre-Cycle Readmes steps"
    OF olo_pre_dts:
     SET sbr_pbil_msg = "Finished executing all Pre-DTS Readmes steps"
    OF olo_downtime_schema:
     SET sbr_pbil_msg = "DOWNTIME mode complete."
    OF olo_post_dts:
     SET sbr_pbil_msg = "Finished executing all Post-DTS Readmes steps"
    OF olo_post_inst:
     SET sbr_pbil_msg = "Finished executing all Post-INST Readmes steps"
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "populate_batch_install_log subroutine: Validating operation."
     SET dm_err->emsg = "Installation Failed. Unknown operation specified for batch logging."
     CALL end_status(dm_err->eproc,sbr_pbil_eid,sbr_pbil_plan_id)
     RETURN(null)
   ENDCASE
   FOR (p_item = 1 TO size(batch_list->qual,5))
     CALL log_package_op(sbr_pbil_op,ols_complete,sbr_pbil_msg,sbr_pbil_eid,batch_list->qual[p_item].
      package_number)
     IF ((dm_err->err_ind=1))
      RETURN(null)
     ENDIF
     IF (((p_item=1) OR ((dm_err->debug_flag > 1))) )
      CALL end_status(sbr_pbil_msg,sbr_pbil_eid,batch_list->qual[p_item].package_number)
      IF ((dm_err->err_ind=1))
       RETURN(null)
      ENDIF
     ENDIF
   ENDFOR
   IF (check_error("Installation Failed. Error while writing to the install log.")=1)
    CALL end_status(dm_err->eproc,sbr_pbil_eid,sbr_pbil_plan_id)
    RETURN(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE validate_load(sbr_vl_package_int)
   IF ((dm2_install_pkg->process_option="SINGLEPKG"))
    SET dm_err->eproc = "Verifying that Package has been loaded."
   ELSE
    SET dm_err->eproc = "Verifying that Packages in the Plan have been loaded."
   ENDIF
   SELECT INTO "nl:"
    FROM dm_alpha_features daf
    WHERE daf.alpha_feature_nbr=sbr_vl_package_int
     AND daf.owner=currdbuser
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    IF ((dm2_install_pkg->process_option="SINGLEPKG"))
     SET dm_err->eproc = "Package has not been loaded."
    ELSE
     SET dm_err->eproc = "Packages have not been loaded."
    ENDIF
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dm_err->err_ind = 0
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE upd_dm_ocd_log(null)
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_alpha_features_env d
    WHERE d.environment_id=dip_env_id
     AND d.alpha_feature_nbr=10292
    WITH nocounter
   ;end select
   IF (check_error("Check if 10292 exists on dm_alpha_features_env.") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SELECT INTO "nl:"
     FROM dm_ocd_log dol
     WHERE dol.environment_id=dip_env_id
      AND dol.project_type="INSTALL LOG"
      AND dol.project_name="POST-INST READMES"
      AND dol.ocd=10292
     WITH nocounter
    ;end select
    IF (check_error("Check if 10292 exists on dm_ocd_log.") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     INSERT  FROM dm_ocd_log
      SET environment_id = dip_env_id, project_type = "INSTALL LOG", project_name =
       "POST-INST READMES",
       ocd = 10292, status = "COMPLETE", message = "INSERT DUMMY ROW",
       active_ind = 1, batch_dt_tm = cnvtdatetime(curdate,curtime3), updt_dt_tm = cnvtdatetime(
        curdate,curtime3)
      WITH nocounter
     ;end insert
     IF (check_error("Insert dummy row for  10292 to dm_ocd_log.") != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
    ELSE
     UPDATE  FROM dm_ocd_log
      SET status = "COMPLETE", message = "UPDATE DUMMY ROW", updt_dt_tm = cnvtdatetime(curdate,
        curtime3)
      WHERE environment_id=dip_env_id
       AND project_type="INSTALL LOG"
       AND project_name="POST-INST READMES"
       AND ocd=10292
       AND status != "COMPLETE"
      WITH nocounter
     ;end update
     IF (check_error("Update dummy row for  10292 to dm_ocd_log.") != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
    ENDIF
    COMMIT
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE silmode_prompt(sp_user_choice,sp_env_id,sp_package_int,sp_install_mode)
   DECLARE sp_promptoptionselected = vc WITH protect, noconstant("")
   DECLARE sp_preview_ind = i2 WITH protect, noconstant(0)
   DECLARE sp_rspchk_ind = i2 WITH protect, noconstant(0)
   DECLARE sp_readme_msg = vc WITH protect, noconstant("")
   DECLARE sp_rspchk_warning = i2 WITH protect, noconstant(0)
   IF ( NOT (sp_install_mode IN ("UPTIME", "DOWNTIME", "POSTINST", "EXPRESS", "BATCHUP",
   "BATCHPRECYCLE", "BATCHDOWN", "BATCHPOST", "BATCHEXPRESS", "MANUAL")))
    SET sp_user_choice = 0
    RETURN(1)
   ENDIF
   IF (check_dol_row(sp_env_id,olpt_install_info,olo_preview_complete,1,sp_package_int,
    ols_complete,sp_preview_ind)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echo(build("sp_preview_ind:",sp_preview_ind))
   ENDIF
   IF (sp_preview_ind=1)
    SELECT INTO "nl:"
     FROM dm_ocd_log d
     WHERE d.environment_id=sp_env_id
      AND d.project_type=cnvtupper(olpt_install_plan)
      AND d.project_name=cnvtupper(olo_readme_spchk)
      AND d.project_instance=1
      AND d.ocd=sp_package_int
      AND d.status=ols_complete
     DETAIL
      sp_readme_msg = d.message
     WITH nocounter
    ;end select
    IF (check_error("Verifying dm_ocd_log readme space check row exists.")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ELSEIF (curqual > 0)
     SET sp_rspchk_ind = 1
    ENDIF
    IF (sp_rspchk_ind=1)
     IF (sp_install_mode IN ("UPTIME", "BATCHUP", "EXPRESS", "BATCHEXPRESS", "MANUAL"))
      SET sp_rspchk_warning = 1
     ELSEIF (sp_install_mode IN ("DOWNTIME", "BATCHDOWN"))
      IF (((findstring("<PREDOWN>",sp_readme_msg,1,0) > 0) OR (((findstring("<POSTDOWN>",
       sp_readme_msg,1,0) > 0) OR (findstring("<UP>",sp_readme_msg,1,0) > 0)) )) )
       SET sp_rspchk_warning = 1
      ENDIF
     ELSEIF (sp_install_mode IN ("POSTINST", "BATCHPOST"))
      IF (findstring("<UP>",sp_readme_msg,1,0) > 0)
       SET sp_rspchk_warning = 1
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   SET message = window
   SET width = 132
   CALL clear(1,1)
   SET drc_row = 1
   CALL text(1,2,"SILENT MODE SELECTION PROMPT")
   CALL text(5,2,"Execute in Silent Mode? (Y/N): ")
   CALL text(7,2,
    "Silent Mode suppresses reports and warning prompts until the installation is complete.")
   IF ((drr_flex_sched->status=0))
    CALL text(9,2,
     "For parallel processing, additional install runners should be started at this time.  To start")
    CALL text(10,2,"an install runner, open up a new session and execute the following in CCL.")
    CALL text(11,2,"")
    CALL text(12,8,"ccl> dm2_install_runner go")
    IF (sp_preview_ind=0)
     CALL text(14,2,concat(
       "Warning: Preview Mode has not been run for this Install.  It is possible ",
       "that Tablespace needs may exist due to schema changes"))
     CALL text(15,2,concat("or readmes with space check scripts.  If tablespace needs exist,",
       " the Installation process will pause for Tablespace maintenance."))
    ELSEIF (sp_rspchk_warning=1)
     CALL text(14,2,concat(
       "Warning: Readmes found with tablespace checks during PREVIEW mode.  It is possible",
       " that Tablespace needs may exist due to"))
     CALL text(15,2,concat("additional readme spaceneeds.  If tablespace needs exist, ",
       "the Installation process will pause for Tablespace maintenance."))
    ENDIF
   ELSE
    IF (sp_preview_ind=0)
     CALL text(9,2,concat("Warning: Preview Mode has not been run for this Install.  It is possible ",
       "that Tablespace needs may exist due to schema changes"))
     CALL text(10,2,concat("or readmes with space check scripts.  If tablespace needs exist,",
       " the Installation process will pause for Tablespace maintenance."))
    ELSEIF (sp_rspchk_warning=1)
     CALL text(9,2,concat("Warning: Readmes found with tablespace checks.  It is possible ",
       "that Tablespace needs may exist due to"))
     CALL text(10,2,concat("additional readme spaceneeds.  If tablespace needs exist, ",
       "the Installation process will pause for Tablespace maintenance."))
    ENDIF
   ENDIF
   CALL accept(5,35,"p;cu"," "
    WHERE curaccept IN ("Y", "N"))
   SET sp_promptoptionselected = curaccept
   CASE (sp_promptoptionselected)
    OF "Y":
     SET sp_user_choice = 1
     SET dm_err->eproc = "Silent Mode Prompt User Selection:  Y"
    ELSE
     SET dm_err->eproc = "Silent Mode Prompt User Selection:  N"
     SET sp_user_choice = 0
   ENDCASE
   CALL disp_msg("",dm_err->logfile,0)
   SET message = nowindow
   RETURN(1)
 END ;Subroutine
 SUBROUTINE silmode_summary(ss_message,ss_environment_id,ss_package_int,ss_logfile_prefix)
   DECLARE ss_filename = vc WITH protect, noconstant(" ")
   SET ss_filename = concat(ss_logfile_prefix,"silmodesum.log")
   SELECT INTO value(ss_filename)
    FROM dual
    DETAIL
     row + 1, col 1, ss_message,
     row + 1, row + 1, col 1,
     "The following Reports/Prompts were bypassed:", row + 1, row + 1,
     col 1, "Report/Prompt Name                             File Name in CCLUSERDIR", row + 1,
     col 1, "-----------------------------------------      ----------------------------------------"
     IF ((dir_silmode->cnt > 0))
      FOR (essidx = 1 TO dir_silmode->cnt)
        row + 1, col 1, dir_silmode->qual[essidx].name,
        col 48, dir_silmode->qual[essidx].filename
      ENDFOR
     ELSE
      row + 1, col 1, "No reports or prompts were bypassed."
     ENDIF
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   IF (check_error("Generating Silent Mode Installation Summary File")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dir_ui_misc->dm_process_event_id > 0))
    IF (drr_assign_file_to_installs("RPT:SILENT MODE SUMMARY",ss_filename,dir_ui_misc->
     dm_process_event_id)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_ui_misc->background_ind=0))
    IF (dm2_disp_file(ss_filename,concat("Silent Mode Summary Report (",ss_filename,")"))=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dip_load_target(dlt_install_mode,dlt_eid,dlt_package_str)
   SET dm_err->eproc = "Loading target record through dm2_translate_load..."
   CALL disp_msg("",dm_err->logfile,0)
   DECLARE dlt_schema_ind = i2 WITH protect, noconstant(0)
   DECLARE dlt_package_int = i4 WITH protect, noconstant(0)
   SET dlt_package_int = cnvtint(dlt_package_str)
   IF ((dm2_install_pkg->process_option="SINGLEPKG"))
    SET dlt_schema_ind = prep_dm2_schema(dlt_eid,dlt_package_str)
    IF (dlt_schema_ind=1)
     EXECUTE dm2_translate_load "LOAD"
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
     EXECUTE dm2_translate_load "PKGINSTALL"
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ENDIF
   ELSE
    SET dm2_install_schema->schema_prefix = "dm2o"
    SET dm2_install_schema->file_prefix = dlt_package_str
    SELECT INTO "nl:"
     dat.table_name
     FROM dm_afd_tables dat
     WHERE dat.alpha_feature_nbr=dlt_package_int
      AND dat.owner=currdbuser
     WITH nocounter
    ;end select
    IF (check_error("Installation Failed. Error while checking for package schema.")=1)
     CALL end_status(dm_err->eproc,dlt_eid,dlt_package_int)
     RETURN(null)
    ENDIF
    IF (curqual >= 1)
     EXECUTE dm2_translate_load "PKGINSTALL"
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dip_process_readme_spc_needs(dpr_install_mode,dpr_eid,dpr_package_int,dpr_readme_chk_mode
  )
   IF ((dm2_rr_misc->dm2_toolset_usage="N"))
    SET dm_err->eproc = "DM Readme Tools in Use: Bypassing readme spacecheck."
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   SET dm_err->eproc = concat("Process readme space needs for install mode ",dpr_install_mode," ",
    " in readme space check mode ",dpr_readme_chk_mode)
   CALL disp_msg("",dm_err->logfile,0)
   DECLARE dpr_exec_get_cursch = i2 WITH protect, noconstant(1)
   DECLARE dpr_orig_diff_ind = i2 WITH protect, noconstant(0)
   IF (currdb != "ORACLE")
    SET dm_err->eproc = "Database is not ORACLE.  Do not process readme space needs."
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   IF ((dm2_db_options->readme_space_calc="N"))
    SET dm_err->eproc = "Readme Space Calculation is off."
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   IF (dpr_install_mode IN ("UPTIME", "BATCHUP", "EXPRESS", "BATCHEXPRESS")
    AND  NOT (dpr_readme_chk_mode IN ("PRESPCHK", "POSTSPCHK")))
    SET dm_err->emsg = concat("Readme space check mode ",dpr_readme_chk_mode,
     " is invalid for install mode ",dpr_install_mode)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dpr_install_mode IN ("DOWNTIME", "BATCHDOWN", "POSTINST", "BATCHPOST")
    AND dpr_readme_chk_mode != "POSTSPCHK")
    SET dm_err->emsg = concat("Readme space check mode ",dpr_readme_chk_mode,
     " is invalid for install mode ",dpr_install_mode)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   EXECUTE dm2_readme_space_check dpr_package_int, dpr_install_mode, dpr_readme_chk_mode
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF ((dm2_rr_spcchk->space_needed=0))
    SET dm_err->eproc = "No readme space needs found."
    IF ((dm_err->debug_flag > 1))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    RETURN(1)
   ENDIF
   IF (dpr_install_mode IN ("UPTIME", "BATCHUP", "EXPRESS", "BATCHEXPRESS")
    AND dpr_readme_chk_mode="POSTSPCHK")
    IF ((tgtsch->diff_ind=1))
     SET tgtsch->diff_ind = 0
     SET dpr_orig_diff_ind = 1
    ENDIF
    IF ((cur_sch->tbl_cnt > 0))
     SET dpr_exec_get_cursch = 0
    ENDIF
   ENDIF
   IF (dpr_exec_get_cursch=1)
    SET dm2_install_schema->curprog = "DM2_INSTALL_PKG"
    EXECUTE dm2_get_cursch "*"
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   EXECUTE dm2_tspace_driver
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET tgtsch->diff_ind = dpr_orig_diff_ind
   SET dm2_rr_spcchk->space_needed = 0
   SET dm2_rr_spc_needs->space_needed = 0
   IF (dpr_readme_chk_mode="POSTSPCHK")
    FREE RECORD tgtsch
    FREE RECORD cur_sch
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE populate_batch_install_log2(pbil2_op,pbil2_eid,pbil2_plan_id,pbil2_msg)
   FOR (p_item = 1 TO size(batch_list->qual,5))
     CALL log_package_op(pbil2_op,ols_complete,pbil2_msg,pbil2_eid,batch_list->qual[p_item].
      package_number)
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
     CALL end_status(pbil2_msg,pbil2_eid,batch_list->qual[p_item].package_number)
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
   ENDFOR
   IF (check_error("Installation Failed. Error while writing to the install log.")=1)
    CALL end_status(dm_err->eproc,sbr_pbil_eid,sbr_pbil_plan_id)
    RETURN(null)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE autosuccess_downtime_ops(ado_env_id,ado_pkg_int)
   IF (check_package_op(olo_post_uts,ado_pkg_int,ado_env_id)=0)
    SET dm_err->err_ind = 1
    CALL end_status(build("Cannot auto-success downtime operations for No-Downtime plan <",
      ado_pkg_int,"> until ",olo_post_uts," operation is complete. Install FAILED."),ado_env_id,
     ado_pkg_int)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Downtime Readme Estimate Report auto-successed due to No-Downtime Plan"
   IF (log_package_op(olo_readme_report,ols_complete,dm_err->eproc,ado_env_id,ado_pkg_int)=0)
    RETURN(0)
   ENDIF
   CALL end_status(dm_err->eproc,ado_env_id,ado_pkg_int)
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET dm_err->eproc = build(
    "Downtime Readme Estimate Report auto-successed due to No-Downtime Plan <",ado_pkg_int,">")
   IF (populate_batch_install_log2(olo_readme_report,ado_env_id,ado_pkg_int,dm_err->eproc)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "PRE-DTS Readme process auto-successed due to No-Downtime Plan"
   IF (log_package_op(olo_pre_dts,ols_complete,dm_err->eproc,ado_env_id,ado_pkg_int)=0)
    RETURN(0)
   ENDIF
   CALL end_status(dm_err->eproc,ado_env_id,ado_pkg_int)
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET dm_err->eproc = build("PRE-DTS Readme process auto-successed due to No-Downtime Plan  <",
    ado_pkg_int,">")
   IF (populate_batch_install_log2(olo_pre_dts,ado_env_id,ado_pkg_int,dm_err->eproc)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "DTS(Downtime Schema) process auto-successed due to No-Downtime Plan"
   IF (log_package_op(olo_downtime_schema,ols_complete,dm_err->eproc,ado_env_id,ado_pkg_int)=0)
    RETURN(0)
   ENDIF
   CALL end_status(dm_err->eproc,ado_env_id,ado_pkg_int)
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET dm_err->eproc = build("Downtime Schema process auto-successed due to No-Downtime Plan  <",
    ado_pkg_int,">")
   IF (populate_batch_install_log2(olo_downtime_schema,ado_env_id,ado_pkg_int,dm_err->eproc)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "POST-DTS Readme process auto-successed due to No-Downtime Plan"
   IF (log_package_op(olo_post_dts,ols_complete,dm_err->eproc,ado_env_id,ado_pkg_int)=0)
    RETURN(0)
   ENDIF
   CALL end_status(dm_err->eproc,ado_env_id,ado_pkg_int)
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET dm_err->eproc = build("POST-DTS Readme process auto-successed due to No-Downtime Plan  <",
    ado_pkg_int,">")
   IF (populate_batch_install_log2(olo_post_dts,ado_env_id,ado_pkg_int,dm_err->eproc)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE code_set_instance_init(csii_pkg_int)
   SELECT INTO "nl:"
    cvs.code_set, cvs.code_set_instance, cvs.updt_dt_tm
    FROM dm_afd_code_value_set cvs
    WHERE cvs.alpha_feature_nbr=csii_pkg_int
    DETAIL
     ics_cs->cnt = (ics_cs->cnt+ 1)
     IF (mod(ics_cs->cnt,100)=1)
      stat = alterlist(ics_cs->qual,(ics_cs->cnt+ 99))
     ENDIF
     ics_cs->qual[ics_cs->cnt].code_set = cvs.code_set, ics_cs->qual[ics_cs->cnt].afd_instance = cvs
     .code_set_instance
    FOOT REPORT
     stat = alterlist(ics_cs->qual,ics_cs->cnt)
    WITH nocounter
   ;end select
   IF (check_error("Loading list of code sets and their instances.")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    di.info_number
    FROM dm_info di,
     (dummyt d  WITH seq = ics_cs->cnt)
    PLAN (d)
     JOIN (di
     WHERE di.info_domain="DM2-CODE-SET-INSTANCE"
      AND di.info_name=cnvtstring(ics_cs->qual[d.seq].code_set))
    DETAIL
     ics_cs->qual[d.seq].di_instance = di.info_number
    WITH nocounter
   ;end select
   IF (check_error("Loading code set instance rows.")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag >= 2))
    CALL echorecord(ics_cs)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dip_pre_install_schema_sync(dpis_package_int)
   DECLARE dpis_cmd = vc WITH protect, noconstant("")
   DECLARE dpis_found = i2 WITH protect, noconstant(0)
   DECLARE dpis_col_oradef_ind = i2 WITH protect, noconstant(0)
   DECLARE dpis_col_ccldef_ind = i2 WITH protect, noconstant(0)
   DECLARE dpis_data_type = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Beginning sync of schema table/columns with afd table/columns"
   CALL disp_msg("",dm_err->logfile,0)
   IF (dm2_table_and_ccldef_exists("CODE_VALUE_SET",dpis_found)=0)
    RETURN(0)
   ENDIF
   IF (dpis_found=1)
    SET dm_err->eproc = "Verifying if column exists on the ccl defintion of the table"
    IF (dm2_table_column_exists(value(currdbuser),"CODE_VALUE_SET","DEFINITION_DUP_IND",1,1,
     1,dpis_col_oradef_ind,dpis_col_ccldef_ind,dpis_data_type)=0)
     RETURN(0)
    ENDIF
    IF (((dpis_col_oradef_ind=0) OR (dpis_col_ccldef_ind=0)) )
     SET dm_err->eproc = "Generating ADD COLUMN operations"
     SELECT INTO "nl:"
      FROM dm_afd_tables t,
       dm_afd_columns tc
      PLAN (t
       WHERE t.alpha_feature_nbr=dpis_package_int
        AND t.owner=currdbuser
        AND t.table_name="CODE_VALUE_SET")
       JOIN (tc
       WHERE t.owner=tc.owner
        AND t.table_name=tc.table_name
        AND t.alpha_feature_nbr=tc.alpha_feature_nbr
        AND tc.column_name="DEFINITION_DUP_IND")
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (curqual > 0)
      IF (dpis_col_oradef_ind=0)
       SET dpis_cmd =
       "RDB ASIS (^ ALTER TABLE CODE_VALUE_SET ADD DEFINITION_DUP_IND NUMBER NULL ^) GO"
       IF (dm2_push_cmd(dpis_cmd,1)=0)
        RETURN(0)
       ENDIF
      ENDIF
      EXECUTE oragen3 "CODE_VALUE_SET"
      IF ((dm_err->err_ind=1))
       RETURN(0)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dip_confirm_monitor_settings(dcms_user_choice)
   DECLARE s_dcms_install_mon_status = i2 WITH protect, noconstant(1)
   DECLARE s_dcms_install_mon_interval = f8 WITH protect, noconstant(15.0)
   DECLARE s_dcms_arch_mon_status = i2 WITH protect, noconstant(0)
   DECLARE s_dcms_arch_pause_threshold = f8 WITH protect, noconstant(0.0)
   DECLARE s_dcms_arch_notify_threshold = f8 WITH protect, noconstant(0.0)
   DECLARE s_dcms_arch_cur_spc_used = f8 WITH protect, noconstant(0.0)
   DECLARE s_dcms_arch_ind = i2 WITH protect, noconstant(0)
   DECLARE s_dcms_mod_loop = i2 WITH protect, noconstant(0)
   DECLARE s_dcms_arch_dest = vc WITH protect, noconstant(" ")
   DECLARE s_dcms_temp_num = vc WITH protect, noconstant(" ")
   WHILE (s_dcms_mod_loop=0)
     SELECT INTO "nl:"
      FROM dm_info d
      WHERE d.info_domain="DM2_INSTALL_MONITOR:PLANSETTINGS"
       AND d.info_name=cnvtstring(dip_package_abs_int)
      DETAIL
       s_dcms_install_mon_interval = d.info_long_id
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (dipma_check_db_arch_mode(null)=0)
      IF ((dm_err->err_ind=1))
       RETURN(0)
      ENDIF
     ELSE
      SET s_dcms_arch_ind = 1
      IF (dipma_get_arch_thresholds(s_dcms_arch_pause_threshold,s_dcms_arch_notify_threshold)=0)
       IF ((dm_err->err_ind=1))
        RETURN(0)
       ENDIF
      ELSE
       SET s_dcms_arch_mon_status = 1
      ENDIF
      IF (dipma_get_arch_dest_space(s_dcms_arch_dest,s_dcms_arch_cur_spc_used)=0)
       RETURN(0)
      ENDIF
     ENDIF
     SET message = window
     SET width = 132
     CALL clear(1,1)
     CALL box(1,1,3,132)
     CALL text(2,2,"INSTALL PLAN MONITORING - Settings confirmation")
     CALL text(5,2,concat("Install Monitoring Status: ",evaluate(s_dcms_install_mon_status,1,"ON",
        "OFF")))
     CALL text(6,2,concat("Monitoring Interval: Every ",trim(cnvtstring(s_dcms_install_mon_interval)),
       " Minutes"))
     CALL text(8,2,concat("ArchiveLog Monitoring Status: ",evaluate(s_dcms_arch_mon_status,1,"ON",
        "OFF")))
     SET s_dcms_temp_num = dipma_get_two_dec(build(s_dcms_arch_cur_spc_used))
     CALL text(9,2,concat("Current ArchiveLog usage: ",evaluate(s_dcms_arch_ind,1,concat(
         s_dcms_temp_num," Gigabytes"),"Unknown")))
     SET s_dcms_temp_num = dipma_get_two_dec(build(s_dcms_arch_notify_threshold))
     CALL text(10,2,concat("Warning emails occur when ArchiveLog space usage exceeds: ",
       s_dcms_temp_num," Gigabytes (0 means No Warning)"))
     SET s_dcms_temp_num = dipma_get_two_dec(build(s_dcms_arch_pause_threshold))
     CALL text(11,2,concat("Installation Pause occurs when ArchiveLog space usage exceeds: ",
       s_dcms_temp_num," Gigabytes (0 means No Pause)"))
     CALL text(13,2,"(C)ontinue Installation, (M)odify settings, (Q)uit:")
     CALL accept(13,55,"P;CU","C"
      WHERE curaccept IN ("C", "M", "Q"))
     SET dcms_user_choice = curaccept
     CASE (dcms_user_choice)
      OF "Q":
       SET s_dcms_mod_loop = 1
      OF "C":
       SET s_dcms_mod_loop = 1
      OF "M":
       EXECUTE dm2_install_plan_menu_arch s_dcms_install_mon_status
     ENDCASE
   ENDWHILE
   SET message = nowindow
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dip_set_ccl_traces(null)
   DECLARE dsct_idx = i4 WITH protect, noconstant(0)
   DECLARE dsct_cmd = vc WITH protect, noconstant(" ")
   FOR (dsct_idx = 1 TO ccl_trace_list->trace_cnt)
     IF ((ccl_trace_list->qual[dsct_idx].active_status_orig=- (1)))
      CALL echo(concat("dip_set_ccl_traces: Bypassing invalid trace name: ",ccl_trace_list->qual[
        dsct_idx].trace_name))
     ELSE
      IF ((ccl_trace_list->qual[dsct_idx].active_status_new=1))
       SET dsct_cmd = concat("set trace ",ccl_trace_list->qual[dsct_idx].trace_name," go")
      ELSE
       SET dsct_cmd = concat("set trace NO",ccl_trace_list->qual[dsct_idx].trace_name," go")
      ENDIF
      IF ((ccl_trace_list->qual[dsct_idx].active_status_new IN (0, 1)))
       IF (dm2_push_cmd(dsct_cmd,1)=0)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dip_reset_ccl_traces(null)
   DECLARE drsct_idx = i4 WITH protect, noconstant(0)
   DECLARE drsct_cmd = vc WITH protect, noconstant(" ")
   FOR (drsct_idx = 1 TO ccl_trace_list->trace_cnt)
     IF ((ccl_trace_list->qual[drsct_idx].active_status_orig=- (1)))
      CALL echo(concat("dip_reset_ccl_traces: Bypassing invalid trace name: ",ccl_trace_list->qual[
        drsct_idx].trace_name))
     ELSE
      IF ((ccl_trace_list->qual[drsct_idx].active_status_orig=1))
       SET drsct_cmd = concat("set trace ",ccl_trace_list->qual[drsct_idx].trace_name," go")
      ELSE
       SET drsct_cmd = concat("set trace NO",ccl_trace_list->qual[drsct_idx].trace_name," go")
      ENDIF
      IF ((ccl_trace_list->qual[drsct_idx].active_status_orig IN (0, 1)))
       IF (dm2_push_cmd(drsct_cmd,1)=0)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dip_recyclebin_check(drc_recyclebin_choice)
   SET drc_recyclebin_choice = " "
   IF (dm2_get_rdbms_version(null)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_rdbms_version->level1 >= 10))
    SET dm_err->eproc = "Beginning recyclebin check"
    SELECT INTO "nl:"
     FROM recyclebin rb
     WHERE rb.type="TABLE"
     WITH maxqual(rb,1), nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual > 0)
     SET message = window
     SET width = 132
     CALL clear(1,1)
     CALL box(1,1,3,132)
     CALL text(2,25,"*** RECYCLEBIN CHECK ***")
     CALL text(5,3,"WARNING: Recyclebin is not empty. This may lead to query performance")
     CALL text(6,3,"         degradation due to install queries joining to recyclebin.")
     CALL text(7,3,"         Please contact your DBA regarding recyclebin cleanup.")
     CALL text(10,2,"(C)ontinue Installation, (Q)uit:")
     CALL accept(10,55,"P;CU"," "
      WHERE curaccept IN ("C", "Q"))
     SET drc_recyclebin_choice = curaccept
     SET message = nowindow
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dip_disp_missing_cvg_rpt(null)
   FREE RECORD ddmcr_pkg_rs
   RECORD ddmcr_pkg_rs(
     1 cnt = i4
     1 qual[*]
       2 pkg_nbr = i4
       2 code_set = i4
   )
   DECLARE ddmcr_best_csi_pkg = i4 WITH protect, noconstant(0)
   DECLARE ddmcr_use_csi = i4 WITH protect, noconstant(0)
   DECLARE ddmcr_best_csi = i4 WITH protect, noconstant(0)
   SET dm_err->eproc =
   "Loading Package number(s) associated to missing Code_value_group parent code_set(s)"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_afd_code_value_set cvs,
     dm_install_plan dip,
     (dummyt d  WITH seq = value(dip_cvg_rs->cnt))
    PLAN (d)
     JOIN (cvs
     WHERE (cvs.code_set=dip_cvg_rs->qual[d.seq].parent_cs))
     JOIN (dip
     WHERE dip.install_plan_id=abs(sbr_ics_package_int)
      AND dip.package_number=cvs.alpha_feature_nbr)
    ORDER BY cvs.code_set, cvs.updt_dt_tm, cvs.alpha_feature_nbr
    HEAD cvs.code_set
     ddmcr_best_csi_pkg = 0, ddmcr_best_csi = 0, ddmcr_use_csi = 1
    DETAIL
     IF (cvs.code_set_instance=0)
      ddmcr_use_csi = 0
     ENDIF
     IF (ddmcr_use_csi=1
      AND cvs.code_set_instance > ddmcr_best_csi)
      ddmcr_best_csi = cvs.code_set_instance, ddmcr_best_csi_pkg = cvs.alpha_feature_nbr
     ENDIF
    FOOT  cvs.code_set
     ddmcr_pkg_rs->cnt = (ddmcr_pkg_rs->cnt+ 1), stat = alterlist(ddmcr_pkg_rs->qual,ddmcr_pkg_rs->
      cnt), ddmcr_pkg_rs->qual[ddmcr_pkg_rs->cnt].code_set = cvs.code_set
     IF (ddmcr_use_csi=1)
      ddmcr_pkg_rs->qual[ddmcr_pkg_rs->cnt].pkg_nbr = ddmcr_best_csi_pkg
     ELSE
      ddmcr_pkg_rs->qual[ddmcr_pkg_rs->cnt].pkg_nbr = cvs.alpha_feature_nbr
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(ddmcr_pkg_rs)
   ENDIF
   SET dip_cvg_rpt_file = build(dm2_install_schema->logfile_prefix,"_cvg.rpt")
   SET dm_err->eproc = "Generate report for missing child code values "
   SELECT INTO value(dip_cvg_rpt_file)
    FROM (dummyt d  WITH seq = value(dip_cvg_rs->cnt)),
     (dummyt dt  WITH seq = value(ddmcr_pkg_rs->cnt))
    PLAN (d)
     JOIN (dt
     WHERE (ddmcr_pkg_rs->qual[dt.seq].code_set=dip_cvg_rs->qual[d.seq].parent_cs))
    HEAD REPORT
     row + 1, col 0, "CODE_VALUE_GROUP Installation Failure Report",
     row + 1, col 0, "--------------------------------------------",
     row + 1, col 0,
     "The following Code Value Group relationship entries were attemped for this install plan but",
     row + 1, col 0, "were unable to install because the child code_value is not already",
     row + 1, col 0, "in the database or not included on the package. ",
     row + 1, row + 2, col 0,
     "Parent_Code_Set", col 20, "Parent_Code_Value",
     col 40, "Child_Code_Set", col 60,
     "Child_Code_Value", col 80, "Package for Parent Code Set",
     row + 1, col 0,
     CALL print(fillstring(15,"-")),
     col 20,
     CALL print(fillstring(17,"-")), col 40,
     CALL print(fillstring(15,"-")), col 60,
     CALL print(fillstring(16,"-")),
     col 80,
     CALL print(fillstring(27,"-")), row + 1
    DETAIL
     row + 1, col 0,
     CALL print(dip_cvg_rs->qual[d.seq].parent_cs),
     col 20,
     CALL print(dip_cvg_rs->qual[d.seq].parent_cv), col 40,
     CALL print(dip_cvg_rs->qual[d.seq].child_cs), col 60,
     CALL print(build2(dip_cvg_rs->qual[d.seq].child_cv,"**")),
     dip_cvg_rs->qual[d.seq].pkg_nbr = ddmcr_pkg_rs->qual[dt.seq].pkg_nbr, col 80,
     CALL print(dip_cvg_rs->qual[d.seq].pkg_nbr)
    FOOT REPORT
     row + 2, col 0, "** Code Value not included on package.",
     row + 1, col 0, "Please log a Service Request to the Millennium Solution team for this package.",
     row + 1, col 0, "****************************** END OF REPORT *****************************",
     row + 1
    WITH nocounter, format = variable, formfeed = none,
     maxcol = 1000
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dip_cvg_rs)
   ENDIF
   IF ((dir_ui_misc->dm_process_event_id > 0))
    IF (drr_assign_file_to_installs("RPT:Missing CVG failure Report",dip_cvg_rpt_file,dir_ui_misc->
     dm_process_event_id)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dir_silmode_requested_ind=1)
    CALL dir_add_silmode_entry("CODE_VALUE_GROUP Installation Failure Report",dip_cvg_rpt_file)
    SET dm_err->eproc = concat(
     "Silent Mode: CODE_VALUE_GROUP Installation Failure Report was bypassed.",
     "Report exists in CCLUSERDIR under file name:",dip_cvg_rpt_file)
    CALL disp_msg("",dm_err->logfile,0)
   ELSE
    IF (dm2_disp_file(dip_cvg_rpt_file,"CODE_VALUE_GROUP Installation Failure Report")=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dip_admin_upgrade(dau_install_mode,dau_package_abs_float)
   DECLARE dau_dblink = vc WITH protect, noconstant("")
   DECLARE dau_run_dm_ocd_setup_admin = i2 WITH protect, noconstant(0)
   DECLARE dau_process_completed = i2 WITH protect, noconstant(0)
   DECLARE dau_exec_cmd = vc WITH protect, noconstant("")
   DECLARE dau_fail_ind = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Initiating admin upgrade for auto installation"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dir_check_dm_ocd_setup_admin(dau_run_dm_ocd_setup_admin,dau_install_mode)=0)
    RETURN(0)
   ELSE
    IF (dau_run_dm_ocd_setup_admin=1)
     EXECUTE dm2_create_system_defs
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
     IF (dir_get_admin_db_link(0,dau_dblink,dau_fail_ind)=0)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = "Deleting dm_info using dblink for ADMIN_UPGRADE_STATUS"
     CALL disp_msg(" ",dm_err->logfile,0)
     DELETE  FROM (value(concat("DM_INFO@",dau_dblink)) di)
      WHERE di.info_domain="ADMIN_UPGRADE_STATUS"
      WITH nocounter
     ;end delete
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      ROLLBACK
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
     IF (drr_submit_background_process("CDBA",dm2_install_schema->cdba_p_word,dm2_install_schema->
      cdba_connect_str," ",dpl_admin_upgrade,
      dau_package_abs_float," ")=0)
      RETURN(0)
     ENDIF
     WHILE (dau_process_completed=0)
       SET dau_exec_cmd = concat("ps -ef | grep 'dm2ob_admupg' | grep  -v grep")
       SET dm_err->disp_dcl_err_ind = 0
       IF (dm2_push_dcl(dau_exec_cmd)=0)
        IF ((dm_err->err_ind=1))
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
       ENDIF
       IF (parse_errfile(dm_err->errfile)=0)
        RETURN(0)
       ENDIF
       IF (findstring("dm2ob_admupg",dm_err->errtext)=0)
        IF (drr_cleanup_adm_dm_info_runners(dau_dblink)=0)
         RETURN(0)
        ENDIF
        SELECT INTO "nl:"
         FROM (value(concat("DM_INFO@",dau_dblink)) di)
         WHERE di.info_domain="DM2_ADMIN_RUNNER"
         WITH nocounter
        ;end select
        IF (check_error("Query dm_info using dblink for dm2_admin_runner")=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
        IF (curqual > 0)
         CALL pause(10)
        ELSE
         SET dau_process_completed = 1
        ENDIF
       ELSE
        CALL pause(10)
       ENDIF
     ENDWHILE
     SET dm_err->eproc = "Query dm_info using dblink for admin upgrade status"
     CALL disp_msg(" ",dm_err->logfile,0)
     SELECT INTO "nl:"
      FROM (value(concat("DM_INFO@",dau_dblink)) di)
      WHERE di.info_domain="ADMIN_UPGRADE_STATUS"
       AND di.info_char="COMPLETE"
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (curqual > 0)
      IF (dir_upd_adm_upgrade_info(null)=0)
       RETURN(0)
      ENDIF
     ELSE
      SET dm_err->eproc = "Check dm_info for admin upgrade status"
      SET dm_err->emsg =
      "Admin upgrade failed, Review logfile in CCLUSERDIR where prefixed dm2ob_admupg"
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
    ENDIF
    SET dau_run_dm_ocd_setup_admin = 0
    IF (dir_check_dm_ocd_setup_admin(dau_run_dm_ocd_setup_admin,dau_install_mode)=0)
     RETURN(0)
    ENDIF
    IF (dau_run_dm_ocd_setup_admin=1)
     SET dm_err->eproc = "Re-evaluate whether Admin upgrade should be completed"
     SET dm_err->emsg =
     "Determined Admin upgrade needs to run when already initiated in prior run of install"
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_program
 IF ((dip_final_msg->error_ind=1))
  SET dm_err->eproc = dip_final_msg->eproc
  SET dm_err->emsg = dip_final_msg->emsg
  SET dm_err->user_action = dip_final_msg->user_action
 ENDIF
 IF ((dnotify->status=1)
  AND (dm2_process_event_rs->ui_allowed_ind=1)
  AND (dm_err->err_ind=1))
  SET dnotify->process = "INSTALLPLAN"
  SET dnotify->install_status = dpl_failed
  SET dnotify->event = dm2_process_event_rs->itinerary_key
  SET dnotify->mode = dip_install_mode
  SET dnotify->plan_id = dip_package_abs_float
  SET dnotify->msgtype = dpl_actionreq
  CALL dn_add_body_text(" ",1)
  CALL dn_add_body_text(concat(dip_install_mode," Failed for Plan ",trim(cnvtstring(
      dip_package_abs_float)),", Environment ",dip_env_name,
    " at ",format(cnvtdatetime(curdate,curtime3),";;q")),0)
  CALL dn_add_body_text(" ",0)
  CALL dn_add_body_text("All logfiles related to the Install can be viewed at:",0)
  CALL dn_add_body_text(
   "   ccl | dm2_install_plan_menu go | Installation Reports | View Install Log Files",0)
  CALL dn_add_body_text(" ",0)
  CALL dn_add_body_text("The last error message generated is below:",0)
  CALL dn_add_body_text(" ",0)
  CALL dn_add_body_text(concat("ACTION:",dm_err->eproc),0)
  CALL dn_add_body_text(" ",0)
  CALL dn_add_body_text(concat("ERROR MESSAGE:",dm_err->emsg),0)
  IF ((dm_err->user_action != "NONE"))
   CALL dn_add_body_text(concat("RECOMMENDED USER ACTION:",dm_err->user_action),0)
  ENDIF
  CALL dn_add_body_text(" ",0)
  IF ((dir_ui_misc->background_ind=1)
   AND validate(dm2_package_os_session_logfile,"x") != "x")
   CALL dn_add_body_text(concat("LOGFILE:",dm2_package_os_session_logfile),0)
  ELSE
   CALL dn_add_body_text(concat("LOGFILE:",dm_err->logfile),0)
  ENDIF
  SET dm2_process_event_rs->begin_dt_tm = cnvtdatetime(curdate,curtime3)
  SET dm2_process_event_rs->status = dpl_complete
  SET dm2_process_event_rs->end_dt_tm = cnvtdatetime(curdate,curtime3)
  SET dm2_process_event_rs->install_plan_id = dip_package_abs_float
  CALL dm2_process_log_add_detail_text(dpl_audit_name,concat("EMAIL: ",dip_install_mode," FAILURE"))
  CALL dm2_process_log_add_detail_text(dpl_audit_type,dpl_progress)
  CALL dn_notify(null)
 ENDIF
 IF ((dm2_process_event_rs->ui_allowed_ind=1)
  AND (dir_ui_misc->dm_process_event_id > 0))
  IF ((dm_err->err_ind=1))
   CALL dpl_upd_dped_last_status(dir_ui_misc->dm_process_event_id,substring(1,1900,dm_err->emsg),0.0,
    cnvtdatetime(curdate,curtime3))
  ELSE
   CALL dpl_upd_dped_last_status(dir_ui_misc->dm_process_event_id,
    "Package installation has completed.",0.0,cnvtdatetime(curdate,curtime3))
  ENDIF
 ENDIF
 CALL drr_remove_runner_row("DM2_INSTALL_PKG",currdbhandle)
 IF ((drr_flex_sched->pkg_using_schedule=1))
  DELETE  FROM dm_info di
   WHERE di.info_domain="DM2_FLEX_SCHED_USAGE"
    AND (di.info_name=drr_flex_sched->pkg_number)
    AND di.info_char=currdbhandle
   WITH nocounter
  ;end delete
  IF ((dm_err->err_ind=0))
   IF (check_error("Removing DM_INFO runner row for DM2_FLEX_SCHED_USAGE")=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ELSE
    COMMIT
   ENDIF
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET lpoe->project_type = olpt_install_log
 IF (dip_install_mode IN ("UTBATCH", "UTSCHEMA", "DTSCHEMA", "SCHEMA", "BATCHSCHEMA"))
  SET lpoe->project_name = concat(dip_install_mode,":",curnode)
 ELSE
  SET lpoe->project_name = dip_install_mode
 ENDIF
 SET lpoe->environment_id = dip_env_id
 SET lpoe->ocd = dip_package_int
 SET lpoe->project_instance = 1
 SET lpoe->batch_dt_tm = dip_start_dt_tm
 SET lpoe->end_dt_tm = cnvtdatetime(curdate,curtime3)
 IF ((dm_err->err_ind=1))
  SET lpoe->status = ols_failed
  SET lpoe->message = concat(dip_install_mode," Mode Error: ",dm_err->emsg)
 ELSE
  SET lpoe->status = ols_complete
  SET lpoe->message = concat(dip_install_mode," Mode")
 ENDIF
 CALL log_package_op_event(null)
 IF ((((dm2_install_schema->run_id > 0)) OR ((dm2_rr_misc->batch_dt_tm != cnvtdatetime("01-JAN-1800")
 ))) )
  IF ((dm_err->debug_flag < 1))
   SET message = noinformation
  ENDIF
  IF (currdb IN ("SQLSRV", "DB2UDB"))
   CALL parser("free define sqlsystem go",1)
  ELSE
   CALL parser("free define oraclesystem go",1)
  ENDIF
  SET dm2_install_schema->dbase_name = dm2_install_schema->target_dbase_name
  SET dm2_install_schema->u_name = currdbuser
  SET dm2_install_schema->p_word = dm2_install_schema->v500_p_word
  SET daso_skip_session_overrides_ind = 1
  EXECUTE dm2_connect_to_dbase "CO"
  SET message = information
  IF (currdbhandle <= " ")
   CALL echo("*")
   CALL echo("**************************************************************************")
   CALL echo("* DATABASE CONNECTION REMOVED. RE-ENTER CCL TO ESTABLISH NEW CONNECTION. *")
   CALL echo("**************************************************************************")
   CALL echo("*")
  ENDIF
 ENDIF
 CALL dip_reset_ccl_traces(null)
 IF ((dip_final_msg->error_ind=1))
  SET dm_err->eproc = dip_final_msg->eproc
  SET dm_err->emsg = dip_final_msg->emsg
  SET dm_err->user_action = dip_final_msg->user_action
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
 ENDIF
 IF ((dm_err->err_ind=0))
  IF (dip_unattended_install_ind=1
   AND (dir_ui_misc->background_ind=0))
   SET dm_err->eproc =
   "Please monitor the installation using the following command: ccl> dm2_install_plan_menu go"
  ELSE
   SET dm_err->eproc = "Package installation completed. "
  ENDIF
 ENDIF
 CALL final_disp_msg(dip_logfile_prefix)
END GO
