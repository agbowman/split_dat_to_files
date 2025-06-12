CREATE PROGRAM dm2_xntr_menu:dba
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
 DECLARE dxrc_update_detail(dud_xntr_detail_id=f8,dud_xntr_status=vc,dud_commit_ind=i2) = i2
 DECLARE dxrc_rollback_extract(dre_extract_id=f8,dre_detail_id=f8,dre_commit_ind=i2) = i2
 DECLARE dxrc_update_job(duj_job_id=f8,duj_status=vc,duj_status_msg=vc,duj_commit_ind=i2) = i2
 DECLARE dxrc_update_extract(due_extract_id=f8,due_status=vc,due_status_msg=vc,due_commit_ind=i2) =
 i2
 DECLARE dxrc_check_stop_time(dcst_start_time=f8) = i2
 DECLARE dxrc_requeue_errors(dre_job_error_id=f8,dre_extract_error_id=f8) = i2
 SUBROUTINE dxrc_update_detail(dud_xntr_detail_id,dud_xntr_status,dud_commit_ind)
   DECLARE dud_prev_err_ind = i2 WITH protect, noconstant
   SET dud_xntr_status = cnvtupper(dud_xntr_status)
   SET dud_prev_err_ind = dm_err->err_ind
   SET dm_err->err_ind = 0
   IF (dud_xntr_status IN ("ERROR", "FINISHED"))
    UPDATE  FROM dm_xntr_detail d
     SET d.status = dud_xntr_status, d.status_msg = evaluate(dud_xntr_status,"FINISHED",
       "Detail work completed successfully","ERROR",dm_err->emsg), d.end_dt_tm = cnvtdatetime(curdate,
       curtime3),
      d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_applctx = reqinfo->updt_applctx, d
      .updt_task = reqinfo->updt_task,
      d.updt_cnt = (d.updt_cnt+ 1), d.updt_id = reqinfo->updt_id
     WHERE d.dm_xntr_detail_id=dud_xntr_detail_id
     WITH nocounter
    ;end update
   ELSEIF (dud_xntr_status="RUNNING")
    UPDATE  FROM dm_xntr_detail d
     SET d.status = dud_xntr_status, d.start_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      d.updt_applctx = reqinfo->updt_applctx, d.updt_task = reqinfo->updt_task, d.updt_cnt = (d
      .updt_cnt+ 1),
      d.updt_id = reqinfo->updt_id
     WHERE d.dm_xntr_detail_id=dud_xntr_detail_id
     WITH nocounter
    ;end update
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->emsg = build("Invalid status passed into DXRC_UPDATE_DETAIL: ",dud_xntr_status)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   IF (check_error("Updating DM_XNTR_DETAIL") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(1)
   ELSE
    SET dm_err->err_ind = dud_prev_err_ind
   ENDIF
   IF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = build("No row found in DM_XNTR_DETAIL for ID: ",dud_xntr_detail_id)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   IF (dud_commit_ind=1)
    COMMIT
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dxrc_rollback_extract(dre_extract_id,dre_detail_id,dre_commit_ind)
   DECLARE dre_tab_loop = i4 WITH protect, noconstant(0)
   DECLARE dre_msg = vc WITH protect, noconstant("")
   DECLARE dre_mismatch_cnt = i4 WITH protect, noconstant(0)
   DECLARE dre_orig_e_ind = i4 WITH protect, noconstant(0)
   DECLARE dre_err_msg = vc WITH protect, noconstant(" ")
   FREE RECORD dre_tab_list
   RECORD dre_tab_list(
     1 table_cnt = i4
     1 table_qual[*]
       2 table_name = vc
       2 delete_cnt = i4
   )
   ROLLBACK
   SET dre_orig_e_ind = dm_err->err_ind
   SET dm_err->err_ind = 0
   SET dre_msg = dm_err->emsg
   SELECT INTO "NL:"
    FROM dm_xntr_extract d
    WHERE d.dm_xntr_extract_id=dre_extract_id
    WITH nocounter
   ;end select
   IF (check_error("Validating DM_XNTR_EXTRACT_ID") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   IF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = build("No row found in DM_XNTR_EXTRACT for ID: ",dre_extract_id)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   IF (dre_detail_id > 0)
    SET dm_err->emsg = dre_msg
    IF (dxrc_update_detail(dre_detail_id,"ERROR",dre_commit_ind)=1)
     RETURN(1)
    ENDIF
   ENDIF
   SELECT DISTINCT INTO "NL:"
    d.table_name
    FROM dm_xntr_extract_row_data d
    WHERE d.extract_id=dre_extract_id
    DETAIL
     dre_tab_list->table_cnt = (dre_tab_list->table_cnt+ 1), stat = alterlist(dre_tab_list->
      table_qual,dre_tab_list->table_cnt), dre_tab_list->table_qual[dre_tab_list->table_cnt].
     table_name = d.table_name
    WITH nocounter
   ;end select
   IF (check_error("Gathering table names from DM_XNTR_EXTRACT_ROW_DATA") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   IF ((dre_tab_list->table_cnt > 0))
    FOR (dre_tab_loop = 1 TO dre_tab_list->table_cnt)
      DELETE  FROM (parser(dre_tab_list->table_qual[dre_tab_loop].table_name) d)
       WHERE d.rowid IN (
       (SELECT
        d1.new_rowid
        FROM dm_xntr_extract_row_data d1
        WHERE d1.extract_id=dre_extract_id
         AND (d1.table_name=dre_tab_list->table_qual[dre_tab_loop].table_name)))
       WITH nocounter
      ;end delete
      IF (check_error(build("Deleting data from ",dre_tab_list->table_qual[dre_tab_loop].table_name))
       != 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN(1)
      ENDIF
      SET dre_tab_list->table_qual[dre_tab_loop].delete_cnt = curqual
      UPDATE  FROM dm_xntr_extract_cnt d
       SET d.deleted_row_cnt = dre_tab_list->table_qual[dre_tab_loop].delete_cnt, d.updt_cnt = (d
        .updt_cnt+ 1), d.updt_applctx = reqinfo->updt_applctx,
        d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task, d.updt_dt_tm = cnvtdatetime(
         curdate,curtime3)
       WHERE dm_xntr_extract_id=dre_extract_id
        AND (retrieved_row_cnt=dre_tab_list->table_qual[dre_tab_loop].delete_cnt)
        AND (table_name=dre_tab_list->table_qual[dre_tab_loop].table_name)
       WITH nocounter
      ;end update
      IF (check_error("Recording delete in DM_XNTR_EXTRACT_CNT") != 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN(1)
      ENDIF
      IF (curqual=0)
       SET dm_err->err_ind = 1
       SET dm_err->emsg = "Could not update the DM_XNTR_EXTRACT_CNT table"
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN(1)
      ENDIF
    ENDFOR
    SELECT INTO "NL:"
     cnt = count(*)
     FROM dm_xntr_extract_cnt d
     WHERE d.dm_xntr_extract_id=dre_extract_id
      AND d.deleted_row_cnt != d.retrieved_row_cnt
     DETAIL
      dre_mismatch_cnt = cnt
     WITH nocounter
    ;end select
    IF (check_error("Looking for mismatched rows in DM_XNTR_EXTRACT_CNT") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(1)
    ENDIF
    IF (dre_mismatch_cnt > 0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "There were inserts reported in DM_XNTR_EXTRACT_CNT that weren't deleted."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(1)
    ENDIF
   ENDIF
   SET dre_err_msg = evaluate(dre_detail_id,0.0,dre_msg,concat(
     "An error occured during the transform: ",trim(cnvtstring(dre_detail_id,20),3)))
   IF (dxrc_update_extract(dre_extract_id,"ERROR",dre_err_msg,dre_commit_ind) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Deleting rows that were rolled back from dm_xntr_extract_row_data."
   DELETE  FROM dm_xntr_extract_row_data d
    WHERE d.extract_id=dre_extract_id
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(1)
   ENDIF
   IF (dre_commit_ind=1)
    COMMIT
   ENDIF
   SET dm_err->err_ind = dre_orig_e_ind
   SET dm_err->emsg = dre_msg
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dxrc_update_job(duj_job_id,duj_status,duj_status_msg,duj_commit_ind)
   DECLARE duj_prev_err_ind = i2 WITH protect, noconstant
   SET duj_status = cnvtupper(duj_status)
   SET duj_prev_err_ind = dm_err->err_ind
   SET dm_err->err_ind = 0
   IF (duj_status IN ("ERROR", "FINISHED"))
    UPDATE  FROM dm_xntr_job d
     SET d.status = duj_status, d.status_msg = duj_status_msg, d.job_end_dt_tm = cnvtdatetime(curdate,
       curtime3),
      d.audit_sid = null, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_applctx = reqinfo->
      updt_applctx,
      d.updt_task = reqinfo->updt_task, d.updt_cnt = (d.updt_cnt+ 1), d.updt_id = reqinfo->updt_id
     WHERE d.dm_xntr_job_id=duj_job_id
     WITH nocounter
    ;end update
   ELSEIF (duj_status="RUNNING")
    UPDATE  FROM dm_xntr_job d
     SET d.status = duj_status, d.status_msg = null, d.job_start_dt_tm = cnvtdatetime(curdate,
       curtime3),
      d.audit_sid = currdbhandle, d.log_file = dm_err->logfile, d.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      d.updt_applctx = reqinfo->updt_applctx, d.updt_task = reqinfo->updt_task, d.updt_cnt = (d
      .updt_cnt+ 1),
      d.updt_id = reqinfo->updt_id
     WHERE d.dm_xntr_job_id=duj_job_id
     WITH nocounter
    ;end update
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->emsg = build("Invalid status passed into DXRC_UPDATE_JOB: ",duj_status)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   IF (check_error("Updating DM_XNTR_JOB") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(1)
   ELSE
    SET dm_err->err_ind = duj_prev_err_ind
   ENDIF
   IF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = build("No row found in DM_XNTR_JOB for ID: ",duj_job_id)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   IF (duj_commit_ind=1)
    COMMIT
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dxrc_update_extract(due_extract_id,due_status,due_status_msg,due_commit_ind)
   DECLARE due_prev_err_ind = i2 WITH protect, noconstant
   FREE RECORD due_stmt
   RECORD due_stmt(
     1 stmt[*]
       2 str = vc
   )
   SET due_status = cnvtupper(due_status)
   SET due_prev_err_ind = dm_err->err_ind
   SET dm_err->err_ind = 0
   IF (due_status IN ("ERROR", "FINISHED"))
    UPDATE  FROM dm_xntr_extract d
     SET d.status = due_status, d.status_msg = due_status_msg, d.extract_stop_dt_tm = cnvtdatetime(
       curdate,curtime3),
      d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_applctx = reqinfo->updt_applctx, d
      .updt_task = reqinfo->updt_task,
      d.updt_cnt = (d.updt_cnt+ 1), d.updt_id = reqinfo->updt_id
     WHERE d.dm_xntr_extract_id=due_extract_id
     WITH nocounter
    ;end update
   ELSEIF (due_status="RETRIEVE")
    UPDATE  FROM dm_xntr_extract d
     SET d.status = due_status, d.status_msg = null, d.extract_start_dt_tm = cnvtdatetime(curdate,
       curtime3),
      d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_applctx = reqinfo->updt_applctx, d
      .updt_task = reqinfo->updt_task,
      d.updt_cnt = (d.updt_cnt+ 1), d.updt_id = reqinfo->updt_id
     WHERE d.dm_xntr_extract_id=due_extract_id
     WITH nocounter
    ;end update
   ELSEIF (due_status IN ("PARSE", "INSERT", "SYNCHRONIZE"))
    SET stat = alterlist(due_stmt->stmt,1)
    SET due_stmt->stmt[1].str = concat("rdb asis(^ BEGIN XNTR_UPDATE_EXTRACT_AUTON('",due_status,
     "','",due_status_msg,"',",
     trim(cnvtstring(due_extract_id,20),3),",'",format(cnvtdatetime(curdate,curtime3),";;q"),
     "'); END; ^) go")
    EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","DUE_STMT")
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->emsg = build("Invalid status passed into DXRC_UPDATE_EXTRACT: ",due_status)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   IF (check_error("Updating DM_XNTR_EXTRACT") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(1)
   ELSE
    SET dm_err->err_ind = due_prev_err_ind
   ENDIF
   IF (due_commit_ind=1)
    COMMIT
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dxrc_check_stop_time(dcst_start_time)
   DECLARE dcst_stop_ind = i2 WITH protect, noconstant(0)
   SELECT INTO "NL:"
    cnt = count(*)
    FROM dm_info d
    WHERE d.info_domain="DATA MANAGEMENT"
     AND d.info_name="XNTR STOP TIME"
     AND d.info_date > cnvtdatetime(dcst_start_time)
    DETAIL
     dcst_stop_ind = cnt
    WITH nocounter
   ;end select
   IF (check_error("Checking Stop Time") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   RETURN(dcst_stop_ind)
 END ;Subroutine
 SUBROUTINE dxrc_requeue_errors(dre_job_error_id,dre_extract_error_id)
   FREE RECORD dre_requeue
   RECORD dre_requeue(
     1 cnt = i4
     1 qual[*]
       2 job_id = f8
   )
   DECLARE dre_loop = i4 WITH protect, noconstant(0)
   IF (dre_job_error_id=0.0
    AND dre_extract_error_id=0.0)
    SELECT INTO "NL:"
     FROM dm_xntr_job d
     WHERE d.status="ERROR"
     DETAIL
      dre_requeue->cnt = (dre_requeue->cnt+ 1), stat = alterlist(dre_requeue->qual,dre_requeue->cnt),
      dre_requeue->qual[dre_requeue->cnt].job_id = d.dm_xntr_job_id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
   ELSEIF (dre_job_error_id > 0.0)
    SET stat = alterlist(dre_requeue->qual,1)
    SET dre_requeue->cnt = 1
    SET dre_requeue->qual[1].job_id = dre_job_error_id
   ELSEIF (dre_extract_error_id > 0.0)
    SELECT INTO "NL:"
     FROM dm_xntr_job d
     WHERE d.status="ERROR"
      AND d.dm_xntr_job_id IN (
     (SELECT
      dm_xntr_job_id
      FROM dm_xntr_extract
      WHERE dm_xntr_extract_id=dre_extract_error_id))
     DETAIL
      dre_requeue->cnt = (dre_requeue->cnt+ 1), stat = alterlist(dre_requeue->qual,dre_requeue->cnt),
      dre_requeue->qual[dre_requeue->cnt].job_id = d.dm_xntr_job_id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
   ENDIF
   IF ((dre_requeue->cnt=0))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Could not identify any errors"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   DELETE  FROM dm_xntr_detail d
    WHERE d.dm_xntr_extract_id IN (
    (SELECT
     e.dm_xntr_extract_id
     FROM dm_xntr_extract e
     WHERE expand(dre_loop,1,dre_requeue->cnt,e.dm_xntr_job_id,dre_requeue->qual[dre_loop].job_id)
      AND e.status != "FINISHED"))
    WITH nocounter, expand = 1
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   DELETE  FROM dm_xntr_extract_cnt d
    WHERE d.dm_xntr_extract_id IN (
    (SELECT
     e.dm_xntr_extract_id
     FROM dm_xntr_extract e
     WHERE expand(dre_loop,1,dre_requeue->cnt,e.dm_xntr_job_id,dre_requeue->qual[dre_loop].job_id)
      AND e.status != "FINISHED"))
    WITH nocounter, expand = 1
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   DELETE  FROM dm_xntr_extract d
    WHERE expand(dre_loop,1,dre_requeue->cnt,d.dm_xntr_job_id,dre_requeue->qual[dre_loop].job_id)
     AND d.status != "FINISHED"
    WITH nocounter, expand = 1
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   UPDATE  FROM dm_xntr_job j
    SET j.status = "QUEUED", j.status_msg = null, j.audit_sid = null,
     j.job_start_dt_tm = null, j.job_end_dt_tm = null, j.log_file = null,
     j.updt_id = reqinfo->updt_id, j.updt_cnt = (j.updt_cnt+ 1), j.updt_applctx = reqinfo->
     updt_applctx,
     j.updt_task = reqinfo->updt_task, j.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE expand(dre_loop,1,dre_requeue->cnt,j.dm_xntr_job_id,dre_requeue->qual[dre_loop].job_id)
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   COMMIT
   RETURN(0)
 END ;Subroutine
 DECLARE dxm_env_id = f8 WITH protect, noconstant(0.0)
 DECLARE dxm_env_name = vc WITH protect, noconstant(" ")
 DECLARE dxm_done_ind = i2 WITH protect, noconstant(0)
 DECLARE dxm_main_menu(null) = i2
 DECLARE dxm_disp_status(dds_error_ind=i2,dds_header=vc,dds_msg=vc) = null
 DECLARE dxm_load_file(null) = i2
 DECLARE dxm_job_report(null) = i2
 DECLARE dxm_extract_report(der_job_id=f8,der_person_str=vc) = i2
 DECLARE dxm_refresh_job_list(drjl_persons=vc(ref)) = i2
 DECLARE dxm_refresh_extract_list(drel_job_id=f8,drel_extracts=vc(ref)) = i2
 DECLARE dxm_refresh_detail_list(drdl_extract_id=f8,drdl_details=vc(ref)) = i2
 DECLARE dxm_detail_report(ddr_extract_id=f8,ddr_extract_name=vc) = i2
 DECLARE dxm_error_report(der_job_error_id=f8,der_extract_error_id=f8) = i2
 DECLARE dxm_start_process(null) = i2
 DECLARE dxm_stop_process(null) = i2
 DECLARE dxm_get_connect_info(dgci_signon=vc(ref)) = i2
 SET message = window
 CALL check_logfile("dm2_xntr_menu",".log","DM2_XNTR_MENU LOGFILE")
 SET dm_err->eproc = "Beginning dm2_xntr_menu"
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM dm_info a,
   dm_environment b
  PLAN (a
   WHERE a.info_name="DM_ENV_ID"
    AND a.info_domain="DATA MANAGEMENT")
   JOIN (b
   WHERE a.info_number=b.environment_id)
  DETAIL
   dxm_env_id = b.environment_id, dxm_env_name = b.environment_name
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc) != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 IF (curqual=0)
  SET dm_err->eproc = "Fatal Error: current environment id not found"
  CALL disp_msg(" ",dm_err->logfile,0)
  GO TO exit_program
 ENDIF
 WHILE (dxm_done_ind=0)
   SET dxm_done_ind = dxm_main_menu(null)
 ENDWHILE
 SUBROUTINE dxm_main_menu(null)
   DECLARE dmm_return_ind = i2
   SET message = window
   CALL clear(1,1)
   SET width = 132
   CALL box(1,1,5,132)
   CALL text(3,44,"***  EXTRACT AND TRANSFORM RETRIEVAL MENU  ***")
   CALL text(4,75,"ENVIRONMENT ID:")
   CALL text(4,20,"ENVIRONMENT NAME:")
   CALL text(4,95,cnvtstring(dxm_env_id))
   CALL text(4,40,dxm_env_name)
   CALL text(7,3,"Please choose from the following options:")
   CALL text(9,3,"1 Upload Retrieval List")
   CALL text(10,3,"2 View Retrieval Status")
   CALL text(11,3,"3 Start Retrieval Process")
   CALL text(12,3,"4 Stop Retrieval Process")
   CALL text(13,3,"0 Exit")
   CALL accept(7,50,"99",0
    WHERE curaccept IN (1, 2, 3, 4, 0))
   CASE (curaccept)
    OF 1:
     SET dmm_return_ind = dxm_load_file(null)
    OF 2:
     SET dmm_return_ind = dxm_job_report(null)
    OF 3:
     SET dmm_return_ind = dxm_start_process(null)
    OF 4:
     SET dmm_return_ind = dxm_stop_process(null)
    OF 0:
     RETURN(1)
   ENDCASE
   RETURN(dmm_return_ind)
 END ;Subroutine
 SUBROUTINE dxm_load_file(null)
   DECLARE dlf_done_ind = i2 WITH protect, noconstant(0)
   DECLARE dlf_return_ind = i2 WITH protect, noconstant(0)
   FREE RECORD dxirl_request
   RECORD dxirl_request(
     1 file_name = vc
   )
   FREE RECORD dxirl_reply
   RECORD dxirl_reply(
     1 msg = vc
   )
   WHILE (dlf_done_ind=0)
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,6,132)
     CALL text(3,44,"***  EXTRACT AND TRANSFORM RETRIEVAL MENU  ***")
     CALL text(4,55,"UPLOAD RETRIEVAL LIST")
     CALL text(5,75,"ENVIRONMENT ID:")
     CALL text(5,20,"ENVIRONMENT NAME:")
     CALL text(5,95,cnvtstring(dxm_env_id,20))
     CALL text(5,40,dxm_env_name)
     CALL text(8,3,concat(
       "The following prompt accepts a CSV file name that should exist in CCLUSERDIR ",
       "that contains the list of PERSON_ID's to retrieve."))
     CALL text(9,3,concat("The case sensitive prompt does not accept the file extension (.csv).  ",
       "Enter a blank line to escape from prompt."))
     CALL text(11,3,"File Name: ")
     CALL accept(11,15,"P(30);C"," ")
     IF (trim(curaccept)="")
      SET dlf_done_ind = 1
      SET dlf_return_ind = 0
     ELSE
      SET dxirl_request->file_name = curaccept
      SET dxirl_request->file_name = concat(trim(dxirl_request->file_name),".csv")
      IF (findfile(dxirl_request->file_name,4)=0)
       CALL dxm_disp_status(1,"UPLOAD RETRIEVAL LIST",concat("The ",dxirl_request->file_name,
         " file could not be found in CCLUSERDIR, or did not have read access allowed."))
      ELSE
       EXECUTE dm_dbimport dxirl_request->file_name, "dm2_xntr_ins_ret_list", 1000
       SET dlf_done_ind = 1
       IF ((dm_err->err_ind=1))
        CALL dxm_disp_status(1,"UPLOAD RETRIEVAL LIST",dm_err->emsg)
        ROLLBACK
       ELSE
        CALL dxm_disp_status(0,"UPLOAD RETRIEVAL LIST",dxirl_reply->msg)
       ENDIF
      ENDIF
     ENDIF
   ENDWHILE
   RETURN(dlf_return_ind)
 END ;Subroutine
 SUBROUTINE dxm_disp_status(dds_error_ind,dds_header,dds_msg)
   DECLARE dds_start = i4 WITH protect, noconstant(0)
   DECLARE dds_pos = i4 WITH protect, noconstant(8)
   DECLARE dds_done_ind = i2 WITH protect, noconstant(0)
   DECLARE dds_space_pos = i4 WITH protect, noconstant(0)
   DECLARE dds_last_pos = i4 WITH protect, noconstant(0)
   SET dds_start = (66 - floor((size(dds_header)/ 2)))
   CALL clear(1,1)
   SET width = 132
   CALL box(1,1,6,132)
   CALL text(3,44,"***  EXTRACT AND TRANSFORM RETRIEVAL MENU  ***")
   CALL text(4,dds_start,dds_header)
   CALL text(5,75,"ENVIRONMENT ID:")
   CALL text(5,20,"ENVIRONMENT NAME:")
   CALL text(5,95,cnvtstring(dxm_env_id))
   CALL text(5,40,dxm_env_name)
   IF (dds_error_ind=1)
    CALL text(8,3,"*** ERROR OCCURED ***")
    SET dds_pos = 10
    SET dm_err->err_ind = 0
   ENDIF
   SET dds_last_pos = 1
   WHILE (dds_done_ind=0)
     IF (size(dds_msg) > 126)
      SET dds_space_pos = findstring(" ",dds_msg,dds_last_pos,0)
      IF (dds_space_pos=0)
       IF (dds_last_pos=1)
        CALL text(dds_pos,3,substring(1,126,dds_msg))
        SET dds_msg = substring(127,size(dds_msg),dds_msg)
        SET dds_pos = (dds_pos+ 1)
       ELSE
        CALL text(dds_pos,3,substring(1,(dds_last_pos - 1),dds_msg))
        SET dds_msg = substring(dds_last_pos,size(dds_msg),dds_msg)
        SET dds_pos = (dds_pos+ 1)
       ENDIF
      ELSEIF (dds_space_pos > 126)
       CALL text(dds_pos,3,substring(1,(dds_last_pos - 1),dds_msg))
       SET dds_msg = substring(dds_last_pos,size(dds_msg),dds_msg)
       SET dds_pos = (dds_pos+ 1)
      ELSE
       SET dds_last_pos = (dds_space_pos+ 1)
      ENDIF
     ELSE
      CALL text(dds_pos,3,dds_msg)
      SET dds_done_ind = 1
     ENDIF
   ENDWHILE
   CALL text(19,3,"Press Enter to proceed")
   CALL accept(19,26,"P;E"," "
    WHERE curaccept=" ")
   RETURN(null)
 END ;Subroutine
 SUBROUTINE dxm_refresh_job_list(drjl_persons)
   DECLARE drjl_loop = i4 WITH protect, noconstant(0)
   DECLARE drjl_str_cnt = i4 WITH protect, noconstant(0)
   DECLARE drjl_temp_pos = i4 WITH protect, noconstant(0)
   DECLARE drjl_cnt = i4 WITH protect, noconstant(0)
   DECLARE drjl_list_loop = i4 WITH protect, noconstant(0)
   FREE RECORD drjl_error
   RECORD drjl_error(
     1 cnt = i4
     1 qual[*]
       2 extract_id = f8
   )
   FREE RECORD drjl_list
   RECORD drjl_list(
     1 qual[4]
       2 status = vc
   )
   SET drjl_list->qual[1].status = "RUNNING"
   SET drjl_list->qual[2].status = "ERROR"
   SET drjl_list->qual[3].status = "QUEUED"
   SET drjl_list->qual[4].status = "FINISHED"
   SELECT INTO "NL:"
    FROM dm_xntr_extract d
    WHERE d.status IN ("PARSE", "INSERT", "SYNCHRONIZE", "RETRIEVE")
     AND d.dm_xntr_job_id IN (
    (SELECT
     j.dm_xntr_job_id
     FROM dm_xntr_job j
     WHERE j.status="RUNNING"
      AND  NOT ( EXISTS (
     (SELECT
      "x"
      FROM gv$session gv
      WHERE gv.audsid=cnvtreal(j.audit_sid))))))
    DETAIL
     drjl_error->cnt = (drjl_error->cnt+ 1), stat = alterlist(drjl_error->qual,drjl_error->cnt),
     drjl_error->qual[drjl_error->cnt].extract_id = d.dm_xntr_extract_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    CALL dxm_disp_status(1,"RETRIEVAL PROGRESS",dm_err->emsg)
    RETURN(1)
   ENDIF
   FOR (drjl_loop = 1 TO drjl_error->cnt)
     IF (dxrc_rollback_extract(drjl_error->qual[drjl_loop].extract_id,0.0,1)=1)
      RETURN(1)
     ENDIF
   ENDFOR
   UPDATE  FROM dm_xntr_detail d
    SET d.status = "ERROR", d.status_msg =
     "The session running this retrieval has died.  See log file for possible errors", d.updt_id =
     reqinfo->updt_id,
     d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_applctx = reqinfo->updt_applctx, d
     .updt_task = reqinfo->updt_task,
     d.updt_cnt = (d.updt_cnt+ 1)
    WHERE d.status="RUNNING"
     AND expand(drjl_loop,1,drjl_error->cnt,d.dm_xntr_extract_id,drjl_error->qual[drjl_loop].
     extract_id)
    WITH nocounter, expand = 1
   ;end update
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    CALL dxm_disp_status(1,"RETRIEVAL PROGRESS",dm_err->emsg)
    RETURN(1)
   ENDIF
   UPDATE  FROM dm_xntr_extract d
    SET d.status = "ERROR", d.status_msg =
     "The session running this retrieval has died.  See log file for possible errors", d.updt_id =
     reqinfo->updt_id,
     d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_applctx = reqinfo->updt_applctx, d
     .updt_task = reqinfo->updt_task,
     d.updt_cnt = (d.updt_cnt+ 1)
    WHERE expand(drjl_loop,1,drjl_error->cnt,d.dm_xntr_extract_id,drjl_error->qual[drjl_loop].
     extract_id)
    WITH nocounter, expand = 1
   ;end update
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    CALL dxm_disp_status(1,"RETRIEVAL PROGRESS",dm_err->emsg)
    RETURN(1)
   ENDIF
   UPDATE  FROM dm_xntr_job d
    SET d.status = "ERROR", d.status_msg =
     "The session running this retrieval has died.  See log file for possible errors", d.audit_sid =
     null,
     d.updt_id = reqinfo->updt_id, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_applctx =
     reqinfo->updt_applctx,
     d.updt_task = reqinfo->updt_task, d.updt_cnt = (d.updt_cnt+ 1)
    WHERE d.status="RUNNING"
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM gv$session gv
     WHERE gv.audsid=cnvtreal(d.audit_sid))))
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    CALL dxm_disp_status(1,"RETRIEVAL PROGRESS",dm_err->emsg)
    RETURN(1)
   ENDIF
   COMMIT
   SET drjl_cnt = 0
   SET drjl_persons->completed_count = 0
   SET drjl_persons->error_count = 0
   SET stat = alterlist(drjl_persons->qual,0)
   SET stat = alterlist(drjl_persons->str_qual,0)
   SELECT INTO "NL:"
    FROM dm_xntr_job d,
     person p
    PLAN (d)
     JOIN (p
     WHERE p.person_id=outerjoin(d.person_id))
    DETAIL
     IF (d.status="FINISHED")
      drjl_persons->completed_count = (drjl_persons->completed_count+ 1)
     ENDIF
     IF (d.status="ERROR")
      drjl_persons->error_count = (drjl_persons->error_count+ 1)
     ENDIF
     drjl_cnt = (drjl_cnt+ 1), stat = alterlist(drjl_persons->qual,drjl_cnt), drjl_persons->qual[
     drjl_cnt].person_id = d.person_id,
     drjl_persons->qual[drjl_cnt].status = d.status, drjl_persons->qual[drjl_cnt].file_name = d
     .file_name, drjl_persons->qual[drjl_cnt].start_time = format(d.job_start_dt_tm,
      "DD-MMM-YYYY HH:MM;;D"),
     drjl_persons->qual[drjl_cnt].stop_time = format(d.job_end_dt_tm,"DD-MMM-YYYY HH:MM;;D")
     IF (trim(p.name_first_key) != ""
      AND trim(p.name_last_key) != "")
      drjl_persons->qual[drjl_cnt].person_name = concat(trim(substring(1,1,p.name_first_key)),". ",
       trim(substring(1,30,p.name_last_key)),"(",trim(cnvtstring(d.person_id)),
       ")")
     ELSE
      drjl_persons->qual[drjl_cnt].person_name = concat("(",trim(cnvtstring(d.person_id)),")")
     ENDIF
     drjl_persons->qual[drjl_cnt].job_id = d.dm_xntr_job_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    CALL dxm_disp_status(1,"RETRIEVAL PROGRESS",dm_err->emsg)
    RETURN(1)
   ENDIF
   SET drjl_persons->total = drjl_cnt
   SET stat = alterlist(drjl_persons->str_qual,drjl_cnt)
   SET drjl_str_cnt = 0
   FOR (drjl_list_loop = 1 TO 4)
     FOR (drjl_loop = 1 TO drjl_cnt)
       IF ((drjl_persons->qual[drjl_loop].status=drjl_list->qual[drjl_list_loop].status))
        SET drjl_str_cnt = (drjl_str_cnt+ 1)
        SET drjl_temp_pos = (4 - size(trim(cnvtstring(drjl_str_cnt))))
        SET drjl_persons->str_qual[drjl_str_cnt].disp_line = concat(trim(cnvtstring(drjl_str_cnt)),
         fillstring(value(drjl_temp_pos)," "),drjl_persons->qual[drjl_loop].person_name)
        SET drjl_temp_pos = (50 - size(drjl_persons->qual[drjl_loop].person_name))
        SET drjl_persons->str_qual[drjl_str_cnt].disp_line = concat(drjl_persons->str_qual[
         drjl_str_cnt].disp_line,fillstring(value(drjl_temp_pos)," "),drjl_persons->qual[drjl_loop].
         status)
        SET drjl_temp_pos = (10 - size(drjl_persons->qual[drjl_loop].status))
        SET drjl_persons->str_qual[drjl_str_cnt].disp_line = notrim(concat(drjl_persons->str_qual[
          drjl_str_cnt].disp_line,fillstring(value(drjl_temp_pos)," "),drjl_persons->qual[drjl_loop].
          start_time))
        SET drjl_temp_pos = (19 - size(drjl_persons->qual[drjl_loop].start_time))
        SET drjl_persons->str_qual[drjl_str_cnt].disp_line = notrim(concat(drjl_persons->str_qual[
          drjl_str_cnt].disp_line,fillstring(value(drjl_temp_pos)," "),drjl_persons->qual[drjl_loop].
          stop_time))
        SET drjl_temp_pos = (19 - size(drjl_persons->qual[drjl_loop].stop_time))
        SET drjl_persons->str_qual[drjl_str_cnt].disp_line = notrim(concat(drjl_persons->str_qual[
          drjl_str_cnt].disp_line,fillstring(value(drjl_temp_pos)," "),drjl_persons->qual[drjl_loop].
          file_name))
        SET drjl_persons->str_qual[drjl_str_cnt].job_id = drjl_persons->qual[drjl_loop].job_id
        SET drjl_persons->str_qual[drjl_str_cnt].person_name = drjl_persons->qual[drjl_loop].
        person_name
       ENDIF
     ENDFOR
   ENDFOR
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dxm_job_report(null)
   DECLARE djr_input = vc WITH protect, noconstant("R")
   DECLARE djr_header = vc WITH protect, constant(
    "*** EXTRACT AND TRANSFORM RETRIEVAL STATUS REPORT ***")
   DECLARE djr_header_offset = i2 WITH protect, constant(ceil(((129 - size(djr_header,1))/ 2)))
   DECLARE djr_cnt = i4 WITH protect, noconstant(0)
   DECLARE djr_loop = i4 WITH protect, noconstant(0)
   DECLARE djr_temp_pos = i4 WITH protect, noconstant(0)
   DECLARE djr_max = i4 WITH protect, noconstant(0)
   DECLARE djr_temp_str = vc WITH protect, noconstant(" ")
   DECLARE djr_return_ind = i2 WITH protect, noconstant(0)
   FREE RECORD djr_persons
   RECORD djr_persons(
     1 completed_count = i4
     1 error_count = i4
     1 total = i4
     1 qual[*]
       2 person_id = f8
       2 person_name = vc
       2 status = vc
       2 start_time = vc
       2 stop_time = vc
       2 file_name = vc
       2 job_id = f8
     1 str_qual[*]
       2 disp_line = vc
       2 job_id = f8
       2 person_name = vc
   )
   SET djr_return_ind = dxm_refresh_job_list(djr_persons)
   IF (djr_return_ind=1)
    RETURN(djr_return_ind)
   ENDIF
   SET djr_cnt = djr_persons->total
   SET djr_temp_pos = 1
   WHILE (djr_input="R")
     SET message = window
     CALL clear(1,1)
     SET width = 132
     CALL text(1,djr_header_offset,djr_header)
     CALL text(3,1,concat("Report Created: ",format(cnvtdatetime(curdate,curtime3),
        "DD-MMM-YYYY HH:MM;;D")," (list will auto-refresh every 30 seconds)"))
     CALL text(5,1,concat("Retrievals Completed: ",trim(cnvtstring(djr_persons->completed_count)),
       " out of ",trim(cnvtstring(djr_persons->total))," total"))
     CALL text(6,1,concat("Number of retrievals with Errors: ",trim(cnvtstring(djr_persons->
         error_count))))
     CALL text(7,1,fillstring(131,"-"))
     IF (djr_cnt > 0)
      CALL text(8,1,concat("No  Name(PERSON_ID)",fillstring(35," "),"Status    Start Time",fillstring
        (9," "),"Stop Time",
        fillstring(9," ")," Upload File Name"))
     ELSE
      CALL text(12,51,"No Retrieval Information Exists")
     ENDIF
     IF ((((djr_cnt - djr_temp_pos)+ 1) > 13))
      SET djr_max = 13
     ELSE
      SET djr_max = ((djr_cnt - djr_temp_pos)+ 1)
     ENDIF
     FOR (djr_loop = 1 TO djr_max)
       CALL text((djr_loop+ 8),1,djr_persons->str_qual[((djr_loop+ djr_temp_pos) - 1)].disp_line)
     ENDFOR
     CALL text(22,1,fillstring(131,"-"))
     CALL text(23,1,"Command Options:")
     SET djr_temp_str = "(R)efresh"
     IF (djr_cnt > 13)
      IF (djr_temp_pos > 1)
       SET djr_temp_str = concat(djr_temp_str,", Page (U)p")
      ENDIF
      IF (((djr_temp_pos+ 12) < djr_cnt))
       SET djr_temp_str = concat(djr_temp_str,", Page (D)own")
      ENDIF
     ENDIF
     IF (djr_cnt > 0)
      IF (((djr_temp_pos+ 12) < djr_cnt))
       SET djr_temp_str = concat(djr_temp_str,", View Retrieve Details(",trim(cnvtstring(djr_temp_pos
          )),"-",trim(cnvtstring((djr_temp_pos+ 12))),
        ")")
      ELSE
       SET djr_temp_str = concat(djr_temp_str,", View Retrieve Details(",trim(cnvtstring(djr_temp_pos
          )),"-",trim(cnvtstring(djr_cnt)),
        ")")
      ENDIF
     ENDIF
     IF ((djr_persons->error_count > 0))
      SET djr_temp_str = concat(djr_temp_str,", View All (E)rrors, Re(Q)ueue All Errored Jobs")
     ENDIF
     SET djr_temp_str = concat(djr_temp_str,", e(X)it")
     CALL text(24,1,djr_temp_str)
     SET accept = nopatcheck
     SET accept = time(30)
     CALL accept(23,17,"XXX;CUS","R")
     SET accept = patcheck
     SET accept = time(0)
     IF (curscroll=0)
      SET djr_input = trim(curaccept)
     ELSEIF (curscroll IN (1, 6))
      SET djr_input = "D"
     ELSEIF (curscroll IN (2, 5))
      SET djr_input = "U"
     ENDIF
     IF (djr_input="R")
      SET djr_return_ind = dxm_refresh_job_list(djr_persons)
      IF (djr_return_ind=1)
       RETURN(djr_return_ind)
      ENDIF
      SET djr_cnt = djr_persons->total
      SET djr_temp_pos = 1
     ELSEIF (djr_input="X")
      SET djr_input = "X"
     ELSEIF (djr_temp_pos > 1
      AND djr_input="U")
      SET djr_temp_pos = (djr_temp_pos - 13)
      SET djr_input = "R"
     ELSEIF (((djr_temp_pos+ 12) < djr_cnt)
      AND djr_input="D")
      SET djr_temp_pos = (djr_temp_pos+ 13)
      SET djr_input = "R"
     ELSEIF ((djr_persons->error_count > 0)
      AND djr_input="E")
      SET djr_return_ind = dxm_error_report(0.0,0.0)
      IF (djr_return_ind=1)
       RETURN(djr_return_ind)
      ENDIF
      SET djr_input = "R"
     ELSEIF ((djr_persons->error_count > 0)
      AND djr_input="Q")
      SET djr_return_ind = dxrc_requeue_errors(0.0,0.0)
      IF (djr_return_ind=1)
       CALL dxm_disp_status(1,"ReQueue Errors",dm_err->emsg)
       RETURN(djr_return_ind)
      ENDIF
      SET djr_input = "R"
      SET djr_return_ind = dxm_refresh_job_list(djr_persons)
      IF (djr_return_ind=1)
       RETURN(djr_return_ind)
      ENDIF
      SET djr_cnt = djr_persons->total
      SET djr_temp_pos = 1
     ELSEIF (isnumeric(djr_input)=1
      AND djr_cnt > 0)
      IF (cnvtint(djr_input) >= djr_temp_pos
       AND (cnvtint(djr_input) <= (djr_temp_pos+ 12)))
       SET djr_return_ind = dxm_extract_report(djr_persons->str_qual[cnvtint(djr_input)].job_id,
        djr_persons->str_qual[cnvtint(djr_input)].person_name)
       IF (djr_return_ind=1)
        RETURN(1)
       ENDIF
       SET djr_input = "R"
       SET djr_return_ind = dxm_refresh_job_list(djr_persons)
       IF (djr_return_ind=1)
        RETURN(djr_return_ind)
       ENDIF
       SET djr_cnt = djr_persons->total
       SET djr_temp_pos = 1
      ELSE
       CALL text(24,1,fillstring(120," "))
       CALL text(24,1,"***INVALID INPUT***")
       SET djr_input = "R"
      ENDIF
     ELSE
      CALL text(24,1,fillstring(120," "))
      CALL text(24,1,"***INVALID INPUT***")
      SET djr_input = "R"
     ENDIF
   ENDWHILE
   SET message = nowindow
   RETURN(djr_return_ind)
 END ;Subroutine
 SUBROUTINE dxm_extract_report(der_job_id,der_person_str)
   DECLARE der_input = vc WITH protect, noconstant("R")
   DECLARE der_header = vc WITH protect, constant(
    "*** EXTRACT AND TRANSFORM RETRIEVAL STATUS REPORT ***")
   DECLARE der_header_offset = i2 WITH protect, constant(ceil(((129 - size(der_header,1))/ 2)))
   DECLARE der_cnt = i4 WITH protect, noconstant(0)
   DECLARE der_loop = i4 WITH protect, noconstant(0)
   DECLARE der_temp_pos = i4 WITH protect, noconstant(0)
   DECLARE der_max = i4 WITH protect, noconstant(0)
   DECLARE der_temp_str = vc WITH protect, noconstant(" ")
   DECLARE der_return_ind = i2 WITH protect, noconstant(0)
   FREE RECORD der_extracts
   RECORD der_extracts(
     1 completed_count = i4
     1 error_count = i4
     1 total = i4
     1 qual[*]
       2 person_id = f8
       2 extract_name = vc
       2 status = vc
       2 start_time = vc
       2 stop_time = vc
       2 extract_id = f8
     1 str_qual[*]
       2 disp_line = vc
       2 extract_id = f8
       2 extract_name = vc
   )
   SET der_return_ind = dxm_refresh_extract_list(der_job_id,der_extracts)
   IF (der_return_ind=1)
    RETURN(der_return_ind)
   ENDIF
   SET der_cnt = der_extracts->total
   SET der_temp_pos = 1
   WHILE (der_input="R")
     SET message = window
     CALL clear(1,1)
     SET width = 132
     CALL text(1,der_header_offset,der_header)
     CALL text(3,1,concat("Report Created: ",format(cnvtdatetime(curdate,curtime3),
        "DD-MMM-YYYY HH:MM;;D")," (list will auto-refresh every 30 seconds)"))
     CALL text(4,1,concat("Person Name (ID): ",der_person_str))
     CALL text(5,1,concat("Extracts Completed: ",trim(cnvtstring(der_extracts->completed_count)),
       " out of ",trim(cnvtstring(der_extracts->total))," total"))
     CALL text(6,1,concat("Number of extracts with Errors: ",trim(cnvtstring(der_extracts->
         error_count))))
     CALL text(7,1,fillstring(122,"-"))
     IF (der_cnt > 0)
      CALL text(8,1,concat("No  Extract Name",fillstring(40," "),
        "Status      Extract PERSON_ID   Start Time",fillstring(9," "),"Stop Time"))
     ELSE
      CALL text(12,52,"No Extract Information Exists")
     ENDIF
     IF ((((der_cnt - der_temp_pos)+ 1) > 13))
      SET der_max = 13
     ELSE
      SET der_max = ((der_cnt - der_temp_pos)+ 1)
     ENDIF
     FOR (der_loop = 1 TO der_max)
       CALL text((der_loop+ 8),1,der_extracts->str_qual[((der_loop+ der_temp_pos) - 1)].disp_line)
     ENDFOR
     CALL text(22,1,fillstring(122,"-"))
     CALL text(23,1,"Command Options:")
     SET der_temp_str = "(R)efresh"
     IF (der_cnt > 13)
      IF (der_temp_pos > 1)
       SET der_temp_str = concat(der_temp_str,", Page (U)p")
      ENDIF
      IF (((der_temp_pos+ 12) < der_cnt))
       SET der_temp_str = concat(der_temp_str,", Page (D)own")
      ENDIF
     ENDIF
     IF (der_cnt > 0)
      IF (((der_temp_pos+ 12) < der_cnt))
       SET der_temp_str = concat(der_temp_str,", View Extract Details(",trim(cnvtstring(der_temp_pos)
         ),"-",trim(cnvtstring((der_temp_pos+ 12))),
        ")")
      ELSE
       SET der_temp_str = concat(der_temp_str,", View Extract Details(",trim(cnvtstring(der_temp_pos)
         ),"-",trim(cnvtstring(der_cnt)),
        ")")
      ENDIF
     ENDIF
     IF ((der_extracts->error_count > 0))
      SET der_temp_str = concat(der_temp_str,", View (E)rrors, Re(Q)ueue Errored Job")
     ENDIF
     SET der_temp_str = concat(der_temp_str,", e(X)it")
     CALL text(24,1,der_temp_str)
     SET accept = nopatcheck
     SET accept = time(30)
     CALL accept(23,17,"XXX;CUS","R")
     SET accept = patcheck
     SET accept = time(0)
     IF (curscroll=0)
      SET der_input = trim(curaccept)
     ELSEIF (curscroll IN (1, 6))
      SET der_input = "D"
     ELSEIF (curscroll IN (2, 5))
      SET der_input = "U"
     ENDIF
     IF (der_input="R")
      SET der_return_ind = dxm_refresh_extract_list(der_job_id,der_extracts)
      IF (der_return_ind=1)
       RETURN(der_return_ind)
      ENDIF
      SET der_cnt = der_extracts->total
      SET der_temp_pos = 1
     ELSEIF (der_input="X")
      SET der_input = "X"
     ELSEIF (der_temp_pos > 1
      AND der_input="U")
      SET der_temp_pos = (der_temp_pos - 13)
      SET der_input = "R"
     ELSEIF (((der_temp_pos+ 12) < der_cnt)
      AND der_input="D")
      SET der_temp_pos = (der_temp_pos+ 13)
      SET der_input = "R"
     ELSEIF ((der_extracts->error_count > 0)
      AND der_input="E")
      SET der_return_ind = dxm_error_report(der_job_id,0.0)
      IF (der_return_ind=1)
       RETURN(der_return_ind)
      ENDIF
      SET der_input = "R"
     ELSEIF ((der_extracts->error_count > 0)
      AND der_input="Q")
      SET der_return_ind = dxrc_requeue_errors(der_job_id,0.0)
      IF (der_return_ind=1)
       CALL dxm_disp_status(1,"ReQueue Errors",dm_err->emsg)
       RETURN(der_return_ind)
      ENDIF
      SET der_input = "R"
      SET der_return_ind = dxm_refresh_extract_list(der_job_id,der_extracts)
      IF (der_return_ind=1)
       RETURN(der_return_ind)
      ENDIF
      SET der_cnt = der_extracts->total
      SET der_temp_pos = 1
     ELSEIF (isnumeric(der_input)=1
      AND der_cnt > 0)
      IF (cnvtint(der_input) >= der_temp_pos
       AND (cnvtint(der_input) <= (der_temp_pos+ 12)))
       SET der_return_ind = dxm_detail_report(der_extracts->str_qual[cnvtint(der_input)].extract_id,
        der_extracts->str_qual[cnvtint(der_input)].extract_name)
       IF (der_return_ind=1)
        RETURN(1)
       ENDIF
       SET der_input = "R"
       SET der_return_ind = dxm_refresh_extract_list(der_job_id,der_extracts)
       IF (der_return_ind=1)
        RETURN(der_return_ind)
       ENDIF
       SET der_cnt = der_extracts->total
       SET der_temp_pos = 1
      ELSE
       CALL text(24,1,fillstring(120," "))
       CALL text(24,1,"***INVALID INPUT***")
       SET der_input = "R"
      ENDIF
     ELSE
      CALL text(24,1,fillstring(120," "))
      CALL text(24,1,"***INVALID INPUT***")
      SET der_input = "R"
     ENDIF
   ENDWHILE
   SET message = nowindow
   RETURN(der_return_ind)
 END ;Subroutine
 SUBROUTINE dxm_refresh_extract_list(drel_job_id,drel_extracts)
   DECLARE drel_loop = i4 WITH protect, noconstant(0)
   DECLARE drel_str_cnt = i4 WITH protect, noconstant(0)
   DECLARE drel_temp_pos = i4 WITH protect, noconstant(0)
   DECLARE drel_cnt = i4 WITH protect, noconstant(0)
   DECLARE drel_list_loop = i4 WITH protect, noconstant(0)
   DECLARE drel_offset = i2 WITH protect, noconstant(0)
   FREE RECORD drel_list
   RECORD drel_list(
     1 qual[7]
       2 status = vc
   )
   SET drel_list->qual[1].status = "ERROR"
   SET drel_list->qual[2].status = "RETRIEVE"
   SET drel_list->qual[3].status = "PARSE"
   SET drel_list->qual[4].status = "INSERT"
   SET drel_list->qual[5].status = "SYNCHRONIZE"
   SET drel_list->qual[6].status = "QUEUED"
   SET drel_list->qual[7].status = "FINISHED"
   SET drel_cnt = 0
   SET stat = alterlist(drel_extracts->qual,0)
   SET stat = alterlist(drel_extracts->str_qual,0)
   SET drel_extracts->completed_count = 0
   SET drel_extracts->error_count = 0
   SELECT INTO "NL:"
    FROM dm_xntr_extract d
    WHERE d.dm_xntr_job_id=drel_job_id
    ORDER BY d.status
    DETAIL
     IF (d.status="FINISHED")
      drel_extracts->completed_count = (drel_extracts->completed_count+ 1)
     ENDIF
     IF (d.status="ERROR")
      drel_extracts->error_count = (drel_extracts->error_count+ 1)
     ENDIF
     drel_cnt = (drel_cnt+ 1), stat = alterlist(drel_extracts->qual,drel_cnt), drel_extracts->qual[
     drel_cnt].person_id = d.extract_person_id,
     drel_extracts->qual[drel_cnt].status = d.status, drel_extracts->qual[drel_cnt].start_time =
     format(d.extract_start_dt_tm,"DD-MMM-YYYY HH:MM;;D"), drel_extracts->qual[drel_cnt].stop_time =
     format(d.extract_stop_dt_tm,"DD-MMM-YYYY HH:MM;;D"),
     drel_extracts->qual[drel_cnt].extract_name = substring(1,50,d.extract_name), drel_extracts->
     qual[drel_cnt].extract_id = d.dm_xntr_extract_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    CALL dxm_disp_status(1,"RETRIEVAL PROGRESS",dm_err->emsg)
    RETURN(1)
   ENDIF
   SET drel_extracts->total = drel_cnt
   SET stat = alterlist(drel_extracts->str_qual,drel_cnt)
   SET drel_str_cnt = 0
   FOR (drel_list_loop = 1 TO 7)
     FOR (drel_loop = 1 TO drel_cnt)
       IF ((drel_extracts->qual[drel_loop].status=drel_list->qual[drel_list_loop].status))
        SET drel_str_cnt = (drel_str_cnt+ 1)
        SET drel_temp_pos = (4 - size(trim(cnvtstring(drel_str_cnt))))
        SET drel_extracts->str_qual[drel_str_cnt].disp_line = concat(trim(cnvtstring(drel_str_cnt)),
         fillstring(value(drel_temp_pos)," "),drel_extracts->qual[drel_loop].extract_name)
        SET drel_temp_pos = (52 - size(drel_extracts->qual[drel_loop].extract_name))
        SET drel_extracts->str_qual[drel_str_cnt].disp_line = concat(drel_extracts->str_qual[
         drel_str_cnt].disp_line,fillstring(value(drel_temp_pos)," "),drel_extracts->qual[drel_loop].
         status)
        SET drel_temp_pos = (12 - size(drel_extracts->qual[drel_loop].status))
        SET drel_extracts->str_qual[drel_str_cnt].disp_line = notrim(concat(drel_extracts->str_qual[
          drel_str_cnt].disp_line,fillstring(value(drel_temp_pos)," ")))
        SET drel_temp_pos = (20 - size(trim(cnvtstring(drel_extracts->qual[drel_loop].person_id))))
        IF (((drel_temp_pos/ 2) != floor((drel_temp_pos/ 2))))
         SET drel_offset = 1
        ELSE
         SET drel_offset = 0
        ENDIF
        SET drel_temp_pos = floor((drel_temp_pos/ 2))
        SET drel_extracts->str_qual[drel_str_cnt].disp_line = notrim(concat(drel_extracts->str_qual[
          drel_str_cnt].disp_line,fillstring(value(drel_temp_pos)," "),trim(cnvtstring(drel_extracts
            ->qual[drel_loop].person_id))))
        SET drel_temp_pos = (drel_temp_pos+ drel_offset)
        SET drel_extracts->str_qual[drel_str_cnt].disp_line = notrim(concat(drel_extracts->str_qual[
          drel_str_cnt].disp_line,fillstring(value(drel_temp_pos)," "),drel_extracts->qual[drel_loop]
          .start_time))
        SET drel_temp_pos = (19 - size(drel_extracts->qual[drel_loop].start_time))
        SET drel_extracts->str_qual[drel_str_cnt].disp_line = notrim(concat(drel_extracts->str_qual[
          drel_str_cnt].disp_line,fillstring(value(drel_temp_pos)," "),drel_extracts->qual[drel_loop]
          .stop_time))
        SET drel_extracts->str_qual[drel_str_cnt].extract_id = drel_extracts->qual[drel_loop].
        extract_id
        SET drel_extracts->str_qual[drel_str_cnt].extract_name = drel_extracts->qual[drel_loop].
        extract_name
       ENDIF
     ENDFOR
   ENDFOR
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dxm_refresh_detail_list(drdl_extract_id,drdl_details)
   DECLARE drdl_loop = i4 WITH protect, noconstant(0)
   DECLARE drdl_str_cnt = i4 WITH protect, noconstant(0)
   DECLARE drdl_temp_pos = i4 WITH protect, noconstant(0)
   DECLARE drdl_cnt = i4 WITH protect, noconstant(0)
   DECLARE drdl_list_loop = i4 WITH protect, noconstant(0)
   FREE RECORD drdl_list
   RECORD drdl_list(
     1 qual[4]
       2 status = vc
   )
   SET drdl_list->qual[1].status = "RUNNING"
   SET drdl_list->qual[2].status = "ERROR"
   SET drdl_list->qual[3].status = "QUEUED"
   SET drdl_list->qual[4].status = "FINISHED"
   SET drdl_cnt = 0
   SET stat = alterlist(drdl_details->qual,0)
   SET stat = alterlist(drdl_details->str_qual,0)
   SET drdl_details->completed_count = 0
   SET drdl_details->error_count = 0
   SELECT INTO "NL:"
    FROM dm_xntr_detail d
    WHERE d.dm_xntr_extract_id=drdl_extract_id
    ORDER BY d.task_entity_name, sequence_nbr
    DETAIL
     IF (d.status="FINISHED")
      drdl_details->completed_count = (drdl_details->completed_count+ 1)
     ENDIF
     IF (d.status="ERROR")
      drdl_details->error_count = (drdl_details->error_count+ 1)
     ENDIF
     drdl_cnt = (drdl_cnt+ 1), stat = alterlist(drdl_details->qual,drdl_cnt), drdl_details->qual[
     drdl_cnt].task_entity_id = d.task_entity_id,
     drdl_details->qual[drdl_cnt].task_entity_name = d.task_entity_name, drdl_details->qual[drdl_cnt]
     .status = d.status, drdl_details->qual[drdl_cnt].start_time = format(d.start_dt_tm,
      "DD-MMM-YYYY HH:MM;;D"),
     drdl_details->qual[drdl_cnt].stop_time = format(d.end_dt_tm,"DD-MMM-YYYY HH:MM;;D")
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    CALL dxm_disp_status(1,"RETRIEVAL PROGRESS",dm_err->emsg)
    RETURN(1)
   ENDIF
   SET drdl_details->total = drdl_cnt
   SET stat = alterlist(drdl_details->str_qual,drdl_cnt)
   SET drdl_str_cnt = 0
   FOR (drdl_list_loop = 1 TO 4)
     FOR (drdl_loop = 1 TO drdl_cnt)
       IF ((drdl_details->qual[drdl_loop].status=drdl_list->qual[drdl_list_loop].status))
        SET drdl_str_cnt = (drdl_str_cnt+ 1)
        SET drdl_temp_pos = (33 - size(drdl_details->qual[drdl_loop].task_entity_name))
        SET drdl_details->str_qual[drdl_str_cnt].disp_line = concat(drdl_details->qual[drdl_loop].
         task_entity_name,fillstring(value(drdl_temp_pos)," "),trim(cnvtstring(drdl_details->qual[
           drdl_loop].task_entity_id)))
        SET drdl_temp_pos = (18 - size(trim(cnvtstring(drdl_details->qual[drdl_loop].task_entity_id))
         ))
        SET drdl_details->str_qual[drdl_str_cnt].disp_line = concat(drdl_details->str_qual[
         drdl_str_cnt].disp_line,fillstring(value(drdl_temp_pos)," "),drdl_details->qual[drdl_loop].
         status)
        SET drdl_temp_pos = (10 - size(drdl_details->qual[drdl_loop].status))
        SET drdl_details->str_qual[drdl_str_cnt].disp_line = notrim(concat(drdl_details->str_qual[
          drdl_str_cnt].disp_line,fillstring(value(drdl_temp_pos)," "),drdl_details->qual[drdl_loop].
          start_time))
        SET drdl_temp_pos = (20 - size(drdl_details->qual[drdl_loop].start_time))
        SET drdl_details->str_qual[drdl_str_cnt].disp_line = notrim(concat(drdl_details->str_qual[
          drdl_str_cnt].disp_line,fillstring(value(drdl_temp_pos)," "),drdl_details->qual[drdl_loop].
          stop_time))
       ENDIF
     ENDFOR
   ENDFOR
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dxm_detail_report(ddr_extract_id,ddr_extract_name)
   DECLARE ddr_input = vc WITH protect, noconstant("R")
   DECLARE ddr_header = vc WITH protect, constant(
    "*** EXTRACT AND TRANSFORM RETRIEVAL STATUS REPORT ***")
   DECLARE ddr_header_offset = i2 WITH protect, constant(ceil(((129 - size(ddr_header,1))/ 2)))
   DECLARE ddr_cnt = i4 WITH protect, noconstant(0)
   DECLARE ddr_loop = i4 WITH protect, noconstant(0)
   DECLARE ddr_temp_pos = i4 WITH protect, noconstant(0)
   DECLARE ddr_max = i4 WITH protect, noconstant(0)
   DECLARE ddr_temp_str = vc WITH protect, noconstant(" ")
   DECLARE ddr_return_ind = i2 WITH protect, noconstant(0)
   FREE RECORD ddr_details
   RECORD ddr_details(
     1 completed_count = i4
     1 error_count = i4
     1 total = i4
     1 qual[*]
       2 task_entity_id = f8
       2 task_entity_name = vc
       2 status = vc
       2 start_time = vc
       2 stop_time = vc
     1 str_qual[*]
       2 disp_line = vc
   )
   SET ddr_return_ind = dxm_refresh_detail_list(ddr_extract_id,ddr_details)
   IF (ddr_return_ind=1)
    RETURN(ddr_return_ind)
   ENDIF
   SET ddr_cnt = ddr_details->total
   SET ddr_temp_pos = 1
   WHILE (ddr_input="R")
     SET message = window
     CALL clear(1,1)
     SET width = 132
     CALL text(1,ddr_header_offset,ddr_header)
     CALL text(3,1,concat("Report Created: ",format(cnvtdatetime(curdate,curtime3),
        "DD-MMM-YYYY HH:MM;;D")," (list will auto-refresh every 30 seconds)"))
     CALL text(4,1,concat("Extract Name: ",ddr_extract_name))
     CALL text(5,1,concat("Tasks Completed: ",trim(cnvtstring(ddr_details->completed_count)),
       " out of ",trim(cnvtstring(ddr_details->total))," total"))
     CALL text(6,1,concat("Number of Tasks with Errors: ",trim(cnvtstring(ddr_details->error_count)))
      )
     CALL text(7,1,fillstring(120,"-"))
     IF (ddr_cnt > 0)
      CALL text(8,1,concat("Task Name",fillstring(24," "),"Task Identifier   Status    Start Time",
        fillstring(10," "),"Stop Time"))
     ELSE
      CALL text(12,53,"No Detail Information Exists")
     ENDIF
     IF ((((ddr_cnt - ddr_temp_pos)+ 1) > 13))
      SET ddr_max = 13
     ELSE
      SET ddr_max = ((ddr_cnt - ddr_temp_pos)+ 1)
     ENDIF
     FOR (ddr_loop = 1 TO ddr_max)
       CALL text((ddr_loop+ 8),1,ddr_details->str_qual[((ddr_loop+ ddr_temp_pos) - 1)].disp_line)
     ENDFOR
     CALL text(22,1,fillstring(120,"-"))
     CALL text(23,1,"Command Options:")
     SET ddr_temp_str = "(R)efresh"
     IF (ddr_cnt > 13)
      IF (ddr_temp_pos > 1)
       SET ddr_temp_str = concat(ddr_temp_str,", Page (U)p")
      ENDIF
      IF (((ddr_temp_pos+ 12) < ddr_cnt))
       SET ddr_temp_str = concat(ddr_temp_str,", Page (D)own")
      ENDIF
     ENDIF
     IF ((ddr_details->error_count > 0))
      SET ddr_temp_str = concat(ddr_temp_str,", View (E)rrors, Re(Q)ueue Errored Job")
     ENDIF
     SET ddr_temp_str = concat(ddr_temp_str,", e(X)it")
     CALL text(24,1,ddr_temp_str)
     SET accept = nopatcheck
     SET accept = time(30)
     CALL accept(23,17,"P;CUS","R"
      WHERE curaccept IN ("R", "X", "U", "D", "E",
      "Q"))
     SET accept = time(0)
     SET accept = patcheck
     IF (curscroll=0)
      SET ddr_input = trim(curaccept)
     ELSEIF (curscroll IN (1, 6))
      SET ddr_input = "D"
     ELSEIF (curscroll IN (2, 5))
      SET ddr_input = "U"
     ENDIF
     IF (ddr_input="R")
      SET ddr_return_ind = dxm_refresh_detail_list(ddr_extract_id,ddr_details)
      IF (ddr_return_ind=1)
       RETURN(ddr_return_ind)
      ENDIF
      SET ddr_cnt = ddr_details->total
      SET ddr_temp_pos = 1
     ELSEIF (ddr_input="X")
      SET ddr_input = "X"
     ELSEIF (ddr_temp_pos > 1
      AND ddr_input="U")
      SET ddr_temp_pos = (ddr_temp_pos - 13)
      SET ddr_input = "R"
     ELSEIF (((ddr_temp_pos+ 12) < ddr_cnt)
      AND ddr_input="D")
      SET ddr_temp_pos = (ddr_temp_pos+ 13)
      SET ddr_input = "R"
     ELSEIF ((ddr_details->error_count > 0)
      AND ddr_input="E")
      SET ddr_return_ind = dxm_error_report(0.0,ddr_extract_id)
      IF (ddr_return_ind=1)
       RETURN(ddr_return_ind)
      ENDIF
      SET ddr_input = "R"
      SET ddr_return_ind = dxm_refresh_detail_list(ddr_extract_id,ddr_details)
      IF (ddr_return_ind=1)
       RETURN(ddr_return_ind)
      ENDIF
      SET ddr_cnt = ddr_details->total
      SET ddr_temp_pos = 1
     ELSEIF ((ddr_details->error_count > 0)
      AND ddr_input="Q")
      SET ddr_return_ind = dxrc_requeue_errors(0.0,ddr_extract_id)
      IF (ddr_return_ind=1)
       CALL dxm_disp_status(1,"ReQueue Errors",dm_err->emsg)
       RETURN(ddr_return_ind)
      ENDIF
      SET ddr_input = "R"
      SET ddr_return_ind = dxm_refresh_detail_list(ddr_extract_id,ddr_details)
      IF (ddr_return_ind=1)
       RETURN(ddr_return_ind)
      ENDIF
      SET ddr_cnt = ddr_details->total
      SET ddr_temp_pos = 1
     ENDIF
   ENDWHILE
   SET message = nowindow
   RETURN(ddr_return_ind)
 END ;Subroutine
 SUBROUTINE dxm_error_report(der_job_error_id,der_extract_error_id)
   FREE RECORD der_job_list
   RECORD der_job_list(
     1 job_cnt = i4
     1 job_qual[*]
       2 job_id = f8
       2 person_id = f8
       2 person_name = vc
       2 message = vc
       2 log_file = vc
   )
   FREE RECORD der_list
   RECORD der_list(
     1 err_cnt = i4
     1 err_qual[*]
       2 job_id = f8
       2 person_id = f8
       2 person_name = vc
       2 extract_id = f8
       2 extract_name = vc
       2 detail_id = f8
       2 task_name = vc
       2 task_id = f8
       2 message = vc
       2 log_file = vc
       2 disp_ind = i2
   )
   DECLARE der_err_idx = i4 WITH protect, noconstant(0)
   DECLARE der_err_loop = i4 WITH protect, noconstant(0)
   DECLARE der_job_loop = i4 WITH protect, noconstant(0)
   DECLARE der_person = vc WITH protect, noconstant("")
   SELECT INTO "NL:"
    FROM dm_xntr_job d,
     person p
    WHERE d.status="ERROR"
     AND p.person_id=outerjoin(d.person_id)
    DETAIL
     der_job_list->job_cnt = (der_job_list->job_cnt+ 1), stat = alterlist(der_job_list->job_qual,
      der_job_list->job_cnt), der_job_list->job_qual[der_job_list->job_cnt].job_id = d.dm_xntr_job_id,
     der_job_list->job_qual[der_job_list->job_cnt].person_id = d.person_id, der_job_list->job_qual[
     der_job_list->job_cnt].message = d.status_msg, der_job_list->job_qual[der_job_list->job_cnt].
     log_file = d.log_file
     IF (trim(p.name_first_key) != ""
      AND trim(p.name_last_key) != "")
      der_job_list->job_qual[der_job_list->job_cnt].person_name = concat(trim(substring(1,1,p
         .name_first_key)),". ",trim(substring(1,30,p.name_last_key)))
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    CALL dxm_disp_status(1,"VIEW ERRORS REPORT",dm_err->emsg)
    RETURN(1)
   ENDIF
   FOR (der_job_loop = 1 TO der_job_list->job_cnt)
     SELECT INTO "NL:"
      FROM dm_xntr_extract d
      WHERE d.status="ERROR"
       AND (d.dm_xntr_job_id=der_job_list->job_qual[der_job_loop].job_id)
      DETAIL
       der_list->err_cnt = (der_list->err_cnt+ 1), stat = alterlist(der_list->err_qual,der_list->
        err_cnt), der_list->err_qual[der_list->err_cnt].job_id = der_job_list->job_qual[der_job_loop]
       .job_id,
       der_list->err_qual[der_list->err_cnt].person_id = der_job_list->job_qual[der_job_loop].
       person_id, der_list->err_qual[der_list->err_cnt].person_name = der_job_list->job_qual[
       der_job_loop].person_name, der_list->err_qual[der_list->err_cnt].message = der_job_list->
       job_qual[der_job_loop].message,
       der_list->err_qual[der_list->err_cnt].log_file = der_job_list->job_qual[der_job_loop].log_file,
       der_list->err_qual[der_list->err_cnt].extract_id = d.dm_xntr_extract_id, der_list->err_qual[
       der_list->err_cnt].extract_name = trim(substring(1,50,d.extract_name)),
       der_list->err_qual[der_list->err_cnt].message = d.status_msg
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      CALL dxm_disp_status(1,"VIEW ERRORS REPORT",dm_err->emsg)
      RETURN(1)
     ENDIF
     IF (curqual=0)
      SET der_list->err_cnt = (der_list->err_cnt+ 1)
      SET stat = alterlist(der_list->err_qual,der_list->err_cnt)
      SET der_list->err_qual[der_list->err_cnt].job_id = der_job_list->job_qual[der_job_loop].job_id
      SET der_list->err_qual[der_list->err_cnt].person_id = der_job_list->job_qual[der_job_loop].
      person_id
      SET der_list->err_qual[der_list->err_cnt].person_name = der_job_list->job_qual[der_job_loop].
      person_name
      SET der_list->err_qual[der_list->err_cnt].message = der_job_list->job_qual[der_job_loop].
      message
      SET der_list->err_qual[der_list->err_cnt].log_file = der_job_list->job_qual[der_job_loop].
      log_file
      SET der_list->err_qual[der_list->err_cnt].extract_name = "Not Available"
     ENDIF
   ENDFOR
   FOR (der_err_loop = 1 TO der_list->err_cnt)
     IF ((der_list->err_qual[der_err_loop].extract_name="Not Available"))
      SET der_list->err_qual[der_err_loop].task_name = "Not Available"
     ELSE
      SELECT INTO "NL:"
       FROM dm_xntr_detail d
       WHERE d.status="ERROR"
        AND (d.dm_xntr_extract_id=der_list->err_qual[der_err_loop].extract_id)
       DETAIL
        der_list->err_qual[der_err_loop].detail_id = d.dm_xntr_detail_id, der_list->err_qual[
        der_err_loop].message = d.status_msg, der_list->err_qual[der_err_loop].task_name = d
        .task_entity_name,
        der_list->err_qual[der_err_loop].task_id = d.task_entity_id
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       CALL dxm_disp_status(1,"VIEW ERRORS REPORT",dm_err->emsg)
       RETURN(1)
      ENDIF
      IF (curqual=0)
       SET der_list->err_qual[der_err_loop].task_name = "Not Available"
      ENDIF
     ENDIF
   ENDFOR
   FOR (der_err_loop = 1 TO der_list->err_cnt)
     IF (der_job_error_id=0.0
      AND der_extract_error_id=0.0)
      SET der_list->err_qual[der_err_loop].disp_ind = 1
     ELSEIF (der_extract_error_id > 0.0)
      IF ((der_list->err_qual[der_err_loop].extract_id=der_extract_error_id))
       SET der_list->err_qual[der_err_loop].disp_ind = 1
      ENDIF
     ELSEIF (der_job_error_id > 0.0)
      IF ((der_list->err_qual[der_err_loop].job_id=der_job_error_id))
       SET der_list->err_qual[der_err_loop].disp_ind = 1
      ENDIF
     ENDIF
   ENDFOR
   SELECT INTO "MINE"
    FROM (dummyt d  WITH seq = der_list->err_cnt)
    WHERE (der_list->err_qual[d.seq].disp_ind=1)
    DETAIL
     col 1, "PERSON (ID): "
     IF ((der_list->err_qual[d.seq].person_name != ""))
      der_list->err_qual[d.seq].person_name, col + 1
     ENDIF
     der_person = concat("(",trim(cnvtstring(der_list->err_qual[d.seq].person_id)),")"), der_person,
     col 65,
     "Log File: ", der_list->err_qual[d.seq].log_file, row + 1,
     col 1, "Extract Name: ", der_list->err_qual[d.seq].extract_name,
     col 65, "Task Information: ", der_list->err_qual[d.seq].task_name
     IF ((der_list->err_qual[d.seq].task_id > 0.0))
      col + 2, der_list->err_qual[d.seq].task_id
     ENDIF
     row + 1, col 1, "Error: ",
     der_list->err_qual[d.seq].message, row + 1, der_person = fillstring(125,"-"),
     der_person, row + 2
    WITH nocounter, maxcol = 500
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    CALL dxm_disp_status(1,"VIEW ERRORS REPORT",dm_err->emsg)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dxm_start_process(null)
   DECLARE dsp_cnt = i4 WITH protect, noconstant(0)
   DECLARE dsp_cur_log = vc WITH protect, noconstant("")
   DECLARE dsp_nohup_log = vc WITH protect, noconstant("")
   DECLARE dsp_execute_str = vc WITH protect, noconstant("")
   DECLARE dsp_dcl_stat = i4 WITH protect, noconstant(0)
   DECLARE dsp_return = i2 WITH protect, noconstant(0)
   FREE RECORD dsp_signon
   RECORD dsp_signon(
     1 dsp_password = vc
     1 dsp_user = vc
     1 dsp_env = vc
   )
   SELECT INTO "NL:"
    cnt = count(*)
    FROM dm_xntr_job j
    WHERE j.status="RUNNING"
     AND  EXISTS (
    (SELECT
     "x"
     FROM gv$session gv
     WHERE gv.audsid=cnvtreal(j.audit_sid)))
    DETAIL
     dsp_cnt = cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    CALL dxm_disp_status(1,"Start Retrieval Process",dm_err->emsg)
    RETURN(1)
   ENDIF
   IF (dsp_cnt > 0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg =
    "Retrieval process can not be started while another retrieval process is already running."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    CALL dxm_disp_status(1,"Start Retrieval Process",dm_err->emsg)
    RETURN(1)
   ENDIF
   IF (((checkprg("DM2_XNT_DM_RETRIEVE_XML")=0) OR (checkprg("DM2_XNT_DM_REMOVE_XML")=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->emsg =
    "There are scripts required by the retrieval process that do not exist in the CCL Dictionary."
    CALL dxm_disp_status(1,"Start Retrieval Process",dm_err->emsg)
    RETURN(1)
   ENDIF
   SET dsp_return = dxm_get_connect_info(dsp_signon)
   IF (dsp_return=1)
    RETURN(1)
   ENDIF
   SET dsp_cur_log = dm_err->unique_fname
   IF (get_unique_file("xntr_run_retrieve",".log")=0)
    SET nohup_submit_logfile = "xntr_run_retrieve.log"
    SET dm_err->err_ind = 0
   ELSE
    SET dsp_nohup_log = dm_err->unique_fname
   ENDIF
   SET dm_err->unique_fname = dsp_cur_log
   SET dsp_execute_str = concat("nohup $cer_proc/xntr_run_retrieve.ksh ",dsp_signon->dsp_password," ",
    dsp_signon->dsp_env," ",
    dsp_signon->dsp_user," > $CCLUSERDIR/",dsp_nohup_log," 2>&1 &")
   CALL dcl(dsp_execute_str,size(dsp_execute_str),dsp_dcl_stat)
   IF (dsp_dcl_stat=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Error connecting to: ",dsp_dcl_stat)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    CALL dxm_disp_status(1,"Start Retrieval Process",dm_err->emsg)
    RETURN(1)
   ENDIF
   CALL dxm_disp_status(0,"Start Retrieval Process",
    "The retrieval process has successfully been started.")
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dxm_stop_process(null)
   UPDATE  FROM dm_info d
    SET d.info_date = cnvtdatetime(curdate,curtime3), d.updt_cnt = (d.updt_cnt+ 1), d.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->
     updt_applctx
    WHERE d.info_domain="DATA MANAGEMENT"
     AND d.info_name="XNTR STOP TIME"
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    CALL dxm_disp_status(1,"Stop Retrieval Process",dm_err->emsg)
    RETURN(1)
   ENDIF
   IF (curqual=0)
    INSERT  FROM dm_info d
     SET d.info_domain = "DATA MANAGEMENT", d.info_name = "XNTR STOP TIME", d.info_date =
      cnvtdatetime(curdate,curtime3),
      d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_id = reqinfo->updt_id, d.updt_task =
      reqinfo->updt_task,
      d.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     CALL dxm_disp_status(1,"Stop Retrieval Process",dm_err->emsg)
     RETURN(1)
    ENDIF
   ENDIF
   COMMIT
   CALL dxm_disp_status(0,"Stop Retrieval Process",
    "The retrieval process has successfully been marked to stop.")
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dxm_get_connect_info(dgci_signon)
   DECLARE dgci_env = vc WITH protect, noconstant("")
   DECLARE dgci_env2 = vc WITH protect, noconstant("")
   DECLARE dgci_find = i4 WITH protect, noconstant(0)
   DECLARE dgci_valid = i4 WITH protect, noconstant(0)
   WHILE (dgci_valid=0)
     SET message = window
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,6,132)
     CALL text(3,44,"***  EXTRACT AND TRANSFORM RETRIEVAL MENU  ***")
     CALL text(4,52,"CCL SECURITY LOGIN INFORMATION")
     CALL text(5,75,"ENVIRONMENT ID:")
     CALL text(5,20,"ENVIRONMENT NAME:")
     CALL text(5,95,cnvtstring(dxm_env_id))
     CALL text(5,40,dxm_env_name)
     CALL text(8,3,"Input user name for CCL Security Login: ")
     CALL text(9,3,"Input environment name for CCL Security Login: ")
     CALL text(10,3,"Input password for CCL Security Login: ")
     CALL text(11,3,
      "Hit PF3 or RETURN to skip credential information.  The XNT Retrieval process won't be allowed to start."
      )
     CALL accept(8,50,"p(30);c"," ")
     SET dgci_signon->dsp_user = curaccept
     IF (trim(dgci_signon->dsp_user)="")
      RETURN(1)
     ENDIF
     CALL accept(9,50,"p(30);c"," ")
     SET dgci_signon->dsp_env = curaccept
     CALL accept(10,50,"p(30);ce"," ")
     SET dgci_signon->dsp_password = curaccept
     SET dgci_env = cnvtupper(logical("environment"))
     SET dgci_signon->dsp_env = cnvtupper(dgci_signon->dsp_env)
     IF ((dgci_signon->dsp_env != dgci_env))
      SET dgci_find = findstring("_",dgci_signon->dsp_env,1)
      IF (dgci_find > 0)
       SET dgci_env2 = substring(1,(dgci_find - 1),dgci_signon->dsp_env)
      ENDIF
     ENDIF
     SET stat = 0
     IF ((((dgci_signon->dsp_env=dgci_env)) OR (dgci_env2=dgci_env)) )
      SET xxcclseclogin->loggedin = 0
      EXECUTE cclseclogin2 dgci_signon->dsp_user, dgci_signon->dsp_env, dgci_signon->dsp_password
      IF ((xxcclseclogin->loggedin=1))
       CALL text(10,10,"SUCCESS")
       SET dgci_valid = 1
      ELSE
       CALL dxm_disp_status(1,"Start Retrieval Process",build("CCL Security Login Failure status = ",
         stat))
      ENDIF
     ELSE
      CALL dxm_disp_status(1,"Start Retrieval Process",build("CCL Security Login Failure (Domain= ",
        dgci_signon->dsp_env," does not match current Environment= ",dgci_env,"."))
     ENDIF
     IF (dgci_valid=0)
      CALL clear(1,1)
      SET width = 132
      CALL box(1,1,6,132)
      CALL text(3,44,"***  EXTRACT AND TRANSFORM RETRIEVAL MENU  ***")
      CALL text(4,52,"CCL SECURITY LOGIN INFORMATION")
      CALL text(5,75,"ENVIRONMENT ID:")
      CALL text(5,20,"ENVIRONMENT NAME:")
      CALL text(5,95,cnvtstring(dxm_env_id))
      CALL text(5,40,dxm_env_name)
      CALL text(8,3,"Retry (Y/N) ")
      CALL text(9,3,"Choosing 'N' will prohibit the starting of an XNT Retrieval Process")
      CALL accept(8,16,"p;cu","Y"
       WHERE curaccept IN ("Y", "N"))
      IF (curaccept != "Y")
       RETURN(1)
      ENDIF
     ENDIF
   ENDWHILE
   RETURN(0)
 END ;Subroutine
END GO
