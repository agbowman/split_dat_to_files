CREATE PROGRAM dm2_tspace_menu:dba
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
 IF ((validate(dmt_min_ext_size,- (1))=- (1)))
  DECLARE dmt_min_ext_size = f8 WITH public, constant(163840.0)
 ENDIF
 IF ((validate(dm2_block_size,- (1))=- (1))
  AND (validate(dm2_block_size,- (2))=- (2)))
  IF (currdb="ORACLE")
   DECLARE dm2_block_size = f8 WITH public, constant(8192.0)
  ELSEIF (currdb="DB2UDB")
   DECLARE dm2_block_size = f8 WITH public, constant(16384.0)
  ELSE
   DECLARE dm2_block_size = f8 WITH public, constant(8192.0)
  ENDIF
 ENDIF
 IF ((validate(rtspace->rtspace_cnt,- (1))=- (1)))
  FREE RECORD rtspace
  RECORD rtspace(
    1 dbname = vc
    1 tmp_table_name = vc
    1 rtspace_cnt = i4
    1 sql_size_mb = f8
    1 sql_filegrowth_mb = f8
    1 install_type = vc
    1 install_type_value = vc
    1 mode = vc
    1 ddl_report_fname = vc
    1 commands_written_ind = i2
    1 database_remote = i2
    1 unique_nbr = vc
    1 temp_tspace_name = vc
    1 temp_tspace_file_type = vc
    1 temp_tspace_ttl_mb = i4
    1 temp_tspace_reserved_pct = i4
    1 temp_tspace_reserved_mb = i4
    1 temp_tspace_ttl_needed_mb = i4
    1 temp_tspace_ratio = f8
    1 temp_tspace_indexlist[*]
      2 tbl_name = vc
      2 ind_name = vc
      2 size_mb = i4
    1 qual[*]
      2 tspace_name = vc
      2 chunk_size = f8
      2 chunks_needed = i4
      2 ext_mgmt = c1
      2 tspace_id = i4
      2 cur_bytes_allocated = f8
      2 bytes_needed = f8
      2 user_bytes_to_add = f8
      2 final_bytes_to_add = f8
      2 new_ind = i2
      2 extend_ind = i2
      2 init_ext = f8
      2 next_ext = f8
      2 cont_complete_ind = i4
      2 cont_cnt = i4
      2 ct_err_msg = vc
      2 ct_err_ind = i2
      2 asm_disk_group = vc
      2 commands[*]
        3 cmd_type = vc
        3 cmd = vc
        3 lv_file = vc
        3 lv_exist_chk = i2
      2 cont[*]
        3 volume_label = vc
        3 disk_name = vc
        3 disk_idx = i4
        3 vg_name = vc
        3 pp_size_mb = f8
        3 pps_to_add = f8
        3 add_ext_ind = c1
        3 cont_tspace_rel_key = i4
        3 space_to_add = f8
        3 delete_ind = i2
        3 cont_size_mb = f8
        3 lv_file = vc
        3 new_ind = i2
        3 mwc_flag = i2
      2 temp_ind = i2
      2 user_tspace_ind = i2
  )
  SET rtspace->install_type = "DM2NOTSET"
  SET rtspace->install_type_value = "DM2NOTSET"
  SET rtspace->mode = "DM2NOTSET"
  SET rtspace->ddl_report_fname = "DM2NOTSET"
  SET rtspace->unique_nbr = ""
 ENDIF
 IF ((validate(ddtsp->tsp_cnt,- (1))=- (1)))
  FREE RECORD ddtsp
  RECORD ddtsp(
    1 nonstd_ind = i2
    1 nonstd_tgt_ind = i2
    1 tsp_cnt = i4
    1 qual[*]
      2 tspace_name = vc
      2 ext_mgmt = c1
      2 alloc_type = vc
      2 seg_space_mgmt = vc
      2 bigfile = c3
      2 nonstd_ind = i2
      2 nonstd_tgt_ind = i2
      2 lmt_ora8_ind = i2
      2 lmt_uniform_ind = i2
      2 lmt_and_not_assm = i2
      2 lmt_bigfile = i2
      2 datafile_not_ae = i2
      2 datafile_not_unlimited = i2
      2 datafile_not_assm = i2
      2 lmt_and_not_ae = i2
  )
  SET ddtsp->nonstd_ind = 0
  SET ddtsp->nonstd_tgt_ind = 0
 ENDIF
 IF ((validate(dm2_ind_tspace_assign->cnt,- (1))=- (1)))
  FREE SET dm2_ind_tspace_assign
  RECORD dm2_ind_tspace_assign(
    1 cnt = i4
    1 qual[*]
      2 table_name = vc
      2 index_tspace = vc
      2 index_tspace_cnt = i4
      2 tspace_cnt = i4
      2 tspace[*]
        3 tspace_name = vc
        3 ind_cnt = i4
  )
  SET dm2_ind_tspace_assign->cnt = 0
 ENDIF
 IF ((validate(das_dtp->dtp_cnt,- (1))=- (1)))
  FREE RECORD das_dtp
  RECORD das_dtp(
    1 dtp_cnt = i4
    1 qual[*]
      2 tname = vc
      2 prec_cnt = i2
      2 prec[*]
        3 precedence = i2
        3 data_tspace = vc
        3 data_extent_size = f8
        3 ind_tspace = vc
        3 index_extent_size = f8
        3 long_tspace = vc
  )
  SET das_dtp->dtp_cnt = 0
 ENDIF
 IF ((validate(dtr_tspace_misc->recalc_space_needs,- (1))=- (1))
  AND (validate(dtr_tspace_misc->recalc_space_needs,- (2))=- (2)))
  FREE RECORD dtr_tspace_misc
  RECORD dtr_tspace_misc(
    1 recalc_space_needs = i2
    1 gen_id = f8
  )
  SET dtr_tspace_misc->recalc_space_needs = 0
  SET dtr_tspace_misc->gen_id = 0.0
 ENDIF
 IF ((validate(dtrt->cnt,- (1))=- (1)))
  FREE RECORD dtrt
  RECORD dtrt(
    1 cnt = i4
    1 qual[*]
      2 tspace_name = vc
  )
  SET dtrt->cnt = 0
 ENDIF
 IF ((validate(dcs_long_tspace->tspace_count,- (1))=- (1)))
  FREE SET dcs_long_tspace
  RECORD dcs_long_tspace(
    1 tspace_count = i4
    1 tspace[*]
      2 tspace_name = vc
      2 bytes = f8
      2 tbl_cnt = i4
      2 tbl[*]
        3 table_name = vc
        3 column_name = vc
  )
  SET dcs_long_tspace->tspace_count = 0
 ENDIF
 DECLARE dtr_lob_size = f8 WITH protect, constant(163840.0)
 DECLARE dtr_load_tspaces(dlt_process=vc) = i2
 DECLARE dtr_rpt_nonstd_tspace(drnt_file=vc,drnt_mode=i2) = i2
 DECLARE dtr_find_tspace(dft_tspace=vc) = i2
 DECLARE dtr_eval_nonstd_tgt_tspace(sbr_tsp_idx=i4) = i2
 DECLARE d2tr_get_man_inst_type_val(null) = i2
 DECLARE dm2_adj_size(d_adj_size=f8,d_adj_mult=f8) = f8
 DECLARE dm2_adj_init_next_ext(daine_data_to_move=vc,daine_table_type=i2,daine_table_name=vc,
  daine_init_ext=f8(ref),daine_next_ext=f8(ref)) = null
 DECLARE dtr_load_clin_tspaces(null) = i2
 SUBROUTINE dm2_adj_size(d_adj_size,d_adj_mult)
   DECLARE das_ceil_factor = f8 WITH protect, noconstant(0.0)
   DECLARE das_ret = f8 WITH protect, noconstant(0.0)
   IF (d_adj_mult > 0.0)
    SET das_ceil_factor = dm2ceil((d_adj_size/ d_adj_mult))
    SET das_ret = (d_adj_mult * das_ceil_factor)
   ELSE
    SET das_ret = d_adj_size
   ENDIF
   RETURN(das_ret)
 END ;Subroutine
 SUBROUTINE d2tr_get_man_inst_type_val(null)
   DECLARE dgmitv_info_num_hold = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Getting Manual Install_Type_Value from DM_INFO."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_TSPACE_SIZE-MAX VALUE"
     AND d.info_name="MANUAL"
    DETAIL
     dgmitv_info_num_hold = d.info_number
    WITH forupdatewait(d)
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   CASE (curqual)
    OF 1:
     SET rtspace->install_type_value = cnvtstring((dgmitv_info_num_hold+ 1))
     SET dm_err->eproc = concat("Updating Manual Install_Type_Value in DM_INFO to:",rtspace->
      install_type_value)
     CALL disp_msg("",dm_err->logfile,0)
     UPDATE  FROM dm_info d
      SET d.info_number = cnvtint(rtspace->install_type_value)
      WHERE d.info_domain="DM2_TSPACE_SIZE-MAX VALUE"
       AND d.info_name="MANUAL"
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
    OF 0:
     SET rtspace->install_type_value = "1"
     SET dm_err->eproc = "Inserting Manual Install_Type_Value into DM_INFO."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
     INSERT  FROM dm_info d
      SET d.info_domain = "DM2_TSPACE_SIZE-MAX VALUE", d.info_name = "MANUAL", d.info_number =
       cnvtint(rtspace->install_type_value)
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_find_tspace(dft_tspace)
   DECLARE dft_idx = i4 WITH protect, noconstant(0)
   SET dft_idx = locateval(dft_idx,1,ddtsp->tsp_cnt,dft_tspace,ddtsp->qual[dft_idx].tspace_name)
   RETURN(dft_idx)
 END ;Subroutine
 SUBROUTINE dtr_rpt_nonstd_tspace(drnt_file,drnt_mode)
   DECLARE drnt_nonstd_found = i2 WITH protect, noconstant(0)
   SELECT
    IF (drnt_mode=0)
     FROM (dummyt d  WITH seq = ddtsp->tsp_cnt)
     WHERE (ddtsp->qual[d.seq].nonstd_tgt_ind=1)
    ELSE
     FROM (dummyt d  WITH seq = ddtsp->tsp_cnt)
     WHERE (ddtsp->qual[d.seq].nonstd_ind=1)
    ENDIF
    INTO value(drnt_file)
    HEAD REPORT
     row + 2,
     CALL center("Unsupported Tablespace Configuration Report",1,126), row + 2,
     col 1,
     "The following tablespaces have been found with an unsupported configuration in the current database.",
     row + 2
    DETAIL
     col 1, "Tablespace Name:", col 20,
     ddtsp->qual[d.seq].tspace_name, row + 1, col 11,
     "Issue:"
     IF ((ddtsp->qual[d.seq].lmt_ora8_ind=1))
      col 20, "Tablespace is locally managed on Oracle 8", row + 1,
      drnt_nonstd_found = 1
     ENDIF
     IF ((ddtsp->qual[d.seq].lmt_uniform_ind=1))
      col 20, "Tablespace is locally managed with uniform extents", row + 1,
      drnt_nonstd_found = 1
     ENDIF
     IF ((ddtsp->qual[d.seq].lmt_and_not_assm=1))
      col 20, "Tablespace is locally managed without automatic segment-space management", row + 1,
      drnt_nonstd_found = 1
     ENDIF
     IF ((ddtsp->qual[d.seq].datafile_not_ae=1))
      col 20, "Tablespace contains datafiles that are not autoextensible", row + 1,
      drnt_nonstd_found = 1
     ENDIF
     IF (ddtsp->qual[d.seq].datafile_not_unlimited)
      col 20, "Tablespace contains datafiles defined with a limited maxsize (not UNLIMITED)", row + 1,
      drnt_nonstd_found = 1
     ENDIF
     row + 2
    FOOT REPORT
     IF (drnt_nonstd_found=0)
      col 1, "No unsupported tablespaces returned.", row + 1
     ENDIF
    WITH nocounter, format = variable, nullreport,
     formfeed = none, maxcol = 512, append
   ;end select
   IF (check_error("Displaying Unsupported Tablespace Configuration Report") != 0)
    CALL disp_msg(" ",dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_eval_nonstd_tgt_tspace(sbr_tsp_idx)
  IF ((ddtsp->qual[sbr_tsp_idx].nonstd_ind=1))
   SET ddtsp->qual[sbr_tsp_idx].nonstd_tgt_ind = 1
   SET ddtsp->nonstd_tgt_ind = 1
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_adj_init_next_ext(daine_data_to_move,daine_table_type,daine_table_name,daine_init_ext,
  daine_next_ext)
   IF (daine_next_ext=0.0)
    SET daine_init_ext = 0.0
   ENDIF
   IF (daine_data_to_move="REF"
    AND daine_table_type=0
    AND daine_init_ext > 0.0)
    SET daine_init_ext = dmt_min_ext_size
   ENDIF
   IF (((daine_data_to_move="REF"
    AND daine_table_type IN (1, 2)) OR (daine_data_to_move="ALL"))
    AND daine_init_ext > 0.0
    AND (daine_init_ext > (5 * dm2_block_size)))
    SET daine_init_ext = dm2_adj_size(daine_init_ext,(5 * dm2_block_size))
   ENDIF
   IF (daine_data_to_move="REF"
    AND daine_table_type=0
    AND daine_next_ext > 0.0)
    SET daine_next_ext = dmt_min_ext_size
   ENDIF
   IF (((daine_data_to_move="REF"
    AND daine_table_type IN (1, 2)) OR (daine_data_to_move="ALL"))
    AND daine_next_ext > 0.0
    AND (daine_next_ext > (5 * dm2_block_size)))
    SET daine_next_ext = dm2_adj_size(daine_next_ext,(5 * dm2_block_size))
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE dtr_load_tspaces(dlt_process)
   DECLARE dlt_fatal_error = i2 WITH protect, noconstant(0)
   DECLARE dlt_ndx = i2 WITH protect, noconstant(0)
   DECLARE dlt_31g = f8 WITH protect, noconstant((((31.0 * 1024.0) * 1024.0) * 1024.0))
   IF (dm2_get_rdbms_version(null)=0)
    GO TO exit_script
   ENDIF
   SET dm_err->eproc = "Load tablespace content."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT
    IF (dlt_process="CLIN COPY")
     FROM dm2_dba_tablespaces dbt
    ELSEIF (dlt_process="REPORT")
     FROM dm2_dba_tablespaces dbt
     WHERE dbt.tablespace_name != "SYSTEM"
      AND  NOT (dbt.contents IN ("UNDO", "TEMPORARY"))
    ELSEIF ( NOT (currdbuser IN ("V500", "CDBA")))
     FROM dm2_dba_tablespaces dbt
     WHERE ((dbt.status = null) OR (dbt.status != "OFFLINE"))
    ELSE
     FROM dm2_dba_tablespaces dbt
     WHERE ((dbt.status = null) OR (dbt.status != "OFFLINE"))
      AND substring(1,2,dbt.tablespace_name) IN ("D_", "I_", "L_")
    ENDIF
    INTO "nl:"
    HEAD REPORT
     ddtsp->nonstd_ind = 0, ddtsp->nonstd_tgt_ind = 0, ddtsp->tsp_cnt = 0
    DETAIL
     IF (dlt_fatal_error=0)
      ddtsp->tsp_cnt = (ddtsp->tsp_cnt+ 1)
      IF (mod(ddtsp->tsp_cnt,50)=1)
       stat = alterlist(ddtsp->qual,(ddtsp->tsp_cnt+ 49))
      ENDIF
      CASE (trim(dbt.extent_management))
       OF "DICTIONARY":
        ddtsp->qual[ddtsp->tsp_cnt].ext_mgmt = "D"
       OF "LOCAL":
        ddtsp->qual[ddtsp->tsp_cnt].ext_mgmt = "L"
       ELSE
        ddtsp->qual[ddtsp->tsp_cnt].ext_mgmt = " ",
        IF (currdb="ORACLE")
         dlt_fatal_error = 1
        ENDIF
      ENDCASE
      ddtsp->qual[ddtsp->tsp_cnt].tspace_name = trim(dbt.tablespace_name), ddtsp->qual[ddtsp->tsp_cnt
      ].alloc_type = trim(dbt.allocation_type), ddtsp->qual[ddtsp->tsp_cnt].seg_space_mgmt = dbt
      .segment_space_management,
      ddtsp->qual[ddtsp->tsp_cnt].nonstd_ind = 0, ddtsp->qual[ddtsp->tsp_cnt].nonstd_tgt_ind = 0,
      ddtsp->qual[ddtsp->tsp_cnt].lmt_ora8_ind = 0,
      ddtsp->qual[ddtsp->tsp_cnt].lmt_uniform_ind = 0, ddtsp->qual[ddtsp->tsp_cnt].lmt_and_not_assm
       = 0, ddtsp->qual[ddtsp->tsp_cnt].lmt_uniform_ind = 0,
      ddtsp->qual[ddtsp->tsp_cnt].lmt_bigfile = 0, ddtsp->qual[ddtsp->tsp_cnt].datafile_not_assm = 0,
      ddtsp->qual[ddtsp->tsp_cnt].datafile_not_unlimited = 0,
      ddtsp->qual[ddtsp->tsp_cnt].lmt_and_not_ae = 0
      IF ((ddtsp->qual[ddtsp->tsp_cnt].ext_mgmt="L")
       AND (dm2_rdbms_version->level1=8))
       ddtsp->qual[ddtsp->tsp_cnt].nonstd_ind = 1, ddtsp->qual[ddtsp->tsp_cnt].lmt_ora8_ind = 1,
       ddtsp->nonstd_ind = 1
      ENDIF
      IF ((ddtsp->qual[ddtsp->tsp_cnt].ext_mgmt="L")
       AND (ddtsp->qual[ddtsp->tsp_cnt].alloc_type="UNIFORM"))
       ddtsp->qual[ddtsp->tsp_cnt].nonstd_ind = 1, ddtsp->qual[ddtsp->tsp_cnt].lmt_uniform_ind = 1,
       ddtsp->nonstd_ind = 1
      ENDIF
      IF ((ddtsp->qual[ddtsp->tsp_cnt].ext_mgmt="L")
       AND (ddtsp->qual[ddtsp->tsp_cnt].seg_space_mgmt != "AUTO"))
       ddtsp->qual[ddtsp->tsp_cnt].lmt_and_not_assm = 1, ddtsp->qual[ddtsp->tsp_cnt].nonstd_ind = 1,
       ddtsp->nonstd_ind = 1
      ENDIF
      IF ((ddtsp->qual[ddtsp->tsp_cnt].ext_mgmt="L")
       AND dbt.bigfile="YES")
       ddtsp->qual[ddtsp->tsp_cnt].lmt_bigfile = 1, ddtsp->qual[ddtsp->tsp_cnt].nonstd_ind = 1, ddtsp
       ->nonstd_ind = 1
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(ddtsp->qual,ddtsp->tsp_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 10))
    CALL echorecord(ddtsp)
   ENDIF
   IF (dlt_fatal_error=1)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Unknown extent_management value returned from dm2_dba_tablespaces"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dir_storage_misc->tgt_storage_type="ASM"))
    SET dm_err->eproc = "Load datafile content."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SELECT
     IF ((dm2_install_schema->process_option="CLIN COPY"))
      FROM dm2_dba_data_files dbt
     ELSE
      FROM dm2_dba_data_files dbt
      WHERE substring(1,2,dbt.tablespace_name) IN ("D_", "I_", "L_")
       AND ((dbt.autoextensible="NO") OR (dbt.maxbytes < dlt_31g))
     ENDIF
     INTO "nl:"
     ORDER BY dbt.tablespace_name
     HEAD dbt.tablespace_name
      dlt_ndx = locateval(dlt_ndx,1,ddtsp->tsp_cnt,dbt.tablespace_name,ddtsp->qual[dlt_ndx].
       tspace_name)
      IF (dlt_ndx > 0)
       IF (dbt.autoextensible="NO")
        ddtsp->qual[dlt_ndx].nonstd_ind = 1, ddtsp->qual[dlt_ndx].datafile_not_ae = 1, ddtsp->
        nonstd_ind = 1
       ENDIF
       IF (dbt.maxbytes < dlt_31g)
        ddtsp->qual[dlt_ndx].nonstd_ind = 1, ddtsp->qual[dlt_ndx].datafile_not_unlimited = 1, ddtsp->
        nonstd_ind = 1
       ENDIF
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
 SUBROUTINE dtr_load_clin_tspaces(null)
   DECLARE dlt_ndx = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Load 'clinical' tablespace content."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT DISTINCT INTO "nl:"
    tspace_name = d.data_tablespace
    FROM dm_ts_precedence d
    WHERE ((d.owner="V500") UNION (
    (SELECT DISTINCT
     tspace_name = i.index_tablespace
     FROM dm_ts_precedence i
     WHERE ((i.owner="V500") UNION (
     (SELECT DISTINCT
      tspace_name = l.long_tablespace
      FROM dm_ts_precedence l
      WHERE l.owner="V500"))) )))
    ORDER BY tspace_name
    HEAD REPORT
     dtrt->cnt = 0
    DETAIL
     dtrt->cnt = (dtrt->cnt+ 1)
     IF (mod(dtrt->cnt,50)=1)
      stat = alterlist(dtrt->qual,(dtrt->cnt+ 49))
     ENDIF
     dtrt->qual[dtrt->cnt].tspace_name = trim(tspace_name)
    FOOT REPORT
     stat = alterlist(dtrt->qual,dtrt->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Load 'clinical' tablespace mapping content."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT DISTINCT INTO "nl:"
    d.info_char
    FROM dm_info d
    WHERE d.info_domain="DM2_TABLESPACE_MAPPING"
    ORDER BY d.info_char
    DETAIL
     dtrt->cnt = (dtrt->cnt+ 1), stat = alterlist(dtrt->qual,dtrt->cnt), dtrt->qual[dtrt->cnt].
     tspace_name = trim(d.info_char)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(dtrt)
   ENDIF
   RETURN(1)
 END ;Subroutine
 IF (validate(rdisk->qual[1].disk_name,"")=""
  AND validate(rdisk->qual[1].disk_name,"Z")="Z")
  FREE RECORD rdisk
  RECORD rdisk(
    1 disk_cnt = i4
    1 qual[*]
      2 disk_name = vc
      2 volume_label = vc
      2 vg_name = vc
      2 pp_size_mb = f8
      2 total_space_mb = f8
      2 free_space_mb = f8
      2 new_free_space_mb = f8
      2 root_ind = i2
      2 used_ind = vc
      2 data_tspace = i2
      2 index_tspace = i2
      2 datafile_dir_exists = i2
      2 mwc_flag = i2
      2 alloc_unit_b = f8
      2 block_size_b = f8
  )
  SET rdisk->disk_cnt = 0
 ENDIF
 IF (validate(pv_lv_list->qual[1].pv_name,"")=""
  AND validate(pv_lv_list->qual[1].pv_name,"Z")="Z")
  FREE RECORD pv_lv_list
  RECORD pv_lv_list(
    1 cnt = i4
    1 pv[*]
      2 pv_name = vc
      2 lv[*]
        3 lv_name = vc
  )
 ENDIF
 IF (validate(pv_mwc_list->pv[1].pv_name,"")=""
  AND validate(pv_mwc_list->pv[1].pv_name,"Z")="Z")
  FREE RECORD pv_mwc_list
  RECORD pv_mwc_list(
    1 cnt = i4
    1 pv[*]
      2 pv_name = vc
      2 mwc_flag = i2
  )
 ENDIF
 IF ((validate(autopop_screen->top_line,- (1))=- (1))
  AND (validate(autopop_screen->top_line,- (2))=- (2)))
  FREE RECORD autopop_screen
  RECORD autopop_screen(
    1 top_line = i4
    1 bottom_line = i4
    1 cur_line = i4
    1 max_scroll = i4
    1 max_value = i4
    1 disk_cnt = i4
    1 remain_space_add = f8
    1 user_bytes = f8
    1 disk[*]
      2 volume_label = vc
      2 disk_name = vc
      2 vg_name = vc
      2 disk_idx = i4
      2 lv_filename = vc
      2 free_disk_space_mb = f8
      2 pp_size_mb = f8
      2 pps_to_add = f8
      2 space_to_add = f8
      2 disk_tspace_rel_key = i4
      2 cont_size_mb = f8
      2 delete_ind = i4
      2 disk_full_ind = i2
      2 orig_disk_space_mb = f8
      2 mwc_flag = i2
      2 alloc_unit_b = f8
      2 block_size_b = f8
  )
 ENDIF
 IF ((validate(rvg->vg_cnt,- (1))=- (1))
  AND (validate(rvg->vg_cnt,- (2))=- (2)))
  FREE RECORD rvg
  RECORD rvg(
    1 vg_cnt = i2
    1 qual[*]
      2 vg_name = vc
      2 psize = i4
      2 ttl_pps = f8
      2 free_pps = f8
      2 free_mb = f8
  )
  SET rvg->vg_cnt = 0
 ENDIF
 IF (validate(dos_sys_filename,"X")="X"
  AND validate(dos_sys_filename,"Y")="Y")
  DECLARE dos_sys_filename = vc WITH public, noconstant("DM2NOTSET")
  IF ((dm2_sys_misc->cur_db_os="AXP"))
   SET dos_sys_filename = logical("sys$sysdevice")
  ENDIF
 ENDIF
 IF ((validate(dor_flex_cmd->dfc_cnt,- (1))=- (1))
  AND (validate(dor_flex_cmd->dfc_cnt,- (2))=- (2)))
  RECORD dor_flex_cmd(
    1 dfc_cnt = i4
    1 cmd[*]
      2 flex_cmd_file = vc
      2 flex_cmd = vc
      2 flex_output = vc
      2 flex_out_file = vc
      2 flex_cmd_type = vc
      2 flex_local = i2
      2 flex_rmt_user = vc
      2 flex_rmt_node = vc
  )
 ENDIF
 DECLARE dm2_find_dir(sbr_dir_name=vc) = i2
 DECLARE dm2_find_queue(sbr_que_name=vc) = i2
 DECLARE dm2_get_mnt_disk_info_axp(sbr_outfile=vc) = i2
 DECLARE convert_blocks_to_bytes(cbb_block_in=f8) = f8
 DECLARE convert_bytes(byte_value=f8,from_flag=c1,to_flag=c1) = f8 WITH public
 DECLARE dm2_get_vg_disk_info_aix(null) = i4 WITH public
 DECLARE dm2_parse_aix_vg_disk_file(sbr_dsk_fname=vc) = i4 WITH public
 DECLARE dm2_parse_hpux_disk_file(sbr_dsk_fname=vc) = i4 WITH public
 DECLARE dm2_assign_disk(agd_size_in=f8,agd_last_disk_ndx=i4) = i4
 DECLARE dm2_create_dir(sbr_new_dir=vc,sbr_new_dir_type=vc) = i2
 DECLARE dm2_get_vgs(null) = i2
 DECLARE dm2_get_novg_disk_info_aix(null) = i2
 DECLARE dm2_get_nomnt_disk_info_axp(null) = i2
 DECLARE dm2_extend_vg(dev_vg_name=vc,dev_disk_name=vc) = i2
 DECLARE dm2_make_vg(dmv_vg_name=vc,dmv_psize=i4,dmv_disk_name=vc) = i2
 DECLARE dm2_init_mount_disk(dim_disk_name=vc,dim_vol_lbl=vc) = vc
 DECLARE dm2_get_mwc_flag(dgm_disk_name=vc) = i2
 DECLARE dm2_sub_space_from_disk(dss_disk_ndx=i4,dss_file_size=f8) = i2
 DECLARE dm2_aix_remove_lv(sbr_arl_db_name=vc) = i2
 DECLARE dm2_rename_login_default(sbr_rld_mode=vc) = i2
 DECLARE dm2_delete_dir(ddd_dir=vc) = i2
 DECLARE dm2_reduce_vg(drv_vg_name=vc,drv_disk_name=vc) = i2
 DECLARE get_space_rounded(space_add_in=f8,pp_size_in=f8) = f8
 DECLARE dm2_parse_aix_vg(dpa_fname=vc,dpa_rvg_idx=i4) = i2
 DECLARE dm2_check_cluster_lic(null) = i2
 DECLARE dos_get_lv_for_pv(dglp_file=vc) = i2
 DECLARE dos_get_sys_dev(dgsd_file=vc) = i2
 DECLARE dos_get_mwc_value(dgmv_file=vc,dgmv_mode=i2) = i2
 DECLARE dor_get_diskgroup_info(null) = i2
 DECLARE dor_load_rdisk_into_rvg(dlrir_os=vc) = i2
 DECLARE dor_init_flex_cmds(null) = i2
 DECLARE dor_add_flex_cmd(dafc_local=i2,dafc_rmt_user=vc,dafc_rmt_node=vc,dafc_cmd_file=vc,dafc_cmd=
  vc,
  dafc_out_file=vc,dafc_cmd_type=vc) = i2
 DECLARE dm2_dismount_disk(ddd_vol_label=vc) = i2
 DECLARE dor_exec_flex_cmd(null) = i2
 DECLARE dm2_parse_mnt_disk_info_axp(dpmdia_outfile=vc) = i2
 DECLARE dor_flex_chmod_file(dfcf_file=vc,dfcf_ssh_str=vc) = i2
 SUBROUTINE dor_flex_chmod_file(dfcf_file,dfcf_ssh_str)
   DECLARE dfcf_str = vc WITH protect, noconstant(" ")
   DECLARE dfcf_stat = i2 WITH protect, noconstant(0)
   SET dfcf_str = concat(dfcf_ssh_str," chmod 777 ",dfcf_file," > ",trim(logical("ccluserdir")),
    "/dfcf_outfile.out 2>&1")
   SET dfcf_stat = 0
   SET dfcf_stat = dcl(dfcf_str,textlen(dfcf_str),dfcf_stat)
   IF ((dm_err->debug_flag > 0))
    CALL echo(dfcf_str)
   ENDIF
   IF (dfcf_stat != 1)
    IF (parse_errfile(concat(trim(logical("ccluserdir")),"/dfcf_outfile.out"))=0)
     RETURN(0)
    ENDIF
    SET dm_err->err_ind = 1
    SET dm_err->emsg = dm_err->errtext
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dor_exec_flex_cmd(null)
   DECLARE defc_stat = i2 WITH protect, noconstant(0)
   DECLARE defc_cnt = i2 WITH protect, noconstant(0)
   DECLARE defc_str = vc WITH protect, noconstant("")
   DECLARE defc_ssh_str = vc WITH protect, noconstant("")
   IF ((dm_err->debug_flag > 5))
    CALL echorecord(dor_flex_cmd)
   ENDIF
   FOR (defc_cnt = 1 TO dor_flex_cmd->dfc_cnt)
     IF ((dor_flex_cmd->cmd[defc_cnt].flex_local=0))
      SET defc_ssh_str = concat("ssh ",dor_flex_cmd->cmd[defc_cnt].flex_rmt_user,"@",dor_flex_cmd->
       cmd[defc_cnt].flex_rmt_node," ")
     ELSE
      SET defc_ssh_str = " "
     ENDIF
     IF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type IN ("EF", "EFRO")))
      IF (dor_flex_chmod_file(dor_flex_cmd->cmd[defc_cnt].flex_cmd_file,defc_ssh_str)=0)
       RETURN(0)
      ENDIF
     ENDIF
     IF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type IN ("EF", "EFRO", "EFO")))
      IF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type="EFRO"))
       IF ((dor_flex_cmd->cmd[defc_cnt].flex_local=1))
        SET defc_str = concat(". ",dor_flex_cmd->cmd[defc_cnt].flex_cmd_file," > ",trim(logical(
           "ccluserdir")),"/defc_outfile.out")
       ELSE
        SET defc_str = concat(defc_ssh_str," ",dor_flex_cmd->cmd[defc_cnt].flex_cmd_file)
       ENDIF
      ELSEIF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type="EF"))
       SET defc_str = concat(". ",dor_flex_cmd->cmd[defc_cnt].flex_cmd_file)
      ELSEIF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type="EFO"))
       IF ((dor_flex_cmd->cmd[defc_cnt].flex_local=1))
        SET defc_str = concat("su - oracle -c ",dor_flex_cmd->cmd[defc_cnt].flex_cmd_file)
       ELSE
        SET defc_str = concat(defc_ssh_str," ",dor_flex_cmd->cmd[defc_cnt].flex_cmd_file)
       ENDIF
      ENDIF
      SET defc_stat = 0
      SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
      IF ((dm_err->debug_flag > 0))
       CALL echo(defc_str)
      ENDIF
      IF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type="EFRO"))
       IF (parse_errfile(concat(trim(logical("ccluserdir")),"/defc_outfile.out"))=0)
        RETURN(0)
       ENDIF
       SET dor_flex_cmd->cmd[defc_cnt].flex_output = dm_err->errtext
      ENDIF
     ENDIF
     IF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type IN ("EC")))
      IF (findstring("update_reg",dor_flex_cmd->cmd[defc_cnt].flex_cmd,1,0) > 0)
       IF (drr_exec_update_reg(dor_flex_cmd->cmd[defc_cnt].flex_cmd)=0)
        RETURN(0)
       ENDIF
      ELSE
       IF ((dor_flex_cmd->cmd[defc_cnt].flex_out_file=""))
        SET dor_flex_cmd->cmd[defc_cnt].flex_out_file = concat(trim(logical("ccluserdir")),
         "/defc_outfile.out")
       ENDIF
       IF ((dor_flex_cmd->cmd[defc_cnt].flex_out_file="*:APPEND"))
        SET defc_stat = 0
        SET defc_str = concat(defc_ssh_str," ",dor_flex_cmd->cmd[defc_cnt].flex_cmd," >> ",substring(
          1,(findstring(":",dor_flex_cmd->cmd[defc_cnt].flex_out_file,1,1) - 1),dor_flex_cmd->cmd[
          defc_cnt].flex_out_file),
         " 2>&1")
        IF ((dm_err->debug_flag > 0))
         CALL echo(defc_str)
        ENDIF
        SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
       ELSEIF ((dor_flex_cmd->cmd[defc_cnt].flex_out_file="noout"))
        SET defc_stat = 0
        SET defc_str = concat(defc_ssh_str," ",dor_flex_cmd->cmd[defc_cnt].flex_cmd)
        IF ((dm_err->debug_flag > 0))
         CALL echo(defc_str)
        ENDIF
        SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
       ELSE
        SET defc_stat = 0
        SET defc_str = concat(defc_ssh_str," ",dor_flex_cmd->cmd[defc_cnt].flex_cmd," > ",
         dor_flex_cmd->cmd[defc_cnt].flex_out_file,
         " 2>&1")
        IF ((dm_err->debug_flag > 0))
         CALL echo(defc_str)
        ENDIF
        SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
        IF (parse_errfile(dor_flex_cmd->cmd[defc_cnt].flex_out_file)=0)
         RETURN(0)
        ENDIF
        SET dor_flex_cmd->cmd[defc_cnt].flex_output = dm_err->errtext
       ENDIF
      ENDIF
     ENDIF
     IF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type IN ("EFORO")))
      IF ((dor_flex_cmd->cmd[defc_cnt].flex_local=1))
       SET defc_str = concat("su - oracle -c ",dor_flex_cmd->cmd[defc_cnt].flex_cmd_file)
      ELSE
       SET defc_str = concat(defc_ssh_str," ",dor_flex_cmd->cmd[defc_cnt].flex_cmd_file)
      ENDIF
      IF ((dor_flex_cmd->cmd[defc_cnt].flex_out_file=""))
       SET dor_flex_cmd->cmd[defc_cnt].flex_out_file = concat(trim(logical("ccluserdir")),
        "/defc_outfile.out")
      ENDIF
      SET defc_stat = 0
      SET defc_str = concat(defc_str," "," > ",dor_flex_cmd->cmd[defc_cnt].flex_out_file," 2>&1")
      IF ((dm_err->debug_flag > 0))
       CALL echo(defc_str)
      ENDIF
      SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
      IF (parse_errfile(dor_flex_cmd->cmd[defc_cnt].flex_out_file)=0)
       RETURN(0)
      ENDIF
      SET dor_flex_cmd->cmd[defc_cnt].flex_output = dm_err->errtext
     ENDIF
     IF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type IN ("EFRF")))
      SET defc_stat = 0
      IF ((dor_flex_cmd->cmd[defc_cnt].flex_local=0))
       SET defc_str = concat(defc_ssh_str," ",dor_flex_cmd->cmd[defc_cnt].flex_cmd_file," > ",
        dor_flex_cmd->cmd[defc_cnt].flex_out_file,
        " 2>&1")
      ELSE
       SET defc_str = concat(dor_flex_cmd->cmd[defc_cnt].flex_cmd_file," > ",dor_flex_cmd->cmd[
        defc_cnt].flex_out_file," 2>&1")
      ENDIF
      IF ((dm_err->debug_flag > 0))
       CALL echo(defc_str)
      ENDIF
      SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
      IF (defc_stat != 1)
       SET dm_err->err_ind = 1
       SET dm_err->emsg = concat("Error returned from:",defc_str)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      IF ((dor_flex_cmd->cmd[defc_cnt].flex_local=0))
       SET defc_str = concat("/usr/bin/scp ",dor_flex_cmd->cmd[defc_cnt].flex_rmt_user,"@",
        dor_flex_cmd->cmd[defc_cnt].flex_rmt_node,":",
        dor_flex_cmd->cmd[defc_cnt].flex_out_file," ",trim(logical("ccluserdir")),"/")
       IF ((dm_err->debug_flag > 0))
        CALL echo(defc_str)
       ENDIF
       SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
       IF (defc_stat != 1)
        SET dm_err->err_ind = 1
        SET dm_err->emsg = concat("Error returned from:",defc_str)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
     IF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type IN ("RCPBACK")))
      SET defc_str = concat("/usr/bin/scp ",dor_flex_cmd->cmd[defc_cnt].flex_rmt_user,"@",
       dor_flex_cmd->cmd[defc_cnt].flex_rmt_node,":",
       dor_flex_cmd->cmd[defc_cnt].flex_out_file," ",trim(logical("ccluserdir")),"/")
      IF ((dm_err->debug_flag > 0))
       CALL echo(defc_str)
      ENDIF
      SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
      IF (defc_stat != 1)
       SET dm_err->err_ind = 1
       SET dm_err->emsg = concat("Error returned from:",defc_str)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
     IF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type IN ("ECRF")))
      SET defc_stat = 0
      IF ((dor_flex_cmd->cmd[defc_cnt].flex_local=0))
       SET defc_str = concat(defc_ssh_str," ",dor_flex_cmd->cmd[defc_cnt].flex_cmd," > ",dor_flex_cmd
        ->cmd[defc_cnt].flex_out_file,
        " 2>&1")
      ELSE
       SET defc_str = concat(dor_flex_cmd->cmd[defc_cnt].flex_cmd," > ",dor_flex_cmd->cmd[defc_cnt].
        flex_out_file," 2>&1")
      ENDIF
      IF ((dm_err->debug_flag > 0))
       CALL echo(defc_str)
      ENDIF
      SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
      IF (defc_stat != 1)
       SET dm_err->err_ind = 1
       SET dm_err->emsg = concat("Error returned from:",defc_str)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      IF ((dor_flex_cmd->cmd[defc_cnt].flex_local=0))
       SET defc_str = concat("/usr/bin/scp ",dor_flex_cmd->cmd[defc_cnt].flex_rmt_user,"@",
        dor_flex_cmd->cmd[defc_cnt].flex_rmt_node,":",
        dor_flex_cmd->cmd[defc_cnt].flex_out_file," ",dor_flex_cmd->cmd[defc_cnt].flex_cmd_file)
       IF ((dm_err->debug_flag > 0))
        CALL echo(defc_str)
       ENDIF
       SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
       IF (defc_stat != 1)
        SET dm_err->err_ind = 1
        SET dm_err->emsg = concat("Error returned from:",defc_str)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
     IF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type IN ("RCP")))
      IF ((dor_flex_cmd->cmd[defc_cnt].flex_local=0))
       SET defc_str = concat("/usr/bin/scp ",dor_flex_cmd->cmd[defc_cnt].flex_cmd_file," ",
        dor_flex_cmd->cmd[defc_cnt].flex_rmt_user,"@",
        dor_flex_cmd->cmd[defc_cnt].flex_rmt_node,":",dor_flex_cmd->cmd[defc_cnt].flex_out_file)
       IF ((dm_err->debug_flag > 0))
        CALL echo(defc_str)
       ENDIF
       SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
       IF (defc_stat != 1)
        SET dm_err->err_ind = 1
        SET dm_err->emsg = concat("Error returned from:",defc_str)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       IF (dor_flex_chmod_file(dor_flex_cmd->cmd[defc_cnt].flex_out_file,defc_ssh_str)=0)
        RETURN(0)
       ENDIF
      ELSE
       SET defc_str = concat("cp ",dor_flex_cmd->cmd[defc_cnt].flex_cmd_file," ",dor_flex_cmd->cmd[
        defc_cnt].flex_out_file)
       IF ((dm_err->debug_flag > 0))
        CALL echo(defc_str)
       ENDIF
       SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
       IF (defc_stat != 1)
        SET dm_err->err_ind = 1
        SET dm_err->emsg = concat("Error returned from:",defc_str)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
     IF ((dm_err->debug_flag > 722))
      SET defc_str = concat("cat ",trim(logical("ccluserdir")),"/defc_outfile.out")
      SET defc_stat = 0
      SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
     ENDIF
     SET dor_flex_cmd->cmd[defc_cnt].flex_output = trim(dor_flex_cmd->cmd[defc_cnt].flex_output,3)
   ENDFOR
   IF ((dm_err->debug_flag > 5))
    CALL echorecord(dor_flex_cmd)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dor_add_flex_cmd(dafc_local,dafc_rmt_user,dafc_rmt_node,dafc_cmd_file,dafc_cmd,
  dafc_out_file,dafc_cmd_type)
   SET dor_flex_cmd->dfc_cnt = (dor_flex_cmd->dfc_cnt+ 1)
   SET stat = alterlist(dor_flex_cmd->cmd,dor_flex_cmd->dfc_cnt)
   SET dor_flex_cmd->cmd[dor_flex_cmd->dfc_cnt].flex_cmd_file = dafc_cmd_file
   IF (dafc_local=0)
    SET dor_flex_cmd->cmd[dor_flex_cmd->dfc_cnt].flex_cmd = concat('"',dafc_cmd,'"')
    IF (findstring("echo $\?",dor_flex_cmd->cmd[dor_flex_cmd->dfc_cnt].flex_cmd,1,1) > 0)
     SET dor_flex_cmd->cmd[dor_flex_cmd->dfc_cnt].flex_cmd = replace(dor_flex_cmd->cmd[dor_flex_cmd->
      dfc_cnt].flex_cmd,"echo $?","echo \$?",0)
    ENDIF
   ELSE
    SET dor_flex_cmd->cmd[dor_flex_cmd->dfc_cnt].flex_cmd = dafc_cmd
   ENDIF
   SET dor_flex_cmd->cmd[dor_flex_cmd->dfc_cnt].flex_out_file = dafc_out_file
   SET dor_flex_cmd->cmd[dor_flex_cmd->dfc_cnt].flex_cmd_type = dafc_cmd_type
   SET dor_flex_cmd->cmd[dor_flex_cmd->dfc_cnt].flex_local = dafc_local
   SET dor_flex_cmd->cmd[dor_flex_cmd->dfc_cnt].flex_rmt_user = dafc_rmt_user
   SET dor_flex_cmd->cmd[dor_flex_cmd->dfc_cnt].flex_rmt_node = dafc_rmt_node
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dor_init_flex_cmds(null)
   SET dor_flex_cmd->dfc_cnt = 0
   SET stat = alterlist(dor_flex_cmd->cmd,0)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_find_dir(sbr_dir_name)
   DECLARE dfd_cmd_txt = vc WITH protect, noconstant(" ")
   DECLARE dfd_err_str = vc WITH protect, noconstant(" ")
   DECLARE dfd_err_str2 = vc WITH protect, noconstant(" ")
   DECLARE dfd_tmp_err_ind = i2 WITH protect, noconstant(0)
   DECLARE dfd_err_str3 = vc WITH protect, noconstant("")
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dfd_cmd_txt = concat("dir ",sbr_dir_name)
    SET dfd_err_str = "directory not found"
    SET dfd_err_str2 = "no files found"
    SET dfd_err_str3 = "error in device name"
   ELSE
    SET dfd_cmd_txt = concat("test -d ",sbr_dir_name,";echo $?")
    SET dfd_err_str = "0"
   ENDIF
   SET dm_err->disp_dcl_err_ind = 0
   CALL dm2_push_dcl(dfd_cmd_txt)
   SET dm_err->disp_dcl_err_ind = 1
   IF ((dm_err->err_ind=1))
    SET dm_err->err_ind = 0
    SET dfd_tmp_err_ind = 1
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    IF (findstring(dfd_err_str,dm_err->errtext,1,0) > 0)
     SET dm_err->eproc = concat("Directory ",sbr_dir_name," not found.")
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     RETURN(0)
    ELSEIF (findstring(dfd_err_str2,dm_err->errtext,1,0) > 0)
     SET dm_err->eproc = concat("Directory ",sbr_dir_name," exists with no files in directory.")
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     RETURN(1)
    ELSEIF (findstring(dfd_err_str3,dm_err->errtext,1,0) > 0)
     SET dm_err->eproc = concat("Directory device ",sbr_dir_name," does not exist.")
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     RETURN(0)
    ELSEIF (dfd_tmp_err_ind=1)
     SET dm_err->eproc = concat("Find directory  ",sbr_dir_name)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     RETURN(0)
    ENDIF
   ELSE
    IF (cnvtint(dm_err->errtext)=0)
     SET dm_err->eproc = concat("Directory ",sbr_dir_name," found.")
     IF ((dm_err->debug_flag > 1))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
     ENDIF
     RETURN(1)
    ELSE
     SET dm_err->eproc = concat("Directory ",sbr_dir_name," not found.")
     IF ((dm_err->debug_flag > 1))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
     ENDIF
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_find_queue(sbr_que_name)
   DECLARE dfd_cmd_txt = vc WITH protect, noconstant(" ")
   DECLARE dfd_err_str = vc WITH protect, noconstant(" ")
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dfd_cmd_txt = concat("sho queue ",sbr_que_name)
    SET dfd_err_str = "no such queue"
   ELSE
    RETURN(0)
   ENDIF
   IF (dm2_push_dcl(dfd_cmd_txt)=0)
    RETURN(0)
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(dm_err->errtext)
   ENDIF
   IF (findstring("idle",dm_err->errtext,1,0) > 0)
    RETURN(1)
   ELSE
    SET dm_err->eproc = concat("Make sure que ",sbr_que_name," is idle.")
    SET dm_err->emsg = dm_err->errtext
    CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dos_get_sys_dev(dgsd_file)
   DECLARE dgsd_device_name = vc WITH protect, noconstant("")
   DECLARE dgsd_start = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Gather system device name"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SET logical dgsd_sys_dev dgsd_file
   FREE DEFINE rtl
   DEFINE rtl "dgsd_sys_dev"
   SELECT INTO "nl:"
    t.line
    FROM rtlt t
    WHERE t.line > " "
    DETAIL
     dgsd_start = (findstring('"SYS$SYSDEVICE" = "',t.line)+ 19)
     IF ((dm_err->debug_flag > 1))
      CALL echo(t.line)
     ENDIF
     IF (dgsd_start > 0)
      dgsd_device_name = substring(dgsd_start,(findstring('"',t.line,(dgsd_start+ 1),1) - dgsd_start),
       t.line)
     ENDIF
     IF ((dm_err->debug_flag > 1))
      CALL echo(dgsd_device_name)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dgsd_device_name="")
    SET dm_err->eproc = concat("Could not gather system device name from file:",dgsd_file)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
   ENDIF
   SET dos_sys_filename = dgsd_device_name
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dos_get_mwc_value(dgmv_file,dgmv_mode)
   DECLARE dgmv_cmd = vc WITH protect, noconstant("")
   DECLARE dgmv_stat = i2 WITH protect, noconstant(0)
   DECLARE dgmv_cnt = i2 WITH protect, noconstant(0)
   IF (dgmv_mode=1)
    SET dgmv_cmd = concat(
     ^a=`lsvg -o | awk -v b="" '{b=sprintf("%s| %s ",b,$1)}END{print b}' | sed 's/^,
     "^| //g'`;for i in `lspv | egrep ",^"($a)" | awk '{print $1}'`;do lqueryvg -p /dev/$i -X | ^,
     ^echo $i `awk '{print" "$1}'` ;done >> ^,dgmv_file)
    IF ((dm_err->debug_flag > 0))
     CALL echo(concat("MWC command:",dgmv_cmd))
    ENDIF
    SET dm_err->eproc = "Gather MWC values"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SET dgmv_stat = dcl(dgmv_cmd,textlen(dgmv_cmd),dgmv_stat)
    IF (dgmv_stat=1)
     IF ((dm_err->debug_flag > 0))
      CALL echo(build("pv mwc listing file =",dgmv_file))
     ENDIF
    ELSE
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ENDIF
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->eproc = concat("Validate that ",dgmv_file," exists")
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    IF (findfile(dgmv_file)=0)
     SET dm_err->emsg = concat(dgmv_file," does not exist, unable to obtain MWC information")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Load MWC values"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SET logical mwc_disk_info dgmv_file
   FREE DEFINE rtl
   DEFINE rtl "mwc_disk_info"
   SELECT INTO "nl:"
    t.line
    FROM rtlt t
    WHERE t.line > " "
    DETAIL
     dgmv_cnt = (dgmv_cnt+ 1)
     IF (mod(dgmv_cnt,10)=1)
      stat = alterlist(pv_mwc_list->pv,(dgmv_cnt+ 9))
     ENDIF
     pv_mwc_list->pv[dgmv_cnt].pv_name = substring(1,(findstring(" ",t.line) - 1),t.line),
     pv_mwc_list->pv[dgmv_cnt].mwc_flag = evaluate(cnvtint(substring((findstring(" ",t.line)+ 1),1,t
        .line)),1,0,1)
     IF ((pv_mwc_list->pv[dgmv_cnt].mwc_flag=0))
      pv_mwc_list->pv[dgmv_cnt].mwc_flag = 1
     ELSE
      pv_mwc_list->pv[dgmv_cnt].mwc_flag = 0
     ENDIF
    FOOT REPORT
     pv_mwc_list->cnt = dgmv_cnt, stat = alterlist(pv_mwc_list->pv,dgmv_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dos_get_lv_for_pv(dglp_file)
   DECLARE dglp_cmd = vc WITH protect, noconstant("")
   DECLARE dglp_rtl_file = vc WITH protect, noconstant("")
   DECLARE dglp_pv_cnt = i4 WITH protect, noconstant(0)
   DECLARE dglp_lv_cnt = i4 WITH protect, noconstant(0)
   DECLARE dglp_stat = i4 WITH protect, noconstant(0)
   SET dglp_rtl_file = concat("ccluserdir:",dglp_file)
   SET logical aix_disk_info dglp_rtl_file
   FREE DEFINE rtl
   DEFINE rtl "aix_disk_info"
   SET dm_err->eproc = "Parse list of PVs and related LVs"
   IF ((dm_err->debug_flag > 1))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    t.line
    FROM rtlt t
    WHERE t.line > " "
    DETAIL
     IF (findstring(":",t.line) > 0)
      dglp_pv_cnt = (dglp_pv_cnt+ 1), stat = alterlist(pv_lv_list->pv,dglp_pv_cnt), pv_lv_list->pv[
      dglp_pv_cnt].pv_name = substring(1,(findstring(":",t.line) - 1),t.line),
      dglp_lv_cnt = 0
     ELSE
      IF ( NOT (findstring("LV NAME",t.line)))
       dglp_lv_cnt = (dglp_lv_cnt+ 1), stat = alterlist(pv_lv_list->pv[dglp_pv_cnt].lv,dglp_lv_cnt),
       pv_lv_list->pv[dglp_pv_cnt].lv[dglp_lv_cnt].lv_name = substring(1,(findstring(" ",t.line) - 1),
        t.line)
      ENDIF
     ENDIF
    FOOT REPORT
     pv_lv_list->cnt = dglp_pv_cnt
    WITH nocounter, maxcol = 500
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(pv_lv_list)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_parse_mnt_disk_info_axp(dpmdia_outfile)
   DECLARE axp_rtl_file = vc WITH public, noconstant("")
   DECLARE disk_vg_hold = vc WITH public, noconstant("")
   DECLARE axp_count_hold = i4 WITH public, noconstant(0)
   DECLARE spot_end = i4 WITH public, noconstant(0)
   DECLARE spot = i4 WITH public, noconstant(0)
   SET axp_rtl_file = concat("ccluserdir:",dpmdia_outfile)
   SET logical axp_disk_info axp_rtl_file
   FREE DEFINE rtl
   DEFINE rtl "axp_disk_info"
   SET dm_err->eproc = "Parse list of mounted disks"
   SELECT INTO "nl:"
    t.line
    FROM rtlt t
    WHERE t.line > " "
    HEAD REPORT
     axp_count_hold = 0
    DETAIL
     axp_count_hold = (axp_count_hold+ 1), stat = alterlist(rdisk->qual,axp_count_hold), spot =
     findstring(",",t.line,1),
     disk_name_hold = substring(1,(spot - 1),t.line), rdisk->qual[axp_count_hold].disk_name =
     disk_name_hold
     IF (disk_name_hold=dos_sys_filename)
      rdisk->qual[axp_count_hold].root_ind = 1
     ELSE
      rdisk->qual[axp_count_hold].root_ind = 0
     ENDIF
     disk_vg_hold = substring((spot+ 2),(textlen(t.line) - spot),t.line), spot = findstring(",",
      disk_vg_hold), disk_vg_hold = substring(1,(spot - 1),disk_vg_hold),
     rdisk->qual[axp_count_hold].volume_label = disk_vg_hold, spot = 0, spot = findstring(
      "Free Space:",t.line,1),
     spot_end = findstring("Total Space:",t.line,1), disk_free_space_mb = substring(spot,((spot_end
       - spot) - 1),t.line), spot = 0,
     spot = findstring(":",disk_free_space_mb,1), disk_free_space_mb = substring((spot+ 2),(textlen(
       disk_free_space_mb) - spot),disk_free_space_mb), rdisk->qual[axp_count_hold].free_space_mb =
     convert_bytes(convert_blocks_to_bytes(cnvtreal(disk_free_space_mb)),"b","m"),
     rdisk->qual[axp_count_hold].new_free_space_mb = rdisk->qual[axp_count_hold].free_space_mb, spot
      = 0, disk_free_space_mb = "",
     spot = findstring("Total Space:",t.line,1), disk_free_space_mb = substring(spot,(textlen(t.line)
       - spot),t.line), spot = 0,
     spot = findstring(":",disk_free_space_mb,1), disk_free_space_mb = substring((spot+ 2),(textlen(
       disk_free_space_mb) - spot),disk_free_space_mb), rdisk->qual[axp_count_hold].total_space_mb =
     convert_bytes(convert_blocks_to_bytes(cnvtreal(disk_free_space_mb)),"b","m")
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    SET message = nowindow
    CALL echorecord(rdisk)
    SET message = window
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_get_mnt_disk_info_axp(sbr_outfile)
   SET dm_err->eproc = "Get list of mounted disks"
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE dcl_str = vc WITH protect, noconstant(" ")
   SET dcl_str = concat("@cer_install:dm2_get_mnt_disk_info.com ",sbr_outfile)
   IF ( NOT (dm2_push_dcl(dcl_str)))
    RETURN(0)
   ENDIF
   IF (dm2_parse_mnt_disk_info_axp(sbr_outfile)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_get_vg_disk_info_aix(null)
   DECLARE dcl_str = vc WITH protect, noconstant(" ")
   DECLARE dcl_stat = i2 WITH protect, noconstant(0)
   DECLARE dcl_temp_file = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Get list of disks in a volume group"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET dm_err->eproc = "DM2_GET_VG_DISK_INFO_AIX: Get unique filename for disk list"
   IF (get_unique_file("dm2_disk_aix_info",".dat"))
    SET dcl_temp_file = dm_err->unique_fname
   ELSE
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AIX"))
    SET dm_err->eproc = "DM2_GET_VG_DISK_INFO_AIX: Get list of disks in a volume group"
    SET dcl_str = concat(^a=`lsvg -o | awk -v b="" '{b=sprintf("%s| %s ",b,$1)}^,
     "END{print b}' | sed 's/^| //g'`",
     ^;for i in `lspv | egrep "($a)" | awk '{print $1}'`;do lspv $i >> ^,dcl_temp_file,";done")
    SET dcl_stat = dcl(dcl_str,textlen(dcl_str),dcl_stat)
    IF (dcl_stat=1)
     IF ((dm_err->debug_flag > 0))
      CALL echo(build("disk_file =",dcl_temp_file))
     ENDIF
     IF ( NOT (dm2_parse_aix_vg_disk_file(dcl_temp_file)))
      RETURN(0)
     ELSE
      RETURN(1)
     ENDIF
    ELSE
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ENDIF
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->eproc = "DM2_GET_VG_DISK_INFO_AIX: Use VGDISPLAY to get list of Volume Groups."
    SET dcl_str = concat("vgdisplay > ",dm_err->unique_fname," 2>/dev/null")
    SET dcl_stat = 0
    SET dcl_stat = dcl(dcl_str,textlen(dcl_str),dcl_stat)
    IF (dcl_stat=0)
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ENDIF
     RETURN(0)
    ELSE
     IF ((dm_err->debug_flag > 0))
      CALL echo(build("disk_file =",dcl_temp_file))
     ENDIF
    ENDIF
    IF (dm2_parse_hpux_disk_file(dcl_temp_file)=0)
     RETURN(0)
    ELSE
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dor_load_rdisk_into_rvg(dlrir_os)
   DECLARE dlrir_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlrir_vg_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlrir_ndx = i4 WITH protect, noconstant(0)
   SET rvg->vg_cnt = 0
   SET stat = alterlist(rvg->qual,rvg->vg_cnt)
   FOR (dlrir_cnt = 1 TO rdisk->disk_cnt)
     IF ( NOT ((rdisk->qual[dlrir_cnt].vg_name IN ("rootvg", "/dev/vg00"))))
      IF (dlrir_cnt > 0
       AND locateval(dlrir_ndx,1,rvg->vg_cnt,rdisk->qual[dlrir_cnt].vg_name,rvg->qual[dlrir_ndx].
       vg_name) > 0)
       SET rvg->qual[dlrir_ndx].ttl_pps = (rvg->qual[dlrir_ndx].ttl_pps+ (rdisk->qual[dlrir_ndx].
       total_space_mb/ rdisk->qual[dlrir_ndx].pp_size_mb))
       SET rvg->qual[dlrir_ndx].free_pps = (rvg->qual[dlrir_ndx].free_pps+ (rdisk->qual[dlrir_cnt].
       free_space_mb/ rdisk->qual[dlrir_cnt].pp_size_mb))
       SET rvg->qual[dlrir_ndx].free_mb = (rvg->qual[dlrir_ndx].free_mb+ rdisk->qual[dlrir_cnt].
       free_space_mb)
      ELSE
       SET rvg->vg_cnt = (rvg->vg_cnt+ 1)
       SET stat = alterlist(rvg->qual,rvg->vg_cnt)
       IF (dlrir_os="HPX")
        SET rvg->qual[rvg->vg_cnt].vg_name = substring(6,(textlen(rdisk->qual[dlrir_cnt].vg_name) - 5
         ),rdisk->qual[dlrir_cnt].vg_name)
       ELSE
        SET rvg->qual[rvg->vg_cnt].vg_name = rdisk->qual[dlrir_cnt].vg_name
       ENDIF
       SET rvg->qual[rvg->vg_cnt].psize = rdisk->qual[dlrir_cnt].pp_size_mb
       SET rvg->qual[rvg->vg_cnt].ttl_pps = (rdisk->qual[dlrir_cnt].total_space_mb/ rdisk->qual[
       dlrir_cnt].pp_size_mb)
       SET rvg->qual[rvg->vg_cnt].free_pps = (rdisk->qual[dlrir_cnt].free_space_mb/ rdisk->qual[
       dlrir_cnt].pp_size_mb)
       SET rvg->qual[rvg->vg_cnt].free_mb = rdisk->qual[dlrir_cnt].free_space_mb
      ENDIF
     ENDIF
   ENDFOR
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(rdisk)
    CALL echorecord(rvg)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dor_get_diskgroup_info(null)
   SET stat = alterlist(rdisk->qual,0)
   SET rdisk->disk_cnt = 0
   SET dm_err->eproc = "Loading ASM diskgroups."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM v$asm_diskgroup v
    WHERE v.state IN ("CONNECTED", "MOUNTED")
    DETAIL
     rdisk->disk_cnt = (rdisk->disk_cnt+ 1), stat = alterlist(rdisk->qual,rdisk->disk_cnt), rdisk->
     qual[rdisk->disk_cnt].disk_name = v.name,
     rdisk->qual[rdisk->disk_cnt].total_space_mb = v.total_mb, rdisk->qual[rdisk->disk_cnt].
     free_space_mb = v.free_mb, rdisk->qual[rdisk->disk_cnt].new_free_space_mb = v.free_mb,
     rdisk->qual[rdisk->disk_cnt].alloc_unit_b = v.allocation_unit_size, rdisk->qual[rdisk->disk_cnt]
     .block_size_b = v.block_size
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(rdisk)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE convert_blocks_to_bytes(cbb_block_in)
   DECLARE cbb_bytes_per_block = f8 WITH public, noconstant(0.0)
   DECLARE cbb_return = f8 WITH public, noconstant(0.0)
   SET cbb_bytes_per_block = 512.0
   SET cbb_return = (cbb_block_in * cbb_bytes_per_block)
   RETURN(cbb_return)
 END ;Subroutine
 SUBROUTINE convert_bytes(byte_value,from_flag,to_flag)
   DECLARE mbyte_factor = f8 WITH constant(1048576.0)
   DECLARE kbyte_factor = f8 WITH constant(1024.0)
   DECLARE temp_byte_value = f8 WITH noconstant(0.0)
   CASE (from_flag)
    OF "m":
     SET byte_value = (byte_value * kbyte_factor)
    OF "k":
     SET byte_value = byte_value
    OF "b":
     SET byte_value = (byte_value/ kbyte_factor)
   ENDCASE
   CASE (to_flag)
    OF "b":
     SET temp_byte_value = byte_value
     SET temp_byte_value = (temp_byte_value * kbyte_factor)
    OF "m":
     SET temp_byte_value = byte_value
     SET temp_byte_value = (byte_value/ kbyte_factor)
    OF "k":
     SET temp_byte_value = byte_value
   ENDCASE
   SET temp_byte_value = dm2ceil(temp_byte_value)
   RETURN(temp_byte_value)
 END ;Subroutine
 SUBROUTINE dm2_assign_disk(agd_size_in,agd_last_disk_ndx)
   DECLARE agd_disk_ndx_ret = i4 WITH noconstant(0)
   DECLARE agd_disk_ndx = i4 WITH noconstant(0)
   DECLARE agd_disk_cnt = i4 WITH noconstant(0)
   DECLARE agd_size_check = f8 WITH noconstant(0.0)
   DECLARE agd_start_pt = i4 WITH noconstant(0)
   DECLARE agd_end_pt = i4 WITH noconstant(0)
   DECLARE agd_start_over = i4 WITH noconstant(0)
   IF ((dm_err->debug_flag > 1))
    SET dm_err->eproc = build("Assign file to disk: size_in=",agd_size_in,"; last_disk_ndx=",
     agd_last_disk_ndx)
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (agd_last_disk_ndx=size(autopop_screen->disk,5))
    SET agd_start_pt = 1
   ELSE
    SET agd_start_pt = (agd_last_disk_ndx+ 1)
   ENDIF
   SET agd_end_pt = size(autopop_screen->disk,5)
   SET agd_disk_cnt = agd_start_pt
   WHILE (agd_start_over < 2
    AND agd_disk_ndx_ret=0)
     IF ((dm_err->debug_flag > 3))
      CALL echo("*************************BEGINWHILE********************")
      CALL echo(agd_disk_cnt)
      CALL echo(agd_end_pt)
      CALL echo(agd_start_over)
      CALL echo(agd_size_check)
      CALL echo(autopop_screen->disk[agd_disk_cnt].free_disk_space_mb)
      CALL echo(autopop_screen->disk[agd_disk_cnt].disk_name)
      CALL echo(agd_disk_ndx_ret)
      CALL echo("*************************BEGINWHILEx********************")
     ENDIF
     SET agd_size_check = 0.0
     IF ((dir_storage_misc->tgt_storage_type IN ("ASM", "AXP")))
      SET agd_size_check = agd_size_in
     ELSE
      SET agd_size_check = get_space_rounded(cnvtreal(agd_size_in),autopop_screen->disk[agd_disk_cnt]
       .pp_size_mb)
     ENDIF
     IF ((dm_err->debug_flag > 3))
      CALL echo("Autopop Values")
      CALL echo(autopop_screen->disk[agd_disk_cnt].free_disk_space_mb)
      CALL echo(agd_size_check)
     ENDIF
     IF ((autopop_screen->disk[agd_disk_cnt].free_disk_space_mb > agd_size_check))
      SET agd_disk_ndx_ret = agd_disk_cnt
      IF ((dm_err->debug_flag > 3))
       CALL echo(agd_disk_ndx_ret)
      ENDIF
     ENDIF
     IF (agd_disk_cnt=agd_end_pt
      AND agd_disk_ndx_ret=0)
      IF (agd_start_over=0)
       IF (agd_start_pt != 1)
        SET agd_disk_cnt = 1
        SET agd_end_pt = agd_last_disk_ndx
        SET agd_start_over = (agd_start_over+ 1)
       ELSE
        SET agd_start_over = 2
       ENDIF
      ELSE
       SET agd_start_over = 2
      ENDIF
     ELSE
      IF (((agd_disk_cnt+ 1) > size(autopop_screen->disk,5)))
       SET agd_disk_cnt = size(autopop_screen->disk,5)
      ELSE
       SET agd_disk_cnt = (agd_disk_cnt+ 1)
      ENDIF
     ENDIF
     IF ((dm_err->debug_flag > 3))
      CALL echo("*************************ENDWHILE********************")
      CALL echo(agd_disk_cnt)
      CALL echo(agd_end_pt)
      CALL echo(agd_start_over)
      CALL echo(agd_size_check)
      CALL echo(autopop_screen->disk[agd_disk_cnt].free_disk_space_mb)
      CALL echo(autopop_screen->disk[agd_disk_cnt].disk_name)
      CALL echo(agd_disk_ndx_ret)
      CALL echo("*************************ENDWHILEx********************")
     ENDIF
   ENDWHILE
   RETURN(agd_disk_ndx_ret)
 END ;Subroutine
 SUBROUTINE dm2_sub_space_from_disk(dss_disk_ndx,dss_file_size)
   SET dm_err->eproc =
   "Substract dfile size from selected disk and reset autopop_screen disk free space."
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dir_storage_misc->tgt_storage_type="RAW"))
    SET dss_file_size = get_space_rounded(cnvtreal(dss_file_size),autopop_screen->disk[dss_disk_ndx].
     pp_size_mb)
   ENDIF
   SET autopop_screen->disk[dss_disk_ndx].free_disk_space_mb = (autopop_screen->disk[dss_disk_ndx].
   free_disk_space_mb - dss_file_size)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE get_space_rounded(space_add_in,pp_size_in)
   DECLARE space_add_out = f8 WITH public, noconstant(0.0)
   IF ((dm_err->debug_flag > 1))
    SET dm_err->eproc = build("In get_space_rounded subroutine")
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET space_add_out = 0.0
   IF (mod(cnvtint(space_add_in),cnvtint(pp_size_in)) > 0)
    SET space_add_out = (space_add_in+ (cnvtint(pp_size_in) - mod(cnvtint(space_add_in),cnvtint(
      pp_size_in))))
   ELSE
    SET space_add_out = space_add_in
   ENDIF
   RETURN(space_add_out)
 END ;Subroutine
 SUBROUTINE dm2_parse_aix_vg_disk_file(sbr_dsk_fname)
   DECLARE disk_str = vc WITH public
   FREE RECORD dm2parse
   RECORD dm2parse(
     1 attr1 = vc
     1 attr1sep = vc
     1 attr2 = vc
     1 attr2sep = vc
     1 attr3 = vc
     1 attr3sep = vc
     1 attr4 = vc
     1 attr4sep = vc
     1 attr5 = vc
     1 attr5sep = vc
     1 qual[*]
       2 attr1val = vc
       2 attr2val = vc
       2 attr3val = vc
       2 attr4val = vc
       2 attr5val = vc
   ) WITH public
   SET dm2parse->attr1 = "PHYSICAL VOLUME:"
   SET dm2parse->attr1sep = " "
   SET dm2parse->attr2 = "VOLUME GROUP:"
   SET dm2parse->attr2sep = " "
   SET dm2parse->attr3 = "PP SIZE:"
   SET dm2parse->attr3sep = " "
   SET dm2parse->attr4 = "TOTAL PPs:"
   SET dm2parse->attr4sep = " "
   SET dm2parse->attr5 = "FREE PPs:"
   SET dm2parse->attr5sep = " "
   SET dm_err->eproc = build("Parsing list of aix disks in volume groups")
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dm2parse_output(5,sbr_dsk_fname,"H"))
    IF ((dm_err->debug_flag > 1))
     CALL echorecord(dm2parse)
    ENDIF
    SET stat = alterlist(rdisk->qual,size(dm2parse->qual,5))
    FOR (ts_cnt_var = 1 TO size(dm2parse->qual,5))
      SET end_pos = findstring(" ",dm2parse->qual[ts_cnt_var].attr1val)
      IF (end_pos > 1)
       SET rdisk->qual[ts_cnt_var].disk_name = substring(1,(end_pos - 1),dm2parse->qual[ts_cnt_var].
        attr1val)
       SET end_pos = 0
      ENDIF
      IF (trim(dm2parse->qual[ts_cnt_var].attr2val,3) > " ")
       SET rdisk->qual[ts_cnt_var].vg_name = trim(dm2parse->qual[ts_cnt_var].attr2val,3)
       IF (cnvtupper(rdisk->qual[ts_cnt_var].vg_name)="ROOTVG")
        SET rdisk->qual[ts_cnt_var].root_ind = 1
       ELSE
        SET rdisk->qual[ts_cnt_var].root_ind = 0
       ENDIF
      ENDIF
      SET end_pos = findstring(" ",dm2parse->qual[ts_cnt_var].attr3val)
      IF (end_pos > 1)
       SET rdisk->qual[ts_cnt_var].pp_size_mb = cnvtreal(substring(1,(end_pos - 1),dm2parse->qual[
         ts_cnt_var].attr3val))
       SET end_pos = 0
      ENDIF
      SET start_pos = findstring("(",dm2parse->qual[ts_cnt_var].attr4val)
      SET end_pos = findstring("m",dm2parse->qual[ts_cnt_var].attr4val)
      IF (start_pos > 0
       AND end_pos > 0)
       SET rdisk->qual[ts_cnt_var].total_space_mb = cnvtreal(substring((start_pos+ 1),((end_pos -
         start_pos) - 2),dm2parse->qual[ts_cnt_var].attr4val))
       SET start_pos = 0
       SET end_pos = 0
      ENDIF
      SET start_pos = findstring("(",dm2parse->qual[ts_cnt_var].attr5val)
      SET end_pos = findstring("m",dm2parse->qual[ts_cnt_var].attr5val)
      IF (start_pos > 0
       AND end_pos > 0)
       SET rdisk->qual[ts_cnt_var].free_space_mb = cnvtreal(substring((start_pos+ 1),((end_pos -
         start_pos) - 2),dm2parse->qual[ts_cnt_var].attr5val))
       SET rdisk->qual[ts_cnt_var].new_free_space_mb = rdisk->qual[ts_cnt_var].free_space_mb
       SET start_pos = 0
       SET end_pos = 0
      ENDIF
    ENDFOR
   ELSE
    RETURN(0)
   ENDIF
   IF (size(rdisk->qual,5) > 0)
    SET rdisk->disk_cnt = size(rdisk->qual,5)
    SET rdisk_filled = "Y"
    SET dm_err->eproc = build("Disk file parsed successfully")
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ELSE
    CALL clear(23,1,130)
    SET dm_err->eproc = build("Parsing disk file.  RDISK not filled.")
    SET dm_err->err_ind = 1
    CALL disp_msg(" ",dm_err->logfile,1)
    CALL text(23,2,"Unable to load system disk information - exiting application.")
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_parse_hpux_disk_file(sbr_dsk_fname)
   DECLARE disk_str = vc WITH public
   FREE RECORD dm2parse
   RECORD dm2parse(
     1 attr1 = vc
     1 attr1sep = vc
     1 attr2 = vc
     1 attr2sep = vc
     1 attr3 = vc
     1 attr3sep = vc
     1 attr4 = vc
     1 attr4sep = vc
     1 qual[*]
       2 attr1val = vc
       2 attr2val = vc
       2 attr3val = vc
       2 attr4val = vc
   )
   SET dm2parse->attr1 = "VG Name"
   SET dm2parse->attr1sep = " "
   SET dm2parse->attr2 = "PE Size (Mbytes)"
   SET dm2parse->attr2sep = " "
   SET dm2parse->attr3 = "Total PE"
   SET dm2parse->attr3sep = " "
   SET dm2parse->attr4 = "Free PE"
   SET dm2parse->attr4sep = " "
   IF (dm2parse_output(4,sbr_dsk_fname,"V"))
    SET stat = alterlist(rdisk->qual,size(dm2parse->qual,5))
    FOR (ts_cnt_var = 1 TO size(dm2parse->qual,5))
      SET rdisk->qual[ts_cnt_var].disk_name = dm2parse->qual[ts_cnt_var].attr1val
      SET rdisk->qual[ts_cnt_var].vg_name = rdisk->qual[ts_cnt_var].disk_name
      IF (cnvtupper(rdisk->qual[ts_cnt_var].disk_name)="/DEV/VG00")
       SET rdisk->qual[ts_cnt_var].root_ind = 1
      ELSE
       SET rdisk->qual[ts_cnt_var].root_ind = 0
      ENDIF
      SET rdisk->qual[ts_cnt_var].pp_size_mb = cnvtreal(dm2parse->qual[ts_cnt_var].attr2val)
      SET rdisk->qual[ts_cnt_var].total_space_mb = cnvtreal(dm2parse->qual[ts_cnt_var].attr3val)
      SET rdisk->qual[ts_cnt_var].free_space_mb = cnvtreal(dm2parse->qual[ts_cnt_var].attr4val)
      SET rdisk->qual[ts_cnt_var].new_free_space_mb = rdisk->qual[ts_cnt_var].free_space_mb
      SET rdisk->qual[ts_cnt_var].total_space_mb = (rdisk->qual[ts_cnt_var].pp_size_mb * rdisk->qual[
      ts_cnt_var].total_space_mb)
      SET rdisk->qual[ts_cnt_var].free_space_mb = (rdisk->qual[ts_cnt_var].pp_size_mb * rdisk->qual[
      ts_cnt_var].free_space_mb)
      SET rdisk->qual[ts_cnt_var].new_free_space_mb = (rdisk->qual[ts_cnt_var].pp_size_mb * rdisk->
      qual[ts_cnt_var].new_free_space_mb)
    ENDFOR
   ELSE
    RETURN(0)
   ENDIF
   IF (size(rdisk->qual,5) > 0)
    SET rdisk->disk_cnt = size(rdisk->qual,5)
    SET rdisk_filled = "Y"
    SET dm_err->eproc = build("Disk file parsed successfully")
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ELSE
    CALL clear(23,1,130)
    SET dm_err->eproc = build("Parsing disk file.  RDISK not filled.")
    SET dm_err->err_ind = 1
    CALL disp_msg(" ",dm_err->logfile,1)
    CALL text(23,2,"Unable to load system disk information - exiting application.")
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_create_dir(sbr_new_dir,sbr_new_dir_type)
   DECLARE dcd_cmd_txt = vc WITH protect, noconstant(" ")
   DECLARE dcd_stat = i2 WITH protect, noconstant(0)
   DECLARE dcd_strip_txt1 = vc WITH protect, noconstant("")
   DECLARE dcd_strip_txt2 = vc WITH protect, noconstant("")
   DECLARE dcd_num_hold = i2 WITH protect, noconstant(0)
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dcd_cmd_txt = concat("create/dir ",sbr_new_dir)
   ELSE
    SET dcd_cmd_txt = concat("mkdir ",sbr_new_dir)
   ENDIF
   CALL dm2_push_dcl(dcd_cmd_txt)
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF (sbr_new_dir_type="DB")
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dcd_num_hold = findstring(".",sbr_new_dir,1,1)
     SET dcd_strip_txt1 = substring(1,(dcd_num_hold - 1),sbr_new_dir)
     SET dcd_strip_txt2 = substring((dcd_num_hold+ 1),((findstring("]",sbr_new_dir,1,1) -
      dcd_num_hold) - 1),sbr_new_dir)
     SET dcd_cmd_txt = concat("set file/prot=(s:rwed,o:rwed,g:rwed,w:rwe) ",dcd_strip_txt1,"]",
      dcd_strip_txt2,".dir")
     CALL dm2_push_dcl(dcd_cmd_txt)
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_delete_dir(ddd_dir)
   DECLARE ddd_cmd_txt = vc WITH protect, noconstant(" ")
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET ddd_cmd_txt = concat("del ",trim(ddd_dir),";")
   ENDIF
   IF (dm2_push_dcl(ddd_cmd_txt)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_get_novg_disk_info_aix(null)
   IF ((dm_err->debug_flag > 0))
    SET message = nowindow
   ENDIF
   SET dm_err->eproc = "Get list of disks not in volume group and store them in rDisk."
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE dgn_cmd = vc WITH protect, noconstant(" ")
   DECLARE dgn_drive = vc WITH protect, noconstant(" ")
   SET dgn_cmd = "lspv | grep vpath"
   IF (dm2_push_dcl(dgn_cmd)=0)
    IF ((dm_err->err_ind=1))
     IF ((dm_err->emsg > " "))
      RETURN(0)
     ELSE
      SET dm_err->eproc = "Message reported when getting vpath is okay - process continuing"
      CALL disp_msg(" ",dm_err->logfile,0)
      SET dm_err->err_ind = 0
     ENDIF
    ENDIF
   ELSE
    SET dgn_drive = "vpath"
   ENDIF
   IF (dgn_drive != "vpath")
    SET dgn_cmd = "lspv | grep hdisk"
    IF (dm2_push_dcl(dgn_cmd)=0)
     IF ((dm_err->err_ind=1))
      IF ((dm_err->emsg > " "))
       RETURN(0)
      ELSE
       SET dm_err->eproc = "Message reported when getting hdisk is okay - process continuing"
       CALL disp_msg(" ",dm_err->logfile,0)
       SET dm_err->err_ind = 0
      ENDIF
     ENDIF
    ELSE
     SET dgn_drive = "hdisk"
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("dgn_drive =",dgn_drive))
   ENDIF
   IF (dgn_drive=" ")
    SET message = nowidnow
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Get list of disks not in volume group and store them in rDisk."
    SET dm_err->emsg =
    "Cerner currently recognizes only VPATH and HDISK disk names.  Unable to find a recognized storage disk name."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dgn_drive="hdisk")
    SET dgn_cmd = "lspv | grep hdisk | grep None"
   ELSE
    SET dgn_cmd = "lspv | grep vpath | grep None"
   ENDIF
   IF (dm2_push_dcl(dgn_cmd)=0)
    IF ((dm_err->err_ind=1))
     IF ((dm_err->emsg > " "))
      RETURN(0)
     ELSE
      SET dm_err->eproc = "Message reported when getting list of disks is okay - process continuing"
      CALL disp_msg("",dm_err->logfile,0)
      SET dm_err->err_ind = 0
      RETURN(1)
     ENDIF
    ENDIF
   ENDIF
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(dm_err->errfile)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    HEAD REPORT
     end_pos = 0
    DETAIL
     end_pos = 0, end_pos = findstring(" ",r.line)
     IF (end_pos > 0)
      rdisk->disk_cnt = (rdisk->disk_cnt+ 1), stat = alterlist(rdisk->qual,rdisk->disk_cnt), rdisk->
      qual[rdisk->disk_cnt].disk_name = substring(1,(end_pos - 1),r.line)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(concat("Get list of disks not in volume group.")) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    SET message = window
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_get_vgs(null)
   SET dm_err->eproc = "Get list of volume groups."
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE dgv_cmd = vc WITH protect, noconstant(" ")
   SET rvg->vg_cnt = 0
   SET stat = alterlist(rvg->qual,0)
   IF ((dm2_sys_misc->cur_os="AIX"))
    SET dgv_cmd = "lsvg -o"
   ELSE
    SET dgv_cmd = 'vgdisplay|grep "VG Name"|cut -d/ -f3'
   ENDIF
   IF (dm2_push_dcl(dgv_cmd)=0)
    RETURN(0)
   ENDIF
   FREE DEFINE rtl
   FREE SET file_loc
   SET logical file_loc value(dm_err->errfile)
   DEFINE rtl logical("file_loc")
   SELECT INTO "nl:"
    r.line
    FROM rtlt r
    DETAIL
     IF (trim(r.line) != "rootvg")
      rvg->vg_cnt = (rvg->vg_cnt+ 1), stat = alterlist(rvg->qual,rvg->vg_cnt), rvg->qual[rvg->vg_cnt]
      .vg_name = trim(r.line)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error("Get list of volume groups.") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   FOR (dgv_i = 1 TO rvg->vg_cnt)
     IF ((dm2_sys_misc->cur_os="AIX"))
      SET dgv_cmd = concat("lsvg ",trim(rvg->qual[dgv_i].vg_name))
     ELSE
      SET dgv_cmd = concat("vgdisplay ",trim(rvg->qual[dgv_i].vg_name))
     ENDIF
     IF (dm2_push_dcl(dgv_cmd)=0)
      RETURN(0)
     ENDIF
     IF (dm2_parse_aix_vg(dm_err->errfile,dgv_i)=0)
      RETURN(0)
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_parse_aix_vg(dpa_fname,dpa_rvg_idx)
   SET dm_err->eproc = build("Parsing volume group's infomation")
   CALL disp_msg(" ",dm_err->logfile,0)
   FREE RECORD dm2parse
   RECORD dm2parse(
     1 attr1 = vc
     1 attr1sep = vc
     1 attr2 = vc
     1 attr2sep = vc
     1 attr3 = vc
     1 attr3sep = vc
     1 qual[*]
       2 attr1val = vc
       2 attr2val = vc
       2 attr3val = vc
   ) WITH public
   IF ((dm2_sys_misc->cur_os="AIX"))
    SET dm2parse->attr1 = "PP SIZE:"
    SET dm2parse->attr1sep = " "
    SET dm2parse->attr2 = "TOTAL PPs:"
    SET dm2parse->attr2sep = " "
    SET dm2parse->attr3 = "FREE PPs:"
    SET dm2parse->attr3sep = " "
   ELSE
    SET dm2parse->attr1 = "PE Size (Mbytes)"
    SET dm2parse->attr1sep = " "
    SET dm2parse->attr2 = "Total PE"
    SET dm2parse->attr2sep = " "
    SET dm2parse->attr3 = "Free PE"
    SET dm2parse->attr3sep = " "
   ENDIF
   IF (dm2parse_output(3,dpa_fname,"H"))
    IF (size(dm2parse->qual,5)=1)
     SET dpa_i = 1
     IF ((dm2_sys_misc->cur_os="AIX"))
      SET end_pos = findstring(" ",dm2parse->qual[dpa_i].attr1val)
      IF (end_pos > 1)
       SET rvg->qual[dpa_rvg_idx].psize = cnvtreal(substring(1,(end_pos - 1),dm2parse->qual[dpa_i].
         attr1val))
       SET end_pos = 0
      ENDIF
      SET end_pos = findstring(" ",dm2parse->qual[dpa_i].attr2val)
      IF (end_pos > 1)
       SET rvg->qual[dpa_rvg_idx].ttl_pps = cnvtreal(substring(1,(end_pos - 1),dm2parse->qual[dpa_i].
         attr2val))
       SET end_pos = 0
      ENDIF
      SET end_pos = findstring(" ",dm2parse->qual[dpa_i].attr3val)
      IF (end_pos > 1)
       SET rvg->qual[dpa_rvg_idx].free_pps = cnvtreal(substring(1,(end_pos - 1),dm2parse->qual[dpa_i]
         .attr3val))
       SET end_pos = 0
      ENDIF
      SET start_pos = findstring("(",dm2parse->qual[dpa_i].attr3val)
      SET end_pos = findstring("m",dm2parse->qual[dpa_i].attr3val)
      IF (start_pos > 0
       AND end_pos > 0)
       SET rvg->qual[dpa_rvg_idx].free_mb = cnvtreal(substring((start_pos+ 1),((end_pos - start_pos)
          - 2),dm2parse->qual[dpa_i].attr3val))
       SET start_pos = 0
       SET end_pos = 0
      ENDIF
     ELSE
      SET rvg->qual[dpa_rvg_idx].psize = cnvtreal(dm2parse->qual[dpa_i].attr1val)
      SET rvg->qual[dpa_rvg_idx].ttl_pps = cnvtreal(dm2parse->qual[dpa_i].attr2val)
      SET rvg->qual[dpa_rvg_idx].free_pps = cnvtreal(dm2parse->qual[dpa_i].attr3val)
      SET rvg->qual[dpa_rvg_idx].free_mb = (rvg->qual[dpa_rvg_idx].free_pps * rvg->qual[dpa_rvg_idx].
      psize)
     ENDIF
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat(
      "Parse VG information failed.  Multiple lines of information found for VG ",rvg->qual[
      dpa_rvg_idx].vg_name)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_get_nomnt_disk_info_axp(null)
   SET dm_err->eproc = "Get list of not mounted disks"
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE dgn_dcl_str = vc WITH protect, noconstant(" ")
   DECLARE dgn_rtl_file = vc WITH protect, noconstant("")
   DECLARE dgn_spot = i4 WITH protect, noconstant(0)
   FREE RECORD dgn_disks
   RECORD dgn_disks(
     1 disk_cnt = i4
     1 disk[*]
       2 disk_name = vc
       2 remote_ind = i2
   )
   SET dgn_dcl_str = "@cer_install:dm2_get_nomnt_disk_info.com"
   IF ( NOT (dm2_push_dcl(dgn_dcl_str)))
    RETURN(0)
   ENDIF
   SET dgn_rtl_file = "ccluserdir:dm2_disk_list.tmp"
   SET logical axp_disk_info dgn_rtl_file
   FREE DEFINE rtl
   DEFINE rtl "axp_disk_info"
   SELECT INTO "nl:"
    t.line
    FROM rtlt t
    WHERE t.line > " "
    DETAIL
     dgn_disks->disk_cnt = (dgn_disks->disk_cnt+ 1), stat = alterlist(dgn_disks->disk,dgn_disks->
      disk_cnt), dgn_spot = 0,
     dgn_spot = findstring(" ",t.line,1)
     IF (dgn_spot > 0)
      dgn_disks->disk[dgn_disks->disk_cnt].disk_name = substring(1,(dgn_spot - 1),t.line)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   FOR (dgn_i = 1 TO dgn_disks->disk_cnt)
     SET dgn_dcl_str = concat("sho device ",dgn_disks->disk[dgn_i].disk_name," /out=disk_info.tmp")
     IF ( NOT (dm2_push_dcl(dgn_dcl_str)))
      RETURN(0)
     ENDIF
     SET dgn_rtl_file = "ccluserdir:disk_info.tmp"
     SET logical axp_disk_info dgn_rtl_file
     FREE DEFINE rtl
     DEFINE rtl "axp_disk_info"
     SELECT INTO "nl:"
      t.line
      FROM rtlt t
      WHERE t.line > " "
      DETAIL
       dgn_spot = 0, dgn_spot = findstring("REMOTE MOUNT",cnvtupper(t.line),1)
       IF (dgn_spot > 0)
        dgn_disks->disk[dgn_i].remote_ind = 1
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error("filter out disks that are remote mount") != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
   ENDFOR
   SET rdisk->disk_cnt = size(rdisk->qual,5)
   SELECT INTO "nl:"
    dgn_disks->disk[d.seq].disk_name
    FROM (dummyt d  WITH seq = value(dgn_disks->disk_cnt))
    WHERE (dgn_disks->disk[d.seq].remote_ind=0)
    DETAIL
     rdisk->disk_cnt = (rdisk->disk_cnt+ 1), stat = alterlist(rdisk->qual,rdisk->disk_cnt), rdisk->
     qual[rdisk->disk_cnt].disk_name = dgn_disks->disk[d.seq].disk_name
    WITH nocounter
   ;end select
   IF (check_error("Populate rDisk with not mounted disks") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(dgn_disks)
    CALL echorecord(rdisk)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_make_vg(dmv_vg_name,dmv_psize,dmv_disk_name)
   IF ((dm_err->debug_flag > 0))
    SET message = nowindow
   ENDIF
   SET dm_err->eproc = concat("Create new volume group ",dmv_vg_name," with disks ",dmv_disk_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE dmv_cmd = vc WITH protect, noconstant(" ")
   IF (substring(1,1,dmv_disk_name)="v")
    SET dmv_cmd = "mkvg4vp"
   ELSEIF (substring(1,1,dmv_disk_name)="h")
    SET dmv_cmd = "mkvg"
   ENDIF
   SET dmv_cmd = concat(dmv_cmd," -B -f -y ",dmv_vg_name," -s ",cnvtstring(dmv_psize),
    " ",dmv_disk_name)
   IF (dm2_push_dcl(dmv_cmd)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    SET message = window
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_extend_vg(dev_vg_name,dev_disk_name)
   IF ((dm_err->debug_flag > 0))
    SET message = nowindow
   ENDIF
   SET dm_err->eproc = concat("Extend existing volume group ",dev_vg_name," with disk ",dev_disk_name
    )
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE dev_cmd = vc WITH protect, noconstant(" ")
   IF (substring(1,1,dev_disk_name)="v")
    SET dev_cmd = "extendvg4vp"
   ELSEIF (substring(1,1,dev_disk_name)="h")
    SET dev_cmd = "extendvg"
   ENDIF
   SET dev_cmd = concat(dev_cmd," -f ",dev_vg_name," ",dev_disk_name)
   IF (dm2_push_dcl(dev_cmd)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    SET message = window
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_reduce_vg(drv_vg_name,drv_disk_name)
   SET dm_err->eproc = concat("Reduce existing volume group ",drv_vg_name," with disk ",drv_disk_name
    )
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE drv_del_vg = i2 WITH protect, noconstant(0)
   SET width = 132
   SET message = window
   CALL clear(1,1)
   CALL text(1,1,dm_err->eproc)
   CALL text(2,1,"Would you like to (C)ontinue or (Q)uit?")
   CALL accept(2,60,"P;CU","C"
    WHERE curaccept IN ("C", "Q"))
   IF (curaccept="Q")
    SET dm_err->emsg = "User choose to quit the program."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET message = nowindow
   DECLARE drv_cmd = vc WITH protect, noconstant(" ")
   SET drv_cmd = concat("reducevg ",drv_vg_name," ",drv_disk_name)
   IF (dm2_push_dcl(drv_cmd)=0)
    RETURN(0)
   ENDIF
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(dm_err->errfile)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    DETAIL
     IF ( NOT (drv_del_vg))
      drv_del_vg = findstring("ldeletepv",r.line)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(concat("Parsing error file ",dm_err->errfile))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (drv_del_vg)
    IF ((dm_err->debug_flag > 0))
     SET message = nowindow
     CALL echo(concat("vg ",drv_vg_name," was deleted."))
     SET message = window
    ENDIF
    SET dpf_existing_vg_ind = 0
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_init_mount_disk(dim_disk_name,dim_vol_lbl)
   SET dm_err->eproc = concat("Mount disk ",trim(dim_disk_name)," on vol_lable ",dim_vol_lbl)
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE dimd_cmd = vc WITH protect, noconstant(" ")
   DECLARE dimd_fnd = i2 WITH protect, noconstant(0)
   IF ((dm2_create_dom->dbtype != "ADMIN"))
    WHILE (dim_vol_lbl="dm2_not_set")
      SET width = 132
      SET message = window
      CALL clear(1,1)
      CALL text(2,1,concat("Please enter volume label to mount disk ",dim_disk_name,":"))
      CALL accept(2,60,"P(20);cu")
      SET dim_vol_lbl = curaccept
      SET dimd_fnd = 0
      SET dimd_fnd = locateval(dimd_fnd,1,size(rdisk->qual,5),dim_vol_lbl,rdisk->qual[dimd_fnd].
       volume_label)
      IF (dimd_fnd)
       CALL text(4,1,concat("The volume lable name ",dim_vol_lbl,
         " is used.  Please enter a different name."))
       CALL text(6,1,"Would you like to (C)ontinue or (Q)uit?")
       CALL accept(6,60,"P;CU","C"
        WHERE curaccept IN ("C", "Q"))
       IF (curaccept="Q")
        SET dm_err->emsg = "User choose to quit the program."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN("ERROR")
       ENDIF
       SET dim_vol_lbl = "dm2_not_set"
      ENDIF
      SET message = nowindow
    ENDWHILE
   ELSE
    SET dimd_fnd = 1
    WHILE (dimd_fnd)
      SET dimd_fnd = 0
      SET dimd_fnd = locateval(dimd_fnd,1,size(rdisk->qual,5),dim_vol_lbl,rdisk->qual[dimd_fnd].
       volume_label)
      IF (dimd_fnd)
       SET dim_vol_lbl = build("ADMIN",dpf_admin_lbl_cnt)
       SET dpf_admin_lbl_cnt = (dpf_admin_lbl_cnt+ 1)
      ENDIF
    ENDWHILE
   ENDIF
   SET width = 132
   SET message = window
   CALL clear(1,1)
   CALL text(1,1,concat("Initialize and Mount disk ",trim(dim_disk_name)," on vol_lable ",dim_vol_lbl
     ))
   CALL text(2,1,"Would you like to (C)ontinue or (Q)uit?")
   CALL accept(2,60,"P;CU","C"
    WHERE curaccept IN ("C", "Q"))
   IF (curaccept="Q")
    SET message = nowindow
    SET dm_err->emsg = "User choose to quit the program."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("ERROR")
   ENDIF
   SET message = nowindow
   SET dimd_cmd = concat("$init/head=65536/clus=16/own=[500,0]/nohigh ",trim(dim_disk_name)," ",
    dim_vol_lbl)
   IF (dm2_push_dcl(dimd_cmd)=0)
    RETURN("ERROR")
   ENDIF
   IF (dm2_check_cluster_lic(null))
    SET dimd_cmd = concat("$mount/clus/win=28/noassist ",trim(dim_disk_name)," ",dim_vol_lbl," ",
     dim_vol_lbl)
   ELSE
    IF ((dm_err->err_ind=0))
     SET dimd_cmd = concat("$mount/sys/win=28/noassist ",trim(dim_disk_name)," ",dim_vol_lbl," ",
      dim_vol_lbl)
    ELSE
     RETURN("ERROR")
    ENDIF
   ENDIF
   IF (dm2_push_dcl(dimd_cmd)=0)
    RETURN("ERROR")
   ENDIF
   RETURN(dim_vol_lbl)
 END ;Subroutine
 SUBROUTINE dm2_check_cluster_lic(null)
   SET dm_err->eproc = "Checking if vmscluster license is loaded on the system."
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE dcc_cmd = vc WITH protect, noconstant(" ")
   DECLARE dcc_str = vc WITH protect, noconstant(" ")
   DECLARE dcc_find = i2 WITH protect, noconstant(0)
   SET dcc_cmd = "$show license vmscluster"
   SET dcc_str = "%SHOW-I-NOLICMATCH, no licenses match search criteria"
   IF (dm2_push_dcl(dcc_cmd)=0)
    RETURN(0)
   ENDIF
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(dm_err->errfile)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    HEAD REPORT
     dcc_find = 0
    DETAIL
     IF (dcc_find=0)
      dcc_find = findstring(dcc_str,r.line)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error("Checking if vmscluster license is loaded on the system.") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dcc_find > 0)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_dismount_disk(ddd_vol_label)
   SET dm_err->eproc = concat("Dismount disk ",ddd_vol_label)
   CALL disp_msg("",dm_err->logfile,0)
   SET width = 132
   SET message = window
   CALL clear(1,1)
   CALL text(1,1,dm_err->eproc)
   CALL text(2,1,"Would you like to (C)ontinue or (Q)uit?")
   CALL accept(2,60,"P;CU","C"
    WHERE curaccept IN ("C", "Q"))
   IF (curaccept="Q")
    SET dm_err->emsg = "User choose to quit the program."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET message = nowindow
   DECLARE ddd_cmd = vc WITH protect, noconstant(" ")
   SET ddd_cmd = concat("dismount ",ddd_vol_label)
   IF (dm2_push_dcl(ddd_cmd)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_get_mwc_flag(dgm_disk_name)
   SET dm_err->eproc = concat("Get mirror-write consistency for disk ",trim(dgm_disk_name))
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   DECLARE dgm_cmd = vc WITH protect, noconstant(" ")
   DECLARE dgm_str = vc WITH protect, noconstant(" ")
   SET dgm_cmd = concat("lqueryvg -p /dev/",trim(dgm_disk_name)," -X")
   IF (dm2_push_dcl(dgm_cmd)=0)
    RETURN("e")
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN("e")
   ENDIF
   FREE DEFINE rtl
   FREE SET file_loc
   SET logical file_loc value(dm_err->errfile)
   DEFINE rtl "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtlt r
    HEAD REPORT
     end_pos = 0
    DETAIL
     end_pos = findstring(" ",r.line)
     IF (end_pos > 0)
      dgm_str = substring(1,(end_pos - 1),r.line)
      IF ((dm_err->debug_flag > 0))
       CALL echo(dgm_str)
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(concat("Get mirror-write consistency for disk ",trim(dgm_disk_name))) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("e")
   ENDIF
   IF (dgm_str="0")
    RETURN("y")
   ELSE
    RETURN("n")
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_aix_remove_lv(sbr_arl_db_name)
   DECLARE sbr_arl_outfile = vc WITH noconstant("dm2_not_set")
   DECLARE sbr_arl_rmlv_str = vc WITH noconstant("dm2_not_set")
   SET dm_err->eproc = "Removing raw logical volumes associated with the database."
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (get_unique_file("dm2_rmlv_cmd",".out")=0)
    RETURN(0)
   ENDIF
   SET sbr_arl_outfile = dm_err->unique_fname
   IF ((dm2_sys_misc->cur_os="AIX"))
    SET sbr_arl_rmlv_str = concat("cd /dev; ls ",char(42),cnvtlower(sbr_arl_db_name),char(42),
     " | while read a; do if [ -b $a ]; then rmlv -f $a >> ",
     sbr_arl_outfile,"; fi; done 2>&1")
   ELSE
    SET sbr_arl_rmlv_str = concat(
     "vgdisplay|grep 'VG Name'|cut -d/ -f3 |while read a; do ls /dev/$a/",char(42),cnvtlower(
      sbr_arl_db_name),char(42)," | while read z; do if [ -b $z ]; then lvremove -f $z >> ",
     sbr_arl_outfile,"; fi; done; done 2>&1")
   ENDIF
   IF (dm2_push_dcl(sbr_arl_rmlv_str)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_rename_login_default(sbr_rld_mode)
   DECLARE sbr_rld_backup = vc WITH constant("BACKUP")
   DECLARE sbr_rld_restore = vc WITH constant("RESTORE")
   DECLARE sbr_rld_bkup_name = vc WITH public, constant("login_save.ccl")
   DECLARE sbr_rld_real_name = vc WITH public, constant("login_default.ccl")
   DECLARE sbr_rld_cmd_str = vc WITH public, noconstant("dm2_not_set")
   DECLARE sbr_rld_ccludir = vc WITH public, noconstant("dm2_not_set")
   CASE (cnvtupper(sbr_rld_mode))
    OF sbr_rld_backup:
     IF ((dm2_sys_misc->cur_os="AXP"))
      IF (findfile(concat("CCLUSERDIR:",sbr_rld_real_name))=0)
       SET dm_err->eproc = "No login_default.ccl file found in CCLUSERDIR."
       RETURN(1)
      ENDIF
      SET sbr_rld_cmd_str = concat("rename CCLUSERDIR:",sbr_rld_real_name," CCLUSERDIR:",
       sbr_rld_bkup_name)
     ELSE
      IF (findfile(concat("$CCLUSERDIR/",sbr_rld_real_name))=0)
       SET dm_err->eproc = "No login_default.ccl file found in CCLUSERDIR."
       RETURN(1)
      ENDIF
      SET sbr_rld_cmd_str = concat("mv -f $CCLUSERDIR/",sbr_rld_real_name," $CCLUSERDIR/",
       sbr_rld_bkup_name)
     ENDIF
    OF sbr_rld_restore:
     IF ((dm2_sys_misc->cur_os="AXP"))
      IF (findfile(concat("CCLUSERDIR:",sbr_rld_bkup_name))=0)
       SET dm_err->eproc = "No login_save.ccl file found in CCLUSERDIR."
       RETURN(1)
      ENDIF
      SET sbr_rld_cmd_str = concat("rename CCLUSERDIR:",sbr_rld_bkup_name," CCLUSERDIR:",
       sbr_rld_real_name)
     ELSE
      IF (findfile(concat("$CCLUSERDIR/",sbr_rld_bkup_name))=0)
       SET dm_err->eproc = "No login_save.ccl file found in CCLUSERDIR."
       RETURN(1)
      ENDIF
      SET sbr_rld_cmd_str = concat("mv -f $CCLUSERDIR/",sbr_rld_bkup_name," $CCLUSERDIR/",
       sbr_rld_real_name)
     ENDIF
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "DM2_RENAME_LOGIN_DEFAULT: validating mode."
     SET dm_err->emsg = concat("Invalid mode of operation: <",sbr_rld_mode,">")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
   ENDCASE
   IF (dm2_push_dcl(sbr_rld_cmd_str)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 IF (check_logfile("dm2_tspace_menu",".log","Tablespace Menu")=0)
  GO TO exit_program
 ENDIF
 FREE RECORD tspace_type
 RECORD tspace_type(
   1 qual[*]
     2 ts_type = vc
 )
 FREE RECORD rd_pp_sizes
 RECORD rd_pp_sizes(
   1 qual[*]
     2 rd_size = f8
 )
 FREE RECORD ncont_screen
 RECORD ncont_screen(
   1 cont_cnt = i4
   1 remain_space_add = f8
   1 user_bytes_orig = f8
   1 user_bytes = f8
   1 cont[*]
     2 volume_label = vc
     2 disk_name = vc
     2 vg_name = vc
     2 disk_idx = i4
     2 lv_filename = vc
     2 free_disk_space_mb = f8
     2 pp_size_mb = f8
     2 pps_to_add = f8
     2 space_to_add = f8
     2 cont_tspace_rel_key = i4
     2 cont_size_mb = f8
     2 delete_ind = i4
     2 new_ind = i2
     2 add_ext_ind = c1
     2 mwc_flag = i2
   1 top_line = i4
   1 bottom_line = i4
   1 cur_line = i4
   1 max_scroll = i4
   1 max_value = i4
 )
 FREE RECORD hold_datafile
 RECORD hold_datafile(
   1 ts[*]
     2 hd_tspace = vc
     2 df[*]
       3 df_name = vc
       3 device_name = vc
 )
 FREE RECORD dfile_seq
 RECORD dfile_seq(
   1 d_seq = i4
   1 i_seq = i4
   1 l_seq = i4
 )
 SET dfile_seq->d_seq = 0
 SET dfile_seq->i_seq = 0
 SET dfile_seq->l_seq = 0
 SET ncont_screen->top_line = 1
 SET ncont_screen->cur_line = 1
 SET ncont_screen->max_scroll = 10
 FREE RECORD tspace_screen
 RECORD tspace_screen(
   1 top_line = i4
   1 bottom_line = i4
   1 cur_line = i4
   1 max_scroll = i4
   1 max_value = i4
 )
 FREE RECORD ap_spread_rs
 RECORD ap_spread_rs(
   1 ap_tspace[*]
     2 ap_tspace_name = vc
     2 ap_bytes_needed_mb = f8
     2 ap_asm_disk_group = vc
     2 ap_cont[*]
       3 ap_cont_name = vc
       3 ap_space_to_add_mb = f8
       3 ap_disk_name = vc
       3 ap_lv_filename = vc
       3 ap_volume_label = vc
       3 pp_size_mb = f8
       3 ap_vg_name = vc
       3 ap_cont_tspace_rel_key = i4
 )
 FREE RECORD dtm_available_ts
 RECORD dtm_available_ts(
   1 qual[*]
     2 tspace_name = c30
     2 free_bytes = f8
     2 current_size = f8
     2 pct_used = f8
     2 extent_management = vc
 )
 DECLARE get_tspace_info(gti_mod_in=i2,gti_tspace_ind=vc) = i4
 DECLARE scroll(rec_str=vc) = c1
 DECLARE fill_tspace_screen(null) = null
 DECLARE tspace_work_menu(null) = vc
 DECLARE container_work_menu(null) = vc
 DECLARE container_add_menu(null) = vc
 DECLARE container_cancel(null) = vc
 DECLARE container_driver(null) = vc
 DECLARE tspace_driver(null) = null
 DECLARE rdisk_pop(null) = i2
 DECLARE tspace_check_disk_space(help_ndx_in=i4,tcont_ndx_in=i4) = vc
 DECLARE fill_existing_container_listing(null) = null
 DECLARE fill_ncont_screen(s_mode) = null
 DECLARE container_disk_help(cdh_mode_in=i2) = vc
 DECLARE container_check_rootvg(vg_ndx_in=i4) = vc
 DECLARE calc_disk_pp_num(cont_size_in=f8,pp_size_in=f8) = i4
 DECLARE calc_cont_size_mb(pp_size_in=f8,pps_add_in=f8) = f8
 DECLARE get_new_lv_filename(lv_tspace_in=vc,lv_mode=i2,lv_custom_in=vc) = vc
 DECLARE cont_update_rdisk(disk_ndx_in=i4,cu_cont_ndx=i4) = i2
 DECLARE save_cont_to_rtspace(null) = vc
 DECLARE tspace_ncont_rel_key(null) = i4
 DECLARE container_delete(cont_del_ndx=i4) = null
 DECLARE display_container_header(null) = null
 DECLARE container_extend_menu(cont_ext_ndx=i4) = vc
 DECLARE display_autopop_header(ap_type_in=vc) = null
 DECLARE get_total_space_add(gtsa_tspace_type=vc) = f8
 DECLARE autopop_work_menu(awm_type_in=vc) = vc
 DECLARE fill_autopop_screen(fas_mode_in=i2) = null
 DECLARE display_autopop_footer(null) = null
 DECLARE autopop_cancel(null) = null
 DECLARE autopop_add_menu(ap_mode_in=vc) = vc
 DECLARE autopop_spread_files(ap_max_cont_size_in=f8,ap_type_in=vc) = vc
 DECLARE display_filegroup_preview(null) = i2
 DECLARE filegroup_paths_entry(null) = i2
 DECLARE filegroup_parameters_entry(null) = i2
 DECLARE display_filegroup_paths(null) = i2
 DECLARE config_total_disk_space(null) = i2
 DECLARE display_tspace_summary_report(dtsr_mode=i2) = null
 DECLARE tspace_check_complete(null) = vc
 DECLARE ap_get_disk(agd_size_in=f8,agd_last_disk_ndx=i4) = i4
 DECLARE autopop_add_container(aac_tspace_in=i4,aac_disk_in=i4,aac_cont_in=i4,aac_space_add_in=f8) =
 i2
 DECLARE ts_inform(ts_msg_in=vc) = null
 DECLARE save_autopop_to_rtspace(null) = null
 DECLARE save_autopop_to_rdisk(null) = null
 DECLARE ap_disk_delete(ap_del_in=i4) = i2
 DECLARE get_disk_for_lv(gdfl_type=vc,gdfl_name=vc) = i2
 DECLARE rdisk_pop_existing_lv(rpe_fname_in=vc,rpe_cont_ndx=i4,rpe_tspace_ndx=i4) = null
 DECLARE ap_get_remain_space_add(null) = f8
 DECLARE autopop_reset(null) = i2
 DECLARE display_tspace_header(null) = null
 DECLARE ts_disk_refresh(null) = null
 DECLARE ts_view_disk_report(null) = null
 DECLARE ts_check_if_tspace_to_display(null) = i2
 DECLARE rtspace_refresh_cont(rrc_mode=i2) = null
 DECLARE rtspace_refresh(rr_mode=i2,rr_action=vc) = null
 DECLARE ts_sort_rtspace(tsr_sort_type=vc) = null
 DECLARE ts_rtspace_sort_space(trs_mode=i2,trs_type=vc) = null
 DECLARE ts_rtspace_sort_rdisk(trsr_mode=i2) = null
 DECLARE ap_display_pp_totals(adpt_size_in=f8,adpt_pp_size=f8,adpt_max_cont_size=f8,adpt_tspace_type=
  vc) = f8
 DECLARE ts_load_hold_datafile(null) = i2
 DECLARE ts_validate_disk_directories(tvdd_disk_in=vc) = i2
 DECLARE ap_reset_autopop(null) = i2
 DECLARE ts_find_disks_for_datafiles(null) = i2
 DECLARE get_good_chunks(grc_tspace_ndx=i4) = i2
 DECLARE calc_min_space_add(cmsa_tspace_ndx=i4) = i2
 DECLARE fill_default_space_add(fds_tspace_ndx=i4,fds_remain_add=f8) = f8
 DECLARE dtm_figure_extra_container(null) = i2
 DECLARE dtm_gather_tspace_related_info(dgtri_mode=i2,dgtri_type=vc,dgtri_table=vc) = i2
 DECLARE dtm_manual_add_work(dmaw_type_in=vc) = vc
 DECLARE dtm_manual_add_driver(dmad_type_in=vc) = vc
 DECLARE dtm_manual_add_header(dpah_type_in=vc) = null
 DECLARE display_warning(warn_type_in=vc,warn_data_in=vc) = vc
 DECLARE dtm_manual_add_prompts(dpap_type_in=vc) = vc
 DECLARE dtm_validate_tspace(dvt_tspace_in=vc,dvt_type_in=vc,dvt_name_type_in=vc) = i2
 DECLARE dtm_add_to_rtspace(datr_tspace_in=vc,datr_type_in=vc,datr_help_ndx=i4) = i2
 DECLARE dtm_pop_help_array(dpha_order=vc) = i2
 DECLARE dtm_view_manual_listing(null) = i2
 DECLARE retrieve_os_data_diff_node(roddn_mode=i2) = i2
 DECLARE tspace_set_space_add(null) = i2
 DECLARE tspace_set_disk_group(null) = i2
 CASE (currdb)
  OF "DB2UDB":
   DECLARE storage_device = vc WITH public, constant("Container")
  OF "ORACLE":
   DECLARE storage_device = vc WITH public, constant("Datafile")
 ENDCASE
 DECLARE max_size_constant = i4 WITH public, constant(2048)
 DECLARE autopop_ready_ind = i2 WITH public, noconstant(0)
 DECLARE ts_one_time = i2 WITH public, noconstant(0)
 DECLARE temp_space = f8 WITH public, noconstant(0.0)
 DECLARE tcont_cnt = i4 WITH public, noconstant(0)
 DECLARE display_line = i4 WITH public, noconstant(0)
 DECLARE mbytes_needed = f8 WITH public, noconstant(0.0)
 DECLARE scroll_accept = c1 WITH public, noconstant(" ")
 DECLARE row_nbr = i4 WITH public, noconstant(0)
 DECLARE dtm_temp_file = vc WITH public, noconstant(" ")
 DECLARE rdisk_filled = c1 WITH public, noconstant("N")
 DECLARE ts_destination = vc WITH public, noconstant(" ")
 DECLARE total = f8 WITH public, noconstant(0.0)
 DECLARE no_diskspace = c1 WITH public, noconstant("N")
 DECLARE remain_space_mb = f8 WITH public, noconstant(0.0)
 DECLARE ts_cnt_var = i4 WITH public, noconstant(0)
 DECLARE c_help_return = vc WITH public, noconstant(" ")
 DECLARE user_mb = f8 WITH public, noconstant(0.0)
 DECLARE user_mb_display = f8 WITH public, noconstant(0.0)
 DECLARE ap_space_needed = f8 WITH public, noconstant(0.0)
 DECLARE ap_space_needed_mb = f8 WITH public, noconstant(0.0)
 DECLARE max_disk = i4 WITH protect, noconstant(0)
 DECLARE cmaxline = i4 WITH protect, noconstant(16)
 DECLARE cheadlines = i4 WITH protect, noconstant(5)
 DECLARE ts_tspace_cnt = i4 WITH public, noconstant(0)
 DECLARE tspace_build = i2 WITH public, noconstant(0)
 DECLARE tdisk_cnt = i4 WITH public, noconstant(0)
 DECLARE ts_no_schema = i2 WITH public, noconstant(0)
 DECLARE ts_autopop_ok = i2 WITH public, noconstant(0)
 DECLARE ap_pp_restrict = i4 WITH public, noconstant(0)
 DECLARE ap_display_pop_option = i4 WITH public, noconstant(0)
 DECLARE ts_datafile_dir = vc WITH public, noconstant("")
 DECLARE ts_build_attempt = i4 WITH public, noconstant(0)
 DECLARE ts_autopop_attempt = i4 WITH public, noconstant(0)
 DECLARE hd_last_seq = i4 WITH protect, noconstant(0)
 DECLARE dtm_summary_logfile = vc WITH protect, noconstant("")
 DECLARE dtm_max_chunk_size = f8 WITH protect, noconstant(0.0)
 DECLARE dtm_sort_criteria = c1 WITH protect, noconstant("T")
 DECLARE dtm_destination = vc WITH protect, noconstant("")
 DECLARE dtm_from_install = i2 WITH protect, noconstant(0)
 DECLARE dtm_data_file = vc WITH protect, noconstant("")
 DECLARE lmt_level_1m = f8 WITH protect, constant(1048576.0)
 DECLARE dtm_cont_size_mb = f8 WITH protect, noconstant(0.0)
 DECLARE dtm_cnt = i4 WITH protect, noconstant(0)
 DECLARE dtm_fnd = i2 WITH protect, noconstant(0)
 DECLARE dtm_fnd2 = i2 WITH protect, noconstant(0)
 DECLARE dtm_disk_cnt = i4 WITH protect, noconstant(0)
 DECLARE dtm_ap_space_free_mb = f8 WITH public, noconstant(0.0)
 DECLARE dtm_diskgroup = vc WITH public, noconstant("NOT_SET")
 SET width = 132
 IF ((dm_err->debug_flag=722))
  SET message = nowindow
 ELSEIF (validate(drrr_responsefile_in_use,0)=0)
  SET message = window
 ENDIF
 IF (currdb="SQLSRV")
  IF (display_filegroup_preview(null)=0)
   GO TO exit_program
  ENDIF
  IF (filegroup_paths_entry(null)=0)
   GO TO exit_program
  ENDIF
  IF (filegroup_parameters_entry(null)=0)
   GO TO exit_program
  ENDIF
  EXECUTE dm2_create_tspace
  IF ((dm_err->err_ind=1))
   GO TO exit_program
  ENDIF
  GO TO exit_program
 ENDIF
 IF ( NOT (get_unique_file("dm2_tspace_summary",".dat")))
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ELSE
  IF (validate(drrr_responsefile_in_use,0)=1)
   SET dtm_summary_logfile = build(drrr_misc_data->active_dir,dm_err->unique_fname)
  ELSE
   SET dtm_summary_logfile = concat("ccluserdir:",dm_err->unique_fname)
  ENDIF
 ENDIF
 IF ((dir_storage_misc->tgt_storage_type="DM2NOTSET"))
  IF (dir_get_storage_type("")=0)
   GO TO exit_program
  ENDIF
 ENDIF
 IF ((dm2_sys_misc->cur_os IN ("HPX", "AIX")))
  CALL ts_inform("Verifying OSUSER is ROOT")
  IF (curuser != "ROOT")
   SET message = nowindow
   SET dm_err->emsg = concat("Current User: ",curuser,
    ".  You must be logged in as ROOT to run Tspace Menu.")
   SET dm_err->err_ind = 1
   SET dm_err->user_action = "Please log in as ROOT to run DM2_TSPACE_MENU"
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   GO TO exit_program
  ENDIF
 ENDIF
 IF ((dm2_sys_misc->cur_db_os != dm2_sys_misc->cur_os))
  IF ((dir_storage_misc->tgt_storage_type != "ASM"))
   SET dm_err->eproc = 'Executing in "REMOTE" mode'
   CALL disp_msg(" ",dm_err->logfile,0)
   SET rtspace->database_remote = 1
  ENDIF
 ENDIF
 IF ((rtspace->database_remote=0)
  AND (dir_storage_misc->tgt_storage_type != "ASM"))
  SET dm_err->eproc = "Finding data files"
  CALL disp_msg(" ",dm_err->logfile,0)
  SELECT INTO "nl:"
   FROM dba_data_files ddf
   DETAIL
    dtm_data_file = ddf.file_name
   WITH maxqual(ddf,1), nocounter
  ;end select
  IF (findfile(dtm_data_file)=0)
   SET dm_err->eproc = 'Datafile not visible at operating system level. Executing in "REMOTE" mode'
   CALL disp_msg(" ",dm_err->logfile,0)
   SET rtspace->database_remote = 1
  ENDIF
 ENDIF
 IF ((dir_storage_misc->tgt_storage_type="ASM"))
  SET stat = alterlist(tspace_type->qual,1)
  SET tspace_type->qual[1].ts_type = "ALL"
 ELSE
  SET stat = alterlist(tspace_type->qual,3)
  SET tspace_type->qual[1].ts_type = "LOB"
  SET tspace_type->qual[2].ts_type = "DATA"
  SET tspace_type->qual[3].ts_type = "INDEX"
 ENDIF
 IF ((rtspace->dbname=""))
  SET rtspace->dbname = cnvtlower(currdbname)
 ENDIF
 SET rtspace->tmp_table_name = "DM2_TSPACE_SIZE"
 IF ((dm2_sys_misc->cur_db_os="AXP"))
  SET ts_datafile_dir = concat("[",trim(currdbuser),".DB_",trim(rtspace->dbname),"]")
 ELSEIF ((dm2_sys_misc->cur_db_os="AIX"))
  SET ts_datafile_dir = "/dev/r"
 ELSEIF ((dm2_sys_misc->cur_db_os="HPX"))
  SET ts_datafile_dir = "/dev"
 ENDIF
 EXECUTE dm2_set_db_options
 IF ((dm_err->err_ind=1))
  GO TO exit_program
 ENDIF
 IF ((dm2_install_schema->process_option IN ("CHECK", "PREVIEW", "CLIN UPGRADE")))
  IF (dir_get_dg_data(cnvtint(dm2_db_options->use_initprm_assign_dg_ind),dm2_db_options->
   assign_dg_override,dtm_diskgroup)=0)
   GO TO exit_program
  ENDIF
  IF (validate(dir_ui_misc->auto_install_ind,0)=1
   AND dtm_diskgroup="NOT_SET")
   SET dm_err->eproc = "Validating disk group allocated for auto package install."
   SET dm_err->emsg = concat("No Diskgroup found.")
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
 ENDIF
 IF ((rtspace->database_remote=1))
  IF (retrieve_os_data_diff_node(1)=0)
   GO TO exit_program
  ENDIF
 ENDIF
 IF ((dir_storage_misc->tgt_storage_type != "ASM"))
  CALL clear(24,1,130)
  CALL text(24,2,concat("Loading ",storage_device," Information ...."))
  IF (ts_load_hold_datafile(null)=0)
   CALL ts_inform(" Error occurred when loading existing datafiles")
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
 ENDIF
 IF (validate(drrr_responsefile_in_use,0)=1)
  SET dm_err->eproc = "Response file detected and will be used to complete tablespace menu process."
  CALL disp_msg("",dm_err->logfile,0)
  FOR (tspace_cnt = 1 TO size(rtspace->qual,5))
    SET rtspace->qual[tspace_cnt].ct_err_ind = 1
  ENDFOR
  CALL ts_sort_rtspace("SPACE")
  IF (dor_get_diskgroup_info(null)=0)
   GO TO exit_program
  ENDIF
  CALL ts_sort_rtspace("RDISK")
  FOR (dtm_cnt = 1 TO drrr_misc_data->tgt_tspace_dg_cnt)
    SET dtm_fnd = 0
    SET dtm_fnd = locateval(dtm_fnd,1,size(rdisk->qual,5),drrr_misc_data->tgt_tspace_dg[dtm_cnt].
     disk_group,rdisk->qual[dtm_fnd].disk_name)
    IF (dtm_fnd)
     SET dtm_fnd2 = 0
     SET dtm_fnd2 = locateval(dtm_fnd2,1,size(autopop_screen->disk,5),drrr_misc_data->tgt_tspace_dg[
      dtm_cnt].disk_group,autopop_screen->disk[dtm_fnd2].disk_name)
     IF (dtm_fnd2=0)
      SET tdisk_cnt = (tdisk_cnt+ 1)
      SET stat = alterlist(autopop_screen->disk,tdisk_cnt)
      SET autopop_screen->disk_cnt = tdisk_cnt
      SET autopop_screen->disk[tdisk_cnt].disk_idx = dtm_fnd
      SET autopop_screen->disk[tdisk_cnt].disk_name = rdisk->qual[dtm_fnd].disk_name
      SET autopop_screen->disk[tdisk_cnt].free_disk_space_mb = rdisk->qual[dtm_fnd].new_free_space_mb
      SET autopop_screen->disk[tdisk_cnt].orig_disk_space_mb = rdisk->qual[dtm_fnd].new_free_space_mb
      SET dtm_ap_space_free_mb = (dtm_ap_space_free_mb+ autopop_screen->disk[tdisk_cnt].
      free_disk_space_mb)
     ENDIF
    ELSE
     SET dm_err->eproc = "Validating disk groups entered in response file."
     SET dm_err->emsg = concat("Disk group (",drrr_misc_data->tgt_tspace_dg[dtm_cnt].disk_group,
      ") not found.")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
  ENDFOR
  SELECT INTO "nl:"
   FROM dm2_dba_data_files df,
    (dummyt d  WITH seq = size(rtspace->qual,5))
   PLAN (d)
    JOIN (df
    WHERE (rtspace->qual[d.seq].tspace_name=cnvtupper(df.tablespace_name)))
   ORDER BY df.tablespace_name
   HEAD REPORT
    ts_tspace_cnt = 0
   HEAD df.tablespace_name
    dtm_cont_cnt = 0
   DETAIL
    IF (textlen(df.file_name) > 0)
     dtm_cont_size_mb = (dtm_cont_size_mb+ convert_bytes(df.bytes,"b","m"))
    ENDIF
   FOOT  df.tablespace_name
    rtspace->qual[d.seq].cur_bytes_allocated = dtm_cont_size_mb, dtm_cont_size_mb = 0.0
   WITH nocounter
  ;end select
  IF (check_error(concat("Loading rtspace")) != 0)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
  SET ap_space_needed_mb = get_total_space_add("ALL")
  IF ((dm_err->debug_flag > 0))
   CALL echo(build("ap_space_needed_mb = ",ap_space_needed_mb))
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = size(rtspace->qual,5))
   WHERE (rtspace->qual[d.seq].ct_err_ind=1)
    AND (rtspace->qual[d.seq].new_ind=1)
   ORDER BY rtspace->qual[d.seq].bytes_needed DESC
   HEAD REPORT
    dtm_cnt = 0
   DETAIL
    dtm_cnt = (dtm_cnt+ 1), stat = alterlist(ap_spread_rs->ap_tspace,dtm_cnt), ap_spread_rs->
    ap_tspace[dtm_cnt].ap_tspace_name = rtspace->qual[d.seq].tspace_name,
    ap_spread_rs->ap_tspace[dtm_cnt].ap_bytes_needed_mb = convert_bytes(rtspace->qual[d.seq].
     bytes_needed,"b","m")
   WITH nocounter
  ;end select
  IF (check_error(concat("Loading tablespaces into Auto-Populate work structure")) != 0)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
  IF (validate(dm2_bypass_calculated_tablespace_needs,0)=1)
   SET dm_err->eproc =
   "User has elected to not satisfy tablespace requirements calculated by process."
   CALL disp_msg("",dm_err->logfile,0)
  ENDIF
  FOR (dtm_cnt = 1 TO size(ap_spread_rs->ap_tspace,5))
    IF (validate(dm2_bypass_calculated_tablespace_needs,0)=1
     AND (ap_spread_rs->ap_tspace[dtm_cnt].ap_bytes_needed_mb > 65))
     SET ap_spread_rs->ap_tspace[dtm_cnt].ap_bytes_needed_mb = 65
    ENDIF
    SET dtm_disk_cnt = dm2_assign_disk(ap_spread_rs->ap_tspace[dtm_cnt].ap_bytes_needed_mb,
     dtm_disk_cnt)
    IF (dtm_disk_cnt=0)
     SET dm_err->eproc = "Assigning disk groups entered in response file to tablespaces."
     SET dm_err->emsg = concat("Not enough free space on entered disk groups (",trim(format(
        cnvtstring(dtm_ap_space_free_mb),"##########;R"),3)," MB) to support tablespace needs (",trim
      (format(cnvtstring(ap_space_needed_mb),"##########;R"),3)," MB).")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    SET ap_spread_rs->ap_tspace[dtm_cnt].ap_asm_disk_group = autopop_screen->disk[dtm_disk_cnt].
    disk_name
    SET autopop_screen->disk[dtm_disk_cnt].free_disk_space_mb = (autopop_screen->disk[dtm_disk_cnt].
    free_disk_space_mb - ap_spread_rs->ap_tspace[dtm_cnt].ap_bytes_needed_mb)
  ENDFOR
  FOR (dtm_cnt = 1 TO size(ap_spread_rs->ap_tspace,5))
    SET ap_tspace_ndx = locateval(dtm_fnd,1,size(rtspace->qual,5),ap_spread_rs->ap_tspace[dtm_cnt].
     ap_tspace_name,rtspace->qual[dtm_fnd].tspace_name)
    SET rtspace->qual[ap_tspace_ndx].cont_complete_ind = 1
    SET rtspace->qual[ap_tspace_ndx].asm_disk_group = ap_spread_rs->ap_tspace[dtm_cnt].
    ap_asm_disk_group
  ENDFOR
  EXECUTE dm2_create_tspace
  SET dtm_cnt = 0
  IF (locateval(dtm_cnt,1,size(rtspace->qual,5),1,rtspace->qual[dtm_cnt].ct_err_ind) > 0)
   SET dm_err->eproc = "Creating new tablespaces."
   SET dm_err->emsg = "Errors encountered while creating new tablespaces.  Exiting process."
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ELSE
   SET tspace_build = 1
   CALL display_tspace_summary_report(1)
   IF (check_error(concat("Creating Tablespace Summary Information Report")) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   SET dm_err->eproc = concat("Tablespace Summary Information Report may be viewed at ",
    dtm_summary_logfile)
   CALL disp_msg("",dm_err->logfile,0)
   IF ((drer_email_list->email_cnt > 0))
    SET drer_email_det->msgtype = "PROGRESS"
    SET drer_email_det->status = "REPORT"
    SET drer_email_det->status_dt_tm = cnvtdatetime(curdate,curtime3)
    SET drer_email_det->step = "Tablespace Summary Information Report"
    SET drer_email_det->email_level = 1
    SET drer_email_det->logfile = dm_err->logfile
    SET drer_email_det->err_ind = dm_err->err_ind
    SET drer_email_det->eproc = dm_err->eproc
    SET drer_email_det->emsg = dm_err->emsg
    SET drer_email_det->user_action = dm_err->user_action
    SET drer_email_det->attachment = dtm_summary_logfile
    CALL drer_add_body_text(concat("Tablespace Summary Information Report was generated at ",format(
       drer_email_det->status_dt_tm,";;q")),1)
    CALL drer_add_body_text(concat("Report file name : ",dtm_summary_logfile),0)
    IF (drer_compose_email(null)=1)
     CALL drer_send_email(drer_email_det->subject,drer_email_det->file_name,drer_email_det->
      email_level)
    ENDIF
    CALL drer_reset_pre_err(null)
   ENDIF
  ENDIF
 ELSEIF (dtm_diskgroup != "NOT_SET")
  SET dm_err->eproc = "Package install detected, to complete the creation of new tablespaces."
  CALL disp_msg("",dm_err->logfile,0)
  FOR (tspace_cnt = 1 TO size(rtspace->qual,5))
    SET rtspace->qual[tspace_cnt].ct_err_ind = 1
  ENDFOR
  CALL ts_sort_rtspace("SPACE")
  IF (dor_get_diskgroup_info(null)=0)
   GO TO exit_program
  ENDIF
  CALL ts_sort_rtspace("RDISK")
  IF (dtm_diskgroup="")
   SET dm_err->eproc = "Validating disk group allocated for auto package install."
   SET dm_err->emsg = concat("No Diskgroup found.")
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
  SET dtm_fnd = 0
  SET dtm_fnd = locateval(dtm_fnd,1,size(rdisk->qual,5),dtm_diskgroup,rdisk->qual[dtm_fnd].disk_name)
  IF (dtm_fnd)
   SET tdisk_cnt = (tdisk_cnt+ 1)
   SET stat = alterlist(autopop_screen->disk,tdisk_cnt)
   SET autopop_screen->disk_cnt = tdisk_cnt
   SET autopop_screen->disk[tdisk_cnt].disk_idx = dtm_fnd
   SET autopop_screen->disk[tdisk_cnt].disk_name = rdisk->qual[dtm_fnd].disk_name
   SET autopop_screen->disk[tdisk_cnt].free_disk_space_mb = rdisk->qual[dtm_fnd].new_free_space_mb
   SET autopop_screen->disk[tdisk_cnt].orig_disk_space_mb = rdisk->qual[dtm_fnd].new_free_space_mb
   SET dtm_ap_space_free_mb = (dtm_ap_space_free_mb+ autopop_screen->disk[tdisk_cnt].
   free_disk_space_mb)
  ELSE
   SET dm_err->eproc = "Validating disk group allocated for auto package install."
   SET dm_err->emsg = concat("Disk group (",dir_ui_misc->tspace_dg,") not found.")
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
  SELECT INTO "nl:"
   FROM dm2_dba_data_files df,
    (dummyt d  WITH seq = size(rtspace->qual,5))
   PLAN (d)
    JOIN (df
    WHERE (rtspace->qual[d.seq].tspace_name=cnvtupper(df.tablespace_name)))
   ORDER BY df.tablespace_name
   HEAD REPORT
    ts_tspace_cnt = 0
   HEAD df.tablespace_name
    dtm_cont_cnt = 0
   DETAIL
    IF (textlen(df.file_name) > 0)
     dtm_cont_size_mb = (dtm_cont_size_mb+ convert_bytes(df.bytes,"b","m"))
    ENDIF
   FOOT  df.tablespace_name
    rtspace->qual[d.seq].cur_bytes_allocated = dtm_cont_size_mb, dtm_cont_size_mb = 0.0
   WITH nocounter
  ;end select
  IF (check_error(concat("Loading rtspace")) != 0)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
  SET ap_space_needed_mb = get_total_space_add("ALL")
  IF ((dm_err->debug_flag > 0))
   CALL echo(build("ap_space_needed_mb = ",ap_space_needed_mb))
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = size(rtspace->qual,5))
   WHERE (rtspace->qual[d.seq].ct_err_ind=1)
    AND (rtspace->qual[d.seq].new_ind=1)
   ORDER BY rtspace->qual[d.seq].bytes_needed DESC
   HEAD REPORT
    dtm_cnt = 0
   DETAIL
    dtm_cnt = (dtm_cnt+ 1), stat = alterlist(ap_spread_rs->ap_tspace,dtm_cnt), ap_spread_rs->
    ap_tspace[dtm_cnt].ap_tspace_name = rtspace->qual[d.seq].tspace_name,
    ap_spread_rs->ap_tspace[dtm_cnt].ap_bytes_needed_mb = convert_bytes(rtspace->qual[d.seq].
     bytes_needed,"b","m")
   WITH nocounter
  ;end select
  IF (check_error(concat("Loading tablespaces into Auto-Populate work structure")) != 0)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
  IF (validate(dm2_bypass_calculated_tablespace_needs,0)=1)
   SET dm_err->eproc =
   "User has elected to not satisfy tablespace requirements calculated by process."
   CALL disp_msg("",dm_err->logfile,0)
  ENDIF
  FOR (dtm_cnt = 1 TO size(ap_spread_rs->ap_tspace,5))
    IF (validate(dm2_bypass_calculated_tablespace_needs,0)=1
     AND (ap_spread_rs->ap_tspace[dtm_cnt].ap_bytes_needed_mb > 65))
     SET ap_spread_rs->ap_tspace[dtm_cnt].ap_bytes_needed_mb = 65
    ENDIF
    SET dtm_disk_cnt = dm2_assign_disk(ap_spread_rs->ap_tspace[dtm_cnt].ap_bytes_needed_mb,
     dtm_disk_cnt)
    IF (dtm_disk_cnt=0)
     SET dm_err->eproc = "Assigning disk groups to tablespaces."
     SET dm_err->emsg = concat("Not enough free space on entered disk groups (",trim(format(
        cnvtstring(dtm_ap_space_free_mb),"##########;R"),3)," MB) to support tablespace needs (",trim
      (format(cnvtstring(ap_space_needed_mb),"##########;R"),3)," MB).")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    SET ap_spread_rs->ap_tspace[dtm_cnt].ap_asm_disk_group = autopop_screen->disk[dtm_disk_cnt].
    disk_name
    SET autopop_screen->disk[dtm_disk_cnt].free_disk_space_mb = (autopop_screen->disk[dtm_disk_cnt].
    free_disk_space_mb - ap_spread_rs->ap_tspace[dtm_cnt].ap_bytes_needed_mb)
  ENDFOR
  FOR (dtm_cnt = 1 TO size(ap_spread_rs->ap_tspace,5))
    SET ap_tspace_ndx = locateval(dtm_fnd,1,size(rtspace->qual,5),ap_spread_rs->ap_tspace[dtm_cnt].
     ap_tspace_name,rtspace->qual[dtm_fnd].tspace_name)
    SET rtspace->qual[ap_tspace_ndx].cont_complete_ind = 1
    SET rtspace->qual[ap_tspace_ndx].asm_disk_group = ap_spread_rs->ap_tspace[dtm_cnt].
    ap_asm_disk_group
  ENDFOR
  EXECUTE dm2_create_tspace
  SET dtm_cnt = 0
  IF (locateval(dtm_cnt,1,size(rtspace->qual,5),1,rtspace->qual[dtm_cnt].ct_err_ind) > 0)
   SET dm_err->eproc = "Creating new tablespaces."
   SET dm_err->emsg = "Errors encountered while creating new tablespaces.  Exiting process."
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ELSE
   SET tspace_build = 1
   CALL display_tspace_summary_report(1)
   IF (check_error(concat("Creating Tablespace Summary Information Report")) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   SET dm_err->eproc = concat("Tablespace Summary Information Report may be viewed at ",
    dtm_summary_logfile)
   CALL disp_msg("",dm_err->logfile,0)
  ENDIF
 ELSE
  IF (size(rtspace->qual,5) > 0)
   CALL display_tspace_header(null)
   SET ts_tspace_cnt = 0
   FOR (tspace_cnt = 1 TO size(rtspace->qual,5))
     SET rtspace->qual[tspace_cnt].ct_err_ind = 1
   ENDFOR
   CALL ts_inform("sorting rtspace by space needed.")
   CALL ts_sort_rtspace("SPACE")
   SET dtm_from_install = 1
   CALL dtm_gather_tspace_related_info(0,"ALL","*")
  ELSEIF ((rtspace->install_type="DM2NOTSET"))
   CALL text(23,2,"Please run DM2_DOMAIN_MAINT to manage tablespaces.")
   SET dm_err->emsg = "Please run DM2_DOMAIN_MAINT to manage tablespaces."
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ELSEIF ((rtspace->install_type="MANUAL"))
   CALL display_tspace_header(null)
   CALL dtm_gather_tspace_related_info(1,"DISK",null)
  ELSE
   CALL display_tspace_header(null)
  ENDIF
  CALL ts_inform("calling tspace_driver.")
  CALL tspace_driver(null)
 ENDIF
 GO TO exit_program
 SUBROUTINE ts_load_hold_datafile(null)
   DECLARE hd_ts_cnt = i4 WITH protect, noconstant(0)
   DECLARE df_start_pt = i4 WITH protect, noconstant(0)
   DECLARE df_end_pt = i4 WITH protect, noconstant(0)
   DECLARE hd_df_cnt = i4 WITH protect, noconstant(0)
   SET stat = alterlist(hold_datafile->ts,0)
   CALL ts_inform("Load Existing Datafiles")
   SELECT INTO "nl:"
    FROM dm2_dba_data_files d
    ORDER BY d.tablespace_name
    HEAD d.tablespace_name
     hd_ts_cnt = (hd_ts_cnt+ 1), stat = alterlist(hold_datafile->ts,hd_ts_cnt), hold_datafile->ts[
     hd_ts_cnt].hd_tspace = d.tablespace_name,
     hd_df_cnt = 0
    DETAIL
     hd_df_cnt = (hd_df_cnt+ 1), stat = alterlist(hold_datafile->ts[hd_ts_cnt].df,hd_df_cnt)
     IF ((dm2_sys_misc->cur_db_os="AXP"))
      df_start_pt = (findstring("]",d.file_name,1,1)+ 1), df_end_pt = textlen(d.file_name),
      hold_datafile->ts[hd_ts_cnt].df[hd_df_cnt].df_name = cnvtlower(substring(df_start_pt,((
        df_end_pt - df_start_pt)+ 1),d.file_name)),
      df_start_pt = 1, df_end_pt = 0, df_end_pt = findstring(":",d.file_name,1,1),
      hold_datafile->ts[hd_ts_cnt].df[hd_df_cnt].device_name = substring(df_start_pt,df_end_pt,d
       .file_name)
     ELSEIF ((dm2_sys_misc->cur_db_os="AIX"))
      df_start_pt = (findstring("/r",d.file_name,1,1)+ 2), df_end_pt = textlen(d.file_name),
      hold_datafile->ts[hd_ts_cnt].df[hd_df_cnt].df_name = cnvtlower(substring(df_start_pt,((
        df_end_pt - df_start_pt)+ 1),d.file_name))
     ELSEIF ((dm2_sys_misc->cur_db_os="HPX"))
      df_start_pt = (findstring("/",d.file_name,1,1)+ 2), df_end_pt = textlen(d.file_name),
      hold_datafile->ts[hd_ts_cnt].df[hd_df_cnt].df_name = cnvtlower(substring(df_start_pt,((
        df_end_pt - df_start_pt)+ 1),d.file_name)),
      df_start_pt = findstring("/",d.file_name,1,0), df_end_pt = findstring("/",d.file_name,1,1),
      hold_datafile->ts[hd_ts_cnt].df[hd_df_cnt].device_name = substring(df_start_pt,(df_end_pt - 1),
       d.file_name)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(concat("loading hold datafile")) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ts_inform(ts_msg_in)
  SET dm_err->eproc = concat(ts_msg_in)
  IF ((dm_err->debug_flag > 0))
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  ENDIF
 END ;Subroutine
 SUBROUTINE tspace_driver(null)
   DECLARE ts_screen_return = vc WITH protect, noconstant("")
   DECLARE tspace_leave = vc WITH protect, noconstant("")
   DECLARE ap_max_cont_size = f8 WITH protect, noconstant(0.0)
   SET tspace_leave = "N"
   IF ((rtspace->install_type != "MANUAL")
    AND dtm_from_install=0)
    CALL dtm_gather_tspace_related_info(1,"ALL","*")
   ENDIF
   WHILE (tspace_leave="N")
     CALL ts_inform("in tspace_driver.")
     SET ts_screen_return = ""
     SET ts_screen_return = tspace_work_menu(null)
     CASE (ts_screen_return)
      OF "CONTAINER_SCREEN":
       SET display_line = 12
       SET ncont_screen->top_line = 1
       SET ncont_screen->cur_line = 0
       SET ncont_screen->bottom_line = 0
       SET ncont_screen->max_scroll = 10
       CALL ts_inform("calling container_driver.")
       CALL container_driver(null)
      OF "EXIT_PROGRAM":
       SET tspace_leave = "Y"
      OF "AUTOPOP_SCREEN":
       CALL ts_inform("calling autopop_driver.")
       SET ap_max_cont_size = 0.0
       SET autopop_screen->top_line = 1
       SET autopop_screen->cur_line = 0
       SET autopop_screen->bottom_line = 0
       SET autopop_screen->max_scroll = 10
       CALL autopop_driver(null)
      OF "SUMMARY_REPORT":
       CALL ts_inform("calling tspace_summary_report.")
       CALL display_tspace_summary_report(0)
      OF "REFRESH_DISK":
       CALL ts_inform("calling ts_disk_refresh")
       CALL ts_disk_refresh(null)
      OF "VIEW_DISK_REPORT":
       CALL ts_inform("calling view_disks")
       CALL ts_view_disk_report(null)
      OF "MANUALADD":
       CALL dtm_manual_add_driver("N")
      OF "MANUALEDIT":
       CALL dtm_manual_add_driver("E")
     ENDCASE
   ENDWHILE
   IF (tspace_leave="Y")
    IF ((validate(dtd_quit_menu_ind,- (1)) != - (1)))
     SET dtd_quit_menu_ind = 1
    ENDIF
    IF (ts_check_if_tspace_to_display(null)=1)
     SET dm_err->err_ind = 1
     CALL ts_inform("User quit before all tablespaces were created successfully")
     SET dm_err->emsg = "User quit before all tablespaces were created successfully"
    ENDIF
    GO TO exit_program
   ENDIF
 END ;Subroutine
 SUBROUTINE container_driver(null)
   DECLARE cont_screen_return = vc WITH protect, noconstant("")
   SET display_line = 12
   WHILE (cont_screen_return != "DONE")
    CALL ts_inform("calling container_work_menu.")
    SET cont_screen_return = container_work_menu(null)
   ENDWHILE
   RETURN(cont_screen_return)
 END ;Subroutine
 SUBROUTINE autopop_driver(null)
   DECLARE autopop_screen_return = vc WITH protect, noconstant("")
   DECLARE awm_max_request = i2 WITH protect, noconstant(0)
   DECLARE ad_type_cnt = i4 WITH protect, noconstant(0)
   SET display_line = 12
   FOR (at_type_cnt = 1 TO size(tspace_type->qual,5))
    CALL ts_inform("calling autopop_work_menu.")
    IF (get_total_space_add(tspace_type->qual[at_type_cnt].ts_type) > 0)
     CALL clear(1,1)
     SET stat = alterlist(autopop_screen->disk,0)
     SET autopop_ready_ind = 0
     SET ap_max_cont_size = 0
     IF (autopop_work_menu(tspace_type->qual[at_type_cnt].ts_type)="QUIT")
      SET at_type_cnt = size(tspace_type->qual,5)
     ENDIF
    ELSE
     CALL display_warning("AUTOPOP",tspace_type->qual[at_type_cnt].ts_type)
    ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE rdisk_pop(null)
   CALL ts_inform("in rdisk_pop.")
   DECLARE rp_rdisk_cnt = i4 WITH protect, noconstant(0)
   DECLARE td_disk_cnt = i4 WITH protect, noconstant(0)
   DECLARE rp_cmd = vc WITH protect, noconstant("")
   DECLARE td_find_ndx = i4 WITH protect, noconstant(0)
   IF (size(rdisk->qual,5)=0)
    SET rdisk_filled = "N"
   ELSE
    SET rdisk_filled = "Y"
   ENDIF
   IF (rdisk_filled="N")
    CALL clear(24,1,130)
    CALL text(24,2,"Loading System Disk Information ....")
    IF ((rtspace->database_remote=1))
     IF (retrieve_os_data_diff_node(2)=0)
      RETURN(0)
     ENDIF
    ELSE
     IF ((dir_storage_misc->tgt_storage_type="ASM"))
      IF (dor_get_diskgroup_info(null)=0)
       CALL text(23,2,"Unable to load system disk information - exiting application.")
       RETURN(0)
      ENDIF
     ELSEIF ((dm2_sys_misc->cur_db_os IN ("HPX", "AIX")))
      IF ( NOT (dm2_get_vg_disk_info_aix(null)))
       CALL text(23,2,"Unable to load system disk information - exiting application.")
       RETURN(0)
      ENDIF
      IF ((dm2_sys_misc->cur_db_os="AIX"))
       IF ( NOT (get_unique_file("dm2_get_mwc",".dat")))
        SET dm_err->eproc = "FAILED in get unique file for mwc value"
        CALL disp_msg(dm_err->eproc,dm_err->logfile,dm_err->err_ind)
        RETURN(0)
       ENDIF
       IF (dos_get_mwc_value(dm_err->unique_fname,1)=0)
        RETURN(0)
       ELSE
        FOR (td_disk_cnt = 1 TO size(rdisk->qual,5))
         SET td_find_ndx = locateval(td_find_ndx,1,size(pv_mwc_list->pv,5),rdisk->qual[td_disk_cnt].
          disk_name,pv_mwc_list->pv[td_find_ndx].pv_name)
         SET rdisk->qual[td_disk_cnt].mwc_flag = pv_mwc_list->pv[td_find_ndx].mwc_flag
        ENDFOR
       ENDIF
      ENDIF
     ELSEIF ((dm2_sys_misc->cur_db_os="AXP"))
      IF ( NOT (get_unique_file("dm2_tspace_menu",".dat")))
       SET dm_err->eproc = "FAILED IN GET_UNIQUE_FILE"
       CALL disp_msg(dm_err->eproc,dm_err->logfile,dm_err->err_ind)
       RETURN(0)
      ENDIF
      IF (dm2_get_mnt_disk_info_axp(dm_err->unique_fname)=0)
       CALL text(23,2,"Unable to load system disk information - exiting application.")
       RETURN(0)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CALL ts_sort_rtspace("RDISK")
   IF (size(rd_pp_sizes->qual,5)=0
    AND (dir_storage_misc->tgt_storage_type="RAW"))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = size(rdisk->qual,5))
     ORDER BY rdisk->qual[d.seq].pp_size_mb
     HEAD REPORT
      td_disk_cnt = 0, td_find_ndx = 0
     DETAIL
      td_find_ndx = 0, td_find_ndx = locateval(td_find_ndx,1,size(rd_pp_sizes->qual,5),rdisk->qual[d
       .seq].pp_size_mb,rd_pp_sizes->qual[td_find_ndx].rd_size)
      IF (td_find_ndx=0)
       td_disk_cnt = (td_disk_cnt+ 1), stat = alterlist(rd_pp_sizes->qual,td_disk_cnt), rd_pp_sizes->
       qual[td_disk_cnt].rd_size = rdisk->qual[d.seq].pp_size_mb
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ts_validate_disk_directories(tvdd_disk_in)
   DECLARE tvdd_command = vc WITH protect, noconstant("")
   DECLARE tvdd_ndx = i4 WITH protect, noconstant(0)
   CALL ts_inform(concat("validating...",tvdd_disk_in,":",ts_datafile_dir))
   IF ( NOT (dm2_find_dir(concat(tvdd_disk_in,":",ts_datafile_dir))))
    IF ( NOT (dm2_create_dir(concat(tvdd_disk_in,":",ts_datafile_dir),"DB")))
     GO TO exit_program
    ENDIF
   ENDIF
   SET tvdd_ndx = locateval(tvdd_ndx,1,size(rdisk->qual,5),tvdd_disk_in,rdisk->qual[tvdd_ndx].
    volume_label)
   IF (tvdd_ndx > 0)
    SET rdisk->qual[tvdd_ndx].datafile_dir_exists = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE ts_find_disks_for_datafiles(null)
  DECLARE tfdd_cnt = i4 WITH protect, noconstant(0)
  FOR (tfdd_cnt = 1 TO size(rdisk->qual,5))
    SET dm_err->eproc = "Looking for datafile directory"
    SET dm_err->user_action =
    "This is an acceptable error message that can be ignored. No action needed."
    IF (dm2_findfile(concat(rdisk->qual[tfdd_cnt].volume_label,":",ts_datafile_dir,"*.*;*")))
     SET rdisk->qual[tfdd_cnt].datafile_dir_exists = 1
    ELSEIF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE get_disk_for_lv(gdfl_type,gdfl_name)
   DECLARE dglv_tspace_cnt = i4 WITH protect, noconstant(0)
   DECLARE dglv_cont_cnt = i4 WITH protect, noconstant(0)
   DECLARE dglv_stat = i2 WITH protect, noconstant(0)
   CALL ts_inform("getting disk information for existing datafiles")
   CALL clear(24,1,130)
   CALL text(24,2,concat("Loading Disk Information for Existing ",storage_device,"s...."))
   IF ((rtspace->database_remote=0))
    IF (get_unique_file("dm2_tspace_menu",".dat"))
     SET dtm_temp_file = dm_err->unique_fname
     IF ((dm_err->debug_flag >= 1))
      CALL ts_inform(concat("Disk file name:",dm_err->unique_fname))
     ENDIF
     FOR (dglv_tspace_cnt = 1 TO size(rtspace->qual,5))
       IF (((gdfl_type="TABLE"
        AND (rtspace->qual[dglv_tspace_cnt].tspace_name=gdfl_name)) OR (gdfl_type="ALL")) )
        IF (size(rtspace->qual[dglv_tspace_cnt].cont,5) > 0)
         FOR (dglv_cont_cnt = 1 TO size(rtspace->qual[dglv_tspace_cnt].cont,5))
           SET dcl_str = concat("lslv -l ",rtspace->qual[dglv_tspace_cnt].cont[dglv_cont_cnt].lv_file,
            '| grep -v "None" | cut -d" " -f1  > ',dtm_temp_file)
           SET dglv_stat = dcl(dcl_str,textlen(dcl_str),dglv_stat)
           IF (dglv_stat=0)
            IF ((dm_err->debug_flag >= 1))
             CALL ts_inform(concat("lslv filename:",dm_err->unique_fname))
            ENDIF
            RETURN(0)
           ENDIF
           IF ( NOT (rdisk_pop_existing_lv(dtm_temp_file,dglv_cont_cnt,dglv_tspace_cnt)))
            RETURN(0)
           ENDIF
         ENDFOR
        ENDIF
       ENDIF
     ENDFOR
    ELSE
     RETURN(0)
    ENDIF
   ELSE
    FOR (dglv_cont_cnt = 1 TO size(rtspace->qual[dglv_tspace_cnt].cont,5))
      IF ( NOT (rdisk_pop_existing_lv("not needed",dglv_cont_cnt,dglv_tspace_cnt)))
       RETURN(0)
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE rdisk_pop_existing_lv(rpe_fname_in,rpe_cont_ndx,rpe_tspace_ndx)
   DECLARE rpe_rtl_file = vc WITH protect, noconstant("")
   DECLARE rpe_cnt = i4 WITH protect, noconstant(0)
   DECLARE rpe_rdisk_ndx = i4 WITH protect, noconstant(0)
   DECLARE rpe_pv_ndx = i4 WITH protect, noconstant(0)
   DECLARE rpe_pv_cnt = i4 WITH protect, noconstant(0)
   IF ((rtspace->database_remote=0))
    SET rpe_rtl_file = concat("ccluserdir:",rpe_fname_in)
    SET logical rpe_disk_info rpe_rtl_file
    CALL ts_inform("populating rtspace with disk information for existing datafiles")
    IF ((dm_err->debug_flag >= 1))
     CALL ts_inform(concat("rtl file for disk info:",rpe_rtl_file))
    ENDIF
    FREE DEFINE rtl
    DEFINE rtl "rpe_disk_info"
    SELECT INTO "nl:"
     t.line
     FROM rtlt t
     WHERE t.line > " "
     HEAD REPORT
      ape_cnt = 0
     DETAIL
      rpe_rdisk_ndx = 0
      IF ((dm_err->debug_flag >= 1))
       CALL echo(t.line)
      ENDIF
      rpe_cnt = (rpe_cnt+ 1)
      IF (mod(rpe_cnt,3)=0)
       rtspace->qual[rpe_tspace_ndx].cont[rpe_cont_ndx].disk_name = t.line, rpe_rdisk_ndx = locateval
       (rpe_rdisk_ndx,1,size(rdisk->qual,5),rtspace->qual[rpe_tspace_ndx].cont[rpe_cont_ndx].
        disk_name,rdisk->qual[rpe_rdisk_ndx].disk_name), rtspace->qual[rpe_tspace_ndx].cont[
       rpe_cont_ndx].vg_name = rdisk->qual[rpe_rdisk_ndx].vg_name,
       rtspace->qual[rpe_tspace_ndx].cont[rpe_cont_ndx].pp_size_mb = rdisk->qual[rpe_rdisk_ndx].
       pp_size_mb
      ENDIF
     WITH nocounter
    ;end select
    IF ((dm_err->debug_flag=722))
     SET message = nowindow
    ENDIF
    IF (check_error(concat("pop_existing_tspace_aix")) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     CALL ts_inform(concat(dm_err->emsg,". Error in RDISK_POP_EXISTING_LV"))
     RETURN(0)
    ELSE
     CALL ts_inform("RDISK_POP_EXISTING_LV completed Successfully")
     RETURN(1)
    ENDIF
   ELSE
    FOR (rpe_pv_cnt = 1 TO size(pv_lv_list->pv,5))
     SET rpe_pv_ndx = locateval(rpe_pv_ndx,1,size(pv_lv_list->pv[rpe_pv_cnt].lv,5),rtspace->qual[
      rpe_tspace_ndx].cont[rpe_cont_ndx].lv_file,pv_lv_list->pv[rpe_pv_cnt].lv[rpe_pv_ndx].lv_name)
     IF (rpe_pv_ndx > 0)
      SET rpe_rdisk_ndx = locateval(rpe_rdisk_ndx,1,size(rdisk->qual,5),pv_lv_list->pv[rpe_pv_cnt].
       pv_name,rdisk->qual[rpe_rdisk_ndx].disk_name)
      SET rtspace->qual[rpe_tspace_ndx].cont[rpe_cont_ndx].disk_name = rdisk->qual[rpe_rdisk_ndx].
      disk_name
      SET rtspace->qual[rpe_tspace_ndx].cont[rpe_cont_ndx].vg_name = rdisk->qual[rpe_rdisk_ndx].
      vg_name
      SET rtspace->qual[rpe_tspace_ndx].cont[rpe_cont_ndx].pp_size_mb = rdisk->qual[rpe_rdisk_ndx].
      pp_size_mb
      SET rpe_pv_cnt = size(pv_lv_list->pv,5)
     ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE get_tspace_info(gti_mode_in,gti_tspace_in)
   DECLARE gti_cont_cnt = i4 WITH protect, noconstant(0)
   DECLARE gti_spot = i4 WITH protect, noconstant(0)
   DECLARE gti_spot_end = i4 WITH protect, noconstant(0)
   DECLARE gti_have_name = i2 WITH protect, noconstant(0)
   DECLARE gti_disk_ndx = i4 WITH protect, noconstant(0)
   DECLARE gti_cont_size_mb = f8 WITH protect, noconstant(0.0)
   DECLARE gti_device = vc WITH protect, noconstant("")
   CALL clear(23,1,130)
   CALL display_warning("TSPACE GATHER INFO",null)
   IF (gti_mode_in=1)
    SELECT INTO "nl:"
     FROM dm2_tspace_size dm,
      dm2_dba_data_files df
     PLAN (dm
      WHERE (dm.install_type=rtspace->install_type)
       AND (dm.install_type_value=rtspace->install_type_value)
       AND ((dm.install_status != "SUCCESS") OR (dm.install_status = null))
       AND dm.tspace_name=patstring(value(gti_tspace_in)))
      JOIN (df
      WHERE outerjoin(dm.tspace_name)=df.tablespace_name)
     ORDER BY dm.bytes_needed DESC, dm.tspace_name
     HEAD REPORT
      ts_tspace_cnt = 0
     HEAD dm.tspace_name
      ts_tspace_cnt = (ts_tspace_cnt+ 1)
      IF (mod(ts_tspace_cnt,10)=1)
       stat = alterlist(rtspace->qual,(ts_tspace_cnt+ 9))
      ENDIF
      rtspace->qual[ts_tspace_cnt].tspace_name = cnvtupper(dm.tspace_name), rtspace->qual[
      ts_tspace_cnt].bytes_needed = dm.bytes_needed, rtspace->qual[ts_tspace_cnt].new_ind = dm
      .new_ind,
      rtspace->qual[ts_tspace_cnt].user_bytes_to_add = dm.bytes_needed, rtspace->qual[ts_tspace_cnt].
      chunk_size = dm.chunk_size
      IF (dm.chunk_size > dtm_max_chunk_size)
       dtm_max_chunk_size = dm.chunk_size
      ENDIF
      IF (dm.chunk_size > 0)
       rtspace->qual[ts_tspace_cnt].chunks_needed = dm2floor((dm.bytes_needed/ dm.chunk_size))
      ENDIF
      rtspace->qual[ts_tspace_cnt].ext_mgmt = dm.extent_management, rtspace->qual[ts_tspace_cnt].
      ct_err_ind = 1, gti_cont_cnt = 0
     DETAIL
      IF (textlen(df.file_name) > 0)
       IF ((dir_storage_misc->tgt_storage_type="ASM"))
        gti_cont_size_mb = (gti_cont_size_mb+ convert_bytes(df.bytes,"b","m"))
       ELSEIF ((dm2_sys_misc->cur_db_os="AXP"))
        gti_cont_cnt = (gti_cont_cnt+ 1), stat = alterlist(rtspace->qual[ts_tspace_cnt].cont,
         gti_cont_cnt), gti_spot = findstring(":",df.file_name),
        gti_device = substring(1,(gti_spot - 1),df.file_name), gti_disk_ndx = 0, gti_disk_ndx =
        locateval(gti_disk_ndx,1,size(rdisk->qual,5),gti_device,rdisk->qual[gti_disk_ndx].
         volume_label)
        IF (gti_disk_ndx=0)
         gti_disk_ndx = locateval(gti_disk_ndx,1,size(rdisk->qual,5),concat(gti_device,":"),rdisk->
          qual[gti_disk_ndx].disk_name)
        ENDIF
        IF (gti_disk_ndx=0)
         rtspace->qual[ts_tspace_cnt].cont[gti_cont_cnt].volume_label = "NOT_FOUND", rtspace->qual[
         ts_tspace_cnt].cont[gti_cont_cnt].disk_name = "NOT_FOUND"
        ELSE
         rtspace->qual[ts_tspace_cnt].cont[gti_cont_cnt].disk_name = rdisk->qual[gti_disk_ndx].
         disk_name
         IF ((concat(gti_device,":")=rdisk->qual[gti_disk_ndx].disk_name))
          rtspace->qual[ts_tspace_cnt].cont[gti_cont_cnt].volume_label = gti_device
         ELSE
          rtspace->qual[ts_tspace_cnt].cont[gti_cont_cnt].volume_label = rdisk->qual[gti_disk_ndx].
          volume_label
         ENDIF
        ENDIF
        gti_spot = findstring("]",df.file_name), gti_spot_end = findstring(".DBS",df.file_name),
        rtspace->qual[ts_tspace_cnt].cont[gti_cont_cnt].lv_file = substring((gti_spot+ 1),((
         gti_spot_end - gti_spot) - 1),df.file_name),
        rtspace->qual[ts_tspace_cnt].cont[gti_cont_cnt].cont_size_mb = convert_bytes(df.bytes,"b","m"
         ), gti_cont_size_mb = (gti_cont_size_mb+ rtspace->qual[ts_tspace_cnt].cont[gti_cont_cnt].
        cont_size_mb)
       ELSEIF ((dm2_sys_misc->cur_db_os="AIX"))
        gti_cont_cnt = (gti_cont_cnt+ 1), stat = alterlist(rtspace->qual[ts_tspace_cnt].cont,
         gti_cont_cnt), gti_spot = 0,
        gti_spot = (findstring("/r",df.file_name,1,1)+ 1)
        IF (gti_spot=1)
         gti_spot = findstring("/",df.file_name,1,1)
        ENDIF
        gti_spot_end = textlen(df.file_name), rtspace->qual[ts_tspace_cnt].cont[gti_cont_cnt].lv_file
         = substring((gti_spot+ 1),(gti_spot_end - gti_spot),df.file_name), rtspace->qual[
        ts_tspace_cnt].cont[gti_cont_cnt].cont_size_mb = convert_bytes(df.bytes,"b","m"),
        gti_cont_size_mb = (gti_cont_size_mb+ rtspace->qual[ts_tspace_cnt].cont[gti_cont_cnt].
        cont_size_mb)
       ELSEIF ((dm2_sys_misc->cur_db_os="HPX"))
        gti_cont_cnt = (gti_cont_cnt+ 1), stat = alterlist(rtspace->qual[ts_tspace_cnt].cont,
         gti_cont_cnt), gti_spot = (findstring("/r",df.file_name,1,1)+ 1),
        gti_spot_end = textlen(df.file_name), rtspace->qual[ts_tspace_cnt].cont[gti_cont_cnt].lv_file
         = substring((gti_spot+ 1),(gti_spot_end - gti_spot),df.file_name), gti_spot = findstring("/",
         df.file_name,1,0),
        gti_spot_end = findstring("/",df.file_name,1,1), rtspace->qual[ts_tspace_cnt].cont[
        gti_cont_cnt].disk_name = substring(gti_spot,(gti_spot_end - gti_spot),df.file_name), rtspace
        ->qual[ts_tspace_cnt].cont[gti_cont_cnt].vg_name = rtspace->qual[ts_tspace_cnt].cont[
        gti_cont_cnt].disk_name,
        rtspace->qual[ts_tspace_cnt].cont[gti_cont_cnt].cont_size_mb = convert_bytes(df.bytes,"b","m"
         ), gti_disk_ndx = 0, gti_disk_ndx = locateval(gti_disk_ndx,1,size(rdisk->qual,5),rtspace->
         qual[ts_tspace_cnt].cont[gti_cont_cnt].disk_name,rdisk->qual[gti_disk_ndx].disk_name),
        rtspace->qual[ts_tspace_cnt].cont[gti_cont_cnt].pp_size_mb = rdisk->qual[gti_disk_ndx].
        pp_size_mb, gti_cont_size_mb = (gti_cont_size_mb+ rtspace->qual[ts_tspace_cnt].cont[
        gti_cont_cnt].cont_size_mb)
       ENDIF
       IF ((dir_storage_misc->tgt_storage_type != "ASM"))
        rtspace->qual[ts_tspace_cnt].cont[gti_cont_cnt].add_ext_ind = "-"
       ENDIF
      ENDIF
     FOOT  dm.tspace_name
      rtspace->qual[ts_tspace_cnt].cur_bytes_allocated = gti_cont_size_mb, gti_cont_size_mb = 0.0
     FOOT REPORT
      stat = alterlist(rtspace->qual,ts_tspace_cnt), tspace_screen->max_value = ts_tspace_cnt
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM dm2_dba_data_files df,
      (dummyt d  WITH seq = size(rtspace->qual,5))
     PLAN (d
      WHERE (rtspace->qual[d.seq].tspace_name=patstring(value(gti_tspace_in))))
      JOIN (df
      WHERE (rtspace->qual[d.seq].tspace_name=cnvtupper(df.tablespace_name)))
     ORDER BY df.tablespace_name
     HEAD REPORT
      ts_tspace_cnt = 0
     HEAD df.tablespace_name
      gti_cont_cnt = 0
     DETAIL
      IF (textlen(df.file_name) > 0)
       IF ((dir_storage_misc->tgt_storage_type="ASM"))
        gti_cont_size_mb = (gti_cont_size_mb+ convert_bytes(df.bytes,"b","m"))
       ELSEIF ((dm2_sys_misc->cur_db_os="AXP"))
        gti_cont_cnt = (gti_cont_cnt+ 1), stat = alterlist(rtspace->qual[d.seq].cont,gti_cont_cnt),
        gti_spot = findstring(":",df.file_name),
        gti_device = substring(1,(gti_spot - 1),df.file_name), gti_disk_ndx = 0, gti_disk_ndx =
        locateval(gti_disk_ndx,1,size(rdisk->qual,5),gti_device,rdisk->qual[gti_disk_ndx].
         volume_label)
        IF (gti_disk_ndx=0)
         gti_disk_ndx = locateval(gti_disk_ndx,1,size(rdisk->qual,5),concat(gti_device,":"),rdisk->
          qual[gti_disk_ndx].disk_name)
        ENDIF
        IF (gti_disk_ndx=0)
         rtspace->qual[d.seq].cont[gti_cont_cnt].volume_label = "NOT_FOUND", rtspace->qual[d.seq].
         cont[gti_cont_cnt].disk_name = "NOT_FOUND"
        ELSE
         rtspace->qual[d.seq].cont[gti_cont_cnt].disk_name = rdisk->qual[gti_disk_ndx].disk_name
         IF ((concat(gti_device,":")=rdisk->qual[gti_disk_ndx].disk_name))
          rtspace->qual[d.seq].cont[gti_cont_cnt].volume_label = gti_device
         ELSE
          rtspace->qual[d.seq].cont[gti_cont_cnt].volume_label = rdisk->qual[gti_disk_ndx].
          volume_label
         ENDIF
        ENDIF
        gti_spot = findstring("]",df.file_name), gti_spot_end = findstring(".DBS",df.file_name),
        rtspace->qual[d.seq].cont[gti_cont_cnt].lv_file = substring((gti_spot+ 1),((gti_spot_end -
         gti_spot) - 1),df.file_name),
        rtspace->qual[d.seq].cont[gti_cont_cnt].cont_size_mb = convert_bytes(df.bytes,"b","m"),
        gti_cont_size_mb = (gti_cont_size_mb+ rtspace->qual[d.seq].cont[gti_cont_cnt].cont_size_mb)
       ELSEIF ((dm2_sys_misc->cur_db_os="AIX"))
        gti_cont_cnt = (gti_cont_cnt+ 1), stat = alterlist(rtspace->qual[d.seq].cont,gti_cont_cnt),
        gti_spot = 0,
        gti_spot = (findstring("/r",df.file_name,1,1)+ 1)
        IF (gti_spot=1)
         gti_spot = findstring("/",df.file_name,1,1)
        ENDIF
        gti_spot_end = textlen(df.file_name), rtspace->qual[d.seq].cont[gti_cont_cnt].lv_file =
        substring((gti_spot+ 1),(gti_spot_end - gti_spot),df.file_name), rtspace->qual[d.seq].cont[
        gti_cont_cnt].cont_size_mb = convert_bytes(df.bytes,"b","m"),
        gti_cont_size_mb = (gti_cont_size_mb+ rtspace->qual[d.seq].cont[gti_cont_cnt].cont_size_mb)
       ELSEIF ((dm2_sys_misc->cur_db_os="HPX"))
        gti_cont_cnt = (gti_cont_cnt+ 1), stat = alterlist(rtspace->qual[d.seq].cont,gti_cont_cnt),
        gti_spot = (findstring("/r",df.file_name,1,1)+ 1),
        gti_spot_end = textlen(df.file_name), rtspace->qual[d.seq].cont[gti_cont_cnt].lv_file =
        substring((gti_spot+ 1),(gti_spot_end - gti_spot),df.file_name), gti_spot = findstring("/",df
         .file_name,1,0),
        gti_spot_end = findstring("/",df.file_name,1,1), rtspace->qual[d.seq].cont[gti_cont_cnt].
        disk_name = substring(gti_spot,(gti_spot_end - gti_spot),df.file_name), rtspace->qual[d.seq].
        cont[gti_cont_cnt].vg_name = rtspace->qual[d.seq].cont[gti_cont_cnt].disk_name,
        rtspace->qual[d.seq].cont[gti_cont_cnt].cont_size_mb = convert_bytes(df.bytes,"b","m"),
        gti_cont_size_mb = (gti_cont_size_mb+ rtspace->qual[d.seq].cont[gti_cont_cnt].cont_size_mb),
        gti_disk_ndx = 0,
        gti_disk_ndx = locateval(gti_disk_ndx,1,size(rdisk->qual,5),rtspace->qual[d.seq].cont[
         gti_cont_cnt].disk_name,rdisk->qual[gti_disk_ndx].disk_name), rtspace->qual[d.seq].cont[
        gti_cont_cnt].pp_size_mb = rdisk->qual[gti_disk_ndx].pp_size_mb
       ENDIF
       IF ((dir_storage_misc->tgt_storage_type != "ASM"))
        rtspace->qual[d.seq].cont[gti_cont_cnt].add_ext_ind = "-"
       ENDIF
      ENDIF
     FOOT  df.tablespace_name
      rtspace->qual[d.seq].cur_bytes_allocated = gti_cont_size_mb, gti_cont_size_mb = 0.0
     WITH nocounter
    ;end select
    SET tspace_screen->max_value = size(rtspace->qual,5)
    SET gti_cont_cnt = 0
    FOR (gti_cont_cnt = 1 TO size(rtspace->qual,5))
     SET rtspace->qual[gti_cont_cnt].user_bytes_to_add = rtspace->qual[gti_cont_cnt].bytes_needed
     IF ((rtspace->qual[gti_cont_cnt].chunk_size > dtm_max_chunk_size))
      SET dtm_max_chunk_size = rtspace->qual[gti_cont_cnt].chunk_size
     ENDIF
    ENDFOR
   ENDIF
   IF (check_error(concat("loading rtspace")) != 0)
    CALL ts_inform(concat(dm_err->emsg,"Error occurred in GET_TSPACE_INFO"))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (size(rtspace->qual,5) > 0)
    CALL ts_inform("RTSPACE populated successuflly")
    RETURN(1)
   ELSEIF (curqual=0
    AND (rtspace->install_type != "MANUAL"))
    CALL ts_inform("No tablespaces qualified in DM2_TSPACE_SIZE, unable to load RTSPACE.")
    CALL clear(23,1,130)
    CALL text(23,2,"Unable to load tspace information - exiting application.")
    RETURN(0)
   ELSEIF (size(rtspace->qual,5)=0
    AND (rtspace->install_type != "MANUAL"))
    CALL ts_inform("ERROR occurred in GET_TSPACE_INFO, no TSPACE information in RTSPACE")
    CALL clear(23,1,130)
    CALL text(23,2,"Unable to load tspace information - exiting application.")
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE display_tspace_header(null)
   IF ((dir_storage_misc->tgt_storage_type != "ASM"))
    CALL clear(1,1)
    CALL box(2,1,22,132)
    CALL text(1,1,"TABLESPACE MENU",w)
    CALL line(7,1,132,xhor)
    CALL text(5,3,"Ready")
    CALL text(6,3,"to Create")
    CALL text(6,23,"Name")
    CALL text(4,61,"Current")
    CALL text(5,61,"Total Size")
    CALL text(6,61,"(MBYTES)")
    CALL text(4,91,"Space")
    CALL text(5,91,"Needed")
    CALL text(6,91,"(MBYTES)")
    CALL text(4,116,"Space to")
    CALL text(5,116,"be Added")
    CALL text(6,116,"(MBYTES)")
   ELSE
    CALL clear(1,1)
    CALL box(2,1,22,132)
    CALL text(1,1,"TABLESPACE MENU",w)
    CALL line(7,1,132,xhor)
    CALL text(5,3,"Ready")
    CALL text(6,3,"to Create")
    CALL text(6,23,"Name")
    CALL text(4,61,"Space")
    CALL text(5,61,"Needed")
    CALL text(6,61,"(MBYTES)")
    CALL text(5,80,"Disk")
    CALL text(6,80,"Group")
   ENDIF
 END ;Subroutine
 SUBROUTINE ts_disk_refresh(null)
   SET stat = alterlist(rdisk->qual,0)
   IF (rdisk_pop(null)=0)
    CALL clear(23,1,130)
    CALL ts_inform("Unable to refresh rdisk information - exiting application.")
    CALL text(23,2,"Unable to refresh rdisk information - exiting application.")
    GO TO exit_program
   ENDIF
   IF ((dm2_sys_misc->cur_db_os="AXP")
    AND (rtspace->database_remote=0))
    CALL ts_find_disks_for_datafiles(null)
   ENDIF
   CALL ts_inform("calling config_total_disk_space.")
   CALL clear(23,1,130)
   CALL text(23,2,"Configuring Unapplied Disk Usage.....")
   CALL config_total_disk_space(null)
 END ;Subroutine
 SUBROUTINE tspace_work_menu(null)
   CALL ts_inform("in tspace_work_menu")
   CALL clear(1,1)
   CALL display_tspace_header(null)
   SET display_line = 8
   IF ((tspace_screen->cur_line <= 1))
    SET tspace_screen->top_line = 1
    SET tspace_screen->cur_line = 1
    SET tspace_screen->bottom_line = 0
    SET tspace_screen->max_scroll = 14
   ELSE
    SET tspace_screen->top_line = tspace_screen->top_line
    SET tspace_screen->cur_line = tspace_screen->cur_line
    SET tspace_screen->bottom_line = tspace_screen->bottom_line
    SET tspace_screen->max_scroll = 14
   ENDIF
   CALL fill_tspace_screen(null)
   SET ts_destination = ""
   CASE (scroll("tspace_screen"))
    OF "E":
     IF ((rtspace->qual[tspace_screen->cur_line].ct_err_ind=1))
      IF ((dir_storage_misc->tgt_storage_type="ASM"))
       CALL tspace_set_disk_group(null)
      ELSE
       IF (tspace_set_space_add(null))
        SET ts_destination = "CONTAINER_SCREEN"
       ENDIF
      ENDIF
     ENDIF
    OF "A":
     IF ((rtspace->install_type="MANUAL"))
      SET ts_destination = "MANUALADD"
     ELSE
      IF (ts_check_if_tspace_to_display(null)=1)
       IF (tspace_check_complete(null) != "COMPLETE")
        SET ts_destination = "AUTOPOP_SCREEN"
       ELSE
        IF (ts_build_attempt > 0)
         CALL ap_reset_autopop(null)
         CALL ts_disk_refresh(null)
         IF ((dm2_sys_misc->cur_db_os="AXP")
          AND (rtspace->database_remote=0))
          CALL clear(24,1,130)
          CALL text(24,2,concat("Loading ",storage_device," Directory Information ...."))
          CALL ts_find_disks_for_datafiles(null)
         ENDIF
        ENDIF
        SET ts_destination = "AUTOPOP_SCREEN"
        SET ts_autopop_attempt = (ts_autopop_attempt+ 1)
       ENDIF
      ELSE
       CALL display_warning("AUTOPOP NOT AVAILABLE","0")
      ENDIF
     ENDIF
    OF "V":
     SET ts_destination = "SUMMARY_REPORT"
    OF "Q":
     SET ts_destination = "EXIT_PROGRAM"
    OF "C":
     SET message = nowindow
     CALL build_tspace(null)
     SET tspace_build = 1
    OF "D":
     SET ts_destination = "VIEW_DISK_REPORT"
     CALL ts_inform("calling view_disks")
    OF "M":
     CALL dtm_pop_help_array("test")
     SET ts_destination = "MANUALEDIT"
    OF "R":
     IF (size(rtspace->qual,5) > 0)
      IF (display_warning("REMOVE FROM RTSPACE",rtspace->qual[tspace_screen->cur_line].tspace_name)=
      "Y")
       CALL ts_sort_rtspace("DELETE")
      ENDIF
     ELSE
      CALL clear(24,2,130)
      CALL text(24,3,"No tablespaces are available for deletion from listing.")
      CALL pause(2)
     ENDIF
    OF "S":
     IF (size(rtspace->qual,5) > 0)
      SET rtspace->mode = "CREATE_DDL_ONLY"
      CALL build_tspace(null)
     ELSE
      CALL display_warning("NO DDL TO REPORT","")
     ENDIF
   ENDCASE
   RETURN(ts_destination)
 END ;Subroutine
 SUBROUTINE dtm_manual_add_driver(dmad_type_in)
   DECLARE dpad_add_leave = vc WITH protect, noconstant("")
   DECLARE dpad_screen_return = vc WITH protect, noconstant("")
   SET dpad_add_leave = "N"
   WHILE (dpad_add_leave="N")
     SET dpad_screen_return = ""
     SET dpad_screen_return = dtm_manual_add_work(dmad_type_in)
     CASE (dpad_screen_return)
      OF "QUIT":
       SET dpad_add_leave = "Y"
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE dtm_manual_add_work(dmaw_type_in)
   DECLARE dpaw_stay_menu = i2 WITH protect, noconstant(0)
   CALL clear(1,1)
   WHILE (dpaw_stay_menu=0)
     CALL dtm_manual_add_header(dmaw_type_in)
     IF (dmaw_type_in="E")
      CALL accept(23,108,"p;cu","A"
       WHERE curaccept IN ("A", "R", "V", "C"))
     ELSE
      CALL accept(23,85,"p;cu","A"
       WHERE curaccept IN ("A", "R", "V"))
     ENDIF
     CASE (curaccept)
      OF "A":
       SET dtm_destination = "ADD_TO_MANUAL"
      OF "R":
       SET dtm_destination = "QUIT"
      OF "V":
       SET dtm_destination = "VIEW_LISTING"
      OF "C":
       SET dtm_destination = "SORT_LISTING"
     ENDCASE
     CASE (dtm_destination)
      OF "ADD_TO_MANUAL":
       CALL dtm_manual_add_header(dmaw_type_in)
       CALL dtm_manual_add_prompts(dmaw_type_in)
      OF "VIEW_LISTING":
       CALL dtm_view_manual_listing(null)
      OF "SORT_LISTING":
       SET dtm_sort_criteria = display_warning("SORT LISTING",null)
      OF "QUIT":
       SET dpaw_stay_menu = 1
     ENDCASE
   ENDWHILE
   RETURN(dtm_destination)
 END ;Subroutine
 SUBROUTINE dtm_manual_add_header(dpah_type_in)
   CALL clear(1,1)
   CALL box(2,1,22,132)
   IF (dpah_type_in="E")
    CALL text(1,1,"TABLESPACE MANAGEMENT (MODIFY EXISTING)",w)
   ELSE
    CALL text(1,1,"TABLESPACE MANAGEMENT (ADD NEW)",w)
   ENDIF
   IF (dpah_type_in="N")
    CALL text(3,3,concat("Extent Management:",evaluate(dm2_db_options->new_tspace_type,"D",
       "Dictionary Managed","Locally Managed")))
   ENDIF
   IF (dpah_type_in="E")
    CALL text(5,3,concat("Sorting by:",evaluate(dtm_sort_criteria,"T","Tablespace Name",
       "Percent Used")))
   ENDIF
   IF (dpah_type_in="N")
    CALL text(6,3,"Select Tablespace Type:  (D)ata")
    CALL text(7,3,"                         (I)ndex ")
    CALL text(8,3,"                         (L)ong            Selection:")
    CALL box(5,27,9,65)
   ENDIF
   CALL line(10,1,132,xhor)
   CASE (dpah_type_in)
    OF "N":
     CALL text(11,3," New Tablespace Name: ")
    OF "E":
     CALL text(11,3," Existing Tablespace Name:")
     CALL text(13,3,"  -Wildcards allowed (e.g. D_A_*)")
   ENDCASE
   IF (dpah_type_in="E")
    CALL text(23,2,concat("(A)dd Tablespace to List, (R)eturn to Tablespace Menu,",
      " (V)iew Tablespace Listing, (C)hange Sort Criteria:"))
   ELSE
    CALL text(23,2,
     "(A)dd Tablespace to List, (R)eturn to Tablespace Menu, (V)iew Tablespace Listing:")
   ENDIF
 END ;Subroutine
 SUBROUTINE dtm_manual_add_prompts(dpap_type_in)
   DECLARE dpap_col = i2 WITH protect, noconstant(0)
   DECLARE dpap_help_ndx = i4 WITH protect, noconstant(0)
   DECLARE dpap_tspace_search = vc WITH protect, noconstant("")
   DECLARE dpap_tspace_accept = vc WITH protect, noconstant("")
   DECLARE dpap_tspace_name_type = vc WITH protect, noconstant("")
   SET dpap_col = evaluate(dpap_type_in,"N",25,35)
   IF (dpap_type_in="N")
    CALL accept(8,57,"p;cu","D"
     WHERE curaccept IN ("D", "I", "L"))
    SET dpap_tspace_name_type = curaccept
   ENDIF
   CASE (dpap_type_in)
    OF "N":
     CALL accept(11,dpap_col,"p(30);cu")
    OF "E":
     CALL accept(11,dpap_col,"p(30);cu")
     SET dpap_tspace_search = trim(curaccept)
     SET help = off
     SET help = pos(11,40,10,90)
     IF (size(rtspace->qual,5) > 0)
      SET help =
      SELECT
       IF (dtm_sort_criteria="P")
        FROM (dummyt d  WITH seq = size(dtm_available_ts->qual,5)),
         (dummyt r  WITH seq = size(rtspace->qual,5))
        PLAN (d
         WHERE d.seq > 0
          AND (dtm_available_ts->qual[d.seq].tspace_name=patstring(value(dpap_tspace_search))))
         JOIN (r
         WHERE r.seq > 0
          AND (dtm_available_ts->qual[d.seq].tspace_name=rtspace->qual[r.seq].tspace_name))
        ORDER BY dtm_available_ts->qual[d.seq].pct_used DESC
       ELSE
        FROM (dummyt d  WITH seq = size(dtm_available_ts->qual,5)),
         (dummyt r  WITH seq = size(rtspace->qual,5))
        PLAN (d
         WHERE d.seq > 0
          AND (dtm_available_ts->qual[d.seq].tspace_name=patstring(value(dpap_tspace_search))))
         JOIN (r
         WHERE r.seq > 0
          AND (dtm_available_ts->qual[d.seq].tspace_name=rtspace->qual[r.seq].tspace_name))
        ORDER BY dtm_available_ts->qual[d.seq].tspace_name
       ENDIF
       INTO "nl:"
       tablespace_name = dtm_available_ts->qual[d.seq].tspace_name, percent_used = dtm_available_ts->
       qual[d.seq].pct_used, free_space_mb = convert_bytes(dtm_available_ts->qual[d.seq].free_bytes,
        "b","m"),
       current_size_mb = convert_bytes(dtm_available_ts->qual[d.seq].current_size,"b","m")
       WITH nocounter, outerjoin = d, dontexist
      ;end select
     ELSE
      SET help =
      SELECT
       IF (dtm_sort_criteria="P")
        FROM (dummyt d  WITH seq = size(dtm_available_ts->qual,5))
        PLAN (d
         WHERE d.seq > 0
          AND (dtm_available_ts->qual[d.seq].tspace_name=patstring(value(dpap_tspace_search))))
        ORDER BY dtm_available_ts->qual[d.seq].pct_used DESC
       ELSE
        FROM (dummyt d  WITH seq = size(dtm_available_ts->qual,5))
        PLAN (d
         WHERE d.seq > 0
          AND (dtm_available_ts->qual[d.seq].tspace_name=patstring(value(dpap_tspace_search))))
        ORDER BY dtm_available_ts->qual[d.seq].tspace_name
       ENDIF
       INTO "nl:"
       tablespace_name = dtm_available_ts->qual[d.seq].tspace_name, percent_used = dtm_available_ts->
       qual[d.seq].pct_used, free_space_mb = convert_bytes(dtm_available_ts->qual[d.seq].free_bytes,
        "b","m"),
       current_size_mb = convert_bytes(dtm_available_ts->qual[d.seq].current_size,"b","m")
       WITH nocounter
      ;end select
     ENDIF
     CALL accept(11,dpap_col,"p(30);cuF")
     SET help = off
     SET dpap_help_ndx = locateval(dpap_help_ndx,1,size(dtm_available_ts->qual,5),dtm_available_ts->
      qual[curhelp].tspace_name,dtm_available_ts->qual[dpap_help_ndx].tspace_name)
   ENDCASE
   SET dpap_tspace_accept = trim(curaccept)
   CALL clear(24,1,130)
   CALL text(24,3,"CORRECT (Y/N)?")
   CALL accept(24,20,"p;cu","Y"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    IF (dtm_validate_tspace(dpap_tspace_accept,dpap_type_in,dpap_tspace_name_type)=0)
     CALL dtm_add_to_rtspace(dpap_tspace_accept,dpap_type_in,evaluate(dpap_type_in,"N",0,
       dpap_help_ndx))
     CALL display_warning("MANUAL ADD TSPACE",dpap_tspace_accept)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE dtm_pop_help_array(dpha_order)
   DECLARE dpha_cnt = i4 WITH protect, noconstant(0)
   SET stat = alterlist(dtm_available_ts->qual,0)
   SELECT INTO "nl:"
    FROM dm2_dba_data_files d,
     dm2_dba_tablespaces t
    WHERE d.tablespace_name=t.tablespace_name
    ORDER BY d.tablespace_name
    HEAD REPORT
     dpha_cnt = 0
    HEAD d.tablespace_name
     dpha_cnt = (dpha_cnt+ 1), stat = alterlist(dtm_available_ts->qual,dpha_cnt), dtm_available_ts->
     qual[dpha_cnt].tspace_name = trim(d.tablespace_name)
    DETAIL
     dtm_available_ts->qual[dpha_cnt].current_size = (dtm_available_ts->qual[dpha_cnt].current_size+
     d.bytes), dtm_available_ts->qual[dpha_cnt].pct_used = round((((dtm_available_ts->qual[dpha_cnt].
      current_size - dtm_available_ts->qual[dpha_cnt].free_bytes)/ dtm_available_ts->qual[dpha_cnt].
      current_size) * 100.0),2), dtm_available_ts->qual[dpha_cnt].extent_management = evaluate(t
      .extent_management,"DICTIONARY","D","L")
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM dm2_dba_free_space f,
     (dummyt d  WITH seq = size(dtm_available_ts->qual,5))
    PLAN (d
     WHERE d.seq > 0)
     JOIN (f
     WHERE (f.tablespace_name=dtm_available_ts->qual[d.seq].tspace_name))
    ORDER BY f.tablespace_name
    DETAIL
     dtm_available_ts->qual[d.seq].free_bytes = (dtm_available_ts->qual[d.seq].free_bytes+ f.bytes)
    FOOT  f.tablespace_name
     dtm_available_ts->qual[d.seq].pct_used = round((((dtm_available_ts->qual[d.seq].current_size -
      dtm_available_ts->qual[d.seq].free_bytes)/ dtm_available_ts->qual[d.seq].current_size) * 100.0),
      2)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE dtm_validate_tspace(dvt_tspace_in,dvt_type_in,dvt_name_type_in)
   DECLARE dvt_found_ind = i2 WITH protect, noconstant(0)
   DECLARE dvt_ndx = i4 WITH protect, noconstant(0)
   IF (dvt_type_in="N")
    IF (substring(1,2,dvt_tspace_in) != concat(dvt_name_type_in,"_"))
     SET dvt_found_ind = 1
     CALL display_warning("INVALID TSPACE NAME",concat("Tablespace name,",dvt_tspace_in,
       ",needs to begin with: ",trim(dvt_name_type_in),"_ . Tablespace not added to listing."))
     RETURN(1)
    ENDIF
   ENDIF
   IF (locateval(dvt_ndx,1,size(rtspace->qual,5),dvt_tspace_in,rtspace->qual[dvt_ndx].tspace_name) >
   0)
    SET dvt_found_ind = 1
   ENDIF
   IF (dvt_found_ind=1)
    CALL display_warning("TSPACE IN RTSPACE",dvt_tspace_in)
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    FROM dm2_user_tablespaces
    WHERE tablespace_name=dvt_tspace_in
    DETAIL
     dvt_found_ind = 1
    WITH nocounter
   ;end select
   IF (dvt_found_ind=1
    AND dvt_type_in="N")
    CALL display_warning("TSPACE EXISTS IN ENV",dvt_tspace_in)
    RETURN(1)
   ELSEIF (dvt_found_ind=0
    AND dvt_type_in="E")
    CALL display_warning("TSPACE DOES NOT EXIST",dvt_tspace_in)
    RETURN(1)
   ELSEIF (dvt_found_ind=1
    AND dvt_type_in="E")
    RETURN(0)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dtm_add_to_rtspace(datr_tspace_in,datr_type_in,datr_help_ndx)
   SET rtspace->rtspace_cnt = (value(size(rtspace->qual,5))+ 1)
   SET stat = alterlist(rtspace->qual,rtspace->rtspace_cnt)
   SET rtspace->qual[rtspace->rtspace_cnt].tspace_name = datr_tspace_in
   SET rtspace->qual[rtspace->rtspace_cnt].new_ind = evaluate(datr_type_in,"N",1,0)
   SET rtspace->qual[rtspace->rtspace_cnt].chunk_size = 0
   SET rtspace->qual[rtspace->rtspace_cnt].chunks_needed = 0
   SET rtspace->qual[rtspace->rtspace_cnt].ext_mgmt = evaluate(datr_type_in,"N",dm2_db_options->
    new_tspace_type,dtm_available_ts->qual[datr_help_ndx].extent_management)
   SET rtspace->qual[rtspace->rtspace_cnt].tspace_id = 0
   SET rtspace->qual[rtspace->rtspace_cnt].cur_bytes_allocated = evaluate(datr_type_in,"N",0,
    dtm_available_ts->qual[datr_help_ndx].current_size)
   SET rtspace->qual[rtspace->rtspace_cnt].bytes_needed = convert_bytes(1.0,"m","b")
   SET rtspace->qual[rtspace->rtspace_cnt].user_bytes_to_add = convert_bytes(1.0,"m","b")
   SET rtspace->qual[rtspace->rtspace_cnt].final_bytes_to_add = convert_bytes(1.0,"m","b")
   SET rtspace->qual[rtspace->rtspace_cnt].extend_ind = 0
   SET rtspace->qual[rtspace->rtspace_cnt].next_ext = evaluate(datr_type_in,"N",163840,0)
   SET rtspace->qual[rtspace->rtspace_cnt].init_ext = evaluate(datr_type_in,"N",163840,0)
   SET rtspace->qual[rtspace->rtspace_cnt].ct_err_ind = 1
   IF (datr_type_in="E")
    CALL dtm_gather_tspace_related_info(0,"TABLE",datr_tspace_in)
   ENDIF
   SET tspace_screen->max_value = size(rtspace->qual,5)
 END ;Subroutine
 SUBROUTINE dtm_view_manual_listing(null)
  DECLARE dvml_find_ndx = i4 WITH protect, noconstant(0)
  IF ((rtspace->rtspace_cnt > 0)
   AND locateval(dvml_find_ndx,1,size(rtspace->qual,5),1,rtspace->qual[dvml_find_ndx].ct_err_ind) > 0
  )
   SET help = pos(11,60,10,60)
   SET help =
   SELECT INTO "nl:"
    tablespace_name = rtspace->qual[d.seq].tspace_name, state_of_tablespace = evaluate(rtspace->qual[
     d.seq].new_ind,0,"Existing","New")
    FROM (dummyt d  WITH seq = value(rtspace->rtspace_cnt))
    PLAN (d
     WHERE (rtspace->qual[d.seq].ct_err_ind=1))
    ORDER BY tablespace_name
    WITH nocounter
   ;end select
   CALL accept(1,1,"P(1);cuF"," ")
   SET help = off
  ELSE
   CALL display_warning("NO TSPACE TO VIEW","")
  ENDIF
 END ;Subroutine
 SUBROUTINE dtm_gather_tspace_related_info(dgtri_mode,dgtri_type,dgtri_table)
   IF (dgtri_type IN ("DISK", "ALL"))
    IF (rdisk_pop(null)=0)
     CALL clear(23,1,130)
     CALL ts_inform("Unable to load rdisk information - exiting application.")
     CALL text(23,2,"Unable to load tspace information - exiting application. Please view Logfile.")
     GO TO exit_program
    ENDIF
    IF ((dm2_sys_misc->cur_db_os="AXP")
     AND (rtspace->database_remote=0))
     CALL ts_inform("Finding disks with datafile directories...")
     CALL ts_find_disks_for_datafiles(null)
    ENDIF
   ENDIF
   IF (dgtri_type IN ("TABLE", "ALL"))
    IF (get_tspace_info(dgtri_mode,dgtri_table)=0)
     CALL clear(23,1,130)
     CALL ts_inform("Unable to load tspace information - exiting application.")
     CALL text(23,2,"Unable to load tspace information - exiting application. Please view Logfile.")
     GO TO exit_program
    ENDIF
    IF ((dm2_sys_misc->cur_db_os="AIX")
     AND (dir_storage_misc->tgt_storage_type="RAW"))
     IF (get_disk_for_lv(dgtri_type,dgtri_table)=0)
      CALL clear(23,1,130)
      CALL ts_inform(concat("Unable to load logical volume for existing ",storage_device,
        " - exiting application."))
      CALL text(23,2,concat("Unable to load logical volume for existing ",storage_device,
        " - exiting application."))
      GO TO exit_program
     ENDIF
    ENDIF
   ENDIF
   CALL config_total_disk_space(null)
 END ;Subroutine
 SUBROUTINE scroll(rec_str)
   CALL ts_inform("in _Scroll")
   DECLARE top_line = i4 WITH protect, noconstant(0)
   DECLARE bottom_line = i4 WITH protect, noconstant(0)
   DECLARE max_value = i4 WITH protect, noconstant(0)
   DECLARE max_scroll = i4 WITH protect, noconstant(0)
   DECLARE cur_line = i4 WITH protect, noconstant(0)
   DECLARE disp_create_ind = i2 WITH protect, noconstant(0)
   DECLARE valid_value = i2 WITH protect, noconstant(0)
   SET scroll_accept = " "
   IF ((dir_storage_misc->tgt_storage_type IN ("ASM", "AXP")))
    SET ap_display_pop_option = 1
   ENDIF
   CALL parser(concat("set top_line = ",rec_str,"->top_line go"))
   CALL parser(concat("set bottom_line = ",rec_str,"->bottom_line go"))
   CALL parser(concat("set max_value = ",rec_str,"->max_value go"))
   CALL parser(concat("set max_scroll = ",rec_str,"->max_scroll go"))
   CALL parser(concat("set cur_line = ",rec_str,"->cur_line go"))
   SET disp_create_ind = 0
   IF (tspace_check_complete(null)="COMPLETE"
    AND size(rtspace->qual,5) > 0)
    SET disp_create_ind = 1
   ELSE
    SET disp_create_ind = 0
   ENDIF
   CALL clear(23,1,132)
   IF (size(rtspace->qual,5)=0)
    SET ts_autopop_ok = 0
   ELSE
    SET ts_autopop_ok = 1
   ENDIF
   IF (rec_str="tspace_screen")
    CALL video(n)
    IF (disp_create_ind=0)
     IF ((dir_storage_misc->tgt_storage_type="ASM")
      AND (rtspace->install_type="MANUAL")
      AND size(rtspace->qual,5) > 0)
      CALL text(23,2,"(E)dit, (A)dd New, (M)odify Existing, (R)emove, (D)isk Space Report, (Q)uit:")
     ELSEIF ((dir_storage_misc->tgt_storage_type="ASM")
      AND (rtspace->install_type="MANUAL"))
      CALL text(23,2,"(A)dd New, (M)odify Existing, (R)emove, (D)isk Space Report, (Q)uit:")
     ELSEIF ((dir_storage_misc->tgt_storage_type="ASM")
      AND ts_autopop_ok=1)
      CALL text(23,2,"(E)dit, (D)isk Space Report, (A)uto Populate, (Q)uit:")
     ELSEIF ((dir_storage_misc->tgt_storage_type="ASM")
      AND ts_autopop_ok=0)
      CALL text(23,2,"(E)dit, (D)isk Space Report, (Q)uit:")
     ELSEIF ((rtspace->install_type="MANUAL")
      AND size(rtspace->qual,5) > 0)
      CALL text(23,2,
       "(E)dit, (A)dd New, (M)odify Existing, (R)emove, (D)isk Space Report, (V)iew Settings, (S)how DDL, (Q)uit:"
       )
     ELSEIF ((rtspace->install_type="MANUAL"))
      CALL text(23,2,
       "(A)dd New, (M)odify Existing, (R)emove, (D)isk Space Report, (V)iew Settings, (S)how DDL, (Q)uit:"
       )
     ELSE
      IF (ts_autopop_ok=1)
       CALL text(23,2,
        "(E)dit, (D)isk Space Report, (V)iew Settings, (A)uto Populate, (S)how DDL, (Q)uit:")
      ELSE
       CALL text(23,2,"(E)dit, (D)isk Space Report, (V)iew Settings, (S)how DDL, (Q)uit:")
      ENDIF
     ENDIF
    ELSE
     IF ((dir_storage_misc->tgt_storage_type="ASM")
      AND (rtspace->install_type="MANUAL")
      AND size(rtspace->qual,5) > 0)
      CALL text(23,2,concat("(C)reate All, (E)dit, (A)dd New, (M)odify Existing, (R)emove,",
        "(D)isk Space Report, (Q)uit:"))
     ELSEIF ((dir_storage_misc->tgt_storage_type="ASM")
      AND (rtspace->install_type="MANUAL"))
      CALL text(23,2,concat("(C)reate All, (A)dd New, (M)odify Existing, (R)emove,",
        "(D)isk Space Report, (Q)uit:"))
     ELSEIF ((dir_storage_misc->tgt_storage_type="ASM")
      AND ts_autopop_ok=1)
      CALL text(23,2,"(C)reate All, (E)dit, (D)isk Space Report, (A)uto Populate, (Q)uit:")
     ELSEIF ((dir_storage_misc->tgt_storage_type="ASM")
      AND ts_autopop_ok=0)
      CALL text(23,2,"(C)reate All, (E)dit, (D)isk Space Report, (Q)uit:")
     ELSEIF ((rtspace->install_type="MANUAL")
      AND size(rtspace->qual,5) > 0)
      CALL text(23,2,concat("(C)reate All, (E)dit, (A)dd New, (M)odify Existing, (R)emove,",
        "(D)isk Space Report, (V)iew Settings, (S)how DDL, (Q)uit:"))
     ELSEIF ((rtspace->install_type="MANUAL"))
      CALL text(23,2,concat("(C)reate All, (A)dd New, (M)odify Existing, (R)emove,",
        "(D)isk Space Report,(V)iew Settings, (S)how DDL, (Q)uit:"))
     ELSE
      IF (ts_autopop_ok=1)
       CALL text(23,2,concat("(C)reate All, (E)dit, (D)isk Space Report, (V)iew Settings,",
         " (A)uto Populate, (S)how DDL, (Q)uit:"))
      ELSE
       CALL text(23,2,
        "(C)reate All, (E)dit, (D)isk Space Report, (V)iew Settings, (S)how DDL, (Q)uit:")
      ENDIF
     ENDIF
    ENDIF
   ELSEIF (rec_str="ncont_screen")
    IF ((ncont_screen->remain_space_add <= 0))
     CALL text(23,2,"(C)ompleted ,(A)dd, (E)xtend, (R)emove, (Q)uit:")
    ELSE
     CALL text(23,2,"(A)dd, (E)xtend, (R)emove, (Q)uit:")
    ENDIF
   ELSEIF (rec_str="autopop_screen")
    IF (autopop_ready_ind=0)
     IF (size(autopop_screen->disk,5) > 0
      AND ap_display_pop_option=1)
      CALL text(23,2,"(A)dd, (R)emove, (Q)uit, (P)opulate:")
     ELSE
      IF (size(autopop_screen->disk,5)=0)
       CALL text(23,2,"(A)dd, (Q)uit:")
      ELSE
       CALL text(23,2,"(A)dd, (R)emove, (Q)uit:")
      ENDIF
     ENDIF
    ELSE
     CALL text(23,2,"(A)dd, (R)emove, (C)omplete, (Q)uit, (P)opulate:")
    ENDIF
   ENDIF
   WHILE (scroll_accept=" ")
     SET valid_value = 0
     IF (rec_str="tspace_screen")
      IF (disp_create_ind=0)
       IF ((dir_storage_misc->tgt_storage_type="ASM")
        AND (rtspace->install_type="MANUAL")
        AND size(rtspace->qual,5) > 0)
        CALL accept(23,79,"p;cus","A"
         WHERE curaccept IN ("E", "A", "M", "R", "D",
         "Q"))
       ELSEIF ((dir_storage_misc->tgt_storage_type="ASM")
        AND (rtspace->install_type="MANUAL"))
        CALL accept(23,71,"p;cus","A"
         WHERE curaccept IN ("A", "M", "R", "D", "Q"))
       ELSEIF ((dir_storage_misc->tgt_storage_type="ASM")
        AND ts_autopop_ok=1)
        CALL accept(23,56,"p;cus","A"
         WHERE curaccept IN ("E", "A", "D", "Q"))
       ELSEIF ((dir_storage_misc->tgt_storage_type="ASM")
        AND ts_autopop_ok=0)
        CALL accept(23,39,"p;cus","A"
         WHERE curaccept IN ("E", "D", "Q"))
       ELSEIF ((rtspace->install_type="MANUAL")
        AND size(rtspace->qual,5) > 0)
        CALL accept(23,109,"p;cus","A"
         WHERE curaccept IN ("E", "A", "M", "R", "D",
         "Q", "V", "S"))
       ELSEIF ((rtspace->install_type="MANUAL"))
        CALL accept(23,101,"p;cus","A"
         WHERE curaccept IN ("A", "M", "R", "D", "Q",
         "V", "S"))
       ELSE
        IF (ts_autopop_ok=1)
         CALL accept(23,85,"p;cus","E"
          WHERE curaccept IN ("E", "V", "Q", "D", "A",
          "S"))
        ELSE
         CALL accept(23,68,"p;cus","E"
          WHERE curaccept IN ("E", "V", "Q", "D", "S"))
        ENDIF
       ENDIF
      ELSE
       IF ((dir_storage_misc->tgt_storage_type="ASM")
        AND (rtspace->install_type="MANUAL"))
        CALL accept(23,92,"p;cus","A"
         WHERE curaccept IN ("A", "M", "R", "D", "Q",
         "C"))
       ELSEIF ((dir_storage_misc->tgt_storage_type="ASM")
        AND ts_autopop_ok=1)
        CALL accept(23,71,"p;cus","A"
         WHERE curaccept IN ("E", "A", "D", "Q", "C"))
       ELSEIF ((dir_storage_misc->tgt_storage_type="ASM")
        AND ts_autopop_ok=0)
        CALL accept(23,40,"p;cus","A"
         WHERE curaccept IN ("E", "D", "Q", "C"))
       ELSEIF ((rtspace->install_type="MANUAL"))
        CALL accept(23,121,"p;cus","A"
         WHERE curaccept IN ("C", "E", "A", "M", "R",
         "D", "Q", "V", "S"))
       ELSE
        IF (ts_autopop_ok=1)
         CALL accept(23,99,"p;cus","V"
          WHERE curaccept IN ("C", "E", "A", "V", "Q",
          "D", "S"))
        ELSE
         CALL accept(23,82,"p;cus","V"
          WHERE curaccept IN ("C", "E", "V", "Q", "D",
          "S"))
        ENDIF
       ENDIF
      ENDIF
     ELSEIF (rec_str="ncont_screen")
      IF ((ncont_screen->remain_space_add <= 0))
       CALL accept(23,50,"p;cus","C"
        WHERE curaccept IN ("C", "A", "E", "R", "Q"))
      ELSE
       CALL accept(23,38,"p;cus","A"
        WHERE curaccept IN ("A", "E", "R", "Q"))
      ENDIF
     ELSEIF (rec_str="autopop_screen")
      IF (autopop_ready_ind=0)
       IF (size(autopop_screen->disk,5) > 0
        AND ap_display_pop_option=1)
        CALL accept(23,39,"p;cus","P"
         WHERE curaccept IN ("A", "P", "R", "Q"))
       ELSE
        IF (size(autopop_screen->disk,5) > 0)
         CALL accept(23,28,"p;cus","A"
          WHERE curaccept IN ("A", "R", "Q"))
        ELSE
         CALL accept(23,19,"p;cus","A"
          WHERE curaccept IN ("A", "Q"))
        ENDIF
       ENDIF
      ELSE
       CALL accept(23,51,"p;cus","C"
        WHERE curaccept IN ("A", "P", "R", "C", "Q"))
      ENDIF
     ENDIF
     CASE (curscroll)
      OF 0:
       SET scroll_accept = curaccept
      OF 1:
       WHILE (valid_value=0)
         IF (cur_line=bottom_line)
          SET valid_value = 1
          SET cur_line = top_line
         ELSE
          IF (cur_line >= max_value)
           SET cur_line = top_line
           SET valid_value = 1
          ELSE
           SET cur_line = (cur_line+ 1)
          ENDIF
         ENDIF
         CALL parser(concat("set ",rec_str,"->cur_line = ",cnvtstring(cur_line)," go"))
         IF ((rtspace->qual[tspace_screen->cur_line].ct_err_ind=1))
          SET valid_value = 1
         ENDIF
         IF (valid_value=1)
          CALL parser(concat("call fill_",rec_str,"(1) go"))
         ENDIF
       ENDWHILE
      OF 2:
       WHILE (valid_value=0)
         IF (cur_line=top_line)
          IF (bottom_line > max_value)
           SET cur_line = max_value
           SET valid_value = 1
          ELSE
           SET valid_value = 1
           SET cur_line = bottom_line
          ENDIF
         ELSE
          SET cur_line = (cur_line - 1)
         ENDIF
         CALL parser(concat("set ",rec_str,"->cur_line = ",cnvtstring(cur_line)," go"))
         IF ((rtspace->qual[tspace_screen->cur_line].ct_err_ind=1))
          SET valid_value = 1
         ENDIF
         IF (valid_value=1)
          CALL parser(concat("call fill_",rec_str,"(1) go"))
         ENDIF
       ENDWHILE
      OF 5:
       SET new_start = 0
       IF (top_line > max_scroll)
        SET top_line = (top_line - max_scroll)
        SET bottom_line = ((top_line+ max_scroll) - 1)
       ELSE
        SET top_line = 1
        IF ((max_value > (max_scroll - 1)))
         SET bottom_line = (top_line+ (max_scroll - 1))
        ELSE
         SET bottom_line = max_value
        ENDIF
       ENDIF
       SET cur_line = top_line
       CALL parser(concat("set ",rec_str,"->cur_line = ",cnvtstring(cur_line)," go"))
       CALL parser(concat("set ",rec_str,"->top_line = ",cnvtstring(top_line)," go"))
       CALL parser(concat("set ",rec_str,"->bottom_line  = ",cnvtstring(bottom_line)," go"))
       CALL parser(concat("call fill_",rec_str,"(1) go"))
      OF 6:
       SET new_start = 0
       SET new_start = (top_line+ max_scroll)
       IF (max_value >= new_start)
        SET top_line = new_start
        SET cur_line = top_line
        IF (((top_line+ (max_scroll - 1)) <= max_value))
         SET bottom_line = (top_line+ (max_scroll - 1))
        ELSE
         SET bottom_line = max_value
        ENDIF
       ELSE
        SET bottom_line = max_value
       ENDIF
       CALL parser(concat("set ",rec_str,"->cur_line = ",cnvtstring(cur_line)," go"))
       CALL parser(concat("set ",rec_str,"->top_line = ",cnvtstring(top_line)," go"))
       CALL parser(concat("set ",rec_str,"->bottom_line  = ",cnvtstring(bottom_line)," go"))
       CALL parser(concat("call fill_",rec_str,"(1) go"))
     ENDCASE
   ENDWHILE
   CALL parser(concat("set ",rec_str,"->top_line = ",cnvtstring(top_line)," go"))
   CALL parser(concat("set ",rec_str,"->bottom_line  = ",cnvtstring(bottom_line)," go"))
   CALL parser(concat("set ",rec_str,"->max_value = ",cnvtstring(max_value)," go"))
   CALL parser(concat("set ",rec_str,"->cur_line = ",cnvtstring(cur_line)," go"))
   CALL parser(concat("set ",rec_str,"->max_scroll = ",cnvtstring(max_scroll)," go"))
   SET no_diskspace = "N"
   CALL ts_inform(concat("User Pressed: ",curaccept))
   CASE (curaccept)
    OF "C":
     SET scroll_accept = "C"
    OF "E":
     SET scroll_accept = "E"
    OF "Q":
     SET scroll_accept = "Q"
    OF "A":
     SET scroll_accept = "A"
    OF "X":
     SET scroll_accept = "X"
    OF "D":
     SET scroll_accept = "D"
    OF "R":
     SET scroll_accept = "R"
    OF "V":
     SET scroll_accept = "V"
    OF "P":
     SET scroll_accept = "P"
    OF "S":
     SET scroll_accept = "S"
   ENDCASE
   RETURN(scroll_accept)
 END ;Subroutine
 SUBROUTINE fill_tspace_screen(null)
   CALL ts_inform("in fill_tspace_screen")
   DECLARE sts_tot_space = f8 WITH protect, noconstant(0.0)
   DECLARE ts_no_display = i2 WITH protect, noconstant(1)
   SET user_mb = 0.0
   SET display_line = 8
   SET tspace_screen->max_scroll = 14
   IF (((tspace_screen->top_line+ 14) > tspace_screen->max_value))
    SET tspace_screen->bottom_line = tspace_screen->max_value
   ELSE
    SET tspace_screen->bottom_line = (tspace_screen->top_line+ 13)
   ENDIF
   SET ts_no_display = 1
   FOR (display_loop = tspace_screen->top_line TO tspace_screen->bottom_line)
     IF ((rtspace->qual[display_loop].ct_err_ind=1))
      SET ts_no_display = 0
      IF ((display_loop=tspace_screen->cur_line))
       CALL video(r)
       SET row_nbr = display_line
      ELSE
       CALL video(n)
      ENDIF
      CALL clear(display_line,02,130)
      CALL text(display_line,15,cnvtstring(display_loop))
      CALL text(display_line,23,trim(rtspace->qual[display_loop].tspace_name))
      IF ((rtspace->qual[display_loop].cont_complete_ind=1))
       CALL text(display_line,3,"*")
      ENDIF
      SET mbytes_needed = convert_bytes(rtspace->qual[display_loop].bytes_needed,"b","m")
      IF ((dir_storage_misc->tgt_storage_type != "ASM"))
       CALL text(display_line,85,format(cnvtstring(mbytes_needed),"##########;r"))
       SET sts_tot_space = 0.0
       FOR (ts_cnt_var = 1 TO size(rtspace->qual[display_loop].cont,5))
         IF ((((rtspace->qual[display_loop].cont[ts_cnt_var].new_ind=1)) OR ((rtspace->qual[
         display_loop].cont[ts_cnt_var].add_ext_ind="x"))) )
          SET sts_tot_space = (sts_tot_space+ rtspace->qual[display_loop].cont[ts_cnt_var].
          space_to_add)
         ENDIF
       ENDFOR
       SET user_mb = convert_bytes(cnvtreal(sts_tot_space),"b","m")
       IF (user_mb=0)
        SET user_mb = convert_bytes(rtspace->qual[display_loop].user_bytes_to_add,"b","m")
       ENDIF
       CALL text(display_line,111,format(cnvtstring(user_mb),"##########;r"))
       CALL text(display_line,56,format(cnvtstring(rtspace->qual[display_loop].cur_bytes_allocated),
         "##########;r"))
      ELSE
       CALL text(display_line,56,format(cnvtstring(mbytes_needed),"##########;r"))
       CALL text(display_line,80,rtspace->qual[display_loop].asm_disk_group)
      ENDIF
      SET display_line = (display_line+ 1)
     ENDIF
   ENDFOR
   IF (display_line < 21)
    CALL video(n)
    FOR (display_blank = display_line TO 21)
      CALL clear(display_blank,2,130)
    ENDFOR
   ENDIF
   CALL video(n)
   IF (ts_no_display=1)
    CALL clear(24,60,72)
    IF ((dir_storage_misc->tgt_storage_type != "ASM"))
     CALL text(24,60,"No Tablespaces to Add or Extend.")
    ELSE
     CALL text(24,60,"No Tablespaces to Add.")
    ENDIF
   ELSE
    IF ((tspace_screen->max_value > tspace_screen->bottom_line)
     AND (tspace_screen->top_line=1))
     CALL clear(24,60,72)
     CALL text(24,60,"More tablespaces available, use <PgDown> key to scroll list")
    ELSEIF ((tspace_screen->max_value > tspace_screen->bottom_line))
     CALL clear(24,60,72)
     CALL text(24,60,"More tablespaces available, use <PgUp>/<PgDown> keys to scroll list")
    ELSE
     CALL clear(24,60,72)
     CALL text(24,60,"Bottom of list, use <PgUp> key to scroll list")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE build_tspace(null)
   DECLARE bt_ts_cnt = i4 WITH protect, noconstant(0)
   DECLARE bt_err_ind = i2 WITH protect, noconstant(0)
   DECLARE bt_ct_cnt = i4 WITH protect, noconstant(0)
   DECLARE bt_rdc_ndx = i4 WITH protect, noconstant(0)
   DECLARE bt_rdc_cnt = i4 WITH protect, noconstant(0)
   CALL clear(23,02,130)
   IF ((rtspace->mode="CREATE_DDL_ONLY"))
    CALL text(23,3,"Generating DDL....")
   ELSE
    CALL text(23,3,"Building Tablespaces....")
   ENDIF
   IF ((dm2_sys_misc->cur_db_os="AXP")
    AND (rtspace->mode != "CREATE_DDL_ONLY")
    AND (rtspace->database_remote=0))
    FREE RECORD rs_disk_check
    RECORD rs_disk_check(
      1 qual[*]
        2 rdc_disk = vc
    )
    FOR (bt_ts_cnt = 1 TO size(rtspace->qual,5))
      FOR (bt_ct_cnt = 1 TO size(rtspace->qual[bt_ts_cnt].cont,5))
        IF ((rtspace->qual[bt_ts_cnt].cont[bt_ct_cnt].new_ind=1))
         IF (locateval(bt_rdc_ndx,1,size(rs_disk_check->qual,5),rtspace->qual[bt_ts_cnt].cont[
          bt_ct_cnt].volume_label,rs_disk_check->qual[bt_rdc_ndx].rdc_disk)=0)
          SET bt_rdc_cnt = (bt_rdc_cnt+ 1)
          SET stat = alterlist(rs_disk_check->qual,bt_rdc_cnt)
          SET rs_disk_check->qual[bt_rdc_cnt].rdc_disk = rtspace->qual[bt_ts_cnt].cont[bt_ct_cnt].
          volume_label
         ENDIF
        ENDIF
      ENDFOR
    ENDFOR
    SET bt_rdc_cnt = 0
    FOR (bt_rdc_cnt = 1 TO size(rs_disk_check->qual,5))
      CALL ts_validate_disk_directories(rs_disk_check->qual[bt_rdc_cnt].rdc_disk)
    ENDFOR
   ENDIF
   EXECUTE dm2_create_tspace
   IF ((rtspace->mode != "CREATE_DDL_ONLY"))
    CALL ts_sort_rtspace("ERROR")
    SET ts_build_attempt = (ts_build_attempt+ 1)
    IF ((dm_err->err_ind=1))
     SET message = window
     CALL display_tspace_header(null)
     CALL fill_tspace_screen(null)
     CALL clear(23,02,130)
     CALL text(24,3,"Error while building Tspaces - Please Review Log File")
    ELSE
     FOR (bt_ts_cnt = 1 TO size(rtspace->qual,5))
       IF ((rtspace->qual[bt_ts_cnt].ct_err_ind=1))
        SET message = window
        CALL display_tspace_header(null)
        CALL fill_tspace_screen(null)
        CALL text(23,3,"Error while building Tspaces - Please Review Log File")
        CALL video(r)
        CALL text(24,3,"Press return to exit.")
        CALL accept(24,23,"p;cduh","E"
         WHERE curaccept IN ("E"))
        CALL video(n)
        SET bt_ts_cnt = size(rtspace->qual,5)
        SET bt_err_ind = 1
       ENDIF
     ENDFOR
     IF (bt_err_ind=0)
      SET dm_err->eproc = "Building Tablespaces has completed"
      CALL disp_msg("",dm_err->logfile,0)
      CALL display_tspace_summary_report(1)
      SET dm_err->eproc = concat("Tablespace Summary Information Report may be viewed at ",
       dtm_summary_logfile)
      CALL disp_msg("",dm_err->logfile,0)
      IF ((validate(dtd_quit_menu_ind,- (1)) != - (1)))
       SET dtd_quit_menu_ind = 1
      ENDIF
      GO TO exit_program
     ELSE
      SET message = window
      CALL display_tspace_header(null)
      CALL fill_tspace_screen(null)
     ENDIF
     IF (ts_load_hold_datafile(null)=0)
      CALL ts_inform(" Error occurred when loading existing datafiles")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
    ENDIF
   ELSE
    CALL clear(23,1,132)
    IF ((dm_err->err_ind=1))
     CALL text(23,2,concat("Error occurred during creation of DDL Report. Logfile: ",dm_err->logfile)
      )
    ELSE
     CALL text(23,2,concat("DDL Report is located in CCLUSERDIR:",rtspace->ddl_report_fname))
    ENDIF
    CALL video(r)
    CALL text(24,3,"Press Enter to return to Menu.")
    CALL accept(24,34,"p;cduh","E"
     WHERE curaccept IN ("E"))
    CALL video(n)
    SET rtspace->ddl_report_fname = "DM2NOTSET"
    SET rtspace->mode = "DM2NOTSET"
    SET dm_err->err_ind = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE tspace_set_disk_group(null)
   SET all_done = " "
   SET temp_space = 0.0
   WHILE (all_done=" ")
     IF ((rtspace->qual[tspace_screen->cur_line].ct_err_ind=1))
      CALL video(n)
      CALL clear(row_nbr,02,130)
      CALL clear(23,02,130)
      CALL clear(row_nbr,02,130)
      CALL text(row_nbr,15,cnvtstring(tspace_screen->cur_line))
      CALL text(row_nbr,23,trim(rtspace->qual[tspace_screen->cur_line].tspace_name))
      SET mbytes_needed = convert_bytes(rtspace->qual[tspace_screen->cur_line].bytes_needed,"b","m")
      CALL text(row_nbr,56,format(cnvtstring(mbytes_needed),"##########;r"))
      SET c_help_return = container_disk_help(1)
      CALL clear(24,02,130)
      IF ((rdisk->qual[cnvtint(c_help_return)].new_free_space_mb < mbytes_needed))
       CALL display_warning("DISK GROUP SPACE",c_help_return)
       CALL pause(2)
       SET all_done = "Y"
      ELSE
       SET all_done = "Y"
       SET rtspace->qual[tspace_screen->cur_line].asm_disk_group = rdisk->qual[cnvtint(c_help_return)
       ].disk_name
       SET rtspace->qual[tspace_screen->cur_line].cont_complete_ind = 1
      ENDIF
     ELSE
      SET all_done = "Y"
      CALL display_warning("NONE LEFT TO ADD",rtspace->qual[tspace_screen->cur_line].tspace_name)
     ENDIF
   ENDWHILE
   CALL config_total_disk_space(null)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE tspace_set_space_add(null)
   CALL ts_inform("in tspace_set_space_add")
   SET all_done = " "
   SET temp_space = 0.0
   WHILE (all_done=" ")
     IF ((rtspace->qual[tspace_screen->cur_line].ct_err_ind=1))
      CALL video(n)
      CALL clear(row_nbr,02,130)
      CALL clear(23,02,130)
      CALL text(row_nbr,15,cnvtstring(tspace_screen->cur_line))
      CALL text(row_nbr,23,trim(rtspace->qual[tspace_screen->cur_line].tspace_name))
      CALL text(row_nbr,56,format(cnvtstring(rtspace->qual[tspace_screen->cur_line].
         cur_bytes_allocated),"##########;r"))
      SET mbytes_needed = convert_bytes(rtspace->qual[tspace_screen->cur_line].bytes_needed,"b","m")
      CALL text(row_nbr,85,format(cnvtstring(mbytes_needed),"##########;r"))
      SET user_mb = convert_bytes(rtspace->qual[tspace_screen->cur_line].user_bytes_to_add,"b","m")
      CALL text(row_nbr,111,format(cnvtstring(user_mb),"##########;r"))
      CALL clear(24,3,130)
      CALL text(24,3,"Space to add must be equal to or greater than the space needed.")
      CALL accept(row_nbr,111,"NNNNNNNNNN;",mbytes_needed
       WHERE curaccept >= mbytes_needed)
      SET temp_space = cnvtreal(curaccept)
      SET rtspace->qual[tspace_screen->cur_line].user_bytes_to_add = convert_bytes(temp_space,"m","b"
       )
      CALL video(n)
      CALL clear(24,3,130)
      CALL text(24,3,"CORRECT (Y/N)?")
      CALL accept(24,20,"p;cu","Y"
       WHERE curaccept IN ("Y", "N"))
      IF (curaccept="Y")
       SET all_done = "Y"
      ENDIF
     ELSE
      SET all_done = "Y"
      CALL display_warning("NONE LEFT TO ADD",rtspace->qual[tspace_screen->cur_line].tspace_name)
     ENDIF
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE container_work_menu(null)
   DECLARE cwm_stay_here = i4 WITH protect, noconstant(0)
   DECLARE cwm_in_add_screen = i2 WITH protect, noconstant(0)
   DECLARE cwm_in_delete_screen = i2 WITH protect, noconstant(0)
   DECLARE cwm_cont_cnt = i4 WITH protect, noconstant(0)
   SET tcont_cnt = 0
   SET ncont_screen->cur_line = 1
   CALL clear(1,1)
   WHILE (cwm_stay_here=0)
     CALL ts_inform("in container_work_menu")
     IF (size(ncont_screen->cont,5)=0
      AND size(rtspace->qual[tspace_screen->cur_line].cont,5) > 0)
      CALL fill_existing_container_listing(null)
     ENDIF
     CALL display_container_header(null)
     IF (size(ncont_screen->cont,5) > 0)
      SET ncont_screen->cont_cnt = size(ncont_screen->cont,5)
      SET ncont_screen->max_value = ncont_screen->cont_cnt
      IF ((size(ncont_screen->cont,5) > ncont_screen->max_scroll))
       IF (((ncont_screen->top_line+ (ncont_screen->max_scroll - 1)) <= ncont_screen->max_value))
        SET ncont_screen->bottom_line = (ncont_screen->top_line+ (ncont_screen->max_scroll - 1))
       ELSE
        SET ncont_screen->bottom_line = ncont_screen->max_value
       ENDIF
      ELSE
       SET ncont_screen->bottom_line = size(ncont_screen->cont,5)
      ENDIF
      CALL fill_ncont_screen(1)
     ENDIF
     CASE (scroll("ncont_screen"))
      OF "Q":
       SET ts_destination = "CONTAINER_CANCEL"
      OF "A":
       SET ts_destination = "CONTAINER_ADD_MENU"
      OF "C":
       SET ts_destination = "CONTAINER_SAVE"
      OF "R":
       SET ts_destination = "CONTAINER_DELETE"
      OF "E":
       SET ts_destination = "CONTAINER_EXTEND_MENU"
     ENDCASE
     CASE (ts_destination)
      OF "CONTAINER_EXTEND_MENU":
       SET cwm_in_add_screen = 1
       SET cont_screen_return = container_extend_menu(ncont_screen->cur_line)
      OF "CONTAINER_ADD_MENU":
       SET cwm_in_add_screen = 1
       SET cont_screen_return = container_add_menu(null)
      OF "CONTAINER_CANCEL":
       SET cont_screen_return = container_cancel(null)
       SET cwm_stay_here = 1
      OF "CONTAINER_SAVE":
       IF ((ncont_screen->remain_space_add <= 0))
        IF (dtm_figure_extra_container(null)=0)
         SET cont_screen_return = save_cont_to_rtspace(null)
         SET cwm_stay_here = 1
         SET ts_destination = "DONE"
        ELSE
         CALL display_warning("NO SAVE",null)
        ENDIF
       ENDIF
      OF "CONTAINER_DELETE":
       SET cwm_stay_here = 1
       SET cwm_in_delete_screen = 1
       SET cont_screen_return = container_delete(ncont_screen->cur_line)
     ENDCASE
   ENDWHILE
   RETURN(ts_destination)
 END ;Subroutine
 SUBROUTINE dtm_figure_extra_container(null)
   DECLARE dfec_cont_cnt = i4 WITH protect, noconstant(0)
   DECLARE dfec_space_sum = f8 WITH protect, noconstant(0.0)
   DECLARE dfec_cont_mod_cnt = i4 WITH protect, noconstant(0)
   IF ((dm2_sys_misc->cur_db_os="AXP"))
    RETURN(0)
   ENDIF
   FOR (dfec_cont_cnt = 1 TO size(ncont_screen->cont,5))
     IF ((ncont_screen->cont[dfec_cont_cnt].space_to_add > 0))
      SET dfec_cont_mod_cnt = (dfec_cont_mod_cnt+ 1)
      SET dfec_space_sum = (dfec_space_sum+ (convert_bytes(ncont_screen->cont[dfec_cont_cnt].
       space_to_add,"b","m") - 1))
     ENDIF
   ENDFOR
   IF (dfec_space_sum <= convert_bytes(rtspace->qual[tspace_screen->cur_line].bytes_needed,"b","m")
    AND dfec_cont_mod_cnt > 1)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE container_add_menu(null)
   CALL ts_inform("in container_add_menu")
   DECLARE all_done = c1 WITH protect, noconstant("")
   DECLARE cont_space_ok = i2 WITH protect, noconstant(0)
   DECLARE write_cont_return = vc WITH protect, noconstant("")
   DECLARE cont_root_vg = i2 WITH protect, noconstant(0)
   DECLARE pp_val = i4 WITH protect, noconstant(0)
   DECLARE temp_file_name = vc WITH protect, noconstant("")
   DECLARE temp_space_add = f8 WITH protect, noconstant(0.0)
   DECLARE lv_filename_ok = vc WITH protect, noconstant("")
   DECLARE cam_space_mb = f8 WITH protect, noconstant(0.0)
   DECLARE cam_accept_hold = f8 WITH protect, noconstant(0.0)
   DECLARE cam_file = vc WITH protect, noconstant("")
   DECLARE cam_min_space_add = f8 WITH protect, noconstant(0.0)
   SET all_done = "N"
   WHILE (all_done != "Y")
     CALL display_container_header(null)
     IF (display_line >= 22)
      SET display_line = 12
     ENDIF
     CALL box(1,1,22,132)
     SET tcont_cnt = size(ncont_screen->cont,5)
     IF (tcont_cnt > 0)
      IF ((tcont_cnt >= ncont_screen->max_scroll))
       SET ncont_screen->top_line = ((size(ncont_screen->cont,5) - mod(size(ncont_screen->cont,5),
        ncont_screen->max_scroll))+ 1)
       CALL fill_ncont_screen(0)
      ENDIF
     ENDIF
     CALL text(display_line,20,cnvtstring((tcont_cnt+ 1)))
     SET c_help_return = container_disk_help(1)
     CALL clear(24,02,130)
     SET cont_root_vg = 0
     IF (c_help_return != "EXIT")
      IF (container_check_rootvg(cnvtint(c_help_return))="N")
       SET cont_root_vg = 1
      ENDIF
     ENDIF
     IF (cont_root_vg=1)
      SET no_diskspace = "Y"
      SET all_done = "Y"
      CALL clear(display_line,3,130)
     ELSE
      SET tcont_cnt = (tcont_cnt+ 1)
      SET ncont_screen->cur_line = tcont_cnt
      SET stat = alterlist(ncont_screen->cont,tcont_cnt)
      SET ncont_screen->cont_cnt = tcont_cnt
      SET ncont_screen->cont[tcont_cnt].disk_idx = cnvtint(c_help_return)
      SET ncont_screen->cont[tcont_cnt].disk_name = rdisk->qual[cnvtint(c_help_return)].disk_name
      SET ncont_screen->cont[tcont_cnt].mwc_flag = rdisk->qual[cnvtint(c_help_return)].mwc_flag
      IF ((dm2_sys_misc->cur_db_os IN ("HPX", "AIX"))
       AND (dir_storage_misc->tgt_storage_type="RAW"))
       SET ncont_screen->cont[tcont_cnt].vg_name = rdisk->qual[cnvtint(c_help_return)].vg_name
      ELSE
       SET ncont_screen->cont[tcont_cnt].volume_label = rdisk->qual[cnvtint(c_help_return)].
       volume_label
      ENDIF
      SET ncont_screen->cont[tcont_cnt].add_ext_ind = "a"
      SET ncont_screen->cont[tcont_cnt].cont_tspace_rel_key = tspace_ncont_rel_key(null)
      SET ncont_screen->cont[tcont_cnt].new_ind = 1
      IF ((dm2_sys_misc->cur_db_os IN ("HPX", "AIX"))
       AND (dir_storage_misc->tgt_storage_type="RAW"))
       SET ncont_screen->cont[tcont_cnt].pp_size_mb = rdisk->qual[cnvtint(c_help_return)].pp_size_mb
      ENDIF
      SET cont_space_ok = 0
      WHILE (cont_space_ok=0)
        SET temp_space_add = 0.0
        SET temp_space_add = fill_default_space_add(tspace_screen->cur_line,ncont_screen->
         remain_space_add)
        SET cam_min_space_add = 0
        SET cam_min_space_add = calc_min_space_add(tspace_screen->cur_line)
        IF (cam_min_space_add > 0)
         CALL display_warning("CHUNK MESSAGE",cnvtstring(cam_min_space_add))
        ELSE
         SET cam_min_space_add = 1
        ENDIF
        CALL accept(display_line,78,"NNNNNNNNNN;",temp_space_add
         WHERE curaccept >= cam_min_space_add)
        SET cam_accept_hold = cnvtreal(curaccept)
        SET temp_space_add = 0.0
        IF ((dm2_sys_misc->cur_db_os IN ("HPX", "AIX"))
         AND (dir_storage_misc->tgt_storage_type="RAW"))
         SET temp_space_add = cnvtreal(get_space_rounded(cam_accept_hold,ncont_screen->cont[tcont_cnt
           ].pp_size_mb))
        ELSE
         SET temp_space_add = cam_accept_hold
        ENDIF
        SET ncont_screen->cont[tcont_cnt].space_to_add = convert_bytes(temp_space_add,"m","b")
        IF ((dm2_sys_misc->cur_db_os IN ("HPX", "AIX"))
         AND (dir_storage_misc->tgt_storage_type="RAW"))
         SET pp_val = calc_disk_pp_num(convert_bytes(ncont_screen->cont[tcont_cnt].space_to_add,"b",
           "m"),ncont_screen->cont[tcont_cnt].pp_size_mb)
         SET ncont_screen->cont[tcont_cnt].pps_to_add = pp_val
         SET ncont_screen->cont[tcont_cnt].cont_size_mb = calc_cont_size_mb(ncont_screen->cont[
          tcont_cnt].pp_size_mb,ncont_screen->cont[tcont_cnt].pps_to_add)
        ELSE
         SET ncont_screen->cont[tcont_cnt].cont_size_mb = convert_bytes(ncont_screen->cont[tcont_cnt]
          .space_to_add,"b","m")
        ENDIF
        SET write_cont_return = tspace_check_disk_space(cnvtint(c_help_return),tcont_cnt)
        IF (write_cont_return="Y")
         SET cont_space_ok = 1
         SET lv_filename_ok = "N"
         WHILE (lv_filename_ok="N")
           SET temp_file_name = ""
           SET temp_file_name = get_new_lv_filename(rtspace->qual[tspace_screen->cur_line].
            tspace_name,1,"none")
           IF (temp_file_name="NO NAME")
            SET dm_err->err_ind = 1
            CALL ts_inform(concat("No datafile name is available for ",rtspace->qual[tspace_screen->
              cur_line].tspace_name))
            GO TO exit_program
           ENDIF
           CALL accept(display_line,91,"P(28);c",temp_file_name
            WHERE curaccept > "")
           SET cam_file = ""
           SET cam_file = trim(curaccept,3)
           IF (cam_file != temp_file_name)
            IF (get_new_lv_filename(rtspace->qual[tspace_screen->cur_line].tspace_name,0,cam_file)=
            "NAME EXISTS")
             CALL display_warning("LV FILENAME",cam_file)
            ELSE
             SET lv_filename_ok = "Y"
             SET ncont_screen->cont[tcont_cnt].lv_filename = cam_file
            ENDIF
            IF ((dm2_sys_misc->cur_db_os IN ("HPX", "AIX"))
             AND (dir_storage_misc->tgt_storage_type="RAW"))
             SET hd_last_seq = (hd_last_seq - 1)
            ENDIF
           ELSE
            SET lv_filename_ok = "Y"
            SET ncont_screen->cont[tcont_cnt].lv_filename = cam_file
           ENDIF
         ENDWHILE
         CALL clear(23,1,120)
         CALL clear(24,1,120)
         CALL display_container_footer(null)
         CALL display_container_header(null)
         CALL fill_ncont_screen(0)
        ELSE
         SET ncont_screen->cont[tcont_cnt].space_to_add = 0
         IF ((rtspace->qual[tspace_screen->cur_line].chunk_size >= convert_bytes(rdisk->qual[cnvtint(
           c_help_return)].new_free_space_mb,"m","b"))
          AND get_good_chunks(tspace_screen->cur_line) > 0)
          CALL display_warning("DISK SPACE NO CHANGE SIZE",c_help_return)
          SET cont_space_ok = 1
          SET write_cont_return = "N"
         ELSE
          IF (display_warning("DISK SPACE",c_help_return)="D")
           SET cont_space_ok = 1
           SET write_cont_return = "N"
          ENDIF
         ENDIF
        ENDIF
      ENDWHILE
      CALL box(1,1,22,132)
      IF (write_cont_return="Y"
       AND lv_filename_ok="Y")
       IF ((ncont_screen->remain_space_add=0))
        CALL clear(24,02,130)
        CALL text(24,3,"No space remaining to add.")
        SET all_done = "Y"
       ELSE
        SET all_done = "Y"
       ENDIF
       CALL cont_update_rdisk(cnvtint(c_help_return),tcont_cnt)
      ELSEIF (write_cont_return="N")
       SET stat = alterlist(ncont_screen->cont,(tcont_cnt - 1))
       SET tcont_cnt = (tcont_cnt - 1)
      ENDIF
      CALL box(1,1,22,132)
     ENDIF
   ENDWHILE
   RETURN(ts_destination)
 END ;Subroutine
 SUBROUTINE tspace_check_disk_space(help_ndx_in,tcont_ndx_in)
   CALL ts_inform("in tspace_check_disk_space")
   DECLARE tcd_disk_ok = vc WITH protect, noconstant("")
   CASE (dm2_sys_misc->cur_db_os)
    OF "HPX":
    OF "AIX":
     IF ((dir_storage_misc->tgt_storage_type="RAW"))
      IF (((rdisk->qual[help_ndx_in].new_free_space_mb - (ncont_screen->cont[tcont_ndx_in].pps_to_add
       * ncont_screen->cont[tcont_ndx_in].pp_size_mb)) >= 0))
       SET tcd_disk_ok = "Y"
      ELSE
       SET tcd_disk_ok = "N"
      ENDIF
     ENDIF
    OF "AXP":
     IF (((rdisk->qual[help_ndx_in].new_free_space_mb - convert_bytes(ncont_screen->cont[tcont_ndx_in
      ].space_to_add,"b","m")) >= 0))
      SET tcd_disk_ok = "Y"
     ELSE
      SET tcd_disk_ok = "N"
     ENDIF
   ENDCASE
   RETURN(tcd_disk_ok)
 END ;Subroutine
 SUBROUTINE cont_update_rdisk(disk_ndx_in,cu_cont_ndx)
   CALL ts_inform("in cont_update_rdisk")
   DECLARE find_ncont_ndx = i4
   DECLARE found_ndx = i4
   IF (cu_cont_ndx > 0
    AND disk_ndx_in > 0)
    IF ((dm2_sys_misc->cur_db_os IN ("HPX", "AIX"))
     AND (dir_storage_misc->tgt_storage_type="RAW"))
     SET rdisk->qual[disk_ndx_in].new_free_space_mb = (rdisk->qual[disk_ndx_in].new_free_space_mb - (
     ncont_screen->cont[cu_cont_ndx].pps_to_add * ncont_screen->cont[cu_cont_ndx].pp_size_mb))
    ELSE
     SET rdisk->qual[disk_ndx_in].new_free_space_mb = (rdisk->qual[disk_ndx_in].new_free_space_mb -
     convert_bytes(ncont_screen->cont[cu_cont_ndx].space_to_add,"b","m"))
    ENDIF
   ELSE
    CALL ts_inform("ERROR: Could not find the disk to update")
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE display_warning(warn_type_in,warn_data_in)
   DECLARE dw_num_var = f8
   CALL ts_inform("in display_warning")
   CALL ts_inform(build(warn_type_in,"....",warn_data_in))
   CASE (warn_type_in)
    OF "NO DISK FOR DATAFILE":
     CALL clear(23,02,130)
     CALL text(23,2,concat("Unable to obtain disk information for ",warn_data_in,". ",storage_device,
       " is unavailable for action."))
     CALL pause(2)
    OF "DISK GROUP SPACE":
     CALL clear(23,02,130)
     CALL text(23,2,concat("Not enough space in Disk Group: ",rdisk->qual[cnvtint(warn_data_in)].
       disk_name,". Please select another Disk Group."))
     CALL pause(2)
    OF "DISK SPACE":
     CALL clear(23,02,130)
     CALL text(23,2,concat("Size needed for ",storage_device," exceeds the ",
       "amount of space available on the selected disk by ",trim(cnvtstring((ncont_screen->cont[
         ncont_screen->cont_cnt].cont_size_mb - rdisk->qual[cnvtint(warn_data_in)].new_free_space_mb)
         )),
       " mbyte(s)"))
     CALL clear(24,3,130)
     CALL text(24,3,concat("Select New Disk(D) or Enter New ",storage_device," Size(C)?"))
     CALL accept(24,55,"p;cu","D"
      WHERE curaccept IN ("D", "C"))
     CALL clear(24,1,130)
     CALL clear(23,1,120)
     RETURN(curaccept)
    OF "DISK SPACE NO CHANGE SIZE":
     CALL clear(24,02,130)
     CALL text(24,2,concat("Size needed for ",storage_device," exceeds the ",
       "amount of space available on the selected disk by ",trim(cnvtstring((ncont_screen->cont[
         ncont_screen->cont_cnt].cont_size_mb - rdisk->qual[cnvtint(warn_data_in)].new_free_space_mb)
         )),
       " mbyte(s). Please select new disk."))
    OF "DATA TSPACE":
     CALL clear(23,02,130)
     CALL text(23,2,concat("The disk ,",warn_data_in,", has contains DATA tablespaces. ",
       "Use this disk to hold INDEX tablespace? "))
     CALL clear(24,3,130)
     CALL text(24,3,"Yes (Y) or No (N)?")
     CALL accept(24,23,"p;cu","N"
      WHERE curaccept IN ("Y", "N"))
     CALL clear(24,1,130)
     CALL clear(23,1,120)
     RETURN(curaccept)
    OF "INDEX TSPACE":
     CALL clear(23,02,130)
     CALL text(23,2,concat("The disk ,",warn_data_in,", has contains INDEX tablespaces. ",
       "Use this disk to hold DATA tablespace? "))
     CALL clear(24,3,130)
     CALL text(24,3,"Yes (Y) or No (N)?")
     CALL accept(24,60,"p;cu","N"
      WHERE curaccept IN ("Y", "N"))
     CALL clear(24,1,130)
     CALL clear(23,1,120)
     RETURN(curaccept)
    OF "DISK SPACE EXTEND":
     CALL clear(24,02,130)
     CALL text(24,2,concat("Size needed for ",storage_device," exceeds the ",
       "amount of space available on ",trim(ncont_screen->cont[cont_ext_ndx].disk_name),
       " by ",trim(cnvtstring((convert_bytes(ncont_screen->cont[cont_ext_ndx].space_to_add,"b","m")
          - rdisk->qual[cnvtint(warn_data_in)].new_free_space_mb)))," mbyte(s)"))
    OF "LV FILENAME":
     CALL clear(23,02,130)
     CALL text(23,2,concat("Logical Volume Name, ",trim(warn_data_in),
       " ,already used. Please Enter Different Name."))
    OF "NO SPACE TO ADD":
     CALL clear(24,1,67)
     CALL text(24,2,concat("Remain Space to Add is ZERO. Either REMOVE or EDIT existing ",
       storage_device,"s."))
    OF "NO EXTEND ADDED CONT":
     CALL clear(24,1,67)
     CALL text(24,2,concat("You may only extend ",storage_device,"s that exist for the tablespace."))
    OF "NO DISK SPACE":
     CALL clear(24,1,67)
     IF ((dir_storage_misc->tgt_storage_type="ASM"))
      CALL text(24,2,concat("Not enough disk space to add ",trim(warn_data_in)," tablespaces."))
     ELSE
      CALL text(24,2,concat("Not enough disk space to add ALL ",trim(warn_data_in)," tablespaces."))
     ENDIF
    OF "AUTOPOP DONE":
     CALL clear(24,1,67)
     IF ((dir_storage_misc->tgt_storage_type="ASM"))
      CALL text(24,2,concat("Auto Population is complete for ",warn_data_in,
        " tablespaces. Press 'Enter' to confirm."))
     ELSE
      CALL text(24,2,concat("Auto Population is complete for ",warn_data_in,
        " tablespaces. Press 'Enter' and move to next TableSpace Type."))
     ENDIF
    OF "AUTOPOP PROGRESS":
     CALL clear(24,1,132)
     CALL text(24,2,concat("Populating ",storage_device,"s for ",warn_data_in,"."))
    OF "AUTOPOP":
     CALL clear(24,1,132)
     CALL text(24,2,concat("No ",storage_device,"s to add for ",warn_data_in,"."))
     CALL pause(1)
    OF "NONE LEFT TO ADD":
     CALL clear(24,1,132)
     CALL text(24,2,concat("No ",storage_device,"s left to add for ",warn_data_in,"."))
    OF "NO SAVE":
     CALL clear(24,1,132)
     CALL text(24,2,concat(
       "Due to the overhead of control blocks for raw devices, at least one more partition needs to be added."
       ))
    OF "DISK USED":
     CALL clear(24,1,132)
     CALL text(24,2,concat("The following disk has been used previously: ",warn_data_in,"."))
     CALL pause(1)
    OF "PP RESTRICT":
     CALL clear(24,1,132)
     CALL text(24,2,concat("You may only use disks with  ",trim(warn_data_in),"MB Partitions."))
     CALL pause(3)
    OF "AUTOPOP NOT AVAILABLE":
     CALL clear(24,1,132)
     CALL text(24,2,"No Tablespaces Available for Auto Populate.")
     CALL pause(2)
    OF "CHUNK MESSAGE":
     CALL clear(23,70,52)
     CALL text(23,70,concat("Size must be greater than or equal to chunk size of ",trim(warn_data_in),
       "(MB)."))
    OF "NEW_OR_EXISTING":
     CALL clear(23,01,130)
     CALL text(23,2,concat("Would you like to add a New or Existing Tablespace to the list? "))
     CALL clear(24,3,130)
     CALL text(24,3,"New (N) or Existing (E)?")
     CALL accept(24,28,"p;cu","N"
      WHERE curaccept IN ("E", "N"))
     CALL clear(24,1,130)
     CALL clear(23,1,120)
     RETURN(curaccept)
    OF "TSPACE IN TSPACE_SIZE":
     CALL clear(24,1,132)
     CALL text(24,2,concat(trim(warn_data_in),
       " has not been added. It has been created through installation tools previously."))
     CALL pause(2)
    OF "TSPACE IN RTSPACE":
     CALL clear(24,1,132)
     CALL text(24,2,concat(trim(warn_data_in),
       " has not been added. It is currently in the list of tablespaces to create."))
     CALL pause(2)
    OF "TSPACE EXISTS IN ENV":
     CALL clear(24,1,132)
     CALL text(24,2,concat(trim(warn_data_in),
       " has not been added. It currently exists in the database."))
     CALL pause(2)
    OF "NO TSPACE TO VIEW":
     CALL clear(24,1,132)
     CALL text(24,2,"There are no Tablespaces in listing available for view.")
     CALL pause(2)
    OF "TSPACE DOES NOT EXIST":
     CALL clear(24,1,132)
     CALL text(24,2,concat(trim(warn_data_in)," does not exist. Cannot add as 'Existing'."))
     CALL pause(2)
    OF "INVALID TSPACE NAME":
     CALL clear(24,1,132)
     CALL text(24,2,warn_data_in)
     CALL pause(2)
    OF "SORT LISTING":
     CALL clear(23,01,130)
     CALL clear(24,3,130)
     CALL text(23,2,"Would you like to sort by (P)ercent Used or (T)ablespace Name? (P/T): ")
     CALL accept(23,72,"p;cu","T"
      WHERE curaccept IN ("T", "P"))
     CALL clear(24,1,130)
     CALL clear(23,1,120)
     RETURN(curaccept)
    OF "REMOVE FROM RTSPACE":
     CALL clear(24,3,130)
     CALL text(24,2,concat("Are you sure you want to remove ",trim(warn_data_in)," from the list? "))
     CALL text(24,value((53+ textlen(trim(warn_data_in)))),"(Y)es or (N)o:")
     CALL accept(24,value(((50+ textlen(trim(warn_data_in)))+ 18)),"p;cu","N"
      WHERE curaccept IN ("Y", "N"))
     CALL clear(24,1,130)
     RETURN(curaccept)
    OF "MANUAL ADD TSPACE":
     CALL clear(24,1,130)
     CALL text(24,2,concat("Tablespace,",trim(warn_data_in),",added to list successfully."))
     CALL pause(2)
    OF "TSPACE GATHER INFO":
     CALL clear(24,1,130)
     CALL text(24,2,"Loading Tablespace Information ....")
    OF "NO DDL TO REPORT":
     CALL clear(24,1,130)
     CALL text(24,2,"There are no Tablespaces available to report DDL on.")
     CALL pause(2)
   ENDCASE
 END ;Subroutine
 SUBROUTINE container_cancel(null)
   CALL ts_inform("in container cancel")
   DECLARE remove_containers_ind = i2 WITH protect, noconstant(0)
   DECLARE cc_rt_ndx = i4 WITH protect, noconstant(0)
   DECLARE cc_rt_cnt = i4 WITH protect, noconstant(0)
   FOR (cc_rt_cnt = 1 TO size(rtspace->qual[tspace_screen->cur_line].cont,5))
     SET rtspace->qual[tspace_screen->cur_line].cont[cc_rt_cnt].delete_ind = 0
   ENDFOR
   SET ncont_screen->cont_cnt = 0
   SET ncont_screen->top_line = 0
   SET ncont_screen->bottom_line = 0
   SET ncont_screen->cur_line = 0
   SET ncont_screen->max_value = 0
   SET stat = alterlist(ncont_screen->cont,0)
   CALL config_total_disk_space(null)
   SET ts_destination = "DONE"
   RETURN(ts_destination)
 END ;Subroutine
 SUBROUTINE autopop_add_menu(ap_mode_in)
   DECLARE disk_root_vg = i2 WITH protect, noconstant(0)
   CALL ts_inform("in autopop_add_menu")
   SET all_done = "N"
   WHILE (all_done != "Y")
     CALL display_autopop_header(ap_mode_in)
     IF (display_line >= 22)
      SET display_line = 12
     ENDIF
     CALL box(3,1,22,132)
     SET tdisk_cnt = size(autopop_screen->disk,5)
     IF (tdisk_cnt > 0)
      IF ((tdisk_cnt >= autopop_screen->max_scroll))
       SET autopop_screen->top_line = ((size(autopop_screen->disk,5) - mod(size(autopop_screen->disk,
         5),autopop_screen->max_scroll))+ 1)
       CALL fill_autopop_screen(0)
      ENDIF
     ENDIF
     SET c_help_return = container_disk_help(2)
     CALL ts_inform(cnvtstring(c_help_return))
     CALL clear(display_line,2,100)
     IF ((dm2_sys_misc->cur_db_os IN ("HPX", "AIX"))
      AND (dir_storage_misc->tgt_storage_type="RAW"))
      IF (tdisk_cnt=0)
       SET ap_pp_restrict = rdisk->qual[cnvtint(c_help_return)].pp_size_mb
      ENDIF
     ENDIF
     IF (c_help_return != "EXIT")
      IF ((rdisk->qual[cnvtint(c_help_return)].used_ind=""))
       IF ((((rdisk->qual[cnvtint(c_help_return)].pp_size_mb=ap_pp_restrict)) OR ((dm2_sys_misc->
       cur_db_os="AXP"))) )
        IF (container_check_rootvg(cnvtint(c_help_return))="N")
         SET disk_root_vg = 1
        ENDIF
       ELSE
        CALL display_warning("PP RESTRICT",trim(cnvtstring(ap_pp_restrict)))
        SET disk_root_vg = 1
       ENDIF
      ELSE
       CALL display_warning("DISK USED",trim(rdisk->qual[cnvtint(c_help_return)].disk_name))
       SET disk_root_vg = 1
      ENDIF
     ENDIF
     IF (disk_root_vg=1)
      SET no_diskspace = "Y"
      SET all_done = "Y"
     ELSE
      SET tdisk_cnt = (tdisk_cnt+ 1)
      SET autopop_screen->cur_line = tdisk_cnt
      SET stat = alterlist(autopop_screen->disk,tdisk_cnt)
      SET autopop_screen->disk_cnt = tdisk_cnt
      SET autopop_screen->disk[tdisk_cnt].disk_idx = cnvtint(c_help_return)
      SET autopop_screen->disk[tdisk_cnt].disk_name = rdisk->qual[cnvtint(c_help_return)].disk_name
      SET autopop_screen->disk[tdisk_cnt].mwc_flag = rdisk->qual[cnvtint(c_help_return)].mwc_flag
      IF ((dm2_sys_misc->cur_db_os IN ("AIX", "HPX"))
       AND (dir_storage_misc->tgt_storage_type="RAW"))
       SET autopop_screen->disk[tdisk_cnt].vg_name = rdisk->qual[cnvtint(c_help_return)].vg_name
      ELSE
       SET autopop_screen->disk[tdisk_cnt].volume_label = rdisk->qual[cnvtint(c_help_return)].
       volume_label
      ENDIF
      SET autopop_screen->disk[tdisk_cnt].disk_tspace_rel_key = tspace_ncont_rel_key(null)
      IF ((dm2_sys_misc->cur_db_os IN ("HPX", "AIX"))
       AND (dir_storage_misc->tgt_storage_type="RAW"))
       SET autopop_screen->disk[tdisk_cnt].pp_size_mb = rdisk->qual[cnvtint(c_help_return)].
       pp_size_mb
      ENDIF
      SET autopop_screen->disk[tdisk_cnt].free_disk_space_mb = rdisk->qual[cnvtint(c_help_return)].
      new_free_space_mb
      SET autopop_screen->disk[tdisk_cnt].orig_disk_space_mb = rdisk->qual[cnvtint(c_help_return)].
      new_free_space_mb
      SET disk_space_ok = 0
      CALL box(3,1,22,132)
      SET rdisk->qual[cnvtint(c_help_return)].used_ind = "*"
     ENDIF
     IF (size(autopop_screen->disk,5) > 0)
      CALL fill_autopop_screen(0)
     ENDIF
     CALL clear(24,02,130)
     CALL clear(24,1,130)
     SET all_done = "Y"
   ENDWHILE
   RETURN(ts_destination)
 END ;Subroutine
 SUBROUTINE autopop_cancel(null)
   CALL ts_inform("in autopop_cancel")
   SET autopop_screen->disk_cnt = 0
   SET autopop_screen->top_line = 0
   SET autopop_screen->bottom_line = 0
   SET autopop_screen->cur_line = 0
   SET autopop_screen->max_value = 0
   SET stat = alterlist(autopop_screen->disk,0)
   SET stat = alterlist(ap_spread_rs->ap_tspace,0)
   CALL config_total_disk_space(null)
   RETURN("DONE_CANCEL")
 END ;Subroutine
 SUBROUTINE fill_existing_container_listing(null)
   CALL ts_inform("in fill_existing_container_listing")
   DECLARE fec_cont_cnt = i4 WITH protect, noconstant(0)
   DECLARE fec_final_cnt = i4 WITH protect, noconstant(0)
   FOR (fec_final_cnt = 1 TO size(rtspace->qual[tspace_screen->cur_line].cont,5))
     IF ((rtspace->qual[tspace_screen->cur_line].cont[fec_final_cnt].delete_ind=0))
      SET fec_cont_cnt = (fec_cont_cnt+ 1)
      SET ncont_screen->cont_cnt = fec_cont_cnt
      SET stat = alterlist(ncont_screen->cont,fec_cont_cnt)
      SET ncont_screen->cont[fec_cont_cnt].cont_tspace_rel_key = rtspace->qual[tspace_screen->
      cur_line].cont[fec_cont_cnt].cont_tspace_rel_key
      SET ncont_screen->cont[fec_cont_cnt].volume_label = rtspace->qual[tspace_screen->cur_line].
      cont[fec_cont_cnt].volume_label
      SET ncont_screen->cont[fec_cont_cnt].lv_filename = rtspace->qual[tspace_screen->cur_line].cont[
      fec_cont_cnt].lv_file
      SET ncont_screen->cont[fec_cont_cnt].disk_name = rtspace->qual[tspace_screen->cur_line].cont[
      fec_cont_cnt].disk_name
      SET ncont_screen->cont[fec_cont_cnt].new_ind = rtspace->qual[tspace_screen->cur_line].cont[
      fec_cont_cnt].new_ind
      IF ((dm2_sys_misc->cur_db_os IN ("HPX", "AIX"))
       AND (dir_storage_misc->tgt_storage_type="RAW"))
       SET ncont_screen->cont[fec_cont_cnt].vg_name = rtspace->qual[tspace_screen->cur_line].cont[
       fec_cont_cnt].vg_name
      ELSE
       SET ncont_screen->cont[fec_cont_cnt].volume_label = rtspace->qual[tspace_screen->cur_line].
       cont[fec_cont_cnt].volume_label
      ENDIF
      SET ncont_screen->cont[fec_cont_cnt].cont_size_mb = rtspace->qual[tspace_screen->cur_line].
      cont[fec_cont_cnt].cont_size_mb
      IF ((dm2_sys_misc->cur_db_os IN ("HPX", "AIX"))
       AND (dir_storage_misc->tgt_storage_type="RAW"))
       SET ncont_screen->cont[fec_cont_cnt].pps_to_add = rtspace->qual[tspace_screen->cur_line].cont[
       fec_cont_cnt].pps_to_add
       SET ncont_screen->cont[fec_cont_cnt].pp_size_mb = rtspace->qual[tspace_screen->cur_line].cont[
       fec_cont_cnt].pp_size_mb
       SET ncont_screen->cont[fec_cont_cnt].space_to_add = (rtspace->qual[tspace_screen->cur_line].
       cont[fec_cont_cnt].pp_size_mb * rtspace->qual[tspace_screen->cur_line].cont[fec_cont_cnt].
       pps_to_add)
       SET ncont_screen->cont[fec_cont_cnt].space_to_add = convert_bytes(ncont_screen->cont[
        fec_cont_cnt].space_to_add,"m","b")
      ELSE
       SET ncont_screen->cont[fec_cont_cnt].space_to_add = rtspace->qual[tspace_screen->cur_line].
       cont[fec_cont_cnt].space_to_add
      ENDIF
      SET ncont_screen->cont[fec_cont_cnt].add_ext_ind = rtspace->qual[tspace_screen->cur_line].cont[
      fec_cont_cnt].add_ext_ind
      SET ncont_screen->cont[fec_cont_cnt].disk_idx = rtspace->qual[tspace_screen->cur_line].cont[
      fec_cont_cnt].disk_idx
      SET ncont_screen->cont[fec_cont_cnt].lv_filename = rtspace->qual[tspace_screen->cur_line].cont[
      fec_cont_cnt].lv_file
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE display_container_header(null)
   DECLARE dch_text = vc WITH protect, noconstant("")
   DECLARE dch_disk_cnt = i4 WITH protect, noconstant(0)
   DECLARE dch_pp_return = f8 WITH protect, noconstant(0.0)
   CALL ts_inform("in display_container_header")
   SET remain_space_mb = 0.0
   CALL line(7,1,132,xhor)
   CALL text(9,5,"Add/Extend")
   CALL text(10,5,"Indicator")
   CALL text(9,17,storage_device)
   CALL text(9,28,"Current Size")
   IF ((dm2_sys_misc->cur_db_os IN ("HPX", "AIX"))
    AND (dir_storage_misc->tgt_storage_type="RAW"))
    CALL text(9,41,"PP Size")
    CALL text(8,70,"PPs")
    CALL text(9,70," to ")
    IF ((dm2_sys_misc->cur_db_os="AIX"))
     CALL text(9,50,"Disk")
    ELSE
     CALL text(9,50,"Volume")
     CALL text(10,50,"Group")
    ENDIF
    CALL text(10,41,"(MBYTES)")
    CALL text(10,70,"Add")
   ELSE
    CALL text(9,50,"Volume")
    CALL text(10,50," Label")
   ENDIF
   CALL text(8,78,"Space to be")
   CALL text(9,78,"   Added")
   CALL text(10,78,"(MBYTES)")
   IF ((dm2_sys_misc->cur_db_os IN ("HPX", "AIX"))
    AND (dir_storage_misc->tgt_storage_type="RAW"))
    CALL text(10,91,"Logical Volume")
   ELSE
    CALL text(10,91,"File Name")
   ENDIF
   CALL text(10,28,"  (MBYTES)")
   SET ncont_screen->remain_space_add = 0.0
   IF (size(ncont_screen->cont,5)=0
    AND size(rtspace->qual[tspace_screen->cur_line].cont,5) > 0)
    CALL fill_existing_container_listing(null)
   ENDIF
   SET ncont_screen->user_bytes = 0.0
   SET ncont_screen->user_bytes = rtspace->qual[tspace_screen->cur_line].user_bytes_to_add
   SET ncont_screen->user_bytes_orig = 0.0
   SET ncont_screen->user_bytes_orig = rtspace->qual[tspace_screen->cur_line].bytes_needed
   SET user_mb = 0
   SET user_mb_display = 0
   SET user_mb = convert_bytes(rtspace->qual[tspace_screen->cur_line].user_bytes_to_add,"b","m")
   IF ((rtspace->qual[tspace_screen->cur_line].chunk_size > 0))
    SET user_mb_display = convert_bytes((dm2ceil((rtspace->qual[tspace_screen->cur_line].
      user_bytes_to_add/ rtspace->qual[tspace_screen->cur_line].chunk_size)) * rtspace->qual[
     tspace_screen->cur_line].chunk_size),"b","m")
   ELSE
    SET user_mb_display = user_mb
   ENDIF
   CALL text(6,3,"Total Space to Add(MB): ")
   CALL text(6,28,format(cnvtstring(user_mb_display),"##########;L"))
   CALL box(1,1,22,132)
   CALL line(11,1,132,xhor)
   IF ((rtspace->qual[tspace_screen->cur_line].new_ind=1))
    CALL text(2,44,concat(storage_device,"s for New Tablespace: "))
    CALL text(2,76,rtspace->qual[tspace_screen->cur_line].tspace_name)
   ELSE
    CALL text(2,44,concat(storage_device,"s for Existing Tablespace: "))
    CALL text(2,82,rtspace->qual[tspace_screen->cur_line].tspace_name)
   ENDIF
   CALL text(3,32,"('a' indicates added,'x' indicates extended,'-' indicates existing)")
   CALL clear(5,3,130)
   SET total = 0.0
   FOR (ts_cnt_var = 1 TO size(ncont_screen->cont,5))
     IF ((ncont_screen->cont[ts_cnt_var].space_to_add > 0))
      SET total = (total+ ncont_screen->cont[ts_cnt_var].space_to_add)
     ENDIF
   ENDFOR
   IF ((total <= ncont_screen->user_bytes))
    SET ncont_screen->remain_space_add = (ncont_screen->user_bytes - total)
   ENDIF
   SET ncont_screen->user_bytes_orig = (ncont_screen->user_bytes_orig - total)
   IF ((ncont_screen->remain_space_add < 0))
    SET ncont_screen->remain_space_add = 0.0
   ENDIF
   SET remain_space_mb = 0.0
   SET remain_space_mb = convert_bytes(ncont_screen->remain_space_add,"b","m")
   IF ((dm2_sys_misc->cur_db_os="AXP"))
    CALL text(5,3,"Remaining Space to Add:")
    CALL text(5,28,trim(cnvtstring(remain_space_mb)))
   ELSE
    FOR (dch_disk_cnt = 1 TO size(rd_pp_sizes->qual,5))
      SET dch_pp_return = 0.0
      SET dch_pp_return = calc_disk_pp_num(convert_bytes(ncont_screen->remain_space_add,"b","m"),
       rd_pp_sizes->qual[dch_disk_cnt].rd_size)
      IF (dch_disk_cnt=1)
       SET dch_text = concat("Remaining Partitions to Add: ",trim(cnvtstring(rd_pp_sizes->qual[
          dch_disk_cnt].rd_size)),"MB: ",trim(cnvtstring(dch_pp_return))," PPs     ")
      ELSE
       SET dch_text = concat(dch_text,"  ",trim(cnvtstring(rd_pp_sizes->qual[dch_disk_cnt].rd_size)),
        "MB: ",trim(cnvtstring(dch_pp_return)),
        " PPs   ")
      ENDIF
    ENDFOR
    CALL text(5,3,dch_text)
   ENDIF
   IF ((rtspace->qual[tspace_screen->cur_line].chunk_size > 0))
    CALL clear(6,50,80)
    SET dch_text = ""
    IF ((rtspace->qual[tspace_screen->cur_line].chunk_size > lmt_level_1m))
     SET dch_text = concat("Minimum Chunk Size(MB):",trim(cnvtstring(convert_bytes(rtspace->qual[
         tspace_screen->cur_line].chunk_size,"b","m"))),"            Remaining Chunks to Add:",trim(
       cnvtstring(get_good_chunks(tspace_screen->cur_line))))
    ELSE
     SET dch_text = concat("Minimum Chunk Size(KB):",trim(cnvtstring(convert_bytes(rtspace->qual[
         tspace_screen->cur_line].chunk_size,"b","k"))),"            Remaining Chunks to Add:",trim(
       cnvtstring(get_good_chunks(tspace_screen->cur_line))))
    ENDIF
    CALL text(6,50,dch_text)
   ENDIF
 END ;Subroutine
 SUBROUTINE get_good_chunks(grc_tspace_ndx)
  DECLARE grc_chunk_return = i4 WITH protect, noconstant(0)
  IF ((rtspace->qual[grc_tspace_ndx].chunk_size > 0))
   IF ((ncont_screen->user_bytes_orig > 0))
    SET grc_chunk_return = 0
    SET grc_chunk_return = dm2floor((ncont_screen->user_bytes_orig/ rtspace->qual[grc_tspace_ndx].
     chunk_size))
    RETURN(grc_chunk_return)
   ELSE
    RETURN(0)
   ENDIF
  ELSE
   RETURN(0)
  ENDIF
 END ;Subroutine
 SUBROUTINE display_autopop_header(ap_type_in)
   CALL ts_inform("in display_autopop_header")
   DECLARE ap_text = vc WITH protect, noconstant("")
   DECLARE ap_out = i2 WITH protect, noconstant(0)
   DECLARE ap_pp_return = f8 WITH protect, noconstant(0.0)
   DECLARE dah_disk_cnt = i4 WITH protect, noconstant(0)
   DECLARE dah_text = vc WITH protect, noconstant("")
   DECLARE dah_space_tot = f8 WITH protect, noconstant(0.0)
   DECLARE ap_min_size_in = vc WITH protect, noconstant("")
   SET ap_out = 0
   CALL line(8,1,132,xhor)
   SET ap_text = concat(ap_type_in," Tablespaces")
   CALL text(4,44,ap_text)
   IF ((dm2_sys_misc->cur_db_os="HPX")
    AND (dir_storage_misc->tgt_storage_type="RAW"))
    CALL text(10,21,"Volume Group")
   ELSE
    CALL text(10,21,"Disk Name")
   ENDIF
   IF ((dm2_sys_misc->cur_db_os="AXP"))
    CALL text(10,41,"Volume Label")
   ELSEIF ((dm2_sys_misc->cur_db_os="AIX")
    AND (dir_storage_misc->tgt_storage_type="RAW"))
    CALL text(10,41,"Volume Group")
   ENDIF
   IF ((dir_storage_misc->tgt_storage_type="ASM"))
    CALL text(10,78,"Total Space MB")
    CALL text(10,95,"Free Space MB")
   ELSEIF ((dm2_sys_misc->cur_db_os="AXP"))
    CALL text(9,78,"Space Remaining")
    CALL text(10,78,"(MBYTES)")
   ELSE
    CALL text(10,78,"PPs Remaining")
   ENDIF
   SET row_nbr = 0
   SET ap_space_needed_mb = get_total_space_add(ap_type_in)
   CALL text(2,2,"Auto-Populate",w)
   CALL box(3,1,22,132)
   CALL line(11,1,132,xhor)
   IF ((dir_storage_misc->tgt_storage_type IN ("ASM", "AXP")))
    CALL text(6,3,"Total Space to Add(MB): ")
    CALL text(6,27,format(cnvtstring(ap_space_needed_mb),"##########;R"))
    CALL clear(7,3,130)
    SET autopop_screen->user_bytes = ap_space_needed_mb
    IF ((dm2_sys_misc->cur_db_os="AXP"))
     CALL text(7,3,"Remaining Space to Add:")
     SET autopop_screen->remain_space_add = ap_get_remain_space_add(null)
     CALL text(7,27,format(cnvtstring(autopop_screen->remain_space_add),"##########;R"))
    ENDIF
   ENDIF
   IF (ap_max_cont_size=0
    AND (dir_storage_misc->tgt_storage_type != "ASM"))
    SET ap_min_size_in = cnvtstring(convert_bytes(dtm_max_chunk_size,"b","m"))
    IF (dtm_max_chunk_size > 0)
     CALL display_warning("CHUNK MESSAGE",ap_min_size_in)
    ELSE
     SET ap_min_size_in = "1"
    ENDIF
    CALL text(6,71,concat("Please Enter the Maximum ",storage_device," Size(MB):"))
    CALL accept(6,117,"NNNNNNNNNN;",max_size_constant
     WHERE curaccept >= cnvtint(ap_min_size_in))
    SET ap_max_cont_size = cnvtreal(curaccept)
    IF (curaccept > 0)
     SET ap_max_request = 1
    ENDIF
   ENDIF
   IF ((dir_storage_misc->tgt_storage_type != "ASM"))
    CALL clear(6,71,50)
    CALL text(6,91,concat("Maximum ",storage_device," Size(MB):"))
    CALL text(6,119,format(cnvtstring(ap_max_cont_size),"##########;R"))
   ENDIF
   IF ((dm2_sys_misc->cur_db_os IN ("HPX", "AIX"))
    AND (dir_storage_misc->tgt_storage_type="RAW"))
    SET ap_display_pop_option = 0
    IF (size(autopop_screen->disk,5) > 0)
     SET ap_pp_return = 0.0
     SET ap_pp_return = ap_display_pp_totals(autopop_screen->remain_space_add,autopop_screen->disk[1]
      .pp_size_mb,ap_max_cont_size,ap_type_in)
     SET dah_disk_cnt = 0
     SET dah_space_tot = 0
     FOR (dah_disk_cnt = 1 TO size(autopop_screen->disk,5))
       SET dah_space_tot = (dah_space_tot+ calc_disk_pp_num(autopop_screen->disk[dah_disk_cnt].
        free_disk_space_mb,autopop_screen->disk[dah_disk_cnt].pp_size_mb))
     ENDFOR
     CALL ts_inform(cnvtstring(dah_space_tot))
     CALL ts_inform(cnvtstring(ap_pp_return))
     IF (ap_pp_return <= dah_space_tot)
      SET ap_display_pop_option = 1
     ENDIF
     IF (((ap_pp_return - dah_space_tot) < 0))
      SET ap_pp_return = 0
      SET dah_space_tot = 0
     ENDIF
     SET dah_text = concat("Remaining Partitions to Add: ",trim(cnvtstring(autopop_screen->disk[1].
        pp_size_mb)),"MB: ",trim(cnvtstring((ap_pp_return - dah_space_tot))),"PPs     ")
    ELSE
     FOR (dah_disk_cnt = 1 TO size(rd_pp_sizes->qual,5))
       SET ap_pp_return = 0.0
       SET ap_pp_return = ap_display_pp_totals(autopop_screen->remain_space_add,rd_pp_sizes->qual[
        dah_disk_cnt].rd_size,ap_max_cont_size,ap_type_in)
       IF (dah_disk_cnt=1)
        SET dah_text = concat("Remaining Partitions to Add: ",trim(cnvtstring(rd_pp_sizes->qual[
           dah_disk_cnt].rd_size)),"MB: ",trim(cnvtstring(ap_pp_return))," PPs     ")
       ELSE
        SET dah_text = concat(dah_text,"  ",trim(cnvtstring(rd_pp_sizes->qual[dah_disk_cnt].rd_size)),
         "MB: ",trim(cnvtstring(ap_pp_return)),
         " PPs   ")
       ENDIF
     ENDFOR
    ENDIF
    CALL clear(7,2,130)
    CALL text(7,3,dah_text)
    CALL ts_inform(dah_text)
   ENDIF
 END ;Subroutine
 SUBROUTINE ap_display_pp_totals(adpt_size_in,adpt_pp_size,adpt_max_cont_size,adpt_tspace_type)
   DECLARE adpt_space_tot = f8 WITH protect, noconstant(0.0)
   DECLARE adpt_max_size_bytes = f8 WITH protect, noconstant(0.0)
   DECLARE adpt_size_mb = f8 WITH protect, noconstant(0.0)
   DECLARE adpt_cnt = i4 WITH protect, noconstant(0)
   DECLARE adpt_pp_total = f8 WITH protect, noconstant(0.0)
   FREE RECORD adpt_hold
   RECORD adpt_hold(
     1 qual[*]
       2 adpt_mb_need = f8
   )
   CASE (adpt_tspace_type)
    OF "LOB":
     SET adpt_find = "L_"
    OF "DATA":
     SET adpt_find = "D_"
    OF "INDEX":
     SET adpt_find = "I_"
   ENDCASE
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(rtspace->qual,5))
    WHERE (rtspace->qual[d.seq].ct_err_ind=1)
    ORDER BY rtspace->qual[d.seq].bytes_needed DESC
    DETAIL
     IF (substring(1,2,rtspace->qual[d.seq].tspace_name)=adpt_find)
      adpt_cnt = (adpt_cnt+ 1), stat = alterlist(adpt_hold->qual,adpt_cnt), adpt_hold->qual[adpt_cnt]
      .adpt_mb_need = convert_bytes(rtspace->qual[d.seq].bytes_needed,"b","m")
     ENDIF
    WITH nocounter
   ;end select
   SET adpt_cnt = 0
   FOR (adpt_cnt = 1 TO size(adpt_hold->qual,5))
    WHILE ((adpt_hold->qual[adpt_cnt].adpt_mb_need > 0))
      IF ((adpt_hold->qual[adpt_cnt].adpt_mb_need < adpt_max_cont_size))
       SET adpt_pp_total = (adpt_pp_total+ calc_disk_pp_num(get_space_rounded(adpt_hold->qual[
         adpt_cnt].adpt_mb_need,adpt_pp_size),adpt_pp_size))
       SET adpt_hold->qual[adpt_cnt].adpt_mb_need = 0
      ELSE
       SET adpt_pp_total = (adpt_pp_total+ calc_disk_pp_num(get_space_rounded(adpt_max_cont_size,
         adpt_pp_size),adpt_pp_size))
       SET adpt_hold->qual[adpt_cnt].adpt_mb_need = (adpt_hold->qual[adpt_cnt].adpt_mb_need -
       get_space_rounded(adpt_max_cont_size,adpt_pp_size))
      ENDIF
    ENDWHILE
    IF ((dm_err->debug_flag > 0))
     CALL ts_inform(concat("For",cnvtstring(adpt_hold->qual[adpt_cnt].adpt_mb_need)))
     CALL ts_inform(cnvtstring(adpt_pp_total))
     CALL ts_inform(cnvtstring(adpt_hold->qual[adpt_cnt].adpt_mb_need))
    ENDIF
   ENDFOR
   RETURN(adpt_pp_total)
 END ;Subroutine
 SUBROUTINE autopop_work_menu(awm_type_in)
   CALL ts_inform("in autopop_work_menu")
   DECLARE autopop_stay_here = i2
   CALL clear(1,1)
   SET autopop_screen->cur_line = size(autopop_screen->disk,5)
   CALL clear(1,1)
   WHILE (autopop_stay_here=0)
     SET autopop_screen->cur_line = size(autopop_screen->disk,5)
     CALL display_autopop_header(awm_type_in)
     IF (size(autopop_screen->disk,5) > 0)
      SET autopop_screen->disk_cnt = size(autopop_screen->disk,5)
      SET autopop_screen->max_value = autopop_screen->disk_cnt
      IF ((size(autopop_screen->disk,5) > autopop_screen->max_scroll))
       IF (((autopop_screen->top_line+ (autopop_screen->max_scroll - 1)) <= autopop_screen->max_value
       ))
        SET autopop_screen->bottom_line = (autopop_screen->top_line+ (autopop_screen->max_scroll - 1)
        )
       ELSE
        SET autopop_screen->bottom_line = autopop_screen->max_value
       ENDIF
      ELSE
       SET autopop_screen->bottom_line = size(autopop_screen->disk,5)
      ENDIF
      CALL fill_autopop_screen(1)
     ENDIF
     CASE (scroll("autopop_screen"))
      OF "A":
       SET ts_destination = "AUTOPOP_ADD_MENU"
      OF "Q":
       SET ts_destination = "AUTOPOP_QUIT"
      OF "C":
       SET ts_destination = "AUTOPOP_SAVE"
      OF "R":
       SET ts_destination = "AUTOPOP_DELETE_MENU"
      OF "P":
       SET ts_destination = "POPULATE_AUTO"
     ENDCASE
     CASE (ts_destination)
      OF "AUTOPOP_ADD_MENU":
       SET autopop_screen_return = autopop_add_menu(awm_type_in)
      OF "AUTOPOP_QUIT":
       SET autopop_screen_return = autopop_cancel(null)
       SET autopop_stay_here = 1
       SET ap_max_cont_size = 0.0
      OF "AUTOPOP_SAVE":
       SET autopop_screen_return = save_autopop_to_rdisk(awm_type_in)
       IF (autopop_screen_return="SUCCESS")
        SET autopop_screen_return = save_autopop_to_rtspace(null)
       ENDIF
       IF (autopop_screen_return="ERROR")
        CALL ts_inform("AN ERROR OCCURRED in return from AUTOPOP_SCREEN")
       ENDIF
       SET autopop_stay_here = 1
      OF "AUTOPOP_DELETE_MENU":
       CALL ap_disk_delete(autopop_screen->cur_line)
       IF (tdisk_cnt > 0)
        SET tdisk_cnt = (tdisk_cnt - 1)
       ELSE
        SET tdisk_cnt = 0
       ENDIF
       IF ((autopop_screen->cur_line > 0))
        SET autopop_screen->cur_line = (autopop_screen->cur_line - 1)
       ELSE
        SET autopop_screen->cur_line = 0
       ENDIF
      OF "POPULATE_AUTO":
       CALL autopop_reset(null)
       SET autopop_ready_ind = 1
       SET autopop_screen_return = autopop_spread_files(ap_max_cont_size,awm_type_in)
       IF (autopop_screen_return="NO_DISK_SPACE")
        CALL autopop_reset(null)
        IF (size(autopop_screen->disk,5) > 0)
         CALL fill_autopop_screen(1)
        ENDIF
        CALL display_warning("NO DISK SPACE",awm_type_in)
        SET autopop_ready_ind = 0
       ENDIF
     ENDCASE
   ENDWHILE
   IF (autopop_screen_return="DONE_CANCEL")
    SET ts_destination = "QUIT"
   ENDIF
   RETURN(ts_destination)
 END ;Subroutine
 SUBROUTINE autopop_reset(null)
   DECLARE apr_rd_size = i4 WITH protect, noconstant(0)
   DECLARE apr_as_cnt = i4 WITH protect, noconstant(0)
   DECLARE apr_rd_ndx = i4 WITH protect, noconstant(0)
   DECLARE apr_rd_find = i4 WITH protect, noconstant(0)
   SET apr_rd_size = size(rdisk->qual,5)
   SET stat = alterlist(ap_spread_rs->ap_tspace,0)
   FOR (apr_as_cnt = 1 TO size(autopop_screen->disk,5))
    SET apr_rd_ndx = locateval(apr_rd_find,1,apr_rd_size,autopop_screen->disk[apr_as_cnt].disk_name,
     rdisk->qual[apr_rd_find].disk_name)
    SET autopop_screen->disk[apr_as_cnt].free_disk_space_mb = rdisk->qual[apr_rd_ndx].
    new_free_space_mb
   ENDFOR
   IF (check_error(concat("autopop_reset")) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE save_autopop_to_rdisk(sar_ts_type)
   DECLARE ap_rd_size = i4 WITH protect, noconstant(0)
   DECLARE ap_as_cnt = i4 WITH protect, noconstant(0)
   DECLARE ap_rd_ndx = i4 WITH protect, noconstant(0)
   DECLARE ap_rd_find = i4 WITH protect, noconstant(0)
   SET ap_rd_size = size(rdisk->qual,5)
   FOR (ap_as_cnt = 1 TO size(autopop_screen->disk,5))
     SET ap_rd_ndx = locateval(ap_rd_find,1,ap_rd_size,autopop_screen->disk[ap_as_cnt].disk_name,
      rdisk->qual[ap_rd_find].disk_name)
     SET rdisk->qual[ap_rd_ndx].new_free_space_mb = autopop_screen->disk[ap_as_cnt].
     free_disk_space_mb
     SET rdisk->qual[ap_rd_ndx].used_ind = ""
   ENDFOR
   IF (check_error(concat("save_autopop_to_rdisk")) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("ERROR")
   ELSE
    RETURN("SUCCESS")
   ENDIF
 END ;Subroutine
 SUBROUTINE save_autopop_to_rtspace(null)
   DECLARE scr_rt_size = i4 WITH protect, noconstant(0)
   DECLARE ap_rt_cnt = i4 WITH protect, noconstant(0)
   DECLARE ap_ct_cnt = i4 WITH protect, noconstant(0)
   DECLARE ap_tspace_ndx = i4 WITH protect, noconstant(0)
   DECLARE ap_tspace_find = i4 WITH protect, noconstant(0)
   DECLARE ap_tsp_ct_cnt = i4 WITH protect, noconstant(0)
   IF ((dm_err->debug_flag >= 1))
    CALL ts_inform(concat("AP_SPREAD_RS",cnvtstring(curdate)))
    CALL echorecord(ap_spread_rs,concat("AP_SPREAD_RS",cnvtstring(curdate)))
   ENDIF
   FOR (ap_rt_cnt = 1 TO size(ap_spread_rs->ap_tspace,5))
     SET ap_tspace_ndx = locateval(ap_tspace_find,1,size(rtspace->qual,5),ap_spread_rs->ap_tspace[
      ap_rt_cnt].ap_tspace_name,rtspace->qual[ap_tspace_find].tspace_name)
     SET rtspace->qual[ap_tspace_ndx].cont_complete_ind = 1
     IF ((dir_storage_misc->tgt_storage_type="ASM"))
      SET rtspace->qual[ap_tspace_ndx].asm_disk_group = ap_spread_rs->ap_tspace[ap_rt_cnt].
      ap_asm_disk_group
     ENDIF
     SET ap_tsp_ct_cnt = size(rtspace->qual[ap_tspace_ndx].cont,5)
     FOR (ap_ct_cnt = 1 TO size(ap_spread_rs->ap_tspace[ap_rt_cnt].ap_cont,5))
       SET ap_tsp_ct_cnt = (ap_tsp_ct_cnt+ 1)
       SET stat = alterlist(rtspace->qual[ap_tspace_ndx].cont,(size(rtspace->qual[ap_tspace_ndx].cont,
         5)+ 1))
       SET rtspace->qual[ap_tspace_ndx].cont[ap_tsp_ct_cnt].add_ext_ind = "a"
       SET rtspace->qual[ap_tspace_ndx].cont[ap_tsp_ct_cnt].volume_label = ap_spread_rs->ap_tspace[
       ap_rt_cnt].ap_cont[ap_ct_cnt].ap_volume_label
       SET rtspace->qual[ap_tspace_ndx].cont[ap_tsp_ct_cnt].cont_tspace_rel_key = ap_spread_rs->
       ap_tspace[ap_rt_cnt].ap_cont[ap_ct_cnt].ap_cont_tspace_rel_key
       SET rtspace->qual[ap_tspace_ndx].cont[ap_tsp_ct_cnt].disk_name = ap_spread_rs->ap_tspace[
       ap_rt_cnt].ap_cont[ap_ct_cnt].ap_disk_name
       IF ((dm2_sys_misc->cur_db_os IN ("HPX", "AIX"))
        AND (dir_storage_misc->tgt_storage_type="RAW"))
        SET rtspace->qual[ap_tspace_ndx].cont[ap_tsp_ct_cnt].vg_name = ap_spread_rs->ap_tspace[
        ap_rt_cnt].ap_cont[ap_ct_cnt].ap_vg_name
        SET rtspace->qual[ap_tspace_ndx].cont[ap_tsp_ct_cnt].pp_size_mb = ap_spread_rs->ap_tspace[
        ap_rt_cnt].ap_cont[ap_ct_cnt].pp_size_mb
        SET rtspace->qual[ap_tspace_ndx].cont[ap_tsp_ct_cnt].pps_to_add = calc_disk_pp_num(
         ap_spread_rs->ap_tspace[ap_rt_cnt].ap_cont[ap_ct_cnt].ap_space_to_add_mb,ap_spread_rs->
         ap_tspace[ap_rt_cnt].ap_cont[ap_ct_cnt].pp_size_mb)
       ENDIF
       SET rtspace->qual[ap_tspace_ndx].cont[ap_tsp_ct_cnt].space_to_add = convert_bytes(ap_spread_rs
        ->ap_tspace[ap_rt_cnt].ap_cont[ap_ct_cnt].ap_space_to_add_mb,"m","b")
       SET rtspace->qual[ap_tspace_ndx].cont[ap_tsp_ct_cnt].cont_size_mb = ap_spread_rs->ap_tspace[
       ap_rt_cnt].ap_cont[ap_ct_cnt].ap_space_to_add_mb
       SET rtspace->qual[ap_tspace_ndx].cont[ap_tsp_ct_cnt].lv_file = ap_spread_rs->ap_tspace[
       ap_rt_cnt].ap_cont[ap_ct_cnt].ap_lv_filename
       SET rtspace->qual[ap_tspace_ndx].cont[ap_tsp_ct_cnt].new_ind = 1
     ENDFOR
   ENDFOR
   SET stat = alterlist(ap_spread_rs->ap_tspace,0)
   IF (check_error(concat("save_autopop_to_rtspace")) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("ERROR")
   ELSE
    RETURN("SUCCESS")
   ENDIF
 END ;Subroutine
 SUBROUTINE get_total_space_add(gtsa_tspace_type)
   CALL ts_inform("in get_total_space_add")
   DECLARE gtsa_cnt = i4 WITH protect, noconstant(0)
   DECLARE gtsa_space_total = f8 WITH protect, noconstant(0.0)
   DECLARE gtsa_find = vc WITH protect, noconstant("")
   DECLARE gtsa_start_pt = i2 WITH protect, noconstant(0)
   DECLARE gtsa_cut_len = i2 WITH protect, noconstant(0)
   CASE (gtsa_tspace_type)
    OF "LOB":
     SET gtsa_find = "L_"
    OF "DATA":
     SET gtsa_find = "D_"
    OF "INDEX":
     SET gtsa_find = "I_"
    ELSE
     SET gtsa_find = "_"
   ENDCASE
   IF (gtsa_find="_")
    SET gtsa_start_pt = 2
    SET gtsa_cut_len = 1
   ELSE
    SET gtsa_start_pt = 1
    SET gtsa_cut_len = 2
   ENDIF
   SET gtsa_cnt = 0
   SET gtsa_space_total = 0.0
   FOR (gtsa_cnt = 1 TO size(rtspace->qual,5))
     IF ((rtspace->qual[gtsa_cnt].ct_err_ind=1))
      IF (((substring(gtsa_start_pt,gtsa_cut_len,rtspace->qual[gtsa_cnt].tspace_name)=gtsa_find) OR (
      (rtspace->qual[gtsa_cnt].user_tspace_ind=1))) )
       IF ((rtspace->qual[gtsa_cnt].cont_complete_ind=0))
        SET gtsa_space_total = (gtsa_space_total+ convert_bytes(rtspace->qual[gtsa_cnt].bytes_needed,
         "b","m"))
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   RETURN(gtsa_space_total)
 END ;Subroutine
 SUBROUTINE fill_ncont_screen(s_mode)
   CALL ts_inform("in fill_ncont_screen")
   DECLARE sns_upto_value = i4 WITH protect, noconstant(0)
   DECLARE space_to_add_mb = f8 WITH protect, noconstant(0.0)
   SET space_to_add_mb = 0.0
   IF (size(ncont_screen->cont,5) > 0)
    CALL box(1,1,22,132)
    SET display_line = 12
    IF (s_mode=1)
     SET sns_upto_value = ncont_screen->bottom_line
    ELSE
     SET sns_upto_value = tcont_cnt
    ENDIF
    FOR (display_loop = ncont_screen->top_line TO sns_upto_value)
      IF ((display_loop=ncont_screen->cur_line))
       CALL video(r)
       SET row_nbr = display_line
      ELSE
       CALL video(n)
      ENDIF
      CALL clear(display_line,02,130)
      CALL text(display_line,5,ncont_screen->cont[display_loop].add_ext_ind)
      CALL text(display_line,20,cnvtstring(display_loop))
      CALL text(display_line,28,format(cnvtstring(ncont_screen->cont[display_loop].cont_size_mb),
        "##########;R"))
      IF ((dm2_sys_misc->cur_db_os="AXP"))
       CALL text(display_line,50,trim(ncont_screen->cont[display_loop].volume_label))
      ENDIF
      IF ((dm2_sys_misc->cur_db_os IN ("HPX", "AIX"))
       AND (dir_storage_misc->tgt_storage_type="RAW"))
       CALL text(display_line,50,trim(ncont_screen->cont[display_loop].disk_name))
       CALL text(display_line,38,format(cnvtstring(ncont_screen->cont[display_loop].pp_size_mb),
         "##########;R"))
       CALL text(display_line,68,format(cnvtstring(ncont_screen->cont[display_loop].pps_to_add),
         "####;R"))
      ENDIF
      SET space_to_add_mb = convert_bytes(ncont_screen->cont[display_loop].space_to_add,"b","m")
      CALL text(display_line,78,format(cnvtstring(space_to_add_mb),"##########;R"))
      CALL text(display_line,91,trim(ncont_screen->cont[display_loop].lv_filename))
      CALL video(n)
      SET display_line = (display_line+ 1)
    ENDFOR
    IF (display_line < 22)
     CALL video(n)
     FOR (display_blank = display_line TO 22)
       CALL clear(display_blank,2,130)
     ENDFOR
    ENDIF
    CALL display_container_footer(null)
    CALL video(n)
    CALL box(1,1,22,132)
   ENDIF
 END ;Subroutine
 SUBROUTINE fill_autopop_screen(fas_mode_in)
   CALL ts_inform("in fill_autopop_screen")
   DECLARE sas_to_value = i4 WITH protect, noconstant(0)
   DECLARE sas_pp_num = f8 WITH protect, noconstant(0.0)
   IF (fas_mode_in=0)
    SET sas_to_value = tdisk_cnt
   ELSE
    SET sas_to_value = autopop_screen->bottom_line
   ENDIF
   IF (size(autopop_screen->disk,5) > 0)
    CALL box(3,1,22,132)
    SET display_line = 12
    FOR (display_loop = autopop_screen->top_line TO sas_to_value)
      IF ((display_loop=autopop_screen->cur_line))
       CALL video(r)
       SET row_nbr = display_line
      ELSE
       CALL video(n)
      ENDIF
      CALL clear(display_line,02,130)
      CALL text(display_line,17,cnvtstring(display_loop))
      CALL text(display_line,20,trim(autopop_screen->disk[display_loop].disk_name))
      IF ((dir_storage_misc->tgt_storage_type="ASM"))
       CALL text(display_line,98,format(cnvtstring(autopop_screen->disk[display_loop].
          free_disk_space_mb),"##########;R"))
       CALL text(display_line,82,format(cnvtstring(rdisk->qual[autopop_screen->disk[display_loop].
          disk_idx].total_space_mb),"##########;R"))
      ELSEIF ((dm2_sys_misc->cur_db_os="AXP"))
       CALL text(display_line,78,format(cnvtstring(autopop_screen->disk[display_loop].
          free_disk_space_mb),"##########;R"))
       CALL text(display_line,41,trim(autopop_screen->disk[display_loop].volume_label))
      ELSEIF ((dm2_sys_misc->cur_db_os IN ("HPX", "AIX")))
       SET sas_pp_num = calc_disk_pp_num(autopop_screen->disk[display_loop].free_disk_space_mb,
        autopop_screen->disk[display_loop].pp_size_mb)
       CALL text(display_line,78,format(cnvtstring(sas_pp_num),"##########;R"))
       IF ((dm2_sys_misc->cur_db_os="AIX"))
        CALL text(display_line,41,trim(autopop_screen->disk[display_loop].vg_name))
       ENDIF
      ENDIF
      CALL video(n)
      SET display_line = (display_line+ 1)
    ENDFOR
    IF (display_line < 22)
     CALL video(n)
     FOR (display_blank = display_line TO 22)
       CALL clear(display_blank,2,130)
     ENDFOR
    ENDIF
    CALL display_autopop_footer(null)
    CALL video(n)
    CALL box(3,1,22,132)
   ENDIF
 END ;Subroutine
 SUBROUTINE display_autopop_footer(null)
  CALL ts_inform("in display_autopop_footer")
  IF ((autopop_screen->disk_cnt > autopop_screen->max_scroll))
   IF ((autopop_screen->disk_cnt > autopop_screen->bottom_line)
    AND (autopop_screen->top_line=1))
    CALL clear(23,65,67)
    CALL text(23,65,"More disks available, use <PgDown> key to scroll list")
   ELSEIF ((autopop_screen->disk_cnt > autopop_screen->bottom_line))
    CALL clear(23,65,67)
    CALL text(23,65,"More disks available, use <PgUp>/<PgDown> keys to scroll list")
   ELSE
    CALL clear(23,65,67)
    CALL text(23,65,"Bottom of list, use <PgUp> key to scroll list")
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE display_container_footer(null)
  CALL ts_inform("in display_container_footer")
  IF ((ncont_screen->cont_cnt > ncont_screen->max_scroll))
   IF ((ncont_screen->cont_cnt > ncont_screen->bottom_line)
    AND (ncont_screen->top_line=1))
    CALL clear(23,65,67)
    CALL text(23,65,concat("More ",storage_device,"s available, use <PgDown> key to scroll list"))
   ELSEIF ((ncont_screen->cont_cnt > ncont_screen->bottom_line))
    CALL clear(23,65,67)
    CALL text(23,65,concat("More ",storage_device,
      "s available, use <PgUp>/<PgDown> keys to scroll list"))
   ELSE
    CALL clear(23,65,67)
    CALL text(23,65,"Bottom of list, use <PgUp> key to scroll list")
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE get_new_lv_filename(lv_tspace_in,lv_mode,lv_custom_in)
   CALL ts_inform("in get_new_lv_filename")
   DECLARE lv_new_name = vc WITH protect, noconstant("")
   DECLARE found_lv_name = i2 WITH protect, noconstant(0)
   DECLARE lv_seq_num = i2 WITH protect, noconstant(0)
   DECLARE find_ndx = i4 WITH protect, noconstant(0)
   DECLARE hd_upto_seq = i4 WITH protect, noconstant(0)
   DECLARE df_cont_cnt = i4 WITH protect, noconstant(0)
   IF ((dm_err->debug_flag=722))
    SET message = nowindow
   ENDIF
   IF (check_error(concat("getting ",storage_device," name")) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL ts_inform(concat("last_seq:",cnvtstring(hd_last_seq)))
   ENDIF
   SET hd_upto_seq = 0
   IF ((dm2_sys_misc->cur_db_os IN ("HPX", "AIX"))
    AND (dir_storage_misc->tgt_storage_type="RAW"))
    SET hd_upto_seq = 9999999
   ELSEIF ((dm2_sys_misc->cur_db_os="AXP"))
    SET hd_upto_seq = 999
   ENDIF
   SET dm_err->eproc = "Looking for datafile"
   SET dm_err->user_action =
   "This is an acceptable error message that can be ignored. No action needed."
   WHILE (found_lv_name=0)
    IF (lv_mode=1)
     IF ((dm2_sys_misc->cur_db_os IN ("HPX", "AIX"))
      AND (dir_storage_misc->tgt_storage_type="RAW"))
      CASE (cnvtlower(substring(1,1,lv_tspace_in)))
       OF "d":
        SET lv_seq_num = dfile_seq->d_seq
       OF "i":
        SET lv_seq_num = dfile_seq->i_seq
       OF "l":
        SET lv_seq_num = dfile_seq->l_seq
      ENDCASE
     ENDIF
     SET lv_seq_num = (lv_seq_num+ 1)
     IF ((dm2_sys_misc->cur_db_os IN ("HPX", "AIX"))
      AND (dir_storage_misc->tgt_storage_type="RAW"))
      SET hd_last_seq = lv_seq_num
      CASE (cnvtlower(substring(1,1,lv_tspace_in)))
       OF "d":
        SET dfile_seq->d_seq = hd_last_seq
       OF "i":
        SET dfile_seq->i_seq = hd_last_seq
       OF "l":
        SET dfile_seq->l_seq = hd_last_seq
      ENDCASE
     ENDIF
     IF ((dm_err->debug_flag > 0))
      CALL echorecord(dfile_seq)
     ENDIF
     IF (lv_seq_num < hd_upto_seq)
      IF ((dm2_sys_misc->cur_db_os IN ("HPX", "AIX"))
       AND (dir_storage_misc->tgt_storage_type="RAW"))
       SET lv_new_name = build(cnvtlower(substring(1,1,lv_tspace_in)),cnvtlower(rtspace->dbname),"_",
        format(lv_seq_num,"#######;P0"))
      ELSEIF ((dm2_sys_misc->cur_db_os="AXP"))
       SET lv_new_name = build(lv_tspace_in,"_",format(lv_seq_num,"###;P0"))
      ENDIF
      SET find_ndx = 0
      IF (size(hold_datafile->ts,5) > 0)
       FOR (df_cont_cnt = 1 TO size(hold_datafile->ts,5))
         IF (locateval(find_ndx,1,size(hold_datafile->ts[df_cont_cnt].df,5),lv_new_name,hold_datafile
          ->ts[df_cont_cnt].df[find_ndx].df_name) > 0)
          SET found_lv_name = 1
         ENDIF
       ENDFOR
      ENDIF
      SET find_ndx = 0
      IF (found_lv_name=0)
       IF (size(ncont_screen->cont,5) > 0)
        IF (locateval(find_ndx,1,size(ncont_screen->cont,5),lv_new_name,ncont_screen->cont[find_ndx].
         lv_filename) > 0)
         SET found_lv_name = 1
        ENDIF
       ENDIF
      ENDIF
      SET find_ndx = 0
      IF (found_lv_name=0)
       IF (size(ap_spread_rs->ap_tspace,5) > 0)
        FOR (df_cont_cnt = 1 TO size(ap_spread_rs->ap_tspace,5))
          IF (locateval(find_ndx,1,size(ap_spread_rs->ap_tspace[df_cont_cnt].ap_cont,5),lv_new_name,
           ap_spread_rs->ap_tspace[df_cont_cnt].ap_cont[find_ndx].ap_lv_filename) > 0)
           SET found_lv_name = 1
          ENDIF
        ENDFOR
       ENDIF
      ENDIF
      SET find_ndx = 0
      IF (found_lv_name=0)
       IF (size(rtspace->qual,5) > 0)
        FOR (df_cont_cnt = 1 TO size(rtspace->qual,5))
          IF (locateval(find_ndx,1,size(rtspace->qual[df_cont_cnt].cont,5),lv_new_name,rtspace->qual[
           df_cont_cnt].cont[find_ndx].lv_file) > 0)
           SET found_lv_name = 1
          ENDIF
        ENDFOR
       ENDIF
      ENDIF
      SET find_ndx = 0
      IF (found_lv_name=0)
       IF ((rtspace->database_remote=0))
        IF ((dm2_sys_misc->cur_db_os IN ("HPX", "AXP")))
         FOR (gnlf_cnt = 1 TO size(rdisk->qual,5))
           IF ((dm2_sys_misc->cur_db_os="AXP"))
            IF ((rdisk->qual[gnlf_cnt].datafile_dir_exists=1))
             IF (findfile(concat(rdisk->qual[gnlf_cnt].volume_label,":",ts_datafile_dir,lv_new_name,
               ".dbs")) > 0)
              SET found_lv_name = 1
              SET gnlf_cnt = size(rdisk->qual,5)
             ELSEIF ((dm_err->err_ind=1))
              GO TO exit_program
             ENDIF
            ENDIF
           ELSE
            IF ((dir_storage_misc->tgt_storage_type="RAW"))
             IF (findfile(concat(rdisk->qual[gnlf_cnt].vg_name,"/r",lv_new_name)) > 0)
              SET found_lv_name = 1
              SET gnlf_cnt = size(rdisk->qual,5)
             ELSEIF ((dm_err->err_ind=1))
              GO TO exit_program
             ENDIF
            ENDIF
           ENDIF
         ENDFOR
        ELSE
         IF (findfile(concat(ts_datafile_dir,lv_new_name)) > 0)
          SET found_lv_name = 1
         ELSEIF ((dm_err->err_ind=1))
          GO TO exit_program
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ELSE
      SET found_lv_name = 2
      SET lv_new_name = "NO NAME"
      RETURN(lv_new_name)
     ENDIF
    ELSE
     IF (size(hold_datafile->ts,5) > 0)
      FOR (df_cont_cnt = 1 TO size(hold_datafile->ts,5))
        IF (locateval(find_ndx,1,size(hold_datafile->ts[df_cont_cnt].df,5),lv_custom_in,hold_datafile
         ->ts[df_cont_cnt].df[find_ndx].df_name) > 0)
         SET found_lv_name = 3
         SET lv_custom_in = "NAME EXISTS"
         RETURN(lv_custom_in)
        ENDIF
      ENDFOR
     ENDIF
     SET find_ndx = 0
     IF (found_lv_name=0)
      SET dm_err->eproc = "Looking for datafile"
      SET dm_err->user_action =
      "This is an acceptable error message that can be ignored. No action needed."
      IF ((dm2_sys_misc->cur_db_os IN ("AXP", "HPX"))
       AND (rtspace->database_remote=0))
       FOR (gnlf_cnt = 1 TO size(rdisk->qual,5))
         IF ((dm2_sys_misc->cur_db_os="AXP"))
          IF ((rdisk->qual[gnlf_cnt].datafile_dir_exists=1))
           IF (findfile(concat(rdisk->qual[gnlf_cnt].volume_label,":",ts_datafile_dir,lv_custom_in,
             ".dbs")) > 0)
            SET found_lv_name = 3
            SET lv_custom_in = "NAME EXISTS"
            RETURN(lv_custom_in)
           ELSEIF ((dm_err->err_ind=1))
            GO TO exit_program
           ENDIF
          ENDIF
         ELSE
          IF ((dir_storage_misc->tgt_storage_type="RAW"))
           IF (findfile(concat(rdisk->qual[gnlf_cnt].vg_name,"/r",lv_custom_in)) > 0)
            SET found_lv_name = 3
            SET lv_custom_in = "NAME EXISTS"
            RETURN(lv_custom_in)
           ELSEIF ((dm_err->err_ind=1))
            GO TO exit_program
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
      ELSE
       IF (findfile(trim(concat(trim(ts_datafile_dir),trim(lv_custom_in)))) > 0)
        SET found_lv_name = 3
        SET lv_custom_in = "NAME EXISTS"
        RETURN(lv_custom_in)
       ELSEIF ((dm_err->err_ind=1))
        GO TO exit_program
       ENDIF
      ENDIF
     ENDIF
     IF (found_lv_name=0)
      IF (size(rtspace->qual,5) > 0)
       FOR (df_cont_cnt = 1 TO size(rtspace->qual,5))
         IF (locateval(find_ndx,1,size(rtspace->qual[df_cont_cnt].cont,5),lv_custom_in,rtspace->qual[
          df_cont_cnt].cont[find_ndx].lv_file) > 0)
          SET found_lv_name = 3
          SET lv_custom_in = "NAME EXISTS"
          RETURN(lv_custom_in)
         ENDIF
       ENDFOR
      ENDIF
     ENDIF
     IF (found_lv_name=0)
      IF (locateval(find_ndx,1,size(ncont_screen->cont,5),lv_custom_in,ncont_screen->cont[find_ndx].
       lv_filename) > 0)
       SET found_lv_name = 3
       SET lv_custom_in = "NAME EXISTS"
       RETURN(lv_custom_in)
      ELSE
       SET found_lv_name = 0
      ENDIF
     ENDIF
    ENDIF
    IF (found_lv_name=0)
     SET found_lv_name = 1
    ELSE
     SET found_lv_name = 0
    ENDIF
   ENDWHILE
   RETURN(lv_new_name)
 END ;Subroutine
 SUBROUTINE container_disk_help(cdh_mode_in)
   CALL ts_inform("in container_disk_help")
   DECLARE cdh_ret_ndx = i4 WITH protect, noconstant(0)
   DECLARE cdh_return = i4 WITH protect, noconstant(0)
   SET help = pos(12,20,10,100)
   IF (cdh_mode_in=1)
    IF ((dir_storage_misc->tgt_storage_type="ASM"))
     SET help =
     SELECT INTO "nl:"
      disk_group___________________ = trim(rdisk->qual[d.seq].disk_name), __block_size = trim(
       cnvtstring(rdisk->qual[d.seq].block_size_b)), allocation_unit = trim(cnvtstring(rdisk->qual[d
        .seq].alloc_unit_b)),
      total_space_mb = trim(cnvtstring(rdisk->qual[d.seq].total_space_mb)), free_space_mb = trim(
       cnvtstring(rdisk->qual[d.seq].new_free_space_mb))
      FROM (dummyt d  WITH seq = value(size(rdisk->qual,5)))
      WHERE d.seq > 0
      WITH nocounter
     ;end select
     CALL accept(row_nbr,80,"P(9);cuF")
    ELSEIF ((dm2_sys_misc->cur_db_os="AIX"))
     SET help =
     SELECT INTO "nl:"
      disk_name_____ = trim(rdisk->qual[d.seq].disk_name), free_space_mb____ = trim(cnvtstring(rdisk
        ->qual[d.seq].new_free_space_mb)), volume_group_____ = trim(rdisk->qual[d.seq].vg_name),
      pps_remaining___ = trim(cnvtstring((rdisk->qual[d.seq].new_free_space_mb/ rdisk->qual[d.seq].
        pp_size_mb))), pp_size___ = trim(cnvtstring(rdisk->qual[d.seq].pp_size_mb))
      FROM (dummyt d  WITH seq = value(size(rdisk->qual,5)))
      WHERE d.seq > 0
      WITH nocounter
     ;end select
     CALL accept(display_line,50,"P(9);cuF")
    ELSEIF ((dm2_sys_misc->cur_db_os="AXP"))
     SET help =
     SELECT INTO "nl:"
      volume_label___ = trim(rdisk->qual[d.seq].volume_label), disk_name______ = trim(rdisk->qual[d
       .seq].disk_name), _____free_space_mb = rdisk->qual[d.seq].new_free_space_mb,
      device_name_____ = trim(rdisk->qual[d.seq].volume_label), _____total_space = rdisk->qual[d.seq]
      .total_space_mb
      FROM (dummyt d  WITH seq = value(size(rdisk->qual,5)))
      WHERE d.seq > 0
      WITH nocounter
     ;end select
     CALL accept(display_line,50,"P(15);cuF")
    ELSEIF ((dm2_sys_misc->cur_db_os="HPX"))
     SET help =
     SELECT INTO "nl:"
      volume_group________ = trim(rdisk->qual[d.seq].vg_name), free_space_mb____ = trim(cnvtstring(
        rdisk->qual[d.seq].new_free_space_mb)), pps_remaining___ = trim(cnvtstring((rdisk->qual[d.seq
        ].new_free_space_mb/ rdisk->qual[d.seq].pp_size_mb))),
      pp_size___ = trim(cnvtstring(rdisk->qual[d.seq].pp_size_mb))
      FROM (dummyt d  WITH seq = value(size(rdisk->qual,5)))
      WHERE d.seq > 0
      WITH nocounter
     ;end select
     CALL accept(display_line,50,"P(20);cuF")
    ENDIF
   ELSEIF (cdh_mode_in=2)
    IF ((dir_storage_misc->tgt_storage_type="ASM"))
     SET help =
     SELECT INTO "nl:"
      disk_group___________________ = trim(rdisk->qual[d.seq].disk_name), used__ = trim(rdisk->qual[d
       .seq].used_ind), __block_size = trim(cnvtstring(rdisk->qual[d.seq].block_size_b)),
      allocation_unit = trim(cnvtstring(rdisk->qual[d.seq].alloc_unit_b)), total_space_mb = trim(
       cnvtstring(rdisk->qual[d.seq].total_space_mb)), free_space_mb = trim(cnvtstring(rdisk->qual[d
        .seq].new_free_space_mb))
      FROM (dummyt d  WITH seq = value(size(rdisk->qual,5)))
      WHERE d.seq > 0
      WITH nocounter
     ;end select
     CALL accept(display_line,50,"P(9);cuF")
    ELSEIF ((dm2_sys_misc->cur_db_os="AIX"))
     SET help =
     SELECT INTO "nl:"
      disk_name_____ = trim(rdisk->qual[d.seq].disk_name), used__ = trim(rdisk->qual[d.seq].used_ind),
      free_space_mb____ = trim(cnvtstring(rdisk->qual[d.seq].new_free_space_mb)),
      volume_group_____ = trim(rdisk->qual[d.seq].vg_name), pps_remaining___ = trim(cnvtstring((rdisk
        ->qual[d.seq].new_free_space_mb/ rdisk->qual[d.seq].pp_size_mb))), pp_size___ = trim(
       cnvtstring(rdisk->qual[d.seq].pp_size_mb))
      FROM (dummyt d  WITH seq = value(size(rdisk->qual,5)))
      WHERE d.seq > 0
      WITH nocounter
     ;end select
     CALL accept(display_line,20,"P(9);cuF")
    ELSEIF ((dm2_sys_misc->cur_db_os="AXP"))
     SET help =
     SELECT INTO "nl:"
      volume_label___ = trim(rdisk->qual[d.seq].volume_label), disk_name______ = trim(rdisk->qual[d
       .seq].disk_name), used__ = trim(rdisk->qual[d.seq].used_ind),
      _____free_space_mb = rdisk->qual[d.seq].new_free_space_mb, _____total_space = rdisk->qual[d.seq
      ].total_space_mb
      FROM (dummyt d  WITH seq = value(size(rdisk->qual,5)))
      WHERE d.seq > 0
      WITH nocounter
     ;end select
     CALL accept(display_line,20,"P(15);cuF")
    ELSEIF ((dm2_sys_misc->cur_db_os="HPX"))
     SET help =
     SELECT INTO "nl:"
      volume_group________ = trim(rdisk->qual[d.seq].vg_name), used__ = trim(rdisk->qual[d.seq].
       used_ind), free_space_mb____ = trim(cnvtstring(rdisk->qual[d.seq].new_free_space_mb)),
      pps_remaining___ = trim(cnvtstring((rdisk->qual[d.seq].new_free_space_mb/ rdisk->qual[d.seq].
        pp_size_mb))), pp_size___ = trim(cnvtstring(rdisk->qual[d.seq].pp_size_mb))
      FROM (dummyt d  WITH seq = value(size(rdisk->qual,5)))
      WHERE d.seq > 0
      WITH nocounter
     ;end select
     CALL accept(display_line,20,"P(29);cuF")
    ENDIF
   ENDIF
   SET cdh_return = curhelp
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(rdisk)
    CALL ts_inform(cnvtstring(cdh_ret_ndx))
    CALL ts_inform(cnvtstring(cdh_return))
    CALL ts_inform(curaccept)
    CALL echorecord(rdisk)
   ENDIF
   SET help = off
   RETURN(cnvtstring(cdh_return))
 END ;Subroutine
 SUBROUTINE container_check_rootvg(vg_ndx_in)
   CALL ts_inform("in container-check_rootvg")
   DECLARE chk_vg_ret = c1 WITH protect, noconstant("")
   DECLARE chk_txt = vc WITH protect, noconstant("")
   IF ((rdisk->qual[vg_ndx_in].root_ind=1))
    CALL clear(24,02,130)
    SET chk_txt = concat("WARNING! ",storage_device," will be on system disk:",trim(rdisk->qual[
      vg_ndx_in].disk_name),". Continue (Y) or No (N)?")
    CALL text(24,3,chk_txt)
    CALL accept(24,(textlen(chk_txt)+ 4),"p;cu","N"
     WHERE curaccept IN ("Y", "N"))
    CALL clear(24,02,130)
    IF (curaccept="N")
     SET chk_vg_ret = "N"
    ELSEIF (curaccept="Y")
     SET chk_vg_ret = "Y"
    ENDIF
   ELSE
    SET chk_vg_ret = "Y"
   ENDIF
   RETURN(chk_vg_ret)
 END ;Subroutine
 SUBROUTINE calc_disk_pp_num(cont_size_in,pp_size_in)
   CALL ts_inform("in calc_disk_pp_num")
   DECLARE pp_num = i4 WITH protect, noconstant(0)
   DECLARE pp_num_ret = i4 WITH protect, noconstant(0)
   SET pp_num = dm2ceil((cont_size_in/ pp_size_in))
   RETURN(pp_num)
 END ;Subroutine
 SUBROUTINE tspace_ncont_rel_key(null)
   CALL ts_inform("in tspace_ncont_rel_key")
   DECLARE rel_key_out = i4 WITH protect, noconstant(0)
   SET rel_key_out = 0
   SET rel_key_out = curtime3
   RETURN(rel_key_out)
 END ;Subroutine
 SUBROUTINE calc_min_space_add(cmsa_tspace_ndx)
   DECLARE cmsa_min_space_out = i2 WITH protect, noconstant(0)
   IF ((rtspace->qual[cmsa_tspace_ndx].chunk_size > 0))
    SET cmsa_min_space_out = get_good_chunks(cmsa_tspace_ndx)
    IF (cmsa_min_space_out > 0)
     SET cmsa_min_space_out = convert_bytes(rtspace->qual[cmsa_tspace_ndx].chunk_size,"b","m")
    ENDIF
   ELSE
    SET cmsa_min_space_out = 0
   ENDIF
   RETURN(cmsa_min_space_out)
 END ;Subroutine
 SUBROUTINE calc_cont_size_mb(pp_size_in,pps_add_in)
   CALL ts_inform("in calc_cont_size_mb")
   DECLARE cont_mb_ret = f8 WITH protect, noconstant(0.0)
   SET cont_mb_ret = (pp_size_in * pps_add_in)
   RETURN(cont_mb_ret)
 END ;Subroutine
 SUBROUTINE fill_default_space_add(fds_tspace_ndx,fds_remain_add)
   DECLARE fds_default_space_add = f8 WITH protect, noconstant(0.0)
   IF (get_good_chunks(fds_tspace_ndx) > 0)
    IF ((ncont_screen->remain_space_add >= rtspace->qual[fds_tspace_ndx].chunk_size))
     SET fds_default_space_add = convert_bytes(fds_remain_add,"b","m")
    ELSE
     SET fds_default_space_add = convert_bytes(rtspace->qual[fds_tspace_ndx].chunk_size,"b","m")
    ENDIF
   ELSE
    SET fds_default_space_add = convert_bytes(fds_remain_add,"b","m")
   ENDIF
   RETURN(fds_default_space_add)
 END ;Subroutine
 SUBROUTINE container_extend_menu(cont_ext_ndx)
   CALL ts_inform("in container_extend_menu")
   DECLARE ext_space_ok = i2 WITH protect, noconstant(0)
   DECLARE ext_disk_ndx = i2 WITH protect, noconstant(0)
   DECLARE ext_user_bytes_mb = f8 WITH protect, noconstant(0.0)
   DECLARE ext_curaccept = f8 WITH protect, noconstant(0.0)
   DECLARE ext_min_space_add = f8 WITH protect, noconstant(0.0)
   IF ((ncont_screen->cont[cont_ext_ndx].new_ind=0)
    AND size(ncont_screen->cont,5) > 0
    AND (ncont_screen->cont[cont_ext_ndx].disk_name != "NOT_FOUND"))
    SET ext_user_bytes_mb = 0.0
    SET ext_disk_ndx = locateval(ext_disk_ndx,1,size(rdisk->qual,5),ncont_screen->cont[cont_ext_ndx].
     disk_name,rdisk->qual[ext_disk_ndx].disk_name)
    SET ext_space_ok = 0
    WHILE (ext_space_ok=0)
      SET ext_user_bytes_mb = convert_bytes(ncont_screen->user_bytes,"b","m")
      SET temp_space_add = 0.0
      SET temp_space_add = fill_default_space_add(tspace_screen->cur_line,ncont_screen->
       remain_space_add)
      SET ext_min_space_add = 0
      SET ext_min_space_add = calc_min_space_add(tspace_screen->cur_line)
      IF (ext_min_space_add > 0)
       CALL display_warning("CHUNK MESSAGE",cnvtstring(ext_min_space_add))
      ELSE
       SET ext_min_space_add = 1
      ENDIF
      CALL accept(row_nbr,78,"NNNNNNNNNN;",temp_space_add
       WHERE curaccept >= ext_min_space_add)
      SET ext_curaccept = cnvtreal(curaccept)
      IF (ext_curaccept=0)
       SET ncont_screen->cont[cont_ext_ndx].add_ext_ind = "-"
      ELSE
       SET ncont_screen->cont[cont_ext_ndx].add_ext_ind = "x"
      ENDIF
      IF ((dm2_sys_misc->cur_db_os IN ("HPX", "AIX"))
       AND (dir_storage_misc->tgt_storage_type="RAW"))
       SET temp_space_add = cnvtreal(get_space_rounded(ext_curaccept,ncont_screen->cont[cont_ext_ndx]
         .pp_size_mb))
       IF ((ncont_screen->cont[cont_ext_ndx].space_to_add != 0))
        SET rdisk->qual[ext_disk_ndx].new_free_space_mb = (rdisk->qual[ext_disk_ndx].
        new_free_space_mb+ convert_bytes(ncont_screen->cont[cont_ext_ndx].space_to_add,"b","m"))
        SET ncont_screen->cont[cont_ext_ndx].cont_size_mb = (ncont_screen->cont[cont_ext_ndx].
        cont_size_mb - convert_bytes(ncont_screen->cont[cont_ext_ndx].space_to_add,"b","m"))
       ENDIF
       SET ncont_screen->cont[cont_ext_ndx].space_to_add = convert_bytes(temp_space_add,"m","b")
       SET pp_val = calc_disk_pp_num(convert_bytes(ncont_screen->cont[cont_ext_ndx].space_to_add,"b",
         "m"),ncont_screen->cont[cont_ext_ndx].pp_size_mb)
       SET ncont_screen->cont[cont_ext_ndx].pps_to_add = pp_val
       SET ncont_screen->cont[cont_ext_ndx].cont_size_mb = (ncont_screen->cont[cont_ext_ndx].
       cont_size_mb+ dm2ceil(calc_cont_size_mb(ncont_screen->cont[cont_ext_ndx].pp_size_mb,
         ncont_screen->cont[cont_ext_ndx].pps_to_add)))
      ELSE
       IF ((ncont_screen->cont[cont_ext_ndx].space_to_add != convert_bytes(temp_space_add,"m","b"))
        AND (ncont_screen->cont[cont_ext_ndx].space_to_add != 0))
        SET rdisk->qual[ext_disk_ndx].new_free_space_mb = (rdisk->qual[ext_disk_ndx].
        new_free_space_mb+ convert_bytes(ncont_screen->cont[cont_ext_ndx].space_to_add,"b","m"))
        SET ncont_screen->cont[cont_ext_ndx].cont_size_mb = (ncont_screen->cont[cont_ext_ndx].
        cont_size_mb - convert_bytes(ncont_screen->cont[cont_ext_ndx].space_to_add,"b","m"))
       ENDIF
       SET ncont_screen->cont[cont_ext_ndx].space_to_add = convert_bytes(ext_curaccept,"m","b")
       SET ncont_screen->cont[cont_ext_ndx].cont_size_mb = (ncont_screen->cont[cont_ext_ndx].
       cont_size_mb+ convert_bytes(ncont_screen->cont[cont_ext_ndx].space_to_add,"b","m"))
      ENDIF
      SET write_cont_return = tspace_check_disk_space(ext_disk_ndx,cont_ext_ndx)
      IF (write_cont_return="Y")
       CALL cont_update_rdisk(ext_disk_ndx,cont_ext_ndx)
       SET ext_space_ok = 1
       CALL clear(23,1,120)
       CALL clear(24,1,120)
       CALL fill_ncont_screen(0)
       CALL display_container_header(null)
      ELSE
       CALL display_warning("DISK SPACE EXTEND",ext_disk_ndx)
       SET ext_space_ok = 1
       SET write_cont_return = "N"
       SET ncont_screen->cont[cont_ext_ndx].cont_size_mb = (ncont_screen->cont[cont_ext_ndx].
       cont_size_mb - convert_bytes(ncont_screen->cont[cont_ext_ndx].space_to_add,"b","m"))
       SET ncont_screen->cont[cont_ext_ndx].space_to_add = 0
       SET ncont_screen->cont[cont_ext_ndx].add_ext_ind = ""
       SET ncont_screen->cont[cont_ext_ndx].pps_to_add = 0
      ENDIF
    ENDWHILE
   ELSE
    IF ((ncont_screen->cont[cont_ext_ndx].disk_name="NOT_FOUND"))
     CALL display_warning("NO DISK FOR DATAFILE",ncont_screen->cont[cont_ext_ndx].lv_filename)
    ELSE
     CALL display_warning("NO EXTEND ADDED CONT",0)
    ENDIF
   ENDIF
   RETURN(ts_destination)
 END ;Subroutine
 SUBROUTINE autopop_spread_files(ap_max_cont_size_in,ap_type_in)
   CALL ts_inform("in autopop_spread_files")
   DECLARE ap_disk_cnt = i4 WITH protect, noconstant(0)
   DECLARE ap_tspace_cnt = i4 WITH protect, noconstant(0)
   DECLARE ap_cont_cnt = i4 WITH protect, noconstant(0)
   DECLARE num_disks = i4 WITH protect, noconstant(0)
   DECLARE ap_num_cont = i4 WITH protect, noconstant(0)
   DECLARE ap_cont_needed = i2 WITH protect, noconstant(0)
   DECLARE ap_full_ind = i2 WITH protect, noconstant(0)
   DECLARE ap_find = vc WITH protect, noconstant("")
   DECLARE ap_revive_cnt = i4 WITH protect, noconstant(0)
   DECLARE ap_bytes_needed_rounded = f8 WITH protect, noconstant(0.0)
   DECLARE ap_add_ret = i2 WITH protect, noconstant(0)
   SET stat = alterlist(ap_spread_rs->ap_tspace,0)
   SET num_disks = size(autopop_screen->disk,5)
   CASE (ap_type_in)
    OF "LOB":
     SET ap_find = "L_"
    OF "DATA":
     SET ap_find = "D_"
    OF "INDEX":
     SET ap_find = "I_"
   ENDCASE
   SELECT
    IF ((dir_storage_misc->tgt_storage_type="ASM"))
     FROM (dummyt d  WITH seq = size(rtspace->qual,5))
     WHERE (rtspace->qual[d.seq].ct_err_ind=1)
      AND (rtspace->qual[d.seq].new_ind=1)
     ORDER BY rtspace->qual[d.seq].bytes_needed DESC
    ELSE
     FROM (dummyt d  WITH seq = size(rtspace->qual,5))
     WHERE (rtspace->qual[d.seq].ct_err_ind=1)
     ORDER BY rtspace->qual[d.seq].bytes_needed DESC
    ENDIF
    INTO "nl:"
    HEAD REPORT
     ap_disk_cnt = 0, ap_tspace_cnt = 0, ap_cont_cnt = 0
    DETAIL
     IF ((dir_storage_misc->tgt_storage_type="ASM"))
      ap_tspace_cnt = (ap_tspace_cnt+ 1), stat = alterlist(ap_spread_rs->ap_tspace,ap_tspace_cnt),
      ap_spread_rs->ap_tspace[ap_tspace_cnt].ap_tspace_name = rtspace->qual[d.seq].tspace_name,
      ap_spread_rs->ap_tspace[ap_tspace_cnt].ap_bytes_needed_mb = convert_bytes(rtspace->qual[d.seq].
       bytes_needed,"b","m")
     ELSE
      IF (substring(1,2,rtspace->qual[d.seq].tspace_name)=ap_find)
       ap_tspace_cnt = (ap_tspace_cnt+ 1), stat = alterlist(ap_spread_rs->ap_tspace,ap_tspace_cnt),
       ap_spread_rs->ap_tspace[ap_tspace_cnt].ap_tspace_name = rtspace->qual[d.seq].tspace_name,
       ap_spread_rs->ap_tspace[ap_tspace_cnt].ap_bytes_needed_mb = convert_bytes(rtspace->qual[d.seq]
        .bytes_needed,"b","m")
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   FOR (ap_tspace_cnt = 1 TO size(ap_spread_rs->ap_tspace,5))
     CALL display_warning("AUTOPOP PROGRESS",ap_spread_rs->ap_tspace[ap_tspace_cnt].ap_tspace_name)
     CALL ts_inform(concat("Spreading files for ",ap_spread_rs->ap_tspace[ap_tspace_cnt].
       ap_tspace_name))
     IF ((dir_storage_misc->tgt_storage_type="ASM"))
      SET ap_disk_cnt = dm2_assign_disk(ap_spread_rs->ap_tspace[ap_tspace_cnt].ap_bytes_needed_mb,
       ap_disk_cnt)
      IF (ap_disk_cnt=0)
       SET ap_full_ind = 1
       SET ap_tspace_cnt = size(ap_spread_rs->ap_tspace,5)
       RETURN("NO_DISK_SPACE")
      ENDIF
      SET ap_spread_rs->ap_tspace[ap_tspace_cnt].ap_asm_disk_group = autopop_screen->disk[ap_disk_cnt
      ].disk_name
      SET autopop_screen->disk[ap_disk_cnt].free_disk_space_mb = (autopop_screen->disk[ap_disk_cnt].
      free_disk_space_mb - ap_spread_rs->ap_tspace[ap_tspace_cnt].ap_bytes_needed_mb)
     ELSE
      SET ap_cont_needed = 0
      WHILE (ap_cont_needed=0
       AND ap_full_ind=0
       AND (ap_spread_rs->ap_tspace[ap_tspace_cnt].ap_bytes_needed_mb > 0))
        SET ap_cont_cnt = size(ap_spread_rs->ap_tspace[ap_tspace_cnt].ap_cont,5)
        IF ((ap_spread_rs->ap_tspace[ap_tspace_cnt].ap_bytes_needed_mb < ap_max_cont_size_in))
         SET ap_disk_cnt = dm2_assign_disk(ap_spread_rs->ap_tspace[ap_tspace_cnt].ap_bytes_needed_mb,
          ap_disk_cnt)
        ELSE
         SET ap_disk_cnt = dm2_assign_disk(ap_max_cont_size_in,ap_disk_cnt)
        ENDIF
        IF (ap_disk_cnt=0)
         SET ap_full_ind = 1
         SET ap_tspace_cnt = size(ap_spread_rs->ap_tspace,5)
         RETURN("NO_DISK_SPACE")
        ELSE
         SET ap_cont_cnt = (ap_cont_cnt+ 1)
         SET stat = alterlist(ap_spread_rs->ap_tspace[ap_tspace_cnt].ap_cont,ap_cont_cnt)
         IF ((ap_spread_rs->ap_tspace[ap_tspace_cnt].ap_bytes_needed_mb > ap_max_cont_size_in))
          SET ap_bytes_needed_rounded = 0
          IF ((dm2_sys_misc->cur_db_os IN ("HPX", "AIX")))
           SET ap_bytes_needed_rounded = get_space_rounded(cnvtreal(ap_max_cont_size_in),
            autopop_screen->disk[ap_disk_cnt].pp_size_mb)
          ELSEIF ((dm2_sys_misc->cur_db_os="AXP"))
           SET ap_bytes_needed_rounded = ap_max_cont_size_in
          ENDIF
         ELSE
          SET ap_bytes_needed_rounded = 0
          IF ((dm2_sys_misc->cur_db_os IN ("HPX", "AIX")))
           SET ap_bytes_needed_rounded = get_space_rounded(ap_spread_rs->ap_tspace[ap_tspace_cnt].
            ap_bytes_needed_mb,autopop_screen->disk[ap_disk_cnt].pp_size_mb)
          ELSEIF ((dm2_sys_misc->cur_db_os="AXP"))
           SET ap_bytes_needed_rounded = ap_spread_rs->ap_tspace[ap_tspace_cnt].ap_bytes_needed_mb
          ENDIF
          SET ap_cont_needed = 1
         ENDIF
         SET ap_add_ret = 0
         SET ap_add_ret = autopop_add_container(ap_tspace_cnt,ap_disk_cnt,ap_cont_cnt,
          ap_bytes_needed_rounded)
         CASE (ap_add_ret)
          OF 0:
           CALL disp_msg("Getting autopop filename",dm_err->logfile,1)
           GO TO exit_program
          OF 2:
           CALL display_warning("LV FILENAME",curaccept)
         ENDCASE
        ENDIF
      ENDWHILE
     ENDIF
   ENDFOR
   CALL display_warning("AUTOPOP DONE",ap_type_in)
   RETURN("COMPLETE")
 END ;Subroutine
 SUBROUTINE ap_reset_autopop(null)
  DECLARE ara_ts_cnt = i4 WITH protect, noconstant(0)
  FOR (ara_ts_cnt = 1 TO size(rtspace->qual,5))
    IF ((rtspace->qual[ara_ts_cnt].ct_err_ind=1))
     SET rtspace->qual[ara_ts_cnt].cont_complete_ind = 0
     SET rtspace->qual[ara_ts_cnt].ct_err_msg = ""
     SET stat = alterlist(rtspace->qual[ara_ts_cnt].cont,0)
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE ap_get_remain_space_add(null)
   DECLARE ap_rem_ts_cnt = i4 WITH protect, noconstant(0)
   DECLARE ap_rem_ct_cnt = i4 WITH protect, noconstant(0)
   DECLARE ap_rem_out = f8 WITH protect, noconstant(0.0)
   IF (size(ap_spread_rs->ap_tspace,5)=0)
    SET ap_rem_out = autopop_screen->user_bytes
   ELSE
    SET ap_rem_out = autopop_screen->user_bytes
    FOR (ap_rem_ts_cnt = 1 TO size(ap_spread_rs->ap_tspace,5))
      FOR (ap_rem_ct_cnt = 1 TO size(ap_spread_rs->ap_tspace[ap_rem_ts_cnt].ap_cont,5))
        SET ap_rem_out = (ap_rem_out - ap_spread_rs->ap_tspace[ap_rem_ts_cnt].ap_cont[ap_rem_ct_cnt].
        ap_space_to_add_mb)
      ENDFOR
    ENDFOR
   ENDIF
   IF (ap_rem_out < 0)
    SET ap_rem_out = 0
   ENDIF
   RETURN(ap_rem_out)
 END ;Subroutine
 SUBROUTINE autopop_add_container(aac_tspace_in,aac_disk_in,aac_cont_in,aac_space_add_in)
   CALL ts_inform(" in autopop_add_container")
   SET ap_spread_rs->ap_tspace[aac_tspace_in].ap_cont[aac_cont_in].ap_space_to_add_mb =
   aac_space_add_in
   SET ap_spread_rs->ap_tspace[aac_tspace_in].ap_cont[aac_cont_in].ap_vg_name = autopop_screen->disk[
   aac_disk_in].vg_name
   SET ap_spread_rs->ap_tspace[aac_tspace_in].ap_cont[aac_cont_in].ap_cont_tspace_rel_key =
   tspace_ncont_rel_key(null)
   SET ap_spread_rs->ap_tspace[aac_tspace_in].ap_cont[aac_cont_in].ap_disk_name = autopop_screen->
   disk[aac_disk_in].disk_name
   SET ap_spread_rs->ap_tspace[aac_tspace_in].ap_cont[aac_cont_in].ap_lv_filename =
   get_new_lv_filename(ap_spread_rs->ap_tspace[aac_tspace_in].ap_tspace_name,1,"none")
   CASE (ap_spread_rs->ap_tspace[aac_tspace_in].ap_cont[aac_cont_in].ap_lv_filename)
    OF "ERROR":
     RETURN(0)
    OF "NAME EXISTS":
     RETURN(2)
   ENDCASE
   SET autopop_screen->remain_space_add = (autopop_screen->remain_space_add - ap_spread_rs->
   ap_tspace[aac_tspace_in].ap_cont[aac_cont_in].ap_space_to_add_mb)
   SET ap_spread_rs->ap_tspace[aac_tspace_in].ap_cont[aac_cont_in].ap_volume_label = autopop_screen->
   disk[aac_disk_in].volume_label
   IF ((dm2_sys_misc->cur_db_os IN ("HPX", "AIX"))
    AND (dir_storage_misc->tgt_storage_type="RAW"))
    SET ap_spread_rs->ap_tspace[aac_tspace_in].ap_bytes_needed_mb = (ap_spread_rs->ap_tspace[
    aac_tspace_in].ap_bytes_needed_mb - (ap_spread_rs->ap_tspace[aac_tspace_in].ap_cont[aac_cont_in].
    ap_space_to_add_mb - 1))
   ELSEIF ((dm2_sys_misc->cur_db_os="AXP"))
    SET ap_spread_rs->ap_tspace[aac_tspace_in].ap_bytes_needed_mb = (ap_spread_rs->ap_tspace[
    aac_tspace_in].ap_bytes_needed_mb - ap_spread_rs->ap_tspace[aac_tspace_in].ap_cont[aac_cont_in].
    ap_space_to_add_mb)
   ENDIF
   SET autopop_screen->disk[aac_disk_in].free_disk_space_mb = (autopop_screen->disk[aac_disk_in].
   free_disk_space_mb - ap_spread_rs->ap_tspace[aac_tspace_in].ap_cont[aac_cont_in].
   ap_space_to_add_mb)
   SET ap_spread_rs->ap_tspace[aac_tspace_in].ap_cont[aac_cont_in].pp_size_mb = autopop_screen->disk[
   aac_disk_in].pp_size_mb
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ap_disk_delete(ap_del_in)
   DECLARE ap_xfer_cnt = i4 WITH protect, noconstant(0)
   DECLARE ap_del_cnt = i4 WITH protect, noconstant(0)
   DECLARE ap_rdisk_ndx = i4 WITH protect, noconstant(0)
   FREE RECORD autopop_xfer
   RECORD autopop_xfer(
     1 top_line = i4
     1 bottom_line = i4
     1 cur_line = i4
     1 max_scroll = i4
     1 max_value = i4
     1 disk_cnt = i4
     1 remain_space_add = f8
     1 user_bytes = f8
     1 disk[*]
       2 volume_label = vc
       2 disk_name = vc
       2 vg_name = vc
       2 disk_idx = i4
       2 lv_filename = vc
       2 free_disk_space_mb = f8
       2 pp_size_mb = f8
       2 pps_to_add = f8
       2 space_to_add = f8
       2 disk_tspace_rel_key = i4
       2 cont_size_mb = f8
       2 delete_ind = i4
       2 disk_full_ind = i2
       2 orig_disk_space_mb = f8
       2 mwc_flag = i2
       2 alloc_unit_b = f8
       2 block_size_b = f8
   )
   IF (size(autopop_screen->disk,5)=1)
    SET ap_rdisk_ndx = locateval(ap_rdisk_ndx,1,size(rdisk->qual,5),autopop_screen->disk[ap_del_in].
     disk_name,rdisk->qual[ap_rdisk_ndx].disk_name)
    SET rdisk->qual[ap_rdisk_ndx].used_ind = ""
    SET stat = alterlist(autopop_screen->disk,0)
    SET autopop_screen->disk_cnt = 0
    SET autopop_ready_ind = 0
    CALL clear(1,1)
    RETURN(1)
   ELSE
    SET autopop_screen->disk_cnt = (autopop_screen->disk_cnt - 1)
   ENDIF
   SET autopop_screen->max_value = autopop_screen->disk_cnt
   FOR (ap_del_cnt = 1 TO size(autopop_screen->disk,5))
     IF (ap_del_cnt != ap_del_in)
      SET ap_xfer_cnt = (ap_xfer_cnt+ 1)
      SET stat = alterlist(autopop_xfer->disk,ap_xfer_cnt)
      SET autopop_xfer->disk[ap_xfer_cnt].volume_label = autopop_screen->disk[ap_del_cnt].
      volume_label
      SET autopop_xfer->disk[ap_xfer_cnt].disk_name = autopop_screen->disk[ap_del_cnt].disk_name
      SET autopop_xfer->disk[ap_xfer_cnt].vg_name = autopop_screen->disk[ap_del_cnt].vg_name
      SET autopop_xfer->disk[ap_xfer_cnt].disk_idx = autopop_screen->disk[ap_del_cnt].disk_idx
      SET autopop_xfer->disk[ap_xfer_cnt].lv_filename = autopop_screen->disk[ap_del_cnt].lv_filename
      SET autopop_xfer->disk[ap_xfer_cnt].free_disk_space_mb = autopop_screen->disk[ap_del_cnt].
      free_disk_space_mb
      SET autopop_xfer->disk[ap_xfer_cnt].pp_size_mb = autopop_screen->disk[ap_del_cnt].pp_size_mb
      SET autopop_xfer->disk[ap_xfer_cnt].pps_to_add = autopop_screen->disk[ap_del_cnt].pps_to_add
      SET autopop_xfer->disk[ap_xfer_cnt].space_to_add = autopop_screen->disk[ap_del_cnt].
      space_to_add
      SET autopop_xfer->disk[ap_xfer_cnt].disk_tspace_rel_key = autopop_screen->disk[ap_del_cnt].
      disk_tspace_rel_key
      SET autopop_xfer->disk[ap_xfer_cnt].cont_size_mb = autopop_screen->disk[ap_del_cnt].
      cont_size_mb
      SET autopop_xfer->disk[ap_xfer_cnt].delete_ind = autopop_screen->disk[ap_del_cnt].delete_ind
      SET autopop_xfer->disk[ap_xfer_cnt].mwc_flag = autopop_screen->disk[ap_del_cnt].mwc_flag
      SET autopop_xfer->disk[ap_xfer_cnt].disk_full_ind = autopop_screen->disk[ap_del_cnt].
      disk_full_ind
      SET autopop_xfer->disk[ap_xfer_cnt].orig_disk_space_mb = autopop_screen->disk[ap_del_cnt].
      orig_disk_space_mb
      SET autopop_xfer->disk[ap_xfer_cnt].alloc_unit_b = autopop_screen->disk[ap_del_cnt].
      alloc_unit_b
      SET autopop_xfer->disk[ap_xfer_cnt].block_size_b = autopop_screen->disk[ap_del_cnt].
      block_size_b
     ENDIF
   ENDFOR
   SET ap_rdisk_ndx = locateval(ap_rdisk_ndx,1,size(rdisk->qual,5),autopop_screen->disk[ap_del_in].
    disk_name,rdisk->qual[ap_rdisk_ndx].disk_name)
   SET rdisk->qual[ap_rdisk_ndx].used_ind = ""
   SET stat = alterlist(autopop_screen->disk,0)
   SET stat = alterlist(autopop_screen->disk,size(autopop_xfer->disk,5))
   FOR (ap_xfer_cnt = 1 TO size(autopop_xfer->disk,5))
     SET autopop_screen->disk[ap_xfer_cnt].volume_label = autopop_xfer->disk[ap_xfer_cnt].
     volume_label
     SET autopop_screen->disk[ap_xfer_cnt].disk_name = autopop_xfer->disk[ap_xfer_cnt].disk_name
     SET autopop_screen->disk[ap_xfer_cnt].vg_name = autopop_xfer->disk[ap_xfer_cnt].vg_name
     SET autopop_screen->disk[ap_xfer_cnt].disk_idx = autopop_xfer->disk[ap_xfer_cnt].disk_idx
     SET autopop_screen->disk[ap_xfer_cnt].lv_filename = autopop_xfer->disk[ap_xfer_cnt].lv_filename
     SET autopop_screen->disk[ap_xfer_cnt].free_disk_space_mb = autopop_xfer->disk[ap_xfer_cnt].
     free_disk_space_mb
     SET autopop_screen->disk[ap_xfer_cnt].pp_size_mb = autopop_xfer->disk[ap_xfer_cnt].pp_size_mb
     SET autopop_screen->disk[ap_xfer_cnt].pps_to_add = autopop_xfer->disk[ap_xfer_cnt].pps_to_add
     SET autopop_screen->disk[ap_xfer_cnt].space_to_add = autopop_xfer->disk[ap_xfer_cnt].
     space_to_add
     SET autopop_screen->disk[ap_xfer_cnt].disk_tspace_rel_key = autopop_xfer->disk[ap_xfer_cnt].
     disk_tspace_rel_key
     SET autopop_screen->disk[ap_xfer_cnt].cont_size_mb = autopop_xfer->disk[ap_xfer_cnt].
     cont_size_mb
     SET autopop_screen->disk[ap_xfer_cnt].delete_ind = autopop_xfer->disk[ap_xfer_cnt].delete_ind
     SET autopop_screen->disk[ap_xfer_cnt].mwc_flag = autopop_xfer->disk[ap_xfer_cnt].mwc_flag
     SET autopop_screen->disk[ap_xfer_cnt].disk_full_ind = autopop_xfer->disk[ap_xfer_cnt].
     disk_full_ind
     SET autopop_screen->disk[ap_xfer_cnt].orig_disk_space_mb = autopop_xfer->disk[ap_xfer_cnt].
     orig_disk_space_mb
     SET autopop_screen->disk[ap_xfer_cnt].alloc_unit_b = autopop_xfer->disk[ap_xfer_cnt].
     alloc_unit_b
     SET autopop_screen->disk[ap_xfer_cnt].block_size_b = autopop_xfer->disk[ap_xfer_cnt].
     block_size_b
   ENDFOR
   CALL clear(1,1)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE container_delete(cont_del_ndx)
   CALL ts_inform("in container_delete")
   DECLARE del_txt = vc WITH protect, noconstant("")
   DECLARE cont_del_cnt = i4 WITH protect, noconstant(0)
   DECLARE c_del_cnt = i4 WITH protect, noconstant(0)
   DECLARE rt_del_ndx = i4 WITH protect, noconstant(0)
   DECLARE rt_ndx = i4 WITH protect, noconstant(0)
   DECLARE del_ret_out = vc WITH protect, noconstant("")
   FREE RECORD temp_ncont
   RECORD temp_ncont(
     1 cont_cnt2 = i4
     1 remain_space_add2 = f8
     1 user_bytes2 = f8
     1 user_bytes_orig2 = f8
     1 cont[*]
       2 volume_label2 = vc
       2 disk_name2 = vc
       2 vg_name2 = vc
       2 disk_idx2 = i4
       2 lv_filename2 = vc
       2 free_disk_space_mb2 = f8
       2 pp_size_mb2 = f8
       2 pps_to_add2 = f8
       2 space_to_add2 = f8
       2 cont_size_mb2 = f8
       2 delete_ind2 = i4
       2 cont_tspace_rel_key2 = i4
       2 add_ext_ind2 = c1
       2 new_ind2 = i2
       2 mwc_flag2 = i2
     1 top_line2 = i4
     1 bottom_line2 = i4
     1 cur_line2 = i4
     1 max_scroll2 = i4
     1 max_value2 = i4
   )
   SET del_ret_out = ""
   SET rt_ndx = 0
   SET rt_del_ndx = 0
   SET c_del_cnt = 0
   SET del_txt = ""
   SET cont_del_cnt = 0
   IF ((((ncont_screen->cont[cont_del_ndx].add_ext_ind="x")) OR ((ncont_screen->cont[cont_del_ndx].
   new_ind=0))) )
    IF (size(ncont_screen->cont,5)=0)
     SET del_txt = concat("No ",storage_device,"s are available for deletion.")
     CALL clear(24,2,130)
     CALL text(24,3,del_txt)
    ELSE
     SET del_txt = concat(storage_device," ",trim(cnvtstring(cont_del_ndx)),
      ", is not new and may not be removed.")
     CALL clear(24,2,130)
     CALL text(24,3,del_txt)
    ENDIF
   ELSE
    SET del_txt = concat("Are you sure you want to remove the current ",storage_device,": ",trim(
      cnvtstring(cont_del_ndx)),". (Y,N)")
    CALL clear(24,2,130)
    CALL text(24,3,del_txt)
    CALL accept(24,66,"p;cu","N"
     WHERE curaccept IN ("Y", "N"))
    IF (curaccept="Y")
     SET rt_ndx = locateval(rt_del_ndx,1,size(rtspace->qual[tspace_screen->cur_line].cont,5),
      ncont_screen->cont[cont_del_ndx].cont_tspace_rel_key,rtspace->qual[tspace_screen->cur_line].
      cont[rt_del_ndx].cont_tspace_rel_key)
     IF (rt_ndx > 0)
      SET rtspace->qual[tspace_screen->cur_line].cont[rt_ndx].delete_ind = 1
     ENDIF
     SET del_ret_out = "DELETE"
     SET ncont_screen->cont[cont_del_ndx].delete_ind = 1
     FOR (cont_del_cnt = 1 TO size(ncont_screen->cont,5))
       IF ((ncont_screen->cont[cont_del_cnt].delete_ind=0))
        SET c_del_cnt = (c_del_cnt+ 1)
        SET stat = alterlist(temp_ncont->cont,c_del_cnt)
        SET temp_ncont->cont[c_del_cnt].add_ext_ind2 = ncont_screen->cont[cont_del_cnt].add_ext_ind
        SET temp_ncont->cont[c_del_cnt].volume_label2 = ncont_screen->cont[cont_del_cnt].volume_label
        SET temp_ncont->cont[c_del_cnt].disk_name2 = ncont_screen->cont[cont_del_cnt].disk_name
        SET temp_ncont->cont[c_del_cnt].vg_name2 = ncont_screen->cont[cont_del_cnt].vg_name
        SET temp_ncont->cont[c_del_cnt].disk_idx2 = ncont_screen->cont[cont_del_cnt].disk_idx
        SET temp_ncont->cont[c_del_cnt].cont_tspace_rel_key2 = ncont_screen->cont[cont_del_cnt].
        cont_tspace_rel_key
        SET temp_ncont->cont[c_del_cnt].new_ind2 = ncont_screen->cont[cont_del_cnt].new_ind
        SET temp_ncont->cont[c_del_cnt].lv_filename2 = ncont_screen->cont[cont_del_cnt].lv_filename
        SET temp_ncont->cont[c_del_cnt].free_disk_space_mb2 = ncont_screen->cont[cont_del_cnt].
        free_disk_space_mb
        SET temp_ncont->cont[c_del_cnt].pp_size_mb2 = ncont_screen->cont[cont_del_cnt].pp_size_mb
        SET temp_ncont->cont[c_del_cnt].pps_to_add2 = ncont_screen->cont[cont_del_cnt].pps_to_add
        SET temp_ncont->cont[c_del_cnt].space_to_add2 = ncont_screen->cont[cont_del_cnt].space_to_add
        SET temp_ncont->cont[c_del_cnt].cont_size_mb2 = ncont_screen->cont[cont_del_cnt].cont_size_mb
        SET temp_ncont->cont[c_del_cnt].delete_ind2 = ncont_screen->cont[cont_del_cnt].delete_ind
        SET temp_ncont->cont[c_del_cnt].mwc_flag2 = ncont_screen->cont[cont_del_cnt].mwc_flag
       ENDIF
     ENDFOR
     SET stat = alterlist(ncont_screen->cont,0)
     SET stat = alterlist(ncont_screen->cont,size(temp_ncont->cont,5))
     FOR (cont_del_cnt = 1 TO size(temp_ncont->cont,5))
       SET ncont_screen->cont[cont_del_cnt].cont_tspace_rel_key = temp_ncont->cont[cont_del_cnt].
       cont_tspace_rel_key2
       SET ncont_screen->cont[cont_del_cnt].add_ext_ind = temp_ncont->cont[cont_del_cnt].add_ext_ind2
       SET ncont_screen->cont[cont_del_cnt].volume_label = temp_ncont->cont[cont_del_cnt].
       volume_label2
       SET ncont_screen->cont[cont_del_cnt].disk_name = temp_ncont->cont[cont_del_cnt].disk_name2
       SET ncont_screen->cont[cont_del_cnt].vg_name = temp_ncont->cont[cont_del_cnt].vg_name2
       SET ncont_screen->cont[cont_del_cnt].disk_idx = temp_ncont->cont[cont_del_cnt].disk_idx2
       SET ncont_screen->cont[cont_del_cnt].lv_filename = temp_ncont->cont[cont_del_cnt].lv_filename2
       SET ncont_screen->cont[cont_del_cnt].free_disk_space_mb = temp_ncont->cont[cont_del_cnt].
       free_disk_space_mb2
       SET ncont_screen->cont[cont_del_cnt].pp_size_mb = temp_ncont->cont[cont_del_cnt].pp_size_mb2
       SET ncont_screen->cont[cont_del_cnt].new_ind = temp_ncont->cont[cont_del_cnt].new_ind2
       SET ncont_screen->cont[cont_del_cnt].pps_to_add = temp_ncont->cont[cont_del_cnt].pps_to_add2
       SET ncont_screen->cont[cont_del_cnt].space_to_add = temp_ncont->cont[cont_del_cnt].
       space_to_add2
       SET ncont_screen->cont[cont_del_cnt].cont_size_mb = temp_ncont->cont[cont_del_cnt].
       cont_size_mb2
       SET ncont_screen->cont[cont_del_cnt].delete_ind = temp_ncont->cont[cont_del_cnt].delete_ind2
       SET ncont_screen->cont[cont_del_cnt].mwc_flag = temp_ncont->cont[cont_del_cnt].mwc_flag2
     ENDFOR
     CALL config_total_disk_space(null)
     CALL clear(24,2,130)
     SET del_txt = concat("The following ",storage_device," has been removed: ",trim(cnvtstring(
        cont_del_ndx)),".")
     CALL text(24,3,del_txt)
    ELSE
     CALL clear(24,2,130)
     SET del_txt = concat("The following ",storage_device," has NOT been removed: ",trim(cnvtstring(
        cont_del_ndx)),".")
     CALL text(24,3,del_txt)
    ENDIF
   ENDIF
   CALL pause(1)
   CALL display_container_header(null)
   SET display_line = (display_line - 1)
   RETURN(del_ret_out)
 END ;Subroutine
 SUBROUTINE save_cont_to_rtspace(null)
   CALL ts_inform("in save_cont_to_rtspace")
   DECLARE cont_rt_cnt = i4 WITH protect, noconstant(0)
   DECLARE scr_cont_size = i4 WITH protect, noconstant(0)
   DECLARE scr_rtspace_size = i4 WITH protect, noconstant(0)
   SET curalias ts rtspace->qual[tspace_screen->cur_line].cont[cont_rt_cnt]
   SET curalias nc ncont_screen->cont[cont_rt_cnt]
   SET scr_cont_size = size(ncont_screen->cont,5)
   SET stat = alterlist(rtspace->qual[tspace_screen->cur_line].cont,0)
   SET stat = alterlist(rtspace->qual[tspace_screen->cur_line].cont,scr_cont_size)
   FOR (cont_rt_cnt = 1 TO scr_cont_size)
     IF ((nc->new_ind=1))
      SET ts->cont_tspace_rel_key = nc->cont_tspace_rel_key
      SET ts->add_ext_ind = nc->add_ext_ind
      SET ts->volume_label = nc->volume_label
      SET ts->disk_name = nc->disk_name
      SET ts->vg_name = nc->vg_name
      SET ts->disk_idx = nc->disk_idx
      SET ts->new_ind = nc->new_ind
      SET ts->vg_name = nc->vg_name
      SET ts->pp_size_mb = nc->pp_size_mb
      SET ts->pps_to_add = nc->pps_to_add
      SET ts->space_to_add = nc->space_to_add
      SET ts->cont_size_mb = nc->cont_size_mb
      SET ts->lv_file = nc->lv_filename
      SET ts->mwc_flag = nc->mwc_flag
     ELSE
      SET ts->cont_tspace_rel_key = nc->cont_tspace_rel_key
      SET ts->add_ext_ind = nc->add_ext_ind
      IF ((nc->add_ext_ind="x"))
       SET rtspace->qual[tspace_screen->cur_line].extend_ind = 1
      ENDIF
      SET ts->volume_label = nc->volume_label
      SET ts->disk_name = nc->disk_name
      SET ts->vg_name = nc->vg_name
      SET ts->disk_idx = nc->disk_idx
      SET ts->new_ind = nc->new_ind
      SET ts->vg_name = nc->vg_name
      SET ts->pp_size_mb = nc->pp_size_mb
      SET ts->pps_to_add = nc->pps_to_add
      SET ts->space_to_add = nc->space_to_add
      SET ts->cont_size_mb = (nc->cont_size_mb+ ts->cont_size_mb)
      SET ts->lv_file = nc->lv_filename
      SET ts->mwc_flag = nc->mwc_flag
      SET ts->delete_ind = 0
     ENDIF
   ENDFOR
   SET stat = alterlist(ncont_screen->cont,0)
   SET ncont_screen->cont_cnt = 0
   SET ncont_screen->bottom_line = 0
   SET ncont_screen->cur_line = 0
   CALL config_total_disk_space(null)
   IF ((ncont_screen->remain_space_add=0))
    SET rtspace->qual[tspace_screen->cur_line].cont_complete_ind = 1
   ELSE
    SET rtspace->qual[tspace_screen->cur_line].cont_complete_ind = 0
   ENDIF
   SET curalias nc off
   SET curalias ts off
   RETURN("DONE")
 END ;Subroutine
 SUBROUTINE config_total_disk_space(null)
   CALL ts_inform("in config_total_disk_space")
   DECLARE ct_disk_cnt = i4 WITH protect, noconstant(0)
   DECLARE ct_cont_cnt = i4 WITH protect, noconstant(0)
   DECLARE ct_tspace_cnt = i4 WITH protect, noconstant(0)
   IF ((dir_storage_misc->tgt_storage_type != "ASM"))
    FOR (ct_disk_cnt = 1 TO size(rdisk->qual,5))
      SET rdisk->qual[ct_disk_cnt].used_ind = ""
      SET rdisk->qual[ct_disk_cnt].new_free_space_mb = rdisk->qual[ct_disk_cnt].free_space_mb
      FOR (ct_tspace_cnt = 1 TO size(rtspace->qual,5))
        IF ((rtspace->qual[ct_tspace_cnt].tspace_name=rtspace->qual[tspace_screen->cur_line].
        tspace_name)
         AND size(ncont_screen->cont,5) > 0)
         FOR (ct_cont_cnt = 1 TO size(ncont_screen->cont,5))
           IF ((ncont_screen->cont[ct_cont_cnt].disk_name=rdisk->qual[ct_disk_cnt].disk_name))
            SET rdisk->qual[ct_disk_cnt].new_free_space_mb = (rdisk->qual[ct_disk_cnt].
            new_free_space_mb - convert_bytes(ncont_screen->cont[ct_cont_cnt].space_to_add,"b","m"))
           ENDIF
         ENDFOR
        ELSE
         FOR (ct_cont_cnt = 1 TO size(rtspace->qual[ct_tspace_cnt].cont,5))
           IF ((rtspace->qual[ct_tspace_cnt].cont[ct_cont_cnt].delete_ind=0))
            IF ((rtspace->qual[ct_tspace_cnt].cont[ct_cont_cnt].disk_name=rdisk->qual[ct_disk_cnt].
            disk_name))
             SET rdisk->qual[ct_disk_cnt].new_free_space_mb = (rdisk->qual[ct_disk_cnt].
             new_free_space_mb - convert_bytes(rtspace->qual[ct_tspace_cnt].cont[ct_cont_cnt].
              space_to_add,"b","m"))
            ENDIF
           ENDIF
         ENDFOR
        ENDIF
      ENDFOR
    ENDFOR
   ELSE
    FOR (ct_disk_cnt = 1 TO size(rdisk->qual,5))
      SET rdisk->qual[ct_disk_cnt].used_ind = ""
      SET rdisk->qual[ct_disk_cnt].new_free_space_mb = rdisk->qual[ct_disk_cnt].free_space_mb
      FOR (ct_tspace_cnt = 1 TO size(rtspace->qual,5))
        IF ((rtspace->qual[ct_tspace_cnt].asm_disk_group=rdisk->qual[ct_disk_cnt].disk_name))
         SET rdisk->qual[ct_disk_cnt].new_free_space_mb = (rdisk->qual[ct_disk_cnt].new_free_space_mb
          - convert_bytes(rtspace->qual[ct_tspace_cnt].bytes_needed,"b","m"))
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE ts_view_disk_report(null)
   DECLARE tsd_line = vc WITH protect, noconstant("")
   DECLARE tsd_dash_line = vc WITH protect, noconstant("")
   SET tsd_dash_line = fillstring(132,"_")
   SET tsd_dot_line = fillstring(132,".")
   SELECT INTO mine
    d_name = rdisk->qual[d.seq].disk_name"CCCCCCCCCCCCCC"
    FROM (dummyt d  WITH seq = value(size(rdisk->qual,5)))
    ORDER BY d_name
    HEAD REPORT
     CALL center("*********** Disk Space Report ***********",0,132), row + 1,
     CALL center(
     "***********Disk Space Statistics Including Unapplied Tablespace Alteration/Creation ***********",
     0,132),
     row + 2
     IF ((dir_storage_misc->tgt_storage_type="ASM"))
      col 1, "Disk Group"
     ELSEIF ((dm2_sys_misc->cur_db_os IN ("AXP", "AIX")))
      col 1, "Disk Name"
     ELSEIF ((dm2_sys_misc->cur_db_os="HPX"))
      col 1, "Volume Group"
     ENDIF
     IF ((dm2_sys_misc->cur_db_os="AXP"))
      col 20, "Volume Label"
     ELSEIF ((dm2_sys_misc->cur_db_os IN ("AIX"))
      AND (dir_storage_misc->tgt_storage_type="RAW"))
      col 20, "Volume Group"
     ENDIF
     IF ((dm2_sys_misc->cur_db_os IN ("HPX", "AIX"))
      AND (dir_storage_misc->tgt_storage_type="RAW"))
      col 44, "PP Size", col 80,
      "PPs "
     ENDIF
     col 55, "Space (MB)", col 69,
     "Total"
     IF ((dir_storage_misc->tgt_storage_type="ASM"))
      col 83, "Allocation Unit", col 101,
      "Block"
     ENDIF
     row + 1
     IF ((dm2_sys_misc->cur_db_os IN ("HPX", "AIX"))
      AND (dir_storage_misc->tgt_storage_type="RAW"))
      col 80, "Available"
     ENDIF
     col 54, "Available", col 69,
     "Space (MB)"
     IF ((dir_storage_misc->tgt_storage_type="ASM"))
      col 83, "Size (Bytes)", col 101,
      "Size (Bytes)"
     ENDIF
     IF ((dm2_sys_misc->cur_db_os="AXP"))
      col 80, "Datafile Directory Exists"
     ENDIF
     row + 1, col 1, tsd_dash_line,
     row + 1
    DETAIL
     IF ((dm2_sys_misc->cur_db_os="HPX")
      AND (dir_storage_misc->tgt_storage_type="RAW"))
      tsd_line = rdisk->qual[d.seq].vg_name
     ELSE
      tsd_line = rdisk->qual[d.seq].disk_name
     ENDIF
     col 1, tsd_line
     IF ((dm2_sys_misc->cur_db_os="AXP"))
      tsd_line = rdisk->qual[d.seq].volume_label, col 20, tsd_line
     ELSEIF ((dm2_sys_misc->cur_db_os="AIX")
      AND (dir_storage_misc->tgt_storage_type="RAW"))
      tsd_line = rdisk->qual[d.seq].vg_name, col 20, tsd_line
     ENDIF
     IF ((dm2_sys_misc->cur_db_os IN ("HPX", "AIX"))
      AND (dir_storage_misc->tgt_storage_type="RAW"))
      tsd_line = format(cnvtstring(rdisk->qual[d.seq].pp_size_mb),"#####;R"), col 44, tsd_line
     ENDIF
     tsd_line = format(cnvtstring(rdisk->qual[d.seq].new_free_space_mb),"##########;R"), col 53,
     tsd_line,
     tsd_line = format(cnvtstring(rdisk->qual[d.seq].total_space_mb),"##########;R"), col 69,
     tsd_line,
     tsd_line = ""
     IF ((dm2_sys_misc->cur_db_os="AXP"))
      IF ((rdisk->qual[d.seq].datafile_dir_exists=1))
       tsd_line = "Yes"
      ELSE
       tsd_line = " - "
      ENDIF
      col 87, tsd_line
     ELSE
      IF ((dir_storage_misc->tgt_storage_type="ASM"))
       tsd_line = format(cnvtstring(rdisk->qual[d.seq].alloc_unit_b),"##########;R"), col 85,
       tsd_line,
       tsd_line = format(cnvtstring(rdisk->qual[d.seq].block_size_b),"##########;R"), col 100,
       tsd_line
      ELSE
       tsd_line = format(cnvtstring((rdisk->qual[d.seq].new_free_space_mb/ rdisk->qual[d.seq].
         pp_size_mb)),"##########;R"), col 79, tsd_line
      ENDIF
     ENDIF
     row + 1
    WITH nocounter, maxcol = 1000, nullreport
   ;end select
 END ;Subroutine
 SUBROUTINE display_tspace_summary_report(dtsr_mode)
   DECLARE dts_line = vc WITH protect, noconstant(fillstring(132,"_"))
   DECLARE dts_dash_line = vc WITH protect, noconstant(fillstring(132,"_"))
   DECLARE dts_cont_cnt = i4 WITH protect, noconstant(0)
   DECLARE dts_dot_line = vc WITH protect, noconstant(fillstring(132,"."))
   CALL ts_inform("Building Tspace Summary Report")
   SET logical dtm_logfile_hold dtm_summary_logfile
   SELECT
    IF (dtsr_mode=1)INTO dtm_logfile_hold
     t_name = rtspace->qual[d.seq].tspace_name"CCCCCCCCCCCCCCCCCCCCCCCCCCCCC"
     FROM (dummyt d  WITH seq = value(size(rtspace->qual,5)))
    ELSE INTO mine
     t_name = rtspace->qual[d.seq].tspace_name"CCCCCCCCCCCCCCCCCCCCCCCCCCCCC"
     FROM (dummyt d  WITH seq = value(size(rtspace->qual,5)))
    ENDIF
    ORDER BY t_name
    HEAD REPORT
     CALL center("*********** Tablespace Summary ***********",0,132), row + 1,
     CALL center(
     "*********** ( 'a' indicates added,  'x' indicates extended, '-' indicates existing) ***********",
     0,132),
     row + 2, col 51, "Current",
     col 66, "Space", row + 1,
     col 32, "Indicator", col 53,
     "Size", col 66, "to Add",
     col 90, "Logical Volume /", row + 1,
     col 32, "Add/Extend", col 1,
     "Tablespace Name", col 51, "MBYTES",
     col 66, "MBYTES", col 90,
     "File Name"
     IF ((dm2_sys_misc->cur_db_os="HPX")
      AND (dir_storage_misc->tgt_storage_type="RAW"))
      col 120, "Volume Group"
     ELSE
      col 120, "Disk"
     ENDIF
     row + 1, col 1, dts_dash_line,
     row + 1
    HEAD t_name
     dts_line = rtspace->qual[d.seq].tspace_name, col 1, dts_line,
     row + 1
     FOR (dts_cont_cnt = 1 TO size(rtspace->qual[d.seq].cont,5))
       dts_line = rtspace->qual[d.seq].cont[dts_cont_cnt].add_ext_ind, col 32, dts_line,
       dts_line = format(cnvtstring(rtspace->qual[d.seq].cont[dts_cont_cnt].cont_size_mb),
        "##########;R"), col 51, dts_line
       IF ((rtspace->qual[d.seq].cont[dts_cont_cnt].space_to_add > 0))
        dts_line = format(cnvtstring(convert_bytes(rtspace->qual[d.seq].cont[dts_cont_cnt].
           space_to_add,"b","m")),"##########;R")
       ELSE
        dts_line = format(cnvtstring(rtspace->qual[d.seq].cont[dts_cont_cnt].space_to_add),
         "##########;R")
       ENDIF
       col 66, dts_line, dts_line = rtspace->qual[d.seq].cont[dts_cont_cnt].lv_file,
       col 90, dts_line, dts_line = rtspace->qual[d.seq].cont[dts_cont_cnt].disk_name,
       col 120, dts_line, row + 1
     ENDFOR
     row + 1
    FOOT  t_name
     IF ((rtspace->qual[d.seq].cont_complete_ind=1)
      AND tspace_build=1)
      IF ((rtspace->qual[d.seq].ct_err_ind=0))
       dts_line = concat(rtspace->qual[d.seq].tspace_name," Operations Completed Successfully.")
      ELSE
       dts_line = concat("Error occurred: ",rtspace->qual[d.seq].ct_err_msg)
      ENDIF
      col 1, dts_line, row + 1
     ENDIF
     col 1, dts_dot_line, row + 1
    WITH nocounter, maxcol = 1000, nullreport,
     formfeed = none, format = stream
   ;end select
 END ;Subroutine
 SUBROUTINE ts_sort_rtspace(ts_sort_type)
   DECLARE ts_xfer_cnt = i4 WITH private, noconstant(0)
   DECLARE ts_xfer_ind = i2 WITH private, noconstant(0)
   DECLARE ts_refresh_disk = i2 WITH protect, noconstant(0)
   FREE RECORD rtspace_xfer
   RECORD rtspace_xfer(
     1 dbname = vc
     1 tmp_table_name = vc
     1 rtspace_cnt = i4
     1 sql_size_mb = f8
     1 sql_filegrowth_mb = f8
     1 install_type = vc
     1 install_type_value = vc
     1 commands_written_ind = i2
     1 database_remote = i2
     1 unique_nbr = vc
     1 qual[*]
       2 tspace_name = vc
       2 chunk_size = f8
       2 chunks_needed = i4
       2 ext_mgmt = c1
       2 tspace_id = i4
       2 cur_bytes_allocated = f8
       2 bytes_needed = f8
       2 user_bytes_to_add = f8
       2 final_bytes_to_add = f8
       2 new_ind = i2
       2 extend_ind = i2
       2 init_ext = f8
       2 next_ext = f8
       2 cont_complete_ind = i4
       2 cont_cnt = i4
       2 ct_err_msg = vc
       2 ct_err_ind = i2
       2 asm_disk_group = vc
       2 commands[*]
         3 cmd = vc
         3 cmd_type = vc
         3 lv_file = vc
         3 lv_exist_chk = i2
       2 cont[*]
         3 volume_label = vc
         3 disk_name = vc
         3 disk_idx = i4
         3 vg_name = vc
         3 pp_size_mb = f8
         3 pps_to_add = f8
         3 add_ext_ind = c1
         3 cont_tspace_rel_key = i4
         3 space_to_add = f8
         3 delete_ind = i2
         3 cont_size_mb = f8
         3 lv_file = vc
         3 new_ind = i2
         3 mwc_flag = i2
       2 temp_ind = i2
       2 user_tspace_ind = i2
   )
   FREE RECORD rdisk_xfer
   RECORD rdisk_xfer(
     1 disk_cnt = i4
     1 qual[*]
       2 disk_name = vc
       2 volume_label = vc
       2 vg_name = vc
       2 pp_size_mb = f8
       2 total_space_mb = f8
       2 free_space_mb = f8
       2 new_free_space_mb = f8
       2 root_ind = i2
       2 used_ind = vc
       2 data_tspace = i2
       2 index_tspace = i2
       2 datafile_dir_exists = i2
       2 mwc_flag = i2
       2 alloc_unit_b = f8
       2 block_size_b = f8
   )
   CASE (ts_sort_type)
    OF "ERROR":
     FOR (ts_xfer_cnt = 1 TO size(rtspace->qual,5))
       IF ((rtspace->qual[ts_xfer_cnt].ct_err_ind=1))
        SET ts_xfer_ind = 1
       ENDIF
     ENDFOR
     IF (ts_xfer_ind=1)
      CALL ts_inform("CALLING RTSPACE_REFRESH, mode 1")
      CALL rtspace_refresh(1,"NONE")
      CALL ts_inform("CALLING RTSPACE_REFRESH, mode 2")
      CALL rtspace_refresh(2,"NONE")
     ENDIF
    OF "SPACE":
     CALL ts_rtspace_sort_space(1,"SPACE")
     CALL ts_rtspace_sort_space(2,"SPACE")
    OF "RDISK":
     CALL ts_rtspace_sort_rdisk(1)
     CALL ts_rtspace_sort_rdisk(2)
    OF "DELETE":
     IF ((rtspace->qual[tspace_screen->cur_line].cont_complete_ind=1))
      SET ts_refresh_disk = 1
     ENDIF
     CALL ts_inform("CALLING RTSPACE_REFRESH, mode 1 for delete")
     CALL rtspace_refresh(1,"DELETE")
     CALL ts_inform("CALLING RTSPACE_REFRESH, mode 2 for delete")
     CALL rtspace_refresh(2,"DELETE")
     SET tspace_screen->cur_line = evaluate(tspace_screen->cur_line,1,1,(tspace_screen->cur_line - 1)
      )
     SET tspace_screen->max_value = size(rtspace->qual,5)
     IF (ts_refresh_disk=1)
      CALL ts_disk_refresh(null)
     ENDIF
   ENDCASE
   FREE RECORD rtspace_xfer
   FREE RECORD rdisk_xfer
 END ;Subroutine
 SUBROUTINE ts_rtspace_sort_rdisk(trsr_mode)
   DECLARE trsr_cnt = i4 WITH protect, noconstant(0)
   CALL ts_inform("Sorting rdisk by vgname or volume_label")
   IF (trsr_mode=1)
    SELECT
     IF ((dir_storage_misc->tgt_storage_type="ASM"))INTO "nl:"
      FROM (dummyt d  WITH seq = size(rdisk->qual,5))
      ORDER BY rdisk->qual[d.seq].disk_name
     ELSEIF ((dm2_sys_misc->cur_db_os IN ("HPX", "AIX")))INTO "nl:"
      FROM (dummyt d  WITH seq = size(rdisk->qual,5))
      ORDER BY rdisk->qual[d.seq].vg_name
     ELSEIF ((dm2_sys_misc->cur_db_os="AXP"))INTO "nl:"
      FROM (dummyt d  WITH seq = size(rdisk->qual,5))
      ORDER BY rdisk->qual[d.seq].volume_label
     ELSE
     ENDIF
     HEAD REPORT
      stat = alterlist(rdisk_xfer->qual,size(rdisk->qual,5))
     DETAIL
      trsr_cnt = (trsr_cnt+ 1), rdisk_xfer->qual[trsr_cnt].disk_name = rdisk->qual[d.seq].disk_name,
      rdisk_xfer->qual[trsr_cnt].vg_name = rdisk->qual[d.seq].vg_name,
      rdisk_xfer->qual[trsr_cnt].volume_label = rdisk->qual[d.seq].volume_label, rdisk_xfer->qual[
      trsr_cnt].pp_size_mb = rdisk->qual[d.seq].pp_size_mb, rdisk_xfer->qual[trsr_cnt].total_space_mb
       = rdisk->qual[d.seq].total_space_mb,
      rdisk_xfer->qual[trsr_cnt].free_space_mb = rdisk->qual[d.seq].free_space_mb, rdisk_xfer->qual[
      trsr_cnt].new_free_space_mb = rdisk->qual[d.seq].new_free_space_mb, rdisk_xfer->qual[trsr_cnt].
      root_ind = rdisk->qual[d.seq].root_ind,
      rdisk_xfer->qual[trsr_cnt].used_ind = rdisk->qual[d.seq].used_ind, rdisk_xfer->qual[trsr_cnt].
      data_tspace = rdisk->qual[d.seq].data_tspace, rdisk_xfer->qual[trsr_cnt].index_tspace = rdisk->
      qual[d.seq].index_tspace,
      rdisk_xfer->qual[trsr_cnt].datafile_dir_exists = rdisk->qual[d.seq].datafile_dir_exists,
      rdisk_xfer->qual[trsr_cnt].mwc_flag = rdisk->qual[d.seq].mwc_flag, rdisk_xfer->qual[trsr_cnt].
      alloc_unit_b = rdisk->qual[d.seq].alloc_unit_b,
      rdisk_xfer->qual[trsr_cnt].block_size_b = rdisk->qual[d.seq].block_size_b
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = size(rdisk_xfer->qual,5))
     HEAD REPORT
      stat = alterlist(rdisk->qual,0), stat = alterlist(rdisk->qual,size(rdisk_xfer->qual,5))
     DETAIL
      rdisk->qual[d.seq].disk_name = rdisk_xfer->qual[d.seq].disk_name, rdisk->qual[d.seq].vg_name =
      rdisk_xfer->qual[d.seq].vg_name, rdisk->qual[d.seq].volume_label = rdisk_xfer->qual[d.seq].
      volume_label,
      rdisk->qual[d.seq].pp_size_mb = rdisk_xfer->qual[d.seq].pp_size_mb, rdisk->qual[d.seq].
      total_space_mb = rdisk_xfer->qual[d.seq].total_space_mb, rdisk->qual[d.seq].free_space_mb =
      rdisk_xfer->qual[d.seq].free_space_mb,
      rdisk->qual[d.seq].new_free_space_mb = rdisk_xfer->qual[d.seq].new_free_space_mb, rdisk->qual[d
      .seq].root_ind = rdisk_xfer->qual[d.seq].root_ind, rdisk->qual[d.seq].used_ind = rdisk_xfer->
      qual[d.seq].used_ind,
      rdisk->qual[d.seq].data_tspace = rdisk_xfer->qual[d.seq].data_tspace, rdisk->qual[d.seq].
      index_tspace = rdisk_xfer->qual[d.seq].index_tspace, rdisk->qual[d.seq].datafile_dir_exists =
      rdisk_xfer->qual[d.seq].datafile_dir_exists,
      rdisk->qual[d.seq].mwc_flag = rdisk_xfer->qual[d.seq].mwc_flag, rdisk->qual[d.seq].alloc_unit_b
       = rdisk_xfer->qual[d.seq].alloc_unit_b, rdisk->qual[d.seq].block_size_b = rdisk_xfer->qual[d
      .seq].block_size_b
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE ts_rtspace_sort_space(trs_mode,trs_type)
  DECLARE trs_ts_cnt = i4 WITH protect, noconstant(0)
  IF (trs_mode=1)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(rtspace->qual,5))
    ORDER BY rtspace->qual[d.seq].bytes_needed DESC
    DETAIL
     IF (((trs_type="SPACE"
      AND (rtspace->qual[d.seq].bytes_needed > 0)) OR (trs_type != "SPACE")) )
      trs_ts_cnt = (trs_ts_cnt+ 1), stat = alterlist(rtspace_xfer->qual,trs_ts_cnt), rtspace_xfer->
      qual[trs_ts_cnt].tspace_name = rtspace->qual[d.seq].tspace_name,
      rtspace_xfer->qual[trs_ts_cnt].chunk_size = rtspace->qual[d.seq].chunk_size, rtspace_xfer->
      qual[trs_ts_cnt].chunks_needed = rtspace->qual[d.seq].chunks_needed, rtspace_xfer->qual[
      trs_ts_cnt].ext_mgmt = rtspace->qual[d.seq].ext_mgmt,
      rtspace_xfer->qual[trs_ts_cnt].tspace_id = rtspace->qual[d.seq].tspace_id, rtspace_xfer->qual[
      trs_ts_cnt].cur_bytes_allocated = rtspace->qual[d.seq].cur_bytes_allocated, rtspace_xfer->qual[
      trs_ts_cnt].bytes_needed = rtspace->qual[d.seq].bytes_needed,
      rtspace_xfer->qual[trs_ts_cnt].user_bytes_to_add = rtspace->qual[d.seq].user_bytes_to_add,
      rtspace_xfer->qual[trs_ts_cnt].final_bytes_to_add = rtspace->qual[d.seq].final_bytes_to_add,
      rtspace_xfer->qual[trs_ts_cnt].new_ind = rtspace->qual[d.seq].new_ind,
      rtspace_xfer->qual[trs_ts_cnt].extend_ind = rtspace->qual[d.seq].extend_ind, rtspace_xfer->
      qual[trs_ts_cnt].init_ext = rtspace->qual[d.seq].init_ext, rtspace_xfer->qual[trs_ts_cnt].
      next_ext = rtspace->qual[d.seq].next_ext,
      rtspace_xfer->qual[trs_ts_cnt].new_ind = rtspace->qual[d.seq].new_ind, rtspace_xfer->qual[
      trs_ts_cnt].cont_complete_ind = rtspace->qual[d.seq].cont_complete_ind, rtspace_xfer->qual[
      trs_ts_cnt].cont_cnt = rtspace->qual[d.seq].cont_cnt,
      rtspace_xfer->qual[trs_ts_cnt].ct_err_msg = rtspace->qual[d.seq].ct_err_msg, rtspace_xfer->
      qual[trs_ts_cnt].ct_err_ind = rtspace->qual[d.seq].ct_err_ind, rtspace_xfer->qual[trs_ts_cnt].
      asm_disk_group = rtspace->qual[d.seq].asm_disk_group,
      rtspace_xfer->qual[trs_ts_cnt].temp_ind = rtspace->qual[d.seq].temp_ind, rtspace_xfer->qual[
      trs_ts_cnt].user_tspace_ind = rtspace->qual[d.seq].user_tspace_ind
     ENDIF
    WITH nocounter
   ;end select
   SET rtspace_xfer->rtspace_cnt = trs_ts_cnt
  ELSE
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(rtspace_xfer->qual,5))
    HEAD REPORT
     stat = alterlist(rtspace->qual,0), stat = alterlist(rtspace->qual,size(rtspace_xfer->qual,5))
    DETAIL
     rtspace->qual[d.seq].tspace_name = rtspace_xfer->qual[d.seq].tspace_name, rtspace->qual[d.seq].
     chunk_size = rtspace_xfer->qual[d.seq].chunk_size, rtspace->qual[d.seq].chunks_needed =
     rtspace_xfer->qual[d.seq].chunks_needed,
     rtspace->qual[d.seq].ext_mgmt = rtspace_xfer->qual[d.seq].ext_mgmt, rtspace->qual[d.seq].
     tspace_id = rtspace_xfer->qual[d.seq].tspace_id, rtspace->qual[d.seq].cur_bytes_allocated =
     rtspace_xfer->qual[d.seq].cur_bytes_allocated,
     rtspace->qual[d.seq].bytes_needed = rtspace_xfer->qual[d.seq].bytes_needed, rtspace->qual[d.seq]
     .user_bytes_to_add = rtspace_xfer->qual[d.seq].user_bytes_to_add, rtspace->qual[d.seq].
     final_bytes_to_add = rtspace_xfer->qual[d.seq].final_bytes_to_add,
     rtspace->qual[d.seq].new_ind = rtspace_xfer->qual[d.seq].new_ind, rtspace->qual[d.seq].
     extend_ind = rtspace_xfer->qual[d.seq].extend_ind, rtspace->qual[d.seq].init_ext = rtspace_xfer
     ->qual[d.seq].init_ext,
     rtspace->qual[d.seq].next_ext = rtspace_xfer->qual[d.seq].next_ext, rtspace->qual[d.seq].new_ind
      = rtspace_xfer->qual[d.seq].new_ind, rtspace->qual[d.seq].cont_complete_ind = rtspace_xfer->
     qual[d.seq].cont_complete_ind,
     rtspace->qual[d.seq].cont_cnt = rtspace_xfer->qual[d.seq].cont_cnt, rtspace->qual[d.seq].
     ct_err_msg = rtspace_xfer->qual[d.seq].ct_err_msg, rtspace->qual[d.seq].ct_err_ind =
     rtspace_xfer->qual[d.seq].ct_err_ind,
     rtspace->qual[d.seq].temp_ind = rtspace_xfer->qual[d.seq].temp_ind, rtspace->qual[d.seq].
     user_tspace_ind = rtspace_xfer->qual[d.seq].user_tspace_ind
    WITH nocounter
   ;end select
   SET rtspace->rtspace_cnt = rtspace_xfer->rtspace_cnt
  ENDIF
 END ;Subroutine
 SUBROUTINE rtspace_refresh(rr_mode,rr_action)
   DECLARE ts_cnt = i4 WITH protect, noconstant(0)
   DECLARE rt_cnt = i2 WITH protect, noconstant(0)
   DECLARE ts_size = i4 WITH protect, noconstant(0)
   DECLARE track_cnt = i4 WITH protect, noconstant(0)
   DECLARE err_cnt = i4 WITH protect, noconstant(0)
   CALL ts_inform("IN RTSPACE_REFRESH")
   IF (rr_mode=1)
    SET curalias tspace rtspace->qual[rt_cnt]
    SET curalias tspace_xfer rtspace_xfer->qual[ts_cnt]
    SET ts_size = value(size(rtspace->qual,5))
    IF (rr_action="DELETE")
     SET stat = alterlist(rtspace_xfer->qual,(ts_size - 1))
    ELSE
     SET stat = alterlist(rtspace_xfer->qual,ts_size)
    ENDIF
   ELSE
    SET curalias tspace rtspace_xfer->qual[rt_cnt]
    SET curalias tspace_xfer rtspace->qual[ts_cnt]
    SET ts_size = value(size(rtspace_xfer->qual,5))
    SET stat = alterlist(rtspace->qual,0)
    SET stat = alterlist(rtspace->qual,ts_size)
   ENDIF
   IF ((dm_err->debug_flag=722))
    SET message = nowindow
    CALL echorecord(rtspace)
    CALL echorecord(rtspace_xfer)
   ENDIF
   SET err_cnt = 1
   WHILE (err_cnt >= 0)
    FOR (rt_cnt = 1 TO ts_size)
      IF ((((tspace->ct_err_ind=err_cnt)
       AND rr_action != "DELETE") OR (((rr_action="DELETE"
       AND (rt_cnt != tspace_screen->cur_line)
       AND rr_mode=1) OR (rr_mode=2
       AND rr_action="DELETE")) )) )
       SET ts_cnt = (ts_cnt+ 1)
       SET tspace_xfer->tspace_name = tspace->tspace_name
       SET tspace_xfer->tspace_id = tspace->tspace_id
       SET tspace_xfer->cur_bytes_allocated = tspace->cur_bytes_allocated
       SET tspace_xfer->bytes_needed = tspace->bytes_needed
       SET tspace_xfer->user_bytes_to_add = tspace->user_bytes_to_add
       SET tspace_xfer->final_bytes_to_add = tspace->final_bytes_to_add
       SET tspace_xfer->new_ind = tspace->new_ind
       SET tspace_xfer->extend_ind = tspace->extend_ind
       SET tspace_xfer->init_ext = tspace->init_ext
       SET tspace_xfer->next_ext = tspace->next_ext
       SET tspace_xfer->new_ind = tspace->new_ind
       SET tspace_xfer->cont_complete_ind = tspace->cont_complete_ind
       SET tspace_xfer->cont_cnt = tspace->cont_cnt
       SET tspace_xfer->ct_err_msg = tspace->ct_err_msg
       SET tspace_xfer->ct_err_ind = tspace->ct_err_ind
       SET tspace_xfer->ext_mgmt = tspace->ext_mgmt
       SET tspace_xfer->chunk_size = tspace->chunk_size
       SET tspace_xfer->chunks_needed = tspace->chunks_needed
       SET tspace_xfer->temp_ind = tspace->temp_ind
       SET tspace_xfer->user_tspace_ind = tspace->user_tspace_ind
       SET stat = alterlist(tspace_xfer->commands,size(tspace->commands,5))
       FOR (op_cnt = 1 TO size(tspace->commands,5))
         SET tspace_xfer->commands[op_cnt].cmd = tspace->commands[op_cnt].cmd
         SET tspace_xfer->commands[op_cnt].cmd_type = tspace->commands[op_cnt].cmd_type
         SET tspace_xfer->commands[op_cnt].lv_file = tspace->commands[op_cnt].lv_file
         SET tspace_xfer->commands[op_cnt].lv_exist_chk = tspace->commands[op_cnt].lv_exist_chk
       ENDFOR
       CALL rtspace_refresh_cont(rr_mode)
      ENDIF
    ENDFOR
    IF (rr_action="DELETE")
     SET err_cnt = - (1)
    ELSE
     SET err_cnt = (err_cnt - 1)
    ENDIF
   ENDWHILE
   SET curalias tspace off
   SET curalias tspace_xfer off
 END ;Subroutine
 SUBROUTINE rtspace_refresh_cont(rrc_mode)
   DECLARE tsxfer_cnt = i4 WITH private, noconstant(0)
   DECLARE ct_size = i4 WITH private, noconstant(0)
   DECLARE ct_cnt = i4 WITH private, noconstant(0)
   IF (rrc_mode=1)
    SET curalias contain rtspace->qual[rt_cnt].cont[ct_cnt]
    SET curalias contain_xfer rtspace_xfer->qual[ts_cnt].cont[ct_cnt]
    SET stat = alterlist(rtspace_xfer->qual[ts_cnt].cont,value(size(rtspace->qual[rt_cnt].cont,5)))
    SET ct_size = size(rtspace->qual[rt_cnt].cont,5)
   ELSE
    SET curalias contain rtspace_xfer->qual[rt_cnt].cont[ct_cnt]
    SET curalias contain_xfer rtspace->qual[ts_cnt].cont[ct_cnt]
    SET stat = alterlist(rtspace->qual[ts_cnt].cont,value(size(rtspace_xfer->qual[rt_cnt].cont,5)))
    SET ct_size = size(rtspace_xfer->qual[rt_cnt].cont,5)
   ENDIF
   SET ct_cnt = 0
   FOR (ct_cnt = 1 TO ct_size)
     SET contain_xfer->volume_label = contain->volume_label
     SET contain_xfer->disk_name = contain->disk_name
     SET contain_xfer->disk_idx = contain->disk_idx
     SET contain_xfer->vg_name = contain->vg_name
     SET contain_xfer->pp_size_mb = contain->pp_size_mb
     SET contain_xfer->pps_to_add = contain->pps_to_add
     SET contain_xfer->add_ext_ind = contain->add_ext_ind
     SET contain_xfer->cont_tspace_rel_key = contain->cont_tspace_rel_key
     SET contain_xfer->space_to_add = contain->space_to_add
     SET contain_xfer->delete_ind = contain->delete_ind
     SET contain_xfer->cont_size_mb = contain->cont_size_mb
     SET contain_xfer->lv_file = contain->lv_file
     SET contain_xfer->new_ind = contain->new_ind
     SET contain_xfer->mwc_flag = contain->mwc_flag
   ENDFOR
   SET curalias contain off
   SET curalias contain_xfer off
 END ;Subroutine
 SUBROUTINE ts_check_if_tspace_to_display(null)
   DECLARE dcit_ind = i2 WITH protect, noconstant(0)
   DECLARE dcit_cnt = i4 WITH protect, noconstant(0)
   FOR (dcit_cnt = 1 TO size(rtspace->qual,5))
     IF ((rtspace->qual[dcit_cnt].ct_err_ind=1))
      SET dcit_ind = 1
      SET dcit_cnt = size(rtspace->qual,5)
     ENDIF
   ENDFOR
   RETURN(dcit_ind)
 END ;Subroutine
 SUBROUTINE tspace_check_complete(null)
   CALL ts_inform("in tspace_check_complete")
   DECLARE tcc_check_cnt = i4 WITH protect, noconstant(0)
   DECLARE tcc_complete_cnt = i2 WITH protect, noconstant(0)
   DECLARE tcc_return = vc WITH protect, noconstant("")
   DECLARE tcc_check_ind = i2 WITH protect, noconstant(0)
   FOR (tcc_complete_cnt = 1 TO size(rtspace->qual,5))
     IF ((rtspace->qual[tcc_complete_cnt].cont_complete_ind=0))
      SET tcc_complete_cnt = size(rtspace->qual,5)
      SET tcc_check_ind = 1
     ENDIF
   ENDFOR
   IF (tcc_check_ind=0)
    RETURN("COMPLETE")
   ELSE
    RETURN("")
   ENDIF
 END ;Subroutine
 SUBROUTINE retrieve_os_data_diff_node(roddn_mode)
   DECLARE roddn_cmd1 = vc WITH protect, noconstant("")
   DECLARE roddn_cmd2 = vc WITH protect, noconstant("")
   DECLARE roddn_cmd3 = vc WITH protect, noconstant("")
   DECLARE roddn_ksh1 = vc WITH protect, noconstant("")
   DECLARE roddn_file1 = vc WITH protect, noconstant("")
   DECLARE roddn_file2 = vc WITH protect, noconstant("")
   DECLARE roddn_file3 = vc WITH protect, noconstant("")
   DECLARE roddn_com_file = vc WITH protect, noconstant("")
   DECLARE roddn_cnt = i4 WITH protect, noconstant(0)
   DECLARE roddn_found = i2 WITH protect, noconstant(0)
   DECLARE roddn_ndx = i4 WITH protect, noconstant(0)
   DECLARE roddn_msg = vc WITH protect, noconstant("")
   DECLARE roddn_currow = i4 WITH protect, noconstant(0)
   FREE RECORD roddn_com
   RECORD roddn_com(
     1 qual[*]
       2 c_line = vc
   )
   SET rtspace->unique_nbr = trim(cnvtstring(format(cnvtdatetime(curdate,curtime),"mmddyyhhmm;;d")))
   SET roddn_ksh1 = concat("dm2_get_disk_info_",rtspace->unique_nbr,evaluate(dm2_sys_misc->cur_db_os,
     "AXP",".com",".ksh"))
   CASE (dm2_sys_misc->cur_db_os)
    OF "HPX":
     SET roddn_file1 = concat("dm2_disk_info_",rtspace->unique_nbr,".dat")
     SET roddn_cmd1 = concat("vgdisplay >> ",roddn_file1)
    OF "AIX":
     SET roddn_file1 = concat("dm2_disk_info_",rtspace->unique_nbr,".dat")
     SET roddn_file2 = concat("dm2_pv_lv_list_",rtspace->unique_nbr,".dat")
     SET roddn_file3 = concat("dm2_disk_mwc",rtspace->unique_nbr,".dat")
     SET roddn_cmd1 = concat(
      ^a=`lsvg -o | awk -v b="" '{b=sprintf("%s| %s ",b,$1)}END{print b}' | sed 's/^,
      "^| //g'`;for i in `lspv | egrep ",^"($a)" | awk '{print $1}'`;do lspv $i >> ^,roddn_file1,
      ";done")
     SET roddn_cmd2 = concat(
      ^a=`lsvg -o | awk -v b="" '{b=sprintf("%s| %s ",b,$1)}END{print b}' | sed 's/^,
      "^| //g'`;for i in `lspv | egrep ",^"($a)" | awk '{print $1}'`;do lspv -l $i >> ^,roddn_file2,
      ";done ")
     SET roddn_cmd3 = concat(
      ^a=`lsvg -o | awk -v b="" '{b=sprintf("%s| %s ",b,$1)}END{print b}' | sed 's/^,
      "^| //g'`;for i in `lspv | egrep ",^"($a)" | awk '{print $1}'`;do lqueryvg -p /dev/$i -X | ^,
      ^echo $i `awk '{print" "$1}'` ;done >> ^,roddn_file3)
    OF "AXP":
     SET roddn_file1 = concat("dm2_disk_info_",rtspace->unique_nbr,".dat")
     SET roddn_file2 = concat("dm2_sys_dev_",rtspace->unique_nbr,".dat")
     SET roddn_cmd1 = concat("$show logical/output=",roddn_file2," sys$sysdevice")
   ENDCASE
   IF (roddn_mode=1)
    IF ((dm2_sys_misc->cur_db_os="AXP"))
     SET dm_err->eproc = "Load dm2_get_mnt_disk_info.txt into structure from cer_install"
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     SET roddn_com_file = "cer_install:dm2_get_mnt_disk_info.txt"
     SET logical axp_disk_info roddn_com_file
     FREE DEFINE rtl
     DEFINE rtl "axp_disk_info"
     SELECT INTO "nl:"
      t.line
      FROM rtlt t
      WHERE t.line > " "
      HEAD REPORT
       roddn_cnt = 0
      DETAIL
       roddn_cnt = (roddn_cnt+ 1)
       IF (mod(roddn_cnt,10)=1)
        stat = alterlist(roddn_com->qual,(roddn_cnt+ 9))
       ENDIF
       roddn_com->qual[roddn_cnt].c_line = t.line
      FOOT REPORT
       stat = alterlist(roddn_com->qual,roddn_cnt)
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = concat("Create ",roddn_ksh1," in ccluserdir")
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     SELECT INTO value(roddn_ksh1)
      FROM (dummyt d  WITH d.seq = 1)
      HEAD REPORT
       FOR (roddn_cnt = 1 TO size(roddn_com->qual,5))
         IF ((roddn_com->qual[roddn_cnt].c_line="$ exit"))
          col 0, roddn_cmd1, row + 1
         ENDIF
         col 0, roddn_com->qual[roddn_cnt].c_line, row + 1
       ENDFOR
      WITH nocounter, maxcol = 132, maxrow = 1
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ELSE
     SET dm_err->eproc = concat("Creating ",roddn_ksh1," in CCLUSERDIR")
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     SELECT INTO value(roddn_ksh1)
      FROM (dummyt d  WITH d.seq = 1)
      DETAIL
       CASE (dm2_sys_misc->cur_db_os)
        OF "HPX":
         col 0,roddn_cmd1,row + 1
        OF "AIX":
         col 0,roddn_cmd1,row + 1,
         col 0,roddn_cmd2,row + 1,
         col 0,roddn_cmd3,row + 1
       ENDCASE
      WITH nocounter, maxcol = 500, format = variable,
       formfeed = none, maxrow = 1
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    WHILE (roddn_found=0)
      SET message = window
      CALL clear(1,1)
      CALL text(2,1,concat("Take the following ",evaluate(dm2_sys_misc->cur_db_os,"AXP","COM","KSH"),
        " file located in CCLUSERDIR and copy to database node:"))
      CALL text(3,4,roddn_ksh1)
      SET roddn_currow = 5
      IF ((dm2_sys_misc->cur_db_os != "AXP"))
       CALL text(roddn_currow,1,concat("Change file permission for ",evaluate(dm2_sys_misc->cur_db_os,
          "AXP","COM","KSH")," file that was moved to the database node as follows:"))
       CALL text((roddn_currow+ 1),4,concat("chmod 777 ",roddn_ksh1))
       SET roddn_currow = (roddn_currow+ 3)
      ENDIF
      CALL text(roddn_currow,1,concat("Execute the following ",evaluate(dm2_sys_misc->cur_db_os,"AXP",
         "COM","KSH")," file that was moved to the database node as follows:"))
      SET roddn_currow = (roddn_currow+ 1)
      CALL text(roddn_currow,4,concat(evaluate(dm2_sys_misc->cur_db_os,"AXP","@","$. "),roddn_ksh1,
        " ",evaluate(dm2_sys_misc->cur_db_os,"AXP",roddn_file1," ")))
      SET roddn_currow = (roddn_currow+ 2)
      CALL text(roddn_currow,1,concat(
        "Copy the following files created from the execution of the above ",evaluate(dm2_sys_misc->
         cur_db_os,"AXP","COM","KSH")," to CCLUSERDIR in this node:"))
      SET roddn_currow = (roddn_currow+ 1)
      CASE (dm2_sys_misc->cur_db_os)
       OF "HPX":
        CALL text(roddn_currow,4,roddn_file1)
        SET roddn_currow = (roddn_currow+ 2)
       OF "AIX":
        CALL text(roddn_currow,4,roddn_file1)
        CALL text((roddn_currow+ 1),4,roddn_file2)
        CALL text((roddn_currow+ 2),4,roddn_file3)
        SET roddn_currow = (roddn_currow+ 4)
       OF "AXP":
        CALL text(roddn_currow,4,roddn_file1)
        CALL text((roddn_currow+ 1),4,roddn_file2)
        SET roddn_currow = (roddn_currow+ 3)
      ENDCASE
      IF (roddn_msg != " ")
       CALL text(20,1,roddn_msg)
      ENDIF
      SET dm_err->eproc = "Prompt user for completion of steps"
      CALL text(roddn_currow,1,
       "Upon completion of these steps, enter 'C' to continue or 'Q' to quit:")
      CALL accept(roddn_currow,72,"p;cu","C"
       WHERE curaccept IN ("C", "Q"))
      SET message = nowindow
      CALL clear(1,1)
      IF (curaccept="Q")
       SET dm_err->emsg = "User chose to quit from remote node steps. Cannot continue"
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      SET roddn_found = 1
      SET dm_err->eproc = "Validate OS files containing disk information exist in CCLUSERDIR."
      IF ((dm_err->debug_flag > 0))
       CALL disp_msg("",dm_err->logfile,0)
      ENDIF
      CASE (dm2_sys_misc->cur_db_os)
       OF "HPX":
        IF (findfile(concat("ccluserdir:",roddn_file1))=0)
         SET roddn_found = 0
         SET dm_err->emsg = concat("File not found:",roddn_file1)
         SET dm_err->user_action = "Please copy file from remote node into CCLUSERDIR"
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ENDIF
       OF "AIX":
        IF (findfile(concat("ccluserdir:",roddn_file1))=0)
         SET roddn_found = 0
         SET dm_err->emsg = concat("File not found:",roddn_file1)
         SET dm_err->user_action = "Please copy file from remote node into CCLUSERDIR"
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ENDIF
        IF (findfile(concat("ccluserdir:",roddn_file2))=0)
         SET roddn_found = 0
         SET dm_err->emsg = concat("File not found:",roddn_file2)
         SET dm_err->user_action = "Please copy file from remote node into CCLUSERDIR"
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ENDIF
        IF (findfile(concat("ccluserdir:",roddn_file3))=0)
         SET roddn_found = 0
         SET dm_err->emsg = concat("File not found:",roddn_file3)
         SET dm_err->user_action = "Please copy file from remote node into CCLUSERDIR"
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ENDIF
       OF "AXP":
        IF (findfile(concat("ccluserdir:",roddn_file1))=0)
         SET roddn_found = 0
         SET dm_err->emsg = concat("File not found:",roddn_file1)
         SET dm_err->user_action = "Please copy file from remote node into CCLUSERDIR"
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ENDIF
        IF (findfile(concat("ccluserdir:",roddn_file2))=0)
         SET roddn_found = 0
         SET dm_err->emsg = concat("File not found:",roddn_file2)
         SET dm_err->user_action = "Please copy file from remote node into CCLUSERDIR"
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ENDIF
      ENDCASE
      IF (roddn_found=0)
       SET roddn_msg =
       "One or more of the above files were not found in CCLUSERDIR, please scroll up to view missing files."
      ENDIF
    ENDWHILE
   ENDIF
   CASE (dm2_sys_misc->cur_db_os)
    OF "AXP":
     IF (dos_get_sys_dev(roddn_file2)=0)
      RETURN(0)
     ENDIF
     IF (dm2_parse_mnt_disk_info_axp(roddn_file1)=0)
      RETURN(0)
     ENDIF
    OF "AIX":
     IF ( NOT (dm2_parse_aix_vg_disk_file(roddn_file1)))
      RETURN(0)
     ENDIF
     IF (dos_get_lv_for_pv(roddn_file2)=0)
      RETURN(0)
     ENDIF
     IF (dos_get_mwc_value(roddn_file3,0)=0)
      RETURN(0)
     ELSE
      FOR (roddn_cnt = 1 TO size(rdisk->qual,5))
       SET roddn_ndx = locateval(roddn_ndx,1,size(pv_mwc_list->pv,5),rdisk->qual[roddn_cnt].disk_name,
        pv_mwc_list->pv[roddn_ndx].pv_name)
       SET rdisk->qual[roddn_cnt].mwc_flag = pv_mwc_list->pv[roddn_ndx].mwc_flag
      ENDFOR
     ENDIF
    OF "HPX":
     IF (dm2_parse_hpux_disk_file(roddn_file1)=0)
      RETURN(0)
     ENDIF
   ENDCASE
   SET message = window
   RETURN(1)
 END ;Subroutine
 SUBROUTINE display_filegroup_preview(null)
   CALL ts_inform("in display_filegroup_preview")
   DECLARE indx = i4 WITH protect, noconstant(0)
   DECLARE rtspace_cnt = i4 WITH protect, noconstant(0)
   DECLARE display_row = i4 WITH protect, noconstant(0)
   SET rtspace_cnt = size(rtspace->qual,5)
   SELECT
    FROM dual
    DETAIL
     "Filegroup Preview", row + 1, "-----------------",
     row + 1, row + 1, "The following is a list of filegroups that will be created on your system",
     row + 1, display_row = 0
     FOR (indx = 1 TO rtspace_cnt)
       IF ((rtspace->qual[indx].new_ind=1))
        display_row = (display_row+ 1), row + 1, col 3,
        display_row, ". ", rtspace->qual[indx].tspace_name
       ENDIF
     ENDFOR
    WITH nocounter
   ;end select
   IF (check_error(concat("display_filegroup_preview")) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE filegroup_paths_entry(null)
   CALL ts_inform("in filegroup_paths_entry")
   DECLARE screen_2_done = i2 WITH protect, noconstant(0)
   DECLARE good_path_ind = i2 WITH protect, noconstant(0)
   DECLARE path_entered = vc WITH protect, noconstant("")
   CALL display_filegroup_paths(null)
   SET max_disk = 0
   SET curline = 0
   SET screen_2_done = false
   WHILE (screen_2_done=false)
     CALL text(23,3,"Add/Delete/Cancel/Ok (A/D/C/K):")
     CALL accept(23,34,"p;cus","A"
      WHERE curaccept IN ("A", "D", "C", "K"))
     CASE (curaccept)
      OF "C":
       SET dm_err->emsg = "User cancelled the process"
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      OF "A":
       IF (((max_disk+ 1) > cmaxline))
        CALL text(24,3,"Maximum filegroup file paths have been entered")
       ELSE
        SET max_disk = (max_disk+ 1)
        SET good_path_ind = false
        WHILE (good_path_ind=false)
          CALL clear((max_disk+ cheadlines),3,130)
          CALL text((max_disk+ cheadlines),3,concat(trim(cnvtstring(max_disk)),". "))
          SET accept = nopatcheck
          CALL accept((max_disk+ cheadlines),6,"P(100);cu","")
          SET path_entered = ""
          SET path_entered = curaccept
          IF (path_entered != "")
           IF (substring(size(trim(path_entered)),1,path_entered) != "\")
            SET path_entered = concat(path_entered,"\")
           ENDIF
           CASE (verify_path_names(path_entered))
            OF 0:
             RETURN(0)
            OF 1:
             SET stat = alterlist(rdisk->qual,max_disk)
             SET rdisk->qual[max_disk].disk_name = path_entered
             SET good_path_ind = true
             CALL display_filegroup_paths(null)
            OF 2:
             CALL text(24,3,
              "Disk specified cannot be on the same drive as the primary or log filegroups")
           ENDCASE
          ELSE
           CALL clear((max_disk+ cheadlines),3,130)
           SET max_disk = (max_disk - 1)
           SET good_path_ind = true
          ENDIF
        ENDWHILE
       ENDIF
      OF "D":
       CALL clear(24,3,130)
       CALL clear(23,3,130)
       CALL text(23,4,"Row Number to delete: ")
       CALL accept(23,25,"9(2);",0
        WHERE curaccept >= 0)
       IF (curaccept > 0)
        IF (curaccept > max_disk)
         CALL text(24,3,"Row number entered is out of range")
        ELSE
         SET deltx = curaccept
         FOR (x = deltx TO (max_disk - 1))
          SET rdisk->qual[x].disk_name = ""
          SET rdisk->qual[x].disk_name = rdisk->qual[(x+ 1)].disk_name
         ENDFOR
         SET max_disk = (max_disk - 1)
         SET stat = alterlist(rdisk->qual,max_disk)
         CALL display_filegroup_paths(null)
        ENDIF
       ENDIF
      OF "K":
       IF (max_disk > 0)
        SET screen_2_done = true
       ELSE
        CALL text(24,3,"At least one filegroup file path required")
       ENDIF
     ENDCASE
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE verify_path_names(vpn_path_name)
   CALL ts_inform("in verify_path_names")
   DECLARE tspace_fnd_ind = i2 WITH protect, noconstant(0)
   SELECT INTO ":nl"
    df.file_name
    FROM dm2_dba_data_files df
    WHERE df.tablespace_name IN ("PRIMARY", "LOG")
    DETAIL
     IF (cnvtupper(substring(1,1,df.file_name))=cnvtupper(substring(1,1,vpn_path_name)))
      tspace_fnd_ind = true
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(concat("verify_path_names")) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (tspace_fnd_ind=true)
    RETURN(2)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE display_filegroup_paths(null)
   CALL ts_inform("in display_filegroup_paths")
   DECLARE diskx = i4 WITH protect, noconstant(0)
   CALL clear(1,1)
   CALL text(1,2,"SPECIFY DATA/INDEX FILEGROUP FILE PATHS",w)
   CALL text(3,1,"Notes: 1. Paths specified must already exist.")
   CALL text(4,1,"       2. Every data/index filegroup will have one file on each path specified.")
   CALL box(cheadlines,1,((cheadlines+ cmaxline)+ 1),132)
   SET diskx = 1
   FOR (diskx = 1 TO max_disk)
    CALL text((diskx+ cheadlines),3,concat(trim(cnvtstring(diskx)),". "))
    CALL text((diskx+ cheadlines),6,rdisk->qual[diskx].disk_name)
   ENDFOR
 END ;Subroutine
 SUBROUTINE filegroup_parameters_entry(null)
   CALL ts_inform("in filegroup_parameters_entry")
   DECLARE indx = i4 WITH protect, noconstant(0)
   DECLARE rtspace_cnt = i4 WITH protect, noconstant(0)
   CALL clear(1,1)
   CALL text(2,2,"SPECIFY DATA/INDEX FILEGROUP FILE PARAMETERS",w)
   CALL box(3,1,21,132)
   SET rtspace->sql_size_mb = 2
   SET rtspace->sql_filegrowth_mb = 10
   CALL text(10,10,"1. SIZE:          2 MB")
   CALL text(11,10,"2. FILEGROWTH:   10 MB")
   CALL text(23,3,"Edit/Cancel/Ok (E/C/K):")
   SET screen_3_done_ind = false
   WHILE (screen_3_done_ind=false)
    CALL accept(23,27,"p;cus","K"
     WHERE curaccept IN ("E", "C", "K"))
    CASE (curaccept)
     OF "E":
      CALL accept(10,24,"9(6);",rtspace->sql_size_mb
       WHERE curaccept >= 0)
      SET rtspace->sql_size_mb = curaccept
      CALL accept(11,24,"9(6);",rtspace->sql_filegrowth_mb
       WHERE curaccept >= 0)
      SET rtspace->sql_filegrowth_mb = curaccept
     OF "C":
      SET dm_err->emsg = "User cancelled the process"
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     OF "K":
      IF ((rtspace->sql_size_mb > 0)
       AND (rtspace->sql_filegrowth_mb > 0))
       SET screen_3_done_ind = true
      ELSE
       CALL text(24,3,"Size and/or Filegrowth require values")
      ENDIF
    ENDCASE
   ENDWHILE
   RETURN(1)
 END ;Subroutine
#exit_program
 SET message = nowindow
 IF ((dm_err->debug_flag >= 1))
  CALL echorecord(rtspace)
  CALL echorecord(rdisk)
  CALL echorecord(hold_datafile)
  CALL echorecord(dm2_sys_misc)
 ENDIF
 IF ((dm_err->err_ind=0))
  SET dm_err->eproc = "DM2_TSPACE_MENU has Completed."
 ENDIF
 CALL final_disp_msg("dm2_tspace_menu")
 FREE RECORD hold_datafile
 FREE RECORD tspace_type
 FREE RECORD rd_pp_sizes
 FREE RECORD tspace_screen
 FREE RECORD ap_spread_rs
 FREE RECORD ncont_screen
END GO
