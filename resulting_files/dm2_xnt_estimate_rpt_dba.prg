CREATE PROGRAM dm2_xnt_estimate_rpt:dba
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
 DECLARE dxer_clean_info(null) = i2
 DECLARE s_dxr_validate = i2 WITH protect, noconstant(0)
 DECLARE s_dxr_par_loop = i4 WITH protect, noconstant(0)
 DECLARE s_op_col = i4 WITH protect, noconstant(0)
 DECLARE s_cl_col = i4 WITH protect, noconstant(0)
 DECLARE s_tok_str = vc WITH protect, noconstant(" ")
 DECLARE s_tok_idx = i4 WITH protect, noconstant(0)
 DECLARE s_dxr_idx = i4 WITH protect, noconstant(0)
 DECLARE s_dxr_tdx = i4 WITH protect, noconstant(0)
 DECLARE s_dxr_idx2 = i4 WITH protect, noconstant(0)
 DECLARE s_dxr_loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE s_dxr_tdx2 = i4 WITH protect, noconstant(0)
 DECLARE s_dxr_pdx = i4 WITH protect, noconstant(0)
 DECLARE s_dxr_cdx = i4 WITH protect, noconstant(0)
 DECLARE s_dxr_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE s_dxr_ext_tot = f8 WITH protect, noconstant(0.0)
 DECLARE s_dxr_spc_tot = f8 WITH protect, noconstant(0.0)
 DECLARE s_dxr_row_temp = f8 WITH protect, noconstant(0.0)
 DECLARE s_dxr_tbl_loop = i4 WITH protect, noconstant(0)
 DECLARE s_dxr_eo_loop1 = i4 WITH protect, noconstant(0)
 DECLARE s_dxr_eo_loop2 = i4 WITH protect, noconstant(0)
 DECLARE s_dxr_found_ind = i2 WITH protect, noconstant(0)
 DECLARE s_dxr_text = vc WITH protect, noconstant(" ")
 DECLARE s_dxr_text2 = vc WITH protect, noconstant(" ")
 DECLARE s_dxr_max_q_size = i4 WITH protect, noconstant(0)
 DECLARE m_env_name = vc WITH protect, noconstant(" ")
 DECLARE m_env_id = f8 WITH protect, noconstant(0.0)
 DECLARE s_dxr_orders_extra = vc WITH protect, noconstant(" ")
 DECLARE m_dmi_join_ind = i2 WITH protect, noconstant(0)
 DECLARE m_xd_idx = i4 WITH protect, noconstant(0)
 DECLARE m_dxr_rng_loop = i4 WITH protect, noconstant(1)
 DECLARE m_use_rng_ind = i2 WITH protect, noconstant(0)
 DECLARE m_dxr_rng_loop_start = i4 WITH protect, noconstant(0)
 IF (check_logfile("dm2_xnt_est_rpt",".log","DM2_XNT_EST_RPT LogFile...") != 1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Obtaining domain information"
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name IN ("DM_ENV_ID", "DM_ENV_NAME")
  DETAIL
   IF (di.info_name="DM_ENV_ID")
    m_env_id = di.info_number
   ELSE
    m_env_name = di.info_char
   ENDIF
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 IF (((m_env_id=0) OR (size(trim(m_env_name))=0)) )
  SET message = nowindow
  SET dm_err->err_ind = 1
  CALL disp_msg("Fatal Error: current environment information not found ",dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 WHILE (s_dxr_validate=0)
   FREE RECORD s_dxr_edata
   RECORD s_dxr_edata(
     1 template_nbr = i4
     1 template_name = vc
     1 table_name = vc
     1 ext_rows = f8
     1 ext_age = i4
     1 per_age = i4
     1 tok_cnt = i4
     1 tok_list[*]
       2 q_str = vc
       2 answ = vc
       2 token = vc
       2 type = i4
       2 min = i4
       2 max = i4
     1 ext_cnt = i4
     1 ext_stmt[*]
       2 ext_str = vc
     1 pair_cnt = i4
     1 pair_list[*]
       2 par_tbl = vc
       2 chld_tbl = vc
   ) WITH protect
   FREE RECORD s_dxr_tbl
   RECORD s_dxr_tbl(
     1 tbl_cnt = i4
     1 tbl_list[*]
       2 table_name = vc
       2 table_rows = f8
       2 total_space = f8
       2 ext_rows = f8
       2 ext_space = f8
   ) WITH protect
   FREE RECORD s_dxr_tbl_order1
   RECORD s_dxr_tbl_order1(
     1 tbl_cnt = i4
     1 tbl_list[*]
       2 table_name = vc
       2 table_rows = f8
       2 total_space = f8
       2 ext_rows = f8
       2 ext_space = f8
   ) WITH protect
   FREE RECORD s_dxr_tbl_order2
   RECORD s_dxr_tbl_order2(
     1 tbl_cnt = i4
     1 tbl_list[*]
       2 table_name = vc
       2 table_rows = f8
       2 total_space = f8
       2 ext_rows = f8
       2 ext_space = f8
   ) WITH protect
   FREE RECORD s_dxr_alternate
   RECORD s_dxr_alternate(
     1 cnt_odd = i4
     1 list_odd[*]
       2 t_name = vc
     1 cnt_even = i4
     1 list_even[*]
       2 t_name = vc
   )
   FREE RECORD m_ord_sts
   RECORD m_ord_sts(
     1 cnt = i4
     1 qual[*]
       2 stat_cd = f8
   ) WITH protect
   FREE RECORD tbl_ranges
   RECORD tbl_ranges(
     1 cnt = i4
     1 dt_gathered = i4
     1 cur_rng = i4
     1 clm_name = vc
     1 qual[*]
       2 low_val = f8
       2 high_val = f8
   ) WITH protect
   FREE RECORD dxer_request
   RECORD dxer_request(
     1 cnt = i4
     1 qual[*]
       2 str = vc
   ) WITH protect
   SET m_use_rng_ind = 0
   SET m_dxr_rng_loop = 1
   SET message = window
   CALL clear(1,1)
   SET width = 132
   CALL box(1,1,7,132)
   CALL text(3,40,"***  EXTRACT TEMPLATE ESTIMATED RESULTS REPORT  ***")
   CALL text(6,75,"ENVIRONMENT ID:")
   CALL text(6,20,"ENVIRONMENT NAME:")
   CALL text(6,95,cnvtstring(m_env_id))
   CALL text(6,40,trim(m_env_name))
   CALL clear(9,1)
   CALL text(9,3,"Please input template number (0 to Exit): ")
   CALL text(23,05,"HELP: Press <SHIFT><F5>     ")
   SET help =
   SELECT DISTINCT INTO "nl:"
    dpt.template_nbr, dpt.name
    FROM dm_purge_template dpt
    WHERE cnvtupper(trim(dpt.program_str,3))="XNT"
     AND dpt.active_ind=1
     AND (dpt.schema_dt_tm=
    (SELECT
     max(pt1.schema_dt_tm)
     FROM dm_purge_template pt1
     WHERE pt1.template_nbr=dpt.template_nbr))
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET message = nowindow
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    GO TO exit_program
   ENDIF
   CALL accept(9,70,"N(12);CU","0"
    WHERE cnvtreal(curaccept) >= 0)
   IF (curaccept="0")
    GO TO exit_program
   ENDIF
   SET dm_err->eproc = "Validate template number input"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_purge_template dpt
    WHERE dpt.template_nbr=cnvtint(curaccept)
     AND cnvtupper(trim(dpt.program_str,3))="XNT"
     AND dpt.active_ind=1
     AND (dpt.schema_dt_tm=
    (SELECT
     max(pt1.schema_dt_tm)
     FROM dm_purge_template pt1
     WHERE pt1.template_nbr=dpt.template_nbr))
    DETAIL
     s_dxr_edata->template_name = dpt.name, s_dxr_edata->template_nbr = dpt.template_nbr
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET message = nowindow
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    GO TO exit_program
   ENDIF
   IF (curqual > 0)
    SET help = off
    SET message = nowindow
    IF (dxer_clean_info(null)=0)
     GO TO exit_program
    ENDIF
    SET dm_err->eproc = "Obtain list of tables for chosen template"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_purge_table dpt
     WHERE (dpt.template_nbr=s_dxr_edata->template_nbr)
      AND dpt.parent_table != dpt.child_table
      AND (dpt.schema_dt_tm=
     (SELECT
      max(pt1.schema_dt_tm)
      FROM dm_purge_table pt1
      WHERE (pt1.template_nbr=s_dxr_edata->template_nbr)))
     HEAD REPORT
      s_dxr_edata->pair_cnt = 0
     DETAIL
      IF (dpt.purge_type_flag=5)
       s_dxr_edata->table_name = trim(dpt.parent_table,3)
      ELSE
       s_dxr_edata->pair_cnt = (s_dxr_edata->pair_cnt+ 1), stat = alterlist(s_dxr_edata->pair_list,
        s_dxr_edata->pair_cnt), s_dxr_edata->pair_list[s_dxr_edata->pair_cnt].par_tbl = trim(dpt
        .parent_table,3),
       s_dxr_edata->pair_list[s_dxr_edata->pair_cnt].chld_tbl = trim(dpt.child_table,3), s_dxr_tdx =
       locateval(s_dxr_idx,1,s_dxr_tbl->tbl_cnt,trim(dpt.parent_table,3),s_dxr_tbl->tbl_list[
        s_dxr_idx].table_name)
       IF (s_dxr_tdx=0)
        s_dxr_tbl->tbl_cnt = (s_dxr_tbl->tbl_cnt+ 1), stat = alterlist(s_dxr_tbl->tbl_list,s_dxr_tbl
         ->tbl_cnt), s_dxr_tbl->tbl_list[s_dxr_tbl->tbl_cnt].table_name = trim(dpt.parent_table,3)
       ENDIF
       s_dxr_tdx = locateval(s_dxr_idx,1,s_dxr_tbl->tbl_cnt,trim(dpt.child_table,3),s_dxr_tbl->
        tbl_list[s_dxr_idx].table_name)
       IF (s_dxr_tdx=0)
        s_dxr_tbl->tbl_cnt = (s_dxr_tbl->tbl_cnt+ 1), stat = alterlist(s_dxr_tbl->tbl_list,s_dxr_tbl
         ->tbl_cnt), s_dxr_tbl->tbl_list[s_dxr_tbl->tbl_cnt].table_name = trim(dpt.child_table,3)
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET message = nowindow
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     GO TO exit_program
    ENDIF
    SET dm_err->eproc = "Check if table uses range processing"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DM2XNT_EST_RANGE_TABLE"
      AND (di.info_name=s_dxr_edata->table_name)
     DETAIL
      tbl_ranges->clm_name = di.info_char
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET message = nowindow
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     GO TO exit_program
    ENDIF
    IF (curqual > 0)
     SET m_use_rng_ind = 1
     SET dm_err->eproc = "Obtain range values"
     CALL disp_msg(" ",dm_err->logfile,0)
     SELECT INTO "nl:"
      di.info_number
      FROM dm_info di
      WHERE di.info_domain="DM2_CLINICAL_RANGES_XNT"
       AND di.info_name=patstring(concat("V500.",trim(s_dxr_edata->table_name),"*"))
      ORDER BY di.info_number
      HEAD REPORT
       tbl_ranges->cnt = 0
      DETAIL
       tbl_ranges->dt_gathered = datetimediff(sysdate,di.updt_dt_tm,1), tbl_ranges->cur_rng = di
       .info_long_id
       IF ((tbl_ranges->cnt=0))
        tbl_ranges->cnt = (tbl_ranges->cnt+ 1)
       ELSEIF ((tbl_ranges->qual[tbl_ranges->cnt].high_val != di.info_number))
        tbl_ranges->cnt = (tbl_ranges->cnt+ 1)
       ENDIF
       stat = alterlist(tbl_ranges->qual,tbl_ranges->cnt), tbl_ranges->qual[tbl_ranges->cnt].low_val
        = di.info_number, tbl_ranges->qual[tbl_ranges->cnt].high_val = di.info_number
       IF ((tbl_ranges->cnt > 1))
        tbl_ranges->qual[(tbl_ranges->cnt - 1)].high_val = di.info_number
       ENDIF
      FOOT REPORT
       tbl_ranges->qual[tbl_ranges->cnt].high_val = (tbl_ranges->qual[tbl_ranges->cnt].high_val+ 1)
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      SET message = nowindow
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      GO TO exit_program
     ENDIF
     IF (curqual=0)
      SET m_use_rng_ind = 0
      SET message = window
      CALL clear(1,1)
      SET width = 132
      CALL box(1,1,7,132)
      CALL text(3,40,"***  EXTRACT AND TRANSFORM ESTIMATES REPORTING  ***")
      CALL text(6,75,"ENVIRONMENT ID:")
      CALL text(6,20,"ENVIRONMENT NAME:")
      CALL text(6,95,cnvtstring(m_env_id))
      CALL text(6,40,trim(m_env_name))
      SET s_dxr_text = concat("Template : ",trim(s_dxr_edata->template_name))
      CALL text(8,3,s_dxr_text)
      CALL text(11,3,"The driver table for template selected has been marked to process in ranges")
      CALL text(13,3,
       "    Ranges not found. These ranges should be generated for the table before continuing.")
      CALL text(15,3,
       "Ranges can be generated by setting up a routine task or manually executing dm2_xnt_get_clinical_ranges"
       )
      CALL text(24,3,"Enter C to Continue without using ranges or Q to Quit: ")
      CALL accept(24,57,"A;CU"," "
       WHERE curaccept IN ("C", "Q"))
      IF (curaccept="Q")
       GO TO exit_program
      ENDIF
      SET message = nowindow
     ENDIF
    ENDIF
    SET dm_err->eproc = "Obtain template token information"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_purge_token dpt
     WHERE (dpt.template_nbr=s_dxr_edata->template_nbr)
      AND (dpt.schema_dt_tm=
     (SELECT
      max(p1.schema_dt_tm)
      FROM dm_purge_token p1
      WHERE (p1.template_nbr=s_dxr_edata->template_nbr)))
     ORDER BY dpt.prompt_str
     HEAD REPORT
      s_dxr_edata->tok_cnt = 0
     DETAIL
      IF ( NOT (trim(dpt.token_str,3) IN ("JOBNAME", "EXTRACT_NAME")))
       s_dxr_edata->tok_cnt = (s_dxr_edata->tok_cnt+ 1), stat = alterlist(s_dxr_edata->tok_list,
        s_dxr_edata->tok_cnt), s_dxr_edata->tok_list[s_dxr_edata->tok_cnt].token = trim(dpt.token_str,
        3)
       IF (size(trim(dpt.prompt_str,3),1) > 132)
        s_dxr_edata->tok_list[s_dxr_edata->tok_cnt].q_str = substring(1,findstring(".",trim(dpt
           .prompt_str,3),1,0),trim(dpt.prompt_str))
       ELSE
        s_dxr_edata->tok_list[s_dxr_edata->tok_cnt].q_str = trim(dpt.prompt_str,3)
       ENDIF
       IF (size(s_dxr_edata->tok_list[s_dxr_edata->tok_cnt].q_str,1) > s_dxr_max_q_size)
        s_dxr_max_q_size = size(s_dxr_edata->tok_list[s_dxr_edata->tok_cnt].q_str,1)
       ENDIF
       s_dxr_edata->tok_list[s_dxr_edata->tok_cnt].type = dpt.data_type_flag
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET message = nowindow
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     GO TO exit_program
    ENDIF
    SET dm_err->eproc = "Obtain min and max token values"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DM2XNT_DATA"
      AND expand(s_dxr_idx,1,s_dxr_edata->tok_cnt,trim(di.info_name,3),s_dxr_edata->tok_list[
      s_dxr_idx].token)
     HEAD REPORT
      s_dxr_idx = 0, s_tok_idx = 0
     DETAIL
      s_tok_idx = locateval(s_dxr_idx,1,s_dxr_edata->tok_cnt,di.info_name,s_dxr_edata->tok_list[
       s_dxr_idx].token)
      IF (s_tok_idx > 0)
       IF (di.info_name="EXTRACT_AGE")
        s_dxr_edata->tok_list[s_tok_idx].min = 1
       ELSE
        s_dxr_edata->tok_list[s_tok_idx].min = cnvtint(di.info_number)
       ENDIF
      ENDIF
      IF (di.info_name="EXTRACT_FREQUENCY")
       s_dxr_edata->tok_list[s_tok_idx].max = cnvtint(di.info_char)
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET message = nowindow
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     GO TO exit_program
    ENDIF
    SET message = window
    CALL clear(1,1)
    SET width = 132
    CALL box(1,1,7,132)
    CALL text(3,40,"***  EXTRACT TEMPLATE ESTIMATED RESULTS REPORT  ***")
    CALL text(6,75,"ENVIRONMENT ID:")
    CALL text(6,20,"ENVIRONMENT NAME:")
    CALL text(6,95,cnvtstring(m_env_id))
    CALL text(6,40,trim(m_env_name))
    SET s_dxr_text = concat("Template : ",trim(s_dxr_edata->template_name))
    CALL text(8,3,s_dxr_text)
    FOR (s_dxr_par_loop = 1 TO s_dxr_edata->tok_cnt)
      SET s_dxr_validate = 0
      WHILE (s_dxr_validate=0)
        CALL clear((9+ s_dxr_par_loop),1)
        SET s_dxr_text = s_dxr_edata->tok_list[s_dxr_par_loop].q_str
        IF (size(s_dxr_text,1) > 132)
         CALL text((9+ s_dxr_par_loop),3,substring(1,132,s_dxr_text))
        ELSE
         CALL text((9+ s_dxr_par_loop),3,s_dxr_text)
        ENDIF
        IF ((s_dxr_edata->tok_list[s_dxr_par_loop].min > 0)
         AND (s_dxr_edata->tok_list[s_dxr_par_loop].token != "EXTRACT_AGE"))
         IF ((s_dxr_edata->tok_list[s_dxr_par_loop].max > 0))
          SET s_dxr_text2 = concat("Minimum value accepted : ",trim(cnvtstring(s_dxr_edata->tok_list[
             s_dxr_par_loop].min))," - Maximum value accepted : ",trim(cnvtstring(s_dxr_edata->
             tok_list[s_dxr_par_loop].max)))
         ELSE
          SET s_dxr_text2 = concat("Minimum value accepted : ",trim(cnvtstring(s_dxr_edata->tok_list[
             s_dxr_par_loop].min)))
         ENDIF
         CALL clear(24,1)
         CALL text(24,3,s_dxr_text2)
        ENDIF
        IF ((s_dxr_edata->tok_list[s_dxr_par_loop].token IN ("EXTRACT_AGE", "EXTRACT_FREQUENCY")))
         CALL accept((9+ s_dxr_par_loop),(s_dxr_max_q_size+ 5),"X(5);CU"," "
          WHERE cnvtint(curaccept) > 0)
        ELSE
         SET accept = nopatcheck
         CALL accept((9+ s_dxr_par_loop),(s_dxr_max_q_size+ 5),"P(50);C"," "
          WHERE trim(curaccept) > " ")
        ENDIF
        IF ((s_dxr_edata->tok_list[s_dxr_par_loop].type=1))
         IF (isnumeric(curaccept) > 0)
          IF ((cnvtint(curaccept) >= s_dxr_edata->tok_list[s_dxr_par_loop].min))
           IF ((cnvtint(curaccept) >= s_dxr_edata->tok_list[s_dxr_par_loop].max)
            AND (s_dxr_edata->tok_list[s_dxr_par_loop].max != 0))
            CALL clear(24,1)
            CALL text(24,3,"Value is above the Maximum value accepted. Press <Enter> to Continue")
            CALL accept(24,74,"p;cuh"," ")
           ELSE
            SET s_dxr_edata->tok_list[s_dxr_par_loop].answ = trim(curaccept,3)
            SET s_dxr_validate = 1
            IF ((s_dxr_edata->tok_list[s_dxr_par_loop].token IN ("EXTRACT_AGE", "EXTRACT_FREQUENCY"))
            )
             IF ((s_dxr_edata->tok_list[s_dxr_par_loop].token="EXTRACT_AGE"))
              SET s_dxr_edata->ext_age = cnvtint(s_dxr_edata->tok_list[s_dxr_par_loop].answ)
             ENDIF
             SET s_dxr_edata->per_age = (s_dxr_edata->per_age+ cnvtint(s_dxr_edata->tok_list[
              s_dxr_par_loop].answ))
            ENDIF
           ENDIF
          ELSE
           CALL clear(24,1)
           CALL text(24,3,"Value is below the Minimum value accepted. Press <Enter> to Continue")
           CALL accept(24,74,"p;cuh"," ")
          ENDIF
         ELSE
          CALL clear(24,1)
          CALL text(24,3,"Invalid value, numeric only. Press <Enter> to Continue")
          CALL accept(24,62,"p;cuh"," ")
         ENDIF
        ELSE
         SET s_dxr_validate = 1
         SET s_dxr_edata->tok_list[s_dxr_par_loop].answ = trim(curaccept)
        ENDIF
      ENDWHILE
      IF ((s_dxr_par_loop=s_dxr_edata->tok_cnt))
       CALL clear(((9+ s_dxr_par_loop)+ 4),1)
       CALL text(((9+ s_dxr_par_loop)+ 4),3,"Enter C to Continue or Q to Quit: ")
       CALL accept(((9+ s_dxr_par_loop)+ 4),37,"A;CU"," "
        WHERE curaccept IN ("C", "Q"))
       IF (curaccept="Q")
        GO TO exit_program
       ENDIF
      ENDIF
    ENDFOR
    IF (m_use_rng_ind=1
     AND (tbl_ranges->dt_gathered > s_dxr_edata->per_age))
     SET message = window
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,7,132)
     CALL text(3,40,"***  EXTRACT AND TRANSFORM ESTIMATES REPORTING  ***")
     CALL text(6,75,"ENVIRONMENT ID:")
     CALL text(6,20,"ENVIRONMENT NAME:")
     CALL text(6,95,cnvtstring(m_env_id))
     CALL text(6,40,trim(m_env_name))
     SET s_dxr_text = concat("Template : ",trim(s_dxr_edata->template_name))
     CALL text(8,3,s_dxr_text)
     CALL text(11,3,"The driver table for template selected has been marked to process in ranges")
     CALL text(13,3,"    The ranges are stale and should be regenerated before continuing.")
     CALL text(15,3,
      "Ranges can be generated by setting up a routine task or manually executing dm2_xnt_get_clinical_ranges"
      )
     CALL text(24,3,"Enter C to Continue without using ranges, S to use stale ranges or Q to Quit: ")
     CALL accept(24,80,"A;CU"," "
      WHERE curaccept IN ("C", "Q", "S"))
     IF (curaccept="Q")
      GO TO exit_program
     ELSEIF (curaccept="C")
      SET m_use_rng_ind = 0
     ENDIF
    ENDIF
    SET message = nowindow
    IF ((s_dxr_edata->table_name="ORDERS"))
     SET dm_err->eproc = "Obtain Values for ORDER_STATUS_CD"
     CALL disp_msg(" ",dm_err->logfile,0)
     INSERT  FROM dm_info di
      (di.info_number, di.info_domain, di.info_name,
      di.info_long_id)(SELECT DISTINCT
       cvg.child_code_value, "XNT_ORDER_STATUS_QUAL", concat("OSQ:",currdbhandle,":",trim(cnvtstring(
          cvg.child_code_value,20),3)),
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
      GO TO exit_program
     ELSE
      COMMIT
     ENDIF
     IF (curqual=0)
      SET dm_err->err_ind = 1
      SET dm_err->emsg = "Could not obtain order_status_cd values"
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      GO TO exit_program
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
    SET m_dmi_join_ind = 0
    SET s_dxr_orders_extra = " "
    SET m_add_select = 0
    FOR (s_dxr_par_loop = 1 TO s_dxr_edata->tok_cnt)
      CASE (s_dxr_edata->tok_list[s_dxr_par_loop].token)
       OF "EVENT_SET_NAME":
        SET dm_err->eproc = "Obtain Values for EVENT_SET_NAME"
        CALL disp_msg(" ",dm_err->logfile,0)
        INSERT  FROM dm_info di
         (di.info_number, di.info_domain, di.info_name,
         di.info_long_id)(SELECT DISTINCT
          ese.event_cd, "XNT_CE_EVENT_CD_QUAL", concat("CECQ:",currdbhandle,":",trim(cnvtstring(ese
             .event_cd,20),3)),
          cnvtreal(currdbhandle)
          FROM v500_event_set_code esc,
           v500_event_set_explode ese
          WHERE esc.event_set_name=trim(s_dxr_edata->tok_list[s_dxr_par_loop].answ,3)
           AND ese.event_set_cd=esc.event_set_cd)
         WITH nocounter
        ;end insert
        IF (check_error(dm_err->eproc)=1)
         SET message = nowindow
         CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
         GO TO exit_program
        ELSE
         COMMIT
        ENDIF
        IF (curqual=0)
         SET dm_err->emsg = "Could not obtain event_cd values"
         SET dm_err->err_ind = 1
         SET message = nowindow
         CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
         GO TO exit_program
        ENDIF
        SET m_dmi_join_ind = 1
       OF "XNT_CTLG_TYP_CD_DISPLAY_KEY":
        IF (cnvtupper(trim(s_dxr_edata->tok_list[s_dxr_par_loop].answ,3)) != "ALL")
         SET dm_err->eproc = "Obtain Values for XNT_CTLG_TYP_CD_DISPLAY_KEY"
         CALL disp_msg(" ",dm_err->logfile,0)
         INSERT  FROM dm_info di
          (di.info_number, di.info_domain, di.info_name,
          di.info_long_id)(SELECT DISTINCT
           cvg.child_code_value, "XNT_ORDER_CATALOG_TYPE_CD_QUAL", concat("OCTCQ:",currdbhandle,":",
            trim(cnvtstring(cvg.child_code_value,20),3)),
           cnvtreal(currdbhandle)
           FROM code_value cv,
            code_value_group cvg
           WHERE cvg.parent_code_value=cv.code_value
            AND cv.code_set=4002373
            AND cv.display_key=trim(s_dxr_edata->tok_list[s_dxr_par_loop].answ,3)
            AND cv.active_ind=1)
          WITH nocounter
         ;end insert
         IF (check_error(dm_err->eproc)=1)
          SET message = nowindow
          CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
          GO TO exit_program
         ELSE
          COMMIT
         ENDIF
         IF (curqual=0)
          SET dm_err->emsg = "Could not obtain catalog_type_cd values"
          SET dm_err->err_ind = 1
          SET message = nowindow
          CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
          GO TO exit_program
         ELSE
          SET m_dmi_join_ind = 1
          SET dm_err->eproc = "Obtain query for XNT_CTLG_TYP_CD_DISPLAY_KEY"
          CALL disp_msg(" ",dm_err->logfile,0)
          SELECT INTO "nl:"
           FROM dm_info di
           WHERE di.info_domain="DM2XNT_EXTRA_QUAL_D"
            AND (di.info_name=s_dxr_edata->tok_list[s_dxr_par_loop].token)
           DETAIL
            IF (((m_add_select=0) OR (m_add_select=3)) )
             m_add_select = 3, s_dxr_orders_extra = concat(" ",trim(replace(trim(replace(di.info_char,
                  ":AUDSID:",concat(trim(currdbhandle),".0"),0)),"''","'",0)))
            ENDIF
           WITH nocounter
          ;end select
          IF (check_error(dm_err->eproc)=1)
           SET message = nowindow
           CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
           GO TO exit_program
          ENDIF
          IF (curqual=0)
           SET dm_err->err_ind = 1
           SET dm_err->emsg = "Could not obtain XNT_CTLG_TYP_CD_DISPLAY_KEY query"
           SET message = nowindow
           CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
           GO TO exit_program
          ENDIF
         ENDIF
        ENDIF
       OF "XNT_CTLG_CD_DISPLAY_KEY":
        IF (cnvtupper(trim(s_dxr_edata->tok_list[s_dxr_par_loop].answ,3)) != "ALL")
         SET dm_err->eproc = "Obtain Values for XNT_CTLG_CD_DISPLAY_KEY"
         CALL disp_msg(" ",dm_err->logfile,0)
         INSERT  FROM dm_info di
          (di.info_number, di.info_domain, di.info_name,
          di.info_long_id)(SELECT DISTINCT
           cvg.child_code_value, "XNT_ORDER_CATALOG_CD_QUAL", concat("OCCQ:",currdbhandle,":",trim(
             cnvtstring(cvg.child_code_value,20),3)),
           cnvtreal(currdbhandle)
           FROM code_value cv,
            code_value_group cvg
           WHERE cvg.parent_code_value=cv.code_value
            AND cv.code_set=4002389
            AND cv.display_key=trim(s_dxr_edata->tok_list[s_dxr_par_loop].answ,3)
            AND cv.active_ind=1)
          WITH nocounter
         ;end insert
         IF (check_error(dm_err->eproc)=1)
          SET message = nowindow
          CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
          GO TO exit_program
         ELSE
          COMMIT
         ENDIF
         IF (curqual=0)
          SET dm_err->err_ind = 1
          SET dm_err->emsg = "Could not obtain catalog_cd values"
          SET message = nowindow
          CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
          GO TO exit_program
         ELSE
          SET m_dmi_join_ind = 1
          SET dm_err->eproc = "Obtain query for XNT_CTLG_CD_DISPLAY_KEY"
          CALL disp_msg(" ",dm_err->logfile,0)
          SELECT INTO "nl:"
           FROM dm_info di
           WHERE di.info_domain="DM2XNT_EXTRA_QUAL_D"
            AND (di.info_name=s_dxr_edata->tok_list[s_dxr_par_loop].token)
           DETAIL
            m_add_select = 1, s_dxr_orders_extra = concat(" ",trim(replace(trim(replace(di.info_char,
                 ":AUDSID:",concat(trim(currdbhandle),".0"),0)),"''","'",0)))
           WITH nocounter
          ;end select
          IF (check_error(dm_err->eproc)=1)
           SET message = nowindow
           CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
           GO TO exit_program
          ENDIF
          IF (curqual=0)
           SET dm_err->err_ind = 1
           SET dm_err->emsg = "Could not obtain XNT_CTLG_CD_DISPLAY_KEY query"
           SET message = nowindow
           CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
           GO TO exit_program
          ENDIF
         ENDIF
        ENDIF
       OF "XNT_ACT_TYP_CD_DISPLAY_KEY":
        IF (cnvtupper(trim(s_dxr_edata->tok_list[s_dxr_par_loop].answ,3)) != "ALL")
         SET dm_err->eproc = "Obtain Values for XNT_ACT_TYP_CD_DISPLAY_KEY"
         CALL disp_msg(" ",dm_err->logfile,0)
         INSERT  FROM dm_info di
          (di.info_number, di.info_domain, di.info_name,
          di.info_long_id)(SELECT DISTINCT
           cvg.child_code_value, "XNT_ORDER_ACTIVITY_TYPE_CD_QUAL", concat("OATCQ:",currdbhandle,":",
            trim(cnvtstring(cvg.child_code_value,20),3)),
           cnvtreal(currdbhandle)
           FROM code_value cv,
            code_value_group cvg
           WHERE cvg.parent_code_value=cv.code_value
            AND cv.code_set=4002388
            AND cv.display_key=trim(s_dxr_edata->tok_list[s_dxr_par_loop].answ,3)
            AND cv.active_ind=1)
          WITH nocounter
         ;end insert
         IF (check_error(dm_err->eproc)=1)
          SET message = nowindow
          CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
          GO TO exit_program
         ELSE
          COMMIT
         ENDIF
         IF (curqual=0)
          SET dm_err->err_ind = 1
          SET dm_err->emsg = "Could not obtain activity_type_cd values"
          SET message = nowindow
          CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
          GO TO exit_program
         ELSE
          SET m_dmi_join_ind = 1
          SET dm_err->eproc = "Obtain query for XNT_ACT_TYP_CD_DISPLAY_KEY"
          CALL disp_msg(" ",dm_err->logfile,0)
          SELECT INTO "nl:"
           FROM dm_info di
           WHERE di.info_domain="DM2XNT_EXTRA_QUAL_D"
            AND (di.info_name=s_dxr_edata->tok_list[s_dxr_par_loop].token)
           DETAIL
            IF (m_add_select != 1)
             m_add_select = 2, s_dxr_orders_extra = concat(" ",trim(replace(trim(replace(di.info_char,
                  ":AUDSID:",concat(trim(currdbhandle),".0"),0)),"''","'",0)))
            ENDIF
           WITH nocounter
          ;end select
          IF (check_error(dm_err->eproc)=1)
           CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
           GO TO exit_program
          ENDIF
          IF (curqual=0)
           SET dm_err->err_ind = 1
           SET dm_err->emsg = "Could not obtain XNT_ACT_TYP_CD_DISPLAY_KEY query"
           SET message = nowindow
           CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
           GO TO exit_program
          ENDIF
         ENDIF
        ENDIF
      ENDCASE
    ENDFOR
    SET dm_err->eproc = "Obtain Total row count query"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DM2XNT_DRIVER_SELECT"
      AND (di.info_name=s_dxr_edata->table_name)
     HEAD REPORT
      s_dxr_edata->ext_cnt = 1, stat = alterlist(s_dxr_edata->ext_stmt,s_dxr_edata->ext_cnt),
      s_dxr_edata->ext_stmt[s_dxr_edata->ext_cnt].ext_str = "select into 'nl:' y = count(*) "
     DETAIL
      s_dxr_edata->ext_cnt = (s_dxr_edata->ext_cnt+ 1), stat = alterlist(s_dxr_edata->ext_stmt,
       s_dxr_edata->ext_cnt), s_dxr_edata->ext_stmt[s_dxr_edata->ext_cnt].ext_str = replace(replace(
        di.info_char,":EXTRACT_DT_TM:",concat("sysdate - ",cnvtstring(s_dxr_edata->per_age)),0),
       ":DM_INFO:",evaluate(m_dmi_join_ind,1,", dm_info di "," "),0),
      s_dxr_edata->ext_stmt[s_dxr_edata->ext_cnt].ext_str = replace(s_dxr_edata->ext_stmt[s_dxr_edata
       ->ext_cnt].ext_str,":AUDSID:",trim(currdbhandle),0), s_op_col = findstring(":",s_dxr_edata->
       ext_stmt[s_dxr_edata->ext_cnt].ext_str,1,0)
      IF (s_op_col > 0)
       s_cl_col = findstring(":",s_dxr_edata->ext_stmt[s_dxr_edata->ext_cnt].ext_str,(s_op_col+ 1),0),
       s_tok_str = substring((s_op_col+ 1),((s_cl_col - s_op_col) - 1),s_dxr_edata->ext_stmt[
        s_dxr_edata->ext_cnt].ext_str), s_tok_idx = locateval(s_dxr_idx,1,s_dxr_edata->tok_cnt,
        s_tok_str,s_dxr_edata->tok_list[s_dxr_idx].token)
       IF (s_tok_idx > 0)
        s_dxr_edata->ext_stmt[s_dxr_edata->ext_cnt].ext_str = replace(s_dxr_edata->ext_stmt[
         s_dxr_edata->ext_cnt].ext_str,concat(":",trim(s_dxr_edata->tok_list[s_tok_idx].token),":"),
         concat("'",trim(s_dxr_edata->tok_list[s_tok_idx].answ),"'"),0)
       ENDIF
      ENDIF
     FOOT REPORT
      IF (size(trim(s_dxr_orders_extra,3),1) > 0)
       s_dxr_edata->ext_cnt = (s_dxr_edata->ext_cnt+ 1), stat = alterlist(s_dxr_edata->ext_stmt,
        s_dxr_edata->ext_cnt), s_dxr_edata->ext_stmt[s_dxr_edata->ext_cnt].ext_str =
       s_dxr_orders_extra
      ENDIF
      IF (m_use_rng_ind=1)
       s_dxr_edata->ext_cnt = (s_dxr_edata->ext_cnt+ 1), stat = alterlist(s_dxr_edata->ext_stmt,
        s_dxr_edata->ext_cnt), s_dxr_edata->ext_stmt[s_dxr_edata->ext_cnt].ext_str =
       " ::REPLACE_ME:: "
      ENDIF
      s_dxr_edata->ext_cnt = (s_dxr_edata->ext_cnt+ 1), stat = alterlist(s_dxr_edata->ext_stmt,
       s_dxr_edata->ext_cnt), s_dxr_edata->ext_stmt[s_dxr_edata->ext_cnt].ext_str = " detail ",
      s_dxr_edata->ext_cnt = (s_dxr_edata->ext_cnt+ 1), stat = alterlist(s_dxr_edata->ext_stmt,
       s_dxr_edata->ext_cnt), s_dxr_edata->ext_stmt[s_dxr_edata->ext_cnt].ext_str =
      "   s_dxr_edata->ext_rows = s_dxr_edata->ext_rows + y ",
      s_dxr_edata->ext_cnt = (s_dxr_edata->ext_cnt+ 1), stat = alterlist(s_dxr_edata->ext_stmt,
       s_dxr_edata->ext_cnt)
      IF ((s_dxr_edata->table_name IN ("ORDERS", "CLINICAL_EVENT")))
       s_dxr_edata->ext_stmt[s_dxr_edata->ext_cnt].ext_str =
       " with orahint('ORDERED'),orahintcbo('ORDERED'), nocounter go "
      ELSE
       s_dxr_edata->ext_stmt[s_dxr_edata->ext_cnt].ext_str = " with nocounter go "
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET message = nowindow
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     GO TO exit_program
    ENDIF
    IF (m_use_rng_ind=1)
     SET m_dxr_rng_loop = tbl_ranges->cnt
    ENDIF
    SET dm_err->eproc = "Execute extract row count query"
    CALL disp_msg(" ",dm_err->logfile,0)
    FOR (m_dxr_rng_loop_start = 1 TO m_dxr_rng_loop)
      SET dxer_request->cnt = 0
      SET stat = alterlist(dxer_request->qual,0)
      FOR (s_dxr_idx = 1 TO s_dxr_edata->ext_cnt)
        SET dxer_request->cnt = (dxer_request->cnt+ 1)
        SET stat = alterlist(dxer_request->qual,dxer_request->cnt)
        IF (m_use_rng_ind=1)
         IF (findstring("::REPLACE_ME::",s_dxr_edata->ext_stmt[s_dxr_idx].ext_str,1,0) > 0)
          SET dxer_request->qual[dxer_request->cnt].str = replace(s_dxr_edata->ext_stmt[s_dxr_idx].
           ext_str,"::REPLACE_ME::",concat(" and m.",tbl_ranges->clm_name," >= ",trim(cnvtstring(
              tbl_ranges->qual[m_dxr_rng_loop_start].low_val,20)),".0 and m.",
            tbl_ranges->clm_name," < ",trim(cnvtstring(tbl_ranges->qual[m_dxr_rng_loop_start].
              high_val,20)),".0 "))
         ELSE
          SET dxer_request->qual[dxer_request->cnt].str = s_dxr_edata->ext_stmt[s_dxr_idx].ext_str
         ENDIF
        ELSE
         SET dxer_request->qual[dxer_request->cnt].str = s_dxr_edata->ext_stmt[s_dxr_idx].ext_str
        ENDIF
      ENDFOR
      EXECUTE dm2_xnt_xml_parser  WITH replace("DXXP_REQUEST","DXER_REQUEST")
      IF ((dm_err->err_ind != 0))
       SET message = nowindow
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       IF (findstring("01555",cnvtupper(dm_err->emsg),1,0) > 0
        AND size(trim(tbl_ranges->clm_name),1) > 0)
        SET message = window
        CALL clear(1,1)
        SET width = 132
        CALL box(1,1,7,132)
        CALL text(3,40,"***  EXTRACT AND TRANSFORM ESTIMATES REPORTING  ***")
        CALL text(6,75,"ENVIRONMENT ID:")
        CALL text(6,20,"ENVIRONMENT NAME:")
        CALL text(6,95,cnvtstring(m_env_id))
        CALL text(6,40,trim(m_env_name))
        SET s_dxr_text = concat("Template : ",trim(s_dxr_edata->template_name))
        CALL text(8,3,s_dxr_text)
        CALL text(11,3,"The driver table for template selected has been marked to process in ranges")
        IF (m_use_rng_ind=1)
         CALL text(13,3,concat(
           "  The current set of ranges needs to be increased to prevent snapshot/resource",
           " errors during estimate calculations."))
         SET s_dxr_text = concat(
          "  Execuate dm2_xnt_set_clinical_range, increasing the number of ranges from current",
          " value: ",trim(cnvtstring(tbl_ranges->cur_rng))," and then regenerate ranges.")
         CALL text(14,3,s_dxr_text)
        ELSE
         CALL text(13,3,
          "  Estimates could not be completed without using ranges. Please generate ranges for the table."
          )
        ENDIF
        CALL text(16,3,concat(
          "Ranges can be generated by setting up a routine task or manually executing",
          " dm2_xnt_get_clinical_ranges"))
        CALL text(24,3,"Press <Enter> to exit")
        CALL accept(24,25,"p;cuh"," ")
       ENDIF
       GO TO exit_program
      ENDIF
    ENDFOR
    SET dm_err->eproc = "Obtain total rows in table list"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_user_tables_actual_stats ut
     WHERE expand(s_dxr_idx,1,s_dxr_tbl->tbl_cnt,ut.table_name,s_dxr_tbl->tbl_list[s_dxr_idx].
      table_name)
     HEAD REPORT
      s_dxr_tdx = 0
     DETAIL
      s_dxr_tdx = locateval(s_dxr_idx,1,s_dxr_tbl->tbl_cnt,ut.table_name,s_dxr_tbl->tbl_list[
       s_dxr_idx].table_name), s_dxr_tbl->tbl_list[s_dxr_tdx].table_rows = ut.num_rows
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET message = nowindow
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     GO TO exit_program
    ENDIF
    SET dm_err->eproc = "Obtain space taken by table"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM user_segments us
     WHERE expand(s_dxr_idx,1,s_dxr_tbl->tbl_cnt,us.segment_name,s_dxr_tbl->tbl_list[s_dxr_idx].
      table_name)
      AND us.segment_type="TABLE"
     HEAD REPORT
      s_dxr_tdx = 0
     DETAIL
      s_dxr_tdx = locateval(s_dxr_idx,1,s_dxr_tbl->tbl_cnt,us.segment_name,s_dxr_tbl->tbl_list[
       s_dxr_idx].table_name), s_dxr_tbl->tbl_list[s_dxr_tdx].total_space = us.bytes
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET message = nowindow
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     GO TO exit_program
    ENDIF
    SET dm_err->eproc = "Obtain space taken by table indexes"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM user_indexes ui,
      user_segments us
     WHERE expand(s_dxr_idx,1,s_dxr_tbl->tbl_cnt,ui.table_name,s_dxr_tbl->tbl_list[s_dxr_idx].
      table_name)
      AND us.segment_name=ui.index_name
      AND us.segment_type="INDEX"
     HEAD REPORT
      s_dxr_tdx = 0
     DETAIL
      s_dxr_tdx = locateval(s_dxr_idx,1,s_dxr_tbl->tbl_cnt,ui.table_name,s_dxr_tbl->tbl_list[
       s_dxr_idx].table_name), s_dxr_tbl->tbl_list[s_dxr_tdx].total_space = (s_dxr_tbl->tbl_list[
      s_dxr_tdx].total_space+ us.bytes)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET message = nowindow
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     GO TO exit_program
    ENDIF
    SET dm_err->eproc = "Calculate estimate for rows extracted and space freed after extract"
    CALL disp_msg(" ",dm_err->logfile,0)
    SET s_dxr_validate = 0
    SET s_dxr_tdx = locateval(s_dxr_idx,1,s_dxr_tbl->tbl_cnt,s_dxr_edata->table_name,s_dxr_tbl->
     tbl_list[s_dxr_idx].table_name)
    SET s_dxr_tbl->tbl_list[s_dxr_tdx].ext_rows = s_dxr_edata->ext_rows
    SET s_dxr_tbl->tbl_list[s_dxr_tdx].ext_space = (s_dxr_tbl->tbl_list[s_dxr_tdx].ext_rows * (
    s_dxr_tbl->tbl_list[s_dxr_tdx].total_space/ s_dxr_tbl->tbl_list[s_dxr_tdx].table_rows))
    SET s_dxr_alternate->cnt_odd = 1
    SET s_dxr_loop_cnt = 0
    SET stat = alterlist(s_dxr_alternate->list_odd,s_dxr_alternate->cnt_odd)
    SET s_dxr_alternate->list_odd[s_dxr_alternate->cnt_odd].t_name = s_dxr_edata->table_name
    WHILE (s_dxr_validate=0)
      SET s_dxr_loop_cnt = (s_dxr_loop_cnt+ 1)
      IF (even(s_dxr_loop_cnt)=1)
       SET s_dxr_alternate->cnt_odd = 0
       SET stat = alterlist(s_dxr_alternate->list_odd,s_dxr_alternate->cnt_odd)
       FOR (s_dxr_tdx = 1 TO s_dxr_alternate->cnt_even)
         FOR (s_dxr_tdx2 = 1 TO s_dxr_edata->pair_cnt)
           IF ((s_dxr_edata->pair_list[s_dxr_tdx2].par_tbl=s_dxr_alternate->list_even[s_dxr_tdx].
           t_name))
            SET s_dxr_idx2 = locateval(s_dxr_idx,1,s_dxr_alternate->cnt_odd,s_dxr_edata->pair_list[
             s_dxr_tdx2].chld_tbl,s_dxr_alternate->list_odd[s_dxr_idx].t_name)
            IF (s_dxr_idx2=0)
             SET s_dxr_alternate->cnt_odd = (s_dxr_alternate->cnt_odd+ 1)
             SET stat = alterlist(s_dxr_alternate->list_odd,s_dxr_alternate->cnt_odd)
             SET s_dxr_alternate->list_odd[s_dxr_alternate->cnt_odd].t_name = s_dxr_edata->pair_list[
             s_dxr_tdx2].chld_tbl
            ENDIF
            SET s_dxr_pdx = locateval(s_dxr_idx,1,s_dxr_tbl->tbl_cnt,s_dxr_edata->pair_list[
             s_dxr_tdx2].par_tbl,s_dxr_tbl->tbl_list[s_dxr_idx].table_name)
            SET s_dxr_cdx = locateval(s_dxr_idx,1,s_dxr_tbl->tbl_cnt,s_dxr_edata->pair_list[
             s_dxr_tdx2].chld_tbl,s_dxr_tbl->tbl_list[s_dxr_idx].table_name)
            IF (s_dxr_pdx > 0
             AND s_dxr_cdx > 0)
             SET s_dxr_tbl->tbl_list[s_dxr_cdx].ext_rows = (s_dxr_tbl->tbl_list[s_dxr_cdx].ext_rows+
             ((s_dxr_tbl->tbl_list[s_dxr_cdx].table_rows/ s_dxr_tbl->tbl_list[s_dxr_pdx].table_rows)
              * s_dxr_tbl->tbl_list[s_dxr_pdx].ext_rows))
             SET s_dxr_tbl->tbl_list[s_dxr_cdx].ext_space = (s_dxr_tbl->tbl_list[s_dxr_cdx].ext_rows
              * (s_dxr_tbl->tbl_list[s_dxr_cdx].total_space/ s_dxr_tbl->tbl_list[s_dxr_cdx].
             table_rows))
            ENDIF
           ENDIF
         ENDFOR
       ENDFOR
       SET s_dxr_alternate->cnt_even = 0
      ELSE
       SET s_dxr_alternate->cnt_even = 0
       SET stat = alterlist(s_dxr_alternate->list_even,s_dxr_alternate->cnt_even)
       FOR (s_dxr_tdx = 1 TO s_dxr_alternate->cnt_odd)
         FOR (s_dxr_tdx2 = 1 TO s_dxr_edata->pair_cnt)
           IF ((s_dxr_edata->pair_list[s_dxr_tdx2].par_tbl=s_dxr_alternate->list_odd[s_dxr_tdx].
           t_name))
            SET s_dxr_idx2 = locateval(s_dxr_idx,1,s_dxr_alternate->cnt_even,s_dxr_edata->pair_list[
             s_dxr_tdx2].chld_tbl,s_dxr_alternate->list_even[s_dxr_idx].t_name)
            IF (s_dxr_idx2=0)
             SET s_dxr_alternate->cnt_even = (s_dxr_alternate->cnt_even+ 1)
             SET stat = alterlist(s_dxr_alternate->list_even,s_dxr_alternate->cnt_even)
             SET s_dxr_alternate->list_even[s_dxr_alternate->cnt_even].t_name = s_dxr_edata->
             pair_list[s_dxr_tdx2].chld_tbl
            ENDIF
            SET s_dxr_pdx = locateval(s_dxr_idx,1,s_dxr_tbl->tbl_cnt,s_dxr_edata->pair_list[
             s_dxr_tdx2].par_tbl,s_dxr_tbl->tbl_list[s_dxr_idx].table_name)
            SET s_dxr_cdx = locateval(s_dxr_idx,1,s_dxr_tbl->tbl_cnt,s_dxr_edata->pair_list[
             s_dxr_tdx2].chld_tbl,s_dxr_tbl->tbl_list[s_dxr_idx].table_name)
            IF (s_dxr_pdx > 0
             AND s_dxr_cdx > 0)
             SET s_dxr_tbl->tbl_list[s_dxr_cdx].ext_rows = (s_dxr_tbl->tbl_list[s_dxr_cdx].ext_rows+
             ((s_dxr_tbl->tbl_list[s_dxr_cdx].table_rows/ s_dxr_tbl->tbl_list[s_dxr_pdx].table_rows)
              * s_dxr_tbl->tbl_list[s_dxr_pdx].ext_rows))
             SET s_dxr_tbl->tbl_list[s_dxr_cdx].ext_space = (s_dxr_tbl->tbl_list[s_dxr_cdx].ext_rows
              * (s_dxr_tbl->tbl_list[s_dxr_cdx].total_space/ s_dxr_tbl->tbl_list[s_dxr_cdx].
             table_rows))
            ENDIF
           ENDIF
         ENDFOR
       ENDFOR
       SET s_dxr_alternate->cnt_odd = 0
      ENDIF
      IF ((s_dxr_alternate->cnt_odd=0)
       AND (s_dxr_alternate->cnt_even=0))
       SET s_dxr_validate = 1
      ENDIF
    ENDWHILE
    SET s_dxr_loop_cnt = 0
    FOR (s_dxr_tbl_loop = 1 TO s_dxr_tbl->tbl_cnt)
      IF (floor(s_dxr_tbl->tbl_list[s_dxr_tbl_loop].ext_rows)=0)
       SET s_dxr_tbl->tbl_list[s_dxr_tbl_loop].ext_space = 0
      ENDIF
      SET s_dxr_loop_cnt = (s_dxr_loop_cnt+ 1)
      IF (even(s_dxr_loop_cnt)=1)
       SET s_dxr_found_ind = 0
       FOR (s_dxr_eo_loop1 = 1 TO s_dxr_tbl_order1->tbl_cnt)
         IF (s_dxr_found_ind=1)
          SET s_dxr_eo_loop2 = (s_dxr_eo_loop1+ 1)
         ELSE
          SET s_dxr_eo_loop2 = s_dxr_eo_loop1
         ENDIF
         SET s_dxr_tbl_order2->tbl_cnt = (s_dxr_tbl_order1->tbl_cnt+ 1)
         SET stat = alterlist(s_dxr_tbl_order2->tbl_list,s_dxr_tbl_order2->tbl_cnt)
         IF ((s_dxr_tbl->tbl_list[s_dxr_tbl_loop].ext_space >= s_dxr_tbl_order1->tbl_list[
         s_dxr_eo_loop1].ext_space))
          IF (s_dxr_found_ind=0)
           SET s_dxr_tbl_order2->tbl_list[s_dxr_eo_loop2].ext_rows = s_dxr_tbl->tbl_list[
           s_dxr_tbl_loop].ext_rows
           SET s_dxr_tbl_order2->tbl_list[s_dxr_eo_loop2].ext_space = s_dxr_tbl->tbl_list[
           s_dxr_tbl_loop].ext_space
           SET s_dxr_tbl_order2->tbl_list[s_dxr_eo_loop2].table_name = s_dxr_tbl->tbl_list[
           s_dxr_tbl_loop].table_name
           SET s_dxr_tbl_order2->tbl_list[s_dxr_eo_loop2].table_rows = s_dxr_tbl->tbl_list[
           s_dxr_tbl_loop].table_rows
           SET s_dxr_tbl_order2->tbl_list[s_dxr_eo_loop2].total_space = s_dxr_tbl->tbl_list[
           s_dxr_tbl_loop].total_space
           SET s_dxr_found_ind = 1
           SET s_dxr_tbl_order2->tbl_list[(s_dxr_eo_loop2+ 1)].ext_rows = s_dxr_tbl_order1->tbl_list[
           s_dxr_eo_loop1].ext_rows
           SET s_dxr_tbl_order2->tbl_list[(s_dxr_eo_loop2+ 1)].ext_space = s_dxr_tbl_order1->
           tbl_list[s_dxr_eo_loop1].ext_space
           SET s_dxr_tbl_order2->tbl_list[(s_dxr_eo_loop2+ 1)].table_name = s_dxr_tbl_order1->
           tbl_list[s_dxr_eo_loop1].table_name
           SET s_dxr_tbl_order2->tbl_list[(s_dxr_eo_loop2+ 1)].table_rows = s_dxr_tbl_order1->
           tbl_list[s_dxr_eo_loop1].table_rows
           SET s_dxr_tbl_order2->tbl_list[(s_dxr_eo_loop2+ 1)].total_space = s_dxr_tbl_order1->
           tbl_list[s_dxr_eo_loop1].total_space
          ELSE
           SET s_dxr_tbl_order2->tbl_list[s_dxr_eo_loop2].ext_rows = s_dxr_tbl_order1->tbl_list[
           s_dxr_eo_loop1].ext_rows
           SET s_dxr_tbl_order2->tbl_list[s_dxr_eo_loop2].ext_space = s_dxr_tbl_order1->tbl_list[
           s_dxr_eo_loop1].ext_space
           SET s_dxr_tbl_order2->tbl_list[s_dxr_eo_loop2].table_name = s_dxr_tbl_order1->tbl_list[
           s_dxr_eo_loop1].table_name
           SET s_dxr_tbl_order2->tbl_list[s_dxr_eo_loop2].table_rows = s_dxr_tbl_order1->tbl_list[
           s_dxr_eo_loop1].table_rows
           SET s_dxr_tbl_order2->tbl_list[s_dxr_eo_loop2].total_space = s_dxr_tbl_order1->tbl_list[
           s_dxr_eo_loop1].total_space
          ENDIF
         ELSE
          IF ((s_dxr_eo_loop1=s_dxr_tbl_order1->tbl_cnt))
           SET s_dxr_tbl_order2->tbl_list[(s_dxr_eo_loop2+ 1)].ext_rows = s_dxr_tbl->tbl_list[
           s_dxr_tbl_loop].ext_rows
           SET s_dxr_tbl_order2->tbl_list[(s_dxr_eo_loop2+ 1)].ext_space = s_dxr_tbl->tbl_list[
           s_dxr_tbl_loop].ext_space
           SET s_dxr_tbl_order2->tbl_list[(s_dxr_eo_loop2+ 1)].table_name = s_dxr_tbl->tbl_list[
           s_dxr_tbl_loop].table_name
           SET s_dxr_tbl_order2->tbl_list[(s_dxr_eo_loop2+ 1)].table_rows = s_dxr_tbl->tbl_list[
           s_dxr_tbl_loop].table_rows
           SET s_dxr_tbl_order2->tbl_list[(s_dxr_eo_loop2+ 1)].total_space = s_dxr_tbl->tbl_list[
           s_dxr_tbl_loop].total_space
           SET s_dxr_tbl_order2->tbl_list[s_dxr_eo_loop2].ext_rows = s_dxr_tbl_order1->tbl_list[
           s_dxr_eo_loop1].ext_rows
           SET s_dxr_tbl_order2->tbl_list[s_dxr_eo_loop2].ext_space = s_dxr_tbl_order1->tbl_list[
           s_dxr_eo_loop1].ext_space
           SET s_dxr_tbl_order2->tbl_list[s_dxr_eo_loop2].table_name = s_dxr_tbl_order1->tbl_list[
           s_dxr_eo_loop1].table_name
           SET s_dxr_tbl_order2->tbl_list[s_dxr_eo_loop2].table_rows = s_dxr_tbl_order1->tbl_list[
           s_dxr_eo_loop1].table_rows
           SET s_dxr_tbl_order2->tbl_list[s_dxr_eo_loop2].total_space = s_dxr_tbl_order1->tbl_list[
           s_dxr_eo_loop1].total_space
          ELSE
           SET s_dxr_tbl_order2->tbl_list[s_dxr_eo_loop2].ext_rows = s_dxr_tbl_order1->tbl_list[
           s_dxr_eo_loop1].ext_rows
           SET s_dxr_tbl_order2->tbl_list[s_dxr_eo_loop2].ext_space = s_dxr_tbl_order1->tbl_list[
           s_dxr_eo_loop1].ext_space
           SET s_dxr_tbl_order2->tbl_list[s_dxr_eo_loop2].table_name = s_dxr_tbl_order1->tbl_list[
           s_dxr_eo_loop1].table_name
           SET s_dxr_tbl_order2->tbl_list[s_dxr_eo_loop2].table_rows = s_dxr_tbl_order1->tbl_list[
           s_dxr_eo_loop1].table_rows
           SET s_dxr_tbl_order2->tbl_list[s_dxr_eo_loop2].total_space = s_dxr_tbl_order1->tbl_list[
           s_dxr_eo_loop1].total_space
          ENDIF
         ENDIF
       ENDFOR
      ELSE
       IF (s_dxr_loop_cnt=1)
        SET s_dxr_tbl_order1->tbl_cnt = 1
        SET stat = alterlist(s_dxr_tbl_order1->tbl_list,s_dxr_tbl_order1->tbl_cnt)
        SET s_dxr_tbl_order1->tbl_list[s_dxr_tbl_order1->tbl_cnt].table_name = s_dxr_tbl->tbl_list[
        s_dxr_tbl_loop].table_name
        SET s_dxr_tbl_order1->tbl_list[s_dxr_tbl_order1->tbl_cnt].ext_rows = s_dxr_tbl->tbl_list[
        s_dxr_tbl_loop].ext_rows
        SET s_dxr_tbl_order1->tbl_list[s_dxr_tbl_order1->tbl_cnt].ext_space = s_dxr_tbl->tbl_list[
        s_dxr_tbl_loop].ext_space
        SET s_dxr_tbl_order1->tbl_list[s_dxr_tbl_order1->tbl_cnt].table_rows = s_dxr_tbl->tbl_list[
        s_dxr_tbl_loop].table_rows
        SET s_dxr_tbl_order1->tbl_list[s_dxr_tbl_order1->tbl_cnt].total_space = s_dxr_tbl->tbl_list[
        s_dxr_tbl_loop].total_space
       ELSE
        SET s_dxr_found_ind = 0
        FOR (s_dxr_eo_loop1 = 1 TO s_dxr_tbl_order2->tbl_cnt)
          IF (s_dxr_found_ind=1)
           SET s_dxr_eo_loop2 = (s_dxr_eo_loop1+ 1)
          ELSE
           SET s_dxr_eo_loop2 = s_dxr_eo_loop1
          ENDIF
          SET s_dxr_tbl_order1->tbl_cnt = (s_dxr_tbl_order2->tbl_cnt+ 1)
          SET stat = alterlist(s_dxr_tbl_order1->tbl_list,s_dxr_tbl_order1->tbl_cnt)
          IF ((s_dxr_tbl->tbl_list[s_dxr_tbl_loop].ext_space >= s_dxr_tbl_order2->tbl_list[
          s_dxr_eo_loop1].ext_space))
           IF (s_dxr_found_ind=0)
            SET s_dxr_tbl_order1->tbl_list[s_dxr_eo_loop2].ext_rows = s_dxr_tbl->tbl_list[
            s_dxr_tbl_loop].ext_rows
            SET s_dxr_tbl_order1->tbl_list[s_dxr_eo_loop2].ext_space = s_dxr_tbl->tbl_list[
            s_dxr_tbl_loop].ext_space
            SET s_dxr_tbl_order1->tbl_list[s_dxr_eo_loop2].table_name = s_dxr_tbl->tbl_list[
            s_dxr_tbl_loop].table_name
            SET s_dxr_tbl_order1->tbl_list[s_dxr_eo_loop2].table_rows = s_dxr_tbl->tbl_list[
            s_dxr_tbl_loop].table_rows
            SET s_dxr_tbl_order1->tbl_list[s_dxr_eo_loop2].total_space = s_dxr_tbl->tbl_list[
            s_dxr_tbl_loop].total_space
            SET s_dxr_found_ind = 1
            SET s_dxr_tbl_order1->tbl_list[(s_dxr_eo_loop2+ 1)].ext_rows = s_dxr_tbl_order2->
            tbl_list[s_dxr_eo_loop1].ext_rows
            SET s_dxr_tbl_order1->tbl_list[(s_dxr_eo_loop2+ 1)].ext_space = s_dxr_tbl_order2->
            tbl_list[s_dxr_eo_loop1].ext_space
            SET s_dxr_tbl_order1->tbl_list[(s_dxr_eo_loop2+ 1)].table_name = s_dxr_tbl_order2->
            tbl_list[s_dxr_eo_loop1].table_name
            SET s_dxr_tbl_order1->tbl_list[(s_dxr_eo_loop2+ 1)].table_rows = s_dxr_tbl_order2->
            tbl_list[s_dxr_eo_loop1].table_rows
            SET s_dxr_tbl_order1->tbl_list[(s_dxr_eo_loop2+ 1)].total_space = s_dxr_tbl_order2->
            tbl_list[s_dxr_eo_loop1].total_space
           ELSE
            SET s_dxr_tbl_order1->tbl_list[s_dxr_eo_loop2].ext_rows = s_dxr_tbl_order2->tbl_list[
            s_dxr_eo_loop1].ext_rows
            SET s_dxr_tbl_order1->tbl_list[s_dxr_eo_loop2].ext_space = s_dxr_tbl_order2->tbl_list[
            s_dxr_eo_loop1].ext_space
            SET s_dxr_tbl_order1->tbl_list[s_dxr_eo_loop2].table_name = s_dxr_tbl_order2->tbl_list[
            s_dxr_eo_loop1].table_name
            SET s_dxr_tbl_order1->tbl_list[s_dxr_eo_loop2].table_rows = s_dxr_tbl_order2->tbl_list[
            s_dxr_eo_loop1].table_rows
            SET s_dxr_tbl_order1->tbl_list[s_dxr_eo_loop2].total_space = s_dxr_tbl_order2->tbl_list[
            s_dxr_eo_loop1].total_space
           ENDIF
          ELSE
           IF ((s_dxr_eo_loop1=s_dxr_tbl_order2->tbl_cnt))
            SET s_dxr_tbl_order1->tbl_list[(s_dxr_eo_loop2+ 1)].ext_rows = s_dxr_tbl->tbl_list[
            s_dxr_tbl_loop].ext_rows
            SET s_dxr_tbl_order1->tbl_list[(s_dxr_eo_loop2+ 1)].ext_space = s_dxr_tbl->tbl_list[
            s_dxr_tbl_loop].ext_space
            SET s_dxr_tbl_order1->tbl_list[(s_dxr_eo_loop2+ 1)].table_name = s_dxr_tbl->tbl_list[
            s_dxr_tbl_loop].table_name
            SET s_dxr_tbl_order1->tbl_list[(s_dxr_eo_loop2+ 1)].table_rows = s_dxr_tbl->tbl_list[
            s_dxr_tbl_loop].table_rows
            SET s_dxr_tbl_order1->tbl_list[(s_dxr_eo_loop2+ 1)].total_space = s_dxr_tbl->tbl_list[
            s_dxr_tbl_loop].total_space
            SET s_dxr_tbl_order1->tbl_list[s_dxr_eo_loop2].ext_rows = s_dxr_tbl_order2->tbl_list[
            s_dxr_eo_loop1].ext_rows
            SET s_dxr_tbl_order1->tbl_list[s_dxr_eo_loop2].ext_space = s_dxr_tbl_order2->tbl_list[
            s_dxr_eo_loop1].ext_space
            SET s_dxr_tbl_order1->tbl_list[s_dxr_eo_loop2].table_name = s_dxr_tbl_order2->tbl_list[
            s_dxr_eo_loop1].table_name
            SET s_dxr_tbl_order1->tbl_list[s_dxr_eo_loop2].table_rows = s_dxr_tbl_order2->tbl_list[
            s_dxr_eo_loop1].table_rows
            SET s_dxr_tbl_order1->tbl_list[s_dxr_eo_loop2].total_space = s_dxr_tbl_order2->tbl_list[
            s_dxr_eo_loop1].total_space
           ELSE
            SET s_dxr_tbl_order1->tbl_list[s_dxr_eo_loop2].ext_rows = s_dxr_tbl_order2->tbl_list[
            s_dxr_eo_loop1].ext_rows
            SET s_dxr_tbl_order1->tbl_list[s_dxr_eo_loop2].ext_space = s_dxr_tbl_order2->tbl_list[
            s_dxr_eo_loop1].ext_space
            SET s_dxr_tbl_order1->tbl_list[s_dxr_eo_loop2].table_name = s_dxr_tbl_order2->tbl_list[
            s_dxr_eo_loop1].table_name
            SET s_dxr_tbl_order1->tbl_list[s_dxr_eo_loop2].table_rows = s_dxr_tbl_order2->tbl_list[
            s_dxr_eo_loop1].table_rows
            SET s_dxr_tbl_order1->tbl_list[s_dxr_eo_loop2].total_space = s_dxr_tbl_order2->tbl_list[
            s_dxr_eo_loop1].total_space
           ENDIF
          ENDIF
        ENDFOR
       ENDIF
      ENDIF
    ENDFOR
    IF ((s_dxr_tbl_order1->tbl_cnt=s_dxr_tbl->tbl_cnt))
     FOR (s_dxr_tbl_loop = 1 TO s_dxr_tbl_order1->tbl_cnt)
       SET s_dxr_tbl->tbl_list[s_dxr_tbl_loop].ext_rows = s_dxr_tbl_order1->tbl_list[s_dxr_tbl_loop].
       ext_rows
       SET s_dxr_tbl->tbl_list[s_dxr_tbl_loop].ext_space = s_dxr_tbl_order1->tbl_list[s_dxr_tbl_loop]
       .ext_space
       SET s_dxr_tbl->tbl_list[s_dxr_tbl_loop].table_name = s_dxr_tbl_order1->tbl_list[s_dxr_tbl_loop
       ].table_name
       SET s_dxr_tbl->tbl_list[s_dxr_tbl_loop].table_rows = s_dxr_tbl_order1->tbl_list[s_dxr_tbl_loop
       ].table_rows
       SET s_dxr_tbl->tbl_list[s_dxr_tbl_loop].total_space = s_dxr_tbl_order1->tbl_list[
       s_dxr_tbl_loop].total_space
     ENDFOR
    ELSE
     FOR (s_dxr_tbl_loop = 1 TO s_dxr_tbl_order2->tbl_cnt)
       SET s_dxr_tbl->tbl_list[s_dxr_tbl_loop].ext_rows = s_dxr_tbl_order2->tbl_list[s_dxr_tbl_loop].
       ext_rows
       SET s_dxr_tbl->tbl_list[s_dxr_tbl_loop].ext_space = s_dxr_tbl_order2->tbl_list[s_dxr_tbl_loop]
       .ext_space
       SET s_dxr_tbl->tbl_list[s_dxr_tbl_loop].table_name = s_dxr_tbl_order2->tbl_list[s_dxr_tbl_loop
       ].table_name
       SET s_dxr_tbl->tbl_list[s_dxr_tbl_loop].table_rows = s_dxr_tbl_order2->tbl_list[s_dxr_tbl_loop
       ].table_rows
       SET s_dxr_tbl->tbl_list[s_dxr_tbl_loop].total_space = s_dxr_tbl_order2->tbl_list[
       s_dxr_tbl_loop].total_space
     ENDFOR
    ENDIF
    SET s_dxr_ext_tot = 0
    SET s_dxr_spc_tot = 0
    SET dm_err->eproc = "Display report"
    CALL disp_msg(" ",dm_err->logfile,0)
    SET s_dxr_dt_tm = format(sysdate,";;q")
    SET message = nowindow
    SET width = 132
    SELECT INTO "MINE"
     d.seq
     FROM dummyt d
     HEAD REPORT
      row + 1, col 30, "****EXTRACT TEMPLATE ESTIMATED RESULTS REPORT****",
      row + 2
     DETAIL
      row + 1, col 5, "Date/Time: ",
      s_dxr_dt_tm, row + 2, col 5,
      "Extract Template: ", s_dxr_edata->template_name, row + 2,
      col 5, "Template Parameters: "
      FOR (s_dxr_idx = 1 TO s_dxr_edata->tok_cnt)
        row + 1, col 7, s_dxr_edata->tok_list[s_dxr_idx].q_str,
        ": ", call reportmove('COL',(s_dxr_max_q_size+ 10),0), s_dxr_edata->tok_list[s_dxr_idx].answ
      ENDFOR
      row + 2, col 47, "Extract Estimates",
      col 83, "Current Size", row + 1,
      col 5, "Table Name: ", col 48,
      "Rows  ", col 62, "Bytes ",
      col 82, "Rows ", col 94,
      "Bytes "
      FOR (s_dxr_idx = 1 TO s_dxr_tbl->tbl_cnt)
        row + 1, col 7, s_dxr_tbl->tbl_list[s_dxr_idx].table_name,
        s_dxr_row_temp = floor(s_dxr_tbl->tbl_list[s_dxr_idx].ext_rows)
        IF ((s_dxr_row_temp > s_dxr_tbl->tbl_list[s_dxr_idx].table_rows))
         s_dxr_row_temp = s_dxr_tbl->tbl_list[s_dxr_idx].table_rows, s_dxr_tbl->tbl_list[s_dxr_idx].
         ext_space = s_dxr_tbl->tbl_list[s_dxr_idx].total_space
        ENDIF
        col 38, s_dxr_row_temp
        IF (s_dxr_row_temp > 0)
         col 55, s_dxr_tbl->tbl_list[s_dxr_idx].ext_space
        ELSE
         col 55, s_dxr_row_temp
        ENDIF
        col 72, s_dxr_tbl->tbl_list[s_dxr_idx].table_rows, col 87,
        s_dxr_tbl->tbl_list[s_dxr_idx].total_space, s_dxr_ext_tot = (s_dxr_ext_tot+ s_dxr_tbl->
        tbl_list[s_dxr_idx].ext_space), s_dxr_spc_tot = (s_dxr_spc_tot+ s_dxr_tbl->tbl_list[s_dxr_idx
        ].total_space)
      ENDFOR
      row + 2, col 5, "Total : ",
      col 55, s_dxr_ext_tot, col 87,
      s_dxr_spc_tot
      IF (s_dxr_ext_tot > 0
       AND s_dxr_spc_tot > 0)
       s_dxr_row_temp = ((s_dxr_ext_tot/ s_dxr_spc_tot) * 100)
      ELSE
       s_dxr_row_temp = 0.0
      ENDIF
      row + 2, col 5, "Estimated percentage of space recovered after extract : ",
      s_dxr_row_temp, "%"
     WITH nocounter, maxcol = 512, formfeed = none
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET message = nowindow
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     GO TO exit_program
    ENDIF
   ELSE
    CALL clear(23,1)
    CALL text(24,3,"Invalid Template. Press <Enter> to continue")
    CALL accept(24,48,"p;cuh"," ")
   ENDIF
   SET s_dxr_validate = 0
   ROLLBACK
 ENDWHILE
 GO TO exit_program
 SUBROUTINE dxer_clean_info(null)
   SET dm_err->eproc = "Clean DM_INFO rows from previous run(s)"
   CALL disp_msg(" ",dm_err->logfile,0)
   DELETE  FROM dm_info di
    WHERE di.info_domain IN ("XNT_ORDER_STATUS_QUAL", "XNT_ORDER_CATALOG_TYPE_CD_QUAL",
    "XNT_ORDER_ACTIVITY_TYPE_CD_QUAL", "XNT_ORDER_CATALOG_CD_QUAL", "XNT_CE_EVENT_CD_QUAL")
     AND di.info_long_id=cnvtreal(currdbhandle)
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
#exit_program
 SET message = nowindow
 IF ((dm_err->err_ind=1))
  ROLLBACK
 ENDIF
 CALL dxer_clean_info(null)
 SET dm_err->eproc = "Dm2_xnt_estimate_rpt finished"
 CALL final_disp_msg("dm2_xnt_est_rpt")
END GO
