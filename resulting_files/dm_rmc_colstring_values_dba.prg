CREATE PROGRAM dm_rmc_colstring_values:dba
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
 DECLARE ms_log_prefix = vc WITH protect, constant("dm_rmc_colstr_val")
 DECLARE imaxlength = i4 WITH protect, constant(4000)
 DECLARE count = i4 WITH protect, noconstant(0)
 DECLARE ccnt = i4 WITH protect, noconstant(0)
 DECLARE tcnt = i4 WITH protect, noconstant(0)
 DECLARE inum = i4 WITH protect, noconstant(0)
 DECLARE icurcolstrlen = i4 WITH protect, noconstant(0)
 DECLARE itotcolstrlen = i4 WITH protect, noconstant(0)
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE y = i4 WITH protect, noconstant(0)
 DECLARE parm_nbr_cnt = i4 WITH protect, noconstant(0)
 DECLARE ideletecnt = i4 WITH protect, noconstant(0)
 DECLARE iinsertcnt = i4 WITH protect, noconstant(0)
 DECLARE itotinsertcnt = i4 WITH protect, noconstant(0)
 DECLARE s_info_name = vc WITH protect, noconstant("")
 DECLARE s_table_name = vc WITH protect, noconstant("")
 DECLARE s_column_name = vc WITH protect, noconstant("")
 DECLARE ms_report_filename = vc WITH protect, noconstant("dm_rmc_col_excl_rpt")
 DECLARE i_admin_ind = i4 WITH protect, noconstant(0)
 DECLARE drcv_tab_name = vc WITH protect, noconstant(" ")
 DECLARE drcv_mode = vc WITH protect, noconstant(" ")
 FREE RECORD tables_data
 RECORD tables_data(
   1 table_cnt = i4
   1 max_column_cnt = i4
   1 qual[*]
     2 table_name = vc
     2 table_status_flag = i2
     2 column_cnt = i4
     2 column_list[*]
       3 column_name = vc
       3 parm_nbr = i4
       3 data_type = vc
       3 data_length = i4
       3 unique_ident_ind = i2
       3 merge_delete_ind = i2
       3 defining_attribute_ind = i2
       3 column_status_flag = i2
 )
 IF (check_logfile(ms_log_prefix,".log","DM_RMC_COLSTRING_VALUES")=0)
  SET dm_err->err_ind = 1
  SET dm_err->eproc = "Error creating log file"
  CALL disp_msg(" ",dm_err->logfile,0)
  GO TO exit_program
 ENDIF
 IF ((dm_err->debug_flag >= 10))
  SET trace = echoinput
  SET trace = echoinput2
  SET trace = rdbbind
  SET trace = rdbdebug
  SET trace = callecho
 ENDIF
 SET dm_err->eproc = "Beginning DM_RMC_COLSTRING_VALUES"
 CALL disp_msg(" ",dm_err->logfile,0)
 IF (((reflect(parameter(1,0)) != "C*") OR (reflect(parameter(2,0)) != "C*")) )
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Expected syntax:  dm_rmc_colstring_values <mode> <table_name>"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ELSE
  SET drcv_mode =  $1
  SET drcv_tab_name =  $2
 ENDIF
 IF (cnvtupper(drcv_mode)="REVADMIN")
  IF (drcv_tab_name != char(42))
   SET dm_err->err_ind = 1
   SET dm_err->emsg =
   "Invalid parameter detected!  A table level regen can not be ran in REVADMIN mode."
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
  SET i_admin_ind = 1
  SET dm_err->eproc = "Running in ADMIN MASTER mode"
  CALL disp_msg(" ",dm_err->logfile,0)
 ELSEIF (cnvtupper(drcv_mode)="LOCAL")
  SET i_admin_ind = 0
  SET dm_err->eproc = "Running in local mode"
  CALL disp_msg(" ",dm_err->logfile,0)
 ELSE
  SET dm_err->err_ind = 1
  SET dm_err->emsg =
  "Invalid parameter detected!  The parameter passed into this program can only be REVADMIN or LOCAL."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Gather list of tables..."
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT
  IF (i_admin_ind=1)INTO "NL:"
   d.table_name
   FROM dm_rdds_tbl_doc d
   WHERE d.table_name=d.full_table_name
    AND ((d.reference_ind=1) OR (d.table_name IN (
   (SELECT
    rt.table_name
    FROM dm_rdds_refmrg_tables rt))))
  ELSE INTO "NL:"
   d.table_name
   FROM dm_tables_doc_local d
   WHERE  EXISTS (
   (SELECT
    "x"
    FROM user_tables u
    WHERE u.table_name=d.table_name))
    AND  NOT ( EXISTS (
   (SELECT
    "x"
    FROM dm_colstring_parm c
    WHERE c.table_name=d.table_name)))
    AND  NOT ( EXISTS (
   (SELECT
    "x"
    FROM code_value cv
    WHERE cv.code_set=4001912
     AND cv.cdf_meaning="NORDDSTRG"
     AND cv.active_ind=1
     AND cv.display=d.table_name)))
    AND ((d.reference_ind=1) OR (d.table_name IN (
   (SELECT
    rt.table_name
    FROM dm_rdds_refmrg_tables rt))))
    AND d.table_name=patstring(drcv_tab_name)
  ENDIF
  HEAD REPORT
   tcnt = 0
  DETAIL
   tcnt = (tcnt+ 1)
   IF (mod(tcnt,20)=1)
    stat = alterlist(tables_data->qual,(tcnt+ 19))
   ENDIF
   tables_data->qual[tcnt].table_name = d.table_name
  FOOT REPORT
   stat = alterlist(tables_data->qual,tcnt)
  WITH nocounter
 ;end select
 SET tables_data->table_cnt = tcnt
 IF (i_admin_ind=1)
  SET dm_err->eproc = "Determine which tables are in code set 4001912..."
  CALL disp_msg(" ",dm_err->logfile,0)
  SELECT INTO "NL:"
   FROM code_value cv,
    (dummyt d  WITH seq = tcnt)
   PLAN (d)
    JOIN (cv
    WHERE cv.code_set=4001912
     AND cv.cdf_meaning="NORDDSTRG"
     AND (cv.display=tables_data->qual[d.seq].table_name)
     AND cv.active_ind=1)
   DETAIL
    index = locateval(inum,1,tables_data->table_cnt,cv.display,tables_data->qual[inum].table_name),
    tables_data->qual[index].table_status_flag = 1
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc) != 0)
   SET dm_err->eproc = concat("Error filtering tables in code set 4001912: ",dm_err->emsg)
   GO TO exit_program
  ENDIF
 ENDIF
 SET dm_err->eproc = "Gather list of tables and columns on the exclusion list..."
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "NL:"
  d.info_name
  FROM dm2_admin_dm_info d
  WHERE d.info_domain="RDDS COLSTRING EXCLUSIONS"
  DETAIL
   ccnt = 0, tcnt = tables_data->table_cnt, s_info_name = d.info_name,
   s_table_name = substring(1,(findstring(":",s_info_name,1,0) - 1),s_info_name), s_column_name =
   substring((findstring(":",s_info_name,1,0)+ 1),size(s_info_name,1),s_info_name), index = locateval
   (inum,1,size(tables_data->qual,5),s_table_name,tables_data->qual[inum].table_name)
   IF (index > 0)
    ccnt = size(tables_data->qual[index].column_list,5), ccnt = (ccnt+ 1), stat = alterlist(
     tables_data->qual[index].column_list,ccnt),
    tables_data->qual[index].column_cnt = ccnt, tables_data->qual[index].column_list[ccnt].
    column_name = s_column_name, tables_data->qual[index].column_list[ccnt].parm_nbr = ccnt,
    tables_data->qual[index].column_list[ccnt].column_status_flag = 3
   ENDIF
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc) != 0)
  SET dm_err->eproc = concat("Error filtering tables in exclusion list: ",dm_err->emsg)
  GO TO exit_program
 ENDIF
 SET tables_data->max_column_cnt = 0
 IF (i_admin_ind=1)
  SET dm_err->eproc = concat("Clean-Up DM_ADM_COLSTRING_PARM table")
  CALL disp_msg(" ",dm_err->logfile,0)
  SELECT INTO "NL:"
   xcnt = count(*)
   FROM dm_adm_colstring_parm dcp
   DETAIL
    ideletecnt = xcnt
   WITH nocounter
  ;end select
  WHILE (ideletecnt > 0)
   DELETE  FROM dm_adm_colstring_parm dcp
    WHERE 1=1
    WITH maxqual = 2000
   ;end delete
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->eproc = concat("Error cleaning up rows from DM_ADM_COLSTRING_PARM table: ",dm_err->
     emsg)
    ROLLBACK
    GO TO exit_program
   ELSE
    SET dm_err->eproc = build("Cleaned up: ",ideletecnt," rows from DM_ADM_COLSTRING_PARM table")
    CALL disp_msg(" ",dm_err->logfile,0)
    COMMIT
    SET ideletecnt = (ideletecnt - 2000)
   ENDIF
  ENDWHILE
  SET ideletecnt = count
 ENDIF
 SET dm_err->eproc = "Gather table and column data..."
 CALL disp_msg(" ",dm_err->logfile,0)
 FOR (i = 1 TO tables_data->table_cnt)
   SELECT
    IF (i_admin_ind=1)INTO "NL:"
     dac.column_name, dac.data_type, dac.data_length,
     dcd.merge_delete_ind, dcd.unique_ident_ind, dcd.defining_attribute_ind
     FROM dm_adm_columns dac,
      dm_rdds_col_doc dcd
     WHERE (dac.table_name=tables_data->qual[i].table_name)
      AND (dcd.table_name=tables_data->qual[i].table_name)
      AND dcd.column_name=dac.column_name
      AND (dac.schema_date=
     (SELECT
      max(dat.schema_date)
      FROM dm_adm_tables dat
      WHERE (dat.table_name=tables_data->qual[i].table_name)))
      AND ((dac.virtual_column="NO") OR (dac.virtual_column = null))
      AND  NOT ( EXISTS (
     (SELECT
      "x"
      FROM dm_info di
      WHERE di.info_domain="RDDS IGNORE COL LIST:*"
       AND sqlpassthru(" dac.column_name like di.info_name and dac.table_name like di.info_char"))))
     ORDER BY dcd.unique_ident_ind DESC, dcd.merge_delete_ind DESC, dcd.defining_attribute_ind DESC,
      dac.data_length, dac.column_name
    ELSE INTO "NL:"
     dac.column_name, dac.data_type, dac.data_length,
     dcd.merge_delete_ind, dcd.unique_ident_ind, dcd.defining_attribute_ind
     FROM user_tab_cols dac,
      dm_columns_doc_local dcd
     WHERE (dac.table_name=tables_data->qual[i].table_name)
      AND (dcd.table_name=tables_data->qual[i].table_name)
      AND dcd.column_name=dac.column_name
      AND dac.hidden_column="NO"
      AND dac.virtual_column="NO"
      AND  NOT ( EXISTS (
     (SELECT
      "x"
      FROM dm_info di
      WHERE di.info_domain="RDDS IGNORE COL LIST:*"
       AND sqlpassthru(" dac.column_name like di.info_name and dac.table_name like di.info_char"))))
     ORDER BY dcd.unique_ident_ind DESC, dcd.merge_delete_ind DESC, dcd.defining_attribute_ind DESC,
      dac.data_length, dac.column_name
    ENDIF
    HEAD REPORT
     ccnt = size(tables_data->qual[i].column_list,5)
    DETAIL
     index = locateval(inum,1,size(tables_data->qual[i].column_list,5),dac.column_name,tables_data->
      qual[i].column_list[inum].column_name)
     IF (index=0)
      ccnt = (ccnt+ 1), stat = alterlist(tables_data->qual[i].column_list,ccnt), tables_data->qual[i]
      .column_list[ccnt].column_name = dac.column_name,
      tables_data->qual[i].column_list[ccnt].parm_nbr = ccnt, tables_data->qual[i].column_list[ccnt].
      data_type = dac.data_type
      IF (((dac.data_type="NUMBER") OR (dac.data_type="FLOAT")) )
       tables_data->qual[i].column_list[ccnt].data_length = 12
      ELSEIF (dac.data_type="DATE")
       tables_data->qual[i].column_list[ccnt].data_length = 20
      ELSE
       tables_data->qual[i].column_list[ccnt].data_length = dac.data_length
      ENDIF
      tables_data->qual[i].column_list[ccnt].unique_ident_ind = dcd.unique_ident_ind, tables_data->
      qual[i].column_list[ccnt].merge_delete_ind = dcd.merge_delete_ind, tables_data->qual[i].
      column_list[ccnt].defining_attribute_ind = dcd.defining_attribute_ind
      IF ((tables_data->qual[i].table_status_flag=1))
       tables_data->qual[i].column_list[ccnt].column_status_flag = 6
      ELSEIF (((dac.data_type="LONG") OR (((dac.data_type="LONG RAW") OR (dac.data_type="*LOB")) )) )
       tables_data->qual[i].column_list[ccnt].column_status_flag = 5
      ELSEIF (dac.column_name="*NLS")
       tables_data->qual[i].column_list[ccnt].column_status_flag = 4
      ELSEIF (dac.column_name IN ("ACTIVE_STATUS_CD", "ACTIVE_STATUS_DT_TM", "ACTIVE_STATUS_PRSNL_ID",
      "DATA_STATUS_CD", "DATA_STATUS_PRSNL_ID",
      "DATA_DT_TM", "UPDT_ID", "UPDT_TASK", "UPDT_DT_TM", "UPDT_APPLCTX",
      "UPDT_CNT"))
       tables_data->qual[i].column_list[ccnt].column_status_flag = 0
      ELSEIF (((dcd.unique_ident_ind=1) OR (((dcd.merge_delete_ind=1) OR (dcd.defining_attribute_ind=
      1)) )) )
       tables_data->qual[i].column_list[ccnt].column_status_flag = 1
      ELSEIF (dac.column_name IN ("BEGIN_EFFECTIVE_DT_TM", "BEGIN_EFF_DT_TM", "BEG_EFFECTIVE_DT_TM",
      "BEG_EFFECTIVE_UTC_DT_TM", "BEG_EFF_DT_TM",
      "CNTRCT_BEG_EFF_DT_TM", "PRSNL_BEG_EFF_DT_TM", "END_EFFECTIVE_DT_TM",
      "PRSNL_END_EFFECTIVE_DT_TM", "END_EFFECTIVE_UTC_DT_TM",
      "END_EFF_DT_TM", "CNTRCT_EFF_DT_TM"))
       tables_data->qual[i].column_list[ccnt].column_status_flag = 1
      ELSE
       tables_data->qual[i].column_list[ccnt].column_status_flag = 8
      ENDIF
     ELSE
      tables_data->qual[i].column_list[index].data_type = dac.data_type
      IF (((dac.data_type="NUMBER") OR (dac.data_type="FLOAT")) )
       tables_data->qual[i].column_list[index].data_length = 12
      ELSEIF (dac.data_type="DATE")
       tables_data->qual[i].column_list[index].data_length = 20
      ELSE
       tables_data->qual[i].column_list[index].data_length = dac.data_length
      ENDIF
      tables_data->qual[i].column_list[index].unique_ident_ind = dcd.unique_ident_ind, tables_data->
      qual[i].column_list[index].merge_delete_ind = dcd.merge_delete_ind, tables_data->qual[i].
      column_list[index].defining_attribute_ind = dcd.defining_attribute_ind
     ENDIF
    FOOT REPORT
     ccnt = size(tables_data->qual[i].column_list,5), tables_data->qual[i].column_cnt = ccnt
     IF ((tables_data->qual[i].column_cnt > tables_data->max_column_cnt))
      tables_data->max_column_cnt = tables_data->qual[i].column_cnt
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->eproc = concat("Error in gather column data for ",tables_data->qual[i].table_name,
     ": ",dm_err->emsg)
    GO TO exit_program
   ENDIF
   SELECT INTO "NL:"
    FROM dm_refchg_attribute d
    WHERE (d.table_name=tables_data->qual[i].table_name)
     AND d.attribute_name IN ("BEG_EFFECTIVE COLUMN_NAME_IND", " END_EFFECTIVE COLUMN_NAME_IND")
     AND d.attribute_value=1
    DETAIL
     index = locateval(inum,1,size(tables_data->qual[i].column_list,5),d.column_name,tables_data->
      qual[i].column_list[inum].column_name)
     IF (index > 0)
      tables_data->qual[i].column_list[index].column_status_flag = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->eproc = concat("Error in gather column data for ",tables_data->qual[i].table_name,
     ": ",dm_err->emsg)
    GO TO exit_program
   ENDIF
   SELECT
    IF (i_admin_ind=1)INTO "nl:"
     FROM dm_adm_columns dac,
      dm_rdds_col_doc dcd
     WHERE (dac.table_name=tables_data->qual[i].table_name)
      AND (dcd.table_name=tables_data->qual[i].table_name)
      AND dcd.column_name=dac.column_name
      AND (dac.schema_date=
     (SELECT
      max(dat.schema_date)
      FROM dm_adm_tables dat
      WHERE (dat.table_name=tables_data->qual[i].table_name)))
      AND  EXISTS (
     (SELECT
      "x"
      FROM dm_adm_index_columns dic
      WHERE dic.table_name=dac.table_name
       AND dic.column_name=dac.column_name
       AND dic.schema_date=dac.schema_date))
      AND ((dac.virtual_column="NO") OR (dac.virtual_column = null))
      AND  NOT ( EXISTS (
     (SELECT
      "x"
      FROM dm_info di
      WHERE di.info_domain="RDDS IGNORE COL LIST:*"
       AND sqlpassthru(" dac.column_name like di.info_name and dac.table_name like di.info_char"))))
    ELSE INTO "nl:"
     FROM user_tab_cols dac,
      dm_columns_doc_local dcd
     WHERE (dac.table_name=tables_data->qual[i].table_name)
      AND (dcd.table_name=tables_data->qual[i].table_name)
      AND dcd.column_name=dac.column_name
      AND dac.column_name IN (
     (SELECT
      dic.column_name
      FROM user_ind_columns dic
      WHERE (dic.table_name=tables_data->qual[i].table_name)))
      AND dac.virtual_column="NO"
      AND dac.hidden_column="NO"
      AND  NOT ( EXISTS (
     (SELECT
      "x"
      FROM dm_info di
      WHERE di.info_domain="RDDS IGNORE COL LIST:*"
       AND sqlpassthru(" dac.column_name like di.info_name and dac.table_name like di.info_char"))))
    ENDIF
    HEAD REPORT
     ccnt = size(tables_data->qual[i].column_list,5)
    DETAIL
     index = locateval(inum,1,size(tables_data->qual[i].column_list,5),dac.column_name,tables_data->
      qual[i].column_list[inum].column_name)
     IF (index=0)
      ccnt = (ccnt+ 1), stat = alterlist(tables_data->qual[i].column_list,ccnt), tables_data->qual[i]
      .column_list[ccnt].column_name = dac.column_name,
      tables_data->qual[i].column_list[ccnt].parm_nbr = ccnt, tables_data->qual[i].column_list[ccnt].
      data_type = dac.data_type
      IF (((dac.data_type="NUMBER") OR (dac.data_type="FLOAT")) )
       tables_data->qual[i].column_list[ccnt].data_length = 12
      ELSEIF (dac.data_type="DATE")
       tables_data->qual[i].column_list[ccnt].data_length = 20
      ELSE
       tables_data->qual[i].column_list[ccnt].data_length = dac.data_length
      ENDIF
      tables_data->qual[i].column_list[ccnt].unique_ident_ind = dcd.unique_ident_ind, tables_data->
      qual[i].column_list[ccnt].merge_delete_ind = dcd.merge_delete_ind, tables_data->qual[i].
      column_list[ccnt].defining_attribute_ind = dcd.defining_attribute_ind
      IF ((tables_data->qual[i].table_status_flag=1))
       tables_data->qual[i].column_list[ccnt].column_status_flag = 6
      ELSEIF (((dac.data_type="LONG") OR (((dac.data_type="LONG RAW") OR (dac.data_type="*LOB")) )) )
       tables_data->qual[i].column_list[ccnt].column_status_flag = 5
      ELSEIF (dac.column_name="*NLS")
       tables_data->qual[i].column_list[ccnt].column_status_flag = 4
      ELSE
       tables_data->qual[i].column_list[ccnt].column_status_flag = 7
      ENDIF
     ELSE
      IF (((dac.data_type="NUMBER") OR (dac.data_type="FLOAT")) )
       tables_data->qual[i].column_list[index].data_length = 12
      ELSEIF (dac.data_type="DATE")
       tables_data->qual[i].column_list[index].data_length = 20
      ELSE
       tables_data->qual[i].column_list[index].data_length = dac.data_length
      ENDIF
      tables_data->qual[i].column_list[index].unique_ident_ind = dcd.unique_ident_ind, tables_data->
      qual[i].column_list[index].merge_delete_ind = dcd.merge_delete_ind, tables_data->qual[i].
      column_list[index].defining_attribute_ind = dcd.defining_attribute_ind
      IF ( NOT ((tables_data->qual[i].column_list[index].column_status_flag IN (1, 3, 4, 5, 6))))
       tables_data->qual[i].column_list[index].column_status_flag = 7
      ENDIF
     ENDIF
    FOOT REPORT
     ccnt = size(tables_data->qual[i].column_list,5), tables_data->qual[i].column_cnt = ccnt
     IF ((tables_data->qual[i].column_cnt > tables_data->max_column_cnt))
      tables_data->max_column_cnt = tables_data->qual[i].column_cnt
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->eproc = concat("Error in gather column data for ",tables_data->qual[i].table_name,
     ": ",dm_err->emsg)
    GO TO exit_program
   ENDIF
   SET dm_err->eproc = "Determine UI, MD, and DA columns to add to list..."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET itotcolstrlen = 0
   SET parm_nbr_cnt = 0
   FOR (y = 1 TO tables_data->qual[i].column_cnt)
     IF ((tables_data->qual[i].column_list[y].column_status_flag=1))
      SET icurcolstrlen = ((tables_data->qual[i].column_list[y].data_length+ (2 * textlen(tables_data
       ->qual[i].column_list[y].column_name)))+ 5)
      SET itotcolstrlen = (itotcolstrlen+ icurcolstrlen)
      IF (itotcolstrlen > imaxlength)
       SET tables_data->qual[i].column_list[y].column_status_flag = 2
       SET itotcolstrlen = (itotcolstrlen - icurcolstrlen)
      ELSE
       SET parm_nbr_cnt = (parm_nbr_cnt+ 1)
       SET tables_data->qual[i].column_list[y].parm_nbr = parm_nbr_cnt
      ENDIF
     ENDIF
   ENDFOR
   SET dm_err->eproc = "Determine all indexed column to add to list..."
   CALL disp_msg(" ",dm_err->logfile,0)
   FOR (y = 1 TO tables_data->qual[i].column_cnt)
     IF ((tables_data->qual[i].column_list[y].column_status_flag=7))
      SET icurcolstrlen = ((tables_data->qual[i].column_list[y].data_length+ (2 * textlen(tables_data
       ->qual[i].column_list[y].column_name)))+ 5)
      SET itotcolstrlen = (itotcolstrlen+ icurcolstrlen)
      IF (itotcolstrlen > imaxlength)
       SET tables_data->qual[i].column_list[y].column_status_flag = 2
       SET itotcolstrlen = (itotcolstrlen - icurcolstrlen)
      ELSE
       SET tables_data->qual[i].column_list[y].column_status_flag = 1
       SET parm_nbr_cnt = (parm_nbr_cnt+ 1)
       SET tables_data->qual[i].column_list[y].parm_nbr = parm_nbr_cnt
      ENDIF
     ENDIF
   ENDFOR
   SET dm_err->eproc = "Determine other columns to add to list..."
   CALL disp_msg(" ",dm_err->logfile,0)
   FOR (y = 1 TO tables_data->qual[i].column_cnt)
     IF ((tables_data->qual[i].column_list[y].column_status_flag=8))
      SET icurcolstrlen = ((tables_data->qual[i].column_list[y].data_length+ (2 * textlen(tables_data
       ->qual[i].column_list[y].column_name)))+ 5)
      SET itotcolstrlen = (itotcolstrlen+ icurcolstrlen)
      IF (itotcolstrlen > imaxlength)
       SET tables_data->qual[i].column_list[y].column_status_flag = 2
       SET itotcolstrlen = (itotcolstrlen - icurcolstrlen)
      ELSE
       SET tables_data->qual[i].column_list[y].column_status_flag = 1
       SET parm_nbr_cnt = (parm_nbr_cnt+ 1)
       SET tables_data->qual[i].column_list[y].parm_nbr = parm_nbr_cnt
      ENDIF
     ENDIF
   ENDFOR
   SET dm_err->eproc = "Determine all other columns to add to list..."
   CALL disp_msg(" ",dm_err->logfile,0)
   FOR (y = 1 TO tables_data->qual[i].column_cnt)
     IF ((tables_data->qual[i].column_list[y].column_status_flag=0))
      SET icurcolstrlen = ((tables_data->qual[i].column_list[y].data_length+ (2 * textlen(tables_data
       ->qual[i].column_list[y].column_name)))+ 5)
      SET itotcolstrlen = (itotcolstrlen+ icurcolstrlen)
      IF (itotcolstrlen > imaxlength)
       SET tables_data->qual[i].column_list[y].column_status_flag = 2
       SET itotcolstrlen = (itotcolstrlen - icurcolstrlen)
      ELSE
       SET tables_data->qual[i].column_list[y].column_status_flag = 1
       SET parm_nbr_cnt = (parm_nbr_cnt+ 1)
       SET tables_data->qual[i].column_list[y].parm_nbr = parm_nbr_cnt
      ENDIF
     ENDIF
   ENDFOR
   IF (i_admin_ind=0)
    SET dm_err->eproc = concat("Clean-Up DM_COLSTRING_PARM table for ",tables_data->qual[i].
     table_name)
    CALL disp_msg(" ",dm_err->logfile,0)
    SET ideletecnt = 0
    DELETE  FROM dm_colstring_parm dcp
     WHERE (dcp.table_name=tables_data->qual[i].table_name)
     WITH nocounter
    ;end delete
    SET ideletecnt = curqual
    IF (check_error(dm_err->eproc) != 0)
     SET dm_err->eproc = concat("Error cleaning up rows from DM_COLSTRING_PARM table: ",dm_err->emsg)
     ROLLBACK
     GO TO exit_program
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Insert colstring data, for ",tables_data->qual[i].table_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   SET iinsertcnt = 0
   IF (i_admin_ind=1)
    INSERT  FROM dm_adm_colstring_parm dcp,
      (dummyt d  WITH seq = size(tables_data->qual[i].column_list,5))
     SET dcp.table_name = tables_data->qual[i].table_name, dcp.parm_nbr = tables_data->qual[i].
      column_list[d.seq].parm_nbr, dcp.column_name = tables_data->qual[i].column_list[d.seq].
      column_name,
      dcp.updt_id = reqinfo->updt_id, dcp.updt_dt_tm = cnvtdatetime(curdate,curtime3), dcp.updt_task
       = reqinfo->updt_task,
      dcp.updt_applctx = reqinfo->updt_applctx, dcp.updt_cnt = 0
     PLAN (d
      WHERE (tables_data->qual[i].column_list[d.seq].column_status_flag=1)
       AND (tables_data->qual[i].column_list[d.seq].parm_nbr > 0))
      JOIN (dcp)
     WITH nocounter
    ;end insert
   ELSE
    INSERT  FROM dm_colstring_parm dcp,
      (dummyt d  WITH seq = size(tables_data->qual[i].column_list,5))
     SET dcp.table_name = tables_data->qual[i].table_name, dcp.parm_nbr = tables_data->qual[i].
      column_list[d.seq].parm_nbr, dcp.column_name = tables_data->qual[i].column_list[d.seq].
      column_name,
      dcp.data_type = tables_data->qual[i].column_list[d.seq].data_type, dcp.updt_id = reqinfo->
      updt_id, dcp.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      dcp.updt_task = reqinfo->updt_task, dcp.updt_applctx = reqinfo->updt_applctx, dcp.updt_cnt = 0
     PLAN (d
      WHERE (tables_data->qual[i].column_list[d.seq].column_status_flag=1)
       AND (tables_data->qual[i].column_list[d.seq].parm_nbr > 0))
      JOIN (dcp)
     WITH nocounter
    ;end insert
   ENDIF
   SET iinsertcnt = curqual
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->eproc = concat("Error inserting colstring data: ",dm_err->emsg)
    ROLLBACK
    GO TO exit_program
   ELSE
    SET dm_err->eproc = build("Inserted: ",iinsertcnt," rows of colstring data, for: ",tables_data->
     qual[i].table_name)
    CALL disp_msg(" ",dm_err->logfile,0)
    COMMIT
   ENDIF
   SET itotinsertcnt = (itotinsertcnt+ iinsertcnt)
 ENDFOR
 IF ((dm_err->debug_flag >= 1))
  SET dm_err->eproc = build("Total Rows Deleted: ",ideletecnt)
  CALL disp_msg(" ",dm_err->logfile,0)
  SET dm_err->eproc = build("Total Rows Inserted: ",itotinsertcnt)
  CALL disp_msg(" ",dm_err->logfile,0)
 ENDIF
 IF (i_admin_ind=1)
  SET ms_report_filename = concat(ms_report_filename,cnvtstring(cnvtdatetime(curdate,curtime3)))
  SELECT INTO value(concat("ccluserdir:",ms_report_filename))
   FROM (dummyt d  WITH seq = value(tables_data->table_cnt)),
    (dummyt d1  WITH seq = value(tables_data->max_column_cnt))
   PLAN (d)
    JOIN (d1
    WHERE d1.seq <= size(tables_data->qual[d.seq].column_list,5)
     AND (tables_data->qual[d.seq].column_list[d1.seq].column_status_flag != 1))
   HEAD REPORT
    line_d = fillstring(130,"="), line_s = fillstring(53,"-"), blank_line = fillstring(130," "),
    MACRO (col_heads)
     col 1, "EXCLUSION REASON", col 30,
     "TABLE NAME", col 75, "COLUMN NAME",
     row + 1, line_d
    ENDMACRO
    , row 0,
    CALL center("* * * COLUMN EXCLUSION REPORT * * *",1,130),
    row + 2, col 0, "Report Date: ",
    curdate"MM/DD/YYYY;;D", col 112, "Report Time: ",
    curtime3"HH:MM;;M", row + 3, col 0,
    "Exclusion Reason Code Description", row + 1, line_s,
    row + 1, col 1, " 2 = Column could not fit into space available ",
    row + 1, col 1, " 3 = Listed in exclusion list ",
    row + 1, col 1, " 4 = Column name ends with 'NLS' ",
    row + 1, col 1, " 5 = Data type is a 'LONG', 'LONG_BLOB', or '*LOB' ",
    row + 1, col 1, " 6 = Table belongs to code set 4001912 ",
    row + 1, line_d, row + 2
   HEAD PAGE
    row + 1, col 0, "Page: ",
    col 7, curpage"###;L", row + 2,
    col_heads, row + 2
   DETAIL
    IF (((row+ 1) >= 57))
     BREAK
    ENDIF
    col 1, tables_data->qual[d.seq].column_list[d1.seq].column_status_flag"#;L", col 30,
    tables_data->qual[d.seq].table_name, col 75, tables_data->qual[d.seq].column_list[d1.seq].
    column_name,
    row + 1
   FOOT PAGE
    row 57, row + 1
   FOOT REPORT
    row + 1, row- (9), col 0,
    blank_line, row + 2, col 0,
    blank_line, row + 1, col 0,
    blank_line, row + 5,
    CALL center("* * * END OF REPORT * * *",1,130),
    row + 1
   WITH nocounter, maxcol = 2100, format = variable,
    formfeed = none
  ;end select
  IF (check_error(dm_err->eproc) != 0)
   SET dm_err->eproc = concat("Error in gathering report information",dm_err->emsg)
   GO TO exit_program
  ENDIF
  SET dm_err->eproc = "Changing report file permissions..."
  CALL disp_msg(" ",dm_err->logfile,0)
  SET ms_report_filename = concat(ms_report_filename,".dat")
  IF (cursys2="AXP")
   IF (findfile(ms_report_filename)=1)
    CALL dm2_push_dcl(concat("set file/prot=(s:RWED,o:RWED,g:RWED,w:RWED) ccluserdir:",
      ms_report_filename))
   ELSE
    SET dm_err->err_ind = 1
    CALL disp_msg("Report does not exist, so file permissions could not be set.",dm_err->logfile,1)
    GO TO exit_program
   ENDIF
  ENDIF
  IF (cursys2="AIX")
   IF (findfile(ms_report_filename)=1)
    CALL dm2_push_dcl(concat("chmod 777 $CCLUSERDIR/",ms_report_filename))
   ELSE
    SET dm_err->err_ind = 1
    CALL disp_msg("Report does not exist, so file permissions could not be set.",dm_err->logfile,1)
    GO TO exit_program
   ENDIF
  ENDIF
  IF (cursys2="HPX")
   IF (findfile(ms_report_filename)=1)
    CALL dm2_push_dcl(concat("chmod 777 $CCLUSERDIR/",ms_report_filename))
   ELSE
    SET dm_err->err_ind = 1
    CALL disp_msg("Report does not exist, so file permissions could not be set.",dm_err->logfile,1)
    GO TO exit_program
   ENDIF
  ENDIF
  IF (cursys2="LNX")
   IF (findfile(ms_report_filename)=1)
    CALL dm2_push_dcl(concat("chmod 777 $CCLUSERDIR/",ms_report_filename))
   ELSE
    SET dm_err->err_ind = 1
    CALL disp_msg("Report does not exist, so file permissions could not be set.",dm_err->logfile,1)
    GO TO exit_program
   ENDIF
  ENDIF
  IF (check_error(dm_err->eproc)=1)
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
 ENDIF
 IF ((dm_err->debug_flag >= 2))
  CALL echorecord(tables_data)
 ENDIF
#exit_program
 IF ((dm_err->err_ind=0))
  SET dm_err->eproc = concat("DM_RMC_COLSTRING_VALUES completed successfully.")
  CALL final_disp_msg(dm_err->logfile)
 ELSE
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
 ENDIF
 FREE RECORD tables_data
END GO
