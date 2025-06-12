CREATE PROGRAM dm_rdds_remove:dba
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
 DECLARE remove_lock(i_info_domain=vc,i_info_name=vc,i_info_char=vc,io_reply=vc(ref)) = null
 DECLARE check_lock(i_info_domain=vc,i_info_name=vc,io_reply=vc(ref)) = null
 DECLARE get_lock(i_info_domain=vc,i_info_name=vc,i_retry_limit=i2,io_reply=vc(ref)) = null
 IF ((validate(drl_request->retry_flag,- (1))=- (1)))
  FREE RECORD drl_request
  RECORD drl_request(
    1 info_domain = vc
    1 info_name = vc
    1 info_char = vc
    1 info_number = f8
    1 retry_flag = i2
  )
  FREE RECORD drl_reply
  RECORD drl_reply(
    1 status = c1
    1 status_msg = vc
  )
 ENDIF
 SUBROUTINE remove_lock(i_info_domain,i_info_name,i_info_char,io_reply)
  DELETE  FROM dm_info di
   WHERE di.info_domain=i_info_domain
    AND di.info_name=i_info_name
    AND di.info_char=i_info_char
   WITH nocounter
  ;end delete
  IF (check_error("Deleting in-process row from dm_info") != 0)
   SET io_reply->status = "F"
   SET io_reply->status_msg = dm_err->emsg
  ELSE
   COMMIT
  ENDIF
 END ;Subroutine
 SUBROUTINE check_lock(i_info_domain,i_info_name,io_reply)
   DECLARE s_info_char = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    rdbhandle = trim(di.info_char)
    FROM dm_info di
    WHERE di.info_domain=i_info_domain
     AND di.info_name=i_info_name
    DETAIL
     s_info_char = rdbhandle
    WITH nocounter
   ;end select
   IF (check_error("Retrieving in-process from from dm_info") != 0)
    SET io_reply->status = "F"
    SET io_reply->status_msg = dm_err->emsg
    RETURN
   ENDIF
   IF (s_info_char > ""
    AND s_info_char != currdbhandle)
    SELECT INTO "nl:"
     FROM gv$session s
     WHERE s.audsid=cnvtreal(s_info_char)
     WITH nocounter
    ;end select
    IF (check_error("Retrieving session id from gv$session") != 0)
     SET io_reply->status = "F"
     SET io_reply->status_msg = dm_err->emsg
     RETURN
    ENDIF
    IF (curqual=0)
     CALL remove_lock(i_info_domain,i_info_name,s_info_char,io_reply)
    ELSE
     SET io_reply->status = "Z"
     SET io_reply->status_msg = "Another active session has the required lock."
    ENDIF
   ELSEIF (s_info_char=currdbhandle)
    SET io_reply->status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE get_lock(i_info_domain,i_info_name,i_retry_limit,io_reply)
   DECLARE s_retry_cnt = i2 WITH protect, noconstant(0)
   DECLARE s_retry_limit = i2 WITH protect, noconstant(i_retry_limit)
   IF (s_retry_limit <= 0)
    SET s_retry_limit = 3
   ENDIF
   SET io_reply->status = ""
   SET io_reply->status_msg = ""
   CALL check_lock(i_info_domain,i_info_name,io_reply)
   IF ((io_reply->status=""))
    FOR (s_retry_cnt = 1 TO s_retry_limit)
     INSERT  FROM dm_info di
      SET di.info_domain = i_info_domain, di.info_name = i_info_name, di.info_char = currdbhandle
      WITH nocounter
     ;end insert
     IF (check_error("Inserting lock creation row...") != 0)
      IF (findstring("ORA-00001",dm_err->emsg,1,0) > 0)
       SET dm_err->err_ind = 0
       CALL check_lock(i_info_domain,i_info_name,io_reply)
       IF ((io_reply->status="F"))
        SET io_reply->status_msg = dm_err->emsg
        SET s_retry_cnt = s_retry_limit
       ELSEIF ((io_reply->status="Z"))
        SET s_retry_cnt = s_retry_limit
       ELSE
        SET io_reply->status = "F"
        SET io_reply->status_msg = dm_err->emsg
        SET dm_err->err_ind = 0
       ENDIF
      ELSE
       ROLLBACK
       SET io_reply->status = "F"
       SET io_reply->status_msg = dm_err->emsg
       SET s_retry_cnt = s_retry_limit
      ENDIF
     ELSE
      COMMIT
      SET io_reply->status = "S"
      SET io_reply->status_msg = ""
      SET s_retry_cnt = s_retry_limit
     ENDIF
    ENDFOR
   ENDIF
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
 DECLARE drcm_get_imp_file(dgf_name=vc,dgf_file=vc,dgf_xtn=vc) = vc
 DECLARE drcm_check_context(dcc_ctxt_name=vc,dcc_null_allowed_ind=i2) = i2
 DECLARE drcm_file_complete(dfc_name=vc,dfc_files=vc(ref),dvc_type=vc,dfc_error_ind=i2) = null
 DECLARE check_error_gui(ceg_proc=vc,ceg_menu_screen=vc,ceg_env_name=vc,ceg_env_id=f8) = i4
 DECLARE drcm_dbase_connect(ddc_password=vc(ref),ddc_sid=vc(ref)) = i4
 DECLARE drcm_retry_connect(retry_reason=vc) = i4
 DECLARE drcm_check_user(null) = i2
 IF ((validate(drcm_files->cnt,- (2))=- (2)))
  FREE RECORD drcm_files
  RECORD drcm_files(
    1 cnt = i4
    1 qual[*]
      2 file_name = vc
  )
 ENDIF
 SUBROUTINE drcm_get_imp_file(dgf_name,dgf_file,dgf_xtn)
   SET dm_err->eproc = "Getting file name"
   DECLARE dgf_file_name = vc WITH protect, noconstant("")
   DECLARE dgf_full_file = vc WITH protect, noconstant("")
   DECLARE dgf_done_ind = i2 WITH protect, noconstant(0)
   DECLARE dgf_valid_ind = i2 WITH protect, noconstant(1)
   DECLARE dgf_title = vc WITH protect, noconstant("")
   SET dgf_title = concat("*** ",dgf_name," ***")
   WHILE (dgf_done_ind=0)
     SET dgf_valid_ind = 1
     SET message = window
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,4,132)
     CALL text(3,(66 - ceil((size(dgf_title)/ 2))),dgf_title)
     CALL text(6,3,concat("Please enter a file name for the ",dgf_name,
       " to be imported from (0 to exit): "))
     CALL text(9,3,concat("Example: myfilename",dgf_xtn))
     CALL text(10,3,concat("NOTE: File must be located in CCLUSERDIR "))
     SET accept = nopatcheck
     CALL accept(7,3,"P(30);CU",value(dgf_file))
     SET accept = patcheck
     SET dgf_file_name = curaccept
     SET dgf_file_name = cnvtlower(dgf_file_name)
     IF (dgf_file_name="0")
      RETURN("0")
     ENDIF
     IF (findstring(".",dgf_file_name)=0)
      SET dgf_file_name = concat(dgf_file_name,dgf_xtn)
     ELSEIF (substring(findstring(".",dgf_file_name),((size(dgf_file_name,1) - findstring(".",
       dgf_file_name))+ 1),dgf_file_name) != dgf_xtn)
      CALL text(20,3,concat("Invalid file type, file extension must be ",dgf_xtn))
      CALL pause(3)
      SET dgf_valid_ind = 0
     ENDIF
     IF (size(dgf_file_name,1) >= 31)
      SET dgf_valid_ind = 0
     ENDIF
     IF (dgf_valid_ind=1)
      SET dgf_full_file = concat(trim(logical("CCLUSERDIR")),"/",dgf_file_name)
      IF (findfile(value(dgf_full_file))=0)
       SET message = window
       CALL clear(1,1)
       SET width = 132
       CALL box(1,1,4,132)
       CALL text(3,(66 - ceil((size(dgf_title)/ 2))),dgf_title)
       CALL text(6,3,concat(dgf_file_name," could not be found in CCLLUSERDIR."))
       CALL text(7,3,"Please ensure file is located in CCLUSERDIR")
       CALL text(10,3,"Press enter to continue.")
       CALL accept(10,28,"P;E"," ")
      ELSE
       SET dgf_done_ind = 1
      ENDIF
      SET dgf_file_name = dgf_full_file
     ENDIF
   ENDWHILE
   RETURN(dgf_file_name)
 END ;Subroutine
 SUBROUTINE drcm_check_context(dcc_ctxt_name,dcc_null_allowed_ind)
   DECLARE dcc_valid_ind = i2 WITH protect, noconstant(0)
   IF (size(trim(dcc_ctxt_name),1) <= 24
    AND dcc_ctxt_name != "ALL"
    AND findstring(":",dcc_ctxt_name)=0
    AND size(trim(dcc_ctxt_name),1) > 0
    AND ((dcc_ctxt_name != "NULL"
    AND dcc_null_allowed_ind=0) OR (dcc_ctxt_name="NULL"
    AND dcc_null_allowed_ind=1)) )
    SET dcc_valid_ind = 1
   ELSE
    SET dcc_valid_ind = 0
   ENDIF
   RETURN(dcc_valid_ind)
 END ;Subroutine
 SUBROUTINE drcm_file_complete(dfc_name,dfc_files,dfc_type,dfc_num,dfc_error_ind,dfc_env_name,
  dfc_env_id)
   DECLARE dfc_title = vc WITH protect, noconstant("")
   DECLARE dfc_pos = i4 WITH protect, noconstant(0)
   DECLARE dfc_loop = i4 WITH protect, noconstant(0)
   DECLARE dfc_line = i4 WITH protect, noconstant(11)
   SET dfc_title = concat("*** ",dfc_name," ***")
   IF (dfc_error_ind=0)
    CALL clear(1,1)
    SET width = 132
    CALL box(1,1,5,132)
    CALL text(3,(66 - ceil((size(dfc_title)/ 2))),dfc_title)
    CALL text(4,75,"ENVIRONMENT ID:")
    CALL text(4,20,"ENVIRONMENT NAME:")
    CALL text(4,95,cnvtstring(dfc_env_id))
    CALL text(4,40,dfc_env_name)
    CALL text(7,3,concat(dfc_type," complete!"))
    IF (dfc_type="Export")
     CALL text(8,3,concat(trim(cnvtstring(dfc_num))," rows were exported"))
    ENDIF
    CALL text(9,3,
     "For optimal viewing, the following file(s) needs to be moved from CCLUSERDIR to a PC:")
    CALL text(10,3,"-----------------------------")
    FOR (dfc_loop = 1 TO dfc_files->cnt)
     CALL text(dfc_line,3,dfc_files->qual[dfc_loop].file_name)
     SET dfc_line = (dfc_line+ 1)
    ENDFOR
    CALL text(dfc_line,3,"-----------------------------")
    CALL text((dfc_line+ 2),3,"Press enter to return:")
    CALL accept((dfc_line+ 2),26,"X;CUS","E")
   ELSE
    CALL clear(1,1)
    SET width = 132
    CALL box(1,1,5,132)
    CALL text(3,(66 - ceil((size(dfc_title)/ 2))),dfc_title)
    CALL text(7,3,concat(dfc_type," was not successful.  The following error occurred!"))
    SET dfc_pos = drdc_wrap_menu_lines(dm_err->emsg,8,3,"   ",0,
     120)
    CALL text((dfc_pos+ 1),3,"Press enter to return:")
    CALL accept((dfc_pos+ 1),26,"X;CUS","E")
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE check_error_gui(ceg_proc,ceg_menu_screen,ceg_env_name,ceg_env_id)
   DECLARE ceg_error = i4 WITH protect, noconstant(0)
   DECLARE ceg_size = i4 WITH protect, noconstant(0)
   SET ceg_error = check_error(ceg_proc)
   IF (ceg_error != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    SET message = window
    SET width = 132
    CALL clear(1,1)
    CALL box(1,1,7,132)
    CALL text(3,floor(((66 - 5) - (size(ceg_menu_screen)/ 2))),concat("***  ",ceg_menu_screen,"  ***"
      ))
    CALL text(5,20,"Environment Name:")
    CALL text(5,40,ceg_env_name)
    CALL text(5,65,"Environment ID:")
    CALL text(5,85,cnvtstring(ceg_env_id))
    SET ceg_size = size(dm_err->emsg)
    CALL text(9,3,trim(substring(1,125,dm_err->emsg)))
    IF (ceg_size > 125)
     CALL text(10,3,trim(substring(126,125,dm_err->emsg)))
    ENDIF
    CALL text(12,3,"Press ENTER to continue")
    CALL accept(12,28,"P;E"," ")
   ENDIF
   RETURN(dm_err->err_ind)
 END ;Subroutine
 SUBROUTINE drcm_dbase_connect(ddc_password,ddc_sid)
   DECLARE dc_retry_ans = i2 WITH protect, noconstant(0)
   DECLARE dc_db_name = vc WITH protect, noconstant(" ")
   DECLARE dc_con_db_name = vc WITH protect, noconstant(" ")
   DECLARE dc_attempt_connection = i2 WITH protect, noconstant(0)
   DECLARE dc_ind = i2 WITH protect, noconstant(0)
   DECLARE dc_db_tab = vc WITH protect, noconstant(" ")
   SET dc_ind = dm2_get_rdbms_version(null)
   IF (dc_ind=0)
    RETURN(- (1))
   ENDIF
   IF ((dm2_rdbms_version->level1 >= 12))
    SET dc_db_tab = "V$PDBS"
   ELSE
    SET dc_db_tab = "V$DATABASE"
   ENDIF
   SELECT INTO "nl:"
    FROM (parser(dc_db_tab) db)
    DETAIL
     dc_db_name = db.name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->emsg = "Get current database name"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   WHILE (dc_attempt_connection=0)
     SET dm2_install_schema->dbase_name = dc_db_name
     SET dm2_install_schema->u_name = "V500"
     SET dm2_install_schema->p_word = ""
     SET dm2_install_schema->connect_str = ""
     EXECUTE dm2_connect_to_dbase "PC"
     IF ((dm_err->err_ind=1))
      IF ((dm_err->emsg="User quit process*"))
       SET retry_ans = drcm_retry_connect("Q")
       IF (retry_ans=1)
        SET dm_err->err_ind = 0
       ELSEIF (retry_ans=2)
        RETURN(- (1))
       ENDIF
      ELSE
       RETURN(- (1))
      ENDIF
     ELSE
      SET ddc_password = dm2_install_schema->p_word
      SET ddc_sid = dm2_install_schema->connect_str
      SELECT INTO "nl:"
       FROM (parser(dc_db_tab) db)
       DETAIL
        dc_con_db_name = db.name
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       SET dm_err->emsg = "Get current database name"
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(- (1))
      ENDIF
      IF (dc_db_name != dc_con_db_name)
       SET retry_ans = drcm_retry_connect("D")
       IF (retry_ans=1)
        SET dm_err->err_ind = 0
       ELSEIF (retry_ans=2)
        RETURN(- (1))
       ENDIF
      ELSE
       SET dc_attempt_connection = 1
      ENDIF
     ENDIF
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drcm_retry_connect(retry_reason)
   CALL clear(1,1)
   SET width = 132
   IF (retry_reason="D")
    CALL text(11,3,
     "   Database connect information provided for WRONG database.  Movers cannot be started.")
    CALL text(13,3,concat("     Menu started in database ",dc_db_name))
    CALL text(14,3,concat("     Connect information provided for database ",dc_con_db_name))
   ELSE
    CALL text(11,3,"   Unable to make database connection")
    CALL text(12,21,"   or")
    CALL text(13,3,"   Database connect information provided is incorrect.")
   ENDIF
   CALL text(20,3,"   Would you like to retry database connection? (Y/N)")
   CALL accept(20,59,"P;CU","N"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    RETURN(1)
   ELSE
    RETURN(2)
    CALL clear(1,1)
    SET width = 132
    CALL text(11,3,"   Please EXIT out of this CCL session and start a new one")
    CALL text(20,20,"Press ENTER to continue")
    CALL accept(20,60,"P;E"," ")
    SET dm_err->eproc = "DATABASE CONNECTION REMOVED. RE-ENTER CCL TO ESTABLISH NEW CONNECTION."
    CALL disp_msg(dm_err->err_msg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN(2)
   ENDIF
 END ;Subroutine
 SUBROUTINE drcm_check_user(null)
   DECLARE dcu_ret = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM prsnl p
    WHERE (p.person_id=reqinfo->updt_id)
     AND cnvtupper(p.username) IN ("SYSTEM", "SYSTEMOE", "CERNER")
    DETAIL
     dcu_ret = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    RETURN(- (1))
   ENDIF
   RETURN(dcu_ret)
 END ;Subroutine
 IF ( NOT (validate(auto_ver_request,0)))
  FREE RECORD auto_ver_request
  RECORD auto_ver_request(
    1 qual[*]
      2 rdds_event = vc
      2 event_reason = vc
      2 cur_environment_id = f8
      2 paired_environment_id = f8
      2 detail_qual[*]
        3 event_detail1_txt = vc
        3 event_detail2_txt = vc
        3 event_detail3_txt = vc
        3 event_value = f8
  )
  FREE RECORD auto_ver_reply
  RECORD auto_ver_reply(
    1 status = c1
    1 status_msg = vc
  )
 ENDIF
 IF (validate(parsed_task_data->request_definition,"-99")="-99")
  FREE RECORD task_info
  RECORD task_info(
    1 process_name = vc
    1 environment_id = f8
    1 qual[*]
      2 error_text = vc
      2 log_file = vc
      2 task_desc = vc
      2 task_level = i4
      2 task_name = vc
      2 task_reply = vc
      2 task_request = vc
    1 total = i4
    1 detail_cnt = i4
    1 detail_qual[*]
      2 event_detail1_txt = vc
      2 event_detail2_txt = vc
      2 event_detail3_txt = vc
      2 event_value = f8
  ) WITH protect
 ENDIF
 IF (validate(parsed_task_data->request_definition,"-99")="-99")
  FREE RECORD parsed_task_data
  RECORD parsed_task_data(
    1 request_definition = vc
    1 var_qual[*]
      2 variable_declaration = vc
    1 var_cnt = i2
    1 set_qual[*]
      2 set_command = vc
    1 set_cnt = i2
    1 reply_definition = vc
    1 error_ind_item = vc
    1 error_msg_item = vc
    1 error_type = vc
    1 no_err_result = vc
  ) WITH protect
 ENDIF
 DECLARE drtq_insert_task_process(i_task_info=vc(ref),i_new_proc_ind=i2) = c1
 DECLARE drtq_update_task_process(i_drtq_id=f8,i_log_file=vc,i_task_status=vc,i_error_text=vc) = c1
 DECLARE drtq_delete_task_process(i_process_name=vc) = c1
 DECLARE drtq_reset_task_process(i_process_name=vc) = c1
 DECLARE drtq_check_task_process(i_process_name=vc) = i2
 DECLARE drtq_parse_task_data(i_task_request=vc,i_task_reply=vc,i_parsed_task_data=vc(ref)) = c1
 DECLARE drtq_extract_val_string(i_tag=vc,io_tagged_str=vc(ref)) = vc
 DECLARE drtq_view_task_process(i_process_name=vc) = null
 SUBROUTINE drtq_insert_task_process(i_task_info,i_new_proc_ind)
   DECLARE ditp_retry_cnt = i2 WITH protect, noconstant(3)
   IF (i_new_proc_ind=1)
    SET stat = alterlist(auto_ver_request->qual,1)
    SET auto_ver_request->qual[1].rdds_event = "Task Queue Started"
    SET auto_ver_request->qual[1].event_reason = cnvtupper(i_task_info->process_name)
    SET auto_ver_request->qual[1].cur_environment_id = i_task_info->environment_id
    SET auto_ver_request->qual[1].paired_environment_id = 0
    SET stat = alterlist(auto_ver_request->qual[1].detail_qual,i_task_info->detail_cnt)
    FOR (i = 1 TO i_task_info->detail_cnt)
      SET auto_ver_request->qual[1].detail_qual[i].event_detail1_txt = i_task_info->detail_qual[i].
      event_detail1_txt
      SET auto_ver_request->qual[1].detail_qual[i].event_detail2_txt = i_task_info->detail_qual[i].
      event_detail2_txt
      SET auto_ver_request->qual[1].detail_qual[i].event_detail3_txt = i_task_info->detail_qual[i].
      event_detail3_txt
      SET auto_ver_request->qual[1].detail_qual[i].event_value = i_task_info->detail_qual[i].
      event_value
    ENDFOR
    EXECUTE dm_rmc_auto_verify_setup
    IF ((auto_ver_reply->status="F"))
     SET dm_err->err_ind = 1
     SET dm_err->emsg = auto_ver_reply->status_msg
     ROLLBACK
     RETURN("F")
    ENDIF
    SET stat = initrec(auto_ver_request)
    SET stat = initrec(auto_ver_reply)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="TASK_RETRY_CNT"
    DETAIL
     ditp_retry_cnt = di.info_number
    WITH nocounter
   ;end select
   IF (check_error("While retrieving override TASK_RETRY_CNT value from DM_INFO") > 0)
    RETURN("F")
   ENDIF
   FOR (ditp_cnt = 1 TO i_task_info->total)
    INSERT  FROM dm_refchg_task_queue drtq
     SET drtq.dm_refchg_task_queue_id = seq(dm_clinical_seq,nextval), drtq.begin_dt_tm = cnvtdatetime
      (curdate,curtime3), drtq.create_dt_tm = cnvtdatetime(curdate,curtime3),
      drtq.error_text = i_task_info->qual[ditp_cnt].error_text, drtq.log_file = i_task_info->qual[
      ditp_cnt].log_file, drtq.process_name = cnvtupper(i_task_info->process_name),
      drtq.rdbhandle_value = - (1), drtq.task_desc = i_task_info->qual[ditp_cnt].task_desc, drtq
      .task_level = i_task_info->qual[ditp_cnt].task_level,
      drtq.task_reply = i_task_info->qual[ditp_cnt].task_reply, drtq.task_request = i_task_info->
      qual[ditp_cnt].task_request, drtq.task_name = i_task_info->qual[ditp_cnt].task_name,
      drtq.task_status = "QUEUED", drtq.task_retry_cnt = ditp_retry_cnt, drtq.updt_id = reqinfo->
      updt_id,
      drtq.updt_task = reqinfo->updt_task, drtq.updt_applctx = reqinfo->updt_applctx, drtq.updt_cnt
       = 0,
      drtq.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
    IF (check_error("While inserting new row into DM_REFCHG_TASK_QUEUE") > 0)
     ROLLBACK
     RETURN("F")
    ENDIF
   ENDFOR
   COMMIT
   RETURN("S")
 END ;Subroutine
 SUBROUTINE drtq_update_task_process(i_drtq_id,i_log_file,i_task_status,i_error_text)
   IF ( NOT (i_task_status IN ("FINISHED", "READY", "RUNNING", "ERROR")))
    CALL disp_msg(concat("'",i_task_status,"' is not a valid task status"),dm_err->logfile,1)
    RETURN("F")
   ELSE
    UPDATE  FROM dm_refchg_task_queue drtq
     SET drtq.task_status = i_task_status, drtq.log_file = i_log_file, drtq.rdbhandle_value =
      cnvtreal(currdbhandle),
      drtq.error_text = i_error_text, drtq.begin_dt_tm =
      IF (i_task_status="RUNNING") cnvtdatetime(curdate,curtime3)
      ELSE drtq.begin_dt_tm
      ENDIF
      , drtq.end_dt_tm =
      IF (i_task_status="FINISHED") cnvtdatetime(curdate,curtime3)
      ELSE drtq.end_dt_tm
      ENDIF
     WHERE drtq.dm_refchg_task_queue_id=i_drtq_id
     WITH nocounter
    ;end update
    IF (check_error(concat("While updating DM_REFCHG_TASK_QUEUE where dm_refchg_task_queue_id = ",
      trim(cnvtstring(i_drtq_id)))) > 0)
     ROLLBACK
     RETURN("F")
    ELSE
     COMMIT
     RETURN("S")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE drtq_delete_task_process(i_process_name)
   DECLARE ddtp_process_name = vc WITH protect, constant(cnvtupper(i_process_name))
   DELETE  FROM dm_refchg_task_queue drtq
    WHERE drtq.process_name=ddtp_process_name
    WITH nocounter
   ;end delete
   IF (check_error(concat("While deleting from DM_REFCHG_TASK_QUEUE where process_name = ",
     ddtp_process_name)) > 0)
    ROLLBACK
    RETURN("F")
   ELSE
    COMMIT
    RETURN("S")
   ENDIF
 END ;Subroutine
 SUBROUTINE drtq_reset_task_process(i_process_name)
   DECLARE drtp_min_lvl = i4 WITH protect, noconstant(0)
   DECLARE drtp_process_name = vc WITH protect, constant(cnvtupper(i_process_name))
   DECLARE drtp_retry_cnt = i2 WITH protect, noconstant(3)
   SELECT INTO "nl:"
    x = min(drtq.task_level)
    FROM dm_refchg_task_queue drtq
    WHERE drtq.process_name=drtp_process_name
     AND drtq.task_status="ERROR"
    DETAIL
     drtp_min_lvl = x
    WITH nocounter
   ;end select
   IF (check_error(concat("While selecting the lowest error task level from ",
     "DM_REFCHG_TASK_QUEUE where process_name = ",drtp_process_name)) > 0)
    RETURN("F")
   ENDIF
   IF (drtp_min_lvl > 0)
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="TASK_RETRY_CNT"
     DETAIL
      drtp_retry_cnt = di.info_number
     WITH nocounter
    ;end select
    IF (check_error("While retrieving override TASK_RETRY_CNT value from DM_INFO") > 0)
     RETURN("F")
    ENDIF
    UPDATE  FROM dm_refchg_task_queue drtq
     SET drtq.task_status = "QUEUED", drtq.task_retry_cnt = drtp_retry_cnt
     WHERE drtq.process_name=drtp_process_name
      AND drtq.task_status="ERROR"
      AND drtq.task_level=drtp_min_lvl
     WITH nocounter
    ;end update
    IF (check_error(concat('While resetting DM_REFCHG_TASK_QUEUE "Error" rows where process_name = ',
      drtp_process_name)) > 0)
     ROLLBACK
     RETURN("F")
    ELSE
     COMMIT
    ENDIF
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE drtq_check_task_process(i_process_name)
   DECLARE dctp_process_name = vc WITH protect, constant(cnvtupper(i_process_name))
   FREE RECORD dctp_tasks
   RECORD dctp_tasks(
     1 qual[*]
       2 task_status = vc
       2 rdbhandle_value = f8
     1 total = i4
   )
   SELECT INTO "nl:"
    FROM dm_refchg_task_queue drtq
    WHERE drtq.process_name=dctp_process_name
    DETAIL
     dctp_tasks->total = (dctp_tasks->total+ 1), stat = alterlist(dctp_tasks->qual,dctp_tasks->total),
     dctp_tasks->qual[dctp_tasks->total].task_status = drtq.task_status,
     dctp_tasks->qual[dctp_tasks->total].rdbhandle_value = drtq.rdbhandle_value
    WITH nocounter
   ;end select
   IF (check_error(concat("While querying DM_REFCHG_TASK_QUEUE where process_name = ",
     dctp_process_name)) > 0)
    RETURN(- (1))
   ELSEIF ((dctp_tasks->total=0))
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(dctp_tasks->total))
    PLAN (d
     WHERE (dctp_tasks->qual[d.seq].task_status != "FINISHED"))
    WITH nocounter
   ;end select
   IF (check_error(concat(
     'While checking for task_statuses other than "FINISHED" for process_name = ',dctp_process_name))
    > 0)
    RETURN(- (1))
   ELSEIF (curqual=0)
    RETURN(2)
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(dctp_tasks->total)),
     gv$session g
    PLAN (d
     WHERE (dctp_tasks->qual[d.seq].task_status != "FINISHED"))
     JOIN (g
     WHERE (g.audsid=dctp_tasks->qual[d.seq].rdbhandle_value))
    WITH nocounter
   ;end select
   IF (curqual=0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(dctp_tasks->total)),
      v$session v
     PLAN (d
      WHERE (dctp_tasks->qual[d.seq].task_status != "FINISHED"))
      JOIN (v
      WHERE (v.audsid=dctp_tasks->qual[d.seq].rdbhandle_value))
     WITH nocounter
    ;end select
   ENDIF
   IF (check_error(concat("While checking for actively running tasks for process_name = ",
     dctp_process_name)) > 0)
    RETURN(- (1))
   ELSEIF (curqual=0)
    RETURN(3)
   ELSE
    RETURN(4)
   ENDIF
 END ;Subroutine
 SUBROUTINE drtq_parse_task_data(i_task_request,i_task_reply,i_parsed_task_data)
   DECLARE dptd_temp_str = vc WITH protect, noconstant("")
   DECLARE dptd_val_str = vc WITH protect, noconstant("")
   SET dptd_val_str = drtq_extract_val_string("VAR_DEF",i_task_request)
   WHILE (dptd_val_str > "")
     SET parsed_task_data->var_cnt = (parsed_task_data->var_cnt+ 1)
     SET stat = alterlist(parsed_task_data->var_qual,parsed_task_data->var_cnt)
     SET parsed_task_data->var_qual[parsed_task_data->var_cnt].variable_declaration = dptd_val_str
     SET dptd_val_str = drtq_extract_val_string("VAR_DEF",i_task_request)
   ENDWHILE
   SET dptd_val_str = drtq_extract_val_string("VAL_SET",i_task_request)
   WHILE (dptd_val_str > "")
     SET parsed_task_data->set_cnt = (parsed_task_data->set_cnt+ 1)
     SET stat = alterlist(parsed_task_data->set_qual,parsed_task_data->set_cnt)
     SET parsed_task_data->set_qual[parsed_task_data->set_cnt].set_command = dptd_val_str
     SET dptd_val_str = drtq_extract_val_string("VAL_SET",i_task_request)
   ENDWHILE
   SET parsed_task_data->request_definition = drtq_extract_val_string("REC_DEF",i_task_request)
   SET parsed_task_data->error_ind_item = drtq_extract_val_string("ERR_IND",i_task_reply)
   SET parsed_task_data->error_msg_item = drtq_extract_val_string("ERR_MSG",i_task_reply)
   SET parsed_task_data->error_type = drtq_extract_val_string("ERR_TYPE",i_task_reply)
   SET parsed_task_data->no_err_result = drtq_extract_val_string("NO_ERR_RESULT",i_task_reply)
   SET parsed_task_data->reply_definition = drtq_extract_val_string("REC_DEF",i_task_reply)
   IF (check_error("While parsing the task_request and task_reply data") > 0)
    RETURN("F")
   ELSE
    RETURN("S")
   ENDIF
 END ;Subroutine
 SUBROUTINE drtq_extract_val_string(i_tag,io_tagged_str)
   DECLARE devs_start = i4 WITH protect, noconstant(0)
   DECLARE devs_end = i4 WITH protect, noconstant(0)
   DECLARE devs_len = i4 WITH protect, noconstant(0)
   DECLARE devs_val_str = vc WITH protect, noconstant("")
   SET devs_start = findstring(concat("<",i_tag,">"),io_tagged_str)
   IF (devs_start=0)
    RETURN("")
   ENDIF
   SET devs_end = findstring(concat("</",i_tag,">"),io_tagged_str,devs_start)
   IF (devs_end=0)
    RETURN("")
   ENDIF
   SET devs_len = size(i_tag,1)
   SET devs_val_str = substring(((devs_start+ devs_len)+ 2),(devs_end - ((devs_start+ devs_len)+ 2)),
    io_tagged_str)
   SET io_tagged_str = concat(substring(1,(devs_start - 1),io_tagged_str),substring(((devs_end+
     devs_len)+ 3),(size(io_tagged_str,1) - ((devs_end+ devs_len)+ 2)),io_tagged_str))
   RETURN(devs_val_str)
 END ;Subroutine
 SUBROUTINE drtq_view_task_process(i_process_name)
   DECLARE dvtp_temp_str = vc WITH protect, noconstant("")
   DECLARE dvtp_temp_int = i2 WITH protect, noconstant(0)
   DECLARE dvtp_spacer_str = vc WITH protect, constant(fillstring(60,"-"))
   DECLARE dvtp_ndx = i2 WITH protect, noconstant(0)
   DECLARE dvtp_refresh = c1 WITH protect, noconstant("R")
   DECLARE dvtp_process_name = vc WITH protect, constant(cnvtupper(i_process_name))
   DECLARE dvtp_header = vc WITH protect, constant(concat("*** RDDS ",dvtp_process_name,
     " STATUS REPORT ***"))
   DECLARE dvtp_header_offset = i2 WITH protect, constant(ceil(((129 - size(dvtp_header,1))/ 2)))
   FREE RECORD dvtp_tasks
   RECORD dvtp_tasks(
     1 completed_count = i2
     1 error_count = i2
     1 total = i4
   )
   SET message = window
   SET accept = time(30)
   WHILE (dvtp_refresh="R")
     UPDATE  FROM dm_refchg_task_queue d
      SET d.task_status = "QUEUED", d.task_retry_cnt = (d.task_retry_cnt - 1), d.rdbhandle_value =
       - (1),
       d.log_file = null, d.begin_dt_tm = null, d.end_dt_tm = null,
       d.updt_id = reqinfo->updt_id, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_applctx =
       reqinfo->updt_applctx,
       d.updt_task = reqinfo->updt_task, d.updt_cnt = (d.updt_cnt+ 1)
      WHERE d.task_status="RUNNING"
       AND d.task_retry_cnt > 0
       AND  NOT ( EXISTS (
      (SELECT
       "x"
       FROM gv$session gv
       WHERE gv.audsid=d.rdbhandle_value)))
       AND  NOT ( EXISTS (
      (SELECT
       "x"
       FROM v$session v
       WHERE v.audsid=d.rdbhandle_value)))
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN
     ELSE
      COMMIT
     ENDIF
     IF (curqual > 0)
      UPDATE  FROM dm_refchg_task_queue d
       SET d.task_status = "ERROR", d.error_text =
        "Task has failed on all retries, session id remains inactive"
       WHERE d.task_status="QUEUED"
        AND (d.rdbhandle_value=- (1))
        AND d.task_retry_cnt=0
       WITH nocounter
      ;end update
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN
      ELSE
       COMMIT
      ENDIF
     ENDIF
     SELECT INTO "nl:"
      drtq.task_status, y = count(drtq.task_status)
      FROM dm_refchg_task_queue drtq
      WHERE drtq.process_name=dvtp_process_name
      GROUP BY drtq.task_status
      HEAD REPORT
       dvtp_tasks->total = 0, dvtp_tasks->error_count = 0, dvtp_tasks->completed_count = 0
      DETAIL
       dvtp_tasks->total = (dvtp_tasks->total+ y)
       IF (drtq.task_status="FINISHED")
        dvtp_tasks->completed_count = y
       ENDIF
       IF (drtq.task_status="ERROR")
        dvtp_tasks->error_count = y
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN
     ENDIF
     CALL clear(1,1)
     SET width = 132
     CALL text(1,dvtp_header_offset,dvtp_header)
     CALL text(3,1,concat("Report Created: ",format(cnvtdatetime(curdate,curtime3),
        "DD-MMM-YYYY HH:MM;;D")," (list will auto-refresh every 30 seconds)"))
     CALL text(5,1,concat("Tasks Completed: ",trim(cnvtstring(dvtp_tasks->completed_count)),
       " out of ",trim(cnvtstring(dvtp_tasks->total))," total"))
     CALL text(6,1,concat("Number of Tasks with Errors: ",trim(cnvtstring(dvtp_tasks->error_count))))
     CALL text(8,1,"Tasks currently in progress (up to 12 tasks will be displayed):")
     CALL text(9,1,"Task Description")
     CALL text(9,101,"Execution Start Time")
     CALL text(10,1,fillstring(120,"-"))
     IF ((dvtp_tasks->total=0))
      CALL text(15,20,concat("No tasks have been detected for ",dvtp_process_name,"."))
     ELSE
      SELECT INTO "nl:"
       FROM dm_refchg_task_queue drtq
       WHERE drtq.process_name=dvtp_process_name
        AND drtq.task_status="RUNNING"
       ORDER BY drtq.task_level
       HEAD REPORT
        dvtp_ndx = 11
       DETAIL
        CALL text(dvtp_ndx,1,drtq.task_desc),
        CALL text(dvtp_ndx,104,format(drtq.begin_dt_tm,"DD-MMM-YYYY HH:MM;;D")), dvtp_ndx = (dvtp_ndx
        + 1)
       WITH nocounter, maxqual(drtq,12)
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN
      ENDIF
     ENDIF
     CALL text(23,1,fillstring(120,"-"))
     CALL text(24,1,"Command Options:")
     SET accept = nopatcheck
     IF ((dvtp_tasks->error_count > 0))
      CALL text(24,20,"(R)efresh, (V)iew All Task Details , View (E)rror Details, e(X)it")
      CALL accept(24,18,"P;CU","R"
       WHERE curaccept IN ("R", "V", "E", "X"))
     ELSE
      CALL text(24,20,"(R)efresh, (V)iew All Task Details , e(X)it")
      CALL accept(24,18,"P;CU","R"
       WHERE curaccept IN ("R", "V", "X"))
     ENDIF
     SET accept = patcheck
     SET dvtp_refresh = curaccept
     IF (dvtp_refresh="V")
      SELECT
       task_level = drtq.task_level, task_description = drtq.task_desc, task_status = drtq
       .task_status,
       start_time = format(drtq.begin_dt_tm,"DD-MMM-YYYY HH:MM;;D"), end_time = format(drtq.end_dt_tm,
        "DD-MMM-YYYY HH:MM;;D")
       FROM dm_refchg_task_queue drtq
       WHERE drtq.process_name=dvtp_process_name
       ORDER BY drtq.task_level
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN
      ENDIF
      SET dvtp_refresh = "R"
     ELSEIF (dvtp_refresh="E")
      SELECT
       FROM dm_refchg_task_queue drtq
       WHERE process_name=dvtp_process_name
        AND task_status="ERROR"
       HEAD REPORT
        col dvtp_header_offset, dvtp_header, row + 2,
        col 0, "Report Created:", dvtp_temp_str = format(cnvtdatetime(curdate,curtime3),
         "DD-MMM-YYYY HH:MM;;D"),
        col + 1, dvtp_temp_str, row + 2,
        col 0, "Tasks Completed: ", dvtp_temp_str = trim(cnvtstring(dvtp_tasks->completed_count)),
        col + 1, dvtp_temp_str, " out of ",
        dvtp_temp_str = trim(cnvtstring(dvtp_tasks->total)), col + 1, dvtp_temp_str,
        " total", row + 2, col 0,
        "The following tasks are in a failed status:", row + 1, col 0,
        dvtp_spacer_str
       DETAIL
        row + 2, col 0, "Task Description:",
        col 18, drtq.task_desc, row + 1,
        "Log File Name:", col 18, drtq.log_file,
        row + 1, "Error Message:", dvtp_ndx = 1,
        dvtp_temp_int = size(trim(drtq.error_text),1), dvtp_temp_str = trim(substring(dvtp_ndx,100,
          drtq.error_text)), col 18,
        dvtp_temp_str, dvtp_ndx = (dvtp_ndx+ 100)
        WHILE (dvtp_ndx < dvtp_temp_int)
          row + 1, dvtp_temp_str = trim(substring(dvtp_ndx,100,drtq.error_text)), col 18,
          dvtp_temp_str, dvtp_ndx = (dvtp_ndx+ 100)
        ENDWHILE
        row + 2, col 0, dvtp_spacer_str
       FOOT REPORT
        row + 2, col 52, "*** END OF REPORT ***"
       WITH nocounter, formfeed = none
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN
      ENDIF
      SET dvtp_refresh = "R"
     ENDIF
   ENDWHILE
   SET accept = time(0)
   SET message = nowindow
 END ;Subroutine
 DECLARE drrm_ack_mig(dam_oe_name=vc,dam_env_id=f8) = null
 DECLARE drrm_check_ack(dca_oe_name=vc) = i2
 DECLARE drrm_check_mig(dcm_check_ack_ind=i2,dcm_oe_name=vc) = i4
 DECLARE drrm_check_freeze(dcf_env_id=f8) = i2
 IF ( NOT (validate(auto_ver_request,0)))
  FREE RECORD auto_ver_request
  RECORD auto_ver_request(
    1 qual[*]
      2 rdds_event = vc
      2 event_reason = vc
      2 cur_environment_id = f8
      2 paired_environment_id = f8
      2 detail_qual[*]
        3 event_detail1_txt = vc
        3 event_detail2_txt = vc
        3 event_detail3_txt = vc
        3 event_value = f8
  )
  FREE RECORD auto_ver_reply
  RECORD auto_ver_reply(
    1 status = c1
    1 status_msg = vc
  )
 ENDIF
 SUBROUTINE drrm_ack_mig(dam_oe_name,dam_env_id)
   IF (size(trim(dam_oe_name))=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "No event name passed into DRRM_ACK_MIG."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   SET stat = alterlist(auto_ver_request->qual,1)
   SET auto_ver_request->qual[1].rdds_event = "MIGRATION ACKNOWLEDGE"
   SET auto_ver_request->qual[1].event_reason = dam_oe_name
   IF (dam_env_id=0.0)
    SELECT INTO "NL:"
     FROM dm_info d
     WHERE d.info_domain="DATA MANAGEMENT"
      AND d.info_name="DM_ENV_ID"
     DETAIL
      auto_ver_request->qual[1].cur_environment_id = d.info_number
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET stat = initrec(auto_ver_request)
     RETURN(null)
    ENDIF
    IF ((auto_ver_request->qual[1].cur_environment_id=0))
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "No environment_id found.  Please run DM_SET_ENV_ID to correct."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET stat = initrec(auto_ver_request)
     RETURN(null)
    ENDIF
   ELSE
    SET auto_ver_request->qual[1].cur_environment_id = dam_env_id
   ENDIF
   EXECUTE dm_rmc_auto_verify_setup
   IF ((auto_ver_reply->status="F"))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = auto_ver_reply->status_msg
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ELSE
    COMMIT
   ENDIF
   SET stat = initrec(auto_ver_reply)
   SET stat = initrec(auto_ver_request)
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drrm_check_ack(dca_oe_name)
   DECLARE dca_return = i2 WITH protect, noconstant(0)
   IF (size(trim(dca_oe_name)) > 0)
    SELECT INTO "NL:"
     cnt = count(*)
     FROM dm_rdds_event_log d,
      dm_info di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="DM_ENV_ID"
      AND d.cur_environment_id=di.info_number
      AND d.rdds_event_key="MIGRATIONACKNOWLEDGE"
      AND d.event_reason=dca_oe_name
     DETAIL
      IF (cnt > 0)
       dca_return = 1
      ENDIF
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "NL:"
     cnt = count(*)
     FROM dm_rdds_event_log d2,
      dm_rdds_event_log d,
      dm_info di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="DM_ENV_ID"
      AND d.cur_environment_id=di.info_number
      AND d.rdds_event_key="MIGRATIONACKNOWLEDGE"
      AND d2.cur_environment_id=d.cur_environment_id
      AND d2.event_reason=d.event_reason
      AND d2.rdds_event_key="BEGINREFERENCEDATASYNC"
      AND  NOT (list(d2.cur_environment_id,d2.paired_environment_id,d2.event_reason) IN (
     (SELECT
      d3.cur_environment_id, d3.paired_environment_id, d3.event_reason
      FROM dm_rdds_event_log d3
      WHERE d3.rdds_event_key="ENDREFERENCEDATASYNC"
       AND d3.cur_environment_id=di.info_number)))
     DETAIL
      IF (cnt > 0)
       dca_return = cnt
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
   RETURN(dca_return)
 END ;Subroutine
 SUBROUTINE drrm_check_mig(dcm_ack_ind,dcm_oe_name)
   DECLARE PUBLIC::dcm_return = i4 WITH protect, noconstant(0)
   DECLARE PUBLIC::dcm_ack_ret = i2 WITH protect, noconstant(0)
   DECLARE PUBLIC::dcm_script_name = vc WITH protect, noconstant("DM2_MIG_STATUS_CHECK")
   IF (validate(PUBLIC::dm2_mig_status,"-1")="-1")
    DECLARE PUBLIC::dm2_mig_status = vc WITH protect, noconstant("")
   ENDIF
   IF (validate(PUBLIC::dm2_mig_utc_status,"-1")="-1")
    DECLARE PUBLIC::dm2_mig_utc_status = vc WITH protect, noconstant("")
   ENDIF
   IF (checkprg(dcm_script_name) > 0)
    EXECUTE dm2_mig_status_check
    IF (((check_error(dm_err->eproc)=1) OR (((cnvtupper(dm2_mig_status) IN ("", "ERROR")) OR (
    cnvtupper(dm2_mig_utc_status) IN ("", "ERROR"))) )) )
     IF (size(trim(dm_err->emsg))=0)
      SET dm_err->emsg = "Unexpected error occurred in DM2_MIG_STATUS_CHECK"
      SET dm_err->err_ind = 1
     ENDIF
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (cnvtupper(dm2_mig_status)="ON")
     IF (cnvtupper(dm2_mig_utc_status)="ON")
      SET dcm_return = 2
     ELSE
      SET dcm_return = 1
     ENDIF
     IF (dcm_ack_ind=1)
      SET dcm_ack_ret = drrm_check_ack(dcm_oe_name)
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      IF (dcm_ack_ret=1)
       SET dcm_return = 0
      ENDIF
     ENDIF
    ELSE
     SET dcm_return = 0
    ENDIF
   ELSE
    SET dcm_return = 0
   ENDIF
   RETURN(dcm_return)
 END ;Subroutine
 SUBROUTINE drrm_check_freeze(dcf_env_id)
   DECLARE dcf_ret_val = i2 WITH protect, noconstant(0)
   DECLARE dcf_freeze_ind = i2 WITH protect, noconstant(0)
   DECLARE dcf_ovr_ind = i2 WITH protect, noconstant(0)
   DECLARE dcf_mig_domain = vc WITH protect, constant("DM2_MIG_STATUS_MARKER")
   DECLARE dcf_ovr_domain = vc WITH protect, constant("RDDS MIGRATION OVERRIDE")
   SELECT INTO "NL:"
    FROM dm_info di
    WHERE di.info_name="SCHEMA_FREEZE"
     AND di.info_domain IN (dcf_mig_domain, dcf_ovr_domain)
    DETAIL
     IF (di.info_domain=dcf_mig_domain)
      dcf_freeze_ind = 1
     ELSEIF (di.info_domain=dcf_ovr_domain
      AND di.info_number=dcf_env_id
      AND di.info_date >= cnvtdatetime(curdate,curtime3))
      dcf_ovr_ind = 1
     ENDIF
    FOOT REPORT
     IF (dcf_freeze_ind=1
      AND dcf_ovr_ind=0)
      dcf_ret_val = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(dcf_ret_val)
 END ;Subroutine
 DECLARE drr_env_id = f8 WITH protect, noconstant(0.0)
 DECLARE drr_env_name = vc WITH protect, noconstant(" ")
 DECLARE drr_accept = vc WITH protect, noconstant(" ")
 DECLARE drr_text = vc WITH protect, noconstant(" ")
 DECLARE drr_task_cnt = i4 WITH protect, noconstant(0)
 DECLARE drr_proc_cnt = i4 WITH protect, noconstant(0)
 DECLARE drr_ndx = i4 WITH protect, noconstant(0)
 DECLARE drr_cur_logfile = vc WITH protect, noconstant(" ")
 DECLARE nohup_submit_logfile = vc WITH protect, noconstant(" ")
 DECLARE drr_execute_str = vc WITH protect, noconstant(" ")
 DECLARE drr_db_password = vc WITH protect, noconstant(" ")
 DECLARE drr_db_sid = vc WITH protect, noconstant(" ")
 DECLARE drr_dcl_stat = i4 WITH protect, noconstant(0)
 DECLARE drr_nvld_user = i2 WITH protect, noconstant(0)
 DECLARE drr_db_link_cnt = i4 WITH protect, noconstant(0)
 FREE RECORD drr_info
 RECORD drr_info(
   1 env_id = f8
   1 env_name = vc
   1 event_dt_tm = f8
   1 event_reason = vc
   1 event_src_id = f8
   1 cutover_dt_tm = f8
   1 mover_dt_tm = f8
   1 uncutover_r_cnt = i4
   1 missing_def_ind = i2
   1 mover_ind = i2
   1 cutover_ind = i2
 )
 DECLARE drr_get_rdds_info(dgri_info=vc(ref)) = i2
 DECLARE drr_write_header(dwh_info=vc(ref)) = null
 IF (check_logfile("dm_rdds_remove",".log","DM_RDDS_REMOVE LOG")=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to Create Log File"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Starting dm_rdds_remove"
 CALL disp_msg("",dm_err->logfile,0)
 SET dm_err->eproc = "Gathering local environment information"
 SELECT INTO "nl:"
  FROM dm_info a,
   dm_environment b
  WHERE a.info_name="DM_ENV_ID"
   AND a.info_domain="DATA MANAGEMENT"
   AND a.info_number=b.environment_id
  DETAIL
   drr_info->env_id = b.environment_id, drr_info->env_name = b.environment_name
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc) != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ELSEIF ((drr_info->env_id=0))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "No local environment_id set.  Please use DM_SET_ENV_ID to set one."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (drrm_check_mig(0,"") > 0)
  SET dm_err->eproc = "Checking for migration status."
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat(
   "It has been detected that a database migration is in progress.  The removal of RDDS should not be ",
   "run while a migration is still in process.")
  CALL check_error_gui(dm_err->eproc,"RDDS Remove Process",drr_info->env_name,drr_info->env_id)
  SET message = nowindow
  GO TO exit_program
 ENDIF
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 SET message = window
 CALL drr_write_header(drr_info)
 IF (curgroup != 0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "User Group 0 required to run the RDDS remove process."
  CALL check_error_gui("Check if user is dba","RDDS Remove Process",drr_info->env_name,drr_info->
   env_id)
  SET message = nowindow
  GO TO exit_program
 ENDIF
 IF ((validate(xxcclseclogin->loggedin,- (99)) != - (99)))
  SET dm_err->eproc = "Gathering cclseclogin information"
  IF ((xxcclseclogin->loggedin != 1))
   CALL clear(6,1)
   CALL text(10,22,"WARNING: The next few screens will prompt you for CCLSECLOGIN information. ")
   CALL text(11,22,"The following accounts cannot be used: SYSTEM, CERNER, SYSTEMOE.")
   CALL text(12,22,"Please have this information ready!")
   CALL text(24,3,"Would you like to continue?(Y/N)")
   CALL accept(24,40,"P;CU"," "
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    CALL clear(1,1)
    CALL parser("cclseclogin go")
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->emsg = ""
     SET dm_err->err_ind = 0
    ENDIF
    IF ((xxcclseclogin->loggedin != 1))
     SET dm_err->eproc = "RDDS Remove process"
     SET dm_err->emsg = "User not logged in cclseclogin"
     SET dm_err->err_ind = 1
     CALL check_error_gui(dm_err->eproc,"RDDS Remove Process",drr_info->env_name,drr_info->env_id)
     GO TO exit_program
    ENDIF
    CALL drr_write_header(drr_info)
   ELSE
    GO TO exit_program
   ENDIF
  ENDIF
  SET drr_nvld_user = drcm_check_user(null)
  IF (drr_nvld_user < 0)
   CALL check_error_gui(dm_err->eproc,"RDDS Remove Process",drr_info->env_name,drr_info->env_id)
   GO TO exit_program
  ELSEIF (drr_nvld_user=1)
   SET dm_err->err_ind = 1
   SET dm_err->emsg =
   "RESTRICTED USER. Please exit your ccl session and sign in as a user other than SYSTEM, SYSTEMOE, or CERNER"
   CALL check_error_gui(dm_err->eproc,"RDDS Remove Process",drr_info->env_name,drr_info->env_id)
   GO TO exit_program
  ENDIF
 ENDIF
 CALL video(b)
 CALL text(12,45,"Gathering RDDS data.  Please wait...")
 CALL video(n)
 SET dm_err->eproc = "Gathering RDDS information for local domain"
 IF (drr_get_rdds_info(drr_info) > 0)
  CALL check_error_gui(dm_err->eproc,"RDDS Remove Process",drr_info->env_name,drr_info->env_id)
  GO TO exit_program
 ENDIF
 CALL clear(7,1)
 CALL text(11,50,"!!! WARNING !!!")
 CALL text(12,5,
  "Continue with the following process only if RDDS is not used any longer.  Consult with the Integration Architect "
  )
 CALL text(13,5,
  "and the IP Strategist for RDDS to verify that RDDS is not actively used in these domains.  There is no "
  )
 CALL text(14,5,"recovery from these actions.")
 CALL text(16,5,
  "Once these steps are completed, the only way to use RDDS again will require completion of the ")
 CALL text(17,5,
  "Domain Copy process (replicate or refresh to create fresh domains) and new setup of RDDS configuration."
  )
 CALL text(24,3,"Would you like to continue?(Y/N)")
 CALL accept(24,40,"P;CU"," "
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="N")
  GO TO exit_program
 ENDIF
 CALL clear(7,1)
 CALL text(7,5,"WARNING - This process will remove all RDDS information from this domain.")
 CALL text(8,5,"Please review the following information carefully before continuing.")
 CALL text(10,5,"Date current event was opened: ")
 IF ((drr_info->event_dt_tm=0))
  SET drr_text = "No Open Event"
 ELSE
  SET drr_text = concat(format(drr_info->event_dt_tm,"dd-mmm-yy HH:MM:SS;;q")," (",drr_info->
   event_reason,")")
 ENDIF
 CALL text(10,45,drr_text)
 CALL text(11,5,"Date of last mover run: ")
 IF ((drr_info->mover_dt_tm=0))
  SET drr_text = "No Mover Run detected"
 ELSE
  SET drr_text = format(drr_info->mover_dt_tm,"dd-mmm-yy HH:MM:SS;;q")
 ENDIF
 CALL text(11,45,drr_text)
 CALL text(12,5,"Date of last cutover run: ")
 IF ((drr_info->cutover_dt_tm=0))
  SET drr_text = "No Cutover detected"
 ELSE
  SET drr_text = format(drr_info->cutover_dt_tm,"dd-mmm-yy HH:MM:SS;;q")
 ENDIF
 CALL text(12,45,drr_text)
 CALL text(13,5,"Mover processes running:")
 IF ((drr_info->mover_ind=1))
  SET drr_text = "Yes"
 ELSE
  SET drr_text = "No"
 ENDIF
 CALL text(13,45,drr_text)
 CALL text(14,5,"Cutover processes running:")
 IF ((drr_info->cutover_ind=1))
  SET drr_text = "Yes"
 ELSE
  SET drr_text = "No"
 ENDIF
 CALL text(14,45,drr_text)
 CALL text(15,5,"$R tables with uncutover rows: ")
 SET drr_text = cnvtstring(drr_info->uncutover_r_cnt)
 CALL text(15,45,drr_text)
 IF ((drr_info->missing_def_ind=1))
  CALL text(16,5,
   "*** Warning: Missing ccl $R definitions; uncutover count does not contain all data ***")
 ENDIF
 CALL text(24,3,"Would you like to continue?(Y/N)")
 CALL accept(24,40,"P;CU"," "
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="N")
  GO TO exit_program
 ENDIF
 CALL clear(7,1)
 CALL text(12,3,"    How many RDDS remove processes do you want to start (minimum of 1): ")
 CALL accept(12,80,"99",4
  WHERE curaccept > 0)
 SET drr_proc_cnt = curaccept
 IF (drcm_dbase_connect(drr_db_password,drr_db_sid) < 0)
  GO TO exit_program
 ENDIF
 IF (drtq_delete_task_process("REMOVE RDDS PROCESS")="F")
  SET dm_err->err_ind = 1
  GO TO exit_program
 ENDIF
 SET stat = initrec(task_info)
 SET task_info->environment_id = drr_info->env_id
 SET task_info->process_name = "REMOVE RDDS PROCESS"
 SET drr_task_cnt = 11
 SET stat = alterlist(task_info->qual,drr_task_cnt)
 SET task_info->total = (task_info->total+ 1)
 SET task_info->qual[task_info->total].task_level = 100
 SET task_info->qual[task_info->total].task_desc = "Stopping data movers"
 SET task_info->qual[task_info->total].task_name = "execute DM_RDDS_REMOVE_STOP_MOVERS go"
 IF ((drr_info->event_dt_tm > 0))
  SET task_info->total = (task_info->total+ 1)
  SET task_info->qual[task_info->total].task_level = 150
  SET task_info->qual[task_info->total].task_desc = "Closing an event"
  SET task_info->qual[task_info->total].task_name = "execute DM_RMC_AUTO_VERIFY_SETUP go"
  SET task_info->qual[task_info->total].task_request = replace(replace(replace(concat(
      "<REC_DEF>record auto_ver_request (1 QUAL[*] 2 rdds_event = VC 2 event_reason = VC 2 cur_environment_id = F8 ",
      "2 paired_environment_id = F8 2 detail_qual[*] 3 event_detail1_txt = VC 3 event_detail2_txt = VC 3 event_detail3_txt = VC",
      " 3 event_value = f8) go</REC_DEF> ",
      "<VAL_SET>set stat = alterlist(auto_ver_request->qual,1) go</VAL_SET> ",
      "<VAL_SET>set auto_ver_request->qual[1].rdds_event = 'End Reference Data Sync' go</VAL_SET> ",
      "<VAL_SET>set auto_ver_request->qual[1].cur_environment_id = <tgt_env_id>.0 go</VAL_SET> ",
      "<VAL_SET>set auto_ver_request->qual[1].paired_environment_id = <src_env_id>.0 go</VAL_SET> ",
      "<VAL_SET>set auto_ver_request->qual[1].event_reason = '<EVENT_NAME>' go</VAL_SET> "),
     "<src_env_id>",trim(cnvtstring(drr_info->event_src_id)),0),"<tgt_env_id>",trim(cnvtstring(
      drr_info->env_id)),0),"<EVENT_NAME>",drr_info->event_reason,0)
  SET task_info->qual[task_info->total].task_reply = concat(
   "<REC_DEF>record auto_ver_reply(1 STATUS=C1 1 STATUS_MSG=VC) go</REC_DEF> ",
   "<ERR_IND>auto_ver_reply->STATUS</ERR_IND> ","<ERR_MSG>auto_ver_reply->STATUS_MSG</ERR_MSG> ",
   "<ERR_TYPE>VC</ERR_TYPE> ","<NO_ERR_RESULT>S</NO_ERR_RESULT>")
 ENDIF
 SET task_info->total = (task_info->total+ 1)
 SET task_info->qual[task_info->total].task_level = 200
 SET task_info->qual[task_info->total].task_desc = "Dropping environment relationships"
 SET task_info->qual[task_info->total].task_name = "execute DM_RMC_REM_ENV_RELTN go"
 SET task_info->total = (task_info->total+ 1)
 SET task_info->qual[task_info->total].task_level = 250
 SET task_info->qual[task_info->total].task_desc = "Dropping all RDDS logging triggers"
 SET task_info->qual[task_info->total].task_name = "execute DM2_DROP_REFCHG_LOG_TRIGGERS go"
 SET task_info->total = (task_info->total+ 1)
 SET task_info->qual[task_info->total].task_level = 300
 SET task_info->qual[task_info->total].task_desc = "Dropping all $R tables"
 SET task_info->qual[task_info->total].task_name = "execute DM_RMC_DROP_ALL_R go"
 SET task_info->total = (task_info->total+ 1)
 SET task_info->qual[task_info->total].task_level = 350
 SET task_info->qual[task_info->total].task_desc = "Dropping RDDS sql objects"
 SET task_info->qual[task_info->total].task_name = "execute DM_RMC_REM_PLSQL go"
 SET task_info->total = (task_info->total+ 1)
 SET task_info->qual[task_info->total].task_level = 350
 SET task_info->qual[task_info->total].task_desc = "Purging RDDS tables"
 SET task_info->qual[task_info->total].task_name = "execute DM_RMC_TRUNC_RDDS go"
 SET task_info->total = (task_info->total+ 1)
 SET task_info->qual[task_info->total].task_level = 350
 SET task_info->qual[task_info->total].task_desc = "Removing environment RDDS data"
 SET task_info->qual[task_info->total].task_name = "execute DM_RMC_DI_DEL go"
 SET task_info->total = (task_info->total+ 1)
 SET task_info->qual[task_info->total].task_level = 350
 SET task_info->qual[task_info->total].task_desc = "Cleaning up RDDS code-sets"
 SET task_info->qual[task_info->total].task_name = "execute DM_RMC_CV_UPD go"
 SET task_info->total = (task_info->total+ 1)
 SET task_info->qual[task_info->total].task_level = 360
 SET task_info->qual[task_info->total].task_desc = "Dropping cutover by context triggers"
 SET task_info->qual[task_info->total].task_name = "execute DM_RMC_CREATE_DMT_TRIG go"
 SET stat = alterlist(task_info->qual,task_info->total)
 SET dm_err->eproc = "Gathering list of database links to drop."
 SELECT INTO "nl:"
  FROM dba_db_links l
  WHERE l.owner="V500"
   AND l.db_link=patstring(concat("MERGE*",trim(cnvtstring(drr_info->env_id,20)),".WORLD"))
  DETAIL
   drr_db_link_cnt = (drr_db_link_cnt+ 1), task_info->total = (task_info->total+ 1), stat = alterlist
   (task_info->qual,task_info->total),
   task_info->qual[task_info->total].task_level = 900, task_info->qual[task_info->total].task_desc =
   "Dropping database links", task_info->qual[task_info->total].task_name =
   "execute DM_PARSE_STMT go",
   task_info->qual[task_info->total].task_request = concat(
    "<REC_DEF>record dps_stmt_in( 1 stmt_cnt = i4 1 qual[*] 2 stmt = vc) go</REC_DEF> ",
    "<VAL_SET>set dps_stmt_in->stmt_cnt = 1 go</VAL_SET>",
    "<VAL_SET>set stat = alterlist(dps_stmt_in->qual,dps_stmt_in->stmt_cnt) go</VAL_SET> ",
    "<VAL_SET>set dps_stmt_in->qual[1].stmt = ","'rdb drop database link ",
    trim(replace(l.db_link,".WORLD","",0))," go' go</VAL_SET> "), task_info->qual[task_info->total].
   task_reply = concat(
    "<REC_DEF>record dps_stmt_out( 1 stmt_curqual = i4 1 err_ind = i2 1 err_msg = vc) go</REC_DEF> ",
    "<ERR_IND>dps_stmt_out->err_ind</ERR_IND> ","<ERR_MSG>dps_stmt_out->err_msg</ERR_MSG> ",
    "<ERR_TYPE>I4</ERR_TYPE> ","<NO_ERR_RESULT>0</NO_ERR_RESULT>")
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc) != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Inserting RDDS remove tasks"
 IF (drtq_insert_task_process(task_info,1)="F")
  SET dm_err->err_ind = 1
  GO TO exit_program
 ENDIF
 FOR (drr_ndx = 1 TO drr_proc_cnt)
   SET drr_cur_logfile = dm_err->unique_fname
   IF (get_unique_file("rdds_run_proc",".log")=0)
    SET nohup_submit_logfile = "rdds_run_proc.log"
    SET dm_err->err_ind = 0
   ELSE
    SET nohup_submit_logfile = dm_err->unique_fname
   ENDIF
   SET dm_err->unique_fname = drr_cur_logfile
   SET drr_execute_str = concat("nohup $cer_proc/rdds_run_proc.ksh 'REMOVE RDDS PROCESS' ",
    drr_db_password," ",drr_db_sid," > $CCLUSERDIR/",
    nohup_submit_logfile," 2>&1 &")
   CALL echo(drr_execute_str)
   CALL dcl(drr_execute_str,size(drr_execute_str),drr_dcl_stat)
   IF (drr_dcl_stat=0)
    SET dm_err->eproc = concat("Error connecting to: ",cnvtstring(drr_dcl_stat))
    CALL disp_msg(" ",dm_err->logfile,0)
    GO TO exit_program
   ENDIF
 ENDFOR
 CALL drr_write_header(drr_info)
 CALL text(15,03,concat("  You can use DM_RDDS_REMOVE_MON program to monitor the processes running.")
  )
 CALL text(16,03,
  "  For details on each RDDS remove process started, view the rdds_run_proc*.log file(s) in CCLUSERDIR."
  )
 CALL text(24,20,"Press ENTER to continue")
 CALL accept(24,60,"P;HCU","N")
 SUBROUTINE drr_get_rdds_info(dgri_info)
   FREE RECORD r_tab
   RECORD r_tab(
     1 cnt = i4
     1 qual[*]
       2 tab_name = vc
       2 ccl_def_ind = i2
   )
   DECLARE dgri_idx = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Gathering open event information"
   SELECT INTO "NL:"
    FROM dm_rdds_event_log d
    WHERE (d.cur_environment_id=dgri_info->env_id)
     AND d.rdds_event_key="BEGINREFERENCEDATASYNC"
     AND  NOT (list(d.paired_environment_id,d.event_reason) IN (
    (SELECT
     d1.paired_environment_id, d1.event_reason
     FROM dm_rdds_event_log d1
     WHERE (d1.cur_environment_id=dgri_info->env_id)
      AND d1.rdds_event_key="ENDREFERENCEDATASYNC")))
    DETAIL
     dgri_info->event_dt_tm = d.event_dt_tm, dgri_info->event_reason = d.event_reason, dgri_info->
     event_src_id = d.paired_environment_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Gathering mover and cutover information"
   SELECT INTO "nl:"
    drel.rdds_event_key, y_dt_tm = max(drel.event_dt_tm)
    FROM dm_rdds_event_log drel
    WHERE (drel.cur_environment_id=dgri_info->env_id)
     AND drel.rdds_event_key IN ("CUTOVERPROCESSSTARTED", "STARTINGRDDSMOVERS")
    GROUP BY drel.rdds_event_key
    DETAIL
     IF (drel.rdds_event_key="STARTINGRDDSMOVERS")
      dgri_info->mover_dt_tm = y_dt_tm
     ELSE
      dgri_info->cutover_dt_tm = y_dt_tm
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Gathering $R information"
   SELECT INTO "nl:"
    FROM user_tables ut
    WHERE ut.table_name="*$R"
    DETAIL
     r_tab->cnt = (r_tab->cnt+ 1)
     IF (mod(r_tab->cnt,10)=1)
      stat = alterlist(r_tab->qual,(r_tab->cnt+ 9))
     ENDIF
     r_tab->qual[r_tab->cnt].tab_name = ut.table_name
    FOOT REPORT
     stat = alterlist(r_tab->qual,r_tab->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Checking for $R table ccl definitions and uncutover rows."
   FOR (dgri_idx = 1 TO r_tab->cnt)
     SELECT INTO "nl:"
      FROM dtable dt
      WHERE (dt.table_name=r_tab->qual[dgri_idx].tab_name)
      DETAIL
       r_tab->qual[dgri_idx].ccl_def_ind = 1
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(1)
     ENDIF
     IF ((r_tab->qual[dgri_idx].ccl_def_ind=0))
      SET dgri_info->missing_def_ind = 1
     ELSE
      SELECT INTO "nl:"
       FROM (parser(r_tab->qual[dgri_idx].tab_name) r)
       WHERE r.rdds_status_flag < 9000
       WITH nocounter, maxqual(r,1)
      ;end select
      IF (check_error(dm_err->eproc) != 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(1)
      ENDIF
      IF (curqual > 0)
       SET dgri_info->uncutover_r_cnt = (dgri_info->uncutover_r_cnt+ 1)
      ENDIF
     ENDIF
   ENDFOR
   SELECT INTO "nl:"
    FROM dm_refchg_process d,
     gv$session s
    WHERE d.rdbhandle_value=s.audsid
     AND ((d.refchg_type="MOVER PROCESS") OR (d.refchg_type="CUTOVER_PROCESS*"))
    DETAIL
     IF (d.refchg_type="MOVER PROCESS")
      dgri_info->mover_ind = 1
     ELSE
      dgri_info->cutover_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE drr_write_header(dwh_info)
   SET message = window
   CALL clear(1,1)
   SET width = 132
   CALL box(1,1,5,132)
   CALL text(3,50,"***  RDDS REMOVE ***")
   CALL text(4,75,"ENVIRONMENT ID:")
   CALL text(4,20,"ENVIRONMENT NAME:")
   CALL text(4,95,cnvtstring(dwh_info->env_id))
   CALL text(4,40,dwh_info->env_name)
 END ;Subroutine
#exit_program
END GO
