CREATE PROGRAM dm_rmc_bookmark_begin:dba
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
 DECLARE regen_trigs(null) = i4
 DECLARE check_open_event(cur_env_id=f8,paired_env_id=f8) = i4
 SUBROUTINE regen_trigs(null)
   DECLARE rt_err_flg = i2 WITH protect, noconstant(0)
   FREE RECORD invalid
   RECORD invalid(
     1 data[*]
       2 name = vc
   )
   SET dm_err->eproc = "Regenerating triggers..."
   CALL disp_msg("",dm_err->logfile,0)
   EXECUTE dm2_add_refchg_log_triggers
   SET dm_err->eproc = "RECOMPILING INVALID TRIGGERS"
   SELECT INTO "NL:"
    FROM dm2_user_objects d1
    WHERE d1.object_name="REFCHG*"
     AND d1.object_type="TRIGGER"
     AND d1.status != "VALID"
     AND d1.object_name != "REFCHG*MC*"
    HEAD REPORT
     trig_cnt = 0
    DETAIL
     trig_cnt = (trig_cnt+ 1)
     IF (mod(trig_cnt,10)=1)
      stat = alterlist(invalid->data,(trig_cnt+ 9))
     ENDIF
     invalid->data[trig_cnt].name = d1.object_name
    FOOT REPORT
     stat = alterlist(invalid->data,trig_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->emsg = "Error checking invalid triggers"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET rt_err_flg = 1
    SET dm_err->err_ind = 1
    ROLLBACK
    RETURN(rt_err_flg)
   ENDIF
   FOR (t_ndx = 1 TO size(invalid->data,5))
     CALL parser(concat("RDB ASIS(^alter trigger ",invalid->data[t_ndx].name," compile^) go"))
   ENDFOR
   SELECT INTO "NL:"
    FROM dm2_user_objects d1
    WHERE d1.object_name="REFCHG*"
     AND d1.object_type="TRIGGER"
     AND d1.status != "VALID"
     AND d1.object_name != "REFCHG*MC*"
    DETAIL
     v_trigger_name = d1.object_name
    WITH nocounter, maxqual(d1,1)
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->emsg = "Error compiling invalid triggers"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET rt_err_flg = 1
    SET dm_err->err_ind = 1
    ROLLBACK
    RETURN(rt_err_flg)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = "Triggers regenerated successfully."
    SET rt_err_flg = 0
   ELSE
    SET dm_err->eproc = "Error regenerating RDDS related triggers."
    SET rt_err_flg = 1
    RETURN(rt_err_flg)
   ENDIF
   RETURN(rt_err_flg)
 END ;Subroutine
 SUBROUTINE check_open_event(cur_env_id,paired_env_id)
   DECLARE coe_event_flg = i4 WITH protect
   IF (cur_env_id > 0
    AND paired_env_id > 0)
    SET dm_err->eproc = "Checking open events for environment pair."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "NL:"
     FROM dm_rdds_event_log drel
     WHERE drel.rdds_event="Begin Reference Data Sync"
      AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
      AND drel.cur_environment_id=cur_env_id
      AND drel.paired_environment_id=paired_env_id
      AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
     (SELECT
      cur_environment_id, paired_environment_id, event_reason
      FROM dm_rdds_event_log
      WHERE cur_environment_id=cur_env_id
       AND paired_environment_id=paired_env_id
       AND rdds_event="End Reference Data Sync"
       AND rdds_event_key="ENDREFERENCEDATASYNC")))
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(coe_event_flg)
    ENDIF
    IF (curqual=0)
     SET dm_err->eproc = "Determining reverse open events for environment pair."
     SELECT INTO "NL:"
      FROM dm_rdds_event_log drel
      WHERE drel.rdds_event="Begin Reference Data Sync"
       AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
       AND drel.cur_environment_id=paired_env_id
       AND drel.paired_environment_id=cur_env_id
       AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
      (SELECT
       cur_environment_id, paired_environment_id, event_reason
       FROM dm_rdds_event_log
       WHERE cur_environment_id=paired_env_id
        AND paired_environment_id=cur_env_id
        AND rdds_event="End Reference Data Sync"
        AND rdds_event_key="ENDREFERENCEDATASYNC")))
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(coe_event_flg)
     ENDIF
     IF (curqual > 0)
      SET coe_event_flg = 2
     ENDIF
    ELSE
     SET coe_event_flg = 1
    ENDIF
   ENDIF
   IF (paired_env_id=0)
    SET dm_err->eproc = "Determining open events for current environment."
    SELECT INTO "NL:"
     FROM dm_rdds_event_log drel
     WHERE drel.rdds_event="Begin Reference Data Sync"
      AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
      AND drel.cur_environment_id=cur_env_id
      AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
     (SELECT
      cur_environment_id, paired_environment_id, event_reason
      FROM dm_rdds_event_log
      WHERE cur_environment_id=cur_env_id
       AND rdds_event="End Reference Data Sync"
       AND rdds_event_key="ENDREFERENCEDATASYNC")))
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(coe_event_flg)
    ENDIF
    IF (curqual > 0)
     SET coe_event_flg = 1
    ENDIF
   ENDIF
   RETURN(coe_event_flg)
 END ;Subroutine
 DECLARE cutover_tab_name(i_normal_tab_name=vc,i_table_suffix=vc) = vc
 IF ((validate(table_data->counter,- (1))=- (1)))
  FREE RECORD table_data
  RECORD table_data(
    1 counter = i4
    1 qual[*]
      2 table_name = vc
      2 table_suffix = vc
  ) WITH protect
 ENDIF
 SUBROUTINE cutover_tab_name(i_normal_tab_name,i_table_suffix)
   DECLARE s_new_tab_name = vc WITH protect
   DECLARE s_tab_suffix = vc WITH protect
   DECLARE s_lv_num = i4 WITH protect
   DECLARE s_lv_pos = i4 WITH protect
   IF (i_table_suffix > " ")
    SET s_tab_suffix = i_table_suffix
    SET s_new_tab_name = concat(trim(substring(1,14,i_normal_tab_name)),s_tab_suffix,"$R")
   ELSE
    SET s_lv_pos = locateval(s_lv_num,1,size(table_data->qual,5),i_normal_tab_name,table_data->qual[
     s_lv_num].table_name)
    IF (s_lv_pos > 0)
     SET s_tab_suffix = table_data->qual[s_lv_pos].table_suffix
     SET s_new_tab_name = concat(trim(substring(1,14,i_normal_tab_name)),s_tab_suffix,"$R")
    ELSE
     SELECT INTO "nl:"
      FROM dm_rdds_tbl_doc dtd
      WHERE dtd.table_name=i_normal_tab_name
       AND dtd.table_name=dtd.full_table_name
      HEAD REPORT
       stat = alterlist(table_data->qual,(table_data->counter+ 1)), table_data->counter = size(
        table_data->qual,5)
      DETAIL
       table_data->qual[table_data->counter].table_name = dtd.table_name, table_data->qual[table_data
       ->counter].table_suffix = dtd.table_suffix, s_new_tab_name = concat(trim(substring(1,14,
          i_normal_tab_name)),dtd.table_suffix,"$R")
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   RETURN(s_new_tab_name)
 END ;Subroutine
 DECLARE add_tracking_row(i_source_id=f8,i_refchg_type=vc,i_refchg_status=vc) = null
 DECLARE delete_tracking_row(null) = null
 DECLARE move_long(i_from_table=vc,i_to_table=vc,i_column_name=vc,i_pk_str=vc,i_source_env_id=f8,
  i_status_flag=i4) = null
 DECLARE get_reg_tab_name(i_r_tab_name=vc,i_suffix=vc) = vc
 DECLARE dcc_find_val(i_delim_str=vc,i_delim_val=vc,i_val_rec=vc(ref)) = i2
 DECLARE move_circ_long(i_from_table=vc,i_from_rtable=vc,i_from_pk=vc,i_from_prev_pk=vc,i_from_fk=vc,
  i_from_pe_col=vc,i_circ_table=vc,i_circ_column_name=vc,i_circ_fk_col=vc,i_circ_long_col=vc,
  i_source_env_id=f8,i_status_flag=i4) = null
 IF ((validate(table_data->counter,- (1))=- (1)))
  FREE RECORD table_data
  RECORD table_data(
    1 counter = i4
    1 qual[*]
      2 table_name = vc
      2 table_suffix = vc
  ) WITH protect
 ENDIF
 SUBROUTINE add_tracking_row(i_source_id,i_refchg_type,i_refchg_status)
   DECLARE var_process = vc
   DECLARE var_sid = f8
   DECLARE var_serial_num = f8
   SELECT INTO "nl:"
    process, sid, serial#
    FROM v$session vs
    WHERE audsid=cnvtreal(currdbhandle)
    DETAIL
     var_process = vs.process, var_sid = vs.sid, var_serial_num = vs.serial#
    WITH maxqual(vs,1)
   ;end select
   UPDATE  FROM dm_refchg_process
    SET refchg_type = i_refchg_type, refchg_status = i_refchg_status, last_action_dt_tm = sysdate,
     updt_cnt = (updt_cnt+ 1), updt_id = reqinfo->updt_id, updt_applctx = reqinfo->updt_applctx,
     updt_task = reqinfo->updt_task, updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE rdbhandle_value=cnvtreal(currdbhandle)
   ;end update
   COMMIT
   IF (curqual=0)
    INSERT  FROM dm_refchg_process
     SET dm_refchg_process_id = seq(dm_clinical_seq,nextval), env_source_id = i_source_id,
      rdbhandle_value = cnvtreal(currdbhandle),
      process_name = var_process, log_file = dm_err->logfile, last_action_dt_tm = sysdate,
      refchg_type = i_refchg_type, refchg_status = i_refchg_status, updt_cnt = 0,
      updt_id = reqinfo->updt_id, updt_applctx = reqinfo->updt_applctx, updt_task = reqinfo->
      updt_task,
      updt_dt_tm = cnvtdatetime(curdate,curtime3), session_sid = var_sid, serial_number =
      var_serial_num
    ;end insert
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE delete_tracking_row(null)
  DELETE  FROM dm_refchg_process
   WHERE rdbhandle_value=cnvtreal(currdbhandle)
   WITH nocounter
  ;end delete
  COMMIT
 END ;Subroutine
 SUBROUTINE move_long(i_from_table,i_to_table,i_column_name,i_pk_str,i_source_env_id,i_status_flag)
   RECORD long_col(
     1 data[*]
       2 pk_str = vc
       2 long_str = vc
   )
   SET s_rdds_where_iu_str =
   " rdds_delete_ind = 0 and rdds_source_env_id = i_source_env_id and rdds_status_flag = i_status_flag"
   DECLARE long_str = vc
   CALL parser(" select into 'nl:' ",0)
   CALL parser(concat("        bloblen = textlen(l.",trim(i_column_name),")"),0)
   CALL parser(concat("        , pk_str=",i_pk_str),0)
   CALL parser(concat("   from ",trim(i_from_table)," l "),0)
   CALL parser(concat(" where ",s_rdds_where_iu_str),0)
   CALL parser(" head report ",0)
   CALL parser("   outbuf = fillstring(32767,' ') ",0)
   CALL parser("   long_cnt = 0 ",0)
   CALL parser(" detail ",0)
   CALL parser("   retlen = 0 ",0)
   CALL parser("   offset = 0 ",0)
   CALL parser("   long_str = ' ' ",0)
   CALL parser(concat("   retlen = blobget(outbuf,offset,l.",trim(i_column_name),") "),0)
   CALL parser("   while (retlen > 0) ",0)
   CALL parser("     if (long_str = ' ') ",0)
   CALL parser("       long_str = notrim(outbuf) ",0)
   CALL parser("     else ",0)
   CALL parser("       long_str = notrim(concat(long_str,substring(1,retlen,outbuf))) ",0)
   CALL parser("     endif ",0)
   CALL parser("     offset = offset + retlen ",0)
   CALL parser(concat("     retlen = blobget(outbuf,offset,l.",trim(i_column_name),") "),0)
   CALL parser("   endwhile ",0)
   CALL parser("   long_cnt=long_cnt + 1",0)
   CALL parser("   if (mod(long_cnt,50) = 1)",0)
   CALL parser("     stat = alterlist(long_col->data,long_cnt+49)",0)
   CALL parser("   endif",0)
   CALL parser("   long_col->data[long_cnt].pk_str = pk_str",0)
   CALL parser("   long_col->data[long_cnt].long_str = trim(long_str,5)",0)
   CALL parser(" foot report",0)
   CALL parser("   stat = alterlist(long_col->data,long_cnt)",0)
   CALL parser(" with nocounter,rdbarrayfetch=1 ",0)
   CALL parser(" go",1)
   FOR (lc_ndx = 1 TO size(long_col->data,5))
     CALL parser(concat("update from ",trim(i_to_table)," set ",trim(i_column_name)),0)
     CALL parser("= long_col->data[lc_ndx].long_str where ",0)
     CALL parser(long_col->data[lc_ndx].pk_str,0)
     CALL parser(" go",1)
   ENDFOR
 END ;Subroutine
 SUBROUTINE get_reg_tab_name(i_r_tab_name,i_suffix)
   DECLARE s_suffix = vc
   DECLARE s_tab_name = vc
   IF (i_suffix > " ")
    SET s_suffix = i_suffix
   ELSE
    SET s_suffix = substring((size(i_r_tab_name) - 5),4,i_r_tab_name)
   ENDIF
   SELECT INTO "nl:"
    dtd.table_name
    FROM dm_rdds_tbl_doc dtd
    WHERE dtd.table_suffix=s_suffix
     AND dtd.table_name=dtd.full_table_name
    DETAIL
     s_tab_name = dtd.table_name
    WITH nocounter
   ;end select
   RETURN(s_tab_name)
 END ;Subroutine
 SUBROUTINE dcc_find_val(i_delim_str,i_delim_val,i_val_rec)
   DECLARE dfv_temp_delim_str = vc WITH constant(concat(i_delim_val,i_delim_str,i_delim_val)),
   protect
   DECLARE dfv_temp_str = vc WITH noconstant(""), protect
   DECLARE dfv_return = i2 WITH noconstant(0), protect
   IF (size(trim(i_delim_str),1) > 0)
    FOR (i = 1 TO i_val_rec->len)
      IF (size(trim(i_val_rec->values[i].str),1) > 0)
       SET dfv_temp_str = concat(i_delim_val,i_val_rec->values[i].str,i_delim_val)
       IF (findstring(dfv_temp_str,dfv_temp_delim_str) > 0)
        SET dfv_return = 1
        RETURN(dfv_return)
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   RETURN(dfv_return)
 END ;Subroutine
 SUBROUTINE move_circ_long(i_from_table,i_from_rtable,i_from_pk,i_from_prev_pk,i_from_fk,
  i_from_pe_col,i_circ_table,i_circ_column_name,i_circ_fk_col,i_circ_long_col,i_source_env_id,
  i_status_flag)
   DECLARE mcl_rdds_iu_str = vc WITH protect, noconstant("")
   DECLARE move_circ_lc_ndx = i4 WITH protect, noconstant(0)
   DECLARE move_circ_long_str = vc WITH protect, noconstant("")
   DECLARE evaluate_pe_name() = c255
   RECORD long_col(
     1 data[*]
       2 long_pk = f8
       2 long_col_fk = f8
       2 long_str = vc
   )
   SET mcl_rdds_iu_str =
   " r.rdds_delete_ind = 0 and r.rdds_source_env_id = i_source_env_id and r.rdds_status_flag = i_status_flag"
   CALL parser(" select into 'nl:' ",0)
   CALL parser(concat("        bloblen = textlen(l.",trim(i_circ_long_col),")"),0)
   CALL parser(concat("   from ",trim(i_circ_table)," l, ",trim(i_from_table)," t, "),0)
   CALL parser(concat("         ",trim(i_from_rtable)," r "),0)
   CALL parser(concat(" where l.",trim(i_circ_column_name)," = t.",i_from_fk),0)
   CALL parser(concat("    and t.",i_from_pk," = r.",i_from_prev_pk),0)
   CALL parser(concat("    and r.",i_from_pk," != r.",i_from_prev_pk),0)
   IF (i_from_pe_col > "")
    CALL parser(concat("    and evaluate_pe_name('",i_from_table,"', '",i_from_fk,"','",
      i_from_pe_col,"', r.",i_from_pe_col,") = '",i_circ_table,
      "'"),0)
   ENDIF
   CALL parser(concat("    and l.",i_circ_column_name," > 0"),0)
   CALL parser(concat("    and ",mcl_rdds_iu_str),0)
   CALL parser(" head report ",0)
   CALL parser("   outbuf = fillstring(32767,' ') ",0)
   CALL parser("   long_cnt = 0 ",0)
   CALL parser(" detail ",0)
   CALL parser("   retlen = 0 ",0)
   CALL parser("   offset = 0 ",0)
   CALL parser("   move_circ_long_str = ' ' ",0)
   CALL parser(concat("   retlen = blobget(outbuf,offset,l.",trim(i_circ_long_col),") "),0)
   CALL parser("   while (retlen > 0) ",0)
   CALL parser("     if (move_circ_long_str = ' ') ",0)
   CALL parser("       move_circ_long_str = notrim(outbuf) ",0)
   CALL parser("     else ",0)
   CALL parser(
    "       move_circ_long_str = notrim(concat(move_circ_long_str,substring(1,retlen,outbuf))) ",0)
   CALL parser("     endif ",0)
   CALL parser("     offset = offset + retlen ",0)
   CALL parser(concat("     retlen = blobget(outbuf,offset,l.",trim(i_circ_long_col),") "),0)
   CALL parser("   endwhile ",0)
   CALL parser("   long_cnt=long_cnt + 1",0)
   CALL parser("   if (mod(long_cnt,50) = 1)",0)
   CALL parser("     stat = alterlist(long_col->data,long_cnt+49)",0)
   CALL parser("   endif",0)
   CALL parser(concat("   long_col->data[long_cnt].long_pk = t.",i_from_pk),0)
   CALL parser("   long_col->data[long_cnt].long_str = trim(move_circ_long_str,5)",0)
   CALL parser(concat("   long_col->data[long_cnt].long_col_fk = r.",i_from_fk),0)
   CALL parser(" foot report",0)
   CALL parser("   stat = alterlist(long_col->data,long_cnt)",0)
   CALL parser(" with nocounter,rdbarrayfetch=1 ",0)
   CALL parser(" go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   FOR (move_circ_lc_ndx = 1 TO size(long_col->data,5))
     CALL parser(concat("update from ",trim(i_circ_table)," t set ",trim(i_circ_long_col)),0)
     CALL parser("= long_col->data[move_circ_lc_ndx].long_str where ",0)
     CALL parser(concat("t.",i_circ_column_name," = ",trim(cnvtstring(long_col->data[move_circ_lc_ndx
         ].long_col_fk,20,2))),0)
     CALL parser(" go",1)
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(null)
     ENDIF
   ENDFOR
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
 IF (validate(dm_load_reply->status,"$")="$")
  RECORD dm_load_reply(
    1 status = c1
    1 status_msg = vc
    1 ins_meaning = vc
    1 description = vc
    1 run_time_flag = i4
    1 run_order = i4
    1 ins_table_name = vc
  )
 ENDIF
 IF (validate(dm_load_request->file_name,"-+")="-+")
  RECORD dm_load_request(
    1 file_name = vc
  )
 ENDIF
 IF (validate(dm_run_reply->status,"$")="$")
  RECORD dm_run_reply(
    1 status = c1
    1 status_msg = vc
    1 log_file = vc
    1 ins_meaning = vc
  )
 ENDIF
 IF (validate(dm_run_request->ins_meaning,"-+")="-+")
  RECORD dm_run_request(
    1 ins_meaning = vc
    1 diagnostic_ind = i2
    1 where_clause = vc
  )
 ENDIF
 IF (validate(dm_get_reply->status,"$")="$")
  RECORD dm_get_reply(
    1 status = vc
    1 status_msg = vc
    1 ins_cnt = i4
    1 ins_qual[*]
      2 ins_meaning = vc
      2 ins_status = vc
      2 ins_message = vc
      2 ins_log_file = vc
  )
 ENDIF
 IF ((validate(dm_get_request->run_cnt,- (99))=- (99)))
  RECORD dm_get_request(
    1 run_cnt = i4
    1 table_name = vc
    1 run_qual[*]
      2 run_time_flag = i4
  )
 ENDIF
 DECLARE drrd_get_realm(null) = vc
 SUBROUTINE drrd_get_realm(null)
   DECLARE dgr_env_name = vc WITH protect, noconstant(" ")
   DECLARE dgr_cmd = vc WITH protect, noconstant(" ")
   DECLARE dgr_no_error = i2 WITH protect, noconstant(0)
   DECLARE dgr_domain = vc WITH protect, noconstant(" ")
   SET dm_err->eproc = "Get environment name via environment logical"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (cursys="AXP")
    SET dgr_domain = "-1"
    RETURN(dgr_domain)
   ENDIF
   SET dgr_env_name = cnvtlower(trim(logical("environment")))
   IF ((dm_err->debug_flag > 0))
    SET message = nowindow
    CALL clear(1,1)
    CALL echo(concat("ENVIRONMENT LOGICAL:",dgr_env_name))
   ENDIF
   IF (trim(dgr_env_name) <= " ")
    SET dm_err->emsg = "Environment logical is not valued."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("-1")
   ENDIF
   SET dm_err->eproc = "Checking for domain name in registry"
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dgr_cmd = concat("$cer_exe/lreg -getp \\environment\\",dgr_env_name," Domain")
   SET dm_err->disp_dcl_err_ind = 0
   SET dgr_no_error = dm2_push_dcl(dgr_cmd)
   IF (dgr_no_error=0)
    IF ((dm_err->err_ind=1))
     RETURN("-1")
    ENDIF
   ELSE
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN("-1")
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dm_err)
     CALL pause(3)
    ENDIF
   ENDIF
   IF (((findstring("unable",dm_err->errtext,1,1)) OR ((((dm_err->errtext="")) OR (((findstring(
    "key not found",dm_err->errtext,1,1)) OR (findstring("property not found",dm_err->errtext,1,1)))
   )) )) )
    SET dgr_no_error = 1
    SET dgr_domain = "NOPARMRETURNED"
   ELSE
    SET dgr_domain = dm_err->errtext
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("domain_value: <<",dgr_domain,">>"))
   ENDIF
   IF (dgr_no_error=0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("-1")
   ENDIF
   RETURN(cnvtupper(dgr_domain))
 END ;Subroutine
 DECLARE dmbb_refresh_ind = i2
 DECLARE drbb_oeind = i4
 DECLARE drbb_dcl_ind = i2
 DECLARE drst_event_reason = vc
 DECLARE drbb_block_ind = i2 WITH protect, noconstant(1)
 DECLARE drbb_background_ind = i4 WITH protect, noconstant(0)
 DECLARE drbb_cur_logfile = vc WITH protect, noconstant("")
 DECLARE drbb_nohup_logfile = vc WITH protect, noconstant("")
 DECLARE drbb_execute_str = vc WITH protect, noconstant("")
 DECLARE drbb_dcl_stat = i4 WITH protect, noconstant(0)
 DECLARE drbb_chk_ind = i2 WITH protect, noconstant(0)
 DECLARE drbb_ins_status = vc WITH protect, noconstant("")
 DECLARE drbb_event_name = vc WITH protect, noconstant("")
 DECLARE drbb_domain = vc WITH protect, noconstant("")
 DECLARE drbb_remote_seq = vc WITH protect, noconstant("")
 DECLARE drbb_post_link_name = vc WITH protect, noconstant("")
 FREE RECORD drop_request
 RECORD drop_request(
   1 drop_after_day = i4
 )
 FREE RECORD dclbb_request
 RECORD dclbb_request(
   1 target_id = f8
   1 log_id = f8
 )
 FREE RECORD dclbb_reply
 RECORD dclbb_reply(
   1 realm_value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD drbb_drvc_request
 RECORD drbb_drvc_request(
   1 current_env_id = f8
   1 paired_env_id = f8
 )
 FREE RECORD drbb_drvc_reply
 RECORD drbb_drvc_reply(
   1 target_version_nbr = i4
   1 source_version_nbr = i4
   1 valid_status_ind = i2
   1 message = vc
 )
 FREE RECORD drcso_request
 RECORD drcso_request(
   1 object_name = vc
   1 source_env_id = f8
 )
 FREE RECORD drri_reply
 RECORD drri_reply(
   1 status = c1
   1 message = vc
 )
 FREE RECORD drbb_drccf_request
 RECORD drbb_drccf_request(
   1 source_env_id = f8
   1 target_env_id = f8
 )
 IF (validate(dmda_drbb_request->db_sid,"-1234")="-1234"
  AND ( $6 > 0))
  SET dm_err->err_ind = 1
  CALL disp_msg(
   "Open event process cannot be started at this time since required information has not been gathered",
   dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 FREE RECORD dmd_request
 RECORD dmd_request(
   1 remote_env_id = f8
   1 local_env_id = f8
   1 post_link_name = vc
 )
 SET help = off
 SET validate = off
 SET message = nowindow
 SET width = 132
 SET drbb_drvc_request->paired_env_id =  $1
 SET drbb_drvc_request->current_env_id =  $2
 SET drbb_drccf_request->source_env_id =  $1
 SET drbb_drccf_request->target_env_id =  $2
 SET drbb_event_name =  $3
 SET dmbb_refresh_ind =  $4
 SET drbb_dcl_ind =  $5
 SET drbb_background_ind =  $6
 SET drbb_post_link_name = concat("@MERGE",trim(cnvtstring( $1)),trim(cnvtstring( $2)))
 EXECUTE dm_rdds_version_check  WITH replace("REQUEST","DRBB_DRVC_REQUEST"), replace("REPLY",
  "DRBB_DRVC_REPLY")
 IF (check_error(dm_err->eproc)=1)
  SET dm_err->err_ind = 1
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF ((drbb_drvc_reply->valid_status_ind=0))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat("The program will exit because ",drbb_drvc_reply->message)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Checking for existing open events for current environment."
 SET drbb_oeind = check_open_event(drbb_drvc_request->current_env_id,drbb_drvc_request->paired_env_id
  )
 SET drbb_chk_ind = drtq_check_task_process("OPEN EVENT PROCESS")
 IF (drbb_oeind=1
  AND drbb_chk_ind IN (1, 2))
  SET dm_err->eproc =
  "Open event exists for current environment.  You cannot open a new RDDS event while another event is open."
  CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
  GO TO exit_program
 ELSE
  SET dm_err->eproc = "Checking for adding event process"
  SELECT INTO "NL:"
   FROM dm_refchg_process
   WHERE refchg_type="RDDS OPEN EVENT"
    AND refchg_status="RDDS OPEN EVENT"
    AND (env_source_id=drbb_drvc_request->paired_env_id)
    AND rdbhandle_value IN (
   (SELECT
    audsid
    FROM gv$session))
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
  IF (curqual > 0)
   SET dm_err->err_ind = 1
   SET dm_err->emsg = "Another session is in the process of opening the event."
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ELSE
   SET dm_err->eproc = "Adding opening event process row"
   CALL add_tracking_row(drbb_drvc_request->paired_env_id,"RDDS OPEN EVENT","RDDS OPEN EVENT")
  ENDIF
  DELETE  FROM dm_refchg_stat
   WHERE (source_env_id=drbb_drvc_request->paired_env_id)
    AND stat_type="CUTOVER"
   WITH nocounter
  ;end delete
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
  SET drbb_block_ind = drcr_get_dual_build_config(drbb_drvc_request->paired_env_id,drbb_drvc_request
   ->current_env_id)
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
  IF ((drbb_block_ind=- (1)))
   SET dm_err->err_ind = 1
   SET dm_err->emsg = concat(
    "The program will exit because the dual build configuration for this environment pair ",
    "has not been completed yet.")
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
 ENDIF
 IF (drbb_background_ind=1)
  SET drbb_chk_ind = drtq_check_task_process("OPEN EVENT PROCESS")
  IF (drbb_chk_ind IN (1, 2))
   SET drbb_ret_status = drtq_delete_task_process("OPEN EVENT PROCESS")
   IF (drbb_ret_status="F")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
  ELSEIF (drbb_chk_ind=3)
   SET drbb_ret_status = drtq_reset_task_process("OPEN EVENT PROCESS")
   IF (drbb_ret_status="F")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
  ELSEIF (drbb_chk_ind=4)
   SET dm_err->err_ind = 1
   SET dm_err->emsg = "Due to an event already in progress an additional event cannot be started."
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   SET dmda_drbb_request->dmoe_num_proc = 0
   GO TO exit_program
  ELSE
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
  IF (drbb_chk_ind IN (1, 2))
   SET dm_err->eproc = "Deleting Cutover by Context row"
   DELETE  FROM dm_info di
    WHERE di.info_domain="RDDS CONFIGURATION"
     AND di.info_name="CUTOVER BY CONTEXT"
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF ((dmda_drbb_request->cbc_ind=1))
    SET dm_err->eproc = "Inserting Cutover by Context row"
    INSERT  FROM dm_info di
     SET di.info_domain = "RDDS CONFIGURATION", di.info_name = "CUTOVER BY CONTEXT", di.updt_applctx
       = reqinfo->updt_applctx,
      di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = reqinfo->updt_id, di.updt_task =
      reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
   ENDIF
   COMMIT
   SET stat = initrec(task_info)
   SET drbb_remote_seq = concat(
    "rdb create or replace public synonym RDDS_SOURCE_CLINICAL_SEQ for V500.dm_clinical_seq",
    drbb_post_link_name," go")
   CALL parser(drbb_remote_seq,1)
   SELECT INTO "nl:"
    seq(rdds_source_clinical_seq,nextval)
    FROM dual
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   SET task_info->environment_id = drbb_drvc_request->current_env_id
   SET task_info->process_name = "OPEN EVENT PROCESS"
   SET stat = alterlist(task_info->qual,12)
   SET task_info->total = (task_info->total+ 1)
   SET task_info->qual[task_info->total].task_level = 100
   SET task_info->qual[task_info->total].task_desc = "Creating RDDS translation package"
   SET task_info->qual[task_info->total].task_name = "execute DM_RMC_CREATE_RDDS_XLAT go"
   SET task_info->total = (task_info->total+ 1)
   SET task_info->qual[task_info->total].task_level = 200
   SET task_info->qual[task_info->total].task_desc = "Compiling RDDS translation functions"
   SET task_info->qual[task_info->total].task_name = "execute DM_RDDS_COMPILE_XLAT_FUNCTION go"
   SET task_info->total = (task_info->total+ 1)
   SET task_info->qual[task_info->total].task_level = 300
   SET task_info->qual[task_info->total].task_desc = "Creating new translation functions"
   SET task_info->qual[task_info->total].task_name = replace(replace(
     "execute DM_RMC_CREATE_XLAT_FUNCTION <src_env_id>.0 , <tgt_env_id>.0 go","<src_env_id>",trim(
      cnvtstring(drbb_drvc_request->paired_env_id)),0),"<tgt_env_id>",trim(cnvtstring(
      drbb_drvc_request->current_env_id)),0)
   SET task_info->total = (task_info->total+ 1)
   SET task_info->qual[task_info->total].task_level = 100
   SET task_info->qual[task_info->total].task_desc = "Refresh pl/sql packages"
   SET task_info->qual[task_info->total].task_name = "execute DM_RDDS_METADATA_PLSQL go"
   SET task_info->total = (task_info->total+ 1)
   SET task_info->qual[task_info->total].task_level = 50
   SET task_info->qual[task_info->total].task_desc = "Loading custom pl/sql tables"
   SET task_info->qual[task_info->total].task_name = "execute DM_WRP_SQL_OBJ_LOAD go"
   SET task_info->total = (task_info->total+ 1)
   SET task_info->qual[task_info->total].task_level = 400
   SET task_info->qual[task_info->total].task_desc = "Creating all custom translation functions"
   SET task_info->qual[task_info->total].task_name =
   'execute DM_RMC_CREATE_SQL_OBJECT with replace("REQUEST","DRCO_REQUEST"), replace("REPLY","DRCO_REPLY") go'
   SET task_info->qual[task_info->total].task_request = replace(concat(
     "<REC_DEF>record drco_request (1 object_name = vc 1 source_env_id = f8) go</REC_DEF> ",
     "<VAL_SET>set drco_request->object_name = '*' go</VAL_SET> ",
     "<VAL_SET>set drco_request->source_env_id = <src_env_id>.0 go</VAL_SET>"),"<src_env_id>",trim(
     cnvtstring(drbb_drvc_request->paired_env_id)),0)
   SET task_info->qual[task_info->total].task_reply = concat(
    "<REC_DEF>record drco_reply(1 status_data 2 status = c1) go</REC_DEF> ",
    "<ERR_IND>drco_reply->status_data.status</ERR_IND> ","<ERR_MSG></ERR_MSG> ",
    "<ERR_TYPE>VC</ERR_TYPE> ","<NO_ERR_RESULT>S</NO_ERR_RESULT>")
   SET task_info->total = (task_info->total+ 1)
   SET task_info->qual[task_info->total].task_level = 200
   SET task_info->qual[task_info->total].task_desc = "Refreshing all logging triggers"
   IF ((dmda_drbb_request->dmoe_num_proc > 1))
    SET task_info->qual[task_info->total].task_name = "execute DM_RMC_EXPLODE_TRIG_TASK go"
   ELSE
    SET task_info->qual[task_info->total].task_name =
    'execute DM2_ADD_REFCHG_LOG_TRIGGERS with replace("REQUEST","ENV_REQUEST") go'
    SET task_info->qual[task_info->total].task_request = replace(concat(
      "<REC_DEF>record env_request (1 remote_env_id = f8) go</REC_DEF> ",
      "<VAR_DEF>declare trg_regen_reason = vc go</VAR_DEF> ",
      "<VAL_SET>set env_request->remote_env_id = <src_env_id>.0 go</VAL_SET> ",
      "<VAL_SET>set trg_regen_reason = 'Automatic Regeneration via open event' go</VAL_SET>"),
     "<src_env_id>",trim(cnvtstring(drbb_drvc_request->paired_env_id)),0)
   ENDIF
   SET task_info->total = (task_info->total+ 1)
   SET task_info->qual[task_info->total].task_level = 100
   SET task_info->qual[task_info->total].task_desc = "Refreshing local meta-data"
   SET task_info->qual[task_info->total].task_name =
   'execute dm2_refresh_local_meta_data with replace("REQUEST","MD_REQUEST") go'
   SET task_info->qual[task_info->total].task_request = replace(replace(concat(
      "<REC_DEF>record md_request (1 remote_env_id = f8 1 local_env_id = f8 1 post_link_name = vc) go</REC_DEF> ",
      "<VAL_SET>set md_request->remote_env_id = <src_env_id>.0 go</VAL_SET> ",
      "<VAL_SET>set md_request->local_env_id = <tgt_env_id>.0 go</VAL_SET>"),"<src_env_id>",trim(
      cnvtstring(drbb_drvc_request->paired_env_id)),0),"<tgt_env_id>",trim(cnvtstring(
      drbb_drvc_request->current_env_id)),0)
   SET task_info->total = (task_info->total+ 1)
   SET task_info->qual[task_info->total].task_level = 200
   SET task_info->qual[task_info->total].task_desc = "Creating RDDS table tiering list"
   SET task_info->qual[task_info->total].task_name = "execute DM_RMC_SETUP_TIER go"
   SET task_info->qual[task_info->total].task_request = concat(
    "<VAR_DEF>declare drst_event_reason = vc go</VAR_DEF>",
    "<VAL_SET>set drst_event_reason = 'Open Event Run' go</VAL_SET>")
   SET task_info->total = (task_info->total+ 1)
   SET task_info->qual[task_info->total].task_level = 200
   SET task_info->qual[task_info->total].task_desc = "Refreshing function that prevents dual build"
   SET task_info->qual[task_info->total].task_name = replace(
    "execute DM_REFCHG_DUAL_BUILD_REJECT < 0 or 1> go","< 0 or 1>",trim(cnvtstring(drbb_block_ind)),0
    )
   SET task_info->total = (task_info->total+ 1)
   SET task_info->qual[task_info->total].task_level = 500
   SET task_info->qual[task_info->total].task_desc = "Opening an event"
   SET task_info->qual[task_info->total].task_name = "execute DM_RMC_AUTO_VERIFY_SETUP go"
   SET task_info->qual[task_info->total].task_request = replace(replace(replace(replace(replace(
        concat(
         "<REC_DEF>record auto_ver_request (1 QUAL[*] 2 rdds_event = VC 2 event_reason = VC 2 cur_environment_id = F8 ",
         "2 paired_environment_id = F8 2 detail_qual[*] 3 event_detail1_txt = VC 3 event_detail2_txt = VC 3 event_detail3_txt = VC"
,
         " 3 event_value = f8) go</REC_DEF> ",
         "<VAL_SET>set stat = alterlist(auto_ver_request->qual,2) go</VAL_SET> ",
         "<VAL_SET>set auto_ver_request->qual[1].rdds_event = 'Dual Build Trigger Change' go</VAL_SET> ",
         "<VAL_SET>set auto_ver_request->qual[1].cur_environment_id = <tgt_env_id>.0 go</VAL_SET> ",
         "<VAL_SET>set auto_ver_request->qual[1].paired_environment_id = <src_env_id>.0 go</VAL_SET> ",
         "<VAL_SET>set auto_ver_request->qual[1].event_reason = 'Caused by Open Event' go</VAL_SET> ",
         "<VAL_SET>set stat = alterlist(auto_ver_request->qual[1].detail_qual, 1) go</VAL_SET> ",
"<VAL_SET>set auto_ver_request->qual[1].detail_qual[1].event_detail1_txt='Compile DM_REFCHG_DUAL_BUILD_REJECT' go</VAL_SET>\
 \
",
         "<VAL_SET>set auto_ver_request->qual[1].detail_qual[1].event_value=<0 or 1> go</VAL_SET> ",
         "<VAL_SET>set auto_ver_request->qual[2].rdds_event = 'Begin Reference Data Sync' go</VAL_SET> ",
         "<VAL_SET>set auto_ver_request->qual[2].cur_environment_id = <tgt_env_id>.0 go</VAL_SET> ",
         "<VAL_SET>set auto_ver_request->qual[2].paired_environment_id = <src_env_id>.0 go</VAL_SET> ",
         "<VAL_SET>set auto_ver_request->qual[2].event_reason = '<EVENT_NAME>' go</VAL_SET> ",
         "<VAL_SET>set stat = alterlist(auto_ver_request->qual[2].detail_qual, 1) go</VAL_SET> ",
         "<VAL_SET>set auto_ver_request->qual[2].detail_qual[1].event_detail1_txt='Cutover by Context Setting' go</VAL_SET> ",
         "<VAL_SET>set auto_ver_request->qual[2].detail_qual[1].event_value=<cbc_ind> go</VAL_SET> "),
        "<src_env_id>",trim(cnvtstring(drbb_drvc_request->paired_env_id)),0),"<tgt_env_id>",trim(
        cnvtstring(drbb_drvc_request->current_env_id)),0),"<0 or 1>",trim(cnvtstring(drbb_block_ind)),
      0),"<EVENT_NAME>",drbb_event_name,0),"<cbc_ind>",trim(cnvtstring(dmda_drbb_request->cbc_ind)),0
    )
   SET task_info->qual[task_info->total].task_reply = concat(
    "<REC_DEF>record auto_ver_reply(1 STATUS=C1 1 STATUS_MSG=VC) go</REC_DEF> ",
    "<ERR_IND>auto_ver_reply->STATUS</ERR_IND> ","<ERR_MSG>auto_ver_reply->STATUS_MSG</ERR_MSG> ",
    "<ERR_TYPE>VC</ERR_TYPE> ","<NO_ERR_RESULT>S</NO_ERR_RESULT>")
   SET task_info->total = (task_info->total+ 1)
   SET task_info->qual[task_info->total].task_level = 400
   SET task_info->qual[task_info->total].task_desc = "Creating all $R tables"
   SET task_info->qual[task_info->total].task_name = replace(replace(
     "execute DM_RMC_CHECK_PRECREATE <cur_env_id>.0, <post-Link_name> go","<cur_env_id>",trim(
      cnvtstring(drbb_drvc_request->current_env_id)),0),"<post-Link_name>",concat('"@MERGE',trim(
      cnvtstring(drbb_drvc_request->paired_env_id)),trim(cnvtstring(drbb_drvc_request->current_env_id
       )),'"'),0)
   IF (drbb_dcl_ind=1)
    SET task_info->total = (task_info->total+ 1)
    SET stat = alterlist(task_info->qual,task_info->total)
    SET task_info->qual[task_info->total].task_level = 600
    SET task_info->qual[task_info->total].task_desc = "Correcting form of invalid change log rows"
    SET task_info->qual[task_info->total].task_name =
    'execute DM_RMC_CORRECT_DCL with replace ("REQUEST","DCLBB_REQUEST"),replace("REPLY","DCLBB_REPLY") go'
    SET task_info->qual[task_info->total].task_request = replace(replace(concat(
       "<REC_DEF>record dclbb_request (1 target_id = f8 1 log_id = f8) go</REC_DEF> ",
       "<VAL_SET>set dclbb_request->target_id = <src_env_id>.0 go</VAL_SET> ",
       "<VAL_SET>set dclbb_request->log_id = 0 go</VAL_SET>"),"<src_env_id>",trim(cnvtstring(
        drbb_drvc_request->paired_env_id)),0),"<tgt_env_id>",trim(cnvtstring(drbb_drvc_request->
       current_env_id)),0)
    SET task_info->qual[task_info->total].task_reply = concat(
     "<REC_DEF>record dclbb_reply (1 status_data 2 status = c1) go</REC_DEF> ",
     "<ERR_IND>dclbb_reply->status_data.status</ERR_IND> ","<ERR_MSG></ERR_MSG> ",
     "<ERR_TYPE>VC</ERR_TYPE> ","<NO_ERR_RESULT>S</NO_ERR_RESULT>")
   ENDIF
   IF (dmbb_refresh_ind != 0)
    SET task_info->total = (task_info->total+ 1)
    SET stat = alterlist(task_info->qual,task_info->total)
    SET task_info->qual[task_info->total].task_level = 200
    SET task_info->qual[task_info->total].task_desc = "Dropping old and empty $R tables"
    SET task_info->qual[task_info->total].task_name =
    'execute DM_RMC_DROP_OLD_R with replace("REQUEST","DROP_REQUEST") go'
    SET task_info->qual[task_info->total].task_request = concat(
     "<REC_DEF>record drop_request(1 drop_after_day = i4) go</REC_DEF> ",
     "<VAL_SET>set drop_request->drop_after_day = 30 go</VAL_SET>")
    SET task_info->total = (task_info->total+ 1)
    SET stat = alterlist(task_info->qual,task_info->total)
    SET task_info->qual[task_info->total].task_level = 300
    SET task_info->qual[task_info->total].task_desc =
    "Refreshing all current $Rs and related objects"
    SET task_info->qual[task_info->total].task_name = replace(
     "execute DM_RMC_REFRESH_R <cur_env_id>.0 go","<cur_env_id>",trim(cnvtstring(drbb_drvc_request->
       current_env_id)),0)
   ENDIF
   SET task_info->total = (task_info->total+ 1)
   SET stat = alterlist(task_info->qual,task_info->total)
   SET task_info->qual[task_info->total].task_level = 300
   SET task_info->qual[task_info->total].task_desc = "Managing DM_MERGE_TRANSLATE triggers"
   SET task_info->qual[task_info->total].task_name = "execute dm_rmc_create_dmt_trig go"
   SET task_info->total = (task_info->total+ 1)
   SET stat = alterlist(task_info->qual,task_info->total)
   SET task_info->qual[task_info->total].task_level = 300
   SET task_info->qual[task_info->total].task_desc = "Creating DM_CLOB_GTTD temp table"
   SET task_info->qual[task_info->total].task_name = "execute dm_create_dm_lob_gttd go"
   SET task_info->total = (task_info->total+ 1)
   SET stat = alterlist(task_info->qual,task_info->total)
   SET task_info->qual[task_info->total].task_level = 400
   SET task_info->qual[task_info->total].task_desc = "Creating XML CLOB pl/sql functions"
   SET task_info->qual[task_info->total].task_name =
   'execute dm_rmc_create_clobxml_function with replace ("DRCCF_REQUEST","DRBB_DRCCF_REQUEST") go'
   SET task_info->qual[task_info->total].task_request = replace(replace(concat(
      "<REC_DEF>record drbb_drccf_request (1 source_env_id = f8 1 target_env_id = f8) go</REC_DEF> ",
      "<VAL_SET>set drbb_drccf_request->source_env_id = <src_env_id>.0 go</VAL_SET> ",
      "<VAL_SET>set drbb_drccf_request->target_env_id = <tgt_env_id>.0 go</VAL_SET>"),"<src_env_id>",
     trim(cnvtstring(drbb_drccf_request->source_env_id)),0),"<tgt_env_id>",trim(cnvtstring(
      drbb_drccf_request->target_env_id)),0)
   SET task_info->total = (task_info->total+ 1)
   SET stat = alterlist(task_info->qual,task_info->total)
   SET task_info->qual[task_info->total].task_level = 400
   SET task_info->qual[task_info->total].task_desc = "Creating JSON CLOB pl/sql functions"
   SET task_info->qual[task_info->total].task_name =
   'execute dm_rmc_create_clobjson_fxn with replace ("DRCCF_REQUEST","DRBB_DRCCF_REQUEST") go'
   SET task_info->qual[task_info->total].task_request = replace(replace(concat(
      "<REC_DEF>record drbb_drccf_request (1 source_env_id = f8 1 target_env_id = f8) go</REC_DEF> ",
      "<VAL_SET>set drbb_drccf_request->source_env_id = <src_env_id>.0 go</VAL_SET> ",
      "<VAL_SET>set drbb_drccf_request->target_env_id = <tgt_env_id>.0 go</VAL_SET>"),"<src_env_id>",
     trim(cnvtstring(drbb_drccf_request->source_env_id)),0),"<tgt_env_id>",trim(cnvtstring(
      drbb_drccf_request->target_env_id)),0)
   SET task_info->detail_cnt = 3
   SET stat = alterlist(task_info->detail_qual,task_info->detail_cnt)
   SET task_info->detail_qual[1].event_detail1_txt = "EVENT_NAME"
   SET task_info->detail_qual[1].event_detail2_txt = drbb_event_name
   SET task_info->detail_qual[2].event_detail1_txt = "EVENT_SOURCE_ID"
   SET task_info->detail_qual[2].event_detail2_txt = trim(cnvtstring(drbb_drvc_request->paired_env_id
     ))
   SET task_info->detail_qual[3].event_detail1_txt = "EVENT_SOURCE_NAME"
   SET task_info->detail_qual[3].event_detail2_txt = dmda_drbb_request->src_env_name
   SET task_info->total = (task_info->total+ 1)
   SET stat = alterlist(task_info->qual,task_info->total)
   SET task_info->qual[task_info->total].task_level = 600
   SET task_info->qual[task_info->total].task_desc = "Running Instruction Sets"
   SET task_info->qual[task_info->total].task_name = "execute dm_rmc_get_ins_set go"
   SET task_info->qual[task_info->total].task_request = concat(
    "<REC_DEF>record dm_get_request (1 table_name = vc 1 run_cnt = i4 1 run_qual[*] 2 run_time_flag = i4) go</REC_DEF> ",
    "<VAL_SET>set dm_get_request->run_cnt = 1 go</VAL_SET> ",
    "<VAL_SET>set dm_get_request->table_name = '' go</VAL_SET> ",
    "<VAL_SET>set stat = alterlist(dm_get_request->run_qual, 1) go</VAL_SET>",
    "<VAL_SET>set dm_get_request->run_qual[1].run_time_flag = 1 go</VAL_SET>")
   SET task_info->qual[task_info->total].task_reply = concat(
    "<REC_DEF>record dm_get_reply(1 status = vc 1 status_msg = vc 1 ins_cnt = i4 1 ins_qual[*] ",
    " 2 ins_meaning = vc 2 ins_status = vc 2 ins_message = vc 2 ins_log_file = vc) go</REC_DEF> ",
    "<ERR_IND>dm_get_reply->status</ERR_IND> ","<ERR_MSG>dm_get_reply->status_msg</ERR_MSG> ",
    "<ERR_TYPE>VC</ERR_TYPE> ",
    "<NO_ERR_RESULT>S</NO_ERR_RESULT>")
   SET task_info->total = (task_info->total+ 1)
   SET stat = alterlist(task_info->qual,task_info->total)
   SET task_info->qual[task_info->total].task_level = 50
   SET task_info->qual[task_info->total].task_desc = "Checking for REALM Value"
   SET task_info->qual[task_info->total].task_name =
   'execute dm_rmc_chk_realm with replace("REPLY","DRCR_REPLY") go'
   SET task_info->qual[task_info->total].task_reply = concat(
    "<REC_DEF>record drcr_reply(1 realm_value = vc 1 status_data 2 status = c1) go</REC_DEF> ",
    "<ERR_IND>drcr_reply->status_data.status</ERR_IND> ","<ERR_MSG></ERR_MSG> ",
    "<ERR_TYPE>VC</ERR_TYPE> ","<NO_ERR_RESULT>S</NO_ERR_RESULT>")
   SET task_info->total = (task_info->total+ 1)
   SET stat = alterlist(task_info->qual,task_info->total)
   SET task_info->qual[task_info->total].task_level = 50
   SET task_info->qual[task_info->total].task_desc = "Uploading data into DM_REFCHG_FILTER"
   SET task_info->qual[task_info->total].task_name = "execute dm_wrp_dm_refchg_filter go"
   SET task_info->total = (task_info->total+ 1)
   SET stat = alterlist(task_info->qual,task_info->total)
   SET task_info->qual[task_info->total].task_level = 50
   SET task_info->qual[task_info->total].task_desc = "Uploading data into DM_REFCHG_FILTER_PARM"
   SET task_info->qual[task_info->total].task_name = "execute dm_wrp_dm_refchg_filter_parm go"
   SET task_info->total = (task_info->total+ 1)
   SET stat = alterlist(task_info->qual,task_info->total)
   SET task_info->qual[task_info->total].task_level = 50
   SET task_info->qual[task_info->total].task_desc = "Uploading data into DM_REFCHG_FILTER_TEST"
   SET task_info->qual[task_info->total].task_name = "execute dm_wrp_dm_refchg_filter_test go"
   SET drbb_ins_status = drtq_insert_task_process(task_info,1)
  ELSE
   SET drbb_ins_status = "S"
  ENDIF
  IF (drbb_ins_status="S")
   FOR (drbb_i = 1 TO dmda_drbb_request->dmoe_num_proc)
     SET drbb_cur_logfile = dm_err->unique_fname
     IF (get_unique_file("rdds_run_oeproc",".log")=0)
      SET drbb_nohup_logfile = "rdds_run_oeproc.log"
      SET dm_err->err_ind = 0
     ELSE
      SET drbb_nohup_logfile = dm_err->unique_fname
     ENDIF
     SET dm_err->unique_fname = drbb_cur_logfile
     IF (cursys="AXP")
      SET drbb_execute_str = concat("SUBMIT /QUE=",dmda_drbb_request->dgnb_com_batch,
       " cer_proc:rdds_run_proc.com /param=(",'"OPEN EVENT PROCESS",',dmda_drbb_request->db_password,
       ",",dmda_drbb_request->db_sid,") /log=CCLUSERDIR:",drbb_nohup_logfile)
     ELSE
      SET drbb_execute_str = concat("nohup $cer_proc/rdds_run_proc.ksh 'OPEN EVENT PROCESS' ",
       dmda_drbb_request->db_password," ",dmda_drbb_request->db_sid," > $CCLUSERDIR/",
       drbb_nohup_logfile," 2>&1 &")
     ENDIF
     CALL dcl(drbb_execute_str,size(drbb_execute_str),drbb_dcl_stat)
     IF (drbb_dcl_stat=0)
      SET dm_err->eproc = concat("Error connecting to: ",dmda_drbb_request->db_sid)
      CALL disp_msg(" ",dm_err->logfile,0)
      GO TO exit_program
     ENDIF
     CALL pause(2)
   ENDFOR
  ENDIF
 ENDIF
#exit_program
 CALL delete_tracking_row(null)
 COMMIT
END GO
