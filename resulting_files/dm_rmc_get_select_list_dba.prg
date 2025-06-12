CREATE PROGRAM dm_rmc_get_select_list:dba
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
 IF (validate(drqp_reply->tab_cnt,99)=99)
  FREE RECORD drqp_reply
  RECORD drqp_reply(
    1 tab_cnt = i4
    1 tab_qual[*]
      2 table_name = vc
      2 table_alias = vc
      2 dummyt_ind = i2
    1 col_cnt = i4
    1 col_qual[*]
      2 return_phrase = vc
      2 return_name = vc
      2 return_clause = vc
      2 func_ind = i2
      2 clause_alias = vc
      2 clause_column = vc
      2 all_col_ind = i2
    1 cnt = i4
    1 qual[*]
      2 text = vc
  )
 ENDIF
 IF (validate(drqp_reply->tab_cnt,99)=99)
  FREE RECORD drqp_reply
  RECORD drqp_reply(
    1 tab_cnt = i4
    1 tab_qual[*]
      2 table_name = vc
      2 table_alias = vc
      2 dummyt_ind = i2
    1 col_cnt = i4
    1 col_qual[*]
      2 return_phrase = vc
      2 return_name = vc
      2 return_clause = vc
      2 func_ind = i2
      2 clause_alias = vc
      2 clause_column = vc
      2 all_col_ind = i2
    1 cnt = i4
    1 qual[*]
      2 text = vc
  )
 ENDIF
 IF (validate(drqp_pos->qual_pos,99)=99)
  FREE RECORD drqp_pos
  RECORD drqp_pos(
    1 qual_pos = i4
    1 char_pos = i4
  )
 ENDIF
 DECLARE drqp_find_clause(dfc_text=vc,dfc_rec=vc(ref),dfc_qual_idx=i4,dfc_char_idx=i4,dfc_rep=vc(ref),
  dfc_space_flag=i4) = null
 DECLARE drqp_parse_tables(dpt_temp=vc,dpt_rep=vc(ref)) = null
 DECLARE drqp_parse_columns(dpc_temp=vc,dpc_rep=vc(ref)) = null
 DECLARE drqp_remove_comments(drc_text=vc(ref)) = null
 SUBROUTINE drqp_find_clause(dfc_text,dfc_rec,dfc_qual_idx,dfc_char_idx,dfc_rep,dfc_space_flag)
   DECLARE dfc_loop = i4 WITH protect, noconstant(0)
   DECLARE dfc_beg_check_ind = i2 WITH protect, noconstant(0)
   DECLARE dfc_end_check_ind = i2 WITH protect, noconstant(0)
   DECLARE dfc_mid_check_ind = i2 WITH protect, noconstant(0)
   DECLARE dfc_alias = vc WITH protect, noconstant("")
   DECLARE dfc_prefix = vc WITH protect, noconstant("")
   DECLARE dfc_search = vc WITH protect, noconstant("")
   SET dfc_rep->char_pos = 0
   SET dfc_rep->qual_pos = 0
   IF ((dfc_qual_idx > dfc_rec->cnt))
    RETURN(null)
   ENDIF
   FOR (dfc_loop = dfc_qual_idx TO dfc_rec->cnt)
     SET dfc_beg_check_ind = 0
     SET dfc_end_check_ind = 0
     SET dfc_mid_check_ind = 0
     IF (dfc_loop=dfc_qual_idx)
      IF (dfc_char_idx=1)
       SET dfc_beg_check_ind = 1
       SET dfc_mid_check_ind = 1
       SET dfc_end_check_ind = 1
      ELSEIF ((dfc_char_idx=(size(dfc_rec->qual[dfc_loop].text) - size(dfc_text))))
       SET dfc_end_check_ind = 1
      ELSEIF ((dfc_char_idx < (size(dfc_rec->qual[dfc_loop].text) - size(dfc_text))))
       SET dfc_mid_check_ind = 1
       SET dfc_end_check_ind = 1
      ENDIF
     ELSE
      SET dfc_beg_check_ind = 1
      SET dfc_mid_check_ind = 1
      SET dfc_end_check_ind = 1
     ENDIF
     SET dfc_search = dfc_text
     IF (dfc_space_flag IN (0, 2))
      SET dfc_alias = concat(dfc_text," *")
     ELSE
      SET dfc_alias = concat(dfc_text,"*")
     ENDIF
     IF (dfc_space_flag IN (0, 1))
      SET dfc_prefix = concat("* ",dfc_text)
      SET dfc_search = concat(" ",dfc_search)
     ELSE
      SET dfc_prefix = concat("*",dfc_text)
     ENDIF
     IF (dfc_beg_check_ind=1
      AND cnvtupper(dfc_rec->qual[dfc_loop].text)=patstring(dfc_alias))
      SET dfc_rep->char_pos = 1
      SET dfc_rep->qual_pos = dfc_loop
      RETURN(null)
     ENDIF
     IF (dfc_end_check_ind=1
      AND cnvtupper(dfc_rec->qual[dfc_loop].text)=patstring(dfc_prefix))
      SET dfc_rep->char_pos = ((size(dfc_rec->qual[dfc_loop].text) - size(dfc_text))+ 1)
      SET dfc_rep->qual_pos = dfc_loop
      RETURN(null)
     ENDIF
     IF (dfc_mid_check_ind=1)
      IF (dfc_loop=dfc_qual_idx)
       IF (dfc_space_flag IN (0, 2))
        SET dfc_rep->char_pos = findstring(concat(dfc_search," "),cnvtupper(dfc_rec->qual[dfc_loop].
          text),dfc_char_idx,0)
       ELSE
        SET dfc_rep->char_pos = findstring(dfc_search,cnvtupper(dfc_rec->qual[dfc_loop].text),
         dfc_char_idx,0)
       ENDIF
      ELSE
       IF (dfc_space_flag IN (0, 2))
        SET dfc_rep->char_pos = findstring(concat(dfc_search," "),cnvtupper(dfc_rec->qual[dfc_loop].
          text),1,0)
       ELSE
        SET dfc_rep->char_pos = findstring(dfc_search,cnvtupper(dfc_rec->qual[dfc_loop].text),1,0)
       ENDIF
      ENDIF
      IF ((dfc_rep->char_pos > 0))
       SET dfc_rep->qual_pos = dfc_loop
       IF (dfc_space_flag IN (0, 1))
        SET dfc_rep->char_pos = (dfc_rep->char_pos+ 1)
       ENDIF
       RETURN(null)
      ENDIF
     ENDIF
   ENDFOR
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drqp_parse_tables(dpt_temp,dpt_rep)
   DECLARE dpt_done_ind = i2 WITH protect, noconstant(0)
   DECLARE dpt_start_pos = i4 WITH protect, noconstant(0)
   DECLARE dpt_stop_pos = i4 WITH protect, noconstant(0)
   DECLARE dpt_temp2 = vc WITH protect, noconstant(" ")
   DECLARE dpt_sfx_cnt = i4 WITH protect, noconstant(0)
   SET dpt_temp = trim(dpt_temp,3)
   IF (size(dpt_temp)=0)
    RETURN(null)
   ENDIF
   SET dpt_done_ind = 0
   WHILE (dpt_done_ind=0)
     SET dpt_stop_pos = findstring(",",dpt_temp,1,0)
     IF (dpt_stop_pos=0)
      SET dpt_done_ind = 1
      SET dpt_stop_pos = findstring(" ",dpt_temp,1,0)
      SET dpt_rep->tab_cnt = (dpt_rep->tab_cnt+ 1)
      SET stat = alterlist(dpt_rep->tab_qual,dpt_rep->tab_cnt)
      IF (dpt_stop_pos=0)
       SET dpt_rep->tab_qual[dpt_rep->tab_cnt].table_name = trim(dpt_temp,3)
       IF (cnvtupper(dpt_rep->tab_qual[dpt_rep->tab_cnt].table_name) != "DUMMYT")
        SET dpt_sfx_cnt = (dpt_sfx_cnt+ 1)
        SET dpt_rep->tab_qual[dpt_rep->tab_cnt].table_alias = concat("sfx",trim(cnvtstring(
           dpt_sfx_cnt)))
       ENDIF
      ELSE
       SET dpt_rep->tab_qual[dpt_rep->tab_cnt].table_name = trim(substring(1,(dpt_stop_pos - 1),
         dpt_temp),3)
       SET dpt_rep->tab_qual[dpt_rep->tab_cnt].table_alias = trim(substring((dpt_stop_pos+ 1),size(
          dpt_temp),dpt_temp),3)
       IF (trim(dpt_rep->tab_qual[dpt_rep->tab_cnt].table_alias,3) <= " "
        AND cnvtupper(dpt_rep->tab_qual[dpt_rep->tab_cnt].table_name) != "DUMMYT")
        SET dpt_sfx_cnt = (dpt_sfx_cnt+ 1)
        SET dpt_rep->tab_qual[dpt_rep->tab_cnt].table_alias = concat("sfx",trim(cnvtstring(
           dpt_sfx_cnt)))
       ENDIF
      ENDIF
     ELSE
      SET dpt_temp2 = trim(substring(1,(dpt_stop_pos - 1),dpt_temp),3)
      SET dpt_temp = trim(substring((dpt_stop_pos+ 1),size(dpt_temp),dpt_temp),3)
      SET dpt_start_pos = findstring(" ",dpt_temp2,1,0)
      SET dpt_rep->tab_cnt = (dpt_rep->tab_cnt+ 1)
      SET stat = alterlist(dpt_rep->tab_qual,dpt_rep->tab_cnt)
      IF (dpt_start_pos=0)
       SET dpt_rep->tab_qual[dpt_rep->tab_cnt].table_name = trim(dpt_temp2,3)
       IF (cnvtupper(dpt_rep->tab_qual[dpt_rep->tab_cnt].table_name) != "DUMMYT")
        SET dpt_sfx_cnt = (dpt_sfx_cnt+ 1)
        SET dpt_rep->tab_qual[dpt_rep->tab_cnt].table_alias = concat("sfx",trim(cnvtstring(
           dpt_sfx_cnt)))
       ENDIF
      ELSE
       SET dpt_rep->tab_qual[dpt_rep->tab_cnt].table_name = trim(substring(1,(dpt_start_pos - 1),
         dpt_temp2),3)
       SET dpt_rep->tab_qual[dpt_rep->tab_cnt].table_alias = trim(substring((dpt_start_pos+ 1),size(
          dpt_temp),dpt_temp2),3)
       IF (trim(dpt_rep->tab_qual[dpt_rep->tab_cnt].table_alias,3) <= " "
        AND cnvtupper(dpt_rep->tab_qual[dpt_rep->tab_cnt].table_name) != "DUMMYT")
        SET dpt_sfx_cnt = (dpt_sfx_cnt+ 1)
        SET dpt_rep->tab_qual[dpt_rep->tab_cnt].table_alias = concat("sfx",trim(cnvtstring(
           dpt_sfx_cnt)))
       ENDIF
      ENDIF
     ENDIF
     IF (cnvtupper(dpt_rep->tab_qual[dpt_rep->tab_cnt].table_name)="DUMMYT")
      SET dpt_rep->tab_qual[dpt_rep->tab_cnt].dummyt_ind = 1
      IF ((dpt_rep->tab_qual[dpt_rep->tab_cnt].table_alias <= " "))
       SET dm_err->err_ind = 1
       SET dm_err->emsg = "No alias found for dummyt table name.  Invalid query."
      ENDIF
     ENDIF
   ENDWHILE
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drqp_parse_columns(dpc_temp,dpc_rep)
   DECLARE dpc_done_ind = i2 WITH protect, noconstant(0)
   DECLARE dpc_start_pos = i4 WITH protect, noconstant(0)
   DECLARE dpc_stop_pos = i4 WITH protect, noconstant(0)
   DECLARE dpc_temp2 = vc WITH protect, noconstant(" ")
   DECLARE dpc_cnt = i4 WITH protect, noconstant(0)
   DECLARE dpc_exclude_ind = i2 WITH protect, noconstant(0)
   DECLARE dpc_last_pos = i4 WITH protect, noconstant(0)
   FREE RECORD dpc_parens
   RECORD dpc_parens(
     1 cnt = i4
     1 qual[*]
       2 start_pos = i4
       2 stop_pos = i4
   )
   SET dpc_temp = trim(dpc_temp,3)
   IF (size(dpc_temp)=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "There must be 1 return specified in the SELECT column list."
    RETURN(null)
   ENDIF
   SET dpc_start_pos = 0
   WHILE (dpc_done_ind=0)
    SET dpc_start_pos = findstring("(",dpc_temp,(dpc_start_pos+ 1),0)
    IF (dpc_start_pos > 0)
     SET dpc_parens->cnt = (dpc_parens->cnt+ 1)
     SET stat = alterlist(dpc_parens->qual,dpc_parens->cnt)
     SET dpc_parens->qual[dpc_parens->cnt].start_pos = dpc_start_pos
    ELSE
     SET dpc_done_ind = 1
    ENDIF
   ENDWHILE
   IF ((dpc_parens->cnt > 0))
    SET dpc_start_pos = 0
    SET dpc_done_ind = 0
    WHILE (dpc_done_ind=0)
     SET dpc_start_pos = findstring(")",dpc_temp,(dpc_start_pos+ 1),0)
     IF (dpc_start_pos > 0)
      IF ((dpc_parens->cnt=1)
       AND (dpc_parens->qual[1].stop_pos > 0))
       SET dm_err->err_ind = 1
       SET dm_err->emsg = "Additional ) symbol found"
       RETURN(null)
      ELSEIF ((dpc_parens->cnt=1)
       AND (dpc_parens->qual[1].stop_pos=0))
       SET dpc_parens->qual[1].stop_pos = dpc_start_pos
      ELSE
       FOR (dpc_cnt = dpc_parens->cnt TO 1 BY - (1))
         IF ((dpc_start_pos > dpc_parens->qual[dpc_cnt].start_pos)
          AND (dpc_parens->qual[dpc_cnt].stop_pos=0))
          SET dpc_parens->qual[dpc_cnt].stop_pos = dpc_start_pos
          SET dpc_cnt = 0
         ENDIF
       ENDFOR
      ENDIF
     ELSE
      SET dpc_done_ind = 1
     ENDIF
    ENDWHILE
   ENDIF
   SET dpc_done_ind = 0
   SET dpc_start_pos = 0
   CALL echo(dpc_temp)
   CALL echorecord(dpc_parens)
   WHILE (dpc_done_ind=0)
     SET dpc_stop_pos = findstring(",",dpc_temp,(dpc_start_pos+ 1),0)
     SET dpc_start_pos = dpc_stop_pos
     CALL echo(concat("comma found at: ",trim(cnvtstring(dpc_stop_pos))))
     IF (dpc_stop_pos=0)
      SET dpc_done_ind = 1
      SET dpc_rep->col_cnt = (dpc_rep->col_cnt+ 1)
      SET stat = alterlist(dpc_rep->col_qual,dpc_rep->col_cnt)
      SET dpc_rep->col_qual[dpc_rep->col_cnt].return_phrase = trim(substring((dpc_last_pos+ 1),size(
         dpc_temp),dpc_temp),3)
     ELSE
      SET dpc_exclude_ind = 0
      FOR (dpc_cnt = 1 TO dpc_parens->cnt)
        IF (dpc_stop_pos BETWEEN dpc_parens->qual[dpc_cnt].start_pos AND dpc_parens->qual[dpc_cnt].
        stop_pos)
         SET dpc_exclude_ind = 1
        ENDIF
      ENDFOR
      IF (dpc_exclude_ind=0)
       SET dpc_temp2 = trim(substring((dpc_last_pos+ 1),((dpc_stop_pos - dpc_last_pos) - 1),dpc_temp),
        3)
       SET dpc_rep->col_cnt = (dpc_rep->col_cnt+ 1)
       SET stat = alterlist(dpc_rep->col_qual,dpc_rep->col_cnt)
       SET dpc_rep->col_qual[dpc_rep->col_cnt].return_phrase = trim(dpc_temp2,3)
       SET dpc_last_pos = dpc_stop_pos
      ENDIF
     ENDIF
   ENDWHILE
   FOR (dpc_cnt = 1 TO dpc_rep->col_cnt)
     SET dpc_stop_pos = findstring("=",dpc_rep->col_qual[dpc_cnt].return_phrase,1,0)
     IF (dpc_stop_pos > 0)
      SET dpc_rep->col_qual[dpc_cnt].return_name = trim(substring(1,(dpc_stop_pos - 1),dpc_rep->
        col_qual[dpc_cnt].return_phrase),3)
      SET dpc_rep->col_qual[dpc_cnt].return_clause = trim(substring((dpc_stop_pos+ 1),size(dpc_rep->
         col_qual[dpc_cnt].return_phrase),dpc_rep->col_qual[dpc_cnt].return_phrase),3)
     ELSE
      SET dpc_rep->col_qual[dpc_cnt].return_clause = dpc_rep->col_qual[dpc_cnt].return_phrase
     ENDIF
     SET dpc_start_pos = findstring("(",dpc_rep->col_qual[dpc_cnt].return_clause,1,0)
     IF (dpc_start_pos > 0)
      SET dpc_rep->col_qual[dpc_cnt].func_ind = 1
     ELSE
      SET dpc_start_pos = findstring(" ",dpc_rep->col_qual[dpc_cnt].return_clause,1,0)
      IF (dpc_start_pos > 0)
       SET dpc_temp2 = trim(substring(1,(dpc_start_pos - 1),dpc_rep->col_qual[dpc_cnt].return_clause),
        3)
      ELSE
       SET dpc_temp2 = dpc_rep->col_qual[dpc_cnt].return_clause
      ENDIF
      SET dpc_start_pos = findstring(".",dpc_temp2,1,0)
      IF (dpc_start_pos > 0)
       SET dpc_rep->col_qual[dpc_cnt].clause_alias = trim(substring(1,(dpc_start_pos - 1),dpc_temp2),
        3)
       SET dpc_rep->col_qual[dpc_cnt].clause_column = trim(substring((dpc_start_pos+ 1),size(
          dpc_temp2),dpc_temp2),3)
      ELSE
       SET dpc_rep->col_qual[dpc_cnt].clause_column = trim(dpc_temp2,3)
      ENDIF
     ENDIF
     IF ((dpc_rep->col_qual[dpc_cnt].clause_column=char(42)))
      SET dpc_rep->col_qual[dpc_cnt].all_col_ind = 1
     ENDIF
   ENDFOR
   CALL echorecord(dpc_rep)
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drqp_remove_comments(drc_text)
   DECLARE drc_loop = i4 WITH protect, noconstant(0)
   DECLARE drc_end_loop = i4 WITH protect, noconstant(0)
   DECLARE drc_pos = i4 WITH protect, noconstant(0)
   DECLARE drc_diff = i4 WITH protect, noconstant(0)
   DECLARE drc_idx = i4 WITH protect, noconstant(0)
   DECLARE drc_idx2 = i4 WITH protect, noconstant(0)
   DECLARE drc_stop = i4 WITH protect, noconstant(0)
   DECLARE drc_loop2 = i4 WITH protect, noconstant(0)
   DECLARE drc_start = i4 WITH protect, noconstant(0)
   FOR (drc_loop = 1 TO drc_text->cnt)
     SET drc_start = 1
     SET drc_idx = 0
     WHILE (drc_idx=0)
      SET drc_pos = findstring("/*",drc_text->qual[drc_loop].text,drc_start,0)
      IF (drc_pos > 0)
       SET drc_start = (drc_pos+ 1)
       FOR (drc_end_loop = drc_loop TO drc_text->cnt)
         SET drc_idx2 = 0
         WHILE (drc_idx2=0)
          SET drc_stop = findstring("*/",drc_text->qual[drc_end_loop].text,drc_start,0)
          IF (drc_stop=0)
           SET drc_idx2 = 1
          ELSE
           IF (drc_end_loop=drc_loop)
            SET drc_text->qual[drc_end_loop].text = replace(drc_text->qual[drc_end_loop].text,
             substring(drc_pos,((drc_stop - drc_pos)+ 2),drc_text->qual[drc_end_loop].text),"",0)
            IF (size(trim(drc_text->qual[drc_end_loop].text,3))=0)
             FOR (drc_loop2 = (drc_end_loop+ 1) TO drc_text->cnt)
               SET drc_text->qual[(drc_loop2 - 1)].text = drc_text->qual[drc_loop2].text
             ENDFOR
             SET drc_text->cnt = (drc_text->cnt - 1)
            ENDIF
            SET drc_start = 1
            SET drc_idx = 0
            SET drc_idx2 = 1
            SET drc_end_loop = (size(drc_text->qual,5)+ 1)
           ELSE
            SET drc_diff = (drc_end_loop - drc_loop)
            IF (drc_pos > 1)
             SET drc_text->qual[drc_loop].text = substring(1,(drc_pos - 1),drc_text->qual[drc_loop].
              text)
             SET drc_diff = (drc_diff - 1)
            ENDIF
            IF ((drc_stop < (size(drc_text->qual[drc_end_loop].text) - 1)))
             SET drc_text->qual[drc_end_loop].text = substring((drc_stop+ 2),size(drc_text->qual[
               drc_end_loop].text),drc_text->qual[drc_end_loop].text)
             IF ((drc_end_loop=drc_text->cnt))
              SET drc_text->qual[(drc_end_loop - drc_diff)].text = drc_text->qual[drc_end_loop].text
             ELSE
              FOR (drc_loop2 = drc_end_loop TO drc_text->cnt)
                SET drc_text->qual[(drc_loop2 - drc_diff)].text = drc_text->qual[drc_loop2].text
              ENDFOR
             ENDIF
             SET drc_text->cnt = (drc_text->cnt - drc_diff)
            ELSE
             SET drc_diff = (drc_diff+ 1)
             IF ((drc_end_loop < drc_text->cnt))
              FOR (drc_loop2 = (drc_end_loop+ 1) TO drc_text->cnt)
                SET drc_text->qual[(drc_loop2 - drc_diff)].text = drc_text->qual[drc_loop2].text
              ENDFOR
             ENDIF
             SET drc_text->cnt = (drc_text->cnt - drc_diff)
            ENDIF
            SET drc_start = 1
            SET drc_idx = 0
            SET drc_idx2 = 1
            SET drc_end_loop = (size(drc_text->qual,5)+ 1)
           ENDIF
          ENDIF
         ENDWHILE
         SET drc_start = 1
       ENDFOR
      ELSE
       SET drc_idx = 1
      ENDIF
     ENDWHILE
   ENDFOR
   SET stat = alterlist(drc_text->qual,drc_text->cnt)
   FOR (drc_loop = 1 TO drc_text->cnt)
    SET drc_pos = findstring(concat(";"),drc_text->qual[drc_loop].text,1,0)
    IF (drc_pos=1)
     FOR (drc_loop2 = (drc_loop+ 1) TO drc_text->cnt)
       SET drc_text->qual[(drc_loop2 - 1)].text = drc_text->qual[drc_loop2].text
     ENDFOR
     SET drc_text->cnt = (drc_text->cnt - 1)
    ELSEIF (drc_pos > 0)
     SET drc_text->qual[drc_loop].text = substring(1,(drc_pos - 1),drc_text->qual[drc_loop].text)
    ENDIF
   ENDFOR
   SET stat = alterlist(drc_text->qual,drc_text->cnt)
   RETURN(null)
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
 DECLARE drgsl_query_temp = vc WITH protect, noconstant(" ")
 DECLARE drgsl_select_start = i4 WITH protect, noconstant(0)
 DECLARE drgsl_from_start = i4 WITH protect, noconstant(0)
 FREE RECORD drgsl_query_text
 RECORD drgsl_query_text(
   1 cnt = i4
   1 qual[*]
     2 text = vc
 )
 SET dm_err->eproc = "Starting dm_rmc_get_select_list..."
 IF (check_logfile("dm_rmc_select_list",".log","DM_RMC_GET_SELECT_LIST LOG")=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to Create Log File"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (reflect(parameter(1,0)) != "C*")
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat("Expected syntax:  dm_rmc_get_select_list <query> go")
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ELSE
  SET drgsl_query_text->cnt = 1
  SET stat = alterlist(drgsl_query_text->qual,drgsl_query_text->cnt)
  SET drgsl_query_text->qual[drgsl_query_text->cnt].text = cnvtupper( $1)
 ENDIF
 IF (daf_is_blank(drgsl_query_text->qual[drgsl_query_text->cnt].text))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "ERROR: The parameter passed in must contain a query."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 CALL drqp_remove_comments(drgsl_query_text)
 SET stat = initrec(drqp_pos)
 CALL drqp_find_clause("SELECT",drgsl_query_text,1,1,drqp_pos,
  2)
 IF (check_error("Error finding select clause") != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF ((drqp_pos->qual_pos=0)
  AND (drqp_pos->char_pos=0))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat("The SELECT clause was not found in the provided query.")
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ELSE
  SET drgsl_select_start = drqp_pos->char_pos
 ENDIF
 SET drgsl_query_temp = ""
 SET drqp_pos->qual_pos = 0
 SET drqp_pos->char_pos = 0
 CALL drqp_find_clause("FROM",drgsl_query_text,1,drgsl_select_start,drqp_pos,
  0)
 IF (check_error("Looking for FROM clause") != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF ((drqp_pos->qual_pos=0)
  AND (drqp_pos->char_pos=0))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat("The FROM clause was not found in the provided query.")
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET drgsl_from_start = drqp_pos->char_pos
 SET drgsl_query_temp = ""
 SET drgsl_query_temp = trim(substring((drgsl_select_start+ 6),(drgsl_from_start - (
   drgsl_select_start+ 6)),drgsl_query_text->qual[1].text),3)
 CALL echo(concat("tempstuff:",drgsl_query_temp))
 CALL drqp_parse_columns(drgsl_query_temp,drqp_reply)
 IF (check_error("Parsing column list apart") != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF ((dm_err->debug_flag > 0))
  CALL echorecord(drqp_reply)
 ENDIF
#exit_program
END GO
