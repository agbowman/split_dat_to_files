CREATE PROGRAM dm2_create_db_shell:dba
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
 IF ((validate(des_env_switch_rs->old_env_id,- (1))=- (1))
  AND (validate(des_env_switch_rs->old_env_id,- (2))=- (2)))
  FREE RECORD des_env_switch_rs
  RECORD des_env_switch_rs(
    1 old_env_id = f8
    1 new_env_id = f8
  )
 ENDIF
 IF ((validate(des_env_data->env_exists,- (1))=- (1))
  AND (validate(des_env_data->loaded_ind,- (2))=- (2)))
  FREE RECORD des_env_data
  RECORD des_env_data(
    1 loaded_ind = i2
    1 env_exists = i2
    1 env_id = f8
    1 env_name = vc
    1 env_desc = vc
    1 db_name = vc
    1 db_node_os = vc
    1 admin_dbase_link_name = vc
    1 v500_connect_string = vc
    1 v500ref_connect_string = vc
    1 envset_string = vc
    1 db_version = i4
    1 cerner_fs_mtpt = vc
    1 ora_pri_fs_mtpt = vc
    1 ora_sec_fs_mtpt = vc
    1 db_ora_version = vc
    1 max_file_size = f8
  )
  SET des_env_data->loaded_ind = 0
  SET des_env_data->env_exists = 0
  SET des_env_data->env_id = 0.0
  SET des_env_data->env_name = "DM2NOTSET"
  SET des_env_data->env_desc = "DM2NOTSET"
  SET des_env_data->db_name = "DM2NOTSET"
  SET des_env_data->db_node_os = "DM2NOTSET"
  SET des_env_data->admin_dbase_link_name = "ADMIN1"
  SET des_env_data->v500_connect_string = "DM2NOTSET"
  SET des_env_data->v500ref_connect_string = "DM2NOTSET"
  SET des_env_data->envset_string = "DM2NOTSET"
  SET des_env_data->db_version = 0
  SET des_env_data->cerner_fs_mtpt = "/cerner"
  SET des_env_data->ora_pri_fs_mtpt = "/u01"
  SET des_env_data->ora_sec_fs_mtpt = "/u02"
  SET des_env_data->db_ora_version = "DM2NOTSET"
  SET des_env_data->max_file_size = 2000
 ENDIF
 DECLARE des_env_switch(des_env_id=f8) = i2
 DECLARE des_env_data_prompt(null) = i4
 DECLARE des_env_data_check(null) = i4
 DECLARE des_get_env_data(load_ind=i4) = i4
 DECLARE des_insert_env(null) = i4
 DECLARE des_update_env(null) = i4
 DECLARE des_new_id_prompt(null) = i4
 SUBROUTINE des_env_switch(des_env_id)
   DECLARE des_env_name = vc WITH protect, noconstant("")
   DECLARE des_old_env_id = f8 WITH protect, noconstant(0.0)
   DECLARE des_description = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Querying for new environment_name from dm_environment."
   SELECT INTO "nl:"
    FROM dm_environment de
    WHERE de.environment_id=des_env_id
    DETAIL
     des_env_name = de.environment_name, des_description = de.description
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ( NOT (curqual))
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Querying for old environment_id from dm_environment."
   SELECT INTO "nl:"
    FROM dm_environment de
    WHERE de.description=concat("OLD_NAME:",des_env_name)
     AND de.environment_id != des_env_id
    DETAIL
     des_old_env_id = de.environment_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ( NOT (curqual))
    RETURN(1)
   ENDIF
   IF (checkprg("EUC_REFRESH"))
    SET des_env_switch_rs->new_env_id = des_env_id
    SET des_env_switch_rs->old_env_id = des_old_env_id
    EXECUTE euc_refresh
    IF (dm_err->err_ind)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET stat = error(dm_err->emsg,1)
   ENDIF
   SET dm_err->eproc = "Updating old environment description back in dm_environment."
   UPDATE  FROM dm_environment de
    SET de.description = des_description
    WHERE de.environment_id=des_old_env_id
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc))
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE des_env_data_prompt(null)
   SET dm_err->eproc = "Displaying prompt for Target Database Information."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET width = 132
   SET message = window
   CALL box(1,1,14,131)
   CALL text(2,55,"TARGET DATABASE ENVIRONMENT INFORMATION")
   CALL text(4,2,"Help is available via <Shift><F5>")
   CALL text(6,2,"Target Database Node Operating System:")
   SET help = fix("AIX,HPX,LNX")
   CALL accept(6,45,"A(3);CU"," "
    WHERE build(curaccept) IN ("HPX", "AIX", "LNX"))
   SET help = off
   SET des_env_data->db_node_os = build(curaccept)
   CALL text(7,2,"Target Database Oracle Version:")
   IF ((des_env_data->db_node_os="HPX"))
    SET help = fix("10.1,11.1,11.2")
    CALL accept(7,45,"P(4);CFU"," "
     WHERE build(curaccept) IN ("10.1", "11.1", "11.2"))
   ELSEIF ((des_env_data->db_node_os="AIX"))
    SET help = fix("10.1,10.2,11.1,11.2,12.2,19")
    CALL accept(7,45,"P(4);CFU"," "
     WHERE build(curaccept) IN ("10.1", "10.2", "11.1", "11.2", "12.2",
     "19"))
   ELSEIF ((des_env_data->db_node_os="LNX"))
    SET help = fix("10.2,11.1,11.2,12.2,19")
    CALL accept(7,45,"P(4);CFU"," "
     WHERE build(curaccept) IN ("10.2", "11.1", "11.2", "12.2", "19"))
   ENDIF
   SET help = off
   SET des_env_data->db_ora_version = build(curaccept)
   CALL text(8,2,"Target Environment Name:")
   SET help =
   SELECT
    de.environment_name, de.database_name
    FROM dm_environment de
    WHERE (de.target_operating_system=des_env_data->db_node_os)
    ORDER BY de.environment_name
    WITH nocounter
   ;end select
   CALL accept(8,45,"P(20);CU"," "
    WHERE build(curaccept) > "")
   SET help = off
   SET des_env_data->env_name = build(curaccept)
   SET dm_err->eproc =
   "Selecting target environment description and Database name from dm_environment."
   SELECT INTO "nl:"
    FROM dm_environment de
    WHERE (cnvtupper(de.environment_name)=des_env_data->env_name)
    DETAIL
     des_env_data->env_desc = trim(de.description), des_env_data->db_name = cnvtupper(de
      .database_name)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET message = nowindow
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   CALL text(9,2,"Target Environment Description:")
   IF ((des_env_data->env_desc != "DM2NOTSET"))
    CALL text(9,45,des_env_data->env_desc)
    CALL accept(9,45,"P(60);CU",des_env_data->env_desc
     WHERE build(curaccept) > "")
   ELSE
    CALL accept(9,45,"P(60);CU",""
     WHERE build(curaccept) > "")
   ENDIF
   SET des_env_data->env_desc = build(curaccept)
   CALL text(10,2,"Target Database Name:")
   IF (cnvtint(des_env_data->db_ora_version) >= 12)
    IF ((des_env_data->db_name != "DM2NOTSET"))
     CALL text(10,45,des_env_data->db_name)
     CALL accept(10,45,"P(6);CU",des_env_data->db_name
      WHERE build(curaccept) > "")
    ELSE
     CALL accept(10,45,"P(6);CU",""
      WHERE build(curaccept) > "")
    ENDIF
   ELSE
    IF ((des_env_data->db_name != "DM2NOTSET"))
     CALL text(10,45,des_env_data->db_name)
     CALL accept(10,45,"P(5);CU",des_env_data->db_name
      WHERE build(curaccept) > "")
    ELSE
     CALL accept(10,45,"P(5);CU",""
      WHERE build(curaccept) > "")
    ENDIF
   ENDIF
   SET des_env_data->db_name = build(curaccept)
   CALL text(12,2,"(Q)uit, (C)ontinue:")
   CALL accept(12,21,"A;CU"," "
    WHERE curaccept IN ("C", "Q"))
   SET message = nowindow
   CALL clear(1,1)
   IF (curaccept="Q")
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Displaying prompt for Target Database Information."
    SET dm_err->emsg = "User choose to Quit."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag >= 1))
    CALL echorecord(des_env_data)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE des_env_data_check(null)
   DECLARE dedc_idx = i2 WITH protect, noconstant(0)
   IF ( NOT ((des_env_data->db_node_os IN ("AIX", "HPX", "LNX"))))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating target db node os: ",des_env_data->db_node_os,".")
    SET dm_err->emsg = "Target Database Node Operating System has invald value."
    SET dm_err->user_action = "Please specify one of the following values: AIX/HPX/LNX."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Validating db oracle version: ",des_env_data->db_ora_version,".")
   IF ( NOT ((des_env_data->db_ora_version IN ("10.1", "11.1", "11.2")))
    AND (des_env_data->db_node_os="HPX"))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Target Oracle Version has invald value."
    SET dm_err->user_action = "Please specify one of the following values: 10.1/11.1/11.2"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF ( NOT ((des_env_data->db_ora_version IN ("10.1", "10.2", "11.1", "11.2", "12.2",
   "19")))
    AND (des_env_data->db_node_os="AIX"))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Target Oracle Version has invald value."
    SET dm_err->user_action =
    "Please specify one of the following values: 10.1/10.2/11.1/11.2/12.2/19"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF ( NOT ((des_env_data->db_ora_version IN ("10.2", "11.1", "11.2", "12.2", "19")))
    AND (des_env_data->db_node_os="LNX"))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Target Oracle Version has invald value."
    SET dm_err->user_action = "Please specify one of the following values: 10.2/11.1/11.2/12.2/19"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((((des_env_data->env_name="DM2NOTSET")) OR (((findstring(" ",des_env_data->env_name,1,0) > 0)
    OR (((size(des_env_data->env_name) > 20) OR ((des_env_data->env_name != cnvtupper(des_env_data->
    env_name)))) )) )) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating environment name: ",des_env_data->env_name,".")
    SET dm_err->emsg = "Target Environment Name has invald value."
    SET dm_err->user_action = concat(
     "Please specify Target Environment Name which is equal to or less than ",
     "20 characters in uppercase with no spaces.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((((des_env_data->env_desc="DM2NOTSET")) OR (((size(des_env_data->env_desc) > 60) OR ((
   des_env_data->env_desc != cnvtupper(des_env_data->env_desc)))) )) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Validating environment description: ",des_env_data->env_desc,".")
    SET dm_err->emsg = "Target Environment Description has invald value."
    SET dm_err->user_action = concat(
     "Please specify Target Environment Description which is equal to or less than ",
     "60 characters in uppercase.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (cnvtint(des_env_data->db_ora_version) >= 12)
    IF ((((des_env_data->db_name="DM2NOTSET")) OR (((size(des_env_data->db_name) > 30) OR ((
    des_env_data->db_name != cnvtupper(des_env_data->db_name)))) )) )
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating database name: ",des_env_data->db_name,".")
     SET dm_err->emsg = "Target Database Name has invald value."
     SET dm_err->user_action =
     "Please specify Target Database Name which is equal to or less than 30 characters in uppercase."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    IF ((((des_env_data->db_name="DM2NOTSET")) OR (((size(des_env_data->db_name) > 5) OR ((
    des_env_data->db_name != cnvtupper(des_env_data->db_name)))) )) )
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating database name: ",des_env_data->db_name,".")
     SET dm_err->emsg = "Target Database Name has invald value."
     SET dm_err->user_action =
     "Please specify Target Database Name which is equal to or less than 5 characters in uppercase."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((des_env_data->v500_connect_string="DM2NOTSET"))
    SET dedc_idx = locateval(dedc_idx,1,dir_db_users_pwds->cnt,"V500",dir_db_users_pwds->qual[
     dedc_idx].user)
    IF (dedc_idx > 0)
     SET des_env_data->v500_connect_string = concat("V500/",dir_db_users_pwds->qual[dedc_idx].pwd,"@",
      des_env_data->db_name,"1")
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Creating connect string for V500.")
     SET dm_err->emsg = "Password missing for V500."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((des_env_data->v500ref_connect_string="DM2NOTSET"))
    SET dedc_idx = locateval(dedc_idx,1,dir_db_users_pwds->cnt,"V500_REF",dir_db_users_pwds->qual[
     dedc_idx].user)
    IF (dedc_idx > 0)
     SET des_env_data->v500ref_connect_string = concat("V500_REF/",dir_db_users_pwds->qual[dedc_idx].
      pwd,"@",des_env_data->db_name,"1")
    ELSE
     SET des_env_data->v500ref_connect_string = concat("V500_REF/V500_REF@",des_env_data->db_name,"1"
      )
    ENDIF
   ENDIF
   IF ((des_env_data->envset_string="DM2NOTSET"))
    SET des_env_data->envset_string = cnvtlower(des_env_data->env_name)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE des_get_env_data(load_ind)
   SET dm_err->eproc = "Selecting target environment information from dm_environment."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_environment de
    WHERE (cnvtupper(de.environment_name)=des_env_data->env_name)
    DETAIL
     des_env_data->env_id = de.environment_id, des_env_data->env_exists = 1
     IF (load_ind=1)
      des_env_data->env_desc = de.description, des_env_data->db_name = de.database_name, des_env_data
      ->db_ora_version = de.oracle_version,
      des_env_data->db_node_os = de.target_operating_system, des_env_data->admin_dbase_link_name = de
      .admin_dbase_link_name, des_env_data->v500_connect_string = de.v500_connect_string,
      des_env_data->v500ref_connect_string = de.v500ref_connect_string, des_env_data->envset_string
       = de.envset_string, des_env_data->loaded_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET des_env_data->env_exists = 0
    SET des_env_data->env_id = 0.0
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE des_insert_env(null)
   SET dm_err->eproc = "Generating new environment_id from dual."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    id = seq(dm_seq,nextval)
    FROM dual d
    DETAIL
     des_env_data->env_id = cnvtreal(id)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((des_env_data->env_id <= 0))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Unable to obtain environment_id. Envid returned:",build(des_env_data->
      env_id))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Inserting new environment data into dm_environment."
   CALL disp_msg(" ",dm_err->logfile,0)
   INSERT  FROM dm_environment de
    SET de.environment_id = des_env_data->env_id, de.description = des_env_data->env_desc, de
     .environment_name = des_env_data->env_name,
     de.database_name = des_env_data->db_name, de.target_operating_system = des_env_data->db_node_os,
     de.admin_dbase_link_name = des_env_data->admin_dbase_link_name,
     de.db_version = des_env_data->db_version, de.v500_connect_string = des_env_data->
     v500_connect_string, de.v500ref_connect_string = des_env_data->v500ref_connect_string,
     de.cerner_fs_mtpt = des_env_data->cerner_fs_mtpt, de.ora_pri_fs_mtpt = des_env_data->
     ora_pri_fs_mtpt, de.ora_sec_fs_mtpt = des_env_data->ora_sec_fs_mtpt,
     de.oracle_version = des_env_data->db_ora_version, de.max_file_size = 2000, de.envset_string =
     des_env_data->envset_string,
     de.root_dir_name = " ", de.volume_group = " ", de.updt_dt_tm = cnvtdatetime(curdate,curtime3)
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
 SUBROUTINE des_update_env(null)
   SET dm_err->eproc = "Updating environment data in dm_environment."
   CALL disp_msg(" ",dm_err->logfile,0)
   UPDATE  FROM dm_environment de
    SET de.description = des_env_data->env_desc, de.database_name = des_env_data->db_name, de
     .target_operating_system = des_env_data->db_node_os,
     de.db_version = des_env_data->db_version, de.v500_connect_string = des_env_data->
     v500_connect_string, de.v500ref_connect_string = des_env_data->v500ref_connect_string,
     de.cerner_fs_mtpt = des_env_data->cerner_fs_mtpt, de.ora_pri_fs_mtpt = des_env_data->
     ora_pri_fs_mtpt, de.ora_sec_fs_mtpt = des_env_data->ora_sec_fs_mtpt,
     de.oracle_version = des_env_data->db_ora_version, de.envset_string = des_env_data->envset_string,
     de.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (de.environment_id=des_env_data->env_id)
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE des_new_id_prompt(null)
   SET dm_err->eproc = "Displaying New Target environment id confirmation prompt."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET message = window
   SET width = 132
   CALL clear(1,1)
   CALL box(1,1,10,100)
   CALL text(3,22,"NEW TARGET ENVIRONMENT ID CONFIRMATION PROMPT")
   CALL text(5,2,"Package history found and a new environment id will be created.")
   CALL text(7,2,"(Q)uit, (C)ontinue:")
   CALL accept(7,21,"A;CU"," "
    WHERE curaccept IN ("C", "Q"))
   SET message = nowindow
   CALL clear(1,1)
   IF (curaccept="Q")
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "User choose to Quit."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE dtr_parse_tns(dpt_fl=vc,dpt_fn=vc) = i2
 DECLARE dtr_copy_to_tnstgt(null) = i2
 DECLARE dtr_merge_to_tnstgt(null) = i2
 DECLARE dtr_reset_tnswork(null) = i2
 DECLARE dtr_tns_generate(dtg_file_location=vc,dtg_file_name=vc) = i2
 DECLARE dtr_tns_confirm(dtc_file_location=vc,dtc_file_name=vc) = i2
 DECLARE dtr_tns_deploy(dtd_file_location=vc,dtd_file_name=vc) = i2
 DECLARE dtr_tns_test_connect(null) = i2
 DECLARE dtr_get_tns_details(null) = i2
 DECLARE dtr_get_host_port_numbers(null) = i2
 DECLARE dtr_import_tns_templates(null) = i2
 DECLARE dtr_setup_tgt_template(token_name=vc) = i2
 DECLARE dtr_complete_tgt_template(null) = i2
 DECLARE dtr_add_token(token_name=vc,token_value=vc) = null
 DECLARE dtr_clear_tokens(null) = null
 DECLARE dtr_copy_tgt_template(null) = i2
 DECLARE dtr_populate_all_tns_stanzas(null) = i2
 DECLARE dtr_display_tns_report(null) = i2
 DECLARE dtr_prompt_tns_confirmation(null) = i2
 DECLARE dtr_service_connectivity_test(null) = i2
 DECLARE dtr_query_tns_details(null) = i2
 IF ((validate(tnswork->cnt,- (1))=- (1))
  AND (validate(tnswork->cnt,- (2))=- (2)))
  RECORD tnswork(
    1 db_name = vc
    1 db_connected = i2
    1 db_vip_ext = vc
    1 db_port = vc
    1 db_host_name = vc
    1 db_host_clause = vc
    1 db_domain = vc
    1 tc_user = vc
    1 tc_pwd = vc
    1 tc_inst_cnt = i2
    1 cnt = i2
    1 qual[*]
      2 tns_key = vc
      2 tns_key_full = vc
      2 db_domain = vc
      2 tns_key_type_cd = i2
      2 chg_format_ind = i2
      2 merge_ind = i2
      2 line_cnt = i2
      2 qual[*]
        3 text = vc
      2 tc_option = i2
      2 tc_num_connects = i2
      2 tc_inst_cnt = i2
      2 tcl[*]
        3 instance_name = vc
        3 host_name = vc
    1 inst_cnt = i2
    1 inst[*]
      2 instance_name = vc
      2 host_name = vc
  )
  SET tnswork->db_vip_ext = "DM2NOTSET"
  SET tnswork->db_port = "DM2NOTSET"
  SET tnswork->db_host_name = "DM2NOTSET"
  SET tnswork->db_host_clause = "DM2NOTSET"
  SET tnswork->db_domain = "DM2NOTSET"
  SET tnswork->tc_user = "DM2NOTSET"
  SET tnswork->tc_pwd = "DM2NOTSET"
  SET tnswork->inst_cnt = 0
 ENDIF
 IF ((validate(tnstgt->cnt,- (1))=- (1))
  AND (validate(tnstgt->cnt,- (2))=- (2)))
  RECORD tnstgt(
    1 cnt = i2
    1 db_name = vc
    1 db_vip_ext = vc
    1 db_port = vc
    1 db_domain = vc
    1 global_status_ind = i2
    1 qual[*]
      2 tns_key = vc
      2 tns_key_full = vc
      2 db_domain = vc
      2 tns_key_type_cd = i2
      2 mod_ind = i2
      2 status_ind = i2
      2 instance_name = vc
      2 host_name = vc
      2 line_cnt = i2
      2 qual[*]
        3 text = vc
  )
 ENDIF
 IF ((validate(tns_reply->process,- (1))=- (1))
  AND (validate(tns_reply->process,- (2))=- (2)))
  RECORD tns_reply(
    1 process = vc
    1 user_selection = vc
    1 status_ind = i2
    1 message = vc
  )
 ENDIF
 IF (validate(dtr_tns_details->vip_extension,"A")="A"
  AND validate(dtr_tns_details->vip_extension,"B")="B")
  FREE RECORD dtr_tns_details
  RECORD dtr_tns_details(
    1 spfile_ind = i2
    1 vip_extension = vc
    1 desired_db_domain = vc
  )
 ENDIF
 IF (validate(dtr_tns_templs->cnt,1)=1
  AND validate(dtr_tns_templs->cnt,2)=2)
  FREE RECORD dtr_tns_templs
  RECORD dtr_tns_templs(
    1 cnt = i4
    1 qual[*]
      2 token_name = vc
      2 line_cnt = i4
      2 lines[*]
        3 line = vc
    1 token_cnt = i4
    1 tokens[*]
      2 token_name = vc
      2 token_value = vc
    1 tgt_line_cnt = i4
    1 tgt_template[*]
      2 line = vc
    1 all_tgt_template_cnt = i4
    1 all_tgt_templates[*]
      2 line_cnt = i4
      2 qual[*]
        3 line = vc
  )
 ENDIF
 IF (validate(dtr_instance_data->ping_fail_ind,1)=1
  AND validate(dtr_instance_data->ping_fail_ind,2)=2)
  FREE RECORD dtr_instance_data
  RECORD dtr_instance_data(
    1 ping_fail_ind = i2
    1 qual[*]
      2 port_number = i4
      2 ping_fail_ind = i2
      2 emsg = vc
  )
 ENDIF
 IF (validate(dtr_connectivity->cnt,1)=1
  AND validate(dtr_connectivity->cnt,2)=2)
  FREE RECORD dtr_connectivity
  RECORD dtr_connectivity(
    1 cnt = i4
    1 qual[*]
      2 connect_string = vc
      2 connect_ind = i2
      2 emsg = vc
    1 connect_fail_ind = i2
  )
 ENDIF
 SUBROUTINE dtr_parse_tns(dpt_fl,dpt_fn)
   DECLARE dpt_file_location = vc WITH protect, noconstant(dpt_fl)
   DECLARE dpt_file_name = vc WITH protect, noconstant(dpt_fn)
   DECLARE dpt_file_loc = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE rline_nospaces = vc WITH protect, noconstant("DM2NOTSET")
   IF ( NOT (validate(dm2_tgt_db_type_flag,"XXX") IN ("ADMIN", "ADMMIG")))
    IF ((tnswork->inst_cnt=0))
     SET dm_err->eproc = "Loading database instances."
     SELECT INTO "nl:"
      g.instance_name, g.host_name
      FROM gv$instance g
      DETAIL
       tnswork->inst_cnt = (tnswork->inst_cnt+ 1), stat = alterlist(tnswork->inst,tnswork->inst_cnt),
       tnswork->inst[tnswork->inst_cnt].instance_name = g.instance_name,
       tnswork->inst[tnswork->inst_cnt].host_name = g.host_name
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc) > 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF (dpt_file_location <= "")
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dpt_file_location = "ora_root:[network.admin]"
    ELSE
     SET dpt_file_location = build(logical("ORACLE_HOME"),"/network/admin/")
    ENDIF
   ENDIF
   IF (dpt_file_name="")
    SET dpt_file_name = "tnsnames.ora"
   ENDIF
   FREE DEFINE rtl3
   FREE SET dpt_file_loc
   SET logical dpt_file_loc value(build(dpt_file_location,dpt_file_name))
   DEFINE rtl3 "dpt_file_loc"
   SET dm_err->eproc = build("Parsing <",dpt_file_location,dpt_file_name,">")
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    r.line
    FROM rtl3t r
    HEAD REPORT
     charcnt = 0, newtnskeyline = 1, openparen_cnt = 0,
     closeparen_cnt = 0, connectdata_cnt = 0, description_cnt = 0,
     addresslist_cnt = 0, test_cnt = 0
    DETAIL
     test_cnt = (test_cnt+ 1), rline_nospaces = cnvtlower(trim(r.line,4))
     IF (rline_nospaces > "")
      IF (substring(1,1,rline_nospaces)="#")
       IF (newtnskeyline=1)
        tnswork->cnt = (tnswork->cnt+ 1), stat = alterlist(tnswork->qual,tnswork->cnt)
       ENDIF
       tnswork->qual[tnswork->cnt].tns_key = " ", tnswork->qual[tnswork->cnt].tns_key_type_cd = 1,
       tnswork->qual[tnswork->cnt].line_cnt = (tnswork->qual[tnswork->cnt].line_cnt+ 1),
       stat = alterlist(tnswork->qual[tnswork->cnt].qual,tnswork->qual[tnswork->cnt].line_cnt)
       IF ((tnswork->qual[tnswork->cnt].line_cnt > 1)
        AND substring(1,1,r.line) != " ")
        tnswork->qual[tnswork->cnt].qual[tnswork->qual[tnswork->cnt].line_cnt].text = concat(" ",r
         .line), tnswork->qual[tnswork->cnt].chg_format_ind = 1
       ELSE
        tnswork->qual[tnswork->cnt].qual[tnswork->qual[tnswork->cnt].line_cnt].text = r.line
       ENDIF
      ELSE
       IF (((connectdata_cnt > 1) OR (((description_cnt > 1) OR (addresslist_cnt > 1)) )) )
        dm_err->emsg = concat("The TNS Key ",tnswork->qual[tnswork->cnt].tns_key,
         " appears to have mismatching parentheses."), dm_err->user_action =
        "Please correct the tnsnames.ora file and try again.", dm_err->err_ind = 1,
        BREAK
       ELSE
        IF (newtnskeyline=1)
         tnswork->cnt = (tnswork->cnt+ 1), stat = alterlist(tnswork->qual,tnswork->cnt), tnswork->
         qual[tnswork->cnt].tns_key_type_cd = 2,
         tnswork->qual[tnswork->cnt].tns_key_full = substring(1,(findstring("=",rline_nospaces) - 1),
          rline_nospaces), tnswork->qual[tnswork->cnt].tns_key = substring(1,(findstring(".",
           rline_nospaces) - 1),rline_nospaces), tnswork->qual[tnswork->cnt].db_domain = substring((
          findstring(".",rline_nospaces)+ 1),(findstring("=",rline_nospaces) - 1),rline_nospaces),
         newtnskeyline = 0
        ENDIF
        IF ((tnswork->qual[tnswork->cnt].tns_key=concat("listeners_",tnswork->db_name)))
         IF (newtnskeyline=1
          AND (tnswork->db_domain="DM2NOTSET"))
          tnswork->db_domain = substring((findstring(".",rline_nospaces)+ 1),(findstring("=",
            rline_nospaces) - 1),rline_nospaces)
         ELSE
          IF ((((tnswork->db_vip_ext="DM2NOTSET")) OR ((((tnswork->db_host_name="DM2NOTSET")) OR ((
          tnswork->db_host_clause="DM2NOTSET"))) ))
           AND findstring("host=",rline_nospaces) > 0)
           FOR (instcnt = 1 TO tnswork->inst_cnt)
            host_pos = findstring(concat("host=",tnswork->inst[instcnt].host_name),rline_nospaces),
            IF (host_pos > 0)
             tnswork->db_host_name = tnswork->inst[instcnt].host_name, tnswork->db_host_clause =
             substring((host_pos+ 5),findstring(")",rline_nospaces,host_pos),rline_nospaces), tnswork
             ->db_vip_ext = substring(((host_pos+ size(tnswork->inst[instcnt].host_name))+ 5),
              findstring(")",rline_nospaces,host_pos),rline_nospaces)
            ENDIF
           ENDFOR
          ENDIF
          IF ((tnswork->db_port="DM2NOTSET")
           AND findstring("port=",rline_nospaces) > 0)
           port_pos = (findstring("port=",rline_nospaces)+ 5), tnswork->db_port = substring(port_pos,
            findstring(")",rline_nospaces,host_pos),rline_nospaces)
          ENDIF
         ENDIF
        ENDIF
        IF (findstring("load_balance",rline_nospaces)=0)
         tnswork->qual[tnswork->cnt].line_cnt = (tnswork->qual[tnswork->cnt].line_cnt+ 1), stat =
         alterlist(tnswork->qual[tnswork->cnt].qual,tnswork->qual[tnswork->cnt].line_cnt)
         IF ((tnswork->qual[tnswork->cnt].line_cnt=1))
          tnswork->qual[tnswork->cnt].qual[tnswork->qual[tnswork->cnt].line_cnt].text = trim(r.line,2
           )
         ELSEIF (substring(1,1,r.line)=" ")
          tnswork->qual[tnswork->cnt].qual[tnswork->qual[tnswork->cnt].line_cnt].text = r.line
         ELSE
          tnswork->qual[tnswork->cnt].qual[tnswork->qual[tnswork->cnt].line_cnt].text = concat(" ",r
           .line), tnswork->qual[tnswork->cnt].chg_format_ind = 1
         ENDIF
        ENDIF
        IF (findstring("CONNECT_DATA",rline_nospaces) > 0)
         connectdata_cnt = (connectdata_cnt+ 1)
        ENDIF
        IF (findstring("DESCRIPTION",rline_nospaces) > 0)
         description_cnt = (description_cnt+ 1)
        ENDIF
        IF (findstring("ADDRESS_LIST",rline_nospaces) > 0)
         addresslist_cnt = (addresslist_cnt+ 1)
        ENDIF
        FOR (charcnt = 1 TO size(rline_nospaces))
          IF (substring(charcnt,1,rline_nospaces)="(")
           openparen_cnt = (openparen_cnt+ 1)
          ELSEIF (substring(charcnt,1,rline_nospaces)=")")
           closeparen_cnt = (closeparen_cnt+ 1)
          ENDIF
        ENDFOR
        IF (openparen_cnt > 0
         AND ((openparen_cnt - closeparen_cnt)=0))
         newtnskeyline = 1, connectdata_cnt = 0, description_cnt = 0,
         addresslist_cnt = 0, openparen_cnt = 0, closeparen_cnt = 0
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_copy_to_tnstgt(null)
   DECLARE tmpcnt1 = i4 WITH protect, noconstant(0)
   DECLARE tmpcnt2 = i4 WITH protect, noconstant(0)
   IF ((tnstgt->cnt > 0))
    FOR (tmpcnt1 = 1 TO tnstgt->cnt)
     SET tnstgt->qual[tmpcnt1].line_cnt = 0
     SET stat = alterlist(tnstgt->qual[tmpcnt1].qual,tnstgt->qual[tmpcnt1].line_cnt)
    ENDFOR
   ENDIF
   SET tnstgt->cnt = 0
   SET stat = alterlist(tnstgt->qual,tnstgt->cnt)
   SET tnstgt->cnt = tnswork->cnt
   SET stat = alterlist(tnstgt->qual,tnstgt->cnt)
   SET tmpcnt = 0
   SET tnstgt->db_vip_ext = tnswork->db_vip_ext
   SET tnstgt->db_port = tnswork->db_port
   SET tnstgt->db_domain = tnswork->db_domain
   FOR (tmpcnt1 = 1 TO tnswork->cnt)
     SET tnstgt->qual[tmpcnt1].mod_ind = 0
     SET tnstgt->qual[tmpcnt1].tns_key = tnswork->qual[tmpcnt1].tns_key
     SET tnstgt->qual[tmpcnt1].tns_key_full = tnswork->qual[tmpcnt1].tns_key_full
     SET tnstgt->qual[tmpcnt1].db_domain = tnswork->qual[tmpcnt1].db_domain
     SET tnstgt->qual[tmpcnt1].tns_key_type_cd = tnswork->qual[tmpcnt1].tns_key_type_cd
     SET tnstgt->qual[tmpcnt1].line_cnt = tnswork->qual[tmpcnt1].line_cnt
     IF ((tnstgt->qual[tmpcnt1].line_cnt > 0))
      SET stat = alterlist(tnstgt->qual[tmpcnt1].qual,tnstgt->qual[tmpcnt1].line_cnt)
      FOR (tmpcnt2 = 1 TO tnstgt->qual[tmpcnt1].line_cnt)
        SET tnstgt->qual[tmpcnt1].qual[tmpcnt2].text = tnswork->qual[tmpcnt1].qual[tmpcnt2].text
      ENDFOR
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_merge_to_tnstgt(null)
   DECLARE mrgcnt1 = i4 WITH protect, noconstant(0)
   DECLARE mrgcnt2 = i4 WITH protect, noconstant(0)
   DECLARE mrgloc = i4 WITH protect, noconstant(0)
   FOR (mrgcnt1 = 1 TO tnswork->cnt)
     IF ((tnswork->qual[mrgcnt1].merge_ind=1))
      SET mrgloc = locateval(mrgloc,1,tnstgt->cnt,tnswork->qual[mrgcnt1].tns_key,tnstgt->qual[mrgloc]
       .tns_key)
      IF (mrgloc > 0)
       SET tnstgt->qual[mrgloc].mod_ind = 2
       SET tnstgt->qual[mrgloc].tns_key_full = tnswork->qual[mrgcnt1].tns_key_full
       SET tnstgt->qual[mrgloc].db_domain = tnswork->qual[mrgcnt1].db_domain
       SET tnstgt->qual[mrgloc].tns_key_type_cd = tnswork->qual[mrgcnt1].tns_key_type_cd
       SET tnstgt->qual[mrgloc].line_cnt = tnswork->qual[mrgcnt1].line_cnt
       IF ((tnstgt->qual[mrgloc].line_cnt > 0))
        SET stat = alterlist(tnstgt->qual[mrgloc].qual,tnstgt->qual[mrgloc].line_cnt)
        FOR (mrgcnt2 = 1 TO tnstgt->qual[mrgloc].line_cnt)
          SET tnstgt->qual[mrgloc].qual[mrgcnt2].text = tnswork->qual[mrgcnt1].qual[mrgcnt2].text
        ENDFOR
       ENDIF
      ELSE
       SET tnstgt->cnt = (tnstgt->cnt+ 1)
       SET stat = alterlist(tnstgt->qual,tnstgt->cnt)
       SET tnstgt->qual[tnstgt->cnt].mod_ind = 1
       SET tnstgt->qual[tnstgt->cnt].tns_key = tnswork->qual[mrgcnt1].tns_key
       SET tnstgt->qual[tnstgt->cnt].tns_key_full = tnswork->qual[mrgcnt1].tns_key_full
       SET tnstgt->qual[tnstgt->cnt].db_domain = tnswork->qual[mrgcnt1].db_domain
       SET tnstgt->qual[tnstgt->cnt].tns_key_type_cd = tnswork->qual[mrgcnt1].tns_key_type_cd
       SET tnstgt->qual[tnstgt->cnt].line_cnt = tnswork->qual[mrgcnt1].line_cnt
       IF ((tnstgt->qual[tnstgt->cnt].line_cnt > 0))
        SET stat = alterlist(tnstgt->qual[tnstgt->cnt].qual,tnstgt->qual[tnstgt->cnt].line_cnt)
        FOR (mrgcnt2 = 1 TO tnstgt->qual[tnstgt->cnt].line_cnt)
          SET tnstgt->qual[tnstgt->cnt].qual[mrgcnt2].text = tnswork->qual[mrgcnt1].qual[mrgcnt2].
          text
        ENDFOR
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_reset_tnswork(null)
   IF ((tnswork->cnt > 0))
    FOR (tmpcnt1 = 1 TO tnswork->cnt)
      SET tnswork->qual[tmpcnt1].line_cnt = 0
      SET stat = alterlist(tnswork->qual[tmpcnt1].qual,tnswork->qual[tmpcnt1].line_cnt)
      SET tnswork->qual[tmpcnt1].tc_inst_cnt = 0
      SET stat = alterlist(tnswork->qual[tmpcnt1].tcl,tnswork->qual[tmpcnt1].tc_inst_cnt)
    ENDFOR
   ENDIF
   SET tnswork->cnt = 0
   SET stat = alterlist(tnswork->qual,tnswork->cnt)
   SET tnswork->db_name = "DM2NOTSET"
   SET tnswork->db_connected = 0
   SET tnswork->db_vip_ext = "DM2NOTSET"
   SET tnswork->db_port = "DM2NOTSET"
   SET tnswork->db_host_name = "DM2NOTSET"
   SET tnswork->db_host_clause = "DM2NOTSET"
   SET tnswork->db_domain = "DM2NOTSET"
   SET tnswork->tc_user = "DM2NOTSET"
   SET tnswork->tc_pwd = "DM2NOTSET"
   SET tnswork->inst_cnt = 0
   SET stat = alterlist(tnswork->inst,tnswork->inst_cnt)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_tns_generate(dtg_file_location,dtg_file_name)
   DECLARE dtg_file_location2 = vc WITH protect, noconstant(trim(logical("CCLUSERDIR"),3))
   DECLARE dtg_file_name2 = vc WITH protect, noconstant("tnsnames.ora")
   DECLARE dtg_path_delim = vc WITH protect, noconstant("/")
   DECLARE dtg_report_str = vc WITH protect, noconstant("DM2NOTSET")
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dtg_path_delim = ":"
   ENDIF
   SET dm_err->eproc = "Validating destination directory."
   IF (dtg_file_location > "")
    SET dtg_file_location2 = concat(trim(dtg_file_location,3),dtg_path_delim)
   ELSEIF (((dtg_file_location="ora_root:[network.admin]") OR (dtg_file_location=build(logical(
     "ORACLE_HOME"),"/network/admin/"))) )
    SET dm_err->emsg = "Cannot generate new tnsnames.ora file directly in the TNS_ADMIN directory."
    SET dm_err->err_ind = 1
   ELSE
    SET dtg_file_location2 = concat(dtg_file_location2,dtg_path_delim)
   ENDIF
   IF (dtg_file_name > "")
    SET dtg_file_name2 = dtg_file_name
   ENDIF
   SET dm_err->eproc = build("Generating <",dtg_file_location2,dtg_file_name2,">")
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO value(build(dtg_file_location2,dtg_file_name2))
    d.seq
    FROM (dummyt d  WITH seq = tnstgt->cnt)
    HEAD REPORT
     rptseq = 0
    DETAIL
     rptseq = 0
     FOR (rptseq = 1 TO tnstgt->qual[d.seq].line_cnt)
       col + 0, tnstgt->qual[d.seq].qual[rptseq].text, row + 1
     ENDFOR
    WITH nocounter, maxrow = 1, noformfeed,
     maxcol = 2000, format = lfstream
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_tns_confirm(dtc_file_location,dtc_file_name)
   DECLARE dtc_user_viewed_ind = i2 WITH protect, noconstant(0)
   DECLARE dtc_done = i2 WITH protect, noconstant(0)
   DECLARE dtc_file_location2 = vc WITH protect, noconstant(trim(logical("CCLUSERDIR"),3))
   DECLARE dtc_file_name2 = vc WITH protect, noconstant("tnsnames.ora")
   DECLARE dtc_path_delim = vc WITH protect, noconstant("/")
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dtc_path_delim = ":"
   ENDIF
   SET tns_reply->process = "tns_confirm"
   IF (dtc_file_location > "")
    SET dtc_file_location2 = concat(trim(dtc_file_location,3),dtc_path_delim)
   ELSE
    SET dtc_file_location2 = concat(dtc_file_location2,dtc_path_delim)
   ENDIF
   IF (dtc_file_name > "")
    SET dtc_file_name2 = trim(dtc_file_name,3)
   ENDIF
   SET width = 132
   SET message = window
   WHILE (dtc_done=0)
     CALL clear(1,1)
     CALL box(1,1,5,132)
     CALL text(3,44,"***  VERIFY TNSNAMES.ORA FILE  ***")
     CALL text(7,3,build("A new file named <",dtc_file_name2,"> has been generated to <",
       dtc_file_location2,">."))
     CALL text(8,3,"Please view and then confirm that the file is accurate before proceeding.")
     IF (dtc_user_viewed_ind=0)
      CALL text(10,3,"(V)iew, (E)xit")
      CALL accept(10,30,"P;CU","V"
       WHERE curaccept IN ("V", "E"))
     ELSE
      CALL text(10,3,"(V)iew, (C)onfirm, (E)xit")
      CALL accept(10,30,"P;CU","C"
       WHERE curaccept IN ("V", "C", "E"))
     ENDIF
     CASE (curaccept)
      OF "V":
       SET message = nowindow
       CALL echo(dm2_sys_misc->cur_os)
       CALL echo(build(dtc_file_location2,dtc_file_name2))
       FREE SET dtc_file_loc
       SET logical dtc_file_loc value(build(dtc_file_location2,dtc_file_name2))
       FREE DEFINE rtl2
       DEFINE rtl2 "dtc_file_loc"
       SELECT
        r.line
        FROM rtl2t r
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc) > 0)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        RETURN(0)
       ENDIF
       SET dtc_user_viewed_ind = 1
       SET tns_reply->message = "File viewed"
       SET message = window
      OF "C":
       IF (dtc_user_viewed_ind=1)
        SET message = nowindow
        SET dtc_done = 1
       ENDIF
      OF "E":
       SET message = nowindow
       SET dm_err->emsg = "User chose to quit."
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       RETURN(0)
     ENDCASE
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_tns_deploy(dtd_file_location,dtd_file_name)
   DECLARE dtd_file_location2 = vc WITH protect, noconstant(trim(logical("CCLUSERDIR"),3))
   DECLARE dtd_file_name2 = vc WITH protect, noconstant("tnsnames.ora")
   DECLARE dtd_path_delim = vc WITH protect, noconstant("/")
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dtd_path_delim = ":"
   ENDIF
   SET tns_reply->process = "tns_deploy"
   IF (dtd_file_location > "")
    SET dtd_file_location2 = concat(trim(dtd_file_location,3),dtd_path_delim)
   ELSE
    SET dtd_file_location2 = concat(dtd_file_location2,dtd_path_delim)
   ENDIF
   IF (dtd_file_name > "")
    SET dtd_file_name2 = trim(dtd_file_name,3)
   ENDIF
   SET width = 132
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,5,132)
   CALL text(3,44,"***  DEPLOYMENT STEPS FOR TNSNAMES.ORA FILE  ***")
   CALL text(7,3,build("For each application and database node in the <",logical("environment"),
     "> environment, perform the following steps:"))
   CALL text(9,3,"1) Make a backup copy of the existing tnsnames.ora file.")
   CALL text(10,3,concat("2) From this node, copy file <",dtd_file_name2,"> from directory <",
     dtd_file_location2,">"))
   CALL text(11,3,concat(
     "   to the ORACLE_HOME/network/admin directory of each application and database node."))
   CALL text(13,3,
    "Please continue from this prompt ONLY AFTER the new tnsnames.ora file has been deployed ")
   CALL text(14,3,"successfully to all database and application nodes.")
   CALL text(16,3,"(C)ontinue, (E)xit")
   CALL accept(16,30,"P;CU","C"
    WHERE curaccept IN ("C", "E"))
   SET tns_reply->user_selection = curaccept
   SET message = nowindow
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_tns_test_connect(null)
   DECLARE dttc_for_cnt = i4 WITH protect, noconstant(0)
   DECLARE dttc_done = i2 WITH protect, noconstant(0)
   DECLARE dttc_instance_str = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dttc_position_int = i4 WITH protect, noconstant(0)
   FOR (dttc_for_cnt = 1 TO tnswork->cnt)
     IF ((tnswork->qual[dttc_for_cnt].tc_option > 0))
      SET dttc_done = 0
      WHILE (dttc_done=0)
        SET dm_err->err_ind = 0
        SET dm2_install_schema->u_name = tnswork->tc_user
        SET dm2_install_schema->p_word = tnswork->tc_pwd
        SET dm2_install_schema->connect_str = tnswork->qual[dttc_for_cnt].tns_key
        EXECUTE dm2_connect_to_dbase "CO"
        IF ((dm_err->err_ind=0))
         IF ((tnswork->inst_cnt > 0))
          SET dm_err->eproc = ""
          SELECT INTO "nl:"
           i.instance_name, i.host_name
           FROM gv$instance i
           DETAIL
            tnswork->inst_cnt = (tnswork->inst_cnt+ 1), stat = alterlist(tnswork->inst,tnswork->
             inst_cnt), tnswork->inst[tnswork->inst_cnt].instance_name = i.instance_name,
            tnswork->inst[tnswork->inst_cnt].host_name = i.host_name
           WITH nocounter
          ;end select
          IF (check_error(dm_err->eproc) > 0)
           CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
           RETURN(0)
          ENDIF
         ENDIF
         SET tnswork->qual[dttc_for_cnt].tc_num_connects = (tnswork->qual[dttc_for_cnt].
         tc_num_connects+ 1)
         SELECT INTO "nl:"
          v.instance_name
          FROM v$instance v
          DETAIL
           dttc_instance_str = v.instance_name
          WITH nocounter
         ;end select
         IF (check_error(dm_err->eproc) > 0)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
          RETURN(0)
         ENDIF
         SET dttc_position_int = locateval(dttc_position_int,1,tnswork->qual[dttc_for_cnt].
          tc_inst_cnt,dttc_instance_str,tnswork->qual[dttc_for_cnt].tcl[dttc_position_int].
          instance_name)
         IF (dttc_position_int=0)
          SET tnswork->qual[dttc_for_cnt].tc_inst_cnt = (tnswork->qual[dttc_for_cnt].tc_inst_cnt+ 1)
          SET stat = alterlist(tnswork->qual[dttc_for_cnt].tcl,tnswork->qual[dttc_for_cnt].
           tc_inst_cnt)
          SET tnswork->qual[dttc_for_cnt].tcl[tnswork->qual[dttc_for_cnt].tc_inst_cnt].instance_name
           = dttc_instance_str
         ENDIF
         IF ((((tnswork->qual[dttc_for_cnt].tc_option=2)) OR ((((tnswork->qual[dttc_for_cnt].
         tc_inst_cnt=tnswork->inst_cnt)) OR ((tnswork->qual[dttc_for_cnt].tc_num_connects=50))) )) )
          SET dttc_done = 1
         ENDIF
        ENDIF
      ENDWHILE
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_get_tns_details(null)
   WHILE (true)
     SET message = window
     CALL clear(1,1)
     CALL box(1,1,24,131)
     CALL text(2,2,"Generate Cerner Database Services tnsnames.ora entries - Details")
     CALL text(4,2,"Please verify / supply the following database host information.")
     CALL text(6,2,"ORACLE VIP EXTENSION (e.g. '_oracle'): ")
     CALL video(r)
     CALL text(6,41,dtr_tns_details->vip_extension)
     CALL video(n)
     CALL text(7,2,concat(
       "This extension is appended to the host names to form a proper host name that represents the",
       " Oracle VIP for the database cluster."))
     CALL text(9,2,"db_domain (e.g. 'world'): ")
     CALL video(r)
     CALL text(9,28,dtr_tns_details->desired_db_domain)
     CALL video(n)
     CALL text(10,2,"This is the domain extension value to use for all generated connect strings.")
     CALL text(16,2,"(M)odify, (C)ontinue, (Q)uit: ")
     CALL accept(16,32,"A;CU","C"
      WHERE curaccept IN ("M", "C", "Q"))
     CASE (curaccept)
      OF "Q":
       SET message = nowindow
       CALL clear(1,1)
       RETURN(0)
      OF "M":
       CALL accept(6,41,"P(20);C",dtr_tns_details->vip_extension)
       SET dtr_tns_details->vip_extension = curaccept
       CALL accept(9,28,"A(50);C",dtr_tns_details->desired_db_domain)
       SET dtr_tns_details->desired_db_domain = curaccept
      OF "C":
       SET message = nowindow
       CALL clear(1,1)
       RETURN(1)
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE dtr_get_host_port_numbers(null)
   DECLARE dghpn_iter = i4 WITH protect, noconstant(0)
   DECLARE dghpn_temp_num = i4 WITH protect, noconstant(0)
   WHILE (true)
     SET message = window
     CALL clear(1,1)
     CALL box(1,1,24,131)
     CALL text(2,2,"Generate Cerner Database Services tnsnames.ora entries - Listener Port Numbers")
     CALL text(4,7,"Host Name")
     CALL text(4,58,"Listener Port Number")
     CALL text(5,7,fillstring(50,"-"))
     CALL text(5,58,fillstring(20,"-"))
     FOR (dghpn_iter = 1 TO least(16,daic_rac_inst_data->instance_cnt))
       CALL text((5+ dghpn_iter),2,build(dghpn_iter,"."))
       CALL text((5+ dghpn_iter),7,daic_rac_inst_data->qual[dghpn_iter].partial_host_name)
       CALL text((5+ dghpn_iter),58,cnvtstring(dtr_instance_data->qual[dghpn_iter].port_number))
     ENDFOR
     CALL text(23,2,"(M)odify Port, (C)ontinue, (Q)uit: ")
     CALL accept(23,37,"A;CU","C"
      WHERE curaccept IN ("M", "C", "Q"))
     CASE (curaccept)
      OF "Q":
       SET message = nowindow
       CALL clear(1,1)
       RETURN(0)
      OF "M":
       CALL clear(23,2,129)
       CALL text(23,2,"Which host's listener port number would you like to change (e.g. 2)?")
       CALL accept(23,71,"99",0
        WHERE curaccept BETWEEN 0 AND 16)
       SET dghpn_temp_num = curaccept
       IF (dghpn_temp_num > 0
        AND (dghpn_temp_num <= daic_rac_inst_data->instance_cnt))
        CALL accept((5+ dghpn_temp_num),58,"999999")
        SET dtr_instance_data->qual[dghpn_temp_num].port_number = curaccept
       ENDIF
      OF "C":
       SET message = nowindow
       CALL clear(1,1)
       RETURN(1)
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE dtr_import_tns_templates(null)
   SET stat = initrec(dtr_tns_templs)
   FREE DEFINE rtl
   FREE SET ditt_file_loc
   SET logical ditt_file_loc "cer_install:dm2_tns_templ_svc.txt"
   DEFINE rtl "ditt_file_loc"
   SET dm_err->eproc = "Reading cer_install:dm2_tns_templ_svc.txt."
   SELECT INTO "nl:"
    FROM rtlt r
    HEAD REPORT
     dtr_tns_templs->cnt = (dtr_tns_templs->cnt+ 1), stat = alterlist(dtr_tns_templs->qual,
      dtr_tns_templs->cnt), dtr_tns_templs->qual[dtr_tns_templs->cnt].token_name = "<service>"
    DETAIL
     dtr_tns_templs->qual[dtr_tns_templs->cnt].line_cnt = (dtr_tns_templs->qual[dtr_tns_templs->cnt].
     line_cnt+ 1), stat = alterlist(dtr_tns_templs->qual[dtr_tns_templs->cnt].lines,dtr_tns_templs->
      qual[dtr_tns_templs->cnt].line_cnt), dtr_tns_templs->qual[dtr_tns_templs->cnt].lines[
     dtr_tns_templs->qual[dtr_tns_templs->cnt].line_cnt].line = r.line
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   FREE DEFINE rtl
   FREE SET ditt_file_loc
   SET logical ditt_file_loc "cer_install:dm2_tns_templ_inst.txt"
   DEFINE rtl "ditt_file_loc"
   SET dm_err->eproc = "Reading cer_install:dm2_tns_templ_inst.txt."
   SELECT INTO "nl:"
    FROM rtlt r
    HEAD REPORT
     dtr_tns_templs->cnt = (dtr_tns_templs->cnt+ 1), stat = alterlist(dtr_tns_templs->qual,
      dtr_tns_templs->cnt), dtr_tns_templs->qual[dtr_tns_templs->cnt].token_name = "<instance>"
    DETAIL
     dtr_tns_templs->qual[dtr_tns_templs->cnt].line_cnt = (dtr_tns_templs->qual[dtr_tns_templs->cnt].
     line_cnt+ 1), stat = alterlist(dtr_tns_templs->qual[dtr_tns_templs->cnt].lines,dtr_tns_templs->
      qual[dtr_tns_templs->cnt].line_cnt), dtr_tns_templs->qual[dtr_tns_templs->cnt].lines[
     dtr_tns_templs->qual[dtr_tns_templs->cnt].line_cnt].line = r.line
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   FREE DEFINE rtl
   FREE SET ditt_file_loc
   SET logical ditt_file_loc "cer_install:dm2_tns_templ_address.txt"
   DEFINE rtl "ditt_file_loc"
   SET dm_err->eproc = "Reading cer_install:dm2_tns_templ_address.txt."
   SELECT INTO "nl:"
    FROM rtlt r
    HEAD REPORT
     dtr_tns_templs->cnt = (dtr_tns_templs->cnt+ 1), stat = alterlist(dtr_tns_templs->qual,
      dtr_tns_templs->cnt), dtr_tns_templs->qual[dtr_tns_templs->cnt].token_name = "<address>"
    DETAIL
     dtr_tns_templs->qual[dtr_tns_templs->cnt].line_cnt = (dtr_tns_templs->qual[dtr_tns_templs->cnt].
     line_cnt+ 1), stat = alterlist(dtr_tns_templs->qual[dtr_tns_templs->cnt].lines,dtr_tns_templs->
      qual[dtr_tns_templs->cnt].line_cnt), dtr_tns_templs->qual[dtr_tns_templs->cnt].lines[
     dtr_tns_templs->qual[dtr_tns_templs->cnt].line_cnt].line = r.line
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dtr_tns_templs)
   ENDIF
   FREE DEFINE rtl
   FREE SET ditt_file_loc
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_setup_tgt_template(token_name)
   DECLARE dstt_iter = i4 WITH protect, noconstant(0)
   DECLARE dstt_iter2 = i4 WITH protect, noconstant(0)
   DECLARE dstt_temp = i4 WITH protect, noconstant(0)
   DECLARE dstt_address = i4 WITH protect, noconstant(0)
   IF ( NOT (assign(dstt_temp,locateval(dstt_temp,1,dtr_tns_templs->cnt,token_name,dtr_tns_templs->
     qual[dstt_temp].token_name))))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Searching for given token_name in service template management"
    SET dm_err->emsg = concat("Unable to find given token_name: ",token_name)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ( NOT (assign(dstt_address,locateval(dstt_address,1,dtr_tns_templs->cnt,"<address>",
     dtr_tns_templs->qual[dstt_address].token_name))))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Searching for given token_name in service template management"
    SET dm_err->emsg = "Unable to find <address> token."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc =
   "Transferring single token from qual portion of record stucture to tgt_template portion."
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(dtr_tns_templs->qual[dstt_temp].line_cnt))
    HEAD REPORT
     dtr_tns_templs->tgt_line_cnt = 0, stat = alterlist(dtr_tns_templs->tgt_template,0)
    DETAIL
     IF (findstring("<cern_host_list>",dtr_tns_templs->qual[dstt_temp].lines[d.seq].line))
      FOR (dstt_iter = 1 TO evaluate(token_name,"<service>",daic_rac_inst_data->instance_cnt,1))
        FOR (dstt_iter2 = 1 TO dtr_tns_templs->qual[dstt_address].line_cnt)
          dtr_tns_templs->tgt_line_cnt = (dtr_tns_templs->tgt_line_cnt+ 1), stat = alterlist(
           dtr_tns_templs->tgt_template,dtr_tns_templs->tgt_line_cnt), dtr_tns_templs->tgt_template[
          dtr_tns_templs->tgt_line_cnt].line = replace(dtr_tns_templs->qual[dstt_temp].lines[d.seq].
           line,"<cern_host_list>",evaluate(token_name,"<service>",replace(dtr_tns_templs->qual[
             dstt_address].lines[dstt_iter2].line,">",build(dstt_iter,">")),dtr_tns_templs->qual[
            dstt_address].lines[dstt_iter2].line))
        ENDFOR
      ENDFOR
     ELSE
      dtr_tns_templs->tgt_line_cnt = (dtr_tns_templs->tgt_line_cnt+ 1), stat = alterlist(
       dtr_tns_templs->tgt_template,dtr_tns_templs->tgt_line_cnt), dtr_tns_templs->tgt_template[
      dtr_tns_templs->tgt_line_cnt].line = dtr_tns_templs->qual[dstt_temp].lines[d.seq].line
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dtr_tns_templs)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_complete_tgt_template(null)
   DECLARE dctt_iter = i4 WITH protect, noconstant(0)
   SET dm_err->eproc =
   "Completing tokens in tgt_template by replacing tokens with values in service template management."
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(dtr_tns_templs->tgt_line_cnt))
    DETAIL
     FOR (dctt_iter = 1 TO dtr_tns_templs->token_cnt)
       dtr_tns_templs->tgt_template[d.seq].line = replace(dtr_tns_templs->tgt_template[d.seq].line,
        dtr_tns_templs->tokens[dctt_iter].token_name,dtr_tns_templs->tokens[dctt_iter].token_value,0)
     ENDFOR
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dtr_tns_templs)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_clear_tokens(null)
  SET dtr_tns_templs->token_cnt = 0
  SET stat = alterlist(dtr_tns_templs->tokens,0)
 END ;Subroutine
 SUBROUTINE dtr_add_token(token_name,token_value)
  DECLARE dat_temp = i4 WITH protect, noconstant(0)
  IF (assign(dat_temp,locateval(dat_temp,1,dtr_tns_templs->token_cnt,token_name,dtr_tns_templs->
    tokens[dat_temp].token_name)))
   SET dtr_tns_templs->tokens[dat_temp].token_value = token_value
  ELSE
   SET dtr_tns_templs->token_cnt = (dtr_tns_templs->token_cnt+ 1)
   SET stat = alterlist(dtr_tns_templs->tokens,dtr_tns_templs->token_cnt)
   SET dtr_tns_templs->tokens[dtr_tns_templs->token_cnt].token_name = token_name
   SET dtr_tns_templs->tokens[dtr_tns_templs->token_cnt].token_value = token_value
  ENDIF
 END ;Subroutine
 SUBROUTINE dtr_copy_tgt_template(null)
   SET dm_err->eproc =
   "Transferring single tgt_template to all_tgt_templates for service template management."
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(dtr_tns_templs->tgt_line_cnt))
    HEAD REPORT
     dtr_tns_templs->all_tgt_template_cnt = (dtr_tns_templs->all_tgt_template_cnt+ 1), stat =
     alterlist(dtr_tns_templs->all_tgt_templates,dtr_tns_templs->all_tgt_template_cnt),
     dtr_tns_templs->all_tgt_templates[dtr_tns_templs->all_tgt_template_cnt].line_cnt =
     dtr_tns_templs->tgt_line_cnt,
     stat = alterlist(dtr_tns_templs->all_tgt_templates[dtr_tns_templs->all_tgt_template_cnt].qual,
      dtr_tns_templs->tgt_line_cnt)
    DETAIL
     dtr_tns_templs->all_tgt_templates[dtr_tns_templs->all_tgt_template_cnt].qual[d.seq].line =
     dtr_tns_templs->tgt_template[d.seq].line
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_display_tns_report(null)
   DECLARE ddtr_dbase_name = vc WITH protect, noconstant("")
   DECLARE ddtr_iter = i4 WITH protect, noconstant(0)
   IF ( NOT (dm2_get_dbase_name(ddtr_dbase_name)))
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Displaying tnsnames.ora entry report to the screen."
   SELECT INTO "mine"
    FROM (dummyt d  WITH seq = value(dtr_tns_templs->all_tgt_template_cnt))
    HEAD REPORT
     col 0,
     "#The following Cerner Database Service TNS entries should be added/updated into the local tnsnames.ora file.",
     row + 1,
     col 0, "", row + 1,
     col 0, "Warning:  To prevent connectivity issues:", row + 1,
     col 0, "1) Each of the following entries to be added/updated should be reviewed for accuracy.",
     row + 1,
     col 0, "2) Updates to a tnsnames.ora file should be carefully performed.", row + 1,
     col 0,
     "   Missing or extra characters (parenthesis for example) can render entire portions of a tnsnames.ora",
     row + 1,
     col 0, "   file unusable and disrupt existing connectivity.", row + 1,
     col 0, "3) New entries should always be added to the end of a tnsnames.ora file.  ", row + 1,
     col 0,
     "4) A copy of the current tnsnames.ora file should be saved under a saved name before making updates.",
     row + 1,
     col 0, "", row + 1,
     col 0, "#Cerner Database Services entries for ", ddtr_dbase_name,
     row + 1
    DETAIL
     FOR (ddtr_iter = 1 TO dtr_tns_templs->all_tgt_templates[d.seq].line_cnt)
       col 0, dtr_tns_templs->all_tgt_templates[d.seq].qual[ddtr_iter].line, row + 1
     ENDFOR
     col 0, "", row + 1
    WITH nocounter, maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_prompt_tns_confirmation(null)
   WHILE (true)
     SET message = window
     CALL clear(1,1)
     CALL box(1,1,24,131)
     CALL text(2,2,
      "Generate Cerner Database Services tnsnames.ora entries - TNS Deployment Verification")
     CALL text(4,10,build(
       "Please confirm the TNS entries have been deployed to the local application node (",curnode,
       ")"))
     CALL text(6,10,"(V)iew Cerner Database Services TNS Report")
     CALL text(7,10,"(C)ontinue, TNS entries have been deployed")
     CALL text(8,10,"(Q)uit")
     CALL text(10,10,"Selection:")
     CALL accept(10,21,"A;CU","V"
      WHERE curaccept IN ("V", "C", "Q"))
     CASE (curaccept)
      OF "Q":
       SET dm2_process_event_rs->status = dpl_decline
       CALL dm2_process_log_row(dpl_db_services,dpl_tns_deployment,dpl_no_prev_id,1)
       RETURN(0)
      OF "V":
       IF ( NOT (dtr_display_tns_report(null)))
        GO TO exit_script
       ENDIF
      OF "C":
       SET dm2_process_event_rs->status = dpl_confirmation
       CALL dm2_process_log_row(dpl_db_services,dpl_tns_deployment,dpl_no_prev_id,1)
       RETURN(1)
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE dtr_service_connectivity_test(null)
   DECLARE dsct_iter = i4 WITH protect, noconstant(0)
   DECLARE dsct_dbase_name = vc WITH protect, noconstant("")
   IF ( NOT (dm2_get_dbase_name(dsct_dbase_name)))
    RETURN(0)
   ENDIF
   SET message = nowindow
   CALL clear(1,1)
   SET dm2_install_schema->u_name = "CER_TST"
   SET dm2_install_schema->p_word = "EG"
   SET dtr_connectivity->connect_fail_ind = 0
   FOR (dsct_iter = 1 TO dtr_connectivity->cnt)
     SET dm2_install_schema->dbase_name = dtr_connectivity->qual[dsct_iter].connect_string
     SET dm2_install_schema->connect_str = dtr_connectivity->qual[dsct_iter].connect_string
     EXECUTE dm2_connect_to_dbase "CO"
     IF ((dm_err->emsg="*ORA-01017*"))
      SET dtr_connectivity->qual[dsct_iter].connect_ind = 1
     ELSE
      SET dtr_connectivity->connect_fail_ind = 1
      SET dtr_connectivity->qual[dsct_iter].connect_ind = 0
      SET dtr_connectivity->qual[dsct_iter].emsg = dm_err->emsg
     ENDIF
     SET dm_err->err_ind = 0
   ENDFOR
   IF (dtr_connectivity->connect_fail_ind)
    SET dm_err->eproc = "Displaying service connectivity failure report."
    SELECT INTO "mine"
     FROM (dummyt d  WITH seq = value(dtr_connectivity->cnt))
     HEAD REPORT
      col 0, "Connectivity Report for Database ", dsct_dbase_name,
      row + 2, col 0, "Connect String",
      col 31, "Status", col 41,
      "Message", row + 1, col 0,
      CALL print(fillstring(30,"-")), col 31,
      CALL print(fillstring(9,"-")),
      col 41,
      CALL print(fillstring(60,"-")), row + 1
     DETAIL
      col 0, dtr_connectivity->qual[d.seq].connect_string, col 31,
      CALL print(evaluate(dtr_connectivity->qual[d.seq].connect_ind,1,"SUCCESS","FAILURE"))
      IF ( NOT (dtr_connectivity->qual[d.seq].connect_ind))
       col 41,
       CALL print(substring(findstring("ORA-",dtr_connectivity->qual[d.seq].emsg),90,dtr_connectivity
        ->qual[d.seq].emsg))
      ENDIF
      row + 1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->eproc = "Displaying service connectivity success report."
    SELECT INTO "mine"
     FROM dummyt d
     HEAD REPORT
      col 0, "Connectivity Report for Database ", dsct_dbase_name,
      row + 2, col 0, "All Cerner Database Service connect strings were successfully tested."
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_populate_all_tns_stanzas(null)
   DECLARE dpats_iter = i4 WITH protect, noconstant(0)
   DECLARE dpats_dbase_name = vc WITH protect, noconstant("")
   IF ( NOT (dm2_get_dbase_name(dpats_dbase_name)))
    RETURN(0)
   ENDIF
   IF ( NOT (dtr_import_tns_templates(null)))
    GO TO exit_script
   ENDIF
   FOR (dpats_iter = 1 TO daic_rac_inst_data->instance_cnt)
     IF ( NOT (dtr_setup_tgt_template("<instance>")))
      GO TO exit_script
     ENDIF
     CALL dtr_clear_tokens(null)
     CALL dtr_add_token("<cern_db_domain>",dtr_tns_details->desired_db_domain)
     CALL dtr_add_token("<cern_instance_name>",daic_rac_inst_data->qual[dpats_iter].instance_name)
     CALL dtr_add_token("<cern_service_name>",cnvtlower(dpats_dbase_name))
     CALL dtr_add_token("<cern_vip_host_name>",concat(daic_rac_inst_data->qual[dpats_iter].
       partial_host_name,dtr_tns_details->vip_extension))
     CALL dtr_add_token("<cern_port>",build(dtr_instance_data->qual[dpats_iter].port_number))
     IF ( NOT (dtr_complete_tgt_template(null)))
      GO TO exit_script
     ENDIF
     IF ( NOT (dtr_copy_tgt_template(null)))
      GO TO exit_script
     ENDIF
   ENDFOR
   IF ( NOT (dtr_setup_tgt_template("<service>")))
    GO TO exit_script
   ENDIF
   CALL dtr_clear_tokens(null)
   CALL dtr_add_token("<cern_db_domain>",dtr_tns_details->desired_db_domain)
   FOR (dpats_iter = 1 TO daic_rac_inst_data->instance_cnt)
    CALL dtr_add_token(build("<cern_vip_host_name",dpats_iter,">"),concat(daic_rac_inst_data->qual[
      dpats_iter].partial_host_name,dtr_tns_details->vip_extension))
    CALL dtr_add_token(build("<cern_port",dpats_iter,">"),build(dtr_instance_data->qual[dpats_iter].
      port_number))
   ENDFOR
   CALL dtr_add_token("<cern_service_name>",cnvtlower(dpats_dbase_name))
   IF ( NOT (dtr_complete_tgt_template(null)))
    GO TO exit_script
   ENDIF
   IF ( NOT (dtr_copy_tgt_template(null)))
    GO TO exit_script
   ENDIF
   FOR (dpats_iter = 1 TO ddr_cerner_services->service_cnt)
     IF ( NOT (dtr_setup_tgt_template("<service>")))
      GO TO exit_script
     ENDIF
     CALL dtr_add_token("<cern_service_name>",ddr_cerner_services->service[dpats_iter].service_name)
     IF ( NOT (dtr_complete_tgt_template(null)))
      GO TO exit_script
     ENDIF
     IF ( NOT (dtr_copy_tgt_template(null)))
      GO TO exit_script
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE dtr_query_tns_details(null)
   SET dm_err->eproc = "Querying for db_domain/spfile from v$parameter."
   SELECT INTO "nl:"
    value_null_ind = nullind(vp.value)
    FROM v$parameter vp
    WHERE vp.name IN ("db_domain", "spfile")
    DETAIL
     CASE (vp.name)
      OF "db_domain":
       dtr_tns_details->desired_db_domain = cnvtlower(vp.value)
      OF "spfile":
       dtr_tns_details->spfile_ind = (1 - value_null_ind)
     ENDCASE
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dtr_tns_details->vip_extension = "_oracle"
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
 DECLARE dcdur_create_db_users(null) = i2
 DECLARE dcdur_report_db_users_diff_tspaces(null) = i2
 DECLARE dcdur_cleanup_pwds(dcp_in_dbname=vc) = i2
 DECLARE dcdur_insert_pwds(dip_in_dbname=vc,dip_in_type=vc,dip_in_user=vc,dip_in_pwd=vc) = i2
 DECLARE dcdur_preserve_pwds(dpp_in_dbname=vc) = i2
 DECLARE dcdur_restore_pwds(drp_in_dbname=vc,drp_in_mode=vc) = i2
 DECLARE dcdur_get_server_users_pwds(dgsup_in_domain=vc) = i2
 DECLARE dcdur_prompt_tspaces(dpt_user_name=vc,dpt_db_name=vc,dpt_user_idx=i4(ref)) = i2
 DECLARE dcdur_user_tspace_cleanup(dutc_user_name=vc,dutc_db_name=vc) = i2
 DECLARE dcdur_user_tspace_load(dutl_db_name=vc) = i2
 DECLARE dcdur_insert_admin_tspace_rows(diatr_user_name=vc,diatr_db_name=vc,diatr_temp_ts=vc,
  diatr_misc_ts=vc) = i2
 DECLARE dcdur_get_db_owner_pwds(dgdop_in_dbname=vc) = i2
 IF (validate(dcdur_input->src_user,"ABC")="ABC"
  AND validate(dcdur_input->src_user,"XYZ")="XYZ")
  FREE RECORD dcdur_input
  RECORD dcdur_input(
    1 src_user = vc
    1 src_pwd = vc
    1 src_cnct_str = vc
    1 tgt_user = vc
    1 tgt_pwd = vc
    1 tgt_cnct_str = vc
    1 user_list = vc
    1 fix_tspaces_ind = c1
    1 default_tspace = vc
    1 temp_tspace = vc
    1 tgt_dbname = vc
    1 connect_back = c1
    1 replace_tspaces = c1
    1 replace_pwds = c1
  )
  SET dcdur_input->src_user = ""
  SET dcdur_input->src_user = ""
  SET dcdur_input->src_pwd = ""
  SET dcdur_input->src_cnct_str = ""
  SET dcdur_input->tgt_user = ""
  SET dcdur_input->tgt_pwd = ""
  SET dcdur_input->tgt_cnct_str = ""
  SET dcdur_input->fix_tspaces_ind = ""
  SET dcdur_input->default_tspace = ""
  SET dcdur_input->default_tspace = ""
  SET dcdur_input->user_list = ""
  SET dcdur_input->tgt_dbname = ""
  SET dcdur_input->connect_back = ""
  SET dcdur_input->replace_tspaces = ""
  SET dcdur_input->replace_pwds = ""
 ENDIF
 IF (validate(dcdur_server_pwds->cnt,1)=1
  AND validate(dcdur_server_pwds->cnt,2)=2)
  FREE RECORD dcdur_server_pwds
  RECORD dcdur_server_pwds(
    1 cnt = i4
    1 qual[*]
      2 server = i4
      2 user = vc
      2 pwd = vc
  )
  SET dcdur_server_pwds->cnt = 0
 ENDIF
 IF (validate(dcdur_owner_pwds->cnt,1)=1
  AND validate(dcdur_owner_pwds->cnt,2)=2)
  FREE RECORD dcdur_owner_pwds
  RECORD dcdur_owner_pwds(
    1 cnt = i4
    1 qual[*]
      2 type = vc
      2 owner = vc
      2 pwd = vc
  )
  SET dcdur_owner_pwds->cnt = 0
 ENDIF
 IF (validate(dcdur_cmds->cnt,1)=1
  AND validate(dcdur_cmds->cnt,2)=2)
  FREE RECORD dcdur_cmds
  RECORD dcdur_cmds(
    1 cnt = i4
    1 qual[*]
      2 type = vc
      2 name = vc
      2 command = vc
      2 owner = vc
      2 default_tspace = vc
      2 temp_tspace = vc
      2 pwd = vc
      2 default_tspace_quota = vc
  )
  SET dcdur_cmds->cnt = 0
 ENDIF
 IF (validate(dcdur_user_data->misc_tspace_default,"X")="X"
  AND validate(dcdur_user_data->misc_tspace_default,"Y")="Y")
  FREE RECORD dcdur_user_data
  RECORD dcdur_user_data(
    1 misc_tspace_default = vc
    1 temp_tspace_default = vc
    1 misc_tspace_force = vc
    1 temp_tspace_force = vc
    1 user_cnt = i4
    1 users[*]
      2 user = vc
      2 misc_tspace = vc
      2 temp_tspace = vc
    1 tgt_sys_user = vc
    1 tgt_sys_pwd = vc
    1 create_user_method = vc
  )
  SET dcdur_user_data->misc_tspace_default = "DM2NOTSET"
  SET dcdur_user_data->temp_tspace_default = "DM2NOTSET"
  SET dcdur_user_data->misc_tspace_force = "DM2NOTSET"
  SET dcdur_user_data->temp_tspace_force = "DM2NOTSET"
  SET dcdur_user_data->tgt_sys_user = "SYS"
  SET dcdur_user_data->tgt_sys_pwd = "DM2NOTSET"
  SET dcdur_user_data->create_user_method = "DM2NOTSET"
  SET dcdur_user_data->user_cnt = 0
 ENDIF
 SUBROUTINE dcdur_create_db_users(null)
   DECLARE dcdu_iter = i4 WITH protect, noconstant(0)
   DECLARE dcdu_beg = i2 WITH protect, noconstant(0)
   DECLARE dcdu_end = i2 WITH protect, noconstant(0)
   DECLARE dcdu_str = vc WITH protect, noconstant(" ")
   DECLARE dcdu_grant_ptr = i2 WITH protect, noconstant(1)
   DECLARE dcdu_start_ptr = i2 WITH protect, noconstant(0)
   DECLARE dcdu_ndx = i4 WITH protect, noconstant(0)
   DECLARE dcdu_index1 = i2 WITH protect, noconstant(0)
   DECLARE dcdu_index2 = i2 WITH protect, noconstant(0)
   DECLARE dcdu_parse_cmd = vc WITH protect, noconstant("")
   DECLARE dcdu_cmd_string = vc WITH protect, noconstant("")
   DECLARE dcdu_where_clause = vc WITH protect, noconstant("")
   DECLARE dcdu_cmd_str_length = i4 WITH protect, noconstant(0)
   DECLARE dcdu_user_list = vc WITH protect, noconstant("")
   DECLARE dcdu_fix_tspaces_ind = i2 WITH protect, noconstant(0)
   DECLARE dcdu_replace_from = vc WITH protect, noconstant("")
   DECLARE dcdu_replace_to = vc WITH protect, noconstant("")
   DECLARE dcdu_func_owner = vc WITH protect, noconstant("")
   DECLARE dcdu_func_name = vc WITH protect, noconstant("")
   DECLARE dcdu_create_ind = i2 WITH protect, noconstant(0)
   DECLARE dcdu_idx = i4 WITH protect, noconstant(0)
   DECLARE dcdu_db_user_pwd = vc WITH protect, noconstant("")
   DECLARE dcdu_default_tspace = vc WITH protect, noconstant("")
   DECLARE dcdu_role_where_clause = vc WITH protect, noconstant("")
   DECLARE dcdu_adb_ind = i2 WITH protect, noconstant(0)
   DECLARE dcdu_owner = vc WITH protect, noconstant("")
   FREE RECORD dcdu_orauser
   RECORD dcdu_orauser(
     1 cnt = i4
     1 qual[*]
       2 user = vc
       2 default_tspace = vc
       2 temp_tspace = vc
       2 dt_fix_ind = i2
       2 tt_fix_ind = i2
   )
   FREE RECORD dcdu_tspaces
   RECORD dcdu_tspaces(
     1 cnt = i4
     1 qual[*]
       2 tspace_name = vc
   )
   SET dcdur_cmds->cnt = 0
   SET stat = alterlist(dcdur_cmds->qual,0)
   SET dcdur_input->connect_back = "N"
   IF (dm2_adb_check("",dcdu_adb_ind)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Creating database users and all dependent objects."
   CALL disp_msg("",dm_err->logfile,0)
   IF (((size(trim(dcdur_input->src_user))=0) OR (((size(trim(dcdur_input->src_pwd))=0) OR (((size(
    trim(dcdur_input->src_cnct_str))=0) OR (((size(trim(dcdur_input->tgt_user))=0) OR (((size(trim(
     dcdur_input->tgt_pwd))=0) OR (((size(trim(dcdur_input->tgt_cnct_str))=0) OR ((( NOT ((
   dcdur_input->replace_tspaces IN ("Y", "N")))) OR ((( NOT ((dcdur_input->replace_pwds IN ("Y", "N")
   ))) OR ((( NOT ((dcdur_input->fix_tspaces_ind IN ("Y", "N")))) OR ((((dcdur_input->fix_tspaces_ind
   ="Y")
    AND size(trim(dcdur_input->default_tspace))=0) OR ((((dcdur_input->fix_tspaces_ind="Y")
    AND size(trim(dcdur_input->temp_tspace))=0) OR (((trim(dcdur_input->user_list)="") OR (findstring
   ("(",dcdur_input->user_list,1) > 0)) )) )) )) )) )) )) )) )) )) )) )) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating input variables."
    SET dm_err->emsg = "Invalid input."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dcdur_input)
    ENDIF
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcdur_input)
   ENDIF
   SET dm_err->eproc = concat("Using DBMS_METADATA method to create [",trim(dcdur_input->user_list),
    "] users.")
   CALL disp_msg("",dm_err->logfile,0)
   SET dcdur_input->connect_back = "Y"
   SET dm2_force_connect_string = 1
   SET dm2_install_schema->dbase_name = '"SOURCE"'
   SET dm2_install_schema->u_name = dcdur_input->src_user
   SET dm2_install_schema->p_word = dcdur_input->src_pwd
   SET dm2_install_schema->connect_str = dcdur_input->src_cnct_str
   EXECUTE dm2_connect_to_dbase "CO"
   SET dm2_force_connect_string = 0
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET stat = alterlist(dcdu_orauser->qual,0)
   SET dcdu_orauser->cnt = 0
   IF ((dcdur_input->fix_tspaces_ind="Y"))
    SET dm_err->eproc = "Retrieve list of Source custom database users based on defined user list."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dba_users du
     WHERE parser(concat("du.username in (",dcdur_input->user_list,")"))
     ORDER BY du.username
     DETAIL
      dcdu_orauser->cnt = (dcdu_orauser->cnt+ 1), stat = alterlist(dcdu_orauser->qual,dcdu_orauser->
       cnt), dcdu_orauser->qual[dcdu_orauser->cnt].user = du.username,
      dcdu_orauser->qual[dcdu_orauser->cnt].default_tspace = du.default_tablespace, dcdu_orauser->
      qual[dcdu_orauser->cnt].temp_tspace = du.temporary_tablespace, dcdu_orauser->qual[dcdu_orauser
      ->cnt].dt_fix_ind = 0,
      dcdu_orauser->qual[dcdu_orauser->cnt].tt_fix_ind = 0
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dcdu_orauser)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Check for role exclusion list override."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    d.info_name
    FROM dm_info d
    WHERE info_domain="DM2_ROLE_EXLUSION_LIST_OVERRIDE"
    DETAIL
     dcdu_where_clause = concat("r.grantee not in(",d.info_name,")")
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dcdu_where_clause <= "")
    SET dcdu_where_clause = concat(
     "r.grantee not in('CONNECT','RESOURCE','DBA','EXP_FULL_DATABASE','IMP_FULL_DATABASE',",
     "'DELETE_CATALOG_ROLE','EXECUTE_CATALOG_ROLE','SELECT_CATALOG_ROLE',",
     "'RECOVERY_CATALOG_OWNER','HS_ADMIN_ROLE','AQ_USER_ROLE','AQ_ADMINISTRATOR_ROLE',",
     "'SNMPAGENT','SCHEDULER_ADMIN')")
   ENDIF
   IF (dm2_push_cmd(concat(
     "rdb asis(^begin DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,",
     "'SQLTERMINATOR',TRUE); end;^) go"),1)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Retrieve Source DDL to create Functions, Profiles, Users, Roles and Grants."
   CALL disp_msg("",dm_err->logfile,0)
   IF ((validate(dm2_bypass_get_pwd_function_ddl,- (1))=- (1)))
    SET dm_err->eproc = concat(
     "Get all Source dependent functions' DDL used in the PASSWORD_VERIFY_FUNCTION function ",
     "of profiles for user(s) specified.")
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_DDL('FUNCTION', dp.referenced_name, dp.referenced_owner)")
       FROM (
        (
        (SELECT DISTINCT
         d.referenced_name, d.referenced_owner
         FROM dba_profiles p,
          dba_objects o,
          dba_dependencies d
         WHERE ((p.profile="DEFAULT") OR (p.profile IN (
         (SELECT
          du.profile
          FROM dba_users du
          WHERE parser(concat("du.username in (",dcdur_input->user_list,")"))))))
          AND p.resource_name="PASSWORD_VERIFY_FUNCTION"
          AND  NOT (p.limit IN ("DEFAULT", "NULL"))
          AND p.limit=o.object_name
          AND o.object_type="FUNCTION"
          AND o.object_name=d.name
          AND d.referenced_type="FUNCTION"
         WITH sqltype("C32000")))
        dp)
       WHERE 1=1
       WITH sqltype("C32000")))
      a)
     DETAIL
      dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
      dcdu_parse_cmd = replace(trim(a.x,3),"/","",2),
      dcdu_beg = (findstring('"',dcdu_parse_cmd,1,0)+ 1), dcdu_end = findstring('"',dcdu_parse_cmd,
       dcdu_beg,0), dcdur_cmds->qual[dcdur_cmds->cnt].owner = substring(dcdu_beg,(dcdu_end - dcdu_beg
       ),dcdu_parse_cmd),
      dcdu_beg = 0, dcdu_beg = (findstring('"',dcdu_parse_cmd,(dcdu_end+ 1),0)+ 1), dcdu_end = 0,
      dcdu_end = findstring('"',dcdu_parse_cmd,dcdu_beg,0), dcdur_cmds->qual[dcdur_cmds->cnt].name =
      substring(dcdu_beg,(dcdu_end - dcdu_beg),dcdu_parse_cmd), dcdur_cmds->qual[dcdur_cmds->cnt].
      type = "FUNCTION",
      dcdur_cmds->qual[dcdur_cmds->cnt].command = dcdu_parse_cmd
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
    SET dm_err->eproc = concat(
     "Get all Source PASSWORD_VERIFY_FUNCTION functions' DDL used during create ",
     "profile for user(s) specified.")
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_DDL('FUNCTION', dp.object_name, dp.owner)")
       FROM (
        (
        (SELECT DISTINCT
         o.object_name, o.owner
         FROM dba_profiles p,
          dba_objects o
         WHERE p.profile != "DEFAULT"
          AND p.profile IN (
         (SELECT
          d.profile
          FROM dba_users d
          WHERE parser(concat("d.username in (",dcdur_input->user_list,")"))))
          AND p.resource_name="PASSWORD_VERIFY_FUNCTION"
          AND  NOT (p.limit IN ("DEFAULT", "NULL"))
          AND p.limit=o.object_name
          AND o.object_type="FUNCTION"
         WITH sqltype("C32000")))
        dp)
       WHERE 1=1
       WITH sqltype("C32000")))
      a)
     DETAIL
      dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
      dcdu_parse_cmd = replace(trim(a.x,3),"/","",2),
      dcdu_beg = (findstring('"',dcdu_parse_cmd,1,0)+ 1), dcdu_end = findstring('"',dcdu_parse_cmd,
       dcdu_beg,0), dcdur_cmds->qual[dcdur_cmds->cnt].owner = substring(dcdu_beg,(dcdu_end - dcdu_beg
       ),dcdu_parse_cmd),
      dcdu_beg = 0, dcdu_beg = (findstring('"',dcdu_parse_cmd,(dcdu_end+ 1),0)+ 1), dcdu_end = 0,
      dcdu_end = findstring('"',dcdu_parse_cmd,dcdu_beg,0), dcdur_cmds->qual[dcdur_cmds->cnt].name =
      substring(dcdu_beg,(dcdu_end - dcdu_beg),dcdu_parse_cmd), dcdur_cmds->qual[dcdur_cmds->cnt].
      type = "FUNCTION",
      dcdur_cmds->qual[dcdur_cmds->cnt].command = dcdu_parse_cmd
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
   ENDIF
   IF ((validate(dm2_bypass_get_profiles_ddl,- (1))=- (1)))
    SET dm_err->eproc = "Get Source create/alter profile DDL for user(s) specified."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_DDL('PROFILE', dp.profile)")
       FROM (
        (
        (SELECT DISTINCT
         p.profile
         FROM dba_profiles p
         WHERE ((p.profile="DEFAULT") OR (p.profile IN (
         (SELECT
          d.profile
          FROM dba_users d
          WHERE parser(concat("d.username in (",dcdur_input->user_list,")"))))))
         WITH sqltype("C32000")))
        dp)
       WHERE 1=1
       WITH sqltype("C32000")))
      a)
     DETAIL
      dcdu_grant_ptr = 1, dcdu_start_ptr = 1
      IF (findstring(";",trim(a.x,3),dcdu_start_ptr) > 0)
       dcdu_cmd_string = replace(replace(replace(trim(a.x,3),char(0),""),char(10),""),char(13),""),
       dcdu_index1 = 0, dcdu_index1 = locateval(dcdu_index1,1,dcdur_cmds->cnt,dcdu_cmd_string,
        dcdur_cmds->qual[dcdu_index1].command)
       IF (dcdu_index1=0)
        dcdu_cmd_str_length = textlen(dcdu_cmd_string)
        WHILE (dcdu_grant_ptr > 0)
          dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),dcdu_start_ptr), dcdu_parse_cmd =
          replace(trim(substring(dcdu_start_ptr,((dcdu_grant_ptr - dcdu_start_ptr)+ 1),
             dcdu_cmd_string),3),";","",0), dcdu_index2 = 0,
          dcdu_index2 = locateval(dcdu_index2,1,dcdur_cmds->cnt,dcdu_parse_cmd,dcdur_cmds->qual[
           dcdu_index2].command)
          IF (dcdu_index2=0)
           dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
           dcdu_beg = (findstring('"',dcdu_parse_cmd,1,0)+ 1),
           dcdu_end = findstring('"',dcdu_parse_cmd,dcdu_beg,0), dcdur_cmds->qual[dcdur_cmds->cnt].
           name = substring(dcdu_beg,(dcdu_end - dcdu_beg),dcdu_parse_cmd), dcdur_cmds->qual[
           dcdur_cmds->cnt].type = "PROFILE",
           dcdur_cmds->qual[dcdur_cmds->cnt].command = dcdu_parse_cmd
          ENDIF
          dcdu_start_ptr = (dcdu_grant_ptr+ 1)
          IF (dcdu_start_ptr >= dcdu_cmd_str_length)
           dcdu_grant_ptr = 0
          ENDIF
        ENDWHILE
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
   ENDIF
   IF ((validate(dm2_bypass_get_users_ddl,- (1))=- (1)))
    SET dm_err->eproc = "Get Source create user DDL for user(s) specified."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_DDL('USER', USERNAME)")
       FROM dba_users u
       WHERE parser(concat("u.username in (",dcdur_input->user_list,")"))
       WITH sqltype("C32000")))
      a)
     DETAIL
      IF ((dm_err->debug_flag > 4))
       CALL echo(concat("x = ",a.x))
      ENDIF
      dcdu_grant_ptr = 1, dcdu_start_ptr = 1
      IF (findstring(";",trim(a.x,3),dcdu_start_ptr) > 0)
       dcdu_cmd_string = replace(replace(replace(trim(a.x,3),char(0),""),char(10),""),char(13),"")
       IF ((dm_err->debug_flag > 4))
        CALL echo(concat("dcdu_cmd_string = ",dcdu_cmd_string))
       ENDIF
       dcdu_index1 = 0, dcdu_index1 = locateval(dcdu_index1,1,dcdur_cmds->cnt,dcdu_cmd_string,
        dcdur_cmds->qual[dcdu_index1].command)
       IF (dcdu_index1=0)
        dcdu_cmd_str_length = textlen(dcdu_cmd_string)
        WHILE (dcdu_grant_ptr > 0)
          dcdu_beg = findstring("IDENTIFIED BY VALUES '",dcdu_cmd_string,dcdu_start_ptr)
          IF ((dm_err->debug_flag > 4))
           CALL echo(build("dcdu_beg =",dcdu_beg))
          ENDIF
          IF (dcdu_beg > 0)
           dcdu_end = findstring("'",dcdu_cmd_string,(dcdu_beg+ 22))
           IF ((dm_err->debug_flag > 4))
            CALL echo(build("dcdu_end =",dcdu_end))
           ENDIF
           dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),(dcdu_end+ 1))
          ELSE
           dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),dcdu_start_ptr)
          ENDIF
          IF ((dm_err->debug_flag > 4))
           CALL echo(build("dcdu_grant_ptr =",dcdu_grant_ptr)),
           CALL echo(build("dcdu_start_ptr =",dcdu_start_ptr))
          ENDIF
          dcdu_parse_cmd = replace(trim(substring(dcdu_start_ptr,((dcdu_grant_ptr - dcdu_start_ptr)+
             1),dcdu_cmd_string),3),";","",2)
          IF ((dm_err->debug_flag > 4))
           CALL echo(concat("dcdu_parse_cmd = ",dcdu_parse_cmd))
          ENDIF
          dcdu_index2 = 0, dcdu_index2 = locateval(dcdu_index2,1,dcdur_cmds->cnt,dcdu_parse_cmd,
           dcdur_cmds->qual[dcdu_index2].command)
          IF ((dm_err->debug_flag > 4))
           CALL echo(build("dcdu_index2 = ",dcdu_index2))
          ENDIF
          IF (dcdu_index2=0)
           dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
           dcdu_beg = (findstring('"',dcdu_parse_cmd,1,0)+ 1),
           dcdu_end = findstring('"',dcdu_parse_cmd,dcdu_beg,0), dcdur_cmds->qual[dcdur_cmds->cnt].
           name = substring(dcdu_beg,(dcdu_end - dcdu_beg),dcdu_parse_cmd), dcdur_cmds->qual[
           dcdur_cmds->cnt].owner = dcdur_cmds->qual[dcdur_cmds->cnt].name,
           dcdur_cmds->qual[dcdur_cmds->cnt].type = "USER", dcdur_cmds->qual[dcdur_cmds->cnt].command
            = dcdu_parse_cmd
           IF (findstring("DEFAULT TABLESPACE",dcdur_cmds->qual[dcdur_cmds->cnt].command,
            dcdu_start_ptr) > 0)
            dcdur_cmds->qual[dcdur_cmds->cnt].default_tspace = substring((findstring(
              "DEFAULT TABLESPACE",dcdur_cmds->qual[dcdur_cmds->cnt].command,dcdu_start_ptr)+ 20),(
             findstring('"',dcdur_cmds->qual[dcdur_cmds->cnt].command,((findstring(
               "DEFAULT TABLESPACE",dcdur_cmds->qual[dcdur_cmds->cnt].command,dcdu_start_ptr)+ 20)+ 1
              )) - (findstring("DEFAULT TABLESPACE",dcdur_cmds->qual[dcdur_cmds->cnt].command,
              dcdu_start_ptr)+ 20)),dcdur_cmds->qual[dcdur_cmds->cnt].command)
           ENDIF
           IF (findstring("TEMPORARY TABLESPACE",dcdur_cmds->qual[dcdur_cmds->cnt].command,
            dcdu_start_ptr) > 0)
            dcdur_cmds->qual[dcdur_cmds->cnt].temp_tspace = substring((findstring(
              "TEMPORARY TABLESPACE",dcdur_cmds->qual[dcdur_cmds->cnt].command,dcdu_start_ptr)+ 22),(
             findstring('"',dcdur_cmds->qual[dcdur_cmds->cnt].command,((findstring(
               "TEMPORARY TABLESPACE",dcdur_cmds->qual[dcdur_cmds->cnt].command,dcdu_start_ptr)+ 22)
              + 1)) - (findstring("TEMPORARY TABLESPACE",dcdur_cmds->qual[dcdur_cmds->cnt].command,
              dcdu_start_ptr)+ 22)),dcdur_cmds->qual[dcdur_cmds->cnt].command)
           ENDIF
           IF (findstring("IDENTIFIED BY VALUES '",dcdur_cmds->qual[dcdur_cmds->cnt].command,
            dcdu_start_ptr) > 0)
            dcdur_cmds->qual[dcdur_cmds->cnt].pwd = substring((findstring("IDENTIFIED BY VALUES '",
              dcdur_cmds->qual[dcdur_cmds->cnt].command,dcdu_start_ptr)+ 22),(findstring("'",
              dcdur_cmds->qual[dcdur_cmds->cnt].command,((findstring("IDENTIFIED BY VALUES '",
               dcdur_cmds->qual[dcdur_cmds->cnt].command,dcdu_start_ptr)+ 22)+ 1)) - (findstring(
              "IDENTIFIED BY VALUES '",dcdur_cmds->qual[dcdur_cmds->cnt].command,dcdu_start_ptr)+ 22)
             ),dcdur_cmds->qual[dcdur_cmds->cnt].command)
           ENDIF
          ENDIF
          dcdu_start_ptr = (dcdu_grant_ptr+ 1)
          IF (dcdu_start_ptr >= dcdu_cmd_str_length)
           dcdu_grant_ptr = 0
          ENDIF
        ENDWHILE
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
   ENDIF
   SET dcdu_role_where_clause = " 1=1 "
   IF ((dm2_rdbms_version->level1 > 11))
    SET dcdu_role_where_clause = " u.COMMON='NO' "
   ENDIF
   IF ((validate(dm2_bypass_get_roles_ddl,- (1))=- (1)))
    SET dm_err->eproc = "Get all Source create role DDL (i.e. create role <role>)."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_DDL('ROLE', ROLE)")
       FROM dba_roles u
       WHERE parser(dcdu_role_where_clause)
       WITH sqltype("C32000")))
      a)
     DETAIL
      dcdu_grant_ptr = 1, dcdu_start_ptr = 1
      IF (findstring(";",trim(a.x,3),dcdu_start_ptr) > 0)
       dcdu_cmd_string = replace(replace(replace(trim(a.x,3),char(0),""),char(10),""),char(13),""),
       dcdu_index1 = 0, dcdu_index1 = locateval(dcdu_index1,1,dcdur_cmds->cnt,dcdu_cmd_string,
        dcdur_cmds->qual[dcdu_index1].command)
       IF (dcdu_index1=0)
        dcdu_cmd_str_length = textlen(dcdu_cmd_string)
        WHILE (dcdu_grant_ptr > 0)
          dcdu_beg = findstring("IDENTIFIED BY VALUES '",dcdu_cmd_string,dcdu_start_ptr)
          IF (dcdu_beg > 0)
           dcdu_end = findstring("'",dcdu_cmd_string,(dcdu_beg+ 22))
           IF ((dm_err->debug_flag > 4))
            CALL echo(build("dcdu_end =",dcdu_end))
           ENDIF
           dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),(dcdu_end+ 1))
          ELSE
           dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),dcdu_start_ptr)
          ENDIF
          dcdu_parse_cmd = replace(trim(substring(dcdu_start_ptr,((dcdu_grant_ptr - dcdu_start_ptr)+
             1),dcdu_cmd_string),3),";","",2), dcdu_index2 = 0, dcdu_index2 = locateval(dcdu_index2,1,
           dcdur_cmds->cnt,dcdu_parse_cmd,dcdur_cmds->qual[dcdu_index2].command)
          IF (dcdu_index2=0)
           dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
           dcdu_beg = (findstring('"',dcdu_parse_cmd,1,0)+ 1),
           dcdu_end = findstring('"',dcdu_parse_cmd,dcdu_beg,0), dcdur_cmds->qual[dcdur_cmds->cnt].
           name = substring(dcdu_beg,(dcdu_end - dcdu_beg),dcdu_parse_cmd), dcdur_cmds->qual[
           dcdur_cmds->cnt].type = "ROLE",
           dcdur_cmds->qual[dcdur_cmds->cnt].command = dcdu_parse_cmd
          ENDIF
          dcdu_start_ptr = (dcdu_grant_ptr+ 1)
          IF (dcdu_start_ptr >= dcdu_cmd_str_length)
           dcdu_grant_ptr = 0
          ENDIF
        ENDWHILE
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
   ENDIF
   IF ((validate(dm2_bypass_get_role_grants_ddl,- (1))=- (1)))
    SET dm_err->eproc =
    "Get all Source role grant DDL for all roles (i.e. grant <role> to <role>) excluding default roles."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_GRANTED_DDL('ROLE_GRANT', r.grantee)")
       FROM dba_role_privs r
       WHERE r.grantee IN (
       (SELECT
        x.role
        FROM dba_roles x))
        AND parser(dcdu_where_clause)
       WITH sqltype("C32000")))
      a)
     DETAIL
      dcdu_grant_ptr = 1, dcdu_start_ptr = 1
      IF (findstring(";",trim(a.x,3),dcdu_start_ptr) > 0)
       dcdu_cmd_string = replace(replace(replace(trim(a.x,3),char(0),""),char(10),""),char(13),""),
       dcdu_index1 = 0, dcdu_index1 = locateval(dcdu_index1,1,dcdur_cmds->cnt,dcdu_cmd_string,
        dcdur_cmds->qual[dcdu_index1].command)
       IF (dcdu_index1=0)
        dcdu_cmd_str_length = textlen(dcdu_cmd_string)
        WHILE (dcdu_grant_ptr > 0)
          dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),dcdu_start_ptr), dcdu_parse_cmd =
          replace(trim(substring(dcdu_start_ptr,((dcdu_grant_ptr - dcdu_start_ptr)+ 1),
             dcdu_cmd_string),3),";","",0), dcdu_index2 = 0,
          dcdu_index2 = locateval(dcdu_index2,1,dcdur_cmds->cnt,dcdu_parse_cmd,dcdur_cmds->qual[
           dcdu_index2].command)
          IF (dcdu_index2=0)
           dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
           dcdur_cmds->qual[dcdur_cmds->cnt].type = "ROLE GRANT",
           dcdur_cmds->qual[dcdur_cmds->cnt].command = dcdu_parse_cmd
          ENDIF
          dcdu_start_ptr = (dcdu_grant_ptr+ 1)
          IF (dcdu_start_ptr >= dcdu_cmd_str_length)
           dcdu_grant_ptr = 0
          ENDIF
        ENDWHILE
       ENDIF
      ENDIF
     FOOT REPORT
      stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
   ENDIF
   IF ((validate(dm2_bypass_get_system_grants_ddl,- (1))=- (1)))
    SET dm_err->eproc = concat(
     "Get all Source system priv grant DDL for all roles (i.e. grant <sys priv> to <role>)",
     "excluding default roles.")
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_GRANTED_DDL('SYSTEM_GRANT', r.grantee)")
       FROM dba_sys_privs r
       WHERE r.grantee IN (
       (SELECT
        u.role
        FROM dba_roles u
        WHERE parser(dcdu_role_where_clause)))
        AND parser(dcdu_where_clause)
       WITH sqltype("C32000")))
      a)
     DETAIL
      dcdu_grant_ptr = 1, dcdu_start_ptr = 1
      IF (findstring(";",trim(a.x,3),dcdu_start_ptr) > 0)
       dcdu_cmd_string = replace(replace(replace(trim(a.x,3),char(0),""),char(10),""),char(13),""),
       dcdu_index1 = 0, dcdu_index1 = locateval(dcdu_index1,1,dcdur_cmds->cnt,dcdu_cmd_string,
        dcdur_cmds->qual[dcdu_index1].command)
       IF (dcdu_index1=0)
        dcdu_cmd_str_length = textlen(dcdu_cmd_string)
        WHILE (dcdu_grant_ptr > 0)
          dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),dcdu_start_ptr), dcdu_parse_cmd =
          replace(trim(substring(dcdu_start_ptr,((dcdu_grant_ptr - dcdu_start_ptr)+ 1),
             dcdu_cmd_string),3),";","",0), dcdu_index2 = 0,
          dcdu_index2 = locateval(dcdu_index2,1,dcdur_cmds->cnt,dcdu_parse_cmd,dcdur_cmds->qual[
           dcdu_index2].command)
          IF (dcdu_index2=0)
           dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
           dcdur_cmds->qual[dcdur_cmds->cnt].type = "SYS GRANT",
           dcdur_cmds->qual[dcdur_cmds->cnt].command = dcdu_parse_cmd
          ENDIF
          dcdu_start_ptr = (dcdu_grant_ptr+ 1)
          IF (dcdu_start_ptr >= dcdu_cmd_str_length)
           dcdu_grant_ptr = 0
          ENDIF
        ENDWHILE
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
   ENDIF
   IF ((validate(dm2_bypass_role_grants_userlist_ddl,- (1))=- (1)))
    SET dm_err->eproc =
    "Get all Source role grant DDL for user(s) specified (i.e. grant <role> to <user>)."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_GRANTED_DDL('ROLE_GRANT', USERNAME)")
       FROM dba_users u
       WHERE parser(concat("u.username in (",dcdur_input->user_list,")"))
        AND  EXISTS (
       (SELECT
        1
        FROM dba_role_privs drp
        WHERE drp.grantee=u.username))
       WITH sqltype("C32000")))
      a)
     DETAIL
      dcdu_grant_ptr = 1, dcdu_start_ptr = 1
      IF (findstring(";",trim(a.x,3),dcdu_start_ptr) > 0)
       dcdu_cmd_string = replace(replace(replace(trim(a.x,3),char(0),""),char(10),""),char(13),""),
       dcdu_index1 = 0, dcdu_index1 = locateval(dcdu_index1,1,dcdur_cmds->cnt,dcdu_cmd_string,
        dcdur_cmds->qual[dcdu_index1].command)
       IF (dcdu_index1=0)
        dcdu_cmd_str_length = textlen(dcdu_cmd_string)
        WHILE (dcdu_grant_ptr > 0)
          dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),dcdu_start_ptr), dcdu_parse_cmd =
          replace(trim(substring(dcdu_start_ptr,((dcdu_grant_ptr - dcdu_start_ptr)+ 1),
             dcdu_cmd_string),3),";","",0), dcdu_index2 = 0,
          dcdu_index2 = locateval(dcdu_index2,1,dcdur_cmds->cnt,dcdu_parse_cmd,dcdur_cmds->qual[
           dcdu_index2].command)
          IF (dcdu_index2=0)
           dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
           dcdur_cmds->qual[dcdur_cmds->cnt].type = "ROLE GRANT"
           IF (findstring('"DBA"',dcdu_parse_cmd) > 0
            AND dcdu_adb_ind=1)
            dcdu_parse_cmd = replace(dcdu_parse_cmd,'"DBA"','"PDB_DBA"')
           ENDIF
           dcdur_cmds->qual[dcdur_cmds->cnt].command = dcdu_parse_cmd
          ENDIF
          dcdu_start_ptr = (dcdu_grant_ptr+ 1)
          IF (dcdu_start_ptr >= dcdu_cmd_str_length)
           dcdu_grant_ptr = 0
          ENDIF
        ENDWHILE
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
   ENDIF
   IF ((validate(dm2_bypass_system_grants_userlist_ddl,- (1))=- (1)))
    SET dm_err->eproc =
    "Get all Source sys priv grant DDL (not role) for user(s) specified (i.e. grant <sys priv> to <user>)."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (
      (
      (SELECT
       x = sqlpassthru("DBMS_METADATA.GET_GRANTED_DDL('SYSTEM_GRANT', USERNAME)")
       FROM dba_users u
       WHERE parser(concat("u.username in (",dcdur_input->user_list,")"))
        AND  EXISTS (
       (SELECT
        1
        FROM dba_sys_privs dsp
        WHERE dsp.grantee=u.username))
       WITH sqltype("C32000")))
      a)
     DETAIL
      dcdu_grant_ptr = 1, dcdu_start_ptr = 1
      IF (findstring(";",trim(a.x,3),dcdu_start_ptr) > 0)
       dcdu_cmd_string = replace(replace(replace(trim(a.x,3),char(0),""),char(10),""),char(13),""),
       dcdu_index1 = 0, dcdu_index1 = locateval(dcdu_index1,1,dcdur_cmds->cnt,dcdu_cmd_string,
        dcdur_cmds->qual[dcdu_index1].command)
       IF (dcdu_index1=0)
        dcdu_cmd_str_length = textlen(dcdu_cmd_string)
        WHILE (dcdu_grant_ptr > 0)
          dcdu_grant_ptr = findstring(";",trim(dcdu_cmd_string,3),dcdu_start_ptr), dcdu_parse_cmd =
          replace(trim(substring(dcdu_start_ptr,((dcdu_grant_ptr - dcdu_start_ptr)+ 1),
             dcdu_cmd_string),3),";","",0), dcdu_index2 = 0,
          dcdu_index2 = locateval(dcdu_index2,1,dcdur_cmds->cnt,dcdu_parse_cmd,dcdur_cmds->qual[
           dcdu_index2].command)
          IF (dcdu_index2=0)
           dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
           dcdur_cmds->qual[dcdur_cmds->cnt].type = "SYS GRANT",
           dcdur_cmds->qual[dcdur_cmds->cnt].command = dcdu_parse_cmd
          ENDIF
          dcdu_start_ptr = (dcdu_grant_ptr+ 1)
          IF (dcdu_start_ptr >= dcdu_cmd_str_length)
           dcdu_grant_ptr = 0
          ENDIF
        ENDWHILE
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 4))
     CALL echorecord(dcdur_cmds)
    ENDIF
   ENDIF
   IF ((validate(dm2_bypass_table_grants_userlist_ddl,- (1))=- (1)))
    SET dm_err->eproc = "Retrieve Source DDL for SYS object grants on user(s) specified."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dba_tab_privs dtp
     WHERE dtp.owner="SYS"
      AND parser(concat("dtp.grantee in (",dcdur_input->user_list,")"))
     DETAIL
      dcdur_cmds->cnt = (dcdur_cmds->cnt+ 1), stat = alterlist(dcdur_cmds->qual,dcdur_cmds->cnt),
      dcdur_cmds->qual[dcdur_cmds->cnt].type = "TABLE GRANT",
      dcdur_cmds->qual[dcdur_cmds->cnt].owner = dtp.owner, dcdur_cmds->qual[dcdur_cmds->cnt].name =
      dtp.table_name
      IF (dtp.privilege IN ("READ", "WRITE"))
       dcdur_cmds->qual[dcdur_cmds->cnt].command = concat("GRANT ",trim(dtp.privilege),
        ' ON DIRECTORY "',trim(dtp.owner),'"."',
        trim(dtp.table_name),'" TO "',trim(dtp.grantee),'"')
      ELSE
       dcdur_cmds->qual[dcdur_cmds->cnt].command = concat("GRANT ",trim(dtp.privilege),' ON "',trim(
         dtp.owner),'"."',
        trim(dtp.table_name),'" TO "',trim(dtp.grantee),'"')
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Check for Source users default tablespaces with unlimited quota."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_ts_quotas dtq,
     dba_users du
    WHERE parser(concat("du.username in (",dcdur_input->user_list,")"))
     AND du.username=dtq.username
     AND du.default_tablespace=dtq.tablespace_name
     AND (dtq.max_bytes=- (1))
    DETAIL
     dcdu_index1 = 0, dcdu_index1 = locateval(dcdu_index1,1,dcdur_cmds->cnt,"USER",dcdur_cmds->qual[
      dcdu_index1].type,
      du.username,dcdur_cmds->qual[dcdu_index1].owner,du.default_tablespace,dcdur_cmds->qual[
      dcdu_index1].default_tspace)
     IF (dcdu_index1 > 0)
      dcdur_cmds->qual[dcdu_index1].default_tspace_quota = "Y"
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcdur_cmds)
   ENDIF
   SET dm2_force_connect_string = 1
   SET dm2_install_schema->dbase_name = '"TARGET"'
   SET dm2_install_schema->u_name = dcdur_input->tgt_user
   SET dm2_install_schema->p_word = dcdur_input->tgt_pwd
   SET dm2_install_schema->connect_str = dcdur_input->tgt_cnct_str
   EXECUTE dm2_connect_to_dbase "CO"
   SET dm2_force_connect_string = 0
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET dcdur_input->connect_back = "N"
   IF ((dcdur_input->fix_tspaces_ind="Y"))
    SET dm_err->eproc = "Retrieving Target tablespaces from dba_tablespaces."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT DISTINCT INTO "nl:"
     dt.tablespace_name
     FROM dba_tablespaces dt
     DETAIL
      dcdu_tspaces->cnt = (dcdu_tspaces->cnt+ 1), stat = alterlist(dcdu_tspaces->qual,dcdu_tspaces->
       cnt), dcdu_tspaces->qual[dcdu_tspaces->cnt].tspace_name = dt.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    FOR (dcdu_iter = 1 TO dcdu_orauser->cnt)
      SET dcdu_ndx = 0
      SET dcdu_ndx = locateval(dcdu_ndx,1,dcdu_tspaces->cnt,dcdu_orauser->qual[dcdu_iter].
       default_tspace,dcdu_tspaces->qual[dcdu_ndx].tspace_name)
      IF (dcdu_ndx=0)
       SET dcdu_fix_tspaces_ind = 1
       SET dcdu_orauser->qual[dcdu_iter].dt_fix_ind = 1
      ENDIF
      SET dcdu_ndx = 0
      SET dcdu_ndx = locateval(dcdu_ndx,1,dcdu_tspaces->cnt,dcdu_orauser->qual[dcdu_iter].temp_tspace,
       dcdu_tspaces->qual[dcdu_ndx].tspace_name)
      IF (dcdu_ndx=0)
       SET dcdu_fix_tspaces_ind = 1
       SET dcdu_orauser->qual[dcdu_iter].tt_fix_ind = 1
      ENDIF
    ENDFOR
    IF (dcdu_fix_tspaces_ind=1)
     IF ((dm_err->debug_flag > 0))
      CALL echorecord(dcdu_orauser)
     ENDIF
    ELSE
     IF ((dm_err->debug_flag > 0))
      SET dm_err->eproc = "No database users with missing default/temporary tablespaces."
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
    ENDIF
   ENDIF
   FOR (dcdu_iter = 1 TO dcdur_cmds->cnt)
     IF ((dcdur_cmds->qual[dcdu_iter].type="USER"))
      SET dm_err->eproc = concat("Check if ",dcdur_cmds->qual[dcdu_iter].owner,
       " user exists in TARGET.")
      CALL disp_msg("",dm_err->logfile,0)
      SELECT INTO "nl:"
       FROM dba_users u
       WHERE u.username=cnvtupper(dcdur_cmds->qual[dcdu_iter].owner)
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      IF (curqual=0)
       SET dcdu_cmd_string = dcdur_cmds->qual[dcdu_iter].command
       IF (dcdu_fix_tspaces_ind=1)
        SET dcdu_ndx = 0
        SET dcdu_ndx = locateval(dcdu_ndx,1,dcdu_orauser->cnt,dcdur_cmds->qual[dcdu_iter].owner,
         dcdu_orauser->qual[dcdu_ndx].user)
        IF (dcdu_ndx > 0)
         IF ((dcdu_orauser->qual[dcdu_ndx].dt_fix_ind=1))
          SET dcdu_replace_from = build('DEFAULT TABLESPACE "',dcdu_orauser->qual[dcdu_ndx].
           default_tspace,'"')
          SET dcdu_replace_to = build('DEFAULT TABLESPACE "',dcdur_input->default_tspace,'"')
          SET dcdu_cmd_string = replace(dcdu_cmd_string,dcdu_replace_from,dcdu_replace_to,0)
         ENDIF
         IF ((dcdu_orauser->qual[dcdu_ndx].tt_fix_ind=1))
          SET dcdu_replace_from = build('TEMPORARY TABLESPACE "',dcdu_orauser->qual[dcdu_ndx].
           temp_tspace,'"')
          SET dcdu_replace_to = build('TEMPORARY TABLESPACE "',dcdur_input->temp_tspace,'"')
          SET dcdu_cmd_string = replace(dcdu_cmd_string,dcdu_replace_from,dcdu_replace_to,0)
         ENDIF
        ENDIF
       ENDIF
       IF ((dcdur_input->replace_tspaces="Y"))
        SET dcdu_idx = 0
        IF (dcdur_prompt_tspaces(dcdur_cmds->qual[dcdu_iter].owner,dcdur_input->tgt_dbname,dcdu_idx)=
        0)
         RETURN(0)
        ENDIF
        SET dcdu_replace_from = build('DEFAULT TABLESPACE "',dcdur_cmds->qual[dcdu_iter].
         default_tspace,'"')
        SET dcdu_replace_to = build('DEFAULT TABLESPACE "',dcdur_user_data->users[dcdu_idx].
         misc_tspace,'"')
        SET dcdu_cmd_string = replace(dcdu_cmd_string,dcdu_replace_from,dcdu_replace_to,2)
        SET dcdu_replace_from = build('TEMPORARY TABLESPACE "',dcdur_cmds->qual[dcdu_iter].
         temp_tspace,'"')
        SET dcdu_replace_to = build('TEMPORARY TABLESPACE "',dcdur_user_data->users[dcdu_idx].
         temp_tspace,'"')
        SET dcdu_cmd_string = replace(dcdu_cmd_string,dcdu_replace_from,dcdu_replace_to,2)
       ENDIF
       IF ((dcdur_input->replace_pwds="Y"))
        SET dcdu_idx = 0
        SET dcdu_idx = locateval(dcdu_idx,1,dir_db_users_pwds->cnt,dcdur_cmds->qual[dcdu_iter].owner,
         replace(dir_db_users_pwds->qual[dcdu_idx].user,"'","",0))
        SET dcdu_db_user_pwd = dir_db_users_pwds->qual[dcdu_idx].pwd
        SET dcdu_cmd_string = replace(dcdu_cmd_string,concat("'",dcdur_cmds->qual[dcdu_iter].pwd,"'"),
         concat('"',dcdu_db_user_pwd,'"'),0)
        SET dcdu_cmd_string = replace(dcdu_cmd_string,"IDENTIFIED BY VALUES","IDENTIFIED BY",0)
       ENDIF
       IF (dm2_push_cmd(build("rdb asis(^",dcdu_cmd_string,"^) go"),1)=0)
        RETURN(0)
       ENDIF
      ELSE
       IF ((dm_err->debug_flag > 0))
        SET dm_err->eproc = concat(dcdur_cmds->qual[dcdu_iter].owner,
         " user already exists in TARGET.")
        CALL disp_msg("",dm_err->logfile,0)
       ENDIF
      ENDIF
     ELSEIF ((dcdur_cmds->qual[dcdu_iter].type="ROLE"))
      SET dm_err->eproc = concat("Check if ",dcdur_cmds->qual[dcdu_iter].name,
       " role exists in TARGET.")
      CALL disp_msg("",dm_err->logfile,0)
      SELECT INTO "nl:"
       FROM dba_roles u
       WHERE u.role=cnvtupper(dcdur_cmds->qual[dcdu_iter].name)
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      IF (curqual=0)
       IF (dm2_push_cmd(build("rdb asis(^",dcdur_cmds->qual[dcdu_iter].command,"^) go"),1)=0)
        RETURN(0)
       ENDIF
      ELSE
       IF ((dm_err->debug_flag > 0))
        SET dm_err->eproc = concat(dcdur_cmds->qual[dcdu_iter].name," role already exists in TARGET."
         )
        CALL disp_msg("",dm_err->logfile,0)
       ENDIF
      ENDIF
     ELSEIF ((dcdur_cmds->qual[dcdu_iter].type="PROFILE"))
      SET dcdu_create_ind = 1
      IF (findstring("CREATE PROFILE",dcdur_cmds->qual[dcdu_iter].command,1,0) > 0)
       SET dm_err->eproc = concat("Check if ",dcdur_cmds->qual[dcdu_iter].name,
        " profile exists in TARGET.")
       CALL disp_msg("",dm_err->logfile,0)
       SELECT INTO "nl:"
        FROM dba_profiles p
        WHERE p.profile=cnvtupper(dcdur_cmds->qual[dcdu_iter].name)
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       IF (curqual > 0)
        SET dcdu_create_ind = 0
        IF ((dm_err->debug_flag > 0))
         SET dm_err->eproc = concat(dcdur_cmds->qual[dcdu_iter].name,
          " profile already exists in TARGET.")
         CALL disp_msg("",dm_err->logfile,0)
        ENDIF
       ENDIF
      ENDIF
      IF (dcdu_create_ind=1)
       IF (dm2_push_cmd(build("rdb asis(^",dcdur_cmds->qual[dcdu_iter].command,"^) go"),1)=0)
        RETURN(0)
       ENDIF
      ENDIF
     ELSEIF ((dcdur_cmds->qual[dcdu_iter].type="FUNCTION"))
      SET dm_err->eproc = concat("Check if ",dcdur_cmds->qual[dcdu_iter].owner,".",dcdur_cmds->qual[
       dcdu_iter].name," function exists in TARGET.")
      CALL disp_msg("",dm_err->logfile,0)
      SELECT INTO "nl:"
       FROM dba_objects o
       WHERE (o.owner=dcdur_cmds->qual[dcdu_iter].owner)
        AND (o.object_name=dcdur_cmds->qual[dcdu_iter].name)
        AND o.object_type="FUNCTION"
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      IF (curqual=0)
       IF (dm2_push_cmd(build("rdb asis(^",dcdur_cmds->qual[dcdu_iter].command,"^) go"),1)=0)
        RETURN(0)
       ENDIF
      ELSE
       IF ((dm_err->debug_flag > 0))
        SET dm_err->eproc = concat(dcdur_cmds->qual[dcdu_iter].owner,".",dcdur_cmds->qual[dcdu_iter].
         name," function already exists in TARGET.")
        CALL disp_msg("",dm_err->logfile,0)
       ENDIF
      ENDIF
     ELSE
      SET dcdu_create_ind = 1
      IF ((dcdur_cmds->qual[dcdu_iter].type="TABLE GRANT"))
       SET dm_err->eproc = concat("Check if ",dcdur_cmds->qual[dcdu_iter].owner,".",dcdur_cmds->qual[
        dcdu_iter].name," object exists in TARGET.")
       CALL disp_msg("",dm_err->logfile,0)
       SELECT INTO "nl:"
        FROM dba_objects o
        WHERE (o.owner=dcdur_cmds->qual[dcdu_iter].owner)
         AND (o.object_name=dcdur_cmds->qual[dcdu_iter].name)
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       IF (curqual=0)
        SET dcdu_create_ind = 0
        IF ((dm_err->debug_flag > 0))
         SET dm_err->eproc = concat("No ",dcdur_cmds->qual[dcdu_iter].owner,".",dcdur_cmds->qual[
          dcdu_iter].name," object found in TARGET, skipping TABLE GRANT command.")
         CALL disp_msg("",dm_err->logfile,0)
        ENDIF
       ENDIF
      ENDIF
      IF (dcdu_create_ind=1)
       IF (dm2_push_cmd(build("rdb asis(^",dcdur_cmds->qual[dcdu_iter].command,"^) go"),1)=0)
        SET dm_err->err_ind = 0
        SET dm_err->eproc = "THE ABOVE ERROR MESSAGE IS IGNORABLE"
        CALL disp_msg(" ",dm_err->logfile,0)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   FOR (dcdu_iter = 1 TO dcdur_cmds->cnt)
     IF ((dcdur_cmds->qual[dcdu_iter].type="USER")
      AND (dcdur_cmds->qual[dcdu_iter].default_tspace_quota="Y"))
      SET dm_err->eproc = concat("Obtain default tablespace for [",dcdur_cmds->qual[dcdu_iter].owner,
       "] user.")
      CALL disp_msg(" ",dm_err->logfile,0)
      SELECT INTO "nl:"
       FROM dba_users du
       WHERE (du.username=dcdur_cmds->qual[dcdu_iter].owner)
       DETAIL
        dcdu_default_tspace = du.default_tablespace
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      SET dm_err->eproc = concat("Give unlimited tablespace quota to ",dcdur_cmds->qual[dcdu_iter].
       owner," user's default tablespace [",trim(dcdu_default_tspace),"].")
      CALL disp_msg(" ",dm_err->logfile,10)
      IF (dm2_push_cmd(concat("rdb asis(^alter user ",dcdur_cmds->qual[dcdu_iter].owner,
        " quota unlimited on ",trim(dcdu_default_tspace),"^) go"),1)=0)
       RETURN(0)
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_report_db_users_diff_tspaces(null)
   DECLARE drdudt_ndx = i4 WITH protect, noconstant(0)
   DECLARE drdudt_ndx2 = i4 WITH protect, noconstant(0)
   DECLARE drdudt_diff_tspace = i2 WITH protect, noconstant(0)
   DECLARE drdudt_str = vc WITH protect, noconstant(" ")
   DECLARE drdudt_file = vc WITH protect, noconstant("")
   FREE RECORD drdudt_user_tsp
   RECORD drdudt_user_tsp(
     1 cnt = i4
     1 qual[*]
       2 user = vc
       2 create_dt_tm = dq8
       2 src_default_tspace = vc
       2 src_temp_tspace = vc
       2 tgt_default_tspace = vc
       2 tgt_temp_tspace = vc
       2 dt_diff_ind = i2
       2 tt_diff_ind = i2
   )
   FREE RECORD dcdu_tspaces
   RECORD dcdu_tspaces(
     1 cnt = i4
     1 qual[*]
       2 tspace_name = vc
   )
   IF ((dcdur_input->fix_tspaces_ind != "Y"))
    RETURN(1)
   ENDIF
   IF (((size(trim(dcdur_input->default_tspace))=0) OR (((size(trim(dcdur_input->temp_tspace))=0) OR
   (size(trim(dcdur_input->user_list))=0)) )) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating input criteria."
    SET dm_err->emsg = "Invalid input."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dcdur_input)
    ENDIF
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcdur_input)
   ENDIF
   SET dm_err->eproc = "Retrieve list of Source custom database users based on defined user list."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_users@ref_data_link du
    WHERE parser(concat("du.username in (",dcdur_input->user_list,")"))
    ORDER BY du.username
    DETAIL
     drdudt_user_tsp->cnt = (drdudt_user_tsp->cnt+ 1), stat = alterlist(drdudt_user_tsp->qual,
      drdudt_user_tsp->cnt), drdudt_user_tsp->qual[drdudt_user_tsp->cnt].user = du.username,
     drdudt_user_tsp->qual[drdudt_user_tsp->cnt].src_default_tspace = du.default_tablespace,
     drdudt_user_tsp->qual[drdudt_user_tsp->cnt].src_temp_tspace = du.temporary_tablespace,
     drdudt_user_tsp->qual[drdudt_user_tsp->cnt].tgt_default_tspace = "",
     drdudt_user_tsp->qual[drdudt_user_tsp->cnt].tgt_temp_tspace = "", drdudt_user_tsp->qual[
     drdudt_user_tsp->cnt].dt_diff_ind = 0, drdudt_user_tsp->qual[drdudt_user_tsp->cnt].tt_diff_ind
      = 0
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Retrieving tablespaces from dba_tablespaces."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT DISTINCT INTO "nl:"
    dt.tablespace_name
    FROM dba_tablespaces dt
    DETAIL
     dcdu_tspaces->cnt = (dcdu_tspaces->cnt+ 1), stat = alterlist(dcdu_tspaces->qual,dcdu_tspaces->
      cnt), dcdu_tspaces->qual[dcdu_tspaces->cnt].tspace_name = dt.tablespace_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Retrieve list of Target custom database users based on defined user list."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_users du
    WHERE parser(concat("du.username in (",dcdur_input->user_list,")"))
    ORDER BY du.username
    DETAIL
     drdudt_ndx = 0, drdudt_ndx = locateval(drdudt_ndx,1,drdudt_user_tsp->cnt,du.username,
      drdudt_user_tsp->qual[drdudt_ndx].user)
     IF (drdudt_ndx > 0)
      drdudt_user_tsp->qual[drdudt_ndx].tgt_default_tspace = du.default_tablespace, drdudt_user_tsp->
      qual[drdudt_ndx].tgt_temp_tspace = du.temporary_tablespace, drdudt_user_tsp->qual[drdudt_ndx].
      create_dt_tm = du.created,
      drdudt_ndx2 = 0, drdudt_ndx2 = locateval(drdudt_ndx2,1,dcdu_tspaces->cnt,drdudt_user_tsp->qual[
       drdudt_ndx].src_default_tspace,dcdu_tspaces->qual[drdudt_ndx2].tspace_name)
      IF ((drdudt_user_tsp->qual[drdudt_ndx].src_default_tspace != drdudt_user_tsp->qual[drdudt_ndx].
      tgt_default_tspace)
       AND (drdudt_user_tsp->qual[drdudt_ndx].tgt_default_tspace=dcdur_input->default_tspace)
       AND drdudt_ndx2=0)
       drdudt_diff_tspace = 1, drdudt_user_tsp->qual[drdudt_ndx].dt_diff_ind = 1
      ENDIF
      drdudt_ndx2 = 0, drdudt_ndx2 = locateval(drdudt_ndx2,1,dcdu_tspaces->cnt,drdudt_user_tsp->qual[
       drdudt_ndx].src_temp_tspace,dcdu_tspaces->qual[drdudt_ndx2].tspace_name)
      IF ((drdudt_user_tsp->qual[drdudt_ndx].src_temp_tspace != drdudt_user_tsp->qual[drdudt_ndx].
      tgt_temp_tspace)
       AND (drdudt_user_tsp->qual[drdudt_ndx].tgt_temp_tspace=dcdur_input->temp_tspace)
       AND drdudt_ndx2=0)
       drdudt_diff_tspace = 1, drdudt_user_tsp->qual[drdudt_ndx].tt_diff_ind = 1
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(drdudt_user_tsp)
   ENDIF
   IF (drdudt_diff_tspace=1)
    IF (get_unique_file("dm2_db_user_tspace",".rpt")=0)
     RETURN(0)
    ENDIF
    SET drdudt_file = dm_err->unique_fname
    IF (validate(drrr_responsefile_in_use,0)=1)
     SET drdudt_file = build(drrr_misc_data->active_dir,drdudt_file)
    ENDIF
    SET dm_err->eproc = concat(
     "Reporting Target Database users having different default/temporary tablespaces then Source (",
     trim(drdudt_file),").")
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO value(drdudt_file)
     FROM (dummyt t  WITH seq = drdudt_user_tsp->cnt)
     HEAD REPORT
      col 50, "Database Users Missing Default/Temporary Tablespaces", row + 2,
      row + 1, drdudt_str = concat(
       "The following reports Source database users created in Target with different default and/or ",
       " temporary tablespaces due to the tablespaces not existing in Target."), col 0,
      drdudt_str, row + 2, row + 1,
      col 0, "Missing Default Tablespace replaced with: ", dcdur_input->default_tspace,
      row + 2, col 0, "Missing Temporary Tablespace replaced with: ",
      dcdur_input->temp_tspace, row + 2, row + 1,
      col 0, "A Default/Temporary Tablespace of '-' denotes no differences.", row + 2,
      row + 1, col 0, "User",
      col 35, "Created", col 70,
      "Source Default Tablespace", col 105, "Source Temporary Tablespace",
      row + 1, col 0, "------------------------------",
      col 35, "------------------------------", col 70,
      "------------------------------", col 105, "------------------------------",
      row + 1
     DETAIL
      IF ((((drdudt_user_tsp->qual[t.seq].dt_diff_ind=1)) OR ((drdudt_user_tsp->qual[t.seq].
      tt_diff_ind=1))) )
       drdudt_str = drdudt_user_tsp->qual[t.seq].user, col 0, drdudt_str,
       drdudt_str = format(cnvtdatetime(drdudt_user_tsp->qual[t.seq].create_dt_tm),";;q"), col 35,
       drdudt_str,
       drdudt_str = evaluate(drdudt_user_tsp->qual[t.seq].dt_diff_ind,1,drdudt_user_tsp->qual[t.seq].
        src_default_tspace,"-"), col 70, drdudt_str,
       drdudt_str = evaluate(drdudt_user_tsp->qual[t.seq].tt_diff_ind,1,drdudt_user_tsp->qual[t.seq].
        src_temp_tspace,"-"), col 105, drdudt_str,
       row + 1
      ENDIF
     WITH nocounter, maxcol = 250, format = variable,
      formfeed = none, maxrow = 1
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (validate(drrr_responsefile_in_use,0)=1)
     SET dm_err->eproc = concat(
      "Skipping display of Database Users Missing Default/Temporary Tablespaces Report (",trim(
       drdudt_file,3),")")
     CALL disp_msg("",dm_err->logfile,0)
     IF ((drer_email_list->email_cnt > 0))
      SET drer_email_det->msgtype = "ACTIONREQ"
      SET drer_email_det->status = "REPORT"
      SET drer_email_det->status_dt_tm = cnvtdatetime(curdate,curtime3)
      SET drer_email_det->step = "Database Users Missing Default/Temporary Tablespaces report"
      SET drer_email_det->email_level = 1
      SET drer_email_det->logfile = dm_err->logfile
      SET drer_email_det->err_ind = dm_err->err_ind
      SET drer_email_det->eproc = dm_err->eproc
      SET drer_email_det->emsg = dm_err->emsg
      SET drer_email_det->user_action = dm_err->user_action
      CALL drer_add_body_text(concat("Database Users Missing Default/Temporary Tablespaces ",
        "report was generated at ",format(drer_email_det->status_dt_tm,";;q")),1)
      CALL drer_add_body_text(concat(
        "User Action : Please review the report to ensure desired Default/Temporary Tablespaces",
        " are used for each user."),0)
      CALL drer_add_body_text(concat("Report file name is : ",drdudt_file),0)
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
      SET drer_email_det->step = "Database Users Missing Default/Temporary Tablespaces report"
      SET drer_email_det->email_level = 1
      SET drer_email_det->logfile = dm_err->logfile
      SET drer_email_det->err_ind = dm_err->err_ind
      SET drer_email_det->eproc = dm_err->eproc
      SET drer_email_det->emsg = dm_err->emsg
      SET drer_email_det->user_action = dm_err->user_action
      CALL drer_add_body_text(concat("Database Users Missing Default/Temporary Tablespaces ",
        "report was displayed at ",format(drer_email_det->status_dt_tm,";;q")),1)
      CALL drer_add_body_text(concat(
        "User Action : Return to dm2_domain_maint main session and review ",
        "Database Users Missing Default/Temporary Tablespaces report displayed on the screen.  Press <enter> to continue."
        ),0)
      CALL drer_add_body_text(concat("Report file name is ccluserdir: ",drdudt_file),0)
      IF (drer_compose_email(null)=1)
       CALL drer_send_email(drer_email_det->subject,drer_email_det->file_name,drer_email_det->
        email_level)
      ENDIF
      CALL drer_reset_pre_err(null)
     ENDIF
     IF (dm2_disp_file(drdudt_file,"Database Users Missing Default/Temporary Tablespaces")=0)
      RETURN(0)
     ENDIF
    ENDIF
   ELSE
    SET dm_err->eproc = "No database users with missing default/temporary tablespaces."
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_cleanup_pwds(dcp_in_dbname)
   SET dm_err->eproc = concat("Delete password data in Admin DM_INFO for database ",dcp_in_dbname)
   CALL disp_msg("",dm_err->logfile,0)
   DELETE  FROM dm2_admin_dm_info di
    WHERE di.info_domain="DM2_REPLICATE_USER_PWDS"
     AND di.info_name=patstring(cnvtupper(build(dcp_in_dbname,"*")))
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
 SUBROUTINE dcdur_insert_pwds(dip_in_dbname,dip_in_type,dip_in_user,dip_in_pwd)
   DECLARE dip_scrambled_pwd = vc WITH protect, noconstant("")
   SET dm_err->eproc = concat("Insert user password rows for database ",dip_in_dbname)
   CALL disp_msg("",dm_err->logfile,0)
   IF (((size(trim(dip_in_dbname))=0) OR (((size(trim(dip_in_type))=0) OR (((size(trim(dip_in_user))=
   0) OR (size(trim(dip_in_pwd))=0)) )) )) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating input criteria for insert of password."
    SET dm_err->emsg = "Invalid input."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dip_scrambled_pwd = dip_in_pwd
   IF (dip_in_type IN ("LOGIN", "SERVER"))
    SET dm2scramble->method_flag = 0
    SET dm2scramble->mode_ind = 1
    SET dm2scramble->in_text = dip_in_pwd
    IF (ds_scramble(null)=0)
     RETURN(0)
    ENDIF
    SET dm2scramble->out_text = replace(check(dm2scramble->out_text," ")," ","",0)
    SET dip_scrambled_pwd = dm2scramble->out_text
   ENDIF
   INSERT  FROM dm2_admin_dm_info di
    SET di.info_domain = "DM2_REPLICATE_USER_PWDS", di.info_name = cnvtupper(concat(trim(
        dip_in_dbname),"-",trim(dip_in_type),"-",trim(dip_in_user))), di.info_char =
     dip_scrambled_pwd,
     di.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc) > 0)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   COMMIT
 END ;Subroutine
 SUBROUTINE dcdur_preserve_pwds(dpp_in_dbname)
   DECLARE dpp_idx = i2 WITH protect, noconstant(0)
   DECLARE dpp_cmd_string = vc WITH protect, noconstant("")
   DECLARE dpp_iter = i4 WITH protect, noconstant(0)
   DECLARE dpp_owner = vc WITH protect, noconstant("")
   DECLARE dpp_str = vc WITH protect, noconstant("")
   DECLARE dpp_env = vc WITH protect, noconstant("")
   DECLARE dpp_domain = vc WITH protect, noconstant("")
   IF (dm2_push_cmd(concat(
     "rdb asis(^begin DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,",
     "'SQLTERMINATOR',TRUE); end;^) go"),1)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Retrieve CREATE USER DDL to retrieve password values."
   SELECT INTO "nl:"
    FROM (
     (
     (SELECT
      x = sqlpassthru("DBMS_METADATA.GET_DDL('USER', USERNAME)")
      FROM dba_users u
      WHERE u.username != "XS$NULL"
      WITH sqltype("C32000")))
     a)
    DETAIL
     IF (findstring(";",trim(a.x,3),1) > 0)
      dpp_cmd_string = replace(replace(replace(trim(a.x,3),char(0),""),char(10),""),char(13),""),
      dpp_owner = substring((findstring('"',dpp_cmd_string,1)+ 1),((findstring('"',dpp_cmd_string,(
        findstring('"',dpp_cmd_string,1)+ 1)) - findstring('"',dpp_cmd_string,1)) - 1),dpp_cmd_string
       ), dpp_idx = 0,
      dpp_idx = locateval(dpp_idx,1,dcdur_owner_pwds->cnt,dpp_owner,dcdur_owner_pwds->qual[dpp_idx].
       owner)
      IF (dpp_idx=0)
       IF (findstring("IDENTIFIED BY VALUES '",dpp_cmd_string,1) > 0)
        dcdur_owner_pwds->cnt = (dcdur_owner_pwds->cnt+ 1), stat = alterlist(dcdur_owner_pwds->qual,
         dcdur_owner_pwds->cnt), dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].type = "DB",
        dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].owner = dpp_owner, dcdur_owner_pwds->qual[
        dcdur_owner_pwds->cnt].pwd = substring((findstring("IDENTIFIED BY VALUES '",dpp_cmd_string,1)
         + 22),(findstring("'",dpp_cmd_string,((findstring("IDENTIFIED BY VALUES '",dpp_cmd_string,1)
          + 22)+ 1)) - (findstring("IDENTIFIED BY VALUES '",dpp_cmd_string,1)+ 22)),dpp_cmd_string)
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcdur_owner_pwds)
   ENDIF
   SET dm_err->eproc = "Get environment name."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dpp_env = cnvtlower(trim(logical("environment")))
   IF (trim(dpp_env) > " ")
    IF ((dm_err->debug_flag > 0))
     CALL echo(concat("ENVIRONMENT LOGICAL:",dpp_env))
    ENDIF
   ELSE
    SET dm_err->emsg = "Environment logical is not valued."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dpp_str = concat("\\environment\\",dpp_env," Domain")
   IF (ddr_lreg_oper("GET",dpp_str,dpp_domain)=0)
    RETURN(0)
   ENDIF
   IF (dpp_domain="NOPARMRETURNED")
    SET dm_err->emsg = concat("Unable to retrieve domain name property for ",dpp_env)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dcdur_get_server_users_pwds(dpp_domain)=0)
    RETURN(0)
   ENDIF
   IF (dcdur_get_db_owner_pwds(dpp_in_dbname)=0)
    RETURN(0)
   ENDIF
   IF ((dcdur_owner_pwds->cnt > 0))
    FOR (dpp_iter = 1 TO dcdur_owner_pwds->cnt)
      IF ((dcdur_owner_pwds->qual[dpp_iter].type IN ("LOGIN", "SERVER")))
       SET dm2scramble->method_flag = 0
       SET dm2scramble->mode_ind = 1
       SET dm2scramble->in_text = dcdur_owner_pwds->qual[dpp_iter].pwd
       IF (ds_scramble(null)=0)
        RETURN(0)
       ENDIF
       SET dm2scramble->out_text = replace(check(dm2scramble->out_text," ")," ","",0)
       SET dcdur_owner_pwds->qual[dpp_iter].pwd = dm2scramble->out_text
      ENDIF
    ENDFOR
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dcdur_owner_pwds)
    ENDIF
    IF (dcdur_cleanup_pwds(dpp_in_dbname)=0)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = concat("Insert user password rows for database ",dpp_in_dbname)
    CALL disp_msg("",dm_err->logfile,0)
    INSERT  FROM dm2_admin_dm_info di,
      (dummyt d  WITH seq = value(dcdur_owner_pwds->cnt))
     SET di.info_domain = "DM2_REPLICATE_USER_PWDS", di.info_name = cnvtupper(concat(trim(
         dpp_in_dbname),"-",trim(dcdur_owner_pwds->qual[d.seq].type),"-",trim(dcdur_owner_pwds->qual[
         d.seq].owner))), di.info_char = dcdur_owner_pwds->qual[d.seq].pwd,
      di.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     PLAN (d
      WHERE d.seq > 0)
      JOIN (di)
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc) > 0)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_restore_pwds(drp_in_dbname,drp_in_mode)
   DECLARE drp_idx = i2 WITH protect, noconstant(0)
   DECLARE drp_cmd_string = vc WITH protect, noconstant("")
   DECLARE drp_iter = i4 WITH protect, noconstant(0)
   DECLARE drp_str = vc WITH protect, noconstant("")
   DECLARE drp_issue_cmds = i2 WITH protect, noconstant(0)
   DECLARE drp_owner = vc WITH protect, noconstant("")
   DECLARE drp_sea = vc WITH protect, noconstant("")
   DECLARE drp_file = vc WITH protect, noconstant("")
   DECLARE drp_tmp_pwd = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE drp_env = vc WITH protect, noconstant("")
   DECLARE drp_domain = vc WITH protect, noconstant("")
   DECLARE drp_ret_val = vc WITH protect, noconstant("")
   DECLARE drp_tmp_owner = vc WITH protect, noconstant("")
   FREE RECORD drp_pwds
   RECORD drp_pwds(
     1 cnt = i4
     1 qual[*]
       2 owner = vc
       2 pwd = vc
   )
   FREE RECORD drp_cmds
   RECORD drp_cmds(
     1 cnt = i4
     1 qual[*]
       2 command = vc
       2 owner = vc
       2 common = vc
       2 oracle_maintained = vc
       2 pwd = vc
       2 issue_cmd = i2
   )
   IF (drp_in_mode IN ("SERVERS", "ALL"))
    SET dm_err->eproc = "Get environment name."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET drp_env = cnvtlower(trim(logical("environment")))
    IF (trim(drp_env) > " ")
     IF ((dm_err->debug_flag > 0))
      CALL echo(concat("ENVIRONMENT LOGICAL:",drp_env))
     ENDIF
    ELSE
     SET dm_err->emsg = "Environment logical is not valued."
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET drp_str = concat("\\environment\\",drp_env," Domain")
    IF (ddr_lreg_oper("GET",drp_str,drp_domain)=0)
     RETURN(0)
    ENDIF
    IF (drp_domain="NOPARMRETURNED")
     SET dm_err->emsg = concat("Unable to retrieve domain name property for ",drp_env)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = concat("Retrieve server user pwd rows for database ",drp_in_dbname)
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm2_admin_dm_info di
     WHERE di.info_domain="DM2_REPLICATE_USER_PWDS"
      AND di.info_name=patstring(cnvtupper(build(drp_in_dbname,"-SERVER*")))
      AND ((di.info_number != 99) OR (di.info_number = null))
     DETAIL
      drp_sea = cnvtupper(build(drp_in_dbname,"-SERVER-")), drp_owner = replace(di.info_name,drp_sea,
       "",0), drp_pwds->cnt = (drp_pwds->cnt+ 1),
      stat = alterlist(drp_pwds->qual,drp_pwds->cnt), drp_pwds->qual[drp_pwds->cnt].owner = cnvtupper
      (drp_owner), drp_pwds->qual[drp_pwds->cnt].pwd = di.info_char
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(drp_pwds)
    ENDIF
    IF ((drp_pwds->cnt > 0))
     IF (dcdur_get_server_users_pwds(drp_domain)=0)
      RETURN(0)
     ENDIF
     IF ((dcdur_server_pwds->cnt=0))
      SET dm_err->eproc =
      "No existing server 'Rdbms Password' properties to restore preserved passwords against."
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
    ELSE
     SET dm_err->eproc = "No preserved server passwords to restore."
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    IF ((drp_pwds->cnt > 0)
     AND (dcdur_server_pwds->cnt > 0))
     FOR (drp_iter = 1 TO drp_pwds->cnt)
       SET dm2scramble->method_flag = 0
       SET dm2scramble->mode_ind = 0
       SET dm2scramble->in_text = drp_pwds->qual[drp_iter].pwd
       IF (ds_scramble(null)=0)
        RETURN(0)
       ENDIF
       SET drp_pwds->qual[drp_iter].pwd = dm2scramble->out_text
     ENDFOR
     IF ((dm_err->debug_flag > 0))
      CALL echorecord(drp_pwds)
     ENDIF
    ENDIF
    IF ((dcdur_server_pwds->cnt > 0))
     FOR (drp_iter = 1 TO dcdur_server_pwds->cnt)
       SET drp_tmp_owner = cnvtupper(dcdur_server_pwds->qual[drp_iter].user)
       SET drp_idx = 0
       SET drp_idx = locateval(drp_idx,1,drp_pwds->cnt,drp_tmp_owner,drp_pwds->qual[drp_idx].owner)
       IF (drp_idx > 0)
        IF ( NOT ((dcdur_server_pwds->qual[drp_iter].server IN (58, 74))))
         SET dm_err->eproc = concat('Set "Rdbms Password" for server ',trim(cnvtstring(
            dcdur_server_pwds->qual[drp_iter].server)),".")
         CALL disp_msg("",dm_err->logfile,0)
         SET drp_str = concat("\\node\\",trim(curnode),"\\domain\\",drp_domain,"\\servers\\",
          trim(cnvtstring(dcdur_server_pwds->qual[drp_iter].server)),'\\prop "Rdbms Password" ','"',
          trim(drp_pwds->qual[drp_idx].pwd),'"')
         IF (ddr_lreg_oper("SET",drp_str,drp_ret_val)=0)
          RETURN(0)
         ENDIF
         SET drp_str = concat("\\node\\",trim(curnode),"\\domain\\",drp_domain,"\\servers\\",
          trim(cnvtstring(dcdur_server_pwds->qual[drp_iter].server)),'\\prop "Rdbms Password"')
         IF (ddr_lreg_oper("GET",drp_str,drp_ret_val)=0)
          RETURN(0)
         ENDIF
         IF (trim(drp_ret_val) != trim(drp_pwds->qual[drp_idx].pwd))
          SET dm_err->emsg = concat('Error setting "Rdbms Password" for server ',trim(cnvtstring(
             dcdur_server_pwds->qual[drp_iter].server)),".")
          SET dm_err->err_ind = 1
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          RETURN(0)
         ENDIF
        ELSE
         SET dm_err->eproc = concat("Skipping update of Rdbms Password for server ",trim(cnvtstring(
            dcdur_server_pwds->qual[drp_iter].server))," as already updated in earlier step.")
         CALL disp_msg("",dm_err->logfile,0)
        ENDIF
       ELSE
        SET dm_err->err_ind = 1
        SET dm_err->eproc = "Retrieving preserved password to complete restore."
        SET dm_err->emsg = concat("No preserved password found for server ",trim(cnvtstring(
           dcdur_server_pwds->qual[drp_iter].server))," and user ",trim(dcdur_server_pwds->qual[
          drp_iter].user),".")
        SET dm_err->user_action = concat(
         "After filling in <password> with original Target password, ",
         "execute the following and then rerun restore process: dm2_repl_insert_pwds 'SERVER', '",
         trim(dcdur_server_pwds->qual[drp_iter].user),"', '<password>' go")
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   IF (drp_in_mode IN ("DATABASE", "ALL"))
    SET dm_err->eproc = "Retrieve database users."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT
     IF ((dm2_rdbms_version->level1 >= 12))
      FROM (
       (
       (SELECT
        username = x.username, common = x.common, oracle_maintained = x.oracle_maintained
        FROM dba_users x
        WITH sqltype("C128","C3","C1")))
       du)
     ELSE
      FROM (
       (
       (SELECT
        username = x.username, common = "NO", oracle_maintained = "N"
        FROM dba_users x
        WITH sqltype("C128","C3","C1")))
       du)
     ENDIF
     INTO "nl:"
     du.username, du.common, du.oracle_maintained
     ORDER BY du.username
     DETAIL
      drp_cmds->cnt = (drp_cmds->cnt+ 1), stat = alterlist(drp_cmds->qual,drp_cmds->cnt), drp_cmds->
      qual[drp_cmds->cnt].owner = du.username,
      drp_cmds->qual[drp_cmds->cnt].common = du.common, drp_cmds->qual[drp_cmds->cnt].
      oracle_maintained = du.oracle_maintained, drp_cmds->qual[drp_cmds->cnt].issue_cmd = 0
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(drp_cmds)
    ENDIF
    SET dm_err->eproc = concat("Retrieve database user pwd rows for database ",drp_in_dbname)
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm2_admin_dm_info di
     WHERE di.info_domain="DM2_REPLICATE_USER_PWDS"
      AND di.info_name=patstring(cnvtupper(build(drp_in_dbname,"-DB*")))
      AND ((di.info_number != 99) OR (di.info_number = null))
     DETAIL
      drp_sea = cnvtupper(build(drp_in_dbname,"-DB-")), drp_owner = replace(di.info_name,drp_sea,"",0
       ), drp_idx = 0
      IF (drp_owner != "V500")
       drp_idx = locateval(drp_idx,1,drp_cmds->cnt,drp_owner,drp_cmds->qual[drp_idx].owner)
       IF (drp_idx > 0)
        drp_cmds->qual[drp_idx].pwd = di.info_char, drp_cmds->qual[drp_idx].command = concat(
         "ALTER USER ",build('"',trim(drp_cmds->qual[drp_idx].owner),'"')," IDENTIFIED BY VALUES ",
         build("'",trim(drp_cmds->qual[drp_idx].pwd),"'")," account unlock")
        IF ((drp_cmds->qual[drp_idx].common="NO")
         AND (drp_cmds->qual[drp_idx].oracle_maintained="N"))
         drp_cmds->qual[drp_idx].issue_cmd = 1, drp_issue_cmds = 1
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(drp_cmds)
    ENDIF
    IF (drp_issue_cmds=1)
     FOR (drp_iter = 1 TO drp_cmds->cnt)
       IF ((drp_cmds->qual[drp_iter].issue_cmd > 0))
        SET dm_err->eproc = concat("Restoring password for database user ",drp_cmds->qual[drp_iter].
         owner)
        CALL disp_msg("",dm_err->logfile,0)
        IF (dm2_push_cmd(build("rdb asis(^",drp_cmds->qual[drp_iter].command,"^) go"),1)=0)
         RETURN(0)
        ENDIF
       ELSE
        SET dm_err->eproc = concat("Skipping restore password for user ",drp_cmds->qual[drp_iter].
         owner," because either V500, COMMON or Oracle Maintained.")
        CALL disp_msg("",dm_err->logfile,0)
       ENDIF
     ENDFOR
    ELSE
     SET dm_err->eproc = "No preserved database users to restore passwords against."
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
   ENDIF
   IF (drp_in_mode IN ("DATABASE", "ALL", "LOGIN"))
    SET dm_err->eproc = concat("Retrieve login pwd rows for database ",drp_in_dbname)
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm2_admin_dm_info di
     WHERE di.info_domain="DM2_REPLICATE_USER_PWDS"
      AND di.info_name=patstring(cnvtupper(build(drp_in_dbname,"-LOGIN*")))
      AND ((di.info_number != 99) OR (di.info_number = null))
     DETAIL
      drp_tmp_pwd = di.info_char
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (drp_tmp_pwd="DM2NOTSET")
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validating preserved login password in Admin DM_INFO."
     SET dm_err->emsg = "No login password found."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm2scramble->method_flag = 0
    SET dm2scramble->mode_ind = 0
    SET dm2scramble->in_text = drp_tmp_pwd
    IF (ds_scramble(null)=0)
     RETURN(0)
    ENDIF
    SET drp_tmp_pwd = dm2scramble->out_text
    SET dm_err->eproc = 'Set "Rdbms Password" in registry, for the database property.'
    CALL disp_msg("",dm_err->logfile,0)
    SET drp_str = concat("\\database\\",trim(drp_in_dbname),"\\Node\\",trim(curnode),
     ' "Rdbms Password" ',
     '"',trim(drp_tmp_pwd),'"')
    IF (ddr_lreg_oper("SET",drp_str,drp_ret_val)=0)
     RETURN(0)
    ENDIF
    SET drp_str = concat("\\database\\",trim(drp_in_dbname),"\\Node\\",trim(curnode),
     ' "Rdbms Password" ')
    IF (ddr_lreg_oper("GET",drp_str,drp_ret_val)=0)
     RETURN(0)
    ENDIF
    IF (trim(drp_ret_val) != trim(drp_tmp_pwd))
     SET dm_err->emsg = 'Error setting "Rdbms Password" for database property in registry.'
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_get_server_users_pwds(dgsup_in_domain)
   DECLARE dgsup_idx = i2 WITH protect, noconstant(0)
   DECLARE dgsup_cmd_string = vc WITH protect, noconstant("")
   DECLARE dgsup_iter = i4 WITH protect, noconstant(0)
   DECLARE dgsup_str = vc WITH protect, noconstant("")
   DECLARE dgsup_num = i4 WITH protect, noconstant(0)
   DECLARE dgsup_fatal_err1 = i2 WITH protect, noconstant(0)
   DECLARE dgsup_fatal_err2 = i2 WITH protect, noconstant(0)
   DECLARE dgsup_fatal_str = vc WITH protect, noconstant("")
   DECLARE dgsup_err_msg = vc WITH protect, noconstant("")
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgsup_cmd_string = concat("mcr cer_exe:alter_server -domain ",dgsup_in_domain,
     ' -display "Rdbms Password"')
   ELSE
    SET dgsup_cmd_string = concat("$cer_exe/alter_server -domain ",dgsup_in_domain,
     ' -display "Rdbms Password"')
   ENDIF
   SET dm_err->disp_dcl_err_ind = 0
   IF (dm2_push_dcl(dgsup_cmd_string)=0)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Retrieve Rdbms Passwords for all servers."
   CALL disp_msg("",dm_err->logfile,0)
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(dm_err->errfile)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    t.line
    FROM rtl2t r
    WHERE r.line > " "
    HEAD REPORT
     dcdur_server_pwds->cnt = 0, stat = alterlist(dcdur_server_pwds->qual,dcdur_server_pwds->cnt)
    DETAIL
     beg_pos = 0, end_pos = 0, beg_pos2 = 0,
     end_pos2 = 0
     IF (findstring("rdbms password",cnvtlower(r.line),1,0) > 0)
      beg_pos = findstring("=",r.line,1,0), beg_pos2 = findstring("#",cnvtlower(r.line),1,0), end_pos
       = findstring(" ",r.line,(beg_pos+ 2),0),
      end_pos2 = findstring(" ",r.line,(beg_pos2+ 1),0)
      IF (beg_pos > 0
       AND end_pos > 0
       AND beg_pos2 > 0
       AND end_pos2 > 0)
       dgsup_num = cnvtint(substring((beg_pos2+ 1),((end_pos2 - beg_pos2) - 1),r.line)), dgsup_str =
       substring((beg_pos+ 2),((end_pos - beg_pos) - 1),r.line), dcdur_server_pwds->cnt = (
       dcdur_server_pwds->cnt+ 1),
       stat = alterlist(dcdur_server_pwds->qual,dcdur_server_pwds->cnt), dcdur_server_pwds->qual[
       dcdur_server_pwds->cnt].pwd = dgsup_str, dcdur_server_pwds->qual[dcdur_server_pwds->cnt].
       server = dgsup_num,
       dcdur_server_pwds->qual[dcdur_server_pwds->cnt].user = ""
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcdur_server_pwds)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgsup_cmd_string = concat("mcr cer_exe:alter_server -domain ",dgsup_in_domain,
     ' -display "Rdbms User Name"')
   ELSE
    SET dgsup_cmd_string = concat("$cer_exe/alter_server -domain ",dgsup_in_domain,
     ' -display "Rdbms User Name"')
   ENDIF
   SET dm_err->disp_dcl_err_ind = 0
   IF (dm2_push_dcl(dgsup_cmd_string)=0)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Retrieve Rdbms User Names for all servers with associated password property."
   CALL disp_msg("",dm_err->logfile,0)
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(dm_err->errfile)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    t.line
    FROM rtl2t r
    WHERE r.line > " "
    DETAIL
     beg_pos = 0, end_pos = 0, beg_pos2 = 0,
     end_pos2 = 0
     IF (findstring("rdbms user name",cnvtlower(r.line),1,0) > 0)
      beg_pos = findstring("=",r.line,1,0), beg_pos2 = findstring("#",cnvtlower(r.line),1,0), end_pos
       = findstring(" ",r.line,(beg_pos+ 2),0),
      end_pos2 = findstring(" ",r.line,(beg_pos2+ 1),0)
      IF (beg_pos > 0
       AND end_pos > 0
       AND beg_pos2 > 0
       AND end_pos2 > 0)
       dgsup_num = cnvtint(substring((beg_pos2+ 1),((end_pos2 - beg_pos2) - 1),r.line)), dgsup_str =
       substring((beg_pos+ 2),((end_pos - beg_pos) - 1),r.line), dgsup_idx = 0,
       dgsup_idx = locateval(dgsup_idx,1,dcdur_server_pwds->cnt,dgsup_num,dcdur_server_pwds->qual[
        dgsup_idx].server)
       IF (dgsup_idx > 0)
        dcdur_server_pwds->qual[dgsup_idx].user = dgsup_str
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcdur_server_pwds)
   ENDIF
   IF ((dcdur_server_pwds->cnt > 0))
    SET dm_err->eproc = "Rolling up Server User Name and Password properties."
    CALL disp_msg("",dm_err->logfile,0)
    FOR (dgsup_iter = 1 TO dcdur_server_pwds->cnt)
      IF ((dcdur_server_pwds->qual[dgsup_iter].user > "")
       AND (dcdur_server_pwds->qual[dgsup_iter].pwd > ""))
       IF ((dcdur_owner_pwds->cnt=0))
        SET dcdur_owner_pwds->cnt = (dcdur_owner_pwds->cnt+ 1)
        SET stat = alterlist(dcdur_owner_pwds->qual,dcdur_owner_pwds->cnt)
        SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].type = "SERVER"
        SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].owner = dcdur_server_pwds->qual[dgsup_iter]
        .user
        SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].pwd = dcdur_server_pwds->qual[dgsup_iter].
        pwd
       ELSE
        SET dgsup_idx = 0
        SET dgsup_idx = locateval(dgsup_idx,1,dcdur_owner_pwds->cnt,dcdur_server_pwds->qual[
         dgsup_iter].user,dcdur_owner_pwds->qual[dgsup_idx].owner,
         "SERVER",dcdur_owner_pwds->qual[dgsup_idx].type)
        IF (dgsup_idx > 0)
         IF ((dcdur_owner_pwds->qual[dgsup_idx].pwd != dcdur_server_pwds->qual[dgsup_iter].pwd))
          SET dgsup_fatal_err1 = 1
          IF (dgsup_fatal_str="")
           SET dgsup_fatal_str = concat(trim(dcdur_owner_pwds->qual[dgsup_idx].owner),", ")
          ELSE
           SET dgsup_fatal_str = concat(dgsup_fatal_str,trim(dcdur_owner_pwds->qual[dgsup_idx].owner),
            ", ")
          ENDIF
         ENDIF
        ELSE
         SET dcdur_owner_pwds->cnt = (dcdur_owner_pwds->cnt+ 1)
         SET stat = alterlist(dcdur_owner_pwds->qual,dcdur_owner_pwds->cnt)
         SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].type = "SERVER"
         SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].owner = dcdur_server_pwds->qual[dgsup_iter
         ].user
         SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].pwd = dcdur_server_pwds->qual[dgsup_iter].
         pwd
        ENDIF
       ENDIF
      ELSE
       SET dgsup_fatal_err2 = 1
      ENDIF
    ENDFOR
    IF (((dgsup_fatal_err1=1) OR (dgsup_fatal_err2=1)) )
     IF (dgsup_fatal_err2=1)
      SET dgsup_err_msg = concat(
       "'Rdbms Password' properties found without an associated 'Rdbms User Name' ","property.")
     ENDIF
     IF (dgsup_fatal_err1=1)
      SET dgsup_fatal_str = replace(dgsup_fatal_str,",","",2)
      SET dgsup_err_msg = concat(dgsup_err_msg,
       "   The following is a list of 'Rdbms User Name' property values with ",
       "inconsistent 'Rdbms Password' ","property values: ",trim(dgsup_fatal_str),
       ".")
     ENDIF
     IF ((dm2_sys_misc->cur_os="AXP"))
      SET dgsup_cmd_string = concat("mcr cer_exe:alter_server -domain ",dgsup_in_domain,
       ' -display "<property>"')
     ELSE
      SET dgsup_cmd_string = concat("$cer_exe/alter_server -domain ",dgsup_in_domain,
       ' -display "<property>"')
     ENDIF
     SET dgsup_err_msg = concat(trim(dgsup_err_msg,3),"   Use the following alter_server command to ",
      "reconcile issues:  ",trim(dgsup_cmd_string),".")
     SET dm_err->err_ind = 1
     SET dm_err->emsg = trim(dgsup_err_msg,3)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dcdur_owner_pwds)
    ENDIF
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo("No 'Rdbms Passwords' properties found for any servers.")
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_user_tspace_load(dutl_db_name)
   DECLARE dutl_info_domain = vc WITH protect, noconstant("")
   DECLARE dutl_len = i4 WITH protect, noconstant(0)
   DECLARE dutl_pos = i4 WITH protect, noconstant(0)
   DECLARE dutl_pos2 = i4 WITH protect, noconstant(0)
   DECLARE dutl_cur_user = vc WITH protect, noconstant("")
   DECLARE dutl_cur_idx = i4 WITH protect, noconstant(0)
   DECLARE dutl_ndx = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Load dcdur_user_data record structure"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dcdur_user_data->user_cnt=0))
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
     SET dm_err->eproc = "Retrieve tablespace mappings for TEMP and MISC"
     CALL disp_msg(" ",dm_err->logfile,0)
     SELECT INTO "nl:"
      FROM dm2_admin_dm_info d
      WHERE cnvtupper(d.info_domain)=patstring(build("DM2_",cnvtupper(dutl_db_name),
        "_*_TSPACE_MAPPING"))
       AND cnvtupper(d.info_name) IN ("MISC_TSPACE", "TEMP_TSPACE")
      HEAD REPORT
       dcdur_user_data->user_cnt = 0, stat = alterlist(dcdur_user_data->users,dcdur_user_data->
        user_cnt)
      DETAIL
       dutl_cur_idx = 0, dutl_cur_user = "", dutl_info_domain = d.info_domain,
       dutl_len = textlen(trim(dutl_db_name)), dutl_pos = findstring(trim(cnvtupper(dutl_db_name)),
        dutl_info_domain,1,0), dutl_pos = ((dutl_pos+ dutl_len)+ 1),
       dutl_pos2 = findstring("_TSPACE_MAPPING",dutl_info_domain,1,1), dutl_cur_user = substring(
        dutl_pos,(dutl_pos2 - dutl_pos),dutl_info_domain)
       IF ((dcdur_user_data->user_cnt > 0))
        dutl_cur_idx = locateval(dutl_ndx,1,dcdur_user_data->user_cnt,dutl_cur_user,dcdur_user_data->
         users[dutl_ndx].user)
       ENDIF
       IF (dutl_cur_idx=0)
        dcdur_user_data->user_cnt = (dcdur_user_data->user_cnt+ 1), stat = alterlist(dcdur_user_data
         ->users,dcdur_user_data->user_cnt), dcdur_user_data->users[dcdur_user_data->user_cnt].user
         = dutl_cur_user
        IF (cnvtupper(d.info_name)="MISC_TSPACE")
         dcdur_user_data->users[dcdur_user_data->user_cnt].misc_tspace = d.info_char
        ELSEIF (cnvtupper(d.info_name)="TEMP_TSPACE")
         dcdur_user_data->users[dcdur_user_data->user_cnt].temp_tspace = d.info_char
        ENDIF
       ELSE
        IF (cnvtupper(d.info_name)="MISC_TSPACE")
         dcdur_user_data->users[dutl_cur_idx].misc_tspace = d.info_char
        ELSEIF (cnvtupper(d.info_name)="TEMP_TSPACE")
         dcdur_user_data->users[dutl_cur_idx].temp_tspace = d.info_char
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcdur_user_data)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_insert_admin_tspace_rows(diatr_user_name,diatr_db_name,diatr_temp_ts,diatr_misc_ts)
   SET dm_err->eproc = "Verify that dm2_admin_dm_info public synonym exists"
   CALL disp_msg(" ",dm_err->logfile,0)
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
    SET dm_err->eproc = concat("Insert tablespace mappings rows into dm2_admin_dm_info for user: ",
     diatr_user_name)
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dm_err->eproc = "Insert MISC TSPACE mapping row"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    INSERT  FROM dm2_admin_dm_info d
     SET d.info_domain = concat("DM2_",trim(cnvtupper(diatr_db_name)),"_",trim(cnvtupper(
         diatr_user_name)),"_TSPACE_MAPPING"), d.info_name = "MISC_TSPACE", d.info_char =
      diatr_misc_ts
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Insert TEMP TSPACE mapping row"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    INSERT  FROM dm2_admin_dm_info d
     SET d.info_domain = concat("DM2_",trim(cnvtupper(diatr_db_name)),"_",trim(cnvtupper(
         diatr_user_name)),"_TSPACE_MAPPING"), d.info_name = "TEMP_TSPACE", d.info_char =
      diatr_temp_ts
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_prompt_tspaces(dpt_user_name,dpt_db_name,dpt_user_idx)
   DECLARE dpt_temp_ts_def = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dpt_misc_ts_def = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dpt_cur_ts_tmp = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dpt_len = i4 WITH protect, noconstant(0)
   DECLARE dpt_pos = i4 WITH protect, noconstant(0)
   DECLARE dpt_pos2 = i4 WITH protect, noconstant(0)
   DECLARE dpt_cur_idx = i4 WITH protect, noconstant(0)
   DECLARE dpt_ndx = i4 WITH protect, noconstant(0)
   DECLARE dpt_continue = i2 WITH protect, noconstant(1)
   DECLARE dpt_invalid_misc_ts = i2 WITH protect, noconstant(0)
   DECLARE dpt_invalid_temp_ts = i2 WITH protect, noconstant(0)
   IF (dcdur_user_tspace_load(dpt_db_name)=0)
    RETURN(0)
   ENDIF
   IF ((dcdur_user_data->user_cnt > 0))
    SET dpt_cur_idx = locateval(dpt_ndx,1,dcdur_user_data->user_cnt,cnvtupper(dpt_user_name),
     dcdur_user_data->users[dpt_ndx].user)
    IF (dpt_cur_idx > 0)
     SET dpt_user_idx = dpt_cur_idx
     RETURN(1)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Verify that current user is a valid user"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_users du
    WHERE cnvtupper(du.username)=cnvtupper(dpt_user_name)
    DETAIL
     dpt_temp_ts_def = trim(cnvtupper(du.temporary_tablespace)), dpt_misc_ts_def = trim(cnvtupper(du
       .default_tablespace))
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0
    AND validate(drrr_responsefile_in_use,0)=1
    AND validate(drrr_misc_data->process_type,"zz")="REFRESH")
    SET dpt_misc_ts_def = drrr_rf_data->tgt_default_misc_ts
    SET dpt_temp_ts_def = drrr_rf_data->tgt_default_temp_ts
    IF (((dpt_misc_ts_def="DM2NOTSET") OR (dpt_temp_ts_def="DM2NOTSET")) )
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validating if default tablespaces are set in the response file."
     SET dm_err->emsg = concat("Invalid values found for default tablespaces in the response file. ",
      "Please provide valid inputs for s_TGT_DEFAULT_MISC_TS and s_TGT_DEFAULT_TEMP_TS tokens.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (((curqual > 0) OR (curqual=0
    AND validate(drrr_responsefile_in_use,0)=1
    AND validate(drrr_misc_data->process_type,"zz")="REFRESH")) )
    IF ((dm_err->debug_flag > 0))
     CALL echo(dpt_temp_ts_def)
     CALL echo(dpt_misc_ts_def)
    ENDIF
    IF (dcdur_insert_admin_tspace_rows(dpt_user_name,dpt_db_name,dpt_temp_ts_def,dpt_misc_ts_def)=0)
     RETURN(0)
    ENDIF
    SET dcdur_user_data->user_cnt = (dcdur_user_data->user_cnt+ 1)
    SET stat = alterlist(dcdur_user_data->users,dcdur_user_data->user_cnt)
    SET dcdur_user_data->users[dcdur_user_data->user_cnt].user = dpt_user_name
    SET dcdur_user_data->users[dcdur_user_data->user_cnt].misc_tspace = dpt_misc_ts_def
    SET dcdur_user_data->users[dcdur_user_data->user_cnt].temp_tspace = dpt_temp_ts_def
    SET dpt_user_idx = dcdur_user_data->user_cnt
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Check if override values are set for MISC and TEMP tablespace mappings"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (trim(dcdur_user_data->misc_tspace_force) != "DM2NOTSET"
    AND trim(dcdur_user_data->misc_tspace_force) != ""
    AND trim(dcdur_user_data->temp_tspace_force) != "DM2NOTSET"
    AND trim(dcdur_user_data->temp_tspace_force) != "")
    SET dpt_misc_ts_def = dcdur_user_data->misc_tspace_force
    SET dpt_temp_ts_def = dcdur_user_data->temp_tspace_force
    IF ((dm_err->debug_flag > 0))
     CALL echo("OVERRIDING VALUES FOR TEMP AND MISC TSPACE MAPPING")
     CALL echo(dpt_temp_ts_def)
     CALL echo(dpt_misc_ts_def)
    ENDIF
    IF (dcdur_insert_admin_tspace_rows(dpt_user_name,dpt_db_name,dpt_temp_ts_def,dpt_misc_ts_def)=0)
     RETURN(0)
    ENDIF
    SET dcdur_user_data->user_cnt = (dcdur_user_data->user_cnt+ 1)
    SET stat = alterlist(dcdur_user_data->users,dcdur_user_data->user_cnt)
    SET dcdur_user_data->users[dcdur_user_data->user_cnt].user = dpt_user_name
    SET dcdur_user_data->users[dcdur_user_data->user_cnt].misc_tspace = dpt_misc_ts_def
    SET dcdur_user_data->users[dcdur_user_data->user_cnt].temp_tspace = dpt_temp_ts_def
    SET dpt_user_idx = dcdur_user_data->user_cnt
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Set default values for MISC and TEMP tablespace mappings"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (trim(dcdur_user_data->misc_tspace_default)="DM2NOTSET")
    SET dm_err->eproc = "Retrieve MISC tablespace from dba_tablespaces"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dba_tablespaces dt
     WHERE dt.tablespace_name="MISC"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual > 0)
     SET dcdur_user_data->misc_tspace_default = "MISC"
    ENDIF
    IF ((dcdur_user_data->user_cnt > 0))
     SET dcdur_user_data->misc_tspace_default = dcdur_user_data->users[1].misc_tspace
    ENDIF
   ENDIF
   IF (trim(dcdur_user_data->temp_tspace_default)="DM2NOTSET")
    SET dm_err->eproc = "Retrieve temp tablespace from dba_tablespaces"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dba_tablespaces dt
     WHERE dt.tablespace_name="TEMP"
      AND dt.contents="TEMPORARY"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual > 0)
     SET dcdur_user_data->temp_tspace_default = "TEMP"
    ELSE
     SET dm_err->eproc = "Retrieve temp tablespace contents from dba_tablespaces"
     CALL disp_msg(" ",dm_err->logfile,0)
     SELECT INTO "nl:"
      FROM dba_tablespaces dt
      WHERE dt.contents="TEMPORARY"
      DETAIL
       dpt_cur_ts_tmp = dt.tablespace_name
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (curqual > 0)
      SET dcdur_user_data->temp_tspace_default = dpt_cur_ts_tmp
     ENDIF
    ENDIF
    IF ((dcdur_user_data->user_cnt > 0))
     SET dcdur_user_data->temp_tspace_default = dcdur_user_data->users[1].temp_tspace
    ENDIF
   ENDIF
   SET dm_err->eproc = "Prompt user for MISC and TEMP tablespace mappings"
   CALL disp_msg(" ",dm_err->logfile,0)
   WHILE (dpt_continue=1)
     SET message = window
     CALL clear(1,1)
     CALL box(1,1,3,132)
     CALL text(2,2,"TABLESPACE MAPPING PROMPTS")
     CALL text(2,70,"DATE/TIME: ")
     CALL text(2,80,format(cnvtdatetime(curdate,curtime3),";;Q"))
     IF (dpt_invalid_temp_ts=1
      AND dpt_invalid_misc_ts=1)
      CALL text(5,2,concat(
        "Both MISC and TEMP tablespace mappings provided could not be validated in dba_tablespaces.",
        " Please provide an alternate mappings."))
     ELSEIF (dpt_invalid_temp_ts=1)
      CALL text(5,2,concat(
        "TEMP tablespace provided is not a valid TEMPORARY tablespace in dba_tablespaces.",
        " Please provide an alternate mapping."))
     ELSEIF (dpt_invalid_misc_ts=1)
      CALL text(5,2,concat("MISC tablespace provided is not a valid tablespace in dba_tablespaces.",
        " Please provide an alternate mapping."))
     ELSE
      CALL clear(5,2,100)
     ENDIF
     SET dpt_invalid_temp_ts = 0
     SET dpt_invalid_misc_ts = 0
     CALL text(7,2,concat("MISC Tablespace for ",dpt_user_name,": "))
     CALL text(9,2,concat("TEMP Tablespace for ",dpt_user_name,": "))
     CALL accept(7,40,"P(30);CU",evaluate(dcdur_user_data->misc_tspace_default,"DM2NOTSET"," ",
       dcdur_user_data->misc_tspace_default)
      WHERE curaccept != " ")
     SET dpt_misc_ts_def = trim(curaccept)
     CALL accept(9,40,"P(30);CU",evaluate(dcdur_user_data->temp_tspace_default,"DM2NOTSET"," ",
       dcdur_user_data->temp_tspace_default)
      WHERE curaccept != " ")
     SET dpt_temp_ts_def = trim(curaccept)
     CALL text(12,2,"(C)ontinue, (M)odify, (Q)uit :")
     CALL accept(12,34,"p;cu","C"
      WHERE curaccept IN ("C", "M", "Q"))
     SET message = nowindow
     CASE (curaccept)
      OF "Q":
       SET dm_err->emsg = "User Quit Process"
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dpt_misc_ts_def = "DM2NOTSET"
       SET dpt_temp_ts_def = "DM2NOTSET"
       SET dpt_continue = 0
       RETURN(0)
      OF "C":
       IF ((((dpt_misc_ts_def != dcdur_user_data->misc_tspace_default)) OR ((dpt_temp_ts_def !=
       dcdur_user_data->temp_tspace_default))) )
        SET dm_err->eproc = "Verifying that MISC and TEMP tablspace mappings provided are valid"
        CALL disp_msg(" ",dm_err->logfile,0)
        SET dm_err->eproc = "Retrieve temp tablespace from dba_tablespaces"
        CALL disp_msg(" ",dm_err->logfile,0)
        SELECT INTO "nl:"
         FROM dba_tablespaces dt
         WHERE dt.tablespace_name=dpt_temp_ts_def
          AND dt.contents="TEMPORARY"
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
        IF (curqual=0)
         SET dpt_continue = 1
         SET dpt_invalid_temp_ts = 1
        ENDIF
        SET dm_err->eproc = "Retrieve misc tablespace from dba_tablespaces"
        CALL disp_msg(" ",dm_err->logfile,0)
        SELECT INTO "nl:"
         FROM dba_tablespaces dt
         WHERE dt.tablespace_name=dpt_misc_ts_def
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
        IF (curqual=0)
         SET dpt_continue = 1
         SET dpt_invalid_misc_ts = 1
        ENDIF
        IF (dpt_invalid_misc_ts=0
         AND dpt_invalid_temp_ts=0)
         SET dpt_continue = 0
        ELSE
         SET dpt_continue = 1
        ENDIF
       ELSE
        SET dpt_continue = 0
       ENDIF
      OF "M":
       SET dpt_continue = 1
     ENDCASE
   ENDWHILE
   IF (dcdur_insert_admin_tspace_rows(dpt_user_name,dpt_db_name,dpt_temp_ts_def,dpt_misc_ts_def)=0)
    RETURN(0)
   ENDIF
   SET dcdur_user_data->user_cnt = (dcdur_user_data->user_cnt+ 1)
   SET stat = alterlist(dcdur_user_data->users,dcdur_user_data->user_cnt)
   SET dcdur_user_data->users[dcdur_user_data->user_cnt].user = dpt_user_name
   SET dcdur_user_data->users[dcdur_user_data->user_cnt].misc_tspace = dpt_misc_ts_def
   SET dcdur_user_data->users[dcdur_user_data->user_cnt].temp_tspace = dpt_temp_ts_def
   SET dpt_user_idx = dcdur_user_data->user_cnt
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_user_tspace_cleanup(dutc_user_name,dutc_db_name)
   SET dm_err->eproc = "Verify that dm2_admin_dm_info public synonym exists"
   CALL disp_msg(" ",dm_err->logfile,0)
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
    SET dm_err->eproc = concat("Cleanup tablespace mappings rows in dm2_admin_dm_info for user: ",
     dutc_user_name)
    CALL disp_msg(" ",dm_err->logfile,0)
    DELETE  FROM dm2_admin_dm_info d
     WHERE d.info_domain=patstring(build("DM2_",cnvtupper(dutc_db_name),"_",cnvtupper(dutc_user_name),
       "_TSPACE_MAPPING"))
     WITH nocounter
    ;end delete
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcdur_get_db_owner_pwds(dgdop_in_dbname)
   DECLARE dgdop_str = vc WITH protect, noconstant("")
   DECLARE dgdop_pwd_val = vc WITH protect, noconstant("")
   DECLARE dgdop_user_val = vc WITH protect, noconstant("")
   SET dm_err->eproc = 'Get "Rdbms User Name" from registry.'
   CALL disp_msg("",dm_err->logfile,0)
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgdop_str = concat("\database\",trim(dgdop_in_dbname),"\Node\",trim(curnode),
     ' "Rdbms User Name" ')
   ELSE
    SET dgdop_str = concat("\\database\\",trim(dgdop_in_dbname),"\\Node\\",trim(curnode),
     ' "Rdbms User Name" ')
   ENDIF
   IF (ddr_lreg_oper("GET",dgdop_str,dgdop_user_val)=0)
    RETURN(0)
   ENDIF
   IF (dgdop_user_val="NOPARMRETURNED")
    SET dm_err->emsg = concat("Unable to retrieve Rdbms User Name property for ",trim(dgdop_in_dbname
      ))
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (dgdop_user_val != "v500")
    SET dm_err->emsg = concat("Retrieved Rdbms User Name for DB ",trim(dgdop_in_dbname)," is ",
     dgdop_user_val," instead of v500")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = 'Get "Rdbms Password" from registry.'
   CALL disp_msg("",dm_err->logfile,0)
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dgdop_str = concat("\database\",trim(dgdop_in_dbname),"\Node\",trim(curnode),
     ' "Rdbms Password" ')
   ELSE
    SET dgdop_str = concat("\\database\\",trim(dgdop_in_dbname),"\\Node\\",trim(curnode),
     ' "Rdbms Password" ')
   ENDIF
   IF (ddr_lreg_oper("GET",dgdop_str,dgdop_pwd_val)=0)
    RETURN(0)
   ENDIF
   IF (dgdop_pwd_val="NOPARMRETURNED")
    SET dm_err->emsg = concat("Unable to retrieve Rdbms Password property for ",trim(dgdop_in_dbname)
     )
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dcdur_owner_pwds->cnt = (dcdur_owner_pwds->cnt+ 1)
   SET stat = alterlist(dcdur_owner_pwds->qual,dcdur_owner_pwds->cnt)
   SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].type = "LOGIN"
   SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].owner = dgdop_user_val
   SET dcdur_owner_pwds->qual[dcdur_owner_pwds->cnt].pwd = dgdop_pwd_val
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcdur_owner_pwds)
   ENDIF
   RETURN(1)
 END ;Subroutine
 FREE RECORD dm_env_import_request
 RECORD dm_env_import_request(
   1 remote_node_name = vc
   1 local_ind = i2
   1 target_environment_name = vc
   1 target_environment_id = f8
   1 target_environment_exists = i2
   1 target_environment_description = vc
   1 target_database_name = vc
   1 target_connect_string = vc
   1 target_cdb_name = vc
   1 target_database_version = i4
   1 target_oracle_version = vc
   1 major_tgt_ora_ver_int = i4
   1 database_extent_management = vc
   1 database_storage_type = vc
   1 character_set = vc
   1 cerner_mtpt = vc
   1 ora_sft_mtpt = vc
   1 ora_link_mtpt = vc
   1 local_node_name = vc
   1 local_oracle_home_log = vc
   1 db_node_op_system = vc
   1 rdbms_registry = vc
   1 source_host_name = vc
   1 source_instance_name = vc
   1 source_connect_string = vc
   1 source_v500_pwd = vc
   1 source_dbase_name = vc
   1 source_instance_cnt = i4
   1 admin_host_name = vc
   1 admin_instance_name = vc
   1 admin_connect_string = vc
   1 admin_user_name = vc
   1 admin_pwd = vc
   1 oracle_sys_pwd = vc
   1 dbca_used_ind = i2
   1 remote_hosts_cnt = i4
   1 remote_hosts[*]
     2 host_name = vc
     2 ping_success_ind = i2
     2 emsg = vc
   1 all_pings_successful_ind = i2
   1 db_oracle_home = vc
   1 db_oracle_base = vc
   1 asm_oracle_home = vc
   1 asm_sysdba_pwd = vc
   1 sys_user = vc
   1 sys_pwd = vc
   1 system_pwd = vc
   1 ftp_user_name = vc
   1 ftp_pwd = vc
   1 tgt_exec_dir = vc
   1 target_tns_host = vc
   1 target_tns_port = vc
   1 source_tns_port = vc
   1 admin_tns_port = vc
   1 asm_storage_disk_group = vc
   1 asm_recovery_disk_group = vc
   1 log_archive_dest_1 = vc
   1 response_file_used_ind = i2
   1 ignorable_error_codes = vc
   1 mode = vc
   1 admin_dbase_name = vc
   1 admin_oracle_version = vc
   1 local_node_name_sn = vc
   1 remote_node_name_sn = vc
   1 shared_pool_size = vc
   1 source_case_sens_login_val = vc
   1 source_lvl4_oracle_version = vc
   1 target_lvl4_oracle_version = vc
   1 source_db_node_name = vc
   1 source_sql92_security_val = vc
   1 source_o7_dict_access_val = vc
 )
 SET dm_env_import_request->response_file_used_ind = 0
 SET dm_env_import_request->target_tns_port = "1521"
 SET dm_env_import_request->source_tns_port = "1521"
 SET dm_env_import_request->admin_tns_port = "1521"
 SET dm_env_import_request->log_archive_dest_1 = "DM2_NOT_SET"
 SET dm_env_import_request->ignorable_error_codes = "DM2NOTSET"
 SET dm_env_import_request->mode = "DM2NOTSET"
 SET dm_env_import_request->source_case_sens_login_val = "FALSE"
 SET dm_env_import_request->source_sql92_security_val = "FALSE"
 SET dm_env_import_request->source_o7_dict_access_val = "TRUE"
 FREE RECORD deir_char_set
 RECORD deir_char_set(
   1 char_set_str = vc
   1 cnt = i4
   1 qual[*]
     2 char_set_value = vc
 )
 SET deir_char_set->cnt = 0
 DECLARE deir_label_start = i2 WITH protect, constant(2)
 DECLARE deir_data_start = i2 WITH protect, constant(35)
 DECLARE deir_label_start2 = i2 WITH protect, constant(75)
 DECLARE deir_data_start2 = i2 WITH protect, constant(100)
 DECLARE deir_msg = vc WITH protect, noconstant("")
 DECLARE deir_menu_choice = vc WITH protect, noconstant("")
 DECLARE deir_failed = i2 WITH protect, noconstant(0)
 DECLARE deir_temp_line = vc WITH protect, noconstant("")
 DECLARE deir_process_registry_ind = i2 WITH protect, noconstant(1)
 DECLARE deir_source_env_name = vc WITH protect, noconstant("DM2_NOT_SET")
 DECLARE deir_env_selection_cont = i2 WITH protect, noconstant(1)
 DECLARE deir_dbca_tgt_file = vc WITH protect, noconstant("")
 DECLARE deir_sync_tgt_file = vc WITH protect, noconstant("")
 DECLARE deir_iter = i4 WITH protect, noconstant(0)
 DECLARE deir_iter2 = i4 WITH protect, noconstant(0)
 DECLARE deir_search = i4 WITH protect, noconstant(0)
 DECLARE deir_temp_string = vc WITH protect, noconstant("")
 DECLARE deir_connectivity_ind = i2 WITH protect, noconstant(0)
 DECLARE deir_src_characterset = vc WITH protect, noconstant("")
 DECLARE deir_src_extent_mgmt = vc WITH protect, noconstant("")
 DECLARE deir_src_storage_type = vc WITH protect, noconstant("")
 DECLARE deir_cont = i2 WITH protect, noconstant(1)
 DECLARE deir_use_autoftp = i2 WITH protect, noconstant(1)
 DECLARE deir_error_prefixes = vc WITH protect, noconstant("DM2NOTSET")
 DECLARE deir_shared_pool_size_max = f8 WITH protect, noconstant(4294967296.0)
 DECLARE deir_shared_pool_size_1 = f8 WITH protect, noconstant(536870912.0)
 DECLARE deir_shared_pool_size_2 = f8 WITH protect, noconstant(1241513984.0)
 DECLARE deir_loc = i2 WITH protect, noconstant(0)
 DECLARE deir_src_v500_users = vc WITH protect, noconstant("")
 DECLARE deir_case_cnt = i2 WITH protect, noconstant(0)
 DECLARE deir_pdb_cnt = i2 WITH protect, noconstant(0)
 DECLARE deir_src_tmp_full_dir = vc WITH protect, noconstant("")
 DECLARE deir_clear_screen_main_and_repopulate(null) = null
 DECLARE deir_clear_screen_instruct_and_repopulate(null) = vc
 DECLARE deir_clear_screen_reg1_and_repopulate(null) = vc
 DECLARE deir_clear_screen_reg2_and_repopulate(null) = vc
 DECLARE deir_clear_screen_ora_and_repopulate(null) = vc
 DECLARE deir_clear_screen_sys_prompt(null) = null
 DECLARE deir_clear_screen_dbca_and_repopulate(null) = vc
 DECLARE deir_clear_screen_dbca_ftp_tns_and_repopulate(null) = vc
 DECLARE deir_clear_screen_tns_verify_and_repopulate(null) = vc
 DECLARE deir_clear_screen_tns_format_verify_and_repopulate(null) = vc
 DECLARE deir_display_tns_report(ddtr_format_ind=i2) = i2
 DECLARE deir_remote_host_name_list_prompt(null) = i2
 DECLARE deir_main_screen_prompt(dmsp_selection=vc(ref)) = i2
 DECLARE deir_main_screen_summary(dmss_selection=vc(ref)) = i2
 DECLARE deir_characterset_prompt(dcp_new_characterset=vc) = i2
 DECLARE deir_process_response_file(null) = i2
 DECLARE deir_check_response_file(null) = i2
 DECLARE deir_validate_response_data(null) = i2
 DECLARE deir_clear_screen_silent_dbca_and_repopulate(null) = vc
 DECLARE deir_test_ftp(null) = i2
 DECLARE deir_manage_tns_formatting(null) = i2
 DECLARE deir_add_tns_entries(null) = i2
 DECLARE deir_update_registry(null) = i2
 DECLARE deir_rrr_shell_creation(null) = i2
 DECLARE deir_rrr_create_db(null) = i2
 DECLARE deir_rrr_app_tns_cnct_work(dratw_mode=i2) = i2
 DECLARE deir_rrr_chk_connect(drcc_in_node=vc,drcc_in_ora_home=vc,drcc_in_dir_path=vc,drcc_in_uname=
  vc,drcc_in_upwd=vc,
  drcc_in_db_connect=vc,drcc_in_dbinstance=vc,drcc_in_dbhost=vc,drcc_in_ora_version=vc) = i2
 DECLARE deir_rrr_verify_ssh_setup(drvss_node=vc,drvss_db_node_ind=i2,drvss_node_os=vc(ref),
  drvss_node_ln=vc(ref)) = i2
 DECLARE deir_load_characterset(null) = i2
 DECLARE deir_create_misc_ts(null) = i2
 DECLARE deir_rrr_get_nbr_list(drgnl_dir=vc,drgnl_file_prefix=vc,drgnl_nbr_list=vc(ref)) = i2
 DECLARE deir_mng_temp_tspaces(null) = i2
 IF (check_logfile("dm2_create_db_shell",".log","dm2_create_db_shell LOGFILE")=0)
  GO TO exit_script
 ENDIF
 IF ( NOT ((dm2_sys_misc->cur_os IN ("AXP", "AIX", "HPX", "LNX"))))
  SET dm_err->eproc =
  "The database shell creation process can only be used from a VMS, AIX, LNX or HPUX node."
  CALL disp_msg(" ",dm_err->logfile,0)
  GO TO exit_script
 ENDIF
 IF (validate(drrr_responsefile_in_use,0)=1)
  SET dm_err->eproc = "Response file detected and will be used to complete database shell creation."
  CALL disp_msg("",dm_err->logfile,0)
  IF (validate(drrr_rf_data->responsefile_version,"X")="X"
   AND validate(drrr_rf_data->responsefile_version,"Z")="Z")
   SET dm_err->eproc = "Verify response file structures accessible"
   SET dm_err->emsg = "Response file structure could not be accessed."
   SET dm_err->err_ind = 1
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  IF ((dm_err->debug_flag > 0))
   CALL echorecord(drrr_rf_data)
   CALL echorecord(drrr_misc_data)
  ENDIF
  SET dm2_install_schema->cdba_p_word = drrr_rf_data->adm_db_user_pwd
  SET dm2_install_schema->cdba_connect_str = drrr_rf_data->adm_db_cnct_str
  SET dm_env_import_request->admin_user_name = "CDBA"
  SET dm_env_import_request->admin_pwd = drrr_rf_data->adm_db_user_pwd
  SET dm_env_import_request->admin_connect_string = drrr_rf_data->adm_db_cnct_str
  SET dm2_install_schema->src_v500_p_word = drrr_rf_data->src_db_user_pwd
  SET dm2_install_schema->src_v500_connect_str = drrr_rf_data->src_db_cnct_str
  SET dm_env_import_request->source_v500_pwd = drrr_rf_data->src_db_user_pwd
  SET dm_env_import_request->source_connect_string = drrr_rf_data->src_db_cnct_str
  SET dm2_install_schema->v500_p_word = drrr_rf_data->tgt_db_user_pwd
  SET dm2_install_schema->v500_connect_str = drrr_rf_data->tgt_db_cnct_str
  IF ((drrr_rf_data->mode="ISOLATED"))
   SET dm2_skip_source_processing = 1
   SET deir_src_tmp_full_dir = build(drrr_rf_data->tgt_app_temp_dir,cnvtlower(drrr_rf_data->
     src_env_name),"/")
   IF ((drrr_misc_data->process_mode="ADMIN DATABASE CREATION"))
    SET dm2_skip_admin_processing = 1
    SET dm2_tgt_db_type_flag = "ADMIN"
   ENDIF
   IF ((drrr_misc_data->process_mode="CLINICAL DATABASE CREATION"))
    SET dir_db_users_pwds->cnt = 0
    SET stat = alterlist(dir_db_users_pwds->qual,0)
    FOR (deir_iter = 1 TO drrr_misc_data->tgt_db_user_pwd_map_cnt)
      SET dir_db_users_pwds->cnt = (dir_db_users_pwds->cnt+ 1)
      SET stat = alterlist(dir_db_users_pwds->qual,dir_db_users_pwds->cnt)
      SET dir_db_users_pwds->qual[dir_db_users_pwds->cnt].user = drrr_misc_data->tgt_db_user_pwd_map[
      deir_iter].user
      SET dir_db_users_pwds->qual[dir_db_users_pwds->cnt].pwd = drrr_misc_data->tgt_db_user_pwd_map[
      deir_iter].pwd
    ENDFOR
   ENDIF
   SET dm_env_import_request->source_lvl4_oracle_version = "DM2NOTSET"
   SET dm_env_import_request->source_o7_dict_access_val = "DM2NOTSET"
   SET dm_env_import_request->source_case_sens_login_val = drrr_rf_data->tgt_case_sens_logon
   SET dm_env_import_request->source_sql92_security_val = drrr_rf_data->tgt_sql92_security
   SET dm_env_import_request->source_db_node_name = "DM2NOTSET"
   SET deir_source_env_name = drrr_rf_data->src_db_env_name
   SET deir_src_characterset = drrr_rf_data->tgt_characterset
   SET dm_env_import_request->character_set = deir_src_characterset
   SET dm_env_import_request->source_dbase_name = "DM2NOTSET"
   SET dm_env_import_request->source_instance_cnt = 0
   SET deir_src_extent_mgmt = "LOCAL"
   SET deir_src_storage_type = "ASM"
   SET deir_error_prefixes = drrr_rf_data->tgt_error_prefix_list
  ENDIF
 ENDIF
 SET dm_env_import_request->dbca_used_ind = 1
 IF ((dm2_sys_misc->cur_os != "AXP")
  AND validate(drrr_responsefile_in_use,0) != 1)
  IF (deir_check_response_file(null)=0)
   GO TO exit_script
  ENDIF
 ENDIF
 IF (dm_env_import_request->response_file_used_ind)
  IF (deir_process_response_file(null)=0)
   GO TO exit_script
  ENDIF
 ENDIF
 IF (validate(dm2_mig_db_ind,- (1))=1)
  SET deir_process_registry_ind = 0
  SET dm2_skip_registry_processing = 1
 ENDIF
 IF (validate(dm2_tgt_db_type_flag,"XXX")="ADMIN")
  SET dm2_skip_admin_processing = 1
  SET dm2_skip_source_processing = 1
  SET dm2_skip_env_hist_processing = 1
  SET dm2_skip_create_users = 1
 ELSEIF (validate(dm2_tgt_db_type_flag,"XXX")="STRT")
  SET dm2_skip_admin_processing = 1
  SET dm2_skip_source_processing = 1
  SET dm2_skip_env_hist_processing = 1
 ELSEIF (validate(dm2_tgt_db_type_flag,"XXX")="ADMMIG")
  SET dm2_skip_registry_processing = 1
  SET dm2_skip_admin_processing = 1
  SET dm2_skip_source_processing = 1
  SET dm2_skip_env_hist_processing = 1
  SET dm2_skip_create_users = 1
 ENDIF
 IF ((validate(dm2_skip_source_processing,- (1))=- (1)))
  IF (validate(dm2_mig_db_ind,- (1))=1)
   SET dm2_install_schema->dbase_name = dmr_mig_data->src_db_name
   SET dm2_install_schema->u_name = "V500"
   SET dm2_install_schema->p_word = dmr_mig_data->src_v500_pwd
   SET dm2_install_schema->connect_str = dmr_mig_data->src_v500_cnct_str
   EXECUTE dm2_connect_to_dbase "CO"
  ELSE
   SET dm2_install_schema->dbase_name = '"SOURCE"'
   SET dm2_install_schema->u_name = "V500"
   IF ((((dm_env_import_request->response_file_used_ind=1)) OR (validate(drrr_responsefile_in_use,0)=
   1)) )
    SET dm2_install_schema->p_word = dm_env_import_request->source_v500_pwd
    SET dm2_install_schema->connect_str = dm_env_import_request->source_connect_string
    EXECUTE dm2_connect_to_dbase "CO"
   ELSE
    SET dm2_force_connect_string = 1
    EXECUTE dm2_connect_to_dbase "PC"
    SET dm2_force_connect_string = 0
   ENDIF
  ENDIF
  IF ((dm_err->err_ind=1))
   GO TO exit_script
  ELSE
   SET dm2_install_schema->src_v500_p_word = dm2_install_schema->p_word
   SET dm2_install_schema->src_v500_connect_str = dm2_install_schema->connect_str
   SET dm_env_import_request->source_v500_pwd = dm2_install_schema->p_word
   SET dm_env_import_request->source_connect_string = dm2_install_schema->connect_str
  ENDIF
  IF (validate(drrr_responsefile_in_use,0)=1)
   SET dir_db_users_pwds->cnt = 0
   SET stat = alterlist(dir_db_users_pwds->qual,0)
   FOR (deir_iter = 1 TO drrr_misc_data->tgt_db_user_pwd_map_cnt)
     SET dir_db_users_pwds->cnt = (dir_db_users_pwds->cnt+ 1)
     SET stat = alterlist(dir_db_users_pwds->qual,dir_db_users_pwds->cnt)
     SET dir_db_users_pwds->qual[dir_db_users_pwds->cnt].user = drrr_misc_data->tgt_db_user_pwd_map[
     deir_iter].user
     SET dir_db_users_pwds->qual[dir_db_users_pwds->cnt].pwd = drrr_misc_data->tgt_db_user_pwd_map[
     deir_iter].pwd
   ENDFOR
  ELSE
   SET dm_err->eproc = "Determine which v500* users exist in Source."
   SELECT
    IF (validate(dm2_mig_db_ind,- (1))=1)
     WHERE du.username IN ("V500_EVENT", "V500_READ", "V500_REF", "V500")
    ELSE
     WHERE du.username IN ("V500_EVENT", "V500_READ", "V500")
    ENDIF
    INTO "nl:"
    du.username
    FROM dba_users du
    HEAD REPORT
     row + 0
    DETAIL
     deir_src_v500_users = concat(trim(deir_src_v500_users),trim(du.username),",")
    FOOT REPORT
     deir_src_v500_users = replace(deir_src_v500_users,",","",2)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_script
   ENDIF
   SET dm_err->eproc = "Prompt for user passwords."
   IF (dir_load_users_pwds(deir_src_v500_users)=0)
    GO TO exit_script
   ENDIF
  ENDIF
  SET dm_err->eproc = "Gathering oracle version from Source."
  IF (dm2_get_rdbms_version(null)=0)
   GO TO exit_script
  ENDIF
  IF ((dm_err->debug_flag > 0))
   CALL echorecord(dm2_rdbms_version)
  ENDIF
  IF ((dm2_rdbms_version->level1 < 19))
   SET dm_env_import_request->source_lvl4_oracle_version = concat(trim(cnvtstring(dm2_rdbms_version->
      level1)),".",trim(cnvtstring(dm2_rdbms_version->level2)),".",trim(cnvtstring(dm2_rdbms_version
      ->level3)),
    ".",trim(cnvtstring(dm2_rdbms_version->level4)))
  ELSE
   SET dm_env_import_request->source_lvl4_oracle_version = concat(trim(cnvtstring(dm2_rdbms_version->
      level1)),".0.0.0")
  ENDIF
  IF (validate(drrr_rf_data->src_db_deploy_config,"xx") != "ADB"
   AND (validate(dm2_bypass_src_param_check,- (1))=- (1)))
   SET dm_env_import_request->source_o7_dict_access_val = "FALSE"
   SET dm_env_import_request->major_tgt_ora_ver_int = dm2_rdbms_version->level1
   SET dm_err->eproc = "Gathering v$parameter info from Source."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT
    IF ((dm_env_import_request->major_tgt_ora_ver_int > 12))
     FROM v$parameter vp
     WHERE cnvtlower(vp.name) IN ("sec_case_sensitive_logon", "sql92_security")
    ELSE
     FROM v$parameter vp
     WHERE cnvtlower(vp.name) IN ("sec_case_sensitive_logon", "sql92_security",
     "o7_dictionary_accessibility")
    ENDIF
    INTO "nl:"
    DETAIL
     CASE (cnvtlower(vp.name))
      OF "sec_case_sensitive_logon":
       dm_env_import_request->source_case_sens_login_val = vp.value
      OF "o7_dictionary_accessibility":
       dm_env_import_request->source_o7_dict_access_val = vp.value
      OF "sql92_security":
       dm_env_import_request->source_sql92_security_val = vp.value
     ENDCASE
     deir_case_cnt = (deir_case_cnt+ 1)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_script
   ENDIF
   IF ((((dm_env_import_request->major_tgt_ora_ver_int <= 12)
    AND deir_case_cnt < 3) OR ((dm_env_import_request->major_tgt_ora_ver_int > 12)
    AND deir_case_cnt < 2)) )
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Not all v$parameter rows found in Source. Exiting script."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_script
   ENDIF
  ENDIF
  SET dm_err->eproc = "Determining SOURCE db node name."
  SELECT INTO "nl:"
   FROM v$instance vi
   DETAIL
    dm_env_import_request->source_db_node_name = vi.host_name
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc))
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  SET dm_err->eproc = "Gathering source info."
  CALL disp_msg("",dm_err->logfile,0)
  SET dm_err->eproc = "Determining current environment name from dm_info."
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="DATA MANAGEMENT"
    AND di.info_name="DM_ENV_NAME"
   DETAIL
    deir_source_env_name = di.info_char
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  SET dm_err->eproc = "Determining SOURCE character set from v$nls_parameters."
  SELECT INTO "nl:"
   FROM v$nls_parameters vnp
   WHERE vnp.parameter="NLS_CHARACTERSET"
   DETAIL
    IF (validate(dm2_mig_db_ind,- (1))=1)
     dm_env_import_request->character_set = vnp.value, deir_src_characterset = vnp.value
    ELSE
     deir_src_characterset = vnp.value
    ENDIF
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc))
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  SET dm_env_import_request->source_dbase_name = currdbname
  IF ((dm_err->debug_flag > 0))
   CALL echo(build("source_dbase_name = ",dm_env_import_request->source_dbase_name))
  ENDIF
  SET dm_err->eproc = "Determining SOURCE instance count from gv$instance."
  SELECT INTO "nl:"
   cnt = count(*)
   FROM gv$instance gvi
   DETAIL
    dm_env_import_request->source_instance_cnt = cnt
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc))
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  SET dm_err->eproc = "Determining SOURCE database extent management."
  SELECT INTO "nl:"
   FROM dba_tablespaces dt
   WHERE dt.tablespace_name="SYSTEM"
   DETAIL
    IF (validate(dm2_mig_db_ind,- (1))=1)
     dm_env_import_request->database_extent_management = "LOCAL", deir_src_extent_mgmt = dt
     .extent_management
    ELSE
     deir_src_extent_mgmt = dt.extent_management
    ENDIF
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc))
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  SET dm_err->eproc = "Determining SOURCE database storage type."
  SELECT INTO "nl:"
   FROM dba_data_files ddf
   WHERE ddf.tablespace_name="SYSTEM"
    AND ddf.file_name=patstring("/dev/*")
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc))
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ELSE
   IF (curqual > 0)
    SET deir_src_storage_type = "RAW"
   ELSE
    SET deir_src_storage_type = "ASM"
   ENDIF
  ENDIF
  SET dm_err->eproc = "Getting error prefix overrides."
  IF ((dm_err->debug_flag > 0))
   CALL disp_msg("",dm_err->logfile,0)
  ENDIF
  SELECT INTO "nl:"
   FROM dm_info d
   WHERE d.info_domain="DM2_RRR_DATA"
    AND d.info_name="DB_SHELL_ERROR_PREFIXES"
   DETAIL
    deir_error_prefixes = trim(d.info_char)
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((validate(dm2_skip_admin_processing,- (1))=- (1)))
  IF (validate(dm2_mig_db_ind,- (1))=1)
   SET dm2_install_schema->dbase_name = "ADMIN"
   SET dm2_install_schema->u_name = "CDBA"
   SET dm2_install_schema->p_word = dmr_mig_data->adm_cdba_pwd
   SET dm2_install_schema->connect_str = dmr_mig_data->adm_cdba_cnct_str
   EXECUTE dm2_connect_to_dbase "CO"
   SET dm_env_import_request->source_connect_string = dmr_mig_data->src_v500_cnct_str
   SET dm_env_import_request->source_host_name = dmr_mig_data->src_nodes[1].node_name
   SET dm_env_import_request->source_instance_name = dmr_mig_data->src_nodes[1].instance_name
  ELSE
   SET dm2_install_schema->dbase_name = "ADMIN"
   IF ((((dm_env_import_request->response_file_used_ind=1)) OR (validate(drrr_responsefile_in_use,0)=
   1)) )
    SET dm2_install_schema->u_name = dm_env_import_request->admin_user_name
    SET dm2_install_schema->p_word = dm_env_import_request->admin_pwd
    SET dm2_install_schema->connect_str = dm_env_import_request->admin_connect_string
    EXECUTE dm2_connect_to_dbase "CO"
   ELSE
    EXECUTE dm2_connect_to_dbase "SC"
   ENDIF
  ENDIF
  IF ((dm_err->err_ind=1))
   GO TO exit_script
  ENDIF
  SET dm_env_import_request->admin_dbase_name = currdbname
  IF ((dm_err->debug_flag > 0))
   CALL echo(build("admin_dbase_name = ",dm_env_import_request->admin_dbase_name))
  ENDIF
  SET dm_err->eproc = "Querying for instance information from v$instance."
  SELECT INTO "nl:"
   FROM v$instance v
   DETAIL
    dm_env_import_request->admin_host_name = cnvtlower(v.host_name), dm_env_import_request->
    admin_instance_name = cnvtlower(v.instance_name)
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  SET dm_env_import_request->admin_connect_string = dm2_install_schema->connect_str
 ENDIF
 IF ((dm2_sys_misc->cur_os="AXP"))
  SET dm_err->eproc = "Determining oracle version for VMS."
  CALL dm2_push_dcl("@CER_INSTALL:DM_GET_ORACLE_VERSION.COM")
  IF ((dm_err->err_ind=1))
   GO TO exit_script
  ENDIF
  SET dm_env_import_request->rdbms_registry = logical("VERSION")
 ELSE
  SET dm_err->eproc = "Determining oracle version for AIX/HPUX."
  IF (dm2_push_dcl("$cer_install/dm_get_oracle_version.ksh")=0)
   GO TO exit_script
  ENDIF
  FREE DEFINE rtl
  FREE SET file_loc
  SET logical file_loc value("/tmp/dm_get_oracle_version.out")
  DEFINE rtl "file_loc"
  SELECT INTO "nl:"
   r.line
   FROM rtlt r
   DETAIL
    dm_env_import_request->rdbms_registry = substring(1,10,r.line)
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
 ENDIF
 SET dm_env_import_request->target_database_version = 1001
 SET dm_env_import_request->cerner_mtpt = "/cerner"
 SET dm_env_import_request->ora_sft_mtpt = "/u01"
 SET dm_env_import_request->ora_link_mtpt = "/u02"
 SET dm_env_import_request->local_node_name = build(curnode)
 SET dm_env_import_request->local_node_name_sn = build(curnode)
 SET dm_err->eproc = "Getting ORACLE_HOME"
 SET dm_env_import_request->local_oracle_home_log = logical("ORACLE_HOME")
 IF (build(dm_env_import_request->local_oracle_home_log)="")
  SET dm_err->emsg = "ORACLE_HOME logical not defined."
  SET dm_err->err_ind = 1
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF (deir_load_characterset(null)=0)
  GO TO exit_script
 ENDIF
 IF ((validate(dm2_shared_pool_max_override,- (999.00)) != - (999.00)))
  SET deir_shared_pool_size_max = cnvtreal(dm2_shared_pool_max_override)
 ENDIF
 IF (validate(drrr_responsefile_in_use,0)=1)
  IF (deir_rrr_shell_creation(null)=0)
   GO TO exit_script
  ENDIF
  GO TO exit_script
 ENDIF
 IF ( NOT (dm_env_import_request->response_file_used_ind))
  IF (deir_main_screen_prompt(deir_menu_choice)=0)
   GO TO exit_script
  ENDIF
  SET dm_env_import_request->target_connect_string = concat(dm_env_import_request->
   target_database_name,"1")
 ELSE
  IF (deir_validate_response_data(null)=0)
   GO TO exit_script
  ENDIF
  IF (deir_main_screen_summary(deir_menu_choice)=0)
   GO TO exit_script
  ENDIF
 ENDIF
 CALL echo(dm_env_import_request->major_tgt_ora_ver_int)
 IF ((dm_env_import_request->major_tgt_ora_ver_int >= 11)
  AND (dm_env_import_request->major_tgt_ora_ver_int < 19))
  SET deir_loc = findstring(".",dm_env_import_request->db_oracle_home,1)
  SET dm_env_import_request->target_lvl4_oracle_version = substring((deir_loc - 2),8,
   dm_env_import_request->db_oracle_home)
 ELSE
  SET dm_env_import_request->target_lvl4_oracle_version = concat(trim(cnvtstring(
     dm_env_import_request->major_tgt_ora_ver_int)),".0.0.0")
 ENDIF
 IF ((((dm2_sys_misc->cur_os="AXP")) OR ((((dm_env_import_request->db_node_op_system="LNX")
  AND (dm_env_import_request->target_oracle_version=patstring("10.*"))) OR ((((dm_env_import_request
 ->remote_hosts_cnt > 1)) OR (validate(skip_autoftp,- (1))=1)) )) )) )
  SET deir_use_autoftp = 0
 ENDIF
 IF (deir_menu_choice IN ("C", "S"))
  SET des_env_data->db_node_os = dm_env_import_request->db_node_op_system
  SET des_env_data->db_ora_version = dm_env_import_request->target_oracle_version
  SET des_env_data->env_name = dm_env_import_request->target_environment_name
  SET des_env_data->env_desc = dm_env_import_request->target_environment_description
  SET des_env_data->db_name = dm_env_import_request->target_database_name
  SET des_env_data->loaded_ind = 1
  IF ( NOT (validate(dm2_tgt_db_type_flag,"XXX") IN ("ADMIN", "ADMMIG")))
   EXECUTE dm2_create_db_env
   IF ((dm_err->err_ind=1))
    GO TO exit_script
   ENDIF
  ENDIF
  IF (deir_use_autoftp
   AND (dm_env_import_request->local_ind=0))
   IF (deir_test_ftp(null)=0)
    GO TO exit_script
   ENDIF
  ENDIF
  IF (deir_menu_choice="C")
   IF ( NOT (dm_env_import_request->dbca_used_ind))
    FREE DEFINE rtl2
    SET logical file_name value(concat("CER_INSTALL:",cnvtlower(dm_env_import_request->
       db_node_op_system),"db_create.txt"))
    DEFINE rtl2 "file_name"  WITH nomodify
    SET dm_err->eproc = concat("Creating ",build("CCLUSERDIR:v500db_",cnvtlower(dm_env_import_request
       ->target_database_name),"_create.ksh"))
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO build("CCLUSERDIR:v500db_",cnvtlower(dm_env_import_request->target_database_name),
      "_create.ksh")
     FROM rtl2t r
     HEAD REPORT
      ora_ver_len = 0, ora_ver = "xx.xxx.xxx.xxx"
     DETAIL
      deir_temp_line = replace(r.line,"<<dbname>>",cnvtlower(build(dm_env_import_request->
         target_database_name)),0), deir_temp_line = replace(deir_temp_line,"<<dbcharset>>",build(
        dm_env_import_request->character_set),0), deir_temp_line = replace(deir_temp_line,
       "<<remote_node>>",build(dm_env_import_request->target_tns_host),0),
      deir_temp_line = replace(deir_temp_line,"<<target_tns_port>>",build(dm_env_import_request->
        target_tns_port),0), deir_temp_line = replace(deir_temp_line,"<<admin_host_name>>",build(
        dm_env_import_request->admin_host_name),0), deir_temp_line = replace(deir_temp_line,
       "<<admin_instance_name>>",build(dm_env_import_request->admin_instance_name),0),
      deir_temp_line = replace(deir_temp_line,"<<admin_connect_str>>",build(dm_env_import_request->
        admin_connect_string),0), deir_temp_line = replace(deir_temp_line,"<<admin_tns_port>>",build(
        dm_env_import_request->admin_tns_port),0)
      IF (validate(dm2_mig_db_ind,- (1))=1)
       deir_temp_line = replace(deir_temp_line,"<<source_connect_string>>",build(
         dm_env_import_request->source_connect_string),0), deir_temp_line = replace(deir_temp_line,
        "<<source_host_name>>",build(dm_env_import_request->source_host_name),0), deir_temp_line =
       replace(deir_temp_line,"<<source_instance_name>>",build(dm_env_import_request->
         source_instance_name),0),
       deir_temp_line = replace(deir_temp_line,"<<source_tns_port>>",build(dm_env_import_request->
         source_tns_port),0)
      ELSE
       deir_temp_line = replace(deir_temp_line,"<<source_connect_string>>",build(
         dm_env_import_request->target_database_name,"1"),0), deir_temp_line = replace(deir_temp_line,
        "<<source_host_name>>",build(dm_env_import_request->remote_node_name),0), deir_temp_line =
       replace(deir_temp_line,"<<source_instance_name>>",build(dm_env_import_request->
         target_database_name,"1"),0),
       deir_temp_line = replace(deir_temp_line,"<<source_tns_port>>",build(dm_env_import_request->
         target_tns_port),0)
      ENDIF
      IF (deir_temp_line=patstring("<<CERNER*"))
       ora_ver_len = (findstring(">>",substring(10,size(deir_temp_line),deir_temp_line)) - 1),
       ora_ver = substring(1,ora_ver_len,substring(10,size(deir_temp_line),deir_temp_line))
       IF ((ora_ver=dm_env_import_request->target_oracle_version))
        CALL print(substring((12+ ora_ver_len),size(deir_temp_line),deir_temp_line)), row + 1
       ENDIF
      ELSE
       IF (deir_temp_line > " ")
        CALL print(deir_temp_line), row + 1
       ENDIF
      ENDIF
     WITH nocounter, maxrow = 1, maxcol = 2001,
      format = variable, formfeed = none
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_script
    ENDIF
    FREE DEFINE rtl2
    SET logical file_name value(concat("CER_INSTALL:",cnvtlower(dm_env_import_request->
       db_node_op_system),"db_config.txt"))
    DEFINE rtl2 "file_name"  WITH nomodify
    SET dm_err->eproc = concat("Creating ",build("CCLUSERDIR:v500db_",cnvtlower(dm_env_import_request
       ->target_database_name),"_config.ora"))
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO build("CCLUSERDIR:v500db_",cnvtlower(dm_env_import_request->target_database_name),
      "_config.ora")
     FROM rtl2t r
     HEAD REPORT
      ora_ver_len = 0, ora_ver = "xx.xxx.xxx.xxx"
     DETAIL
      deir_temp_line = replace(r.line,"<<dbname>>",cnvtlower(build(dm_env_import_request->
         target_database_name)),0)
      IF (deir_temp_line=patstring("<<CERNER*"))
       ora_ver_len = (findstring(">>",substring(10,size(deir_temp_line),deir_temp_line)) - 1),
       ora_ver = substring(1,ora_ver_len,substring(10,size(deir_temp_line),deir_temp_line))
       IF ((ora_ver=dm_env_import_request->target_oracle_version))
        CALL print(substring((12+ ora_ver_len),size(deir_temp_line),deir_temp_line)), row + 1
       ENDIF
      ELSE
       IF (deir_temp_line > " ")
        CALL print(deir_temp_line), row + 1
       ENDIF
      ENDIF
     WITH nocounter, maxrow = 1, maxcol = 2001,
      format = variable, formfeed = none
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_script
    ENDIF
    FREE DEFINE rtl2
    SET logical file_name value(concat("CER_INSTALL:",cnvtlower(dm_env_import_request->
       db_node_op_system),"db_create_db.txt"))
    DEFINE rtl2 "file_name"  WITH nomodify
    SET dm_err->eproc = concat("Creating ",build("CCLUSERDIR:v500db_",cnvtlower(dm_env_import_request
       ->target_database_name),"_create_db.sql"))
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO build("CCLUSERDIR:v500db_",cnvtlower(dm_env_import_request->target_database_name),
      "_create_db.sql")
     FROM rtl2t r
     HEAD REPORT
      ora_ver_len = 0, ora_ver = "xx.xxx.xxx.xxx"
     DETAIL
      deir_temp_line = replace(r.line,"<<dbname>>",cnvtlower(build(dm_env_import_request->
         target_database_name)),0), deir_temp_line = replace(deir_temp_line,"<<dbcharset>>",build(
        dm_env_import_request->character_set),0)
      IF ((dm_env_import_request->database_extent_management="LOCAL"))
       deir_temp_line = replace(deir_temp_line,"<<database_extent_management>>",
        "extent management local",0)
      ELSE
       deir_temp_line = replace(deir_temp_line,"<<database_extent_management>>","",0)
      ENDIF
      IF (deir_temp_line=patstring("<<CERNER*"))
       ora_ver_len = (findstring(">>",substring(10,size(deir_temp_line),deir_temp_line)) - 1),
       ora_ver = substring(1,ora_ver_len,substring(10,size(deir_temp_line),deir_temp_line))
       IF ((ora_ver=dm_env_import_request->target_oracle_version))
        CALL print(substring((12+ ora_ver_len),size(deir_temp_line),deir_temp_line)), row + 1
       ENDIF
      ELSE
       IF (deir_temp_line > " ")
        CALL print(deir_temp_line), row + 1
       ENDIF
      ENDIF
     WITH nocounter, maxrow = 1, maxcol = 2001,
      format = variable, formfeed = none
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_script
    ENDIF
    FREE DEFINE rtl2
    SET logical file_name value(concat("CER_INSTALL:",cnvtlower(dm_env_import_request->
       db_node_op_system),"db_init1.txt"))
    DEFINE rtl2 "file_name"  WITH nomodify
    SET dm_err->eproc = concat("Creating ",build("CCLUSERDIR:v500db_",cnvtlower(dm_env_import_request
       ->target_database_name),"_init1.ora"))
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO build("CCLUSERDIR:v500db_",cnvtlower(dm_env_import_request->target_database_name),
      "_init1.ora")
     FROM rtl2t r
     HEAD REPORT
      ora_ver_len = 0, ora_ver = "xx.xxx.xxx.xxx"
     DETAIL
      deir_temp_line = replace(r.line,"<<dbname>>",cnvtlower(build(dm_env_import_request->
         target_database_name)),0), deir_temp_line = replace(deir_temp_line,"<<db_oracle_base>>",
       cnvtlower(build(dm_env_import_request->db_oracle_base)),0)
      IF (deir_temp_line=patstring("<<CERNER*"))
       ora_ver_len = (findstring(">>",substring(10,size(deir_temp_line),deir_temp_line)) - 1),
       ora_ver = substring(1,ora_ver_len,substring(10,size(deir_temp_line),deir_temp_line))
       IF ((ora_ver=dm_env_import_request->target_oracle_version))
        CALL print(substring((12+ ora_ver_len),size(deir_temp_line),deir_temp_line)), row + 1
       ENDIF
      ELSE
       IF (deir_temp_line > " ")
        CALL print(deir_temp_line), row + 1
       ENDIF
      ENDIF
     WITH nocounter, maxrow = 1, maxcol = 2001,
      format = variable, formfeed = none
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_script
    ENDIF
    FREE DEFINE rtl2
    SET logical file_name "CER_INSTALL:dm2_updatetns.txt"
    DEFINE rtl2 "file_name"  WITH nomodify
    SET dm_err->eproc = concat("Creating ",build("CCLUSERDIR:v500db_",cnvtlower(dm_env_import_request
       ->target_database_name),"_updatetns.ksh"))
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO build("CCLUSERDIR:v500db_",cnvtlower(dm_env_import_request->target_database_name),
      "_updatetns.ksh")
     FROM rtl2t r
     DETAIL
      CALL print(build(r.line)), row + 1
     WITH nocounter, maxrow = 1, maxcol = 2001,
      format = variable, formfeed = none
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_script
    ENDIF
    FREE DEFINE rtl2
    SET logical file_name "CER_INSTALL:dm2_update_sqlnetora.txt"
    DEFINE rtl2 "file_name"  WITH nomodify
    SET dm_err->eproc = concat("Creating ",build("CCLUSERDIR:v500db_",cnvtlower(dm_env_import_request
       ->target_database_name),"_updsqlnetora.ksh"))
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO build("CCLUSERDIR:v500db_",cnvtlower(dm_env_import_request->target_database_name),
      "_updsqlnetora.ksh")
     FROM rtl2t r
     DETAIL
      CALL print(build(r.line)), row + 1
     WITH nocounter, maxrow = 1, maxcol = 2001,
      format = variable, formfeed = none
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_script
    ENDIF
    FREE DEFINE rtl2
    SET logical file_name value(concat("CER_INSTALL:",cnvtlower(dm_env_import_request->
       db_node_op_system),"db_definitions.txt"))
    DEFINE rtl2 "file_name"  WITH nomodify
    SET dm_err->eproc = concat("Creating ",build("CCLUSERDIR:v500db_",cnvtlower(dm_env_import_request
       ->target_database_name),"_definitions.ksh"))
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO build("CCLUSERDIR:v500db_",cnvtlower(dm_env_import_request->target_database_name),
      "_definitions.ksh")
     FROM rtl2t r
     HEAD REPORT
      ora_ver_len = 0, ora_ver = "xx.xxx.xxx.xxx"
     DETAIL
      deir_temp_line = replace(r.line,"<<target_oracle_version>>",build(dm_env_import_request->
        target_oracle_version),0), deir_temp_line = replace(deir_temp_line,"<<dbname>>",cnvtlower(
        build(dm_env_import_request->target_database_name)),0), deir_temp_line = replace(
       deir_temp_line,"<<dbcharset>>",build(dm_env_import_request->character_set),0),
      deir_temp_line = replace(deir_temp_line,"<<oracle_home>>",build(dm_env_import_request->
        db_oracle_home),0)
      IF (deir_temp_line=patstring("<<CERNER*"))
       ora_ver_len = (findstring(">>",substring(10,size(deir_temp_line),deir_temp_line)) - 1),
       ora_ver = substring(1,ora_ver_len,substring(10,size(deir_temp_line),deir_temp_line))
       IF ((ora_ver=dm_env_import_request->target_oracle_version))
        CALL print(substring((12+ ora_ver_len),size(deir_temp_line),deir_temp_line)), row + 1
       ENDIF
      ELSE
       CALL print(deir_temp_line), row + 1
      ENDIF
     WITH nocounter, maxrow = 1, maxcol = 2000,
      format = variable, formfeed = none
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_script
    ENDIF
    FREE DEFINE rtl2
    IF (deir_clear_screen_instruct_and_repopulate(null)="Q")
     GO TO exit_script
    ENDIF
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dm_env_import_request)
    ENDIF
    IF ((dm_env_import_request->major_tgt_ora_ver_int >= 11))
     FREE DEFINE rtl2
     IF ((dm_env_import_request->target_oracle_version=patstring("12.*")))
      SET logical file_name value(build("CER_INSTALL:dm2_master_122_ksh.txt"))
     ELSEIF ((dm_env_import_request->target_oracle_version=patstring("19*")))
      SET logical file_name value(build("CER_INSTALL:dm2_master_19_ksh.txt"))
     ELSE
      SET logical file_name value(build("CER_INSTALL:dm2_master_111_ksh.txt"))
     ENDIF
     DEFINE rtl2 "file_name"  WITH nomodify
     SET dm_err->eproc = concat("Creating ",build("CCLUSERDIR:v500db_",cnvtlower(
        dm_env_import_request->target_database_name),"_create.ksh"))
     CALL disp_msg("",dm_err->logfile,0)
     SELECT INTO build("CCLUSERDIR:v500db_",cnvtlower(dm_env_import_request->target_database_name),
       "_create.ksh")
      FROM rtl2t r
      DETAIL
       deir_temp_line = replace(r.line,"[[db_home]]",build(dm_env_import_request->db_oracle_home),0),
       deir_temp_line = replace(deir_temp_line,"[[db_node_os]]",build(dm_env_import_request->
         db_node_op_system),0), deir_temp_line = replace(deir_temp_line,"[[tgt_exec_dir]]",build(
         dm_env_import_request->tgt_exec_dir),0),
       deir_temp_line = replace(deir_temp_line,"[[oracle_base]]",build(dm_env_import_request->
         db_oracle_base),0)
       IF ((dm_env_import_request->major_tgt_ora_ver_int >= 12))
        deir_temp_line = replace(deir_temp_line,"[[cdbname]]",cnvtlower(build(dm_env_import_request->
           target_cdb_name)),0), deir_temp_line = replace(deir_temp_line,"[[pdbname]]",cnvtlower(
          build(dm_env_import_request->target_database_name)),0)
       ELSE
        deir_temp_line = replace(deir_temp_line,"[[dbname]]",cnvtlower(build(dm_env_import_request->
           target_database_name)),0)
       ENDIF
       deir_temp_line = replace(deir_temp_line,"[[dbcharset]]",build(dm_env_import_request->
         character_set),0), deir_temp_line = replace(deir_temp_line,"[[node_list]]",build(
         dm_env_import_request->remote_node_name),0), deir_temp_line = replace(deir_temp_line,
        "[[sys_pwd]]",build(dm_env_import_request->sys_pwd),0),
       deir_temp_line = replace(deir_temp_line,"[[system_pwd]]",build(dm_env_import_request->
         system_pwd),0), deir_temp_line = replace(deir_temp_line,"[[asm_sysdba_pwd]]",build(
         dm_env_import_request->asm_sysdba_pwd),0), deir_temp_line = replace(deir_temp_line,
        "[[asm_storage_dg]]",build(dm_env_import_request->asm_storage_disk_group),0),
       deir_temp_line = replace(deir_temp_line,"[[asm_recovery_dg]]",build(dm_env_import_request->
         asm_recovery_disk_group),0), deir_temp_line = replace(deir_temp_line,
        "[[log_archive_dest_1]]",build(dm_env_import_request->log_archive_dest_1),0), deir_temp_line
        = replace(deir_temp_line,"[[dbca_template]]",cnvtlower(build("v500db_",dm_env_import_request
          ->target_database_name,"_dbca.dbt")),0),
       deir_temp_line = replace(deir_temp_line,"[[dbca_pdbname_line]]","-pdbName ${PDBNAME} \",0),
       deir_temp_line = replace(deir_temp_line,"[[src_pdbname]]",cnvtlower(build(
          dm_env_import_request->target_database_name)),0), deir_temp_line = replace(deir_temp_line,
        "[[dbca_create_type]]","SHELL",0),
       deir_temp_line = replace(deir_temp_line,"[[disableSecurityConfiguration]]",
        "-disableSecurityConfiguration ALL \",0), deir_temp_line = replace(deir_temp_line,
        "[[emConfiguration]]","-emConfiguration NONE \",0), deir_temp_line = replace(deir_temp_line,
        "[[ignorable_error_codes]]",build(dm_env_import_request->ignorable_error_codes),0),
       deir_temp_line = replace(deir_temp_line,"[[mode]]",build(dm_env_import_request->mode),0),
       deir_temp_line = replace(deir_temp_line,"[[case_sens_logon_val]]",build(dm_env_import_request
         ->source_case_sens_login_val),0), deir_temp_line = replace(deir_temp_line,
        "[[source_db_node_name]]",cnvtupper(build(dm_env_import_request->source_db_node_name)),0)
       IF ((validate(dm2_skip_source_processing,- (1))=- (1))
        AND (validate(dm2_skip_sqlnet_sync_work,- (1))=- (1))
        AND (dm_env_import_request->source_lvl4_oracle_version=dm_env_import_request->
       target_lvl4_oracle_version))
        deir_temp_line = replace(deir_temp_line,"[[source_sync_flag]]","YES",0)
       ELSE
        deir_temp_line = replace(deir_temp_line,"[[source_sync_flag]]","NO",0)
       ENDIF
       deir_temp_line = replace(deir_temp_line,"[[sql92_security]]",build(dm_env_import_request->
         source_sql92_security_val),0)
       IF ((dm_env_import_request->major_tgt_ora_ver_int <= 12))
        deir_temp_line = replace(deir_temp_line,"[[o7_dictionary_accessibility]]",build(
          dm_env_import_request->source_o7_dict_access_val),0)
       ENDIF
       CALL print(deir_temp_line), row + 1
      WITH nocounter, maxrow = 1, maxcol = 2001,
       format = variable, formfeed = none
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_script
     ENDIF
     FREE DEFINE rtl2
     IF ((dm_env_import_request->target_oracle_version="11.2"))
      SET logical file_name value(build("CER_INSTALL:dm2_master_112_single.txt"))
     ELSEIF ((dm_env_import_request->target_oracle_version="12.2"))
      SET logical file_name value(build("CER_INSTALL:dm2_master_122_single.txt"))
     ELSEIF ((dm_env_import_request->target_oracle_version="19"))
      SET logical file_name value(build("CER_INSTALL:dm2_master_19_single.txt"))
     ELSE
      SET logical file_name value(build("CER_INSTALL:dm2_master_111_single.txt"))
     ENDIF
     DEFINE rtl2 "file_name"  WITH nomodify
     SET dm_err->eproc = "Creating customized remote DBCA template"
     CALL disp_msg("",dm_err->logfile,0)
     SET deir_dbca_tgt_file = build("v500db_",cnvtlower(dm_env_import_request->target_database_name),
      "_dbca",".dbt")
     SELECT INTO build("CCLUSERDIR:",deir_dbca_tgt_file)
      FROM rtl2t r
      HEAD REPORT
       db_platform_len = 0, db_platform = "XXX", db_platform_pos = 0
      DETAIL
       deir_temp_line = replace(r.line,"[[Cern_dbca_template_name]]",build("v500db_",cnvtlower(
          dm_env_import_request->target_database_name),"_dbca.dbt"),0), deir_temp_line = replace(
        deir_temp_line,"[[Cern_characterSet]]",build(dm_env_import_request->character_set),0),
       deir_temp_line = replace(deir_temp_line,"[[oracle_base]]",build(dm_env_import_request->
         db_oracle_base),0),
       deir_temp_line = replace(deir_temp_line,"[[asm_storage_dg]]",build(dm_env_import_request->
         asm_storage_disk_group),0), deir_temp_line = replace(deir_temp_line,"[[asm_recovery_dg]]",
        build(dm_env_import_request->asm_recovery_disk_group),0), deir_temp_line = replace(
        deir_temp_line,"[[log_archive_dest_1]]",build(dm_env_import_request->log_archive_dest_1),0),
       deir_temp_line = replace(deir_temp_line,"[[shared_pool_size]]",build(dm_env_import_request->
         shared_pool_size),0)
       IF ((dm_env_import_request->major_tgt_ora_ver_int >= 12))
        deir_temp_line = replace(deir_temp_line,"[[pdb_name]]",build(dm_env_import_request->
          target_database_name),0)
       ENDIF
       IF (deir_temp_line=patstring("*<<CERNERPLAT:*"))
        db_platform_pos = findstring("<<",deir_temp_line), db_platform_len = findstring(">>",
         substring((db_platform_pos+ 14),size(deir_temp_line),deir_temp_line)), db_platform =
        substring(1,db_platform_len,substring(((db_platform_pos+ 14) - 1),size(deir_temp_line),
          deir_temp_line))
        IF ((db_platform=dm_env_import_request->db_node_op_system))
         CALL print(concat("         ",substring((((db_platform_pos+ 16)+ db_platform_len) - 1),size(
            deir_temp_line),deir_temp_line))), row + 1
        ENDIF
       ELSE
        CALL print(deir_temp_line), row + 1
       ENDIF
      WITH nocounter, maxrow = 1, maxcol = 2000,
       format = variable, formfeed = none
     ;end select
     IF (check_error(dm_err->eproc))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_script
     ENDIF
     FREE DEFINE rtl2
     SET logical file_name "CER_INSTALL:dm2_update_sqlnetora.txt"
     DEFINE rtl2 "file_name"  WITH nomodify
     SET dm_err->eproc = concat("Creating ",build("CCLUSERDIR:v500db_",cnvtlower(
        dm_env_import_request->target_database_name),"_updsqlnetora.ksh"))
     CALL disp_msg("",dm_err->logfile,0)
     SELECT INTO build("CCLUSERDIR:v500db_",cnvtlower(dm_env_import_request->target_database_name),
       "_updsqlnetora.ksh")
      FROM rtl2t r
      DETAIL
       CALL print(build(r.line)), row + 1
      WITH nocounter, maxrow = 1, maxcol = 2001,
       format = variable, formfeed = none
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_script
     ENDIF
     FREE DEFINE rtl2
    ELSE
     FREE DEFINE rtl2
     SET logical file_name value(build("CER_INSTALL:dm2_master_",cnvtlower(dm_env_import_request->
        db_node_op_system),"_102_",evaluate(dm_env_import_request->remote_hosts_cnt,1,"single",
        "multiple"),".txt"))
     DEFINE rtl2 "file_name"  WITH nomodify
     SET dm_err->eproc = "Creating customized remote DBCA template"
     CALL disp_msg("",dm_err->logfile,0)
     SET deir_dbca_tgt_file = build("dm2_master_",cnvtlower(dm_env_import_request->db_node_op_system),
      "_102_",cnvtlower(dm_env_import_request->target_database_name),".dbt")
     SELECT INTO build("CCLUSERDIR:",deir_dbca_tgt_file)
      FROM rtl2t r
      DETAIL
       deir_temp_line = replace(r.line,"[[Cern_characterSet]]",build(dm_env_import_request->
         character_set),0),
       CALL print(deir_temp_line), row + 1
      WITH nocounter, maxrow = 1, maxcol = 2000,
       format = variable, formfeed = none
     ;end select
     IF (check_error(dm_err->eproc))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_script
     ENDIF
     FREE DEFINE rtl2
    ENDIF
    IF ((dm_env_import_request->remote_hosts_cnt > 1))
     FREE DEFINE rtl2
     SET logical file_name value(build("CER_INSTALL:",cnvtlower(dm_env_import_request->
        db_node_op_system),"db_sync_db.txt"))
     DEFINE rtl2 "file_name"  WITH nomodify
     SET dm_err->eproc = "Creating customized Linux sync template"
     CALL disp_msg("",dm_err->logfile,0)
     SET deir_sync_tgt_file = build("dm2_master_",cnvtlower(dm_env_import_request->db_node_op_system),
      "_",cnvtlower(dm_env_import_request->target_database_name),"_sync.ksh")
     SELECT INTO build("CCLUSERDIR:",deir_sync_tgt_file)
      FROM rtl2t r
      DETAIL
       deir_temp_line = replace(r.line,"<<dbname>>",cnvtlower(build(dm_env_import_request->
          target_database_name)),0), deir_temp_line = replace(deir_temp_line,"<<oracle_home>>",build(
         dm_env_import_request->db_oracle_home),0), deir_temp_line = replace(deir_temp_line,
        "<<oracle_base>>",build(dm_env_import_request->db_oracle_base),0),
       CALL print(deir_temp_line), row + 1
      WITH nocounter, maxrow = 1, maxcol = 2000,
       format = variable, formfeed = none
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_script
     ENDIF
     FREE DEFINE rtl2
    ENDIF
    IF (deir_manage_tns_formatting(null)=0)
     SET deir_failed = 1
     GO TO exit_script
    ENDIF
    IF ((dm_env_import_request->major_tgt_ora_ver_int >= 11))
     IF (deir_clear_screen_silent_dbca_and_repopulate(null)="Q")
      SET deir_failed = 1
      GO TO exit_script
     ENDIF
    ELSE
     IF (deir_clear_screen_dbca_and_repopulate(null)="Q")
      SET deir_failed = 1
      GO TO exit_script
     ENDIF
    ENDIF
    IF ((dm_err->debug_flag > 0))
     SET message = nowindow
    ENDIF
    IF (deir_clear_screen_dbca_ftp_tns_and_repopulate(null)="Q")
     SET deir_failed = 1
     GO TO exit_script
    ENDIF
    IF ( NOT (dtr_parse_tns(dm2_install_schema->ccluserdir,"")))
     GO TO exit_script
    ENDIF
    IF (dm_env_import_request->dbca_used_ind)
     IF ( NOT (deir_add_tns_entries(null)))
      SET deir_failed = 1
      GO TO exit_script
     ENDIF
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(tnswork)
    ENDIF
    FOR (deir_iter = 1 TO tnswork->cnt)
      IF ((dm_env_import_request->major_tgt_ora_ver_int >= 12))
       IF (((findstring(cnvtupper(build(dm_env_import_request->target_database_name)),cnvtupper(
         tnswork->qual[deir_iter].tns_key),1,0) > 0) OR (findstring(cnvtupper(build(
          dm_env_import_request->target_cdb_name)),cnvtupper(tnswork->qual[deir_iter].tns_key),1,0)
        > 0)) )
        SET tnswork->qual[deir_iter].merge_ind = 1
       ENDIF
      ELSE
       SET deir_temp_string = replace(cnvtupper(tnswork->qual[deir_iter].tns_key),cnvtupper(
         dm_env_import_request->target_database_name),"")
       IF (cnvtint(deir_temp_string) BETWEEN 1 AND dm_env_import_request->remote_hosts_cnt)
        SET tnswork->qual[deir_iter].merge_ind = 1
       ENDIF
      ENDIF
    ENDFOR
    IF (validate(dm2_tgt_db_type_flag,"XXX") IN ("ADMIN", "ADMMIG"))
     FOR (deir_iter = 1 TO tnswork->cnt)
       IF (cnvtupper(tnswork->qual[deir_iter].tns_key)=cnvtupper(build(dm_env_import_request->
         target_database_name,"1")))
        FOR (deir_iter2 = 1 TO tnswork->qual[deir_iter].line_cnt)
          IF (deir_iter2=1)
           SET tnswork->qual[deir_iter].qual[deir_iter2].text = replace(tnswork->qual[deir_iter].
            qual[deir_iter2].text,tnswork->qual[deir_iter].tns_key,cnvtupper(build("remote_",tnswork
              ->qual[deir_iter].tns_key)))
          ELSE
           SET tnswork->qual[deir_iter].qual[deir_iter2].text = tnswork->qual[deir_iter].qual[
           deir_iter2].text
          ENDIF
        ENDFOR
        SET tnswork->qual[deir_iter].tns_key = build("remote_",tnswork->qual[deir_iter].tns_key)
       ENDIF
     ENDFOR
    ENDIF
    IF ( NOT (dtr_merge_to_tnstgt(null)))
     GO TO exit_script
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(tnstgt)
    ENDIF
    IF ( NOT (dtr_reset_tnswork(null)))
     GO TO exit_script
    ENDIF
    IF (validate(dm2_mig_db_ind,- (1))=1)
     IF ((dm_err->debug_flag > 0))
      CALL echo(build("dm2_mig_db_ind =",dm2_mig_db_ind))
     ENDIF
     FOR (deir_iter = 1 TO tnstgt->cnt)
      IF ((dm_env_import_request->major_tgt_ora_ver_int >= 12))
       IF ((dm_err->debug_flag > 0))
        CALL echo(build("tns_key =",cnvtupper(tnstgt->qual[deir_iter].tns_key)))
        CALL echo(build("target_pdb_name =",cnvtupper(dm_env_import_request->target_database_name),
          "1"))
       ENDIF
      ENDIF
      IF (cnvtupper(tnstgt->qual[deir_iter].tns_key)=cnvtupper(build(dm_env_import_request->
        target_database_name,"1")))
       SET tnstgt->cnt = (tnstgt->cnt+ 1)
       SET stat = alterlist(tnstgt->qual,tnstgt->cnt)
       SET tnstgt->qual[tnstgt->cnt].tns_key = build("remote_",tnstgt->qual[deir_iter].tns_key)
       SET tnstgt->qual[tnstgt->cnt].tns_key_full = tnstgt->qual[deir_iter].tns_key_full
       SET tnstgt->qual[tnstgt->cnt].db_domain = tnstgt->qual[deir_iter].db_domain
       SET tnstgt->qual[tnstgt->cnt].tns_key_type_cd = tnstgt->qual[deir_iter].tns_key_type_cd
       SET tnstgt->qual[tnstgt->cnt].mod_ind = tnstgt->qual[deir_iter].mod_ind
       SET tnstgt->qual[tnstgt->cnt].line_cnt = tnstgt->qual[deir_iter].line_cnt
       SET stat = alterlist(tnstgt->qual[tnstgt->cnt].qual,tnstgt->qual[deir_iter].line_cnt)
       FOR (deir_iter2 = 1 TO tnstgt->qual[tnstgt->cnt].line_cnt)
         IF (deir_iter2=1)
          SET tnstgt->qual[tnstgt->cnt].qual[deir_iter2].text = replace(cnvtupper(tnstgt->qual[
            deir_iter].qual[deir_iter2].text),cnvtupper(tnstgt->qual[deir_iter].tns_key),cnvtupper(
            build("remote_",tnstgt->qual[deir_iter].tns_key)))
         ELSE
          SET tnstgt->qual[tnstgt->cnt].qual[deir_iter2].text = tnstgt->qual[deir_iter].qual[
          deir_iter2].text
         ENDIF
       ENDFOR
       SET deir_iter = (tnstgt->cnt+ 1)
      ENDIF
     ENDFOR
     IF ((dm_err->debug_flag > 0))
      CALL echorecord(tnstgt)
     ENDIF
    ENDIF
    IF ( NOT (dtr_parse_tns("","tnsnames.ora")))
     GO TO exit_script
    ENDIF
    IF (validate(dm2_mig_db_ind,- (1))=1)
     FOR (deir_iter = 1 TO tnswork->cnt)
      SET deir_temp_string = replace(cnvtupper(tnswork->qual[deir_iter].tns_key),cnvtupper(
        dm_env_import_request->source_dbase_name),"")
      IF (cnvtint(deir_temp_string) BETWEEN 1 AND dm_env_import_request->source_instance_cnt)
       SET tnswork->qual[deir_iter].merge_ind = 1
      ENDIF
     ENDFOR
    ENDIF
    IF ( NOT (validate(dm2_tgt_db_type_flag,"XXX") IN ("ADMIN", "ADMMIG")))
     FOR (deir_iter = 1 TO tnswork->cnt)
       IF (cnvtupper(tnswork->qual[deir_iter].tns_key)=cnvtupper(dm_env_import_request->
        admin_connect_string))
        SET tnswork->qual[deir_iter].merge_ind = 1
       ENDIF
     ENDFOR
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(tnswork)
    ENDIF
    IF ( NOT (dtr_merge_to_tnstgt(null)))
     GO TO exit_script
    ENDIF
    IF ( NOT (dtr_reset_tnswork(null)))
     GO TO exit_script
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(tnstgt)
    ENDIF
    IF ((dm_env_import_request->remote_hosts_cnt=1))
     SET deir_search = locateval(deir_search,1,tnstgt->cnt,cnvtlower(dm_env_import_request->
       target_database_name),tnstgt->qual[deir_search].tns_key)
     IF ((dm_err->debug_flag > 5))
      CALL echo(build("deir_search = ",deir_search))
     ENDIF
     IF (deir_search > 0)
      SET tnswork->cnt = (tnswork->cnt+ 1)
      SET stat = alterlist(tnswork->qual,tnswork->cnt)
      SET tnswork->qual[tnswork->cnt].tns_key = build(tnstgt->qual[deir_search].tns_key,"1")
      SET tnswork->qual[tnswork->cnt].tns_key_full = tnstgt->qual[deir_search].tns_key_full
      SET tnswork->qual[tnswork->cnt].db_domain = tnstgt->qual[deir_search].db_domain
      SET tnswork->qual[tnswork->cnt].tns_key_type_cd = tnstgt->qual[deir_search].tns_key_type_cd
      SET tnswork->qual[tnswork->cnt].merge_ind = 1
      SET tnswork->qual[tnswork->cnt].line_cnt = tnstgt->qual[deir_search].line_cnt
      SET stat = alterlist(tnswork->qual[tnswork->cnt].qual,tnstgt->qual[deir_search].line_cnt)
      FOR (deir_iter = 1 TO tnstgt->qual[deir_search].line_cnt)
        IF (deir_iter=1)
         SET tnswork->qual[tnswork->cnt].qual[deir_iter].text = replace(cnvtupper(tnstgt->qual[
           deir_search].qual[deir_iter].text),cnvtupper(tnstgt->qual[deir_search].tns_key),cnvtupper(
           build(tnstgt->qual[deir_search].tns_key,"1")))
        ELSE
         SET tnswork->qual[tnswork->cnt].qual[deir_iter].text = tnstgt->qual[deir_search].qual[
         deir_iter].text
        ENDIF
      ENDFOR
     ENDIF
     IF ((dm_err->debug_flag > 0))
      CALL echorecord(tnswork)
      CALL echorecord(tnstgt)
     ENDIF
     IF ( NOT (dtr_merge_to_tnstgt(null)))
      GO TO exit_script
     ENDIF
     IF ((dm_err->debug_flag > 0))
      CALL echorecord(tnstgt)
     ENDIF
    ENDIF
    SET deir_connectivity_ind = 1
    WHILE (deir_connectivity_ind)
      IF (deir_clear_screen_tns_verify_and_repopulate(null)="Q")
       IF ( NOT (dm_err->err_ind))
        SET deir_failed = 1
       ENDIF
       GO TO exit_script
      ENDIF
      IF ((dm_env_import_request->db_node_op_system="LNX")
       AND (dm_env_import_request->target_oracle_version=patstring("10.*")))
       CALL deir_clear_screen_sys_prompt(null)
      ENDIF
      CALL clear(1,1)
      SET message = nowindow
      SET tnstgt->global_status_ind = 1
      FOR (deir_iter = 1 TO tnstgt->cnt)
        IF ((tnstgt->qual[deir_iter].status_ind != 1)
         AND ((validate(dm2_mig_db_ind,- (1))=1
         AND cnvtupper(tnstgt->qual[deir_iter].tns_key)=patstring("REMOTE_*")) OR (((validate(
         dm2_tgt_db_type_flag,"XXX") IN ("ADMIN", "ADMMIG")
         AND cnvtupper(tnstgt->qual[deir_iter].tns_key)=patstring("REMOTE_*")) OR (((validate(
         dm2_mig_db_ind,- (1)) != 1
         AND cnvtupper(tnstgt->qual[deir_iter].tns_key)=patstring(build(cnvtupper(
           dm_env_import_request->target_database_name),"??"))) OR (validate(dm2_mig_db_ind,- (1))
         != 1
         AND cnvtupper(tnstgt->qual[deir_iter].tns_key)=patstring(build(cnvtupper(
           dm_env_import_request->target_cdb_name),"??")))) )) )) )
         IF (cnvtupper(tnstgt->qual[deir_iter].tns_key)=patstring(build(cnvtupper(
            dm_env_import_request->target_cdb_name),"??")))
          SET dm2_install_schema->dbase_name = dm_env_import_request->target_cdb_name
         ELSE
          SET dm2_install_schema->dbase_name = dm_env_import_request->target_database_name
         ENDIF
         SET dm2_install_schema->u_name = "SYS"
         SET dm2_install_schema->p_word = dm_env_import_request->oracle_sys_pwd
         SET dm2_install_schema->connect_str = tnstgt->qual[deir_iter].tns_key
         EXECUTE dm2_connect_to_dbase "CO"
         IF (dm_err->err_ind)
          SET dm_err->err_ind = 0
          SET tnstgt->qual[deir_iter].status_ind = 2
          SET tnstgt->global_status_ind = 2
         ELSE
          SET tnstgt->qual[deir_iter].status_ind = 1
          SET dm_err->eproc = "Querying for instance information from v$instance."
          SELECT INTO "nl:"
           FROM v$instance vi
           DETAIL
            tnstgt->qual[deir_iter].instance_name = vi.instance_name, tnstgt->qual[deir_iter].
            host_name = vi.host_name
           WITH nocounter
          ;end select
          IF (check_error(dm_err->eproc))
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           GO TO exit_script
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
      IF ((dm_err->debug_flag > 0))
       CALL echorecord(tnstgt)
      ENDIF
      IF ((tnstgt->global_status_ind=2))
       SET dm_err->eproc = "Displaying Remote Instance Connectivity Report from tnstgt."
       SELECT INTO "mine"
        FROM (dummyt d  WITH seq = value(tnstgt->cnt))
        WHERE (tnstgt->qual[d.seq].status_ind > 0)
        HEAD REPORT
         col 0, "Remote instance Connectivity Report", row + 1,
         col 0, "Connection", col 21,
         "Status", col 32, "Instance",
         col 43, "Host Name", row + 1,
         col 0,
         CALL print(fillstring(50,"-")), col 21,
         CALL print(fillstring(10,"-")), col 32,
         CALL print(fillstring(10,"-")),
         col 43,
         CALL print(fillstring(10,"-")), row + 1
        DETAIL
         col 0, tnstgt->qual[d.seq].tns_key, col 21,
         CALL print(evaluate(tnstgt->qual[d.seq].status_ind,1,"SUCCESS","FAILURE")), col 32, tnstgt->
         qual[d.seq].instance_name,
         col 43, tnstgt->qual[d.seq].host_name, row + 1
        WITH nocounter, maxrow = 1
       ;end select
       IF (check_error(dm_err->eproc))
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_script
       ENDIF
      ENDIF
      IF ((tnstgt->global_status_ind=1))
       SET deir_connectivity_ind = 0
      ENDIF
    ENDWHILE
   ENDIF
   IF (deir_clear_screen_ora_and_repopulate(null)="N")
    SET deir_failed = 1
    GO TO exit_script
   ENDIF
   CALL clear(1,1)
   SET message = nowindow
   IF ( NOT (dm_env_import_request->dbca_used_ind))
    IF (deir_update_tns(null)=1)
     SET dm_err->eproc = "tnsnames.ora has been successfully updated."
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
   ENDIF
   IF (deir_process_registry_ind
    AND (validate(dm2_skip_registry_processing,- (1))=- (1)))
    IF (deir_clear_screen_reg1_and_repopulate(null)="N")
     SET deir_failed = 1
     GO TO exit_script
    ENDIF
    IF (deir_clear_screen_reg2_and_repopulate(null)="N")
     SET deir_failed = 1
     GO TO exit_script
    ENDIF
    CALL clear(1,1)
    SET message = nowindow
    IF (deir_update_registry(null)=1)
     SET dm_err->eproc = "The registry has been successfully updated."
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
   ENDIF
   IF (dm_env_import_request->dbca_used_ind)
    IF ((dm2_install_schema->dbase_name="ADMIN")
     AND cnvtupper(dm_env_import_request->target_database_name) != "ADMIN")
     SET dm_err->eproc = "Validate TNS entries have been tested."
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "TNS entries were not tested. Still connected to ADMIN database."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_script
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echo(build("dm_env_import_request->target_oracle_version = ",dm_env_import_request->
       target_oracle_version))
    ENDIF
    IF ((dm_env_import_request->major_tgt_ora_ver_int >= 12))
     IF (checkdic("V$PDBS","T",0) != 2)
      EXECUTE oragen3 "SYS.V$PDBS"
      IF (check_error(dm_err->eproc)=1)
       GO TO exit_script
      ENDIF
     ENDIF
     SET dm2_install_schema->dbase_name = dm_env_import_request->target_database_name
     SET dm2_install_schema->u_name = "SYS"
     SET dm2_install_schema->p_word = dm_env_import_request->oracle_sys_pwd
     IF (validate(dm2_mig_db_ind,- (1))=1)
      SET dm2_install_schema->connect_str = concat("remote_",dm_env_import_request->
       target_database_name,"1")
     ELSE
      SET dm2_install_schema->connect_str = concat(dm_env_import_request->target_database_name,"1")
     ENDIF
     EXECUTE dm2_connect_to_dbase "CO"
    ENDIF
    SET dm2_install_schema->curprog = curprog
    IF (currdbname != cnvtupper(dm_env_import_request->target_database_name))
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Not connected to Target Database. Exiting script."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_script
    ENDIF
    IF ((validate(dm2_skip_create_users,- (1))=- (1)))
     IF (deir_create_misc_ts(null)=0)
      GO TO exit_script
     ENDIF
     SET dcdur_user_data->tgt_sys_pwd = dm_env_import_request->oracle_sys_pwd
     EXECUTE dm2_create_users "ALL"
     IF (dm_err->err_ind)
      GO TO exit_script
     ENDIF
    ENDIF
    EXECUTE dm2_setup_new_db
    IF (dm_err->err_ind)
     GO TO exit_script
    ENDIF
   ENDIF
  ENDIF
  IF (dm_env_import_request->response_file_used_ind)
   IF (dm2_findfile(concat(build(logical("ccluserdir")),"/dm2_create_db_shell_resp_old.dat")))
    IF (dm2_push_dcl(concat("rm ",build(logical("ccluserdir")),"/dm2_create_db_shell_resp_old.dat"))=
    0)
     GO TO exit_script
    ENDIF
   ENDIF
   IF (dm2_push_dcl(concat("mv ",build(logical("ccluserdir")),"/dm2_create_db_shell_resp.dat ",build(
      logical("ccluserdir")),"/dm2_create_db_shell_resp_old.dat"))=0)
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 GO TO exit_script
 SUBROUTINE deir_update_tns(null)
  IF ((dm2_sys_misc->cur_os="AXP"))
   SET dm_err->eproc = concat(
    "Executing pipe @ORACLE_HOME:orauser.com ; @cer_install:dm2_update_tns.com ",build(
     dm_env_import_request->target_database_name),"1 ",build(dm_env_import_request->target_tns_host),
    build(dm_env_import_request->target_tns_port),
    build(dm_env_import_request->target_database_name),"1 ","T")
   CALL disp_msg("",dm_err->logfile,0)
   CALL dm2_push_dcl(concat("@ORACLE_HOME:orauser.com ; @cer_install:dm2_update_tns.com ",build(
      dm_env_import_request->target_database_name),"1 ",build(dm_env_import_request->target_tns_host),
     build(dm_env_import_request->target_tns_port),
     build(dm_env_import_request->target_database_name),"1 ","T"))
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat(
    "Executing pipe @ORACLE_HOME:orauser.com ; @cer_install:dm2_update_tns.com remote_",build(
     dm_env_import_request->target_database_name),"1 ",build(dm_env_import_request->target_tns_host),
    build(dm_env_import_request->target_tns_port),
    build(dm_env_import_request->target_database_name),"1 ","T")
   CALL disp_msg("",dm_err->logfile,0)
   CALL dm2_push_dcl(concat("@ORACLE_HOME:orauser.com ; @cer_install:dm2_update_tns.com remote_",
     build(dm_env_import_request->target_database_name),"1 ",build(dm_env_import_request->
      target_tns_host),build(dm_env_import_request->target_tns_port),
     build(dm_env_import_request->target_database_name),"1 ","T"))
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
  ELSE
   SET dm_err->eproc = concat('Executing su - oracle -c "',build(logical("cer_install")),
    "/dm2_updatetns.ksh -a ",build(dm_env_import_request->target_database_name),"1 -n ",
    build(dm_env_import_request->target_tns_host)," -p ",build(dm_env_import_request->target_tns_port
     )," -s ",build(dm_env_import_request->target_database_name),
    "1 ","-h ",build(dm_env_import_request->local_oracle_home_log),' -m T"')
   CALL disp_msg("",dm_err->logfile,0)
   CALL dm2_push_dcl(concat('su - oracle -c "',build(logical("cer_install")),"/dm2_updatetns.ksh -a ",
     build(dm_env_import_request->target_database_name),"1 -n ",
     build(dm_env_import_request->target_tns_host)," -p ",build(dm_env_import_request->
      target_tns_port)," -s ",build(dm_env_import_request->target_database_name),
     "1 ","-h ",build(dm_env_import_request->local_oracle_home_log),' -m T"'))
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat('Executing su - oracle -c "',build(logical("cer_install")),
    "/dm2_updatetns.ksh -a remote_",build(dm_env_import_request->target_database_name),"1 -n ",
    build(dm_env_import_request->target_tns_host)," -p ",build(dm_env_import_request->target_tns_port
     )," -s ",build(dm_env_import_request->target_database_name),
    "1 ","-h ",build(dm_env_import_request->local_oracle_home_log),' -m T"')
   CALL disp_msg("",dm_err->logfile,0)
   CALL dm2_push_dcl(concat('su - oracle -c "',build(logical("cer_install")),
     "/dm2_updatetns.ksh -a remote_",build(dm_env_import_request->target_database_name),"1 -n ",
     build(dm_env_import_request->target_tns_host)," -p ",build(dm_env_import_request->
      target_tns_port)," -s ",build(dm_env_import_request->target_database_name),
     "1 ","-h ",build(dm_env_import_request->local_oracle_home_log),' -m T"'))
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE deir_update_registry(null)
   SET dm_err->eproc = concat("Generating ",cnvtlower(build("updreg_",dm_env_import_request->
      target_environment_name,".ksh")))
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO cnvtlower(build("updreg_",dm_env_import_request->target_environment_name,".ksh"))
    DETAIL
     CALL print("#!/usr/bin/ksh"), row + 1,
     CALL print(concat("lreg -crek \\environment\\",cnvtlower(build(dm_env_import_request->
        target_environment_name)),"\\node\\",cnvtlower(build(dm_env_import_request->local_node_name))
      )),
     row + 1,
     CALL print(concat("lreg -setp \\environment\\",cnvtlower(build(dm_env_import_request->
        target_environment_name)),"\\node\\",cnvtlower(build(dm_env_import_request->local_node_name)),
      " DbInstance ",
      cnvtlower(dm_env_import_request->target_connect_string))), row + 1
     IF ((dm_env_import_request->character_set != "US7ASCII"))
      IF ((dm2_sys_misc->cur_os="AIX"))
       CALL print(concat("lreg -crek \\environment\\",cnvtlower(build(dm_env_import_request->
          target_environment_name)),"\\definitions\\aixrs6000\\environment")), row + 1,
       CALL print(concat("lreg -setp \\environment\\",cnvtlower(build(dm_env_import_request->
          target_environment_name)),
        "\\definitions\\aixrs6000\\environment NLS_LANG AMERICAN_AMERICA.",cnvtupper(build(
          dm_env_import_request->character_set)))),
       row + 1,
       CALL print(concat("lreg -setp \\environment\\",cnvtlower(build(dm_env_import_request->
          target_environment_name)),
        ^\\definitions\\aixrs6000\\environment ORA_NLS10 "'ORACLE_HOME'/nls/data"^)), row + 1
      ELSEIF ((dm2_sys_misc->cur_os="HPX"))
       CALL print(concat("lreg -crek \\environment\\",cnvtlower(build(dm_env_import_request->
          target_environment_name)),"\\definitions\\hpuxia64\\environment")), row + 1,
       CALL print(concat("lreg -setp \\environment\\",cnvtlower(build(dm_env_import_request->
          target_environment_name)),"\\definitions\\hpuxia64\\environment NLS_LANG AMERICAN_AMERICA.",
        cnvtupper(build(dm_env_import_request->character_set)))),
       row + 1,
       CALL print(concat("lreg -setp \\environment\\",cnvtlower(build(dm_env_import_request->
          target_environment_name)),
        ^\\definitions\\hpuxia64\\environment ORA_NLS10 "'ORACLE_HOME'/nls/data"^)), row + 1
      ELSEIF ((dm2_sys_misc->cur_os="LNX"))
       CALL print(concat("lreg -crek \\environment\\",cnvtlower(build(dm_env_import_request->
          target_environment_name)),"\\definitions\\linuxx86-64\\environment")), row + 1,
       CALL print(concat("lreg -setp \\environment\\",cnvtlower(build(dm_env_import_request->
          target_environment_name)),
        "\\definitions\\linuxx86-64\\environment NLS_LANG AMERICAN_AMERICA.",cnvtupper(build(
          dm_env_import_request->character_set)))),
       row + 1,
       CALL print(concat("lreg -setp \\environment\\",cnvtlower(build(dm_env_import_request->
          target_environment_name)),
        ^\\definitions\\linuxx86-64\\environment ORA_NLS10 "'ORACLE_HOME'/nls/data"^)), row + 1
      ENDIF
     ENDIF
     CALL print(concat("lreg -crek \\DbInstance\\",cnvtlower(dm_env_import_request->
       target_connect_string))), row + 1,
     CALL print(concat("lreg -setp \\DbInstance\\",cnvtlower(dm_env_import_request->
       target_connect_string)," database ",cnvtlower(build(dm_env_import_request->
        target_database_name)))),
     row + 1,
     CALL print(concat("lreg -crek \\Database\\",cnvtlower(build(dm_env_import_request->
        target_database_name)),"\\node\\",cnvtlower(build(dm_env_import_request->local_node_name)))),
     row + 1,
     CALL print(concat("lreg -setp \\Database\\",cnvtlower(build(dm_env_import_request->
        target_database_name))," Rdbms ",build(dm_env_import_request->rdbms_registry))), row + 1,
     CALL print(concat("lreg -setp \\Database\\",cnvtlower(build(dm_env_import_request->
        target_database_name))," RootPath ",cnvtlower(build(dm_env_import_request->ora_link_mtpt)),
      "/oracle/admin/",
      cnvtlower(build(dm_env_import_request->target_database_name)))),
     row + 1
     IF ((dm2_install_schema->v500_connect_str != "NONE"))
      CALL print(concat("lreg -setp \\Database\\",cnvtlower(build(dm_env_import_request->
         target_database_name)),"\\node\\",cnvtlower(build(dm_env_import_request->local_node_name)),
       ' "Rdbms Connect Option" @',
       dm2_install_schema->v500_connect_str)), row + 1
     ELSE
      CALL print(concat("lreg -setp \\Database\\",cnvtlower(build(dm_env_import_request->
         target_database_name)),"\\node\\",cnvtlower(build(dm_env_import_request->local_node_name)),
       ' "Rdbms Connect Option" @',
       cnvtlower(dm_env_import_request->target_connect_string))), row + 1
     ENDIF
     CALL print(concat("lreg -setp \\Database\\",cnvtlower(build(dm_env_import_request->
        target_database_name)),"\\node\\",cnvtlower(build(dm_env_import_request->local_node_name)),
      ' "Rdbms User Name" v500')), row + 1
     IF ((dm2_install_schema->v500_p_word != "NONE"))
      CALL print(concat("lreg -setp \\Database\\",cnvtlower(build(dm_env_import_request->
         target_database_name)),"\\node\\",cnvtlower(build(dm_env_import_request->local_node_name)),
       ' "Rdbms Password" ',
       dm2_install_schema->v500_p_word)), row + 1
     ELSE
      CALL print(concat("lreg -setp \\Database\\",cnvtlower(build(dm_env_import_request->
         target_database_name)),"\\node\\",cnvtlower(build(dm_env_import_request->local_node_name)),
       ' "Rdbms Password" v500')), row + 1
     ENDIF
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   SET dm_err->eproc = concat("chmod 777 ",cnvtlower(build("updreg_",dm_env_import_request->
      target_environment_name,".ksh")))
   CALL dm2_push_dcl(concat("chmod 777 ",cnvtlower(build("updreg_",dm_env_import_request->
       target_environment_name,".ksh"))))
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Executing ",build(". $CCLUSERDIR/updreg_",cnvtlower(
      dm_env_import_request->target_environment_name),".ksh"))
   CALL dm2_push_dcl(concat(build(". $CCLUSERDIR/updreg_",cnvtlower(dm_env_import_request->
       target_environment_name),".ksh")))
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE deir_clear_screen_ora_and_repopulate(null)
   DECLARE dcsrar_label_start = i2 WITH private, constant(5)
   SET width = 132
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,24,131)
   CALL text(2,56,"DATABASE SHELL CREATION")
   CALL text(7,dcsrar_label_start,
    "Please confirm the ORACLE_HOME directory location for the LOCAL node:")
   CALL text(9,(dcsrar_label_start+ 2),build(dm_env_import_request->local_oracle_home_log))
   CALL text(11,dcsrar_label_start,concat(
     "This value will be used when updating Cerner Registry entries as well as LOCAL",
     " tnsnames.ora entries for Millennium"))
   CALL text(12,dcsrar_label_start,concat("to successfully access the",evaluate(dm_env_import_request
      ->local_ind,1," "," REMOTE "),"database."))
   CALL text(16,dcsrar_label_start,"Is the above ORACLE_HOME value correct for the LOCAL node (Y/N)?"
    )
   CALL accept(16,70,"A;CU"," "
    WHERE curaccept IN ("Y", "N"))
   RETURN(curaccept)
 END ;Subroutine
 SUBROUTINE deir_clear_screen_reg2_and_repopulate(null)
   DECLARE dcsrar_label_start = i2 WITH private, constant(5)
   SET width = 132
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,24,131)
   CALL text(2,56,"DATABASE SHELL CREATION")
   CALL text(7,dcsrar_label_start,"Additional Cerner Registry Updates:")
   IF ((dm2_sys_misc->cur_os="AXP"))
    CALL text(9,dcsrar_label_start,concat("\environment\",cnvtlower(build(dm_env_import_request->
        target_environment_name)),"\definitions\vmsalpha\environment"))
   ELSEIF ((dm2_sys_misc->cur_os="AIX"))
    CALL text(9,dcsrar_label_start,concat("\environment\",cnvtlower(build(dm_env_import_request->
        target_environment_name)),"\definitions\aixrs6000\environment"))
   ELSEIF ((dm2_sys_misc->cur_os="HPX"))
    CALL text(9,dcsrar_label_start,concat("\environment\",cnvtlower(build(dm_env_import_request->
        target_environment_name)),"\definitions\hpuxia64\environment"))
   ELSEIF ((dm2_sys_misc->cur_os="LNX"))
    CALL text(9,dcsrar_label_start,concat("\environment\",cnvtlower(build(dm_env_import_request->
        target_environment_name)),"\definitions\linuxx86-64\environment"))
   ENDIF
   IF ((dm_env_import_request->character_set != "US7ASCII"))
    CALL text(10,8,concat("NLS_LANG = AMERICAN_AMERICA.",cnvtupper(dm_env_import_request->
       character_set)))
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    CALL text(11,(dcsrar_label_start+ 3),concat("ORA_NLS33 = ",cnvtupper(build(logical("ora_nls33")))
      ))
    CALL text(12,(dcsrar_label_start+ 3),"CER_ORA_CLIENT = LIBCLNTSH")
    CALL text(13,(dcsrar_label_start+ 3),concat("ORACLE_HOME = ",dm_env_import_request->
      local_oracle_home_log))
    CALL text(14,(dcsrar_label_start+ 3),concat("LIBCLNTSH = ",replace(dm_env_import_request->
       local_oracle_home_log,"]",".LIB32]libclntsh.so",2)))
   ELSE
    CALL text(11,(dcsrar_label_start+ 3),concat("ORA_NLS10 = 'ORACLE_HOME'/nls/data"))
   ENDIF
   CALL text(23,dcsrar_label_start,"Please confirm the above registry information.  Continue(Y/N)?")
   CALL accept(23,68,"A;CU"," "
    WHERE curaccept IN ("Y", "N"))
   RETURN(curaccept)
 END ;Subroutine
 SUBROUTINE deir_clear_screen_reg1_and_repopulate(null)
   DECLARE dcsrar_label_start = i2 WITH private, constant(5)
   SET width = 132
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,24,131)
   CALL text(2,56,"DATABASE SHELL CREATION")
   CALL text(7,dcsrar_label_start,"Cerner Registry Updates:")
   CALL text(9,dcsrar_label_start,"\environment")
   CALL text(10,(dcsrar_label_start+ 2),concat("\",cnvtlower(build(dm_env_import_request->
       target_environment_name))))
   CALL text(11,(dcsrar_label_start+ 4),"\node")
   CALL text(12,(dcsrar_label_start+ 6),concat("\",cnvtlower(build(dm_env_import_request->
       local_node_name))))
   CALL text(13,(dcsrar_label_start+ 8),concat("dbinstance = ",cnvtlower(build(dm_env_import_request
       ->target_database_name)),"1"))
   CALL text(15,dcsrar_label_start,"\dbinstance")
   CALL text(16,(dcsrar_label_start+ 2),concat("\",cnvtlower(build(dm_env_import_request->
       target_database_name)),"1"))
   CALL text(17,(dcsrar_label_start+ 4),concat("database = ",cnvtlower(build(dm_env_import_request->
       target_database_name))))
   CALL text(9,(dcsrar_label_start+ 31),"\database")
   CALL text(10,(dcsrar_label_start+ 33),concat("\",cnvtlower(build(dm_env_import_request->
       target_database_name))))
   CALL text(11,(dcsrar_label_start+ 35),concat("rdbms = ",build(dm_env_import_request->
      rdbms_registry)))
   IF ((dm2_sys_misc->cur_os="AXP"))
    CALL text(12,(dcsrar_label_start+ 35),"rootpath = <NOT SET>")
   ELSE
    CALL text(12,(dcsrar_label_start+ 35),concat("rootpath = ",cnvtlower(build(dm_env_import_request
        ->ora_link_mtpt)),"/oracle/admin/",cnvtlower(build(dm_env_import_request->
        target_database_name))))
   ENDIF
   CALL text(13,(dcsrar_label_start+ 35),"\node")
   CALL text(14,(dcsrar_label_start+ 39),concat("\",cnvtlower(build(dm_env_import_request->
       local_node_name))))
   CALL text(15,(dcsrar_label_start+ 41),concat("rdbms connect option = @",cnvtlower(build(
       dm_env_import_request->target_database_name)),"1"))
   CALL text(16,(dcsrar_label_start+ 41),"rdbms user name = v500")
   CALL text(17,(dcsrar_label_start+ 41),"rdbms Password = v500")
   CALL text(23,dcsrar_label_start,"Please confirm the above registry information.  Continue(Y/N)? ")
   CALL accept(23,68,"A;CU"," "
    WHERE curaccept IN ("Y", "N"))
   RETURN(curaccept)
 END ;Subroutine
 SUBROUTINE deir_clear_screen_instruct_and_repopulate(null)
   DECLARE dcsiar_cmd = vc WITH protect, noconstant("")
   IF (deir_use_autoftp)
    SET dm_err->eproc = "Copying shell creation scripts to target execution directory"
    IF (dm_env_import_request->local_ind)
     IF (dm2_find_dir(build(dm_env_import_request->tgt_exec_dir))=0)
      IF (dm_err->err_ind)
       RETURN("Q")
      ELSE
       IF (dm2_push_dcl(concat("mkdir ",build(dm_env_import_request->tgt_exec_dir)))=0)
        RETURN("Q")
       ENDIF
       SET dcsiar_cmd = concat("chmod 777 ",build(dm_env_import_request->tgt_exec_dir))
       IF (dm2_push_dcl(dcsiar_cmd)=0)
        RETURN("Q")
       ENDIF
      ENDIF
     ENDIF
     SET dcsiar_cmd = concat("cp ",build(trim(logical("ccluserdir"))),"/v500db_",cnvtlower(build(
        dm_env_import_request->target_database_name)),"* ",
      build(dm_env_import_request->tgt_exec_dir))
     IF (dm2_push_dcl(dcsiar_cmd)=0)
      RETURN("Q")
     ENDIF
     SET dcsiar_cmd = concat("chmod 777 ",build(dm_env_import_request->tgt_exec_dir),"/v500db_",
      cnvtlower(build(dm_env_import_request->target_database_name)),"*")
     IF (dm2_push_dcl(dcsiar_cmd)=0)
      RETURN("Q")
     ENDIF
    ELSE
     CALL dfr_add_putops_line(" "," "," "," "," ",
      1)
     CALL dfr_add_putops_line(" ",build(trim(logical("ccluserdir")),"/"),concat("v500db_",cnvtlower(
        build(dm_env_import_request->target_database_name)),"_updatetns.ksh"),concat(
       dm_env_import_request->tgt_exec_dir,"/"),concat("v500db_",cnvtlower(build(
         dm_env_import_request->target_database_name)),"_updatetns.ksh"),
      0)
     CALL dfr_add_putops_line(" ",build(trim(logical("ccluserdir")),"/"),concat("v500db_",cnvtlower(
        build(dm_env_import_request->target_database_name)),"_init1.ora"),concat(
       dm_env_import_request->tgt_exec_dir,"/"),concat("v500db_",cnvtlower(build(
         dm_env_import_request->target_database_name)),"_init1.ora"),
      0)
     CALL dfr_add_putops_line(" ",build(trim(logical("ccluserdir")),"/"),concat("v500db_",cnvtlower(
        build(dm_env_import_request->target_database_name)),"_definitions.ksh"),concat(
       dm_env_import_request->tgt_exec_dir,"/"),concat("v500db_",cnvtlower(build(
         dm_env_import_request->target_database_name)),"_definitions.ksh"),
      0)
     CALL dfr_add_putops_line(" ",build(trim(logical("ccluserdir")),"/"),concat("v500db_",cnvtlower(
        build(dm_env_import_request->target_database_name)),"_create_db.sql"),concat(
       dm_env_import_request->tgt_exec_dir,"/"),concat("v500db_",cnvtlower(build(
         dm_env_import_request->target_database_name)),"_create_db.sql"),
      0)
     CALL dfr_add_putops_line(" ",build(trim(logical("ccluserdir")),"/"),concat("v500db_",cnvtlower(
        build(dm_env_import_request->target_database_name)),"_create.ksh"),concat(
       dm_env_import_request->tgt_exec_dir,"/"),concat("v500db_",cnvtlower(build(
         dm_env_import_request->target_database_name)),"_create.ksh"),
      0)
     CALL dfr_add_putops_line(" ",build(trim(logical("ccluserdir")),"/"),concat("v500db_",cnvtlower(
        build(dm_env_import_request->target_database_name)),"_config.ora"),concat(
       dm_env_import_request->tgt_exec_dir,"/"),concat("v500db_",cnvtlower(build(
         dm_env_import_request->target_database_name)),"_config.ora"),
      0)
     CALL dfr_add_putops_line(" ",build(trim(logical("ccluserdir")),"/"),concat("v500db_",cnvtlower(
        build(dm_env_import_request->target_database_name)),"_updsqlnetora.ksh"),concat(
       dm_env_import_request->tgt_exec_dir,"/"),concat("v500db_",cnvtlower(build(
         dm_env_import_request->target_database_name)),"_updsqlnetora.ksh"),
      0)
     IF (dfr_put_file(null)=0)
      RETURN("Q")
     ENDIF
     CALL dfr_add_putops_line(" "," "," "," "," ",
      1)
    ENDIF
   ENDIF
   SET width = 132
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,24,131)
   CALL text(2,56,"DATABASE SHELL CREATION")
   IF (deir_use_autoftp)
    IF (dm_env_import_request->local_ind)
     CALL text(3,deir_label_start,
      "To create the database perform the following steps as the root user:")
     CALL text(5,deir_label_start,
      "1) Edit the following file and replace all tokens (denoted by <<some value>>)")
     CALL text(6,deir_label_start,"   with the appropriate values.")
     CALL text(10,deir_label_start,concat("2) Execute the following ksh script from ",build(
        dm_env_import_request->tgt_exec_dir)," to create the database."))
    ELSE
     CALL text(3,deir_label_start,concat("To create the database on the remote node (",build(
        dm_env_import_request->remote_node_name),") perform the following steps as the root user:"))
     CALL text(5,deir_label_start,concat("1) On the remote node (",build(dm_env_import_request->
        remote_node_name),
       ") edit the following file and replace all tokens (denoted by <<some value>>)"))
     CALL text(6,(deir_label_start+ 3),"with the appropriate values from the remote node.")
     CALL text(10,deir_label_start,concat("2) On the remote node (",build(dm_env_import_request->
        remote_node_name),"), execute the following ksh script from ",build(dm_env_import_request->
        tgt_exec_dir)," to create the database."))
    ENDIF
    CALL text(8,(deir_label_start+ 3),concat(build(dm_env_import_request->tgt_exec_dir),"/v500db_",
      cnvtlower(build(dm_env_import_request->target_database_name)),"_definitions.ksh"))
    CALL text(12,(deir_label_start+ 3),concat(build(dm_env_import_request->tgt_exec_dir),"/v500db_",
      cnvtlower(build(dm_env_import_request->target_database_name)),"_create.ksh"))
   ELSE
    IF (dm_env_import_request->local_ind)
     CALL text(3,deir_label_start,
      "To create the database perform the following steps as the root user:")
     CALL text(5,deir_label_start,"1) Copy the following files in CCLUSERDIR to another <dir>ectory."
      )
     CALL text(10,deir_label_start,"2) Set full permissions for the copied files.")
     CALL text(14,deir_label_start,
      "3) Edit the following file and replace all tokens (denoted by <<some value>>)")
     CALL text(15,deir_label_start,"   with the appropriate values.")
     CALL text(19,deir_label_start,
      "4) Execute the following ksh script from /<dir> to create the database.")
    ELSE
     CALL text(3,deir_label_start,concat("To create the database on the remote node (",build(
        dm_env_import_request->remote_node_name),") perform the following steps as the root user:"))
     CALL text(5,deir_label_start,concat("1) FTP the following files in CCLUSERDIR from this node ",
       "to a <dir>ectory on the remote node (",build(dm_env_import_request->remote_node_name),")."))
     CALL text(6,(deir_label_start+ 3),
      "Note: Make sure to use ascii mode for FTP and that the remote file names are in lowercase.")
     CALL text(10,deir_label_start,concat("2) On the remote node (",build(dm_env_import_request->
        remote_node_name),") set full permissions for the ftp'd files."))
     CALL text(14,deir_label_start,concat("3) On the remote node (",build(dm_env_import_request->
        remote_node_name),
       ") edit the following file and replace all tokens (denoted by <<some value>>)"))
     CALL text(15,(deir_label_start+ 3),"with the appropriate values from the remote node.")
     CALL text(19,deir_label_start,concat("4) On the remote node (",build(dm_env_import_request->
        remote_node_name),"), execute the following ksh script from /<dir> to create the database."))
    ENDIF
    CALL text(8,(deir_label_start+ 3),concat("CCLUSERDIR:v500db_",cnvtlower(build(
        dm_env_import_request->target_database_name)),"*"))
    CALL text(12,(deir_label_start+ 3),concat("chmod 777 /<dir>/v500db_",cnvtlower(build(
        dm_env_import_request->target_database_name)),"*"))
    CALL text(17,(deir_label_start+ 3),concat("/<dir>/v500db_",cnvtlower(build(dm_env_import_request
        ->target_database_name)),"_definitions.ksh"))
    CALL text(21,(deir_label_start+ 3),concat("/<dir>/v500db_",cnvtlower(build(dm_env_import_request
        ->target_database_name)),"_create.ksh"))
   ENDIF
   CALL text(23,deir_label_start,"(Q)uit, (C)ontinue:")
   CALL accept(23,22,"A;CU"," "
    WHERE curaccept IN ("C", "Q"))
   RETURN(curaccept)
 END ;Subroutine
 SUBROUTINE deir_clear_screen_main_and_repopulate(null)
   DECLARE dcsmr_cur_row = i4 WITH protect, noconstant(0)
   DECLARE dcsmr_cur_row2 = i4 WITH protect, noconstant(0)
   SET width = 132
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,24,131)
   CALL text(2,56,"DATABASE SHELL CREATION")
   IF ((dm_env_import_request->response_file_used_ind=1))
    CALL text(3,deir_label_start,concat("*** Please verify that ALL values are accurate. ",
      "If not, please fix the response file and re-run script ***"))
   ELSE
    CALL text(3,deir_label_start,concat(
      "*** Please provide information for all prompts to successfully ",
      "generate the database creation scripts ***"))
   ENDIF
   SET dcsmr_cur_row = 5
   CALL text(dcsmr_cur_row,deir_label_start,"Target Node Operating System:")
   CALL text(dcsmr_cur_row,deir_data_start,dm_env_import_request->db_node_op_system)
   SET dcsmr_cur_row = (dcsmr_cur_row+ 1)
   CALL text(dcsmr_cur_row,deir_label_start,"Target Oracle Version:")
   CALL text(dcsmr_cur_row,deir_data_start,dm_env_import_request->target_oracle_version)
   SET dcsmr_cur_row = (dcsmr_cur_row+ 1)
   CALL text(dcsmr_cur_row,deir_label_start,"Target Node Name:")
   IF (size(dm_env_import_request->remote_node_name) <= 90)
    CALL text(dcsmr_cur_row,deir_data_start,concat(dm_env_import_request->remote_node_name,evaluate(
       dm_env_import_request->local_ind,1," (local)","")))
   ELSE
    CALL text(dcsmr_cur_row,deir_data_start,"<List is too long to display>")
   ENDIF
   SET dcsmr_cur_row = (dcsmr_cur_row+ 1)
   CALL text(dcsmr_cur_row,deir_label_start,"Target Node Oracle Home:")
   CALL text(dcsmr_cur_row,deir_data_start,dm_env_import_request->db_oracle_home)
   SET dcsmr_cur_row = (dcsmr_cur_row+ 1)
   CALL text(dcsmr_cur_row,deir_label_start,"Target Node Oracle Base:")
   CALL text(dcsmr_cur_row,deir_data_start,dm_env_import_request->db_oracle_base)
   SET dcsmr_cur_row = (dcsmr_cur_row+ 1)
   IF ( NOT (validate(dm2_tgt_db_type_flag,"XXX") IN ("ADMIN", "ADMMIG")))
    CALL text(dcsmr_cur_row,deir_label_start,"Target Environment Name:")
    CALL text(dcsmr_cur_row,deir_data_start,dm_env_import_request->target_environment_name)
    SET dcsmr_cur_row = (dcsmr_cur_row+ 1)
    CALL text(dcsmr_cur_row,deir_label_start,"Target Environment Description:")
    CALL text(dcsmr_cur_row,deir_data_start,dm_env_import_request->target_environment_description)
    SET dcsmr_cur_row = (dcsmr_cur_row+ 1)
   ENDIF
   IF ((dm_env_import_request->major_tgt_ora_ver_int >= 12))
    CALL text(dcsmr_cur_row,deir_label_start,"Target Container Database Name:")
    CALL text(dcsmr_cur_row,deir_data_start,dm_env_import_request->target_cdb_name)
   ELSE
    CALL text(dcsmr_cur_row,deir_label_start,"Target Database Name:")
    CALL text(dcsmr_cur_row,deir_data_start,dm_env_import_request->target_database_name)
   ENDIF
   SET dcsmr_cur_row = (dcsmr_cur_row+ 1)
   IF ((dm_env_import_request->major_tgt_ora_ver_int >= 12))
    CALL text(dcsmr_cur_row,deir_label_start,"Target PDB Database Name:")
    CALL text(dcsmr_cur_row,deir_data_start,dm_env_import_request->target_database_name)
    SET dcsmr_cur_row = (dcsmr_cur_row+ 1)
   ENDIF
   CALL text(dcsmr_cur_row,deir_label_start,"Target Storage Type:")
   CALL text(dcsmr_cur_row,deir_data_start,dm_env_import_request->database_storage_type)
   SET dcsmr_cur_row = (dcsmr_cur_row+ 1)
   CALL text(dcsmr_cur_row,deir_label_start,"Target Extent Management:")
   CALL text(dcsmr_cur_row,deir_data_start,dm_env_import_request->database_extent_management)
   SET dcsmr_cur_row = (dcsmr_cur_row+ 1)
   CALL text(dcsmr_cur_row,deir_label_start,"Target Character Set:")
   CALL text(dcsmr_cur_row,deir_data_start,dm_env_import_request->character_set)
   SET dcsmr_cur_row = (dcsmr_cur_row+ 1)
   IF ((dm_env_import_request->database_storage_type="ASM"))
    IF ( NOT ((dm_env_import_request->db_node_op_system="LNX")
     AND (dm_env_import_request->target_oracle_version=patstring("10.*"))))
     CALL text(dcsmr_cur_row,deir_label_start,"ASM Storage Disk Group:")
     CALL text(dcsmr_cur_row,deir_data_start,dm_env_import_request->asm_storage_disk_group)
     SET dcsmr_cur_row = (dcsmr_cur_row+ 1)
     CALL text(dcsmr_cur_row,deir_label_start,"ASM Recovery Disk Group:")
     CALL text(dcsmr_cur_row,deir_data_start,dm_env_import_request->asm_recovery_disk_group)
     SET dcsmr_cur_row = (dcsmr_cur_row+ 1)
     CALL text(dcsmr_cur_row,deir_label_start,"LOG_ARCHIVE_DEST_1:")
     CALL text(dcsmr_cur_row,deir_data_start,dm_env_import_request->log_archive_dest_1)
     SET dcsmr_cur_row = (dcsmr_cur_row+ 1)
     CALL text(dcsmr_cur_row,deir_label_start,"ASM SYSDBA Password:")
     CALL text(dcsmr_cur_row,deir_data_start,dm_env_import_request->asm_sysdba_pwd)
     SET dcsmr_cur_row = (dcsmr_cur_row+ 1)
     CALL text(dcsmr_cur_row,deir_label_start,"Database SYS Password:")
     CALL text(dcsmr_cur_row,deir_data_start,dm_env_import_request->sys_pwd)
     SET dcsmr_cur_row = (dcsmr_cur_row+ 1)
     CALL text(dcsmr_cur_row,deir_label_start,"Database SYSTEM Password:")
     CALL text(dcsmr_cur_row,deir_data_start,dm_env_import_request->system_pwd)
     SET dcsmr_cur_row = (dcsmr_cur_row+ 1)
    ENDIF
   ELSE
    CALL text(dcsmr_cur_row,deir_label_start,"Cerner Mt Pt:")
    CALL text(dcsmr_cur_row,deir_data_start,dm_env_import_request->cerner_mtpt)
    SET dcsmr_cur_row = (dcsmr_cur_row+ 1)
    CALL text(dcsmr_cur_row,deir_label_start,"ORA Soft Mt Pt:")
    CALL text(dcsmr_cur_row,deir_data_start,dm_env_import_request->ora_sft_mtpt)
    SET dcsmr_cur_row = (dcsmr_cur_row+ 1)
    CALL text(dcsmr_cur_row,deir_label_start,"ORA Link Mt Pt:")
    CALL text(dcsmr_cur_row,deir_data_start,dm_env_import_request->ora_link_mtpt)
    SET dcsmr_cur_row = (dcsmr_cur_row+ 1)
   ENDIF
   SET dcsmr_cur_row2 = 5
   IF ((dm_env_import_request->remote_hosts_cnt=1))
    CALL text(dcsmr_cur_row2,deir_label_start2,"Target TNS Host Name:")
    CALL text(dcsmr_cur_row2,deir_data_start2,dm_env_import_request->target_tns_host)
    SET dcsmr_cur_row2 = (dcsmr_cur_row2+ 1)
   ENDIF
   CALL text(dcsmr_cur_row2,deir_label_start2,"Target TNS Port Number:")
   CALL text(dcsmr_cur_row2,deir_data_start2,dm_env_import_request->target_tns_port)
   SET dcsmr_cur_row2 = (dcsmr_cur_row2+ 1)
   CALL text(dcsmr_cur_row2,deir_label_start2,"Admin TNS Port Number:")
   CALL text(dcsmr_cur_row2,deir_data_start2,dm_env_import_request->admin_tns_port)
   SET dcsmr_cur_row2 = (dcsmr_cur_row2+ 1)
   IF (validate(dm2_mig_db_ind,- (1))=1)
    CALL text(dcsmr_cur_row2,deir_label_start2,"Source TNS Port Number:")
    CALL text(dcsmr_cur_row2,deir_data_start2,dm_env_import_request->source_tns_port)
    SET dcsmr_cur_row2 = (dcsmr_cur_row2+ 1)
   ENDIF
   IF ((dm2_sys_misc->cur_os != "AXP"))
    CALL text(dcsmr_cur_row2,deir_label_start2,"Target Execution Dir:")
    CALL text(dcsmr_cur_row2,deir_data_start2,dm_env_import_request->tgt_exec_dir)
    SET dcsmr_cur_row2 = (dcsmr_cur_row2+ 1)
   ENDIF
   IF ((dm_env_import_request->major_tgt_ora_ver_int >= 11))
    CALL text(dcsmr_cur_row2,deir_label_start2,"Target Shared_Pool_Size:")
    CALL text(dcsmr_cur_row2,deir_data_start2,dm_env_import_request->shared_pool_size)
    SET dcsmr_cur_row2 = (dcsmr_cur_row2+ 1)
   ENDIF
   CALL text(23,deir_label_start,"(Q)uit, (S)ave and Quit, (C)ontinue:")
   CALL text(23,(deir_data_start+ 10),deir_msg)
 END ;Subroutine
 SUBROUTINE deir_remote_host_name_list_prompt(null)
   DECLARE drhnlp_remove_location = i4 WITH protect, noconstant(0)
   DECLARE drhnlp_iter = i4 WITH protect, noconstant(0)
   DECLARE drhnlp_ping_error_cont = i2 WITH protect, noconstant(1)
   WHILE (true)
     SET width = 132
     SET message = window
     CALL clear(1,1)
     CALL box(1,1,24,131)
     CALL text(2,56,"DATABASE SHELL CREATION")
     CALL text(3,52,"*** Remote Host Name List ***")
     CALL text(5,10,"Host Name")
     FOR (drhnlp_iter = 1 TO least(15,dm_env_import_request->remote_hosts_cnt))
       CALL text((6+ drhnlp_iter),10,concat(build(drhnlp_iter),".  ",dm_env_import_request->
         remote_hosts[drhnlp_iter].host_name))
     ENDFOR
     IF ((dm_env_import_request->remote_hosts_cnt=0))
      CALL text(23,2,"(A)dd Host Name, (Q)uit without saving: ")
      CALL accept(23,42,"A;CU"," "
       WHERE curaccept IN ("A", "Q"))
     ELSEIF ((dm_env_import_request->remote_hosts_cnt BETWEEN 1 AND 14))
      IF ((dm_env_import_request->target_oracle_version=patstring("11.*")))
       CALL text(21,2,"Only single node databases supported for Oracle 11g")
       CALL text(23,2,"(R)emove Host Name, (C)ontinue, (Q)uit without saving: ")
       CALL accept(23,57,"A;CU"," "
        WHERE curaccept IN ("R", "C", "Q"))
      ELSE
       CALL text(23,2,"(A)dd Host Name, (R)emove Host Name, (C)ontinue, (Q)uit without saving: ")
       CALL accept(23,74,"A;CU"," "
        WHERE curaccept IN ("A", "R", "C", "Q"))
      ENDIF
     ELSE
      CALL text(23,2,"(R)emove Host Name, (C)ontinue, (Q)uit without saving: ")
      CALL accept(23,57,"A;CU"," "
       WHERE curaccept IN ("R", "C", "Q"))
     ENDIF
     CASE (curaccept)
      OF "A":
       CALL text(22,2,"Host Name To Add:")
       CALL accept(22,39,"P(50);C")
       CALL clear(22,2,129)
       IF ( NOT (locateval(deir_search,1,dm_env_import_request->remote_hosts_cnt,curaccept,
        dm_env_import_request->remote_hosts[deir_search].host_name)))
        SET dm_env_import_request->remote_hosts_cnt = (dm_env_import_request->remote_hosts_cnt+ 1)
        SET stat = alterlist(dm_env_import_request->remote_hosts,dm_env_import_request->
         remote_hosts_cnt)
        SET dm_env_import_request->remote_hosts[dm_env_import_request->remote_hosts_cnt].host_name =
        curaccept
       ENDIF
      OF "R":
       CALL text(22,2,"Host Name to Remove, by number:")
       CALL accept(22,34,"99;H",0
        WHERE curaccept BETWEEN 0 AND dm_env_import_request->remote_hosts_cnt)
       CALL clear(22,2,129)
       SET drhnlp_remove_location = curaccept
       IF (drhnlp_remove_location > 0)
        FOR (drhnlp_iter = drhnlp_remove_location TO (dm_env_import_request->remote_hosts_cnt - 1))
          SET dm_env_import_request->remote_hosts[drhnlp_iter].host_name = dm_env_import_request->
          remote_hosts[(drhnlp_iter+ 1)].host_name
        ENDFOR
        SET dm_env_import_request->remote_hosts_cnt = (dm_env_import_request->remote_hosts_cnt - 1)
        SET stat = alterlist(dm_env_import_request->remote_hosts,dm_env_import_request->
         remote_hosts_cnt)
       ENDIF
      OF "C":
       SET dm_env_import_request->remote_node_name = dm_env_import_request->remote_hosts[1].host_name
       FOR (drhnlp_iter = 2 TO dm_env_import_request->remote_hosts_cnt)
         SET dm_env_import_request->remote_node_name = concat(dm_env_import_request->remote_node_name,
          ", ",dm_env_import_request->remote_hosts[drhnlp_iter].host_name)
       ENDFOR
       SET dm_env_import_request->all_pings_successful_ind = 1
       FOR (drhnlp_iter = 1 TO dm_env_import_request->remote_hosts_cnt)
         IF (dm2_ping(dm_env_import_request->remote_hosts[drhnlp_iter].host_name))
          SET dm_env_import_request->remote_hosts[drhnlp_iter].ping_success_ind = 1
         ELSE
          SET dm_err->err_ind = 0
          SET dm_env_import_request->remote_hosts[drhnlp_iter].ping_success_ind = 0
          SET dm_env_import_request->remote_hosts[drhnlp_iter].emsg = dm_err->emsg
          SET dm_env_import_request->all_pings_successful_ind = 0
         ENDIF
       ENDFOR
       IF ( NOT (dm_env_import_request->all_pings_successful_ind))
        SET drhnlp_ping_error_cont = 1
        WHILE (drhnlp_ping_error_cont)
          SET width = 132
          SET message = window
          CALL clear(1,1)
          CALL box(1,1,24,131)
          CALL text(2,56,"DATABASE SHELL CREATION")
          CALL text(3,48,"*** Remote Host Name Ping Error ***")
          CALL text(5,2,
           "One or more hosts were unsuccessfully pinged.  This process cannot continue.")
          CALL text(6,2,"Please confirm that all databases hosts are operational and on the network."
           )
          CALL text(10,2,"(V)iew Report, (M)odify Host Name List, (Q)uit: ")
          CALL accept(10,55,"A;CU","V"
           WHERE curaccept IN ("V", "M", "Q"))
          CASE (curaccept)
           OF "V":
            IF ( NOT (deir_ping_failure_report(null)))
             RETURN(0)
            ENDIF
           OF "M":
            SET drhnlp_ping_error_cont = 0
           OF "Q":
            RETURN(0)
          ENDCASE
        ENDWHILE
       ENDIF
       IF (dm_env_import_request->all_pings_successful_ind)
        RETURN(1)
       ENDIF
      OF "Q":
       RETURN(0)
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE deir_ping_failure_report(null)
   SET dm_err->eproc = "Displaying network connectivity test report to the screen."
   SELECT INTO "mine"
    FROM (dummyt d  WITH seq = value(dm_env_import_request->remote_hosts_cnt))
    HEAD REPORT
     col 0, "Network Connectivity Test Report", row + 1,
     row + 1, row + 1, col 0,
     "A 'ping' command was issued for all database instances hosts to validate they are operational and on the network.",
     row + 1, row + 1,
     col 0, "Host Name", col 51,
     "Status", col 61, "Message",
     row + 1, col 0,
     CALL print(fillstring(50,"-")),
     col 51,
     CALL print(fillstring(9,"-")), col 61,
     CALL print(fillstring(60,"-")), row + 1
    DETAIL
     col 0, dm_env_import_request->remote_hosts[d.seq].host_name, col 51,
     CALL print(evaluate(dm_env_import_request->remote_hosts[d.seq].ping_success_ind,1,"SUCCESS",
      "FAILURE"))
     IF ( NOT (dm_env_import_request->remote_hosts[d.seq].ping_success_ind))
      col 61,
      CALL print(substring(1,60,dm_env_import_request->remote_hosts[d.seq].emsg))
     ENDIF
     row + 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE deir_clear_screen_dbca_and_repopulate(null)
   DECLARE line_nbr = i4 WITH protect, noconstant(0)
   DECLARE dcsdar_prompt = vc WITH protect, noconstant("")
   SET width = 132
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,24,131)
   CALL text(2,56,"DATABASE SHELL CREATION")
   CALL text(3,38,"*** CREATE database shell on remote node(s) using DBCA ***")
   CALL text(5,2,"Please perform the following steps to create the database:")
   IF ((dm_env_import_request->remote_hosts_cnt > 1))
    SET dcsdar_prompt = "1) FTP (ASCII) the following Cerner templates"
   ELSE
    SET dcsdar_prompt = "1) FTP (ASCII) the following Cerner DBCA template"
   ENDIF
   CALL text(7,2,concat(dcsdar_prompt,
     " from CCLUSERDIR to $ORACLE_HOME/assistants/dbca/templates (On Database Node):"))
   CALL text(9,10,deir_dbca_tgt_file)
   SET line_nbr = 9
   IF ((dm_env_import_request->remote_hosts_cnt > 1))
    SET line_nbr = (line_nbr+ 1)
    CALL text(line_nbr,10,deir_sync_tgt_file)
   ENDIF
   SET line_nbr = (line_nbr+ 2)
   CALL text(line_nbr,2,"2) Launch DBCA on the database node and build the database.")
   IF ((dm_env_import_request->remote_hosts_cnt > 1))
    SET line_nbr = (line_nbr+ 2)
    CALL text(line_nbr,2,
     "3) Execute the following to set full permissions for the ftp'd file on the database node:")
    SET line_nbr = (line_nbr+ 2)
    CALL text(line_nbr,10,concat("chmod 777 $ORACLE_HOME/assistants/dbca/templates/",
      deir_sync_tgt_file))
    SET line_nbr = (line_nbr+ 2)
    CALL text(line_nbr,2,"4) Execute the following ksh on the database node as the oracle user:")
    SET line_nbr = (line_nbr+ 2)
    CALL text(line_nbr,10,concat("$ORACLE_HOME/assistants/dbca/templates/",deir_sync_tgt_file))
   ENDIF
   SET line_nbr = (line_nbr+ 2)
   CALL text(line_nbr,2,
    "Enter 'C' to continue after above steps are complete or 'Q' to quit the process: ")
   CALL accept(line_nbr,83,"A;CU"," "
    WHERE curaccept IN ("C", "Q"))
   RETURN(curaccept)
 END ;Subroutine
 SUBROUTINE deir_clear_screen_sys_prompt(null)
   SET width = 132
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,24,131)
   CALL text(2,56,"DATABASE SHELL CREATION")
   CALL text(4,2,"Please provide the password for the SYS user created by DBCA: ")
   CALL accept(4,64,"P(30);c",dm_env_import_request->oracle_sys_pwd)
   SET dm_env_import_request->oracle_sys_pwd = curaccept
 END ;Subroutine
 SUBROUTINE deir_clear_screen_dbca_ftp_tns_and_repopulate(null)
   DECLARE dcsdftar_msg = vc WITH protect, noconstant("")
   SET dm_err->disp_dcl_err_ind = 0
   IF ((dm2_sys_misc->cur_os="AXP"))
    CALL dm2_push_dcl("delete ccluserdir:tnsnames.ora;*")
   ELSE
    CALL dm2_push_dcl("rm $CCLUSERDIR/tnsnames.ora")
   ENDIF
   SET dm_err->err_ind = 0
   IF (deir_use_autoftp)
    IF (dm_env_import_request->local_ind)
     IF (dm2_push_dcl(concat("cp ",build(dm_env_import_request->db_oracle_home,"/network/admin/"),
       "tnsnames.ora ",build(trim(logical("ccluserdir")))))=0)
      RETURN("Q")
     ENDIF
    ELSE
     CALL dfr_add_getops_line(" "," "," "," "," ",
      1)
     CALL dfr_add_getops_line(" ",build(trim(logical("ccluserdir")),"/"),"tnsnames.ora",build(
       dm_env_import_request->db_oracle_home,"/network/admin/"),"tnsnames.ora",
      0)
     IF (dfr_get_file(null)=0)
      RETURN("Q")
     ENDIF
     CALL dfr_add_getops_line(" "," "," "," "," ",
      1)
    ENDIF
    IF ( NOT (dm2_findfile("$CCLUSERDIR/tnsnames.ora")))
     SET dm_err->eproc = "Attempting to copy tnsnames.ora to CCLUSDERDIR"
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "ERROR: tnsnames.ora was not found in CCLUSERDIR."
     RETURN("Q")
    ELSE
     RETURN("C")
    ENDIF
   ELSE
    WHILE (true)
      SET width = 132
      SET message = window
      CALL clear(1,1)
      CALL box(1,1,24,131)
      CALL text(2,56,"DATABASE SHELL CREATION")
      CALL text(3,39,"*** Copy TNSNAMES.ORA from database node to APP Node ***")
      CALL text(5,2,concat("Please copy the tnsnames.ora file from $ORACLE_HOME/network/admin ",
        evaluate(dm_env_import_request->local_ind,0,concat("on ",dm_env_import_request->remote_hosts[
          1].host_name),"")))
      CALL text(6,2,"to the current application node's CCLUSERDIR directory.")
      IF ( NOT (dm_env_import_request->local_ind))
       CALL text(8,2,"***ADVISORY***: Please PUT file to APP node from database node in ASCII Mode.")
      ENDIF
      CALL video(b)
      CALL text(10,2,dcsdftar_msg)
      CALL video(n)
      CALL text(11,2,
       "Enter 'C' to continue after above steps are complete or 'Q' to quit the process: ")
      CALL accept(11,83,"A;CU"," "
       WHERE curaccept IN ("C", "Q"))
      IF (curaccept="Q")
       RETURN("Q")
      ENDIF
      IF ((dm2_sys_misc->cur_os="AXP"))
       IF ( NOT (dm2_findfile("ccluserdir:tnsnames.ora")))
        SET dcsdftar_msg = "ERROR: File was not found."
       ELSE
        RETURN("C")
       ENDIF
      ELSE
       IF ( NOT (dm2_findfile("$CCLUSERDIR/tnsnames.ora")))
        SET dcsdftar_msg = "ERROR: File was not found."
       ELSE
        RETURN("C")
       ENDIF
      ENDIF
    ENDWHILE
   ENDIF
 END ;Subroutine
 SUBROUTINE deir_clear_screen_tns_verify_and_repopulate(null)
  IF ( NOT (deir_display_tns_report(0)))
   RETURN("Q")
  ENDIF
  WHILE (true)
    SET width = 132
    SET message = window
    CALL clear(1,1)
    CALL box(1,1,24,131)
    CALL text(2,56,"DATABASE SHELL CREATION")
    CALL text(3,53,"*** Verify TNS entries ***")
    CALL text(5,2,concat("Please Verify that the TNS entries have been merged to all TARGET",
      " database nodes and SOURCE application nodes."))
    CALL text(7,2,"(V)iew TNS Merge Report")
    CALL text(8,2,"(C)ontinue, TNS entries have been merged.")
    CALL text(9,2,"(Q)uit")
    CALL text(11,2,"Selection (V/C/Q): ")
    CALL accept(11,21,"A;CU"," "
     WHERE curaccept IN ("V", "C", "Q"))
    CASE (curaccept)
     OF "Q":
      RETURN("Q")
     OF "V":
      IF ( NOT (deir_display_tns_report(0)))
       RETURN("Q")
      ENDIF
     OF "C":
      RETURN("C")
    ENDCASE
  ENDWHILE
 END ;Subroutine
 SUBROUTINE deir_clear_screen_tns_format_verify_and_repopulate(null)
   DECLARE dcstfvr_format_ind = i2 WITH protect, noconstant(1)
   IF ( NOT (deir_display_tns_report(dcstfvr_format_ind)))
    RETURN("Q")
   ENDIF
   WHILE (true)
     SET width = 132
     SET message = window
     CALL clear(1,1)
     CALL box(1,1,24,131)
     CALL text(2,56,"DATABASE SHELL CREATION")
     CALL text(3,53,"*** Verify TNS entries ***")
     CALL text(5,2,concat(
       "Please verify the TNS stanzas with formatting corrections have been merged to ",
       dm_env_import_request->remote_node_name,":$ORACLE_HOME/network/admin/tnsnames.ora"))
     CALL text(7,2,"(V)iew TNS Formatting Issues Report")
     CALL text(8,2,"(C)ontinue, TNS stanza corrections have been merged.")
     CALL text(9,2,"(Q)uit")
     CALL text(11,2,"Selection (V/C/Q): ")
     CALL accept(11,21,"A;CU"," "
      WHERE curaccept IN ("V", "C", "Q"))
     CASE (curaccept)
      OF "Q":
       RETURN("Q")
      OF "V":
       IF ( NOT (deir_display_tns_report(dcstfvr_format_ind)))
        RETURN("Q")
       ENDIF
      OF "C":
       RETURN("C")
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE deir_display_tns_report(ddtr_format_ind)
   SET dm_err->eproc = "Writing TNS Merge data to tnsmerge.ora in CCLUSERDIR."
   SELECT INTO "tnsmerge.ora"
    FROM (dummyt d  WITH seq = value(tnstgt->cnt))
    HEAD REPORT
     iter = 0
     IF (ddtr_format_ind=1)
      col 0,
      CALL print(concat(
       "#The following TNS stanzas were found to have formatting (spacing) issues that will cause ",
       "Oracle's DBCA utility to fail when creating the database.")), row + 1,
      col 0,
      CALL print(concat(
       "#The required spaces have been added to the stanzas and are displayed in this report")), row
       + 1,
      col 0,
      CALL print(concat("#Please merge all the corrected stanzas from this report to ",
       dm_env_import_request->remote_node_name,":$ORACLE_HOME/network/admin/tnsnames.ora")), row + 1
     ELSE
      col 0,
      "#The following TNS entries should be merged to all TARGET database nodes and SOURCE application nodes.",
      row + 1
     ENDIF
     col 0, "", row + 1,
     col 0, "", row + 1
    DETAIL
     FOR (iter = 1 TO tnstgt->qual[d.seq].line_cnt)
       col 0, tnstgt->qual[d.seq].qual[iter].text, row + 1
     ENDFOR
     col 0, "", row + 1
    WITH nocounter, maxcol = 32767, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (validate(drrr_responsefile_in_use,0)=0)
    FREE DEFINE rtl3
    DEFINE rtl3 "tnsmerge.ora"
    SET dm_err->eproc = "Reading tnsmerge.ora from file to CCL Displayer."
    SELECT INTO "mine"
     tnsmerge_ora = r.line
     FROM rtl3t r
     WITH nocounter, maxcol = 32767, maxrow = 1
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE deir_clear_screen_silent_dbca_and_repopulate(null)
   DECLARE dmtf_cmd = vc WITH protect, noconstant("")
   IF (deir_use_autoftp)
    SET dm_err->eproc = "Copying shell creation scripts to target execution directory"
    IF (dm_env_import_request->local_ind)
     IF (dm2_find_dir(build(dm_env_import_request->tgt_exec_dir))=0)
      IF (dm_err->err_ind)
       RETURN("Q")
      ELSE
       IF (dm2_push_dcl(concat("mkdir ",build(dm_env_import_request->tgt_exec_dir)))=0)
        RETURN("Q")
       ENDIF
      ENDIF
     ENDIF
     SET dmtf_cmd = concat("cp ",build(trim(logical("ccluserdir"))),"/v500db_",cnvtlower(build(
        dm_env_import_request->target_database_name)),"* ",
      build(dm_env_import_request->tgt_exec_dir))
     IF (dm2_push_dcl(dmtf_cmd)=0)
      RETURN("Q")
     ENDIF
     SET dmtf_cmd = concat("chmod 777 ",build(dm_env_import_request->tgt_exec_dir),"/v500db_",
      cnvtlower(build(dm_env_import_request->target_database_name)),"*")
     IF (dm2_push_dcl(dmtf_cmd)=0)
      RETURN("Q")
     ENDIF
    ELSE
     CALL dfr_add_putops_line(" "," "," "," "," ",
      1)
     CALL dfr_add_putops_line(" ",build(trim(logical("ccluserdir")),"/"),concat("v500db_",cnvtlower(
        build(dm_env_import_request->target_database_name)),"_create.ksh"),concat(
       dm_env_import_request->tgt_exec_dir,"/"),concat("v500db_",cnvtlower(build(
         dm_env_import_request->target_database_name)),"_create.ksh"),
      0)
     CALL dfr_add_putops_line(" ",build(trim(logical("ccluserdir")),"/"),concat("v500db_",cnvtlower(
        build(dm_env_import_request->target_database_name)),"_dbca.dbt"),concat(dm_env_import_request
       ->tgt_exec_dir,"/"),concat("v500db_",cnvtlower(build(dm_env_import_request->
         target_database_name)),"_dbca.dbt"),
      0)
     CALL dfr_add_putops_line(" ",build(trim(logical("ccluserdir")),"/"),concat("v500db_",cnvtlower(
        build(dm_env_import_request->target_database_name)),"_updsqlnetora.ksh"),concat(
       dm_env_import_request->tgt_exec_dir,"/"),concat("v500db_",cnvtlower(build(
         dm_env_import_request->target_database_name)),"_updsqlnetora.ksh"),
      0)
     IF (dfr_put_file(null)=0)
      RETURN("Q")
     ENDIF
     CALL dfr_add_putops_line(" "," "," "," "," ",
      1)
    ENDIF
   ENDIF
   SET width = 132
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,24,131)
   CALL text(2,56,"DATABASE SHELL CREATION")
   CALL text(3,38,"*** CREATE database shell on remote node using DBCA in SILENT mode ***")
   CALL text(5,2,"Please perform the following steps to create the database:")
   IF (deir_use_autoftp)
    IF (dm_env_import_request->local_ind)
     CALL text(7,deir_label_start,concat("1) On the current node",
       ", as the ORACLE user, execute the following ksh script from ",dm_env_import_request->
       tgt_exec_dir," to create the database."))
    ELSE
     CALL text(7,deir_label_start,concat("1) On the remote node (",build(dm_env_import_request->
        remote_node_name),"), as the ORACLE user, execute the following ksh script from ",
       dm_env_import_request->tgt_exec_dir," to create the database."))
    ENDIF
    CALL text(9,(deir_label_start+ 3),concat(dm_env_import_request->tgt_exec_dir,"/v500db_",cnvtlower
      (build(dm_env_import_request->target_database_name)),"_create.ksh"))
   ELSE
    IF (dm_env_import_request->local_ind)
     CALL text(7,deir_label_start,concat(
       "1) Copy the following files in CCLUSERDIR to another <dir>ectory."))
     CALL text(12,deir_label_start,concat("2) Set full permissions for the copied files."))
     CALL text(16,deir_label_start,concat(
       "3) Execute the following ksh script from /<dir> to create the database."))
    ELSE
     CALL text(7,deir_label_start,concat("1) FTP the following files in CCLUSERDIR from this node ",
       "to a <dir>ectory on the remote node (",build(dm_env_import_request->remote_node_name),")."))
     CALL text(8,(deir_label_start+ 3),
      "Note: Make sure to use ascii mode for FTP and that the remote file names are in lowercase.")
     CALL text(12,deir_label_start,concat("2) On the remote node (",build(dm_env_import_request->
        remote_node_name),") set full permissions for the ftp'd files."))
     CALL text(16,deir_label_start,concat("3) On the remote node (",build(dm_env_import_request->
        remote_node_name),
       "), as the ORACLE user, execute the following ksh script from /<dir> to create the database.")
      )
    ENDIF
    CALL text(10,(deir_label_start+ 3),concat("CCLUSERDIR:v500db_",cnvtlower(build(
        dm_env_import_request->target_database_name)),"*"))
    CALL text(14,(deir_label_start+ 3),concat("chmod 777 /<dir>/v500db_",cnvtlower(build(
        dm_env_import_request->target_database_name)),"*"))
    CALL text(18,(deir_label_start+ 3),concat("/<dir>/v500db_",cnvtlower(build(dm_env_import_request
        ->target_database_name)),"_create.ksh"))
   ENDIF
   CALL text(21,deir_label_start,
    "Once the above steps have been successfully completed, select one of the options below.")
   CALL text(23,deir_label_start,"(Q)uit, (C)ontinue:")
   CALL accept(23,22,"A;CU"," "
    WHERE curaccept IN ("C", "Q"))
   RETURN(curaccept)
 END ;Subroutine
 SUBROUTINE deir_manage_tns_formatting(null)
   DECLARE dmtf_format_chg_ind = i2 WITH protect, noconstant(1)
   DECLARE dmtf_iter = i4 WITH protect, noconstant(0)
   DECLARE dmtf_path = vc WITH protect, noconstant("")
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dmtf_path = build(trim(logical("ccluserdir")))
   ELSE
    SET dmtf_path = build(trim(logical("ccluserdir")),"/")
   ENDIF
   WHILE (dmtf_format_chg_ind)
     SET dmtf_format_chg_ind = 0
     IF (deir_clear_screen_dbca_ftp_tns_and_repopulate(null)="Q")
      RETURN(0)
     ENDIF
     IF ( NOT (dtr_parse_tns(dmtf_path,"")))
      RETURN(0)
     ENDIF
     FOR (dmtf_iter = 1 TO tnswork->cnt)
       IF (tnswork->qual[dmtf_iter].chg_format_ind)
        SET tnswork->qual[dmtf_iter].merge_ind = 1
        SET dmtf_format_chg_ind = 1
       ENDIF
     ENDFOR
     IF ( NOT (dtr_merge_to_tnstgt(null)))
      RETURN(0)
     ENDIF
     IF ( NOT (dtr_reset_tnswork(null)))
      RETURN(0)
     ENDIF
     IF (dmtf_format_chg_ind)
      IF (deir_clear_screen_tns_format_verify_and_repopulate(null)="Q")
       RETURN(0)
      ENDIF
     ENDIF
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE deir_add_tns_entries(null)
   DECLARE date_ndx = i4 WITH protect, noconstant(0)
   DECLARE date_str = vc WITH protect, noconstant(cnvtlower(dm_env_import_request->
     target_database_name))
   IF ( NOT (((locateval(date_ndx,1,tnswork->cnt,concat(date_str,"1"),tnswork->qual[date_ndx].tns_key
    )) OR (locateval(date_ndx,1,tnswork->cnt,concat(dm_env_import_request->target_database_name,"1"),
    tnswork->qual[date_ndx].tns_key))) ))
    SET dm_err->eproc = "Adding tns entry for target database"
    CALL disp_msg("",dm_err->logfile,0)
    SET tnswork->cnt = (tnswork->cnt+ 1)
    SET stat = alterlist(tnswork->qual,tnswork->cnt)
    SET tnswork->qual[tnswork->cnt].tns_key_type_cd = 2
    SET tnswork->qual[tnswork->cnt].tns_key_full = concat(dm_env_import_request->target_database_name,
     "1.world")
    SET tnswork->qual[tnswork->cnt].tns_key = concat(dm_env_import_request->target_database_name,"1")
    SET tnswork->qual[tnswork->cnt].db_domain = "world="
    SET tnswork->qual[tnswork->cnt].merge_ind = 1
    SET tnswork->qual[tnswork->cnt].line_cnt = 9
    SET stat = alterlist(tnswork->qual[tnswork->cnt].qual,tnswork->qual[tnswork->cnt].line_cnt)
    SET tnswork->qual[tnswork->cnt].qual[1].text = concat(cnvtupper(dm_env_import_request->
      target_database_name),"1.WORLD = ")
    SET tnswork->qual[tnswork->cnt].qual[2].text = concat("  (DESCRIPTION = ")
    SET tnswork->qual[tnswork->cnt].qual[3].text = concat("    (ADDRESS_LIST = ")
    SET tnswork->qual[tnswork->cnt].qual[4].text = concat("      (ADDRESS = (PROTOCOL = TCP)(Host = ",
     build(dm_env_import_request->target_tns_host),")(Port = ",build(dm_env_import_request->
      target_tns_port),"))")
    SET tnswork->qual[tnswork->cnt].qual[5].text = concat("    )")
    SET tnswork->qual[tnswork->cnt].qual[6].text = concat("    (CONNECT_DATA =")
    IF ((dm_env_import_request->target_oracle_version=patstring("11.*")))
     SET tnswork->qual[tnswork->cnt].qual[7].text = concat("      (SID = ",cnvtlower(
       dm_env_import_request->target_database_name),"1)")
    ELSEIF ((dm_env_import_request->major_tgt_ora_ver_int >= 12))
     SET tnswork->qual[tnswork->cnt].qual[7].text = concat("      (SERVICE_NAME = ",cnvtlower(
       dm_env_import_request->target_database_name),"1)")
    ENDIF
    SET tnswork->qual[tnswork->cnt].qual[8].text = concat("    )")
    SET tnswork->qual[tnswork->cnt].qual[9].text = concat("  )")
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE deir_check_response_file(null)
   SET dm_err->eproc = "Check if valid response file exists."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dm_env_import_request->response_file_used_ind = 0
   CALL dor_init_flex_cmds(null)
   CALL dor_add_flex_cmd(1," "," "," ",concat("test -e ","$CCLUSERDIR",
     "/dm2_create_db_shell_resp.dat ;echo $?"),
    " ","EC")
   IF (dor_exec_flex_cmd(null)=0)
    RETURN(0)
   ENDIF
   IF ((dor_flex_cmd->cmd[1].flex_output IN ("0")))
    SET dm_err->eproc = "Verify response is not older than 1 week."
    CALL dor_init_flex_cmds(null)
    CALL dor_add_flex_cmd(1," "," "," ",concat("find $CCLUSERDIR/dm2_create_db_shell_resp.dat",
      " -mtime -7"),
     " ","EC")
    IF (dor_exec_flex_cmd(null)=0)
     RETURN(0)
    ENDIF
    IF ((dor_flex_cmd->cmd[1].flex_output=concat(build(trim(logical("ccluserdir"))),
     "/dm2_create_db_shell_resp.dat")))
     SET dm_env_import_request->response_file_used_ind = 1
     SET dm_err->eproc = "Response file found. Using response file."
     CALL disp_msg("",dm_err->logfile,0)
    ELSE
     SET dm_env_import_request->response_file_used_ind = 0
     SET dm_err->eproc = concat(
      "A response file (dm2_create_db_shell_resp.dat) was found in CCLUSERDIR that is older than 7 days.",
      " Please refresh the file with current content or remove the file from CCLUSERDIR before re-executing the script"
      )
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE deir_process_response_file(null)
   DECLARE dpr_cnt = i4 WITH protect, noconstant(0)
   DECLARE dpr_file = vc WITH protect, noconstant(concat(build(trim(logical("ccluserdir"))),
     "/dm2_create_db_shell_resp.dat"))
   DECLARE dpr_iter = i4 WITH protect, noconstant(0)
   DECLARE dpr_cont = i2 WITH protect, noconstant(1)
   DECLARE dpr_tmp_host = vc WITH protect, noconstant("")
   DECLARE dpr_host_list = vc WITH protect, noconstant("")
   FREE RECORD dpr_cmd
   RECORD dpr_cmd(
     1 qual[*]
       2 rs_temp = vc
       2 rs_item = vc
       2 rs_item_value = vc
   )
   IF (dm2_findfile(dpr_file)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat(
    "Loading Database Shell Creation response file values into memory from: ",dpr_file)
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
    HEAD REPORT
     eq_pos = 0
    DETAIL
     dpr_cnt = (dpr_cnt+ 1), stat = alterlist(dpr_cmd->qual,dpr_cnt)
     IF (t.line != patstring(";*")
      AND findstring('="',t.line,1,0) > 0)
      eq_pos = findstring('="',t.line,1,0), dpr_cmd->qual[dpr_cnt].rs_item = substring(1,(eq_pos - 1),
       t.line), dpr_cmd->qual[dpr_cnt].rs_temp = substring((eq_pos+ 2),((size(t.line) - eq_pos) - 1),
       t.line),
      dpr_cmd->qual[dpr_cnt].rs_item_value = substring(1,(findstring('"',dpr_cmd->qual[dpr_cnt].
        rs_temp,1,0) - 1),dpr_cmd->qual[dpr_cnt].rs_temp)
     ENDIF
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
     IF ((dpr_cmd->qual[dpr_cnt].rs_item > " "))
      IF ((dpr_cmd->qual[dpr_cnt].rs_item IN ("admin_connect_string", "source_connect_string",
      "target_database_name", "target_environment_name", "target_environment_description",
      "db_node_op_system", "character_set", "database_storage_type", "database_extent_management")))
       CALL parser(concat("set dm_env_import_request->",dpr_cmd->qual[dpr_cnt].rs_item,' = "',
         cnvtupper(build(dpr_cmd->qual[dpr_cnt].rs_item_value)),'" go'),1)
      ELSE
       CALL parser(concat("set dm_env_import_request->",dpr_cmd->qual[dpr_cnt].rs_item,' = "',build(
          dpr_cmd->qual[dpr_cnt].rs_item_value),'" go'),1)
      ENDIF
     ENDIF
   ENDFOR
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (cnvtupper(dm_env_import_request->remote_node_name)=cnvtupper(build(curnode)))
    SET dm_env_import_request->local_ind = 1
   ELSE
    IF (findstring(",",dm_env_import_request->remote_node_name))
     IF ((dm_env_import_request->db_node_op_system="LNX")
      AND (dm_env_import_request->target_oracle_version=patstring("10.*")))
      SET dpr_host_list = dm_env_import_request->remote_node_name
      WHILE (dpr_cont=1)
        IF (findstring(",",dpr_host_list))
         SET dpr_tmp_host = substring(1,(findstring(",",dpr_host_list) - 1),dpr_host_list)
        ELSE
         SET dpr_tmp_host = build(dpr_host_list)
         SET dpr_cont = 0
        ENDIF
        IF ( NOT (locateval(deir_search,1,dm_env_import_request->remote_hosts_cnt,dpr_tmp_host,
         dm_env_import_request->remote_hosts[deir_search].host_name)))
         SET dm_env_import_request->remote_hosts_cnt = (dm_env_import_request->remote_hosts_cnt+ 1)
         SET stat = alterlist(dm_env_import_request->remote_hosts,dm_env_import_request->
          remote_hosts_cnt)
         SET dm_env_import_request->remote_hosts[dm_env_import_request->remote_hosts_cnt].host_name
          = build(dpr_tmp_host)
        ENDIF
        SET dpr_host_list = replace(dpr_host_list,concat(dpr_tmp_host,","),"")
      ENDWHILE
     ELSE
      SET dm_err->err_ind = 1
      SET dm_err->emsg = "Multiple node databases are not allowed for current configuration"
      SET dm_err->user_action =
      "Please provide a single remote node for the database in the response file"
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ELSE
     SET dm_env_import_request->remote_hosts_cnt = 1
     SET stat = alterlist(dm_env_import_request->remote_hosts,dm_env_import_request->remote_hosts_cnt
      )
     SET dm_env_import_request->remote_hosts[dm_env_import_request->remote_hosts_cnt].host_name =
     dm_env_import_request->remote_node_name
    ENDIF
    SET dm_env_import_request->all_pings_successful_ind = 1
    FOR (dpr_iter = 1 TO dm_env_import_request->remote_hosts_cnt)
      IF (dm2_ping(dm_env_import_request->remote_hosts[dpr_iter].host_name))
       SET dm_env_import_request->remote_hosts[dpr_iter].ping_success_ind = 1
      ELSE
       SET dm_env_import_request->all_pings_successful_ind = 0
       SET dm_env_import_request->remote_hosts[dpr_iter].ping_success_ind = 0
       SET dm_err->err_ind = 1
       SET dm_err->emsg = concat("Unable to ping ",dm_env_import_request->remote_hosts[dpr_iter].
        host_name)
       SET dm_err->user_action = "Please correct the database node name(s) in the response file"
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
    ENDFOR
    IF (cnvtupper(dm_env_import_request->remote_node_name) != cnvtupper(dm_env_import_request->
     target_tns_host))
     IF ( NOT (dm2_ping(dm_env_import_request->target_tns_host)))
      SET dm_env_import_request->all_pings_successful_ind = 0
      SET dm_err->err_ind = 1
      SET dm_err->emsg = concat("Unable to ping ",dm_env_import_request->target_tns_host)
      SET dm_err->user_action = "Please correct the tns host name in the response file"
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   SET dm_env_import_request->asm_oracle_home = replace(dm_env_import_request->db_oracle_home,"/db",
    "/asm",2)
   SET dm_env_import_request->oracle_sys_pwd = dm_env_import_request->sys_pwd
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm_env_import_request)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE deir_validate_response_data(null)
   DECLARE dvrd_idx = i4 WITH protect, noconstant(0)
   IF ((dm_env_import_request->database_extent_management="<SOURCE_VALUE>"))
    SET dm_env_import_request->database_extent_management = deir_src_extent_mgmt
   ENDIF
   IF ((dm_env_import_request->database_storage_type="<SOURCE_VALUE>"))
    SET dm_env_import_request->database_storage_type = deir_src_storage_type
   ENDIF
   IF ((dm_env_import_request->database_storage_type != "ASM"))
    SET dm_env_import_request->dbca_used_ind = 0
   ENDIF
   IF ((dm_env_import_request->character_set="<SOURCE_VALUE>"))
    SET dm_env_import_request->character_set = deir_src_characterset
   ENDIF
   IF ((validate(dm2_skip_source_processing,- (1))=- (1)))
    IF (deir_characterset_prompt(deir_src_characterset)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Verify response data specified correctly."
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((((((dm_env_import_request->remote_node_name < " ")) OR ((dm_env_import_request->
   remote_node_name="<REQUIRED_INPUT>"))) ) OR ((((((dm_env_import_request->target_tns_host < " "))
    OR ((dm_env_import_request->target_tns_host="<REQUIRED_INPUT>"))) ) OR ((((((
   dm_env_import_request->target_tns_port < " ")) OR ((dm_env_import_request->target_tns_port=
   "<REQUIRED_INPUT>"))) ) OR ((((((dm_env_import_request->db_node_op_system < " ")) OR ((
   dm_env_import_request->db_node_op_system="<REQUIRED_INPUT>"))) ) OR ((((((dm_env_import_request->
   target_environment_name < " ")) OR ((dm_env_import_request->target_environment_name=
   "<REQUIRED_INPUT>"))) ) OR ((((((dm_env_import_request->target_environment_description < " ")) OR
   ((dm_env_import_request->target_environment_description="<REQUIRED_INPUT>"))) ) OR ((((((
   dm_env_import_request->target_database_name < " ")) OR ((dm_env_import_request->
   target_database_name="<REQUIRED_INPUT>"))) ) OR ((((((dm_env_import_request->target_oracle_version
    < " ")) OR ((dm_env_import_request->target_oracle_version="<REQUIRED_INPUT>"))) ) OR ((((
   dm_env_import_request->database_extent_management < " ")) OR ((((dm_env_import_request->
   database_storage_type < " ")) OR ((((dm_env_import_request->character_set < " ")) OR ((((((
   dm_env_import_request->source_connect_string < " ")) OR ((dm_env_import_request->
   source_connect_string="<REQUIRED_INPUT>"))) ) OR ((((((dm_env_import_request->source_v500_pwd <
   " ")) OR ((dm_env_import_request->source_v500_pwd="<REQUIRED_INPUT>"))) ) OR ((((((
   dm_env_import_request->admin_user_name < " ")) OR ((dm_env_import_request->admin_user_name=
   "<REQUIRED_INPUT>"))) ) OR ((((((dm_env_import_request->admin_pwd < " ")) OR ((
   dm_env_import_request->admin_pwd="<REQUIRED_INPUT>"))) ) OR ((((((dm_env_import_request->
   admin_connect_string < " ")) OR ((dm_env_import_request->admin_connect_string="<REQUIRED_INPUT>")
   )) ) OR ((((((dm_env_import_request->db_oracle_home < " ")) OR ((dm_env_import_request->
   db_oracle_home="<REQUIRED_INPUT>"))) ) OR ((((((dm_env_import_request->db_oracle_base < " ")) OR (
   (dm_env_import_request->db_oracle_base="<REQUIRED_INPUT>"))) ) OR ((((dm_env_import_request->
   tgt_exec_dir < " ")) OR ((dm_env_import_request->tgt_exec_dir="<REQUIRED_INPUT>"))) )) )) )) ))
   )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dm_env_import_request)
    ENDIF
    SET dm_err->err_ind = 1
    SET dm_err->emsg =
    "One or more required fields is not populated in dm2_create_db_shell_resp.dat."
    SET dm_err->user_action =
    "Verify that all fields are populated according to the comments in dm2_create_db_shell_resp.dat"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_env_import_request->ftp_user_name = "oracle"
   SET dm_env_import_request->ftp_pwd = "oracle"
   IF ((dm_env_import_request->database_storage_type="ASM"))
    IF ((((((dm_env_import_request->asm_oracle_home < " ")) OR ((dm_env_import_request->
    asm_oracle_home="<REQUIRED_INPUT>"))) ) OR ((((((dm_env_import_request->asm_sysdba_pwd < " "))
     OR ((dm_env_import_request->asm_sysdba_pwd="<REQUIRED_INPUT>"))) ) OR ((((((
    dm_env_import_request->sys_pwd < " ")) OR ((dm_env_import_request->sys_pwd="<REQUIRED_INPUT>")))
    ) OR ((((((dm_env_import_request->system_pwd < " ")) OR ((dm_env_import_request->system_pwd=
    "<REQUIRED_INPUT>"))) ) OR ((((((dm_env_import_request->asm_storage_disk_group < " ")) OR ((
    dm_env_import_request->asm_storage_disk_group="<REQUIRED_INPUT>"))) ) OR ((((
    dm_env_import_request->asm_recovery_disk_group < " ")) OR ((dm_env_import_request->
    asm_recovery_disk_group="<REQUIRED_INPUT>"))) )) )) )) )) )) )
     IF ((dm_err->debug_flag > 0))
      CALL echorecord(dm_env_import_request)
     ENDIF
     SET dm_err->err_ind = 1
     SET dm_err->emsg =
     "One or more required ASM fields is not populated in dm2_create_db_shell_resp.dat."
     SET dm_err->user_action =
     "Verify that all fields are populated according to the comments in dm2_create_db_shell_resp.dat"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_env_import_request->log_archive_dest_1="DM2_NOT_SET"))
     SET dm_env_import_request->log_archive_dest_1 = build("LOCATION=+",dm_env_import_request->
      asm_recovery_disk_group,"/",cnvtupper(dm_env_import_request->target_database_name))
    ELSEIF (cnvtupper(dm_env_import_request->log_archive_dest_1) != patstring("LOCATION=*"))
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Value for LOG_ARCHIVE_DEST_1 must begin with 'LOCATION='."
     SET dm_err->user_action = "Please specify a different value for log_archive_dest_1"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (((findstring('"',dm_env_import_request->log_archive_dest_1,1,0) > 0) OR (findstring("'",
     dm_env_import_request->log_archive_dest_1,1,0) > 0)) )
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Value for LOG_ARCHIVE_DEST_1 cannot contain single or double quotes"
     SET dm_err->user_action = "Please remove quotes from log_archive_dest_1 value"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_env_import_request->db_node_op_system="LNX")
    AND (dm_env_import_request->database_storage_type != "ASM"))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "ASM is the only storage type supported for Linux"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_env_import_request->database_storage_type="ASM"))
    IF ((dm_env_import_request->database_extent_management="DICTIONARY"))
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "DMT is not supported for ASM storage type"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_env_import_request->db_node_op_system != "LNX")
     AND (dm_env_import_request->target_oracle_version=patstring("10.*")))
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "ASM is not supported for Oracle 10g on AIX/HPX"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_env_import_request->target_environment_name=deir_source_env_name))
    SET dm_err->err_ind = 1
    SET dm_err->emsg =
    "Target Environment Name specified in dm2_create_db_shell_resp.dat is same as SOURCE Environment."
    SET dm_err->user_action = "Please specify a different Target Environment Name"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ( NOT ((dm_env_import_request->db_node_op_system IN ("AIX", "HPX", "LNX"))))
    SET dm_err->err_ind = 1
    SET dm_err->emsg =
    "Database Node Operating System specified incorrectly in dm2_create_db_shell_resp.dat."
    SET dm_err->user_action = "Please specify one of the following values: AIX/HPX/LNX"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ( NOT ((dm_env_import_request->target_oracle_version IN ("10.1", "10.2", "11.1", "11.2", "12.2",
   "19"))))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Target Oracle Version specified incorrectly in dm2_create_db_shell_resp.dat."
    SET dm_err->user_action =
    "Please specify one of the following values: 10.1/10.2/11.1/11.2/12.2/19"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ( NOT ((dm_env_import_request->database_extent_management IN ("LOCAL", "DICTIONARY"))))
    SET dm_err->err_ind = 1
    SET dm_err->emsg =
    "Database Extent Management specified incorrectly in dm2_create_db_shell_resp.dat."
    SET dm_err->user_action = "Please specify one of the following values: LOCAL/DICTIONARY"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ( NOT ((dm_env_import_request->database_storage_type IN ("RAW", "ASM"))))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Database Storage Type specified incorrectly in dm2_create_db_shell_resp.dat."
    SET dm_err->user_action = "Please specify one of the following values: RAW/ASM"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (locateval(dvrd_idx,1,deir_char_set->cnt,dm_env_import_request->character_set,deir_char_set->
    qual[dvrd_idx].char_set_value)=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg =
    "Database Character Set specified incorrectly in dm2_create_db_shell_resp.dat."
    SET dm_err->user_action = concat("Please specify one of the following values: ",deir_char_set->
     char_set_str,".")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE deir_main_screen_prompt(dmsp_selection)
   DECLARE dmsp_help_str = vc WITH protect, noconstant("")
   DECLARE dmsp_cur_row = i4 WITH protect, noconstant(0)
   DECLARE dmsp_cur_row2 = i4 WITH protect, noconstant(0)
   DECLARE dmsp_idx = i4 WITH protect, noconstant(0)
   SET dm_env_import_request->ftp_user_name = "oracle"
   SET dm_env_import_request->ftp_pwd = "oracle"
   SET dm_env_import_request->tgt_exec_dir = "/tmp"
   SET width = 132
   SET message = window
   SET dmsp_cur_row = 5
   SET deir_msg = "Help is available via <Shift><F5>"
   CALL deir_clear_screen_main_and_repopulate(null)
   SET deir_msg = ""
   SET help = fix("AIX,HPX,LNX")
   CALL accept(dmsp_cur_row,deir_data_start,"A(3);CU",dm_env_import_request->db_node_op_system
    WHERE build(curaccept) IN ("HPX", "AIX", "LNX"))
   SET help = off
   SET dm_env_import_request->db_node_op_system = build(curaccept)
   SET dmsp_cur_row = (dmsp_cur_row+ 1)
   SET deir_msg = "Help is available via <Shift><F5>"
   CALL deir_clear_screen_main_and_repopulate(null)
   SET deir_msg = ""
   IF ((dm_env_import_request->db_node_op_system="HPX"))
    SET help = fix("10.1,11.1,11.2,12.2")
    CALL accept(dmsp_cur_row,deir_data_start,"P(4);CFU",dm_env_import_request->target_oracle_version
     WHERE build(curaccept) IN ("10.1", "11.1", "11.2", "12.2"))
    SET help = off
   ELSEIF ((dm_env_import_request->db_node_op_system="LNX"))
    SET help = fix("10.2,11.1,11.2,12.2,19")
    CALL accept(dmsp_cur_row,deir_data_start,"P(4);CFU",dm_env_import_request->target_oracle_version
     WHERE build(curaccept) IN ("10.2", "11.1", "11.2", "12.2", "19"))
    SET help = off
   ELSE
    SET help = fix("10.1,10.2,11.1,11.2,12.2,19")
    CALL accept(dmsp_cur_row,deir_data_start,"P(4);CFU",dm_env_import_request->target_oracle_version
     WHERE build(curaccept) IN ("10.1", "10.2", "11.1", "11.2", "12.2",
     "19"))
    SET help = off
   ENDIF
   SET dm_env_import_request->target_oracle_version = build(curaccept)
   IF (findstring(".",dm_env_import_request->target_oracle_version) > 0)
    SET dm_env_import_request->major_tgt_ora_ver_int = cnvtint(substring(1,(findstring(".",
       dm_env_import_request->target_oracle_version) - 1),dm_env_import_request->
      target_oracle_version))
   ELSE
    SET dm_env_import_request->major_tgt_ora_ver_int = cnvtint(dm_env_import_request->
     target_oracle_version)
   ENDIF
   SET dmsp_cur_row = (dmsp_cur_row+ 1)
   IF ((dm_env_import_request->target_oracle_version="10.1"))
    SET dm_env_import_request->db_oracle_home = "/u01/oracle/product/10.1.0.5/db"
    SET dm_env_import_request->db_oracle_base = "/u02/oracle"
   ELSEIF ((dm_env_import_request->target_oracle_version="10.2"))
    SET dm_env_import_request->db_oracle_home = "/u01/oracle/product/10.2.0.3/db"
    SET dm_env_import_request->db_oracle_base = "/u02/oracle"
   ELSEIF ((dm_env_import_request->target_oracle_version="11.1"))
    SET dm_env_import_request->db_oracle_home = "/u01/oracle/product/11.1.0.7/db"
    SET dm_env_import_request->db_oracle_base = "/u02"
    SET dm_env_import_request->shared_pool_size = cnvtstring(deir_shared_pool_size_1,15)
   ELSEIF ((dm_env_import_request->target_oracle_version="11.2"))
    SET dm_env_import_request->db_oracle_home = "/u01/oracle/product/11.2.0.3/db"
    SET dm_env_import_request->db_oracle_base = "/u02"
    SET dm_env_import_request->shared_pool_size = cnvtstring(deir_shared_pool_size_2,15)
   ELSEIF ((dm_env_import_request->target_oracle_version="12.2"))
    SET dm_env_import_request->db_oracle_home = "/u01/oracle/product/12.2.0.1/db"
    SET dm_env_import_request->db_oracle_base = "/u02"
    SET dm_env_import_request->shared_pool_size = cnvtstring(deir_shared_pool_size_2,15)
   ELSEIF ((dm_env_import_request->target_oracle_version="19"))
    SET dm_env_import_request->db_oracle_home = "/u01/oracle/product/19/db"
    SET dm_env_import_request->db_oracle_base = "/u01/oracle/product"
    SET dm_env_import_request->shared_pool_size = cnvtstring(deir_shared_pool_size_2,15)
   ENDIF
   IF ( NOT ((dm_env_import_request->db_node_op_system="LNX")))
    WHILE (deir_cont=1)
      CALL deir_clear_screen_main_and_repopulate(null)
      CALL accept(dmsp_cur_row,deir_data_start,"P(30);C",dm_env_import_request->remote_node_name
       WHERE build(curaccept) > "")
      SET dm_env_import_request->remote_node_name = build(curaccept)
      IF (dm2_ping(dm_env_import_request->remote_node_name))
       SET deir_cont = 0
      ELSE
       SET dm_err->err_ind = 0
       SET width = 132
       SET message = window
       CALL clear(1,1)
       CALL box(1,1,24,131)
       CALL text(2,56,"DATABASE SHELL CREATION")
       CALL text(3,48,"*** Remote Node Ping Error ***")
       CALL text(5,2,"Remote Node was unsuccessfully pinged.  This process cannot continue.")
       CALL text(6,2,"Please confirm that remote database node is operational and on the network.")
       CALL text(8,2,concat("Error Message: ",dm_err->emsg))
       CALL text(10,2,"(M)odify, (Q)uit: ")
       CALL accept(10,21,"A;CU","M"
        WHERE curaccept IN ("M", "Q"))
       CASE (curaccept)
        OF "M":
         SET deir_cont = 1
        OF "Q":
         RETURN(0)
       ENDCASE
      ENDIF
    ENDWHILE
    SET dm_env_import_request->remote_hosts_cnt = 1
    SET stat = alterlist(dm_env_import_request->remote_hosts,dm_env_import_request->remote_hosts_cnt)
    SET dm_env_import_request->remote_hosts[dm_env_import_request->remote_hosts_cnt].host_name =
    dm_env_import_request->remote_node_name
    SET deir_cont = 1
   ELSE
    IF ( NOT (deir_remote_host_name_list_prompt(null)))
     RETURN(0)
    ENDIF
    CALL deir_clear_screen_main_and_repopulate(null)
   ENDIF
   IF (cnvtupper(dm_env_import_request->remote_node_name)=cnvtupper(build(curnode)))
    SET dm_env_import_request->local_ind = 1
   ENDIF
   SET dmsp_cur_row = (dmsp_cur_row+ 1)
   SET deir_msg = "Help is available via <Shift><F5>"
   CALL deir_clear_screen_main_and_repopulate(null)
   IF ((dm_env_import_request->target_oracle_version="11.1"))
    SET dmsp_help_str = substring(1,40,"/u01/oracle/product/11.1.0.7/db")
   ELSEIF ((dm_env_import_request->target_oracle_version="11.2"))
    SET dmsp_help_str = substring(1,40,"/u01/oracle/product/11.2.0.3/db")
   ELSEIF ((dm_env_import_request->target_oracle_version="12.2"))
    SET dmsp_help_str = substring(1,40,"/u01/oracle/product/12.2.0.1/db")
   ELSEIF ((dm_env_import_request->target_oracle_version="19"))
    SET dmsp_help_str = substring(1,40,"/u01/oracle/product/19/db")
   ELSE
    SET dmsp_help_str = concat(substring(1,40,"/u01/oracle/product/10.1.0.5/db"),",",substring(1,40,
      "/u01/oracle/product/10.2.0.3/db"))
   ENDIF
   SET help = fix(value(dmsp_help_str))
   CALL accept(dmsp_cur_row,deir_data_start,"P(40);C",dm_env_import_request->db_oracle_home
    WHERE build(curaccept) > ""
     AND substring(1,1,curaccept)="/"
     AND findstring("/",trim(curaccept),1,1) != size(trim(curaccept)))
   SET help = off
   SET dm_env_import_request->db_oracle_home = check(curaccept)
   SET dmsp_cur_row = (dmsp_cur_row+ 1)
   CALL deir_clear_screen_main_and_repopulate(null)
   IF ((dm_env_import_request->target_oracle_version=patstring("11.*")))
    SET help = fix("/u02")
   ELSE
    SET help = fix("/u02/oracle")
   ENDIF
   CALL accept(dmsp_cur_row,deir_data_start,"P(30);C",dm_env_import_request->db_oracle_base
    WHERE build(curaccept) > ""
     AND substring(1,1,curaccept)="/"
     AND findstring("/",trim(curaccept),1,1) != size(trim(curaccept)))
   SET help = off
   SET dm_env_import_request->db_oracle_base = check(curaccept)
   SET deir_msg = ""
   SET dmsp_cur_row = (dmsp_cur_row+ 1)
   IF ( NOT (validate(dm2_tgt_db_type_flag,"XXX") IN ("ADMIN", "ADMMIG")))
    SET deir_msg = "Help is available via <Shift><F5>"
    WHILE (deir_env_selection_cont)
      CALL deir_clear_screen_main_and_repopulate(null)
      SET help =
      SELECT
       de.environment_name, de.database_name
       FROM dm_environment de
       WHERE (de.target_operating_system=dm_env_import_request->db_node_op_system)
        AND de.environment_name != deir_source_env_name
       ORDER BY de.environment_name
       WITH nocounter
      ;end select
      CALL accept(dmsp_cur_row,deir_data_start,"P(20);CU",dm_env_import_request->
       target_environment_name
       WHERE build(curaccept) > "")
      SET help = off
      IF (build(curaccept)=deir_source_env_name
       AND deir_process_registry_ind=0)
       SET deir_msg = "The selected environment name cannot be used.  Please choose another."
      ELSE
       SET dm_env_import_request->target_environment_name = build(curaccept)
       SET deir_env_selection_cont = 0
      ENDIF
    ENDWHILE
    SET deir_msg = ""
    SET dmsp_cur_row = (dmsp_cur_row+ 1)
    SET dm_err->eproc = "Selecting target environment description from dm_environment."
    SELECT INTO "nl:"
     FROM dm_environment de
     WHERE (cnvtupper(de.environment_name)=dm_env_import_request->target_environment_name)
     DETAIL
      dm_env_import_request->target_environment_id = de.environment_id, dm_env_import_request->
      target_environment_description = trim(de.description), dm_env_import_request->
      target_database_name = cnvtupper(de.database_name),
      dm_env_import_request->target_environment_exists = 1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    CALL deir_clear_screen_main_and_repopulate(null)
    CALL accept(dmsp_cur_row,deir_data_start,"P(20);CU",dm_env_import_request->
     target_environment_description
     WHERE build(curaccept) > "")
    SET dm_env_import_request->target_environment_description = build(curaccept)
    SET dmsp_cur_row = (dmsp_cur_row+ 1)
   ENDIF
   IF ((dm_env_import_request->major_tgt_ora_ver_int >= 12))
    CALL deir_clear_screen_main_and_repopulate(null)
    CALL accept(dmsp_cur_row,deir_data_start,"P(7);CU",dm_env_import_request->target_cdb_name
     WHERE build(curaccept) > "")
    SET dm_env_import_request->target_cdb_name = build(curaccept)
    SET dmsp_cur_row = (dmsp_cur_row+ 1)
    CALL deir_clear_screen_main_and_repopulate(null)
    CALL accept(dmsp_cur_row,deir_data_start,"P(6);CU",dm_env_import_request->target_database_name
     WHERE build(curaccept) > "")
    SET dm_env_import_request->target_database_name = build(curaccept)
    SET dmsp_cur_row = (dmsp_cur_row+ 1)
   ELSE
    CALL deir_clear_screen_main_and_repopulate(null)
    CALL accept(dmsp_cur_row,deir_data_start,"P(5);CU",dm_env_import_request->target_database_name
     WHERE build(curaccept) > "")
    SET dm_env_import_request->target_database_name = build(curaccept)
    SET dmsp_cur_row = (dmsp_cur_row+ 1)
   ENDIF
   SET dm_env_import_request->asm_storage_disk_group = build(cnvtupper(dm_env_import_request->
     target_database_name),"_DG1")
   SET dm_env_import_request->asm_recovery_disk_group = build(cnvtupper(dm_env_import_request->
     target_database_name),"_DG_FLASH")
   SET dm_env_import_request->log_archive_dest_1 = build("LOCATION=+",dm_env_import_request->
    asm_recovery_disk_group,"/",cnvtupper(dm_env_import_request->target_database_name))
   SET deir_msg = "Help is available via <Shift><F5>"
   IF ((dm_env_import_request->db_node_op_system="LNX"))
    SET deir_src_storage_type = "ASM"
    SET dmsp_help_str = substring(1,12,"ASM")
   ELSE
    SET dmsp_help_str = concat(substring(1,12,"RAW"),",",substring(1,12,"ASM"))
   ENDIF
   SET help = fix(value(dmsp_help_str))
   WHILE (deir_cont=1)
     CALL deir_clear_screen_main_and_repopulate(null)
     CALL accept(dmsp_cur_row,deir_data_start,"P(12);CU",deir_src_storage_type
      WHERE curaccept IN ("RAW", "ASM"))
     SET dm_env_import_request->database_storage_type = build(curaccept)
     IF ((dm_env_import_request->db_node_op_system="LNX")
      AND (dm_env_import_request->database_storage_type != "ASM"))
      SET deir_cont = 1
      SET deir_msg = "ASM is the only storage type supported on Linux."
     ELSEIF ((dm_env_import_request->database_storage_type="ASM")
      AND (dm_env_import_request->db_node_op_system != "LNX")
      AND (dm_env_import_request->target_oracle_version=patstring("10.*")))
      SET deir_cont = 1
      SET deir_msg = "ASM is not supported for Oracle 10g on AIX/HPX"
     ELSE
      SET deir_cont = 0
     ENDIF
   ENDWHILE
   SET deir_cont = 1
   SET help = off
   SET deir_msg = ""
   SET dmsp_cur_row = (dmsp_cur_row+ 1)
   IF ((validate(dm2_mig_db_ind,- (1))=- (1)))
    SET deir_msg = "Help is available via <Shift><F5>"
    IF ((dm_env_import_request->db_node_op_system="LNX"))
     SET dmsp_help_str = substring(1,12,"LOCAL")
    ELSE
     SET dmsp_help_str = concat(substring(1,12,"LOCAL"),",",substring(1,12,"DICTIONARY"))
    ENDIF
    SET help = fix(value(dmsp_help_str))
    WHILE (deir_cont=1)
      CALL deir_clear_screen_main_and_repopulate(null)
      CALL accept(dmsp_cur_row,deir_data_start,"P(12);CU",deir_src_extent_mgmt
       WHERE curaccept IN ("LOCAL", "DICTIONARY"))
      SET dm_env_import_request->database_extent_management = build(curaccept)
      IF ((dm_env_import_request->database_storage_type="ASM")
       AND (dm_env_import_request->database_extent_management="DICTIONARY"))
       SET deir_cont = 1
       SET deir_msg = "DMT is not supported for ASM storage type"
      ELSE
       SET deir_cont = 0
      ENDIF
    ENDWHILE
    SET deir_cont = 1
    SET help = off
    SET deir_msg = ""
    SET dmsp_cur_row = (dmsp_cur_row+ 1)
    SET deir_msg = "Help is available via <Shift><F5>"
    CALL deir_clear_screen_main_and_repopulate(null)
    SET help = fix(value(deir_char_set->char_set_str))
    CALL accept(dmsp_cur_row,deir_data_start,"P(12);CU",deir_src_characterset
     WHERE locateval(dmsp_idx,1,deir_char_set->cnt,curaccept,deir_char_set->qual[dmsp_idx].
      char_set_value) > 0)
    SET dm_env_import_request->character_set = build(curaccept)
    IF ((validate(dm2_skip_source_processing,- (1))=- (1)))
     IF (deir_characterset_prompt(deir_src_characterset)=0)
      RETURN(0)
     ENDIF
    ENDIF
    SET help = off
    SET deir_msg = ""
    SET dmsp_cur_row = (dmsp_cur_row+ 1)
   ELSE
    SET dmsp_cur_row = (dmsp_cur_row+ 2)
   ENDIF
   IF ((dm_env_import_request->database_storage_type="ASM"))
    SET dm_env_import_request->asm_oracle_home = replace(dm_env_import_request->db_oracle_home,"/db",
     "/asm",2)
    IF ( NOT ((dm_env_import_request->db_node_op_system="LNX")
     AND (dm_env_import_request->target_oracle_version=patstring("10.*"))))
     CALL deir_clear_screen_main_and_repopulate(null)
     CALL accept(dmsp_cur_row,deir_data_start,"P(30);CU",dm_env_import_request->
      asm_storage_disk_group
      WHERE  NOT (curaccept=""))
     SET dm_env_import_request->asm_storage_disk_group = build(curaccept)
     SET dmsp_cur_row = (dmsp_cur_row+ 1)
     CALL deir_clear_screen_main_and_repopulate(null)
     CALL accept(dmsp_cur_row,deir_data_start,"P(30);CU",dm_env_import_request->
      asm_recovery_disk_group
      WHERE  NOT (curaccept=""))
     SET dm_env_import_request->asm_recovery_disk_group = build(curaccept)
     SET dmsp_cur_row = (dmsp_cur_row+ 1)
     CALL deir_clear_screen_main_and_repopulate(null)
     WHILE (deir_cont=1)
      CALL accept(dmsp_cur_row,deir_data_start,"P(80);C",build("LOCATION=+",dm_env_import_request->
        asm_recovery_disk_group,"/",cnvtupper(dm_env_import_request->target_database_name))
       WHERE  NOT (curaccept=""))
      IF (curaccept=patstring("LOCATION=*"))
       CALL clear(22,50,75)
       IF (((findstring('"',curaccept,1,0) > 0) OR (findstring("'",curaccept,1,0) > 0)) )
        CALL clear(22,50,75)
        CALL text(22,50,"***Value for LOG_ARCHIVE_DEST_1 cannot contain single or double quotes***")
       ELSE
        SET dm_env_import_request->log_archive_dest_1 = build(curaccept)
        SET deir_cont = 0
       ENDIF
      ELSE
       CALL clear(22,50,75)
       CALL text(22,50,"***Value for LOG_ARCHIVE_DEST_1 must begin with 'LOCATION='***")
      ENDIF
     ENDWHILE
     SET deir_cont = 1
     SET dmsp_cur_row = (dmsp_cur_row+ 1)
     CALL deir_clear_screen_main_and_repopulate(null)
     CALL accept(dmsp_cur_row,deir_data_start,"P(30);C"
      WHERE  NOT (curaccept=""))
     SET dm_env_import_request->asm_sysdba_pwd = build(curaccept)
     SET dmsp_cur_row = (dmsp_cur_row+ 1)
     CALL deir_clear_screen_main_and_repopulate(null)
     CALL accept(dmsp_cur_row,deir_data_start,"P(30);C"
      WHERE  NOT (curaccept=""))
     SET dm_env_import_request->sys_pwd = build(curaccept)
     SET dm_env_import_request->oracle_sys_pwd = dm_env_import_request->sys_pwd
     SET dmsp_cur_row = (dmsp_cur_row+ 1)
     CALL deir_clear_screen_main_and_repopulate(null)
     CALL accept(dmsp_cur_row,deir_data_start,"P(30);C"
      WHERE  NOT (curaccept=""))
     SET dm_env_import_request->system_pwd = build(curaccept)
     CALL deir_clear_screen_main_and_repopulate(null)
     SET dmsp_cur_row = (dmsp_cur_row+ 1)
    ENDIF
   ELSE
    SET dm_env_import_request->dbca_used_ind = 0
    SET dmsp_cur_row = (dmsp_cur_row+ 3)
   ENDIF
   SET dmsp_cur_row2 = 5
   SET dm_env_import_request->target_tns_host = dm_env_import_request->remote_hosts[1].host_name
   IF ((dm_env_import_request->remote_hosts_cnt=1))
    WHILE (deir_cont=1)
      CALL deir_clear_screen_main_and_repopulate(null)
      CALL accept(dmsp_cur_row2,deir_data_start2,"P(30);C",dm_env_import_request->target_tns_host
       WHERE build(curaccept) > "")
      SET dm_env_import_request->target_tns_host = build(curaccept)
      IF (dm2_ping(dm_env_import_request->target_tns_host))
       SET deir_cont = 0
      ELSE
       SET dm_err->err_ind = 0
       SET width = 132
       SET message = window
       CALL clear(1,1)
       CALL box(1,1,24,131)
       CALL text(2,56,"DATABASE SHELL CREATION")
       CALL text(3,48,"*** Remote TNS Host Ping Error ***")
       CALL text(5,2,"Remote TNS Host was unsuccessfully pinged.  This process cannot continue.")
       CALL text(6,2,"Please confirm that remote tns host is operational and on the network.")
       CALL text(8,2,concat("Error Message: ",dm_err->emsg))
       CALL text(10,2,"(M)odify, (Q)uit: ")
       CALL accept(10,21,"A;CU","M"
        WHERE curaccept IN ("M", "Q"))
       CASE (curaccept)
        OF "M":
         SET deir_cont = 1
        OF "Q":
         RETURN(0)
       ENDCASE
      ENDIF
    ENDWHILE
    SET deir_cont = 1
    SET help = off
    SET deir_msg = ""
    SET dmsp_cur_row2 = (dmsp_cur_row2+ 1)
   ENDIF
   CALL deir_clear_screen_main_and_repopulate(null)
   CALL accept(dmsp_cur_row2,deir_data_start2,"9(4);C",dm_env_import_request->target_tns_port
    WHERE build(curaccept) > "")
   SET dm_env_import_request->target_tns_port = build(curaccept)
   SET dmsp_cur_row2 = (dmsp_cur_row2+ 1)
   CALL deir_clear_screen_main_and_repopulate(null)
   CALL accept(dmsp_cur_row2,deir_data_start2,"9(4);C",dm_env_import_request->admin_tns_port
    WHERE build(curaccept) > "")
   SET dm_env_import_request->admin_tns_port = build(curaccept)
   SET dmsp_cur_row2 = (dmsp_cur_row2+ 1)
   IF (validate(dm2_mig_db_ind,- (1))=1)
    CALL deir_clear_screen_main_and_repopulate(null)
    CALL accept(dmsp_cur_row2,deir_data_start2,"9(4);C",dm_env_import_request->source_tns_port
     WHERE build(curaccept) > "")
    SET dm_env_import_request->source_tns_port = build(curaccept)
    SET dmsp_cur_row2 = (dmsp_cur_row2+ 1)
   ENDIF
   IF ((dm2_sys_misc->cur_os != "AXP")
    AND (dm_env_import_request->remote_hosts_cnt=1))
    CALL deir_clear_screen_main_and_repopulate(null)
    CALL accept(dmsp_cur_row2,deir_data_start2,"P(30);C",dm_env_import_request->tgt_exec_dir
     WHERE build(curaccept) > "")
    SET dm_env_import_request->tgt_exec_dir = build(curaccept)
    SET dmsp_cur_row2 = (dmsp_cur_row2+ 1)
   ENDIF
   IF ((dm_env_import_request->target_oracle_version="11.1")
    AND deir_shared_pool_size_max < deir_shared_pool_size_1)
    SET deir_shared_pool_size_max = deir_shared_pool_size_1
   ELSEIF ((((dm_env_import_request->target_oracle_version="11.2")) OR ((dm_env_import_request->
   major_tgt_ora_ver_int >= 12)))
    AND deir_shared_pool_size_max < deir_shared_pool_size_2)
    SET deir_shared_pool_size_max = deir_shared_pool_size_2
   ENDIF
   IF ((dm_env_import_request->major_tgt_ora_ver_int >= 11))
    CALL deir_clear_screen_main_and_repopulate(null)
    CALL accept(dmsp_cur_row2,deir_data_start2,"9(15);C",dm_env_import_request->shared_pool_size
     WHERE build(curaccept) > "")
    IF ((dm_env_import_request->target_oracle_version="11.1"))
     WHILE (((cnvtreal(curaccept) < deir_shared_pool_size_1) OR (cnvtreal(curaccept) >
     deir_shared_pool_size_max)) )
       CALL text((dmsp_cur_row2+ 2),deir_label_start2,"Please enter a shared pool size value between"
        )
       CALL text((dmsp_cur_row2+ 3),deir_label_start2,concat(trim(cnvtstring(deir_shared_pool_size_1,
           15))," and ",trim(cnvtstring(deir_shared_pool_size_max,15))))
       CALL accept(dmsp_cur_row2,deir_data_start2,"9(15);C",dm_env_import_request->shared_pool_size
        WHERE build(curaccept) > "")
     ENDWHILE
    ELSEIF ((((dm_env_import_request->target_oracle_version="11.2")) OR ((dm_env_import_request->
    major_tgt_ora_ver_int >= 12))) )
     WHILE (((cnvtreal(curaccept) < deir_shared_pool_size_2) OR (cnvtreal(curaccept) >
     deir_shared_pool_size_max)) )
       CALL text((dmsp_cur_row2+ 2),deir_label_start2,"Please enter a shared pool size value between"
        )
       CALL text((dmsp_cur_row2+ 3),deir_label_start2,concat(trim(cnvtstring(deir_shared_pool_size_2,
           15))," and ",trim(cnvtstring(deir_shared_pool_size_max,15))))
       CALL accept(dmsp_cur_row2,deir_data_start2,"9(15);C",dm_env_import_request->shared_pool_size
        WHERE build(curaccept) > "")
     ENDWHILE
    ENDIF
    SET dm_env_import_request->shared_pool_size = build(curaccept)
    SET dmsp_cur_row2 = (dmsp_cur_row2+ 1)
   ENDIF
   CALL deir_clear_screen_main_and_repopulate(null)
   CALL accept(23,40,"A;CU"," "
    WHERE curaccept IN ("C", "S", "Q"))
   SET dmsp_selection = build(curaccept)
   SET message = nowindow
   CALL clear(1,1)
   IF ((dm_err->debug_flag >= 1))
    CALL echorecord(dm_env_import_request)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE deir_characterset_prompt(dcp_src_characterset)
   IF ((dm_env_import_request->character_set != dcp_src_characterset))
    SET width = 132
    SET message = window
    CALL clear(1,1)
    CALL box(1,1,24,131)
    CALL text(2,56,"DATABASE SHELL CREATION")
    CALL text(4,2,concat(
      "*** WARNING!!  Character Set differences between Source and Target database were found ***"))
    CALL text(6,2,concat("Source Character Set: ",dcp_src_characterset))
    CALL text(7,2,concat("Target Character Set: ",dm_env_import_request->character_set))
    CALL text(9,2,concat("This can result in negative data loss/conversion ",
      "when the data is moved later in the replicate process"))
    CALL text(11,2,"(C)ontinue, (U)se Source Character Set, (Q)uit: ")
    CALL accept(11,55,"A;CU","Q"
     WHERE curaccept IN ("C", "U", "Q"))
    IF (curaccept="Q")
     RETURN(0)
    ELSEIF (curaccept="U")
     SET dm_env_import_request->character_set = dcp_src_characterset
    ENDIF
   ENDIF
   SET message = nowindow
   CALL clear(1,1)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE deir_main_screen_summary(dmss_selection)
   CALL deir_clear_screen_main_and_repopulate(null)
   CALL accept(23,40,"A;CU"," "
    WHERE curaccept IN ("C", "S", "Q"))
   SET dmss_selection = build(curaccept)
   SET message = nowindow
   CALL clear(1,1)
   IF ((dm_err->debug_flag >= 1))
    CALL echorecord(dm_env_import_request)
   ENDIF
   RETURN(dmss_selection)
 END ;Subroutine
 SUBROUTINE deir_test_ftp(null)
   SET dm_err->eproc = "Setting and validating variables for auto ftp procedures."
   CALL disp_msg("",dm_err->logfile,0)
   SET dm2ftpr->user_name = dm_env_import_request->ftp_user_name
   SET dm2ftpr->remote_host = dm_env_import_request->remote_node_name
   SET dm2ftpr->dir_name = dm_env_import_request->tgt_exec_dir
   SET dm2ftpr->options = "-b"
   IF (dfr_test_connect(null)=0)
    RETURN(0)
   ENDIF
   IF (dfr_find_directory(null)=0)
    RETURN(0)
   ENDIF
   IF ((dm2ftpr->exists_ind=0))
    IF (validate(drrr_responsefile_in_use,0)=1)
     SET dm_err->eproc = "Verify Target database node temporary directory."
     SET dm_err->emsg = concat("Target database node temporary directory (",dm_env_import_request->
      tgt_exec_dir,") not found on Target database node (",dm_env_import_request->remote_node_name,
      ").")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     RETURN(0)
    ELSE
     IF (dfr_create_directory(null)=0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE deir_rrr_shell_creation(null)
   DECLARE drsc_iter = i4 WITH protect, noconstant(0)
   DECLARE drsc_wait_ts1 = f8 WITH protect, noconstant(0)
   DECLARE drsc_wait_ts2 = f8 WITH protect, noconstant(0)
   DECLARE drsc_fnd_idx = i4 WITH protect, noconstant(0)
   DECLARE drsc_search = i4 WITH protect, noconstant(0)
   DECLARE drsc_temp_string = vc WITH protect, noconstant("")
   DECLARE drsc_admin_tns_fnd_ind = i2 WITH protect, noconstant(0)
   DECLARE drsc_node_os = vc WITH protect, noconstant("")
   DECLARE drsc_file_name = vc WITH protect, noconstant("")
   DECLARE drsc_cmd = vc WITH protect, noconstant("")
   DECLARE drsc_node_ln = vc WITH protect, noconstant("")
   DECLARE drsc_idx = i4 WITH protect, noconstant(0)
   DECLARE drsc_info_name_str = vc WITH protect, noconstant("")
   DECLARE drsc_initial_phase_ind = i2 WITH protect, noconstant(0)
   DECLARE drsc_adm_stat_file_name = vc WITH protect, noconstant("")
   IF (curuser != "ROOT")
    SET dm_err->eproc = "Verify current user is root."
    SET dm_err->emsg = "Must be connected to Target APP node as root in order to verify SSH setup."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((drrr_misc_data->process_mode="ADMIN DATABASE CREATION"))
    SET dm_env_import_request->remote_node_name = drrr_rf_data->adm_db_node
   ELSE
    SET dm_env_import_request->remote_node_name = drrr_rf_data->tgt_db_node
   ENDIF
   SET dm_env_import_request->remote_node_name_sn = dm_env_import_request->remote_node_name
   IF (validate(dm2_skip_db_shell_fqdn_check,0)=1)
    IF (findstring(".",dm_env_import_request->remote_node_name,1,0) > 0)
     SET dm_env_import_request->remote_node_name_sn = substring(1,(findstring(".",
       dm_env_import_request->remote_node_name,1,0) - 1),dm_env_import_request->remote_node_name)
    ENDIF
   ENDIF
   SET dm_env_import_request->remote_hosts_cnt = 1
   SET stat = alterlist(dm_env_import_request->remote_hosts,dm_env_import_request->remote_hosts_cnt)
   SET dm_env_import_request->remote_hosts[1].host_name = dm_env_import_request->remote_node_name
   IF (cnvtupper(dm_env_import_request->remote_node_name_sn)=cnvtupper(dm_env_import_request->
    local_node_name_sn))
    SET dm_env_import_request->local_ind = 1
   ENDIF
   SET dm_env_import_request->tgt_exec_dir = drrr_rf_data->tgt_app_temp_dir
   SET dm_env_import_request->db_node_op_system = dm2_sys_misc->cur_db_os
   IF ((drrr_rf_data->tgt_db_deploy_config="OP"))
    SET dm_env_import_request->tgt_exec_dir = drrr_rf_data->tgt_db_temp_dir
    IF (deir_rrr_verify_ssh_setup(dm_env_import_request->remote_node_name_sn,1,drsc_node_os,
     drsc_node_ln)=0)
     RETURN(0)
    ENDIF
    IF (findstring(".",drsc_node_ln,1,0) > 0)
     SET dm_env_import_request->remote_node_name = drsc_node_ln
    ENDIF
    SET dm_env_import_request->db_node_op_system = drsc_node_os
    IF (cnvtupper(drrr_rf_data->tgt_db_node_os) != cnvtupper(dm_env_import_request->db_node_op_system
     ))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validating Target database node OS type."
     SET dm_err->emsg = concat("Target database node OS specified in the response file ",drrr_rf_data
      ->tgt_db_node_os," does not match auto-detected value ",dm_env_import_request->
      db_node_op_system,".")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((drrr_misc_data->tgt_app_node_cnt > 0))
    FOR (drsc_iter = 1 TO drrr_misc_data->tgt_app_node_cnt)
      IF (cnvtupper(curnode) != cnvtupper(build(drrr_misc_data->tgt_app_nodes[drsc_iter].node_name))
       AND cnvtupper(dm_env_import_request->remote_node_name) != cnvtupper(build(drrr_misc_data->
        tgt_app_nodes[drsc_iter].node_name)))
       IF (deir_rrr_verify_ssh_setup(drrr_misc_data->tgt_app_nodes[drsc_iter].node_name,0,
        drsc_node_os,drsc_node_ln)=0)
        RETURN(0)
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF (findstring("/",trim(dm_env_import_request->tgt_exec_dir),1,1)=size(trim(dm_env_import_request
     ->tgt_exec_dir)))
    SET dm_env_import_request->tgt_exec_dir = trim(replace(dm_env_import_request->tgt_exec_dir,"/","",
      2))
   ENDIF
   SET dm_env_import_request->ftp_user_name = "oracle"
   SET dm_env_import_request->database_storage_type = "ASM"
   IF ((cnvtupper(deir_src_storage_type) != dm_env_import_request->database_storage_type)
    AND (validate(dm2_allow_different_storage,- (1))=- (1)))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating Source database storage type."
    SET dm_err->emsg = concat(
     "Source database storage is RAW.  Only supporting ASM when response file used.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_env_import_request->character_set = deir_src_characterset
   SET dm_env_import_request->database_extent_management = deir_src_extent_mgmt
   SET dm_env_import_request->target_oracle_version = drrr_rf_data->tgt_db_oracle_ver
   IF (findstring(".",dm_env_import_request->target_oracle_version) > 0)
    SET dm_env_import_request->major_tgt_ora_ver_int = cnvtint(substring(1,(findstring(".",
       dm_env_import_request->target_oracle_version) - 1),dm_env_import_request->
      target_oracle_version))
   ELSE
    SET dm_env_import_request->major_tgt_ora_ver_int = cnvtint(dm_env_import_request->
     target_oracle_version)
   ENDIF
   SET dm_env_import_request->db_oracle_home = drrr_rf_data->tgt_db_oracle_home
   SET dm_env_import_request->db_oracle_base = drrr_rf_data->tgt_db_oracle_base
   SET dm_env_import_request->target_environment_name = drrr_rf_data->tgt_db_env_name
   SET dm_env_import_request->target_environment_description = drrr_rf_data->tgt_env_desc
   IF ((drrr_misc_data->process_mode="ADMIN DATABASE CREATION"))
    SET dm_env_import_request->target_database_name = "ADMIN"
    SET dm_env_import_request->admin_oracle_version = drrr_rf_data->adm_db_oracle_ver
    SET dm_env_import_request->target_cdb_name = "CADMIN"
    SET dm_env_import_request->asm_storage_disk_group = drrr_rf_data->adm_storage_dg
    SET dm_env_import_request->asm_recovery_disk_group = drrr_rf_data->adm_recovery_dg
    SET dm_env_import_request->log_archive_dest_1 = drrr_rf_data->tgt_archive_dest1
    IF ((drrr_rf_data->adm_tns_port != "DM2NOTSET"))
     SET dm_env_import_request->target_tns_port = drrr_rf_data->adm_tns_port
     SET dm_env_import_request->admin_tns_port = drrr_rf_data->adm_tns_port
    ENDIF
    SET dm_env_import_request->target_tns_host = drrr_rf_data->adm_db_node
   ELSE
    SET dm_env_import_request->target_database_name = cnvtupper(drrr_rf_data->tgt_db_name)
    SET dm_env_import_request->target_connect_string = drrr_rf_data->tgt_db_cnct_str
    SET dm_env_import_request->admin_oracle_version = drrr_rf_data->adm_db_oracle_ver
    IF ((dm_env_import_request->major_tgt_ora_ver_int >= 12))
     SET dm_env_import_request->target_cdb_name = cnvtupper(drrr_rf_data->tgt_cdb_name)
    ENDIF
    SET dm_env_import_request->asm_storage_disk_group = drrr_rf_data->tgt_storage_dg
    SET dm_env_import_request->asm_recovery_disk_group = drrr_rf_data->tgt_recovery_dg
    SET dm_env_import_request->log_archive_dest_1 = drrr_rf_data->tgt_archive_dest1
    SET dm_env_import_request->target_tns_host = drrr_rf_data->tgt_tns_host_name
    IF ((drrr_rf_data->tgt_tns_port != "DM2NOTSET"))
     SET dm_env_import_request->target_tns_port = drrr_rf_data->tgt_tns_port
    ENDIF
    IF ((drrr_rf_data->adm_tns_port != "DM2NOTSET"))
     SET dm_env_import_request->admin_tns_port = drrr_rf_data->adm_tns_port
    ENDIF
    IF ((dm_env_import_request->target_tns_host="DM2NOTSET"))
     SET dm_env_import_request->target_tns_host = drrr_rf_data->tgt_db_node
    ENDIF
   ENDIF
   IF ((dm_env_import_request->asm_storage_disk_group="DM2NOTSET"))
    SET dm_env_import_request->asm_storage_disk_group = build(cnvtupper(dm_env_import_request->
      target_database_name),"_DG1")
   ENDIF
   IF ((dm_env_import_request->asm_recovery_disk_group="DM2NOTSET"))
    SET dm_env_import_request->asm_recovery_disk_group = build(cnvtupper(dm_env_import_request->
      target_database_name),"_DG_FLASH")
   ENDIF
   IF ((dm_env_import_request->log_archive_dest_1="DM2NOTSET"))
    SET dm_env_import_request->log_archive_dest_1 = build("LOCATION=+",dm_env_import_request->
     asm_recovery_disk_group,"/",cnvtupper(dm_env_import_request->target_database_name))
   ENDIF
   SET dm_err->eproc = "Verify response data specified correctly."
   IF (cnvtupper(dm_env_import_request->log_archive_dest_1) != patstring("LOCATION=*"))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Value for LOG_ARCHIVE_DEST_1 must begin with 'LOCATION='."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (((findstring('"',dm_env_import_request->log_archive_dest_1,1,0) > 0) OR (findstring("'",
    dm_env_import_request->log_archive_dest_1,1,0) > 0)) )
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Value for LOG_ARCHIVE_DEST_1 cannot contain single or double quotes"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_env_import_request->asm_sysdba_pwd = drrr_rf_data->tgt_asm_sysdba_pwd
   SET dm_env_import_request->sys_user = drrr_rf_data->tgt_sys_user
   SET dm_env_import_request->sys_pwd = drrr_rf_data->tgt_sys_pwd
   SET dm_env_import_request->oracle_sys_pwd = dm_env_import_request->sys_pwd
   SET dm_env_import_request->system_pwd = drrr_rf_data->tgt_system_pwd
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm_env_import_request)
   ENDIF
   IF ((drrr_rf_data->tgt_shell_ignorable_error_list != "DM2NOTSET"))
    SET dm_env_import_request->ignorable_error_codes = build("(",replace(replace(drrr_rf_data->
       tgt_shell_ignorable_error_list,'"',"",0),",","|",0),")")
   ENDIF
   SET dm_env_import_request->mode = "NOPROMPT"
   IF (findstring("/",trim(dm_env_import_request->db_oracle_home),1,1)=size(trim(
     dm_env_import_request->db_oracle_home)))
    SET dm_env_import_request->db_oracle_home = trim(replace(dm_env_import_request->db_oracle_home,
      "/","",2))
   ENDIF
   IF (findstring("/",trim(dm_env_import_request->db_oracle_base),1,1)=size(trim(
     dm_env_import_request->db_oracle_base)))
    SET dm_env_import_request->db_oracle_base = trim(replace(dm_env_import_request->db_oracle_base,
      "/","",2))
   ENDIF
   SET dm_env_import_request->asm_oracle_home = replace(dm_env_import_request->db_oracle_home,"/db",
    "/asm",2)
   IF (cnvtupper(dm_env_import_request->target_environment_name)=cnvtupper(deir_source_env_name))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Target Environment Name specified is same as SOURCE Environment."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ( NOT ((dm_env_import_request->database_extent_management="LOCAL")))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Database Extent Management invalid (must be LOCAL)."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (locateval(drsc_idx,1,deir_char_set->cnt,dm_env_import_request->character_set,deir_char_set->
    qual[drsc_idx].char_set_value)=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Database Character Set invalid.  Valid values are: ",deir_char_set->
     char_set_str,".")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_env_import_request->major_tgt_ora_ver_int >= 12))
    IF ((drrr_rf_data->tgt_db_deploy_config != "ADB")
     AND textlen(dm_env_import_request->target_cdb_name) > 7
     AND (validate(dm2_allow_longer_db_name,- (1))=- (1)))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file target cdb name: ",dm_env_import_request->
      target_cdb_name)
     SET dm_err->emsg = concat("Target CDB name should not exceed 7 characters.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (textlen(dm_env_import_request->target_database_name) > 30
     AND (validate(dm2_allow_longer_db_name,- (1))=- (1)))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file target database name: ",
      dm_env_import_request->target_database_name)
     SET dm_err->emsg = concat("Target PDB name should not exceed 30 characters.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    IF (textlen(dm_env_import_request->target_database_name) > 5
     AND (validate(dm2_allow_longer_db_name,- (1))=- (1)))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating response file target database name: ",
      dm_env_import_request->target_database_name)
     SET dm_err->emsg = concat("Target database name should not exceed 5 characters.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_env_import_request->target_oracle_version="11.1")
    AND deir_shared_pool_size_max < deir_shared_pool_size_1)
    SET deir_shared_pool_size_max = deir_shared_pool_size_1
   ELSEIF ((((dm_env_import_request->target_oracle_version="11.2")) OR ((dm_env_import_request->
   major_tgt_ora_ver_int >= 12)))
    AND deir_shared_pool_size_max < deir_shared_pool_size_2)
    SET deir_shared_pool_size_max = deir_shared_pool_size_2
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("deir_shared_pool_size_max = ",deir_shared_pool_size_max))
   ENDIF
   IF (cnvtreal(drrr_rf_data->tgt_shared_pool_size) > deir_shared_pool_size_max)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating shared pool size."
    SET dm_err->emsg = concat("Shared pool size value should be less than ",build(
      deir_shared_pool_size_max))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_env_import_request->local_ind=0)
    AND (drrr_rf_data->tgt_db_deploy_config="OP"))
    IF (deir_test_ftp(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET drsc_adm_stat_file_name = build(drrr_misc_data->status_dir,"admin_db_creation_succ.txt")
   IF ((drrr_misc_data->process_mode="ADMIN DATABASE CREATION"))
    SET drsc_initial_phase_ind = 1
    SET dm_err->eproc = concat("Evaluating if success file for Admin Database Creation (",trim(
      drsc_adm_stat_file_name,3),") exists.")
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (dm2_findfile(drsc_adm_stat_file_name) > 0)
     SET drsc_cmd = concat("cat ",drsc_adm_stat_file_name)
     IF (dm2_push_dcl(drsc_cmd)=0)
      RETURN(0)
     ENDIF
     IF (parse_errfile(dm_err->errfile)=0)
      RETURN(0)
     ENDIF
     IF (findstring(concat("SUCCESS"),cnvtupper(dm_err->errtext),1,0) > 0)
      SET drsc_initial_phase_ind = 0
     ENDIF
    ENDIF
   ELSE
    SET dm2_install_schema->dbase_name = "ADMIN"
    SET dm2_install_schema->u_name = dm_env_import_request->admin_user_name
    SET dm2_install_schema->p_word = dm_env_import_request->admin_pwd
    SET dm2_install_schema->connect_str = dm_env_import_request->admin_connect_string
    EXECUTE dm2_connect_to_dbase "CO"
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    IF ( NOT (validate(dm2_tgt_db_type_flag,"XXX") IN ("ADMIN", "ADMMIG")))
     EXECUTE dm2_create_db_env
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ENDIF
    SET drsc_info_name_str = cnvtupper(build(dm_env_import_request->target_database_name,
      "_DB_SHELL_CREATION_PROCESS"))
    SET dm_err->eproc = concat("Query for ",drsc_info_name_str," row in Admin DM_INFO.")
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DM2_REPLICATE_DATA"
      AND di.info_name=patstring(drsc_info_name_str)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET drsc_initial_phase_ind = 1
    ENDIF
   ENDIF
   IF (drsc_initial_phase_ind=1)
    SET dm_err->eproc = "Starting initial phase - DBCA database creation."
    CALL disp_msg("",dm_err->logfile,0)
    IF ((validate(dm2_bypass_tns_work,- (1))=- (1))
     AND (drrr_rf_data->tgt_db_deploy_config != "ADB"))
     IF (deir_rrr_app_tns_cnct_work(1)=0)
      RETURN(0)
     ENDIF
    ENDIF
    IF ((drrr_rf_data->tgt_db_deploy_config="OP"))
     IF (deir_rrr_create_db(null)=0)
      RETURN(0)
     ENDIF
    ENDIF
    IF ((drrr_misc_data->process_mode="ADMIN DATABASE CREATION"))
     SET dm_err->eproc = concat("Writing success file for Admin Database Creation (",trim(
       drsc_adm_stat_file_name,3),").")
     CALL disp_msg(" ",dm_err->logfile,0)
     SELECT INTO value(drsc_adm_stat_file_name)
      DETAIL
       CALL print("SUCCESS"), row + 1
      WITH nocounter, maxcol = 500, format = variable,
       maxrow = 1
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
    ELSE
     SET dm_err->eproc = concat("Insert row ",drsc_info_name_str)
     CALL disp_msg("",dm_err->logfile,0)
     INSERT  FROM dm_info di
      SET di.info_domain = "DM2_REPLICATE_DATA", di.info_name = drsc_info_name_str
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     COMMIT
    ENDIF
   ELSE
    SET dm_err->eproc =
    "Initial phase (DBCA database creation) complete.  Continuing to final phase."
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SET dm_err->eproc = "Starting final phase - complete configuration on Target app node(s)."
   CALL disp_msg("",dm_err->logfile,0)
   IF ((validate(dm2_bypass_tns_work,- (1))=- (1))
    AND (drrr_rf_data->tgt_db_deploy_config != "ADB"))
    SET dm_err->eproc =
    "Update Target app node(s) tnsnames.ora file with Target database tns entries."
    CALL disp_msg("",dm_err->logfile,0)
    IF (deir_rrr_app_tns_cnct_work(2)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((validate(dm2_bypass_tns_work,- (1))=- (1)))
    SET dm_err->eproc =
    "Verify Target app node(s) tnsnames.ora file using Target database tns entries."
    CALL disp_msg("",dm_err->logfile,0)
    IF (deir_rrr_app_tns_cnct_work(3)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_env_import_request->local_ind=0)
    AND (drrr_misc_data->process_mode != "ADMIN DATABASE CREATION")
    AND (drrr_rf_data->tgt_db_deploy_config="OP"))
    SET dm_err->eproc = "Verify Admin Connection setup on Target database node."
    CALL disp_msg("",dm_err->logfile,0)
    SET dm_err->disp_dcl_err_ind = 0
    CALL dm2_push_dcl("rm $CCLUSERDIR/tnsnames.ora")
    SET dm_err->err_ind = 0
    SET dm_err->eproc = concat("Copy tnsnames.ora file from remote database node (",build(
      dm_env_import_request->remote_node_name),") ",build(dm_env_import_request->db_oracle_home,
      "/network/admin")," directory to CCLUSERDIR on local Target app node.")
    CALL disp_msg("",dm_err->logfile,0)
    SET dm2ftpr->user_name = "oracle"
    SET dm2ftpr->remote_host = dm_env_import_request->remote_node_name
    SET dm2ftpr->options = "-b"
    CALL dfr_add_getops_line(" "," "," "," "," ",
     1)
    CALL dfr_add_getops_line(" ",build(trim(logical("ccluserdir")),"/"),"tnsnames.ora",build(
      dm_env_import_request->db_oracle_home,"/network/admin/"),"tnsnames.ora",
     0)
    IF (dfr_get_file(null)=0)
     RETURN(0)
    ENDIF
    CALL dfr_add_getops_line(" "," "," "," "," ",
     1)
    IF ( NOT (dm2_findfile("$CCLUSERDIR/tnsnames.ora")))
     SET dm_err->eproc = "Attempting to copy tnsnames.ora to CCLUSDERDIR"
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "ERROR: tnsnames.ora was not found in CCLUSERDIR."
     RETURN(0)
    ENDIF
    IF ( NOT (dtr_parse_tns(dm2_install_schema->ccluserdir,"")))
     RETURN(0)
    ENDIF
    FOR (drsc_iter = 1 TO tnswork->cnt)
      IF (cnvtupper(tnswork->qual[drsc_iter].tns_key)=cnvtupper(dm_env_import_request->
       admin_connect_string))
       SET drsc_admin_tns_fnd_ind = 1
      ENDIF
    ENDFOR
    IF ( NOT (dtr_reset_tnswork(null)))
     RETURN(0)
    ENDIF
    IF (drsc_admin_tns_fnd_ind=0)
     IF ( NOT (dtr_parse_tns("","tnsnames.ora")))
      RETURN(0)
     ENDIF
     SET dm_err->eproc =
     "Create file to store Admin tns entry to be added to Target db node tnsnames.ora file."
     CALL disp_msg(" ",dm_err->logfile,0)
     IF (get_unique_file("dm2_admin_tns",".txt")=0)
      RETURN(0)
     ELSE
      SET drsc_file_name = dm_err->unique_fname
     ENDIF
     SELECT INTO value(drsc_file_name)
      FROM (dummyt d  WITH seq = value(tnswork->cnt))
      WHERE cnvtupper(tnswork->qual[d.seq].tns_key)=cnvtupper(dm_env_import_request->
       admin_connect_string)
      HEAD REPORT
       iter = 0, col 0, " ",
       row + 1, col 0, " ",
       row + 1
      DETAIL
       col 0, " ", row + 1
       FOR (iter = 1 TO tnswork->qual[d.seq].line_cnt)
         col 0, tnswork->qual[d.seq].qual[iter].text, row + 1
       ENDFOR
       col 0, " ", row + 1
      WITH nocounter, maxcol = 500, format = variable,
       maxrow = 1
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = concat("Append Admin database tns entry to Target db node (",build(
       dm_env_import_request->remote_node_name),") Oracle Home directory tnsnames file (",build(
       dm_env_import_request->db_oracle_home,"/network/admin/tnsnames.ora"),").")
     CALL disp_msg(" ",dm_err->logfile,0)
     SET drsc_cmd = concat("cat ",build(trim(logical("ccluserdir")),"/",drsc_file_name),
      " | ssh oracle@",build(dm_env_import_request->remote_node_name)," 'cat >> ",
      build(dm_env_import_request->db_oracle_home,"/network/admin/tnsnames.ora"),"'")
     SET dm_err->eproc = concat("Executing: ",drsc_cmd)
     CALL disp_msg(" ",dm_err->logfile,0)
     CALL dcl(drsc_cmd,size(drsc_cmd),dm_err->ecode)
    ENDIF
    IF (deir_rrr_chk_connect(dm_env_import_request->remote_node_name,dm_env_import_request->
     db_oracle_home,dm_env_import_request->tgt_exec_dir,dm_env_import_request->admin_user_name,
     dm_env_import_request->admin_pwd,
     dm_env_import_request->admin_connect_string,dm_env_import_request->admin_dbase_name,
     dm_env_import_request->admin_host_name,dm_env_import_request->admin_oracle_version)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm2_install_schema->dbase_name = dm_env_import_request->target_database_name
   SET dm2_install_schema->u_name = dm_env_import_request->sys_user
   SET dm2_install_schema->p_word = dm_env_import_request->oracle_sys_pwd
   SET dm2_install_schema->connect_str = drrr_rf_data->tgt_db_cnct_str
   EXECUTE dm2_connect_to_dbase "CO"
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF (((cnvtupper(currdbname) != cnvtupper(dm_env_import_request->target_database_name)) OR (((
    NOT (trim(currdbhandle,3) > " ")) OR ((currdbuser != dm_env_import_request->sys_user))) )) )
    SET dm_err->eproc = "Validate local TNS file contains Target database TNS connection entries."
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "TNS entries were not successfully tested."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Updating the local registry..."
   CALL disp_msg("",dm_err->logfile,0)
   IF ((validate(dm2_skip_update_registry,- (1))=- (1)))
    IF (deir_update_registry(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm2_install_schema->curprog = curprog
   IF ((validate(dm2_skip_create_users,- (1))=- (1))
    AND  NOT ((drrr_misc_data->process_mode IN ("ADMIN DATABASE CREATION",
   "CLINICAL DATABASE CREATION"))))
    IF ((drrr_rf_data->tgt_db_deploy_config != "ADB"))
     IF (deir_create_misc_ts(null)=0)
      RETURN(0)
     ENDIF
    ENDIF
    SET dcdur_user_data->tgt_sys_user = dm_env_import_request->sys_user
    SET dcdur_user_data->tgt_sys_pwd = dm_env_import_request->oracle_sys_pwd
    EXECUTE dm2_create_users "ALL"
    IF (dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((drrr_misc_data->process_mode IN ("ADMIN DATABASE CREATION", "CLINICAL DATABASE CREATION")))
    IF (deir_mng_temp_tspaces(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   EXECUTE dm2_setup_new_db
   IF (dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((drrr_misc_data->process_mode="ADMIN DATABASE CREATION"))
    IF (dm2_findfile(drsc_adm_stat_file_name) > 0)
     SET drsc_cmd = concat("rm ",drsc_adm_stat_file_name)
     IF (dm2_push_dcl(drsc_cmd)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ELSE
    SET dm2_install_schema->dbase_name = "ADMIN"
    SET dm2_install_schema->u_name = dm_env_import_request->admin_user_name
    SET dm2_install_schema->p_word = dm_env_import_request->admin_pwd
    SET dm2_install_schema->connect_str = dm_env_import_request->admin_connect_string
    EXECUTE dm2_connect_to_dbase "CO"
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    SET dm_err->eproc = concat("Delete ",drsc_info_name_str," row in Admin DM_INFO.")
    CALL disp_msg("",dm_err->logfile,0)
    DELETE  FROM dm_info di
     WHERE di.info_domain="DM2_REPLICATE_DATA"
      AND di.info_name=patstring(drsc_info_name_str)
     WITH nocounter
    ;end delete
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE deir_rrr_create_db(null)
   DECLARE drcd_dbca_tgt_file = vc WITH protect, noconstant("")
   DECLARE drcd_iter = i4 WITH protect, noconstant(0)
   DECLARE drcd_format_chg_ind = i2 WITH protect, noconstant(0)
   DECLARE drcd_cmd = vc WITH protect, noconstant("")
   DECLARE drcd_ksh_err_file = vc WITH protect, noconstant("")
   DECLARE drcd_fatal_err = i2 WITH protect, noconstant(0)
   DECLARE drcd_ksh_error = vc WITH protect, noconstant("")
   DECLARE drcd_str = vc WITH protect, noconstant("")
   DECLARE drcd_notfnd = vc WITH protect, constant("<not_found>")
   DECLARE drcd_num = i4 WITH protect, noconstant(1)
   DECLARE drcd_error_prefix = vc WITH protect, noconstant("")
   DECLARE drcd_cnt = i4 WITH protect, noconstant(0)
   DECLARE drcd_cnt2 = i4 WITH protect, noconstant(0)
   DECLARE drcd_ignore_err = i2 WITH protect, noconstant(0)
   DECLARE drcd_skip_file_gen = i2 WITH protect, noconstant(0)
   DECLARE drcd_line = i4 WITH protect, noconstant(0)
   DECLARE drcd_idx = i4 WITH protect, noconstant(0)
   DECLARE drcd_idx2 = i4 WITH protect, noconstant(0)
   DECLARE drcd_stack_key = vc WITH protect, noconstant("")
   DECLARE drcd_ignore_str = vc WITH protect, noconstant("")
   DECLARE drcd_scnt = i4 WITH protect, noconstant(0)
   DECLARE drcd_scnt2 = i4 WITH protect, noconstant(0)
   DECLARE drcd_nbr_list = vc WITH protect, noconstant("")
   DECLARE drcd_nbr = vc WITH protect, noconstant("")
   FREE RECORD drcd_error_pref_rs
   RECORD drcd_error_pref_rs(
     1 cnt = i4
     1 qual[*]
       2 prefix = vc
   )
   SET drcd_error_pref_rs->cnt = 0
   SET stat = alterlist(drcd_error_pref_rs->qual,0)
   FREE RECORD drcd_file_content
   RECORD drcd_file_content(
     1 cnt = i4
     1 qual[*]
       2 line = vc
   )
   SET drcd_file_content->cnt = 0
   SET stat = alterlist(drcd_file_content->qual,0)
   FREE RECORD dcds_ignore_stack
   RECORD dcds_ignore_stack(
     1 cnt = i4
     1 qual[*]
       2 skey = vc
       2 icnt = i4
       2 ignore[*]
         3 str = vc
   )
   SET dcds_ignore_stack->cnt = 0
   IF (validate(dm2_bypass_db_shell_stck_load,0)=0)
    SET dcds_ignore_stack->cnt = 1
    SET stat = alterlist(dcds_ignore_stack->qual,dcds_ignore_stack->cnt)
    SET dcds_ignore_stack->qual[dcds_ignore_stack->cnt].skey = "ORA-06550"
    SET dcds_ignore_stack->qual[dcds_ignore_stack->cnt].icnt = 2
    SET stat = alterlist(dcds_ignore_stack->qual[dcds_ignore_stack->cnt].ignore,dcds_ignore_stack->
     qual[dcds_ignore_stack->cnt].icnt)
    SET dcds_ignore_stack->qual[dcds_ignore_stack->cnt].ignore[1].str = "INITJVMAUX"
    SET dcds_ignore_stack->qual[dcds_ignore_stack->cnt].ignore[2].str = "STATEMENT IGNORED"
   ENDIF
   IF ((drrr_misc_data->process_mode != "ADMIN DATABASE CREATION"))
    SET dm_err->eproc = "Load ingorable error stack data into memory."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DM2_CREATE_DB_SHELL_IGNORE_STACK:*"
     ORDER BY di.info_domain
     DETAIL
      drcd_stack_key = substring((findstring(":",di.info_domain,1,0)+ 1),size(di.info_domain),di
       .info_domain), drcd_stack_key = cnvtupper(trim(drcd_stack_key,3)), drcd_ignore_str = cnvtupper
      (trim(di.info_name,3)),
      drcd_idx = 0, drcd_idx = locateval(drcd_idx,1,dcds_ignore_stack->cnt,drcd_stack_key,
       dcds_ignore_stack->qual[drcd_idx].skey)
      IF (drcd_idx=0)
       dcds_ignore_stack->cnt = (dcds_ignore_stack->cnt+ 1), stat = alterlist(dcds_ignore_stack->qual,
        dcds_ignore_stack->cnt), dcds_ignore_stack->qual[dcds_ignore_stack->cnt].skey =
       drcd_stack_key,
       drcd_idx = dcds_ignore_stack->cnt
      ENDIF
      drcd_idx2 = 0, drcd_idx2 = locateval(drcd_idx2,1,dcds_ignore_stack->qual[drcd_idx].icnt,
       drcd_ignore_str,dcds_ignore_stack->qual[drcd_idx].ignore[drcd_idx2].str)
      IF (drcd_idx2=0)
       dcds_ignore_stack->qual[drcd_idx].icnt = (dcds_ignore_stack->qual[drcd_idx].icnt+ 1), stat =
       alterlist(dcds_ignore_stack->qual[drcd_idx].ignore,dcds_ignore_stack->qual[drcd_idx].icnt),
       dcds_ignore_stack->qual[drcd_idx].ignore[dcds_ignore_stack->qual[drcd_idx].icnt].str =
       drcd_ignore_str
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcds_ignore_stack)
   ENDIF
   IF (validate(dm2_bypass_db_shell_file_generation,0)=1)
    SET drcd_skip_file_gen = 1
   ENDIF
   IF ((((drrr_rf_data->tgt_db_oracle_ver=patstring("11.*"))) OR ((drrr_rf_data->tgt_db_oracle_ver=
   patstring("12.*")))) )
    SET deir_loc = findstring(".",drrr_rf_data->tgt_db_oracle_home,1)
    SET dm_env_import_request->target_lvl4_oracle_version = substring((deir_loc - 2),8,drrr_rf_data->
     tgt_db_oracle_home)
   ELSEIF ((drrr_rf_data->tgt_db_oracle_ver=patstring("19*")))
    SET dm_env_import_request->target_lvl4_oracle_version = concat(trim(cnvtstring(
       dm_env_import_request->major_tgt_ora_ver_int)),".0.0.0")
   ENDIF
   IF ((drrr_rf_data->tgt_db_create_type != "SHELL"))
    IF ((drrr_misc_data->process_mode="ADMIN DATABASE CREATION"))
     IF (dm2_findfile(build(deir_src_tmp_full_dir,"dm2_dbca_seeded_template_admin_19.dbc"))=0)
      SET dm_err->eproc = concat("Check for Admin dbca seeded template (",build(deir_src_tmp_full_dir,
        "dm2_dbca_seeded_template_admin_19.dbc"),").")
      SET dm_err->emsg = "File not found."
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ELSE
     IF (dm2_findfile(build(deir_src_tmp_full_dir,cnvtlower(build("dm2_dbca_seeded_template_",
         drrr_rf_data->tgt_db_create_type,"_19.dbc"))))=0)
      SET dm_err->eproc = concat("Check for clinical dbca seeded template (",build(
        deir_src_tmp_full_dir,cnvtlower(build("dm2_dbca_seeded_template_",drrr_rf_data->
          tgt_db_create_type,"_19.dbc"))),").")
      SET dm_err->emsg = "File not found."
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF (drcd_skip_file_gen=0)
    FREE DEFINE rtl2
    IF ((dm_err->debug_flag > 0))
     CALL echo(build("dm_env_import_request->target_oracle_version =",dm_env_import_request->
       target_oracle_version))
    ENDIF
    IF ((dm_env_import_request->target_oracle_version=patstring("12.*")))
     SET logical file_name value(build("CER_INSTALL:dm2_master_122_ksh.txt"))
    ELSEIF ((dm_env_import_request->target_oracle_version=patstring("19*")))
     SET logical file_name value(build("CER_INSTALL:dm2_master_19_ksh.txt"))
    ELSE
     SET logical file_name value(build("CER_INSTALL:dm2_master_111_ksh.txt"))
    ENDIF
    DEFINE rtl2 "file_name"  WITH nomodify
    SET drcd_dbca_tgt_file = build("v500db_",cnvtlower(dm_env_import_request->target_database_name),
     "_create.ksh")
    SET dm_err->eproc = concat("Creating ",build("CCLUSERDIR:",drcd_dbca_tgt_file))
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO build("CCLUSERDIR:",drcd_dbca_tgt_file)
     FROM rtl2t r
     DETAIL
      deir_temp_line = replace(r.line,"[[db_home]]",build(dm_env_import_request->db_oracle_home),0),
      deir_temp_line = replace(deir_temp_line,"[[db_node_os]]",build(dm_env_import_request->
        db_node_op_system),0), deir_temp_line = replace(deir_temp_line,"[[tgt_exec_dir]]",build(
        dm_env_import_request->tgt_exec_dir),0),
      deir_temp_line = replace(deir_temp_line,"[[oracle_base]]",build(dm_env_import_request->
        db_oracle_base),0)
      IF ((dm_env_import_request->major_tgt_ora_ver_int >= 12))
       deir_temp_line = replace(deir_temp_line,"[[cdbname]]",cnvtlower(build(dm_env_import_request->
          target_cdb_name)),0), deir_temp_line = replace(deir_temp_line,"[[pdbname]]",cnvtlower(build
         (dm_env_import_request->target_database_name)),0)
      ELSE
       deir_temp_line = replace(deir_temp_line,"[[dbname]]",cnvtlower(build(dm_env_import_request->
          target_database_name)),0)
      ENDIF
      deir_temp_line = replace(deir_temp_line,"[[dbcharset]]",build(dm_env_import_request->
        character_set),0), deir_temp_line = replace(deir_temp_line,"[[node_list]]",build(
        dm_env_import_request->remote_node_name),0), deir_temp_line = replace(deir_temp_line,
       "[[sys_pwd]]",build(dm_env_import_request->sys_pwd),0),
      deir_temp_line = replace(deir_temp_line,"[[system_pwd]]",build(dm_env_import_request->
        system_pwd),0), deir_temp_line = replace(deir_temp_line,"[[asm_sysdba_pwd]]",build(
        dm_env_import_request->asm_sysdba_pwd),0), deir_temp_line = replace(deir_temp_line,
       "[[asm_storage_dg]]",build(dm_env_import_request->asm_storage_disk_group),0),
      deir_temp_line = replace(deir_temp_line,"[[asm_recovery_dg]]",build(dm_env_import_request->
        asm_recovery_disk_group),0), deir_temp_line = replace(deir_temp_line,"[[log_archive_dest_1]]",
       build(dm_env_import_request->log_archive_dest_1),0)
      IF ((drrr_rf_data->tgt_db_create_type="SHELL"))
       deir_temp_line = replace(deir_temp_line,"[[dbca_template]]",cnvtlower(build("v500db_",
          dm_env_import_request->target_database_name,"_dbca.dbt")),0), deir_temp_line = replace(
        deir_temp_line,"[[dbca_pdbname_line]]","-pdbName ${PDBNAME} \",0), deir_temp_line = replace(
        deir_temp_line,"[[src_pdbname]]",cnvtlower(build(dm_env_import_request->target_database_name)
         ),0),
       deir_temp_line = replace(deir_temp_line,"[[dbca_create_type]]","SHELL",0)
      ELSE
       IF ((drrr_misc_data->process_mode="ADMIN DATABASE CREATION"))
        deir_temp_line = replace(deir_temp_line,"[[dbca_template]]",concat(dm_env_import_request->
          tgt_exec_dir,"/dm2_dbca_seeded_template_admin_19.dbc"),0), deir_temp_line = replace(
         deir_temp_line,"[[src_pdbname]]",cnvtlower(build(dm_env_import_request->target_database_name
           )),0)
       ELSE
        deir_temp_line = replace(deir_temp_line,"[[dbca_template]]",cnvtlower(build(
           dm_env_import_request->tgt_exec_dir,"/dm2_dbca_seeded_template_",drrr_rf_data->
           tgt_db_create_type,"_19.dbc")),0), deir_temp_line = replace(deir_temp_line,
         "[[src_pdbname]]",cnvtlower(build(drrr_rf_data->src_db_name)),0)
       ENDIF
       deir_temp_line = replace(deir_temp_line,"[[dbca_pdbname_line]]","\",0)
      ENDIF
      deir_temp_line = replace(deir_temp_line,"[[disableSecurityConfiguration]]",
       "-disableSecurityConfiguration ALL \",0), deir_temp_line = replace(deir_temp_line,
       "[[emConfiguration]]","-emConfiguration NONE \",0), deir_temp_line = replace(deir_temp_line,
       "[[ignorable_error_codes]]",build(dm_env_import_request->ignorable_error_codes),0),
      deir_temp_line = replace(deir_temp_line,"[[mode]]",build(dm_env_import_request->mode),0),
      deir_temp_line = replace(deir_temp_line,"[[case_sens_logon_val]]",build(dm_env_import_request->
        source_case_sens_login_val),0), deir_temp_line = replace(deir_temp_line,
       "[[source_db_node_name]]",cnvtupper(build(dm_env_import_request->source_db_node_name)),0),
      deir_temp_line = replace(deir_temp_line,"[[dbca_create_type]]","NON-SHELL",0)
      IF ((drrr_rf_data->tgt_db_create_type="SHELL"))
       IF ((validate(dm2_skip_source_processing,- (1))=- (1))
        AND (validate(dm2_skip_sqlnet_sync_work,- (1))=- (1))
        AND (dm_env_import_request->source_lvl4_oracle_version=dm_env_import_request->
       target_lvl4_oracle_version))
        deir_temp_line = replace(deir_temp_line,"[[source_sync_flag]]","YES",0)
       ELSE
        deir_temp_line = replace(deir_temp_line,"[[source_sync_flag]]","NO",0)
       ENDIF
      ELSE
       deir_temp_line = replace(deir_temp_line,"[[source_sync_flag]]","NO",0)
      ENDIF
      deir_temp_line = replace(deir_temp_line,"[[sql92_security]]",build(dm_env_import_request->
        source_sql92_security_val),0)
      IF ((dm_env_import_request->major_tgt_ora_ver_int <= 12))
       deir_temp_line = replace(deir_temp_line,"[[o7_dictionary_accessibility]]",build(
         dm_env_import_request->source_o7_dict_access_val),0)
      ENDIF
      CALL print(deir_temp_line), row + 1
     WITH nocounter, maxrow = 1, maxcol = 2001,
      format = variable, formfeed = none
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    FREE DEFINE rtl2
    IF ((drrr_rf_data->tgt_db_create_type="SHELL"))
     IF ((dm_env_import_request->target_oracle_version="11.2"))
      SET logical file_name value(build("CER_INSTALL:dm2_master_112_single.txt"))
     ELSEIF ((dm_env_import_request->target_oracle_version="12.2"))
      SET logical file_name value(build("CER_INSTALL:dm2_master_122_single.txt"))
     ELSEIF ((dm_env_import_request->target_oracle_version="19"))
      SET logical file_name value(build("CER_INSTALL:dm2_master_19_single.txt"))
     ELSE
      SET logical file_name value(build("CER_INSTALL:dm2_master_111_single.txt"))
     ENDIF
     SET drcd_dbca_tgt_file = build("v500db_",cnvtlower(dm_env_import_request->target_database_name),
      "_dbca",".dbt")
    ELSE
     IF ((drrr_misc_data->process_mode="ADMIN DATABASE CREATION"))
      SET logical file_name value(build(deir_src_tmp_full_dir,"dm2_dbca_seeded_template_admin_19.dbc"
        ))
      SET drcd_dbca_tgt_file = "dm2_dbca_seeded_template_admin_19.dbc"
     ELSE
      SET logical file_name value(build(deir_src_tmp_full_dir,cnvtlower(build(
          "dm2_dbca_seeded_template_",drrr_rf_data->tgt_db_create_type,"_19.dbc"))))
      SET drcd_dbca_tgt_file = cnvtlower(build("dm2_dbca_seeded_template_",drrr_rf_data->
        tgt_db_create_type,"_19.dbc"))
     ENDIF
    ENDIF
    DEFINE rtl2 "file_name"  WITH nomodify
    SET dm_err->eproc = concat("Creating customized remote DBCA template (",drcd_dbca_tgt_file,").")
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO build("CCLUSERDIR:",drcd_dbca_tgt_file)
     FROM rtl2t r
     HEAD REPORT
      db_platform_len = 0, db_platform = "XXX", db_platform_pos = 0
     DETAIL
      deir_temp_line = replace(r.line,"[[Cern_dbca_template_name]]",build("v500db_",cnvtlower(
         dm_env_import_request->target_database_name),"_dbca.dbt"),0), deir_temp_line = replace(
       deir_temp_line,"[[Cern_characterSet]]",build(dm_env_import_request->character_set),0),
      deir_temp_line = replace(deir_temp_line,"[[oracle_base]]",build(dm_env_import_request->
        db_oracle_base),0),
      deir_temp_line = replace(deir_temp_line,"[[asm_storage_dg]]",build(dm_env_import_request->
        asm_storage_disk_group),0), deir_temp_line = replace(deir_temp_line,"[[asm_recovery_dg]]",
       build(dm_env_import_request->asm_recovery_disk_group),0), deir_temp_line = replace(
       deir_temp_line,"[[log_archive_dest_1]]",build(dm_env_import_request->log_archive_dest_1),0),
      deir_temp_line = replace(deir_temp_line,"[[shared_pool_size]]",build(drrr_rf_data->
        tgt_shared_pool_size),0)
      IF ((dm_env_import_request->major_tgt_ora_ver_int >= 12))
       deir_temp_line = replace(deir_temp_line,"[[pdb_name]]",build(dm_env_import_request->
         target_database_name),0)
      ENDIF
      deir_temp_line = replace(deir_temp_line,"[[df_dbca_location]]",build(dm_env_import_request->
        tgt_exec_dir),0)
      IF (deir_temp_line=patstring("*<<CERNERPLAT:*"))
       db_platform_pos = findstring("<<",deir_temp_line), db_platform_len = findstring(">>",substring
        ((db_platform_pos+ 14),size(deir_temp_line),deir_temp_line)), db_platform = substring(1,
        db_platform_len,substring(((db_platform_pos+ 14) - 1),size(deir_temp_line),deir_temp_line))
       IF ((db_platform=dm_env_import_request->db_node_op_system))
        CALL print(concat("         ",substring((((db_platform_pos+ 16)+ db_platform_len) - 1),size(
           deir_temp_line),deir_temp_line))), row + 1
       ENDIF
      ELSE
       CALL print(deir_temp_line), row + 1
      ENDIF
     WITH nocounter, maxrow = 1, maxcol = 2000,
      format = variable, formfeed = none
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    FREE DEFINE rtl2
    SET logical file_name "CER_INSTALL:dm2_update_sqlnetora.txt"
    DEFINE rtl2 "file_name"  WITH nomodify
    SET dm_err->eproc = concat("Creating ",build("CCLUSERDIR:v500db_",cnvtlower(dm_env_import_request
       ->target_database_name),"_updsqlnetora.ksh"))
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO build("CCLUSERDIR:v500db_",cnvtlower(dm_env_import_request->target_database_name),
      "_updsqlnetora.ksh")
     FROM rtl2t r
     DETAIL
      CALL print(build(r.line)), row + 1
     WITH nocounter, maxrow = 1, maxcol = 2001,
      format = variable, formfeed = none
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    FREE DEFINE rtl2
   ENDIF
   SET dm_err->disp_dcl_err_ind = 0
   CALL dm2_push_dcl("rm $CCLUSERDIR/tnsnames.ora")
   SET dm_err->err_ind = 0
   IF (dm_env_import_request->local_ind)
    IF (dm2_push_dcl(concat("cp ",build(dm_env_import_request->db_oracle_home,"/network/admin/"),
      "tnsnames.ora ",build(trim(logical("ccluserdir")))))=0)
     RETURN(0)
    ENDIF
   ELSE
    SET dm2ftpr->user_name = "oracle"
    SET dm2ftpr->remote_host = dm_env_import_request->remote_node_name
    SET dm2ftpr->options = "-b"
    CALL dfr_add_getops_line(" "," "," "," "," ",
     1)
    CALL dfr_add_getops_line(" ",build(trim(logical("ccluserdir")),"/"),"tnsnames.ora",build(
      dm_env_import_request->db_oracle_home,"/network/admin/"),"tnsnames.ora",
     0)
    IF (dfr_get_file(null)=0)
     RETURN(0)
    ENDIF
    CALL dfr_add_getops_line(" "," "," "," "," ",
     1)
   ENDIF
   IF ( NOT (dm2_findfile("$CCLUSERDIR/tnsnames.ora")))
    SET dm_err->eproc =
    "Attempting to copy tnsnames.ora file from Target database node $ORACLE_HOME location to CCLUSERDIR"
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "ERROR: tnsnames.ora was not found in CCLUSERDIR."
    RETURN(0)
   ENDIF
   IF ( NOT (dtr_parse_tns(build(trim(logical("ccluserdir")),"/"),"")))
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(tnswork)
   ENDIF
   FOR (drcd_iter = 1 TO tnswork->cnt)
     IF (tnswork->qual[drcd_iter].chg_format_ind)
      SET tnswork->qual[drcd_iter].merge_ind = 1
      SET drcd_format_chg_ind = 1
     ENDIF
   ENDFOR
   IF ( NOT (dtr_merge_to_tnstgt(null)))
    RETURN(0)
   ENDIF
   IF ( NOT (dtr_reset_tnswork(null)))
    RETURN(0)
   ENDIF
   IF (drcd_format_chg_ind)
    IF (deir_display_tns_report(drcd_format_chg_ind)=0)
     RETURN(0)
    ENDIF
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Verify the TNS stanzas formatted correctly in ",build(
      dm_env_import_request->db_oracle_home,"/network/admin/tnsnames.ora"),
     " on Target database node ",dm_env_import_request->remote_node_name,".")
    SET dm_err->emsg = concat(
     "TNS stanzas were found to have formatting (spacing) issues that will cause Oracle's DBCA ",
     "utility to fail when creating the database.  Review $CCLUSERDIR/tnsmerge.ora file (on local app node) for the ",
     "offending TNS stanzas.  The required spaces have already been added to the reported stanzas.  Please merge all ",
     "the corrected stanzas from this report to ",build(dm_env_import_request->db_oracle_home,
      "/network/admin/tnsnames.ora"),
     " and restart the database shell creation process.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Copying shell creation scripts to target execution directory"
   CALL disp_msg("",dm_err->logfile,0)
   IF (dm_env_import_request->local_ind)
    SET drcd_cmd = concat("cp ",build(trim(logical("ccluserdir"))),"/v500db_",cnvtlower(build(
       dm_env_import_request->target_database_name)),"* ",
     build(dm_env_import_request->tgt_exec_dir))
    IF (dm2_push_dcl(drcd_cmd)=0)
     RETURN(0)
    ENDIF
    SET drcd_cmd = concat("chmod 777 ",build(dm_env_import_request->tgt_exec_dir),"/v500db_",
     cnvtlower(build(dm_env_import_request->target_database_name)),"*")
    IF (dm2_push_dcl(drcd_cmd)=0)
     RETURN(0)
    ENDIF
   ELSE
    SET dm2ftpr->user_name = dm_env_import_request->ftp_user_name
    SET dm2ftpr->remote_host = dm_env_import_request->remote_node_name
    SET dm2ftpr->dir_name = dm_env_import_request->tgt_exec_dir
    SET dm2ftpr->options = "-b"
    CALL dfr_add_putops_line(" "," "," "," "," ",
     1)
    CALL dfr_add_putops_line(" ",build(trim(logical("ccluserdir")),"/"),concat("v500db_",cnvtlower(
       build(dm_env_import_request->target_database_name)),"_create.ksh"),concat(
      dm_env_import_request->tgt_exec_dir,"/"),concat("v500db_",cnvtlower(build(dm_env_import_request
        ->target_database_name)),"_create.ksh"),
     0)
    IF ((drrr_rf_data->tgt_db_create_type="SHELL"))
     CALL dfr_add_putops_line(" ",build(trim(logical("ccluserdir")),"/"),concat("v500db_",cnvtlower(
        build(dm_env_import_request->target_database_name)),"_dbca.dbt"),concat(dm_env_import_request
       ->tgt_exec_dir,"/"),concat("v500db_",cnvtlower(build(dm_env_import_request->
         target_database_name)),"_dbca.dbt"),
      0)
    ELSE
     IF ((drrr_misc_data->process_mode="ADMIN DATABASE CREATION"))
      CALL dfr_add_putops_line(" ",build(trim(logical("ccluserdir")),"/"),
       "dm2_dbca_seeded_template_admin_19.dbc",concat(dm_env_import_request->tgt_exec_dir,"/"),
       "dm2_dbca_seeded_template_admin_19.dbc",
       0)
      CALL dfr_add_putops_line(" ",deir_src_tmp_full_dir,"dm2_dbca_seeded_template_admin_19.ctl",
       concat(dm_env_import_request->tgt_exec_dir,"/"),"dm2_dbca_seeded_template_admin_19.ctl",
       0)
      IF (deir_rrr_get_nbr_list(deir_src_tmp_full_dir,"dm2_dbca_seeded_template_admin_19.dfb",
       drcd_nbr_list)=0)
       RETURN(0)
      ELSE
       SET drcd_idx = 1
       WHILE (drcd_nbr != drcd_notfnd)
         SET drcd_nbr = piece(drcd_nbr_list,",",drcd_idx,drcd_notfnd)
         SET drcd_idx = (drcd_idx+ 1)
         IF (drcd_nbr != drcd_notfnd)
          CALL dfr_add_putops_line(" ",deir_src_tmp_full_dir,build(
            "dm2_dbca_seeded_template_admin_19.dfb",drcd_nbr),concat(dm_env_import_request->
            tgt_exec_dir,"/"),build("dm2_dbca_seeded_template_admin_19.dfb",drcd_nbr),
           0)
         ENDIF
       ENDWHILE
      ENDIF
     ELSE
      CALL dfr_add_putops_line(" ",build(trim(logical("ccluserdir")),"/"),cnvtlower(build(
         "dm2_dbca_seeded_template_",drrr_rf_data->tgt_db_create_type,"_19.dbc")),concat(
        dm_env_import_request->tgt_exec_dir,"/"),cnvtlower(build("dm2_dbca_seeded_template_",
         drrr_rf_data->tgt_db_create_type,"_19.dbc")),
       0)
      CALL dfr_add_putops_line(" ",deir_src_tmp_full_dir,cnvtlower(build("dm2_dbca_seeded_template_",
         drrr_rf_data->tgt_db_create_type,"_19.ctl")),concat(dm_env_import_request->tgt_exec_dir,"/"),
       cnvtlower(build("dm2_dbca_seeded_template_",drrr_rf_data->tgt_db_create_type,"_19.ctl")),
       0)
      IF (deir_rrr_get_nbr_list(deir_src_tmp_full_dir,cnvtlower(build("dm2_dbca_seeded_template_",
         drrr_rf_data->tgt_db_create_type,"_19.dfb")),drcd_nbr_list)=0)
       RETURN(0)
      ELSE
       SET drcd_idx = 1
       WHILE (drcd_nbr != drcd_notfnd)
         SET drcd_nbr = piece(drcd_nbr_list,",",drcd_idx,drcd_notfnd)
         SET drcd_idx = (drcd_idx+ 1)
         IF (drcd_nbr != drcd_notfnd)
          CALL dfr_add_putops_line(" ",deir_src_tmp_full_dir,cnvtlower(build(
             "dm2_dbca_seeded_template_",drrr_rf_data->tgt_db_create_type,"_19.dfb",drcd_nbr)),concat
           (dm_env_import_request->tgt_exec_dir,"/"),cnvtlower(build("dm2_dbca_seeded_template_",
             drrr_rf_data->tgt_db_create_type,"_19.dfb",drcd_nbr)),
           0)
         ENDIF
       ENDWHILE
      ENDIF
     ENDIF
    ENDIF
    CALL dfr_add_putops_line(" ",build(trim(logical("ccluserdir")),"/"),concat("v500db_",cnvtlower(
       build(dm_env_import_request->target_database_name)),"_updsqlnetora.ksh"),concat(
      dm_env_import_request->tgt_exec_dir,"/"),concat("v500db_",cnvtlower(build(dm_env_import_request
        ->target_database_name)),"_updsqlnetora.ksh"),
     0)
    IF (dfr_put_file(null)=0)
     RETURN(0)
    ENDIF
    CALL dfr_add_putops_line(" "," "," "," "," ",
     1)
   ENDIF
   IF (get_unique_file("dm2credbshellksh",".err")=0)
    RETURN(0)
   ELSE
    SET drcd_ksh_err_file = dm_err->unique_fname
    SET dm_err->errfile = dm_err->unique_fname
   ENDIF
   IF (dm_env_import_request->local_ind)
    SET dm_err->eproc = concat(
     "On the current node, as the ORACLE user, executing ksh script v500db_",cnvtlower(build(
       dm_env_import_request->target_database_name)),"_create.ksh from ",dm_env_import_request->
     tgt_exec_dir,
     " to create the database.  Output from ksh file execution will be stored in CCLUSERDIR, file ",
     build(dm_err->errfile),".  Executing ksh...")
    CALL disp_msg("",dm_err->logfile,0)
    SET drcd_cmd = concat("su - oracle -c ",dm_env_import_request->tgt_exec_dir,"/v500db_",cnvtlower(
      build(dm_env_import_request->target_database_name)),"_create.ksh")
   ELSE
    SET dm_err->eproc = concat("On the remote node (",build(dm_env_import_request->remote_node_name),
     "), as the ORACLE user, executing ksh script v500db_",cnvtlower(build(dm_env_import_request->
       target_database_name)),"_create.ksh from ",
     dm_env_import_request->tgt_exec_dir,
     " to create the database.  Output from ksh file execution will be stored in CCLUSERDIR, file ",
     build(dm_err->errfile),".  Executing ksh...")
    CALL disp_msg("",dm_err->logfile,0)
    SET drcd_cmd = concat("su - oracle -c 'ssh oracle@",dm_env_import_request->remote_node_name," ",
     dm_env_import_request->tgt_exec_dir,"/v500db_",
     cnvtlower(build(dm_env_import_request->target_database_name)),"_create.ksh'")
   ENDIF
   SET dm_err->disp_dcl_err_ind = 0
   IF (dm2_push_dcl(drcd_cmd)=0)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   SET dm_err->errfile = "NONE"
   IF (findstring("CER-00000",cnvtupper(dm_err->errtext),1,0) > 0)
    SET drcd_fatal_err = 1
    IF (findstring("DBCA CREATE DATABASE FAILED",cnvtupper(dm_err->errtext),1,0) > 0)
     SET drcd_ksh_error = concat("Review DBCA log file (",cnvtlower(build(dm_env_import_request->
        db_oracle_base,"/cfgtoollogs/dbca/",dm_env_import_request->target_database_name,"/",
        dm_env_import_request->target_database_name,
        ".log)"))," on Target database node (",dm_env_import_request->remote_node_name,
      ") for more details.")
    ELSE
     SET drcd_ksh_error = concat("Fatal error:  ",substring(findstring("CER-00000",cnvtupper(dm_err->
         errtext),1,1),(size(dm_err->errtext) - findstring("CER-00000",cnvtupper(dm_err->errtext),1,1
        )),dm_err->errtext),".")
    ENDIF
   ENDIF
   IF (drcd_fatal_err=0)
    IF (((deir_error_prefixes="DM2NOTSET") OR (size(trim(deir_error_prefixes,3))=0)) )
     SET deir_error_prefixes = '"ORA-","PRKO-"'
    ENDIF
    IF (findstring('"',deir_error_prefixes,1,0) > 0
     AND findstring('"',deir_error_prefixes,1,0) != findstring('"',deir_error_prefixes,1,1))
     WHILE (drcd_str != drcd_notfnd)
      SET drcd_str = piece(deir_error_prefixes,",",drcd_num,drcd_notfnd)
      IF (drcd_str != drcd_notfnd)
       IF (findstring('"',drcd_str,1,0) != findstring('"',drcd_str,1,1))
        SET drcd_error_prefix = trim(replace(drcd_str,'"',"",0),3)
        IF (size(trim(drcd_error_prefix,3)) > 0)
         SET drcd_error_pref_rs->cnt = (drcd_error_pref_rs->cnt+ 1)
         SET stat = alterlist(drcd_error_pref_rs->qual,drcd_error_pref_rs->cnt)
         SET drcd_error_pref_rs->qual[drcd_error_pref_rs->cnt].prefix = drcd_error_prefix
         SET drcd_num = (drcd_num+ 1)
        ELSE
         SET dm_err->err_ind = 1
         SET dm_err->eproc = concat("Validating override error prefixes: ",deir_error_prefixes)
         SET dm_err->emsg = concat("Individual override error prefix in position ",trim(cnvtstring(
            drcd_num),3)," not properly set.")
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
       ELSE
        SET dm_err->err_ind = 1
        SET dm_err->eproc = concat("Validating override error prefixes: ",deir_error_prefixes)
        SET dm_err->emsg = concat("Individual override error prefix (",trim(drcd_str,3),
         ") not wrapped in double-quotes.")
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
     ENDWHILE
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Validating override error prefixes: ",deir_error_prefixes)
     SET dm_err->emsg = concat(
      "Individual override error prefixes does not contain any double-quotes or pairs.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Accessing ksh error file..."
    FREE SET drcd_error_file
    SET logical drcd_error_file drcd_ksh_err_file
    FREE DEFINE rtl3
    DEFINE rtl3 "drcd_error_file"
    SELECT INTO "nl:"
     t.line
     FROM rtl3t t
     WHERE t.line > " "
     DETAIL
      IF (trim(t.line) > "")
       drcd_file_content->cnt = (drcd_file_content->cnt+ 1), stat = alterlist(drcd_file_content->qual,
        drcd_file_content->cnt), drcd_file_content->qual[drcd_file_content->cnt].line = trim(t.line)
      ENDIF
     WITH nocounter
    ;end select
    FREE SET drcd_error_file
    FREE DEFINE rtl3
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(drcd_file_content)
    ENDIF
    FOR (drcd_line = 1 TO drcd_file_content->cnt)
      FOR (drcd_cnt = 1 TO drcd_error_pref_rs->cnt)
        IF (findstring(drcd_error_pref_rs->qual[drcd_cnt].prefix,drcd_file_content->qual[drcd_line].
         line,1,0) > 0)
         SET drcd_ignore_err = 0
         FOR (drcd_cnt2 = 1 TO drrr_misc_data->tgt_shell_ign_error_cnt)
           IF (findstring(drrr_misc_data->tgt_shell_ign_errors[drcd_cnt2].error_cd,drcd_file_content
            ->qual[drcd_line].line,1,0) > 0)
            SET drcd_ignore_err = 1
            SET drcd_cnt2 = drrr_misc_data->tgt_shell_ign_error_cnt
           ENDIF
         ENDFOR
         IF (drcd_ignore_err=0)
          FOR (drcd_scnt = 1 TO dcds_ignore_stack->cnt)
            IF (findstring(dcds_ignore_stack->qual[drcd_scnt].skey,trim(cnvtupper(drcd_file_content->
               qual[drcd_line].line)),1,0) > 0
             AND ((drcd_line+ 1) <= drcd_file_content->cnt))
             FOR (drcd_scnt2 = 1 TO dcds_ignore_stack->qual[drcd_scnt].icnt)
               IF (findstring(dcds_ignore_stack->qual[drcd_scnt].ignore[drcd_scnt2].str,trim(
                 cnvtupper(drcd_file_content->qual[(drcd_line+ 1)].line)),1,0) > 0)
                SET drcd_ignore_err = 1
                SET drcd_scnt2 = dcds_ignore_stack->qual[drcd_scnt].icnt
                SET drcd_scnt = dcds_ignore_stack->cnt
               ENDIF
             ENDFOR
            ENDIF
          ENDFOR
          IF (drcd_ignore_err=0)
           SET drcd_fatal_err = 1
           SET drcd_cnt = drcd_error_pref_rs->cnt
           SET drcd_line = drcd_file_content->cnt
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
    ENDFOR
    IF (drcd_fatal_err=1)
     SET drcd_ksh_error = concat("Review ksh log file ($CCLUSERDIR/",drcd_ksh_err_file,
      "), on Target app node (",trim(curnode),") for more details.")
    ENDIF
   ENDIF
   IF (drcd_fatal_err=1)
    SET drer_email_det->msgtype = "PROGRESS"
    SET drer_email_det->status = "REPORT"
    SET drer_email_det->status_dt_tm = cnvtdatetime(curdate,curtime3)
    SET drer_email_det->step = "Create Database Shell Error Report"
    SET drer_email_det->email_level = 1
    SET drer_email_det->logfile = dm_err->logfile
    SET drer_email_det->err_ind = dm_err->err_ind
    SET drer_email_det->eproc = dm_err->eproc
    SET drer_email_det->emsg = dm_err->emsg
    SET drer_email_det->user_action = dm_err->user_action
    CALL drer_add_body_text(concat("Create Database Shell Error Report was generated at ",format(
       drer_email_det->status_dt_tm,";;q")),1)
    CALL drer_add_body_text(concat("User Action : Please review the error report to ensure ",
      "subsequent execution completes successfully."),0)
    CALL drer_add_body_text(concat("Error Report file name (in CCLUSERDIR) : ",drcd_ksh_err_file),0)
    SET drer_email_det->attachment = build(dm2_install_schema->ccluserdir,drcd_ksh_err_file)
    IF (drer_compose_email(null)=1)
     CALL drer_send_email(drer_email_det->subject,drer_email_det->file_name,drer_email_det->
      email_level)
    ENDIF
    CALL drer_reset_pre_err(null)
    SET dm_err->eproc = concat("Executing ksh script v500db_",cnvtlower(build(dm_env_import_request->
       target_database_name)),"_create.ksh from ",dm_env_import_request->tgt_exec_dir,
     " on Target database node (",
     build(dm_env_import_request->remote_node_name),") to create the database.")
    SET dm_err->emsg = concat("Error(s) detected during ksh execution.  ",drcd_ksh_error,
     "  Resolve errors and restart the database shell creation process.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF (findstring("DATABASE CREATION SUCCESSFUL",cnvtupper(dm_err->errtext),1,0) > 0)
    SET dm_err->eproc = concat("Execution of ksh script v500db_",cnvtlower(build(
       dm_env_import_request->target_database_name)),"_create.ksh from ",dm_env_import_request->
     tgt_exec_dir," on Target database node (",
     build(dm_env_import_request->remote_node_name),") to create the database was successful.")
    CALL disp_msg("",dm_err->logfile,0)
   ELSE
    SET dm_err->eproc = concat("Executing ksh script v500db_",cnvtlower(build(dm_env_import_request->
       target_database_name)),"_create.ksh from ",dm_env_import_request->tgt_exec_dir,
     " on Target database node (",
     build(dm_env_import_request->remote_node_name),") to create the database.")
    SET dm_err->emsg = concat(
     "Unable to verify successful execution of ksh file.  Command executed:  ",build(drcd_cmd),".")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Verify Target database node connection for (",build(
     dm_env_import_request->target_database_name),") connect string.")
   CALL disp_msg("",dm_err->logfile,0)
   IF (deir_rrr_chk_connect(dm_env_import_request->remote_node_name,dm_env_import_request->
    db_oracle_home,dm_env_import_request->tgt_exec_dir,"sys",dm_env_import_request->sys_pwd,
    build(dm_env_import_request->target_database_name),dm_env_import_request->target_database_name,
    dm_env_import_request->remote_node_name,dm_env_import_request->target_oracle_version)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Verify Target database node connection for (",build(
     dm_env_import_request->target_database_name,"1"),") connect string.")
   CALL disp_msg("",dm_err->logfile,0)
   IF (deir_rrr_chk_connect(dm_env_import_request->remote_node_name,dm_env_import_request->
    db_oracle_home,dm_env_import_request->tgt_exec_dir,"sys",dm_env_import_request->sys_pwd,
    build(dm_env_import_request->target_database_name,"1"),dm_env_import_request->
    target_database_name,dm_env_import_request->remote_node_name,dm_env_import_request->
    target_oracle_version)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE deir_rrr_app_tns_cnct_work(dratw_mode)
   DECLARE dratw_num = i4 WITH protect, noconstant(1)
   DECLARE dratw_local = i2 WITH protect, noconstant(0)
   DECLARE dratw_file_name = vc WITH protect, noconstant("")
   DECLARE dratw_chk = i2 WITH protect, noconstant(0)
   DECLARE dratw_iter = i4 WITH protect, noconstant(0)
   DECLARE dratw_iter2 = i4 WITH protect, noconstant(0)
   DECLARE dratw_text_nospaces = vc WITH protect, noconstant("")
   DECLARE dratw_hfnd = i2 WITH protect, noconstant(0)
   DECLARE dratw_pfnd = i2 WITH protect, noconstant(0)
   DECLARE dratw_cmd = vc WITH protect, noconstant("")
   DECLARE dratw_db_name = vc WITH protect, noconstant("")
   DECLARE dratw_db_tns_entry = vc WITH protect, noconstant("")
   DECLARE dratw_db_cnct_str = vc WITH protect, noconstant("")
   DECLARE dratw_svc_name = vc WITH protect, noconstant("")
   DECLARE dratw_svcfnd = i2 WITH protect, noconstant(0)
   DECLARE dratw_tns_entry = vc WITH protect, noconstant("")
   DECLARE dratw_tns_svc_name = vc WITH protect, noconstant("")
   DECLARE dratw_tns_port = vc WITH protect, noconstant("")
   DECLARE dratw_tns_host = vc WITH protect, noconstant("")
   DECLARE dratw_tns_svc_idx = i4 WITH protect, noconstant(0)
   DECLARE dratw_tns_fnd_ind = i4 WITH protect, noconstant(0)
   DECLARE dratw_tns_idx = i4 WITH protect, noconstant(0)
   DECLARE dratw_tns_entries_list = vc WITH protect, noconstant("")
   DECLARE dratw_tns_key = vc WITH protect, noconstant("")
   FREE RECORD dratw_tns_map
   RECORD dratw_tns_map(
     1 cnt = i4
     1 map[*]
       2 fnd_ind = i2
   )
   SET dratw_tns_map->cnt = drrr_misc_data->tgt_tns_map_cnt
   SET stat = alterlist(dratw_tns_map->map,dratw_tns_map->cnt)
   SET dm_err->eproc = concat("Target App TNS Management (",evaluate(dratw_mode,1,
     "Check Target Database Stanza(s) Format Only",2,"Add Target Database Stanza(s)",
     "Target Database Stanza(s) Connection Check"),").")
   CALL disp_msg("",dm_err->logfile,0)
   SET dratw_db_name = dm_env_import_request->target_database_name
   FOR (dratw_num = 1 TO drrr_misc_data->tgt_app_node_cnt)
     SET dratw_tns_entries_list = ""
     IF (cnvtupper(drrr_misc_data->tgt_app_nodes[dratw_num].node_name)=cnvtupper(build(curnode)))
      SET dratw_local = 1
     ELSE
      SET dratw_local = 0
     ENDIF
     SET dm_err->eproc = concat("Verifying that tnsnames.ora file exists in ",build(
       dm_env_import_request->local_oracle_home_log,"/network/admin")," on ",build(drrr_misc_data->
       tgt_app_nodes[dratw_num].node_name)," node.")
     CALL disp_msg("",dm_err->logfile,0)
     CALL dor_init_flex_cmds(null)
     CALL dor_add_flex_cmd(dratw_local,"oracle",drrr_misc_data->tgt_app_nodes[dratw_num].node_name,
      " ",concat("test -f ",build(dm_env_import_request->local_oracle_home_log,
        "/network/admin/tnsnames.ora")," ;echo $?"),
      " ","EC")
     IF (dor_exec_flex_cmd(null)=0)
      RETURN(0)
     ENDIF
     IF (trim(dor_flex_cmd->cmd[1].flex_output,3)="1")
      SET dm_err->err_ind = 1
      SET dm_err->eproc = concat("Verifying that tnsnames.ora file exists in ",build(
        dm_env_import_request->local_oracle_home_log,"/network/admin")," on ",build(drrr_misc_data->
        tgt_app_nodes[dratw_num].node_name)," node.")
      SET dm_err->emsg = concat(
       "Tnsnames.ora file not found.  Please verify Oracle Home (all application nodes ",
       "should have the same Oracle Home path) and restart.")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET dm_err->disp_dcl_err_ind = 0
     CALL dm2_push_dcl("rm $CCLUSERDIR/tnsnames.ora")
     SET dm_err->err_ind = 0
     SET dm_err->eproc = concat("Copy tnsnames.ora file from Target app node (",build(drrr_misc_data
       ->tgt_app_nodes[dratw_num].node_name),") $ORACLE_HOME location to local CCLUSDERDIR.")
     CALL disp_msg(" ",dm_err->logfile,0)
     IF (dratw_local=0)
      SET dm2ftpr->user_name = "oracle"
      SET dm2ftpr->remote_host = drrr_misc_data->tgt_app_nodes[dratw_num].node_name
      SET dm2ftpr->options = "-b"
      CALL dfr_add_getops_line(" "," "," "," "," ",
       1)
      CALL dfr_add_getops_line(" ",build(trim(logical("ccluserdir")),"/"),"tnsnames.ora",build(
        dm_env_import_request->local_oracle_home_log,"/network/admin/"),"tnsnames.ora",
       0)
      IF (dfr_get_file(null)=0)
       RETURN(0)
      ENDIF
      CALL dfr_add_getops_line(" "," "," "," "," ",
       1)
     ELSE
      IF (dm2_push_dcl(concat("cp ",build(dm_env_import_request->local_oracle_home_log,
         "/network/admin/"),"tnsnames.ora ",build(trim(logical("ccluserdir")))))=0)
       RETURN(0)
      ENDIF
     ENDIF
     IF ( NOT (dm2_findfile("$CCLUSERDIR/tnsnames.ora")))
      SET dm_err->eproc = concat("Attempting to copy tnsnames.ora file from Target app node (",build(
        drrr_misc_data->tgt_app_nodes[dratw_num].node_name),
       ") $ORACLE_HOME location to local CCLUSDERDIR.")
      SET dm_err->err_ind = 1
      SET dm_err->emsg = "ERROR: tnsnames.ora was not found in CCLUSERDIR."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF ( NOT (dtr_parse_tns(build(trim(logical("ccluserdir")),"/"),"")))
      RETURN(0)
     ENDIF
     IF ((dm_err->debug_flag > 0))
      CALL echorecord(tnswork)
     ENDIF
     FOR (dratw_iter = 1 TO tnswork->cnt)
       SET dratw_chk = 0
       IF ((drrr_rf_data->tgt_db_deploy_config="OP"))
        SET drsc_temp_string = replace(cnvtupper(tnswork->qual[dratw_iter].tns_key),cnvtupper(
          dratw_db_name),"")
        IF (((cnvtint(drsc_temp_string) BETWEEN 1 AND dm_env_import_request->remote_hosts_cnt) OR (
        size(trim(tnswork->qual[dratw_iter].tns_key,3)) > 0
         AND size(trim(drsc_temp_string,3))=0)) )
         SET dratw_chk = 1
        ENDIF
       ENDIF
       SET dratw_tns_svc_idx = 0
       SET dratw_tns_svc_idx = locateval(dratw_tns_svc_idx,1,drrr_misc_data->tgt_tns_map_cnt,
        cnvtlower(trim(tnswork->qual[dratw_iter].tns_key_full,3)),cnvtlower(drrr_misc_data->
         tgt_tns_map[dratw_tns_svc_idx].tns_entry))
       IF (((dratw_tns_svc_idx > 0) OR (dratw_chk=1)) )
        IF (dratw_tns_svc_idx > 0)
         SET dratw_tns_map->map[dratw_tns_svc_idx].fnd_ind = 1
         SET dratw_tns_host = drrr_misc_data->tgt_tns_map[dratw_tns_svc_idx].host
         SET dratw_tns_port = drrr_misc_data->tgt_tns_map[dratw_tns_svc_idx].port
         SET dratw_tns_svc_name = drrr_misc_data->tgt_tns_map[dratw_tns_svc_idx].service_name
        ENDIF
        IF (dratw_chk=1)
         SET dratw_tns_host = dm_env_import_request->target_tns_host
         SET dratw_tns_port = dm_env_import_request->target_tns_port
         SET dratw_tns_svc_name = build("s",dratw_db_name,".world")
        ENDIF
        SET dm_err->eproc = concat('Verify "host" and "port" values for Target app node (',build(
          drrr_misc_data->tgt_app_nodes[dratw_num].node_name),
         ") $ORACLE_HOME/network/admin/tnsnames.ora file, Net Services Name (",trim(tnswork->qual[
          dratw_iter].tns_key_full,3),").")
        CALL disp_msg("",dm_err->logfile,0)
        SET dratw_hfnd = 0
        SET dratw_pfnd = 0
        SET dratw_svcfnd = 0
        FOR (dratw_iter2 = 1 TO tnswork->qual[dratw_iter].line_cnt)
          SET dratw_text_nospaces = cnvtlower(trim(tnswork->qual[dratw_iter].qual[dratw_iter2].text,4
            ))
          IF (findstring("host=",dratw_text_nospaces) > 0)
           IF (findstring(build("host=",cnvtlower(trim(dratw_tns_host))),dratw_text_nospaces)=0)
            SET dm_err->err_ind = 1
            SET dm_err->eproc = concat('Verify "host" value for Target app node (',build(
              drrr_misc_data->tgt_app_nodes[dratw_num].node_name),
             ") $ORACLE_HOME/network/admin/tnsnames.ora file, Net Services Name (",trim(tnswork->
              qual[dratw_iter].tns_key_full,3),").")
            SET dm_err->emsg = concat('"Host" value specified for Net Service Name (',trim(tnswork->
              qual[dratw_iter].tns_key_full,3),
             ") in tnsnames.ora file does not match Target tns host (",trim(dratw_tns_host),
             ').  Please perform necessary cleanup and restart.  The "host=" line in question is:  ',
             trim(tnswork->qual[dratw_iter].qual[dratw_iter2].text,3),".")
            CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
            RETURN(0)
           ELSE
            SET dratw_hfnd = 1
           ENDIF
          ENDIF
          IF (findstring("port=",dratw_text_nospaces) > 0)
           IF (findstring(build("port=",cnvtlower(trim(dratw_tns_port))),dratw_text_nospaces)=0)
            SET dm_err->err_ind = 1
            SET dm_err->eproc = concat('Verify "port" value for Target app node (',build(
              drrr_misc_data->tgt_app_nodes[dratw_num].node_name),
             ") $ORACLE_HOME/network/admin/tnsnames.ora file, Net Services Name (",trim(tnswork->
              qual[dratw_iter].tns_key_full,3),").")
            SET dm_err->emsg = concat('"Port" value specified for Net Service Name (',trim(tnswork->
              qual[dratw_iter].tns_key_full,3),
             ") in tnsnames.ora file does not match Target tns port (",trim(dratw_tns_port),
             ').  Please perform necessary cleanup and restart.  The "port=" line in question is:  ',
             trim(tnswork->qual[dratw_iter].qual[dratw_iter2].text,3),".")
            CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
            RETURN(0)
           ELSE
            SET dratw_pfnd = 1
           ENDIF
          ENDIF
          IF ((dm_env_import_request->major_tgt_ora_ver_int >= 12))
           IF ((dm_err->debug_flag > 3))
            CALL echo(build("dratw_text_nospaces=",dratw_text_nospaces))
           ENDIF
           IF (findstring("service_name=",dratw_text_nospaces) > 0)
            IF ((dm_err->debug_flag > 3))
             CALL echo(build("service_name=",cnvtlower(dratw_tns_svc_name)))
            ENDIF
            IF (findstring(build("service_name=",cnvtlower(dratw_tns_svc_name)),dratw_text_nospaces)=
            0)
             SET dm_err->err_ind = 1
             SET dm_err->eproc = concat('Verify "service_name" value for Target app node (',build(
               drrr_misc_data->tgt_app_nodes[dratw_num].node_name),
              ") $ORACLE_HOME/network/admin/tnsnames.ora file, Net Services Name (",trim(tnswork->
               qual[dratw_iter].tns_key_full,3),").")
             SET dm_err->emsg = concat('"service_name" value specified for Net Service Name (',trim(
               tnswork->qual[dratw_iter].tns_key_full,3),
              ") in tnsnames.ora file does not match Target tns service_name (",cnvtlower(
               dratw_tns_svc_name),
              ').  Please perform necessary cleanup and restart.  The "service_name=" line in question is:  ',
              trim(tnswork->qual[dratw_iter].qual[dratw_iter2].text,3),".")
             CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
             RETURN(0)
            ELSE
             SET dratw_svcfnd = 1
             IF ((dm_err->debug_flag > 3))
              CALL echo(build("dratw_svcfnd =",dratw_svcfnd))
             ENDIF
            ENDIF
           ENDIF
          ENDIF
        ENDFOR
        IF (((dratw_hfnd=0) OR (dratw_pfnd=0)) )
         SET dm_err->err_ind = 1
         SET dm_err->emsg = concat('"Host" and/or "Port" strings for Net Service Name (',trim(tnswork
           ->qual[dratw_iter].tns_key_full,3),
          ") in tnsnames.ora file could not be found or not set to correct values.  ",
          "Please perform necessary corrections and restart.")
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
        IF ((dm_env_import_request->major_tgt_ora_ver_int >= 12))
         IF (dratw_svcfnd=0)
          SET dm_err->err_ind = 1
          SET dm_err->emsg = concat('"service_name" strings for Net Service Name (',trim(tnswork->
            qual[dratw_iter].tns_key_full,3),
           ") in tnsnames.ora file could not be found or not set to correct values.  ",
           "Please perform necessary corrections and restart.")
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          RETURN(0)
         ENDIF
        ENDIF
        IF (dratw_mode=3)
         SET dm_err->eproc = concat("Verify sys database user connection on Target app node (",build(
           drrr_misc_data->tgt_app_nodes[dratw_num].node_name),
          ") using $ORACLE_HOME/network/admin/tnsnames.ora file Net Services Name (",trim(tnswork->
           qual[dratw_iter].tns_key_full,3),").")
         CALL disp_msg("",dm_err->logfile,0)
         SET dratw_tns_key = evaluate(tnswork->qual[dratw_iter].tns_key,"",tnswork->qual[dratw_iter].
          tns_key_full,tnswork->qual[dratw_iter].tns_key)
         IF ((dm_err->debug_flag > 0))
          CALL echo(concat("dratw_tns_key:",dratw_tns_key))
         ENDIF
         IF (deir_rrr_chk_connect(drrr_misc_data->tgt_app_nodes[dratw_num].node_name,
          dm_env_import_request->local_oracle_home_log,logical("ccluserdir"),dm_env_import_request->
          sys_user,dm_env_import_request->sys_pwd,
          dratw_tns_key,dratw_db_name,dm_env_import_request->remote_node_name,dm_env_import_request->
          target_oracle_version)=0)
          RETURN(0)
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
     IF ( NOT (dtr_reset_tnswork(null)))
      RETURN(0)
     ENDIF
     IF ((dm_err->debug_flag > 0))
      CALL echorecord(dratw_tns_map)
     ENDIF
     IF (dratw_mode=3)
      IF (locateval(dratw_tns_fnd_ind,1,dratw_tns_map->cnt,0,dratw_tns_map->map[dratw_tns_fnd_ind].
       fnd_ind) > 0)
       FOR (dratw_tns_idx = 1 TO dratw_tns_map->cnt)
        SET dratw_tns_entries_list = evaluate(dratw_tns_map->map[dratw_tns_idx].fnd_ind,0,concat(
          dratw_tns_entries_list,drrr_misc_data->tgt_tns_map[dratw_tns_idx].tns_entry,","),1,
         dratw_tns_entries_list)
        IF ((dm_err->debug_flag > 0))
         CALL echo(concat("dratw_tns_entries_list:",dratw_tns_entries_list))
        ENDIF
       ENDFOR
       SET dratw_tns_entries_list = replace(dratw_tns_entries_list,",","",2)
       SET dm_err->err_ind = 1
       SET dm_err->eproc = concat("Check for Target database (",dratw_tns_entries_list,
        ") entry/entries in Target app (",build(drrr_misc_data->tgt_app_nodes[dratw_num].node_name),
        ") Oracle Home directory (",
        build(dm_env_import_request->local_oracle_home_log,"/network/admin/tnsnames.ora"),").")
       SET dm_err->emsg = concat("Listed TNS entries NOT found in the tnsnames.ora file.")
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
     IF (dratw_mode=2)
      SET dratw_tns_fnd_ind = 0
      IF (locateval(dratw_tns_fnd_ind,1,dratw_tns_map->cnt,0,dratw_tns_map->map[dratw_tns_fnd_ind].
       fnd_ind)=0)
       SET dm_err->eproc = concat("Target database (",build(dratw_db_name),
        ") entries in Target app (",build(drrr_misc_data->tgt_app_nodes[dratw_num].node_name),
        ") Oracle Home directory (",
        build(dm_env_import_request->local_oracle_home_log),
        "/network/admin/tnsnames.ora).  No sync up work needed.")
       CALL disp_msg(" ",dm_err->logfile,0)
      ELSE
       SET dm_err->eproc =
       "Create file to store tns entries to be added to Target app node tnsnames.ora file."
       CALL disp_msg(" ",dm_err->logfile,0)
       IF (get_unique_file("dm2_dbcre_tns",".txt")=0)
        RETURN(0)
       ELSE
        SET dratw_file_name = dm_err->unique_fname
       ENDIF
       SELECT INTO value(dratw_file_name)
        DETAIL
         FOR (dratw_tns_idx = 1 TO dratw_tns_map->cnt)
           IF ((dratw_tns_map->map[dratw_tns_idx].fnd_ind=0))
            dratw_tns_entry = drrr_misc_data->tgt_tns_map[dratw_tns_idx].tns_entry,
            dratw_tns_svc_name = drrr_misc_data->tgt_tns_map[dratw_tns_idx].service_name,
            dratw_tns_host = drrr_misc_data->tgt_tns_map[dratw_tns_idx].host,
            dratw_tns_port = drrr_misc_data->tgt_tns_map[dratw_tns_idx].port,
            CALL print(" "), row + 1,
            CALL print(concat(dratw_tns_entry," =")), row + 1,
            CALL print("  (DESCRIPTION ="),
            row + 1,
            CALL print(concat("    (ADDRESS = (PROTOCOL = TCP)(HOST = ",dratw_tns_host,")(PORT = ",
             dratw_tns_port,"))")), row + 1,
            CALL print("    (CONNECT_DATA ="), row + 1,
            CALL print("      (SERVER = DEDICATED)"),
            row + 1
            IF ((dm_env_import_request->major_tgt_ora_ver_int < 12))
             CALL print(concat("      (SERVICE_NAME = ",dratw_tns_svc_name,")")), row + 1
             IF (dratw_tns_entry=build(dratw_db_name,"1.world"))
              CALL print(concat("      (INSTANCE_NAME = ",build(dratw_db_name,"1.world"),")")), row
               + 1
             ENDIF
            ELSE
             CALL print(concat("      (SERVICE_NAME = ",dratw_tns_svc_name,")")), row + 1
            ENDIF
            CALL print("    )"), row + 1,
            CALL print("  )"),
            row + 1
           ENDIF
         ENDFOR
        WITH nocounter, maxcol = 500, format = variable,
         maxrow = 1
       ;end select
       IF (check_error(dm_err->eproc) != 0)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       SET dm_err->eproc = concat("Append Target database (",build(dratw_db_name),
        ") tns entries to Target app (",build(drrr_misc_data->tgt_app_nodes[dratw_num].node_name),
        ") Oracle Home directory tnsnames file (",
        build(dm_env_import_request->local_oracle_home_log,"/network/admin/tnsnames.ora"),").")
       CALL disp_msg(" ",dm_err->logfile,0)
       IF (dratw_local=0)
        SET dratw_cmd = concat("cat ",build(trim(logical("ccluserdir")),"/",dratw_file_name),
         " | ssh oracle@",build(drrr_misc_data->tgt_app_nodes[dratw_num].node_name)," 'cat >> ",
         build(dm_env_import_request->local_oracle_home_log,"/network/admin/tnsnames.ora"),"'")
       ELSE
        SET dratw_cmd = concat("cat ",build(trim(logical("ccluserdir")),"/",dratw_file_name)," >> ",
         build(dm_env_import_request->local_oracle_home_log,"/network/admin/tnsnames.ora"))
       ENDIF
       SET dm_err->eproc = concat("Executing: ",dratw_cmd)
       CALL disp_msg(" ",dm_err->logfile,0)
       CALL dcl(dratw_cmd,size(dratw_cmd),dm_err->ecode)
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE deir_rrr_verify_ssh_setup(drvss_node,drvss_db_node_ind,drvss_node_os,drvss_node_ln)
   DECLARE drvss_cmd = vc WITH protect, noconstant("")
   DECLARE drvss_s_node = vc WITH protect, noconstant("")
   SET drvss_s_node = drvss_node
   SET drvss_cmd = concat("su - oracle -c 'ssh -o batchmode=yes -o numberofpasswordprompts=0 oracle@",
    drvss_s_node,^ echo "Target_Node:\`hostname\`"'^)
   SET dm_err->eproc = concat("Executing: ",drvss_cmd)
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dm_err->disp_dcl_err_ind = 0
   IF (dm2_push_dcl(drvss_cmd)=0)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("Output returned from ssh command = ",dm_err->errtext))
   ENDIF
   SET drsc_fnd_idx = 0
   SET drsc_fnd_idx = findstring("TARGET_NODE:",cnvtupper(dm_err->errtext),1,0)
   IF (drsc_fnd_idx > 0)
    SET drsc_fnd_idx = 0
    SET drsc_fnd_idx = findstring(cnvtupper(drvss_s_node),cnvtupper(dm_err->errtext),findstring(
      "TARGET_NODE:",cnvtupper(dm_err->errtext),1,0),0)
   ENDIF
   IF (drsc_fnd_idx=0)
    SET dm_err->eproc = concat("Verify SSH setup between local Target APP node (",trim(cnvtupper(
       curnode)),") and remote Target node (",cnvtupper(drvss_s_node),") for the oracle user.")
    SET dm_err->emsg = concat(
     "SSH command did not return the remote Target node.  On the local Target app node as ",
     "the root user, verify that the following o/s command returns a 'Target_Node' value of ",
     drvss_s_node,": ",drvss_cmd)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF (drvss_db_node_ind=1)
    SET drvss_cmd = concat("ssh -o batchmode=yes -o numberofpasswordprompts=0 oracle@",drvss_s_node,
     ' echo "Target_DB_Node_Uname:\`uname\`"')
    SET dm_err->eproc = concat("Executing: ",drvss_cmd)
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dm_err->disp_dcl_err_ind = 0
    IF (dm2_push_dcl(drvss_cmd)=0)
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ENDIF
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echo(concat("Output returned from ssh command = ",dm_err->errtext))
    ENDIF
    SET drvss_node_os = "DM2NOTSET"
    SET drsc_fnd_idx = 0
    SET drsc_fnd_idx = findstring("TARGET_DB_NODE_UNAME:",cnvtupper(dm_err->errtext),1,0)
    IF (drsc_fnd_idx > 0)
     SET drsc_fnd_idx = 0
     IF (findstring("LINUX",cnvtupper(dm_err->errtext),findstring("TARGET_DB_NODE_UNAME:",cnvtupper(
        dm_err->errtext),1,0),0) > 0)
      SET drvss_node_os = "LNX"
     ELSEIF (findstring("HP-UX",cnvtupper(dm_err->errtext),findstring("TARGET_DB_NODE_UNAME:",
       cnvtupper(dm_err->errtext),1,0),0) > 0)
      SET drvss_node_os = "HPX"
     ELSEIF (findstring("AIX",cnvtupper(dm_err->errtext),findstring("TARGET_DB_NODE_UNAME:",cnvtupper
       (dm_err->errtext),1,0),0) > 0)
      SET drvss_node_os = "AIX"
     ENDIF
    ENDIF
    IF (drvss_node_os="DM2NOTSET")
     SET dm_err->eproc = concat("Retrieve Target DB node (",cnvtupper(drvss_s_node),") o/s.")
     SET dm_err->emsg = concat(
      "Could not detect o/s via ssh 'uname' command or value returned invalid.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE deir_rrr_chk_connect(drcc_in_node,drcc_in_ora_home,drcc_in_dir_path,drcc_in_uname,
  drcc_in_upwd,drcc_in_db_connect,drcc_in_dbname,drcc_in_dbhost,drcc_in_ora_version)
   DECLARE drcc_cmd = vc WITH protect, noconstant("")
   DECLARE drcc_host = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE drcc_db = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE drcc_pos1 = i4 WITH protect, noconstant(0)
   DECLARE drcc_pos2 = i4 WITH protect, noconstant(0)
   IF (cnvtupper(drcc_in_node)=cnvtupper(build(curnode)))
    SET drcat_local = 1
   ELSE
    SET drcat_local = 0
   ENDIF
   IF (cnvtupper(drcc_in_node)=cnvtupper(dm_env_import_request->remote_node_name))
    SET drcat_db_node = 1
   ELSE
    SET drcat_db_node = 0
   ENDIF
   SET dm_err->eproc = "Create file to test database connection."
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (get_unique_file("dm2_dbcre_tns_chk",".ksh")=0)
    RETURN(0)
   ELSE
    SET drcat_file_name = dm_err->unique_fname
   ENDIF
   SELECT INTO value(drcat_file_name)
    DETAIL
     CALL print("#!/usr/bin/ksh"), row + 1,
     CALL print(concat('export ORACLE_HOME="',build(drcc_in_ora_home),'"')),
     row + 1,
     CALL print(concat("export UNAME='",drcc_in_uname,"'")), row + 1,
     CALL print(concat("export UPWD='",drcc_in_upwd,"'")), row + 1
     IF (cnvtupper(drcc_in_uname)="SYS")
      CALL print(concat("$ORACLE_HOME/bin/sqlplus $UNAME/$UPWD","@",build(drcc_in_db_connect),
       " 'as sysdba' <<endSQL")), row + 1
     ELSE
      CALL print(concat("$ORACLE_HOME/bin/sqlplus $UNAME/$UPWD","@",build(drcc_in_db_connect),
       " <<endSQL")), row + 1
     ENDIF
     CALL print("set serveroutput on;"), row + 1,
     CALL print("DECLARE"),
     row + 1,
     CALL print("  dbname VARCHAR2(128) := '';"), row + 1,
     CALL print("  host VARCHAR2(64) := '';"), row + 1,
     CALL print("BEGIN"),
     row + 1
     IF ((drrr_rf_data->tgt_db_deploy_config != "ADB"))
      CALL print("  SELECT lower(host_name) INTO host FROM v\$instance;"), row + 1,
      CALL print("  dbms_output.put_line('HOST_NAME is: <' || host ||'>');"),
      row + 1,
      CALL print(concat("  IF host = lower('",build(drcc_in_dbhost),"')")), row + 1,
      CALL print("  THEN"), row + 1,
      CALL print("    dbms_output.put_line('Database host matches');"),
      row + 1,
      CALL print("  END IF;"), row + 1
     ENDIF
     IF (((drcc_in_ora_version=patstring("12.*")) OR (drcc_in_ora_version=patstring("19*"))) )
      CALL print("  SELECT lower(name) INTO dbname FROM v\$pdbs;"), row + 1
     ELSE
      CALL print("  SELECT lower(name) INTO dbname FROM v\$database;"), row + 1
     ENDIF
     CALL print("  dbms_output.put_line('DATABASE_NAME is: <' || dbname || '>');"), row + 1,
     CALL print(concat("  IF dbname = lower('",build(drcc_in_dbname),"')")),
     row + 1,
     CALL print("  THEN"), row + 1,
     CALL print("    dbms_output.put_line('Database name matches');"), row + 1,
     CALL print("  END IF;"),
     row + 1,
     CALL print("END;"), row + 1,
     CALL print("/"), row + 1,
     CALL print("exit"),
     row + 1,
     CALL print("endSQL"), row + 1
    WITH nocounter, maxcol = 500, format = variable,
     maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (drcat_local=1)
    IF (cnvtlower(build(drcc_in_dir_path)) != cnvtlower(build(logical("ccluserdir"))))
     SET drcc_cmd = concat("cp ",build(logical("ccluserdir"),"/",drcat_file_name)," ",build(
       drcc_in_dir_path))
     IF (dm2_push_dcl(drcc_cmd)=0)
      RETURN(0)
     ENDIF
    ENDIF
    SET drcc_cmd = concat("chmod 777 ",build(drcc_in_dir_path),"/",build(drcat_file_name))
    IF (dm2_push_dcl(drcc_cmd)=0)
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->eproc = "Setting and validating variables for auto ftp procedures."
    CALL disp_msg("",dm_err->logfile,0)
    SET dm2ftpr->user_name = "oracle"
    SET dm2ftpr->remote_host = drcc_in_node
    SET dm2ftpr->dir_name = build(drcc_in_dir_path)
    SET dm2ftpr->options = "-b"
    SET dm_err->eproc = concat("Verify directory (",build(drcc_in_dir_path),") exists on node (",
     build(drcc_in_node),").")
    CALL disp_msg("",dm_err->logfile,0)
    IF (dfr_find_directory(null)=0)
     RETURN(0)
    ENDIF
    IF ((dm2ftpr->exists_ind=0))
     SET dm_err->eproc = concat("Verify directory (",build(drcc_in_dir_path),") exists on node (",
      build(drcc_in_node),").")
     SET dm_err->emsg = concat("Target directory (",build(drcc_in_dir_path),
      ") not found on Target node (",drcc_in_node,").")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     RETURN(0)
    ENDIF
    CALL dfr_add_putops_line(" "," "," "," "," ",
     1)
    CALL dfr_add_putops_line(" ",build(logical("ccluserdir"),"/"),drcat_file_name,build(
      drcc_in_dir_path,"/"),drcat_file_name,
     0)
    IF (dfr_put_file(null)=0)
     RETURN(0)
    ENDIF
    CALL dfr_add_putops_line(" "," "," "," "," ",
     1)
   ENDIF
   IF (get_unique_file("dm2_dbcre_tns_chk",".err")=0)
    RETURN(0)
   ELSE
    SET drcd_ksh_err_file = dm_err->unique_fname
    SET dm_err->errfile = dm_err->unique_fname
   ENDIF
   SET dm_err->eproc = concat("On node (",build(drcc_in_node),
    "), as the ORACLE user, executing ksh script ",build(drcat_file_name)," from ",
    build(drcc_in_dir_path)," to verify connection to database...")
   CALL disp_msg("",dm_err->logfile,0)
   IF (drcat_local=1)
    SET drcc_cmd = concat("su - oracle -c ",build(drcc_in_dir_path,"/",drcat_file_name))
   ELSE
    SET drcc_cmd = concat("su - oracle -c 'ssh oracle@",build(drcc_in_node)," ",build(
      drcc_in_dir_path,"/"),build(drcat_file_name),
     "'")
   ENDIF
   SET dm_err->disp_dcl_err_ind = 0
   IF (dm2_push_dcl(drcc_cmd)=0)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   SET dm_err->errfile = "NONE"
   IF (((findstring("DATABASE HOST MATCHES",cnvtupper(dm_err->errtext),1,0)=0
    AND (drrr_rf_data->tgt_db_deploy_config != "ADB")) OR (findstring("DATABASE NAME MATCHES",
    cnvtupper(dm_err->errtext),1,0)=0)) )
    IF (findstring("HOST_NAME IS:",cnvtupper(dm_err->errtext),1,0) > 0)
     SET drcc_pos1 = findstring("<",dm_err->errtext,findstring("HOST_NAME IS:",cnvtupper(dm_err->
        errtext),1,0),0)
     SET drcc_pos2 = findstring(">",dm_err->errtext,drcc_pos1,0)
     SET drcc_host = substring((findstring("HOST_NAME IS:",cnvtupper(dm_err->errtext),1,0)+ 15),((
      drcc_pos2 - drcc_pos1) - 1),dm_err->errtext)
    ENDIF
    IF (findstring("DATABASE_NAME IS:",cnvtupper(dm_err->errtext),1,0) > 0)
     SET drcc_pos1 = findstring("<",dm_err->errtext,findstring("DATABASE_NAME IS:",cnvtupper(dm_err->
        errtext),1,0),0)
     SET drcc_pos2 = findstring(">",dm_err->errtext,drcc_pos1,0)
     SET drcc_db = substring((findstring("DATABASE_NAME IS:",cnvtupper(dm_err->errtext),1,0)+ 19),((
      drcc_pos2 - drcc_pos1) - 1),dm_err->errtext)
    ENDIF
    SET dm_err->eproc = concat("Test database connection.")
    SET dm_err->err_ind = 1
    IF (((drcc_db="DM2NOTSET") OR (drcc_host="DM2NOTSET")) )
     SET dm_err->emsg = concat("On node (",build(drcc_in_node),"), as the ORACLE user, ksh script (",
      build(drcc_in_dir_path,"/",drcat_file_name),") failed to connect to (",
      build(drcc_in_dbname),") database for (",build(drcc_in_uname),") database user and (",build(
       drcc_in_db_connect),
      ") connect string.")
    ELSE
     SET dm_err->emsg = concat("On node (",build(drcc_in_node),"), as the ORACLE user, ksh script (",
      build(drcc_in_dir_path,"/",drcat_file_name),") successfully connected to (",
      build(drcc_in_dbname),") database for (",build(drcc_in_uname),") database user and (",build(
       drcc_in_db_connect),
      ") connect string but selected database/host name ","not expected values of ",build(
       drcc_in_dbname),"/",build(drcc_in_dbhost),
      ".  Database/host name ","selected was ",build(drcc_db),"/",build(drcc_host),
      ".")
    ENDIF
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    SET dm_err->eproc = concat("On node (",build(drcc_in_node),"), as the ORACLE user, ksh script (",
     build(drcc_in_dir_path,"/",drcat_file_name),") successfully connected to (",
     build(drcc_in_dbname),") database for (",build(drcc_in_uname),") database user and (",build(
      drcc_in_db_connect),
     ") connect string and selected database/host name ","are expected values of ",build(
      drcc_in_dbname),"/",build(drcc_in_dbhost),
     ".")
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE deir_load_characterset(null)
   SET dm_err->eproc = "Read dm2_tools_valid_characterset.txt from cer_install"
   CALL disp_msg(" ",dm_err->logfile,0)
   FREE DEFINE rtl2
   SET logical file_name value(concat("CER_INSTALL:","dm2_tools_valid_characterset.txt"))
   DEFINE rtl2 "file_name"  WITH nomodify
   SELECT INTO "nl:"
    t.line
    FROM rtl2t t
    WHERE t.line > " "
    DETAIL
     deir_char_set->cnt = (deir_char_set->cnt+ 1), stat = alterlist(deir_char_set->qual,deir_char_set
      ->cnt)
     IF ((deir_char_set->cnt=1))
      deir_char_set->char_set_str = substring(1,12,trim(cnvtupper(t.line)))
     ELSE
      deir_char_set->char_set_str = concat(deir_char_set->char_set_str,",",substring(1,12,trim(
         cnvtupper(t.line))))
     ENDIF
     deir_char_set->qual[deir_char_set->cnt].char_set_value = trim(cnvtupper(t.line))
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE deir_create_misc_ts(null)
   DECLARE dcmt_stmt = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Retrieve MISC tablespace from dba_tablespaces"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_tablespaces dt
    WHERE dt.tablespace_name="MISC"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = concat("Create MISC tablespace.")
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dcmt_stmt = concat("RDB ASIS (^ create tablespace MISC"," datafile '+",build(
      dm_env_import_request->asm_storage_disk_group),"' size 1M autoextend ","on next 64M ^) GO ")
    IF (dm2_push_cmd(dcmt_stmt,1)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE deir_rrr_get_nbr_list(drgnl_dir,drgnl_file_prefix,drgnl_nbr_list)
   DECLARE drgnl_dcl = vc WITH protect, noconstant("")
   DECLARE drgnl_stripped_nbr = vc WITH protect, noconstant("")
   SET drgnl_nbr_list = ""
   SET drgnl_dcl = concat("ls -t ",build(drgnl_dir),"/",drgnl_file_prefix,"* | wc -w")
   IF (dm2_push_dcl(drgnl_dcl)=0)
    RETURN(0)
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   IF (findstring("0",cnvtlower(dm_err->errtext)) > 0)
    SET dm_err->eproc = concat("Find ",drgnl_file_prefix,"* files in ",drgnl_dir,".")
    SET dm_err->emsg = "No files found."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET drgnl_dcl = concat("ls -l ",build(drgnl_dir),"/",drgnl_file_prefix,"* ")
   SET dm_err->eproc = "Getting list of files."
   IF (dm2_push_dcl(drgnl_dcl)=0)
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
     stripped_nbr = trim(substring((findstring(drgnl_file_prefix,r.line)+ size(drgnl_file_prefix)),
       size(r.line),r.line),3), drgnl_nbr_list = build(trim(drgnl_nbr_list,3),trim(stripped_nbr,3),
      ",")
    FOOT REPORT
     drgnl_nbr_list = replace(drgnl_nbr_list,",","",2)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echo(build("Number list = ",drgnl_nbr_list))
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE deir_mng_temp_tspaces(null)
   DECLARE dmtt_iter = i4 WITH protect, noconstant(0)
   DECLARE dmtt_stmt = vc WITH protect, noconstant("")
   DECLARE dmtt_size = i4 WITH protect, noconstant(5)
   FREE RECORD dmtt_temp_tspaces
   RECORD dmtt_temp_tspaces(
     1 cnt = i4
     1 qual[*]
       2 tspace = vc
   )
   SET dmtt_temp_tspaces->cnt = 0
   SET stat = alterlist(dmtt_temp_tspaces->qual,0)
   SET dm_err->eproc = "Retrieve temporary tablespaces without tempfiles"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_tablespaces dt
    WHERE dt.contents="TEMPORARY"
     AND  NOT (dt.tablespace_name IN (
    (SELECT
     x.tablespace_name
     FROM dba_temp_files x)))
    DETAIL
     dmtt_temp_tspaces->cnt = (dmtt_temp_tspaces->cnt+ 1), stat = alterlist(dmtt_temp_tspaces->qual,
      dmtt_temp_tspaces->cnt), dmtt_temp_tspaces->qual[dmtt_temp_tspaces->cnt].tspace = trim(dt
      .tablespace_name)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dmtt_temp_tspaces->cnt > 0))
    IF (validate(dm2_create_db_tempfile_size,0) > 0)
     SET dmtt_size = dm2_create_db_tempfile_size
    ENDIF
    FOR (dmtt_iter = 1 TO dmtt_temp_tspaces->cnt)
      SET dm_err->eproc = concat("Add tempfile to temporary tablespace ",trim(dmtt_temp_tspaces->
        qual[dmtt_iter].tspace),".")
      CALL disp_msg(" ",dm_err->logfile,0)
      SET dmtt_stmt = concat("RDB ASIS (^ alter tablespace ",trim(dmtt_temp_tspaces->qual[dmtt_iter].
        tspace)," add tempfile '+",build(dm_env_import_request->asm_storage_disk_group),"' size ",
       trim(cnvtstring(dmtt_size)),"M autoextend ","on next 64M ^) GO ")
      IF (dm2_push_cmd(dmtt_stmt,1)=0)
       RETURN(0)
      ENDIF
    ENDFOR
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_script
 IF (validate(drrr_responsefile_in_use,0)=0)
  CALL clear(1,1)
  SET message = nowindow
  IF (deir_failed=1)
   SET dm_err->eproc =
   "Please re-execute the database shell creation process with the necessary changes."
   CALL disp_msg("User chose to quit.",dm_err->logfile,1)
  ENDIF
  IF ((dm_err->err_ind=1))
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  ENDIF
  SET dm_err->eproc = "Ending dm2_create_db_shell"
  CALL final_disp_msg("dm2_create_db_shell")
 ELSE
  IF ((dm_err->err_ind=0))
   SET dm_err->eproc = "dm2_create_db_shell completed successfully."
  ENDIF
  CALL final_disp_msg("dm2_create_db_shell")
 ENDIF
END GO
