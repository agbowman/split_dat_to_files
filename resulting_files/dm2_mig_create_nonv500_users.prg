CREATE PROGRAM dm2_mig_create_nonv500_users
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
 DECLARE dcdur_create_db_users(null) = i2
 DECLARE dcdur_report_db_users_diff_tspaces(null) = i2
 DECLARE dcdur_cleanup_pwds(dcp_in_dbname=vc) = i2
 DECLARE dcdur_insert_pwds(dip_in_dbname=vc,dip_in_type=vc,dip_in_user=vc,dip_in_pwd=vc) = i2
 DECLARE dcdur_preserve_pwds(dpp_in_dbname=vc) = i2
 DECLARE dcdur_restore_pwds(drp_in_dbname=vc,drp_in_mode=vc) = i2
 DECLARE dcdur_get_server_users_pwds(dgsup_in_domain=vc) = i2
 DECLARE dcdur_prompt_tspaces(dpt_user_name=vc,dpt_db_name=vc,dpt_user_idx=i4(ref)) = i2
 DECLARE dcdur_user_tspace_cleanup(dutc_user_name=vc,dutc_db_name=vc) = i2
 DECLARE dcdur_user_tspace_load(dutl_db_name=vc) = i2
 DECLARE dcdur_insert_admin_tspace_rows(diatr_user_name=vc,diatr_db_name=vc,diatr_temp_ts=vc,
  diatr_misc_ts=vc) = i2
 DECLARE dcdur_get_db_owner_pwds(dgdop_in_dbname=vc) = i2
 IF (validate(dcdur_input->src_user,"ABC")="ABC"
  AND validate(dcdur_input->src_user,"XYZ")="XYZ")
  FREE RECORD dcdur_input
  RECORD dcdur_input(
    1 src_user = vc
    1 src_pwd = vc
    1 src_cnct_str = vc
    1 tgt_user = vc
    1 tgt_pwd = vc
    1 tgt_cnct_str = vc
    1 user_list = vc
    1 fix_tspaces_ind = c1
    1 default_tspace = vc
    1 temp_tspace = vc
    1 tgt_dbname = vc
    1 connect_back = c1
    1 replace_tspaces = c1
    1 replace_pwds = c1
  )
  SET dcdur_input->src_user = ""
  SET dcdur_input->src_user = ""
  SET dcdur_input->src_pwd = ""
  SET dcdur_input->src_cnct_str = ""
  SET dcdur_input->tgt_user = ""
  SET dcdur_input->tgt_pwd = ""
  SET dcdur_input->tgt_cnct_str = ""
  SET dcdur_input->fix_tspaces_ind = ""
  SET dcdur_input->default_tspace = ""
  SET dcdur_input->default_tspace = ""
  SET dcdur_input->user_list = ""
  SET dcdur_input->tgt_dbname = ""
  SET dcdur_input->connect_back = ""
  SET dcdur_input->replace_tspaces = ""
  SET dcdur_input->replace_pwds = ""
 ENDIF
 IF (validate(dcdur_server_pwds->cnt,1)=1
  AND validate(dcdur_server_pwds->cnt,2)=2)
  FREE RECORD dcdur_server_pwds
  RECORD dcdur_server_pwds(
    1 cnt = i4
    1 qual[*]
      2 server = i4
      2 user = vc
      2 pwd = vc
  )
  SET dcdur_server_pwds->cnt = 0
 ENDIF
 IF (validate(dcdur_owner_pwds->cnt,1)=1
  AND validate(dcdur_owner_pwds->cnt,2)=2)
  FREE RECORD dcdur_owner_pwds
  RECORD dcdur_owner_pwds(
    1 cnt = i4
    1 qual[*]
      2 type = vc
      2 owner = vc
      2 pwd = vc
  )
  SET dcdur_owner_pwds->cnt = 0
 ENDIF
 IF (validate(dcdur_cmds->cnt,1)=1
  AND validate(dcdur_cmds->cnt,2)=2)
  FREE RECORD dcdur_cmds
  RECORD dcdur_cmds(
    1 cnt = i4
    1 qual[*]
      2 type = vc
      2 name = vc
      2 command = vc
      2 owner = vc
      2 default_tspace = vc
      2 temp_tspace = vc
      2 pwd = vc
      2 default_tspace_quota = vc
  )
  SET dcdur_cmds->cnt = 0
 ENDIF
 IF (validate(dcdur_user_data->misc_tspace_default,"X")="X"
  AND validate(dcdur_user_data->misc_tspace_default,"Y")="Y")
  FREE RECORD dcdur_user_data
  RECORD dcdur_user_data(
    1 misc_tspace_default = vc
    1 temp_tspace_default = vc
    1 misc_tspace_force = vc
    1 temp_tspace_force = vc
    1 user_cnt = i4
    1 users[*]
      2 user = vc
      2 misc_tspace = vc
      2 temp_tspace = vc
    1 tgt_sys_user = vc
    1 tgt_sys_pwd = vc
    1 create_user_method = vc
  )
  SET dcdur_user_data->misc_tspace_default = "DM2NOTSET"
  SET dcdur_user_data->temp_tspace_default = "DM2NOTSET"
  SET dcdur_user_data->misc_tspace_force = "DM2NOTSET"
  SET dcdur_user_data->temp_tspace_force = "DM2NOTSET"
  SET dcdur_user_data->tgt_sys_user = "SYS"
  SET dcdur_user_data->tgt_sys_pwd = "DM2NOTSET"
  SET dcdur_user_data->create_user_method = "DM2NOTSET"
  SET dcdur_user_data->user_cnt = 0
 ENDIF
 SUBROUTINE dcdur_create_db_users(null)
   DECLARE dcdu_iter = i4 WITH protect, noconstant(0)
   DECLARE dcdu_beg = i2 WITH protect, noconstant(0)
   DECLARE dcdu_end = i2 WITH protect, noconstant(0)
   DECLARE dcdu_str = vc WITH protect, noconstant(" ")
   DECLARE dcdu_grant_ptr = i2 WITH protect, noconstant(1)
   DECLARE dcdu_start_ptr = i2 WITH protect, noconstant(0)
   DECLARE dcdu_ndx = i4 WITH protect, noconstant(0)
   DECLARE dcdu_index1 = i2 WITH protect, noconstant(0)
   DECLARE dcdu_index2 = i2 WITH protect, noconstant(0)
   DECLARE dcdu_parse_cmd = vc WITH protect, noconstant("")
   DECLARE dcdu_cmd_string = vc WITH protect, noconstant("")
   DECLARE dcdu_where_clause = vc WITH protect, noconstant("")
   DECLARE dcdu_cmd_str_length = i4 WITH protect, noconstant(0)
   DECLARE dcdu_user_list = vc WITH protect, noconstant("")
   DECLARE dcdu_fix_tspaces_ind = i2 WITH protect, noconstant(0)
   DECLARE dcdu_replace_from = vc WITH protect, noconstant("")
   DECLARE dcdu_replace_to = vc WITH protect, noconstant("")
   DECLARE dcdu_func_owner = vc WITH protect, noconstant("")
   DECLARE dcdu_func_name = vc WITH protect, noconstant("")
   DECLARE dcdu_create_ind = i2 WITH protect, noconstant(0)
   DECLARE dcdu_idx = i4 WITH protect, noconstant(0)
   DECLARE dcdu_db_user_pwd = vc WITH protect, noconstant("")
   DECLARE dcdu_default_tspace = vc WITH protect, noconstant("")
   DECLARE dcdu_role_where_clause = vc WITH protect, noconstant("")
   DECLARE dcdu_adb_ind = i2 WITH protect, noconstant(0)
   DECLARE dcdu_owner = vc WITH protect, noconstant("")
   FREE RECORD dcdu_orauser
   RECORD dcdu_orauser(
     1 cnt = i4
     1 qual[*]
       2 user = vc
       2 default_tspace = vc
       2 temp_tspace = vc
       2 dt_fix_ind = i2
       2 tt_fix_ind = i2
   )
   FREE RECORD dcdu_tspaces
   RECORD dcdu_tspaces(
     1 cnt = i4
     1 qual[*]
       2 tspace_name = vc
   )
   SET dcdur_cmds->cnt = 0
   SET stat = alterlist(dcdur_cmds->qual,0)
   SET dcdur_input->connect_back = "N"
   IF (dm2_adb_check("",dcdu_adb_ind)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Creating database users and all dependent objects."
   CALL disp_msg("",dm_err->logfile,0)
   IF (((size(trim(dcdur_input->src_user))=0) OR (((size(trim(dcdur_input->src_pwd))=0) OR (((size(
    trim(dcdur_input->src_cnct_str))=0) OR (((size(trim(dcdur_input->tgt_user))=0) OR (((size(trim(
     dcdur_input->tgt_pwd))=0) OR (((size(trim(dcdur_input->tgt_cnct_str))=0) OR ((( NOT ((
   dcdur_input->replace_tspaces IN ("Y", "N")))) OR ((( NOT ((dcdur_input->replace_pwds IN ("Y", "N")
   ))) OR ((( NOT ((dcdur_input->fix_tspaces_ind IN ("Y", "N")))) OR ((((dcdur_input->fix_tspaces_ind
   ="Y")
    AND size(trim(dcdur_input->default_tspace))=0) OR ((((dcdur_input->fix_tspaces_ind="Y")
    AND size(trim(dcdur_input->temp_tspace))=0) OR (((trim(dcdur_input->user_list)="") OR (findstring
   ("(",dcdur_input->user_list,1) > 0)) )) )) )) )) )) )) )) )) )) )) )) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating input variables."
    SET dm_err->emsg = "Invalid input."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dcdur_input)
    ENDIF
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcdur_input)
   ENDIF
   SET dm_err->eproc = concat("Using DBMS_METADATA method to create [",trim(dcdur_input->user_list),
    "] users.")
   CALL disp_msg("",dm_err->logfile,0)
   SET dcdur_input->connect_back = "Y"
   SET dm2_force_connect_string = 1
   SET dm2_install_schema->dbase_name = '"SOURCE"'
   SET dm2_install_schema->u_name = dcdur_input->src_user
   SET dm2_install_schema->p_word = dcdur_input->src_pwd
   SET dm2_install_schema->connect_str = dcdur_input->src_cnct_str
   EXECUTE dm2_connect_to_dbase "CO"
   SET dm2_force_connect_string = 0
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET stat = alterlist(dcdu_orauser->qual,0)
   SET dcdu_orauser->cnt = 0
   IF ((dcdur_input->fix_tspaces_ind="Y"))
    SET dm_err->eproc = "Retrieve list of Source custom database users based on defined user list."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dba_users du
     WHERE parser(concat("du.username in (",dcdur_input->user_list,")"))
     ORDER BY du.username
     DETAIL
      dcdu_orauser->cnt = (dcdu_orauser->cnt+ 1), stat = alterlist(dcdu_orauser->qual,dcdu_orauser->
       cnt), dcdu_orauser->qual[dcdu_orauser->cnt].user = du.username,
      dcdu_orauser->qual[dcdu_orauser->cnt].default_tspace = du.default_tablespace, dcdu_orauser->
      qual[dcdu_orauser->cnt].temp_tspace = du.temporary_tablespace, dcdu_orauser->qual[dcdu_orauser
      ->cnt].dt_fix_ind = 0,
      dcdu_orauser->qual[dcdu_orauser->cnt].tt_fix_ind = 0
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dcdu_orauser)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Check for role exclusion list override."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    d.info_name
    FROM dm_info d
    WHERE info_domain="DM2_ROLE_EXLUSION_LIST_OVERRIDE"
    DETAIL
     dcdu_where_clause = concat("r.grantee not in(",d.info_name,")")
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dcdu_where_clause <= "")
    SET dcdu_where_clause = concat(
     "r.grantee not in('CONNECT','RESOURCE','DBA','EXP_FULL_DATABASE','IMP_FULL_DATABASE',",
     "'DELETE_CATALOG_ROLE','EXECUTE_CATALOG_ROLE','SELECT_CATALOG_ROLE',",
     "'RECOVERY_CATALOG_OWNER','HS_ADMIN_ROLE','AQ_USER_ROLE','AQ_ADMINISTRATOR_ROLE',",
     "'SNMPAGENT','SCHEDULER_ADMIN')")
   ENDIF
   IF (dm2_push_cmd(concat(
     "rdb asis(^begin DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,",
     "'SQLTERMINATOR',TRUE); end;^) go"),1)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Retrieve Source DDL to create Functions, Profiles, Users, Roles and Grants."
   CALL disp_msg("",dm_err->logfile,0)
   IF ((validate(dm2_bypass_get_pwd_function_ddl,- (1))=- (1)))
    SET dm_err->eproc = concat(
     "Get all Source dependent functions' DDL used in the PASSWORD_VERIFY_FUNCTION function ",
     "of profiles for user(s) specified.")
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_DDL('FUNCTION', dp.referenced_name, dp.referenced_owner)")
       FROM (
        (
        (SELECT DISTINCT
         d.referenced_name, d.referenced_owner
         FROM dba_profiles p,
          dba_objects o,
          dba_dependencies d
         WHERE ((p.profile="DEFAULT") OR (p.profile IN (
         (SELECT
          du.profile
          FROM dba_users du
          WHERE parser(concat("du.username in (",dcdur_input->user_list,")"))))))
          AND p.resource_name="PASSWORD_VERIFY_FUNCTION"
          AND  NOT (p.limit IN ("DEFAULT", "NULL"))
          AND p.limit=o.object_name
          AND o.object_type="FUNCTION"
          AND o.object_name=d.name
          AND d.referenced_type="FUNCTION"
         WITH sqltype("C32000")))
        dp)
       WHERE 1=1
       WITH sqltype("C32000")))
      a)
     DETAIL
      dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
      dcdu_parse_cmd = replace(trim(a.x,3),"/","",2),
      dcdu_beg = (findstring('"',dcdu_parse_cmd,1,0)+ 1), dcdu_end = findstring('"',dcdu_parse_cmd,
       dcdu_beg,0), dcdur_cmds->qual[dcdur_cmds->cnt].owner = substring(dcdu_beg,(dcdu_end - dcdu_beg
       ),dcdu_parse_cmd),
      dcdu_beg = 0, dcdu_beg = (findstring('"',dcdu_parse_cmd,(dcdu_end+ 1),0)+ 1), dcdu_end = 0,
      dcdu_end = findstring('"',dcdu_parse_cmd,dcdu_beg,0), dcdur_cmds->qual[dcdur_cmds->cnt].name =
      substring(dcdu_beg,(dcdu_end - dcdu_beg),dcdu_parse_cmd), dcdur_cmds->qual[dcdur_cmds->cnt].
      type = "FUNCTION",
      dcdur_cmds->qual[dcdur_cmds->cnt].command = dcdu_parse_cmd
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
    SET dm_err->eproc = concat(
     "Get all Source PASSWORD_VERIFY_FUNCTION functions' DDL used during create ",
     "profile for user(s) specified.")
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_DDL('FUNCTION', dp.object_name, dp.owner)")
       FROM (
        (
        (SELECT DISTINCT
         o.object_name, o.owner
         FROM dba_profiles p,
          dba_objects o
         WHERE p.profile != "DEFAULT"
          AND p.profile IN (
         (SELECT
          d.profile
          FROM dba_users d
          WHERE parser(concat("d.username in (",dcdur_input->user_list,")"))))
          AND p.resource_name="PASSWORD_VERIFY_FUNCTION"
          AND  NOT (p.limit IN ("DEFAULT", "NULL"))
          AND p.limit=o.object_name
          AND o.object_type="FUNCTION"
         WITH sqltype("C32000")))
        dp)
       WHERE 1=1
       WITH sqltype("C32000")))
      a)
     DETAIL
      dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
      dcdu_parse_cmd = replace(trim(a.x,3),"/","",2),
      dcdu_beg = (findstring('"',dcdu_parse_cmd,1,0)+ 1), dcdu_end = findstring('"',dcdu_parse_cmd,
       dcdu_beg,0), dcdur_cmds->qual[dcdur_cmds->cnt].owner = substring(dcdu_beg,(dcdu_end - dcdu_beg
       ),dcdu_parse_cmd),
      dcdu_beg = 0, dcdu_beg = (findstring('"',dcdu_parse_cmd,(dcdu_end+ 1),0)+ 1), dcdu_end = 0,
      dcdu_end = findstring('"',dcdu_parse_cmd,dcdu_beg,0), dcdur_cmds->qual[dcdur_cmds->cnt].name =
      substring(dcdu_beg,(dcdu_end - dcdu_beg),dcdu_parse_cmd), dcdur_cmds->qual[dcdur_cmds->cnt].
      type = "FUNCTION",
      dcdur_cmds->qual[dcdur_cmds->cnt].command = dcdu_parse_cmd
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
   ENDIF
   IF ((validate(dm2_bypass_get_profiles_ddl,- (1))=- (1)))
    SET dm_err->eproc = "Get Source create/alter profile DDL for user(s) specified."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_DDL('PROFILE', dp.profile)")
       FROM (
        (
        (SELECT DISTINCT
         p.profile
         FROM dba_profiles p
         WHERE ((p.profile="DEFAULT") OR (p.profile IN (
         (SELECT
          d.profile
          FROM dba_users d
          WHERE parser(concat("d.username in (",dcdur_input->user_list,")"))))))
         WITH sqltype("C32000")))
        dp)
       WHERE 1=1
       WITH sqltype("C32000")))
      a)
     DETAIL
      dcdu_grant_ptr = 1, dcdu_start_ptr = 1
      IF (findstring(";",trim(a.x,3),dcdu_start_ptr) > 0)
       dcdu_cmd_string = replace(replace(replace(trim(a.x,3),char(0),""),char(10),""),char(13),""),
       dcdu_index1 = 0, dcdu_index1 = locateval(dcdu_index1,1,dcdur_cmds->cnt,dcdu_cmd_string,
        dcdur_cmds->qual[dcdu_index1].command)
       IF (dcdu_index1=0)
        dcdu_cmd_str_length = textlen(dcdu_cmd_string)
        WHILE (dcdu_grant_ptr > 0)
          dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),dcdu_start_ptr), dcdu_parse_cmd =
          replace(trim(substring(dcdu_start_ptr,((dcdu_grant_ptr - dcdu_start_ptr)+ 1),
             dcdu_cmd_string),3),";","",0), dcdu_index2 = 0,
          dcdu_index2 = locateval(dcdu_index2,1,dcdur_cmds->cnt,dcdu_parse_cmd,dcdur_cmds->qual[
           dcdu_index2].command)
          IF (dcdu_index2=0)
           dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
           dcdu_beg = (findstring('"',dcdu_parse_cmd,1,0)+ 1),
           dcdu_end = findstring('"',dcdu_parse_cmd,dcdu_beg,0), dcdur_cmds->qual[dcdur_cmds->cnt].
           name = substring(dcdu_beg,(dcdu_end - dcdu_beg),dcdu_parse_cmd), dcdur_cmds->qual[
           dcdur_cmds->cnt].type = "PROFILE",
           dcdur_cmds->qual[dcdur_cmds->cnt].command = dcdu_parse_cmd
          ENDIF
          dcdu_start_ptr = (dcdu_grant_ptr+ 1)
          IF (dcdu_start_ptr >= dcdu_cmd_str_length)
           dcdu_grant_ptr = 0
          ENDIF
        ENDWHILE
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
   ENDIF
   IF ((validate(dm2_bypass_get_users_ddl,- (1))=- (1)))
    SET dm_err->eproc = "Get Source create user DDL for user(s) specified."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_DDL('USER', USERNAME)")
       FROM dba_users u
       WHERE parser(concat("u.username in (",dcdur_input->user_list,")"))
       WITH sqltype("C32000")))
      a)
     DETAIL
      IF ((dm_err->debug_flag > 4))
       CALL echo(concat("x = ",a.x))
      ENDIF
      dcdu_grant_ptr = 1, dcdu_start_ptr = 1
      IF (findstring(";",trim(a.x,3),dcdu_start_ptr) > 0)
       dcdu_cmd_string = replace(replace(replace(trim(a.x,3),char(0),""),char(10),""),char(13),"")
       IF ((dm_err->debug_flag > 4))
        CALL echo(concat("dcdu_cmd_string = ",dcdu_cmd_string))
       ENDIF
       dcdu_index1 = 0, dcdu_index1 = locateval(dcdu_index1,1,dcdur_cmds->cnt,dcdu_cmd_string,
        dcdur_cmds->qual[dcdu_index1].command)
       IF (dcdu_index1=0)
        dcdu_cmd_str_length = textlen(dcdu_cmd_string)
        WHILE (dcdu_grant_ptr > 0)
          dcdu_beg = findstring("IDENTIFIED BY VALUES '",dcdu_cmd_string,dcdu_start_ptr)
          IF ((dm_err->debug_flag > 4))
           CALL echo(build("dcdu_beg =",dcdu_beg))
          ENDIF
          IF (dcdu_beg > 0)
           dcdu_end = findstring("'",dcdu_cmd_string,(dcdu_beg+ 22))
           IF ((dm_err->debug_flag > 4))
            CALL echo(build("dcdu_end =",dcdu_end))
           ENDIF
           dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),(dcdu_end+ 1))
          ELSE
           dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),dcdu_start_ptr)
          ENDIF
          IF ((dm_err->debug_flag > 4))
           CALL echo(build("dcdu_grant_ptr =",dcdu_grant_ptr)),
           CALL echo(build("dcdu_start_ptr =",dcdu_start_ptr))
          ENDIF
          dcdu_parse_cmd = replace(trim(substring(dcdu_start_ptr,((dcdu_grant_ptr - dcdu_start_ptr)+
             1),dcdu_cmd_string),3),";","",2)
          IF ((dm_err->debug_flag > 4))
           CALL echo(concat("dcdu_parse_cmd = ",dcdu_parse_cmd))
          ENDIF
          dcdu_index2 = 0, dcdu_index2 = locateval(dcdu_index2,1,dcdur_cmds->cnt,dcdu_parse_cmd,
           dcdur_cmds->qual[dcdu_index2].command)
          IF ((dm_err->debug_flag > 4))
           CALL echo(build("dcdu_index2 = ",dcdu_index2))
          ENDIF
          IF (dcdu_index2=0)
           dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
           dcdu_beg = (findstring('"',dcdu_parse_cmd,1,0)+ 1),
           dcdu_end = findstring('"',dcdu_parse_cmd,dcdu_beg,0), dcdur_cmds->qual[dcdur_cmds->cnt].
           name = substring(dcdu_beg,(dcdu_end - dcdu_beg),dcdu_parse_cmd), dcdur_cmds->qual[
           dcdur_cmds->cnt].owner = dcdur_cmds->qual[dcdur_cmds->cnt].name,
           dcdur_cmds->qual[dcdur_cmds->cnt].type = "USER", dcdur_cmds->qual[dcdur_cmds->cnt].command
            = dcdu_parse_cmd
           IF (findstring("DEFAULT TABLESPACE",dcdur_cmds->qual[dcdur_cmds->cnt].command,
            dcdu_start_ptr) > 0)
            dcdur_cmds->qual[dcdur_cmds->cnt].default_tspace = substring((findstring(
              "DEFAULT TABLESPACE",dcdur_cmds->qual[dcdur_cmds->cnt].command,dcdu_start_ptr)+ 20),(
             findstring('"',dcdur_cmds->qual[dcdur_cmds->cnt].command,((findstring(
               "DEFAULT TABLESPACE",dcdur_cmds->qual[dcdur_cmds->cnt].command,dcdu_start_ptr)+ 20)+ 1
              )) - (findstring("DEFAULT TABLESPACE",dcdur_cmds->qual[dcdur_cmds->cnt].command,
              dcdu_start_ptr)+ 20)),dcdur_cmds->qual[dcdur_cmds->cnt].command)
           ENDIF
           IF (findstring("TEMPORARY TABLESPACE",dcdur_cmds->qual[dcdur_cmds->cnt].command,
            dcdu_start_ptr) > 0)
            dcdur_cmds->qual[dcdur_cmds->cnt].temp_tspace = substring((findstring(
              "TEMPORARY TABLESPACE",dcdur_cmds->qual[dcdur_cmds->cnt].command,dcdu_start_ptr)+ 22),(
             findstring('"',dcdur_cmds->qual[dcdur_cmds->cnt].command,((findstring(
               "TEMPORARY TABLESPACE",dcdur_cmds->qual[dcdur_cmds->cnt].command,dcdu_start_ptr)+ 22)
              + 1)) - (findstring("TEMPORARY TABLESPACE",dcdur_cmds->qual[dcdur_cmds->cnt].command,
              dcdu_start_ptr)+ 22)),dcdur_cmds->qual[dcdur_cmds->cnt].command)
           ENDIF
           IF (findstring("IDENTIFIED BY VALUES '",dcdur_cmds->qual[dcdur_cmds->cnt].command,
            dcdu_start_ptr) > 0)
            dcdur_cmds->qual[dcdur_cmds->cnt].pwd = substring((findstring("IDENTIFIED BY VALUES '",
              dcdur_cmds->qual[dcdur_cmds->cnt].command,dcdu_start_ptr)+ 22),(findstring("'",
              dcdur_cmds->qual[dcdur_cmds->cnt].command,((findstring("IDENTIFIED BY VALUES '",
               dcdur_cmds->qual[dcdur_cmds->cnt].command,dcdu_start_ptr)+ 22)+ 1)) - (findstring(
              "IDENTIFIED BY VALUES '",dcdur_cmds->qual[dcdur_cmds->cnt].command,dcdu_start_ptr)+ 22)
             ),dcdur_cmds->qual[dcdur_cmds->cnt].command)
           ENDIF
          ENDIF
          dcdu_start_ptr = (dcdu_grant_ptr+ 1)
          IF (dcdu_start_ptr >= dcdu_cmd_str_length)
           dcdu_grant_ptr = 0
          ENDIF
        ENDWHILE
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
   ENDIF
   SET dcdu_role_where_clause = " 1=1 "
   IF ((dm2_rdbms_version->level1 > 11))
    SET dcdu_role_where_clause = " u.COMMON='NO' "
   ENDIF
   IF ((validate(dm2_bypass_get_roles_ddl,- (1))=- (1)))
    SET dm_err->eproc = "Get all Source create role DDL (i.e. create role <role>)."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_DDL('ROLE', ROLE)")
       FROM dba_roles u
       WHERE parser(dcdu_role_where_clause)
       WITH sqltype("C32000")))
      a)
     DETAIL
      dcdu_grant_ptr = 1, dcdu_start_ptr = 1
      IF (findstring(";",trim(a.x,3),dcdu_start_ptr) > 0)
       dcdu_cmd_string = replace(replace(replace(trim(a.x,3),char(0),""),char(10),""),char(13),""),
       dcdu_index1 = 0, dcdu_index1 = locateval(dcdu_index1,1,dcdur_cmds->cnt,dcdu_cmd_string,
        dcdur_cmds->qual[dcdu_index1].command)
       IF (dcdu_index1=0)
        dcdu_cmd_str_length = textlen(dcdu_cmd_string)
        WHILE (dcdu_grant_ptr > 0)
          dcdu_beg = findstring("IDENTIFIED BY VALUES '",dcdu_cmd_string,dcdu_start_ptr)
          IF (dcdu_beg > 0)
           dcdu_end = findstring("'",dcdu_cmd_string,(dcdu_beg+ 22))
           IF ((dm_err->debug_flag > 4))
            CALL echo(build("dcdu_end =",dcdu_end))
           ENDIF
           dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),(dcdu_end+ 1))
          ELSE
           dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),dcdu_start_ptr)
          ENDIF
          dcdu_parse_cmd = replace(trim(substring(dcdu_start_ptr,((dcdu_grant_ptr - dcdu_start_ptr)+
             1),dcdu_cmd_string),3),";","",2), dcdu_index2 = 0, dcdu_index2 = locateval(dcdu_index2,1,
           dcdur_cmds->cnt,dcdu_parse_cmd,dcdur_cmds->qual[dcdu_index2].command)
          IF (dcdu_index2=0)
           dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
           dcdu_beg = (findstring('"',dcdu_parse_cmd,1,0)+ 1),
           dcdu_end = findstring('"',dcdu_parse_cmd,dcdu_beg,0), dcdur_cmds->qual[dcdur_cmds->cnt].
           name = substring(dcdu_beg,(dcdu_end - dcdu_beg),dcdu_parse_cmd), dcdur_cmds->qual[
           dcdur_cmds->cnt].type = "ROLE",
           dcdur_cmds->qual[dcdur_cmds->cnt].command = dcdu_parse_cmd
          ENDIF
          dcdu_start_ptr = (dcdu_grant_ptr+ 1)
          IF (dcdu_start_ptr >= dcdu_cmd_str_length)
           dcdu_grant_ptr = 0
          ENDIF
        ENDWHILE
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
   ENDIF
   IF ((validate(dm2_bypass_get_role_grants_ddl,- (1))=- (1)))
    SET dm_err->eproc =
    "Get all Source role grant DDL for all roles (i.e. grant <role> to <role>) excluding default roles."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_GRANTED_DDL('ROLE_GRANT', r.grantee)")
       FROM dba_role_privs r
       WHERE r.grantee IN (
       (SELECT
        x.role
        FROM dba_roles x))
        AND parser(dcdu_where_clause)
       WITH sqltype("C32000")))
      a)
     DETAIL
      dcdu_grant_ptr = 1, dcdu_start_ptr = 1
      IF (findstring(";",trim(a.x,3),dcdu_start_ptr) > 0)
       dcdu_cmd_string = replace(replace(replace(trim(a.x,3),char(0),""),char(10),""),char(13),""),
       dcdu_index1 = 0, dcdu_index1 = locateval(dcdu_index1,1,dcdur_cmds->cnt,dcdu_cmd_string,
        dcdur_cmds->qual[dcdu_index1].command)
       IF (dcdu_index1=0)
        dcdu_cmd_str_length = textlen(dcdu_cmd_string)
        WHILE (dcdu_grant_ptr > 0)
          dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),dcdu_start_ptr), dcdu_parse_cmd =
          replace(trim(substring(dcdu_start_ptr,((dcdu_grant_ptr - dcdu_start_ptr)+ 1),
             dcdu_cmd_string),3),";","",0), dcdu_index2 = 0,
          dcdu_index2 = locateval(dcdu_index2,1,dcdur_cmds->cnt,dcdu_parse_cmd,dcdur_cmds->qual[
           dcdu_index2].command)
          IF (dcdu_index2=0)
           dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
           dcdur_cmds->qual[dcdur_cmds->cnt].type = "ROLE GRANT",
           dcdur_cmds->qual[dcdur_cmds->cnt].command = dcdu_parse_cmd
          ENDIF
          dcdu_start_ptr = (dcdu_grant_ptr+ 1)
          IF (dcdu_start_ptr >= dcdu_cmd_str_length)
           dcdu_grant_ptr = 0
          ENDIF
        ENDWHILE
       ENDIF
      ENDIF
     FOOT REPORT
      stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
   ENDIF
   IF ((validate(dm2_bypass_get_system_grants_ddl,- (1))=- (1)))
    SET dm_err->eproc = concat(
     "Get all Source system priv grant DDL for all roles (i.e. grant <sys priv> to <role>)",
     "excluding default roles.")
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_GRANTED_DDL('SYSTEM_GRANT', r.grantee)")
       FROM dba_sys_privs r
       WHERE r.grantee IN (
       (SELECT
        u.role
        FROM dba_roles u
        WHERE parser(dcdu_role_where_clause)))
        AND parser(dcdu_where_clause)
       WITH sqltype("C32000")))
      a)
     DETAIL
      dcdu_grant_ptr = 1, dcdu_start_ptr = 1
      IF (findstring(";",trim(a.x,3),dcdu_start_ptr) > 0)
       dcdu_cmd_string = replace(replace(replace(trim(a.x,3),char(0),""),char(10),""),char(13),""),
       dcdu_index1 = 0, dcdu_index1 = locateval(dcdu_index1,1,dcdur_cmds->cnt,dcdu_cmd_string,
        dcdur_cmds->qual[dcdu_index1].command)
       IF (dcdu_index1=0)
        dcdu_cmd_str_length = textlen(dcdu_cmd_string)
        WHILE (dcdu_grant_ptr > 0)
          dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),dcdu_start_ptr), dcdu_parse_cmd =
          replace(trim(substring(dcdu_start_ptr,((dcdu_grant_ptr - dcdu_start_ptr)+ 1),
             dcdu_cmd_string),3),";","",0), dcdu_index2 = 0,
          dcdu_index2 = locateval(dcdu_index2,1,dcdur_cmds->cnt,dcdu_parse_cmd,dcdur_cmds->qual[
           dcdu_index2].command)
          IF (dcdu_index2=0)
           dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
           dcdur_cmds->qual[dcdur_cmds->cnt].type = "SYS GRANT",
           dcdur_cmds->qual[dcdur_cmds->cnt].command = dcdu_parse_cmd
          ENDIF
          dcdu_start_ptr = (dcdu_grant_ptr+ 1)
          IF (dcdu_start_ptr >= dcdu_cmd_str_length)
           dcdu_grant_ptr = 0
          ENDIF
        ENDWHILE
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
   ENDIF
   IF ((validate(dm2_bypass_role_grants_userlist_ddl,- (1))=- (1)))
    SET dm_err->eproc =
    "Get all Source role grant DDL for user(s) specified (i.e. grant <role> to <user>)."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_GRANTED_DDL('ROLE_GRANT', USERNAME)")
       FROM dba_users u
       WHERE parser(concat("u.username in (",dcdur_input->user_list,")"))
        AND  EXISTS (
       (SELECT
        1
        FROM dba_role_privs drp
        WHERE drp.grantee=u.username))
       WITH sqltype("C32000")))
      a)
     DETAIL
      dcdu_grant_ptr = 1, dcdu_start_ptr = 1
      IF (findstring(";",trim(a.x,3),dcdu_start_ptr) > 0)
       dcdu_cmd_string = replace(replace(replace(trim(a.x,3),char(0),""),char(10),""),char(13),""),
       dcdu_index1 = 0, dcdu_index1 = locateval(dcdu_index1,1,dcdur_cmds->cnt,dcdu_cmd_string,
        dcdur_cmds->qual[dcdu_index1].command)
       IF (dcdu_index1=0)
        dcdu_cmd_str_length = textlen(dcdu_cmd_string)
        WHILE (dcdu_grant_ptr > 0)
          dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),dcdu_start_ptr), dcdu_parse_cmd =
          replace(trim(substring(dcdu_start_ptr,((dcdu_grant_ptr - dcdu_start_ptr)+ 1),
             dcdu_cmd_string),3),";","",0), dcdu_index2 = 0,
          dcdu_index2 = locateval(dcdu_index2,1,dcdur_cmds->cnt,dcdu_parse_cmd,dcdur_cmds->qual[
           dcdu_index2].command)
          IF (dcdu_index2=0)
           dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
           dcdur_cmds->qual[dcdur_cmds->cnt].type = "ROLE GRANT"
           IF (findstring('"DBA"',dcdu_parse_cmd) > 0
            AND dcdu_adb_ind=1)
            dcdu_parse_cmd = replace(dcdu_parse_cmd,'"DBA"','"PDB_DBA"')
           ENDIF
           dcdur_cmds->qual[dcdur_cmds->cnt].command = dcdu_parse_cmd
          ENDIF
          dcdu_start_ptr = (dcdu_grant_ptr+ 1)
          IF (dcdu_start_ptr >= dcdu_cmd_str_length)
           dcdu_grant_ptr = 0
          ENDIF
        ENDWHILE
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
   ENDIF
   IF ((validate(dm2_bypass_system_grants_userlist_ddl,- (1))=- (1)))
    SET dm_err->eproc =
    "Get all Source sys priv grant DDL (not role) for user(s) specified (i.e. grant <sys priv> to <user>)."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_GRANTED_DDL('SYSTEM_GRANT', USERNAME)")
       FROM dba_users u
       WHERE parser(concat("u.username in (",dcdur_input->user_list,")"))
        AND  EXISTS (
       (SELECT
        1
        FROM dba_sys_privs dsp
        WHERE dsp.grantee=u.username))
       WITH sqltype("C32000")))
      a)
     DETAIL
      dcdu_grant_ptr = 1, dcdu_start_ptr = 1
      IF (findstring(";",trim(a.x,3),dcdu_start_ptr) > 0)
       dcdu_cmd_string = replace(replace(replace(trim(a.x,3),char(0),""),char(10),""),char(13),""),
       dcdu_index1 = 0, dcdu_index1 = locateval(dcdu_index1,1,dcdur_cmds->cnt,dcdu_cmd_string,
        dcdur_cmds->qual[dcdu_index1].command)
       IF (dcdu_index1=0)
        dcdu_cmd_str_length = textlen(dcdu_cmd_string)
        WHILE (dcdu_grant_ptr > 0)
          dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),dcdu_start_ptr), dcdu_parse_cmd =
          replace(trim(substring(dcdu_start_ptr,((dcdu_grant_ptr - dcdu_start_ptr)+ 1),
             dcdu_cmd_string),3),";","",0), dcdu_index2 = 0,
          dcdu_index2 = locateval(dcdu_index2,1,dcdur_cmds->cnt,dcdu_parse_cmd,dcdur_cmds->qual[
           dcdu_index2].command)
          IF (dcdu_index2=0)
           dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
           dcdur_cmds->qual[dcdur_cmds->cnt].type = "SYS GRANT",
           dcdur_cmds->qual[dcdur_cmds->cnt].command = dcdu_parse_cmd
          ENDIF
          dcdu_start_ptr = (dcdu_grant_ptr+ 1)
          IF (dcdu_start_ptr >= dcdu_cmd_str_length)
           dcdu_grant_ptr = 0
          ENDIF
        ENDWHILE
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
   ENDIF
   IF ((validate(dm2_bypass_table_grants_userlist_ddl,- (1))=- (1)))
    SET dm_err->eproc = "Retrieve Source DDL for SYS object grants on user(s) specified."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dba_tab_privs dtp
     WHERE dtp.owner="SYS"
      AND parser(concat("dtp.grantee in (",dcdur_input->user_list,")"))
     DETAIL
      dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
      dcdur_cmds->qual[dcdur_cmds->cnt].type = "TABLE GRANT",
      dcdur_cmds->qual[dcdur_cmds->cnt].owner = dtp.owner, dcdur_cmds->qual[dcdur_cmds->cnt].name =
      dtp.table_name
      IF (dtp.privilege IN ("READ", "WRITE"))
       dcdur_cmds->qual[dcdur_cmds->cnt].command = concat("GRANT ",trim(dtp.privilege),
        ' ON DIRECTORY "',trim(dtp.owner),'"."',
        trim(dtp.table_name),'" TO "',trim(dtp.grantee),'"')
      ELSE
       dcdur_cmds->qual[dcdur_cmds->cnt].command = concat("GRANT ",trim(dtp.privilege),' ON "',trim(
         dtp.owner),'"."',
        trim(dtp.table_name),'" TO "',trim(dtp.grantee),'"')
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Check for Source users default tablespaces with unlimited quota."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_ts_quotas dtq,
     dba_users du
    WHERE parser(concat("du.username in (",dcdur_input->user_list,")"))
     AND du.username=dtq.username
     AND du.default_tablespace=dtq.tablespace_name
     AND (dtq.max_bytes=- (1))
    DETAIL
     dcdu_index1 = 0, dcdu_index1 = locateval(dcdu_index1,1,dcdur_cmds->cnt,"USER",dcdur_cmds->qual[
      dcdu_index1].type,
      du.username,dcdur_cmds->qual[dcdu_index1].owner,du.default_tablespace,dcdur_cmds->qual[
      dcdu_index1].default_tspace)
     IF (dcdu_index1 > 0)
      dcdur_cmds->qual[dcdu_index1].default_tspace_quota = "Y"
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcdur_cmds)
   ENDIF
   SET dm2_force_connect_string = 1
   SET dm2_install_schema->dbase_name = '"TARGET"'
   SET dm2_install_schema->u_name = dcdur_input->tgt_user
   SET dm2_install_schema->p_word = dcdur_input->tgt_pwd
   SET dm2_install_schema->connect_str = dcdur_input->tgt_cnct_str
   EXECUTE dm2_connect_to_dbase "CO"
   SET dm2_force_connect_string = 0
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET dcdur_input->connect_back = "N"
   IF ((dcdur_input->fix_tspaces_ind="Y"))
    SET dm_err->eproc = "Retrieving Target tablespaces from dba_tablespaces."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT DISTINCT INTO "nl:"
     dt.tablespace_name
     FROM dba_tablespaces dt
     DETAIL
      dcdu_tspaces->cnt = (dcdu_tspaces->cnt+ 1), stat = alterlist(dcdu_tspaces->qual,dcdu_tspaces->
       cnt), dcdu_tspaces->qual[dcdu_tspaces->cnt].tspace_name = dt.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    FOR (dcdu_iter = 1 TO dcdu_orauser->cnt)
      SET dcdu_ndx = 0
      SET dcdu_ndx = locateval(dcdu_ndx,1,dcdu_tspaces->cnt,dcdu_orauser->qual[dcdu_iter].
       default_tspace,dcdu_tspaces->qual[dcdu_ndx].tspace_name)
      IF (dcdu_ndx=0)
       SET dcdu_fix_tspaces_ind = 1
       SET dcdu_orauser->qual[dcdu_iter].dt_fix_ind = 1
      ENDIF
      SET dcdu_ndx = 0
      SET dcdu_ndx = locateval(dcdu_ndx,1,dcdu_tspaces->cnt,dcdu_orauser->qual[dcdu_iter].temp_tspace,
       dcdu_tspaces->qual[dcdu_ndx].tspace_name)
      IF (dcdu_ndx=0)
       SET dcdu_fix_tspaces_ind = 1
       SET dcdu_orauser->qual[dcdu_iter].tt_fix_ind = 1
      ENDIF
    ENDFOR
    IF (dcdu_fix_tspaces_ind=1)
     IF ((dm_err->debug_flag > 0))
      CALL echorecord(dcdu_orauser)
     ENDIF
    ELSE
     IF ((dm_err->debug_flag > 0))
      SET dm_err->eproc = "No database users with missing default/temporary tablespaces."
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
    ENDIF
   ENDIF
   FOR (dcdu_iter = 1 TO dcdur_cmds->cnt)
     IF ((dcdur_cmds->qual[dcdu_iter].type="USER"))
      SET dm_err->eproc = concat("Check if ",dcdur_cmds->qual[dcdu_iter].owner,
       " user exists in TARGET.")
      CALL disp_msg("",dm_err->logfile,0)
      SELECT INTO "nl:"
       FROM dba_users u
       WHERE u.username=cnvtupper(dcdur_cmds->qual[dcdu_iter].owner)
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      IF (curqual=0)
       SET dcdu_cmd_string = dcdur_cmds->qual[dcdu_iter].command
       IF (dcdu_fix_tspaces_ind=1)
        SET dcdu_ndx = 0
        SET dcdu_ndx = locateval(dcdu_ndx,1,dcdu_orauser->cnt,dcdur_cmds->qual[dcdu_iter].owner,
         dcdu_orauser->qual[dcdu_ndx].user)
        IF (dcdu_ndx > 0)
         IF ((dcdu_orauser->qual[dcdu_ndx].dt_fix_ind=1))
          SET dcdu_replace_from = build('DEFAULT TABLESPACE "',dcdu_orauser->qual[dcdu_ndx].
           default_tspace,'"')
          SET dcdu_replace_to = build('DEFAULT TABLESPACE "',dcdur_input->default_tspace,'"')
          SET dcdu_cmd_string = replace(dcdu_cmd_string,dcdu_replace_from,dcdu_replace_to,0)
         ENDIF
         IF ((dcdu_orauser->qual[dcdu_ndx].tt_fix_ind=1))
          SET dcdu_replace_from = build('TEMPORARY TABLESPACE "',dcdu_orauser->qual[dcdu_ndx].
           temp_tspace,'"')
          SET dcdu_replace_to = build('TEMPORARY TABLESPACE "',dcdur_input->temp_tspace,'"')
          SET dcdu_cmd_string = replace(dcdu_cmd_string,dcdu_replace_from,dcdu_replace_to,0)
         ENDIF
        ENDIF
       ENDIF
       IF ((dcdur_input->replace_tspaces="Y"))
        SET dcdu_idx = 0
        IF (dcdur_prompt_tspaces(dcdur_cmds->qual[dcdu_iter].owner,dcdur_input->tgt_dbname,dcdu_idx)=
        0)
         RETURN(0)
        ENDIF
        SET dcdu_replace_from = build('DEFAULT TABLESPACE "',dcdur_cmds->qual[dcdu_iter].
         default_tspace,'"')
        SET dcdu_replace_to = build('DEFAULT TABLESPACE "',dcdur_user_data->users[dcdu_idx].
         misc_tspace,'"')
        SET dcdu_cmd_string = replace(dcdu_cmd_string,dcdu_replace_from,dcdu_replace_to,2)
        SET dcdu_replace_from = build('TEMPORARY TABLESPACE "',dcdur_cmds->qual[dcdu_iter].
         temp_tspace,'"')
        SET dcdu_replace_to = build('TEMPORARY TABLESPACE "',dcdur_user_data->users[dcdu_idx].
         temp_tspace,'"')
        SET dcdu_cmd_string = replace(dcdu_cmd_string,dcdu_replace_from,dcdu_replace_to,2)
       ENDIF
       IF ((dcdur_input->replace_pwds="Y"))
        SET dcdu_idx = 0
        SET dcdu_idx = locateval(dcdu_idx,1,dir_db_users_pwds->cnt,dcdur_cmds->qual[dcdu_iter].owner,
         replace(dir_db_users_pwds->qual[dcdu_idx].user,"'","",0))
        SET dcdu_db_user_pwd = dir_db_users_pwds->qual[dcdu_idx].pwd
        SET dcdu_cmd_string = replace(dcdu_cmd_string,concat("'",dcdur_cmds->qual[dcdu_iter].pwd,"'"),
         concat('"',dcdu_db_user_pwd,'"'),0)
        SET dcdu_cmd_string = replace(dcdu_cmd_string,"IDENTIFIED BY VALUES","IDENTIFIED BY",0)
       ENDIF
       IF (dm2_push_cmd(build("rdb asis(^",dcdu_cmd_string,"^) go"),1)=0)
        RETURN(0)
       ENDIF
      ELSE
       IF ((dm_err->debug_flag > 0))
        SET dm_err->eproc = concat(dcdur_cmds->qual[dcdu_iter].owner,
         " user already exists in TARGET.")
        CALL disp_msg("",dm_err->logfile,0)
       ENDIF
      ENDIF
     ELSEIF ((dcdur_cmds->qual[dcdu_iter].type="ROLE"))
      SET dm_err->eproc = concat("Check if ",dcdur_cmds->qual[dcdu_iter].name,
       " role exists in TARGET.")
      CALL disp_msg("",dm_err->logfile,0)
      SELECT INTO "nl:"
       FROM dba_roles u
       WHERE u.role=cnvtupper(dcdur_cmds->qual[dcdu_iter].name)
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      IF (curqual=0)
       IF (dm2_push_cmd(build("rdb asis(^",dcdur_cmds->qual[dcdu_iter].command,"^) go"),1)=0)
        RETURN(0)
       ENDIF
      ELSE
       IF ((dm_err->debug_flag > 0))
        SET dm_err->eproc = concat(dcdur_cmds->qual[dcdu_iter].name," role already exists in TARGET."
         )
        CALL disp_msg("",dm_err->logfile,0)
       ENDIF
      ENDIF
     ELSEIF ((dcdur_cmds->qual[dcdu_iter].type="PROFILE"))
      SET dcdu_create_ind = 1
      IF (findstring("CREATE PROFILE",dcdur_cmds->qual[dcdu_iter].command,1,0) > 0)
       SET dm_err->eproc = concat("Check if ",dcdur_cmds->qual[dcdu_iter].name,
        " profile exists in TARGET.")
       CALL disp_msg("",dm_err->logfile,0)
       SELECT INTO "nl:"
        FROM dba_profiles p
        WHERE p.profile=cnvtupper(dcdur_cmds->qual[dcdu_iter].name)
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       IF (curqual > 0)
        SET dcdu_create_ind = 0
        IF ((dm_err->debug_flag > 0))
         SET dm_err->eproc = concat(dcdur_cmds->qual[dcdu_iter].name,
          " profile already exists in TARGET.")
         CALL disp_msg("",dm_err->logfile,0)
        ENDIF
       ENDIF
      ENDIF
      IF (dcdu_create_ind=1)
       IF (dm2_push_cmd(build("rdb asis(^",dcdur_cmds->qual[dcdu_iter].command,"^) go"),1)=0)
        RETURN(0)
       ENDIF
      ENDIF
     ELSEIF ((dcdur_cmds->qual[dcdu_iter].type="FUNCTION"))
      SET dm_err->eproc = concat("Check if ",dcdur_cmds->qual[dcdu_iter].owner,".",dcdur_cmds->qual[
       dcdu_iter].name," function exists in TARGET.")
      CALL disp_msg("",dm_err->logfile,0)
      SELECT INTO "nl:"
       FROM dba_objects o
       WHERE (o.owner=dcdur_cmds->qual[dcdu_iter].owner)
        AND (o.object_name=dcdur_cmds->qual[dcdu_iter].name)
        AND o.object_type="FUNCTION"
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      IF (curqual=0)
       IF (dm2_push_cmd(build("rdb asis(^",dcdur_cmds->qual[dcdu_iter].command,"^) go"),1)=0)
        RETURN(0)
       ENDIF
      ELSE
       IF ((dm_err->debug_flag > 0))
        SET dm_err->eproc = concat(dcdur_cmds->qual[dcdu_iter].owner,".",dcdur_cmds->qual[dcdu_iter].
         name," function already exists in TARGET.")
        CALL disp_msg("",dm_err->logfile,0)
       ENDIF
      ENDIF
     ELSE
      SET dcdu_create_ind = 1
      IF ((dcdur_cmds->qual[dcdu_iter].type="TABLE GRANT"))
       SET dm_err->eproc = concat("Check if ",dcdur_cmds->qual[dcdu_iter].owner,".",dcdur_cmds->qual[
        dcdu_iter].name," object exists in TARGET.")
       CALL disp_msg("",dm_err->logfile,0)
       SELECT INTO "nl:"
        FROM dba_objects o
        WHERE (o.owner=dcdur_cmds->qual[dcdu_iter].owner)
         AND (o.object_name=dcdur_cmds->qual[dcdu_iter].name)
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       IF (curqual=0)
        SET dcdu_create_ind = 0
        IF ((dm_err->debug_flag > 0))
         SET dm_err->eproc = concat("No ",dcdur_cmds->qual[dcdu_iter].owner,".",dcdur_cmds->qual[
          dcdu_iter].name," object found in TARGET, skipping TABLE GRANT command.")
         CALL disp_msg("",dm_err->logfile,0)
        ENDIF
       ENDIF
      ENDIF
      IF (dcdu_create_ind=1)
       IF (dm2_push_cmd(build("rdb asis(^",dcdur_cmds->qual[dcdu_iter].command,"^) go"),1)=0)
        SET dm_err->err_ind = 0
        SET dm_err->eproc = "THE ABOVE ERROR MESSAGE IS IGNORABLE"
        CALL disp_msg(" ",dm_err->logfile,0)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   FOR (dcdu_iter = 1 TO dcdur_cmds->cnt)
     IF ((dcdur_cmds->qual[dcdu_iter].type="USER")
      AND (dcdur_cmds->qual[dcdu_iter].default_tspace_quota="Y"))
      SET dm_err->eproc = concat("Obtain default tablespace for [",dcdur_cmds->qual[dcdu_iter].owner,
       "] user.")
      CALL disp_msg(" ",dm_err->logfile,0)
      SELECT INTO "nl:"
       FROM dba_users du
       WHERE (du.username=dcdur_cmds->qual[dcdu_iter].owner)
       DETAIL
        dcdu_default_tspace = du.default_tablespace
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      SET dm_err->eproc = concat("Give unlimited tablespace quota to ",dcdur_cmds->qual[dcdu_iter].
       owner," user's default tablespace [",trim(dcdu_default_tspace),"].")
      CALL disp_msg(" ",dm_err->logfile,10)
      IF (dm2_push_cmd(concat("rdb asis(^alter user ",dcdur_cmds->qual[dcdu_iter].owner,
        " quota unlimited on ",trim(dcdu_default_tspace),"^) go"),1)=0)
       RETURN(0)
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_report_db_users_diff_tspaces(null)
   DECLARE drdudt_ndx = i4 WITH protect, noconstant(0)
   DECLARE drdudt_ndx2 = i4 WITH protect, noconstant(0)
   DECLARE drdudt_diff_tspace = i2 WITH protect, noconstant(0)
   DECLARE drdudt_str = vc WITH protect, noconstant(" ")
   DECLARE drdudt_file = vc WITH protect, noconstant("")
   FREE RECORD drdudt_user_tsp
   RECORD drdudt_user_tsp(
     1 cnt = i4
     1 qual[*]
       2 user = vc
       2 create_dt_tm = dq8
       2 src_default_tspace = vc
       2 src_temp_tspace = vc
       2 tgt_default_tspace = vc
       2 tgt_temp_tspace = vc
       2 dt_diff_ind = i2
       2 tt_diff_ind = i2
   )
   FREE RECORD dcdu_tspaces
   RECORD dcdu_tspaces(
     1 cnt = i4
     1 qual[*]
       2 tspace_name = vc
   )
   IF ((dcdur_input->fix_tspaces_ind != "Y"))
    RETURN(1)
   ENDIF
   IF (((size(trim(dcdur_input->default_tspace))=0) OR (((size(trim(dcdur_input->temp_tspace))=0) OR
   (size(trim(dcdur_input->user_list))=0)) )) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating input criteria."
    SET dm_err->emsg = "Invalid input."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dcdur_input)
    ENDIF
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcdur_input)
   ENDIF
   SET dm_err->eproc = "Retrieve list of Source custom database users based on defined user list."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_users@ref_data_link du
    WHERE parser(concat("du.username in (",dcdur_input->user_list,")"))
    ORDER BY du.username
    DETAIL
     drdudt_user_tsp->cnt = (drdudt_user_tsp->cnt+ 1), stat = alterlist(drdudt_user_tsp->qual,
      drdudt_user_tsp->cnt), drdudt_user_tsp->qual[drdudt_user_tsp->cnt].user = du.username,
     drdudt_user_tsp->qual[drdudt_user_tsp->cnt].src_default_tspace = du.default_tablespace,
     drdudt_user_tsp->qual[drdudt_user_tsp->cnt].src_temp_tspace = du.temporary_tablespace,
     drdudt_user_tsp->qual[drdudt_user_tsp->cnt].tgt_default_tspace = "",
     drdudt_user_tsp->qual[drdudt_user_tsp->cnt].tgt_temp_tspace = "", drdudt_user_tsp->qual[
     drdudt_user_tsp->cnt].dt_diff_ind = 0, drdudt_user_tsp->qual[drdudt_user_tsp->cnt].tt_diff_ind
      = 0
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Retrieving tablespaces from dba_tablespaces."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT DISTINCT INTO "nl:"
    dt.tablespace_name
    FROM dba_tablespaces dt
    DETAIL
     dcdu_tspaces->cnt = (dcdu_tspaces->cnt+ 1), stat = alterlist(dcdu_tspaces->qual,dcdu_tspaces->
      cnt), dcdu_tspaces->qual[dcdu_tspaces->cnt].tspace_name = dt.tablespace_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Retrieve list of Target custom database users based on defined user list."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_users du
    WHERE parser(concat("du.username in (",dcdur_input->user_list,")"))
    ORDER BY du.username
    DETAIL
     drdudt_ndx = 0, drdudt_ndx = locateval(drdudt_ndx,1,drdudt_user_tsp->cnt,du.username,
      drdudt_user_tsp->qual[drdudt_ndx].user)
     IF (drdudt_ndx > 0)
      drdudt_user_tsp->qual[drdudt_ndx].tgt_default_tspace = du.default_tablespace, drdudt_user_tsp->
      qual[drdudt_ndx].tgt_temp_tspace = du.temporary_tablespace, drdudt_user_tsp->qual[drdudt_ndx].
      create_dt_tm = du.created,
      drdudt_ndx2 = 0, drdudt_ndx2 = locateval(drdudt_ndx2,1,dcdu_tspaces->cnt,drdudt_user_tsp->qual[
       drdudt_ndx].src_default_tspace,dcdu_tspaces->qual[drdudt_ndx2].tspace_name)
      IF ((drdudt_user_tsp->qual[drdudt_ndx].src_default_tspace != drdudt_user_tsp->qual[drdudt_ndx].
      tgt_default_tspace)
       AND (drdudt_user_tsp->qual[drdudt_ndx].tgt_default_tspace=dcdur_input->default_tspace)
       AND drdudt_ndx2=0)
       drdudt_diff_tspace = 1, drdudt_user_tsp->qual[drdudt_ndx].dt_diff_ind = 1
      ENDIF
      drdudt_ndx2 = 0, drdudt_ndx2 = locateval(drdudt_ndx2,1,dcdu_tspaces->cnt,drdudt_user_tsp->qual[
       drdudt_ndx].src_temp_tspace,dcdu_tspaces->qual[drdudt_ndx2].tspace_name)
      IF ((drdudt_user_tsp->qual[drdudt_ndx].src_temp_tspace != drdudt_user_tsp->qual[drdudt_ndx].
      tgt_temp_tspace)
       AND (drdudt_user_tsp->qual[drdudt_ndx].tgt_temp_tspace=dcdur_input->temp_tspace)
       AND drdudt_ndx2=0)
       drdudt_diff_tspace = 1, drdudt_user_tsp->qual[drdudt_ndx].tt_diff_ind = 1
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(drdudt_user_tsp)
   ENDIF
   IF (drdudt_diff_tspace=1)
    IF (get_unique_file("dm2_db_user_tspace",".rpt")=0)
     RETURN(0)
    ENDIF
    SET drdudt_file = dm_err->unique_fname
    IF (validate(drrr_responsefile_in_use,0)=1)
     SET drdudt_file = build(drrr_misc_data->active_dir,drdudt_file)
    ENDIF
    SET dm_err->eproc = concat(
     "Reporting Target Database users having different default/temporary tablespaces then Source (",
     trim(drdudt_file),").")
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO value(drdudt_file)
     FROM (dummyt t  WITH seq = drdudt_user_tsp->cnt)
     HEAD REPORT
      col 50, "Database Users Missing Default/Temporary Tablespaces", row + 2,
      row + 1, drdudt_str = concat(
       "The following reports Source database users created in Target with different default and/or ",
       " temporary tablespaces due to the tablespaces not existing in Target."), col 0,
      drdudt_str, row + 2, row + 1,
      col 0, "Missing Default Tablespace replaced with: ", dcdur_input->default_tspace,
      row + 2, col 0, "Missing Temporary Tablespace replaced with: ",
      dcdur_input->temp_tspace, row + 2, row + 1,
      col 0, "A Default/Temporary Tablespace of '-' denotes no differences.", row + 2,
      row + 1, col 0, "User",
      col 35, "Created", col 70,
      "Source Default Tablespace", col 105, "Source Temporary Tablespace",
      row + 1, col 0, "------------------------------",
      col 35, "------------------------------", col 70,
      "------------------------------", col 105, "------------------------------",
      row + 1
     DETAIL
      IF ((((drdudt_user_tsp->qual[t.seq].dt_diff_ind=1)) OR ((drdudt_user_tsp->qual[t.seq].
      tt_diff_ind=1))) )
       drdudt_str = drdudt_user_tsp->qual[t.seq].user, col 0, drdudt_str,
       drdudt_str = format(cnvtdatetime(drdudt_user_tsp->qual[t.seq].create_dt_tm),";;q"), col 35,
       drdudt_str,
       drdudt_str = evaluate(drdudt_user_tsp->qual[t.seq].dt_diff_ind,1,drdudt_user_tsp->qual[t.seq].
        src_default_tspace,"-"), col 70, drdudt_str,
       drdudt_str = evaluate(drdudt_user_tsp->qual[t.seq].tt_diff_ind,1,drdudt_user_tsp->qual[t.seq].
        src_temp_tspace,"-"), col 105, drdudt_str,
       row + 1
      ENDIF
     WITH nocounter, maxcol = 250, format = variable,
      formfeed = none, maxrow = 1
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (validate(drrr_responsefile_in_use,0)=1)
     SET dm_err->eproc = concat(
      "Skipping display of Database Users Missing Default/Temporary Tablespaces Report (",trim(
       drdudt_file,3),")")
     CALL disp_msg("",dm_err->logfile,0)
     IF ((drer_email_list->email_cnt > 0))
      SET drer_email_det->msgtype = "ACTIONREQ"
      SET drer_email_det->status = "REPORT"
      SET drer_email_det->status_dt_tm = cnvtdatetime(curdate,curtime3)
      SET drer_email_det->step = "Database Users Missing Default/Temporary Tablespaces report"
      SET drer_email_det->email_level = 1
      SET drer_email_det->logfile = dm_err->logfile
      SET drer_email_det->err_ind = dm_err->err_ind
      SET drer_email_det->eproc = dm_err->eproc
      SET drer_email_det->emsg = dm_err->emsg
      SET drer_email_det->user_action = dm_err->user_action
      CALL drer_add_body_text(concat("Database Users Missing Default/Temporary Tablespaces ",
        "report was generated at ",format(drer_email_det->status_dt_tm,";;q")),1)
      CALL drer_add_body_text(concat(
        "User Action : Please review the report to ensure desired Default/Temporary Tablespaces",
        " are used for each user."),0)
      CALL drer_add_body_text(concat("Report file name is : ",drdudt_file),0)
      IF (drer_compose_email(null)=1)
       CALL drer_send_email(drer_email_det->subject,drer_email_det->file_name,drer_email_det->
        email_level)
      ENDIF
      CALL drer_reset_pre_err(null)
     ENDIF
    ELSE
     IF ((dm2_install_schema->process_option="CLIN COPY")
      AND (drer_email_list->email_cnt > 0))
      SET drer_email_det->process = drr_clin_copy_data->process
      SET drer_email_det->msgtype = "ACTIONREQ"
      SET drer_email_det->status = "PAUSED"
      SET drer_email_det->status_dt_tm = cnvtdatetime(curdate,curtime3)
      SET drer_email_det->step = "Database Users Missing Default/Temporary Tablespaces report"
      SET drer_email_det->email_level = 1
      SET drer_email_det->logfile = dm_err->logfile
      SET drer_email_det->err_ind = dm_err->err_ind
      SET drer_email_det->eproc = dm_err->eproc
      SET drer_email_det->emsg = dm_err->emsg
      SET drer_email_det->user_action = dm_err->user_action
      CALL drer_add_body_text(concat("Database Users Missing Default/Temporary Tablespaces ",
        "report was displayed at ",format(drer_email_det->status_dt_tm,";;q")),1)
      CALL drer_add_body_text(concat(
        "User Action : Return to dm2_domain_maint main session and review ",
        "Database Users Missing Default/Temporary Tablespaces report displayed on the screen.  Press <enter> to continue."
        ),0)
      CALL drer_add_body_text(concat("Report file name is ccluserdir: ",drdudt_file),0)
      IF (drer_compose_email(null)=1)
       CALL drer_send_email(drer_email_det->subject,drer_email_det->file_name,drer_email_det->
        email_level)
      ENDIF
      CALL drer_reset_pre_err(null)
     ENDIF
     IF (dm2_disp_file(drdudt_file,"Database Users Missing Default/Temporary Tablespaces")=0)
      RETURN(0)
     ENDIF
    ENDIF
   ELSE
    SET dm_err->eproc = "No database users with missing default/temporary tablespaces."
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_cleanup_pwds(dcp_in_dbname)
   SET dm_err->eproc = concat("Delete password data in Admin DM_INFO for database ",dcp_in_dbname)
   CALL disp_msg("",dm_err->logfile,0)
   DELETE  FROM dm2_admin_dm_info di
    WHERE di.info_domain="DM2_REPLICATE_USER_PWDS"
     AND di.info_name=patstring(cnvtupper(build(dcp_in_dbname,"*")))
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_insert_pwds(dip_in_dbname,dip_in_type,dip_in_user,dip_in_pwd)
   DECLARE dip_scrambled_pwd = vc WITH protect, noconstant("")
   SET dm_err->eproc = concat("Insert user password rows for database ",dip_in_dbname)
   CALL disp_msg("",dm_err->logfile,0)
   IF (((size(trim(dip_in_dbname))=0) OR (((size(trim(dip_in_type))=0) OR (((size(trim(dip_in_user))=
   0) OR (size(trim(dip_in_pwd))=0)) )) )) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating input criteria for insert of password."
    SET dm_err->emsg = "Invalid input."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dip_scrambled_pwd = dip_in_pwd
   IF (dip_in_type IN ("LOGIN", "SERVER"))
    SET dm2scramble->method_flag = 0
    SET dm2scramble->mode_ind = 1
    SET dm2scramble->in_text = dip_in_pwd
    IF (ds_scramble(null)=0)
     RETURN(0)
    ENDIF
    SET dm2scramble->out_text = replace(check(dm2scramble->out_text," ")," ","",0)
    SET dip_scrambled_pwd = dm2scramble->out_text
   ENDIF
   INSERT  FROM dm2_admin_dm_info di
    SET di.info_domain = "DM2_REPLICATE_USER_PWDS", di.info_name = cnvtupper(concat(trim(
        dip_in_dbname),"-",trim(dip_in_type),"-",trim(dip_in_user))), di.info_char =
     dip_scrambled_pwd,
     di.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc) > 0)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   COMMIT
 END ;Subroutine
 SUBROUTINE dcdur_preserve_pwds(dpp_in_dbname)
   DECLARE dpp_idx = i2 WITH protect, noconstant(0)
   DECLARE dpp_cmd_string = vc WITH protect, noconstant("")
   DECLARE dpp_iter = i4 WITH protect, noconstant(0)
   DECLARE dpp_owner = vc WITH protect, noconstant("")
   DECLARE dpp_str = vc WITH protect, noconstant("")
   DECLARE dpp_env = vc WITH protect, noconstant("")
   DECLARE dpp_domain = vc WITH protect, noconstant("")
   IF (dm2_push_cmd(concat(
     "rdb asis(^begin DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,",
     "'SQLTERMINATOR',TRUE); end;^) go"),1)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Retrieve CREATE USER DDL to retrieve password values."
   SELECT INTO "nl:"
    FROM (
     (
     (SELECT
      x = sqlpassthru("DBMS_METADATA.GET_DDL('USER', USERNAME)")
      FROM dba_users u
      WHERE u.username != "XS$NULL"
      WITH sqltype("C32000")))
     a)
    DETAIL
     IF (findstring(";",trim(a.x,3),1) > 0)
      dpp_cmd_string = replace(replace(replace(trim(a.x,3),char(0),""),char(10),""),char(13),""),
      dpp_owner = substring((findstring('"',dpp_cmd_string,1)+ 1),((findstring('"',dpp_cmd_string,(
        findstring('"',dpp_cmd_string,1)+ 1)) - findstring('"',dpp_cmd_string,1)) - 1),dpp_cmd_string
       ), dpp_idx = 0,
      dpp_idx = locateval(dpp_idx,1,dcdur_owner_pwds->cnt,dpp_owner,dcdur_owner_pwds->qual[dpp_idx].
       owner)
      IF (dpp_idx=0)
       IF (findstring("IDENTIFIED BY VALUES '",dpp_cmd_string,1) > 0)
        dcdur_owner_pwds->cnt = (dcdur_owner_pwds->cnt+ 1), stat = alterlist(dcdur_owner_pwds->qual,
         dcdur_owner_pwds->cnt), dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].type = "DB",
        dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].owner = dpp_owner, dcdur_owner_pwds->qual[
        dcdur_owner_pwds->cnt].pwd = substring((findstring("IDENTIFIED BY VALUES '",dpp_cmd_string,1)
         + 22),(findstring("'",dpp_cmd_string,((findstring("IDENTIFIED BY VALUES '",dpp_cmd_string,1)
          + 22)+ 1)) - (findstring("IDENTIFIED BY VALUES '",dpp_cmd_string,1)+ 22)),dpp_cmd_string)
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcdur_owner_pwds)
   ENDIF
   SET dm_err->eproc = "Get environment name."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dpp_env = cnvtlower(trim(logical("environment")))
   IF (trim(dpp_env) > " ")
    IF ((dm_err->debug_flag > 0))
     CALL echo(concat("ENVIRONMENT LOGICAL:",dpp_env))
    ENDIF
   ELSE
    SET dm_err->emsg = "Environment logical is not valued."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dpp_str = concat("\\environment\\",dpp_env," Domain")
   IF (ddr_lreg_oper("GET",dpp_str,dpp_domain)=0)
    RETURN(0)
   ENDIF
   IF (dpp_domain="NOPARMRETURNED")
    SET dm_err->emsg = concat("Unable to retrieve domain name property for ",dpp_env)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dcdur_get_server_users_pwds(dpp_domain)=0)
    RETURN(0)
   ENDIF
   IF (dcdur_get_db_owner_pwds(dpp_in_dbname)=0)
    RETURN(0)
   ENDIF
   IF ((dcdur_owner_pwds->cnt > 0))
    FOR (dpp_iter = 1 TO dcdur_owner_pwds->cnt)
      IF ((dcdur_owner_pwds->qual[dpp_iter].type IN ("LOGIN", "SERVER")))
       SET dm2scramble->method_flag = 0
       SET dm2scramble->mode_ind = 1
       SET dm2scramble->in_text = dcdur_owner_pwds->qual[dpp_iter].pwd
       IF (ds_scramble(null)=0)
        RETURN(0)
       ENDIF
       SET dm2scramble->out_text = replace(check(dm2scramble->out_text," ")," ","",0)
       SET dcdur_owner_pwds->qual[dpp_iter].pwd = dm2scramble->out_text
      ENDIF
    ENDFOR
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dcdur_owner_pwds)
    ENDIF
    IF (dcdur_cleanup_pwds(dpp_in_dbname)=0)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = concat("Insert user password rows for database ",dpp_in_dbname)
    CALL disp_msg("",dm_err->logfile,0)
    INSERT  FROM dm2_admin_dm_info di,
      (dummyt d  WITH seq = value(dcdur_owner_pwds->cnt))
     SET di.info_domain = "DM2_REPLICATE_USER_PWDS", di.info_name = cnvtupper(concat(trim(
         dpp_in_dbname),"-",trim(dcdur_owner_pwds->qual[d.seq].type),"-",trim(dcdur_owner_pwds->qual[
         d.seq].owner))), di.info_char = dcdur_owner_pwds->qual[d.seq].pwd,
      di.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     PLAN (d
      WHERE d.seq > 0)
      JOIN (di)
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc) > 0)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_restore_pwds(drp_in_dbname,drp_in_mode)
   DECLARE drp_idx = i2 WITH protect, noconstant(0)
   DECLARE drp_cmd_string = vc WITH protect, noconstant("")
   DECLARE drp_iter = i4 WITH protect, noconstant(0)
   DECLARE drp_str = vc WITH protect, noconstant("")
   DECLARE drp_issue_cmds = i2 WITH protect, noconstant(0)
   DECLARE drp_owner = vc WITH protect, noconstant("")
   DECLARE drp_sea = vc WITH protect, noconstant("")
   DECLARE drp_file = vc WITH protect, noconstant("")
   DECLARE drp_tmp_pwd = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE drp_env = vc WITH protect, noconstant("")
   DECLARE drp_domain = vc WITH protect, noconstant("")
   DECLARE drp_ret_val = vc WITH protect, noconstant("")
   DECLARE drp_tmp_owner = vc WITH protect, noconstant("")
   FREE RECORD drp_pwds
   RECORD drp_pwds(
     1 cnt = i4
     1 qual[*]
       2 owner = vc
       2 pwd = vc
   )
   FREE RECORD drp_cmds
   RECORD drp_cmds(
     1 cnt = i4
     1 qual[*]
       2 command = vc
       2 owner = vc
       2 common = vc
       2 oracle_maintained = vc
       2 pwd = vc
       2 issue_cmd = i2
   )
   IF (drp_in_mode IN ("SERVERS", "ALL"))
    SET dm_err->eproc = "Get environment name."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET drp_env = cnvtlower(trim(logical("environment")))
    IF (trim(drp_env) > " ")
     IF ((dm_err->debug_flag > 0))
      CALL echo(concat("ENVIRONMENT LOGICAL:",drp_env))
     ENDIF
    ELSE
     SET dm_err->emsg = "Environment logical is not valued."
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET drp_str = concat("\\environment\\",drp_env," Domain")
    IF (ddr_lreg_oper("GET",drp_str,drp_domain)=0)
     RETURN(0)
    ENDIF
    IF (drp_domain="NOPARMRETURNED")
     SET dm_err->emsg = concat("Unable to retrieve domain name property for ",drp_env)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = concat("Retrieve server user pwd rows for database ",drp_in_dbname)
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm2_admin_dm_info di
     WHERE di.info_domain="DM2_REPLICATE_USER_PWDS"
      AND di.info_name=patstring(cnvtupper(build(drp_in_dbname,"-SERVER*")))
      AND ((di.info_number != 99) OR (di.info_number = null))
     DETAIL
      drp_sea = cnvtupper(build(drp_in_dbname,"-SERVER-")), drp_owner = replace(di.info_name,drp_sea,
       "",0), drp_pwds->cnt = (drp_pwds->cnt+ 1),
      stat = alterlist(drp_pwds->qual,drp_pwds->cnt), drp_pwds->qual[drp_pwds->cnt].owner = cnvtupper
      (drp_owner), drp_pwds->qual[drp_pwds->cnt].pwd = di.info_char
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(drp_pwds)
    ENDIF
    IF ((drp_pwds->cnt > 0))
     IF (dcdur_get_server_users_pwds(drp_domain)=0)
      RETURN(0)
     ENDIF
     IF ((dcdur_server_pwds->cnt=0))
      SET dm_err->eproc =
      "No existing server 'Rdbms Password' properties to restore preserved passwords against."
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
    ELSE
     SET dm_err->eproc = "No preserved server passwords to restore."
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    IF ((drp_pwds->cnt > 0)
     AND (dcdur_server_pwds->cnt > 0))
     FOR (drp_iter = 1 TO drp_pwds->cnt)
       SET dm2scramble->method_flag = 0
       SET dm2scramble->mode_ind = 0
       SET dm2scramble->in_text = drp_pwds->qual[drp_iter].pwd
       IF (ds_scramble(null)=0)
        RETURN(0)
       ENDIF
       SET drp_pwds->qual[drp_iter].pwd = dm2scramble->out_text
     ENDFOR
     IF ((dm_err->debug_flag > 0))
      CALL echorecord(drp_pwds)
     ENDIF
    ENDIF
    IF ((dcdur_server_pwds->cnt > 0))
     FOR (drp_iter = 1 TO dcdur_server_pwds->cnt)
       SET drp_tmp_owner = cnvtupper(dcdur_server_pwds->qual[drp_iter].user)
       SET drp_idx = 0
       SET drp_idx = locateval(drp_idx,1,drp_pwds->cnt,drp_tmp_owner,drp_pwds->qual[drp_idx].owner)
       IF (drp_idx > 0)
        IF ( NOT ((dcdur_server_pwds->qual[drp_iter].server IN (58, 74))))
         SET dm_err->eproc = concat('Set "Rdbms Password" for server ',trim(cnvtstring(
            dcdur_server_pwds->qual[drp_iter].server)),".")
         CALL disp_msg("",dm_err->logfile,0)
         SET drp_str = concat("\\node\\",trim(curnode),"\\domain\\",drp_domain,"\\servers\\",
          trim(cnvtstring(dcdur_server_pwds->qual[drp_iter].server)),'\\prop "Rdbms Password" ','"',
          trim(drp_pwds->qual[drp_idx].pwd),'"')
         IF (ddr_lreg_oper("SET",drp_str,drp_ret_val)=0)
          RETURN(0)
         ENDIF
         SET drp_str = concat("\\node\\",trim(curnode),"\\domain\\",drp_domain,"\\servers\\",
          trim(cnvtstring(dcdur_server_pwds->qual[drp_iter].server)),'\\prop "Rdbms Password"')
         IF (ddr_lreg_oper("GET",drp_str,drp_ret_val)=0)
          RETURN(0)
         ENDIF
         IF (trim(drp_ret_val) != trim(drp_pwds->qual[drp_idx].pwd))
          SET dm_err->emsg = concat('Error setting "Rdbms Password" for server ',trim(cnvtstring(
             dcdur_server_pwds->qual[drp_iter].server)),".")
          SET dm_err->err_ind = 1
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          RETURN(0)
         ENDIF
        ELSE
         SET dm_err->eproc = concat("Skipping update of Rdbms Password for server ",trim(cnvtstring(
            dcdur_server_pwds->qual[drp_iter].server))," as already updated in earlier step.")
         CALL disp_msg("",dm_err->logfile,0)
        ENDIF
       ELSE
        SET dm_err->err_ind = 1
        SET dm_err->eproc = "Retrieving preserved password to complete restore."
        SET dm_err->emsg = concat("No preserved password found for server ",trim(cnvtstring(
           dcdur_server_pwds->qual[drp_iter].server))," and user ",trim(dcdur_server_pwds->qual[
          drp_iter].user),".")
        SET dm_err->user_action = concat(
         "After filling in <password> with original Target password, ",
         "execute the following and then rerun restore process: dm2_repl_insert_pwds 'SERVER', '",
         trim(dcdur_server_pwds->qual[drp_iter].user),"', '<password>' go")
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   IF (drp_in_mode IN ("DATABASE", "ALL"))
    SET dm_err->eproc = "Retrieve database users."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT
     IF ((dm2_rdbms_version->level1 >= 12))
      FROM (
       (
       (SELECT
        username = x.username, common = x.common, oracle_maintained = x.oracle_maintained
        FROM dba_users x
        WITH sqltype("C128","C3","C1")))
       du)
     ELSE
      FROM (
       (
       (SELECT
        username = x.username, common = "NO", oracle_maintained = "N"
        FROM dba_users x
        WITH sqltype("C128","C3","C1")))
       du)
     ENDIF
     INTO "nl:"
     du.username, du.common, du.oracle_maintained
     ORDER BY du.username
     DETAIL
      drp_cmds->cnt = (drp_cmds->cnt+ 1), stat = alterlist(drp_cmds->qual,drp_cmds->cnt), drp_cmds->
      qual[drp_cmds->cnt].owner = du.username,
      drp_cmds->qual[drp_cmds->cnt].common = du.common, drp_cmds->qual[drp_cmds->cnt].
      oracle_maintained = du.oracle_maintained, drp_cmds->qual[drp_cmds->cnt].issue_cmd = 0
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(drp_cmds)
    ENDIF
    SET dm_err->eproc = concat("Retrieve database user pwd rows for database ",drp_in_dbname)
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm2_admin_dm_info di
     WHERE di.info_domain="DM2_REPLICATE_USER_PWDS"
      AND di.info_name=patstring(cnvtupper(build(drp_in_dbname,"-DB*")))
      AND ((di.info_number != 99) OR (di.info_number = null))
     DETAIL
      drp_sea = cnvtupper(build(drp_in_dbname,"-DB-")), drp_owner = replace(di.info_name,drp_sea,"",0
       ), drp_idx = 0
      IF (drp_owner != "V500")
       drp_idx = locateval(drp_idx,1,drp_cmds->cnt,drp_owner,drp_cmds->qual[drp_idx].owner)
       IF (drp_idx > 0)
        drp_cmds->qual[drp_idx].pwd = di.info_char, drp_cmds->qual[drp_idx].command = concat(
         "ALTER USER ",build('"',trim(drp_cmds->qual[drp_idx].owner),'"')," IDENTIFIED BY VALUES ",
         build("'",trim(drp_cmds->qual[drp_idx].pwd),"'")," account unlock")
        IF ((drp_cmds->qual[drp_idx].common="NO")
         AND (drp_cmds->qual[drp_idx].oracle_maintained="N"))
         drp_cmds->qual[drp_idx].issue_cmd = 1, drp_issue_cmds = 1
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(drp_cmds)
    ENDIF
    IF (drp_issue_cmds=1)
     FOR (drp_iter = 1 TO drp_cmds->cnt)
       IF ((drp_cmds->qual[drp_iter].issue_cmd > 0))
        SET dm_err->eproc = concat("Restoring password for database user ",drp_cmds->qual[drp_iter].
         owner)
        CALL disp_msg("",dm_err->logfile,0)
        IF (dm2_push_cmd(build("rdb asis(^",drp_cmds->qual[drp_iter].command,"^) go"),1)=0)
         RETURN(0)
        ENDIF
       ELSE
        SET dm_err->eproc = concat("Skipping restore password for user ",drp_cmds->qual[drp_iter].
         owner," because either V500, COMMON or Oracle Maintained.")
        CALL disp_msg("",dm_err->logfile,0)
       ENDIF
     ENDFOR
    ELSE
     SET dm_err->eproc = "No preserved database users to restore passwords against."
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
   ENDIF
   IF (drp_in_mode IN ("DATABASE", "ALL", "LOGIN"))
    SET dm_err->eproc = concat("Retrieve login pwd rows for database ",drp_in_dbname)
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm2_admin_dm_info di
     WHERE di.info_domain="DM2_REPLICATE_USER_PWDS"
      AND di.info_name=patstring(cnvtupper(build(drp_in_dbname,"-LOGIN*")))
      AND ((di.info_number != 99) OR (di.info_number = null))
     DETAIL
      drp_tmp_pwd = di.info_char
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (drp_tmp_pwd="DM2NOTSET")
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validating preserved login password in Admin DM_INFO."
     SET dm_err->emsg = "No login password found."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm2scramble->method_flag = 0
    SET dm2scramble->mode_ind = 0
    SET dm2scramble->in_text = drp_tmp_pwd
    IF (ds_scramble(null)=0)
     RETURN(0)
    ENDIF
    SET drp_tmp_pwd = dm2scramble->out_text
    SET dm_err->eproc = 'Set "Rdbms Password" in registry, for the database property.'
    CALL disp_msg("",dm_err->logfile,0)
    SET drp_str = concat("\\database\\",trim(drp_in_dbname),"\\Node\\",trim(curnode),
     ' "Rdbms Password" ',
     '"',trim(drp_tmp_pwd),'"')
    IF (ddr_lreg_oper("SET",drp_str,drp_ret_val)=0)
     RETURN(0)
    ENDIF
    SET drp_str = concat("\\database\\",trim(drp_in_dbname),"\\Node\\",trim(curnode),
     ' "Rdbms Password" ')
    IF (ddr_lreg_oper("GET",drp_str,drp_ret_val)=0)
     RETURN(0)
    ENDIF
    IF (trim(drp_ret_val) != trim(drp_tmp_pwd))
     SET dm_err->emsg = 'Error setting "Rdbms Password" for database property in registry.'
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_get_server_users_pwds(dgsup_in_domain)
   DECLARE dgsup_idx = i2 WITH protect, noconstant(0)
   DECLARE dgsup_cmd_string = vc WITH protect, noconstant("")
   DECLARE dgsup_iter = i4 WITH protect, noconstant(0)
   DECLARE dgsup_str = vc WITH protect, noconstant("")
   DECLARE dgsup_num = i4 WITH protect, noconstant(0)
   DECLARE dgsup_fatal_err1 = i2 WITH protect, noconstant(0)
   DECLARE dgsup_fatal_err2 = i2 WITH protect, noconstant(0)
   DECLARE dgsup_fatal_str = vc WITH protect, noconstant("")
   DECLARE dgsup_err_msg = vc WITH protect, noconstant("")
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgsup_cmd_string = concat("mcr cer_exe:alter_server -domain ",dgsup_in_domain,
     ' -display "Rdbms Password"')
   ELSE
    SET dgsup_cmd_string = concat("$cer_exe/alter_server -domain ",dgsup_in_domain,
     ' -display "Rdbms Password"')
   ENDIF
   SET dm_err->disp_dcl_err_ind = 0
   IF (dm2_push_dcl(dgsup_cmd_string)=0)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Retrieve Rdbms Passwords for all servers."
   CALL disp_msg("",dm_err->logfile,0)
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(dm_err->errfile)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    t.line
    FROM rtl2t r
    WHERE r.line > " "
    HEAD REPORT
     dcdur_server_pwds->cnt = 0, stat = alterlist(dcdur_server_pwds->qual,dcdur_server_pwds->cnt)
    DETAIL
     beg_pos = 0, end_pos = 0, beg_pos2 = 0,
     end_pos2 = 0
     IF (findstring("rdbms password",cnvtlower(r.line),1,0) > 0)
      beg_pos = findstring("=",r.line,1,0), beg_pos2 = findstring("#",cnvtlower(r.line),1,0), end_pos
       = findstring(" ",r.line,(beg_pos+ 2),0),
      end_pos2 = findstring(" ",r.line,(beg_pos2+ 1),0)
      IF (beg_pos > 0
       AND end_pos > 0
       AND beg_pos2 > 0
       AND end_pos2 > 0)
       dgsup_num = cnvtint(substring((beg_pos2+ 1),((end_pos2 - beg_pos2) - 1),r.line)), dgsup_str =
       substring((beg_pos+ 2),((end_pos - beg_pos) - 1),r.line), dcdur_server_pwds->cnt = (
       dcdur_server_pwds->cnt+ 1),
       stat = alterlist(dcdur_server_pwds->qual,dcdur_server_pwds->cnt), dcdur_server_pwds->qual[
       dcdur_server_pwds->cnt].pwd = dgsup_str, dcdur_server_pwds->qual[dcdur_server_pwds->cnt].
       server = dgsup_num,
       dcdur_server_pwds->qual[dcdur_server_pwds->cnt].user = ""
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcdur_server_pwds)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgsup_cmd_string = concat("mcr cer_exe:alter_server -domain ",dgsup_in_domain,
     ' -display "Rdbms User Name"')
   ELSE
    SET dgsup_cmd_string = concat("$cer_exe/alter_server -domain ",dgsup_in_domain,
     ' -display "Rdbms User Name"')
   ENDIF
   SET dm_err->disp_dcl_err_ind = 0
   IF (dm2_push_dcl(dgsup_cmd_string)=0)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Retrieve Rdbms User Names for all servers with associated password property."
   CALL disp_msg("",dm_err->logfile,0)
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(dm_err->errfile)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    t.line
    FROM rtl2t r
    WHERE r.line > " "
    DETAIL
     beg_pos = 0, end_pos = 0, beg_pos2 = 0,
     end_pos2 = 0
     IF (findstring("rdbms user name",cnvtlower(r.line),1,0) > 0)
      beg_pos = findstring("=",r.line,1,0), beg_pos2 = findstring("#",cnvtlower(r.line),1,0), end_pos
       = findstring(" ",r.line,(beg_pos+ 2),0),
      end_pos2 = findstring(" ",r.line,(beg_pos2+ 1),0)
      IF (beg_pos > 0
       AND end_pos > 0
       AND beg_pos2 > 0
       AND end_pos2 > 0)
       dgsup_num = cnvtint(substring((beg_pos2+ 1),((end_pos2 - beg_pos2) - 1),r.line)), dgsup_str =
       substring((beg_pos+ 2),((end_pos - beg_pos) - 1),r.line), dgsup_idx = 0,
       dgsup_idx = locateval(dgsup_idx,1,dcdur_server_pwds->cnt,dgsup_num,dcdur_server_pwds->qual[
        dgsup_idx].server)
       IF (dgsup_idx > 0)
        dcdur_server_pwds->qual[dgsup_idx].user = dgsup_str
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcdur_server_pwds)
   ENDIF
   IF ((dcdur_server_pwds->cnt > 0))
    SET dm_err->eproc = "Rolling up Server User Name and Password properties."
    CALL disp_msg("",dm_err->logfile,0)
    FOR (dgsup_iter = 1 TO dcdur_server_pwds->cnt)
      IF ((dcdur_server_pwds->qual[dgsup_iter].user > "")
       AND (dcdur_server_pwds->qual[dgsup_iter].pwd > ""))
       IF ((dcdur_owner_pwds->cnt=0))
        SET dcdur_owner_pwds->cnt = (dcdur_owner_pwds->cnt+ 1)
        SET stat = alterlist(dcdur_owner_pwds->qual,dcdur_owner_pwds->cnt)
        SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].type = "SERVER"
        SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].owner = dcdur_server_pwds->qual[dgsup_iter]
        .user
        SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].pwd = dcdur_server_pwds->qual[dgsup_iter].
        pwd
       ELSE
        SET dgsup_idx = 0
        SET dgsup_idx = locateval(dgsup_idx,1,dcdur_owner_pwds->cnt,dcdur_server_pwds->qual[
         dgsup_iter].user,dcdur_owner_pwds->qual[dgsup_idx].owner,
         "SERVER",dcdur_owner_pwds->qual[dgsup_idx].type)
        IF (dgsup_idx > 0)
         IF ((dcdur_owner_pwds->qual[dgsup_idx].pwd != dcdur_server_pwds->qual[dgsup_iter].pwd))
          SET dgsup_fatal_err1 = 1
          IF (dgsup_fatal_str="")
           SET dgsup_fatal_str = concat(trim(dcdur_owner_pwds->qual[dgsup_idx].owner),", ")
          ELSE
           SET dgsup_fatal_str = concat(dgsup_fatal_str,trim(dcdur_owner_pwds->qual[dgsup_idx].owner),
            ", ")
          ENDIF
         ENDIF
        ELSE
         SET dcdur_owner_pwds->cnt = (dcdur_owner_pwds->cnt+ 1)
         SET stat = alterlist(dcdur_owner_pwds->qual,dcdur_owner_pwds->cnt)
         SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].type = "SERVER"
         SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].owner = dcdur_server_pwds->qual[dgsup_iter
         ].user
         SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].pwd = dcdur_server_pwds->qual[dgsup_iter].
         pwd
        ENDIF
       ENDIF
      ELSE
       SET dgsup_fatal_err2 = 1
      ENDIF
    ENDFOR
    IF (((dgsup_fatal_err1=1) OR (dgsup_fatal_err2=1)) )
     IF (dgsup_fatal_err2=1)
      SET dgsup_err_msg = concat(
       "'Rdbms Password' properties found without an associated 'Rdbms User Name' ","property.")
     ENDIF
     IF (dgsup_fatal_err1=1)
      SET dgsup_fatal_str = replace(dgsup_fatal_str,",","",2)
      SET dgsup_err_msg = concat(dgsup_err_msg,
       "   The following is a list of 'Rdbms User Name' property values with ",
       "inconsistent 'Rdbms Password' ","property values: ",trim(dgsup_fatal_str),
       ".")
     ENDIF
     IF ((dm2_sys_misc->cur_os="AXP"))
      SET dgsup_cmd_string = concat("mcr cer_exe:alter_server -domain ",dgsup_in_domain,
       ' -display "<property>"')
     ELSE
      SET dgsup_cmd_string = concat("$cer_exe/alter_server -domain ",dgsup_in_domain,
       ' -display "<property>"')
     ENDIF
     SET dgsup_err_msg = concat(trim(dgsup_err_msg,3),"   Use the following alter_server command to ",
      "reconcile issues:  ",trim(dgsup_cmd_string),".")
     SET dm_err->err_ind = 1
     SET dm_err->emsg = trim(dgsup_err_msg,3)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dcdur_owner_pwds)
    ENDIF
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo("No 'Rdbms Passwords' properties found for any servers.")
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_user_tspace_load(dutl_db_name)
   DECLARE dutl_info_domain = vc WITH protect, noconstant("")
   DECLARE dutl_len = i4 WITH protect, noconstant(0)
   DECLARE dutl_pos = i4 WITH protect, noconstant(0)
   DECLARE dutl_pos2 = i4 WITH protect, noconstant(0)
   DECLARE dutl_cur_user = vc WITH protect, noconstant("")
   DECLARE dutl_cur_idx = i4 WITH protect, noconstant(0)
   DECLARE dutl_ndx = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Load dcdur_user_data record structure"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dcdur_user_data->user_cnt=0))
    SET dm_err->eproc = "Verify that dm2_admin_dm_info public synonym exists"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dba_synonyms ds
     WHERE cnvtupper(ds.synonym_name)="DM2_ADMIN_DM_INFO"
      AND ds.owner="PUBLIC"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual > 0)
     SET dm_err->eproc = "Retrieve tablespace mappings for TEMP and MISC"
     CALL disp_msg(" ",dm_err->logfile,0)
     SELECT INTO "nl:"
      FROM dm2_admin_dm_info d
      WHERE cnvtupper(d.info_domain)=patstring(build("DM2_",cnvtupper(dutl_db_name),
        "_*_TSPACE_MAPPING"))
       AND cnvtupper(d.info_name) IN ("MISC_TSPACE", "TEMP_TSPACE")
      HEAD REPORT
       dcdur_user_data->user_cnt = 0, stat = alterlist(dcdur_user_data->users,dcdur_user_data->
        user_cnt)
      DETAIL
       dutl_cur_idx = 0, dutl_cur_user = "", dutl_info_domain = d.info_domain,
       dutl_len = textlen(trim(dutl_db_name)), dutl_pos = findstring(trim(cnvtupper(dutl_db_name)),
        dutl_info_domain,1,0), dutl_pos = ((dutl_pos+ dutl_len)+ 1),
       dutl_pos2 = findstring("_TSPACE_MAPPING",dutl_info_domain,1,1), dutl_cur_user = substring(
        dutl_pos,(dutl_pos2 - dutl_pos),dutl_info_domain)
       IF ((dcdur_user_data->user_cnt > 0))
        dutl_cur_idx = locateval(dutl_ndx,1,dcdur_user_data->user_cnt,dutl_cur_user,dcdur_user_data->
         users[dutl_ndx].user)
       ENDIF
       IF (dutl_cur_idx=0)
        dcdur_user_data->user_cnt = (dcdur_user_data->user_cnt+ 1), stat = alterlist(dcdur_user_data
         ->users,dcdur_user_data->user_cnt), dcdur_user_data->users[dcdur_user_data->user_cnt].user
         = dutl_cur_user
        IF (cnvtupper(d.info_name)="MISC_TSPACE")
         dcdur_user_data->users[dcdur_user_data->user_cnt].misc_tspace = d.info_char
        ELSEIF (cnvtupper(d.info_name)="TEMP_TSPACE")
         dcdur_user_data->users[dcdur_user_data->user_cnt].temp_tspace = d.info_char
        ENDIF
       ELSE
        IF (cnvtupper(d.info_name)="MISC_TSPACE")
         dcdur_user_data->users[dutl_cur_idx].misc_tspace = d.info_char
        ELSEIF (cnvtupper(d.info_name)="TEMP_TSPACE")
         dcdur_user_data->users[dutl_cur_idx].temp_tspace = d.info_char
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcdur_user_data)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_insert_admin_tspace_rows(diatr_user_name,diatr_db_name,diatr_temp_ts,diatr_misc_ts)
   SET dm_err->eproc = "Verify that dm2_admin_dm_info public synonym exists"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_synonyms ds
    WHERE cnvtupper(ds.synonym_name)="DM2_ADMIN_DM_INFO"
     AND ds.owner="PUBLIC"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dm_err->eproc = concat("Insert tablespace mappings rows into dm2_admin_dm_info for user: ",
     diatr_user_name)
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dm_err->eproc = "Insert MISC TSPACE mapping row"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    INSERT  FROM dm2_admin_dm_info d
     SET d.info_domain = concat("DM2_",trim(cnvtupper(diatr_db_name)),"_",trim(cnvtupper(
         diatr_user_name)),"_TSPACE_MAPPING"), d.info_name = "MISC_TSPACE", d.info_char =
      diatr_misc_ts
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Insert TEMP TSPACE mapping row"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    INSERT  FROM dm2_admin_dm_info d
     SET d.info_domain = concat("DM2_",trim(cnvtupper(diatr_db_name)),"_",trim(cnvtupper(
         diatr_user_name)),"_TSPACE_MAPPING"), d.info_name = "TEMP_TSPACE", d.info_char =
      diatr_temp_ts
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_prompt_tspaces(dpt_user_name,dpt_db_name,dpt_user_idx)
   DECLARE dpt_temp_ts_def = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dpt_misc_ts_def = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dpt_cur_ts_tmp = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dpt_len = i4 WITH protect, noconstant(0)
   DECLARE dpt_pos = i4 WITH protect, noconstant(0)
   DECLARE dpt_pos2 = i4 WITH protect, noconstant(0)
   DECLARE dpt_cur_idx = i4 WITH protect, noconstant(0)
   DECLARE dpt_ndx = i4 WITH protect, noconstant(0)
   DECLARE dpt_continue = i2 WITH protect, noconstant(1)
   DECLARE dpt_invalid_misc_ts = i2 WITH protect, noconstant(0)
   DECLARE dpt_invalid_temp_ts = i2 WITH protect, noconstant(0)
   IF (dcdur_user_tspace_load(dpt_db_name)=0)
    RETURN(0)
   ENDIF
   IF ((dcdur_user_data->user_cnt > 0))
    SET dpt_cur_idx = locateval(dpt_ndx,1,dcdur_user_data->user_cnt,cnvtupper(dpt_user_name),
     dcdur_user_data->users[dpt_ndx].user)
    IF (dpt_cur_idx > 0)
     SET dpt_user_idx = dpt_cur_idx
     RETURN(1)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Verify that current user is a valid user"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_users du
    WHERE cnvtupper(du.username)=cnvtupper(dpt_user_name)
    DETAIL
     dpt_temp_ts_def = trim(cnvtupper(du.temporary_tablespace)), dpt_misc_ts_def = trim(cnvtupper(du
       .default_tablespace))
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0
    AND validate(drrr_responsefile_in_use,0)=1
    AND validate(drrr_misc_data->process_type,"zz")="REFRESH")
    SET dpt_misc_ts_def = drrr_rf_data->tgt_default_misc_ts
    SET dpt_temp_ts_def = drrr_rf_data->tgt_default_temp_ts
    IF (((dpt_misc_ts_def="DM2NOTSET") OR (dpt_temp_ts_def="DM2NOTSET")) )
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validating if default tablespaces are set in the response file."
     SET dm_err->emsg = concat("Invalid values found for default tablespaces in the response file. ",
      "Please provide valid inputs for s_TGT_DEFAULT_MISC_TS and s_TGT_DEFAULT_TEMP_TS tokens.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (((curqual > 0) OR (curqual=0
    AND validate(drrr_responsefile_in_use,0)=1
    AND validate(drrr_misc_data->process_type,"zz")="REFRESH")) )
    IF ((dm_err->debug_flag > 0))
     CALL echo(dpt_temp_ts_def)
     CALL echo(dpt_misc_ts_def)
    ENDIF
    IF (dcdur_insert_admin_tspace_rows(dpt_user_name,dpt_db_name,dpt_temp_ts_def,dpt_misc_ts_def)=0)
     RETURN(0)
    ENDIF
    SET dcdur_user_data->user_cnt = (dcdur_user_data->user_cnt+ 1)
    SET stat = alterlist(dcdur_user_data->users,dcdur_user_data->user_cnt)
    SET dcdur_user_data->users[dcdur_user_data->user_cnt].user = dpt_user_name
    SET dcdur_user_data->users[dcdur_user_data->user_cnt].misc_tspace = dpt_misc_ts_def
    SET dcdur_user_data->users[dcdur_user_data->user_cnt].temp_tspace = dpt_temp_ts_def
    SET dpt_user_idx = dcdur_user_data->user_cnt
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Check if override values are set for MISC and TEMP tablespace mappings"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (trim(dcdur_user_data->misc_tspace_force) != "DM2NOTSET"
    AND trim(dcdur_user_data->misc_tspace_force) != ""
    AND trim(dcdur_user_data->temp_tspace_force) != "DM2NOTSET"
    AND trim(dcdur_user_data->temp_tspace_force) != "")
    SET dpt_misc_ts_def = dcdur_user_data->misc_tspace_force
    SET dpt_temp_ts_def = dcdur_user_data->temp_tspace_force
    IF ((dm_err->debug_flag > 0))
     CALL echo("OVERRIDING VALUES FOR TEMP AND MISC TSPACE MAPPING")
     CALL echo(dpt_temp_ts_def)
     CALL echo(dpt_misc_ts_def)
    ENDIF
    IF (dcdur_insert_admin_tspace_rows(dpt_user_name,dpt_db_name,dpt_temp_ts_def,dpt_misc_ts_def)=0)
     RETURN(0)
    ENDIF
    SET dcdur_user_data->user_cnt = (dcdur_user_data->user_cnt+ 1)
    SET stat = alterlist(dcdur_user_data->users,dcdur_user_data->user_cnt)
    SET dcdur_user_data->users[dcdur_user_data->user_cnt].user = dpt_user_name
    SET dcdur_user_data->users[dcdur_user_data->user_cnt].misc_tspace = dpt_misc_ts_def
    SET dcdur_user_data->users[dcdur_user_data->user_cnt].temp_tspace = dpt_temp_ts_def
    SET dpt_user_idx = dcdur_user_data->user_cnt
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Set default values for MISC and TEMP tablespace mappings"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (trim(dcdur_user_data->misc_tspace_default)="DM2NOTSET")
    SET dm_err->eproc = "Retrieve MISC tablespace from dba_tablespaces"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dba_tablespaces dt
     WHERE dt.tablespace_name="MISC"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual > 0)
     SET dcdur_user_data->misc_tspace_default = "MISC"
    ENDIF
    IF ((dcdur_user_data->user_cnt > 0))
     SET dcdur_user_data->misc_tspace_default = dcdur_user_data->users[1].misc_tspace
    ENDIF
   ENDIF
   IF (trim(dcdur_user_data->temp_tspace_default)="DM2NOTSET")
    SET dm_err->eproc = "Retrieve temp tablespace from dba_tablespaces"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dba_tablespaces dt
     WHERE dt.tablespace_name="TEMP"
      AND dt.contents="TEMPORARY"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual > 0)
     SET dcdur_user_data->temp_tspace_default = "TEMP"
    ELSE
     SET dm_err->eproc = "Retrieve temp tablespace contents from dba_tablespaces"
     CALL disp_msg(" ",dm_err->logfile,0)
     SELECT INTO "nl:"
      FROM dba_tablespaces dt
      WHERE dt.contents="TEMPORARY"
      DETAIL
       dpt_cur_ts_tmp = dt.tablespace_name
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (curqual > 0)
      SET dcdur_user_data->temp_tspace_default = dpt_cur_ts_tmp
     ENDIF
    ENDIF
    IF ((dcdur_user_data->user_cnt > 0))
     SET dcdur_user_data->temp_tspace_default = dcdur_user_data->users[1].temp_tspace
    ENDIF
   ENDIF
   SET dm_err->eproc = "Prompt user for MISC and TEMP tablespace mappings"
   CALL disp_msg(" ",dm_err->logfile,0)
   WHILE (dpt_continue=1)
     SET message = window
     CALL clear(1,1)
     CALL box(1,1,3,132)
     CALL text(2,2,"TABLESPACE MAPPING PROMPTS")
     CALL text(2,70,"DATE/TIME: ")
     CALL text(2,80,format(cnvtdatetime(curdate,curtime3),";;Q"))
     IF (dpt_invalid_temp_ts=1
      AND dpt_invalid_misc_ts=1)
      CALL text(5,2,concat(
        "Both MISC and TEMP tablespace mappings provided could not be validated in dba_tablespaces.",
        " Please provide an alternate mappings."))
     ELSEIF (dpt_invalid_temp_ts=1)
      CALL text(5,2,concat(
        "TEMP tablespace provided is not a valid TEMPORARY tablespace in dba_tablespaces.",
        " Please provide an alternate mapping."))
     ELSEIF (dpt_invalid_misc_ts=1)
      CALL text(5,2,concat("MISC tablespace provided is not a valid tablespace in dba_tablespaces.",
        " Please provide an alternate mapping."))
     ELSE
      CALL clear(5,2,100)
     ENDIF
     SET dpt_invalid_temp_ts = 0
     SET dpt_invalid_misc_ts = 0
     CALL text(7,2,concat("MISC Tablespace for ",dpt_user_name,": "))
     CALL text(9,2,concat("TEMP Tablespace for ",dpt_user_name,": "))
     CALL accept(7,40,"P(30);CU",evaluate(dcdur_user_data->misc_tspace_default,"DM2NOTSET"," ",
       dcdur_user_data->misc_tspace_default)
      WHERE curaccept != " ")
     SET dpt_misc_ts_def = trim(curaccept)
     CALL accept(9,40,"P(30);CU",evaluate(dcdur_user_data->temp_tspace_default,"DM2NOTSET"," ",
       dcdur_user_data->temp_tspace_default)
      WHERE curaccept != " ")
     SET dpt_temp_ts_def = trim(curaccept)
     CALL text(12,2,"(C)ontinue, (M)odify, (Q)uit :")
     CALL accept(12,34,"p;cu","C"
      WHERE curaccept IN ("C", "M", "Q"))
     SET message = nowindow
     CASE (curaccept)
      OF "Q":
       SET dm_err->emsg = "User Quit Process"
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dpt_misc_ts_def = "DM2NOTSET"
       SET dpt_temp_ts_def = "DM2NOTSET"
       SET dpt_continue = 0
       RETURN(0)
      OF "C":
       IF ((((dpt_misc_ts_def != dcdur_user_data->misc_tspace_default)) OR ((dpt_temp_ts_def !=
       dcdur_user_data->temp_tspace_default))) )
        SET dm_err->eproc = "Verifying that MISC and TEMP tablspace mappings provided are valid"
        CALL disp_msg(" ",dm_err->logfile,0)
        SET dm_err->eproc = "Retrieve temp tablespace from dba_tablespaces"
        CALL disp_msg(" ",dm_err->logfile,0)
        SELECT INTO "nl:"
         FROM dba_tablespaces dt
         WHERE dt.tablespace_name=dpt_temp_ts_def
          AND dt.contents="TEMPORARY"
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
        IF (curqual=0)
         SET dpt_continue = 1
         SET dpt_invalid_temp_ts = 1
        ENDIF
        SET dm_err->eproc = "Retrieve misc tablespace from dba_tablespaces"
        CALL disp_msg(" ",dm_err->logfile,0)
        SELECT INTO "nl:"
         FROM dba_tablespaces dt
         WHERE dt.tablespace_name=dpt_misc_ts_def
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
        IF (curqual=0)
         SET dpt_continue = 1
         SET dpt_invalid_misc_ts = 1
        ENDIF
        IF (dpt_invalid_misc_ts=0
         AND dpt_invalid_temp_ts=0)
         SET dpt_continue = 0
        ELSE
         SET dpt_continue = 1
        ENDIF
       ELSE
        SET dpt_continue = 0
       ENDIF
      OF "M":
       SET dpt_continue = 1
     ENDCASE
   ENDWHILE
   IF (dcdur_insert_admin_tspace_rows(dpt_user_name,dpt_db_name,dpt_temp_ts_def,dpt_misc_ts_def)=0)
    RETURN(0)
   ENDIF
   SET dcdur_user_data->user_cnt = (dcdur_user_data->user_cnt+ 1)
   SET stat = alterlist(dcdur_user_data->users,dcdur_user_data->user_cnt)
   SET dcdur_user_data->users[dcdur_user_data->user_cnt].user = dpt_user_name
   SET dcdur_user_data->users[dcdur_user_data->user_cnt].misc_tspace = dpt_misc_ts_def
   SET dcdur_user_data->users[dcdur_user_data->user_cnt].temp_tspace = dpt_temp_ts_def
   SET dpt_user_idx = dcdur_user_data->user_cnt
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_user_tspace_cleanup(dutc_user_name,dutc_db_name)
   SET dm_err->eproc = "Verify that dm2_admin_dm_info public synonym exists"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_synonyms ds
    WHERE cnvtupper(ds.synonym_name)="DM2_ADMIN_DM_INFO"
     AND ds.owner="PUBLIC"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dm_err->eproc = concat("Cleanup tablespace mappings rows in dm2_admin_dm_info for user: ",
     dutc_user_name)
    CALL disp_msg(" ",dm_err->logfile,0)
    DELETE  FROM dm2_admin_dm_info d
     WHERE d.info_domain=patstring(build("DM2_",cnvtupper(dutc_db_name),"_",cnvtupper(dutc_user_name),
       "_TSPACE_MAPPING"))
     WITH nocounter
    ;end delete
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_get_db_owner_pwds(dgdop_in_dbname)
   DECLARE dgdop_str = vc WITH protect, noconstant("")
   DECLARE dgdop_pwd_val = vc WITH protect, noconstant("")
   DECLARE dgdop_user_val = vc WITH protect, noconstant("")
   SET dm_err->eproc = 'Get "Rdbms User Name" from registry.'
   CALL disp_msg("",dm_err->logfile,0)
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgdop_str = concat("\database\",trim(dgdop_in_dbname),"\Node\",trim(curnode),
     ' "Rdbms User Name" ')
   ELSE
    SET dgdop_str = concat("\\database\\",trim(dgdop_in_dbname),"\\Node\\",trim(curnode),
     ' "Rdbms User Name" ')
   ENDIF
   IF (ddr_lreg_oper("GET",dgdop_str,dgdop_user_val)=0)
    RETURN(0)
   ENDIF
   IF (dgdop_user_val="NOPARMRETURNED")
    SET dm_err->emsg = concat("Unable to retrieve Rdbms User Name property for ",trim(dgdop_in_dbname
      ))
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (dgdop_user_val != "v500")
    SET dm_err->emsg = concat("Retrieved Rdbms User Name for DB ",trim(dgdop_in_dbname)," is ",
     dgdop_user_val," instead of v500")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = 'Get "Rdbms Password" from registry.'
   CALL disp_msg("",dm_err->logfile,0)
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgdop_str = concat("\database\",trim(dgdop_in_dbname),"\Node\",trim(curnode),
     ' "Rdbms Password" ')
   ELSE
    SET dgdop_str = concat("\\database\\",trim(dgdop_in_dbname),"\\Node\\",trim(curnode),
     ' "Rdbms Password" ')
   ENDIF
   IF (ddr_lreg_oper("GET",dgdop_str,dgdop_pwd_val)=0)
    RETURN(0)
   ENDIF
   IF (dgdop_pwd_val="NOPARMRETURNED")
    SET dm_err->emsg = concat("Unable to retrieve Rdbms Password property for ",trim(dgdop_in_dbname)
     )
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dcdur_owner_pwds->cnt = (dcdur_owner_pwds->cnt+ 1)
   SET stat = alterlist(dcdur_owner_pwds->qual,dcdur_owner_pwds->cnt)
   SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].type = "LOGIN"
   SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].owner = dgdop_user_val
   SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].pwd = dgdop_pwd_val
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcdur_owner_pwds)
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE dm2_adb_check(dac_db_link=vc,dac_adb_ind=i2(ref)) = i2
 SUBROUTINE dm2_adb_check(dac_db_link,dac_adb_ind)
   DECLARE dac_col_cnt = i4 WITH protect, noconstant(0)
   SET dac_adb_ind = 0
   SET dm_err->eproc = "Check if connected to database."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   IF (validate(currdbhandle,"")="")
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "currdbhandle is not set."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Check if connected to autonomous database."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT
    IF (dac_db_link > ""
     AND dac_db_link != "DM2NOTSET")
     FROM (parser(concat("dba_tab_columns@",dac_db_link)) dtc)
    ELSE
     FROM dba_tab_columns dtc
    ENDIF
    INTO "nl:"
    dac_col_tmp_cnt = count(*)
    WHERE dtc.owner="SYS"
     AND dtc.table_name="V_$PDBS"
     AND dtc.column_name="CLOUD_IDENTITY"
    DETAIL
     dac_col_cnt = dac_col_tmp_cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dac_col_cnt > 0)
    IF (dac_db_link > ""
     AND dac_db_link != "DM2NOTSET")
     SELECT INTO "nl:"
      FROM (
       (
       (SELECT
        name = x.name
        FROM (parser(concat("V$PDBS@",dac_db_link)) x)
        WHERE parser(concat(cnvtupper(" x.cloud_identity = '*AUTONOMOUSDATABASE*' ")))
        WITH sqltype("C128")))
       u)
      DETAIL
       CALL echo("Connected to autonomous database"), dac_adb_ind = 1
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM (
       (
       (SELECT
        name = x.name
        FROM v$pdbs x
        WHERE parser(concat(cnvtupper(" x.cloud_identity = '*AUTONOMOUSDATABASE*' ")))
        WITH sqltype("C128")))
       u)
      DETAIL
       CALL echo("Connected to autonomous database"), dac_adb_ind = 1
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE dmcnu_user_list = vc WITH protect, noconstant("")
 IF (check_logfile("dm2_mignv500crt",".log","dm2_mig_create_nonv500_users")=0)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Starting dm2_mig_create_nonv500_users"
 CALL disp_msg(" ",dm_err->logfile,0)
 IF (dmr_prompt_retrieve_mig_data(0,1,0,0)=0)
  GO TO exit_program
 ENDIF
 IF (dmr_prompt_connect_data("SOURCE","V500","CO")=0)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Getting list of migration non-v500 users to create."
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
 ;end select
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE ((di.info_domain="DM2_MIG_USER") OR (di.info_domain="DM2_MIG_DT_USER"
   AND di.info_char="1"))
   AND  NOT (di.info_name IN ("V500_EVENT", "V500_READ", "V500_REF", "V500"))
  ORDER BY di.info_name
  HEAD REPORT
   dmcnu_user_list = ""
  DETAIL
   IF (dmcnu_user_list="")
    dmcnu_user_list = build("'",di.info_name,"',")
   ELSE
    dmcnu_user_list = build(dmcnu_user_list,"'",di.info_name,"',")
   ENDIF
  FOOT REPORT
   dmcnu_user_list = replace(dmcnu_user_list,",","",2)
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (curqual=0)
  SET dm_err->emsg = "No migration users were identified!"
  SET dm_err->err_ind = 1
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (dmr_prompt_connect_data("TARGET","SYS","PC")=0)
  GO TO exit_program
 ENDIF
 SET dcdur_input->user_list = dmcnu_user_list
 SET dcdur_input->src_user = "V500"
 SET dcdur_input->src_pwd = dmr_mig_data->src_v500_pwd
 SET dcdur_input->src_cnct_str = dmr_mig_data->src_v500_cnct_str
 SET dcdur_input->tgt_user = "SYS"
 SET dcdur_input->tgt_pwd = dmr_mig_data->tgt_sys_pwd
 SET dcdur_input->tgt_cnct_str = dmr_mig_data->tgt_sys_cnct_str
 SET dcdur_input->tgt_dbname = ""
 SET dcdur_input->fix_tspaces_ind = "N"
 SET dcdur_input->default_tspace = ""
 SET dcdur_input->temp_tspace = ""
 SET dcdur_input->replace_tspaces = "N"
 SET dcdur_input->replace_pwds = "N"
 IF (dcdur_create_db_users(null)=0)
  GO TO exit_program
 ENDIF
#exit_program
 SET dm_err->eproc = "dm2_mig_create_nonv500_users completed"
 CALL final_disp_msg("dm2_mignv500crt")
END GO
