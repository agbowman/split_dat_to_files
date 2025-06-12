CREATE PROGRAM dm_rmc_rdds_setup:dba
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
 FREE RECORD dera_request
 RECORD dera_request(
   1 child_env_id = f8
   1 env_list[*]
     2 parent_env_id = f8
     2 child_env_id = f8
     2 relationship_type = vc
     2 pre_link_name = vc
     2 post_link_name = vc
     2 event_reason = vc
 )
 FREE RECORD dera_reply
 RECORD dera_reply(
   1 err_num = i4
   1 err_msg = vc
 )
 FREE RECORD derd_request
 RECORD derd_request(
   1 child_env_id = f8
   1 env_list[*]
     2 parent_env_id = f8
     2 child_env_id = f8
     2 relationship_type = vc
 )
 FREE RECORD derd_reply
 RECORD derd_reply(
   1 err_num = i4
   1 err_msg = vc
 )
 DECLARE drcr_get_relationship_type(null) = i2
 DECLARE drcr_get_ptam_config(i_source_env_id=f8,i_target_env_id=f8) = i2
 DECLARE drcr_get_cutover_config(i_source_env_id=f8,i_target_env_id=f8) = i2
 DECLARE drcr_get_dual_build_config(i_source_env_id=f8,i_target_env_id=f8) = i2
 DECLARE drcr_get_full_circle_config(i_source_env_id=f8,i_target_env_id=f8) = i2
 DECLARE drcr_check_all_config(i_config_info_rec=vc(ref)) = null
 DECLARE drcr_get_config_text(i_config_type=vc,i_config_setting=i2) = vc
 DECLARE drcr_check_cbc_setup(i_source_env_id=f8,i_target_env_id=f8,ccs_msg=vc(ref)) = null
 IF ((validate(drcr_reltn_type_list->count,- (1))=- (1)))
  FREE RECORD drcr_reltn_type_list
  RECORD drcr_reltn_type_list(
    1 qual[*]
      2 type = vc
    1 source_env_id = f8
    1 target_env_id = f8
    1 count = i2
  )
 ENDIF
 IF ((validate(drcr_config_info->config_complete_ind,- (1))=- (1)))
  FREE RECORD drcr_config_info
  RECORD drcr_config_info(
    1 source_env_id = f8
    1 target_env_id = f8
    1 config_complete_ind = i2
    1 error_ind = i2
    1 error_msg = vc
  )
 ENDIF
 IF ((validate(drcr_ccs_info->cbc_ind,- (1))=- (1)))
  FREE RECORD drcr_ccs_info
  RECORD drcr_ccs_info(
    1 cbc_ind = i2
    1 return_ind = i2
    1 return_msg = vc
  )
 ENDIF
 SUBROUTINE drcr_get_relationship_type(null)
   DECLARE dgrt_relationship_type = vc WITH protect, noconstant("NOT CONFIGURED")
   DECLARE dgrt_ndx = i2 WITH protect, noconstant(0)
   DECLARE dgrt_return = i2 WITH protect, noconstant(- (1))
   SELECT INTO "nl:"
    FROM dm_env_reltn der
    WHERE (der.parent_env_id=drcr_reltn_type_list->source_env_id)
     AND (der.child_env_id=drcr_reltn_type_list->target_env_id)
     AND expand(dgrt_ndx,1,drcr_reltn_type_list->count,der.relationship_type,drcr_reltn_type_list->
     qual[dgrt_ndx].type)
    DETAIL
     dgrt_relationship_type = der.relationship_type
    WITH nocounter
   ;end select
   SET dgrt_return = (locateval(dgrt_ndx,1,drcr_reltn_type_list->count,dgrt_relationship_type,
    drcr_reltn_type_list->qual[dgrt_ndx].type) - 1)
   RETURN(dgrt_return)
 END ;Subroutine
 SUBROUTINE drcr_get_ptam_config(i_source_env_id,i_target_env_id)
   SET stat = initrec(drcr_reltn_type_list)
   SET drcr_reltn_type_list->source_env_id = i_source_env_id
   SET drcr_reltn_type_list->target_env_id = i_target_env_id
   SET stat = alterlist(drcr_reltn_type_list->qual,2)
   SET drcr_reltn_type_list->count = 2
   SET drcr_reltn_type_list->qual[1].type = "NO PENDING TARGET AS MASTER"
   SET drcr_reltn_type_list->qual[2].type = "PENDING TARGET AS MASTER"
   RETURN(drcr_get_relationship_type(null))
 END ;Subroutine
 SUBROUTINE drcr_get_cutover_config(i_source_env_id,i_target_env_id)
   SET stat = initrec(drcr_reltn_type_list)
   SET drcr_reltn_type_list->source_env_id = i_source_env_id
   SET drcr_reltn_type_list->target_env_id = i_target_env_id
   SET stat = alterlist(drcr_reltn_type_list->qual,2)
   SET drcr_reltn_type_list->count = 2
   SET drcr_reltn_type_list->qual[1].type = "AUTO CUTOVER"
   SET drcr_reltn_type_list->qual[2].type = "PLANNED CUTOVER"
   RETURN(drcr_get_relationship_type(null))
 END ;Subroutine
 SUBROUTINE drcr_get_dual_build_config(i_source_env_id,i_target_env_id)
   SET stat = initrec(drcr_reltn_type_list)
   SET drcr_reltn_type_list->source_env_id = i_source_env_id
   SET drcr_reltn_type_list->target_env_id = i_target_env_id
   SET stat = alterlist(drcr_reltn_type_list->qual,2)
   SET drcr_reltn_type_list->count = 2
   SET drcr_reltn_type_list->qual[1].type = "ALLOW DUAL BUILD"
   SET drcr_reltn_type_list->qual[2].type = "BLOCK DUAL BUILD"
   RETURN(drcr_get_relationship_type(null))
 END ;Subroutine
 SUBROUTINE drcr_get_full_circle_config(i_source_env_id,i_target_env_id)
   SET stat = initrec(drcr_reltn_type_list)
   SET drcr_reltn_type_list->source_env_id = i_source_env_id
   SET drcr_reltn_type_list->target_env_id = i_target_env_id
   SET stat = alterlist(drcr_reltn_type_list->qual,1)
   SET drcr_reltn_type_list->count = 1
   SET drcr_reltn_type_list->qual[1].type = "RDDS MOVER CHANGES NOT LOGGED"
   RETURN((drcr_get_relationship_type(null)+ 1))
 END ;Subroutine
 SUBROUTINE drcr_check_all_config(i_config_info_rec)
  IF (drcr_get_cutover_config(i_config_info_rec->source_env_id,i_config_info_rec->target_env_id) >= 0
  )
   IF (drcr_get_dual_build_config(i_config_info_rec->source_env_id,i_config_info_rec->target_env_id)
    >= 0)
    SET i_config_info_rec->config_complete_ind = 1
    IF (drcr_get_full_circle_config(i_config_info_rec->source_env_id,i_config_info_rec->target_env_id
     )=1)
     IF ((drcr_get_ptam_config(i_config_info_rec->source_env_id,i_config_info_rec->target_env_id)=- (
     1)))
      SET i_config_info_rec->config_complete_ind = 0
     ENDIF
    ENDIF
   ENDIF
  ENDIF
  IF (check_error(dm_err->eproc) != 0)
   SET i_config_info_rec->error_ind = 1
   SET i_config_info_rec->error_msg = dm_err->emsg
  ELSE
   IF ((i_config_info_rec->config_complete_ind=0))
    SET i_config_info_rec->error_msg = concat(
     "The process is unable to proceed because one or more of the required mover ",
     'configurations have not been setup.  Please go to the "Configure RDDS Settings" option under the "Manage RDDS ',
     'Post Domain Copy" option in the DM_MERGE_DOMAIN_ADM script.')
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE drcr_get_config_text(i_config_type,i_config_setting)
   IF ((i_config_setting=- (1)))
    RETURN("Not Configured")
   ELSE
    CASE (trim(cnvtupper(i_config_type)))
     OF "PTAM":
      IF (i_config_setting=0)
       RETURN("NO PENDING TARGET AS MASTER")
      ELSE
       RETURN("PENDING TARGET AS MASTER")
      ENDIF
     OF "DUAL BUILD":
      IF (i_config_setting=0)
       RETURN("ALLOW DUAL BUILD")
      ELSE
       RETURN("BLOCK DUAL BUILD")
      ENDIF
     OF "CUTOVER":
      IF (i_config_setting=0)
       RETURN("AUTO CUTOVER")
      ELSE
       RETURN("PLANNED CUTOVER")
      ENDIF
     ELSE
      RETURN("Unknown Configuration Type")
    ENDCASE
   ENDIF
 END ;Subroutine
 SUBROUTINE drcr_check_cbc_setup(i_source_env_id,i_target_env_id,ccs_msg)
   DECLARE dccs_ctp = vc WITH protect, noconstant("")
   SET drcr_ccs_info->return_ind = 0
   SET drcr_ccs_info->cbc_ind = 0
   SET drcr_ccs_info->return_msg = ""
   SELECT INTO "NL:"
    FROM dm_info d
    WHERE d.info_domain="RDDS CONFIGURATION"
     AND d.info_name="CUTOVER BY CONTEXT"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET drcr_ccs_info->return_msg = dm_err->emsg
    SET drcr_ccs_info->return_ind = 1
    RETURN(null)
   ENDIF
   IF (curqual=0)
    SET drcr_ccs_info->return_ind = 0
    SET drcr_ccs_info->cbc_ind = 0
    RETURN(null)
   ELSE
    SET drcr_ccs_info->cbc_ind = 1
   ENDIF
   SELECT INTO "NL:"
    FROM dm_info d
    WHERE d.info_domain="RDDS CONTEXT"
     AND d.info_name="CONTEXTS TO PULL"
    DETAIL
     dccs_ctp = d.info_char
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET drcr_ccs_info->return_msg = dm_err->emsg
    SET drcr_ccs_info->return_ind = 1
    RETURN(null)
   ENDIF
   IF (((findstring("::",dccs_ctp,1,0) > 0) OR (cnvtupper(dccs_ctp)="ALL")) )
    SELECT INTO "NL:"
     FROM dm_info d
     WHERE d.info_domain="RDDS CONTEXT"
      AND d.info_name="CONTEXT GROUP_IND"
      AND d.info_number=0
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     SET drcr_ccs_info->return_msg = dm_err->emsg
     SET drcr_ccs_info->return_ind = 1
     RETURN(null)
    ENDIF
    IF (curqual=0)
     SET drcr_ccs_info->return_msg = concat(
      "The RDDS mover configuration must be set up to maintain contexts that are being pulled, ",
      "in order for cutover by context to be used.  Please correct the setup through DM_MERGE_DOMAIN_ADM."
      )
     SET drcr_ccs_info->return_ind = 1
     RETURN(null)
    ENDIF
   ELSE
    SELECT INTO "NL:"
     FROM dm_info d
     WHERE d.info_domain="RDDS CONTEXT"
      AND d.info_name="CONTEXT GROUP_IND"
      AND d.info_number=1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     SET drcr_ccs_info->return_msg = dm_err->emsg
     SET drcr_ccs_info->return_ind = 1
     RETURN(null)
    ENDIF
    IF (curqual=0)
     SET drcr_ccs_info->return_msg = concat(
      "When only pulling 1 context, the CONTEXT GROUP_IND row must be set to 1.  Please use DM_MERGE_DOMAIN_ADM to setup ",
      "the context information for the merge, so that it is performed correctly.")
     SET drcr_ccs_info->return_ind = 1
     RETURN(null)
    ENDIF
   ENDIF
   SET dccs_ctp = concat("::",dccs_ctp,"::")
   IF (((findstring("::NULL::",cnvtupper(dccs_ctp),1,0) > 0) OR (findstring("::ALL::",cnvtupper(
     dccs_ctp),1,0) > 0)) )
    SELECT INTO "NL:"
     FROM dm_info d
     WHERE d.info_domain="RDDS CONTEXT"
      AND d.info_name="DEFAULT CONTEXT"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     SET drcr_ccs_info->return_msg = dm_err->emsg
     SET drcr_ccs_info->return_ind = 1
     RETURN(null)
    ENDIF
    IF (curqual=0)
     SET drcr_ccs_info->return_msg = concat(
      "The RDDS mover configuration must have a default context supplied if pulling NULL or ALL. ",
      "Please correct the setup through DM_MERGE_DOMAIN_ADM.")
     SET drcr_ccs_info->return_ind = 1
     RETURN(null)
    ENDIF
   ENDIF
   SELECT INTO "NL:"
    FROM user_objects u
    WHERE u.object_name IN ("DM_RDDS_DMT_DEL", "DM_RDDS_DMT_INS", "DM_RDDS_DMT_UPD")
     AND u.object_type="TRIGGER"
     AND status="VALID"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (curqual != 3)
    SET drcr_ccs_info->return_msg =
    "One of the DM_MERGE_TRANSLATE triggers is missing.  Please run DM_RMC_CREATE_DMT_TRIG to create the triggers."
    SET drcr_ccs_info->return_ind = 1
   ENDIF
   RETURN(null)
 END ;Subroutine
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
 DECLARE drdc_to_string(dts_num=f8) = vc
 SUBROUTINE drdc_to_string(dts_num)
   DECLARE dts_str = vc WITH protect, noconstant("")
   SET dts_str = trim(cnvtstring(dts_num,20),3)
   IF (findstring(".",dts_str)=0)
    SET dts_str = concat(dts_str,".0")
   ENDIF
   RETURN(dts_str)
 END ;Subroutine
 DECLARE drmmi_set_mock_id(dsmi_cur_id=f8,dsmi_final_tgt_id=f8,dsmi_mock_ind=i2) = i4
 DECLARE drmmi_get_mock_id(dgmi_env_id=f8) = f8
 DECLARE drmmi_backfill_mock_id(dbmi_env_id=f8) = f8
 SUBROUTINE drmmi_set_mock_id(dsmi_cur_id,dsmi_final_tgt_id,dsmi_mock_ind)
   DECLARE dsmi_info_char = vc WITH protect, noconstant("")
   DECLARE dsmi_mock_str = vc WITH protect, noconstant("")
   SET dsmi_info_char = drdc_to_string(dsmi_cur_id)
   SET dm_err->eproc = "Delete current mock setting."
   DELETE  FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name IN ("RDDS_MOCK_ENV_ID", "RDDS_NO_MOCK_ENV_ID")
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   IF (dsmi_mock_ind=1)
    SET dsmi_mock_str = "RDDS_MOCK_ENV_ID"
   ELSE
    SET dsmi_mock_str = "RDDS_NO_MOCK_ENV_ID"
   ENDIF
   SET dm_err->eproc = "Inserting new mock setting into dm_info."
   INSERT  FROM dm_info di
    SET di.info_domain = "DATA MANAGEMENT", di.info_name = dsmi_mock_str, di.info_number =
     dsmi_final_tgt_id,
     di.info_char = dsmi_info_char, di.updt_applctx = reqinfo->updt_applctx, di.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     di.updt_cnt = 0, di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   SET dm_err->eproc = "Log Mock Copy of Prod Change event."
   SET stat = initrec(auto_ver_request)
   SET stat = initrec(auto_ver_reply)
   SET stat = alterlist(auto_ver_request->qual,1)
   SET auto_ver_request->qual[1].rdds_event = "Mock Copy of Prod Change"
   SET auto_ver_request->qual[1].cur_environment_id = dsmi_cur_id
   SET auto_ver_request->qual[1].paired_environment_id = dsmi_final_tgt_id
   EXECUTE dm_rmc_auto_verify_setup
   IF ((auto_ver_reply->status="F"))
    ROLLBACK
    SET dm_err->err_ind = 1
    SET dm_err->emsg = auto_ver_reply->status_msg
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ELSE
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drmmi_get_mock_id(dgmi_env_id)
   DECLARE dgmi_mock_id = f8 WITH protect, noconstant(0.0)
   DECLARE dgmi_info_char = vc WITH protect, noconstant("")
   IF (dgmi_env_id=0.0)
    SET dm_err->eproc = "Gathering environment_id from dm_info."
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_name="DM_ENV_ID"
      AND di.info_domain="DATA MANAGEMENT"
     DETAIL
      dgmi_env_id = di.info_number
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(- (1))
    ELSEIF (dgmi_env_id=0.0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Could not retrieve valid environment_id"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET dgmi_info_char = drdc_to_string(dgmi_env_id)
   SET dm_err->eproc = "Querying dm_info for mock id."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name IN ("RDDS_MOCK_ENV_ID", "RDDS_NO_MOCK_ENV_ID")
     AND di.info_char=dgmi_info_char
    DETAIL
     IF (di.info_name="RDDS_MOCK_ENV_ID")
      dgmi_mock_id = di.info_number
     ELSE
      dgmi_mock_id = dgmi_env_id
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ELSEIF (curqual > 1)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid MOCK setup detected."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   IF (dgmi_mock_id=0.0)
    SET dgmi_mock_id = drmmi_backfill_mock_id(dgmi_env_id)
    IF (dgmi_mock_id < 0.0)
     RETURN(- (1))
    ENDIF
   ENDIF
   RETURN(dgmi_mock_id)
 END ;Subroutine
 SUBROUTINE drmmi_backfill_mock_id(dbmi_env_id)
   DECLARE dbmi_mock_id = f8 WITH protect, noconstant(0.0)
   DECLARE dbmi_info_char = vc WITH protect, noconstant("")
   DECLARE dbmi_continue = i2 WITH protect, noconstant(0)
   SET dbmi_info_char = drdc_to_string(dbmi_env_id)
   WHILE (dbmi_continue=0)
     SET drl_reply->status = ""
     SET drl_reply->status_msg = ""
     CALL get_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,0,drl_reply)
     IF ((drl_reply->status="F"))
      CALL disp_msg(drl_reply->status_msg,dm_err->logfile,1)
      SET dm_err->err_ind = 1
      SET dm_err->emsg = drl_reply->status_msg
      CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
      RETURN(- (1))
     ELSEIF ((drl_reply->status="Z"))
      CALL pause(10)
     ELSE
      SET dbmi_continue = 1
     ENDIF
   ENDWHILE
   SET dm_err->eproc = "Querying dm_info for mock id."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name IN ("RDDS_MOCK_ENV_ID", "RDDS_NO_MOCK_ENV_ID")
     AND di.info_char=dbmi_info_char
    DETAIL
     IF (di.info_name="RDDS_MOCK_ENV_ID")
      dbmi_mock_id = di.info_number
     ELSE
      dbmi_mock_id = dbmi_env_id
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
    RETURN(- (1))
   ENDIF
   IF (dbmi_mock_id=0.0)
    UPDATE  FROM dm_info di
     SET di.info_char = dbmi_info_char
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="RDDS_MOCK_ENV_ID"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     ROLLBACK
     CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
     RETURN(- (1))
    ELSE
     COMMIT
    ENDIF
    IF (curqual=0)
     SET dm_err->eproc = "Updating RDDS_NO_MOCK_ENV_ID row."
     UPDATE  FROM dm_info di
      SET di.info_number = 0.0, di.info_char = dbmi_info_char, di.updt_applctx = reqinfo->
       updt_applctx,
       di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_cnt = 0, di.updt_id = reqinfo->updt_id,
       di.updt_task = reqinfo->updt_task
      WHERE di.info_domain="DATA MANAGEMENT"
       AND di.info_name="RDDS_NO_MOCK_ENV_ID"
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      ROLLBACK
      CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
      RETURN(- (1))
     ELSE
      COMMIT
     ENDIF
     IF (curqual=0)
      SET dm_err->eproc = "Inserting RDDS_NO_MOCK_ENV_ID row."
      INSERT  FROM dm_info di
       SET di.info_domain = "DATA MANAGEMENT", di.info_name = "RDDS_NO_MOCK_ENV_ID", di.info_number
         = 0.0,
        di.info_char = dbmi_info_char, di.updt_applctx = reqinfo->updt_applctx, di.updt_dt_tm =
        cnvtdatetime(curdate,curtime3),
        di.updt_cnt = 0, di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       ROLLBACK
       CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
       RETURN(- (1))
      ELSE
       COMMIT
      ENDIF
     ENDIF
     SET dbmi_mock_id = dbmi_env_id
    ELSE
     SET dm_err->eproc = "Querying for mock id."
     SELECT INTO "nl:"
      FROM dm_info di
      WHERE di.info_domain="DATA MANAGEMENT"
       AND di.info_name="RDDS_MOCK_ENV_ID"
       AND di.info_char=dbmi_info_char
      DETAIL
       dbmi_mock_id = di.info_number
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
      RETURN(- (1))
     ENDIF
    ENDIF
   ENDIF
   CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
   RETURN(dbmi_mock_id)
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
 IF (validate(derg_request->env_id,- (1)) < 0)
  FREE RECORD derg_request
  RECORD derg_request(
    1 env_id = f8
    1 relationship_type = vc
  )
 ENDIF
 IF (validate(derg_reply->err_num,- (1)) < 0)
  FREE RECORD derg_reply
  RECORD derg_reply(
    1 parent_env_list[*]
      2 env_id = f8
      2 env_name = vc
      2 relationship_type = vc
      2 pre_link_name = vc
      2 post_link_name = vc
      2 no_log_ind = i2
    1 child_env_list[*]
      2 env_id = f8
      2 env_name = vc
      2 relationship_type = vc
      2 pre_link_name = vc
      2 post_link_name = vc
      2 no_log_ind = i2
    1 err_num = i4
    1 err_msg = vc
  )
 ENDIF
 DECLARE dmai_get_cur_mod_act(dgcma_mod_out=vc(ref),dmgca_act_out=vc(ref)) = i2
 DECLARE dmai_set_mod_act(module_name=vc,action_name=vc) = null WITH protect, sql =
 "SYS.DBMS_APPLICATION_INFO.SET_MODULE", parameter
 SUBROUTINE dmai_get_cur_mod_act(dgcma_mod_out,dmgca_act_out)
   DECLARE dgcma_mod_hold = vc WITH protect, noconstant("")
   DECLARE dgcma_act_hold = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Obtaining current Module and Action"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM v$session vs
    WHERE audsid=cnvtreal(currdbhandle)
    HEAD REPORT
     dgcma_mod_hold = vs.module, dgcma_act_hold = vs.action
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dgcma_mod_out = dgcma_mod_hold
   SET dmgca_act_out = dgcma_act_hold
   RETURN(1)
 END ;Subroutine
 DECLARE drrt_recompile_trigs(drt_cur_env_id=f8,drt_paired_env_id=f8,drt_event_reason=vc) = i4
 SUBROUTINE drrt_recompile_trigs(drt_cur_env_id,drt_paired_env_id,drt_event_reason)
   FREE RECORD drrs_invalid
   RECORD drt_invalid(
     1 data[*]
       2 name = vc
   ) WITH protect
   DECLARE drt_trig_cnt = i4 WITH protect, noconstant(0)
   DECLARE drt_i = i4 WITH protect, noconstant(0)
   DECLARE drt_j = i4 WITH protect, noconstant(0)
   DECLARE drt_k = i4 WITH protect, noconstant(0)
   DECLARE drt_module_name = vc WITH protect, constant("RDDS_PROCESS")
   DECLARE drt_action_name = vc WITH protect, constant("RDDS_DDL")
   DECLARE drt_original_module = vc WITH protect, noconstant(" ")
   DECLARE drt_original_action = vc WITH protect, noconstant(" ")
   DECLARE drt_module_set_ind = i2 WITH protect, noconstant(0)
   DECLARE drt_ret = i2 WITH protect, noconstant(1)
   IF (dm2_get_rdbms_version(null)=0)
    SET drt_ret = - (1)
    GO TO exit_drt_sub
   ENDIF
   IF ((dm2_rdbms_version->level1 >= 11))
    IF (dmai_get_cur_mod_act(drt_original_module,drt_original_action)=0)
     RETURN(- (1))
    ELSE
     SET drt_module_set_ind = 1
    ENDIF
    CALL dmai_set_mod_act(drt_module_name,drt_action_name)
   ENDIF
   EXECUTE dm_rdds_update_trig_proc
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET drt_ret = - (1)
    GO TO exit_drt_sub
   ENDIF
   SET dm_err->eproc = "RECOMPILING INVALID TRIGGERS"
   SELECT INTO "NL:"
    FROM dm2_user_objects d1
    WHERE d1.object_name="REFCHG*"
     AND d1.object_type="TRIGGER"
     AND d1.status != "VALID"
     AND d1.object_name != "REFCHG*MC*"
    HEAD REPORT
     drt_trig_cnt = 0
    DETAIL
     drt_trig_cnt = (drt_trig_cnt+ 1)
     IF (mod(drt_trig_cnt,10)=1)
      stat = alterlist(drt_invalid->data,(drt_trig_cnt+ 9))
     ENDIF
     drt_invalid->data[drt_trig_cnt].name = d1.object_name
    FOOT REPORT
     stat = alterlist(drt_invalid->data,drt_trig_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET drt_ret = - (1)
    GO TO exit_drt_sub
   ENDIF
   FOR (drt_i = 1 TO size(drt_invalid->data,5))
     CALL parser(concat("RDB ASIS(^alter trigger ",drt_invalid->data[drt_i].name," compile^) go"))
   ENDFOR
   SELECT INTO "NL:"
    d1.object_name
    FROM dm2_user_objects d1
    WHERE d1.object_name="REFCHG*"
     AND d1.object_type="TRIGGER"
     AND d1.status != "VALID"
     AND d1.object_name != "REFCHG*MC*"
    WITH nocounter, maxqual(d1,1)
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET drt_ret = - (1)
    GO TO exit_drt_sub
   ENDIF
   IF (curqual > 0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid triggers detected."
    SET drt_ret = - (1)
    GO TO exit_drt_sub
   ENDIF
   IF ((dm_err->err_ind=0))
    SET stat = alterlist(auto_ver_request->qual,size(derg_reply->child_env_list,5))
    SELECT INTO "nl:"
     ut.table_name, cnt = count(*)
     FROM user_triggers ut
     WHERE ((ut.trigger_name="REFCHG????ADD") OR (((ut.trigger_name="REFCHG????UPD") OR (ut
     .trigger_name="REFCHG????DEL")) ))
     GROUP BY ut.table_name
     HEAD REPORT
      drt_trig_cnt = 0
     DETAIL
      drt_trig_cnt = (drt_trig_cnt+ 1)
      IF (mod(drt_trig_cnt,10)=1)
       stat = alterlist(auto_ver_request->qual[1].detail_qual,(drt_trig_cnt+ 9))
      ENDIF
      auto_ver_request->qual[1].detail_qual[drt_trig_cnt].event_detail1_txt = ut.table_name,
      auto_ver_request->qual[1].detail_qual[drt_trig_cnt].event_value = cnt
     FOOT REPORT
      stat = alterlist(auto_ver_request->qual[1].detail_qual,drt_trig_cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET drt_ret = - (1)
     GO TO exit_drt_sub
    ENDIF
    FOR (drt_j = 1 TO size(derg_reply->child_env_list,5))
      SET auto_ver_request->qual[drt_j].rdds_event = "Add Environment Triggers"
      SET auto_ver_request->qual[drt_j].cur_environment_id = drt_cur_env_id
      SET auto_ver_request->qual[drt_j].paired_environment_id = derg_reply->child_env_list[drt_j].
      env_id
      SET auto_ver_request->qual[drt_j].event_reason = drt_event_reason
      IF (drt_j > 1)
       SET stat = alterlist(auto_ver_request->qual[drt_j].detail_qual,drt_trig_cnt)
       FOR (drt_k = 1 TO drt_trig_cnt)
        SET auto_ver_request->qual[drt_j].detail_qual[drt_k].event_detail1_txt = auto_ver_request->
        qual[1].detail_qual[drt_k].event_detail1_txt
        SET auto_ver_request->qual[drt_j].detail_qual[drt_k].event_value = auto_ver_request->qual[1].
        detail_qual[drt_k].event_value
       ENDFOR
      ENDIF
    ENDFOR
    EXECUTE dm_rmc_auto_verify_setup
    IF ((auto_ver_reply->status="F"))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET drt_ret = - (1)
     GO TO exit_drt_sub
    ELSE
     COMMIT
    ENDIF
   ELSE
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET drt_ret = - (1)
    GO TO exit_drt_sub
   ENDIF
#exit_drt_sub
   IF (drt_module_set_ind=1)
    CALL dmai_set_mod_act(drt_original_module,drt_original_action)
   ENDIF
   RETURN(drt_ret)
 END ;Subroutine
 DECLARE drrs_check_env_reltn(dcer_env_reltn=vc(ref)) = i4
 DECLARE drrs_connect_info_display(dcid_env_str=vc,dcid_paired_str=vc) = null
 FREE RECORD drrs_rec
 RECORD drrs_rec(
   1 cur_env_id = f8
   1 cur_env_name = vc
   1 replicate_source_id = f8
   1 replicate_env_name = vc
   1 mock_env_ind = i2
   1 build_source_id = f8
   1 build_source_name = vc
 )
 FREE RECORD drrs_parent_env
 RECORD drrs_parent_env(
   1 total = i4
   1 qual[*]
     2 parent_id = f8
     2 parent_name = vc
 )
 FREE RECORD drrs_link_request
 RECORD drrs_link_request(
   1 cur_env_id = f8
   1 cur_env_name = vc
   1 remote_env_id = f8
   1 remote_env_name = vc
   1 dblink_name = vc
   1 username = vc
   1 password = vc
   1 tnsname = vc
 )
 FREE RECORD drrs_link_reply
 RECORD drrs_link_reply(
   1 error_ind = i2
   1 error_msg = vc
   1 username = vc
   1 password = vc
   1 tnsname = vc
 )
 FREE RECORD drrs_env_reltn
 RECORD drrs_env_reltn(
   1 parent_env_id = f8
   1 child_env_id = f8
   1 total = i4
   1 qual[*]
     2 relationship_type = vc
     2 reltn_exist_ind = i2
     2 reverse_exist_ind = i2
 )
 IF (validate(reply) != 1)
  FREE RECORD reply
  RECORD reply(
    1 status_flg = i4
    1 err_msg = vc
  )
 ENDIF
 FREE RECORD drri_reply
 RECORD drri_reply(
   1 status = c1
   1 message = vc
 )
 DECLARE drrs_finished = i2 WITH protect, noconstant(0)
 DECLARE drrs_build_name = vc WITH protect, noconstant("")
 DECLARE drrs_build_id = f8 WITH protect, noconstant(0.0)
 DECLARE drrs_ret = i4 WITH protect, noconstant(0)
 DECLARE drrs_paired_id = f8 WITH protect, noconstant(0.0)
 DECLARE drrs_paired_name = vc WITH protect, noconstant(" ")
 DECLARE drrs_reltn_cnt = i4 WITH protect, noconstant(0)
 DECLARE drrs_ptam_ind = i2 WITH protect, noconstant(0)
 DECLARE drrs_reltn_str = vc WITH protect, noconstant("")
 DECLARE drrs_reverse_str = vc WITH protect, noconstant("")
 DECLARE drrs_i = i4 WITH protect, noconstant(0)
 DECLARE drrs_idx = i4 WITH protect, noconstant(0)
 DECLARE drrs_regen_ind = i2 WITH protect, noconstant(0)
 DECLARE drrs_cutover = i2 WITH protect, noconstant(0)
 DECLARE drrs_cutover_reverse = i2 WITH protect, noconstant(0)
 DECLARE drrs_ptam = i2 WITH protect, noconstant(0)
 DECLARE drrs_ptam_reverse = i2 WITH protect, noconstant(0)
 DECLARE drrs_dual_build = i2 WITH protect, noconstant(0)
 DECLARE drrs_dual_build_reverse = i2 WITH protect, noconstant(0)
 DECLARE drrs_username = vc WITH protect, noconstant(" ")
 DECLARE drrs_password = vc WITH protect, noconstant(" ")
 DECLARE drrs_tnsname = vc WITH protect, noconstant(" ")
 DECLARE drrs_paired_username = vc WITH protect, noconstant(" ")
 DECLARE drrs_paired_password = vc WITH protect, noconstant(" ")
 DECLARE drrs_paired_tnsname = vc WITH protect, noconstant(" ")
 DECLARE drrs_holder = vc WITH protect, noconstant(" ")
 DECLARE drrs_size = i4 WITH protect, noconstant(0)
 DECLARE drrs_link_pos = i4 WITH protect, noconstant(0)
 DECLARE drrs_user_pos = i4 WITH protect, noconstant(0)
 DECLARE drrs_env_str = vc WITH protect, noconstant(" ")
 DECLARE drrs_paired_str = vc WITH protect, noconstant(" ")
 DECLARE drrs_open_evt_src_id = f8 WITH protect, noconstant(0.0)
 IF (check_logfile("dm_rmc_rdds_setup",".log","DM_RMC_RDDS_SETUP LOG")=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to Create Log File"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Starting dm_rmc_rdds_setup"
 CALL disp_msg(" ",dm_err->logfile,0)
 SET dm_err->eproc = "Gathering environment id and name information."
 SELECT INTO "NL:"
  FROM dm_info a,
   dm_environment b
  PLAN (a
   WHERE a.info_name="DM_ENV_ID"
    AND a.info_domain="DATA MANAGEMENT")
   JOIN (b
   WHERE a.info_number=b.environment_id)
  DETAIL
   drrs_rec->cur_env_id = b.environment_id, drrs_rec->cur_env_name = b.environment_name
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ELSEIF ((drrs_rec->cur_env_id=0.0))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Error retrieving environment_id."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Gathering replicate source information."
 SELECT INTO "NL:"
  c.info_number
  FROM dm_info c,
   dm_environment d
  PLAN (c
   WHERE c.info_domain="RDDS REPLICATE INFO"
    AND c.info_name="DOMAIN REPLICATE SOURCE")
   JOIN (d
   WHERE c.info_number=d.environment_id)
  DETAIL
   drrs_rec->replicate_source_id = d.environment_id, drrs_rec->replicate_env_name = d
   .environment_name
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ELSEIF ((drrs_rec->replicate_source_id=0.0))
  CALL clear(09,1)
  CALL text(12,13,"Unexpected configuration found. Please log a SR with Database Architecture team.")
  CALL text(14,30,"Press ENTER to return to the previous menu.")
  CALL accept(14,74,"P;E"," ")
  SET help = off
  SET validate = off
  GO TO exit_program
 ENDIF
 WHILE (drrs_finished=0)
   SET dm_err->eproc = "Determine if this is a MOCK domain."
   CALL clear(9,01)
   CALL text(10,05,concat("It was detected that this environment was replicated from ",drrs_rec->
     replicate_env_name,":",trim(cnvtstring(drrs_rec->replicate_source_id,20),3),"."))
   CALL text(11,05,concat("Will environment ",drrs_rec->cur_env_name,":",trim(cnvtstring(drrs_rec->
       cur_env_id,20),3)," be used for a RDDS Mock (Y/N)? (Enter X to Exit.)"))
   CALL text(12,05,"ENTER CHOICE:")
   SET accept = nopatcheck
   CALL accept(12,30,"P;CU"
    WHERE curaccept IN ("Y", "N", "X"))
   SET accept = patcheck
   IF (curaccept="X")
    GO TO exit_program
   ELSEIF (curaccept="N")
    SET drrs_finished = 1
    SET drrs_rec->mock_env_ind = 0
    SET drrs_rec->build_source_id = 0
    SET drrs_rec->build_source_name = " "
    SET drrs_build_id = 0.0
    SET drrs_build_name = " "
    SET drrs_regen_ind = 0
    SET drrs_env_str = concat(drrs_rec->cur_env_name,":",trim(cnvtstring(drrs_rec->cur_env_id,20),3))
    SET drrs_paired_str = concat(drrs_rec->replicate_env_name,":",trim(cnvtstring(drrs_rec->
       replicate_source_id,20),3))
    CALL drrs_connect_info_display(drrs_env_str,drrs_paired_str)
    CALL text(24,3,"Would you like to continue?(Y/N)")
    CALL accept(24,40,"P;CU"," "
     WHERE curaccept IN ("Y", "N"))
    IF (curaccept="N")
     GO TO exit_program
    ENDIF
   ELSE
    DECLARE drcrt_precreate_ind = i2 WITH protect, noconstant(0)
    SET drcrt_precreate_ind = 1
    SET dm_err->eproc = "Querying for possible BUILD SOURCE environments."
    SELECT INTO "nl:"
     FROM dm_env_reltn der,
      dm_environment de
     WHERE der.relationship_type="REFERENCE MERGE"
      AND (der.child_env_id=drrs_rec->replicate_source_id)
      AND der.parent_env_id=de.environment_id
      AND (der.parent_env_id != drrs_rec->cur_env_id)
      AND de.environment_name != "OLD<*"
     HEAD REPORT
      drrs_parent_env->total = 0
     DETAIL
      drrs_parent_env->total = (drrs_parent_env->total+ 1), stat = alterlist(drrs_parent_env->qual,
       drrs_parent_env->total), drrs_parent_env->qual[drrs_parent_env->total].parent_id = der
      .parent_env_id,
      drrs_parent_env->qual[drrs_parent_env->total].parent_name = de.environment_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     GO TO exit_program
    ENDIF
    IF ((drrs_parent_env->total=1))
     SET drrs_build_name = drrs_parent_env->qual[1].parent_name
     SET drrs_build_id = drrs_parent_env->qual[1].parent_id
     CALL text(14,05,concat("The BUILD SOURCE environment of ",drrs_build_name,":",trim(cnvtstring(
         drrs_build_id,20),3)," will be used for this RDDS MOCK. "))
     CALL text(15,05,"Is this correct? (Y/N) (Enter X to exit.)")
     CALL text(16,05,"ENTER CHOICE: ")
     SET drrs_env_str = concat(drrs_rec->cur_env_name,":",trim(cnvtstring(drrs_rec->cur_env_id,20),3)
      )
     SET drrs_paired_str = concat(drrs_build_name,":",trim(cnvtstring(drrs_build_id,20),3))
     CALL drrs_connect_info_display(drrs_env_str,drrs_paired_str)
     SET accept = nopatcheck
     CALL accept(16,20,"P;CU","Y"
      WHERE curaccept IN ("Y", "N", "X"))
     SET accept = patcheck
     IF (curaccept="N")
      CALL clear(09,1)
      CALL text(12,13,
       "Unexpected configuration found. Please log a SR with Database Architecture team.")
      CALL text(14,30,"Press ENTER to return to the previous menu.")
      CALL accept(14,74,"P;E"," ")
      SET help = off
      SET validate = off
      GO TO exit_program
     ELSEIF (curaccept="X")
      GO TO exit_program
     ENDIF
    ELSEIF ((drrs_parent_env->total=0))
     CALL clear(09,1)
     CALL text(12,13,
      "Unexpected configuration found. Please log a SR with Database Architecture team.")
     CALL text(14,30,"Press ENTER to return to the previous menu.")
     CALL accept(14,74,"P;E"," ")
     SET help = off
     SET validate = off
     GO TO exit_program
    ELSE
     CALL text(14,05,
      "Please select the BUILD SOURCE environment that should be used for this RDDS MOCK relationship:"
      )
     SET help = pos(16,3,8,50)
     SET help =
     SELECT INTO "nl:"
      environment_id = drrs_parent_env->qual[d.seq].parent_id, environment_name = drrs_parent_env->
      qual[d.seq].parent_name
      FROM (dummyt d  WITH seq = value(drrs_parent_env->total))
      WHERE 1=1
      ORDER BY environment_name
      WITH nocounter
     ;end select
     SET validate =
     SELECT INTO "nl:"
      drrs_parent_env->qual[d.seq].parent_id
      FROM (dummyt d  WITH seq = value(drrs_parent_env->total))
      WHERE (drrs_parent_env->qual[d.seq].parent_id=cnvtreal(curaccept))
      WITH nocounter
     ;end select
     SET validate = 2
     CALL accept(14,115,"N(15);CUF","0")
     CALL clear(23,1)
     SET drrs_build_id = cnvtreal(trim(curaccept,3))
     SET validate = off
     SET help = off
     SET drrs_idx = locateval(drrs_i,1,drrs_parent_env->total,drrs_build_id,drrs_parent_env->qual[
      drrs_i].parent_id)
     SET drrs_build_name = drrs_parent_env->qual[drrs_idx].parent_name
     CALL clear(14,1)
     CALL text(14,05,concat("The BUILD SOURCE environment of ",drrs_build_name,":",trim(cnvtstring(
         drrs_build_id,20),3)," will be used for this RDDS MOCK. "))
     CALL text(15,05,"Is this correct? (Y/N) (Enter X to exit.)")
     CALL text(16,05,"ENTER CHOICE: ")
     SET drrs_env_str = concat(drrs_rec->cur_env_name,":",trim(cnvtstring(drrs_rec->cur_env_id,20),3)
      )
     SET drrs_paired_str = concat(drrs_build_name,":",trim(cnvtstring(drrs_build_id,20),3))
     CALL drrs_connect_info_display(drrs_env_str,drrs_paired_str)
     SET accept = nopatcheck
     CALL accept(16,20,"P;CU","Y"
      WHERE curaccept IN ("Y", "N", "X"))
     SET accept = patcheck
     IF (curaccept="N")
      SET drrs_finished = 0
      SET drrs_rec->build_source_id = 0
      SET drrs_rec->build_source_name = " "
      SET drrs_build_id = 0
      SET drrs_build_name = " "
      SET drrs_regen_ind = 0
     ELSEIF (curaccept="X")
      GO TO exit_program
     ELSE
      SET drrs_finished = 1
     ENDIF
    ENDIF
    IF (drrs_build_id > 0.0)
     SET drrs_finished = 1
     SET drrs_rec->mock_env_ind = 1
     SET drrs_rec->build_source_id = drrs_build_id
     SET drrs_rec->build_source_name = drrs_build_name
    ENDIF
   ENDIF
 ENDWHILE
 IF ((drrs_rec->mock_env_ind=1))
  SET drrs_paired_id = drrs_rec->build_source_id
  SET drrs_paired_name = drrs_rec->build_source_name
 ELSE
  SET drrs_paired_id = drrs_rec->replicate_source_id
  SET drrs_paired_name = drrs_rec->replicate_env_name
 ENDIF
 SET drrs_finished = 0
 WHILE (drrs_finished=0)
   SET dm_err->eproc = "Gathering connection information for current environment."
   SET message = window
   CALL clear(10,01)
   CALL text(10,3,concat("Please input connection information for the database ",drrs_rec->
     cur_env_name,":",trim(cnvtstring(drrs_rec->cur_env_id,20),3),"."))
   SELECT INTO "nl:"
    FROM dm_environment d
    WHERE (d.environment_id=drrs_rec->cur_env_id)
    DETAIL
     drrs_holder = d.v500_connect_string
    WITH nocounter
   ;end select
   SET drrs_size = size(drrs_holder,1)
   SET drrs_link_pos = findstring("@",drrs_holder)
   SET drrs_user_pos = findstring("/",drrs_holder)
   IF (drrs_size != 0)
    IF (drrs_user_pos != 0)
     SET drrs_username = substring(1,(drrs_user_pos - 1),drrs_holder)
    ENDIF
    IF (drrs_link_pos != 0)
     SET drrs_tnsname = substring((drrs_link_pos+ 1),(drrs_size - drrs_link_pos),drrs_holder)
     SET drrs_password = substring((drrs_user_pos+ 1),((drrs_link_pos - drrs_user_pos) - 1),
      drrs_holder)
    ELSE
     SET drrs_password = substring((drrs_user_pos+ 1),(drrs_size - drrs_user_pos),drrs_holder)
    ENDIF
   ENDIF
   CALL text(12,3,"Input user name: ")
   CALL accept(12,40,"P(30);CU",drrs_username)
   SET drrs_username = curaccept
   SET accept = nopatcheck
   CALL text(13,3,"Input password: ")
   CALL accept(13,40,"P(30);CEH",drrs_password)
   SET drrs_password = curaccept
   SET accept = patcheck
   CALL text(14,3,"Input tnsname for this environment: ")
   CALL accept(14,40,"P(30);CU",drrs_tnsname)
   SET drrs_tnsname = curaccept
   SET dm_err->eproc = "Gathering connection information for paired environment."
   CALL clear(10,01)
   CALL text(10,3,concat("Please input connection information for the database ",drrs_paired_name,":",
     trim(cnvtstring(drrs_paired_id,20),3),"."))
   SELECT INTO "nl:"
    FROM dm_environment d
    WHERE d.environment_id=drrs_paired_id
    DETAIL
     drrs_holder = d.v500_connect_string
    WITH nocounter
   ;end select
   SET drrs_size = size(drrs_holder,1)
   SET drrs_link_pos = findstring("@",drrs_holder)
   SET drrs_user_pos = findstring("/",drrs_holder)
   IF (drrs_size != 0)
    IF (drrs_user_pos != 0)
     SET drrs_paired_username = substring(1,(drrs_user_pos - 1),drrs_holder)
    ENDIF
    IF (drrs_link_pos != 0)
     SET drrs_paired_tnsname = substring((drrs_link_pos+ 1),(drrs_size - drrs_link_pos),drrs_holder)
     SET drrs_paired_password = substring((drrs_user_pos+ 1),((drrs_link_pos - drrs_user_pos) - 1),
      drrs_holder)
    ELSE
     SET drrs_paired_password = substring((drrs_user_pos+ 1),(drrs_size - drrs_user_pos),drrs_holder)
    ENDIF
   ENDIF
   CALL text(12,3,"Input user name: ")
   CALL accept(12,40,"P(30);CU",drrs_paired_username)
   SET drrs_paired_username = curaccept
   SET accept = nopatcheck
   CALL text(13,3,"Input password: ")
   CALL accept(13,40,"P(30);CEH",drrs_paired_password)
   SET drrs_paired_password = curaccept
   SET accept = patcheck
   CALL text(14,3,"Input tnsname for this environment: ")
   CALL accept(14,40,"P(30);CU",drrs_paired_tnsname)
   SET drrs_paired_tnsname = curaccept
   CALL clear(10,01)
   CALL text(12,20,concat("Environment Name: ",drrs_rec->cur_env_name))
   CALL text(12,80,concat("Environment Name: ",drrs_paired_name))
   CALL text(13,20,concat("Environment Id: ",trim(cnvtstring(drrs_rec->cur_env_id,20))))
   CALL text(13,80,concat("Environment Id: ",trim(cnvtstring(drrs_paired_id,20))))
   CALL text(14,20,concat("Username: ",drrs_username))
   CALL text(14,80,concat("Username: ",drrs_paired_username))
   CALL text(15,20,concat("Tnsname: ",drrs_tnsname))
   CALL text(15,80,concat("Tnsname: ",drrs_paired_tnsname))
   CALL text(17,10,
    "Please review and confirm the above connection information (Y/N). Enter X to exit.")
   SET accept = nopatcheck
   CALL accept(17,94,"P;CU"
    WHERE curaccept IN ("Y", "N", "X"))
   SET accept = patcheck
   IF (curaccept="X")
    GO TO exit_program
   ELSEIF (curaccept="Y")
    SET drrs_finished = 1
   ENDIF
 ENDWHILE
 SET message = nowindow
 IF ((drrs_rec->mock_env_ind=0))
  SET stat = initrec(drrs_env_reltn)
  SET drrs_env_reltn->parent_env_id = drrs_rec->replicate_source_id
  SET drrs_env_reltn->child_env_id = drrs_rec->cur_env_id
  SET drrs_env_reltn->total = 3
  SET stat = alterlist(drrs_env_reltn->qual,drrs_env_reltn->total)
  SET drrs_env_reltn->qual[1].relationship_type = "REFERENCE MERGE"
  SET drrs_env_reltn->qual[2].relationship_type = "RDDS MOVER CHANGES NOT LOGGED"
  SET drrs_env_reltn->qual[3].relationship_type = "REPLICATE MERGE"
  SET drrs_ret = drrs_check_env_reltn(drrs_env_reltn)
  IF (drrs_ret < 0)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   GO TO exit_program
  ENDIF
  SET stat = initrec(dera_request)
  SET stat = initrec(dera_reply)
  SET drrs_reltn_cnt = 0
  IF ((drrs_env_reltn->qual[3].reltn_exist_ind=1))
   SET dm_err->eproc = "Deleting REPLICATE MERGE relationship."
   DELETE  FROM dm_env_reltn der
    WHERE (der.parent_env_id=drrs_rec->replicate_source_id)
     AND (der.child_env_id=drrs_rec->cur_env_id)
     AND der.relationship_type="REPLICATE MERGE"
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    GO TO exit_program
   ENDIF
   COMMIT
  ENDIF
  IF ((drrs_env_reltn->qual[1].reltn_exist_ind=0))
   SET drrs_reltn_cnt = (drrs_reltn_cnt+ 1)
   SET stat = alterlist(dera_request->env_list,drrs_reltn_cnt)
   SET dera_request->env_list[drrs_reltn_cnt].relationship_type = "REFERENCE MERGE"
   SET dera_request->env_list[drrs_reltn_cnt].child_env_id = drrs_rec->cur_env_id
   SET dera_request->env_list[drrs_reltn_cnt].parent_env_id = drrs_rec->replicate_source_id
   IF ((drrs_env_reltn->qual[3].reltn_exist_ind=1))
    SET dera_request->env_list[drrs_reltn_cnt].event_reason =
    "Updating REPLICATE MERGE to REFERENCE MERGE"
   ENDIF
  ENDIF
  IF ((drrs_env_reltn->qual[3].reverse_exist_ind=1))
   SET dm_err->eproc = "Deleting REPLICATE MERGE relationship."
   DELETE  FROM dm_env_reltn der
    WHERE (der.parent_env_id=drrs_rec->cur_env_id)
     AND (der.child_env_id=drrs_rec->replicate_source_id)
     AND der.relationship_type="REPLICATE MERGE"
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    GO TO exit_program
   ENDIF
   COMMIT
  ENDIF
  IF ((drrs_env_reltn->qual[1].reverse_exist_ind=0))
   SET drrs_reltn_cnt = (drrs_reltn_cnt+ 1)
   SET stat = alterlist(dera_request->env_list,drrs_reltn_cnt)
   SET dera_request->env_list[drrs_reltn_cnt].relationship_type = "REFERENCE MERGE"
   SET dera_request->env_list[drrs_reltn_cnt].child_env_id = drrs_rec->replicate_source_id
   SET dera_request->env_list[drrs_reltn_cnt].parent_env_id = drrs_rec->cur_env_id
   IF ((drrs_env_reltn->qual[3].reverse_exist_ind=1))
    SET dera_request->env_list[drrs_reltn_cnt].event_reason =
    "Updating REPLICATE MERGE to REFERENCE MERGE"
   ENDIF
   SET drrs_regen_ind = 1
  ENDIF
  IF ((drrs_env_reltn->qual[2].reltn_exist_ind=0))
   SET drrs_reltn_cnt = (drrs_reltn_cnt+ 1)
   SET stat = alterlist(dera_request->env_list,drrs_reltn_cnt)
   SET dera_request->env_list[drrs_reltn_cnt].relationship_type = "RDDS MOVER CHANGES NOT LOGGED"
   SET dera_request->env_list[drrs_reltn_cnt].child_env_id = drrs_rec->cur_env_id
   SET dera_request->env_list[drrs_reltn_cnt].parent_env_id = drrs_rec->replicate_source_id
  ENDIF
  IF ((drrs_env_reltn->qual[2].reverse_exist_ind=0))
   SET drrs_reltn_cnt = (drrs_reltn_cnt+ 1)
   SET stat = alterlist(dera_request->env_list,drrs_reltn_cnt)
   SET dera_request->env_list[drrs_reltn_cnt].relationship_type = "RDDS MOVER CHANGES NOT LOGGED"
   SET dera_request->env_list[drrs_reltn_cnt].child_env_id = drrs_rec->replicate_source_id
   SET dera_request->env_list[drrs_reltn_cnt].parent_env_id = drrs_rec->cur_env_id
  ENDIF
  IF (drrs_reltn_cnt > 0)
   EXECUTE dm_add_env_reltn
   IF ((dera_reply->err_num > 0))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = dera_reply->err_msg
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    ROLLBACK
    GO TO exit_program
   ENDIF
  ENDIF
 ELSE
  SET dm_err->eproc = "Remove REPLICATE MERGE relationships between replicate source and target."
  SET stat = alterlist(derd_request->env_list,4)
  SET derd_request->env_list[1].parent_env_id = drrs_rec->cur_env_id
  SET derd_request->env_list[1].child_env_id = drrs_rec->replicate_source_id
  SET derd_request->env_list[1].relationship_type = "REPLICATE MERGE"
  SET derd_request->env_list[2].parent_env_id = drrs_rec->replicate_source_id
  SET derd_request->env_list[2].child_env_id = drrs_rec->cur_env_id
  SET derd_request->env_list[2].relationship_type = "REPLICATE MERGE"
  SET derd_request->env_list[3].parent_env_id = drrs_rec->cur_env_id
  SET derd_request->env_list[3].child_env_id = drrs_rec->replicate_source_id
  SET derd_request->env_list[3].relationship_type = "RDDS MOVER CHANGES NOT LOGGED"
  SET derd_request->env_list[4].parent_env_id = drrs_rec->replicate_source_id
  SET derd_request->env_list[4].child_env_id = drrs_rec->cur_env_id
  SET derd_request->env_list[4].relationship_type = "RDDS MOVER CHANGES NOT LOGGED"
  EXECUTE dm_del_env_reltn
  IF ((derd_reply->err_num > 0))
   SET dm_err->err_ind = 1
   SET dm_err->emsg = derd_reply->err_msg
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   ROLLBACK
   GO TO exit_program
  ENDIF
  SET stat = initrec(drrs_env_reltn)
  SET drrs_env_reltn->parent_env_id = drrs_rec->build_source_id
  SET drrs_env_reltn->child_env_id = drrs_rec->cur_env_id
  SET drrs_env_reltn->total = 2
  SET stat = alterlist(drrs_env_reltn->qual,drrs_env_reltn->total)
  SET drrs_env_reltn->qual[1].relationship_type = "REFERENCE MERGE"
  SET drrs_env_reltn->qual[2].relationship_type = "RDDS MOVER CHANGES NOT LOGGED"
  SET drrs_ret = drrs_check_env_reltn(drrs_env_reltn)
  IF (drrs_ret < 0)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   GO TO exit_program
  ENDIF
  SET stat = initrec(dera_request)
  SET stat = initrec(dera_reply)
  SET drrs_reltn_cnt = 0
  IF ((drrs_env_reltn->qual[1].reltn_exist_ind=0))
   SET drrs_reltn_cnt = (drrs_reltn_cnt+ 1)
   SET stat = alterlist(dera_request->env_list,drrs_reltn_cnt)
   SET dera_request->env_list[drrs_reltn_cnt].relationship_type = "REFERENCE MERGE"
   SET dera_request->env_list[drrs_reltn_cnt].child_env_id = drrs_rec->cur_env_id
   SET dera_request->env_list[drrs_reltn_cnt].parent_env_id = drrs_rec->build_source_id
  ENDIF
  IF ((drrs_env_reltn->qual[1].reverse_exist_ind=0))
   SET drrs_reltn_cnt = (drrs_reltn_cnt+ 1)
   SET stat = alterlist(dera_request->env_list,drrs_reltn_cnt)
   SET dera_request->env_list[drrs_reltn_cnt].relationship_type = "REFERENCE MERGE"
   SET dera_request->env_list[drrs_reltn_cnt].child_env_id = drrs_rec->build_source_id
   SET dera_request->env_list[drrs_reltn_cnt].parent_env_id = drrs_rec->cur_env_id
  ENDIF
  IF ((drrs_env_reltn->qual[2].reltn_exist_ind=0))
   SET drrs_reltn_cnt = (drrs_reltn_cnt+ 1)
   SET stat = alterlist(dera_request->env_list,drrs_reltn_cnt)
   SET dera_request->env_list[drrs_reltn_cnt].relationship_type = "RDDS MOVER CHANGES NOT LOGGED"
   SET dera_request->env_list[drrs_reltn_cnt].child_env_id = drrs_rec->cur_env_id
   SET dera_request->env_list[drrs_reltn_cnt].parent_env_id = drrs_rec->build_source_id
  ENDIF
  IF ((drrs_env_reltn->qual[2].reverse_exist_ind=0))
   SET drrs_reltn_cnt = (drrs_reltn_cnt+ 1)
   SET stat = alterlist(dera_request->env_list,drrs_reltn_cnt)
   SET dera_request->env_list[drrs_reltn_cnt].relationship_type = "RDDS MOVER CHANGES NOT LOGGED"
   SET dera_request->env_list[drrs_reltn_cnt].child_env_id = drrs_rec->build_source_id
   SET dera_request->env_list[drrs_reltn_cnt].parent_env_id = drrs_rec->cur_env_id
  ENDIF
  IF (drrs_reltn_cnt > 0)
   EXECUTE dm_add_env_reltn
   IF ((dera_reply->err_num > 0))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = dera_reply->err_msg
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    ROLLBACK
    GO TO exit_program
   ENDIF
   SET drrs_regen_ind = 1
  ENDIF
 ENDIF
 SET drrs_cutover = drcr_get_cutover_config(drrs_paired_id,drrs_rec->cur_env_id)
 SET drrs_cutover_reverse = drcr_get_cutover_config(drrs_rec->cur_env_id,drrs_paired_id)
 SET drrs_ptam = drcr_get_ptam_config(drrs_paired_id,drrs_rec->cur_env_id)
 SET drrs_ptam_reverse = drcr_get_ptam_config(drrs_rec->cur_env_id,drrs_paired_id)
 SET drrs_dual_build = drcr_get_dual_build_config(drrs_paired_id,drrs_rec->cur_env_id)
 SET drrs_dual_build_reverse = drcr_get_dual_build_config(drrs_rec->cur_env_id,drrs_paired_id)
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 SET stat = initrec(dera_request)
 SET stat = initrec(dera_reply)
 SET drrs_reltn_cnt = 0
 IF (drrs_cutover < 0)
  SET drrs_reltn_cnt = (drrs_reltn_cnt+ 1)
  SET stat = alterlist(dera_request->env_list,drrs_reltn_cnt)
  SET dera_request->env_list[drrs_reltn_cnt].relationship_type = "PLANNED CUTOVER"
  SET dera_request->env_list[drrs_reltn_cnt].child_env_id = drrs_rec->cur_env_id
  SET dera_request->env_list[drrs_reltn_cnt].parent_env_id = drrs_paired_id
 ENDIF
 IF (drrs_cutover_reverse < 0)
  SET drrs_reltn_cnt = (drrs_reltn_cnt+ 1)
  SET stat = alterlist(dera_request->env_list,drrs_reltn_cnt)
  SET dera_request->env_list[drrs_reltn_cnt].relationship_type = "PLANNED CUTOVER"
  SET dera_request->env_list[drrs_reltn_cnt].child_env_id = drrs_paired_id
  SET dera_request->env_list[drrs_reltn_cnt].parent_env_id = drrs_rec->cur_env_id
 ENDIF
 IF (((drrs_ptam=1) OR (drrs_ptam_reverse=1)) )
  SET drrs_ptam_ind = 1
 ENDIF
 IF (((drrs_ptam_ind=1) OR ((drrs_rec->mock_env_ind=1))) )
  SET drrs_reltn_str = "NO PENDING TARGET AS MASTER"
  SET drrs_reverse_str = "NO PENDING TARGET AS MASTER"
 ELSE
  SET drrs_reltn_str = "PENDING TARGET AS MASTER"
  SET drrs_reverse_str = "NO PENDING TARGET AS MASTER"
 ENDIF
 IF (drrs_ptam < 0)
  SET drrs_reltn_cnt = (drrs_reltn_cnt+ 1)
  SET stat = alterlist(dera_request->env_list,drrs_reltn_cnt)
  SET dera_request->env_list[drrs_reltn_cnt].relationship_type = drrs_reltn_str
  SET dera_request->env_list[drrs_reltn_cnt].child_env_id = drrs_rec->cur_env_id
  SET dera_request->env_list[drrs_reltn_cnt].parent_env_id = drrs_paired_id
  IF (drrs_dual_build >= 0)
   SET dm_err->eproc = "Remove DUAL BUILD setting"
   SET stat = alterlist(derd_request->env_list,1)
   SET derd_request->env_list[1].parent_env_id = drrs_paired_id
   SET derd_request->env_list[1].child_env_id = drrs_rec->cur_env_id
   SET derd_request->env_list[1].relationship_type = evaluate(drrs_dual_build,1,"BLOCK DUAL BUILD",0,
    "ALLOW DUAL BUILD")
   EXECUTE dm_del_env_reltn
   IF ((derd_reply->err_num > 0))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = derd_reply->err_msg
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    ROLLBACK
    GO TO exit_program
   ENDIF
   SET drrs_dual_build = - (1)
  ENDIF
 ENDIF
 IF (drrs_ptam_reverse < 0)
  SET drrs_reltn_cnt = (drrs_reltn_cnt+ 1)
  SET stat = alterlist(dera_request->env_list,drrs_reltn_cnt)
  SET dera_request->env_list[drrs_reltn_cnt].relationship_type = drrs_reverse_str
  SET dera_request->env_list[drrs_reltn_cnt].child_env_id = drrs_paired_id
  SET dera_request->env_list[drrs_reltn_cnt].parent_env_id = drrs_rec->cur_env_id
 ENDIF
 IF (((drrs_ptam_ind=1) OR ((drrs_rec->mock_env_ind=1))) )
  SET drrs_reltn_str = "BLOCK DUAL BUILD"
  SET drrs_reverse_str = "BLOCK DUAL BUILD"
 ELSE
  SET drrs_reltn_str = "ALLOW DUAL BUILD"
  SET drrs_reverse_str = "BLOCK DUAL BUILD"
 ENDIF
 IF (drrs_dual_build < 0)
  SET drrs_reltn_cnt = (drrs_reltn_cnt+ 1)
  SET stat = alterlist(dera_request->env_list,drrs_reltn_cnt)
  SET dera_request->env_list[drrs_reltn_cnt].relationship_type = drrs_reltn_str
  SET dera_request->env_list[drrs_reltn_cnt].child_env_id = drrs_rec->cur_env_id
  SET dera_request->env_list[drrs_reltn_cnt].parent_env_id = drrs_paired_id
 ENDIF
 IF (drrs_dual_build_reverse < 0)
  SET drrs_reltn_cnt = (drrs_reltn_cnt+ 1)
  SET stat = alterlist(dera_request->env_list,drrs_reltn_cnt)
  SET dera_request->env_list[drrs_reltn_cnt].relationship_type = drrs_reverse_str
  SET dera_request->env_list[drrs_reltn_cnt].child_env_id = drrs_paired_id
  SET dera_request->env_list[drrs_reltn_cnt].parent_env_id = drrs_rec->cur_env_id
 ENDIF
 IF (drrs_reltn_cnt > 0)
  EXECUTE dm_add_env_reltn
  IF ((dera_reply->err_num > 0))
   SET dm_err->err_ind = 1
   SET dm_err->emsg = dera_reply->err_msg
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   ROLLBACK
   GO TO exit_program
  ENDIF
 ENDIF
 SET drrs_link_request->cur_env_id = drrs_rec->cur_env_id
 SET drrs_link_request->cur_env_name = drrs_rec->cur_env_name
 IF ((drrs_rec->mock_env_ind=0))
  SET drrs_link_request->remote_env_id = drrs_rec->replicate_source_id
  SET drrs_link_request->remote_env_name = drrs_rec->replicate_env_name
 ELSE
  SET drrs_link_request->remote_env_id = drrs_rec->build_source_id
  SET drrs_link_request->remote_env_name = drrs_rec->build_source_name
 ENDIF
 SET drrs_link_request->dblink_name = concat("MERGE",trim(cnvtstring(drrs_link_request->remote_env_id,
    20),3),trim(cnvtstring(drrs_link_request->cur_env_id,20),3))
 SET drrs_link_request->username = drrs_paired_username
 SET drrs_link_request->password = drrs_paired_password
 SET drrs_link_request->tnsname = drrs_paired_tnsname
 EXECUTE dm_rmc_setup_dblink  WITH replace("REQUEST","DRRS_LINK_REQUEST"), replace("REPLY",
  "DRRS_LINK_REPLY")
 IF ((drrs_link_reply->error_ind=1))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = drrs_link_reply->error_msg
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ELSE
  SET drrs_paired_username = drrs_link_reply->username
  SET drrs_paired_password = drrs_link_reply->password
  SET drrs_paired_tnsname = drrs_link_reply->tnsname
 ENDIF
 SET dm_err->eproc = "Updating postlink name."
 UPDATE  FROM dm_env_reltn der
  SET der.post_link_name = concat("@",drrs_link_request->dblink_name)
  WHERE (der.parent_env_id=drrs_link_request->remote_env_id)
   AND (der.child_env_id=drrs_link_request->cur_env_id)
   AND der.relationship_type="REFERENCE MERGE"
  WITH nocounter
 ;end update
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  ROLLBACK
  GO TO exit_program
 ELSE
  COMMIT
 ENDIF
 IF ((drrs_rec->mock_env_ind=1))
  EXECUTE dm2_rdds_val_reltn drrs_rec->build_source_id
  IF ((dm_err->err_ind > 0))
   GO TO exit_program
  ENDIF
 ENDIF
 SET dm_err->eproc = concat("Connecting to ",drrs_paired_name," environment.")
 CALL disp_msg(" ",dm_err->logfile,0)
 CALL parser("free define oraclesystem go",1)
 CALL parser(concat("define oraclesystem '",drrs_paired_username,"/",drrs_paired_password,"@",
   drrs_paired_tnsname,"' go"),1)
 IF (check_error(dm_err->eproc)=1)
  SET reply->status_flg = - (2)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 IF ((drrs_rec->mock_env_ind=1))
  SET drrs_ret = drrt_recompile_trigs(drrs_rec->build_source_id,drrs_rec->cur_env_id,
   "Automated Replicate Setup")
  IF (drrs_ret < 0)
   SET reply->status_flg = - (2)
   GO TO exit_program
  ENDIF
 ELSE
  SET drrs_link_request->remote_env_id = drrs_rec->cur_env_id
  SET drrs_link_request->remote_env_name = drrs_rec->cur_env_name
  SET drrs_link_request->cur_env_id = drrs_rec->replicate_source_id
  SET drrs_link_request->cur_env_name = drrs_rec->replicate_env_name
  SET drrs_link_request->dblink_name = concat("MERGE",trim(cnvtstring(drrs_link_request->
     remote_env_id,20),3),trim(cnvtstring(drrs_link_request->cur_env_id,20),3))
  SET drrs_link_request->username = drrs_username
  SET drrs_link_request->password = drrs_password
  SET drrs_link_request->tnsname = drrs_tnsname
  EXECUTE dm_rmc_setup_dblink  WITH replace("REQUEST","DRRS_LINK_REQUEST"), replace("REPLY",
   "DRRS_LINK_REPLY")
  IF ((drrs_link_reply->error_ind=1))
   SET reply->status_flg = - (2)
   SET dm_err->emsg = drrs_link_reply->error_msg
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   GO TO exit_program
  ELSE
   SET drrs_username = drrs_link_reply->username
   SET drrs_password = drrs_link_reply->password
   SET drrs_tnsname = drrs_link_reply->tnsname
  ENDIF
  SET dm_err->eproc = "Updating postlink name."
  UPDATE  FROM dm_env_reltn der
   SET der.post_link_name = concat("@",drrs_link_request->dblink_name)
   WHERE (der.parent_env_id=drrs_link_request->remote_env_id)
    AND (der.child_env_id=drrs_link_request->cur_env_id)
    AND der.relationship_type="REFERENCE MERGE"
   WITH nocounter
  ;end update
  IF (check_error(dm_err->eproc)=1)
   SET reply->status_flg = - (2)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   ROLLBACK
   GO TO exit_program
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET dm_err->eproc = concat("Connecting to ",drrs_rec->cur_env_name," environment.")
 CALL disp_msg(" ",dm_err->logfile,0)
 CALL parser("free define oraclesystem go",1)
 CALL parser(concat("define oraclesystem '",drrs_username,"/",drrs_password,"@",
   drrs_tnsname,"' go"),1)
 IF (check_error(dm_err->eproc)=1)
  SET reply->status_flg = - (2)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 IF (drrs_regen_ind=1)
  SET drrs_ret = drrt_recompile_trigs(drrs_rec->cur_env_id,drrs_paired_id,"Automated Replicate Setup"
   )
  IF (drrs_ret < 0)
   GO TO exit_program
  ENDIF
 ENDIF
 IF ((drrs_rec->mock_env_ind=1))
  SET drrs_ret = drmmi_set_mock_id(drrs_rec->cur_env_id,drrs_rec->replicate_source_id,drrs_rec->
   mock_env_ind)
 ELSE
  SET drrs_ret = drmmi_set_mock_id(drrs_rec->cur_env_id,0.0,drrs_rec->mock_env_ind)
 ENDIF
 IF (drrs_ret < 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ELSEIF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 EXECUTE dm2_rdds_metadata_refresh "NONE"
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 EXECUTE dm_rmc_env_change_event
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Executing dm_refresh_r_indexes"
 CALL disp_msg(" ",dm_err->logfile,0)
 EXECUTE dm_refresh_r_indexes  WITH replace("REPLY","DRRI_REPLY")
 IF ((drri_reply->status="F"))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = drri_reply->message
  GO TO exit_program
 ENDIF
 SET reply->status_flg = 1
 SUBROUTINE drrs_check_env_reltn(dcer_env_reltn)
   DECLARE dcer_idx = i4 WITH protect, noconstant(0)
   DECLARE dcer_num = i4 WITH protect, noconstant(0)
   IF ((dcer_env_reltn->total > 0))
    SET dm_err->eproc = "Querying dm_env_reltn for relationships."
    SELECT INTO "nl:"
     FROM dm_env_reltn der
     WHERE (((der.parent_env_id=dcer_env_reltn->parent_env_id)
      AND (der.child_env_id=dcer_env_reltn->child_env_id)) OR ((der.parent_env_id=dcer_env_reltn->
     child_env_id)
      AND (der.child_env_id=dcer_env_reltn->parent_env_id)))
      AND expand(dcer_num,1,dcer_env_reltn->total,der.relationship_type,dcer_env_reltn->qual[dcer_num
      ].relationship_type)
     DETAIL
      dcer_idx = locateval(dcer_num,1,dcer_env_reltn->total,der.relationship_type,dcer_env_reltn->
       qual[dcer_num].relationship_type)
      IF ((der.parent_env_id=dcer_env_reltn->parent_env_id))
       dcer_env_reltn->qual[dcer_idx].reltn_exist_ind = 1
      ELSE
       dcer_env_reltn->qual[dcer_idx].reverse_exist_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(- (1))
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrs_connect_info_display(cid_env_str,cid_paired_str)
   CALL clear(18,1)
   CALL text(18,22,"!!!WARNING: The next few screens will prompt you for the following: ")
   CALL text(19,22,concat("   The ",cid_env_str," domain V500 database password and connect string.")
    )
   CALL text(20,22,concat("   The ",cid_paired_str,
     " domain V500 database password and connect string."))
   CALL text(22,22,"Please have this information ready!!!")
   RETURN
 END ;Subroutine
#exit_program
 IF (check_error(dm_err->eproc)=1)
  SET reply->err_msg = dm_err->emsg
  IF ((reply->status_flg=- (2)))
   SET dm_err->err_ind = 0
   CALL parser("free define oraclesystem go",1)
   CALL parser(concat("define oraclesystem '",drrs_username,"/",drrs_password,"@",
     drrs_tnsname,"' go"),1)
   IF (check_error(dm_err->eproc) != 1)
    SET reply->status_flg = - (1)
   ENDIF
  ELSE
   SET reply->status_flg = - (1)
  ENDIF
 ENDIF
 CALL final_disp_msg("dm_rmc_rdds_setup")
END GO
