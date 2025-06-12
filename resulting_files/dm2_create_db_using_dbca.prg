CREATE PROGRAM dm2_create_db_using_dbca
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
 IF (validate(dm2_create_dom->ora_root," ")=" "
  AND validate(dm2_create_dom->ora_root,"Z")="Z")
  FREE RECORD dm2_create_dom
  RECORD dm2_create_dom(
    1 oracle_home = vc
    1 asm_home = vc
    1 local_ccluserdir = vc
    1 asm_sid = vc
    1 oracle_version = vc
    1 ora_root = vc
    1 ora_db = vc
    1 node_name = vc
    1 db_node_name = vc
    1 dname = vc
    1 dbtype = vc
    1 admin_port = vc
    1 clinical_port = vc
    1 env_id = vc
    1 env_name = vc
    1 domain_account = vc
    1 local_db = i2
    1 rmt_temp_dir = vc
    1 rmt_os = vc
    1 tns_host = vc
    1 db_node_root_pass = vc
    1 db_node_oracle_pass = vc
    1 oracle_sys_pass = vc
    1 oracle_system_pass = vc
    1 asm_storage_dg = vc
    1 asm_recovery_dg = vc
    1 dbca_template_name = vc
    1 oracle_base = vc
    1 dbtype = vc
    1 dname = vc
    1 oracle_sys_pass = vc
    1 oracle_system_pass = vc
    1 asm_sysdba_pass = vc
    1 asm_recovery_dg = vc
    1 asm_storage_dg = vc
    1 log_archive_dest_1 = vc
    1 response_file_in_use = i2
    1 rmt_oracle_home = vc
    1 crs_healthy_ind = i2
    1 hasuser = vc
    1 crs_home = vc
    1 crs_state = vc
    1 rac_option = vc
    1 crsctl_chk = vc
    1 db_ora_ver = vc
  )
  SET dm2_create_dom->oracle_home = "dm2_not_set"
  SET dm2_create_dom->oracle_version = "dm2_not_set"
  SET dm2_create_dom->ora_root = "dm2_not_set"
  SET dm2_create_dom->ora_db = "dm2_not_set"
  SET dm2_create_dom->node_name = curnode
  SET dm2_create_dom->dname = "dm2_not_set"
  SET dm2_create_dom->dbtype = "dm2_not_set"
  SET dm2_create_dom->admin_port = "1521"
  SET dm2_create_dom->clinical_port = "1521"
  SET dm2_create_dom->env_id = "dm2_not_set"
  SET dm2_create_dom->env_name = logical("environment")
  SET dm2_create_dom->local_db = 1
  SET dm2_create_dom->oracle_base = "/u02"
  SET dm2_create_dom->local_ccluserdir = trim(logical("CCLUSERDIR"))
  SET dm2_create_dom->log_archive_dest_1 = "dm2_not_set"
  SET dm2_create_dom->hasuser = "DM2_NOT_SET"
  SET dm2_create_dom->crs_home = "DM2_NOT_SET"
  SET dm2_create_dom->crs_state = "DM2_NOT_SET"
  SET dm2_create_dom->rac_option = "DM2_NOT_SET"
  SET dm2_create_dom->crsctl_chk = "DM2_NOT_SET"
  SET dm2_create_dom->db_ora_ver = "DM2_NOT_SET"
 ENDIF
 IF ((validate(dcd_templates->temp_cnt,- (1))=- (1))
  AND (validate(dcd_templates->temp_cnt,- (2))=- (2)))
  FREE RECORD dcd_templates
  RECORD dcd_templates(
    1 temp_cnt = i2
    1 qual[*]
      2 temp_name = vc
      2 action_type = vc
      2 outfile_name = vc
  )
  SET dcd_templates->temp_cnt = 0
 ENDIF
 IF ((validate(dcd_ftxt->txt_cnt,- (1))=- (1))
  AND (validate(dcd_ftxt->txt_cnt,- (2))=- (2)))
  FREE RECORD dcd_ftxt
  RECORD dcd_ftxt(
    1 txt_cnt = i4
    1 txt[*]
      2 txt_line = vc
  )
 ENDIF
 IF ((validate(dcd_disk_groups->dg_cnt,- (1))=- (1))
  AND (validate(dcd_disk_groups->dg_cnt,- (2))=- (2)))
  FREE RECORD dcd_disk_groups
  RECORD dcd_disk_groups(
    1 dg_cnt = i4
    1 dg_list = vc
    1 qual[*]
      2 dg_name = vc
  )
 ENDIF
 DECLARE dcd_db_reg_entries(null) = i2
 DECLARE dcd_ora_installed(null) = i2
 DECLARE dcd_prompt_for_dom_info(null) = i2
 DECLARE dcd_get_ora_ver(null) = i2
 DECLARE dcd_exec_shutdown_script(null) = i2
 DECLARE dcd_load_sr_rec(null) = null
 DECLARE dcd_add_sr_data(sbr_search_val_str=vc,sbr_replace_val_str=vc) = null
 DECLARE dcd_prompt_quit(sbr_exists_str=vc) = i2
 DECLARE dcd_exec_load_hist(null) = i2
 DECLARE dcd_exec_load_hist_afe(null) = i2
 DECLARE dcd_write_login_default(null) = i2
 DECLARE dcd_get_account_name(null) = i2
 DECLARE dcd_load_sids(dcd_dbtype=vc) = i2
 DECLARE dcd_set_envid(null) = i2
 DECLARE dcd_add_text(dat_in_text=vc,dat_in_reset_ind=i2) = null
 DECLARE dcd_create_text_file(dctf_in_fname=vc) = i2
 DECLARE dcd_process_response(null) = i2
 DECLARE dcd_validate_response(null) = i2
 DECLARE dcd_gather_available_disk_groups(null) = i2
 DECLARE dcd_perform_query(dqa_query=vc,dqa_retfile=vc(ref),dqa_ora_home=vc,dqa_ora_sid=vc,dqa_user=
  vc) = i2
 DECLARE dcd_check_crs(dcc_local=i2,dcc_node=vc,dcc_os_user=vc) = i2
 DECLARE dcd_get_asm_data(null) = i2
 DECLARE dcd_get_ora_kernel_user(null) = i2
 DECLARE dcd_get_rac_config(null) = i2
 SUBROUTINE dcd_check_crs(dcc_local,dcc_node,dcc_os_user)
   DECLARE dcs_start_pos = i4 WITH protect, noconstant(0)
   DECLARE dcs_exe_fname1 = vc WITH protect, noconstant(" ")
   DECLARE dcs_exe_fname2 = vc WITH protect, noconstant(" ")
   DECLARE dcs_source_fname1 = vc WITH protect, noconstant(concat(dm2_create_dom->local_ccluserdir,
     "/dm2_ora_crs_home.ksh"))
   DECLARE dcs_source_fname2 = vc WITH protect, noconstant(concat(dm2_create_dom->local_ccluserdir,
     "/dm2_crs_healthy.ksh"))
   SET dm2_create_dom->crs_state = "unhealthy"
   SET dm_err->eproc = concat("Check for ORA_CRS_HOME on ",dcc_node,".")
   CALL disp_msg(" ",dm_err->logfile,0)
   CALL dcd_add_text(" ",1)
   CALL dcd_add_text("#!/bin/ksh",0)
   CALL dcd_add_text('[[ `uname` = "AIX" ]] && ID=/etc INV_LOC=/etc',0)
   CALL dcd_add_text('[[ `uname` = "HP-UX" ]] && ID=/sbin/init.d INV_LOC=/var/opt/oracle',0)
   CALL dcd_add_text('[[ `uname` = "Linux" ]] && ID=/etc/init.d INV_LOC=/etc',0)
   CALL dcd_add_text("export ORA_INV=`grep inventory_loc ${INV_LOC}/oraInst.loc | cut -d= -f2`",0)
   CALL dcd_add_text(concat(
     'export ORA_CRS_HOME=`grep "NAME=" ${ORA_INV}/ContentsXML/inventory.xml  | grep -Ev ',
     ^"REMOVED=|NODE NAME=" | grep "CRS=" | awk '{print $3}' | cut -d\" -f2`^),0)
   CALL dcd_add_text("if [[ -z ${ORA_CRS_HOME} ]]",0)
   CALL dcd_add_text("then",0)
   CALL dcd_add_text('  export ORA_CRS_HOME=`grep "ORA_CRS_HOME=" ${ID}/init.cssd | cut -f2 -d"="`',0
    )
   CALL dcd_add_text("fi",0)
   CALL dcd_add_text("if [[ ! -z ${ORA_CRS_HOME} ]]",0)
   CALL dcd_add_text("then",0)
   CALL dcd_add_text("  if [[ ! -d ${ORA_CRS_HOME} ]]",0)
   CALL dcd_add_text("  then",0)
   CALL dcd_add_text('   echo "CER-00000: error - Directory ${ORA_CRS_HOME} not found."',0)
   CALL dcd_add_text("    exit 1",0)
   CALL dcd_add_text("  fi",0)
   CALL dcd_add_text("fi",0)
   CALL dcd_add_text('echo "ORA_CRS_HOME:<${ORA_CRS_HOME}>"',0)
   IF (dcd_create_text_file(dcs_source_fname1)=0)
    RETURN(0)
   ENDIF
   IF (dcc_local=0)
    SET dm_err->eproc = "Copy dm2_ora_crs_home to target node."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dcs_exe_fname1 = concat(dm2_create_dom->rmt_temp_dir,"/dm2_ora_crs_home.ksh")
    CALL dor_init_flex_cmds(null)
    CALL dor_add_flex_cmd(dcc_local,"root",dcc_node,dcs_source_fname1," ",
     dcs_exe_fname1,"RCP")
    IF (dor_exec_flex_cmd(null)=0)
     RETURN(0)
    ENDIF
   ELSE
    SET dcs_exe_fname1 = concat('"',dm2_create_dom->local_ccluserdir,'/dm2_ora_crs_home.ksh"')
   ENDIF
   SET dm_err->eproc = "Execute the dm2_ora_crs_home check script."
   CALL disp_msg(" ",dm_err->logfile,0)
   CALL dor_init_flex_cmds(null)
   CALL dor_add_flex_cmd(dcc_local,"oracle",dcc_node,dcs_exe_fname1," ",
    " ","EFORO")
   IF (dor_exec_flex_cmd(null)=0)
    RETURN(0)
   ENDIF
   IF (trim(dor_flex_cmd->cmd[1].flex_output) > " ")
    IF (findstring("ORA_CRS_HOME:",dor_flex_cmd->cmd[1].flex_output,1,0) > 0)
     SET dcs_start_pos = findstring("ORA_CRS_HOME:",dor_flex_cmd->cmd[1].flex_output,1,0)
     SET dm2_create_dom->crs_home = trim(substring((dcs_start_pos+ 14),((size(dor_flex_cmd->cmd[1].
        flex_output,1) - findstring("<",dor_flex_cmd->cmd[1].flex_output,dcs_start_pos,0)) - 1),
       dor_flex_cmd->cmd[1].flex_output))
     IF ((dm2_create_dom->crs_home=" "))
      SET dm2_create_dom->crs_state = " "
      SET dm_err->eproc =
      "Unable to obtain CRS_HOME from /etc/init.d/init.cssd. Return CRS status as Unhealthy."
      CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
      RETURN(1)
     ENDIF
    ELSE
     IF (findstring("CER-00000",cnvtupper(dm_err->errtext),1,0) > 0)
      SET dm_err->emsg = concat(substring(findstring("CER-00000",cnvtupper(dor_flex_cmd->cmd[1].
          flex_output),1,1),(size(dor_flex_cmd->cmd[1].flex_output) - findstring("CER-00000",
         cnvtupper(dor_flex_cmd->cmd[1].flex_output),1,1)),dor_flex_cmd->cmd[1].flex_output),".")
     ELSE
      SET dm_err->emsg = dor_flex_cmd->cmd[1].flex_output
     ENDIF
     SET message = nowindow
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm2_create_dom->crs_home="DM2_NOT_SET"))
    SET dm2_create_dom->crs_state = " "
    SET dm_err->eproc =
    "Unable to obtain CRS_HOME from /etc/init.d/init.cssd. Return CRS status as Unhealthy."
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
    RETURN(1)
   ENDIF
   IF (cnvtlower(dm2_create_dom->hasuser)="oracle")
    SET dm2_create_dom->crsctl_chk = "has"
   ELSE
    SET dm2_create_dom->crsctl_chk = "crs"
   ENDIF
   SET dm_err->eproc = concat("Check status of CRS on ",dcc_node,".")
   CALL disp_msg(" ",dm_err->logfile,0)
   CALL dcd_add_text(" ",1)
   CALL dcd_add_text("#!/bin/ksh",0)
   CALL dcd_add_text('export CRS_HEALTH="UNHEALTHY"',0)
   CALL dcd_add_text(concat("export ORA_CRS_HOME=",dm2_create_dom->crs_home),0)
   CALL dcd_add_text(concat("export CRSCTL_CHK=",dm2_create_dom->crsctl_chk),0)
   CALL dcd_add_text('export CRS_VAR="CRS|Cluster Ready Services"',0)
   CALL dcd_add_text(concat(
     'export CRS_VAR2="appears healthy|Cluster Ready Services is online|Oracle High Availability ',
     'Services is online"'),0)
   CALL dcd_add_text(
    'if [[ `${ORA_CRS_HOME}/bin/crsctl check ${CRSCTL_CHK} | grep -E "${CRS_VAR}" | wc -l` -gt 0 ]]',
    0)
   CALL dcd_add_text("then",0)
   CALL dcd_add_text(
    '  export CRS_STATUS=`${ORA_CRS_HOME}/bin/crsctl check ${CRSCTL_CHK} | grep -E "${CRS_VAR}"`',0)
   CALL dcd_add_text('  echo "CRS status: ${CRS_STATUS}"',0)
   CALL dcd_add_text('  if [[ `echo ${CRS_STATUS} | grep -E  "${CRS_VAR2}" | wc -l` -gt 0 ]]',0)
   CALL dcd_add_text("  then",0)
   CALL dcd_add_text('    export CRS_HEALTH="HEALTHY"',0)
   CALL dcd_add_text("  fi",0)
   CALL dcd_add_text("fi",0)
   CALL dcd_add_text('echo " CRS_STATE:<${CRS_HEALTH}>"',0)
   IF (dcd_create_text_file(dcs_source_fname2)=0)
    RETURN(0)
   ENDIF
   IF (dcc_local=0)
    SET dcs_exe_fname2 = concat(dm2_create_dom->rmt_temp_dir,"/dm2_crs_healthy.ksh")
    SET dm_err->eproc = "Copy dm2_crs_healthy to target node."
    CALL dor_init_flex_cmds(null)
    CALL dor_add_flex_cmd(dcc_local,"root",dcc_node,dcs_source_fname2," ",
     dcs_exe_fname2,"RCP")
    IF (dor_exec_flex_cmd(null)=0)
     RETURN(0)
    ENDIF
   ELSE
    SET dcs_exe_fname2 = concat('"',dm2_create_dom->local_ccluserdir,'/dm2_crs_healthy.ksh"')
   ENDIF
   SET dm_err->eproc = "Execute the dm2_crs_healthy check script."
   CALL disp_msg(" ",dm_err->logfile,0)
   CALL dor_init_flex_cmds(null)
   CALL dor_add_flex_cmd(dcc_local,"oracle",dcc_node,dcs_exe_fname2," ",
    " ","EFORO")
   IF (dor_exec_flex_cmd(null)=0)
    RETURN(0)
   ENDIF
   IF (trim(dor_flex_cmd->cmd[1].flex_output) > " ")
    IF (findstring("CRS_STATE:",dor_flex_cmd->cmd[1].flex_output,1,0) > 0)
     SET dcs_start_pos = findstring("CRS_STATE:",dor_flex_cmd->cmd[1].flex_output,1,0)
     SET dm2_create_dom->crs_state = trim(substring((dcs_start_pos+ 11),((size(dor_flex_cmd->cmd[1].
        flex_output,1) - findstring("<",dor_flex_cmd->cmd[1].flex_output,dcs_start_pos,0)) - 1),
       dor_flex_cmd->cmd[1].flex_output))
     IF ((dm2_create_dom->crs_state=" "))
      SET dm_err->eproc = "CRS status not found."
      CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
      RETURN(0)
     ENDIF
    ELSE
     SET dm_err->emsg = dor_flex_cmd->cmd[1].flex_output
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    SET dm2_create_dom->crs_state = "unhealthy"
    SET dm_err->eproc = "Unable to obtain CRS status from crsctl. Return CRS status as Unhealthy."
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
    RETURN(1)
   ENDIF
   IF ( NOT (cnvtupper(dm2_create_dom->crs_state) IN ("HEALTHY", "UNHEALTHY")))
    SET dm_err->emsg =
    "Invalid value for: dm2_create_dom->crs_state. Valid entries are HEALTHY or UNHEALTHY."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcd_perform_query(dqa_query,dqa_retfile,dqa_ora_home,dqa_ora_sid,dqa_user)
   DECLARE dqa_out_file = vc WITH protect, noconstant(concat(dm2_create_dom->local_ccluserdir,
     "/dm2_perform_query.out"))
   DECLARE dqa_rmtout_file = vc WITH protect, noconstant(concat(dm2_create_dom->rmt_temp_dir,
     "/dm2_perform_query.out"))
   DECLARE dqa_sql_file = vc WITH protect, noconstant(concat(dm2_create_dom->rmt_temp_dir,
     "/dm2_perform_query.sql"))
   DECLARE dqa_rmtexec_file = vc WITH protect, noconstant(concat(dm2_create_dom->rmt_temp_dir,
     "/dm2_perform_query.ksh"))
   DECLARE dqa_exec_file = vc WITH protect, noconstant(concat(dm2_create_dom->rmt_temp_dir,
     "/dm2_perform_query.ksh"))
   SET dqa_retfile = dqa_out_file
   IF ((dm_err->debug_flag > 0))
    CALL echo(dqa_query)
   ENDIF
   CALL dcd_add_text("#!/usr/bin/ksh",1)
   CALL dcd_add_text(concat("export ORACLE_HOME=",dqa_ora_home),0)
   CALL dcd_add_text(concat('export ORACLE_SID="',dqa_ora_sid,'"'),0)
   CALL dcd_add_text(concat("rm -f ",dqa_sql_file),0)
   IF ((dm2_create_dom->local_db=1))
    CALL dcd_add_text(concat("rm -f ",dqa_out_file),0)
    CALL dcd_add_text(concat('echo "SPOOL ',dqa_out_file,'" > ',dqa_sql_file),0)
   ELSE
    CALL dcd_add_text(concat("rm -f ",dqa_rmtout_file),0)
    CALL dcd_add_text(concat('echo "SPOOL ',dqa_rmtout_file,'" > ',dqa_sql_file),0)
   ENDIF
   CALL dcd_add_text(concat('echo "SET NEWPAGE 0" >> ',dqa_sql_file),0)
   CALL dcd_add_text(concat('echo "SET SPACE 0" >> ',dqa_sql_file),0)
   CALL dcd_add_text(concat('echo "SET LINESIZE 80" >> ',dqa_sql_file),0)
   CALL dcd_add_text(concat('echo "SET PAGESIZE 0" >> ',dqa_sql_file),0)
   CALL dcd_add_text(concat('echo "SET ECHO OFF" >> ',dqa_sql_file),0)
   CALL dcd_add_text(concat('echo "SET FEEDBACK OFF" >> ',dqa_sql_file),0)
   CALL dcd_add_text(concat('echo "SET VERIFY OFF" >> ',dqa_sql_file),0)
   CALL dcd_add_text(concat('echo "SET HEADING OFF" >> ',dqa_sql_file),0)
   CALL dcd_add_text(concat('echo "SET MARKUP HTML OFF" >> ',dqa_sql_file),0)
   CALL dcd_add_text(concat('echo "',dqa_query,'" >> ',dm2_create_dom->rmt_temp_dir,
     "/dm2_perform_query.sql"),0)
   CALL dcd_add_text(concat('echo "SPOOL OFF" >> ',dqa_sql_file),0)
   CALL dcd_add_text("$ORACLE_HOME/bin/sqlplus '/as sysdba' <<endSQL",0)
   CALL dcd_add_text(concat("@",dqa_sql_file),0)
   CALL dcd_add_text("exit",0)
   CALL dcd_add_text("endSQL",0)
   IF (dcd_create_text_file(dqa_exec_file)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Execute the query and return the results to ",dqa_out_file)
   CALL dor_init_flex_cmds(null)
   IF ((dm2_create_dom->local_db=0))
    CALL dor_add_flex_cmd(dm2_create_dom->local_db,"root",dm2_create_dom->db_node_name,dqa_exec_file,
     " ",
     dqa_rmtexec_file,"RCP")
   ENDIF
   CALL dor_add_flex_cmd(dm2_create_dom->local_db,"oracle",dm2_create_dom->db_node_name,
    dqa_rmtexec_file," ",
    " ","EFO")
   IF ((dm2_create_dom->local_db=0))
    CALL dor_add_flex_cmd(dm2_create_dom->local_db,"root",dm2_create_dom->db_node_name,dqa_out_file,
     " ",
     dqa_rmtout_file,"RCPBACK")
   ENDIF
   IF (dor_exec_flex_cmd(null)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Verify ",dqa_out_file," exists.")
   CALL dor_init_flex_cmds(null)
   CALL dor_add_flex_cmd(1," "," "," ",concat("test -f ",dqa_out_file," ;echo $?"),
    " ","EC")
   IF (dor_exec_flex_cmd(null)=0)
    RETURN(0)
   ENDIF
   IF ((dor_flex_cmd->cmd[1].flex_output="1"))
    IF ((dm2_create_dom->response_file_in_use=0))
     SET message = nowindow
    ENDIF
    SET dm_err->emsg = "Output file does not exist"
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcd_gather_available_disk_groups(null)
   DECLARE dgadg_strt = i2 WITH protect, noconstant(0)
   DECLARE dgadg_end = i2 WITH protect, noconstant(0)
   DECLARE dgadg_query = vc WITH protect, noconstant("")
   DECLARE dgadg_outfile = vc WITH protect, noconstant("")
   SET dgadg_query = "select name||',' from v\$asm_diskgroup;"
   SET dm_err->eproc = "Gather available disk groups"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dcd_perform_query(dgadg_query,dgadg_outfile,dm2_create_dom->asm_home,dm2_create_dom->asm_sid,
    "oracle")=0)
    RETURN(0)
   ENDIF
   IF (parse_errfile(dgadg_outfile)=0)
    RETURN(0)
   ENDIF
   SET dcd_disk_groups->dg_list = substring(1,(findstring(",",dm_err->errtext,1,1) - 1),dm_err->
    errtext)
   IF ((((dcd_disk_groups->dg_list="")) OR (findstring(",",dm_err->errtext,1,1) != size(dm_err->
    errtext))) )
    IF ((dm2_create_dom->response_file_in_use=0))
     SET message = nowindow
    ENDIF
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Unable to parse errfile. Output in invalid format."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    CALL echorecord(dm_err)
    CALL echorecord(dcd_disk_groups)
    RETURN(0)
   ENDIF
   SET dgadg_strt = 1
   WHILE (dgadg_strt < size(dm_err->errtext))
     SET dgadg_end = findstring(",",dm_err->errtext,dgadg_strt,0)
     SET dcd_disk_groups->dg_cnt = (dcd_disk_groups->dg_cnt+ 1)
     SET stat = alterlist(dcd_disk_groups->qual,dcd_disk_groups->dg_cnt)
     SET dcd_disk_groups->qual[dcd_disk_groups->dg_cnt].dg_name = substring(dgadg_strt,(dgadg_end -
      dgadg_strt),dm_err->errtext)
     SET dgadg_strt = (dgadg_end+ 1)
   ENDWHILE
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm_err)
    CALL echorecord(dcd_disk_groups)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcd_process_response(null)
   DECLARE dpr_cnt = i4 WITH protect, noconstant(0)
   DECLARE dpr_file = vc WITH protect, noconstant(concat(dm2_create_dom->local_ccluserdir,
     "/dm2_response_data.dat"))
   FREE RECORD dpr_cmd
   RECORD dpr_cmd(
     1 qual[*]
       2 rs_item = vc
       2 rs_item_value = vc
   )
   IF (dm2_findfile(dpr_file)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Attempting to access ",dpr_file)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET logical dpr_config_file dpr_file
   FREE DEFINE rtl
   DEFINE rtl "dpr_config_file"
   SELECT INTO "nl:"
    t.line
    FROM rtlt t
    WHERE t.line > " "
    DETAIL
     dpr_cnt = (dpr_cnt+ 1), stat = alterlist(dpr_cmd->qual,dpr_cnt), dpr_cmd->qual[dpr_cnt].rs_item
      = substring(1,(findstring("=",t.line,1,0) - 1),t.line),
     dpr_cmd->qual[dpr_cnt].rs_item_value = substring((findstring("=",t.line,1,0)+ 1),(size(t.line)
       - findstring("=",t.line,1,0)),t.line)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dpr_cmd)
   ENDIF
   SET dpr_cnt = 0
   FOR (dpr_cnt = 1 TO size(dpr_cmd->qual,5))
     CALL parser(concat("set dm2_create_dom->",dpr_cmd->qual[dpr_cnt].rs_item," = ",cnvtlower(dpr_cmd
        ->qual[dpr_cnt].rs_item_value)," go"),1)
   ENDFOR
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Verify response data specified correctly."
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((((dm2_create_dom->rmt_os < " ")) OR ((((dm2_create_dom->tns_host < " ")) OR ((((
   dm2_create_dom->clinical_port < " ")) OR ((((dm2_create_dom->dbtype < " ")) OR ((((dm2_create_dom
   ->db_node_name < " ")) OR ((((dm2_create_dom->dname < " ")) OR ((((dm2_create_dom->oracle_sys_pass
    < " ")) OR ((((dm2_create_dom->oracle_system_pass < " ")) OR ((((dm2_create_dom->rmt_oracle_home
    < " ")) OR ((((dm2_create_dom->asm_recovery_dg < " ")) OR ((((dm2_create_dom->asm_storage_dg <
   " ")) OR ((dm2_create_dom->asm_sysdba_pass < " "))) )) )) )) )) )) )) )) )) )) )) )
    CALL echorecord(dm2_create_dom)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Not all data specified in dm2_response_data.dat."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcd_validate_response(null)
   DECLARE dvr_cnt = i2 WITH protect, noconstant(0)
   DECLARE dvr_check_name = vc WITH protect, noconstant("")
   DECLARE dvr_ndx = i2 WITH protect, noconstant(0)
   FREE RECORD dvr_emsg
   RECORD dvr_emsg(
     1 de_cnt = i2
     1 qual[*]
       2 msg = vc
   )
   SET dvr_emsg->de_cnt = 0
   SET stat = alterlist(dvr_emsg->qual,10)
   SET dm_err->eproc = "Validate the response file entries."
   CALL disp_msg("",dm_err->logfile,0)
   SET dm2_create_dom->rmt_os = cnvtupper(dm2_create_dom->rmt_os)
   SET dm2_create_dom->asm_storage_dg = cnvtupper(dm2_create_dom->asm_storage_dg)
   SET dm2_create_dom->asm_recovery_dg = cnvtupper(dm2_create_dom->asm_recovery_dg)
   IF ( NOT ((dm2_create_dom->dbtype IN ("strt", "admin"))))
    SET dvr_emsg->de_cnt = (dvr_emsg->de_cnt+ 1)
    SET dvr_emsg->qual[dvr_emsg->de_cnt].msg = concat("Invalid entry:",cnvtupper(dm2_create_dom->
      dbtype),". Valid entries are STRT or ADMIN.")
   ENDIF
   CALL dor_init_flex_cmds(null)
   CALL dor_add_flex_cmd(0,"root",dm2_create_dom->db_node_name," ","hostname",
    " ","EC")
   IF (dor_exec_flex_cmd(null)=0)
    RETURN(0)
   ENDIF
   IF (findstring(".",dor_flex_cmd->cmd[1].flex_output,1,0) > 0)
    SET dvr_check_name = cnvtlower(substring(1,(findstring(".",dor_flex_cmd->cmd[1].flex_output,1,0)
       - 1),dor_flex_cmd->cmd[1].flex_output))
   ELSE
    SET dvr_check_name = cnvtlower(dor_flex_cmd->cmd[1].flex_output)
   ENDIF
   IF ((dvr_check_name != dm2_create_dom->db_node_name))
    SET dvr_emsg->de_cnt = (dvr_emsg->de_cnt+ 1)
    SET dvr_emsg->qual[dvr_emsg->de_cnt].msg = concat("Invalid primary db node entry:",dm2_create_dom
     ->db_node_name,". Unable to communicate with remote node via SSH or hostname is not valid.")
   ENDIF
   IF ((dvr_emsg->de_cnt=0))
    IF (dcd_load_sids(dm2_create_dom->dbtype)=0)
     RETURN(0)
    ENDIF
    CALL dor_init_flex_cmds(null)
    CALL dor_add_flex_cmd(0,"root",dm2_create_dom->db_node_name," ",concat("test -d ",dm2_create_dom
      ->rmt_oracle_home," ;echo $?"),
     " ","EC")
    IF (dor_exec_flex_cmd(null)=0)
     RETURN(0)
    ENDIF
    IF ((dor_flex_cmd->cmd[1].flex_output IN ("", "1")))
     SET dvr_emsg->de_cnt = (dvr_emsg->de_cnt+ 1)
     SET dvr_emsg->qual[dvr_emsg->de_cnt].msg = concat("Invalid entry:",dm2_create_dom->
      rmt_oracle_home,". Directory not found on remote primary database node.")
    ENDIF
    IF (findstring("11.1",dm2_create_dom->oracle_home,1,0) > 0)
     SET dm2_create_dom->db_ora_ver = "11.1"
    ELSE
     SET dm2_create_dom->db_ora_ver = "11.2"
    ENDIF
    IF (dcd_get_asm_data(null)=0)
     RETURN(0)
    ENDIF
    IF (dcd_gather_available_disk_groups(null)=0)
     RETURN(0)
    ENDIF
    IF (locateval(dvr_ndx,1,dcd_disk_groups->dg_cnt,dm2_create_dom->asm_recovery_dg,dcd_disk_groups->
     qual[dvr_ndx].dg_name)=0)
     SET dvr_emsg->de_cnt = (dvr_emsg->de_cnt+ 1)
     SET dvr_emsg->qual[dvr_emsg->de_cnt].msg = concat("Recovery disk group invalid entry:",
      dm2_create_dom->asm_recovery_dg,". Disk Group not found within ASM.")
    ENDIF
    IF (locateval(dvr_ndx,1,dcd_disk_groups->dg_cnt,dm2_create_dom->asm_storage_dg,dcd_disk_groups->
     qual[dvr_ndx].dg_name)=0)
     SET dvr_emsg->de_cnt = (dvr_emsg->de_cnt+ 1)
     SET dvr_emsg->qual[dvr_emsg->de_cnt].msg = concat("Storage disk group invalid entry:",
      dm2_create_dom->asm_storage_dg,". Disk Group not found within ASM.")
    ENDIF
    IF ((dm2_create_dom->log_archive_dest_1="dm2_not_set"))
     SET dm2_create_dom->log_archive_dest_1 = concat("LOCATION=+",dm2_create_dom->asm_recovery_dg,"/",
      dm2_create_dom->dname)
    ELSEIF (cnvtlower(dm2_create_dom->log_archive_dest_1) != patstring("location=*"))
     SET dvr_emsg->de_cnt = (dvr_emsg->de_cnt+ 1)
     SET dvr_emsg->qual[dvr_emsg->de_cnt].msg =
     "Value for LOG_ARCHIVE_DEST_1 must begin with 'LOCATION='."
    ENDIF
   ENDIF
   IF ((dvr_emsg->de_cnt=0))
    SET dm_err->eproc = "Response file entries are valid, proceeding with installation."
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   SET dm_err->err_ind = 1
   SET stat = alterlist(dvr_emsg->qual,dvr_emsg->de_cnt)
   FOR (dvr_cnt = 1 TO dvr_emsg->de_cnt)
    SET dm_err->emsg = dvr_emsg->qual[dvr_cnt].msg
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDFOR
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dcd_prompt_for_dom_info(null)
   SET dm_err->eproc = "Gather domain information from user."
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE dcd_db_name_done = i2 WITH protect, noconstant(0)
   DECLARE dcd_type_idx = i4 WITH protect, noconstant(0)
   DECLARE dcd_allow_dbtype_create_ind = i2 WITH protect, noconstant(0)
   DECLARE dcd_valid_dir = i2 WITH protect, noconstant(0)
   DECLARE dcd_override_template_name = vc WITH protect, noconstant("dm2_not_set")
   IF (validate(dm2_template_name_override,"x") != "x")
    SET dcd_override_template_name = dm2_template_name_override
   ENDIF
   IF (validate(dm2_allow_dbtype_create,- (1))=1)
    SET dcd_allow_dbtype_create_ind = 1
   ENDIF
   SET dm_err->eproc = "Verify creation indicator is not older than 1 week."
   CALL dor_init_flex_cmds(null)
   CALL dor_add_flex_cmd(1," "," "," ",concat("find ",dm2_create_dom->local_ccluserdir,
     "/dm2_response_data.dat"," -mtime -7"),
    " ","EC")
   IF (dor_exec_flex_cmd(null)=0)
    RETURN(0)
   ENDIF
   IF ((dor_flex_cmd->cmd[1].flex_output=concat(dm2_create_dom->local_ccluserdir,
    "/dm2_response_data.dat")))
    SET dm_err->eproc = "Check for final status file."
    CALL dor_init_flex_cmds(null)
    CALL dor_add_flex_cmd(1," "," "," ",concat("test -f ",dm2_create_dom->local_ccluserdir,
      "/dm2_final_status.txt ;echo $?"),
     " ","EC")
    IF (dor_exec_flex_cmd(null)=0)
     RETURN(0)
    ENDIF
    IF ((dor_flex_cmd->cmd[1].flex_output IN ("0")))
     SET dm_err->eproc = "Remove the final status file."
     CALL dor_init_flex_cmds(null)
     CALL dor_add_flex_cmd(1," "," "," ",concat("rm -f ",dm2_create_dom->local_ccluserdir,
       "/dm2_final_status.txt"),
      " ","EC")
     IF (dor_exec_flex_cmd(null)=0)
      RETURN(0)
     ENDIF
    ENDIF
    SET dm2_create_dom->response_file_in_use = 1
    IF (dcd_process_response(null)=0)
     RETURN(0)
    ENDIF
    IF (cnvtlower(curnode) != cnvtlower(dm2_create_dom->db_node_name))
     SET dm2_create_dom->local_db = 0
     SET dm2_create_dom->rmt_temp_dir = "/tmp"
    ELSE
     SET dm2_create_dom->local_db = 1
     SET dm2_create_dom->rmt_temp_dir = "/tmp"
    ENDIF
    SET dm2_create_dom->oracle_home = logical("ORACLE_HOME")
    IF (dcd_validate_response(null)=0)
     RETURN(0)
    ENDIF
    IF ((dm2_create_dom->db_ora_ver="11.1"))
     SET dm2_create_dom->dbca_template_name = build("dm2_ni_dbca_seeded_template_",dm2_create_dom->
      dbtype,"_111.dbc")
    ELSE
     SET dm2_create_dom->dbca_template_name = build("dm2_ni_dbca_seeded_template_",dm2_create_dom->
      dbtype,"_112.dbc")
    ENDIF
    IF (dcd_override_template_name != "dm2_not_set")
     IF (dcd_override_template_name != "dm2_ni_dbca_seeded_template*.dbc")
      SET dm_err->err_ind = 1
      SET dm_err->eproc = "Validating template name override."
      SET dm_err->emsg = "Invalid template name override entered."
      SET dm_err->user_action = "Template name must match dm2_ni_dbca_seeded_template*.dbc."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
     SET dm2_create_dom->dbca_template_name = dcd_override_template_name
    ENDIF
   ELSE
    SET dm_err->eproc = "Check for response file."
    CALL dor_init_flex_cmds(null)
    CALL dor_add_flex_cmd(1," "," "," ",concat("test -f ",dm2_create_dom->local_ccluserdir,
      "/dm2_response_data.dat ;echo $?"),
     " ","EC")
    IF (dor_exec_flex_cmd(null)=0)
     RETURN(0)
    ENDIF
    IF ((dor_flex_cmd->cmd[1].flex_output IN ("0")))
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Response file found, but older than 7 days"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm2_create_dom->response_file_in_use = 0
   ENDIF
   IF (dcd_get_account_name(null)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_create_dom->response_file_in_use=1))
    RETURN(1)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcd_get_ora_ver(null)
   SET dm_err->eproc = "Determine Oracle Version."
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE dgo_cmd_txt = vc WITH protect, noconstant(" ")
   DECLARE dgov_version_found_ind = i2 WITH protect, noconstant(0)
   SET dgo_cmd_txt = "$cer_install/dm_get_oracle_version.ksh"
   IF (dm2_push_dcl(dgo_cmd_txt)=0)
    RETURN(0)
   ENDIF
   SET dgo_cmd_txt = "cat /tmp/dm_get_oracle_version.out"
   IF (dm2_push_dcl(dgo_cmd_txt)=0)
    RETURN(0)
   ENDIF
   FREE DEFINE rtl
   FREE SET file_loc
   SET logical file_loc value(dm_err->errfile)
   DEFINE rtl "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtlt r
    DETAIL
     dm2_create_dom->oracle_version = substring(1,10,r.line),
     CALL echo(build("oracle_version =",dm2_create_dom->oracle_version))
    WITH nocounter
   ;end select
   IF (check_error("Determine Oracle Version.") > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcd_add_text(dat_in_txt,dat_in_reset_ind)
   IF (dat_in_reset_ind=1)
    SET dcd_ftxt->txt_cnt = 1
    SET stat = alterlist(dcd_ftxt->txt,1)
    SET dcd_ftxt->txt[dcd_ftxt->txt_cnt].txt_line = dat_in_txt
   ELSE
    SET dcd_ftxt->txt_cnt = (dcd_ftxt->txt_cnt+ 1)
    SET stat = alterlist(dcd_ftxt->txt,dcd_ftxt->txt_cnt)
    SET dcd_ftxt->txt[dcd_ftxt->txt_cnt].txt_line = dat_in_txt
   ENDIF
 END ;Subroutine
 SUBROUTINE dcd_create_text_file(dctf_in_fname)
   DECLARE dctf_cnt = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = concat("Writing ",trim(dctf_in_fname)," file.")
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO value(dctf_in_fname)
    FROM (dummyt d  WITH seq = value(dcd_ftxt->txt_cnt))
    DETAIL
     col 0, dcd_ftxt->txt[d.seq].txt_line, row + 1
    WITH nocounter, format = variable, formfeed = none,
     maxrow = 1, maxcol = 1000
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   CALL dcd_add_text(" ",1)
   IF (dor_flex_chmod_file(dctf_in_fname," ")=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcd_exec_shutdown_script(null)
   DECLARE dess_file = vc WITH protect, noconstant(" ")
   SET dess_file = concat(dm2_create_dom->rmt_temp_dir,"/shutdown_",dm2_create_dom->dname,"1.ksh")
   SET dm_err->eproc = "Executing database shutdown script."
   CALL disp_msg(" ",dm_err->logfile,0)
   EXECUTE dm2_connect_to_dbase "DO"
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   CALL dcd_add_text("#!/usr/bin/ksh",1)
   CALL dcd_add_text('if [[ `whoami`  != "oracle" ]]',0)
   CALL dcd_add_text("then",0)
   CALL dcd_add_text('    echo "you must be oracle to execute this script."',0)
   CALL dcd_add_text('    echo "Exiting script..."',0)
   CALL dcd_add_text("    exit 1",0)
   CALL dcd_add_text("fi",0)
   CALL dcd_add_text(concat("export ORACLE_HOME=",dm2_create_dom->rmt_oracle_home),0)
   CALL dcd_add_text(concat("export ORACLE_SID=",dm2_create_dom->dname,"1"),0)
   CALL dcd_add_text("$ORACLE_HOME/bin/sqlplus /nolog <<endSQLPLUS",0)
   CALL dcd_add_text("connect /as sysdba",0)
   CALL dcd_add_text("alter system set cluster_database=false scope=spfile;",0)
   CALL dcd_add_text("shutdown abort",0)
   CALL dcd_add_text("exit",0)
   CALL dcd_add_text("endSQLPLUS",0)
   IF (dcd_create_text_file(dess_file)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_create_dom->local_db=0))
    SET dm_err->eproc = "Copy shutdown script to target node."
    CALL dor_init_flex_cmds(null)
    CALL dor_add_flex_cmd(dm2_create_dom->local_db,"root",dm2_create_dom->db_node_name,dess_file," ",
     dess_file,"RCP")
    IF (dor_exec_flex_cmd(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Check for running database."
   CALL dor_init_flex_cmds(null)
   CALL dor_add_flex_cmd(dm2_create_dom->local_db,"root",dm2_create_dom->db_node_name," ",concat(
     'ps -ef | grep pmon | grep -v grep | cut -d"_" -f3 | grep ',dm2_create_dom->dname),
    " ","EC")
   IF (dor_exec_flex_cmd(null)=0)
    RETURN(0)
   ENDIF
   IF ((dor_flex_cmd->cmd[1].flex_output=concat(dm2_create_dom->dname,"1")))
    SET dm_err->eproc = "Execute the shutdown script as the oracle user"
    CALL dor_init_flex_cmds(null)
    CALL dor_add_flex_cmd(dm2_create_dom->local_db,"oracle",dm2_create_dom->db_node_name,dess_file,
     " ",
     " ","EFO")
    IF (dor_exec_flex_cmd(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Finished executing database shutdown script."
   CALL disp_msg(" ",dm_err->logfile,0)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcd_prompt_quit(sbr_exists_str)
   DECLARE dpq_msg1_str = vc WITH public, noconstant(" ")
   DECLARE dpq_msg2_str = vc WITH public, noconstant(" ")
   SET dpq_msg1_str = concat(sbr_exists_str,".")
   SET dpq_msg2_str = concat("If you choose to continue, the ",dm2_create_dom->dname,
    " database will be deleted and recreated.")
   SET width = 132
   SET message = window
   CALL clear(1,1)
   CALL text(2,2,"DELETE EXISTING DATABASE",w)
   CALL box(3,2,20,130)
   CALL text(5,4,dpq_msg1_str)
   CALL text(6,4,dpq_msg2_str)
   CALL text(9,4,"Do you want to continue? (Y/N)")
   CALL accept(9,35,"A;CU"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    CALL text(11,4,"CAUTION!")
    CALL text(13,4,"The existing database will be dropped if you continue.")
    CALL text(14,4,"Are you sure you want to continue? (Y/N)")
    CALL accept(14,45,"A;CU"
     WHERE curaccept IN ("Y", "N"))
    IF (curaccept="N")
     CALL clear(1,1)
     SET message = nowindow
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Existing database found."
     SET dm_err->eproc = "User chose to quit."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ELSE
    CALL clear(1,1)
    SET message = nowindow
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Existing database found."
    SET dm_err->eproc = "User chose to quit."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   CALL clear(1,1)
   SET message = nowindow
   SET dm_err->eproc = "Existing database found.  User chose to continue."
   CALL disp_msg(" ",dm_err->logfile,0)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcd_load_sr_rec(null)
   SET dm_err->eproc = "Loading the drr_search_rep_rec record structure."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF ((dm2_create_dom->dbtype="admin"))
    CALL dcd_add_sr_data("<dname>",cnvtlower(dm2_create_dom->dname))
    IF ((dm2_create_dom->local_db=1))
     CALL dcd_add_sr_data("<oracle home>",dm2_create_dom->oracle_home)
    ELSE
     CALL dcd_add_sr_data("<oracle home>",dm2_create_dom->rmt_oracle_home)
    ENDIF
    CALL dcd_add_sr_data("<oracle version>",dm2_create_dom->oracle_version)
    CALL dcd_add_sr_data("<node name>",dm2_create_dom->node_name)
    CALL dcd_add_sr_data("<admin_port>",dm2_create_dom->admin_port)
    CALL dcd_add_sr_data("<domain account>",dm2_create_dom->domain_account)
    CALL dcd_add_sr_data("<DNAME>",cnvtupper(dm2_create_dom->dname))
    CALL dcd_add_sr_data("<ccluserdir>",evaluate(dm2_create_dom->local_db,1,trim(logical("ccluserdir"
        )),dm2_create_dom->rmt_temp_dir))
    CALL dcd_add_sr_data("<cer_wh>",logical("cer_wh"))
   ELSE
    CALL dcd_add_sr_data("<oracle version>",dm2_create_dom->oracle_version)
    IF ((dm2_create_dom->local_db=1))
     CALL dcd_add_sr_data("<oracle home>",dm2_create_dom->oracle_home)
    ELSE
     CALL dcd_add_sr_data("<oracle home>",dm2_create_dom->rmt_oracle_home)
    ENDIF
    CALL dcd_add_sr_data("<node name>",dm2_create_dom->node_name)
    CALL dcd_add_sr_data("<dname>",dm2_create_dom->dname)
    CALL dcd_add_sr_data("<admin_port>",dm2_create_dom->admin_port)
    CALL dcd_add_sr_data("<clinical_port>",dm2_create_dom->clinical_port)
    CALL dcd_add_sr_data("<environment_id>",dm2_create_dom->env_id)
    CALL dcd_add_sr_data("<env_name>",dm2_create_dom->env_name)
    CALL dcd_add_sr_data("<domain account>",dm2_create_dom->domain_account)
    CALL dcd_add_sr_data("<DNAME>",cnvtupper(dm2_create_dom->dname))
    CALL dcd_add_sr_data("<dbtype>",dm2_create_dom->dbtype)
    CALL dcd_add_sr_data("<cer_wh>",logical("cer_wh"))
    CALL dcd_add_sr_data("<cntrllocation>",evaluate(dm2_create_dom->local_db,1,trim(logical("cer_wh")
       ),dm2_create_dom->rmt_temp_dir))
    CALL dcd_add_sr_data("<ccluserdir>",evaluate(dm2_create_dom->local_db,1,trim(logical("ccluserdir"
        )),dm2_create_dom->rmt_temp_dir))
   ENDIF
   CALL dcd_add_sr_data("<asm_home>",dm2_create_dom->asm_home)
   CALL dcd_add_sr_data("<asm_sid>",dm2_create_dom->asm_sid)
   IF (findstring("$",dm2_create_dom->oracle_sys_pass,1,1)=0)
    CALL dcd_add_sr_data("<syspwd>",dm2_create_dom->oracle_sys_pass)
   ELSE
    CALL dcd_add_sr_data("<syspwd>",replace(dm2_create_dom->oracle_sys_pass,"$","\$",0))
   ENDIF
   IF (findstring("$",dm2_create_dom->oracle_system_pass,1,1)=0)
    CALL dcd_add_sr_data("<systempwd>",dm2_create_dom->oracle_system_pass)
   ELSE
    CALL dcd_add_sr_data("<systempwd>",replace(dm2_create_dom->oracle_system_pass,"$","\$",0))
   ENDIF
   IF (findstring("$",dm2_create_dom->asm_sysdba_pass,1,1)=0)
    CALL dcd_add_sr_data("<asmsysdbapwd>",dm2_create_dom->asm_sysdba_pass)
   ELSE
    CALL dcd_add_sr_data("<asmsysdbapwd>",replace(dm2_create_dom->asm_sysdba_pass,"$","\$",0))
   ENDIF
   CALL dcd_add_sr_data("<storage_disk_group>",dm2_create_dom->asm_storage_dg)
   CALL dcd_add_sr_data("<recovery_disk_group>",dm2_create_dom->asm_recovery_dg)
   CALL dcd_add_sr_data("<log_archive_dest_1>",dm2_create_dom->log_archive_dest_1)
   CALL dcd_add_sr_data("<dbca_template_name>",dm2_create_dom->dbca_template_name)
   CALL dcd_add_sr_data("<oracle_base>",dm2_create_dom->oracle_base)
   CALL dcd_add_sr_data("<node_list>",dm2_create_dom->db_node_name)
   CALL dcd_add_sr_data("<hasuser>",cnvtupper(dm2_create_dom->hasuser))
   CALL dcd_add_sr_data("<crs_home>",dm2_create_dom->crs_home)
   CALL dcd_add_sr_data("<crs_state>",cnvtupper(dm2_create_dom->crs_state))
   CALL dcd_add_sr_data("<rac_option>",cnvtupper(dm2_create_dom->rac_option))
   CALL dcd_add_sr_data("<db_ora_ver>",cnvtupper(dm2_create_dom->db_ora_ver))
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(drr_search_rep_rec)
   ENDIF
   SET dm_err->eproc = "Finished loading the drr_search_rep_rec record structure."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
 END ;Subroutine
 SUBROUTINE dcd_add_sr_data(sbr_search_val_str,sbr_replace_val_str)
   SET drr_search_rep_rec->elem_cnt = (drr_search_rep_rec->elem_cnt+ 1)
   SET stat = alterlist(drr_search_rep_rec->elems,drr_search_rep_rec->elem_cnt)
   SET drr_search_rep_rec->elems[drr_search_rep_rec->elem_cnt].search_val = sbr_search_val_str
   SET drr_search_rep_rec->elems[drr_search_rep_rec->elem_cnt].replace_val = sbr_replace_val_str
 END ;Subroutine
 SUBROUTINE dcd_exec_load_hist(null)
   SET dm_err->eproc = "Executing load of package history."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    d.info_number
    FROM dm_info d
    WHERE d.info_domain="DATA MANAGEMENT"
     AND d.info_name="DM_ENV_ID"
    DETAIL
     dm2_create_dom->env_id = build(d.info_number)
    WITH nocounter
   ;end select
   IF (check_error("Error occurred getting new environment ID.")=1)
    RETURN(0)
   ENDIF
   EXECUTE dm2_ni_load_pkg_hist_wrapper
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Finished executing load of package history."
   CALL disp_msg(" ",dm_err->logfile,0)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcd_write_login_default(null)
   SELECT INTO "login_default.ccl"
    d.*
    FROM dual d
    DETAIL
     col 0, "%D NOECHO", row + 1
     IF ((dm2_create_dom->local_db=1))
      IF (cnvtupper(currdbuser)="CDBA")
       col 0, "define ORACLESYSTEM 'cdba/cdba' go"
      ELSE
       col 0, "define ORACLESYSTEM 'v500/v500' go"
      ENDIF
     ELSE
      IF (cnvtupper(currdbuser)="CDBA")
       CALL print(concat("define ORACLESYSTEM 'cdba/cdba@",dm2_create_dom->dname,"1' go"))
      ELSE
       CALL print(concat("define ORACLESYSTEM 'v500/v500@",dm2_create_dom->dname,"1' go"))
      ENDIF
     ENDIF
    WITH nocounter, format = variable, formfeed = none,
     maxrow = 1
   ;end select
   IF (check_error("Writing login_default.ccl")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcd_get_account_name(null)
   DECLARE dgan_lreg_cmd = vc WITH public, noconstant("not_set")
   DECLARE dgan_dcl_stat = i4 WITH public, noconstant(0)
   DECLARE dgan_start_pos = i4 WITH public, noconstant(0)
   DECLARE dgan_end_pos = i4 WITH public, noconstant(0)
   SET dm_err->eproc = "Getting the domain-level OS user from the registry."
   SET dm_err->errfile = dm_err->unique_fname
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dgan_lreg_cmd = concat("lreg -getp environment\\",dm2_create_dom->env_name," LocalUserName",
    " > ",dm2_install_schema->ccluserdir,
    dm_err->errfile," 2>&1")
   IF ((dm_err->debug_flag > 0))
    CALL echo("*")
    CALL echo(concat("call dcl executing: ",dgan_lreg_cmd))
    CALL echo("*")
   ENDIF
   CALL dcl(dgan_lreg_cmd,size(dgan_lreg_cmd),dgan_dcl_stat)
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   SET dm2_create_dom->domain_account = cnvtlower(trim(dm_err->errtext))
   IF (trim(dm2_create_dom->domain_account,3)="")
    SET dm_err->emsg = "Create database failed.  LocalUserName not defined in the registry."
    SET dm_err->user_action = concat("Please define LocalUserName in \system\environment\",
     dm2_create_dom->env_name," and try again.")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Found the domain-level OS user: ",dm2_create_dom->domain_account)
   CALL disp_msg(" ",dm_err->logfile,0)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcd_load_sids(dcd_dbtype)
   DECLARE dcd_ret_file = vc WITH protect, noconstant(concat(dm2_create_dom->local_ccluserdir,"/",
     dcd_dbtype,"_outfile.txt"))
   FREE RECORD dcd_ora_pmon
   RECORD dcd_ora_pmon(
     1 pmon_cnt = i4
     1 pmon_list[*]
       2 db_name = vc
   )
   SET dcd_ora_pmon->pmon_cnt = 0
   SET dm_err->eproc = "Populate list of databases running on database node."
   CALL dor_init_flex_cmds(null)
   CALL dor_add_flex_cmd(dm2_create_dom->local_db,"root",dm2_create_dom->db_node_name," ",
    "ps -fu oracle|grep pmon|cut -d_ -f3",
    dcd_ret_file,"EC")
   IF (dor_exec_flex_cmd(null)=0)
    RETURN(0)
   ENDIF
   FREE SET pmonlist
   SET logical pmonlist value(dcd_ret_file)
   FREE DEFINE rtl
   DEFINE rtl "pmonlist"
   SELECT INTO "nl:"
    r.list
    FROM rtlt r
    DETAIL
     IF (findstring("+",r.line,1,1)=0)
      dcd_ora_pmon->pmon_cnt = (dcd_ora_pmon->pmon_cnt+ 1), stat = alterlist(dcd_ora_pmon->pmon_list,
       dcd_ora_pmon->pmon_cnt), dcd_ora_pmon->pmon_list[dcd_ora_pmon->pmon_cnt].db_name = substring(1,
       (size(trim(r.line)) - 1),r.line)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 5))
    CALL echorecord(dcd_ora_pmon)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcd_set_envid(null)
   DECLARE dse_env_id = f8 WITH protect, noconstant(0.00)
   DECLARE dse_old_env_id = f8 WITH protect, noconstant(0.00)
   DECLARE dse_tmp_env_name = vc WITH protect, noconstant("NOT_SET")
   DECLARE dse_for_migration = i2 WITH protect, noconstant(0)
   DECLARE dse_driver_env_name = vc WITH protect, noconstant("NOT_SET")
   IF (validate(dmcd_app_tier_mig_ind,- (1))=1)
    SET dse_for_migration = 1
   ENDIF
   IF (dse_for_migration=1)
    SET dse_driver_env_name = build(cnvtupper(dm2_create_dom->env_name),"_",cnvtupper(dm2_create_dom
      ->dname))
   ELSE
    SET dse_driver_env_name = cnvtupper(dm2_create_dom->env_name)
   ENDIF
   SET dm_err->eproc = build("Checking for exiting dm_environment row for environment <",
    dm2_create_dom->env_name,">.")
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    d.environment_id
    FROM dm_environment d
    WHERE cnvtupper(d.environment_name)=dse_driver_env_name
    DETAIL
     dse_old_env_id = d.environment_id, dse_tmp_env_name = concat("OLD <",trim(cnvtstring(
        dse_old_env_id)),">")
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dm_err->eproc = build("Updating the existing dm_environment row for environment name <",
     dm2_create_dom->env_name,">.")
    CALL disp_msg(" ",dm_err->logfile,0)
    UPDATE  FROM dm_environment d
     SET d.environment_name = dse_tmp_env_name
     WHERE d.environment_id=dse_old_env_id
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = build("Insert env_name <",dm2_create_dom->env_name,"> into DM_ENVIRONMENT")
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    y = seq(dm_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     dse_env_id = cnvtreal(y)
    WITH format, nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(dm_err->asterisk_line)
    CALL echo(build("dse_env_id=",dse_env_id))
    CALL echo(dm_err->asterisk_line)
   ENDIF
   INSERT  FROM dm_environment d
    SET d.environment_id = dse_env_id, d.environment_name = dse_driver_env_name, d.database_name =
     dm2_create_dom->dname,
     d.target_operating_system = dm2_create_dom->rmt_os, d.admin_dbase_link_name = "ADMIN1", d
     .v500_connect_string = concat("V500/V500@",dm2_create_dom->dname,"1"),
     d.v500ref_connect_string = concat("V500_REF/V500_REF@",dm2_create_dom->dname,"1"), d
     .envset_string = dm2_create_dom->env_name, d.root_dir_name = "N/A",
     d.volume_group = "N/A", d.updt_applctx = 0, d.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     d.updt_cnt = 0, d.updt_id = 0, d.updt_task = 0
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   DELETE  FROM dm_info
    WHERE info_domain="DATA MANAGEMENT"
     AND info_name IN ("DM_ENV_ID", "DM_ENV_NAME")
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = build("Insert env_id <",dm2_create_dom->env_name,"> into DM_INFO")
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   INSERT  FROM dm_info d
    SET d.info_domain = "DATA MANAGEMENT", d.info_name = "DM_ENV_ID", d.info_number = dse_env_id,
     d.updt_applctx = 0, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_cnt = 0,
     d.updt_id = 0, d.updt_task = 0
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = build("Insert env_name <",dm2_create_dom->env_name,"> into DM_INFO")
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   INSERT  FROM dm_info d
    SET d.info_domain = "DATA MANAGEMENT", d.info_name = "DM_ENV_NAME", d.info_char =
     dse_driver_env_name,
     d.updt_applctx = 0, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_cnt = 0,
     d.updt_id = 0, d.updt_task = 0
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
 SUBROUTINE dcd_db_reg_entries(null)
   DECLARE dbre_platform = vc WITH public, noconstant("DM2_NOT_SET")
   IF ((dm2_sys_misc->cur_os="AIX"))
    SET dbre_platform = "aixrs6000"
   ELSEIF ((dm2_sys_misc->cur_os="HPX"))
    SET dbre_platform = "hpuxia64"
   ELSE
    SET dbre_platform = "linuxx86-64"
   ENDIF
   SET dm_err->eproc = "Create file for database specific registry updates"
   CALL disp_msg(" ",dm_err->logfile,0)
   CALL dcd_add_text(concat("! -----------------------------------------------------,,,"),1)
   CALL dcd_add_text(concat("!  Add Environment Key,,,"),0)
   CALL dcd_add_text(concat("! -----------------------------------------------------,,,"),0)
   IF ((dm2_create_dom->dbtype="strt"))
    CALL dcd_add_text(concat("addk,\Environment\",dm2_create_dom->env_name,"\node\%node%,,"),0)
    CALL dcd_add_text(concat("update,\Environment\",dm2_create_dom->env_name,
      "\node\%node%,DbInstance,",dm2_create_dom->dname,"1"),0)
    CALL dcd_add_text(concat("update,\environment\",dm2_create_dom->env_name,"\Definitions\",
      dbre_platform,"\Environment,date_mode,UTC"),0)
    CALL dcd_add_text(concat("update,\Environment\",dm2_create_dom->env_name,"\Definitions\",
      dbre_platform,"\Environment,NLS_LANG,AMERICAN_AMERICA.WE8MSWIN1252"),0)
    CALL dcd_add_text(concat("update,\Environment\",dm2_create_dom->env_name,"\Definitions\",
      dbre_platform,"\Environment,ORA_NLS10,",
      dm2_create_dom->oracle_home,"/nls/data"),0)
   ELSE
    CALL dcd_add_text(concat("addk,\Environment\admin\node\%node%,,"),0)
    CALL dcd_add_text(concat("update,\Environment\admin\node\%node%,DbInstance,",dm2_create_dom->
      dname,"1"),0)
    CALL dcd_add_text(concat("update,\Environment\admin\Definitions\",dbre_platform,
      "\Environment,ORA_NLS10,",dm2_create_dom->oracle_home,"/nls/data"),0)
   ENDIF
   CALL dcd_add_text(concat("! -----------------------------------------------------,,,"),0)
   CALL dcd_add_text(concat("!  Add Database Key,,,"),0)
   CALL dcd_add_text(concat("! -----------------------------------------------------,,,"),0)
   CALL dcd_add_text(concat("addk,\Database,,"),0)
   CALL dcd_add_text(concat("addk,\Database\",dm2_create_dom->dname,",,"),0)
   CALL dcd_add_text(concat("addk,\Database\",dm2_create_dom->dname,"\node,,"),0)
   CALL dcd_add_text(concat("addk,\Database\",dm2_create_dom->dname,"\node\%node%,,"),0)
   CALL dcd_add_text(concat("update,\Database\",dm2_create_dom->dname,",Rdbms,",dm2_create_dom->
     oracle_version),0)
   CALL dcd_add_text(concat("update,\Database\",dm2_create_dom->dname,",RootPath,/u02/oracle/admin/",
     dm2_create_dom->dname),0)
   IF ((dm2_create_dom->local_db=0))
    CALL dcd_add_text(concat("update,\Database\",dm2_create_dom->dname,
      '\node\%node%,Rdbms Connect Option,"@',dm2_create_dom->dname,'1"'),0)
   ELSE
    CALL dcd_add_text(concat("update,\Database\",dm2_create_dom->dname,
      '\node\%node%,Rdbms Connect Option," "'),0)
   ENDIF
   IF ((dm2_create_dom->dbtype="admin"))
    CALL dcd_add_text(concat("update,\Database\",dm2_create_dom->dname,
      "\node\%node%,Rdbms Password,cdba"),0)
    CALL dcd_add_text(concat("update,\Database\",dm2_create_dom->dname,
      "\node\%node%,Rdbms User Name,cdba"),0)
   ELSE
    CALL dcd_add_text(concat("update,\Database\",dm2_create_dom->dname,
      "\node\%node%,Rdbms Password,v500"),0)
    CALL dcd_add_text(concat("update,\Database\",dm2_create_dom->dname,
      "\node\%node%,Rdbms User Name,v500"),0)
   ENDIF
   CALL dcd_add_text(concat("! -----------------------------------------------------,,,"),0)
   CALL dcd_add_text(concat("!  Add Dbinstance Key,,,"),0)
   CALL dcd_add_text(concat("! -----------------------------------------------------,,,"),0)
   CALL dcd_add_text(concat("addk,\Dbinstance,,"),0)
   CALL dcd_add_text(concat("addk,\Dbinstance\",dm2_create_dom->dname,"1,,"),0)
   CALL dcd_add_text(concat("update,\Dbinstance\",dm2_create_dom->dname,"1,database,",dm2_create_dom
     ->dname),0)
   IF (dcd_create_text_file(concat("update_reg_",dm2_create_dom->dname,".csv"))=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcd_get_asm_data(null)
   DECLARE dgad_start_pos = i4 WITH protect, noconstant(0)
   DECLARE dgad_exe_fname1 = vc WITH protect, noconstant(" ")
   DECLARE dgad_exe_fname2 = vc WITH protect, noconstant(" ")
   DECLARE dgad_source_fname1 = vc WITH protect, noconstant(concat(dm2_create_dom->local_ccluserdir,
     "/dm2_asm_sid.ksh"))
   DECLARE dgad_source_fname2 = vc WITH protect, noconstant(concat(dm2_create_dom->local_ccluserdir,
     "/dm2_asm_home.ksh"))
   SET dm_err->eproc = "Retrieve ASM sid."
   CALL disp_msg(" ",dm_err->logfile,0)
   CALL dcd_add_text(" ",1)
   CALL dcd_add_text("#!/bin/ksh",0)
   CALL dcd_add_text(
    ^export ASM_SID=`ps -ef | grep "asm_pmon" | grep -v grep | sed 's/ //g' | cut -d+ -f2`^,0)
   CALL dcd_add_text("if [[ ${ASM_SID} = '' ]]",0)
   CALL dcd_add_text("then",0)
   CALL dcd_add_text(concat(
     ' echo "CER-00000: error - ASM Instance background process ("asm_pmon") not found. ',
     'Please perform necessary steps to ensure ASM Instance is running."'),0)
   CALL dcd_add_text("  exit 1",0)
   CALL dcd_add_text("fi",0)
   CALL dcd_add_text("export ASM_SID=+${ASM_SID}",0)
   CALL dcd_add_text(concat(
     "if [[ `grep -i ${ASM_SID} /etc/oratab | grep -v '^#' | cut -d':' -s -f1 | grep -i ${ASM_SID} ",
     "| wc -l` -eq 0 ]]"),0)
   CALL dcd_add_text("then",0)
   CALL dcd_add_text(concat(
     'echo " CER-00000: error - File /etc/oratab does not have an entry for running ASM Instance ',
     '(${ASM_SID}). Please perform necessary steps to update /etc/oratab."'),0)
   CALL dcd_add_text("  exit 1",0)
   CALL dcd_add_text("fi",0)
   CALL dcd_add_text('echo "ASM_SID:<${ASM_SID}>"',0)
   IF (dcd_create_text_file(dgad_source_fname1)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_create_dom->local_db=0))
    SET dm_err->eproc = "Copy dm2_asm_sid script to target node."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dgad_exe_fname1 = concat(dm2_create_dom->rmt_temp_dir,"/dm2_asm_sid.ksh")
    CALL dor_init_flex_cmds(null)
    CALL dor_add_flex_cmd(dm2_create_dom->local_db,"root",dm2_create_dom->db_node_name,
     dgad_source_fname1," ",
     dgad_exe_fname1,"RCP")
    IF (dor_exec_flex_cmd(null)=0)
     RETURN(0)
    ENDIF
   ELSE
    SET dgad_exe_fname1 = concat('"',dm2_create_dom->local_ccluserdir,'/dm2_asm_sid.ksh"')
   ENDIF
   SET dm_err->eproc = "Execute the dm2_asm_sid check script."
   CALL disp_msg(" ",dm_err->logfile,0)
   CALL dor_init_flex_cmds(null)
   CALL dor_add_flex_cmd(dm2_create_dom->local_db,"oracle",dm2_create_dom->db_node_name,
    dgad_exe_fname1," ",
    " ","EFORO")
   IF (dor_exec_flex_cmd(null)=0)
    RETURN(0)
   ENDIF
   IF ((dor_flex_cmd->cmd[1].flex_output > " "))
    IF (findstring("ASM_SID:",dor_flex_cmd->cmd[1].flex_output,1,0) > 0)
     SET dgad_start_pos = findstring("ASM_SID:",dor_flex_cmd->cmd[1].flex_output,1,0)
     SET dm2_create_dom->asm_sid = trim(substring(findstring("+",dor_flex_cmd->cmd[1].flex_output,
        dgad_start_pos,0),((size(dor_flex_cmd->cmd[1].flex_output,1) - findstring("<",dor_flex_cmd->
        cmd[1].flex_output,dgad_start_pos,0)) - 1),dor_flex_cmd->cmd[1].flex_output))
    ELSE
     IF (findstring("CER-00000",cnvtupper(dm_err->errtext),1,0) > 0)
      SET dm_err->emsg = concat(substring(findstring("CER-00000",cnvtupper(dor_flex_cmd->cmd[1].
          flex_output),1,1),(size(dor_flex_cmd->cmd[1].flex_output) - findstring("CER-00000",
         cnvtupper(dor_flex_cmd->cmd[1].flex_output),1,1)),dor_flex_cmd->cmd[1].flex_output),".")
     ELSE
      SET dm_err->emsg = dor_flex_cmd->cmd[1].flex_output
     ENDIF
     SET message = nowindow
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((((dm2_create_dom->asm_sid=" ")) OR (cnvtupper(dm2_create_dom->asm_sid)="DM2_NOT_SET")) )
    SET dm_err->emsg = "Unable to obtain ASM sid"
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Retrieve ASM home."
   CALL disp_msg(" ",dm_err->logfile,0)
   CALL dcd_add_text(" ",1)
   CALL dcd_add_text("#!/bin/ksh",0)
   CALL dcd_add_text(concat("ASM_OHOME=`grep -i ",dm2_create_dom->asm_sid,
     " /etc/oratab | grep -v '^#' | cut -d':' -s -f2`"),0)
   CALL dcd_add_text(" if [[ ! -d ${ASM_OHOME} ]]",0)
   CALL dcd_add_text("then",0)
   CALL dcd_add_text(concat(
     ' echo " CER-00000: error - Directory ${ASM_OHOME}, retrieved from /etc/oratab for ',"ASM sid (",
     dm2_create_dom->asm_sid,'),not found."'),0)
   CALL dcd_add_text("  exit 1",0)
   CALL dcd_add_text("fi",0)
   CALL dcd_add_text('echo "ASM_HOME:<${ASM_OHOME}>"',0)
   IF (dcd_create_text_file(dgad_source_fname2)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_create_dom->local_db=0))
    SET dm_err->eproc = "Copy dm2_asm_home script to target node."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dgad_exe_fname2 = concat(dm2_create_dom->rmt_temp_dir,"/dm2_asm_home.ksh")
    CALL dor_init_flex_cmds(null)
    CALL dor_add_flex_cmd(dm2_create_dom->local_db,"root",dm2_create_dom->db_node_name,
     dgad_source_fname2," ",
     dgad_exe_fname2,"RCP")
    IF (dor_exec_flex_cmd(null)=0)
     RETURN(0)
    ENDIF
   ELSE
    SET dgad_exe_fname2 = concat('"',dm2_create_dom->local_ccluserdir,'/dm2_asm_home.ksh"')
   ENDIF
   SET dm_err->eproc = "Execute the dm2_asm_home check script."
   CALL disp_msg(" ",dm_err->logfile,0)
   CALL dor_init_flex_cmds(null)
   CALL dor_add_flex_cmd(dm2_create_dom->local_db,"oracle",dm2_create_dom->db_node_name,
    dgad_exe_fname2," ",
    " ","EFORO")
   IF (dor_exec_flex_cmd(null)=0)
    RETURN(0)
   ENDIF
   IF ((dor_flex_cmd->cmd[1].flex_output > " "))
    IF (findstring("ASM_HOME:",dor_flex_cmd->cmd[1].flex_output,1,0) > 0)
     SET dgad_start_pos = findstring("ASM_HOME:",dor_flex_cmd->cmd[1].flex_output,1,0)
     SET dm2_create_dom->asm_home = trim(substring((dgad_start_pos+ 10),((size(dor_flex_cmd->cmd[1].
        flex_output,1) - findstring("<",dor_flex_cmd->cmd[1].flex_output,dgad_start_pos,0)) - 1),
       dor_flex_cmd->cmd[1].flex_output))
    ELSE
     IF (findstring("CER-00000",cnvtupper(dm_err->errtext),1,0) > 0)
      SET dm_err->emsg = concat(substring(findstring("CER-00000",cnvtupper(dor_flex_cmd->cmd[1].
          flex_output),1,1),(size(dor_flex_cmd->cmd[1].flex_output) - findstring("CER-00000",
         cnvtupper(dor_flex_cmd->cmd[1].flex_output),1,1)),dor_flex_cmd->cmd[1].flex_output),".")
     ELSE
      SET dm_err->emsg = dor_flex_cmd->cmd[1].flex_output
     ENDIF
     SET message = nowindow
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((((dm2_create_dom->asm_home=" ")) OR (cnvtupper(dm2_create_dom->asm_home)="DM2_NOT_SET")) )
    SET dm_err->emsg = "Unable to obtain ASM Oracle Home"
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcd_get_ora_kernel_user(null)
   DECLARE dgoku_start_pos = i4 WITH protect, noconstant(0)
   DECLARE dgoku_exe_fname = vc WITH protect, noconstant(" ")
   DECLARE dgoku_source_fname = vc WITH protect, noconstant(concat(dm2_create_dom->local_ccluserdir,
     "/dm2_db_oracle_kernel.ksh"))
   SET dm_err->eproc = "Retrieve Database Node Kernel."
   CALL disp_msg(" ",dm_err->logfile,0)
   CALL dcd_add_text(" ",1)
   CALL dcd_add_text("#!/bin/ksh",0)
   CALL dcd_add_text('[[ `uname` = "AIX" ]] && ID=/etc',0)
   CALL dcd_add_text('[[ `uname` = "HP-UX" ]] && ID=/sbin/init.d',0)
   CALL dcd_add_text('[[ `uname` = "Linux" ]] && ID=/etc/init.d',0)
   CALL dcd_add_text("IDFILE=init.ohasd",0)
   CALL dcd_add_text('HASUSER="unknown"',0)
   CALL dcd_add_text(
    'echo "`date`: Verify ${ID} directory has read and execute privileges for the oracle user..."',0)
   CALL dcd_add_text("if [[ ! -r ${ID} ]]",0)
   CALL dcd_add_text("then",0)
   CALL dcd_add_text(concat(
     '  echo "CER-00000: error - ${ID} directory does not have read access for oracle user. ',
     'Update permissions and restart."'),0)
   CALL dcd_add_text("  exit 1",0)
   CALL dcd_add_text("elif  [[ ! -x ${ID} ]]",0)
   CALL dcd_add_text("then",0)
   CALL dcd_add_text(concat(
     '  echo "CER-00000: error - ${ID} directory does not have execute privileges for oracle user. ',
     'Update permissions and restart."'),0)
   CALL dcd_add_text("  exit 1",0)
   CALL dcd_add_text("fi",0)
   CALL dcd_add_text(
    'echo "`date`: Verify, if ${ID}/${IDFILE} file exists, that it has read privileges for the oracle user..."',
    0)
   CALL dcd_add_text("if [[ -f ${ID}/${IDFILE} ]]",0)
   CALL dcd_add_text("then",0)
   CALL dcd_add_text("  if [[ -r ${ID}/${IDFILE} ]]",0)
   CALL dcd_add_text("  then",0)
   CALL dcd_add_text('    echo "Get HAS_USER value from ${ID}/${IDFILE} file..."',0)
   CALL dcd_add_text(^    HASUSER=`grep -i "HAS_USER=" ${ID}/${IDFILE} | cut -f2 -d'='`^,0)
   CALL dcd_add_text("    typeset -l HASUSER=${HASUSER}",0)
   CALL dcd_add_text('    if [[ ${HASUSER} != "oracle" && ${HASUSER} != "root" ]]',0)
   CALL dcd_add_text("    then",0)
   CALL dcd_add_text(concat(
     '      echo "CER-00000: error - HAS_USER value (${HASUSER}) obtained from ${ID}/${IDFILE} ',
     'not found or expected value of either oracle or root."'),0)
   CALL dcd_add_text("      exit 1",0)
   CALL dcd_add_text("    fi",0)
   CALL dcd_add_text("  else",0)
   CALL dcd_add_text(concat(
     '    echo "CER-00000: error - ${ID}/${IDFILE} file exists but does not have read access for oracle. ',
     'Update permissions and restart."'),0)
   CALL dcd_add_text("    exit 1",0)
   CALL dcd_add_text("  fi",0)
   CALL dcd_add_text("else",0)
   CALL dcd_add_text('  echo "${ID}/${IDFILE} file does not exist."',0)
   CALL dcd_add_text("fi",0)
   CALL dcd_add_text('echo "HASUSER:<${HASUSER}>"',0)
   IF (dcd_create_text_file(dgoku_source_fname)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_create_dom->local_db=0))
    SET dm_err->eproc = "Copy dm2_db_oracle_kernel script to target node."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dgoku_exe_fname = concat(dm2_create_dom->rmt_temp_dir,"/dm2_db_oracle_kernel.ksh")
    CALL dor_init_flex_cmds(null)
    CALL dor_add_flex_cmd(dm2_create_dom->local_db,"root",dm2_create_dom->db_node_name,
     dgoku_source_fname," ",
     dgoku_exe_fname,"RCP")
    IF (dor_exec_flex_cmd(null)=0)
     RETURN(0)
    ENDIF
   ELSE
    SET dgoku_exe_fname = concat('"',dm2_create_dom->local_ccluserdir,'/dm2_db_oracle_kernel.ksh"')
   ENDIF
   SET dm_err->eproc = "Execute the dm2_db_oracle_kernel check script."
   CALL disp_msg(" ",dm_err->logfile,0)
   CALL dor_init_flex_cmds(null)
   CALL dor_add_flex_cmd(dm2_create_dom->local_db,"oracle",dm2_create_dom->db_node_name,
    dgoku_exe_fname," ",
    " ","EFORO")
   IF (dor_exec_flex_cmd(null)=0)
    RETURN(0)
   ENDIF
   IF ((dor_flex_cmd->cmd[1].flex_output > " "))
    IF (findstring("HASUSER:",dor_flex_cmd->cmd[1].flex_output,1,0) > 0)
     SET dgoku_start_pos = findstring("HASUSER:",dor_flex_cmd->cmd[1].flex_output,1,0)
     SET dm2_create_dom->hasuser = trim(substring((dgoku_start_pos+ 9),((size(dor_flex_cmd->cmd[1].
        flex_output,1) - findstring("<",dor_flex_cmd->cmd[1].flex_output,dgoku_start_pos,0)) - 1),
       dor_flex_cmd->cmd[1].flex_output))
    ELSE
     IF (findstring("CER-00000",cnvtupper(dm_err->errtext),1,0) > 0)
      SET dm_err->emsg = concat(substring(findstring("CER-00000",cnvtupper(dor_flex_cmd->cmd[1].
          flex_output),1,1),(size(dor_flex_cmd->cmd[1].flex_output) - findstring("CER-00000",
         cnvtupper(dor_flex_cmd->cmd[1].flex_output),1,1)),dor_flex_cmd->cmd[1].flex_output),".")
     ELSE
      SET dm_err->emsg = dor_flex_cmd->cmd[1].flex_output
     ENDIF
     SET message = nowindow
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ( NOT (cnvtlower(dm2_create_dom->hasuser) IN ("root", "oracle", "unknown")))
    SET dm_err->emsg =
    "Invalid HASUSER value obtained. Acceptable values include root,oracle or unknown."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcd_get_rac_config(null)
   DECLARE dgrc_start_pos = i4 WITH protect, noconstant(0)
   DECLARE dgrc_exe_fname = vc WITH protect, noconstant(" ")
   DECLARE dgrc_source_fname = vc WITH protect, noconstant(concat(dm2_create_dom->local_ccluserdir,
     "/dm2_get_rac_config.ksh"))
   SET dm_err->eproc = "Check if database node Oracle kernel has RAC enabled."
   CALL disp_msg(" ",dm_err->logfile,0)
   CALL dcd_add_text(" ",1)
   CALL dcd_add_text("#!/bin/ksh",0)
   CALL dcd_add_text('export RAC_OPT="N"',0)
   CALL dcd_add_text(concat("if [[ `strings ",dm2_create_dom->rmt_oracle_home,
     "/rdbms/lib/libknlopt.a | grep -c kcsm.o` -gt 0 ]]"),0)
   CALL dcd_add_text("then",0)
   CALL dcd_add_text('export RAC_OPT="Y"',0)
   CALL dcd_add_text("fi",0)
   CALL dcd_add_text('echo "RAC_OPT:<${RAC_OPT}>"',0)
   IF (dcd_create_text_file(dgrc_source_fname)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_create_dom->local_db=0))
    SET dm_err->eproc = "Copy dm2_get_rac_config script to target node."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dgrc_exe_fname = concat(dm2_create_dom->rmt_temp_dir,"/dm2_get_rac_config.ksh")
    CALL dor_init_flex_cmds(null)
    CALL dor_add_flex_cmd(dm2_create_dom->local_db,"root",dm2_create_dom->db_node_name,
     dgrc_source_fname," ",
     dgrc_exe_fname,"RCP")
    IF (dor_exec_flex_cmd(null)=0)
     RETURN(0)
    ENDIF
   ELSE
    SET dgrc_exe_fname = concat('"',dm2_create_dom->local_ccluserdir,'/dm2_get_rac_config.ksh"')
   ENDIF
   SET dm_err->eproc = "Execute the dm2_get_rac_config script."
   CALL disp_msg(" ",dm_err->logfile,0)
   CALL dor_init_flex_cmds(null)
   CALL dor_add_flex_cmd(dm2_create_dom->local_db,"oracle",dm2_create_dom->db_node_name,
    dgrc_exe_fname," ",
    " ","EFORO")
   IF (dor_exec_flex_cmd(null)=0)
    RETURN(0)
   ENDIF
   IF ((dor_flex_cmd->cmd[1].flex_output > " "))
    IF (findstring("RAC_OPT:",dor_flex_cmd->cmd[1].flex_output,1,0) > 0)
     SET dgrc_start_pos = findstring("RAC_OPT:",dor_flex_cmd->cmd[1].flex_output,1,0)
     SET dm2_create_dom->rac_option = trim(substring((dgrc_start_pos+ 9),((size(dor_flex_cmd->cmd[1].
        flex_output,1) - findstring("<",dor_flex_cmd->cmd[1].flex_output,dgrc_start_pos,0)) - 1),
       dor_flex_cmd->cmd[1].flex_output))
    ELSE
     SET message = nowindow
     SET dm_err->emsg = dor_flex_cmd->cmd[1].flex_output
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ( NOT (cnvtupper(dm2_create_dom->rac_option) IN ("Y", "N")))
    SET dm_err->emsg = "Invalid value for: dm2_create_dom->rac_option. Valid entries are Y or N."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
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
 IF ((validate(drr_search_rep_rec->elem_cnt,- (1))=- (1))
  AND (validate(drr_search_rep_rec->elem_cnt,- (2))=- (2)))
  RECORD drr_search_rep_rec(
    1 elem_cnt = i2
    1 elems[*]
      2 search_val = vc
      2 temp_search_val = vc
      2 replace_val = vc
      2 calc_param = vc
  )
  SET drr_search_rep_rec->elem_cnt = 0
 ENDIF
 IF ((validate(drr_cmd_rec->cmd_cnt,- (1))=- (1))
  AND (validate(drr_cmd_rec->cmd_cnt,- (2))=- (2)))
  RECORD drr_cmd_rec(
    1 cmd_cnt = i4
    1 cmds[*]
      2 text = vc
    1 src_filename = vc
    1 tgt_filename = vc
    1 action_type = vc
  )
  SET drr_cmd_rec->cmd_cnt = 0
 ENDIF
 IF ((validate(disk_rec->disk_cnt,- (1))=- (1))
  AND (validate(disk_rec->disk_cnt,- (2))=- (2)))
  RECORD disk_rec(
    1 disk_cnt = i2
    1 qual[*]
      2 disk_name = vc
      2 disk_vg = vc
      2 mwc_flag = c1
  )
  SET disk_rec->disk_cnt = 0
 ENDIF
 IF ((validate(drr_delim_txt_rec->txt_elem_cnt,- (1))=- (1))
  AND (validate(drr_delim_txt_rec->txt_elem_cnt,- (2))=- (2)))
  RECORD drr_delim_txt_rec(
    1 orig_txt = vc
    1 sep_char = vc
    1 txt_elem_cnt = i2
    1 qual[*]
      2 txt_elem = vc
  )
  SET drr_delim_txt_rec->orig_txt = "not_set"
  SET drr_delim_txt_rec->sep_char = "not_set"
  SET drr_delim_txt_rec->txt_elem_cnt = 0
 ENDIF
 DECLARE drr_search_replace(null) = i2
 DECLARE drr_calc_replace_val(sbr_elem_idx=i2) = i2
 DECLARE drr_replace_calcdisk(sbr_elem_idx=i2) = i2
 DECLARE drr_replace_mwc(sbr_elem_idx=i2) = i2
 DECLARE drr_replace_calcpartition(sbr_elem_idx=i2) = i2
 DECLARE drr_get_dfile_idx(sbr_dfile_tag=vc) = i4
 DECLARE drr_get_inner_val(sbr_full_str=vc,sbr_beg_sym=vc,sbr_end_sym=vc,sbr_strip_sym_ind=i2) = vc
 DECLARE drr_load_cmds_from_file(dlcf_fname=vc) = i2
 DECLARE drr_reset_cmd_rec(null) = null
 DECLARE drr_perform_cmd_action(null) = i2
 DECLARE drr_write_cmds_to_file(null) = i2
 DECLARE drr_exec_cmd_file(null) = i2
 DECLARE drr_exec_cmd_lines(null) = i2
 DECLARE drr_parse_delim_txt(null) = i2
 DECLARE drr_reset_search_rep_rec(null) = null
 DECLARE dm2_push_compile(sbr_dpc_file=vc) = i2
 DECLARE drr_exec_update_reg(sbr_deur_updtreg_cmd=vc) = i2
 SUBROUTINE drr_search_replace(null)
   SET dm_err->eproc = "Beginning drr_search_replace."
   DECLARE cr_cnt = i4 WITH protect, noconstant(0)
   DECLARE srr_cnt = i4 WITH protect, noconstant(0)
   DECLARE dsr_calc_str_loc = i2 WITH protect, noconstant(0)
   DECLARE dsr_substr_len = i4 WITH protect, noconstant(0)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(drr_search_rep_rec)
   ENDIF
   FOR (cr_cnt = 1 TO drr_cmd_rec->cmd_cnt)
     FOR (srr_cnt = 1 TO drr_search_rep_rec->elem_cnt)
       IF (findstring("<=",drr_search_rep_rec->elems[srr_cnt].search_val,1,0) > 0)
        SET dsr_calc_str_loc = findstring(drr_search_rep_rec->elems[srr_cnt].search_val,drr_cmd_rec->
         cmds[cr_cnt].text,1,0)
        WHILE (dsr_calc_str_loc > 0)
          SET dsr_substr_len = ((textlen(drr_cmd_rec->cmds[cr_cnt].text) - dsr_calc_str_loc)+ 1)
          SET drr_search_rep_rec->elems[srr_cnt].temp_search_val = drr_get_inner_val(substring(
            dsr_calc_str_loc,dsr_substr_len,drr_cmd_rec->cmds[cr_cnt].text),"<=","=>",0)
          IF (drr_calc_replace_val(srr_cnt)=0)
           RETURN(0)
          ENDIF
          SET drr_cmd_rec->cmds[cr_cnt].text = replace(drr_cmd_rec->cmds[cr_cnt].text,
           drr_search_rep_rec->elems[srr_cnt].temp_search_val,drr_search_rep_rec->elems[srr_cnt].
           replace_val,1)
          SET dsr_calc_str_loc = findstring(drr_search_rep_rec->elems[srr_cnt].search_val,drr_cmd_rec
           ->cmds[cr_cnt].text,1,0)
        ENDWHILE
       ELSE
        SET drr_cmd_rec->cmds[cr_cnt].text = replace(drr_cmd_rec->cmds[cr_cnt].text,
         drr_search_rep_rec->elems[srr_cnt].search_val,drr_search_rep_rec->elems[srr_cnt].replace_val,
         0)
       ENDIF
     ENDFOR
   ENDFOR
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(drr_cmd_rec)
   ENDIF
 END ;Subroutine
 SUBROUTINE drr_calc_replace_val(sbr_elem_idx)
   DECLARE crv_temp_val = vc WITH protect, noconstant(" ")
   DECLARE crv_dfile_idx = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Calculating replace value."
   SET drr_search_rep_rec->elems[sbr_elem_idx].calc_param = drr_get_inner_val(drr_search_rep_rec->
    elems[sbr_elem_idx].temp_search_val,"(",")",1)
   IF (size(drr_search_rep_rec->elems[sbr_elem_idx].calc_param,1) != 5)
    SET dm_err->emsg = concat("The template contained an invalid DFILE tag <",drr_search_rep_rec->
     elems[sbr_elem_idx].calc_param,">.")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET crv_dfile_idx = drr_get_dfile_idx(drr_search_rep_rec->elems[sbr_elem_idx].calc_param)
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   CASE (drr_search_rep_rec->elems[sbr_elem_idx].search_val)
    OF "<=calcdisk(":
     SET drr_search_rep_rec->elems[sbr_elem_idx].replace_val = dm2_dfile_rec->qual[crv_dfile_idx].
     disk_name
    OF "<=calcpartition(":
     IF ((dm_err->debug_flag > 0))
      CALL echo(build("partition_data::",dm2_dfile_rec->qual[crv_dfile_idx].dfile_size_adj_mb,"::",
        dm2_create_dom->psize))
     ENDIF
     SET drr_search_rep_rec->elems[sbr_elem_idx].replace_val = format((dm2_dfile_rec->qual[
      crv_dfile_idx].dfile_size_adj_mb/ dm2_create_dom->psize),";L;I")
    OF "<=calcmwc(":
     SET drr_search_rep_rec->elems[sbr_elem_idx].replace_val = build(dm2_dfile_rec->qual[
      crv_dfile_idx].mwc_flag)
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("An unsupported calc function call ",drr_search_rep_rec->elems[
      sbr_elem_idx].temp_search_val," was found.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
   ENDCASE
   IF ((dm_err->debug_flag > 0))
    CALL echo(dm_err->asterisk_line)
    CALL echo(concat("SR_vals:",drr_search_rep_rec->elems[sbr_elem_idx].search_val,"^",
      drr_search_rep_rec->elems[sbr_elem_idx].temp_search_val,"^",
      drr_search_rep_rec->elems[sbr_elem_idx].replace_val,"^",drr_search_rep_rec->elems[sbr_elem_idx]
      .calc_param))
    CALL echo(dm_err->asterisk_line)
   ENDIF
   IF (check_error("Error detected while calculating replacement values.")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_get_dfile_idx(sbr_dfile_tag)
  DECLARE gdi_dfile_idx = i4 WITH protect, noconstant(0)
  IF ((sbr_dfile_tag=dm2_dfile_rec->cur_dfile_tag))
   RETURN(dm2_dfile_rec->cur_dfile_idx)
  ELSE
   SET gdi_dfile_idx = locateval(gdi_dfile_idx,1,dm2_dfile_rec->dfile_cnt,sbr_dfile_tag,dm2_dfile_rec
    ->qual[gdi_dfile_idx].dfile_tag)
   IF (gdi_dfile_idx=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Could not locate data file tag ",sbr_dfile_tag,
     " in memory. Verify tag ",
     "exists in the datafile template corresponding to this type of install.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm2_dfile_rec->cur_dfile_tag = sbr_dfile_tag
   SET dm2_dfile_rec->cur_dfile_idx = gdi_dfile_idx
   RETURN(gdi_dfile_idx)
  ENDIF
 END ;Subroutine
 SUBROUTINE drr_get_inner_val(sbr_full_str,sbr_beg_sym,sbr_end_sym,sbr_strip_sym_ind)
   DECLARE giv_beg_sym_len = i2 WITH protect, noconstant(0)
   DECLARE giv_end_sym_len = i2 WITH protect, noconstant(0)
   DECLARE giv_return_str = vc WITH protect, noconstant(" ")
   DECLARE giv_beg_sym_loc = i2 WITH protect, noconstant(0)
   DECLARE giv_end_sym_loc = i2 WITH protect, noconstant(0)
   SET giv_beg_sym_len = textlen(sbr_beg_sym)
   SET giv_end_sym_len = textlen(sbr_end_sym)
   SET giv_beg_sym_loc = findstring(sbr_beg_sym,sbr_full_str,1,0)
   SET giv_end_sym_loc = findstring(sbr_end_sym,sbr_full_str,1,0)
   IF (sbr_strip_sym_ind=1)
    SET giv_beg_pos = (giv_beg_sym_loc+ giv_beg_sym_len)
    SET giv_substr_len = (giv_end_sym_loc - giv_beg_pos)
   ELSE
    SET giv_beg_pos = giv_beg_sym_loc
    SET giv_substr_len = ((giv_end_sym_loc+ giv_end_sym_len) - giv_beg_pos)
   ENDIF
   SET giv_return_str = substring(giv_beg_pos,giv_substr_len,sbr_full_str)
   RETURN(giv_return_str)
 END ;Subroutine
 SUBROUTINE drr_load_cmds_from_file(dlcf_fname)
   SET dm_err->eproc = "Load each line in file into drr_cmd_rec record structure."
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE dlcf_pname = vc WITH protect, noconstant(" ")
   DECLARE dlcf_name = vc WITH protect, noconstant(" ")
   IF (cursys="AIX")
    SET dlcf_pname = concat("$cer_install/",dlcf_fname)
    SET dlcf_name = concat("cer_install:",dlcf_fname)
   ELSEIF (cursys="AXP")
    SET dlcf_pname = concat("cer_install:",dlcf_fname)
    SET dlcf_name = concat("cer_install:",dlcf_fname)
   ENDIF
   IF (dm2_findfile(dlcf_pname)=0)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ELSE
     SET dm_err->eproc = "Checking for template driver file."
     SET dm_err->emsg = concat("Template driver file ",dlcf_pname," not found.")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(dlcf_name)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    DETAIL
     drr_cmd_rec->cmd_cnt = (drr_cmd_rec->cmd_cnt+ 1), stat = alterlist(drr_cmd_rec->cmds,drr_cmd_rec
      ->cmd_cnt), drr_cmd_rec->cmds[drr_cmd_rec->cmd_cnt].text = trim(r.line)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(drr_cmd_rec)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_reset_cmd_rec(null)
   SET drr_cmd_rec->cmd_cnt = 0
   SET stat = alterlist(drr_cmd_rec->cmds,0)
   SET drr_cmd_rec->src_filename = ""
   SET drr_cmd_rec->tgt_filename = ""
   SET drr_cmd_rec->action_type = ""
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(drr_cmd_rec)
   ENDIF
 END ;Subroutine
 SUBROUTINE drr_perform_cmd_action(null)
   SET dm_err->eproc = concat("Performing command actions for ",drr_cmd_rec->src_filename,".")
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF ((drr_cmd_rec->action_type IN ("CF", "CFE", "CFO", "CFP")))
    IF (drr_write_cmds_to_file(null)=0)
     RETURN(0)
    ENDIF
    IF ((drr_cmd_rec->action_type IN ("CFE", "CFO")))
     IF (drr_exec_cmd_file(null)=0)
      RETURN(0)
     ENDIF
    ELSEIF ((drr_cmd_rec->action_type="CFP"))
     IF (dm2_push_compile(drr_cmd_rec->tgt_filename)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ELSEIF ((drr_cmd_rec->action_type="E"))
    IF (drr_exec_cmd_lines(null)=0)
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Executing template commands."
    SET dm_err->emsg = concat("Invalid action type: <",drr_cmd_rec->action_type,">.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Finished performing command actions for ",drr_cmd_rec->src_filename,
    ".")
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_write_cmds_to_file(null)
   DECLARE sbr_wcf_trim_text = vc WITH protect, noconstant(" ")
   SELECT INTO value(drr_cmd_rec->tgt_filename)
    d.seq
    FROM (dummyt d  WITH seq = drr_cmd_rec->cmd_cnt)
    DETAIL
     sbr_wcf_trim_text = trim(drr_cmd_rec->cmds[d.seq].text), col 0, sbr_wcf_trim_text
     IF ((d.seq < drr_cmd_rec->cmd_cnt))
      row + 1
     ENDIF
    WITH nocounter, maxrow = 1, format = variable,
     noformfeed
   ;end select
   IF (check_error(concat("Error writing ",drr_cmd_rec->tgt_filename,"."))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_exec_cmd_file(null)
   DECLARE dec_exec_file = vc WITH public, noconstant("NOT_SET")
   DECLARE dec_chmod_str = vc WITH public, noconstant("NOT_SET")
   IF (cursys="AIX")
    IF ((drr_cmd_rec->action_type="CFO"))
     SET dec_exec_file = concat("su - oracle -c ",trim(logical("CCLUSERDIR")),"/",drr_cmd_rec->
      tgt_filename)
    ELSE
     SET dec_exec_file = concat(trim(logical("CCLUSERDIR")),"/",drr_cmd_rec->tgt_filename)
    ENDIF
    SET dec_chmod_str = concat("chmod 777 $CCLUSERDIR/",drr_cmd_rec->tgt_filename)
   ELSE
    SET dec_chmod_str = concat("set file/prot =(s:RWED, o:RWED, g:RWED, w:RWED) CCLUSERDIR:",
     drr_cmd_rec->tgt_filename)
    SET dec_exec_file = concat("@CCLUSERDIR:",drr_cmd_rec->tgt_filename)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc = concat("drr_exec_cmd_file changing permissions for ",dec_exec_file,".")
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (dm2_push_dcl(dec_chmod_str)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc = concat("drr_exec_cmd_file now executing ",dec_exec_file,".")
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (findstring("restore",cnvtlower(drr_cmd_rec->tgt_filename)) > 0)
    SET dm_err->eproc =
    "Restoring database backup files.  This process may take as much as 30 minutes to complete."
    SET dm_err->user_action =
    "For information on monitoring the restore process, see the Installation Guide."
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (dm2_push_dcl(dec_exec_file)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_exec_cmd_lines(null)
   DECLARE sbr_ecl_idx = i4 WITH public, noconstant(0)
   DECLARE sbr_ecl_cmd_txt = vc WITH protect, noconstant("DM2_NOT_SET")
   DECLARE sbr_ecl_err_str = vc WITH protect, noconstant("DM2_NOT_SET")
   DECLARE sbr_ecl_err_str2 = vc WITH protect, noconstant("DM2_NOT_SET")
   DECLARE sbr_ecl_tmp_err_ind = i2 WITH protect, noconstant(0)
   IF (cursys="AIX")
    SET sbr_ecl_err_str = "does not exist"
   ELSEIF (cursys="AXP")
    SET sbr_ecl_err_str = "directory not found"
    SET sbr_ecl_err_str2 = "no files found"
   ENDIF
   FOR (sbr_ecl_idx = 1 TO drr_cmd_rec->cmd_cnt)
     SET sbr_ecl_tmp_err_ind = 0
     IF (findstring("update_reg",drr_cmd_rec->cmds[sbr_ecl_idx].text,1,0) > 0)
      IF (drr_exec_update_reg(drr_cmd_rec->cmds[sbr_ecl_idx].text)=0)
       RETURN(0)
      ENDIF
     ELSE
      CALL dm2_push_dcl(drr_cmd_rec->cmds[sbr_ecl_idx].text)
     ENDIF
     IF ((dm_err->err_ind=1))
      SET dm_err->err_ind = 0
      SET sbr_ecl_tmp_err_ind = 1
     ENDIF
     IF (parse_errfile(dm_err->errfile)=0)
      RETURN(0)
     ENDIF
     IF (findstring(sbr_ecl_err_str,dm_err->errtext,1,0) > 0)
      CALL echo("found the error string")
      SET dm_err->eproc = "A file or directory was not found.  This is an acceptable error."
      CALL disp_msg(" ",dm_err->logfile,0)
      RETURN(1)
     ELSEIF (findstring(sbr_ecl_err_str2,dm_err->errtext,1,0) > 0)
      SET dm_err->eproc = "A file or directory was not found.  This is an acceptable error."
      CALL disp_msg(" ",dm_err->logfile,0)
      RETURN(1)
     ELSEIF (sbr_ecl_tmp_err_ind=1)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_parse_delim_txt(null)
   SET dm_err->eproc = "Parse text to get elements seperated by delimiter."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   DECLARE dpd_end_str = i2 WITH protect, noconstant(0)
   DECLARE dpd_beg_pos = i2 WITH protect, noconstant(0)
   DECLARE dpd_end_pos = i2 WITH protect, noconstant(0)
   DECLARE dpd_final_pos = i2 WITH protect, noconstant(0)
   SET drr_delim_txt_rec->txt_elem_cnt = 0
   SET stat = alterlist(drr_delim_txt_rec->qual,0)
   SET dpd_final_pos = size(drr_delim_txt_rec->orig_txt)
   SET dpd_beg_pos = 1
   SET dpd_end_pos = findstring(drr_delim_txt_rec->sep_char,drr_delim_txt_rec->orig_txt)
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("beg_pos =",dpd_beg_pos))
    CALL echo(build("end_pos =",dpd_end_pos))
    CALL echo(build("final_pos =",dpd_final_pos))
    CALL echo(build("orig_txt =",drr_delim_txt_rec->orig_txt))
   ENDIF
   IF (dpd_end_pos=0)
    IF ((dm_err->debug_flag > 0))
     CALL echo("No delimiter found.")
    ENDIF
    RETURN(1)
   ENDIF
   WHILE (dpd_end_str != 1)
     SET drr_delim_txt_rec->txt_elem_cnt = (drr_delim_txt_rec->txt_elem_cnt+ 1)
     SET stat = alterlist(drr_delim_txt_rec->qual,drr_delim_txt_rec->txt_elem_cnt)
     IF (dpd_end_pos=dpd_final_pos)
      SET drr_delim_txt_rec->qual[drr_delim_txt_rec->txt_elem_cnt].txt_elem = substring(dpd_beg_pos,(
       (dpd_end_pos - dpd_beg_pos)+ 1),drr_delim_txt_rec->orig_txt)
      SET dpd_end_str = 1
     ELSE
      SET drr_delim_txt_rec->qual[drr_delim_txt_rec->txt_elem_cnt].txt_elem = substring(dpd_beg_pos,(
       dpd_end_pos - dpd_beg_pos),drr_delim_txt_rec->orig_txt)
      SET dpd_beg_pos = (dpd_end_pos+ 1)
      SET dpd_end_pos = findstring(drr_delim_txt_rec->sep_char,drr_delim_txt_rec->orig_txt,
       dpd_beg_pos)
      IF (dpd_end_pos=0)
       SET dpd_end_pos = dpd_final_pos
      ENDIF
     ENDIF
   ENDWHILE
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(drr_delim_txt_rec)
   ENDIF
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_reset_search_rep_rec(null)
   SET drr_search_rep_rec->elem_cnt = 0
   SET dm_err->eproc = "Resetting drr_search_rep_rec."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET stat = alterlist(drr_search_rep_rec->elems,0)
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(drr_search_rep_rec)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_push_compile(sbr_dpc_file)
   DECLARE sbr_dpc_full_path = vc WITH public, noconstant("dm2_not_set")
   IF (cursys="AIX")
    SET sbr_dpc_full_path = build(logical("CCLUSERDIR"),"/",sbr_dpc_file)
   ELSE
    SET sbr_dpc_full_path = build("CCLUSERDIR:",sbr_dpc_file)
   ENDIF
   IF (dm2_findfile(sbr_dpc_full_path)=0)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ELSE
     SET dm_err->eproc = concat("Checking for ",sbr_dpc_full_path,".")
     SET dm_err->emsg = concat("CCL file ",sbr_dpc_full_path," not found.")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo("*")
    CALL echo(concat("dm2_push_compile compiling: ",sbr_dpc_full_path))
    CALL echo("*")
   ENDIF
   CALL compile(sbr_dpc_full_path)
   IF (check_error(concat("Error executing ",sbr_dpc_full_path,".")) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_exec_update_reg(sbr_deur_updtreg_cmd)
   DECLARE sbr_deur_lreg_cmd = vc WITH public, noconstant("not_set")
   DECLARE sbr_deur_dcl_stat = i4 WITH public, noconstant(0)
   SET dm_err->eproc = "Importing registry updates with update_reg."
   SET dm_err->errfile = dm_err->unique_fname
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (cursys="AIX")
    SET sbr_deur_lreg_cmd = concat("lreg -getp \\dbinstance\\",dm2_create_dom->dname,"1 database",
     " > ",dm2_install_schema->ccluserdir,
     dm_err->errfile," 2>&1")
   ELSE
    SET sbr_deur_lreg_cmd = concat("pipe lreg -getp \dbinstance\",dm2_create_dom->dname,
     "1 database ;show symbol lreg_result"," > ccluserdir:",dm_err->errfile)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo("*")
    CALL echo(concat("call dcl executing: ",sbr_deur_updtreg_cmd))
    CALL echo("*")
   ENDIF
   CALL dcl(sbr_deur_updtreg_cmd,size(sbr_deur_updtreg_cmd),sbr_deur_dcl_stat)
   CALL dcl(sbr_deur_lreg_cmd,size(sbr_deur_lreg_cmd),sbr_deur_dcl_stat)
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   IF (findstring(cnvtlower(dm2_create_dom->dname),trim(cnvtlower(dm_err->errtext)))=0)
    SET dm_err->emsg = "Registry update failed.  Database instance not defined."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_add_sr_data(sbr_search_val_str,sbr_replace_val_str)
   SET drr_search_rep_rec->elem_cnt = (drr_search_rep_rec->elem_cnt+ 1)
   SET stat = alterlist(drr_search_rep_rec->elems,drr_search_rep_rec->elem_cnt)
   SET drr_search_rep_rec->elems[drr_search_rep_rec->elem_cnt].search_val = sbr_search_val_str
   SET drr_search_rep_rec->elems[drr_search_rep_rec->elem_cnt].replace_val = sbr_replace_val_str
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
 DECLARE dm2_ping(host_name=vc) = i2
 SUBROUTINE dm2_ping(host_name)
  SET dm_err->eproc = concat("Ping host ",host_name)
  IF ((dm2_sys_misc->cur_os IN ("LNX", "AIX")))
   RETURN(dm2_push_dcl(concat("ping -c 1 ",host_name)))
  ELSEIF ((dm2_sys_misc->cur_os="AXP"))
   RETURN(dm2_push_dcl(concat("tcpip ping /number_packets=1 ",host_name)))
  ELSEIF ((dm2_sys_misc->cur_os="HPX"))
   RETURN(dm2_push_dcl(concat("ping ",host_name," -n 1")))
  ELSE
   SET dm_err->err_ind = 1
   SET dm_err->emsg = "Operating System not supported."
   RETURN(0)
  ENDIF
 END ;Subroutine
 DECLARE dcdud_drop_needed = i2 WITH protect, noconstant(0)
 DECLARE dcdud_eproc_string = vc WITH protect, noconstant("")
 DECLARE dcdud_cnt = i4 WITH protect, noconstant(0)
 DECLARE dcdud_str = vc WITH protect, noconstant("")
 DECLARE dcdud_running_ret = i2 WITH protect, noconstant(0)
 DECLARE dcdud_delete_only = i2 WITH protect, noconstant(0)
 DECLARE dcdud_continue = i2 WITH protect, noconstant(1)
 IF (validate(dm2_allow_delete_only,- (1))=1)
  SET dcdud_delete_only = 1
 ENDIF
 DECLARE dcdud_allow_dbtype_create_ind = i2 WITH protect, noconstant(0)
 IF (validate(dm2_allow_dbtype_create,- (1))=1)
  SET dcdud_allow_dbtype_create_ind = 1
 ENDIF
 DECLARE dcdud_override_template_name = vc WITH protect, noconstant("dm2_not_set")
 IF (validate(dm2_template_name_override,"x") != "x")
  SET dcdud_override_template_name = dm2_template_name_override
 ENDIF
 DECLARE dcdud_override_admin_dbname = vc WITH protect, noconstant("dm2_not_set")
 IF (validate(dm2_override_admin_dbname," ") != " ")
  SET dcdud_override_admin_dbname = dm2_override_admin_dbname
 ENDIF
 DECLARE dcdud_override_admin_db_pass = vc WITH protect, noconstant("CDBA")
 IF (validate(dm2_override_admin_db_pass," ") != " ")
  SET dcdud_override_admin_db_pass = dm2_override_admin_db_pass
 ENDIF
 DECLARE dcdud_bypass_restore = i2 WITH protect, noconstant(0)
 IF (validate(dm2_bypass_restore,- (1))=1)
  SET dcdud_bypass_restore = 1
 ENDIF
 DECLARE dcdud_admin_dbname = vc WITH protect, noconstant("")
 DECLARE dcdud_admin_cstr = vc WITH protect, noconstant("")
 DECLARE dcdud_gather_prereqs(null) = i2
 DECLARE dcdud_disp_prereq_screen(null) = i2
 DECLARE dcdud_transform_templates(null) = i2
 DECLARE dcdud_setup_sqlnet(dss_local=i2,dss_node=vc,dss_oracle_home=vc) = i2
 DECLARE dcdud_check_drop_db(dcdb_check_db_dropped_only=i2) = i2
 DECLARE dcdud_manage_tnsentry(drt_action=vc,drt_local=vc,drt_user=vc,drt_node=vc,drt_tnsdir=vc,
  drt_dname=vc,drt_tmpdir=vc,drt_tnsdirrmt=vc,drt_tnshost=vc) = i2
 DECLARE dcdud_check_instance(dci_local=i2,dci_instance_name=vc,dci_node=vc,dci_running_out=i2(ref))
  = i2
 DECLARE dcdud_updatetns(null) = i2
 IF (dcdud_override_admin_dbname != "dm2_not_set")
  SET dcdud_admin_dbname = dcdud_override_admin_dbname
  SET dcdud_admin_cstr = concat(dcdud_override_admin_dbname,"1")
 ELSE
  SET dcdud_admin_dbname = "admin"
  SET dcdud_admin_cstr = "admin1"
 ENDIF
 IF (check_logfile("dm2_create_dbcadb",".log","DM2_CREATE_DB_USING_DBCA LOG FILE")=0)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Begin DM2_CREATE_DB_USING_DBCA"
 CALL disp_msg(" ",dm_err->logfile,0)
 IF (dcd_prompt_for_dom_info(null)=0)
  GO TO exit_script
 ENDIF
 IF ((dm2_create_dom->response_file_in_use=0))
  IF (dcdud_gather_prereqs(null)=0)
   GO TO exit_script
  ENDIF
 ELSE
  IF (dcd_get_ora_ver(null)=0)
   GO TO exit_script
  ENDIF
 ENDIF
 IF (dcd_get_ora_kernel_user(null)=0)
  GO TO exit_script
 ENDIF
 IF (validate(dm2_cd_override_rac_option,"x") != "x")
  SET dm2_create_dom->rac_option = dm2_cd_override_rac_option
  SET dm_err->eproc = "Bypassing call to get rac config (override detected/used)."
  CALL disp_msg(" ",dm_err->logfile,0)
 ELSE
  IF (dcd_get_rac_config(null)=0)
   GO TO exit_script
  ENDIF
 ENDIF
 IF (validate(dm2_cd_override_crs_home,"x") != "x")
  IF (((validate(dm2_cd_override_crs_state,"x")="x") OR (validate(dm2_cd_override_crs_exe,"x")="x"))
  )
   SET dm_err->eproc = "Checking CRS variable overrides."
   SET dm_err->emsg = concat(
    "All of the following variables must be supplied in order to override scripts detected ",
    "values:  dm2_cd_override_crs_home, dm2_cd_override_crs_state and dm2_cd_override_crs_exe.")
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   GO TO exit_script
  ENDIF
  SET dm2_create_dom->crs_home = dm2_cd_override_crs_home
  SET dm2_create_dom->crs_state = cnvtupper(dm2_cd_override_crs_state)
  SET dm2_create_dom->crsctl_chk = dm2_cd_override_crs_exe
  SET dm_err->eproc = "Bypassing call to check CRS (overrides detected/used)."
  CALL disp_msg(" ",dm_err->logfile,0)
 ELSE
  IF (dcd_check_crs(dm2_create_dom->local_db,dm2_create_dom->db_node_name,"root")=0)
   GO TO exit_script
  ENDIF
 ENDIF
 IF (dcdud_transform_templates(null)=0)
  GO TO exit_script
 ENDIF
 IF (dcdud_bypass_restore=0)
  IF (dcdud_check_drop_db(0)=0)
   GO TO exit_script
  ENDIF
  IF (dcdud_delete_only=1)
   SET dm_err->eproc = "Exiting. Process set to remove database only."
   CALL disp_msg("",dm_err->logfile,0)
   GO TO exit_script
  ENDIF
  IF (dcdud_drop_needed=1)
   SET dcdud_drop_needed = 0
   IF (dcdud_check_drop_db(1)=0)
    GO TO exit_script
   ENDIF
  ENDIF
  SET dm_err->eproc = "Copy the template files into dbca template directory on primary database node"
  CALL disp_msg(" ",dm_err->logfile,0)
  CALL dor_init_flex_cmds(null)
  CALL dor_add_flex_cmd(dm2_create_dom->local_db,"oracle",dm2_create_dom->db_node_name,concat(
    "/cerner/w_standard/",dm2_create_dom->dbtype,"/dm2_ni_dbca_seeded_template",char(42),".",
    char(42))," ",
   concat(dm2_create_dom->rmt_oracle_home,"/assistants/dbca/templates/"),"RCP")
  CALL dor_add_flex_cmd(dm2_create_dom->local_db,"root",dm2_create_dom->db_node_name," ",concat(
    "chown -R oracle:dba ",dm2_create_dom->rmt_oracle_home,"/assistants/dbca/templates/"),
   " ","EC")
  CALL dor_add_flex_cmd(dm2_create_dom->local_db,"root",dm2_create_dom->db_node_name," ",concat(
    "chmod 777 ",dm2_create_dom->rmt_oracle_home,"/assistants/dbca/templates/dm2_ni_dbca*.*"),
   " ","EC")
  IF (dor_exec_flex_cmd(null)=0)
   GO TO exit_script
  ENDIF
  IF (dcdud_setup_sqlnet(1,curnode,dm2_create_dom->oracle_home)=0)
   GO TO exit_script
  ENDIF
  IF (dcdud_setup_sqlnet(dm2_create_dom->local_db,dm2_create_dom->db_node_name,dm2_create_dom->
   rmt_oracle_home)=0)
   GO TO exit_script
  ENDIF
  SET dm_err->eproc = "Begin the database restore."
  CALL disp_msg(" ",dm_err->logfile,0)
  CALL dor_init_flex_cmds(null)
  CALL dor_add_flex_cmd(dm2_create_dom->local_db,"oracle",dm2_create_dom->db_node_name,concat('"',
    dm2_create_dom->rmt_temp_dir,"/restore_",dm2_create_dom->dname,'_database.ksh"')," ",
   " ","EFO")
  IF (dor_exec_flex_cmd(null)=0)
   GO TO exit_script
  ENDIF
  SET dm_err->eproc = "Check for errors in restore."
  CALL disp_msg(" ",dm_err->logfile,0)
  CALL dor_init_flex_cmds(null)
  CALL dor_add_flex_cmd(dm2_create_dom->local_db,"root",dm2_create_dom->db_node_name," ",concat(
    "test -f /tmp/",dm2_create_dom->dname,"_dbca_ora_err.log ;echo $?"),
   " ","EC")
  IF (dor_exec_flex_cmd(null)=0)
   GO TO exit_script
  ENDIF
  IF ((dor_flex_cmd->cmd[1].flex_output="0"))
   SET dm_err->emsg = concat(
    "Oracle errors found in DBCA log file. Error captured may be viewed in /tmp/",dm2_create_dom->
    dname,"_dbca_ora_err.log on the database node.")
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
 ENDIF
 IF (validate(dm2_bypass_updatetns_work,"x") != "x")
  SET dm_err->eproc = "Bypassing call to updatetns work (override detected/used)."
  CALL disp_msg(" ",dm_err->logfile,0)
 ELSE
  IF (dcdud_updatetns(null)=0)
   GO TO exit_script
  ENDIF
 ENDIF
 SET dm2_install_schema->dbase_name = dm2_create_dom->dname
 SET dm2_install_schema->u_name = "SYS"
 SET dm2_install_schema->p_word = dm2_create_dom->oracle_sys_pass
 SET dm2_install_schema->connect_str = concat(dm2_create_dom->dname,"1")
 EXECUTE dm2_connect_to_dbase "CO"
 IF ((dm_err->err_ind > 0))
  GO TO exit_script
 ENDIF
 FREE RECORD dcdud_users
 RECORD dcdud_users(
   1 user_cnt = i2
   1 qual[*]
     2 username = vc
 )
 SET dm_err->eproc = "Obtain list of Cerner users."
 SELECT
  IF ((dm2_create_dom->dbtype="admin"))
   FROM dba_users d
   WHERE d.username="CDBA"
  ELSE
   FROM dba_users d
   WHERE d.username="V500*"
  ENDIF
  INTO "nl:"
  DETAIL
   dcdud_users->user_cnt = (dcdud_users->user_cnt+ 1), stat = alterlist(dcdud_users->qual,dcdud_users
    ->user_cnt), dcdud_users->qual[dcdud_users->user_cnt].username = d.username
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc) > 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 FOR (dcdud_cnt = 1 TO dcdud_users->user_cnt)
   SET dm_err->eproc = concat("Reset password and unlock account for user: ",dcdud_users->qual[
    dcdud_cnt].username)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dm2_push_cmd(concat("rdb alter user ",dcdud_users->qual[dcdud_cnt].username," identified by ",
     dcdud_users->qual[dcdud_cnt].username," account unlock go"),1)=0)
    GO TO exit_script
   ENDIF
 ENDFOR
 EXECUTE dm2_setup_new_db
 IF ((dm_err->err_ind > 0))
  GO TO exit_script
 ENDIF
 SET dcdud_running_ret = 0
 IF (dcdud_check_instance(dm2_create_dom->local_db,concat(dm2_create_dom->dname,"1"),dm2_create_dom->
  db_node_name,dcdud_running_ret)=0)
  GO TO exit_script
 ENDIF
 IF (dcdud_running_ret=0)
  SET dm_err->emsg = concat("Failed to find running database instance ",dm2_create_dom->dname,"1 on ",
   dm2_create_dom->db_node_name)
  SET dm_err->err_ind = 1
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF ((dm2_create_dom->dbtype="strt"))
  SET dm2_install_schema->u_name = "V500"
  SET dm2_install_schema->p_word = "V500"
 ELSE
  SET dm2_install_schema->u_name = "CDBA"
  SET dm2_install_schema->p_word = "CDBA"
 ENDIF
 SET dm2_install_schema->dbase_name = dm2_create_dom->dname
 SET dm2_install_schema->connect_str = concat(dm2_create_dom->dname,"1")
 EXECUTE dm2_connect_to_dbase "CO"
 IF (trim(logical("environment")) != "admin"
  AND (dm2_create_dom->dbtype="admin"))
  SET dm_err->eproc = concat("Installing ADMIN database type in environment:",trim(logical(
     "environment")),". Bypassing registry updates for ADMIN.")
  CALL disp_msg(" ",dm_err->logfile,0)
 ELSE
  IF (dcd_db_reg_entries(null)=0)
   GO TO exit_script
  ENDIF
  SET dm_err->eproc = "Update registry entries for database."
  CALL disp_msg(" ",dm_err->logfile,0)
  CALL dor_init_flex_cmds(null)
  CALL dor_add_flex_cmd(1," "," "," ",concat("$cer_exe/update_reg -input $CCLUSERDIR/update_reg_",
    dm2_create_dom->dname,".csv"),
   " ","EC")
  IF (dor_exec_flex_cmd(null)=0)
   GO TO exit_script
  ENDIF
  SET dm_err->eproc = "Write login_default file."
  CALL disp_msg(" ",dm_err->logfile,0)
  IF (dcd_write_login_default(null)=0)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((dm2_create_dom->dbtype != "admin"))
  EXECUTE dm2_create_admin_link dcdud_admin_cstr, "none", dcdud_override_admin_db_pass
  IF ((dm_err->err_ind=1))
   GO TO exit_script
  ENDIF
  IF (dcd_set_envid(null)=0)
   GO TO exit_script
  ENDIF
  IF (dcd_exec_load_hist(null)=0)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((dm2_create_dom->dbtype != "admin"))
  SET dm_err->eproc = "Initialize EM admin information."
  CALL disp_msg(" ",dm_err->logfile,0)
  EXECUTE euc_data_load_wrapper
  IF ((dm_err->err_ind=1))
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  EXECUTE dep_dbmaintenance_wrapper
  IF ((((readme_data->status="F")) OR (check_error(dm_err->eproc) > 0)) )
   SET dm_err->err_ind = 1
   IF ((readme_data->status="F"))
    SET dm_err->emsg = readme_data->message
   ENDIF
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  EXECUTE dm2_rdm_refresh_rdds_views
  IF ((dm_err->err_ind=1))
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  EXECUTE dm2_rdds_metadata_refresh "NONE"
  IF ((dm_err->err_ind=1))
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((dm2_create_dom->response_file_in_use=1))
  SET dm_err->eproc = "Removing the response file from ccluserdir."
  CALL disp_msg("",dm_err->logfile,0)
  CALL dor_init_flex_cmds(null)
  CALL dor_add_flex_cmd(1," "," "," ",concat("rm -f ",dm2_create_dom->local_ccluserdir,
    "/dm2_response_data.dat"),
   " ","EC")
  IF (dor_exec_flex_cmd(null)=0)
   GO TO exit_script
  ENDIF
 ENDIF
 GO TO exit_script
 SUBROUTINE dcdud_check_instance(dci_local,dci_instance_name,dci_node,dci_running_out)
   SET dm_err->eproc = concat("Check status of ",dci_instance_name," on ",dci_node,".")
   CALL disp_msg(" ",dm_err->logfile,0)
   CALL dor_init_flex_cmds(null)
   CALL dor_add_flex_cmd(dci_local,"root",dci_node," ",concat(
     "ps -fu oracle|grep pmon|cut -d_ -f3|grep -w ",dci_instance_name),
    " ","EC")
   IF (dor_exec_flex_cmd(null)=0)
    RETURN(0)
   ENDIF
   IF (trim(dor_flex_cmd->cmd[1].flex_output)=dci_instance_name)
    SET dci_running_out = 1
   ELSE
    SET dci_running_out = 0
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdud_setup_sqlnet(dss_local,dss_node,dss_oracle_home)
   SET dm_err->eproc = concat("Update sqlnet.ora on ",dss_node)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dss_local=1)
    IF (dor_flex_chmod_file(concat(trim(logical("cer_wh")),"/install/dm2_update_sqlnet.ksh")," ")=0)
     RETURN(0)
    ENDIF
   ENDIF
   CALL dor_init_flex_cmds(null)
   CALL dor_add_flex_cmd(dss_local,"oracle",dss_node,concat(trim(logical("cer_wh")),
     "/install/dm2_update_sqlnet.ksh")," ",
    concat(dm2_create_dom->rmt_temp_dir,"/dm2_update_sqlnet.ksh"),"RCP")
   CALL dor_add_flex_cmd(dss_local,"oracle",dss_node,concat('"',dm2_create_dom->rmt_temp_dir,
     "/dm2_update_sqlnet.ksh ",dss_oracle_home,'"')," ",
    " ","EFO")
   IF (dor_exec_flex_cmd(null)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdud_manage_tnsentry(drt_action,drt_local,drt_user,drt_node,drt_tnsdir,drt_dname,
  drt_tmpdir,drt_tnsdirrmt,drt_tnshost)
   DECLARE drt_exec_file = vc WITH protect, noconstant(concat(drt_tmpdir,"/dm2_",drt_dname,"_",
     cnvtlower(drt_action),
     "_tns_entry.ksh"))
   DECLARE drt_exclude_file = vc WITH protect, noconstant(concat(drt_tmpdir,"/",drt_dname,
     "_exclude.txt"))
   DECLARE drt_dbentry_file = vc WITH protect, noconstant(concat(drt_tmpdir,"/dm2_",drt_dname,
     "_tnsnames.txt"))
   DECLARE drt_temptns_file = vc WITH protect, noconstant(concat(drt_tmpdir,"/dm2_temp_",drt_dname,
     "_tnsnames.txt"))
   DECLARE drt_tnsdir_exec = vc WITH protect, noconstant("")
   DECLARE drt_bypass_tns_host_chk = i2 WITH protect, noconstant(0)
   IF (validate(dm2_bypass_tns_host_check,- (1))=1)
    SET drt_bypass_tns_host_chk = 1
    SET dm_err->eproc = "Bypassing tns_host_check - external flag set"
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET dm_err->eproc = concat(drt_action," TNS entry.")
   CALL disp_msg("",dm_err->logfile,0)
   IF (drt_local=0)
    SET drt_tnsdir_exec = drt_tnsdirrmt
   ELSE
    SET drt_tnsdir_exec = drt_tnsdir
   ENDIF
   CALL dcd_add_text(" ",1)
   CALL dcd_add_text("#!/bin/ksh",0)
   CALL dcd_add_text(concat("rm -f ",drt_dbentry_file),0)
   CALL dcd_add_text(concat("rm -f ",drt_exclude_file),0)
   CALL dcd_add_text(concat("rm -f ",drt_temptns_file),0)
   CALL dcd_add_text("unset LineCnt",0)
   CALL dcd_add_text("unset rparentot",0)
   CALL dcd_add_text("unset lparentot",0)
   CALL dcd_add_text("unset ResolvedCnt",0)
   CALL dcd_add_text("unset StanzaStart",0)
   CALL dcd_add_text("typeset -i LineCnt",0)
   CALL dcd_add_text("typeset -i lparentot",0)
   CALL dcd_add_text("typeset -i ResolvedCnt",0)
   CALL dcd_add_text("typeset -i StanzaStart",0)
   CALL dcd_add_text("typeset -i rparentot",0)
   CALL dcd_add_text("LineCnt=0",0)
   CALL dcd_add_text("lparencnt=0",0)
   CALL dcd_add_text("lparentot=0",0)
   CALL dcd_add_text("ResolvedCnt=0",0)
   CALL dcd_add_text("StanzaStart=0",0)
   CALL dcd_add_text("while read line",0)
   CALL dcd_add_text("do                  ",0)
   CALL dcd_add_text("  #keep counter of lines ",0)
   CALL dcd_add_text("  ((LineCnt=${LineCnt}+1))",0)
   CALL dcd_add_text("  #convert line to lowercase for evaluation",0)
   CALL dcd_add_text("  LowerLine=`echo $line | tr '[:upper:]' '[:lower:]'` ",0)
   CALL dcd_add_text("  LowerLineNoSpace=`echo $LowerLine | sed 's/ *//g'`",0)
   CALL dcd_add_text(concat("  #Reset StanzaStart when ResolvedCnt has dropped back to zero. ",
     "In order for StanzaStart to equal 2, ResolvedCnt"),0)
   CALL dcd_add_text("  #would have had to have been > 0 at one time  ",0)
   CALL dcd_add_text("  if [[ ${StanzaStart} -eq 2 && ${ResolvedCnt} = 0 ]]",0)
   CALL dcd_add_text("  then",0)
   CALL dcd_add_text("    ((StanzaStart=0))",0)
   CALL dcd_add_text("    ((lparencnt=0))",0)
   CALL dcd_add_text("    ((rparencnt=0))",0)
   CALL dcd_add_text("  fi",0)
   CALL dcd_add_text("  #if the stanza is found and we are not excluding a stanza at the time",0)
   CALL dcd_add_text(concat("  if [[ (${LowerLine} = ",drt_dname,"?.world* || ${LowerLine} =  ",
     drt_dname,".world* ) && ${StanzaStart} -eq 0 ]]"),0)
   CALL dcd_add_text("  then",0)
   CALL dcd_add_text("    #Found first line of stanza",0)
   CALL dcd_add_text("    ((StanzaStart=1))",0)
   CALL dcd_add_text("  fi  ",0)
   CALL dcd_add_text("  #start counting parens at first and subsequent lines of stanza",0)
   CALL dcd_add_text("  if [[ ${StanzaStart} -eq 1 || ${StanzaStart} -eq 2 ]]",0)
   CALL dcd_add_text("  then",0)
   IF (drt_action != "ADD"
    AND drt_bypass_tns_host_chk != 1)
    CALL dcd_add_text("      if [[ ${LowerLineNoSpace} = *host=* ]]",0)
    CALL dcd_add_text("      then",0)
    CALL dcd_add_text(concat(
      "        if [[ `echo $LowerLineNoSpace | sed 's/.*host=//' | sed 's/).*//'` != *",
      dm2_create_dom->tns_host,"* ]]"),0)
    CALL dcd_add_text("        then",0)
    CALL dcd_add_text(
     '          echo "FAILED-HOSTCHECK:TNS Stanza detected for database under different host."',0)
    CALL dcd_add_text("          exit 1",0)
    CALL dcd_add_text("        fi",0)
    CALL dcd_add_text("      fi",0)
   ENDIF
   CALL dcd_add_text("      #accumulate total number of left and right parens",0)
   CALL dcd_add_text(concat('      ((lparentot= ${lparentot}+ `echo $line | sed "s/',
     '[^(]//g" | wc -c`))'),0)
   CALL dcd_add_text(concat('      ((rparentot= ${rparentot}+ `echo $line | sed "s/',
     '[^)]//g" | wc -c`))'),0)
   CALL dcd_add_text(
    "      #once the resolved count reaches 0 the last matching paren has been found",0)
   CALL dcd_add_text("      ((ResolvedCnt=${lparentot}-${rparentot}))",0)
   CALL dcd_add_text(concat(
     '      echo "Lp:${lparentot},Rp:${rparentot},Res:${ResolvedCnt},StanzaStart:${StanzaStart}, ',
     '${LineCnt}, $LowerLine" >> ',drt_exclude_file),0)
   CALL dcd_add_text("      if [[ ${ResolvedCnt} -gt 0 ]]",0)
   CALL dcd_add_text("      then",0)
   CALL dcd_add_text(concat('        sed -n "${LineCnt}p" ',drt_tnsdir_exec,"/tnsnames.ora | sed ",
     "'s/^/ /' ","| sed 's/LOAD_BALANCE = yes/LOAD_BALANCE = no/g' >> ",
     drt_dbentry_file),0)
   CALL dcd_add_text("      else",0)
   CALL dcd_add_text(concat('        sed -n "${LineCnt}p" ',drt_tnsdir_exec,
     "/tnsnames.ora | sed 's/LOAD_BALANCE = yes/LOAD_BALANCE = no/g' >> ",drt_dbentry_file),0)
   CALL dcd_add_text("      fi",0)
   CALL dcd_add_text("  fi",0)
   CALL dcd_add_text(
    "  #First line of stanza may not contain ( or ). Once we have found ( or ) set StanzaStart to 2",
    0)
   CALL dcd_add_text("  if [[ ${ResolvedCnt} -gt 0 ]] ",0)
   CALL dcd_add_text("  then",0)
   CALL dcd_add_text("  ((StanzaStart=2))",0)
   CALL dcd_add_text("  fi",0)
   CALL dcd_add_text("  #Print any lines that are not involved in the stanza being excluded",0)
   CALL dcd_add_text("  if [[ ${StanzaStart} -eq 0 ]]",0)
   CALL dcd_add_text("  then ",0)
   CALL dcd_add_text(concat('  sed -n "${LineCnt}p" ',drt_tnsdir_exec,"/tnsnames.ora >> ",
     drt_temptns_file),0)
   CALL dcd_add_text("  fi",0)
   CALL dcd_add_text(concat("done<",drt_tnsdir_exec,"/tnsnames.ora"),0)
   IF (drt_action="REMOVE")
    CALL dcd_add_text("if [[ ${lparentot} -gt 0 ]]",0)
    CALL dcd_add_text("then",0)
    CALL dcd_add_text(concat("cp ",drt_temptns_file," ",drt_tnsdir_exec,"/tnsnames.ora"),0)
    CALL dcd_add_text("fi",0)
   ENDIF
   IF (drt_action="MANAGE")
    CALL dcd_add_text("if [[ ${lparentot} -gt 0 ]]",0)
    CALL dcd_add_text("then",0)
    CALL dcd_add_text(concat("  cp ",drt_temptns_file," ",drt_tnsdir_exec,"/tnsnames.ora"),0)
    CALL dcd_add_text(concat("  if [[ -f ",drt_dbentry_file," ]]"),0)
    CALL dcd_add_text("  then",0)
    CALL dcd_add_text(concat("    cat ",drt_dbentry_file," >> ",drt_tnsdir_exec,"/tnsnames.ora"),0)
    CALL dcd_add_text("  fi",0)
    CALL dcd_add_text("fi",0)
   ENDIF
   IF (dcd_create_text_file(drt_exec_file)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Execute the TNS management script."
   CALL disp_msg("",dm_err->logfile,0)
   CALL dor_init_flex_cmds(null)
   IF (drt_local=0)
    CALL dor_add_flex_cmd(drt_local,drt_user,drt_node,drt_exec_file," ",
     drt_exec_file,"RCP")
   ENDIF
   CALL dor_add_flex_cmd(drt_local,drt_user,drt_node,drt_exec_file," ",
    " ","EFRO")
   IF (dor_exec_flex_cmd(null)=0)
    RETURN(0)
   ENDIF
   IF ((dor_flex_cmd->cmd[1].flex_output > " "))
    SET message = nowindow
    SET dm_err->emsg = dor_flex_cmd->cmd[1].flex_output
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (drt_action="REMOVE")
    SET dm_err->eproc = concat("Verify contents related to ",drt_dname,
     " are cleared from tnsnames.ora.")
    CALL disp_msg("",dm_err->logfile,0)
    CALL dor_init_flex_cmds(null)
    CALL dor_add_flex_cmd(drt_local,drt_user,drt_node," ",concat("grep -i -w ",drt_dname,".\*.world ",
      drt_tnsdir,"/tnsnames.ora | grep -vi LISTENER"),
     " ","EC")
    IF (dor_exec_flex_cmd(null)=0)
     RETURN(0)
    ENDIF
    IF ((dor_flex_cmd->cmd[1].flex_output > " "))
     SET message = nowindow
     SET dm_err->emsg = concat(drt_tnsdir,"/tnsnames.ora contains entries for database: ",drt_dname)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (drt_action="ADD")
    SET dm_err->eproc = concat("Verify existance of ",drt_dname," in tnsnames.ora on ",dm2_create_dom
     ->db_node_name,".")
    CALL disp_msg("",dm_err->logfile,0)
    CALL dor_init_flex_cmds(null)
    CALL dor_add_flex_cmd(dm2_create_dom->local_db,drt_user,dm2_create_dom->db_node_name," ",concat(
      "grep -i -w ",drt_dname,".\*.world ",drt_tnsdirrmt,"/tnsnames.ora | grep -vi LISTENER"),
     " ","EC")
    IF (dor_exec_flex_cmd(null)=0)
     RETURN(0)
    ENDIF
    IF ((dor_flex_cmd->cmd[1].flex_output > " "))
     SET dm_err->eproc = concat(drt_dname," TNS entry already exists.")
     CALL disp_msg("",dm_err->logfile,0)
    ELSE
     SET dm_err->eproc = "Append TNS stanzas on to target TNS file."
     CALL dor_init_flex_cmds(null)
     IF ((dm2_create_dom->local_db=0))
      CALL dor_add_flex_cmd(1," "," "," ",concat("cat ",drt_dbentry_file," | ssh oracle@",
        dm2_create_dom->db_node_name," 'cat >> ",
        drt_tnsdirrmt,"/tnsnames.ora'"),
       " ","EC")
     ELSE
      CALL dor_add_flex_cmd(1," "," "," ",concat("cat ",drt_dbentry_file," >> ",drt_tnsdir,
        "/tnsnames.ora'"),
       " ","EC")
     ENDIF
     IF (dor_exec_flex_cmd(null)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdud_check_drop_db(dcdb_check_db_dropped_only)
   SET dm_err->eproc = "Determine if database currently exists"
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE dcdd_prompt_msg = vc WITH protect, noconstant("")
   DECLARE dcdd_outfile = vc WITH protect, noconstant(" ")
   DECLARE dcdd_str = vc WITH protect, noconstant(" ")
   DECLARE dcdd_exe_fname = vc WITH protect, noconstant(" ")
   DECLARE dcdd_dbnotexists_fname = vc WITH protect, noconstant(concat(dm2_create_dom->
     local_ccluserdir,"/dm2_",dm2_create_dom->dbtype,"_",dm2_create_dom->dname,
     "_db_not_exists.dat"))
   DECLARE dcdd_source_fname = vc WITH protect, noconstant(concat(dm2_create_dom->local_ccluserdir,
     "/dcd_check_db_",dm2_create_dom->dname,"_exist.ksh"))
   SET dm_err->eproc = "Check for creation indicator."
   CALL dor_init_flex_cmds(null)
   CALL dor_add_flex_cmd(1," "," "," ",concat("test -f ",dcdd_dbnotexists_fname," ;echo $?"),
    " ","EC")
   IF (dor_exec_flex_cmd(null)=0)
    RETURN(0)
   ENDIF
   IF ((dor_flex_cmd->cmd[1].flex_output="0"))
    SET dm_err->eproc = "Verify creation indicator is not older than 1 week."
    CALL dor_init_flex_cmds(null)
    CALL dor_add_flex_cmd(1," "," "," ",concat("find ",dcdd_dbnotexists_fname," -mtime +7"),
     " ","EC")
    IF (dor_exec_flex_cmd(null)=0)
     RETURN(0)
    ENDIF
    IF ((dor_flex_cmd->cmd[1].flex_output=dcdd_dbnotexists_fname))
     SET dcdd_db_not_exists = 0
     SET dm_err->eproc = "Remove the creation indicator for restart."
     CALL dor_init_flex_cmds(null)
     CALL dor_add_flex_cmd(1," "," "," ",concat("rm -f ",dcdd_dbnotexists_fname),
      " ","EC")
     IF (dor_exec_flex_cmd(null)=0)
      RETURN(0)
     ENDIF
    ELSE
     SET dm_err->eproc = "Refresh database creation indicator."
     CALL dor_init_flex_cmds(null)
     CALL dor_add_flex_cmd(1," "," "," ",concat("touch ",dcdd_dbnotexists_fname),
      " ","EC")
     IF (dor_exec_flex_cmd(null)=0)
      RETURN(0)
     ENDIF
     SET dcdd_db_not_exists = 1
    ENDIF
   ELSE
    SET dcdd_db_not_exists = 0
   ENDIF
   CALL dcd_add_text(" ",1)
   CALL dcd_add_text("#!/bin/ksh",0)
   CALL dcd_add_text(concat("if [[ `ls -l ",dm2_create_dom->rmt_oracle_home,"/dbs/",char(42),
     dm2_create_dom->dname,
     char(42)," | wc -l` > 0 ]]"),0)
   CALL dcd_add_text("then",0)
   CALL dcd_add_text('  echo "CHECK-DBEXISTS:Database files exist in \$ORACLE_HOME/dbs" ',0)
   CALL dcd_add_text("  exit 1",0)
   CALL dcd_add_text(concat("elif [[ `grep ",dm2_create_dom->dname,
     " /etc/oratab | grep -v '#' | cut -d':' -f1 | grep -i ",dm2_create_dom->dname,
     " | wc -l` -gt 0 ]]"),0)
   CALL dcd_add_text("then",0)
   CALL dcd_add_text('  echo "CHECK-DBEXISTS:Database exists in /etc/oratab',0)
   CALL dcd_add_text("  exit 1",0)
   CALL dcd_add_text(concat("elif [[ `grep -i -w ",dm2_create_dom->dname," ",dm2_create_dom->
     rmt_oracle_home,"/network/admin/tnsnames.ora | grep -v '^#' | wc -l` -gt 0 ]]"),0)
   CALL dcd_add_text("then",0)
   CALL dcd_add_text(' echo "CHECK-DBEXISTS:TNS entries exist for database',0)
   CALL dcd_add_text("  exit 1",0)
   CALL dcd_add_text("fi",0)
   CALL dcd_add_text('echo "CHECK-NODB:CLEAR"',0)
   IF (dcd_create_text_file(dcdd_source_fname)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_create_dom->local_db=0))
    SET dcdd_exe_fname = concat(dm2_create_dom->rmt_temp_dir,"/dcd_check_db_",dm2_create_dom->dname,
     "_exist.ksh")
   ELSE
    SET dcdd_exe_fname = dcdd_source_fname
   ENDIF
   IF ((dm2_create_dom->local_db=0))
    SET dm_err->eproc = "Copy check db script to target node."
    CALL dor_init_flex_cmds(null)
    CALL dor_add_flex_cmd(dm2_create_dom->local_db,"root",dm2_create_dom->db_node_name,
     dcdd_source_fname," ",
     dcdd_exe_fname,"RCP")
    IF (dor_exec_flex_cmd(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Execute the db check script."
   CALL dor_init_flex_cmds(null)
   CALL dor_add_flex_cmd(dm2_create_dom->local_db,"root",dm2_create_dom->db_node_name," ",
    dcdd_exe_fname,
    " ","EC")
   IF (dor_exec_flex_cmd(null)=0)
    RETURN(0)
   ENDIF
   IF (substring(findstring("CHECK-",dor_flex_cmd->cmd[1].flex_output,1,1),(findstring(":",
     dor_flex_cmd->cmd[1].flex_output,1,1) - findstring("CHECK-",dor_flex_cmd->cmd[1].flex_output,1,1
     )),dor_flex_cmd->cmd[1].flex_output)="CHECK-DBEXISTS")
    SET dcdud_drop_needed = 1
    SET dcdd_prompt_msg = trim(substring((findstring(":",dor_flex_cmd->cmd[1].flex_output,1,1)+ 1),(
      size(dor_flex_cmd->cmd[1].flex_output,1) - findstring(":",dor_flex_cmd->cmd[1].flex_output,1,1)
      ),dor_flex_cmd->cmd[1].flex_output))
   ENDIF
   IF (dcdud_drop_needed=0)
    SET dm_err->eproc = "Check to see if database is registered with srvctl"
    CALL disp_msg(" ",dm_err->logfile,0)
    CALL dor_init_flex_cmds(null)
    CALL dor_add_flex_cmd(dm2_create_dom->local_db,"oracle",dm2_create_dom->db_node_name," ",concat(
      dm2_create_dom->rmt_oracle_home,"/bin/srvctl config database | grep -i -w ",dm2_create_dom->
      dname," | wc -l"),
     " ","EC")
    IF (dor_exec_flex_cmd(null)=0)
     RETURN(0)
    ENDIF
    IF ((dor_flex_cmd->cmd[1].flex_output != "0"))
     SET dcdd_prompt_msg = "Database exists in Server Control Utility (srvctl)."
     SET dcdud_drop_needed = 1
    ENDIF
   ENDIF
   IF (dcdud_drop_needed=0
    AND (dm2_create_dom->local_db=0))
    CALL dor_init_flex_cmds(null)
    CALL dor_add_flex_cmd(1," "," "," ",concat("grep -i -w ",dm2_create_dom->dname,".\*.world ",
      dm2_create_dom->oracle_home,"/network/admin/tnsnames.ora | wc -l"),
     " ","EC")
    IF (dor_exec_flex_cmd(null)=0)
     RETURN(0)
    ENDIF
    IF ((dor_flex_cmd->cmd[1].flex_output != "0"))
     SET dcdd_prompt_msg = concat(cnvtupper(dm2_create_dom->dname),
      " exists in $ORACLE_HOME/network/admin/tnsnames.ora")
     SET dcdud_drop_needed = 1
    ENDIF
   ENDIF
   IF (dcdud_drop_needed=0)
    SET dcdd_str = concat("select db_name from v\$asm_client where lower(db_name) like '%",
     dm2_create_dom->dname,"%';")
    SET dm_err->eproc = "Check if database registered in v$asm_client."
    IF (dcd_perform_query(dcdd_str,dcdd_outfile,dm2_create_dom->asm_home,dm2_create_dom->asm_sid,
     "oracle")=0)
     RETURN(0)
    ENDIF
    IF (parse_errfile(dcdd_outfile)=0)
     RETURN(0)
    ENDIF
    IF ((dm_err->errtext > " "))
     SET dcdd_prompt_msg = concat(cnvtupper(dm2_create_dom->dname),
      " database exists in V$ASM_CLIENT.")
     SET dcdud_drop_needed = 1
    ENDIF
   ENDIF
   IF (dcdud_drop_needed=1)
    SET dm_err->eproc = concat(dcdd_prompt_msg,
     "  Database components found requiring need to drop database.")
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (dcdb_check_db_dropped_only=0)
     IF (dcdd_db_not_exists=0)
      SET dm_err->err_ind = 1
      SET dm_err->emsg =
      "Database may not be removed due to creation being older than 7 days or not created by Cerner."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF ((dm2_create_dom->response_file_in_use=0))
      IF (dcd_prompt_quit(dcdd_prompt_msg)=0)
       RETURN(0)
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET dm_err->eproc = "Generate database creation indicator."
    CALL dor_init_flex_cmds(null)
    CALL dor_add_flex_cmd(1," "," "," ",concat("touch ",dcdd_dbnotexists_fname),
     " ","EC")
    IF (dor_exec_flex_cmd(null)=0)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "No existing database files found.  Continuing with installation."
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   IF (dcdb_check_db_dropped_only=0)
    SET dm_err->eproc = concat("Remove ",dm2_create_dom->dname,
     " database and/or database specific information.")
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dm_err->eproc = concat("Remove TNS stanzas related to ",dm2_create_dom->dname)
    IF (dcdud_manage_tnsentry("REMOVE",1," "," ",concat(dm2_create_dom->oracle_home,"/network/admin"),
     dm2_create_dom->dname,dm2_create_dom->rmt_temp_dir," ",dm2_create_dom->tns_host)=0)
     RETURN(0)
    ENDIF
    IF ((dm2_create_dom->local_db=0))
     SET dm_err->eproc = concat("Remove TNS stanzas related to ",dm2_create_dom->dname," on ",
      dm2_create_dom->db_node_name)
     IF (dcdud_manage_tnsentry("REMOVE",dm2_create_dom->local_db,"oracle",dm2_create_dom->
      db_node_name,concat(dm2_create_dom->rmt_oracle_home,"/network/admin"),
      dm2_create_dom->dname,dm2_create_dom->rmt_temp_dir,concat(dm2_create_dom->rmt_oracle_home,
       "/network/admin"),dm2_create_dom->tns_host)=0)
      GO TO exit_script
     ENDIF
    ENDIF
    IF (dcd_exec_shutdown_script(null)=0)
     RETURN(0)
    ENDIF
    CALL dor_init_flex_cmds(null)
    CALL dor_add_flex_cmd(dm2_create_dom->local_db,"oracle",dm2_create_dom->db_node_name,concat('"',
      dm2_create_dom->rmt_temp_dir,"/delete_",dm2_create_dom->dname,'_database.ksh"')," ",
     " ","EFO")
    IF (dor_exec_flex_cmd(null)=0)
     RETURN(0)
    ENDIF
    IF ((dor_flex_cmd->cmd[1].flex_output > " ")
     AND findstring("CER-00000",dor_flex_cmd->cmd[1].flex_output,1,0) > 0)
     SET dm_err->emsg = concat(substring(findstring("CER-00000",cnvtupper(dor_flex_cmd->cmd[1].
         flex_output),1,1),(size(dor_flex_cmd->cmd[1].flex_output) - findstring("CER-00000",cnvtupper
        (dor_flex_cmd->cmd[1].flex_output),1,1)),dor_flex_cmd->cmd[1].flex_output),".")
     SET message = nowindow
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat(
     "Database was not cleaned successfully. Database related information still exists for ",
     dm2_create_dom->dname,".")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdud_transform_templates(null)
   DECLARE dtt_cnt = i4 WITH protect, noconstant(0)
   IF (validate(dm2_bypass_transform_template,- (1))=1)
    SET dm_err->eproc = "Bypassing template files - external flag set"
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Move template files into database specific files."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dcd_templates->temp_cnt = 3
   SET stat = alterlist(dcd_templates->qual,dcd_templates->temp_cnt)
   SET dcd_templates->qual[1].temp_name = "dm2_ni_dbca_tokens.txt"
   SET dcd_templates->qual[1].action_type = "CF"
   SET dcd_templates->qual[1].outfile_name = concat(dm2_create_dom->dname,"_database_tokens.ksh")
   SET dcd_templates->qual[2].temp_name = "dm2_ni_dbca_delete_database.txt"
   SET dcd_templates->qual[2].action_type = "CF"
   SET dcd_templates->qual[2].outfile_name = concat("delete_",dm2_create_dom->dname,"_database.ksh")
   SET dcd_templates->qual[3].temp_name = "dm2_ni_dbca_restore_database.txt"
   SET dcd_templates->qual[3].action_type = "CF"
   SET dcd_templates->qual[3].outfile_name = concat("restore_",dm2_create_dom->dname,"_database.ksh")
   CALL drr_reset_search_rep_rec(null)
   CALL dcd_load_sr_rec(null)
   FOR (dtt_cnt = 1 TO size(dcd_templates->qual,5))
     CALL drr_reset_cmd_rec(null)
     SET drr_cmd_rec->src_filename = dcd_templates->qual[dtt_cnt].temp_name
     SET drr_cmd_rec->action_type = dcd_templates->qual[dtt_cnt].action_type
     SET drr_cmd_rec->tgt_filename = dcd_templates->qual[dtt_cnt].outfile_name
     IF (drr_load_cmds_from_file(drr_cmd_rec->src_filename)=0)
      RETURN(0)
     ENDIF
     IF (drr_search_replace(null)=0)
      RETURN(0)
     ENDIF
     IF (drr_perform_cmd_action(null)=0)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = "Copy database restore script to target node."
     CALL dor_init_flex_cmds(null)
     CALL dor_add_flex_cmd(dm2_create_dom->local_db,"oracle",dm2_create_dom->db_node_name,concat(
       dm2_create_dom->local_ccluserdir,"/",dcd_templates->qual[dtt_cnt].outfile_name)," ",
      concat(dm2_create_dom->rmt_temp_dir,"/",dcd_templates->qual[dtt_cnt].outfile_name),"RCP")
     CALL dor_add_flex_cmd(dm2_create_dom->local_db,"root",dm2_create_dom->db_node_name," ",concat(
       "chown -R oracle:dba ",dm2_create_dom->rmt_temp_dir,"/",dcd_templates->qual[dtt_cnt].
       outfile_name),
      " ","EC")
     IF (dor_exec_flex_cmd(null)=0)
      GO TO exit_script
     ENDIF
     IF ((dm2_create_dom->local_db=1))
      IF (dor_flex_chmod_file(concat(dm2_create_dom->rmt_temp_dir,"/",dcd_templates->qual[dtt_cnt].
        outfile_name)," ")=0)
       RETURN(0)
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdud_disp_prereq_screen(null)
   DECLARE ddps_row = i2 WITH protect, noconstant(0)
   SET ddps_row = 5
   CALL clear(1,1)
   CALL text(2,2,"CERNER MILLENNIUM - CREATE A DATABASE",w)
   CALL box(3,2,24,132)
   CALL text(4,5,concat("ENTER DATABASE NODE OPERATING SYSTEM:",dm2_create_dom->rmt_os))
   CALL text(ddps_row,5,concat("SELECT DATABASE TYPE:",dm2_create_dom->dbtype))
   SET ddps_row = (ddps_row+ 1)
   CALL text(ddps_row,5,concat("ENTER PRIMARY DATABASE NODE NAME:",dm2_create_dom->db_node_name))
   SET ddps_row = (ddps_row+ 1)
   CALL text(ddps_row,5,concat("ENTER TNS HOST NAME:",dm2_create_dom->tns_host))
   SET ddps_row = (ddps_row+ 1)
   CALL text(ddps_row,5,concat("ENTER TNS PORT:",dm2_create_dom->clinical_port))
   SET ddps_row = (ddps_row+ 1)
   CALL text(ddps_row,5,concat("ENTER DATABASE NAME: ",dm2_create_dom->dname))
   SET ddps_row = (ddps_row+ 1)
   CALL text(ddps_row,5,concat("ENTER DATABASE SYS USER PASSWORD:",dm2_create_dom->oracle_sys_pass))
   SET ddps_row = (ddps_row+ 1)
   CALL text(ddps_row,5,concat("ENTER DATABASE SYSTEM USER PASSWORD:",dm2_create_dom->
     oracle_system_pass))
   SET ddps_row = (ddps_row+ 1)
   CALL text(ddps_row,5,concat("ENTER ASM SYSDBA PASSWORD:",dm2_create_dom->asm_sysdba_pass))
   SET ddps_row = (ddps_row+ 1)
   CALL text(ddps_row,5,"ENTER THE DATABASE NODE ORACLE HOME:")
   SET ddps_row = (ddps_row+ 1)
   CALL text(ddps_row,5,dm2_create_dom->rmt_oracle_home)
   SET ddps_row = (ddps_row+ 1)
   CALL text(ddps_row,5,"ENTER THE DATABASE NODE ASM HOME:")
   SET ddps_row = (ddps_row+ 1)
   CALL text(ddps_row,5,dm2_create_dom->asm_home)
   SET ddps_row = (ddps_row+ 1)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdud_gather_prereqs(null)
   DECLARE dgp_row = i2 WITH protect, noconstant(5)
   DECLARE dgp_db_name_done = i2 WITH protect, noconstant(0)
   DECLARE dgp_valid_dir = i2 WITH protect, noconstant(0)
   DECLARE dgp_check_name = vc WITH protect, noconstant(" ")
   DECLARE dgp_ndx = i4 WITH protect, noconstant(0)
   DECLARE dgp_str = vc WITH protect, noconstant("")
   SET width = 132
   IF ((dm_err->debug_flag != 722))
    SET message = window
   ENDIF
   CALL clear(1,1)
   CALL text(2,2,"CERNER MILLENNIUM - CREATE A DATABASE",w)
   CALL box(3,2,24,132)
   SET help = fix("AIX,HPX,LNX")
   CALL text(4,5,"ENTER DATABASE NODE OPERATING SYSTEM:")
   CALL accept(4,44,"P(3);cu")
   IF ( NOT (curaccept IN ("AIX", "HPX", "LNX")))
    SET message = nowindow
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating selected database operating system."
    SET dm_err->emsg = concat("Selected operation system is not valid: ",curaccept,".")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm2_create_dom->rmt_os = cnvtupper(curaccept)
   SET help = off
   SET help = fix("STRT,ADMIN")
   CALL text(dgp_row,5,"SELECT DATABASE TYPE:")
   CALL accept(dgp_row,36,"P(15);cuF")
   IF ( NOT (curaccept IN ("STRT", "ADMIN")))
    SET message = nowindow
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating selected database type."
    SET dm_err->emsg = "Valid database types are STRT and ADMIN."
    SET dm_err->user_action = "Please select valid database type."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET help = off
   SET dm2_create_dom->dbtype = cnvtlower(curaccept)
   SET dgp_row = (dgp_row+ 1)
   CALL text(dgp_row,5,"ENTER PRIMARY DATABASE NODE NAME:")
   CALL accept(dgp_row,41,"P(30);c"," "
    WHERE curaccept > " ")
   SET dm2_create_dom->db_node_name = cnvtlower(curaccept)
   IF (cnvtlower(curnode) != cnvtlower(dm2_create_dom->db_node_name))
    SET dm2_create_dom->local_db = 0
    CALL dor_init_flex_cmds(null)
    CALL dor_add_flex_cmd(dm2_create_dom->local_db,"root",dm2_create_dom->db_node_name," ","hostname",
     " ","EC")
    IF (dor_exec_flex_cmd(null)=0)
     RETURN(0)
    ENDIF
    SET dm2_create_dom->rmt_temp_dir = "/tmp"
    IF (findstring(".",dor_flex_cmd->cmd[1].flex_output,1,0) > 0)
     SET dgp_check_name = cnvtlower(substring(1,(findstring(".",dor_flex_cmd->cmd[1].flex_output,1,0)
        - 1),dor_flex_cmd->cmd[1].flex_output))
    ELSE
     SET dgp_check_name = cnvtlower(dor_flex_cmd->cmd[1].flex_output)
    ENDIF
    IF ((dgp_check_name != dm2_create_dom->db_node_name))
     SET message = nowindow
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validate communication with remote node"
     SET dm_err->emsg = "Unable to communicate with remote node via SSH or hostname is not valid."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ELSE
    SET dm2_create_dom->rmt_temp_dir = "/tmp"
    SET dm2_create_dom->local_db = 1
   ENDIF
   SET dgp_row = (dgp_row+ 1)
   CALL text(dgp_row,5,"ENTER TNS HOST NAME:")
   CALL accept(dgp_row,41,"P(30);c"," "
    WHERE curaccept > " ")
   SET dm2_create_dom->tns_host = cnvtlower(curaccept)
   IF ((dm2_create_dom->local_db=0))
    IF (dm2_ping(dm2_create_dom->tns_host)=0)
     SET message = nowindow
     SET dm_err->eproc = concat("Validate connectivity to TNS host:",dm2_create_dom->tns_host)
     CALL disp_msg(dm_err->eproc,dm_err->emsg,1)
     RETURN(0)
    ENDIF
   ENDIF
   SET dgp_row = (dgp_row+ 1)
   CALL text(dgp_row,5,"ENTER TNS PORT:")
   CALL accept(dgp_row,41,"P(5);c",dm2_create_dom->clinical_port
    WHERE isnumeric(curaccept) > 0)
   SET dm2_create_dom->clinical_port = cnvtlower(curaccept)
   IF (dcd_load_sids(dm2_create_dom->dbtype)=0)
    RETURN(0)
   ENDIF
   SET dgp_row = (dgp_row+ 1)
   WHILE ( NOT (dgp_db_name_done))
     CALL clear(dgp_row,3,131)
     CALL clear((dgp_row+ 1),3,131)
     CALL clear((dgp_row+ 2),3,131)
     CALL text(2,2,"CERNER MILLENNIUM - CREATE A DATABASE",w)
     CALL box(3,2,24,132)
     CALL text(dgp_row,5,"ENTER DATABASE NAME: ")
     CALL accept(dgp_row,36,"XXXXX;C")
     SET dm2_create_dom->dname = cnvtlower(curaccept)
     SET dgp_db_name_done = 1
     IF ((dm2_create_dom->dname IN ("open")))
      CALL text((dgp_row+ 1),5,concat("Oracle will NOT allow database name ",dm2_create_dom->dname,
        ". Please enter another database name."))
      CALL text((dgp_row+ 2),5,
       "Please enter Q to quit or C to continue entering another database name.")
      CALL accept((dgp_row+ 2),80,"P;CU","C"
       WHERE curaccept IN ("Q", "C"))
      IF (curaccept="Q")
       SET dm_err->err_ind = 1
       SET dm_err->emsg = concat("User chose to quit when prompted to enter database name.")
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ELSE
       SET dgp_db_name_done = 0
      ENDIF
     ENDIF
   ENDWHILE
   SET dgp_row = (dgp_row+ 1)
   CALL text(dgp_row,5,"ENTER DATABASE SYS USER PASSWORD:")
   CALL accept(dgp_row,41,"P(30);c"," "
    WHERE curaccept > " ")
   SET dm2_create_dom->oracle_sys_pass = curaccept
   SET dgp_row = (dgp_row+ 1)
   CALL text(dgp_row,5,"ENTER DATABASE SYSTEM USER PASSWORD:")
   CALL accept(dgp_row,44,"P(30);c"," "
    WHERE curaccept > " ")
   SET dm2_create_dom->oracle_system_pass = curaccept
   SET dgp_row = (dgp_row+ 1)
   CALL text(dgp_row,5,"ENTER ASM SYSDBA PASSWORD:")
   CALL accept(dgp_row,34,"P(30);c"," "
    WHERE curaccept > " ")
   SET dm2_create_dom->asm_sysdba_pass = curaccept
   SET dgp_row = (dgp_row+ 1)
   WHILE (dgp_valid_dir=0)
     CALL clear(dgp_row,3,131)
     CALL clear((dgp_row+ 1),3,131)
     CALL clear((dgp_row+ 2),3,131)
     CALL clear((dgp_row+ 3),3,131)
     IF (trim(logical("oracle_home")) > " ")
      SET dm2_create_dom->rmt_oracle_home = trim(logical("oracle_home"))
     ELSE
      SET dm2_create_dom->rmt_oracle_home = " "
     ENDIF
     CALL text(dgp_row,5,"ENTER THE DATABASE NODE ORACLE HOME (/u01/oracle/product/11.1.0.7/db):")
     CALL accept((dgp_row+ 1),5,"P(90);C",dm2_create_dom->rmt_oracle_home
      WHERE  NOT (curaccept="")
       AND substring(1,1,curaccept)="/"
       AND findstring("/",trim(curaccept),1,1) != size(trim(curaccept)))
     SET dm2_create_dom->rmt_oracle_home = curaccept
     CALL dor_init_flex_cmds(null)
     CALL dor_add_flex_cmd(dm2_create_dom->local_db,"root",dm2_create_dom->db_node_name," ",concat(
       "test -d ",dm2_create_dom->rmt_oracle_home," ;echo $?"),
      " ","EC")
     IF (dor_exec_flex_cmd(null)=0)
      RETURN(0)
     ENDIF
     IF ((dor_flex_cmd->cmd[1].flex_output IN ("", "1")))
      CALL text((dgp_row+ 2),3,"PLEASE ENTER A VALID ORACLE HOME WHICH EXISTS ON DATABASE NODE.")
      CALL text((dgp_row+ 3),5,
       "Please enter Q to quit or C to continue entering oracle home directory.")
      CALL accept((dgp_row+ 2),80,"P;CU","C"
       WHERE curaccept IN ("Q", "C"))
      IF (curaccept="Q")
       SET message = nowindow
       SET dm_err->err_ind = 1
       SET dm_err->emsg = concat("User chose to quit when prompted to enter oracle home.")
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ELSE
      SET dgp_valid_dir = 1
     ENDIF
     IF ((dm2_create_dom->local_db=1))
      SET dm2_create_dom->oracle_home = dm2_create_dom->rmt_oracle_home
     ENDIF
   ENDWHILE
   IF (findstring("11.1",dm2_create_dom->rmt_oracle_home,1,0) > 0)
    SET dm2_create_dom->db_ora_ver = "11.1"
   ELSE
    SET dm2_create_dom->db_ora_ver = "11.2"
   ENDIF
   IF ((dm2_create_dom->db_ora_ver="11.1"))
    SET dm2_create_dom->dbca_template_name = build("dm2_ni_dbca_seeded_template_",dm2_create_dom->
     dbtype,"_111.dbc")
   ELSE
    SET dm2_create_dom->dbca_template_name = build("dm2_ni_dbca_seeded_template_",dm2_create_dom->
     dbtype,"_112.dbc")
   ENDIF
   IF (dcdud_override_template_name != "dm2_not_set")
    IF (dcdud_override_template_name != "dm2_ni_dbca_seeded_template*.dbc")
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validating template name override."
     SET dm_err->emsg = "Invalid template name override entered."
     SET dm_err->user_action = "Template name must match dm2_ni_dbca_seeded_template*.dbc."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET dm2_create_dom->dbca_template_name = dcdud_override_template_name
   ENDIF
   IF (dcd_get_asm_data(null)=0)
    RETURN(0)
   ENDIF
   IF (dcd_gather_available_disk_groups(null)=0)
    RETURN(0)
   ENDIF
   IF (dcdud_disp_prereq_screen(null)=0)
    RETURN(0)
   ENDIF
   SET dgp_row = (dgp_row+ 2)
   SET help = fix(value(dcd_disk_groups->dg_list))
   CALL text(dgp_row,5,concat("ENTER DISK GROUP NAME FOR STORAGE (i.e. ",cnvtupper(dm2_create_dom->
      dname),"_DG1):"))
   CALL accept(dgp_row,60,"P(20);cuF")
   IF (locateval(dgp_ndx,1,dcd_disk_groups->dg_cnt,curaccept,dcd_disk_groups->qual[dgp_ndx].dg_name)=
   0)
    SET message = nowindow
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating disk group for storage"
    SET dm_err->emsg = concat("Selected disk group is not valid: ",curaccept,".")
    SET dm_err->user_action = concat("Valid disk groups are ",dcd_disk_groups->dg_list)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm2_create_dom->asm_storage_dg = curaccept
   SET help = off
   SET dgp_row = (dgp_row+ 1)
   SET help = fix(value(dcd_disk_groups->dg_list))
   CALL text(dgp_row,5,concat("ENTER DISK GROUP NAME FOR RECOVERY (i.e. ",cnvtupper(dm2_create_dom->
      dname),"_DG_FLASH):"))
   CALL accept(dgp_row,63,"P(20);cuF")
   IF (locateval(dgp_ndx,1,dcd_disk_groups->dg_cnt,curaccept,dcd_disk_groups->qual[dgp_ndx].dg_name)=
   0)
    SET message = nowindow
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating disk group for recovery"
    SET dm_err->emsg = concat("Selected disk group is not valid: ",curaccept,".")
    SET dm_err->user_action = concat("Valid disk groups are ",dcd_disk_groups->dg_list)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm2_create_dom->asm_recovery_dg = curaccept
   SET help = off
   SET dgp_row = (dgp_row+ 1)
   CALL text(dgp_row,5,concat("ENTER VALUE FOR LOG_ARCHIVE_DEST_1:"))
   WHILE (dcdud_continue=1)
    CALL accept(dgp_row,42,"P(80);cu",concat('LOCATION="+',dm2_create_dom->asm_recovery_dg,"/",
      cnvtupper(dm2_create_dom->dname),'"'))
    IF (curaccept=patstring("LOCATION=*"))
     CALL clear((dgp_row+ 1),3,131)
     SET dm2_create_dom->log_archive_dest_1 = curaccept
     SET dcdud_continue = 0
    ELSE
     CALL text((dgp_row+ 1),5,"***Value for LOG_ARCHIVE_DEST_1 must begin with 'LOCATION='. ")
    ENDIF
   ENDWHILE
   IF ((dm2_create_dom->dbtype="admin"))
    SET dm2_install_schema->cdba_p_word = "CDBA"
    SET dm2_install_schema->cdba_connect_str = cnvtupper(dcdud_admin_cstr)
    SET dm2_install_schema->target_dbase_name = cnvtupper(dcdud_admin_dbname)
    SET dm2_create_dom->admin_port = dm2_create_dom->clinical_port
   ENDIF
   SET dgp_row = (dgp_row+ 2)
   CALL text(dgp_row,5,"Enter 'C' to Continue or 'Q' to Quit:")
   CALL accept(dgp_row,52,"P;CU","C"
    WHERE curaccept IN ("Q", "C"))
   IF (curaccept="Q")
    SET message = nowindow
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Obtain user confirmation to continue."
    SET dm_err->emsg = concat("User chose to quit from Create a Database Screen.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   CALL clear(1,1)
   SET message = nowindow
   IF ((dm2_create_dom->dbtype != "admin"))
    SET dm2_install_schema->cdba_connect_str = dcdud_admin_cstr
    SET dm2_install_schema->u_name = "CDBA"
    SET dm2_install_schema->p_word = dcdud_override_admin_db_pass
    SET dm2_install_schema->connect_str = dm2_install_schema->cdba_connect_str
    SET dm2_install_schema->dbase_name = cnvtupper(dcdud_admin_dbname)
    EXECUTE dm2_connect_to_dbase "CO"
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    EXECUTE dm2_connect_to_dbase "DO"
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    SET dm2_install_schema->dbase_name = dm2_create_dom->dname
    IF ((dm_err->debug_flag > 0))
     CALL echo(concat("dbase_name=",dm2_install_schema->dbase_name))
    ENDIF
   ENDIF
   IF ((dm2_create_dom->local_db=0))
    SET dm2_create_dom->oracle_home = logical("ORACLE_HOME")
    IF (trim(dm2_create_dom->oracle_home)="")
     SET message = nowindow
     SET dm_err->eproc = "Checking the definition of oracle_home."
     SET dm_err->emsg = "The ORACLE_HOME logical is not defined."
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Verifying that Cerner code warehouse has been installed."
   CALL dor_init_flex_cmds(null)
   CALL dor_add_flex_cmd(1," "," "," ",concat("test -d /cerner/w_standard/",dm2_create_dom->dbtype,
     " ;echo $?"),
    " ","EC")
   IF (dor_exec_flex_cmd(null)=0)
    RETURN(0)
   ENDIF
   IF ((dor_flex_cmd->cmd[1].flex_output IN ("", "1")))
    SET message = nowindow
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Warehouse dir /cerner/w_standard/",dm2_create_dom->dbtype,
     " not found. Cannot continue with database creation.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Verify /u02/oracle/admin directory exists"
   CALL dor_init_flex_cmds(null)
   CALL dor_add_flex_cmd(dm2_create_dom->local_db,"root",dm2_create_dom->db_node_name," ",concat(
     "test -d /u02/oracle/admin ;echo $?"),
    " ","EC")
   IF (dor_exec_flex_cmd(null)=0)
    RETURN(0)
   ENDIF
   IF ((dor_flex_cmd->cmd[1].flex_output IN ("", "1")))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "/u02/oracle/admin must exist for database creation to succeed"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dcd_get_ora_ver(null)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm2_create_dom)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdud_updatetns(null)
   DECLARE du_exe_fname = vc WITH protect, noconstant(" ")
   DECLARE du_source_fname = vc WITH protect, noconstant(" ")
   SET dm_err->eproc = "Verifying that tnsnames.ora exists on remote node."
   CALL dor_init_flex_cmds(null)
   CALL dor_add_flex_cmd(dm2_create_dom->local_db,"oracle",dm2_create_dom->db_node_name," ",concat(
     "test -f ",concat(dm2_create_dom->rmt_oracle_home,"/network/admin/tnsnames.ora")," ;echo $?"),
    " ","EC")
   IF (dor_exec_flex_cmd(null)=0)
    RETURN(0)
   ENDIF
   IF ((dor_flex_cmd->cmd[1].flex_output="0"))
    SET dm_err->eproc = concat("Remove TNS stanzas related to ",dm2_create_dom->dname)
    IF (dcdud_manage_tnsentry("REMOVE",dm2_create_dom->local_db,"oracle",dm2_create_dom->db_node_name,
     concat(dm2_create_dom->rmt_oracle_home,"/network/admin"),
     dm2_create_dom->dname,dm2_create_dom->rmt_temp_dir,concat(dm2_create_dom->rmt_oracle_home,
      "/network/admin"),dm2_create_dom->tns_host)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm2_create_dom->local_db=0))
    SET du_source_fname = concat(dm2_create_dom->local_ccluserdir,"/dm2_updatetns_rmt.ksh")
    IF (validate(dm2_bypass_updatetns_file_create,- (1))=1)
     SET dm_err->eproc = "Bypassing creation of dm2_updatetns_rmt.ksh - external flag set"
     CALL disp_msg(" ",dm_err->logfile,0)
    ELSE
     IF (dm2_findfile(du_source_fname))
      IF (dm2_push_dcl(concat("rm ",du_source_fname))=0)
       RETURN(0)
      ENDIF
     ENDIF
     SET dm_err->eproc = concat("Creating remote ",du_source_fname)
     CALL disp_msg(" ",dm_err->logfile,0)
     CALL dcd_add_text(" ",1)
     CALL dcd_add_text("#!/bin/ksh",0)
     CALL dcd_add_text('FoundCur="N"',0)
     CALL dcd_add_text("NODENAME=`hostname`",0)
     CALL dcd_add_text(concat('Dname="',dm2_create_dom->dname,'"'),0)
     CALL dcd_add_text(concat('Alias="',dm2_create_dom->dname,'1"'),0)
     CALL dcd_add_text(concat('Node="',dm2_create_dom->tns_host,'"'),0)
     CALL dcd_add_text(concat('Port="',dm2_create_dom->clinical_port,'"'),0)
     CALL dcd_add_text(concat('OHome="',dm2_create_dom->rmt_oracle_home,'"'),0)
     CALL dcd_add_text("if [[ -z $ORACLE_HOME ]]",0)
     CALL dcd_add_text("then",0)
     CALL dcd_add_text("  ORACLE_HOME=$OHome",0)
     CALL dcd_add_text("fi",0)
     CALL dcd_add_text("TNS_ADMIN=$ORACLE_HOME/network/admin",0)
     CALL dcd_add_text("NTF=$TNS_ADMIN/tnsnames.ora",0)
     CALL dcd_add_text("if [[ ! -d $TNS_ADMIN ]]",0)
     CALL dcd_add_text("then",0)
     CALL dcd_add_text(concat('  echo "CER-00000: error - ", $TNS_ADMIN ,"is not a directory."'),0)
     CALL dcd_add_text("  exit 1",0)
     CALL dcd_add_text("fi",0)
     CALL dcd_add_text("if [[ ! -w $TNS_ADMIN ]]",0)
     CALL dcd_add_text("then",0)
     CALL dcd_add_text(concat('  echo "CER-00000: error - No write permission to ", $TNS_ADMIN'),0)
     CALL dcd_add_text("    exit 1",0)
     CALL dcd_add_text("fi",0)
     CALL dcd_add_text("if [[ -a $NTF ]]",0)
     CALL dcd_add_text("then",0)
     CALL dcd_add_text(
      '  for CurAlias in `grep -i ".world" $NTF|grep -vi "tcp.world"|grep -vi "listener"|cut -f1 -d"."`',
      0)
     CALL dcd_add_text("  do",0)
     CALL dcd_add_text("    TempCurAlias=`echo $CurAlias | tr '[:upper:]' '[:lower:]'`",0)
     CALL dcd_add_text("    TempAlias=`echo $Alias | tr '[:upper:]' '[:lower:]'`",0)
     CALL dcd_add_text("    if [[ $TempCurAlias = $TempAlias ]]",0)
     CALL dcd_add_text("    then",0)
     CALL dcd_add_text('      FoundCur="Y"',0)
     CALL dcd_add_text("    fi",0)
     CALL dcd_add_text("  done",0)
     CALL dcd_add_text("fi",0)
     CALL dcd_add_text("#Don't try to read it to tnsnames.ora if it already exists",0)
     CALL dcd_add_text('if [[ $FoundCur = "N" ]]',0)
     CALL dcd_add_text("then",0)
     CALL dcd_add_text("  if [[ ! -a $NTF ]]",0)
     CALL dcd_add_text("  then",0)
     CALL dcd_add_text('    echo "################"                      >> $NTF',0)
     CALL dcd_add_text('    echo "# Filename......: tnsnames.ora"        >> $NTF',0)
     CALL dcd_add_text('    echo "# Node..........: ${NODENAME}.world"   >> $NTF',0)
     CALL dcd_add_text('    echo "# Date..........: `date`"              >> $NTF',0)
     CALL dcd_add_text('    echo "################"                      >> $NTF',0)
     CALL dcd_add_text("  else",0)
     CALL dcd_add_text("    LastNTF=`ls $NTF.[0-9]* 2>/dev/null | tail -1`",0)
     CALL dcd_add_text("    LastNTF=`echo ${LastNTF##*/}`",0)
     CALL dcd_add_text("    if [[ -z $LastNTF ]]",0)
     CALL dcd_add_text("    then",0)
     CALL dcd_add_text("      cp -p $NTF $NTF.0001",0)
     CALL dcd_add_text("    else",0)
     CALL dcd_add_text('      Nam=`echo $LastNTF | cut -f1 -d"."`',0)
     CALL dcd_add_text('      Ext=`echo $LastNTF | cut -f2 -d"."`',0)
     CALL dcd_add_text('      Cnt=`echo $LastNTF | cut -f3 -d"."`',0)
     CALL dcd_add_text("      ((CntNew=Cnt+1))",0)
     CALL dcd_add_text("      while [[ ${#CntNew} -lt 4 ]]",0)
     CALL dcd_add_text("      do",0)
     CALL dcd_add_text("        CntNew=0$CntNew",0)
     CALL dcd_add_text("      done",0)
     CALL dcd_add_text("      cp  -p $NTF $TNS_ADMIN/$Nam.$Ext.$CntNew",0)
     CALL dcd_add_text("    fi",0)
     CALL dcd_add_text("  fi",0)
     CALL dcd_add_text('  echo "${Alias}.world ="                               >>$NTF',0)
     CALL dcd_add_text('  echo " (DESCRIPTION ="                                >>$NTF',0)
     CALL dcd_add_text('  echo "    (ENABLE=BROKEN)"                            >>$NTF',0)
     CALL dcd_add_text('  echo "    (ADDRESS=(PROTOCOL=TCP)"                    >>$NTF',0)
     CALL dcd_add_text('  echo "    (HOST=${Node})(PORT=${Port}))"              >>$NTF',0)
     CALL dcd_add_text('  echo "  (CONNECT_DATA="                               >>$NTF',0)
     CALL dcd_add_text('  echo "     (SERVER=DEDICATED)"                        >>$NTF',0)
     CALL dcd_add_text('  echo "     (SERVICE_NAME=${Dname}.world)"             >>$NTF',0)
     CALL dcd_add_text('  echo "     (INSTANCE_NAME=${Alias}))"                 >>$NTF',0)
     CALL dcd_add_text('  echo " )"                                             >>$NTF',0)
     CALL dcd_add_text('fi #$FoundCur = "N"',0)
     CALL dcd_add_text("  chown oracle:dba $NTF*",0)
     CALL dcd_add_text("chmod 644 $NTF",0)
     IF (dcd_create_text_file(du_source_fname)=0)
      RETURN(0)
     ENDIF
    ENDIF
    SET dm_err->eproc = concat("Copy ",du_source_fname," script to target node.")
    CALL disp_msg(" ",dm_err->logfile,0)
    SET du_exe_fname = concat(dm2_create_dom->rmt_temp_dir,"/dm2_updatetns_rmt.ksh")
    CALL dor_init_flex_cmds(null)
    CALL dor_add_flex_cmd(dm2_create_dom->local_db,"root",dm2_create_dom->db_node_name,
     du_source_fname," ",
     du_exe_fname,"RCP")
    IF (dor_exec_flex_cmd(null)=0)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Execute remote dm2_updatetns_rmt script."
    CALL disp_msg(" ",dm_err->logfile,0)
    CALL dor_init_flex_cmds(null)
    CALL dor_add_flex_cmd(dm2_create_dom->local_db,"root",dm2_create_dom->db_node_name,du_exe_fname,
     " ",
     " ","EFRO")
    IF (dor_exec_flex_cmd(null)=0)
     RETURN(0)
    ENDIF
    IF ((dor_flex_cmd->cmd[1].flex_output > " "))
     IF (findstring("CER-00000",cnvtupper(dm_err->errtext),1,0) > 0)
      SET dm_err->emsg = concat(substring(findstring("CER-00000",cnvtupper(dor_flex_cmd->cmd[1].
          flex_output),1,1),(size(dor_flex_cmd->cmd[1].flex_output) - findstring("CER-00000",
         cnvtupper(dor_flex_cmd->cmd[1].flex_output),1,1)),dor_flex_cmd->cmd[1].flex_output),".")
      SET message = nowindow
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   SET du_source_fname = concat(dm2_create_dom->local_ccluserdir,"/dm2_updatetns.ksh")
   IF (validate(dm2_bypass_updatetns_file_create,- (1))=1)
    SET dm_err->eproc = "Bypassing creation of dm2_updatetns.ksh - external flag set"
    CALL disp_msg(" ",dm_err->logfile,0)
   ELSE
    IF (dm2_findfile(du_source_fname))
     IF (dm2_push_dcl(concat("rm ",du_source_fname))=0)
      RETURN(0)
     ENDIF
    ENDIF
    SET dm_err->eproc = "Creating dm2_updatetns.ksh."
    CALL disp_msg(" ",dm_err->logfile,0)
    CALL dcd_add_text(" ",1)
    CALL dcd_add_text("#!/bin/ksh",0)
    CALL dcd_add_text('FoundCur="N"',0)
    CALL dcd_add_text("NODENAME=`hostname`",0)
    CALL dcd_add_text(concat('Dname="',dm2_create_dom->dname,'"'),0)
    CALL dcd_add_text(concat('Alias="',dm2_create_dom->dname,'1"'),0)
    CALL dcd_add_text(concat('Node="',dm2_create_dom->tns_host,'"'),0)
    CALL dcd_add_text(concat('Port="',dm2_create_dom->clinical_port,'"'),0)
    CALL dcd_add_text(concat('OHome="',dm2_create_dom->oracle_home,'"'),0)
    CALL dcd_add_text("if [[ -z $ORACLE_HOME ]]",0)
    CALL dcd_add_text("then",0)
    CALL dcd_add_text("  ORACLE_HOME=$OHome",0)
    CALL dcd_add_text("fi",0)
    CALL dcd_add_text("TNS_ADMIN=$ORACLE_HOME/network/admin",0)
    CALL dcd_add_text("NTF=$TNS_ADMIN/tnsnames.ora",0)
    CALL dcd_add_text("if [[ ! -d $TNS_ADMIN ]]",0)
    CALL dcd_add_text("then",0)
    CALL dcd_add_text(concat('  echo "CER-00000: error - ", $TNS_ADMIN," is not a directory."'),0)
    CALL dcd_add_text("    exit 1",0)
    CALL dcd_add_text("fi",0)
    CALL dcd_add_text("if [[ ! -w $TNS_ADMIN ]]",0)
    CALL dcd_add_text("then",0)
    CALL dcd_add_text(concat('  echo "CER-00000: error - No write permission to ", $TNS_ADMIN'),0)
    CALL dcd_add_text("    exit 1",0)
    CALL dcd_add_text("fi",0)
    CALL dcd_add_text("if [[ -a $NTF ]]",0)
    CALL dcd_add_text("then",0)
    CALL dcd_add_text(
     '  for CurAlias in `grep -i ".world" $NTF|grep -vi "tcp.world"|grep -vi "listener"|cut -f1 -d"."`',
     0)
    CALL dcd_add_text("  do",0)
    CALL dcd_add_text("    TempCurAlias=`echo $CurAlias | tr '[:upper:]' '[:lower:]'`",0)
    CALL dcd_add_text("    TempAlias=`echo $Alias | tr '[:upper:]' '[:lower:]'`",0)
    CALL dcd_add_text("    if [[ $TempCurAlias = $TempAlias ]]",0)
    CALL dcd_add_text("    then",0)
    CALL dcd_add_text('      FoundCur="Y"',0)
    CALL dcd_add_text("    fi",0)
    CALL dcd_add_text("  done",0)
    CALL dcd_add_text("fi",0)
    CALL dcd_add_text("#Don't try to read it to tnsnames.ora if it already exists",0)
    CALL dcd_add_text('if [[ $FoundCur = "N" ]]',0)
    CALL dcd_add_text("then",0)
    CALL dcd_add_text("  if [[ ! -a $NTF ]]",0)
    CALL dcd_add_text("  then",0)
    CALL dcd_add_text('    echo "################"                      >> $NTF',0)
    CALL dcd_add_text('    echo "# Filename......: tnsnames.ora"        >> $NTF',0)
    CALL dcd_add_text('    echo "# Node..........: ${NODENAME}.world"   >> $NTF',0)
    CALL dcd_add_text('    echo "# Date..........: `date`"              >> $NTF',0)
    CALL dcd_add_text('    echo "################"                      >> $NTF',0)
    CALL dcd_add_text("  else",0)
    CALL dcd_add_text("    LastNTF=`ls $NTF.[0-9]* 2>/dev/null | tail -1`",0)
    CALL dcd_add_text("    LastNTF=`echo ${LastNTF##*/}`",0)
    CALL dcd_add_text("    if [[ -z $LastNTF ]]",0)
    CALL dcd_add_text("    then",0)
    CALL dcd_add_text("      cp -p $NTF $NTF.0001",0)
    CALL dcd_add_text("    else",0)
    CALL dcd_add_text('      Nam=`echo $LastNTF | cut -f1 -d"."`',0)
    CALL dcd_add_text('      Ext=`echo $LastNTF | cut -f2 -d"."`',0)
    CALL dcd_add_text('      Cnt=`echo $LastNTF | cut -f3 -d"."`',0)
    CALL dcd_add_text("      ((CntNew=Cnt+1))",0)
    CALL dcd_add_text("      while [[ ${#CntNew} -lt 4 ]]",0)
    CALL dcd_add_text("      do",0)
    CALL dcd_add_text("        CntNew=0$CntNew",0)
    CALL dcd_add_text("      done",0)
    CALL dcd_add_text("      cp -p $NTF $TNS_ADMIN/$Nam.$Ext.$CntNew",0)
    CALL dcd_add_text("    fi",0)
    CALL dcd_add_text("  fi",0)
    CALL dcd_add_text('  echo "${Alias}.world ="                              >>$NTF',0)
    CALL dcd_add_text('  echo " (DESCRIPTION ="                               >>$NTF',0)
    CALL dcd_add_text('  echo "    (ENABLE=BROKEN)"                           >>$NTF',0)
    CALL dcd_add_text('  echo "    (ADDRESS=(PROTOCOL=TCP)"                   >>$NTF',0)
    CALL dcd_add_text('  echo "    (HOST=${Node})(PORT=${Port}))"             >>$NTF',0)
    CALL dcd_add_text('  echo "  (CONNECT_DATA="                              >>$NTF',0)
    CALL dcd_add_text('  echo "     (SERVER=DEDICATED)"                       >>$NTF',0)
    CALL dcd_add_text('  echo "     (SERVICE_NAME=${Dname}.world)"            >>$NTF',0)
    CALL dcd_add_text('  echo "     (INSTANCE_NAME=${Alias}))"                >>$NTF',0)
    CALL dcd_add_text('  echo " )"                                            >>$NTF',0)
    CALL dcd_add_text('fi #$FoundCur = "N"',0)
    CALL dcd_add_text("  chown oracle:dba $NTF*",0)
    CALL dcd_add_text("chmod 644 $NTF",0)
    IF (dcd_create_text_file(du_source_fname)=0)
     RETURN(0)
    ENDIF
    IF (dor_flex_chmod_file(du_source_fname," ")=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Set path of dm2_updatetns script to execute variable."
   SET du_exe_fname = concat(dm2_create_dom->local_ccluserdir,"/dm2_updatetns.ksh")
   SET dm_err->eproc = "Execute the dm2_updatetns script."
   CALL disp_msg(" ",dm_err->logfile,0)
   CALL dor_init_flex_cmds(null)
   CALL dor_add_flex_cmd(1,"root",dm2_create_dom->db_node_name,du_exe_fname," ",
    " ","EFRO")
   IF (dor_exec_flex_cmd(null)=0)
    RETURN(0)
   ENDIF
   IF ((dor_flex_cmd->cmd[1].flex_output > " "))
    IF (findstring("CER-00000",cnvtupper(dm_err->errtext),1,0) > 0)
     SET dm_err->emsg = concat(substring(findstring("CER-00000",cnvtupper(dor_flex_cmd->cmd[1].
         flex_output),1,1),(size(dor_flex_cmd->cmd[1].flex_output) - findstring("CER-00000",cnvtupper
        (dor_flex_cmd->cmd[1].flex_output),1,1)),dor_flex_cmd->cmd[1].flex_output),".")
     SET message = nowindow
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm2_create_dom->dbtype != "admin")
    AND (dm2_create_dom->local_db=0))
    SET dm_err->eproc = "Add Admin TNS stanza to DB node TNS."
    IF (dcdud_manage_tnsentry("ADD",1,"oracle",dm2_create_dom->db_node_name,concat(dm2_create_dom->
      oracle_home,"/network/admin"),
     dcdud_admin_dbname,dm2_create_dom->rmt_temp_dir,concat(dm2_create_dom->rmt_oracle_home,
      "/network/admin")," ")=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_script
 IF ((dm2_create_dom->response_file_in_use=1))
  SET dcdud_eproc_str = dm_err->eproc
  IF ((dm_err->err_ind=0))
   CALL dcd_add_text("STATUS:SUCCESS",1)
  ELSE
   CALL dcd_add_text("STATUS:FAILED",1)
   CALL dcd_add_text(concat("STEP:",dcdud_eproc_str),0)
   CALL dcd_add_text(concat("MESSAGE:",dm_err->emsg),0)
  ENDIF
  CALL dcd_create_text_file(concat(dm2_create_dom->local_ccluserdir,"/dm2_final_status.txt"))
 ENDIF
 IF ((dm_err->err_ind=0))
  SET dm_err->eproc = concat("Completed DM2_CREATE_DB_USING_DBCA for ",dm2_create_dom->dname)
 ENDIF
 CALL final_disp_msg("dm2_create_dbcadb")
END GO
