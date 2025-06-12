CREATE PROGRAM dm_rmc_rdds_info
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
 DECLARE daf_is_blank(dib_str=vc) = i2
 DECLARE daf_is_not_blank(dinb_str=vc) = i2
 SUBROUTINE daf_is_blank(dib_str)
  IF (textlen(trim(dib_str,3)) > 0)
   RETURN(false)
  ENDIF
  RETURN(true)
 END ;Subroutine
 SUBROUTINE daf_is_not_blank(dinb_str)
  IF (textlen(trim(dinb_str,3)) > 0)
   RETURN(true)
  ENDIF
  RETURN(false)
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
 IF (validate(quick_metadata)=0)
  FREE RECORD quick_metadata
  RECORD quick_metadata(
    1 table_name = vc
    1 table_suffix = vc
    1 rtbl_name = vc
    1 reference_ind = i4
    1 mergeable_ind = i4
    1 owner_name = vc
    1 data_model_section = vc
    1 merge_delete_ind = i4
    1 rdds_list_reason = vc
    1 doc_cnt = i4
    1 dtd_updt_cnt = i4
    1 inhouse_ind = i2
    1 doc_qual[*]
      2 definition = vc
      2 user_id = vc
      2 updt_dt_tm = dq8
      2 create_dt_tm = dq8
    1 ovr_mergeable_ind = i4
    1 ovr_merge_delete_ind = i4
    1 ovr_nonmerge_cols = vc
    1 ovr_merge_cols = vc
    1 ovr_cnt = i4
    1 ovr_qual[*]
      2 ovr_description = vc
      2 ovr_instance = i4
      2 ovr_name = vc
      2 ovr_type = vc
      2 ovr_version = i4
      2 mergeable_ind = i2
      2 merge_delete_ind = i2
      2 col_ovr_cnt = i4
      2 merge_cols[*]
        3 ovr_data = vc
      2 nonmerge_cols_cnt = i4
      2 nonmerge_cols[*]
        3 ovr_data = vc
    1 mixed_ind = i4
    1 version_algorithm = vc
    1 ui_cnt = i4
    1 ui_qual[*]
      2 column_name = vc
    1 parent_cnt = i4
    1 parent_qual[*]
      2 table_name = vc
      2 column_name = vc
      2 mergeable_ind = i4
      2 reference_ind = i4
    1 ndx_cnt = i4
    1 ndx_qual[*]
      2 index_name = vc
      2 uniqueness = vc
      2 ndx_col_cnt = i4
      2 ndx_col_qual[*]
        3 column_name = vc
    1 id_cnt = i4
    1 id_qual[*]
      2 column_name = vc
      2 root_entity_name = vc
      2 root_entity_attr = vc
      2 root_entity_ind = i2
      2 root_entity_refmrg = vc
      2 exception_flg = i4
      2 parent_entity_col = vc
      2 sequence_name = vc
      2 code_set = i4
      2 code_set_dup = vc
      2 constant_value = vc
      2 merge_delete_ind = i4
      2 unique_ident_ind = i4
      2 defining_attribute_ind = i4
      2 dcd_updt_cnt = i4
      2 description = vc
    1 should_not_merge = vc
    1 refchg_filter = vc
    1 filter_parm_cnt = i4
    1 filter_parm[*]
      2 column_name = vc
    1 filter_test_cnt = i4
    1 filter_test[*]
      2 test_nbr = vc
      2 test_str = vc
      2 mover_str = vc
    1 refchg_dml_cnt = i4
    1 refchg_dml[*]
      2 column_name = vc
      2 dml_attribute = vc
      2 dml_value = vc
    1 custom_cols_cnt = i4
    1 custom_cols[*]
      2 column_name = vc
      2 object_name = vc
      2 execution_flag = i4
    1 refchg_pe_abbrev = vc
    1 pe_abbrev_cnt = i4
    1 pe_abbrev[*]
      2 col_name = vc
      2 data_value = vc
      2 pe_table_name = vc
    1 out_file = vc
    1 cvs_cnt = i4
    1 cvs[*]
      2 code_set = i4
      2 description = vc
      2 dup_check = vc
    1 current_state_ind = i2
    1 dual_build_trg = vc
  )
 ENDIF
 DECLARE get_metadata(null) = null
 DECLARE drri_table_name_validate(table_name_in=vc) = null
 DECLARE drri_get_inhouse_data(null) = null
 DECLARE drri_get_mixed(null) = null
 DECLARE drri_get_ovr_qual(null) = null
 DECLARE drri_get_id_qual(null) = null
 DECLARE drri_get_code_value(null) = null
 DECLARE drri_get_refchg_filter(null) = null
 DECLARE drri_get_filter_parm(null) = null
 DECLARE drri_get_filter_test(null) = null
 DECLARE drri_get_refchg_dml(null) = null
 DECLARE drri_get_custom_cols(null) = null
 DECLARE drri_get_pe_abbrev(null) = null
 DECLARE drri_get_parent_qual(null) = null
 DECLARE drri_get_ndx_qual(null) = null
 DECLARE drri_get_current_state_ind(null) = null
 DECLARE build_report(null) = null
 DECLARE drri_ui_info(null) = null
 SUBROUTINE drri_table_name_validate(table_name_in)
   SET quick_metadata->table_name = " "
   SET quick_metadata->table_suffix = "<no suffix>"
   SET dm_err->eproc = "Getting table_name from dm_tables_doc based on prefix"
   SELECT INTO "nl:"
    FROM dm_tables_doc d
    WHERE ((d.table_name=table_name_in) OR (d.table_suffix=table_name_in))
     AND d.table_name=d.full_table_name
    DETAIL
     quick_metadata->table_suffix = d.table_suffix, quick_metadata->table_name = d.table_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   IF (daf_is_blank(quick_metadata->table_name))
    SET dm_err->eproc = "Invalid table_name or suffix in domain"
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drri_get_inhouse_data(null)
   IF (daf_is_blank(quick_metadata->table_name))
    SET dm_err->eproc = "TABLE_NAME not set in quick_metadata"
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   SET quick_metadata->rtbl_name = cutover_tab_name(quick_metadata->table_name,quick_metadata->
    table_suffix)
   SET dm_err->eproc = "Getting basic data including inhouse domain data"
   SELECT INTO "nl:"
    FROM dm_data_model_section ddms,
     dm_tables_doc dtd
    WHERE (dtd.table_name=quick_metadata->table_name)
     AND dtd.table_name=dtd.full_table_name
     AND dtd.data_model_section=ddms.data_model_section
    DETAIL
     quick_metadata->mergeable_ind = dtd.mergeable_ind, quick_metadata->reference_ind = dtd
     .reference_ind, quick_metadata->owner_name = ddms.owner_name,
     quick_metadata->data_model_section = dtd.data_model_section, quick_metadata->merge_delete_ind =
     dtd.merge_delete_ind, quick_metadata->table_suffix = dtd.table_suffix,
     quick_metadata->dtd_updt_cnt = dtd.updt_cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   SET dm_err->eproc = "Getting rdds_list_reason reason from rdds_list_reason"
   SELECT INTO "nl:"
    FROM rdds_list_reason rlr,
     rdds_list rl
    WHERE (rl.table_name=quick_metadata->table_name)
     AND rl.list_reason_id=rlr.rdds_list_reason_id
     AND rl.active_ind=1
    DETAIL
     quick_metadata->rdds_list_reason = rlr.reason
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   SET dm_err->eproc = "Getting doc_qual info from dm_object_doc"
   SELECT INTO "nl:"
    FROM dm_object_doc dod
    WHERE (((dod.object_parent_name=quick_metadata->table_name)) OR ((dod.object_name=quick_metadata
    ->table_name)))
     AND dod.subject_area="RDDS"
    ORDER BY dod.create_dt_tm
    DETAIL
     quick_metadata->doc_cnt = (quick_metadata->doc_cnt+ 1), stat = alterlist(quick_metadata->
      doc_qual,quick_metadata->doc_cnt)
     IF (cnvtupper(dod.object_name) != cnvtupper(quick_metadata->table_name))
      quick_metadata->doc_qual[quick_metadata->doc_cnt].definition = build("(",dod.object_name,"):",
       dod.definition)
     ELSE
      quick_metadata->doc_qual[quick_metadata->doc_cnt].definition = dod.definition
     ENDIF
     quick_metadata->doc_qual[quick_metadata->doc_cnt].user_id = dod.user_id, quick_metadata->
     doc_qual[quick_metadata->doc_cnt].updt_dt_tm = dod.updt_dt_tm, quick_metadata->doc_qual[
     quick_metadata->doc_cnt].create_dt_tm = dod.create_dt_tm
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drri_get_outhouse_dm_tables_doc(null)
   IF (daf_is_blank(quick_metadata->table_name))
    SET dm_err->eproc = "TABLE_NAME not set in quick_metadata"
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   SET quick_metadata->rtbl_name = cutover_tab_name(quick_metadata->table_name,quick_metadata->
    table_suffix)
   SET dm_err->eproc = "Getting basic data including out outhouse domain data"
   SELECT INTO "nl:"
    FROM dm_tables_doc dtd
    WHERE (dtd.table_name=quick_metadata->table_name)
     AND dtd.table_name=dtd.full_table_name
    DETAIL
     quick_metadata->mergeable_ind = dtd.mergeable_ind, quick_metadata->reference_ind = dtd
     .reference_ind, quick_metadata->owner_name = "<INFO NOT FOUND>",
     quick_metadata->data_model_section = dtd.data_model_section, quick_metadata->merge_delete_ind =
     dtd.merge_delete_ind, quick_metadata->table_suffix = dtd.table_suffix,
     quick_metadata->dtd_updt_cnt = dtd.updt_cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drri_ui_info(null)
   SET dm_err->eproc = "Getting UI data including column_name and ui_count"
   IF (daf_is_blank(quick_metadata->table_name))
    SET dm_err->eproc = "TABLE_NAME not set in quick_metadata"
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   SELECT
    IF ((quick_metadata->merge_delete_ind > 0))
     WHERE dcd.merge_delete_ind=1
      AND (dcd.table_name=quick_metadata->table_name)
    ELSE
     WHERE dcd.unique_ident_ind=1
      AND (dcd.table_name=quick_metadata->table_name)
    ENDIF
    INTO "nl:"
    FROM dm_columns_doc dcd
    ORDER BY dcd.column_name
    HEAD REPORT
     quick_metadata->ui_cnt = 0
    DETAIL
     quick_metadata->ui_cnt = (quick_metadata->ui_cnt+ 1), stat = alterlist(quick_metadata->ui_qual,
      quick_metadata->ui_cnt), quick_metadata->ui_qual[quick_metadata->ui_cnt].column_name = dcd
     .column_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drri_get_mixed(null)
   IF (daf_is_blank(quick_metadata->table_name))
    SET dm_err->eproc = "TABLE_NAME not set in quick_metadata"
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   IF ((quick_metadata->reference_ind=0))
    SET dm_err->eproc = "Getting mixed_ind FROM dm_rdds_refmrg_tables"
    SELECT INTO "nl:"
     FROM dm_rdds_refmrg_tables d
     WHERE (d.table_name=quick_metadata->table_name)
     DETAIL
      quick_metadata->mixed_ind = 1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(null)
    ENDIF
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drri_get_ovr_qual(null)
   IF (daf_is_blank(quick_metadata->table_name))
    SET dm_err->eproc = "TABLE_NAME not set in quick_metadata"
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   SET dm_err->eproc = "Getting ovr_qual FROM DM_RDDS_OVERRIDE_REQ and DM_RDDS_OVERRIDE_TBL_DOC"
   SELECT INTO "nl:"
    FROM dm_rdds_override_req dror,
     dm_rdds_override_tbl_doc drotd
    WHERE dror.table_name=drotd.table_name
     AND dror.override_instance=drotd.override_instance
     AND (dror.table_name=quick_metadata->table_name)
    ORDER BY drotd.override_instance
    HEAD REPORT
     quick_metadata->ovr_cnt = 0
    DETAIL
     quick_metadata->ovr_cnt = (quick_metadata->ovr_cnt+ 1), stat = alterlist(quick_metadata->
      ovr_qual,quick_metadata->ovr_cnt), quick_metadata->ovr_qual[quick_metadata->ovr_cnt].
     ovr_description = dror.req_description,
     quick_metadata->ovr_qual[quick_metadata->ovr_cnt].ovr_instance = dror.override_instance,
     quick_metadata->ovr_qual[quick_metadata->ovr_cnt].ovr_name = dror.req_name, quick_metadata->
     ovr_qual[quick_metadata->ovr_cnt].ovr_type = dror.req_type,
     quick_metadata->ovr_qual[quick_metadata->ovr_cnt].ovr_version = dror.req_version_nbr,
     quick_metadata->ovr_qual[quick_metadata->ovr_cnt].mergeable_ind = nullval(drotd.mergeable_ind,
      quick_metadata->mergeable_ind), quick_metadata->ovr_qual[quick_metadata->ovr_cnt].
     merge_delete_ind = nullval(drotd.merge_delete_ind,quick_metadata->merge_delete_ind),
     quick_metadata->ovr_mergeable_ind = quick_metadata->ovr_qual[quick_metadata->ovr_cnt].
     mergeable_ind, quick_metadata->ovr_merge_delete_ind = quick_metadata->ovr_qual[quick_metadata->
     ovr_cnt].merge_delete_ind
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   SET dm_err->eproc = "Getting overide info from DM_RDDS_OVERRIDE_REQ and DM_RDDS_OVERRIDE_COL_DOC"
   SELECT DISTINCT INTO "nl:"
    sn_ni = nullind(drocd.sequence_name), cs_ni = nullind(drocd.code_set), uii_ni = nullind(drocd
     .unique_ident_ind),
    ren_ni = nullind(drocd.root_entity_name), rea_ni = nullind(drocd.root_entity_attr), cv_ni =
    nullind(drocd.constant_value),
    pec_ni = nullind(drocd.parent_entity_col), ef_ni = nullind(drocd.exception_flg), dai_ni = nullind
    (drocd.defining_attribute_ind),
    mdi_ni = nullind(drocd.merge_delete_ind)
    FROM dm_rdds_override_req dror,
     dm_rdds_override_col_doc drocd
    WHERE dror.table_name=drocd.table_name
     AND dror.override_instance=drocd.override_instance
     AND (dror.table_name=quick_metadata->table_name)
    ORDER BY drocd.override_instance
    HEAD REPORT
     nonmerge_cols_cnt = 0, ovr_col_cnt = 0, oidx = 0,
     oi = 0
    HEAD drocd.override_instance
     oidx = 0, oidx = locateval(oi,1,quick_metadata->ovr_cnt,drocd.override_instance,quick_metadata->
      ovr_qual[oi].ovr_instance,
      dror.req_name,quick_metadata->ovr_qual[oi].ovr_name)
    DETAIL
     IF (oidx > 0)
      ovr_col_cnt = (ovr_col_cnt+ 1), stat = alterlist(quick_metadata->ovr_qual[oidx].merge_cols,
       ovr_col_cnt), quick_metadata->ovr_qual[oidx].merge_cols[ovr_col_cnt].ovr_data = drocd
      .column_name
      IF (sn_ni=0)
       quick_metadata->ovr_qual[oidx].merge_cols[ovr_col_cnt].ovr_data = build(quick_metadata->
        ovr_qual[oidx].merge_cols[ovr_col_cnt].ovr_data,": SEQUENCE_NAME=",drocd.sequence_name)
      ENDIF
      IF (cs_ni=0)
       quick_metadata->ovr_qual[oidx].merge_cols[ovr_col_cnt].ovr_data = build(quick_metadata->
        ovr_qual[oidx].merge_cols[ovr_col_cnt].ovr_data,": CODE_SET=",drocd.code_set)
      ENDIF
      IF (uii_ni=0)
       quick_metadata->ovr_qual[oidx].merge_cols[ovr_col_cnt].ovr_data = build(quick_metadata->
        ovr_qual[oidx].merge_cols[ovr_col_cnt].ovr_data,": UNIQUE_IDENT_IND=",drocd.unique_ident_ind)
      ENDIF
      IF (ren_ni=0)
       quick_metadata->ovr_qual[oidx].merge_cols[ovr_col_cnt].ovr_data = build(quick_metadata->
        ovr_qual[oidx].merge_cols[ovr_col_cnt].ovr_data,": ROOT_ENTITY_NAME=",drocd.root_entity_name)
      ENDIF
      IF (rea_ni=0)
       quick_metadata->ovr_qual[oidx].merge_cols[ovr_col_cnt].ovr_data = build(quick_metadata->
        ovr_qual[oidx].merge_cols[ovr_col_cnt].ovr_data,": ROOT_ENTITY_ATTR=",drocd.root_entity_attr)
      ENDIF
      IF (cv_ni=0)
       quick_metadata->ovr_qual[oidx].merge_cols[ovr_col_cnt].ovr_data = build(quick_metadata->
        ovr_qual[oidx].merge_cols[ovr_col_cnt].ovr_data,": CONSTANT_VALUE=",drocd.constant_value)
      ENDIF
      IF (pec_ni=0)
       quick_metadata->ovr_qual[oidx].merge_cols[ovr_col_cnt].ovr_data = build(quick_metadata->
        ovr_qual[oidx].merge_cols[ovr_col_cnt].ovr_data,": PARENT_ENTITY_COL=",drocd
        .parent_entity_col)
      ENDIF
      IF (ef_ni=0)
       quick_metadata->ovr_qual[oidx].merge_cols[ovr_col_cnt].ovr_data = build(quick_metadata->
        ovr_qual[oidx].merge_cols[ovr_col_cnt].ovr_data,": EXCEPTION_FLG=",drocd.exception_flg)
      ENDIF
      IF (dai_ni=0)
       quick_metadata->ovr_qual[oidx].merge_cols[ovr_col_cnt].ovr_data = build(quick_metadata->
        ovr_qual[oidx].merge_cols[ovr_col_cnt].ovr_data,": DEFINING_ATTRIBUTE_IND=",drocd
        .defining_attribute_ind)
      ENDIF
      IF (mdi_ni=0)
       quick_metadata->ovr_qual[oidx].merge_cols[ovr_col_cnt].ovr_data = build(quick_metadata->
        ovr_qual[oidx].merge_cols[ovr_col_cnt].ovr_data,": MERGE_DELETE_IND=",drocd.merge_delete_ind)
      ENDIF
     ELSE
      nonmerge_cols_cnt = (nonmerge_cols_cnt+ 1), stat = alterlist(quick_metadata->ovr_qual[oidx].
       nonmerge_cols,nonmerge_cols_cnt), quick_metadata->ovr_qual[oidx].nonmerge_cols[
      nonmerge_cols_cnt] = drocd.column_name
     ENDIF
    FOOT  drocd.override_instance
     quick_metadata->ovr_qual[oi].col_ovr_cnt = ovr_col_cnt, quick_metadata->ovr_qual[oi].
     nonmerge_cols_cnt = nonmerge_cols_cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drri_get_id_qual(null)
   IF (daf_is_blank(quick_metadata->table_name))
    SET dm_err->eproc = "TABLE_NAME not set in quick_metadata"
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   SET dm_err->eproc = "Getting info for id_qual from dm_columns_doc"
   SELECT INTO "nl:"
    FROM dm_columns_doc dcd
    WHERE (dcd.table_name=quick_metadata->table_name)
     AND ((substring(- (3),3,dcd.column_name)="_ID") OR (((substring(- (3),3,dcd.column_name)="_CD")
     OR (((dcd.column_name="CODE_VALUE") OR (((dcd.column_name IN (
    (SELECT
     di.info_name
     FROM dm_info di
     WHERE di.info_domain=concat("RDDS TRANS COLUMN:",quick_metadata->table_name)))) OR (((dcd
    .table_name=dcd.root_entity_name
     AND dcd.column_name=dcd.root_entity_attr) OR (((dcd.exception_flg > 0) OR (((dcd
    .unique_ident_ind > 0) OR (dcd.merge_delete_ind > 0)) )) )) )) )) )) ))
     AND  NOT (dcd.column_name IN ("UPDT_ID", "ACTIVE_STATUS_CD", "ACTIVE_STATUS_PRSNL_ID"))
    ORDER BY dcd.column_name
    DETAIL
     quick_metadata->id_cnt = (quick_metadata->id_cnt+ 1), stat = alterlist(quick_metadata->id_qual,
      quick_metadata->id_cnt), quick_metadata->id_qual[quick_metadata->id_cnt].column_name = dcd
     .column_name,
     quick_metadata->id_qual[quick_metadata->id_cnt].root_entity_name = trim(dcd.root_entity_name,3),
     quick_metadata->id_qual[quick_metadata->id_cnt].root_entity_attr = trim(dcd.root_entity_attr,3),
     quick_metadata->id_qual[quick_metadata->id_cnt].root_entity_refmrg = "NOT FOUND",
     quick_metadata->id_qual[quick_metadata->id_cnt].exception_flg = dcd.exception_flg,
     quick_metadata->id_qual[quick_metadata->id_cnt].parent_entity_col = dcd.parent_entity_col,
     quick_metadata->id_qual[quick_metadata->id_cnt].sequence_name = dcd.sequence_name,
     quick_metadata->id_qual[quick_metadata->id_cnt].constant_value = dcd.constant_value,
     quick_metadata->id_qual[quick_metadata->id_cnt].defining_attribute_ind = dcd
     .defining_attribute_ind, quick_metadata->id_qual[quick_metadata->id_cnt].unique_ident_ind = dcd
     .unique_ident_ind,
     quick_metadata->id_qual[quick_metadata->id_cnt].merge_delete_ind = dcd.merge_delete_ind,
     quick_metadata->id_qual[quick_metadata->id_cnt].dcd_updt_cnt = dcd.updt_cnt
     IF (dcd.table_name=dcd.root_entity_name
      AND dcd.column_name=dcd.root_entity_attr)
      quick_metadata->id_qual[quick_metadata->id_cnt].root_entity_ind = 1
     ENDIF
     quick_metadata->id_qual[quick_metadata->id_cnt].code_set = dcd.code_set, quick_metadata->
     id_qual[quick_metadata->id_cnt].code_set_dup = "NOT FOUND", quick_metadata->id_qual[
     quick_metadata->id_cnt].description = concat(trim(dcd.definition,3)," ",trim(dcd.description,3))
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   IF ((quick_metadata->id_cnt > 0))
    SET dm_err->eproc = "Getting id_qual->code_set_dup info from code_value_set"
    SELECT INTO "nl:"
     FROM code_value_set cs,
      (dummyt d  WITH seq = value(quick_metadata->id_cnt))
     PLAN (d
      WHERE (quick_metadata->id_qual[d.seq].code_set > 0)
       AND (quick_metadata->id_qual[d.seq].code_set_dup="NOT FOUND"))
      JOIN (cs
      WHERE (cs.code_set=quick_metadata->id_qual[d.seq].code_set))
     HEAD REPORT
      csi = 0, cri = 0, fri = 0
     DETAIL
      IF ((quick_metadata->id_qual[d.seq].code_set_dup="NOT FOUND"))
       quick_metadata->id_qual[d.seq].code_set_dup = "DupChk"
      ENDIF
      IF (cs.cdf_meaning_dup_ind=1)
       quick_metadata->id_qual[d.seq].code_set_dup = concat(quick_metadata->id_qual[d.seq].
        code_set_dup,"/cdf_meaning")
      ENDIF
      IF (cs.display_dup_ind=1)
       quick_metadata->id_qual[d.seq].code_set_dup = concat(quick_metadata->id_qual[d.seq].
        code_set_dup,"/display")
      ENDIF
      IF (cs.display_key_dup_ind=1)
       quick_metadata->id_qual[d.seq].code_set_dup = concat(quick_metadata->id_qual[d.seq].
        code_set_dup,"/display_key")
      ENDIF
      IF (cs.definition_dup_ind=1)
       quick_metadata->id_qual[d.seq].code_set_dup = concat(quick_metadata->id_qual[d.seq].
        code_set_dup,"/definition")
      ENDIF
      IF (cs.active_ind_dup_ind=1)
       quick_metadata->id_qual[d.seq].code_set_dup = concat(quick_metadata->id_qual[d.seq].
        code_set_dup,"/active_ind")
      ENDIF
      IF (cs.alias_dup_ind=1)
       quick_metadata->id_qual[d.seq].code_set_dup = concat(quick_metadata->id_qual[d.seq].
        code_set_dup,"/alias")
      ENDIF
      IF ((d.seq < quick_metadata->id_cnt))
       cri = (d.seq+ 1), fri = 1
       WHILE (fri > 0
        AND (cri < quick_metadata->id_cnt))
        fri = locateval(fri,cri,quick_metadata->id_cnt,quick_metadata->id_qual[d.seq].code_set,
         quick_metadata->id_qual[fri].code_set),
        IF (fri > 0)
         quick_metadata->id_qual[fri].code_set_dup = quick_metadata->id_qual[d.seq].code_set_dup, cri
          = (fri+ 1)
        ENDIF
       ENDWHILE
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(null)
    ENDIF
    SET dm_err->eproc = "Getting code_set_dup info from DM_AFD_CODE_VALUE_SET for id_qual"
    SELECT INTO "nl:"
     FROM dm_afd_code_value_set cs,
      (dummyt d  WITH seq = value(quick_metadata->id_cnt))
     PLAN (d
      WHERE (quick_metadata->id_qual[d.seq].code_set > 0)
       AND (quick_metadata->id_qual[d.seq].code_set_dup="NOT FOUND"))
      JOIN (cs
      WHERE (cs.code_set=quick_metadata->id_qual[d.seq].code_set)
       AND (cs.schema_date=
      (SELECT
       max(x.schema_date)
       FROM dm_afd_code_value_set x
       WHERE (x.code_set=quick_metadata->id_qual[d.seq].code_set))))
     HEAD REPORT
      csi = 0, cri = 0, fri = 0
     DETAIL
      IF ((quick_metadata->id_qual[d.seq].code_set_dup="NOT FOUND"))
       quick_metadata->id_qual[d.seq].code_set_dup = "DupChk"
      ENDIF
      IF (cs.cdf_meaning_dup_ind=1)
       quick_metadata->id_qual[d.seq].code_set_dup = concat(quick_metadata->id_qual[d.seq].
        code_set_dup,"/cdf_meaning")
      ENDIF
      IF (cs.display_dup_ind=1)
       quick_metadata->id_qual[d.seq].code_set_dup = concat(quick_metadata->id_qual[d.seq].
        code_set_dup,"/display")
      ENDIF
      IF (cs.display_key_dup_ind=1)
       quick_metadata->id_qual[d.seq].code_set_dup = concat(quick_metadata->id_qual[d.seq].
        code_set_dup,"/display_key")
      ENDIF
      IF (cs.definition_dup_ind=1)
       quick_metadata->id_qual[d.seq].code_set_dup = concat(quick_metadata->id_qual[d.seq].
        code_set_dup,"/definition")
      ENDIF
      IF (cs.active_ind_dup_ind=1)
       quick_metadata->id_qual[d.seq].code_set_dup = concat(quick_metadata->id_qual[d.seq].
        code_set_dup,"/active_ind")
      ENDIF
      IF (cs.alias_dup_ind=1)
       quick_metadata->id_qual[d.seq].code_set_dup = concat(quick_metadata->id_qual[d.seq].
        code_set_dup,"/alias")
      ENDIF
      IF ((d.seq < quick_metadata->id_cnt))
       cri = (d.seq+ 1), fri = 1
       WHILE (fri > 0
        AND (cri < quick_metadata->id_cnt))
        fri = locateval(fri,cri,quick_metadata->id_cnt,quick_metadata->id_qual[d.seq].code_set,
         quick_metadata->id_qual[fri].code_set),
        IF (fri > 0)
         quick_metadata->id_qual[fri].code_set_dup = quick_metadata->id_qual[d.seq].code_set_dup, cri
          = (fri+ 1)
        ENDIF
       ENDWHILE
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(null)
    ENDIF
    SET dm_err->eproc = "Getting id_qual duplicate information"
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(quick_metadata->id_cnt))
     PLAN (d
      WHERE (quick_metadata->id_qual[d.seq].code_set > 0)
       AND (quick_metadata->id_qual[d.seq].code_set_dup="DupChk"))
     DETAIL
      quick_metadata->id_qual[d.seq].code_set_dup = "DupChk/NOT SET"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(null)
    ENDIF
    SET dm_err->eproc = "Getting id_qual refernce and mergeable information"
    SELECT INTO "nl:"
     FROM dm_tables_doc dtd,
      (dummyt d  WITH seq = value(quick_metadata->id_cnt))
     PLAN (d
      WHERE (quick_metadata->id_qual[d.seq].root_entity_name > " ")
       AND (quick_metadata->id_qual[d.seq].root_entity_refmrg="NOT FOUND"))
      JOIN (dtd
      WHERE (dtd.table_name=quick_metadata->id_qual[d.seq].root_entity_name))
     HEAD REPORT
      cri = 0, fri = 0
     DETAIL
      IF (dtd.mergeable_ind=1)
       quick_metadata->id_qual[d.seq].root_entity_refmrg = "Mergeable=1"
      ELSE
       quick_metadata->id_qual[d.seq].root_entity_refmrg = "Mergeable=0"
      ENDIF
      IF (dtd.reference_ind=1)
       quick_metadata->id_qual[d.seq].root_entity_refmrg = concat("Reference=1 / ",quick_metadata->
        id_qual[d.seq].root_entity_refmrg)
      ELSE
       quick_metadata->id_qual[d.seq].root_entity_refmrg = concat("Reference=0 / ",quick_metadata->
        id_qual[d.seq].root_entity_refmrg)
      ENDIF
      IF ((d.seq < quick_metadata->id_cnt))
       cri = (d.seq+ 1), fri = 1
       WHILE (fri > 0
        AND (cri < quick_metadata->id_cnt))
        fri = locateval(fri,cri,quick_metadata->id_cnt,quick_metadata->id_qual[d.seq].
         root_entity_name,quick_metadata->id_qual[fri].root_entity_name),
        IF (fri > 0)
         quick_metadata->id_qual[fri].root_entity_refmrg = quick_metadata->id_qual[d.seq].
         root_entity_refmrg, cri = (fri+ 1)
        ENDIF
       ENDWHILE
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(null)
    ENDIF
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drri_get_code_value(null)
   IF (daf_is_blank(quick_metadata->table_name))
    SET dm_err->eproc = "TABLE_NAME not set in quick_metadata"
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   SET dm_err->eproc = "Getting active_ind from code_value info"
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set IN (255351, 4001912, 4002213)
     AND cv.display_key=cnvtalphanum(quick_metadata->table_name)
     AND (cv.display=quick_metadata->table_name)
    DETAIL
     IF (cv.code_set=255351)
      quick_metadata->version_algorithm = concat(trim(cv.cdf_meaning),evaluate(cv.active_ind,1,
        "(ACTIVE)","(INACTIVE)"))
     ENDIF
     IF (cv.code_set=4001912)
      quick_metadata->should_not_merge = concat(trim(cv.cdf_meaning),evaluate(cv.active_ind,1,
        "(ACTIVE)","(INACTIVE)"))
     ENDIF
     IF (cv.code_set=4002213)
      quick_metadata->dual_build_trg = concat(trim(cv.cdf_meaning),evaluate(cv.active_ind,1,
        "(ACTIVE)","(INACTIVE)"))
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drri_get_refchg_filter(null)
   IF (daf_is_blank(quick_metadata->table_name))
    SET dm_err->eproc = "TABLE_NAME not set in quick_metadata"
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   SET quick_metadata->refchg_filter = " "
   SET dm_err->eproc = "Getting refchg_filter info from dm_refchg_filter"
   SELECT INTO "nl:"
    FROM dm_refchg_filter drf
    WHERE (drf.table_name=quick_metadata->table_name)
    ORDER BY drf.active_ind DESC
    DETAIL
     IF (drf.active_ind=1)
      IF (drf.filter_type IN ("INCLUDE", "EXCLUDE"))
       quick_metadata->refchg_filter = build(drf.filter_type," - ACTIVE")
      ELSE
       quick_metadata->refchg_filter = "ACTIVE"
      ENDIF
     ELSE
      quick_metadata->refchg_filter = "INACTIVE"
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drri_get_filter_parm(null)
   IF (daf_is_blank(quick_metadata->table_name))
    SET dm_err->eproc = "TABLE_NAME not set in quick_metadata"
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   SET stat = alterlist(quick_metadata->filter_parm,0)
   SET dm_err->eproc = "Getting filter_parm info from dm_refchg_filter_parm"
   SELECT INTO "nl:"
    FROM dm_refchg_filter_parm drf
    WHERE (drf.table_name=quick_metadata->table_name)
    ORDER BY drf.parm_nbr
    HEAD REPORT
     quick_metadata->filter_parm_cnt = 0
    DETAIL
     quick_metadata->filter_parm_cnt = (quick_metadata->filter_parm_cnt+ 1), stat = alterlist(
      quick_metadata->filter_parm,quick_metadata->filter_parm_cnt), quick_metadata->filter_parm[
     quick_metadata->filter_parm_cnt].column_name = concat(evaluate(drf.active_ind,1,"(ACTIVE)   ",
       "(INACTIVE) "),drf.column_name)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drri_get_filter_test(null)
   IF (daf_is_blank(quick_metadata->table_name))
    SET dm_err->eproc = "TABLE_NAME not set in quick_metadata"
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   SET stat = alterlist(quick_metadata->filter_test,0)
   SET dm_err->eproc = "Getting filter_test info from dm_refchg_filter_test"
   SELECT INTO "nl:"
    FROM dm_refchg_filter_test drf
    WHERE (drf.table_name=quick_metadata->table_name)
    ORDER BY drf.test_nbr
    HEAD REPORT
     quick_metadata->filter_test_cnt = 0
    DETAIL
     quick_metadata->filter_test_cnt = (quick_metadata->filter_test_cnt+ 1), stat = alterlist(
      quick_metadata->filter_test,quick_metadata->filter_test_cnt), quick_metadata->filter_test[
     quick_metadata->filter_test_cnt].test_nbr = build("Test Nbr:",drf.test_nbr,evaluate(drf
       .active_ind,1,"(ACTIVE)","(INACTIVE)")),
     quick_metadata->filter_test[quick_metadata->filter_test_cnt].test_str = trim(drf.test_str)
     IF (daf_is_not_blank(drf.mover_string))
      quick_metadata->filter_test[quick_metadata->filter_test_cnt].mover_str = trim(drf.mover_string)
     ELSE
      quick_metadata->filter_test[quick_metadata->filter_test_cnt].mover_str = "<NO Mover String>"
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drri_get_refchg_dml(null)
   IF (daf_is_blank(quick_metadata->table_name))
    SET dm_err->eproc = "TABLE_NAME not set in quick_metadata"
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   SET stat = alterlist(quick_metadata->refchg_dml,0)
   SET dm_err->eproc = "Getting refchg_dml info from dm_refchg_dml"
   SELECT INTO "nl:"
    FROM dm_refchg_dml drd
    WHERE (drd.table_name=quick_metadata->table_name)
    HEAD REPORT
     quick_metadata->refchg_dml_cnt = 0
    DETAIL
     quick_metadata->refchg_dml_cnt = (quick_metadata->refchg_dml_cnt+ 1), stat = alterlist(
      quick_metadata->refchg_dml,quick_metadata->refchg_dml_cnt), quick_metadata->refchg_dml[
     quick_metadata->refchg_dml_cnt].column_name = drd.column_name,
     quick_metadata->refchg_dml[quick_metadata->refchg_dml_cnt].dml_attribute = drd.dml_attribute,
     quick_metadata->refchg_dml[quick_metadata->refchg_dml_cnt].dml_value = trim(substring(1,200,drd
       .dml_value))
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drri_get_custom_cols(null)
   IF (daf_is_blank(quick_metadata->table_name))
    SET dm_err->eproc = "TABLE_NAME not set in quick_metadata"
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   SET stat = alterlist(quick_metadata->custom_cols,0)
   SET dm_err->eproc = "Getting custom_cols info from dm_refchg_sql_obj"
   SELECT INTO "nl:"
    FROM dm_refchg_sql_obj drs
    WHERE (drs.table_name=quick_metadata->table_name)
    HEAD REPORT
     quick_metadata->custom_cols_cnt = 0
    DETAIL
     quick_metadata->custom_cols_cnt = (quick_metadata->custom_cols_cnt+ 1), stat = alterlist(
      quick_metadata->custom_cols,quick_metadata->custom_cols_cnt), quick_metadata->custom_cols[
     quick_metadata->custom_cols_cnt].column_name = drs.column_name,
     quick_metadata->custom_cols[quick_metadata->custom_cols_cnt].execution_flag = drs.execution_flag,
     quick_metadata->custom_cols[quick_metadata->custom_cols_cnt].object_name = substring(1,
      findstring("::",drs.object_name),drs.object_name)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drri_get_pe_abbrev(null)
   IF (daf_is_blank(quick_metadata->table_name))
    SET dm_err->eproc = "TABLE_NAME not set in quick_metadata"
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   SET quick_metadata->refchg_pe_abbrev = " "
   SET quick_metadata->pe_abbrev_cnt = 0
   SET stat = alterlist(quick_metadata->pe_abbrev,0)
   SET dm_err->eproc = "Getting pe_abbrev info from dm_info"
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=concat("RDDS_PE_ABBREV:",quick_metadata->table_name)
    ORDER BY di.info_name
    HEAD REPORT
     quick_metadata->refchg_pe_abbrev = "PE OVERRIDE", delim = 0, quick_metadata->pe_abbrev_cnt = 0
    DETAIL
     delim = findstring(":",di.info_name)
     IF (delim > 0)
      quick_metadata->pe_abbrev_cnt = (quick_metadata->pe_abbrev_cnt+ 1), stat = alterlist(
       quick_metadata->pe_abbrev,quick_metadata->pe_abbrev_cnt), quick_metadata->pe_abbrev[
      quick_metadata->pe_abbrev_cnt].col_name = trim(substring(1,(delim - 1),di.info_name)),
      quick_metadata->pe_abbrev[quick_metadata->pe_abbrev_cnt].data_value = trim(substring((delim+ 1),
        100,di.info_name)), quick_metadata->pe_abbrev[quick_metadata->pe_abbrev_cnt].pe_table_name =
      trim(substring(1,30,di.info_char))
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drri_get_parent_qual(null)
   IF (daf_is_blank(quick_metadata->table_name))
    SET dm_err->eproc = "TABLE_NAME not set in quick_metadata"
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   SET dm_err->eproc = "Getting parent_qual info from dm_tables_doc and dm_columns_doc "
   SELECT INTO "nl:"
    dcd1.table_name, dcd1.column_name
    FROM dm_tables_doc dtd1,
     dm_columns_doc dcd1
    WHERE (dcd1.root_entity_name=quick_metadata->table_name)
     AND (dcd1.root_entity_attr=
    (SELECT
     dcd.column_name
     FROM dm_tables_doc dtd,
      dm_columns_doc dcd
     WHERE (dtd.table_name=quick_metadata->table_name)
      AND dtd.table_name=dtd.full_table_name
      AND dcd.table_name=dtd.table_name
      AND dcd.root_entity_name=dcd.table_name
      AND dcd.root_entity_attr=dcd.column_name))
     AND (dcd1.table_name != quick_metadata->table_name)
     AND dcd1.table_name=dtd1.table_name
     AND dtd1.table_name=dtd1.full_table_name
    ORDER BY dcd1.table_name, dcd1.column_name
    DETAIL
     quick_metadata->parent_cnt = (quick_metadata->parent_cnt+ 1), stat = alterlist(quick_metadata->
      parent_qual,quick_metadata->parent_cnt), quick_metadata->parent_qual[quick_metadata->parent_cnt
     ].column_name = dcd1.column_name,
     quick_metadata->parent_qual[quick_metadata->parent_cnt].table_name = dcd1.table_name,
     quick_metadata->parent_qual[quick_metadata->parent_cnt].reference_ind = dtd1.reference_ind,
     quick_metadata->parent_qual[quick_metadata->parent_cnt].mergeable_ind = dtd1.mergeable_ind
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drri_get_ndx_qual(null)
   IF (daf_is_blank(quick_metadata->table_name))
    SET dm_err->eproc = "TABLE_NAME not set in quick_metadata"
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   SET dm_err->eproc = "Getting ndx_qual info from user_ind_columns and user_indexes"
   SELECT INTO "nl:"
    ui.index_name, unq_ind = evaluate(ui.uniqueness,"UNIQUE",1,0), uic.column_name
    FROM user_ind_columns uic,
     user_indexes ui
    WHERE (ui.table_name=quick_metadata->table_name)
     AND ui.table_name=uic.table_name
     AND ui.index_name=uic.index_name
    ORDER BY ui.index_name, uic.column_position
    HEAD ui.index_name
     quick_metadata->ndx_cnt = (quick_metadata->ndx_cnt+ 1), stat = alterlist(quick_metadata->
      ndx_qual,quick_metadata->ndx_cnt), quick_metadata->ndx_qual[quick_metadata->ndx_cnt].index_name
      = ui.index_name,
     quick_metadata->ndx_qual[quick_metadata->ndx_cnt].uniqueness = evaluate(unq_ind,1,"UNIQUE",
      "NONUNIQUE"), quick_metadata->ndx_qual[quick_metadata->ndx_cnt].ndx_col_cnt = 0
    DETAIL
     quick_metadata->ndx_qual[quick_metadata->ndx_cnt].ndx_col_cnt = (quick_metadata->ndx_qual[
     quick_metadata->ndx_cnt].ndx_col_cnt+ 1), stat = alterlist(quick_metadata->ndx_qual[
      quick_metadata->ndx_cnt].ndx_col_qual,quick_metadata->ndx_qual[quick_metadata->ndx_cnt].
      ndx_col_cnt), quick_metadata->ndx_qual[quick_metadata->ndx_cnt].ndx_col_qual[quick_metadata->
     ndx_qual[quick_metadata->ndx_cnt].ndx_col_cnt].column_name = uic.column_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drri_get_current_state_ind(null)
   IF (daf_is_blank(quick_metadata->table_name))
    SET dm_err->eproc = "TABLE_NAME not set in quick_metadata"
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   SET dm_err->eproc = "Getting current_state_ind from dm_info"
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="RDDS CURRENT STATE TABLES"
     AND findstring(quick_metadata->table_name,d.info_name) > 0
    DETAIL
     IF (((findstring(build(quick_metadata->table_name,":"),d.info_name) > 0) OR (((findstring(build(
       ":",quick_metadata->table_name),d.info_name) > 0) OR (findstring(build(":",quick_metadata->
       table_name,":"),d.info_name) > 0)) )) )
      quick_metadata->current_state_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE get_metadata(null)
   IF (daf_is_blank(quick_metadata->table_name))
    SET dm_err->eproc = "TABLE_NAME not set in quick_metadata"
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   SET quick_metadata->data_model_section = "<NOT FOUND>"
   SET quick_metadata->inhouse_ind = 0
   SET dm_err->eproc = "Determining if inhouse domain"
   SELECT INTO "nl:"
    FROM dm_info
    WHERE info_domain="DATA MANAGEMENT"
     AND info_name="INHOUSE DOMAIN"
    DETAIL
     quick_metadata->inhouse_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   IF ((quick_metadata->inhouse_ind=1))
    CALL drri_get_inhouse_data(null)
   ELSE
    CALL drri_get_outhouse_dm_tables_doc(null)
   ENDIF
   IF ((quick_metadata->data_model_section="<NOT FOUND>"))
    RETURN(null)
   ENDIF
   CALL drri_ui_info(null)
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   CALL drri_get_mixed(null)
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   CALL drri_get_ovr_qual(null)
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   CALL drri_get_id_qual(null)
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   CALL drri_get_code_value(null)
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   CALL drri_get_refchg_filter(null)
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   CALL drri_get_filter_parm(null)
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   CALL drri_get_filter_test(null)
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   CALL drri_get_refchg_dml(null)
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   CALL drri_get_custom_cols(null)
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   CALL drri_get_pe_abbrev(null)
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   CALL drri_get_parent_qual(null)
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   CALL drri_get_ndx_qual(null)
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   CALL drri_get_current_state_ind(null)
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE build_report(null)
   DECLARE drris_str = vc WITH protect, noconstant(" "), protect
   SET dm_err->eproc = "Building Output Report"
   SELECT INTO quick_metadata->out_file
    FROM dual
    WHERE 1=1
    HEAD REPORT
     xi = 0
    DETAIL
     "******************************************************************************", row + 1,
     quick_metadata->table_name,
     col 40, "(", quick_metadata->table_suffix,
     ")", col 50, quick_metadata->rtbl_name,
     row + 1, col 10
     IF ((quick_metadata->data_model_section="<NOT FOUND>"))
      "TABLE NOT FOUND!", row + 1
     ELSE
      IF ((quick_metadata->reference_ind=1))
       "Reference ", row + 1
      ELSE
       IF ((quick_metadata->mixed_ind=1))
        "Activity (Mixed/Special)", row + 1
       ELSE
        "Activity ", row + 1
       ENDIF
      ENDIF
      col 10
      IF ((quick_metadata->mergeable_ind=1))
       "Mergeable "
      ELSE
       "Not mergeable "
      ENDIF
      IF ((quick_metadata->ovr_cnt > 0))
       "(see overrides below)"
      ENDIF
      row + 1
     ENDIF
     col 10, "Data Model Section : ", quick_metadata->data_model_section,
     row + 1, col 10, "Owner: ",
     quick_metadata->owner_name, row + 1
     IF ((quick_metadata->version_algorithm > " "))
      col 10, "Versioning algorithm: ", quick_metadata->version_algorithm,
      row + 1
     ENDIF
     IF ((quick_metadata->current_state_ind > 0))
      col 10, "RDDS Current State: YES (MUI/MDI Restriction!)", row + 1
     ENDIF
     IF (size(quick_metadata->custom_cols,5) > 0)
      col 10, "Custom plsql logic: YES (see below)", row + 1
     ENDIF
     IF ((quick_metadata->refchg_filter > " "))
      col 10, "RDDS Filter: ", quick_metadata->refchg_filter,
      " (see below)", row + 1
     ENDIF
     IF (size(quick_metadata->refchg_dml,5) > 0)
      col 10, "Special DML logic: YES (see below)", row + 1
     ENDIF
     IF ((quick_metadata->should_not_merge > " "))
      col 10, "Should not merge: ", quick_metadata->should_not_merge,
      row + 1
     ENDIF
     IF ((quick_metadata->dual_build_trg > " "))
      col 10, "Dual Build trigs: ", quick_metadata->dual_build_trg,
      row + 1
     ENDIF
     IF ((quick_metadata->rdds_list_reason > " "))
      drris_str = substring(1,60,quick_metadata->rdds_list_reason), col 10, "RDDS_LIST_REASON: ",
      drris_str, row + 1
     ENDIF
     IF ((quick_metadata->ovr_cnt > 0))
      "******************************************************************************", row + 1,
      "Overrides",
      row + 1, col 10
      IF ((quick_metadata->ovr_mergeable_ind=1))
       "Mergeable", row + 1
      ELSE
       "Not mergeable ", row + 1
      ENDIF
      col 10
      IF ((quick_metadata->ovr_merge_delete_ind=1))
       "Merge Delete ", row + 1
      ELSE
       "Not merge delete ", row + 1
      ENDIF
      "Override Requirements", row + 1
      FOR (i = 1 TO quick_metadata->ovr_cnt)
        IF (((i=1) OR ((quick_metadata->ovr_qual[i].ovr_instance != quick_metadata->ovr_qual[(i - 1)]
        .ovr_instance))) )
         col 0, "Inst=", quick_metadata->ovr_qual[i].ovr_instance"###;l",
         col 10
         IF ((quick_metadata->ovr_qual[i].mergeable_ind=1))
          "Mergeable"
         ELSE
          "Not mergeable"
         ENDIF
         IF ((quick_metadata->ovr_qual[i].merge_delete_ind=1))
          ", Merge delete"
         ELSE
          ", Not merge delete"
         ENDIF
         row + 1
        ENDIF
        col 5, quick_metadata->ovr_qual[i].ovr_type, "/",
        quick_metadata->ovr_qual[i].ovr_version"##;l", col 15,
        CALL print(substring(1,20,quick_metadata->ovr_qual[i].ovr_name)),
        col 36,
        CALL print(substring(1,90,quick_metadata->ovr_qual[i].ovr_description)), row + 1
        IF ((quick_metadata->ovr_qual[i].col_ovr_cnt > 0))
         "Column Overrides:", row + 1
         FOR (num = 1 TO quick_metadata->ovr_qual[i].col_ovr_cnt)
           col 12,
           CALL print(quick_metadata->ovr_qual[i].merge_cols[num].ovr_data), row + 1
         ENDFOR
        ENDIF
        IF ((quick_metadata->ovr_qual[i].nonmerge_cols_cnt > 0))
         "Column Overrides:", row + 1
         FOR (j = 1 TO quick_metadata->ovr_qual[i].nonmerge_cols_cnt)
           col 12,
           CALL print(quick_metadata->ovr_qual[i].nonmerge_cols[j].ovr_data), row + 1
         ENDFOR
        ENDIF
      ENDFOR
     ENDIF
     "******************************************************************************", row + 1
     IF ((quick_metadata->ui_cnt > 0))
      IF ((quick_metadata->merge_delete_ind=0))
       "UI Columns"
      ELSE
       "Merge Delete Columns"
      ENDIF
      IF ((quick_metadata->current_state_ind > 0))
       col 30, "RDDS Current State Table (MUI/MDI Restriction!)"
      ENDIF
      row + 1
      FOR (i = 1 TO quick_metadata->ui_cnt)
        col 10, quick_metadata->ui_qual[i].column_name, row + 1
      ENDFOR
      "******************************************************************************", row + 1
     ENDIF
     IF ((quick_metadata->ndx_cnt > 0))
      "Indexes:  <from current database>", row + 1
      FOR (i = 1 TO quick_metadata->ndx_cnt)
        col 10, quick_metadata->ndx_qual[i].index_name, col 40,
        quick_metadata->ndx_qual[i].uniqueness, row + 1
        FOR (j = 1 TO quick_metadata->ndx_qual[i].ndx_col_cnt)
          col 20, quick_metadata->ndx_qual[i].ndx_col_qual[j].column_name, row + 1
        ENDFOR
      ENDFOR
      "******************************************************************************", row + 1
     ENDIF
     IF ((quick_metadata->id_cnt > 0))
      "Significant Columns (translate-able ID/CD, exception_flg, merge identifier, defining attribute)",
      row + 1
      FOR (i = 1 TO quick_metadata->id_cnt)
        col 10, quick_metadata->id_qual[i].column_name
        IF ((quick_metadata->id_qual[i].root_entity_ind=1))
         col 50, "<Root Entity Attribute>"
        ENDIF
        row + 1
        IF ((quick_metadata->id_qual[i].root_entity_name > " "))
         col 20, "Root entity: ", quick_metadata->id_qual[i].root_entity_name,
         ".", quick_metadata->id_qual[i].root_entity_attr, "  (",
         quick_metadata->id_qual[i].root_entity_refmrg, ")", row + 1
        ENDIF
        IF ((quick_metadata->id_qual[i].parent_entity_col > " "))
         col 20, "Parent entity column: ", quick_metadata->id_qual[i].parent_entity_col,
         row + 1, xi = 0
         IF ((quick_metadata->pe_abbrev_cnt > 0)
          AND locateval(xi,1,quick_metadata->pe_abbrev_cnt,quick_metadata->id_qual[i].
          parent_entity_col,quick_metadata->pe_abbrev[xi].col_name) > 0)
          col 25, "(see parent entity replacement below)", row + 1
         ENDIF
        ENDIF
        IF ((quick_metadata->id_qual[i].exception_flg > 0))
         col 20, "Exception_Flg: ", quick_metadata->id_qual[i].exception_flg,
         row + 1
        ENDIF
        IF ((quick_metadata->id_qual[i].sequence_name > " "))
         col 20, "Sequence_Name: ", quick_metadata->id_qual[i].sequence_name,
         row + 1
        ENDIF
        IF ((quick_metadata->id_qual[i].code_set > 0))
         col 20, "Code_Set: ", quick_metadata->id_qual[i].code_set,
         "  (", quick_metadata->id_qual[i].code_set_dup, ")",
         row + 1
        ENDIF
        IF ((quick_metadata->id_qual[i].constant_value > " "))
         quick_metadata->id_qual[i].constant_value = substring(1,70,quick_metadata->id_qual[i].
          constant_value), col 20, "Constant_Value: ",
         quick_metadata->id_qual[i].constant_value, row + 1
        ENDIF
        IF ((quick_metadata->id_qual[i].defining_attribute_ind > 0))
         col 20, "Defining_Attribute_Ind: ", quick_metadata->id_qual[i].defining_attribute_ind,
         row + 1
        ENDIF
        IF ((quick_metadata->id_qual[i].unique_ident_ind > 0))
         col 20, "Unique_Ident_Ind: ", quick_metadata->id_qual[i].unique_ident_ind,
         row + 1
        ENDIF
        IF ((quick_metadata->id_qual[i].merge_delete_ind > 0))
         col 20, "Merge_Delete_Ind: ", quick_metadata->id_qual[i].merge_delete_ind,
         row + 1
        ENDIF
        IF ((quick_metadata->id_qual[i].root_entity_name <= " ")
         AND (quick_metadata->id_qual[i].parent_entity_col <= " ")
         AND (quick_metadata->id_qual[i].description > " "))
         quick_metadata->id_qual[i].description = concat("Description: ",quick_metadata->id_qual[i].
          description)
         FOR (j = 1 TO size(quick_metadata->id_qual[i].description,1) BY 100)
           drris_str = substring(j,100,quick_metadata->id_qual[i].description), col 20, drris_str,
           row + 1
         ENDFOR
        ENDIF
      ENDFOR
      "******************************************************************************", row + 1
     ENDIF
     IF ((quick_metadata->parent_cnt > 0))
      "Parent of: ", row + 1
      FOR (i = 1 TO quick_metadata->parent_cnt)
        col 10, quick_metadata->parent_qual[i].table_name, ".",
        quick_metadata->parent_qual[i].column_name, col 70, "REFERENCE_IND =",
        quick_metadata->parent_qual[i].reference_ind"##", "  MERGEABLE_IND =", quick_metadata->
        parent_qual[i].mergeable_ind"##",
        row + 1
      ENDFOR
      "******************************************************************************", row + 1
     ENDIF
     "Parent of: <info not collected>", row + 1,
     "******************************************************************************",
     row + 1
     IF ((quick_metadata->doc_cnt > 0))
      "Object Doc: ", row + 1
      FOR (i = 1 TO quick_metadata->doc_cnt)
        col 5, quick_metadata->doc_qual[i].user_id, col 17,
        "Created/Updated: ", quick_metadata->doc_qual[i].create_dt_tm"DD-MMM-YYYY HH:MM;;D", " / ",
        quick_metadata->doc_qual[i].updt_dt_tm"DD-MMM-YYYY HH:MM;;D", row + 1
        FOR (j = 1 TO size(quick_metadata->doc_qual[i].definition,1) BY 80)
          drris_str = substring(j,80,quick_metadata->doc_qual[i].definition), col 20, drris_str,
          row + 1
        ENDFOR
      ENDFOR
      "******************************************************************************", row + 1
     ENDIF
     IF ((((quick_metadata->filter_parm_cnt > 0)) OR ((quick_metadata->filter_test_cnt > 0))) )
      "RDDS Filter: ", quick_metadata->refchg_filter, row + 1
      FOR (i = 1 TO quick_metadata->filter_parm_cnt)
        IF (i=1)
         "RDDS Filter columns:", row + 1
        ENDIF
        col 2, quick_metadata->filter_parm[i].column_name, row + 1
      ENDFOR
      mover_only_ind = 0
      FOR (i = 1 TO quick_metadata->filter_test_cnt)
        IF (i=1)
         "RDDS Filter tests:", row + 1
        ENDIF
        col 2, quick_metadata->filter_test[i].test_nbr, row + 1
        FOR (j = 1 TO size(quick_metadata->filter_test[i].test_str,1) BY 100)
          drris_str = substring(j,100,quick_metadata->filter_test[i].test_str), col 10, drris_str,
          row + 1
        ENDFOR
        IF ((quick_metadata->filter_test[i].mover_str > " "))
         mover_only = 1
        ENDIF
      ENDFOR
      FOR (i = 1 TO quick_metadata->filter_test_cnt)
       IF (mover_only=1
        AND i=1)
        "RDDS Filter tests: (MOVER_STRING)", row + 1
       ENDIF
       ,
       IF ((quick_metadata->filter_test[i].mover_str > " "))
        col 2, quick_metadata->filter_test[i].test_nbr, row + 1
        FOR (j = 1 TO size(quick_metadata->filter_test[i].mover_str,1) BY 100)
          drris_str = substring(j,100,quick_metadata->filter_test[i].mover_str), col 10, drris_str,
          row + 1
        ENDFOR
       ENDIF
      ENDFOR
      "******************************************************************************", row + 1
     ENDIF
     IF ((quick_metadata->refchg_dml_cnt > 0))
      "Special DML logic for columns:", row + 1
      FOR (i = 1 TO quick_metadata->refchg_dml_cnt)
        IF ((quick_metadata->refchg_dml[i].column_name > " "))
         col 10, quick_metadata->refchg_dml[i].column_name
        ELSE
         col 10, "<<TABLE>>"
        ENDIF
        col 45, "ATTR: ",
        CALL print(substring(1,80,quick_metadata->refchg_dml[i].dml_attribute)),
        row + 1, col 13, "VALUE: ",
        CALL print(substring(1,110,quick_metadata->refchg_dml[i].dml_value)), row + 1
      ENDFOR
      "******************************************************************************", row + 1
     ENDIF
     IF ((quick_metadata->pe_abbrev_cnt > 0))
      "Parent Entity Replacement:", row + 1
      FOR (i = 1 TO quick_metadata->pe_abbrev_cnt)
        IF (((i=1) OR ((quick_metadata->pe_abbrev[i].col_name != quick_metadata->pe_abbrev[(i - 1)].
        col_name))) )
         col 2, "Column: ", quick_metadata->pe_abbrev[i].col_name,
         " (Actual Data Value - PE Table Name)", row + 1
        ENDIF
        col 15, quick_metadata->pe_abbrev[i].data_value, col 60,
        quick_metadata->pe_abbrev[i].pe_table_name, row + 1
      ENDFOR
      "******************************************************************************", row + 1
     ENDIF
     IF ((quick_metadata->custom_cols_cnt > 0))
      "Custom merge logic for columns:", row + 1
      FOR (i = 1 TO quick_metadata->custom_cols_cnt)
        col 10, quick_metadata->custom_cols[i].column_name, col 45,
        quick_metadata->custom_cols[i].object_name, row + 1
      ENDFOR
      "******************************************************************************", row + 1
     ENDIF
    WITH nocounter, formfeed = none, format = variable,
     maxcol = 200, maxrow = 1, append
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   RETURN(null)
 END ;Subroutine
 DECLARE drri_table_name = vc WITH noconstant(" ")
 SET dm_err->eproc = "Validating table_name is text"
 IF (reflect(parameter(1,0)) != "C*")
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Expected syntax: dm_rmc_rdds_info <Table_name>"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET drri_table_name = cnvtupper( $1)
 CALL drri_table_name_validate(drri_table_name)
 IF ((dm_err->err_ind=1))
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET quick_metadata->out_file = "MINE"
 CALL get_metadata(null)
 IF ((dm_err->err_ind=1))
  GO TO exit_program
 ENDIF
 CALL build_report(null)
#exit_program
END GO
