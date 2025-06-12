CREATE PROGRAM dm2_rrr:dba
 SET trace progcachesize 255
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
 DECLARE dcl_check_lang(null) = i2
 SUBROUTINE dcl_check_lang(null)
   DECLARE ddrd_cur_lang = vc WITH protect, noconstant("DM2_NOT_SET")
   DECLARE ddrd_lang_str = vc WITH protect, noconstant("DM2_NOT_SET")
   DECLARE ddrd_idx = i4 WITH protect, noconstant(0)
   IF ((validate(dm2_bypass_lang_check,- (1))=- (1)))
    FREE RECORD ddrd_lang
    RECORD ddrd_lang(
      1 cnt = i4
      1 qual[*]
        2 lang_value = vc
    )
    SET ddrd_lang->cnt = 0
    SET dm_err->eproc = "Read dm2_tools_valid_lang.txt from cer_install"
    CALL disp_msg(" ",dm_err->logfile,0)
    FREE DEFINE rtl2
    SET logical file_name value(concat("CER_INSTALL:","dm2_tools_valid_lang.txt"))
    DEFINE rtl2 "file_name"  WITH nomodify
    SELECT INTO "nl:"
     t.line
     FROM rtl2t t
     WHERE t.line > " "
     DETAIL
      IF ((ddrd_lang->cnt=0))
       ddrd_lang_str = trim(cnvtupper(t.line))
      ELSE
       ddrd_lang_str = concat(ddrd_lang_str,", ",trim(cnvtupper(t.line)))
      ENDIF
      ddrd_lang->cnt = (ddrd_lang->cnt+ 1), stat = alterlist(ddrd_lang->qual,ddrd_lang->cnt),
      ddrd_lang->qual[ddrd_lang->cnt].lang_value = trim(cnvtupper(t.line))
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(ddrd_lang)
    ENDIF
    SET ddrd_cur_lang = cnvtupper(logical("LANG"))
    IF (ddrd_cur_lang > "")
     IF (locateval(ddrd_idx,1,ddrd_lang->cnt,ddrd_cur_lang,ddrd_lang->qual[ddrd_idx].lang_value)=0)
      SET dm_err->err_ind = 1
      SET dm_err->emsg = concat("Current LANG setting (",ddrd_cur_lang,") is not supported")
      SET dm_err->user_action = concat("Please exit CCL, alter the O/S session value of LANG ",
       "to one of the following supported values <",ddrd_lang_str,">",
       ", re-enter CCL and re-execute dm2_domain_refresh_driver")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
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
 DECLARE drrr_initialize_rf_data_rs(null) = null
 DECLARE drrr_initialize_misc_data_rs(null) = null
 DECLARE drrr_create_text_file(dctf_in_fname=vc) = i2
 DECLARE drrr_load_rf_data_rs(dldr_file=vc,dldr_mode=vc) = i2
 DECLARE drrr_val_rf_status_file(dvrsf_status_file_in) = i2
 DECLARE drrr_val_rf_version(null) = i2
 DECLARE drrr_add_text(dat_in_text=vc,dat_in_reset_ind=i2) = null
 DECLARE drrr_val_rf_client_mnemonic(null) = i2
 DECLARE drrr_val_rf_target_refresh(null) = i2
 DECLARE drrr_val_rf_adm_cnnct_data(dvracd_in_cnct_to_db_ind=i2) = i2
 DECLARE drrr_val_rf_src_cnnct_data(dvrscd_in_cnct_to_db_ind=i2) = i2
 DECLARE drrr_val_rf_tgt_cnnct_data(dvrtcd_in_cnct_to_db_ind=i2) = i2
 DECLARE drrr_val_rf_tgt_sys_cnnct_data(dvrtscd_in_cnct_to_db_ind=i2) = i2
 DECLARE drrr_val_rf_src_env_name(null) = i2
 DECLARE drrr_val_rf_src_domain_name(null) = i2
 DECLARE drrr_val_rf_src_high_priv_user(null) = i2
 DECLARE drrr_val_rf_src_app_temp_dir(null) = i2
 DECLARE drrr_val_rf_src_app_node_list(null) = i2
 DECLARE drrr_val_rf_tgt_env_name(null) = i2
 DECLARE drrr_val_rf_tgt_domain_name(null) = i2
 DECLARE drrr_val_rf_tgt_high_priv_user(null) = i2
 DECLARE drrr_val_rf_tgt_app_node_list(null) = i2
 DECLARE drrr_val_rf_tgt_app_temp_dir(null) = i2
 DECLARE drrr_val_rf_tgt_app_prim_temp_dir(null) = i2
 DECLARE drrr_val_rf_tgt_backup_warehouse(null) = i2
 DECLARE drrr_val_rf_tgt_backup_ccluserdir(null) = i2
 DECLARE drrr_val_rf_tgt_preserve_data(null) = i2
 DECLARE drrr_val_rf_tgt_redo_preserve_on_restart(null) = i2
 DECLARE drrr_val_rf_restore_preserve_data(null) = i2
 DECLARE drrr_val_rf_tgt_capture_schema_date(null) = i2
 DECLARE drrr_val_rf_tgt_tspace_increase_pct(null) = i2
 DECLARE drrr_val_write_privs(drvwp_full_dir=vc) = i4
 DECLARE drrr_val_rf_tgt_tspace_dg_list(null) = i2
 DECLARE drrr_val_rf_tgt_server_set_names(null) = i2
 DECLARE drrr_val_email_list(null) = i2
 DECLARE drrr_val_rf_tgt_background_runners(null) = i2
 DECLARE drrr_val_rf_ads(null) = i2
 DECLARE drrr_val_rf_tgt_opsexec_node_mapping(null) = i2
 DECLARE drrr_val_rf_drop_tablespaces(null) = i2
 DECLARE drrr_val_rf_tgt_retain_db_user_list(null) = i2
 DECLARE drrr_val_rf_tgt_database_users(null) = i2
 DECLARE drrr_val_rf_tgt_expimp_runners(null) = i2
 DECLARE drrr_val_rf_src_sys_cnnct_data(dvrsscd_in_cnct_to_db_ind=i2) = i2
 DECLARE drrr_val_rf_tgt_db_temp_dir(null) = i2
 DECLARE drrr_val_rf_src_db_temp_dir(null) = i2
 DECLARE drrr_val_rf_tgt_db_oracle_misc(null) = i2
 DECLARE drrr_val_rf_tgt_db_node(null) = i2
 DECLARE drrr_val_rf_tgt_db_shell_misc(null) = i2
 DECLARE drrr_val_rf_tgt_solution_chks(null) = i2
 DECLARE drrr_val_rf_tgt_apply_src_ed_registry(null) = i2
 DECLARE drrr_val_rf_tgt_registry_set_name(null) = i2
 DECLARE drrr_val_rf_tgt_wh(null) = i2
 DECLARE drrr_val_rf_tgt_ibus_env_mapping(null) = i2
 DECLARE drrr_val_rf_tgt_db_user_pwd_mapping(null) = i2
 DECLARE drrr_val_rf_datapump(null) = i2
 DECLARE drrr_val_rf_restore_list(null) = i2
 DECLARE drrr_val_rf_restore_groups(null) = i2
 DECLARE drrr_val_rf_drr_shadow_tables(null) = i2
 DECLARE drrr_val_rf_mode(null) = i2
 DECLARE drrr_val_rf_isolated_mode(null) = i2
 DECLARE drrr_val_rf_ping_nodes(dvrpn_in_src_ind=i2,dvrpn_in_tgt_ind=i2,dvrpn_in_adm_ind=i2,
  dvrpn_in_local=vc) = i2
 DECLARE drrr_val_rf_tgt_drop_db_links(null) = i2
 DECLARE drrr_val_rf_deploy_configs(null) = i2
 DECLARE drrr_val_rf_tgt_tns_mapping(null) = i2
 DECLARE drrr_load_default_tns_map(dldtm_tns_entry=vc) = i2
 DECLARE drrr_val_rf_tgt_default_tspaces(null) = i2
 DECLARE drrr_val_rf_cred_link_data(null) = i2
 IF ((validate(drrr_responsefile_in_use,- (1))=- (1))
  AND (validate(drrr_responsefile_in_use,- (2))=- (2)))
  DECLARE drrr_responsefile_in_use = i2 WITH public, noconstant(0)
 ENDIF
 IF (validate(drrr_rf_data->responsefile_version,"X")="X"
  AND validate(drrr_rf_data->responsefile_version,"Z")="Z")
  FREE RECORD drrr_rf_data
  RECORD drrr_rf_data(
    1 responsefile_version = vc
    1 client_mnemonic = vc
    1 status_file = vc
    1 target_refresh = vc
    1 adm_db_user = vc
    1 adm_db_user_pwd = vc
    1 adm_db_cnct_str = vc
    1 adm_db_oracle_ver = vc
    1 src_env_name = vc
    1 src_domain_name = vc
    1 src_db_user = vc
    1 src_db_user_pwd = vc
    1 src_db_cnct_str = vc
    1 src_db_name = vc
    1 src_high_priv_user = vc
    1 src_high_priv_user_pwd = vc
    1 src_app_temp_dir = vc
    1 src_app_node_list = vc
    1 tgt_env_name = vc
    1 tgt_domain_name = vc
    1 tgt_sys_user = vc
    1 tgt_sys_pwd = vc
    1 tgt_db_user = vc
    1 tgt_db_user_pwd = vc
    1 tgt_db_cnct_str = vc
    1 tgt_db_name = vc
    1 tgt_cdb_name = vc
    1 tgt_cdb_cnct_str = vc
    1 tgt_high_priv_user = vc
    1 tgt_high_priv_user_pwd = vc
    1 tgt_app_temp_dir = vc
    1 tgt_app_prim_temp_dir = vc
    1 tgt_app_node_list = vc
    1 tgt_primary_app_node = vc
    1 tgt_preserve_data = vc
    1 tgt_redo_preserve_on_restart = vc
    1 tgt_backup_ccluserdir = vc
    1 tgt_backup_warehouse = vc
    1 tgt_db_copy_type = vc
    1 tgt_capture_schema_date = vc
    1 tgt_tspace_increase_pct = i2
    1 tgt_tspace_dg_list = vc
    1 tgt_restore_preserve_data = vc
    1 tgt_restore_autotester = vc
    1 tgt_restore_rrd = vc
    1 tgt_restore_printers = vc
    1 tgt_restore_interfaces = vc
    1 tgt_prim_server_set_name = vc
    1 tgt_sec_server_set_name = vc
    1 email_list = vc
    1 tgt_background_runners = i2
    1 src_ads_domain_ind = i2
    1 ads_config_name = vc
    1 ads_sort_field = vc
    1 ads_sort_value = vc
    1 tgt_opsexec_node_mapping = vc
    1 tgt_drop_tablespaces = vc
    1 tgt_retain_db_user_list = vc
    1 tgt_expimp_runners = i2
    1 src_sys_user = vc
    1 src_sys_pwd = vc
    1 tgt_db_temp_dir = vc
    1 src_db_temp_dir = vc
    1 tgt_db_oracle_home = vc
    1 tgt_system_pwd = vc
    1 tgt_db_oracle_ver = vc
    1 tgt_db_oracle_base = vc
    1 tgt_db_node = vc
    1 tgt_db_env_name = vc
    1 tgt_env_desc = vc
    1 tgt_storage_dg = vc
    1 tgt_recovery_dg = vc
    1 tgt_archive_dest1 = vc
    1 tgt_asm_sysdba_pwd = vc
    1 tgt_tns_host_name = vc
    1 tgt_tns_port = vc
    1 adm_tns_port = vc
    1 tgt_shell_ignorable_error_list = vc
    1 tgt_reapply_sched_templates = vc
    1 tgt_reapply_sched_templates_range = i4
    1 tgt_reapply_sched_templates_reset = vc
    1 tgt_apply_src_ed_registry = vc
    1 tgt_reg_ed_set_name = vc
    1 tgt_top_dir = vc
    1 tgt_cer_mgr_dir = vc
    1 tgt_cer_mgr_exe_dir = vc
    1 tgt_cer_mgr_log_dir = vc
    1 tgt_cer_reg_dir = vc
    1 tgt_cer_fifo_dir = vc
    1 tgt_cer_usock_dir = vc
    1 tgt_cer_lock_dir = vc
    1 tgt_wh_name = vc
    1 tgt_wh_dir = vc
    1 tgt_user_name = vc
    1 common_to_tgt = vc
    1 tgt_copy_interrogator = vc
    1 tgt_interrogator_tmp_dir = vc
    1 tgt_shared_pool_size = vc
    1 tgt_db_node_os = vc
    1 tgt_ibus_env_mapping = vc
    1 tgt_db_user_pwd_mapping = vc
    1 tgt_dp_dir_name = vc
    1 tgt_dp_dir_path = vc
    1 src_dp_dir_setup = vc
    1 src_dp_dir_name = vc
    1 src_dp_dir_path = vc
    1 tgt_restore_list = vc
    1 tgt_expimp_drr_shadow_tables = vc
    1 mode = vc
    1 src_db_env_name = vc
    1 tgt_db_create_type = vc
    1 tgt_dbca_template = vc
    1 tgt_case_sens_logon = vc
    1 tgt_sql92_security = vc
    1 tgt_characterset = vc
    1 tgt_error_prefix_list = vc
    1 adm_db_node = vc
    1 adm_storage_dg = vc
    1 adm_recovery_dg = vc
    1 tgt_drop_db_links = vc
    1 tgt_drop_expimp_dir = vc
    1 src_drop_expimp_dir = vc
    1 src_db_deploy_config = vc
    1 tgt_db_deploy_config = vc
    1 adm_db_deploy_config = vc
    1 tgt_tns_cnct_str = vc
    1 tgt_tns_mapping = vc
    1 tgt_tns_svc_name = vc
    1 tgt_default_misc_ts = vc
    1 tgt_default_temp_ts = vc
    1 adm_db_cred_nm = vc
    1 adm_db_link_host = vc
    1 adm_db_link_port = vc
    1 adm_db_link_svc_nm = vc
    1 adm_db_link_cnct_desc = vc
    1 tgt_db_adm_db_link_name = vc
    1 tgt_db_cred_nm = vc
    1 tgt_db_link_host = vc
    1 tgt_db_link_port = vc
    1 tgt_db_link_svc_nm = vc
    1 tgt_db_link_cnct_desc = vc
    1 src_db_cred_nm = vc
    1 src_db_link_host = vc
    1 src_db_link_port = vc
    1 src_db_link_svc_nm = vc
    1 src_db_link_cnct_desc = vc
    1 tgt_app_oracle_home = vc
    1 tgt_app_oracle_client_ver = vc
    1 tgt_app_dp_temp_dir = vc
    1 tgt_app_dp_node = vc
    1 dp_cred_name = vc
    1 dp_user = vc
    1 dp_user_pwd = vc
    1 dp_oos_dir_path = vc
  )
  CALL drrr_initialize_rf_data_rs(null)
 ENDIF
 IF (validate(drrr_misc_data->status_dir,"X")="X"
  AND validate(drrr_misc_data->status_dir,"Z")="Z")
  FREE RECORD drrr_misc_data
  RECORD drrr_misc_data(
    1 status_dir = vc
    1 status_file = vc
    1 response_file_dir = vc
    1 response_file_name = vc
    1 src_app_node_cnt = i4
    1 src_app_nodes[*]
      2 node_name = vc
    1 tgt_app_node_cnt = i4
    1 tgt_app_nodes[*]
      2 node_name = vc
    1 active_dir = vc
    1 process_mode = vc
    1 process_type = vc
    1 tgt_tspace_dg_cnt = i4
    1 tgt_tspace_dg[*]
      2 disk_group = vc
    1 tgt_opsexec_map_cnt = i4
    1 tgt_opsexec_map[*]
      2 src_node = vc
      2 tgt_node = vc
    1 tgt_retain_db_user_cnt = i4
    1 tgt_retain_db_users[*]
      2 user_name = vc
    1 tgt_shell_ign_error_cnt = i4
    1 tgt_shell_ign_errors[*]
      2 error_cd = vc
    1 process_id = f8
    1 event_id = f8
    1 tgt_ibus_env_map_cnt = i4
    1 tgt_ibus_env_map[*]
      2 src_ibus_env = vc
      2 tgt_ibus_env = vc
    1 tgt_db_user_pwd_map_cnt = i4
    1 tgt_db_user_pwd_map[*]
      2 user = vc
      2 pwd = vc
    1 tgt_restore_list_cnt = i4
    1 tgt_restore_list[*]
      2 restore_group = vc
      2 restore_ind = i2
    1 tgt_tns_map_cnt = i4
    1 tgt_tns_map[*]
      2 tns_entry = vc
      2 service_name = vc
      2 host = vc
      2 port = vc
  )
  CALL drrr_initialize_misc_data_rs(null)
 ENDIF
 IF ((validate(drrr_ftxt->txt_cnt,- (1))=- (1))
  AND (validate(drrr_ftxt->txt_cnt,- (2))=- (2)))
  FREE RECORD drrr_ftxt
  RECORD drrr_ftxt(
    1 txt_cnt = i4
    1 txt[*]
      2 txt_line = vc
  )
 ENDIF
 FREE RECORD drrr_raw_data
 RECORD drrr_raw_data(
   1 qual[*]
     2 item = vc
     2 itemx = vc
     2 type = vc
     2 item_value = vc
 )
 SUBROUTINE drrr_initialize_rf_data_rs(null)
   SET drrr_rf_data->responsefile_version = "DM2NOTSET"
   SET drrr_rf_data->client_mnemonic = "DM2NOTSET"
   SET drrr_rf_data->status_file = "DM2NOTSET"
   SET drrr_rf_data->target_refresh = "DM2NOTSET"
   SET drrr_rf_data->adm_db_user = "DM2NOTSET"
   SET drrr_rf_data->adm_db_user_pwd = "DM2NOTSET"
   SET drrr_rf_data->adm_db_cnct_str = "DM2NOTSET"
   SET drrr_rf_data->adm_db_oracle_ver = "DM2NOTSET"
   SET drrr_rf_data->src_env_name = "DM2NOTSET"
   SET drrr_rf_data->src_domain_name = "DM2NOTSET"
   SET drrr_rf_data->src_db_user = "DM2NOTSET"
   SET drrr_rf_data->src_db_user_pwd = "DM2NOTSET"
   SET drrr_rf_data->src_db_cnct_str = "DM2NOTSET"
   SET drrr_rf_data->src_db_name = "DM2NOTSET"
   SET drrr_rf_data->src_high_priv_user = "DM2NOTSET"
   SET drrr_rf_data->src_high_priv_user_pwd = "DM2NOTSET"
   SET drrr_rf_data->src_app_temp_dir = "DM2NOTSET"
   SET drrr_rf_data->src_app_node_list = "DM2NOTSET"
   SET drrr_rf_data->tgt_db_copy_type = "DM2NOTSET"
   SET drrr_rf_data->tgt_env_name = "DM2NOTSET"
   SET drrr_rf_data->tgt_domain_name = "DM2NOTSET"
   SET drrr_rf_data->tgt_sys_user = "DM2NOTSET"
   SET drrr_rf_data->tgt_sys_pwd = "DM2NOTSET"
   SET drrr_rf_data->tgt_db_user = "DM2NOTSET"
   SET drrr_rf_data->tgt_db_user_pwd = "DM2NOTSET"
   SET drrr_rf_data->tgt_db_cnct_str = "DM2NOTSET"
   SET drrr_rf_data->tgt_db_name = "DM2NOTSET"
   SET drrr_rf_data->tgt_cdb_name = "DM2NOTSET"
   SET drrr_rf_data->tgt_cdb_cnct_str = "DM2NOTSET"
   SET drrr_rf_data->tgt_high_priv_user = "DM2NOTSET"
   SET drrr_rf_data->tgt_high_priv_user_pwd = "DM2NOTSET"
   SET drrr_rf_data->tgt_app_temp_dir = "DM2NOTSET"
   SET drrr_rf_data->tgt_app_prim_temp_dir = "DM2NOTSET"
   SET drrr_rf_data->tgt_app_node_list = "DM2NOTSET"
   SET drrr_rf_data->tgt_primary_app_node = "DM2NOTSET"
   SET drrr_rf_data->tgt_preserve_data = "DM2NOTSET"
   SET drrr_rf_data->tgt_backup_ccluserdir = "DM2NOTSET"
   SET drrr_rf_data->tgt_backup_warehouse = "DM2NOTSET"
   SET drrr_rf_data->tgt_capture_schema_date = "DM2NOTSET"
   SET drrr_rf_data->tgt_tspace_increase_pct = - (999)
   SET drrr_rf_data->tgt_tspace_dg_list = "DM2NOTSET"
   SET drrr_rf_data->tgt_prim_server_set_name = "DM2NOTSET"
   SET drrr_rf_data->tgt_sec_server_set_name = "DM2NOTSET"
   SET drrr_rf_data->email_list = "DM2NOTSET"
   SET drrr_rf_data->tgt_background_runners = - (999)
   SET drrr_rf_data->src_ads_domain_ind = - (999)
   SET drrr_rf_data->ads_config_name = "DM2NOTSET"
   SET drrr_rf_data->ads_sort_field = "DM2NOTSET"
   SET drrr_rf_data->ads_sort_value = "DM2NOTSET"
   SET drrr_rf_data->tgt_opsexec_node_mapping = "DM2NOTSET"
   SET drrr_rf_data->tgt_drop_tablespaces = "DM2NOTSET"
   SET drrr_rf_data->tgt_retain_db_user_list = "DM2NOTSET"
   SET drrr_rf_data->tgt_expimp_runners = - (999)
   SET drrr_rf_data->src_sys_user = "DM2NOTSET"
   SET drrr_rf_data->src_sys_pwd = "DM2NOTSET"
   SET drrr_rf_data->tgt_db_temp_dir = "DM2NOTSET"
   SET drrr_rf_data->src_db_temp_dir = "DM2NOTSET"
   SET drrr_rf_data->tgt_db_oracle_home = "DM2NOTSET"
   SET drrr_rf_data->tgt_system_pwd = "DM2NOTSET"
   SET drrr_rf_data->tgt_db_oracle_ver = "DM2NOTSET"
   SET drrr_rf_data->tgt_db_oracle_base = "DM2NOTSET"
   SET drrr_rf_data->tgt_db_node = "DM2NOTSET"
   SET drrr_rf_data->tgt_db_env_name = "DM2NOTSET"
   SET drrr_rf_data->tgt_env_desc = "DM2NOTSET"
   SET drrr_rf_data->tgt_storage_dg = "DM2NOTSET"
   SET drrr_rf_data->tgt_recovery_dg = "DM2NOTSET"
   SET drrr_rf_data->tgt_archive_dest1 = "DM2NOTSET"
   SET drrr_rf_data->tgt_asm_sysdba_pwd = "DM2NOTSET"
   SET drrr_rf_data->tgt_tns_host_name = "DM2NOTSET"
   SET drrr_rf_data->tgt_tns_port = "DM2NOTSET"
   SET drrr_rf_data->adm_tns_port = "DM2NOTSET"
   SET drrr_rf_data->tgt_shell_ignorable_error_list = "DM2NOTSET"
   SET drrr_rf_data->tgt_reapply_sched_templates = "DM2NOTSET"
   SET drrr_rf_data->tgt_reapply_sched_templates_range = - (999)
   SET drrr_rf_data->tgt_reapply_sched_templates_reset = "DM2NOTSET"
   SET drrr_rf_data->tgt_apply_src_ed_registry = "DM2NOTSET"
   SET drrr_rf_data->tgt_reg_ed_set_name = "DM2NOTSET"
   SET drrr_rf_data->tgt_top_dir = "DM2NOTSET"
   SET drrr_rf_data->tgt_cer_mgr_dir = "DM2NOTSET"
   SET drrr_rf_data->tgt_cer_mgr_exe_dir = "DM2NOTSET"
   SET drrr_rf_data->tgt_cer_mgr_log_dir = "DM2NOTSET"
   SET drrr_rf_data->tgt_cer_reg_dir = "DM2NOTSET"
   SET drrr_rf_data->tgt_cer_fifo_dir = "DM2NOTSET"
   SET drrr_rf_data->tgt_cer_usock_dir = "DM2NOTSET"
   SET drrr_rf_data->tgt_cer_lock_dir = "DM2NOTSET"
   SET drrr_rf_data->tgt_wh_name = "DM2NOTSET"
   SET drrr_rf_data->tgt_wh_dir = "DM2NOTSET"
   SET drrr_rf_data->tgt_user_name = "DM2NOTSET"
   SET drrr_rf_data->common_to_tgt = "DM2NOTSET"
   SET drrr_rf_data->tgt_shared_pool_size = "DM2NOTSET"
   SET drrr_rf_data->tgt_db_node_os = "DM2NOTSET"
   SET drrr_rf_data->tgt_ibus_env_mapping = "DM2NOTSET"
   SET drrr_rf_data->tgt_db_user_pwd_mapping = "DM2NOTSET"
   SET drrr_rf_data->tgt_dp_dir_name = "DM2NOTSET"
   SET drrr_rf_data->tgt_dp_dir_path = "DM2NOTSET"
   SET drrr_rf_data->src_dp_dir_setup = "DM2NOTSET"
   SET drrr_rf_data->src_dp_dir_name = "DM2NOTSET"
   SET drrr_rf_data->src_dp_dir_path = "DM2NOTSET"
   SET drrr_rf_data->tgt_restore_list = "DM2NOTSET"
   SET drrr_rf_data->tgt_expimp_drr_shadow_tables = "DM2NOTSET"
   SET drrr_rf_data->mode = "DM2NOTSET"
   SET drrr_rf_data->src_db_env_name = "DM2NOTSET"
   SET drrr_rf_data->tgt_db_create_type = "DM2NOTSET"
   SET drrr_rf_data->tgt_dbca_template = "DM2NOTSET"
   SET drrr_rf_data->tgt_case_sens_logon = "DM2NOTSET"
   SET drrr_rf_data->tgt_sql92_security = "DM2NOTSET"
   SET drrr_rf_data->tgt_characterset = "DM2NOTSET"
   SET drrr_rf_data->tgt_error_prefix_list = "DM2NOTSET"
   SET drrr_rf_data->adm_db_node = "DM2NOTSET"
   SET drrr_rf_data->adm_storage_dg = "DM2NOTSET"
   SET drrr_rf_data->adm_recovery_dg = "DM2NOTSET"
   SET drrr_rf_data->tgt_drop_db_links = "DM2NOTSET"
   SET drrr_rf_data->tgt_drop_expimp_dir = "DM2NOTSET"
   SET drrr_rf_data->src_drop_expimp_dir = "DM2NOTSET"
   SET drrr_rf_data->src_db_deploy_config = "DM2NOTSET"
   SET drrr_rf_data->tgt_db_deploy_config = "DM2NOTSET"
   SET drrr_rf_data->adm_db_deploy_config = "DM2NOTSET"
   SET drrr_rf_data->tgt_tns_mapping = "DM2NOTSET"
   SET drrr_rf_data->tgt_tns_cnct_str = "DM2NOTSET"
   SET drrr_rf_data->tgt_tns_svc_name = "DM2NOTSET"
   SET drrr_rf_data->tgt_default_misc_ts = "DM2NOTSET"
   SET drrr_rf_data->tgt_default_temp_ts = "DM2NOTSET"
   SET drrr_rf_data->adm_db_cred_nm = "DM2NOTSET"
   SET drrr_rf_data->adm_db_link_host = "DM2NOTSET"
   SET drrr_rf_data->adm_db_link_port = "DM2NOTSET"
   SET drrr_rf_data->adm_db_link_svc_nm = "DM2NOTSET"
   SET drrr_rf_data->adm_db_link_cnct_desc = "DM2NOTSET"
   SET drrr_rf_data->tgt_db_adm_db_link_name = "DM2NOTSET"
   SET drrr_rf_data->tgt_db_cred_nm = "DM2NOTSET"
   SET drrr_rf_data->tgt_db_link_host = "DM2NOTSET"
   SET drrr_rf_data->tgt_db_link_port = "DM2NOTSET"
   SET drrr_rf_data->tgt_db_link_svc_nm = "DM2NOTSET"
   SET drrr_rf_data->tgt_db_link_cnct_desc = "DM2NOTSET"
   SET drrr_rf_data->src_db_cred_nm = "DM2NOTSET"
   SET drrr_rf_data->src_db_link_host = "DM2NOTSET"
   SET drrr_rf_data->src_db_link_port = "DM2NOTSET"
   SET drrr_rf_data->src_db_link_svc_nm = "DM2NOTSET"
   SET drrr_rf_data->src_db_link_cnct_desc = "DM2NOTSET"
   SET drrr_rf_data->tgt_app_oracle_home = "DM2NOTSET"
   SET drrr_rf_data->tgt_app_oracle_client_ver = "DM2NOTSET"
   SET drrr_rf_data->tgt_app_dp_temp_dir = "DM2NOTSET"
   SET drrr_rf_data->tgt_app_dp_node = "DM2NOTSET"
   SET drrr_rf_data->dp_cred_name = "DM2NOTSET"
   SET drrr_rf_data->dp_user = "DM2NOTSET"
   SET drrr_rf_data->dp_user_pwd = "DM2NOTSET"
   SET drrr_rf_data->dp_oos_dir_path = "DM2NOTSET"
 END ;Subroutine
 SUBROUTINE drrr_initialize_misc_data_rs(null)
   SET drrr_misc_data->status_dir = "DM2NOTSET"
   SET drrr_misc_data->status_file = "DM2NOTSET"
   SET drrr_misc_data->response_file_dir = "DM2NOTSET"
   SET drrr_misc_data->response_file_name = "DM2NOTSET"
   SET drrr_misc_data->src_app_node_cnt = 0
   SET stat = alterlist(drrr_misc_data->src_app_nodes,0)
   SET drrr_misc_data->tgt_app_node_cnt = 0
   SET stat = alterlist(drrr_misc_data->tgt_app_nodes,0)
   SET drrr_misc_data->active_dir = "DM2NOTSET"
   SET drrr_misc_data->process_mode = "DM2NOTSET"
   SET drrr_misc_data->process_type = "DM2NOTSET"
   SET drrr_misc_data->tgt_tspace_dg_cnt = 0
   SET stat = alterlist(drrr_misc_data->tgt_tspace_dg,0)
   SET drrr_misc_data->tgt_opsexec_map_cnt = 0
   SET stat = alterlist(drrr_misc_data->tgt_opsexec_map,0)
   SET drrr_misc_data->tgt_retain_db_user_cnt = 0
   SET stat = alterlist(drrr_misc_data->tgt_retain_db_users,0)
   SET drrr_misc_data->tgt_shell_ign_error_cnt = 0
   SET stat = alterlist(drrr_misc_data->tgt_shell_ign_errors,0)
   SET drrr_misc_data->process_id = 0.0
   SET drrr_misc_data->event_id = 0.0
   SET drrr_misc_data->tgt_ibus_env_map_cnt = 0
   SET stat = alterlist(drrr_misc_data->tgt_ibus_env_map,0)
   SET drrr_misc_data->tgt_db_user_pwd_map_cnt = 0
   SET stat = alterlist(drrr_misc_data->tgt_db_user_pwd_map,0)
   SET drrr_misc_data->tgt_restore_list_cnt = 0
   SET stat = alterlist(drrr_misc_data->tgt_restore_list,0)
   SET drrr_misc_data->tgt_tns_map_cnt = 0
   SET stat = alterlist(drrr_misc_data->tgt_tns_map,0)
 END ;Subroutine
 SUBROUTINE drrr_load_rf_data_rs(dldr_in_file,dldr_mode)
   DECLARE dldr_cnt = i4 WITH protect, noconstant(0)
   DECLARE dldr_rf_dir = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dldr_rf_name = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dldr_dir_found_ind = i2 WITH protect, noconstant(0)
   DECLARE dldr_tmp_rs_item = vc WITH protect, noconstant("")
   DECLARE dldr_tmp_rs_item_value = vc WITH protect, noconstant("")
   DECLARE dldr_item_name = vc WITH protect, noconstant("")
   DECLARE dldr_process_item = i2 WITH protect, noconstant(0)
   SET drrr_misc_data->response_file_dir = "DM2NOTSET"
   SET drrr_misc_data->response_file_name = "DM2NOTSET"
   IF (dm2_findfile(dldr_in_file)=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file exists:  ",dldr_in_file)
    SET dm_err->emsg = "Response file not found."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (findstring("/",dldr_in_file,1,0)=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file: ",dldr_in_file)
    SET dm_err->emsg = "Response file requires both directory and file name."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    SET dldr_rf_dir = build(cnvtlower(substring(1,(findstring("/",dldr_in_file,1,1) - 1),dldr_in_file
       )),"/")
    SET dldr_rf_name = cnvtlower(trim(substring((findstring("/",dldr_in_file,1,1)+ 1),(size(
        dldr_in_file) - findstring("=",dldr_in_file,1,0)),dldr_in_file),3))
    SET dldr_dir_found_ind = 0
    SET dldr_dir_found_ind = dm2_find_dir(dldr_rf_dir)
    IF ((dm_err->err_ind > 0))
     RETURN(0)
    ENDIF
    IF (dldr_dir_found_ind=0)
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file : ",dldr_in_file)
     SET dm_err->emsg = concat("Response file directory (",trim(dldr_rf_dir,3),") not found.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (((dldr_rf_name="DM2NOTSET") OR (size(trim(dldr_rf_name,3))=0)) )
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file : ",dldr_in_file)
     SET dm_err->emsg = concat("Response file name (",trim(dldr_rf_name,3),") not set.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET drrr_misc_data->response_file_dir = dldr_rf_dir
    SET drrr_misc_data->response_file_name = dldr_rf_name
   ENDIF
   SET dm_err->eproc = "Accessing response file..."
   CALL disp_msg(" ",dm_err->logfile,0)
   FREE SET dldr_response_file
   SET logical dldr_response_file dldr_in_file
   FREE DEFINE rtl3
   DEFINE rtl3 "dldr_response_file"
   SELECT INTO "nl:"
    t.line
    FROM rtl3t t
    WHERE t.line > " "
    DETAIL
     IF (trim(t.line) > ""
      AND trim(substring(1,1,trim(t.line)),3) != "#")
      dldr_tmp_rs_item = trim(cnvtlower(substring(1,(findstring("=",t.line,1,0) - 1),t.line)),3),
      dldr_tmp_rs_item_value = trim(substring((findstring("=",t.line,1,0)+ 1),(size(t.line) -
        findstring("=",t.line,1,0)),t.line),3)
      IF (substring(1,3,dldr_tmp_rs_item)="sl_")
       IF (findstring("{",dldr_tmp_rs_item_value,1,0) > 0
        AND findstring("}",dldr_tmp_rs_item_value,1,0) > 0
        AND findstring('"',dldr_tmp_rs_item_value,1,0) > 0
        AND findstring('"',dldr_tmp_rs_item_value,1,0) != findstring('"',dldr_tmp_rs_item_value,1,1))
        dldr_cnt = (dldr_cnt+ 1), stat = alterlist(drrr_raw_data->qual,dldr_cnt), drrr_raw_data->
        qual[dldr_cnt].item = dldr_tmp_rs_item,
        drrr_raw_data->qual[dldr_cnt].item_value = dldr_tmp_rs_item_value, drrr_raw_data->qual[
        dldr_cnt].type = "STRINGLIST", drrr_raw_data->qual[dldr_cnt].item_value = replace(
         drrr_raw_data->qual[dldr_cnt].item_value,"{","^",0),
        drrr_raw_data->qual[dldr_cnt].item_value = replace(drrr_raw_data->qual[dldr_cnt].item_value,
         "}","^",0), drrr_raw_data->qual[dldr_cnt].itemx = trim(replace(drrr_raw_data->qual[dldr_cnt]
          .item,"sl_","",1),3)
       ENDIF
      ELSEIF (substring(1,4,dldr_tmp_rs_item)="slp_")
       IF (findstring('"',dldr_tmp_rs_item_value,1,0) > 0)
        dldr_cnt = (dldr_cnt+ 1), stat = alterlist(drrr_raw_data->qual,dldr_cnt), drrr_raw_data->
        qual[dldr_cnt].item = dldr_tmp_rs_item,
        drrr_raw_data->qual[dldr_cnt].item_value = dldr_tmp_rs_item_value, drrr_raw_data->qual[
        dldr_cnt].type = "STRINGLIST", drrr_raw_data->qual[dldr_cnt].item_value = replace(
         drrr_raw_data->qual[dldr_cnt].item_value,'"'," <=CERNd=>",0),
        drrr_raw_data->qual[dldr_cnt].item_value = build('"',drrr_raw_data->qual[dldr_cnt].item_value,
         '"'), drrr_raw_data->qual[dldr_cnt].itemx = trim(replace(drrr_raw_data->qual[dldr_cnt].item,
          "slp_","",1),3)
       ENDIF
      ELSEIF (((substring(1,2,dldr_tmp_rs_item)="s_") OR (substring(1,5,dldr_tmp_rs_item)="clog_")) )
       IF (findstring('"',dldr_tmp_rs_item_value,1,0) > 0
        AND findstring('"',dldr_tmp_rs_item_value,1,0) != findstring('"',dldr_tmp_rs_item_value,1,1))
        dldr_cnt = (dldr_cnt+ 1), stat = alterlist(drrr_raw_data->qual,dldr_cnt), drrr_raw_data->
        qual[dldr_cnt].item = dldr_tmp_rs_item,
        drrr_raw_data->qual[dldr_cnt].item_value = dldr_tmp_rs_item_value, drrr_raw_data->qual[
        dldr_cnt].type = "STRING", drrr_raw_data->qual[dldr_cnt].itemx = trim(replace(drrr_raw_data->
          qual[dldr_cnt].item,"s_","",1),3)
       ENDIF
      ELSEIF (substring(1,2,dldr_tmp_rs_item)="n_")
       dldr_cnt = (dldr_cnt+ 1), stat = alterlist(drrr_raw_data->qual,dldr_cnt), drrr_raw_data->qual[
       dldr_cnt].item = dldr_tmp_rs_item,
       drrr_raw_data->qual[dldr_cnt].item_value = dldr_tmp_rs_item_value, drrr_raw_data->qual[
       dldr_cnt].type = "NUMBER", drrr_raw_data->qual[dldr_cnt].itemx = trim(replace(drrr_raw_data->
         qual[dldr_cnt].item,"n_","",1),3)
      ELSEIF (substring(1,2,dldr_tmp_rs_item)="b_")
       dldr_cnt = (dldr_cnt+ 1), stat = alterlist(drrr_raw_data->qual,dldr_cnt), drrr_raw_data->qual[
       dldr_cnt].item = dldr_tmp_rs_item,
       drrr_raw_data->qual[dldr_cnt].item_value = dldr_tmp_rs_item_value, drrr_raw_data->qual[
       dldr_cnt].type = "BOOLEAN", drrr_raw_data->qual[dldr_cnt].itemx = trim(replace(drrr_raw_data->
         qual[dldr_cnt].item,"b_","",1),3)
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   FREE SET dldr_response_file
   FREE DEFINE rtl3
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(drrr_raw_data)
   ENDIF
   IF (dldr_cnt=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file content:  ",dldr_in_file)
    SET dm_err->emsg = "Response file does not contain any data."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dldr_mode="INITIAL_LOAD")
    RETURN(1)
   ENDIF
   SET dldr_cnt = 0
   FOR (dldr_cnt = 1 TO size(drrr_raw_data->qual,5))
     SET dldr_item_name = build("drrr_rf_data->",drrr_raw_data->qual[dldr_cnt].itemx)
     SET dldr_process_item = 1
     IF ((drrr_raw_data->qual[dldr_cnt].type IN ("STRINGLIST", "STRING")))
      IF (validate(parser(dldr_item_name),"X")="X"
       AND validate(parser(dldr_item_name),"Z")="Z")
       SET dldr_process_item = 0
       IF ((dm_err->debug_flag > 0))
        CALL echo(concat("Record item ",build(dldr_item_name)," not found in structure.  Skipping."))
       ENDIF
      ENDIF
     ELSE
      IF (validate(parser(dldr_item_name),1)=1
       AND validate(parser(dldr_item_name),2)=2)
       SET dldr_process_item = 0
       IF ((dm_err->debug_flag > 0))
        CALL echo(concat("Record item ",build(dldr_item_name)," not found in structure.  Skipping."))
       ENDIF
      ENDIF
     ENDIF
     IF (dldr_process_item=1)
      IF ((drrr_raw_data->qual[dldr_cnt].type="BOOLEAN"))
       IF (cnvtupper(drrr_raw_data->qual[dldr_cnt].item_value)="TRUE")
        IF ((dm_err->debug_flag > 0))
         CALL echo(concat("set drrr_rf_data->",drrr_raw_data->qual[dldr_cnt].itemx," = 1 go"))
        ENDIF
        CALL parser(concat("set drrr_rf_data->",drrr_raw_data->qual[dldr_cnt].temx," = 1 go"),1)
       ELSEIF (cnvtupper(drrr_raw_data->qual[dldr_cnt].item_value)="FALSE")
        IF ((dm_err->debug_flag > 0))
         CALL echo(concat("set drrr_rf_data->",drrr_raw_data->qual[dldr_cnt].itemx," = 0 go"))
        ENDIF
        CALL parser(concat("set drrr_rf_data->",drrr_raw_data->qual[dldr_cnt].itemx," = 0 go"),1)
       ELSE
        SET dm_err->err_ind = 1
        SET dm_err->eproc = concat("Validating response file data:  ",drrr_raw_data->qual[dldr_cnt].
         item)
        SET dm_err->emsg = "Token is BOOLEAN data_type but does not have value of true/false."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        SET dldr_cnt = size(drrr_raw_data->qual,5)
       ENDIF
      ELSEIF ((drrr_raw_data->qual[dldr_cnt].type="NUMBER"))
       IF ((dm_err->debug_flag > 0))
        CALL echo(concat("set drrr_rf_data->",drrr_raw_data->qual[dldr_cnt].itemx," = ",drrr_raw_data
          ->qual[dldr_cnt].item_value," go"))
       ENDIF
       IF (isnumeric(drrr_raw_data->qual[dldr_cnt].item_value) != 1
        AND cnvtupper(drrr_raw_data->qual[dldr_cnt].item_value) != "*VALUE*UNSPECIFIED*")
        SET dm_err->err_ind = 1
        SET dm_err->eproc = concat("Validating response file data:  ",drrr_raw_data->qual[dldr_cnt].
         item)
        SET dm_err->emsg =
        "Token is NUMBER data_type but does not have numeric token value (token required)."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        SET dldr_cnt = size(drrr_raw_data->qual,5)
       ENDIF
       IF (cnvtupper(drrr_raw_data->qual[dldr_cnt].item_value)="*VALUE*UNSPECIFIED*")
        CALL parser(concat("set drrr_rf_data->",drrr_raw_data->qual[dldr_cnt].itemx," = -999 go"),1)
       ELSE
        CALL parser(concat("set drrr_rf_data->",drrr_raw_data->qual[dldr_cnt].itemx," = ",
          drrr_raw_data->qual[dldr_cnt].item_value," go"),1)
       ENDIF
      ELSE
       IF ((dm_err->debug_flag > 0))
        CALL echo(concat("set drrr_rf_data->",drrr_raw_data->qual[dldr_cnt].itemx," = ",drrr_raw_data
          ->qual[dldr_cnt].item_value," go"))
       ENDIF
       CALL parser(concat("set drrr_rf_data->",drrr_raw_data->qual[dldr_cnt].itemx," = ",
         drrr_raw_data->qual[dldr_cnt].item_value," go"),1)
      ENDIF
     ENDIF
   ENDFOR
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(drrr_rf_data)
    CALL echorecord(drrr_misc_data)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_version(null)
   DECLARE dvrv_rf_template_name = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dvrv_rf_template_version = vc WITH protect, noconstant("DM2NOTSET")
   IF ((((drrr_rf_data->responsefile_version="DM2NOTSET")) OR (size(trim(drrr_rf_data->
     responsefile_version,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file version: ",drrr_rf_data->
     responsefile_version)
    SET dm_err->emsg = "Response file version not set."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    SET dvrv_rf_template_name = build(dm2_install_schema->cer_install,"dm2_rr_resp_file_template.txt"
     )
    IF (dm2_findfile(dvrv_rf_template_name)=0)
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file template exists:  ",dvrv_rf_template_name)
     SET dm_err->emsg = "Response file template not found."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Accessing response file template to retrieve version..."
    CALL disp_msg(" ",dm_err->logfile,0)
    FREE SET dldr_rf_template
    SET logical dldr_rf_template dvrv_rf_template_name
    FREE DEFINE rtl3
    DEFINE rtl3 "dldr_rf_template"
    SELECT INTO "nl:"
     t.line
     FROM rtl3t t
     WHERE t.line="*RESPONSEFILE_VERSION*"
     DETAIL
      IF (cnvtupper(substring(1,22,trim(t.line)))="S_RESPONSEFILE_VERSION")
       dvrv_rf_template_version = trim(substring((findstring("=",t.line,1,0)+ 1),(size(t.line) -
         findstring("=",t.line,1,0)),t.line),3), dvrv_rf_template_version = replace(
        dvrv_rf_template_version,'"',"",0)
      ENDIF
     WITH nocounter
    ;end select
    FREE SET dldr_rp_template
    FREE DEFINE rtl3
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echo(concat("Template version:  ",dvrv_rf_template_version))
    ENDIF
    IF (((dvrv_rf_template_version="DM2NOTSET") OR (size(trim(dvrv_rf_template_version,3))=0)) )
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file template version: ",
      dvrv_rf_template_version)
     SET dm_err->emsg = "Response file template version not set."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF ((drrr_rf_data->responsefile_version != dvrv_rf_template_version))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file template version: ",
      dvrv_rf_template_version)
     SET dm_err->emsg = concat("Response file version (",trim(drrr_rf_data->responsefile_version,3),
      ") does not match template version (",trim(dvrv_rf_template_version,3),").")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_status_file(dvrsf_status_file_in)
   DECLARE dvrsf_status_dir = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dvrsf_status_file = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dvrsf_dir_found_ind = i2 WITH protect, noconstant(0)
   SET drrr_misc_data->status_dir = "DM2NOTSET"
   SET drrr_misc_data->status_file = "DM2NOTSET"
   IF (((dvrsf_status_file_in="DM2NOTSET") OR (size(trim(dvrsf_status_file_in,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating STATUS_FILE: ",dvrsf_status_file_in)
    SET dm_err->emsg = "Response file status directory/file not set."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (findstring("/",dvrsf_status_file_in,1,0)=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating STATUS_FILE: ",dvrsf_status_file_in)
    SET dm_err->emsg = "Status file requires both directory and file name."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    IF (textlen(dvrsf_status_file_in) > 200)
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating STATUS_FILE: ",dvrsf_status_file_in)
     SET dm_err->emsg = concat("Full path of status file should not exceed 200 characters.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dvrsf_status_dir = build(cnvtlower(substring(1,(findstring("/",dvrsf_status_file_in,1,1) - 1),
       dvrsf_status_file_in)),"/")
    SET dvrsf_status_file = cnvtlower(trim(substring((findstring("/",dvrsf_status_file_in,1,1)+ 1),(
       size(dvrsf_status_file_in) - findstring("=",dvrsf_status_file_in,1,0)),dvrsf_status_file_in),3
      ))
    SET dvrsf_dir_found_ind = 0
    SET dvrsf_dir_found_ind = dm2_find_dir(dvrsf_status_dir)
    IF ((dm_err->err_ind > 0))
     RETURN(0)
    ENDIF
    IF (dvrsf_dir_found_ind=0)
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating STATUS_FILE: ",dvrsf_status_file_in)
     SET dm_err->emsg = concat("STATUS_FILE directory (",trim(dvrsf_status_dir,3),") not found.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (((dvrsf_status_file="DM2NOTSET") OR (size(trim(dvrsf_status_file,3))=0)) )
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating STATUS_FILE: ",dvrsf_status_file_in)
     SET dm_err->emsg = concat("STATUS_FILE name (",trim(dvrsf_status_file,3),") not set.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dm2_findfile(dvrsf_status_file_in) > 0)
     SET dm_err->eproc = concat("Remove: ",dvrsf_status_file_in)
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     IF (dm2_push_dcl(concat("rm ",dvrsf_status_file_in))=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   SET drrr_misc_data->status_dir = dvrsf_status_dir
   SET drrr_misc_data->status_file = dvrsf_status_file
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_add_text(dat_in_txt,dat_in_reset_ind)
   IF (dat_in_reset_ind=1)
    SET drrr_ftxt->txt_cnt = 1
    SET stat = alterlist(drrr_ftxt->txt,1)
    SET drrr_ftxt->txt[drrr_ftxt->txt_cnt].txt_line = dat_in_txt
   ELSE
    SET drrr_ftxt->txt_cnt = (drrr_ftxt->txt_cnt+ 1)
    SET stat = alterlist(drrr_ftxt->txt,drrr_ftxt->txt_cnt)
    SET drrr_ftxt->txt[drrr_ftxt->txt_cnt].txt_line = dat_in_txt
   ENDIF
 END ;Subroutine
 SUBROUTINE drrr_create_text_file(dctf_in_fname)
   DECLARE dctf_cnt = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = concat("Writing ",trim(dctf_in_fname)," file.")
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO value(dctf_in_fname)
    FROM (dummyt d  WITH seq = value(drrr_ftxt->txt_cnt))
    DETAIL
     CALL print(substring(1,4000,drrr_ftxt->txt[d.seq].txt_line)), row + 1
    WITH nocounter, format = variable, formfeed = none,
     maxrow = 1, maxcol = 5000
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   CALL drrr_add_text(" ",1)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_client_mnemonic(null)
  IF (((cnvtupper(drrr_rf_data->client_mnemonic) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
  "DM2NOTSET")) OR (size(trim(drrr_rf_data->client_mnemonic,3))=0)) )
   SET dm_err->err_ind = 1
   SET dm_err->eproc = concat("Validating response file CLIENT_MNEMONIC: ",drrr_rf_data->
    client_mnemonic)
   SET dm_err->emsg = "Response file CLIENT_MNEMONIC must be set to a specific value."
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   RETURN(0)
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_target_refresh(null)
   IF ( NOT (cnvtupper(drrr_rf_data->target_refresh) IN ("YES", "NO")))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file TARGET_REFRESH: ",drrr_rf_data->
     target_refresh)
    SET dm_err->emsg = 'Response file TARGET_REFRESH must be equal to "YES" or "NO".'
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET drrr_rf_data->target_refresh = cnvtupper(drrr_rf_data->target_refresh)
   SET drrr_misc_data->process_type = evaluate(drrr_rf_data->target_refresh,"YES","REFRESH",
    "REPLICATE")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_db_copy_type(null)
   IF ( NOT (cnvtupper(drrr_rf_data->tgt_db_copy_type) IN ("ALTERNATE", "REFERENCE", "ALL", "ADS")))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file TGT_DB_COPY_TYPE: ",drrr_rf_data->
     tgt_db_copy_type)
    SET dm_err->emsg =
    'Response file TGT_DB_COPY_TYPE must be equal to "ALTERNATE", "REFERENCE", "ALL" or "ADS".'
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET drrr_rf_data->tgt_db_copy_type = cnvtupper(drrr_rf_data->tgt_db_copy_type)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_ads(null)
   IF ( NOT (cnvtupper(drrr_rf_data->ads_sort_field) IN ("TABLE NAME", "DRIVER TABLE NAME",
   "SAMPLE METHOD", "TABLESPACE NAME", "SOURCE NUM ROWS",
   "TARGET NUM ROWS", "TGT/SRC PERCENT")))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file ADS_SORT_FIELD: ",drrr_rf_data->
     ads_sort_field)
    SET dm_err->emsg = "Response file ADS_SORT_FIELD is not valid."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET drrr_rf_data->ads_sort_field = cnvtupper(drrr_rf_data->ads_sort_field)
   IF ( NOT (cnvtupper(drrr_rf_data->ads_sort_value) IN ("ASC", "DESC")))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file ADS_SORT_VALUE: ",drrr_rf_data->
     ads_sort_value)
    SET dm_err->emsg = "Response file ADS_SORT_VALUE is not valid."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET drrr_rf_data->ads_sort_value = cnvtupper(drrr_rf_data->ads_sort_value)
   IF ( NOT ((drrr_rf_data->src_ads_domain_ind IN (0, 1))))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = build("Validating response file SRC_ADS_DOMAIN_IND: ",drrr_rf_data->
     src_ads_domain_ind)
    SET dm_err->emsg = "Response file SRC_ADS_DOMAIN_IND is not valid."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((cnvtupper(drrr_rf_data->ads_config_name) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->ads_config_name,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file ADS config name: ",drrr_rf_data->
     ads_config_name)
    SET dm_err->emsg =
    "Response file ADS config name (ADS_CONFIG_NAME) must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_adm_cnnct_data(dvracd_in_cnct_to_db_ind)
   IF (cnvtupper(drrr_rf_data->adm_db_user) != "CDBA")
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file admin database user: ",drrr_rf_data->
     adm_db_user)
    SET dm_err->emsg = "Response file admin database user (ADM_DB_USER) must be set to CDBA."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((cnvtupper(drrr_rf_data->adm_db_user_pwd) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->adm_db_user_pwd,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file admin database user password: ",drrr_rf_data
     ->adm_db_user_pwd)
    SET dm_err->emsg =
    "Response file admin database user password (ADM_DB_USER_PWD) must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((cnvtupper(drrr_rf_data->adm_db_cnct_str) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->adm_db_cnct_str,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file admin database connect string: ",
     drrr_rf_data->adm_db_cnct_str)
    SET dm_err->emsg =
    "Response file admin database connect string (ADM_DB_CNCT_STR) must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((cnvtupper(drrr_rf_data->adm_db_oracle_ver) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->adm_db_oracle_ver,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file admin database oracle version: ",
     drrr_rf_data->adm_db_oracle_ver)
    SET dm_err->emsg =
    "Response file admin database oracle version (ADM_DB_ORACLE_VER) must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dvracd_in_cnct_to_db_ind=1)
    SET dm2_install_schema->u_name = drrr_rf_data->adm_db_user
    SET dm2_install_schema->p_word = drrr_rf_data->adm_db_user_pwd
    SET dm2_install_schema->connect_str = drrr_rf_data->adm_db_cnct_str
    SET dm2_install_schema->dbase_name = '"ADMIN"'
    EXECUTE dm2_connect_to_dbase "CO"
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_src_cnnct_data(dvrscd_in_cnct_to_db_ind)
   IF (cnvtupper(drrr_rf_data->src_db_user) != "V500")
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file source database user: ",drrr_rf_data->
     src_db_user)
    SET dm_err->emsg = "Response file source database user (SRC_DB_USER) must be set to V500."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((cnvtupper(drrr_rf_data->src_db_user_pwd) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->src_db_user_pwd,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file source database user password: ",
     drrr_rf_data->src_db_user_pwd)
    SET dm_err->emsg =
    "Response file source database user password (SRC_DB_USER_PWD) must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((cnvtupper(drrr_rf_data->src_db_cnct_str) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->src_db_cnct_str,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file source database connect string: ",
     drrr_rf_data->src_db_cnct_str)
    SET dm_err->emsg =
    "Response file source database connect string (SRC_DB_CNCT_STR) must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((cnvtupper(drrr_rf_data->src_db_name) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->src_db_name,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file source database name: ",drrr_rf_data->
     src_db_name)
    SET dm_err->emsg =
    "Response file source database name (SRC_DB_NAME) must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dvrscd_in_cnct_to_db_ind=1)
    SET dm2_install_schema->u_name = drrr_rf_data->src_db_user
    SET dm2_install_schema->p_word = drrr_rf_data->src_db_user_pwd
    SET dm2_install_schema->connect_str = drrr_rf_data->src_db_cnct_str
    SET dm2_install_schema->dbase_name = '"SOURCE"'
    EXECUTE dm2_connect_to_dbase "CO"
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    IF (cnvtupper(currdbname) != cnvtupper(drrr_rf_data->src_db_name))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file source database name: ",drrr_rf_data->
      src_db_name)
     SET dm_err->emsg = concat(
      "Response file source database name (SRC_DB_NAME) does not match db name after connection (",
      trim(currdbname,3),").")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_src_high_priv_user(null)
   IF (((cnvtupper(drrr_rf_data->src_high_priv_user) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->src_high_priv_user,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file source high priv user: ",drrr_rf_data->
     src_high_priv_user)
    SET dm_err->emsg =
    "Response file source high priv user (SRC_HIGH_PRIV_USER) must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((cnvtupper(drrr_rf_data->src_high_priv_user_pwd) IN ("*VALUE*REQUIRED*",
   "*VALUE*UNSPECIFIED*", "DM2NOTSET")) OR (size(trim(drrr_rf_data->src_high_priv_user_pwd,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file source high priv user password: ",
     drrr_rf_data->src_high_priv_user_pwd)
    SET dm_err->emsg =
    "Response file source high priv user password (SRC_HIGH_PRIV_USER_PWD) must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_src_env_name(null)
  IF (((cnvtupper(drrr_rf_data->src_env_name) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
  "DM2NOTSET")) OR (size(trim(drrr_rf_data->src_env_name,3))=0)) )
   SET dm_err->err_ind = 1
   SET dm_err->eproc = concat("Validating response file source environment name: ",drrr_rf_data->
    src_env_name)
   SET dm_err->emsg =
   "Response file source environment name (SRC_ENV_NAME) must be set to a specific value."
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   RETURN(0)
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_src_domain_name(null)
  IF (((cnvtupper(drrr_rf_data->src_domain_name) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
  "DM2NOTSET")) OR (size(trim(drrr_rf_data->src_domain_name,3))=0)) )
   SET dm_err->err_ind = 1
   SET dm_err->eproc = concat("Validating response file source domain name: ",drrr_rf_data->
    src_domain_name)
   SET dm_err->emsg =
   "Response file source domain name (SRC_DOMAIN_NAME) must be set to a specific value."
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   RETURN(0)
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_src_app_node_list(null)
   DECLARE dvrsanl_str = vc WITH protect, noconstant("")
   DECLARE dvrsanl_notfnd = vc WITH protect, constant("<not_found>")
   DECLARE dvrsanl_num = i4 WITH protect, noconstant(1)
   DECLARE dvrsanl_tmp_node = vc WITH protect, noconstant("")
   SET drrr_misc_data->src_app_node_cnt = 0
   SET stat = alterlist(drrr_misc_data->src_app_nodes,0)
   IF (((cnvtupper(drrr_rf_data->src_app_node_list) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->src_app_node_list,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file source app node list: ",drrr_rf_data->
     src_app_node_list)
    SET dm_err->emsg =
    "Response file source app node list (SRC_APP_NODE_LIST) must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    WHILE (dvrsanl_str != dvrsanl_notfnd)
     SET dvrsanl_str = piece(drrr_rf_data->src_app_node_list,",",dvrsanl_num,dvrsanl_notfnd)
     IF (dvrsanl_str != dvrsanl_notfnd)
      IF (findstring('"',dvrsanl_str,1,0) != findstring('"',dvrsanl_str,1,1))
       SET dvrsanl_tmp_node = cnvtlower(trim(replace(dvrsanl_str,'"',"",0),3))
       IF (size(trim(dvrsanl_tmp_node,3)) > 0)
        SET drrr_misc_data->src_app_node_cnt = (drrr_misc_data->src_app_node_cnt+ 1)
        SET stat = alterlist(drrr_misc_data->src_app_nodes,drrr_misc_data->src_app_node_cnt)
        SET drrr_misc_data->src_app_nodes[drrr_misc_data->src_app_node_cnt].node_name =
        dvrsanl_tmp_node
        SET dvrsanl_num = (dvrsanl_num+ 1)
       ELSE
        SET dm_err->err_ind = 1
        SET dm_err->eproc = concat(
         "Validating response file source app node list (SRC_APP_NODE_LIST): ",drrr_rf_data->
         src_app_node_list)
        SET dm_err->emsg = concat("Individual node name in position ",trim(cnvtstring(dvrsanl_num),3),
         " not properly set.")
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ELSE
       SET dm_err->err_ind = 1
       SET dm_err->eproc = concat(
        "Validating response file source app node list (SRC_APP_NODE_LIST): ",drrr_rf_data->
        src_app_node_list)
       SET dm_err->emsg = concat("Individual node name (",trim(dvrsanl_str,3),
        ") not wrapped in double-quotes.")
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
    ENDWHILE
    IF ((drrr_misc_data->src_app_node_cnt=0))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file source app node list (SRC_APP_NODE_LIST): ",
      drrr_rf_data->src_app_node_list)
     SET dm_err->emsg = "Node name(s) not loaded into memory."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_sys_cnnct_data(dvrtscd_in_cnct_to_db_ind)
   IF (((cnvtupper(drrr_rf_data->tgt_sys_pwd) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_sys_pwd,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target SYS password: ",drrr_rf_data->
     tgt_sys_pwd)
    SET dm_err->emsg = "Response file target SYS password must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_system_pwd) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_system_pwd,3))=0
    AND (drrr_rf_data->tgt_db_deploy_config != "ADB"))) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target SYSTEM password: ",drrr_rf_data->
     tgt_system_pwd)
    SET dm_err->emsg = "Response file target SYSTEM password must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_db_cnct_str) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_db_cnct_str,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target database connect string: ",
     drrr_rf_data->tgt_db_cnct_str)
    SET dm_err->emsg =
    "Response file target database connect string must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_db_name) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_db_name,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target database name: ",drrr_rf_data->
     tgt_db_name)
    SET dm_err->emsg = "Response file target database name must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (cnvtupper(drrr_rf_data->tgt_db_deploy_config) IN ("OP", "OCI"))
    SET drrr_rf_data->tgt_sys_user = "SYS"
   ELSE
    SET drrr_rf_data->tgt_sys_user = "ADMIN"
   ENDIF
   IF (dvrtscd_in_cnct_to_db_ind=1)
    SET dm2_install_schema->u_name = drrr_rf_data->tgt_sys_user
    SET dm2_install_schema->p_word = drrr_rf_data->tgt_sys_pwd
    SET dm2_install_schema->connect_str = drrr_rf_data->tgt_db_cnct_str
    SET dm2_install_schema->dbase_name = '"TARGET"'
    EXECUTE dm2_connect_to_dbase "CO"
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    IF (cnvtupper(currdbname) != cnvtupper(drrr_rf_data->tgt_db_name))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file target database name: ",drrr_rf_data->
      tgt_db_name)
     SET dm_err->emsg = concat(
      "Response file target database name does not match db name after connection (",trim(currdbname,
       3),") using SYS user.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((drrr_rf_data->tgt_db_deploy_config != "ADB"))
     SET dm2_install_schema->u_name = "SYSTEM"
     SET dm2_install_schema->p_word = drrr_rf_data->tgt_system_pwd
     SET dm2_install_schema->connect_str = drrr_rf_data->tgt_db_cnct_str
     SET dm2_install_schema->dbase_name = '"TARGET"'
     EXECUTE dm2_connect_to_dbase "CO"
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
     IF (cnvtupper(currdbname) != cnvtupper(drrr_rf_data->tgt_db_name))
      SET dm_err->err_ind = 1
      SET dm_err->eproc = concat("Validating response file target database name: ",drrr_rf_data->
       tgt_db_name)
      SET dm_err->emsg = concat(
       "Response file target database name does not match db name after connection (",trim(currdbname,
        3),") using SYSTEM user.")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_cnnct_data(dvrtcd_in_cnct_to_db_ind)
   IF (cnvtupper(drrr_rf_data->tgt_db_user) != "V500")
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target database user: ",drrr_rf_data->
     tgt_db_user)
    SET dm_err->emsg = "Response file target database user must be set to V500."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_db_user_pwd) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_db_user_pwd,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target database user password: ",
     drrr_rf_data->tgt_db_user_pwd)
    SET dm_err->emsg = "Response file target database user password must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_db_cnct_str) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_db_cnct_str,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target database connect string: ",
     drrr_rf_data->tgt_db_cnct_str)
    SET dm_err->emsg =
    "Response file target database connect string must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_db_name) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_db_name,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target database name: ",drrr_rf_data->
     tgt_db_name)
    SET dm_err->emsg = "Response file target database name must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((((drrr_rf_data->tgt_db_oracle_ver=patstring("12.*"))) OR ((drrr_rf_data->tgt_db_oracle_ver=
   patstring("19*")))) )
    IF (((cnvtupper(drrr_rf_data->tgt_cdb_name) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
    "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_cdb_name,3))=0))
     AND (drrr_rf_data->tgt_db_deploy_config != "ADB"))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file target cdb name: ",drrr_rf_data->
      tgt_cdb_name)
     SET dm_err->emsg = "Response file target cdb name must be set to a specific value."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((((drrr_rf_data->tgt_db_oracle_ver=patstring("12.*"))) OR ((drrr_rf_data->tgt_db_oracle_ver=
   patstring("19*")))) )
    IF (((cnvtupper(drrr_rf_data->tgt_cdb_cnct_str) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
    "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_cdb_cnct_str,3))=0))
     AND (drrr_rf_data->tgt_db_deploy_config != "ADB"))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file target container database connect string: ",
      drrr_rf_data->tgt_cdb_cnct_str)
     SET dm_err->emsg =
     "Response file target container database connect string must be set to a specific value."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dvrtcd_in_cnct_to_db_ind=1)
    SET dm2_install_schema->u_name = drrr_rf_data->tgt_db_user
    SET dm2_install_schema->p_word = drrr_rf_data->tgt_db_user_pwd
    SET dm2_install_schema->connect_str = drrr_rf_data->tgt_db_cnct_str
    SET dm2_install_schema->dbase_name = '"TARGET"'
    EXECUTE dm2_connect_to_dbase "CO"
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    IF (cnvtupper(currdbname) != cnvtupper(drrr_rf_data->tgt_db_name))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file target database name: ",drrr_rf_data->
      tgt_db_name)
     SET dm_err->emsg = concat(
      "Response file target database name does not match db name after connection (",trim(currdbname,
       3),").")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_high_priv_user(null)
   IF (((cnvtupper(drrr_rf_data->tgt_high_priv_user) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_high_priv_user,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target high priv user: ",drrr_rf_data->
     tgt_high_priv_user)
    SET dm_err->emsg =
    "Response file target high priv user (TGT_HIGH_PRIV_USER) must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_high_priv_user_pwd) IN ("*VALUE*REQUIRED*",
   "*VALUE*UNSPECIFIED*", "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_high_priv_user_pwd,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target high priv user password: ",
     drrr_rf_data->tgt_high_priv_user_pwd)
    SET dm_err->emsg =
    "Response file target high priv user password (TGT_HIGH_PRIV_USER_PWD) must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (cnvtupper(drrr_rf_data->tgt_high_priv_user) != cnvtupper(drrr_rf_data->src_high_priv_user))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target high priv user: ",drrr_rf_data->
     tgt_high_priv_user)
    SET dm_err->emsg = concat(
     "Response file target high priv user (TGT_HIGH_PRIV_USER) must be equal to the source ",
     "high priv user (SRC_HIGH_PRIV_USER) value (",drrr_rf_data->src_high_priv_user,").")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_env_name(null)
   IF (((cnvtupper(drrr_rf_data->tgt_env_name) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_env_name,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target environment name: ",drrr_rf_data->
     tgt_env_name)
    SET dm_err->emsg =
    "Response file target environment name (TGT_ENV_NAME) must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_db_env_name) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_db_env_name,3))=0)) )
    SET drrr_rf_data->tgt_db_env_name = cnvtupper(drrr_rf_data->tgt_env_name)
   ELSE
    SET drrr_rf_data->tgt_db_env_name = cnvtupper(drrr_rf_data->tgt_db_env_name)
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_env_desc) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_env_desc,3))=0)) )
    SET drrr_rf_data->tgt_env_desc = concat(drrr_rf_data->tgt_db_env_name," environment")
   ENDIF
   SET drrr_rf_data->tgt_env_desc = cnvtupper(drrr_rf_data->tgt_env_desc)
   IF (textlen(drrr_rf_data->tgt_env_desc) > 60)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target environment description: ",
     drrr_rf_data->tgt_env_desc)
    SET dm_err->emsg = concat(
     "Target environment description (TGT_ENV_DESC) should not exceed 60 characters.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_domain_name(null)
  IF (((cnvtupper(drrr_rf_data->tgt_domain_name) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
  "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_domain_name,3))=0)) )
   SET dm_err->err_ind = 1
   SET dm_err->eproc = concat("Validating response file target dmain name: ",drrr_rf_data->
    tgt_domain_name)
   SET dm_err->emsg =
   "Response file target domain name (TGT_DOMAIN_NAME) must be set to a specific value."
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   RETURN(0)
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_app_node_list(null)
   DECLARE dvrtanl_str = vc WITH protect, noconstant("")
   DECLARE dvrtanl_notfnd = vc WITH protect, constant("<not_found>")
   DECLARE dvrtanl_num = i4 WITH protect, noconstant(1)
   DECLARE dvrtanl_tmp_node = vc WITH protect, noconstant("")
   DECLARE dvrtanl_idx = i4 WITH protect, noconstant(0)
   SET drrr_misc_data->tgt_app_node_cnt = 0
   SET stat = alterlist(drrr_misc_data->tgt_app_nodes,0)
   IF (((cnvtupper(drrr_rf_data->tgt_app_node_list) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_app_node_list,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target app node list: ",drrr_rf_data->
     tgt_app_node_list)
    SET dm_err->emsg =
    "Response file target app node list (TGT_APP_NODE_LIST) must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    WHILE (dvrtanl_str != dvrtanl_notfnd)
     SET dvrtanl_str = piece(drrr_rf_data->tgt_app_node_list,",",dvrtanl_num,dvrtanl_notfnd)
     IF (dvrtanl_str != dvrtanl_notfnd)
      IF (findstring('"',dvrtanl_str,1,0) != findstring('"',dvrtanl_str,1,1))
       SET dvrtanl_tmp_node = cnvtlower(trim(replace(dvrtanl_str,'"',"",0),3))
       IF (size(trim(dvrtanl_tmp_node,3)) > 0)
        SET drrr_misc_data->tgt_app_node_cnt = (drrr_misc_data->tgt_app_node_cnt+ 1)
        SET stat = alterlist(drrr_misc_data->tgt_app_nodes,drrr_misc_data->tgt_app_node_cnt)
        SET drrr_misc_data->tgt_app_nodes[drrr_misc_data->tgt_app_node_cnt].node_name =
        dvrtanl_tmp_node
        SET dvrtanl_num = (dvrtanl_num+ 1)
       ELSE
        SET dm_err->err_ind = 1
        SET dm_err->eproc = concat(
         "Validating response file target app node list (TGT_APP_NODE_LIST): ",drrr_rf_data->
         tgt_app_node_list)
        SET dm_err->emsg = concat("Individual node name in position ",trim(cnvtstring(dvrtanl_num),3),
         " not properly set.")
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ELSE
       SET dm_err->err_ind = 1
       SET dm_err->eproc = concat(
        "Validating response file target app node list (tgt_APP_NODE_LIST): ",drrr_rf_data->
        tgt_app_node_list)
       SET dm_err->emsg = concat("Individual node name (",trim(dvrtanl_str,3),
        ") not wrapped in double-quotes.")
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
    ENDWHILE
    IF ((drrr_misc_data->tgt_app_node_cnt=0))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file target app node list (tgt_APP_NODE_LIST): ",
      drrr_rf_data->tgt_app_node_list)
     SET dm_err->emsg = "Node name(s) not loaded into memory."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_primary_app_node) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_primary_app_node,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target primary app node: ",drrr_rf_data->
     tgt_primary_app_node)
    SET dm_err->emsg =
    "Response file target primary app node (TGT_PRIMARY_APP_NODE) must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    SET drrr_rf_data->tgt_primary_app_node = cnvtlower(trim(drrr_rf_data->tgt_primary_app_node,3))
    SET dvrtanl_idx = locateval(dvrtanl_idx,1,drrr_misc_data->tgt_app_node_cnt,drrr_rf_data->
     tgt_primary_app_node,drrr_misc_data->tgt_app_nodes[dvrtanl_idx].node_name)
    IF (dvrtanl_idx=0)
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file target primary app node: ",drrr_rf_data->
      tgt_primary_app_node)
     SET dm_err->emsg = concat(
      "Response file target primary app node (TGT_PRIMARY_APP_NODE) not found in target ",
      "app node list (TGT_APP_NODE_LIST).")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_src_app_temp_dir(null)
   IF (((cnvtupper(drrr_rf_data->src_app_temp_dir) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->src_app_temp_dir,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file source app temp directory: ",drrr_rf_data->
     src_app_temp_dir)
    SET dm_err->emsg =
    "Response file source app temp directory (SRC_APP_TEMP_DIR) must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (substring(1,1,drrr_rf_data->src_app_temp_dir) != "/")
    SET drrr_rf_data->src_app_temp_dir = concat("/",drrr_rf_data->src_app_temp_dir)
   ENDIF
   IF (findstring("/",trim(drrr_rf_data->src_app_temp_dir),1,1) != size(trim(drrr_rf_data->
     src_app_temp_dir)))
    SET drrr_rf_data->src_app_temp_dir = concat(trim(drrr_rf_data->src_app_temp_dir),"/")
   ENDIF
   IF ( NOT (dm2_find_dir(drrr_rf_data->src_app_temp_dir)))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file source app temp directory: ",drrr_rf_data->
     src_app_temp_dir)
    SET dm_err->emsg = "Failed to find source app temp directory (SRC_APP_TEMP_DIR). "
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (textlen(drrr_rf_data->src_app_temp_dir) > 175)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file source app temp directory: ",drrr_rf_data->
     src_app_temp_dir)
    SET dm_err->emsg = concat(
     "Full path of source app temp directory should not exceed 175 characters.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (drrr_val_write_privs(drrr_rf_data->src_app_temp_dir)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_app_temp_dir(null)
   IF (((cnvtupper(drrr_rf_data->tgt_app_temp_dir) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_app_temp_dir,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target app temp directory: ",drrr_rf_data->
     tgt_app_temp_dir)
    SET dm_err->emsg =
    "Response file target app temp directory (tgt_APP_TEMP_DIR) must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (substring(1,1,drrr_rf_data->tgt_app_temp_dir) != "/")
    SET drrr_rf_data->tgt_app_temp_dir = concat("/",drrr_rf_data->tgt_app_temp_dir)
   ENDIF
   IF (findstring("/",trim(drrr_rf_data->tgt_app_temp_dir),1,1) != size(trim(drrr_rf_data->
     tgt_app_temp_dir)))
    SET drrr_rf_data->tgt_app_temp_dir = concat(trim(drrr_rf_data->tgt_app_temp_dir),"/")
   ENDIF
   IF ( NOT (dm2_find_dir(drrr_rf_data->tgt_app_temp_dir)))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target app temp directory: ",drrr_rf_data->
     tgt_app_temp_dir)
    SET dm_err->emsg = "Failed to find target app temp directory (tgt_APP_TEMP_DIR). "
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (textlen(drrr_rf_data->tgt_app_temp_dir) > 175)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target app temp directory: ",drrr_rf_data->
     tgt_app_temp_dir)
    SET dm_err->emsg = concat(
     "Full path of target app temp directory should not exceed 175 characters.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (drrr_val_write_privs(drrr_rf_data->tgt_app_temp_dir)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_app_prim_temp_dir(null)
   IF (((cnvtupper(drrr_rf_data->tgt_app_prim_temp_dir) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_app_prim_temp_dir,3))=0)) )
    SET drrr_rf_data->tgt_app_prim_temp_dir = concat(drrr_rf_data->tgt_app_temp_dir,"/",drrr_rf_data
     ->tgt_primary_app_node,"/",drrr_rf_data->tgt_env_name,
     "/")
    RETURN(1)
   ENDIF
   IF (substring(1,1,drrr_rf_data->tgt_app_prim_temp_dir) != "/")
    SET drrr_rf_data->tgt_app_prim_temp_dir = concat("/",drrr_rf_data->tgt_app_prim_temp_dir)
   ENDIF
   IF (findstring("/",trim(drrr_rf_data->tgt_app_prim_temp_dir),1,1) != size(trim(drrr_rf_data->
     tgt_app_prim_temp_dir)))
    SET drrr_rf_data->tgt_app_prim_temp_dir = concat(trim(drrr_rf_data->tgt_app_prim_temp_dir),"/")
   ENDIF
   IF (textlen(drrr_rf_data->tgt_app_prim_temp_dir) > 175)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target app primary temp directory: ",
     drrr_rf_data->tgt_app_prim_temp_dir)
    SET dm_err->emsg = concat(
     "Full path of target app primary temp directory should not exceed 175 characters.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_preserve_data(null)
   IF ( NOT (cnvtupper(drrr_rf_data->tgt_preserve_data) IN ("YES", "NO")))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file TGT_PRESERVE_DATA: ",drrr_rf_data->
     tgt_preserve_data)
    SET dm_err->emsg = 'Response file TGT_PRESERVE_DATA must be equal to "YES" or "NO".'
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET drrr_rf_data->tgt_preserve_data = cnvtupper(drrr_rf_data->tgt_preserve_data)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_backup_ccluserdir(null)
   IF ( NOT (cnvtupper(drrr_rf_data->tgt_backup_ccluserdir) IN ("YES", "NO")))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file tgt_backup_ccluserdir: ",drrr_rf_data->
     tgt_backup_ccluserdir)
    SET dm_err->emsg = 'Response file tgt_backup_ccluserdir must be equal to "YES" or "NO".'
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET drrr_rf_data->tgt_backup_ccluserdir = cnvtupper(drrr_rf_data->tgt_backup_ccluserdir)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_backup_warehouse(null)
   IF ( NOT (cnvtupper(drrr_rf_data->tgt_backup_warehouse) IN ("YES", "NO")))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file tgt_backup_warehouse: ",drrr_rf_data->
     tgt_backup_warehouse)
    SET dm_err->emsg = 'Response file tgt_backup_warehouse must be equal to "YES" or "NO".'
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET drrr_rf_data->tgt_backup_warehouse = cnvtupper(drrr_rf_data->tgt_backup_warehouse)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_capture_schema_date(null)
   DECLARE dvrtcsd_dt = vc WITH protect, noconstant("")
   IF (validate(dm2_skip_tgt_schema_date,- (1))=1)
    SET dm_err->eproc = "Bypassing response file target capture schema date limit."
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   SET dvrtcsd_dt = trim(drrr_rf_data->tgt_capture_schema_date,3)
   IF (((cnvtupper(dvrtcsd_dt) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*", "DM2NOTSET")) OR (((
   size(dvrtcsd_dt)=0) OR (((format(cnvtdate(cnvtalphanum(dvrtcsd_dt)),"MM-DD-YYYY;;D") != dvrtcsd_dt
   ) OR (datetimeadd(cnvtdatetime(format(cnvtdate2(dvrtcsd_dt,"MM-DD-YYYY"),"DD-MMM-YYYY;;D")),30) <
   cnvtdatetime(curdate,curtime3))) )) )) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target capture schema date: ",drrr_rf_data->
     tgt_capture_schema_date)
    SET dm_err->emsg = concat(
     "Response file target capture schema date (TGT_CAPTURE_SCHEMA_DATE) must be ",
     "set to a specific value (format of MM-DD-YYYY) and date should be within the last 30 days.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_tspace_increase_pct(null)
  IF ((((drrr_rf_data->tgt_tspace_increase_pct <= - (100))) OR ((drrr_rf_data->
  tgt_tspace_increase_pct >= 100))) )
   SET drrr_rf_data->tgt_tspace_increase_pct = 10
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_write_privs(drvwp_full_dir)
   DECLARE drvwp_full_fname = vc WITH protect
   IF (get_unique_file("dm2wrtprvtst",".dat")=0)
    RETURN(0)
   ENDIF
   SET drvwp_full_fname = build(drvwp_full_dir,cnvtlower(dm_err->unique_fname))
   SET dm_err->eproc = concat("Validating write privs to directory: ",drvwp_full_dir)
   SELECT INTO value(drvwp_full_fname)
    d.seq
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     row + 1, "This is a test of writing to ", drvwp_full_dir
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dm2_push_dcl(concat("rm ",drvwp_full_fname))=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_tspace_dg_list(null)
   DECLARE dvrttdl_str = vc WITH protect, noconstant("")
   DECLARE dvrttdl_notfnd = vc WITH protect, constant("<not_found>")
   DECLARE dvrttdl_num = i4 WITH protect, noconstant(1)
   DECLARE dvrttdl_tmp_dg = vc WITH protect, noconstant("")
   IF (((cnvtupper(drrr_rf_data->tgt_tspace_dg_list) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_tspace_dg_list,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target tspace diskgroup list: ",drrr_rf_data
     ->tgt_tspace_dg_list)
    SET dm_err->emsg =
    "Response file target tspace diskgroup list (TGT_TSPACE_DG_LIST) must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    WHILE (dvrttdl_str != dvrttdl_notfnd)
     SET dvrttdl_str = piece(drrr_rf_data->tgt_tspace_dg_list,",",dvrttdl_num,dvrttdl_notfnd)
     IF (dvrttdl_str != dvrttdl_notfnd)
      IF (findstring('"',dvrttdl_str,1,0) != findstring('"',dvrttdl_str,1,1))
       SET dvrttdl_tmp_dg = cnvtupper(trim(replace(dvrttdl_str,'"',"",0),3))
       IF (size(dvrttdl_tmp_dg) > 0)
        SELECT INTO "nl:"
         FROM v$asm_diskgroup v
         WHERE v.state IN ("CONNECTED", "MOUNTED")
          AND v.name=dvrttdl_tmp_dg
         WITH nocounter
        ;end select
        IF (check_error(concat("Verify disk group (",dvrttdl_tmp_dg,") exists.")) != 0)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ELSEIF (curqual=0)
         SET dm_err->err_ind = 1
         SET dm_err->eproc = concat(
          "Validating response file target tspace diskgroup list (TGT_TSPACE_DG_LIST): ",drrr_rf_data
          ->tgt_tspace_dg_list)
         SET dm_err->emsg = concat("Individual diskgroup (",dvrttdl_str,
          ") not found or not valid state.")
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
        SET drrr_misc_data->tgt_tspace_dg_cnt = (drrr_misc_data->tgt_tspace_dg_cnt+ 1)
        SET stat = alterlist(drrr_misc_data->tgt_tspace_dg,drrr_misc_data->tgt_tspace_dg_cnt)
        SET drrr_misc_data->tgt_tspace_dg[drrr_misc_data->tgt_tspace_dg_cnt].disk_group =
        dvrttdl_tmp_dg
        SET dvrttdl_num = (dvrttdl_num+ 1)
       ELSE
        SET dm_err->err_ind = 1
        SET dm_err->eproc = concat(
         "Validating response file target tspace diskgroup list (TGT_TSPACE_DG_LIST): ",drrr_rf_data
         ->tgt_tspace_dg_list)
        SET dm_err->emsg = concat("Individual diskgroup in position ",trim(cnvtstring(dvrttdl_num),3),
         " not properly set.")
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ELSE
       SET dm_err->err_ind = 1
       SET dm_err->eproc = concat(
        "Validating response file target tspace diskgroup list (TGT_TSPACE_DG_LIST): ",drrr_rf_data->
        tgt_tspace_dg_list)
       SET dm_err->emsg = concat("Individual diskgroup (",trim(dvrttdl_str,3),
        ") not wrapped in double-quotes.")
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
    ENDWHILE
    IF ((drrr_misc_data->tgt_tspace_dg_cnt=0))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat(
      "Validating response file target tspace diskgroup list (TGT_TSPACE_DG_LIST): ",drrr_rf_data->
      tgt_tspace_dg_list)
     SET dm_err->emsg = "Diskgroup(s) not loaded into memory."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_restore_preserve_data(null)
   IF ( NOT (cnvtupper(drrr_rf_data->tgt_restore_preserve_data) IN ("YES", "NO")))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file RESTORE PRESERVE DATA: ",drrr_rf_data->
     tgt_restore_preserve_data)
    SET dm_err->emsg = 'Response file RESTORE PRESERVE DATA must be equal to "YES" or "NO".'
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET drrr_rf_data->tgt_restore_preserve_data = cnvtupper(drrr_rf_data->tgt_restore_preserve_data)
   IF ((drrr_rf_data->tgt_preserve_data="NO")
    AND (drrr_rf_data->tgt_restore_preserve_data="YES"))
    SET dm_err->err_ind = 1
    SET dm_err->eproc =
    'Validating response file restore preserve data indicator (TGT_RESTORE_PRESERVE_DATA) can be set to "YES".'
    SET dm_err->emsg = concat("Response file target preserve data (TGT_PRESERVE_DATA) must ",
     'be equal to "YES" in order to restore preserve data.')
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((drrr_rf_data->tgt_restore_preserve_data="YES"))
    IF ( NOT (cnvtupper(drrr_rf_data->tgt_restore_autotester) IN ("YES", "NO")))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file RESTORE AUTOTESTER: ",drrr_rf_data->
      tgt_restore_autotester)
     SET dm_err->emsg = 'Response file RESTORE AUTOTESTER must be equal to "YES" or "NO".'
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET drrr_rf_data->tgt_restore_autotester = cnvtupper(drrr_rf_data->tgt_restore_autotester)
    IF ( NOT (cnvtupper(drrr_rf_data->tgt_restore_rrd) IN ("YES", "NO")))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file RESTORE RRD: ",drrr_rf_data->
      tgt_restore_rrd)
     SET dm_err->emsg = 'Response file RESTORE RRD must be equal to "YES" or "NO".'
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET drrr_rf_data->tgt_restore_rrd = cnvtupper(drrr_rf_data->tgt_restore_rrd)
    IF ( NOT (cnvtupper(drrr_rf_data->tgt_restore_printers) IN ("YES", "NO")))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file RESTORE PRINTERS: ",drrr_rf_data->
      tgt_restore_printers)
     SET dm_err->emsg = 'Response file RESTORE PRINTERS must be equal to "YES" or "NO".'
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET drrr_rf_data->tgt_restore_printers = cnvtupper(drrr_rf_data->tgt_restore_printers)
    IF ( NOT (cnvtupper(drrr_rf_data->tgt_restore_interfaces) IN ("YES", "NO")))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file RESTORE INTERFACES: ",drrr_rf_data->
      tgt_restore_interfaces)
     SET dm_err->emsg = 'Response file RESTORE INTERFACES must be equal to "YES" or "NO".'
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET drrr_rf_data->tgt_restore_interfaces = cnvtupper(drrr_rf_data->tgt_restore_interfaces)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_email_list(null)
   DECLARE dvel_email = vc WITH protect, noconstant("")
   DECLARE dvel_level = i2 WITH protect, noconstant(0)
   DECLARE dvel_beg = i2 WITH protect, noconstant(1)
   DECLARE dvel_end = i2 WITH protect, noconstant(1)
   DECLARE dvel_cnt = i2 WITH protect, noconstant(0)
   DECLARE dvel_str = vc WITH protect, noconstant("")
   DECLARE dvel_level_idx = i2 WITH protect, noconstant(0)
   DECLARE dvel_email_idx = i2 WITH protect, noconstant(0)
   DECLARE dvel_finish = i2 WITH protect, noconstant(0)
   IF (((cnvtupper(drrr_rf_data->email_list) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->email_list,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file email list: ",drrr_rf_data->email_list)
    SET dm_err->emsg = "Response file email list (EMAIL_LIST) must be set."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dvel_str = build(trim(cnvtlower(replace(drrr_rf_data->email_list,'"',"",0)),4))
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("dvel_str = ",dvel_str))
   ENDIF
   IF (dvel_str > "")
    WHILE ( NOT (dvel_finish))
      SET dvel_cnt = (dvel_cnt+ 1)
      IF ((dm_err->debug_flag > 0))
       CALL echo(build("cnt = ",dvel_cnt))
      ENDIF
      SET dvel_beg = dvel_end
      SET dvel_end = findstring(",",dvel_str,(dvel_beg+ 1),0)
      IF (dvel_end=0)
       SET dvel_end = (size(dvel_str)+ 1)
       SET dvel_finish = 1
      ENDIF
      IF (even(dvel_cnt)=1)
       IF ((dm_err->debug_flag > 0))
        CALL echo(build("beg = ",dvel_beg))
        CALL echo(build("end = ",dvel_end))
        CALL echo(substring((dvel_beg+ 1),((dvel_end - dvel_beg) - 1),dvel_str))
       ENDIF
       SET dvel_level = cnvtint(substring((dvel_beg+ 1),((dvel_end - dvel_beg) - 1),dvel_str))
       IF ((dm_err->debug_flag > 0))
        CALL echo(build("dvel_level = ",dvel_level))
       ENDIF
       IF (((dvel_level=0) OR ((dvel_level > drer_email_list->max_email_level))) )
        SET dm_err->err_ind = 1
        SET dm_err->eproc = concat("Validating response file Email List: ",drrr_rf_data->email_list)
        SET dm_err->emsg = concat("Response file Email level must be greater than 0 and less than ",
         trim(cnvtstring(drer_email_list->max_email_level)))
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       SET drer_email_list->email[drer_email_list->email_cnt].level = dvel_level
      ELSE
       IF (dvel_beg=1)
        SET dvel_email = substring(dvel_beg,(dvel_end - dvel_beg),dvel_str)
       ELSE
        SET dvel_email = substring((dvel_beg+ 1),((dvel_end - dvel_beg) - 1),dvel_str)
       ENDIF
       IF ((dm_err->debug_flag > 0))
        CALL echo(build("dvel_email = ",dvel_email))
       ENDIF
       IF (((findstring("@",dvel_email,1)=0) OR (findstring(".",dvel_email,1)=0)) )
        SET dm_err->err_ind = 1
        SET dm_err->eproc = concat("Validating response file Email List: ",drrr_rf_data->email_list)
        SET dm_err->emsg = "Response file Email address must have '@' and '.' ."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       SET dvel_email_idx = locateval(dvel_email_idx,1,drer_email_list->email_cnt,dvel_email,
        drer_email_list->email[dvel_email_idx].address)
       IF (dvel_email_idx=0)
        SET drer_email_list->email_cnt = (drer_email_list->email_cnt+ 1)
        SET stat = alterlist(drer_email_list->email,drer_email_list->email_cnt)
        SET drer_email_list->email[drer_email_list->email_cnt].address = dvel_email
       ELSE
        SET dm_err->err_ind = 1
        SET dm_err->eproc = concat("Validating response file Email List: ",drrr_rf_data->email_list)
        SET dm_err->emsg = "Find duplicate email addresses in the response file."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
    ENDWHILE
    IF (even(dvel_cnt) != 1)
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file Email List: ",drrr_rf_data->email_list)
     SET dm_err->emsg = "Failed to find email level for all email addresses."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    FOR (dvel_level = 1 TO drer_email_list->max_email_level)
      SET dvel_beg = 1
      SET dvel_level_idx = 0
      SET dvel_level_idx = locateval(dvel_level_idx,dvel_beg,drer_email_list->email_cnt,dvel_level,
       drer_email_list->email[dvel_level_idx].level)
      IF ((dm_err->debug_flag > 0))
       CALL echo(build("dvel_level = ",dvel_level))
       CALL echo(build("dvel_level_idx = ",dvel_level_idx))
      ENDIF
      IF (dvel_level_idx != 0)
       SET drer_email_list->level_cnt = (drer_email_list->level_cnt+ 1)
       SET stat = alterlist(drer_email_list->email_level,drer_email_list->level_cnt)
       SET drer_email_list->email_level[drer_email_list->level_cnt].level = drer_email_list->email[
       dvel_level_idx].level
       SET drer_email_list->email_level[drer_email_list->level_cnt].email_list = drer_email_list->
       email[dvel_level_idx].address
      ENDIF
      WHILE (dvel_level_idx != 0)
        SET dvel_beg = (dvel_level_idx+ 1)
        SET dvel_level_idx = 0
        SET dvel_level_idx = locateval(dvel_level_idx,dvel_beg,drer_email_list->email_cnt,dvel_level,
         drer_email_list->email[dvel_level_idx].level)
        IF ((dm_err->debug_flag > 0))
         CALL echo(build("dvel_level_idx = ",dvel_level_idx))
        ENDIF
        IF (dvel_level_idx != 0)
         SET drer_email_list->email_level[drer_email_list->level_cnt].email_list = concat(
          drer_email_list->email_level[drer_email_list->level_cnt].email_list,",",drer_email_list->
          email[dvel_level_idx].address)
        ENDIF
      ENDWHILE
    ENDFOR
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(drer_email_list)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_server_set_names(null)
   IF (((cnvtupper(drrr_rf_data->tgt_prim_server_set_name) IN ("*VALUE*REQUIRED*",
   "*VALUE*UNSPECIFIED*", "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_prim_server_set_name,3))=0))
   )
    SET drrr_rf_data->tgt_prim_server_set_name = "CERNER_SHIPPED_DEFAULT"
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_sec_server_set_name) IN ("*VALUE*REQUIRED*",
   "*VALUE*UNSPECIFIED*", "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_sec_server_set_name,3))=0)) )
    SET drrr_rf_data->tgt_sec_server_set_name = "CERNER_SHIPPED_DEFAULT"
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_background_runners(null)
  IF (validate(dm2_rrr_force_interactive_runners,0)=1)
   SET drrr_rf_data->tgt_background_runners = 0
  ELSE
   IF ((drrr_rf_data->tgt_background_runners=- (999)))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating response file target background runners: <not specified>"
    SET dm_err->emsg = concat(
     "Response file target background runners (TGT_BACKGROUND_RUNNERS) must be specified with ",
     "a numeric value of 1 - 10.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF ((((drrr_rf_data->tgt_background_runners < 1)) OR ((drrr_rf_data->tgt_background_runners
    >= 11))) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target background runners: ",cnvtstring(
      drrr_rf_data->tgt_background_runners))
    SET dm_err->emsg = concat(
     "Response file target background runners (TGT_BACKGROUND_RUNNERS) must be ",
     "numeric value of 1 - 10.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_opsexec_node_mapping(null)
   DECLARE dvtonm_num = i2 WITH protect, noconstant(1)
   DECLARE dvtonm_str = vc WITH protect, noconstant("")
   DECLARE dvtonm_notfnd = vc WITH protect, constant("<not_found>")
   DECLARE dvtonm_tmp_str = vc WITH protect, noconstant("")
   IF (((cnvtupper(drrr_rf_data->tgt_opsexec_node_mapping) IN ("*VALUE*REQUIRED*",
   "*VALUE*UNSPECIFIED*", "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_opsexec_node_mapping,3))=0))
   )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file OpsExec Node Mapping: ",drrr_rf_data->
     tgt_opsexec_node_mapping)
    SET dm_err->emsg = "Response file OpsExec Node Mapping (tgt_opsexec_node_mapping) must be set."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dvtonm_str = build(cnvtlower(drrr_rf_data->tgt_opsexec_node_mapping))
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("dvtonm_str = ",dvtonm_str))
   ENDIF
   WHILE (dvtonm_str != dvtonm_notfnd)
     SET dvtonm_str = piece(drrr_rf_data->tgt_opsexec_node_mapping,",",dvtonm_num,dvtonm_notfnd)
     CALL echo(dvtonm_str)
     IF (dvtonm_num=1
      AND dvtonm_str=dvtonm_notfnd)
      SET dvtonm_str = drrr_rf_data->tgt_opsexec_node_mapping
     ENDIF
     IF (dvtonm_str != dvtonm_notfnd)
      IF (findstring('"',dvtonm_str,1,0) != findstring('"',dvtonm_str,1,1))
       SET dvtonm_tmp_str = cnvtlower(trim(replace(dvtonm_str,'"',"",0),3))
       IF (size(trim(dvtonm_tmp_str,3)) > 0)
        IF (findstring(":",dvtonm_tmp_str,1,0) > 1
         AND findstring(":",dvtonm_tmp_str,1,0) < size(trim(dvtonm_tmp_str,3)))
         SET drrr_misc_data->tgt_opsexec_map_cnt = (drrr_misc_data->tgt_opsexec_map_cnt+ 1)
         SET stat = alterlist(drrr_misc_data->tgt_opsexec_map,drrr_misc_data->tgt_opsexec_map_cnt)
         SET drrr_misc_data->tgt_opsexec_map[drrr_misc_data->tgt_opsexec_map_cnt].src_node =
         cnvtupper(value(piece(dvtonm_tmp_str,":",1,dvtonm_notfnd)))
         SET drrr_misc_data->tgt_opsexec_map[drrr_misc_data->tgt_opsexec_map_cnt].tgt_node =
         cnvtupper(value(piece(dvtonm_tmp_str,":",2,dvtonm_notfnd)))
         SET dvtonm_num = (dvtonm_num+ 1)
        ELSE
         SET dm_err->err_ind = 1
         SET dm_err->eproc = concat(
          "Validating response file target opsexec node mapping (tgt_OPSEXEC_NODE_MAPPING): ",
          drrr_rf_data->tgt_opsexec_node_mapping)
         SET dm_err->emsg = concat("Node mapping in position ",trim(cnvtstring(dvtonm_num),3),
          " not properly set.")
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
       ELSE
        SET dm_err->err_ind = 1
        SET dm_err->eproc = concat(
         "Validating response file target opsexec node mapping (tgt_OPSEXEC_NODE_MAPPING): ",
         drrr_rf_data->tgt_opsexec_node_mapping)
        SET dm_err->emsg = concat("Node mapping in position ",trim(cnvtstring(dvtonm_num),3),
         " not properly set.")
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ELSE
       SET dm_err->err_ind = 1
       SET dm_err->eproc = concat(
        "Validating response file target opsexec node mapping (tgt_OPSEXEC_NODE_MAPPING): ",
        drrr_rf_data->tgt_opsexec_node_mapping)
       SET dm_err->emsg = concat("Node mapping (",trim(dvtonm_str,3),
        ") not wrapped in double-quotes.")
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
   ENDWHILE
   CALL echorecord(drrr_misc_data)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_drop_tablespaces(null)
   IF ( NOT (cnvtupper(drrr_rf_data->tgt_drop_tablespaces) IN ("YES", "NO")))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file TGT_DROP_TABLESPACES: ",drrr_rf_data->
     tgt_drop_tablespaces)
    SET dm_err->emsg = 'Response file TGT_DROP_TABLESPACES must be equal to "YES" or "NO".'
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET drrr_rf_data->tgt_drop_tablespaces = cnvtupper(drrr_rf_data->tgt_drop_tablespaces)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_retain_db_user_list(null)
   DECLARE dvrtrdul_str = vc WITH protect, noconstant("")
   DECLARE dvrtrdul_notfnd = vc WITH protect, constant("<not_found>")
   DECLARE dvrtrdul_num = i4 WITH protect, noconstant(1)
   DECLARE dvrtrdul_tmp_user = vc WITH protect, noconstant("")
   DECLARE dvrtrdul_idx = i4 WITH protect, noconstant(0)
   DECLARE dvrtrdul_tmp_str = vc WITH protect, noconstant("")
   IF (((cnvtupper(drrr_rf_data->tgt_retain_db_user_list) IN ("*VALUE*REQUIRED*",
   "*VALUE*UNSPECIFIED*", "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_retain_db_user_list,3))=0)) )
    SET drrr_rf_data->tgt_retain_db_user_list = "DM2NOTSET"
    RETURN(1)
   ELSE
    IF ((drrr_rf_data->target_refresh != "YES"))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat(
      "Validating response file target retain db user list (tgt_RETAIN_DB_USER_LIST): ",drrr_rf_data
      ->tgt_retain_db_user_list)
     SET dm_err->emsg = concat("Response file target refresh indicator (TARGET_REFRESH) must ",
      'be equal to "YES" in order to retain database users.')
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((drrr_rf_data->tgt_db_copy_type != "ALTERNATE"))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat(
      "Validating response file target retain db user list (tgt_RETAIN_DB_USER_LIST): ",drrr_rf_data
      ->tgt_retain_db_user_list)
     SET dm_err->emsg = concat("Response file target db copy type (TGT_DB_COPY_TYPE) must ",
      'be equal to "ALTERNATE" in order to retain database users.')
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    WHILE (dvrtrdul_str != dvrtrdul_notfnd)
     SET dvrtrdul_str = piece(drrr_rf_data->tgt_retain_db_user_list,",",dvrtrdul_num,dvrtrdul_notfnd)
     IF (dvrtrdul_str != dvrtrdul_notfnd)
      IF (findstring('"',dvrtrdul_str,1,0) != findstring('"',dvrtrdul_str,1,1))
       SET dvrtrdul_tmp_user = cnvtupper(trim(replace(dvrtrdul_str,'"',"",0),3))
       IF (size(trim(dvrtrdul_tmp_user,3)) > 0)
        IF (trim(dvrtrdul_tmp_user,3) IN ("V500", "CDBA"))
         SET dm_err->err_ind = 1
         SET dm_err->eproc = concat(
          "Validating response file target retain db user list (tgt_RETAIN_DB_USER_LIST): ",
          drrr_rf_data->tgt_retain_db_user_list)
         SET dm_err->emsg = "V500/CDBA cannot be included in list of database users to be retained."
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ELSE
         IF (cnvtalphanum(trim(dvrtrdul_tmp_user,3)) != replace(trim(dvrtrdul_tmp_user,3),"_","",0))
          SET dm_err->err_ind = 1
          SET dm_err->eproc = concat(
           "Validating response file target retain db user list (tgt_RETAIN_DB_USER_LIST): ",
           drrr_rf_data->tgt_retain_db_user_list)
          SET dm_err->emsg =
          "One or more database users contains invalid characters (only allowing alphanumerics and underscores)."
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          RETURN(0)
         ELSE
          SET drrr_misc_data->tgt_retain_db_user_cnt = (drrr_misc_data->tgt_retain_db_user_cnt+ 1)
          SET stat = alterlist(drrr_misc_data->tgt_retain_db_users,drrr_misc_data->
           tgt_retain_db_user_cnt)
          SET drrr_misc_data->tgt_retain_db_users[drrr_misc_data->tgt_retain_db_user_cnt].user_name
           = dvrtrdul_tmp_user
          SET dvrtrdul_num = (dvrtrdul_num+ 1)
         ENDIF
        ENDIF
       ELSE
        SET dm_err->err_ind = 1
        SET dm_err->eproc = concat(
         "Validating response file target retain db user list (tgt_RETAIN_DB_USER_LIST): ",
         drrr_rf_data->tgt_retain_db_user_list)
        SET dm_err->emsg = concat("Individual database user name in position ",trim(cnvtstring(
           dvrtrdul_num),3)," not properly set.")
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ELSE
       SET dm_err->err_ind = 1
       SET dm_err->eproc = concat(
        "Validating response file target retain db user list (tgt_RETAIN_DB_USER_LIST): ",
        drrr_rf_data->tgt_retain_db_user_list)
       SET dm_err->emsg = concat("Individual database user name (",trim(dvrtrdul_str,3),
        ") not wrapped in double-quotes.")
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
    ENDWHILE
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_database_users(null)
   DECLARE dvrtdu_num = i4 WITH protect, noconstant(0)
   DECLARE dvrtdu_missing_users = vc WITH protect, noconstant("")
   DECLARE dvrtdu_reserve_users = vc WITH protect, noconstant("")
   DECLARE dvrtdu_invalid_pres_users = vc WITH protect, noconstant("")
   DECLARE dvrtdu_user_name = vc WITH protect, noconstant("")
   DECLARE dvrtdu_user_name_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE dvrtdu_iter = i4 WITH protect, noconstant(0)
   FREE RECORD dvrtdu_preserve_users
   RECORD dvrtdu_preserve_users(
     1 cnt = i4
     1 user[*]
       2 user_name = vc
   )
   IF ((drrr_misc_data->tgt_retain_db_user_cnt > 0))
    SET dm_err->eproc = "Selecting list of users to be preserved from dm_info."
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE "DM2_CERN_CUST_USER"=di.info_domain
     HEAD REPORT
      dvrtdu_preserve_users->cnt = 0, stat = alterlist(dvrtdu_preserve_users->user,0)
     DETAIL
      dvrtdu_preserve_users->cnt = (dvrtdu_preserve_users->cnt+ 1), stat = alterlist(
       dvrtdu_preserve_users->user,dvrtdu_preserve_users->cnt), dvrtdu_preserve_users->user[
      dvrtdu_preserve_users->cnt].user_name = trim(di.info_name)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dvrtdu_preserve_users)
    ENDIF
    FOR (dvrtdu_num = 1 TO drrr_misc_data->tgt_retain_db_user_cnt)
      SET dvrtdu_user_name = drrr_misc_data->tgt_retain_db_users[dvrtdu_num].user_name
      SET dm_err->eproc = "Validating retain database user exists in database."
      SELECT INTO "nl:"
       FROM dba_users u
       WHERE (u.username=drrr_misc_data->tgt_retain_db_users[dvrtdu_num].user_name)
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ELSEIF (curqual=0)
       SET dvrtdu_missing_users = build(dvrtdu_missing_users,dvrtdu_user_name,",")
      ENDIF
      SET dm_err->eproc =
      "Validating retain database user is not a Cerner shipped or Oracle database user."
      SELECT INTO "nl:"
       FROM dm_info d
       WHERE d.info_name=dvrtdu_user_name
        AND d.info_domain IN ("DM2_CERNER_USER", "DM2_ORACLE_USER")
        AND d.info_number=1
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ELSEIF (curqual > 0)
       SET dvrtdu_reserve_users = build(dvrtdu_reserve_users,dvrtdu_user_name,",")
      ENDIF
      SET dm_err->eproc = concat("Validating retain database user ",dvrtdu_user_name,
       " is a custom user from the users list to be preserved.")
      CALL disp_msg("",dm_err->logfile,0)
      SET dvrtdu_user_name_exists_ind = 0
      FOR (dvrtdu_iter = 1 TO dvrtdu_preserve_users->cnt)
        IF (dvrtdu_user_name=patstring(dvrtdu_preserve_users->user[dvrtdu_iter].user_name,0))
         SET dvrtdu_user_name_exists_ind = 1
         SET dvrtdu_iter = (dvrtdu_preserve_users->cnt+ 1)
        ENDIF
      ENDFOR
      IF (dvrtdu_user_name_exists_ind=0)
       SET dvrtdu_invalid_pres_users = build(dvrtdu_invalid_pres_users,dvrtdu_user_name,",")
      ENDIF
    ENDFOR
    IF (((size(trim(dvrtdu_missing_users,3)) > 0) OR (((size(trim(dvrtdu_reserve_users,3)) > 0) OR (
    size(trim(dvrtdu_invalid_pres_users,3)) > 0)) )) )
     SET dm_err->emsg = ""
     IF (size(trim(dvrtdu_missing_users,3)) > 0)
      SET dvrtdu_missing_users = concat("Individual database users not found (",trim(replace(
         dvrtdu_missing_users,",","",2),3),").")
     ENDIF
     IF (size(trim(dvrtdu_reserve_users,3)) > 0)
      SET dvrtdu_reserve_users = concat("Individual database users marked as Cerner/Oracle users (",
       trim(replace(dvrtdu_reserve_users,",","",2),3),").")
     ENDIF
     IF (size(trim(dvrtdu_invalid_pres_users,3)) > 0)
      SET dvrtdu_invalid_pres_users = concat(
       "Individual database users are not valid preserve users (",trim(replace(
         dvrtdu_invalid_pres_users,",","",2),3),").")
     ENDIF
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat(
      "Validating response file target retain db user list (tgt_RETAIN_DB_USER_LIST): ",drrr_rf_data
      ->tgt_retain_db_user_list)
     IF (size(trim(dvrtdu_missing_users,3)) > 0)
      SET dm_err->emsg = trim(dvrtdu_missing_users,3)
     ENDIF
     IF (size(trim(dvrtdu_reserve_users,3)) > 0)
      SET dm_err->emsg = trim(concat(dm_err->emsg,"  ",trim(dvrtdu_reserve_users,3)),3)
     ENDIF
     IF (size(trim(dvrtdu_invalid_pres_users,3)) > 0)
      SET dm_err->emsg = trim(concat(dm_err->emsg,"  ",trim(dvrtdu_invalid_pres_users,3)),3)
     ENDIF
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_expimp_runners(null)
  IF ((((drrr_rf_data->tgt_expimp_runners < 0)) OR ((drrr_rf_data->tgt_expimp_runners > 10))) )
   SET drrr_rf_data->tgt_expimp_runners = 5
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_src_sys_cnnct_data(dvrsscd_in_cnct_to_db_ind)
   IF (((cnvtupper(drrr_rf_data->src_sys_pwd) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->src_sys_pwd,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file source SYS password: ",drrr_rf_data->
     src_sys_pwd)
    SET dm_err->emsg = "Response file source SYS password must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dvrsscd_in_cnct_to_db_ind=1)
    IF (((cnvtupper(drrr_rf_data->src_db_cnct_str) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
    "DM2NOTSET")) OR (size(trim(drrr_rf_data->src_db_cnct_str,3))=0)) )
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file source database connect string: ",
      drrr_rf_data->src_db_cnct_str)
     SET dm_err->emsg =
     "Response file source database connect string must be set to a specific value."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (((cnvtupper(drrr_rf_data->src_db_name) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
    "DM2NOTSET")) OR (size(trim(drrr_rf_data->src_db_name,3))=0)) )
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file source database name: ",drrr_rf_data->
      src_db_name)
     SET dm_err->emsg = "Response file source database name must be set to a specific value."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (cnvtupper(drrr_rf_data->src_db_deploy_config) IN ("OP", "OCI"))
     SET drrr_rf_data->src_sys_user = "SYS"
    ELSE
     SET drrr_rf_data->src_sys_user = "ADMIN"
    ENDIF
    SET dm2_install_schema->u_name = drrr_rf_data->src_sys_user
    SET dm2_install_schema->p_word = drrr_rf_data->src_sys_pwd
    SET dm2_install_schema->connect_str = drrr_rf_data->src_db_cnct_str
    SET dm2_install_schema->dbase_name = '"SOURCE"'
    EXECUTE dm2_connect_to_dbase "CO"
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    IF (cnvtupper(currdbname) != cnvtupper(drrr_rf_data->src_db_name))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file source database name: ",drrr_rf_data->
      src_db_name)
     SET dm_err->emsg = concat(
      "Response file source database name does not match db name after connection (",trim(currdbname,
       3),").")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_db_temp_dir(null)
   IF (((cnvtupper(drrr_rf_data->tgt_db_temp_dir) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_db_temp_dir,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target db temp directory: ",drrr_rf_data->
     tgt_db_temp_dir)
    SET dm_err->emsg =
    "Response file target db temp directory (tgt_DB_TEMP_DIR) must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (substring(1,1,drrr_rf_data->tgt_db_temp_dir) != "/")
    SET drrr_rf_data->tgt_db_temp_dir = concat("/",drrr_rf_data->tgt_db_temp_dir)
   ENDIF
   IF (findstring("/",trim(drrr_rf_data->tgt_db_temp_dir),1,1) != size(trim(drrr_rf_data->
     tgt_db_temp_dir)))
    SET drrr_rf_data->tgt_db_temp_dir = concat(trim(drrr_rf_data->tgt_db_temp_dir),"/")
   ENDIF
   IF (textlen(drrr_rf_data->tgt_db_temp_dir) > 175)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target db temp directory: ",drrr_rf_data->
     tgt_db_temp_dir)
    SET dm_err->emsg = concat(
     "Full path of target db temp directory should not exceed 175 characters.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_src_db_temp_dir(null)
   IF (((cnvtupper(drrr_rf_data->src_db_temp_dir) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->src_db_temp_dir,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file source db temp directory: ",drrr_rf_data->
     src_db_temp_dir)
    SET dm_err->emsg =
    "Response file source db temp directory (src_DB_TEMP_DIR) must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (substring(1,1,drrr_rf_data->src_db_temp_dir) != "/")
    SET drrr_rf_data->src_db_temp_dir = concat("/",drrr_rf_data->src_db_temp_dir)
   ENDIF
   IF (findstring("/",trim(drrr_rf_data->src_db_temp_dir),1,1) != size(trim(drrr_rf_data->
     src_db_temp_dir)))
    SET drrr_rf_data->src_db_temp_dir = concat(trim(drrr_rf_data->src_db_temp_dir),"/")
   ENDIF
   IF (textlen(drrr_rf_data->src_db_temp_dir) > 175)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file source db temp directory: ",drrr_rf_data->
     src_db_temp_dir)
    SET dm_err->emsg = concat(
     "Full path of source db temp directory should not exceed 175 characters.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_db_oracle_misc(null)
   DECLARE dvrt_shared_pool_size_1 = vc WITH protect, noconstant("536870912")
   DECLARE dvrt_shared_pool_size_2 = vc WITH protect, noconstant("1241513984")
   IF (((cnvtupper(drrr_rf_data->tgt_db_oracle_ver) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_db_oracle_ver,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target db oracle version: ",drrr_rf_data->
     tgt_db_oracle_ver)
    SET dm_err->emsg =
    "Response file target db oracle version (tgt_DB_ORACLE_VER) must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((drrr_rf_data->tgt_db_oracle_ver != patstring("10.*"))
    AND (drrr_rf_data->tgt_db_oracle_ver != patstring("11.*"))
    AND (drrr_rf_data->tgt_db_oracle_ver != patstring("12.*"))
    AND (drrr_rf_data->tgt_db_oracle_ver != patstring("19*")))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target db oracle version: ",drrr_rf_data->
     tgt_db_oracle_ver)
    SET dm_err->emsg =
    "Response file target db oracle version (tgt_DB_ORACLE_VER) must be set to supported version (10.x,11.x,12.x,19)."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_db_oracle_home) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_db_oracle_home,3))=0)) )
    IF ((drrr_rf_data->tgt_db_oracle_ver="10.1"))
     SET drrr_rf_data->tgt_db_oracle_home = "/u01/oracle/product/10.1.0.5/db/"
    ELSEIF ((drrr_rf_data->tgt_db_oracle_ver="10.2"))
     SET drrr_rf_data->tgt_db_oracle_home = "/u01/oracle/product/10.2.0.3/db/"
    ELSEIF ((drrr_rf_data->tgt_db_oracle_ver="11.1"))
     SET drrr_rf_data->tgt_db_oracle_home = "/u01/oracle/product/11.1.0.7/db/"
    ELSEIF ((drrr_rf_data->tgt_db_oracle_ver="11.2"))
     SET drrr_rf_data->tgt_db_oracle_home = "/u01/oracle/product/11.2.0.3/db/"
    ELSEIF ((drrr_rf_data->tgt_db_oracle_ver="12.2"))
     SET drrr_rf_data->tgt_db_oracle_home = "/u01/oracle/product/12.2.0.1/db"
    ELSEIF ((drrr_rf_data->tgt_db_oracle_ver="19"))
     SET drrr_rf_data->tgt_db_oracle_home = "/u01/oracle/product/19/db"
    ENDIF
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_db_oracle_home) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_db_oracle_home,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target db oracle home: ",drrr_rf_data->
     tgt_db_oracle_home)
    SET dm_err->emsg =
    "Response file target db oracle home (tgt_DB_ORACLE_HOME) must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (substring(1,1,drrr_rf_data->tgt_db_oracle_home) != "/")
    SET drrr_rf_data->tgt_db_oracle_home = concat("/",drrr_rf_data->tgt_db_oracle_home)
   ENDIF
   IF (findstring("/",trim(drrr_rf_data->tgt_db_oracle_home),1,1) != size(trim(drrr_rf_data->
     tgt_db_oracle_home)))
    SET drrr_rf_data->tgt_db_oracle_home = concat(trim(drrr_rf_data->tgt_db_oracle_home),"/")
   ENDIF
   IF (textlen(drrr_rf_data->tgt_db_oracle_home) > 175)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target db oracle home: ",drrr_rf_data->
     tgt_db_oracle_home)
    SET dm_err->emsg = concat("Full path of target db oracle home should not exceed 175 characters.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_db_oracle_base) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_db_oracle_base,3))=0)) )
    IF ((drrr_rf_data->tgt_db_oracle_ver IN ("10.1", "10.2")))
     SET drrr_rf_data->tgt_db_oracle_base = "/u02/oracle/"
    ELSEIF ((drrr_rf_data->tgt_db_oracle_ver="11.1"))
     SET drrr_rf_data->tgt_db_oracle_base = "/u02/"
    ELSEIF ((drrr_rf_data->tgt_db_oracle_ver="11.2"))
     SET drrr_rf_data->tgt_db_oracle_base = "/u02/"
    ELSEIF ((drrr_rf_data->tgt_db_oracle_ver="12.2"))
     SET drrr_rf_data->tgt_db_oracle_base = "/u02/"
    ELSEIF ((drrr_rf_data->tgt_db_oracle_ver="19"))
     SET drrr_rf_data->tgt_db_oracle_base = "/u01/oracle/product"
    ENDIF
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_db_oracle_base) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_db_oracle_base,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target db oracle base: ",drrr_rf_data->
     tgt_db_oracle_base)
    SET dm_err->emsg =
    "Response file target db oracle base (tgt_DB_ORACLE_BASE) must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (substring(1,1,drrr_rf_data->tgt_db_oracle_base) != "/")
    SET drrr_rf_data->tgt_db_oracle_base = concat("/",drrr_rf_data->tgt_db_oracle_base)
   ENDIF
   IF (findstring("/",trim(drrr_rf_data->tgt_db_oracle_base),1,1) != size(trim(drrr_rf_data->
     tgt_db_oracle_base)))
    SET drrr_rf_data->tgt_db_oracle_base = concat(trim(drrr_rf_data->tgt_db_oracle_base),"/")
   ENDIF
   IF (textlen(drrr_rf_data->tgt_db_oracle_base) > 175)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target db oracle base: ",drrr_rf_data->
     tgt_db_oracle_base)
    SET dm_err->emsg = concat("Target db oracle base should not exceed 175 characters.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (cnvtupper(drrr_rf_data->tgt_shared_pool_size) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET"))
    IF ((drrr_rf_data->tgt_db_oracle_ver="11.1"))
     SET drrr_rf_data->tgt_shared_pool_size = dvrt_shared_pool_size_1
    ELSEIF ((drrr_rf_data->tgt_db_oracle_ver IN ("11.2", "12.2", "19")))
     SET drrr_rf_data->tgt_shared_pool_size = dvrt_shared_pool_size_2
    ENDIF
   ENDIF
   IF ((drrr_rf_data->tgt_db_oracle_ver="11.1")
    AND cnvtreal(drrr_rf_data->tgt_shared_pool_size) < cnvtreal(dvrt_shared_pool_size_1))
    SET drrr_rf_data->tgt_shared_pool_size = dvrt_shared_pool_size_1
   ELSEIF ((drrr_rf_data->tgt_db_oracle_ver IN ("11.2", "12.2", "19"))
    AND cnvtreal(drrr_rf_data->tgt_shared_pool_size) < cnvtreal(dvrt_shared_pool_size_2))
    SET drrr_rf_data->tgt_shared_pool_size = dvrt_shared_pool_size_2
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_db_node(null)
   DECLARE dvrtanl_str = vc WITH protect, noconstant("")
   DECLARE dvrtanl_notfnd = vc WITH protect, constant("<not_found>")
   DECLARE dvrtanl_num = i4 WITH protect, noconstant(1)
   DECLARE dvrtanl_tmp_node = vc WITH protect, noconstant("")
   DECLARE dvrtanl_idx = i4 WITH protect, noconstant(0)
   IF (((cnvtupper(drrr_rf_data->tgt_db_node) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_db_node,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target db node: ",drrr_rf_data->tgt_db_node)
    SET dm_err->emsg = "Response file target db node (TGT_DB_NODE) must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_db_node_os) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_db_node_os,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target db node os: ",drrr_rf_data->
     tgt_db_node_os)
    SET dm_err->emsg =
    "Response file target db node os (TGT_DB_NODE_OS) must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ( NOT (cnvtupper(drrr_rf_data->tgt_db_node_os) IN ("LNX", "AIX", "HPX", "HPUX", "LINUX")))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating target db node os is UNIX."
    SET dm_err->emsg = "Target db node os (TGT_DB_NODE_OS) should be LNX/AIX/HPX."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (cnvtupper(drrr_rf_data->tgt_db_node_os)="HPUX")
    SET drrr_rf_data->tgt_db_node_os = "HPX"
   ELSEIF (cnvtupper(drrr_rf_data->tgt_db_node_os)="LINUX")
    SET drrr_rf_data->tgt_db_node_os = "LNX"
   ENDIF
   SET drrr_rf_data->tgt_db_node_os = cnvtupper(drrr_rf_data->tgt_db_node_os)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_db_shell_misc(null)
   DECLARE dvrtdsm_str = vc WITH protect, noconstant("")
   DECLARE dvrtdsm_notfnd = vc WITH protect, constant("<not_found>")
   DECLARE dvrtdsm_num = i4 WITH protect, noconstant(1)
   DECLARE dvrtdsm_error_cd = vc WITH protect, noconstant("")
   DECLARE dvrtdsm_idx = i4 WITH protect, noconstant(0)
   IF (((cnvtupper(drrr_rf_data->tgt_storage_dg) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_storage_dg,3))=0)) )
    SET drrr_rf_data->tgt_storage_dg = "DM2NOTSET"
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_recovery_dg) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_recovery_dg,3))=0)) )
    SET drrr_rf_data->tgt_recovery_dg = "DM2NOTSET"
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_archive_dest1) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_archive_dest1,3))=0)) )
    SET drrr_rf_data->tgt_archive_dest1 = "DM2NOTSET"
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_asm_sysdba_pwd) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_asm_sysdba_pwd,3))=0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target asm sysdba password: ",drrr_rf_data->
     tgt_asm_sysdba_pwd)
    SET dm_err->emsg =
    "Response file target asm sysdba password (TGT_ASM_SYSDBA_PWD) must be set to a specific value."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_tns_host_name) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_tns_host_name,3))=0)) )
    SET drrr_rf_data->tgt_tns_host_name = drrr_rf_data->tgt_db_node
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_tns_port) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_tns_port,3))=0)) )
    SET drrr_rf_data->tgt_tns_port = "DM2NOTSET"
   ENDIF
   IF (((cnvtupper(drrr_rf_data->adm_tns_port) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->adm_tns_port,3))=0)) )
    SET drrr_rf_data->adm_tns_port = "DM2NOTSET"
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_shell_ignorable_error_list) IN ("*VALUE*REQUIRED*",
   "*VALUE*UNSPECIFIED*", "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_shell_ignorable_error_list,3)
    )=0)) )
    SET drrr_rf_data->tgt_shell_ignorable_error_list = '"ORA-01921","ORA-00959"'
   ELSE
    IF (findstring("ORA-01921",drrr_rf_data->tgt_shell_ignorable_error_list,1,0)=0)
     SET drrr_rf_data->tgt_shell_ignorable_error_list = build(drrr_rf_data->
      tgt_shell_ignorable_error_list,',"ORA-01921"')
    ENDIF
    IF (findstring("ORA-00959",drrr_rf_data->tgt_shell_ignorable_error_list,1,0)=0)
     SET drrr_rf_data->tgt_shell_ignorable_error_list = build(drrr_rf_data->
      tgt_shell_ignorable_error_list,',"ORA-00959"')
    ENDIF
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_tns_cnct_str) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_tns_cnct_str,3))=0)) )
    IF ((drrr_rf_data->tgt_db_deploy_config IN ("OP", "OCI")))
     SET drrr_rf_data->tgt_tns_cnct_str = concat(drrr_rf_data->tgt_db_cnct_str,".world")
    ELSE
     SET drrr_rf_data->tgt_tns_cnct_str = drrr_rf_data->tgt_db_cnct_str
    ENDIF
   ENDIF
   IF (cnvtupper(drrr_rf_data->tgt_tns_mapping) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET"))
    SET drrr_rf_data->tgt_tns_mapping = "DM2NOTSET"
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_tns_svc_name) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_tns_svc_name,3))=0)) )
    IF ((drrr_rf_data->tgt_db_deploy_config IN ("OP", "OCI")))
     SET drrr_rf_data->tgt_tns_svc_name = concat("s",drrr_rf_data->tgt_db_name,".world")
    ELSEIF ((drrr_rf_data->tgt_db_deploy_config="ADB"))
     IF ((drrr_rf_data->tgt_tns_mapping="DM2NOTSET"))
      SET dm_err->err_ind = 1
      SET dm_err->eproc = concat(
       "Validating response file target TNS service name (TGT_TNS_SVC_NAME): ",drrr_rf_data->
       tgt_tns_svc_name)
      SET dm_err->emsg = "TNS service name required for connecting to Target ADB is NOT provided."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ELSE
      SET drrr_rf_data->tgt_tns_svc_name = "DM2NOTSET"
     ENDIF
    ENDIF
   ENDIF
   IF (drrr_val_rf_tgt_tns_mapping(null)=0)
    RETURN(0)
   ENDIF
   WHILE (dvrtdsm_str != dvrtdsm_notfnd)
    SET dvrtdsm_str = piece(drrr_rf_data->tgt_shell_ignorable_error_list,",",dvrtdsm_num,
     dvrtdsm_notfnd)
    IF (dvrtdsm_str != dvrtdsm_notfnd)
     IF (findstring('"',dvrtdsm_str,1,0) != findstring('"',dvrtdsm_str,1,1))
      SET dvrtdsm_error_cd = trim(replace(dvrtdsm_str,'"',"",0),3)
      IF (size(trim(dvrtdsm_error_cd,3)) > 0)
       IF (cnvtalphanum(cnvtupper(dvrtdsm_error_cd)) != cnvtupper(replace(replace(dvrtdsm_error_cd,
          ",","",0),"-","",0)))
        SET dm_err->err_ind = 1
        SET dm_err->eproc = concat(
         "Validating response file target shell ignorable error list (TGT_SHELL_IGNORABLE_ERROR_LIST): ",
         drrr_rf_data->tgt_shell_ignorable_error_list)
        SET dm_err->emsg = "Error codes can only contain alphanumeric characters and hyphens."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ELSE
        SET drrr_misc_data->tgt_shell_ign_error_cnt = (drrr_misc_data->tgt_shell_ign_error_cnt+ 1)
        SET stat = alterlist(drrr_misc_data->tgt_shell_ign_errors,drrr_misc_data->
         tgt_shell_ign_error_cnt)
        SET drrr_misc_data->tgt_shell_ign_errors[drrr_misc_data->tgt_shell_ign_error_cnt].error_cd =
        dvrtdsm_error_cd
        SET dvrtdsm_num = (dvrtdsm_num+ 1)
       ENDIF
      ELSE
       SET dm_err->err_ind = 1
       SET dm_err->eproc = concat(
        "Validating response file target shell ignorable error list (TGT_SHELL_IGNORABLE_ERROR_LIST): ",
        drrr_rf_data->tgt_shell_ignorable_error_list)
       SET dm_err->emsg = concat("Individual ignorable error in position ",trim(cnvtstring(
          dvrtdsm_num),3)," not properly set.")
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ELSE
      SET dm_err->err_ind = 1
      SET dm_err->eproc = concat(
       "Validating response file target shell ignorable error list (TGT_SHELL_IGNORABLE_ERROR_LIST): ",
       drrr_rf_data->tgt_shell_ignorable_error_list)
      SET dm_err->emsg = concat("Individual ignorable error (",trim(dvrtdsm_str,3),
       ") not wrapped in double-quotes.")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_solution_chks(null)
   DECLARE dvrtdsm_str = vc WITH protect, noconstant("")
   DECLARE dvrtdsm_notfnd = vc WITH protect, constant("<not_found>")
   DECLARE dvrtdsm_num = i4 WITH protect, noconstant(1)
   DECLARE dvrtdsm_error_cd = vc WITH protect, noconstant("")
   DECLARE dvrtdsm_idx = i4 WITH protect, noconstant(0)
   IF ((drrr_rf_data->tgt_db_copy_type="REFERENCE"))
    IF ( NOT (cnvtupper(drrr_rf_data->tgt_reapply_sched_templates) IN ("YES", "NO")))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat(
      "Validating response file target reapply scheduling templates (TGT_REAPPLY_SCHED_TEMPLATES): ",
      drrr_rf_data->tgt_reapply_sched_templates)
     SET dm_err->emsg =
     'Response file target reapply scheduling templates must be equal to "YES" or "NO".'
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET drrr_rf_data->tgt_reapply_sched_templates = cnvtupper(drrr_rf_data->
     tgt_reapply_sched_templates)
    IF ((drrr_rf_data->tgt_reapply_sched_templates="YES"))
     IF ((drrr_rf_data->tgt_reapply_sched_templates_range < 1))
      SET drrr_rf_data->tgt_reapply_sched_templates_range = 90
     ENDIF
     IF (((cnvtupper(drrr_rf_data->tgt_reapply_sched_templates_reset) IN ("*VALUE*REQUIRED*",
     "*VALUE*UNSPECIFIED*", "DM2NOTSET")) OR (size(trim(drrr_rf_data->
       tgt_reapply_sched_templates_reset,3))=0)) )
      SET drrr_rf_data->tgt_reapply_sched_templates_reset = "YES"
     ELSEIF ( NOT (cnvtupper(drrr_rf_data->tgt_reapply_sched_templates_reset) IN ("YES", "NO")))
      SET dm_err->err_ind = 1
      SET dm_err->eproc = concat(
       "Validating response file target reapply scheduling templates reset ",
       "(TGT_REAPPLY_SCHED_TEMPLATES_RESET): ",drrr_rf_data->tgt_reapply_sched_templates_reset)
      SET dm_err->emsg =
      'Response file target reapply scheduling templates reset must be equal to "YES" or "NO" if specified (defaults to YES).'
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET drrr_rf_data->tgt_reapply_sched_templates_reset = cnvtupper(drrr_rf_data->
      tgt_reapply_sched_templates_reset)
    ENDIF
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_copy_interrogator) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_copy_interrogator,3))=0)) )
    SET drrr_rf_data->tgt_copy_interrogator = "NO"
   ELSEIF ( NOT (cnvtupper(drrr_rf_data->tgt_copy_interrogator) IN ("YES", "NO")))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file (TGT_COPY_INTERROGATOR): ",drrr_rf_data->
     tgt_copy_interrogator)
    SET dm_err->emsg = concat("Response file target copy interrogator value must be equal ",
     ' to "YES" or "NO" if specified (defaults to NO).')
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET drrr_rf_data->tgt_copy_interrogator = cnvtupper(drrr_rf_data->tgt_copy_interrogator)
   IF (((cnvtupper(drrr_rf_data->tgt_interrogator_tmp_dir) IN ("*VALUE*REQUIRED*",
   "*VALUE*UNSPECIFIED*", "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_interrogator_tmp_dir,3))=0))
   )
    SET drrr_rf_data->tgt_interrogator_tmp_dir = "/tmp/"
   ENDIF
   IF (substring(1,1,drrr_rf_data->tgt_interrogator_tmp_dir) != "/")
    SET drrr_rf_data->tgt_interrogator_tmp_dir = concat("/",drrr_rf_data->tgt_interrogator_tmp_dir)
   ENDIF
   IF (findstring("/",trim(drrr_rf_data->tgt_interrogator_tmp_dir),1,1) != size(trim(drrr_rf_data->
     tgt_interrogator_tmp_dir)))
    SET drrr_rf_data->tgt_interrogator_tmp_dir = concat(trim(drrr_rf_data->tgt_interrogator_tmp_dir),
     "/")
   ENDIF
   IF (textlen(drrr_rf_data->tgt_interrogator_tmp_dir) > 175)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file target interrogator temp directory: ",
     drrr_rf_data->tgt_interrogator_tmp_dir)
    SET dm_err->emsg = concat(
     "Full path of target interrogator temp directory should not exceed 175 characters.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_apply_src_ed_registry(null)
   IF (((cnvtupper(drrr_rf_data->tgt_apply_src_ed_registry) IN ("*VALUE*REQUIRED*",
   "*VALUE*UNSPECIFIED*", "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_apply_src_ed_registry,3))=0
   )) )
    SET drrr_rf_data->tgt_apply_src_ed_registry = "NO"
   ELSEIF ( NOT (cnvtupper(drrr_rf_data->tgt_apply_src_ed_registry) IN ("YES", "NO")))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat(
     "Validating response file target apply source environment definitions registry ",
     "(TGT_APPLY_SRC_ED_REGISTRY): ",drrr_rf_data->tgt_apply_src_ed_registry)
    SET dm_err->emsg = concat(
     "Response file target apply source environment definitions registry must be equal ",
     ' to "YES" or "NO" if specified (defaults to NO).')
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET drrr_rf_data->tgt_apply_src_ed_registry = cnvtupper(drrr_rf_data->tgt_apply_src_ed_registry)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_registry_set_name(null)
   IF (((cnvtupper(drrr_rf_data->tgt_reg_ed_set_name) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_reg_ed_set_name,3))=0)) )
    SET drrr_rf_data->tgt_reg_ed_set_name = "DM2NOTSET"
   ENDIF
   SET drrr_rf_data->tgt_reg_ed_set_name = cnvtupper(drrr_rf_data->tgt_reg_ed_set_name)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_wh(null)
   IF (((cnvtupper(drrr_rf_data->tgt_top_dir) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_top_dir,3))=0)) )
    SET drrr_rf_data->tgt_top_dir = "/cerner"
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_cer_mgr_dir) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_cer_mgr_dir,3))=0)) )
    SET drrr_rf_data->tgt_cer_mgr_dir = build(drrr_rf_data->tgt_top_dir,"/mgr")
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_cer_mgr_log_dir) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_cer_mgr_log_dir,3))=0)) )
    SET drrr_rf_data->tgt_cer_mgr_log_dir = build(drrr_rf_data->tgt_cer_mgr_dir,"/log")
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_cer_mgr_exe_dir) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_cer_mgr_exe_dir,3))=0)) )
    CASE (dm2_sys_misc->cur_os)
     OF "AIX":
      SET drrr_rf_data->tgt_cer_mgr_exe_dir = build(drrr_rf_data->tgt_cer_mgr_dir,"/aixrs6000")
     OF "HPX":
      SET drrr_rf_data->tgt_cer_mgr_exe_dir = build(drrr_rf_data->tgt_cer_mgr_dir,"/hpuxia64")
     OF "LNX":
      SET drrr_rf_data->tgt_cer_mgr_exe_dir = build(drrr_rf_data->tgt_cer_mgr_dir,"/linuxx86-64")
    ENDCASE
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_cer_reg_dir) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_cer_reg_dir,3))=0)) )
    SET drrr_rf_data->tgt_cer_reg_dir = build(drrr_rf_data->tgt_top_dir,"/reg/`hostname`")
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_cer_fifo_dir) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_cer_fifo_dir,3))=0)) )
    SET drrr_rf_data->tgt_cer_fifo_dir = build(drrr_rf_data->tgt_top_dir,"/fifo")
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_cer_usock_dir) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_cer_usock_dir,3))=0)) )
    SET drrr_rf_data->tgt_cer_usock_dir = build(drrr_rf_data->tgt_top_dir,"/usock")
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_cer_lock_dir) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_cer_lock_dir,3))=0)) )
    SET drrr_rf_data->tgt_cer_lock_dir = build(drrr_rf_data->tgt_top_dir,"/lock")
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_wh_name) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_wh_name,3))=0)) )
    SET drrr_rf_data->tgt_wh_name = build(drrr_rf_data->tgt_domain_name,"_wh")
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_wh_dir) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_wh_dir,3))=0)) )
    SET drrr_rf_data->tgt_wh_dir = build("/cerner/w_standard/",drrr_rf_data->tgt_wh_name)
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_user_name) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_user_name,3))=0)) )
    SET drrr_rf_data->tgt_user_name = build("d_",cnvtlower(drrr_rf_data->tgt_domain_name))
   ENDIF
   IF ( NOT (cnvtupper(drrr_rf_data->common_to_tgt) IN ("YES", "NO")))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file common_to_tgt: ",drrr_rf_data->common_to_tgt
     )
    SET dm_err->emsg = 'Response file common_to_tgt must be equal to "YES" or "NO".'
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_ibus_env_mapping(null)
   DECLARE dvtiem_num = i2 WITH protect, noconstant(1)
   DECLARE dvtiem_str = vc WITH protect, noconstant("")
   DECLARE dvtiem_notfnd = vc WITH protect, constant("<not_found>")
   DECLARE dvtiem_tmp_str = vc WITH protect, noconstant("")
   DECLARE dvtiem_src_idx = i2 WITH protect, noconstant(0)
   DECLARE dvtiem_src_str = vc WITH protect, noconstant("")
   DECLARE dvtiem_tgt_str = vc WITH protect, noconstant("")
   IF (((cnvtupper(drrr_rf_data->tgt_ibus_env_mapping) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_ibus_env_mapping,3))=0)) )
    SET drrr_rf_data->tgt_ibus_env_mapping = "DM2NOTSET"
    RETURN(1)
   ENDIF
   SET dvtiem_str = build(drrr_rf_data->tgt_ibus_env_mapping)
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("dvtiem_str = ",dvtiem_str))
   ENDIF
   WHILE (dvtiem_str != dvtiem_notfnd)
     SET dvtiem_str = piece(drrr_rf_data->tgt_ibus_env_mapping,",",dvtiem_num,dvtiem_notfnd)
     IF (dvtiem_num=1
      AND dvtiem_str=dvtiem_notfnd)
      SET dvtiem_str = drrr_rf_data->tgt_ibus_env_mapping
     ENDIF
     IF (dvtiem_str != dvtiem_notfnd)
      IF (dvtiem_num <= 50)
       IF (findstring('"',dvtiem_str,1,0) != findstring('"',dvtiem_str,1,1))
        SET dvtiem_tmp_str = trim(replace(dvtiem_str,'"',"",0),3)
        IF (size(trim(dvtiem_tmp_str,3)) > 0)
         IF (findstring(":",dvtiem_tmp_str,1,0) > 1
          AND findstring(":",dvtiem_tmp_str,1,0) < size(trim(dvtiem_tmp_str,3)))
          SET dvtiem_src_str = value(piece(dvtiem_tmp_str,":",1,dvtiem_notfnd))
          SET dvtiem_tgt_str = value(piece(dvtiem_tmp_str,":",2,dvtiem_notfnd))
          IF (((size(dvtiem_src_str) > 256) OR (size(dvtiem_tgt_str) > 256)) )
           SET dm_err->err_ind = 1
           SET dm_err->eproc = concat(
            "Validating response file target iBus environment mapping (tgt_IBUS_ENV_MAPPING): ",
            drrr_rf_data->tgt_ibus_env_mapping)
           SET dm_err->emsg = concat("iBus environment mapping in position ",trim(cnvtstring(
              dvtiem_num),3)," for both Source and Target should be less than 256 characters")
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           RETURN(0)
          ENDIF
          SET dvtiem_src_idx = 0
          IF (locateval(dvtiem_src_idx,1,drrr_misc_data->tgt_ibus_env_map_cnt,cnvtupper(
            dvtiem_src_str),cnvtupper(drrr_misc_data->tgt_ibus_env_map[dvtiem_src_idx].src_ibus_env))
          =0)
           SET drrr_misc_data->tgt_ibus_env_map_cnt = (drrr_misc_data->tgt_ibus_env_map_cnt+ 1)
           SET stat = alterlist(drrr_misc_data->tgt_ibus_env_map,drrr_misc_data->tgt_ibus_env_map_cnt
            )
           SET drrr_misc_data->tgt_ibus_env_map[drrr_misc_data->tgt_ibus_env_map_cnt].src_ibus_env =
           dvtiem_src_str
           SET drrr_misc_data->tgt_ibus_env_map[drrr_misc_data->tgt_ibus_env_map_cnt].tgt_ibus_env =
           dvtiem_tgt_str
          ELSE
           SET dm_err->err_ind = 1
           SET dm_err->eproc = concat(
            "Validating response file target iBus environment mapping (tgt_IBUS_ENV_MAPPING): ",
            drrr_rf_data->tgt_ibus_env_mapping)
           SET dm_err->emsg = concat("Source environment in position ",trim(cnvtstring(dvtiem_num),3),
            " should be unique.")
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           RETURN(0)
          ENDIF
          SET dvtiem_num = (dvtiem_num+ 1)
         ELSE
          SET dm_err->err_ind = 1
          SET dm_err->eproc = concat(
           "Validating response file target iBus environment mapping (tgt_IBUS_ENV_MAPPING): ",
           drrr_rf_data->tgt_ibus_env_mapping)
          SET dm_err->emsg = concat("iBus environment mapping in position ",trim(cnvtstring(
             dvtiem_num),3)," not properly set.")
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          RETURN(0)
         ENDIF
        ELSE
         SET dm_err->err_ind = 1
         SET dm_err->eproc = concat(
          "Validating response file target iBus environment mapping (tgt_IBUS_ENV_MAPPING): ",
          drrr_rf_data->tgt_ibus_env_mapping)
         SET dm_err->emsg = concat("iBus environment mapping in position ",trim(cnvtstring(dvtiem_num
            ),3)," not properly set.")
         SET dm_err->user_action =
         "Please specify iBus environment mappings wrapped in double qotes."
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
       ELSE
        SET dm_err->err_ind = 1
        SET dm_err->eproc = concat(
         "Validating response file target iBus environment mapping (tgt_IBUS_ENV_MAPPING): ",
         drrr_rf_data->tgt_ibus_env_mapping)
        SET dm_err->emsg = concat("iBus environment mapping (",trim(dvtiem_str,3),
         ") not wrapped in double-quotes.")
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ELSE
       SET dm_err->err_ind = 1
       SET dm_err->eproc = concat(
        "Validating response file target iBus environment mapping (tgt_IBUS_ENV_MAPPING): ",
        drrr_rf_data->tgt_ibus_env_mapping)
       SET dm_err->emsg = concat("iBus environment mappings should not be more than 50.")
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_db_user_pwd_mapping(null)
   DECLARE dvrtdup_pwd = vc WITH protect, noconstant("")
   DECLARE dvrtdup_user = vc WITH protect, noconstant("")
   DECLARE dvrtdup_str = vc WITH protect, noconstant("")
   DECLARE dvrtdup_user_idx = i2 WITH protect, noconstant(0)
   DECLARE dvrtdup_piece = vc WITH protect, noconstant("")
   DECLARE dvrtdup_notfnd = vc WITH protect, constant("<not_found>")
   DECLARE dvrtdup_num = i4 WITH protect, noconstant(1)
   DECLARE dvrtdup_str_cnt = i4 WITH protect, noconstant(0)
   IF (((cnvtupper(drrr_rf_data->tgt_db_user_pwd_mapping) IN ("*VALUE*REQUIRED*",
   "*VALUE*UNSPECIFIED*", "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_db_user_pwd_mapping,3))=0)) )
    IF ((drrr_misc_data->process_mode="COMPLETE COPY OF DATABASE"))
     SET drrr_rf_data->tgt_db_user_pwd_mapping = "DM2NOTSET"
     RETURN(1)
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validating Target database user/password mapping from response file"
     SET dm_err->emsg = concat(
      "The database user/password mapping is required.  The database user/password mapping must",
      ' be set using a single double-quote delimiter in format of <user>"<pwd>"<user>"<pwd>"<user>"<pwd>'
      )
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   SET dvrtdup_str = build(drrr_rf_data->tgt_db_user_pwd_mapping)
   IF ((dm_err->debug_flag > 5))
    CALL echo(build("dvrtdup_str = ",dvrtdup_str))
   ENDIF
   SET dvrtdup_str = replace(dvrtdup_str,"<=CERNd=>",'"',0)
   IF ((dm_err->debug_flag > 5))
    CALL echo(build("dvrtdup_str = ",dvrtdup_str))
   ENDIF
   IF (dvrtdup_str > "")
    SET dvrtdup_str_cnt = ((size(trim(dvrtdup_str,1)) - size(trim(replace(dvrtdup_str,'"',""),1)))/
    size('"'))
    IF ((dm_err->debug_flag > 5))
     CALL echo(build("dvrtdup_str_cnt = ",dvrtdup_str_cnt))
    ENDIF
    IF (dvrtdup_str_cnt > 0
     AND even(dvrtdup_str_cnt) != 1)
     WHILE (dvrtdup_piece != dvrtdup_notfnd)
       SET dvrtdup_piece = piece(dvrtdup_str,'"',dvrtdup_num,dvrtdup_notfnd)
       SET dvrtdup_num = (dvrtdup_num+ 1)
       IF (((size(dvrtdup_piece)=0) OR (trim(dvrtdup_piece,3)="")) )
        SET dm_err->err_ind = 1
        SET dm_err->eproc = "Validating Target database user/password mapping from response file"
        SET dm_err->emsg = concat(
         "Response file has empty entry.  The database user/password mapping must be set using",
         ' a single double-quote delimiter in format of <user>"<pwd>"<user>"<pwd>"<user>"<pwd>')
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
     ENDWHILE
     IF (even(dvrtdup_num) != 1)
      SET dm_err->err_ind = 1
      SET dm_err->eproc = "Validating Target database user/password mapping from response file"
      SET dm_err->emsg = concat(
       "Response file entry is not valid - missing user/password pairing.  The database user/password",
       ' mapping must be set using a single double-quote delimiter in format of <user>"<pwd>"<user>"<pwd>"<user>"<pwd>'
       )
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET dvrtdup_piece = ""
     SET dvrtdup_num = 1
     WHILE (dvrtdup_piece != dvrtdup_notfnd)
       SET dvrtdup_piece = ""
       SET dvrtdup_piece = piece(dvrtdup_str,'"',dvrtdup_num,dvrtdup_notfnd)
       IF (dvrtdup_piece != dvrtdup_notfnd)
        IF (even(dvrtdup_num)=1)
         SET dvrtdup_pwd = trim(dvrtdup_piece,3)
         IF (dvrtdup_pwd="<pwd>")
          SET dm_err->err_ind = 1
          SET dm_err->eproc = "Validating Target database user/password mapping from response file"
          SET dm_err->emsg = "Found user password still set to <pwd> placeholder."
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          RETURN(0)
         ENDIF
         SET dvrtdup_num = (dvrtdup_num+ 1)
         SET drrr_misc_data->tgt_db_user_pwd_map[drrr_misc_data->tgt_db_user_pwd_map_cnt].pwd =
         dvrtdup_pwd
        ELSE
         SET dvrtdup_user = cnvtupper(trim(dvrtdup_piece,3))
         SET dvrtdup_num = (dvrtdup_num+ 1)
         SET dvrtdup_user_idx = 0
         SET dvrtdup_user_idx = locateval(dvrtdup_user_idx,1,drrr_misc_data->tgt_db_user_pwd_map_cnt,
          dvrtdup_user,drrr_misc_data->tgt_db_user_pwd_map[dvrtdup_user_idx].user)
         IF (dvrtdup_user_idx=0)
          SET drrr_misc_data->tgt_db_user_pwd_map_cnt = (drrr_misc_data->tgt_db_user_pwd_map_cnt+ 1)
          SET stat = alterlist(drrr_misc_data->tgt_db_user_pwd_map,drrr_misc_data->
           tgt_db_user_pwd_map_cnt)
          SET drrr_misc_data->tgt_db_user_pwd_map[drrr_misc_data->tgt_db_user_pwd_map_cnt].user =
          dvrtdup_user
         ELSE
          SET dm_err->err_ind = 1
          SET dm_err->eproc = "Validating Target database user/password mapping from response file"
          SET dm_err->emsg = "Found duplicate user in the response file."
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          RETURN(0)
         ENDIF
        ENDIF
       ENDIF
     ENDWHILE
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validating Target database user/password mapping from response file"
     SET dm_err->emsg = concat(
      "The database user/password mapping is not properly delimited or syntax incorrect.  The database",
      " user/password mapping must be set using a single double-quote delimiter in format of",
      ' <user>"<pwd>"<user>"<pwd>"<user>"<pwd>')
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating Target database user/password mapping from response file"
    SET dm_err->emsg = concat(
     "No target database user/password mapping was specified.  The database user/password mapping must",
     ' be set using a single double-quote delimiter in format of <user>"<pwd>"<user>"<pwd>"<user>"<pwd>'
     )
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dvrtdup_user_idx = 0
   SET dvrtdup_user_idx = locateval(dvrtdup_user_idx,1,drrr_misc_data->tgt_db_user_pwd_map_cnt,
    "V500_READ",drrr_misc_data->tgt_db_user_pwd_map[dvrtdup_user_idx].user)
   IF (dvrtdup_user_idx=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating Target database user/password mapping from response file"
    SET dm_err->emsg = "Response file missing V500_READ user/password."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dvrtdup_user_idx = 0
   SET dvrtdup_user_idx = locateval(dvrtdup_user_idx,1,drrr_misc_data->tgt_db_user_pwd_map_cnt,
    "V500_EVENT",drrr_misc_data->tgt_db_user_pwd_map[dvrtdup_user_idx].user)
   IF (dvrtdup_user_idx=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating Target database user/password mapping from response file"
    SET dm_err->emsg = "Response file missing V500_EVENT user/password."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dvrtdup_user_idx = 0
   SET dvrtdup_user_idx = locateval(dvrtdup_user_idx,1,drrr_misc_data->tgt_db_user_pwd_map_cnt,
    drrr_rf_data->tgt_db_user,drrr_misc_data->tgt_db_user_pwd_map[dvrtdup_user_idx].user)
   IF (dvrtdup_user_idx=0)
    SET drrr_misc_data->tgt_db_user_pwd_map_cnt = (drrr_misc_data->tgt_db_user_pwd_map_cnt+ 1)
    SET stat = alterlist(drrr_misc_data->tgt_db_user_pwd_map,drrr_misc_data->tgt_db_user_pwd_map_cnt)
    SET drrr_misc_data->tgt_db_user_pwd_map[drrr_misc_data->tgt_db_user_pwd_map_cnt].user = cnvtupper
    (drrr_rf_data->tgt_db_user)
    SET drrr_misc_data->tgt_db_user_pwd_map[drrr_misc_data->tgt_db_user_pwd_map_cnt].pwd =
    drrr_rf_data->tgt_db_user_pwd
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_datapump(null)
   DECLARE dvra_db_name = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dvra_ora_client_ver_lvl1 = i2 WITH protect, noconstant(0)
   DECLARE dvra_ora_client_ver_lvl2 = i2 WITH protect, noconstant(0)
   DECLARE dvra_loc = i2 WITH protect, noconstant(0)
   DECLARE dvra_len = i2 WITH protect, noconstant(0)
   DECLARE dvra_dp_log_dir = vc WITH protect, noconstant("")
   SET dvra_db_name = drrr_rf_data->tgt_db_name
   IF ( NOT (cnvtupper(drrr_rf_data->src_dp_dir_setup) IN ("YES", "NO")))
    SET drrr_rf_data->src_dp_dir_setup = "YES"
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_dp_dir_name) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_dp_dir_name,3))=0)) )
    SET drrr_rf_data->tgt_dp_dir_name = cnvtupper(concat(dvra_db_name,"_EXPORT_IMPORT"))
   ELSE
    SET drrr_rf_data->tgt_dp_dir_name = cnvtupper(drrr_rf_data->tgt_dp_dir_name)
   ENDIF
   IF (((cnvtupper(drrr_rf_data->src_dp_dir_name) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->src_dp_dir_name,3))=0)) )
    SET drrr_rf_data->src_dp_dir_name = cnvtupper(concat(dvra_db_name,"_EXPORT_IMPORT"))
   ELSE
    SET drrr_rf_data->src_dp_dir_name = cnvtupper(drrr_rf_data->src_dp_dir_name)
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_dp_dir_path) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_dp_dir_path,3))=0)) )
    SET drrr_rf_data->tgt_dp_dir_path = concat(drrr_rf_data->tgt_db_temp_dir,cnvtlower(dvra_db_name),
     "_exp")
   ENDIF
   IF ((drrr_rf_data->tgt_db_deploy_config != "ADB"))
    IF (substring(1,1,drrr_rf_data->tgt_dp_dir_path) != "/")
     SET drrr_rf_data->tgt_dp_dir_path = concat("/",drrr_rf_data->tgt_dp_dir_path)
    ENDIF
   ELSE
    IF (substring(1,1,drrr_rf_data->tgt_dp_dir_path)="/")
     SET drrr_rf_data->tgt_dp_dir_path = replace(drrr_rf_data->tgt_dp_dir_path,"/","",1)
    ENDIF
   ENDIF
   IF (((cnvtupper(drrr_rf_data->src_dp_dir_path) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->src_dp_dir_path,3))=0)) )
    SET drrr_rf_data->src_dp_dir_path = concat(drrr_rf_data->src_db_temp_dir,cnvtlower(dvra_db_name),
     "_exp")
   ENDIF
   IF ((drrr_rf_data->src_db_deploy_config != "ADB"))
    IF (substring(1,1,drrr_rf_data->src_dp_dir_path) != "/")
     SET drrr_rf_data->src_dp_dir_path = concat("/",drrr_rf_data->src_dp_dir_path)
    ENDIF
   ELSE
    IF (substring(1,1,drrr_rf_data->src_dp_dir_path)="/")
     SET drrr_rf_data->src_dp_dir_path = replace(drrr_rf_data->src_dp_dir_path,"/","",1)
    ENDIF
   ENDIF
   IF (cnvtupper(drrr_rf_data->src_dp_dir_setup)="YES")
    IF (drrr_val_rf_src_sys_cnnct_data(1)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ( NOT (cnvtupper(drrr_rf_data->src_drop_expimp_dir) IN ("YES", "NO")))
    SET drrr_rf_data->src_drop_expimp_dir = "YES"
   ELSE
    SET drrr_rf_data->src_drop_expimp_dir = cnvtupper(drrr_rf_data->src_drop_expimp_dir)
   ENDIF
   IF ( NOT (cnvtupper(drrr_rf_data->tgt_drop_expimp_dir) IN ("YES", "NO")))
    SET drrr_rf_data->tgt_drop_expimp_dir = "YES"
   ELSE
    SET drrr_rf_data->tgt_drop_expimp_dir = cnvtupper(drrr_rf_data->tgt_drop_expimp_dir)
   ENDIF
   IF (((cnvtupper(drrr_rf_data->src_db_deploy_config) IN ("OCI", "ADB")) OR (cnvtupper(drrr_rf_data
    ->tgt_db_deploy_config) IN ("OCI", "ADB"))) )
    IF (((cnvtupper(drrr_rf_data->tgt_app_oracle_home) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
    "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_app_oracle_home,3))=0)) )
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file target app oracle home: ",drrr_rf_data->
      tgt_app_oracle_home)
     SET dm_err->emsg =
     "Response file target app oracle home (tgt_APP_ORACLE_HOME) must be set to a specific value."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (substring(1,1,drrr_rf_data->tgt_app_oracle_home) != "/")
     SET drrr_rf_data->tgt_app_oracle_home = concat("/",drrr_rf_data->tgt_app_oracle_home)
    ENDIF
    IF (findstring("/",trim(drrr_rf_data->tgt_app_oracle_home),1,1) != size(trim(drrr_rf_data->
      tgt_app_oracle_home)))
     SET drrr_rf_data->tgt_app_oracle_home = concat(trim(drrr_rf_data->tgt_app_oracle_home),"/")
    ENDIF
    IF (textlen(drrr_rf_data->tgt_app_oracle_home) > 175)
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file target app oracle home: ",drrr_rf_data->
      tgt_app_oracle_home)
     SET dm_err->emsg = concat(
      "Full path of target app oracle home should not exceed 175 characters.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (((cnvtupper(drrr_rf_data->tgt_app_oracle_client_ver) IN ("*VALUE*REQUIRED*",
    "*VALUE*UNSPECIFIED*", "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_app_oracle_client_ver,3))=0
    )) )
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file target app oracle client version: ",
      drrr_rf_data->tgt_app_oracle_client_ver)
     SET dm_err->emsg =
     "Response file target app oracle client version (tgt_APP_ORACLE_CLIENT_VER) must be set to a specific value."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dvra_loc = findstring(".",drrr_rf_data->tgt_app_oracle_client_ver,1,0)
    IF (dvra_loc > 0)
     SET dvra_len = (dvra_loc - 1)
     IF ((dm_err->debug_flag > 0))
      CALL echo(build("dvra_loc = ",dvra_loc))
      CALL echo(build("dvra_len = ",dvra_len))
     ENDIF
     SET dvra_ora_client_ver_lvl1 = cnvtint(substring(1,dvra_len,drrr_rf_data->
       tgt_app_oracle_client_ver))
     SET dvra_prev_loc = dvra_loc
     SET dvra_len = (textlen(drrr_rf_data->tgt_app_oracle_client_ver) - dvra_prev_loc)
     SET dvra_loc = findstring(".",drrr_rf_data->tgt_app_oracle_client_ver,(dvra_prev_loc+ 1),0)
     IF (dvra_loc > 0)
      SET dvra_ora_client_ver_lvl2 = cnvtint(substring((dvra_prev_loc+ 1),((dvra_loc - dvra_prev_loc)
         - 1),drrr_rf_data->tgt_app_oracle_client_ver))
     ELSE
      SET dvra_ora_client_ver_lvl2 = cnvtint(substring((dvra_prev_loc+ 1),dvra_len,drrr_rf_data->
        tgt_app_oracle_client_ver))
     ENDIF
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echo(build("dvra_new_loc = ",dvra_loc))
     CALL echo(build("dvra_len = ",dvra_len))
     CALL echo(build("dvra_ora_client_ver_lvl1 = ",dvra_ora_client_ver_lvl1))
     CALL echo(build("dvra_ora_client_ver_lvl2 = ",dvra_ora_client_ver_lvl2))
    ENDIF
    IF (((dvra_ora_client_ver_lvl1 < 19) OR (dvra_ora_client_ver_lvl1=19
     AND dvra_ora_client_ver_lvl2 < 14)) )
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file target app oracle client version: ",
      drrr_rf_data->tgt_app_oracle_client_ver)
     SET dm_err->emsg = concat(
      "Response file target app oracle client version (tgt_APP_ORACLE_CLIENT_VER) must be set to ",
      "supported version equal or greater than 19.14.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (((cnvtupper(drrr_rf_data->tgt_app_dp_temp_dir) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
    "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_app_dp_temp_dir,3))=0)) )
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file target app datapump temp directory: ",
      drrr_rf_data->tgt_app_dp_temp_dir)
     SET dm_err->emsg =
     "Response file target app datapump temp directory must be set to a specific value."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (substring(1,1,drrr_rf_data->tgt_app_dp_temp_dir) != "/")
     SET drrr_rf_data->tgt_app_dp_temp_dir = concat("/",drrr_rf_data->tgt_app_dp_temp_dir)
    ENDIF
    IF (findstring("/",trim(drrr_rf_data->tgt_app_dp_temp_dir),1,1) != size(trim(drrr_rf_data->
      tgt_app_dp_temp_dir)))
     SET drrr_rf_data->tgt_app_dp_temp_dir = concat(trim(drrr_rf_data->tgt_app_dp_temp_dir),"/")
    ENDIF
    IF ( NOT (dm2_find_dir(drrr_rf_data->tgt_app_dp_temp_dir)))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file target app datapump temp directory: ",
      drrr_rf_data->tgt_app_dp_temp_dir)
     SET dm_err->emsg = "Failed to find target app datapump temp directory. "
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (textlen(drrr_rf_data->tgt_app_dp_temp_dir) > 175)
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file target app datapump temp directory: ",
      drrr_rf_data->tgt_app_dp_temp_dir)
     SET dm_err->emsg = concat(
      "Full path of target app datapump temp directory should not exceed 175 characters.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (drrr_val_write_privs(drrr_rf_data->tgt_app_dp_temp_dir)=0)
     RETURN(0)
    ENDIF
    SET dvra_dp_log_dir = concat(drrr_rf_data->tgt_app_dp_temp_dir,cnvtlower(dvra_db_name),"_exp")
    IF ( NOT (dm2_find_dir(dvra_dp_log_dir)))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating target app datapump log directory on the app node: ",
      dvra_dp_log_dir)
     SET dm_err->emsg = "Failed to find target app datapump log directory. "
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (drrr_val_write_privs(dvra_dp_log_dir)=0)
     RETURN(0)
    ENDIF
    SET drrr_rf_data->tgt_app_dp_node = drrr_rf_data->tgt_primary_app_node
   ENDIF
   IF (((cnvtupper(drrr_rf_data->src_db_deploy_config) IN ("OCI", "ADB")) OR (cnvtupper(drrr_rf_data
    ->tgt_db_deploy_config) IN ("OCI", "ADB"))) )
    IF ((validate(dm2_bypass_dp_oos,- (1))=- (1)))
     IF (((cnvtupper(drrr_rf_data->dp_cred_name) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
     "DM2NOTSET")) OR (size(trim(drrr_rf_data->dp_cred_name,3))=0)) )
      SET drrr_rf_data->dp_cred_name = "DP_CRED_NAME"
     ELSE
      SET drrr_rf_data->dp_cred_name = cnvtupper(drrr_rf_data->dp_cred_name)
     ENDIF
     IF (((findstring("-",drrr_rf_data->dp_cred_name,1,0) > 0) OR (findstring(" ",drrr_rf_data->
      dp_cred_name,1,0) > 0)) )
      SET dm_err->err_ind = 1
      SET dm_err->eproc = concat("Validating datapump credential name: ",drrr_rf_data->dp_cred_name)
      SET dm_err->emsg = "Credential name do not allow spaces or hyphens. "
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (((cnvtupper(drrr_rf_data->dp_user) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
     "DM2NOTSET")) OR (size(trim(drrr_rf_data->dp_user,3))=0)) )
      SET dm_err->err_ind = 1
      SET dm_err->eproc = concat("Validating datapump user used for credential ",drrr_rf_data->
       dp_user)
      SET dm_err->emsg = "A valid user is required to create datapump credential."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (((cnvtupper(drrr_rf_data->dp_user_pwd) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
     "DM2NOTSET")) OR (size(trim(drrr_rf_data->dp_user_pwd,3))=0)) )
      SET dm_err->err_ind = 1
      SET dm_err->eproc = concat("Validating datapump user password used for credential ",
       drrr_rf_data->dp_user_pwd)
      SET dm_err->emsg = "A valid user password is required to create datapump credential."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (((cnvtupper(drrr_rf_data->dp_oos_dir_path) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
     "DM2NOTSET")) OR (size(trim(drrr_rf_data->dp_oos_dir_path,3))=0)) )
      SET dm_err->err_ind = 1
      SET dm_err->eproc = concat("Validating datapump object storage directory path: ",drrr_rf_data->
       dp_oos_dir_path)
      SET dm_err->emsg = "Datapump object storage directory path must be set to a specific value."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (findstring("https://swiftobjectstorage",drrr_rf_data->dp_oos_dir_path,1,0)=0)
      SET dm_err->err_ind = 1
      SET dm_err->eproc = concat("Validating datapump object storage directory path: ",drrr_rf_data->
       dp_oos_dir_path)
      SET dm_err->emsg = "The datapump object storage directory path is not in Swift URI."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (findstring("/",trim(drrr_rf_data->dp_oos_dir_path),1,1) != size(trim(drrr_rf_data->
       dp_oos_dir_path)))
      SET drrr_rf_data->dp_oos_dir_path = concat(trim(drrr_rf_data->dp_oos_dir_path),"/")
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_restore_list(null)
   DECLARE dvrrl_group = vc WITH protect, noconstant("")
   DECLARE dvrrl_value = vc WITH protect, noconstant("")
   DECLARE dvrrl_ind = i2 WITH protect, noconstant(0)
   DECLARE dvrrl_beg = i2 WITH protect, noconstant(1)
   DECLARE dvrrl_end = i2 WITH protect, noconstant(1)
   DECLARE dvrrl_cnt = i2 WITH protect, noconstant(0)
   DECLARE dvrrl_str = vc WITH protect, noconstant("")
   DECLARE dvrrl_group_idx = i2 WITH protect, noconstant(0)
   DECLARE dvrrl_finish = i2 WITH protect, noconstant(0)
   IF ( NOT (cnvtupper(drrr_rf_data->tgt_restore_preserve_data) IN ("YES", "NO")))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file RESTORE PRESERVE DATA: ",drrr_rf_data->
     tgt_restore_preserve_data)
    SET dm_err->emsg = 'Response file RESTORE PRESERVE DATA must be equal to "YES" or "NO".'
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET drrr_rf_data->tgt_restore_preserve_data = cnvtupper(drrr_rf_data->tgt_restore_preserve_data)
   IF ((drrr_rf_data->tgt_preserve_data="NO")
    AND (drrr_rf_data->tgt_restore_preserve_data="YES"))
    SET dm_err->err_ind = 1
    SET dm_err->eproc =
    'Validating response file restore preserve data indicator (TGT_RESTORE_PRESERVE_DATA) can be set to "YES".'
    SET dm_err->emsg = concat("Response file target preserve data (TGT_PRESERVE_DATA) must ",
     'be equal to "YES" in order to restore preserve data.')
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((drrr_rf_data->tgt_restore_preserve_data="YES"))
    IF (((cnvtupper(drrr_rf_data->tgt_restore_list) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
    "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_restore_list,3))=0)) )
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file target restore list: ",drrr_rf_data->
      tgt_restore_list)
     SET dm_err->emsg = "Response file target restore list list (TGT_RESTORE_LIST) must be set."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dvrrl_str = build(trim(cnvtupper(replace(drrr_rf_data->tgt_restore_list,'"',"",0)),4))
    IF ((dm_err->debug_flag > 0))
     CALL echo(build("dvrrl_str = ",dvrrl_str))
    ENDIF
    IF (dvrrl_str > "")
     WHILE ( NOT (dvrrl_finish))
       SET dvrrl_cnt = (dvrrl_cnt+ 1)
       IF ((dm_err->debug_flag > 0))
        CALL echo(build("cnt = ",dvrrl_cnt))
       ENDIF
       SET dvrrl_beg = dvrrl_end
       SET dvrrl_end = findstring(",",dvrrl_str,(dvrrl_beg+ 1),0)
       IF (dvrrl_end=0)
        SET dvrrl_end = (size(dvrrl_str)+ 1)
        SET dvrrl_finish = 1
       ENDIF
       IF (even(dvrrl_cnt)=1)
        IF ((dm_err->debug_flag > 0))
         CALL echo(build("beg = ",dvrrl_beg))
         CALL echo(build("end = ",dvrrl_end))
         CALL echo(substring((dvrrl_beg+ 1),((dvrrl_end - dvrrl_beg) - 1),dvrrl_str))
        ENDIF
        SET dvrrl_value = substring((dvrrl_beg+ 1),((dvrrl_end - dvrrl_beg) - 1),dvrrl_str)
        IF ((dm_err->debug_flag > 0))
         CALL echo(build("dvrrl_value = ",dvrrl_value))
        ENDIF
        IF ( NOT (cnvtupper(dvrrl_value) IN ("Y", "N")))
         SET dm_err->err_ind = 1
         SET dm_err->eproc = concat("Validating response file Target Restore List: ",drrr_rf_data->
          tgt_restore_list)
         SET dm_err->emsg = 'Response file Target Restore value must be equal to "Y" or "N".'
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
        IF (dvrrl_value="Y")
         SET dvrrl_ind = 1
        ELSE
         SET dvrrl_ind = 0
        ENDIF
        SET drrr_misc_data->tgt_restore_list[drrr_misc_data->tgt_restore_list_cnt].restore_ind =
        dvrrl_ind
       ELSE
        IF (dvrrl_beg=1)
         SET dvrrl_group = substring(dvrrl_beg,(dvrrl_end - dvrrl_beg),dvrrl_str)
        ELSE
         SET dvrrl_group = substring((dvrrl_beg+ 1),((dvrrl_end - dvrrl_beg) - 1),dvrrl_str)
        ENDIF
        IF ((dm_err->debug_flag > 0))
         CALL echo(build("dvrrl_group = ",dvrrl_group))
        ENDIF
        SET dvrrl_group_idx = locateval(dvrrl_group_idx,1,drrr_misc_data->tgt_restore_list_cnt,
         dvrrl_group,drrr_misc_data->tgt_restore_list[dvrrl_group_idx].restore_group)
        IF (dvrrl_group_idx=0)
         SET drrr_misc_data->tgt_restore_list_cnt = (drrr_misc_data->tgt_restore_list_cnt+ 1)
         SET stat = alterlist(drrr_misc_data->tgt_restore_list,drrr_misc_data->tgt_restore_list_cnt)
         SET drrr_misc_data->tgt_restore_list[drrr_misc_data->tgt_restore_list_cnt].restore_group =
         dvrrl_group
        ELSE
         SET dm_err->err_ind = 1
         SET dm_err->eproc = concat("Validating response file Target Restore List: ",drrr_rf_data->
          tgt_restore_list)
         SET dm_err->emsg = "Found duplicate restore group in the response file."
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
       ENDIF
     ENDWHILE
     IF (even(dvrrl_cnt) != 1)
      SET dm_err->err_ind = 1
      SET dm_err->eproc = concat("Validating response file Target Restore List: ",drrr_rf_data->
       tgt_restore_list)
      SET dm_err->emsg = concat(
       "The Target restore list is not properly delimited or syntax is incorrect. ",
       ' The restore list must be in <group>,<y/n> pairings and comma-delimited (i.e. "printers","y","rrd","y").'
       )
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET dvrrl_group_idx = 0
     IF (locateval(dvrrl_group_idx,1,drrr_misc_data->tgt_restore_list_cnt,"AUTOTESTER",drrr_misc_data
      ->tgt_restore_list[dvrrl_group_idx].restore_group)=0)
      SET dm_err->err_ind = 1
      SET dm_err->eproc = concat("Validating response file Target Restore List: ",drrr_rf_data->
       tgt_restore_list)
      SET dm_err->emsg = concat(
       'Group "AUTOTESTER" is missing from the Target restore list. This group is required.')
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_restore_groups(null)
   DECLARE dvrrg_ndx = i4 WITH protect, noconstant(0)
   DECLARE dvrrg_idx = i4 WITH protect, noconstant(0)
   DECLARE dvrrg_no_match = i4 WITH protect, noconstant(0)
   IF ((validate(dvrrg_group->cnt,- (1))=- (1))
    AND (validate(dvrrg_group->cnt,- (2))=- (2)))
    FREE RECORD dvrrg_group
    RECORD dvrrg_group(
      1 cnt = i2
      1 group[*]
        2 group_name = vc
    )
   ENDIF
   IF ((((drrr_rf_data->target_refresh="NO")) OR ((drrr_rf_data->target_refresh="YES")
    AND (drrr_rf_data->tgt_restore_preserve_data="NO"))) )
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Get preserved group names from dm_info."
   SELECT DISTINCT INTO "nl:"
    di.info_domain
    FROM dm_info di
    WHERE di.info_domain="DM2_PRESERVED_TABLE-*"
     AND di.info_domain != "DM2_PRESERVED_TABLE-NOPROMPT"
     AND di.info_number=1
    DETAIL
     pos = 0, pos = findstring("-",di.info_domain), dvrrg_group->cnt = (dvrrg_group->cnt+ 1),
     stat = alterlist(dvrrg_group->group,dvrrg_group->cnt), dvrrg_group->group[dvrrg_group->cnt].
     group_name = cnvtupper(substring((pos+ 1),size(di.info_domain),di.info_domain))
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   FOR (dvrrg_idx = 1 TO dvrrg_group->cnt)
     SET dvrrg_ndx = 0
     SET dvrrg_ndx = locateval(dvrrg_ndx,1,drrr_misc_data->tgt_restore_list_cnt,dvrrg_group->group[
      dvrrg_idx].group_name,drrr_misc_data->tgt_restore_list[dvrrg_ndx].restore_group)
     IF (dvrrg_ndx=0)
      SET dvrrg_no_match = 1
      SET dm_err->eproc = concat("Response file is missing PRESERVED group: ",dvrrg_group->group[
       dvrrg_idx].group_name)
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
   ENDFOR
   FOR (dvrrg_idx = 1 TO drrr_misc_data->tgt_restore_list_cnt)
     IF ((drrr_misc_data->tgt_restore_list[dvrrg_idx].restore_group != "AUTOTESTER"))
      SET dvrrg_ndx = 0
      SET dvrrg_ndx = locateval(dvrrg_ndx,1,dvrrg_group->cnt,drrr_misc_data->tgt_restore_list[
       dvrrg_idx].restore_group,dvrrg_group->group[dvrrg_ndx].group_name)
      IF (dvrrg_ndx=0)
       SET dvrrg_no_match = 1
       SET dm_err->eproc = concat("DM_INFO table is missing PRESERVED group: ",drrr_misc_data->
        tgt_restore_list[dvrrg_idx].restore_group)
       CALL disp_msg("",dm_err->logfile,0)
      ENDIF
     ENDIF
   ENDFOR
   IF (dvrrg_no_match=1)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Matching up dm_info PRESERVED groups with response file."
    SET dm_err->emsg = concat(
     "PRESERVED groups in the response file and DM_INFO table do not match up.",
     " Please verify that all PRESERVED groups in the response file have a matching DM_INFO row and vice versa."
     )
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_drr_shadow_tables(null)
   IF ( NOT (cnvtupper(drrr_rf_data->tgt_expimp_drr_shadow_tables) IN ("YES", "NO")))
    IF ((drrr_rf_data->tgt_expimp_drr_shadow_tables="DM2NOTSET"))
     SET drrr_rf_data->tgt_expimp_drr_shadow_tables = "NO"
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file TGT_EXPIMP_DRR_SHADOW_TABLES: ",
      drrr_rf_data->tgt_expimp_drr_shadow_tables)
     SET dm_err->emsg =
     'Response file token TGT_EXPIMP_DRR_SHADOW_TABLES must be equal to "YES" or "NO".'
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSEIF (cnvtupper(drrr_rf_data->tgt_expimp_drr_shadow_tables)="YES")
    IF (cnvtupper(drrr_rf_data->tgt_restore_preserve_data)="YES")
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file TGT_EXPIMP_DRR_SHADOW_TABLES: ",
      drrr_rf_data->tgt_expimp_drr_shadow_tables)
     SET dm_err->emsg =
     "TGT_EXPIMP_DRR_SHADOW_TABLES cannot be turned on when TGT_RESTORE_PRESERVE_DATA is set to YES."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   SET drrr_rf_data->tgt_expimp_drr_shadow_tables = cnvtupper(drrr_rf_data->
    tgt_expimp_drr_shadow_tables)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_mode(null)
   IF (((cnvtupper(drrr_rf_data->mode) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*", "DM2NOTSET"))
    OR (size(trim(drrr_rf_data->mode,3))=0)) )
    SET drrr_rf_data->mode = "DM2NOTSET"
   ENDIF
   SET drrr_rf_data->mode = cnvtupper(drrr_rf_data->mode)
   IF ((drrr_rf_data->mode != "DM2NOTSET"))
    IF ((drrr_rf_data->mode != "ISOLATED"))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file MODE: ",drrr_rf_data->mode)
     SET dm_err->emsg = "MODE must be set to ISOLATED if valued."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_db_create_type) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_db_create_type,3))=0)) )
    SET drrr_rf_data->tgt_db_create_type = "SHELL"
   ENDIF
   SET drrr_rf_data->tgt_db_create_type = cnvtupper(drrr_rf_data->tgt_db_create_type)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_isolated_mode(null)
   DECLARE dvrtdct_str = vc WITH protect, noconstant("")
   DECLARE dvrtdct_notfnd = vc WITH protect, constant("<not_found>")
   DECLARE dvrtdct_num = i4 WITH protect, noconstant(1)
   DECLARE dvrtdct_error_prefix = vc WITH protect, noconstant("")
   DECLARE dvrtdct_local_node_sn = vc WITH protect, noconstant("")
   DECLARE dvrtdct_db_node = vc WITH protect, noconstant("")
   DECLARE dvrtdct_db_node_sn = vc WITH protect, noconstant("")
   FREE RECORD dvrtdct_error_pref_rs
   RECORD dvrtdct_error_pref_rs(
     1 cnt = i4
     1 qual[*]
       2 prefix = vc
   )
   SET dvrtdct_error_pref_rs->cnt = 0
   SET stat = alterlist(dvrtdct_error_pref_rs->qual,0)
   IF (((cnvtupper(drrr_rf_data->src_db_env_name) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->src_db_env_name,3))=0)) )
    SET drrr_rf_data->src_db_env_name = "DM2NOTSET"
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_dbca_template) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_dbca_template,3))=0)) )
    SET drrr_rf_data->tgt_dbca_template = "DM2NOTSET"
   ENDIF
   SET drrr_rf_data->tgt_dbca_template = cnvtlower(drrr_rf_data->tgt_dbca_template)
   IF (((cnvtupper(drrr_rf_data->tgt_case_sens_logon) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_case_sens_logon,3))=0)) )
    SET drrr_rf_data->tgt_case_sens_logon = "DM2NOTSET"
   ENDIF
   SET drrr_rf_data->tgt_case_sens_logon = cnvtupper(drrr_rf_data->tgt_case_sens_logon)
   IF (((cnvtupper(drrr_rf_data->tgt_sql92_security) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_sql92_security,3))=0)) )
    SET drrr_rf_data->tgt_sql92_security = "DM2NOTSET"
   ENDIF
   SET drrr_rf_data->tgt_sql92_security = cnvtupper(drrr_rf_data->tgt_sql92_security)
   IF (((cnvtupper(drrr_rf_data->tgt_characterset) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_characterset,3))=0)) )
    SET drrr_rf_data->tgt_characterset = "DM2NOTSET"
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_error_prefix_list) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_error_prefix_list,3))=0)) )
    SET drrr_rf_data->tgt_error_prefix_list = "DM2NOTSET"
   ENDIF
   IF (((cnvtupper(drrr_rf_data->adm_db_node) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->adm_db_node,3))=0)) )
    SET drrr_rf_data->adm_db_node = "DM2NOTSET"
   ENDIF
   IF (((cnvtupper(drrr_rf_data->adm_storage_dg) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->adm_storage_dg,3))=0)) )
    SET drrr_rf_data->adm_storage_dg = "DM2NOTSET"
   ENDIF
   IF (((cnvtupper(drrr_rf_data->adm_recovery_dg) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->adm_recovery_dg,3))=0)) )
    SET drrr_rf_data->adm_recovery_dg = "DM2NOTSET"
   ENDIF
   IF ((drrr_rf_data->mode="ISOLATED"))
    IF ((drrr_rf_data->tgt_db_create_type="SHELL"))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat(
      "Validating response file target database create type (TGT_DB_CREATE_TYPE): ",drrr_rf_data->
      tgt_db_create_type)
     SET dm_err->emsg = "TGT_DB_CREATE_TYPE must be valued based on clinical dbca template."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((drrr_rf_data->target_refresh != "NO"))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file mode (MODE): ",drrr_rf_data->mode)
     SET dm_err->emsg = concat("Response file target refresh indicator (TARGET_REFRESH) must ",
      'be equal to "NO" for "ISOLATED" mode.')
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((drrr_rf_data->tgt_db_copy_type != "ALTERNATE"))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file mode (MODE): ",drrr_rf_data->mode)
     SET dm_err->emsg = concat("Response file target db copy type (TGT_DB_COPY_TYPE) must ",
      'be equal to "ALTERNATE" for "ISOLATED" mode.')
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((drrr_rf_data->src_db_env_name="DM2NOTSET"))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file mode (MODE): ",drrr_rf_data->mode)
     SET dm_err->emsg = concat("Response file source database environment name (SRC_DB_ENV_NAME) ",
      'must be valued for "ISOLATED" mode.')
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((drrr_rf_data->tgt_db_oracle_ver != "19"))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file mode (MODE): ",drrr_rf_data->mode)
     SET dm_err->emsg = concat(
      "Response file target database oracle version (TGT_DB_ORACLE_VER) must ",
      'be 19 for "ISOLATED" mode.')
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((drrr_rf_data->tgt_dbca_template != "dm2_dbca_seeded_*.dbc"))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file target dbca template (TGT_DBCA_TEMPLATE): ",
      drrr_rf_data->tgt_dbca_template)
     SET dm_err->emsg = concat(
      'TGT_DBCA_TEMPLATE must be in format of "dm2_dbca_seeded_<tgt_db_create_type>.dbc".')
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (findstring(cnvtlower(drrr_rf_data->tgt_db_create_type),drrr_rf_data->tgt_dbca_template)=0)
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat(
      "Validating response file target database create type (TGT_DB_CREATE_TYPE): ",drrr_rf_data->
      tgt_db_create_type)
     SET dm_err->emsg = concat("TGT_DB_CREATE_TYPE must be contained in the target dbca template (",
      drrr_rf_data->tgt_dbca_template,").")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ( NOT ((drrr_rf_data->tgt_case_sens_logon IN ("FALSE", "TRUE"))))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat(
      "Validating response file target case sensitive logon (TGT_CASE_SENS_LOGON): ",drrr_rf_data->
      tgt_case_sens_logon)
     SET dm_err->emsg = concat('TGT_CASE_SENS_LOGON must be equal to "TRUE" or "FALSE".')
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ( NOT ((drrr_rf_data->tgt_sql92_security IN ("FALSE", "TRUE"))))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat(
      "Validating response file target sql92 security (TGT_SQL92_SECURITY): ",drrr_rf_data->
      tgt_sql92_security)
     SET dm_err->emsg = concat('TGT_SQL92_SECURITY must be equal to "TRUE" or "FALSE".')
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((drrr_rf_data->tgt_characterset="DM2NOTSET"))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file target characterset (TGT_CHARACTERSET): ",
      drrr_rf_data->tgt_characterset)
     SET dm_err->emsg = concat("TGT_CHARACTERSET must be valued.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((drrr_rf_data->adm_db_node="DM2NOTSET"))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file admin database node (ADM_DB_NODE): ",
      drrr_rf_data->adm_db_node)
     SET dm_err->emsg = concat("ADM_DB_NODE must be valued.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((drrr_rf_data->tgt_error_prefix_list != "DM2NOTSET"))
     IF (findstring('"',drrr_rf_data->tgt_error_prefix_list,1,0) > 0
      AND findstring('"',drrr_rf_data->tgt_error_prefix_list,1,0) != findstring('"',drrr_rf_data->
      tgt_error_prefix_list,1,1))
      WHILE (dvrtdct_str != dvrtdct_notfnd)
       SET dvrtdct_str = piece(drrr_rf_data->tgt_error_prefix_list,",",dvrtdct_num,dvrtdct_notfnd)
       IF (dvrtdct_str != dvrtdct_notfnd)
        IF (findstring('"',dvrtdct_str,1,0) != findstring('"',dvrtdct_str,1,1))
         SET dvrtdct_error_prefix = trim(replace(dvrtdct_str,'"',"",0),3)
         IF (size(trim(dvrtdct_error_prefix,3)) > 0)
          SET dvrtdct_error_pref_rs->cnt = (dvrtdct_error_pref_rs->cnt+ 1)
          SET stat = alterlist(dvrtdct_error_pref_rs->qual,dvrtdct_error_pref_rs->cnt)
          SET dvrtdct_error_pref_rs->qual[dvrtdct_error_pref_rs->cnt].prefix = dvrtdct_error_prefix
          SET dvrtdct_num = (dvrtdct_num+ 1)
         ELSE
          SET dm_err->err_ind = 1
          SET dm_err->eproc = concat("Validating override error prefixes: ",drrr_rf_data->
           tgt_error_prefix_list)
          SET dm_err->emsg = concat("Individual override error prefix in position ",trim(cnvtstring(
             dvrtdct_num),3)," not properly set.")
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          RETURN(0)
         ENDIF
        ELSE
         SET dm_err->err_ind = 1
         SET dm_err->eproc = concat("Validating override error prefixes: ",drrr_rf_data->
          tgt_error_prefix_list)
         SET dm_err->emsg = concat("Individual override error prefix (",trim(dvrtdct_str,3),
          ") not wrapped in double-quotes.")
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
       ENDIF
      ENDWHILE
     ELSE
      SET dm_err->err_ind = 1
      SET dm_err->eproc = concat("Validating override error prefixes: ",drrr_rf_data->
       tgt_error_prefix_list)
      SET dm_err->emsg = concat(
       "Individual override error prefixes does not contain any double-quotes or pairs.")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    IF ((drrr_misc_data->process_mode IN ("ADMIN DATABASE CREATION", "CLINICAL DATABASE CREATION")))
     SET dvrtdct_local_node_sn = build(curnode)
     SET dvrtdct_db_node = drrr_rf_data->tgt_db_node
     SET dvrtdct_db_node_sn = dvrtdct_db_node
     IF (validate(dm2_skip_db_shell_fqdn_check,0)=1)
      IF (findstring(".",dvrtdct_db_node,1,0) > 0)
       SET dvrtdct_db_node_sn = substring(1,(findstring(".",dvrtdct_db_node,1,0) - 1),dvrtdct_db_node
        )
      ENDIF
     ENDIF
     IF (cnvtupper(dvrtdct_db_node_sn)=cnvtupper(dvrtdct_local_node_sn))
      SET dm_err->err_ind = 1
      SET dm_err->eproc = concat("Validating response file target db node: ",drrr_rf_data->
       tgt_db_node)
      SET dm_err->emsg = "Target db node (TGT_DB_NODE) cannot be local node."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET dvrtdct_db_node = drrr_rf_data->adm_db_node
     SET dvrtdct_db_node_sn = dvrtdct_db_node
     IF (validate(dm2_skip_db_shell_fqdn_check,0)=1)
      IF (findstring(".",dvrtdct_db_node,1,0) > 0)
       SET dvrtdct_db_node_sn = substring(1,(findstring(".",dvrtdct_db_node,1,0) - 1),dvrtdct_db_node
        )
      ENDIF
     ENDIF
     IF (cnvtupper(dvrtdct_db_node_sn)=cnvtupper(dvrtdct_local_node_sn))
      SET dm_err->err_ind = 1
      SET dm_err->eproc = concat("Validating response file admin database node (ADM_DB_NODE): ",
       drrr_rf_data->adm_db_node)
      SET dm_err->emsg = concat("Admin db node (ADM_DB_NODE) cannot be local node.")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_ping_nodes(dvrpn_in_src_ind,dvrpn_in_tgt_ind,dvrpn_in_adm_ind,dvrpn_in_local)
   IF (validate(dm2_bypass_rr_all_pings,0)=1)
    RETURN(1)
   ENDIF
   DECLARE dvrpn_num = i4 WITH protect, noconstant(1)
   IF (dvrpn_in_src_ind=1)
    IF (dvrpn_in_local="TARGET"
     AND (drrr_rf_data->mode != "ISOLATED"))
     IF ((((drrr_rf_data->src_db_deploy_config IN ("OCI", "ADB"))) OR ((drrr_rf_data->
     tgt_db_deploy_config IN ("OCI", "ADB")))) )
      SET dm_err->eproc = "Skips pinging all SOURCE nodes"
      CALL disp_msg("",dm_err->logfile,0)
     ELSE
      FOR (dvrpn_num = 1 TO drrr_misc_data->src_app_node_cnt)
        IF (dm2_ping(drrr_misc_data->src_app_nodes[dvrpn_num].node_name)=0)
         SET dm_err->err_ind = 1
         SET dm_err->eproc = "Validating connectivity to all source nodes"
         SET dm_err->emsg = concat("Unable to ping source node: ",drrr_misc_data->src_app_nodes[
          dvrpn_num].node_name)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
   ENDIF
   IF (dvrpn_in_tgt_ind=1)
    IF (dvrpn_in_local="SOURCE"
     AND (drrr_rf_data->mode != "ISOLATED"))
     IF ((((drrr_rf_data->src_db_deploy_config IN ("OCI", "ADB"))) OR ((drrr_rf_data->
     tgt_db_deploy_config IN ("OCI", "ADB")))) )
      SET dm_err->eproc = "Skips pinging all TARGET nodes"
      CALL disp_msg("",dm_err->logfile,0)
     ELSE
      FOR (dvrpn_num = 1 TO drrr_misc_data->tgt_app_node_cnt)
        IF (dm2_ping(drrr_misc_data->tgt_app_nodes[dvrpn_num].node_name)=0)
         SET dm_err->err_ind = 1
         SET dm_err->eproc = "Validating connectivity to all target nodes"
         SET dm_err->emsg = concat("Unable to ping target node: ",drrr_misc_data->tgt_app_nodes[
          dvrpn_num].node_name)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
    IF (dvrpn_in_local="TARGET"
     AND (drrr_rf_data->mode != "ISOLATED"))
     IF ((drrr_rf_data->tgt_db_deploy_config IN ("OCI", "ADB")))
      SET dm_err->eproc = "Skips pinging the TARGET database node."
      CALL disp_msg("",dm_err->logfile,0)
     ELSE
      IF (dm2_ping(drrr_rf_data->tgt_db_node)=0)
       SET dm_err->err_ind = 1
       SET dm_err->eproc = "Validating connectivity to target db node"
       SET dm_err->emsg = concat("Unable to ping target db node (TGT_DB_NODE): ",drrr_rf_data->
        tgt_db_node)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      IF (cnvtupper(drrr_rf_data->tgt_tns_host_name) != cnvtupper(drrr_rf_data->tgt_db_node)
       AND (drrr_rf_data->target_refresh="NO"))
       IF (dm2_ping(drrr_rf_data->tgt_tns_host_name)=0)
        SET dm_err->err_ind = 1
        SET dm_err->eproc = "Validating connectivity to target tns host name."
        SET dm_err->emsg = concat("Unable to ping target tns host name (TGT_TNS_HOST_NAME): ",
         drrr_rf_data->tgt_tns_host_name)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (dvrpn_in_adm_ind=1)
    IF (dm2_ping(drrr_rf_data->adm_db_node)=0)
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validating connectivity to admin db node"
     SET dm_err->emsg = concat("Unable to ping admin db node (ADM_DB_NODE): ",drrr_rf_data->
      adm_db_node)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_drop_db_links(null)
  IF ( NOT (cnvtupper(drrr_rf_data->tgt_drop_db_links) IN ("YES", "NO")))
   SET drrr_rf_data->tgt_drop_db_links = "YES"
  ELSE
   SET drrr_rf_data->tgt_drop_db_links = cnvtupper(drrr_rf_data->tgt_drop_db_links)
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_deploy_configs(null)
   IF (((cnvtupper(drrr_rf_data->src_db_deploy_config) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->src_db_deploy_config,3))=0)) )
    SET drrr_rf_data->src_db_deploy_config = "DM2NOTSET"
   ENDIF
   IF (cnvtupper(drrr_rf_data->src_db_deploy_config)="DM2NOTSET")
    SET drrr_rf_data->src_db_deploy_config = "OP"
   ELSEIF ( NOT (cnvtupper(drrr_rf_data->src_db_deploy_config) IN ("OP", "OCI", "ADB")))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file SRC_DB_DEPLOY_CONFIG: ",drrr_rf_data->
     src_db_deploy_config)
    SET dm_err->emsg = 'Response file SRC_DB_DEPLOY_CONFIG must be equal to "OP", "OCI" or "ADB".'
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    SET drrr_rf_data->src_db_deploy_config = cnvtupper(drrr_rf_data->src_db_deploy_config)
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_db_deploy_config) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_db_deploy_config,3))=0)) )
    SET drrr_rf_data->tgt_db_deploy_config = "DM2NOTSET"
   ENDIF
   IF (cnvtupper(drrr_rf_data->tgt_db_deploy_config)="DM2NOTSET")
    SET drrr_rf_data->tgt_db_deploy_config = "OP"
   ELSEIF ( NOT (cnvtupper(drrr_rf_data->tgt_db_deploy_config) IN ("OP", "OCI", "ADB")))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file TGT_DB_DEPLOY_CONFIG: ",drrr_rf_data->
     tgt_db_deploy_config)
    SET dm_err->emsg = 'Response file TGT_DB_DEPLOY_CONFIG must be equal to "OP", "OCI" or "ADB".'
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    SET drrr_rf_data->tgt_db_deploy_config = cnvtupper(drrr_rf_data->tgt_db_deploy_config)
   ENDIF
   IF (((cnvtupper(drrr_rf_data->adm_db_deploy_config) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->adm_db_deploy_config,3))=0)) )
    SET drrr_rf_data->adm_db_deploy_config = "DM2NOTSET"
   ENDIF
   IF (cnvtupper(drrr_rf_data->adm_db_deploy_config)="DM2NOTSET")
    SET drrr_rf_data->adm_db_deploy_config = "OP"
   ELSEIF ( NOT (cnvtupper(drrr_rf_data->adm_db_deploy_config) IN ("OP", "OCI", "ADB")))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating response file ADM_DB_DEPLOY_CONFIG: ",drrr_rf_data->
     adm_db_deploy_config)
    SET dm_err->emsg = 'Response file ADM_DB_DEPLOY_CONFIG must be equal to "OP", "OCI" or "ADB".'
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    SET drrr_rf_data->adm_db_deploy_config = cnvtupper(drrr_rf_data->adm_db_deploy_config)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_tns_mapping(null)
   DECLARE dvtonm_num = i2 WITH protect, noconstant(1)
   DECLARE dvtonm_str = vc WITH protect, noconstant("")
   DECLARE dvtonm_notfnd = vc WITH protect, constant("<not_found>")
   DECLARE dvtonm_tmp_str = vc WITH protect, noconstant("")
   DECLARE dvrttsm_tns_idx = i4 WITH protect, noconstant(0)
   DECLARE dvrttsm_db_cnct_str = vc WITH protect, noconstant("")
   DECLARE dvrttsm_world_idx = i2 WITH protect, noconstant(0)
   SET dvtonm_str = drrr_rf_data->tgt_tns_mapping
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("dvtonm_str = ",dvtonm_str))
   ENDIF
   IF ((drrr_rf_data->tgt_tns_mapping != "DM2NOTSET"))
    WHILE (dvtonm_str != dvtonm_notfnd)
      SET dvtonm_str = piece(drrr_rf_data->tgt_tns_mapping,",",dvtonm_num,dvtonm_notfnd)
      IF (dvtonm_num=1
       AND dvtonm_str=dvtonm_notfnd)
       SET dvtonm_str = drrr_rf_data->tgt_tns_mapping
      ENDIF
      IF (dvtonm_str != dvtonm_notfnd)
       IF (findstring('"',dvtonm_str,1,0) != findstring('"',dvtonm_str,1,1))
        SET dvtonm_tmp_str = cnvtlower(trim(replace(dvtonm_str,'"',"",0),3))
        IF (size(trim(dvtonm_tmp_str,3)) > 0)
         IF (findstring(":",dvtonm_tmp_str,1,0) > 1
          AND findstring(":",dvtonm_tmp_str,1,0) < size(trim(dvtonm_tmp_str,3)))
          SET dvrttsm_list_tns_entry = piece(dvtonm_tmp_str,":",1,dvtonm_notfnd)
          SET dvrttsm_list_svc_name = piece(dvtonm_tmp_str,":",2,dvtonm_notfnd)
          SET dvrttsm_tns_idx = 0
          IF (locateval(dvrttsm_tns_idx,1,drrr_misc_data->tgt_tns_map_cnt,dvrttsm_list_tns_entry,
           drrr_misc_data->tgt_tns_map[dvrttsm_tns_idx].tns_entry)=0)
           SET drrr_misc_data->tgt_tns_map_cnt = (drrr_misc_data->tgt_tns_map_cnt+ 1)
           SET stat = alterlist(drrr_misc_data->tgt_tns_map,drrr_misc_data->tgt_tns_map_cnt)
           SET drrr_misc_data->tgt_tns_map[drrr_misc_data->tgt_tns_map_cnt].tns_entry =
           dvrttsm_list_tns_entry
           SET drrr_misc_data->tgt_tns_map[drrr_misc_data->tgt_tns_map_cnt].service_name =
           dvrttsm_list_svc_name
           SET drrr_misc_data->tgt_tns_map[drrr_misc_data->tgt_tns_map_cnt].host = drrr_rf_data->
           tgt_tns_host_name
           SET drrr_misc_data->tgt_tns_map[drrr_misc_data->tgt_tns_map_cnt].port = drrr_rf_data->
           tgt_tns_port
           SET dvtonm_num = (dvtonm_num+ 1)
          ELSE
           SET dm_err->err_ind = 1
           SET dm_err->eproc = concat(
            "Validating response file Target TNS cnct str name and TNS service name list: ",
            drrr_rf_data->tgt_tns_mapping)
           SET dm_err->emsg = concat("Found duplicate TNS entry in the response file. Remove (",
            drrr_misc_data->tgt_tns_map[dvrttsm_tns_idx].tns_entry,") entry and try again.")
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           RETURN(0)
          ENDIF
         ELSE
          SET dm_err->err_ind = 1
          SET dm_err->eproc = concat("Validating response file target TNS cnct str name and ",
           "TNS service name mapping (tgt_tns_mapping): ",drrr_rf_data->tgt_tns_mapping)
          SET dm_err->emsg = concat("TNS entry and service name mapping in position ",trim(cnvtstring
            (dvtonm_num),3)," not properly set.")
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          RETURN(0)
         ENDIF
        ELSE
         SET dm_err->err_ind = 1
         SET dm_err->eproc = concat("Validating response file target TNS cnct str name and ",
          "TNS service name mapping (tgt_tns_mapping): ",drrr_rf_data->tgt_tns_mapping)
         SET dm_err->emsg = concat("TNS entry and service name mapping in position ",trim(cnvtstring(
            dvtonm_num),3)," not properly set.")
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
       ELSE
        SET dm_err->err_ind = 1
        SET dm_err->eproc = concat("Validating response file target TNS cnct str name and ",
         "TNS service name mapping (tgt_tns_mapping): ",drrr_rf_data->tgt_tns_mapping)
        SET dm_err->emsg = concat("TNS entry and service name mapping (",trim(dvtonm_str,3),
         ") not wrapped in double-quotes.")
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
    ENDWHILE
   ENDIF
   IF ((drrr_misc_data->tgt_tns_map_cnt=0)
    AND (drrr_rf_data->tgt_db_deploy_config IN ("OP", "OCI")))
    IF (drrr_load_default_tns_map(concat(drrr_rf_data->tgt_db_name,".world"))=0)
     RETURN(0)
    ENDIF
    IF (drrr_load_default_tns_map(concat(drrr_rf_data->tgt_db_name,"1.world"))=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET dvrttsm_tns_idx = 0
   IF ((drrr_misc_data->tgt_tns_map_cnt > 0))
    SET dvrttsm_tns_idx = locateval(dvrttsm_tns_idx,1,drrr_misc_data->tgt_tns_map_cnt,cnvtlower(
      drrr_rf_data->tgt_tns_cnct_str),cnvtlower(drrr_misc_data->tgt_tns_map[dvrttsm_tns_idx].
      tns_entry))
    IF ((drrr_rf_data->tgt_db_deploy_config="ADB")
     AND (drrr_rf_data->tgt_tns_svc_name="DM2NOTSET"))
     SET drrr_rf_data->tgt_tns_svc_name = drrr_misc_data->tgt_tns_map[1].service_name
    ENDIF
   ENDIF
   IF (dvrttsm_tns_idx=0)
    IF (drrr_load_default_tns_map(drrr_rf_data->tgt_tns_cnct_str)=0)
     RETURN(0)
    ENDIF
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo(concat("TNS entry (",drrr_misc_data->tgt_tns_map[dvrttsm_tns_idx].tns_entry,
       ") already exists."))
    ENDIF
   ENDIF
   SET dvrttsm_tns_idx = 0
   IF ((drrr_misc_data->tgt_tns_map_cnt > 0))
    SET dvrttsm_world_idx = 0
    SET dvrttsm_world_idx = findstring(".world",cnvtlower(drrr_misc_data->tgt_tns_map[1].tns_entry),1,
     0)
    IF ((dm_err->debug_flag > 0))
     CALL echo(build("dvrttsm_world_idx:",dvrttsm_world_idx))
    ENDIF
    SET dvrttsm_tns_idx = locateval(dvrttsm_tns_idx,1,drrr_misc_data->tgt_tns_map_cnt,evaluate(
      dvrttsm_world_idx,0,cnvtlower(drrr_rf_data->tgt_db_cnct_str),concat(cnvtlower(drrr_rf_data->
        tgt_db_cnct_str),".world")),cnvtlower(drrr_misc_data->tgt_tns_map[dvrttsm_tns_idx].tns_entry)
     )
   ENDIF
   IF (dvrttsm_tns_idx=0)
    IF (drrr_load_default_tns_map(drrr_rf_data->tgt_db_cnct_str)=0)
     RETURN(0)
    ENDIF
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo(concat("TNS entry (",drrr_misc_data->tgt_tns_map[dvrttsm_tns_idx].tns_entry,
       ") already exists."))
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(drrr_misc_data)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_load_default_tns_map(dldtm_tns_entry)
   SET dm_err->eproc = concat("Loading TNS entry ",dldtm_tns_entry," into target TNS map.")
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SET drrr_misc_data->tgt_tns_map_cnt = (drrr_misc_data->tgt_tns_map_cnt+ 1)
   SET stat = alterlist(drrr_misc_data->tgt_tns_map,drrr_misc_data->tgt_tns_map_cnt)
   SET drrr_misc_data->tgt_tns_map[drrr_misc_data->tgt_tns_map_cnt].tns_entry = dldtm_tns_entry
   SET drrr_misc_data->tgt_tns_map[drrr_misc_data->tgt_tns_map_cnt].service_name = drrr_rf_data->
   tgt_tns_svc_name
   SET drrr_misc_data->tgt_tns_map[drrr_misc_data->tgt_tns_map_cnt].host = drrr_rf_data->
   tgt_tns_host_name
   SET drrr_misc_data->tgt_tns_map[drrr_misc_data->tgt_tns_map_cnt].port = drrr_rf_data->tgt_tns_port
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_tgt_default_tspaces(null)
   IF (((cnvtupper(drrr_rf_data->tgt_default_misc_ts) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_default_misc_ts,3))=0)) )
    SET drrr_rf_data->tgt_default_misc_ts = "DM2NOTSET"
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_default_temp_ts) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_default_temp_ts,3))=0)) )
    SET drrr_rf_data->tgt_default_temp_ts = "DM2NOTSET"
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drrr_val_rf_cred_link_data(null)
   IF (((cnvtupper(drrr_rf_data->tgt_db_adm_db_link_name) IN ("*VALUE*REQUIRED*",
   "*VALUE*UNSPECIFIED*", "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_db_adm_db_link_name,3))=0)) )
    SET drrr_rf_data->tgt_db_adm_db_link_name = "ADMIN1"
   ENDIF
   IF (((cnvtupper(drrr_rf_data->adm_db_cred_nm) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->adm_db_cred_nm,3))=0)) )
    SET drrr_rf_data->adm_db_cred_nm = "DM2NOTSET"
   ENDIF
   IF (((cnvtupper(drrr_rf_data->adm_db_link_host) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->adm_db_link_host,3))=0)) )
    SET drrr_rf_data->adm_db_link_host = "DM2NOTSET"
   ENDIF
   IF (((cnvtupper(drrr_rf_data->adm_db_link_port) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->adm_db_link_port,3))=0)) )
    SET drrr_rf_data->adm_db_link_port = "DM2NOTSET"
   ENDIF
   IF (((cnvtupper(drrr_rf_data->adm_db_link_svc_nm) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->adm_db_link_svc_nm,3))=0)) )
    SET drrr_rf_data->adm_db_link_svc_nm = "DM2NOTSET"
   ENDIF
   IF (((cnvtupper(drrr_rf_data->adm_db_link_cnct_desc) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->adm_db_link_cnct_desc,3))=0)) )
    IF ((drrr_rf_data->tgt_db_deploy_config IN ("OP", "OCI")))
     IF ((drrr_rf_data->adm_db_link_host="DM2NOTSET")
      AND (drrr_rf_data->adm_db_link_port="DM2NOTSET")
      AND (drrr_rf_data->adm_db_link_svc_nm="DM2NOTSET"))
      SET drrr_rf_data->adm_db_link_cnct_desc = drrr_rf_data->adm_db_cnct_str
     ELSE
      SET drrr_rf_data->adm_db_link_cnct_desc = "DM2NOTSET"
     ENDIF
    ELSEIF ((drrr_rf_data->tgt_db_deploy_config="ADB"))
     SET drrr_rf_data->adm_db_link_cnct_desc = "DM2NOTSET"
    ENDIF
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_db_cred_nm) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_db_cred_nm,3))=0)) )
    SET drrr_rf_data->tgt_db_cred_nm = "DM2NOTSET"
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_db_link_host) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_db_link_host,3))=0)) )
    SET drrr_rf_data->tgt_db_link_host = "DM2NOTSET"
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_db_link_port) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_db_link_port,3))=0)) )
    SET drrr_rf_data->tgt_db_link_port = "DM2NOTSET"
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_db_link_svc_nm) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_db_link_svc_nm,3))=0)) )
    SET drrr_rf_data->tgt_db_link_svc_nm = "DM2NOTSET"
   ENDIF
   IF (((cnvtupper(drrr_rf_data->tgt_db_link_cnct_desc) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->tgt_db_link_cnct_desc,3))=0)) )
    IF ((drrr_rf_data->tgt_db_deploy_config IN ("OP", "OCI")))
     IF ((drrr_rf_data->tgt_db_link_host="DM2NOTSET")
      AND (drrr_rf_data->tgt_db_link_port="DM2NOTSET")
      AND (drrr_rf_data->tgt_db_link_svc_nm="DM2NOTSET"))
      SET drrr_rf_data->tgt_db_link_cnct_desc = drrr_rf_data->tgt_db_cnct_str
     ELSE
      SET drrr_rf_data->tgt_db_link_cnct_desc = "DM2NOTSET"
     ENDIF
    ELSEIF ((drrr_rf_data->tgt_db_deploy_config="ADB"))
     SET drrr_rf_data->tgt_db_link_cnct_desc = "DM2NOTSET"
    ENDIF
   ENDIF
   IF (((cnvtupper(drrr_rf_data->src_db_cred_nm) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->src_db_cred_nm,3))=0)) )
    SET drrr_rf_data->src_db_cred_nm = "DM2NOTSET"
   ENDIF
   IF (((cnvtupper(drrr_rf_data->src_db_link_host) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->src_db_link_host,3))=0)) )
    SET drrr_rf_data->src_db_link_host = "DM2NOTSET"
   ENDIF
   IF (((cnvtupper(drrr_rf_data->src_db_link_port) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->src_db_link_port,3))=0)) )
    SET drrr_rf_data->src_db_link_port = "DM2NOTSET"
   ENDIF
   IF (((cnvtupper(drrr_rf_data->src_db_link_svc_nm) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->src_db_link_svc_nm,3))=0)) )
    SET drrr_rf_data->src_db_link_svc_nm = "DM2NOTSET"
   ENDIF
   IF (((cnvtupper(drrr_rf_data->src_db_link_cnct_desc) IN ("*VALUE*REQUIRED*", "*VALUE*UNSPECIFIED*",
   "DM2NOTSET")) OR (size(trim(drrr_rf_data->src_db_link_cnct_desc,3))=0)) )
    SET drrr_rf_data->src_db_link_cnct_desc = "DM2NOTSET"
    IF ((drrr_rf_data->tgt_db_deploy_config IN ("OP", "OCI")))
     IF ((drrr_rf_data->src_db_link_host="DM2NOTSET")
      AND (drrr_rf_data->src_db_link_port="DM2NOTSET")
      AND (drrr_rf_data->src_db_link_svc_nm="DM2NOTSET"))
      SET drrr_rf_data->src_db_link_cnct_desc = drrr_rf_data->src_db_cnct_str
     ELSE
      SET drrr_rf_data->src_db_link_cnct_desc = "DM2NOTSET"
     ENDIF
    ELSEIF ((drrr_rf_data->tgt_db_deploy_config="ADB"))
     SET drrr_rf_data->src_db_link_cnct_desc = "DM2NOTSET"
    ENDIF
   ENDIF
   IF ((drrr_rf_data->tgt_db_deploy_config="ADB")
    AND (((drrr_rf_data->adm_db_cred_nm="DM2NOTSET")) OR ((((drrr_rf_data->adm_db_link_host=
   "DM2NOTSET")) OR ((((drrr_rf_data->adm_db_link_port="DM2NOTSET")) OR ((drrr_rf_data->
   adm_db_link_svc_nm="DM2NOTSET"))) )) )) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating response file admin database credential/link data."
    SET dm_err->emsg = trim(evaluate(drrr_rf_data->adm_db_cred_nm,"DM2NOTSET","ADM_DB_CRED_NM,"," "),
     3)
    SET dm_err->emsg = concat(dm_err->emsg,trim(evaluate(drrr_rf_data->adm_db_link_host,"DM2NOTSET",
       "ADM_DB_LINK_HOST,"," "),3))
    SET dm_err->emsg = concat(dm_err->emsg,trim(evaluate(drrr_rf_data->adm_db_link_port,"DM2NOTSET",
       "ADM_DB_LINK_PORT,"," "),3))
    SET dm_err->emsg = concat(dm_err->emsg,trim(evaluate(drrr_rf_data->adm_db_link_svc_nm,"DM2NOTSET",
       "ADM_DB_LINK_SVC_NM,"," "),3))
    SET dm_err->emsg = concat(dm_err->emsg,trim(evaluate(drrr_rf_data->adm_db_link_cnct_desc,
       "DM2NOTSET","ADM_DB_LINK_CNCT_DESC,"," "),3))
    SET dm_err->emsg = trim(replace(dm_err->emsg,",","",2),3)
    SET dm_err->emsg = concat("Response file admin database credential/link data must be set ",
     "when Target (",drrr_rf_data->tgt_db_deploy_config,
     ") is autonomous database (ADB).  Token(s) not set: ",dm_err->emsg,
     ".")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((drrr_rf_data->src_db_deploy_config="ADB")
    AND (((drrr_rf_data->tgt_db_cred_nm="DM2NOTSET")) OR ((((drrr_rf_data->tgt_db_link_host=
   "DM2NOTSET")) OR ((((drrr_rf_data->tgt_db_link_port="DM2NOTSET")) OR ((drrr_rf_data->
   tgt_db_link_svc_nm="DM2NOTSET"))) )) )) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating response file target database credential/link data."
    SET dm_err->emsg = trim(evaluate(drrr_rf_data->tgt_db_cred_nm,"DM2NOTSET","TGT_DB_CRED_NM,"," "),
     3)
    SET dm_err->emsg = concat(dm_err->emsg,trim(evaluate(drrr_rf_data->tgt_db_link_host,"DM2NOTSET",
       "TGT_DB_LINK_HOST,"," "),3))
    SET dm_err->emsg = concat(dm_err->emsg,trim(evaluate(drrr_rf_data->tgt_db_link_port,"DM2NOTSET",
       "TGT_DB_LINK_PORT,"," "),3))
    SET dm_err->emsg = concat(dm_err->emsg,trim(evaluate(drrr_rf_data->tgt_db_link_svc_nm,"DM2NOTSET",
       "TGT_DB_LINK_SVC_NM,"," "),3))
    SET dm_err->emsg = concat(dm_err->emsg,trim(evaluate(drrr_rf_data->tgt_db_link_cnct_desc,
       "DM2NOTSET","TGT_DB_LINK_CNCT_DESC,"," "),3))
    SET dm_err->emsg = trim(replace(dm_err->emsg,",","",2),3)
    SET dm_err->emsg = concat("Response file target database credential/link data must be set ",
     "when Source (",drrr_rf_data->src_db_deploy_config,
     ") is autonomous database (ADB).  Token(s) not set: ",dm_err->emsg,
     ".")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((((drrr_rf_data->src_db_deploy_config="ADB")) OR ((drrr_rf_data->tgt_db_deploy_config="ADB")
   ))
    AND (((drrr_rf_data->src_db_cred_nm="DM2NOTSET")) OR ((((drrr_rf_data->src_db_link_host=
   "DM2NOTSET")) OR ((((drrr_rf_data->src_db_link_port="DM2NOTSET")) OR ((drrr_rf_data->
   src_db_link_svc_nm="DM2NOTSET"))) )) )) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating response file source database credential/link data."
    SET dm_err->emsg = trim(evaluate(drrr_rf_data->src_db_cred_nm,"DM2NOTSET","SRC_DB_CRED_NM,"," "),
     3)
    SET dm_err->emsg = concat(dm_err->emsg,trim(evaluate(drrr_rf_data->src_db_link_host,"DM2NOTSET",
       "SRC_DB_LINK_HOST,"," "),3))
    SET dm_err->emsg = concat(dm_err->emsg,trim(evaluate(drrr_rf_data->src_db_link_port,"DM2NOTSET",
       "SRC_DB_LINK_PORT,"," "),3))
    SET dm_err->emsg = concat(dm_err->emsg,trim(evaluate(drrr_rf_data->src_db_link_svc_nm,"DM2NOTSET",
       "SRC_DB_LINK_SVC_NM,"," "),3))
    SET dm_err->emsg = concat(dm_err->emsg,trim(evaluate(drrr_rf_data->src_db_link_cnct_desc,
       "DM2NOTSET","SRC_DB_LINK_CNCT_DESC,"," "),3))
    SET dm_err->emsg = trim(replace(dm_err->emsg,",","",2),3)
    SET dm_err->emsg = concat("Response file source database credential/link data must be set ",
     "when Source (",drrr_rf_data->src_db_deploy_config,") or Target (",drrr_rf_data->
     tgt_db_deploy_config,
     ") is autonomous database (ADB).  Token(s) not set: ",dm_err->emsg,".")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
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
 DECLARE drer_email_setup(des_src_env=vc,des_tgt_env=vc) = i2
 DECLARE drer_fill_email_list(dfel_src_env=vc,dfel_tgt_env=vc) = i2
 DECLARE drer_compose_email(null) = i2
 DECLARE drer_send_email(dse_subject=vc,dse_file_name=vc,dse_level=i4) = i2
 DECLARE drer_send_test_emails(dste_level=i4) = i2
 DECLARE drer_add_body_text(dabt_in_text=vc,dabt_in_reset_ind=i2) = null
 DECLARE drer_reset_pre_err(null) = null
 DECLARE drer_get_client(null) = i2
 DECLARE drer_redhat_version(null) = i2
 IF ((validate(drer_email_list->level_cnt,- (99))=- (99))
  AND validate(drer_email_list->level_cnt,99)=99)
  FREE RECORD drer_email_list
  RECORD drer_email_list(
    1 max_email_level = i4
    1 email_cnt = i4
    1 change_ind = i2
    1 email[*]
      2 address = vc
      2 level = i4
    1 level_cnt = i4
    1 email_level[*]
      2 level = i4
      2 email_list = vc
  )
  SET drer_email_list->max_email_level = 2
 ENDIF
 IF ((validate(drer_email_det->email_level,- (99))=- (99))
  AND validate(drer_email_det->email_level,99)=99)
  FREE RECORD drer_email_det
  RECORD drer_email_det(
    1 subject = vc
    1 process = vc
    1 msgtype = vc
    1 status = vc
    1 status_dt_tm = f8
    1 client = vc
    1 src_env = vc
    1 src_node = vc
    1 tgt_env = vc
    1 tgt_node = vc
    1 step = vc
    1 email_level = i4
    1 file_name = vc
    1 component_name = vc
    1 eproc = vc
    1 err_ind = i2
    1 emsg = vc
    1 user_action = vc
    1 logfile = vc
    1 restart_ind = i2
    1 body_cnt = i4
    1 body[*]
      2 txt = vc
    1 attachment = vc
  )
  SET drer_email_det->subject = "DM2NOTSET"
  SET drer_email_det->process = "DM2NOTSET"
  SET drer_email_det->msgtype = "DM2NOTSET"
  SET drer_email_det->status = "DM2NOTSET"
  SET drer_email_det->client = "DM2NOTSET"
  SET drer_email_det->src_env = "DM2NOTSET"
  SET drer_email_det->src_node = "DM2NOTSET"
  SET drer_email_det->tgt_env = "DM2NOTSET"
  SET drer_email_det->tgt_node = "DM2NOTSET"
  SET drer_email_det->step = "DM2NOTSET"
  SET drer_email_det->file_name = "DM2NOTSET"
  SET drer_email_det->component_name = "DM2NOTSET"
  SET drer_email_det->eproc = "DM2NOTSET"
  SET drer_email_det->emsg = "DM2NOTSET"
  SET drer_email_det->user_action = "DM2NOTSET"
  SET drer_email_det->logfile = "DM2NOTSET"
  SET drer_email_det->attachment = "DM2NOTSET"
 ENDIF
 SUBROUTINE drer_email_setup(des_src_env,des_tgt_env)
   DECLARE des_iter = i4 WITH protect, noconstant(0)
   DECLARE des_index = i4 WITH protect, noconstant(0)
   DECLARE des_remove_location = i4 WITH protect, noconstant(0)
   DECLARE des_level = i4 WITH protect, noconstant(0)
   DECLARE des_working = i2 WITH protect, noconstant(0)
   DECLARE des_pre_max_level = i4 WITH protect, noconstant(0)
   DECLARE des_help_str = vc WITH protect, noconstant(" ")
   IF (drer_fill_email_list(des_src_env,des_tgt_env)=0)
    RETURN(0)
   ENDIF
   FOR (des_iter = 1 TO drer_email_list->max_email_level)
     IF ((des_iter=drer_email_list->max_email_level))
      SET des_help_str = concat(des_help_str,trim(cnvtstring(des_iter)))
     ELSE
      SET des_help_str = concat(des_help_str,trim(cnvtstring(des_iter)),",")
     ENDIF
   ENDFOR
   WHILE (true)
     SET width = 132
     IF ((dm_err->debug_flag != 722))
      SET message = window
     ENDIF
     CALL clear(1,1)
     CALL box(1,1,24,131)
     CALL text(2,2,"Setup Email Addresses")
     IF ((drer_email_list->email_cnt > 0))
      CALL text(4,4,"EMAIL ADDRESS")
      CALL text(4,80,"EMAIL LEVEL")
      FOR (des_index = 1 TO least(15,drer_email_list->email_cnt))
       CALL text((5+ des_index),4,concat(build(des_index),".  ",drer_email_list->email[des_index].
         address))
       CALL text((5+ des_index),80,trim(cnvtstring(drer_email_list->email[des_index].level)))
      ENDFOR
     ENDIF
     CALL clear(23,2,129)
     IF ((drer_email_list->email_cnt=0))
      CALL text(23,2,"(A)dd new email address, (S)ave, (Q)uit: ")
      CALL accept(23,80,"A;CU"," "
       WHERE curaccept IN ("A", "S", "Q"))
     ELSEIF ((drer_email_list->email_cnt < 15))
      IF ((drer_email_list->change_ind=0))
       CALL text(23,2,concat("(A)dd new email address, (R)emove existing email address, (S)ave,",
         " (T)est email addresses, (Q)uit: "))
       CALL accept(23,124,"A;CU"," "
        WHERE curaccept IN ("A", "R", "S", "T", "Q"))
      ELSE
       CALL text(23,2,concat("(A)dd new email address, (R)emove existing email address, (S)ave,",
         " (Q)uit: "))
       CALL accept(23,124,"A;CU"," "
        WHERE curaccept IN ("A", "R", "S", "Q"))
      ENDIF
     ELSE
      IF ((drer_email_list->change_ind=0))
       CALL text(23,2,"(R)emove existing email address, (S)ave, (T)est email addresses, (Q)uit: ")
       CALL accept(23,99,"A;CU"," "
        WHERE curaccept IN ("R", "S", "T", "Q"))
      ELSE
       CALL text(23,2,"(R)emove existing email address, (S)ave, (Q)uit: ")
       CALL accept(23,99,"A;CU"," "
        WHERE curaccept IN ("R", "S", "Q"))
      ENDIF
     ENDIF
     CASE (curaccept)
      OF "A":
       CALL clear(21,2,129)
       CALL text(21,2,"Email Address to Add:")
       CALL accept(21,24,"P(80);CHU","NONE"
        WHERE ((findstring("@",curaccept) > 0
         AND findstring(".",curaccept) > 0
         AND findstring("@",curaccept) < findstring(".",curaccept,1,1)) OR (curaccept="NONE")) )
       IF (curaccept != "NONE"
        AND locateval(des_index,1,drer_email_list->email_cnt,curaccept,drer_email_list->email[
        des_index].address)=0)
        SET drer_email_list->email_cnt = (drer_email_list->email_cnt+ 1)
        SET stat = alterlist(drer_email_list->email,drer_email_list->email_cnt)
        SET drer_email_list->email[drer_email_list->email_cnt].address = curaccept
        SET drer_email_list->change_ind = 1
       ENDIF
       CALL clear(22,2,129)
       CALL text(22,2,"Email level to Add:")
       SET help = fix(value(des_help_str))
       CALL accept(22,24,"99;F",0
        WHERE (curaccept < drer_email_list->max_email_level))
       SET drer_email_list->email[drer_email_list->email_cnt].level = curhelp
       CALL clear(21,2,129)
       CALL clear(22,2,129)
      OF "R":
       CALL clear(21,2,129)
       CALL text(21,2,"Email Address to Remove, by number:")
       CALL accept(21,38,"99;H",0
        WHERE curaccept BETWEEN 0 AND drer_email_list->email_cnt)
       SET des_remove_location = curaccept
       IF (des_remove_location > 0)
        FOR (des_iter = des_remove_location TO (drer_email_list->email_cnt - 1))
         SET drer_email_list->email[des_iter].address = drer_email_list->email[(des_iter+ 1)].address
         SET drer_email_list->email[des_iter].level = drer_email_list->email[(des_iter+ 1)].level
        ENDFOR
        SET stat = alterlist(drer_email_list->email,(drer_email_list->email_cnt - 1))
        SET drer_email_list->email_cnt = (drer_email_list->email_cnt - 1)
        SET drer_email_list->change_ind = 1
       ENDIF
       CALL clear(21,2,129)
      OF "S":
       IF ((dm_err->debug_flag=722))
        SET message = nowindow
       ENDIF
       IF ((drer_email_list->change_ind=1))
        SET dm_err->eproc = "Deleting existing email rows from dm2_admin_dm_info."
        DELETE  FROM dm2_admin_dm_info di
         WHERE di.info_domain=value(build("DM2_RR_EMAIL:",cnvtupper(drer_email_det->client),"_",
           cnvtupper(des_src_env),"_",
           cnvtupper(des_tgt_env)))
         WITH nocounter
        ;end delete
        IF (check_error(dm_err->eproc)=1)
         ROLLBACK
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
        IF ((drer_email_list->email_cnt > 0))
         SET dm_err->eproc = "Inserting new email rows into dm2_admin_dm_info."
         INSERT  FROM dm2_admin_dm_info di,
           (dummyt d  WITH seq = value(drer_email_list->email_cnt))
          SET di.info_domain = value(build("DM2_RR_EMAIL:",cnvtupper(drer_email_det->client),"_",
             cnvtupper(des_src_env),"_",
             cnvtupper(des_tgt_env))), di.info_name = drer_email_list->email[d.seq].address, di
           .info_number = drer_email_list->email[d.seq].level
          PLAN (d)
           JOIN (di)
          WITH nocounter
         ;end insert
         IF (check_error(dm_err->eproc)=1)
          ROLLBACK
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          RETURN(0)
         ENDIF
        ENDIF
        COMMIT
       ENDIF
       IF (drer_fill_email_list(des_src_env,des_tgt_env)=0)
        RETURN(0)
       ENDIF
       IF ((drer_email_list->email_cnt > 0))
        CALL clear(23,2,129)
        CALL text(23,2,"Changes have been saved.  Would you like to send a test email (Y/N)?")
        CALL accept(23,70,"A;CU"," "
         WHERE curaccept IN ("Y", "N"))
        CASE (curaccept)
         OF "Y":
          IF (drer_send_test_emails(1)=0)
           RETURN(0)
          ENDIF
        ENDCASE
       ENDIF
      OF "T":
       IF (drer_send_test_emails(1)=0)
        RETURN(0)
       ENDIF
       CALL clear(21,2,129)
       CALL text(21,2,"A test email has been sent.  Press <enter> to continue.")
       CALL accept(21,58,"A;CH"," ")
       CALL clear(21,2,129)
      OF "Q":
       RETURN(1)
     ENDCASE
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drer_fill_email_list(dfel_src_env,dfel_tgt_env)
   IF (validate(drrr_responsefile_in_use,0)=1)
    RETURN(1)
   ENDIF
   DECLARE dfel_table_name = vc WITH protect, noconstant("DM2NOTSET")
   IF (((dfel_src_env="DM2NOTSET") OR (dfel_tgt_env="DM2NOTSET")) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Evaluate input parameters for subroutine drer_fill_email_list."
    SET dm_err->emsg = "Input parameter(s) is not set."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (drer_get_client(null)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Verify that dm2_admin_dm_info public synonym exists"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dba_synonyms ds
    WHERE cnvtupper(ds.synonym_name)="DM2_ADMIN_DM_INFO"
     AND ds.owner="PUBLIC"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dfel_table_name = "DM2_ADMIN_DM_INFO"
   ELSE
    SET dm_err->eproc = "ADMIN CONNECTION"
    CALL disp_msg("",dm_err->logfile,0)
    SET dm2_install_schema->dbase_name = "ADMIN"
    SET dm2_install_schema->u_name = "CDBA"
    IF ((dm2_install_schema->cdba_p_word="DM2NOTSET"))
     EXECUTE dm2_connect_to_dbase "PC"
    ELSE
     SET dm2_install_schema->p_word = dm2_install_schema->cdba_p_word
     SET dm2_install_schema->connect_str = dm2_install_schema->cdba_connect_str
     EXECUTE dm2_connect_to_dbase "CO"
    ENDIF
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    SET dfel_table_name = "DM_INFO"
   ENDIF
   SET dm_err->eproc = concat("Querying for list of email addresses from ",dfel_table_name)
   SELECT INTO "nl:"
    FROM (parser(dfel_table_name) di)
    WHERE di.info_domain=value(build("DM2_RR_EMAIL:",cnvtupper(drer_email_det->client),"_",cnvtupper(
       dfel_src_env),"_",
      cnvtupper(dfel_tgt_env)))
    ORDER BY di.info_number, di.info_name
    HEAD REPORT
     level_cnt = 0, email_cnt = 0
    HEAD di.info_number
     level_cnt = (level_cnt+ 1), drer_email_list->level_cnt = level_cnt, stat = alterlist(
      drer_email_list->email_level,level_cnt),
     drer_email_list->email_level[level_cnt].level = di.info_number, drer_email_list->email_level[
     level_cnt].email_list = ""
    DETAIL
     email_cnt = (email_cnt+ 1), stat = alterlist(drer_email_list->email,email_cnt), drer_email_list
     ->email[email_cnt].address = di.info_name,
     drer_email_list->email[email_cnt].level = di.info_number
     IF ((drer_email_list->email_level[level_cnt].email_list=""))
      drer_email_list->email_level[level_cnt].email_list = di.info_name
     ELSE
      drer_email_list->email_level[level_cnt].email_list = concat(drer_email_list->email_level[
       level_cnt].email_list,",",di.info_name)
     ENDIF
     drer_email_list->email_cnt = email_cnt
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag=722))
    SET message = nowindow
    CALL echorecord(drer_email_list)
    SET message = window
   ENDIF
   IF (dfel_table_name="DM_INFO")
    IF ((((dm2_install_schema->target_dbase_name="DM2NOTSET")) OR ((dm2_install_schema->v500_p_word=
    "DM2NOTSET"))) )
     SET dm2_install_schema->dbase_name = '"TARGET"'
     SET dm2_install_schema->u_name = "V500"
     EXECUTE dm2_connect_to_dbase "PC"
    ELSE
     SET dm2_install_schema->dbase_name = dm2_install_schema->target_dbase_name
     SET dm2_install_schema->u_name = "V500"
     SET dm2_install_schema->p_word = dm2_install_schema->v500_p_word
     SET dm2_install_schema->connect_str = dm2_install_schema->v500_connect_str
     EXECUTE dm2_connect_to_dbase "CO"
    ENDIF
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drer_compose_email(null)
   DECLARE def_line = vc WITH protect, noconstant(" ")
   DECLARE def_cnt = i4 WITH protect, noconstant(0)
   IF ((drer_email_det->status="EXECUTING"))
    SET drer_email_det->msgtype = "PROGRESS"
    IF ((drer_email_det->restart_ind=0))
     SET def_line = concat(drer_email_det->step," started at ",format(drer_email_det->status_dt_tm,
       ";;q"))
    ELSE
     SET def_line = concat(drer_email_det->step," restarted at ",format(drer_email_det->status_dt_tm,
       ";;q"))
    ENDIF
    CALL drer_add_body_text(def_line,1)
    SET def_line = concat("Log file name is ccluserdir: ",drer_email_det->logfile)
    CALL drer_add_body_text(def_line,0)
   ELSEIF ((drer_email_det->status="COMPLETE"))
    SET drer_email_det->msgtype = "PROGRESS"
    SET def_line = concat(drer_email_det->step," completed at ",format(drer_email_det->status_dt_tm,
      ";;q"))
    CALL drer_add_body_text(def_line,1)
    SET def_line = concat("Log file name is ccluserdir: ",drer_email_det->logfile)
    CALL drer_add_body_text(def_line,0)
   ELSEIF ((drer_email_det->status="FAILED"))
    SET drer_email_det->msgtype = "ACTIONREQ"
    SET def_line = concat("Component Name :",drer_email_det->component_name)
    CALL drer_add_body_text(def_line,1)
    SET def_line = concat("Process Description :",drer_email_det->eproc)
    CALL drer_add_body_text(def_line,0)
    SET def_line = concat("Error Message :",drer_email_det->emsg)
    CALL drer_add_body_text(def_line,0)
    IF ((drer_email_det->user_action > "")
     AND (drer_email_det->user_action != "DM2NOTSET")
     AND (drer_email_det->user_action != "NONE"))
     SET def_line = concat("User Action :",drer_email_det->user_action)
     CALL drer_add_body_text(def_line,0)
    ENDIF
    IF (findstring("/",drer_email_det->logfile)=0)
     SET def_line = concat("Log file name is ccluserdir: ",drer_email_det->logfile)
    ELSE
     SET def_line = concat("Log file name is : ",drer_email_det->logfile)
    ENDIF
    CALL drer_add_body_text(def_line,0)
   ENDIF
   SET drer_email_det->subject = concat("PROCESS: ",evaluate(drer_email_det->process,"DM2NOTSET",
     "N/A",trim(drer_email_det->process)),", MSGTYPE: ",evaluate(drer_email_det->msgtype,"DM2NOTSET",
     "N/A",trim(drer_email_det->msgtype)),", STATUS: ",
    evaluate(drer_email_det->status,"DM2NOTSET","N/A",trim(drer_email_det->status)),", CLIENT: ",
    evaluate(drer_email_det->client,"DM2NOTSET","N/A",trim(drer_email_det->client)))
   IF (get_unique_file("dm2_rr_email",".dat")=0)
    RETURN(0)
   ENDIF
   SET drer_email_det->file_name = dm_err->unique_fname
   SET dm_err->eproc = concat("Generate file ",drer_email_det->file_name)
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO value(drer_email_det->file_name)
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     def_line = concat("SRC_ENV/SRC_NODE:",evaluate(drer_email_det->src_env,"DM2NOTSET","N/A",trim(
        drer_email_det->src_env)),"/",evaluate(drer_email_det->src_node,"DM2NOTSET","N/A",trim(
        drer_email_det->src_node)),", TGT_ENV/TGT_NODE:",
      evaluate(drer_email_det->tgt_env,"DM2NOTSET","N/A",trim(drer_email_det->tgt_env)),"/",evaluate(
       drer_email_det->tgt_node,"DM2NOTSET","N/A",trim(drer_email_det->tgt_node)),", STEP: ",evaluate
      (drer_email_det->step,"DM2NOTSET","N/A",trim(drer_email_det->step)),
      ", EMAIL DT/TM: ",format(cnvtdatetime(curdate,curtime3),";;q")),
     CALL print(def_line), row + 1,
     row + 2
     FOR (def_cnt = 1 TO drer_email_det->body_cnt)
      CALL print(drer_email_det->body[def_cnt].txt),row + 2
     ENDFOR
    WITH nocounter, maxcol = 2000, format = variable,
     formfeed = none, maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drer_send_email(dse_subject,dse_file_name,dse_level)
   DECLARE dse_iter = i4 WITH protect, noconstant(0)
   DECLARE dse_idx = i4 WITH protect, noconstant(0)
   DECLARE dse_file = vc WITH protect, noconstant("")
   DECLARE dse_lnx_version = f8 WITH protect, noconstant(0)
   IF (((trim(dse_subject)="DM2NOTSET") OR (trim(dse_file_name)="DM2NOTSET")) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Verifying input parameters."
    SET dm_err->emsg = "Input parameters <Subject, File Name> can not be blank."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dse_level > drer_email_list->max_email_level))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Verifying input parameters."
    SET dm_err->emsg = "Input parameter email level is not valid."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   WHILE (dse_idx=0)
    SET dse_idx = locateval(dse_idx,1,drer_email_list->level_cnt,dse_level,drer_email_list->
     email_level[dse_idx].level)
    IF (dse_idx=0
     AND (dse_level < drer_email_list->max_email_level))
     SET dse_level = (dse_level+ 1)
    ELSEIF (dse_idx=0
     AND (dse_level=drer_email_list->max_email_level))
     RETURN(1)
    ENDIF
   ENDWHILE
   IF ((dm_err->debug_flag=722))
    SET message = nowindow
    CALL echo(build("dse_idx = ",dse_idx))
   ENDIF
   IF (((dse_idx <= 0) OR ((dse_idx > drer_email_list->level_cnt))) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Verifying input parameters."
    SET dm_err->emsg = "Input parameter dse_level is invalid"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF ((drer_email_list->email_level[dse_idx].email_list=""))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Verifying input parameters."
    SET dm_err->emsg = "Email list can not be blank"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   FOR (dse_iter = dse_idx TO drer_email_list->level_cnt)
    IF ((drer_email_det->attachment != "DM2NOTSET")
     AND (dm2_sys_misc->cur_os IN ("AIX", "LNX", "HPX")))
     SET dse_file = replace(drer_email_det->attachment,".","w.",2)
     IF (dm2_push_dcl(concat(^sed 's/$'"/`echo \\^,'\\\r`/"'," ",drer_email_det->attachment," > ",
       dse_file))=0)
      SET dm_err->err_ind = 0
      SET dse_file = drer_email_det->attachment
     ENDIF
     SET drer_email_det->attachment = "DM2NOTSET"
    ENDIF
    IF ((dm2_sys_misc->cur_os="AXP"))
     IF (dm2_push_dcl(concat('MAIL/SUBJECT="',build(dse_subject),'" ',build(dse_file_name),' "',
       build(drer_email_list->email_level[dse_iter].email_list),'"'))=0)
      RETURN(0)
     ENDIF
    ELSEIF ((dm2_sys_misc->cur_os="LNX"))
     IF (dse_file != "")
      SET dse_lnx_version = drer_redhat_version(null)
      IF (dse_lnx_version >= 6)
       IF (dm2_push_dcl(concat("cat ",dse_file_name,' | mail -s "',dse_subject,'" -a ',
         dse_file,' "',drer_email_list->email_level[dse_iter].email_list,'"'))=0)
        RETURN(0)
       ENDIF
      ELSE
       IF (dm2_push_dcl(concat("(cat ",dse_file_name,"; uuencode ",dse_file," `basename ",
         dse_file,'`) | mail -s "',dse_subject,'" "',drer_email_list->email_level[dse_iter].
         email_list,
         '"'))=0)
        RETURN(0)
       ENDIF
      ENDIF
      SET drer_email_det->attachment = "DM2NOTSET"
     ELSEIF (dm2_push_dcl(concat('mail -s "',dse_subject,'" "',drer_email_list->email_level[dse_iter]
       .email_list,'" < ',
       dse_file_name))=0)
      RETURN(0)
     ENDIF
    ELSEIF ((dm2_sys_misc->cur_os="AIX"))
     IF (dse_file != "")
      IF (dm2_push_dcl(concat("(cat ",dse_file_name,"; uuencode ",dse_file," `basename ",
        dse_file,'`) | mail -s "',dse_subject,'" "',drer_email_list->email_level[dse_iter].email_list,
        '"'))=0)
       RETURN(0)
      ENDIF
      SET drer_email_det->attachment = "DM2NOTSET"
     ELSEIF (dm2_push_dcl(concat('mail -s "',dse_subject,'" "',drer_email_list->email_level[dse_iter]
       .email_list,'" < ',
       dse_file_name))=0)
      RETURN(0)
     ENDIF
    ELSEIF ((dm2_sys_misc->cur_os="HPX"))
     IF (dse_file != "")
      IF (dm2_push_dcl(concat("(cat ",dse_file_name,"; uuencode ",dse_file," `basename ",
        dse_file,'`) | mailx -m -s "',dse_subject,'" "',drer_email_list->email_level[dse_iter].
        email_list,
        '"'))=0)
       RETURN(0)
      ENDIF
      SET drer_email_det->attachment = "DM2NOTSET"
     ELSEIF (dm2_push_dcl(concat('mailx -s "',dse_subject,'" "',drer_email_list->email_level[dse_iter
       ].email_list,'" < ',
       dse_file_name))=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drer_send_test_emails(dste_level)
   DECLARE dste_test_file_name = vc WITH protect, noconstant("")
   DECLARE dste_iter = i4 WITH protect, noconstant(0)
   DECLARE dste_email_list = vc WITH protect, noconstant("")
   SET dste_test_file_name = build(logical("CCLUSERDIR"),evaluate(dm2_sys_misc->cur_os,"AXP",
     "dm2_email_test.txt","/dm2_email_test.txt"))
   SET dm_err->eproc = "Attempting to create a test file to be emailed."
   SELECT INTO value(dste_test_file_name)
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     row + 1, "This is a test email"
    WITH nocounter, maxcol = 100, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(drer_send_email("Test email",dste_test_file_name,dste_level))
 END ;Subroutine
 SUBROUTINE drer_add_body_text(dabt_in_text,dabt_in_reset_ind)
   IF (dabt_in_reset_ind=1)
    SET drer_email_det->body_cnt = 1
    SET stat = alterlist(drer_email_det->body,1)
    SET drer_email_det->body[drer_email_det->body_cnt].txt = dabt_in_text
   ELSE
    SET drer_email_det->body_cnt = (drer_email_det->body_cnt+ 1)
    SET stat = alterlist(drer_email_det->body,drer_email_det->body_cnt)
    SET drer_email_det->body[drer_email_det->body_cnt].txt = dabt_in_text
   ENDIF
 END ;Subroutine
 SUBROUTINE drer_reset_pre_err(null)
   SET dm_err->err_ind = drer_email_det->err_ind
   SET dm_err->emsg = drer_email_det->emsg
   SET dm_err->eproc = drer_email_det->eproc
   SET dm_err->user_action = drer_email_det->user_action
 END ;Subroutine
 SUBROUTINE drer_get_client(null)
   SET dm_err->eproc = "Get Client Mnemonic."
   CALL disp_msg("",dm_err->logfile,0)
   SET drer_email_det->client = cnvtupper(logical("client_mnemonic"))
   IF ((((drer_email_det->client="DM2NOTSET")) OR ((drer_email_det->client=""))) )
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="DATA MANAGEMENT"
      AND d.info_name="CLIENT MNEMONIC"
     DETAIL
      drer_email_det->client = trim(cnvtupper(d.info_char))
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drer_redhat_version(null)
   DECLARE drv_lnx_ver_temp = vc WITH protect, constant(build2("dm2_os_ver_",cnvtdatetime(curdate,
      curtime3),".dat"))
   DECLARE drv_cmd_lnx_ver = vc WITH protect, constant(build2("cat /etc/redhat-release >> ",trim(
      drv_lnx_ver_temp,3)))
   DECLARE drv_cmd_length = i4 WITH protect, noconstant(textlen(drv_cmd_lnx_ver))
   DECLARE drv_status = i4 WITH protect, noconstant(0)
   DECLARE drv_version = vc WITH protect, noconstant("")
   DECLARE drv_dcl_output = vc WITH protect, noconstant("")
   DECLARE drv_return_value = f8 WITH protect, noconstant(0)
   DECLARE drv_continue = i2 WITH protect, noconstant(true)
   DECLARE drv_iwknt = i4 WITH protect, noconstant(1)
   SET stat = remove(drv_lnx_ver_temp)
   CALL dcl(drv_cmd_lnx_ver,drv_cmd_length,drv_status)
   FREE DEFINE rtl
   DEFINE rtl drv_lnx_ver_temp
   SELECT INTO "nl:"
    FROM rtlt r
    HEAD REPORT
     drv_dcl_output = cnvtupper(trim(r.line,3))
    WITH nocounter
   ;end select
   SET stat = remove(drv_lnx_ver_temp)
   SET drv_version = substring((findstring("RELEASE",drv_dcl_output)+ 8),1,drv_dcl_output)
   IF (isnumeric(drv_version)=1)
    WHILE (drv_continue
     AND drv_iwknt < 4)
     SET drv_iwknt = (drv_iwknt+ 1)
     IF (isnumeric(substring(((findstring("RELEASE",drv_dcl_output)+ 8)+ drv_iwknt),1,drv_dcl_output)
      )=1)
      IF (drv_iwknt=2)
       SET drv_version = concat(trim(drv_version,3),".",substring(((findstring("RELEASE",
          drv_dcl_output)+ 8)+ drv_iwknt),1,drv_dcl_output))
      ELSE
       SET drv_version = concat(trim(drv_version,3),substring(((findstring("RELEASE",drv_dcl_output)
         + 8)+ drv_iwknt),1,drv_dcl_output))
      ENDIF
     ELSE
      SET drv_continue = false
     ENDIF
    ENDWHILE
    IF (isnumeric(drv_version) > 0)
     SET drv_return_value = cnvtreal(drv_version)
    ENDIF
   ENDIF
   CALL echo(build("RHEL Version = ",drv_return_value))
   RETURN(drv_return_value)
 END ;Subroutine
 DECLARE dapl_process_add_detail_text(dpadt_detail_type=vc,dpadt_detail_text=vc) = null
 DECLARE dapl_process_add_detail_date(dpadd_detail_type=vc,dpadd_detail_date=dq8) = null
 DECLARE dapl_process_add_detail_number(dpadn_detail_type=vc,dpadn_detail_number=f8) = null
 DECLARE dapl_process_event_add_detail_text(dpeadt_detail_type=vc,dpeadt_detail_text=vc) = null
 DECLARE dapl_process_event_add_detail_date(dpeadd_detail_type=vc,dpeadd_detail_date=dq8) = null
 DECLARE dapl_process_event_add_detail_number(dpeadn_detail_type=vc,dpeadn_detail_number=f8) = null
 DECLARE dapl_manage_process(dmp_process_name=vc,dmp_process_type=vc,dmp_action_type=vc,
  dmp_process_id=f8) = i2
 DECLARE dapl_manage_process_dtl(dmpd_process_id=f8) = i2
 DECLARE dapl_manage_process_event(dmpe_process_id=f8,dmpe_process_event_id=f8) = i2
 DECLARE dapl_manage_process_event_dtl(dmped_process_event_id=f8) = i2
 DECLARE dapl_check_process_event(dcpe_process_id=f8,dcpe_event_name=vc,dcpe_status=vc,dcpe_curqual=
  i4(ref)) = i2
 IF ((validate(dapl_process_rs->cnt,- (1))=- (1))
  AND (validate(dapl_process_rs->cnt,- (2))=- (2)))
  FREE RECORD dapl_process_rs
  RECORD dapl_process_rs(
    1 process_id = f8
    1 detail_cnt = i4
    1 details[*]
      2 dtype = vc
      2 dnumber = f8
      2 dtext = vc
      2 ddate = dq8
  )
  SET dapl_process_rs->process_id = 0.0
  SET dapl_process_rs->detail_cnt = 0
  SET stat = alterlist(dapl_process_rs->details,0)
 ENDIF
 IF ((validate(dapl_event_rs->cnt,- (1))=- (1))
  AND (validate(dapl_event_rs->cnt,- (2))=- (2)))
  FREE RECORD dapl_event_rs
  RECORD dapl_event_rs(
    1 event_id = f8
    1 event_name = vc
    1 status = vc
    1 message = vc
    1 begin_dt_tm = dq8
    1 end_dt_tm = dq8
    1 detail_cnt = i4
    1 details[*]
      2 dtype = vc
      2 dnumber = f8
      2 dtext = vc
      2 ddate = dq8
  )
  SET dapl_event_rs->event_id = 0.0
  SET dapl_event_rs->event_name = "DM2NOTSET"
  SET dapl_event_rs->status = "DM2NOTSET"
  SET dapl_event_rs->message = "DM2NOTSET"
  SET dapl_event_rs->begin_dt_tm = cnvtdatetime("01-JAN-1900")
  SET dapl_event_rs->end_dt_tm = cnvtdatetime("01-JAN-1900")
  SET dapl_event_rs->detail_cnt = 0
  SET stat = alterlist(dapl_event_rs->details,0)
 ENDIF
 DECLARE dapl_username = vc WITH protect, constant(curuser)
 DECLARE dapl_no_id = f8 WITH protect, constant(0.0)
 DECLARE dapl_replicate_refresh = vc WITH protect, constant("REPLICATE_REFRESH")
 DECLARE dapl_execution = vc WITH protect, constant("EXECUTION")
 DECLARE dapl_failed = vc WITH protect, constant("FAILED")
 DECLARE dapl_complete = vc WITH protect, constant("COMPLETE")
 DECLARE dapl_executing = vc WITH protect, constant("EXECUTING")
 SUBROUTINE dapl_process_add_detail_text(dpadt_detail_type,dpadt_detail_text)
   SET dapl_process_rs->detail_cnt = (dapl_process_rs->detail_cnt+ 1)
   SET stat = alterlist(dapl_process_rs->details,dapl_process_rs->detail_cnt)
   SET dapl_process_rs->details[dapl_process_rs->detail_cnt].dtype = dpadt_detail_type
   SET dapl_process_rs->details[dapl_process_rs->detail_cnt].dtext = dpadt_detail_text
 END ;Subroutine
 SUBROUTINE dapl_process_add_detail_date(dpadd_detail_type,dpadd_detail_date)
   SET dapl_process_rs->detail_cnt = (dapl_process_rs->detail_cnt+ 1)
   SET stat = alterlist(dapl_process_rs->details,dapl_process_rs->detail_cnt)
   SET dapl_process_rs->details[dapl_process_rs->detail_cnt].dtype = dpadd_detail_type
   SET dapl_process_rs->details[dapl_process_rs->detail_cnt].ddate = dpadd_detail_date
 END ;Subroutine
 SUBROUTINE dapl_process_add_detail_number(dpadn_detail_type,dpadn_detail_number)
   SET dapl_process_rs->detail_cnt = (dapl_process_rs->detail_cnt+ 1)
   SET stat = alterlist(dapl_process_rs->details,dapl_process_rs->detail_cnt)
   SET dapl_process_rs->details[dapl_process_rs->detail_cnt].dtype = dpadn_detail_type
   SET dapl_process_rs->details[dapl_process_rs->detail_cnt].dnumber = dpadn_detail_number
 END ;Subroutine
 SUBROUTINE dapl_process_event_add_detail_text(dpeadt_detail_type,dpeadt_detail_text)
   SET dapl_event_rs->detail_cnt = (dapl_event_rs->detail_cnt+ 1)
   SET stat = alterlist(dapl_event_rs->details,dapl_event_rs->detail_cnt)
   SET dapl_event_rs->details[dapl_event_rs->detail_cnt].dtype = dpeadt_detail_type
   SET dapl_event_rs->details[dapl_event_rs->detail_cnt].dtext = dpeadt_detail_text
 END ;Subroutine
 SUBROUTINE dapl_process_event_add_detail_date(dpeadd_detail_type,dpeadd_detail_date)
   SET dapl_event_rs->detail_cnt = (dapl_event_rs->detail_cnt+ 1)
   SET stat = alterlist(dapl_event_rs->details,dapl_event_rs->detail_cnt)
   SET dapl_event_rs->details[dapl_event_rs->detail_cnt].dtype = dpeadd_detail_type
   SET dapl_event_rs->details[dapl_event_rs->detail_cnt].ddate = dpeadd_detail_date
 END ;Subroutine
 SUBROUTINE dapl_process_event_add_detail_number(dpeadn_detail_type,dpeadn_detail_number)
   SET dapl_event_rs->detail_cnt = (dapl_event_rs->detail_cnt+ 1)
   SET stat = alterlist(dapl_event_rs->details,dapl_event_rs->detail_cnt)
   SET dapl_event_rs->details[dapl_event_rs->detail_cnt].dtype = dpeadn_detail_type
   SET dapl_event_rs->details[dapl_event_rs->detail_cnt].dnumber = dpeadn_detail_number
 END ;Subroutine
 SUBROUTINE dapl_manage_process(dmp_process_name,dmp_process_type,dmp_action_type,dmp_process_id)
   IF (validate(dm2_skip_admin_logging,- (1))=1)
    SET dm_err->eproc = "Bypassing call to Admin logging process."
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   IF (dmp_process_id=0.0)
    SET dm_err->eproc = "Validating the input parameter values."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    IF (((dmp_process_name="DM2NOTSET") OR (size(trim(dmp_process_name,3))=0)) )
     SET dm_err->eproc = "Check for the input value passed to dapl_manage_process."
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("Process_name must be set to a specific value.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (((dmp_process_type="DM2NOTSET") OR (size(trim(dmp_process_type,3))=0)) )
     SET dm_err->eproc = "Check for the input value passed to dapl_manage_process."
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("Process_type must be set to a specific value.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (((dmp_action_type="DM2NOTSET") OR (size(trim(dmp_action_type,3))=0)) )
     SET dm_err->eproc = "Check for the input value passed to dapl_manage_process."
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("Action_type must be set to a specific value.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Querying for process_id from dma_process."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dma_process dp
     WHERE dp.process_name=dmp_process_name
      AND dp.process_type=dmp_process_type
      AND dp.action_type=dmp_action_type
     DETAIL
      dapl_process_rs->process_id = dp.dma_process_id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) > 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dapl_process_rs->process_id=0.0))
     SET dm_err->eproc = "Getting next sequence for dma_process from dm_seq."
     SELECT INTO "nl:"
      id = seq(dm_seq,nextval)
      FROM dual
      DETAIL
       dapl_process_rs->process_id = id
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc) > 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = "Inserting new process into dma_process."
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     INSERT  FROM dma_process dp
      SET dp.dma_process_id = dapl_process_rs->process_id, dp.process_name = dmp_process_name, dp
       .process_type = dmp_process_type,
       dp.action_type = dmp_action_type, dp.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
    ENDIF
   ENDIF
   IF ((dapl_process_rs->detail_cnt > 0))
    IF (dapl_manage_process_dtl(dapl_process_rs->process_id)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dapl_process_rs)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dapl_manage_process_dtl(dmpd_process_id)
   DECLARE dmpd_process_dtl_id = f8 WITH protect, noconstant(0)
   DECLARE dmpd_cnt = i4 WITH protect, noconstant(0)
   IF (validate(dm2_skip_admin_logging,- (1))=1)
    SET dm_err->eproc = "Bypassing call to Admin logging process."
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   IF ((dapl_process_rs->detail_cnt > 0))
    FOR (dmpd_cnt = 1 TO size(dapl_process_rs->details,5))
      SET dm_err->eproc = "Getting next sequence for process_dtl_id from dm_seq."
      SELECT INTO "nl:"
       id = seq(dm_seq,nextval)
       FROM dual
       DETAIL
        dmpd_process_dtl_id = id
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc) > 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      SET dm_err->eproc = "Inserting new process detail row into dma_process_dtl."
      IF ((dm_err->debug_flag > 0))
       CALL disp_msg(" ",dm_err->logfile,0)
      ENDIF
      INSERT  FROM dma_process_dtl dpd
       SET dpd.dma_process_dtl_id = dmpd_process_dtl_id, dpd.dma_process_id = dmpd_process_id, dpd
        .detail_type = dapl_process_rs->details[dmpd_cnt].dtype,
        dpd.detail_text = substring(1,2000,dapl_process_rs->details[dmpd_cnt].dtext), dpd
        .detail_number = dapl_process_rs->details[dmpd_cnt].dnumber, dpd.detail_dt_tm = cnvtdatetime(
         dapl_process_rs->details[dmpd_cnt].ddate),
        dpd.updt_dt_tm = cnvtdatetime(curdate,curtime3)
       WITH nocounter
      ;end insert
      IF (check_error(dm_err->eproc)=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ELSE
       COMMIT
      ENDIF
    ENDFOR
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dapl_process_rs)
   ENDIF
   SET dapl_process_rs->detail_cnt = 0
   SET stat = alterlist(dapl_process_rs->details,0)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dapl_manage_process_event(dmpe_process_id,dmpe_process_event_id)
   IF (validate(dm2_skip_admin_logging,- (1))=1)
    SET dm_err->eproc = "Bypassing call to Admin logging process."
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   IF (dmpe_process_id=0.0)
    SET dm_err->eproc = "Check for the input value passed to dapl_manage_process_event."
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Process_ID value is set to 0.0.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dmpe_process_event_id=0.0
    AND (((dapl_event_rs->event_name="DM2NOTSET")) OR (size(trim(dapl_event_rs->event_name,3))=0)) )
    SET dm_err->eproc = "Check for the input values passed to dapl_manage_process_event."
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Process_ID value is set to 0.0 and Event_name to NULL.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (dmpe_process_event_id=0.0)
    SET dm_err->eproc = "Getting next sequence for process_event_id from dm_seq."
    SELECT INTO "nl:"
     id = seq(dm_seq,nextval)
     FROM dual
     DETAIL
      dapl_event_rs->event_id = id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) > 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Inserting logging row into dma_process_event."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    INSERT  FROM dma_process_event dpe
     SET dpe.dma_process_event_id = dapl_event_rs->event_id, dpe.dma_process_id = dmpe_process_id,
      dpe.event_name = dapl_event_rs->event_name,
      dpe.event_status = evaluate(dapl_event_rs->status,"DM2NOTSET","",dapl_event_rs->status), dpe
      .message = evaluate(dapl_event_rs->message,"DM2NOTSET","",substring(1,2000,dapl_event_rs->
        message)), dpe.username = dapl_username,
      dpe.begin_dt_tm = cnvtdatetime(dapl_event_rs->begin_dt_tm), dpe.end_dt_tm = cnvtdatetime(
       dapl_event_rs->begin_dt_tm), dpe.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ELSEIF (dmpe_process_event_id > 0.0)
    SET dm_err->eproc = "Update logging row into dma_process_event."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    UPDATE  FROM dma_process_event dpe
     SET dpe.event_status = evaluate(dapl_event_rs->status,"DM2NOTSET",dpe.event_status,dapl_event_rs
       ->status), dpe.message = evaluate(dapl_event_rs->message,"DM2NOTSET",dpe.message,substring(1,
        2000,dapl_event_rs->message)), dpe.username = dapl_username,
      dpe.end_dt_tm = cnvtdatetime(dapl_event_rs->end_dt_tm), dpe.updt_dt_tm = cnvtdatetime(curdate,
       curtime3)
     WHERE dpe.dma_process_event_id=dmpe_process_event_id
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
    SET dapl_event_rs->event_name = "DM2NOTSET"
    SET dapl_event_rs->status = "DM2NOTSET"
    SET dapl_event_rs->message = "DM2NOTSET"
    SET dapl_event_rs->begin_dt_tm = cnvtdatetime("01-JAN-1900")
    SET dapl_event_rs->end_dt_tm = cnvtdatetime("01-JAN-1900")
    SET dapl_event_rs->event_id = dmpe_process_event_id
   ENDIF
   IF ((dapl_event_rs->detail_cnt > 0))
    IF (dapl_manage_process_event_dtl(dapl_event_rs->event_id)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dapl_process_rs)
    CALL echorecord(dapl_event_rs)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dapl_manage_process_event_dtl(dmped_process_event_id)
   DECLARE dmped_process_event_dtl_id = f8 WITH protect, noconstant(0)
   DECLARE dmped_cnt = i4 WITH protect, noconstant(0)
   IF (validate(dm2_skip_admin_logging,- (1))=1)
    SET dm_err->eproc = "Bypassing call to Admin logging process."
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   IF (dmped_process_event_id=0.0)
    SET dm_err->eproc =
    "Check for the Process_event_id value passed to subroutine dapl_manage_process_event_dtl."
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Process_event_id value is set to 0.0")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dapl_event_rs->detail_cnt > 0))
    FOR (dmped_cnt = 1 TO size(dapl_event_rs->details,5))
      SET dm_err->eproc = "Getting next sequence for process_event_dtl_id from dm_seq."
      SELECT INTO "nl:"
       id = seq(dm_seq,nextval)
       FROM dual
       DETAIL
        dmped_process_event_dtl_id = id
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc) > 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      SET dm_err->eproc = "Inserting logging detail row into dma_process_event_dtl."
      IF ((dm_err->debug_flag > 0))
       CALL disp_msg(" ",dm_err->logfile,0)
      ENDIF
      INSERT  FROM dma_process_event_dtl dped
       SET dped.dma_process_event_dtl_id = dmped_process_event_dtl_id, dped.dma_process_event_id =
        dmped_process_event_id, dped.detail_type = dapl_event_rs->details[dmped_cnt].dtype,
        dped.detail_text = substring(1,2000,dapl_event_rs->details[dmped_cnt].dtext), dped
        .detail_number = dapl_event_rs->details[dmped_cnt].dnumber, dped.detail_dt_tm = cnvtdatetime(
         dapl_event_rs->details[dmped_cnt].ddate),
        dped.updt_dt_tm = cnvtdatetime(curdate,curtime3)
       WITH nocounter
      ;end insert
      IF (check_error(dm_err->eproc)=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ELSE
       COMMIT
      ENDIF
    ENDFOR
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dapl_process_rs)
   ENDIF
   SET dapl_event_rs->detail_cnt = 0
   SET stat = alterlist(dapl_event_rs->details,0)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dapl_check_process_event(dcpe_process_id,dcpe_event_name,dcpe_status,dcpe_curqual)
   IF (dcpe_process_id=0.0)
    SET dcpe_curqual = 0
    RETURN(1)
   ELSE
    SET dm_err->eproc = "Querying for process_id from DMA_PROCESS_EVENT."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dma_process_event dpe
     WHERE dpe.dma_process_id=dcpe_process_id
      AND dpe.event_name=dcpe_event_name
      AND dpe.event_status=dcpe_status
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) > 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (curqual > 0)
    SET dcpe_curqual = curqual
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE dfr_add_cmd_line(dacl_cmd_in=vc,dacl_reset=i2) = i2
 DECLARE dfr_add_exec_line(dael_cmd_in=vc,dael_reset=i2) = i2
 DECLARE dfr_load_out_text(dlot_file_in=vc) = i2
 DECLARE dfr_load_err_text(dlot_file_in=vc) = i2
 DECLARE dfr_load_stat_text(dlst_file_in=vc) = i2
 DECLARE dfr_gen_exec_file(null) = i2
 DECLARE dfr_gen_cmd_file(null) = i2
 DECLARE dfr_init(null) = i2
 DECLARE dfr_remove_exec_files(null) = i2
 DECLARE dfr_test_connect(null) = i2
 DECLARE dfr_exec(null) = i2
 DECLARE dfr_get_file_listing(null) = i2
 DECLARE dfr_find_directory(null) = i2
 DECLARE dfr_find_file(null) = i2
 DECLARE dfr_create_directory(null) = i2
 DECLARE dfr_put_file(null) = i2
 DECLARE dfr_add_putops_line(dapl_xfer_type=vc,dapl_loc_dir_in=vc,dapl_loc_file_in=vc,
  dapl_remote_dir_in=vc,dapl_remote_file_in=vc,
  dapl_reset=i2) = i2
 DECLARE dfr_add_getops_line(dagl_xfer_type=vc,dagl_loc_dir_in=vc,dagl_loc_file_in=vc,
  dagl_remote_dir_in=vc,dagl_remote_file_in=vc,
  dagl_reset=i2) = i2
 IF (validate(dm2ftpr->remote_host,"x")="x")
  FREE RECORD dm2ftpr
  RECORD dm2ftpr(
    1 remote_host = vc
    1 user_name = vc
    1 user_pwd = vc
    1 remote_wd = vc
    1 remote_file = vc
    1 local_wd = vc
    1 dir_name = vc
    1 file_name = vc
    1 remote_host_os = vc
    1 local_host_os = vc
    1 options = vc
    1 exec_work_dir = vc
    1 exec_command_file_name = vc
    1 exec_file_name = vc
    1 exec_logfile_name = vc
    1 exec_errfile_name = vc
    1 exec_statfile_name = vc
    1 exists_ind = i2
    1 putops_cnt = i4
    1 putops[*]
      2 put_transfer_type = vc
      2 put_local_file = vc
      2 put_local_dir = vc
      2 put_remote_file = vc
      2 put_remote_dir = vc
    1 getops_cnt = i4
    1 getops[*]
      2 get_transfer_type = vc
      2 get_local_file = vc
      2 get_local_dir = vc
      2 get_remote_file = vc
      2 get_remote_dir = vc
    1 exec_cnt = i4
    1 exec[*]
      2 exec_line = vc
    1 cmd_cnt = i4
    1 cmd[*]
      2 cmd_line = vc
    1 err_cnt = i4
    1 errline_full = vc
    1 err[*]
      2 err_line = vc
    1 out_cnt = i4
    1 outline_full = vc
    1 out[*]
      2 out_line = vc
    1 stat_val = i4
    1 statline_full = vc
  )
  SET dm2ftpr->options = "-b"
 ENDIF
 SUBROUTINE dfr_init(null)
   SET dm2ftpr->exec_logfile_name = "DM2NOTSET"
   SET dm2ftpr->exec_errfile_name = "DM2NOTSET"
   SET dm2ftpr->cmd_cnt = 0
   SET stat = alterlist(dm2ftpr->cmd,dm2ftpr->cmd_cnt)
   SET dm2ftpr->out_cnt = 0
   SET dm2ftpr->outline_full = ""
   SET stat = alterlist(dm2ftpr->out,dm2ftpr->out_cnt)
   SET dm2ftpr->err_cnt = 0
   SET dm2ftpr->errline_full = ""
   SET stat = alterlist(dm2ftpr->err,dm2ftpr->err_cnt)
   SET dm2ftpr->exec_cnt = 0
   SET stat = alterlist(dm2ftpr->exec,dm2ftpr->exec_cnt)
   SET dm2ftpr->exec_work_dir = build(logical("ccluserdir"),"/")
   IF (get_unique_file("dm2ftpr",".dat")=0)
    RETURN(0)
   ELSE
    SET dm2ftpr->exec_command_file_name = dm_err->unique_fname
    SET dm2ftpr->exec_file_name = replace(dm_err->unique_fname,".dat",".ksh",1)
    SET dm2ftpr->exec_logfile_name = replace(dm_err->unique_fname,".dat",".log",1)
    SET dm2ftpr->exec_errfile_name = replace(dm_err->unique_fname,".dat",".err",1)
    SET dm2ftpr->exec_statfile_name = replace(dm_err->unique_fname,".dat",".stat",1)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dfr_add_putops_line(dapl_xfer_type,dapl_loc_dir_in,dapl_loc_file_in,dapl_remote_dir_in,
  dapl_remote_file_in,dapl_reset)
   IF (dapl_reset=1)
    SET dm2ftpr->putops_cnt = 0
    SET stat = alterlist(dm2ftpr->putops,dm2ftpr->putops_cnt)
    RETURN(1)
   ENDIF
   SET dm2ftpr->putops_cnt = (dm2ftpr->putops_cnt+ 1)
   SET stat = alterlist(dm2ftpr->putops,dm2ftpr->putops_cnt)
   SET dm2ftpr->putops[dm2ftpr->putops_cnt].put_transfer_type = dapl_xfer_type
   SET dm2ftpr->putops[dm2ftpr->putops_cnt].put_local_file = dapl_loc_file_in
   SET dm2ftpr->putops[dm2ftpr->putops_cnt].put_local_dir = dapl_loc_dir_in
   SET dm2ftpr->putops[dm2ftpr->putops_cnt].put_remote_file = dapl_remote_file_in
   SET dm2ftpr->putops[dm2ftpr->putops_cnt].put_remote_dir = dapl_remote_dir_in
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dfr_add_getops_line(dagl_xfer_type,dagl_loc_dir_in,dagl_loc_file_in,dagl_remote_dir_in,
  dagl_remote_file_in,dagl_reset)
   IF (dagl_reset=1)
    SET dm2ftpr->getops_cnt = 0
    SET stat = alterlist(dm2ftpr->getops,dm2ftpr->getops_cnt)
    RETURN(1)
   ENDIF
   SET dm2ftpr->getops_cnt = (dm2ftpr->getops_cnt+ 1)
   SET stat = alterlist(dm2ftpr->getops,dm2ftpr->getops_cnt)
   SET dm2ftpr->getops[dm2ftpr->getops_cnt].get_transfer_type = dagl_xfer_type
   SET dm2ftpr->getops[dm2ftpr->getops_cnt].get_local_file = dagl_loc_file_in
   SET dm2ftpr->getops[dm2ftpr->getops_cnt].get_local_dir = dagl_loc_dir_in
   SET dm2ftpr->getops[dm2ftpr->getops_cnt].get_remote_file = dagl_remote_file_in
   SET dm2ftpr->getops[dm2ftpr->getops_cnt].get_remote_dir = dagl_remote_dir_in
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dfr_add_cmd_line(dacl_cmd_in,dacl_reset)
   IF (dacl_reset=1)
    SET dm2ftpr->cmd_cnt = 0
    SET stat = alterlist(dm2ftpr->cmd,dm2ftpr->cmd_cnt)
    RETURN(1)
   ENDIF
   SET dm2ftpr->cmd_cnt = (dm2ftpr->cmd_cnt+ 1)
   SET stat = alterlist(dm2ftpr->cmd,dm2ftpr->cmd_cnt)
   SET dm2ftpr->cmd[dm2ftpr->cmd_cnt].cmd_line = dacl_cmd_in
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dfr_add_exec_line(dael_exec_in,dael_reset)
   IF (dael_reset=1)
    SET dm2ftpr->exec_cnt = 0
    SET stat = alterlist(dm2ftpr->exec,dm2ftpr->exec_cnt)
    RETURN(1)
   ENDIF
   SET dm2ftpr->exec_cnt = (dm2ftpr->exec_cnt+ 1)
   SET stat = alterlist(dm2ftpr->exec,dm2ftpr->exec_cnt)
   SET dm2ftpr->exec[dm2ftpr->exec_cnt].exec_line = dael_exec_in
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dfr_load_err_text(dlet_file_in)
   IF (dm2_findfile(dlet_file_in)=0)
    SET dm_err->eproc = concat("Loading contents of error file: ",dlet_file_in)
    SET dm_err->emsg = concat("Error file not found:",dlet_file_in)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   FREE DEFINE rtl2
   FREE SET dlet_err_file_loc
   SET logical dlet_err_file_loc value(dlet_file_in)
   DEFINE rtl2 "dlet_err_file_loc"
   SET dm2ftpr->err_cnt = 0
   SET stat = alterlist(dm2ftpr->err,0)
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    WHERE r.line > " "
    DETAIL
     IF ((dm_err->debug_flag > 0))
      CALL echo(concat("TEXT = ",r.line))
     ENDIF
     dm2ftpr->err_cnt = (dm2ftpr->err_cnt+ 1), stat = alterlist(dm2ftpr->err,dm2ftpr->err_cnt),
     dm2ftpr->err[dm2ftpr->err_cnt].err_line = r.line
     IF (size(dm2ftpr->errline_full) < 200)
      dm2ftpr->errline_full = build(dm2ftpr->errline_full,dm2ftpr->err[dm2ftpr->err_cnt].err_line)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->eproc = concat("Loading contents of errput file: ",dlet_file_in)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm2ftpr->err_cnt > 0))
    SET dm2ftpr->errline_full = check(dm2ftpr->errline_full)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dfr_load_out_text(dlot_file_in)
   IF (dm2_findfile(dlot_file_in)=0)
    SET dm_err->eproc = concat("Loading contents of output file: ",dlot_file_in)
    SET dm_err->emsg = concat("Output file not found:",dlot_file_in)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   FREE DEFINE rtl2
   FREE SET dlot_out_file_loc
   SET logical dlot_out_file_loc value(dlot_file_in)
   DEFINE rtl2 "dlot_out_file_loc"
   SET dm2ftpr->out_cnt = 0
   SET stat = alterlist(dm2ftpr->out,0)
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    WHERE r.line > " "
    DETAIL
     IF ((dm_err->debug_flag > 0))
      CALL echo(concat("TEXT = ",r.line))
     ENDIF
     IF (substring(1,5,r.line) != "sftp>")
      dm2ftpr->out_cnt = (dm2ftpr->out_cnt+ 1), stat = alterlist(dm2ftpr->out,dm2ftpr->out_cnt),
      dm2ftpr->out[dm2ftpr->out_cnt].out_line = r.line
      IF (size(dm2ftpr->outline_full) < 200)
       dm2ftpr->outline_full = build(dm2ftpr->outline_full,dm2ftpr->out[dm2ftpr->out_cnt].out_line)
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->eproc = concat("Loading contents of output file: ",dlot_file_in)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm2ftpr->out_cnt > 0))
    SET dm2ftpr->outline_full = check(dm2ftpr->outline_full)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dfr_load_stat_text(dlst_file_in)
   IF (dm2_findfile(dlst_file_in)=0)
    SET dm_err->eproc = concat("Loading contents of status file: ",dlst_file_in)
    SET dm_err->emsg = concat("Output file not found:",dlst_file_in)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   FREE DEFINE rtl2
   FREE SET dlst_stat_file_loc
   SET logical dlst_stat_file_loc value(dlst_file_in)
   DEFINE rtl2 "dlst_stat_file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    WHERE r.line > " "
    DETAIL
     IF ((dm_err->debug_flag > 0))
      CALL echo(concat("TEXT = ",r.line))
     ENDIF
     dm2ftpr->statline_full = check(trim(r.line)), dm2ftpr->stat_val = cnvtint(dm2ftpr->statline_full
      )
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->eproc = concat("Loading contents of output file: ",dlst_file_in)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dfr_gen_exec_file(null)
   DECLARE dgef_cnt = i4 WITH protect, noconstant(0)
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc = concat("Writing command file for FTP: ",concat(dm2ftpr->exec_work_dir,dm2ftpr
      ->exec_file_name))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO value(concat(dm2ftpr->exec_work_dir,dm2ftpr->exec_file_name))
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     CALL print("#!/bin/ksh"), row + 1
     FOR (dgef_cnt = 1 TO dm2ftpr->exec_cnt)
      CALL print(dm2ftpr->exec[dgef_cnt].exec_line),row + 1
     ENDFOR
    WITH nocounter, maxcol = 1000, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->eproc = concat("Writing command file for FTP: ",concat(dm2ftpr->exec_work_dir,dm2ftpr
      ->exec_file_name))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dfr_gen_cmd_file(null)
   DECLARE dgcf_cnt = i4 WITH protect, noconstant(0)
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc = concat("Writing command file for FTP: ",concat(dm2ftpr->exec_work_dir,dm2ftpr
      ->exec_command_file_name))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO value(concat(dm2ftpr->exec_work_dir,dm2ftpr->exec_command_file_name))
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     FOR (dgcf_cnt = 1 TO dm2ftpr->cmd_cnt)
      CALL print(dm2ftpr->cmd[dgcf_cnt].cmd_line),row + 1
     ENDFOR
    WITH nocounter, maxcol = 1000, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->eproc = concat("Writing command file for FTP: ",concat(dm2ftpr->exec_work_dir,dm2ftpr
      ->exec_command_file_name))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dfr_exec(null)
   SET dm_err->eproc = concat("Setting permissions for executable file: ",concat(dm2ftpr->
     exec_work_dir,dm2ftpr->exec_file_name))
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   IF (dm2_push_dcl(concat("chmod 777 ",dm2ftpr->exec_work_dir,dm2ftpr->exec_file_name))=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Executing command: ",dm2ftpr->exec_work_dir,dm2ftpr->exec_file_name)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SET dm_err->disp_dcl_err_ind = 0
   IF ((dm2ftpr->user_name != curuser))
    CALL dm2_push_dcl(concat("su - ",dm2ftpr->user_name," -c ",dm2ftpr->exec_work_dir,dm2ftpr->
      exec_file_name))
   ELSE
    CALL dm2_push_dcl(concat(dm2ftpr->exec_work_dir,dm2ftpr->exec_file_name))
   ENDIF
   IF (dm2_findfile(concat(dm2ftpr->exec_work_dir,dm2ftpr->exec_statfile_name))=0)
    SET dm_err->emsg = concat("Error executing FTP script: ",concat(dm2ftpr->exec_work_dir,dm2ftpr->
      exec_file_name),". Statusfile (",concat(dm2ftpr->exec_work_dir,dm2ftpr->exec_statfile_name),
     ") not found.")
    CALL echorecord(dm2ftpr)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF (dm2_findfile(concat(dm2ftpr->exec_work_dir,dm2ftpr->exec_errfile_name))=0)
    SET dm_err->emsg = concat("Error executing FTP script: ",concat(dm2ftpr->exec_work_dir,dm2ftpr->
      exec_file_name),". Errfile (",concat(dm2ftpr->exec_work_dir,dm2ftpr->exec_errfile_name),
     ") not found.")
    CALL echorecord(dm2ftpr)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF (dm2_findfile(concat(dm2ftpr->exec_work_dir,dm2ftpr->exec_logfile_name))=0)
    SET dm_err->emsg = concat("Error executing FTP script: ",concat(dm2ftpr->exec_work_dir,dm2ftpr->
      exec_file_name),". Outfile (",concat(dm2ftpr->exec_work_dir,dm2ftpr->exec_logfile_name),
     ") not found.")
    CALL echorecord(dm2ftpr)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dfr_remove_exec_files(null)
   IF (dm2_findfile(concat(dm2ftpr->exec_work_dir,dm2ftpr->exec_logfile_name)) > 0)
    IF (dm2_push_dcl(concat("rm -f ",dm2ftpr->exec_work_dir,dm2ftpr->exec_logfile_name))=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dm2_findfile(concat(dm2ftpr->exec_work_dir,dm2ftpr->exec_errfile_name)) > 0)
    IF (dm2_push_dcl(concat("rm -f ",dm2ftpr->exec_work_dir,dm2ftpr->exec_errfile_name))=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dm2_findfile(concat(dm2ftpr->exec_work_dir,dm2ftpr->exec_command_file_name)) > 0)
    IF (dm2_push_dcl(concat("rm -f ",dm2ftpr->exec_work_dir,dm2ftpr->exec_command_file_name))=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dm2_findfile(concat(dm2ftpr->exec_work_dir,dm2ftpr->exec_file_name)) > 0)
    IF (dm2_push_dcl(concat("rm -f ",dm2ftpr->exec_work_dir,dm2ftpr->exec_file_name))=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dfr_test_connect(null)
   SET dm_err->eproc = concat("Testing FTP connection for user:",dm2ftpr->user_name," to host:",
    dm2ftpr->remote_host)
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   IF (dfr_init(null)=0)
    RETURN(0)
   ENDIF
   CALL dfr_add_cmd_line("quit",0)
   IF (dfr_gen_cmd_file(null)=0)
    RETURN(0)
   ENDIF
   CALL dfr_add_exec_line(concat("export FTP_EXEC_DIR=",dm2ftpr->exec_work_dir),0)
   CALL dfr_add_exec_line(concat("sftp ",dm2ftpr->options," ${FTP_EXEC_DIR}",dm2ftpr->
     exec_command_file_name," ",
     dm2ftpr->user_name,"@",dm2ftpr->remote_host," 1> ${FTP_EXEC_DIR}",dm2ftpr->exec_logfile_name,
     " 2> ${FTP_EXEC_DIR}",dm2ftpr->exec_errfile_name),0)
   CALL dfr_add_exec_line(concat("echo $? > ",dm2ftpr->exec_work_dir,dm2ftpr->exec_statfile_name),0)
   IF (dfr_gen_exec_file(null)=0)
    RETURN(0)
   ENDIF
   IF (dfr_exec(null)=0)
    RETURN(0)
   ENDIF
   IF (dfr_load_stat_text(concat(dm2ftpr->exec_work_dir,dm2ftpr->exec_statfile_name))=0)
    RETURN(0)
   ENDIF
   IF ((dm2ftpr->stat_val != 0))
    IF (dfr_load_err_text(concat(dm2ftpr->exec_work_dir,dm2ftpr->exec_errfile_name))=0)
     RETURN(0)
    ENDIF
    IF ((dm2ftpr->err_cnt > 0))
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("FTP connection error."," FTP messages:",dm2ftpr->errline_full)
     CALL echorecord(dm2ftpr)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag=0))
    IF (dfr_remove_exec_files(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("FTP connection successful for user:",dm2ftpr->user_name," to host:",
    dm2ftpr->remote_host)
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dfr_find_directory(null)
   SET dm_err->eproc = concat("Verify directory:",dm2ftpr->dir_name," on host:",dm2ftpr->remote_host)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   ENDIF
   IF (dfr_init(null)=0)
    RETURN(0)
   ENDIF
   SET dm2ftpr->exists_ind = 0
   CALL dfr_add_cmd_line(concat("cd ",dm2ftpr->dir_name),0)
   CALL dfr_add_cmd_line("quit",0)
   IF (dfr_gen_cmd_file(null)=0)
    RETURN(0)
   ENDIF
   CALL dfr_add_exec_line(concat("export FTP_EXEC_DIR=",dm2ftpr->exec_work_dir),0)
   CALL dfr_add_exec_line(concat("sftp ",dm2ftpr->options," ${FTP_EXEC_DIR}",dm2ftpr->
     exec_command_file_name," ",
     dm2ftpr->user_name,"@",dm2ftpr->remote_host," 1> ${FTP_EXEC_DIR}",dm2ftpr->exec_logfile_name,
     " 2> ${FTP_EXEC_DIR}",dm2ftpr->exec_errfile_name),0)
   CALL dfr_add_exec_line(concat("echo $? > ",dm2ftpr->exec_work_dir,dm2ftpr->exec_statfile_name),0)
   IF (dfr_gen_exec_file(null)=0)
    RETURN(0)
   ENDIF
   IF (dfr_exec(null)=0)
    RETURN(0)
   ENDIF
   IF (dfr_load_stat_text(concat(dm2ftpr->exec_work_dir,dm2ftpr->exec_statfile_name))=0)
    RETURN(0)
   ENDIF
   IF ((dm2ftpr->stat_val != 0))
    IF (dfr_load_err_text(concat(dm2ftpr->exec_work_dir,dm2ftpr->exec_errfile_name))=0)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dm2ftpr)
    ENDIF
    IF ((dm2ftpr->err_cnt > 0))
     SET dm2ftpr->exists_ind = 0
    ELSE
     SET dm2ftpr->exists_ind = 1
    ENDIF
   ELSE
    SET dm2ftpr->exists_ind = 1
   ENDIF
   SET dm_err->eproc = concat("Directory:",dm2ftpr->dir_name," on host:",dm2ftpr->remote_host," ",
    evaluate(dm2ftpr->exists_ind,1,"exists.","does not exist."))
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   ENDIF
   IF ((dm_err->debug_flag=0))
    IF (dfr_remove_exec_files(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dfr_create_directory(null)
   SET dm_err->eproc = concat("Create directory:",dm2ftpr->dir_name," on host:",dm2ftpr->remote_host)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   ENDIF
   IF (dfr_init(null)=0)
    RETURN(0)
   ENDIF
   CALL dfr_add_cmd_line(concat("mkdir ",dm2ftpr->dir_name),0)
   CALL dfr_add_cmd_line(concat("chmod 777 ",dm2ftpr->dir_name),0)
   CALL dfr_add_cmd_line("quit",0)
   IF (dfr_gen_cmd_file(null)=0)
    RETURN(0)
   ENDIF
   CALL dfr_add_exec_line(concat("export FTP_EXEC_DIR=",dm2ftpr->exec_work_dir),0)
   CALL dfr_add_exec_line(concat("sftp ",dm2ftpr->options," ${FTP_EXEC_DIR}",dm2ftpr->
     exec_command_file_name," ",
     dm2ftpr->user_name,"@",dm2ftpr->remote_host," 1> ${FTP_EXEC_DIR}",dm2ftpr->exec_logfile_name,
     " 2> ${FTP_EXEC_DIR}",dm2ftpr->exec_errfile_name),0)
   CALL dfr_add_exec_line(concat("echo $? > ",dm2ftpr->exec_work_dir,dm2ftpr->exec_statfile_name),0)
   IF (dfr_gen_exec_file(null)=0)
    RETURN(0)
   ENDIF
   IF (dfr_exec(null)=0)
    RETURN(0)
   ENDIF
   IF (dfr_load_stat_text(concat(dm2ftpr->exec_work_dir,dm2ftpr->exec_statfile_name))=0)
    RETURN(0)
   ENDIF
   IF ((dm2ftpr->stat_val != 0))
    IF (dfr_load_err_text(concat(dm2ftpr->exec_work_dir,dm2ftpr->exec_errfile_name))=0)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dm2ftpr)
    ENDIF
    IF ((dm2ftpr->err_cnt > 0))
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("FTP create directory error."," FTP messages:",dm2ftpr->errline_full)
     CALL echorecord(dm2ftpr)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag=0))
    IF (dfr_remove_exec_files(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Directory:",dm2ftpr->dir_name," created on host:",dm2ftpr->remote_host,
    " ")
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dfr_get_file_listing(null)
   SET dm_err->eproc = concat("Obtain listing from:",dm2ftpr->dir_name," on host:",dm2ftpr->
    remote_host)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   ENDIF
   IF (dfr_init(null)=0)
    RETURN(0)
   ENDIF
   CALL dfr_add_cmd_line(concat("cd ",dm2ftpr->dir_name),0)
   CALL dfr_add_cmd_line("ls -1",0)
   CALL dfr_add_cmd_line("quit",0)
   IF (dfr_gen_cmd_file(null)=0)
    RETURN(0)
   ENDIF
   CALL dfr_add_exec_line(concat("export FTP_EXEC_DIR=",dm2ftpr->exec_work_dir),0)
   CALL dfr_add_exec_line(concat("sftp ",dm2ftpr->options," ${FTP_EXEC_DIR}",dm2ftpr->
     exec_command_file_name," ",
     dm2ftpr->user_name,"@",dm2ftpr->remote_host," 1> ${FTP_EXEC_DIR}",dm2ftpr->exec_logfile_name,
     " 2> ${FTP_EXEC_DIR}",dm2ftpr->exec_errfile_name),0)
   CALL dfr_add_exec_line(concat("echo $? > ",dm2ftpr->exec_work_dir,dm2ftpr->exec_statfile_name),0)
   IF (dfr_gen_exec_file(null)=0)
    RETURN(0)
   ENDIF
   IF (dfr_exec(null)=0)
    RETURN(0)
   ENDIF
   IF (dfr_load_stat_text(concat(dm2ftpr->exec_work_dir,dm2ftpr->exec_statfile_name))=0)
    RETURN(0)
   ENDIF
   IF ((dm2ftpr->stat_val != 0))
    IF (dfr_load_err_text(concat(dm2ftpr->exec_work_dir,dm2ftpr->exec_errfile_name))=0)
     RETURN(0)
    ENDIF
    IF ((dm2ftpr->err_cnt > 0))
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("FTP get file listing error."," FTP messages:",dm2ftpr->errline_full)
     CALL echorecord(dm2ftpr)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dfr_load_out_text(concat(dm2ftpr->exec_work_dir,dm2ftpr->exec_logfile_name))=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm2ftpr)
   ENDIF
   IF ((dm_err->debug_flag=0))
    IF (dfr_remove_exec_files(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("File listing for:",dm2ftpr->dir_name," obtained from host:",dm2ftpr->
    remote_host," ")
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dfr_find_file(null)
   SET dm_err->eproc = concat("Find file:",dm2ftpr->dir_name,dm2ftpr->file_name," on host:",dm2ftpr->
    remote_host)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   ENDIF
   IF (dfr_init(null)=0)
    RETURN(0)
   ENDIF
   SET dm2ftpr->exists_ind = 0
   CALL dfr_add_cmd_line(concat("ls ",dm2ftpr->dir_name,dm2ftpr->file_name),0)
   CALL dfr_add_cmd_line("quit",0)
   IF (dfr_gen_cmd_file(null)=0)
    RETURN(0)
   ENDIF
   CALL dfr_add_exec_line(concat("export FTP_EXEC_DIR=",dm2ftpr->exec_work_dir),0)
   CALL dfr_add_exec_line(concat("sftp ",dm2ftpr->options," ${FTP_EXEC_DIR}",dm2ftpr->
     exec_command_file_name," ",
     dm2ftpr->user_name,"@",dm2ftpr->remote_host," 1> ${FTP_EXEC_DIR}",dm2ftpr->exec_logfile_name,
     " 2> ${FTP_EXEC_DIR}",dm2ftpr->exec_errfile_name),0)
   CALL dfr_add_exec_line(concat("echo $? > ",dm2ftpr->exec_work_dir,dm2ftpr->exec_statfile_name),0)
   IF (dfr_gen_exec_file(null)=0)
    RETURN(0)
   ENDIF
   IF (dfr_exec(null)=0)
    RETURN(0)
   ENDIF
   IF (dfr_load_out_text(concat(dm2ftpr->exec_work_dir,dm2ftpr->exec_logfile_name))=0)
    RETURN(0)
   ENDIF
   IF (dfr_load_stat_text(concat(dm2ftpr->exec_work_dir,dm2ftpr->exec_statfile_name))=0)
    RETURN(0)
   ENDIF
   IF ((dm2ftpr->stat_val != 0))
    IF (dfr_load_err_text(concat(dm2ftpr->exec_work_dir,dm2ftpr->exec_errfile_name))=0)
     RETURN(0)
    ENDIF
    IF ((dm2ftpr->err_cnt > 0))
     SET dm2ftpr->exists_ind = 0
    ENDIF
   ENDIF
   IF ((dm2ftpr->out_cnt > 0))
    SET dm2ftpr->exists_ind = 1
   ENDIF
   SET dm_err->eproc = concat("File:",dm2ftpr->dir_name,dm2ftpr->file_name," on host:",dm2ftpr->
    remote_host,
    " ",evaluate(dm2ftpr->exists_ind,1,"exists.","does not exist."))
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm2ftpr)
   ENDIF
   IF ((dm_err->debug_flag=0))
    IF (dfr_remove_exec_files(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dfr_put_file(null)
   DECLARE dpf_cnt = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = concat("Land files on host:",dm2ftpr->remote_host," via FTP PUT operation.")
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   ENDIF
   IF (dfr_init(null)=0)
    RETURN(0)
   ENDIF
   SET dm2ftpr->exists_ind = 0
   FOR (dpf_cnt = 1 TO dm2ftpr->putops_cnt)
    CALL dfr_add_cmd_line(concat("put ",dm2ftpr->putops[dpf_cnt].put_local_dir,dm2ftpr->putops[
      dpf_cnt].put_local_file," ",dm2ftpr->putops[dpf_cnt].put_remote_dir,
      dm2ftpr->putops[dpf_cnt].put_remote_file),0)
    CALL dfr_add_cmd_line(concat("chmod 777 ",dm2ftpr->putops[dpf_cnt].put_remote_dir,dm2ftpr->
      putops[dpf_cnt].put_remote_file),0)
   ENDFOR
   CALL dfr_add_cmd_line("quit",0)
   IF (dfr_gen_cmd_file(null)=0)
    RETURN(0)
   ENDIF
   CALL dfr_add_exec_line(concat("export FTP_EXEC_DIR=",dm2ftpr->exec_work_dir),0)
   CALL dfr_add_exec_line(concat("sftp ",dm2ftpr->options," ${FTP_EXEC_DIR}",dm2ftpr->
     exec_command_file_name," ",
     dm2ftpr->user_name,"@",dm2ftpr->remote_host," 1> ${FTP_EXEC_DIR}",dm2ftpr->exec_logfile_name,
     " 2> ${FTP_EXEC_DIR}",dm2ftpr->exec_errfile_name),0)
   CALL dfr_add_exec_line(concat("echo $? > ",dm2ftpr->exec_work_dir,dm2ftpr->exec_statfile_name),0)
   IF (dfr_gen_exec_file(null)=0)
    RETURN(0)
   ENDIF
   IF (dfr_exec(null)=0)
    RETURN(0)
   ENDIF
   IF (dfr_load_stat_text(concat(dm2ftpr->exec_work_dir,dm2ftpr->exec_statfile_name))=0)
    RETURN(0)
   ENDIF
   IF ((dm2ftpr->stat_val != 0))
    IF (dfr_load_err_text(concat(dm2ftpr->exec_work_dir,dm2ftpr->exec_errfile_name))=0)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dm2ftpr)
    ENDIF
    IF ((dm2ftpr->err_cnt > 0))
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("FTP Put failed for 1 or more files."," FTP messages:",dm2ftpr->
      errline_full)
     CALL echorecord(dm2ftpr)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag=0))
    IF (dfr_remove_exec_files(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Files landed on host:",dm2ftpr->remote_host)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dfr_get_file(null)
   DECLARE dpg_cnt = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = concat("Obtain files from host:",dm2ftpr->remote_host,
    " via FTP GET operation.")
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   ENDIF
   IF (dfr_init(null)=0)
    RETURN(0)
   ENDIF
   SET dm2ftpr->exists_ind = 0
   FOR (dpg_cnt = 1 TO dm2ftpr->getops_cnt)
     CALL dfr_add_cmd_line(concat("get ",dm2ftpr->getops[dpg_cnt].get_remote_dir,dm2ftpr->getops[
       dpg_cnt].get_remote_file," ",dm2ftpr->getops[dpg_cnt].get_local_dir,
       dm2ftpr->getops[dpg_cnt].get_local_file),0)
   ENDFOR
   CALL dfr_add_cmd_line("quit",0)
   IF (dfr_gen_cmd_file(null)=0)
    RETURN(0)
   ENDIF
   CALL dfr_add_exec_line(concat("export FTP_EXEC_DIR=",dm2ftpr->exec_work_dir),0)
   CALL dfr_add_exec_line(concat("sftp ",dm2ftpr->options," ${FTP_EXEC_DIR}",dm2ftpr->
     exec_command_file_name," ",
     dm2ftpr->user_name,"@",dm2ftpr->remote_host," 1> ${FTP_EXEC_DIR}",dm2ftpr->exec_logfile_name,
     " 2> ${FTP_EXEC_DIR}",dm2ftpr->exec_errfile_name),0)
   FOR (dpg_cnt = 1 TO dm2ftpr->getops_cnt)
     CALL dfr_add_exec_line(concat("chmod 777 ",dm2ftpr->getops[dpg_cnt].get_local_dir,dm2ftpr->
       getops[dpg_cnt].get_local_file),0)
   ENDFOR
   CALL dfr_add_exec_line(concat("echo $? > ",dm2ftpr->exec_work_dir,dm2ftpr->exec_statfile_name),0)
   IF (dfr_gen_exec_file(null)=0)
    RETURN(0)
   ENDIF
   IF (dfr_exec(null)=0)
    RETURN(0)
   ENDIF
   IF (dfr_load_stat_text(concat(dm2ftpr->exec_work_dir,dm2ftpr->exec_statfile_name))=0)
    RETURN(0)
   ENDIF
   IF ((dm2ftpr->stat_val != 0))
    IF (dfr_load_err_text(concat(dm2ftpr->exec_work_dir,dm2ftpr->exec_errfile_name))=0)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dm2ftpr)
    ENDIF
    IF ((dm2ftpr->err_cnt > 0))
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("FTP Get failed for 1 or more files."," FTP messages:",dm2ftpr->
      errline_full)
     CALL echorecord(dm2ftpr)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag=0))
    IF (dfr_remove_exec_files(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Files were obtained from host:",dm2ftpr->remote_host)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   ENDIF
   RETURN(1)
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
 DECLARE dm2_adb_check(dac_db_link=vc,dac_adb_ind=i2(ref)) = i2
 SUBROUTINE dm2_adb_check(dac_db_link,dac_adb_ind)
   DECLARE dac_col_cnt = i4 WITH protect, noconstant(0)
   SET dac_adb_ind = 0
   SET dm_err->eproc = "Check if connected to database."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   IF (validate(currdbhandle,"")="")
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "currdbhandle is not set."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Check if connected to autonomous database."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT
    IF (dac_db_link > ""
     AND dac_db_link != "DM2NOTSET")
     FROM (parser(concat("dba_tab_columns@",dac_db_link)) dtc)
    ELSE
     FROM dba_tab_columns dtc
    ENDIF
    INTO "nl:"
    dac_col_tmp_cnt = count(*)
    WHERE dtc.owner="SYS"
     AND dtc.table_name="V_$PDBS"
     AND dtc.column_name="CLOUD_IDENTITY"
    DETAIL
     dac_col_cnt = dac_col_tmp_cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dac_col_cnt > 0)
    IF (dac_db_link > ""
     AND dac_db_link != "DM2NOTSET")
     SELECT INTO "nl:"
      FROM (
       (
       (SELECT
        name = x.name
        FROM (parser(concat("V$PDBS@",dac_db_link)) x)
        WHERE parser(concat(cnvtupper(" x.cloud_identity = '*AUTONOMOUSDATABASE*' ")))
        WITH sqltype("C128")))
       u)
      DETAIL
       CALL echo("Connected to autonomous database"), dac_adb_ind = 1
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM (
       (
       (SELECT
        name = x.name
        FROM v$pdbs x
        WHERE parser(concat(cnvtupper(" x.cloud_identity = '*AUTONOMOUSDATABASE*' ")))
        WITH sqltype("C128")))
       u)
      DETAIL
       CALL echo("Connected to autonomous database"), dac_adb_ind = 1
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE dr_load_validate_response_file(dvr_process=vc,dvr_resp_file=vc,dvr_status_file=vc) = i2
 DECLARE dr_write_log(dwl_mode=vc) = i2
 DECLARE dr_general_sanity_checks(null) = i2
 DECLARE dr_src_sanity_checks(null) = i2
 DECLARE dr_tgt_sanity_checks(null) = i2
 DECLARE drrr_process = vc WITH protect, noconstant("DM2NOTSET")
 DECLARE drrr_resp_file_in = vc WITH protect, noconstant("DM2NOTSET")
 DECLARE drrr_hold_eproc = vc WITH protect, noconstant("")
 DECLARE drrr_hold_emsg = vc WITH protect, noconstant("")
 DECLARE drrr_hold_err_ind = i2 WITH protect, noconstant(0)
 DECLARE drrr_status_file_in = vc WITH protect, noconstant("")
 DECLARE drrr_cclversion = i4 WITH protect, noconstant(0)
 DECLARE drrr_hold_user_action = vc WITH protect, noconstant("")
 DECLARE drrr_curqual_ret = i4 WITH protect, noconstant(0)
 DECLARE drrr_start_dt = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 IF (check_logfile("dm2_rrr",".log","dm2_rrr driver")=0)
  GO TO end_program
 ENDIF
 SET dm_err->eproc = "Begin DM2_RRR..."
 CALL disp_msg(" ",dm_err->logfile,0)
 SET drrr_process = trim(cnvtupper( $1),3)
 SET drrr_resp_file_in =  $2
 SET drrr_responsefile_in_use = 1
 SET drrr_status_file_in =  $3
 IF ( NOT ((dm2_sys_misc->cur_os IN ("AIX", "HPX", "LNX"))))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat(trim(dm2_sys_misc->cur_os)," is an invalid operating system.")
  SET dm_err->eproc = "Validating supported operating system."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO end_program
 ENDIF
 SET drrr_cclversion = (((cnvtint(currev) * 10000)+ (cnvtint(currevminor) * 100))+ cnvtint(
  currevminor2))
 IF (drrr_cclversion < 80305)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Response file can only be used for CCL 8.3.5 and above."
  SET dm_err->eproc = "Validating CCL version"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO end_program
 ENDIF
 IF ( NOT (drrr_process IN ("SOURCE DATA COLLECTION", "TARGET DATA COLLECTION", "DOMAIN REFRESH",
 "DOMAIN REPLICATE", "CREATE COPY OF DATABASE",
 "REPLICATE RUNNER", "REFRESH V500 USER", "EXPORT/IMPORT SETUP", "EXPORT/IMPORT CLEANUP",
 "DATABASE SHELL CREATION",
 "DATA SYNC", "COMPLETE COPY OF DATABASE", "CREATE DB ENVIRONMENT", "ADMIN DATABASE CREATION",
 "CLINICAL DATABASE CREATION",
 "FINAL CLEANUP")))
  SET dm_err->eproc = "Verify input process."
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Invalid input process option."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO end_program
 ENDIF
 SET drrr_misc_data->process_mode = drrr_process
 SET dm_err->eproc = concat("Completing [",trim(drrr_process),"] process using [",trim(
   drrr_resp_file_in),"] response file...")
 CALL disp_msg(" ",dm_err->logfile,0)
 IF (dr_load_validate_response_file(drrr_process,drrr_resp_file_in,drrr_status_file_in)=0)
  GO TO end_program
 ENDIF
 IF ((dm_err->debug_flag > 0))
  CALL echorecord(drrr_rf_data)
  CALL echorecord(drrr_misc_data)
 ENDIF
 IF ((drer_email_list->email_cnt > 0))
  SET drer_email_det->process = drrr_process
  SET drer_email_det->status = "EXECUTING"
  SET drer_email_det->status_dt_tm = cnvtdatetime(curdate,curtime3)
  SET drer_email_det->src_env = drrr_rf_data->src_env_name
  SET drer_email_det->tgt_env = drrr_rf_data->tgt_env_name
  IF (drrr_process="SOURCE DATA COLLECTION")
   SET drer_email_det->src_node = curnode
  ELSE
   SET drer_email_det->tgt_node = curnode
  ENDIF
  SET drer_email_det->client = drrr_rf_data->client_mnemonic
  SET drer_email_det->step = drrr_process
  SET drer_email_det->email_level = 1
  SET drer_email_det->logfile = dm_err->logfile
  SET drer_email_det->err_ind = dm_err->err_ind
  SET drer_email_det->eproc = dm_err->eproc
  SET drer_email_det->emsg = dm_err->emsg
  SET drer_email_det->user_action = dm_err->user_action
  IF (drer_compose_email(null)=1)
   CALL drer_send_email(drer_email_det->subject,drer_email_det->file_name,drer_email_det->email_level
    )
  ENDIF
  CALL drer_reset_pre_err(null)
 ENDIF
 IF (validate(dm2_test_token_validation_only,0)=1)
  GO TO end_program
 ENDIF
 IF ((((drrr_rf_data->mode != "ISOLATED")) OR ((drrr_rf_data->mode="ISOLATED")
  AND  NOT (drrr_process IN ("SOURCE DATA COLLECTION", "ADMIN DATABASE CREATION")))) )
  IF (dr_write_log("START")=0)
   GO TO end_program
  ENDIF
 ENDIF
 IF ((drrr_rf_data->mode="ISOLATED"))
  IF (drrr_process="CLINICAL DATABASE CREATION")
   IF (dr_write_log("DETAILS")=0)
    GO TO end_program
   ENDIF
  ENDIF
 ELSE
  IF (drrr_process="SOURCE DATA COLLECTION")
   IF (dr_write_log("DETAILS")=0)
    GO TO end_program
   ENDIF
  ENDIF
 ENDIF
 CASE (drrr_process)
  OF "SOURCE DATA COLLECTION":
   SET drrr_rf_data->src_app_temp_dir = build(drrr_rf_data->src_app_temp_dir,cnvtlower(trim(curnode,3
      )),"/")
   SET drrr_misc_data->active_dir = drrr_rf_data->src_app_temp_dir
   IF (drrr_val_rf_src_cnnct_data(1)=0)
    GO TO end_program
   ENDIF
   EXECUTE dm2_get_src_domain_data drrr_misc_data->process_type
   IF ((dm_err->err_ind > 0))
    GO TO end_program
   ENDIF
  OF "TARGET DATA COLLECTION":
   SET drrr_rf_data->tgt_app_temp_dir = build(drrr_rf_data->tgt_app_temp_dir,cnvtlower(trim(curnode,3
      )),"/")
   SET drrr_misc_data->active_dir = drrr_rf_data->tgt_app_temp_dir
   IF ((validate(dm2_skip_pre_process_event_check,- (1))=- (1)))
    IF (dapl_check_process_event(drrr_misc_data->process_id,"EXPORT/IMPORT SETUP",dapl_complete,
     drrr_curqual_ret)=0)
     GO TO end_program
    ENDIF
    IF (drrr_curqual_ret=0)
     SET dm_err->eproc = "Pre-process check for 'TARGET DATA COLLECTION'."
     SET dm_err->emsg = concat("Check for completed 'EXPORT/IMPORT SETUP' process failed.")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO end_program
    ENDIF
   ENDIF
   IF (drrr_val_rf_tgt_cnnct_data(1)=0)
    GO TO end_program
   ENDIF
   EXECUTE dm2_get_tgt_domain_data drrr_misc_data->process_type
   IF ((dm_err->err_ind > 0))
    GO TO end_program
   ENDIF
  OF "DOMAIN REFRESH":
   SET drrr_rf_data->tgt_app_temp_dir = build(drrr_rf_data->tgt_app_temp_dir,cnvtlower(trim(curnode,3
      )),"/")
   SET drrr_misc_data->active_dir = drrr_rf_data->tgt_app_temp_dir
   IF ((validate(dm2_skip_pre_process_event_check,- (1))=- (1)))
    IF ((drrr_rf_data->tgt_db_copy_type="ALTERNATE"))
     IF (dapl_check_process_event(drrr_misc_data->process_id,"COMPLETE COPY OF DATABASE",
      dapl_complete,drrr_curqual_ret)=0)
      GO TO end_program
     ENDIF
     IF (drrr_curqual_ret=0)
      SET dm_err->eproc = "Pre-process check for 'DOMAIN REFRESH'."
      SET dm_err->emsg = concat("Check for completed 'COMPLETE COPY OF DATABASE' process failed.")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO end_program
     ENDIF
    ELSE
     IF (dapl_check_process_event(drrr_misc_data->process_id,"CREATE COPY OF DATABASE",dapl_complete,
      drrr_curqual_ret)=0)
      GO TO end_program
     ENDIF
     IF (drrr_curqual_ret=0)
      SET dm_err->eproc = "Pre-process check for 'DOMAIN REFRESH'."
      SET dm_err->emsg = concat("Check for completed 'CREATE COPY OF DATABASE' process failed.")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO end_program
     ENDIF
    ENDIF
    SET drrr_curqual_ret = 0
    IF (dapl_check_process_event(drrr_misc_data->process_id,"FINAL CLEANUP",dapl_complete,
     drrr_curqual_ret)=0)
     GO TO end_program
    ENDIF
    IF (drrr_curqual_ret > 0)
     SET dm_err->eproc = "Pre-process check for 'DOMAIN REFRESH'."
     SET dm_err->emsg = concat(
      "'DOMAIN REFRESH' cannot be run after 'FINAL CLEANUP' complete.  Process failed.")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO end_program
    ENDIF
   ENDIF
   IF (drrr_val_rf_tgt_cnnct_data(1)=0)
    GO TO end_program
   ENDIF
   EXECUTE dm2_domain_refresh "REFRESH"
   IF ((dm_err->err_ind=1))
    GO TO end_program
   ENDIF
  OF "DOMAIN REPLICATE":
   SET drrr_rf_data->tgt_app_temp_dir = build(drrr_rf_data->tgt_app_temp_dir,cnvtlower(trim(curnode,3
      )),"/")
   SET drrr_misc_data->active_dir = drrr_rf_data->tgt_app_temp_dir
   IF ((validate(dm2_skip_pre_process_event_check,- (1))=- (1)))
    IF ((drrr_rf_data->tgt_db_copy_type="ALTERNATE"))
     IF (dapl_check_process_event(drrr_misc_data->process_id,"COMPLETE COPY OF DATABASE",
      dapl_complete,drrr_curqual_ret)=0)
      GO TO end_program
     ENDIF
     IF (drrr_curqual_ret=0)
      SET dm_err->eproc = "Pre-process check for 'DOMAIN REPLICATE'."
      SET dm_err->emsg = concat("Check for completed 'COMPLETE COPY OF DATABASE' process failed.")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO end_program
     ENDIF
    ELSE
     IF (dapl_check_process_event(drrr_misc_data->process_id,"CREATE COPY OF DATABASE",dapl_complete,
      drrr_curqual_ret)=0)
      GO TO end_program
     ENDIF
     IF (drrr_curqual_ret=0)
      SET dm_err->eproc = "Pre-process check for 'DOMAIN REPLICATE'."
      SET dm_err->emsg = concat("Check for completed 'CREATE COPY OF DATABASE' process failed.")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO end_program
     ENDIF
    ENDIF
    SET drrr_curqual_ret = 0
    IF (dapl_check_process_event(drrr_misc_data->process_id,"FINAL CLEANUP",dapl_complete,
     drrr_curqual_ret)=0)
     GO TO end_program
    ENDIF
    IF (drrr_curqual_ret > 0)
     SET dm_err->eproc = "Pre-process check for 'DOMAIN REPLICATE'."
     SET dm_err->emsg = concat(
      "'DOMAIN REPLICATE' cannot be run after 'FINAL CLEANUP' complete.  Process failed.")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO end_program
    ENDIF
   ENDIF
   IF (drrr_val_rf_tgt_cnnct_data(1)=0)
    GO TO end_program
   ENDIF
   EXECUTE dm2_domain_refresh "REPLICATE"
   IF ((dm_err->err_ind=1))
    GO TO end_program
   ENDIF
  OF "COMPLETE COPY OF DATABASE":
   IF ((validate(dm2_skip_pre_process_event_check,- (1))=- (1)))
    IF (dapl_check_process_event(drrr_misc_data->process_id,"CREATE DB ENVIRONMENT",dapl_complete,
     drrr_curqual_ret)=0)
     GO TO end_program
    ENDIF
    IF (drrr_curqual_ret=0)
     SET dm_err->eproc = "Pre-process check for 'COMPLETE COPY OF DATABASE'."
     SET dm_err->emsg = concat("Check for completed 'CREATE DB ENVIRONMENT' process failed.")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO end_program
    ENDIF
   ENDIF
   IF (drrr_val_rf_tgt_cnnct_data(1)=0)
    GO TO end_program
   ENDIF
   SET dm2_install_schema->menu_driver = "dm2_rrr"
   SET dm2_install_schema->process_option = "CLIN COPY"
   SET drrr_rf_data->tgt_app_temp_dir = build(drrr_rf_data->tgt_app_temp_dir,cnvtlower(trim(curnode,3
      )),"/")
   SET drrr_misc_data->active_dir = drrr_rf_data->tgt_app_temp_dir
   SET dm_err->eproc = 'Executing DM2_INSTALL_SCHEMA with "Complete Copy of Database" process mode.'
   CALL disp_msg("",dm_err->logfile,0)
   EXECUTE dm2_install_schema "NONE", "NONE", "NONE",
   "NONE", "NONE", "NONE",
   "NONE"
   IF ((dm_err->err_ind=1))
    GO TO end_program
   ENDIF
  OF "CREATE COPY OF DATABASE":
   IF ((validate(dm2_skip_pre_process_event_check,- (1))=- (1)))
    IF (cnvtupper(drrr_rf_data->target_refresh)="YES")
     IF (dapl_check_process_event(drrr_misc_data->process_id,"REFRESH V500 USER",dapl_complete,
      drrr_curqual_ret)=0)
      GO TO end_program
     ENDIF
     IF (drrr_curqual_ret=0)
      SET dm_err->eproc = "Pre-process check for 'CREATE COPY OF DATABASE'."
      SET dm_err->emsg = concat("Check for completed 'REFRESH V500 USER' process failed.")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO end_program
     ENDIF
    ELSE
     IF (dapl_check_process_event(drrr_misc_data->process_id,"EXPORT/IMPORT SETUP",dapl_complete,
      drrr_curqual_ret)=0)
      GO TO end_program
     ENDIF
     IF (drrr_curqual_ret=0)
      SET dm_err->eproc = "Pre-process check for 'CREATE COPY OF DATABASE'."
      SET dm_err->emsg = concat("Check for completed 'EXPORT/IMPORT SETUP' process failed.")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO end_program
     ENDIF
    ENDIF
   ENDIF
   IF (drrr_val_rf_tgt_cnnct_data(1)=0)
    GO TO end_program
   ENDIF
   SET dm2_install_schema->menu_driver = "dm2_rrr"
   SET dm2_install_schema->process_option = "CLIN COPY"
   SET drrr_rf_data->tgt_app_temp_dir = build(drrr_rf_data->tgt_app_temp_dir,cnvtlower(trim(curnode,3
      )),"/")
   SET drrr_misc_data->active_dir = drrr_rf_data->tgt_app_temp_dir
   SET dm_err->eproc = 'Executing DM2_INSTALL_SCHEMA with "Create Copy of Database" process mode.'
   CALL disp_msg("",dm_err->logfile,0)
   EXECUTE dm2_install_schema "NONE", "NONE", "NONE",
   "NONE", "NONE", "NONE",
   "NONE"
   IF ((dm_err->err_ind=1))
    GO TO end_program
   ENDIF
  OF "REPLICATE RUNNER":
   SET drrr_rf_data->tgt_app_temp_dir = build(drrr_rf_data->tgt_app_temp_dir,cnvtlower(trim(curnode,3
      )),"/")
   SET drrr_misc_data->active_dir = drrr_rf_data->tgt_app_temp_dir
   IF (drrr_val_rf_tgt_cnnct_data(1)=0)
    GO TO end_program
   ENDIF
   EXECUTE dm2_replicate_runner
   IF ((dm_err->err_ind=1))
    GO TO end_program
   ENDIF
  OF "REFRESH V500 USER":
   IF ((validate(dm2_skip_pre_process_event_check,- (1))=- (1)))
    IF (dapl_check_process_event(drrr_misc_data->process_id,"TARGET REFRESH KSH",dapl_complete,
     drrr_curqual_ret)=0)
     GO TO end_program
    ENDIF
    IF (drrr_curqual_ret=0)
     SET dm_err->eproc = "Pre-process check for 'REFRESH V500 USER'."
     SET dm_err->emsg = concat("Check for completed 'TARGET REFRESH KSH' process failed.")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO end_program
    ENDIF
   ENDIF
   SET drrr_rf_data->tgt_app_temp_dir = build(drrr_rf_data->tgt_app_temp_dir,cnvtlower(trim(curnode,3
      )),"/")
   SET drrr_misc_data->active_dir = drrr_rf_data->tgt_app_temp_dir
   IF (drrr_val_rf_tgt_sys_cnnct_data(1)=0)
    GO TO end_program
   ENDIF
   EXECUTE dm2_refresh_v500_user
   IF ((dm_err->err_ind=1))
    GO TO end_program
   ENDIF
  OF "EXPORT/IMPORT SETUP":
  OF "EXPORT/IMPORT CLEANUP":
   SET drrr_rf_data->tgt_app_temp_dir = build(drrr_rf_data->tgt_app_temp_dir,cnvtlower(trim(curnode,3
      )),"/")
   SET drrr_misc_data->active_dir = drrr_rf_data->tgt_app_temp_dir
   IF (drrr_val_rf_tgt_cnnct_data(1)=0)
    GO TO end_program
   ENDIF
   EXECUTE dm2_replicate_expimp_menu
   IF ((dm_err->err_ind=1))
    GO TO end_program
   ENDIF
  OF "DATABASE SHELL CREATION":
   SET drrr_rf_data->tgt_app_temp_dir = build(drrr_rf_data->tgt_app_temp_dir,cnvtlower(trim(curnode,3
      )),"/")
   SET drrr_misc_data->active_dir = drrr_rf_data->tgt_app_temp_dir
   IF (drrr_val_rf_src_cnnct_data(1)=0)
    GO TO end_program
   ENDIF
   EXECUTE dm2_create_db_shell
   IF ((dm_err->err_ind=1))
    GO TO end_program
   ENDIF
  OF "DATA SYNC":
   SET drrr_rf_data->tgt_app_temp_dir = build(drrr_rf_data->tgt_app_temp_dir,cnvtlower(trim(curnode,3
      )),"/")
   SET drrr_misc_data->active_dir = drrr_rf_data->tgt_app_temp_dir
   IF (drrr_val_rf_tgt_cnnct_data(1)=0)
    GO TO end_program
   ENDIF
   EXECUTE dm2_replicate_data_sync
   IF ((dm_err->err_ind=1))
    GO TO end_program
   ENDIF
  OF "CREATE DB ENVIRONMENT":
   SET dm2_install_schema->menu_driver = "dm2_rrr"
   SET dm2_install_schema->process_option = "CLIN COPY"
   SET drrr_rf_data->tgt_app_temp_dir = build(drrr_rf_data->tgt_app_temp_dir,cnvtlower(trim(curnode,3
      )),"/")
   SET drrr_misc_data->active_dir = drrr_rf_data->tgt_app_temp_dir
   IF (drrr_val_rf_adm_cnnct_data(1)=0)
    GO TO end_program
   ENDIF
   SET dm_err->eproc = 'Executing DM2_CREATE_DB_ENV with "Create DB Environment" process mode.'
   CALL disp_msg("",dm_err->logfile,0)
   EXECUTE dm2_create_db_env
   IF ((dm_err->err_ind=1))
    GO TO end_program
   ENDIF
  OF "ADMIN DATABASE CREATION":
  OF "CLINICAL DATABASE CREATION":
   SET drrr_rf_data->tgt_app_temp_dir = build(drrr_rf_data->tgt_app_temp_dir,cnvtlower(trim(curnode,3
      )),"/")
   SET drrr_misc_data->active_dir = drrr_rf_data->tgt_app_temp_dir
   EXECUTE dm2_create_db_shell
   IF ((dm_err->err_ind=1))
    GO TO end_program
   ENDIF
  OF "FINAL CLEANUP":
   IF ((validate(dm2_skip_pre_process_event_check,- (1))=- (1)))
    IF ((drrr_rf_data->target_refresh="YES"))
     IF (dapl_check_process_event(drrr_misc_data->process_id,"DOMAIN REFRESH",dapl_complete,
      drrr_curqual_ret)=0)
      GO TO end_program
     ENDIF
     IF (drrr_curqual_ret=0)
      SET dm_err->eproc = "Pre-process check for 'FINAL CLEANUP'."
      SET dm_err->emsg = concat("Check for completed 'DOMAIN REFRESH' process failed.")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO end_program
     ENDIF
    ELSE
     IF (dapl_check_process_event(drrr_misc_data->process_id,"DOMAIN REPLICATE",dapl_complete,
      drrr_curqual_ret)=0)
      GO TO end_program
     ENDIF
     IF (drrr_curqual_ret=0)
      SET dm_err->eproc = "Pre-process check for 'FINAL CLEANUP'."
      SET dm_err->emsg = concat("Check for completed 'DOMAIN REPLICATE' process failed.")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO end_program
     ENDIF
    ENDIF
   ENDIF
   IF (drrr_val_rf_tgt_cnnct_data(1)=0)
    GO TO end_program
   ENDIF
   IF ((drrr_rf_data->tgt_drop_db_links="YES"))
    IF (drr_drop_db_link("REF_DATA_LINK")=0)
     GO TO end_program
    ENDIF
    IF (drr_drop_db_link("REPL_SOURCE")=0)
     GO TO end_program
    ENDIF
   ENDIF
   IF ((drrr_rf_data->target_refresh="YES"))
    EXECUTE dm2_repl_cleanup_pwds
    IF ((dm_err->err_ind=1))
     GO TO end_program
    ENDIF
   ENDIF
   IF (drr_del_preserved_ts(drrr_rf_data->tgt_db_name)=0)
    GO TO end_program
   ENDIF
 ENDCASE
 FREE SET drrr_responsefile_in_use
 GO TO end_program
 SUBROUTINE dr_load_validate_response_file(dvr_process,dvr_resp_file,dvr_status_file)
   DECLARE dvrfc_cur_app_node = vc WITH protect, noconstant("")
   DECLARE dvrfc_idx = i4 WITH protect, noconstant(0)
   DECLARE dvrfc_curr_env = vc WITH protect, noconstant("")
   DECLARE dvrfc_local = vc WITH protect, noconstant("")
   SET dvrfc_cur_app_node = trim(curnode,3)
   SET dvrfc_curr_env = cnvtupper(trim(logical("environment")))
   IF (drrr_load_rf_data_rs(dvr_resp_file,"FINAL_LOAD")=0)
    SET drrr_hold_eproc = dm_err->eproc
    SET drrr_hold_emsg = dm_err->emsg
    SET drrr_hold_err_ind = dm_err->err_ind
    SET dm_err->err_ind = 0
    CALL drrr_val_rf_status_file(dvr_status_file)
    SET dm_err->eproc = drrr_hold_eproc
    SET dm_err->emsg = drrr_hold_emsg
    SET dm_err->err_ind = drrr_hold_err_ind
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_status_file(dvr_status_file)=0)
    RETURN(0)
   ENDIF
   IF (dr_general_sanity_checks(null)=0)
    RETURN(0)
   ENDIF
   IF (dr_src_sanity_checks(null)=0)
    RETURN(0)
   ENDIF
   IF (dr_tgt_sanity_checks(null)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_adm_cnnct_data(0)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_cred_link_data(null)=0)
    RETURN(0)
   ENDIF
   IF ((drrr_rf_data->mode="ISOLATED"))
    IF (drrr_val_rf_isolated_mode(dvr_process)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((drrr_rf_data->target_refresh="NO"))
    SET drrr_rf_data->tgt_restore_preserve_data = "NO"
    IF (drrr_val_rf_tgt_db_shell_misc(0)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (drrr_val_rf_drr_shadow_tables(null)=0)
    RETURN(0)
   ENDIF
   IF (dvr_process IN ("TARGET DATA COLLECTION", "DOMAIN REFRESH", "DOMAIN REPLICATE",
   "CREATE COPY OF DATABASE", "REPLICATE RUNNER",
   "REFRESH V500 USER", "EXPORT/IMPORT SETUP", "EXPORT/IMPORT CLEANUP", "DATABASE SHELL CREATION",
   "DATA SYNC",
   "COMPLETE COPY OF DATABASE", "CREATE DB ENVIRONMENT", "ADMIN DATABASE CREATION",
   "CLINICAL DATABASE CREATION"))
    IF (cnvtupper(drrr_rf_data->tgt_env_name) != cnvtupper(trim(logical("environment"))))
     SET dm_err->eproc = concat("Verify process context matches with current enivornment (",trim(
       cnvtupper(logical("environment")),3),").")
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("Currently performing ",cnvtupper(dvr_process),
      " but not connected to TARGET environment (",cnvtupper(drrr_rf_data->tgt_env_name),").")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET dvrfc_local = "TARGET"
   ELSEIF (dvr_process IN ("SOURCE DATA COLLECTION"))
    IF (cnvtupper(drrr_rf_data->src_env_name) != cnvtupper(trim(logical("environment"))))
     SET dm_err->eproc = concat("Verify process context matches with current enivornment (",trim(
       cnvtupper(logical("environment")),3),").")
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("Currently performing ",cnvtupper(dvr_process),
      " but not connected to SOURCE environment (",cnvtupper(drrr_rf_data->src_env_name),").")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET dvrfc_local = "SOURCE"
   ENDIF
   IF ((drrr_rf_data->mode="ISOLATED"))
    IF (dvr_process="SOURCE DATA COLLECTION")
     IF (drrr_val_rf_ping_nodes(1,0,0,dvrfc_local)=0)
      RETURN(0)
     ENDIF
    ELSE
     IF (drrr_val_rf_ping_nodes(0,1,1,dvrfc_local)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ELSE
    IF ((drrr_rf_data->target_refresh="YES"))
     IF (drrr_val_rf_ping_nodes(1,1,0,dvrfc_local)=0)
      RETURN(0)
     ENDIF
    ELSE
     IF (dvr_process="SOURCE DATA COLLECTION")
      IF (drrr_val_rf_ping_nodes(1,0,0,dvrfc_local)=0)
       RETURN(0)
      ENDIF
     ELSE
      IF (drrr_val_rf_ping_nodes(1,1,0,dvrfc_local)=0)
       RETURN(0)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CASE (cnvtupper(dvr_process))
    OF "SOURCE DATA COLLECTION":
     IF (drrr_val_rf_src_cnnct_data(1)=0)
      RETURN(0)
     ENDIF
     IF (drrr_val_rf_src_app_temp_dir(null)=0)
      RETURN(0)
     ENDIF
     SET dvrfc_idx = 0
     IF (locateval(dvrfc_idx,1,drrr_misc_data->src_app_node_cnt,cnvtlower(trim(curnode,3)),
      drrr_misc_data->src_app_nodes[dvrfc_idx].node_name)=0)
      SET dm_err->eproc =
      "Verify current application node matches response file Source app node list."
      SET dm_err->err_ind = 1
      SET dm_err->emsg =
      "Current application node does not match any Source app node listed in response file."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
     IF (dm2_get_rdbms_version(null)=0)
      RETURN(0)
     ENDIF
     IF ((dm2_rdbms_version->level1 < 10))
      SET dm_err->err_ind = 1
      SET dm_err->emsg = "Response file can only be used for Oracle 11 and above."
      SET dm_err->eproc = "Validating Oracle version"
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
    OF "COMPLETE COPY OF DATABASE":
    OF "CREATE COPY OF DATABASE":
    OF "TARGET DATA COLLECTION":
     IF ((drrr_rf_data->mode != "ISOLATED"))
      IF (drrr_val_rf_src_cnnct_data(1)=0)
       RETURN(0)
      ENDIF
      IF (drrr_val_rf_restore_groups(null)=0)
       RETURN(0)
      ENDIF
     ENDIF
     IF (drrr_val_rf_tgt_cnnct_data(1)=0)
      RETURN(0)
     ENDIF
     IF (drrr_val_rf_tgt_app_temp_dir(null)=0)
      RETURN(0)
     ENDIF
     IF ((drrr_rf_data->mode != "ISOLATED"))
      IF (drrr_val_rf_tgt_tspace_dg_list(null)=0)
       RETURN(0)
      ENDIF
     ENDIF
     SET dvrfc_idx = 0
     IF (locateval(dvrfc_idx,1,drrr_misc_data->tgt_app_node_cnt,cnvtlower(trim(curnode,3)),
      drrr_misc_data->tgt_app_nodes[dvrfc_idx].node_name)=0)
      SET dm_err->eproc =
      "Verify current application node matches response file Target app node list."
      SET dm_err->err_ind = 1
      SET dm_err->emsg =
      "Current application node does not match any Target app node listed in response file."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
     IF (dm2_get_rdbms_version(null)=0)
      RETURN(0)
     ENDIF
     IF ((dm2_rdbms_version->level1 < 10))
      SET dm_err->err_ind = 1
      SET dm_err->emsg = "Response file can only be used for Oracle 10 and above."
      SET dm_err->eproc = "Validating Oracle version"
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
     IF ((dm2_rdbms_version->level1 <= 10)
      AND (drrr_misc_data->tgt_retain_db_user_cnt > 0))
      SET dm_err->err_ind = 1
      SET dm_err->eproc = concat(
       "Validating response file target retain db user list (tgt_RETAIN_DB_USER_LIST): ",drrr_rf_data
       ->tgt_retain_db_user_list)
      SET dm_err->emsg = concat(
       "Oracle version must be 11 or higher in order to retain database users.")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (cnvtupper(dvr_process)="TARGET DATA COLLECTION")
      IF (drrr_val_rf_tgt_database_users(null)=0)
       RETURN(0)
      ENDIF
     ENDIF
    OF "REFRESH V500 USER":
     IF (drrr_val_rf_src_cnnct_data(1)=0)
      RETURN(0)
     ENDIF
     IF ((validate(dm2_rrr_skip_refresh_drop_restart,- (1))=- (1))
      AND (validate(dm2_rrr_skip_refresh_drop_restrict,- (2))=- (2)))
      IF (curnode != cnvtlower(drrr_rf_data->tgt_db_node)
       AND cnvtupper(drrr_rf_data->tgt_db_node_os)="LNX"
       AND (drrr_rf_data->tgt_db_deploy_config="OP"))
       IF (drr_refresh_drop_restrict("I",1)=0)
        RETURN(0)
       ENDIF
      ENDIF
     ELSE
      SET dm_err->eproc = "Skipping the execution of refresh drop restrict."
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     IF (drrr_val_rf_tgt_sys_cnnct_data(1)=0)
      RETURN(0)
     ENDIF
    OF "DOMAIN REFRESH":
     IF ((drrr_misc_data->process_type != "REFRESH"))
      SET dm_err->eproc = "Validate process type."
      SET dm_err->err_ind = 1
      SET dm_err->emsg =
      'DOMAIN REFRESH is performed only if "TARGET REFRESH" is set to "YES" in response file'
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
     IF (drrr_val_rf_src_cnnct_data(1)=0)
      RETURN(0)
     ENDIF
     IF (drrr_val_rf_tgt_cnnct_data(1)=0)
      RETURN(0)
     ENDIF
     IF (drrr_val_rf_tgt_app_temp_dir(null)=0)
      RETURN(0)
     ENDIF
    OF "DOMAIN REPLICATE":
     IF ((drrr_misc_data->process_type != "REPLICATE"))
      SET dm_err->eproc = "Validate process type."
      SET dm_err->err_ind = 1
      SET dm_err->emsg =
      'DOMAIN REPLICATE is performed only if "TARGET REFRESH" is set to "NO" in response file'
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
     IF ((drrr_rf_data->mode != "ISOLATED"))
      IF (drrr_val_rf_src_cnnct_data(1)=0)
       RETURN(0)
      ENDIF
     ENDIF
     IF (drrr_val_rf_tgt_cnnct_data(1)=0)
      RETURN(0)
     ENDIF
     IF (drrr_val_rf_tgt_app_temp_dir(null)=0)
      RETURN(0)
     ENDIF
    OF "EXPORT/IMPORT SETUP":
    OF "EXPORT/IMPORT CLEANUP":
     IF (drrr_val_rf_src_cnnct_data(1)=0)
      RETURN(0)
     ENDIF
     IF (drrr_val_rf_tgt_sys_cnnct_data(1)=0)
      RETURN(0)
     ENDIF
     IF (drrr_val_rf_tgt_cnnct_data(1)=0)
      RETURN(0)
     ENDIF
    OF "DATABASE SHELL CREATION":
     IF ( NOT ((drrr_rf_data->tgt_db_oracle_ver IN (patstring("11.*"), patstring("12.*"), patstring(
      "19*")))))
      SET dm_err->eproc = "Validate process type."
      SET dm_err->err_ind = 1
      SET dm_err->emsg = "Database shell creation using response file only allowed for Oracle 11+."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
    OF "ADMIN DATABASE CREATION":
    OF "CLINICAL DATABASE CREATION":
     IF (drrr_val_rf_tgt_app_temp_dir(null)=0)
      RETURN(0)
     ENDIF
   ENDCASE
   IF (cnvtupper(dvr_process)="CREATE COPY OF DATABASE")
    IF (drrr_val_rf_tgt_sys_cnnct_data(1)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dvr_process IN ("DATABASE SHELL CREATION", "DOMAIN REFRESH", "DOMAIN REPLICATE",
   "COMPLETE COPY OF DATABASE", "REFRESH V500 USER",
   "CREATE DB ENVIRONMENT", "CLINICAL DATABASE CREATION"))
    IF (drrr_val_rf_tgt_db_user_pwd_mapping(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (cnvtupper(dvr_process) IN ("EXPORT/IMPORT SETUP", "EXPORT/IMPORT CLEANUP"))
    IF (drrr_val_rf_datapump(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Response file data after validation..."
   CALL disp_msg(" ",dm_err->logfile,0)
   CALL echorecord(drrr_rf_data,dm_err->logfile,1)
   CALL echorecord(drrr_misc_data,dm_err->logfile,1)
   IF (drrr_val_email_list(null)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dr_write_log(dwl_mode)
   DECLARE dwl_process_name = vc WITH protect, noconstant("")
   DECLARE dwl_cnt = i4 WITH protect, noconstant(0)
   DECLARE dwl_item_name = vc WITH protect, noconstant("")
   DECLARE dwl_process_item = i4 WITH protect, noconstant(0)
   DECLARE dwl_item = vc WITH protect, noconstant("")
   IF (validate(dm2_rrr_skip_logging,- (1))=1)
    SET dm_err->eproc = "Bypassing call to logging process."
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   IF (((dwl_mode IN ("START", "DETAILS")) OR (dwl_mode="END"
    AND (drrr_misc_data->process_id > 0.0)
    AND (drrr_misc_data->event_id > 0.0))) )
    IF (drrr_val_rf_adm_cnnct_data(1)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dwl_mode="START")
    SET dwl_process_name = cnvtupper(build(drrr_rf_data->client_mnemonic,"_",drrr_rf_data->
      src_env_name,"_TO_",drrr_rf_data->tgt_env_name,
      "_",replace(drrr_rf_data->tgt_capture_schema_date,"-","")))
    IF (dapl_manage_process(trim(dwl_process_name,3),dapl_replicate_refresh,dapl_execution,dapl_no_id
     )=0)
     RETURN(0)
    ENDIF
    SET drrr_misc_data->process_id = dapl_process_rs->process_id
    SET dapl_event_rs->event_name = cnvtupper(drrr_process)
    SET dapl_event_rs->status = dapl_executing
    SET dapl_event_rs->message = ""
    SET dapl_event_rs->begin_dt_tm = drrr_start_dt
    IF (dapl_manage_process_event(drrr_misc_data->process_id,dapl_no_id)=0)
     RETURN(0)
    ENDIF
    SET drrr_misc_data->event_id = dapl_event_rs->event_id
   ELSEIF (dwl_mode="DETAILS")
    IF (drrr_load_rf_data_rs(drrr_resp_file_in,"INITIAL_LOAD")=0)
     RETURN(0)
    ENDIF
    SET dwl_cnt = 0
    FOR (dwl_cnt = 1 TO size(drrr_raw_data->qual,5))
      SET dwl_item_name = cnvtupper(drrr_raw_data->qual[dwl_cnt].itemx)
      IF (substring(1,5,dwl_item_name) != "CLOG_")
       SET dwl_item_name = cnvtupper(build("drrr_rf_data->",drrr_raw_data->qual[dwl_cnt].itemx))
       SET dwl_process_item = 1
       IF ((drrr_raw_data->qual[dwl_cnt].type IN ("STRINGLIST", "STRING")))
        IF (validate(parser(dwl_item_name),"X")="X"
         AND validate(parser(dwl_item_name),"Z")="Z")
         SET dwl_process_item = 0
         IF ((dm_err->debug_flag > 0))
          CALL echo(concat("Record item ",build(dwl_item_name)," not found in structure.  Skipping.")
           )
         ENDIF
        ENDIF
       ELSE
        IF (validate(parser(dwl_item_name),1)=1
         AND validate(parser(dwl_item_name),2)=2)
         SET dwl_process_item = 0
         IF ((dm_err->debug_flag > 0))
          CALL echo(concat("Record item ",build(dwl_item_name)," not found in structure.  Skipping.")
           )
         ENDIF
        ENDIF
       ENDIF
      ENDIF
      IF (((dwl_process_item=1) OR (substring(1,5,dwl_item_name)="CLOG_")) )
       IF (substring((size(dwl_item_name) - 3),4,dwl_item_name) != "_PWD")
        IF (substring((size(dwl_item_name) - 11),12,dwl_item_name) != "_PWD_MAPPING")
         IF (substring(1,5,dwl_item_name)="CLOG_")
          SET dwl_item_name = trim(substring(6,(size(dwl_item_name) - 5),dwl_item_name),3)
         ELSE
          SET dwl_item_name = trim(substring(15,(size(dwl_item_name) - 14),dwl_item_name),3)
         ENDIF
         IF (((substring(1,1,drrr_raw_data->qual[dwl_cnt].item_value)='"') OR (substring(1,1,
          drrr_raw_data->qual[dwl_cnt].item_value)="^")) )
          SET dwl_item = substring(2,(size(drrr_raw_data->qual[dwl_cnt].item_value) - 2),
           drrr_raw_data->qual[dwl_cnt].item_value)
         ELSE
          SET dwl_item = drrr_raw_data->qual[dwl_cnt].item_value
         ENDIF
         IF (dapl_process_add_detail_text(dwl_item_name,dwl_item)=0)
          RETURN(0)
         ENDIF
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
    IF (dapl_manage_process_dtl(drrr_misc_data->process_id)=0)
     RETURN(0)
    ENDIF
   ELSEIF (dwl_mode="END")
    IF ((drrr_misc_data->process_id > 0.0)
     AND (drrr_misc_data->event_id > 0.0))
     SET dapl_event_rs->status = evaluate(drrr_hold_err_ind,1,dapl_failed,dapl_complete)
     SET dapl_event_rs->message = evaluate(drrr_hold_err_ind,1,drrr_hold_emsg,"")
     SET dapl_event_rs->end_dt_tm = cnvtdatetime(curdate,curtime3)
     IF (dapl_manage_process_event(drrr_misc_data->process_id,drrr_misc_data->event_id)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dr_general_sanity_checks(null)
   IF (dcl_check_lang(null)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_version(null)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_client_mnemonic(null)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_mode(null)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_target_refresh(null)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_tgt_db_copy_type(null)=0)
    RETURN(0)
   ENDIF
   IF ((drrr_rf_data->tgt_db_copy_type="ADS"))
    IF (drrr_val_rf_ads(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (drrr_val_rf_deploy_configs(null)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dr_src_sanity_checks(null)
   IF (drrr_val_rf_src_cnnct_data(0)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_src_app_node_list(null)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_src_env_name(null)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_src_domain_name(null)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_src_high_priv_user(null)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_src_db_temp_dir(null)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dr_tgt_sanity_checks(null)
   IF (drrr_val_rf_tgt_db_oracle_misc(null)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_tgt_cnnct_data(0)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_tgt_sys_cnnct_data(0)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_tgt_app_node_list(null)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_tgt_env_name(null)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_tgt_domain_name(null)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_tgt_server_set_names(null)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_tgt_background_runners(null)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_tgt_retain_db_user_list(null)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_tgt_capture_schema_date(null)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_tgt_tspace_increase_pct(null)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_tgt_opsexec_node_mapping(null)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_tgt_expimp_runners(null)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_tgt_db_temp_dir(null)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_tgt_db_node(null)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_tgt_solution_chks(null)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_tgt_apply_src_ed_registry(null)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_tgt_registry_set_name(null)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_tgt_app_prim_temp_dir(null)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_tgt_wh(null)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_tgt_ibus_env_mapping(null)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_tgt_drop_db_links(null)=0)
    RETURN(0)
   ENDIF
   IF (drrr_val_rf_tgt_default_tspaces(null)=0)
    RETURN(0)
   ENDIF
   IF ((drrr_rf_data->target_refresh="YES"))
    IF (drrr_val_rf_tgt_high_priv_user(null)=0)
     RETURN(0)
    ENDIF
    IF (drrr_val_rf_tgt_preserve_data(null)=0)
     RETURN(0)
    ENDIF
    IF (drrr_val_rf_tgt_backup_ccluserdir(null)=0)
     RETURN(0)
    ENDIF
    IF (drrr_val_rf_tgt_backup_warehouse(null)=0)
     RETURN(0)
    ENDIF
    IF (drrr_val_rf_restore_list(null)=0)
     RETURN(0)
    ENDIF
    IF ((drrr_rf_data->tgt_db_copy_type != "ALTERNATE"))
     IF (drrr_val_rf_drop_tablespaces(null)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
#end_program
 IF ((dm_err->debug_flag > 0))
  CALL echorecord(drrr_rf_data)
  CALL echorecord(drrr_misc_data)
 ENDIF
 SET drrr_hold_eproc = dm_err->eproc
 SET drrr_hold_emsg = dm_err->emsg
 SET drrr_hold_err_ind = dm_err->err_ind
 SET drrr_hold_user_action = dm_err->user_action
 SET dm_err->err_ind = 0
 CALL dr_write_log("END")
 IF ((drrr_misc_data->status_dir != "DM2NOTSET"))
  IF (drrr_hold_err_ind=0)
   CALL drrr_add_text("STATUS:SUCCESS",1)
  ELSE
   CALL drrr_add_text("STATUS:FAILED",1)
   CALL drrr_add_text(concat("PROCESS DESCRIPTION:",drrr_hold_eproc),0)
   CALL drrr_add_text(concat("ERROR MESSAGE:",drrr_hold_emsg),0)
  ENDIF
  CALL drrr_create_text_file(concat(drrr_misc_data->status_dir,drrr_misc_data->status_file))
 ELSE
  IF ((dm_err->debug_flag > 0))
   SET dm_err->eproc = concat("Bypass writing to response file status file.")
   CALL disp_msg(" ",dm_err->logfile,0)
  ENDIF
 ENDIF
 SET dm_err->eproc = drrr_hold_eproc
 SET dm_err->emsg = drrr_hold_emsg
 SET dm_err->err_ind = drrr_hold_err_ind
 SET dm_err->user_action = drrr_hold_user_action
 IF ((dm_err->err_ind=0))
  IF ((drer_email_list->email_cnt > 0))
   SET drer_email_det->step = drrr_process
   SET drer_email_det->status = "COMPLETE"
   SET drer_email_det->status_dt_tm = cnvtdatetime(curdate,curtime3)
   SET drer_email_det->email_level = 1
   SET drer_email_det->logfile = dm_err->logfile
   SET drer_email_det->err_ind = dm_err->err_ind
   SET drer_email_det->eproc = dm_err->eproc
   SET drer_email_det->emsg = dm_err->emsg
   SET drer_email_det->user_action = dm_err->user_action
   IF (drer_compose_email(null)=1)
    CALL drer_send_email(drer_email_det->subject,drer_email_det->file_name,drer_email_det->
     email_level)
   ENDIF
   CALL drer_reset_pre_err(null)
  ENDIF
  SET dm_err->eproc = "dm2_rrr has completed"
 ELSE
  IF ((drer_email_list->email_cnt > 0))
   SET drer_email_det->step = drrr_process
   SET drer_email_det->status = "FAILED"
   SET drer_email_det->status_dt_tm = cnvtdatetime(curdate,curtime3)
   SET drer_email_det->email_level = 1
   SET drer_email_det->logfile = dm_err->logfile
   SET drer_email_det->err_ind = dm_err->err_ind
   SET dm_err->err_ind = 0
   SET drer_email_det->eproc = dm_err->eproc
   SET drer_email_det->emsg = dm_err->emsg
   SET drer_email_det->user_action = dm_err->user_action
   SET drer_email_det->component_name = curprog
   IF (drer_compose_email(null)=1)
    CALL drer_send_email(drer_email_det->subject,drer_email_det->file_name,drer_email_det->
     email_level)
   ENDIF
   CALL drer_reset_pre_err(null)
  ENDIF
 ENDIF
 CALL final_disp_msg("dm2_rrr")
 CALL parser("free define oraclesystem go",1)
 CALL echo("*")
 CALL echo("**************************************************************************")
 CALL echo("* DATABASE CONNECTION REMOVED. RE-ENTER CCL TO ESTABLISH NEW CONNECTION. *")
 CALL echo("**************************************************************************")
 CALL echo("*")
END GO
