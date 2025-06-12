CREATE PROGRAM dm_rdds_audit:dba
 PROMPT
  "  Enter the name of the output XML file('audit.xml'): " = "audit",
  "Enter the table name or pattern to be audited:('*'): " = "*",
  "Enter the source domain id: " = 0,
  "Should the audit limit change log retrieval:('Yes'): " = "Yes",
  "Should the audit limit the sample size:('Yes'): " = "Yes",
  "Should the audit limit the output to matching change log rows: ('Yes'): " = "Yes",
  "Should the audit limit by context_name:('No'): " = "No"
  WITH outdev, ptable, psrcenv
 IF ( NOT (validate(dguc_request,0)))
  FREE RECORD dguc_request
  RECORD dguc_request(
    1 what_tables = vc
    1 is_ref_ind = i2
    1 is_mrg_ind = i2
    1 only_special_ind = i2
    1 current_remote_db = i2
    1 local_tables_ind = i2
    1 db_link = vc
    1 req_special[*]
      2 sp_tbl = vc
  )
 ENDIF
 IF ( NOT (validate(dguc_reply,0)))
  FREE RECORD dguc_reply
  RECORD dguc_reply(
    1 rs_tbl_cnt = i4
    1 dguc_err_ind = i2
    1 dguc_err_msg = vc
    1 dtd_hold[*]
      2 tbl_name = vc
      2 tbl_suffix = vc
      2 pk_cnt = i4
      2 pk_hold[*]
        3 pk_datatype = vc
        3 pk_name = vc
  )
 ENDIF
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
 DECLARE regen_trigs(null) = i4
 DECLARE check_open_event(cur_env_id=f8,paired_env_id=f8) = i4
 SUBROUTINE regen_trigs(null)
   DECLARE rt_err_flg = i2 WITH protect, noconstant(0)
   FREE RECORD invalid
   RECORD invalid(
     1 data[*]
       2 name = vc
   )
   SET dm_err->eproc = "Regenerating triggers..."
   CALL disp_msg("",dm_err->logfile,0)
   EXECUTE dm2_add_refchg_log_triggers
   SET dm_err->eproc = "RECOMPILING INVALID TRIGGERS"
   SELECT INTO "NL:"
    FROM dm2_user_objects d1
    WHERE d1.object_name="REFCHG*"
     AND d1.object_type="TRIGGER"
     AND d1.status != "VALID"
     AND d1.object_name != "REFCHG*MC*"
    HEAD REPORT
     trig_cnt = 0
    DETAIL
     trig_cnt = (trig_cnt+ 1)
     IF (mod(trig_cnt,10)=1)
      stat = alterlist(invalid->data,(trig_cnt+ 9))
     ENDIF
     invalid->data[trig_cnt].name = d1.object_name
    FOOT REPORT
     stat = alterlist(invalid->data,trig_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->emsg = "Error checking invalid triggers"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET rt_err_flg = 1
    SET dm_err->err_ind = 1
    ROLLBACK
    RETURN(rt_err_flg)
   ENDIF
   FOR (t_ndx = 1 TO size(invalid->data,5))
     CALL parser(concat("RDB ASIS(^alter trigger ",invalid->data[t_ndx].name," compile^) go"))
   ENDFOR
   SELECT INTO "NL:"
    FROM dm2_user_objects d1
    WHERE d1.object_name="REFCHG*"
     AND d1.object_type="TRIGGER"
     AND d1.status != "VALID"
     AND d1.object_name != "REFCHG*MC*"
    DETAIL
     v_trigger_name = d1.object_name
    WITH nocounter, maxqual(d1,1)
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET dm_err->emsg = "Error compiling invalid triggers"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET rt_err_flg = 1
    SET dm_err->err_ind = 1
    ROLLBACK
    RETURN(rt_err_flg)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = "Triggers regenerated successfully."
    SET rt_err_flg = 0
   ELSE
    SET dm_err->eproc = "Error regenerating RDDS related triggers."
    SET rt_err_flg = 1
    RETURN(rt_err_flg)
   ENDIF
   RETURN(rt_err_flg)
 END ;Subroutine
 SUBROUTINE check_open_event(cur_env_id,paired_env_id)
   DECLARE coe_event_flg = i4 WITH protect
   IF (cur_env_id > 0
    AND paired_env_id > 0)
    SET dm_err->eproc = "Checking open events for environment pair."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "NL:"
     FROM dm_rdds_event_log drel
     WHERE drel.rdds_event="Begin Reference Data Sync"
      AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
      AND drel.cur_environment_id=cur_env_id
      AND drel.paired_environment_id=paired_env_id
      AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
     (SELECT
      cur_environment_id, paired_environment_id, event_reason
      FROM dm_rdds_event_log
      WHERE cur_environment_id=cur_env_id
       AND paired_environment_id=paired_env_id
       AND rdds_event="End Reference Data Sync"
       AND rdds_event_key="ENDREFERENCEDATASYNC")))
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(coe_event_flg)
    ENDIF
    IF (curqual=0)
     SET dm_err->eproc = "Determining reverse open events for environment pair."
     SELECT INTO "NL:"
      FROM dm_rdds_event_log drel
      WHERE drel.rdds_event="Begin Reference Data Sync"
       AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
       AND drel.cur_environment_id=paired_env_id
       AND drel.paired_environment_id=cur_env_id
       AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
      (SELECT
       cur_environment_id, paired_environment_id, event_reason
       FROM dm_rdds_event_log
       WHERE cur_environment_id=paired_env_id
        AND paired_environment_id=cur_env_id
        AND rdds_event="End Reference Data Sync"
        AND rdds_event_key="ENDREFERENCEDATASYNC")))
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(coe_event_flg)
     ENDIF
     IF (curqual > 0)
      SET coe_event_flg = 2
     ENDIF
    ELSE
     SET coe_event_flg = 1
    ENDIF
   ENDIF
   IF (paired_env_id=0)
    SET dm_err->eproc = "Determining open events for current environment."
    SELECT INTO "NL:"
     FROM dm_rdds_event_log drel
     WHERE drel.rdds_event="Begin Reference Data Sync"
      AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
      AND drel.cur_environment_id=cur_env_id
      AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
     (SELECT
      cur_environment_id, paired_environment_id, event_reason
      FROM dm_rdds_event_log
      WHERE cur_environment_id=cur_env_id
       AND rdds_event="End Reference Data Sync"
       AND rdds_event_key="ENDREFERENCEDATASYNC")))
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(coe_event_flg)
    ENDIF
    IF (curqual > 0)
     SET coe_event_flg = 1
    ENDIF
   ENDIF
   RETURN(coe_event_flg)
 END ;Subroutine
 DECLARE check_sql_error(cse_object_name=vc,cse_object_type=vc) = i4
 SUBROUTINE check_sql_error(cse_object_name,cse_object_type)
   DECLARE sql_obj_name = vc WITH protect, noconstant(cnvtupper(trim(cse_object_name,3)))
   DECLARE sql_obj_type = vc WITH protect, noconstant(cnvtupper(trim(cse_object_type,3)))
   DECLARE par = c20 WITH protect, noconstant("")
   DECLARE sql_error_msg = vc WITH protect, noconstant("")
   DECLARE sql_disp_msg = vc WITH protect, noconstant("")
   DECLARE sql_chk_num = i4 WITH protect, noconstant(1)
   DECLARE sql_chk_cnt = i4 WITH protect, noconstant(0)
   DECLARE valid_obj_flg = i4 WITH protect, noconstant(0)
   IF (((sql_obj_name=" ") OR (sql_obj_type=" ")) )
    SET valid_obj_flg = 0
    SET sql_disp_msg = "Incorrect parameters. Usage:dm_rmc_sql_chk <object_name>, <object_type>"
    CALL echo("Incorrect parameters. Usage:dm_rmc_sql_chk <object_name>, <object_type>")
    RETURN(valid_obj_flg)
   ENDIF
   SELECT INTO "nl:"
    u.text
    FROM user_errors u
    WHERE u.name=sql_obj_name
     AND u.type=sql_obj_type
    DETAIL
     sql_error_msg = u.text
    WITH nocounter
   ;end select
   IF (curqual)
    SET sql_disp_msg = concat(sql_obj_type," ",sql_obj_name," failed to compile:",sql_error_msg)
    CALL echo(concat(sql_obj_type," ",sql_obj_name," failed to compile:",sql_error_msg))
    SET valid_obj_flg = 0
   ENDIF
   SELECT INTO "nl:"
    u.object_name
    FROM user_objects u
    WHERE u.object_name=sql_obj_name
     AND u.object_type=sql_obj_type
     AND u.status="VALID"
    WITH nocounter
   ;end select
   IF (curqual)
    SET sql_disp_msg = concat(sql_obj_type," ",sql_obj_name," is valid.")
    CALL echo(sql_disp_msg)
    SET valid_obj_flg = 1
   ELSE
    SET sql_disp_msg = concat(sql_obj_type," ",sql_obj_name," is invalid.")
    CALL echo(sql_disp_msg)
    SET valid_obj_flg = 0
   ENDIF
   RETURN(valid_obj_flg)
 END ;Subroutine
 DECLARE remove_lock(i_info_domain=vc,i_info_name=vc,i_info_char=vc,io_reply=vc(ref)) = null
 DECLARE check_lock(i_info_domain=vc,i_info_name=vc,io_reply=vc(ref)) = null
 DECLARE get_lock(i_info_domain=vc,i_info_name=vc,i_retry_limit=i2,io_reply=vc(ref)) = null
 IF ((validate(drl_request->retry_flag,- (1))=- (1)))
  FREE RECORD drl_request
  RECORD drl_request(
    1 info_domain = vc
    1 info_name = vc
    1 info_char = vc
    1 info_number = f8
    1 retry_flag = i2
  )
  FREE RECORD drl_reply
  RECORD drl_reply(
    1 status = c1
    1 status_msg = vc
  )
 ENDIF
 SUBROUTINE remove_lock(i_info_domain,i_info_name,i_info_char,io_reply)
  DELETE  FROM dm_info di
   WHERE di.info_domain=i_info_domain
    AND di.info_name=i_info_name
    AND di.info_char=i_info_char
   WITH nocounter
  ;end delete
  IF (check_error("Deleting in-process row from dm_info") != 0)
   SET io_reply->status = "F"
   SET io_reply->status_msg = dm_err->emsg
  ELSE
   COMMIT
  ENDIF
 END ;Subroutine
 SUBROUTINE check_lock(i_info_domain,i_info_name,io_reply)
   DECLARE s_info_char = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    rdbhandle = trim(di.info_char)
    FROM dm_info di
    WHERE di.info_domain=i_info_domain
     AND di.info_name=i_info_name
    DETAIL
     s_info_char = rdbhandle
    WITH nocounter
   ;end select
   IF (check_error("Retrieving in-process from from dm_info") != 0)
    SET io_reply->status = "F"
    SET io_reply->status_msg = dm_err->emsg
    RETURN
   ENDIF
   IF (s_info_char > ""
    AND s_info_char != currdbhandle)
    SELECT INTO "nl:"
     FROM gv$session s
     WHERE s.audsid=cnvtreal(s_info_char)
     WITH nocounter
    ;end select
    IF (check_error("Retrieving session id from gv$session") != 0)
     SET io_reply->status = "F"
     SET io_reply->status_msg = dm_err->emsg
     RETURN
    ENDIF
    IF (curqual=0)
     CALL remove_lock(i_info_domain,i_info_name,s_info_char,io_reply)
    ELSE
     SET io_reply->status = "Z"
     SET io_reply->status_msg = "Another active session has the required lock."
    ENDIF
   ELSEIF (s_info_char=currdbhandle)
    SET io_reply->status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE get_lock(i_info_domain,i_info_name,i_retry_limit,io_reply)
   DECLARE s_retry_cnt = i2 WITH protect, noconstant(0)
   DECLARE s_retry_limit = i2 WITH protect, noconstant(i_retry_limit)
   IF (s_retry_limit <= 0)
    SET s_retry_limit = 3
   ENDIF
   SET io_reply->status = ""
   SET io_reply->status_msg = ""
   CALL check_lock(i_info_domain,i_info_name,io_reply)
   IF ((io_reply->status=""))
    FOR (s_retry_cnt = 1 TO s_retry_limit)
     INSERT  FROM dm_info di
      SET di.info_domain = i_info_domain, di.info_name = i_info_name, di.info_char = currdbhandle
      WITH nocounter
     ;end insert
     IF (check_error("Inserting lock creation row...") != 0)
      IF (findstring("ORA-00001",dm_err->emsg,1,0) > 0)
       SET dm_err->err_ind = 0
       CALL check_lock(i_info_domain,i_info_name,io_reply)
       IF ((io_reply->status="F"))
        SET io_reply->status_msg = dm_err->emsg
        SET s_retry_cnt = s_retry_limit
       ELSEIF ((io_reply->status="Z"))
        SET s_retry_cnt = s_retry_limit
       ELSE
        SET io_reply->status = "F"
        SET io_reply->status_msg = dm_err->emsg
        SET dm_err->err_ind = 0
       ENDIF
      ELSE
       ROLLBACK
       SET io_reply->status = "F"
       SET io_reply->status_msg = dm_err->emsg
       SET s_retry_cnt = s_retry_limit
      ENDIF
     ELSE
      COMMIT
      SET io_reply->status = "S"
      SET io_reply->status_msg = ""
      SET s_retry_cnt = s_retry_limit
     ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 DECLARE parse_string(i_string=vc,i_string_delim=vc,io_string_rs=vc(ref)) = null
 DECLARE encode_html_string(io_string=vc) = vc
 DECLARE copy_xsl(i_template_name=vc,i_file_name=vc) = i2
 DECLARE dmda_get_file_name(i_env_id=f8,i_env_name=vc,i_mnu_hdg=vc,i_default_name=vc,i_file_xtn=vc,
  i_type=vc) = vc
 SUBROUTINE parse_string(i_string,i_string_delim,io_string_rs)
   DECLARE ps_delim_len = i4 WITH protect, noconstant(size(i_string_delim))
   DECLARE ps_str_len = i4 WITH protect, noconstant(size(i_string))
   DECLARE ps_start = i4 WITH protect, noconstant(1)
   DECLARE ps_pos = i4 WITH protect, noconstant(0)
   DECLARE ps_num_found = i4 WITH protect, noconstant(0)
   DECLARE ps_idx = i4 WITH protect, noconstant(0)
   DECLARE ps_loop = i4 WITH protect, noconstant(0)
   DECLARE ps_temp_string = vc WITH protect, noconstant("")
   SET ps_pos = findstring(i_string_delim,i_string,ps_start)
   SET ps_num_found = size(io_string_rs->qual,5)
   WHILE (ps_pos > 0)
     SET ps_num_found = (ps_num_found+ 1)
     SET ps_temp_string = substring(ps_start,(ps_pos - ps_start),i_string)
     IF (ps_num_found > 1)
      SET ps_idx = locateval(ps_loop,1,(ps_num_found - 1),ps_temp_string,io_string_rs->qual[ps_loop].
       values)
     ELSE
      SET ps_idx = 0
     ENDIF
     IF (ps_idx=0)
      SET stat = alterlist(io_string_rs->qual,ps_num_found)
      SET io_string_rs->qual[ps_num_found].values = ps_temp_string
     ELSE
      SET ps_num_found = (ps_num_found - 1)
     ENDIF
     SET ps_start = (ps_pos+ ps_delim_len)
     SET ps_pos = findstring(i_string_delim,i_string,ps_start)
   ENDWHILE
   IF (ps_start <= ps_str_len)
    SET ps_num_found = (ps_num_found+ 1)
    SET ps_temp_string = substring(ps_start,((ps_str_len - ps_start)+ 1),i_string)
    IF (ps_num_found > 1)
     SET ps_idx = locateval(ps_loop,1,(ps_num_found - 1),ps_temp_string,io_string_rs->qual[ps_loop].
      values)
    ELSE
     SET ps_idx = 0
    ENDIF
    IF (ps_idx=0)
     SET stat = alterlist(io_string_rs->qual,ps_num_found)
     SET io_string_rs->qual[ps_num_found].values = ps_temp_string
    ELSE
     SET ps_num_found = (ps_num_found - 1)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE encode_html_string(i_string)
   SET i_string = replace(i_string,"&","&amp;",0)
   SET i_string = replace(i_string,"<","&lt;",0)
   SET i_string = replace(i_string,">","&gt;",0)
   RETURN(i_string)
 END ;Subroutine
 SUBROUTINE copy_xsl(i_template_name,i_file_name)
   SET dm_err->eproc = "Copying Stylesheet"
   CALL disp_msg("",dm_err->logfile,0)
   DECLARE cx_cmd = vc WITH protect, noconstant("")
   DECLARE cx_status = i4 WITH protect, noconstant(0)
   IF (cursys="AXP")
    SET cx_cmd = concat("COPY CER_INSTALL:",trim(i_template_name,3)," CCLUSERDIR:",i_file_name)
    SET cx_status = 0
    SET cx_status = dm2_push_dcl(cx_cmd)
    IF (cx_status=0)
     SET dm_err->emsg = "Failed copying stylesheet "
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(- (1))
    ENDIF
   ELSE
    SET cx_cmd = concat("cp $cer_install/",trim(i_template_name,3)," $CCLUSERDIR/",i_file_name)
    SET cx_status = 0
    SET cx_status = dm2_push_dcl(cx_cmd)
    IF (cx_status=0)
     SET dm_err->emsg = "Failed copying stylesheet "
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(- (1))
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dmda_get_file_name(i_env_id,i_env_name,i_mnu_hdg,i_default_name,i_file_xtn,i_type)
   SET dm_err->eproc = "Getting file name"
   DECLARE dgfn_file_name = vc
   DECLARE dgfn_menu = i2
   DECLARE dgfn_file_xtn = vc
   DECLARE dgfn_default_name = vc
   IF (findstring(".",i_file_xtn)=0)
    SET dgfn_file_xtn = cnvtlower(concat(".",i_file_xtn))
   ELSE
    SET dgfn_file_xtn = cnvtlower(i_file_xtn)
   ENDIF
   IF (findstring(".",i_default_name) > 0)
    SET dgfn_default_name = cnvtlower(substring(1,(findstring(".",i_default_name) - 1),i_default_name
      ))
   ELSE
    SET dgfn_default_name = cnvtlower(i_default_name)
   ENDIF
   CALL check_lock("RDDS FILENAME LOCK",concat(dgfn_default_name,dgfn_file_xtn),drl_reply)
   IF ((drl_reply->status="F"))
    RETURN("-1")
   ELSEIF ((drl_reply->status="Z"))
    SET dgfn_default_name = concat(trim(substring(1,((30 - size(dgfn_file_xtn)) - size(trim(
         currdbhandle))),dgfn_default_name)),currdbhandle)
   ENDIF
   SET stat = initrec(drl_reply)
   SET dgfn_menu = 0
   WHILE (dgfn_menu=0)
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,5,132)
     CALL text(3,44,concat("***  ",i_mnu_hdg,"  ***"))
     CALL text(4,75,"ENVIRONMENT ID:")
     CALL text(4,20,"ENVIRONMENT NAME:")
     CALL text(4,95,cnvtstring(i_env_id))
     CALL text(4,40,i_env_name)
     CALL text(7,3,concat("Please enter a file name for ",i_type," (0 to exit): "))
     CALL text(9,3,"NOTE: This will overwrite any file in CCLUSERDIR with the same name.")
     SET accept = nopatcheck
     CALL accept(7,70,"P(30);C",trim(build(dgfn_default_name,dgfn_file_xtn)))
     SET accept = patcheck
     SET dgfn_file_name = curaccept
     IF (dgfn_file_name="0")
      SET dgfn_menu = 1
      RETURN("-1")
     ENDIF
     IF (findstring(".",dgfn_file_name)=0)
      SET dgfn_file_name = concat(dgfn_file_name,dgfn_file_xtn)
     ENDIF
     IF (size(dgfn_file_name) > 30)
      SET dgfn_file_name = concat(trim(substring(1,(30 - size(dgfn_file_xtn)),dgfn_file_name)),
       dgfn_file_xtn)
     ENDIF
     CALL check_lock("RDDS FILENAME LOCK",dgfn_file_name,drl_reply)
     IF ((drl_reply->status="F"))
      RETURN("-1")
     ENDIF
     IF (cnvtlower(substring(findstring(".",dgfn_file_name),size(dgfn_file_name,1),dgfn_file_name))
      != cnvtlower(dgfn_file_xtn))
      CALL text(20,3,concat("Invalid file type, file extension must be ",dgfn_file_xtn))
      CALL pause(5)
     ELSEIF ((drl_reply->status="Z"))
      CALL text(20,3,concat("File name ",dgfn_file_name,
        " is currently locked, please choose a different filename."))
      CALL pause(5)
      IF ((((size(substring(1,(findstring(".",dgfn_file_name) - 1),dgfn_file_name))+ size(trim(
        currdbhandle)))+ size(dgfn_file_xtn)) <= 30))
       SET dgfn_default_name = concat(substring(1,(findstring(".",dgfn_file_name) - 1),dgfn_file_name
         ),trim(currdbhandle))
      ELSE
       SET dgfn_default_name = concat(trim(substring(1,((30 - size(dgfn_file_xtn)) - size(trim(
            currdbhandle))),dgfn_file_name)),trim(currdbhandle))
      ENDIF
     ELSE
      CALL get_lock("RDDS FILENAME LOCK",dgfn_file_name,1,drl_reply)
      IF ((drl_reply->status="F"))
       RETURN("-1")
      ELSEIF ((drl_reply->status="Z"))
       CALL text(20,3,concat("File name ",dgfn_file_name,
         " is currently locked, please choose a different filename."))
       CALL pause(5)
       IF ((((size(substring(1,(findstring(".",dgfn_file_name) - 1),dgfn_file_name))+ size(trim(
         currdbhandle)))+ size(dgfn_file_xtn)) <= 30))
        SET dgfn_default_name = concat(substring(1,(findstring(".",dgfn_file_name) - 1),
          dgfn_file_name),trim(currdbhandle))
       ELSE
        SET dgfn_default_name = concat(trim(substring(1,((30 - size(dgfn_file_xtn)) - size(trim(
             currdbhandle))),dgfn_file_name)),trim(currdbhandle))
       ENDIF
      ELSE
       SET dgfn_menu = 1
      ENDIF
     ENDIF
     SET stat = initrec(drl_reply)
   ENDWHILE
   RETURN(dgfn_file_name)
 END ;Subroutine
 IF ( NOT (validate(auto_ver_request,0)))
  FREE RECORD auto_ver_request
  RECORD auto_ver_request(
    1 qual[*]
      2 rdds_event = vc
      2 event_reason = vc
      2 cur_environment_id = f8
      2 paired_environment_id = f8
      2 detail_qual[*]
        3 event_detail1_txt = vc
        3 event_detail2_txt = vc
        3 event_detail3_txt = vc
        3 event_value = f8
  )
  FREE RECORD auto_ver_reply
  RECORD auto_ver_reply(
    1 status = c1
    1 status_msg = vc
  )
 ENDIF
 DECLARE remove_lock(i_info_domain=vc,i_info_name=vc,i_info_char=vc,io_reply=vc(ref)) = null
 DECLARE check_lock(i_info_domain=vc,i_info_name=vc,io_reply=vc(ref)) = null
 DECLARE get_lock(i_info_domain=vc,i_info_name=vc,i_retry_limit=i2,io_reply=vc(ref)) = null
 IF ((validate(drl_request->retry_flag,- (1))=- (1)))
  FREE RECORD drl_request
  RECORD drl_request(
    1 info_domain = vc
    1 info_name = vc
    1 info_char = vc
    1 info_number = f8
    1 retry_flag = i2
  )
  FREE RECORD drl_reply
  RECORD drl_reply(
    1 status = c1
    1 status_msg = vc
  )
 ENDIF
 SUBROUTINE remove_lock(i_info_domain,i_info_name,i_info_char,io_reply)
  DELETE  FROM dm_info di
   WHERE di.info_domain=i_info_domain
    AND di.info_name=i_info_name
    AND di.info_char=i_info_char
   WITH nocounter
  ;end delete
  IF (check_error("Deleting in-process row from dm_info") != 0)
   SET io_reply->status = "F"
   SET io_reply->status_msg = dm_err->emsg
  ELSE
   COMMIT
  ENDIF
 END ;Subroutine
 SUBROUTINE check_lock(i_info_domain,i_info_name,io_reply)
   DECLARE s_info_char = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    rdbhandle = trim(di.info_char)
    FROM dm_info di
    WHERE di.info_domain=i_info_domain
     AND di.info_name=i_info_name
    DETAIL
     s_info_char = rdbhandle
    WITH nocounter
   ;end select
   IF (check_error("Retrieving in-process from from dm_info") != 0)
    SET io_reply->status = "F"
    SET io_reply->status_msg = dm_err->emsg
    RETURN
   ENDIF
   IF (s_info_char > ""
    AND s_info_char != currdbhandle)
    SELECT INTO "nl:"
     FROM gv$session s
     WHERE s.audsid=cnvtreal(s_info_char)
     WITH nocounter
    ;end select
    IF (check_error("Retrieving session id from gv$session") != 0)
     SET io_reply->status = "F"
     SET io_reply->status_msg = dm_err->emsg
     RETURN
    ENDIF
    IF (curqual=0)
     CALL remove_lock(i_info_domain,i_info_name,s_info_char,io_reply)
    ELSE
     SET io_reply->status = "Z"
     SET io_reply->status_msg = "Another active session has the required lock."
    ENDIF
   ELSEIF (s_info_char=currdbhandle)
    SET io_reply->status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE get_lock(i_info_domain,i_info_name,i_retry_limit,io_reply)
   DECLARE s_retry_cnt = i2 WITH protect, noconstant(0)
   DECLARE s_retry_limit = i2 WITH protect, noconstant(i_retry_limit)
   IF (s_retry_limit <= 0)
    SET s_retry_limit = 3
   ENDIF
   SET io_reply->status = ""
   SET io_reply->status_msg = ""
   CALL check_lock(i_info_domain,i_info_name,io_reply)
   IF ((io_reply->status=""))
    FOR (s_retry_cnt = 1 TO s_retry_limit)
     INSERT  FROM dm_info di
      SET di.info_domain = i_info_domain, di.info_name = i_info_name, di.info_char = currdbhandle
      WITH nocounter
     ;end insert
     IF (check_error("Inserting lock creation row...") != 0)
      IF (findstring("ORA-00001",dm_err->emsg,1,0) > 0)
       SET dm_err->err_ind = 0
       CALL check_lock(i_info_domain,i_info_name,io_reply)
       IF ((io_reply->status="F"))
        SET io_reply->status_msg = dm_err->emsg
        SET s_retry_cnt = s_retry_limit
       ELSEIF ((io_reply->status="Z"))
        SET s_retry_cnt = s_retry_limit
       ELSE
        SET io_reply->status = "F"
        SET io_reply->status_msg = dm_err->emsg
        SET dm_err->err_ind = 0
       ENDIF
      ELSE
       ROLLBACK
       SET io_reply->status = "F"
       SET io_reply->status_msg = dm_err->emsg
       SET s_retry_cnt = s_retry_limit
      ENDIF
     ELSE
      COMMIT
      SET io_reply->status = "S"
      SET io_reply->status_msg = ""
      SET s_retry_cnt = s_retry_limit
     ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 DECLARE drdc_to_string(dts_num=f8) = vc
 SUBROUTINE drdc_to_string(dts_num)
   DECLARE dts_str = vc WITH protect, noconstant("")
   SET dts_str = trim(cnvtstring(dts_num,20),3)
   IF (findstring(".",dts_str)=0)
    SET dts_str = concat(dts_str,".0")
   ENDIF
   RETURN(dts_str)
 END ;Subroutine
 DECLARE drmmi_set_mock_id(dsmi_cur_id=f8,dsmi_final_tgt_id=f8,dsmi_mock_ind=i2) = i4
 DECLARE drmmi_get_mock_id(dgmi_env_id=f8) = f8
 DECLARE drmmi_backfill_mock_id(dbmi_env_id=f8) = f8
 SUBROUTINE drmmi_set_mock_id(dsmi_cur_id,dsmi_final_tgt_id,dsmi_mock_ind)
   DECLARE dsmi_info_char = vc WITH protect, noconstant("")
   DECLARE dsmi_mock_str = vc WITH protect, noconstant("")
   SET dsmi_info_char = drdc_to_string(dsmi_cur_id)
   SET dm_err->eproc = "Delete current mock setting."
   DELETE  FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name IN ("RDDS_MOCK_ENV_ID", "RDDS_NO_MOCK_ENV_ID")
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   IF (dsmi_mock_ind=1)
    SET dsmi_mock_str = "RDDS_MOCK_ENV_ID"
   ELSE
    SET dsmi_mock_str = "RDDS_NO_MOCK_ENV_ID"
   ENDIF
   SET dm_err->eproc = "Inserting new mock setting into dm_info."
   INSERT  FROM dm_info di
    SET di.info_domain = "DATA MANAGEMENT", di.info_name = dsmi_mock_str, di.info_number =
     dsmi_final_tgt_id,
     di.info_char = dsmi_info_char, di.updt_applctx = reqinfo->updt_applctx, di.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     di.updt_cnt = 0, di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   SET dm_err->eproc = "Log Mock Copy of Prod Change event."
   SET stat = initrec(auto_ver_request)
   SET stat = initrec(auto_ver_reply)
   SET stat = alterlist(auto_ver_request->qual,1)
   SET auto_ver_request->qual[1].rdds_event = "Mock Copy of Prod Change"
   SET auto_ver_request->qual[1].cur_environment_id = dsmi_cur_id
   SET auto_ver_request->qual[1].paired_environment_id = dsmi_final_tgt_id
   EXECUTE dm_rmc_auto_verify_setup
   IF ((auto_ver_reply->status="F"))
    ROLLBACK
    SET dm_err->err_ind = 1
    SET dm_err->emsg = auto_ver_reply->status_msg
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ELSE
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drmmi_get_mock_id(dgmi_env_id)
   DECLARE dgmi_mock_id = f8 WITH protect, noconstant(0.0)
   DECLARE dgmi_info_char = vc WITH protect, noconstant("")
   IF (dgmi_env_id=0.0)
    SET dm_err->eproc = "Gathering environment_id from dm_info."
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_name="DM_ENV_ID"
      AND di.info_domain="DATA MANAGEMENT"
     DETAIL
      dgmi_env_id = di.info_number
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(- (1))
    ELSEIF (dgmi_env_id=0.0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Could not retrieve valid environment_id"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET dgmi_info_char = drdc_to_string(dgmi_env_id)
   SET dm_err->eproc = "Querying dm_info for mock id."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name IN ("RDDS_MOCK_ENV_ID", "RDDS_NO_MOCK_ENV_ID")
     AND di.info_char=dgmi_info_char
    DETAIL
     IF (di.info_name="RDDS_MOCK_ENV_ID")
      dgmi_mock_id = di.info_number
     ELSE
      dgmi_mock_id = dgmi_env_id
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ELSEIF (curqual > 1)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid MOCK setup detected."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   IF (dgmi_mock_id=0.0)
    SET dgmi_mock_id = drmmi_backfill_mock_id(dgmi_env_id)
    IF (dgmi_mock_id < 0.0)
     RETURN(- (1))
    ENDIF
   ENDIF
   RETURN(dgmi_mock_id)
 END ;Subroutine
 SUBROUTINE drmmi_backfill_mock_id(dbmi_env_id)
   DECLARE dbmi_mock_id = f8 WITH protect, noconstant(0.0)
   DECLARE dbmi_info_char = vc WITH protect, noconstant("")
   DECLARE dbmi_continue = i2 WITH protect, noconstant(0)
   SET dbmi_info_char = drdc_to_string(dbmi_env_id)
   WHILE (dbmi_continue=0)
     SET drl_reply->status = ""
     SET drl_reply->status_msg = ""
     CALL get_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,0,drl_reply)
     IF ((drl_reply->status="F"))
      CALL disp_msg(drl_reply->status_msg,dm_err->logfile,1)
      SET dm_err->err_ind = 1
      SET dm_err->emsg = drl_reply->status_msg
      CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
      RETURN(- (1))
     ELSEIF ((drl_reply->status="Z"))
      CALL pause(10)
     ELSE
      SET dbmi_continue = 1
     ENDIF
   ENDWHILE
   SET dm_err->eproc = "Querying dm_info for mock id."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name IN ("RDDS_MOCK_ENV_ID", "RDDS_NO_MOCK_ENV_ID")
     AND di.info_char=dbmi_info_char
    DETAIL
     IF (di.info_name="RDDS_MOCK_ENV_ID")
      dbmi_mock_id = di.info_number
     ELSE
      dbmi_mock_id = dbmi_env_id
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
    RETURN(- (1))
   ENDIF
   IF (dbmi_mock_id=0.0)
    UPDATE  FROM dm_info di
     SET di.info_char = dbmi_info_char
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="RDDS_MOCK_ENV_ID"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     ROLLBACK
     CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
     RETURN(- (1))
    ELSE
     COMMIT
    ENDIF
    IF (curqual=0)
     SET dm_err->eproc = "Updating RDDS_NO_MOCK_ENV_ID row."
     UPDATE  FROM dm_info di
      SET di.info_number = 0.0, di.info_char = dbmi_info_char, di.updt_applctx = reqinfo->
       updt_applctx,
       di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_cnt = 0, di.updt_id = reqinfo->updt_id,
       di.updt_task = reqinfo->updt_task
      WHERE di.info_domain="DATA MANAGEMENT"
       AND di.info_name="RDDS_NO_MOCK_ENV_ID"
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      ROLLBACK
      CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
      RETURN(- (1))
     ELSE
      COMMIT
     ENDIF
     IF (curqual=0)
      SET dm_err->eproc = "Inserting RDDS_NO_MOCK_ENV_ID row."
      INSERT  FROM dm_info di
       SET di.info_domain = "DATA MANAGEMENT", di.info_name = "RDDS_NO_MOCK_ENV_ID", di.info_number
         = 0.0,
        di.info_char = dbmi_info_char, di.updt_applctx = reqinfo->updt_applctx, di.updt_dt_tm =
        cnvtdatetime(curdate,curtime3),
        di.updt_cnt = 0, di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       ROLLBACK
       CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
       RETURN(- (1))
      ELSE
       COMMIT
      ENDIF
     ENDIF
     SET dbmi_mock_id = dbmi_env_id
    ELSE
     SET dm_err->eproc = "Querying for mock id."
     SELECT INTO "nl:"
      FROM dm_info di
      WHERE di.info_domain="DATA MANAGEMENT"
       AND di.info_name="RDDS_MOCK_ENV_ID"
       AND di.info_char=dbmi_info_char
      DETAIL
       dbmi_mock_id = di.info_number
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
      RETURN(- (1))
     ENDIF
    ENDIF
   ENDIF
   CALL remove_lock("RDDS MOCK ID BACKFILL",dbmi_info_char,currdbhandle,drl_reply)
   RETURN(dbmi_mock_id)
 END ;Subroutine
 DECLARE drrm_ack_mig(dam_oe_name=vc,dam_env_id=f8) = null
 DECLARE drrm_check_ack(dca_oe_name=vc) = i2
 DECLARE drrm_check_mig(dcm_check_ack_ind=i2,dcm_oe_name=vc) = i4
 DECLARE drrm_check_freeze(dcf_env_id=f8) = i2
 IF ( NOT (validate(auto_ver_request,0)))
  FREE RECORD auto_ver_request
  RECORD auto_ver_request(
    1 qual[*]
      2 rdds_event = vc
      2 event_reason = vc
      2 cur_environment_id = f8
      2 paired_environment_id = f8
      2 detail_qual[*]
        3 event_detail1_txt = vc
        3 event_detail2_txt = vc
        3 event_detail3_txt = vc
        3 event_value = f8
  )
  FREE RECORD auto_ver_reply
  RECORD auto_ver_reply(
    1 status = c1
    1 status_msg = vc
  )
 ENDIF
 SUBROUTINE drrm_ack_mig(dam_oe_name,dam_env_id)
   IF (size(trim(dam_oe_name))=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "No event name passed into DRRM_ACK_MIG."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   SET stat = alterlist(auto_ver_request->qual,1)
   SET auto_ver_request->qual[1].rdds_event = "MIGRATION ACKNOWLEDGE"
   SET auto_ver_request->qual[1].event_reason = dam_oe_name
   IF (dam_env_id=0.0)
    SELECT INTO "NL:"
     FROM dm_info d
     WHERE d.info_domain="DATA MANAGEMENT"
      AND d.info_name="DM_ENV_ID"
     DETAIL
      auto_ver_request->qual[1].cur_environment_id = d.info_number
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET stat = initrec(auto_ver_request)
     RETURN(null)
    ENDIF
    IF ((auto_ver_request->qual[1].cur_environment_id=0))
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "No environment_id found.  Please run DM_SET_ENV_ID to correct."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET stat = initrec(auto_ver_request)
     RETURN(null)
    ENDIF
   ELSE
    SET auto_ver_request->qual[1].cur_environment_id = dam_env_id
   ENDIF
   EXECUTE dm_rmc_auto_verify_setup
   IF ((auto_ver_reply->status="F"))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = auto_ver_reply->status_msg
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ELSE
    COMMIT
   ENDIF
   SET stat = initrec(auto_ver_reply)
   SET stat = initrec(auto_ver_request)
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drrm_check_ack(dca_oe_name)
   DECLARE dca_return = i2 WITH protect, noconstant(0)
   IF (size(trim(dca_oe_name)) > 0)
    SELECT INTO "NL:"
     cnt = count(*)
     FROM dm_rdds_event_log d,
      dm_info di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="DM_ENV_ID"
      AND d.cur_environment_id=di.info_number
      AND d.rdds_event_key="MIGRATIONACKNOWLEDGE"
      AND d.event_reason=dca_oe_name
     DETAIL
      IF (cnt > 0)
       dca_return = 1
      ENDIF
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "NL:"
     cnt = count(*)
     FROM dm_rdds_event_log d2,
      dm_rdds_event_log d,
      dm_info di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="DM_ENV_ID"
      AND d.cur_environment_id=di.info_number
      AND d.rdds_event_key="MIGRATIONACKNOWLEDGE"
      AND d2.cur_environment_id=d.cur_environment_id
      AND d2.event_reason=d.event_reason
      AND d2.rdds_event_key="BEGINREFERENCEDATASYNC"
      AND  NOT (list(d2.cur_environment_id,d2.paired_environment_id,d2.event_reason) IN (
     (SELECT
      d3.cur_environment_id, d3.paired_environment_id, d3.event_reason
      FROM dm_rdds_event_log d3
      WHERE d3.rdds_event_key="ENDREFERENCEDATASYNC"
       AND d3.cur_environment_id=di.info_number)))
     DETAIL
      IF (cnt > 0)
       dca_return = cnt
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
   RETURN(dca_return)
 END ;Subroutine
 SUBROUTINE drrm_check_mig(dcm_ack_ind,dcm_oe_name)
   DECLARE PUBLIC::dcm_return = i4 WITH protect, noconstant(0)
   DECLARE PUBLIC::dcm_ack_ret = i2 WITH protect, noconstant(0)
   DECLARE PUBLIC::dcm_script_name = vc WITH protect, noconstant("DM2_MIG_STATUS_CHECK")
   IF (validate(PUBLIC::dm2_mig_status,"-1")="-1")
    DECLARE PUBLIC::dm2_mig_status = vc WITH protect, noconstant("")
   ENDIF
   IF (validate(PUBLIC::dm2_mig_utc_status,"-1")="-1")
    DECLARE PUBLIC::dm2_mig_utc_status = vc WITH protect, noconstant("")
   ENDIF
   IF (checkprg(dcm_script_name) > 0)
    EXECUTE dm2_mig_status_check
    IF (((check_error(dm_err->eproc)=1) OR (((cnvtupper(dm2_mig_status) IN ("", "ERROR")) OR (
    cnvtupper(dm2_mig_utc_status) IN ("", "ERROR"))) )) )
     IF (size(trim(dm_err->emsg))=0)
      SET dm_err->emsg = "Unexpected error occurred in DM2_MIG_STATUS_CHECK"
      SET dm_err->err_ind = 1
     ENDIF
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (cnvtupper(dm2_mig_status)="ON")
     IF (cnvtupper(dm2_mig_utc_status)="ON")
      SET dcm_return = 2
     ELSE
      SET dcm_return = 1
     ENDIF
     IF (dcm_ack_ind=1)
      SET dcm_ack_ret = drrm_check_ack(dcm_oe_name)
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      IF (dcm_ack_ret=1)
       SET dcm_return = 0
      ENDIF
     ENDIF
    ELSE
     SET dcm_return = 0
    ENDIF
   ELSE
    SET dcm_return = 0
   ENDIF
   RETURN(dcm_return)
 END ;Subroutine
 SUBROUTINE drrm_check_freeze(dcf_env_id)
   DECLARE dcf_ret_val = i2 WITH protect, noconstant(0)
   DECLARE dcf_freeze_ind = i2 WITH protect, noconstant(0)
   DECLARE dcf_ovr_ind = i2 WITH protect, noconstant(0)
   DECLARE dcf_mig_domain = vc WITH protect, constant("DM2_MIG_STATUS_MARKER")
   DECLARE dcf_ovr_domain = vc WITH protect, constant("RDDS MIGRATION OVERRIDE")
   SELECT INTO "NL:"
    FROM dm_info di
    WHERE di.info_name="SCHEMA_FREEZE"
     AND di.info_domain IN (dcf_mig_domain, dcf_ovr_domain)
    DETAIL
     IF (di.info_domain=dcf_mig_domain)
      dcf_freeze_ind = 1
     ELSEIF (di.info_domain=dcf_ovr_domain
      AND di.info_number=dcf_env_id
      AND di.info_date >= cnvtdatetime(curdate,curtime3))
      dcf_ovr_ind = 1
     ENDIF
    FOOT REPORT
     IF (dcf_freeze_ind=1
      AND dcf_ovr_ind=0)
      dcf_ret_val = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(dcf_ret_val)
 END ;Subroutine
 IF ((dm_err->debug_flag >= 1))
  SET trace = echoinput
  SET trace = echoinput2
  SET trace = rdbbind
  SET trace = rdbdebug
  SET trace = callecho
  CALL trace(7)
 ENDIF
 DECLARE execute_ccl(dummy=i4) = i2 WITH protect
 DECLARE get_sequence_match(ssequencename=vc) = f8 WITH protect
 DECLARE create_functions(dummy=i4) = i2 WITH protect
 DECLARE create_table_functions(dummy=i4) = i2
 DECLARE print_xml_header(sfile=vc,sxslfile=vc) = i2 WITH protect
 DECLARE print_xml_body(sfile=vc) = i2 WITH protect
 DECLARE print_xml_body_summary(sfile=vc) = i2 WITH protect
 DECLARE print_xml_footer(sfile=vc) = i2 WITH protect
 DECLARE copy_stylesheet(sfile=vc,sxslfile=vc) = i2 WITH protect
 DECLARE print_screen_summary(sfile=vc,sfilesummary=vc,sxslfile=vc) = i2 WITH protect
 DECLARE evaluate_pe_name() = c255 WITH protect
 FREE RECORD table_info
 RECORD table_info(
   1 tables[*]
     2 table_name = vc
     2 table_suffix = vc
     2 src_filter_function = vc
     2 tgt_filter_function = vc
     2 src_pkwhere_function = vc
     2 tgt_pkwhere_function = vc
     2 src_filter_parameters = vc
     2 tgt_filter_parameters = vc
     2 src_pkwhere_parameters = vc
     2 tgt_pkwhere_parameters = vc
     2 cmp_pkwhere_parameters = vc
     2 src_pkwhere_signature = vc
     2 tgt_pkwhere_signature = vc
     2 cmp_pkwhere_signature = vc
     2 version_flg = i2
     2 exclusion_flg = i2
     2 beg_column_name = vc
     2 end_column_name = vc
     2 column_cnt = i4
     2 columns[*]
       3 column_name = vc
       3 no_compare_ind = i2
       3 data_type = vc
       3 custom_object_name = vc
       3 ccl_data_type = vc
       3 parm_list[*]
         4 column_name = vc
       3 root_entity_attr = vc
       3 root_entity_name = vc
       3 no_backfill_ind = i2
       3 constant_value = vc
       3 exception_flg = i2
       3 sequence_name = vc
       3 sequence_match = f8
       3 defining_attribute_ind = i2
       3 pk_ind = i2
       3 ui_ind = i2
       3 translation_ind = i2
       3 parent_entity_col = vc
       3 parent_entity_vals[*]
         4 pe_table_value = vc
         4 pe_name = vc
         4 pe_attr = vc
         4 root_entity_attr = vc
         4 root_entity_name = vc
         4 no_backfill_ind = i2
         4 sequence_name = vc
         4 sequence_match = f8
         4 exception_flg = i2
 )
 FREE RECORD exception_columns
 RECORD exception_columns(
   1 columns[*]
     2 table_name = vc
     2 column_name = vc
 )
 FREE RECORD parser_buffer
 RECORD parser_buffer(
   1 qual[*]
     2 line = vc
 )
 FREE RECORD ignore_seq
 RECORD ignore_seq(
   1 table_cnt = i4
   1 tables[*]
     2 table_name = vc
 )
 RECORD dguc_lkp_reply(
   1 rs_tbl_cnt = i4
   1 dguc_err_ind = i2
   1 dguc_err_msg = vc
   1 dtd_hold[*]
     2 tbl_name = vc
     2 tbl_suffix = vc
     2 pk_cnt = i4
     2 pk_hold[*]
       3 pk_datatype = vc
       3 pk_name = vc
 )
 FREE RECORD local_metadata_params
 RECORD local_metadata_params(
   1 remote_env_id = f8
   1 local_env_id = f8
   1 post_link_name = vc
 )
 FREE RECORD table_params
 RECORD table_params(
   1 tables[*]
     2 table_name = vc
     2 column_name = vc
     2 exclusion_ind = i2
 )
 FREE RECORD context_tables
 RECORD context_tables(
   1 tables[*]
     2 table_name = vc
 )
 FREE RECORD drcxf_request
 RECORD drcxf_request(
   1 source_env_id = f8
   1 target_env_id = f8
 )
 FREE RECORD drcso_request
 RECORD drcso_request(
   1 object_name = vc
   1 source_env_id = f8
 )
 FREE RECORD drcso_reply
 RECORD drcso_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE itgtenvid = f8 WITH protect, noconstant(0.0)
 DECLARE itgtenvidmock = f8 WITH protect, noconstant(0.0)
 DECLARE stgtname = vc WITH protect, noconstant
 DECLARE isrcenvid = f8 WITH protect, noconstant(0.0)
 DECLARE ilimitchglog = i2 WITH protect, noconstant(0)
 DECLARE ioutputchglog = i2 WITH protect, noconstant(0)
 DECLARE icontextauditind = i2 WITH protect, noconstant(0)
 DECLARE ssrcname = vc WITH protect, noconstant
 DECLARE iloopcnt = i4 WITH private, noconstant(0)
 DECLARE itableidx = i4 WITH protect, noconstant(0)
 DECLARE itablecnt = i4 WITH protect, noconstant(0)
 DECLARE icolumnidx = i4 WITH protect, noconstant(0)
 DECLARE sdblink = vc WITH protect, noconstant("")
 DECLARE sdblinkmock = vc WITH protect, noconstant("")
 DECLARE sseqmatchstr = vc WITH protect, noconstant("")
 DECLARE nsqllines = i2 WITH private, noconstant(4)
 DECLARE stablename = vc WITH protect, noconstant("")
 DECLARE ssequencename = vc WITH protect, noconstant("")
 DECLARE idefattind = i2 WITH protect, noconstant(0)
 DECLARE iexceptionflg = i2 WITH protect, noconstant(0)
 DECLARE ireferenceind = i2 WITH protect, noconstant(0)
 DECLARE iidx = i4 WITH private, noconstant(0)
 DECLARE iidx2 = i4 WITH private, noconstant(0)
 DECLARE inum = i4 WITH private, noconstant(0)
 DECLARE npesize = i4 WITH private, noconstant(0)
 DECLARE sparententity = vc WITH protect, noconstant("")
 DECLARE sparentattr = vc WITH protect, noconstant("")
 DECLARE itableexists = i2 WITH protect, noconstant(0)
 DECLARE sfilename = vc WITH protect, noconstant("")
 DECLARE sfilenamesummary = vc WITH protect, noconstant("")
 DECLARE sxslfilename = vc WITH protect, noconstant("")
 DECLARE dstartdate = dq8 WITH protect
 DECLARE denddate = dq8 WITH protect
 DECLARE icustomtable = i2 WITH protect, noconstant(0)
 DECLARE sfrom = vc WITH protect, noconstant("")
 DECLARE imergeable = i2 WITH protect, noconstant(0)
 DECLARE iextpos = i2 WITH protect, noconstant(0)
 DECLARE itables = i4 WITH protect, noconstant(0)
 DECLARE ssubstr = vc WITH protect, noconstant("")
 DECLARE nloopcnt = i2 WITH protect, noconstant(0)
 DECLARE sfind = vc WITH protect, noconstant("")
 DECLARE sreplace = vc WITH protect, noconstant("")
 DECLARE i = i2 WITH protect, noconstant(0)
 DECLARE imanualexclude = i2 WITH protect, noconstant(0)
 DECLARE irowlimit = i2 WITH protect, noconstant(0)
 DECLARE irownum = i4 WITH protect, noconstant(0)
 DECLARE dra_tempqual = i4 WITH protect, noconstant(0)
 DECLARE icnt = i4 WITH protect, noconstant(0)
 DECLARE ichkopenevent = i4 WITH protect, noconstant(0)
 DECLARE ichkcodeset = i4 WITH protect, noconstant(0)
 DECLARE ichkdmrefchgdml = i4 WITH protect, noconstant(0)
 DECLARE num1 = i2 WITH protect, noconstant(0)
 DECLARE itableidx2 = i2 WITH protect, noconstant(0)
 DECLARE icolumnidx2 = i2 WITH protect, noconstant(0)
 DECLARE ntbl_cnt = i2 WITH protect, noconstant(0)
 DECLARE ncol_cnt = i2 WITH protect, noconstant(0)
 DECLARE ncontext_cnt = i2 WITH protect, noconstant(0)
 DECLARE scontextlist = vc WITH protect, noconstant("")
 DECLARE ichkcontext = i4 WITH protect, noconstant(0)
 DECLARE n_null_ind = i4 WITH protect, noconstant(0)
 DECLARE s_null_str = vc WITH protect, noconstant("")
 DECLARE s_where_clause = vc WITH protect, noconstant("")
 DECLARE ivalidobjind = i2 WITH protect, noconstant(0)
 DECLARE isrctgtmapid = f8 WITH protect, noconstant(0.0)
 DECLARE ssrctgtmapid = vc WITH protect, noconstant("")
 DECLARE senvpair = vc WITH protect, noconstant("")
 IF (check_logfile("dm_rdds_audit",".log","DM_RDDS_AUDIT_LOG")=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to Create Log File"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF (drrm_check_mig(1,"") > 0)
  SET dm_err->eproc = "Checking for migration status."
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat("It has been detected that a database migration is in progress.  ",
   "There is an RDDS project strategy that allows for auditing to run during a migration, but it requires an acknowledgement ",
   "of the strategy through DM_MERGE_DOMAIN_ADM.  Please use that to start the audit.")
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_script
 ENDIF
 SET dstartdate = cnvtdatetime(curdate,curtime2)
 SET sfilename = cnvtlower(trim( $1,3))
 SET stablename = cnvtupper(trim( $2,3))
 SET isrcenvid = cnvtreal( $3)
 IF (cnvtupper(trim( $4,3))="YES")
  SET ilimitchglog = 0
 ELSEIF (cnvtupper(trim( $4,3))="NO")
  SET ilimitchglog = 1
 ELSE
  CALL echo("****************************************************************")
  CALL echo("**                                                            **")
  CALL echo("**   ERROR: Invalid change log limit option entered           **")
  CALL echo("**                                                            **")
  CALL echo("****************************************************************")
  GO TO exit_script
 ENDIF
 IF (cnvtupper(trim( $5,3))="YES")
  SET irowlimit = 1
 ELSEIF (cnvtupper(trim( $5,3))="NO")
  SET irowlimit = 0
 ELSE
  CALL echo("****************************************************************")
  CALL echo("**                                                            **")
  CALL echo("**   ERROR: Invalid sample size limit option entered          **")
  CALL echo("**                                                            **")
  CALL echo("****************************************************************")
  GO TO exit_script
 ENDIF
 IF (cnvtupper(trim( $6,3))="YES")
  SET ioutputchglog = 1
 ELSEIF (cnvtupper(trim( $6,3))="NO")
  SET ioutputchglog = 0
 ELSE
  CALL echo("****************************************************************")
  CALL echo("**                                                            **")
  CALL echo("**   ERROR: Invalid change log limit option entered           **")
  CALL echo("**                                                            **")
  CALL echo("****************************************************************")
  GO TO exit_script
 ENDIF
 IF (cnvtupper(trim( $7,3))="YES")
  SET icontextauditind = 1
 ELSEIF (cnvtupper(trim( $7,3))="NO")
  SET icontextauditind = 0
 ELSE
  CALL echo("****************************************************************")
  CALL echo("**                                                            **")
  CALL echo("**   ERROR: Invalid context_name limit option entered         **")
  CALL echo("**                                                            **")
  CALL echo("****************************************************************")
  GO TO exit_script
 ENDIF
 IF (isrcenvid=0)
  CALL echo("****************************************************************")
  CALL echo("**                                                            **")
  CALL echo("**   ERROR: Invalid source environment id entered in prompt   **")
  CALL echo("**                                                            **")
  CALL echo("****************************************************************")
  GO TO exit_script
 ENDIF
 IF (irowlimit=0
  AND findstring("\*",stablename,1,0) != 0)
  CALL echo("****************************************************************")
  CALL echo("**                                                            **")
  CALL echo("**   ERROR: Have to limit report if table has wildcard (*)    **")
  CALL echo("**                                                            **")
  CALL echo("****************************************************************")
  GO TO exit_script
 ENDIF
 IF (irowlimit=1)
  IF (findstring("\*",stablename,1,0)=0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="RDDS CONFIGURATION"
     AND di.info_name="AUDIT_REPORT_SAMPLE_SIZE"
    DETAIL
     irownum = di.info_number
    WITH nocounter
   ;end select
   SET dra_tempqual = curqual
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    GO TO exit_script
   ENDIF
   IF (dra_tempqual=0)
    SET irownum = 25
   ENDIF
  ELSE
   SET irownum = 25
  ENDIF
 ELSE
  SET irownum = 5000000
 ENDIF
 SET dm_err->eproc = "Starting dm_rdds_audit"
 SET iextpos = findstring(".",sfilename)
 IF (iextpos=0
  AND sfilename != "MINE")
  SET sfilenamesummary = concat(sfilename,"_summary.xml")
  SET sfilename = concat(sfilename,".xml")
 ELSE
  SET sfilenamesummary = concat(substring(1,(iextpos - 1),sfilename),"_summary",substring(iextpos,
    size(sfilename,1),sfilename))
 ENDIF
 SET sxslfilename = replace(sfilename,".xml",".xsl")
 SELECT INTO "NL:"
  FROM dm_info d
  WHERE d.info_name="DM_ENV_ID"
   AND d.info_domain="DATA MANAGEMENT"
  DETAIL
   itgtenvid = d.info_number
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to retrieve target environment id from dm_info!"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM dm_env_reltn der
  WHERE der.parent_env_id=isrcenvid
   AND der.child_env_id=itgtenvid
   AND der.relationship_type="REFERENCE MERGE"
  HEAD REPORT
   sdblink = der.post_link_name
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET dm_err->emsg = "Invalid source domain specified!"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF (sdblink="")
  SET sdblink = concat(concat("@MERGE",trim(cnvtstring(isrcenvid),3)),trim(cnvtstring(itgtenvid),3))
 ENDIF
 SELECT INTO "NL:"
  FROM dm_environment d
  WHERE ((d.environment_id=isrcenvid) OR (d.environment_id=itgtenvid))
  DETAIL
   IF (d.environment_id=isrcenvid)
    ssrcname = d.environment_name
   ELSE
    stgtname = d.environment_name
   ENDIF
  WITH nocounter
 ;end select
 SET itgtenvidmock = drmmi_get_mock_id(itgtenvid)
 IF (itgtenvidmock < 0.0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET sdblinkmock = concat("@MERGE",trim(cnvtstring(isrcenvid,20),3),trim(cnvtstring(itgtenvidmock,20),
   3))
 SET sseqmatchstr = concat(trim(replace(sdblinkmock,"@",""),3),"SEQMATCH")
 SET senvpair = concat(trim(cnvtstring(isrcenvid),3),"::",trim(cnvtstring(itgtenvid),3))
 IF ((dm_err->debug_flag > 1))
  CALL echo(build("sEnvPair = ",senvpair))
 ENDIF
 SET dm_err->eproc = "Obtaining Source-Target Mapping ID from DM_INFO table"
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "NL:"
  di.info_number
  FROM dm_info di
  WHERE di.info_domain="RDDS ENV PAIR"
   AND di.info_name=senvpair
  DETAIL
   isrctgtmapid = di.info_number
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SET dm_err->eproc =
  "Inserting the Source-Target Mapping ID since it did not exist in DM_INFO table"
  CALL disp_msg(" ",dm_err->logfile,0)
  SET isrctgtmapid = seq(dm_clinical_seq,nextval)
  INSERT  FROM dm_info di
   SET di.info_domain = "RDDS ENV PAIR", di.info_name = senvpair, di.info_number = isrctgtmapid,
    di.updt_applctx = reqinfo->updt_applctx, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di
    .updt_cnt = 0,
    di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
  IF (check_error("Can not load RDDS 'RDDS ENV PAIR' DM_INFO row") != 0)
   ROLLBACK
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   SET dm_err->err_ind = 1
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET ssrctgtmapid = trim(cnvtstring(isrctgtmapid,20),3)
 IF ((dm_err->debug_flag > 1))
  CALL echo(build("sSrcTgtMapId = ",ssrctgtmapid))
 ENDIF
 SET dm_err->eproc = "Refreshing the metadata"
 IF ((dm_err->debug_flag >= 1))
  CALL echo("BEGIN METADATA REFRESH")
  CALL trace(7)
 ENDIF
 EXECUTE dm2_rdds_metadata_refresh "NONE"
 IF ((dm_err->debug_flag >= 1))
  CALL echo("END METADATA REFRESH")
  CALL trace(7)
 ENDIF
 IF ((dm_err->debug_flag >= 1))
  CALL echo("BEGIN CHECK OPEN EVENT")
  CALL trace(7)
 ENDIF
 SET ichkopenevent = check_open_event(itgtenvid,0.0)
 IF ((dm_err->debug_flag >= 1))
  CALL echo("END CHECK OPEN EVENT")
  CALL trace(7)
 ENDIF
 IF ((dm_err->debug_flag >= 2))
  CALL echo("******************************************************************")
  CALL echo(build("The check_open_event subroutine returned:  ",ichkopenevent))
  CALL echo("******************************************************************")
 ENDIF
 IF (ichkopenevent=0)
  SET local_metadata_params->remote_env_id = isrcenvid
  SET local_metadata_params->local_env_id = itgtenvid
  SET drcxf_request->source_env_id = isrcenvid
  SET drcxf_request->target_env_id = itgtenvid
  IF ((dm_err->debug_flag >= 1))
   CALL echo("BEGIN LOCAL METADATA REFRESH")
   CALL trace(7)
  ENDIF
  EXECUTE dm2_refresh_local_meta_data  WITH replace(request,local_metadata_params)
  IF ((dm_err->debug_flag >= 1))
   CALL echo("END LOCAL METADATA REFRESH")
   CALL trace(7)
  ENDIF
  IF ((dm_err->debug_flag >= 1))
   CALL echo("BEGIN CREATE XLAT FUNCTIONS")
   CALL trace(7)
  ENDIF
  EXECUTE dm_rmc_create_xlat_function  WITH replace(request,drcxf_request)
  IF (check_error("Create XLAT functions") != 0)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  ENDIF
  IF ((dm_err->debug_flag >= 1))
   CALL echo("END CREATE XLAT FUNCTIONS")
   CALL trace(7)
  ENDIF
  IF ((dm_err->debug_flag >= 1))
   CALL echo("BEGIN COMPILE XLAT FUNCTIONS")
   CALL trace(7)
  ENDIF
  EXECUTE dm_rdds_compile_xlat_function
  IF (check_error("Compile XLAT functions") != 0)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  ENDIF
  IF ((dm_err->debug_flag >= 1))
   CALL echo("END COMPILE XLAT FUNCTIONS")
   CALL trace(7)
  ENDIF
  SET drcso_request->object_name = "*"
  SET drcso_request->source_env_id = isrcenvid
  IF ((dm_err->debug_flag >= 1))
   CALL echo("BEGIN CREATE SQL OBJECT")
   CALL trace(7)
  ENDIF
  EXECUTE dm_rmc_create_sql_object  WITH replace(request,drcso_request), replace(reply,drcso_reply)
  IF ((drcso_reply->status_data.status="F"))
   SET dm_err->eproc = "The creation of the custom pl/sql function has failed"
   CALL disp_msg(" ",dm_err->logfile,0)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  ELSE
   SET dm_err->eproc = "The creation of the custom pl/sql function was successful"
   CALL disp_msg(" ",dm_err->logfile,0)
  ENDIF
  IF ((dm_err->debug_flag >= 1))
   CALL echo("END CREATE SQL OBJECT")
   CALL trace(7)
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM dtable a
  WHERE a.table_name=patstring(trim(stablename,3))
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET dm_err->err_ind = 0
  SET dm_err->emsg = build(stablename," does not exist in the TARGET domain.")
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET dguc_request->local_tables_ind = 1
 IF (stablename="")
  SET dguc_request->what_tables = "*"
  SET stat = alterlist(dguc_request->req_special,11)
  SET dguc_request->req_special[1].sp_tbl = "ACCESSION"
  SET dguc_request->req_special[2].sp_tbl = "ADDRESS"
  SET dguc_request->req_special[3].sp_tbl = "PHONE"
  SET dguc_request->req_special[4].sp_tbl = "PERSON"
  SET dguc_request->req_special[5].sp_tbl = "PERSON_NAME"
  SET dguc_request->req_special[6].sp_tbl = "PERSON_ALIAS"
  SET dguc_request->req_special[7].sp_tbl = "DCP_ENTITY_RELTN"
  SET dguc_request->req_special[8].sp_tbl = "LONG_TEXT"
  SET dguc_request->req_special[9].sp_tbl = "LONG_BLOB"
  SET dguc_request->req_special[10].sp_tbl = "ACCOUNT"
  SET dguc_request->req_special[11].sp_tbl = "AT_ACCT_RELTN"
 ELSE
  SET dguc_request->what_tables = stablename
 ENDIF
 SET dguc_request->is_ref_ind = 1
 SET dguc_request->is_mrg_ind = 0
 SET dguc_request->only_special_ind = 0
 SET dguc_request->current_remote_db = 0
 SET dguc_request->db_link = ""
 SET dm_err->eproc = "Getting Unique Columns"
 IF ((dm_err->debug_flag >= 1))
  CALL echo("BEGIN GET UNIQUE COLUMNS")
  CALL trace(7)
 ENDIF
 EXECUTE dm_get_unique_columns
 IF ((dm_err->debug_flag >= 1))
  CALL echo("END GET UNIQUE COLUMNS")
  CALL trace(7)
 ENDIF
 SET itables = size(dguc_reply->dtd_hold,5)
 SET stat = create_functions(0)
 IF (stat=0)
  SET dm_err->emsg = "Failed during creation of the translation functions"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(table_info->tables,itables)
 SET dm_err->eproc = "Checking for code_set 4000220 table exclusion"
 SET ichkcodeset = 0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=4000220
   AND cv.cdf_meaning="INSERT_ONLY"
   AND cv.active_ind=1
  HEAD REPORT
   ntbl_cnt = 0
  DETAIL
   ntbl_cnt = (ntbl_cnt+ 1)
   IF (mod(ntbl_cnt,20)=1)
    stat = alterlist(table_params->tables,(ntbl_cnt+ 19))
   ENDIF
   table_params->tables[ntbl_cnt].table_name = cv.display, table_params->tables[ntbl_cnt].column_name
    = "NOCOLUMN", table_params->tables[ntbl_cnt].exclusion_ind = 3
  WITH nocounter
 ;end select
 SET stat = alterlist(table_params->tables,ntbl_cnt)
 IF (check_error(dm_err->eproc)=1)
  SET dm_err->emsg = "Check for code_set 4000220 failed"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET dm_err->err_ind = 0
 ENDIF
 SET dm_err->eproc = "Checking for Dm_Refchg_Dml table/column exclusions"
 SET ichkdmrefchgdml = 0
 SET ncol_cnt = ntbl_cnt
 SELECT DISTINCT INTO "NL:"
  drd.table_name, drd.column_name
  FROM dm_refchg_dml drd
  WHERE drd.dml_attribute IN ("INS_VAL_STR", "UPD_VAL_STR")
  DETAIL
   ncol_cnt = (ncol_cnt+ 1), stat = alterlist(table_params->tables,ncol_cnt), table_params->tables[
   ncol_cnt].table_name = drd.table_name,
   table_params->tables[ncol_cnt].column_name = drd.column_name, table_params->tables[ncol_cnt].
   exclusion_ind = 3
  WITH nocounter
 ;end select
 SET stat = alterlist(table_params->tables,ncol_cnt)
 IF (check_error(dm_err->eproc)=1)
  SET dm_err->emsg = "Check for Dm_Refchg_Dml table/column exclusions failed"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET dm_err->err_ind = 0
 ENDIF
 IF (icontextauditind=1)
  SET dm_err->eproc = "Checking for tables associated with the given context_names"
  SET ichkcontext = 0
  SELECT INTO "NL:"
   di.info_char
   FROM dm_info di
   PLAN (di
    WHERE di.info_domain="RDDS CONTEXT"
     AND di.info_name="CONTEXTS TO AUDIT")
   DETAIL
    scontextlist = di.info_char
   WITH nocounter
  ;end select
  SET s_null_str = "NULL"
  SET n_null_ind = findstring(s_null_str,scontextlist,1,0)
  IF (n_null_ind > 0)
   SET s_null_str = concat("|",trim(replace(concat("::",scontextlist,"::"),concat(":",s_null_str,":"),
      ""),3),"|")
   SET s_null_str = replace(s_null_str,"::::","::")
   SET s_null_str = replace(s_null_str,"|::","")
   SET s_null_str = replace(s_null_str,"::|","")
   SET s_null_str = replace(s_null_str,"|","")
   SET scontextlist = replace(trim(s_null_str,3),"::",'","')
   SET s_where_clause = concat("(d.context_name IN(",'"',scontextlist,'"',")",
    " OR d.context_name = NULL)")
  ELSE
   SET scontextlist = replace(trim(scontextlist,3),"::",'","')
   SET s_where_clause = concat("(d.context_name IN(",'"',scontextlist,'"',"))")
  ENDIF
  IF ((dm_err->debug_flag >= 2))
   CALL echo("******************************************************************")
   CALL echo(build("The context_names list is:  ",scontextlist))
   CALL echo("******************************************************************")
   CALL echo("******************************************************************")
   CALL echo(build("The where clause string is:  ",s_where_clause))
   CALL echo("******************************************************************")
  ENDIF
  SELECT DISTINCT INTO "NL:"
   d.table_name
   FROM (parser(concat("dm_chg_log",sdblink)) d)
   PLAN (d
    WHERE d.target_env_id=itgtenvid
     AND parser(s_where_clause))
   HEAD REPORT
    ncontext_cnt = 0, inum = 0
   DETAIL
    ncontext_cnt = (ncontext_cnt+ 1)
    IF (mod(ncontext_cnt,20)=1)
     stat = alterlist(context_tables->tables,(ncontext_cnt+ 19))
    ENDIF
    context_tables->tables[ncontext_cnt].table_name = d.table_name
   WITH nocounter
  ;end select
  SET stat = alterlist(context_tables->tables,ncontext_cnt)
  IF (check_error(dm_err->eproc)=1)
   SET dm_err->emsg = "Check for tables within the given context_names list failed"
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   SET dm_err->err_ind = 0
   GO TO exit_script
  ENDIF
  SET stat = alterlist(table_info->tables,ncontext_cnt)
 ELSE
  SET stat = alterlist(table_info->tables,itables)
 ENDIF
 SET stat = print_xml_header(sfilename,sxslfilename)
 SET stat = print_xml_header(sfilenamesummary,sxslfilename)
 FOR (i = 1 TO 255)
  SET sfind = notrim(concat(sfind,char(i)))
  IF (((i < 32
   AND i != 10
   AND i != 13) OR (i > 128)) )
   SET sreplace = notrim(concat(sreplace," "))
  ELSE
   SET sreplace = notrim(concat(sreplace,char(i)))
  ENDIF
 ENDFOR
 FOR (itablecnt = 1 TO itables)
   SET dm_err->eproc = concat("Audit process started on ",dguc_reply->dtd_hold[itablecnt].tbl_name)
   SET dm_err->emsg = concat("Table "," ",trim(cnvtstring(itablecnt),3)," of "," ",
    trim(cnvtstring(itables),3))
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   IF (icontextauditind=1)
    SET iidx = locateval(inum,1,size(context_tables->tables,5),dguc_reply->dtd_hold[itablecnt].
     tbl_name,context_tables->tables[inum].table_name)
    IF ((dm_err->debug_flag >= 3))
     CALL echo(table_info->tables[itableidx].table_name)
     CALL echo(iidx)
    ENDIF
   ENDIF
   IF (((iidx > 0) OR (icontextauditind=0)) )
    IF (iidx > 0)
     IF ((dm_err->debug_flag >= 2))
      CALL echo(
       "**************************************************************************************************************"
       )
      CALL echo(build(
        "The following table_name is listed as one of the tables associated to the given list of context names:  ",
        context_tables->tables[inum].table_name))
      CALL echo(
       "**************************************************************************************************************"
       )
     ENDIF
    ENDIF
    FREE RECORD audit_info
    RECORD audit_info(
      1 table_name = vc
      1 audit_types[*]
        2 audit_flg = i2
        2 audit_desc = vc
        2 audit_cnt = i4
        2 audit_msg = vc
        2 log_type_cnt = i4
        2 log_types[*]
          3 log_type = vc
          3 cnt = i4
        2 audit_values[*]
          3 log_type = vc
          3 context_name = vc
          3 data_values[*]
            4 column_name = vc
            4 pk_ind = i4
            4 src_column_value = vc
            4 tgt_column_value = vc
    )
    SET dm_err->eproc = "Checking for custom script"
    SET icustomtable = 0
    IF ((((dguc_reply->dtd_hold[itablecnt].tbl_name="ACCESSION_ASSIGN_POOL")) OR ((((dguc_reply->
    dtd_hold[itablecnt].tbl_name="ACCOUNT")) OR ((((dguc_reply->dtd_hold[itablecnt].tbl_name=
    "APPLICATION_TASK")) OR ((((dguc_reply->dtd_hold[itablecnt].tbl_name="CCL_LAYOUT_SECTION")) OR (
    (((dguc_reply->dtd_hold[itablecnt].tbl_name="CHART_SECTION")) OR ((((dguc_reply->dtd_hold[
    itablecnt].tbl_name="HEALTH_PLAN")) OR ((((dguc_reply->dtd_hold[itablecnt].tbl_name=
    "PATHWAY_CATALOG")) OR ((((dguc_reply->dtd_hold[itablecnt].tbl_name="SA_REF_GROUP")) OR ((((
    dguc_reply->dtd_hold[itablecnt].tbl_name="SCH_FREQ")) OR ((((dguc_reply->dtd_hold[itablecnt].
    tbl_name="SEG_GRP_SEQ_R")) OR ((((dguc_reply->dtd_hold[itablecnt].tbl_name="DCP_FORMS_REF")) OR (
    (((dguc_reply->dtd_hold[itablecnt].tbl_name="DCP_SECTION_REF")) OR ((dguc_reply->dtd_hold[
    itablecnt].tbl_name="SA_REF_ACTION"))) )) )) )) )) )) )) )) )) )) )) )) )
     SET icustomtable = 0
    ELSE
     SELECT INTO "NL:"
      FROM dm_info d
      WHERE d.info_domain="DATA MANAGEMENT"
       AND d.info_name=concat("CUTOVER SCRIPT:",dguc_reply->dtd_hold[itablecnt].tbl_name)
      DETAIL
       icustomtable = 1
      WITH nocounter
     ;end select
    ENDIF
    SELECT DISTINCT INTO "NL:"
     drso.table_name
     FROM dm_refchg_sql_obj drso
     WHERE (drso.table_name=dguc_reply->dtd_hold[itablecnt].tbl_name)
      AND drso.execution_flag IN (1, 2)
      AND drso.active_ind=1
     DETAIL
      icustomtable = 2
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->emsg = "Check for custom script failed"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
    ENDIF
    SET dm_err->eproc = "Checking for mergeable_ind"
    SET imergeable = 0
    SELECT INTO "NL:"
     FROM dm_tables_doc_local td
     WHERE (td.table_name=dguc_reply->dtd_hold[itablecnt].tbl_name)
     DETAIL
      imergeable = td.mergeable_ind
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->emsg = "Check for mergeable_ind failed"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
    ENDIF
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE cv.code_set=4001912.0
      AND cv.cdf_meaning="NORDDSTRG"
      AND cv.active_ind=1
      AND (cv.display=dguc_reply->dtd_hold[itablecnt].tbl_name)
     DETAIL
      imergeable = 0
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->emsg = "Check for table in 4001912 code_set failed"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
    ENDIF
    SET dm_err->eproc = "Checking for manual exclude in dm_info"
    SET imanualexclude = 0
    SELECT INTO "NL:"
     FROM dm_info dm
     WHERE dm.info_domain="DATA MANAGEMENT"
      AND dm.info_name=concat("RDDS_MANUAL_EXCLUDE|",dguc_reply->dtd_hold[itablecnt].tbl_name)
     DETAIL
      imanualexclude = dm.info_number
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->emsg = "Check for manual exclude failed"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
    ENDIF
    IF (imergeable != 1)
     SET dm_err->emsg = concat("Table is not flagged as mergeable.  ",dguc_reply->dtd_hold[itablecnt]
      .tbl_name," will be skipped.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ELSEIF (icustomtable=1)
     SET dm_err->emsg = concat("Tables moved by custom movers are not yet supported!  ",dguc_reply->
      dtd_hold[itablecnt].tbl_name," will be skipped.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ELSEIF (imanualexclude=1)
     SET dm_err->emsg = concat(dguc_reply->dtd_hold[itablecnt].tbl_name,
      " has been manually excluded in dm_info.  This table will be skipped.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ELSE
     SET dm_err->eproc = "Checking for the table"
     SET nsqllines = 4
     SET stat = alterlist(parser_buffer->qual,nsqllines)
     SET parser_buffer->qual[1].line = concat("select into ",'"nl:"')
     SET parser_buffer->qual[2].line = concat("from user_tables",sdblink," a")
     SET parser_buffer->qual[3].line = concat('where a.table_name = "',dguc_reply->dtd_hold[itablecnt
      ].tbl_name,'"')
     SET parser_buffer->qual[4].line = "with nocounter go"
     SET cnt = 1
     WHILE (cnt <= nsqllines)
      CALL parser(parser_buffer->qual[cnt].line)
      SET cnt = (cnt+ 1)
     ENDWHILE
     IF (check_error(dm_err->eproc)=1)
      SET dm_err->emsg = concat("Table check failed for ",dguc_reply->dtd_hold[itablecnt].tbl_name)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm_err->err_ind = 0
     ENDIF
     IF (curqual > 0)
      SET itableidx = (itableidx+ 1)
      SET table_info->tables[itableidx].table_name = dguc_reply->dtd_hold[itablecnt].tbl_name
      SET iidx = locateval(inum,1,size(table_params->tables,5),table_info->tables[itableidx].
       table_name,table_params->tables[inum].table_name)
      IF ((dm_err->debug_flag >= 2))
       CALL echo(table_info->tables[itableidx].table_name)
       CALL echo(iidx)
      ENDIF
      SET ichkcodeset = 0
      IF (iidx > 0)
       IF ((table_params->tables[iidx].column_name="NOCOLUMN"))
        IF ((table_params->tables[iidx].exclusion_ind=3))
         SET ichkcodeset = 1
         SET table_info->tables[itableidx].exclusion_flg = table_params->tables[iidx].exclusion_ind
        ENDIF
       ENDIF
      ENDIF
      IF ((dm_err->debug_flag >= 2))
       CALL echo("*********************************************************************************")
       CALL echo(build("The check for code_set 4000220 table exclusions returned:  ",ichkcodeset))
       CALL echo("*********************************************************************************")
      ENDIF
      IF ((dm_err->debug_flag >= 2))
       CALL echo("*********************************************************************************")
       CALL echo(build("The Custom Table Indicator is:  ",icustomtable))
       CALL echo("*********************************************************************************")
      ENDIF
      IF (icustomtable > 0)
       SET table_info->tables[itableidx].exclusion_flg = 1
      ENDIF
      SET dm_err->eproc = "Checking for a filter function"
      SELECT INTO "NL:"
       FROM dm_tables_doc_local dt
       WHERE (dt.table_name=table_info->tables[itableidx].table_name)
       DETAIL
        table_info->tables[itableidx].table_suffix = dt.table_suffix
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       SET dm_err->emsg = concat("Filter function check failed for  ",dguc_reply->dtd_hold[itablecnt]
        .tbl_name)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
      ENDIF
      SET dm_err->eproc = "Checking for the filter function name in the target"
      SELECT INTO "NL:"
       FROM user_objects o
       WHERE ((o.object_name=concat("REFCHG_FILTER_",table_info->tables[itableidx].table_suffix,"_1")
       ) OR (((o.object_name=concat("REFCHG_FILTER_",table_info->tables[itableidx].table_suffix,"_2")
       ) OR (((o.object_name=concat("REFCHG_PKW_",table_info->tables[itableidx].table_suffix,"_1"))
        OR (o.object_name=concat("REFCHG_PKW_",table_info->tables[itableidx].table_suffix,"_2"))) ))
       ))
       DETAIL
        IF (o.object_name="*REFCHG_PKW*")
         table_info->tables[itableidx].tgt_pkwhere_function = trim(o.object_name,3)
        ELSEIF (o.object_name="*REFCHG_FILTER*")
         table_info->tables[itableidx].tgt_filter_function = trim(o.object_name,3)
        ENDIF
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       SET dm_err->emsg = concat("Filter function name check failed for  ",dguc_reply->dtd_hold[
        itablecnt].tbl_name)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
      ENDIF
      SET dm_err->eproc = "Checking for the filter function name in the source"
      SELECT INTO "NL:"
       FROM (parser(concat("user_objects",sdblink)) o)
       WHERE ((o.object_name=concat("REFCHG_FILTER_",table_info->tables[itableidx].table_suffix,"_1")
       ) OR (((o.object_name=concat("REFCHG_FILTER_",table_info->tables[itableidx].table_suffix,"_2")
       ) OR (((o.object_name=concat("REFCHG_PKW_",table_info->tables[itableidx].table_suffix,"_1"))
        OR (o.object_name=concat("REFCHG_PKW_",table_info->tables[itableidx].table_suffix,"_2"))) ))
       ))
       DETAIL
        IF (o.object_name="*REFCHG_PKW*")
         table_info->tables[itableidx].src_pkwhere_function = trim(o.object_name,3)
        ELSEIF (o.object_name="*REFCHG_FILTER*")
         table_info->tables[itableidx].src_filter_function = trim(o.object_name,3)
        ENDIF
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       SET dm_err->emsg = concat("Filter name check failed for ",dguc_reply->dtd_hold[itablecnt].
        tbl_name)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
      ENDIF
      SET dm_err->eproc = "Checking for parameters to be passed into the filter function"
      SET cnt = 0
      SELECT INTO "NL:"
       FROM (parser(concat("dm_refchg_filter_parm",sdblink)) d)
       WHERE (d.table_name=table_info->tables[itableidx].table_name)
        AND d.active_ind=1
       ORDER BY d.parm_nbr
       DETAIL
        cnt = (cnt+ 1), table_info->tables[itableidx].src_filter_parameters = trim(concat(table_info
          ->tables[itableidx].src_filter_parameters,",::",trim(d.column_name,3),",::",trim(d
           .column_name,3)),3)
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       SET dm_err->emsg = concat("Filter function parameter check failed for  ",dguc_reply->dtd_hold[
        itablecnt].tbl_name)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
      ENDIF
      SET cnt = 0
      SELECT INTO "NL:"
       FROM dm_refchg_filter_parm d
       WHERE (d.table_name=table_info->tables[itableidx].table_name)
        AND d.active_ind=1
       ORDER BY d.parm_nbr
       DETAIL
        cnt = (cnt+ 1), table_info->tables[itableidx].tgt_filter_parameters = trim(concat(table_info
          ->tables[itableidx].tgt_filter_parameters,",::",trim(d.column_name,3),",::",trim(d
           .column_name,3)),3)
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       SET dm_err->emsg = concat("Filter function parameter check failed for  ",dguc_reply->dtd_hold[
        itablecnt].tbl_name)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
      ENDIF
      SET cnt = 0
      SET dm_err->eproc = "Checking for parameters to be passed into the pk_where function"
      SET cnt = 0
      SELECT INTO "NL:"
       FROM (parser(concat("dm_pk_where_parm",sdblink)) d)
       WHERE (d.table_name=table_info->tables[itableidx].table_name)
        AND d.function_type="PK_WHERE"
        AND d.delete_ind=0
       ORDER BY d.parm_nbr
       DETAIL
        cnt = (cnt+ 1), table_info->tables[itableidx].src_pkwhere_signature = trim(concat(table_info
          ->tables[itableidx].src_pkwhere_signature,",::",trim(d.column_name,3)," ",trim(d.data_type,
           3)),3), table_info->tables[itableidx].src_pkwhere_parameters = trim(concat(table_info->
          tables[itableidx].src_pkwhere_parameters,",::",trim(d.column_name,3)),3)
       WITH nocounter
      ;end select
      SET dm_err->eproc = "Checking for parameters to be passed into the pk_where function"
      SET cnt = 0
      SELECT INTO "NL:"
       FROM dm_pk_where_parm d
       WHERE (d.table_name=table_info->tables[itableidx].table_name)
        AND d.function_type="PK_WHERE"
        AND d.delete_ind=0
       ORDER BY d.parm_nbr
       DETAIL
        cnt = (cnt+ 1), table_info->tables[itableidx].tgt_pkwhere_signature = trim(concat(table_info
          ->tables[itableidx].tgt_pkwhere_signature,",::",trim(d.column_name,3)," ",trim(d.data_type,
           3)),3), table_info->tables[itableidx].tgt_pkwhere_parameters = trim(concat(table_info->
          tables[itableidx].tgt_pkwhere_parameters,",::",trim(d.column_name,3)),3)
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       SET dm_err->emsg = concat("PK Where function parameter check failed for  ",dguc_reply->
        dtd_hold[itablecnt].tbl_name)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
      ENDIF
      SET dm_err->eproc = "Checking for a unique list of pk_where columns between target and source"
      SET cnt = 0
      SELECT INTO "NL:"
       d.column_name, d.data_type
       FROM dm_pk_where_parm d
       WHERE (d.table_name=table_info->tables[itableidx].table_name)
        AND d.function_type="PK_WHERE"
        AND ((d.delete_ind=0) UNION (
       (SELECT
        d.column_name, d.data_type
        FROM (parser(concat("dm_pk_where_parm",sdblink)) d)
        WHERE (d.table_name=table_info->tables[itableidx].table_name)
         AND d.function_type="PK_WHERE"
         AND d.delete_ind=0
        ORDER BY d.parm_nbr)))
       DETAIL
        cnt = (cnt+ 1), table_info->tables[itableidx].cmp_pkwhere_signature = trim(concat(table_info
          ->tables[itableidx].cmp_pkwhere_signature,",::",trim(d.column_name,3)," ",trim(d.data_type,
           3)),3), table_info->tables[itableidx].cmp_pkwhere_parameters = trim(concat(table_info->
          tables[itableidx].cmp_pkwhere_parameters,",::",trim(d.column_name,3)),3)
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       SET dm_err->emsg = concat("PK Signature parameters check failed for  ",dguc_reply->dtd_hold[
        itablecnt].tbl_name)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
      ENDIF
      SET cnt = 0
      SET dm_err->eproc = "Get list of translation exceptions"
      SELECT INTO "NL:"
       FROM dm_info di
       WHERE di.info_domain=concat("RDDS TRANS COLUMN:",table_info->tables[itableidx].table_name)
       DETAIL
        cnt = (cnt+ 1), stat = alterlist(exception_columns->columns,cnt), exception_columns->columns[
        cnt].column_name = di.info_name,
        exception_columns->columns[cnt].table_name = table_info->tables[itableidx].table_name
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       SET dm_err->emsg = concat("Translation check failed for ",dguc_reply->dtd_hold[itablecnt].
        tbl_name)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
      ENDIF
      SET dm_err->eproc = "Versioning Check"
      SELECT INTO "NL:"
       FROM code_value cv
       WHERE cv.code_set=255351
        AND cv.active_ind=1
        AND (cv.display=table_info->tables[itableidx].table_name)
       DETAIL
        IF (cv.cdf_meaning IN ("ALG1", "ALG3", "ALG4"))
         table_info->tables[itableidx].version_flg = 1
        ELSEIF (cv.cdf_meaning IN ("ALG2", "ALG5"))
         table_info->tables[itableidx].version_flg = 2
        ELSE
         table_info->tables[itableidx].version_flg = 0
        ENDIF
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       SET dm_err->emsg = concat("Version check failed for ",dguc_reply->dtd_hold[itablecnt].tbl_name
        )
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
      ENDIF
      IF ((table_info->tables[itableidx].version_flg=2))
       SELECT INTO "NL:"
        FROM user_tab_columns uc
        WHERE (uc.table_name=table_info->tables[itableidx].table_name)
         AND uc.column_name IN ("BEGIN_EFFECTIVE_DT_TM", "BEGIN_EFF_DT_TM", "BEG_EFFECTIVE_DT_TM",
        "BEG_EFFECTIVE_UTC_DT_TM", "BEG_EFF_DT_TM",
        "CNTRCT_BEG_EFF_DT_TM", "PRSNL_BEG_EFF_DT_TM", "END_EFFECTIVE_DT_TM",
        "PRSNL_END_EFFECTIVE_DT_TM", "END_EFFECTIVE_UTC_DT_TM",
        "END_EFF_DT_TM", "CNTRCT_EFF_DT_TM")
        DETAIL
         IF (uc.column_name IN ("BEGIN_EFFECTIVE_DT_TM", "BEGIN_EFF_DT_TM", "BEG_EFFECTIVE_DT_TM",
         "BEG_EFFECTIVE_UTC_DT_TM", "BEG_EFF_DT_TM",
         "CNTRCT_BEG_EFF_DT_TM", "PRSNL_BEG_EFF_DT_TM"))
          table_info->tables[itableidx].beg_column_name = uc.column_name
         ELSE
          table_info->tables[itableidx].end_column_name = uc.column_name
         ENDIF
        WITH nocounter
       ;end select
      ENDIF
      SET dm_err->eproc = concat("Get all other meta data for ",table_info->tables[itableidx].
       table_name)
      SET cnt = 0
      SELECT INTO "NL:"
       FROM dtableattr a,
        dtableattrl l,
        dm_columns_doc_local dc,
        user_tab_cols uc
       PLAN (a
        WHERE (a.table_name=table_info->tables[itableidx].table_name))
        JOIN (l
        WHERE l.structtype="F"
         AND btest(l.stat,11)=0)
        JOIN (dc
        WHERE dc.table_name=a.table_name
         AND dc.column_name=l.attr_name
         AND  NOT (dc.column_name="DATA_STATUS_*")
         AND  NOT (dc.column_name="ACTIVE_STATUS_*")
         AND  NOT (dc.column_name IN ("BEGIN_EFFECTIVE_DT_TM", "BEGIN_EFF_DT_TM",
        "BEG_EFFECTIVE_DT_TM", "BEG_EFFECTIVE_UTC_DT_TM", "BEG_EFF_DT_TM",
        "CNTRCT_BEG_EFF_DT_TM", "PRSNL_BEG_EFF_DT_TM", "END_EFFECTIVE_DT_TM",
        "PRSNL_END_EFFECTIVE_DT_TM", "END_EFFECTIVE_UTC_DT_TM",
        "END_EFF_DT_TM", "CNTRCT_EFF_DT_TM", "ACTIVE_IND"))
         AND nullval(dc.exception_flg,- (1)) != 6
         AND ((trim(dc.constant_value,3) < "' '") OR (trim(dc.constant_value,3)=null)) )
        JOIN (uc
        WHERE dc.table_name=uc.table_name
         AND dc.column_name=uc.column_name
         AND uc.data_type != "CLOB"
         AND uc.data_type != "BLOB"
         AND uc.data_type != "*RAW*"
         AND uc.data_type != "LONG"
         AND uc.hidden_column="NO"
         AND uc.virtual_column="NO"
         AND  NOT ( EXISTS (
        (SELECT
         "x"
         FROM dm_info di
         WHERE di.info_domain="RDDS IGNORE COL LIST:*"
          AND sqlpassthru(" uc.column_name like di.info_name and uc.table_name like di.info_char"))))
        )
       DETAIL
        cnt = (cnt+ 1)
        IF (mod(cnt,30)=1)
         stat = alterlist(table_info->tables[itableidx].columns,(cnt+ 29))
        ENDIF
        IF (dc.column_name="UPDT_*")
         table_info->tables[itableidx].columns[cnt].no_compare_ind = 1
        ENDIF
        table_info->tables[itableidx].columns[cnt].parent_entity_col = cnvtupper(trim(dc
          .parent_entity_col,3)), table_info->tables[itableidx].columns[cnt].root_entity_name = dc
        .root_entity_name, table_info->tables[itableidx].columns[cnt].root_entity_attr = dc
        .root_entity_attr,
        table_info->tables[itableidx].columns[cnt].constant_value = dc.constant_value, table_info->
        tables[itableidx].columns[cnt].exception_flg = dc.exception_flg, table_info->tables[itableidx
        ].columns[cnt].sequence_name = dc.sequence_name,
        table_info->tables[itableidx].columns[cnt].defining_attribute_ind = dc.defining_attribute_ind,
        table_info->tables[itableidx].columns[cnt].data_type = l.type, table_info->tables[itableidx].
        columns[cnt].column_name = dc.column_name
        IF (dc.unique_ident_ind=1)
         table_info->tables[itableidx].columns[cnt].ui_ind = 1
        ENDIF
        iidx = 0, inum = 0, iidx = locateval(inum,1,dguc_reply->dtd_hold[itablecnt].pk_cnt,dc
         .column_name,dguc_reply->dtd_hold[itablecnt].pk_hold[inum].pk_name)
        IF (iidx > 0)
         table_info->tables[itableidx].columns[cnt].pk_ind = 1
        ENDIF
        iidx = 0, inum = 0
        IF (((dc.column_name="*_ID") OR (((dc.column_name="*_CD") OR (dc.column_name="CODE_VALUE"))
        ))
         AND dc.exception_flg != 1
         AND (table_info->tables[itableidx].columns[cnt].no_compare_ind != 1)
         AND l.type IN ("F", "I"))
         table_info->tables[itableidx].columns[cnt].translation_ind = 1
        ELSE
         iidx = locateval(inum,1,size(exception_columns->columns,5),dc.table_name,exception_columns->
          columns[inum].table_name,
          dc.column_name,exception_columns->columns[inum].column_name)
         IF (iidx > 0)
          table_info->tables[itableidx].columns[cnt].translation_ind = 1
         ENDIF
        ENDIF
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       SET dm_err->emsg = concat("Metadata check failed for ",dguc_reply->dtd_hold[itablecnt].
        tbl_name)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
      ENDIF
      SET stat = alterlist(table_info->tables[itableidx].columns,cnt)
      SET table_info->tables[itableidx].column_cnt = cnt
      SET cnt = 0
      SET dm_err->eproc = "Check for skip sequence match row"
      SELECT INTO "NL:"
       FROM dm_info d
       WHERE d.info_domain="RDDS SKIP SEQMATCH"
       DETAIL
        cnt = (cnt+ 1), stat = alterlist(ignore_seq->tables,cnt), ignore_seq->tables[cnt].table_name
         = d.info_name
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       SET dm_err->emsg = concat("Skip seqmatch check failed for ",dguc_reply->dtd_hold[itablecnt].
        tbl_name)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
      ENDIF
      SET ignore_seq->table_cnt = cnt
      FOR (icolumnidx = 1 TO table_info->tables[itableidx].column_cnt)
        SET iskipind = 0
        SET sfrom = concat("from user_tab_columns",sdblink," d")
        SET dm_err->eproc = "Check to see if the columnn exists in the source"
        CALL parser('select into "NL: "')
        CALL parser(sfrom)
        CALL parser("where d.table_name = table_info->tables[iTableIdx].table_name and ")
        CALL parser(
         "      d.column_name = table_info->tables[iTableIdx].columns[iColumnIdx].column_name")
        CALL parser(" with nocounter go")
        IF (curqual=0)
         SET dm_err->emsg = concat(table_info->tables[itableidx].table_name,":",table_info->tables[
          itableidx].columns[icolumnidx].column_name,
          " does not exist in the source.  The column will be ignored")
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ELSE
         IF (icustomtable=2)
          SELECT INTO "NL:"
           build(l.type,l.len), l.*, so.object_name
           FROM dtableattr a,
            dtableattrl l,
            dm_refchg_sql_obj so
           PLAN (a
            WHERE (a.table_name=table_info->tables[itableidx].table_name))
            JOIN (l
            WHERE l.structtype="F"
             AND btest(l.stat,11)=0
             AND (l.attr_name=table_info->tables[itableidx].columns[icolumnidx].column_name))
            JOIN (so
            WHERE so.table_name=a.table_name
             AND so.column_name=l.attr_name
             AND so.execution_flag IN (1, 2)
             AND so.active_ind=1)
           DETAIL
            table_info->tables[itableidx].columns[icolumnidx].custom_object_name = so.object_name,
            table_info->tables[itableidx].columns[icolumnidx].translation_ind = 1
            IF (l.type="F")
             table_info->tables[itableidx].columns[icolumnidx].ccl_data_type = "F8"
            ELSEIF (l.type="I")
             table_info->tables[itableidx].columns[icolumnidx].ccl_data_type = "I4"
            ELSEIF (l.type="Q")
             table_info->tables[itableidx].columns[icolumnidx].ccl_data_type = "DQ8"
            ELSEIF (l.type="C")
             table_info->tables[itableidx].columns[icolumnidx].ccl_data_type = build(l.type,l.len)
            ENDIF
           WITH nocounter
          ;end select
          SELECT INTO "NL:"
           FROM dm_refchg_sql_obj_parm sop
           WHERE (sop.object_name=table_info->tables[itableidx].columns[icolumnidx].
           custom_object_name)
            AND sop.active_ind=1
           ORDER BY sop.parm_nbr
           HEAD REPORT
            parm_cnt = 0
           DETAIL
            parm_cnt = (parm_cnt+ 1), stat = alterlist(table_info->tables[itableidx].columns[
             icolumnidx].parm_list,parm_cnt), table_info->tables[itableidx].columns[icolumnidx].
            parm_list[parm_cnt].column_name = sop.column_name
           WITH nocounter
          ;end select
         ENDIF
         SET ichkdmrefchgdml = 0
         SELECT INTO "NL:"
          FROM (dummyt d  WITH seq = size(table_params->tables,5))
          PLAN (d
           WHERE (table_params->tables[d.seq].table_name=table_info->tables[itableidx].table_name)
            AND (table_params->tables[d.seq].column_name=table_info->tables[itableidx].columns[
           icolumnidx].column_name)
            AND (table_params->tables[d.seq].exclusion_ind=3)
            AND (table_params->tables[d.seq].column_name != "NOCOLUMN"))
          DETAIL
           table_info->tables[itableidx].columns[icolumnidx].no_compare_ind = 1, table_info->tables[
           itableidx].columns[icolumnidx].translation_ind = 0, ichkdmrefchgdml = 1
          WITH nocounter
         ;end select
         IF ((dm_err->debug_flag >= 2))
          CALL echo(
           "*********************************************************************************")
          CALL echo(build("The check for dm_refchg_dml column exclusions returned:  ",ichkdmrefchgdml
            ))
          CALL echo(
           "*********************************************************************************")
         ENDIF
         IF ((table_info->tables[itableidx].columns[icolumnidx].parent_entity_col != ""))
          SET dm_err->eproc = "Check for the parent entity column"
          SELECT INTO "nl:"
           FROM dtableattr d,
            dtableattrl dl
           WHERE (d.table_name=table_info->tables[itableidx].table_name)
            AND (dl.attr_name=table_info->tables[itableidx].columns[icolumnidx].parent_entity_col)
           WITH nocounter
          ;end select
          IF (check_error(dm_err->eproc)=1)
           SET dm_err->emsg = concat("Column checked failed on ",dguc_reply->dtd_hold[itablecnt].
            tbl_name)
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           SET dm_err->err_ind = 0
          ENDIF
          IF (curqual=0)
           SET iskipind = 1
          ELSE
           SET stat = alterlist(parser_buffer->qual,0)
           SET cnt = 0
           SET dm_err->eproc = "Get unique list of parent entity names"
           SET stat = alterlist(parser_buffer->qual,20)
           SET parser_buffer->qual[1].line = concat("select distinct into ",'"nl:"')
           SET parser_buffer->qual[2].line = concat("result = EVALUATE_PE_NAME('",trim(table_info->
             tables[itableidx].table_name,3),"','",trim(table_info->tables[itableidx].columns[
             icolumnidx].column_name,3),"','",
            trim(table_info->tables[itableidx].columns[icolumnidx].parent_entity_col,3),"',",
            "trim(t.",table_info->tables[itableidx].columns[icolumnidx].parent_entity_col,",3)",
            "),","trim(t.",table_info->tables[itableidx].columns[icolumnidx].parent_entity_col,",3)")
           SET parser_buffer->qual[3].line = concat("from ",table_info->tables[itableidx].table_name,
            " t")
           SET parser_buffer->qual[4].line = concat("where trim(t.",table_info->tables[itableidx].
            columns[icolumnidx].parent_entity_col,",3) != NULL ","and trim(t.",table_info->tables[
            itableidx].columns[icolumnidx].parent_entity_col,
            ",3)"," > ' '")
           SET parser_buffer->qual[5].line = concat("order by ","trim(t.",table_info->tables[
            itableidx].columns[icolumnidx].parent_entity_col,",3)")
           SET parser_buffer->qual[6].line = "head report"
           SET parser_buffer->qual[7].line = "  iNum = 0"
           SET parser_buffer->qual[8].line = "  cnt = 0"
           SET parser_buffer->qual[9].line = "detail"
           SET parser_buffer->qual[10].line =
           "nPESize=size(table_info->tables[iTableIdx].columns[iColumnIdx].parent_entity_vals, 5)"
           SET parser_buffer->qual[11].line = concat("iIdx = locateval(iNum, 1, nPESize,","trim(t.",
            table_info->tables[itableidx].columns[icolumnidx].parent_entity_col,",3),",
            "table_info->tables[iTableIdx].columns[iColumnIdx].parent_entity_vals[iNum].pe_table_value)"
            )
           SET parser_buffer->qual[12].line = "if (iIdx = 0)"
           SET parser_buffer->qual[13].line = "cnt = nPESize + 1"
           SET parser_buffer->qual[14].line =
           "stat = alterlist(table_info->tables[iTableIdx].columns[iColumnIdx].parent_entity_vals,cnt)"
           SET parser_buffer->qual[15].line = concat(
            "table_info->tables[iTableIdx].columns[iColumnIdx].parent_entity_vals[cnt].pe_name = result"
            )
           SET parser_buffer->qual[16].line = concat(
            "table_info->tables[iTableIdx].columns[iColumnIdx].parent_entity_vals[cnt].pe_table_value =",
            " t.",trim(table_info->tables[itableidx].columns[icolumnidx].parent_entity_col,3))
           SET parser_buffer->qual[17].line = "endif"
           SET parser_buffer->qual[18].line = "foot report"
           SET parser_buffer->qual[19].line = "  iNum = iNum"
           SET parser_buffer->qual[20].line = "with nocounter go"
           SET stat = execute_ccl(cnt)
           IF (((check_error(dm_err->eproc)=1) OR (stat=0)) )
            SET dm_err->emsg = concat("Target parent entity and override check failed for ",
             table_info->tables[itableidx].table_name)
            CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
            SET dm_err->err_ind = 0
           ENDIF
           SET parser_buffer->qual[3].line = replace(parser_buffer->qual[3].line," t",concat(sdblink,
             " t"))
           SET stat = execute_ccl(cnt)
           IF (((check_error(dm_err->eproc)=1) OR (stat=0)) )
            SET dm_err->emsg = concat("Source parent entity and override check failed for ",
             table_info->tables[itableidx].table_name)
            CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
            SET dm_err->err_ind = 0
           ENDIF
           IF (size(table_info->tables[itableidx].columns[icolumnidx].parent_entity_vals,5)=0)
            SET table_info->tables[itableidx].columns[icolumnidx].translation_ind = 0
           ENDIF
           SET iidx = 0
           SET inum = 0
           FOR (i = 1 TO size(table_info->tables[itableidx].columns[icolumnidx].parent_entity_vals,5)
            )
             IF ((table_info->tables[itableidx].columns[icolumnidx].parent_entity_vals[i].pe_name !=
             "RDDS:MOVE AS IS"))
              SET ncolloc = 0
              SET ssubstr = ""
              SET dm_err->eproc = "Check to see if the referenced parent entity exists"
              SELECT INTO "nl:"
               FROM dtable d
               WHERE (d.table_name=table_info->tables[itableidx].columns[icolumnidx].
               parent_entity_vals[i].pe_name)
               DETAIL
                itableexists = 1
               WITH nocounter
              ;end select
              IF (check_error(dm_err->eproc)=1)
               SET dm_err->emsg = concat("Parent entity table failed for ",table_info->tables[
                itableidx].columns[icolumnidx].parent_entity_vals[i].pe_name)
               CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
               SET dm_err->err_ind = 0
              ENDIF
              SET iidx = locateval(inum,1,size(dguc_reply->dtd_hold,5),table_info->tables[itableidx].
               columns[icolumnidx].parent_entity_vals[i].pe_name,dguc_reply->dtd_hold[inum].tbl_name)
              IF (iidx=0)
               SET dguc_request->local_tables_ind = 1
               SET dguc_request->what_tables = trim(table_info->tables[itableidx].columns[icolumnidx]
                .parent_entity_vals[i].pe_name,3)
               SET dguc_request->is_ref_ind = 1
               SET dguc_request->is_mrg_ind = 0
               SET dguc_request->only_special_ind = 0
               SET dguc_request->current_remote_db = 0
               SET dguc_request->db_link = ""
               SET stat = alterlist(dguc_request->req_special,11)
               SET dguc_request->req_special[1].sp_tbl = "ACCESSION"
               SET dguc_request->req_special[2].sp_tbl = "ADDRESS"
               SET dguc_request->req_special[3].sp_tbl = "PHONE"
               SET dguc_request->req_special[4].sp_tbl = "PERSON"
               SET dguc_request->req_special[5].sp_tbl = "PERSON_NAME"
               SET dguc_request->req_special[6].sp_tbl = "PERSON_ALIAS"
               SET dguc_request->req_special[7].sp_tbl = "DCP_ENTITY_RELTN"
               SET dguc_request->req_special[8].sp_tbl = "LONG_TEXT"
               SET dguc_request->req_special[9].sp_tbl = "LONG_BLOB"
               SET dguc_request->req_special[10].sp_tbl = "ACCOUNT"
               SET dguc_request->req_special[11].sp_tbl = "AT_ACCT_RELTN"
               SET icnt = locateval(inum,1,size(dguc_request->req_special,5),dguc_request->
                what_tables,dguc_request->req_special[inum].sp_tbl)
               IF (icnt=0)
                SET ireferenceind = 0
               ELSE
                SET ireferenceind = 1
               ENDIF
               IF (ireferenceind=0)
                SELECT INTO "nl:"
                 dtd.reference_ind
                 FROM dm_tables_doc_local dtd
                 WHERE (dtd.table_name=dguc_request->what_tables)
                 DETAIL
                  IF (dtd.reference_ind=0)
                   count = (size(dguc_request->req_special,5)+ 1), stat = alterlist(dguc_request->
                    req_special,count), dguc_request->req_special[count].sp_tbl = dguc_request->
                   what_tables
                  ENDIF
                 WITH nocounter
                ;end select
               ENDIF
               SET stat = alterlist(dguc_lkp_reply->dtd_hold,0)
               IF ((dm_err->debug_flag >= 1))
                CALL echo("BEGIN SECOND GET UNIQUE COLUMNS")
                CALL trace(7)
               ENDIF
               EXECUTE dm_get_unique_columns  WITH replace("DGUC_REPLY","DGUC_LKP_REPLY")
               IF ((dm_err->debug_flag >= 1))
                CALL echo("END SECOND GET UNIQUE COLUMNS")
                CALL trace(7)
               ENDIF
               IF (size(dguc_lkp_reply->dtd_hold,5)=0)
                SET dm_err->eproc = "Resolving parent entity metadata"
                SET dm_err->emsg = concat(dguc_request->what_tables,
                 " not found by unique column lookup.  Parent entity column comparison may not be valid!"
                 )
                CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
               ELSE
                SET iidx2 = locateval(inum,1,size(dguc_lkp_reply->dtd_hold,5),table_info->tables[
                 itableidx].columns[icolumnidx].parent_entity_vals[i].pe_name,dguc_lkp_reply->
                 dtd_hold[inum].tbl_name)
                IF (iidx2=0)
                 SET dm_err->eproc = "Resolving parent entity metadata"
                 SET dm_err->emsg = concat(dguc_request->what_tables,
                  " contains an invalid number of unique columns!",
                  "  Parent entity column comparison may not be valid!")
                 CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
                ELSE
                 SET table_info->tables[itableidx].columns[icolumnidx].parent_entity_vals[i].pe_attr
                  = dguc_lkp_reply->dtd_hold[iidx2].pk_hold[1].pk_name
                ENDIF
               ENDIF
              ELSE
               SET table_info->tables[itableidx].columns[icolumnidx].parent_entity_vals[i].pe_attr =
               dguc_reply->dtd_hold[iidx].pk_hold[1].pk_name
              ENDIF
              SET stat = alterlist(parser_buffer->qual,0)
              SET cnt = 0
              SET stat = alterlist(parser_buffer->qual,10)
              SET dm_err->eproc =
              "Check for the root entity information for the parent entity column"
              SET parser_buffer->qual[1].line = concat("select into ",'"nl:"')
              SET parser_buffer->qual[2].line = "t.root_entity_name, t.root_entity_attr"
              SET parser_buffer->qual[3].line = "from dm_columns_doc_local t"
              SET parser_buffer->qual[4].line =
              "where t.table_name = table_info->tables[iTableIdx].columns[iColumnIdx].parent_entity_vals[i].pe_name and"
              SET parser_buffer->qual[5].line =
              "t.column_name = table_info->tables[iTableIdx].columns[iColumnIdx].parent_entity_vals[i].pe_attr"
              SET parser_buffer->qual[6].line = "detail"
              SET parser_buffer->qual[7].line = concat(
               "table_info->tables[iTableIdx].columns[iColumnIdx].parent_entity_vals[i].root_entity_attr ",
               "= t.root_entity_attr")
              SET parser_buffer->qual[8].line = concat(
               "table_info->tables[iTableIdx].columns[iColumnIdx].parent_entity_vals[i].root_entity_name ",
               "= t.root_entity_name")
              SET parser_buffer->qual[9].line =
              "table_info->tables[iTableIdx].columns[iColumnIdx].parent_entity_vals[i].exception_flg = t.exception_flg"
              SET parser_buffer->qual[10].line = "with nocounter go"
              SET stat = execute_ccl(cnt)
              IF (((check_error(dm_err->eproc)=1) OR (stat=0)) )
               SET dm_err->emsg = concat(
                "Failed to retrieve root entity information while processing ",table_info->tables[
                itableidx].table_name)
               CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
               SET dm_err->err_ind = 0
              ENDIF
              SET dm_err->eproc = "Get the sequence name for the parent entity value"
              SELECT INTO "NL:"
               FROM dm_columns_doc_local dc
               WHERE (dc.table_name=table_info->tables[itableidx].columns[icolumnidx].
               parent_entity_vals[i].root_entity_name)
                AND (dc.column_name=table_info->tables[itableidx].columns[icolumnidx].
               parent_entity_vals[i].root_entity_attr)
               DETAIL
                table_info->tables[itableidx].columns[icolumnidx].parent_entity_vals[i].sequence_name
                 = dc.sequence_name
               WITH nocounter
              ;end select
              IF (check_error(dm_err->eproc)=1)
               SET dm_err->emsg = concat("Failed to get sequence information while processing ",
                table_info->tables[itableidx].table_name)
               CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
               SET dm_err->err_ind = 0
              ENDIF
              IF ((table_info->tables[itableidx].columns[icolumnidx].parent_entity_vals[i].
              sequence_name > ""))
               IF (locateval(inum,1,ignore_seq->table_cnt,table_info->tables[itableidx].columns[
                icolumnidx].root_entity_name,ignore_seq->tables[inum].table_name) < 1)
                SET table_info->tables[itableidx].columns[icolumnidx].parent_entity_vals[i].
                sequence_match = get_sequence_match(table_info->tables[itableidx].columns[icolumnidx]
                 .parent_entity_vals[i].sequence_name)
               ENDIF
              ENDIF
             ENDIF
           ENDFOR
          ENDIF
         ENDIF
         IF (iskipind=0)
          SET sparententity = table_info->tables[itableidx].columns[icolumnidx].root_entity_name
          SET sparentattr = table_info->tables[itableidx].columns[icolumnidx].root_entity_attr
          SET stablename = table_info->tables[itableidx].table_name
          SET ssequencename = table_info->tables[itableidx].columns[icolumnidx].sequence_name
          SET nloopcnt = 0
          WHILE (sparententity != stablename
           AND trim(sparententity,3) != ""
           AND nloopcnt < 5)
            SET nloopcnt = (nloopcnt+ 1)
            SET dm_err->eproc = "Traverse up the hierarchy to get the top level parent"
            SELECT INTO "NL:"
             FROM dm_columns_doc_local dc
             WHERE dc.table_name=sparententity
              AND dc.column_name=sparentattr
             DETAIL
              sparententity = dc.root_entity_name, sparentattr = dc.root_entity_attr, stablename = dc
              .table_name,
              ssequencename = dc.sequence_name
             WITH nocounter
            ;end select
            IF (check_error(dm_err->eproc)=1)
             SET dm_err->emsg = concat("Failed obtaining top level parent while processing ",
              table_info->tables[itableidx].table_name)
             CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
             SET dm_err->err_ind = 0
            ENDIF
          ENDWHILE
          IF (nloopcnt=5
           AND sparententity != stablename)
           SET dm_err->emsg = concat("Failed obtaining top level parent while processing ",table_info
            ->tables[itableidx].table_name,". Number of ","levels exceeds the threshold.")
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          ENDIF
          SET table_info->tables[itableidx].columns[icolumnidx].root_entity_name = sparententity
          SET table_info->tables[itableidx].columns[icolumnidx].root_entity_attr = sparentattr
          SET table_info->tables[itableidx].columns[icolumnidx].sequence_name = ssequencename
          SET iidx = 0
          SET inum = 0
          IF ((table_info->tables[itableidx].columns[icolumnidx].sequence_name > ""))
           SET iidx = locateval(inum,1,ignore_seq->table_cnt,table_info->tables[itableidx].columns[
            icolumnidx].root_entity_name,ignore_seq->tables[inum].table_name)
           IF (iidx < 1)
            SET table_info->tables[itableidx].columns[icolumnidx].sequence_match = get_sequence_match
            (table_info->tables[itableidx].columns[icolumnidx].sequence_name)
           ENDIF
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
      IF ((dm_err->debug_flag >= 1))
       CALL echo("BEGIN CREATE TABLE FUNCTIONS")
       CALL trace(7)
      ENDIF
      CALL create_table_functions(0)
      IF ((dm_err->debug_flag >= 1))
       CALL echo("END CREATE TABLE FUNCTIONS")
       CALL trace(7)
      ENDIF
      FREE DEFINE dm_rdds_log_type_src
      FREE DEFINE dm_rdds_log_type_tgt
      FREE DEFINE dm_rdds_log_type_cmp
      CALL parser(concat("declare dm_rdds_log_type_src(",substring(2,size(replace(table_info->tables[
           itableidx].src_pkwhere_parameters,"::","in_"),1),replace(table_info->tables[itableidx].
          src_pkwhere_parameters,"::","in_")),",in_iContextInd) = c300 go"))
      CALL parser(concat("declare dm_rdds_log_type_tgt(",substring(2,size(replace(table_info->tables[
           itableidx].tgt_pkwhere_parameters,"::","in_"),1),replace(table_info->tables[itableidx].
          tgt_pkwhere_parameters,"::","in_")),",in_iContextInd) = c300 go"))
      CALL parser(concat("declare dm_rdds_log_type_cmp(",substring(2,size(replace(table_info->tables[
           itableidx].src_pkwhere_parameters,"::","in_"),1),replace(table_info->tables[itableidx].
          src_pkwhere_parameters,"::","in_")),",in_iContextInd) = c300 go"))
      SET ivalidobjind = check_sql_error("DM_RDDS_LOG_TYPE_SRC","FUNCTION")
      IF (ivalidobjind=0)
       SET dm_err->eproc = concat("DM_RDDS_LOG_TYPE_SRC",
        " function creation experienced a compile error.")
       SET dm_err->user_action =
       "This is a table level function so the function will be re-created for the next table"
       SET dm_err->err_ind = 0
       CALL disp_msg(" ",dm_err->logfile,0)
      ELSE
       SET dm_err->eproc = concat("DM_RDDS_LOG_TYPE_SRC"," function was created successfully.")
       CALL disp_msg(" ",dm_err->logfile,0)
      ENDIF
      SET ivalidobjind = check_sql_error("DM_RDDS_LOG_TYPE_TGT","FUNCTION")
      IF (ivalidobjind=0)
       SET dm_err->eproc = concat("DM_RDDS_LOG_TYPE_TGT",
        " function creation experienced a compile error.")
       SET dm_err->user_action =
       "This is a table level function so the function will be re-created for the next table"
       SET dm_err->err_ind = 0
       CALL disp_msg(" ",dm_err->logfile,0)
      ELSE
       SET dm_err->eproc = concat("DM_RDDS_LOG_TYPE_TGT"," function was created successfully.")
       CALL disp_msg(" ",dm_err->logfile,0)
      ENDIF
      SET ivalidobjind = check_sql_error("DM_RDDS_LOG_TYPE_CMP","FUNCTION")
      IF (ivalidobjind=0)
       SET dm_err->eproc = concat("DM_RDDS_LOG_TYPE_CMP",
        " function creation experienced a compile error.")
       SET dm_err->user_action =
       "This is a table level function so the function will be re-created for the next table"
       SET dm_err->err_ind = 0
       CALL disp_msg(" ",dm_err->logfile,0)
      ELSE
       SET dm_err->eproc = concat("DM_RDDS_LOG_TYPE_CMP"," function was created successfully.")
       CALL disp_msg(" ",dm_err->logfile,0)
      ENDIF
      FOR (x = 1 TO size(table_info->tables[itableidx].columns,5))
       IF ((table_info->tables[itableidx].columns[x].root_entity_name > ""))
        IF ((table_info->tables[itableidx].columns[x].no_backfill_ind != 1))
         SELECT INTO "NL:"
          FROM code_value cv
          WHERE cv.code_set=255351
           AND cv.active_ind=1
           AND cv.cdf_meaning IN ("ALG1", "ALG2", "ALG3", "ALG4", "ALG5")
           AND (cv.display=table_info->tables[itableidx].columns[x].root_entity_name)
          DETAIL
           table_info->tables[itableidx].columns[x].no_backfill_ind = 1
          WITH nocounter
         ;end select
         IF ((table_info->tables[itableidx].columns[x].no_backfill_ind != 1))
          SELECT INTO "NL:"
           FROM code_value cv
           WHERE cv.code_set=4001912
            AND cv.cdf_meaning="NORDDSTRG"
            AND (cv.display=table_info->tables[itableidx].columns[x].root_entity_name)
            AND cv.active_ind=1
           DETAIL
            table_info->tables[itableidx].columns[x].no_backfill_ind = 1
           WITH nocounter
          ;end select
         ENDIF
        ENDIF
       ENDIF
       FOR (z = 1 TO size(table_info->tables[itableidx].columns[x].parent_entity_vals,5))
         IF ((table_info->tables[itableidx].columns[x].parent_entity_vals[z].root_entity_name > ""))
          SELECT INTO "NL:"
           FROM dm_tables_doc_local td
           WHERE (td.table_name=table_info->tables[itableidx].columns[x].parent_entity_vals[z].
           root_entity_name)
           DETAIL
            table_info->tables[itableidx].columns[x].parent_entity_vals[z].no_backfill_ind = td
            .merge_delete_ind
           WITH nocounter
          ;end select
          IF ((table_info->tables[itableidx].columns[x].parent_entity_vals[z].no_backfill_ind != 1))
           SELECT INTO "NL:"
            FROM code_value cv
            WHERE cv.code_set=255351
             AND cv.active_ind=1
             AND cv.cdf_meaning IN ("ALG1", "ALG2", "ALG3", "ALG4", "ALG5")
             AND (cv.display=table_info->tables[itableidx].columns[x].parent_entity_vals[z].
            root_entity_name)
            DETAIL
             table_info->tables[itableidx].columns[x].parent_entity_vals[z].no_backfill_ind = 1
            WITH nocounter
           ;end select
           IF ((table_info->tables[itableidx].columns[x].parent_entity_vals[z].no_backfill_ind != 1))
            SELECT INTO "NL:"
             FROM code_value cv
             WHERE cv.code_set=4001912
              AND cv.cdf_meaning="NORDDSTRG"
              AND (cv.display=table_info->tables[itableidx].columns[x].parent_entity_vals[z].
             root_entity_name)
              AND cv.active_ind=1
             DETAIL
              table_info->tables[itableidx].columns[x].parent_entity_vals[z].no_backfill_ind = 1
             WITH nocounter
            ;end select
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
      ENDFOR
      CALL echo(concat("TIMER:",table_info->tables[itableidx].table_name," TABLE COMPARE STARTING ",
        format(cnvtdatetime(curdate,curtime2),"@SHORTDATETIME")))
      IF ((dm_err->debug_flag >= 1))
       CALL echo("BEGIN DM_RDDS_COMPARE_TABLE")
       CALL trace(7)
      ENDIF
      EXECUTE dm_rdds_compare_table
      IF ((dm_err->debug_flag >= 1))
       CALL echo("END DM_RDDS_COMPARE_TABLE")
       CALL trace(7)
      ENDIF
      CALL echo(concat("TIMER:",table_info->tables[itableidx].table_name," TABLE COMPARE FINISHED ",
        format(cnvtdatetime(curdate,curtime2),"@SHORTDATETIME")))
      SET stat = print_xml_body_summary(sfilenamesummary)
      SET stat = print_xml_body(sfilename)
     ELSE
      SET dm_err->err_ind = 0
      SET dm_err->emsg = build(dguc_reply->dtd_hold[itablecnt].tbl_name,
       " does not exist in the source domain.  It is being skipped")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 IF ((dm_err->debug_flag >= 2))
  CALL echorecord(table_info)
  CALL echorecord(dguc_lkp_reply)
  CALL echorecord(dguc_reply)
  CALL echorecord(table_params)
  CALL echorecord(context_tables)
 ENDIF
 SET denddate = cnvtdatetime(curdate,curtime2)
 SET stat = print_xml_footer(sfilename)
 SET stat = print_xml_footer(sfilenamesummary)
 IF ((validate(exclude_xsl,- (1))=- (1))
  AND (validate(exclude_xsl,- (2))=- (2)))
  SET stat = copy_stylesheet(sfilename,sxslfilename)
 ENDIF
 SET stat = print_screen_summary(sfilename,sfilenamesummary,sxslfilename)
 SUBROUTINE execute_ccl(dummy)
   DECLARE ncnt = i4 WITH protect, noconstant(1)
   SET nsqllines = size(parser_buffer->qual,5)
   WHILE (ncnt <= nsqllines)
    IF ((parser_buffer->qual[ncnt].line > ""))
     CALL parser(parser_buffer->qual[ncnt].line)
    ENDIF
    SET ncnt = (ncnt+ 1)
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE get_sequence_match(ssequencename)
   DECLARE nseqmatch = f8 WITH protect, noconstant(0.0)
   SET dm_err->eproc = concat("Looking up sequence match for ",ssequencename)
   SELECT INTO "NL:"
    FROM dm_info d
    WHERE d.info_domain=sseqmatchstr
     AND d.info_name=ssequencename
    DETAIL
     nseqmatch = d.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->emsg = "Failed in get_sequence_match "
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
    RETURN(- (1))
   ENDIF
   RETURN(nseqmatch)
 END ;Subroutine
 SUBROUTINE create_functions(dummy)
   DECLARE ssql = vc WITH protect, noconstant("")
   SET ssql = concat("create or replace function rdds_diff_translate_src (",char(10),
    "     root_table_name varchar2,        ",char(10),"     seq_match number,             ",
    char(10),"     iFromValue number,               ",char(10),"     iMergeDelete number,   ",char(10
     ),
    "     iDefAttInd number,     ",char(10),"     iExceptionFlg number) return number is    ",char(10
     ),"   v_to_value number;                 ",
    char(10),"   v_alt_root_table varchar2(30);        ",char(10),
    "begin                              ",char(10),
    "   if (seq_match >= iFromValue or iFromValue=0 or iExceptionFlg = 1       ",char(10),
    "     or root_table_name = 'RDDS:MOVE AS IS') then       ",char(10),
    "       return (iFromValue);           ",
    char(10),"   end if;                         ",char(10),
    "   if (root_table_name = 'PRSNL') then      ",char(10),
    "      v_alt_root_table := 'PERSON';      ",char(10),
    "   elsif (root_table_name = 'PERSON')then    ",char(10),
    "      v_alt_root_table := 'PRSNL';      ",
    char(10),"   else                          ",char(10),
    "      v_alt_root_table := root_table_name;",char(10),
    "   end if;                         ",char(10),"   begin                           ",char(10),
    "   select nvl(max(dmt.to_value),-1) into v_to_value from dm_merge_translate dmt ",
    char(10),"    where dmt.env_source_id = ",cnvtstring(isrcenvid),char(10),
    "      and dmt.env_target_id = ",
    cnvtstring(itgtenvidmock),char(10),
    "      and dmt.table_name in (v_alt_root_table, root_table_name) ",char(10),
    "      and dmt.from_value = iFromValue;",
    char(10),"    if (v_to_value > 0) then return (v_to_value); end if;",char(10),"   end;",char(10),
    "begin ",char(10),"select nvl(max(dmt.from_value),-1) into v_to_value from dm_merge_translate",
    sdblink," dmt ",
    char(10),"where dmt.env_source_id = ",cnvtstring(itgtenvidmock),"  ",char(10),
    "      and dmt.env_target_id = ",cnvtstring(isrcenvid),"  ",char(10),
    "      and dmt.table_name in (v_alt_root_table, root_table_name) ",
    char(10),"      and dmt.to_value = iFromValue; ",char(10),
    "   if (iMergeDelete = 1 and v_to_value = -1) then ",char(10),
    "      return(iFromValue);         ",char(10),
    "   elsif (iDefAttInd = 0 and v_to_value = -1) then ",char(10),"      return(0);         ",
    char(10),"   else                     ",char(10),"       return(v_to_value);                ",
    char(10),
    "   end if;                   ",char(10),"end; ",char(10),"end;")
   CALL parser(concat("rdb asis (^",ssql,"^) go"))
   SET ivalidobjind = check_sql_error("RDDS_DIFF_TRANSLATE_SRC","FUNCTION")
   IF (ivalidobjind=0)
    SET dm_err->eproc = concat("RDDS_DIFF_TRANSLATE_SRC",
     " function creation experienced a compile error.")
    SET dm_err->err_ind = 1
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(0)
   ELSE
    SET dm_err->eproc = concat("RDDS_DIFF_TRANSLATE_SRC"," function was created successfully.")
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET ssql = concat("create or replace function rdds_diff_translate_tgt(",char(10),
    "     root_table_name varchar2,        ",char(10),"     seq_match number,             ",
    char(10),"     iFromValue number,               ",char(10),"     iMergeDelete number,   ",char(10
     ),
    "     iDefAttInd number,     ",char(10),"     iExceptionFlg number) return number is    ",char(10
     ),"v_to_value number; ",
    char(10),"v_alt_root_table varchar2(30); ",char(10),"begin ",char(10),
    "if (seq_match >= iFromValue or iFromValue=0 or iExceptionFlg = 1 ",char(10),
    "     or root_table_name = 'RDDS:MOVE AS IS') then       ",char(10),"return (iFromValue); ",
    char(10),"end if; ",char(10),"if (root_table_name = 'PRSNL') then        ",char(10),
    "    v_alt_root_table := 'PERSON';         ",char(10),
    "elsif (root_table_name = 'PERSON') then    ",char(10),
    "       v_alt_root_table := 'PRSNL';      ",
    char(10),"else                             ",char(10),
    "       v_alt_root_table := root_table_name;",char(10),
    "end if;                         ",char(10),"begin ",char(10),
    "select nvl(max(dmt.from_value),-1) into v_to_value from dm_merge_translate dmt  ",
    char(10),"where dmt.env_source_id = ",cnvtstring(isrcenvid),"  ",char(10),
    "  and dmt.env_target_id = ",cnvtstring(itgtenvidmock),"  ",char(10),
    "      and dmt.table_name in (v_alt_root_table, root_table_name) ",
    char(10),"      and dmt.to_value = iFromValue; ",char(10),
    " if (v_to_value > 0) then return (v_to_value); end if; ",char(10),
    "end; ",char(10),"begin ",char(10),
    "select nvl(max(dmt.to_value),-1) into v_to_value from dm_merge_translate",
    sdblink," dmt ",char(10),"where dmt.env_source_id = ",cnvtstring(itgtenvidmock),
    "  ",char(10),"  and dmt.env_target_id = ",cnvtstring(isrcenvid),"  ",
    char(10),"      and dmt.table_name = root_table_name ",char(10),
    "      and dmt.from_value = iFromValue; ",char(10),
    "   if (iMergeDelete = 1 and v_to_value = -1) then     ",char(10),
    "      return(iFromValue);      ",char(10),"   elsif (iDefAttInd = 0 and v_to_value = -1) then ",
    char(10),"      return(0);         ",char(10),"   else                     ",char(10),
    "       return(v_to_value);         ",char(10),"   end if;                 ",char(10),"end; ",
    char(10),"end;")
   CALL parser(concat("rdb asis (^",ssql,"^) go"))
   SET ivalidobjind = check_sql_error("RDDS_DIFF_TRANSLATE_TGT","FUNCTION")
   IF (ivalidobjind=0)
    SET dm_err->eproc = concat("RDDS_DIFF_TRANSLATE_TGT",
     " function creation experienced a compile error.")
    SET dm_err->err_ind = 1
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(0)
   ELSE
    SET dm_err->eproc = concat("RDDS_DIFF_TRANSLATE_TGT"," function was created successfully.")
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE create_table_functions(dummy)
   DECLARE ssql = vc WITH protect, noconstant("")
   DECLARE ssql2 = vc WITH protect, noconstant("")
   DECLARE ssqlsrcfunction = vc WITH protect, noconstant("")
   DECLARE ssqltgtfunction = vc WITH protect, noconstant("")
   DECLARE ssqlcmpfunction = vc WITH protect, noconstant("")
   DECLARE nhashsize = i4 WITH protect, constant(1073741824)
   SET ssql = concat("rdb asis(^create or replace function ::FUNCTIONNAME(",char(10),"::PKSIG,",char(
     10),"iContextInd number ",
    char(10),") return varchar is ",char(10),"v_rtn dm_chg_log.context_name%type;",char(10),
    "v_pk_where dm_chg_log.pk_where%type;",char(10),"v_hash number;",char(10),"begin ",
    char(10),"select ::PKWHERE::DBLINK",char(10),"(::PKPARM",char(10),
    ") into v_pk_where from dual;",char(10)," select dbms_utility.get_hash_value(v_pk_where, 0,",
    cnvtstring(nhashsize),") into v_hash ",
    char(10)," from dual;",char(10)," begin ",char(10),
    " if(iContextInd = 0) then ",char(10),"   select d.log_type into v_rtn ",char(10),
    "   from dm_chg_log::DBLINK d ",
    char(10),"   where d.target_env_id = ::TGTENVID and ",char(10),"         d.table_name = '",
    table_info->tables[itableidx].table_name,
    "' and ",char(10),"         d.pk_where_value = v_hash and ",char(10),
    "         d.pk_where = v_pk_where and ",
    char(10),"         ::CONTEXT and ",char(10),"         d.log_id in ",char(10),
    "           ( select max(d1.log_id) from dm_chg_log::DBLINK d1",char(10),
    "             where d1.pk_where_value = d.pk_where_value and ",char(10),
    "                   d1.pk_where = d.pk_where and ",
    char(10),"                   d1.table_name = d.table_name and ",char(10),
    "                   d1.target_env_id = d.target_env_id ",char(10),
    "    ); ",char(10)," else ",char(10),"   select d.context_name into v_rtn ",
    char(10),"   from dm_chg_log::DBLINK d ",char(10),"   where d.target_env_id = ::TGTENVID and ",
    char(10),
    "         d.table_name = '",table_info->tables[itableidx].table_name,"' and ",char(10),
    "         d.pk_where_value = v_hash and ",
    char(10),"         d.pk_where = v_pk_where and ",char(10),"         ::CONTEXT and ",char(10),
    "         d.log_id in ",char(10),"           ( select max(d1.log_id) from dm_chg_log::DBLINK d1",
    char(10),"             where d1.pk_where_value = d.pk_where_value and ",
    char(10),"                   d1.pk_where = d.pk_where and ",char(10),
    "                   d1.table_name = d.table_name and ",char(10),
    "                   d1.target_env_id = d.target_env_id ",char(10),"    ); ",char(10)," end if; ",
    char(10)," exception when no_data_found then ",char(10),
    "   v_rtn := '**NO CHANGE LOG RECORD FOUND**';",char(10),
    " end;",char(10),"  return(v_rtn); end;",char(10),"^) go")
   SET ssql2 = concat("rdb asis(^create or replace function ::FUNCTIONNAME(",char(10),"::PKSIG,",char
    (10),"iContextInd number",
    char(10),") return varchar is ",char(10),"v_rtn dm_chg_log.context_name%type;",char(10),
    "v_pk_where_src dm_chg_log.pk_where%type;",char(10),"v_hash_src number;",char(10),
    "v_rtn_src dm_chg_log.context_name%type;",
    char(10),"v_src_id number;",char(10),"v_rtn_tgt dm_chg_log.context_name%type;",char(10),
    "v_tgt_id number;",char(10),"v_pk_where_tgt dm_chg_log.pk_where%type;",char(10),
    "v_hash_tgt number;",
    char(10),"begin ",char(10),"select ::PKWHERESRC::DBLINK",char(10),
    "(::PKPARMSRC",char(10),") into v_pk_where_src from dual;",char(10),
    " select dbms_utility.get_hash_value(v_pk_where_src, 0,",
    cnvtstring(nhashsize),") into v_hash_src ",char(10)," from dual;",char(10),
    " begin ",char(10),"  if(iContextInd = 0) then ",char(10),
    "select d.log_type, d.log_id into v_rtn_src, v_src_id ",
    char(10),"from dm_chg_log::DBLINK d ",char(10),"where d.target_env_id = ::TGTENVIDTGT and ",char(
     10),
    " d.table_name = '",table_info->tables[itableidx].table_name,"' and ",char(10),
    " d.pk_where_value = v_hash_src and ",
    char(10)," d.pk_where = v_pk_where_src and",char(10)," ::CONTEXT and ",char(10),
    " d.log_id in ",char(10)," ( select max(d1.log_id) from dm_chg_log::DBLINK d1",char(10),
    "   where d1.pk_where_value = d.pk_where_value and ",
    char(10)," d1.pk_where = d.pk_where and ",char(10)," d1.table_name = d.table_name and ",char(10),
    " d1.target_env_id = d.target_env_id",char(10)," ); ",char(10),"  else ",
    char(10),"select d.context_name, d.log_id into v_rtn_src, v_src_id ",char(10),
    "from dm_chg_log::DBLINK d ",char(10),
    "where d.target_env_id = ::TGTENVIDTGT and ",char(10)," d.table_name = '",table_info->tables[
    itableidx].table_name,"' and ",
    char(10)," d.pk_where_value = v_hash_src and ",char(10)," d.pk_where = v_pk_where_src and",char(
     10),
    " ::CONTEXT and ",char(10)," d.log_id in ",char(10),
    " ( select max(d1.log_id) from dm_chg_log::DBLINK d1",
    char(10),"   where d1.pk_where_value = d.pk_where_value and ",char(10),
    " d1.pk_where = d.pk_where and ",char(10),
    " d1.table_name = d.table_name and ",char(10)," d1.target_env_id = d.target_env_id",char(10),
    " ); ",
    char(10),"  end if; ",char(10)," exception when no_data_found then ",char(10),
    "   v_rtn := '**NO CHANGE LOG RECORD FOUND**';",char(10)," end;",char(10),"select ::PKWHERETGT",
    char(10),"(::PKPARMTGT",char(10),") into v_pk_where_tgt from dual;",char(10),
    " select dbms_utility.get_hash_value(v_pk_where_tgt, 0,",cnvtstring(nhashsize),
    ") into v_hash_tgt ",char(10)," from dual; ",
    char(10)," begin ",char(10),"  if(iContextInd = 0) then ",char(10),
    "select d.log_type, d.log_id into v_rtn_tgt, v_tgt_id ",char(10),"from dm_chg_log::DBLINK d ",
    char(10),"where d.target_env_id = ::TGTENVIDTGT and ",
    char(10)," d.table_name = '",table_info->tables[itableidx].table_name,"' and ",char(10),
    " d.pk_where_value = v_hash_tgt and ",char(10)," d.pk_where = v_pk_where_tgt and ",char(10),
    " ::CONTEXT and ",
    char(10)," d.log_id in ",char(10)," ( select max(d1.log_id) from dm_chg_log::DBLINK d1",char(10),
    "   where d1.pk_where_value = d.pk_where_value and ",char(10)," d1.pk_where = d.pk_where and ",
    char(10)," d1.table_name = d.table_name and ",
    char(10)," d1.target_env_id = d.target_env_id ",char(10)," ); ",char(10),
    "  else ",char(10),"select d.context_name, d.log_id into v_rtn_tgt, v_tgt_id ",char(10),
    "from dm_chg_log::DBLINK d ",
    char(10),"where d.target_env_id = ::TGTENVIDTGT and ",char(10)," d.table_name = '",table_info->
    tables[itableidx].table_name,
    "' and ",char(10)," d.pk_where_value = v_hash_tgt and ",char(10),
    " d.pk_where = v_pk_where_tgt and ",
    char(10)," ::CONTEXT and ",char(10)," d.log_id in ",char(10),
    " ( select max(d1.log_id) from dm_chg_log::DBLINK d1",char(10),
    "   where d1.pk_where_value = d.pk_where_value and ",char(10)," d1.pk_where = d.pk_where and ",
    char(10)," d1.table_name = d.table_name and ",char(10)," d1.target_env_id = d.target_env_id ",
    char(10),
    " ); ",char(10),"  end if; ",char(10)," exception when no_data_found then ",
    char(10),"   v_rtn_tgt := '**NO CHANGE LOG RECORD FOUND**';",char(10),"   v_tgt_id := -1;",char(
     10),
    " end;",char(10),"if (v_src_id > v_tgt_id) then ",char(10),"  v_rtn := v_rtn_src; ",
    char(10),"else ",char(10),"  v_rtn := v_rtn_tgt; ",char(10),
    "end if; ",char(10),"return(v_rtn); end;",char(10),"^) go")
   SET ssqlcmpfunction = replace(ssql2,"::DBLINK",sdblink)
   SET ssqlsrcfunction = replace(ssql,"::DBLINK",sdblink)
   SET ssqltgtfunction = replace(ssql,"::DBLINK","")
   SET ssqlsrcfunction = replace(ssqlsrcfunction,"::FUNCTIONNAME","dm_rdds_log_type_src")
   SET ssqltgtfunction = replace(ssqltgtfunction,"::FUNCTIONNAME","dm_rdds_log_type_tgt")
   IF ((table_info->tables[itableidx].tgt_pkwhere_parameters=table_info->tables[itableidx].
   src_pkwhere_parameters))
    SET ssqlcmpfunction = replace(ssqlcmpfunction,"::FUNCTIONNAME","dm_rdds_log_type_cmp")
   ELSE
    SET ssqlcmpfunction = replace(ssqlcmpfunction,"::FUNCTIONNAME","dm_rdds_log_type_src")
   ENDIF
   SET ssqlsrcfunction = replace(ssqlsrcfunction,"::TGTENVID",cnvtstring(itgtenvid))
   SET ssqltgtfunction = replace(ssqltgtfunction,"::TGTENVID",cnvtstring(isrcenvid))
   SET ssqlcmpfunction = replace(ssqlcmpfunction,"::TGTENVIDTGT",cnvtstring(itgtenvid))
   SET ssqlcmpfunction = replace(ssqlcmpfunction,"::TGTENVIDSRC",cnvtstring(isrcenvid))
   SET ssqlsrcfunction = replace(ssqlsrcfunction,"::PKWHERE",table_info->tables[itableidx].
    src_pkwhere_function)
   SET ssqltgtfunction = replace(ssqltgtfunction,"::PKWHERE",table_info->tables[itableidx].
    tgt_pkwhere_function)
   SET ssqlcmpfunction = replace(ssqlcmpfunction,"::PKWHERESRC",table_info->tables[itableidx].
    src_pkwhere_function)
   SET ssqlcmpfunction = replace(ssqlcmpfunction,"::PKWHERETGT",table_info->tables[itableidx].
    tgt_pkwhere_function)
   SET ssqlsrcfunction = replace(ssqlsrcfunction,"::PKPARM",substring(2,size(replace(table_info->
       tables[itableidx].src_pkwhere_parameters,"::","")),replace(table_info->tables[itableidx].
      src_pkwhere_parameters,"::","")))
   SET ssqltgtfunction = replace(ssqltgtfunction,"::PKPARM",substring(2,size(replace(table_info->
       tables[itableidx].tgt_pkwhere_parameters,"::","")),replace(table_info->tables[itableidx].
      tgt_pkwhere_parameters,"::","")))
   SET ssqlcmpfunction = replace(ssqlcmpfunction,"::PKPARMSRC",substring(2,size(replace(table_info->
       tables[itableidx].src_pkwhere_parameters,"::","")),replace(table_info->tables[itableidx].
      src_pkwhere_parameters,"::","")))
   SET ssqlcmpfunction = replace(ssqlcmpfunction,"::PKPARMTGT",substring(2,size(replace(table_info->
       tables[itableidx].tgt_pkwhere_parameters,"::","")),replace(table_info->tables[itableidx].
      tgt_pkwhere_parameters,"::","")))
   SET ssqlsrcfunction = replace(ssqlsrcfunction,"::PKSIG",substring(2,(size(replace(table_info->
       tables[itableidx].src_pkwhere_signature,"::",""),1) - 1),replace(table_info->tables[itableidx]
      .src_pkwhere_signature,"::","")))
   SET ssqltgtfunction = replace(ssqltgtfunction,"::PKSIG",substring(2,(size(replace(table_info->
       tables[itableidx].tgt_pkwhere_signature,"::",""),1) - 1),replace(table_info->tables[itableidx]
      .tgt_pkwhere_signature,"::","")))
   IF ((table_info->tables[itableidx].tgt_pkwhere_parameters=table_info->tables[itableidx].
   src_pkwhere_parameters))
    SET ssqlcmpfunction = replace(ssqlcmpfunction,"::PKSIG",substring(2,(size(replace(table_info->
        tables[itableidx].src_pkwhere_signature,"::",""),1) - 1),replace(table_info->tables[itableidx
       ].src_pkwhere_signature,"::","")))
    SET table_info->tables[itableidx].cmp_pkwhere_signature = table_info->tables[itableidx].
    src_pkwhere_signature
    SET table_info->tables[itableidx].cmp_pkwhere_parameters = table_info->tables[itableidx].
    src_pkwhere_parameters
   ELSE
    SET ssqlcmpfunction = replace(ssqlcmpfunction,"::PKSIG",substring(2,(size(replace(table_info->
        tables[itableidx].cmp_pkwhere_signature,"::",""),1) - 1),replace(table_info->tables[itableidx
       ].cmp_pkwhere_signature,"::","")))
   ENDIF
   IF (icontextauditind=1)
    IF (n_null_ind > 0)
     SET ssqlsrcfunction = replace(ssqlsrcfunction,"::CONTEXT",concat("(d.context_name IN(","'",
       scontextlist,"'",") OR d.context_name IS NULL)"))
     SET ssqltgtfunction = replace(ssqltgtfunction," ::CONTEXT and ","")
     SET ssqlcmpfunction = replace(ssqlcmpfunction,"::CONTEXT",concat("(d.context_name IN(","'",
       scontextlist,"'",") OR d.context_name IS NULL)"))
    ELSE
     SET scontextlist = replace(scontextlist,'","',"','")
     SET ssqlsrcfunction = replace(ssqlsrcfunction,"::CONTEXT",concat("(d.context_name IN(","'",
       scontextlist,"'","))"))
     SET ssqltgtfunction = replace(ssqltgtfunction," ::CONTEXT and ","")
     SET ssqlcmpfunction = replace(ssqlcmpfunction,"::CONTEXT",concat("(d.context_name IN(","'",
       scontextlist,"'","))"))
    ENDIF
   ELSE
    SET ssqlsrcfunction = replace(ssqlsrcfunction," ::CONTEXT and ","")
    SET ssqltgtfunction = replace(ssqltgtfunction," ::CONTEXT and ","")
    SET ssqlcmpfunction = replace(ssqlcmpfunction," ::CONTEXT and ","")
   ENDIF
   CALL parser(ssqlsrcfunction)
   CALL parser(ssqltgtfunction)
   CALL parser(ssqlcmpfunction)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE print_xml_header(sfile,sxslfile)
   DECLARE icnt = i4 WITH protect, noconstant(0)
   DECLARE iidx = i4 WITH protect, noconstant(0)
   DECLARE sauditmsg = vc WITH protect, noconstant("")
   IF (icontextauditind=1
    AND ioutputchglog=0)
    SET sauditmsg = concat(sauditmsg,
     " Audit 1 is excluded since the audit output has been limited to specific context_name(s): ",
     scontextlist)
   ELSEIF (icontextauditind=0
    AND ioutputchglog=1)
    SET sauditmsg = concat(sauditmsg,
     " Audit 1 is excluded since the audit output has been limited to valid Source change log rows.")
   ELSEIF (icontextauditind=1
    AND ioutputchglog=1)
    SET sauditmsg = concat(sauditmsg,
     " Audit 1 is excluded since the audit output has been limited to valid Source change log rows and ",
     "specific context_name(s): ",scontextlist)
   ELSE
    SET sauditmsg = concat(sauditmsg," ")
   ENDIF
   SELECT INTO value(sfile)
    FROM dummyt d
    DETAIL
     IF ((validate(exclude_xsl,- (1))=- (1))
      AND (validate(exclude_xsl,- (2))=- (2)))
      CALL print(concat('<?xml-stylesheet href="',sxslfile,'" type="text/xsl"?>')), row + 1
     ENDIF
     "<rdds_audit_data>", row + 1, "<audit_date_start>",
     dstartdate"DD-MMM-YYYY HH:MM:SS;;D", "</audit_date_start>", row + 1,
     "<source_environment_id>", isrcenvid, "</source_environment_id>",
     row + 1, "<source_environment_name>", ssrcname,
     "</source_environment_name>", row + 1, "<target_environment_id>",
     itgtenvid, "</target_environment_id>", row + 1,
     "<target_environment_name>", stgtname, "</target_environment_name>",
     row + 1, "<audit_message>", sauditmsg,
     "</audit_message>", row + 1
     IF (ilimitchglog=1)
      "<limit_change_log>**Showing partial change log information**</limit_change_log>", row + 1
     ENDIF
    WITH nocounter, maxrow = 1, maxcol = 4000,
     format = variable, formfeed = none
   ;end select
   RETURN(1)
 END ;Subroutine
 SUBROUTINE print_xml_body(sfile)
   DECLARE iidx = i4 WITH protect, noconstant(0)
   DECLARE ilogtypeidx = i4 WITH protect, noconstant(0)
   DECLARE icolidx = i4 WITH protect, noconstant(0)
   DECLARE iaudittypeidx = i4 WITH protect, noconstant(0)
   DECLARE iauditrowidx = i4 WITH protect, noconstant(0)
   DECLARE iauditcolidx = i4 WITH protect, noconstant(0)
   DECLARE scolumn = vc WITH protect, noconstant("")
   DECLARE iprintrowstag = i4 WITH protect, noconstant(0)
   DECLARE srowstart = vc WITH protect, noconstant("")
   DECLARE srowend = vc WITH protect, noconstant("")
   SET iidx = itableidx
   SELECT INTO value(sfile)
    FROM dummyt d
    DETAIL
     IF (icustomtable > 0)
      '<table_name id="', table_info->tables[iidx].table_name,
      " **** Custom logic is used for Audit Type 2 and 3 **** ",
      '">'
     ELSE
      '<table_name id="', table_info->tables[iidx].table_name, '">'
     ENDIF
     row + 1, "<primary_key_columns>"
     FOR (icolidx = 1 TO size(table_info->tables[iidx].columns,5))
       IF ((table_info->tables[iidx].columns[icolidx].pk_ind=1))
        "<column>", row + 1, "<name>",
        CALL print(table_info->tables[iidx].columns[icolidx].column_name), "</name>", row + 1
        IF ((table_info->tables[iidx].columns[icolidx].sequence_name > " "))
         "<sequence_name>", row + 1,
         CALL print(table_info->tables[iidx].columns[icolidx].sequence_name),
         row + 1, "</sequence_name>", row + 1,
         "<sequence_match>", row + 1,
         CALL print(table_info->tables[iidx].columns[icolidx].sequence_match),
         row + 1, "</sequence_match>", row + 1
        ENDIF
        IF ((table_info->tables[iidx].columns[icolidx].root_entity_name > " "))
         "<root_entity_name>", row + 1,
         CALL print(table_info->tables[iidx].columns[icolidx].root_entity_name),
         row + 1, "</root_entity_name>", "<root_entity_attr>",
         row + 1,
         CALL print(table_info->tables[iidx].columns[icolidx].root_entity_attr), row + 1,
         "</root_entity_attr>"
        ENDIF
        "</column>"
       ENDIF
     ENDFOR
     "</primary_key_columns>", row + 1, "<ui_columns>",
     icolidx = 1
     FOR (icolidx = 1 TO size(table_info->tables[iidx].columns,5))
       IF ((table_info->tables[iidx].columns[icolidx].ui_ind=1))
        "<column>", row + 1, "<name>",
        CALL print(table_info->tables[iidx].columns[icolidx].column_name), "</name>", row + 1
        IF ((table_info->tables[iidx].columns[icolidx].sequence_name > " "))
         "<sequence_name>", row + 1,
         CALL print(table_info->tables[iidx].columns[icolidx].sequence_name),
         row + 1, "</sequence_name>", row + 1,
         "<sequence_match>", row + 1,
         CALL print(table_info->tables[iidx].columns[icolidx].sequence_match),
         row + 1, "</sequence_match>", row + 1
        ENDIF
        IF ((table_info->tables[iidx].columns[icolidx].root_entity_name > " "))
         "<root_entity_name>", row + 1,
         CALL print(table_info->tables[iidx].columns[icolidx].root_entity_name),
         row + 1, "</root_entity_name>", "<root_entity_attr>",
         row + 1,
         CALL print(table_info->tables[iidx].columns[icolidx].root_entity_attr), row + 1,
         "</root_entity_attr>"
        ENDIF
        "</column>"
       ENDIF
     ENDFOR
     "</ui_columns>", "<columns>"
     FOR (icolidx = 1 TO size(table_info->tables[iidx].columns,5))
       IF ((table_info->tables[iidx].columns[icolidx].ui_ind != 1)
        AND (table_info->tables[iidx].columns[icolidx].pk_ind != 1)
        AND (((table_info->tables[iidx].columns[icolidx].sequence_name > " ")) OR ((table_info->
       tables[iidx].columns[icolidx].root_entity_name > " "))) )
        "<column>", row + 1, "<name>",
        CALL print(table_info->tables[iidx].columns[icolidx].column_name), "</name>", row + 1
        IF ((table_info->tables[iidx].columns[icolidx].sequence_name > " "))
         "<sequence_name>", row + 1,
         CALL print(table_info->tables[iidx].columns[icolidx].sequence_name),
         row + 1, "</sequence_name>", row + 1,
         "<sequence_match>", row + 1,
         CALL print(table_info->tables[iidx].columns[icolidx].sequence_match),
         row + 1, "</sequence_match>", row + 1
        ENDIF
        IF ((table_info->tables[iidx].columns[icolidx].root_entity_name > " "))
         "<root_entity_name>", row + 1,
         CALL print(table_info->tables[iidx].columns[icolidx].root_entity_name),
         row + 1, "</root_entity_name>", "<root_entity_attr>",
         row + 1,
         CALL print(table_info->tables[iidx].columns[icolidx].root_entity_attr), row + 1,
         "</root_entity_attr>"
        ENDIF
        "</column>"
       ENDIF
     ENDFOR
     "</columns>"
     FOR (iaudittypeidx = 1 TO size(audit_info->audit_types,5))
       iprintrowstag = 0,
       CALL print(concat('<audit id="',trim(cnvtstring(audit_info->audit_types[iaudittypeidx].
          audit_flg),3),'">')), row + 1,
       CALL print(concat("<audit_description>",audit_info->audit_types[iaudittypeidx].audit_desc,
        "</audit_description>")), row + 1
       IF ((audit_info->audit_types[iaudittypeidx].audit_cnt > 0))
        CALL print(concat("<row_count>",trim(cnvtstring(audit_info->audit_types[iaudittypeidx].
           audit_cnt),3),"</row_count>")), row + 1
       ELSEIF ((audit_info->audit_types[iaudittypeidx].audit_cnt=0)
        AND (audit_info->audit_types[iaudittypeidx].audit_msg <= ""))
        CALL print(concat("<row_count>","NO DIFFERENCES FOUND","</row_count>")), row + 1
       ELSE
        CALL print(concat("<row_count>",encode_html_string(audit_info->audit_types[iaudittypeidx].
          audit_msg),"</row_count>")), row + 1
       ENDIF
       IF ((audit_info->audit_types[iaudittypeidx].log_type_cnt > 0))
        CALL print("<log_types>")
        FOR (ilogtypeidx = 1 TO audit_info->audit_types[iaudittypeidx].log_type_cnt)
          row + 1,
          CALL print(concat('<log_type id="',audit_info->audit_types[iaudittypeidx].log_types[
           ilogtypeidx].log_type,'">')), row + 1,
          CALL print(concat("<log_count>",trim(cnvtstring(audit_info->audit_types[iaudittypeidx].
             log_types[ilogtypeidx].cnt),3),"</log_count>")), row + 1,
          CALL print("</log_type>")
        ENDFOR
        row + 1,
        CALL print("</log_types>")
       ENDIF
       FOR (iauditrowidx = 1 TO size(audit_info->audit_types[iaudittypeidx].audit_values,5))
         IF (iauditrowidx=1)
          iprintrowstag = 1, "<audit_rows>"
         ENDIF
         row + 1
         IF (iaudittypeidx=1)
          srowstart = "<target_row>", srowend = "</target_row>"
         ELSEIF (iaudittypeidx=2)
          srowstart = "<source_row>", srowend = "</source_row>"
         ELSE
          srowstart = "<difference_row>", srowend = "</difference_row>"
         ENDIF
         CALL print(srowstart), row + 1,
         CALL print(concat('<log_type id="',audit_info->audit_types[iaudittypeidx].audit_values[
          iauditrowidx].log_type,'">',"</log_type>"))
         IF ((audit_info->audit_types[iaudittypeidx].audit_values[iauditrowidx].context_name=""))
          CALL print(concat('<context_name id="',"NULL",'">',"</context_name>"))
         ELSE
          CALL print(concat('<context_name id="',audit_info->audit_types[iaudittypeidx].audit_values[
           iauditrowidx].context_name,'">',"</context_name>"))
         ENDIF
         row + 1
         FOR (iauditcolidx = 1 TO size(audit_info->audit_types[iaudittypeidx].audit_values[
          iauditrowidx].data_values,5))
           scolumn = audit_info->audit_types[iaudittypeidx].audit_values[iauditrowidx].data_values[
           iauditcolidx].column_name
           IF ((((audit_info->audit_types[iaudittypeidx].audit_flg=2)) OR ((audit_info->audit_types[
           iaudittypeidx].audit_flg=3)
            AND (audit_info->audit_types[iaudittypeidx].audit_values[iauditrowidx].data_values[
           iauditcolidx].pk_ind != 1))) )
            "<source_value>",
            CALL print(concat("<",scolumn,">")), row + 1,
            CALL print(trim(replace(replace(replace(replace(replace(audit_info->audit_types[
                  iaudittypeidx].audit_values[iauditrowidx].data_values[iauditcolidx].
                  src_column_value,sfind,sreplace,3),"&","&amp;"),"<","&lt;"),">","&gt;"),"%",
              "&#37;"),3)), row + 1,
            CALL print(concat("</",scolumn,">")),
            "</source_value>"
           ENDIF
           IF ((((audit_info->audit_types[iaudittypeidx].audit_flg=1)) OR ((audit_info->audit_types[
           iaudittypeidx].audit_flg=3))) )
            "<target_value>",
            CALL print(concat("<",scolumn,">")), row + 1,
            CALL print(trim(replace(replace(replace(replace(replace(audit_info->audit_types[
                  iaudittypeidx].audit_values[iauditrowidx].data_values[iauditcolidx].
                  tgt_column_value,sfind,sreplace,3),"&","&amp;"),"<","&lt;"),">","&gt;"),"%",
              "&#37;"),3)), row + 1,
            CALL print(concat("</",scolumn,">")),
            "</target_value>"
           ENDIF
         ENDFOR
         row + 1,
         CALL print(srowend)
       ENDFOR
       IF (iprintrowstag > 0)
        row + 1, "</audit_rows>"
       ENDIF
       row + 1, "</audit>"
     ENDFOR
     row + 1, "</table_name>"
    WITH nocounter, maxrow = 1, maxcol = 4000,
     format = variable, formfeed = none, append
   ;end select
   RETURN(1)
 END ;Subroutine
 SUBROUTINE print_xml_body_summary(sfile)
   DECLARE iidx = i4 WITH protect, noconstant(0)
   DECLARE iaudittypeidx = i4 WITH protect, noconstant(0)
   DECLARE ilogtypeidx = i4 WITH protect, noconstant(0)
   SET iidx = itableidx
   SELECT INTO value(sfile)
    FROM dummyt d
    DETAIL
     '<table_name id="', table_info->tables[iidx].table_name, '">',
     row + 1
     IF ((((audit_info->audit_types[1].audit_cnt > 0)) OR ((((audit_info->audit_types[2].audit_cnt >
     0)) OR ((audit_info->audit_types[3].audit_cnt > 0))) )) )
      FOR (iaudittypeidx = 1 TO size(audit_info->audit_types,5))
        IF ((audit_info->audit_types[iaudittypeidx].audit_cnt > 0))
         CALL print(concat('<audit id="',trim(cnvtstring(audit_info->audit_types[iaudittypeidx].
            audit_flg),3),'">')), row + 1,
         CALL print(concat("<audit_description>",audit_info->audit_types[iaudittypeidx].audit_desc,
          "</audit_description>")),
         row + 1,
         CALL print(concat("<row_count>",trim(cnvtstring(audit_info->audit_types[iaudittypeidx].
            audit_cnt),3),"</row_count>")), row + 1
         IF ((audit_info->audit_types[iaudittypeidx].log_type_cnt > 0))
          CALL print("<log_types>")
          FOR (ilogtypeidx = 1 TO audit_info->audit_types[iaudittypeidx].log_type_cnt)
            row + 1,
            CALL print(concat('<log_type id="',audit_info->audit_types[iaudittypeidx].log_types[
             ilogtypeidx].log_type,'">')), row + 1,
            CALL print(concat("<log_count>",trim(cnvtstring(audit_info->audit_types[iaudittypeidx].
               log_types[ilogtypeidx].cnt),3),"</log_count>")), row + 1,
            CALL print("</log_type>")
          ENDFOR
          row + 1,
          CALL print("</log_types>")
         ENDIF
         "</audit>"
        ENDIF
      ENDFOR
     ENDIF
     row + 1, "</table_name>"
    WITH nocounter, maxrow = 1, maxcol = 4000,
     format = variable, formfeed = none, append
   ;end select
   RETURN(1)
 END ;Subroutine
 SUBROUTINE print_xml_footer(sfile)
  SELECT INTO value(sfile)
   FROM dummyt d
   DETAIL
    "<audit_date_end>", denddate"DD-MMM-YYYY HH:MM:SS;;D", "</audit_date_end>",
    row + 1, "</rdds_audit_data>"
   WITH nocounter, maxrow = 1, maxcol = 4000,
    format = variable, formfeed = none, append
  ;end select
  RETURN(1)
 END ;Subroutine
 SUBROUTINE copy_stylesheet(sfile,sxslfile)
   DECLARE dclcom = vc WITH protect, noconstant("")
   DECLARE len = i4 WITH protect, noconstant(0)
   DECLARE status = i4 WITH protect, noconstant(0)
   IF (cursys="AXP")
    SET dclcom = concat("COPY CER_INSTALL:dm_rdds_audit.xsl CCLUSERDIR:",sxslfile)
    SET len = size(trim(dclcom,3))
    SET status = 0
    CALL dcl(dclcom,len,status)
    IF (status=0)
     SET dm_err->emsg = "Failed copying stylesheet "
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ENDIF
   ELSE
    SET dclcom = concat("cp $cer_install/dm_rdds_audit.xsl $CCLUSERDIR/",sxslfile)
    SET len = size(trim(dclcom,3))
    SET status = 0
    CALL dcl(dclcom,len,status)
    IF (status=0)
     SET dm_err->emsg = "Failed copying stylesheet "
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE print_screen_summary(sfile,sfilesummary,sxslfile)
   CALL echo("**************************************************************")
   CALL echo("Audit complete!")
   CALL echo("For optimal viewing, the following files need to be moved to a PC:")
   CALL echo("---------------------------")
   CALL echo(sfile)
   CALL echo(sfilesummary)
   IF ((validate(exclude_xsl,- (1))=- (1))
    AND (validate(exclude_xsl,- (2))=- (2)))
    CALL echo(sxslfile)
   ENDIF
   CALL echo("---------------------------")
   CALL echo(concat(sfile," and ",sfilesummary," should be opened to view the differences"))
   CALL echo("**************************************************************")
 END ;Subroutine
#exit_script
 FREE RECORD table_info
 FREE RECORD exception_columns
 FREE RECORD parser_buffer
 FREE RECORD ignore_seq
 FREE RECORD local_metadata_params
 FREE RECORD table_params
 FREE RECORD context_tables
END GO
