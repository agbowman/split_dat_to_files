CREATE PROGRAM dm2_mv_restore_bytable:dba
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
 IF ((validate(mv->cnt,- (1.0))=- (1.0))
  AND (validate(mv->cnt,- (2.0))=- (2.0)))
  FREE RECORD mv
  RECORD mv(
    1 name = vc
    1 syn_name = vc
    1 cview_name = vc
    1 instance = i2
    1 exists_ind = i2
    1 query = vc
    1 create_txt = vc
    1 piece_cnt = i2
    1 txt[*]
      2 piece = vc
    1 bt_cnt = i2
    1 bt[*]
      2 table_name = vc
      2 tablespace_name = vc
    1 mlog_cnt = i2
    1 mlog[*]
      2 type = i2
      2 table_name = vc
    1 sq_query = vc
    1 sq_cnt = i2
    1 sq[*]
      2 piece = vc
  )
 ENDIF
 IF ((validate(btmv->mv_cnt,- (1.0))=- (1.0))
  AND (validate(btmv->mv_cnt,- (2.0))=- (2.0)))
  FREE RECORD btmv
  RECORD btmv(
    1 base_table_name = vc
    1 mv_cnt = i2
    1 mv[*]
      2 name = vc
      2 instance = i2
      2 status = vc
    1 mvl_cnt = i2
    1 mvl[*]
      2 table_name = vc
  )
 ENDIF
 DECLARE dmvr_get_mv(ddme_name=vc,ddme_exists_ind=i2(ref)) = i2
 DECLARE dmvr_get_msyn(ddms_name=vc,ddms_exists_ind=i2(ref),ddms_ref_name=vc(ref)) = i2
 DECLARE dmvr_mv_log_maint(dmlm_mode=vc,dmlm_bt_name=vc) = i2
 DECLARE dmvr_create_mview(null) = i2
 DECLARE dmvr_refresh_mview(drm_mv_name=vc,drm_method=vc) = i2
 DECLARE dmvr_create_mv_syn(dcms_syn_name=vc,dcms_ref_name=vc) = i2
 DECLARE dmvr_updt_mv_inst(dumi_mode=vc,dumi_name=vc,dumi_instance=i2,dumi_status=vc) = i2
 DECLARE dmvr_create_mv_cview(null) = i2
 DECLARE dmvr_get_mv_metadata(dgmm_name=vc,dgmm_instance=i2) = i2
 DECLARE dmvr_drop_mlog(ddm_bt_name=vc) = i2
 DECLARE dmvr_get_mvs_for_bt(dgmfb_table_name=vc) = i2
 DECLARE dmvr_get_mv_restores_for_bt(dgmrfb_table_name=vc) = i2
 SUBROUTINE dmvr_get_mv_metadata(dgmm_name,dgmm_instance)
   DECLARE dgmm_instance = i2 WITH protect, noconstant(dgmm_instance)
   SET mv->name = ""
   SET mv->cview_name = ""
   SET mv->syn_name = ""
   SET mv->query = " "
   SET mv->create_txt = " "
   SET mv->piece_cnt = 0
   SET stat = alterlist(mv->txt,mv->piece_cnt)
   SET mv->bt_cnt = 0
   SET stat = alterlist(mv->bt,mv->bt_cnt)
   SET mv->mlog_cnt = 0
   SET stat = alterlist(mv->mlog,mv->mlog_cnt)
   SET mv->sq_query = " "
   SET mv->sq_cnt = 0
   SET stat = alterlist(mv->sq,mv->sq_cnt)
   SET dm_err->eproc = concat("Retrieving Admin metadata for MVIEW ",dgmm_name)
   SELECT INTO "nl:"
    FROM dma_sql_obj_inst a,
     dma_sql_obj_inst_attr b
    WHERE a.object_type="MVIEW"
     AND a.process_type="INSTALL UPGRADE"
     AND a.object_name=cnvtupper(dgmm_name)
     AND a.object_instance=dgmm_instance
     AND a.active_ind=1
     AND a.dma_sql_obj_inst_id=b.dma_sql_obj_inst_id
    ORDER BY b.attr_name, b.attr_seg_nbr
    HEAD REPORT
     mv->name = a.object_name, mv->instance = a.object_instance
    DETAIL
     CASE (cnvtupper(b.attr_name))
      OF "SYN_NAME":
       mv->syn_name = cnvtupper(b.attr_value_char)
      OF "CVIEW_NAME":
       mv->cview_name = cnvtupper(b.attr_value_char)
      OF "QUERY":
       mv->piece_cnt = (mv->piece_cnt+ 1),stat = alterlist(mv->txt,mv->piece_cnt),mv->txt[mv->
       piece_cnt].piece = b.attr_value_char,
       mv->query = concat(mv->query," ",mv->txt[mv->piece_cnt].piece)
      OF "BASETABLE":
       mv->bt_cnt = (mv->bt_cnt+ 1),stat = alterlist(mv->bt,mv->bt_cnt),mv->bt[mv->bt_cnt].table_name
        = b.attr_value_char
      OF "MVIEWLOGROWID":
       mv->mlog_cnt = (mv->mlog_cnt+ 1),stat = alterlist(mv->mlog,mv->mlog_cnt),mv->mlog[mv->mlog_cnt
       ].type = 1,
       mv->mlog[mv->mlog_cnt].table_name = b.attr_value_char
      OF "SPACEQUERY":
       mv->sq_cnt = (mv->sq_cnt+ 1),stat = alterlist(mv->sq,mv->sq_cnt),mv->sq[mv->sq_cnt].piece = b
       .attr_value_char,
       mv->sq_query = concat(mv->sq_query," ",mv->sq[mv->sq_cnt].piece)
      OF "CREATE":
       mv->create_txt = concat(mv->create_txt," ",trim(b.attr_value_char))
     ENDCASE
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(mv)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmvr_get_mv(dgm_name,dgm_exists_ind)
   SET dm_err->eproc = concat("Checking for Materialized View: ",dgm_name)
   SET dgm_exists_ind = 0
   SELECT INTO "nl:"
    FROM dba_mviews dm
    WHERE dm.owner=currdbuser
     AND dm.mview_name=cnvtupper(dgm_name)
    DETAIL
     dgm_exists_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmvr_get_msyn(dgms_name,dgms_exists_ind,dgms_ref_name)
   SET dm_err->eproc = concat("Checking for Materialized View Synonym:",dgms_name)
   SET dgms_exists_ind = 0
   SELECT INTO "nl:"
    FROM all_synonyms a
    WHERE a.synonym_name=cnvtupper(dgms_name)
     AND a.owner="PUBLIC"
    DETAIL
     dgms_exists_ind = 1, dgms_ref_name = a.table_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmvr_mv_log_maint(dmlm_mode,dmlm_bt_name)
   DECLARE dmlm_tspace_name = vc WITH protect, noconstant(" ")
   DECLARE dmlm_cmd = vc WITH protect, noconstant(" ")
   SET dm_err->eproc = concat("Checking for ROWID Materialized View Log on :",dmlm_bt_name)
   SELECT INTO "nl:"
    FROM dba_mview_logs a
    WHERE a.log_owner=currdbuser
     AND a.master=cnvtupper(dmlm_bt_name)
     AND a.rowids="YES"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   IF (dmlm_mode="CREATE")
    IF (curqual=1)
     SET dm_err->eproc = concat("ROWID MVIEW Log for base table ",dmlm_bt_name,
      " exists.  Bypassing Creation request...")
     CALL disp_msg(" ",dm_err->logfile,0)
    ELSE
     SET dm_err->eproc = concat("Getting tablespace for MVIEW Base Table:",dmlm_bt_name)
     SELECT INTO "nl:"
      FROM dba_tables dut
      WHERE dut.table_name=cnvtupper(dmlm_bt_name)
       AND dut.owner=currdbuser
      DETAIL
       dmlm_tspace_name = dut.tablespace_name
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      RETURN(0)
     ENDIF
     IF (curqual=0)
      SET dm_err->err_ind = 1
      SET dm_err->emsg = concat("MView Base Table",dmlm_bt_name," not found in dba_tables")
      RETURN(0)
     ENDIF
     SET dm_err->eproc = concat("Build ROWID Materialized View Log on:",dmlm_bt_name)
     SET dmlm_cmd = concat("RDB CREATE MATERIALIZED VIEW LOG ON ",dmlm_bt_name," TABLESPACE ",
      dmlm_tspace_name," WITH ROWID GO")
     IF ( NOT (dm2_push_cmd(dmlm_cmd,1)))
      RETURN(0)
     ENDIF
    ENDIF
   ELSEIF (dmlm_mode="DROP")
    IF (curqual=1)
     SET dm_err->eproc = concat("Drop ROWID Materialized View Log on:",dmlm_bt_name)
     SET dmlm_cmd = concat("RDB DROP MATERIALIZED VIEW LOG ON ",dmlm_bt_name," GO")
     IF ( NOT (dm2_push_cmd(dmlm_cmd,1)))
      RETURN(0)
     ENDIF
    ELSE
     SET dm_err->eproc = concat("ROWID MVIEW Log doesn't exist on ",dmlm_bt_name,
      ".  Bypassing drop request..")
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Invalid mode (",dmlm_mode,") passed to subroutine dmvr_mv_log_maint")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmvr_create_mview(null)
   DECLARE dcm_cmd = vc WITH protect, noconstant(" ")
   DECLARE dcm_resumeable_timeout = i4 WITH protect, noconstant(28800)
   IF ((mv->exists_ind=1))
    SET dm_err->eproc = concat("Dropping Materialized View:",mv->name)
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
    SET dcm_cmd = concat("RDB DROP MATERIALIZED VIEW ",mv->name," GO")
    IF ( NOT (dm2_push_cmd(dcm_cmd,1)))
     RETURN(0)
    ENDIF
   ENDIF
   IF (dm2_push_cmd(concat("rdb alter session enable resumable timeout ",build(dcm_resumeable_timeout
      )," name '",mv->name,"' go"),1)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Building Materialized View ",mv->name," on Pre-Built table.")
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SET dcm_cmd = concat("RDB ",mv->create_txt," ",mv->query," GO")
   IF ( NOT (dm2_push_cmd(dcm_cmd,1)))
    RETURN(0)
   ENDIF
   IF (dm2_push_cmd(concat("rdb alter session disable resumable go"),1)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmvr_refresh_mview(drm_name,drm_method)
   DECLARE drm_cmd = vc WITH protect, noconstant(" ")
   DECLARE drm_resumeable_timeout = i4 WITH protect, noconstant(28800)
   SET dm_err->eproc = concat("Refreshing Materialized View ",drm_name," using method: ",drm_method)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dm2_push_cmd(concat("rdb alter session enable resumable timeout ",build(drm_resumeable_timeout
      )," name '",mv->name,"' go"),1)=0)
    RETURN(0)
   ENDIF
   SET drm_cmd = concat("RDB ASIS(^ BEGIN DBMS_MVIEW.REFRESH('",drm_name,"','",trim(drm_method),
    "'); END; ^) GO")
   IF ( NOT (dm2_push_cmd(drm_cmd,1)))
    RETURN(0)
   ENDIF
   IF (dm2_push_cmd(concat("rdb alter session disable resumable go"),1)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmvr_create_mv_syn(dcms_syn_name,dcms_ref_object)
   DECLARE dcms_cmd = vc WITH protect, noconstant(" ")
   SET dm_err->eproc = concat("Create/Replacing MVIEW Public Synonym ",dcms_syn_name," referencing ",
    dcms_ref_object)
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dcms_cmd = concat("RDB CREATE OR REPLACE PUBLIC SYNONYM ",dcms_syn_name," FOR ",
    dcms_ref_object," GO")
   IF ( NOT (dm2_push_cmd(dcms_cmd,1)))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmvr_create_mv_cview(null)
   DECLARE dcmc_cmd = vc WITH protect, noconstant(" ")
   SET dm_err->eproc = concat("Create/Replacing Companion View ",mv->cview_name," for Materialized ",
    "View ",mv->name)
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dcmc_cmd = concat("RDB CREATE OR REPLACE VIEW ",mv->cview_name," AS ",mv->query," GO ")
   IF ( NOT (dm2_push_cmd(dcmc_cmd,1)))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmvr_updt_mv_inst(dumi_mode,dumi_name,dumi_instance,dumi_status)
   IF (cnvtupper(dumi_mode) IN ("U", "IU"))
    UPDATE  FROM dm_info a
     SET a.info_char = cnvtupper(dumi_status), a.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE a.info_domain="DM2_MVIEW_INSTANCE"
      AND a.info_name=cnvtupper(dumi_name)
     WITH nocounter
    ;end update
    IF (check_error(concat("Updating MVIEW Instance row for: ",dumi_name)))
     ROLLBACK
     RETURN(0)
    ENDIF
   ENDIF
   IF (cnvtupper(dumi_mode)="IU")
    IF (curqual=0)
     INSERT  FROM dm_info a
      SET a.info_domain = "DM2_MVIEW_INSTANCE", a.info_name = cnvtupper(dumi_name), a.info_number =
       dumi_instance,
       a.info_char = cnvtupper(dumi_status), a.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WITH nocounter
     ;end insert
     IF (check_error(concat("Inserting MVIEW Instance row for: ",dumi_name)))
      ROLLBACK
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmvr_get_mvs_for_bt(dgmfb_bt_name)
   SET btmv->mv_cnt = 0
   SET stat = alterlist(btmv->mv,btmv->mv_cnt)
   SET btmv->mvl_cnt = 0
   SET stat = alterlist(btmv->mvl,btmv->mvl_cnt)
   SET dm_err->eproc = concat("Retrieving Cerner MVIEWs for Base Table ",dgmfb_bt_name)
   SELECT INTO "nl:"
    FROM user_base_table_mviews ubtm,
     user_registered_mviews urm,
     dm_info di
    WHERE ubtm.mview_id=urm.mview_id
     AND urm.name=di.info_name
     AND di.info_domain="DM2_MVIEW_INSTANCE"
     AND ubtm.master=patstring(dgmfb_bt_name)
    ORDER BY urm.name
    HEAD urm.name
     btmv->mv_cnt = (btmv->mv_cnt+ 1), stat = alterlist(btmv->mv,btmv->mv_cnt), btmv->mv[btmv->mv_cnt
     ].name = urm.name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Retrieving Cerner MVIEW Logs for Base Table ",dgmfb_bt_name)
   SELECT INTO "nl:"
    FROM user_mview_logs uml
    WHERE uml.master IN (
    (SELECT
     dsoia.attr_value_char
     FROM dma_sql_obj_inst_attr dsoia,
      dma_sql_obj_inst dsoi,
      dm_info di
     WHERE dsoia.dma_sql_obj_inst_id=dsoi.dma_sql_obj_inst_id
      AND dsoi.object_name=di.info_name
      AND di.info_domain="DM2_MVIEW_INSTANCE"
      AND dsoia.attr_value_char=patstring(dgmfb_bt_name)
      AND dsoia.attr_name="BASETABLE"))
    ORDER BY uml.master
    HEAD uml.master
     btmv->mvl_cnt = (btmv->mvl_cnt+ 1), stat = alterlist(btmv->mvl,btmv->mvl_cnt), btmv->mvl[btmv->
     mvl_cnt].table_name = uml.master
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmvr_get_mv_restores_for_bt(dgmrfb_bt_name)
   DECLARE dgmrfb_basetable_name = vc WITH protect, noconstant(" ")
   SET dgmrfb_basetable_name = cnvtupper(dgmrfb_bt_name)
   SET btmv->mv_cnt = 0
   SET stat = alterlist(btmv->mv,btmv->mv_cnt)
   SET dm_err->eproc = concat("Retrieving MVIEW restore list for base table ",dgmrfb_bt_name)
   SELECT INTO "nl:"
    FROM dma_sql_obj_inst dsoi,
     dm_info di
    WHERE dsoi.object_name=di.info_name
     AND dsoi.object_instance=di.info_number
     AND dsoi.active_ind=1
     AND di.info_domain="DM2_MVIEW_INSTANCE"
     AND di.info_char IN ("MVIEW", "MVIEWBUILD", "CVIEW")
     AND dsoi.dma_sql_obj_inst_id IN (
    (SELECT
     dsoia.dma_sql_obj_inst_id
     FROM dma_sql_obj_inst_attr dsoia
     WHERE dsoia.attr_name="BASETABLE"
      AND dsoia.attr_value_char=patstring(dgmrfb_basetable_name)))
    DETAIL
     btmv->mv_cnt = (btmv->mv_cnt+ 1), stat = alterlist(btmv->mv,btmv->mv_cnt), btmv->mv[btmv->mv_cnt
     ].name = dsoi.object_name,
     btmv->mv[btmv->mv_cnt].instance = dsoi.object_instance, btmv->mv[btmv->mv_cnt].status = di
     .info_char
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmvr_drop_mlog(ddm_bt_name)
   DECLARE ddm_cmd = vc WITH protect, noconstant(" ")
   DECLARE ddm_mlog_exists_ind = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = concat("Checking existence for Materialized View Log on Base Table: ",
    ddm_bt_name)
   SELECT INTO "nl:"
    FROM user_mview_logs aml
    WHERE aml.master=cnvtupper(ddm_bt_name)
    DETAIL
     ddm_mlog_exists_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   IF (ddm_mlog_exists_ind=1)
    SET dm_err->eproc = concat("Dropping Materialized View Log for Base Table: ",ddm_bt_name)
    CALL disp_msg(" ",dm_err->logfile,0)
    SET ddm_cmd = concat("RDB DROP MATERIALIZED VIEW LOG ON ",ddm_bt_name," GO ")
    IF ( NOT (dm2_push_cmd(ddm_cmd,1)))
     RETURN(0)
    ENDIF
   ELSE
    IF ((dm_err->debug_flag > 0))
     SET dm_err->eproc = concat("Materialized View Log bypassed for Base Table: ",ddm_bt_name)
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
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
 DECLARE dmrb_base_table = vc WITH protect, noconstant(" ")
 DECLARE dmrb_iter = i2 WITH protect, noconstant(0)
 DECLARE dmrb_mv_name = vc WITH protect, noconstant(" ")
 DECLARE dmrb_instance = i2 WITH protect, noconstant(0)
 DECLARE dmrb_dbwide_allowed_ind = i2 WITH protect, noconstant(1)
 IF (check_logfile("dm2_mv_restbytab",".log","dm2_mv_restore_bytable LOGFILE")=0)
  GO TO exit_program
 ENDIF
 SET dmrb_base_table = trim(cnvtupper( $1))
 IF (check_error(dm_err->eproc) != 0)
  SET dm_err->emsg = "Parameter usage: dm2_mv_restore_bytable '<table_name>'"
  CALL disp_msg("Checking input parameters...",dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 CALL dm2_get_rdbms_version(null)
 IF ((dm2_rdbms_version->level1 < 9))
  SET dm_err->eproc = "Materialized View processing not needed on Oracle 8.  Exiting..."
  CALL disp_msg(dm_err->eproc,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Load MVIEW Active Switch - DB Level"
 CALL disp_msg("",dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DM2_MVIEWS"
   AND di.info_name="STATUS"
  DETAIL
   dmrb_dbwide_allowed_ind = di.info_number
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  RETURN(0)
 ENDIF
 IF (dmrb_dbwide_allowed_ind=0)
  SET dm_err->emsg = "Materialized Views are turned off in the database.  Exiting..."
  SET dm_err->err_ind = 1
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 IF (dmvr_get_mv_restores_for_bt(dmrb_base_table)=0)
  GO TO exit_program
 ENDIF
 IF ((dm_err->debug_flag > 0))
  CALL echorecord(btmv)
 ENDIF
 FOR (dmrb_iter = 1 TO btmv->mv_cnt)
   SET dmrb_mv_name = btmv->mv[dmrb_iter].name
   SET dmrb_instance = btmv->mv[dmrb_iter].instance
   IF ((btmv->mv[dmrb_iter].status="CVIEW"))
    IF (dmvr_updt_mv_inst("U",dmrb_mv_name,1,"MVIEWBUILD")=0)
     GO TO exit_program
    ENDIF
   ENDIF
   EXECUTE dm2_mv_create dmrb_mv_name, dmrb_instance
   IF ((dm_err->err_ind=1))
    GO TO exit_program
   ENDIF
 ENDFOR
 GO TO exit_program
#exit_program
 SET dm_err->eproc = "DM2_MV_RESTORE_BYTABLE completed"
 CALL final_disp_msg("dm2_mv_restbytab")
END GO
