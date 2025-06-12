CREATE PROGRAM dm_rmc_find_dcl:dba
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
 DECLARE drmm_get_col_string(sbr_pk_where=vc,sbr_log_id=f8,sbr_tbl_name=vc,sbr_tbl_suffix=vc,
  sbr_db_link=vc) = i4
 DECLARE drmm_get_ptam_match_query(sbr_log_id=f8,sbr_tab_name=vc,sbr_tab_suffix=vc,sbr_db_link=vc) =
 null
 DECLARE drmm_get_ptam_match_result(sbr_log_id=f8,sbr_src_env_id=f8,sbr_tgt_env_id=f8,sbr_db_link=vc,
  sbr_local_ind=i2,
  sbr_trans_type=vc) = f8
 DECLARE drmm_get_pk_where(sbr_tab_name=vc,sbr_tab_suffix=vc,sbr_delete_ind=i2,sbr_db_link=vc) = vc
 DECLARE drmm_get_exploded_pkw(sbr_tab_name=vc,sbr_tab_suffix=vc,sbr_db_link=vc) = vc
 DECLARE drmm_get_func_name(sbr_prefix=vc,sbr_db_link=vc) = vc
 DECLARE drmm_get_cust_col_string(sbr_pk_where=vc,sbr_tbl_name=vc,sbr_col_name=vc,sbr_tbl_suffix=vc,
  sbr_db_link=vc) = i4
 IF ( NOT (validate(col_string_parm,0)))
  FREE RECORD col_string_parm
  RECORD col_string_parm(
    1 total = i4
    1 qual[*]
      2 table_name = vc
      2 col_qual[*]
        3 column_name = vc
        3 in_src_ind = i2
  ) WITH protect
 ENDIF
 SUBROUTINE drmm_get_col_string(sbr_pk_where,sbr_log_id,sbr_tbl_name,sbr_tbl_suffix,sbr_db_link)
   DECLARE dgcs_tab_name = vc WITH protect, noconstant("")
   DECLARE dgcs_tab_suffix = vc WITH protect, noconstant("")
   DECLARE dgcs_src_tab_name = vc WITH protect, noconstant("")
   DECLARE dgcs_col_pos = i4 WITH protect, noconstant(0)
   DECLARE dgcs_num = i4 WITH protect, noconstant(0)
   DECLARE dgcs_func_prefix = vc WITH protect, noconstant("")
   DECLARE dgcs_func_name = vc WITH protect, noconstant("")
   DECLARE dgcs_loop = i4 WITH protect, noconstant(0)
   DECLARE dgcs_dcl_tab_name = vc WITH protect, noconstant("")
   DECLARE dgcs_db_link = vc WITH protect, noconstant(" ")
   DECLARE dgcs_stmt_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgcs_stmt_idx = i4 WITH protect, noconstant(0)
   DECLARE dgcs_qual_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgcs_col_loop = i4 WITH protect, noconstant(0)
   DECLARE dgcs_utc_name = vc WITH protect, noconstant("")
   DECLARE dgcs_pos = i4 WITH protect, noconstant(0)
   DECLARE dgcs_miss_ind = i2 WITH protect, noconstant(0)
   IF ( NOT (validate(parse_rs,0)))
    FREE RECORD parse_rs
    RECORD parse_rs(
      1 stmt[*]
        2 str = vc
    ) WITH protect
   ENDIF
   DECLARE dm2_context_control_wrapper() = i2
   IF (sbr_db_link > " ")
    SET dgcs_db_link = sbr_db_link
   ENDIF
   IF (sbr_log_id > 0.0)
    SET dgcs_dcl_tab_name = concat("DM_CHG_LOG",dgcs_db_link)
    SELECT INTO "nl:"
     dm2_context_control_wrapper("RDDS_COL_STRING",d.col_string)
     FROM (parser(dgcs_dcl_tab_name) d)
     WHERE d.log_id=sbr_log_id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(- (1))
    ENDIF
   ELSE
    SET dgcs_tab_name = sbr_tbl_name
    SET dgcs_tab_suffix = sbr_tbl_suffix
    SET dgcs_col_pos = locateval(dgcs_num,1,col_string_parm->total,dgcs_tab_name,col_string_parm->
     qual[dgcs_num].table_name)
    IF (dgcs_col_pos=0)
     SET dgcs_col_pos = (col_string_parm->total+ 1)
     SET stat = alterlist(col_string_parm->qual,dgcs_col_pos)
     SET col_string_parm->total = dgcs_col_pos
     SET col_string_parm->qual[dgcs_col_pos].table_name = dgcs_tab_name
     SELECT INTO "nl:"
      FROM dm_colstring_parm d
      WHERE d.table_name=dgcs_tab_name
      ORDER BY d.parm_nbr
      HEAD REPORT
       parm_cnt = 0
      DETAIL
       parm_cnt = (parm_cnt+ 1), stat = alterlist(col_string_parm->qual[dgcs_col_pos].col_qual,
        parm_cnt), col_string_parm->qual[dgcs_col_pos].col_qual[parm_cnt].column_name = d.column_name
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(- (1))
     ENDIF
    ENDIF
    IF (dgcs_db_link > "")
     FOR (dgcs_col_loop = 1 TO size(col_string_parm->qual[dgcs_col_pos].col_qual,5))
       SET col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_col_loop].in_src_ind = 0
     ENDFOR
     SET dgcs_utc_name = concat("USER_TAB_COLUMNS",dgcs_db_link)
     SELECT INTO "nl:"
      FROM (parser(dgcs_utc_name) utc)
      WHERE (utc.table_name=col_string_parm->qual[dgcs_col_pos].table_name)
       AND expand(dgcs_num,1,size(col_string_parm->qual[dgcs_col_pos].col_qual,5),utc.column_name,
       col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_num].column_name)
       AND  NOT (column_name IN ("KEY1", "KEY2", "KEY3"))
      DETAIL
       dgcs_pos = 0, dgcs_pos = locateval(dgcs_num,1,size(col_string_parm->qual[dgcs_col_pos].
         col_qual,5),utc.column_name,col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_num].
        column_name)
       IF (dgcs_pos > 0)
        col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_pos].in_src_ind = 1
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(- (1))
     ENDIF
     SELECT DISTINCT INTO "nl:"
      dpwp.column_name
      FROM dm_pk_where_parm dpwp
      WHERE (dpwp.table_name=col_string_parm->qual[dgcs_col_pos].table_name)
      DETAIL
       dgcs_pos = 0, dgcs_pos = locateval(dgcs_num,1,size(col_string_parm->qual[dgcs_col_pos].
         col_qual,5),dpwp.column_name,col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_num].
        column_name)
       IF ((col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_pos].in_src_ind=0))
        dgcs_miss_ind = 1
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(- (1))
     ENDIF
     IF (dgcs_miss_ind=1)
      SET dm_err->err_ind = 1
      SET dm_err->emsg = concat(
       "PK_WHERE or PTAM_MATCH_QUERY is going to use a column that does not exist in source.")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(- (2))
     ENDIF
    ENDIF
    SET dgcs_func_prefix = concat("REFCHG_COLSTRING_",dgcs_tab_suffix)
    SET dgcs_func_name = drmm_get_func_name(dgcs_func_prefix," ")
    IF (check_error(dm_err->eproc)=1)
     RETURN(- (1))
    ENDIF
    IF (dgcs_func_name="")
     SET dm_err->emsg = concat("A col_string function is not built: ",dgcs_func_prefix)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     RETURN(- (1))
    ENDIF
    CALL parser(concat("declare ",dgcs_func_name,"() = c4000 go"),1)
    SET dgcs_stmt_cnt = (size(col_string_parm->qual[dgcs_col_pos].col_qual,5)+ 4)
    SET stat = alterlist(parse_rs->stmt,dgcs_stmt_cnt)
    SET dgcs_qual_cnt = 0
    SET dgcs_stmt_idx = 1
    SET dgcs_src_tab_name = concat(dgcs_tab_name,dgcs_db_link)
    SET parse_rs->stmt[dgcs_stmt_idx].str =
    "select into 'nl:' dm2_context_control_wrapper('RDDS_COL_STRING',"
    SET dgcs_stmt_idx = (dgcs_stmt_idx+ 1)
    SET parse_rs->stmt[dgcs_stmt_idx].str = concat(dgcs_func_name,"(")
    FOR (dgcs_loop = 1 TO size(col_string_parm->qual[dgcs_col_pos].col_qual,5))
      SET dgcs_stmt_idx = (dgcs_stmt_idx+ 1)
      IF (dgcs_loop != 1)
       SET parse_rs->stmt[dgcs_stmt_idx].str = ","
      ELSE
       SET parse_rs->stmt[dgcs_stmt_idx].str = " "
      ENDIF
      IF (dgcs_db_link > "")
       IF ((col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_loop].in_src_ind=0))
        SET parse_rs->stmt[dgcs_stmt_idx].str = concat(parse_rs->stmt[dgcs_stmt_idx].str,"NULL")
       ELSE
        SET parse_rs->stmt[dgcs_stmt_idx].str = concat(parse_rs->stmt[dgcs_stmt_idx].str,"t",
         dgcs_tab_suffix,".",col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_loop].column_name)
       ENDIF
      ELSE
       SET parse_rs->stmt[dgcs_stmt_idx].str = concat(parse_rs->stmt[dgcs_stmt_idx].str,"t",
        dgcs_tab_suffix,".",col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_loop].column_name)
      ENDIF
    ENDFOR
    SET dgcs_stmt_idx = (dgcs_stmt_idx+ 1)
    SET parse_rs->stmt[dgcs_stmt_idx].str = concat(")) from ",dgcs_src_tab_name," t",dgcs_tab_suffix)
    SET dgcs_stmt_idx = (dgcs_stmt_idx+ 1)
    SET parse_rs->stmt[dgcs_stmt_idx].str = concat(" ",sbr_pk_where,
     " detail dgcs_qual_cnt = dgcs_qual_cnt + 1 with nocounter,notrim, maxqual(t",dgcs_tab_suffix,
     ",1) go")
    EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","PARSE_RS")
    SET stat = initrec(parse_rs)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(- (1))
    ENDIF
    IF (dgcs_qual_cnt=0)
     CALL echo(concat("The pk_where: ",sbr_pk_where," did not return any rows."))
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drmm_get_ptam_match_query(sbr_log_id,sbr_tab_name,sbr_tab_suffix,sbr_db_link)
   DECLARE dgpq_dcl_tab_name = vc WITH protect, noconstant(" ")
   DECLARE dgpq_func_name = vc WITH protect, noconstant("")
   DECLARE dgpq_func_prefix = vc WITH protect, noconstant("")
   DECLARE dgpq_db_link = vc WITH protect, noconstant(" ")
   DECLARE dm2_context_control_wrapper() = i2
   DECLARE sys_context() = c4000
   IF ( NOT (validate(parse_rs,0)))
    FREE RECORD parse_rs
    RECORD parse_rs(
      1 stmt[*]
        2 str = vc
    ) WITH protect
   ENDIF
   IF (sbr_db_link > " ")
    SET dgpq_db_link = sbr_db_link
   ENDIF
   IF (sbr_log_id > 0.0)
    SET dgpq_dcl_tab_name = concat("DM_CHG_LOG",dgpq_db_link)
    SELECT INTO "nl:"
     dm2_context_control_wrapper("RDDS_PTAM_MATCH_QUERY",d.ptam_match_query)
     FROM (parser(dgpq_dcl_tab_name) d)
     WHERE d.log_id=sbr_log_id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN
    ENDIF
   ELSE
    SET dgpq_func_prefix = concat("REFCHG_GEN_PK_PTAM_",sbr_tab_suffix)
    SET dgpq_func_name = drmm_get_func_name(dgpq_func_prefix," ")
    IF (check_error(dm_err->eproc)=1)
     RETURN
    ENDIF
    IF (dgpq_func_name="")
     SET dm_err->emsg = concat("A function is not built: ",dgpq_func_prefix)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     RETURN
    ENDIF
    CALL parser(concat("declare ",dgpq_func_name,"() = c2000 go"),1)
    SET stat = alterlist(parse_rs->stmt,3)
    SET parse_rs->stmt[1].str =
    "SELECT into 'nl:' sbr_ind = dm2_context_control_wrapper('RDDS_PTAM_MATCH_QUERY',"
    SET parse_rs->stmt[2].str = concat(dgpq_func_name,
     "(0,1,SYS_CONTEXT('CERNER','RDDS_COL_STRING',4000),'",dgpq_db_link,"')) from dual")
    SET parse_rs->stmt[3].str = " with nocounter go"
    EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","PARSE_RS")
    SET stat = initrec(parse_rs)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN
    ENDIF
   ENDIF
   RETURN
 END ;Subroutine
 SUBROUTINE drmm_get_ptam_match_result(sbr_log_id,sbr_src_env_id,sbr_tgt_env_id,sbr_db_link,
  sbr_local_ind,sbr_xlat_type)
   DECLARE dgpr_ptam_result = f8 WITH protect, noconstant(0.0)
   DECLARE dgpr_src_str = vc WITH protect, noconstant(" ")
   DECLARE dgpr_tgt_str = vc WITH protect, noconstant(" ")
   DECLARE dgpr_db_link = vc WITH protect, noconstant(" ")
   DECLARE dgpr_xlat_type = vc WITH protect, noconstant(" ")
   DECLARE refchg_run_ptam() = f8
   DECLARE sys_context() = c2000
   IF (sbr_db_link > " ")
    SET dgpr_db_link = sbr_db_link
   ENDIF
   IF (sbr_xlat_type > " ")
    SET dgpr_xlat_type = sbr_xlat_type
   ENDIF
   IF (sbr_log_id > 0.0)
    SET dgpq_dcl_tab_name = concat("DM_CHG_LOG",dgpr_db_link)
    SELECT INTO "nl:"
     FROM (parser(dgpq_dcl_tab_name) d)
     WHERE d.log_id=sbr_log_id
     DETAIL
      dgpr_ptam_result = d.ptam_match_result
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ELSE
    SET dgpr_src_str = concat(trim(cnvtstring(sbr_src_env_id)),".0")
    SET dgpr_tgt_str = concat(trim(cnvtstring(sbr_tgt_env_id)),".0")
    SELECT INTO "nl:"
     ptam_result = refchg_run_ptam(replace(replace(replace(replace(replace(sys_context("CERNER",
            "RDDS_PTAM_MATCH_QUERY",2000),"<SOURCE_ID>",dgpr_src_str),"<TARGET_ID>",dgpr_tgt_str),
         "<DB_LINK>",concat("'",dgpr_db_link,"'")),"<LOCAL_IND>",trim(cnvtstring(sbr_local_ind))),
       "<XLAT_TYPE>",concat("'",dgpr_xlat_type,"'")))
     FROM dual
     DETAIL
      dgpr_ptam_result = ptam_result
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(dgpr_ptam_result)
 END ;Subroutine
 SUBROUTINE drmm_get_pk_where(sbr_tab_name,sbr_tab_suffix,sbr_delete_ind,sbr_db_link)
   DECLARE dgpw_dcl_tab_name = vc WITH protect, noconstant(" ")
   DECLARE dgpw_func_name = vc WITH protect, noconstant("")
   DECLARE dgpw_func_prefix = vc WITH protect, noconstant("")
   DECLARE dgpw_pk_where = vc WITH protect, noconstant(" ")
   DECLARE dgpw_db_link = vc WITH protect, noconstant(" ")
   DECLARE dm2_context_control_wrapper() = i2
   DECLARE sys_context() = c4000
   IF ( NOT (validate(parse_rs,0)))
    FREE RECORD parse_rs
    RECORD parse_rs(
      1 stmt[*]
        2 str = vc
    ) WITH protect
   ENDIF
   IF (sbr_db_link > " ")
    SET dgpw_db_link = sbr_db_link
   ENDIF
   SET dgpw_func_prefix = concat("REFCHG_GEN_PK_PTAM_",sbr_tab_suffix)
   SET dgpw_func_name = drmm_get_func_name(dgpw_func_prefix," ")
   IF (dgpw_func_name="")
    SET dm_err->emsg = concat("A col_string function is not built: ",dgpw_func_prefix)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN("")
   ENDIF
   CALL parser(concat("declare ",dgpw_func_name,"() = c2000 go"),1)
   SET stat = alterlist(parse_rs->stmt,4)
   SET parse_rs->stmt[1].str = "SELECT into 'nl:' dgpw_pkw = "
   SET parse_rs->stmt[2].str = concat(dgpw_func_name,"(1,",trim(cnvtstring(sbr_delete_ind)),
    ",SYS_CONTEXT('CERNER','RDDS_COL_STRING',4000),'",dgpw_db_link,
    "') from dual")
   SET parse_rs->stmt[3].str = "detail dgpw_pk_where = dgpw_pkw "
   SET parse_rs->stmt[4].str = "with nocounter go"
   EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","PARSE_RS")
   SET stat = initrec(parse_rs)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("")
   ENDIF
   RETURN(dgpw_pk_where)
 END ;Subroutine
 SUBROUTINE drmm_get_func_name(sbr_prefix,sbr_db_link)
   DECLARE dgfn_func_name = vc WITH protect, noconstant("")
   DECLARE dgfn_uo_tab = vc WITH protect, noconstant("")
   DECLARE dgfn_prefix = vc WITH protect, noconstant("")
   SET dgfn_uo_tab = concat("USER_OBJECTS",sbr_db_link)
   SET dgfn_prefix = concat(sbr_prefix,"*")
   SELECT INTO "nl:"
    FROM (parser(dgfn_uo_tab) uo)
    WHERE uo.object_name=patstring(dgfn_prefix)
    DETAIL
     dgfn_func_name = uo.object_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("")
   ENDIF
   RETURN(dgfn_func_name)
 END ;Subroutine
 SUBROUTINE drmm_get_cust_col_string(sbr_pk_where,sbr_tbl_name,sbr_col_name,sbr_tbl_suffix,
  sbr_db_link)
   DECLARE dgcs_tab_name = vc WITH protect, noconstant("")
   DECLARE dgcs_tab_suffix = vc WITH protect, noconstant("")
   DECLARE dgcs_src_tab_name = vc WITH protect, noconstant("")
   DECLARE dgcs_col_pos = i4 WITH protect, noconstant(0)
   DECLARE dgcs_num = i4 WITH protect, noconstant(0)
   DECLARE dgcs_func_prefix = vc WITH protect, noconstant("")
   DECLARE dgcs_func_name = vc WITH protect, noconstant("")
   DECLARE dgcs_loop = i4 WITH protect, noconstant(0)
   DECLARE dgcs_dcl_tab_name = vc WITH protect, noconstant("")
   DECLARE dgcs_db_link = vc WITH protect, noconstant(" ")
   DECLARE dgcs_stmt_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgcs_stmt_idx = i4 WITH protect, noconstant(0)
   DECLARE dgcs_qual_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgcs_col_loop = i4 WITH protect, noconstant(0)
   DECLARE dgcs_utc_name = vc WITH protect, noconstant("")
   DECLARE dgcs_pos = i4 WITH protect, noconstant(0)
   DECLARE dgcs_miss_ind = i2 WITH protect, noconstant(0)
   DECLARE dgcs_col_name = vc WITH protect, noconstant("")
   DECLARE dgcs_type = vc WITH protect, noconstant("")
   IF ( NOT (validate(parse_rs,0)))
    FREE RECORD parse_rs
    RECORD parse_rs(
      1 stmt[*]
        2 str = vc
    ) WITH protect
   ENDIF
   DECLARE dm2_context_control_wrapper() = i2
   IF (sbr_db_link > " ")
    SET dgcs_db_link = sbr_db_link
   ENDIF
   SET dgcs_tab_name = sbr_tbl_name
   SET dgcs_tab_suffix = sbr_tbl_suffix
   SET dgcs_col_name = sbr_col_name
   IF (dgcs_db_link > "")
    SET dgcs_utc_name = concat("USER_TAB_COLUMNS",dgcs_db_link)
   ELSE
    SET dgcs_utc_name = "USER_TAB_COLUMNS"
   ENDIF
   SELECT INTO "nl:"
    FROM (parser(dgcs_utc_name) utc)
    WHERE utc.table_name=dgcs_tab_name
     AND utc.column_name=dgcs_col_name
    DETAIL
     dgcs_type = utc.data_type
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   IF (curqual=0)
    CALL disp_msg("The column being asked for does not exist in source.",dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   IF ( NOT (dgcs_type IN ("DATE", "FLOAT", "NUMBER", "CHAR", "VARCHAR2")))
    CALL disp_msg("The column being asked has an incompatible data_type.",dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   SET dgcs_func_name = "REFCHG_CUST_COLSTRING"
   CALL parser(concat("declare ",dgcs_func_name,"() = c4000 go"),1)
   SET stat = alterlist(parse_rs->stmt,5)
   SET dgcs_qual_cnt = 0
   SET dgcs_stmt_idx = 1
   SET dgcs_src_tab_name = concat(dgcs_tab_name,dgcs_db_link)
   SET parse_rs->stmt[dgcs_stmt_idx].str =
   "select into 'nl:' dm2_context_control_wrapper('RDDS_CUST_COL_STRING',"
   SET dgcs_stmt_idx = (dgcs_stmt_idx+ 1)
   SET parse_rs->stmt[dgcs_stmt_idx].str = concat(dgcs_func_name,"(")
   SET dgcs_stmt_idx = (dgcs_stmt_idx+ 1)
   SET parse_rs->stmt[dgcs_stmt_idx].str = concat("'",dgcs_col_name,"','",dgcs_type,"',")
   IF (dgcs_type IN ("VARCHAR2", "CHAR"))
    SET parse_rs->stmt[dgcs_stmt_idx].str = concat(parse_rs->stmt[dgcs_stmt_idx].str,
     "0.0,cnvtdatetime(curdate,curtime3),","t",dgcs_tab_suffix,".",
     dgcs_col_name)
   ELSEIF (dgcs_type IN ("FLOAT", "NUMBER"))
    SET parse_rs->stmt[dgcs_stmt_idx].str = concat(parse_rs->stmt[dgcs_stmt_idx].str,"t",
     dgcs_tab_suffix,".",dgcs_col_name,
     ",cnvtdatetime(curdate,curtime3),'ABC'")
   ELSE
    SET parse_rs->stmt[dgcs_stmt_idx].str = concat(parse_rs->stmt[dgcs_stmt_idx].str,"0.0,t",
     dgcs_tab_suffix,".",dgcs_col_name,
     ",'ABC'")
   ENDIF
   SET dgcs_stmt_idx = (dgcs_stmt_idx+ 1)
   SET parse_rs->stmt[dgcs_stmt_idx].str = concat(")) from ",dgcs_src_tab_name," t",dgcs_tab_suffix)
   SET dgcs_stmt_idx = (dgcs_stmt_idx+ 1)
   SET parse_rs->stmt[dgcs_stmt_idx].str = concat(" ",sbr_pk_where,
    " detail dgcs_qual_cnt = dgcs_qual_cnt + 1 with nocounter,notrim, maxqual(t",dgcs_tab_suffix,
    ",1) go")
   EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","PARSE_RS")
   SET stat = initrec(parse_rs)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   IF (dgcs_qual_cnt=0)
    CALL echo(concat("The pk_where: ",sbr_pk_where," did not return any rows."))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drmm_get_exploded_pkw(sbr_tab_name,sbr_tab_suffix,sbr_db_link)
   DECLARE dgep_dcl_tab_name = vc WITH protect, noconstant(" ")
   DECLARE dgep_func_name = vc WITH protect, noconstant("")
   DECLARE dgep_func_prefix = vc WITH protect, noconstant("")
   DECLARE dgep_pk_where = vc WITH protect, noconstant(" ")
   DECLARE dgep_db_link = vc WITH protect, noconstant(" ")
   DECLARE dm2_context_control_wrapper() = i2
   DECLARE sys_context() = c4000
   IF ( NOT (validate(parse_rs,0)))
    FREE RECORD parse_rs
    RECORD parse_rs(
      1 stmt[*]
        2 str = vc
    ) WITH protect
   ENDIF
   IF (sbr_db_link > " ")
    SET dgep_db_link = sbr_db_link
   ENDIF
   SET dgep_func_prefix = concat("REFCHG_GEN_PK_PTAM_",sbr_tab_suffix)
   SET dgep_func_name = drmm_get_func_name(dgep_func_prefix," ")
   IF (dgep_func_name="")
    SET dm_err->emsg = concat("A col_string function is not built: ",dgep_func_prefix)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN("")
   ENDIF
   CALL parser(concat("declare ",dgep_func_name,"() = c2000 go"),1)
   SET stat = alterlist(parse_rs->stmt,4)
   SET parse_rs->stmt[1].str = "SELECT into 'nl:' dgep_pkw = "
   SET parse_rs->stmt[2].str = concat(dgep_func_name,
    "(1,0,SYS_CONTEXT('CERNER','RDDS_COL_STRING',4000),'",dgep_db_link,"',0) from dual")
   SET parse_rs->stmt[3].str = "detail dgep_pk_where = dgep_pkw "
   SET parse_rs->stmt[4].str = "with nocounter go"
   EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","PARSE_RS")
   SET stat = initrec(parse_rs)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("")
   ENDIF
   RETURN(dgep_pk_where)
 END ;Subroutine
 IF (check_logfile("dm_rmc_find_dcl",".log","dm_rmc_find_dcl LOG FILE...") != 1)
  SET dm_err->err_ind = 1
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 DECLARE drfd_pk_where = vc WITH protect, noconstant("")
 DECLARE drfd_del_pk_where = vc WITH protect, noconstant("")
 DECLARE drfd_table_suffix = vc WITH protect, noconstant("")
 DECLARE drfd_loop = i4 WITH protect, noconstant(0)
 DECLARE drfd_where_str = vc WITH protect, noconstant("")
 DECLARE drfd_dcl_name = vc WITH protect, noconstant("")
 DECLARE drfd_pkw_value = f8 WITH protect, noconstant(0.0)
 DECLARE drfd_del_pkw_value = f8 WITH protect, noconstant(0.0)
 DECLARE drfd_total = i4 WITH protect, noconstant(0)
 DECLARE drfd_idx = i4 WITH protect, noconstant(0)
 DECLARE drfd_ctp_str = vc WITH protect, noconstant("")
 DECLARE drfd_cs_ind = i2 WITH protect, noconstant(0)
 DECLARE drfd_get_cs_exploded(dgce_req=vc(ref),dgce_rep=vc(ref),dgce_idx=i4) = i2
 DECLARE dm_get_hash_value() = f8 WITH protect, noconstant(0.0)
 IF (validate(request->table_name,"-+")="-+")
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "The REQUEST structure must be declared prior to executing this script."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF ((validate(reply->row_cnt,- (99))=- (99)))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "The REPLY structure must be declared prior to executing this script."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF ((request->row_cnt=0))
  GO TO exit_program
 ENDIF
 SET request->table_name = cnvtupper(request->table_name)
 SELECT INTO "nl:"
  FROM dm_tables_doc dtd
  WHERE (dtd.full_table_name=request->table_name)
  DETAIL
   drfd_table_suffix = dtd.table_suffix
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="RDDS CURRENT STATE TABLES"
   AND d.info_name=patstring(concat(request->table_name,":*"))
  DETAIL
   drfd_cs_ind = 1
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF ((request->db_link > " "))
  SELECT INTO "NL:"
   FROM dm_info d
   WHERE d.info_domain="DATA MANAGEMENT"
    AND d.info_name="DM_ENV_ID"
   DETAIL
    drfd_where_str = concat("d.target_env_id = ",trim(cnvtstring(d.info_number,20,1)))
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
  IF (curqual=0)
   SET dm_err->err_ind = 1
   SET dm_err->emsg = "No environment_id found in DM_INFO.  Please run DM_SET_ENV_ID"
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
  SELECT INTO "NL:"
   FROM dm_info d
   WHERE d.info_domain="RDDS CONTEXT"
    AND d.info_name="CONTEXTS TO PULL"
   DETAIL
    drfd_ctp_str = concat("::",trim(d.info_char),"::")
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
 ELSE
  SET drfd_where_str = "1 = 1"
 ENDIF
 FOR (drfd_loop = 1 TO request->row_cnt)
   SET drfd_pk_where = concat("WHERE t",drfd_table_suffix,".ROWID = '",request->row_qual[drfd_loop].
    rowid,"'")
   CALL drmm_get_col_string(drfd_pk_where,0.0,request->table_name,drfd_table_suffix,request->db_link)
   SET drfd_pk_where = drmm_get_pk_where(request->table_name,drfd_table_suffix,0,request->db_link)
   SET drfd_del_pk_where = drmm_get_pk_where(request->table_name,drfd_table_suffix,1,request->db_link
    )
   SET drfd_pk_where = replace(drfd_pk_where,"'",'"',0)
   SET drfd_del_pk_where = replace(drfd_del_pk_where,"'",'"',0)
   SELECT INTO "nl:"
    pkw_value = dm_get_hash_value(drfd_pk_where,0,1073741824.0), del_pkw_value = dm_get_hash_value(
     drfd_del_pk_where,0,1073741824.0)
    FROM dual
    DETAIL
     drfd_pkw_value = pkw_value, drfd_del_pkw_value = del_pkw_value
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    GO TO exit_program
   ENDIF
   SET dm_err->eproc = "Searching for DCL row."
   SET drfd_dcl_name = concat("DM_CHG_LOG",request->db_link)
   SET drfd_total = 0
   SET drfd_idx = 0
   SELECT INTO "nl:"
    ctxt_ind = nullind(d.context_name)
    FROM (parser(drfd_dcl_name) d)
    WHERE (d.table_name=request->table_name)
     AND ((d.delete_ind=0
     AND d.pk_where=drfd_pk_where
     AND d.pk_where_value=drfd_pkw_value) OR (d.delete_ind=1
     AND d.pk_where=drfd_del_pk_where
     AND d.pk_where_value=drfd_del_pkw_value))
     AND parser(drfd_where_str)
    ORDER BY d.target_env_id, d.context_name
    HEAD REPORT
     reply->row_cnt = (reply->row_cnt+ 1), stat = alterlist(reply->row_qual,reply->row_cnt), reply->
     row_qual[reply->row_cnt].rowid = request->row_qual[drfd_loop].rowid,
     drfd_idx = reply->row_cnt
    DETAIL
     reply->row_qual[drfd_idx].dcl_cnt = (reply->row_qual[drfd_idx].dcl_cnt+ 1), drfd_total = reply->
     row_qual[drfd_idx].dcl_cnt, stat = alterlist(reply->row_qual[drfd_idx].dcl_qual,drfd_total),
     reply->row_qual[drfd_idx].dcl_qual[drfd_total].delete_ind = d.delete_ind, reply->row_qual[
     drfd_idx].dcl_qual[drfd_total].log_type = d.log_type, reply->row_qual[drfd_idx].dcl_qual[
     drfd_total].log_id = d.log_id,
     reply->row_qual[drfd_idx].dcl_qual[drfd_total].target_env_id = d.target_env_id
     IF (ctxt_ind=1)
      reply->row_qual[drfd_idx].dcl_qual[drfd_total].context_name = "NULL"
     ELSE
      reply->row_qual[drfd_idx].dcl_qual[drfd_total].context_name = d.context_name
     ENDIF
     reply->row_qual[drfd_idx].dcl_qual[drfd_total].dm_chg_log_exception_id = d
     .dm_chg_log_exception_id, reply->row_qual[drfd_idx].dcl_qual[drfd_total].pk_where = d.pk_where
     IF (((findstring(concat("::",reply->row_qual[drfd_idx].dcl_qual[drfd_total].context_name,"::"),
      drfd_ctp_str,1,0) > 0) OR (findstring("::ALL::",drfd_ctp_str,1,0) > 0)) )
      reply->row_qual[drfd_idx].dcl_qual[drfd_total].context_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    GO TO exit_program
   ENDIF
   IF (drfd_cs_ind=1)
    SET drfd_pk_where = drmm_get_exploded_pkw(request->table_name,drfd_table_suffix,request->db_link)
    SET drfd_pk_where = replace(drfd_pk_where,"'",'"',0)
    SELECT INTO "nl:"
     pkw_value = dm_get_hash_value(drfd_pk_where,0,1073741824.0)
     FROM dual
     DETAIL
      drfd_pkw_value = pkw_value
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     GO TO exit_program
    ENDIF
    SET dm_err->eproc = "Searching for DCL row."
    SET drfd_dcl_name = concat("DM_CHG_LOG",request->db_link)
    SELECT INTO "nl:"
     ctxt_ind = nullind(d.context_name)
     FROM (parser(drfd_dcl_name) d)
     WHERE (d.table_name=request->table_name)
      AND d.delete_ind=0
      AND d.pk_where=drfd_pk_where
      AND d.pk_where_value=drfd_pkw_value
      AND parser(drfd_where_str)
     ORDER BY d.target_env_id, d.context_name
     HEAD REPORT
      drfd_idx = reply->row_cnt
     DETAIL
      reply->row_qual[drfd_idx].dcl_cnt = (reply->row_qual[drfd_idx].dcl_cnt+ 1), drfd_total = reply
      ->row_qual[drfd_idx].dcl_cnt, stat = alterlist(reply->row_qual[drfd_idx].dcl_qual,drfd_total),
      reply->row_qual[drfd_idx].dcl_qual[drfd_total].delete_ind = d.delete_ind, reply->row_qual[
      drfd_idx].dcl_qual[drfd_total].log_type = d.log_type, reply->row_qual[drfd_idx].dcl_qual[
      drfd_total].log_id = d.log_id,
      reply->row_qual[drfd_idx].dcl_qual[drfd_total].target_env_id = d.target_env_id
      IF (ctxt_ind=1)
       reply->row_qual[drfd_idx].dcl_qual[drfd_total].context_name = "NULL"
      ELSE
       reply->row_qual[drfd_idx].dcl_qual[drfd_total].context_name = d.context_name
      ENDIF
      reply->row_qual[drfd_idx].dcl_qual[drfd_total].dm_chg_log_exception_id = d
      .dm_chg_log_exception_id, reply->row_qual[drfd_idx].dcl_qual[drfd_total].pk_where = d.pk_where
      IF (((findstring(concat("::",reply->row_qual[drfd_idx].dcl_qual[drfd_total].context_name,"::"),
       drfd_ctp_str,1,0) > 0) OR (findstring("::ALL::",drfd_ctp_str,1,0) > 0)) )
       reply->row_qual[drfd_idx].dcl_qual[drfd_total].context_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     GO TO exit_program
    ENDIF
   ENDIF
 ENDFOR
 FOR (drfd_loop = 1 TO reply->row_cnt)
  CALL echo(concat("ROWID = '",reply->row_qual[drfd_loop].rowid,"'"))
  FOR (drfd_idx = 1 TO reply->row_qual[drfd_loop].dcl_cnt)
    CALL echo(concat("    ",trim(cnvtstring(reply->row_qual[drfd_loop].dcl_qual[drfd_idx].log_id,20,1
        )),"  ",reply->row_qual[drfd_loop].dcl_qual[drfd_idx].log_type,"   ",
      trim(cnvtstring(reply->row_qual[drfd_loop].dcl_qual[drfd_idx].target_env_id,20,1)),"   ",reply
      ->row_qual[drfd_loop].dcl_qual[drfd_idx].context_name,"-",trim(cnvtstring(reply->row_qual[
        drfd_loop].dcl_qual[drfd_idx].context_ind))))
  ENDFOR
 ENDFOR
#exit_program
END GO
