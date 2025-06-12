CREATE PROGRAM dm2_compare_rowcnts
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
 DECLARE dcr_get_tab_ind_info(dgui_type=vc,dgui_user=vc,dgui_reset=i2,dgui_resize=i2) = i2
 DECLARE dcr_prompt_owner_names(null) = i2
 DECLARE dcr_get_count(dgc_tbl_name=vc,dgc_col_name=vc,dgc_owner=vc,dgc_row_cnt=f8(ref),dgc_drop_ind=
  i2,
  dgc_type=vc) = i2
 DECLARE dcr_create_report(null) = i2
 DECLARE dcr_prelim(dp_mig_ind=i2) = i2
 DECLARE dcr_dblink_maint(dbm_mode=vc) = i2
 IF ((validate(dcr_compare_rowcnts_rec->owner_cnt,- (1))=- (1))
  AND (validate(dcr_compare_rowcnts_rec->owner_cnt,- (2))=- (2)))
  FREE RECORD dcr_compare_rowcnts_rec
  RECORD dcr_compare_rowcnts_rec(
    1 owner_cnt = i4
    1 mode = vc
    1 src_db_name = vc
    1 src_read_only = i2
    1 tgt_db_name = vc
    1 owner[*]
      2 owner_name = vc
      2 tbl_cnt = i4
      2 num_mismatch = i4
      2 tab[*]
        3 table_name = vc
        3 src_index_col = vc
        3 tgt_index_col = vc
        3 src_tbl_fnd = i2
        3 tgt_tbl_fnd = i2
        3 src_row_cnt = f8
        3 tgt_row_cnt = f8
  )
  SET dcr_compare_rowcnts_rec->owner_cnt = 0
 ENDIF
 IF ((validate(dcr_excl_tbls->tbl_cnt,- (1))=- (1)))
  FREE RECORD dcr_excl_tbls
  RECORD dcr_excl_tbls(
    1 tbl_cnt = i4
    1 tbls[*]
      2 owner_name = vc
      2 tbl_name = vc
      2 nomove_ind = i2
    1 owner_cnt = i4
    1 owner[*]
      2 owner_name = vc
      2 nomove_ind = i2
  )
  SET dcr_excl_tbls->tbl_cnt = 0
 ENDIF
 SUBROUTINE dcr_prelim(dp_mig_ind)
   DECLARE dp_owner_cnt = i4 WITH protect, noconstant(0)
   DECLARE dp_no_tables_ind = i2 WITH protect, noconstant(0)
   DECLARE dp_src_dbase = vc WITH protect, noconstant("")
   DECLARE dp_tgt_dbase = vc WITH protect, noconstant("")
   IF ((dm2_install_schema->src_dbase_name != "NONE")
    AND (dm2_install_schema->src_v500_p_word != "NONE")
    AND (dm2_install_schema->src_v500_connect_str != "NONE"))
    EXECUTE dm2_connect_to_dbase "CO"
   ELSE
    SET dm2_install_schema->dbase_name = '"SOURCE"'
    SET dm2_install_schema->u_name = "V500"
    SET dm2_force_connect_string = 1
    EXECUTE dm2_connect_to_dbase "PC"
    SET dm2_force_connect_string = 0
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ELSE
     IF (dm2_get_dbase_name(dp_src_dbase)=0)
      RETURN(0)
     ENDIF
     SET dm2_install_schema->src_dbase_name = dp_src_dbase
     SET dm2_install_schema->src_v500_p_word = dm2_install_schema->p_word
     SET dm2_install_schema->src_v500_connect_str = dm2_install_schema->connect_str
    ENDIF
   ENDIF
   IF (dp_mig_ind=1)
    SET dm_err->eproc = "Retrieving List of Excluded Tables"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain IN ("DM2_MIG_DT_USER", "DM2_MIG_EXCL")
      AND di.info_name != "GG"
     HEAD REPORT
      dcr_excl_tbls->tbl_cnt = 0
     DETAIL
      IF (di.info_domain="DM2_MIG_EXCL")
       dcr_excl_tbls->tbl_cnt = (dcr_excl_tbls->tbl_cnt+ 1), stat = alterlist(dcr_excl_tbls->tbls,
        dcr_excl_tbls->tbl_cnt), dcr_excl_tbls->tbls[dcr_excl_tbls->tbl_cnt].owner_name = trim(
        substring(1,(findstring(".",di.info_name) - 1),di.info_name)),
       dcr_excl_tbls->tbls[dcr_excl_tbls->tbl_cnt].tbl_name = trim(substring((findstring(".",di
          .info_name,1,1)+ 1),size(di.info_name),di.info_name)), dcr_excl_tbls->tbls[dcr_excl_tbls->
       tbl_cnt].nomove_ind = evaluate(di.info_char,"0",1,0)
      ELSE
       dcr_excl_tbls->owner_cnt = (dcr_excl_tbls->owner_cnt+ 1), stat = alterlist(dcr_excl_tbls->
        owner,dcr_excl_tbls->owner_cnt), dcr_excl_tbls->owner[dcr_excl_tbls->owner_cnt].owner_name =
       trim(di.info_name),
       dcr_excl_tbls->owner[dcr_excl_tbls->owner_cnt].nomove_ind = evaluate(di.info_char,"0",1,0)
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(dcr_excl_tbls)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Determine READ ONLY status of DB"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM v$database v
    WHERE v.open_mode="READ ONLY"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dcr_compare_rowcnts_rec->src_read_only = 1
   ENDIF
   IF ((dm2_install_schema->target_dbase_name != "NONE")
    AND (dm2_install_schema->v500_p_word != "NONE")
    AND (dm2_install_schema->v500_connect_str != "NONE"))
    EXECUTE dm2_connect_to_dbase "CO"
   ELSE
    SET dm2_install_schema->dbase_name = '"TARGET"'
    SET dm2_install_schema->u_name = "V500"
    SET dm2_force_connect_string = 1
    EXECUTE dm2_connect_to_dbase "PC"
    SET dm2_force_connect_string = 0
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ELSE
     IF (dm2_get_dbase_name(dp_tgt_dbase)=0)
      RETURN(0)
     ENDIF
     SET dm2_install_schema->target_dbase_name = dp_tgt_dbase
     SET dm2_install_schema->v500_p_word = dm2_install_schema->p_word
     SET dm2_install_schema->v500_connect_str = dm2_install_schema->connect_str
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
   IF (dp_mig_ind=1)
    SET dm_err->eproc = "Determine migration users"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE ((d.info_domain="DM2_MIG_DT_USER"
      AND d.info_char="1"
      AND d.info_name != "GG") OR (d.info_domain="DM2_MIG_USER"))
     HEAD REPORT
      dcr_compare_rowcnts_rec->owner_cnt = 0
     DETAIL
      dcr_compare_rowcnts_rec->owner_cnt = (dcr_compare_rowcnts_rec->owner_cnt+ 1), stat = alterlist(
       dcr_compare_rowcnts_rec->owner,dcr_compare_rowcnts_rec->owner_cnt), dcr_compare_rowcnts_rec->
      owner[dcr_compare_rowcnts_rec->owner_cnt].owner_name = d.info_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET dm_err->emsg = "No migration users obtained from DM_INFO."
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    IF (dcr_prompt_owner_names(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   FOR (dp_owner_cnt = 1 TO dcr_compare_rowcnts_rec->owner_cnt)
     IF (dcr_get_tab_ind_info("SOURCE",dp_owner_cnt,1,0)=0)
      RETURN(0)
     ENDIF
   ENDFOR
   SET dm2_install_schema->dbase_name = dm2_install_schema->target_dbase_name
   SET dm2_install_schema->u_name = "V500"
   SET dm2_install_schema->p_word = dm2_install_schema->v500_p_word
   SET dm2_install_schema->connect_str = dm2_install_schema->v500_connect_str
   EXECUTE dm2_connect_to_dbase "CO"
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   FOR (dp_owner_cnt = 1 TO dcr_compare_rowcnts_rec->owner_cnt)
     IF (dcr_get_tab_ind_info("TARGET",dp_owner_cnt,0,1)=0)
      RETURN(0)
     ENDIF
   ENDFOR
   FOR (dp_owner_cnt = 1 TO dcr_compare_rowcnts_rec->owner_cnt)
     IF ((dcr_compare_rowcnts_rec->owner[dp_owner_cnt].tbl_cnt=0))
      SET dp_no_tables_ind = (dp_no_tables_ind+ 1)
     ENDIF
   ENDFOR
   IF ((dp_no_tables_ind=dcr_compare_rowcnts_rec->owner_cnt))
    SET dm_err->emsg = "No tables obtained from SOURCE and TARGET."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dcr_compare_rowcnts_rec->src_db_name = dm2_install_schema->src_dbase_name
   SET dcr_compare_rowcnts_rec->tgt_db_name = dm2_install_schema->target_dbase_name
   IF ((dcr_compare_rowcnts_rec->src_read_only=1))
    IF (dcr_dblink_maint("CREATE")=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcr_dblink_maint(dbm_mode)
   SET dm_err->eproc = "Check for DM2_CNT_LINK database link"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM all_db_links dl
    WHERE dl.db_link="DM2_CNT_LINK.*"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dm_err->eproc = "Drop DM2_CNT_LINK database link"
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (dm2_push_cmd(concat("rdb drop public database link DM2_CNT_LINK go"),1)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dbm_mode="CREATE")
    SET dm_err->eproc = 'Creating public DM2_CNT_LINK to "SOURCE" database'
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (dm2_push_cmd(concat(
      "rdb create public database link DM2_CNT_LINK connect to v500 identified by ",
      dm2_install_schema->src_v500_p_word," using '",dm2_install_schema->src_v500_connect_str,"' go"),
     1)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcr_create_report(null)
   DECLARE dcr_str = vc WITH protect, noconstant("")
   DECLARE dcr_num = f8 WITH protect, noconstant(0.0)
   DECLARE dcr_rpt_file = vc WITH protect, noconstant("")
   DECLARE dcr_own_cnt = i4 WITH protect, noconstant(0)
   DECLARE dcr_tbl_cnt = i4 WITH protect, noconstant(0)
   DECLARE dcr_line = vc WITH protect, noconstant(fillstring(132,"_"))
   IF (get_unique_file(evaluate(dcr_compare_rowcnts_rec->mode,"DOWNTIME","dm2_dtcnt_cmp",
     "dm2_cnt_cmp"),".rpt")=0)
    RETURN(0)
   ELSE
    SET dcr_rpt_file = dm_err->unique_fname
   ENDIF
   SET dm_err->eproc = concat("Write report data to ",dcr_rpt_file)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO value(dcr_rpt_file)
    FROM dual
    HEAD REPORT
     CALL print(dcr_line), row + 1
     IF ((dcr_compare_rowcnts_rec->mode != "DOWNTIME"))
      col 0, "ROW COUNT COMPARE"
     ELSE
      col 0, "DOWNTIME ROW COUNT COMPARE"
     ENDIF
     dcr_str = format(cnvtdatetime(curdate,curtime3),"YYYY-MM-DD HH:MM:SS;;Q"), col 50, dcr_str,
     row + 1,
     CALL print(dcr_line), row + 2,
     CALL print("Criteria:"), row + 1,
     CALL print("_________"),
     row + 1,
     CALL print(concat("Source Database:",dcr_compare_rowcnts_rec->src_db_name)), row + 1,
     CALL print(concat("Target Database:",dcr_compare_rowcnts_rec->tgt_db_name)), row + 1
     FOR (dcr_own_cnt = 1 TO dcr_compare_rowcnts_rec->owner_cnt)
       row + 5,
       CALL print(concat("Summary for USER(",dcr_compare_rowcnts_rec->owner[dcr_own_cnt].owner_name,
        "):")), row + 1,
       CALL print("_________"), row + 1
       IF ((dcr_compare_rowcnts_rec->owner[dcr_own_cnt].tbl_cnt > 0))
        CALL print(concat("Tables Compared:",cnvtstring(dcr_compare_rowcnts_rec->owner[dcr_own_cnt].
          tbl_cnt))), row + 1,
        CALL print(concat("Tables Matched:",cnvtstring((dcr_compare_rowcnts_rec->owner[dcr_own_cnt].
          tbl_cnt - dcr_compare_rowcnts_rec->owner[dcr_own_cnt].num_mismatch)))),
        row + 1,
        CALL print(concat("Tables Mismatched:",cnvtstring(dcr_compare_rowcnts_rec->owner[dcr_own_cnt]
          .num_mismatch))), row + 3,
        CALL print(dcr_line), row + 1,
        CALL print("Mismatched Tables"),
        row + 1,
        CALL print(dcr_line), row + 2,
        CALL print("                                     Source            Target              "),
        row + 1,
        CALL print(
        "Table Name                           Row Count         Row Count               Difference   "
        ),
        row + 1,
        CALL print(
        "_______________                      ______________    ______________          __________       "
        ), row + 1
        IF ((dcr_compare_rowcnts_rec->owner[dcr_own_cnt].num_mismatch > 0))
         FOR (dcr_tab_cnt = 1 TO dcr_compare_rowcnts_rec->owner[dcr_own_cnt].tbl_cnt)
           IF ((dcr_compare_rowcnts_rec->owner[dcr_own_cnt].tab[dcr_tab_cnt].src_row_cnt !=
           dcr_compare_rowcnts_rec->owner[dcr_own_cnt].tab[dcr_tab_cnt].tgt_row_cnt))
            col 0, dcr_compare_rowcnts_rec->owner[dcr_own_cnt].tab[dcr_tab_cnt].table_name
            IF ((dcr_compare_rowcnts_rec->owner[dcr_own_cnt].tab[dcr_tab_cnt].src_row_cnt != - (1)))
             col 37, dcr_compare_rowcnts_rec->owner[dcr_own_cnt].tab[dcr_tab_cnt].src_row_cnt
            ELSE
             col 37, "<table not found>"
            ENDIF
            IF ((dcr_compare_rowcnts_rec->owner[dcr_own_cnt].tab[dcr_tab_cnt].tgt_row_cnt != - (1)))
             col 55, dcr_compare_rowcnts_rec->owner[dcr_own_cnt].tab[dcr_tab_cnt].tgt_row_cnt
            ELSE
             col 55, "<table not found>"
            ENDIF
            IF ((((dcr_compare_rowcnts_rec->owner[dcr_own_cnt].tab[dcr_tab_cnt].tgt_tbl_fnd=0)) OR ((
            dcr_compare_rowcnts_rec->owner[dcr_own_cnt].tab[dcr_tab_cnt].src_tbl_fnd=0))) )
             col 85, "-"
            ELSE
             dcr_num = (dcr_compare_rowcnts_rec->owner[dcr_own_cnt].tab[dcr_tab_cnt].src_row_cnt -
             dcr_compare_rowcnts_rec->owner[dcr_own_cnt].tab[dcr_tab_cnt].tgt_row_cnt)
             IF (dcr_num < 0)
              dcr_str = concat("(",build((dcr_num * - (1.0))),")"), col 80, dcr_str
             ELSE
              dcr_str = build(dcr_num), col 80, dcr_str
             ENDIF
            ENDIF
            row + 1
           ENDIF
         ENDFOR
        ELSE
         CALL print("There are no mismatched row counts"), row + 2
        ENDIF
        IF ((dcr_compare_rowcnts_rec->owner[dcr_own_cnt].num_mismatch != dcr_compare_rowcnts_rec->
        owner[dcr_own_cnt].tbl_cnt))
         row + 5,
         CALL print(dcr_line), row + 1,
         CALL print("Matched Tables"), row + 1,
         CALL print(dcr_line),
         row + 2,
         CALL print("                                     Source            Target              "),
         row + 1,
         CALL print("Table Name                           Row Count         Row Count            "),
         row + 1,
         CALL print("_______________                      ______________    ______________      "),
         row + 1
         FOR (dcr_tab_cnt = 1 TO dcr_compare_rowcnts_rec->owner[dcr_own_cnt].tbl_cnt)
           IF ((dcr_compare_rowcnts_rec->owner[dcr_own_cnt].tab[dcr_tab_cnt].src_row_cnt=
           dcr_compare_rowcnts_rec->owner[dcr_own_cnt].tab[dcr_tab_cnt].tgt_row_cnt))
            col 0, dcr_compare_rowcnts_rec->owner[dcr_own_cnt].tab[dcr_tab_cnt].table_name, col 37,
            dcr_compare_rowcnts_rec->owner[dcr_own_cnt].tab[dcr_tab_cnt].src_row_cnt, col 55,
            dcr_compare_rowcnts_rec->owner[dcr_own_cnt].tab[dcr_tab_cnt].tgt_row_cnt,
            row + 1
           ENDIF
         ENDFOR
        ELSE
         CALL print("There are no matched row counts"), row + 2
        ENDIF
       ELSE
        CALL print("No tables recorded"), row + 2
       ENDIF
     ENDFOR
    WITH nocounter, format = variable, formfeed = none,
     maxcol = 512
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dm2_disp_file(dcr_rpt_file,concat("Report File may be found in CCLUSERDIR:",dcr_rpt_file))=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcr_get_count(dgc_tbl_name,dgc_col_name,dgc_owner,dgc_row_cnt,dgc_drop_ind,dgc_type)
   DECLARE dgc_view_str = vc WITH protect, noconstant("")
   DECLARE dgc_view_exist = i2 WITH protect, noconstant(0)
   DECLARE dgc_error_ind = i2 WITH protect, noconstant(0)
   IF (dgc_drop_ind=1)
    SET dgc_error_ind = dm_err->err_ind
    SET dm_err->err_ind = 0
    SET dm_err->eproc = "Clean up DM2ROW_COUNT view and ccldef"
    CALL disp_msg("",dm_err->logfile,0)
    IF (checkdic("DM2ROW_COUNT","T",0)=2)
     DROP TABLE dm2row_count
    ENDIF
    SET dm_err->eproc = "Check for DM2ROW_COUNT view"
    SELECT INTO "nl:"
     FROM dm2_user_views v
     WHERE v.view_name="DM2ROW_COUNT"
     DETAIL
      dgc_view_exist = 1
     WITH nocounter
    ;end select
    IF (dgc_view_exist=1)
     SET dm_err->eproc = "Dropping DM2ROW_COUNT view"
     SET dgc_view_str = "RDB DROP VIEW DM2ROW_COUNT GO"
     CALL dm2_push_cmd(dgc_view_str,1)
    ENDIF
    IF ((dcr_compare_rowcnts_rec->src_read_only=1))
     IF (dcr_dblink_maint("DROP")=0)
      RETURN(0)
     ENDIF
    ENDIF
    SET dm_err->err_ind = dgc_error_ind
    RETURN(1)
   ENDIF
   SET dm_err->eproc = concat("Get row count for ",dgc_owner,".",dgc_tbl_name)
   CALL disp_msg("",dm_err->logfile,0)
   SET dm_err->eproc = "Creating DM2ROW_COUNT view."
   IF ((dcr_compare_rowcnts_rec->src_read_only=1)
    AND dgc_type="SOURCE")
    SET dgc_view_str = concat("CREATE OR REPLACE VIEW DM2ROW_COUNT AS"," SELECT ",dgc_col_name,
     " AS DM2_CNTVAL FROM ",dgc_owner,
     '."',dgc_tbl_name,'"@dm2_cnt_link d')
   ELSE
    SET dgc_view_str = concat("CREATE OR REPLACE VIEW DM2ROW_COUNT AS"," SELECT ",dgc_col_name,
     " AS DM2_CNTVAL FROM ",dgc_owner,
     '."',dgc_tbl_name,'" d')
   ENDIF
   IF (dm2_push_cmd(concat("RDB ASIS(^",dgc_view_str,"^) go"),1)=0)
    RETURN(0)
   ENDIF
   IF (checkdic("DM2ROW_COUNT","T",0)=0)
    SET dm_err->eproc = "Dropping and re-creating DM2ROW_COUNT ddlrecord."
    DROP DDLRECORD dm2row_count FROM DATABASE v500 WITH deps_deleted
    CREATE DDLRECORD dm2row_count FROM DATABASE v500
 TABLE dm2row_count
  1 dm2_cntval  = f8 CCL(dm2_cntval)
 END TABLE dm2row_count
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Get row count for ",dgc_owner,".",dgc_tbl_name," from DM2ROW_COUNT")
   SELECT INTO "nl:"
    x = d.dm2_cntval
    FROM dm2row_count d
    DETAIL
     dgc_row_cnt = x
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcr_get_tab_ind_info(dgui_type,dgui_user_ndx,dgui_reset,dgui_resize)
   DECLARE dgui_tmp_data_type = vc WITH protect, noconstant("")
   DECLARE dgui_tmp_col_name = vc WITH protect, noconstant("")
   DECLARE dgui_ndx = i4 WITH protect, noconstant(0)
   DECLARE dgui_ndx2 = i4 WITH protect, noconstant(0)
   DECLARE dgui_compare = i2 WITH protect, noconstant(0)
   IF (dgui_reset=1)
    SET dcr_compare_rowcnts_rec->owner[dgui_user_ndx].tbl_cnt = 0
    SET stat = alterlist(dcr_compare_rowcnts_rec->owner[dgui_user_ndx].tab,0)
    SET dcr_compare_rowcnts_rec->owner[dgui_user_ndx].num_mismatch = 0
   ENDIF
   SET dm_err->eproc = concat("Get list of tables for ",dgui_type)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcr_excl_tbls)
   ENDIF
   SELECT INTO "nl:"
    FROM dba_tables d
    PLAN (d
     WHERE d.owner=cnvtupper(dcr_compare_rowcnts_rec->owner[dgui_user_ndx].owner_name))
    ORDER BY d.table_name
    DETAIL
     dgui_compare = 0, dgui_ndx2 = 0
     IF ((dcr_excl_tbls->tbl_cnt=0)
      AND (dcr_compare_rowcnts_rec->mode != "DOWNTIME"))
      dgui_compare = 1
     ELSEIF ((dcr_excl_tbls->tbl_cnt > 0))
      IF ((dcr_compare_rowcnts_rec->mode != "DOWNTIME")
       AND locateval(dgui_ndx2,1,dcr_excl_tbls->tbl_cnt,d.table_name,dcr_excl_tbls->tbls[dgui_ndx2].
       tbl_name,
       d.owner,dcr_excl_tbls->tbls[dgui_ndx2].owner_name)=0)
       IF ((dcr_excl_tbls->owner_cnt > 0))
        IF (locateval(dgui_ndx2,1,dcr_excl_tbls->owner_cnt,d.owner,dcr_excl_tbls->owner[dgui_ndx2].
         owner_name)=0)
         dgui_compare = 1
        ENDIF
       ELSE
        dgui_compare = 1
       ENDIF
      ELSE
       IF ((dcr_compare_rowcnts_rec->mode="DOWNTIME"))
        dgui_ndx2 = locateval(dgui_ndx2,1,dcr_excl_tbls->tbl_cnt,d.table_name,dcr_excl_tbls->tbls[
         dgui_ndx2].tbl_name,
         d.owner,dcr_excl_tbls->tbls[dgui_ndx2].owner_name)
        IF (dgui_ndx2 > 0)
         IF ((dcr_excl_tbls->tbls[dgui_ndx2].nomove_ind=0))
          dgui_compare = 1
         ENDIF
        ELSE
         IF ((dcr_excl_tbls->owner_cnt > 0))
          dgui_ndx2 = locateval(dgui_ndx2,1,dcr_excl_tbls->owner_cnt,d.owner,dcr_excl_tbls->owner[
           dgui_ndx2].owner_name)
          IF (dgui_ndx2 > 0)
           IF ((dcr_excl_tbls->owner[dgui_ndx2].nomove_ind=0))
            dgui_compare = 1
           ENDIF
          ENDIF
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
     IF (dgui_compare=1)
      IF ((dm_err->debug_flag > 0))
       CALL echo(concat(trim(d.owner),".",trim(d.table_name)))
      ENDIF
      IF (locateval(dgui_ndx,1,dcr_compare_rowcnts_rec->owner[dgui_user_ndx].tbl_cnt,d.table_name,
       dcr_compare_rowcnts_rec->owner[dgui_user_ndx].tab[dgui_ndx].table_name)=0)
       dcr_compare_rowcnts_rec->owner[dgui_user_ndx].tbl_cnt = (dcr_compare_rowcnts_rec->owner[
       dgui_user_ndx].tbl_cnt+ 1)
       IF (mod(dcr_compare_rowcnts_rec->owner[dgui_user_ndx].tbl_cnt,100)=1)
        stat = alterlist(dcr_compare_rowcnts_rec->owner[dgui_user_ndx].tab,(dcr_compare_rowcnts_rec->
         owner[dgui_user_ndx].tbl_cnt+ 99))
       ENDIF
       dcr_compare_rowcnts_rec->owner[dgui_user_ndx].tab[dcr_compare_rowcnts_rec->owner[dgui_user_ndx
       ].tbl_cnt].table_name = d.table_name
       IF (dgui_type="SOURCE")
        dcr_compare_rowcnts_rec->owner[dgui_user_ndx].tab[dcr_compare_rowcnts_rec->owner[
        dgui_user_ndx].tbl_cnt].src_tbl_fnd = 1
       ELSE
        dcr_compare_rowcnts_rec->owner[dgui_user_ndx].tab[dcr_compare_rowcnts_rec->owner[
        dgui_user_ndx].tbl_cnt].tgt_tbl_fnd = 1
       ENDIF
      ELSE
       IF (dgui_type="SOURCE")
        dcr_compare_rowcnts_rec->owner[dgui_user_ndx].tab[dgui_ndx].src_tbl_fnd = 1
       ELSE
        dcr_compare_rowcnts_rec->owner[dgui_user_ndx].tab[dgui_ndx].tgt_tbl_fnd = 1
       ENDIF
      ENDIF
     ENDIF
    FOOT REPORT
     IF (dgui_resize=1)
      stat = alterlist(dcr_compare_rowcnts_rec->owner[dgui_user_ndx].tab,dcr_compare_rowcnts_rec->
       owner[dgui_user_ndx].tbl_cnt)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Get list of unique indexes for ",dgui_type)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dba_indexes d
    PLAN (d
     WHERE d.owner=cnvtupper(dcr_compare_rowcnts_rec->owner[dgui_user_ndx].owner_name))
    ORDER BY d.table_name, d.index_name
    HEAD d.table_name
     ind_added = 0, dgui_ndx = locateval(dgui_ndx,1,dcr_compare_rowcnts_rec->owner[dgui_user_ndx].
      tbl_cnt,d.table_name,dcr_compare_rowcnts_rec->owner[dgui_user_ndx].tab[dgui_ndx].table_name)
    DETAIL
     IF (dgui_ndx > 0)
      IF (d.uniqueness="UNIQUE"
       AND ind_added=0)
       IF (dgui_type="SOURCE")
        dcr_compare_rowcnts_rec->owner[dgui_user_ndx].tab[dgui_ndx].src_index_col = concat(
         " /*+ index(d ",trim(d.index_name),") */ count(*) ")
       ELSE
        dcr_compare_rowcnts_rec->owner[dgui_user_ndx].tab[dgui_ndx].tgt_index_col = concat(
         " /*+ index(d ",trim(d.index_name),") */ count(*) ")
       ENDIF
       ind_added = 1
      ENDIF
     ENDIF
    FOOT  d.table_name
     IF (ind_added=0
      AND dgui_ndx > 0)
      IF (dgui_type="SOURCE")
       dcr_compare_rowcnts_rec->owner[dgui_user_ndx].tab[dgui_ndx].src_index_col = " count(*) "
      ELSE
       dcr_compare_rowcnts_rec->owner[dgui_user_ndx].tab[dgui_ndx].tgt_index_col = " count(*) "
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   FOR (dgui_ndx = 1 TO dcr_compare_rowcnts_rec->owner[dgui_user_ndx].tbl_cnt)
     IF ((dcr_compare_rowcnts_rec->owner[dgui_user_ndx].tab[dgui_ndx].src_index_col="")
      AND dgui_type="SOURCE")
      SET dcr_compare_rowcnts_rec->owner[dgui_user_ndx].tab[dgui_ndx].src_index_col = " count(*) "
     ELSEIF ((dcr_compare_rowcnts_rec->owner[dgui_user_ndx].tab[dgui_ndx].tgt_index_col="")
      AND dgui_type="TARGET")
      SET dcr_compare_rowcnts_rec->owner[dgui_user_ndx].tab[dgui_ndx].tgt_index_col = " count(*) "
     ENDIF
   ENDFOR
   IF ((dm_err->debug_flag > 5))
    CALL echorecord(dcr_compare_rowcnts_rec)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcr_prompt_owner_names(null)
   DECLARE dpon_rows_max = i4 WITH protect, constant(23)
   DECLARE dpon_col_max = i4 WITH protect, constant(80)
   DECLARE dpon_node_list = vc WITH protect, noconstant("")
   DECLARE dpon_cnt = i4 WITH protect, noconstant(0)
   DECLARE dpon_row_cnt = i4 WITH protect, noconstant(0)
   DECLARE dpon_col_num = i4 WITH protect, noconstant(2)
   DECLARE dpon_length = i4 WITH protect, noconstant(0)
   DECLARE dpon_exit = i2 WITH protect, noconstant(0)
   DECLARE dpon_ndx = i2 WITH protect, noconstant(0)
   DECLARE dpon_accept = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Owner Name Entry"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   FREE RECORD dpon_users
   RECORD dpon_users(
     1 user_cnt = i4
     1 qual[*]
       2 name = vc
   )
   FREE RECORD dpon_work
   RECORD dpon_work(
     1 owner_cnt = i4
     1 owner[*]
       2 keep = i2
       2 owner_name = vc
   )
   SET dm_err->eproc = "Determine valid database users."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT DISTINCT INTO "nl:"
    d.owner
    FROM dba_tables d
    WHERE  NOT (d.owner IN ("OUTLN", "SYS", "SYSTEM"))
    DETAIL
     dpon_users->user_cnt = (dpon_users->user_cnt+ 1), stat = alterlist(dpon_users->qual,dpon_users->
      user_cnt), dpon_users->qual[dpon_users->user_cnt].name = cnvtlower(d.owner)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dpon_users)
   ENDIF
   IF ((dm_err->debug_flag != 722))
    SET message = window
   ENDIF
   SET help = pos(11,50,10,60)
   SET help =
   SELECT INTO "nl:"
    owner_name = dpon_users->qual[d.seq].name
    FROM (dummyt d  WITH seq = value(dpon_users->user_cnt))
    PLAN (d
     WHERE d.seq > 0)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dpon_work->owner_cnt = (dpon_work->owner_cnt+ 1)
   SET stat = alterlist(dpon_work->owner,dpon_work->owner_cnt)
   SET dpon_work->owner[dpon_work->owner_cnt].owner_name = cnvtlower(currdbuser)
   SET dpon_work->owner[dpon_work->owner_cnt].keep = 1
   WHILE (dpon_exit=0)
     CALL clear(1,1)
     CALL box(1,1,22,131)
     CALL text(1,dpon_col_num,"DATABASE USER ENTRY SCREEN ")
     CALL text(3,dpon_col_num,"Enter database users for comparison of row counts.")
     CALL text(4,dpon_col_num,"Database user name <enter SPACE if finished>:")
     CALL text(7,dpon_col_num,"Database user(s) entered: ")
     CALL text(8,dpon_col_num,
      "<NOTE:If you wish to remove a database user from the list, re-type the user's name and it will be removed.>"
      )
     SET dpon_node_list = ""
     FOR (dpon_cnt = 1 TO dpon_work->owner_cnt)
       IF ((dpon_work->owner[dpon_cnt].keep=1))
        IF ((dpon_work->owner_cnt > 1)
         AND dpon_cnt != 1)
         SET dpon_node_list = concat(dpon_node_list,", ",dpon_work->owner[dpon_cnt].owner_name)
        ELSE
         SET dpon_node_list = dpon_work->owner[dpon_cnt].owner_name
        ENDIF
       ENDIF
     ENDFOR
     SET dpon_cnt = 0
     SET dpon_row_cnt = 9
     WHILE (dpon_cnt < size(dpon_node_list)
      AND dpon_row_cnt < dpon_rows_max)
       CALL clear(dpon_row_cnt,dpon_col_num,129)
       IF (size(dpon_node_list) < dpon_col_max)
        CALL text(dpon_row_cnt,(dpon_col_num+ 2),trim(substring((dpon_cnt+ 1),dpon_col_max,
           dpon_node_list)))
        SET dpon_length = dpon_col_max
       ELSE
        SET dpon_length = findstring(",",substring((dpon_cnt+ 1),dpon_col_max,dpon_node_list),(
         dpon_cnt+ 1),1)
        IF (dpon_length=0)
         SET dpon_length = dpon_col_max
        ENDIF
        CALL text(dpon_row_cnt,(dpon_col_num+ 2),trim(substring((dpon_cnt+ 1),dpon_length,
           dpon_node_list)))
       ENDIF
       SET dpon_cnt = (dpon_cnt+ dpon_length)
       SET dpon_row_cnt = (dpon_row_cnt+ 1)
     ENDWHILE
     CALL accept(4,(52+ dpon_col_num),"P(10);CU"," "
      WHERE curaccept > "")
     SET dpon_accept = cnvtlower(curaccept)
     IF (dpon_accept=" ")
      CALL text(5,dpon_col_num,"Have you finished entering all user names (Y)es,(N)o,(Q)uit?")
      CALL accept(5,(69+ dpon_col_num),"A;cu"," "
       WHERE curaccept IN ("Y", "N", "Q"))
      IF (curaccept="Y")
       SET dpon_exit = 1
      ELSEIF (curaccept="Q")
       SET dpon_exit = 2
       CALL clear(5,2,129)
      ENDIF
     ELSE
      CALL echo(dpon_accept)
      CALL echorecord(dpon_work)
      IF (locateval(dpon_ndx,1,dpon_users->user_cnt,dpon_accept,dpon_users->qual[dpon_ndx].name)=0)
       CALL clear(20,2,130)
       CALL text(20,2,concat("User:",dpon_accept," is not a valid user. Please enter a valid user."))
       CALL pause(3)
      ELSE
       IF (assign(dpon_ndx,locateval(dpon_ndx,1,dpon_work->owner_cnt,dpon_accept,dpon_work->owner[
         dpon_ndx].owner_name)) > 0
        AND dpon_ndx != 1)
        IF ((dpon_work->owner[dpon_ndx].keep=0))
         SET dpon_work->owner[dpon_ndx].keep = 1
        ELSE
         SET dpon_work->owner[dpon_ndx].keep = 0
        ENDIF
       ENDIF
       IF (dpon_ndx=0)
        SET dpon_work->owner_cnt = (dpon_work->owner_cnt+ 1)
        SET stat = alterlist(dpon_work->owner,dpon_work->owner_cnt)
        SET dpon_work->owner[dpon_work->owner_cnt].owner_name = cnvtlower(replace(dpon_accept," ","",
          0))
        SET dpon_work->owner[dpon_work->owner_cnt].keep = 1
       ENDIF
      ENDIF
     ENDIF
   ENDWHILE
   SET help = off
   CALL clear(1,1)
   SET message = nowindow
   IF (dpon_exit=2)
    SET dm_err->emsg = "User elected to quit from Database User Name entry"
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dpon_work)
   ENDIF
   IF ((dpon_work->owner_cnt=0))
    SET dm_err->emsg = "No users entered at User Name Entry prompt."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   FOR (dpon_ndx = 1 TO dpon_work->owner_cnt)
     IF ((dpon_work->owner[dpon_ndx].keep=1))
      SET dcr_compare_rowcnts_rec->owner_cnt = (dcr_compare_rowcnts_rec->owner_cnt+ 1)
      SET stat = alterlist(dcr_compare_rowcnts_rec->owner,dcr_compare_rowcnts_rec->owner_cnt)
      SET dcr_compare_rowcnts_rec->owner[dcr_compare_rowcnts_rec->owner_cnt].owner_name = dpon_work->
      owner[dpon_ndx].owner_name
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 DECLARE dcr_tbl_cnt = i4 WITH protect, noconstant(0)
 DECLARE dcr_cnt_ret = f8 WITH protect, noconstant(0.0)
 DECLARE dcr_owner_cnt = i4 WITH protect, noconstant(0)
 SET width = 132
 IF (check_logfile("dm2_cmp_rowcnts",".log","dm2_cmp_rowcnts")=0)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Starting dm2_cmp_rowcnts"
 CALL disp_msg(" ",dm_err->logfile,0)
 IF ((dcr_compare_rowcnts_rec->owner_cnt=0))
  IF (dcr_prelim(0)=0)
   GO TO exit_program
  ENDIF
 ENDIF
 IF ((dcr_compare_rowcnts_rec->src_read_only=0))
  SET dm2_install_schema->dbase_name = dm2_install_schema->src_dbase_name
  SET dm2_install_schema->u_name = "V500"
  SET dm2_install_schema->p_word = dm2_install_schema->src_v500_p_word
  SET dm2_install_schema->connect_str = dm2_install_schema->src_v500_connect_str
  EXECUTE dm2_connect_to_dbase "CO"
  IF ((dm_err->err_ind=1))
   GO TO exit_program
  ENDIF
 ENDIF
 FOR (dcr_owner_cnt = 1 TO dcr_compare_rowcnts_rec->owner_cnt)
   FOR (dcr_tbl_cnt = 1 TO dcr_compare_rowcnts_rec->owner[dcr_owner_cnt].tbl_cnt)
     IF ((dcr_compare_rowcnts_rec->owner[dcr_owner_cnt].tab[dcr_tbl_cnt].src_tbl_fnd=1))
      IF (dcr_get_count(dcr_compare_rowcnts_rec->owner[dcr_owner_cnt].tab[dcr_tbl_cnt].table_name,
       dcr_compare_rowcnts_rec->owner[dcr_owner_cnt].tab[dcr_tbl_cnt].src_index_col,
       dcr_compare_rowcnts_rec->owner[dcr_owner_cnt].owner_name,dcr_cnt_ret,0,
       "SOURCE")=0)
       GO TO exit_program
      ENDIF
      SET dcr_compare_rowcnts_rec->owner[dcr_owner_cnt].tab[dcr_tbl_cnt].src_row_cnt = dcr_cnt_ret
     ENDIF
   ENDFOR
 ENDFOR
 SET dm2_install_schema->dbase_name = dm2_install_schema->target_dbase_name
 SET dm2_install_schema->u_name = "V500"
 SET dm2_install_schema->p_word = dm2_install_schema->v500_p_word
 SET dm2_install_schema->connect_str = dm2_install_schema->v500_connect_str
 EXECUTE dm2_connect_to_dbase "CO"
 IF ((dm_err->err_ind=1))
  GO TO exit_program
 ENDIF
 FOR (dcr_owner_cnt = 1 TO dcr_compare_rowcnts_rec->owner_cnt)
   FOR (dcr_tbl_cnt = 1 TO dcr_compare_rowcnts_rec->owner[dcr_owner_cnt].tbl_cnt)
     IF ((dcr_compare_rowcnts_rec->owner[dcr_owner_cnt].tab[dcr_tbl_cnt].tgt_tbl_fnd=1))
      IF (dcr_get_count(dcr_compare_rowcnts_rec->owner[dcr_owner_cnt].tab[dcr_tbl_cnt].table_name,
       dcr_compare_rowcnts_rec->owner[dcr_owner_cnt].tab[dcr_tbl_cnt].tgt_index_col,
       dcr_compare_rowcnts_rec->owner[dcr_owner_cnt].owner_name,dcr_cnt_ret,0,
       "TARGET")=0)
       GO TO exit_program
      ENDIF
      SET dcr_compare_rowcnts_rec->owner[dcr_owner_cnt].tab[dcr_tbl_cnt].tgt_row_cnt = dcr_cnt_ret
      IF ((dcr_compare_rowcnts_rec->owner[dcr_owner_cnt].tab[dcr_tbl_cnt].tgt_row_cnt !=
      dcr_compare_rowcnts_rec->owner[dcr_owner_cnt].tab[dcr_tbl_cnt].src_row_cnt))
       SET dcr_compare_rowcnts_rec->owner[dcr_owner_cnt].num_mismatch = (dcr_compare_rowcnts_rec->
       owner[dcr_owner_cnt].num_mismatch+ 1)
      ENDIF
     ELSE
      IF ((dcr_compare_rowcnts_rec->owner[dcr_owner_cnt].tab[dcr_tbl_cnt].src_tbl_fnd !=
      dcr_compare_rowcnts_rec->owner[dcr_owner_cnt].tab[dcr_tbl_cnt].tgt_tbl_fnd))
       SET dcr_compare_rowcnts_rec->owner[dcr_owner_cnt].num_mismatch = (dcr_compare_rowcnts_rec->
       owner[dcr_owner_cnt].num_mismatch+ 1)
      ENDIF
     ENDIF
     IF ((dcr_compare_rowcnts_rec->owner[dcr_owner_cnt].tab[dcr_tbl_cnt].tgt_tbl_fnd=0))
      SET dcr_compare_rowcnts_rec->owner[dcr_owner_cnt].tab[dcr_tbl_cnt].tgt_row_cnt = - (1)
     ENDIF
     IF ((dcr_compare_rowcnts_rec->owner[dcr_owner_cnt].tab[dcr_tbl_cnt].src_tbl_fnd=0))
      SET dcr_compare_rowcnts_rec->owner[dcr_owner_cnt].tab[dcr_tbl_cnt].src_row_cnt = - (1)
     ENDIF
   ENDFOR
 ENDFOR
 IF ((dm_err->debug_flag > 5))
  CALL echorecord(dcr_compare_rowcnts_rec)
 ENDIF
 IF (dcr_create_report(null)=0)
  GO TO exit_program
 ENDIF
 GO TO exit_program
#exit_program
 CALL dcr_get_count("x","x","x",dcr_cnt_ret,1,
  "x")
 SET dm_err->eproc = "Dm2_compare_rowcnts completed"
 CALL final_disp_msg("dm2_cmp_rowcnts")
END GO
