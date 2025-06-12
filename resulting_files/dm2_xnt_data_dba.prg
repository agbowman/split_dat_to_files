CREATE PROGRAM dm2_xnt_data:dba
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
 DECLARE dxd_parse_temp_semi_selection(i_semi_string=vc,io_ranges=vc(ref)) = i2
 DECLARE dxd_parse_temp_comma_selection(i_comma_string=vc,io_cranges=vc(ref)) = i2
 DECLARE dxd_parse_string(i_str=vc,io_tranges=vc(ref)) = i2
 DECLARE dxd_clean_info(null) = i2
 DECLARE dxd_job_log(i_status=vc,i_msg=vc,i_log_id=f8) = i2
 DECLARE dxd_get_minmax(i_tbl=vc,i_clm=vc,i_job=f8,io_min=f8(ref),io_max=f8(ref),
  io_flip_ind=i2(ref),io_tbl_max=f8(ref)) = i2
 IF (validate(request->batch_selection,"-1")="-1")
  FREE RECORD request
  RECORD request(
    1 batch_selection = vc
  )
  SET request->batch_selection =  $1
 ENDIF
 IF (validate(reply->status_data.status,"-1")="-1")
  FREE RECORD reply
  RECORD reply(
    1 ops_event = vc
    1 identifier = vc
    1 qual[*]
      2 version = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD m_tpl_data
 RECORD m_tpl_data(
   1 tpl_cnt = i4
   1 tpl_list[*]
     2 run_cnt = i4
     2 template_nbr = i4
     2 template_name = vc
     2 table_name = vc
     2 table_suffix = vc
     2 content_type = vc
     2 pk_col = vc
     2 job_cnt = i4
     2 job_list[*]
       3 job_id = f8
       3 token_cnt = i4
       3 token_list[*]
         4 token_str = vc
         4 token_val = vc
         4 token_type = vc
 ) WITH protect
 FREE RECORD m_ranges
 RECORD m_ranges(
   1 cnt = i4
   1 time = f8
   1 qual[*]
     2 low_val = i4
     2 high_val = i4
 ) WITH protect
 FREE RECORD m_job_special_tokens
 RECORD m_job_special_tokens(
   1 cnt = i4
   1 qual[*]
     2 token_str = vc
     2 token_type = vc
 ) WITH protect
 FREE RECORD m_dxdc_request
 RECORD m_dxdc_request(
   1 template_nbr = i4
   1 job_id = f8
   1 table_name = vc
   1 table_suffix = vc
   1 person_id = f8
   1 start_dt_tm = f8
   1 extract_dt_tm = f8
   1 ret_dt_tm = f8
   1 extract_age = i4
   1 extract_freq = i4
   1 timelock = f8
   1 extra_params = vc
   1 max_dt_tm = f8
   1 min_dt_tm = f8
   1 dm_xnt_job_log_dtl_id = f8
   1 dm_xnt_job_log_id = f8
   1 file_name = vc
   1 extract_crit = vc
   1 content_type = vc
   1 d_cnt = i4
   1 d_query[*]
     2 str = vc
 ) WITH protect
 FREE RECORD m_select_stmts
 RECORD m_select_stmts(
   1 cnt = i4
   1 qual[*]
     2 str = vc
 ) WITH protect
 FREE RECORD m_person
 RECORD m_person(
   1 cnt = i4
   1 qual[*]
     2 person_id = f8
 ) WITH protect
 FREE RECORD m_ord_sts
 RECORD m_ord_sts(
   1 cnt = i4
   1 qual[*]
     2 stat_cd = f8
 ) WITH protect
 DECLARE m_job_status_fail = vc WITH protect, constant("FAILED")
 DECLARE m_job_status_succ = vc WITH protect, constant("SUCCESS")
 DECLARE m_tpl_loop = i4 WITH protect, noconstant(0)
 DECLARE m_tpl_run_loop = i4 WITH protect, noconstant(0)
 DECLARE m_job_loop = i4 WITH protect, noconstant(0)
 DECLARE m_tok_loop = i4 WITH protect, noconstant(0)
 DECLARE m_per_loop = i4 WITH protect, noconstant(0)
 DECLARE m_parse_loop = i4 WITH protect, noconstant(0)
 DECLARE m_xd_idx = i4 WITH protect, noconstant(0)
 DECLARE m_xd_idx2 = i4 WITH protect, noconstant(0)
 DECLARE m_job_idx = i4 WITH protect, noconstant(0)
 DECLARE m_tok_idx = i4 WITH protect, noconstant(0)
 DECLARE m_op_col = i4 WITH protect, noconstant(0)
 DECLARE m_cl_col = i4 WITH protect, noconstant(0)
 DECLARE m_tok_str = vc WITH protect, noconstant(" ")
 DECLARE m_time_limit = f8 WITH protect, noconstant(0.0)
 DECLARE m_max_template_date = f8 WITH protect, noconstant(cnvtdatetime((curdate - 1000),0))
 DECLARE m_last_gen_dt = f8 WITH protect, noconstant(cnvtdatetime((curdate - 10000),0))
 DECLARE m_regen_plsql_ind = i2 WITH protect, noconstant(0)
 DECLARE m_limit_ea = i4 WITH protect, noconstant(365)
 DECLARE m_limit_ef = i4 WITH protect, noconstant(30)
 DECLARE m_limit_ef_max = i4 WITH protect, noconstant(365)
 DECLARE m_job_skip_ind = i2 WITH protect, noconstant(0)
 DECLARE m_job_skip_reason = vc WITH protect, noconstant(" ")
 DECLARE m_job_success_text = vc WITH protect, noconstant(" ")
 DECLARE m_dt_col = vc WITH protect, noconstant(" ")
 DECLARE m_driver_sel_add = vc WITH protect, noconstant(" ")
 DECLARE m_job_tper_cnt = i4 WITH protect, noconstant(0)
 DECLARE m_job_fper_cnt = i4 WITH protect, noconstant(0)
 DECLARE m_dmi_join_ind = i2 WITH protect, noconstant(0)
 DECLARE m_add_select = i4 WITH protect, noconstant(0)
 DECLARE m_sql_extra_stmt = vc WITH protect, noconstant(" ")
 DECLARE dxd_min = f8 WITH protect, noconstant(0.0)
 DECLARE dxd_max = f8 WITH protect, noconstant(0.0)
 DECLARE dxd_tbl_max = f8 WITH protect, noconstant(0.0)
 DECLARE dxd_while_ind = i2 WITH protect, noconstant(0)
 DECLARE dxd_flip_ind = i2 WITH protect, noconstant(0)
 DECLARE dxd_start_min = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 IF (check_logfile("dm2_xnt_data",".log","DM2_XNT_DATA LogFile...") != 1)
  SET dm_err->err_ind = 1
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_main
 ENDIF
 IF (checkprg("DM2_XNT_DM_XML_STORE")=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg =
  "There are scripts required by the XnT process that do not exist in the CCL Dictionary."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_main
 ENDIF
 EXECUTE dm2_set_context "FIRE_REFCHG_TRG", "NO"
 IF ((dm_err->err_ind=1))
  GO TO exit_main
 ENDIF
 IF (dxd_parse_string(request->batch_selection,m_ranges)=0)
  GO TO exit_main
 ENDIF
 SET m_time_limit = cnvtlookahead(concat(cnvtstring((m_ranges->time * 60)),",MIN"),cnvtdatetime(
   curdate,curtime3))
 CALL echo(format(sysdate,";;q"))
 CALL echo(format(m_time_limit,";;q"))
 SET dm_err->eproc = "Obtain active templates that will run"
 CALL disp_msg(" ",dm_err->logfile,0)
 IF ((m_ranges->cnt=0))
  SELECT DISTINCT INTO "nl:"
   dpt.template_nbr
   FROM dm_purge_template dpt
   WHERE cnvtupper(dpt.program_str)="XNT"
    AND dpt.active_ind=1
    AND (dpt.schema_dt_tm=
   (SELECT
    max(pt1.schema_dt_tm)
    FROM dm_purge_template pt1
    WHERE pt1.template_nbr=dpt.template_nbr))
   ORDER BY dpt.template_nbr
   HEAD REPORT
    m_tpl_data->tpl_cnt = 0
   DETAIL
    IF (cnvtdatetime(m_max_template_date) < dpt.schema_dt_tm)
     m_max_template_date = dpt.schema_dt_tm
    ENDIF
    m_tpl_data->tpl_cnt = (m_tpl_data->tpl_cnt+ 1), stat = alterlist(m_tpl_data->tpl_list,m_tpl_data
     ->tpl_cnt), m_tpl_data->tpl_list[m_tpl_data->tpl_cnt].template_nbr = dpt.template_nbr,
    m_tpl_data->tpl_list[m_tpl_data->tpl_cnt].template_name = dpt.name, m_tpl_data->tpl_list[
    m_tpl_data->tpl_cnt].run_cnt = 1
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   GO TO exit_main
  ENDIF
 ELSE
  SET m_tpl_data->tpl_cnt = 0
  FOR (m_tpl_loop = 1 TO m_ranges->cnt)
   SELECT DISTINCT INTO "nl:"
    dpt.template_nbr
    FROM dm_purge_template dpt
    WHERE cnvtupper(dpt.program_str)="XNT"
     AND dpt.active_ind=1
     AND (dpt.template_nbr >= m_ranges->qual[m_tpl_loop].low_val)
     AND (dpt.template_nbr <= m_ranges->qual[m_tpl_loop].high_val)
     AND (dpt.schema_dt_tm=
    (SELECT
     max(pt1.schema_dt_tm)
     FROM dm_purge_template pt1
     WHERE pt1.template_nbr=dpt.template_nbr))
    ORDER BY dpt.template_nbr
    DETAIL
     IF (cnvtdatetime(m_max_template_date) < dpt.schema_dt_tm)
      m_max_template_date = dpt.schema_dt_tm
     ENDIF
     m_xd_idx = 0
     IF ((m_tpl_data->tpl_cnt > 0))
      m_xd_idx = locateval(m_xd_idx2,1,m_tpl_data->tpl_cnt,dpt.template_nbr,m_tpl_data->tpl_list[
       m_xd_idx2].template_nbr)
     ENDIF
     IF (m_xd_idx=0)
      m_tpl_data->tpl_cnt = (m_tpl_data->tpl_cnt+ 1), stat = alterlist(m_tpl_data->tpl_list,
       m_tpl_data->tpl_cnt), m_tpl_data->tpl_list[m_tpl_data->tpl_cnt].template_nbr = dpt
      .template_nbr,
      m_tpl_data->tpl_list[m_tpl_data->tpl_cnt].template_name = dpt.name, m_tpl_data->tpl_list[
      m_tpl_data->tpl_cnt].run_cnt = 1
     ELSE
      m_tpl_data->tpl_list[m_xd_idx].run_cnt = (m_tpl_data->tpl_list[m_xd_idx].run_cnt+ 1)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    GO TO exit_main
   ENDIF
  ENDFOR
 ENDIF
 IF ((m_tpl_data->tpl_cnt=0))
  SET dm_err->eproc = "There were no active templates in the range provided"
  CALL disp_msg(" ",dm_err->logfile,0)
  SET reply->status_data.status = "S"
  GO TO exit_main
 ENDIF
 SET dm_err->eproc = "Obtain scheduled jobs and their parameters"
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM dm_purge_job dpj,
   dm_purge_job_token dpjt
  WHERE expand(m_xd_idx2,1,m_tpl_data->tpl_cnt,dpj.template_nbr,m_tpl_data->tpl_list[m_xd_idx2].
   template_nbr)
   AND dpj.active_flag=1
   AND dpjt.job_id=dpj.job_id
  ORDER BY dpj.job_id
  DETAIL
   m_xd_idx = locateval(m_xd_idx2,1,m_tpl_data->tpl_cnt,dpj.template_nbr,m_tpl_data->tpl_list[
    m_xd_idx2].template_nbr), m_job_idx = locateval(m_xd_idx2,1,m_tpl_data->tpl_list[m_xd_idx].
    job_cnt,dpj.job_id,m_tpl_data->tpl_list[m_xd_idx].job_list[m_xd_idx2].job_id)
   IF (m_job_idx=0)
    m_tpl_data->tpl_list[m_xd_idx].job_cnt = (m_tpl_data->tpl_list[m_xd_idx].job_cnt+ 1), m_job_idx
     = m_tpl_data->tpl_list[m_xd_idx].job_cnt, stat = alterlist(m_tpl_data->tpl_list[m_xd_idx].
     job_list,m_job_idx),
    m_tpl_data->tpl_list[m_xd_idx].job_list[m_job_idx].job_id = dpj.job_id
   ENDIF
   m_tok_idx = locateval(m_xd_idx2,1,m_tpl_data->tpl_list[m_xd_idx].job_list[m_job_idx].token_cnt,
    dpjt.token_str,m_tpl_data->tpl_list[m_xd_idx].job_list[m_job_idx].token_list[m_xd_idx2].token_str
    )
   IF (m_tok_idx=0)
    m_tpl_data->tpl_list[m_xd_idx].job_list[m_job_idx].token_cnt = (m_tpl_data->tpl_list[m_xd_idx].
    job_list[m_job_idx].token_cnt+ 1), m_tok_idx = m_tpl_data->tpl_list[m_xd_idx].job_list[m_job_idx]
    .token_cnt, stat = alterlist(m_tpl_data->tpl_list[m_xd_idx].job_list[m_job_idx].token_list,
     m_tok_idx),
    m_tpl_data->tpl_list[m_xd_idx].job_list[m_job_idx].token_list[m_tok_idx].token_str = dpjt
    .token_str, m_tpl_data->tpl_list[m_xd_idx].job_list[m_job_idx].token_list[m_tok_idx].token_val =
    dpjt.value
   ENDIF
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_main
 ENDIF
 IF (curqual=0)
  SET dm_err->eproc = "There were no scheduled jobs in the range provided"
  CALL disp_msg(" ",dm_err->logfile,0)
  SET reply->status_data.status = "S"
  GO TO exit_main
 ENDIF
 SET dm_err->eproc = "Obtaining the date when the PLSQL functions were last generated"
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
  di.info_date
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="XNT_PLSQL_GEN"
  DETAIL
   m_last_gen_dt = di.info_date
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_main
 ENDIF
 IF (cnvtdatetime(m_last_gen_dt) < cnvtdatetime(m_max_template_date))
  SET m_regen_plsql_ind = 1
 ENDIF
 IF (m_regen_plsql_ind=0)
  SET dm_err->eproc = "Check to see if metadata was updated after the PLSQL functions were created"
  CALL disp_msg(" ",dm_err->logfile,0)
  SELECT INTO "nl:"
   di.info_date
   FROM dm_info di
   WHERE di.info_domain="DATA MANAGEMENT"
    AND di.info_name="USERLASTUPDT"
    AND di.info_date >= cnvtdatetime(m_last_gen_dt)
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   GO TO exit_main
  ENDIF
  IF (curqual > 0)
   SET m_regen_plsql_ind = 1
  ENDIF
 ENDIF
 IF (m_regen_plsql_ind=1)
  EXECUTE dm2_xnt_plsql_gen
  IF ((dm_err->err_ind=1))
   GO TO exit_main
  ENDIF
 ENDIF
 SET dm_err->eproc = "Obtain top level table for each template"
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
  dpt.parent_table
  FROM dm_purge_table dpt
  WHERE expand(m_xd_idx2,1,m_tpl_data->tpl_cnt,dpt.template_nbr,m_tpl_data->tpl_list[m_xd_idx2].
   template_nbr)
   AND dpt.purge_type_flag=5
  DETAIL
   m_xd_idx = locateval(m_xd_idx2,1,m_tpl_data->tpl_cnt,dpt.template_nbr,m_tpl_data->tpl_list[
    m_xd_idx2].template_nbr), m_tpl_data->tpl_list[m_xd_idx].table_name = dpt.parent_table
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_main
 ENDIF
 SET dm_err->eproc = "Obtain table suffix for each template"
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE expand(m_xd_idx2,1,m_tpl_data->tpl_cnt,di.info_name,m_tpl_data->tpl_list[m_xd_idx2].
   table_name)
   AND di.info_domain="DM_TABLES_DOC_TABLE_SUFFIX"
  DETAIL
   m_xd_idx = locateval(m_xd_idx2,1,m_tpl_data->tpl_cnt,di.info_name,m_tpl_data->tpl_list[m_xd_idx2].
    table_name), m_tpl_data->tpl_list[m_xd_idx].table_suffix = di.info_char
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_main
 ENDIF
 FOR (m_xd_idx2 = 1 TO m_tpl_data->tpl_cnt)
   IF (size(trim(m_tpl_data->tpl_list[m_xd_idx2].table_suffix),1)=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Unable to obtain table_suffix for our driver tables"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    GO TO exit_main
   ENDIF
 ENDFOR
 SET dm_err->eproc = "Obtain min extract age and frequency"
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DM2XNT_DATA"
   AND di.info_name IN ("EXTRACT_AGE", "EXTRACT_FREQUENCY")
  DETAIL
   IF (di.info_name="EXTRACT_AGE")
    m_limit_ea = di.info_number
   ELSE
    m_limit_ef = di.info_number, m_limit_ef_max = cnvtint(di.info_char)
   ENDIF
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_main
 ENDIF
 SET dm_err->eproc = "Obtain content type"
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DM2XNT_CONTENT_TYPE"
   AND expand(m_xd_idx2,1,m_tpl_data->tpl_cnt,di.info_name,m_tpl_data->tpl_list[m_xd_idx2].table_name
   )
  DETAIL
   m_xd_idx = locateval(m_xd_idx2,1,m_tpl_data->tpl_cnt,di.info_name,m_tpl_data->tpl_list[m_xd_idx2].
    table_name), m_tpl_data->tpl_list[m_xd_idx].content_type = di.info_char
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_main
 ENDIF
 FOR (m_xd_idx2 = 1 TO m_tpl_data->tpl_cnt)
   IF (size(trim(m_tpl_data->tpl_list[m_xd_idx2].content_type),1)=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Missing content_types for XNT templates"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    GO TO exit_main
   ENDIF
 ENDFOR
 SET dm_err->eproc = "Obtain range columns"
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DM2XNT_ACT_RANGE_TABLE"
   AND expand(m_xd_idx2,1,m_tpl_data->tpl_cnt,di.info_name,m_tpl_data->tpl_list[m_xd_idx2].table_name
   )
  DETAIL
   m_xd_idx = locateval(m_xd_idx2,1,m_tpl_data->tpl_cnt,di.info_name,m_tpl_data->tpl_list[m_xd_idx2].
    table_name), m_tpl_data->tpl_list[m_xd_idx].pk_col = di.info_char
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_main
 ENDIF
 FOR (m_tpl_loop = 1 TO m_tpl_data->tpl_cnt)
   FOR (m_tpl_run_loop = 1 TO m_tpl_data->tpl_list[m_tpl_loop].run_cnt)
    CALL echo(m_tpl_data->tpl_list[m_tpl_loop].template_name)
    FOR (m_job_loop = 1 TO m_tpl_data->tpl_list[m_tpl_loop].job_cnt)
      IF (cnvtdatetime(curdate,curtime3) < cnvtdatetime(m_time_limit))
       CALL echo(m_tpl_data->tpl_list[m_tpl_loop].job_list[m_job_loop].job_id)
       SET dm_err->eproc = concat("Running template: ",m_tpl_data->tpl_list[m_tpl_loop].template_name,
        " job id : ",cnvtstring(m_tpl_data->tpl_list[m_tpl_loop].job_list[m_job_loop].job_id,20))
       CALL disp_msg(" ",dm_err->logfile,0)
       IF (dxd_clean_info(null)=0)
        GO TO exit_main
       ENDIF
       SET dxd_min = 0.0
       SET dxd_max = 0.0
       SET dxd_tbl_max = 0.0
       SET dxd_flip_ind = 0
       SET dxd_start_min = 0.0
       SET m_job_skip_ind = 0
       SET m_job_skip_reason = " "
       SET m_job_success_text = " "
       SET m_driver_sel_add = " "
       SET m_job_fper_cnt = 0
       SET m_job_tper_cnt = 0
       SET m_dxdc_request->job_id = m_tpl_data->tpl_list[m_tpl_loop].job_list[m_job_loop].job_id
       SET m_dxdc_request->template_nbr = m_tpl_data->tpl_list[m_tpl_loop].template_nbr
       SET m_dxdc_request->extra_params = ""
       SET m_dxdc_request->extract_crit = " "
       SET m_dxdc_request->timelock = cnvtdatetime(curdate,curtime3)
       SET m_dxdc_request->start_dt_tm = m_dxdc_request->timelock
       SET m_dxdc_request->content_type = m_tpl_data->tpl_list[m_tpl_loop].content_type
       SET m_dxdc_request->table_name = m_tpl_data->tpl_list[m_tpl_loop].table_name
       SET m_dxdc_request->table_suffix = m_tpl_data->tpl_list[m_tpl_loop].table_suffix
       SET m_dxdc_request->dm_xnt_job_log_id = 0
       SET m_dmi_join_ind = 0
       SET m_sql_extra_stmt = " "
       SET m_add_select = 0
       SET dm_err->eproc = concat("Logging tracking row for job - ",build(m_dxdc_request->job_id))
       CALL disp_msg(" ",dm_err->logfile,0)
       SELECT INTO "nl:"
        y = seq(dm_clinical_seq,nextval)
        FROM dual
        DETAIL
         m_dxdc_request->dm_xnt_job_log_id = y
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        GO TO exit_main
       ENDIF
       INSERT  FROM dm_xnt_job_log dxjl
        SET dxjl.dm_xnt_job_log_id = m_dxdc_request->dm_xnt_job_log_id, dxjl.job_id = m_dxdc_request
         ->job_id, dxjl.start_dt_tm = cnvtdatetime(curdate,curtime3),
         dxjl.status = "RUNNING", dxjl.audit_sid = currdbhandle, dxjl.updt_dt_tm = cnvtdatetime(
          curdate,curtime3),
         dxjl.updt_task = reqinfo->updt_task, dxjl.updt_id = reqinfo->updt_id, dxjl.updt_applctx =
         reqinfo->updt_applctx,
         dxjl.updt_cnt = 0
        WITH nocounter
       ;end insert
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        IF (findstring("20205",dm_err->emsg,1,0) > 0)
         SET dm_err->err_ind = 0
         SET dm_err->eproc = "Skipping job because it is being executed by another process"
         CALL disp_msg(" ",dm_err->logfile,0)
         SET m_job_skip_ind = 1
        ELSE
         GO TO exit_main
        ENDIF
       ELSE
        COMMIT
       ENDIF
       IF (m_job_skip_ind != 1)
        SET dm_err->eproc = concat("Obtain special tokens for job# ",build(m_dxdc_request->job_id))
        CALL disp_msg(" ",dm_err->logfile,0)
        SET m_job_special_tokens->cnt = 0
        SET stat = alterlist(m_job_special_tokens->qual,m_job_special_tokens->cnt)
        IF ((m_tpl_data->tpl_list[m_tpl_loop].job_list[m_job_loop].token_cnt > 4))
         SELECT INTO "nl:"
          FROM dm_purge_token dpt
          WHERE (dpt.template_nbr=m_tpl_data->tpl_list[m_tpl_loop].template_nbr)
           AND  NOT (dpt.token_str IN ("JOBNAME", "EXTRACT_NAME", "EXTRACT_AGE", "EXTRACT_FREQUENCY")
          )
           AND (dpt.schema_dt_tm=
          (SELECT
           max(p1.schema_dt_tm)
           FROM dm_purge_token p1
           WHERE (p1.template_nbr=m_tpl_data->tpl_list[m_tpl_loop].template_nbr)))
          ORDER BY dpt.token_str
          DETAIL
           m_job_special_tokens->cnt = (m_job_special_tokens->cnt+ 1), stat = alterlist(
            m_job_special_tokens->qual,m_job_special_tokens->cnt), m_job_special_tokens->qual[
           m_job_special_tokens->cnt].token_str = dpt.token_str
           IF (dpt.data_type_flag=1)
            m_job_special_tokens->qual[m_job_special_tokens->cnt].token_type = "NUMBER"
           ELSEIF (dpt.data_type_flag=3)
            m_job_special_tokens->qual[m_job_special_tokens->cnt].token_type = "STRING"
           ENDIF
          WITH nocounter
         ;end select
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
          GO TO exit_main
         ENDIF
        ENDIF
       ENDIF
       FOR (m_tok_loop = 1 TO m_tpl_data->tpl_list[m_tpl_loop].job_list[m_job_loop].token_cnt)
         IF (m_job_skip_ind != 1)
          IF ((m_tpl_data->tpl_list[m_tpl_loop].job_list[m_job_loop].token_list[m_tok_loop].token_str
          ="EXTRACT_AGE"))
           SET m_dxdc_request->extract_age = cnvtint(m_tpl_data->tpl_list[m_tpl_loop].job_list[
            m_job_loop].token_list[m_tok_loop].token_val)
           IF ((m_dxdc_request->extract_age < m_limit_ea))
            SET m_job_skip_ind = 1
            SET m_job_skip_reason = "Value entered for EXTRACT_AGE is below the minimum requirement"
           ENDIF
          ELSEIF ((m_tpl_data->tpl_list[m_tpl_loop].job_list[m_job_loop].token_list[m_tok_loop].
          token_str="EXTRACT_FREQUENCY"))
           SET m_dxdc_request->extract_freq = cnvtint(m_tpl_data->tpl_list[m_tpl_loop].job_list[
            m_job_loop].token_list[m_tok_loop].token_val)
           IF ((m_dxdc_request->extract_freq < m_limit_ef))
            SET m_job_skip_ind = 1
            SET m_job_skip_reason =
            "Value entered for EXTRACT_FREQUENCY is below the minimum requirement"
           ELSEIF ((m_dxdc_request->extract_freq > m_limit_ef_max))
            SET m_job_skip_ind = 1
            SET m_job_skip_reason =
            "Value entered for EXTRACT_FREQUENCY is above the maximum requirement"
           ENDIF
          ELSEIF ((m_tpl_data->tpl_list[m_tpl_loop].job_list[m_job_loop].token_list[m_tok_loop].
          token_str="EXTRACT_NAME"))
           SET m_dxdc_request->file_name = replace(cnvtupper(m_tpl_data->tpl_list[m_tpl_loop].
             job_list[m_job_loop].token_list[m_tok_loop].token_val),
            "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_ ","0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ__",3)
           IF (cnvtupper(m_tpl_data->tpl_list[m_tpl_loop].job_list[m_job_loop].token_list[m_tok_loop]
            .token_val) != replace(cnvtupper(m_tpl_data->tpl_list[m_tpl_loop].job_list[m_job_loop].
             token_list[m_tok_loop].token_val),"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_ ",
            "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_ ",3))
            SET m_job_skip_ind = 1
            SET m_job_skip_reason =
            "Value entered for EXTRACT_NAME contains characters that are not acceptable"
           ENDIF
          ELSEIF ((m_tpl_data->tpl_list[m_tpl_loop].job_list[m_job_loop].token_list[m_tok_loop].
          token_str="JOBNAME"))
           IF (cnvtupper(m_tpl_data->tpl_list[m_tpl_loop].job_list[m_job_loop].token_list[m_tok_loop]
            .token_val) != replace(cnvtupper(m_tpl_data->tpl_list[m_tpl_loop].job_list[m_job_loop].
             token_list[m_tok_loop].token_val),"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_ ",
            "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_ ",3))
            SET m_job_skip_ind = 1
            SET m_job_skip_reason =
            "Value entered for JOBNAME contains characters that are not acceptable"
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
       IF ((m_dxdc_request->table_name="ORDERS"))
        IF (m_job_skip_ind != 1)
         SET dm_err->eproc = "Obtain Values for ORDER_STATUS_CD"
         CALL disp_msg(" ",dm_err->logfile,0)
         INSERT  FROM dm_info di
          (di.info_number, di.info_domain, di.info_name,
          di.info_long_id)(SELECT DISTINCT
           cvg.child_code_value, "XNT_ORDER_STATUS_QUAL", concat("OSQ:",currdbhandle,":",trim(
             cnvtstring(cvg.child_code_value,20),3)),
           cnvtreal(currdbhandle)
           FROM code_value cv,
            code_value_group cvg
           WHERE cvg.parent_code_value=cv.code_value
            AND cv.code_set=4002374
            AND cv.active_ind=1)
          WITH nocounter
         ;end insert
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
          GO TO exit_main
         ELSE
          COMMIT
         ENDIF
         IF (curqual=0)
          SET m_job_skip_ind = 1
          SET m_job_skip_reason = "Could not obtain order_status_cd values"
         ENDIF
         SET dm_err->eproc = "Load Values for ORDER_STATUS_CD in RS"
         CALL disp_msg(" ",dm_err->logfile,0)
         SELECT INTO "nl:"
          FROM dm_info di
          WHERE di.info_domain="XNT_ORDER_STATUS_QUAL"
           AND di.info_long_id=cnvtreal(currdbhandle)
          HEAD REPORT
           m_ord_sts->cnt = 0
          DETAIL
           m_ord_sts->cnt = (m_ord_sts->cnt+ 1), stat = alterlist(m_ord_sts->qual,m_ord_sts->cnt),
           m_ord_sts->qual[m_ord_sts->cnt].stat_cd = di.info_number
          WITH nocounter
         ;end select
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
          GO TO exit_main
         ENDIF
        ENDIF
        SET m_dxdc_request->extra_params = concat(
         ",' and m.order_status_cd in (select di.info_number from dm_info di where ",
         "di.info_domain = ''XNT_ORDER_STATUS_QUAL'' and di.info_long_id = ",trim(currdbhandle),") '"
         )
       ENDIF
       IF ((m_job_special_tokens->cnt > 0))
        FOR (m_tok_loop = 1 TO m_job_special_tokens->cnt)
          IF (m_job_skip_ind != 1)
           SET m_tok_idx = locateval(m_xd_idx2,1,m_tpl_data->tpl_list[m_tpl_loop].job_list[m_job_loop
            ].token_cnt,m_job_special_tokens->qual[m_tok_loop].token_str,m_tpl_data->tpl_list[
            m_tpl_loop].job_list[m_job_loop].token_list[m_xd_idx2].token_str)
           SET m_tpl_data->tpl_list[m_tpl_loop].job_list[m_job_loop].token_list[m_tok_idx].token_type
            = m_job_special_tokens->qual[m_tok_loop].token_type
           IF ( NOT ((m_job_special_tokens->qual[m_tok_loop].token_str IN ("EVENT_SET_NAME",
           "XNT_CTLG_TYP_CD_DISPLAY_KEY", "XNT_CTLG_CD_DISPLAY_KEY", "XNT_ACT_TYP_CD_DISPLAY_KEY"))))
            SET m_dxdc_request->extract_crit = concat(m_dxdc_request->extract_crit,
             m_job_special_tokens->qual[m_tok_loop].token_str," - ",trim(m_tpl_data->tpl_list[
              m_tpl_loop].job_list[m_job_loop].token_list[m_tok_idx].token_val,3),"; ")
            IF ((m_tpl_data->tpl_list[m_tpl_loop].job_list[m_job_loop].token_list[m_tok_idx].
            token_type="STRING"))
             SET m_dxdc_request->extra_params = concat(trim(m_dxdc_request->extra_params),",'",
              replace(trim(m_tpl_data->tpl_list[m_tpl_loop].job_list[m_job_loop].token_list[m_tok_idx
                ].token_val),char(42),"%",0),"'")
            ELSEIF ((m_tpl_data->tpl_list[m_tpl_loop].job_list[m_job_loop].token_list[m_tok_idx].
            token_type="NUMBER"))
             SET m_dxdc_request->extra_params = concat(trim(m_dxdc_request->extra_params),",",trim(
               m_tpl_data->tpl_list[m_tpl_loop].job_list[m_job_loop].token_list[m_tok_idx].token_val)
              )
            ENDIF
           ELSE
            CASE (m_job_special_tokens->qual[m_tok_loop].token_str)
             OF "EVENT_SET_NAME":
              SET m_dxdc_request->extract_crit = concat(m_dxdc_request->extract_crit,
               " XNT Event Set Code Name - ",trim(m_tpl_data->tpl_list[m_tpl_loop].job_list[
                m_job_loop].token_list[m_tok_idx].token_val,3),"; ")
              SET dm_err->eproc = "Obtain Values for EVENT_SET_NAME"
              CALL disp_msg(" ",dm_err->logfile,0)
              INSERT  FROM dm_info di
               (di.info_number, di.info_domain, di.info_name,
               di.info_long_id)(SELECT DISTINCT
                ese.event_cd, "XNT_CE_EVENT_CD_QUAL", concat("CECQ:",currdbhandle,":",trim(cnvtstring
                  (ese.event_cd,20),3)),
                cnvtreal(currdbhandle)
                FROM v500_event_set_code esc,
                 v500_event_set_explode ese
                WHERE esc.event_set_name=trim(m_tpl_data->tpl_list[m_tpl_loop].job_list[m_job_loop].
                 token_list[m_tok_idx].token_val,3)
                 AND ese.event_set_cd=esc.event_set_cd)
               WITH nocounter
              ;end insert
              IF (check_error(dm_err->eproc)=1)
               CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
               GO TO exit_main
              ELSE
               COMMIT
              ENDIF
              IF (curqual=0)
               SET m_job_skip_ind = 1
               SET m_job_skip_reason = "Could not obtain event_cd values"
              ELSE
               SET m_dmi_join_ind = 1
               SET dm_err->eproc = "Obtain query for EVENT_SET_NAME"
               CALL disp_msg(" ",dm_err->logfile,0)
               SELECT INTO "nl:"
                FROM dm_info di
                WHERE di.info_domain="DM2XNT_EXTRA_QUAL"
                 AND (di.info_name=m_job_special_tokens->qual[m_tok_loop].token_str)
                DETAIL
                 m_dxdc_request->extra_params = concat(trim(m_dxdc_request->extra_params),",' ",trim(
                   replace(di.info_char,":AUDSID:",concat(trim(currdbhandle),".0"),0)),"'")
                WITH nocounter
               ;end select
               IF (check_error(dm_err->eproc)=1)
                CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
                GO TO exit_main
               ENDIF
               IF (curqual=0)
                SET m_job_skip_ind = 1
                SET m_job_skip_reason = "Could not obtain EVENT_SET_NAME query"
               ENDIF
              ENDIF
             OF "XNT_CTLG_TYP_CD_DISPLAY_KEY":
              SET m_dxdc_request->extract_crit = concat(m_dxdc_request->extract_crit,
               " XNT Catalog Type Code Display Key - ",trim(m_tpl_data->tpl_list[m_tpl_loop].
                job_list[m_job_loop].token_list[m_tok_idx].token_val,3),"; ")
              IF (cnvtupper(trim(m_tpl_data->tpl_list[m_tpl_loop].job_list[m_job_loop].token_list[
                m_tok_idx].token_val,3)) != "ALL")
               SET dm_err->eproc = "Obtain Values for XNT_CTLG_TYP_CD_DISPLAY_KEY"
               CALL disp_msg(" ",dm_err->logfile,0)
               INSERT  FROM dm_info di
                (di.info_number, di.info_domain, di.info_name,
                di.info_long_id)(SELECT DISTINCT
                 cvg.child_code_value, "XNT_ORDER_CATALOG_TYPE_CD_QUAL", concat("OCTCQ:",currdbhandle,
                  ":",trim(cnvtstring(cvg.child_code_value,20),3)),
                 cnvtreal(currdbhandle)
                 FROM code_value cv,
                  code_value_group cvg
                 WHERE cvg.parent_code_value=cv.code_value
                  AND cv.code_set=4002373
                  AND cv.display_key=trim(m_tpl_data->tpl_list[m_tpl_loop].job_list[m_job_loop].
                  token_list[m_tok_idx].token_val,3)
                  AND cv.active_ind=1)
                WITH nocounter
               ;end insert
               IF (check_error(dm_err->eproc)=1)
                CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
                GO TO exit_main
               ELSE
                COMMIT
               ENDIF
               IF (curqual=0)
                SET m_job_skip_ind = 1
                SET m_job_skip_reason = "Could not obtain catalog_type_cd values"
               ELSE
                SET m_dmi_join_ind = 1
                SET dm_err->eproc = "Obtain query for XNT_CTLG_TYP_CD_DISPLAY_KEY"
                CALL disp_msg(" ",dm_err->logfile,0)
                SELECT INTO "nl:"
                 FROM dm_info di
                 WHERE di.info_domain="DM2XNT_EXTRA_QUAL*"
                  AND (di.info_name=m_job_special_tokens->qual[m_tok_loop].token_str)
                 DETAIL
                  IF (((m_add_select=0) OR (m_add_select=3)) )
                   m_add_select = 3
                   IF (di.info_domain="DM2XNT_EXTRA_QUAL_D")
                    m_driver_sel_add = concat(" ",trim(replace(trim(replace(di.info_char,":AUDSID:",
                         concat(trim(currdbhandle),".0"),0)),"''","'",0)))
                   ELSE
                    m_sql_extra_stmt = concat(",' ",trim(replace(di.info_char,":AUDSID:",concat(trim(
                         currdbhandle),".0"),0)),"'")
                   ENDIF
                  ENDIF
                 WITH nocounter
                ;end select
                IF (check_error(dm_err->eproc)=1)
                 CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
                 GO TO exit_main
                ENDIF
                IF (curqual=0)
                 SET m_job_skip_ind = 1
                 SET m_job_skip_reason = "Could not obtain XNT_CTLG_TYP_CD_DISPLAY_KEY query"
                ENDIF
               ENDIF
              ENDIF
             OF "XNT_CTLG_CD_DISPLAY_KEY":
              SET m_dxdc_request->extract_crit = concat(m_dxdc_request->extract_crit,
               " XNT Catalog Code Display Key - ",trim(m_tpl_data->tpl_list[m_tpl_loop].job_list[
                m_job_loop].token_list[m_tok_idx].token_val,3),"; ")
              IF (cnvtupper(trim(m_tpl_data->tpl_list[m_tpl_loop].job_list[m_job_loop].token_list[
                m_tok_idx].token_val,3)) != "ALL")
               SET dm_err->eproc = "Obtain Values for XNT_CTLG_CD_DISPLAY_KEY"
               CALL disp_msg(" ",dm_err->logfile,0)
               INSERT  FROM dm_info di
                (di.info_number, di.info_domain, di.info_name,
                di.info_long_id)(SELECT DISTINCT
                 cvg.child_code_value, "XNT_ORDER_CATALOG_CD_QUAL", concat("OCCQ:",currdbhandle,":",
                  trim(cnvtstring(cvg.child_code_value,20),3)),
                 cnvtreal(currdbhandle)
                 FROM code_value cv,
                  code_value_group cvg
                 WHERE cvg.parent_code_value=cv.code_value
                  AND cv.code_set=4002389
                  AND cv.display_key=trim(m_tpl_data->tpl_list[m_tpl_loop].job_list[m_job_loop].
                  token_list[m_tok_idx].token_val,3)
                  AND cv.active_ind=1)
                WITH nocounter
               ;end insert
               IF (check_error(dm_err->eproc)=1)
                CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
                GO TO exit_main
               ELSE
                COMMIT
               ENDIF
               IF (curqual=0)
                SET m_job_skip_ind = 1
                SET m_job_skip_reason = "Could not obtain catalog_cd values"
               ELSE
                SET m_dmi_join_ind = 1
                SET dm_err->eproc = "Obtain query for XNT_CTLG_CD_DISPLAY_KEY"
                CALL disp_msg(" ",dm_err->logfile,0)
                SELECT INTO "nl:"
                 FROM dm_info di
                 WHERE di.info_domain="DM2XNT_EXTRA_QUAL*"
                  AND (di.info_name=m_job_special_tokens->qual[m_tok_loop].token_str)
                 DETAIL
                  m_add_select = 1
                  IF (di.info_domain="DM2XNT_EXTRA_QUAL_D")
                   m_driver_sel_add = concat(" ",trim(replace(trim(replace(di.info_char,":AUDSID:",
                        concat(trim(currdbhandle),".0"),0)),"''","'",0)))
                  ELSE
                   m_sql_extra_stmt = concat(",' ",trim(replace(di.info_char,":AUDSID:",concat(trim(
                        currdbhandle),".0"),0)),"'")
                  ENDIF
                 WITH nocounter
                ;end select
                IF (check_error(dm_err->eproc)=1)
                 CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
                 GO TO exit_main
                ENDIF
                IF (curqual=0)
                 SET m_job_skip_ind = 1
                 SET m_job_skip_reason = "Could not obtain XNT_CTLG_CD_DISPLAY_KEY query"
                ENDIF
               ENDIF
              ENDIF
             OF "XNT_ACT_TYP_CD_DISPLAY_KEY":
              SET m_dxdc_request->extract_crit = concat(m_dxdc_request->extract_crit,
               " XNT Activity Type Code Display Key - ",trim(m_tpl_data->tpl_list[m_tpl_loop].
                job_list[m_job_loop].token_list[m_tok_idx].token_val,3),"; ")
              IF (cnvtupper(trim(m_tpl_data->tpl_list[m_tpl_loop].job_list[m_job_loop].token_list[
                m_tok_idx].token_val,3)) != "ALL")
               SET dm_err->eproc = "Obtain Values for XNT_ACT_TYP_CD_DISPLAY_KEY"
               CALL disp_msg(" ",dm_err->logfile,0)
               INSERT  FROM dm_info di
                (di.info_number, di.info_domain, di.info_name,
                di.info_long_id)(SELECT DISTINCT
                 cvg.child_code_value, "XNT_ORDER_ACTIVITY_TYPE_CD_QUAL", concat("OATCQ:",
                  currdbhandle,":",trim(cnvtstring(cvg.child_code_value,20),3)),
                 cnvtreal(currdbhandle)
                 FROM code_value cv,
                  code_value_group cvg
                 WHERE cvg.parent_code_value=cv.code_value
                  AND cv.code_set=4002388
                  AND cv.display_key=trim(m_tpl_data->tpl_list[m_tpl_loop].job_list[m_job_loop].
                  token_list[m_tok_idx].token_val,3)
                  AND cv.active_ind=1)
                WITH nocounter
               ;end insert
               IF (check_error(dm_err->eproc)=1)
                CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
                GO TO exit_main
               ELSE
                COMMIT
               ENDIF
               IF (curqual=0)
                SET m_job_skip_ind = 1
                SET m_job_skip_reason = "Could not obtain activity_type_cd values"
               ELSE
                SET m_dmi_join_ind = 1
                SET dm_err->eproc = "Obtain query for XNT_ACT_TYP_CD_DISPLAY_KEY"
                CALL disp_msg(" ",dm_err->logfile,0)
                SELECT INTO "nl:"
                 FROM dm_info di
                 WHERE di.info_domain="DM2XNT_EXTRA_QUAL*"
                  AND (di.info_name=m_job_special_tokens->qual[m_tok_loop].token_str)
                 DETAIL
                  IF (m_add_select != 1)
                   m_add_select = 2
                   IF (di.info_domain="DM2XNT_EXTRA_QUAL_D")
                    m_driver_sel_add = concat(" ",trim(replace(trim(replace(di.info_char,":AUDSID:",
                         concat(trim(currdbhandle),".0"),0)),"''","'",0)))
                   ELSE
                    m_sql_extra_stmt = concat(",' ",trim(replace(di.info_char,":AUDSID:",concat(trim(
                         currdbhandle),".0"),0)),"'")
                   ENDIF
                  ENDIF
                 WITH nocounter
                ;end select
                IF (check_error(dm_err->eproc)=1)
                 CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
                 GO TO exit_main
                ENDIF
                IF (curqual=0)
                 SET m_job_skip_ind = 1
                 SET m_job_skip_reason = "Could not obtain XNT_ACT_TYP_CD_DISPLAY_KEY query"
                ENDIF
               ENDIF
              ENDIF
            ENDCASE
           ENDIF
          ENDIF
        ENDFOR
       ENDIF
       IF ((m_dxdc_request->table_name="ORDERS")
        AND size(trim(m_sql_extra_stmt))=0)
        SET m_sql_extra_stmt = ",' '"
       ENDIF
       SET m_dxdc_request->extra_params = concat(m_dxdc_request->extra_params,m_sql_extra_stmt)
       IF (size(trim(m_dxdc_request->extract_crit),1) > 0)
        SET m_dxdc_request->extract_crit = substring(1,(size(trim(m_dxdc_request->extract_crit,3),1)
          - 1),trim(m_dxdc_request->extract_crit,3))
       ENDIF
       SET m_dxdc_request->extract_dt_tm = cnvtlookbehind(concat(trim(cnvtstring((m_dxdc_request->
           extract_age+ m_dxdc_request->extract_freq))),",D"),m_dxdc_request->timelock)
       SET m_dxdc_request->ret_dt_tm = cnvtlookbehind(concat(trim(cnvtstring(m_dxdc_request->
           extract_age)),",D"),m_dxdc_request->timelock)
       IF (m_job_skip_ind != 1)
        SET dm_err->eproc = "Obtain date column used for query"
        CALL disp_msg(" ",dm_err->logfile,0)
        SELECT INTO "nl:"
         FROM dm_info di
         WHERE di.info_domain="DM2XNT_DATE_COL"
          AND (di.info_name=m_dxdc_request->table_name)
         DETAIL
          m_dt_col = trim(di.info_char,3)
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
         GO TO exit_main
        ENDIF
        IF (curqual=0)
         SET m_dt_col = "updt_dt_tm"
        ENDIF
       ENDIF
       SET dxd_while_ind = 1
       WHILE (dxd_while_ind=1)
         IF (((size(m_tpl_data->tpl_list[m_tpl_loop].pk_col)=0) OR (m_job_skip_ind=1)) )
          SET dxd_while_ind = 0
         ELSEIF (m_job_skip_ind != 1)
          IF (dxd_get_minmax(m_dxdc_request->table_name,m_tpl_data->tpl_list[m_tpl_loop].pk_col,
           m_dxdc_request->job_id,dxd_min,dxd_max,
           dxd_flip_ind,dxd_tbl_max)=0)
           GO TO exit_main
          ENDIF
          IF ((dm_err->debug_flag > 1))
           CALL echo(dxd_start_min)
           CALL echo(dxd_min)
           CALL echo(dxd_max)
           CALL echo(dxd_tbl_max)
           CALL echo(dxd_flip_ind)
          ENDIF
          IF (dxd_start_min=0)
           SET dxd_start_min = dxd_min
          ENDIF
          IF (dxd_start_min=0)
           SET dxd_while_ind = 0
           SET dxd_min = 0
           SET dxd_max = 0
          ELSEIF (dxd_flip_ind > 0
           AND dxd_start_min <= dxd_min)
           SET dxd_while_ind = 0
           SET dxd_min = 0
           SET dxd_max = 0
          ENDIF
         ENDIF
         IF (m_job_skip_ind != 1)
          SET dm_err->eproc = concat("Construct select statements to obtain person_ids for job# ",
           build(m_dxdc_request->job_id))
          CALL disp_msg(" ",dm_err->logfile,0)
          SET m_select_stmts->cnt = 0
          SET stat = alterlist(m_select_stmts->qual,m_select_stmts->cnt)
          SELECT INTO "nl:"
           FROM dm_info di
           WHERE di.info_domain="DM2XNT_DRIVER_SELECT"
            AND (di.info_name=m_dxdc_request->table_name)
           HEAD REPORT
            m_dxdc_request->d_cnt = 1, m_select_stmts->cnt = 1, stat = alterlist(m_select_stmts->qual,
             m_select_stmts->cnt),
            stat = alterlist(m_dxdc_request->d_query,m_dxdc_request->d_cnt), m_select_stmts->qual[
            m_select_stmts->cnt].str = " select distinct into 'nl:' m.person_id ", m_dxdc_request->
            d_query[m_dxdc_request->d_cnt].str = concat(" select into 'nl:' y = max(m.",m_dt_col,
             "), x=min(m.",m_dt_col,") ")
           DETAIL
            m_dxdc_request->d_cnt = (m_dxdc_request->d_cnt+ 1), m_select_stmts->cnt = (m_select_stmts
            ->cnt+ 1), stat = alterlist(m_select_stmts->qual,m_select_stmts->cnt),
            stat = alterlist(m_dxdc_request->d_query,m_dxdc_request->d_cnt), m_select_stmts->qual[
            m_select_stmts->cnt].str = replace(replace(replace(di.info_char,":EXTRACT_DT_TM:",concat(
                "cnvtdatetime(",trim(build(m_dxdc_request->extract_dt_tm)),")"),0),":AUDSID:",concat(
               trim(currdbhandle),".0"),0),":DM_INFO:",evaluate(m_dmi_join_ind,1,", dm_info di "," "),
             0), m_dxdc_request->d_query[m_dxdc_request->d_cnt].str = replace(replace(replace(di
               .info_char,":EXTRACT_DT_TM:",concat("cnvtdatetime(",trim(build(m_dxdc_request->
                  ret_dt_tm)),")"),0),":AUDSID:",concat(trim(currdbhandle),".0"),0),":DM_INFO:",
             evaluate(m_dmi_join_ind,1,", dm_info di "," "),0),
            m_op_col = findstring(":",m_select_stmts->qual[m_select_stmts->cnt].str,1,0)
            IF (m_op_col > 0)
             m_cl_col = findstring(":",m_select_stmts->qual[m_select_stmts->cnt].str,(m_op_col+ 1),0),
             m_tok_str = substring((m_op_col+ 1),((m_cl_col - m_op_col) - 1),m_select_stmts->qual[
              m_select_stmts->cnt].str), m_tok_idx = locateval(m_xd_idx2,1,m_tpl_data->tpl_list[
              m_tpl_loop].job_list[m_job_loop].token_cnt,m_tok_str,m_tpl_data->tpl_list[m_tpl_loop].
              job_list[m_job_loop].token_list[m_xd_idx2].token_str)
             IF (m_tok_idx > 0)
              IF ((m_tpl_data->tpl_list[m_tpl_loop].job_list[m_job_loop].token_list[m_xd_idx2].
              token_type="STRING"))
               m_select_stmts->qual[m_select_stmts->cnt].str = replace(m_select_stmts->qual[
                m_select_stmts->cnt].str,concat(":",trim(m_tpl_data->tpl_list[m_tpl_loop].job_list[
                  m_job_loop].token_list[m_xd_idx2].token_str),":"),concat("'",trim(m_tpl_data->
                  tpl_list[m_tpl_loop].job_list[m_job_loop].token_list[m_xd_idx2].token_val),"'"),0)
              ELSEIF ((m_tpl_data->tpl_list[m_tpl_loop].job_list[m_job_loop].token_list[m_xd_idx2].
              token_type="NUMBER"))
               m_select_stmts->qual[m_select_stmts->cnt].str = replace(m_select_stmts->qual[
                m_select_stmts->cnt].str,concat(":",trim(m_tpl_data->tpl_list[m_tpl_loop].job_list[
                  m_job_loop].token_list[m_xd_idx2].token_str),":"),trim(m_tpl_data->tpl_list[
                 m_tpl_loop].job_list[m_job_loop].token_list[m_xd_idx2].token_val),0)
              ENDIF
             ENDIF
            ENDIF
            m_op_col = findstring(":",m_dxdc_request->d_query[m_dxdc_request->d_cnt].str,1,0)
            IF (m_op_col > 0)
             m_cl_col = findstring(":",m_dxdc_request->d_query[m_dxdc_request->d_cnt].str,(m_op_col+
              1),0), m_tok_str = substring((m_op_col+ 1),((m_cl_col - m_op_col) - 1),m_dxdc_request->
              d_query[m_dxdc_request->d_cnt].str), m_tok_idx = locateval(m_xd_idx2,1,m_tpl_data->
              tpl_list[m_tpl_loop].job_list[m_job_loop].token_cnt,m_tok_str,m_tpl_data->tpl_list[
              m_tpl_loop].job_list[m_job_loop].token_list[m_xd_idx2].token_str)
             IF (m_tok_idx > 0)
              IF ((m_tpl_data->tpl_list[m_tpl_loop].job_list[m_job_loop].token_list[m_xd_idx2].
              token_type="STRING"))
               m_dxdc_request->d_query[m_dxdc_request->d_cnt].str = replace(m_dxdc_request->d_query[
                m_dxdc_request->d_cnt].str,concat(":",trim(m_tpl_data->tpl_list[m_tpl_loop].job_list[
                  m_job_loop].token_list[m_xd_idx2].token_str),":"),concat("'",trim(m_tpl_data->
                  tpl_list[m_tpl_loop].job_list[m_job_loop].token_list[m_xd_idx2].token_val),"'"),0)
              ELSEIF ((m_tpl_data->tpl_list[m_tpl_loop].job_list[m_job_loop].token_list[m_xd_idx2].
              token_type="NUMBER"))
               m_dxdc_request->d_query[m_dxdc_request->d_cnt].str = replace(m_dxdc_request->d_query[
                m_dxdc_request->d_cnt].str,concat(":",trim(m_tpl_data->tpl_list[m_tpl_loop].job_list[
                  m_job_loop].token_list[m_xd_idx2].token_str),":"),trim(m_tpl_data->tpl_list[
                 m_tpl_loop].job_list[m_job_loop].token_list[m_xd_idx2].token_val),0)
              ENDIF
             ENDIF
            ENDIF
           FOOT REPORT
            IF (size(trim(m_driver_sel_add)) > 0)
             m_dxdc_request->d_cnt = (m_dxdc_request->d_cnt+ 1), stat = alterlist(m_dxdc_request->
              d_query,m_dxdc_request->d_cnt), m_dxdc_request->d_query[m_dxdc_request->d_cnt].str =
             m_driver_sel_add
            ENDIF
            m_dxdc_request->d_cnt = (m_dxdc_request->d_cnt+ 1), stat = alterlist(m_dxdc_request->
             d_query,m_dxdc_request->d_cnt), m_dxdc_request->d_query[m_dxdc_request->d_cnt].str =
            " and m.person_id = :PERSON_ID: ",
            m_dxdc_request->d_cnt = (m_dxdc_request->d_cnt+ 1), stat = alterlist(m_dxdc_request->
             d_query,m_dxdc_request->d_cnt), m_dxdc_request->d_query[m_dxdc_request->d_cnt].str =
            " detail ",
            m_dxdc_request->d_cnt = (m_dxdc_request->d_cnt+ 1), stat = alterlist(m_dxdc_request->
             d_query,m_dxdc_request->d_cnt), m_dxdc_request->d_query[m_dxdc_request->d_cnt].str =
            " m_dxdc_request->max_dt_tm = y ",
            m_dxdc_request->d_cnt = (m_dxdc_request->d_cnt+ 1), stat = alterlist(m_dxdc_request->
             d_query,m_dxdc_request->d_cnt), m_dxdc_request->d_query[m_dxdc_request->d_cnt].str =
            " m_dxdc_request->min_dt_tm = x ",
            m_dxdc_request->d_cnt = (m_dxdc_request->d_cnt+ 1), stat = alterlist(m_dxdc_request->
             d_query,m_dxdc_request->d_cnt), m_dxdc_request->d_query[m_dxdc_request->d_cnt].str =
            " with nocounter go "
            IF (size(trim(m_driver_sel_add)) > 0)
             m_select_stmts->cnt = (m_select_stmts->cnt+ 1), stat = alterlist(m_select_stmts->qual,
              m_select_stmts->cnt), m_select_stmts->qual[m_select_stmts->cnt].str = m_driver_sel_add
            ENDIF
            IF (size(m_tpl_data->tpl_list[m_tpl_loop].pk_col) > 0)
             m_select_stmts->cnt = (m_select_stmts->cnt+ 1), stat = alterlist(m_select_stmts->qual,
              m_select_stmts->cnt), m_select_stmts->qual[m_select_stmts->cnt].str = concat(" and m.",
              trim(m_tpl_data->tpl_list[m_tpl_loop].pk_col)," >= ",trim(cnvtstring(dxd_min,20)),
              ".0 and m.",
              trim(m_tpl_data->tpl_list[m_tpl_loop].pk_col),"<",trim(cnvtstring(dxd_max,20)),".0")
            ENDIF
            m_select_stmts->cnt = (m_select_stmts->cnt+ 1), stat = alterlist(m_select_stmts->qual,
             m_select_stmts->cnt), m_select_stmts->qual[m_select_stmts->cnt].str = " head report ",
            m_select_stmts->cnt = (m_select_stmts->cnt+ 1), stat = alterlist(m_select_stmts->qual,
             m_select_stmts->cnt), m_select_stmts->qual[m_select_stmts->cnt].str =
            "   m_person->cnt = 0",
            m_select_stmts->cnt = (m_select_stmts->cnt+ 1), stat = alterlist(m_select_stmts->qual,
             m_select_stmts->cnt), m_select_stmts->qual[m_select_stmts->cnt].str = " detail ",
            m_select_stmts->cnt = (m_select_stmts->cnt+ 1), stat = alterlist(m_select_stmts->qual,
             m_select_stmts->cnt), m_select_stmts->qual[m_select_stmts->cnt].str =
            "   m_person->cnt = m_person->cnt + 1 ",
            m_select_stmts->cnt = (m_select_stmts->cnt+ 1), stat = alterlist(m_select_stmts->qual,
             m_select_stmts->cnt), m_select_stmts->qual[m_select_stmts->cnt].str =
            "   if (mod(m_person->cnt, 100) = 1) ",
            m_select_stmts->cnt = (m_select_stmts->cnt+ 1), stat = alterlist(m_select_stmts->qual,
             m_select_stmts->cnt), m_select_stmts->qual[m_select_stmts->cnt].str =
            "     stat = alterlist(m_person->qual, m_person->cnt+99) ",
            m_select_stmts->cnt = (m_select_stmts->cnt+ 1), stat = alterlist(m_select_stmts->qual,
             m_select_stmts->cnt), m_select_stmts->qual[m_select_stmts->cnt].str = "   endif ",
            m_select_stmts->cnt = (m_select_stmts->cnt+ 1), stat = alterlist(m_select_stmts->qual,
             m_select_stmts->cnt), m_select_stmts->qual[m_select_stmts->cnt].str =
            "   m_person->qual[m_person->cnt].person_id = m.person_id ",
            m_select_stmts->cnt = (m_select_stmts->cnt+ 1), stat = alterlist(m_select_stmts->qual,
             m_select_stmts->cnt), m_select_stmts->qual[m_select_stmts->cnt].str = " foot report ",
            m_select_stmts->cnt = (m_select_stmts->cnt+ 1), stat = alterlist(m_select_stmts->qual,
             m_select_stmts->cnt), m_select_stmts->qual[m_select_stmts->cnt].str =
            " stat = alterlist(m_person->qual,m_person->cnt) ",
            m_select_stmts->cnt = (m_select_stmts->cnt+ 1), stat = alterlist(m_select_stmts->qual,
             m_select_stmts->cnt)
            IF ((m_dxdc_request->table_name IN ("ORDERS", "CLINICAL_EVENT")))
             m_select_stmts->qual[m_select_stmts->cnt].str =
             " with orahint('ORDERED'),orahintcbo('ORDERED'), nocounter go "
            ELSE
             m_select_stmts->qual[m_select_stmts->cnt].str = " with nocounter go "
            ENDIF
           WITH nocounter
          ;end select
          IF (check_error(dm_err->eproc)=1)
           CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
           GO TO exit_main
          ENDIF
          IF (curqual=0)
           SET m_job_skip_ind = 1
           SET m_job_skip_reason = "Could not obtain Driver Select"
          ENDIF
         ENDIF
         IF (m_job_skip_ind != 1)
          SET m_person->cnt = 0
          SET stat = alterlist(m_person->qual,0)
          EXECUTE dm2_xnt_xml_parser  WITH replace("DXXP_REQUEST","M_SELECT_STMTS")
          IF (check_error(dm_err->eproc)=1)
           CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
           GO TO exit_main
          ENDIF
          IF ((dm_err->debug_flag > 1))
           CALL echorecord(m_dxdc_request)
           CALL echorecord(m_person)
          ENDIF
          FOR (m_per_loop = 1 TO m_person->cnt)
            IF (cnvtdatetime(curdate,curtime3) < cnvtdatetime(m_time_limit))
             CALL echo(concat("WORKING ON PERSON ",cnvtstring(m_per_loop)," out of ",cnvtstring(
                m_person->cnt)))
             SET m_dxdc_request->person_id = m_person->qual[m_per_loop].person_id
             SET m_job_tper_cnt = (m_job_tper_cnt+ 1)
             EXECUTE dm2_xnt_data_child  WITH replace("REQUEST","M_DXDC_REQUEST")
             IF ((dm_err->err_ind=1))
              ROLLBACK
              IF (((findstring("COUNT MISMATCH",cnvtupper(dm_err->emsg),1,0) > 0) OR (((findstring(
               "20204",dm_err->emsg,1,0) > 0) OR (((findstring("has been processed",dm_err->emsg,1,0)
               > 0) OR (findstring("was recently retrieved",dm_err->emsg,1,0) > 0)) )) )) )
               SET dm_err->err_ind = 0
               IF (findstring("COUNT MISMATCH",cnvtupper(dm_err->emsg),1,0) > 0)
                SET m_job_fper_cnt = (m_job_fper_cnt+ 1)
               ENDIF
               SET dm_err->emsg = " "
               CALL echo("ERROR IGNORED, MOVING ONTO NEXT PERSON")
              ELSE
               SET m_job_fper_cnt = (m_job_fper_cnt+ 1)
               SET dm_err->emsg = concat("Job Failed: ",dm_err->emsg," (",trim(cnvtstring(
                  m_job_tper_cnt),3)," persons processed with ",
                trim(cnvtstring(m_job_fper_cnt),3)," person failures)")
               GO TO exit_main
              ENDIF
             ENDIF
            ELSE
             SET m_job_success_text = concat("Job completed upon timeout (",trim(cnvtstring(
                m_job_tper_cnt),3)," persons processed with ",trim(cnvtstring(m_job_fper_cnt),3),
              " person failures)")
             SET m_per_loop = (m_person->cnt+ 1)
             SET dxd_while_ind = 0
            ENDIF
          ENDFOR
          IF (cnvtdatetime(m_time_limit) < cnvtdatetime(curdate,curtime3))
           SET dxd_while_ind = 0
           IF (size(trim(m_job_success_text))=0)
            SET m_job_success_text = concat("Job completed upon timeout (",trim(cnvtstring(
               m_job_tper_cnt),3)," persons processed with ",trim(cnvtstring(m_job_fper_cnt),3),
             " person failures)")
           ENDIF
          ENDIF
         ENDIF
       ENDWHILE
       IF (size(trim(m_job_success_text))=0)
        IF (m_job_tper_cnt=0)
         SET m_job_success_text = "Job completed (no persons qualified)"
        ELSE
         SET m_job_success_text = concat("Job completed (",trim(cnvtstring(m_job_tper_cnt),3),
          " persons processed with ",trim(cnvtstring(m_job_fper_cnt),3)," person failures)")
        ENDIF
       ENDIF
       IF (m_job_skip_ind=1
        AND size(trim(m_job_skip_reason,3)) > 0)
        IF (dxd_job_log(m_job_status_fail,m_job_skip_reason,m_dxdc_request->dm_xnt_job_log_id)=0)
         GO TO exit_main
        ENDIF
       ELSE
        IF (dxd_job_log(m_job_status_succ,m_job_success_text,m_dxdc_request->dm_xnt_job_log_id)=0)
         GO TO exit_main
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
   ENDFOR
 ENDFOR
 SET reply->status_data.status = "S"
 GO TO exit_main
 SUBROUTINE dxd_parse_string(i_str,io_tranges)
   DECLARE s_str = vc
   DECLARE s_pipe_pos = i4
   DECLARE s_time_str = vc
   SET s_str = trim(i_str,3)
   IF (size(s_str,1)=0)
    SET dm_err->emsg = "Batch selection was incorrectly defined. Please consult the help file."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET s_pipe_pos = findstring("|",s_str,1,0)
   IF (s_pipe_pos=0)
    SET dm_err->emsg = "Time limit is not defined. Please consult the help file."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ELSE
    SET s_time_str = substring(1,(s_pipe_pos - 1),s_str)
    SET s_str = substring((s_pipe_pos+ 1),(size(s_str,1) - s_pipe_pos),s_str)
    IF (isnumeric(s_time_str) > 0)
     SET io_tranges->time = cnvtreal(s_time_str)
     IF ((io_tranges->time < 1.0))
      SET dm_err->emsg = "Time value needs to be at least 1 hour"
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
    ELSE
     SET dm_err->emsg = "Time value is incorrectly defined"
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Time limit is ",trim(cnvtstring(io_tranges->time))," hours")
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dxd_parse_temp_semi_selection(s_str,io_tranges)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dxd_parse_temp_semi_selection(i_semi_string,io_ranges)
   DECLARE s_semi_found = i4 WITH protect, noconstant(0)
   DECLARE s_prev_semi_found = i4 WITH protect, noconstant(1)
   DECLARE s_temp_str = vc WITH protect, noconstant(" ")
   SET dm_err->eproc = "Parsing out the template selection passed in"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (size(trim(i_semi_string),1)=0)
    SET dm_err->eproc = "All active XNT templates will be executed"
    CALL disp_msg(" ",dm_err->logfile,0)
   ELSE
    SET s_semi_found = findstring(";",i_semi_string)
    IF (s_semi_found > 0)
     WHILE (s_prev_semi_found != 0)
       IF (s_semi_found=0)
        SET s_temp_str = substring(s_prev_semi_found,((size(i_semi_string) - s_prev_semi_found)+ 1),
         i_semi_string)
       ELSE
        SET s_temp_str = substring(s_prev_semi_found,(s_semi_found - s_prev_semi_found),i_semi_string
         )
       ENDIF
       IF (dxd_parse_temp_comma_selection(s_temp_str,io_ranges)=0)
        RETURN(0)
       ENDIF
       IF (s_semi_found=0)
        SET s_prev_semi_found = s_semi_found
       ELSE
        SET s_prev_semi_found = (s_semi_found+ 1)
        SET s_semi_found = findstring(";",i_semi_string,s_prev_semi_found)
       ENDIF
     ENDWHILE
    ELSE
     IF (dxd_parse_temp_comma_selection(i_semi_string,io_ranges)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dxd_parse_temp_comma_selection(i_comma_string,io_cranges)
   DECLARE s_com_found = i4 WITH protect, noconstant(0)
   SET s_com_found = findstring(",",i_comma_string)
   IF (s_com_found=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg =
    "Request->batch_selection is in an incorrect format. Please consult the help file."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ELSE
    SET io_cranges->cnt = (io_cranges->cnt+ 1)
    SET stat = alterlist(io_cranges->qual,io_cranges->cnt)
    SET io_cranges->qual[io_cranges->cnt].low_val = cnvtint(substring(1,(s_com_found - 1),
      i_comma_string))
    SET io_cranges->qual[io_cranges->cnt].high_val = cnvtint(substring((s_com_found+ 1),(size(
       i_comma_string) - s_com_found),i_comma_string))
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dxd_clean_info(null)
   SET dm_err->eproc = "Cleaning dm_info rows inserted by old jobs"
   CALL disp_msg(" ",dm_err->logfile,0)
   DELETE  FROM dm_info di
    WHERE di.info_domain IN ("XNT_ORDER_STATUS_QUAL", "XNT_ORDER_CATALOG_TYPE_CD_QUAL",
    "XNT_ORDER_ACTIVITY_TYPE_CD_QUAL", "XNT_ORDER_CATALOG_CD_QUAL", "XNT_CE_EVENT_CD_QUAL")
     AND ((di.info_long_id=cnvtreal(currdbhandle)) OR ( NOT (di.info_long_id IN (
    (SELECT
     vs.audsid
     FROM v$session vs)))
     AND  NOT (di.info_long_id IN (
    (SELECT
     gvs.audsid
     FROM gv$session gvs)))))
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Cleaning dm_xnt_job_log_dtl rows inserted by old jobs"
   CALL disp_msg(" ",dm_err->logfile,0)
   UPDATE  FROM dm_xnt_job_log_dtl dxjd
    SET dxjd.extract_status = "FAILED", dxjd.error_msg =
     "Job set to failed due to session no longer being active."
    WHERE dxjd.extract_status="RUNNING"
     AND  NOT (cnvtreal(dxjd.audit_sid) IN (
    (SELECT
     vs.audsid
     FROM v$session vs)))
     AND  NOT (cnvtreal(dxjd.audit_sid) IN (
    (SELECT
     gvs.audsid
     FROM gv$session gvs)))
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Cleaning dm_xnt_job_log rows inserted by old jobs"
   CALL disp_msg(" ",dm_err->logfile,0)
   UPDATE  FROM dm_xnt_job_log dxjl
    SET dxjl.status = "FAILED", dxjl.error_msg =
     "Job set to failed due to session no longer being active."
    WHERE dxjl.status="RUNNING"
     AND  NOT (cnvtreal(dxjl.audit_sid) IN (
    (SELECT
     vs.audsid
     FROM v$session vs)))
     AND  NOT (cnvtreal(dxjl.audit_sid) IN (
    (SELECT
     gvs.audsid
     FROM gv$session gvs)))
     AND dxjl.dm_xnt_job_log_id != 0
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dxd_job_log(i_status,i_msg,i_log_id)
   SET dm_err->eproc = "Logging status for current job"
   CALL disp_msg(" ",dm_err->logfile,0)
   UPDATE  FROM dm_xnt_job_log dxjl
    SET dxjl.status = i_status, dxjl.error_msg = substring(1,1000,i_msg), dxjl.end_dt_tm =
     cnvtdatetime(curdate,curtime3),
     dxjl.updt_dt_tm = cnvtdatetime(curdate,curtime3), dxjl.updt_task = reqinfo->updt_task, dxjl
     .updt_id = reqinfo->updt_id,
     dxjl.updt_applctx = reqinfo->updt_applctx, dxjl.updt_cnt = (dxjl.updt_cnt+ 1)
    WHERE dxjl.dm_xnt_job_log_id=i_log_id
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dxd_get_minmax(i_tbl,i_clm,i_job,io_min,io_max,io_flip_ind,io_tbl_max)
   DECLARE dgm_rng_val = f8 WITH protect, noconstant(100000.0)
   DECLARE dgm_get_new_ind = i2 WITH protect, noconstant(0)
   FREE RECORD dgm_stmt
   RECORD dgm_stmt(
     1 cnt = i4
     1 qual[*]
       2 str = vc
   ) WITH protect
   SET dm_err->eproc = concat("Obtain range value")
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_XNT_RANGE"
     AND di.info_name="CONTROL_VAL"
    DETAIL
     dgm_rng_val = di.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (io_tbl_max > 0)
    IF (io_max <= io_tbl_max)
     SET io_min = io_max
     SET io_max = (io_max+ dgm_rng_val)
    ELSE
     SET io_flip_ind = (io_flip_ind+ 1)
     SET dgm_get_new_ind = 1
    ENDIF
   ELSE
    SET dm_err->eproc = concat("Obtain previous min/max on the table")
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="XNT_JOB_RANGES"
      AND di.info_name=concat(trim(i_tbl),trim(cnvtstring(i_job,20)))
     DETAIL
      io_min = di.info_number, io_max = (di.info_number+ dgm_rng_val), io_tbl_max = di.info_long_id
      IF (io_min > io_tbl_max)
       dgm_get_new_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET dgm_get_new_ind = 1
    ENDIF
   ENDIF
   IF (dgm_get_new_ind=1)
    SET dm_err->eproc = concat("Update the min/max on the table")
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dgm_stmt->cnt = 6
    SET stat = alterlist(dgm_stmt->qual,dgm_stmt->cnt)
    SET dgm_stmt->qual[1].str = concat("select into 'nl:' y = min(d.",trim(i_clm),") ")
    SET dgm_stmt->qual[2].str = concat(" from ",trim(i_tbl)," d ")
    SET dgm_stmt->qual[3].str = concat(" where d.",trim(i_clm)," > 0.0 ")
    SET dgm_stmt->qual[4].str = "detail"
    SET dgm_stmt->qual[5].str = "  io_min = y "
    SET dgm_stmt->qual[6].str = "with nocounter go "
    EXECUTE dm2_xnt_xml_parser  WITH replace("DXXP_REQUEST","DGM_STMT")
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET dgm_stmt->qual[1].str = concat("select into 'nl:' y = max(d.",trim(i_clm),") ")
    SET dgm_stmt->qual[5].str = "  io_tbl_max = y "
    EXECUTE dm2_xnt_xml_parser  WITH replace("DXXP_REQUEST","DGM_STMT")
    SET io_max = (io_min+ dgm_rng_val)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Update the range we will use")
   CALL disp_msg(" ",dm_err->logfile,0)
   UPDATE  FROM dm_info di
    SET di.info_number = io_max, di.info_long_id = io_tbl_max
    WHERE di.info_domain="XNT_JOB_RANGES"
     AND di.info_name=concat(trim(i_tbl),trim(cnvtstring(i_job,20)))
    WITH nocounter
   ;end update
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_domain = "XNT_JOB_RANGES", di.info_name = concat(trim(i_tbl),trim(cnvtstring(i_job,
         20))), di.info_number = io_max,
      di.info_long_id = io_tbl_max
     WITH nocounter
    ;end insert
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    ROLLBACK
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
#exit_main
 IF ((reply->status_data.status="F"))
  SET reply->ops_event = dm_err->emsg
  ROLLBACK
  IF ((m_dxdc_request->dm_xnt_job_log_id > 0))
   SET dm_err->err_ind = 0
   IF (dxd_job_log(m_job_status_fail,dm_err->emsg,m_dxdc_request->dm_xnt_job_log_id)=0)
    ROLLBACK
   ENDIF
  ENDIF
 ENDIF
 IF ((dm_err->debug_flag > 1))
  CALL echorecord(request)
  CALL echorecord(reply)
 ENDIF
 EXECUTE dm2_set_context "FIRE_REFCHG_TRG", "NO"
 SET dm_err->eproc = "Dm2_xnt_data finished"
 CALL final_disp_msg("dm2_xnt_data")
END GO
