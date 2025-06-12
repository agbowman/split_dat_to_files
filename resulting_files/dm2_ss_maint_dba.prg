CREATE PROGRAM dm2_ss_maint:dba
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
 FREE RECORD sscm_collector_list
 RECORD sscm_collector_list(
   1 cnt = i4
   1 qual[*]
     2 report_name = vc
     2 report_desc = vc
 )
 FREE RECORD tablespace_list
 RECORD tablespace_list(
   1 cnt = i4
   1 qual[*]
     2 tablespace_name = vc
 )
 FREE RECORD ssrog_environment_list
 RECORD ssrog_environment_list(
   1 cnt = i4
   1 qual[*]
     2 environment_name = vc
     2 environment_id = f8
     2 database_name = vc
 )
 FREE RECORD ssrog_collector_list
 RECORD ssrog_collector_list(
   1 cnt = i4
   1 qual[*]
     2 collector_name = vc
     2 run_date = dq8
     2 report_event_id = f8
 )
 FREE RECORD sscm_collector_info
 RECORD sscm_collector_info(
   1 name = vc
   1 description = vc
   1 id = f8
   1 parm_cnt = i4
   1 parms[*]
     2 parm_value = vc
 )
 FREE RECORD ssrog_report_options
 RECORD ssrog_report_options(
   1 report_event_id = f8
   1 report_name = vc
   1 report_run_date = dq8
   1 environment_name = vc
   1 environment_id = f8
   1 database_name = vc
   1 parm_cnt = i4
   1 parms[*]
     2 parm_value = vc
   1 less_than_x_pct_free = i4
   1 x_away_max_extents = i4
   1 x_away_unable_to_extend = i4
   1 show_flagged_only = vc
   1 collection_parm_cnt = i4
   1 collection_parms[*]
     2 parm_value = vc
 )
 FREE RECORD gssr_files
 RECORD gssr_files(
   1 ts_cnt = i4
   1 ts[*]
     2 tablespace_name = vc
     2 file_cnt = i4
     2 blocks_allocated_sum = f8
     2 blocks_free_sum = f8
     2 num_free_chunks_sum = f8
     2 max_free_chunk_size_max = f8
     2 files[*]
       3 file_id = f8
       3 file_name = vc
       3 autoextensible = vc
       3 blocks_allocated = f8
       3 blocks_free = f8
       3 num_free_chunks = f8
       3 max_free_chunk_size = f8
 )
 FREE RECORD gssr_ts_obj
 RECORD gssr_ts_obj(
   1 flagged_objects = i2
   1 extent_management = vc
   1 object_cnt = i4
   1 objects[*]
     2 flags = vc
     2 object_name = vc
     2 object_type = vc
     2 last_allocated_next_extent = vc
     2 extents_allocated = f8
     2 max_extents = f8
     2 blocks_allocated = f8
     2 num_rows = vc
     2 table_mods = vc
     2 last_analyzed = vc
     2 table_name = vc
 )
 DECLARE dsm_cur_env = vc WITH protect, noconstant("")
 DECLARE dsm_cur_env_id = f8 WITH protect, noconstant(0.0)
 DECLARE dsm_cur_db_name = vc WITH protect, noconstant("")
 DECLARE space_summary_main_menu(null) = i2
 DECLARE compact_parms(record_name=vc) = null
 DECLARE space_summary_collection_maintenance(null) = i2
 DECLARE sscm_prompt_report_name(pr_action=vc) = i2
 DECLARE sscm_prompt_tablespace_criteria(null) = null
 DECLARE sscm_prompt_save(ps_insert_update=vc) = i2
 DECLARE sscm_prompt_description(null) = null
 DECLARE sscm_clear_report_info(null) = null
 DECLARE sscm_clear_screen_and_repopulate(null) = null
 DECLARE sscm_fill_sscm_collector_list(null) = i2
 DECLARE sscm_fill_tablespace_list(null) = i2
 DECLARE sscm_generate_collection_script(report_name=vc,database_password=vc,database_connect_string=
  vc) = i2
 DECLARE space_summary_report_option_gathering(null) = i2
 DECLARE ssrog_clear_report_options(null) = null
 DECLARE ssrog_prompt_tablespace_criteria(null) = null
 DECLARE ssrog_clear_screen_and_repopulate(null) = null
 DECLARE ssrog_fill_env_list(null) = i2
 DECLARE ssrog_prompt_environment(null) = null
 DECLARE ssrog_prompt_collector_name(null) = null
 DECLARE ssrog_fill_collector_list(null) = i2
 DECLARE ssrog_fill_tablespace_list(null) = i2
 DECLARE ssrog_prompt_flag_options(null) = null
 DECLARE generate_space_summary_report(null) = i2
 IF (check_logfile("dm2_ss_maint",".log","DM2_SS_MAINT LOGFILE")=0)
  GO TO exit_script
 ENDIF
 SET message = window
 SET width = 132
 SET accept = nopatcheck
 SET dm_err->eproc = "Selecting current environment information from dm_environment and dm_info."
 SELECT INTO "nl:"
  de.environment_name
  FROM dm_environment de
  WHERE (de.environment_id=
  (SELECT
   di.info_number
   FROM dm_info di
   WHERE di.info_domain="DATA MANAGEMENT"
    AND di.info_name="DM_ENV_ID"
   WITH nocounter))
  DETAIL
   dsm_cur_env = de.environment_name, dsm_cur_env_id = de.environment_id, dsm_cur_db_name = de
   .database_name
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 WHILE (true)
   CALL clear(1,1)
   CALL box(1,1,24,131)
   CALL text(2,2,"Space Summary Main Menu")
   CALL text(4,10,"1. Space Summary Collection")
   CALL text(6,10,"2. View Space Summary Report")
   CALL text(9,10,"Your Selection(0 to Exit)?")
   CALL accept(9,37,"9;",0
    WHERE curaccept IN (0, 1, 2))
   CASE (curaccept)
    OF 0:
     GO TO exit_script
    OF 1:
     IF (space_summary_collection_maintenance(null)=0)
      GO TO exit_script
     ENDIF
    OF 2:
     IF (space_summary_report_option_gathering(null)=0)
      GO TO exit_script
     ENDIF
   ENDCASE
 ENDWHILE
 SUBROUTINE space_summary_collection_maintenance(null)
   DECLARE sscm_width = i4 WITH protect, constant(131)
   DECLARE sscm_height = i4 WITH protect, constant(24)
   DECLARE sscm_top_row = i4 WITH protect, constant(1)
   DECLARE sscm_left_column = i4 WITH protect, constant(1)
   DECLARE sscm_bottom_row = i4 WITH protect, constant(((sscm_top_row+ sscm_height) - 1))
   DECLARE sscm_right_column = i4 WITH protect, constant(((sscm_left_column+ sscm_width) - 1))
   DECLARE sscm_action_bar = vc WITH protect, constant(
    "(C)reate New, (M)odify, (D)elete, (E)xecute, (G)enerate, (Q)uit: ")
   DECLARE sscm_err_msg = vc WITH protect, noconstant(" ")
   IF (sscm_fill_tablespace_list(null)=0)
    RETURN(0)
   ENDIF
   CALL sscm_clear_report_info(null)
   WHILE (true)
     CALL sscm_clear_screen_and_repopulate(null)
     CALL accept((sscm_bottom_row - 3),(((sscm_left_column+ 2)+ size(sscm_action_bar,1))+ 1),"A;CU",
      "Q"
      WHERE curaccept IN ("C", "M", "D", "E", "G",
      "Q"))
     SET sscm_err_msg = " "
     CASE (curaccept)
      OF "C":
       CALL sscm_clear_report_info(null)
       CALL sscm_clear_screen_and_repopulate(null)
       IF (sscm_prompt_report_name("CREATE")=0)
        RETURN(0)
       ENDIF
       IF ((sscm_collector_info->name != ""))
        CALL sscm_prompt_description(null)
        CALL sscm_prompt_tablespace_criteria(null)
        IF (sscm_prompt_save("INSERT")=0)
         RETURN(0)
        ENDIF
       ENDIF
      OF "M":
       IF (sscm_prompt_report_name("MODIFY")=0)
        RETURN(0)
       ENDIF
       IF ( NOT ((sscm_collector_info->name IN ("CERN_SPACE_ALL", ""))))
        CALL sscm_prompt_description(null)
        CALL sscm_prompt_tablespace_criteria(null)
        IF (sscm_prompt_save("UPDATE")=0)
         RETURN(0)
        ENDIF
       ENDIF
      OF "D":
       IF (sscm_prompt_report_name("DELETE")=0)
        RETURN(0)
       ENDIF
       IF ((sscm_collector_info->name="CERN_SPACE_ALL"))
        SET sscm_err_msg = "You cannot delete the collector [CERN_SPACE_ALL]"
       ELSEIF ((sscm_collector_info->name != ""))
        IF (sscm_prompt_delete(null)=0)
         RETURN(0)
        ENDIF
       ENDIF
      OF "E":
       IF (sscm_prompt_report_name("EXECUTE")=0)
        RETURN(0)
       ENDIF
       IF ((sscm_collector_info->name != ""))
        SET sscm_err_msg = "Executing Collector..."
        CALL sscm_clear_screen_and_repopulate(null)
        EXECUTE dm2_space_summary value(sscm_collector_info->name)
        IF ((dm_err->err_ind=1))
         SET sscm_err_msg = concat("Error executing collector: ",build(dm_err->emsg))
         SET dm_err->err_ind = 0
        ELSE
         SET sscm_err_msg = "Collector Executed."
        ENDIF
       ENDIF
       CALL sscm_clear_report_info(null)
       CALL sscm_clear_screen_and_repopulate(null)
      OF "G":
       IF (sscm_prompt_report_name("GENERATE")=0)
        RETURN(0)
       ENDIF
       IF ((sscm_collector_info->name != ""))
        SET dm2_install_schema->u_name = build(currdbuser)
        SET dm2_install_schema->dbase_name = build(currdbname)
        EXECUTE dm2_connect_to_dbase "PO"
        SET message = window
        IF ((dm_err->err_ind=1))
         RETURN(0)
        ENDIF
        IF (sscm_generate_collection_script(sscm_collector_info->name,dm2_install_schema->p_word,
         dm2_install_schema->connect_str)=1)
         IF (((cursys="AXP") OR (cursys="VMS")) )
          SET sscm_err_msg = concat("ccluserdir:",cnvtlower(sscm_collector_info->name),
           ".com has been generated.  ","Use '@ccluserdir:",cnvtlower(sscm_collector_info->name),
           ".com' to execute from the O/S.")
         ELSEIF (cursys="AIX")
          SET sscm_err_msg = concat("ccluserdir:",cnvtlower(sscm_collector_info->name),
           ".ksh has been generated.  ","Use '. $CCLUSERDIR/",cnvtlower(sscm_collector_info->name),
           ".ksh' to execute from the O/S.")
         ENDIF
        ENDIF
       ENDIF
       CALL sscm_clear_report_info(null)
       CALL sscm_clear_screen_and_repopulate(null)
      OF "Q":
       CALL sscm_clear_report_info(null)
       RETURN(1)
     ENDCASE
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE sscm_clear_screen_and_repopulate(null)
   DECLARE scsar_forcount = i4 WITH protect, noconstant(0)
   CALL clear(1,1)
   CALL box(sscm_top_row,sscm_left_column,sscm_bottom_row,sscm_right_column)
   CALL text((sscm_top_row+ 1),(sscm_left_column+ 2),"Space Summary Collection Options")
   CALL text((sscm_top_row+ 1),((sscm_right_column - size(dsm_cur_env,1)) - 23),
    "Current Environment:")
   CALL text((sscm_top_row+ 1),((sscm_right_column - size(dsm_cur_env,1)) - 2),build(dsm_cur_env))
   CALL text((sscm_top_row+ 4),(sscm_left_column+ 2),"Space Summary Collector Name:")
   CALL text((sscm_top_row+ 4),(sscm_left_column+ 33),sscm_collector_info->name)
   CALL text((sscm_top_row+ 6),(sscm_left_column+ 2),"Collector Description:")
   CALL text((sscm_top_row+ 7),(sscm_left_column+ 2),sscm_collector_info->description)
   CALL text((sscm_top_row+ 11),(sscm_left_column+ 2),
    "Tablespace criteria (Selections are OR'd together):")
   FOR (scsar_forcount = 1 TO least(sscm_collector_info->parm_cnt,3))
     CALL text(((sscm_top_row+ 11)+ scsar_forcount),(sscm_left_column+ 2),sscm_collector_info->parms[
      scsar_forcount].parm_value)
   ENDFOR
   FOR (scsar_forcount = 4 TO least(sscm_collector_info->parm_cnt,6))
     CALL text((((sscm_top_row+ 11)+ scsar_forcount) - 3),(sscm_left_column+ 38),sscm_collector_info
      ->parms[scsar_forcount].parm_value)
   ENDFOR
   CALL text((sscm_top_row+ 11),(sscm_right_column - 12),"Examples:")
   CALL text((sscm_top_row+ 12),(sscm_right_column - 12),"D_A_*")
   CALL text((sscm_top_row+ 13),(sscm_right_column - 12),"D_PERSON")
   CALL text((sscm_top_row+ 18),(sscm_left_column+ 2),"Save (Y/N):")
   CALL text((sscm_bottom_row - 3),(sscm_left_column+ 2),sscm_action_bar)
   CALL text((sscm_bottom_row - 1),(sscm_left_column+ 2),sscm_err_msg)
 END ;Subroutine
 SUBROUTINE sscm_clear_report_info(null)
   SET sscm_collector_info->name = " "
   SET sscm_collector_info->description = " "
   SET sscm_collector_info->id = 0.0
   SET sscm_collector_info->parm_cnt = 1
   SET stat = alterlist(sscm_collector_info->parms,sscm_collector_info->parm_cnt)
   SET sscm_collector_info->parms[1].parm_value = "*"
 END ;Subroutine
 SUBROUTINE sscm_prompt_report_name(pr_action)
   SET dm_err->eproc = "Prompting for report name in Space Summary Collection Maintenance."
   DECLARE sprn_accept_string = vc WITH protect, noconstant(" ")
   DECLARE sprn_acceptable_entry = i2 WITH protect, noconstant(0)
   CASE (pr_action)
    OF "CREATE":
     SET sprn_acceptable_entry = 0
     SET sscm_err_msg =
     "Please specify a name with alphanumeric.  Please use underscores instead of spaces."
     CALL sscm_clear_screen_and_repopulate(null)
     WHILE (sprn_acceptable_entry != 1)
       SET sprn_acceptable_entry = 0
       CALL accept((sscm_top_row+ 4),33,"P(20);CU"," ")
       SET sscm_collector_info->name = cnvtupper(replace(trim(curaccept,3)," ","_",0))
       IF ((sscm_collector_info->name=""))
        SET sprn_acceptable_entry = 1
       ENDIF
       IF (cnvtalphanum(sscm_collector_info->name) != replace(sscm_collector_info->name,"_","",0))
        SET sscm_err_msg =
        "Name has invalid characters.  Please uses alphanumerics and underscores only."
        CALL sscm_clear_screen_and_repopulate(null)
        SET sprn_acceptable_entry = 2
       ENDIF
       IF (sprn_acceptable_entry=0)
        SET dm_err->eproc = "Checking if collector name exists in ref_user_report."
        SELECT INTO "nl:"
         rur.report_name
         FROM ref_user_report rur
         WHERE (rur.report_name=sscm_collector_info->name)
          AND rur.report_cd=1
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
        IF (curqual > 0)
         SET sscm_err_msg = "Name already exists.  Please select a new one."
         CALL sscm_clear_screen_and_repopulate(null)
        ELSE
         SET sprn_acceptable_entry = 1
        ENDIF
       ENDIF
     ENDWHILE
     SET sscm_err_msg = " "
    ELSE
     IF (sscm_fill_sscm_collector_list(null)=0)
      RETURN(0)
     ENDIF
     SET help =
     SELECT INTO "nl:"
      ___collector_name___ = sscm_collector_list->qual[d.seq].report_name
      FROM (dummyt d  WITH seq = value(sscm_collector_list->cnt))
      WITH nocounter
     ;end select
     SET sprn_acceptable_entry = 0
     WHILE (sprn_acceptable_entry != 1)
       SET sprn_acceptable_entry = 0
       CALL accept((sscm_top_row+ 4),33,"P(20);CFU"," ")
       SET sscm_collector_info->name = trim(curaccept,3)
       IF ((sscm_collector_info->name IN ("Close Window", "")))
        CALL sscm_clear_report_info(null)
        SET sprn_acceptable_entry = 1
       ELSE
        SET dm_err->eproc = "Checking if collector name exists in ref_user_report."
        SELECT INTO "nl:"
         rur.report_name
         FROM ref_user_report rur
         WHERE rur.report_cd=1
          AND (rur.report_name=sscm_collector_info->name)
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
        IF (curqual > 0)
         SET sprn_acceptable_entry = 1
        ENDIF
       ENDIF
       CALL sscm_clear_screen_and_repopulate(null)
     ENDWHILE
     SET help = off
     SET dm_err->eproc =
     "Getting collector information for selected report from ref_user_report/ref_user_report_parms."
     SELECT INTO "nl:"
      FROM ref_user_report rur,
       ref_user_report_parms rurp
      WHERE rur.report_id=rurp.report_id
       AND rur.report_cd=1
       AND (rur.report_name=sscm_collector_info->name)
      ORDER BY rur.report_name, rurp.parm_seq
      HEAD rur.report_name
       sscm_collector_info->parm_cnt = 0, sscm_collector_info->name = rur.report_name,
       sscm_collector_info->description = rur.report_desc,
       sscm_collector_info->id = rur.report_id
      DETAIL
       sscm_collector_info->parm_cnt = (sscm_collector_info->parm_cnt+ 1), stat = alterlist(
        sscm_collector_info->parms,sscm_collector_info->parm_cnt), sscm_collector_info->parms[
       sscm_collector_info->parm_cnt].parm_value = rurp.parm_value
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
   ENDCASE
   CALL sscm_clear_screen_and_repopulate(null)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE sscm_prompt_description(null)
   CALL accept((sscm_top_row+ 7),(sscm_left_column+ 2),"P(80);C",sscm_collector_info->description)
   SET sscm_collector_info->description = curaccept
   CALL sscm_clear_screen_and_repopulate(null)
 END ;Subroutine
 SUBROUTINE sscm_prompt_tablespace_criteria(null)
   DECLARE sptc_forcount = i4 WITH protect, noconstant(0)
   DECLARE sptc_temp_str = vc WITH protect, noconstant("")
   DECLARE sptc_acceptable_entry = i4 WITH protect, noconstant(0)
   SET help =
   SELECT INTO "nl:"
    __________tablespace__________ = tablespace_list->qual[d.seq].tablespace_name
    FROM (dummyt d  WITH seq = value(tablespace_list->cnt))
    WITH nocounter
   ;end select
   FOR (sptc_forcount = 1 TO 6)
     SET sptc_acceptable_entry = 0
     WHILE (sptc_acceptable_entry != 1)
       IF (sptc_forcount IN (1, 2, 3))
        IF ((sptc_forcount > sscm_collector_info->parm_cnt))
         CALL accept(((sscm_top_row+ 11)+ sptc_forcount),(sscm_left_column+ 2),"P(30);CU"," ")
        ELSE
         CALL accept(((sscm_top_row+ 11)+ sptc_forcount),(sscm_left_column+ 2),"P(30);CU",
          sscm_collector_info->parms[sptc_forcount].parm_value)
        ENDIF
       ELSE
        IF ((sptc_forcount > sscm_collector_info->parm_cnt))
         CALL accept((((sscm_top_row+ 11)+ sptc_forcount) - 3),(sscm_left_column+ 38),"P(30);CU"," ")
        ELSE
         CALL accept((((sscm_top_row+ 11)+ sptc_forcount) - 3),(sscm_left_column+ 38),"P(30);CU",
          sscm_collector_info->parms[sptc_forcount].parm_value)
        ENDIF
       ENDIF
       SET sptc_temp_str = trim(curaccept,3)
       IF (sptc_temp_str != "Close Window")
        SET sptc_acceptable_entry = 1
       ENDIF
     ENDWHILE
     IF (sptc_temp_str="")
      IF ((sptc_forcount > sscm_collector_info->parm_cnt))
       SET help = off
       RETURN
      ELSEIF ((sptc_forcount=sscm_collector_info->parm_cnt))
       SET sscm_collector_info->parm_cnt = (sscm_collector_info->parm_cnt - 1)
       SET stat = alterlist(sscm_collector_info->parms,sscm_collector_info->parm_cnt)
       IF ((sscm_collector_info->parm_cnt=0))
        SET sscm_collector_info->parm_cnt = 1
        SET stat = alterlist(sscm_collector_info->parms,sscm_collector_info->parm_cnt)
        SET sscm_collector_info->parms[1].parm_value = "*"
       ENDIF
       CALL sscm_clear_screen_and_repopulate(null)
       SET help = off
       RETURN
      ELSE
       SET sscm_collector_info->parms[sptc_forcount].parm_value = ""
       CALL compact_parms("sscm_collector_info")
       SET sptc_forcount = (sptc_forcount - 1)
      ENDIF
     ELSE
      IF ((sptc_forcount > sscm_collector_info->parm_cnt))
       SET sscm_collector_info->parm_cnt = (sscm_collector_info->parm_cnt+ 1)
       SET stat = alterlist(sscm_collector_info->parms,sscm_collector_info->parm_cnt)
      ENDIF
      SET sscm_collector_info->parms[sptc_forcount].parm_value = replace(sptc_temp_str,"%","*",0)
     ENDIF
     CALL sscm_clear_screen_and_repopulate(null)
   ENDFOR
   SET help = off
 END ;Subroutine
 SUBROUTINE sscm_prompt_save(ps_insert_update)
   CALL accept((sscm_top_row+ 18),(sscm_left_column+ 14),"A;CU"
    WHERE curaccept IN ("Y", "N"))
   CASE (curaccept)
    OF "Y":
     CASE (ps_insert_update)
      OF "INSERT":
       SET dm_err->eproc = "Inserting new collector into ref_user_report."
       INSERT  FROM ref_user_report rur
        SET rur.report_id = seq(report_sequence,nextval), rur.report_name = sscm_collector_info->name,
         rur.report_desc = sscm_collector_info->description,
         rur.report_cd = 1, rur.updt_id = reqinfo->updt_id, rur.updt_dt_tm = cnvtdatetime(curdate,
          curtime3),
         rur.updt_task = reqinfo->updt_task, rur.updt_applctx = reqinfo->updt_applctx, rur.updt_cnt
          = 0
        WITH nocounter
       ;end insert
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        RETURN(0)
       ENDIF
       SET dm_err->eproc = "Inserting new collector parms into ref_user_report_parms."
       INSERT  FROM ref_user_report_parms rurp,
         (dummyt d  WITH seq = value(sscm_collector_info->parm_cnt))
        SET rurp.report_parms_id = seq(report_sequence,nextval), rurp.report_id =
         (SELECT INTO "nl:"
          rur.report_id
          FROM ref_user_report rur
          WHERE (rur.report_name=sscm_collector_info->name)
           AND rur.report_cd=1
          WITH nocounter), rurp.parm_cd = 3,
         rurp.parm_seq = d.seq, rurp.parm_value = sscm_collector_info->parms[d.seq].parm_value, rurp
         .updt_id = reqinfo->updt_id,
         rurp.updt_dt_tm = cnvtdatetime(curdate,curtime3), rurp.updt_task = reqinfo->updt_task, rurp
         .updt_applctx = reqinfo->updt_applctx,
         rurp.updt_cnt = 0
        PLAN (d)
         JOIN (rurp)
        WITH nocounter
       ;end insert
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        RETURN(0)
       ENDIF
      OF "UPDATE":
       SET dm_err->eproc = "Updating collector in ref_user_report."
       UPDATE  FROM ref_user_report rur
        SET rur.report_name = sscm_collector_info->name, rur.report_desc = sscm_collector_info->
         description, rur.report_cd = 1,
         rur.updt_id = reqinfo->updt_id, rur.updt_dt_tm = cnvtdatetime(curdate,curtime3), rur
         .updt_task = reqinfo->updt_task,
         rur.updt_applctx = reqinfo->updt_applctx, rur.updt_cnt = (rur.updt_cnt+ 1)
        WHERE (rur.report_id=sscm_collector_info->id)
        WITH nocounter
       ;end update
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        RETURN(0)
       ENDIF
       SET dm_err->eproc = "Deleting collectors old parms from ref_user_report_parms."
       DELETE  FROM ref_user_report_parms rurp
        WHERE (rurp.report_id=sscm_collector_info->id)
        WITH nocounter
       ;end delete
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        RETURN(0)
       ENDIF
       SET dm_err->eproc = "Inserting collectors new parms into ref_user_report_parms."
       INSERT  FROM ref_user_report_parms rurp,
         (dummyt d  WITH seq = value(sscm_collector_info->parm_cnt))
        SET rurp.report_parms_id = seq(report_sequence,nextval), rurp.report_id = sscm_collector_info
         ->id, rurp.parm_cd = 3,
         rurp.parm_seq = d.seq, rurp.parm_value = sscm_collector_info->parms[d.seq].parm_value, rurp
         .updt_id = reqinfo->updt_id,
         rurp.updt_dt_tm = cnvtdatetime(curdate,curtime3), rurp.updt_task = reqinfo->updt_task, rurp
         .updt_applctx = reqinfo->updt_applctx,
         rurp.updt_cnt = 0
        PLAN (d)
         JOIN (rurp)
        WITH nocounter
       ;end insert
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        RETURN(0)
       ENDIF
     ENDCASE
   ENDCASE
   COMMIT
   CALL sscm_clear_report_info(null)
   CALL sscm_clear_screen_and_repopulate(null)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE sscm_prompt_delete(null)
   SET dm_err->eproc = "Prompting for delete."
   SET sscm_err_msg = "Are you sure you want to delete the collector (Y/N)?"
   CALL sscm_clear_screen_and_repopulate(null)
   CALL accept((sscm_bottom_row - 1),(sscm_left_column+ 55),"A;CU"
    WHERE curaccept IN ("Y", "N"))
   SET sscm_err_msg = " "
   CASE (curaccept)
    OF "Y":
     SET dm_err->eproc = "Deleting collector parms from ref_user_report_parms."
     DELETE  FROM ref_user_report_parms rurp
      WHERE (rurp.report_id=sscm_collector_info->id)
      WITH nocounter
     ;end delete
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN(0)
     ENDIF
     SET dm_err->eproc = "Deleting collector from ref_user_report."
     DELETE  FROM ref_user_report rur
      WHERE (rur.report_id=sscm_collector_info->id)
      WITH nocounter
     ;end delete
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN(0)
     ENDIF
     SET dm_err->eproc = "Deleting files previously generated for collector."
     IF (((cursys="AXP") OR (cursys="VMS")) )
      SET stat = remove(build(cnvtlower(sscm_collector_info->name),".com;*"))
     ELSEIF (cursys="AIX")
      SET stat = remove(build(cnvtlower(sscm_collector_info->name),".ksh"))
     ENDIF
     SET sscm_err_msg = concat("The collector ",sscm_collector_info->name,
      ", and any generated files for it were deleted from CCLUSERDIR.")
   ENDCASE
   COMMIT
   CALL sscm_clear_report_info(null)
   CALL sscm_clear_screen_and_repopulate(null)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE sscm_fill_sscm_collector_list(null)
   SET dm_err->eproc = "Selecting collector names from ref_user_report."
   SELECT INTO "nl:"
    FROM ref_user_report rur
    WHERE rur.report_cd=1
    ORDER BY rur.report_name
    HEAD REPORT
     sscm_collector_list->cnt = 1, stat = alterlist(sscm_collector_list->qual,sscm_collector_list->
      cnt), sscm_collector_list->qual[1].report_name = "Close Window"
    DETAIL
     sscm_collector_list->cnt = (sscm_collector_list->cnt+ 1), stat = alterlist(sscm_collector_list->
      qual,sscm_collector_list->cnt), sscm_collector_list->qual[sscm_collector_list->cnt].report_name
      = cnvtupper(rur.report_name),
     sscm_collector_list->qual[sscm_collector_list->cnt].report_desc = cnvtupper(rur.report_desc)
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE sscm_fill_tablespace_list(null)
   SET dm_err->eproc = "Selecting tablespaces from dba_tablespaces."
   SELECT INTO "nl:"
    FROM dba_tablespaces dt
    ORDER BY dt.tablespace_name
    HEAD REPORT
     tablespace_list->cnt = 1, stat = alterlist(tablespace_list->qual,tablespace_list->cnt),
     tablespace_list->qual[1].tablespace_name = "Close Window"
    DETAIL
     tablespace_list->cnt = (tablespace_list->cnt+ 1), stat = alterlist(tablespace_list->qual,
      tablespace_list->cnt), tablespace_list->qual[tablespace_list->cnt].tablespace_name = dt
     .tablespace_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE space_summary_report_option_gathering(null)
   DECLARE ssrog_width = i4 WITH protect, constant(131)
   DECLARE ssrog_height = i4 WITH protect, constant(24)
   DECLARE ssrog_top_row = i4 WITH protect, constant(1)
   DECLARE ssrog_left_column = i4 WITH protect, constant(1)
   DECLARE ssrog_bottom_row = i4 WITH protect, constant(((ssrog_top_row+ ssrog_height) - 1))
   DECLARE ssrog_right_column = i4 WITH protect, constant(((ssrog_left_column+ ssrog_width) - 1))
   DECLARE ssrog_action_bar = vc WITH protect, constant("(C)ontinue, (M)odify, (Q)uit:")
   DECLARE ssrog_err_msg = vc WITH protect, noconstant(" ")
   DECLARE ssrog_locateval = i4 WITH protect, noconstant(0)
   DECLARE ssrog_locateval_temp = i4 WITH protect, noconstant(0)
   DECLARE ssrog_newest_report_name = vc WITH protect, noconstant("")
   DECLARE ssrog_newest_report_date = dq8 WITH protect
   DECLARE ssrog_newest_report_event_id = f8 WITH protect, noconstant(0.0)
   DECLARE ssrog_temp_collector_name = vc WITH protect, noconstant("")
   DECLARE ssrog_temp_env_name = vc WITH protect, noconstant("")
   DECLARE ssrog_menu_driver = i2 WITH protect, noconstant(0)
   CALL ssrog_clear_report_options(null)
   SET ssrog_err_msg = " "
   IF (ssrog_fill_env_list(null)=0)
    RETURN(0)
   ENDIF
   IF ((ssrog_environment_list->cnt=0))
    SET ssrog_err_msg = "You do not have any collectors.  You will be returned to the previous menu."
    CALL ssrog_clear_screen_and_repopulate(null)
    CALL pause(8)
    RETURN(1)
   ENDIF
   SET ssrog_report_options->environment_name = dsm_cur_env
   SET ssrog_report_options->environment_id = dsm_cur_env_id
   SET ssrog_report_options->database_name = dsm_cur_db_name
   IF (ssrog_fill_collector_list(null)=0)
    RETURN(0)
   ENDIF
   IF ((ssrog_collector_list->cnt=0))
    SET ssrog_err_msg = concat("No Space Summaries for the current environment_name.  ",
     "Press <Shift><F5> for help list of environments with Space Summary reports.")
   ELSE
    SET ssrog_report_options->report_event_id = ssrog_newest_report_event_id
    SET ssrog_report_options->report_name = ssrog_newest_report_name
    SET ssrog_report_options->report_run_date = ssrog_newest_report_date
   ENDIF
   CALL ssrog_clear_screen_and_repopulate(null)
   WHILE (true)
     CALL ssrog_prompt_environment(null)
     IF (ssrog_fill_collector_list(null)=0)
      RETURN(0)
     ENDIF
     SET ssrog_report_options->report_event_id = ssrog_newest_report_event_id
     SET ssrog_report_options->report_name = ssrog_newest_report_name
     SET ssrog_report_options->report_run_date = ssrog_newest_report_date
     CALL ssrog_clear_screen_and_repopulate(null)
     IF (ssrog_prompt_collector_name(null)=0)
      RETURN(0)
     ENDIF
     IF (ssrog_fill_tablespace_list(null)=0)
      RETURN(0)
     ENDIF
     CALL ssrog_prompt_tablespace_criteria(null)
     CALL ssrog_prompt_flag_options(null)
     SET ssrog_menu_driver = 1
     WHILE (ssrog_menu_driver=1)
       CALL accept((ssrog_bottom_row - 3),((ssrog_left_column+ 3)+ size(ssrog_action_bar,1)),"A;CU",
        "Q"
        WHERE curaccept IN ("C", "M", "Q"))
       SET ssrog_err_msg = " "
       CALL ssrog_clear_screen_and_repopulate(null)
       CASE (curaccept)
        OF "C":
         SET ssrog_err_msg = "Generating report..."
         CALL ssrog_clear_screen_and_repopulate(null)
         IF (generate_space_summary_report(null)=0)
          RETURN(0)
         ENDIF
         SET ssrog_err_msg = " "
         CALL ssrog_clear_screen_and_repopulate(null)
        OF "Q":
         CALL ssrog_clear_report_options(null)
         RETURN(1)
        OF "M":
         SET ssrog_menu_driver = 0
       ENDCASE
     ENDWHILE
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ssrog_clear_screen_and_repopulate(null)
   DECLARE scsar_forcount = i4 WITH protect, noconstant(0)
   CALL clear(1,1)
   CALL box(ssrog_top_row,ssrog_left_column,ssrog_bottom_row,ssrog_right_column)
   CALL text((ssrog_top_row+ 1),(ssrog_left_column+ 2),"Space Summary Report Options")
   CALL text((ssrog_top_row+ 4),(ssrog_left_column+ 2),"Select Environment:")
   CALL text((ssrog_top_row+ 7),(ssrog_left_column+ 2),"Select Collector Name:")
   CALL text((ssrog_top_row+ 9),(ssrog_left_column+ 2),"Tablespaces:")
   CALL video(u)
   CALL text((ssrog_top_row+ 15),(ssrog_left_column+ 2),"Flag Options:")
   CALL text((ssrog_top_row+ 3),(ssrog_left_column+ 23),"Environment Name")
   CALL text((ssrog_top_row+ 3),(ssrog_left_column+ 44),"Database Name")
   CALL text((ssrog_top_row+ 6),(ssrog_left_column+ 26),"Collector Name")
   CALL text((ssrog_top_row+ 6),(ssrog_left_column+ 47),"Date")
   CALL video(n)
   CALL text((ssrog_top_row+ 15),(ssrog_left_column+ 2),"Flag Tablespaces Less Than ___% Free")
   CALL text((ssrog_top_row+ 16),(ssrog_left_column+ 2),
    "Flag Objects __ Extents Away from Reaching Max Extents")
   CALL text((ssrog_top_row+ 17),(ssrog_left_column+ 2),"Only Show Flagged Objects (Y/N)? _")
   CALL text((ssrog_top_row+ 4),(ssrog_left_column+ 23),ssrog_report_options->environment_name)
   CALL text((ssrog_top_row+ 4),(ssrog_left_column+ 44),ssrog_report_options->database_name)
   CALL text((ssrog_top_row+ 7),(ssrog_left_column+ 26),ssrog_report_options->report_name)
   CALL text((ssrog_top_row+ 7),(ssrog_left_column+ 47),format(ssrog_report_options->report_run_date,
     "MM/DD/YYYY HH:MM;;Q"))
   FOR (scsar_forcount = 1 TO least(ssrog_report_options->parm_cnt,3))
     CALL text(((ssrog_top_row+ 9)+ scsar_forcount),(ssrog_left_column+ 2),ssrog_report_options->
      parms[scsar_forcount].parm_value)
   ENDFOR
   FOR (scsar_forcount = 4 TO least(ssrog_report_options->parm_cnt,6))
     CALL text((((ssrog_top_row+ 9)+ scsar_forcount) - 3),(ssrog_left_column+ 38),
      ssrog_report_options->parms[scsar_forcount].parm_value)
   ENDFOR
   CALL text((ssrog_top_row+ 15),(ssrog_left_column+ 29),cnvtstring(ssrog_report_options->
     less_than_x_pct_free,3))
   CALL text((ssrog_top_row+ 16),(ssrog_left_column+ 15),cnvtstring(ssrog_report_options->
     x_away_max_extents,2))
   CALL text((ssrog_top_row+ 17),(ssrog_left_column+ 35),ssrog_report_options->show_flagged_only)
   CALL text((ssrog_bottom_row - 3),(ssrog_left_column+ 2),ssrog_action_bar)
   CALL text((ssrog_bottom_row - 1),(ssrog_left_column+ 2),ssrog_err_msg)
 END ;Subroutine
 SUBROUTINE ssrog_clear_report_options(null)
   SET ssrog_report_options->environment_name = " "
   SET ssrog_report_options->environment_id = 0.0
   SET ssrog_report_options->database_name = " "
   SET ssrog_report_options->report_event_id = 0.0
   SET ssrog_report_options->report_name = " "
   SET ssrog_report_options->report_run_date = null
   SET ssrog_report_options->parm_cnt = 1
   SET stat = alterlist(ssrog_report_options->parms,ssrog_report_options->parm_cnt)
   SET ssrog_report_options->parms[1].parm_value = "*"
   SET ssrog_report_options->less_than_x_pct_free = 10
   SET ssrog_report_options->x_away_max_extents = 5
   SET ssrog_report_options->show_flagged_only = "N"
 END ;Subroutine
 SUBROUTINE ssrog_prompt_environment(null)
   DECLARE spe_acceptable_entry = i2 WITH protect, noconstant(0)
   SET help =
   SELECT INTO "nl:"
    _______environment_name_______ = ssrog_environment_list->qual[d.seq].environment_name,
    database_name = ssrog_environment_list->qual[d.seq].database_name
    FROM (dummyt d  WITH seq = value(ssrog_environment_list->cnt))
    WITH nocounter
   ;end select
   WHILE (spe_acceptable_entry != 1)
     CALL ssrog_clear_screen_and_repopulate(null)
     CALL accept((ssrog_top_row+ 4),(ssrog_left_column+ 23),"P(20);CU",ssrog_report_options->
      environment_name)
     SET ssrog_temp_env_name = trim(curaccept,3)
     SET ssrog_locateval = 0
     SET ssrog_locateval = locateval(ssrog_locateval_temp,1,ssrog_environment_list->cnt,
      ssrog_temp_env_name,ssrog_environment_list->qual[ssrog_locateval_temp].environment_name)
     IF (ssrog_locateval > 0)
      SET ssrog_report_options->environment_name = ssrog_temp_env_name
      SET ssrog_report_options->database_name = ssrog_environment_list->qual[ssrog_locateval].
      database_name
      SET ssrog_report_options->environment_id = ssrog_environment_list->qual[ssrog_locateval].
      environment_id
      SET spe_acceptable_entry = 1
      SET ssrog_err_msg = " "
     ELSE
      SET ssrog_err_msg = concat(
       "That environment is either an invalid name or collectors do not exist for it.  ",
       "Press <Shift><F5> for help list of environments.")
     ENDIF
   ENDWHILE
   SET help = off
 END ;Subroutine
 SUBROUTINE ssrog_prompt_collector_name(null)
   DECLARE spcn_acceptable_entry = i2 WITH protect, noconstant(0)
   SET help =
   SELECT INTO "nl:"
    ___collector_name___ = ssrog_collector_list->qual[d.seq].collector_name, ___run_date___ = format(
     ssrog_collector_list->qual[d.seq].run_date,"MM/DD/YY HH:MM;;Q")
    FROM (dummyt d  WITH seq = value(ssrog_collector_list->cnt))
    WITH nocounter
   ;end select
   WHILE (spcn_acceptable_entry != 1)
     CALL ssrog_clear_screen_and_repopulate(null)
     SET curhelp = 0
     CALL accept((ssrog_top_row+ 7),(ssrog_left_column+ 26),"P(20);CU",ssrog_newest_report_name)
     SET ssrog_help = curhelp
     IF (ssrog_help != 0)
      SET ssrog_report_options->report_name = ssrog_collector_list->qual[ssrog_help].collector_name
      SET ssrog_report_options->report_event_id = ssrog_collector_list->qual[ssrog_help].
      report_event_id
      SET ssrog_report_options->report_run_date = ssrog_collector_list->qual[ssrog_help].run_date
      SET spcn_acceptable_entry = 1
      SET ssrog_err_msg = " "
     ELSE
      SET ssrog_temp_collector_name = trim(curaccept,3)
      SET ssrog_locateval = 0
      SET ssrog_locateval = locateval(ssrog_locateval_temp,1,ssrog_collector_list->cnt,
       ssrog_temp_collector_name,ssrog_collector_list->qual[ssrog_locateval_temp].collector_name)
      IF (ssrog_locateval > 0)
       SET ssrog_report_options->report_name = ssrog_collector_list->qual[ssrog_locateval].
       collector_name
       SET ssrog_report_options->report_event_id = ssrog_collector_list->qual[ssrog_locateval].
       report_event_id
       SET ssrog_report_options->report_run_date = ssrog_collector_list->qual[ssrog_locateval].
       run_date
       SET spcn_acceptable_entry = 1
       SET ssrog_err_msg = " "
      ELSE
       SET ssrog_err_msg = concat("That is not a valid collector name.  ",
        "Press <Shift><F5> for help list of collectors for selected environment.")
      ENDIF
     ENDIF
   ENDWHILE
   CALL ssrog_clear_screen_and_repopulate(null)
   SET help = off
 END ;Subroutine
 SUBROUTINE ssrog_prompt_tablespace_criteria(null)
   DECLARE sptc_forcount = i4 WITH protect, noconstant(0)
   DECLARE sptc_temp_str = vc WITH protect, noconstant("")
   DECLARE sptc_acceptable_entry = i4 WITH protect, noconstant(0)
   SET help =
   SELECT INTO "nl:"
    __________tablespace__________ = tablespace_list->qual[d.seq].tablespace_name
    FROM (dummyt d  WITH seq = value(tablespace_list->cnt))
    WITH nocounter
   ;end select
   FOR (sptc_forcount = 1 TO 6)
     SET sptc_acceptable_entry = 0
     WHILE (sptc_acceptable_entry != 1)
       IF (sptc_forcount IN (1, 2, 3))
        IF ((sptc_forcount > ssrog_report_options->parm_cnt))
         CALL accept(((ssrog_top_row+ 9)+ sptc_forcount),(ssrog_left_column+ 2),"P(30);CU"," ")
        ELSE
         CALL accept(((ssrog_top_row+ 9)+ sptc_forcount),(ssrog_left_column+ 2),"P(30);CU",
          ssrog_report_options->parms[sptc_forcount].parm_value)
        ENDIF
       ELSE
        IF ((sptc_forcount > ssrog_report_options->parm_cnt))
         CALL accept((((ssrog_top_row+ 9)+ sptc_forcount) - 3),(ssrog_left_column+ 38),"P(30);CU"," "
          )
        ELSE
         CALL accept((((ssrog_top_row+ 9)+ sptc_forcount) - 3),(ssrog_left_column+ 38),"P(30);CU",
          ssrog_report_options->parms[sptc_forcount].parm_value)
        ENDIF
       ENDIF
       SET sptc_temp_str = trim(curaccept,3)
       IF (sptc_temp_str != "Close Window")
        SET sptc_acceptable_entry = 1
       ENDIF
     ENDWHILE
     IF (sptc_temp_str="")
      IF ((sptc_forcount > ssrog_report_options->parm_cnt))
       SET help = off
       RETURN
      ELSEIF ((sptc_forcount=ssrog_report_options->parm_cnt))
       SET ssrog_report_options->parm_cnt = (ssrog_report_options->parm_cnt - 1)
       SET stat = alterlist(ssrog_report_options->parms,ssrog_report_options->parm_cnt)
       IF ((ssrog_report_options->parm_cnt=0))
        SET ssrog_report_options->parm_cnt = 1
        SET stat = alterlist(ssrog_report_options->parms,ssrog_report_options->parm_cnt)
        SET ssrog_report_options->parms[1].parm_value = "*"
       ENDIF
       CALL ssrog_clear_screen_and_repopulate(null)
       SET help = off
       RETURN
      ELSE
       SET ssrog_report_options->parms[sptc_forcount].parm_value = ""
       CALL compact_parms("ssrog_report_options")
       SET sptc_forcount = (sptc_forcount - 1)
      ENDIF
     ELSE
      IF ((sptc_forcount > ssrog_report_options->parm_cnt))
       SET ssrog_report_options->parm_cnt = (ssrog_report_options->parm_cnt+ 1)
       SET stat = alterlist(ssrog_report_options->parms,ssrog_report_options->parm_cnt)
      ENDIF
      SET ssrog_report_options->parms[sptc_forcount].parm_value = replace(sptc_temp_str,"%","*",0)
     ENDIF
     CALL ssrog_clear_screen_and_repopulate(null)
   ENDFOR
   SET help = off
 END ;Subroutine
 SUBROUTINE ssrog_prompt_flag_options(null)
   CALL accept((ssrog_top_row+ 15),(ssrog_left_column+ 29),"999",ssrog_report_options->
    less_than_x_pct_free
    WHERE curaccept BETWEEN 0 AND 100)
   SET ssrog_report_options->less_than_x_pct_free = curaccept
   CALL ssrog_clear_screen_and_repopulate(null)
   CALL accept((ssrog_top_row+ 16),(ssrog_left_column+ 15),"99",ssrog_report_options->
    x_away_max_extents)
   SET ssrog_report_options->x_away_max_extents = curaccept
   CALL ssrog_clear_screen_and_repopulate(null)
   CALL accept((ssrog_top_row+ 17),(ssrog_left_column+ 35),"A;CU",ssrog_report_options->
    show_flagged_only
    WHERE curaccept IN ("Y", "N"))
   SET ssrog_report_options->show_flagged_only = curaccept
   CALL ssrog_clear_screen_and_repopulate(null)
 END ;Subroutine
 SUBROUTINE ssrog_fill_env_list(null)
   SET ssrog_environment_list->cnt = 0
   SET stat = alterlist(ssrog_environment_list->qual,ssrog_environment_list->cnt)
   SET dm_err->eproc =
   "Selecting collectors from all environments from dm_environment/ref_report_event."
   SELECT INTO "nl:"
    FROM dm_environment de
    WHERE de.environment_id IN (
    (SELECT INTO "nl:"
     rre.environment_id
     FROM ref_report_event rre
     WHERE rre.report_cd=1
      AND rre.status="COMPLETE"
     WITH nocounter))
    ORDER BY de.environment_name
    DETAIL
     ssrog_environment_list->cnt = (ssrog_environment_list->cnt+ 1), stat = alterlist(
      ssrog_environment_list->qual,ssrog_environment_list->cnt), ssrog_environment_list->qual[
     ssrog_environment_list->cnt].environment_name = de.environment_name,
     ssrog_environment_list->qual[ssrog_environment_list->cnt].environment_id = de.environment_id,
     ssrog_environment_list->qual[ssrog_environment_list->cnt].database_name = de.database_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ssrog_fill_collector_list(null)
   SET ssrog_collector_list->cnt = 0
   SET stat = alterlist(ssrog_collector_list->qual,ssrog_collector_list->cnt)
   SET dm_err->eproc = "Selecting collectors for chosen environment from ref_report_event."
   SELECT INTO "nl:"
    FROM ref_report_event rre
    WHERE (rre.environment_id=ssrog_report_options->environment_id)
     AND rre.report_cd=1
     AND rre.status="COMPLETE"
    ORDER BY rre.report_name, rre.end_dt_tm DESC
    DETAIL
     ssrog_collector_list->cnt = (ssrog_collector_list->cnt+ 1), stat = alterlist(
      ssrog_collector_list->qual,ssrog_collector_list->cnt), ssrog_collector_list->qual[
     ssrog_collector_list->cnt].collector_name = rre.report_name,
     ssrog_collector_list->qual[ssrog_collector_list->cnt].run_date = rre.end_dt_tm,
     ssrog_collector_list->qual[ssrog_collector_list->cnt].report_event_id = rre.report_event_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Selecting newest collector for chosen environment from ref_report_event."
   SELECT INTO "nl:"
    FROM ref_report_event rre
    WHERE (rre.environment_id=ssrog_report_options->environment_id)
     AND rre.report_cd=1
     AND rre.status="COMPLETE"
    ORDER BY rre.end_dt_tm DESC
    HEAD REPORT
     ssrog_newest_report_name = rre.report_name, ssrog_newest_report_date = rre.end_dt_tm,
     ssrog_newest_report_event_id = rre.report_event_id,
     CALL cancel(1)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ssrog_fill_tablespace_list(null)
   SET dm_err->eproc = "Selecting tablespaces for chosen collector from space_tablespaces."
   SELECT INTO "nl:"
    FROM space_tablespaces st
    WHERE (st.report_event_id=ssrog_report_options->report_event_id)
    ORDER BY st.tablespace_name
    HEAD REPORT
     tablespace_list->cnt = 1, stat = alterlist(tablespace_list->qual,tablespace_list->cnt),
     tablespace_list->qual[1].tablespace_name = "Close Window"
    DETAIL
     tablespace_list->cnt = (tablespace_list->cnt+ 1), stat = alterlist(tablespace_list->qual,
      tablespace_list->cnt), tablespace_list->qual[tablespace_list->cnt].tablespace_name = st
     .tablespace_name
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE generate_space_summary_report(null)
   DECLARE gssr_forcount = i4 WITH protect, noconstant(0)
   DECLARE gssr_where_clause = vc WITH protect, noconstant("")
   DECLARE gssr_locateval = i4 WITH protect, noconstant(0)
   DECLARE gssr_locateval_temp = i4 WITH protect, noconstant(0)
   DECLARE gssr_report_destination = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Selecting collection tablespace criteria from ref_report_event_parms."
   SELECT INTO "nl:"
    FROM ref_report_event_parms rrep
    WHERE (rrep.report_event_id=ssrog_report_options->report_event_id)
    ORDER BY rrep.parm_seq
    HEAD REPORT
     ssrog_report_options->collection_parm_cnt = 0, stat = alterlist(ssrog_report_options->
      collection_parms,ssrog_report_options->collection_parm_cnt)
    DETAIL
     ssrog_report_options->collection_parm_cnt = (ssrog_report_options->collection_parm_cnt+ 1), stat
      = alterlist(ssrog_report_options->collection_parms,ssrog_report_options->collection_parm_cnt),
     ssrog_report_options->collection_parms[ssrog_report_options->collection_parm_cnt].parm_value =
     rrep.parm_value
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET gssr_where_clause = build("(sf.tablespace_name = patstring('",ssrog_report_options->parms[1].
    parm_value,"')")
   FOR (gssr_forcount = 2 TO ssrog_report_options->parm_cnt)
     SET gssr_where_clause = concat(gssr_where_clause," OR sf.tablespace_name = patstring('",build(
       ssrog_report_options->parms[gssr_forcount].parm_value),"')")
   ENDFOR
   SET gssr_where_clause = build(gssr_where_clause,")")
   SET dm_err->eproc = "Selecting data from space_files for report generation."
   SELECT INTO "nl:"
    FROM space_files sf
    WHERE (sf.report_seq=ssrog_report_options->report_event_id)
     AND parser(gssr_where_clause)
    ORDER BY sf.tablespace_name, sf.file_id
    HEAD REPORT
     gssr_files->ts_cnt = 0, stat = alterlist(gssr_files->ts,gssr_files->ts_cnt)
    HEAD sf.tablespace_name
     gssr_files->ts_cnt = (gssr_files->ts_cnt+ 1)
     IF (mod(gssr_files->ts_cnt,50)=1)
      stat = alterlist(gssr_files->ts,(gssr_files->ts_cnt+ 49))
     ENDIF
     gssr_files->ts[gssr_files->ts_cnt].tablespace_name = sf.tablespace_name
    DETAIL
     gssr_files->ts[gssr_files->ts_cnt].file_cnt = (gssr_files->ts[gssr_files->ts_cnt].file_cnt+ 1),
     stat = alterlist(gssr_files->ts[gssr_files->ts_cnt].files,gssr_files->ts[gssr_files->ts_cnt].
      file_cnt), gssr_files->ts[gssr_files->ts_cnt].files[gssr_files->ts[gssr_files->ts_cnt].file_cnt
     ].file_id = sf.file_id,
     gssr_files->ts[gssr_files->ts_cnt].files[gssr_files->ts[gssr_files->ts_cnt].file_cnt].file_name
      = build(substring(1,70,sf.file_name)), gssr_files->ts[gssr_files->ts_cnt].files[gssr_files->ts[
     gssr_files->ts_cnt].file_cnt].autoextensible = sf.autoextensible, gssr_files->ts[gssr_files->
     ts_cnt].files[gssr_files->ts[gssr_files->ts_cnt].file_cnt].blocks_allocated = sf.total_space,
     gssr_files->ts[gssr_files->ts_cnt].files[gssr_files->ts[gssr_files->ts_cnt].file_cnt].
     blocks_free = sf.free_space, gssr_files->ts[gssr_files->ts_cnt].files[gssr_files->ts[gssr_files
     ->ts_cnt].file_cnt].num_free_chunks = sf.num_chunks, gssr_files->ts[gssr_files->ts_cnt].files[
     gssr_files->ts[gssr_files->ts_cnt].file_cnt].max_free_chunk_size = sf.max_contig
    FOOT  sf.tablespace_name
     gssr_files->ts[gssr_files->ts_cnt].blocks_allocated_sum = sum(sf.total_space), gssr_files->ts[
     gssr_files->ts_cnt].blocks_free_sum = sum(sf.free_space), gssr_files->ts[gssr_files->ts_cnt].
     num_free_chunks_sum = sum(sf.num_chunks),
     gssr_files->ts[gssr_files->ts_cnt].max_free_chunk_size_max = max(sf.max_contig)
    FOOT REPORT
     stat = alterlist(gssr_files->ts,gssr_files->ts_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET gssr_locateval = locateval(gssr_locateval_temp,1,ssrog_report_options->parm_cnt,"*",
    ssrog_report_options->parms[gssr_locateval_temp].parm_value)
   IF (gssr_locateval > 0
    AND (ssrog_report_options->show_flagged_only="N"))
    SET gssr_report_destination = build(ssrog_report_options->report_name,format(ssrog_report_options
      ->report_run_date,"MMDDYYHHMM;;Q"))
   ELSE
    SET gssr_report_destination = "dm2ssrpt"
   ENDIF
   SET gssr_where_clause = build("(st.tablespace_name = patstring('",ssrog_report_options->parms[1].
    parm_value,"')")
   FOR (gssr_forcount = 2 TO ssrog_report_options->parm_cnt)
     SET gssr_where_clause = concat(gssr_where_clause," OR st.tablespace_name = patstring('",build(
       ssrog_report_options->parms[gssr_forcount].parm_value),"')")
   ENDFOR
   SET gssr_where_clause = build(gssr_where_clause,")")
   SET dm_err->eproc = "Selecting data from space_tablespaces/space_objects for report generation."
   SELECT INTO build(gssr_report_destination)
    row_count_null_ind = nullind(so.row_count), end_dt_tm_null_ind = nullind(so.end_dt_tm)
    FROM space_tablespaces st,
     space_objects so
    WHERE outerjoin(st.tablespace_name)=so.tablespace_name
     AND outerjoin(st.report_event_id)=so.report_seq
     AND (st.report_event_id=ssrog_report_options->report_event_id)
     AND parser(gssr_where_clause)
    ORDER BY st.tablespace_name, so.segment_name
    HEAD REPORT
     MACRO (lmt_ts_heading)
      col 74, "  Max Last", row + 1,
      col 47, "Ext", col 53,
      "      Num", col 63, "     Total",
      col 74, " Allocated", col 85,
      "    Blocks", col 96, "   Blocks",
      col 107, " Pct", row + 1,
      col 0, "Flags", col 16,
      "Tablespace_Name", col 47, "Mgmt",
      col 53, "  Objects", col 63,
      "   Extents", col 74, "  Ext Size",
      col 85, " Allocated", col 96,
      "     Free", col 107, "Free"
     ENDMACRO
     ,
     MACRO (dmt_ts_heading)
      col 47, "Ext", col 53,
      "      Num", col 63, "     Total",
      col 74, "  Max Next", col 85,
      "    Blocks", col 96, "   Blocks",
      col 107, " Pct", row + 1,
      col 0, "Flags", col 16,
      "Tablespace_Name", col 47, "Mgmt",
      col 53, "  Objects", col 63,
      "   Extents", col 74, "  Ext Size",
      col 85, " Allocated", col 96,
      "     Free", col 107, "Free"
     ENDMACRO
     ,
     MACRO (lmt_obj_heading)
      col 53, "     Last", row + 1,
      col 47, "Obj", col 53,
      "Allocated", col 63, "   Extents",
      col 74, "       Max", col 85,
      "    Blocks", col 118, "Last",
      row + 1, col 16, "Object Name",
      col 47, "Type", col 53,
      " Ext Size", col 63, " Allocated",
      col 74, "   Extents", col 85,
      " Allocated", col 96, "  Num Rows",
      col 107, "Table Mods", col 118,
      "Analyzed"
     ENDMACRO
     ,
     MACRO (dmt_obj_heading)
      col 47, "Obj", col 53,
      "     Next", col 63, "   Extents",
      col 74, "       Max", col 85,
      "    Blocks", col 118, "Last",
      row + 1, col 16, "Object Name",
      col 47, "Type", col 53,
      " Ext Size", col 63, " Allocated",
      col 74, "   Extents", col 85,
      " Allocated", col 96, "  Num Rows",
      col 107, "Table Mods", col 118,
      "Analyzed"
     ENDMACRO
     ,
     MACRO (file_heading)
      col 27, "    Blocks", col 38,
      "    Blocks", col 49, "  Num Free",
      col 60, "  Max Free", row + 1,
      col 16, "File Id", col 27,
      " Allocated", col 38, "      Free",
      col 49, "    Chunks", col 60,
      "Chunk Size", col 71, "File Name"
     ENDMACRO
     , col 0,
     "SPACE SUMMARY REPORT",
     CALL center(concat("Report Date/Time: ",format(cnvtdatetime(curdate,curtime3),
       "MM/DD/YYYY HH:MM:SS;;Q")),0,132), col 164,
     "Page: ", curpage"###;L", row + 1,
     CALL center(concat("Report File Name: ",build(gssr_report_destination),".dat"),0,132), row + 3,
     col 0,
     "Collection Criteria", row + 1, col 0,
     "Environment ID:", col 20,
     CALL print(build(cnvtstring(ssrog_report_options->environment_id,17))),
     row + 1, col 0, "Environment Name:",
     col 20, ssrog_report_options->environment_name, row + 1,
     col 0, "Collector Name:", col 20,
     ssrog_report_options->report_name, row + 1, col 0,
     "Date/Time:", col 20, ssrog_report_options->report_run_date"MM/DD/YYYY HH:MM:SS;;Q",
     row + 1, col 0, "Tablespaces:",
     row- (1)
     FOR (gssr_forcount = 1 TO ssrog_report_options->collection_parm_cnt)
       row + 1, col 20, ssrog_report_options->collection_parms[gssr_forcount].parm_value
     ENDFOR
     row + 3, col 0, "Report Criteria",
     row + 1, col 0, "Tablespaces:",
     row- (1)
     FOR (gssr_forcount = 1 TO ssrog_report_options->parm_cnt)
       row + 1, col 20, ssrog_report_options->parms[gssr_forcount].parm_value
     ENDFOR
     row + 1, col 0, "Flag Options:",
     row + 1, col 3,
     CALL print(concat("** 1 ** Tablespaces less than ",build(ssrog_report_options->
       less_than_x_pct_free)," percent free")),
     row + 1, col 3,
     CALL print(concat("** 2 ** Object is ",build(ssrog_report_options->x_away_max_extents),
      " extents away from reaching Max Extents")),
     row + 1, col 3, "Show Flagged Objects Only = ",
     ssrog_report_options->show_flagged_only, row_cnt = ((13+ ssrog_report_options->parm_cnt)+
     ssrog_report_options->collection_parm_cnt), row- (row_cnt),
     row + 1, col 60, "Definitions",
     row + 1, col 60, "Chunk: A group of contiguous free blocks",
     row + 2, col 60, "Block translation Legend (given 8192 bytes per Oracle block)",
     row + 1, col 60, "Kilobytes = Blocks * 8192 / 1024",
     row + 1, col 60, "Megabytes = Blocks * 8192 / 1048576",
     row + 1, col 60, "Gigabytes = Blocks * 8192 / 1073741824",
     row + 2, col 60, "Note: Object level detail collected only for ",
     currdbuser, row + 1, col 60,
     "********* = column overflow", row_cnt = ((5+ ssrog_report_options->parm_cnt)+
     ssrog_report_options->collection_parm_cnt), row + row_cnt
    HEAD PAGE
     col 164,
     CALL print(concat("Page: ",cnvtstring((curpage+ 1),3)))
    HEAD st.tablespace_name
     gssr_ts_obj->object_cnt = 0, stat = alterlist(gssr_ts_obj->objects,gssr_ts_obj->object_cnt),
     gssr_ts_obj->flagged_objects = 0
    DETAIL
     IF (so.segment_name != null)
      flag2 = 0, flag3 = 0, disp_object = 0,
      flag = fillstring(15," ")
      IF (((so.max_extents - so.extents) <= ssrog_report_options->x_away_max_extents))
       flag2 = 1, gssr_ts_obj->flagged_objects = 1
      ENDIF
      IF ((((ssrog_report_options->show_flagged_only="N")) OR ((ssrog_report_options->
      show_flagged_only="Y")
       AND (gssr_ts_obj->flagged_objects=1))) )
       gssr_ts_obj->object_cnt = (gssr_ts_obj->object_cnt+ 1), stat = alterlist(gssr_ts_obj->objects,
        gssr_ts_obj->object_cnt)
       IF (flag2=1
        AND flag3=1)
        flag = "** 2,3 **"
       ELSEIF (flag2=1)
        flag = "** 2 **"
       ELSEIF (flag3=1)
        flag = "** 3 **"
       ELSE
        flag = ""
       ENDIF
       gssr_ts_obj->objects[gssr_ts_obj->object_cnt].flags = flag, gssr_ts_obj->objects[gssr_ts_obj->
       object_cnt].object_name = build(substring(1,30,so.segment_name))
       IF (substring(1,10,so.segment_type)="LOB COLUMN")
        gssr_ts_obj->objects[gssr_ts_obj->object_cnt].object_type = "LOB"
       ELSE
        gssr_ts_obj->objects[gssr_ts_obj->object_cnt].object_type = build(substring(1,5,so
          .segment_type))
       ENDIF
       IF (st.extent_management="LOCAL")
        gssr_ts_obj->objects[gssr_ts_obj->object_cnt].last_allocated_next_extent = evaluate(so
         .max_alloc_next_ext,0.0,"Initial",cnvtstring(so.max_alloc_next_ext))
       ELSE
        gssr_ts_obj->objects[gssr_ts_obj->object_cnt].last_allocated_next_extent = cnvtstring(so
         .next_extent)
       ENDIF
       gssr_ts_obj->objects[gssr_ts_obj->object_cnt].extents_allocated = so.extents, gssr_ts_obj->
       objects[gssr_ts_obj->object_cnt].max_extents = so.max_extents, gssr_ts_obj->objects[
       gssr_ts_obj->object_cnt].blocks_allocated = so.total_space
       IF (row_count_null_ind=1)
        gssr_ts_obj->objects[gssr_ts_obj->object_cnt].num_rows = "No Stats"
       ELSEIF (so.row_count > 9999999999.0)
        gssr_ts_obj->objects[gssr_ts_obj->object_cnt].num_rows = "**********"
       ELSE
        gssr_ts_obj->objects[gssr_ts_obj->object_cnt].num_rows = cnvtstring(so.row_count,10)
       ENDIF
       IF (so.monitoring="NO")
        gssr_ts_obj->objects[gssr_ts_obj->object_cnt].table_mods = "Off"
       ELSE
        gssr_ts_obj->objects[gssr_ts_obj->object_cnt].table_mods = cnvtstring(so.table_mods,10)
       ENDIF
       IF (so.end_dt_tm=null)
        gssr_ts_obj->objects[gssr_ts_obj->object_cnt].last_analyzed = "No Stats"
       ELSE
        gssr_ts_obj->objects[gssr_ts_obj->object_cnt].last_analyzed = format(so.end_dt_tm,
         "MM/DD/YY HH:MM;;Q")
       ENDIF
       gssr_ts_obj->objects[gssr_ts_obj->object_cnt].table_name = evaluate(gssr_ts_obj->objects[
        gssr_ts_obj->object_cnt].object_type,"LOB",so.table_name,"")
      ENDIF
     ENDIF
    FOOT  st.tablespace_name
     IF ((((ssrog_report_options->show_flagged_only="N")) OR ((ssrog_report_options->
     show_flagged_only="Y")
      AND (((st.pct_free < ssrog_report_options->less_than_x_pct_free)) OR ((gssr_ts_obj->
     flagged_objects=1))) )) )
      IF (st.extent_management="LOCAL")
       row + 1, lmt_ts_heading, row + 1
      ELSE
       row + 1, dmt_ts_heading, row + 1
      ENDIF
      IF ((st.pct_free < ssrog_report_options->less_than_x_pct_free))
       col 0, "** 1 **"
      ENDIF
      col 16, st.tablespace_name";L"
      IF (st.extent_management="DICTIONARY")
       col 47, "DICT"
      ELSE
       col 47,
       CALL print(trim(st.extent_management))
      ENDIF
      col 53, st.num_objects"#########;R", col 63,
      st.total_extents"##########;R"
      IF (st.max_alloc_next_ext=0)
       col 74, "   Initial"
      ELSE
       col 74,
       CALL print(format(cnvtstring(st.max_alloc_next_ext,10),"##########;R"))
      ENDIF
      IF (st.blocks_allocated > 9999999999.0)
       col 85, "**********"
      ELSE
       col 85, st.blocks_allocated"##########;R"
      ENDIF
      col 96, st.blocks_free"#########;R", col 107,
      st.pct_free"####;R", row + 1
      IF (st.segment_space_management != "AUTO"
       AND st.extent_management="LOCAL")
       col 47,
       CALL print(concat("*Warning: Segment_Space_Management = '",trim(st.segment_space_management),
        "' (this is a non-standard Cerner configuration)")), row + 1
      ENDIF
      row + 1
      IF (build(st.extent_management)="LOCAL")
       row + 1, lmt_obj_heading, row + 1
      ELSE
       row + 1, dmt_obj_heading, row + 1
      ENDIF
      FOR (gssr_forcount = 1 TO gssr_ts_obj->object_cnt)
        IF ((((ssrog_report_options->show_flagged_only="N")) OR ((ssrog_report_options->
        show_flagged_only="Y")
         AND (gssr_ts_obj->objects[gssr_forcount].flags > ""))) )
         col 0,
         CALL print(trim(gssr_ts_obj->objects[gssr_forcount].flags)), col 16,
         CALL print(trim(gssr_ts_obj->objects[gssr_forcount].object_name)), col 47,
         CALL print(trim(gssr_ts_obj->objects[gssr_forcount].object_type)),
         col 53, gssr_ts_obj->objects[gssr_forcount].last_allocated_next_extent"#########;R", col 63,
         gssr_ts_obj->objects[gssr_forcount].extents_allocated"##########;R", col 74, gssr_ts_obj->
         objects[gssr_forcount].max_extents"##########;R"
         IF ((gssr_ts_obj->objects[gssr_forcount].blocks_allocated > 9999999999.0))
          col 85, "**********"
         ELSE
          col 85, gssr_ts_obj->objects[gssr_forcount].blocks_allocated"##########;R"
         ENDIF
         col 96, gssr_ts_obj->objects[gssr_forcount].num_rows"##########;R", col 107,
         gssr_ts_obj->objects[gssr_forcount].table_mods"##########;R", col 118,
         CALL print(trim(gssr_ts_obj->objects[gssr_forcount].last_analyzed)),
         col 133,
         CALL print(trim(gssr_ts_obj->objects[gssr_forcount].table_name)), row + 1
        ENDIF
      ENDFOR
      IF ((gssr_ts_obj->object_cnt=0))
       CALL center("**** NO OBJECTS REPORTED ****",1,142), row + 1
      ENDIF
      row + 1, row + 1, file_heading,
      row + 1, gssr_locateval = 0, gssr_locateval = locateval(gssr_locateval_temp,1,gssr_files->
       ts_cnt,st.tablespace_name,gssr_files->ts[gssr_locateval_temp].tablespace_name)
      IF (gssr_locateval > 0)
       FOR (gssr_forcount = 1 TO gssr_files->ts[gssr_locateval].file_cnt)
         col 16, gssr_files->ts[gssr_locateval].files[gssr_forcount].file_id";L"
         IF ((gssr_files->ts[gssr_locateval].files[gssr_forcount].blocks_allocated > 9999999999.0))
          col 27, "**********"
         ELSE
          col 27, gssr_files->ts[gssr_locateval].files[gssr_forcount].blocks_allocated"##########;R"
         ENDIF
         col 38, gssr_files->ts[gssr_locateval].files[gssr_forcount].blocks_free"##########;R", col
         49,
         gssr_files->ts[gssr_locateval].files[gssr_forcount].num_free_chunks"##########;R", col 60,
         gssr_files->ts[gssr_locateval].files[gssr_forcount].max_free_chunk_size"##########;R",
         col 71,
         CALL print(trim(gssr_files->ts[gssr_locateval].files[gssr_forcount].file_name)), row + 1
         IF ((gssr_files->ts[gssr_locateval].files[gssr_forcount].autoextensible="YES"))
          col 16,
          "*Warning: autoextend = 'YES' on above datafile (this is a non-standard Cerner configuration)",
          row + 1
         ENDIF
       ENDFOR
       col 16, "Totals:"
       IF ((gssr_files->ts[gssr_locateval].blocks_allocated_sum > 9999999999.0))
        col 27, "**********"
       ELSE
        col 27, gssr_files->ts[gssr_locateval].blocks_allocated_sum"##########;R"
       ENDIF
       col 38, gssr_files->ts[gssr_locateval].blocks_free_sum"##########;R", col 49,
       gssr_files->ts[gssr_locateval].num_free_chunks_sum"##########;R", col 60, gssr_files->ts[
       gssr_locateval].max_free_chunk_size_max"##########;R",
       row + 1
      ENDIF
      row + 2
     ENDIF
    FOOT REPORT
     CALL center("*** END OF REPORT ***",1,142)
    WITH nocounter, nullreport, maxcol = 174,
     format = variable, formfeed = none
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   FREE DEFINE rtl2
   DEFINE rtl2 build(gssr_report_destination)
   SELECT INTO mine
    FROM rtl2t t
    DETAIL
     col 0,
     CALL print(trim(t.line)), row + 1
    WITH nocounter, maxcol = 174, maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE compact_parms(record_name)
   FREE RECORD parm_temp
   RECORD parm_temp(
     1 parms[*]
       2 parm_value = vc
   )
   DECLARE cp_orig_parm = i4 WITH protect, noconstant(0)
   DECLARE cp_temp_parm = i4 WITH protect, noconstant(0)
   DECLARE cp_old_cnt = i4 WITH protect, noconstant(0)
   CASE (record_name)
    OF "ssrog_report_options":
     SET stat = alterlist(parm_temp->parms,ssrog_report_options->parm_cnt)
     FOR (cp_temp_parm = 1 TO ssrog_report_options->parm_cnt)
       SET parm_temp->parms[cp_temp_parm].parm_value = ssrog_report_options->parms[cp_temp_parm].
       parm_value
     ENDFOR
     FOR (cp_temp_parm = 1 TO ssrog_report_options->parm_cnt)
       SET ssrog_report_options->parms[cp_temp_parm].parm_value = ""
     ENDFOR
     SET cp_old_cnt = ssrog_report_options->parm_cnt
     SET ssrog_report_options->parm_cnt = 0
     SET stat = alterlist(ssrog_report_options->parms,ssrog_report_options->parm_cnt)
     FOR (cp_temp_parm = 1 TO cp_old_cnt)
       IF (build(parm_temp->parms[cp_temp_parm].parm_value) != "")
        SET ssrog_report_options->parm_cnt = (ssrog_report_options->parm_cnt+ 1)
        SET stat = alterlist(ssrog_report_options->parms,ssrog_report_options->parm_cnt)
        SET ssrog_report_options->parms[ssrog_report_options->parm_cnt].parm_value = parm_temp->
        parms[cp_temp_parm].parm_value
       ENDIF
     ENDFOR
    OF "sscm_collector_info":
     SET stat = alterlist(parm_temp->parms,sscm_collector_info->parm_cnt)
     FOR (cp_temp_parm = 1 TO sscm_collector_info->parm_cnt)
       SET parm_temp->parms[cp_temp_parm].parm_value = sscm_collector_info->parms[cp_temp_parm].
       parm_value
     ENDFOR
     FOR (cp_temp_parm = 1 TO sscm_collector_info->parm_cnt)
       SET sscm_collector_info->parms[cp_temp_parm].parm_value = ""
     ENDFOR
     SET cp_old_cnt = sscm_collector_info->parm_cnt
     SET sscm_collector_info->parm_cnt = 0
     SET stat = alterlist(sscm_collector_info->parms,sscm_collector_info->parm_cnt)
     FOR (cp_temp_parm = 1 TO cp_old_cnt)
       IF (build(parm_temp->parms[cp_temp_parm].parm_value) != "")
        SET sscm_collector_info->parm_cnt = (sscm_collector_info->parm_cnt+ 1)
        SET stat = alterlist(sscm_collector_info->parms,sscm_collector_info->parm_cnt)
        SET sscm_collector_info->parms[sscm_collector_info->parm_cnt].parm_value = parm_temp->parms[
        cp_temp_parm].parm_value
       ENDIF
     ENDFOR
   ENDCASE
   FREE RECORD parm_temp
 END ;Subroutine
 SUBROUTINE sscm_generate_collection_script(report_name,database_password,database_connect_string)
   DECLARE gcs_define_string = vc WITH protect, noconstant("")
   DECLARE gcs_execute_string = vc WITH protect, noconstant("")
   DECLARE gcs_file_name = vc WITH protect, noconstant("")
   SET report_name = trim(cnvtlower(report_name),3)
   IF (cursys IN ("AXP", "VMS"))
    SET gcs_define_string = build("define oraclesystem '",currdbuser,"/",database_password,"@",
     database_connect_string,"' go")
    SET gcs_execute_string = build("dm2_space_summary '",cnvtupper(report_name),"' go")
    SET gcs_file_name = build(report_name,".com")
    SET dm_err->eproc = "Generating com file."
    SELECT INTO build(gcs_file_name)
     DETAIL
      col 0, "$!", row + 1,
      col 0, "$! Space Summary Collector script for ", report_name,
      row + 1, col 0, "$!",
      row + 1, col 0, '$CCL :== "$CER_EXE:CCLORA.EXE"',
      row + 1, col 0, "$CCL",
      row + 1, col 0, "free define oraclesystem go",
      row + 1, col 0, gcs_define_string,
      row + 1, col 0, gcs_execute_string,
      row + 1, col 0, "exit"
     WITH format = stream, noheading, formfeed = none,
      nocounter, maxrow = 1
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET sscm_err_msg = concat("Error generating file: ",dm_err->emsg)
     SET dm_err->err_ind = 0
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Changing file permissions on com file."
    IF (findfile(build(gcs_file_name))=1)
     CALL dm2_push_dcl(build("set file/prot=(s:RWED,o:RWED,g:RWED,w:RWED) ccluserdir:",gcs_file_name,
       ";*"))
     IF ((dm_err->err_ind=1))
      SET sscm_err_msg = concat("File generated, error changing permissions: ",dm_err->emsg)
      SET dm_err->err_ind = 0
      RETURN(0)
     ENDIF
    ENDIF
   ELSEIF (cursys="AIX")
    SET gcs_file_name = build(report_name,".ksh")
    SET gcs_define_string = build("define oraclesystem '",currdbuser,"/",database_password,"@",
     database_connect_string,"' go")
    SET gcs_execute_string = build("dm2_space_summary '",cnvtupper(report_name),"' go")
    SET stat = remove(build(cnvtlower(sscm_collector_info->name),".ksh"))
    SET dm_err->eproc = "Generating ksh file."
    SELECT INTO build(gcs_file_name)
     DETAIL
      col 0, "#!/usr/bin/ksh", row + 1,
      col 0, "#", row + 1,
      col 0, "# Space Summary Collector script for ", report_name,
      row + 1, col 0, "#",
      row + 1, col 0, "ccl <<!",
      row + 1, col 0, "free define oraclesystem go",
      row + 1, col 0, gcs_define_string,
      row + 1, col 0, gcs_execute_string,
      row + 1, col 0, "exit"
     WITH format = stream, noheading, formfeed = none,
      nocounter, maxrow = 1
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET sscm_err_msg = concat("Error generating file: ",dm_err->emsg)
     SET dm_err->err_ind = 0
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Changing file permissions for ksh file."
    IF (findfile(build(gcs_file_name))=1)
     CALL dm2_push_dcl(build("chmod 777 $CCLUSERDIR/",gcs_file_name))
     IF ((dm_err->err_ind=1))
      SET sscm_err_msg = concat("File generated, error changing permissions: ",dm_err->emsg)
      SET dm_err->err_ind = 0
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_script
 CALL clear(1,1)
 SET message = nowindow
 IF ((dm_err->err_ind=1))
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
 ENDIF
 SET dm_err->eproc = "Ending DM2_SS_MAINT."
 CALL final_disp_msg("dm2_ss_maint")
END GO
