CREATE PROGRAM dm2_preview_luts
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
 IF ((validate(luts_list->table_cnt,- (1))=- (1))
  AND (validate(luts_list->table_cnt,- (2))=- (2)))
  FREE RECORD luts_list
  RECORD luts_list(
    01 inst_cnt = i2
    01 parallel_degree = i2
    01 table_cnt = i4
    01 table_diff_cnt = i2
    01 table_diff_txn_cnt = i2
    01 add_column_cnt = i2
    01 add_instid_column_cnt = i2
    01 add_txn_column_cnt = i2
    01 modify_dd_cnt = i2
    01 set_index_visible_cnt = i2
    01 set_txn_index_visible_cnt = i2
    01 create_index_cnt = i2
    01 rename_index_cnt = i2
    01 create_txn_index_cnt = i2
    01 disable_txn_trigger_cnt = i2
    01 create_trigger_cnt = i2
    01 create_del_trigger_cnt = i2
    01 set_col_stats_cnt = i2
    01 set_txn_col_stats_cnt = i2
    01 set_instid_col_stats_cnt = i2
    01 default_index_tspace = vc
    01 use_txn_table_synonym_ind = i2
    01 config_curr_txn_table = vc
    01 default_free_bytes_mb = f8
    01 txn_schema_ind = i2
    01 qual[*]
      02 table_is_scn = i2
      02 table_is_luts = i2
      02 table_owner = vc
      02 table_name = vc
      02 suffixed_table_name = vc
      02 table_suffix = vc
      02 diff_ind = i2
      02 diff_txn_ind = i2
      02 add_column_ind = i2
      02 add_instid_column_ind = i2
      02 add_txn_column_ind = i2
      02 add_column_ddl = vc
      02 add_txn_column_ddl = vc
      02 add_instid_column_ddl = vc
      02 add_combined_column_ddl = vc
      02 set_col_stats_ind = i2
      02 set_instid_col_stats_ind = i2
      02 set_txn_col_stats_ind = i2
      02 num_rows = f8
      02 create_index_ind = i2
      02 rename_index_ind = i2
      02 create_txn_index_ind = i2
      02 create_index_ddl = vc
      02 rename_index_ddl = vc
      02 create_txn_index_ddl = vc
      02 set_index_visible_ddl = vc
      02 set_txn_index_visible_ddl = vc
      02 set_index_visible_ind = i2
      02 set_txn_index_visible_ind = i2
      02 set_index_visible_ddl = vc
      02 set_txn_index_visible_ddl = vc
      02 index_name = vc
      02 txn_index_name = vc
      02 index_tspace = vc
      02 free_bytes_mb = f8
      02 index_col_list = vc
      02 index_txn_col_list = vc
      02 tspace_needed_mb = f8
      02 new_trigger_ind = i2
      02 create_trigger_ind = i2
      02 disable_txn_trigger_ind = i2
      02 disable_txn_trigger_ddl = vc
      02 trigger_name = vc
      02 delete_tracking_ind = i2
      02 delete_tracking_ldt_idx = i4
      02 del_trigger_name = vc
      02 create_del_trigger_ind = i2
      02 create_del_trigger_ddl = vc
      02 new_del_trigger_ind = i2
      02 txn_info_char = vc
      02 original_trigger_ddl = vc
      02 original_del_trigger_ddl = vc
      02 original_txn_trigger_ddl = vc
      02 create_trigger_ddl = vc
      02 use_inst_id_ind = i2
      02 delete_tracking_only_ind = i2
    01 asm_ind = i2
    01 dg_cnt = i2
    01 dg_space_needed_ind = i2
    01 dg[*]
      02 dg_name = vc
      02 total_bytes_mb = f8
      02 reserved_bytes_mb = f8
      02 free_bytes_mb = f8
      02 assigned_bytes_mb = f8
      02 new_ind_cnt = i4
    01 tspace_cnt = i2
    01 tspace_needed_ind = i2
    01 ts[*]
      02 tspace_name = vc
      02 dg_name = vc
      02 data_file_cnt = i4
      02 max_bytes_mb = f8
      02 user_bytes_mb = f8
      02 reserved_bytes_mb = f8
      02 free_bytes_mb = f8
      02 assigned_bytes_mb = f8
      02 assigned_ind_names = vc
      02 new_ind_cnt = i4
    01 install_by_rdm_ind = i2
  )
 ENDIF
 IF ((validate(luts_dyn_trig->table_cnt,- (1))=- (1))
  AND (validate(luts_dyn_trig->table_cnt,- (2))=- (2)))
  FREE RECORD luts_dyn_trig
  RECORD luts_dyn_trig(
    1 table_cnt = i4
    1 tbl[*]
      2 table_name = vc
      2 tn_txt = vc
      2 pen_txt = vc
      2 pei_txt = vc
      2 tpk_txt = vc
      2 data_txt = vc
      2 del_log_condition = vc
      2 txn_log_condition = vc
      2 dup_delrow_var_values = vc
  )
 ENDIF
 IF ((validate(luts_drop_list->table_cnt,- (1))=- (1))
  AND (validate(luts_drop_list->table_cnt,- (2))=- (2)))
  FREE RECORD luts_drop_list
  RECORD luts_drop_list(
    1 table_cnt = i4
    1 drop_index_cnt = i4
    1 drop_txn_index_cnt = i4
    1 drop_trigger_cnt = i4
    1 drop_del_trigger_cnt = i4
    1 drop_txn_trigger_cnt = i4
    1 drop_txn_pkg_cnt = i4
    1 qual[*]
      2 table_owner = vc
      2 table_name = vc
      2 drop_index_ind = i2
      2 drop_txn_index_ind = i2
      2 drop_index_ddl = vc
      2 drop_index_reason = vc
      2 drop_txn_index_ddl = vc
      2 drop_txn_index_reason = vc
      2 drop_trigger_ind = i2
      2 drop_txn_trigger_ind = i2
      2 drop_trigger_ddl = vc
      2 drop_trigger_reason = vc
      2 drop_del_trigger_ind = i2
      2 drop_del_trigger_ddl = vc
      2 drop_del_trigger_reason = vc
      2 drop_txn_trigger_ddl = vc
      2 drop_txn_trigger_reason = vc
      2 drop_txn_pkg_ind = i2
      2 drop_txn_pkg_ddl = vc
      2 drop_txn_pkg_name = vc
      2 drop_txn_pkg_reason = vc
  )
 ENDIF
 DECLARE dld_load_tables(null) = i2
 DECLARE dld_diff_schema(null) = i2
 DECLARE dld_diff_trigger(ddt_trigger_name=vc,ddt_table_name=vc,ddt_trigger_txt=vc,ddt_diff_ind=i2(
   ref)) = i2
 DECLARE dld_gen_lutsonly_trigger(dglt_idx=i4,dgkt_ddl_txt=vc(ref)) = i2
 DECLARE dld_gen_compound_trigger(dgct_idx=i4,dgct_ddl_txt=vc(ref)) = i2
 DECLARE dld_gen_del_compound_trigger(dgct_idx=i4,dgct_ddl_txt=vc(ref)) = i2
 DECLARE dld_compare_trigger(dct_owner=i4,dct_trigger_name=vc,dct_trigger_txt=vc,dct_from_gtt=i4) =
 i4 WITH sql = "V500.DM2DMP_UTIL.COMPARE_TRIGGER", parameter
 DECLARE dld_load_original_trigger_ddl(null) = i2
 DECLARE dld_load_curr_txn_table(null) = i2
 SUBROUTINE dld_load_tables(null)
   DECLARE dlt_locidx = i4 WITH protect, noconstant(0)
   DECLARE dlt_drpobjidx = i4 WITH protect, noconstant(0)
   DECLARE dlt_dtd_error_list = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dlt_invalid_txn = i2 WITH protect, noconstant(0)
   DECLARE dlt_drop_threshold = i2 WITH protect, noconstant(100)
   DECLARE dlt_col_list = vc WITH protect, noconstant("")
   DECLARE dld_deltrk_idx = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Loading trigger metadata"
   EXECUTE dm2_dbimport "cer_install:dm2_cdr_trig_meta.csv", "dm2_load_cdr_trig_csv", 100000
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(luts_dyn_trig)
   ENDIF
   SET dm_err->eproc = "LAST_UTC_TS: Getting driver table list from DM_TABLES_DOC"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_tables_doc dtd,
     user_tables ut,
     dm_info di
    WHERE dtd.drop_ind=0
     AND dtd.table_name=di.info_name
     AND di.info_domain IN ("DM2SETUP_LAST_UTC_TS", "DM2SETUP_TXNSCN")
     AND di.info_name=ut.table_name
    ORDER BY di.info_name, di.info_domain
    HEAD REPORT
     luts_list->table_cnt = 0, stat = alterlist(luts_list->qual,luts_list->table_cnt)
    HEAD di.info_name
     luts_list->table_cnt = (luts_list->table_cnt+ 1)
     IF (mod(luts_list->table_cnt,10)=1)
      stat = alterlist(luts_list->qual,(luts_list->table_cnt+ 9))
     ENDIF
     luts_list->qual[luts_list->table_cnt].table_owner = "V500", luts_list->qual[luts_list->table_cnt
     ].table_name = dtd.table_name, luts_list->qual[luts_list->table_cnt].index_name = "DM2NOTSET",
     luts_list->qual[luts_list->table_cnt].index_col_list = "DM2NOTSET", luts_list->qual[luts_list->
     table_cnt].index_tspace = "DM2NOTSET", luts_list->qual[luts_list->table_cnt].create_trigger_ddl
      = "DM2NOTSET",
     luts_list->qual[luts_list->table_cnt].suffixed_table_name = trim(dtd.suffixed_table_name),
     luts_list->qual[luts_list->table_cnt].table_suffix = trim(dtd.table_suffix), luts_list->qual[
     luts_list->table_cnt].num_rows = ut.num_rows,
     luts_list->qual[luts_list->table_cnt].trigger_name = concat("TRG_",luts_list->qual[luts_list->
      table_cnt].table_suffix,"_LUTS"), luts_list->qual[luts_list->table_cnt].del_trigger_name =
     concat("TRG_DEL_",luts_list->qual[luts_list->table_cnt].table_suffix,"_LUTS"), luts_list->qual[
     luts_list->table_cnt].create_del_trigger_ddl = "DM2NOTSET",
     luts_list->qual[luts_list->table_cnt].new_trigger_ind = 1, luts_list->qual[luts_list->table_cnt]
     .new_del_trigger_ind = 1
     IF (di.updt_applctx=1)
      luts_list->qual[luts_list->table_cnt].use_inst_id_ind = 1
     ELSEIF (di.updt_applctx=2)
      luts_list->qual[luts_list->table_cnt].delete_tracking_only_ind = 1
     ENDIF
    DETAIL
     IF (di.info_domain="DM2SETUP_LAST_UTC_TS")
      luts_list->qual[luts_list->table_cnt].table_is_luts = di.info_number, luts_list->qual[luts_list
      ->table_cnt].index_name = concat("XCER",luts_list->qual[luts_list->table_cnt].
       suffixed_table_name), luts_list->qual[luts_list->table_cnt].add_column_ind = evaluate(
       luts_list->qual[luts_list->table_cnt].delete_tracking_only_ind,1,0,luts_list->qual[luts_list->
       table_cnt].table_is_luts),
      luts_list->qual[luts_list->table_cnt].add_instid_column_ind = evaluate(luts_list->qual[
       luts_list->table_cnt].use_inst_id_ind,0,0,luts_list->qual[luts_list->table_cnt].table_is_luts),
      luts_list->qual[luts_list->table_cnt].add_column_ddl = "LAST_UTC_TS TIMESTAMP(9) NULL",
      luts_list->qual[luts_list->table_cnt].add_instid_column_ddl = "INST_ID NUMBER NULL",
      luts_list->qual[luts_list->table_cnt].set_col_stats_ind = evaluate(luts_list->qual[luts_list->
       table_cnt].delete_tracking_only_ind,1,0,luts_list->qual[luts_list->table_cnt].table_is_luts),
      luts_list->qual[luts_list->table_cnt].set_instid_col_stats_ind = evaluate(luts_list->qual[
       luts_list->table_cnt].use_inst_id_ind,0,0,luts_list->qual[luts_list->table_cnt].table_is_luts),
      luts_list->qual[luts_list->table_cnt].create_index_ind = evaluate(luts_list->qual[luts_list->
       table_cnt].delete_tracking_only_ind,1,0,luts_list->qual[luts_list->table_cnt].table_is_luts),
      luts_list->qual[luts_list->table_cnt].set_index_visible_ind = evaluate(luts_list->qual[
       luts_list->table_cnt].delete_tracking_only_ind,1,0,luts_list->qual[luts_list->table_cnt].
       table_is_luts), dld_deltrk_idx = 0, dld_deltrk_idx = locateval(dld_deltrk_idx,1,luts_dyn_trig
       ->table_cnt,luts_list->qual[luts_list->table_cnt].table_name,luts_dyn_trig->tbl[dld_deltrk_idx
       ].table_name)
      IF (dld_deltrk_idx > 0)
       luts_list->qual[luts_list->table_cnt].delete_tracking_ind = 1, luts_list->qual[luts_list->
       table_cnt].delete_tracking_ldt_idx = dld_deltrk_idx
      ELSE
       luts_list->qual[luts_list->table_cnt].delete_tracking_ind = 0
      ENDIF
     ELSE
      luts_list->qual[luts_list->table_cnt].table_is_scn = evaluate(luts_list->txn_schema_ind,0,0,di
       .info_number), luts_list->qual[luts_list->table_cnt].txn_index_name = concat("XCERTXN",
       luts_list->qual[luts_list->table_cnt].suffixed_table_name), luts_list->qual[luts_list->
      table_cnt].add_txn_column_ddl = "TXN_ID_TEXT VARCHAR2(200) NULL",
      luts_list->qual[luts_list->table_cnt].add_txn_column_ind = evaluate(luts_list->qual[luts_list->
       table_cnt].delete_tracking_only_ind,1,0,luts_list->qual[luts_list->table_cnt].table_is_scn),
      luts_list->qual[luts_list->table_cnt].set_txn_col_stats_ind = evaluate(luts_list->qual[
       luts_list->table_cnt].delete_tracking_only_ind,1,0,luts_list->qual[luts_list->table_cnt].
       table_is_scn), luts_list->qual[luts_list->table_cnt].create_txn_index_ind = evaluate(luts_list
       ->qual[luts_list->table_cnt].delete_tracking_only_ind,1,0,luts_list->qual[luts_list->table_cnt
       ].table_is_scn),
      luts_list->qual[luts_list->table_cnt].set_txn_index_visible_ind = evaluate(luts_list->qual[
       luts_list->table_cnt].delete_tracking_only_ind,1,0,luts_list->qual[luts_list->table_cnt].
       table_is_scn), luts_list->qual[luts_list->table_cnt].disable_txn_trigger_ind = 0
      IF (trim(di.info_char,3) > " ")
       luts_list->qual[luts_list->table_cnt].txn_info_char = di.info_char
      ENDIF
     ENDIF
    FOOT  di.info_name
     IF ((luts_list->qual[luts_list->table_cnt].table_is_scn=1)
      AND (luts_list->qual[luts_list->table_cnt].use_inst_id_ind=1)
      AND (luts_list->qual[luts_list->table_cnt].table_is_luts=0))
      CALL echo(concat(luts_list->qual[luts_list->table_cnt].table_name,
       " is an SCN-Only table and may not use INST_ID")), luts_list->qual[luts_list->table_cnt].
      use_inst_id_ind = 0
     ENDIF
     IF ((((luts_list->qual[luts_list->table_cnt].table_is_luts=0)
      AND (luts_list->qual[luts_list->table_cnt].table_is_scn=0)) OR ((luts_list->qual[luts_list->
     table_cnt].delete_tracking_only_ind=1))) )
      luts_list->qual[luts_list->table_cnt].create_trigger_ind = 0
     ELSE
      luts_list->qual[luts_list->table_cnt].create_trigger_ind = 1
     ENDIF
     IF ((((luts_list->qual[luts_list->table_cnt].table_is_luts=0)
      AND (luts_list->qual[luts_list->table_cnt].table_is_scn=0)) OR ((luts_list->qual[luts_list->
     table_cnt].delete_tracking_ind=0))) )
      luts_list->qual[luts_list->table_cnt].create_del_trigger_ind = 0
     ELSE
      luts_list->qual[luts_list->table_cnt].create_del_trigger_ind = 1
     ENDIF
    FOOT REPORT
     stat = alterlist(luts_list->qual,luts_list->table_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(luts_list)
   ENDIF
   SET luts_drop_list->table_cnt = 0
   SET luts_drop_list->drop_index_cnt = 0
   SET luts_drop_list->drop_txn_index_cnt = 0
   SET luts_drop_list->drop_trigger_cnt = 0
   SET luts_drop_list->drop_del_trigger_cnt = 0
   SET luts_drop_list->drop_txn_pkg_cnt = 0
   SET luts_drop_list->drop_txn_trigger_cnt = 0
   SET stat = alterlist(luts_drop_list->qual,0)
   SET dm_err->eproc = "Load extraneous packages"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_objects uo,
     dm_tables_doc u
    WHERE uo.owner="V500"
     AND uo.object_name="PKG*TXNSCN"
     AND uo.object_type="PACKAGE"
     AND replace(replace(uo.object_name,"PKG_",""),"_TXNSCN","")=u.table_suffix
     AND u.table_name=u.full_table_name
    ORDER BY uo.object_name
    DETAIL
     IF ((luts_list->txn_schema_ind=0))
      dlt_invalid_txn = 1,
      CALL echo(concat("SCN object found, but SCN not active: ",uo.object_name))
     ENDIF
     dlt_drpobjidx = locateval(dlt_drpobjidx,1,luts_drop_list->table_cnt,u.table_name,luts_drop_list
      ->qual[dlt_drpobjidx].table_name)
     IF (dlt_drpobjidx=0)
      luts_drop_list->table_cnt = (luts_drop_list->table_cnt+ 1), stat = alterlist(luts_drop_list->
       qual,luts_drop_list->table_cnt), dlt_drpobjidx = luts_drop_list->table_cnt,
      luts_drop_list->qual[dlt_drpobjidx].table_name = u.table_name, luts_drop_list->qual[
      dlt_drpobjidx].table_owner = uo.owner
     ENDIF
     luts_drop_list->drop_txn_pkg_cnt = (luts_drop_list->drop_txn_pkg_cnt+ 1), luts_drop_list->qual[
     dlt_drpobjidx].drop_txn_pkg_ind = 1, luts_drop_list->qual[dlt_drpobjidx].drop_txn_pkg_name = uo
     .object_name,
     luts_drop_list->qual[dlt_drpobjidx].drop_txn_pkg_ddl = concat("drop package ",trim(uo.owner),".",
      uo.object_name), luts_drop_list->qual[dlt_drpobjidx].drop_txn_pkg_reason = concat(trim(u
       .table_name)," is no longer required")
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM dba_triggers d
    WHERE d.owner="V500"
     AND ((d.trigger_name="TRG*LUTS") OR (d.trigger_name="TRG*TXNSCN"))
    DETAIL
     dlt_locidx = locateval(dlt_locidx,1,luts_list->table_cnt,d.table_name,luts_list->qual[dlt_locidx
      ].table_name), dlt_drpobjidx = locateval(dlt_drpobjidx,1,luts_drop_list->table_cnt,d.table_name,
      luts_drop_list->qual[dlt_drpobjidx].table_name)
     IF (d.trigger_name="TRG_DEL_*LUTS"
      AND ((dlt_locidx=0) OR (dlt_locidx > 0
      AND (((luts_list->qual[dlt_locidx].table_is_scn=0)
      AND (luts_list->qual[dlt_locidx].table_is_luts=0)) OR ((luts_list->qual[dlt_locidx].
     delete_tracking_ind=0))) )) )
      IF (dlt_drpobjidx=0)
       luts_drop_list->table_cnt = (luts_drop_list->table_cnt+ 1), stat = alterlist(luts_drop_list->
        qual,luts_drop_list->table_cnt), dlt_drpobjidx = luts_drop_list->table_cnt,
       luts_drop_list->qual[dlt_drpobjidx].table_name = d.table_name, luts_drop_list->qual[
       dlt_drpobjidx].table_owner = d.owner
      ENDIF
      luts_drop_list->drop_del_trigger_cnt = (luts_drop_list->drop_del_trigger_cnt+ 1),
      luts_drop_list->qual[dlt_drpobjidx].drop_del_trigger_ind = 1, luts_drop_list->qual[
      dlt_drpobjidx].drop_del_trigger_ddl = concat("drop trigger ",trim(d.owner),".",trim(d
        .trigger_name)),
      luts_drop_list->qual[dlt_drpobjidx].drop_del_trigger_reason = concat(trim(d.table_name),
       " is not a delete-tracking table")
     ELSEIF (d.trigger_name="TRG*LUTS"
      AND d.trigger_name != "TRG_DEL_*_LUTS"
      AND ((dlt_locidx=0) OR (dlt_locidx > 0
      AND (((luts_list->qual[dlt_locidx].table_is_scn=0)
      AND (luts_list->qual[dlt_locidx].table_is_luts=0)) OR ((luts_list->qual[dlt_locidx].
     delete_tracking_only_ind=1))) )) )
      IF (dlt_drpobjidx=0)
       luts_drop_list->table_cnt = (luts_drop_list->table_cnt+ 1), stat = alterlist(luts_drop_list->
        qual,luts_drop_list->table_cnt), dlt_drpobjidx = luts_drop_list->table_cnt,
       luts_drop_list->qual[dlt_drpobjidx].table_name = d.table_name, luts_drop_list->qual[
       dlt_drpobjidx].table_owner = d.owner
      ENDIF
      luts_drop_list->drop_trigger_cnt = (luts_drop_list->drop_trigger_cnt+ 1), luts_drop_list->qual[
      dlt_drpobjidx].drop_trigger_ind = 1, luts_drop_list->qual[dlt_drpobjidx].drop_trigger_ddl =
      concat("drop trigger ",trim(d.owner),".",trim(d.trigger_name))
      IF ((luts_list->qual[dlt_locidx].delete_tracking_only_ind=1))
       luts_drop_list->qual[dlt_drpobjidx].drop_trigger_reason = concat(trim(d.table_name),
        " is delete-tracking only table")
      ELSE
       luts_drop_list->qual[dlt_drpobjidx].drop_trigger_reason = concat(trim(d.table_name),
        " is not a LUTS and SCN candidate table")
      ENDIF
     ELSEIF (d.trigger_name="TRG*TXNSCN")
      IF (dlt_drpobjidx=0)
       luts_drop_list->table_cnt = (luts_drop_list->table_cnt+ 1), stat = alterlist(luts_drop_list->
        qual,luts_drop_list->table_cnt), dlt_drpobjidx = luts_drop_list->table_cnt,
       luts_drop_list->qual[dlt_drpobjidx].table_name = d.table_name, luts_drop_list->qual[
       dlt_drpobjidx].table_owner = d.owner
      ENDIF
      luts_drop_list->drop_txn_trigger_cnt = (luts_drop_list->drop_txn_trigger_cnt+ 1),
      luts_drop_list->qual[dlt_drpobjidx].drop_txn_trigger_ind = 1, luts_drop_list->qual[
      dlt_drpobjidx].drop_txn_trigger_ddl = concat("drop trigger ",trim(d.owner),".",trim(d
        .trigger_name)),
      luts_drop_list->qual[dlt_drpobjidx].drop_txn_trigger_reason = concat(trim(d.trigger_name),
       " is no longer required")
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Load extraneous indexes"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_ind_columns d
    WHERE d.table_owner="V500"
     AND d.index_owner="V500"
     AND ((d.index_name="XCER*"
     AND d.column_name IN ("INST_ID", "LAST_UTC_TS")) OR (d.index_name="XCERTXN*"
     AND d.column_name="TXN_ID_TEXT"))
     AND  NOT (d.index_name IN (
    (SELECT
     di.info_char
     FROM dm_info di
     WHERE di.info_domain="DM2_INSTALL_LUTS"
      AND di.info_name="BYPASS_EXTRANEOUS_INDEX")))
     AND  NOT (d.table_name IN ("DM_DELETE_TRACKING", "DM_TXN_TRACKING"))
    ORDER BY d.table_name, d.index_name, d.column_position
    HEAD d.table_name
     dlt_locidx = 0, dlt_locidx = locateval(dlt_locidx,1,luts_list->table_cnt,d.table_name,luts_list
      ->qual[dlt_locidx].table_name)
    HEAD d.index_name
     dlt_col_list = ""
    DETAIL
     dlt_col_list = concat(dlt_col_list,",",trim(d.column_name))
     IF ((luts_list->txn_schema_ind=0)
      AND d.column_name="TXN_ID_TEXT")
      dlt_invalid_txn = 1,
      CALL echo(concat("SCN object found, but SCN not active: ",d.index_name))
     ENDIF
    FOOT  d.index_name
     dlt_col_list = replace(dlt_col_list,",","",1),
     CALL echo(concat(d.table_name,".",d.index_name,":",dlt_col_list))
     IF (((dlt_locidx=0) OR (((dlt_locidx > 0
      AND d.index_name != "XCERTXN*"
      AND (((luts_list->qual[dlt_locidx].use_inst_id_ind=1)
      AND findstring("INST_ID",dlt_col_list)=0) OR ((luts_list->qual[dlt_locidx].use_inst_id_ind=0)
      AND findstring("INST_ID",dlt_col_list) > 0)) ) OR (((dlt_locidx > 0
      AND (((luts_list->qual[dlt_locidx].table_is_scn=0)) OR ((luts_list->qual[dlt_locidx].
     table_is_luts=0))) ) OR (dlt_locidx > 0
      AND (luts_list->qual[dlt_locidx].delete_tracking_only_ind=1))) )) )) )
      dlt_drpobjidx = locateval(dlt_drpobjidx,1,luts_drop_list->table_cnt,d.table_name,luts_drop_list
       ->qual[dlt_drpobjidx].table_name)
      IF (dlt_locidx > 0
       AND (luts_list->qual[dlt_locidx].delete_tracking_only_ind=1))
       IF (dlt_drpobjidx=0)
        luts_drop_list->table_cnt = (luts_drop_list->table_cnt+ 1), stat = alterlist(luts_drop_list->
         qual,luts_drop_list->table_cnt), dlt_drpobjidx = luts_drop_list->table_cnt,
        luts_drop_list->qual[dlt_drpobjidx].table_name = d.table_name, luts_drop_list->qual[
        dlt_drpobjidx].table_owner = d.table_owner
       ENDIF
       IF (d.index_name="XCERTXN*")
        luts_drop_list->qual[dlt_drpobjidx].drop_txn_index_ind = 1, luts_drop_list->qual[
        dlt_drpobjidx].drop_txn_index_ddl = concat("drop index ",trim(d.index_owner),".",trim(d
          .index_name)), luts_drop_list->drop_txn_index_cnt = (luts_drop_list->drop_txn_index_cnt+ 1),
        luts_drop_list->qual[dlt_drpobjidx].drop_txn_index_reason = concat(trim(d.table_name),
         " is a DELETE TRACKING ONLY candidate table")
       ELSE
        luts_drop_list->qual[dlt_drpobjidx].drop_index_ind = 1, luts_drop_list->qual[dlt_drpobjidx].
        drop_index_ddl = concat("drop index ",trim(d.index_owner),".",trim(d.index_name)),
        luts_drop_list->drop_index_cnt = (luts_drop_list->drop_index_cnt+ 1),
        luts_drop_list->qual[dlt_drpobjidx].drop_index_reason = concat(trim(d.table_name),
         " is a DELETE TRACKING ONLY candidate table")
       ENDIF
      ELSEIF (d.column_name="LAST_UTC_TS"
       AND ((dlt_locidx=0) OR (dlt_locidx > 0
       AND (luts_list->qual[dlt_locidx].table_is_luts=0))) )
       IF (dlt_drpobjidx=0)
        luts_drop_list->table_cnt = (luts_drop_list->table_cnt+ 1), stat = alterlist(luts_drop_list->
         qual,luts_drop_list->table_cnt), dlt_drpobjidx = luts_drop_list->table_cnt,
        luts_drop_list->qual[dlt_drpobjidx].table_name = d.table_name, luts_drop_list->qual[
        dlt_drpobjidx].table_owner = d.table_owner
       ENDIF
       luts_drop_list->qual[dlt_drpobjidx].drop_index_ind = 1, luts_drop_list->qual[dlt_drpobjidx].
       drop_index_ddl = concat("drop index ",trim(d.index_owner),".",trim(d.index_name)),
       luts_drop_list->drop_index_cnt = (luts_drop_list->drop_index_cnt+ 1),
       luts_drop_list->qual[dlt_drpobjidx].drop_index_reason = concat(trim(d.table_name),
        " is not a LUTS candidate table")
      ELSEIF (d.column_name="TXN_ID_TEXT"
       AND ((dlt_locidx=0) OR (dlt_locidx > 0
       AND (luts_list->qual[dlt_locidx].table_is_scn=0))) )
       IF (dlt_drpobjidx=0)
        luts_drop_list->table_cnt = (luts_drop_list->table_cnt+ 1), stat = alterlist(luts_drop_list->
         qual,luts_drop_list->table_cnt), dlt_drpobjidx = luts_drop_list->table_cnt,
        luts_drop_list->qual[dlt_drpobjidx].table_name = d.table_name, luts_drop_list->qual[
        dlt_drpobjidx].table_owner = d.table_owner
       ENDIF
       luts_drop_list->qual[dlt_drpobjidx].drop_txn_index_ind = 1, luts_drop_list->qual[dlt_drpobjidx
       ].drop_txn_index_ddl = concat("drop index ",trim(d.index_owner),".",trim(d.index_name)),
       luts_drop_list->drop_txn_index_cnt = (luts_drop_list->drop_txn_index_cnt+ 1),
       luts_drop_list->qual[dlt_drpobjidx].drop_txn_index_reason = concat(trim(d.table_name),
        " is not a SCN candidate table")
      ELSEIF (dlt_locidx > 0
       AND d.index_name != "XCERTXN*"
       AND (((luts_list->qual[dlt_locidx].use_inst_id_ind=1)
       AND findstring("INST_ID",dlt_col_list)=0) OR ((luts_list->qual[dlt_locidx].use_inst_id_ind=0)
       AND findstring("INST_ID",dlt_col_list) > 0)) )
       IF (dlt_drpobjidx=0)
        luts_drop_list->table_cnt = (luts_drop_list->table_cnt+ 1), stat = alterlist(luts_drop_list->
         qual,luts_drop_list->table_cnt), dlt_drpobjidx = luts_drop_list->table_cnt,
        luts_drop_list->qual[dlt_drpobjidx].table_name = d.table_name, luts_drop_list->qual[
        dlt_drpobjidx].table_owner = d.table_owner
       ENDIF
       IF (d.index_name != "XCER_O_*")
        luts_list->qual[dlt_locidx].rename_index_ind = 1, luts_list->qual[dlt_locidx].
        rename_index_ddl = concat("alter index ",trim(d.index_owner),".",trim(d.index_name),
         " rename to ",
         "XCER_O_",luts_list->qual[dlt_locidx].suffixed_table_name)
       ENDIF
       luts_drop_list->qual[dlt_drpobjidx].drop_index_ind = 1, luts_drop_list->qual[dlt_drpobjidx].
       drop_index_ddl = concat("drop index ",trim(d.index_owner),".","XCER_O_",luts_list->qual[
        dlt_locidx].suffixed_table_name), luts_drop_list->drop_index_cnt = (luts_drop_list->
       drop_index_cnt+ 1),
       luts_drop_list->qual[dlt_drpobjidx].drop_index_reason = concat(trim(d.table_name),
        " incorrect index structure")
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(luts_drop_list)
   ENDIF
   IF (dlt_invalid_txn=1)
    SET dm_err->eproc = "LAST_UTC_TS: Check if invalid txn bypass is enabled"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DM2_INSTALL_LUTS"
      AND di.info_name="DROP_INVALID_SCN_OBJ"
     DETAIL
      CALL echo("Invalid SCN object bypass found"), dlt_invalid_txn = 0
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dlt_invalid_txn=1)
     SET dm_err->err_ind = 1
     SET dm_err->emsg =
     "One or more tables had invalid metadata. Run in PREVIEW to view listing in output."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ENDIF
    IF (check_error(dm_err->eproc)=1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dld_load_curr_txn_table(null)
   IF (textlen(luts_list->config_curr_txn_table) > 0)
    SET dm_err->eproc = concat("txn table already determined. LUTS triggers will write to ",luts_list
     ->config_curr_txn_table)
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_INSTALL_LUTS"
     AND di.info_name="TXN_STAGING_TABLE"
    WITH nocounter
   ;end select
   IF (check_error("Checking DM_INFO for 'TXN_STAGING_TABLE' flag")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET luts_list->config_curr_txn_table = "DM_TXN_TRACKING"
    SET luts_list->use_txn_table_synonym_ind = 0
    SET dm_err->eproc =
    "'TXN_STAGING_TABLE' row does not exist in DM_INFO. LUTS triggers will write to DM_TXN_TRACKING."
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    FROM dba_objects x
    WHERE x.owner="V500"
     AND x.object_name="DM_TXN_TRACKING_STG"
     AND x.object_type="TABLE"
    WITH nocounter
   ;end select
   IF (check_error("Checking for existence of DM_TXN_TRACKING_STG table")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET luts_list->config_curr_txn_table = "DM_TXN_TRACKING"
    SET luts_list->use_txn_table_synonym_ind = 0
    SET dm_err->eproc =
    "DM_TXN_TRACKING_STG table does not exist. LUTS triggers will write to DM_TXN_TRACKING."
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    FROM dba_dependencies x
    WHERE x.owner="V500"
     AND x.name="DM_SCN_OBJECTS"
     AND x.type="PACKAGE BODY"
     AND x.referenced_name="SCOUT_STG_READ_VW"
     AND x.referenced_type="VIEW"
    WITH nocounter
   ;end select
   IF (check_error("Checking if scout procedure supports DM_TXN_TRACKING_STG table")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET luts_list->config_curr_txn_table = "DM_TXN_TRACKING"
    SET luts_list->use_txn_table_synonym_ind = 0
    SET dm_err->eproc =
    "Scout process does not support DM_TXN_TRACKING_STG table. LUTS triggers will write to DM_TXN_TRACKING."
   ELSE
    SET luts_list->config_curr_txn_table = "DM_TXN_TRACKING_STG"
    SET luts_list->use_txn_table_synonym_ind = 1
    SET dm_err->eproc =
    "Scout process supports DM_TXN_TRACKING_STG table. LUTS triggers will write to DM_TXN_TRACKING_STG."
   ENDIF
   CALL disp_msg("",dm_err->logfile,0)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dld_diff_schema(null)
   DECLARE dds_locidx = i4 WITH protect, noconstant(0)
   DECLARE dds_str = vc WITH protect, noconstant("")
   DECLARE dds_cnt = i4 WITH protect, noconstant(0)
   DECLARE dds_tslocidx = i4 WITH protect, noconstant(0)
   DECLARE dds_dglocidx = i4 WITH protect, noconstant(0)
   DECLARE dds_is_11204 = i2 WITH protect, noconstant(0)
   DECLARE dds_dg_name = vc WITH protect, noconstant(" ")
   DECLARE dds_tsp_reserve_pct = f8 WITH protect, noconstant(0.1)
   DECLARE dds_tsp_raw_reserve_pct = f8 WITH protect, noconstant(0.25)
   IF (dm2_get_rdbms_version(null)=0)
    RETURN(0)
   ENDIF
   IF ((((dm2_rdbms_version->level1 > 11)) OR ((((dm2_rdbms_version->level1=11)
    AND (dm2_rdbms_version->level2 > 2)) OR ((((dm2_rdbms_version->level1=11)
    AND (dm2_rdbms_version->level2=2)
    AND (dm2_rdbms_version->level3 > 0)) OR ((dm2_rdbms_version->level1=11)
    AND (dm2_rdbms_version->level2=2)
    AND (dm2_rdbms_version->level3=0)
    AND (dm2_rdbms_version->level4 >= 4))) )) )) )
    SET dds_is_11204 = 1
   ENDIF
   SET dm_err->eproc =
   "Evaluating accurate TXN_ID_TEXT and LAST_UTC_TS column existence against driver table list"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    lutscol_no_stats = nullind(utc.last_analyzed)
    FROM user_tab_columns utc
    WHERE utc.column_name IN ("LAST_UTC_TS", "TXN_ID_TEXT", "INST_ID")
    ORDER BY utc.table_name
    HEAD utc.table_name
     dds_locidx = locateval(dds_locidx,1,luts_list->table_cnt,utc.table_name,luts_list->qual[
      dds_locidx].table_name)
    DETAIL
     IF (dds_locidx > 0)
      IF (utc.column_name="LAST_UTC_TS")
       luts_list->qual[dds_locidx].add_column_ind = 0, luts_list->qual[dds_locidx].set_col_stats_ind
        = evaluate(lutscol_no_stats,1,1,0)
      ELSEIF (utc.column_name="INST_ID")
       luts_list->qual[dds_locidx].add_instid_column_ind = 0, luts_list->qual[dds_locidx].
       set_instid_col_stats_ind = evaluate(lutscol_no_stats,1,1,0)
      ELSE
       luts_list->qual[dds_locidx].add_txn_column_ind = 0, luts_list->qual[dds_locidx].
       set_txn_col_stats_ind = evaluate(lutscol_no_stats,1,1,0)
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Evaluating accurate TXN_ID_TEXT and LUTS indexing against driver table list"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM user_ind_columns uic,
     user_indexes ui
    WHERE ((uic.column_name="TXN_ID_TEXT"
     AND uic.column_position=1) OR (uic.column_name IN ("INST_ID", "LAST_UTC_TS")
     AND uic.column_position IN (1, 2)))
     AND ui.table_name=uic.table_name
     AND ui.index_name=uic.index_name
    ORDER BY uic.table_name
    HEAD uic.table_name
     dds_locidx = locateval(dds_locidx,1,luts_list->table_cnt,uic.table_name,luts_list->qual[
      dds_locidx].table_name)
    DETAIL
     IF (dds_locidx > 0)
      IF (uic.column_name IN ("INST_ID", "LAST_UTC_TS"))
       IF (((uic.column_name="INST_ID"
        AND uic.column_position=1
        AND (luts_list->qual[dds_locidx].use_inst_id_ind=1)) OR (uic.column_name="LAST_UTC_TS"
        AND uic.column_position=1
        AND (luts_list->qual[dds_locidx].use_inst_id_ind=0))) )
        luts_list->qual[dds_locidx].create_index_ind = 0
        IF (dds_is_11204=1
         AND ui.visibility="VISIBLE")
         luts_list->qual[dds_locidx].set_index_visible_ind = 0
        ELSE
         IF (dds_is_11204=0)
          luts_list->qual[dds_locidx].set_index_visible_ind = 0
         ENDIF
        ENDIF
       ENDIF
      ELSE
       luts_list->qual[dds_locidx].create_txn_index_ind = 0
       IF (dds_is_11204=1
        AND ui.visibility="VISIBLE")
        luts_list->qual[dds_locidx].set_txn_index_visible_ind = 0
       ELSE
        IF (dds_is_11204=0)
         luts_list->qual[dds_locidx].set_txn_index_visible_ind = 0
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Evaluating TXNSCN and LUTS trigger build against driver table list"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM user_triggers ut
    WHERE ((ut.trigger_name="TRG*LUTS") OR (ut.trigger_name="TRG*TXNSCN"))
    ORDER BY ut.table_name
    HEAD ut.table_name
     dds_locidx = locateval(dds_locidx,1,luts_list->table_cnt,ut.table_name,luts_list->qual[
      dds_locidx].table_name)
    DETAIL
     IF (dds_locidx > 0)
      IF (ut.trigger_name="TRG_DEL_*LUTS")
       luts_list->qual[dds_locidx].create_del_trigger_ind = 0, luts_list->qual[dds_locidx].
       new_del_trigger_ind = 0
      ELSEIF (ut.trigger_name="TRG*LUTS")
       luts_list->qual[dds_locidx].create_trigger_ind = 0, luts_list->qual[dds_locidx].
       new_trigger_ind = 0
      ELSE
       IF (ut.status="ENABLED")
        luts_list->qual[dds_locidx].disable_txn_trigger_ind = 1, luts_list->qual[dds_locidx].
        disable_txn_trigger_ddl = concat("alter trigger ",trim(ut.trigger_name)," disable")
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Evaluating existing triggers for differences"
   CALL disp_msg("",dm_err->logfile,0)
   FOR (dds_locidx = 1 TO luts_list->table_cnt)
     IF ((((luts_list->qual[dds_locidx].table_is_scn > 0)) OR ((luts_list->qual[dds_locidx].
     table_is_luts > 0))) )
      IF ((luts_list->qual[dds_locidx].delete_tracking_only_ind=0))
       IF ((((luts_list->qual[dds_locidx].table_is_scn=0)) OR ((luts_list->txn_schema_ind=0))) )
        IF (dld_gen_lutsonly_trigger(dds_locidx,dds_str)=0)
         RETURN(0)
        ENDIF
        SET luts_list->qual[dds_locidx].create_trigger_ddl = dds_str
       ELSE
        IF (dld_gen_compound_trigger(dds_locidx,dds_str)=0)
         RETURN(0)
        ENDIF
        SET luts_list->qual[dds_locidx].create_trigger_ddl = dds_str
       ENDIF
      ENDIF
      IF ((luts_list->qual[dds_locidx].delete_tracking_ind=1))
       IF (dld_gen_del_compound_trigger(dds_locidx,dds_str)=0)
        RETURN(0)
       ENDIF
       SET luts_list->qual[dds_locidx].create_del_trigger_ddl = dds_str
      ENDIF
      IF ((luts_list->qual[dds_locidx].new_del_trigger_ind=0))
       IF ((luts_list->qual[dds_locidx].delete_tracking_ind=1))
        IF (dld_diff_trigger(luts_list->qual[dds_locidx].del_trigger_name,luts_list->qual[dds_locidx]
         .table_name,luts_list->qual[dds_locidx].create_del_trigger_ddl,luts_list->qual[dds_locidx].
         create_del_trigger_ind)=0)
         RETURN(0)
        ENDIF
       ENDIF
      ENDIF
      IF ((luts_list->qual[dds_locidx].new_trigger_ind=0)
       AND (luts_list->qual[dds_locidx].delete_tracking_only_ind=0))
       IF (dld_diff_trigger(luts_list->qual[dds_locidx].trigger_name,luts_list->qual[dds_locidx].
        table_name,luts_list->qual[dds_locidx].create_trigger_ddl,luts_list->qual[dds_locidx].
        create_trigger_ind)=0)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   IF (dld_load_original_trigger_ddl(null)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Accumulating LAST_UTC_TS and TXN schema change scope across tables evaluated"
   CALL disp_msg("",dm_err->logfile,0)
   SET luts_list->add_column_cnt = 0
   SET luts_list->add_instid_column_cnt = 0
   SET luts_list->create_index_cnt = 0
   SET luts_list->rename_index_cnt = 0
   SET luts_list->create_trigger_cnt = 0
   SET luts_list->create_del_trigger_cnt = 0
   SET luts_list->table_diff_cnt = 0
   SET luts_list->set_col_stats_cnt = 0
   SET luts_list->set_instid_col_stats_cnt = 0
   SET luts_list->set_index_visible_cnt = 0
   SET luts_list->disable_txn_trigger_cnt = 0
   SET luts_list->add_txn_column_cnt = 0
   SET luts_list->create_txn_index_cnt = 0
   SET luts_list->set_txn_col_stats_cnt = 0
   SET luts_list->table_diff_txn_cnt = 0
   SET luts_list->set_txn_index_visible_cnt = 0
   FOR (dds_locidx = 1 TO luts_list->table_cnt)
     IF ((luts_list->qual[dds_locidx].add_column_ind=1))
      SET luts_list->add_column_cnt = (luts_list->add_column_cnt+ 1)
      SET luts_list->qual[dds_locidx].add_combined_column_ddl = concat(luts_list->qual[dds_locidx].
       add_combined_column_ddl,",",luts_list->qual[dds_locidx].add_column_ddl)
      SET luts_list->qual[dds_locidx].diff_ind = 1
     ENDIF
     IF ((luts_list->qual[dds_locidx].add_instid_column_ind=1))
      SET luts_list->add_instid_column_cnt = (luts_list->add_instid_column_cnt+ 1)
      SET luts_list->qual[dds_locidx].add_combined_column_ddl = concat(luts_list->qual[dds_locidx].
       add_combined_column_ddl,",",luts_list->qual[dds_locidx].add_instid_column_ddl)
      SET luts_list->qual[dds_locidx].diff_ind = 1
     ENDIF
     IF ((luts_list->qual[dds_locidx].create_index_ind=1))
      SET luts_list->create_index_cnt = (luts_list->create_index_cnt+ 1)
      SET luts_list->qual[dds_locidx].diff_ind = 1
     ENDIF
     IF ((luts_list->qual[dds_locidx].rename_index_ind=1))
      SET luts_list->rename_index_cnt = (luts_list->rename_index_cnt+ 1)
      SET luts_list->qual[dds_locidx].diff_ind = 1
     ENDIF
     IF ((luts_list->qual[dds_locidx].set_index_visible_ind=1))
      SET luts_list->set_index_visible_cnt = (luts_list->set_index_visible_cnt+ 1)
      SET luts_list->qual[dds_locidx].diff_ind = 1
     ENDIF
     IF ((luts_list->qual[dds_locidx].create_trigger_ind > 0))
      SET luts_list->create_trigger_cnt = (luts_list->create_trigger_cnt+ 1)
      SET luts_list->qual[dds_locidx].diff_ind = 1
     ENDIF
     IF ((luts_list->qual[dds_locidx].create_del_trigger_ind > 0))
      SET luts_list->create_del_trigger_cnt = (luts_list->create_del_trigger_cnt+ 1)
      SET luts_list->qual[dds_locidx].diff_ind = 1
     ENDIF
     IF ((luts_list->qual[dds_locidx].set_col_stats_ind=1))
      SET luts_list->set_col_stats_cnt = (luts_list->set_col_stats_cnt+ 1)
      SET luts_list->qual[dds_locidx].diff_ind = 1
     ENDIF
     IF ((luts_list->qual[dds_locidx].set_instid_col_stats_ind=1))
      SET luts_list->set_instid_col_stats_cnt = (luts_list->set_instid_col_stats_cnt+ 1)
      SET luts_list->qual[dds_locidx].diff_ind = 1
     ENDIF
     IF ((luts_list->qual[dds_locidx].diff_ind=1))
      SET luts_list->table_diff_cnt = (luts_list->table_diff_cnt+ 1)
     ENDIF
     IF ((luts_list->qual[dds_locidx].add_txn_column_ind=1))
      SET luts_list->add_txn_column_cnt = (luts_list->add_txn_column_cnt+ 1)
      SET luts_list->qual[dds_locidx].add_combined_column_ddl = concat(luts_list->qual[dds_locidx].
       add_combined_column_ddl,",",luts_list->qual[dds_locidx].add_txn_column_ddl)
      SET luts_list->qual[dds_locidx].diff_txn_ind = 1
     ENDIF
     IF ((luts_list->qual[dds_locidx].disable_txn_trigger_ind=1))
      SET luts_list->disable_txn_trigger_cnt = (luts_list->disable_txn_trigger_cnt+ 1)
      SET luts_list->qual[dds_locidx].diff_txn_ind = 1
     ENDIF
     IF ((luts_list->qual[dds_locidx].create_txn_index_ind=1))
      SET luts_list->create_txn_index_cnt = (luts_list->create_txn_index_cnt+ 1)
      SET luts_list->qual[dds_locidx].diff_txn_ind = 1
     ENDIF
     IF ((luts_list->qual[dds_locidx].set_txn_index_visible_ind=1))
      SET luts_list->set_txn_index_visible_cnt = (luts_list->set_txn_index_visible_cnt+ 1)
      SET luts_list->qual[dds_locidx].diff_txn_ind = 1
     ENDIF
     IF ((luts_list->qual[dds_locidx].set_txn_col_stats_ind=1))
      SET luts_list->set_txn_col_stats_cnt = (luts_list->set_txn_col_stats_cnt+ 1)
      SET luts_list->qual[dds_locidx].diff_txn_ind = 1
     ENDIF
     IF ((luts_list->qual[dds_locidx].diff_txn_ind=1))
      SET luts_list->table_diff_txn_cnt = (luts_list->table_diff_txn_cnt+ 1)
     ENDIF
     SET luts_list->qual[dds_locidx].add_combined_column_ddl = concat("ALTER TABLE ",trim(luts_list->
       qual[dds_locidx].table_owner),".",trim(luts_list->qual[dds_locidx].table_name)," ADD (",
      replace(luts_list->qual[dds_locidx].add_combined_column_ddl,",","",1),")")
   ENDFOR
   SET dm_err->eproc = "LAST_UTC_TS: Retrieving tablespace reserve percentage"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_INSTALL_LUTS"
     AND di.info_name IN ("RESERVE_PCT", "RAW_RESERVE_PCT")
    DETAIL
     IF (di.info_name="RESERVE_PCT")
      dds_tsp_reserve_pct = di.info_number
     ELSE
      dds_tsp_raw_reserve_pct = di.info_number
     ENDIF
    WITH nocounter
   ;end select
   IF ((((luts_list->create_index_cnt > 0)) OR ((luts_list->create_txn_index_cnt > 0))) )
    SET dm_err->eproc = "LAST_UTC_TS: Retrieving ASM/RAW tablespace usage"
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dba_data_files ddf
     WHERE tablespace_name="SYSTEM"
      AND file_name="*/dev/*"
     HEAD REPORT
      luts_list->asm_ind = 1
     DETAIL
      luts_list->asm_ind = 0
     WITH nocounter, nullreport
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc =
    "LAST_UTC_TS: Loading existing index tablespaces for affected tables into memory"
    CALL disp_msg("",dm_err->logfile,0)
    SELECT DISTINCT INTO "nl:"
     FROM user_indexes ui
     WHERE ui.index_type="NORMAL"
      AND ui.tablespace_name IS NOT null
      AND  NOT (ui.tablespace_name IN ("SYS", "SYSTEM", "MISC", "*UNDO*"))
     ORDER BY ui.tablespace_name
     HEAD REPORT
      luts_list->tspace_cnt = 0, stat = alterlist(luts_list->ts,luts_list->tspace_cnt)
     DETAIL
      luts_list->tspace_cnt = (luts_list->tspace_cnt+ 1)
      IF (mod(luts_list->tspace_cnt,10)=1)
       stat = alterlist(luts_list->ts,(luts_list->tspace_cnt+ 9))
      ENDIF
      luts_list->ts[luts_list->tspace_cnt].tspace_name = ui.tablespace_name, luts_list->ts[luts_list
      ->tspace_cnt].dg_name = "DM2NOTSET", luts_list->ts[luts_list->tspace_cnt].data_file_cnt = 0
     FOOT REPORT
      stat = alterlist(luts_list->ts,luts_list->tspace_cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((luts_list->asm_ind=1))
     SET dm_err->eproc = "LAST_UTC_TS: Loading data file free space information into memory"
     CALL disp_msg("",dm_err->logfile,0)
     SELECT INTO "nl:"
      FROM dba_data_files ddf
      ORDER BY ddf.tablespace_name, ddf.file_name
      DETAIL
       dds_locidx = locateval(dds_locidx,1,luts_list->tspace_cnt,ddf.tablespace_name,luts_list->ts[
        dds_locidx].tspace_name)
       IF (dds_locidx > 0)
        luts_list->ts[dds_locidx].data_file_cnt = (luts_list->ts[dds_locidx].data_file_cnt+ 1),
        dds_dg_name = substring(2,(findstring("/",ddf.file_name,1,0) - 2),ddf.file_name)
        IF ((luts_list->ts[dds_locidx].dg_name="DM2NOTSET"))
         luts_list->ts[dds_locidx].dg_name = dds_dg_name
        ENDIF
        IF ((dds_dg_name=luts_list->ts[dds_locidx].dg_name))
         IF (ddf.autoextensible="YES")
          luts_list->ts[dds_locidx].max_bytes_mb = (luts_list->ts[dds_locidx].max_bytes_mb+ ((ddf
          .maxbytes/ 1024)/ 1024)), luts_list->ts[dds_locidx].user_bytes_mb = (luts_list->ts[
          dds_locidx].user_bytes_mb+ ((ddf.user_bytes/ 1024)/ 1024)), luts_list->ts[dds_locidx].
          free_bytes_mb = (luts_list->ts[dds_locidx].free_bytes_mb+ (((ddf.maxbytes - ddf.user_bytes)
          / 1024)/ 1024)),
          luts_list->ts[dds_locidx].reserved_bytes_mb = (luts_list->ts[dds_locidx].free_bytes_mb *
          dds_tsp_reserve_pct)
         ENDIF
        ENDIF
       ENDIF
      FOOT  ddf.tablespace_name
       IF (dds_locidx > 0)
        IF ((luts_list->default_index_tspace="DM2NOTSET"))
         luts_list->default_index_tspace = ddf.tablespace_name, luts_list->default_free_bytes_mb =
         luts_list->ts[dds_locidx].free_bytes_mb
        ELSEIF ((luts_list->default_free_bytes_mb < luts_list->ts[dds_locidx].free_bytes_mb))
         luts_list->default_index_tspace = ddf.tablespace_name, luts_list->default_free_bytes_mb =
         luts_list->ts[dds_locidx].free_bytes_mb
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = "LAST_UTC_TS: Loading ASM diskgroup information into memory"
     CALL disp_msg("",dm_err->logfile,0)
     SELECT INTO "nl:"
      FROM v$asm_diskgroup vad
      HEAD REPORT
       luts_list->dg_cnt = 0, stat = alterlist(luts_list->dg,luts_list->dg_cnt)
      DETAIL
       luts_list->dg_cnt = (luts_list->dg_cnt+ 1), stat = alterlist(luts_list->dg,luts_list->dg_cnt),
       luts_list->dg[luts_list->dg_cnt].dg_name = vad.name,
       luts_list->dg[luts_list->dg_cnt].free_bytes_mb = vad.free_mb, luts_list->dg[luts_list->dg_cnt]
       .total_bytes_mb = vad.total_mb, luts_list->dg[luts_list->dg_cnt].reserved_bytes_mb = (vad
       .free_mb * dds_tsp_reserve_pct)
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF ((luts_list->dg_cnt=0))
      SET dm_err->err_ind = 1
      SET dm_err->emsg =
      "LAST_UTC_TS: No diskgroups found in v$asm_diskgroup for LAST_UTC_TS tablespace processing"
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ELSE
     SET dm_err->eproc = "LAST_UTC_TS: Loading raw data file free space into memory"
     CALL disp_msg("",dm_err->logfile,0)
     SELECT INTO "nl:"
      dfs.tablespace_name, free_bytes = max(dfs.bytes), file_cnt = count(dfs.file_id)
      FROM dba_free_space dfs
      GROUP BY dfs.tablespace_name
      ORDER BY dfs.tablespace_name
      DETAIL
       dds_locidx = locateval(dds_locidx,1,luts_list->tspace_cnt,dfs.tablespace_name,luts_list->ts[
        dds_locidx].tspace_name)
       IF (dds_locidx > 0)
        luts_list->ts[dds_locidx].data_file_cnt = 1, luts_list->ts[dds_locidx].free_bytes_mb = ((
        free_bytes/ 1024)/ 1024), luts_list->ts[dds_locidx].reserved_bytes_mb = (luts_list->ts[
        dds_locidx].free_bytes_mb * dds_tsp_raw_reserve_pct)
       ENDIF
      FOOT  dfs.tablespace_name
       IF (dds_locidx > 0)
        IF ((luts_list->default_index_tspace="DM2NOTSET"))
         luts_list->default_index_tspace = dfs.tablespace_name, luts_list->default_free_bytes_mb =
         luts_list->ts[dds_locidx].free_bytes_mb
        ELSEIF ((luts_list->default_free_bytes_mb < luts_list->ts[dds_locidx].free_bytes_mb))
         luts_list->default_index_tspace = dfs.tablespace_name, luts_list->default_free_bytes_mb =
         luts_list->ts[dds_locidx].free_bytes_mb
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    FOR (dds_locidx = 1 TO luts_list->table_cnt)
      IF ((((luts_list->qual[dds_locidx].create_index_ind=1)) OR ((luts_list->qual[dds_locidx].
      create_txn_index_ind=1))) )
       SET luts_list->qual[dds_locidx].index_col_list = evaluate(luts_list->qual[dds_locidx].
        use_inst_id_ind,1,"INST_ID,LAST_UTC_TS","LAST_UTC_TS")
       SET luts_list->qual[dds_locidx].index_txn_col_list = "TXN_ID_TEXT"
       SET dm_err->eproc = concat("LAST_UTC_TS:  Retrieving index tablespaces used by table ",
        luts_list->qual[dds_locidx].table_name)
       CALL disp_msg("",dm_err->logfile,0)
       SELECT DISTINCT INTO "nl:"
        ui.tablespace_name
        FROM user_indexes ui
        WHERE ui.index_type="NORMAL"
         AND  NOT (ui.tablespace_name IN ("MISC", "SYS", "SYSTEM", "UNDO*"))
         AND (ui.table_name=luts_list->qual[dds_locidx].table_name)
        ORDER BY ui.tablespace_name
        HEAD REPORT
         tsidx = 0
        DETAIL
         tsidx = locateval(tsidx,1,luts_list->tspace_cnt,ui.tablespace_name,luts_list->ts[tsidx].
          tspace_name)
         IF (tsidx > 0)
          IF ((luts_list->qual[dds_locidx].index_tspace="DM2NOTSET"))
           luts_list->qual[dds_locidx].index_tspace = luts_list->ts[tsidx].tspace_name
          ELSE
           IF (((luts_list->ts[tsidx].free_bytes_mb - luts_list->ts[tsidx].reserved_bytes_mb) >
           luts_list->qual[dds_locidx].free_bytes_mb))
            luts_list->qual[dds_locidx].index_tspace = luts_list->ts[tsidx].tspace_name, luts_list->
            qual[dds_locidx].free_bytes_mb = (luts_list->ts[tsidx].free_bytes_mb - luts_list->ts[
            tsidx].reserved_bytes_mb)
           ENDIF
          ENDIF
         ENDIF
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       IF ((luts_list->qual[dds_locidx].index_tspace="DM2NOTSET"))
        SET luts_list->qual[dds_locidx].index_tspace = luts_list->default_index_tspace
        SET luts_list->qual[dds_locidx].free_bytes_mb = luts_list->default_free_bytes_mb
       ENDIF
       SET luts_list->qual[dds_locidx].create_index_ddl = concat("CREATE INDEX ",trim(luts_list->
         qual[dds_locidx].table_owner),".",trim(luts_list->qual[dds_locidx].index_name)," ON ",
        trim(luts_list->qual[dds_locidx].table_owner),".",trim(luts_list->qual[dds_locidx].table_name
         )," ( ",trim(luts_list->qual[dds_locidx].index_col_list),
        " )"," LOGGING ONLINE ",evaluate(dds_is_11204,1,"INVISIBLE "," ")," TABLESPACE ",trim(
         luts_list->qual[dds_locidx].index_tspace))
       SET luts_list->qual[dds_locidx].create_txn_index_ddl = concat("CREATE INDEX ",trim(luts_list->
         qual[dds_locidx].table_owner),".",trim(luts_list->qual[dds_locidx].txn_index_name)," ON ",
        trim(luts_list->qual[dds_locidx].table_owner),".",trim(luts_list->qual[dds_locidx].table_name
         )," ( ",trim(luts_list->qual[dds_locidx].index_txn_col_list),
        " )"," LOGGING ONLINE ",evaluate(dds_is_11204,1,"INVISIBLE "," ")," TABLESPACE ",trim(
         luts_list->qual[dds_locidx].index_tspace))
       IF ((luts_list->qual[dds_locidx].tspace_needed_mb=0))
        IF ((luts_list->qual[dds_locidx].tspace_needed_mb=0))
         SET luts_list->qual[dds_locidx].tspace_needed_mb = 1
        ENDIF
       ENDIF
       SET dds_tslocidx = locateval(dds_tslocidx,1,luts_list->tspace_cnt,luts_list->qual[dds_locidx].
        index_tspace,luts_list->ts[dds_tslocidx].tspace_name)
       IF (dds_tslocidx > 0)
        SET luts_list->ts[dds_tslocidx].assigned_bytes_mb = (luts_list->ts[dds_tslocidx].
        assigned_bytes_mb+ luts_list->qual[dds_locidx].tspace_needed_mb)
        SET luts_list->ts[dds_tslocidx].assigned_ind_names = concat(luts_list->ts[dds_tslocidx].
         assigned_ind_names,luts_list->qual[dds_locidx].index_name,",")
        SET luts_list->ts[dds_tslocidx].new_ind_cnt = (luts_list->ts[dds_tslocidx].new_ind_cnt+ 1)
        SET dds_dglocidx = locateval(dds_dglocidx,1,luts_list->dg_cnt,luts_list->ts[dds_tslocidx].
         dg_name,luts_list->dg[dds_dglocidx].dg_name)
        IF (dds_dglocidx > 0)
         SET luts_list->dg[dds_dglocidx].assigned_bytes_mb = (luts_list->dg[dds_dglocidx].
         assigned_bytes_mb+ luts_list->qual[dds_locidx].tspace_needed_mb)
         SET luts_list->dg[dds_dglocidx].new_ind_cnt = (luts_list->dg[dds_dglocidx].new_ind_cnt+ 1)
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF ((((luts_list->set_index_visible_cnt > 0)) OR ((luts_list->set_txn_index_visible_cnt > 0))) )
    FOR (dds_locidx = 1 TO luts_list->table_cnt)
      IF ((((luts_list->qual[dds_locidx].set_index_visible_ind=1)) OR ((luts_list->qual[dds_locidx].
      set_txn_index_visible_ind=1))) )
       IF ((luts_list->qual[dds_locidx].set_index_visible_ind=1))
        SET luts_list->qual[dds_locidx].set_index_visible_ddl = concat('DM2_FINISH_INDEX "',trim(
          luts_list->qual[dds_locidx].table_owner),'","',trim(luts_list->qual[dds_locidx].table_name),
         '","',
         trim(luts_list->qual[dds_locidx].table_owner),'","',trim(luts_list->qual[dds_locidx].
          index_name),'" GO')
       ENDIF
       IF ((luts_list->qual[dds_locidx].set_txn_index_visible_ind=1))
        SET luts_list->qual[dds_locidx].set_txn_index_visible_ddl = concat('DM2_FINISH_INDEX "',trim(
          luts_list->qual[dds_locidx].table_owner),'","',trim(luts_list->qual[dds_locidx].table_name),
         '","',
         trim(luts_list->qual[dds_locidx].table_owner),'","',trim(luts_list->qual[dds_locidx].
          txn_index_name),'" GO')
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   SET dm_err->eproc = "LAST_UTC_TS: Checking for Disk Group impact"
   CALL disp_msg("",dm_err->logfile,0)
   FOR (dds_locidx = 1 TO luts_list->dg_cnt)
     IF ((luts_list->dg[dds_locidx].assigned_bytes_mb > (luts_list->dg[dds_locidx].free_bytes_mb -
     luts_list->dg[dds_locidx].reserved_bytes_mb)))
      SET luts_list->dg_space_needed_ind = 1
     ENDIF
   ENDFOR
   SET dm_err->eproc = "LAST_UTC_TS: Checking for Tablespace impact"
   CALL disp_msg("",dm_err->logfile,0)
   FOR (dds_locidx = 1 TO luts_list->tspace_cnt)
     IF ((luts_list->ts[dds_locidx].assigned_bytes_mb > (luts_list->ts[dds_locidx].free_bytes_mb -
     luts_list->ts[dds_locidx].reserved_bytes_mb)))
      SET luts_list->tspace_needed_ind = 1
     ENDIF
   ENDFOR
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(luts_list)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dld_diff_trigger(ddt_trigger_name,ddt_table_name,ddt_trigger_txt,ddt_diff_ind)
   DECLARE ddt_use_gtt_method = i2 WITH protect, noconstant(0)
   SET ddt_use_gtt_method = 0
   IF (textlen(ddt_trigger_txt) > 4000)
    SET ddt_use_gtt_method = 1
    CALL echo(concat(ddt_trigger_name," on ",ddt_table_name," contains ",build(textlen(
        ddt_trigger_txt)),
      " characters. Using GTT method."))
   ENDIF
   IF (ddt_use_gtt_method=1)
    SET dm_err->eproc = "Load trigger ddl into temp table"
    INSERT  FROM dmp_trig_comp dtc,
      (dummyt d  WITH seq = 1)
     SET dtc.trigger_text = ddt_trigger_txt
     PLAN (d)
      JOIN (dtc)
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ENDIF
   ENDIF
   SET ddt_diff_ind = 0
   SET dm_err->eproc = "Compare trigger"
   SELECT
    IF (ddt_use_gtt_method=1)
     qry_dds_diff_ind = dld_compare_trigger("V500",ddt_trigger_name,null,ddt_use_gtt_method)
    ELSE
     qry_dds_diff_ind = dld_compare_trigger("V500",ddt_trigger_name,ddt_trigger_txt,
      ddt_use_gtt_method)
    ENDIF
    INTO "nl:"
    FROM dual
    DETAIL
     IF (qry_dds_diff_ind=1)
      ddt_diff_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   IF (ddt_use_gtt_method=1)
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dld_load_original_trigger_ddl(null)
   DECLARE dgod_original_ddl_str = vc WITH protect, noconstant("")
   DECLARE dgod_ddl_stmt = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Clear out GTT in prep for original DDL gather"
   DELETE  FROM shared_list_gttd
    WHERE (source_entity_id=- (722))
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Load list of original LUTS triggers"
   INSERT  FROM shared_list_gttd s,
     (dummyt d  WITH seq = value(luts_list->table_cnt))
    SET s.source_entity_id = - (722), s.source_entity_txt = luts_list->qual[d.seq].trigger_name, s
     .source_entity_nbr = d.seq
    PLAN (d
     WHERE (luts_list->qual[d.seq].create_trigger_ind=1)
      AND (luts_list->qual[d.seq].new_trigger_ind=0))
     JOIN (s)
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   INSERT  FROM shared_list_gttd s,
     (dummyt d  WITH seq = value(luts_list->table_cnt))
    SET s.source_entity_id = - (722), s.source_entity_txt = luts_list->qual[d.seq].del_trigger_name,
     s.source_entity_nbr = d.seq
    PLAN (d
     WHERE (luts_list->qual[d.seq].create_del_trigger_ind=1)
      AND (luts_list->qual[d.seq].new_del_trigger_ind=0))
     JOIN (s)
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   SET dgod_ddl_stmt = concat("dbms_metadata.get_ddl('TRIGGER',t.trigger_name,t.owner)")
   SET dm_err->eproc = "Load original DDL for triggers"
   SELECT INTO "nl:"
    FROM (
     (
     (SELECT
      qry_dgod_ddl_str = sqlpassthru(value(dgod_ddl_stmt)), t.trigger_name, array_lookup = s
      .source_entity_nbr
      FROM dba_triggers t,
       shared_list_gttd s
      WHERE t.trigger_name="TRG*LUTS"
       AND t.owner="V500"
       AND t.trigger_name=s.source_entity_txt
       AND (s.source_entity_id=- (722))
      WITH sqltype("C32000","C100","I4")))
     d)
    DETAIL
     IF (trim(d.trigger_name)="TRG_DEL_*LUTS")
      luts_list->qual[d.array_lookup].original_del_trigger_ddl = substring(1,(findstring(
        "ALTER TRIGGER ",d.qry_dgod_ddl_str) - 1),d.qry_dgod_ddl_str), luts_list->qual[d.array_lookup
      ].original_del_trigger_ddl = replace(luts_list->qual[d.array_lookup].original_del_trigger_ddl,
       " EDITIONABLE "," ")
     ELSEIF (trim(d.trigger_name)="TRG*LUTS")
      luts_list->qual[d.array_lookup].original_trigger_ddl = substring(1,(findstring("ALTER TRIGGER ",
        d.qry_dgod_ddl_str) - 1),d.qry_dgod_ddl_str), luts_list->qual[d.array_lookup].
      original_trigger_ddl = replace(luts_list->qual[d.array_lookup].original_trigger_ddl,
       " EDITIONABLE "," ")
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   ROLLBACK
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dld_gen_compound_trigger(dgct_idx,dgct_ddl_txt)
   DECLARE dgct_str = vc WITH protect, noconstant("")
   DECLARE dgct_deltrk_idx = i4 WITH protect, noconstant(0)
   SET dgct_deltrk_idx = luts_list->qual[dgct_idx].delete_tracking_ldt_idx
   SET dgct_str = concat("create or replace trigger ",luts_list->qual[dgct_idx].trigger_name)
   SET dgct_str = concat(dgct_str," for insert or update on ")
   SET dgct_str = concat(dgct_str," ",luts_list->qual[dgct_idx].table_name,char(10),
    " compound trigger ",
    char(10))
   IF ((luts_list->qual[dgct_idx].table_is_scn=1))
    SET dgct_str = concat(dgct_str,
     "  cur_txn_id varchar2(200) := dbms_transaction.local_transaction_id;",char(10),
     "  txn_context_name varchar2(200) := '",luts_list->qual[dgct_idx].table_suffix,
     "TXN_ID';",char(10))
   ENDIF
   IF (dgct_deltrk_idx > 0
    AND (luts_dyn_trig->tbl[dgct_deltrk_idx].txn_log_condition != "<DM2NULLVAL>"))
    SET dgct_str = concat(dgct_str," write_txn_ind number := 0;",char(10))
   ENDIF
   SET dgct_str = concat(dgct_str,
    "  fire_luts_trig varchar2(10) := NVL(SYS_CONTEXT('CERNER','FIRE_LUTS_TRG'),'DM2NULLVAL');",char(
     10),"  curr_del_ind number := 0;",char(10),
    "  context_num number := to_number(nvl(sys_context('CERNER','MILLPURGE_APPL_NBR'),'0'));  ",char(
     10))
   IF ((luts_list->use_txn_table_synonym_ind=1))
    SET dgct_str = concat(dgct_str,"  curr_inst_id number := sys_context('userenv','instance'); ",
     char(10))
   ENDIF
   SET dgct_str = concat(dgct_str,"  before each row is",char(10),"  begin",char(10),
    "    if (fire_luts_trig != 'NO' ",build(luts_list->qual[dgct_idx].txn_info_char)," ) then",char(
     10))
   IF ((luts_list->qual[dgct_idx].table_is_luts > 0))
    SET dgct_str = concat(dgct_str,"        :new.last_utc_ts  := sys_extract_utc(systimestamp);",char
     (10))
    IF ((luts_list->qual[dgct_idx].use_inst_id_ind=1))
     IF ((luts_list->use_txn_table_synonym_ind=1))
      SET dgct_str = concat(dgct_str,"          :NEW.INST_ID := curr_inst_id;",char(10))
     ELSE
      SET dgct_str = concat(dgct_str,"          :NEW.INST_ID := sys_context('userenv','instance');",
       char(10))
     ENDIF
    ENDIF
   ENDIF
   IF ((luts_list->qual[dgct_idx].table_is_scn > 0))
    IF (dgct_deltrk_idx > 0
     AND (luts_dyn_trig->tbl[dgct_deltrk_idx].txn_log_condition != "<DM2NULLVAL>"))
     SET dgct_str = concat(dgct_str,"        if (",char(10))
     SET dgct_str = concat(dgct_str,trim(replace(luts_dyn_trig->tbl[dgct_deltrk_idx].
        txn_log_condition,"<STATE>","NEW")),"        ) or (",char(10))
     SET dgct_str = concat(dgct_str,trim(replace(luts_dyn_trig->tbl[dgct_deltrk_idx].
        txn_log_condition,"<STATE>","OLD")),")",char(10))
     SET dgct_str = concat(dgct_str,"        THEN ",char(10))
     SET dgct_str = concat(dgct_str,"          write_txn_ind := 1;",char(10))
    ENDIF
    SET dgct_str = concat(dgct_str,"          :new.txn_id_text := cur_txn_id;",char(10))
    IF (dgct_deltrk_idx > 0
     AND (luts_dyn_trig->tbl[dgct_deltrk_idx].txn_log_condition != "<DM2NULLVAL>"))
     SET dgct_str = concat(dgct_str,"        end if;",char(10))
    ENDIF
   ENDIF
   SET dgct_str = concat(dgct_str,"    end if;",char(10),"  end before each row;",char(10))
   SET dgct_str = concat(dgct_str,"  after statement is ",char(10),"  begin",char(10),
    "    if (fire_luts_trig != 'NO' ",build(luts_list->qual[dgct_idx].txn_info_char)," ) then",char(
     10))
   IF ((luts_list->qual[dgct_idx].table_is_scn > 0))
    IF (dgct_deltrk_idx > 0
     AND (luts_dyn_trig->tbl[dgct_deltrk_idx].txn_log_condition != "<DM2NULLVAL>"))
     SET dgct_str = concat(dgct_str,"      if (write_txn_ind = 1) then",char(10))
    ENDIF
    SET dgct_str = concat(dgct_str,
     "        if (sys_context('CERNER',txn_context_name) != cur_txn_id or sys_context('CERNER', ",
     "txn_context_name) is null)",char(10),"        then",
     char(10))
    IF ((luts_list->use_txn_table_synonym_ind=1))
     SET dgct_str = concat(dgct_str,
      "          insert into txn_staging_table(owner_name,table_name,txn_id_text,del_ind,appl_context_nbr,inst_id)",
      "values('V500','",luts_list->qual[dgct_idx].table_name,
      "',cur_txn_id,curr_del_ind,context_num,curr_inst_id);",
      char(10))
    ELSE
     SET dgct_str = concat(dgct_str,
      "          insert into dm_txn_tracking(owner_name,table_name,txn_id_text,row_scn,del_ind,appl_context_nbr)",
      "values('V500','",luts_list->qual[dgct_idx].table_name,
      "',cur_txn_id,0,curr_del_ind,context_num);",
      char(10))
    ENDIF
    SET dgct_str = concat(dgct_str,"          dm2_context_control(txn_context_name,cur_txn_id);",char
     (10),"        end if;",char(10))
    IF (dgct_deltrk_idx > 0
     AND (luts_dyn_trig->tbl[dgct_deltrk_idx].txn_log_condition != "<DM2NULLVAL>"))
     SET dgct_str = concat(dgct_str,"      end if;",char(10))
    ENDIF
   ENDIF
   SET dgct_str = concat(dgct_str,"    end if;",char(10),"  end after statement;",char(10),
    "end ",luts_list->qual[dgct_idx].trigger_name,";")
   SET dgct_ddl_txt = dgct_str
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dld_gen_del_compound_trigger(dgdct_idx,dgdct_ddl_txt)
   DECLARE dgdct_str = vc WITH protect, noconstant("")
   DECLARE dgdct_deltrk_idx = i4 WITH protect, noconstant(0)
   SET dgdct_deltrk_idx = luts_list->qual[dgdct_idx].delete_tracking_ldt_idx
   SET dgdct_str = concat("create or replace trigger ",luts_list->qual[dgdct_idx].del_trigger_name)
   SET dgdct_str = concat(dgdct_str," for delete on ")
   SET dgdct_str = concat(dgdct_str," ",luts_list->qual[dgdct_idx].table_name,char(10),
    " compound trigger ",
    char(10))
   IF ((luts_list->qual[dgdct_idx].table_is_scn=1))
    SET dgdct_str = concat(dgdct_str,
     "  cur_txn_id varchar2(200) := dbms_transaction.local_transaction_id;",char(10),
     "  txn_del_context_name varchar2(200) := '",luts_list->qual[dgdct_idx].table_suffix,
     "TXN_ID_D';",char(10))
    IF ((luts_list->use_txn_table_synonym_ind=1))
     SET dgdct_str = concat(dgdct_str,"  curr_inst_id number := sys_context('userenv','instance'); ",
      char(10))
    ENDIF
   ENDIF
   IF ((luts_dyn_trig->tbl[dgdct_deltrk_idx].del_log_condition != "<DM2NULLVAL>")
    AND (luts_list->qual[dgdct_idx].table_is_scn=1))
    SET dgdct_str = concat(dgdct_str," write_txn_ind number := 0;",char(10))
   ENDIF
   SET dgdct_str = concat(dgdct_str,
    "  fire_luts_trig varchar2(10) := NVL(SYS_CONTEXT('CERNER','FIRE_LUTS_TRG'),'DM2NULLVAL');",char(
     10),"  curr_del_ind number := 1;",char(10),
    "  context_num number := to_number(nvl(sys_context('CERNER','MILLPURGE_APPL_NBR'),'0'));  ",char(
     10))
   SET dgdct_str = concat(dgdct_str,"  del_record_threshold number := 1000;",char(10),
    "   type del_record is record",char(10),
    "   (",char(10),"      tn_txt   varchar2(40)",char(10),"     ,pen_txt  varchar2(40)",
    char(10),"     ,pei_txt  number",char(10),"     ,tpk_txt  number",char(10),
    "     ,data_txt varchar2(4000)",char(10),"   );",char(10),
    "   type del_record_list is table of del_record index by binary_integer;",
    char(10),"   del_rows del_record_list;",char(10),"   del_cnt number := 0;",char(10),
    "   procedure write_deletes",char(10),"   is",char(10),
    "     write_cnt constant simple_integer := del_rows.count();",
    char(10),"     write_ndx simple_integer := 0;",char(10),"   begin",char(10),
    "     forall write_ndx in 1..write_cnt",char(10),"       insert into dm_delete_tracking",
    "       (dm_delete_tracking_id,table_name,parent_entity_name,parent_entity_id,table_pk_value,data_text,last_utc_ts,",
    "        updt_id,updt_dt_tm,updt_applctx,updt_cnt,purge_appl_nbr",
    evaluate(luts_list->qual[dgdct_idx].table_is_scn,1,",txn_id_text)",")"),char(10),
    "           values",char(10),"       (dm_delete_tracking_seq.nextval,'",
    luts_list->qual[dgdct_idx].table_name,"',del_rows(write_ndx).pen_txt,",
    "        del_rows(write_ndx).pei_txt,del_rows(write_ndx).tpk_txt,del_rows(write_ndx).data_txt,",
    "       sys_extract_utc(systimestamp),0,sysdate,0,0,context_num",evaluate(luts_list->qual[
     dgdct_idx].table_is_scn,1,",cur_txn_id);",");"),
    char(10),"     del_rows.delete();",char(10),"     del_cnt := 0;",char(10),
    "   end write_deletes;",char(10))
   SET dgdct_str = concat(dgdct_str,"  before each row is",char(10),"  begin",char(10),
    "    if (fire_luts_trig != 'NO' ",build(luts_list->qual[dgdct_idx].txn_info_char)," ) then",char(
     10))
   IF ((luts_dyn_trig->tbl[dgdct_deltrk_idx].del_log_condition != "<DM2NULLVAL>"))
    SET dgdct_str = concat(dgdct_str,"        if ",char(10))
    SET dgdct_str = concat(dgdct_str,replace(luts_dyn_trig->tbl[dgdct_deltrk_idx].del_log_condition,
      "<STATE>","OLD"),char(10))
    SET dgdct_str = concat(dgdct_str,"        THEN ",char(10))
    IF ((luts_list->qual[dgdct_idx].table_is_scn > 0))
     SET dgdct_str = concat(dgdct_str,"          write_txn_ind := 1;",char(10))
    ENDIF
   ENDIF
   SET dgdct_str = concat(dgdct_str,"          del_cnt := del_cnt + 1;",char(10))
   SET dgdct_str = concat(dgdct_str,"          del_rows(del_cnt).tn_txt := ",evaluate(luts_dyn_trig->
     tbl[dgdct_deltrk_idx].tn_txt,"<DM2NULLVAL>","null",luts_dyn_trig->tbl[dgdct_deltrk_idx].tn_txt),
    ";",char(10))
   SET dgdct_str = concat(dgdct_str,"          del_rows(del_cnt).pen_txt := ",evaluate(luts_dyn_trig
     ->tbl[dgdct_deltrk_idx].pen_txt,"<DM2NULLVAL>","null",luts_dyn_trig->tbl[dgdct_deltrk_idx].
     pen_txt),";",char(10))
   SET dgdct_str = concat(dgdct_str,"          del_rows(del_cnt).pei_txt := ",evaluate(luts_dyn_trig
     ->tbl[dgdct_deltrk_idx].pei_txt,"<DM2NULLVAL>","null",luts_dyn_trig->tbl[dgdct_deltrk_idx].
     pei_txt),";",char(10))
   SET dgdct_str = concat(dgdct_str,"          del_rows(del_cnt).tpk_txt := ",evaluate(luts_dyn_trig
     ->tbl[dgdct_deltrk_idx].tpk_txt,"<DM2NULLVAL>","null",luts_dyn_trig->tbl[dgdct_deltrk_idx].
     tpk_txt),";",char(10))
   SET dgdct_str = concat(dgdct_str,"          del_rows(del_cnt).data_txt := ",evaluate(luts_dyn_trig
     ->tbl[dgdct_deltrk_idx].data_txt,"<DM2NULLVAL>","null",luts_dyn_trig->tbl[dgdct_deltrk_idx].
     data_txt),";",char(10))
   IF ((luts_dyn_trig->tbl[dgdct_deltrk_idx].dup_delrow_var_values != "<DM2NULLVAL>"))
    SET dgdct_str = concat(dgdct_str,"          del_cnt := del_cnt + 1;",char(10))
    SET dgdct_str = concat(dgdct_str,"          ",luts_dyn_trig->tbl[dgdct_deltrk_idx].
     dup_delrow_var_values,char(10))
   ENDIF
   SET dgdct_str = concat(dgdct_str,"          if del_cnt >= del_record_threshold then",char(10),
    "            write_deletes();",char(10),
    "          end if;",char(10))
   IF ((luts_dyn_trig->tbl[dgdct_deltrk_idx].del_log_condition != "<DM2NULLVAL>"))
    SET dgdct_str = concat(dgdct_str,"        end if;",char(10))
   ENDIF
   SET dgdct_str = concat(dgdct_str,"    end if;",char(10),"  end before each row;",char(10))
   SET dgdct_str = concat(dgdct_str,"  after statement is ",char(10),"  begin",char(10),
    "    if (fire_luts_trig != 'NO' ",build(luts_list->qual[dgdct_idx].txn_info_char)," ) then",char(
     10))
   SET dgdct_str = concat(dgdct_str,"        if del_cnt > 0 then",char(10),
    "          write_deletes();",char(10),
    "        end if;",char(10))
   IF ((luts_list->qual[dgdct_idx].table_is_scn > 0))
    IF ((luts_dyn_trig->tbl[dgdct_deltrk_idx].del_log_condition != "<DM2NULLVAL>"))
     SET dgdct_str = concat(dgdct_str,"      if (write_txn_ind = 1) then",char(10))
    ENDIF
    SET dgdct_str = concat(dgdct_str,
     "        if (sys_context('CERNER',txn_del_context_name) != cur_txn_id or sys_context('CERNER', ",
     "txn_del_context_name) is null)",char(10),"        then",
     char(10))
    IF ((luts_list->use_txn_table_synonym_ind=1))
     SET dgdct_str = concat(dgdct_str,
      "          insert into txn_staging_table(owner_name,table_name,txn_id_text,del_ind,appl_context_nbr,inst_id)",
      "values('V500','",luts_list->qual[dgdct_idx].table_name,
      "',cur_txn_id,curr_del_ind,context_num,curr_inst_id);",
      char(10))
    ELSE
     SET dgdct_str = concat(dgdct_str,
      "          insert into dm_txn_tracking(owner_name,table_name,txn_id_text,row_scn,del_ind,appl_context_nbr)",
      "values('V500','",luts_list->qual[dgdct_idx].table_name,
      "',cur_txn_id,0,curr_del_ind,context_num);",
      char(10))
    ENDIF
    SET dgdct_str = concat(dgdct_str,
     "          dm2_context_control(txn_del_context_name,cur_txn_id);",char(10),"        end if;",
     char(10))
    IF ((luts_dyn_trig->tbl[dgdct_deltrk_idx].del_log_condition != "<DM2NULLVAL>"))
     SET dgdct_str = concat(dgdct_str,"      end if;",char(10))
    ENDIF
   ENDIF
   SET dgdct_str = concat(dgdct_str,"    end if;",char(10),"  end after statement;",char(10),
    "end ",luts_list->qual[dgdct_idx].del_trigger_name,";")
   SET dgdct_ddl_txt = dgdct_str
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dld_gen_lutsonly_trigger(dglt_idx,dglt_ddl_txt)
   DECLARE dglt_str = vc WITH protect, noconstant("")
   SET dglt_str = concat("create or replace trigger ",luts_list->qual[dglt_idx].trigger_name)
   SET dglt_str = concat(dglt_str," before insert or update on ")
   SET dglt_str = concat(dglt_str," ",luts_list->qual[dglt_idx].table_name,char(10)," for each row ",
    char(10)," when (NVL(SYS_CONTEXT('CERNER','FIRE_LUTS_TRG'),'DM2NULLVAL')  != 'NO') ",char(10))
   SET dglt_str = concat(dglt_str,"begin ",char(10))
   SET dglt_str = concat(dglt_str,concat("  :NEW.LAST_UTC_TS := SYS_EXTRACT_UTC(SYSTIMESTAMP);",char(
      10))," ")
   IF ((luts_list->qual[dglt_idx].use_inst_id_ind=1))
    SET dglt_str = concat(dglt_str,char(10),"  :NEW.INST_ID := sys_context('userenv','instance');",
     char(10))
   ENDIF
   SET dglt_str = concat(dglt_str,"exception",char(10),"when others then",char(10),
    "  null;",char(10),"end;",char(10))
   SET dglt_ddl_txt = dglt_str
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
 DECLARE dpluts_logfile_prefix = vc WITH protect, constant("dm2_valluts")
 DECLARE dpluts_inowner = vc WITH protect, noconstant("DM2NOTSET")
 DECLARE dpluts_intable = vc WITH protect, noconstant("DM2NOTSET")
 DECLARE dpluts_inmode = vc WITH protect, noconstant("DM2NOTSET")
 DECLARE dpluts_idx = i4 WITH protect, noconstant(0)
 DECLARE dpluts_is_11204 = i2 WITH protect, noconstant(0)
 DECLARE dpluts_cmd = vc WITH protect, noconstant("")
 DECLARE set_module(module_name=vc,action_name=vc) = null WITH sql =
 "SYS.DBMS_APPLICATION_INFO.SET_MODULE", parameter
 DECLARE set_client_info(client_info=vc) = null WITH sql =
 "SYS.DBMS_APPLICATION_INFO.SET_CLIENT_INFO", parameter
 IF (check_logfile(dpluts_logfile_prefix,".log","dm2_preview_luts")=0)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Beginning dm2_preview_luts"
 CALL disp_msg("",dm_err->logfile,0)
 SET dpluts_inowner =  $1
 SET dpluts_intable =  $2
 SET dpluts_inmode =  $3
 IF (dm2_get_rdbms_version(null)=0)
  GO TO exit_program
 ENDIF
 IF ((((dm2_rdbms_version->level1 > 11)) OR ((((dm2_rdbms_version->level1=11)
  AND (dm2_rdbms_version->level2 > 2)) OR ((((dm2_rdbms_version->level1=11)
  AND (dm2_rdbms_version->level2=2)
  AND (dm2_rdbms_version->level3 > 0)) OR ((dm2_rdbms_version->level1=11)
  AND (dm2_rdbms_version->level2=2)
  AND (dm2_rdbms_version->level3=0)
  AND (dm2_rdbms_version->level4 >= 4))) )) )) )
  SET dpluts_is_11204 = 1
 ENDIF
 IF (dld_load_curr_txn_table(null)=0)
  GO TO exit_program
 ELSE
  CALL disp_msg("Synonym information loaded",dm_err->logfile,0)
 ENDIF
 IF (dld_load_tables(null)=0)
  GO TO exit_program
 ELSE
  CALL disp_msg("Driver information loaded",dm_err->logfile,0)
 ENDIF
 IF (dld_diff_schema(null)=0)
  GO TO exit_program
 ELSE
  CALL disp_msg("Driver information loaded",dm_err->logfile,0)
 ENDIF
 IF ((luts_list->install_by_rdm_ind=1))
  SET dm_err->eproc = "LAST_UTC_TS: Skipping preview reports due to readme execution context"
  CALL disp_msg("",dm_err->logfile,0)
  GO TO exit_program
 ENDIF
 IF (dpluts_inmode="VALIDATE")
  SELECT INTO "MINE"
   FROM dual
   HEAD REPORT
    CALL print(fillstring(250,"-"))
    IF ((luts_list->txn_schema_ind > 0))
     row + 1, col 0,
     CALL print("Install TXN_ID_TEXT Schema Changes [VALIDATE]"),
     row + 2, col 0,
     CALL print("Tables evaluated:"),
     col 50,
     CALL print(luts_list->table_cnt), row + 1,
     col 0,
     CALL print("Table requiring TXN column:"), col 50,
     CALL print(luts_list->add_txn_column_cnt), row + 1, col 0,
     CALL print("Table requiring TXN index:"), col 50,
     CALL print(luts_list->create_txn_index_cnt)
     IF (dpluts_is_11204=1)
      row + 1, col 0,
      CALL print("Table requiring set TXN index visible:"),
      col 50,
      CALL print(luts_list->set_txn_index_visible_cnt)
     ENDIF
     row + 1, col 0,
     CALL print("Table requiring TXN column stats:"),
     col 50,
     CALL print(luts_list->set_txn_col_stats_cnt)
     IF ((luts_list->use_txn_table_synonym_ind != 0))
      row + 1, col 0,
      CALL print("Synonym Update :"),
      col 50,
      CALL print(concat("TXN_STAGING_TABLE To ",luts_list->config_curr_txn_table))
     ENDIF
     row + 2, col 0,
     CALL print(fillstring(250,"-"))
    ENDIF
    row + 1, col 0,
    CALL print("Install LAST_UTC_TS Schema Changes [VALIDATE]"),
    row + 2, col 0,
    CALL print("Tables evaluated:"),
    col 50,
    CALL print(luts_list->table_cnt), row + 1,
    col 0,
    CALL print("Table requiring LUTS column:"), col 50,
    CALL print(luts_list->add_column_cnt), row + 1, col 0,
    CALL print("Table requiring INST_ID column:"), col 50,
    CALL print(luts_list->add_instid_column_cnt),
    row + 1, col 0,
    CALL print("Table requiring LUTS index:"),
    col 50,
    CALL print(luts_list->create_index_cnt)
    IF (dpluts_is_11204=1)
     row + 1, col 0,
     CALL print("Table requiring set LUTS index visible:"),
     col 50,
     CALL print(luts_list->set_index_visible_cnt)
    ENDIF
    row + 1, col 0,
    CALL print("Table requiring LUTS column stats:"),
    col 50,
    CALL print(luts_list->set_col_stats_cnt), row + 1,
    col 0,
    CALL print("Table requiring INST_ID column stats:"), col 50,
    CALL print(luts_list->set_instid_col_stats_cnt), row + 1, col 0,
    CALL print("Table requiring LUTS trigger:"), col 50,
    CALL print(luts_list->create_trigger_cnt),
    row + 1, col 0,
    CALL print("Table requiring DEL trigger:"),
    col 50,
    CALL print(luts_list->create_del_trigger_cnt), row + 2,
    col 0,
    CALL print(fillstring(250,"-"))
    IF ((luts_drop_list->table_cnt > 0))
     row + 1, col 0,
     CALL print("Extraneous Object Cleanup [PREVIEW]"),
     row + 2, col 0,
     CALL print("Table requiring LUTS trigger cleanup:"),
     col 50,
     CALL print(luts_drop_list->drop_trigger_cnt), row + 1,
     col 0,
     CALL print("Table requiring DEL trigger cleanup:"), col 50,
     CALL print(luts_drop_list->drop_del_trigger_cnt), row + 1, col 0,
     CALL print("Table requiring LUTS index cleanup:"), col 50,
     CALL print(luts_drop_list->drop_index_cnt),
     row + 1, col 0,
     CALL print("Table requiring TXN trigger cleanup:"),
     col 50,
     CALL print(luts_drop_list->drop_txn_trigger_cnt), row + 1,
     col 0,
     CALL print("Table requiring TXN package cleanup:"), col 50,
     CALL print(luts_drop_list->drop_txn_pkg_cnt), row + 1, col 0,
     CALL print("Table requiring TXN index cleanup:"), col 50,
     CALL print(luts_drop_list->drop_txn_index_cnt)
    ENDIF
    IF ((luts_list->table_diff_cnt=0)
     AND (luts_list->table_diff_txn_cnt=0)
     AND (luts_drop_list->table_cnt=0))
     row + 2, col 0,
     CALL print(" LAST_UTC_TS Column Schema is correct for all tables")
    ELSE
     row + 2, col 2,
     CALL print(concat(build(luts_list->table_diff_cnt)," table(s) require schema changes")),
     row + 2, col 2,
     CALL print(concat("Please follow the PREVIEW and INSTALL menu ",
      "options to properly install the missing database schema"))
    ENDIF
   WITH nocounter, formfeed = none, format = variable,
    maxcol = 1000
  ;end select
 ELSE
  SELECT INTO "MINE"
   FROM dual
   DETAIL
    CALL print(fillstring(250,"*"))
    IF ((luts_list->txn_schema_ind > 0))
     row + 1, col 0,
     CALL print("Install TXN_ID_TEXT Schema Changes [PREVIEW]"),
     row + 2, col 0,
     CALL print("Tables evaluated:"),
     col 50,
     CALL print(luts_list->table_cnt), row + 1,
     col 0,
     CALL print("Tables requiring TXN changes:"), col 50,
     CALL print(luts_list->table_diff_txn_cnt), row + 1, col 0,
     CALL print("Table requiring TXN column:"), col 50,
     CALL print(luts_list->add_txn_column_cnt),
     row + 1, col 0,
     CALL print("Table requiring TXN index:"),
     col 50,
     CALL print(luts_list->create_txn_index_cnt)
     IF (dpluts_is_11204=1)
      row + 1, col 0,
      CALL print("Table requiring set TXN index visible:"),
      col 50,
      CALL print(luts_list->set_txn_index_visible_cnt)
     ENDIF
     row + 1, col 0,
     CALL print("Table requiring TXN column stats:"),
     col 50,
     CALL print(luts_list->set_txn_col_stats_cnt), row + 1,
     col 0,
     CALL print("Table requiring disable TXN trigger:"), col 50,
     CALL print(luts_list->disable_txn_trigger_cnt)
     IF ((luts_list->use_txn_table_synonym_ind != 0))
      row + 1, col 0,
      CALL print("Synonym Update :"),
      col 50,
      CALL print(concat("TXN_STAGING_TABLE To ",luts_list->config_curr_txn_table))
     ENDIF
     row + 2, col 0,
     CALL print(fillstring(250,"*"))
    ENDIF
    row + 1, col 0,
    CALL print("Install LAST_UTC_TS Schema Changes [PREVIEW]"),
    row + 2, col 0,
    CALL print("Tables evaluated:"),
    col 50,
    CALL print(luts_list->table_cnt), row + 1,
    col 0,
    CALL print("Tables requiring LUTS changes:"), col 50,
    CALL print(luts_list->table_diff_cnt), row + 1, col 0,
    CALL print("Table requiring LUTS column:"), col 50,
    CALL print(luts_list->add_column_cnt),
    row + 1, col 0,
    CALL print("Table requiring INST_ID column:"),
    col 50,
    CALL print(luts_list->add_instid_column_cnt), row + 1,
    col 0,
    CALL print("Table requiring LUTS index:"), col 50,
    CALL print(luts_list->create_index_cnt), row + 1, col 0,
    CALL print("Table requiring rename LUTS index:"), col 50,
    CALL print(luts_list->rename_index_cnt)
    IF (dpluts_is_11204=1)
     row + 1, col 0,
     CALL print("Table requiring set LUTS index visible:"),
     col 50,
     CALL print(luts_list->set_index_visible_cnt)
    ENDIF
    row + 1, col 0,
    CALL print("Table requiring LUTS column stats:"),
    col 50,
    CALL print(luts_list->set_col_stats_cnt), row + 1,
    col 0,
    CALL print("Table requiring INST_ID column stats:"), col 50,
    CALL print(luts_list->set_instid_col_stats_cnt), row + 1, col 0,
    CALL print("Table requiring LUTS trigger:"), col 50,
    CALL print(luts_list->create_trigger_cnt),
    row + 1, col 0,
    CALL print("Table requiring DEL trigger:"),
    col 50,
    CALL print(luts_list->create_del_trigger_cnt), row + 2,
    col 0,
    CALL print(fillstring(250,"*"))
    IF ((luts_drop_list->table_cnt > 0))
     row + 1, col 0,
     CALL print("Extraneous Object Cleanup [PREVIEW]"),
     row + 2, col 0,
     CALL print("Table requiring LUTS trigger cleanup:"),
     col 50,
     CALL print(luts_drop_list->drop_trigger_cnt), row + 1,
     col 0,
     CALL print("Table requiring DEL trigger cleanup:"), col 50,
     CALL print(luts_drop_list->drop_del_trigger_cnt), row + 1, col 0,
     CALL print("Table requiring LUTS index cleanup:"), col 50,
     CALL print(luts_drop_list->drop_index_cnt),
     row + 1, col 0,
     CALL print("Table requiring TXN trigger cleanup:"),
     col 50,
     CALL print(luts_drop_list->drop_txn_trigger_cnt), row + 1,
     col 0,
     CALL print("Table requiring TXN package cleanup:"), col 50,
     CALL print(luts_drop_list->drop_txn_pkg_cnt), row + 1, col 0,
     CALL print("Table requiring TXN index cleanup:"), col 50,
     CALL print(luts_drop_list->drop_txn_index_cnt)
    ENDIF
    dpluts_idx = 0
    IF ((((luts_list->table_diff_cnt > 0)) OR ((luts_list->table_diff_txn_cnt > 0))) )
     row + 2, col 0,
     CALL print("PHASE 1 DDL:  ALTER TABLE ADD A COLUMN"),
     row + 1, col 0,
     CALL print(fillstring(60,"-"))
     IF ((luts_list->add_column_cnt=0)
      AND (luts_list->add_txn_column_cnt=0)
      AND (luts_list->add_instid_column_cnt=0))
      row + 1, col 4, "No columns to add"
     ELSE
      FOR (dpluts_idx = 1 TO luts_list->table_cnt)
        IF ((((luts_list->qual[dpluts_idx].add_column_ind=1)) OR ((((luts_list->qual[dpluts_idx].
        add_txn_column_ind=1)) OR ((luts_list->qual[dpluts_idx].add_instid_column_ind=1))) )) )
         row + 1, col 4, luts_list->qual[dpluts_idx].add_combined_column_ddl
        ENDIF
      ENDFOR
     ENDIF
     row + 2, col 0,
     CALL print("PHASE 2 STATS: SET COLUMN STATS"),
     row + 1, col 0,
     CALL print(fillstring(60,"-"))
     IF ((luts_list->set_col_stats_cnt=0)
      AND (luts_list->set_txn_col_stats_cnt=0)
      AND (luts_list->set_instid_col_stats_cnt=0))
      row + 1, col 4, "No column statistics need to be set"
     ELSE
      FOR (dpluts_idx = 1 TO luts_list->table_cnt)
        IF ((luts_list->qual[dpluts_idx].set_col_stats_ind=1))
         row + 1, col 4,
         CALL print(concat("DBMS_STATS.SET_COLUMN_STATS(ownname=>'",luts_list->qual[dpluts_idx].
          table_owner,"', tabname=>'",luts_list->qual[dpluts_idx].table_name,
          "', colname =>'LAST_UTC_TS', nullcnt=>",
          build(cnvtint(luts_list->qual[dpluts_idx].num_rows)),
          ", avgclen=>1, force=>true, no_invalidate=>false);"))
        ENDIF
        IF ((luts_list->qual[dpluts_idx].set_txn_col_stats_ind=1))
         row + 1, col 4,
         CALL print(concat("DBMS_STATS.SET_COLUMN_STATS(ownname=>'",luts_list->qual[dpluts_idx].
          table_owner,"', tabname=>'",luts_list->qual[dpluts_idx].table_name,
          "', colname =>'TXN_ID_TEXT', nullcnt=>",
          build(cnvtint(luts_list->qual[dpluts_idx].num_rows)),
          ", avgclen=>1, force=>true, no_invalidate=>false);"))
        ENDIF
        IF ((luts_list->qual[dpluts_idx].set_instid_col_stats_ind=1))
         row + 1, col 4,
         CALL print(concat("DBMS_STATS.SET_COLUMN_STATS(ownname=>'",luts_list->qual[dpluts_idx].
          table_owner,"', tabname=>'",luts_list->qual[dpluts_idx].table_name,
          "', colname =>'INST_ID', nullcnt=>",
          build(cnvtint((luts_list->qual[dpluts_idx].num_rows * 0.90))),", distcnt=> ",build(
           luts_list->inst_cnt),", avgclen=>1, force=>true, no_invalidate=>false);"))
        ENDIF
      ENDFOR
     ENDIF
     row + 2, col 0,
     CALL print("PHASE 3 DDL: RENAME INDEX"),
     row + 1, col 0,
     CALL print(fillstring(60,"-"))
     IF ((luts_list->rename_index_cnt=0))
      row + 1, col 4, "No indexes to rename"
     ELSE
      FOR (dpluts_idx = 1 TO luts_list->table_cnt)
        IF ((luts_list->qual[dpluts_idx].rename_index_ind=1))
         row + 1, col 4, luts_list->qual[dpluts_idx].rename_index_ddl
        ENDIF
      ENDFOR
     ENDIF
     row + 2, col 0,
     CALL print("PHASE 4 DDL: CREATE INDEX"),
     row + 1, col 0,
     CALL print(fillstring(60,"-"))
     IF ((luts_list->create_index_cnt=0)
      AND (luts_list->create_txn_index_cnt=0))
      row + 1, col 4, "No indexes to create"
     ELSE
      FOR (dpluts_idx = 1 TO luts_list->table_cnt)
       IF ((luts_list->qual[dpluts_idx].create_index_ind=1))
        row + 1, col 4, luts_list->qual[dpluts_idx].create_index_ddl
       ENDIF
       ,
       IF ((luts_list->qual[dpluts_idx].create_txn_index_ind=1))
        row + 1, col 4, luts_list->qual[dpluts_idx].create_txn_index_ddl
       ENDIF
      ENDFOR
     ENDIF
     IF (dpluts_is_11204=1)
      row + 2, col 0,
      CALL print("PHASE 5 DDL: SET INDEX VISIBLE"),
      row + 1, col 0,
      CALL print(fillstring(60,"-"))
      IF ((luts_list->set_index_visible_cnt=0)
       AND (luts_list->set_txn_index_visible_cnt=0))
       row + 1, col 4, "No indexes to set visible"
      ELSE
       FOR (dpluts_idx = 1 TO luts_list->table_cnt)
        IF ((luts_list->qual[dpluts_idx].set_index_visible_ind=1))
         row + 1, col 4, luts_list->qual[dpluts_idx].set_index_visible_ddl
        ENDIF
        ,
        IF ((luts_list->qual[dpluts_idx].set_txn_index_visible_ind=1))
         row + 1, col 4, luts_list->qual[dpluts_idx].set_txn_index_visible_ddl
        ENDIF
       ENDFOR
      ENDIF
     ENDIF
     row + 2, col 0,
     CALL print("PHASE 6 DDL: CREATE OR REPLACE A TRIGGER"),
     row + 1, col 0,
     CALL print(fillstring(60,"-"))
     IF ((luts_list->create_trigger_cnt=0)
      AND (luts_list->create_del_trigger_cnt=0))
      row + 1, col 4, "No triggers to create"
     ELSE
      FOR (dpluts_idx = 1 TO luts_list->table_cnt)
       IF ((luts_list->qual[dpluts_idx].create_del_trigger_ind > 0))
        row + 1, col 4,
        CALL print(substring(1,499,luts_list->qual[dpluts_idx].create_del_trigger_ddl))
       ENDIF
       ,
       IF ((luts_list->qual[dpluts_idx].create_trigger_ind > 0))
        row + 1, col 4,
        CALL print(substring(1,499,luts_list->qual[dpluts_idx].create_trigger_ddl))
       ENDIF
      ENDFOR
     ENDIF
     row + 2, col 0,
     CALL print("PHASE 7 DDL: DISABLE TXN TRIGGER"),
     row + 1, col 0,
     CALL print(fillstring(60,"-"))
     IF ((luts_list->disable_txn_trigger_cnt=0))
      row + 1, col 4, "No triggers to disable"
     ELSE
      FOR (dpluts_idx = 1 TO luts_list->table_cnt)
        IF ((luts_list->qual[dpluts_idx].disable_txn_trigger_ind > 0))
         row + 1, col 4,
         CALL print(substring(1,499,luts_list->qual[dpluts_idx].disable_txn_trigger_ddl))
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
    IF ((luts_drop_list->table_cnt > 0))
     row + 2, col 0,
     CALL print("PHASE 8 DDL: DROP EXTRANEOUS OBJECTS"),
     row + 1, col 0,
     CALL print(fillstring(60,"-"))
     FOR (dis_idx = 1 TO luts_drop_list->table_cnt)
       IF ((luts_drop_list->qual[dis_idx].drop_trigger_ind=1))
        row + 1, col 4, luts_drop_list->qual[dis_idx].drop_trigger_ddl,
        col 64, luts_drop_list->qual[dis_idx].drop_trigger_reason
       ENDIF
       IF ((luts_drop_list->qual[dis_idx].drop_del_trigger_ind=1))
        row + 1, col 4, luts_drop_list->qual[dis_idx].drop_del_trigger_ddl,
        col 64, luts_drop_list->qual[dis_idx].drop_del_trigger_reason
       ENDIF
       IF ((luts_drop_list->qual[dis_idx].drop_txn_trigger_ind=1))
        row + 1, col 4, luts_drop_list->qual[dis_idx].drop_txn_trigger_ddl,
        col 64, luts_drop_list->qual[dis_idx].drop_txn_trigger_reason
       ENDIF
       IF ((luts_drop_list->qual[dis_idx].drop_txn_pkg_ind=1))
        row + 1, col 4, luts_drop_list->qual[dis_idx].drop_txn_pkg_ddl,
        col 64, luts_drop_list->qual[dis_idx].drop_txn_pkg_reason
       ENDIF
       IF ((luts_drop_list->qual[dis_idx].drop_index_ind=1))
        row + 1, col 4, luts_drop_list->qual[dis_idx].drop_index_ddl,
        col 64, luts_drop_list->qual[dis_idx].drop_index_reason
       ENDIF
       IF ((luts_drop_list->qual[dis_idx].drop_txn_index_ind=1))
        row + 1, col 4, luts_drop_list->qual[dis_idx].drop_txn_index_ddl,
        col 64, luts_drop_list->qual[dis_idx].drop_txn_index_reason
       ENDIF
     ENDFOR
    ENDIF
   FOOT REPORT
    IF ((((luts_list->table_diff_cnt > 0)) OR ((((luts_drop_list->table_cnt > 0)) OR ((luts_list->
    table_diff_txn_cnt > 0))) )) )
     row + 2, col 0,
     CALL print("************** End of Preview Report ***************")
    ELSE
     row + 2, col 0,
     CALL print("             No Schema Changes required "),
     row + 2, col 0,
     CALL print("************** End of Preview Report ***************")
    ENDIF
   WITH nocounter, formfeed = none, format = variable,
    maxcol = 1000, nullreport
  ;end select
  IF ((luts_list->create_index_cnt > 0))
   SELECT INTO "MINE"
    FROM dual
    HEAD REPORT
     CALL print(fillstring(250,"*")), row + 1, col 0,
     CALL print("Install LAST_UTC_TS: Tablespace Impact [PREVIEW]"), row + 2, col 0,
     CALL print("Tables evaluated:"), col 32,
     CALL print(luts_list->table_cnt),
     row + 1, col 0,
     CALL print("Tables with new indexes:"),
     col 32,
     CALL print(luts_list->create_index_cnt), row + 1,
     col 0,
     CALL print(fillstring(250,"*")), dpluts_idx = 0
    DETAIL
     IF ((((luts_list->create_index_cnt > 0)) OR ((luts_list->create_txn_index_cnt > 0))) )
      row + 2, col 0,
      CALL print(
      "This report displays the tablespace impact for new indexes being built by this process."),
      row + 2, col 0,
      CALL print(
      "Consuming all free space in an Oracle tablespace can cause errors to Millennium Applications, "
      ),
      row + 1, col 0,
      CALL print(
      "so it is critical to ensure that adequate free space exists to build the new indexes."),
      row + 2, col 0,
      CALL print(
      "This report should be reviewed with the Database Administrator responsible for this database."
      )
      IF ((luts_list->dg_cnt > 0))
       row + 2, col 0,
       CALL print(fillstring(60,"-")),
       row + 1, col 0,
       CALL print("Space Impact By Diskgroup in Megabytes (MB)"),
       row + 1, col 0,
       CALL print(fillstring(60,"-")),
       row + 1, col 0,
       CALL print(
       " >> Review the 'Disk Group Space Needed MB' column for any Disk Groups needing more space."),
       row + 2, col 32,
       CALL print("   New"),
       col 41,
       CALL print("       New"), col 51,
       CALL print("   Disk Group"), col 65,
       CALL print("   Disk Group"),
       row + 1, col 32,
       CALL print(" Index"),
       col 41,
       CALL print("     Index"), col 51,
       CALL print("   Free Space"), col 65,
       CALL print(" Space Needed"),
       row + 1, col 0,
       CALL print("Disk Group Name"),
       col 32,
       CALL print(" Count"), col 41,
       CALL print("   Cost MB"), col 51,
       CALL print("           MB"),
       col 65,
       CALL print("           MB"), row + 1,
       col 0,
       CALL print(fillstring(30,"-")), col 32,
       CALL print(fillstring(6,"-")), col 41,
       CALL print(fillstring(10,"-")),
       col 54,
       CALL print(fillstring(10,"-")), col 66,
       CALL print(fillstring(12,"-"))
       FOR (dpluts_idx = 1 TO luts_list->dg_cnt)
         IF ((luts_list->dg[dpluts_idx].assigned_bytes_mb > 0))
          row + 1, col 0,
          CALL print(luts_list->dg[dpluts_idx].dg_name),
          col 34,
          CALL print(format(luts_list->dg[dpluts_idx].new_ind_cnt,"####")), col 42,
          CALL print(format(luts_list->dg[dpluts_idx].assigned_bytes_mb,"######.##")), col 58,
          CALL print(format((luts_list->dg[dpluts_idx].free_bytes_mb - luts_list->dg[dpluts_idx].
           reserved_bytes_mb),"######"))
          IF (((luts_list->dg[dpluts_idx].free_bytes_mb - luts_list->dg[dpluts_idx].reserved_bytes_mb
          ) > luts_list->dg[dpluts_idx].assigned_bytes_mb))
           col 77,
           CALL print("0")
          ELSE
           col 72,
           CALL print(format((luts_list->dg[dpluts_idx].assigned_bytes_mb - (luts_list->dg[dpluts_idx
            ].free_bytes_mb - luts_list->dg[dpluts_idx].reserved_bytes_mb)),"######"))
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
      row + 2, col 0,
      CALL print(fillstring(60,"-")),
      row + 1, col 0,
      CALL print("Space Impact By Tablespace/Data File in Megabytes (MB)"),
      row + 1, col 0,
      CALL print(fillstring(60,"-")),
      row + 1, col 0,
      CALL print(
      " >> Review the 'Data File Space Needed MB' column for any tablespaces needing more space (data files)."
      ),
      row + 2, col 32,
      CALL print("   New"),
      col 43,
      CALL print("      New"), col 56,
      CALL print(" Data File"), col 68,
      CALL print("Min Data File"),
      row + 1, col 32,
      CALL print(" Index"),
      col 43,
      CALL print("    Index"), col 56,
      CALL print("Free Space"), col 68,
      CALL print(" Space Needed"),
      row + 1, col 0,
      CALL print("Tablespace Name"),
      col 32,
      CALL print(" Count"), col 43,
      CALL print("  Cost MB"), col 56,
      CALL print("        MB"),
      col 68,
      CALL print("           MB")
      IF ((luts_list->dg_cnt > 0))
       col 83,
       CALL print("Disk Group Name")
      ENDIF
      row + 1, col 0,
      CALL print(fillstring(30,"-")),
      col 32,
      CALL print(fillstring(6,"-")), col 43,
      CALL print(fillstring(9,"-")), col 56,
      CALL print(fillstring(10,"-")),
      col 68,
      CALL print(fillstring(13,"-"))
      IF ((luts_list->dg_cnt > 0))
       col 83,
       CALL print(fillstring(30,"-"))
      ENDIF
      FOR (dpluts_idx = 1 TO luts_list->tspace_cnt)
        IF ((luts_list->ts[dpluts_idx].assigned_bytes_mb > 0))
         row + 1, col 0,
         CALL print(luts_list->ts[dpluts_idx].tspace_name),
         col 32,
         CALL print(format(luts_list->ts[dpluts_idx].new_ind_cnt,"######")), col 43,
         CALL print(format(luts_list->ts[dpluts_idx].assigned_bytes_mb,"######.##")), col 60,
         CALL print(format((luts_list->ts[dpluts_idx].free_bytes_mb - luts_list->ts[dpluts_idx].
          reserved_bytes_mb),"######"))
         IF (((luts_list->ts[dpluts_idx].free_bytes_mb - luts_list->ts[dpluts_idx].reserved_bytes_mb)
          > luts_list->ts[dpluts_idx].assigned_bytes_mb))
          col 80,
          CALL print("0")
         ELSE
          col 72,
          CALL print(format((luts_list->ts[dpluts_idx].assigned_bytes_mb - (luts_list->ts[dpluts_idx]
           .free_bytes_mb - luts_list->ts[dpluts_idx].reserved_bytes_mb)),"######.##"))
         ENDIF
         IF ((luts_list->dg_cnt > 0))
          col 83,
          CALL print(luts_list->ts[dpluts_idx].dg_name)
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
    FOOT REPORT
     IF ((((luts_list->create_index_cnt > 0)) OR ((luts_list->create_txn_index_cnt > 0))) )
      row + 2, col 0,
      CALL print("************** End of Tablespace Report ***************")
     ELSE
      row + 2, col 0,
      CALL print("            There are 0 new Indexes, so there is no Tablespace Impact "),
      row + 2, col 0,
      CALL print("************** End of Tablespace Report ***************")
     ENDIF
    WITH nocounter, formfeed = none, format = variable,
     maxcol = 1000
   ;end select
  ENDIF
 ENDIF
 IF (check_error(dm_err->eproc))
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 GO TO exit_program
#exit_program
 SET dm_err->eproc = "Ending dm2_preview_luts"
 CALL final_disp_msg(dpluts_logfile_prefix)
END GO
