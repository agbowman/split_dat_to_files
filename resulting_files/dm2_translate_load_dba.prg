CREATE PROGRAM dm2_translate_load:dba
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
 IF (validate(tbl_doc->qual[1].table_name,"@")="@")
  FREE RECORD tbl_doc
  RECORD tbl_doc(
    1 cnt = i4
    1 qual[*]
      2 table_name = vc
      2 data_model_section = vc
      2 description = vc
      2 definition = vc
      2 primary_update_script = vc
      2 primary_insert_script = vc
      2 primary_delete_script = vc
      2 static_size_flg = i4
      2 static_rows = i4
      2 reads_flg = i4
      2 update_flg = i4
      2 insert_flg = i4
      2 delete_flg = i4
      2 core_ind = i2
      2 updt_cnt = i4
      2 bytes_per_row = i4
      2 reference_ind = i2
      2 pct_free = i4
      2 pct_used = i4
      2 bpr_mean = f8
      2 bpr_min = f8
      2 bpr_max = f8
      2 bpr_std_dev = f8
      2 human_reqd_ind = i2
      2 purge_except_ind = i2
      2 freelist_cnt = i4
      2 drop_ind = i2
      2 table_suffix = vc
      2 full_table_name = vc
      2 suffixed_table_name = vc
      2 default_row_ind = i2
      2 person_cmb_trigger_type = vc
      2 encntr_cmb_trigger_type = vc
      2 merge_ui_query = vc
      2 mergeable_ind = i2
      2 merge_delete_ind = i2
      2 merge_active_ind = i2
      2 data_disp_flag = i2
  )
 ENDIF
 IF (validate(tbl_doc_maint->qual[1].maint_type,"@")="@")
  FREE RECORD tbl_doc_maint
  RECORD tbl_doc_maint(
    1 qual[*]
      2 maint_type = c1
    1 num_of_inserts = i4
    1 num_of_updates = i4
    1 num_of_none = i4
    1 num_of_fixes = i4
  )
 ENDIF
 IF (validate(col_doc->qual[1].table_name,"@")="@")
  FREE RECORD col_doc
  RECORD col_doc(
    1 cnt = i4
    1 qual[*]
      2 table_name = vc
      2 column_name = vc
      2 sequence_name = vc
      2 code_set = i4
      2 description = vc
      2 definition = vc
      2 flag_ind = i2
      2 updt_cnt = i4
      2 unique_ident_ind = i2
      2 root_entity_name = vc
      2 root_entity_attr = vc
      2 constant_value = vc
      2 parent_entity_col = vc
      2 exception_flg = i4
      2 defining_attribute_ind = i2
      2 merge_updateable_ind = i2
      2 nls_col_ind = i2
      2 absolute_date_ind = i2
      2 merge_delete_ind = i2
      2 tz_rule_flag = i2
  )
 ENDIF
 IF (validate(col_doc_maint->qual[1].maint_type,"@")="@")
  FREE RECORD col_doc_maint
  RECORD col_doc_maint(
    1 qual[*]
      2 maint_type = c1
    1 num_of_inserts = i4
    1 num_of_updates = i4
    1 num_of_none = i4
  )
 ENDIF
 IF (validate(ts_prec->qual[1].table_name,"@")="@")
  FREE RECORD ts_prec
  RECORD ts_prec(
    1 cnt = i4
    1 qual[*]
      2 table_name = vc
      2 precedence = i4
      2 data_tablespace = vc
      2 data_extent_size = f8
      2 index_tablespace = vc
      2 index_extent_size = f8
      2 long_tablespace = vc
      2 long_extent_size = f8
      2 updt_cnt = i4
  )
 ENDIF
 IF (validate(ts_prec_maint->qual[1].maint_type,"@")="@")
  FREE RECORD ts_prec_maint
  RECORD ts_prec_maint(
    1 qual[*]
      2 maint_type = c1
    1 num_of_inserts = i4
    1 num_of_updates = i4
    1 num_of_none = i4
  )
 ENDIF
 DECLARE open_sch_files(sbr_for_modify=i4) = i4
 DECLARE create_sch_files(null) = i4
 DECLARE close_sch_files(null) = i4
 DECLARE copy_sch_files(null) = i4
 DECLARE open_sch_file(sbr_osf_modind=i4,sbr_osf_fname=vc,sbr_osf_rndx=i4) = i4
 DECLARE val_sch_file_ver(sbr_vsf_rndx=i4) = i4
 DECLARE make_sch_file_defs(sbr_msf_rndx=i4) = i4
 DECLARE del_sch_file(sbr_dsf_ffname=vc,sbr_dsf_fname=vc) = i4
 DECLARE del_sch_files(null) = i2
 DECLARE copy_sch_file(sbr_src_fname=vc,sbr_tgt_fname=vc) = i4
 DECLARE check_sch_files(null) = i4
 DECLARE prep_sch_file(rec_ndx=i4) = i4
 DECLARE gen_sch_files(null) = i4
 DECLARE dsfi_load_schema_file_defs(dsfi_schema_set=vc) = i4
 DECLARE dsfi_load_schema_files(dlsf_desc=vc,dlsf_process_option=vc) = i2
 DECLARE dsfi_pop_dmheader(sfidx=i4) = null
 DECLARE dsfi_pop_dmtable(sfidx=i4) = null
 DECLARE dsfi_pop_dmcolumn(sfidx=i4) = null
 DECLARE dsfi_pop_dmindex(sfidx=i4) = null
 DECLARE dsfi_pop_dmindcol(sfidx=i4) = null
 DECLARE dsfi_pop_dmcons(sfidx=i4) = null
 DECLARE dsfi_pop_dmconscol(sfidx=i4) = null
 DECLARE dsfi_pop_dmseq(sfidx=i4) = null
 DECLARE dsfi_pop_dmtbldoc(sfidx=i4) = null
 DECLARE dsfi_pop_dmcoldoc(sfidx=i4) = null
 DECLARE dsfi_pop_dmtdprec(sfidx=i4) = null
 DECLARE dsfi_pop_dmtspace(sfidx=i4) = null
 IF ((validate(dm2_sch_file->file_cnt,- (1))=- (1)))
  RECORD dm2_sch_file(
    1 sf_ver = i4
    1 file_cnt = i4
    1 src_dir_osfmt = vc
    1 dest_dir_cclfmt = vc
    1 dest_dir_osfmt = vc
    1 ending_punct = vc
    1 file_prefix = vc
    1 qual[*]
      2 file_suffix = vc
      2 table_name = vc
      2 db_name = vc
      2 size = vc
      2 data_size = vc
      2 key_size = vc
      2 db_key = vc
      2 key_cnt = i4
      2 kqual[*]
        3 key_col = vc
      2 data_cnt = i4
      2 dqual[*]
        3 data_col = vc
  )
  SET dm2_sch_file->sf_ver = 1
  CASE (dm2_sys_misc->cur_os)
   OF "AXP":
    SET dm2_sch_file->ending_punct = " "
   OF "WIN":
    SET dm2_sch_file->ending_punct = "\"
   ELSE
    SET dm2_sch_file->ending_punct = "/"
  ENDCASE
  IF (dsfi_load_schema_file_defs("TABLE_INFO") != 1)
   SET dm_err->err_ind = 1
  ENDIF
 ENDIF
 SUBROUTINE create_sch_files(null)
   DECLARE csf_concurrency_cnt = i4 WITH noconstant(0)
   DECLARE sch_file_status = i4
   DECLARE di_insert_ind = i2 WITH noconstant(0)
   DECLARE pause_length = i2 WITH noconstant(60)
   DECLARE csf_done_ind = i2 WITH noconstant(0)
   DECLARE csf_retry_cnt = i2 WITH noconstant(0)
   DECLARE csf_skip_ind = i2 WITH noconstant(0)
   SET dm2_sch_file->dest_dir_osfmt = build(logical(dm2_sch_file->dest_dir_cclfmt),dm2_sch_file->
    ending_punct)
   WHILE (csf_done_ind=0
    AND (dm_err->err_ind=0))
     SET csf_done_ind = 1
     SET csf_skip_ind = 0
     IF ((dm2_sch_file->qual[1].table_name != "DMTSPACE"))
      WHILE (csf_concurrency_cnt < 2
       AND (dm_err->err_ind=0))
        IF (dm2_set_autocommit(1)=1)
         SELECT INTO "nl:"
          FROM dm_info d
          WHERE d.info_domain="DM2 TOOLS"
           AND d.info_name="CREATING SCHEMA FILES"
          WITH nocounter
         ;end select
         IF (curqual > 0)
          SET csf_concurrency_cnt = (csf_concurrency_cnt+ 1)
          IF (csf_concurrency_cnt=2)
           SET dm_err->emsg =
           "Another process is currently generating schema file definitions, please try again later."
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           SET dm_err->err_ind = 1
          ELSE
           SET dm_err->eproc = concat(
            "Another process is currently generating schema file definitions.  Pausing ",trim(
             cnvtstring(pause_length))," seconds before trying again. Please wait.")
           CALL disp_msg(" ",dm_err->logfile,0)
           CALL pause(pause_length)
          ENDIF
         ELSE
          IF (check_error("Checking for concurrency row in dm_info ")=1)
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          ENDIF
          SET csf_concurrency_cnt = 2
         ENDIF
        ENDIF
      ENDWHILE
     ENDIF
     IF ((dm_err->err_ind=0))
      SET sch_file_status = check_sch_files(null)
      CASE (sch_file_status)
       OF 0:
        SET dm_err->err_ind = 1
       OF 1:
        SET dm_err->eproc = "ALL CORE SCHEMA FILE COMPONENTS EXIST"
        CALL disp_msg(" ",dm_err->logfile,0)
        FOR (csf_file_cnt = 1 TO dm2_sch_file->file_cnt)
          IF (prep_sch_file(csf_file_cnt)=0)
           SET dm_err->err_ind = 1
           SET csf_file_cnt = dm2_sch_file->file_cnt
          ENDIF
        ENDFOR
       OF 2:
        IF ((dm2_sch_file->qual[1].table_name != "DMTSPACE"))
         SET dm_err->eproc = "INSERT CONCURRENCY ROW INTO DM_INFO"
         CALL disp_msg(" ",dm_err->logfile,0)
         INSERT  FROM dm_info d
          SET d.info_domain = "DM2 TOOLS", d.info_name = "CREATING SCHEMA FILES", d.info_date = null,
           d.info_char = " ", d.info_number = 0.0, d.info_long_id = 0.0,
           d.updt_applctx = 0, d.updt_task = 0.0, d.updt_cnt = 0,
           d.updt_id = 0.0, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
          WITH nocounter
         ;end insert
         IF (check_error("Inserting dm_info row for concurrency ")=1)
          IF (findstring("ORA-00001",dm_err->emsg,1,0) > 0)
           SET csf_retry_cnt = (csf_retry_cnt+ 1)
           IF (csf_retry_cnt < 2)
            SET dm_err->err_ind = 0
            SET csf_done_ind = 0
            SET csf_skip_ind = 1
            SET dm_err->eproc = concat(
             "Another process is currently generating schema file definitions.  Pausing ",trim(
              cnvtstring(pause_length))," seconds before trying again. Please wait.")
            CALL disp_msg(" ",dm_err->logfile,0)
            CALL pause(pause_length)
           ELSE
            SET dm_err->emsg =
            "Another process is currently generating schema file definitions, please try again later."
            CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           ENDIF
          ELSE
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           ROLLBACK
          ENDIF
         ELSE
          COMMIT
          SET di_insert_ind = 1
         ENDIF
        ENDIF
        IF ((dm_err->err_ind=0)
         AND csf_skip_ind=0)
         SET dm_err->eproc = "REGENERATE CORE SCHEMA FILE COMPONENTS"
         CALL disp_msg(" ",dm_err->logfile,0)
         CALL gen_sch_files(null)
        ENDIF
      ENDCASE
     ENDIF
   ENDWHILE
   IF (di_insert_ind=1)
    SET dm_err->eproc = "REMOVE CONCURRENCY ROW FROM DM_INFO"
    CALL disp_msg(" ",dm_err->logfile,0)
    DELETE  FROM dm_info d
     WHERE d.info_domain="DM2 TOOLS"
      AND d.info_name="CREATING SCHEMA FILES"
     WITH nocounter
    ;end delete
    COMMIT
    IF ((dm_err->err_ind=0))
     IF (check_error("Deleting dm_info row for concurrency ")=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ENDIF
    ENDIF
   ENDIF
   CALL dm2_set_autocommit(0)
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE open_sch_file(sbr_osf_modind,sbr_osf_fname,sbr_osf_rndx)
   DECLARE osf_tempstr = vc WITH noconstant(" ")
   IF (dm2_push_cmd(concat("free define ",dm2_sch_file->qual[sbr_osf_rndx].db_name," go"),1)=0)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   CALL dm2_push_cmd(concat("define ",dm2_sch_file->qual[sbr_osf_rndx].db_name," is ",build("'",
      sbr_osf_fname,"'")),0)
   IF (sbr_osf_modind=1)
    CALL dm2_push_cmd(" with modify",0)
    SET osf_tempstr = " with modify"
   ENDIF
   IF (dm2_push_cmd(" go",1)=0)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE open_sch_files(sbr_for_modify)
   DECLARE file_name_for_open = vc
   DECLARE dsfi = i4 WITH public, noconstant(0)
   FOR (dsfi = 1 TO dm2_sch_file->file_cnt)
     SET file_name_for_open = build(dm2_sch_file->dest_dir_cclfmt,":",cnvtlower(dm2_sch_file->
       file_prefix),cnvtlower(dm2_sch_file->qual[dsfi].file_suffix),".dat")
     IF (val_sch_file_ver(dsfi)=0)
      IF ((dm_err->err_ind=1))
       RETURN(0)
      ELSEIF (make_sch_file_defs(dsfi)=0)
       SET dm_err->err_ind = 1
       RETURN(0)
      ENDIF
     ENDIF
     IF ((dm_err->debug_flag=1))
      SET dm_err->eproc = concat("Opening ",file_name_for_open)
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     IF (open_sch_file(sbr_for_modify,file_name_for_open,dsfi)=0)
      SET dm_err->err_ind = 1
      RETURN(0)
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE val_sch_file_ver(sbr_vsf_rndx)
   DECLARE vsfv_datacnt = i4 WITH noconstant(0)
   DECLARE vsfv_keycnt = i4 WITH noconstant(0)
   DECLARE vsfv_match_col_ind = i2 WITH noconstant(0)
   DECLARE vsfv_match_db_ind = i2 WITH noconstant(0)
   DECLARE vsfv_temp_str = vc WITH noconstant("")
   SELECT INTO "nl:"
    d.table_name
    FROM dtable d
    WHERE (d.file_name=dm2_sch_file->qual[sbr_vsf_rndx].db_name)
     AND (d.table_name=dm2_sch_file->qual[sbr_vsf_rndx].table_name)
    DETAIL
     vsfv_match_db_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(concat("Checking for ",dm2_sch_file->qual[sbr_vsf_rndx].table_name,
     " in CCL dictionary"))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    l.attr_name
    FROM dtableattr a,
     dtableattrl l
    WHERE (a.table_name=dm2_sch_file->qual[sbr_vsf_rndx].table_name)
     AND l.structtype="F"
     AND btest(l.stat,11)=0
    HEAD REPORT
     start_pos = 0, end_pos = 0, x = 0,
     y = 0
    DETAIL
     FOR (x = 1 TO dm2_sch_file->qual[sbr_vsf_rndx].data_cnt)
      end_pos = findstring("=",dm2_sch_file->qual[sbr_vsf_rndx].dqual[x].data_col),
      IF (trim(l.attr_name,3)=substring(1,(end_pos - 1),dm2_sch_file->qual[sbr_vsf_rndx].dqual[x].
       data_col))
       end_pos = 0
       IF (trim(l.attr_name,3)="FILLER")
        start_pos = findstring("FILLER = c",dm2_sch_file->qual[sbr_vsf_rndx].dqual[x].data_col),
        start_pos = (start_pos+ 10), end_pos = findstring(" CCL(FILLER)",dm2_sch_file->qual[
         sbr_vsf_rndx].dqual[x].data_col)
        IF (l.len=cnvtint(substring(start_pos,(end_pos - start_pos),dm2_sch_file->qual[sbr_vsf_rndx].
          dqual[x].data_col)))
         vsfv_datacnt = (vsfv_datacnt+ 1), x = dm2_sch_file->qual[sbr_vsf_rndx].data_cnt
        ENDIF
       ELSE
        vsfv_datacnt = (vsfv_datacnt+ 1), x = dm2_sch_file->qual[sbr_vsf_rndx].data_cnt
       ENDIF
      ENDIF
     ENDFOR
     FOR (y = 1 TO dm2_sch_file->qual[sbr_vsf_rndx].key_cnt)
      end_pos = findstring("=",dm2_sch_file->qual[sbr_vsf_rndx].kqual[y].key_col),
      IF (trim(l.attr_name,3)=substring(1,(end_pos - 1),dm2_sch_file->qual[sbr_vsf_rndx].kqual[y].
       key_col))
       end_pos = 0, vsfv_keycnt = (vsfv_keycnt+ 1), y = dm2_sch_file->qual[sbr_vsf_rndx].key_cnt
      ENDIF
     ENDFOR
    WITH nocounter
   ;end select
   IF (check_error(concat("Checking for columns on ",dm2_sch_file->qual[sbr_vsf_rndx].table_name,
     " in CCL dictionary"))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
    CALL echo(build("dm_err->err_ind = ",dm_err->err_ind))
   ENDIF
   IF ((vsfv_datacnt=dm2_sch_file->qual[sbr_vsf_rndx].data_cnt)
    AND (vsfv_keycnt=dm2_sch_file->qual[sbr_vsf_rndx].key_cnt))
    SET vsfv_match_col_ind = 1
   ENDIF
   IF (vsfv_match_col_ind=1
    AND vsfv_match_db_ind=1)
    RETURN(1)
   ELSE
    CALL disp_msg(concat(dm2_sch_file->qual[sbr_vsf_rndx].table_name,
      " definition not correct in CCL dictionary"),dm_err->logfile,0)
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE make_sch_file_defs(sbr_msf_rndx)
   DECLARE current_db = vc
   DECLARE msfd_estr = vc
   DECLARE msfd_ret_val = i2 WITH noconstant(0)
   DECLARE drop_needed = i2 WITH noconstant(0)
   IF ((dm_err->debug_flag=1))
    SET dm_err->eproc = concat("Making CCL definition for ",dm2_sch_file->qual[sbr_msf_rndx].
     table_name)
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dtable d
    WHERE (d.table_name=dm2_sch_file->qual[sbr_msf_rndx].table_name)
    DETAIL
     drop_needed = 1, current_db = d.file_name
    WITH nocounter
   ;end select
   IF (drop_needed=1)
    IF (dm2_push_cmd(concat("drop table ",dm2_sch_file->qual[sbr_msf_rndx].table_name," go"),1)=0)
     RETURN(0)
    ENDIF
    IF (dm2_push_cmd(concat("drop ddlrecord ",dm2_sch_file->qual[sbr_msf_rndx].table_name,
      " from database ",current_db," WITH DEPS_DELETED go"),1)=0)
     RETURN(0)
    ENDIF
    IF (dm2_push_cmd(concat("drop database ",current_db," with deps_deleted go"),1)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET drop_needed = 0
   SELECT INTO "nl:"
    FROM dfile d
    WHERE (d.file_name=dm2_sch_file->qual[sbr_msf_rndx].db_name)
    DETAIL
     drop_needed = 1
    WITH nocounter
   ;end select
   IF (drop_needed=1)
    IF (dm2_push_cmd(concat("drop database ",dm2_sch_file->qual[sbr_msf_rndx].db_name,
      " with deps_deleted go"),1)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dm2_push_cmd(concat("create database ",dm2_sch_file->qual[sbr_msf_rndx].db_name,
     " organization(indexed) format(variable) size(",dm2_sch_file->qual[sbr_msf_rndx].size,") ",
     dm2_sch_file->qual[sbr_msf_rndx].db_key," go"),1)=0)
    RETURN(0)
   ENDIF
   CALL dm2_push_cmd(concat("create ddlrecord ",dm2_sch_file->qual[sbr_msf_rndx].table_name,
     " from database ",dm2_sch_file->qual[sbr_msf_rndx].db_name," table ",
     dm2_sch_file->qual[sbr_msf_rndx].table_name),0)
   CALL dm2_push_cmd(" 1 key1 ",0)
   FOR (i = 1 TO dm2_sch_file->qual[sbr_msf_rndx].key_cnt)
     CALL dm2_push_cmd(concat(" 2 ",dm2_sch_file->qual[sbr_msf_rndx].kqual[i].key_col),0)
   ENDFOR
   CALL dm2_push_cmd(" 1 data ",0)
   FOR (i = 1 TO dm2_sch_file->qual[sbr_msf_rndx].data_cnt)
     CALL dm2_push_cmd(concat(" 2 ",dm2_sch_file->qual[sbr_msf_rndx].dqual[i].data_col),0)
   ENDFOR
   IF (dm2_push_cmd(concat("end table ",dm2_sch_file->qual[sbr_msf_rndx].table_name," go"),1)=0)
    RETURN(0)
   ENDIF
   SET msfd_estr = concat("Making def for ",dm2_sch_file->qual[sbr_msf_rndx].table_name)
   SET msfd_ret_val = val_sch_file_ver(sbr_msf_rndx)
   IF (msfd_ret_val=0)
    IF ((dm_err->err_ind=0))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = msfd_estr
     CALL disp_msg(" ",dm_err->logfile,1)
    ENDIF
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE close_sch_files(null)
   FOR (close_cnt = 1 TO dm2_sch_file->file_cnt)
     IF (dm2_push_cmd(concat("free define ",dm2_sch_file->qual[close_cnt].db_name," go"),1)=0)
      SET dm_err->err_ind = 1
      RETURN(0)
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE copy_sch_files(null)
  DECLARE target_name = vc
  FOR (csfi = 1 TO dm2_sch_file->file_cnt)
    SET target_name = build(dm2_sch_file->file_prefix,cnvtlower(dm2_sch_file->qual[csfi].file_suffix)
     )
    IF ( NOT ((dm2_sys_misc->cur_os IN ("AXP"))))
     IF (del_sch_file(build(dm2_sch_file->dest_dir_osfmt,target_name,".dat"))=0)
      SET dm_err->err_ind = 1
      RETURN(0)
     ENDIF
     IF (del_sch_file(build(dm2_sch_file->dest_dir_osfmt,target_name,".idx"))=0)
      SET dm_err->err_ind = 1
      RETURN(0)
     ENDIF
    ENDIF
    IF (copy_sch_file(build(dm2_sch_file->src_dir_osfmt,target_name,".dat"),build(dm2_sch_file->
      dest_dir_osfmt,target_name,".dat"))=0)
     SET dm_err->err_ind = 1
     RETURN(0)
    ENDIF
    IF ( NOT ((dm2_sys_misc->cur_os IN ("AXP"))))
     IF (copy_sch_file(build(dm2_sch_file->src_dir_osfmt,target_name,".idx"),build(dm2_sch_file->
       dest_dir_osfmt,target_name,".idx"))=0)
      SET dm_err->err_ind = 1
      RETURN(0)
     ENDIF
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE del_sch_file(sbr_dsf_fname)
  IF ((dm2_sys_misc->cur_os="WIN"))
   IF (findfile(sbr_dsf_fname)=1)
    IF (dm2_push_dcl(concat("del ",sbr_dsf_fname))=0)
     RETURN(0)
    ENDIF
   ENDIF
  ELSEIF ((dm2_sys_misc->cur_os="AXP"))
   IF (findfile(sbr_dsf_fname)=1)
    IF (dm2_push_dcl(concat("del ",sbr_dsf_fname,";\*"))=0)
     RETURN(0)
    ENDIF
   ENDIF
  ELSE
   IF (findfile(sbr_dsf_fname)=1)
    IF (dm2_push_dcl(concat("rm ",sbr_dsf_fname))=0)
     RETURN(0)
    ENDIF
   ENDIF
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE copy_sch_file(sbr_src_fname,sbr_tgt_fname)
  IF ((dm2_sys_misc->cur_os IN ("HPX", "AIX", "LNX")))
   IF (dm2_push_dcl(concat("cp ",sbr_src_fname," ",sbr_tgt_fname))=0)
    RETURN(0)
   ENDIF
   IF (dm2_push_dcl(concat("chmod 777 ",sbr_tgt_fname))=0)
    RETURN(0)
   ENDIF
  ELSE
   IF (dm2_push_dcl(concat("copy ",sbr_src_fname," ",sbr_tgt_fname))=0)
    RETURN(0)
   ENDIF
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE check_sch_files(null)
   DECLARE csf_file_name = vc WITH noconstant("")
   DECLARE csf_val_ver_ind = i2 WITH noconstant(0)
   FOR (csf_file_cnt = 1 TO dm2_sch_file->file_cnt)
     SET csf_file_name = concat(dm2_install_schema->ccluserdir,dm2_sch_file->qual[csf_file_cnt].
      table_name)
     IF ((dm2_sys_misc->cur_os="AXP"))
      IF ( NOT (findfile(concat(trim(csf_file_name,3),".dat"))))
       RETURN(2)
      ENDIF
     ELSE
      IF ( NOT (findfile(concat(trim(csf_file_name,3),".dat"))))
       RETURN(2)
      ELSEIF ( NOT (findfile(concat(trim(csf_file_name,3),".idx"))))
       RETURN(2)
      ENDIF
     ENDIF
     IF (val_sch_file_ver(csf_file_cnt)=0)
      IF ((dm_err->err_ind=1))
       RETURN(0)
      ELSE
       SET csf_val_ver_ind = 1
      ENDIF
     ENDIF
   ENDFOR
   IF (csf_val_ver_ind=1)
    RETURN(2)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE prep_sch_file(rec_ndx)
   DECLARE psf_target_name = vc
   DECLARE psf_target_name2 = vc
   DECLARE psf_estr = vc
   DECLARE psf_fext = vc
   IF ((dm2_sys_misc->cur_os IN ("HPX", "AIX", "LNX")))
    SET psf_fext = ".dat/.idx"
   ELSEIF ((dm2_sys_misc->cur_os="WIN"))
    SET psf_fext = ".dat/.idx"
   ELSE
    SET psf_fext = ".dat"
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("dm2_sch_file->dest_dir_osfmt=",dm2_sch_file->dest_dir_osfmt))
    CALL echo(build("size(dm2_sch_file->dest_dir_osfmt,1)=",size(dm2_sch_file->dest_dir_osfmt,1)))
    CALL echo(concat("dm2_sch_file->file_prefix=",dm2_sch_file->file_prefix))
    CALL echo(concat("dm2_sch_file->qual[rec_ndx]->file_suffix=",dm2_sch_file->qual[rec_ndx].
      file_suffix))
   ENDIF
   SET psf_target_name = build(dm2_sch_file->dest_dir_osfmt,cnvtlower(dm2_sch_file->file_prefix),
    cnvtlower(dm2_sch_file->qual[rec_ndx].file_suffix),".dat")
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("psf_target_name=",psf_target_name))
   ENDIF
   IF ((dm2_sys_misc->cur_os != "AXP"))
    SET psf_target_name2 = build(dm2_sch_file->dest_dir_osfmt,cnvtlower(dm2_sch_file->file_prefix),
     cnvtlower(dm2_sch_file->qual[rec_ndx].file_suffix),".idx")
   ENDIF
   IF ((dm2_sys_misc->cur_os IN ("HPX", "AIX", "WIN", "LNX")))
    IF (del_sch_file(psf_target_name)=0)
     RETURN(0)
    ENDIF
    IF (del_sch_file(psf_target_name2)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (copy_sch_file(concat(dm2_install_schema->ccluserdir,cnvtlower(build(dm2_sch_file->qual[rec_ndx
       ].table_name,".dat"))),psf_target_name)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os != "AXP"))
    IF (copy_sch_file(concat(dm2_install_schema->ccluserdir,cnvtlower(build(dm2_sch_file->qual[
        rec_ndx].table_name,".idx"))),psf_target_name2)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (open_sch_file(1,build(dm2_sch_file->dest_dir_cclfmt,":",cnvtlower(dm2_sch_file->file_prefix),
     cnvtlower(dm2_sch_file->qual[rec_ndx].file_suffix),".dat"),rec_ndx)=0)
    RETURN(0)
   ENDIF
   IF (dm2_push_cmd(concat("delete from ",dm2_sch_file->qual[rec_ndx].table_name," where 1=1 go"),1)=
   0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gen_sch_files(null)
   DECLARE gsf_fext = vc
   IF ((dm2_sys_misc->cur_os IN ("HPX", "AIX", "LNX")))
    SET gsf_fext = ".dat/.idx"
   ELSEIF ((dm2_sys_misc->cur_os="WIN"))
    SET gsf_fext = ".dat/.idx"
   ELSE
    SET gsf_fext = ".dat"
   ENDIF
   FOR (gsf_cnt = 1 TO dm2_sch_file->file_cnt)
     IF ((dm2_sys_misc->cur_os != "AXP"))
      IF (del_sch_file(concat(dm2_install_schema->ccluserdir,cnvtlower(build(dm2_sch_file->qual[
          gsf_cnt].table_name,".dat"))))=0)
       RETURN(0)
      ENDIF
      IF (del_sch_file(concat(dm2_install_schema->ccluserdir,cnvtlower(build(dm2_sch_file->qual[
          gsf_cnt].table_name,".idx"))))=0)
       RETURN(0)
      ENDIF
     ENDIF
     IF (dm2_push_cmd(concat('select into table "',dm2_sch_file->qual[gsf_cnt].table_name,'"',
       " key1=fillstring(",dm2_sch_file->qual[gsf_cnt].key_size,
       '," "),'," data=fillstring(",dm2_sch_file->qual[gsf_cnt].data_size,'," ") ',
       " from dummyt order key1 with organization=indexed GO"),1)=0)
      RETURN(0)
     ENDIF
     IF (dm2_push_cmd(concat("drop table ",dm2_sch_file->qual[gsf_cnt].table_name," go"),1)=0)
      RETURN(0)
     ENDIF
     IF (dm2_push_cmd(concat("drop ddlrecord ",dm2_sch_file->qual[gsf_cnt].table_name,
       " from database ",dm2_sch_file->qual[gsf_cnt].table_name," with deps_deleted go"),1)=0)
      RETURN(0)
     ENDIF
     IF (dm2_push_cmd(concat("drop database ",dm2_sch_file->qual[gsf_cnt].table_name,
       " with deps_deleted go"),1)=0)
      RETURN(0)
     ENDIF
     IF (make_sch_file_defs(gsf_cnt)=0)
      RETURN(0)
     ENDIF
     IF (prep_sch_file(gsf_cnt)=0)
      RETURN(0)
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsfi_load_schema_file_defs(dsfi_schema_set)
  CASE (cnvtupper(dsfi_schema_set))
   OF "TABLE_INFO":
    SET dm2_sch_file->file_cnt = 11
    SET stat = alterlist(dm2_sch_file->qual,dm2_sch_file->file_cnt)
    CALL dsf_pop_dmheader(1)
    CALL dsf_pop_dmtable(2)
    CALL dsf_pop_dmcolumn(3)
    CALL dsf_pop_dmindex(4)
    CALL dsf_pop_dmindcol(5)
    CALL dsf_pop_dmcons(6)
    CALL dsf_pop_dmconscol(7)
    CALL dsf_pop_dmseq(8)
    CALL dsf_pop_dmtbldoc(9)
    CALL dsf_pop_dmcoldoc(10)
    CALL dsf_pop_dmtsprec(11)
   OF "TSPACE":
    SET dm2_sch_file->file_cnt = 1
    SET stat = alterlist(dm2_sch_file->qual,dm2_sch_file->file_cnt)
    CALL dsf_pop_dmtspace(1)
  ENDCASE
  RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmheader(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_h"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMHEADER"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1058"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1028"
   SET dm2_sch_file->qual[dsfcnt].key_size = "30"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 30)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 1
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "DESCRIPTION = c30 CCL(DESCRIPTION)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 4
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "SOURCE_RDBMS = c20 CCL(SOURCE_RDBMS)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "ADMIN_LOAD_IND = i4 CCL(ADMIN_LOAD_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "SF_VERSION = i4 CCL(SF_VERSION)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col = "FILLER = c1000 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmtable(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_t"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMTABLE"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1208"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1178"
   SET dm2_sch_file->qual[dsfcnt].key_size = "30"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 30)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 1
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "TABLE_NAME = c30  CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 21
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "TABLESPACE_NAME = c30 CCL(TABLESPACE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "INDEX_TSPACE = c30 CCL(INDEX_TSPACE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "INDEX_TSPACE_NI = i2 CCL(INDEX_TSPACE_NI)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col = "LONG_TSPACE = c30 CCL(LONG_TSPACE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[5].data_col = "LONG_TSPACE_NI = i2 CCL(LONG_TSPACE_NI)"
   SET dm2_sch_file->qual[dsfcnt].dqual[6].data_col = "INIT_EXT = f8 CCL(INIT_EXT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[7].data_col = "NEXT_EXT = f8 CCL(NEXT_EXT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[8].data_col = "PCT_INCREASE = f8 CCL(PCT_INCREASE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[9].data_col = "PCT_USED = f8 CCL(PCT_USED)"
   SET dm2_sch_file->qual[dsfcnt].dqual[10].data_col = "PCT_FREE = f8 CCL(PCT_FREE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[11].data_col = "BYTES_ALLOCATED = f8 CCL(BYTES_ALLOCATED)"
   SET dm2_sch_file->qual[dsfcnt].dqual[12].data_col = "BYTES_USED = f8 CCL(BYTES_USED)"
   SET dm2_sch_file->qual[dsfcnt].dqual[13].data_col = "SCHEMA_DATE = dq8 CCL(SCHEMA_DATE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[14].data_col =
   "ALPHA_FEATURE_NBR = i4 CCL(ALPHA_FEATURE_NBR)"
   SET dm2_sch_file->qual[dsfcnt].dqual[15].data_col = "FEATURE_NUMBER = i4 CCL(FEATURE_NUMBER)"
   SET dm2_sch_file->qual[dsfcnt].dqual[16].data_col = "UPDT_DT_TM = dq8 CCL(UPDT_DT_TM)"
   SET dm2_sch_file->qual[dsfcnt].dqual[17].data_col = "SCHEMA_INSTANCE = i4 CCL(SCHEMA_INSTANCE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[18].data_col = "TSPACE_TYPE = c1 CCL(TSPACE_TYPE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[19].data_col = "LONG_TSPACE_TYPE = c1 CCL(LONG_TSPACE_TYPE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[20].data_col = "MAX_EXT = f8 CCL(MAX_EXT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[21].data_col = "FILLER = c990 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmcolumn(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_tc"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMCOLUMN"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1343"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1283"
   SET dm2_sch_file->qual[dsfcnt].key_size = "60"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 60)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 2
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "TABLE_NAME = c30 CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].kqual[2].key_col = "COLUMN_NAME = c30 CCL(COLUMN_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 9
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "COLUMN_SEQ = i4 CCL(COLUMN_SEQ)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "DATA_TYPE = c18 CCL(DATA_TYPE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "DATA_LENGTH = i4 CCL(DATA_LENGTH)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col = "NULLABLE = c1 CCL(NULLABLE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[5].data_col = "DATA_DEFAULT = c254 CCL(DATA_DEFAULT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[6].data_col = "DATA_DEFAULT_NI = i2 CCL(DATA_DEFAULT_NI)"
   SET dm2_sch_file->qual[dsfcnt].dqual[7].data_col = "DATA_DEFAULT2 = c500 CCL(DATA_DEFAULT2)"
   SET dm2_sch_file->qual[dsfcnt].dqual[8].data_col = "VIRTUAL_COLUMN = c3 CCL(VIRTUAL_COLUMN)"
   SET dm2_sch_file->qual[dsfcnt].dqual[9].data_col = "FILLER = c497 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmindex(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_i"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMINDEX"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1140"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1080"
   SET dm2_sch_file->qual[dsfcnt].key_size = "60"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 60)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 2
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "TABLE_NAME =  c30 CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].kqual[2].key_col = "INDEX_NAME = c30 CCL(INDEX_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 13
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "FULL_IND_NAME = c30 CCL(FULL_IND_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "PCT_INCREASE = f8 CCL(PCT_INCREASE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "PCT_FREE = f8 CCL(PCT_FREE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col = "INIT_EXT = f8 CCL(INIT_EXT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[5].data_col = "NEXT_EXT = f8 CCL(NEXT_EXT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[6].data_col = "UNIQUE_IND = i2 CCL(UNIQUE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[7].data_col = "BYTES_ALLOCATED = f8 CCL(BYTES_ALLOCATED)"
   SET dm2_sch_file->qual[dsfcnt].dqual[8].data_col = "BYTES_USED = f8 CCL(BYTES_USED)"
   SET dm2_sch_file->qual[dsfcnt].dqual[9].data_col = "TSPACE_NAME = c30 CCL(TSPACE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[10].data_col = "TSPACE_TYPE = c1 CCL(TSPACE_TYPE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[11].data_col = "INDEX_TYPE = c30 CCL(INDEX_TYPE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[12].data_col = "MAX_EXT = f8 CCL(MAX_EXT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[13].data_col = "FILLER = c931 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmindcol(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_ic"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMINDCOL"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1094"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1034"
   SET dm2_sch_file->qual[dsfcnt].key_size = "60"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 60)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 2
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "INDEX_NAME = c30 CCL(INDEX_NAME)"
   SET dm2_sch_file->qual[dsfcnt].kqual[2].key_col = "COLUMN_NAME = c30 CCL(COLUMN_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 3
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "TABLE_NAME = c30 CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "COLUMN_POSITION = i4 CCL(COLUMN_POSITION)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "FILLER = c1000 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmcons(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_c"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMCONS"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1408"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1348"
   SET dm2_sch_file->qual[dsfcnt].key_size = "60"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 60)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 2
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "TABLE_NAME = c30 CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].kqual[2].key_col = "CONSTRAINT_NAME = c30 CCL(CONSTRAINT_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 8
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "FULL_CONS_NAME = c30 CCL(FULL_CONS_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "CONSTRAINT_TYPE = c1 CCL(CONSTRAINT_TYPE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "STATUS_IND = i2 CCL(STATUS_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col =
   "R_CONSTRAINT_NAME = c30 CCL(R_CONSTRAINT_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[5].data_col =
   "PARENT_TABLE_NAME = c30 CCL(PARENT_TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[6].data_col =
   "PARENT_TABLE_COLUMNS = c255 CCL(PARENT_TABLE_COLUMNS)"
   SET dm2_sch_file->qual[dsfcnt].dqual[7].data_col = "DELETE_RULE = c9 CCL(DELETE_RULE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[8].data_col = "FILLER = c991 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmconscol(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_cc"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMCONSCOL"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1094"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1034"
   SET dm2_sch_file->qual[dsfcnt].key_size = "60"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 60)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 2
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "CONSTRAINT_NAME = c30 CCL(CONSTRAINT_NAME)"
   SET dm2_sch_file->qual[dsfcnt].kqual[2].key_col = "COLUMN_NAME = c30 CCL(COLUMN_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 3
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "TABLE_NAME = c30 CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "POSITION =  i4 CCL(POSITION)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "FILLER = c1000 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmseq(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_sq"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMSEQ"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1079"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1049"
   SET dm2_sch_file->qual[dsfcnt].key_size = "30"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 30)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 1
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "SEQUENCE_NAME = c30 CCL(SEQUENCE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 9
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "MIN_VALUE = f8  CCL(MIN_VALUE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "MAX_VALUE = f8 CCL(MAX_VALUE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "INCREMENT_BY = f8 CCL(INCREMENT_BY)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col = "CYCLE_FLAG = c1 CCL(CYCLE_FLAG)"
   SET dm2_sch_file->qual[dsfcnt].dqual[5].data_col = "LAST_NUMBER = f8 CCL(LAST_NUMBER)"
   SET dm2_sch_file->qual[dsfcnt].dqual[6].data_col = "ALPHA_FEATURE_NBR = i4 CCL(ALPHA_FEATURE_NBR)"
   SET dm2_sch_file->qual[dsfcnt].dqual[7].data_col = "FEATURE_NUMBER = i4 CCL(FEATURE_NUMBER)"
   SET dm2_sch_file->qual[dsfcnt].dqual[8].data_col = "UPDT_DT_TM = dq8 CCL(UPDT_DT_TM)"
   SET dm2_sch_file->qual[dsfcnt].dqual[9].data_col = "FILLER = c1000 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmtbldoc(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_td"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMTBLDOC"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "2041"
   SET dm2_sch_file->qual[dsfcnt].data_size = "2011"
   SET dm2_sch_file->qual[dsfcnt].key_size = "30"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 30)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 1
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "TABLE_NAME = c30 CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 20
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col =
   "DATA_MODEL_SECTION = c80 CCL(DATA_MODEL_SECTION)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "DESCRIPTION = c80 CCL(DESCRIPTION)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "DEFINITION = c500 CCL(DEFINITION)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col = "STATIC_ROWS = i4 CCL(STATIC_ROWS)"
   SET dm2_sch_file->qual[dsfcnt].dqual[5].data_col = "UPDT_CNT = i4 CCL(UPDT_CNT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[6].data_col = "REFERENCE_IND = i2 CCL(REFERENCE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[7].data_col = "HUMAN_REQD_IND = i2 CCL(HUMAN_REQD_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[8].data_col = "DROP_IND = i2 CCL(DROP_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[9].data_col = "TABLE_SUFFIX = c4 CCL(TABLE_SUFFIX)"
   SET dm2_sch_file->qual[dsfcnt].dqual[10].data_col = "FULL_TABLE_NAME = c30 CCL(FULL_TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[11].data_col =
   "SUFFIXED_TABLE_NAME = c18 CCL(SUFFIXED_TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[12].data_col = "DEFAULT_ROW_IND = i2 CCL(DEFAULT_ROW_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[13].data_col =
   "PERSON_CMB_TRIGGER_TYPE = c10 CCL(PERSON_CMB_TRIGGER_TYPE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[14].data_col =
   "ENCNTR_CMB_TRIGGER_TYPE = c10 CCL(ENCNTR_CMB_TRIGGER_TYPE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[15].data_col = "MERGE_UI_QUERY = c255 CCL(MERGE_UI_QUERY)"
   SET dm2_sch_file->qual[dsfcnt].dqual[16].data_col = "MERGEABLE_IND  = i2 CCL(MERGEABLE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[17].data_col = "MERGE_DELETE_IND = i2 CCL(MERGE_DELETE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[18].data_col = "MERGE_ACTIVE_IND = i2 CCL(MERGE_ACTIVE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[19].data_col = "DATA_DISP_FLAG = i2 CCL(DATA_DISP_FLAG)"
   SET dm2_sch_file->qual[dsfcnt].dqual[20].data_col = "FILLER = c1000 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmcoldoc(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_cd"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMCOLDOC"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "2043"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1983"
   SET dm2_sch_file->qual[dsfcnt].key_size = "60"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 60)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 2
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "TABLE_NAME = c30 CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].kqual[2].key_col = "COLUMN_NAME = c30 CCL(COLUMN_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 19
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "SEQUENCE_NAME = c30 CCL(SEQUENCE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "CODE_SET = i4 CCL(CODE_SET)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "DESCRIPTION = c80 CCL(DESCRIPTION)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col = "DEFINITION = c500 CCL(DEFINITION)"
   SET dm2_sch_file->qual[dsfcnt].dqual[5].data_col = "FLAG_IND = i2 CCL(FLAG_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[6].data_col = "UPDT_CNT = i4 CCL(UPDT_CNT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[7].data_col = "UNIQUE_IDENT_IND = i2 CCL(UNIQUE_IDENT_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[8].data_col = "ROOT_ENTITY_NAME = c30 CCL(ROOT_ENTITY_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[9].data_col = "ROOT_ENTITY_ATTR = c30 CCL(ROOT_ENTITY_ATTR)"
   SET dm2_sch_file->qual[dsfcnt].dqual[10].data_col = "CONSTANT_VALUE = c255 CCL(CONSTANT_VALUE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[11].data_col =
   "PARENT_ENTITY_COL = c30 CCL(PARENT_ENTITY_COL)"
   SET dm2_sch_file->qual[dsfcnt].dqual[12].data_col = "EXCEPTION_FLG = i4 CCL(EXCEPTION_FLG)"
   SET dm2_sch_file->qual[dsfcnt].dqual[13].data_col =
   "DEFINING_ATTRIBUTE_IND = i2 CCL(DEFINING_ATTRIBUTE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[14].data_col =
   "MERGE_UPDATEABLE_IND = i2 CCL(MERGE_UPDATEABLE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[15].data_col = "NLS_COL_IND = i2 CCL(NLS_COL_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[16].data_col =
   "ABSOLUTE_DATE_IND = i2 CCL(ABSOLUTE_DATE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[17].data_col = "MERGE_DELETE_IND = I2 CCL(MERGE_DELETE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[18].data_col = "TZ_RULE_FLAG = I2 CCL(TZ_RULE_FLAG)"
   SET dm2_sch_file->qual[dsfcnt].dqual[19].data_col = "FILLER = c1000 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmtsprec(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_tp"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMTSPREC"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1152"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1118"
   SET dm2_sch_file->qual[dsfcnt].key_size = "34"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 34)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 2
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "TABLE_NAME = c30 CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].kqual[2].key_col = "PRECEDENCE = i4 CCL(PRECEDENCE)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 8
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "DATA_TABLESPACE = c30 CCL(DATA_TABLESPACE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "DATA_EXTENT_SIZE = f8 CCL(DATA_EXTENT_SIZE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "INDEX_TABLESPACE = c30 CCL(INDEX_TABLESPACE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col = "INDEX_EXTENT_SIZE = f8 CCL(INDEX_EXTENT_SIZE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[5].data_col = "LONG_TABLESPACE = c30 CCL(LONG_TABLESPACE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[6].data_col = "LONG_EXTENT_SIZE = f8 CCL(LONG_EXTENT_SIZE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[7].data_col = "UPDT_CNT = i4 CCL(UPDT_CNT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[8].data_col = "FILLER = c1000 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmtspace(dsfcnt)
   SET dm2_sch_file->qual[1].file_suffix = "_ts"
   SET dm2_sch_file->qual[1].table_name = "DMTSPACE"
   SET dm2_sch_file->qual[1].db_name = build(dm2_sch_file->qual[1].table_name,dm2_sch_file->sf_ver)
   SET dm2_sch_file->qual[1].size = "1056"
   SET dm2_sch_file->qual[1].data_size = "1026"
   SET dm2_sch_file->qual[1].key_size = "30"
   SET dm2_sch_file->qual[1].db_key = "unique key 1 (0, 30)"
   SET dm2_sch_file->qual[1].key_cnt = 1
   SET stat = alterlist(dm2_sch_file->qual[1].kqual,dm2_sch_file->qual[1].key_cnt)
   SET dm2_sch_file->qual[1].kqual[1].key_col = "TSPACE_NAME = c30  CCL(TSPACE_NAME)"
   SET dm2_sch_file->qual[1].data_cnt = 4
   SET stat = alterlist(dm2_sch_file->qual[1].dqual,dm2_sch_file->qual[1].data_cnt)
   SET dm2_sch_file->qual[1].dqual[1].data_col = "BYTES_NEEDED = f8  CCL(BYTES_NEEDED)"
   SET dm2_sch_file->qual[1].dqual[2].data_col = "EXT_MGMT = c10 CCL(EXT_MGMT)"
   SET dm2_sch_file->qual[1].dqual[3].data_col = "UPDT_DT_TM = dq8 CCL(UPDT_DT_TM)"
   SET dm2_sch_file->qual[1].dqual[4].data_col = "FILLER = c1000 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsfi_load_schema_files(dlsf_desc,dlsf_process_option)
   DECLARE dlsf_tbl_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlsf_max_tc_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlsf_max_i_cnt = i2 WITH protect, noconstant(0)
   DECLARE dlsf_max_ic_cnt = i2 WITH protect, noconstant(0)
   DECLARE dlsf_max_c_cnt = i2 WITH protect, noconstant(0)
   DECLARE dlsf_max_cc_cnt = i2 WITH protect, noconstant(0)
   DECLARE dlsf_tc_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlsf_ind_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlsf_icol_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlsf_cons_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlsf_ccol_cnt = i4 WITH protect, noconstant(0)
   IF ((cur_sch->tbl_cnt <= 0))
    SET dm_err->eproc = "NO TABLES IN CURRENT SCHEMA"
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "No tables found for the schema snapshot."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   FOR (dlsf_tbl_cnt = 1 TO value(cur_sch->tbl_cnt))
     SET cur_sch->tbl[dlsf_tbl_cnt].capture_ind = 1
   ENDFOR
   SET dm_err->eproc = "POPULATE DMHEADER SCHEMA FILE WITH HEADER INFO"
   CALL disp_msg(" ",dm_err->logfile,0)
   INSERT  FROM dmheader dh
    SET dh.description = dlsf_desc, dh.admin_load_ind = 0, dh.source_rdbms = currdb,
     dh.sf_version = 1
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "POPULATE DMTABLE SCHEMA FILE WITH TABLE INFO"
   CALL disp_msg(" ",dm_err->logfile,0)
   INSERT  FROM dmtable t,
     (dummyt d  WITH seq = value(cur_sch->tbl_cnt))
    SET t.seq = 1, t.table_name = cur_sch->tbl[d.seq].tbl_name, t.tablespace_name = cur_sch->tbl[d
     .seq].tspace_name,
     t.index_tspace = dm2_dft_clin_itspace, t.index_tspace_ni = 0, t.long_tspace = cur_sch->tbl[d.seq
     ].long_tspace,
     t.long_tspace_ni = cur_sch->tbl[d.seq].long_tspace_ni, t.init_ext = cur_sch->tbl[d.seq].init_ext,
     t.next_ext = cur_sch->tbl[d.seq].next_ext,
     t.pct_increase = cur_sch->tbl[d.seq].pct_increase, t.pct_used = cur_sch->tbl[d.seq].pct_used, t
     .pct_free = cur_sch->tbl[d.seq].pct_free,
     t.bytes_allocated = cur_sch->tbl[d.seq].bytes_allocated, t.bytes_used = cur_sch->tbl[d.seq].
     bytes_used, t.schema_date = cur_sch->tbl[d.seq].schema_date,
     t.schema_instance = cur_sch->tbl[d.seq].schema_instance, t.alpha_feature_nbr = 0, t
     .feature_number = 0,
     t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.tspace_type = cur_sch->tbl[d.seq].ext_mgmt, t
     .long_tspace_type = cur_sch->tbl[d.seq].lext_mgmt,
     t.max_ext = cur_sch->tbl[d.seq].max_ext
    PLAN (d
     WHERE (cur_sch->tbl[d.seq].capture_ind=1))
     JOIN (t
     WHERE (cur_sch->tbl[d.seq].tbl_name=t.table_name))
    WITH nocounter, outerjoin = d, dontexist
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "POPULATE DMCOLUMN SCHEMA FILE WITH COLUMN INFO"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(cur_sch->tbl_cnt))
    PLAN (d)
    DETAIL
     IF ((cur_sch->tbl[d.seq].tbl_col_cnt > dlsf_max_tc_cnt))
      dlsf_max_tc_cnt = cur_sch->tbl[d.seq].tbl_col_cnt
     ENDIF
     dlsf_tc_cnt = (dlsf_tc_cnt+ cur_sch->tbl[d.seq].tbl_col_cnt)
    WITH nocounter
   ;end select
   IF (dlsf_max_tc_cnt > 0)
    INSERT  FROM dmcolumn tc,
      (dummyt d  WITH seq = value(cur_sch->tbl_cnt)),
      (dummyt d2  WITH seq = value(dlsf_max_tc_cnt))
     SET tc.seq = 1, tc.table_name = cur_sch->tbl[d.seq].tbl_name, tc.column_name = cur_sch->tbl[d
      .seq].tbl_col[d2.seq].col_name,
      tc.column_seq = cur_sch->tbl[d.seq].tbl_col[d2.seq].col_seq, tc.data_type = cur_sch->tbl[d.seq]
      .tbl_col[d2.seq].data_type, tc.data_length = cur_sch->tbl[d.seq].tbl_col[d2.seq].data_length,
      tc.nullable = cur_sch->tbl[d.seq].tbl_col[d2.seq].nullable, tc.data_default = cur_sch->tbl[d
      .seq].tbl_col[d2.seq].data_default, tc.data_default_ni = cur_sch->tbl[d.seq].tbl_col[d2.seq].
      data_default_ni,
      tc.data_default2 = cur_sch->tbl[d.seq].tbl_col[d2.seq].data_default, tc.virtual_column =
      cur_sch->tbl[d.seq].tbl_col[d2.seq].virtual_column
     PLAN (d
      WHERE (cur_sch->tbl[d.seq].capture_ind=1))
      JOIN (d2
      WHERE (d2.seq <= cur_sch->tbl[d.seq].tbl_col_cnt))
      JOIN (tc
      WHERE (cur_sch->tbl[d.seq].tbl_name=tc.table_name)
       AND (cur_sch->tbl[d.seq].tbl_col[d2.seq].col_name=tc.column_name))
     WITH nocounter, outerjoin = d2, dontexist
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->err_ind = 1
    CALL disp_msg("No column information found for tables.",dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "POPULATE DMINDEX SCHEMA FILE WITH INDEX INFO"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(cur_sch->tbl_cnt))
    PLAN (d)
    DETAIL
     IF ((cur_sch->tbl[d.seq].ind_cnt > dlsf_max_i_cnt))
      dlsf_max_i_cnt = cur_sch->tbl[d.seq].ind_cnt
     ENDIF
     dlsf_ind_cnt = (dlsf_ind_cnt+ cur_sch->tbl[d.seq].ind_cnt)
    WITH nocounter
   ;end select
   IF (dlsf_max_i_cnt > 0)
    INSERT  FROM dmindex i,
      (dummyt d  WITH seq = value(cur_sch->tbl_cnt)),
      (dummyt d2  WITH seq = value(dlsf_max_i_cnt))
     SET i.seq = 1, i.table_name = cur_sch->tbl[d.seq].tbl_name, i.index_name = cur_sch->tbl[d.seq].
      ind[d2.seq].ind_name,
      i.full_ind_name = cur_sch->tbl[d.seq].ind[d2.seq].full_ind_name, i.pct_increase = cur_sch->tbl[
      d.seq].ind[d2.seq].pct_increase, i.pct_free = cur_sch->tbl[d.seq].ind[d2.seq].pct_free,
      i.init_ext = cur_sch->tbl[d.seq].ind[d2.seq].init_ext, i.next_ext = cur_sch->tbl[d.seq].ind[d2
      .seq].next_ext, i.bytes_allocated = cur_sch->tbl[d.seq].ind[d2.seq].bytes_allocated,
      i.bytes_used = cur_sch->tbl[d.seq].ind[d2.seq].bytes_used, i.unique_ind = cur_sch->tbl[d.seq].
      ind[d2.seq].unique_ind, i.tspace_name = cur_sch->tbl[d.seq].ind[d2.seq].tspace_name,
      i.tspace_type = cur_sch->tbl[d.seq].ind[d2.seq].ext_mgmt, i.index_type = cur_sch->tbl[d.seq].
      ind[d2.seq].index_type, i.max_ext = cur_sch->tbl[d.seq].ind[d2.seq].max_ext
     PLAN (d
      WHERE (cur_sch->tbl[d.seq].capture_ind=1))
      JOIN (d2
      WHERE (d2.seq <= cur_sch->tbl[d.seq].ind_cnt))
      JOIN (i
      WHERE (cur_sch->tbl[d.seq].tbl_name=i.table_name)
       AND (cur_sch->tbl[d.seq].ind[d2.seq].ind_name=i.index_name))
     WITH nocounter, outerjoin = d2, dontexist
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "POPULATE DMINDCOL SCHEMA FILE WITH INDEX COLUMN INFO"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     d.seq
     FROM (dummyt d  WITH seq = value(cur_sch->tbl_cnt)),
      (dummyt d2  WITH seq = value(dlsf_max_i_cnt))
     PLAN (d)
      JOIN (d2
      WHERE (d2.seq <= cur_sch->tbl[d.seq].ind_cnt))
     DETAIL
      IF ((cur_sch->tbl[d.seq].ind[d2.seq].ind_col_cnt > dlsf_max_ic_cnt))
       dlsf_max_ic_cnt = cur_sch->tbl[d.seq].ind[d2.seq].ind_col_cnt
      ENDIF
      dlsf_icol_cnt = (dlsf_icol_cnt+ cur_sch->tbl[d.seq].ind[d2.seq].ind_col_cnt)
     WITH nocounter
    ;end select
    IF (dlsf_max_ic_cnt > 0)
     INSERT  FROM dmindcol ic,
       (dummyt d  WITH seq = value(cur_sch->tbl_cnt)),
       (dummyt d2  WITH seq = value(dlsf_max_i_cnt)),
       (dummyt d3  WITH seq = value(dlsf_max_ic_cnt))
      SET ic.seq = 1, ic.table_name = cur_sch->tbl[d.seq].tbl_name, ic.index_name = cur_sch->tbl[d
       .seq].ind[d2.seq].ind_name,
       ic.column_name = cur_sch->tbl[d.seq].ind[d2.seq].ind_col[d3.seq].col_name, ic.column_position
        = cur_sch->tbl[d.seq].ind[d2.seq].ind_col[d3.seq].col_position
      PLAN (d
       WHERE (cur_sch->tbl[d.seq].capture_ind=1))
       JOIN (d2
       WHERE (d2.seq <= cur_sch->tbl[d.seq].ind_cnt))
       JOIN (d3
       WHERE (d3.seq <= cur_sch->tbl[d.seq].ind[d2.seq].ind_col_cnt))
       JOIN (ic
       WHERE (cur_sch->tbl[d.seq].tbl_name=ic.table_name)
        AND (cur_sch->tbl[d.seq].ind[d2.seq].ind_name=ic.index_name)
        AND (cur_sch->tbl[d.seq].ind[d2.seq].ind_col[d3.seq].col_name=ic.column_name))
      WITH nocounter, outerjoin = d3, dontexist
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ELSE
     SET dm_err->err_ind = 1
     CALL disp_msg("No column information found for indexes.",dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "POPULATE DMCONS SCHEMA FILE WITH CONSTRAINT INFO"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(cur_sch->tbl_cnt))
    PLAN (d)
    DETAIL
     IF ((cur_sch->tbl[d.seq].cons_cnt > dlsf_max_c_cnt))
      dlsf_max_c_cnt = cur_sch->tbl[d.seq].cons_cnt
     ENDIF
     dlsf_cons_cnt = (dlsf_cons_cnt+ cur_sch->tbl[d.seq].cons_cnt)
    WITH nocounter
   ;end select
   IF (dlsf_max_c_cnt > 0)
    INSERT  FROM dmcons c,
      (dummyt d  WITH seq = value(cur_sch->tbl_cnt)),
      (dummyt d2  WITH seq = value(dlsf_max_c_cnt))
     SET c.seq = 1, c.table_name = cur_sch->tbl[d.seq].tbl_name, c.constraint_name = cur_sch->tbl[d
      .seq].cons[d2.seq].cons_name,
      c.full_cons_name = cur_sch->tbl[d.seq].cons[d2.seq].full_cons_name, c.constraint_type = cur_sch
      ->tbl[d.seq].cons[d2.seq].cons_type, c.status_ind = cur_sch->tbl[d.seq].cons[d2.seq].status_ind,
      c.r_constraint_name = cur_sch->tbl[d.seq].cons[d2.seq].r_constraint_name, c.parent_table_name
       = cur_sch->tbl[d.seq].cons[d2.seq].parent_table, c.parent_table_columns = cur_sch->tbl[d.seq].
      cons[d2.seq].parent_table_columns,
      c.delete_rule = cur_sch->tbl[d.seq].cons[d2.seq].delete_rule
     PLAN (d
      WHERE (cur_sch->tbl[d.seq].capture_ind=1))
      JOIN (d2
      WHERE (d2.seq <= cur_sch->tbl[d.seq].cons_cnt))
      JOIN (c
      WHERE (cur_sch->tbl[d.seq].tbl_name=c.table_name)
       AND (cur_sch->tbl[d.seq].cons[d2.seq].cons_name=c.constraint_name))
     WITH nocounter, outerjoin = d2, dontexist
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "POPULATE DMCONSCOL SCHEMA FILE WITH CONSTRAINT COLUMN INFO"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     d.seq
     FROM (dummyt d  WITH seq = value(cur_sch->tbl_cnt)),
      (dummyt d2  WITH seq = value(dlsf_max_c_cnt))
     PLAN (d)
      JOIN (d2
      WHERE (d2.seq <= cur_sch->tbl[d.seq].cons_cnt))
     DETAIL
      IF ((cur_sch->tbl[d.seq].cons[d2.seq].cons_col_cnt > dlsf_max_cc_cnt))
       dlsf_max_cc_cnt = cur_sch->tbl[d.seq].cons[d2.seq].cons_col_cnt
      ENDIF
      dlsf_ccol_cnt = (dlsf_ccol_cnt+ cur_sch->tbl[d.seq].cons[d2.seq].cons_col_cnt)
     WITH nocounter
    ;end select
    IF (dlsf_max_cc_cnt > 0)
     INSERT  FROM dmconscol cc,
       (dummyt d  WITH seq = value(cur_sch->tbl_cnt)),
       (dummyt d2  WITH seq = value(dlsf_max_c_cnt)),
       (dummyt d3  WITH seq = value(dlsf_max_cc_cnt))
      SET cc.seq = 1, cc.table_name = cur_sch->tbl[d.seq].tbl_name, cc.constraint_name = cur_sch->
       tbl[d.seq].cons[d2.seq].cons_name,
       cc.column_name = cur_sch->tbl[d.seq].cons[d2.seq].cons_col[d3.seq].col_name, cc.position =
       cur_sch->tbl[d.seq].cons[d2.seq].cons_col[d3.seq].col_position
      PLAN (d
       WHERE (cur_sch->tbl[d.seq].capture_ind=1))
       JOIN (d2
       WHERE (d2.seq <= cur_sch->tbl[d.seq].cons_cnt))
       JOIN (d3
       WHERE (d3.seq <= cur_sch->tbl[d.seq].cons[d2.seq].cons_col_cnt))
       JOIN (cc
       WHERE (cur_sch->tbl[d.seq].tbl_name=cc.table_name)
        AND (cur_sch->tbl[d.seq].cons[d2.seq].cons_name=cc.constraint_name)
        AND (cur_sch->tbl[d.seq].cons[d2.seq].cons_col[d3.seq].col_name=cc.column_name))
      WITH nocounter, outerjoin = d3, dontexist
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ELSE
     SET dm_err->err_ind = 1
     CALL disp_msg("No column information found for constraints.",dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE del_sch_files(null)
   DECLARE dsf_cnt = i4 WITH protect, noconstant(0)
   DECLARE dsf_name = vc WITH protect, noconstant("")
   FOR (dsf_cnt = 1 TO dm2_sch_file->file_cnt)
     SET dsf_name = build(dm2_sch_file->file_prefix,cnvtlower(dm2_sch_file->qual[dsf_cnt].file_suffix
       ))
     IF (del_sch_file(build(dm2_sch_file->dest_dir_osfmt,dsf_name,".dat"))=0)
      SET dm_err->err_ind = 1
      RETURN(0)
     ENDIF
     IF ((dm2_sys_misc->cur_os != "AXP"))
      IF (del_sch_file(build(dm2_sch_file->dest_dir_osfmt,dsf_name,".idx"))=0)
       SET dm_err->err_ind = 1
       RETURN(0)
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
#end_sch_files_inc
 IF (validate(dm2_install_pkg->process_option,"NOT_SET")="NOT_SET")
  RECORD dm2_install_pkg(
    1 process_option = vc
    1 description = vc
    1 source_rdbms = vc
    1 admin_load_ind = i4
    1 num_of_pkgs = i4
  )
  SET dm2_install_pkg->process_option = "NORMAL"
  SET dm2_install_pkg->description = " "
  SET dm2_install_pkg->source_rdbms = " "
  SET dm2_install_pkg->admin_load_ind = - (1)
  SET dm2_install_pkg->num_of_pkgs = 0
 ENDIF
 IF ((validate(dtl_indtype->totindtype_cnt,- (1))=- (1))
  AND (validate(dtl_indtype->totindtype_cnt,- (2))=- (2)))
  FREE RECORD dtl_indtype
  RECORD dtl_indtype(
    1 tot_cnt = i4
    1 qual[*]
      2 tableandindex_name = vc
      2 table_name = vc
      2 index_name = vc
      2 index_type = vc
      2 baseline_schema_instance = i2
  )
  SET dtl_indtype->tot_cnt = 0
 ENDIF
 DECLARE dm2it_load_index_types(null) = i4
 SUBROUTINE dm2it_load_index_types(null)
   SET dm_err->eproc = "Loading override index_types."
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE dlit_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlit_len = i4 WITH protect, noconstant(0)
   DECLARE dlit_colon_pos = i2 WITH protect, noconstant(0)
   DECLARE dlit_error_msg = vc WITH protect, noconstant(" ")
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=concat("DM2_",cnvtupper(trim(currdb)),"_INDEX_TYPE")
     AND di.updt_applctx=1
    ORDER BY di.info_name
    HEAD REPORT
     dlit_cnt = 0
    DETAIL
     CASE (currdb)
      OF "ORACLE":
       IF (di.info_char != "BITMAP")
        dm_err->err_ind = 1, dm_err->emsg = concat("Index Type (",trim(di.info_char,3),
         ") is invalid.  BITMAP is the only valid"," override index type value for Oracle.")
       ENDIF
      OF "SQLSRV":
       IF (di.info_char != "CLUSTERED")
        dm_err->err_ind = 1, dm_err->emsg = concat("Index Type (",trim(di.info_char,3),
         ") is invalid.  CLUSTERED is the only valid"," override index type value for SQL Server.")
       ENDIF
      OF "DB2UDB":
       dm_err->err_ind = 1,dm_err->emsg = "Override index types are not supported currently on DB2."
     ENDCASE
     IF (findstring(":",di.info_name)=0)
      dm_err->err_ind = 1, dm_err->emsg = concat(
       "Invalid format for override index entry from DM_INFO - colon symbol expected in value (",di
       .info_name,").")
     ENDIF
     IF ((dm_err->err_ind=1))
      CALL cancel(1)
     ENDIF
     dlit_cnt = (dlit_cnt+ 1)
     IF (mod(dlit_cnt,50)=1)
      stat = alterlist(dtl_indtype->qual,(dlit_cnt+ 50))
     ENDIF
     dtl_indtype->qual[dlit_cnt].tableandindex_name = cnvtupper(trim(di.info_name,3)), dlit_len =
     textlen(dtl_indtype->qual[dlit_cnt].tableandindex_name), dlit_colon_pos = findstring(":",
      dtl_indtype->qual[dlit_cnt].tableandindex_name),
     dtl_indtype->qual[dlit_cnt].table_name = substring(1,(dlit_colon_pos - 1),dtl_indtype->qual[
      dlit_cnt].tableandindex_name), dtl_indtype->qual[dlit_cnt].index_name = substring((
      dlit_colon_pos+ 1),(dlit_len - dlit_colon_pos),dtl_indtype->qual[dlit_cnt].tableandindex_name),
     dtl_indtype->qual[dlit_cnt].index_type = cnvtupper(trim(di.info_char,3)),
     dtl_indtype->qual[dlit_cnt].baseline_schema_instance = di.info_number
    FOOT REPORT
     stat = alterlist(dtl_indtype->qual,dlit_cnt), dtl_indtype->tot_cnt = dlit_cnt
    WITH nocounter
   ;end select
   IF ((dm_err->err_ind=1))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   RETURN(dtl_indtype->tot_cnt)
 END ;Subroutine
 DECLARE drr_val_write_privs(dvwp_full_dir=vc) = i4
 DECLARE drr_clin_copy_setup(dccs_whereto=vc(ref)) = i2
 DECLARE drr_clin_copy_restart_chk(null) = i2
 DECLARE drr_check_log_for_errors(dclfe_op_id=f8,dclfe_oper_logfile=vc,dclfe_force_load_ind=i2,
  dclfe_err_ind=i2(ref)) = i2
 DECLARE drr_load_mixed_table_data(dlmtd_force_load_ind=i2) = i2
 DECLARE drr_get_dmp_log_loc(dgdll_op_id=f8,dgdll_dmp_loc_out=vc(ref)) = i2
 DECLARE drr_load_ref_table_data(force_load_ind=i2) = i2
 DECLARE drr_get_exp_dmp_loc(dgedl_dmp_loc_out=vc(ref)) = i2
 DECLARE drr_load_preserved_table_data(dlp_source=vc,dlp_file=vc) = i2
 DECLARE drr_prompt_preserve_data(null) = i2
 DECLARE drr_chk_for_preserved_data(dcf_chk_ret=i2(ref)) = i2
 DECLARE drr_display_summary_screen(null) = i2
 DECLARE drr_get_invalid_tables_list(null) = i2
 DECLARE drr_process_invalid_tables(null) = i2
 DECLARE drr_get_dbase_created_date(dgdcd_created_date=f8(ref)) = i2
 DECLARE drr_prompt_schema_date(dpsd_row=i4(ref)) = null
 DECLARE drr_prompt_loc(dpl_row=i4(ref),dpl_type=vc) = i2
 DECLARE drr_get_max_clin_copy_run_id(dgm_run_id=f8(ref)) = i2
 DECLARE drr_get_custom_tables_list(null) = i2
 DECLARE drr_validate_ref_data_link(null) = i2
 DECLARE drr_ads_domain_check(dadc_db_link=vc,dadc_ads_domain_ind=i2(ref)) = i2
 DECLARE drr_prompt_ads_config(dpac_response=c1(ref)) = i2
 DECLARE drr_validate_tgtdblink(dvt_tgt_host=vc,dvt_tgt_ora_ver=i2,dvt_src_host=vc) = i2
 DECLARE drr_validate_adm_env_csv(dvae_path=vc,dvae_src_env=vc) = i2
 DECLARE drr_set_src_env_path(null) = null
 DECLARE drr_confirm_invalid_tables(dcit_manage_opt_ind=i2,dcit_confirm_ret=i2(ref)) = i2
 DECLARE drr_column_and_ccldef_exists(dcce_table_name=vc,dcce_column_name=vc,dcce_exists_ind=i2(ref))
  = i2
 DECLARE drr_identify_was_usage(diwu_domain=vc,diwu_was_ind=i2(ref)) = i2
 DECLARE drr_restore_col_checks(drcc_src=vc,drcc_sti=i4,drcc_sci=i4,drcc_pti=i4,drcc_pci=i4,
  drcc_tti=i4,drcc_tc=i4) = i2
 DECLARE drr_restore_tbl_checks(drtc_src=vc,drtc_sti=i4,drtc_pti=i4) = i2
 DECLARE drr_restore_report(null) = i2
 DECLARE drr_restore_col_mismatch(null) = i2
 DECLARE drr_restore_tbl_mismatch(null) = i2
 DECLARE drr_cleanup_drr_copy(dcdc_drr_cleanup=vc(ref)) = i2
 DECLARE drr_load_chunk_imp_tbls(dlcit_db_link=vc,dlcit_get_chunks_ind=i2) = i2
 DECLARE drr_get_mixtbl_ref_rows(dgmrr_db_name=vc) = i2
 DECLARE drr_upd_mixtbl_ref_rows(dumrr_db_name=vc,dumrr_run_id=i2) = i2
 DECLARE drr_refresh_drop_restrict(drdr_mode=vc,drdr_restart_ind=i2) = i2
 DECLARE drr_drop_user_restrict_ksh(null) = i2
 DECLARE drr_verify_admin_content(dvac_inform_only_ind=i2,dvac_invalid_data_ind=i2(ref)) = i2
 DECLARE drr_add_default_scd_row(null) = i2
 DECLARE drr_verify_custom_users(dvcu_inform_only_ind=i2,dvcu_invalid_cust_user_ind=i2(ref)) = i2
 DECLARE drr_drop_db_link(dddl_link_name=vc) = i2
 DECLARE drr_check_db_link(dcdl_in_db_link_name=vc,dcdl_out_db_link_fnd_ind=i2(ref)) = i2
 DECLARE drr_del_preserved_ts(dcdl_tgt_db_name=vc) = i2
 IF (validate(drr_clin_copy_ddl->dccd_cnt,1)=1
  AND validate(drr_clin_copy_ddl->dccd_cnt,2)=2)
  FREE RECORD drr_clin_copy_ddl
  RECORD drr_clin_copy_ddl(
    1 dccd_cnt = i4
    1 qual[*]
      2 dccd_op_type = vc
      2 dccd_priority = i4
      2 dccd_operation = vc
  )
 ENDIF
 IF (validate(drr_preserved_tables_data->cnt,1)=1
  AND validate(drr_preserved_tables_data->cnt,2)=2)
  FREE RECORD drr_preserved_tables_data
  RECORD drr_preserved_tables_data(
    1 refresh_ind = i2
    1 restore_groups_str = vc
    1 restore_foul = i2
    1 foul_grp_str = vc
    1 res_rep_name = vc
    1 cnt = i4
    1 tbl[*]
      2 table_name = vc
      2 group = vc
      2 table_suffix = vc
      2 prefix = vc
      2 refresh_ind = i2
      2 tgtsch_idx = i4
      2 partial_ind = i2
      2 exp_where_clause = vc
      2 restore_in_phases = i2
      2 extra_src_cols = i2
      2 extra_pre_cols = i2
      2 pres_tbl_not_in_src = i2
      2 restore_foul = i2
      2 reason_cnt = i4
      2 restore_foul_reasons[*]
        3 text = vc
      2 long_cols_exist = i2
      2 col_diff = i2
      2 col_cnt = i4
      2 col[*]
        3 col_name = vc
        3 data_type = vc
        3 data_length = i4
        3 data_default = vc
        3 data_default_ni = i2
        3 nullable = vc
        3 diff_dtype_ind = i2
        3 diff_dlength_ind = i2
        3 diff_nullable_ind = i2
        3 diff_default_ind = i2
  )
  SET drr_preserved_tables_data->cnt = 0
  SET drr_preserved_tables_data->refresh_ind = 0
  SET drr_preserved_tables_data->restore_foul = 0
 ENDIF
 IF (validate(drr_group->cnt,1)=1
  AND validate(drr_group->cnt,2)=2)
  FREE RECORD drr_group
  RECORD drr_group(
    1 cnt = i4
    1 grp[*]
      2 group = vc
      2 restore = i2
      2 prompt_ind = i2
  )
 ENDIF
 IF (validate(drr_retain_db_users->cnt,1)=1
  AND validate(drr_retain_db_users->cnt,2)=2)
  FREE RECORD drr_retain_db_users
  RECORD drr_retain_db_users(
    1 cnt = i4
    1 user[*]
      2 user_name = vc
  )
  SET drr_retain_db_users->cnt = 0
 ENDIF
 IF (validate(drr_cleanup_warnings->cnt,1)=1
  AND validate(drr_cleanup_warnings->cnt,2)=2)
  RECORD drr_cleanup_warnings(
    1 cnt = i4
    1 qual[*]
      2 table_name = vc
      2 message = vc
  )
  SET drr_cleanup_warnings->cnt = 0
 ENDIF
 IF (validate(drr_cleanup_drop_list->cnt,1)=1
  AND validate(drr_cleanup_drop_list->cnt,2)=2)
  RECORD drr_cleanup_drop_list(
    1 list_loaded_ind = i2
    1 cnt = i4
    1 qual[*]
      2 owner = vc
      2 table_name = vc
  )
 ENDIF
 IF (validate(drr_mvdrop_list->cnt,1)=1
  AND validate(drr_mvdrop_list->cnt,2)=2)
  RECORD drr_mvdrop_list(
    1 list_loaded_ind = i2
    1 cnt = i4
    1 qual[*]
      2 owner = vc
      2 mv_name = vc
  )
 ENDIF
 IF (validate(drr_custom_tables->cnt,1)=1
  AND validate(drr_custom_tables->cnt,2)=2)
  RECORD drr_custom_tables(
    1 list_loaded_ind = i2
    1 cnt = i4
    1 qual[*]
      2 owner_table = vc
      2 owner = vc
      2 table_name = vc
  )
 ENDIF
 IF ((validate(drr_ads_ext->table_cnt,- (1))=- (1))
  AND validate(drr_ads_ext->table_cnt,2)=2)
  FREE SET drr_ads_ext
  RECORD drr_ads_ext(
    1 tbl_cnt = i4
    1 sample_percent = i2
    1 config_id = f8
    1 tgt_p_word = vc
    1 tgt_connect_str = vc
    1 tbl[*]
      2 owner = vc
      2 table_name = vc
      2 deldups_ind = i2
      2 dupind_name = vc
      2 pk_col_cnt = i2
      2 pk_col[*]
        3 col_name = vc
      2 col_fnd = i2
      2 object_id = vc
      2 extract_cnt = i4
      2 nomove = i2
      2 move_all = i2
      2 ext[*]
        3 config_extract_id = f8
        3 extract_id = f8
        3 driver_extract_id = f8
        3 table_extract_nbr = i4
        3 table_extract_inst = i4
        3 active_ind = i2
        3 extract_method = vc
        3 apply_where_ind = i2
        3 data_class_type = vc
        3 where_clause = vc
        3 purge_where_clause = vc
        3 expimp_level = i4
        3 driver_table_ind = i2
        3 driver_table_name = vc
        3 driver_keycol_name = vc
        3 expimp_parent_table_name = vc
        3 dupdel_skip_ind = i2
        3 nomove = i2
  )
 ENDIF
 IF (validate(drr_preserve_db_users->cnt,1)=1
  AND validate(drr_preserve_db_users->cnt,2)=2)
  FREE RECORD drr_preserve_db_users
  RECORD drr_preserve_db_users(
    1 cnt = i4
    1 user[*]
      2 user_name = vc
  )
  SET drr_preserve_db_users->cnt = 0
 ENDIF
 IF ((validate(drr_priority_group_matrix->cnt,- (1))=- (1)))
  FREE RECORD drr_priority_group_matrix
  RECORD drr_priority_group_matrix(
    1 cnt = i2
    1 priority_group[*]
      2 group_name = vc
      2 priority_from_range = i4
      2 priority_to_range = i4
      2 group_prefix = c10
  )
  SET drr_priority_group_matrix->cnt = 0
  SET drr_priority_group_matrix->cnt = (drr_priority_group_matrix->cnt+ 1)
  SET stat = alterlist(drr_priority_group_matrix->priority_group,drr_priority_group_matrix->cnt)
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].group_name =
  "EXPORTS"
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].priority_from_range
   = 0
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].priority_to_range = 9
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].group_prefix = "ex"
  SET drr_priority_group_matrix->cnt = (drr_priority_group_matrix->cnt+ 1)
  SET stat = alterlist(drr_priority_group_matrix->priority_group,drr_priority_group_matrix->cnt)
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].group_name =
  "CREATE TABLES"
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].priority_from_range
   = 9
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].priority_to_range =
  100
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].group_prefix = "ct"
  SET drr_priority_group_matrix->cnt = (drr_priority_group_matrix->cnt+ 1)
  SET stat = alterlist(drr_priority_group_matrix->priority_group,drr_priority_group_matrix->cnt)
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].group_name =
  "IMPORTS"
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].priority_from_range
   = 99
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].priority_to_range =
  200
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].group_prefix = "im"
  SET drr_priority_group_matrix->cnt = (drr_priority_group_matrix->cnt+ 1)
  SET stat = alterlist(drr_priority_group_matrix->priority_group,drr_priority_group_matrix->cnt)
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].group_name =
  "CREATE INDEXES"
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].priority_from_range
   = 199
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].priority_to_range =
  400
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].group_prefix = "ci"
  SET drr_priority_group_matrix->cnt = (drr_priority_group_matrix->cnt+ 1)
  SET stat = alterlist(drr_priority_group_matrix->priority_group,drr_priority_group_matrix->cnt)
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].group_name =
  "CREATE CONSTRAINTS"
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].priority_from_range
   = 399
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].priority_to_range =
  500
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].group_prefix = "cc"
  SET drr_priority_group_matrix->cnt = (drr_priority_group_matrix->cnt+ 1)
  SET stat = alterlist(drr_priority_group_matrix->priority_group,drr_priority_group_matrix->cnt)
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].group_name =
  "RUN UTILITIES"
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].priority_from_range
   = 699
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].priority_to_range =
  800
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].group_prefix = "ru"
  SET drr_priority_group_matrix->cnt = (drr_priority_group_matrix->cnt+ 1)
  SET stat = alterlist(drr_priority_group_matrix->priority_group,drr_priority_group_matrix->cnt)
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].group_name =
  "ALL DDL"
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].priority_from_range
   = 0
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].priority_to_range =
  2000
  SET drr_priority_group_matrix->priority_group[drr_priority_group_matrix->cnt].group_prefix = "all"
 ENDIF
 IF (validate(drr_clin_copy_data->temp_location,"-x")="-x"
  AND validate(drr_clin_copy_data->temp_location,"y")="y")
  FREE RECORD drr_clin_copy_data
  RECORD drr_clin_copy_data(
    1 temp_location = vc
    1 ref_par_file_cnt = i2
    1 mixed_tables_parfile_name = vc
    1 ind_mixed_parfile_prefix = vc
    1 exp_all_prefix = vc
    1 imp_all_prefix = vc
    1 exp_ref_prefix = vc
    1 imp_ref_prefix = vc
    1 exp_pts_prefix = vc
    1 imp_pts_prefix = vc
    1 export_rpt_name = vc
    1 import_rpt_name = vc
    1 starting_point = vc
    1 checkpoint_ind = i2
    1 exp_file_prefix = vc
    1 imp_file_prefix = vc
    1 create_truncate_cmds = i2
    1 src_was_ind = i2
    1 src_env_name = vc
    1 src_env_id = f8
    1 tgt_was_ind = i2
    1 tgt_env_name = vc
    1 tgt_db_env_name = vc
    1 tgt_env_id = f8
    1 exp_imp_utility_location = vc
    1 process = vc
    1 preserve_tbl_pre = vc
    1 preserve_sch_dt = vc
    1 summary_screen_issued = i2
    1 src_db_created = f8
    1 tgt_db_created = f8
    1 tgt_mock_env = i2
    1 exp_rdds_prefix = vc
    1 imp_rdds_prefix = vc
    1 standalone_expimp_process = i2
    1 licensed_to_ads = i2
    1 ads_chosen_ind = i2
    1 ads_config_id = f8
    1 ads_name = vc
    1 ads_mod_dt_tm = f8
    1 ads_pct = f8
    1 src_ads_ind = i2
    1 tgt_domain_name = vc
    1 src_domain_name = vc
    1 purge_chosen_ind = i2
    1 ddl_excl_rpt_name = vc
  )
  SET drr_clin_copy_data->process = "DM2NOTSET"
  SET drr_clin_copy_data->preserve_tbl_pre = "dm2_preserve_table"
  SET drr_clin_copy_data->preserve_sch_dt = "02022002"
  SET drr_clin_copy_data->summary_screen_issued = 0
  SET drr_clin_copy_data->temp_location = "DM2NOTSET"
  SET drr_clin_copy_data->ref_par_file_cnt = 0
  SET drr_clin_copy_data->mixed_tables_parfile_name = "dm2_mixed_tables.par"
  SET drr_clin_copy_data->ind_mixed_parfile_prefix = "dm2_mixtbl_"
  SET drr_clin_copy_data->exp_all_prefix = "exp_v500_all"
  SET drr_clin_copy_data->imp_all_prefix = "imp_v500_all"
  SET drr_clin_copy_data->exp_ref_prefix = "exp_v500_ref"
  SET drr_clin_copy_data->imp_ref_prefix = "imp_v500_ref"
  SET drr_clin_copy_data->exp_pts_prefix = "exp_v500_pts"
  SET drr_clin_copy_data->imp_pts_prefix = "imp_v500_pts"
  SET drr_clin_copy_data->exp_file_prefix = "dm2_export"
  SET drr_clin_copy_data->imp_file_prefix = "dm2_import"
  SET drr_clin_copy_data->starting_point = "DM2NOTSET"
  SET drr_clin_copy_data->src_env_name = "DM2NOTSET"
  SET drr_clin_copy_data->tgt_env_name = "DM2NOTSET"
  SET drr_clin_copy_data->tgt_db_env_name = "DM2NOTSET"
  SET drr_clin_copy_data->create_truncate_cmds = 0
  IF (validate(dm2_troubleshoot_replicate,1)=1
   AND validate(dm2_troubleshoot_replicate,2)=2)
   SET drr_clin_copy_data->checkpoint_ind = 0
  ELSE
   SET drr_clin_copy_data->checkpoint_ind = 1
  ENDIF
  SET drr_clin_copy_data->tgt_mock_env = 1
  SET drr_clin_copy_data->exp_rdds_prefix = "exp_v500_rdds"
  SET drr_clin_copy_data->imp_rdds_prefix = "imp_v500_rdds"
  SET drr_clin_copy_data->standalone_expimp_process = 0
  SET drr_clin_copy_data->ads_name = "DM2NOTSET"
  SET drr_clin_copy_data->src_was_ind = 0
  SET drr_clin_copy_data->tgt_was_ind = 0
  SET drr_clin_copy_data->ddl_excl_rpt_name = ""
 ENDIF
 IF (validate(drr_mixed_tables_data->cnt,1)=1
  AND validate(drr_mixed_tables_data->cnt,2)=2)
  FREE RECORD drr_mixed_tables_data
  RECORD drr_mixed_tables_data(
    1 cnt = i4
    1 tbl[*]
      2 table_name = vc
      2 table_suffix = vc
      2 where_clause_cnt = i2
      2 qual[*]
        3 process_type = vc
        3 data_type = vc
        3 where_clause = vc
      2 prefix = vc
      2 num_rows = f8
      2 last_analyzed = dq8
      2 ref_num_rows_set_ind = i2
      2 ref_num_rows = f8
  )
  SET drr_mixed_tables_data->cnt = 0
 ENDIF
 IF (validate(drr_ignored_errors->cnt,1)=1
  AND validate(drr_ignored_errors->cnt,2)=2)
  FREE RECORD drr_ignored_errors
  RECORD drr_ignored_errors(
    1 cnt = i4
    1 drr_ignorable_errfile = vc
    1 qual[*]
      2 error = vc
  )
  SET drr_ignored_errors->cnt = 0
  SET drr_ignored_errors->drr_ignorable_errfile = "dm2_ignorable_errors.dat"
 ENDIF
 IF (validate(drr_errors_encountered->cmd_cnt,1)=1
  AND validate(drr_errors_encountered->cmd_cnt,2)=2)
  FREE RECORD drr_errors_encountered
  RECORD drr_errors_encountered(
    1 cmd_cnt = i4
    1 qual[*]
      2 dee_op_id = f8
      2 error_cnt = i4
      2 logfile_name = vc
      2 force_reset_ind = i2
      2 qual[*]
        3 error = vc
        3 error_desc = vc
  )
  SET drr_errors_encountered->cmd_cnt = 0
 ENDIF
 IF (validate(drr_ref_tables_data->cnt,1)=1
  AND validate(drr_ref_tables_data->cnt,2)=2)
  FREE RECORD drr_ref_tables_data
  RECORD drr_ref_tables_data(
    1 cnt = i4
    1 tbl[*]
      2 table_name = vc
      2 par_group = i2
  )
  SET drr_ref_tables_data->cnt = 0
 ENDIF
 IF (validate(drr_all_tables_data->cnt,1)=1
  AND validate(drr_all_tables_data->cnt,2)=2)
  FREE RECORD drr_all_tables_data
  RECORD drr_all_tables_data(
    1 par_file_cnt = i2
    1 cnt = i4
    1 tbl[*]
      2 table_name = vc
      2 par_group = i2
  )
  SET drr_all_tables_data->cnt = 0
  SET drr_all_tables_data->par_file_cnt = 0
 ENDIF
 IF (validate(drr_rdds_tables_data->cnt,1)=1
  AND validate(drr_rdds_tables_data->cnt,2)=2)
  FREE RECORD drr_rdds_tables_data
  RECORD drr_rdds_tables_data(
    1 par_file_cnt = i2
    1 cnt = i4
    1 tbl[*]
      2 table_name = vc
      2 par_group = i2
  )
  SET drr_rdds_tables_data->cnt = 0
  SET drr_rdds_tables_data->par_file_cnt = 0
 ENDIF
 IF ((validate(drr_env_hist_misc->cnt,- (1))=- (1))
  AND (validate(drr_env_hist_misc->cnt,- (2))=- (2)))
  FREE RECORD drr_env_hist_misc
  RECORD drr_env_hist_misc(
    1 path = vc
    1 summary_file = vc
    1 cnt = i4
    1 qual[*]
      2 table_name = vc
      2 table_alias = vc
      2 csv_file_name = vc
      2 row_count = vc
      2 date = vc
      2 load = i2
  )
  SET drr_env_hist_misc->cnt = 0
  SET drr_env_hist_misc->path = "DM2NOTSET"
  SET drr_env_hist_misc->summary_file = "DM2NOTSET"
 ENDIF
 IF ((validate(drr_retry_imp_data->tbl_cnt,- (1))=- (1))
  AND (validate(drr_retry_imp_data->tbl_cnt,- (2))=- (2)))
  FREE RECORD drr_retry_imp_data
  RECORD drr_retry_imp_data(
    1 create_chunk_cmds = i2
    1 tbl_cnt = i4
    1 tbl[*]
      2 owner = vc
      2 table_name = vc
      2 op_type = vc
  )
 ENDIF
 IF ((validate(drr_chunk_imp_tbls->tbl_cnt,- (1))=- (1))
  AND (validate(drr_chunk_imp_tbls->tbl_cnt,- (2))=- (2)))
  FREE RECORD drr_chunk_imp_tbls
  RECORD drr_chunk_imp_tbls(
    1 tbl_cnt = i4
    1 tbl[*]
      2 owner = vc
      2 table_name = vc
      2 segment_name = vc
      2 part_ind = i2
      2 part_cnt = i4
      2 orig_num_chunks = i4
      2 num_chunks = i4
      2 chunk_cnt = i4
      2 chunks[*]
        3 min_rid = vc
        3 max_rid = vc
  )
 ENDIF
 SUBROUTINE drr_get_dmp_log_loc(dgdll_op_id,dgdll_dmp_loc_out)
   DECLARE dgdll_strt_pt = i4 WITH protect, noconstant(0)
   DECLARE dgdll_end_pt = i4 WITH protect, noconstant(0)
   DECLARE dgdll_str = vc WITH protect, noconstant(" ")
   SET dm_err->eproc = concat("Find logfile for OP_ID:",build(dgdll_op_id))
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm2_ddl_ops_log d
    WHERE d.op_id=dgdll_op_id
    DETAIL
     dgdll_strt_pt = (findstring("log=",d.operation,1)+ 4), dgdll_end_pt = findstring(" ",d.operation,
      dgdll_strt_pt), dgdll_dmp_loc_out = substring(dgdll_strt_pt,(dgdll_end_pt - dgdll_strt_pt),d
      .operation)
     IF ((dm_err->debug_flag > 2))
      CALL echo(d.operation),
      CALL echo(dgdll_strt_pt),
      CALL echo(dgdll_end_pt),
      CALL echo(dgdll_dmp_loc_out)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dgdll_dmp_loc_out = "NOT_VALID_OP_ID"
   ELSE
    IF (dgdll_dmp_loc_out > " ")
     IF (findfile(dgdll_dmp_loc_out)=0)
      SET dgdll_dmp_loc_out = concat("NO_FILE_IN_OS:",dgdll_dmp_loc_out)
     ENDIF
    ELSE
     SET dgdll_dmp_loc_out = "NO_FILE_IN_COMMAND"
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_load_ref_table_data(force_load_ind)
   DECLARE dlrtd_mix_ndx = i4 WITH protect, noconstant(0)
   DECLARE dlrtd_ref_ndx = i4 WITH protect, noconstant(0)
   DECLARE dlrtd_mix = i4 WITH protect, noconstant(0)
   DECLARE dlrtd_ref = i4 WITH protect, noconstant(0)
   IF ((drr_ref_tables_data->cnt > 0)
    AND force_load_ind=0)
    SET dm_err->eproc = "Skipping load of reference table list."
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   IF (drr_load_mixed_table_data(1)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Loading reference table list."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET drr_ref_tables_data->cnt = 0
   SET stat = alterlist(drr_ref_tables_data->tbl,drr_ref_tables_data->cnt)
   SELECT INTO "nl:"
    dut.table_name
    FROM dm_tables_doc dtd,
     dm2_user_tables dut
    PLAN (dtd
     WHERE dtd.table_name=dtd.full_table_name
      AND dtd.reference_ind=1
      AND  NOT ( EXISTS (
     (SELECT
      "x"
      FROM user_mviews um
      WHERE um.mview_name=dut.table_name)))
      AND  NOT (dtd.table_name IN (
     (SELECT DISTINCT
      dt.drr_table_name
      FROM dm_table_relationships dt
      WHERE dt.drr_table_name="*DRR"
       AND dt.drr_flag=1))))
     JOIN (dut
     WHERE dut.table_name=dtd.table_name)
    ORDER BY dut.table_name
    DETAIL
     IF (locateval(dlrtd_mix_ndx,1,value(drr_mixed_tables_data->cnt),dut.table_name,
      drr_mixed_tables_data->tbl[dlrtd_mix_ndx].table_name)=0)
      drr_ref_tables_data->cnt = (drr_ref_tables_data->cnt+ 1)
      IF (mod(drr_ref_tables_data->cnt,2000)=1)
       stat = alterlist(drr_ref_tables_data->tbl,(drr_ref_tables_data->cnt+ 1999))
      ENDIF
      drr_ref_tables_data->tbl[drr_ref_tables_data->cnt].table_name = dut.table_name
     ELSE
      IF ((dm_err->debug_flag > 0))
       CALL echo(concat(trim(dut.table_name),
        " is a mixed table and not loaded into Reference listing."))
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(drr_ref_tables_data->tbl,drr_ref_tables_data->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((validate(dm2_skip_cust_ref_tables,- (1))=- (1))
    AND (validate(dm2_skip_cust_ref_tables,- (2))=- (2)))
    SET dm_err->eproc = "Loading custom reference table list."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_info i,
      dm2_user_tables u
     WHERE i.info_domain="DM2_CUST_REF_TABLES"
      AND i.info_name=u.table_name
     ORDER BY u.table_name
     HEAD REPORT
      dlrtd_mix_ndx = 0, dlrtd_ref_ndx = 0
     DETAIL
      dlrtd_mix = 0, dlrtd_ref = 0, dlrtd_mix = locateval(dlrtd_mix_ndx,1,value(drr_mixed_tables_data
        ->cnt),u.table_name,drr_mixed_tables_data->tbl[dlrtd_mix_ndx].table_name),
      dlrtd_ref = locateval(dlrtd_ref_ndx,1,value(drr_ref_tables_data->cnt),u.table_name,
       drr_ref_tables_data->tbl[dlrtd_ref_ndx].table_name)
      IF (dlrtd_mix=0
       AND dlrtd_ref=0)
       drr_ref_tables_data->cnt = (drr_ref_tables_data->cnt+ 1), stat = alterlist(drr_ref_tables_data
        ->tbl,drr_ref_tables_data->cnt), drr_ref_tables_data->tbl[drr_ref_tables_data->cnt].
       table_name = u.table_name
      ELSEIF (dlrtd_mix > 0)
       IF ((dm_err->debug_flag > 0))
        CALL echo(build("dlrtd_mix = ",dlrtd_mix)),
        CALL echo(build("dlrtd_ref = ",dlrtd_ref)),
        CALL echo(concat(trim(u.table_name),
         " is a mixed table and not loaded into Reference listing."))
       ENDIF
      ELSEIF (dlrtd_ref > 0)
       IF ((dm_err->debug_flag > 0))
        CALL echo(build("dlrtd_mix = ",dlrtd_mix)),
        CALL echo(build("dlrtd_ref = ",dlrtd_ref)),
        CALL echo(concat(trim(u.table_name)," is already in the Reference list."))
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((drr_ref_tables_data->cnt=0))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Checking count of reference tables."
    SET dm_err->emsg = "No reference tables found."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(drr_ref_tables_data)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_check_log_for_errors(dclfe_op_id,dclfe_oper_logfile,dclfe_force_load_ind,
  dclfe_err_ind)
   DECLARE dclfe_ndx = i4 WITH protect, noconstant(0)
   DECLARE dclfe_err_type = vc WITH protect, noconstant("")
   DECLARE dclfe_start = i4 WITH protect, noconstant(0)
   DECLARE dclfe_end = i4 WITH protect, noconstant(0)
   DECLARE dclfe_add_cmd = i2 WITH protect, noconstant(1)
   DECLARE dclfe_err_cnt = i4 WITH protect, noconstant(0)
   DECLARE dclfe_err_str = vc WITH protect, noconstant("")
   DECLARE dclfe_x = i4 WITH protect, noconstant(0)
   DECLARE dclfe_start = i4 WITH protect, noconstant(0)
   DECLARE dclfe_end = i4 WITH protect, noconstant(0)
   DECLARE dclfe_length = i4 WITH protect, noconstant(0)
   DECLARE dclfe_error = vc WITH protect, noconstant(" ")
   DECLARE dclfe_err_msg = vc WITH protect, noconstant("")
   DECLARE dclfe_err_msg_length = i4 WITH protect, noconstant(0)
   IF (dclfe_force_load_ind != 2)
    SET dm_err->eproc = "Check if ignorable errors file exists."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
    ENDIF
    IF (findfile(value(drr_ignored_errors->drr_ignorable_errfile)) > 0)
     SET dm_err->eproc = "Load ignorable errors."
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
     ENDIF
     FREE DEFINE rtl2
     DEFINE rtl2 value(drr_ignored_errors->drr_ignorable_errfile)
     SELECT INTO "nl:"
      FROM rtl2t t
      WHERE t.line > " "
      HEAD REPORT
       drr_ignored_errors->cnt = 0
      DETAIL
       drr_ignored_errors->cnt = (drr_ignored_errors->cnt+ 1)
       IF (mod(drr_ignored_errors->cnt,10)=1)
        stat = alterlist(drr_ignored_errors->qual,(drr_ignored_errors->cnt+ 9))
       ENDIF
       drr_ignored_errors->qual[drr_ignored_errors->cnt].error = trim(t.line)
      FOOT REPORT
       stat = alterlist(drr_ignored_errors->qual,drr_ignored_errors->cnt)
      WITH nocounter
     ;end select
    ENDIF
    IF ((dm_err->debug_flag > 2))
     CALL echorecord(drr_ignored_errors)
    ENDIF
   ENDIF
   IF (((dclfe_force_load_ind=2
    AND dclfe_op_id=0) OR (dclfe_force_load_ind=1)) )
    IF ((dm_err->debug_flag > 0))
     SET dm_err->eproc = "Resetting error structure due to force load ind."
     CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
    ENDIF
    FOR (dclfe_err_cnt = 1 TO size(drr_errors_encountered->qual,5))
      SET stat = alterlist(drr_errors_encountered->qual[dclfe_err_cnt].qual,0)
    ENDFOR
    SET stat = alterlist(drr_errors_encountered->qual,0)
    SET dclfe_err_cnt = 0
    SET drr_errors_encountered->cmd_cnt = 0
   ENDIF
   IF (dclfe_force_load_ind=2
    AND dclfe_op_id > 0)
    SET dm_err->eproc = "Check Operation Error Message from DM2_DDL_OPS_LOG for Errors."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dm2_ddl_ops_log d
     WHERE d.op_id=dclfe_op_id
     DETAIL
      dclfe_err_msg = trim(d.error_msg,3), dclfe_err_msg_length = size(dclfe_err_msg)
      FOR (dclfe_x = 1 TO dclfe_err_msg_length)
        dclfe_start = (findstring("<<<",dclfe_err_msg,dclfe_x)+ 3), dclfe_end = (findstring(">>>",
         dclfe_err_msg,dclfe_x) - 1), dclfe_length = ((dclfe_end - dclfe_start)+ 1)
        IF (((dclfe_x+ 3) > dclfe_err_msg_length))
         dclfe_x = dclfe_err_msg_length
        ELSE
         dclfe_x = (dclfe_end+ 3)
        ENDIF
        dclfe_error = substring(dclfe_start,dclfe_length,dclfe_err_msg)
        IF ((dm_err->debug_flag > 2))
         CALL echo(concat("dclfe_error = ",dclfe_error))
        ENDIF
        dclfe_err_type = "", dclfe_ndx = 0, dclfe_start = 0,
        dclfe_end = 0, dclfe_err_str = ""
        IF (findstring("ORA-",dclfe_error,0) > 0)
         dclfe_err_type = "ORA-"
        ELSEIF (findstring("EXP-",dclfe_error,0) > 0)
         dclfe_err_type = "EXP-"
        ELSEIF (findstring("IMP-",dclfe_error,0) > 0)
         dclfe_err_type = "IMP-"
        ELSEIF (findstring("LRM-",dclfe_error,0) > 0)
         dclfe_err_type = "LRM-"
        ELSEIF (findstring("CER-",dclfe_error,0) > 0)
         dclfe_err_type = "CER-"
        ELSEIF (findstring("UDI-",dclfe_error,0) > 0)
         dclfe_err_type = "UDI-"
        ENDIF
        IF ((dm_err->debug_flag > 2))
         CALL echo(concat("dclfe_err_type = ",dclfe_err_type))
        ENDIF
        IF (dclfe_err_type > "")
         dclfe_start = findstring(dclfe_err_type,dclfe_error,0), dclfe_end = findstring(" ",
          dclfe_error,dclfe_start), dclfe_err_str = substring(dclfe_start,((dclfe_end - dclfe_start)
           - 1),dclfe_error)
         IF (dclfe_add_cmd=1)
          dclfe_err_ind = 1, drr_errors_encountered->cmd_cnt = (drr_errors_encountered->cmd_cnt+ 1),
          stat = alterlist(drr_errors_encountered->qual,drr_errors_encountered->cmd_cnt),
          drr_errors_encountered->qual[drr_errors_encountered->cmd_cnt].logfile_name =
          dclfe_oper_logfile, drr_errors_encountered->qual[drr_errors_encountered->cmd_cnt].dee_op_id
           = dclfe_op_id
          IF (dclfe_err_str="*EXP-00002*"
           AND d.parent_execution_order=1)
           drr_errors_encountered->qual[drr_errors_encountered->cmd_cnt].force_reset_ind = 1
          ENDIF
          dclfe_add_cmd = 0
         ENDIF
         dclfe_ndx = 0
         IF (locateval(dclfe_ndx,1,drr_errors_encountered->qual[drr_errors_encountered->cmd_cnt].
          error_cnt,dclfe_err_str,drr_errors_encountered->qual[drr_errors_encountered->cmd_cnt].qual[
          dclfe_ndx].error)=0)
          dclfe_err_cnt = (dclfe_err_cnt+ 1), drr_errors_encountered->qual[drr_errors_encountered->
          cmd_cnt].error_cnt = dclfe_err_cnt, stat = alterlist(drr_errors_encountered->qual[
           drr_errors_encountered->cmd_cnt].qual,dclfe_err_cnt),
          drr_errors_encountered->qual[drr_errors_encountered->cmd_cnt].qual[dclfe_err_cnt].error =
          dclfe_err_str, drr_errors_encountered->qual[drr_errors_encountered->cmd_cnt].qual[
          dclfe_err_cnt].error_desc = substring(dclfe_end,(size(trim(d.error_msg)) - dclfe_end),
           dclfe_error)
          IF (dclfe_err_str="*EXP-00002*"
           AND d.parent_execution_order=1)
           drr_errors_encountered->qual[drr_errors_encountered->cmd_cnt].force_reset_ind = 1
          ENDIF
         ELSE
          IF ((dm_err->debug_flag > 0))
           CALL echo(concat("Skipped ",dclfe_err_str," because already in list."))
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
     WITH nocounter
    ;end select
    IF ((dm_err->debug_flag > 721))
     CALL echorecord(drr_errors_encountered)
    ENDIF
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ELSEIF (dclfe_force_load_ind != 2)
    SET dm_err->eproc = "Check Operation Logfile for Errors."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
    ENDIF
    FREE DEFINE rtl2
    SET logical dclfe_operlogfile_logical dclfe_oper_logfile
    DEFINE rtl2 "dclfe_operlogfile_logical"
    SELECT INTO "nl:"
     FROM rtl2t t
     WHERE t.line > " "
     DETAIL
      dclfe_err_type = "", dclfe_ndx = 0, dclfe_start = 0,
      dclfe_end = 0, dclfe_err_str = ""
      IF (findstring("ORA-",t.line,0) > 0)
       dclfe_err_type = "ORA-"
      ELSEIF (findstring("EXP-",t.line,0) > 0)
       dclfe_err_type = "EXP-"
      ELSEIF (findstring("IMP-",t.line,0) > 0)
       dclfe_err_type = "IMP-"
      ELSEIF (findstring("LRM-",t.line,0) > 0)
       dclfe_err_type = "LRM-"
      ELSEIF (findstring("LOG FILE NOT FOUND",t.line,0) > 0)
       dclfe_err_type = "OTHER"
      ENDIF
      IF (dclfe_err_type > "")
       IF (dclfe_err_type="OTHER")
        dclfe_err_str = "", dclfe_end = 1
       ELSE
        dclfe_start = findstring(dclfe_err_type,t.line,0), dclfe_end = findstring(" ",t.line,
         dclfe_start), dclfe_err_str = substring(dclfe_start,((dclfe_end - dclfe_start) - 1),t.line)
       ENDIF
       dclfe_ndx = 0
       IF (locateval(dclfe_ndx,1,drr_ignored_errors->cnt,dclfe_err_str,drr_ignored_errors->qual[
        dclfe_ndx].error)=0)
        IF (dclfe_add_cmd=1)
         dclfe_err_ind = 1, drr_errors_encountered->cmd_cnt = (drr_errors_encountered->cmd_cnt+ 1),
         stat = alterlist(drr_errors_encountered->qual,drr_errors_encountered->cmd_cnt),
         drr_errors_encountered->qual[drr_errors_encountered->cmd_cnt].logfile_name =
         dclfe_oper_logfile, drr_errors_encountered->qual[drr_errors_encountered->cmd_cnt].dee_op_id
          = dclfe_op_id, dclfe_add_cmd = 0
        ENDIF
        dclfe_ndx = 0
        IF (locateval(dclfe_ndx,1,drr_errors_encountered->qual[drr_errors_encountered->cmd_cnt].
         error_cnt,dclfe_err_str,drr_errors_encountered->qual[drr_errors_encountered->cmd_cnt].qual[
         dclfe_ndx].error)=0)
         dclfe_err_cnt = (dclfe_err_cnt+ 1), drr_errors_encountered->qual[drr_errors_encountered->
         cmd_cnt].error_cnt = dclfe_err_cnt, stat = alterlist(drr_errors_encountered->qual[
          drr_errors_encountered->cmd_cnt].qual,dclfe_err_cnt),
         drr_errors_encountered->qual[drr_errors_encountered->cmd_cnt].qual[dclfe_err_cnt].error =
         dclfe_err_str, drr_errors_encountered->qual[drr_errors_encountered->cmd_cnt].qual[
         dclfe_err_cnt].error_desc = substring(dclfe_end,(size(trim(t.line)) - dclfe_end),t.line)
        ELSE
         IF ((dm_err->debug_flag > 0))
          CALL echo(concat("Skipped ",dclfe_err_str," because already in list."))
         ENDIF
        ENDIF
       ELSE
        IF ((dm_err->debug_flag > 0))
         CALL echo(concat("Ignored error:",drr_ignored_errors->qual[dclfe_ndx].error," from file:",
          dclfe_oper_logfile))
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF ((dm_err->debug_flag > 721))
     CALL echorecord(drr_errors_encountered)
    ENDIF
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_load_mixed_table_data(dlmtd_force_load_ind)
   DECLARE dlmtd_start = i2 WITH protect, noconstant(0)
   DECLARE dlmtd_end = i2 WITH protect, noconstant(0)
   DECLARE dlmtd_qual_cnt = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Get mixed tables"
   IF ((drr_mixed_tables_data->cnt > 0)
    AND dlmtd_force_load_ind=0)
    RETURN(1)
   ENDIF
   SET drr_mixed_tables_data->cnt = 0
   SET stat = alterlist(drr_mixed_tables_data->tbl,0)
   SELECT INTO "nl:"
    FROM dm_info di,
     dm_user_tables_actual_stats dut,
     dm_tables_doc dtd
    PLAN (di
     WHERE di.info_domain="DM2_MIXED_TABLE-*")
     JOIN (dut
     WHERE di.info_name=dut.table_name)
     JOIN (dtd
     WHERE dut.table_name=dtd.table_name)
    ORDER BY di.info_name
    HEAD di.info_name
     drr_mixed_tables_data->cnt = (drr_mixed_tables_data->cnt+ 1)
     IF (mod(drr_mixed_tables_data->cnt,10)=1)
      stat = alterlist(drr_mixed_tables_data->tbl,(drr_mixed_tables_data->cnt+ 9))
     ENDIF
     drr_mixed_tables_data->tbl[drr_mixed_tables_data->cnt].table_name = di.info_name,
     drr_mixed_tables_data->tbl[drr_mixed_tables_data->cnt].table_suffix = dtd.table_suffix,
     drr_mixed_tables_data->tbl[drr_mixed_tables_data->cnt].prefix = cnvtlower(build(
       drr_clin_copy_data->ind_mixed_parfile_prefix,dtd.table_suffix)),
     dlmtd_qual_cnt = 0, drr_mixed_tables_data->tbl[drr_mixed_tables_data->cnt].num_rows = dut
     .num_rows, drr_mixed_tables_data->tbl[drr_mixed_tables_data->cnt].last_analyzed = dut
     .last_analyzed,
     drr_mixed_tables_data->tbl[drr_mixed_tables_data->cnt].ref_num_rows_set_ind = 0,
     drr_mixed_tables_data->tbl[drr_mixed_tables_data->cnt].ref_num_rows = 0.0
    DETAIL
     dlmtd_qual_cnt = (dlmtd_qual_cnt+ 1)
     IF (mod(dlmtd_qual_cnt,10)=1)
      stat = alterlist(drr_mixed_tables_data->tbl[drr_mixed_tables_data->cnt].qual,(dlmtd_qual_cnt+ 9
       ))
     ENDIF
     drr_mixed_tables_data->tbl[drr_mixed_tables_data->cnt].qual[dlmtd_qual_cnt].where_clause = di
     .info_char, dlmtd_start = 0, dlmtd_end = 0,
     dlmtd_start = (findstring("-",trim(di.info_domain),0)+ 1), dlmtd_end = findstring("-",trim(di
       .info_domain),dlmtd_start,1), drr_mixed_tables_data->tbl[drr_mixed_tables_data->cnt].qual[
     dlmtd_qual_cnt].process_type = substring(dlmtd_start,(dlmtd_end - dlmtd_start),di.info_domain),
     drr_mixed_tables_data->tbl[drr_mixed_tables_data->cnt].qual[dlmtd_qual_cnt].data_type =
     substring((dlmtd_end+ 1),(size(trim(di.info_domain)) - dlmtd_start),trim(di.info_domain))
    FOOT  di.info_name
     stat = alterlist(drr_mixed_tables_data->tbl[drr_mixed_tables_data->cnt].qual,dlmtd_qual_cnt),
     drr_mixed_tables_data->tbl[drr_mixed_tables_data->cnt].where_clause_cnt = dlmtd_qual_cnt
    FOOT REPORT
     stat = alterlist(drr_mixed_tables_data->tbl,drr_mixed_tables_data->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "No Mixed Tables Exist in DM_INFO."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(drr_mixed_tables_data)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_get_exp_dmp_loc(dgedl_dmp_loc_out)
   DECLARE dgedl_strt_pt = i4 WITH protect, noconstant(0)
   DECLARE dgedl_end_pt = i4 WITH protect, noconstant(0)
   DECLARE dgedl_str = vc WITH protect, noconstant(" ")
   DECLARE dgedl_file_delim = vc WITH protect, noconstant(" ")
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgedl_file_delim = "]"
   ELSE
    SET dgedl_file_delim = "/"
   ENDIF
   SET dgedl_dmp_loc_out = "NONE"
   SET dm_err->eproc = "Verify existance of DDL Ops tables in prep for previous exp location check."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM user_tables u
    WHERE u.table_name IN ("DM2_DDL_OPS1", "DM2_DDL_OPS_LOG1")
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual != 2)
    RETURN(1)
   ENDIF
   IF ((drr_clin_copy_data->process="RESTORE")
    AND (dm2_install_schema->run_id=0))
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Check for prior export to grab location."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT
    IF ((drr_clin_copy_data->process="RESTORE")
     AND (dm2_install_schema->run_id > 0))
     FROM dm2_ddl_ops_log d
     WHERE (d.run_id=dm2_install_schema->run_id)
      AND d.op_type="IMPORT*"
      AND d.op_type != "*(REMOTE)*"
    ELSE
     FROM dm2_ddl_ops_log d
     WHERE d.op_type="EXPORT*"
      AND d.op_type != "*(REMOTE)*"
    ENDIF
    INTO "nl:"
    ORDER BY d.run_id DESC
    HEAD d.run_id
     dgedl_strt_pt = (findstring("file=",d.operation,1)+ 5), dgedl_end_pt = findstring(" ",d
      .operation,dgedl_strt_pt), dgedl_str = substring(dgedl_strt_pt,(dgedl_end_pt - dgedl_strt_pt),d
      .operation),
     dgedl_strt_pt = 0, dgedl_end_pt = 0, dgedl_end_pt = findstring(dgedl_file_delim,dgedl_str,1,1),
     dgedl_dmp_loc_out = substring(dgedl_strt_pt,(dgedl_end_pt - dgedl_strt_pt),dgedl_str)
    WITH nocounter, maxqual(d,1)
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dgedl_dmp_loc_out != "NONE")
    IF (findfile(dgedl_dmp_loc_out)=0)
     SET dgedl_dmp_loc_out = "NONE"
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_val_write_privs(dvwp_full_dir)
   DECLARE full_fname = vc WITH protect
   IF (get_unique_file("dm2wrtprvtst",".dat")=0)
    RETURN(0)
   ENDIF
   SET full_fname = build(dvwp_full_dir,cnvtlower(dm_err->unique_fname))
   SELECT INTO value(full_fname)
    d.seq
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     row + 1, "This is a test of writing to ", dvwp_full_dir
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    IF (dm2_push_dcl(concat("del ",dvwp_full_dir,cnvtlower(dm_err->unique_fname),";"))=0)
     RETURN(0)
    ENDIF
   ELSE
    IF (dm2_push_dcl(concat("rm ",dvwp_full_dir,cnvtlower(dm_err->unique_fname)))=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_clin_copy_restart_chk(null)
   DECLARE dccrc_run_id = f8 WITH protect, noconstant(0.0)
   DECLARE dccrc_schema_date = f8 WITH protect, noconstant(0.0)
   DECLARE dccrc_ops_complete = i2 WITH protect, noconstant(0)
   DECLARE dccrc_ops_tbl_fnd = i2 WITH protect, noconstant(0)
   DECLARE dccrc_ops_log_tbl_fnd = i2 WITH protect, noconstant(0)
   DECLARE dccrc_running_ind = i2 WITH protect, noconstant(0)
   DECLARE dccrc_mig_dbx_tab_cnt = i2 WITH protect, noconstant(0)
   IF ((drr_clin_copy_data->starting_point != "DM2NOTSET"))
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Check status of DDL tables"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM user_tables u
    WHERE u.table_name IN ("DM2_DDL_OPS1", "DM2_DDL_OPS_LOG1")
    DETAIL
     IF (u.table_name="DM2_DDL_OPS1")
      dccrc_ops_tbl_fnd = 1
     ELSE
      dccrc_ops_log_tbl_fnd = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dccrc_ops_log_tbl_fnd=1)
    IF (dm2_cleanup_stranded_appl(null)=0)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Get max Clin Copy run id from Target and determine if any are RUNNING."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dm2_ddl_ops_log d
     WHERE d.run_id IN (
     (SELECT
      max(r.run_id)
      FROM dm2_ddl_ops r
      WHERE r.process_option="CLIN COPY*"
       AND (r.run_id > dm2_install_schema->src_run_id)))
      AND d.status="RUNNING"
     DETAIL
      dccrc_running_ind = 1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((drr_clin_copy_data->process="RESTORE"))
    IF (((dccrc_ops_tbl_fnd=0) OR (dccrc_ops_log_tbl_fnd=0)) )
     SET dm_err->emsg = "Error:Missing one or both DDL tables"
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc =
    "Get max Clin Copy run id from Target that is greater than Source Clin Copy run id."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dm2_ddl_ops d
     WHERE d.run_id IN (
     (SELECT
      max(r.run_id)
      FROM dm2_ddl_ops r
      WHERE r.process_option="CLIN COPY*"
       AND (r.run_id > dm2_install_schema->src_run_id)))
     DETAIL
      dccrc_run_id = d.run_id, dccrc_schema_date = d.schema_date
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (curqual=0)
     SET drr_clin_copy_data->starting_point = "FROM_BEGINNING"
     RETURN(1)
    ENDIF
    SET dm_err->eproc = build("Find operations for run id ",dccrc_run_id)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dm2_ddl_ops_log d
     WHERE d.run_id=dccrc_run_id
     DETAIL
      IF (d.status="COMPLETE")
       dccrc_ops_complete = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dccrc_ops_complete=0)
     SET drr_clin_copy_data->starting_point = "FROM_BEGINNING"
     IF (dccrc_running_ind=1)
      SET dm_err->eproc = concat("Replicate to be restarted - (Run Id ",trim(cnvtstring(dccrc_run_id)
        ),").  Checking for RUNNING operations.")
      SET dm_err->emsg = "Cannot start process from beginning, operations still in RUNNING status."
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (curqual > 0)
      SET dm_err->eproc = build("Delete ops for Clin Copy run id ",dccrc_run_id)
      IF ((dm_err->debug_flag > 0))
       CALL disp_msg("",dm_err->logfile,0)
      ENDIF
      DELETE  FROM dm2_ddl_ops_log a
       WHERE a.run_id=dccrc_run_id
       WITH nocounter
      ;end delete
      IF (check_error(dm_err->eproc)=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ELSE
       COMMIT
      ENDIF
     ENDIF
     SET dm_err->eproc = build("Delete from DM2_DDL_OPS for Clin Copy run id ",dm2_install_schema->
      run_id)
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     DELETE  FROM dm2_ddl_ops
      WHERE run_id=dccrc_run_id
      WITH nocounter
     ;end delete
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
     RETURN(1)
    ELSE
     SET drr_clin_copy_data->starting_point = "DDL_EXECUTION"
     SET dm2_install_schema->run_id = dccrc_run_id
     SET dm2_install_schema->schema_prefix = "dm2s"
     SET dm2_install_schema->file_prefix = cnvtalphanum(format(dccrc_schema_date,"MM/DD/YYYY;;D"))
    ENDIF
   ELSEIF ((drr_clin_copy_data->process="PRESERVE"))
    IF (((dccrc_ops_tbl_fnd=0) OR (dccrc_ops_log_tbl_fnd=0)) )
     SET dm_err->emsg = "Error:Missing one or both DDL tables"
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Get Clin Copy-Preserve run id from Target."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dm2_ddl_ops d
     WHERE d.process_option="CLIN COPY-PRESERVE"
     DETAIL
      dccrc_run_id = d.run_id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual > 0
     AND (der_expimp_data->preserve_from_begin=1))
     IF (dccrc_running_ind=1)
      SET dm_err->eproc = concat("Replicate to be restarted - (Run Id ",trim(cnvtstring(dccrc_run_id)
        ),").  Checking for RUNNING operations.")
      SET dm_err->emsg = "Cannot start process from beginning, operations still in RUNNING status."
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = "Delete Clin Copy-Preserve DM2_DDL_OPS_LOG rows."
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     DELETE  FROM dm2_ddl_ops_log d
      WHERE (d.run_id=
      (SELECT
       a.run_id
       FROM dm2_ddl_ops a
       WHERE a.process_option="CLIN COPY-PRESERVE"))
      WITH nocounter
     ;end delete
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
     SET dm_err->eproc = "Delete Clin Copy-Preserve DM2_DDL_OPS rows."
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     DELETE  FROM dm2_ddl_ops d
      WHERE d.process_option="CLIN COPY-PRESERVE"
      WITH nocounter
     ;end delete
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     COMMIT
     SET drr_clin_copy_data->starting_point = "FROM_BEGINNING"
     RETURN(1)
    ELSEIF (curqual > 0
     AND (der_expimp_data->preserve_from_begin=0))
     SET dm2_install_schema->run_id = dccrc_run_id
     SET drr_clin_copy_data->starting_point = "DDL_EXECUTION"
     RETURN(1)
    ELSE
     SET drr_clin_copy_data->starting_point = "FROM_BEGINNING"
     RETURN(1)
    ENDIF
   ELSE
    IF ((drr_clin_copy_data->process="MIGRATION")
     AND validate(dm2_mig_dbx_in_use,- (1))=1)
     SET dm_err->eproc = "Check if DBX tables exist"
     SELECT INTO "nl:"
      dbx_tab_cnt = count(*)
      FROM dba_tables
      WHERE owner="DBX"
       AND table_name="DBX_OPS"
      DETAIL
       dccrc_mig_dbx_tab_cnt = dbx_tab_cnt
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (dccrc_mig_dbx_tab_cnt > 0)
      SET drr_clin_copy_data->starting_point = "DDL_EXECUTION"
      RETURN(1)
     ELSE
      SET drr_clin_copy_data->starting_point = "FROM_BEGINNING"
      RETURN(1)
     ENDIF
    ENDIF
    IF (((dccrc_ops_tbl_fnd=0) OR (dccrc_ops_log_tbl_fnd=0)) )
     SET drr_clin_copy_data->starting_point = "FROM_BEGINNING"
     RETURN(1)
    ELSEIF (dccrc_ops_tbl_fnd=1
     AND dccrc_ops_log_tbl_fnd=0)
     SET drr_clin_copy_data->starting_point = "FROM_BEGINNING"
     RETURN(1)
    ELSEIF (dccrc_ops_tbl_fnd=0
     AND dccrc_ops_log_tbl_fnd=1)
     SET dm_err->emsg = "Error:Only DM2_DDL_OPS_LOG exists"
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (drr_get_max_clin_copy_run_id(dccrc_run_id)=0)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Check for completed operations other than export ops"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SELECT
     IF ((drr_clin_copy_data->process="MIGRATION"))
      FROM dm2_ddl_ops_log d
      WHERE d.run_id=dccrc_run_id
       AND d.op_type="CREATE TABLE"
       AND d.status IN ("COMPLETE", "RUNNING")
     ELSE
      FROM dm2_ddl_ops_log d
      WHERE d.run_id=dccrc_run_id
       AND d.op_type != "*EXPORT*"
       AND d.status IN ("COMPLETE", "RUNNING")
     ENDIF
     INTO "nl:"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET drr_clin_copy_data->starting_point = "FROM_BEGINNING"
     IF (dccrc_running_ind=1)
      SET dm_err->eproc = concat("Replicate to be restarted - (Run Id ",trim(cnvtstring(dccrc_run_id)
        ),").  Checking for RUNNING operations.")
      SET dm_err->emsg = "Cannot start process from beginning, operations still in RUNNING status."
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     RETURN(1)
    ELSE
     SET drr_clin_copy_data->starting_point = "DDL_EXECUTION"
     SET dm2_install_schema->run_id = dccrc_run_id
    ENDIF
   ENDIF
   SET dm_err->eproc = "Check for import ops which have failed (except for expired applid)"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm2_ddl_ops_log d
    WHERE d.run_id=dccrc_run_id
     AND d.op_type="IMPORT*"
     AND d.op_type != "*(REMOTE)*"
     AND d.status="ERROR"
     AND  NOT (substring(1,14,d.error_msg)="Application Id")
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET drr_clin_copy_data->create_truncate_cmds = 1
   ENDIF
   SET dm_err->eproc = "Check for refresh process ddl rows"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm2_ddl_ops_log d
    WHERE d.run_id=dccrc_run_id
     AND d.op_type="*PRESERVED DATA*"
     AND (( NOT (substring(1,14,d.error_msg)="Application Id")) OR (d.error_msg=null))
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET drr_preserved_tables_data->refresh_ind = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_clin_copy_setup(dccs_whereto)
   DECLARE dccs_exp_loc = vc WITH protect, noconstant("")
   DECLARE dccs_src_dbase_name = vc WITH protect, noconstant("")
   DECLARE dccs_log_prefix = vc WITH protect, noconstant("")
   DECLARE dccs_tgt_dbase_name = vc WITH protect, noconstant("")
   DECLARE dccs_ndx = i4 WITH protect, noconstant(0)
   DECLARE dccs_src_created_date = f8 WITH protect, noconstant(0.0)
   DECLARE dccs_tgt_created_date = f8 WITH protect, noconstant(0.0)
   DECLARE dccs_run_id = f8 WITH protect, noconstant(0.0)
   DECLARE dccs_row = i4 WITH protect, noconstant(0)
   DECLARE dccs_admin_dminfo_name = vc WITH protect, noconstant("")
   DECLARE dccs_ads_domain_ind = i2 WITH protect, noconstant(0)
   DECLARE dccs_refresh_row = i4 WITH protect, noconstant(0)
   DECLARE dccs_response = c1 WITH protect, noconstant(" ")
   DECLARE dccs_tgt_host = vc WITH protect, noconstant(" ")
   DECLARE dccs_str = vc WITH protect, noconstant("")
   DECLARE dccs_ret = vc WITH protect, noconstant("")
   DECLARE dccs_slash = vc WITH protect, noconstant("\\")
   DECLARE dccs_file = vc WITH protect, noconstant("")
   DECLARE misc_data_item = vc WITH protect, noconstant("")
   DECLARE misc_data_item_value = vc WITH protect, noconstant("")
   DECLARE dccs_reg_file = vc WITH protect, noconstant("")
   DECLARE dccs_cmd = vc WITH protect, noconstant("")
   DECLARE dccs_restore = vc WITH protect, noconstant("")
   DECLARE dccs_was_ind = i2 WITH protect, noconstant(0)
   DECLARE dccs_src_host = vc WITH protect, noconstant("")
   DECLARE dccs_part_enabled_ind = i2 WITH protect, noconstant(0)
   DECLARE dccs_part_usage_ind = i2 WITH protect, noconstant(0)
   DECLARE dccs_tgt_ora_ver = i2 WITH protect, noconstant(0)
   FREE RECORD dccs_env
   RECORD dccs_env(
     1 env_cnt = i4
     1 qual[*]
       2 env_name = vc
       2 env_id = f8
       2 database_name = vc
   )
   FREE RECORD dccs_data_move
   RECORD dccs_data_move(
     1 cnt = i4
     1 qual[*]
       2 name = vc
       2 desc = vc
   )
   SET dccs_data_move->cnt = 4
   SET stat = alterlist(dccs_data_move->qual,4)
   SET dccs_data_move->qual[1].name = "REF"
   SET dccs_data_move->qual[1].desc = "Reference Data Only"
   SET dccs_data_move->qual[2].name = "ALL"
   SET dccs_data_move->qual[2].desc = "Reference and Activity Data"
   SET dccs_data_move->qual[3].name = "ADS"
   SET dccs_data_move->qual[3].desc = "Reference with Activity Data Sample"
   SET dccs_data_move->qual[4].name = "PRG"
   SET dccs_data_move->qual[4].desc = "Activity Data Purge"
   IF (validate(drrr_responsefile_in_use,0)=1)
    SET dm2_install_schema->cdba_p_word = drrr_rf_data->adm_db_user_pwd
    SET dm2_install_schema->cdba_connect_str = drrr_rf_data->adm_db_cnct_str
    SET dm2_install_schema->src_v500_p_word = drrr_rf_data->src_db_user_pwd
    SET dm2_install_schema->src_v500_connect_str = drrr_rf_data->src_db_cnct_str
    SET drr_clin_copy_data->src_domain_name = drrr_rf_data->src_domain_name
    SET dm2_install_schema->v500_p_word = drrr_rf_data->tgt_db_user_pwd
    SET dm2_install_schema->v500_connect_str = drrr_rf_data->tgt_db_cnct_str
    SET dm2_install_schema->schema_prefix = "dm2s"
    SET dm2_install_schema->file_prefix = cnvtalphanum(drrr_rf_data->tgt_capture_schema_date)
    IF ((drrr_rf_data->tgt_db_copy_type="ALTERNATE"))
     SET dm2_install_schema->data_to_move = "ALL"
     SET drr_clin_copy_data->process = "RESTORE"
    ELSEIF ((drrr_rf_data->tgt_db_copy_type="REFERENCE"))
     SET dm2_install_schema->data_to_move = "REF"
    ELSEIF ((drrr_rf_data->tgt_db_copy_type="ALL"))
     SET dm2_install_schema->data_to_move = "ALL"
    ELSEIF ((drrr_rf_data->tgt_db_copy_type="ADS"))
     SET dm2_install_schema->data_to_move = "ADS"
    ENDIF
    SET drr_clin_copy_data->tgt_env_name = cnvtupper(drrr_rf_data->tgt_env_name)
    SET drr_clin_copy_data->tgt_db_env_name = cnvtupper(drrr_rf_data->tgt_db_env_name)
    SET dm2_install_schema->percent_tspace = drrr_rf_data->tgt_tspace_increase_pct
    IF ((drrr_rf_data->tgt_db_copy_type="ALTERNATE"))
     SET dm2_install_schema->percent_tspace = 10
    ENDIF
    SET drr_clin_copy_data->temp_location = drrr_rf_data->tgt_app_temp_dir
    IF (findstring(drr_clin_copy_data->tgt_env_name,drr_clin_copy_data->temp_location,1,0)=0)
     SET drr_clin_copy_data->temp_location = concat(drr_clin_copy_data->temp_location,cnvtlower(
       drr_clin_copy_data->tgt_env_name),"/")
    ENDIF
    SET dccs_restore = evaluate(drrr_rf_data->tgt_restore_preserve_data,"YES","Y","N")
    SET drr_clin_copy_data->tgt_mock_env = 1
   ENDIF
   SET dm_err->eproc = "ADMIN CONNECTION"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SET dm2_install_schema->dbase_name = "ADMIN"
   SET dm2_install_schema->u_name = "CDBA"
   IF ((drr_clin_copy_data->process="MIGRATION")
    AND validate(dmr_mig_data->adm_cdba_pwd,"DM2NOTSET") != "DM2NOTSET"
    AND validate(dmr_mig_data->adm_cdba_cnct_str,"DM2NOTSET") != "DM2NOTSET")
    SET dm2_install_schema->p_word = dmr_mig_data->adm_cdba_pwd
    SET dm2_install_schema->connect_str = dmr_mig_data->adm_cdba_cnct_str
    EXECUTE dm2_connect_to_dbase "CO"
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    SET dm2_install_schema->cdba_p_word = dm2_install_schema->p_word
    SET dm2_install_schema->cdba_connect_str = dm2_install_schema->connect_str
   ELSEIF ((dm2_install_schema->cdba_p_word != "NONE")
    AND (dm2_install_schema->cdba_connect_str != "NONE"))
    SET dm2_install_schema->p_word = dm2_install_schema->cdba_p_word
    SET dm2_install_schema->connect_str = dm2_install_schema->cdba_connect_str
    EXECUTE dm2_connect_to_dbase "CO"
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ELSE
    SET dm2_force_connect_string = 1
    EXECUTE dm2_connect_to_dbase "PC"
    SET dm2_force_connect_string = 0
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    SET dm2_install_schema->cdba_p_word = dm2_install_schema->p_word
    SET dm2_install_schema->cdba_connect_str = dm2_install_schema->connect_str
   ENDIF
   SET dm_err->eproc = "Populate environemnt listing while connected to admin."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_environment d
    ORDER BY d.environment_id DESC
    DETAIL
     dccs_env->env_cnt = (dccs_env->env_cnt+ 1), stat = alterlist(dccs_env->qual,dccs_env->env_cnt),
     dccs_env->qual[dccs_env->env_cnt].env_name = cnvtupper(d.environment_name),
     dccs_env->qual[dccs_env->env_cnt].env_id = d.environment_id, dccs_env->qual[dccs_env->env_cnt].
     database_name = d.database_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "SOURCE CONNECTION"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SET dm2_install_schema->dbase_name = '"SOURCE"'
   SET dm2_install_schema->u_name = "V500"
   IF ((drr_clin_copy_data->process="MIGRATION")
    AND validate(dmr_mig_data->src_v500_pwd,"DM2NOTSET") != "DM2NOTSET"
    AND validate(dmr_mig_data->src_v500_cnct_str,"DM2NOTSET") != "DM2NOTSET")
    SET dm2_install_schema->p_word = dmr_mig_data->src_v500_pwd
    SET dm2_install_schema->connect_str = dmr_mig_data->src_v500_cnct_str
    EXECUTE dm2_connect_to_dbase "CO"
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    SET dm2_install_schema->src_v500_p_word = dm2_install_schema->p_word
    SET dm2_install_schema->src_v500_connect_str = dm2_install_schema->connect_str
   ELSEIF ((dm2_install_schema->src_v500_p_word != "NONE")
    AND (dm2_install_schema->src_v500_connect_str != "NONE"))
    SET dm2_install_schema->p_word = dm2_install_schema->src_v500_p_word
    SET dm2_install_schema->connect_str = dm2_install_schema->src_v500_connect_str
    EXECUTE dm2_connect_to_dbase "CO"
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ELSE
    SET dm2_force_connect_string = 1
    EXECUTE dm2_connect_to_dbase "PC"
    SET dm2_force_connect_string = 0
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    SET dm2_install_schema->src_v500_p_word = dm2_install_schema->p_word
    SET dm2_install_schema->src_v500_connect_str = dm2_install_schema->connect_str
   ENDIF
   IF ((dm2_db_options->load_ind=0))
    EXECUTE dm2_set_db_options
    IF ((dm_err->err_ind > 0))
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Get source environment_name."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info d,
     dm_environment de
    PLAN (d
     WHERE d.info_domain="DATA MANAGEMENT"
      AND d.info_name="DM_ENV_ID")
     JOIN (de
     WHERE d.info_number=de.environment_id)
    DETAIL
     drr_clin_copy_data->src_env_name = cnvtupper(de.environment_name), drr_clin_copy_data->
     src_env_id = de.environment_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dccs_src_dbase_name = currdbname
   SET dm2_install_schema->src_dbase_name = dccs_src_dbase_name
   IF (drr_get_dbase_created_date(dccs_src_created_date)=0)
    RETURN(0)
   ENDIF
   SET drr_clin_copy_data->src_db_created = dccs_src_created_date
   SET dm_err->eproc = "Get Source node name"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM v$instance v
    DETAIL
     dccs_src_host = v.host_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (drr_get_max_clin_copy_run_id(dccs_run_id)=0)
    RETURN(0)
   ENDIF
   SET dm2_install_schema->src_run_id = dccs_run_id
   SET dm_err->eproc = "Check if source has partitioning option enabled and has partitioned objects."
   CALL disp_msg("",dm_err->logfile,0)
   IF (dpr_identify_partition_usage(1,dccs_part_enabled_ind,dccs_part_usage_ind)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "TARGET CONNECTION."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SET dm2_install_schema->dbase_name = '"TARGET"'
   SET dm2_install_schema->u_name = "V500"
   IF ((drr_clin_copy_data->process="MIGRATION")
    AND validate(dmr_mig_data->tgt_v500_pwd,"DM2NOTSET") != "DM2NOTSET"
    AND validate(dmr_mig_data->tgt_v500_cnct_str,"DM2NOTSET") != "DM2NOTSET")
    SET dm2_install_schema->p_word = dmr_mig_data->tgt_v500_pwd
    SET dm2_install_schema->connect_str = dmr_mig_data->tgt_v500_cnct_str
    EXECUTE dm2_connect_to_dbase "CO"
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    SET dm2_install_schema->v500_p_word = dm2_install_schema->p_word
    SET dm2_install_schema->v500_connect_str = dm2_install_schema->connect_str
   ELSEIF ((dm2_install_schema->v500_p_word != "NONE")
    AND (dm2_install_schema->v500_connect_str != "NONE"))
    SET dm2_install_schema->p_word = dm2_install_schema->v500_p_word
    SET dm2_install_schema->connect_str = dm2_install_schema->v500_connect_str
    EXECUTE dm2_connect_to_dbase "CO"
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ELSE
    SET dm2_force_connect_string = 1
    EXECUTE dm2_connect_to_dbase "PC"
    SET dm2_force_connect_string = 0
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    SET dm2_install_schema->v500_p_word = dm2_install_schema->p_word
    SET dm2_install_schema->v500_connect_str = dm2_install_schema->connect_str
   ENDIF
   SET dm_err->eproc = "Validate Database Connect Information"
   SET dccs_tgt_dbase_name = currdbname
   SET dm2_install_schema->target_dbase_name = dccs_tgt_dbase_name
   IF (dccs_tgt_dbase_name=dccs_src_dbase_name
    AND (validate(dm2_allow_same_db_name,- (1))=- (1)))
    SET message = nowindow
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Source:",dccs_src_dbase_name," and Target:",trim(dccs_tgt_dbase_name),
     " databases may not be the same.")
    SET dm2_install_schema->p_word = "NONE"
    SET dm2_install_schema->v500_p_word = "NONE"
    SET dm2_install_schema->v500_connect_str = "NONE"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (drr_get_dbase_created_date(dccs_tgt_created_date)=0)
    RETURN(0)
   ENDIF
   SET drr_clin_copy_data->tgt_db_created = dccs_tgt_created_date
   SET dccs_tgt_ora_ver = dm2_rdbms_version->level1
   SET dm_err->eproc = concat("Get Target node name")
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM v$instance v
    DETAIL
     dccs_tgt_host = v.host_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dccs_part_usage_ind=1)
    SET dm_err->eproc = "Check if target partitioning option is enabled."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (dpr_identify_partition_usage(0,dccs_part_enabled_ind,dccs_part_usage_ind)=0)
     RETURN(0)
    ENDIF
    IF (dccs_part_enabled_ind=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat(
      "Target partitioning option (v$option) is disabled and Source has partitioned objects. ",
      "Partitioning must be enabled in Target to proceed.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (validate(drrr_responsefile_in_use,0)=1)
    SET dccs_ndx = locateval(dccs_ndx,1,size(dccs_env->qual,5),cnvtupper(drr_clin_copy_data->
      tgt_db_env_name),dccs_env->qual[dccs_ndx].env_name)
    IF (dccs_ndx=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("Unable to obtain environment_id for environment_name:",cnvtupper(
       drr_clin_copy_data->tgt_db_env_name))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     SET drr_clin_copy_data->tgt_env_id = dccs_env->qual[dccs_ndx].env_id
    ENDIF
   ELSE
    SET dm_err->eproc = "Get environment name via environment logical"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SET drr_clin_copy_data->tgt_env_name = cnvtupper(logical("environment"))
    IF ((dm_err->debug_flag=722))
     SET message = nowindow
    ELSE
     SET message = window
    ENDIF
    CALL clear(1,1)
    CALL box(1,1,5,131)
    CALL text(3,8,"Enter TARGET environment name :                  ")
    SET help =
    SELECT INTO "nl:"
     environment_name____________ = dccs_env->qual[d.seq].env_name
     FROM (dummyt d  WITH seq = size(dccs_env->qual,5))
     PLAN (d
      WHERE d.seq > 0)
     WITH nocounter
    ;end select
    SET validate =
    SELECT INTO "nl:"
     dccs_env->qual[d.seq].env_name
     FROM (dummyt d  WITH seq = size(dccs_env->qual,5))
     PLAN (d
      WHERE d.seq > 0)
     WITH nocounter
    ;end select
    CALL accept(3,70,"P(20);CUF"
     WHERE  NOT (curaccept=" "))
    SET drr_clin_copy_data->tgt_db_env_name = dccs_env->qual[curhelp].env_name
    SET drr_clin_copy_data->tgt_env_id = dccs_env->qual[curhelp].env_id
    SET dm2_install_schema->target_dbase_name = dccs_env->qual[curhelp].database_name
    SET validate = off
    SET help = off
    SET message = window
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("drr_clin_copy_data->tgt_env_id = ",drr_clin_copy_data->tgt_env_id))
    CALL echo(build("drr_clin_copy_data->tgt_env_name = ",drr_clin_copy_data->tgt_env_name))
    CALL echo(build("drr_clin_copy_data->src_env_id = ",drr_clin_copy_data->src_env_id))
    CALL echo(build("drr_clin_copy_data->src_env_name = ",drr_clin_copy_data->src_env_name))
    CALL echo(build("drr_clin_copy_data->tgt_db_env_name = ",drr_clin_copy_data->tgt_db_env_name))
   ENDIF
   SET drr_clin_copy_data->standalone_expimp_process = 1
   IF ( NOT ((drr_clin_copy_data->process IN ("MIGRATION", "RESTORE"))))
    IF ((drr_clin_copy_data->standalone_expimp_process=1))
     SET dm2_install_schema->dbase_name = "ADMIN"
     SET dm2_install_schema->u_name = "CDBA"
     SET dm2_install_schema->p_word = dm2_install_schema->cdba_p_word
     SET dm2_install_schema->connect_str = dm2_install_schema->cdba_connect_str
     EXECUTE dm2_connect_to_dbase "CO"
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
     IF (der_manage_admin_data(dm2_install_schema->target_dbase_name,"DM_INFO","S","ALL","")=0)
      RETURN(0)
     ENDIF
     IF ((der_expimp_data->setup_complete_ind=0))
      SET message = nowindow
      SET dm_err->err_ind = 1
      SET dm_err->eproc = "Validating standalone export/import setup work has been completed."
      SET dm_err->emsg = "Setup work not completed for standalone export/import process."
      SET dm2_install_schema->p_word = "NONE"
      SET dm2_install_schema->v500_p_word = "NONE"
      SET dm2_install_schema->v500_connect_str = "NONE"
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET dm2_install_schema->dbase_name = dm2_install_schema->target_dbase_name
     SET dm2_install_schema->u_name = "V500"
     SET dm2_install_schema->p_word = dm2_install_schema->v500_p_word
     SET dm2_install_schema->connect_str = dm2_install_schema->v500_connect_str
     EXECUTE dm2_connect_to_dbase "CO"
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
     IF (drr_validate_ref_data_link(null)=0)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = "Look for ADS license key on Source DM_INFO."
     CALL disp_msg("",dm_err->logfile,0)
     SELECT INTO "nl:"
      FROM dm_info@ref_data_link
      WHERE info_domain="DM2_ADS_REPLICATE"
       AND info_name="LICENSE_KEY"
       AND info_number=214
      DETAIL
       drr_clin_copy_data->licensed_to_ads = 1
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (validate(drrr_responsefile_in_use,0)=1)
      IF ((drr_clin_copy_data->licensed_to_ads=0)
       AND (drrr_rf_data->tgt_db_copy_type="ADS"))
       SET dm_err->emsg = "Database is missing ADS license."
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
    ENDIF
   ELSEIF ((drr_clin_copy_data->process="MIGRATION"))
    SET drr_clin_copy_data->standalone_expimp_process = 0
   ENDIF
   IF ((drr_clin_copy_data->process != "MIGRATION"))
    SET dccs_str = concat(dccs_slash,"environment",dccs_slash,drr_clin_copy_data->tgt_env_name,
     " domain")
    IF (get_unique_file("ddr_get_reg",evaluate(dm2_sys_misc->cur_os,"AXP",".com",".ksh"))=0)
     RETURN(0)
    ELSE
     SET dccs_reg_file = dm_err->unique_fname
    ENDIF
    SET dm_err->eproc = concat("Create file to obtain target registry info:",dccs_reg_file)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SELECT INTO value(dccs_reg_file)
     DETAIL
      IF ((dm2_sys_misc->cur_os="AXP"))
       CALL print(concat("$ mcr cer_exe:lreg -getp ",dccs_str)), row + 1,
       CALL print("$ write sys$output lreg_result"),
       row + 1
      ELSE
       CALL print(concat("$cer_exe/lreg -getp ",dccs_str)), row + 1
      ENDIF
     WITH nocounter, maxcol = 500, format = variable,
      maxrow = 1
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = concat("Operation for registry:",dccs_str)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dccs_cmd = concat("@",dccs_reg_file)
    ELSE
     SET dccs_cmd = concat(". $CCLUSERDIR/",dccs_reg_file)
    ENDIF
    SET dm_err->disp_dcl_err_ind = 0
    SET dccs_no_error = dm2_push_dcl(dccs_cmd)
    IF (dccs_no_error=0)
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ELSE
     IF (parse_errfile(dm_err->errfile)=0)
      RETURN(0)
     ENDIF
     IF ((dm_err->debug_flag > 0))
      CALL echorecord(dm_err)
     ENDIF
    ENDIF
    IF (((findstring("unable",dm_err->errtext,1,1)) OR ((((dm_err->errtext="")) OR (((findstring(
     "key not found",dm_err->errtext,1,1)) OR (findstring("property not found",dm_err->errtext,1,1)
    )) )) )) )
     SET dccs_no_error = 1
     SET dccs_ret = "NOPARMRETURNED"
    ELSE
     SET dccs_ret = dm_err->errtext
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echo(concat("parm_value:",dccs_ret))
    ENDIF
    IF (dccs_no_error=0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (cnvtupper(dccs_ret)="NOPARMRETURNED")
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Retieving domain name for Target environment ",drr_clin_copy_data->
      tgt_env_name)
     SET dm_err->emsg = "Failed to retrieve domain name for Target."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     SET drr_clin_copy_data->tgt_domain_name = cnvtupper(dccs_ret)
    ENDIF
   ENDIF
   IF (drr_clin_copy_restart_chk(null)=0)
    RETURN(0)
   ENDIF
   IF ((drr_clin_copy_data->starting_point="DDL_EXECUTION"))
    SET message = nowindow
    IF ((drr_clin_copy_data->standalone_expimp_process=0))
     SET dm_err->eproc = "Pull directory location for completed export operations"
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     IF (drr_get_exp_dmp_loc(dccs_exp_loc)=0)
      RETURN(0)
     ENDIF
     IF (dccs_exp_loc="NONE"
      AND  NOT ((drr_clin_copy_data->process IN ("RESTORE", "MIGRATION"))))
      SET dm_err->err_ind = 1
      SET dm_err->emsg = "Could not find logfile location for completed export operation."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ELSE
      SET drr_clin_copy_data->temp_location = dccs_exp_loc
     ENDIF
    ENDIF
    SET dm_err->eproc = "Retrieve All stored information from Admin DM_INFO."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dm2_admin_dm_info di
     WHERE di.info_domain="DM2_REPLICATE_DATA"
      AND di.info_name=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,"*")))
     DETAIL
      IF (di.info_name="*DATA_TO_MOVE")
       dm2_install_schema->data_to_move = di.info_char
      ELSEIF (di.info_name="*_TEMP_LOCATION")
       drr_clin_copy_data->temp_location = di.info_char
      ELSEIF (di.info_name="*_PERCENT_TSPACE")
       dm2_install_schema->percent_tspace = cnvtreal(di.info_char)
      ELSEIF (di.info_name="*_SRC_DOMAIN_NAME")
       drr_clin_copy_data->src_domain_name = di.info_char
      ELSEIF (di.info_name="*_RESTORE_PREV_TGT_DATA_IND")
       IF (di.info_char="Y")
        drr_preserved_tables_data->refresh_ind = 1
       ENDIF
      ELSEIF (di.info_name="*_WAS_ARCH_IND")
       IF (di.info_char="Y")
        drr_clin_copy_data->tgt_was_ind = 1
       ENDIF
      ELSEIF (di.info_name="*ADS_CONFIG_NAME")
       drr_clin_copy_data->ads_name = di.info_char, drr_clin_copy_data->ads_mod_dt_tm = di.info_date
      ELSEIF (di.info_name="*ADS_CONFIG_PCT")
       drr_clin_copy_data->ads_pct = di.info_number
      ELSEIF (di.info_name="*ADS_CONFIG_ID")
       drr_clin_copy_data->ads_config_id = di.info_number, drr_clin_copy_data->ads_chosen_ind = 1
      ELSEIF (di.info_name="*ADS_PURGE")
       drr_clin_copy_data->purge_chosen_ind = 1
      ELSEIF (di.info_name="*DDL_EXCL_RPT")
       IF (di.info_number=0)
        drr_clin_copy_data->ddl_excl_rpt_name = di.info_char
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 5))
     CALL echorecord(drr_clin_copy_data)
    ENDIF
    CALL drr_set_src_env_path(null)
    IF ( NOT ((dm2_install_schema->data_to_move IN ("REF", "ALL"))))
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("Invalid DATA_TO_MOVE value ",trim(dm2_install_schema->data_to_move),
      " found in DM2_ADMIN_DM_INFO on Replicate restart.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    RETURN(1)
   ENDIF
   IF (validate(drrr_responsefile_in_use,0)=0)
    SET dm_err->eproc = "Displaying Clin Copy Window"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    IF ((dm_err->debug_flag=722))
     SET message = nowindow
    ELSE
     SET message = window
    ENDIF
    CALL clear(1,1)
    CALL box(1,1,24,131)
   ENDIF
   IF ((drr_clin_copy_data->process="RESTORE"))
    IF (validate(drrr_responsefile_in_use,0)=0)
     CALL text(2,2,"Complete Copy of Clinical Database (Alternate Database Restore Method)")
     CALL text(4,8,"Restore data previously saved from TARGET database (Y/N) : ")
     CALL accept(4,70,"A;cu"," "
      WHERE curaccept IN ("Y", "N"))
     SET dccs_restore = curaccept
     SET dccs_row = 4
     IF (dccs_restore="Y")
      SET dccs_row = (dccs_row+ 2)
      CALL drr_prompt_schema_date(dccs_row)
     ENDIF
     SET dccs_row = (dccs_row+ 2)
     IF (drr_prompt_loc(dccs_row,"IMPORT")=0)
      RETURN(0)
     ENDIF
     SET dm2_install_schema->data_to_move = "ALL"
     SET dm2_install_schema->percent_tspace = 10
     SET dccs_row = (dccs_row+ 2)
     CALL text(dccs_row,8,
      "Subsequent processing should NOT be performed against a production database.")
     SET dccs_row = (dccs_row+ 1)
     CALL text(dccs_row,8,
      "Please confirm that the following database represents a NON-production domain.")
     SET dccs_row = (dccs_row+ 2)
     CALL text(dccs_row,8,"Is the TARGET database a Production domain (Y/N): ")
     CALL accept(dccs_row,70,"A;cu","Y"
      WHERE curaccept IN ("Y", "N"))
     IF (curaccept="Y")
      SET message = nowindow
      SET dm_err->err_ind = 1
      SET dm_err->emsg = "This process should not be against a production database."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ELSEIF ((drr_clin_copy_data->process="MIGRATION"))
    CALL text(2,2,"Create a Copy of a Clinical Database")
    SET dccs_row = 2
    SET dccs_row = (dccs_row+ 2)
    CALL drr_prompt_schema_date(dccs_row)
    SET dm2_install_schema->data_to_move = "ALL"
    SET dccs_row = (dccs_row+ 2)
    IF (validate(dm2_mig_dbx_in_use,- (1)) != 1)
     CALL text(dccs_row,8,"Adjust tablespace size in target by what percent. (i.e. 10 or -10): ")
     SET dm2_install_schema->percent_tspace = 0
     CALL accept(dccs_row,77,"N(3)",dm2_install_schema->percent_tspace
      WHERE (curaccept > - (100))
       AND curaccept < 100)
     SET dm2_install_schema->percent_tspace = cnvtint(curaccept)
     SET drr_clin_copy_data->temp_location = dm2_install_schema->ccluserdir
     SET dccs_restore = "N"
    ENDIF
   ELSE
    IF (validate(drrr_responsefile_in_use,0)=0)
     CALL text(2,2,"Create a Copy of a Clinical Database")
     SET dccs_row = 2
     SET dccs_row = (dccs_row+ 2)
     CALL drr_prompt_schema_date(dccs_row)
     SET dccs_row = (dccs_row+ 2)
     CALL text(dccs_row,8,"Data to move : ")
     IF ((drr_clin_copy_data->licensed_to_ads=1)
      AND (dm2_sys_misc->cur_db_os != "AXP"))
      SET help = pos(1,60,10,70)
      SET help =
      SELECT INTO "nl:"
       value = substring(1,6,dccs_data_move->qual[t.seq].name), description = substring(1,40,
        dccs_data_move->qual[t.seq].desc)
       FROM (dummyt t  WITH seq = value(dccs_data_move->cnt))
       WITH nocounter
      ;end select
      CALL accept(dccs_row,70,"P(6);CSF")
     ELSE
      SET help = fix('REF" - Reference Data Only",ALL" - Reference and Activity Data"')
      CALL accept(dccs_row,70,"P(3);CSF")
     ENDIF
     SET dm2_install_schema->data_to_move = build(cnvtupper(trim(curaccept)))
     SET help = off
    ENDIF
    IF ((dm2_install_schema->data_to_move IN ("ADS", "PRG")))
     IF ((dm2_install_schema->data_to_move="PRG"))
      SET drr_clin_copy_data->purge_chosen_ind = 1
     ENDIF
     SET dm2_install_schema->data_to_move = "ALL"
     SET drr_clin_copy_data->ads_chosen_ind = 1
     IF (drr_ads_domain_check("ref_data_link",dccs_ads_domain_ind)=0)
      RETURN(0)
     ENDIF
     IF (dccs_ads_domain_ind=1)
      IF (validate(drrr_responsefile_in_use,0)=0)
       SET dccs_refresh_row = dccs_row
       SET dccs_row = (dccs_row+ 2)
       CALL text(dccs_row,8,
        "WARNING : The Source database for this Replicate is already a ADS Domain.")
       SET dccs_row = (dccs_row+ 1)
       CALL text(dccs_row,8,"Do you wish to (C)ontinue or (Q)uit?")
       SET dccs_row = (dccs_row+ 4)
       CALL text(dccs_row,8,"Enter 'C' to continue or 'Q' to quit (C or Q) :")
       CALL accept(dccs_row,70,"A;cu"," "
        WHERE curaccept IN ("Q", "C"))
       IF (curaccept="Q")
        SET message = nowindow
        SET dm_err->err_ind = 1
        SET dm_err->emsg =
        "User choose to quit due to Source database for this Replicate is already a ADS Domain."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       CALL clear((dccs_refresh_row+ 2),8,120)
       CALL clear((dccs_refresh_row+ 3),8,120)
       CALL clear(dccs_row,8,120)
       SET dccs_row = dccs_refresh_row
      ELSE
       IF ((drrr_rf_data->src_ads_domain_ind=0))
        SET dm_err->err_ind = 1
        SET dm_err->emsg = "Quit due to Source database for this Replicate is already a ADS Domain."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    IF (validate(drrr_responsefile_in_use,0)=0)
     SET dccs_row = (dccs_row+ 2)
     CALL text(dccs_row,8,"Increase tablespace size in target by what percent : ")
     SET dm2_install_schema->percent_tspace = 10
     CALL accept(dccs_row,70,"9(3)",dm2_install_schema->percent_tspace
      WHERE curaccept > 0
       AND curaccept < 100)
     SET dm2_install_schema->percent_tspace = cnvtint(curaccept)
     SET dccs_row = (dccs_row+ 2)
     IF (drr_prompt_loc(dccs_row,"EXPORT")=0)
      RETURN(0)
     ENDIF
     SET dccs_row = (dccs_row+ 2)
     CALL text(dccs_row,8,"Restore data previously saved from TARGET database (Y/N) : ")
     CALL accept(dccs_row,70,"A;cu"," "
      WHERE curaccept IN ("Y", "N"))
     SET dccs_restore = curaccept
     SET drr_clin_copy_data->tgt_mock_env = 1
    ENDIF
   ENDIF
   IF ((drr_clin_copy_data->process != "MIGRATION"))
    IF ((((drr_clin_copy_data->src_domain_name="")) OR ((drr_clin_copy_data->src_domain_name=
    "DM2NOTSET"))) )
     SET dccs_row = (dccs_row+ 2)
     CALL text(dccs_row,8,"Please enter the SOURCE domain: ")
     CALL accept(dccs_row,40,"P(20);CU"
      WHERE  NOT (curaccept=" "))
     SET drr_clin_copy_data->src_domain_name = curaccept
    ENDIF
   ENDIF
   IF (validate(drrr_responsefile_in_use,0)=0)
    SET dccs_row = (dccs_row+ 2)
    CALL text(dccs_row,8,"Enter 'C' to continue or 'Q' to quit (C or Q) :")
    CALL accept(dccs_row,70,"A;cu",""
     WHERE curaccept IN ("Q", "C"))
    SET dccs_whereto = curaccept
    IF (dccs_whereto="Q")
     SET message = nowindow
     SET dm_err->eproc = "Prompt user for information needed during CLIN COPY process."
     SET dm_err->emsg = "User chose to quit from Information entry screen for CLIN COPY."
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm2_install_schema->dbase_name = dm2_install_schema->src_dbase_name
   SET dm2_install_schema->u_name = "V500"
   SET dm2_install_schema->p_word = dm2_install_schema->src_v500_p_word
   SET dm2_install_schema->connect_str = dm2_install_schema->src_v500_connect_str
   EXECUTE dm2_connect_to_dbase "CO"
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF ((validate(dm2_bypass_was_check,- (1))=- (1)))
    IF (drr_identify_was_usage(drr_clin_copy_data->src_domain_name,dccs_was_ind)=0)
     RETURN(0)
    ENDIF
    SET drr_clin_copy_data->src_was_ind = dccs_was_ind
    SET drr_clin_copy_data->tgt_was_ind = drr_clin_copy_data->src_was_ind
   ENDIF
   IF ((drr_clin_copy_data->ads_chosen_ind=1))
    IF (drr_prompt_ads_config(dccs_response)=0)
     RETURN(0)
    ELSEIF (dccs_response="Q")
     SET message = nowindow
     SET dm_err->eproc = "Prompt user for ADS information needed during CLIN COPY process."
     SET dm_err->emsg = "User chose to quit from Information entry screen for ADS."
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((((drr_clin_copy_data->ads_chosen_ind=1)) OR ((((drr_clin_copy_data->process="MIGRATION")) OR
   ((dm2_rdbms_version->level1 >= 11)
    AND (dm2_install_schema->data_to_move="REF"))) )) )
    IF (drr_validate_tgtdblink(dccs_tgt_host,dccs_tgt_ora_ver,dccs_src_host)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((drr_clin_copy_data->process != "MIGRATION")
    AND validate(dm2_bypass_adm_csv_load,- (1)) != 1)
    SET message = nowindow
    CALL drr_set_src_env_path(null)
    IF (drr_validate_adm_env_csv(drr_env_hist_misc->path,drr_clin_copy_data->src_env_name)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm2_install_schema->dbase_name = "ADMIN"
   SET dm2_install_schema->u_name = "CDBA"
   SET dm2_install_schema->p_word = dm2_install_schema->cdba_p_word
   SET dm2_install_schema->connect_str = dm2_install_schema->cdba_connect_str
   EXECUTE dm2_connect_to_dbase "CO"
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF (((dccs_restore="Y") OR ((drr_retain_db_users->cnt > 0))) )
    IF ((drr_clin_copy_data->standalone_expimp_process=1)
     AND (drr_clin_copy_data->process="RESTORE"))
     IF (der_manage_admin_data(dm2_install_schema->target_dbase_name,"DM_INFO","S","ALL","")=0)
      RETURN(0)
     ENDIF
     IF ((der_expimp_data->setup_complete_ind=0))
      SET message = nowindow
      SET dm_err->err_ind = 1
      SET dm_err->eproc =
      "Validating standalone export/import setup work has been completed to restore data."
      SET dm_err->emsg = "Setup work not completed for standalone export/import process."
      SET dm2_install_schema->p_word = "NONE"
      SET dm2_install_schema->v500_p_word = "NONE"
      SET dm2_install_schema->v500_connect_str = "NONE"
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    IF (dccs_restore="Y")
     IF (drr_prompt_preserve_data(null)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Delete DM2_REPLICATE_DATA for database ",dm2_install_schema->
    target_dbase_name)
   CALL disp_msg("",dm_err->logfile,0)
   DELETE  FROM dm_info di
    WHERE di.info_domain="DM2_REPLICATE_DATA"
     AND di.info_name=patstring(cnvtupper(build(dm2_install_schema->target_dbase_name,"*")))
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Insert DATA_TO_MOVE for database ",dm2_install_schema->
    target_dbase_name)
   CALL disp_msg("",dm_err->logfile,0)
   INSERT  FROM dm_info di
    SET di.info_domain = "DM2_REPLICATE_DATA", di.info_name = patstring(cnvtupper(build(
        dm2_install_schema->target_dbase_name,"_DATA_TO_MOVE"))), di.info_char = cnvtstring(
      dm2_install_schema->data_to_move)
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Insert TEMP_DIRECTORY for database ",dm2_install_schema->
    target_dbase_name)
   CALL disp_msg("",dm_err->logfile,0)
   INSERT  FROM dm_info di
    SET di.info_domain = "DM2_REPLICATE_DATA", di.info_name = patstring(cnvtupper(build(
        dm2_install_schema->target_dbase_name,"_TEMP_LOCATION"))), di.info_char = cnvtstring(
      drr_clin_copy_data->temp_location)
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Insert PERCENT_TSPACE for database ",dm2_install_schema->
    target_dbase_name)
   CALL disp_msg("",dm_err->logfile,0)
   INSERT  FROM dm_info di
    SET di.info_domain = "DM2_REPLICATE_DATA", di.info_name = patstring(cnvtupper(build(
        dm2_install_schema->target_dbase_name,"_PERCENT_TSPACE"))), di.info_char = cnvtstring(
      dm2_install_schema->percent_tspace)
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Inserting Restore Previous Target Data Indicator row into Admin dm_info."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   INSERT  FROM dm_info di
    SET di.info_domain = "DM2_REPLICATE_DATA", di.info_name = patstring(cnvtupper(build(
        dm2_install_schema->target_dbase_name,"_RESTORE_PREV_TGT_DATA_IND"))), di.info_char =
     cnvtstring(dccs_restore)
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Inserting Restore Groups row into Admin dm_info."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   INSERT  FROM dm_info di
    SET di.info_domain = "DM2_REPLICATE_DATA", di.info_name = patstring(cnvtupper(build(
        dm2_install_schema->target_dbase_name,"_RESTORE_GROUPS_STR"))), di.info_char =
     drr_preserved_tables_data->restore_groups_str
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Inserting Source Domain Name row into Admin dm_info."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   INSERT  FROM dm_info di
    SET di.info_domain = "DM2_REPLICATE_DATA", di.info_name = patstring(cnvtupper(build(
        dm2_install_schema->target_dbase_name,"_SRC_DOMAIN_NAME"))), di.info_char = cnvtstring(
      drr_clin_copy_data->src_domain_name)
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Inserting WAS Architecture Indicator row into Admin dm_info."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   INSERT  FROM dm_info di
    SET di.info_domain = "DM2_REPLICATE_DATA", di.info_name = patstring(cnvtupper(build(
        dm2_install_schema->target_dbase_name,"_WAS_ARCH_IND"))), di.info_char = evaluate(
      drr_clin_copy_data->tgt_was_ind,1,"Y","N")
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   IF ((drr_clin_copy_data->ads_chosen_ind=1))
    SET dm_err->eproc = concat("Insert CONFIG_NAME for database ",dm2_install_schema->
     target_dbase_name)
    CALL disp_msg("",dm_err->logfile,0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_REPLICATE_DATA", di.info_name = patstring(cnvtupper(build(
         dm2_install_schema->target_dbase_name,"_ADS_CONFIG_NAME"))), di.info_char = cnvtstring(
       drr_clin_copy_data->ads_name),
      di.info_date = cnvtdatetime(drr_clin_copy_data->ads_mod_dt_tm)
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = concat("Insert CONFIG_ID for database ",dm2_install_schema->target_dbase_name
     )
    CALL disp_msg("",dm_err->logfile,0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_REPLICATE_DATA", di.info_name = patstring(cnvtupper(build(
         dm2_install_schema->target_dbase_name,"_ADS_CONFIG_ID"))), di.info_number =
      drr_clin_copy_data->ads_config_id
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = concat("Insert CONFIG_PCT for database ",dm2_install_schema->
     target_dbase_name)
    CALL disp_msg("",dm_err->logfile,0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_REPLICATE_DATA", di.info_name = patstring(cnvtupper(build(
         dm2_install_schema->target_dbase_name,"_ADS_CONFIG_PCT"))), di.info_number =
      drr_clin_copy_data->ads_pct
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((drr_clin_copy_data->purge_chosen_ind=1))
    SET dm_err->eproc = concat("Insert ADS Purge indicator for database ",dm2_install_schema->
     target_dbase_name)
    CALL disp_msg("",dm_err->logfile,0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_REPLICATE_DATA", di.info_name = patstring(cnvtupper(build(
         dm2_install_schema->target_dbase_name,"_ADS_PURGE")))
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((drr_clin_copy_data->process != "DM2NOTSET"))
    SET dm_err->eproc = concat("Insert PROCESS NAME for database ",dm2_install_schema->
     target_dbase_name)
    CALL disp_msg("",dm_err->logfile,0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_REPLICATE_DATA", di.info_name = patstring(cnvtupper(build(
         dm2_install_schema->target_dbase_name,"_PROCESS"))), di.info_char = drr_clin_copy_data->
      process
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   COMMIT
   SET dm2_install_schema->dbase_name = dm2_install_schema->target_dbase_name
   SET dm2_install_schema->u_name = "V500"
   SET dm2_install_schema->p_word = dm2_install_schema->v500_p_word
   SET dm2_install_schema->connect_str = dm2_install_schema->v500_connect_str
   EXECUTE dm2_connect_to_dbase "CO"
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(dm2_install_schema)
    CALL echorecord(drr_clin_copy_data)
   ENDIF
   SET dm_err->eproc = "Prompt user to confirm summary screen."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   IF (validate(drrr_responsefile_in_use,0)=0)
    IF (drr_display_summary_screen(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET message = nowindow
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_prompt_schema_date(dpsd_row)
   DECLARE dpsd_sch_date_str = vc WITH protect, noconstant("")
   CALL text(dpsd_row,8,"Enter schema date to use to capture source (in mm-dd-yyyy format ) :  ")
   SET dpsd_row = (dpsd_row+ 1)
   CALL text(dpsd_row,17,"* Do not choose date older than 30 days")
   SET dpsd_sch_date_str = "  -  -    "
   CALL accept((dpsd_row - 1),81,"NNDNNDNNNN;C",dpsd_sch_date_str
    WHERE format(cnvtdate(cnvtalphanum(curaccept)),"MM-DD-YYYY;;D")=curaccept
     AND datetimeadd(cnvtdatetime(format(cnvtdate2(curaccept,"MM-DD-YYYY"),"DD-MMM-YYYY;;D")),30) >=
    cnvtdatetime(curdate,curtime3))
   SET dpsd_sch_date_str = curaccept
   SET dm2_install_schema->schema_prefix = "dm2s"
   SET dm2_install_schema->file_prefix = cnvtalphanum(dpsd_sch_date_str)
 END ;Subroutine
 SUBROUTINE drr_prompt_loc(dpl_row,dpl_type)
   DECLARE dpl_file_delim = vc WITH protect, noconstant("")
   DECLARE dpl_exp_loc = vc WITH protect, noconstant("")
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dpl_file_delim = "]"
   ELSE
    SET dpl_file_delim = "/"
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(dpl_file_delim)
   ENDIF
   CALL text(dpl_row,8,"Enter Temporary Directory for Replicate/Refresh : ")
   IF (dpl_type="IMPORT")
    SET dm_err->eproc = "Get Import Location."
   ELSEIF (dpl_type="EXPORT")
    SET dm_err->eproc = "Get Export Location."
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (dpl_type="IMPORT"
    AND (dm2_install_schema->run_id=0))
    SET dpl_exp_loc = "NONE"
   ELSE
    IF (drr_get_exp_dmp_loc(dpl_exp_loc)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dpl_exp_loc="NONE")
    SET drr_clin_copy_data->temp_location = ""
   ELSE
    SET drr_clin_copy_data->temp_location = dpl_exp_loc
   ENDIF
   SET dpl_row = (dpl_row+ 1)
   IF ((dm2_sys_misc->cur_os="AXP"))
    CALL accept(dpl_row,8,"P(90);C",drr_clin_copy_data->temp_location
     WHERE  NOT (curaccept="")
      AND findstring(dpl_file_delim,trim(curaccept),1,1)=size(trim(curaccept)))
   ELSE
    CALL accept(dpl_row,8,"P(90);C",drr_clin_copy_data->temp_location
     WHERE  NOT (curaccept="")
      AND substring(1,1,curaccept)="/")
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET drr_clin_copy_data->temp_location = curaccept
   ELSE
    IF (findstring(dpl_file_delim,trim(curaccept),1,1) != size(trim(curaccept)))
     SET drr_clin_copy_data->temp_location = concat(trim(curaccept),dpl_file_delim)
    ELSE
     SET drr_clin_copy_data->temp_location = curaccept
    ENDIF
   ENDIF
   IF (dpl_type="IMPORT")
    SET dm_err->eproc = "Validate Import Location."
   ELSEIF (dpl_type="EXPORT")
    SET dm_err->eproc = "Validate Export Location."
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
    CALL echo(curaccept)
   ENDIF
   IF (findfile(trim(curaccept))=0)
    CALL clear(1,1)
    SET message = nowindow
    SET dm_err->emsg = concat("The Export Location:",drr_clin_copy_data->temp_location,
     " was not found.")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (drr_val_write_privs(drr_clin_copy_data->temp_location)=0)
    SET message = nowindow
    SET dm_err->user_action = concat("Please log in as a user that has full privileges to ",
     drr_clin_copy_data->temp_location)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_load_preserved_table_data(dlp_source,dlp_file)
   DECLARE dlp_locate_var = i4 WITH protect, noconstant(0)
   DECLARE dlp_grpname = vc WITH protect, noconstant(" ")
   DECLARE dlp_excl_autotester = i2 WITH protect, noconstant(0)
   DECLARE dlp_excl_file = vc WITH protect, noconstant(" ")
   DECLARE dlp_cnt = i4 WITH protect, noconstant(0)
   FREE RECORD dlp_excl_tbl
   RECORD dlp_excl_tbl(
     1 tbl_cnt = i4
     1 qual[*]
       2 table_name = vc
       2 grpname = vc
   )
   SET dlp_excl_tbl->tbl_cnt = 0
   FREE RECORD dlp_tmp_data
   RECORD dlp_tmp_data(
     1 cnt = i4
     1 tbl[*]
       2 table_name = vc
       2 group = vc
       2 table_suffix = vc
       2 prefix = vc
       2 partial_ind = i2
       2 exp_where_clause = vc
       2 excl_ind = i2
   )
   SET drr_preserved_tables_data->cnt = 0
   SET drr_preserved_tables_data->refresh_ind = 0
   SET stat = alterlist(drr_preserved_tables_data->tbl,0)
   IF (dlp_source="TABLE")
    IF (dpr_sub_ddl_excl(" ")=0)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Verifying dm_info rows for preserved tables exist"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DM2_PRESERVED_TABLE-*"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg =
     "DM_INFO rows for preserved tables are NOT present. Verify that readme 3932 has been run"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Load specific tables that are to be preserved on a Refresh."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    IF ((dpr_obj_list->tbl_cnt=0))
     SELECT INTO "nl:"
      FROM dm_info di,
       dm_tables_doc dtd,
       dm2_user_tables u
      PLAN (di
       WHERE di.info_domain="DM2_PRESERVED_TABLE-*"
        AND di.info_number=1)
       JOIN (dtd
       WHERE di.info_name=dtd.table_name)
       JOIN (u
       WHERE dtd.table_name=u.table_name)
      ORDER BY di.info_name
      HEAD REPORT
       pos = 0, pos = findstring("-",di.info_domain)
      HEAD di.info_name
       drr_preserved_tables_data->cnt = (drr_preserved_tables_data->cnt+ 1)
       IF (mod(drr_preserved_tables_data->cnt,10)=1)
        stat = alterlist(drr_preserved_tables_data->tbl,(drr_preserved_tables_data->cnt+ 9))
       ENDIF
       drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].group = substring((pos+ 1),size
        (di.info_domain),di.info_domain), drr_preserved_tables_data->tbl[drr_preserved_tables_data->
       cnt].table_name = di.info_name, drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt]
       .table_suffix = dtd.table_suffix,
       drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].prefix = cnvtlower(build(
         drr_clin_copy_data->preserve_tbl_pre,dtd.table_suffix)), drr_preserved_tables_data->tbl[
       drr_preserved_tables_data->cnt].refresh_ind = 0
       IF (di.info_char > " ")
        drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].partial_ind = 1,
        drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].exp_where_clause = di
        .info_char
       ENDIF
      FOOT REPORT
       stat = alterlist(drr_preserved_tables_data->tbl,drr_preserved_tables_data->cnt)
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ELSE
     SELECT INTO "nl:"
      FROM dm_info di,
       dm_tables_doc dtd,
       dm2_user_tables u
      PLAN (di
       WHERE di.info_domain="DM2_PRESERVED_TABLE-*"
        AND di.info_number=1)
       JOIN (dtd
       WHERE di.info_name=dtd.table_name)
       JOIN (u
       WHERE dtd.table_name=u.table_name)
      ORDER BY di.info_name
      HEAD REPORT
       pos = 0, pos = findstring("-",di.info_domain)
      HEAD di.info_name
       dpl_grpname = substring((pos+ 1),size(di.info_domain),di.info_domain), dlp_locate_var = 0,
       dlp_locate_var = locateval(dlp_locate_var,1,dpr_obj_list->tbl_cnt,di.info_name,dpr_obj_list->
        obj_tbl[dlp_locate_var].dpr_tbl)
       IF (dlp_locate_var > 0)
        dlp_excl_tbl->tbl_cnt = (dlp_excl_tbl->tbl_cnt+ 1), stat = alterlist(dlp_excl_tbl->qual,
         dlp_excl_tbl->tbl_cnt), dlp_excl_tbl->qual[dlp_excl_tbl->tbl_cnt].table_name = di.info_name,
        dlp_excl_tbl->qual[dlp_excl_tbl->tbl_cnt].grpname = dpl_grpname
       ENDIF
       dlp_tmp_data->cnt = (dlp_tmp_data->cnt+ 1)
       IF (mod(dlp_tmp_data->cnt,10)=1)
        stat = alterlist(dlp_tmp_data->tbl,(dlp_tmp_data->cnt+ 9))
       ENDIF
       dlp_tmp_data->tbl[dlp_tmp_data->cnt].group = dpl_grpname, dlp_tmp_data->tbl[dlp_tmp_data->cnt]
       .table_name = di.info_name, dlp_tmp_data->tbl[dlp_tmp_data->cnt].table_suffix = dtd
       .table_suffix,
       dlp_tmp_data->tbl[dlp_tmp_data->cnt].prefix = cnvtlower(build(drr_clin_copy_data->
         preserve_tbl_pre,dtd.table_suffix))
       IF (di.info_char > " ")
        dlp_tmp_data->tbl[dlp_tmp_data->cnt].partial_ind = 1, dlp_tmp_data->tbl[dlp_tmp_data->cnt].
        exp_where_clause = di.info_char
       ENDIF
       dlp_tmp_data->tbl[dlp_tmp_data->cnt].excl_ind = 0
      FOOT REPORT
       stat = alterlist(dlp_tmp_data->tbl,dlp_tmp_data->cnt)
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     FOR (dlp_cnt = 1 TO dlp_tmp_data->cnt)
       SET dlp_locate_var = 0
       SET dlp_locate_var = locateval(dlp_locate_var,1,dlp_excl_tbl->tbl_cnt,dlp_tmp_data->tbl[
        dlp_cnt].group,dlp_excl_tbl->qual[dlp_locate_var].grpname)
       IF (dlp_locate_var=0)
        SET drr_preserved_tables_data->cnt = (drr_preserved_tables_data->cnt+ 1)
        IF (mod(drr_preserved_tables_data->cnt,10)=1)
         SET stat = alterlist(drr_preserved_tables_data->tbl,(drr_preserved_tables_data->cnt+ 9))
        ENDIF
        SET drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].group = dlp_tmp_data->tbl[
        dlp_cnt].group
        SET drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].table_name = dlp_tmp_data
        ->tbl[dlp_cnt].table_name
        SET drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].table_suffix =
        dlp_tmp_data->tbl[dlp_cnt].table_suffix
        SET drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].prefix = dlp_tmp_data->
        tbl[dlp_cnt].prefix
        SET drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].refresh_ind = 0
        SET drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].partial_ind = dlp_tmp_data
        ->tbl[dlp_cnt].partial_ind
        SET drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].exp_where_clause =
        dlp_tmp_data->tbl[dlp_cnt].exp_where_clause
       ELSE
        SET dlp_tmp_data->tbl[dlp_cnt].excl_ind = 1
       ENDIF
     ENDFOR
     SET stat = alterlist(drr_preserved_tables_data->tbl,drr_preserved_tables_data->cnt)
     SET dm_err->eproc = "Load partitioned AutoTester table."
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     SELECT INTO "nl:"
      FROM dm_tables_doc dtd,
       dm2_user_tables u
      PLAN (dtd
       WHERE dtd.table_name=dtd.full_table_name
        AND dtd.data_model_section="AUTOTESTER")
       JOIN (u
       WHERE dtd.table_name=u.table_name)
      ORDER BY dtd.table_name
      DETAIL
       dlp_locate_var = 0, dlp_locate_var = locateval(dlp_locate_var,1,dpr_obj_list->tbl_cnt,dtd
        .table_name,dpr_obj_list->obj_tbl[dlp_locate_var].dpr_tbl)
       IF (dlp_locate_var > 0)
        dlp_excl_tbl->tbl_cnt = (dlp_excl_tbl->tbl_cnt+ 1), stat = alterlist(dlp_excl_tbl->qual,
         dlp_excl_tbl->tbl_cnt), dlp_excl_tbl->qual[dlp_excl_tbl->tbl_cnt].table_name = dtd
        .table_name,
        dlp_excl_tbl->qual[dlp_excl_tbl->tbl_cnt].grpname = "AUTOTESTER", dlp_excl_autotester = 1
       ENDIF
       dlp_tmp_data->cnt = (dlp_tmp_data->cnt+ 1), stat = alterlist(dlp_tmp_data->tbl,dlp_tmp_data->
        cnt), dlp_tmp_data->tbl[dlp_tmp_data->cnt].group = "AUTOTESTER",
       dlp_tmp_data->tbl[dlp_tmp_data->cnt].table_name = dtd.table_name
      FOOT REPORT
       stat = alterlist(dlp_tmp_data->tbl,dlp_tmp_data->cnt)
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    IF (dlp_excl_autotester=0)
     SET dm_err->eproc = "Load the group of tables that are used by AutoTester."
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     SELECT INTO "nl:"
      FROM dm_tables_doc dtd,
       dm2_user_tables u
      PLAN (dtd
       WHERE dtd.table_name=dtd.full_table_name
        AND dtd.data_model_section="AUTOTESTER")
       JOIN (u
       WHERE dtd.table_name=u.table_name)
      ORDER BY dtd.table_name
      DETAIL
       drr_preserved_tables_data->cnt = (drr_preserved_tables_data->cnt+ 1), stat = alterlist(
        drr_preserved_tables_data->tbl,drr_preserved_tables_data->cnt), drr_preserved_tables_data->
       tbl[drr_preserved_tables_data->cnt].table_name = dtd.table_name,
       drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].group = dtd.data_model_section,
       drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].table_suffix = dtd.table_suffix,
       drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].prefix = cnvtlower(build(
         drr_clin_copy_data->preserve_tbl_pre,dtd.table_suffix)),
       drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].refresh_ind = 0
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ELSEIF (dlp_excl_autotester=1)
     SET dm_err->eproc = "Set preserve exclude indicator for AutoTester."
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     SELECT INTO "nl:"
      FROM (dummyt t  WITH seq = dlp_tmp_data->cnt)
      WHERE (dlp_tmp_data->tbl[t.seq].group="AUTOTESTER")
      DETAIL
       dlp_tmp_data->tbl[t.seq].excl_ind = 1
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    IF ((dlp_excl_tbl->tbl_cnt > 0)
     AND validate(dpt_preserve_tables,- (1))=1)
     SET dm_err->eproc = "Create exclusion report for partitioned preserved tables."
     CALL disp_msg(" ",dm_err->logfile,0)
     IF (get_unique_file("dm2_preserve_excl",".rpt")=0)
      RETURN(0)
     ENDIF
     SET dlp_excl_file = dm_err->unique_fname
     IF (validate(drrr_responsefile_in_use,0)=1)
      SET dlp_excl_file = build(drrr_misc_data->active_dir,dlp_excl_file)
     ENDIF
     SELECT INTO value(dlp_excl_file)
      FROM (dummyt t  WITH seq = dlp_tmp_data->cnt)
      WHERE (dlp_tmp_data->tbl[t.seq].excl_ind=1)
      ORDER BY dlp_tmp_data->tbl[t.seq].group, dlp_tmp_data->tbl[t.seq].table_name
      HEAD REPORT
       row + 1, col 1,
       "***************************WARNING: Preserve Table Exclusion have been detected.************************",
       row + 1, col 1,
       "Tables displayed below cannot be preserved due to one or more tables within its group are partitioned.",
       row + 1, col 1,
       "********************************************************************************************************",
       row + 2, col 10, "TABLE NAME",
       col 50, "GROUP_NAME", row + 1
      DETAIL
       col 10, dlp_tmp_data->tbl[t.seq].table_name, col 50,
       dlp_tmp_data->tbl[t.seq].group, row + 1
      FOOT REPORT
       col 0, "END OF REPORT"
      WITH nocounter, maxcol = 300, formfeed = none,
       maxrow = 1, nullreport
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (validate(drrr_responsefile_in_use,0)=1)
      SET dm_err->eproc = concat(
       "Using response file - Bypassing displaying of Preserve exclusion report.  ",
       "Report File may be found in :  ",dlp_excl_file)
      CALL disp_msg(" ",dm_err->logfile,0)
      IF ((drer_email_list->email_cnt > 0))
       SET drer_email_det->msgtype = "PROGRESS"
       SET drer_email_det->status = "REPORT"
       SET drer_email_det->status_dt_tm = cnvtdatetime(curdate,curtime3)
       SET drer_email_det->step = "Preserve Table Exclusion Report"
       SET drer_email_det->email_level = 1
       SET drer_email_det->logfile = dm_err->logfile
       SET drer_email_det->err_ind = dm_err->err_ind
       SET drer_email_det->eproc = dm_err->eproc
       SET drer_email_det->emsg = dm_err->emsg
       SET drer_email_det->user_action = dm_err->user_action
       SET drer_email_det->attachment = dlp_excl_file
       CALL drer_add_body_text(concat("Preserve Table Exclusion report was generated at ",format(
          drer_email_det->status_dt_tm,";;q")),1)
       CALL drer_add_body_text(concat("Report file name is : ",dlp_excl_file),0)
       IF (drer_compose_email(null)=1)
        CALL drer_send_email(drer_email_det->subject,drer_email_det->file_name,drer_email_det->
         email_level)
       ENDIF
       CALL drer_reset_pre_err(null)
      ENDIF
     ELSE
      SET drer_email_det->process = "PRESERVE"
      SET drer_email_det->msgtype = "PROGRESS"
      SET drer_email_det->status = "REPORT"
      SET drer_email_det->status_dt_tm = cnvtdatetime(curdate,curtime3)
      SET drer_email_det->step = "Preserve Table Exclusion Report"
      SET drer_email_det->email_level = 1
      SET drer_email_det->logfile = dm_err->logfile
      SET drer_email_det->err_ind = dm_err->err_ind
      SET drer_email_det->eproc = dm_err->eproc
      SET drer_email_det->emsg = dm_err->emsg
      SET drer_email_det->user_action = dm_err->user_action
      SET drer_email_det->attachment = dlp_excl_file
      CALL drer_add_body_text(concat("Preserve Table Exclusion report was displayed at ",format(
         drer_email_det->status_dt_tm,";;q")),1)
      CALL drer_add_body_text(concat("Report file name is ccluserdir: ",dlp_excl_file),0)
      IF ((dm_err->debug_flag > 0))
       CALL echo(build("ddr_domain_data->tgt_env = ",ddr_domain_data->tgt_env))
       CALL echo(build("ddr_domain_data->src_env = ",ddr_domain_data->src_env))
       CALL echo(build("ddr_domain_data->src_domain_name = ",ddr_domain_data->src_domain_name))
      ENDIF
      SET drer_email_det->src_env = ddr_domain_data->src_env
      SET drer_email_det->tgt_env = ddr_domain_data->tgt_env
      IF (drer_fill_email_list(drer_email_det->src_env,drer_email_det->tgt_env)=1
       AND (drer_email_list->email_cnt > 0))
       IF (drer_compose_email(null)=1)
        CALL drer_send_email(drer_email_det->subject,drer_email_det->file_name,drer_email_det->
         email_level)
       ENDIF
      ENDIF
      CALL drer_reset_pre_err(null)
      IF (dm2_disp_file(dlp_excl_file,"Preserve Table Exclusion Report")=0)
       RETURN(0)
      ENDIF
     ENDIF
    ENDIF
   ELSEIF (dlp_source="FILE")
    SET dm_err->eproc = concat("Load preserved tables from ",dlp_file)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    FREE DEFINE rtl2
    FREE SET dlp_filename
    SET logical dlp_filename value(dlp_file)
    DEFINE rtl2 "dlp_filename"
    SELECT INTO "nl:"
     t.line
     FROM rtl2t t
     WHERE t.line > " "
     HEAD REPORT
      beg_pos = 1, end_pos = 0
     DETAIL
      beg_pos = 1, end_pos = 0, drr_preserved_tables_data->cnt = (drr_preserved_tables_data->cnt+ 1)
      IF (mod(drr_preserved_tables_data->cnt,10)=1)
       stat = alterlist(drr_preserved_tables_data->tbl,(drr_preserved_tables_data->cnt+ 9))
      ENDIF
      end_pos = findstring(",",t.line,beg_pos,0)
      IF ((dm_err->debug_flag > 2))
       CALL echo(build("end_pos =",end_pos))
      ENDIF
      drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].group = substring(beg_pos,(
       end_pos - beg_pos),t.line), beg_pos = (end_pos+ 1), end_pos = findstring(",",t.line,beg_pos,0)
      IF ((dm_err->debug_flag > 2))
       CALL echo(build("end_pos =",end_pos))
      ENDIF
      drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].table_name = substring(beg_pos,(
       end_pos - beg_pos),t.line), beg_pos = (end_pos+ 1), end_pos = findstring(",",t.line,beg_pos,0)
      IF ((dm_err->debug_flag > 2))
       CALL echo(build("end_pos =",end_pos))
      ENDIF
      drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].partial_ind = evaluate(substring
       (beg_pos,(end_pos - beg_pos),t.line),"PARTIAL",1,0), beg_pos = (end_pos+ 1), end_pos =
      findstring(",",t.line,beg_pos,0)
      IF ((dm_err->debug_flag > 2))
       CALL echo(build("end_pos =",end_pos))
      ENDIF
      drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].exp_where_clause = substring(
       beg_pos,(end_pos - beg_pos),t.line), drr_preserved_tables_data->tbl[drr_preserved_tables_data
      ->cnt].table_suffix = substring((end_pos+ 1),size(t.line),t.line), drr_preserved_tables_data->
      tbl[drr_preserved_tables_data->cnt].prefix = cnvtlower(build(drr_clin_copy_data->
        preserve_tbl_pre,drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].table_suffix)
       ),
      drr_preserved_tables_data->tbl[drr_preserved_tables_data->cnt].refresh_ind = 0
     FOOT REPORT
      stat = alterlist(drr_preserved_tables_data->tbl,drr_preserved_tables_data->cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(drr_preserved_tables_data)
    CALL echorecord(dlp_excl_tbl)
    CALL echorecord(dlp_tmp_data)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_prompt_preserve_data(null)
   DECLARE dpp_pd_present = i2 WITH protect, noconstant(0)
   SET message = nowindow
   SET dm_err->eproc = "Prompt user if restore is needed for preserved data."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   DECLARE dpp_prev_group = vc WITH protect, noconstant(" ")
   DECLARE dpp_row = i4 WITH protect, noconstant(0)
   DECLARE dpp_cnt = i4 WITH protect, noconstant(0)
   DECLARE dpp_restore = c1 WITH protect, noconstant(" ")
   DECLARE dpp_grp = i4 WITH protect, noconstant(0)
   DECLARE dpp_rrd = i4 WITH protect, noconstant(0)
   DECLARE dpp_printers = i4 WITH protect, noconstant(0)
   DECLARE dpp_restore_grps_str = vc WITH protect, noconstant("")
   DECLARE dpp_ndx = i4 WITH protect, noconstant(0)
   IF (drr_chk_for_preserved_data(dpp_pd_present)=0)
    RETURN(0)
   ENDIF
   IF (dpp_pd_present=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Components required for restoring preserved data NOT found"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   FOR (dpp_cnt = 1 TO drr_preserved_tables_data->cnt)
    SET dpp_grp = locateval(dpp_grp,1,drr_group->cnt,drr_preserved_tables_data->tbl[dpp_cnt].group,
     drr_group->grp[dpp_grp].group)
    IF (dpp_grp > 0)
     SET drr_preserved_tables_data->tbl[dpp_cnt].refresh_ind = drr_group->grp[dpp_grp].restore
    ELSE
     SET drr_group->cnt = (drr_group->cnt+ 1)
     SET stat = alterlist(drr_group->grp,drr_group->cnt)
     SET drr_group->grp[drr_group->cnt].group = drr_preserved_tables_data->tbl[dpp_cnt].group
     IF ((drr_group->grp[drr_group->cnt].group="NOPROMPT"))
      SET drr_group->grp[drr_group->cnt].prompt_ind = 0
      SET drr_preserved_tables_data->refresh_ind = 1
      SET drr_preserved_tables_data->tbl[dpp_cnt].refresh_ind = 1
      SET drr_group->grp[drr_group->cnt].restore = 1
     ELSE
      SET drr_group->grp[drr_group->cnt].prompt_ind = 1
     ENDIF
     IF ((drr_preserved_tables_data->tbl[dpp_cnt].group != "NOPROMPT"))
      IF (validate(drrr_responsefile_in_use,0)=1)
       SET dpp_ndx = 0
       SET dpp_ndx = locateval(dpp_ndx,1,drrr_misc_data->tgt_restore_list_cnt,
        drr_preserved_tables_data->tbl[dpp_cnt].group,drrr_misc_data->tgt_restore_list[dpp_ndx].
        restore_group)
       IF (dpp_ndx > 0
        AND (drrr_misc_data->tgt_restore_list[dpp_ndx].restore_ind=1))
        SET drr_preserved_tables_data->refresh_ind = 1
        SET drr_preserved_tables_data->tbl[dpp_cnt].refresh_ind = 1
        SET drr_group->grp[drr_group->cnt].restore = 1
       ELSE
        SET drr_group->grp[drr_group->cnt].restore = 0
       ENDIF
      ELSE
       IF ((drr_group->grp[drr_group->cnt].prompt_ind=1))
        SET message = window
        CALL clear(1,1)
        CALL box(1,1,24,131)
        CALL text(2,2,"Restoring Preserved Data")
        SET dpp_restore = " "
        CALL text(4,8,concat("Restore ",drr_preserved_tables_data->tbl[dpp_cnt].group," (Y/N): "))
        CALL accept(4,70,"A;cu"," "
         WHERE curaccept IN ("Y", "N"))
        SET dpp_restore = curaccept
        IF (dpp_restore="Y")
         SET drr_preserved_tables_data->refresh_ind = 1
         SET drr_preserved_tables_data->tbl[dpp_cnt].refresh_ind = 1
         SET drr_group->grp[drr_group->cnt].restore = 1
        ELSE
         SET drr_group->grp[drr_group->cnt].restore = 0
        ENDIF
        CALL text(8,8,"Enter 'C' to continue or 'Q' to quit (C or Q) :")
        CALL accept(8,70,"A;cu",""
         WHERE curaccept IN ("Q", "C"))
        SET dccs_whereto = curaccept
        SET message = nowindow
        IF (dccs_whereto="Q")
         SET message = nowindow
         SET dm_err->eproc = "Prompt user to restore Preserve data."
         SET dm_err->emsg = "User chose to quit from Restoring Preserved Data menu."
         SET dm_err->err_ind = 1
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDFOR
   SET dpp_rrd = locateval(dpp_rrd,1,drr_group->cnt,"RRD",drr_group->grp[dpp_rrd].group)
   SET dpp_printers = locateval(dpp_printers,1,drr_group->cnt,"PRINTERS",drr_group->grp[dpp_printers]
    .group)
   IF ((drr_group->grp[dpp_rrd].restore=1)
    AND (drr_group->grp[dpp_printers].restore=0))
    SET drr_group->grp[dpp_printers].restore = 1
    FOR (dpp_cnt = 1 TO drr_preserved_tables_data->cnt)
      IF ((drr_preserved_tables_data->tbl[dpp_cnt].group="PRINTERS"))
       SET drr_preserved_tables_data->tbl[dpp_cnt].refresh_ind = 1
      ENDIF
    ENDFOR
    IF (validate(drrr_responsefile_in_use,0)=0)
     SET message = window
     CALL clear(1,1)
     CALL box(1,1,24,131)
     CALL text(2,2,"Restoring Preserved Data")
     CALL text(4,8,"PRINTERS will be restored when RRD group is marked to be restored.")
     CALL text(8,8,"Enter 'C' to continue or 'Q' to quit (C or Q) :")
     CALL accept(8,70,"A;cu",""
      WHERE curaccept IN ("Q", "C"))
     SET dccs_whereto = curaccept
     SET message = nowindow
    ENDIF
   ENDIF
   IF (validate(drrr_responsefile_in_use,0)=1)
    SET dccs_whereto = "C"
   ENDIF
   IF (dccs_whereto="C")
    IF ((dm_err->debug_flag > 2))
     CALL echorecord(drr_preserved_tables_data)
    ENDIF
    SET drr_preserved_tables_data->restore_groups_str = ""
    FOR (dpp_cnt = 1 TO drr_group->cnt)
      IF ((drr_group->grp[dpp_cnt].restore=1))
       IF ((drr_preserved_tables_data->restore_groups_str=""))
        SET drr_preserved_tables_data->restore_groups_str = build("<",drr_group->grp[dpp_cnt].group,
         ">",",")
       ELSE
        SET drr_preserved_tables_data->restore_groups_str = build(drr_preserved_tables_data->
         restore_groups_str,",","<",drr_group->grp[dpp_cnt].group,">")
       ENDIF
      ENDIF
    ENDFOR
    RETURN(1)
   ELSE
    SET message = nowindow
    SET dm_err->eproc = "Prompt user to restore Preserve data."
    SET dm_err->emsg = "User chose to quit from Restoring Preserved Data menu."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE drr_chk_for_preserved_data(dcf_chk_ret)
   SET dm_err->eproc = "Check if preserved data was stored off before a Refresh was initiated."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   DECLARE dcf_cnt = i4 WITH protect, noconstant(0)
   DECLARE dcf_dat_file = vc WITH protect, noconstant(" ")
   DECLARE dcf_dmp_file = vc WITH protect, noconstant(" ")
   DECLARE dcf_sch_file = vc WITH protect, noconstant(" ")
   DECLARE dcf_par_file = vc WITH protect, noconstant(" ")
   SET dcf_dat_file = concat(drr_clin_copy_data->temp_location,drr_clin_copy_data->preserve_tbl_pre,
    "_summary.dat")
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("summary_file =",dcf_dat_file))
   ENDIF
   IF (dm2_findfile(dcf_dat_file)=0)
    SET dcf_chk_ret = 0
    RETURN(1)
   ENDIF
   IF (drr_load_preserved_table_data("FILE",dcf_dat_file)=0)
    RETURN(0)
   ENDIF
   IF ((drr_clin_copy_data->standalone_expimp_process=0))
    FOR (dcf_cnt = 1 TO drr_preserved_tables_data->cnt)
      SET dcf_dmp_file = concat(drr_clin_copy_data->temp_location,drr_clin_copy_data->
       preserve_tbl_pre,drr_preserved_tables_data->tbl[dcf_cnt].table_suffix,".dmp")
      IF ((dm_err->debug_flag > 2))
       CALL echo(build("dmp_file =",dcf_dmp_file))
      ENDIF
      IF (dm2_findfile(dcf_dmp_file)=0)
       SET dcf_chk_ret = 0
       RETURN(1)
      ENDIF
    ENDFOR
   ENDIF
   CALL dsfi_load_schema_file_defs("table_info")
   FOR (dsfi = 1 TO dm2_sch_file->file_cnt)
    SET dcf_sch_file = build(drr_clin_copy_data->temp_location,dm2_install_schema->schema_prefix,
     drr_clin_copy_data->preserve_sch_dt,cnvtlower(dm2_sch_file->qual[dsfi].file_suffix),".dat")
    IF (dm2_findfile(dcf_sch_file)=0)
     SET dcf_chk_ret = 0
     RETURN(1)
    ENDIF
   ENDFOR
   CALL dsfi_load_schema_file_defs("tspace")
   FOR (dsfi = 1 TO dm2_sch_file->file_cnt)
    SET dcf_sch_file = build(drr_clin_copy_data->temp_location,dm2_install_schema->schema_prefix,
     drr_clin_copy_data->preserve_sch_dt,cnvtlower(dm2_sch_file->qual[dsfi].file_suffix),".dat")
    IF (dm2_findfile(dcf_sch_file)=0)
     SET dcf_chk_ret = 0
     RETURN(1)
    ENDIF
   ENDFOR
   CALL dsfi_load_schema_file_defs("table_info")
   SET dcf_par_file = concat(drr_clin_copy_data->temp_location,drr_clin_copy_data->preserve_tbl_pre,
    "_imp.par")
   IF ((dm_err->debug_flag > 2))
    CALL echo(build("par_file =",dcf_par_file))
   ENDIF
   IF (dm2_findfile(dcf_par_file)=0)
    SET dcf_chk_ret = 0
    RETURN(1)
   ENDIF
   SET dcf_chk_ret = 1
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_display_summary_screen(null)
   DECLARE dds_sch_date_str = vc WITH protect, noconstant(" ")
   DECLARE dds_row = i4 WITH protect, noconstant(0)
   DECLARE dds_cnt = i4 WITH protect, noconstant(0)
   DECLARE dds_prev_group = vc WITH protect, noconstant(" ")
   DECLARE dds_file = vc WITH protect, noconstant(" ")
   SET dm_err->eproc = "Display summary report."
   IF ((drr_clin_copy_data->summary_screen_issued=1))
    RETURN(1)
   ENDIF
   IF (get_unique_file("dm2_summary_report",".rpt")=0)
    RETURN(0)
   ELSE
    SET dds_file = dm_err->unique_fname
   ENDIF
   SELECT INTO value(dds_file)
    FROM dummyt d
    HEAD REPORT
     CALL print(fillstring(90,"-")), row + 1
     IF ((drr_clin_copy_data->starting_point="FROM_BEGINNING"))
      IF ((drr_clin_copy_data->process="RESTORE"))
       col 0,
       CALL print("Complete Copy of Clinical Database (Alternate Database Restore Method) Summary")
      ELSE
       col 0,
       CALL print("Create a Copy of a Clinical Database Summary")
      ENDIF
     ELSE
      IF ((drr_clin_copy_data->process="RESTORE"))
       col 0,
       CALL print(
       "Restart Complete Copy of Clinical Database (Alternate Database Restore Method) Summary")
      ELSE
       col 0,
       CALL print("Restart Copy of a Clinical Database Summary")
      ENDIF
     ENDIF
     row + 1,
     CALL print(fillstring(90,"-")), row + 1,
     col 0,
     CALL print(
     "***** PLEASE REVIEW THE VALUES BELOW. WHEN DONE, PRESS ENTER FOR CONFIRMATION SCREEN! *****"),
     row + 1,
     row + 1, col 0,
     CALL print("SOURCE"),
     col 60,
     CALL print("TARGET"), row + 1,
     col 0,
     CALL print(concat("Environment Name : ",trim(drr_clin_copy_data->src_env_name))), col 60,
     CALL print(concat("Environment Name : ",trim(drr_clin_copy_data->tgt_db_env_name))), row + 1,
     col 0,
     CALL print(concat("Database Name : ",trim(dm2_install_schema->src_dbase_name))), col 60,
     CALL print(concat("Database Name : ",trim(dm2_install_schema->target_dbase_name))),
     row + 1, col 0,
     CALL print(concat("Database Create Date  : ",format(drr_clin_copy_data->src_db_created,
       "mm-dd-yyyy;;d"))),
     col 60,
     CALL print(concat("Database Create Date  : ",format(drr_clin_copy_data->tgt_db_created,
       "mm-dd-yyyy;;d"))), row + 1,
     col 0,
     CALL print(concat("Database Password : ",trim(dm2_install_schema->src_v500_p_word))), col 60,
     CALL print(concat("Database Password : ",trim(dm2_install_schema->v500_p_word))), row + 1, col 0,
     CALL print(concat("Database Connect String : ",trim(dm2_install_schema->src_v500_connect_str))),
     col 60,
     CALL print(concat("Database Connect String : ",trim(dm2_install_schema->v500_connect_str)))
     IF ((((drr_clin_copy_data->process != "RESTORE")) OR ((drr_clin_copy_data->process="RESTORE")
      AND (drr_preserved_tables_data->refresh_ind=1))) )
      IF ((drr_clin_copy_data->starting_point="FROM_BEGINNING"))
       IF ((dm2_install_schema->file_prefix > " "))
        dds_sch_date_str = format(cnvtdate(cnvtint(build(substring(1,8,dm2_install_schema->
             file_prefix)))),"mm-dd-yyyy;;d"), row + 1, col 0,
        CALL print(concat("Schema Date = ",dds_sch_date_str))
       ENDIF
       IF ((drr_clin_copy_data->process != "MIGRATION"))
        IF ((drr_clin_copy_data->ads_chosen_ind=1))
         row + 1, col 0,
         CALL print(concat("Data to Move = Reference with Activity Data Sample Name : ",
          drr_clin_copy_data->ads_name))
        ELSE
         row + 1, col 0,
         CALL print(concat("Data to Move = ",evaluate(dm2_install_schema->data_to_move,"REF",
           "Reference Only","All")))
        ENDIF
        row + 1, col 0,
        CALL print(concat("% Tablespace Increase = ",trim(cnvtstring(dm2_install_schema->
           percent_tspace)),"%")),
        row + 1, col 0,
        CALL print(concat("Temporary Directory for Replicate/Refresh = ",drr_clin_copy_data->
         temp_location))
        IF ((drr_preserved_tables_data->refresh_ind=1))
         row + 1, col 6,
         CALL print("Restore data previously saved from TARGET database = Yes")
         FOR (dds_cnt = 1 TO drr_group->cnt)
           IF ((drr_group->grp[dds_cnt].restore=1)
            AND (drr_group->grp[dds_cnt].group != "NOPROMPT"))
            row + 1, col 6,
            CALL print(concat("Restore ",drr_group->grp[dds_cnt].group," = Yes"))
           ENDIF
         ENDFOR
        ENDIF
       ELSE
        row + 1, col 0,
        CALL print(concat("% Tablespace Adjustment = ",trim(cnvtstring(dm2_install_schema->
           percent_tspace)),"%"))
       ENDIF
      ENDIF
      IF ((drr_clin_copy_data->starting_point != "FROM_BEGINNING"))
       row + 1
      ENDIF
      IF ((drr_clin_copy_data->process="MIGRATION"))
       row + 1, col 0,
       CALL print("For parallel processing, open additional sessions and execute the following:"),
       row + 1, col 0,
       CALL print("            ccl> dm2_mig_replicate_runner go "),
       row + 1, col 0,
       CALL print("To monitor the progress of a clinical copy, execute the following:"),
       row + 1, col 0,
       CALL print("            ccl> dm2_mig_replicate_monitor go "),
       row + 1
      ELSE
       row + 1, col 0,
       CALL print("For parallel processing, open additional sessions and execute the following:"),
       row + 1, col 0,
       CALL print("            ccl> dm2_replicate_runner go "),
       row + 1, col 0,
       CALL print("To monitor the progress of a clinical copy, execute the following:"),
       row + 1, col 0,
       CALL print("            ccl> dm2_domain_maint go "),
       row + 1, col 0,
       CALL print("            Replicate/Refresh a Domain -> Monitor Copy of Clinical Database"),
       row + 1, row + 1
      ENDIF
      IF ((drr_clin_copy_data->starting_point != "FROM_BEGINNING"))
       row + 1
      ENDIF
     ENDIF
    FOOT REPORT
     col 0, "END OF REPORT"
    WITH nocounter, maxcol = 300, formfeed = none,
     maxrow = 1, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dm2_disp_file(dds_file,"Clinical Database Summary Report")=0)
    RETURN(0)
   ENDIF
   SET message = window
   CALL clear(1,1)
   CALL text(4,2,"Database Summary Report Confirmation")
   CALL text(7,2,"Enter 'C' to continue or 'Q' to quit (C or Q) :")
   CALL accept(7,60,"p;cu",""
    WHERE curaccept IN ("C", "Q"))
   IF (curaccept="Q")
    SET message = nowindow
    SET dm_err->eproc = "Displaying Clinical Database Summary."
    SET dm_err->emsg = "User chose to quit from Clinical Database Summary."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    SET drr_clin_copy_data->summary_screen_issued = 1
    SET message = nowindow
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE drr_get_invalid_tables_list(null)
   DECLARE dgitl_iter = i4 WITH protect, noconstant(0)
   DECLARE dgitl_found = i4 WITH protect, noconstant(0)
   DECLARE dgitl_found2 = i4 WITH protect, noconstant(0)
   DECLARE dgitl_found3 = i4 WITH protect, noconstant(0)
   FREE RECORD tables_doc_list
   RECORD tables_doc_list(
     1 cnt = i4
     1 qual[*]
       2 table_name = vc
   )
   FREE RECORD exception_list
   RECORD exception_list(
     1 cnt = i4
     1 qual[*]
       2 table_name = vc
       2 owner = vc
   )
   SET dm_err->eproc = "Determining if CQM* exception row exists in dm_info."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE "DM2_REPLICATE_CLEANUP_EXCEPTION"=di.info_domain
     AND "CQM\*"=di.info_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = "Inserting CQM* row as exception into dm_info."
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_REPLICATE_CLEANUP_EXCEPTION", di.info_name = "CQM*", di.info_number =
      1
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ENDIF
    COMMIT
   ENDIF
   SET dm_err->eproc = "Selecting list of exception tables from dm_info."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE "DM2_REPLICATE_CLEANUP_EXCEPTION"=di.info_domain
     AND 1=di.info_number
    HEAD REPORT
     exception_list->cnt = 0, stat = alterlist(exception_list->qual,0)
    DETAIL
     exception_list->cnt = (exception_list->cnt+ 1), stat = alterlist(exception_list->qual,
      exception_list->cnt), exception_list->qual[exception_list->cnt].table_name = di.info_name,
     exception_list->qual[exception_list->cnt].owner = "V500"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((drr_clin_copy_data->tgt_mock_env=1))
    SET exception_list->cnt = (exception_list->cnt+ 1)
    SET stat = alterlist(exception_list->qual,exception_list->cnt)
    SET exception_list->qual[exception_list->cnt].table_name = "*$R"
    SET exception_list->qual[exception_list->cnt].owner = "V500"
   ENDIF
   SET exception_list->cnt = (exception_list->cnt+ 1)
   SET stat = alterlist(exception_list->qual,exception_list->cnt)
   SET exception_list->qual[exception_list->cnt].table_name = "*$C"
   SET exception_list->qual[exception_list->cnt].owner = "V500"
   SET exception_list->cnt = (exception_list->cnt+ 1)
   SET stat = alterlist(exception_list->qual,exception_list->cnt)
   SET exception_list->qual[exception_list->cnt].table_name = "*$O"
   SET exception_list->qual[exception_list->cnt].owner = "V500"
   SET exception_list->cnt = (exception_list->cnt+ 1)
   SET stat = alterlist(exception_list->qual,exception_list->cnt)
   SET exception_list->qual[exception_list->cnt].table_name = "*GTTD"
   SET exception_list->qual[exception_list->cnt].owner = "V500"
   SET exception_list->cnt = (exception_list->cnt+ 1)
   SET stat = alterlist(exception_list->qual,exception_list->cnt)
   SET exception_list->qual[exception_list->cnt].table_name = "*GTTP"
   SET exception_list->qual[exception_list->cnt].owner = "V500"
   SET exception_list->cnt = (exception_list->cnt+ 1)
   SET stat = alterlist(exception_list->qual,exception_list->cnt)
   SET exception_list->qual[exception_list->cnt].table_name = "*GTMP"
   SET exception_list->qual[exception_list->cnt].owner = "V500"
   IF ((drr_retain_db_users->cnt > 0))
    FOR (dgitl_iter = 1 TO drr_retain_db_users->cnt)
      SET exception_list->cnt = (exception_list->cnt+ 1)
      SET stat = alterlist(exception_list->qual,exception_list->cnt)
      SET exception_list->qual[exception_list->cnt].table_name = "*"
      SET exception_list->qual[exception_list->cnt].owner = drr_retain_db_users->user[dgitl_iter].
      user_name
    ENDFOR
   ENDIF
   SET dgitl_iter = 0
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(exception_list)
   ENDIF
   SET dm_err->eproc = "Selecting list of tables from dm_tables_doc."
   SELECT DISTINCT INTO "nl:"
    dtd.table_name
    FROM dm_tables_doc dtd
    ORDER BY dtd.table_name
    HEAD REPORT
     tables_doc_list->cnt = 0, stat = alterlist(tables_doc_list->qual,tables_doc_list->cnt)
    DETAIL
     tables_doc_list->cnt = (tables_doc_list->cnt+ 1)
     IF (mod(tables_doc_list->cnt,250)=1)
      stat = alterlist(tables_doc_list->qual,(tables_doc_list->cnt+ 249))
     ENDIF
     tables_doc_list->qual[tables_doc_list->cnt].table_name = dtd.table_name
    FOOT REPORT
     stat = alterlist(tables_doc_list->qual,tables_doc_list->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dm2_fill_sch_except("LOCAL")=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm2_sch_except)
   ENDIF
   IF (drr_get_custom_tables_list(null)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Selecting list of invalid tables from dm2_dba_tables."
   SELECT INTO "nl:"
    FROM dm2_dba_tables ddt
    WHERE "CDBA" != ddt.owner
     AND  NOT (ddt.owner IN (
    (SELECT
     di.info_name
     FROM dm_info di
     WHERE ((di.info_domain IN ("DM2_ORACLE_USER", "DM2_CERNER_USER")
      AND di.info_number=1) OR (di.info_domain="DM2_CUSTOM_USER"))
     WITH nordbbindcons)))
     AND ddt.table_name != "MLOG*"
    ORDER BY ddt.table_name
    HEAD REPORT
     drr_cleanup_drop_list->cnt = 0, stat = alterlist(drr_cleanup_drop_list->qual,
      drr_cleanup_drop_list->cnt), exception_ind = 0
    DETAIL
     exception_ind = 0
     FOR (dgitl_iter = 1 TO exception_list->cnt)
       IF (ddt.table_name=patstring(exception_list->qual[dgitl_iter].table_name,0)
        AND (ddt.owner=exception_list->qual[dgitl_iter].owner))
        exception_ind = 1, dgitl_iter = (exception_list->cnt+ 1)
       ENDIF
     ENDFOR
     IF (exception_ind=0)
      dgitl_found = locateval(dgitl_iter,1,tables_doc_list->cnt,ddt.table_name,tables_doc_list->qual[
       dgitl_iter].table_name), dgitl_found2 = locateval(dgitl_iter,1,dm2_sch_except->tcnt,ddt
       .table_name,dm2_sch_except->tbl[dgitl_iter].tbl_name), dgitl_found3 = locateval(dgitl_iter,1,
       drr_custom_tables->cnt,ddt.table_name,drr_custom_tables->qual[dgitl_iter].table_name,
       ddt.owner,drr_custom_tables->qual[dgitl_iter].owner)
      IF (((dgitl_found=0) OR (ddt.owner != "V500"))
       AND dgitl_found3=0
       AND dgitl_found2=0)
       drr_cleanup_drop_list->cnt = (drr_cleanup_drop_list->cnt+ 1)
       IF (mod(drr_cleanup_drop_list->cnt,25)=1)
        stat = alterlist(drr_cleanup_drop_list->qual,(drr_cleanup_drop_list->cnt+ 24))
       ENDIF
       drr_cleanup_drop_list->qual[drr_cleanup_drop_list->cnt].owner = ddt.owner,
       drr_cleanup_drop_list->qual[drr_cleanup_drop_list->cnt].table_name = ddt.table_name
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(drr_cleanup_drop_list->qual,drr_cleanup_drop_list->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(drr_cleanup_drop_list)
   ENDIF
   SET dm_err->eproc = "Getting list of Invalid Materialized Views for Invalid Tables being dropped."
   SELECT INTO "nl:"
    FROM dba_mviews dm
    WHERE (list(dm.owner,dm.mview_name)=
    (SELECT
     ddt.owner, ddt.table_name
     FROM dm2_dba_tables ddt
     WHERE "CDBA" != ddt.owner
      AND ((ddt.owner="V500"
      AND ddt.table_name != "CUST*") OR (ddt.owner != "V500"))
      AND  NOT (ddt.owner IN (
     (SELECT
      di.info_name
      FROM dm_info di
      WHERE ((di.info_domain IN ("DM2_ORACLE_USER", "DM2_CERNER_USER")
       AND di.info_number=1) OR (di.info_domain="DM2_CUSTOM_USER"))
      WITH nordbbindcons)))
      AND ddt.table_name != "MLOG*"
      AND  NOT ( EXISTS (
     (SELECT
      "x"
      FROM dm_tables_doc dtd
      WHERE ddt.table_name=dtd.table_name)))))
    HEAD REPORT
     drr_mvdrop_list->cnt = 0, stat = alterlist(drr_mvdrop_list->qual,drr_mvdrop_list->cnt)
    DETAIL
     drr_mvdrop_list->cnt = (drr_mvdrop_list->cnt+ 1)
     IF (mod(drr_mvdrop_list->cnt,10)=1)
      stat = alterlist(drr_mvdrop_list->qual,(drr_mvdrop_list->cnt+ 9))
     ENDIF
     drr_mvdrop_list->qual[drr_mvdrop_list->cnt].owner = dm.owner, drr_mvdrop_list->qual[
     drr_mvdrop_list->cnt].mv_name = dm.mview_name
    FOOT REPORT
     stat = alterlist(drr_mvdrop_list->qual,drr_mvdrop_list->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(drr_mvdrop_list)
   ENDIF
   SET drr_cleanup_drop_list->list_loaded_ind = 1
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_get_custom_tables_list(null)
   DECLARE dgct_idx = i4 WITH protect, noconstant(0)
   DECLARE dgct_purge_string = vc WITH protect, noconstant("")
   DECLARE dgct_pos = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Selecting list of custom tables from dm_info and dm2_dba_tables."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE "DM2_CUSTOM_TABLE"=di.info_domain
    HEAD REPORT
     drr_custom_tables->cnt = 0, stat = alterlist(drr_custom_tables->qual,0)
    DETAIL
     drr_custom_tables->cnt = (drr_custom_tables->cnt+ 1), stat = alterlist(drr_custom_tables->qual,
      drr_custom_tables->cnt), dgct_pos = findstring(":",trim(di.info_name),1,0)
     IF (dgct_pos > 0)
      drr_custom_tables->qual[drr_custom_tables->cnt].owner = substring(1,(dgct_pos - 1),trim(di
        .info_name)), drr_custom_tables->qual[drr_custom_tables->cnt].table_name = substring((
       dgct_pos+ 1),(textlen(trim(di.info_name)) - dgct_pos),trim(di.info_name)), drr_custom_tables->
      qual[drr_custom_tables->cnt].owner_table = concat(trim(drr_custom_tables->qual[
        drr_custom_tables->cnt].owner),trim(drr_custom_tables->qual[drr_custom_tables->cnt].
        table_name))
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm2_dba_tables ddt
    WHERE ddt.owner="V500"
     AND ddt.table_name=patstring("CUST*")
    DETAIL
     IF (locateval(dgct_idx,1,drr_custom_tables->cnt,ddt.table_name,drr_custom_tables->qual[dgct_idx]
      .table_name)=0)
      drr_custom_tables->cnt = (drr_custom_tables->cnt+ 1), stat = alterlist(drr_custom_tables->qual,
       drr_custom_tables->cnt), drr_custom_tables->qual[drr_custom_tables->cnt].table_name = ddt
      .table_name,
      drr_custom_tables->qual[drr_custom_tables->cnt].owner = ddt.owner, drr_custom_tables->qual[
      drr_custom_tables->cnt].owner_table = concat(trim(ddt.owner),trim(ddt.table_name))
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(drr_custom_tables)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_process_invalid_tables(null)
   DECLARE dpit_iter = i4 WITH protect, noconstant(0)
   DECLARE dpit_purge_string = vc WITH protect, noconstant("")
   DECLARE dpit_drop_cmd = vc WITH protect, noconstant("")
   DECLARE dpit_nodrop_ind = i2 WITH protect, noconstant(0)
   FREE RECORD all_objects_list
   RECORD all_objects_list(
     1 cnt = i4
     1 qual[*]
       2 object_name = vc
   )
   CALL dm2_get_rdbms_version(null)
   IF ((dm2_rdbms_version->level1 <= 9))
    SET dpit_purge_string = " "
   ELSE
    SET dpit_purge_string = "PURGE"
   ENDIF
   IF ((dm2_install_schema->process_option != patstring("CLIN COPY*")))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Processing of invalid tables is only allowed during CLIN COPY"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   FOR (dpit_iter = 1 TO drr_mvdrop_list->cnt)
     SET dpit_nodrop_ind = 0
     IF ((drr_clin_copy_data->process != "RESTORE")
      AND (drr_mvdrop_list->qual[dpit_iter].owner != "V500"))
      SET dpit_nodrop_ind = 1
     ENDIF
     IF (dpit_nodrop_ind=0)
      SET dpit_drop_cmd = concat('RDB ASIS(^DROP MATERIALIZED VIEW "',drr_mvdrop_list->qual[dpit_iter
       ].owner,'"."',drr_mvdrop_list->qual[dpit_iter].mv_name,'" ^) GO')
      IF ((dm_err->debug_flag=318))
       CALL echo(dpit_drop_cmd)
      ELSE
       IF (dm2_push_cmd(dpit_drop_cmd,1)=0)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   FOR (dpit_iter = 1 TO drr_cleanup_drop_list->cnt)
     SET dpit_nodrop_ind = 0
     IF ((drr_clin_copy_data->process != "RESTORE")
      AND (drr_cleanup_drop_list->qual[dpit_iter].owner != "V500"))
      SET dpit_nodrop_ind = 1
     ENDIF
     IF (dpit_nodrop_ind=0)
      SET dpit_drop_cmd = concat('RDB ASIS(^DROP TABLE "',drr_cleanup_drop_list->qual[dpit_iter].
       owner,'"."',drr_cleanup_drop_list->qual[dpit_iter].table_name,'" CASCADE CONSTRAINTS ',
       dpit_purge_string," ^) GO")
      IF ((dm_err->debug_flag=318))
       CALL echo(dpit_drop_cmd)
      ELSE
       IF (dm2_push_cmd(dpit_drop_cmd,1)=0)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(drr_cleanup_drop_list)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_confirm_invalid_tables(dcit_manage_opt_ind,dcit_confirm_ret)
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,24,131)
   CALL text(2,36,"INVALID TABLES REPORT CONFIRMATION")
   CALL text(4,2,"Is the invalid tables report correct?")
   IF (dcit_manage_opt_ind=1)
    CALL text(6,2,"The Manage Custom Users option can be leveraged to manage custom users ")
    CALL text(7,2,"that will then be exempt from the invalid tables process.")
    CALL text(8,2,
     "It will be the clients responsibility to evaluate that there is no data copied to TARGET")
    CALL text(9,2,"that still points back to the SOURCE domain/database.")
    CALL text(21,2,"(M)anage Custom Users, (C)onfirm, (Q)uit : ")
    CALL accept(21,45,"A;cu"," "
     WHERE curaccept IN ("M", "C", "Q"))
   ELSE
    CALL text(21,2,"(C)onfirm, (Q)uit : ")
    CALL accept(21,25,"A;cu"," "
     WHERE curaccept IN ("C", "Q"))
   ENDIF
   CASE (curaccept)
    OF "M":
     SET dcit_confirm_ret = 2
    OF "C":
     SET dcit_confirm_ret = 1
    OF "Q":
     SET dcit_confirm_ret = 0
   ENDCASE
   SET message = nowindow
   RETURN(1)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_get_dbase_created_date(dgdcd_created_date)
   IF (dm2_get_rdbms_version(null)=0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Retrieving database created date"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dm2_rdbms_version->level1 <= 11))
    SELECT INTO "nl:"
     FROM v$database v
     DETAIL
      dgdcd_created_date = v.created
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       creation_time = x.creation_time
       FROM (parser("v$pdbs") x)
       WITH sqltype("DQ8")))
      v)
     DETAIL
      dgdcd_created_date = v.creation_time
     WITH nocounter
    ;end select
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_get_max_clin_copy_run_id(dgm_run_id)
   SET dm_err->eproc = "Retrieving max run_id for CLIN COPY"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm2_ddl_ops d
    WHERE d.run_id IN (
    (SELECT
     max(r.run_id)
     FROM dm2_ddl_ops r
     WHERE r.process_option="CLIN COPY"))
    DETAIL
     dgm_run_id = d.run_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_validate_ref_data_link(null)
   IF (validate(drrr_responsefile_in_use,- (1))=1)
    EXECUTE dm2_create_database_link "REF_DATA_LINK", drrr_rf_data->src_db_link_cnct_desc,
    drrr_rf_data->src_db_user,
    drrr_rf_data->src_db_user_pwd, drrr_rf_data->src_db_link_host, drrr_rf_data->src_db_link_port,
    drrr_rf_data->src_db_link_svc_nm, drrr_rf_data->src_db_cred_nm, 1,
    1
   ELSE
    EXECUTE dm2_create_database_link "REF_DATA_LINK", dm2_install_schema->src_v500_connect_str,
    "V500",
    dm2_install_schema->src_v500_p_word, " ", " ",
    " ", " ", 1,
    1
   ENDIF
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF (validate(drrr_responsefile_in_use,- (1))=1)
    EXECUTE dm2_create_database_link "REPL_SOURCE", drrr_rf_data->src_db_link_cnct_desc, drrr_rf_data
    ->src_db_user,
    drrr_rf_data->src_db_user_pwd, drrr_rf_data->src_db_link_host, drrr_rf_data->src_db_link_port,
    drrr_rf_data->src_db_link_svc_nm, drrr_rf_data->src_db_cred_nm, 1,
    1
   ELSE
    EXECUTE dm2_create_database_link "REPL_SOURCE", dm2_install_schema->src_v500_connect_str, "V500",
    dm2_install_schema->src_v500_p_word, " ", " ",
    " ", " ", 1,
    1
   ENDIF
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_drop_db_link(dddl_link_name)
   DECLARE dddl_dblink_fnd_ind = i2 WITH protect, noconstant(0)
   DECLARE dddl_adb_ind = i2 WITH protect, noconstant(0)
   DECLARE drop_database_link(db_link_name=vc,public_link=i4) = null WITH sql =
   "DBMS_CLOUD_ADMIN.DROP_DATABASE_LINK", parameter
   IF (drr_check_db_link(dddl_link_name,dddl_dblink_fnd_ind)=0)
    RETURN(0)
   ENDIF
   IF (dddl_dblink_fnd_ind=1)
    IF (dm2_adb_check("",dddl_adb_ind)=0)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = concat("Removing existing database link for ",dddl_link_name)
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (dddl_adb_ind=1)
     CALL drop_database_link(dddl_link_name,cnvtbool(true))
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ELSE
     IF (dm2_push_cmd(concat("rdb drop public database link ",dddl_link_name," go"),1)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ELSE
    SET dm_err->eproc = concat("Database link ",dddl_link_name," does not exist in database.")
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_ads_domain_check(dadc_db_link,dadc_ads_domain_ind)
   SET dm_err->eproc = concat("Check if domain is configured for ADS.")
   CALL disp_msg("",dm_err->logfile,0)
   SELECT
    IF (dadc_db_link > "")
     FROM (parser(concat("dm_info@",dadc_db_link)) d)
    ELSE
     FROM dm_info d
    ENDIF
    INTO "nl:"
    WHERE d.info_domain="DM2_REPL_METADATA"
     AND d.info_name=parser("'ADS_CONFIG_ID'")
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (curqual > 0)
    SET dadc_ads_domain_ind = 1
   ELSE
    SET dadc_ads_domain_ind = 0
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_prompt_ads_config(dpac_response)
   DECLARE dpac_config_name = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dpac_config_status = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dpac_config_selected = i2 WITH protect, noconstant(0)
   DECLARE dpac_config_idx = i2 WITH protect, noconstant(0)
   DECLARE dpac_purge_cnt = i2 WITH protect, noconstant(0)
   EXECUTE dm2_ads_validate_configs
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   CALL dar_clear_dads_list(null)
   SET dm_err->eproc = "Load ADS Config."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT
    IF ((drr_clin_copy_data->purge_chosen_ind=1))
     WHERE s.config_status IN ("COMPLETE", "REPLICATE_RUNNING")
      AND s.sample_method=dpl_purge
    ELSE
     WHERE s.config_status="COMPLETE"
    ENDIF
    INTO "nl:"
    FROM dm_ads_config s
    ORDER BY s.updt_dt_tm DESC
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1)
     IF (mod(cnt,10)=1)
      stat = alterlist(dads_list->config_qual,(cnt+ 9))
     ENDIF
     dads_list->config_qual[cnt].config_id = s.dm_ads_config_id, dads_list->config_qual[cnt].
     config_name = cnvtupper(trim(s.config_name)), dads_list->config_qual[cnt].config_method = s
     .sample_method,
     dads_list->config_qual[cnt].config_status = s.config_status, dads_list->config_qual[cnt].
     config_pct = s.sample_percent_nbr, dads_list->config_qual[cnt].config_updt_dt_tm = s.updt_dt_tm
    FOOT REPORT
     dads_list->config_cnt = cnt, stat = alterlist(dads_list->config_qual,cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dads_list)
   ENDIF
   IF (validate(drrr_responsefile_in_use,0)=0)
    IF (curqual=0)
     SET message = window
     CALL clear(1,1)
     CALL box(6,1,12,131)
     CALL text(7,5,"No valid sample was found. Please exit this menu and go to ")
     IF ((drr_clin_copy_data->purge_chosen_ind=1))
      CALL text(8,5,concat("dm2_ads_purge_adm->Manage ADS Sample. ",
        " Only Sample Names with a Status of REPLICATE READY"))
     ELSE
      CALL text(8,5,concat("dm2_domain_maint->Activity Data Sampler->Manage Activity Data Sample. ",
        " Only Sample Names with a Status of COMPLETE"))
     ENDIF
     CALL text(9,5,"can be used for Database Replicates.")
     CALL text(11,5,"Press Enter to exit the Replicate Process")
     CALL accept(11,51,"P;E"," ")
     SET dpac_config_selected = 1
     SET dpac_response = "Q"
    ENDIF
    WHILE (dpac_config_selected=0)
      SET message = window
      CALL clear(1,1)
      CALL box(1,1,24,131)
      IF ((drr_clin_copy_data->purge_chosen_ind=1))
       CALL text(2,2,"Activity Data Purge Sample Selection")
       CALL text(4,2,"Current Sample : ")
      ELSE
       CALL text(2,2,"Activity Data Sample Selection")
       CALL text(4,2,"Current Sample Name : ")
      ENDIF
      CALL text(15,2,
       "If you wish to create or modify a Sample Name, please exit this menu and go to ")
      IF ((drr_clin_copy_data->purge_chosen_ind=1))
       CALL text(16,2,concat("dm2_ads_purge_adm->Manage ADS Sample. ",
         " Only Sample Names with a Status of REPLICATE READY"))
      ELSE
       CALL text(16,2,concat("dm2_domain_maint->Activity Data Sampler->Manage Activity Data Sample. ",
         " Only Sample Names with a Status of COMPLETE"))
      ENDIF
      CALL text(17,2,"can be used for Database Replicates.")
      IF ((drr_clin_copy_data->purge_chosen_ind=1))
       SELECT INTO "nl:"
        num_keys = count(dacd.driver_key_id)
        FROM dm_ads_config_driver dacd
        WHERE (dacd.dm_ads_config_id=dads_list->config_qual[1].config_id)
        DETAIL
         dpac_purge_cnt = num_keys
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       CALL text(6,5,"SAMPLE NAME")
       CALL text(6,31,"NUMBER OF PERSONS TO PURGE")
       CALL text(6,61,"LAST MODIFIED")
       CALL line(7,5,69)
       CALL text(8,5,substring(1,30,dads_list->config_qual[1].config_name))
       CALL text(8,31,cnvtstring(dpac_purge_cnt))
       CALL text(8,61,substring(1,13,format(dads_list->config_qual[1].config_updt_dt_tm,
          "DD-MMM-YYYY;;D")))
       SET dpac_config_name = dads_list->config_qual[1].config_name
      ELSE
       SET help = pos(5,2,10,128)
       SET help =
       SELECT INTO "nl:"
        sample_name = substring(1,30,dads_list->config_qual[t.seq].config_name), status = substring(1,
         11,dads_list->config_qual[t.seq].config_status), method = substring(1,12,dads_list->
         config_qual[t.seq].config_method),
        pct = build(dads_list->config_qual[t.seq].config_pct), last_modified = substring(1,14,format(
          dads_list->config_qual[t.seq].config_updt_dt_tm,"DD-MMM-YYYY;;D"))
        FROM (dummyt t  WITH seq = value(dads_list->config_cnt))
        WITH nocounter
       ;end select
       CALL accept(4,30,"P(30);CSF")
       SET help = off
       SET dpac_config_name = build(curaccept)
      ENDIF
      SET dpac_config_selected = 1
      IF ((drr_clin_copy_data->purge_chosen_ind=1))
       CALL text(21,2,"(C)ontinue, (Q)uit : ")
       CALL accept(21,52,"A;cu"," "
        WHERE curaccept IN ("C", "Q"))
      ELSE
       CALL text(21,2,"(S)elect a Sample Name, (V)iew Driver Table Report, (C)ontinue, (Q)uit : ")
       CALL accept(21,52,"A;cu"," "
        WHERE curaccept IN ("S", "V", "C", "Q"))
      ENDIF
      IF (curaccept="S")
       SET dpac_config_selected = 0
      ELSEIF (curaccept="V")
       SET dpac_config_idx = 0
       SET dpac_config_idx = locateval(dpac_config_idx,1,dads_list->config_cnt,dpac_config_name,
        dads_list->config_qual[dpac_config_idx].config_name)
       IF (dpac_config_idx > 0)
        IF ((dads_list->config_qual[dpac_config_idx].config_status="COMPLETE"))
         SET dads_list->config_id = dads_list->config_qual[dpac_config_idx].config_id
         EXECUTE dm2_ads_rpt_dkeys
         IF ((dm_err->err_ind=1))
          SET message = nowindow
          RETURN(0)
         ENDIF
        ENDIF
       ENDIF
       SET dpac_config_selected = 0
      ELSEIF (curaccept="C")
       SET dpac_config_idx = 0
       SET dpac_config_idx = locateval(dpac_config_idx,1,dads_list->config_cnt,dpac_config_name,
        dads_list->config_qual[dpac_config_idx].config_name)
       IF (dpac_config_idx > 0)
        IF ((drr_clin_copy_data->purge_chosen_ind=1)
         AND  NOT ((dads_list->config_qual[dpac_config_idx].config_status IN ("COMPLETE",
        "REPLICATE_RUNNING"))))
         SET dpac_config_selected = 0
        ELSEIF ((drr_clin_copy_data->purge_chosen_ind=0)
         AND (dads_list->config_qual[dpac_config_idx].config_status != "COMPLETE"))
         SET dpac_config_selected = 0
        ELSE
         SET drr_clin_copy_data->ads_config_id = dads_list->config_qual[dpac_config_idx].config_id
         SET drr_clin_copy_data->ads_name = dads_list->config_qual[dpac_config_idx].config_name
         SET drr_clin_copy_data->ads_mod_dt_tm = dads_list->config_qual[dpac_config_idx].
         config_updt_dt_tm
         SET drr_clin_copy_data->ads_pct = dads_list->config_qual[dpac_config_idx].config_pct
         SET dpac_response = "C"
        ENDIF
       ELSE
        SET dpac_config_selected = 0
       ENDIF
      ELSEIF (curaccept="Q")
       SET dpac_response = "Q"
      ENDIF
    ENDWHILE
   ELSE
    SET dpac_config_idx = 0
    SET dpac_config_idx = locateval(dpac_config_idx,1,dads_list->config_cnt,drrr_rf_data->
     ads_config_name,dads_list->config_qual[dpac_config_idx].config_name)
    IF (dpac_config_idx > 0)
     SET dads_list->config_id = dads_list->config_qual[dpac_config_idx].config_id
     EXECUTE dm2_ads_rpt_dkeys
     IF ((dm_err->err_ind=1))
      SET message = nowindow
      RETURN(0)
     ENDIF
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Find config name ",drrr_rf_data->ads_config_name,
      " in completed ADS config list.")
     SET dm_err->emsg = "Failed to find config name."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET drr_clin_copy_data->ads_config_id = dads_list->config_qual[dpac_config_idx].config_id
    SET drr_clin_copy_data->ads_name = dads_list->config_qual[dpac_config_idx].config_name
    SET drr_clin_copy_data->ads_mod_dt_tm = dads_list->config_qual[dpac_config_idx].config_updt_dt_tm
    SET drr_clin_copy_data->ads_pct = dads_list->config_qual[dpac_config_idx].config_pct
    SET dpac_response = "C"
   ENDIF
   SET message = nowindow
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_validate_tgtdblink(dvt_tgt_host,dvt_tgt_ora_ver,dvt_src_host)
   DECLARE dvt_create_link = i2 WITH protect, noconstant(0)
   DECLARE dvt_link_name = vc WITH protect, noconstant("")
   DECLARE dvt_database_name = vc WITH protect, noconstant("")
   DECLARE dvt_link_validated = i2 WITH protect, noconstant(0)
   DECLARE dvt_owner = vc WITH protect, noconstant("")
   IF ((drr_clin_copy_data->process="MIGRATION"))
    SET dvt_link_name = "MIG_TARGET"
   ELSE
    SET dvt_link_name = concat("REPL_",trim(cnvtupper(dm2_install_schema->v500_connect_str)))
   ENDIF
   IF (validate(drrr_responsefile_in_use,- (1))=1)
    EXECUTE dm2_create_database_link dvt_link_name, drrr_rf_data->tgt_db_link_cnct_desc, drrr_rf_data
    ->tgt_db_user,
    drrr_rf_data->tgt_db_user_pwd, drrr_rf_data->tgt_db_link_host, drrr_rf_data->tgt_db_link_port,
    drrr_rf_data->tgt_db_link_svc_nm, drrr_rf_data->tgt_db_cred_nm, 1,
    0
   ELSE
    EXECUTE dm2_create_database_link dvt_link_name, dm2_install_schema->v500_connect_str, "V500",
    dm2_install_schema->v500_p_word, " ", " ",
    " ", " ", 1,
    0
   ENDIF
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF (validate(dm2_bypass_src_to_tgt_dblink_verify_ind,- (1)) != 1)
    WHILE (dvt_link_validated=0)
      SET dm_err->eproc = concat("Validating database link ",trim(dvt_link_name),
       " in Source database ",trim(dm2_install_schema->src_dbase_name)," to Target database ",
       trim(dm2_install_schema->target_dbase_name))
      CALL disp_msg(" ",dm_err->logfile,0)
      SELECT
       IF (dvt_tgt_ora_ver <= 11)
        FROM (parser(concat("v$database@",trim(dvt_link_name))) v)
       ELSE
        FROM (parser(concat("v$pdbs@",trim(dvt_link_name))) v)
       ENDIF
       INTO "nl:"
       DETAIL
        dvt_database_name = v.name
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL echo("ABOVE ERROR IS IGNORABLE")
      ENDIF
      IF ((((dm_err->err_ind=1)) OR (cnvtupper(dvt_database_name) != cnvtupper(dm2_install_schema->
       target_dbase_name))) )
       SET dm_err->err_ind = 0
       IF (validate(drrr_responsefile_in_use,0)=0)
        SET message = window
        CALL clear(1,1)
        CALL box(1,1,24,131)
        CALL text(2,2,"[Replicate] Source TNS Entry confirmation for Target Database")
        CALL text(4,2,concat("Please verify that appropriate",
          " TNS connect string entry exists for Target database [",trim(dm2_install_schema->
           target_dbase_name),"]."))
        CALL text(5,2,concat("on the SOURCE database node [",trim(dvt_src_host),"]"))
        CALL text(21,2,"Enter 'C' to Continue or 'Q' to Quit (C or Q) :")
        CALL accept(21,80,"A;cu"," "
         WHERE curaccept IN ("C", "Q"))
        SET message = nowindow
        IF (curaccept="Q")
         SET dm_err->err_ind = 1
         SET dm_err->emsg =
         "User choose to Quit from [Replicate] Source TNS Entry confirmation screen."
         CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
         RETURN(0)
        ENDIF
       ELSE
        SET dm_err->err_ind = 1
        SET dm_err->emsg = concat("Failed to validate database link ",trim(dvt_link_name),
         " in Source database ",trim(dm2_install_schema->src_dbase_name)," to Target database ",
         trim(dm2_install_schema->target_dbase_name))
        SET dm_err->user_action = concat("Please verify that appropriate Target database ",
         "TNS connect string entry exists for Target database [",trim(dm2_install_schema->
          target_dbase_name),"] on the Source database [",trim(dm2_install_schema->src_dbase_name),
         "] node [",trim(dvt_src_host),"].")
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        RETURN(0)
       ENDIF
      ELSE
       SET dvt_link_validated = 1
      ENDIF
    ENDWHILE
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_set_src_env_path(null)
   DECLARE dsse_str = vc WITH protect, noconstant("")
   DECLARE dsse_tmp_str = vc WITH protext, noconstant("")
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("temp_location = ",drr_clin_copy_data->temp_location))
    CALL echo(build("tgt_env_name = ",drr_clin_copy_data->tgt_env_name))
    CALL echo(build("src_env_name = ",drr_clin_copy_data->src_domain_name))
   ENDIF
   SET dsse_str = substring(1,(size(drr_clin_copy_data->temp_location) - 1),drr_clin_copy_data->
    temp_location)
   CALL echo(build("dsse_str =",dsse_str))
   SET dsse_tmp_str = cnvtlower(substring((findstring("/",dsse_str,1,1)+ 1),size(drr_clin_copy_data->
      tgt_env_name),dsse_str))
   CALL echo(build("search_str =",dsse_tmp_str))
   IF (cnvtlower(drr_clin_copy_data->tgt_env_name)=dsse_tmp_str)
    SET drr_env_hist_misc->path = replace(drr_clin_copy_data->temp_location,cnvtlower(
      drr_clin_copy_data->tgt_env_name),cnvtlower(drr_clin_copy_data->src_domain_name),2)
   ELSE
    IF ((dm2_sys_misc->cur_os != "AXP"))
     SET drr_env_hist_misc->path = concat(drr_clin_copy_data->temp_location,cnvtlower(
       drr_clin_copy_data->src_domain_name),"/")
    ELSE
     SET dsse_str = concat(".",drr_clin_copy_data->src_domain_name,"]")
     SET drr_env_hist_misc->path = replace(drr_clin_copy_data->temp_location,"]",dsse_str,2)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("drr_env_hist_misc->path = ",drr_env_hist_misc->path))
   ENDIF
 END ;Subroutine
 SUBROUTINE drr_validate_adm_env_csv(dvae_path,dvae_src_env)
   SET dm_err->eproc = "Validate Source environment history files."
   CALL disp_msg("",dm_err->logfile,0)
   DECLARE dvae_idx = i4 WITH protect, noconstant(0)
   DECLARE dvae_summary_file = vc WITH protect, noconstant("")
   SET drr_env_hist_misc->cnt = 0
   SET stat = alterlist(drr_env_hist_misc->qual,0)
   IF ( NOT (dm2_find_dir(dvae_path)))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validate directory passed in during drr_validate_adm_env_csv."
    SET dm_err->emsg = concat("Fail to find directory ",dvae_path)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET drr_env_hist_misc->summary_file = concat("dm2_",trim(cnvtlower(dvae_src_env)),
    "_env_hist_summary.txt")
   IF (dm2_findfile(concat(dvae_path,drr_env_hist_misc->summary_file))=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validate if file ",dvae_path,trim(drr_env_hist_misc->summary_file),
     " exists.")
    SET dm_err->emsg =
    "Source environment history summary files could not be found in temporary directory provided."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dvae_summary_file = concat(dvae_path,drr_env_hist_misc->summary_file)
   SET dm_err->eproc = concat("Load file ",dvae_summary_file)
   CALL disp_msg("",dm_err->logfile,0)
   FREE SET inputfile
   SET logical inputfile dvae_summary_file
   FREE DEFINE rtl2
   DEFINE rtl2 "inputfile"
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    HEAD REPORT
     cnt = 0, begin_ptr = 0, end_ptr = 0
    DETAIL
     IF (trim(r.line) != "")
      drr_env_hist_misc->cnt = (drr_env_hist_misc->cnt+ 1), cnt = drr_env_hist_misc->cnt, stat =
      alterlist(drr_env_hist_misc->qual,cnt),
      begin_ptr = findstring(",",r.line), end_ptr = findstring(",",r.line,(begin_ptr+ 1)),
      drr_env_hist_misc->qual[cnt].table_name = trim(substring(1,(begin_ptr - 1),r.line)),
      drr_env_hist_misc->qual[cnt].table_alias = trim(substring((begin_ptr+ 1),((end_ptr - begin_ptr)
         - 1),r.line)), begin_ptr = findstring(",",r.line,(end_ptr+ 1)), drr_env_hist_misc->qual[cnt]
      .csv_file_name = trim(substring((end_ptr+ 1),((begin_ptr - end_ptr) - 1),r.line)),
      end_ptr = findstring(",",r.line,(begin_ptr+ 1)), drr_env_hist_misc->qual[cnt].row_count = trim(
       substring((begin_ptr+ 1),((end_ptr - begin_ptr) - 1),r.line)), drr_env_hist_misc->qual[cnt].
      date = trim(substring((end_ptr+ 1),(textlen(r.line) - end_ptr),r.line))
     ENDIF
    FOOT REPORT
     stat = alterlist(drr_env_hist_misc->qual,cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(drr_env_hist_misc)
   ENDIF
   FOR (dvae_idx = 1 TO drr_env_hist_misc->cnt)
     IF (cnvtint(drr_env_hist_misc->qual[dvae_idx].row_count) > 0)
      IF (dm2_findfile(concat(dvae_path,drr_env_hist_misc->qual[dvae_idx].csv_file_name))=0)
       SET dm_err->err_ind = 1
       SET dm_err->eproc = concat("Validate if file ",dvae_path,trim(drr_env_hist_misc->qual[dvae_idx
         ].csv_file_name)," exists.")
       SET dm_err->emsg =
       "Source environment history files could not be found in temporary directory provided."
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_column_and_ccldef_exists(dcce_table_name,dcce_column_name,dcce_exists_ind)
   DECLARE dcce_col_oradef_ind = i2 WITH protect, noconstant(0)
   DECLARE dcce_col_ccldef_ind = i2 WITH protect, noconstant(0)
   DECLARE dcce_data_type = vc WITH protect, noconstant("")
   SET dm_err->eproc = concat("Validate existance of column ",dcce_column_name," on ",dcce_table_name
    )
   CALL disp_msg("",dm_err->logfile,0)
   IF (dm2_table_column_exists(value(currdbuser),dcce_table_name,dcce_column_name,1,1,
    1,dcce_col_oradef_ind,dcce_col_ccldef_ind,dcce_data_type)=0)
    RETURN(0)
   ENDIF
   IF (dcce_col_oradef_ind=1
    AND dcce_col_ccldef_ind=1)
    SET dcce_exists_ind = 1
   ELSE
    SET dcce_exists_ind = 0
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_identify_was_usage(diwu_domain,diwu_was_ind)
   DECLARE diwu_exists_ind = i2 WITH protect, noconstant(0)
   SET diwu_was_ind = 0
   IF (dm2_table_and_ccldef_exists("EA_USER",diwu_exists_ind)=0)
    RETURN(0)
   ENDIF
   IF (diwu_exists_ind=0)
    SET diwu_was_ind = 0
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    FROM ea_user eu
    WHERE cnvtupper(eu.realm)=cnvtupper(diwu_domain)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET diwu_was_ind = 1
    SET dm_err->eproc = "WAS Security architecture is turned ON"
   ELSE
    SET dm_err->eproc = "WAS Security architecture is turned OFF"
   ENDIF
   CALL disp_msg("",dm_err->logfile,0)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_restore_col_checks(drcc_src,drcc_sti,drcc_sci,drcc_pti,drcc_pci,drcc_tti,drcc_tc)
   IF (drcc_src="T")
    SET curalias drcc_src_col tgtsch->tbl[drcc_sti].tbl_col[drcc_sci]
   ELSEIF (drcc_src="C")
    SET curalias drcc_src_col cur_sch->tbl[drcc_sti].tbl_col[drcc_sci]
   ENDIF
   SET curalias drcc_pre_tbl drr_preserved_tables_data->tbl[drcc_pti]
   SET curalias drcc_pre_col drr_preserved_tables_data->tbl[drcc_pti].col[drcc_pci]
   SET curalias drcc_tgt_col tgtsch->tbl[drcc_tti].tbl_col[drcc_tc]
   SET dm_err->eproc = "Check for preserve restore column mismatch for source and target"
   IF ((drcc_src_col->data_length != drcc_pre_col->data_length))
    SET drcc_pre_col->diff_dlength_ind = 1
    SET drcc_pre_tbl->col_diff = 1
    IF ((drcc_pre_col->data_length > drcc_src_col->data_length))
     SET drcc_tgt_col->data_length = drcc_pre_col->data_length
    ELSE
     SET drcc_tgt_col->data_length = drcc_src_col->data_length
    ENDIF
   ENDIF
   IF ((drcc_src_col->data_type != drcc_pre_col->data_type))
    SET drcc_pre_col->diff_dtype_ind = 1
    SET drcc_pre_tbl->col_diff = 1
    IF ( NOT ((drcc_src_col->data_type IN ("CHAR*", "VARCHAR*", "NUMBER", "FLOAT")))
     AND  NOT ((drcc_pre_col->data_type IN ("CHAR*", "VARCHAR*", "NUMBER", "FLOAT"))))
     SET drr_preserved_tables_data->restore_foul = 1
     SET drcc_pre_tbl->restore_foul = 1
     SET drcc_pre_tbl->reason_cnt = (drcc_pre_tbl->reason_cnt+ 1)
     SET stat = alterlist(drcc_pre_tbl->restore_foul_reasons,drcc_pre_tbl->reason_cnt)
     SET drcc_pre_tbl->restore_foul_reasons[drcc_pre_tbl->reason_cnt].text =
     "Column data type differences found that are not supported."
    ELSE
     IF ((drcc_src_col->data_type="*CHAR*"))
      SET drcc_tgt_col->data_type = "VARCHAR2"
     ELSE
      SET drcc_tgt_col->data_type = drcc_src_col->data_type
     ENDIF
    ENDIF
   ENDIF
   IF ((((drcc_src_col->data_default_ni != drcc_pre_col->data_default_ni)) OR ((drcc_src_col->
   data_default_ni=drcc_pre_col->data_default_ni)
    AND (drcc_src_col->data_default != drcc_pre_col->data_default))) )
    SET drcc_pre_col->diff_default_ind = 1
    SET drcc_pre_tbl->col_diff = 1
    SET drcc_tgt_col->data_default = drcc_src_col->data_default
    SET drcc_tgt_col->data_default_ni = drcc_src_col->data_default_ni
   ENDIF
   IF ((drcc_src_col->nullable != drcc_pre_col->nullable))
    SET drcc_pre_col->diff_nullable_ind = 1
    SET drcc_pre_tbl->col_diff = 1
    SET drcc_tgt_col->nullable = drcc_pre_col->nullable
   ENDIF
   SET curalias drcc_src_col off
   SET curalias drcc_pre_tbl off
   SET curalias drcc_pre_col off
   SET curalias drcc_tgt_col off
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_restore_tbl_checks(drtc_src,drtc_sti,drtc_pti)
   DECLARE drtc_col_idx = i2 WITH protect, noconstant(0)
   DECLARE drtc_pre_col_idx = i2 WITH protect, noconstant(0)
   DECLARE drtc_src_col_idx = i2 WITH protect, noconstant(0)
   IF (drtc_src="T")
    SET curalias drtc_src_rs tgtsch->tbl[drtc_sti]
   ELSEIF (drtc_src="C")
    SET curalias drtc_src_rs cur_sch->tbl[drtc_sti]
   ENDIF
   SET curalias drtc_pre_tbl drr_preserved_tables_data->tbl[drtc_pti]
   SET dm_err->eproc = "Check for preserve restore table mismatch for source and target"
   FOR (drtc_src_idx = 1 TO drtc_src_rs->tbl_col_cnt)
     SET drtc_col_idx = 0
     SET drtc_col_idx = locateval(drtc_col_idx,1,drtc_pre_tbl->col_cnt,drtc_src_rs->tbl_col[
      drtc_src_idx].col_name,drtc_pre_tbl->col[drtc_col_idx].col_name)
     IF (drtc_col_idx=0)
      SET drtc_pre_tbl->extra_src_cols = 1
      IF ((dm2_rdbms_version->level1 >= 11))
       SET drtc_pre_tbl->restore_in_phases = 1
       IF ((drtc_pre_tbl->long_cols_exist > 0))
        SET drr_preserved_tables_data->restore_foul = 1
        SET drtc_pre_tbl->restore_foul = 1
        SET drtc_pre_tbl->reason_cnt = (drtc_pre_tbl->reason_cnt+ 1)
        SET stat = alterlist(drtc_pre_tbl->restore_foul_reasons,drtc_pre_tbl->reason_cnt)
        SET drtc_pre_tbl->restore_foul_reasons[drtc_pre_tbl->reason_cnt].text =
        "Extra Source columns not in Preserved table and Preserved table contains [long/long raw] columns."
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   IF (drtc_src="C")
    FOR (drtc_pre_col_idx = 1 TO drtc_pre_tbl->col_cnt)
      SET drtc_src_col_idx = 0
      SET drtc_src_col_idx = locateval(drtc_src_col_idx,1,drtc_src_rs->tbl_col_cnt,drtc_pre_tbl->col[
       drtc_pre_col_idx].col_name,drtc_src_rs->tbl_col[drtc_src_col_idx].col_name)
      IF (drtc_src_col_idx=0)
       SET drtc_pre_tbl->extra_pre_cols = 1
      ENDIF
    ENDFOR
   ENDIF
   SET curalias drtc_pre_tbl off
   SET curalias drtc_src_rs off
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_restore_report(null)
   DECLARE drr_tbl_idx = i2 WITH protect, noconstant(0)
   DECLARE drr_col_idx = i2 WITH protect, noconstant(0)
   DECLARE drr_grp_idx = i2 WITH protect, noconstant(0)
   DECLARE drr_tblr_idx = i2 WITH protect, noconstant(0)
   DECLARE drr_grpr_idx = i2 WITH protect, noconstant(0)
   DECLARE drr_foul_idx = i2 WITH protect, noconstant(0)
   DECLARE drr_rpt_file = vc WITH protect, noconstant("")
   DECLARE drr_tbl_first = i2 WITH protect, noconstant(0)
   DECLARE drr_col_first = i2 WITH protect, noconstant(0)
   DECLARE drr_res_first = i2 WITH protect, noconstant(0)
   DECLARE drr_grp_str = vc WITH protect, noconstant("")
   DECLARE drr_fact_idx = i2 WITH protect, noconstant(0)
   DECLARE drr_fact_idxg = i2 WITH protect, noconstant(0)
   DECLARE drr_grp_cnt = i2 WITH protect, noconstant(0)
   DECLARE drr_tbl_cnt = i2 WITH protect, noconstant(0)
   DECLARE drr_col_cnt = i2 WITH protect, noconstant(0)
   DECLARE drr_rep_col_idx = i2 WITH protect, noconstant(0)
   DECLARE drr_str = vc WITH protect, noconstant("")
   DECLARE drr_rrd_str = vc WITH protect, noconstant("")
   DECLARE drr_no_cols = i2 WITH protect, noconstant(0)
   IF (validate(drr_res_rpt->grp_cnt,1)=1
    AND validate(drr_res_rpt->grp_cnt,2)=2)
    FREE RECORD drr_res_rpt
    RECORD drr_res_rpt(
      1 grp_cnt = i2
      1 grp[*]
        2 group = vc
        2 refresh_ind = i2
        2 tbl_cnt = i2
        2 tbl[*]
          3 tbl_name = vc
          3 foul_reason = vc
        2 fact_cnt = i2
        2 fact[*]
          3 tbl_name = vc
          3 tbl_not_in_src = i2
          3 extra_src_cols = i2
          3 extra_pre_cols = i2
          3 col_diff = i2
          3 refresh_ind = i2
          3 restore_foul = i2
          3 col_cnt = i2
          3 col[*]
            4 col_name = vc
            4 diff_dtype_ind = i2
            4 diff_dlength_ind = i2
            4 diff_nullable_ind = i2
            4 diff_default_ind = i2
    )
    SET drr_res_rpt->grp_cnt = 0
   ENDIF
   SET dm_err->eproc = "Loading Foul Reason and Table Facts into record structure"
   FOR (drr_tbl_idx = 1 TO drr_preserved_tables_data->cnt)
     SET drr_grp_idx = 0
     SET drr_grp_idx = locateval(drr_grp_idx,1,drr_res_rpt->grp_cnt,drr_preserved_tables_data->tbl[
      drr_tbl_idx].group,drr_res_rpt->grp[drr_grp_idx].group)
     IF (drr_grp_idx=0)
      SET drr_res_rpt->grp_cnt = (drr_res_rpt->grp_cnt+ 1)
      SET stat = alterlist(drr_res_rpt->grp,drr_res_rpt->grp_cnt)
      SET drr_res_rpt->grp[drr_res_rpt->grp_cnt].group = drr_preserved_tables_data->tbl[drr_tbl_idx].
      group
      SET drr_res_rpt->grp[drr_res_rpt->grp_cnt].refresh_ind = drr_preserved_tables_data->tbl[
      drr_tbl_idx].refresh_ind
      SET drr_grp_idx = drr_res_rpt->grp_cnt
     ENDIF
     IF ((drr_preserved_tables_data->tbl[drr_tbl_idx].refresh_ind=1)
      AND (drr_preserved_tables_data->tbl[drr_tbl_idx].restore_foul=1))
      FOR (drr_foul_idx = 1 TO drr_preserved_tables_data->tbl[drr_tbl_idx].reason_cnt)
        SET drr_res_rpt->grp[drr_grp_idx].tbl_cnt = (drr_res_rpt->grp[drr_res_rpt->grp_cnt].tbl_cnt+
        1)
        SET stat = alterlist(drr_res_rpt->grp[drr_grp_idx].tbl,drr_res_rpt->grp[drr_grp_idx].tbl_cnt)
        SET drr_res_rpt->grp[drr_grp_idx].tbl[drr_res_rpt->grp[drr_grp_idx].tbl_cnt].tbl_name =
        drr_preserved_tables_data->tbl[drr_tbl_idx].table_name
        SET drr_res_rpt->grp[drr_grp_idx].tbl[drr_res_rpt->grp[drr_grp_idx].tbl_cnt].foul_reason =
        drr_preserved_tables_data->tbl[drr_tbl_idx].restore_foul_reasons[drr_foul_idx].text
      ENDFOR
     ENDIF
     IF ((((drr_preserved_tables_data->tbl[drr_tbl_idx].refresh_ind=1)) OR ((
     drr_preserved_tables_data->tbl[drr_tbl_idx].refresh_ind=0)
      AND (drr_preserved_tables_data->tbl[drr_tbl_idx].pres_tbl_not_in_src=1))) )
      SET drr_res_rpt->grp[drr_grp_idx].fact_cnt = (drr_res_rpt->grp[drr_grp_idx].fact_cnt+ 1)
      SET stat = alterlist(drr_res_rpt->grp[drr_grp_idx].fact,drr_res_rpt->grp[drr_grp_idx].fact_cnt)
      SET drr_res_rpt->grp[drr_grp_idx].fact[drr_res_rpt->grp[drr_grp_idx].fact_cnt].tbl_name =
      drr_preserved_tables_data->tbl[drr_tbl_idx].table_name
      SET drr_res_rpt->grp[drr_grp_idx].fact[drr_res_rpt->grp[drr_grp_idx].fact_cnt].tbl_not_in_src
       = drr_preserved_tables_data->tbl[drr_tbl_idx].pres_tbl_not_in_src
      SET drr_res_rpt->grp[drr_grp_idx].fact[drr_res_rpt->grp[drr_grp_idx].fact_cnt].extra_src_cols
       = drr_preserved_tables_data->tbl[drr_tbl_idx].extra_src_cols
      SET drr_res_rpt->grp[drr_grp_idx].fact[drr_res_rpt->grp[drr_grp_idx].fact_cnt].extra_pre_cols
       = drr_preserved_tables_data->tbl[drr_tbl_idx].extra_pre_cols
      SET drr_res_rpt->grp[drr_grp_idx].fact[drr_res_rpt->grp[drr_grp_idx].fact_cnt].col_diff =
      drr_preserved_tables_data->tbl[drr_tbl_idx].col_diff
      SET drr_res_rpt->grp[drr_grp_idx].fact[drr_res_rpt->grp[drr_grp_idx].fact_cnt].refresh_ind =
      drr_preserved_tables_data->tbl[drr_tbl_idx].refresh_ind
      SET drr_res_rpt->grp[drr_grp_idx].fact[drr_res_rpt->grp[drr_grp_idx].fact_cnt].restore_foul =
      drr_preserved_tables_data->tbl[drr_tbl_idx].restore_foul
      SET drr_tbl_cnt = drr_res_rpt->grp[drr_grp_idx].fact_cnt
      FOR (drr_col_idx = 1 TO drr_preserved_tables_data->tbl[drr_tbl_idx].col_cnt)
        SET drr_res_rpt->grp[drr_grp_idx].fact[drr_tbl_cnt].col_cnt = (drr_res_rpt->grp[drr_grp_idx].
        fact[drr_tbl_cnt].col_cnt+ 1)
        SET drr_col_cnt = drr_res_rpt->grp[drr_grp_idx].fact[drr_tbl_cnt].col_cnt
        SET stat = alterlist(drr_res_rpt->grp[drr_grp_idx].fact[drr_tbl_cnt].col,drr_col_cnt)
        SET drr_res_rpt->grp[drr_grp_idx].fact[drr_tbl_cnt].col[drr_col_cnt].col_name =
        drr_preserved_tables_data->tbl[drr_tbl_idx].col[drr_col_idx].col_name
        SET drr_res_rpt->grp[drr_grp_idx].fact[drr_tbl_cnt].col[drr_col_cnt].diff_dtype_ind =
        drr_preserved_tables_data->tbl[drr_tbl_idx].col[drr_col_idx].diff_dtype_ind
        SET drr_res_rpt->grp[drr_grp_idx].fact[drr_tbl_cnt].col[drr_col_cnt].diff_dlength_ind =
        drr_preserved_tables_data->tbl[drr_tbl_idx].col[drr_col_idx].diff_dlength_ind
        SET drr_res_rpt->grp[drr_grp_idx].fact[drr_tbl_cnt].col[drr_col_cnt].diff_nullable_ind =
        drr_preserved_tables_data->tbl[drr_tbl_idx].col[drr_col_idx].diff_nullable_ind
        SET drr_res_rpt->grp[drr_grp_idx].fact[drr_tbl_cnt].col[drr_col_cnt].diff_default_ind =
        drr_preserved_tables_data->tbl[drr_tbl_idx].col[drr_col_idx].diff_default_ind
      ENDFOR
     ENDIF
   ENDFOR
   IF (get_unique_file("dm2_res_rpt",".rpt")=0)
    RETURN(0)
   ENDIF
   SET drr_rpt_file = dm_err->unique_fname
   IF (validate(drrr_responsefile_in_use,0)=1)
    SET drr_rpt_file = build(drrr_misc_data->active_dir,drr_rpt_file)
   ENDIF
   SET drr_preserved_tables_data->res_rep_name = drr_rpt_file
   SET dm_err->eproc = "Generating report for Restore Preserve Tables"
   IF ((drr_res_rpt->grp_cnt > 0))
    SET drr_preserved_tables_data->foul_grp_str = " "
    SET drr_rrd_str = " "
    SELECT INTO value(drr_rpt_file)
     FROM (dummyt t  WITH seq = 1)
     HEAD REPORT
      col 90, "RESTORE GROUP REPORT", row + 2,
      col 0, "Restore Groups: "
      FOR (drr_grp_idx = 1 TO drr_res_rpt->grp_cnt)
        IF ((drr_res_rpt->grp[drr_grp_idx].refresh_ind=1))
         IF ((drr_res_rpt->grp[drr_grp_idx].group != "NOPROMPT"))
          IF (drr_grp_idx=1
           AND (drr_grp_idx != drr_res_rpt->grp_cnt))
           drr_grp_str = concat(drr_res_rpt->grp[drr_grp_idx].group,", ")
          ELSEIF ((drr_grp_idx=drr_res_rpt->grp_cnt))
           drr_grp_str = concat(drr_grp_str,drr_res_rpt->grp[drr_grp_idx].group)
          ELSE
           drr_grp_str = concat(drr_grp_str,drr_res_rpt->grp[drr_grp_idx].group,", ")
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
      col 30, drr_grp_str
     DETAIL
      FOR (drr_grp_idx = 1 TO drr_res_rpt->grp_cnt)
        IF ((drr_res_rpt->grp[drr_grp_idx].tbl_cnt > 0))
         IF ((drr_preserved_tables_data->foul_grp_str=""))
          drr_preserved_tables_data->foul_grp_str = drr_res_rpt->grp[drr_grp_idx].group
         ELSE
          drr_preserved_tables_data->foul_grp_str = concat(drr_preserved_tables_data->foul_grp_str,
           ",",drr_res_rpt->grp[drr_grp_idx].group)
         ENDIF
        ENDIF
      ENDFOR
      IF ((drr_preserved_tables_data->foul_grp_str="*PRINTERS*")
       AND (drr_preserved_tables_data->foul_grp_str != "*RRD*")
       AND drr_grp_str="*RRD*")
       drr_preserved_tables_data->foul_grp_str = concat(drr_preserved_tables_data->foul_grp_str,
        ",RRD"), drr_rrd_str =
       "* RRD forced to be deselected along with PRINTERS (RRD  has no invalid tables)."
      ENDIF
      IF ((drr_preserved_tables_data->restore_foul=1))
       row + 1, col 0, "Invalid Restore Groups: ",
       col 30, drr_preserved_tables_data->foul_grp_str
       IF (drr_rrd_str != " ")
        row + 2, col 0, drr_rrd_str,
        row + 1, col 0,
        "USER ACTION: Invalid Restore Groups must be deselected in order to continue process."
       ELSE
        row + 2, col 0,
        "USER ACTION: Invalid Restore Groups must be deselected in order to continue process."
       ENDIF
       row + 2, col 0, "INVALID RESTORE GROUP/TABLE REASONS",
       row + 2, col 0, "GROUP",
       col 17, "TABLE", col 49,
       "REASON", row + 1, col 0,
       CALL print(fillstring(15,"-")), col 17,
       CALL print(fillstring(30,"-")),
       col 49,
       CALL print(fillstring(30,"-"))
       FOR (drr_grpr_idx = 1 TO drr_res_rpt->grp_cnt)
         IF ((drr_res_rpt->grp[drr_grpr_idx].tbl_cnt > 0))
          row + 1, col 0, drr_res_rpt->grp[drr_grpr_idx].group,
          drr_res_first = 1
          FOR (drr_tblr_idx = 1 TO drr_res_rpt->grp[drr_grpr_idx].tbl_cnt)
            IF (drr_res_first=1)
             drr_res_first = 0, col 17, drr_res_rpt->grp[drr_grpr_idx].tbl[drr_tblr_idx].tbl_name,
             col 49, drr_res_rpt->grp[drr_grpr_idx].tbl[drr_tblr_idx].foul_reason
            ELSE
             row + 1, col 17, drr_res_rpt->grp[drr_grpr_idx].tbl[drr_tblr_idx].tbl_name,
             col 49, drr_res_rpt->grp[drr_grpr_idx].tbl[drr_tblr_idx].foul_reason
            ENDIF
          ENDFOR
         ENDIF
       ENDFOR
       drr_str = concat(
        "* Tables with an asterisk (*) in following RESTORE TABLE/COLUMN DIFFERENCES section",
        "are those tables that are part of a restore group that must be deselected."), row + 2, col 0,
       drr_str
      ENDIF
      row + 2, col 0, "RESTORE TABLE/COLUMN DIFFERENCES",
      row + 2, col 49, "TABLE EXISTS",
      col 63, "MARK FOR", col 73,
      "EXTRA COLUMNS", col 88, "EXTRA COLUMNS",
      col 103, "  COLUMN", col 147,
      "DIFF", col 153, "DIFF",
      col 161, "DIFF", col 171,
      "DIFF", row + 1, col 0,
      "GROUP", col 17, "TABLE NAME",
      col 49, "IN SOURCE", col 63,
      "RESTORE", col 73, "IN SOURCE",
      col 88, "IN TARGET", col 103,
      "DIFFERENCE", col 115, "COLUMN NAME",
      col 147, "TYPE", col 153,
      "LENGTH", col 161, "NULLABLE",
      col 171, "DEFAULT", row + 1,
      col 0,
      CALL print(fillstring(15,"-")), col 17,
      CALL print(fillstring(30,"-")), col 49,
      CALL print(fillstring(12,"-")),
      col 63,
      CALL print(fillstring(8,"-")), col 73,
      CALL print(fillstring(13,"-")), col 88,
      CALL print(fillstring(13,"-")),
      col 103,
      CALL print(fillstring(10,"-")), col 115,
      CALL print(fillstring(30,"-")), col 147,
      CALL print(fillstring(4,"-")),
      col 153,
      CALL print(fillstring(6,"-")), col 161,
      CALL print(fillstring(8,"-")), col 171,
      CALL print(fillstring(7,"-")),
      drr_no_cols = 1
      FOR (drr_fact_idxg = 1 TO drr_res_rpt->grp_cnt)
        IF ((drr_res_rpt->grp[drr_fact_idxg].group != "NOPROMPT"))
         drr_tbl_first = 1
         FOR (drr_fact_idx = 1 TO drr_res_rpt->grp[drr_fact_idxg].fact_cnt)
           IF ((((drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].refresh_ind=1)
            AND (((drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].tbl_not_in_src=1)) OR ((((
           drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].extra_src_cols=1)) OR ((((drr_res_rpt->
           grp[drr_fact_idxg].fact[drr_fact_idx].extra_pre_cols=1)) OR ((drr_res_rpt->grp[
           drr_fact_idxg].fact[drr_fact_idx].col_diff=1))) )) )) ) OR ((drr_res_rpt->grp[
           drr_fact_idxg].fact[drr_fact_idx].refresh_ind=0)
            AND (drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].tbl_not_in_src=1))) )
            IF (drr_tbl_first=1)
             IF (drr_no_cols=1)
              drr_no_cols = 0
             ENDIF
             drr_tbl_first = 0
             IF ((drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].refresh_ind=1)
              AND (drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].restore_foul=1))
              row + 1, col 0, drr_res_rpt->grp[drr_fact_idxg].group,
              col 16, "*"
             ELSE
              row + 1, col 0, drr_res_rpt->grp[drr_fact_idxg].group
             ENDIF
             col 17, drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].tbl_name
            ELSE
             IF ((drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].refresh_ind=1)
              AND (drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].restore_foul=1))
              row + 1, col 16, "*",
              col 17, drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].tbl_name
             ELSE
              row + 1, col 17, drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].tbl_name
             ENDIF
            ENDIF
            IF ((drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].refresh_ind=1)
             AND (drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].tbl_not_in_src != 1))
             col 49, "Y"
            ELSE
             col 49, "N"
            ENDIF
            IF ((drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].refresh_ind=0)
             AND (drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].tbl_not_in_src=1))
             col 63, "N"
            ELSE
             col 63, "Y"
            ENDIF
            IF ((drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].tbl_not_in_src != 1))
             IF ((drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].refresh_ind=1)
              AND (drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].extra_src_cols=1))
              col 73, "Y"
             ELSE
              col 73, "N"
             ENDIF
             IF ((drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].refresh_ind=1)
              AND (drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].extra_pre_cols=1))
              col 88, "Y"
             ELSE
              col 88, "N"
             ENDIF
             IF ((drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].refresh_ind=1)
              AND (drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].col_diff=1))
              col 103, "Y", drr_col_first = 1
              FOR (drr_rep_col_idx = 1 TO drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].col_cnt)
                IF ((((drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].col[drr_rep_col_idx].
                diff_dtype_ind=1)) OR ((((drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].col[
                drr_rep_col_idx].diff_dlength_ind=1)) OR ((((drr_res_rpt->grp[drr_fact_idxg].fact[
                drr_fact_idx].col[drr_rep_col_idx].diff_nullable_ind=1)) OR ((drr_res_rpt->grp[
                drr_fact_idxg].fact[drr_fact_idx].col[drr_rep_col_idx].diff_default_ind=1))) )) )) )
                 IF (drr_col_first=1)
                  drr_col_first = 0, col 115, drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].col[
                  drr_rep_col_idx].col_name
                 ELSE
                  row + 1, col 115, drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].col[
                  drr_rep_col_idx].col_name
                 ENDIF
                ENDIF
                IF ((drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].col[drr_rep_col_idx].
                diff_dtype_ind=1))
                 col 147, "Y"
                ENDIF
                IF ((drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].col[drr_rep_col_idx].
                diff_dlength_ind=1))
                 col 153, "Y"
                ENDIF
                IF ((drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].col[drr_rep_col_idx].
                diff_nullable_ind=1))
                 col 161, "Y"
                ENDIF
                IF ((drr_res_rpt->grp[drr_fact_idxg].fact[drr_fact_idx].col[drr_rep_col_idx].
                diff_default_ind=1))
                 col 171, "Y"
                ENDIF
              ENDFOR
             ELSE
              col 103, "N"
             ENDIF
            ENDIF
           ENDIF
         ENDFOR
        ENDIF
      ENDFOR
      IF (drr_no_cols=1)
       row + 2, col 0, "No table/column differences found."
      ENDIF
     WITH nocounter, maxcol = 250, format = variable,
      formfeed = none
    ;end select
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (drr_no_cols=1)
    SET dm_err->eproc = concat("Skipping display of RESTORE GROUP REPORT (",drr_rpt_file,
     ") upon no differences")
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(1)
   ELSE
    IF (validate(drrr_responsefile_in_use,0)=1)
     SET dm_err->eproc = concat("Skipping display of RESTORE GROUP REPORT (",drr_rpt_file,")")
     CALL disp_msg("",dm_err->logfile,0)
     IF ((drer_email_list->email_cnt > 0)
      AND (drr_res_rpt->grp_cnt > 0))
      SET drer_email_det->msgtype = "ACTIONREQ"
      SET drer_email_det->status = "REPORT"
      SET drer_email_det->status_dt_tm = cnvtdatetime(curdate,curtime3)
      SET drer_email_det->step = "RESTORE GROUP REPORT"
      SET drer_email_det->email_level = 1
      SET drer_email_det->logfile = dm_err->logfile
      SET drer_email_det->err_ind = dm_err->err_ind
      SET drer_email_det->eproc = dm_err->eproc
      SET drer_email_det->emsg = dm_err->emsg
      SET drer_email_det->user_action = dm_err->user_action
      SET drer_email_det->attachment = drr_rpt_file
      CALL drer_add_body_text(concat("RESTORE GROUP REPORT was generated at ",format(drer_email_det->
         status_dt_tm,";;q")),1)
      CALL drer_add_body_text(concat("User Action : Please review the report to ensure ",
        "no invalid reasons exist for the tables."),0)
      CALL drer_add_body_text(concat("Report file name : ",trim(drr_rpt_file,3)),0)
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
      SET drer_email_det->step = "RESTORE GROUP REPORT"
      SET drer_email_det->email_level = 1
      SET drer_email_det->logfile = dm_err->logfile
      SET drer_email_det->err_ind = dm_err->err_ind
      SET drer_email_det->eproc = dm_err->eproc
      SET drer_email_det->emsg = dm_err->emsg
      SET drer_email_det->user_action = dm_err->user_action
      CALL drer_add_body_text(concat("RESTORE GROUP REPORT ","was displayed at ",format(
         drer_email_det->status_dt_tm,";;q")),1)
      CALL drer_add_body_text(concat("User Action : Return to dm2_domain_maint main session and ",
        "review Restore Group Report displayed on the screen.  Press <enter> to continue."),0)
      CALL drer_add_body_text(concat("Report file name is ccluserdir: ",drr_rpt_file),0)
      IF (drer_compose_email(null)=1)
       CALL drer_send_email(drer_email_det->subject,drer_email_det->file_name,drer_email_det->
        email_level)
      ENDIF
      CALL drer_reset_pre_err(null)
     ENDIF
     IF (dm2_disp_file(drr_rpt_file," ")=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_restore_col_mismatch(null)
   DECLARE drcm_pre_t = i2 WITH protect, noconstant(0)
   DECLARE drcm_tgt_t = i2 WITH protect, noconstant(0)
   DECLARE drcm_cur_t = i2 WITH protect, noconstant(0)
   DECLARE drcm_tgt_c = i2 WITH protect, noconstant(0)
   DECLARE drcm_cur_c = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Check for preserve restore column mismatch for source and target"
   FOR (drcm_pre_t = 1 TO drr_preserved_tables_data->cnt)
     IF ((drr_preserved_tables_data->tbl[drcm_pre_t].refresh_ind=1))
      SET drcm_tgt_t = drr_preserved_tables_data->tbl[drcm_pre_t].tgtsch_idx
      IF (drcm_tgt_t > 0)
       SET drcm_cur_t = 0
       SET drcm_cur_t = locateval(drcm_cur_t,1,cur_sch->tbl_cnt,drr_preserved_tables_data->tbl[
        drcm_pre_t].table_name,cur_sch->tbl[drcm_cur_t].tbl_name)
       IF (drcm_cur_t > 0)
        FOR (drcm_pre_c = 1 TO drr_preserved_tables_data->tbl[drcm_pre_t].col_cnt)
          SET drcm_tgt_c = 0
          SET drcm_tgt_c = locateval(drcm_tgt_c,1,tgtsch->tbl[drcm_tgt_t].tbl_col_cnt,
           drr_preserved_tables_data->tbl[drcm_pre_t].col[drcm_pre_c].col_name,tgtsch->tbl[drcm_tgt_t
           ].tbl_col[drcm_tgt_c].col_name)
          IF (drcm_tgt_c > 0)
           SET drcm_cur_c = 0
           SET drcm_cur_c = locateval(drcm_cur_c,1,cur_sch->tbl[drcm_cur_t].tbl_col_cnt,
            drr_preserved_tables_data->tbl[drcm_pre_t].col[drcm_pre_c].col_name,cur_sch->tbl[
            drcm_cur_t].tbl_col[drcm_cur_c].col_name)
           IF (drcm_cur_c > 0)
            IF (drr_restore_col_checks("C",drcm_cur_t,drcm_cur_c,drcm_pre_t,drcm_pre_c,
             drcm_tgt_t,drcm_tgt_c)=0)
             SET dm_err->err_ind = 1
             RETURN(0)
            ENDIF
           ENDIF
          ENDIF
        ENDFOR
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_restore_tbl_mismatch(null)
   DECLARE drtm_pre_t = i2 WITH protect, noconstant(0)
   DECLARE drtm_tgt_t = i2 WITH protect, noconstant(0)
   DECLARE drtm_cur_t = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Check for preserve restore table mismatch for source and target"
   FOR (drtm_pre_t = 1 TO drr_preserved_tables_data->cnt)
     IF ((drr_preserved_tables_data->tbl[drtm_pre_t].refresh_ind=1))
      SET drtm_tgt_t = 0
      SET drtm_tgt_t = locateval(drtm_tgt_t,1,tgtsch->tbl_cnt,drr_preserved_tables_data->tbl[
       drtm_pre_t].table_name,tgtsch->tbl[drtm_tgt_t].tbl_name)
      IF (drtm_tgt_t > 0)
       IF ((drr_clin_copy_data->process="RESTORE"))
        SET drtm_cur_t = 0
        SET drtm_cur_t = locateval(drtm_cur_t,1,cur_sch->tbl_cnt,drr_preserved_tables_data->tbl[
         drtm_pre_t].table_name,cur_sch->tbl[drtm_cur_t].tbl_name)
        IF (drtm_cur_t > 0)
         IF (drr_restore_tbl_checks("C",drtm_cur_t,drtm_pre_t)=0)
          RETURN(0)
         ENDIF
        ENDIF
       ELSE
        IF (drr_restore_tbl_checks("T",drtm_tgt_t,drtm_pre_t)=0)
         RETURN(0)
        ENDIF
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   IF (drr_restore_report(null)=0)
    RETURN(0)
   ENDIF
   IF ((drr_preserved_tables_data->restore_foul=1))
    SET dm_err->err_ind = 1
    SET dm_err->eproc =
    "Validating preserved tables to be restored for acceptable column differences in order to successfully complete restore."
    SET dm_err->emsg = concat(
     "Preserved tables to be restored have column differences that prevent ability to restore table(s)",
     ".  The following preserved table groups cannot be restored:  ",drr_preserved_tables_data->
     foul_grp_str,".  In order to continue process, de-select these groups that cannot be restored",
     ".  For explanation of those table column differences preventing restore, see")
    IF (validate(drrr_responsefile_in_use,0)=1)
     SET dm_err->emsg = concat(dm_err->emsg," ",drr_preserved_tables_data->res_rep_name,".")
    ELSE
     SET dm_err->emsg = concat(dm_err->emsg," ",drr_preserved_tables_data->res_rep_name,
      " located in CCLUSERDIR.")
    ENDIF
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_cleanup_drr_copy(dcdc_drr_cleanup)
   SET dcdc_drr_cleanup = "NONE"
   IF (validate(drrr_responsefile_in_use,0)=1)
    IF (cnvtupper(drrr_rf_data->tgt_expimp_drr_shadow_tables)="NO"
     AND cnvtupper(drr_clin_copy_data->process)="RESTORE")
     SET dcdc_drr_cleanup = "RR_ALL"
    ENDIF
   ELSEIF (cnvtupper(drr_clin_copy_data->process)="RESTORE")
    SET dcdc_drr_cleanup = "ALL"
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_load_chunk_imp_tbls(dlcit_db_link,dlcit_load_chunks_ind)
   DECLARE dlcit_dblink_exists = i2 WITH protect, noconstant(0)
   DECLARE dlcit_chunk_tbl_ndx = i4 WITH protect, noconstant(0)
   DECLARE dlcit_tmp = i4 WITH protect, noconstant(0)
   DECLARE dlcit_clu_tbl_ndx = i4 WITH protect, noconstant(0)
   DECLARE dlcit_di_tbl_owner = vc WITH protect, noconstant("")
   DECLARE dlcit_di_tbl_name = vc WITH protect, noconstant("")
   DECLARE dlcit_where_clause = vc WITH protect, noconstant("")
   DECLARE dlcit_dba_extents = vc WITH protect, noconstant("")
   DECLARE dlcit_dba_objects = vc WITH protect, noconstant("")
   DECLARE dlcit_part_cnt = i4 WITH protect, noconstant(0)
   IF (textlen(trim(dlcit_db_link))=0)
    SET dm_err->eproc = "No database link was specified. Skipping database link validation."
    CALL disp_msg(" ",dm_err->logfile,0)
   ELSE
    IF (drr_check_db_link(cnvtupper(trim(dlcit_db_link)),dlcit_dblink_exists)=0)
     RETURN(0)
    ENDIF
    IF (dlcit_dblink_exists=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat(dlcit_db_link," dblink does not exist. Cannot progress further.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   SET stat = initrec(drr_chunk_imp_tbls)
   SET dm_err->eproc = concat("Querying dm_info to check if any tables are marked for chunk imports")
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT
    IF (dlcit_dblink_exists=0)
     FROM dm_info di
    ELSE
     FROM (parser(concat("dm_info@",dlcit_db_link)) di)
    ENDIF
    INTO "nl:"
    di.info_name, di.info_number
    WHERE di.info_domain="DM2_RR_CHUNK_IMPORTS"
    ORDER BY di.info_name
    DETAIL
     dlcit_di_tbl_owner = substring(1,(findstring(".",di.info_name,1,0) - 1),di.info_name),
     dlcit_di_tbl_name = substring((findstring(".",di.info_name,1,1)+ 1),textlen(di.info_name),di
      .info_name), drr_chunk_imp_tbls->tbl_cnt = (drr_chunk_imp_tbls->tbl_cnt+ 1)
     IF (mod(drr_chunk_imp_tbls->tbl_cnt,10)=1)
      stat = alterlist(drr_chunk_imp_tbls->tbl,(drr_chunk_imp_tbls->tbl_cnt+ 9))
     ENDIF
     drr_chunk_imp_tbls->tbl[drr_chunk_imp_tbls->tbl_cnt].owner = dlcit_di_tbl_owner,
     drr_chunk_imp_tbls->tbl[drr_chunk_imp_tbls->tbl_cnt].table_name = dlcit_di_tbl_name,
     drr_chunk_imp_tbls->tbl[drr_chunk_imp_tbls->tbl_cnt].segment_name = dlcit_di_tbl_name,
     drr_chunk_imp_tbls->tbl[drr_chunk_imp_tbls->tbl_cnt].orig_num_chunks = di.info_number,
     drr_chunk_imp_tbls->tbl[drr_chunk_imp_tbls->tbl_cnt].num_chunks = di.info_number,
     drr_chunk_imp_tbls->tbl[drr_chunk_imp_tbls->tbl_cnt].chunk_cnt = 0
    FOOT REPORT
     stat = alterlist(drr_chunk_imp_tbls->tbl,drr_chunk_imp_tbls->tbl_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((drr_chunk_imp_tbls->tbl_cnt > 0))
    CALL echo(concat("***",build(drr_chunk_imp_tbls->tbl_cnt," tables qualified for chunk imports***"
       )))
   ELSE
    CALL echo("***No tables qualified for chunk imports***")
   ENDIF
   SET dm_err->eproc = "Querying dba_tables to fetch the list of clustered tables"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT
    IF (dlcit_dblink_exists=0)
     FROM dba_tables dt
    ELSE
     FROM (parser(concat("dba_tables@",dlcit_db_link)) dt)
    ENDIF
    INTO "nl:"
    WHERE dt.owner=currdbuser
     AND dt.cluster_name IS NOT null
    DETAIL
     IF (locateval(dlcit_clu_tbl_ndx,1,drr_chunk_imp_tbls->tbl_cnt,dt.table_name,drr_chunk_imp_tbls->
      tbl[dlcit_clu_tbl_ndx].table_name) > 0)
      drr_chunk_imp_tbls->tbl[dlcit_clu_tbl_ndx].segment_name = dt.cluster_name
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Querying dba_tables to fetch the list of partitioned tables"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT
    IF (dlcit_dblink_exists=0)
     FROM dba_tables dt
    ELSE
     FROM (parser(concat("dba_tables@",dlcit_db_link)) dt)
    ENDIF
    INTO "nl:"
    WHERE dt.owner=currdbuser
     AND dt.partitioned="YES"
    DETAIL
     IF (locateval(dlcit_clu_tbl_ndx,1,drr_chunk_imp_tbls->tbl_cnt,dt.table_name,drr_chunk_imp_tbls->
      tbl[dlcit_clu_tbl_ndx].table_name) > 0)
      drr_chunk_imp_tbls->tbl[dlcit_clu_tbl_ndx].part_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(drr_chunk_imp_tbls)
   ENDIF
   IF (dlcit_load_chunks_ind=1)
    SET dlcit_dba_extents = concat("dba_extents",evaluate(dlcit_dblink_exists,1,concat("@",
       dlcit_db_link," ")," "))
    SET dlcit_dba_objects = concat("dba_objects",evaluate(dlcit_dblink_exists,1,concat("@",
       dlcit_db_link," ")," "))
    IF ((dm_err->debug_flag > 1))
     CALL echo(concat("dlcit_dba_extents = ",dlcit_dba_extents))
     CALL echo(concat("dlcit_dba_objects = ",dlcit_dba_objects))
    ENDIF
    FOR (dlcit_tbl_idx = 1 TO drr_chunk_imp_tbls->tbl_cnt)
      SET dlcit_where_clause = concat("de.segment_type = 'TABLE'")
      IF ((drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].part_ind=1))
       SET dm_err->eproc = "Obtain number of partitions for partitioned table."
       CALL disp_msg(" ",dm_err->logfile,0)
       SELECT
        IF (dlcit_dblink_exists=0)
         FROM dba_objects do
        ELSE
         FROM (parser(concat("dba_objects@",dlcit_db_link)) do)
        ENDIF
        INTO "nl:"
        tbl_part_cnt = count(*)
        WHERE do.owner=currdbuser
         AND do.object_type="TABLE PARTITION"
         AND (do.object_name=drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].table_name)
        DETAIL
         dlcit_part_cnt = tbl_part_cnt
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        RETURN(0)
       ENDIF
       IF ((dlcit_part_cnt > drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].num_chunks))
        SET drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].num_chunks = 1
       ELSE
        SET drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].num_chunks = round((drr_chunk_imp_tbls->tbl[
         dlcit_tbl_idx].num_chunks/ dlcit_part_cnt),0)
       ENDIF
       SET dlcit_where_clause = concat("de.segment_type = 'TABLE PARTITION'")
       SET drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].part_cnt = dlcit_part_cnt
      ENDIF
      SET dm_err->eproc = concat("Load chunk tables to import during reference copy. Processing ",
       drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].table_name)
      IF ((dm_err->debug_flag > 0))
       CALL disp_msg(" ",dm_err->logfile,0)
      ENDIF
      SELECT INTO "nl:"
       FROM (
        (
        (SELECT
         min_rid = sqlpassthru(
          "dbms_rowid.rowid_create( 1, t.data_object_id, t.lo_fno, t.lo_block, 0 )"), max_rid =
         sqlpassthru("dbms_rowid.rowid_create( 1, t.data_object_id, t.hi_fno, t.hi_block, 10000 )")
         FROM (
          (
          (SELECT DISTINCT
           p.grp, sqlpassthru(concat(
             "first_value(p.relative_fno) over (partition by grp order by p.relative_fno, p.block_id rows ",
             "between unbounded preceding and unbounded following) lo_fno")), sqlpassthru(concat(
             "first_value(p.block_id) over (partition by grp order by p.relative_fno, p.block_id rows ",
             "between unbounded preceding and unbounded following) lo_block")),
           sqlpassthru(concat(
             "last_value(p.relative_fno) over (partition by grp order by p.relative_fno, p.block_id rows ",
             "between unbounded preceding and unbounded following) hi_fno")), sqlpassthru(concat(
             "last_value(p.block_id+blocks-1) over (partition by grp order by p.relative_fno, p.block_id rows ",
             "between unbounded preceding and unbounded following) hi_block")), sqlpassthru(
            "sum(blocks) over (partition by grp) sum_blocks"),
           p.data_object_id
           FROM (
            (
            (SELECT
             de.relative_fno, de.block_id, de.blocks,
             sqlpassthru(concat(
               "trunc((sum(de.blocks) over (order by de.relative_fno, de.block_id)-0.01)/(sum(de.blocks) ",
               "over ()/",cnvtstring(drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].num_chunks),")) grp")),
             do.data_object_id
             FROM (parser(concat(dlcit_dba_extents)) de),
              (parser(concat(dlcit_dba_objects)) do)
             WHERE parser(dlcit_where_clause)
              AND parser(concat("de.owner = '",drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].owner,"'"))
              AND parser(concat("de.segment_name = '",drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].
               segment_name,"'"))
              AND de.owner=do.owner
              AND de.segment_name=do.object_name
              AND de.segment_type=do.object_type))
            p)))
          t)
         ORDER BY min_rid
         WITH sqltype("c30","c30")))
        a)
       DETAIL
        drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].chunk_cnt = (drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].
        chunk_cnt+ 1), dlcit_tmp = drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].chunk_cnt
        IF (mod(dlcit_tmp,50)=1)
         stat = alterlist(drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].chunks,(dlcit_tmp+ 49))
        ENDIF
        drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].chunks[dlcit_tmp].min_rid = a.min_rid,
        drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].chunks[dlcit_tmp].max_rid = a.max_rid
       FOOT REPORT
        stat = alterlist(drr_chunk_imp_tbls->tbl[dlcit_tbl_idx].chunks,drr_chunk_imp_tbls->tbl[
         dlcit_tbl_idx].chunk_cnt)
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       RETURN(0)
      ENDIF
    ENDFOR
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(drr_chunk_imp_tbls)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_get_mixtbl_ref_rows(dgmrr_db_name)
   DECLARE dgmrr_table_name = vc WITH protect, noconstant("")
   DECLARE dgmrr_mix_idx = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = concat("Check if there are mixed table reference rows in ",trim(cnvtupper(
      dgmrr_db_name)),".")
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_MIXTBL_REFDATA_CNT"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->emsg = concat("There are no mixed table reference rows for ",trim(cnvtupper(
       dgmrr_db_name)),".")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
   ELSE
    SET dm_err->eproc = concat("Merge DM2_MIXTBL_REFDATA_CNT rows from ",trim(cnvtupper(dgmrr_db_name
       ))," to Admin DM_INFO.")
    CALL disp_msg("",dm_err->logfile,0)
    MERGE INTO dm2_admin_dm_info d
    USING (SELECT
     info_domain, info_name, info_number
     FROM dm_info
     WHERE info_domain="DM2_MIXTBL_REFDATA_CNT")
    DI ON (d.info_domain=di.info_domain
     AND d.info_name=concat(trim(dgmrr_db_name),"_",di.info_name))
    WHEN MATCHED THEN
    (UPDATE
     SET d.info_number = di.info_number, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE 1=1
    ;end update
    )
    WHEN NOT MATCHED THEN
    (INSERT  FROM d
     (info_domain, info_name, info_number,
     updt_dt_tm)
     VALUES("DM2_MIXTBL_REFDATA_CNT", concat(trim(dgmrr_db_name),"_",di.info_name), di.info_number,
     cnvtdatetime(curdate,curtime3))
     WITH nocounter
    ;end insert
    )
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = concat("Remove DM2_MIXTBL_REFDATA_CNT rows from ",trim(cnvtupper(
       dgmrr_db_name))," DM_INFO.")
    CALL disp_msg("",dm_err->logfile,0)
    DELETE  FROM dm_info di
     WHERE di.info_domain="DM2_MIXTBL_REFDATA_CNT"
    ;end delete
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Obtain latest mixed table reference rows for ",trim(cnvtupper(
      dgmrr_db_name)),".")
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info d
    WHERE d.info_domain="DM2_MIXTBL_REFDATA_CNT"
     AND d.info_name=patstring(concat(dgmrr_db_name,"_*"))
     AND d.info_number > 0
    DETAIL
     dgmrr_table_name = replace(d.info_name,concat(dgmrr_db_name,"_"),""), dgmrr_mix_idx = 0,
     dgmrr_mix_idx = locateval(dgmrr_mix_idx,1,drr_mixed_tables_data->cnt,dgmrr_table_name,
      drr_mixed_tables_data->tbl[dgmrr_mix_idx].table_name)
     IF (dgmrr_mix_idx > 0)
      drr_mixed_tables_data->tbl[dgmrr_mix_idx].ref_num_rows_set_ind = 1, drr_mixed_tables_data->tbl[
      dgmrr_mix_idx].ref_num_rows = d.info_number
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_upd_mixtbl_ref_rows(dumrr_db_name,dumrr_run_id)
   FREE RECORD dumrr_mixed_tables_data
   RECORD dumrr_mixed_tables_data(
     1 cnt = i4
     1 tbl[*]
       2 table_name = vc
       2 num_rows = f8
   )
   DECLARE dumrr_info_name = vc WITH protect, noconstant("")
   DECLARE dumrr_info_number = i4 WITH protect, noconstant(0)
   DECLARE dumrr_idx = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = concat("Obtain latest mixed table reference rows for ",trim(cnvtupper(
      dumrr_db_name)),".")
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    d.table_name, dumrr_mixed_row_cnt_sum = sum(d.row_cnt)
    FROM dm2_ddl_ops_log d
    WHERE d.run_id=dumrr_run_id
     AND d.op_type="EXPORT/IMPORT - MIXED DATA (REMOTE)"
     AND d.status="COMPLETE"
    GROUP BY d.table_name
    HEAD REPORT
     dumrr_mixed_tables_data->cnt = 0, stat = alterlist(dumrr_mixed_tables_data->tbl,0)
    DETAIL
     dumrr_mixed_tables_data->cnt = (dumrr_mixed_tables_data->cnt+ 1)
     IF (mod(dumrr_mixed_tables_data->cnt,10)=1)
      stat = alterlist(dumrr_mixed_tables_data->tbl,(dumrr_mixed_tables_data->cnt+ 9))
     ENDIF
     dumrr_mixed_tables_data->tbl[dumrr_mixed_tables_data->cnt].table_name = d.table_name,
     dumrr_mixed_tables_data->tbl[dumrr_mixed_tables_data->cnt].num_rows = dumrr_mixed_row_cnt_sum
    FOOT REPORT
     stat = alterlist(dumrr_mixed_tables_data->tbl,dumrr_mixed_tables_data->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Update Admin DM_INFO rows for ",trim(cnvtupper(dumrr_db_name)),".")
   CALL disp_msg("",dm_err->logfile,0)
   FOR (dumrr_idx = 1 TO dumrr_mixed_tables_data->cnt)
     SET dm_err->eproc = concat("Update Admin DM_INFO row for ",trim(dumrr_mixed_tables_data->tbl[
       dumrr_idx].table_name))
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     SET dumrr_info_name = concat(trim(cnvtupper(dumrr_db_name)),"_",trim(dumrr_mixed_tables_data->
       tbl[dumrr_idx].table_name))
     SET dumrr_info_number = dumrr_mixed_tables_data->tbl[dumrr_idx].num_rows
     MERGE INTO dm2_admin_dm_info d
     USING DUAL ON (d.info_domain="DM2_MIXTBL_REFDATA_CNT"
      AND d.info_name=trim(dumrr_info_name))
     WHEN MATCHED THEN
     (UPDATE
      SET d.info_number = dumrr_info_number, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE 1=1
     ;end update
     )
     WHEN NOT MATCHED THEN
     (INSERT  FROM d
      (info_domain, info_name, info_number,
      updt_dt_tm)
      VALUES("DM2_MIXTBL_REFDATA_CNT", trim(dumrr_info_name), dumrr_info_number,
      cnvtdatetime(curdate,curtime3))
      WITH nocounter
     ;end insert
     )
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     COMMIT
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_refresh_drop_restrict(drdr_mode,drdr_restart_ind)
   DECLARE drdr_info_char = vc WITH protect, noconstant("")
   IF ( NOT (drdr_mode IN ("I", "D")))
    SET dm_err->eproc = "Verify the input mode in DM_INFO to drop V500 user in restrict mode."
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid input mode option."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm2_install_schema->dbase_name = "ADMIN"
   SET dm2_install_schema->u_name = "CDBA"
   SET dm2_install_schema->p_word = drrr_rf_data->adm_db_user_pwd
   SET dm2_install_schema->connect_str = drrr_rf_data->adm_db_cnct_str
   EXECUTE dm2_connect_to_dbase "CO"
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Querying DM_INFO for the row to restart target database checkpoint row."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_REFRESH_RESTRICT_DATABASE"
     AND di.info_name=cnvtupper(drrr_rf_data->tgt_db_name)
    DETAIL
     drdr_info_char = di.info_char
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (drdr_mode="D")
    IF (curqual=1)
     SET dm_err->eproc = "Removing the restrict database row from DM_INFO."
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     DELETE  FROM dm_info di
      WHERE di.info_domain="DM2_REFRESH_RESTRICT_DATABASE"
       AND di.info_name=cnvtupper(drrr_rf_data->tgt_db_name)
      WITH nocounter
     ;end delete
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
     COMMIT
    ELSE
     SET dm_err->eproc =
     "Could not find the restrict database checkpoint row from DM_INFO. Possible manual intervention occurred."
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
    ENDIF
   ELSE
    IF (((curqual=1
     AND drdr_restart_ind=1
     AND drdr_info_char="INITIATED") OR (curqual=0
     AND drdr_restart_ind=0)) )
     IF (drr_drop_user_restrict_ksh(null)=0)
      RETURN(0)
     ENDIF
    ELSE
     SET dm_err->eproc =
     "Database should be in stable state to continue without the need to put database in restricted mode."
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
    ENDIF
   ENDIF
   SET dm2_install_schema->u_name = "SYS"
   SET dm2_install_schema->p_word = drrr_rf_data->tgt_sys_pwd
   SET dm2_install_schema->connect_str = drrr_rf_data->tgt_db_cnct_str
   SET dm2_install_schema->dbase_name = '"TARGET"'
   EXECUTE dm2_connect_to_dbase "CO"
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_drop_user_restrict_ksh(null)
   DECLARE ddurk_full_ksh_name = vc WITH protect, noconstant("")
   DECLARE ddurk_line = vc WITH protect, noconstant("")
   DECLARE ddurk_text = vc WITH protect, noconstant("")
   DECLARE ddurk_tgt_db_ver = i4 WITH protect, noconstant(0)
   DECLARE ddurk_tgt_ora_home = vc WITH protect, noconstant("")
   DECLARE ddurk_sqlfile = vc WITH protect, noconstant("")
   DECLARE ddurk_logfile = vc WITH protect, noconstant("")
   DECLARE ddurk_full_logfile = vc WITH protect, noconstant("")
   DECLARE ddurk_file_loc = vc WITH protect, noconstant("")
   DECLARE ddurk_cmd = vc WITH protect, noconstant("")
   DECLARE ddurk_ksh_error_msg = vc WITH protect, noconstant("")
   SET ddurk_full_ksh_name = concat("dm2_restrict_",cnvtlower(drrr_rf_data->tgt_db_name),"_db.ksh")
   SET ddurk_file_loc = drrr_rf_data->tgt_db_temp_dir
   SET ddurk_sqlfile = concat(ddurk_file_loc,"restrict_drop_v500.sql")
   SET ddurk_du_sqlfile = concat(ddurk_file_loc,"restrict_drop_user_v500.sql")
   SET ddurk_logfile = concat(ddurk_file_loc,"restrict_drop_v500.log")
   SET ddurk_du_logfile = concat(ddurk_file_loc,"restrict_drop_user_v500.log")
   SET ddurk_full_logfile = concat(ddurk_file_loc,"restrict_drop_v500_full.log")
   SET ddurk_tgt_db_ver = cnvtint(drrr_rf_data->tgt_db_oracle_ver)
   IF (findstring("/",drrr_rf_data->tgt_db_oracle_home,1,1)=size(drrr_rf_data->tgt_db_oracle_home))
    SET ddurk_tgt_ora_home = substring(1,(size(drrr_rf_data->tgt_db_oracle_home,1) - 1),drrr_rf_data
     ->tgt_db_oracle_home)
   ELSE
    SET ddurk_tgt_ora_home = drrr_rf_data->tgt_db_oracle_home
   ENDIF
   SET dm_err->eproc = concat("Create ksh file ",ddurk_full_ksh_name)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO value(ddurk_full_ksh_name)
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     IF (ddurk_tgt_db_ver=19)
      col 0, "#!/bin/ksh", row + 1,
      ddurk_line = build("TGT_DB_NAME=",cnvtupper(drrr_rf_data->tgt_db_name)), col 0, ddurk_line,
      row + 1, ddurk_line = concat("export ORACLE_SID=",cnvtlower(drrr_rf_data->tgt_cdb_cnct_str)),
      col 0,
      ddurk_line, row + 1, ddurk_line = concat("export ORACLE_HOME=",ddurk_tgt_ora_home),
      col 0, ddurk_line, row + 1,
      col 0, "USER_TO_DROP=V500", row + 1,
      ddurk_line = build("DROP_V500_SQLFILE=",ddurk_sqlfile), col 0, ddurk_line,
      row + 1, ddurk_line = build("DROP_USER_V500_SQLFILE=",ddurk_du_sqlfile), col 0,
      ddurk_line, row + 1, ddurk_line = build("DROP_V500_SQL_LOGFILE=",ddurk_logfile),
      col 0, ddurk_line, row + 1,
      ddurk_line = build("DROP_USER_V500_SQL_LOGFILE=",ddurk_du_logfile), col 0, ddurk_line,
      row + 1, ddurk_line = build("DROP_V500_LOGFILE=",ddurk_full_logfile), col 0,
      ddurk_line, row + 1, col 0,
      "USER_EXISTS_IND=0", row + 1, col 0,
      " ", row + 1, col 0,
      "CheckDBMode()", row + 1, col 0,
      "{", row + 1, col 0,
      "  rm -f ${DROP_V500_SQLFILE}", row + 1, col 0,
      "  rm -f ${DROP_V500_SQL_LOGFILE}", row + 1, col 0,
      '  echo "alter session set container=${TGT_DB_NAME};" > ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "set serveroutput on;" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "declare " >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "  db_mode varchar2(10);" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "  restricted_mode varchar2(10);" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "begin" >> ${DROP_V500_SQLFILE}', row + 1, ddurk_line = concat(
       '  echo " select open_mode,restricted into db_mode,restricted_mode from v\$pdbs ',
       ^ where name = '${TGT_DB_NAME}';" >> ${DROP_V500_SQLFILE}^),
      col 0, ddurk_line, row + 1,
      col 0, ^  echo " dbms_output.put_line('DB_MODE is: ' || db_mode);" >> ${DROP_V500_SQLFILE}^,
      row + 1,
      col 0,
      ^  echo " dbms_output.put_line('RESTRICTED_MODE is: ' || restricted_mode);" >> ${DROP_V500_SQLFILE}^,
      row + 1,
      col 0, '  echo " EXCEPTION" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, '  echo "  when others then raise;" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, '  echo "end;" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, '  echo "/" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, '  echo "exit" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0,
      "  ${ORACLE_HOME}/bin/sqlplus '/as sysdba' @${DROP_V500_SQLFILE} > ${DROP_V500_SQL_LOGFILE}",
      row + 1,
      col 0, "  ", row + 1,
      col 0, "  if [[ ! -f ${DROP_V500_SQL_LOGFILE} ]]", row + 1,
      col 0, "  then", row + 1,
      col 0, '   EchoMessage "CER-0000:error - ${DROP_V500_SQL_LOGFILE} file not found"', row + 1,
      col 0, '   EchoMessage `date` "KSH for Setup ending in error."', row + 1,
      col 0, "   exit 1", row + 1,
      col 0, "  fi", row + 1,
      col 0, "  ", row + 1,
      col 0, '  if [[ `grep -E "^ORA-" ${DROP_V500_SQL_LOGFILE} | wc -l` -ne 0 ]]', row + 1,
      col 0, "  then", row + 1,
      col 0, '    EchoMessage "CER-0001:error - Error retrieving database mode info."', row + 1,
      col 0, "    cat ${DROP_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}", row + 1,
      col 0, '    EchoMessage "`date`: KSH ending in error."', row + 1,
      col 0, "    exit 1", row + 1,
      col 0, "  fi", row + 1,
      col 0, '  DB_MODE=`grep "DB_MODE is: " ${DROP_V500_SQL_LOGFILE} | cut -d" " -f3-4`', row + 1,
      col 0,
      '  RESTRICTED_MODE=`grep "RESTRICTED_MODE is: " ${DROP_V500_SQL_LOGFILE} | cut -d" " -f3`', row
       + 1,
      col 0, '  EchoMessage "`date`: DB_MODE=${DB_MODE}"', row + 1,
      col 0, '  EchoMessage "`date`: RESTRICTED=${RESTRICTED_MODE}"', row + 1,
      col 0, "}", row + 1,
      col 0, " ", row + 1,
      col 0, "StartupDB()", row + 1,
      col 0, "{", row + 1,
      col 0, "  rm -f ${DROP_V500_SQLFILE}", row + 1,
      col 0, "  rm -f ${DROP_V500_SQL_LOGFILE}", row + 1,
      col 0,
      "  #Logfile will not be removed since output from CheckDBMode function is evaluated from the logfile.",
      row + 1,
      col 0, "  arg1=$1", row + 1,
      col 0, "  ", row + 1,
      col 0, '  echo "alter session set container=${TGT_DB_NAME};" > ${DROP_V500_SQLFILE}', row + 1,
      col 0, '  if [[ "$arg1" = "READ WRITE" ]]', row + 1,
      col 0, "  then", row + 1,
      col 0, '    echo "startup;" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, '    echo "exit;" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, '  elif [[ "$arg1" = "RESTRICT" ]]', row + 1,
      col 0, "  then", row + 1,
      col 0, '    echo "startup restrict;" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, '    echo "exit;" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, "  fi", row + 1,
      col 0, " ", row + 1,
      col 0,
      "  ${ORACLE_HOME}/bin/sqlplus '/as sysdba' @${DROP_V500_SQLFILE} > ${DROP_V500_SQL_LOGFILE}",
      row + 1,
      col 0, " ", row + 1,
      col 0, "  if [[ ! -f ${DROP_V500_SQL_LOGFILE} ]]", row + 1,
      col 0, "  then", row + 1,
      col 0, '    EchoMessage "CER-0000:error - ${DROP_V500_SQL_LOGFILE} file not found"', row + 1,
      col 0, '    EchoMessage `date` "KSH for Setup ending in error."', row + 1,
      col 0, "    exit 1", row + 1,
      col 0, "  fi", row + 1,
      col 0, " ", row + 1,
      col 0, '  if [[ `grep -E "^ORA-" ${DROP_V500_SQL_LOGFILE} | wc -l` -ne 0 ]]', row + 1,
      col 0, "  then", row + 1,
      col 0, '    EchoMessage "CER-0003:error - Error while starting the database in $arg1 mode."',
      row + 1,
      col 0, "    cat ${DROP_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}", row + 1,
      col 0, '    EchoMessage "`date`: KSH ending in error."', row + 1,
      col 0, "    exit 1", row + 1,
      col 0, "  fi", row + 1,
      col 0, " ", row + 1,
      col 0, "  CheckDBMode", row + 1,
      col 0, "   ", row + 1,
      col 0, '  if [[ ${DB_MODE} == "READ WRITE" ]]', row + 1,
      col 0, "  then", row + 1,
      col 0, '    EchoMessage "`date`: Pluggable database has been opened in $arg1 mode."', row + 1,
      col 0, "  else", row + 1,
      col 0,
      '    EchoMessage "CER-0010:error - Pluggable database is not running in READ WRITE mode."', row
       + 1,
      col 0, "    cat ${DROP_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}", row + 1,
      col 0, '    EchoMessage "`date`: KSH ending in error."', row + 1,
      col 0, "    exit 1", row + 1,
      col 0, "  fi", row + 1,
      ddurk_line = concat('  if [[ $arg1 == "RESTRICT" && ${RESTRICTED_MODE} == "YES" || ',
       '$arg1 == "READ WRITE" && ${RESTRICTED_MODE} == "NO" ]]'), col 0, ddurk_line,
      row + 1, col 0, "  then",
      row + 1, col 0, '    EchoMessage "`date`: Pluggable database is opened in $arg1 mode."',
      row + 1, col 0, "  else",
      row + 1, col 0,
      '    EchoMessage "CER-0011:error - Pluggable database is not in appropriate RESTRICTED mode." "1"',
      row + 1, col 0, "    cat ${DROP_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}",
      row + 1, col 0, '    EchoMessage "`date`: KSH ending in error."',
      row + 1, col 0, "    exit 1",
      row + 1, col 0, "  fi",
      row + 1, col 0, "  ",
      row + 1, col 0, "  #Starting DB service",
      row + 1, col 0, "  StartupService ",
      row + 1, col 0, "}",
      row + 1, col 0, " ",
      row + 1, col 0, "StartupService() ",
      row + 1, col 0, "{ ",
      row + 1, col 0, "  rm -f ${DROP_V500_SQL_LOGFILE} ",
      row + 1, col 0,
      "  ${ORACLE_HOME}/bin/srvctl start service -d c${TGT_DB_NAME} > ${DROP_V500_SQL_LOGFILE} ",
      row + 1, col 0, " ",
      row + 1, col 0, "  if [[ ! -f ${DROP_V500_SQL_LOGFILE} ]] ",
      row + 1, col 0, "  then ",
      row + 1, col 0, '    EchoMessage "CER-0000:error - ${DROP_V500_SQL_LOGFILE} file not found"',
      row + 1, col 0, '    EchoMessage `date` "KSH for Setup ending in error."',
      row + 1, col 0, "    exit 1 ",
      row + 1, col 0, "  fi ",
      row + 1, col 0, " ",
      row + 1, col 0,
      "  $ORACLE_HOME/bin/srvctl status service -d c${TGT_DB_NAME} -s s${TGT_DB_NAME} > ${DROP_V500_SQL_LOGFILE}",
      row + 1, col 0,
      '  SERVICE_RUNNING_IND=`grep -i "Service s${TGT_DB_NAME} is running" ${DROP_V500_SQL_LOGFILE} | wc -l`',
      row + 1, col 0,
      '  echo "`date`:Service running indicator(1 - up/0 - down): ${SERVICE_RUNNING_IND}" >>${DROP_V500_SQL_LOGFILE}',
      row + 1, col 0, "  if [[ ${SERVICE_RUNNING_IND} -eq 0 ]]",
      row + 1, col 0, "  then",
      row + 1, col 0, '    EchoMessage "CER-0009:error - Database service is not running."',
      row + 1, col 0, "    cat ${DROP_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}",
      row + 1, col 0, '    EchoMessage "`date`: KSH ending in error."',
      row + 1, col 0, "    exit 1",
      row + 1, col 0, "  else ",
      row + 1, col 0, '    EchoMessage "`date`: Database service is up and running."',
      row + 1, col 0, "  fi",
      row + 1, col 0, "} ",
      row + 1, col 0, " ",
      row + 1, col 0, "OpenDB()",
      row + 1, col 0, "{",
      row + 1, col 0, "  rm -f ${DROP_V500_SQL_LOGFILE}",
      row + 1, col 0, "  rm -f ${DROP_V500_SQLFILE}",
      row + 1, ddurk_line = concat('  echo "alter session set container=${TGT_DB_NAME};" | ',
       'echo "alter pluggable database ${TGT_DB_NAME} open force;" | ',
       "${ORACLE_HOME}/bin/sqlplus '/as sysdba' > ${DROP_V500_SQL_LOGFILE}"), col 0,
      ddurk_line, row + 1, col 0,
      " ", row + 1, col 0,
      "  if [[ ! -f ${DROP_V500_SQL_LOGFILE} ]]", row + 1, col 0,
      "  then", row + 1, col 0,
      '    EchoMessage "CER-0000:error - ${DROP_V500_SQL_LOGFILE} file not found"', row + 1, col 0,
      '    EchoMessage `date` "KSH for Setup ending in error."', row + 1, col 0,
      "    exit 1", row + 1, col 0,
      "  fi", row + 1, col 0,
      " ", row + 1, col 0,
      '  if [[ `grep -E "^ORA-" ${DROP_V500_SQL_LOGFILE} | wc -l` -ne 0 ]]', row + 1, col 0,
      "  then", row + 1, col 0,
      '    EchoMessage "CER-0004:error - Error while starting the database in READ WRITE mode."', row
       + 1, col 0,
      "    cat ${DROP_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}", row + 1, col 0,
      '    EchoMessage "`date`: KSH ending in error."', row + 1, col 0,
      "    exit 1", row + 1, col 0,
      "  fi ", row + 1, col 0,
      '  EchoMessage "`date`: Pluggable database is opened with force."', row + 1, col 0,
      "}", row + 1, col 0,
      " ", row + 1, col 0,
      "UpdateAdminCheckpointRow()", row + 1, col 0,
      "{", row + 1, col 0,
      "  rm -f ${DROP_V500_SQLFILE}", row + 1, col 0,
      "  rm -f ${DROP_V500_SQL_LOGFILE}", row + 1, col 0,
      "  arg1=$1", row + 1, col 0,
      '  EchoMessage "`date`: Attempting to merge Admin checkpoint row with $arg1 status."', row + 1,
      col 0,
      "  #Merging into dm_info to mark the initiation of restrict database", row + 1, col 0,
      '  echo "begin " > ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "  merge into dm_info x " >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "  using dual " >> ${DROP_V500_SQLFILE}', row + 1, ddurk_line = concat(
       ^  echo "  on (x.info_domain='DM2_REFRESH_RESTRICT_DATABASE' and x.info_name='${TGT_DB_NAME}')"^,
       "  >> ${DROP_V500_SQLFILE}"),
      col 0, ddurk_line, row + 1,
      col 0, '  echo "  when matched then " >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, ^  echo "   update set x.info_char = '$arg1', " >> ${DROP_V500_SQLFILE}^, row + 1,
      col 0, '  echo "   x.updt_dt_tm = sysdate " >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, '  echo "  when not matched then " >> ${DROP_V500_SQLFILE}', row + 1,
      col 0,
      '  echo "   insert(x.info_domain, x.info_name, x.info_char, x.updt_dt_tm) " >> ${DROP_V500_SQLFILE}',
      row + 1,
      col 0,
      ^  echo "   values ('DM2_REFRESH_RESTRICT_DATABASE','${TGT_DB_NAME}','$arg1',sysdate); " >> ${DROP_V500_SQLFILE}^,
      row + 1,
      col 0, '  echo "   commit;"   >> ${DROP_V500_SQLFILE}     ', row + 1,
      col 0, '  echo "exception "  >> ${DROP_V500_SQLFILE} ', row + 1,
      col 0, '  echo "  when others then"  >> ${DROP_V500_SQLFILE} ', row + 1,
      col 0, '  echo "    dbms_output.put_line(sqlerrm);"  >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, '  echo "    rollback; "  >> ${DROP_V500_SQLFILE} ', row + 1,
      col 0, '  echo "end; "  >> ${DROP_V500_SQLFILE} ', row + 1,
      col 0, '  echo "/"   >> ${DROP_V500_SQLFILE} ', row + 1,
      col 0, '  echo "exit; " >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, "  ", row + 1,
      ddurk_line = build(" ${ORACLE_HOME}/bin/sqlplus -L '",drrr_rf_data->adm_db_user,"/",
       drrr_rf_data->adm_db_user_pwd,"@",
       drrr_rf_data->adm_db_cnct_str,"' @${DROP_V500_SQLFILE} > ${DROP_V500_SQL_LOGFILE} "), col 0,
      ddurk_line,
      row + 1, col 0, "  if [[ ! -f ${DROP_V500_SQL_LOGFILE} ]]",
      row + 1, col 0, "  then",
      row + 1, col 0, '    EchoMessage "CER-0000:error - ${DROP_V500_SQL_LOGFILE} file not found"',
      row + 1, col 0, '    EchoMessage "`date`: KSH ending in error."',
      row + 1, col 0, "    exit 1",
      row + 1, col 0, "  fi",
      row + 1, col 0, " ",
      row + 1, col 0, '  if [[ `grep -E "^ORA-" ${DROP_V500_SQL_LOGFILE} | wc -l` -ne 0 ]]',
      row + 1, col 0, "  then",
      row + 1, col 0,
      '    EchoMessage "CER-0005:error - Error while merging dm_info row with $arg1 status."',
      row + 1, col 0, "    cat ${DROP_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}",
      row + 1, col 0, '    EchoMessage "`date`: KSH ending in error."',
      row + 1, col 0, "    exit 1",
      row + 1, col 0, "  fi",
      row + 1, col 0, '  EchoMessage "`date`: Admin checkpoint row merged with $arg1 status."',
      row + 1, col 0, "}",
      row + 1, col 0, " ",
      row + 1, col 0, "CheckDBUserExistence()",
      row + 1, col 0, "{",
      row + 1, col 0, "  rm -f ${DROP_V500_SQLFILE}",
      row + 1, col 0, "  rm -f ${DROP_V500_SQL_LOGFILE}",
      row + 1, col 0, "  USER_EXISTS_IND=0",
      row + 1, col 0, '  echo "alter session set container=${TGT_DB_NAME};" > ${DROP_V500_SQLFILE}',
      row + 1, col 0, '  echo "set serveroutput on;" >> ${DROP_V500_SQLFILE}',
      row + 1, col 0, '  echo "declare " >> ${DROP_V500_SQLFILE}',
      row + 1, col 0, '  echo "  user_exists_ind number := 0;" >> ${DROP_V500_SQLFILE}',
      row + 1, col 0, '  echo "begin" >> ${DROP_V500_SQLFILE}',
      row + 1, ddurk_line = concat('  echo "select count(*) into user_exists_ind from dba_users ',
       ^where username='${USER_TO_DROP}';" >> ${DROP_V500_SQLFILE}^), col 0,
      ddurk_line, row + 1, col 0,
      ^  echo " dbms_output.put_line('USER_EXISTS_IND is: ' || user_exists_ind);" >> ${DROP_V500_SQLFILE}^,
      row + 1, col 0,
      '  echo " EXCEPTION" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "  when others then raise;" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "end;" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "/" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "exit" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      "  ", row + 1, col 0,
      "  ${ORACLE_HOME}/bin/sqlplus '/as sysdba' @${DROP_V500_SQLFILE} > ${DROP_V500_SQL_LOGFILE}",
      row + 1, col 0,
      " ", row + 1, col 0,
      "  if [[ ! -f ${DROP_V500_SQL_LOGFILE} ]] ", row + 1, col 0,
      "  then ", row + 1, col 0,
      '    EchoMessage "CER-0000:error - ${DROP_V500_SQL_LOGFILE} file not found"', row + 1, col 0,
      '    EchoMessage `date` "KSH for Setup ending in error."', row + 1, col 0,
      "    exit 1 ", row + 1, col 0,
      "  fi ", row + 1, col 0,
      "  ", row + 1, col 0,
      '  if [[ `grep -E "^ORA-" ${DROP_V500_SQL_LOGFILE} | wc -l` -ne 0 ]] ', row + 1, col 0,
      "  then ", row + 1, col 0,
      '    EchoMessage "CER-0008:error - Error retrieving user info."', row + 1, col 0,
      "    cat ${DROP_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}", row + 1, col 0,
      '    EchoMessage "`date`: KSH ending in error."', row + 1, col 0,
      "    exit 1 ", row + 1, col 0,
      "  fi ", row + 1, col 0,
      "  ", row + 1, col 0,
      '  USER_EXISTS_IND=`grep "USER_EXISTS_IND is: " ${DROP_V500_SQL_LOGFILE} | cut -d" " -f3`    ',
      row + 1, col 0,
      "  ", row + 1, col 0,
      "  if [[ ${USER_EXISTS_IND} -eq 0 ]] ", row + 1, col 0,
      "  then ", row + 1, col 0,
      '    EchoMessage "`date`: User ${USER_TO_DROP} does not exist."', row + 1, col 0,
      "  else ", row + 1, col 0,
      '    EchoMessage "`date`: User ${USER_TO_DROP} exists."', row + 1, col 0,
      "  fi ", row + 1, col 0,
      "} ", row + 1, col 0,
      " ", row + 1, col 0,
      "EchoMessage()", row + 1, col 0,
      "{", row + 1, col 0,
      " echo $1", row + 1, col 0,
      ' echo "`date`: $1" >> ${DROP_V500_LOGFILE}', row + 1, col 0,
      "}", row + 1, col 0,
      " ", row + 1, col 0,
      "#Main process", row + 1, col 0,
      "rm -f ${DROP_V500_LOGFILE}", row + 1, col 0,
      'EchoMessage "`date`: Beginning of the logfile to drop ${USER_TO_DROP} user."', row + 1, col 0,
      " ", row + 1, col 0,
      "#Check the status of the database.", row + 1, col 0,
      "#Verify the open_mode is in a valid state to be shutdown.", row + 1, col 0,
      "CheckDBMode", row + 1, col 0,
      " ", row + 1, col 0,
      "#If the database is in any mode other than READ WRITE, open the database in READ WRITE mode.",
      row + 1, col 0,
      'if [[ ${DB_MODE} != "READ WRITE" ]]', row + 1, col 0,
      "then  ", row + 1, col 0,
      "  StartupDB 'READ WRITE'", row + 1, col 0,
      "fi", row + 1, col 0,
      'if [[ ${RESTRICTED_MODE} == "YES" ]]', row + 1, col 0,
      "then", row + 1, col 0,
      "  OpenDB", row + 1, col 0,
      "fi", row + 1, col 0,
      " ", row + 1, col 0,
      "UpdateAdminCheckpointRow 'INITIATED' ", row + 1, col 0,
      " ", row + 1, col 0,
      "CheckDBMode", row + 1, col 0,
      "#Check if user exists.", row + 1, col 0,
      "CheckDBUserExistence", row + 1, col 0,
      " ", row + 1, col 0,
      "#Perform shutting down the database, startup in restrict to drop the user operations only ",
      row + 1, col 0,
      "#when the user exists, otherwise ignore all below code and move on.", row + 1, col 0,
      "if [[ ${USER_EXISTS_IND} -eq 1 ]]", row + 1, col 0,
      "then", row + 1, col 0,
      "  #Shutdown the database if open_mode of the pdb is 'READ WRITE'", row + 1, col 0,
      '  if [[ ${DB_MODE} == "READ WRITE" ]]', row + 1, col 0,
      "  then", row + 1, ddurk_line = concat(
       '    EchoMessage "`date`: User ${USER_TO_DROP} exists and the pdb is in ${DB_MODE} mode. ',
       'Shutting down."'),
      col 0, ddurk_line, row + 1,
      col 0, "    rm -f ${DROP_V500_SQLFILE}", row + 1,
      col 0, "    rm -f ${DROP_V500_SQL_LOGFILE}", row + 1,
      col 0, '    echo "alter session set container=${TGT_DB_NAME};" > ${DROP_V500_SQLFILE}', row + 1,
      col 0, '    echo "shutdown immediate;" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, '    echo "exit;"  >> ${DROP_V500_SQLFILE}', row + 1,
      col 0,
      "    ${ORACLE_HOME}/bin/sqlplus '/as sysdba' @${DROP_V500_SQLFILE} > ${DROP_V500_SQL_LOGFILE}",
      row + 1,
      col 0, "    ", row + 1,
      col 0, "    if [[ ! -f ${DROP_V500_SQL_LOGFILE} ]]", row + 1,
      col 0, "    then", row + 1,
      col 0, '      EchoMessage "CER-0000:error - ${DROP_V500_SQL_LOGFILE} file not found"', row + 1,
      col 0, '      EchoMessage `date` "KSH for Setup ending in error."', row + 1,
      col 0, "      exit 1", row + 1,
      col 0, "    fi", row + 1,
      col 0, "    ", row + 1,
      col 0, '    if [[ `grep -E "^ORA-" ${DROP_V500_SQL_LOGFILE} | wc -l` -ne 0 ]]', row + 1,
      col 0, "    then", row + 1,
      col 0, '      EchoMessage "CER-0002:error - Error while shutting down the database."', row + 1,
      col 0, "      cat ${DROP_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}", row + 1,
      col 0, '      EchoMessage "`date`: KSH ending in error."', row + 1,
      col 0, "      exit 1", row + 1,
      col 0, "    fi", row + 1,
      col 0, "  fi", row + 1,
      col 0, "  ", row + 1,
      col 0, "  #Verify the open_mode is in a valid state to be started up.", row + 1,
      col 0, "  CheckDBMode", row + 1,
      col 0, "   ", row + 1,
      col 0, "  #Startup the database", row + 1,
      col 0, '  if [[ ${DB_MODE} == "MOUNTED" ]]', row + 1,
      col 0, "  then", row + 1,
      col 0,
      '    EchoMessage "`date`: Pluggable database in ${DB_MODE} mode.Starting the DB in RESTRICT mode."',
      row + 1,
      col 0, "    StartupDB 'RESTRICT'", row + 1,
      col 0, "    CheckDBMode", row + 1,
      col 0, "  fi", row + 1,
      col 0, " ", row + 1,
      col 0, '  if [[ ${DB_MODE} == "READ WRITE" && ${RESTRICTED_MODE} == "YES" ]]', row + 1,
      col 0, "  then", row + 1,
      col 0,
      '    EchoMessage "`date`: Pluggable database in restricted mode. Attempting to drop the user."',
      row + 1,
      col 0, "    #Lock and drop the user. Confirm it is dropped.", row + 1,
      col 0, "    rm -f ${DROP_V500_SQLFILE}", row + 1,
      col 0, "    rm -f ${DROP_V500_SQL_LOGFILE}", row + 1,
      col 0, '    echo "alter session set container=${TGT_DB_NAME};" > ${DROP_V500_SQLFILE}', row + 1,
      col 0, '    echo "set serveroutput on;"  >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, '    echo "begin " >> ${DROP_V500_SQLFILE}', row + 1,
      col 0,
      "    #Putting the session to sleep after startup, so Oracle catches up to the execution.", row
       + 1,
      col 0, '    echo "  dbms_session.sleep(5);"  >> ${DROP_V500_SQLFILE}', row + 1,
      col 0,
      ^    echo "  execute immediate 'alter user ${USER_TO_DROP} account lock';"  >> ${DROP_V500_SQLFILE}^,
      row + 1,
      col 0,
      "    #Putting the session to sleep after locking V500, to give time so new connections are not established.",
      row + 1,
      col 0, '    echo "  dbms_session.sleep(15);"  >> ${DROP_V500_SQLFILE}', row + 1,
      col 0,
      ^    echo "  execute immediate 'drop user ${USER_TO_DROP} cascade';"  >> ${DROP_V500_SQLFILE}^,
      row + 1,
      col 0, '    echo "EXCEPTION" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, '    echo " when others then raise;" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, '    echo "end;" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, '    echo "/" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, '    echo "exit;" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, "    ", row + 1,
      col 0, "    cat ${DROP_V500_SQLFILE} > ${DROP_USER_V500_SQLFILE}", row + 1,
      col 0, "    ", row + 1,
      col 0,
      "    ${ORACLE_HOME}/bin/sqlplus '/as sysdba' @${DROP_USER_V500_SQLFILE} > ${DROP_USER_V500_SQL_LOGFILE}",
      row + 1,
      col 0, "    CheckDBUserExistence", row + 1,
      col 0, "    if [[ $USER_EXISTS_IND -eq 1 ]]", row + 1,
      col 0, "    then", row + 1,
      col 0, "      COUNTER=1", row + 1,
      col 0, "      while [[ ${COUNTER} -le 3 ]]", row + 1,
      col 0, "      do", row + 1,
      col 0, '        EchoMessage "`date`: Attempt ${COUNTER} to drop the user."', row + 1,
      col 0,
      "        ${ORACLE_HOME}/bin/sqlplus '/as sysdba' @${DROP_USER_V500_SQLFILE} > ${DROP_USER_V500_SQL_LOGFILE}",
      row + 1,
      col 0, "        ((COUNTER++))", row + 1,
      col 0, "        CheckDBUserExistence", row + 1,
      col 0, "        if [[ $USER_EXISTS_IND -eq 0 ]]", row + 1,
      col 0, "        then", row + 1,
      col 0, "          COUNTER=4", row + 1,
      col 0, "        fi    ", row + 1,
      col 0, "      done", row + 1,
      col 0, " ", row + 1,
      col 0, "      if [[ $USER_EXISTS_IND -eq 1 ]]", row + 1,
      col 0, "      then", row + 1,
      col 0, '        EchoMessage "CER-0006:error - Error while dropping the user."', row + 1,
      col 0, "        cat ${DROP_USER_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}", row + 1,
      col 0, '        EchoMessage "`date`: KSH ending in error."', row + 1,
      col 0, "        exit 1", row + 1,
      col 0, "      fi", row + 1,
      col 0, "    fi    ", row + 1,
      col 0, " ", row + 1,
      col 0, "    OpenDB", row + 1,
      col 0, "  fi", row + 1,
      col 0, "fi  ", row + 1,
      col 0, " ", row + 1,
      col 0, "UpdateAdminCheckpointRow 'COMPLETED' ", row + 1,
      col 0, 'EchoMessage "`date`: Drop user in restricted mode successful."', row + 1
     ELSE
      col 0, "#!/bin/ksh", row + 1,
      ddurk_text = build("TGT_DB_NAME=",cnvtupper(drrr_rf_data->tgt_db_name)), col 0, ddurk_text,
      row + 1, ddurk_text = concat("export ORACLE_SID=",cnvtlower(drrr_rf_data->tgt_db_cnct_str)),
      col 0,
      ddurk_text, row + 1, ddurk_text = concat("export ORACLE_HOME=",ddurk_tgt_ora_home),
      col 0, ddurk_text, row + 1,
      ddurk_text = build("USER_TO_DROP=V500"), col 0, ddurk_text,
      row + 1, ddurk_text = build("DROP_V500_SQLFILE=",ddurk_sqlfile), col 0,
      ddurk_text, row + 1, ddurk_line = build("DROP_USER_V500_SQLFILE=",ddurk_du_sqlfile),
      col 0, ddurk_line, row + 1,
      ddurk_text = build("DROP_V500_SQL_LOGFILE=",ddurk_logfile), col 0, ddurk_text,
      row + 1, ddurk_line = build("DROP_USER_V500_SQL_LOGFILE=",ddurk_du_logfile), col 0,
      ddurk_line, row + 1, ddurk_text = build("DROP_V500_LOGFILE=",ddurk_full_logfile),
      col 0, ddurk_text, row + 1,
      col 0, "USER_EXISTS_IND=0", row + 1,
      col 0, " ", row + 1,
      col 0, "StartupDB()", row + 1,
      col 0, "{", row + 1,
      col 0, "  rm -f ${DROP_V500_SQLFILE}", row + 1,
      col 0, "  rm -f ${DROP_V500_SQL_LOGFILE}", row + 1,
      col 0, "  arg1=$1", row + 1,
      col 0, "  ", row + 1,
      col 0, '  if [[ "$arg1" = "READ WRITE" ]]', row + 1,
      col 0, "  then", row + 1,
      col 0, '    echo "startup;" > ${DROP_V500_SQLFILE}', row + 1,
      col 0, '    echo "exit;" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, '  elif [[ "$arg1" = "RESTRICT" ]]', row + 1,
      col 0, "  then", row + 1,
      col 0, '    echo "startup restrict;" > ${DROP_V500_SQLFILE}', row + 1,
      col 0, '    echo "exit;" >> ${DROP_V500_SQLFILE}', row + 1,
      col 0, "  fi", row + 1,
      col 0, " ", row + 1,
      col 0,
      "  ${ORACLE_HOME}/bin/sqlplus '/as sysdba' @${DROP_V500_SQLFILE} > ${DROP_V500_SQL_LOGFILE}",
      row + 1,
      col 0, " ", row + 1,
      col 0, "  if [[ ! -f ${DROP_V500_SQL_LOGFILE} ]]", row + 1,
      col 0, "  then", row + 1,
      col 0, '    EchoMessage "CER-0000:error - ${DROP_V500_SQL_LOGFILE} file not found"', row + 1,
      col 0, '    EchoMessage `date` "KSH for Setup ending in error."', row + 1,
      col 0, "    exit 1", row + 1,
      col 0, "  fi", row + 1,
      col 0, " ", row + 1,
      col 0, '  if [[ `grep -E "^ORA-" ${DROP_V500_SQL_LOGFILE} | wc -l` -ne 0 ]]', row + 1,
      col 0, "  then", row + 1,
      col 0, '    EchoMessage "CER-0003:error - Error while starting the database in $arg1 mode."',
      row + 1,
      col 0, "    cat ${DROP_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}", row + 1,
      col 0, '    EchoMessage "`date`: KSH ending in error."', row + 1,
      col 0, "    exit 1", row + 1,
      col 0, "  fi", row + 1,
      col 0, '  EchoMessage "`date`: Database is opened in $arg1 mode."', row + 1,
      col 0, "}", row + 1,
      col 0, " ", row + 1,
      col 0, "OpenDB()", row + 1,
      col 0, "{", row + 1,
      col 0, "  rm -f ${DROP_V500_SQL_LOGFILE}", row + 1,
      col 0, "  rm -f ${DROP_V500_SQLFILE}", row + 1,
      ddurk_text = concat(
       ^  echo "alter system disable restricted session;" | ${ORACLE_HOME}/bin/sqlplus '/as sysdba' ^,
       "> ${DROP_V500_SQL_LOGFILE}"), col 0, ddurk_text,
      row + 1, col 0, " ",
      row + 1, col 0, "  if [[ ! -f ${DROP_V500_SQL_LOGFILE} ]]",
      row + 1, col 0, "  then",
      row + 1, col 0, '    EchoMessage "CER-0000:error - ${DROP_V500_SQL_LOGFILE} file not found"',
      row + 1, col 0, '    EchoMessage `date` "KSH for Setup ending in error."',
      row + 1, col 0, "    exit 1",
      row + 1, col 0, "  fi",
      row + 1, col 0, " ",
      row + 1, col 0, '  if [[ `grep -E "^ORA-" ${DROP_V500_SQL_LOGFILE} | wc -l` -ne 0 ]]',
      row + 1, col 0, "  then",
      row + 1, col 0, '    EchoMessage "CER-0004:error - Error disabling restricted session."',
      row + 1, col 0, "    cat ${DROP_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}",
      row + 1, col 0, '    EchoMessage "`date`: KSH ending in error."',
      row + 1, col 0, "    exit 1",
      row + 1, col 0, "  fi ",
      row + 1, col 0, '  EchoMessage "`date`: Restrict mode on databse is disabled."',
      row + 1, col 0, "}",
      row + 1, col 0, " ",
      row + 1, col 0, "UpdateAdminCheckpointRow() ",
      row + 1, col 0, "{",
      row + 1, col 0, "  rm -f ${DROP_V500_SQLFILE}",
      row + 1, col 0, "  rm -f ${DROP_V500_SQL_LOGFILE}",
      row + 1, col 0, "  arg1=$1",
      row + 1, col 0,
      '  EchoMessage "`date`: Attempting to merge Admin checkpoint row with $arg1 status."',
      row + 1, col 0, "  #Merging into dm_info to mark the initiation of restrict database",
      row + 1, col 0, '  echo "begin" > ${DROP_V500_SQLFILE}',
      row + 1, col 0, '  echo "  merge into dm_info x " >> ${DROP_V500_SQLFILE}',
      row + 1, col 0, '  echo "  using dual " >> ${DROP_V500_SQLFILE}',
      row + 1, ddurk_text = concat(
       ^  echo "  on (x.info_domain='DM2_REFRESH_RESTRICT_DATABASE' and x.info_name='${TGT_DB_NAME}')"^,
       " >> ${DROP_V500_SQLFILE}"), col 0,
      ddurk_text, row + 1, col 0,
      '  echo "  when matched then " >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      ^  echo "   update set x.info_char = '$arg1', " >> ${DROP_V500_SQLFILE}^, row + 1, col 0,
      '  echo "   x.updt_dt_tm = sysdate " >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "  when not matched then " >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "   insert(x.info_domain, x.info_name, x.info_char, x.updt_dt_tm) " >> ${DROP_V500_SQLFILE}',
      row + 1, col 0,
      ^  echo "   values ('DM2_REFRESH_RESTRICT_DATABASE','${TGT_DB_NAME}','$arg1',sysdate); " >> ${DROP_V500_SQLFILE}^,
      row + 1, col 0,
      '  echo "  commit;"   >> ${DROP_V500_SQLFILE}     ', row + 1, col 0,
      '  echo "exception" >> ${DROP_V500_SQLFILE} ', row + 1, col 0,
      '  echo "  when others then"  >> ${DROP_V500_SQLFILE} ', row + 1, col 0,
      '  echo "    dbms_output.put_line(sqlerrm);"  >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "    rollback; "  >> ${DROP_V500_SQLFILE} ', row + 1, col 0,
      '  echo "end; "  >> ${DROP_V500_SQLFILE} ', row + 1, col 0,
      '  echo "/"   >> ${DROP_V500_SQLFILE} ', row + 1, col 0,
      '  echo "exit; " >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      "  ", row + 1, ddurk_line = build(" ${ORACLE_HOME}/bin/sqlplus -L  '",drrr_rf_data->adm_db_user,
       "/",drrr_rf_data->adm_db_user_pwd,"@",
       drrr_rf_data->adm_db_cnct_str,"' @${DROP_V500_SQLFILE} > ${DROP_V500_SQL_LOGFILE} "),
      col 0, ddurk_line, row + 1,
      col 0, "  if [[ ! -f ${DROP_V500_SQL_LOGFILE} ]]", row + 1,
      col 0, "  then", row + 1,
      col 0, '    EchoMessage "CER-0000:error - ${DROP_V500_SQL_LOGFILE} file not found"', row + 1,
      col 0, '    EchoMessage `date` "KSH for Setup ending in error."', row + 1,
      col 0, "    exit 1", row + 1,
      col 0, "  fi", row + 1,
      col 0, "  ", row + 1,
      col 0, '  if [[ `grep -E "^ORA-" ${DROP_V500_SQL_LOGFILE} | wc -l` -ne 0 ]]', row + 1,
      col 0, "  then", row + 1,
      col 0, '    EchoMessage "CER-0005:error - Error while merging dm_info row with $arg1 status."',
      row + 1,
      col 0, "    cat ${DROP_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}", row + 1,
      col 0, '    EchoMessage "`date`: KSH ending in error."', row + 1,
      col 0, "    exit 1", row + 1,
      col 0, "  fi", row + 1,
      col 0, '  EchoMessage "`date`: Admin checkpoint row merged with $arg1 status."', row + 1,
      col 0, "} ", row + 1,
      col 0, " ", row + 1,
      col 0, "CheckDBUserExistence() ", row + 1,
      col 0, "{ ", row + 1,
      col 0, "  rm -f ${DROP_V500_SQLFILE} ", row + 1,
      col 0, "  rm -f ${DROP_V500_SQL_LOGFILE} ", row + 1,
      col 0, "  USER_EXISTS_IND=0 ", row + 1,
      col 0, '  echo "set serveroutput on;" > ${DROP_V500_SQLFILE} ', row + 1,
      col 0, '  echo "declare " >> ${DROP_V500_SQLFILE} ', row + 1,
      col 0, '  echo "  user_exists_ind number := 0;" >> ${DROP_V500_SQLFILE} ', row + 1,
      col 0, '  echo "begin" >> ${DROP_V500_SQLFILE} ', row + 1,
      ddurk_text = concat(
       ^  echo "select count(*) into user_exists_ind from dba_users where username='${USER_TO_DROP}';"^,
       "  >> ${DROP_V500_SQLFILE}"), col 0, ddurk_text,
      row + 1, col 0,
      ^  echo " dbms_output.put_line('USER_EXISTS_IND is: ' || user_exists_ind);" >> ${DROP_V500_SQLFILE} ^,
      row + 1, col 0, '  echo " EXCEPTION" >> ${DROP_V500_SQLFILE} ',
      row + 1, col 0, '  echo "  when others then raise;" >> ${DROP_V500_SQLFILE} ',
      row + 1, col 0, '  echo "end;" >> ${DROP_V500_SQLFILE} ',
      row + 1, col 0, '  echo "/" >> ${DROP_V500_SQLFILE} ',
      row + 1, col 0, '  echo "exit" >> ${DROP_V500_SQLFILE} ',
      row + 1, col 0, " ",
      row + 1, col 0,
      "  ${ORACLE_HOME}/bin/sqlplus '/as sysdba' @${DROP_V500_SQLFILE} > ${DROP_V500_SQL_LOGFILE} ",
      row + 1, col 0, " ",
      row + 1, col 0, "  if [[ ! -f ${DROP_V500_SQL_LOGFILE} ]] ",
      row + 1, col 0, "  then ",
      row + 1, col 0, '    EchoMessage "CER-0000:error - ${DROP_V500_SQL_LOGFILE} file not found"',
      row + 1, col 0, '    EchoMessage `date` "KSH for Setup ending in error."',
      row + 1, col 0, "    exit 1 ",
      row + 1, col 0, "  fi ",
      row + 1, col 0, "  ",
      row + 1, col 0, '  if [[ `grep -E "^ORA-" ${DROP_V500_SQL_LOGFILE} | wc -l` -ne 0 ]] ',
      row + 1, col 0, "  then ",
      row + 1, col 0, '    EchoMessage "CER-0008:error - Error retrieving user info."',
      row + 1, col 0, "    cat ${DROP_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}",
      row + 1, col 0, '    EchoMessage "`date`: KSH ending in error."',
      row + 1, col 0, "    exit 1 ",
      row + 1, col 0, "  fi ",
      row + 1, col 0, " ",
      row + 1, col 0,
      '  USER_EXISTS_IND=`grep "USER_EXISTS_IND is: " ${DROP_V500_SQL_LOGFILE} | cut -d" " -f3` ',
      row + 1, col 0, " ",
      row + 1, col 0, "  if [[ ${USER_EXISTS_IND} -eq 0 ]] ",
      row + 1, col 0, "  then ",
      row + 1, col 0, '    EchoMessage "`date`: User ${USER_TO_DROP} does not exist."',
      row + 1, col 0, "  else ",
      row + 1, col 0, '    EchoMessage "`date`: User ${USER_TO_DROP} exists."',
      row + 1, col 0, "  fi ",
      row + 1, col 0, "} ",
      row + 1, col 0, " ",
      row + 1, col 0, "EchoMessage()",
      row + 1, col 0, "{",
      row + 1, col 0, " echo $1",
      row + 1, col 0, ' echo "`date`: $1" >> ${DROP_V500_LOGFILE}',
      row + 1, col 0, "}",
      row + 1, col 0, " ",
      row + 1, col 0, "#Main process",
      row + 1, col 0, "rm -f ${DROP_V500_LOGFILE}",
      row + 1, col 0, 'EchoMessage "`date`: Beginning of the logfile to drop ${USER_TO_DROP} user."',
      row + 1, col 0, " ",
      row + 1, col 0, "TGT_DB_STATUS_IND=$(ps -ef | grep pmon | grep ${ORACLE_SID} | wc -l)",
      row + 1, col 0, "#If the database is down during the first run, startup in readwrite mode.",
      row + 1, col 0, "if [[ ${TGT_DB_STATUS_IND} -eq 0 ]]",
      row + 1, col 0, "then",
      row + 1, col 0, '  EchoMessage "`date`: Database is down. Starting up in READ WRITE mode."',
      row + 1, col 0, "  StartupDB 'READ WRITE'",
      row + 1, col 0, "fi",
      row + 1, col 0, " ",
      row + 1, col 0, "TGT_DB_STATUS_IND=$(ps -ef | grep pmon | grep ${ORACLE_SID} | wc -l)",
      row + 1, col 0, "#Check the status of the database.",
      row + 1, col 0, "if [[ ${TGT_DB_STATUS_IND} -gt 0 ]]",
      row + 1, col 0, "then",
      row + 1, col 0,
      '  echo "`date`: DB is running. Retrieving the db_mode and restricted_mode." >> ${DROP_V500_SQL_LOGFILE} ',
      row + 1, col 0, "  #Verify the open_mode is in a valid state to be shutdown.",
      row + 1, col 0, "  rm -f ${DROP_V500_SQLFILE}",
      row + 1, col 0, "  rm -f ${DROP_V500_SQL_LOGFILE}",
      row + 1, col 0, '  echo "set serveroutput on;" > ${DROP_V500_SQLFILE}',
      row + 1, col 0, '  echo "declare " >> ${DROP_V500_SQLFILE}',
      row + 1, col 0, '  echo "  db_mode varchar2(10);" >> ${DROP_V500_SQLFILE}',
      row + 1, col 0, '  echo "  restricted_mode varchar2(10);" >> ${DROP_V500_SQLFILE}',
      row + 1, col 0, '  echo "begin" >> ${DROP_V500_SQLFILE}',
      row + 1, ddurk_text = build('  echo " select open_mode into db_mode from v\$database ',
       ^ where name = '${TGT_DB_NAME}';" >> ${DROP_V500_SQLFILE}^), col 0,
      ddurk_text, row + 1, col 0,
      '  echo " select logins into restricted_mode from v\$instance;" >> ${DROP_V500_SQLFILE}', row
       + 1, col 0,
      ^  echo " dbms_output.put_line('DB_MODE is: ' || db_mode);" >> ${DROP_V500_SQLFILE}^, row + 1,
      col 0,
      ^  echo " dbms_output.put_line('RESTRICTED_MODE is: ' || restricted_mode);" >> ${DROP_V500_SQLFILE}^,
      row + 1, col 0,
      '  echo " EXCEPTION" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "  when others then raise;" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "end;" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "/" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '  echo "exit" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      "  ${ORACLE_HOME}/bin/sqlplus '/as sysdba' @${DROP_V500_SQLFILE} > ${DROP_V500_SQL_LOGFILE}",
      row + 1, col 0,
      "  ", row + 1, col 0,
      "  if [[ ! -f ${DROP_V500_SQL_LOGFILE} ]]", row + 1, col 0,
      "  then", row + 1, col 0,
      '    EchoMessage "CER-0000:error - ${DROP_V500_SQL_LOGFILE} file not found"', row + 1, col 0,
      '    EchoMessage `date` "KSH for Setup ending in error."', row + 1, col 0,
      "    exit 1", row + 1, col 0,
      "  fi", row + 1, col 0,
      "  ", row + 1, col 0,
      '  if [[ `grep -E "^ORA-" ${DROP_V500_SQL_LOGFILE} | wc -l` -ne 0 ]]', row + 1, col 0,
      "  then", row + 1, col 0,
      '    EchoMessage "CER-0001:error - Error retrieving database mode info."', row + 1, col 0,
      "    cat ${DROP_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}", row + 1, col 0,
      '    EchoMessage "`date`: KSH ending in error."', row + 1, col 0,
      "    exit 1", row + 1, col 0,
      "  fi", row + 1, col 0,
      '  DB_MODE=`grep "DB_MODE is: " ${DROP_V500_SQL_LOGFILE} | cut -d" " -f3-4`', row + 1, col 0,
      '  RESTRICTED_MODE=`grep "RESTRICTED_MODE is: " ${DROP_V500_SQL_LOGFILE} | cut -d" " -f3`', row
       + 1, col 0,
      '  EchoMessage "`date`: DB_MODE=${DB_MODE}"', row + 1, col 0,
      '  EchoMessage "`date`: RESTRICTED=${RESTRICTED_MODE}"', row + 1, col 0,
      "fi", row + 1, col 0,
      "#If the database is in any mode other than READ WRITE, open the database in READ WRITE mode.",
      row + 1, col 0,
      'if [[ ${DB_MODE} != "READ WRITE" ]]', row + 1, col 0,
      "then  ", row + 1, col 0,
      '  EchoMessage "`date`: Database is in ${DB_MODE} mode. Opening database."', row + 1, col 0,
      "  rm -f ${DROP_V500_SQL_LOGFILE}", row + 1, col 0,
      "  echo 'alter database open;' | ${ORACLE_HOME}/bin/sqlplus '/as sysdba' > ${DROP_V500_SQL_LOGFILE}",
      row + 1, col 0,
      " ", row + 1, col 0,
      "  if [[ ! -f ${DROP_V500_SQL_LOGFILE} ]]", row + 1, col 0,
      "  then", row + 1, col 0,
      '    EchoMessage "CER-0000:error - ${DROP_V500_SQL_LOGFILE} file not found"', row + 1, col 0,
      '    EchoMessage `date` "KSH for Setup ending in error."', row + 1, col 0,
      "    exit 1", row + 1, col 0,
      "  fi", row + 1, col 0,
      " ", row + 1, col 0,
      '  if [[ `grep -E "^ORA-" ${DROP_V500_SQL_LOGFILE} | wc -l` -ne 0 ]]', row + 1, col 0,
      "  then", row + 1, col 0,
      '    EchoMessage "CER-0007:error - Error while starting the database in READ WRITE mode."', row
       + 1, col 0,
      "    cat ${DROP_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}", row + 1, col 0,
      '    EchoMessage "`date`: KSH ending in error."', row + 1, col 0,
      "    exit 1", row + 1, col 0,
      "  fi ", row + 1, col 0,
      "fi", row + 1, col 0,
      'if [[ ${RESTRICTED_MODE} == "RESTRICTED" ]]', row + 1, col 0,
      "then", row + 1, col 0,
      '  EchoMessage "`date`: Database is restricted. Opening DB to disable restriction."', row + 1,
      col 0,
      "  #Call disable restricted session module.", row + 1, col 0,
      "  OpenDB", row + 1, col 0,
      "fi", row + 1, col 0,
      " ", row + 1, col 0,
      "UpdateAdminCheckpointRow 'INITIATED' ", row + 1, col 0,
      " ", row + 1, col 0,
      "CheckDBUserExistence", row + 1, col 0,
      " ", row + 1, col 0,
      "#Perform shutting down the database, startup in restrict to drop the user operations only ",
      row + 1, col 0,
      "#when the user exists, otherwise ignore all below code and move on.", row + 1, col 0,
      "if [[ ${USER_EXISTS_IND} -eq 1 ]]", row + 1, col 0,
      "then", row + 1, col 0,
      "  #Shutdown the database", row + 1, col 0,
      "  if [[ ${TGT_DB_STATUS_IND} -gt 0 ]]", row + 1, col 0,
      "  then", row + 1, col 0,
      '    EchoMessage "`date`: User ${USER_TO_DROP} exists. Shutting down the database."', row + 1,
      col 0,
      "    rm -f ${DROP_V500_SQLFILE}", row + 1, col 0,
      "    rm -f ${DROP_V500_SQL_LOGFILE}", row + 1, col 0,
      '    echo "shutdown immediate;" > ${DROP_V500_SQLFILE}', row + 1, col 0,
      '    echo "exit;"  >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      "    ${ORACLE_HOME}/bin/sqlplus '/as sysdba' @${DROP_V500_SQLFILE} > ${DROP_V500_SQL_LOGFILE}",
      row + 1, col 0,
      "    ", row + 1, col 0,
      "    if [[ ! -f ${DROP_V500_SQL_LOGFILE} ]]", row + 1, col 0,
      "    then", row + 1, col 0,
      '      EchoMessage "CER-0000:error - ${DROP_V500_SQL_LOGFILE} file not found"', row + 1, col 0,
      '      EchoMessage `date` "KSH for Setup ending in error."', row + 1, col 0,
      "      exit 1", row + 1, col 0,
      "    fi", row + 1, col 0,
      "    ", row + 1, col 0,
      '    if [[ `grep -E "^ORA-" ${DROP_V500_SQL_LOGFILE} | wc -l` -ne 0 ]]', row + 1, col 0,
      "    then", row + 1, col 0,
      '      EchoMessage "CER-0002:error - Error while shutting down the database."', row + 1, col 0,
      "      cat ${DROP_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}", row + 1, col 0,
      '      EchoMessage "`date`: KSH ending in error."', row + 1, col 0,
      "      exit 1", row + 1, col 0,
      "    fi", row + 1, col 0,
      "    ", row + 1, col 0,
      "  fi", row + 1, col 0,
      "  ", row + 1, col 0,
      "  #Check the database status before starting in restrict mode.", row + 1, col 0,
      "  TGT_DB_STATUS_IND=$(ps -ef | grep pmon | grep ${ORACLE_SID} | wc -l)", row + 1, col 0,
      "  ", row + 1, col 0,
      "  #Startup the database", row + 1, col 0,
      "  if [[ ${TGT_DB_STATUS_IND} -eq 0 ]]", row + 1, col 0,
      "  then", row + 1, col 0,
      '    EchoMessage "`date`: Starting the database in RESTRICT mode."', row + 1, col 0,
      "    StartupDB 'RESTRICT'", row + 1, col 0,
      "  fi", row + 1, col 0,
      "  ", row + 1, col 0,
      "  TGT_DB_STATUS_IND=$(ps -ef | grep pmon | grep ${ORACLE_SID} | wc -l)", row + 1, col 0,
      "  if [[ ${TGT_DB_STATUS_IND} -gt 0 ]]", row + 1, col 0,
      "  then", row + 1, col 0,
      '    EchoMessage "`date`: Attempting to drop the user ${USER_TO_DROP}."', row + 1, col 0,
      "    #Lock and drop the user. Confirm it is dropped.", row + 1, col 0,
      "    rm -f ${DROP_V500_SQLFILE}", row + 1, col 0,
      "    rm -f ${DROP_V500_SQL_LOGFILE}", row + 1, col 0,
      '    echo "set serveroutput on;"  > ${DROP_V500_SQLFILE}', row + 1, col 0,
      '    echo "begin " >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '    echo "  dbms_lock.sleep(5);"  >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      ^    echo "  execute immediate 'alter user ${USER_TO_DROP} account lock';"  >> ${DROP_V500_SQLFILE}^,
      row + 1, col 0,
      '    echo "  dbms_lock.sleep(15);"  >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      ^    echo "  execute immediate 'drop user ${USER_TO_DROP} cascade';"  >> ${DROP_V500_SQLFILE}^,
      row + 1, col 0,
      '    echo "EXCEPTION" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '    echo " when others then raise;" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '    echo "end;" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '    echo "/" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      '    echo "exit;" >> ${DROP_V500_SQLFILE}', row + 1, col 0,
      "    ", row + 1, col 0,
      "    cat ${DROP_V500_SQLFILE} > ${DROP_USER_V500_SQLFILE}", row + 1, col 0,
      "    ", row + 1, col 0,
      "    ${ORACLE_HOME}/bin/sqlplus '/as sysdba' @${DROP_USER_V500_SQLFILE} > ${DROP_USER_V500_SQL_LOGFILE}",
      row + 1, col 0,
      "    CheckDBUserExistence", row + 1, col 0,
      "    if [[ $USER_EXISTS_IND -eq 1 ]]", row + 1, col 0,
      "    then", row + 1, col 0,
      "      COUNTER=1", row + 1, col 0,
      "      while [[ ${COUNTER} -le 3 ]]", row + 1, col 0,
      "      do", row + 1, col 0,
      '        EchoMessage "`date`: Attempt ${COUNTER} to drop the user."', row + 1, col 0,
      "        ${ORACLE_HOME}/bin/sqlplus '/as sysdba' @${DROP_USER_V500_SQLFILE} > ${DROP_USER_V500_SQL_LOGFILE}",
      row + 1, col 0,
      "        ((COUNTER++))", row + 1, col 0,
      "        CheckDBUserExistence", row + 1, col 0,
      "        if [[ $USER_EXISTS_IND -eq 0 ]]", row + 1, col 0,
      "        then", row + 1, col 0,
      "          COUNTER=4", row + 1, col 0,
      "        fi    ", row + 1, col 0,
      "      done", row + 1, col 0,
      "      ", row + 1, col 0,
      "      if [[ $USER_EXISTS_IND -eq 1 ]]", row + 1, col 0,
      "      then", row + 1, col 0,
      '        EchoMessage "CER-0006:error - Error while dropping the user."', row + 1, col 0,
      "        cat ${DROP_USER_V500_SQL_LOGFILE} >> ${DROP_V500_LOGFILE}", row + 1, col 0,
      '        EchoMessage "`date`: KSH ending in error."', row + 1, col 0,
      "        exit 1", row + 1, col 0,
      "      fi", row + 1, col 0,
      "    fi    ", row + 1, col 0,
      " ", row + 1, col 0,
      "    OpenDB", row + 1, col 0,
      "    ", row + 1, col 0,
      "  fi", row + 1, col 0,
      "fi  ", row + 1, col 0,
      " ", row + 1, col 0,
      "UpdateAdminCheckpointRow 'COMPLETED' ", row + 1, col 0,
      " ", row + 1, col 0,
      'EchoMessage "`date`: Drop user in restricted mode successful."', row + 1
     ENDIF
    WITH nocounter, format = lfstream, formfeed = none,
     maxrow = 1, maxcol = 512
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (dfr_init(null)=0)
    RETURN(0)
   ENDIF
   SET dm2ftpr->user_name = "oracle"
   SET dm2ftpr->user_pwd = "oracle"
   SET dm2ftpr->remote_host = drrr_rf_data->tgt_db_node
   SET dm2ftpr->options = "-b"
   CALL dfr_add_putops_line(" "," "," "," "," ",
    1)
   CALL dfr_add_putops_line(" ",build(trim(logical("ccluserdir")),"/"),ddurk_full_ksh_name,concat(
     ddurk_file_loc,"/"),ddurk_full_ksh_name,
    0)
   IF (dfr_put_file(null)=0)
    RETURN(0)
   ENDIF
   CALL dfr_add_putops_line(" "," "," "," "," ",
    1)
   SET ddurk_cmd = concat("su - oracle -c 'ssh oracle@",drrr_rf_data->tgt_db_node," ",ddurk_file_loc,
    ddurk_full_ksh_name,
    "'")
   SET dm_err->disp_dcl_err_ind = 0
   IF (dm2_push_dcl(ddurk_cmd)=0)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   SET dm_err->errfile = "NONE"
   IF (findstring("CER-",cnvtupper(dm_err->errtext),1,0) > 0)
    SET ddurk_ksh_error_msg = concat("Fatal error:  ",substring(findstring("CER-",cnvtupper(dm_err->
        errtext),1,1),(size(dm_err->errtext) - findstring("CER-",cnvtupper(dm_err->errtext),1,1)),
      dm_err->errtext),".")
    SET dm_err->eproc = concat("Executing ksh script ",ddurk_full_ksh_name," from ",ddurk_file_loc,
     " on Target ",
     "database node ",drrr_rf_data->tgt_db_node,".")
    SET dm_err->emsg = concat("Error(s) detected during ksh execution. ",ddurk_ksh_error_msg)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (findstring("DROP USER IN RESTRICTED MODE SUCCESSFUL",cnvtupper(dm_err->errtext),1,0) > 0)
    SET dm_err->eproc = concat("Execution of ksh script ",ddurk_full_ksh_name," from ",ddurk_file_loc,
     " on Target database node (",
     drrr_rf_data->tgt_db_node,") to drop V500 user was successful.")
    CALL disp_msg("",dm_err->logfile,0)
   ELSE
    SET dm_err->eproc = concat("Executing ksh script ",ddurk_full_ksh_name," from ",ddurk_file_loc,
     " on Target ",
     "database node ",drrr_rf_data->tgt_db_node,".")
    SET dm_err->emsg = concat(
     "Unable to verify successful execution of ksh file. Command executed:  ",build(ddurk_cmd))
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag=0))
    SET dm_err->eproc = concat("Removing ksh script ",ddurk_full_ksh_name," from ",ddurk_file_loc,
     " on Target database node ",
     drrr_rf_data->tgt_db_node)
    CALL disp_msg("",dm_err->logfile,0)
    IF (dm2_findfile(concat(build(logical("ccluserdir"),"/"),ddurk_full_ksh_name)))
     IF (dm2_push_dcl(concat("rm ",build(logical("ccluserdir"),"/"),ddurk_full_ksh_name))=0)
      RETURN(0)
     ENDIF
    ENDIF
    SET ddurk_cmd = ""
    SET ddurk_cmd = concat("su - oracle -c 'ssh oracle@",drrr_rf_data->tgt_db_node,' "rm -f ',
     ddurk_file_loc,ddurk_full_ksh_name,
     ^"'^)
    SET dm_err->disp_dcl_err_ind = 0
    IF (dm2_push_dcl(ddurk_cmd)=0)
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ENDIF
    SET ddurk_cmd = ""
    SET ddurk_cmd = concat("su - oracle -c 'ssh oracle@",drrr_rf_data->tgt_db_node,' "rm -f ',
     ddurk_full_logfile," ",
     ddurk_logfile," ",ddurk_sqlfile," ",ddurk_du_logfile,
     " ",ddurk_du_sqlfile,^"'^)
    SET dm_err->disp_dcl_err_ind = 0
    IF (dm2_push_dcl(ddurk_cmd)=0)
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_verify_admin_content(dvac_inform_only_ind,dvac_invalid_data_ind)
   DECLARE dvac_msg = vc WITH protect, noconstant("")
   DECLARE dvac_idx = i4 WITH protect, noconstant(0)
   DECLARE dvac_tidx = i4 WITH protect, noconstant(0)
   DECLARE dvac_invalid_tbl_file = vc WITH protect, noconstant("")
   IF (validate(dm2_bypass_verify_adm_cont,- (1))=1)
    SET dm_err->eproc = "Bypassing validation of Admin content before data collection."
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   FREE RECORD dvac_invalid_tbl
   RECORD dvac_invalid_tbl(
     1 cnt = i4
     1 tables[*]
       2 tbl_name = vc
   )
   SET dvac_invalid_tbl->cnt = 0
   FREE RECORD dvac_dup_tbl
   RECORD dvac_dup_tbl(
     1 cnt = i4
     1 suffixes[*]
       2 suffix = vc
       2 tbl_cnt = i4
       2 tables[*]
         3 tbl_name = vc
   )
   SET dvac_dup_tbl->cnt = 0
   FREE RECORD dvac_missing_tp_tbl
   RECORD dvac_missing_tp_tbl(
     1 cnt = i4
     1 tables[*]
       2 tbl_name = vc
   )
   SET dvac_missing_tp_tbl->cnt = 0
   SET dm_err->eproc =
   "Verify if any INVALID table documentation rows are found for the existing Millennium tables."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_tables_doc dt
    WHERE ((dt.table_suffix="0") OR (((dt.full_table_name=null) OR (dt.full_table_name="")) ))
     AND table_name IN (
    (SELECT
     x.table_name
     FROM dba_tables x
     WHERE x.owner=currdbuser))
    DETAIL
     dvac_invalid_tbl->cnt = (dvac_invalid_tbl->cnt+ 1), stat = alterlist(dvac_invalid_tbl->tables,
      dvac_invalid_tbl->cnt), dvac_invalid_tbl->tables[dvac_invalid_tbl->cnt].tbl_name = dt
     .table_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc =
   "Verify if any DUPLICATE table documentation rows are found for the existing Millennium tables."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_tables_doc dt
    WHERE ((table_name=full_table_name) OR (((full_table_name = null) OR (textlen(trim(
      full_table_name,5))=0)) ))
     AND table_suffix IN (
    (SELECT
     x.table_suffix
     FROM dm_tables_doc x
     WHERE ((x.full_table_name=x.table_name) OR (((textlen(trim(full_table_name,5))=0) OR (x
     .full_table_name = null)) ))
      AND x.table_name IN (
     (SELECT
      t.table_name
      FROM dba_tables t
      WHERE t.owner=currdbuser))
     GROUP BY x.table_suffix
     HAVING count(*) > 1))
     AND table_name IN (
    (SELECT
     x.table_name
     FROM dba_tables x
     WHERE x.owner=currdbuser))
    DETAIL
     dvac_idx = 0
     IF (locateval(dvac_idx,1,size(dvac_dup_tbl->suffixes,5),dt.table_suffix,dvac_dup_tbl->suffixes[
      dvac_idx].suffix)=0)
      dvac_dup_tbl->cnt = (dvac_dup_tbl->cnt+ 1), stat = alterlist(dvac_dup_tbl->suffixes,
       dvac_dup_tbl->cnt), dvac_dup_tbl->suffixes[dvac_dup_tbl->cnt].suffix = dt.table_suffix,
      dvac_idx = dvac_dup_tbl->cnt
     ENDIF
     dvac_dup_tbl->suffixes[dvac_idx].tbl_cnt = (dvac_dup_tbl->suffixes[dvac_idx].tbl_cnt+ 1), stat
      = alterlist(dvac_dup_tbl->suffixes[dvac_idx].tables,dvac_dup_tbl->suffixes[dvac_idx].tbl_cnt),
     dvac_dup_tbl->suffixes[dvac_idx].tables[dvac_dup_tbl->suffixes[dvac_idx].tbl_cnt].tbl_name = dt
     .table_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc =
   "Verify if any MISSING table precedence documentation rows are found for the existing Millennium tables."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    td.table_name
    FROM dba_tables t,
     dm_tables_doc td
    WHERE t.owner=currdbuser
     AND  NOT (t.table_name IN ("DM2_DDL_OPS1", "DM2_DDL_OPS_LOG1"))
     AND t.table_name=td.table_name
     AND td.owner=t.owner
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM dm_ts_precedence tp
     WHERE t.table_name=tp.table_name
      AND t.owner=tp.owner)))
    DETAIL
     dvac_missing_tp_tbl->cnt = (dvac_missing_tp_tbl->cnt+ 1), stat = alterlist(dvac_missing_tp_tbl->
      tables,dvac_missing_tp_tbl->cnt), dvac_missing_tp_tbl->tables[dvac_missing_tp_tbl->cnt].
     tbl_name = td.table_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dvac_invalid_tbl)
    CALL echorecord(dvac_dup_tbl)
    CALL echorecord(dvac_missing_tp_tbl)
   ENDIF
   IF ((((dvac_invalid_tbl->cnt > 0)) OR ((((dvac_dup_tbl->cnt > 0)) OR ((dvac_missing_tp_tbl->cnt >
   0))) )) )
    SET dvac_invalid_data_ind = 1
    SET dm_err->eproc = "Create invalid admin content report gathered before data collection."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (get_unique_file("dm2_invalid_adm_cont",".rpt")=0)
     RETURN(0)
    ENDIF
    SET dvac_invalid_tbl_file = concat(build(logical("ccluserdir"),"/"),dm_err->unique_fname)
    SELECT INTO value(dvac_invalid_tbl_file)
     FROM dual
     DETAIL
      row + 1, col 1,
      "***************************WARNING: Invalid Admin Content has been detected.************************",
      row + 1
      IF ((dvac_invalid_tbl->cnt > 0))
       row + 1, col 1, "Tables displayed below have invalid documentation rows.",
       row + 1, col 1,
       "********************************************************************************************************",
       row + 2, col 10, "TABLE NAME",
       row + 1
       FOR (dvac_idx = 1 TO dvac_invalid_tbl->cnt)
         col 10, dvac_invalid_tbl->tables[dvac_idx].tbl_name, row + 1
       ENDFOR
      ENDIF
      IF ((dvac_dup_tbl->cnt > 0))
       row + 1, col 1, "Tables displayed below have duplicate suffixes.",
       row + 1, col 1,
       "********************************************************************************************************",
       row + 2, col 10, "SUFFIX NAME",
       col 40, "TABLE NAME", row + 1
       FOR (dvac_idx = 1 TO dvac_dup_tbl->cnt)
         col 10, dvac_dup_tbl->suffixes[dvac_idx].suffix
         FOR (dvac_tidx = 1 TO dvac_dup_tbl->suffixes[dvac_idx].tbl_cnt)
           col 40, dvac_dup_tbl->suffixes[dvac_idx].tables[dvac_tidx].tbl_name, row + 1
         ENDFOR
       ENDFOR
      ENDIF
      IF ((dvac_missing_tp_tbl->cnt > 0))
       row + 1, col 1, "Tables displayed below are missing table precedence rows.",
       row + 1, col 1,
       "********************************************************************************************************",
       row + 2, col 10, "TABLE NAME",
       row + 1
       FOR (dvac_idx = 1 TO dvac_missing_tp_tbl->cnt)
         col 10, dvac_missing_tp_tbl->tables[dvac_idx].tbl_name, row + 1
       ENDFOR
      ENDIF
     FOOT REPORT
      row + 1, col 0, "END OF REPORT"
     WITH nocounter, maxcol = 300, formfeed = none,
      maxrow = 1, nullreport
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((drer_email_list->email_cnt > 0))
     SET drer_email_det->msgtype = "ACTIONREQ"
     SET drer_email_det->status = "REPORT"
     SET drer_email_det->status_dt_tm = cnvtdatetime(curdate,curtime3)
     SET drer_email_det->step = "Invalid Admin Content Report"
     SET drer_email_det->email_level = 1
     SET drer_email_det->logfile = dm_err->logfile
     SET drer_email_det->err_ind = dm_err->err_ind
     SET drer_email_det->eproc = dm_err->eproc
     SET drer_email_det->emsg = dm_err->emsg
     SET drer_email_det->user_action = dm_err->user_action
     SET drer_email_det->attachment = dvac_invalid_tbl_file
     CALL drer_add_body_text(concat("Invalid Admin Content Report created at ",format(drer_email_det
        ->status_dt_tm,";;q")),1)
     CALL drer_add_body_text(concat("Report file name is : ",dvac_invalid_tbl_file),0)
     IF (drer_compose_email(null)=1)
      CALL drer_send_email(drer_email_det->subject,drer_email_det->file_name,drer_email_det->
       email_level)
     ENDIF
     CALL drer_reset_pre_err(null)
    ENDIF
    SET dvac_msg = "Invalid Admin Content found."
    IF (dvac_inform_only_ind=1)
     SET dm_err->eproc = dvac_msg
     CALL disp_msg("",dm_err->logfile,0)
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validating if invalid admin content found for the Millennium tables."
     SET dm_err->emsg = dvac_msg
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_add_default_scd_row(null)
   DECLARE dadsr_def_row_id = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Verify if default row needs to be added for SCD_TERM_DATA table."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dma_sql_obj_inst dsoi
    WHERE dsoi.process_type="ADD_DEFAULT_ROW"
     AND dsoi.object_type="TABLE"
     AND dsoi.object_name="SCD_TERM_DATA"
     AND dsoi.table_name=dsoi.object_name
    DETAIL
     dadsr_def_row_id = dsoi.dma_sql_obj_inst_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (dadsr_def_row_id=0)
    SELECT INTO "nl:"
     seqval = seq(dm_seq,nextval)
     FROM dual
     DETAIL
      dadsr_def_row_id = seqval
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Inserting rows in dma_sql_obj_inst table for SCD_TERM_DATA table."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    INSERT  FROM dma_sql_obj_inst dsoi
     SET dsoi.dma_sql_obj_inst_id = dadsr_def_row_id, dsoi.process_type = "ADD_DEFAULT_ROW", dsoi
      .object_type = "TABLE",
      dsoi.object_owner = "V500", dsoi.object_name = "SCD_TERM_DATA", dsoi.table_name =
      "SCD_TERM_DATA",
      dsoi.object_instance = 1, dsoi.active_ind = 1, dsoi.updt_cnt = 0,
      dsoi.updt_id = 0, dsoi.updt_dt_tm = cnvtdatetime(curdate,curtime3), dsoi.updt_task = 15301,
      dsoi.updt_applctx = 0
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   SET dm_err->eproc =
   "Verifying if dma_sql_obj_inst_attr table has a matching row for SCD_TERM_DATA table."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dma_sql_obj_inst_attr dsoia
    WHERE dsoia.dma_sql_obj_inst_id=dadsr_def_row_id
     AND dsoia.attr_name="COLUMN_LIST"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = "Inserting row in dma_sql_obj_inst_attr table for SCD_TERM_DATA table."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    INSERT  FROM dma_sql_obj_inst_attr dsoia
     SET dsoia.dma_sql_obj_inst_attr_id = seq(dm_seq,nextval), dsoia.dma_sql_obj_inst_id =
      dadsr_def_row_id, dsoia.attr_name = "COLUMN_LIST",
      dsoia.attr_seg_nbr = 1, dsoia.attr_value_char = "SCD_TERM_DATA_ID", dsoia.attr_value_num = 0.0,
      dsoia.updt_cnt = 0, dsoia.updt_id = 0, dsoia.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      dsoia.updt_task = 15301, dsoia.updt_applctx = 0
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_verify_custom_users(dvcu_inform_only_ind,dvcu_invalid_cust_user_ind)
   DECLARE dvcu_custom_users_msg = vc WITH protect, noconstant("")
   DECLARE dvcu_invalid_custom_users = vc WITH protect, noconstant("")
   IF (validate(dm2_bypass_verify_cust_users,- (1))=1)
    SET dm_err->eproc = "Bypassing validation of any database users that are marked custom."
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Verifying if any CERNER Solution users have been marked as CUSTOM users."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_CUSTOM_USER"
     AND ((di.info_name IN ("V500_OTG", "CER_CASVC", "CER_CONF", "CER_PREF", "CER_IAWARE",
    "CER_CENTRAL")) OR (((di.info_name="V500_BO*") OR (((di.info_name="V500_ETL*") OR (((di.info_name
    ="V500_MODEL*") OR (di.info_name="V500_DM*")) )) )) ))
    DETAIL
     IF (textlen(trim(dvcu_invalid_custom_users))=0)
      dvcu_invalid_custom_users = trim(di.info_name)
     ELSE
      dvcu_invalid_custom_users = concat(dvcu_invalid_custom_users,", ",trim(di.info_name))
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dvcu_invalid_cust_user_ind = 1
    SET dvcu_custom_users_msg = concat("Invalid database users found that are marked as custom: ",
     dvcu_invalid_custom_users)
    IF (dvcu_inform_only_ind=1)
     SET dm_err->eproc = dvcu_custom_users_msg
     CALL disp_msg("",dm_err->logfile,0)
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validating if any invalid database users exist."
     SET dm_err->emsg = dvcu_custom_users_msg
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_check_db_link(dcdl_in_db_link_name,dcdl_out_db_link_fnd_ind)
   DECLARE dcdl_cur_db_link_name = vc WITH protect, noconstant("")
   DECLARE dcdl_db_link_cnt = i2 WITH protect, noconstant(0)
   DECLARE dcdl_pos = i2 WITH protect, noconstant(0)
   SET dcdl_out_db_link_fnd_ind = 0
   SET dm_err->eproc = concat("Check if database link ",dcdl_in_db_link_name," exists.")
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    dl.db_link
    FROM all_db_links dl
    WHERE parser(build(" dl.db_link = '",dcdl_in_db_link_name,"*'"))
    DETAIL
     dcdl_pos = 0, dcdl_pos = findstring(".",dl.db_link,1)
     IF (dcdl_pos > 0)
      dcdl_cur_db_link_name = substring(1,(dcdl_pos - 1),dl.db_link)
     ELSE
      dcdl_cur_db_link_name = dl.db_link
     ENDIF
     IF (trim(cnvtupper(dcdl_cur_db_link_name))=trim(cnvtupper(dcdl_in_db_link_name)))
      dcdl_db_link_cnt = (dcdl_db_link_cnt+ 1)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (dcdl_db_link_cnt > 1)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Multiple database links match input database link (",
     dcdl_in_db_link_name,").")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ELSEIF (dcdl_db_link_cnt=1)
    SET dcdl_out_db_link_fnd_ind = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_del_preserved_ts(dcdl_tgt_db_name)
   SET dm_err->eproc = concat("Delete DM2_REPLICATE_DATA for database ",dm2_install_schema->
    target_dbase_name)
   CALL disp_msg("",dm_err->logfile,0)
   DELETE  FROM dm2_admin_dm_info di
    WHERE di.info_domain="DM2_REPLICATE_USER_TS"
     AND di.info_name=patstring(cnvtupper(build(dcdl_tgt_db_name,"-DB-*")))
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
 DECLARE dcfr_get_header_info(dghi_file_loc=vc,dghi_file_name=vc) = i2
 DECLARE dcfr_get_csv_row_cnt(dgcrc_file_name=vc,dgcrc_row_cnt=i4(ref)) = i2
 DECLARE dcfr_pop_coldic_rec(dpcr_table_in=vc) = i2
 DECLARE dcfr_build_col_list(null) = i2
 DECLARE dcfr_sea_csv_files(dssf_dir=vc,dssf_file_prefix=vc,dssf_schema_date=vc(ref)) = i2
 DECLARE dcfr_fix_afd(null) = i2
 IF ((validate(dcfr_csv_file->file_cnt,- (1))=- (1)))
  RECORD dcfr_csv_file(
    1 sf_ver = i4
    1 file_cnt = i4
    1 qual[*]
      2 file_suffix = vc
      2 file_desc = vc
      2 target_table = vc
      2 data_cnt = i4
  )
  SET dcfr_csv_file->sf_ver = 1
  SET dcfr_csv_file->file_cnt = 8
  SET stat = alterlist(dcfr_csv_file->qual,dcfr_csv_file->file_cnt)
  SET dcfr_csv_file->qual[1].file_suffix = "_h"
  SET dcfr_csv_file->qual[1].file_desc = "HEADER"
  SET dcfr_csv_file->qual[1].target_table = ""
  SET dcfr_csv_file->qual[1].data_cnt = 4
  SET dcfr_csv_file->qual[2].file_suffix = "_t"
  SET dcfr_csv_file->qual[2].file_desc = "TABLE"
  SET dcfr_csv_file->qual[2].target_table = "DM_AFD_TABLES"
  SET dcfr_csv_file->qual[2].data_cnt = 0
  SET dcfr_csv_file->qual[3].file_suffix = "_tc"
  SET dcfr_csv_file->qual[3].file_desc = "COLUMN"
  SET dcfr_csv_file->qual[3].target_table = "DM_AFD_COLUMNS"
  SET dcfr_csv_file->qual[3].data_cnt = 0
  SET dcfr_csv_file->qual[4].file_suffix = "_i"
  SET dcfr_csv_file->qual[4].file_desc = "INDEX"
  SET dcfr_csv_file->qual[4].target_table = "DM_AFD_INDEXES"
  SET dcfr_csv_file->qual[4].data_cnt = 0
  SET dcfr_csv_file->qual[5].file_suffix = "_ic"
  SET dcfr_csv_file->qual[5].file_desc = "INDCOL"
  SET dcfr_csv_file->qual[5].target_table = "DM_AFD_INDEX_COLUMNS"
  SET dcfr_csv_file->qual[5].data_cnt = 0
  SET dcfr_csv_file->qual[6].file_suffix = "_c"
  SET dcfr_csv_file->qual[6].file_desc = "CONS"
  SET dcfr_csv_file->qual[6].target_table = "DM_AFD_CONSTRAINTS"
  SET dcfr_csv_file->qual[6].data_cnt = 0
  SET dcfr_csv_file->qual[7].file_suffix = "_cc"
  SET dcfr_csv_file->qual[7].file_desc = "CONSCOL"
  SET dcfr_csv_file->qual[7].target_table = "DM_AFD_CONS_COLUMNS"
  SET dcfr_csv_file->qual[7].data_cnt = 0
  SET dcfr_csv_file->qual[8].file_suffix = "_sq"
  SET dcfr_csv_file->qual[8].file_desc = "SEQUENCE"
  SET dcfr_csv_file->qual[8].target_table = ""
  SET dcfr_csv_file->qual[8].data_cnt = 0
 ENDIF
 IF ((validate(dcfr_csv_header_info->admin_load_ind,- (1))=- (1)))
  RECORD dcfr_csv_header_info(
    1 admin_load_ind = i4
    1 source_rdbms = vc
    1 desc = vc
    1 sf_version = i4
  )
  SET dcfr_csv_header_info->admin_load_ind = 0
  SET dcfr_csv_header_info->source_rdbms = "DM2NOTSET"
  SET dcfr_csv_header_info->desc = "DM2NOTSET"
  SET dcfr_csv_header_info->sf_version = 0
 ENDIF
 IF (validate(dcfr_col_list->tbl,"-x")="-x"
  AND validate(dcfr_col_list->tbl,"-y")="-y")
  FREE RECORD dcfr_col_list
  RECORD dcfr_col_list(
    1 tbl = vc
    1 col[*]
      2 col_name = vc
      2 col_type = vc
  )
 ENDIF
 SUBROUTINE dcfr_get_header_info(dghi_file_name)
   DECLARE dghi_csv_rows = i4 WITH protect, noconstant(0)
   DECLARE dghi_found_str = vc WITH protect, noconstant(" ")
   DECLARE dghi_line_str = vc WITH protect, noconstant(" ")
   DECLARE dghi_field_number = i4 WITH protect, noconstant(1)
   DECLARE dghi_check_pos = i4 WITH protect, noconstant(0)
   DECLARE dghi_line_cnt = i4 WITH protect, noconstant(0)
   DECLARE dghi_line_len = i4 WITH protect, noconstant(0)
   SET dghi_csv_rows = 0
   IF (dcfr_get_csv_row_cnt(dghi_file_name,dghi_csv_rows)=0)
    RETURN(0)
   ENDIF
   IF (dghi_csv_rows=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("CSV Header File is empty")
    SET dm_err->eproc = "CSV Header File Validation"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Parsing data from csv file ",dghi_file_name)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   FREE SET file_loc
   SET logical file_loc value(dghi_file_name)
   FREE DEFINE rtl2
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    t.line
    FROM rtl2t t
    WHERE t.line > " "
    HEAD REPORT
     delim = ",", dghi_line_str = " ", dghi_line_cnt = 0
    DETAIL
     dghi_line_cnt = (dghi_line_cnt+ 1)
     IF (dghi_line_cnt=2)
      dghi_line_str = t.line, dghi_line_len = textlen(trim(dghi_line_str)), dghi_field_number = 1,
      dghi_check_pos = 0
      WHILE ((dghi_field_number <= dcfr_csv_file->qual[1].data_cnt))
        IF ('"""'=substring(1,3,dghi_line_str))
         dghi_check_pos = findstring('""",',substring(2,dghi_line_len,dghi_line_str)), dghi_found_str
          = substring(4,(dghi_check_pos - 3),dghi_line_str), dghi_line_str = substring((
          dghi_check_pos+ 5),dghi_line_len,dghi_line_str)
        ELSE
         dghi_check_pos = findstring(delim,dghi_line_str), dghi_found_str = substring(1,(
          dghi_check_pos - 1),dghi_line_str), dghi_line_str = substring((dghi_check_pos+ 1),
          dghi_line_len,dghi_line_str)
        ENDIF
        IF (dghi_field_number=1)
         dcfr_csv_header_info->desc = dghi_found_str
        ELSEIF (dghi_field_number=2)
         dcfr_csv_header_info->source_rdbms = dghi_found_str
        ELSEIF (dghi_field_number=3)
         dcfr_csv_header_info->admin_load_ind = cnvtint(dghi_found_str)
        ELSEIF (dghi_field_number=4)
         dcfr_csv_header_info->sf_version = cnvtint(dghi_found_str)
        ENDIF
        dghi_field_number = (dghi_field_number+ 1)
      ENDWHILE
     ENDIF
    WITH nocounter, maxcol = 32768
   ;end select
   FREE DEFINE rtl2
   FREE SET file_loc
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dcfr_csv_header_info->desc=" "))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Description is invalid."
    SET dm_err->eproc = "Validating Header description."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dcfr_csv_header_info->source_rdbms != "ORACLE"))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat(trim(dcfr_csv_header_info->source_rdbms)," is an invalid RDBMS.")
    SET dm_err->eproc = "Validating Header source RDBMS."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dcfr_csv_header_info->admin_load_ind != 0))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Admin load indicator is invalid."
    SET dm_err->eproc = "Validating Header admin load indicator."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcfr_get_csv_row_cnt(dgcrc_file_name,dgcrc_row_cnt)
   SET dgcrc_row_cnt = 0
   SET dm_err->eproc = concat("Determine rows in csv file ",dgcrc_file_name)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   FREE SET file_loc
   SET logical file_loc value(dgcrc_file_name)
   FREE DEFINE rtl2
   DEFINE rtl2 "file_loc"
   SELECT INTO "NL:"
    FROM rtl2t t
    WHERE t.line > " "
    DETAIL
     dgcrc_row_cnt = (dgcrc_row_cnt+ 1)
    WITH nocounter
   ;end select
   FREE DEFINE rtl2
   FREE SET file_loc
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dgcrc_row_cnt = 0
    RETURN(0)
   ENDIF
   SET dgcrc_row_cnt = (dgcrc_row_cnt - 1)
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("Numbers of rows to process: ",dgcrc_row_cnt))
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcfr_pop_coldic_rec(dpcr_table_in)
   DECLARE dpcr_cnt = i4 WITH protect, noconstant(0)
   DECLARE dpcr_idx = i4 WITH protect, noconstant(0)
   DECLARE dcpr_col_oradef_ind = i2 WITH protect, noconstant(0)
   DECLARE dcpr_col_ccldef_ind = i2 WITH protect, noconstant(0)
   DECLARE dpcr_data_type = vc WITH protect, noconstant("")
   SET dcfr_col_list->tbl = ""
   SET stat = alterlist(dcfr_col_list->col,0)
   SET dcfr_col_list->tbl = cnvtupper(dpcr_table_in)
   SET dm_err->eproc = concat("Get list of columns in dictionary for ",dcfr_col_list->tbl)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   FOR (dpcr_idx = 1 TO size(columns_1->list_1,5))
     SET dcpr_col_oradef_ind = 0
     SET dcpr_col_ccldef_ind = 0
     SET dpcr_data_type = ""
     IF (dm2_table_column_exists("",dcfr_col_list->tbl,columns_1->list_1[dpcr_idx].field_name,0,1,
      2,dcpr_col_oradef_ind,dcpr_col_ccldef_ind,dpcr_data_type)=0)
      RETURN(0)
     ENDIF
     IF (dcpr_col_ccldef_ind=1)
      SET dpcr_cnt = (dpcr_cnt+ 1)
      SET stat = alterlist(dcfr_col_list->col,dpcr_cnt)
      SET dcfr_col_list->col[dpcr_cnt].col_name = trim(columns_1->list_1[dpcr_idx].field_name)
      SET dcfr_col_list->col[dpcr_cnt].col_type = substring(1,1,dpcr_data_type)
     ENDIF
   ENDFOR
   IF (size(dcfr_col_list->col,5)=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("No rows identified according to dictionary for ",dcfr_col_list->tbl)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcfr_col_list)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcfr_build_col_list(null)
  DECLARE dbcl_cnt = i4 WITH protect, noconstant(0)
  FOR (dbcl_cnt = 1 TO size(dcfr_col_list->col,5))
   CASE (dcfr_col_list->col[dbcl_cnt].col_type)
    OF "C":
     CALL dm2_push_cmd(concat("dcv.",dcfr_col_list->col[dbcl_cnt].col_name," = ",
       "evaluate(requestin->list_0[d.seq].",dcfr_col_list->col[dbcl_cnt].col_name,
       ",'::DM2NULLVALUE::',","null, requestin->list_0[d.seq].",dcfr_col_list->col[dbcl_cnt].col_name,
       ")"),0)
    OF "Q":
     CALL dm2_push_cmd(concat("dcv.",dcfr_col_list->col[dbcl_cnt].col_name," = ",
       "evaluate(requestin->list_0[d.seq].",dcfr_col_list->col[dbcl_cnt].col_name,
       ",'::DM2NULLVALUE::',","null, cnvtdatetime(requestin->list_0[d.seq].",dcfr_col_list->col[
       dbcl_cnt].col_name,"))"),0)
    OF "I":
     CALL dm2_push_cmd(concat("dcv.",dcfr_col_list->col[dbcl_cnt].col_name," = ",
       "evaluate(requestin->list_0[d.seq].",dcfr_col_list->col[dbcl_cnt].col_name,
       ",'::DM2NULLVALUE::',","null, cnvtint(requestin->list_0[d.seq].",dcfr_col_list->col[dbcl_cnt].
       col_name,"))"),0)
    OF "F":
     CALL dm2_push_cmd(concat("dcv.",dcfr_col_list->col[dbcl_cnt].col_name," = ",
       "evaluate(requestin->list_0[d.seq].",dcfr_col_list->col[dbcl_cnt].col_name,
       ",'::DM2NULLVALUE::',","null, cnvtreal(requestin->list_0[d.seq].",dcfr_col_list->col[dbcl_cnt]
       .col_name,"))"),0)
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("Column Name:",dcfr_col_list->col[dbcl_cnt].col_name,". Data_Type:",
      dcfr_col_list->col[dbcl_cnt].col_type," is not recognizable by load script.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
   ENDCASE
   IF (dbcl_cnt != size(dcfr_col_list->col,5))
    CALL dm2_push_cmd(",",0)
   ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE dcfr_sea_csv_files(dssf_dir,dssf_file_prefix,dssf_schema_date)
   DECLARE dcfr_dcl_find = vc WITH protect, noconstant("")
   DECLARE dcfr_err_str = vc WITH protect, noconstant("")
   SET dssf_schema_date = "01-JAN-1800"
   IF (dssf_file_prefix != "dm2a")
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating file_prefix."
    SET dm_err->emsg = "File_prefix must be 'dm2a'"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dcfr_dcl_find = concat("dir/columns=1  ",build(dssf_dir),dssf_file_prefix,"*.csv")
    SET dcfr_err_str = "no files found"
   ELSEIF ((dm2_sys_misc->cur_os="WIN"))
    SET dcfr_dcl_find = concat("dir ",build(dssf_dir),"\",dssf_file_prefix,"*.csv")
    SET dcfr_err_str = "file not found"
   ELSE
    SET dcfr_dcl_find = concat("find ",build(dssf_dir),' -name "',dssf_file_prefix,
     '*.csv" -print | wc -w')
    SET dcfr_err_str = "0"
   ENDIF
   IF (dm2_push_dcl(dcfr_dcl_find)=0)
    IF (findstring(dcfr_err_str,cnvtlower(dm_err->errtext)) > 0)
     SET dm_err->eproc = "Find schema date."
     SET dm_err->emsg = "No schema date was found."
     SET dm_err->err_ind = 0
     RETURN(1)
    ENDIF
    RETURN(0)
   ELSE
    IF ((dm2_sys_misc->cur_os IN ("AIX", "HPX", "LNX")))
     SET dcfr_dcl_find = concat("find ",build(dssf_dir),' -name "',dssf_file_prefix,'*.csv" -print')
     SET dm_err->eproc = "Building list of schema files to gather schema date"
     IF (dm2_push_dcl(dcfr_dcl_find)=0)
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
       starting_pos = findstring(cnvtupper(dssf_file_prefix),r.line)
      ELSE
       starting_pos = findstring(dssf_file_prefix,r.line)
      ENDIF
      stripped_date = cnvtdate(substring((starting_pos+ 4),8,r.line))
      IF (stripped_date > compare_date)
       dssf_schema_date = format(stripped_date,"DD-MMM-YYYY;;d"), compare_date = stripped_date
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
 SUBROUTINE dcfr_fix_afd(null)
   DECLARE dfa_idx1 = i4 WITH protect, noconstant(0)
   DECLARE dfa_idx2 = i4 WITH protect, noconstant(0)
   DECLARE dfa_col_oradef_ind = i2 WITH protect, noconstant(0)
   DECLARE dfa_col_ccldef_ind = i2 WITH protect, noconstant(0)
   DECLARE dfa_data_type = vc WITH protect, noconstant("")
   FREE RECORD dfa_tbls
   RECORD dfa_tbls(
     1 cnt = i4
     1 list[*]
       2 exist_ind = i2
       2 tbl_name = vc
       2 stmt = vc
   ) WITH protect
   SET dm_err->eproc = "Verify which tables exist in database"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM user_tables ut
    WHERE ut.table_name IN ("DM_AFD_TABLES", "DM_AFD_COLUMNS", "DM_AFD_INDEXES",
    "DM_AFD_INDEX_COLUMNS", "DM_AFD_CONSTRAINTS",
    "DM_AFD_CONS_COLUMNS")
    HEAD REPORT
     dfa_tbls->cnt = 0
    DETAIL
     dfa_tbls->cnt = (dfa_tbls->cnt+ 1), stat = alterlist(dfa_tbls->list,dfa_tbls->cnt), dfa_tbls->
     list[dfa_tbls->cnt].tbl_name = trim(ut.table_name),
     dfa_tbls->list[dfa_tbls->cnt].exist_ind = 0, dfa_tbls->list[dfa_tbls->cnt].stmt = concat(
      " rdb alter table ",trim(ut.table_name)," add OWNER varchar2(30) null go ")
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Verify which tables need the column"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM user_tab_columns utc
    WHERE expand(dfa_idx1,1,dfa_tbls->cnt,utc.table_name,dfa_tbls->list[dfa_idx1].tbl_name)
     AND utc.column_name="OWNER"
    DETAIL
     dfa_idx2 = locateval(dfa_idx1,1,dfa_tbls->cnt,utc.table_name,dfa_tbls->list[dfa_idx1].tbl_name)
     IF (dfa_idx2 != 0)
      dfa_tbls->list[dfa_idx2].exist_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dfa_tbls->cnt > 0))
    FOR (dfa_idx1 = 1 TO dfa_tbls->cnt)
      IF ((dfa_tbls->list[dfa_idx1].exist_ind=0))
       IF (dm2_push_cmd(dfa_tbls->list[dfa_idx1].stmt,1)=0)
        RETURN(0)
       ENDIF
      ENDIF
      SET dfa_col_ccldef_ind = 0
      IF (dm2_table_column_exists("",dfa_tbls->list[dfa_idx1].tbl_name,"OWNER",0,1,
       1,dfa_col_oradef_ind,dfa_col_ccldef_ind,dfa_data_type)=0)
       RETURN(0)
      ENDIF
      IF (dfa_col_ccldef_ind=0)
       EXECUTE oragen3 dfa_tbls->list[dfa_idx1].tbl_name
       IF ((dm_err->err_ind != 0))
        RETURN(0)
       ENDIF
      ENDIF
    ENDFOR
    IF ((dm_err->debug_flag > 1))
     CALL echorecord(dfa_tbls)
    ENDIF
    SET dm_err->eproc = "Validate that tables got the column"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM user_tab_columns utc
     WHERE expand(dfa_idx1,1,dfa_tbls->cnt,utc.table_name,dfa_tbls->list[dfa_idx1].tbl_name)
      AND utc.column_name="OWNER"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((curqual != dfa_tbls->cnt))
     SET dm_err->emsg = "Validation failed for OWNER in AFD tables"
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
#end_csv_file_routines_inc
 IF (validate(inhouse_reply->table_name,"X")="X"
  AND validate(inhouse_reply->table_name,"Y")="Y")
  FREE RECORD inhouse_reply
  RECORD inhouse_reply(
    1 table_name = vc
    1 schema_date = f8
    1 status = vc
    1 status_msg = vc
    1 logfile = vc
    1 err_code = f8
    1 parent_proj_name = vc
    1 tspace_list[*]
      2 tspace_name = vc
  )
  SET inhouse_reply->table_name = "NONE"
  SET inhouse_reply->schema_date = 0.0
  SET inhouse_reply->status = "NONE"
  SET inhouse_reply->status_msg = "NONE"
  SET inhouse_reply->logfile = "NONE"
  SET inhouse_reply->err_code = 0
  SET inhouse_reply->parent_proj_name = ""
 ENDIF
 DECLARE sbr_check_for_a_nls(null) = i2 WITH protect, noconstant(0)
 DECLARE sbr_load_csv(null) = null
 DECLARE sbr_get_nls_lang(null) = vc WITH protect, noconstant("")
 IF ( NOT (validate(dcfan_columns,0)))
  FREE RECORD dcfan_columns
  RECORD dcfan_columns(
    1 rows[*]
      2 nls_language = vc
      2 nls_sort_value = vc
  )
 ENDIF
 SUBROUTINE sbr_check_for_a_nls(null)
   IF ( NOT (validate(dcfan_columns->rows[1].nls_language,0)))
    CALL sbr_load_csv(null)
   ENDIF
   SELECT INTO "nl:"
    FROM v$nls_parameters v,
     (dummyt d  WITH seq = value(size(dcfan_columns->rows,5)))
    PLAN (d)
     JOIN (v
     WHERE v.parameter="NLS_LANGUAGE"
      AND (v.value=dcfan_columns->rows[d.seq].nls_language))
    WITH nocounter
   ;end select
   IF (curqual > 0)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE sbr_load_csv(null)
   DECLARE istart = i2 WITH protect, noconstant(0)
   DECLARE iend = i2 WITH protect, noconstant(0)
   DECLARE rowcnt = i2 WITH protect, noconstant(0)
   DECLARE csvfile = vc WITH protect, constant("cer_install:dac_a_nls_languages.csv")
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc csvfile
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    FROM rtl2t r
    HEAD REPORT
     rowcnt = - (1)
    DETAIL
     IF (size(trim(r.line),1) > 0)
      rowcnt = (rowcnt+ 1)
      IF (rowcnt > 0)
       IF (mod(rowcnt,10)=1)
        stat = alterlist(dcfan_columns->rows,(rowcnt+ 9))
       ENDIF
       istart = 1, iend = 1
       WHILE (iend > 0)
         iend = findstring(",",r.line,istart,0)
         IF (iend > 0)
          dcfan_columns->rows[rowcnt].nls_language = substring(istart,(iend - istart),r.line)
         ELSE
          dcfan_columns->rows[rowcnt].nls_sort_value = substring(istart,(size(r.line,1) - istart),r
           .line)
         ENDIF
         istart = (iend+ 1)
       ENDWHILE
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(dcfan_columns->rows,rowcnt)
    WITH nocounter
   ;end select
   FREE DEFINE rtl2
 END ;Subroutine
 SUBROUTINE sbr_get_nls_lang(null)
   IF ( NOT (validate(dcfan_columns->rows[1].nls_language,0)))
    CALL sbr_load_csv(null)
   ENDIF
   DECLARE dcfan_nls_sort = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM v$nls_parameters v,
     (dummyt d  WITH seq = value(size(dcfan_columns->rows,5)))
    PLAN (d)
     JOIN (v
     WHERE v.parameter="NLS_LANGUAGE"
      AND (v.value=dcfan_columns->rows[d.seq].nls_language))
    DETAIL
     dcfan_nls_sort = dcfan_columns->rows[d.seq].nls_sort_value
    WITH nocounter
   ;end select
   RETURN(dcfan_nls_sort)
 END ;Subroutine
 DECLARE dsr_sd_in_use_check(dsiuc_db_link=vc,dsiuc_sd_in_use_ind=i2(ref)) = i2
 DECLARE dsr_usage_prep(dup_db_link=vc) = i2
 DECLARE dsr_sd_get_trigger_version(dsgtv_owner=vc,dsgtv_trigger_name=vc,dsgtv_table_name=vc,
  dsgtv_when_clause=vc,dsgtv_trig_version=i4(ref)) = i2
 DECLARE dsr_check_object_state(dcos_owner=vc,dcos_object_type=vc,dcos_object_name=vc,dcos_state=vc,
  dcos_obj_drop_ind=i2(ref)) = i2
 DECLARE dsr_chk_sd_in_process(dcsip_db_group=vc,dcsip_owner=vc,dcsip_sd_in_process=i2(ref)) = i2
 IF ((validate(dsr_obj_state->cnt,- (1))=- (1))
  AND (validate(dsr_obj_state->cnt,- (2))=- (2)))
  FREE RECORD dsr_obj_state
  RECORD dsr_obj_state(
    1 obj_owner = vc
    1 obj_type = vc
    1 state = vc
    1 cnt = i4
    1 qual[*]
      2 obj_name = vc
  )
 ENDIF
 IF (validate(dsr_sd_misc->ccl_tbldef_sync_ind,0)=0
  AND validate(dsr_sd_misc->ccl_tbldef_sync_ind,1)=1)
  FREE RECORD dsr_sd_misc
  RECORD dsr_sd_misc(
    1 ccl_tbldef_sync_ind = i2
  )
  SET dsr_sd_misc->ccl_tbldef_sync_ind = 0
 ENDIF
 SUBROUTINE dsr_sd_in_use_check(dsiuc_db_link,dsiuc_sd_in_use_ind)
   DECLARE dsiuc_qry_stats = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dsiuc_sd_tbl_v_ind = i2 WITH protect, noconstant(0)
   DECLARE dsiuc_qry_sd_tbl_cnt = i4 WITH protect, noconstant(0)
   DECLARE dsiuc_sd_tbl_ind = i2 WITH protect, noconstant(0)
   DECLARE dsiuc_pkg_qry_cnt = i4 WITH protect, noconstant(0)
   DECLARE dsiuc_pkg_valid_cnt = i4 WITH protect, noconstant(0)
   DECLARE dsiuc_sd_pkg_ind = i2 WITH protect, noconstant(0)
   DECLARE dsiuc_dm_info_fnd_ind = i2 WITH protect, noconstant(0)
   DECLARE dsiuc_dm_info_cnt = i2 WITH protect, noconstant(0)
   DECLARE dsiuc_dm_info_in_view_ind = i2 WITH protect, noconstant(0)
   DECLARE dsiuc_use_link_ind = i2 WITH protect, noconstant(0)
   DECLARE dsiuc_db_link_new = vc WITH protect, noconstant("")
   DECLARE dsiuc_mill_cds_ind = i2 WITH protect, noconstant(0)
   DECLARE dsiuc_sd_param_table = vc WITH noconstant("")
   SET dsiuc_sd_in_use_ind = 0
   IF (trim(dsiuc_db_link,3) > ""
    AND dsiuc_db_link != "DM2NOTSET")
    IF (substring(1,1,dsiuc_db_link)="@")
     SET dsiuc_db_link_new = substring(2,(size(trim(dsiuc_db_link,3)) - 1),dsiuc_db_link)
    ELSE
     SET dsiuc_db_link_new = dsiuc_db_link
    ENDIF
    SET dsiuc_use_link_ind = 1
   ENDIF
   IF (currdbuser != "V500")
    SET dsiuc_sd_in_use_ind = 0
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Check to see if CERADM schema exists."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT
    IF (dsiuc_use_link_ind=1)
     FROM (parser(concat("dba_users@",dsiuc_db_link_new)) d)
     WHERE d.username="CERADM"
    ELSE
     FROM dba_users d
     WHERE d.username="CERADM"
    ENDIF
    INTO "nl:"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (curqual=0)
    IF ((dm_err->debug_flag > 5))
     CALL echo("SD framework is not in use.")
    ENDIF
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Check to see if SD_PARAM exists."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT
    IF (dsiuc_use_link_ind=1)
     FROM (parser(concat("dba_tables@",dsiuc_db_link_new)) t)
     WHERE t.owner="CERADM"
      AND t.table_name="SD_PARAM"
    ELSE
     FROM dba_tables t
     WHERE t.owner="CERADM"
      AND t.table_name="SD_PARAM"
    ENDIF
    INTO "nl:"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (curqual=0)
    IF ((dm_err->debug_flag > 5))
     CALL echo("SD_PARAM do not exists.")
    ENDIF
    SET dsiuc_sd_in_use_ind = 0
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Check to see if Millennium-CDS in use."
   CALL disp_msg("",dm_err->logfile,0)
   IF (dsiuc_use_link_ind=1)
    SET dsiuc_sd_param_table = concat("CERADM.SD_PARAM@",dsiuc_db_link_new)
   ELSE
    SET dsiuc_sd_param_table = "CERADM.SD_PARAM"
   ENDIF
   SELECT INTO "nl:"
    x = sqlpassthru(concat(asis("(select count(*) from "),dsiuc_sd_param_table," SDP ",asis(
       "where SDP.PTYPE  = 'CDS_GLOBAL_CONFIG'"),asis(
       "  and SDP.PNAME  = 'MILLENNIUM_CDS_IN_USE') as rowsCnt")),0)
    FROM dual
    DETAIL
     dsiuc_mill_cds_ind = x
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (dsiuc_mill_cds_ind=0)
    IF ((dm_err->debug_flag > 5))
     CALL echo("Millennium-CDS is not in use.")
    ENDIF
    SET dsiuc_sd_in_use_ind = 0
    RETURN(1)
   ENDIF
   IF ((dm_err->debug_flag > 5))
    CALL echo("Millennium-CDS is in use.")
   ENDIF
   SET dm_err->eproc = "Check to see if dm_info exists or not."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT
    IF (dsiuc_use_link_ind=1)
     dsiuc_tmp_qry_cnt = count(*)
     FROM (parser(concat("dba_tables@",dsiuc_db_link_new)) d)
     WHERE d.owner=currdbuser
      AND d.table_name="DM_INFO"
    ELSE
     dsiuc_tmp_qry_cnt = count(*)
     FROM dba_tables d
     WHERE d.owner=currdbuser
      AND d.table_name="DM_INFO"
    ENDIF
    INTO "nl:"
    DETAIL
     dsiuc_dm_info_fnd_ind = dsiuc_tmp_qry_cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dsiuc_dm_info_fnd_ind=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "DM_INFO does not exist"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Check to see if sd not in use due to dm_info override."
   SELECT
    IF (dsiuc_use_link_ind=1)
     FROM (parser(concat("DM_INFO@",dsiuc_db_link_new)) di)
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="SD_NOT_IN_USE_OVERRIDE"
    ELSE
     FROM dm_info di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="SD_NOT_IN_USE_OVERRIDE"
    ENDIF
    INTO "nl:"
    DETAIL
     dsiuc_dm_info_cnt = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (dsiuc_dm_info_cnt > 0)
    CALL echo("SD not in use due to DM_INFO override")
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Check to see if Schema Deployment SD_TABLE_VERSION_V view exists or not."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT
    IF (dsiuc_use_link_ind)
     FROM (parser(concat("dba_objects@",dsiuc_db_link_new)) d)
     WHERE d.owner="CERADM"
      AND d.object_name="SD_TABLE_VERSION_V"
      AND d.object_type="VIEW"
    ELSE
     FROM dba_objects d
     WHERE d.owner="CERADM"
      AND d.object_name="SD_TABLE_VERSION_V"
      AND d.object_type="VIEW"
    ENDIF
    INTO "nl:"
    DETAIL
     dsiuc_qry_stats = d.status
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dsiuc_qry_stats="VALID")
    SET dm_err->eproc = "Check to see if dm_info is union of SD view or not."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT
     IF (dsiuc_use_link_ind)
      FROM (parser(concat("dba_views@",dsiuc_db_link_new)) v)
      WHERE v.owner="CERADM"
       AND v.view_name="SD_TABLE_VERSION_V"
     ELSE
      FROM dba_views v
      WHERE v.owner="CERADM"
       AND v.view_name="SD_TABLE_VERSION_V"
     ENDIF
     INTO "nl:"
     DETAIL
      IF (cnvtlower(v.text)="*union all*"
       AND cnvtlower(v.text)="*v500*dm_info*")
       dsiuc_dm_info_in_view_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) > 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dsiuc_dm_info_in_view_ind=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "No union of V500.DM_INFO in SD view"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dsiuc_sd_tbl_v_ind = 1
   ELSEIF (dsiuc_qry_stats="INVALID")
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid Schema deployment Objects exists."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Check to see if Schema Deployment tables exists or not."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT
    IF (dsiuc_use_link_ind)
     dsiuc_tbl_tmp_cnt = count(*)
     FROM (parser(concat("dba_tables@",dsiuc_db_link_new)) t)
     WHERE t.owner="CERADM"
      AND t.table_name IN ("SD_TABLES", "SD_TABLE_COLS", "SD_TABLE_INDS", "SD_TABLE_IND_COLS",
     "SD_TABLE_CONS",
     "SD_TABLE_CON_COLS", "SD_TABLE_GROUP", "SD_DDL_OPS", "SD_OBJECT_VERSION", "SD_OBJECT_STATE",
     "SD_PROCESS_EVENT")
    ELSE
     dsiuc_tbl_tmp_cnt = count(*)
     FROM dba_tables t
     WHERE t.owner="CERADM"
      AND t.table_name IN ("SD_TABLES", "SD_TABLE_COLS", "SD_TABLE_INDS", "SD_TABLE_IND_COLS",
     "SD_TABLE_CONS",
     "SD_TABLE_CON_COLS", "SD_TABLE_GROUP", "SD_DDL_OPS", "SD_OBJECT_VERSION", "SD_OBJECT_STATE",
     "SD_PROCESS_EVENT")
    ENDIF
    INTO "nl:"
    DETAIL
     dsiuc_qry_sd_tbl_cnt = dsiuc_tbl_tmp_cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dsiuc_qry_sd_tbl_cnt=11)
    SET dsiuc_sd_tbl_ind = 1
   ELSEIF (dsiuc_qry_sd_tbl_cnt > 0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Incomplete SD table(s) exists."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc =
   "Check to see if Schema Deployment SD_OBJECT_VERSION_PKG package exists or not"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT
    IF (dsiuc_use_link_ind)
     FROM (parser(concat("dba_objects@",dsiuc_db_link_new)) o)
     WHERE o.owner="CERADM"
      AND o.object_name="SD_OBJECT_VERSION_PKG"
      AND o.object_type IN ("PACKAGE", "PACKAGE BODY")
    ELSE
     FROM dba_objects o
     WHERE o.owner="CERADM"
      AND o.object_name="SD_OBJECT_VERSION_PKG"
      AND o.object_type IN ("PACKAGE", "PACKAGE BODY")
    ENDIF
    INTO "nl:"
    DETAIL
     dsiuc_pkg_qry_cnt = (dsiuc_pkg_qry_cnt+ 1)
     IF (o.status="VALID")
      dsiuc_pkg_valid_cnt = (dsiuc_pkg_valid_cnt+ 1)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dsiuc_pkg_valid_cnt=2)
    SET dsiuc_sd_pkg_ind = 1
   ELSEIF (dsiuc_pkg_qry_cnt > 0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid Schema deployment SD_OBJECT_VERSION_PKG package exists."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dsiuc_sd_tbl_v_ind=1
    AND dsiuc_sd_tbl_ind=1
    AND dsiuc_sd_pkg_ind=1)
    CALL echo("SD framework is in use")
    SET dsiuc_sd_in_use_ind = 1
   ELSEIF (dsiuc_sd_tbl_v_ind=0
    AND dsiuc_sd_tbl_ind=0
    AND dsiuc_sd_pkg_ind=0)
    CALL echo("SD framework is not in use")
    SET dsiuc_sd_in_use_ind = 0
   ELSE
    SET dm_err->eproc = "Check if SD objects exists or not"
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Incomplete Schema Deployment framework."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsr_usage_prep(dup_db_link)
   FREE RECORD dsr_ceradm_rs
   RECORD dsr_ceradm_rs(
     1 tbl_cnt = i4
     1 tbl[*]
       2 tbl_name = vc
       2 ccl_def_ind = i2
       2 col_cnt = i4
       2 col[*]
         3 col_name = vc
   )
   DECLARE dup_use_link_ind = i2 WITH protect, noconstant(0)
   DECLARE dup_db_link_new = vc WITH protect, noconstant("")
   DECLARE dup_tblx = i4 WITH protect, noconstant(0)
   DECLARE dup_colx = i4 WITH protect, noconstant(0)
   DECLARE dup_col_fnd_ind = i2 WITH protect, noconstant(0)
   DECLARE dup_coldef_fnd_ind = i2 WITH protect, noconstant(0)
   DECLARE dup_data_type = vc WITH protect, noconstant("")
   IF (trim(dup_db_link,3) > ""
    AND dup_db_link != "DM2NOTSET")
    IF (substring(1,1,dup_db_link)="@")
     SET dup_db_link_new = substring(2,(size(trim(dup_db_link,3)) - 1),dup_db_link)
    ELSE
     SET dup_db_link_new = dup_db_link
    ENDIF
    SET dup_use_link_ind = 1
   ENDIF
   IF (currdbuser != "V500")
    RETURN(1)
   ENDIF
   IF (validate(dsr_sd_misc->ccl_tbldef_sync_ind,0)=1)
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Loading CERADM Record Structure"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT
    IF (dup_use_link_ind=1)
     FROM (parser(concat("dba_tab_columns@",dup_db_link_new)) dtc)
     WHERE dtc.owner="CERADM"
      AND dtc.table_name="SD*"
     ORDER BY dtc.table_name, dtc.column_name
    ELSE
     FROM dba_tab_columns dtc
     WHERE dtc.owner="CERADM"
      AND dtc.table_name="SD*"
     ORDER BY dtc.table_name, dtc.column_name
    ENDIF
    INTO "nl:"
    HEAD REPORT
     dup_tblx = 0
    HEAD dtc.table_name
     dup_colx = 0, dup_tblx = (dup_tblx+ 1)
     IF (mod(dup_tblx,10)=1)
      stat = alterlist(dsr_ceradm_rs->tbl,(dup_tblx+ 9))
     ENDIF
     dsr_ceradm_rs->tbl[dup_tblx].tbl_name = dtc.table_name, dsr_ceradm_rs->tbl[dup_tblx].ccl_def_ind
      = 0
    DETAIL
     dup_colx = (dup_colx+ 1)
     IF (mod(dup_colx,10)=1)
      stat = alterlist(dsr_ceradm_rs->tbl[dup_tblx].col,(dup_colx+ 9))
     ENDIF
     dsr_ceradm_rs->tbl[dup_tblx].col[dup_colx].col_name = dtc.column_name
    FOOT  dtc.table_name
     stat = alterlist(dsr_ceradm_rs->tbl[dup_tblx].col,dup_colx), dsr_ceradm_rs->tbl[dup_tblx].
     col_cnt = dup_colx
    FOOT REPORT
     stat = alterlist(dsr_ceradm_rs->tbl,dup_tblx), dsr_ceradm_rs->tbl_cnt = dup_tblx
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Comparing CCL Definitions to CERADM Record Structure"
   CALL disp_msg("",dm_err->logfile,0)
   FOR (dup_tblx = 1 TO dsr_ceradm_rs->tbl_cnt)
     IF (checkdic(cnvtupper(dsr_ceradm_rs->tbl[dup_tblx].tbl_name),"T",0)=2)
      FOR (dup_colx = 1 TO dsr_ceradm_rs->tbl[dup_tblx].col_cnt)
        SET dup_coldef_fnd_ind = 0
        IF (dm2_table_column_exists("",cnvtupper(dsr_ceradm_rs->tbl[dup_tblx].tbl_name),cnvtupper(
          dsr_ceradm_rs->tbl[dup_tblx].col[dup_colx].col_name),0,1,
         1,dup_col_fnd_ind,dup_coldef_fnd_ind,dup_data_type)=0)
         RETURN(0)
        ENDIF
        IF (dup_coldef_fnd_ind=0)
         SET dsr_ceradm_rs->tbl[dup_tblx].ccl_def_ind = 1
         SET dup_colx = dsr_ceradm_rs->tbl[dup_tblx].col_cnt
        ENDIF
      ENDFOR
     ELSE
      SET dsr_ceradm_rs->tbl[dup_tblx].ccl_def_ind = 1
     ENDIF
   ENDFOR
   SET dup_tblx = 0
   SET dup_tblx = locateval(dup_tblx,1,dsr_ceradm_rs->tbl_cnt,1,dsr_ceradm_rs->tbl[dup_tblx].
    ccl_def_ind)
   IF (dup_tblx > 0)
    SET dm_err->eproc = "Create CCL definitions for SD tables"
    CALL disp_msg("",dm_err->logfile,0)
    FOR (dup_tblx = 1 TO dsr_ceradm_rs->tbl_cnt)
     IF ((dsr_ceradm_rs->tbl[dup_tblx].ccl_def_ind=1))
      IF (dup_use_link_ind=1)
       EXECUTE oragen3 cnvtupper(concat("CERADM.",dsr_ceradm_rs->tbl[dup_tblx].tbl_name,"@",
         dup_db_link_new))
      ELSE
       EXECUTE oragen3 cnvtupper(concat("CERADM.",dsr_ceradm_rs->tbl[dup_tblx].tbl_name))
      ENDIF
     ENDIF
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ENDFOR
   ENDIF
   IF (validate(dsr_sd_misc->ccl_tbldef_sync_ind,- (1))=0)
    SET dsr_sd_misc->ccl_tbldef_sync_ind = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsr_check_object_state(dcos_owner,dcos_object_type,dcos_object_name,dcos_state,
  dcos_obj_drop_ind)
   DECLARE dcos_obj_idx = i4 WITH protect, noconstant(0)
   SET dcos_obj_drop_ind = 0
   IF ((((dsr_obj_state->cnt=0)) OR ((((dsr_obj_state->obj_type != dcos_object_type)) OR ((
   dsr_obj_state->state != dcos_state))) )) )
    SET stat = alterlist(dsr_obj_state->qual,0)
    SET dsr_obj_state->cnt = 0
    SET dsr_obj_state->obj_owner = dcos_owner
    SET dsr_obj_state->obj_type = dcos_object_type
    SET dsr_obj_state->state = dcos_state
    SET dm_err->eproc = "Check to see if object is in dropped state or not."
    SELECT INTO "nl:"
     FROM (ceradm.sd_object_state sos)
     WHERE sos.object_owner=dcos_owner
      AND sos.object_type=dcos_object_type
      AND sos.state=dcos_state
     DETAIL
      dsr_obj_state->cnt = (dsr_obj_state->cnt+ 1), stat = alterlist(dsr_obj_state->qual,
       dsr_obj_state->cnt), dsr_obj_state->qual[dsr_obj_state->cnt].obj_name = sos.object_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) > 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dsr_obj_state->cnt > 0))
    SET dcos_obj_idx = locateval(dcos_obj_idx,1,dsr_obj_state->cnt,dcos_object_name,dsr_obj_state->
     qual[dcos_obj_idx].obj_name)
   ENDIF
   IF (dcos_obj_idx > 0)
    SET dcos_obj_drop_ind = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsr_sd_get_trigger_version(dsgtv_owner,dsgtv_trigger_name,dsgtv_table_name,
  dsgtv_when_clause,dsgtv_trig_version)
   DECLARE dsgtv_qry_cnt = i4 WITH protect, noconstant(0)
   DECLARE regexp_replace() = c300
   SET dm_err->eproc = "Retrieving from dba_triggers to pull the trigger version."
   SELECT
    IF (dsgtv_when_clause != "DM2NOTSET")
     tmp_version = regexp_replace(dt.description,"(.*/\*version_)(\d+)(\*/.*)","\2",1,0,
      "in")
     FROM dba_triggers dt
     WHERE dt.trigger_name=patstring(dsgtv_trigger_name)
      AND dt.table_name=dsgtv_table_name
      AND cnvtupper(dt.when_clause)=patstring(cnvtupper(dsgtv_when_clause))
      AND dt.owner=dsgtv_owner
    ELSE
     tmp_version = regexp_replace(dt.description,"(.*/\*version_)(\d+)(\*/.*)","\2",1,0,
      "in")
     FROM dba_triggers dt
     WHERE dt.trigger_name=dsgtv_trigger_name
      AND dt.table_name=dsgtv_table_name
      AND dt.owner=dsgtv_owner
    ENDIF
    INTO "nl:"
    DETAIL
     dsgtv_qry_cnt = (dsgtv_qry_cnt+ 1), dsgtv_trig_version = cnvtint(tmp_version)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Check to see if multiple rows are qualified from dba_triggers"
   IF (dsgtv_qry_cnt > 1)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "failed due to the multiple rows are qualified from dba_triggers"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dsgtv_trig_version <= 0)
    SET dsgtv_trig_version = - (1)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsr_chk_sd_in_process(dcsip_db_group,dcsip_owner,dcsip_sd_in_process)
   DECLARE dcsip_get_session_status(session_ident=vc) = i2 WITH sql =
   "CERADM.SD_DDL_MANAGE_PKG.session_is_alive", parameter
   DECLARE dcsip_pvalue_ind = i2 WITH protect, noconstant(0)
   DECLARE dcsip_ret_value = i2 WITH protect, noconstant(0)
   DECLARE dcsip_sessidx = i4 WITH protect, noconstant(0)
   FREE RECORD dcsip_session
   RECORD dcsip_session(
     1 cnt = i4
     1 session[*]
       2 sess_id = vc
   )
   SET dcsip_sd_in_process = 0
   SET stat = alterlist(dcsip_session->session,0)
   SET dcsip_session->cnt = 0
   SET dm_err->eproc = "Checking if schema deployment is actively running"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT DISTINCT INTO "nl:"
    spe.session_ident
    FROM (ceradm.sd_process_event spe)
    WHERE spe.db_group=dcsip_db_group
     AND spe.owner=dcsip_owner
     AND spe.process_name="INSTALLER"
     AND spe.event_name="SCHEMA UPDATE"
     AND spe.status="RUNNING"
    DETAIL
     dcsip_session->cnt = (dcsip_session->cnt+ 1), stat = alterlist(dcsip_session->session,
      dcsip_session->cnt), dcsip_session->session[dcsip_session->cnt].sess_id = spe.session_ident
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dcsip_session->cnt > 0))
    SET dm_err->eproc =
    "Evaluating if there's an override with schema deployment to evaluate only active event sessions."
    SELECT INTO "nl:"
     FROM (ceradm.sd_param sp)
     WHERE sp.pname="PROCESS_EVENT_CHK_ACTIVE_SESSIONS_ONLY"
      AND sp.ptype="CONFIG"
     DETAIL
      IF (sp.pvalue="YES")
       dcsip_pvalue_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) > 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dcsip_pvalue_ind=0)
     SET dcsip_sd_in_process = 1
    ELSE
     SET dm_err->eproc = "Evaluating if session is alive or dead"
     FOR (dcsip_sessidx = 1 TO dcsip_session->cnt)
      SELECT INTO "nl:"
       ret_value_tmp = dcsip_get_session_status(dcsip_session->session[dcsip_sessidx].sess_id)
       FROM dual
       DETAIL
        IF (ret_value_tmp=1)
         dcsip_sd_in_process = 1, dcsip_sessidx = dcsip_session->cnt
        ENDIF
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc) > 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDFOR
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 FREE RECORD td_tables
 RECORD td_tables(
   1 tbl[*]
     2 full_table_name = vc
     2 suff_table_name = vc
     2 table_suffix = c4
 )
 DECLARE td_cnt = i4 WITH protect, noconstant(0)
 FREE RECORD dtl_tmp_tbls
 RECORD dtl_tmp_tbls(
   1 tbl_cnt = i4
   1 tbl[*]
     2 tbl_name = vc
     2 schema_instance = i4
 )
 SET dtl_tmp_tbls->tbl_cnt = 0
 FREE RECORD dtl_obs_obj
 RECORD dtl_obs_obj(
   1 tbl_cnt = i4
   1 tbl[*]
     2 table_name = vc
   1 ind_cnt = i4
   1 ind[*]
     2 index_name = vc
 )
 SET dtl_obs_obj->tbl_cnt = 0
 SET dtl_obs_obj->ind_cnt = 0
 IF ((validate(dtl_user_tables->cnt,- (1))=- (1))
  AND validate(dtl_user_tables->cnt,99)=99)
  FREE RECORD dtl_user_tables
  RECORD dtl_user_tables(
    1 cnt = i4
    1 qual[*]
      2 table_name = vc
  )
  SET dtl_user_tables->cnt = 0
 ENDIF
 FREE RECORD dtl_fk_tbl
 RECORD dtl_fk_tbl(
   1 cnt = i4
   1 list[*]
     2 table_name = vc
 ) WITH protect
 DECLARE dtl_cnt = i4 WITH protect, noconstant(0)
 DECLARE dtl_src_of_data = c1 WITH protect, noconstant(" ")
 DECLARE dtl_admin_load_ind = i4 WITH protect, noconstant(0)
 DECLARE dtl_tbl_idx = i4 WITH protect, noconstant(0)
 DECLARE dtl_dm_info_exists = c1 WITH protect, noconstant("N")
 DECLARE dtl_adm_maint_str = vc WITH protect, noconstant(" ")
 DECLARE dtl_load_from_afd = i2 WITH protect, noconstant(0)
 DECLARE dtl_max_tc_cnt = i4 WITH protect, noconstant(0)
 DECLARE dtl_max_i_cnt = i2 WITH protect, noconstant(0)
 DECLARE dtl_max_ic_cnt = i2 WITH protect, noconstant(0)
 DECLARE dtl_max_c_cnt = i2 WITH protect, noconstant(0)
 DECLARE dtl_max_cc_cnt = i2 WITH protect, noconstant(0)
 DECLARE dtl_schema_loaded = i4 WITH protect, noconstant(0)
 DECLARE dtl_glbl_where_clause = vc WITH protect, noconstant(" ")
 DECLARE dtl_incl_excl_ind = i2 WITH protect, noconstant(0)
 DECLARE dtl_log_file1 = vc WITH protect, noconstant(" ")
 DECLARE dtl_log_file2 = vc WITH protect, noconstant(" ")
 DECLARE dtl_mode = vc WITH protect
 DECLARE dtl_exist_check = c1 WITH protect
 DECLARE dtl_description = vc WITH protect
 DECLARE dtl_obs_obj_idx = i4 WITH protect, noconstant(0)
 DECLARE dtl_obs_obj_idx2 = i4 WITH protect, noconstant(0)
 DECLARE dtl_lp_cnt = i4 WITH protect, noconstant(0)
 DECLARE dtl_lp_cnt2 = i4 WITH protect, noconstant(0)
 DECLARE dtl_index_override_cnt = i4 WITH protect, noconstant(0)
 DECLARE dtl_index_overrides_allowed = i4 WITH protect, noconstant(0)
 DECLARE dtl_optmode = vc WITH protect, noconstant(" ")
 DECLARE dtl_fk_ind = i2 WITH protect, noconstant(0)
 DECLARE dtl_log_file3 = vc WITH protect, noconstant(" ")
 DECLARE dtl_sd_in_use_ind = i2 WITH protect, noconstant(0)
 DECLARE initial_validation(null) = i2
 DECLARE get_header_info(null) = null
 DECLARE load_sq_file_to_tgtsch(null) = null
 DECLARE load_t_td_file_to_tgtsch(null) = null
 DECLARE set_max_schema_instance(null) = null
 DECLARE populate_table(null) = null
 DECLARE populate_tbl_columns(null) = null
 DECLARE populate_tbl_indexes(null) = null
 DECLARE populate_tbl_constraints(null) = null
 DECLARE insert_afd_row_for_table_info(null) = null
 DECLARE delete_insert_table(null) = null
 DECLARE delete_insert_column(null) = null
 DECLARE delete_insert_indexes(null) = null
 DECLARE delete_insert_ind_columns(null) = null
 DECLARE delete_insert_constraints(null) = null
 DECLARE delete_insert_cons_columns(null) = null
 DECLARE load_td_file_to_database(null) = null
 DECLARE load_cd_file_to_database(null) = null
 DECLARE load_tp_file_to_database(null) = null
 DECLARE display_tgt_rec_struct(null) = null
 DECLARE load_obsolete_objects(null) = i2
 DECLARE dtl_override_index_types(null) = i2
 DECLARE dtl_get_optimizer_mode(null) = vc
 DECLARE dtl_include_exclude_list() = vc
 DECLARE dtl_load_user_tables(null) = i2
 DECLARE check_whether_to_load_afd(null) = i2
 DECLARE check_whether_to_load_admin_to_afd(null) = i2
 DECLARE load_t_initial_to_tgtsch(null) = null
 DECLARE dtl_load_user_info(null) = i2
 DECLARE dtl_populate_tbl_part_objs(null) = i2
 IF (check_logfile("dm2_trn_load",".log","DM2_TRANSLATE_LOAD")=0)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Entering Target Record Structure Translate and Load Process...."
 CALL disp_msg(" ",dm_err->logfile,0)
 IF ((tgtsch->tbl_cnt > 0))
  SET dm_err->eproc = "Initializing target record structure...."
  CALL disp_msg(" ",dm_err->logfile,0)
  FOR (dtl_lp_cnt = 1 TO tgtsch->tbl_cnt)
    SET stat = alterlist(tgtsch->tbl[dtl_lp_cnt].tbl_col,0)
    SET tgtsch->tbl[dtl_lp_cnt].tbl_col_cnt = 0
    FOR (dtl_lp_cnt2 = 1 TO tgtsch->tbl[dtl_lp_cnt].ind_cnt)
      SET stat = alterlist(tgtsch->tbl[dtl_lp_cnt].ind[dtl_lp_cnt2].ind_col,0)
      SET tgtsch->tbl[dtl_lp_cnt].ind[dtl_lp_cnt2].ind_col_cnt = 0
      SET stat = alterlist(tgtsch->tbl[dtl_lp_cnt].ind[dtl_lp_cnt2].part_col,0)
      SET tgtsch->tbl[dtl_lp_cnt].ind[dtl_lp_cnt2].part_col_cnt = 0
      SET stat = alterlist(tgtsch->tbl[dtl_lp_cnt].ind[dtl_lp_cnt2].part_tsp,0)
      SET tgtsch->tbl[dtl_lp_cnt].ind[dtl_lp_cnt2].part_tsp_cnt = 0
      SET stat = alterlist(tgtsch->tbl[dtl_lp_cnt].ind[dtl_lp_cnt2].subpart_tsp,0)
      SET tgtsch->tbl[dtl_lp_cnt].ind[dtl_lp_cnt2].subpart_tsp_cnt = 0
      SET stat = alterlist(tgtsch->tbl[dtl_lp_cnt].ind[dtl_lp_cnt2].part,0)
      SET tgtsch->tbl[dtl_lp_cnt].ind[dtl_lp_cnt2].part_cnt = 0
    ENDFOR
    SET stat = alterlist(tgtsch->tbl[dtl_lp_cnt].ind,0)
    SET tgtsch->tbl[dtl_lp_cnt].ind_cnt = 0
    FOR (dtl_lp_cnt2 = 1 TO tgtsch->tbl[dtl_lp_cnt].cons_cnt)
     SET stat = alterlist(tgtsch->tbl[dtl_lp_cnt].cons[dtl_lp_cnt2].cons_col,0)
     SET tgtsch->tbl[dtl_lp_cnt].cons[dtl_lp_cnt2].cons_col_cnt = 0
    ENDFOR
    SET stat = alterlist(tgtsch->tbl[dtl_lp_cnt].part_col,0)
    SET tgtsch->tbl[dtl_lp_cnt].part_col_cnt = 0
    SET stat = alterlist(tgtsch->tbl[dtl_lp_cnt].subpart_col,0)
    SET tgtsch->tbl[dtl_lp_cnt].subpart_col_cnt = 0
    SET stat = alterlist(tgtsch->tbl[dtl_lp_cnt].part_tsp,0)
    SET tgtsch->tbl[dtl_lp_cnt].part_tsp_cnt = 0
    SET stat = alterlist(tgtsch->tbl[dtl_lp_cnt].subpart_tsp,0)
    SET tgtsch->tbl[dtl_lp_cnt].subpart_tsp_cnt = 0
    SET stat = alterlist(tgtsch->tbl[dtl_lp_cnt].ind_rebuild,0)
    SET tgtsch->tbl[dtl_lp_cnt].ind_rebuild_cnt = 0
    SET stat = alterlist(tgtsch->tbl[dtl_lp_cnt].part,0)
    SET tgtsch->tbl[dtl_lp_cnt].part_cnt = 0
    SET stat = alterlist(tgtsch->tbl[dtl_lp_cnt].cons,0)
    SET tgtsch->tbl[dtl_lp_cnt].cons_cnt = 0
  ENDFOR
  SET stat = alterlist(tgtsch->tbl,0)
  SET tgtsch->tbl_cnt = 0
 ENDIF
 IF ((tgtsch->backfill_ops_cnt > 0))
  FOR (dtl_lp_cnt = 1 TO tgtsch->backfill_ops_cnt)
   SET tgtsch->backfill_ops[dtl_lp_cnt].col_cnt = 0
   SET stat = alterlist(tgtsch->backfill_ops[dtl_lp_cnt].col,tgtsch->backfill_ops[dtl_lp_cnt].col_cnt
    )
  ENDFOR
  SET tgtsch->backfill_ops_cnt = 0
  SET stat = alterlist(tgtsch->backfill_ops,tgtsch->backfill_ops_cnt)
 ENDIF
 IF (initial_validation(null)=0)
  GO TO exit_program
 ENDIF
 IF (dtl_admin_load_ind=1)
  CALL load_td_file_to_database(null)
  IF ((dm_err->err_ind=1))
   GO TO exit_program
  ENDIF
 ENDIF
 IF (cnvtupper(currdbuser) != "CDBA")
  CALL load_t_td_file_to_tgtsch(null)
  IF ((dm_err->err_ind=1))
   GO TO exit_program
  ENDIF
 ENDIF
 IF (dtl_mode="PKGINSTALL")
  SET dtl_src_of_data = "A"
 ELSE
  SET dtl_src_of_data = "S"
 ENDIF
 IF ((dm2_install_schema->process_option="INHOUSE"))
  SET dm_err->eproc = "Check to see if generic FK bypass is enabled"
  CALL disp_msg(" ",dm_err->logfile,0)
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="DATA MANAGEMENT"
    AND di.info_name="BYPASS FK ENABLE"
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   GO TO exit_program
  ENDIF
  IF (curqual > 0)
   SET dtl_fk_ind = 1
  ENDIF
  IF (dtl_fk_ind=0)
   SET dm_err->eproc = "Check to see if table specific FK bypass is enabled"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT FK BYPASS"
    HEAD REPORT
     dtl_fk_tbl->cnt = 0
    DETAIL
     dtl_fk_tbl->cnt = (dtl_fk_tbl->cnt+ 1), stat = alterlist(dtl_fk_tbl->list,dtl_fk_tbl->cnt),
     dtl_fk_tbl->list[dtl_fk_tbl->cnt].table_name = di.info_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    GO TO exit_program
   ENDIF
  ENDIF
 ENDIF
 IF (cnvtupper(currdbuser) != "CDBA")
  CALL populate_tbl_columns(null)
  IF ((dm_err->err_ind=1))
   GO TO exit_program
  ENDIF
  CALL populate_tbl_indexes(null)
  IF ((dm_err->err_ind=1))
   GO TO exit_program
  ENDIF
  CALL populate_tbl_constraints(null)
  IF ((dm_err->err_ind=1))
   GO TO exit_program
  ENDIF
  IF (dtl_mode="PKGINSTALL")
   IF (dtl_populate_tbl_part_objs(null)=0)
    GO TO exit_program
   ENDIF
  ENDIF
 ENDIF
 IF (cnvtupper(currdbuser)="CDBA")
  CALL check_whether_to_load_admin_to_afd(null)
  IF ((dm_err->err_ind=1))
   GO TO exit_program
  ENDIF
  IF (dtl_schema_loaded=0)
   EXECUTE dm2_load_afd_content tgtsch->alpha_feature_nbr, dm2_install_schema->schema_loc,
   dm2_sch_file->file_prefix
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
  ENDIF
  CALL load_t_initial_to_tgtsch(null)
  IF ((dm_err->err_ind=1))
   GO TO exit_program
  ENDIF
 ELSEIF (dtl_admin_load_ind=1)
  CALL check_whether_to_load_afd(null)
  IF ((dm_err->err_ind=1))
   GO TO exit_program
  ENDIF
  IF (dtl_schema_loaded=0)
   CALL insert_afd_row_for_table_info(null)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
  ENDIF
 ENDIF
 IF (dtl_dm_info_exists="F"
  AND dtl_mode != "LOAD")
  IF ((dm2_install_schema->process_option != "INHOUSE")
   AND (drr_clin_copy_data->process != "MIGRATION"))
   CALL set_max_schema_instance(null)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
  ENDIF
  IF (((dtl_load_from_afd=1) OR (cnvtupper(currdbuser)="CDBA")) )
   SET dtl_src_of_data = "A"
   IF (dm2_set_autocommit(1)=0)
    GO TO exit_program
   ENDIF
   IF (dtl_load_from_afd=1)
    CALL populate_table(null)
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
   ENDIF
   CALL populate_tbl_columns(null)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL populate_tbl_indexes(null)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   CALL populate_tbl_constraints(null)
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
   IF (dtl_mode="PKGINSTALL")
    IF (dtl_populate_tbl_part_objs(null)=0)
     GO TO exit_program
    ENDIF
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    GO TO exit_program
   ENDIF
  ELSE
   SET dm_err->eproc = "Schema files contain the best schema - schema load complete!."
   CALL disp_msg(" ",dm_err->logfile,0)
  ENDIF
  SET dtl_optmode = dtl_get_optimizer_mode(null)
  IF ((dm_err->debug_flag > 0))
   SET dm_err->eproc = concat("* Optimizer Mode = (",dtl_optmode,")")
   CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
  ENDIF
  IF (dtl_optmode IN ("RULE", "DM2SUBERROR"))
   SET dtl_index_overrides_allowed = 0
  ELSE
   SET dtl_index_overrides_allowed = 1
  ENDIF
  IF (dtl_index_overrides_allowed=1)
   SET dtl_index_override_cnt = dm2it_load_index_types(null)
   IF (dtl_index_override_cnt > 0)
    IF (dtl_override_index_types(null)=0)
     GO TO exit_program
    ENDIF
   ELSEIF (dtl_index_override_cnt=0)
    SET dm_err->eproc = "* No index type overrides found! "
    CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
   ELSE
    GO TO exit_program
   ENDIF
  ELSE
   SET dm_err->eproc = "* Index type overrides not allowed - override logic bypassed. "
   CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
  ENDIF
 ENDIF
 IF (dtl_admin_load_ind=1)
  CALL load_cd_file_to_database(null)
  IF ((dm_err->err_ind=1))
   GO TO exit_program
  ENDIF
  CALL load_tp_file_to_database(null)
  IF ((dm_err->err_ind=1))
   GO TO exit_program
  ENDIF
 ENDIF
 IF (dtl_mode="PKGINSTALL"
  AND (dm2_sys_misc->cur_db_os != "AXP"))
  IF (validate(dm2_bypass_db_user_installation,- (1))=1)
   SET dm_err->eproc = "Bypassing Database user installation - external flag set"
   CALL disp_msg(" ",dm_err->logfile,0)
  ELSE
   IF (dtl_load_user_info(null)=0)
    GO TO exit_program
   ENDIF
  ENDIF
 ENDIF
 GO TO exit_program
 SUBROUTINE initial_validation(null)
   DECLARE iv_header_file_name = vc WITH protect, noconstant(" ")
   SET dm_err->eproc = "Performing Initial Validation for Translate/Load Process"
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dtl_mode =  $1
   IF ( NOT (dtl_mode IN ("NORMAL", "PKGINSTALL", "LOAD")))
    SET dm_err->err_ind = 1
    SET dm_err->emsg =
    "Invalid execution mode, the valid mode should be 'NORMAL', 'PKGINSTALL',or 'LOAD'"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dtl_exist_check = " "
   IF (currdb="ORACLE"
    AND dtl_mode != "LOAD"
    AND  NOT ((dm2_install_schema->process_option IN ("DDL GEN", "INHOUSE"))))
    SET dm_err->eproc = "CHecking for existence of DM_CB_OBJECTS table"
    SET dtl_exist_check = dm2_table_exists("DM_CB_OBJECTS")
    IF (dtl_exist_check="E")
     RETURN(0)
    ENDIF
    IF (dtl_exist_check="F")
     IF (load_obsolete_objects(null)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF (dtl_mode="PKGINSTALL")
    IF (dsr_sd_in_use_check("DM2NOTSET",dtl_sd_in_use_ind)=0)
     RETURN(0)
    ENDIF
    IF (dtl_sd_in_use_ind=1)
     IF (dsr_usage_prep("DM2NOTSET")=0)
      RETURN(0)
     ENDIF
    ENDIF
    SET dtl_admin_load_ind = 0
    SET dm2_install_pkg->source_rdbms = "ORACLE"
    SET tgtsch->source_rdbms = dm2_install_pkg->source_rdbms
    SET tgtsch->alpha_feature_nbr = cnvtint(dm2_install_schema->file_prefix)
    IF ((dm2_install_pkg->process_option="BATCHPKG"))
     SET dm2_install_pkg->description = concat("Installing batch package ",dm2_install_schema->
      file_prefix," with ",cnvtstring(dm2_install_pkg->num_of_pkgs)," single packages")
     SET dtl_description = dm2_install_pkg->description
    ELSE
     SET dtl_description = dm2_install_pkg->description
    ENDIF
   ELSE
    IF ((dm2_install_schema->process_option="INHOUSE"))
     SET dm2_install_schema->schema_prefix = "dm2c"
     SET tgtsch->schema_date = cnvtdate(cnvtint(build(substring(1,8,dm2_install_schema->file_prefix))
       ))
     SET dm2_sch_file->file_prefix = build(dm2_install_schema->schema_prefix,dm2_install_schema->
      file_prefix)
     SET dtl_admin_load_ind = 0
     SET tgtsch->source_rdbms = "ORACLE"
     SET dtl_description = dm2_install_schema->process_option
    ELSE
     IF ((dm2_install_schema->schema_prefix="dm2o"))
      SET tgtsch->alpha_feature_nbr = cnvtint(build(substring(1,6,dm2_install_schema->file_prefix)))
     ELSEIF ((dm2_install_schema->schema_prefix IN ("dm2a", "dm2c", "dm2s")))
      SET tgtsch->schema_date = cnvtdate(cnvtint(build(substring(1,8,dm2_install_schema->file_prefix)
         )))
      IF ((dm2_install_schema->schema_prefix="dm2a"))
       SET tgtsch->alpha_feature_nbr = - ((1 * cnvtint(format(cnvtdate2(dm2_install_schema->
          file_prefix,"MMDDYYYY"),"YYYYMMDD;;D"))))
      ENDIF
     ENDIF
     SET dm2_sch_file->dest_dir_cclfmt = dm2_install_schema->schema_loc
     IF ((dm2_install_schema->process_option="DDL GEN"))
      SET dm2_sch_file->file_prefix = dm2_install_schema->file_prefix
     ELSE
      SET dm2_sch_file->file_prefix = build(dm2_install_schema->schema_prefix,dm2_install_schema->
       file_prefix)
     ENDIF
     IF ((dm2_install_schema->schema_prefix="dm2a"))
      SET iv_header_file_name = build(dm2_install_schema->cer_install,dm2_sch_file->file_prefix,
       dcfr_csv_file->qual[1].file_suffix,".csv")
      IF (dcfr_get_header_info(iv_header_file_name)=0)
       RETURN(0)
      ENDIF
      SET dtl_admin_load_ind = dcfr_csv_header_info->admin_load_ind
      SET tgtsch->source_rdbms = dcfr_csv_header_info->source_rdbms
      SET dtl_description = dcfr_csv_header_info->desc
     ELSE
      SET dm_err->eproc = "Open Schema Files"
      CALL disp_msg(" ",dm_err->logfile,0)
      IF (open_sch_files(0)=0)
       RETURN(0)
      ENDIF
      CALL get_header_info(null)
      IF ((dm_err->err_ind=1))
       RETURN(0)
      ENDIF
     ENDIF
     IF (trim(dm2_install_pkg->source_rdbms)="")
      SET dm2_install_pkg->description = dtl_description
      SET dm2_install_pkg->source_rdbms = tgtsch->source_rdbms
      SET dm2_install_pkg->admin_load_ind = dtl_admin_load_ind
     ELSE
      IF ((((dm2_install_pkg->source_rdbms != tgtsch->source_rdbms)) OR ((dm2_install_pkg->
      admin_load_ind != dtl_admin_load_ind))) )
       SET dm_err->err_ind = 1
       SET dm_err->emsg = "Data in DMS_INSTALL_PKG not match those in DMHEADER"
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF ((dm2_install_schema->process_option != "DDL GEN")
    AND (drr_clin_copy_data->process != "RESTORE"))
    SET dm_err->eproc = "Determine if DM_INFO exists"
    SET dtl_dm_info_exists = dm2_table_exists("DM_INFO")
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   IF ( NOT (dtl_admin_load_ind IN (0, 1)))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Admin Load Indicator in Header Schema File Invalid"
    SET dm_err->eproc = "Validating Schema Header Information"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (dtl_admin_load_ind=1
    AND (dm2_install_schema->schema_prefix="dm2a"))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Admin Load Indicator in Header Schema File Invalid"
    SET dm_err->eproc = "Validating Schema Header Information for Admin Schema"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ( NOT ((tgtsch->source_rdbms IN ("ORACLE"))))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Source RDBMS in Header Schema File Invalid"
    SET dm_err->eproc = "Validating Schema Header Information"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (dtl_admin_load_ind=1)
    SELECT INTO "nl:"
     td.table_name
     FROM dmtbldoc td
     WITH nocounter, maxqual(td,1)
    ;end select
    IF (check_error("Validating Tables Doc Schema File Information")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     IF (curqual=0)
      SET dm_err->err_ind = 1
      SET dm_err->eproc = "Validating Tables Doc Schema File Information"
      SET dm_err->emsg = "No data qualified/selected"
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     cd.table_name
     FROM dmcoldoc cd
     WITH nocounter, maxqual(cd,1)
    ;end select
    IF (check_error("Validating Columns Doc Schema File Information")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     IF (curqual=0)
      SET dm_err->err_ind = 1
      SET dm_err->eproc = "Validating Columns Doc Schema File Information"
      SET dm_err->emsg = "No data qualified/selected"
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     tp.table_name
     FROM dmtsprec tp
     WITH nocounter, maxqual(tp,1)
    ;end select
    IF (check_error("Validating Tablespace Precedence Schema File Information")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     IF (curqual=0)
      SET dm_err->err_ind = 1
      SET dm_err->eproc = "Validating Tablespace Precedence Schema File Information"
      SET dm_err->emsg = "No data qualified/selected"
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF (dtl_dm_info_exists="F"
    AND cnvtupper(currdbuser)="V500")
    SET dtl_glbl_where_clause = dtl_include_exclude_list(null)
    IF (dtl_glbl_where_clause="ERROR")
     RETURN(0)
    ELSEIF (dtl_glbl_where_clause="NONE")
     SET dtl_glbl_where_clause = "1 = 1"
     SET dtl_incl_excl_ind = 0
    ELSE
     SET dtl_incl_excl_ind = 1
    ENDIF
   ELSE
    SET dtl_glbl_where_clause = "1 = 1"
    SET dtl_incl_excl_ind = 0
   ENDIF
   IF (validate(dm2_db_options->load_ind,0)=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Confirming database options."
    SET dm_err->emsg = "Database options have not been determined"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (dtl_mode IN ("PKGINSTALL", "NORMAL")
    AND build(currdbuser) != "CDBA"
    AND build(currdb)="ORACLE"
    AND dtl_dm_info_exists="F")
    IF (dir_get_obsolete_objects(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dm2_get_rdbms_version(null)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE get_header_info(null)
   SET dm_err->eproc = "Retrieving Schema Header Information"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    h.admin_load_ind, h.source_rdbms
    FROM dmheader h
    DETAIL
     dtl_admin_load_ind = h.admin_load_ind, tgtsch->source_rdbms = h.source_rdbms, dtl_description =
     h.description
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ELSE
    IF (curqual=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "No data qualified/selected"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE load_sq_file_to_tgtsch(null)
   SET dm_err->eproc = "Retrieving and Loading Sequence Information"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    sq.sequence_name
    FROM dmseq sq
    HEAD REPORT
     stat = alterlist(tgtsch->sequence,10), tgtsch->sequence_cnt = 0
    DETAIL
     tgtsch->sequence_cnt = (tgtsch->sequence_cnt+ 1)
     IF (mod(tgtsch->sequence_cnt,10)=1
      AND (tgtsch->sequence_cnt != 1))
      stat = alterlist(tgtsch->sequence,(tgtsch->sequence_cnt+ 9))
     ENDIF
     tgtsch->sequence[tgtsch->sequence_cnt].seq_name = sq.sequence_name, tgtsch->sequence[tgtsch->
     sequence_cnt].min_val = sq.min_value, tgtsch->sequence[tgtsch->sequence_cnt].max_val = sq
     .max_value,
     tgtsch->sequence[tgtsch->sequence_cnt].cycle_flag = sq.cycle_flag, tgtsch->sequence[tgtsch->
     sequence_cnt].increment_by = sq.increment_by, tgtsch->sequence[tgtsch->sequence_cnt].last_number
      = sq.last_number
    FOOT REPORT
     stat = alterlist(tgtsch->sequence,tgtsch->sequence_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
 END ;Subroutine
 SUBROUTINE load_t_td_file_to_tgtsch(null)
   FREE RECORD child_tables
   RECORD child_tables(
     1 tbl_cnt = i4
     1 tbl[*]
       2 tbl_name = vc
       2 pct_increase = f8
       2 pct_used = f8
       2 pct_free = f8
       2 schema_instance = i4
       2 alpha_feature_nbr = i4
       2 feature_number = i4
       2 updt_dt_tm = dq8
       2 table_suffix = vc
   )
   SET child_tables->tbl_cnt = 0
   FREE RECORD ltt_table_inst
   RECORD ltt_table_inst(
     1 tbl_cnt = i4
     1 tbl[*]
       2 table_name = vc
       2 schema_instance = i4
   )
   SET ltt_table_inst->tbl_cnt = 0
   FREE RECORD ltt_table_list
   RECORD ltt_table_list(
     1 tbl_cnt = i4
     1 tbl[*]
       2 owner = vc
       2 tbl_name = vc
       2 alpha_feature_nbr = i4
       2 feature_number = i4
       2 schema_instance = i4
       2 updt_dt_tm = f8
       2 pct_increase = f8
       2 pct_used = f8
       2 pct_free = f8
   )
   SET ltt_table_list->tbl_cnt = 0
   FREE RECORD td_tables
   RECORD td_tables(
     1 tbl[*]
       2 table_name = vc
       2 table_suffix = c4
   )
   DECLARE td_cnt = i4 WITH protect, noconstant(0)
   DECLARE td_idx = i4 WITH protect, noconstant(0)
   IF ((drr_clin_copy_data->process="RESTORE"))
    IF (dtl_load_user_tables(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dtl_mode="PKGINSTALL")
    SET dm_err->eproc = "Loading DM_TABLES_DOC into memory..."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     td.table_name
     FROM dm_tables_doc td
     WHERE td.table_name=td.full_table_name
     HEAD REPORT
      stat = alterlist(td_tables->tbl,10), td_cnt = 0
     DETAIL
      td_cnt = (td_cnt+ 1)
      IF (mod(td_cnt,10)=1
       AND td_cnt != 1)
       stat = alterlist(td_tables->tbl,(td_cnt+ 9))
      ENDIF
      td_tables->tbl[td_cnt].table_name = td.table_name, td_tables->tbl[td_cnt].table_suffix = td
      .table_suffix
     FOOT REPORT
      stat = alterlist(td_tables->tbl,td_cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) > 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Load schema instance rows to record."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT
     IF (dtl_sd_in_use_ind=0)
      table_name = di.info_name, version = di.info_number
      FROM dm_info di
      WHERE di.info_domain="DM2_SCHEMA_INSTANCE"
      ORDER BY di.info_name, di.info_number
     ELSE
      table_name = stv.table_name, version = stv.version_nbr
      FROM (ceradm.sd_table_version_v stv)
      WHERE stv.owner=currdbuser
      ORDER BY stv.table_name, stv.version_nbr
     ENDIF
     INTO "nl:"
     HEAD REPORT
      stat = alterlist(ltt_table_inst->tbl,100), ltt_table_inst->tbl_cnt = 0
     HEAD table_name
      ltt_table_inst->tbl_cnt = (ltt_table_inst->tbl_cnt+ 1)
      IF (mod(ltt_table_inst->tbl_cnt,100)=1
       AND (ltt_table_inst->tbl_cnt != 1))
       stat = alterlist(ltt_table_inst->tbl,(ltt_table_inst->tbl_cnt+ 99))
      ENDIF
      ltt_table_inst->tbl[ltt_table_inst->tbl_cnt].table_name = trim(table_name), ltt_table_inst->
      tbl[ltt_table_inst->tbl_cnt].schema_instance = version
     FOOT REPORT
      stat = alterlist(ltt_table_inst->tbl,ltt_table_inst->tbl_cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) > 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Load list of tables from dm_afd_tables."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     t.table_name, t.alpha_feature_nbr, t.schema_instance
     FROM dm_afd_tables t,
      dm_alpha_features daf
     WHERE daf.alpha_feature_nbr > 0
      AND daf.owner=currdbuser
      AND daf.alpha_feature_nbr=t.alpha_feature_nbr
      AND daf.owner=t.owner
      AND  NOT (t.table_name IN (
     (SELECT
      afd.table_name
      FROM dm_afd_tables afd
      WHERE (afd.alpha_feature_nbr=tgtsch->alpha_feature_nbr)
       AND afd.owner=currdbuser)))
     ORDER BY t.table_name, t.schema_instance DESC
     HEAD REPORT
      stat = alterlist(ltt_table_list->tbl,100), ltt_table_list->tbl_cnt = 0, tbl_idx = 0
     DETAIL
      tbl_idx = 0, tbl_idx = locateval(tbl_idx,1,ltt_table_inst->tbl_cnt,t.table_name,ltt_table_inst
       ->tbl[tbl_idx].table_name,
       t.schema_instance,ltt_table_inst->tbl[tbl_idx].schema_instance)
      IF (tbl_idx > 0)
       ltt_table_list->tbl_cnt = (ltt_table_list->tbl_cnt+ 1)
       IF (mod(ltt_table_list->tbl_cnt,100)=1
        AND (ltt_table_list->tbl_cnt != 1))
        stat = alterlist(ltt_table_list->tbl,(ltt_table_list->tbl_cnt+ 99))
       ENDIF
       ltt_table_list->tbl[ltt_table_list->tbl_cnt].owner = t.owner, ltt_table_list->tbl[
       ltt_table_list->tbl_cnt].tbl_name = t.table_name, ltt_table_list->tbl[ltt_table_list->tbl_cnt]
       .schema_instance = t.schema_instance,
       ltt_table_list->tbl[ltt_table_list->tbl_cnt].alpha_feature_nbr = t.alpha_feature_nbr,
       ltt_table_list->tbl[ltt_table_list->tbl_cnt].feature_number = t.feature_number, ltt_table_list
       ->tbl[ltt_table_list->tbl_cnt].updt_dt_tm = t.updt_dt_tm,
       ltt_table_list->tbl[ltt_table_list->tbl_cnt].pct_increase = t.pct_increase, ltt_table_list->
       tbl[ltt_table_list->tbl_cnt].pct_used = t.pct_used, ltt_table_list->tbl[ltt_table_list->
       tbl_cnt].pct_free = t.pct_free
      ENDIF
     FOOT REPORT
      stat = alterlist(ltt_table_list->tbl,ltt_table_list->tbl_cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) > 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Load all child tables associated with parent tables in the batch."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (dummyt t  WITH seq = value(ltt_table_list->tbl_cnt)),
      dm_afd_constraints c1,
      dm_afd_constraints c2
     PLAN (t)
      JOIN (c1
      WHERE (ltt_table_list->tbl[t.seq].owner=c1.owner)
       AND (ltt_table_list->tbl[t.seq].tbl_name=c1.table_name)
       AND (ltt_table_list->tbl[t.seq].alpha_feature_nbr=c1.alpha_feature_nbr)
       AND c1.constraint_type="R")
      JOIN (c2
      WHERE c2.owner=c1.owner
       AND c2.table_name=c1.parent_table_name
       AND c2.constraint_name=c1.r_constraint_name
       AND (c2.alpha_feature_nbr=tgtsch->alpha_feature_nbr))
     ORDER BY c1.table_name, ltt_table_list->tbl[t.seq].schema_instance DESC
     HEAD REPORT
      stat = alterlist(child_tables->tbl,100), child_tables->tbl_cnt = 0
     HEAD c1.table_name
      dtl_obs_obj_idx = 0
      IF ((dtl_obs_obj->tbl_cnt > 0))
       dtl_obs_obj_idx = locateval(dtl_obs_obj_idx,1,dtl_obs_obj->tbl_cnt,c1.table_name,dtl_obs_obj->
        tbl[dtl_obs_obj_idx].table_name)
      ENDIF
      dtl_obs_obj_idx2 = 0
      IF ((dir_obsolete_objects->tbl_cnt > 0)
       AND dtl_obs_obj_idx=0)
       dtl_obs_obj_idx2 = locateval(dtl_obs_obj_idx2,1,dir_obsolete_objects->tbl_cnt,c1.table_name,
        dir_obsolete_objects->tbl[dtl_obs_obj_idx2].table_name)
      ENDIF
      td_idx = 0
      IF (td_cnt > 0)
       td_idx = locateval(td_idx,1,td_cnt,c1.table_name,td_tables->tbl[td_idx].table_name)
      ENDIF
      IF (dtl_obs_obj_idx=0
       AND dtl_obs_obj_idx2=0
       AND td_idx > 0)
       child_tables->tbl_cnt = (child_tables->tbl_cnt+ 1)
       IF (mod(child_tables->tbl_cnt,100)=1
        AND (child_tables->tbl_cnt != 1))
        stat = alterlist(child_tables->tbl,(child_tables->tbl_cnt+ 99))
       ENDIF
       child_tables->tbl[child_tables->tbl_cnt].tbl_name = ltt_table_list->tbl[t.seq].tbl_name,
       child_tables->tbl[child_tables->tbl_cnt].schema_instance = ltt_table_list->tbl[t.seq].
       schema_instance, child_tables->tbl[child_tables->tbl_cnt].alpha_feature_nbr = ltt_table_list->
       tbl[t.seq].alpha_feature_nbr,
       child_tables->tbl[child_tables->tbl_cnt].feature_number = ltt_table_list->tbl[t.seq].
       feature_number, child_tables->tbl[child_tables->tbl_cnt].updt_dt_tm = ltt_table_list->tbl[t
       .seq].updt_dt_tm, child_tables->tbl[child_tables->tbl_cnt].table_suffix = td_tables->tbl[
       td_idx].table_suffix,
       child_tables->tbl[child_tables->tbl_cnt].pct_increase = ltt_table_list->tbl[t.seq].
       pct_increase, child_tables->tbl[child_tables->tbl_cnt].pct_used = ltt_table_list->tbl[t.seq].
       pct_used, child_tables->tbl[child_tables->tbl_cnt].pct_free = ltt_table_list->tbl[t.seq].
       pct_free
      ENDIF
     FOOT REPORT
      stat = alterlist(child_tables->tbl,child_tables->tbl_cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) > 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 2))
     CALL echorecord(child_tables)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Performing Retrieval & Load of Table Information"
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE t_lngth = i4 WITH protect, noconstant(0)
   CALL echo(build("pkg=",tgtsch->alpha_feature_nbr))
   SELECT
    IF (((cnvtupper(currdbuser)="CDBA") OR ((dm2_install_schema->process_option="DDL GEN"))) )
     FROM dmtable t
    ELSEIF (dtl_mode="PKGINSTALL")
     FROM dm_afd_tables t,
      dm_tables_doc td
     PLAN (t
      WHERE (t.alpha_feature_nbr=tgtsch->alpha_feature_nbr)
       AND t.owner=currdbuser)
      JOIN (td
      WHERE t.table_name=td.table_name)
     ORDER BY t.table_name
    ELSEIF ((dm2_install_schema->process_option="INHOUSE"))
     FROM dm_adm_tables t,
      dm_tables_doc td
     PLAN (t
      WHERE t.schema_date=cnvtdatetime(inhouse_reply->schema_date)
       AND (t.table_name=inhouse_reply->table_name)
       AND t.owner=currdbuser)
      JOIN (td
      WHERE t.table_name=td.table_name)
     ORDER BY t.table_name
    ELSE
     FROM dmtable t,
      dm_tables_doc td
     PLAN (t)
      JOIN (td
      WHERE t.table_name=td.table_name
       AND parser(dtl_glbl_where_clause))
    ENDIF
    INTO "nl:"
    HEAD REPORT
     MACRO (convert_table_name)
      IF ((tgtsch->source_rdbms=cnvtupper(currdb)))
       tgtsch->tbl[tgtsch->tbl_cnt].tbl_name = t.table_name
      ELSEIF ((tgtsch->source_rdbms="ORACLE"))
       tgtsch->tbl[tgtsch->tbl_cnt].tbl_name = validate(td.suffixed_table_name," ")
      ELSE
       tgtsch->tbl[tgtsch->tbl_cnt].tbl_name = validate(td.full_table_name," ")
      ENDIF
     ENDMACRO
     , stat = alterlist(tgtsch->tbl,10), tgtsch->tbl_cnt = 0,
     preserve_tbl = 1, pres_tbl_cnt = 0, tbl_ndx = 0,
     noload = 0, instance_idx = 0, restore_t = 0,
     child_tbl_cnt = 0, child_tbl = 1, ctbl_idx = 0
    DETAIL
     noload = 0
     IF (dtl_mode="PKGINSTALL")
      FOR (child_tbl_cnt = child_tbl TO child_tables->tbl_cnt)
        IF ((child_tables->tbl[child_tbl_cnt].tbl_name <= t.table_name))
         IF ((child_tables->tbl[child_tbl_cnt].tbl_name < t.table_name)
          AND locateval(ctbl_idx,1,tgtsch->tbl_cnt,child_tables->tbl[child_tbl_cnt].tbl_name,tgtsch->
          tbl[ctbl_idx].orig_tbl_name)=0)
          tgtsch->tbl_cnt = (tgtsch->tbl_cnt+ 1)
          IF (mod(tgtsch->tbl_cnt,10)=1
           AND (tgtsch->tbl_cnt != 1))
           stat = alterlist(tgtsch->tbl,(tgtsch->tbl_cnt+ 9))
          ENDIF
          tgtsch->tbl[tgtsch->tbl_cnt].tbl_name = child_tables->tbl[child_tbl_cnt].tbl_name, tgtsch->
          tbl[tgtsch->tbl_cnt].orig_tbl_name = child_tables->tbl[child_tbl_cnt].tbl_name, tgtsch->
          tbl[tgtsch->tbl_cnt].child_tbl_ind = 1,
          tgtsch->tbl[tgtsch->tbl_cnt].pct_increase = child_tables->tbl[child_tbl_cnt].pct_increase,
          tgtsch->tbl[tgtsch->tbl_cnt].pct_used = child_tables->tbl[child_tbl_cnt].pct_used, tgtsch->
          tbl[tgtsch->tbl_cnt].pct_free = child_tables->tbl[child_tbl_cnt].pct_free,
          tgtsch->tbl[tgtsch->tbl_cnt].schema_instance = child_tables->tbl[child_tbl_cnt].
          schema_instance, tgtsch->tbl[tgtsch->tbl_cnt].alpha_feature_nbr = child_tables->tbl[
          child_tbl_cnt].alpha_feature_nbr, tgtsch->tbl[tgtsch->tbl_cnt].feature_number =
          child_tables->tbl[child_tbl_cnt].feature_number,
          tgtsch->tbl[tgtsch->tbl_cnt].updt_dt_tm = child_tables->tbl[child_tbl_cnt].updt_dt_tm,
          tgtsch->tbl[tgtsch->tbl_cnt].table_suffix = child_tables->tbl[child_tbl_cnt].table_suffix,
          tgtsch->tbl[tgtsch->tbl_cnt].metadata_loc_flg = 1,
          tgtsch->tbl[tgtsch->tbl_cnt].pull_from_afd = 1
          IF ((dm_err->debug_flag > 2))
           CALL echo(build("Add Child table <",child_tables->tbl[child_tbl_cnt].tbl_name,
            "> to tgtsch with seq <",tgtsch->tbl_cnt,">."))
          ENDIF
         ENDIF
         child_tbl = (child_tbl+ 1)
        ELSE
         child_tbl_cnt = (child_tables->tbl_cnt+ 1)
        ENDIF
      ENDFOR
     ENDIF
     dtl_obs_obj_idx = 0
     IF ((dtl_obs_obj->tbl_cnt > 0))
      dtl_obs_obj_idx = locateval(dtl_obs_obj_idx,1,dtl_obs_obj->tbl_cnt,t.table_name,dtl_obs_obj->
       tbl[dtl_obs_obj_idx].table_name)
     ENDIF
     dtl_obs_obj_idx2 = 0
     IF ((dir_obsolete_objects->tbl_cnt > 0)
      AND dtl_obs_obj_idx=0)
      dtl_obs_obj_idx2 = locateval(dtl_obs_obj_idx2,1,dir_obsolete_objects->tbl_cnt,t.table_name,
       dir_obsolete_objects->tbl[dtl_obs_obj_idx2].table_name)
     ENDIF
     IF (dtl_obs_obj_idx > 0)
      IF ((dm_err->debug_flag > 0))
       CALL echo(build("Conditional Build (table dropped):",t.table_name))
      ENDIF
     ELSEIF (dtl_obs_obj_idx2 > 0)
      dir_dropped_objects->rpt_drp_obj_ind = 1, dir_dropped_objects->obj_cnt = (dir_dropped_objects->
      obj_cnt+ 1), stat = alterlist(dir_dropped_objects->obj,dir_dropped_objects->obj_cnt),
      dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].table_name = t.table_name,
      dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].name = t.table_name, dir_dropped_objects
      ->obj[dir_dropped_objects->obj_cnt].type = "TABLE",
      dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].reason =
      "Obsolete Objects (obsolete table)"
      IF ((dm_err->debug_flag > 0))
       CALL echo(build("Obsolete Objects (obsolete table)",t.table_name))
      ENDIF
     ENDIF
     IF ((dm2_install_schema->process_option="CLIN COPY")
      AND (drr_preserved_tables_data->refresh_ind=1)
      AND (drr_clin_copy_data->process != "RESTORE"))
      FOR (pres_tbl_cnt = preserve_tbl TO drr_preserved_tables_data->cnt)
        IF ((drr_preserved_tables_data->tbl[pres_tbl_cnt].table_name <= t.table_name))
         IF ((drr_preserved_tables_data->tbl[pres_tbl_cnt].refresh_ind=1)
          AND (drr_preserved_tables_data->tbl[pres_tbl_cnt].table_name < t.table_name)
          AND locateval(tbl_ndx,1,tgtsch->tbl_cnt,drr_preserved_tables_data->tbl[pres_tbl_cnt].
          table_name,tgtsch->tbl[tbl_ndx].orig_tbl_name)=0)
          IF ((drr_preserved_tables_data->tbl[pres_tbl_cnt].group="AUTOTESTER"))
           tgtsch->tbl_cnt = (tgtsch->tbl_cnt+ 1)
           IF (mod(tgtsch->tbl_cnt,10)=1
            AND (tgtsch->tbl_cnt != 1))
            stat = alterlist(tgtsch->tbl,(tgtsch->tbl_cnt+ 9))
           ENDIF
           tgtsch->tbl[tgtsch->tbl_cnt].tbl_name = drr_preserved_tables_data->tbl[pres_tbl_cnt].
           table_name, drr_preserved_tables_data->tbl[pres_tbl_cnt].pres_tbl_not_in_src = 1,
           drr_preserved_tables_data->tbl[pres_tbl_cnt].tgtsch_idx = tgtsch->tbl_cnt
           IF ((dm_err->debug_flag > 2))
            CALL echo(build("Add Preserved table ",drr_preserved_tables_data->tbl[pres_tbl_cnt].
             table_name," to tgtsch with seq ",tgtsch->tbl_cnt))
           ENDIF
          ELSE
           drr_preserved_tables_data->tbl[pres_tbl_cnt].refresh_ind = 0, drr_preserved_tables_data->
           tbl[pres_tbl_cnt].pres_tbl_not_in_src = 1
          ENDIF
         ENDIF
         preserve_tbl = (preserve_tbl+ 1)
        ELSE
         pres_tbl_cnt = (drr_preserved_tables_data->cnt+ 1)
        ENDIF
      ENDFOR
     ENDIF
     IF ((drr_clin_copy_data->process="RESTORE"))
      restore_t = locateval(restore_t,1,drr_preserved_tables_data->cnt,t.table_name,
       drr_preserved_tables_data->tbl[restore_t].table_name)
      IF (restore_t > 0
       AND (drr_preserved_tables_data->tbl[restore_t].refresh_ind=1))
       exist_t = 0, exist_t = locateval(exist_t,1,dtl_user_tables->cnt,t.table_name,dtl_user_tables->
        qual[exist_t].table_name)
       IF (exist_t=0)
        drr_preserved_tables_data->tbl[restore_t].pres_tbl_not_in_src = 1
        IF ((drr_preserved_tables_data->tbl[restore_t].group != "AUTOTESTER"))
         noload = 1, drr_preserved_tables_data->tbl[restore_t].refresh_ind = 0
        ENDIF
       ENDIF
      ELSE
       noload = 1
      ENDIF
     ENDIF
     IF (dtl_obs_obj_idx=0
      AND dtl_obs_obj_idx2=0
      AND noload=0)
      tgtsch->tbl_cnt = (tgtsch->tbl_cnt+ 1)
      IF (mod(tgtsch->tbl_cnt,10)=1
       AND (tgtsch->tbl_cnt != 1))
       stat = alterlist(tgtsch->tbl,(tgtsch->tbl_cnt+ 9))
      ENDIF
      IF (((t.table_name="*GTTD") OR (t.table_name="*GTMP")) )
       tgtsch->tbl[tgtsch->tbl_cnt].gtt_flag = 1
      ELSEIF (t.table_name="*GTTP")
       tgtsch->tbl[tgtsch->tbl_cnt].gtt_flag = 2
      ENDIF
      IF (t.table_name="MV*")
       IF ((dm2_rdbms_version->level1 < 9))
        tgtsch->tbl[tgtsch->tbl_cnt].mview_flag = 2
       ELSE
        tgtsch->tbl[tgtsch->tbl_cnt].mview_flag = 1
       ENDIF
       IF ((dm2_install_schema->process_option="CLIN COPY"))
        tgtsch->tbl[tgtsch->tbl_cnt].mview_cc_build_ind = validate(t.feature_number,0)
       ELSE
        tgtsch->tbl[tgtsch->tbl_cnt].mview_cc_build_ind = 1
       ENDIF
      ENDIF
      IF ((drr_clin_copy_data->process="RESTORE"))
       drr_preserved_tables_data->tbl[restore_t].tgtsch_idx = tgtsch->tbl_cnt
      ENDIF
      tgtsch->tbl[tgtsch->tbl_cnt].orig_tbl_name = t.table_name, tgtsch->tbl[tgtsch->tbl_cnt].
      schema_date = t.schema_date, tgtsch->tbl[tgtsch->tbl_cnt].schema_instance = t.schema_instance,
      tgtsch->tbl[tgtsch->tbl_cnt].pct_increase = t.pct_increase, tgtsch->tbl[tgtsch->tbl_cnt].
      pct_used = t.pct_used, tgtsch->tbl[tgtsch->tbl_cnt].pct_free = t.pct_free,
      tgtsch->tbl[tgtsch->tbl_cnt].bytes_allocated = validate(t.bytes_allocated,0.0), tgtsch->tbl[
      tgtsch->tbl_cnt].bytes_used = validate(t.bytes_used,0.0)
      IF ((dm2_install_schema->process_option IN ("CLIN COPY", "DDL GEN")))
       tgtsch->tbl[tgtsch->tbl_cnt].tspace_name = t.tablespace_name, tgtsch->tbl[tgtsch->tbl_cnt].
       ind_tspace = validate(t.index_tspace," "), tgtsch->tbl[tgtsch->tbl_cnt].long_tspace = validate
       (t.long_tspace," "),
       tgtsch->tbl[tgtsch->tbl_cnt].init_ext = validate(t.init_ext,0.0), tgtsch->tbl[tgtsch->tbl_cnt]
       .next_ext = validate(t.next_ext,0.0)
       IF ((tgtsch->tbl[tgtsch->tbl_cnt].pct_free > 60)
        AND (tgtsch->tbl[tgtsch->tbl_cnt].pct_used=0.0))
        tgtsch->tbl[tgtsch->tbl_cnt].pct_used = 1.0
       ENDIF
       tgtsch->tbl[tgtsch->tbl_cnt].dext_mgmt = validate(t.tspace_type," "), tgtsch->tbl[tgtsch->
       tbl_cnt].lext_mgmt = validate(t.long_tspace_type," "), tgtsch->tbl[tgtsch->tbl_cnt].max_ext =
       validate(t.max_ext,0.0)
      ELSE
       tgtsch->tbl[tgtsch->tbl_cnt].tspace_name = " ", tgtsch->tbl[tgtsch->tbl_cnt].ind_tspace = " ",
       tgtsch->tbl[tgtsch->tbl_cnt].long_tspace = " ",
       tgtsch->tbl[tgtsch->tbl_cnt].init_ext = 0.0, tgtsch->tbl[tgtsch->tbl_cnt].next_ext = 0.0
      ENDIF
      tgtsch->tbl[tgtsch->tbl_cnt].alpha_feature_nbr = tgtsch->alpha_feature_nbr, tgtsch->tbl[tgtsch
      ->tbl_cnt].feature_number = validate(t.feature_number,0), tgtsch->tbl[tgtsch->tbl_cnt].
      updt_dt_tm = t.updt_dt_tm,
      tgtsch->tbl[tgtsch->tbl_cnt].afd_schema_instance = 0, tgtsch->tbl[tgtsch->tbl_cnt].
      pull_from_afd = 0, tgtsch->tbl[tgtsch->tbl_cnt].rowid_col_fnd = 0,
      tgtsch->tbl[tgtsch->tbl_cnt].xrid_ind_fnd = 0
      IF (dtl_mode="PKGINSTALL")
       tgtsch->tbl[tgtsch->tbl_cnt].tbl_name = t.table_name, tgtsch->tbl[tgtsch->tbl_cnt].
       table_suffix = validate(td.table_suffix,"0000"), tgtsch->tbl[tgtsch->tbl_cnt].pull_from_afd =
       1,
       tgtsch->tbl[tgtsch->tbl_cnt].metadata_loc_flg = 1, stat = alterlist(tgtsch->tbl[tgtsch->
        tbl_cnt].tbl_col,0), tgtsch->tbl[tgtsch->tbl_cnt].tbl_col_cnt = 0,
       stat = alterlist(tgtsch->tbl[tgtsch->tbl_cnt].ind,0), tgtsch->tbl[tgtsch->tbl_cnt].ind_cnt = 0,
       stat = alterlist(tgtsch->tbl[tgtsch->tbl_cnt].cons,0),
       tgtsch->tbl[tgtsch->tbl_cnt].cons_cnt = 0, tgtsch->tbl[tgtsch->tbl_cnt].rowid_col_fnd = 0,
       tgtsch->tbl[tgtsch->tbl_cnt].xrid_ind_fnd = 0
      ELSEIF (cnvtupper(currdbuser)="CDBA")
       tgtsch->tbl[tgtsch->tbl_cnt].tbl_name = t.table_name, tgtsch->tbl[tgtsch->tbl_cnt].
       table_suffix = "0000", tgtsch->tbl[tgtsch->tbl_cnt].schema_instance = abs(tgtsch->
        alpha_feature_nbr)
      ELSE
       tgtsch->tbl[tgtsch->tbl_cnt].full_tbl_name = validate(td.full_table_name," "), tgtsch->tbl[
       tgtsch->tbl_cnt].suff_tbl_name = validate(td.suffixed_table_name," "), convert_table_name,
       tgtsch->tbl[tgtsch->tbl_cnt].reference_ind = validate(td.reference_ind,0), tgtsch->tbl[tgtsch
       ->tbl_cnt].table_suffix = validate(td.table_suffix," ")
      ENDIF
     ENDIF
    FOOT REPORT
     IF (dtl_mode="PKGINSTALL")
      FOR (child_tbl_cnt = child_tbl TO child_tables->tbl_cnt)
        tgtsch->tbl_cnt = (tgtsch->tbl_cnt+ 1)
        IF (mod(tgtsch->tbl_cnt,10)=1
         AND (tgtsch->tbl_cnt != 1))
         stat = alterlist(tgtsch->tbl,(tgtsch->tbl_cnt+ 9))
        ENDIF
        tgtsch->tbl[tgtsch->tbl_cnt].tbl_name = child_tables->tbl[child_tbl_cnt].tbl_name, tgtsch->
        tbl[tgtsch->tbl_cnt].orig_tbl_name = child_tables->tbl[child_tbl_cnt].tbl_name, tgtsch->tbl[
        tgtsch->tbl_cnt].child_tbl_ind = 1,
        tgtsch->tbl[tgtsch->tbl_cnt].pct_increase = child_tables->tbl[child_tbl_cnt].pct_increase,
        tgtsch->tbl[tgtsch->tbl_cnt].pct_used = child_tables->tbl[child_tbl_cnt].pct_used, tgtsch->
        tbl[tgtsch->tbl_cnt].pct_free = child_tables->tbl[child_tbl_cnt].pct_free,
        tgtsch->tbl[tgtsch->tbl_cnt].schema_instance = child_tables->tbl[child_tbl_cnt].
        schema_instance, tgtsch->tbl[tgtsch->tbl_cnt].alpha_feature_nbr = child_tables->tbl[
        child_tbl_cnt].alpha_feature_nbr, tgtsch->tbl[tgtsch->tbl_cnt].feature_number = child_tables
        ->tbl[child_tbl_cnt].feature_number,
        tgtsch->tbl[tgtsch->tbl_cnt].updt_dt_tm = child_tables->tbl[child_tbl_cnt].updt_dt_tm, tgtsch
        ->tbl[tgtsch->tbl_cnt].table_suffix = child_tables->tbl[child_tbl_cnt].table_suffix, tgtsch->
        tbl[tgtsch->tbl_cnt].metadata_loc_flg = 1,
        tgtsch->tbl[tgtsch->tbl_cnt].pull_from_afd = 1
        IF ((dm_err->debug_flag > 2))
         CALL echo(build("Add Child table <",child_tables->tbl[child_tbl_cnt].tbl_name,
          "> to tgtsch with seq <",tgtsch->tbl_cnt,">."))
        ENDIF
      ENDFOR
     ENDIF
     IF ((dm2_install_schema->process_option="CLIN COPY")
      AND (drr_preserved_tables_data->refresh_ind=1)
      AND (drr_clin_copy_data->process != "RESTORE"))
      FOR (pres_tbl_cnt = preserve_tbl TO drr_preserved_tables_data->cnt)
        IF ((drr_preserved_tables_data->tbl[pres_tbl_cnt].refresh_ind=1))
         IF ((drr_preserved_tables_data->tbl[pres_tbl_cnt].group="AUTOTESTER"))
          tgtsch->tbl_cnt = (tgtsch->tbl_cnt+ 1)
          IF (mod(tgtsch->tbl_cnt,10)=1
           AND (tgtsch->tbl_cnt != 1))
           stat = alterlist(tgtsch->tbl,(tgtsch->tbl_cnt+ 9))
          ENDIF
          tgtsch->tbl[tgtsch->tbl_cnt].tbl_name = drr_preserved_tables_data->tbl[pres_tbl_cnt].
          table_name, drr_preserved_tables_data->tbl[pres_tbl_cnt].pres_tbl_not_in_src = 1,
          drr_preserved_tables_data->tbl[pres_tbl_cnt].tgtsch_idx = tgtsch->tbl_cnt
          IF ((dm_err->debug_flag > 2))
           CALL echo(build("Add Preserved table ",drr_preserved_tables_data->tbl[pres_tbl_cnt].
            table_name," to tgtsch with seq ",tgtsch->tbl_cnt))
          ENDIF
         ELSE
          drr_preserved_tables_data->tbl[pres_tbl_cnt].refresh_ind = 0, drr_preserved_tables_data->
          tbl[pres_tbl_cnt].pres_tbl_not_in_src = 1
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
     stat = alterlist(tgtsch->tbl,tgtsch->tbl_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ELSEIF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "No Table Information Found"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("Table count = ",cnvtstring(tgtsch->tbl_cnt,4,0)))
   ENDIF
   IF ((dm_err->debug_flag > 4))
    CALL echorecord(tgtsch)
   ENDIF
   FREE RECORD child_tables
 END ;Subroutine
 SUBROUTINE set_max_schema_instance(null)
   DECLARE smsi_idx = i4 WITH protect, noconstant(0)
   DECLARE smsi_info_domain = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Retrieving Best Schema to Populate from."
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dtl_mode="PKGINSTALL")
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(tgtsch->tbl_cnt))
     PLAN (d)
     DETAIL
      tgtsch->tbl[d.seq].pull_from_afd = 0, tgtsch->tbl[d.seq].metadata_loc_flg = 0
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN
    ENDIF
   ENDIF
   IF (cnvtupper(currdbuser)="CDBA")
    SET smsi_info_domain = "DM2_ADMIN_TABLE"
   ELSE
    SET smsi_info_domain = "DM2_SCHEMA_INSTANCE"
   ENDIF
   SELECT
    IF (dtl_sd_in_use_ind=0)
     table_name = d.info_name, version = d.info_number
     FROM dm_info d
     PLAN (d
      WHERE d.info_domain=smsi_info_domain)
    ELSE
     table_name = stv.table_name, version = stv.version_nbr
     FROM (ceradm.sd_table_version_v stv)
     WHERE stv.owner=currdbuser
    ENDIF
    INTO "nl:"
    DETAIL
     smsi_idx = 0, smsi_idx = locateval(smsi_idx,1,tgtsch->tbl_cnt,table_name,tgtsch->tbl[smsi_idx].
      tbl_name)
     IF (smsi_idx > 0)
      IF ((version > tgtsch->tbl[smsi_idx].schema_instance))
       tgtsch->tbl[smsi_idx].pull_from_afd = 1, tgtsch->tbl[smsi_idx].afd_schema_instance = version,
       dtl_load_from_afd = 1
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
 END ;Subroutine
 SUBROUTINE populate_table(null)
   DECLARE pt_idx = i4 WITH protect, noconstant(0)
   DECLARE pt_override_ind = i2 WITH protect, noconstant(0)
   DECLARE pt_qry_cnt1 = i4 WITH protect, noconstant(0)
   DECLARE pt_qry_cnt2 = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Retrieval and Load of Schema from Admin."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(tgtsch->tbl_cnt)),
     dm_afd_tables t
    PLAN (d
     WHERE (tgtsch->tbl[d.seq].pull_from_afd=1))
     JOIN (t
     WHERE t.owner=currdbuser
      AND (tgtsch->tbl[d.seq].tbl_name=t.table_name)
      AND (tgtsch->tbl[d.seq].afd_schema_instance=t.schema_instance))
    DETAIL
     tgtsch->tbl[d.seq].tspace_name = t.tablespace_name, tgtsch->tbl[d.seq].pct_increase = t
     .pct_increase, tgtsch->tbl[d.seq].pct_used = t.pct_used,
     tgtsch->tbl[d.seq].pct_free = t.pct_free, tgtsch->tbl[d.seq].schema_date = t.schema_date, tgtsch
     ->tbl[d.seq].alpha_feature_nbr = t.alpha_feature_nbr,
     tgtsch->tbl[d.seq].feature_number = t.feature_number, tgtsch->tbl[d.seq].updt_dt_tm = t
     .updt_dt_tm, tgtsch->tbl[d.seq].schema_instance = t.schema_instance,
     tgtsch->tbl[d.seq].metadata_loc_flg = 1, stat = alterlist(tgtsch->tbl[d.seq].tbl_col,0), tgtsch
     ->tbl[d.seq].tbl_col_cnt = 0,
     stat = alterlist(tgtsch->tbl[d.seq].ind,0), tgtsch->tbl[d.seq].ind_cnt = 0, stat = alterlist(
      tgtsch->tbl[d.seq].cons,0),
     tgtsch->tbl[d.seq].cons_cnt = 0, tgtsch->tbl[d.seq].rowid_col_fnd = 0, tgtsch->tbl[d.seq].
     xrid_ind_fnd = 0
    WITH nocounter, maxqual(t,1)
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
   SET pt_qry_cnt1 = curqual
   SET pt_idx = 0
   IF (dtl_sd_in_use_ind=1)
    IF (locateval(pt_idx,1,tgtsch->tbl_cnt,1,tgtsch->tbl[pt_idx].pull_from_afd,
     0,tgtsch->tbl[pt_idx].metadata_loc_flg) > 0)
     SET dm_err->eproc = "Retrieval and Load of Schema from Admin via SD_TABLES."
     CALL disp_msg(" ",dm_err->logfile,0)
     SELECT INTO "nl:"
      d.seq
      FROM (dummyt d  WITH seq = value(tgtsch->tbl_cnt)),
       (ceradm.sd_tables t)
      PLAN (d
       WHERE (tgtsch->tbl[d.seq].pull_from_afd=1)
        AND (tgtsch->tbl[d.seq].metadata_loc_flg=0))
       JOIN (t
       WHERE t.owner=currdbuser
        AND (tgtsch->tbl[d.seq].tbl_name=t.table_name)
        AND (tgtsch->tbl[d.seq].afd_schema_instance=t.version_nbr))
      DETAIL
       tgtsch->tbl[d.seq].tspace_name = "", tgtsch->tbl[d.seq].pct_increase = 0, tgtsch->tbl[d.seq].
       pct_used = 0,
       tgtsch->tbl[d.seq].pct_free = 0, tgtsch->tbl[d.seq].schema_date = 0, tgtsch->tbl[d.seq].
       alpha_feature_nbr = 0,
       tgtsch->tbl[d.seq].updt_dt_tm = t.updt_dt_tm, tgtsch->tbl[d.seq].schema_instance = t
       .version_nbr, tgtsch->tbl[d.seq].metadata_loc_flg = 2,
       stat = alterlist(tgtsch->tbl[d.seq].tbl_col,0), tgtsch->tbl[d.seq].tbl_col_cnt = 0, stat =
       alterlist(tgtsch->tbl[d.seq].ind,0),
       tgtsch->tbl[d.seq].ind_cnt = 0, stat = alterlist(tgtsch->tbl[d.seq].cons,0), tgtsch->tbl[d.seq
       ].cons_cnt = 0,
       tgtsch->tbl[d.seq].rowid_col_fnd = 0, tgtsch->tbl[d.seq].xrid_ind_fnd = 0
      WITH nocounter, maxqual(t,1)
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ENDIF
     SET pt_qry_cnt2 = curqual
    ENDIF
   ENDIF
   IF ((dir_dropped_objects->obj_cnt > 0))
    SET dm_err->eproc = "Clearing out dir_dropped_object entries for tables to be pulled from afd."
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(tgtsch->tbl_cnt)),
      (dummyt d2  WITH seq = value(dir_dropped_objects->obj_cnt))
     PLAN (d
      WHERE (tgtsch->tbl[d.seq].pull_from_afd=1))
      JOIN (d2
      WHERE (dir_dropped_objects->obj[d2.seq].table_name=tgtsch->tbl[d.seq].tbl_name))
     DETAIL
      dir_dropped_objects->obj[d2.seq].table_name = "", dir_dropped_objects->obj[d2.seq].name = "",
      dir_dropped_objects->obj[d2.seq].type = "",
      dir_dropped_objects->obj[d2.seq].reason = "", dir_dropped_objects->rpt_drp_obj_ind = 0
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ENDIF
    IF ((dir_dropped_objects->rpt_drp_obj_ind=0))
     SET dm_err->eproc = "Resetting report indicator if there is one object to be reported on."
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(dir_dropped_objects->obj_cnt))
      WHERE (dir_dropped_objects->obj[d.seq].table_name > "")
      DETAIL
       dir_dropped_objects->rpt_drp_obj_ind = 1
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ENDIF
    ENDIF
   ENDIF
   IF (pt_qry_cnt1=0
    AND pt_qry_cnt2=0)
    SET dm_err->eproc = "Retrieval and Load of Schema from AFD/SD tables having higher instance."
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "No Table Information Found"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   ENDIF
 END ;Subroutine
 SUBROUTINE populate_tbl_columns(null)
   DECLARE col_cnt = i4 WITH protect, noconstant(0)
   DECLARE column_nm_lngth = i4 WITH protect, noconstant(0)
   DECLARE id_cd_start = i4 WITH protect, noconstant(0)
   DECLARE value_compl_start = i4 WITH protect, noconstant(0)
   DECLARE id_cd_check = vc WITH protect, noconstant(" ")
   DECLARE value_compl_check = vc WITH protect, noconstant(" ")
   DECLARE data_default_scrunched = vc WITH protect, noconstant(" ")
   DECLARE ptc_idx = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Performing Load of Column Information"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dm2_set_autocommit(1)=0)
    RETURN(null)
   ENDIF
   SELECT
    IF (dtl_src_of_data="A")
     FROM (dummyt d  WITH seq = value(tgtsch->tbl_cnt)),
      dm_afd_columns tc
     PLAN (d
      WHERE (tgtsch->tbl[d.seq].pull_from_afd=1)
       AND (tgtsch->tbl[d.seq].metadata_loc_flg=1))
      JOIN (tc
      WHERE tc.owner=currdbuser
       AND (tgtsch->tbl[d.seq].tbl_name=tc.table_name)
       AND (tgtsch->tbl[d.seq].alpha_feature_nbr=tc.alpha_feature_nbr))
    ELSEIF ((dm2_install_schema->process_option="INHOUSE"))
     FROM (dummyt d  WITH seq = value(tgtsch->tbl_cnt)),
      dm_adm_columns tc
     PLAN (d)
      JOIN (tc
      WHERE (tgtsch->tbl[d.seq].orig_tbl_name=tc.table_name)
       AND tc.schema_date=cnvtdatetime(inhouse_reply->schema_date)
       AND tc.owner=currdbuser)
    ELSE
     FROM dmcolumn tc,
      (dummyt d  WITH seq = value(tgtsch->tbl_cnt))
     PLAN (d)
      JOIN (tc
      WHERE (tgtsch->tbl[d.seq].orig_tbl_name=tc.table_name))
    ENDIF
    INTO "nl:"
    ORDER BY tc.table_name, tc.column_seq
    HEAD REPORT
     MACRO (data_default_cleanup)
      IF (((cnvtupper(tc.data_default)="NULL") OR (((tc.data_default=" ") OR (((tc.data_default="")
       OR (((tc.data_default="''") OR (tc.data_default='""')) )) )) )) )
       tgtsch->tbl[d.seq].tbl_col[col_cnt].data_default_ni = 1
      ENDIF
     ENDMACRO
    HEAD tc.table_name
     stat = alterlist(tgtsch->tbl[d.seq].tbl_col,50), tgtsch->tbl[d.seq].tbl_col_cnt = 0, col_cnt = 0,
     tgtsch->tbl[d.seq].rowid_col_fnd = 0, stat = assign(validate(tgtsch->tbl[d.seq].longlob_col_cnt,
       - (1)),0)
     IF ((drr_clin_copy_data->process="RESTORE"))
      pres_idx = 0, pres_idx = locateval(pres_idx,1,drr_preserved_tables_data->cnt,tc.table_name,
       drr_preserved_tables_data->tbl[pres_idx].table_name)
     ENDIF
    DETAIL
     IF ( NOT (validate(tc.virtual_column,"NO")="YES"
      AND (dm2_rdbms_version->level1 < 11)))
      col_cnt = (col_cnt+ 1)
      IF (mod(col_cnt,50)=1
       AND col_cnt != 1)
       stat = alterlist(tgtsch->tbl[d.seq].tbl_col,(col_cnt+ 49))
      ENDIF
      tgtsch->tbl[d.seq].tbl_col[col_cnt].col_name = tc.column_name, tgtsch->tbl[d.seq].tbl_col[
      col_cnt].col_seq = tc.column_seq, tgtsch->tbl[d.seq].tbl_col[col_cnt].nullable = tc.nullable,
      tgtsch->tbl[d.seq].tbl_col[col_cnt].data_length = tc.data_length, tgtsch->tbl[d.seq].tbl_col[
      col_cnt].virtual_column = evaluate(trim(validate(tc.virtual_column,"NO")),"","NO",validate(tc
        .virtual_column,"NO"))
      IF ((( NOT ((dm2_install_schema->process_option IN ("CLIN COPY", "DDL GEN")))) OR ((
      drr_clin_copy_data->process="MIGRATION")
       AND validate(dm2_bypass_long_to_lob,- (1)) != 1)) )
       IF ((dm2_db_options->lob_build_ind="Y"))
        CASE (cnvtupper(tc.data_type))
         OF "LONG":
          tgtsch->tbl[d.seq].tbl_col[col_cnt].data_type = "CLOB"
         OF "LONG RAW":
          tgtsch->tbl[d.seq].tbl_col[col_cnt].data_type = "BLOB"
         ELSE
          tgtsch->tbl[d.seq].tbl_col[col_cnt].data_type = tc.data_type
        ENDCASE
       ELSE
        CASE (cnvtupper(tc.data_type))
         OF "CLOB":
          tgtsch->tbl[d.seq].tbl_col[col_cnt].data_type = "LONG"
         OF "BLOB":
          tgtsch->tbl[d.seq].tbl_col[col_cnt].data_type = "LONG RAW"
         ELSE
          tgtsch->tbl[d.seq].tbl_col[col_cnt].data_type = tc.data_type
        ENDCASE
       ENDIF
      ELSE
       tgtsch->tbl[d.seq].tbl_col[col_cnt].data_type = tc.data_type
      ENDIF
      IF (dtl_src_of_data="A")
       tgtsch->tbl[d.seq].tbl_col[col_cnt].data_default_ni = nullind(tc.data_default)
       IF ((tgtsch->tbl[d.seq].tbl_col[col_cnt].data_default_ni=0))
        data_default_cleanup
       ENDIF
       IF ((tgtsch->tbl[d.seq].tbl_col[col_cnt].data_default_ni=0))
        tgtsch->tbl[d.seq].tbl_col[col_cnt].data_default = tc.data_default
       ENDIF
      ELSE
       IF ((dm2_install_schema->process_option="INHOUSE"))
        tgtsch->tbl[d.seq].tbl_col[col_cnt].data_default_ni = validate(tc.data_default_ni,0)
        IF ((tgtsch->tbl[d.seq].tbl_col[col_cnt].data_default_ni=0))
         IF (((size(trim(tc.data_default),1)=0) OR (nullind(tc.data_default)=1)) )
          tgtsch->tbl[d.seq].tbl_col[col_cnt].data_default_ni = 1
         ENDIF
        ENDIF
       ELSE
        tgtsch->tbl[d.seq].tbl_col[col_cnt].data_default_ni = validate(tc.data_default_ni,1)
       ENDIF
       IF ((tgtsch->tbl[d.seq].tbl_col[col_cnt].data_default_ni=0))
        data_default_cleanup
       ENDIF
       IF ((tgtsch->tbl[d.seq].tbl_col[col_cnt].data_default_ni=0))
        tgtsch->tbl[d.seq].tbl_col[col_cnt].data_default = tc.data_default
        IF ((dm2_install_schema->process_option IN ("CHECK", "PREVIEW", "CLIN COPY", "CLIN UPGRADE"))
         AND  NOT ((dm2_install_pkg->process_option IN ("BATCHPKG", "SINGLEPKG"))))
         IF ( NOT (validate(tc.data_default2,"X")="X"
          AND validate(tc.data_default2,"Y")="Y")
          AND substring(1,254,tc.data_default)=substring(1,254,validate(tc.data_default2,"DM2NOTSET")
          ))
          tgtsch->tbl[d.seq].tbl_col[col_cnt].data_default = validate(tc.data_default2,"DM2NOTSET")
         ENDIF
        ENDIF
       ENDIF
      ENDIF
      IF (cnvtupper(tc.column_name)="ROWID"
       AND cnvtupper(currdbuser) != "CDBA")
       tgtsch->tbl[d.seq].rowid_col_fnd = 1
      ENDIF
      IF ((tgtsch->tbl[d.seq].tbl_col[col_cnt].data_type IN ("LONG", "LONG RAW", "CLOB", "BLOB")))
       stat = assign(validate(tgtsch->tbl[d.seq].longlob_col_cnt,- (1)),(validate(tgtsch->tbl[d.seq].
         longlob_col_cnt,- (1))+ 1))
      ENDIF
      IF ((drr_clin_copy_data->process="RESTORE"))
       IF ((dm_err->debug_flag > 2))
        CALL echo(concat("Populate column for preserve table ",tc.table_name," column ",tgtsch->tbl[d
         .seq].tbl_col[col_cnt].col_name))
       ENDIF
       drr_preserved_tables_data->tbl[pres_idx].col_cnt = (drr_preserved_tables_data->tbl[pres_idx].
       col_cnt+ 1), stat = alterlist(drr_preserved_tables_data->tbl[pres_idx].col,
        drr_preserved_tables_data->tbl[pres_idx].col_cnt), drr_preserved_tables_data->tbl[pres_idx].
       col[drr_preserved_tables_data->tbl[pres_idx].col_cnt].col_name = tgtsch->tbl[d.seq].tbl_col[
       col_cnt].col_name,
       drr_preserved_tables_data->tbl[pres_idx].col[drr_preserved_tables_data->tbl[pres_idx].col_cnt]
       .data_type = tgtsch->tbl[d.seq].tbl_col[col_cnt].data_type
       IF ((((drr_preserved_tables_data->tbl[pres_idx].col[drr_preserved_tables_data->tbl[pres_idx].
       col_cnt].data_type="LONG")) OR ((drr_preserved_tables_data->tbl[pres_idx].col[
       drr_preserved_tables_data->tbl[pres_idx].col_cnt].data_type="LONG RAW"))) )
        drr_preserved_tables_data->tbl[pres_idx].long_cols_exist = 1
       ENDIF
       drr_preserved_tables_data->tbl[pres_idx].col[drr_preserved_tables_data->tbl[pres_idx].col_cnt]
       .data_length = tgtsch->tbl[d.seq].tbl_col[col_cnt].data_length, drr_preserved_tables_data->
       tbl[pres_idx].col[drr_preserved_tables_data->tbl[pres_idx].col_cnt].data_default_ni = tgtsch->
       tbl[d.seq].tbl_col[col_cnt].data_default_ni
       IF ((drr_preserved_tables_data->tbl[pres_idx].col[drr_preserved_tables_data->tbl[pres_idx].
       col_cnt].data_default_ni=0))
        drr_preserved_tables_data->tbl[pres_idx].col[drr_preserved_tables_data->tbl[pres_idx].col_cnt
        ].data_default = tgtsch->tbl[d.seq].tbl_col[col_cnt].data_default
       ENDIF
       drr_preserved_tables_data->tbl[pres_idx].col[drr_preserved_tables_data->tbl[pres_idx].col_cnt]
       .nullable = tgtsch->tbl[d.seq].tbl_col[col_cnt].nullable
      ENDIF
     ENDIF
    FOOT  tc.table_name
     stat = alterlist(tgtsch->tbl[d.seq].tbl_col,col_cnt), tgtsch->tbl[d.seq].tbl_col_cnt = col_cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ELSEIF ((drr_clin_copy_data->process != "RESTORE")
    AND curqual=0
    AND dtl_sd_in_use_ind=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "No Column Information Found"
    SET dm_err->eproc = "Performing Load of Column Information "
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   ENDIF
   IF (dtl_sd_in_use_ind=1)
    IF (locateval(ptc_idx,1,tgtsch->tbl_cnt,1,tgtsch->tbl[ptc_idx].pull_from_afd,
     2,tgtsch->tbl[ptc_idx].metadata_loc_flg) > 0)
     SET dm_err->eproc = "Performing Load of Column Information via SD tables"
     CALL disp_msg(" ",dm_err->logfile,0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(tgtsch->tbl_cnt)),
       (ceradm.sd_table_cols tc)
      PLAN (d
       WHERE (tgtsch->tbl[d.seq].pull_from_afd=1)
        AND (tgtsch->tbl[d.seq].metadata_loc_flg=2))
       JOIN (tc
       WHERE tc.owner=currdbuser
        AND (tgtsch->tbl[d.seq].tbl_name=tc.table_name)
        AND (tgtsch->tbl[d.seq].schema_instance=tc.version_nbr))
      ORDER BY tc.table_name, tc.column_seq
      HEAD REPORT
       MACRO (data_default_cleanup)
        IF (((cnvtupper(tc.data_default)="NULL") OR (((tc.data_default=" ") OR (((tc.data_default="")
         OR (((tc.data_default="''") OR (tc.data_default='""')) )) )) )) )
         tgtsch->tbl[d.seq].tbl_col[col_cnt].data_default_ni = 1
        ENDIF
       ENDMACRO
      HEAD tc.table_name
       stat = alterlist(tgtsch->tbl[d.seq].tbl_col,50), tgtsch->tbl[d.seq].tbl_col_cnt = 0, col_cnt
        = 0,
       tgtsch->tbl[d.seq].rowid_col_fnd = 0, stat = assign(validate(tgtsch->tbl[d.seq].
         longlob_col_cnt,- (1)),0)
      DETAIL
       col_cnt = (col_cnt+ 1)
       IF (mod(col_cnt,50)=1
        AND col_cnt != 1)
        stat = alterlist(tgtsch->tbl[d.seq].tbl_col,(col_cnt+ 49))
       ENDIF
       tgtsch->tbl[d.seq].tbl_col[col_cnt].col_name = tc.column_name, tgtsch->tbl[d.seq].tbl_col[
       col_cnt].col_seq = tc.column_seq, tgtsch->tbl[d.seq].tbl_col[col_cnt].nullable = tc.nullable,
       tgtsch->tbl[d.seq].tbl_col[col_cnt].data_length = tc.data_length, tgtsch->tbl[d.seq].tbl_col[
       col_cnt].virtual_column = tc.virtual_column, tgtsch->tbl[d.seq].tbl_col[col_cnt].data_type =
       tc.data_type,
       tgtsch->tbl[d.seq].tbl_col[col_cnt].data_default_ni = nullind(tc.data_default)
       IF ((tgtsch->tbl[d.seq].tbl_col[col_cnt].data_default_ni=0))
        data_default_cleanup
       ENDIF
       IF ((tgtsch->tbl[d.seq].tbl_col[col_cnt].data_default_ni=0))
        tgtsch->tbl[d.seq].tbl_col[col_cnt].data_default = tc.data_default
       ENDIF
       IF (cnvtupper(tc.column_name)="ROWID")
        tgtsch->tbl[d.seq].rowid_col_fnd = 1
       ENDIF
       IF ((tgtsch->tbl[d.seq].tbl_col[col_cnt].data_type IN ("LONG", "LONG RAW", "CLOB", "BLOB")))
        stat = assign(validate(tgtsch->tbl[d.seq].longlob_col_cnt,- (1)),(validate(tgtsch->tbl[d.seq]
          .longlob_col_cnt,- (1))+ 1))
       ENDIF
      FOOT  tc.table_name
       stat = alterlist(tgtsch->tbl[d.seq].tbl_col,col_cnt), tgtsch->tbl[d.seq].tbl_col_cnt = col_cnt
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ELSEIF (curqual=0)
      SET dm_err->err_ind = 1
      SET dm_err->emsg = "No Column Information Found"
      SET dm_err->eproc = "Performing Load of Column Information via SD tables "
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     ENDIF
    ENDIF
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(null)
   ENDIF
   SET ptc_idx = 0
   IF (locateval(ptc_idx,1,tgtsch->tbl_cnt,0,tgtsch->tbl[ptc_idx].tbl_col_cnt) > 0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "No Column Information Found"
    SET dm_err->eproc = "Performing Load of Column Information via AFD/SD tables "
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   ENDIF
 END ;Subroutine
 SUBROUTINE populate_tbl_indexes(null)
   DECLARE cnt_i = i4 WITH protect, noconstant(0)
   DECLARE cnt_ic = i4 WITH protect, noconstant(0)
   DECLARE ind_type_sw = i4 WITH protect, noconstant(0)
   DECLARE pti_valid_nls = i4 WITH protect, noconstant(0)
   DECLARE pti_found_ind = i2 WITH protect, noconstant(0)
   DECLARE pti_idx = i4 WITH protect, noconstant(0)
   DECLARE pti_col_len = i4 WITH protect, noconstant(0)
   SET pti_valid_nls = 1
   IF (dtl_mode != "LOAD")
    SET pti_valid_nls = sbr_check_for_a_nls(null)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(null)
    ENDIF
    IF (pti_valid_nls=0)
     SET dm_err->eproc = "Query for existence of NLS triggers"
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     SELECT INTO "nl:"
      nls_trg_check = count(*)
      FROM dba_triggers d
      WHERE d.owner="V500"
       AND d.trigger_name="TRG*_ANLS*"
      DETAIL
       IF (nls_trg_check > 0)
        pti_valid_nls = 1
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ENDIF
    ENDIF
   ENDIF
   SET dm_err->eproc = "Retrieving and Loading Index Information."
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dm2_set_autocommit(1)=0)
    RETURN(null)
   ENDIF
   SELECT
    IF (dtl_src_of_data="A")
     FROM (dummyt d  WITH seq = value(tgtsch->tbl_cnt)),
      dm_afd_indexes i,
      dm_afd_index_columns ic
     PLAN (d
      WHERE (tgtsch->tbl[d.seq].pull_from_afd=1)
       AND (tgtsch->tbl[d.seq].metadata_loc_flg=1))
      JOIN (i
      WHERE i.owner=currdbuser
       AND (i.table_name=tgtsch->tbl[d.seq].tbl_name)
       AND (i.alpha_feature_nbr=tgtsch->tbl[d.seq].alpha_feature_nbr))
      JOIN (ic
      WHERE i.alpha_feature_nbr=ic.alpha_feature_nbr
       AND i.owner=ic.owner
       AND i.index_name=ic.index_name
       AND i.table_name=ic.table_name)
    ELSEIF ((dm2_install_schema->process_option="INHOUSE"))
     FROM dm_adm_indexes i,
      dm_adm_index_columns ic,
      (dummyt d  WITH seq = value(tgtsch->tbl_cnt))
     PLAN (d)
      JOIN (i
      WHERE (tgtsch->tbl[d.seq].orig_tbl_name=i.table_name)
       AND i.schema_date=cnvtdatetime(inhouse_reply->schema_date)
       AND i.owner=currdbuser)
      JOIN (ic
      WHERE i.schema_date=ic.schema_date
       AND i.index_name=ic.index_name
       AND i.table_name=ic.table_name
       AND i.owner=ic.owner)
    ELSE
     FROM dmindex i,
      dmindcol ic,
      (dummyt d  WITH seq = value(tgtsch->tbl_cnt))
     PLAN (d)
      JOIN (i
      WHERE (tgtsch->tbl[d.seq].orig_tbl_name=i.table_name))
      JOIN (ic
      WHERE i.index_name=ic.index_name
       AND i.table_name=ic.table_name)
    ENDIF
    INTO "nl:"
    ORDER BY i.table_name, i.index_name, ic.column_position
    HEAD i.table_name
     stat = alterlist(tgtsch->tbl[d.seq].ind,10), tgtsch->tbl[d.seq].ind_cnt = 0, tgtsch->tbl[d.seq].
     xrid_ind_fnd = 0,
     cnt_i = 0, ind_type_sw = 0
     IF (cnvtupper(currdbuser)="CDBA")
      tgtsch->tbl[d.seq].xrid_ind_fnd = 1
     ENDIF
    HEAD i.index_name
     dtl_obs_obj_idx = 0
     IF ((dtl_obs_obj->ind_cnt > 0))
      dtl_obs_obj_idx = locateval(dtl_obs_obj_idx,1,dtl_obs_obj->ind_cnt,i.index_name,dtl_obs_obj->
       ind[dtl_obs_obj_idx].index_name)
     ENDIF
     dtl_obs_obj_idx2 = 0
     IF ((dir_obsolete_objects->ind_cnt > 0)
      AND dtl_obs_obj_idx=0)
      dtl_obs_obj_idx2 = locateval(dtl_obs_obj_idx2,1,dir_obsolete_objects->ind_cnt,i.index_name,
       dir_obsolete_objects->ind[dtl_obs_obj_idx2].index_name)
     ENDIF
     IF (dtl_obs_obj_idx > 0)
      IF ((dm_err->debug_flag > 0))
       CALL echo(build("Conditional Build (index dropped):",i.index_name))
      ENDIF
     ELSEIF (dtl_obs_obj_idx2 > 0)
      dir_dropped_objects->rpt_drp_obj_ind = 1, dir_dropped_objects->obj_cnt = (dir_dropped_objects->
      obj_cnt+ 1), stat = alterlist(dir_dropped_objects->obj,dir_dropped_objects->obj_cnt),
      dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].table_name = tgtsch->tbl[d.seq].tbl_name,
      dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].name = i.index_name, dir_dropped_objects
      ->obj[dir_dropped_objects->obj_cnt].type = "INDEX",
      dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].reason =
      "Obsolete Objects (obsolete index)"
      IF ((dm_err->debug_flag > 0))
       CALL echo(build("Obsolete Objects (obsolete index):",i.index_name))
      ENDIF
     ENDIF
     IF (dtl_obs_obj_idx=0
      AND dtl_obs_obj_idx2=0)
      IF ( NOT (validate(i.index_type,"NORMAL")="FUNCTION-BASED NORMAL"
       AND (dm2_rdbms_version->level1 < 11)))
       cnt_i = (cnt_i+ 1), stat = alterlist(tgtsch->tbl[d.seq].ind,cnt_i), stat = alterlist(tgtsch->
        tbl[d.seq].ind[cnt_i].ind_col,10),
       tgtsch->tbl[d.seq].ind[cnt_i].ind_col_cnt = 0
       IF (dtl_src_of_data="A")
        tgtsch->tbl[d.seq].ind[cnt_i].ind_name = i.index_name
       ELSE
        tgtsch->tbl[d.seq].ind[cnt_i].ind_name = i.index_name
        IF ((dm2_install_schema->process_option IN ("CLIN COPY", "DDL GEN")))
         tgtsch->tbl[d.seq].ind[cnt_i].init_ext = validate(i.init_ext,0.0), tgtsch->tbl[d.seq].ind[
         cnt_i].next_ext = validate(i.next_ext,0.0), tgtsch->tbl[d.seq].ind[cnt_i].tspace_name =
         validate(i.tspace_name," "),
         tgtsch->tbl[d.seq].ind[cnt_i].ext_mgmt = validate(i.tspace_type," "), tgtsch->tbl[d.seq].
         ind[cnt_i].max_ext = validate(i.max_ext,0.0)
        ELSE
         tgtsch->tbl[d.seq].ind[cnt_i].init_ext = 0.0, tgtsch->tbl[d.seq].ind[cnt_i].next_ext = 0.0,
         tgtsch->tbl[d.seq].ind[cnt_i].ext_mgmt = " ",
         tgtsch->tbl[d.seq].ind[cnt_i].max_ext = 0.0
        ENDIF
        tgtsch->tbl[d.seq].ind[cnt_i].bytes_allocated = validate(i.bytes_allocated,0.0), tgtsch->tbl[
        d.seq].ind[cnt_i].bytes_used = validate(i.bytes_used,0.0)
       ENDIF
       tgtsch->tbl[d.seq].ind[cnt_i].index_type = evaluate(trim(validate(i.index_type,"NORMAL")),"",
        "NORMAL",validate(i.index_type,"NORMAL"))
       IF (cnvtupper(currdbuser) != "CDBA")
        IF (cnvtupper(tgtsch->tbl[d.seq].ind[cnt_i].ind_name)=build("XRID",tgtsch->tbl[d.seq].
         table_suffix))
         tgtsch->tbl[d.seq].xrid_ind_fnd = 1
        ENDIF
       ENDIF
       tgtsch->tbl[d.seq].ind[cnt_i].full_ind_name = validate(i.full_ind_name,i.index_name), tgtsch->
       tbl[d.seq].ind[cnt_i].pct_increase = i.pct_increase, tgtsch->tbl[d.seq].ind[cnt_i].pct_free =
       i.pct_free,
       tgtsch->tbl[d.seq].ind[cnt_i].unique_ind = i.unique_ind, cnt_ic = 0
      ENDIF
     ENDIF
    DETAIL
     IF (dtl_obs_obj_idx=0
      AND dtl_obs_obj_idx2=0)
      IF ( NOT (validate(i.index_type,"NORMAL")="FUNCTION-BASED NORMAL"
       AND (dm2_rdbms_version->level1 < 11)))
       cnt_ic = (cnt_ic+ 1)
       IF (mod(cnt_ic,10)=1
        AND cnt_ic != 1)
        stat = alterlist(tgtsch->tbl[d.seq].ind[cnt_i].ind_col,(cnt_ic+ 9))
       ENDIF
       tgtsch->tbl[d.seq].ind[cnt_i].ind_col[cnt_ic].col_name = ic.column_name, tgtsch->tbl[d.seq].
       ind[cnt_i].ind_col[cnt_ic].col_position = ic.column_position
      ENDIF
     ENDIF
    FOOT  i.index_name
     pti_idx = 0, pti_found_ind = 0
     IF (pti_valid_nls=0
      AND dtl_obs_obj_idx=0
      AND dtl_obs_obj_idx2=0)
      FOR (pti_idx = 1 TO size(tgtsch->tbl[d.seq].ind[cnt_i].ind_col,5))
        pti_col_len = textlen(tgtsch->tbl[d.seq].ind[cnt_i].ind_col[pti_idx].col_name)
        IF (findstring("_NLS",tgtsch->tbl[d.seq].ind[cnt_i].ind_col[pti_idx].col_name,(pti_col_len -
         4),1) > 0)
         pti_found_ind = 1
        ENDIF
        pti_col_len = 0
      ENDFOR
      IF (pti_found_ind > 0)
       dtl_obs_obj_idx = 1, stat = alterlist(tgtsch->tbl[d.seq].ind[cnt_i].ind_col,0), cnt_ic = 0,
       CALL echo(concat("Index : ",tgtsch->tbl[d.seq].ind[cnt_i].ind_name,
        " was excluded as it had a NLS column")), cnt_i = (cnt_i - 1), tgtsch->tbl[d.seq].ind_cnt =
       cnt_i,
       stat = alterlist(tgtsch->tbl[d.seq].ind,cnt_i)
      ENDIF
     ENDIF
     IF (dtl_obs_obj_idx=0
      AND dtl_obs_obj_idx2=0)
      IF ( NOT (validate(i.index_type,"NORMAL")="FUNCTION-BASED NORMAL"
       AND (dm2_rdbms_version->level1 < 11)))
       stat = alterlist(tgtsch->tbl[d.seq].ind[cnt_i].ind_col,cnt_ic), tgtsch->tbl[d.seq].ind[cnt_i].
       ind_col_cnt = cnt_ic, cnt_ic = 0
      ENDIF
     ENDIF
    FOOT  i.table_name
     stat = alterlist(tgtsch->tbl[d.seq].ind,cnt_i), tgtsch->tbl[d.seq].ind_cnt = cnt_i
     IF ((tgtsch->tbl[d.seq].rowid_col_fnd=1)
      AND (tgtsch->tbl[d.seq].xrid_ind_fnd=0))
      cnt_i = (cnt_i+ 1), tgtsch->tbl[d.seq].ind_cnt = cnt_i, stat = alterlist(tgtsch->tbl[d.seq].ind,
       cnt_i),
      tgtsch->tbl[d.seq].ind[cnt_i].ind_name = build("XRID",tgtsch->tbl[d.seq].table_suffix), tgtsch
      ->tbl[d.seq].ind[cnt_i].full_ind_name = tgtsch->tbl[d.seq].ind[cnt_i].ind_name, tgtsch->tbl[d
      .seq].ind[cnt_i].pct_increase = 0.0,
      tgtsch->tbl[d.seq].ind[cnt_i].pct_free = 0.0, tgtsch->tbl[d.seq].ind[cnt_i].init_ext = 0.0,
      tgtsch->tbl[d.seq].ind[cnt_i].next_ext = 0.0,
      tgtsch->tbl[d.seq].ind[cnt_i].unique_ind = 1, tgtsch->tbl[d.seq].ind[cnt_i].index_type =
      "NORMAL"
      IF ((tgtsch->tbl[d.seq].ind_cnt > 1))
       tgtsch->tbl[d.seq].ind[cnt_i].bytes_allocated = tgtsch->tbl[d.seq].ind[(cnt_i - 1)].
       bytes_allocated, tgtsch->tbl[d.seq].ind[cnt_i].bytes_used = tgtsch->tbl[d.seq].ind[(cnt_i - 1)
       ].bytes_used
      ELSE
       tgtsch->tbl[d.seq].ind[cnt_i].bytes_allocated = 0.0, tgtsch->tbl[d.seq].ind[cnt_i].bytes_used
        = 0.0
      ENDIF
      tgtsch->tbl[d.seq].ind[cnt_i].ind_col_cnt = 1, stat = alterlist(tgtsch->tbl[d.seq].ind[cnt_i].
       ind_col,1), tgtsch->tbl[d.seq].ind[cnt_i].ind_col[1].col_name = "ROWID",
      tgtsch->tbl[d.seq].ind[cnt_i].ind_col[1].col_position = 1
     ENDIF
     cnt_i = 0
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
   IF (dtl_sd_in_use_ind=1)
    IF (locateval(pti_idx,1,tgtsch->tbl_cnt,1,tgtsch->tbl[pti_idx].pull_from_afd,
     2,tgtsch->tbl[pti_idx].metadata_loc_flg) > 0)
     SET dm_err->eproc = "Retrieving and Loading Index Information via SD tables"
     CALL disp_msg(" ",dm_err->logfile,0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(tgtsch->tbl_cnt)),
       (ceradm.sd_table_inds i),
       (ceradm.sd_table_ind_cols ic)
      PLAN (d
       WHERE (tgtsch->tbl[d.seq].pull_from_afd=1)
        AND (tgtsch->tbl[d.seq].metadata_loc_flg=2))
       JOIN (i
       WHERE i.owner=currdbuser
        AND (i.table_name=tgtsch->tbl[d.seq].tbl_name)
        AND (i.version_nbr=tgtsch->tbl[d.seq].schema_instance))
       JOIN (ic
       WHERE i.version_nbr=ic.version_nbr
        AND i.owner=ic.owner
        AND i.index_name=ic.index_name
        AND i.table_name=ic.table_name)
      ORDER BY i.table_name, i.index_name, ic.position
      HEAD i.table_name
       stat = alterlist(tgtsch->tbl[d.seq].ind,10), tgtsch->tbl[d.seq].ind_cnt = 0, tgtsch->tbl[d.seq
       ].xrid_ind_fnd = 0,
       cnt_i = 0, ind_type_sw = 0
      HEAD i.index_name
       dtl_obs_obj_idx = 0
       IF ((dtl_obs_obj->ind_cnt > 0))
        dtl_obs_obj_idx = locateval(dtl_obs_obj_idx,1,dtl_obs_obj->ind_cnt,i.index_name,dtl_obs_obj->
         ind[dtl_obs_obj_idx].index_name)
       ENDIF
       dtl_obs_obj_idx2 = 0
       IF ((dir_obsolete_objects->ind_cnt > 0)
        AND dtl_obs_obj_idx=0)
        dtl_obs_obj_idx2 = locateval(dtl_obs_obj_idx2,1,dir_obsolete_objects->ind_cnt,i.index_name,
         dir_obsolete_objects->ind[dtl_obs_obj_idx2].index_name)
       ENDIF
       IF (dtl_obs_obj_idx > 0)
        IF ((dm_err->debug_flag > 0))
         CALL echo(build("Conditional Build (index dropped):",i.index_name))
        ENDIF
       ELSEIF (dtl_obs_obj_idx2 > 0)
        dir_dropped_objects->rpt_drp_obj_ind = 1, dir_dropped_objects->obj_cnt = (dir_dropped_objects
        ->obj_cnt+ 1), stat = alterlist(dir_dropped_objects->obj,dir_dropped_objects->obj_cnt),
        dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].table_name = tgtsch->tbl[d.seq].
        tbl_name, dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].name = i.index_name,
        dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].type = "INDEX",
        dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].reason =
        "Obsolete Objects (obsolete index)"
        IF ((dm_err->debug_flag > 0))
         CALL echo(build("Obsolete Objects (obsolete index):",i.index_name))
        ENDIF
       ENDIF
       IF (dtl_obs_obj_idx=0
        AND dtl_obs_obj_idx2=0)
        cnt_i = (cnt_i+ 1), stat = alterlist(tgtsch->tbl[d.seq].ind,cnt_i), stat = alterlist(tgtsch->
         tbl[d.seq].ind[cnt_i].ind_col,10),
        tgtsch->tbl[d.seq].ind[cnt_i].ind_col_cnt = 0, tgtsch->tbl[d.seq].ind[cnt_i].ind_name = i
        .index_name, tgtsch->tbl[d.seq].ind[cnt_i].index_type = i.index_type
        IF (cnvtupper(tgtsch->tbl[d.seq].ind[cnt_i].ind_name)=build("XRID",tgtsch->tbl[d.seq].
         table_suffix))
         tgtsch->tbl[d.seq].xrid_ind_fnd = 1
        ENDIF
        tgtsch->tbl[d.seq].ind[cnt_i].full_ind_name = i.index_name, tgtsch->tbl[d.seq].ind[cnt_i].
        pct_increase = 0, tgtsch->tbl[d.seq].ind[cnt_i].pct_free = 0,
        tgtsch->tbl[d.seq].ind[cnt_i].unique_ind = i.unique_ind, cnt_ic = 0
       ENDIF
      DETAIL
       IF (dtl_obs_obj_idx=0
        AND dtl_obs_obj_idx2=0)
        cnt_ic = (cnt_ic+ 1)
        IF (mod(cnt_ic,10)=1
         AND cnt_ic != 1)
         stat = alterlist(tgtsch->tbl[d.seq].ind[cnt_i].ind_col,(cnt_ic+ 9))
        ENDIF
        tgtsch->tbl[d.seq].ind[cnt_i].ind_col[cnt_ic].col_name = ic.column_name, tgtsch->tbl[d.seq].
        ind[cnt_i].ind_col[cnt_ic].col_position = ic.position
       ENDIF
      FOOT  i.index_name
       pti_idx = 0, pti_found_ind = 0
       IF (pti_valid_nls=0
        AND dtl_obs_obj_idx=0
        AND dtl_obs_obj_idx2=0)
        FOR (pti_idx = 1 TO size(tgtsch->tbl[d.seq].ind[cnt_i].ind_col,5))
          pti_col_len = textlen(tgtsch->tbl[d.seq].ind[cnt_i].ind_col[pti_idx].col_name)
          IF (findstring("_NLS",tgtsch->tbl[d.seq].ind[cnt_i].ind_col[pti_idx].col_name,(pti_col_len
            - 4),1) > 0)
           pti_found_ind = 1
          ENDIF
          pti_col_len = 0
        ENDFOR
        IF (pti_found_ind > 0)
         dtl_obs_obj_idx = 1, stat = alterlist(tgtsch->tbl[d.seq].ind[cnt_i].ind_col,0), cnt_ic = 0,
         CALL echo(concat("Index : ",tgtsch->tbl[d.seq].ind[cnt_i].ind_name,
          " was excluded as it had a NLS column")), cnt_i = (cnt_i - 1), tgtsch->tbl[d.seq].ind_cnt
          = cnt_i,
         stat = alterlist(tgtsch->tbl[d.seq].ind,cnt_i)
        ENDIF
       ENDIF
       IF (dtl_obs_obj_idx=0
        AND dtl_obs_obj_idx2=0)
        stat = alterlist(tgtsch->tbl[d.seq].ind[cnt_i].ind_col,cnt_ic), tgtsch->tbl[d.seq].ind[cnt_i]
        .ind_col_cnt = cnt_ic, cnt_ic = 0
       ENDIF
      FOOT  i.table_name
       stat = alterlist(tgtsch->tbl[d.seq].ind,cnt_i), tgtsch->tbl[d.seq].ind_cnt = cnt_i
       IF ((tgtsch->tbl[d.seq].rowid_col_fnd=1)
        AND (tgtsch->tbl[d.seq].xrid_ind_fnd=0))
        cnt_i = (cnt_i+ 1), tgtsch->tbl[d.seq].ind_cnt = cnt_i, stat = alterlist(tgtsch->tbl[d.seq].
         ind,cnt_i),
        tgtsch->tbl[d.seq].ind[cnt_i].ind_name = build("XRID",tgtsch->tbl[d.seq].table_suffix),
        tgtsch->tbl[d.seq].ind[cnt_i].full_ind_name = tgtsch->tbl[d.seq].ind[cnt_i].ind_name, tgtsch
        ->tbl[d.seq].ind[cnt_i].pct_increase = 0.0,
        tgtsch->tbl[d.seq].ind[cnt_i].pct_free = 0.0, tgtsch->tbl[d.seq].ind[cnt_i].init_ext = 0.0,
        tgtsch->tbl[d.seq].ind[cnt_i].next_ext = 0.0,
        tgtsch->tbl[d.seq].ind[cnt_i].unique_ind = 1, tgtsch->tbl[d.seq].ind[cnt_i].index_type =
        "NORMAL"
        IF ((tgtsch->tbl[d.seq].ind_cnt > 1))
         tgtsch->tbl[d.seq].ind[cnt_i].bytes_allocated = tgtsch->tbl[d.seq].ind[(cnt_i - 1)].
         bytes_allocated, tgtsch->tbl[d.seq].ind[cnt_i].bytes_used = tgtsch->tbl[d.seq].ind[(cnt_i -
         1)].bytes_used
        ELSE
         tgtsch->tbl[d.seq].ind[cnt_i].bytes_allocated = 0.0, tgtsch->tbl[d.seq].ind[cnt_i].
         bytes_used = 0.0
        ENDIF
        tgtsch->tbl[d.seq].ind[cnt_i].ind_col_cnt = 1, stat = alterlist(tgtsch->tbl[d.seq].ind[cnt_i]
         .ind_col,1), tgtsch->tbl[d.seq].ind[cnt_i].ind_col[1].col_name = "ROWID",
        tgtsch->tbl[d.seq].ind[cnt_i].ind_col[1].col_position = 1
       ENDIF
       cnt_i = 0
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ENDIF
    ENDIF
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(null)
   ENDIF
   IF ((drr_clin_copy_data->process != "RESTORE"))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(tgtsch->tbl_cnt))
     PLAN (d
      WHERE (tgtsch->tbl[d.seq].ind_cnt=0))
     DETAIL
      IF ((tgtsch->tbl[d.seq].rowid_col_fnd=1))
       cnt_i = 1, tgtsch->tbl[d.seq].ind_cnt = cnt_i, stat = alterlist(tgtsch->tbl[d.seq].ind,cnt_i),
       tgtsch->tbl[d.seq].ind[cnt_i].ind_name = build("XRID",tgtsch->tbl[d.seq].table_suffix), tgtsch
       ->tbl[d.seq].ind[cnt_i].full_ind_name = tgtsch->tbl[d.seq].ind[cnt_i].ind_name, tgtsch->tbl[d
       .seq].ind[cnt_i].pct_increase = 0.0,
       tgtsch->tbl[d.seq].ind[cnt_i].pct_free = 0.0, tgtsch->tbl[d.seq].ind[cnt_i].init_ext = 0.0,
       tgtsch->tbl[d.seq].ind[cnt_i].next_ext = 0.0,
       tgtsch->tbl[d.seq].ind[cnt_i].unique_ind = 1, tgtsch->tbl[d.seq].ind[cnt_i].bytes_allocated =
       0.0, tgtsch->tbl[d.seq].ind[cnt_i].bytes_used = 0.0,
       tgtsch->tbl[d.seq].ind[cnt_i].index_type = "NORMAL", tgtsch->tbl[d.seq].ind[cnt_i].ind_col_cnt
        = 1, stat = alterlist(tgtsch->tbl[d.seq].ind[cnt_i].ind_col,1),
       tgtsch->tbl[d.seq].ind[cnt_i].ind_col[1].col_name = "ROWID", tgtsch->tbl[d.seq].ind[cnt_i].
       ind_col[1].col_position = 1
      ENDIF
      cnt_i = 0
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE populate_tbl_constraints(null)
   DECLARE cnt_c = i4 WITH protect, noconstant(0)
   DECLARE cnt_cc = i4 WITH protect, noconstant(0)
   DECLARE ptc_tmp_parent_table = vc WITH protect, noconstant(" ")
   DECLARE ptc_fk_tbl_idx = i4 WITH protect, noconstant(0)
   DECLARE ptc_fk_tbl_idx2 = i4 WITH protect, noconstant(0)
   DECLARE ptc_idx = i4 WITH protect, noconstant(0)
   SET dtl_max_c_cnt = 0
   SET dm_err->eproc = "Retrieving and Loading Constraint Information."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT
    IF (dtl_src_of_data="A")
     FROM (dummyt d  WITH seq = value(tgtsch->tbl_cnt)),
      dm_afd_constraints c,
      dm_afd_cons_columns cc
     PLAN (d
      WHERE (tgtsch->tbl[d.seq].pull_from_afd=1)
       AND (tgtsch->tbl[d.seq].metadata_loc_flg=1))
      JOIN (c
      WHERE c.owner=currdbuser
       AND (c.table_name=tgtsch->tbl[d.seq].tbl_name)
       AND (c.alpha_feature_nbr=tgtsch->tbl[d.seq].alpha_feature_nbr))
      JOIN (cc
      WHERE c.alpha_feature_nbr=cc.alpha_feature_nbr
       AND c.owner=cc.owner
       AND c.constraint_name=cc.constraint_name
       AND cc.table_name=c.table_name)
    ELSEIF ((dm2_install_schema->process_option="INHOUSE"))
     FROM dm_adm_constraints c,
      dm_adm_cons_columns cc,
      (dummyt d  WITH seq = value(tgtsch->tbl_cnt))
     PLAN (d)
      JOIN (c
      WHERE (tgtsch->tbl[d.seq].orig_tbl_name=c.table_name)
       AND c.schema_date=cnvtdatetime(inhouse_reply->schema_date)
       AND c.owner=currdbuser
       AND c.delete_ind=0)
      JOIN (cc
      WHERE c.schema_date=cc.schema_date
       AND c.constraint_name=cc.constraint_name
       AND c.table_name=cc.table_name
       AND c.owner=cc.owner)
    ELSE
     FROM dmcons c,
      dmconscol cc,
      (dummyt d  WITH seq = value(tgtsch->tbl_cnt))
     PLAN (d)
      JOIN (c
      WHERE (tgtsch->tbl[d.seq].orig_tbl_name=c.table_name))
      JOIN (cc
      WHERE c.constraint_name=cc.constraint_name
       AND c.table_name=cc.table_name)
    ENDIF
    INTO "nl:"
    c.table_name
    ORDER BY c.table_name, c.constraint_name, cc.position
    HEAD REPORT
     MACRO (convert_cons_status)
      IF (c.constraint_type="R"
       AND currdbuser="V500")
       IF ((dm2_install_schema->process_option="INHOUSE")
        AND dtl_fk_ind=0)
        IF ((dtl_fk_tbl->cnt > 0))
         ptc_fk_tbl_idx = locateval(ptc_fk_tbl_idx2,1,dtl_fk_tbl->cnt,tgtsch->tbl[d.seq].tbl_name,
          dtl_fk_tbl->list[ptc_fk_tbl_idx2].table_name)
         IF (ptc_fk_tbl_idx > 0)
          tgtsch->tbl[d.seq].cons[cnt_c].status_ind = 0
         ELSE
          tgtsch->tbl[d.seq].cons[cnt_c].status_ind = 1
         ENDIF
        ELSE
         tgtsch->tbl[d.seq].cons[cnt_c].status_ind = 1
        ENDIF
       ELSE
        tgtsch->tbl[d.seq].cons[cnt_c].status_ind = 0
       ENDIF
      ELSE
       tgtsch->tbl[d.seq].cons[cnt_c].status_ind = c.status_ind
      ENDIF
     ENDMACRO
    HEAD c.table_name
     stat = alterlist(tgtsch->tbl[d.seq].cons,10), tgtsch->tbl[d.seq].cons_cnt = 0, cnt_c = 0
    HEAD c.constraint_name
     dtl_obs_obj_idx = 0, dtl_obs_obj_idx2 = 0, ptc_tmp_parent_table = " "
     IF (c.constraint_type="R")
      ptc_tmp_parent_table = c.parent_table_name
      IF ((dtl_obs_obj->tbl_cnt > 0))
       dtl_obs_obj_idx = locateval(dtl_obs_obj_idx,1,dtl_obs_obj->tbl_cnt,ptc_tmp_parent_table,
        dtl_obs_obj->tbl[dtl_obs_obj_idx].table_name)
      ENDIF
      dtl_obs_obj_idx2 = 0
      IF ((dir_obsolete_objects->tbl_cnt > 0)
       AND dtl_obs_obj_idx=0)
       dtl_obs_obj_idx2 = locateval(dtl_obs_obj_idx2,1,dir_obsolete_objects->tbl_cnt,
        ptc_tmp_parent_table,dir_obsolete_objects->tbl[dtl_obs_obj_idx2].table_name)
      ENDIF
      IF (dtl_obs_obj_idx > 0)
       IF ((dm_err->debug_flag > 0))
        CALL echo(build("Conditional Build (parent table dropped):",c.constraint_name))
       ENDIF
      ELSEIF (dtl_obs_obj_idx2 > 0)
       dir_dropped_objects->rpt_drp_obj_ind = 1, dir_dropped_objects->obj_cnt = (dir_dropped_objects
       ->obj_cnt+ 1), stat = alterlist(dir_dropped_objects->obj,dir_dropped_objects->obj_cnt),
       dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].table_name = tgtsch->tbl[d.seq].
       tbl_name, dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].name = c.constraint_name,
       dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].type = "CONSTRAINT",
       dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].reason =
       "Obsolete Objects (obsolete parent table)"
       IF ((dm_err->debug_flag > 0))
        CALL echo(build("Obsolete Objects (obsolete parent table):",c.constraint_name))
       ENDIF
      ENDIF
      IF ((dm_err->debug_flag > 1))
       CALL echo(concat("FK Parent Table translated: ",ptc_tmp_parent_table))
      ENDIF
     ENDIF
     IF (dtl_obs_obj_idx=0
      AND dtl_obs_obj_idx2=0)
      dtl_obs_obj_idx = 0
      IF ((dir_obsolete_objects->con_cnt > 0))
       dtl_obs_obj_idx = locateval(dtl_obs_obj_idx,1,dir_obsolete_objects->con_cnt,c.constraint_name,
        dir_obsolete_objects->con[dtl_obs_obj_idx].constraint_name)
      ENDIF
      IF (c.constraint_type != "R")
       dtl_obs_obj_idx2 = 0
       IF ((dir_obsolete_objects->ind_cnt > 0)
        AND dtl_obs_obj_idx=0)
        dtl_obs_obj_idx2 = locateval(dtl_obs_obj_idx2,1,dir_obsolete_objects->ind_cnt,c
         .constraint_name,dir_obsolete_objects->ind[dtl_obs_obj_idx2].index_name)
       ENDIF
      ENDIF
      IF (dtl_obs_obj_idx > 0)
       dir_dropped_objects->rpt_drp_obj_ind = 1, dir_dropped_objects->obj_cnt = (dir_dropped_objects
       ->obj_cnt+ 1), stat = alterlist(dir_dropped_objects->obj,dir_dropped_objects->obj_cnt),
       dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].table_name = tgtsch->tbl[d.seq].
       tbl_name, dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].name = c.constraint_name,
       dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].type = "CONSTRAINT",
       dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].reason =
       "Obsolete Objects (obsolete constraint)"
       IF ((dm_err->debug_flag > 0))
        CALL echo(build("Obsolete Objects (obsolete constraint):",c.constraint_name))
       ENDIF
      ELSEIF (dtl_obs_obj_idx2 > 0)
       dir_dropped_objects->rpt_drp_obj_ind = 1, dir_dropped_objects->obj_cnt = (dir_dropped_objects
       ->obj_cnt+ 1), stat = alterlist(dir_dropped_objects->obj,dir_dropped_objects->obj_cnt),
       dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].table_name = tgtsch->tbl[d.seq].
       tbl_name, dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].name = c.constraint_name,
       dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].type = "CONSTRAINT",
       dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].reason =
       "Obsolete Objects (obsolete index)"
       IF ((dm_err->debug_flag > 0))
        CALL echo(build("Obsolete Objects (obsolete index):",c.constraint_name))
       ENDIF
      ENDIF
     ENDIF
     IF (dtl_obs_obj_idx=0
      AND dtl_obs_obj_idx2=0)
      cnt_c = (cnt_c+ 1)
      IF (mod(cnt_c,10)=1
       AND cnt_c != 1)
       stat = alterlist(tgtsch->tbl[d.seq].cons,(cnt_c+ 9))
      ENDIF
      stat = alterlist(tgtsch->tbl[d.seq].cons[cnt_c].cons_col,10), tgtsch->tbl[d.seq].cons[cnt_c].
      cons_col_cnt = 0, tgtsch->tbl[d.seq].cons[cnt_c].cons_name = c.constraint_name
      IF (dtl_src_of_data="A")
       tgtsch->tbl[d.seq].cons[cnt_c].status_ind = c.status_ind, tgtsch->tbl[d.seq].cons[cnt_c].
       r_constraint_name = c.r_constraint_name
      ELSE
       tgtsch->tbl[d.seq].cons[cnt_c].cons_name = c.constraint_name, tgtsch->tbl[d.seq].cons[cnt_c].
       r_constraint_name = c.r_constraint_name, convert_cons_status
      ENDIF
      tgtsch->tbl[d.seq].cons[cnt_c].index_idx = 0, tgtsch->tbl[d.seq].cons[cnt_c].full_cons_name =
      validate(c.full_cons_name,c.constraint_name), tgtsch->tbl[d.seq].cons[cnt_c].cons_type = c
      .constraint_type,
      tgtsch->tbl[d.seq].cons[cnt_c].parent_table = ptc_tmp_parent_table, tgtsch->tbl[d.seq].cons[
      cnt_c].parent_table_columns = c.parent_table_columns, cnt_cc = 0,
      tgtsch->tbl[d.seq].cons[cnt_c].delete_rule = ""
      IF (c.constraint_type="R")
       tgtsch->tbl[d.seq].cons[cnt_c].delete_rule = evaluate(trim(validate(c.delete_rule,"NO ACTION")
         ),"","NO ACTION",validate(c.delete_rule,"NO ACTION"))
      ENDIF
     ENDIF
    DETAIL
     IF (dtl_obs_obj_idx=0
      AND dtl_obs_obj_idx2=0)
      cnt_cc = (cnt_cc+ 1)
      IF (mod(cnt_cc,10)=1
       AND cnt_cc != 1)
       stat = alterlist(tgtsch->tbl[d.seq].cons[cnt_c].cons_col,(cnt_cc+ 9))
      ENDIF
      tgtsch->tbl[d.seq].cons[cnt_c].cons_col[cnt_cc].col_name = cc.column_name, tgtsch->tbl[d.seq].
      cons[cnt_c].cons_col[cnt_cc].col_position = cc.position
     ENDIF
    FOOT  c.constraint_name
     IF (dtl_obs_obj_idx=0
      AND dtl_obs_obj_idx2=0)
      stat = alterlist(tgtsch->tbl[d.seq].cons[cnt_c].cons_col,cnt_cc), tgtsch->tbl[d.seq].cons[cnt_c
      ].cons_col_cnt = cnt_cc, cnt_cc = 0
     ENDIF
    FOOT  c.table_name
     stat = alterlist(tgtsch->tbl[d.seq].cons,cnt_c), tgtsch->tbl[d.seq].cons_cnt = cnt_c, cnt_c = 0
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
   IF (dtl_sd_in_use_ind=1)
    IF (locateval(ptc_idx,1,tgtsch->tbl_cnt,1,tgtsch->tbl[ptc_idx].pull_from_afd,
     2,tgtsch->tbl[ptc_idx].metadata_loc_flg) > 0)
     SET dm_err->eproc = "Retrieving and Loading Constraint Information via SD tables."
     CALL disp_msg(" ",dm_err->logfile,0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(tgtsch->tbl_cnt)),
       (ceradm.sd_table_cons c),
       (ceradm.sd_table_con_cols cc)
      PLAN (d
       WHERE (tgtsch->tbl[d.seq].pull_from_afd=1)
        AND (tgtsch->tbl[d.seq].metadata_loc_flg=2))
       JOIN (c
       WHERE c.owner=currdbuser
        AND (c.table_name=tgtsch->tbl[d.seq].tbl_name)
        AND (c.version_nbr=tgtsch->tbl[d.seq].schema_instance))
       JOIN (cc
       WHERE c.version_nbr=cc.version_nbr
        AND c.owner=cc.owner
        AND c.constraint_name=cc.constraint_name
        AND cc.table_name=c.table_name)
      ORDER BY c.table_name, c.constraint_name, cc.position
      HEAD c.table_name
       stat = alterlist(tgtsch->tbl[d.seq].cons,10), tgtsch->tbl[d.seq].cons_cnt = 0, cnt_c = 0
      HEAD c.constraint_name
       dtl_obs_obj_idx = 0, dtl_obs_obj_idx2 = 0, ptc_tmp_parent_table = " "
       IF (c.constraint_type="R")
        ptc_tmp_parent_table = c.parent_table_name
        IF ((dtl_obs_obj->tbl_cnt > 0))
         dtl_obs_obj_idx = locateval(dtl_obs_obj_idx,1,dtl_obs_obj->tbl_cnt,ptc_tmp_parent_table,
          dtl_obs_obj->tbl[dtl_obs_obj_idx].table_name)
        ENDIF
        dtl_obs_obj_idx2 = 0
        IF ((dir_obsolete_objects->tbl_cnt > 0)
         AND dtl_obs_obj_idx=0)
         dtl_obs_obj_idx2 = locateval(dtl_obs_obj_idx2,1,dir_obsolete_objects->tbl_cnt,
          ptc_tmp_parent_table,dir_obsolete_objects->tbl[dtl_obs_obj_idx2].table_name)
        ENDIF
        IF (dtl_obs_obj_idx > 0)
         IF ((dm_err->debug_flag > 0))
          CALL echo(build("Conditional Build (parent table dropped):",c.constraint_name))
         ENDIF
        ELSEIF (dtl_obs_obj_idx2 > 0)
         dir_dropped_objects->rpt_drp_obj_ind = 1, dir_dropped_objects->obj_cnt = (
         dir_dropped_objects->obj_cnt+ 1), stat = alterlist(dir_dropped_objects->obj,
          dir_dropped_objects->obj_cnt),
         dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].table_name = tgtsch->tbl[d.seq].
         tbl_name, dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].name = c.constraint_name,
         dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].type = "CONSTRAINT",
         dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].reason =
         "Obsolete Objects (obsolete parent table)"
         IF ((dm_err->debug_flag > 0))
          CALL echo(build("Obsolete Objects (obsolete parent table):",c.constraint_name))
         ENDIF
        ENDIF
        IF ((dm_err->debug_flag > 1))
         CALL echo(concat("FK Parent Table translated: ",ptc_tmp_parent_table))
        ENDIF
       ENDIF
       IF (dtl_obs_obj_idx=0
        AND dtl_obs_obj_idx2=0)
        dtl_obs_obj_idx = 0
        IF ((dir_obsolete_objects->con_cnt > 0))
         dtl_obs_obj_idx = locateval(dtl_obs_obj_idx,1,dir_obsolete_objects->con_cnt,c
          .constraint_name,dir_obsolete_objects->con[dtl_obs_obj_idx].constraint_name)
        ENDIF
        IF (c.constraint_type != "R")
         dtl_obs_obj_idx2 = 0
         IF ((dir_obsolete_objects->ind_cnt > 0)
          AND dtl_obs_obj_idx=0)
          dtl_obs_obj_idx2 = locateval(dtl_obs_obj_idx2,1,dir_obsolete_objects->ind_cnt,c
           .constraint_name,dir_obsolete_objects->ind[dtl_obs_obj_idx2].index_name)
         ENDIF
        ENDIF
        IF (dtl_obs_obj_idx > 0)
         dir_dropped_objects->rpt_drp_obj_ind = 1, dir_dropped_objects->obj_cnt = (
         dir_dropped_objects->obj_cnt+ 1), stat = alterlist(dir_dropped_objects->obj,
          dir_dropped_objects->obj_cnt),
         dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].table_name = tgtsch->tbl[d.seq].
         tbl_name, dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].name = c.constraint_name,
         dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].type = "CONSTRAINT",
         dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].reason =
         "Obsolete Objects (obsolete constraint)"
         IF ((dm_err->debug_flag > 0))
          CALL echo(build("Obsolete Objects (obsolete constraint):",c.constraint_name))
         ENDIF
        ELSEIF (dtl_obs_obj_idx2 > 0)
         dir_dropped_objects->rpt_drp_obj_ind = 1, dir_dropped_objects->obj_cnt = (
         dir_dropped_objects->obj_cnt+ 1), stat = alterlist(dir_dropped_objects->obj,
          dir_dropped_objects->obj_cnt),
         dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].table_name = tgtsch->tbl[d.seq].
         tbl_name, dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].name = c.constraint_name,
         dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].type = "CONSTRAINT",
         dir_dropped_objects->obj[dir_dropped_objects->obj_cnt].reason =
         "Obsolete Objects (obsolete index)"
         IF ((dm_err->debug_flag > 0))
          CALL echo(build("Obsolete Objects (obsolete index):",c.constraint_name))
         ENDIF
        ENDIF
       ENDIF
       IF (dtl_obs_obj_idx=0
        AND dtl_obs_obj_idx2=0)
        cnt_c = (cnt_c+ 1)
        IF (mod(cnt_c,10)=1
         AND cnt_c != 1)
         stat = alterlist(tgtsch->tbl[d.seq].cons,(cnt_c+ 9))
        ENDIF
        stat = alterlist(tgtsch->tbl[d.seq].cons[cnt_c].cons_col,10), tgtsch->tbl[d.seq].cons[cnt_c].
        cons_col_cnt = 0, tgtsch->tbl[d.seq].cons[cnt_c].cons_name = c.constraint_name,
        tgtsch->tbl[d.seq].cons[cnt_c].status_ind = c.status_ind, tgtsch->tbl[d.seq].cons[cnt_c].
        r_constraint_name = c.r_constraint_name, tgtsch->tbl[d.seq].cons[cnt_c].index_idx = 0,
        tgtsch->tbl[d.seq].cons[cnt_c].full_cons_name = c.constraint_name, tgtsch->tbl[d.seq].cons[
        cnt_c].cons_type = c.constraint_type, tgtsch->tbl[d.seq].cons[cnt_c].parent_table =
        ptc_tmp_parent_table,
        tgtsch->tbl[d.seq].cons[cnt_c].parent_table_columns = c.parent_table_columns, cnt_cc = 0,
        tgtsch->tbl[d.seq].cons[cnt_c].delete_rule = ""
        IF (c.constraint_type="R")
         tgtsch->tbl[d.seq].cons[cnt_c].delete_rule = c.delete_rule
        ENDIF
       ENDIF
      DETAIL
       IF (dtl_obs_obj_idx=0
        AND dtl_obs_obj_idx2=0)
        cnt_cc = (cnt_cc+ 1)
        IF (mod(cnt_cc,10)=1
         AND cnt_cc != 1)
         stat = alterlist(tgtsch->tbl[d.seq].cons[cnt_c].cons_col,(cnt_cc+ 9))
        ENDIF
        tgtsch->tbl[d.seq].cons[cnt_c].cons_col[cnt_cc].col_name = cc.column_name, tgtsch->tbl[d.seq]
        .cons[cnt_c].cons_col[cnt_cc].col_position = cc.position
       ENDIF
      FOOT  c.constraint_name
       IF (dtl_obs_obj_idx=0
        AND dtl_obs_obj_idx2=0)
        stat = alterlist(tgtsch->tbl[d.seq].cons[cnt_c].cons_col,cnt_cc), tgtsch->tbl[d.seq].cons[
        cnt_c].cons_col_cnt = cnt_cc, cnt_cc = 0
       ENDIF
      FOOT  c.table_name
       stat = alterlist(tgtsch->tbl[d.seq].cons,cnt_c), tgtsch->tbl[d.seq].cons_cnt = cnt_c, cnt_c =
       0
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE check_whether_to_load_afd(null)
   DECLARE dtl_tbl_cnt = i2
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Pulling package afd rows from admin into record structure."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_afd_tables t
    WHERE (t.alpha_feature_nbr=tgtsch->alpha_feature_nbr)
     AND t.owner=currdbuser
    HEAD REPORT
     stat = alterlist(dtl_tmp_tbls->tbl,10), dtl_tmp_tbls->tbl_cnt = 0
    DETAIL
     dtl_tmp_tbls->tbl_cnt = (dtl_tmp_tbls->tbl_cnt+ 1)
     IF (mod(dtl_tmp_tbls->tbl_cnt,10)=1
      AND (dtl_tmp_tbls->tbl_cnt != 1))
      stat = alterlist(dtl_tmp_tbls->tbl,(dtl_tmp_tbls->tbl_cnt+ 9))
     ENDIF
     dtl_tmp_tbls->tbl[dtl_tmp_tbls->tbl_cnt].tbl_name = t.table_name, dtl_tmp_tbls->tbl[dtl_tmp_tbls
     ->tbl_cnt].schema_instance = t.schema_instance
    FOOT REPORT
     stat = alterlist(dtl_tmp_tbls->tbl,dtl_tmp_tbls->tbl_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ELSEIF (curqual=0)
    IF ((dm_err->debug_flag > 0))
     CALL echo("Package not yet loaded to afd tables in admin")
    ENDIF
    RETURN(null)
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
   FOR (dtl_tbl_idx = 1 TO tgtsch->tbl_cnt)
     SET dtl_tbl_cnt = 0
     SET dtl_tbl_cnt = locateval(dtl_tbl_cnt,1,dtl_tmp_tbls->tbl_cnt,tgtsch->tbl[dtl_tbl_idx].
      tbl_name,dtl_tmp_tbls->tbl[dtl_tbl_cnt].tbl_name)
     IF (dtl_tbl_cnt=0)
      IF ((dm_err->debug_flag > 0))
       CALL echo("Table in target record structure but not in dm_afd_tables")
      ENDIF
      RETURN(null)
     ELSEIF ((tgtsch->tbl[dtl_tbl_idx].schema_instance != dtl_tmp_tbls->tbl[dtl_tbl_cnt].
     schema_instance))
      IF ((dm_err->debug_flag > 0))
       CALL echo("Schema instances different between package schema and afd tables in admin")
      ENDIF
      RETURN(null)
     ENDIF
   ENDFOR
   FOR (dtl_tbl_idx = 1 TO dtl_tmp_tbls->tbl_cnt)
     SET dtl_tbl_cnt = 0
     SET dtl_tbl_cnt = locateval(dtl_tbl_cnt,1,tgtsch->tbl_cnt,dtl_tmp_tbls->tbl[dtl_tbl_idx].
      tbl_name,tgtsch->tbl[dtl_tbl_cnt].tbl_name)
     IF (dtl_tbl_cnt=0)
      IF ((dm_err->debug_flag > 0))
       CALL echo("Table in dm_afd_tables but not in target record structure")
      ENDIF
      RETURN(null)
     ENDIF
   ENDFOR
   SET dtl_schema_loaded = 1
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("Schema for package <",tgtsch->alpha_feature_nbr,"> already loaded to afd"))
   ENDIF
 END ;Subroutine
 SUBROUTINE check_whether_to_load_admin_to_afd(null)
   DECLARE cwtlata_csv_rows = i4 WITH protect, noconstant(0)
   DECLARE cwtlata_row_count = f8 WITH protect, noconstant(0.0)
   DECLARE cwtlata_file_name = vc WITH protect, noconstant(" ")
   SET dm_err->eproc = "Determine if Admin afd rows exist for current set of csv files."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    tmpcnt = count(*)
    FROM dm_afd_tables t
    WHERE (t.alpha_feature_nbr=tgtsch->alpha_feature_nbr)
     AND t.owner=currdbuser
    DETAIL
     cwtlata_row_count = tmpcnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ELSEIF (cwtlata_row_count=0)
    IF ((dm_err->debug_flag > 0))
     CALL echo("Admin csv schema not yet loaded to afd tables in admin")
    ENDIF
    RETURN(null)
   ENDIF
   SET cwtlata_csv_rows = 0
   SET cwtlata_file_name = build(dm2_install_schema->cer_install,dm2_sch_file->file_prefix,
    dcfr_csv_file->qual[2].file_suffix,".csv")
   IF (dcfr_get_csv_row_cnt(cwtlata_file_name,cwtlata_csv_rows)=0)
    RETURN(0)
   ENDIF
   IF (cwtlata_row_count != cwtlata_csv_rows)
    IF ((dm_err->debug_flag > 0))
     CALL echo("Admin csv schema not completely loaded to afd tables in admin")
    ENDIF
    RETURN(null)
   ENDIF
   SET dtl_schema_loaded = 1
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("Schema for Admin <",tgtsch->alpha_feature_nbr,"> already loaded to afd"))
   ENDIF
 END ;Subroutine
 SUBROUTINE insert_afd_row_for_table_info(null)
   SET dm_err->eproc = "Deleting AFD table rows...."
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dtl_incl_excl_ind=0)
    SET dtl_adm_maint_str = concat("delete from DM_AFD_TABLES da ",
     " where da.alpha_feature_nbr = tgtsch->alpha_feature_nbr","   and da.owner = currdbuser",
     " with nocounter go")
   ELSE
    SET dtl_adm_maint_str = concat(
     "delete from DM_AFD_TABLES da, (dummyt d with seq = value(tgtsch->tbl_cnt))"," set da.seq = 1 ",
     " plan d "," join da where da.table_name = tgtsch->tbl[d.seq]->tbl_name",
     "           and da.owner = currdbuser",
     "           and da.alpha_feature_nbr = tgtsch->alpha_feature_nbr"," with nocounter go")
   ENDIF
   IF (dm2_push_adm_maint(dtl_adm_maint_str)=0)
    ROLLBACK
    RETURN(null)
   ELSE
    COMMIT
   ENDIF
   CALL delete_insert_constraints(null)
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   CALL delete_insert_cons_columns(null)
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   CALL delete_insert_indexes(null)
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   CALL delete_insert_ind_columns(null)
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   CALL delete_insert_column(null)
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   CALL delete_insert_table(null)
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE delete_insert_table(null)
   SET dm_err->eproc = "Inserting AFD table rows...."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dtl_adm_maint_str = concat(
    "insert into DM_AFD_TABLES da, (dummyt d with seq = value(tgtsch->tbl_cnt))",
    " set da.table_name =  tgtsch->tbl[d.seq].tbl_name",
    ", da.pct_increase = tgtsch->tbl[d.seq].pct_increase",
    ", da.pct_used = tgtsch->tbl[d.seq].pct_used",", da.pct_free = tgtsch->tbl[d.seq].pct_free",
    ", da.updt_applctx = 0",", da.updt_dt_tm = cnvtdatetime(tgtsch->tbl[d.seq].updt_dt_tm)",
    ", da.updt_cnt = 0",", da.updt_id = 0",", da.updt_task = 0",
    ", da.alpha_feature_nbr = tgtsch->alpha_feature_nbr",
    ", da.feature_number = tgtsch->tbl[d.seq].feature_number",
    ", da.schema_date = cnvtdatetime(tgtsch->tbl[d.seq].schema_date)",
    ", da.schema_instance = tgtsch->tbl[d.seq].schema_instance",", da.owner = currdbuser",
    " plan d "," join da where da.table_name = tgtsch->tbl[d.seq]->tbl_name ",
    "           and da.owner = currdbuser ",
    "           and da.alpha_feature_nbr = tgtsch->alpha_feature_nbr",
    "  with nocounter, outerjoin = d, dontexist go")
   IF (dm2_push_adm_maint(dtl_adm_maint_str)=0)
    ROLLBACK
    RETURN(null)
   ELSE
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE delete_insert_column(null)
   SET dm_err->eproc = "Deleting AFD column rows...."
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dtl_incl_excl_ind=0)
    SET dtl_adm_maint_str = concat("delete from DM_AFD_COLUMNS c ",
     " where c.alpha_feature_nbr = tgtsch->alpha_feature_nbr","   and c.owner = currdbuser",
     " with nocounter go")
   ELSE
    SET dtl_adm_maint_str = concat(
     "delete from DM_AFD_COLUMNS c, (dummyt d with seq = value(tgtsch->tbl_cnt)) "," set c.seq = 1 ",
     " plan d "," join c where c.table_name = tgtsch->tbl[d.seq]->tbl_name",
     "          and c.owner = currdbuser",
     "          and c.alpha_feature_nbr = tgtsch->alpha_feature_nbr"," with nocounter go")
   ENDIF
   IF (dm2_push_adm_maint(dtl_adm_maint_str)=0)
    ROLLBACK
    RETURN(null)
   ELSE
    COMMIT
   ENDIF
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(tgtsch->tbl_cnt))
    PLAN (d)
    DETAIL
     IF ((tgtsch->tbl[d.seq].tbl_col_cnt > dtl_max_tc_cnt))
      dtl_max_tc_cnt = tgtsch->tbl[d.seq].tbl_col_cnt
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error("Finding largest column count in record structure")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   SET dm_err->eproc = "Inserting AFD column rows...."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dtl_adm_maint_str = concat(
    "insert into DM_AFD_COLUMNS c, (dummyt d with seq = value(tgtsch->tbl_cnt)), ",
    "                      (dummyt d2 with seq = value(dtl_max_tc_cnt)) "," set",
    "  c.table_name = tgtsch->tbl[d.seq].tbl_name",
    ", c.column_name = tgtsch->tbl[d.seq].tbl_col[d2.seq].col_name",
    ", c.column_seq = tgtsch->tbl[d.seq].tbl_col[d2.seq].col_seq",
    ", c.data_type = evaluate(tgtsch->tbl[d.seq].tbl_col[d2.seq].data_type,",
    "'DECIMAL(38,10)','DECIMAL',tgtsch->tbl[d.seq].tbl_col[d2.seq].data_type)",
    ", c.data_length = tgtsch->tbl[d.seq].tbl_col[d2.seq].data_length",
    ", c.nullable = tgtsch->tbl[d.seq].tbl_col[d2.seq].nullable",
    ", c.updt_applctx = 0",", c.updt_dt_tm = cnvtdatetime(tgtsch->tbl[d.seq].updt_dt_tm)",
    ", c.updt_cnt = 0",", c.updt_id = 0",", c.updt_task = 0",
    ", c.data_default = evaluate(tgtsch->tbl[d.seq].tbl_col[d2.seq].data_default_ni,1,NULL,",
    "0,tgtsch->tbl[d.seq].tbl_col[d2.seq].data_default)",
    ", c.alpha_feature_nbr = tgtsch->alpha_feature_nbr",", c.owner = currdbuser"," plan d ",
    " join d2 where d2.seq <= tgtsch->tbl[d.seq]->tbl_col_cnt",
    " join c where c.table_name = tgtsch->tbl[d.seq]->tbl_name","          and c.owner = currdbuser ",
    "          and c.alpha_feature_nbr = tgtsch->alpha_feature_nbr",
    "          and c.column_name = tgtsch->tbl[d.seq].tbl_col[d2.seq].col_name",
    " with nocounter, maxcommit = 5000, outerjoin = d2, dontexist go")
   IF (dm2_push_adm_maint(dtl_adm_maint_str)=0)
    ROLLBACK
    RETURN(null)
   ELSE
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE delete_insert_indexes(null)
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(tgtsch->tbl_cnt))
    PLAN (d)
    DETAIL
     IF ((tgtsch->tbl[d.seq].ind_cnt > dtl_max_i_cnt))
      dtl_max_i_cnt = tgtsch->tbl[d.seq].ind_cnt
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error("Finding largest index count in record structure")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   IF (dtl_max_i_cnt > 0)
    SET dm_err->eproc = "Deleting AFD index rows...."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (dtl_incl_excl_ind=0)
     SET dtl_adm_maint_str = concat("delete from DM_AFD_INDEXES i ",
      " where i.alpha_feature_nbr = tgtsch->alpha_feature_nbr","   and i.owner = currdbuser",
      " with nocounter go")
    ELSE
     SET dtl_adm_maint_str = concat(
      "delete from DM_AFD_INDEXES i, (dummyt d with seq = value(tgtsch->tbl_cnt)) "," set i.seq = 1 ",
      " plan d "," join i where i.table_name = tgtsch->tbl[d.seq]->tbl_name",
      "          and i.owner = currdbuser",
      "          and i.alpha_feature_nbr = tgtsch->alpha_feature_nbr"," with nocounter go")
    ENDIF
    IF (dm2_push_adm_maint(dtl_adm_maint_str)=0)
     ROLLBACK
     RETURN(null)
    ELSE
     COMMIT
    ENDIF
    SET dm_err->eproc = "Inserting AFD index rows...."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dtl_adm_maint_str = concat("insert into DM_AFD_INDEXES i, ",
     "  (dummyt d with seq = value(tgtsch->tbl_cnt)), ",
     "  (dummyt d2 with seq = value(dtl_max_i_cnt)) ","set ",
     "  i.index_name = tgtsch->tbl[d.seq].ind[d2.seq].ind_name",
     ", i.table_name = tgtsch->tbl[d.seq].tbl_name",
     ", i.pct_increase = tgtsch->tbl[d.seq].ind[d2.seq].pct_increase",
     ", i.pct_free = tgtsch->tbl[d.seq].ind[d2.seq].pct_free",
     ", i.unique_ind = tgtsch->tbl[d.seq].ind[d2.seq].unique_ind",", i.updt_applctx = 0",
     ", i.updt_dt_tm = cnvtdatetime(tgtsch->tbl[d.seq].updt_dt_tm)",", i.updt_cnt = 0",
     ", i.updt_id = 0",", i.updt_task = 0",", i.alpha_feature_nbr = tgtsch->alpha_feature_nbr",
     ", i.full_ind_name = tgtsch->tbl[d.seq].ind[d2.seq].full_ind_name",", i.owner = currdbuser",
     " plan d "," join d2 where d2.seq <= tgtsch->tbl[d.seq]->ind_cnt ",
     " join i where tgtsch->tbl[d.seq].tbl_name = i.table_name ",
     "          and i.owner = currdbuser ","  and tgtsch->alpha_feature_nbr = i.alpha_feature_nbr ",
     "  and tgtsch->tbl[d.seq].ind[d2.seq].ind_name = i.index_name ",
     " with nocounter, outerjoin = d2, dontexist go")
    IF (dm2_push_adm_maint(dtl_adm_maint_str)=0)
     ROLLBACK
     RETURN(null)
    ELSE
     COMMIT
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE delete_insert_ind_columns(null)
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(tgtsch->tbl_cnt)),
     (dummyt d2  WITH seq = value(dtl_max_i_cnt))
    PLAN (d)
     JOIN (d2
     WHERE (d2.seq <= tgtsch->tbl[d.seq].ind_cnt))
    DETAIL
     IF ((tgtsch->tbl[d.seq].ind[d2.seq].ind_col_cnt > dtl_max_ic_cnt))
      dtl_max_ic_cnt = tgtsch->tbl[d.seq].ind[d2.seq].ind_col_cnt
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error("Finding largest index column count in record structure")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   IF (dtl_max_ic_cnt > 0)
    SET dm_err->eproc = "Deleting AFD index column rows...."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (dtl_incl_excl_ind=0)
     SET dtl_adm_maint_str = concat("delete from DM_AFD_INDEX_COLUMNS ic ",
      " where ic.alpha_feature_nbr = tgtsch->alpha_feature_nbr","   and ic.owner = currdbuser",
      " with nocounter go")
    ELSE
     SET dtl_adm_maint_str = concat(
      "delete from DM_AFD_INDEX_COLUMNS ic, (dummyt d with seq = value(tgtsch->tbl_cnt)) ",
      " set ic.seq = 1 "," plan d "," join ic where ic.table_name = tgtsch->tbl[d.seq]->tbl_name",
      "           and ic.owner = currdbuser",
      "           and ic.alpha_feature_nbr = tgtsch->alpha_feature_nbr"," with nocounter go")
    ENDIF
    IF (dm2_push_adm_maint(dtl_adm_maint_str)=0)
     ROLLBACK
     RETURN(null)
    ELSE
     COMMIT
    ENDIF
    SET dm_err->eproc = "Inserting AFD index column rows...."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dtl_adm_maint_str = concat("insert into DM_AFD_INDEX_COLUMNS ic, ",
     "  (dummyt d with seq = value(tgtsch->tbl_cnt)), ",
     "  (dummyt d2 with seq = value(dtl_max_i_cnt)), ",
     "  (dummyt d3 with seq = value(dtl_max_ic_cnt)) ","set ",
     "  ic.table_name = tgtsch->tbl[d.seq].tbl_name",
     ", ic.index_name = tgtsch->tbl[d.seq].ind[d2.seq].ind_name",
     ", ic.column_name = tgtsch->tbl[d.seq].ind[d2.seq].ind_col[d3.seq].col_name",
     ", ic.column_position = tgtsch->tbl[d.seq].ind[d2.seq].ind_col[d3.seq].col_position",
     ", ic.updt_applctx = 0",
     ", ic.updt_dt_tm = cnvtdatetime(tgtsch->tbl[d.seq].updt_dt_tm)",", ic.updt_cnt = 0",
     ", ic.updt_id = 0",", ic.updt_task = 0",", ic.alpha_feature_nbr = tgtsch->alpha_feature_nbr",
     ", ic.owner = currdbuser"," plan d "," join d2 where d2.seq <= tgtsch->tbl[d.seq]->ind_cnt",
     " join d3 where d3.seq <= tgtsch->tbl[d.seq]->ind[d2.seq].ind_col_cnt",
     " join ic where tgtsch->tbl[d.seq].tbl_name = ic.table_name",
     "           and ic.owner = currdbuser ",
     "           and tgtsch->alpha_feature_nbr = ic.alpha_feature_nbr",
     "           and tgtsch->tbl[d.seq]->ind[d2.seq].ind_name = ic.index_name",
     "           and tgtsch->tbl[d.seq]->ind[d2.seq]->ind_col[d3.seq].col_name = ic.column_name",
     " with nocounter, outerjoin = d3, dontexist go")
    IF (dm2_push_adm_maint(dtl_adm_maint_str)=0)
     ROLLBACK
     RETURN(null)
    ELSE
     COMMIT
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE delete_insert_constraints(null)
   SET dtl_max_c_cnt = 0
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(tgtsch->tbl_cnt))
    PLAN (d)
    DETAIL
     IF ((tgtsch->tbl[d.seq].cons_cnt > dtl_max_c_cnt))
      dtl_max_c_cnt = tgtsch->tbl[d.seq].cons_cnt
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error("Finding largest constraint count in record structure")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   IF (dtl_max_c_cnt > 0)
    SET dm_err->eproc = "Deleting AFD constraint rows...."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (dtl_incl_excl_ind=0)
     SET dtl_adm_maint_str = concat("delete from DM_AFD_CONSTRAINTS c ",
      " where c.alpha_feature_nbr = tgtsch->alpha_feature_nbr","   and c.owner = currdbuser",
      " with nocounter go")
    ELSE
     SET dtl_adm_maint_str = concat(
      "delete from DM_AFD_CONSTRAINTS c, (dummyt d with seq = value(tgtsch->tbl_cnt)) ",
      " set c.seq = 1 "," plan d "," join c where c.table_name = tgtsch->tbl[d.seq]->tbl_name",
      "          and c.owner = currdbuser",
      "          and c.alpha_feature_nbr = tgtsch->alpha_feature_nbr"," with nocounter go")
    ENDIF
    IF (dm2_push_adm_maint(dtl_adm_maint_str)=0)
     ROLLBACK
     RETURN(null)
    ELSE
     COMMIT
    ENDIF
    SET dm_err->eproc = "Inserting AFD constraint rows...."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dtl_adm_maint_str = concat("insert into DM_AFD_CONSTRAINTS c, ",
     "  (dummyt d with seq = value(tgtsch->tbl_cnt)), ",
     "  (dummyt d2 with seq = value(dtl_max_c_cnt)) ","set ",
     "  c.table_name = tgtsch->tbl[d.seq].tbl_name",
     ", c.constraint_name = tgtsch->tbl[d.seq].cons[d2.seq].cons_name",
     ", c.constraint_type = tgtsch->tbl[d.seq].cons[d2.seq].cons_type",
     ", c.parent_table_name = tgtsch->tbl[d.seq].cons[d2.seq].parent_table",
     ", c.status_ind = tgtsch->tbl[d.seq].cons[d2.seq].status_ind",", c.updt_applctx = 0",
     ", c.updt_dt_tm = cnvtdatetime(tgtsch->tbl[d.seq].updt_dt_tm)",", c.updt_cnt = 0",
     ", c.updt_id = 0",", c.updt_task = 0",
     ", c.parent_table_columns = tgtsch->tbl[d.seq].cons[d2.seq].parent_table_columns",
     ", c.r_constraint_name = tgtsch->tbl[d.seq].cons[d2.seq].r_constraint_name",
     ", c.alpha_feature_nbr = tgtsch->alpha_feature_nbr",
     ", c.full_cons_name = tgtsch->tbl[d.seq].cons[d2.seq].full_cons_name",", c.owner = currdbuser",
     " plan d ",
     " join d2 where d2.seq <= tgtsch->tbl[d.seq]->cons_cnt ",
     " join c where tgtsch->tbl[d.seq].tbl_name = c.table_name ",
     "          and c.owner = currdbuser ",
     "          and tgtsch->alpha_feature_nbr = c.alpha_feature_nbr ",
     "          and tgtsch->tbl[d.seq].cons[d2.seq].cons_name = c.constraint_name ",
     " with nocounter, outerjoin = d2, dontexist go")
    IF (dm2_push_adm_maint(dtl_adm_maint_str)=0)
     ROLLBACK
     RETURN(null)
    ELSE
     COMMIT
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE delete_insert_cons_columns(null)
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(tgtsch->tbl_cnt)),
     (dummyt d2  WITH seq = value(dtl_max_c_cnt))
    PLAN (d)
     JOIN (d2
     WHERE (d2.seq <= tgtsch->tbl[d.seq].cons_cnt))
    DETAIL
     IF ((tgtsch->tbl[d.seq].cons[d2.seq].cons_col_cnt > dtl_max_cc_cnt))
      dtl_max_cc_cnt = tgtsch->tbl[d.seq].cons[d2.seq].cons_col_cnt
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error("Finding largest constraint column count in record structure")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   IF (dtl_max_cc_cnt > 0)
    SET dm_err->eproc = "Deleting AFD constraint column rows...."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (dtl_incl_excl_ind=0)
     SET dtl_adm_maint_str = concat("delete from DM_AFD_CONS_COLUMNS cc ",
      " where cc.alpha_feature_nbr = tgtsch->alpha_feature_nbr","   and cc.owner = currdbuser",
      " with nocounter go")
    ELSE
     SET dtl_adm_maint_str = concat(
      "delete from DM_AFD_CONS_COLUMNS cc, (dummyt d with seq = value(tgtsch->tbl_cnt)) ",
      " set cc.seq = 1 "," plan d "," join cc where cc.table_name = tgtsch->tbl[d.seq]->tbl_name",
      "           and cc.owner = currdbuser",
      "           and cc.alpha_feature_nbr = tgtsch->alpha_feature_nbr"," with nocounter go")
    ENDIF
    IF (dm2_push_adm_maint(dtl_adm_maint_str)=0)
     ROLLBACK
     RETURN(null)
    ELSE
     COMMIT
    ENDIF
    SET dm_err->eproc = "Inserting AFD constraint column rows...."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dtl_adm_maint_str = concat("insert into DM_AFD_CONS_COLUMNS cc, ",
     "  (dummyt d with seq = value(tgtsch->tbl_cnt)), ",
     "  (dummyt d2 with seq = value(dtl_max_c_cnt)), ",
     "  (dummyt d3 with seq = value(dtl_max_cc_cnt)) ","set ",
     "  cc.table_name = tgtsch->tbl[d.seq].tbl_name",
     ", cc.constraint_name = tgtsch->tbl[d.seq].cons[d2.seq].cons_name",
     ", cc.column_name = tgtsch->tbl[d.seq].cons[d2.seq].cons_col[d3.seq].col_name",
     ", cc.position = tgtsch->tbl[d.seq].cons[d2.seq].cons_col[d3.seq].col_position",
     ", cc.updt_applctx = 0",
     ", cc.updt_dt_tm = cnvtdatetime(tgtsch->tbl[d.seq].updt_dt_tm)",", cc.updt_cnt = 0",
     ", cc.updt_id = 0",", cc.updt_task = 0",", cc.alpha_feature_nbr = tgtsch->alpha_feature_nbr",
     ", cc.owner = currdbuser"," plan d "," join d2 where d2.seq <= tgtsch->tbl[d.seq]->cons_cnt",
     " join d3 where d3.seq <= tgtsch->tbl[d.seq]->cons[d2.seq]->cons_col_cnt",
     " join cc where tgtsch->tbl[d.seq].tbl_name = cc.table_name ",
     "           and cc.owner = currdbuser ",
     "           and tgtsch->alpha_feature_nbr = cc.alpha_feature_nbr ",
     "           and tgtsch->tbl[d.seq]->cons[d2.seq].cons_name = cc.constraint_name ",
     "           and tgtsch->tbl[d.seq]->cons[d2.seq]->cons_col[d3.seq].col_name = cc.column_name ",
     " with nocounter, outerjoin = d3, dontexist go")
    IF (dm2_push_adm_maint(dtl_adm_maint_str)=0)
     ROLLBACK
     RETURN(null)
    ELSE
     COMMIT
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE load_td_file_to_database(null)
   SET dm_err->eproc = "Loading Tables Doc Schema Info."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    td.table_name
    FROM dmtbldoc td
    WHERE parser(dtl_glbl_where_clause)
    HEAD REPORT
     stat = alterlist(tbl_doc->qual,10), tbl_doc->cnt = 0
    DETAIL
     tbl_doc->cnt = (tbl_doc->cnt+ 1)
     IF (mod(tbl_doc->cnt,10)=1
      AND (tbl_doc->cnt != 1))
      stat = alterlist(tbl_doc->qual,(tbl_doc->cnt+ 9))
     ENDIF
     tbl_doc->qual[tbl_doc->cnt].table_name = td.table_name, tbl_doc->qual[tbl_doc->cnt].
     data_model_section = td.data_model_section, tbl_doc->qual[tbl_doc->cnt].description = td
     .description,
     tbl_doc->qual[tbl_doc->cnt].definition = td.definition, tbl_doc->qual[tbl_doc->cnt].static_rows
      = td.static_rows, tbl_doc->qual[tbl_doc->cnt].updt_cnt = td.updt_cnt,
     tbl_doc->qual[tbl_doc->cnt].reference_ind = td.reference_ind, tbl_doc->qual[tbl_doc->cnt].
     human_reqd_ind = td.human_reqd_ind, tbl_doc->qual[tbl_doc->cnt].drop_ind = td.drop_ind,
     tbl_doc->qual[tbl_doc->cnt].table_suffix = td.table_suffix, tbl_doc->qual[tbl_doc->cnt].
     full_table_name = td.full_table_name, tbl_doc->qual[tbl_doc->cnt].suffixed_table_name = td
     .suffixed_table_name,
     tbl_doc->qual[tbl_doc->cnt].default_row_ind = td.default_row_ind, tbl_doc->qual[tbl_doc->cnt].
     person_cmb_trigger_type = td.person_cmb_trigger_type, tbl_doc->qual[tbl_doc->cnt].
     encntr_cmb_trigger_type = td.encntr_cmb_trigger_type,
     tbl_doc->qual[tbl_doc->cnt].merge_ui_query = td.merge_ui_query, tbl_doc->qual[tbl_doc->cnt].
     mergeable_ind = td.mergeable_ind, tbl_doc->qual[tbl_doc->cnt].merge_delete_ind = td
     .merge_delete_ind,
     tbl_doc->qual[tbl_doc->cnt].merge_active_ind = td.merge_active_ind, tbl_doc->qual[tbl_doc->cnt].
     data_disp_flag = td.data_disp_flag
    FOOT REPORT
     stat = alterlist(tbl_doc->qual,tbl_doc->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   EXECUTE dm2_chk_tbl_doc 0
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("DM_TABLES_DOC insert cnt = ",cnvtstring(tbl_doc_maint->num_of_inserts,9,0)))
    CALL echo(concat("DM_TABLES_DOC update cnt = ",cnvtstring(tbl_doc_maint->num_of_updates,9,0)))
    CALL echo(concat("  DM_TABLES_DOC none cnt = ",cnvtstring(tbl_doc_maint->num_of_none,9,0)))
   ENDIF
   EXECUTE dm2_ins_upd_tbl_doc
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE load_cd_file_to_database(null)
   SET dm_err->eproc = "Loading Column Doc Schema Info."
   CALL disp_msg(" ",dm_err->logfile,0)
   CALL echo(concat("where clause = ",dtl_glbl_where_clause))
   SELECT
    IF (dtl_incl_excl_ind=0)
     FROM dmcoldoc cd
    ELSE
     FROM dmcoldoc cd,
      dmtbldoc td
     PLAN (td
      WHERE parser(dtl_glbl_where_clause))
      JOIN (cd
      WHERE td.table_name=cd.table_name)
    ENDIF
    INTO "nl:"
    cd.table_name
    ORDER BY cd.table_name
    HEAD REPORT
     stat = alterlist(col_doc->qual,10), col_doc->cnt = 0
    DETAIL
     col_doc->cnt = (col_doc->cnt+ 1)
     IF (mod(col_doc->cnt,10)=1
      AND (col_doc->cnt != 1))
      stat = alterlist(col_doc->qual,(col_doc->cnt+ 9))
     ENDIF
     col_doc->qual[col_doc->cnt].table_name = cd.table_name, col_doc->qual[col_doc->cnt].column_name
      = cd.column_name, col_doc->qual[col_doc->cnt].sequence_name = cd.sequence_name,
     col_doc->qual[col_doc->cnt].code_set = cd.code_set, col_doc->qual[col_doc->cnt].description = cd
     .description, col_doc->qual[col_doc->cnt].definition = cd.definition,
     col_doc->qual[col_doc->cnt].flag_ind = cd.flag_ind, col_doc->qual[col_doc->cnt].updt_cnt = cd
     .updt_cnt, col_doc->qual[col_doc->cnt].unique_ident_ind = cd.unique_ident_ind,
     col_doc->qual[col_doc->cnt].root_entity_name = cd.root_entity_name, col_doc->qual[col_doc->cnt].
     root_entity_attr = cd.root_entity_attr, col_doc->qual[col_doc->cnt].constant_value = cd
     .constant_value,
     col_doc->qual[col_doc->cnt].parent_entity_col = cd.parent_entity_col, col_doc->qual[col_doc->cnt
     ].exception_flg = cd.exception_flg, col_doc->qual[col_doc->cnt].defining_attribute_ind = cd
     .defining_attribute_ind,
     col_doc->qual[col_doc->cnt].merge_updateable_ind = cd.merge_updateable_ind, col_doc->qual[
     col_doc->cnt].nls_col_ind = cd.nls_col_ind, col_doc->qual[col_doc->cnt].absolute_date_ind = cd
     .absolute_date_ind,
     col_doc->qual[col_doc->cnt].merge_delete_ind = cd.merge_delete_ind, col_doc->qual[col_doc->cnt].
     tz_rule_flag = cd.tz_rule_flag
    FOOT REPORT
     stat = alterlist(col_doc->qual,col_doc->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   EXECUTE dm2_chk_col_doc tgtsch->alpha_feature_nbr
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("DM_COLUMNS_DOC insert cnt = ",cnvtstring(col_doc_maint->num_of_inserts,9,0)))
    CALL echo(concat("DM_COLUMNS_DOC update cnt = ",cnvtstring(col_doc_maint->num_of_updates,9,0)))
    CALL echo(concat("  DM_COLUMNS_DOC none cnt = ",cnvtstring(col_doc_maint->num_of_none,9,0)))
   ENDIF
   EXECUTE dm2_ins_upd_col_doc
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE load_tp_file_to_database(null)
   SET dm_err->eproc = "Loading Tablespace Precedence Schema Info."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT
    IF (dtl_incl_excl_ind=0)
     FROM dmtsprec tp
    ELSE
     FROM dmtsprec tp,
      dmtbldoc td
     PLAN (td
      WHERE parser(dtl_glbl_where_clause))
      JOIN (tp
      WHERE td.table_name=tp.table_name)
    ENDIF
    INTO "nl:"
    tp.table_name
    ORDER BY tp.table_name
    HEAD REPORT
     stat = alterlist(ts_prec->qual,10), ts_prec->cnt = 0
    DETAIL
     ts_prec->cnt = (ts_prec->cnt+ 1)
     IF (mod(ts_prec->cnt,10)=1
      AND (ts_prec->cnt != 1))
      stat = alterlist(ts_prec->qual,(ts_prec->cnt+ 9))
     ENDIF
     ts_prec->qual[ts_prec->cnt].table_name = tp.table_name, ts_prec->qual[ts_prec->cnt].precedence
      = tp.precedence, ts_prec->qual[ts_prec->cnt].data_tablespace = tp.data_tablespace,
     ts_prec->qual[ts_prec->cnt].data_extent_size = tp.data_extent_size, ts_prec->qual[ts_prec->cnt].
     index_tablespace = tp.index_tablespace, ts_prec->qual[ts_prec->cnt].index_extent_size = tp
     .index_extent_size,
     ts_prec->qual[ts_prec->cnt].long_tablespace = tp.long_tablespace, ts_prec->qual[ts_prec->cnt].
     long_extent_size = tp.long_extent_size, ts_prec->qual[ts_prec->cnt].updt_cnt = tp.updt_cnt
    FOOT REPORT
     stat = alterlist(ts_prec->qual,ts_prec->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   EXECUTE dm2_chk_ts_prec tgtsch->alpha_feature_nbr
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("DM_TS_PRECEDENCE insert cnt = ",cnvtstring(ts_prec_maint->num_of_inserts,9,0)))
    CALL echo(concat("DM_TS_PRECEDENCE update cnt = ",cnvtstring(ts_prec_maint->num_of_updates,9,0)))
    CALL echo(concat("  DM_TS_PRECEDENCE none cnt = ",cnvtstring(ts_prec_maint->num_of_none,9,0)))
   ENDIF
   EXECUTE dm2_ins_upd_ts_prec
   IF ((dm_err->err_ind=1))
    RETURN(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE display_tgt_rec_struct(null)
   DECLARE dtrs_cnt = i4 WITH protect, noconstant(0)
   DECLARE dtrs_lp_cnt2 = i4 WITH protect, noconstant(0)
   DECLARE dtrs_lp_cnt3 = i4 WITH protect, noconstant(0)
   SET dtl_log_file1 = build(dm2_install_schema->schema_prefix,dm2_install_schema->file_prefix,
    "_trnld1.log")
   SET dtl_log_file2 = build(dm2_install_schema->schema_prefix,dm2_install_schema->file_prefix,
    "_trnld2.log")
   SET dtl_log_file3 = build(dm2_install_schema->schema_prefix,dm2_install_schema->file_prefix,
    "_trnld3.log")
   SET dtl_log_file4 = build(dm2_install_schema->schema_prefix,dm2_install_schema->file_prefix,
    "_trnld4.log")
   SELECT INTO value(dtl_log_file1)
    FROM dual
   ;end select
   IF ((tgtsch->tbl_cnt > 0))
    SELECT INTO value(dtl_log_file1)
     d.seq
     FROM (dummyt d  WITH seq = value(tgtsch->tbl_cnt))
     HEAD REPORT
      "table count = ", tgtsch->tbl_cnt, row + 1,
      "Current/Target Database = ", currdb, row + 1,
      "Source Database = ", tgtsch->source_rdbms
     DETAIL
      row + 1, tg_sd = format(tgtsch->tbl[d.seq].schema_date,"dd-mmm-yyyy hh:mm:ss;;d"), row + 1,
      row + 1, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", row + 1,
      "table number = ", d.seq, row + 1,
      "table_name = ", tgtsch->tbl[d.seq].tbl_name, row + 1,
      "tablespace_name = ", tgtsch->tbl[d.seq].tspace_name, row + 1,
      "table_suffix = ", tgtsch->tbl[d.seq].table_suffix, row + 1,
      "reference_ind = ", tgtsch->tbl[d.seq].reference_ind, row + 1,
      "alpha_feature_nbr = ", tgtsch->alpha_feature_nbr, row + 1,
      "feature nbr = ", tgtsch->tbl[d.seq].feature_number, row + 1,
      "schema_instance = ", tgtsch->tbl[d.seq].schema_instance, row + 1,
      "schema_date = ", tg_sd, row + 1,
      "pull_from_afd = ", tgtsch->tbl[d.seq].pull_from_afd, row + 1,
      "afd schema_instance = ", tgtsch->tbl[d.seq].afd_schema_instance, row + 1,
      "pct increase = ", tgtsch->tbl[d.seq].pct_increase, row + 1,
      "pct used = ", tgtsch->tbl[d.seq].pct_used, row + 1,
      "pct free = ", tgtsch->tbl[d.seq].pct_free, row + 1,
      "bytes allocated = ", tgtsch->tbl[d.seq].bytes_allocated, row + 1,
      "bytes used = ", tgtsch->tbl[d.seq].bytes_used, row + 1,
      "init ext = ", tgtsch->tbl[d.seq].init_ext, row + 1,
      "next ext = ", tgtsch->tbl[d.seq].next_ext, row + 1,
      "long tspace = ", tgtsch->tbl[d.seq].long_tspace, row + 1,
      "ind tspace = ", tgtsch->tbl[d.seq].ind_tspace, row + 1,
      "column count", tgtsch->tbl[d.seq].tbl_col_cnt, row + 1,
      "index count", tgtsch->tbl[d.seq].ind_cnt, row + 1,
      "constraint count", tgtsch->tbl[d.seq].cons_cnt, row + 1
      IF ((tgtsch->tbl[d.seq].tbl_col_cnt > 0))
       row + 1, "COLUMNS"
       FOR (dtrs_lp_cnt2 = 1 TO tgtsch->tbl[d.seq].tbl_col_cnt)
         row + 1, col 3, "------------------",
         row + 1, col 3, "column name = ",
         tgtsch->tbl[d.seq].tbl_col[dtrs_lp_cnt2].col_name, row + 1, col 3,
         "data type = ", tgtsch->tbl[d.seq].tbl_col[dtrs_lp_cnt2].data_type, row + 1,
         col 3, "data length = ", tgtsch->tbl[d.seq].tbl_col[dtrs_lp_cnt2].data_length,
         dd = substring(1,70,tgtsch->tbl[d.seq].tbl_col[dtrs_lp_cnt2].data_default), row + 1, col 3,
         "data default = ", dd, row + 1,
         col 3, "data default ni = ", tgtsch->tbl[d.seq].tbl_col[dtrs_lp_cnt2].data_default_ni,
         row + 1, col 3, "nullable = ",
         tgtsch->tbl[d.seq].tbl_col[dtrs_lp_cnt2].nullable, row + 1, col 3,
         "column seq = ", tgtsch->tbl[d.seq].tbl_col[dtrs_lp_cnt2].col_seq, row + 1,
         col 3, "virtual column = ", tgtsch->tbl[d.seq].tbl_col[dtrs_lp_cnt2].virtual_column
       ENDFOR
      ENDIF
      IF ((tgtsch->tbl[d.seq].ind_cnt > 0))
       row + 2, "INDEXES"
       FOR (dtrs_lp_cnt2 = 1 TO tgtsch->tbl[d.seq].ind_cnt)
         row + 1, col 3, "------------------",
         row + 1, col 3, "index name = ",
         tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].ind_name, row + 1, col 3,
         "full index name = ", tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].full_ind_name, row + 1,
         col 3, "index type = ", tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].index_type,
         row + 1, col 3, "unique_ind = ",
         tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].unique_ind, row + 1, col 3,
         "index column count = ", tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].ind_col_cnt
         FOR (dtrs_lp_cnt3 = 1 TO tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].ind_col_cnt)
           row + 1, col 6, "column name = ",
           tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].ind_col[dtrs_lp_cnt3].col_name, row + 1, col 6,
           "column position = ", tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].ind_col[dtrs_lp_cnt3].
           col_position
         ENDFOR
         row + 1, col 3, "pct increase = ",
         tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].pct_increase, row + 1, col 3,
         "pct_free = ", tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].pct_free, row + 1,
         col 3, "init ext = ", tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].init_ext,
         row + 1, col 3, "next ext = ",
         tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].next_ext, row + 1, col 3,
         "unique ind = ", tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].unique_ind, row + 1,
         col 3, "bytes allocated = ", tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].bytes_allocated,
         row + 1, col 3, "bytes used = ",
         tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].bytes_used, row + 1, col 3,
         "part active ind = ", tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].part_active_ind, row + 1,
         col 3, "partitioning type = ", tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].partitioning_type,
         row + 1, col 3, "sunpartitioning type = ",
         tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].subpartitioning_type, row + 1, col 3,
         "partition count = ", tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].partition_count, row + 1,
         col 3, "subpartition count = ", tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].subpartition_count,
         row + 1, col 3, "interval = ",
         tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].interval, row + 1, col 3,
         "autolist = ", tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].autolist, row + 1,
         col 3, "locality = ", tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].locality,
         row + 1, col 3, "partial_ind = ",
         tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].partial_ind, row + 1, col 3,
         "part col cnt = ", tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].part_col_cnt
         FOR (dtrs_lp_cnt3 = 1 TO tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].part_col_cnt)
           row + 1, col 6, "column name = ",
           tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].part_col[dtrs_lp_cnt3].column_name, row + 1, col 6,
           "position = ", tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].part_col[dtrs_lp_cnt3].position
         ENDFOR
         row + 1, col 3, "part tsp cnt = ",
         tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].part_tsp_cnt
         FOR (dtrs_lp_cnt3 = 1 TO tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].part_tsp_cnt)
           row + 1, col 6, "tspace name = ",
           tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].part_tsp[dtrs_lp_cnt3].tablespace_name
         ENDFOR
         row + 1, col 3, "subpart tsp cnt = ",
         tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].subpart_tsp_cnt
         FOR (dtrs_lp_cnt3 = 1 TO tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].subpart_tsp_cnt)
           row + 1, col 6, "tspace name = ",
           tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].subpart_tsp[dtrs_lp_cnt3].tablespace_name
         ENDFOR
         row + 1, col 3, "part cnt = ",
         tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].part_cnt
         FOR (dtrs_lp_cnt3 = 1 TO tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].part_cnt)
           row + 1, col 6, "partition name = ",
           tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].part[dtrs_lp_cnt3].partition_name, row + 1, col 6,
           "subpartition name = ", tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].part[dtrs_lp_cnt3].
           subpartition_name, row + 1,
           col 6, "high value = ", tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].part[dtrs_lp_cnt3].high_value,
           row + 1, col 6, "partition position = ",
           tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].part[dtrs_lp_cnt3].partition_position, row + 1, col 6,
           "subpartition position = ", tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].part[dtrs_lp_cnt3].
           subpartition_position, row + 1,
           col 6, "tablespace name = ", tgtsch->tbl[d.seq].ind[dtrs_lp_cnt2].part[dtrs_lp_cnt3].
           tablespace_name
         ENDFOR
       ENDFOR
      ENDIF
      IF ((tgtsch->tbl[d.seq].cons_cnt > 0))
       row + 2, "CONSTRAINTS"
       FOR (dtrs_lp_cnt2 = 1 TO tgtsch->tbl[d.seq].cons_cnt)
         row + 1, col 3, "------------------",
         row + 1, col 3, "constraint name = ",
         tgtsch->tbl[d.seq].cons[dtrs_lp_cnt2].cons_name, row + 1, col 3,
         "full constraint name = ", tgtsch->tbl[d.seq].cons[dtrs_lp_cnt2].full_cons_name, row + 1,
         col 3, "constraint type = ", tgtsch->tbl[d.seq].cons[dtrs_lp_cnt2].cons_type,
         row + 1, col 3, "parent table = ",
         tgtsch->tbl[d.seq].cons[dtrs_lp_cnt2].parent_table, row + 1, col 3,
         "status_ind = ", tgtsch->tbl[d.seq].cons[dtrs_lp_cnt2].status_ind, row + 1,
         col 3, "r_constraint_name = ", tgtsch->tbl[d.seq].cons[dtrs_lp_cnt2].r_constraint_name,
         row + 1, col 3, "parent table columns = ",
         tgtsch->tbl[d.seq].cons[dtrs_lp_cnt2].parent_table_columns, row + 1, col 3,
         "delete_rule = ", tgtsch->tbl[d.seq].cons[dtrs_lp_cnt2].delete_rule, row + 1,
         col 3, "constraint column count = ", tgtsch->tbl[d.seq].cons[dtrs_lp_cnt2].cons_col_cnt
         FOR (cc_cnt = 1 TO tgtsch->tbl[d.seq].cons[dtrs_lp_cnt2].cons_col_cnt)
           row + 1, col 6, "column name = ",
           tgtsch->tbl[d.seq].cons[dtrs_lp_cnt2].cons_col[cc_cnt].col_name, row + 1, col 6,
           "column position = ", tgtsch->tbl[d.seq].cons[dtrs_lp_cnt2].cons_col[cc_cnt].col_position
         ENDFOR
       ENDFOR
      ENDIF
     WITH nocounter, format = variable, formfeed = none,
      maxrow = 1, maxcol = 512
    ;end select
   ENDIF
   IF ((tgtsch->sequence_cnt > 0))
    SELECT INTO value(dtl_log_file2)
     d.seq
     FROM (dummyt d  WITH seq = value(tgtsch->sequence_cnt))
     HEAD REPORT
      "sequence count = ", tgtsch->sequence_cnt
     DETAIL
      row + 1, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", row + 1,
      "sequence_name = ", tgtsch->sequence[d.seq].seq_name, row + 1,
      "min_val = ", tgtsch->sequence[d.seq].min_val, row + 1,
      "max_val = ", tgtsch->sequence[d.seq].max_val, row + 1,
      "cycle_flag = ", tgtsch->sequence[d.seq].cycle_flag, row + 1,
      "increment by = ", tgtsch->sequence[d.seq].increment_by, row + 1,
      "last number = ", tgtsch->sequence[d.seq].last_number
     WITH nocounter, format = variable, formfeed = none,
      maxrow = 1, maxcol = 512
    ;end select
   ENDIF
   IF ((tgtsch->tspace_cnt > 0))
    SELECT INTO value(dtl_log_file3)
     d.seq
     FROM (dummyt d  WITH seq = value(tgtsch->tspace_cnt))
     HEAD REPORT
      "Tablespace count = ", tgtsch->tspace_cnt
     DETAIL
      row + 1, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", row + 1,
      "tablespace_name = ", tgtsch->tspace[d.seq].tspace_name, row + 1,
      "tspace_type = ", tgtsch->tspace[d.seq].tspace_type, row + 1,
      "min_total_bytes = ", tgtsch->tspace[d.seq].min_total_bytes
     WITH nocounter, format = variable, formfeed = none,
      maxrow = 1, maxcol = 512
    ;end select
   ENDIF
   IF ((tgtsch->user_cnt > 0))
    SELECT INTO value(dtl_log_file4)
     d.seq
     FROM (dummyt d  WITH seq = value(tgtsch->user_cnt))
     HEAD REPORT
      "User count = ", tgtsch->user_cnt
     DETAIL
      row + 1, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", row + 1,
      "User_name = ", tgtsch->user[d.seq].user_name, row + 1,
      "Instance = ", tgtsch->user[d.seq].instance, row + 1,
      "Default_tspace = ", tgtsch->user[d.seq].default_tspace, row + 1,
      "Temp_tspace = ", tgtsch->user[d.seq].temp_tspace, row + 1,
      "Default_tspace_size = ", tgtsch->user[d.seq].default_tspace_size, row + 1,
      "Temp_tspace_size = ", tgtsch->user[d.seq].temp_tspace_size, row + 1,
      "Pull_from_admin = ", tgtsch->user[d.seq].pull_from_admin, row + 1,
      "Priv_cnt = ", tgtsch->user[d.seq].priv_cnt, row + 1,
      "Quota_cnt = ", tgtsch->user[d.seq].quota_cnt
      IF ((tgtsch->user[d.seq].priv_cnt > 0))
       row + 2, "PRIVILEGES"
       FOR (dtrs_cnt = 1 TO tgtsch->user[d.seq].priv_cnt)
         row + 1, col 0, "-------------",
         row + 1, col 3, "Privilege name = ",
         tgtsch->user[d.seq].privs[dtrs_cnt].priv_name
       ENDFOR
      ENDIF
      IF ((tgtsch->user[d.seq].quota_cnt > 0))
       row + 2, "QUOTA"
       FOR (dtrs_cnt = 1 TO tgtsch->user[d.seq].quota_cnt)
         row + 1, col 0, "----------",
         row + 1, col 3, "Tspace name = ",
         tgtsch->user[d.seq].quota[dtrs_cnt].tspace_name
       ENDFOR
      ENDIF
     WITH nocounter, format = variable, formfeed = none,
      maxrow = 1, maxcol = 512
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE load_obsolete_objects(null)
   SET dm_err->eproc = "Loading obsolete objects"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_cb_objects dco
    WHERE dco.object_type IN ("TABLE", "INDEX")
     AND dco.active_ind=1
     AND dco.object_status="DROP"
    ORDER BY dco.object_type
    HEAD REPORT
     stat = alterlist(dtl_obs_obj->tbl,10), dtl_obs_obj->tbl_cnt = 0, stat = alterlist(dtl_obs_obj->
      ind,10),
     dtl_obs_obj->ind_cnt = 0
    DETAIL
     IF (dco.object_type="TABLE")
      dtl_obs_obj->tbl_cnt = (dtl_obs_obj->tbl_cnt+ 1)
      IF (mod(dtl_obs_obj->tbl_cnt,10)=1
       AND (dtl_obs_obj->tbl_cnt != 1))
       stat = alterlist(dtl_obs_obj->tbl,(dtl_obs_obj->tbl_cnt+ 9))
      ENDIF
      dtl_obs_obj->tbl[dtl_obs_obj->tbl_cnt].table_name = dco.object_name
     ELSE
      dtl_obs_obj->ind_cnt = (dtl_obs_obj->ind_cnt+ 1)
      IF (mod(dtl_obs_obj->ind_cnt,10)=1
       AND (dtl_obs_obj->ind_cnt != 1))
       stat = alterlist(dtl_obs_obj->ind,(dtl_obs_obj->ind_cnt+ 9))
      ENDIF
      dtl_obs_obj->ind[dtl_obs_obj->ind_cnt].index_name = dco.object_name
     ENDIF
    FOOT REPORT
     stat = alterlist(dtl_obs_obj->tbl,dtl_obs_obj->tbl_cnt), stat = alterlist(dtl_obs_obj->ind,
      dtl_obs_obj->ind_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtl_override_index_types(null)
   SET dm_err->eproc = "Evaluating override Index Types against Target Indexes..."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dm_err->eproc = "Determining highest index count in TgtSch..."
   SET dtl_max_i_cnt = 0
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(tgtsch->tbl_cnt))
    PLAN (d)
    DETAIL
     IF ((tgtsch->tbl[d.seq].ind_cnt > dtl_max_i_cnt))
      dtl_max_i_cnt = tgtsch->tbl[d.seq].ind_cnt
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((dtl_max_i_cnt=0) OR ((tgtsch->tbl_cnt=0))) )
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Matching Index Overrides to Indexes in the Target Schema..."
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(dtl_indtype->tot_cnt)),
     (dummyt d2  WITH seq = value(tgtsch->tbl_cnt)),
     (dummyt d3  WITH seq = value(dtl_max_i_cnt))
    PLAN (d)
     JOIN (d2
     WHERE (tgtsch->tbl[d2.seq].tbl_name=dtl_indtype->qual[d.seq].table_name)
      AND (tgtsch->tbl[d2.seq].schema_instance >= dtl_indtype->qual[d.seq].baseline_schema_instance))
     JOIN (d3
     WHERE (d3.seq <= tgtsch->tbl[d2.seq].ind_cnt)
      AND (tgtsch->tbl[d2.seq].ind[d3.seq].ind_name=dtl_indtype->qual[d.seq].index_name))
    DETAIL
     IF ((dm_err->debug_flag > 1))
      CALL echo(concat("Match found for table/index:",dtl_indtype->qual[d.seq].tableandindex_name)),
      CALL echo(build("Tgtsch-schinst:",tgtsch->tbl[d2.seq].schema_instance,"indtype-baseschinst:",
       dtl_indtype->qual[d.seq].baseline_schema_instance)),
      CALL echo(build("d=",d.seq," / d2=",d2.seq," / d3=",
       d3.seq))
     ENDIF
     IF ((tgtsch->tbl[d2.seq].ind[d3.seq].index_type != dtl_indtype->qual[d.seq].index_type))
      IF ((dm_err->debug_flag > 1))
       CALL echo(build("Setting override index type = (",dtl_indtype->qual[d.seq].index_type,
        ") for index:(",tgtsch->tbl[d2.seq].ind[d3.seq].ind_name,")."))
      ENDIF
      tgtsch->tbl[d2.seq].ind[d3.seq].index_type = dtl_indtype->qual[d.seq].index_type
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtl_get_optimizer_mode(null)
   DECLARE dtlgom_optmode = vc WITH protect, noconstant("RULE")
   SET dm_err->eproc = "Getting session optimizer mode."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM v$parameter v
    WHERE cnvtupper(v.name)="OPTIMIZER_MODE"
    DETAIL
     dtlgom_optmode = cnvtupper(v.value)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->err_ind = 0
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("DM2_SUBERROR")
   ENDIF
   RETURN(dtlgom_optmode)
 END ;Subroutine
 SUBROUTINE dtl_include_exclude_list(null)
   DECLARE diel_where_clause = vc WITH public, noconstant("")
   SET dm_err->eproc = "Creating list of data_model_section values to include/exclude"
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_INCL_EXCL"
    ORDER BY d.info_char
    HEAD REPORT
     diel_where_clause = " "
    HEAD d.info_char
     cnt = 0
     IF (diel_where_clause=" ")
      IF (cnvtupper(d.info_char)="INCLUDE")
       diel_where_clause = "td.data_model_section in "
      ELSEIF (cnvtupper(d.info_char)="EXCLUDE")
       diel_where_clause = "td.data_model_section not in "
      ELSE
       diel_where_clause = "ERROR - invalid type"
      ENDIF
     ELSE
      diel_where_clause = "ERROR - can only process one type (include/exclude)"
     ENDIF
    DETAIL
     IF (substring(1,5,diel_where_clause) != "ERROR")
      cnt = (cnt+ 1)
      IF (cnt > 1)
       diel_where_clause = concat(diel_where_clause,"','",trim(d.info_name,3))
      ELSE
       diel_where_clause = concat(diel_where_clause," ('",trim(d.info_name,3))
      ENDIF
     ENDIF
    FOOT REPORT
     IF (substring(1,5,diel_where_clause) != "ERROR")
      diel_where_clause = concat(diel_where_clause,"')")
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET diel_where_clause = "ERROR"
   ELSEIF (curqual=0)
    SET diel_where_clause = "NONE"
   ELSEIF (substring(1,5,diel_where_clause)="ERROR")
    SET dm_err->emsg = diel_where_clause
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET diel_where_clause = "ERROR"
   ENDIF
   RETURN(diel_where_clause)
 END ;Subroutine
 SUBROUTINE dtl_load_user_tables(null)
   SET dm_err->eproc = "Retrieving tables from USER_TABLES"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM user_tables ut
    DETAIL
     dtl_user_tables->cnt = (dtl_user_tables->cnt+ 1)
     IF (mod(dtl_user_tables->cnt,10)=1)
      stat = alterlist(dtl_user_tables->qual,(dtl_user_tables->cnt+ 9))
     ENDIF
     dtl_user_tables->qual[dtl_user_tables->cnt].table_name = ut.table_name
    FOOT REPORT
     stat = alterlist(dtl_user_tables->qual,dtl_user_tables->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 4))
    CALL echorecord(dtl_user_tables)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE load_t_initial_to_tgtsch(null)
   SET dm_err->eproc = "Performing Retrieval & Load of Table Information"
   CALL disp_msg(" ",dm_err->logfile,0)
   CALL echo(build("pkg=",tgtsch->alpha_feature_nbr))
   SELECT INTO "nl:"
    FROM dm_afd_tables t
    WHERE (t.alpha_feature_nbr=tgtsch->alpha_feature_nbr)
     AND t.owner=currdbuser
    HEAD REPORT
     stat = alterlist(tgtsch->tbl,10), tgtsch->tbl_cnt = 0
    DETAIL
     tgtsch->tbl_cnt = (tgtsch->tbl_cnt+ 1)
     IF (mod(tgtsch->tbl_cnt,10)=1
      AND (tgtsch->tbl_cnt != 1))
      stat = alterlist(tgtsch->tbl,(tgtsch->tbl_cnt+ 9))
     ENDIF
     IF (((t.table_name="*GTTD") OR (t.table_name="*GTMP")) )
      tgtsch->tbl[tgtsch->tbl_cnt].gtt_flag = 1
     ELSEIF (t.table_name="*GTTP")
      tgtsch->tbl[tgtsch->tbl_cnt].gtt_flag = 2
     ENDIF
     IF (t.table_name="MV*")
      IF ((dm2_rdbms_version->level1 < 9))
       tgtsch->tbl[tgtsch->tbl_cnt].mview_flag = 2
      ELSE
       tgtsch->tbl[tgtsch->tbl_cnt].mview_flag = 1
      ENDIF
      tgtsch->tbl[tgtsch->tbl_cnt].mview_cc_build_ind = t.feature_number
     ENDIF
     tgtsch->tbl[tgtsch->tbl_cnt].tbl_name = t.table_name, tgtsch->tbl[tgtsch->tbl_cnt].orig_tbl_name
      = t.table_name, tgtsch->tbl[tgtsch->tbl_cnt].schema_date = t.schema_date,
     tgtsch->tbl[tgtsch->tbl_cnt].schema_instance = t.schema_instance, tgtsch->tbl[tgtsch->tbl_cnt].
     pct_increase = t.pct_increase, tgtsch->tbl[tgtsch->tbl_cnt].pct_used = t.pct_used,
     tgtsch->tbl[tgtsch->tbl_cnt].pct_free = t.pct_free, tgtsch->tbl[tgtsch->tbl_cnt].
     alpha_feature_nbr = t.alpha_feature_nbr, tgtsch->tbl[tgtsch->tbl_cnt].feature_number = t
     .feature_number,
     tgtsch->tbl[tgtsch->tbl_cnt].updt_dt_tm = t.updt_dt_tm, tgtsch->tbl[tgtsch->tbl_cnt].tspace_name
      = t.tablespace_name, tgtsch->tbl[tgtsch->tbl_cnt].bytes_allocated = 0.0,
     tgtsch->tbl[tgtsch->tbl_cnt].bytes_used = 0.0, tgtsch->tbl[tgtsch->tbl_cnt].ind_tspace = " ",
     tgtsch->tbl[tgtsch->tbl_cnt].long_tspace = " ",
     tgtsch->tbl[tgtsch->tbl_cnt].init_ext = 0.0, tgtsch->tbl[tgtsch->tbl_cnt].next_ext = 0.0, tgtsch
     ->tbl[tgtsch->tbl_cnt].pull_from_afd = 1,
     tgtsch->tbl[tgtsch->tbl_cnt].afd_schema_instance = t.schema_instance, tgtsch->tbl[tgtsch->
     tbl_cnt].metadata_loc_flg = 1, tgtsch->tbl[tgtsch->tbl_cnt].rowid_col_fnd = 0,
     tgtsch->tbl[tgtsch->tbl_cnt].xrid_ind_fnd = 0, tgtsch->tbl[tgtsch->tbl_cnt].table_suffix =
     "0000"
    FOOT REPORT
     stat = alterlist(tgtsch->tbl,tgtsch->tbl_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ELSEIF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "No Table Information Found"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("Table count = ",cnvtstring(tgtsch->tbl_cnt,4,0)))
   ENDIF
   IF ((dm_err->debug_flag > 4))
    CALL echorecord(tgtsch)
   ENDIF
 END ;Subroutine
 SUBROUTINE dtl_populate_tbl_part_objs(null)
   DECLARE ptpo_ind_idx = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Load partitioned object information"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(tgtsch->tbl_cnt)),
     dm_afd_part_objects dapo
    PLAN (d
     WHERE (tgtsch->tbl[d.seq].pull_from_afd=1)
      AND (tgtsch->tbl[d.seq].metadata_loc_flg=1))
     JOIN (dapo
     WHERE dapo.owner=currdbuser
      AND (tgtsch->tbl[d.seq].tbl_name=dapo.table_name)
      AND (tgtsch->tbl[d.seq].alpha_feature_nbr=dapo.alpha_feature_nbr)
      AND dapo.object_type="INDEX")
    ORDER BY dapo.table_name, dapo.object_name
    DETAIL
     ptpo_ind_idx = 0, ptpo_ind_idx = locateval(ptpo_ind_idx,1,tgtsch->tbl[d.seq].ind_cnt,dapo
      .object_name,tgtsch->tbl[d.seq].ind[ptpo_ind_idx].ind_name)
     IF (ptpo_ind_idx > 0)
      tgtsch->tbl[d.seq].ind[ptpo_ind_idx].partitioning_type = dapo.partitioning_type, tgtsch->tbl[d
      .seq].ind[ptpo_ind_idx].subpartitioning_type = dapo.subpartitioning_type, tgtsch->tbl[d.seq].
      ind[ptpo_ind_idx].partition_count = dapo.partition_count,
      tgtsch->tbl[d.seq].ind[ptpo_ind_idx].subpartition_count = dapo.subpartition_count, tgtsch->tbl[
      d.seq].ind[ptpo_ind_idx].interval = dapo.interval, tgtsch->tbl[d.seq].ind[ptpo_ind_idx].
      autolist = dapo.autolist,
      tgtsch->tbl[d.seq].ind[ptpo_ind_idx].locality = dapo.locality, tgtsch->tbl[d.seq].ind[
      ptpo_ind_idx].partial_ind = dapo.partial_ind, tgtsch->tbl[d.seq].ind[ptpo_ind_idx].
      part_active_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Load partitioned column information"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(tgtsch->tbl_cnt)),
     dm_afd_part_subpart_keycols dapsk
    PLAN (d
     WHERE (tgtsch->tbl[d.seq].pull_from_afd=1)
      AND (tgtsch->tbl[d.seq].metadata_loc_flg=1))
     JOIN (dapsk
     WHERE dapsk.owner=currdbuser
      AND (tgtsch->tbl[d.seq].tbl_name=dapsk.table_name)
      AND dapsk.object_type="INDEX"
      AND (tgtsch->tbl[d.seq].alpha_feature_nbr=dapsk.alpha_feature_nbr)
      AND dapsk.part_type="PART")
    ORDER BY dapsk.table_name, dapsk.object_name, dapsk.column_position
    DETAIL
     ptpo_ind_idx = 0, ptpo_ind_idx = locateval(ptpo_ind_idx,1,tgtsch->tbl[d.seq].ind_cnt,dapsk
      .object_name,tgtsch->tbl[d.seq].ind[ptpo_ind_idx].ind_name)
     IF (ptpo_ind_idx > 0)
      tgtsch->tbl[d.seq].ind[ptpo_ind_idx].part_col_cnt = (tgtsch->tbl[d.seq].ind[ptpo_ind_idx].
      part_col_cnt+ 1), stat = alterlist(tgtsch->tbl[d.seq].ind[ptpo_ind_idx].part_col,tgtsch->tbl[d
       .seq].ind[ptpo_ind_idx].part_col_cnt), tgtsch->tbl[d.seq].ind[ptpo_ind_idx].part_col[tgtsch->
      tbl[d.seq].ind[ptpo_ind_idx].part_col_cnt].column_name = dapsk.column_name,
      tgtsch->tbl[d.seq].ind[ptpo_ind_idx].part_col[tgtsch->tbl[d.seq].ind[ptpo_ind_idx].part_col_cnt
      ].position = dapsk.column_position
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Load partitioned tablespace information"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(tgtsch->tbl_cnt)),
     dm_afd_part_subpart_tspaces dapt
    PLAN (d
     WHERE (tgtsch->tbl[d.seq].pull_from_afd=1)
      AND (tgtsch->tbl[d.seq].metadata_loc_flg=1))
     JOIN (dapt
     WHERE dapt.owner=currdbuser
      AND (tgtsch->tbl[d.seq].tbl_name=dapt.table_name)
      AND dapt.object_type="INDEX"
      AND (tgtsch->tbl[d.seq].alpha_feature_nbr=dapt.alpha_feature_nbr)
      AND dapt.part_type="PART")
    ORDER BY dapt.table_name, dapt.object_name, dapt.tablespace_name
    DETAIL
     ptpo_ind_idx = 0, ptpo_ind_idx = locateval(ptpo_ind_idx,1,tgtsch->tbl[d.seq].ind_cnt,dapt
      .object_name,tgtsch->tbl[d.seq].ind[ptpo_ind_idx].ind_name)
     IF (ptpo_ind_idx > 0)
      tgtsch->tbl[d.seq].ind[ptpo_ind_idx].part_tsp_cnt = (tgtsch->tbl[d.seq].ind[ptpo_ind_idx].
      part_tsp_cnt+ 1), stat = alterlist(tgtsch->tbl[d.seq].ind[ptpo_ind_idx].part_tsp,tgtsch->tbl[d
       .seq].ind[ptpo_ind_idx].part_tsp_cnt), tgtsch->tbl[d.seq].ind[ptpo_ind_idx].part_tsp[tgtsch->
      tbl[d.seq].ind[ptpo_ind_idx].part_tsp_cnt].tablespace_name = dapt.tablespace_name
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Load subpartitioned tablespace information"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(tgtsch->tbl_cnt)),
     dm_afd_part_subpart_tspaces dapst
    PLAN (d
     WHERE (tgtsch->tbl[d.seq].pull_from_afd=1)
      AND (tgtsch->tbl[d.seq].metadata_loc_flg=1))
     JOIN (dapst
     WHERE dapst.owner=currdbuser
      AND (tgtsch->tbl[d.seq].tbl_name=dapst.table_name)
      AND dapst.object_type="INDEX"
      AND (tgtsch->tbl[d.seq].alpha_feature_nbr=dapst.alpha_feature_nbr)
      AND dapst.part_type="SUBPART")
    ORDER BY dapst.table_name, dapst.object_name, dapst.tablespace_name
    DETAIL
     ptpo_ind_idx = 0, ptpo_ind_idx = locateval(ptpo_ind_idx,1,tgtsch->tbl[d.seq].ind_cnt,dapst
      .object_name,tgtsch->tbl[d.seq].ind[ptpo_ind_idx].ind_name)
     IF (ptpo_ind_idx > 0)
      tgtsch->tbl[d.seq].ind[ptpo_ind_idx].subpart_tsp_cnt = (tgtsch->tbl[d.seq].ind[ptpo_ind_idx].
      subpart_tsp_cnt+ 1), stat = alterlist(tgtsch->tbl[d.seq].ind[ptpo_ind_idx].subpart_tsp,tgtsch->
       tbl[d.seq].ind[ptpo_ind_idx].subpart_tsp_cnt), tgtsch->tbl[d.seq].ind[ptpo_ind_idx].
      subpart_tsp[tgtsch->tbl[d.seq].ind[ptpo_ind_idx].subpart_tsp_cnt].tablespace_name = dapst
      .tablespace_name
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Load index specific partition information"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(tgtsch->tbl_cnt)),
     dm_afd_part_subpart_objects dapso
    PLAN (d
     WHERE (tgtsch->tbl[d.seq].pull_from_afd=1)
      AND (tgtsch->tbl[d.seq].metadata_loc_flg=1))
     JOIN (dapso
     WHERE dapso.owner=currdbuser
      AND (tgtsch->tbl[d.seq].tbl_name=dapso.table_name)
      AND dapso.object_type="INDEX"
      AND (tgtsch->tbl[d.seq].alpha_feature_nbr=dapso.alpha_feature_nbr))
    ORDER BY dapso.table_name, dapso.partition_position, dapso.subpartition_position
    DETAIL
     ptpo_ind_idx = 0, ptpo_ind_idx = locateval(ptpo_ind_idx,1,tgtsch->tbl[d.seq].ind_cnt,dapso
      .object_name,tgtsch->tbl[d.seq].ind[ptpo_ind_idx].ind_name)
     IF (ptpo_ind_idx > 0)
      tgtsch->tbl[d.seq].ind[ptpo_ind_idx].part_cnt = (tgtsch->tbl[d.seq].ind[ptpo_ind_idx].part_cnt
      + 1), stat = alterlist(tgtsch->tbl[d.seq].ind[ptpo_ind_idx].part,tgtsch->tbl[d.seq].ind[
       ptpo_ind_idx].part_cnt), tgtsch->tbl[d.seq].ind[ptpo_ind_idx].part[tgtsch->tbl[d.seq].ind[
      ptpo_ind_idx].part_cnt].partition_name = dapso.partition_name,
      tgtsch->tbl[d.seq].ind[ptpo_ind_idx].part[tgtsch->tbl[d.seq].ind[ptpo_ind_idx].part_cnt].
      subpartition_name = dapso.subpartition_name, tgtsch->tbl[d.seq].ind[ptpo_ind_idx].part[tgtsch->
      tbl[d.seq].ind[ptpo_ind_idx].part_cnt].high_value = dapso.high_value, tgtsch->tbl[d.seq].ind[
      ptpo_ind_idx].part[tgtsch->tbl[d.seq].ind[ptpo_ind_idx].part_cnt].partition_position = dapso
      .partition_position,
      tgtsch->tbl[d.seq].ind[ptpo_ind_idx].part[tgtsch->tbl[d.seq].ind[ptpo_ind_idx].part_cnt].
      subpartition_position = dapso.subpartition_position, tgtsch->tbl[d.seq].ind[ptpo_ind_idx].part[
      tgtsch->tbl[d.seq].ind[ptpo_ind_idx].part_cnt].tablespace_name = dapso.tablespace_name
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtl_load_user_info(null)
   DECLARE dlccui_idx = i4 WITH protect, noconstant(0)
   DECLARE dlccui_user_load_from_admin = i2 WITH protect, noconstant(0)
   DECLARE dlccui_user_cnt = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Performing Retrieval & Load of CER_CASVC user Information"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_afd_tables t,
     dma_sql_obj_inst dsoi,
     dma_sql_obj_inst_attr dsoia
    WHERE (t.alpha_feature_nbr=tgtsch->alpha_feature_nbr)
     AND t.owner=currdbuser
     AND t.owner=dsoi.object_owner
     AND t.table_name=dsoi.table_name
     AND dsoi.process_type="PACKAGING"
     AND dsoi.object_type="USER"
     AND (dsoi.object_instance=
    (SELECT
     max(dsoi2.object_instance)
     FROM dma_sql_obj_inst dsoi2,
      dm_afd_tables t2
     WHERE t2.owner=dsoi2.object_owner
      AND t2.table_name=dsoi2.table_name
      AND dsoi2.object_owner=dsoi.object_owner
      AND dsoi2.table_name=dsoi.table_name
      AND dsoi2.process_type=dsoi.process_type
      AND dsoi2.object_type=dsoi.object_type))
     AND dsoi.dma_sql_obj_inst_id=dsoia.dma_sql_obj_inst_id
    ORDER BY dsoi.object_name, dsoia.attr_name, dsoia.attr_seg_nbr
    HEAD dsoi.object_name
     IF (dsoi.active_ind=1)
      tgtsch->user_cnt = (tgtsch->user_cnt+ 1), stat = alterlist(tgtsch->user,tgtsch->user_cnt),
      tgtsch->user[tgtsch->user_cnt].user_name = dsoi.object_name,
      tgtsch->user[tgtsch->user_cnt].instance = dsoi.object_instance, tgtsch->user[tgtsch->user_cnt].
      default_tspace = "DM2NOTSET", tgtsch->user[tgtsch->user_cnt].temp_tspace = "DM2NOTSET",
      tgtsch->user[tgtsch->user_cnt].default_tspace_size = 104857600, tgtsch->user[tgtsch->user_cnt].
      temp_tspace_size = 104857600, tgtsch->user[tgtsch->user_cnt].priv_cnt = 0,
      tgtsch->user[tgtsch->user_cnt].quota_cnt = 0, tgtsch->user[tgtsch->user_cnt].cur_instance = 0,
      tgtsch->user[tgtsch->user_cnt].pull_from_admin = 0
     ENDIF
    DETAIL
     IF (dsoi.active_ind=1)
      CASE (cnvtupper(dsoia.attr_name))
       OF "DEFAULT_TABLESPACE":
        tgtsch->user[tgtsch->user_cnt].default_tspace = cnvtupper(dsoia.attr_value_char)
       OF "DEFAULT_TABLESPACE_SIZE":
        tgtsch->user[tgtsch->user_cnt].default_tspace_size = dsoia.attr_value_num
       OF "TEMPORARY_TABLESPACE":
        tgtsch->user[tgtsch->user_cnt].temp_tspace = cnvtupper(dsoia.attr_value_char)
       OF "TEMPORARY_TABLESPACE_SIZE":
        tgtsch->user[tgtsch->user_cnt].temp_tspace_size = dsoia.attr_value_num
       OF "SYS_PRIV_GRANT":
        tgtsch->user[tgtsch->user_cnt].priv_cnt = (tgtsch->user[tgtsch->user_cnt].priv_cnt+ 1),stat
         = alterlist(tgtsch->user[tgtsch->user_cnt].privs,tgtsch->user[tgtsch->user_cnt].priv_cnt),
        tgtsch->user[tgtsch->user_cnt].privs[tgtsch->user[tgtsch->user_cnt].priv_cnt].priv_name =
        cnvtupper(dsoia.attr_value_char)
       OF "TABLESPACE_QUOTA":
        tgtsch->user[tgtsch->user_cnt].quota_cnt = (tgtsch->user[tgtsch->user_cnt].quota_cnt+ 1),stat
         = alterlist(tgtsch->user[tgtsch->user_cnt].quota,tgtsch->user[tgtsch->user_cnt].quota_cnt),
        tgtsch->user[tgtsch->user_cnt].quota[tgtsch->user[tgtsch->user_cnt].quota_cnt].tspace_name =
        cnvtupper(dsoia.attr_value_char)
      ENDCASE
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF ((tgtsch->user_cnt=0))
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Determine if current object instance is higher than instance on plan/pkgs"
   IF ((dm_err->debug_flag > 5))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain="DM2_OBJECT_INSTANCE_USER")
    DETAIL
     dlccui_idx = 0, dlccui_idx = locateval(dlccui_idx,1,tgtsch->user_cnt,di.info_name,tgtsch->user[
      dlccui_idx].user_name)
     IF (dlccui_idx > 0)
      IF ((di.info_number > tgtsch->user[dlccui_idx].instance))
       tgtsch->user[dlccui_idx].pull_from_admin = 1, tgtsch->user[dlccui_idx].cur_instance = di
       .info_number, dlccui_user_load_from_admin = 1
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dlccui_user_load_from_admin=1)
    SET dm_err->eproc =
    "User needs to have its metadata reloaded with a different object instance than one on plan/pkgs"
    IF ((dm_err->debug_flag > 5))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     d.seq
     FROM (dummyt d  WITH seq = value(tgtsch->user_cnt)),
      dma_sql_obj_inst dsoi,
      dma_sql_obj_inst_attr dsoia
     PLAN (d
      WHERE (tgtsch->user[d.seq].pull_from_admin=1))
      JOIN (dsoi
      WHERE dsoi.process_type="PACKAGING"
       AND dsoi.object_type="USER"
       AND dsoi.object_owner=currdbuser
       AND (dsoi.object_name=tgtsch->user[d.seq].user_name)
       AND (dsoi.object_instance=tgtsch->user[d.seq].cur_instance))
      JOIN (dsoia
      WHERE dsoi.dma_sql_obj_inst_id=dsoia.dma_sql_obj_inst_id)
     ORDER BY dsoi.object_name, dsoia.attr_name, dsoia.attr_seg_nbr
     HEAD dsoi.object_name
      tgtsch->user[d.seq].user_name = dsoi.object_name, tgtsch->user[d.seq].instance = dsoi
      .object_instance, tgtsch->user[d.seq].default_tspace = "DM2NOTSET",
      tgtsch->user[d.seq].temp_tspace = "DM2NOTSET", tgtsch->user[d.seq].default_tspace_size =
      104857600, tgtsch->user[d.seq].temp_tspace_size = 104857600,
      tgtsch->user[d.seq].priv_cnt = 0, stat = alterlist(tgtsch->user[d.seq].privs,0), tgtsch->user[d
      .seq].quota_cnt = 0,
      stat = alterlist(tgtsch->user[d.seq].quota,0)
     DETAIL
      CASE (cnvtupper(dsoia.attr_name))
       OF "DEFAULT_TABLESPACE":
        tgtsch->user[d.seq].default_tspace = cnvtupper(dsoia.attr_value_char)
       OF "DEFAULT_TABLESPACE_SIZE":
        tgtsch->user[d.seq].default_tspace_size = dsoia.attr_value_num
       OF "TEMPORARY_TABLESPACE":
        tgtsch->user[d.seq].temp_tspace = cnvtupper(dsoia.attr_value_char)
       OF "TEMPORARY_TABLESPACE_SIZE":
        tgtsch->user[d.seq].temp_tspace_size = dsoia.attr_value_num
       OF "SYS_PRIV_GRANT":
        tgtsch->user[d.seq].priv_cnt = (tgtsch->user[d.seq].priv_cnt+ 1),stat = alterlist(tgtsch->
         user[d.seq].privs,tgtsch->user[d.seq].priv_cnt),tgtsch->user[d.seq].privs[tgtsch->user[d.seq
        ].priv_cnt].priv_name = cnvtupper(dsoia.attr_value_char)
       OF "TABLESPACE_QUOTA":
        tgtsch->user[d.seq].quota_cnt = (tgtsch->user[d.seq].quota_cnt+ 1),stat = alterlist(tgtsch->
         user[d.seq].quota,tgtsch->user[d.seq].quota_cnt),tgtsch->user[d.seq].quota[tgtsch->user[d
        .seq].quota_cnt].tspace_name = cnvtupper(dsoia.attr_value_char)
      ENDCASE
     WITH nocounter
    ;end select
   ENDIF
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   FOR (dlccui_user_cnt = 1 TO tgtsch->user_cnt)
     SET tgtsch->tspace_cnt = (tgtsch->tspace_cnt+ 1)
     SET stat = alterlist(tgtsch->tspace,tgtsch->tspace_cnt)
     SET tgtsch->tspace[tgtsch->tspace_cnt].tspace_name = tgtsch->user[dlccui_user_cnt].
     default_tspace
     SET tgtsch->tspace[tgtsch->tspace_cnt].tspace_type = "PERMANENT"
     SET tgtsch->tspace[tgtsch->tspace_cnt].min_total_bytes = tgtsch->user[dlccui_user_cnt].
     default_tspace_size
     SET tgtsch->tspace_cnt = (tgtsch->tspace_cnt+ 1)
     SET stat = alterlist(tgtsch->tspace,tgtsch->tspace_cnt)
     SET tgtsch->tspace[tgtsch->tspace_cnt].tspace_name = tgtsch->user[dlccui_user_cnt].temp_tspace
     SET tgtsch->tspace[tgtsch->tspace_cnt].tspace_type = "TEMPORARY"
     SET tgtsch->tspace[tgtsch->tspace_cnt].min_total_bytes = tgtsch->user[dlccui_user_cnt].
     temp_tspace_size
   ENDFOR
   RETURN(1)
 END ;Subroutine
#exit_program
 IF (dtl_mode != "PKGINSTALL")
  CALL close_sch_files(null)
 ELSEIF ((dm_err->debug_flag > 4))
  CALL echorecord(tgtsch)
 ENDIF
 IF ((dm2_install_schema->schema_prefix="dm2a"))
  SET tgtsch->alpha_feature_nbr = 0
 ENDIF
 IF ((dm_err->debug_flag > 1))
  CALL display_tgt_rec_struct(null)
 ENDIF
 SET dm_err->eproc = "Exiting Target Record Structure Translate and Load Process"
 CALL final_disp_msg("dm2_trn_load")
 FREE RECORD tbl_doc
 FREE RECORD tbl_doc_maint
 FREE RECORD col_doc
 FREE RECORD col_doc_maint
 FREE RECORD ts_prec
 FREE RECORD ts_prec_maint
 FREE RECORD td_tables
 FREE RECORD dtl_tmp_tbls
 FREE RECORD dtl_indtype
 FREE RECORD dtl_user_tables
END GO
