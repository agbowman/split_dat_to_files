CREATE PROGRAM dm_context_merge_adm:dba
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
 DECLARE dcma_mng_dm_chg_log_rows(null) = null
 DECLARE dcma_mng_usr_cntxt_map(null) = null
 DECLARE exp_rows_w_id_zero(null) = null
 DECLARE imprt_cntxt_frm_xprt(null) = null
 DECLARE show_dcl_row(null) = null
 DECLARE updt_lgd_rows_cntxt(null) = null
 DECLARE add_usr_cntxt_map(null) = null
 DECLARE chg_usr_cntxt_map(prsnl_id=f8) = null
 DECLARE rmv_usr_cntxt_map(null) = null
 DECLARE view_usr_cntxt_map(null) = null
 DECLARE chg_grp_cntxt_map(null) = null
 DECLARE rmv_grp_cntxt_map(null) = null
 DECLARE view_hist_cntxt_map(null) = null
 DECLARE confirm_person(person_id=f8) = vc
 DECLARE display_user_list(last_name=vc) = vc
 DECLARE display_context_list(ex_ctxt=vc) = null
 DECLARE enter_context_name(old_ctxt=vc) = vc
 DECLARE confirm_removal(person_id=f8,context_name=vc) = vc
 DECLARE confirm_addition(person_id=f8,old_context_name=vc,new_context_name=vc) = vc
 DECLARE dcma_main_cnt = i4 WITH protect, noconstant(0)
 DECLARE ctxt_exclude = vc
 IF (check_logfile("dm_context_merge_adm",".log","DM_CONTEXT_MERGE_ADM")=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to Create Log File"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Beginning DM_CONTEXT_MERGE_ADM"
 CALL disp_msg(" ",dm_err->logfile,0)
 SET logfile_name = dm_err->logfile
 FREE RECORD dcma_env
 RECORD dcma_env(
   1 env_id = f8
   1 env_name = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM dm_info a,
   dm_environment b
  PLAN (a
   WHERE a.info_name="DM_ENV_ID"
    AND a.info_domain="DATA MANAGEMENT")
   JOIN (b
   WHERE a.info_number=b.environment_id)
  DETAIL
   dcma_env->env_id = b.environment_id, dcma_env->env_name = b.environment_name
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (curqual=0)
  CALL disp_msg("Fatal Error: current environment id not found ",dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET dcma_main_cnt = 0
 WHILE (dcma_main_cnt=0)
   CALL clear(1,1)
   CALL box(1,1,7,132)
   CALL text(3,50,"USER CONTEXT MAPPING ADMINISTRATION")
   CALL text(5,75,"ENVIRONMENT ID:")
   CALL text(5,20,"ENVIRONMENT NAME:")
   CALL text(5,95,cnvtstring(dcma_env->env_id))
   CALL text(5,40,dcma_env->env_name)
   CALL text(9,3,"Please choose from the following options:")
   CALL text(11,3,"1 Manage DM_CHG_LOG Rows")
   CALL text(12,3,"2 Manage User Context Mappings")
   CALL text(13,3,"0 Exit this program")
   CALL accept(9,50,"99",0
    WHERE curaccept IN (1, 2, 0))
   CASE (curaccept)
    OF 1:
     CALL dcma_mng_dm_chg_log_rows(null)
    OF 2:
     CALL dcma_mng_usr_cntxt_map(null)
    OF 0:
     CALL clear(1,1)
     SET dcma_main_cnt = 1
   ENDCASE
 ENDWHILE
 SUBROUTINE dcma_mng_dm_chg_log_rows(null)
   SET help = off
   SET dm_err->eproc = "Manage DM_CHG_LOG Rows"
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE s_sub1_cnt = i4
   SET s_sub1_cnt = 0
   WHILE (s_sub1_cnt=0)
     CALL clear(1,1)
     CALL box(1,1,7,132)
     CALL text(3,50,"Manage DM_CHG_LOG Rows")
     CALL text(5,75,"ENVIRONMENT ID:")
     CALL text(5,20,"ENVIRONMENT NAME:")
     CALL text(5,95,cnvtstring(dcma_env->env_id))
     CALL text(5,40,dcma_env->env_name)
     CALL text(9,3,"Please choose from the following options:")
     CALL text(11,3,"1 Export rows with UPDT_ID = 0")
     CALL text(12,3,"2 Import CONTEXT_NAME changes from export")
     CALL text(13,3,"3 Show DM_CHG_LOG row")
     CALL text(14,3,"4 Update previously logged rows with CONTEXT_NAME")
     CALL text(15,3,"0 Exit")
     CALL accept(9,50,"99",0
      WHERE curaccept IN (1, 2, 3, 4, 0))
     CASE (curaccept)
      OF 1:
       CALL exp_rows_w_id_zero(null)
      OF 2:
       CALL imprt_cntxt_frm_xprt(null)
      OF 3:
       CALL show_dcl_row(null)
      OF 4:
       CALL updt_lgd_rows_cntxt(null)
      OF 0:
       CALL clear(1,1)
       SET s_sub1_cnt = 1
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE dcma_mng_usr_cntxt_map(null)
   SET help = off
   SET dm_err->eproc = "Manage User Context Mappings"
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE s_sub2_cnt = i4
   SET s_sub2_cnt = 0
   WHILE (s_sub2_cnt=0)
     CALL clear(1,1)
     CALL box(1,1,7,132)
     CALL text(3,50,"Manage User Context Mappings")
     CALL text(5,75,"ENVIRONMENT ID:")
     CALL text(5,20,"ENVIRONMENT NAME:")
     CALL text(5,95,cnvtstring(dcma_env->env_id))
     CALL text(5,40,dcma_env->env_name)
     CALL text(9,3,"Please choose from the following options:")
     CALL text(11,3,"1 View current context mapping")
     CALL text(12,3,"2 Add user-context mapping")
     CALL text(13,3,"3 Change user-context mapping")
     CALL text(14,3,"4 Remove user-context mapping")
     CALL text(15,3,"5 Change group-context mapping")
     CALL text(16,3,"6 Remove group-context mapping")
     CALL text(17,3,"7 View historical context mapping")
     CALL text(18,3,"8 Export current user-context mappings")
     CALL text(19,3,"9 Import user-context mappings")
     CALL text(20,3,"0 Exit")
     CALL accept(9,50,"99",0
      WHERE curaccept IN (1, 2, 3, 4, 5,
      6, 7, 8, 9, 0))
     CASE (curaccept)
      OF 1:
       CALL view_usr_cntxt_map(null)
      OF 2:
       CALL validate_cclseclogin(null)
       CALL add_usr_cntxt_map(null)
      OF 3:
       CALL validate_cclseclogin(null)
       CALL chg_usr_cntxt_map(0.0)
      OF 4:
       CALL validate_cclseclogin(null)
       CALL rmv_usr_cntxt_map(null)
      OF 5:
       CALL validate_cclseclogin(null)
       CALL chg_grp_cntxt_map(null)
      OF 6:
       CALL validate_cclseclogin(null)
       CALL rmv_grp_cntxt_map(null)
      OF 7:
       CALL view_hist_cntxt_map(null)
      OF 8:
       EXECUTE dm_exp_usr_cntxt_map  WITH replace("DDUCM_REQUEST","DCMA_ENV")
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_program
       ENDIF
      OF 9:
       CALL validate_cclseclogin(null)
       EXECUTE dm_imp_usr_cntxt_map  WITH replace("DDUCM_REQUEST","DCMA_ENV")
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_program
       ENDIF
      OF 0:
       CALL clear(1,1)
       SET s_sub2_cnt = 1
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE exp_rows_w_id_zero(null)
   SET help = off
   SET dm_err->eproc = "Exporting USER_ID = 0 Rows"
   CALL disp_msg(" ",dm_err->logfile,0)
   FREE RECORD erwiz_request
   RECORD erwiz_request(
     1 target_env_id = f8
     1 filename = vc
   )
   FREE RECORD erwiz_reply
   RECORD erwiz_reply(
     1 status = c1
     1 status_msg = vc
   )
   DECLARE erwiz_insert_validate_env = i2 WITH protect, noconstant(0)
   DECLARE erwiz_insert_validate_csv = i2 WITH protect, noconstant(0)
   WHILE (erwiz_insert_validate_env=0)
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,5,132)
     CALL text(3,51,"Export Rows with UPDT_ID = 0")
     CALL text(4,40,"Insert a TARGET environment id and a CSV file name")
     CALL text(7,3,"Please input a target environment id (0 to exit): ")
     CALL clear(20,1)
     CALL text(23,05,"HELP: Press <SHIFT><F5>     ")
     SET help =
     SELECT INTO "nl:"
      de.environment_id, de.environment_name
      FROM dm_environment de
      WHERE de.environment_id IN (
      (SELECT
       der.child_env_id
       FROM dm_env_reltn der
       WHERE (der.parent_env_id=dcma_env->env_id)
        AND der.relationship_type="REFERENCE MERGE"))
      ORDER BY de.environment_id
     ;end select
     CALL accept(7,70,"N(15);CU","0"
      WHERE cnvtreal(curaccept) >= 0)
     IF (curaccept="0")
      SET erwiz_insert_validate_env = 1
     ELSE
      SELECT INTO "nl:"
       FROM dm_environment de
       WHERE de.environment_id IN (
       (SELECT
        der.child_env_id
        FROM dm_env_reltn der
        WHERE (der.parent_env_id=dcma_env->env_id)
         AND der.relationship_type="REFERENCE MERGE"))
        AND (de.environment_id != dcma_env->env_id)
        AND de.environment_id=cnvtreal(curaccept)
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_program
      ENDIF
      IF (curqual > 0)
       SET erwiz_insert_validate_env = 1
       SET erwiz_insert_validate_csv = 0
       SET erwiz_request->target_env_id = cnvtreal(curaccept)
       SET help = off
       CALL clear(20,1)
       WHILE (erwiz_insert_validate_csv=0)
         CALL clear(9,1)
         CALL text(9,3,"Please input the CSV filename (0 to return):")
         CALL accept(9,50,"X(30);CU","0")
         IF (curaccept="0")
          SET erwiz_insert_validate_env = 0
          SET erwiz_insert_validate_csv = 1
         ELSE
          SET erwiz_request->filename = trim(curaccept)
          SET erwiz_insert_validate_csv = 1
          EXECUTE dm_export_dcl_0_rows  WITH replace("REQUEST","ERWIZ_REQUEST"), replace("REPLY",
           "ERWIZ_REPLY")
          IF ((erwiz_reply->status="F"))
           CALL clear(1,1)
           SET width = 132
           CALL box(1,1,7,132)
           CALL text(3,50,"Error Ocurred")
           CALL text(10,3,erwiz_reply->status_msg)
           CALL pause(5)
           CALL clear(1,1)
           SET dm_err->err_ind = 0
          ENDIF
         ENDIF
       ENDWHILE
      ELSE
       CALL clear(20,1)
       CALL text(20,3,"Invalid environment ID")
       CALL pause(3)
      ENDIF
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE imprt_cntxt_frm_xprt(null)
   SET help = off
   SET dm_err->eproc = "Importing Context from CSV file"
   CALL disp_msg(" ",dm_err->logfile,0)
   FREE RECORD icfx_request
   RECORD icfx_request(
     1 filename = vc
   )
   FREE RECORD icfx_reply
   RECORD icfx_reply(
     1 status = c1
     1 status_msg = vc
   )
   CALL clear(1,1)
   SET width = 132
   CALL box(1,1,5,132)
   CALL text(3,40,"Import CONTEXT_NAME changes from export")
   CALL text(4,20,"Insert the name of the CSV file from CCLUSERDIR that will be used for the import")
   CALL text(7,3,"Please input a CSV file name that will be used for your import (0 to exit): ")
   CALL accept(7,78,"X(30);CU","0")
   IF (curaccept != "0")
    SET icfx_request->filename = curaccept
    EXECUTE dm_import_dcl_0_rows  WITH replace("REQUEST","ICFX_REQUEST"), replace("REPLY",
     "ICFX_REPLY")
    IF ((icfx_reply->status="F"))
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,7,132)
     CALL text(3,50,"Error Ocurred")
     CALL text(10,3,icfx_reply->status_msg)
     CALL pause(5)
     CALL clear(1,1)
     SET dm_err->err_ind = 0
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE show_dcl_row(null)
   SET help = off
   SET dm_err->eproc = "Show DM_CHG_LOG Row"
   CALL disp_msg(" ",dm_err->logfile,0)
   FREE RECORD sdr_request
   RECORD sdr_request(
     1 log_id = f8
   )
   FREE RECORD sdr_reply
   RECORD sdr_reply(
     1 status = c1
     1 status_msg = vc
   )
   DECLARE sdr_insert_validate = i2 WITH protect, noconstant(0)
   SET sdr_insert_validate = 0
   SET sdr_request->log_id = 0
   WHILE (sdr_insert_validate=0)
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,5,132)
     CALL text(3,55,"Show DM_CHG_LOG Row")
     CALL text(7,3,"Please input a LOG_ID for the row that you want to be shown (0 to exit):")
     CALL accept(7,75,"9(15);CU",cnvtstring(sdr_request->log_id))
     IF (curaccept="0")
      SET sdr_insert_validate = 1
     ELSE
      SET sdr_request->log_id = cnvtreal(curaccept)
      EXECUTE dm_show_dcl_row  WITH replace("REQUEST","SDR_REQUEST"), replace("REPLY","SDR_REPLY")
      IF ((sdr_reply->status="F"))
       CALL clear(1,1)
       SET width = 132
       CALL box(1,1,7,132)
       CALL text(3,50,"Error Ocurred")
       CALL text(10,3,sdr_reply->status_msg)
       CALL pause(5)
       CALL clear(1,1)
       SET dm_err->err_ind = 0
      ENDIF
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE add_usr_cntxt_map(null)
   SET help = off
   SET dm_err->eproc = "Add user-context mapping"
   CALL disp_msg(" ",dm_err->logfile,0)
   FREE RECORD aucm_request
   RECORD aucm_request(
     1 prsnl_id = f8
     1 prsnl_nlk = vc
     1 context_name = vc
   )
   FREE RECORD aucm_search
   RECORD aucm_search(
     1 cnt = i4
     1 list[*]
       2 prsnl_id = f8
       2 prsnl_nff = vc
       2 position = vc
       2 username = vc
   )
   FREE RECORD aucm_reply
   RECORD aucm_reply(
     1 status = c1
     1 status_msg = vc
   )
   DECLARE aucm_insert_validate = i2 WITH protect, noconstant(0)
   DECLARE aucm_wildcard = i2
   DECLARE aucm_return = vc
   DECLARE aucm_find = i4
   DECLARE aucm_idx = i4
   SET aucm_insert_validate = 0
   SET aucm_wildcard = 0
   SET aucm_return = ""
   SET aucm_find = 0
   SET aucm_idx = 0
   CALL validate_cclseclogin(null)
   WHILE (aucm_insert_validate=0)
     SET aucm_search->cnt = 0
     SET stat = alterlist(aucm_search->list,0)
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,5,132)
     CALL text(3,55,"Add user-context mapping")
     CALL text(7,3,"Please enter the last name for the user for whom you want to add a context:")
     CALL text(8,3,"Please enter at least one letter.  Wild card characters are accepted.")
     CALL accept(9,3,"P(50);CU")
     IF (trim(curaccept,3)="")
      CALL text(15,3,
       "ERROR: Please enter at least the first letter of the last name for the user for whom")
      CALL text(16,3,"you want to add a context.")
      CALL text(17,3,"Press Enter to continue.")
      CALL accept(17,28,"P;E"," ")
     ELSE
      SET aucm_request->prsnl_nlk = curaccept
      SELECT INTO "nl:"
       FROM prsnl p,
        code_value c
       WHERE p.name_last_key=patstring(aucm_request->prsnl_nlk)
        AND c.code_value=p.position_cd
        AND p.active_ind=1
        AND trim(p.username) > " "
       DETAIL
        aucm_search->cnt = (aucm_search->cnt+ 1), stat = alterlist(aucm_search->list,aucm_search->cnt
         ), aucm_search->list[aucm_search->cnt].prsnl_id = p.person_id,
        aucm_search->list[aucm_search->cnt].prsnl_nff = p.name_full_formatted, aucm_search->list[
        aucm_search->cnt].position = c.display, aucm_search->list[aucm_search->cnt].username = p
        .username
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_program
      ENDIF
      IF ((aucm_search->cnt=0)
       AND findstring(char(ichar("*")),aucm_request->prsnl_nlk)=0)
       SET aucm_request->prsnl_nlk = concat(aucm_request->prsnl_nlk,"*")
       SELECT INTO "nl:"
        FROM prsnl p,
         code_value c
        WHERE p.name_last_key=patstring(aucm_request->prsnl_nlk)
         AND c.code_value=p.position_cd
         AND p.active_ind=1
         AND p.username > " "
        DETAIL
         aucm_search->cnt = (aucm_search->cnt+ 1), stat = alterlist(aucm_search->list,aucm_search->
          cnt), aucm_search->list[aucm_search->cnt].prsnl_id = p.person_id,
         aucm_search->list[aucm_search->cnt].prsnl_nff = p.name_full_formatted, aucm_search->list[
         aucm_search->cnt].position = c.display, aucm_search->list[aucm_search->cnt].username = p
         .username
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_program
       ENDIF
      ENDIF
      IF ((aucm_search->cnt > 1))
       SET aucm_return = display_user_list(aucm_request->prsnl_nlk)
       IF (aucm_return="0")
        SET aucm_insert_validate = 1
       ELSE
        SET aucm_request->prsnl_id = cnvtreal(aucm_return)
        SET aucm_find = locateval(aucm_idx,1,aucm_search->cnt,aucm_request->prsnl_id,aucm_search->
         list[aucm_idx].prsnl_id)
        SET aucm_return = confirm_person(aucm_search->list[aucm_find].prsnl_id)
        IF (aucm_return="Y")
         SET aucm_return = modify_context(aucm_request->prsnl_id)
         IF (aucm_return="Z")
          SET aucm_request->context_name = enter_context_name("")
          IF ((aucm_request->context_name="LARGER_THAN_24_CHARACTERS"))
           SET aucm_return = "X"
          ELSE
           SET aucm_return = confirm_addition(aucm_request->prsnl_id,"",aucm_request->context_name)
          ENDIF
          IF (aucm_return="Y")
           EXECUTE dm_add_user_ctxt_map  WITH replace("REQUEST","AUCM_REQUEST"), replace("REPLY",
            "AUCM_REPLY")
           IF ((aucm_reply->status="F"))
            CALL clear(1,1)
            SET width = 132
            CALL box(1,1,7,132)
            CALL text(3,50,"Error Ocurred")
            CALL text(10,3,aucm_reply->status_msg)
            CALL text(11,3,"Press Enter to continue.")
            CALL accept(11,28,"P;E"," ")
            CALL clear(1,1)
            SET dm_err->err_ind = 0
           ELSE
            CALL clear(7,1)
            CALL text(7,3,concat("The context_name ",aucm_request->context_name,
              " was successfully added to user ",aucm_search->list[aucm_find].prsnl_nff))
            CALL text(8,3,"Press Enter to continue.")
            CALL accept(8,28,"P;E"," ")
            SET aucm_insert_validate = 1
           ENDIF
          ELSEIF (aucm_return="N")
           SET aucm_insert_validate = 0
          ELSEIF (aucm_return="X")
           SET aucm_insert_validate = 1
          ENDIF
         ELSEIF (aucm_return="Y")
          SET aucm_insert_validate = 1
          CALL chg_usr_cntxt_map(aucm_request->prsnl_id)
         ELSEIF (aucm_return="N")
          SET aucm_insert_validate = 0
         ELSEIF (aucm_return="X")
          SET aucm_insert_validate = 1
         ENDIF
        ELSEIF (aucm_return="N")
         SET aucm_insert_validate = 0
        ELSEIF (aucm_return="X")
         SET aucm_insert_validate = 1
        ENDIF
       ENDIF
      ELSEIF ((aucm_search->cnt=1))
       SET aucm_return = confirm_person(cnvtreal(aucm_search->list[1].prsnl_id))
       IF (aucm_return="Y")
        SET aucm_return = modify_context(cnvtreal(aucm_search->list[1].prsnl_id))
        IF (aucm_return="Z")
         CALL clear(7,1)
         CALL text(7,3,concat("User: ",aucm_search->list[1].prsnl_nff))
         SET aucm_request->prsnl_id = aucm_search->list[1].prsnl_id
         SET aucm_request->context_name = enter_context_name("")
         IF ((aucm_request->context_name="LARGER_THAN_24_CHARACTERS"))
          SET aucm_insert_validate = 1
         ELSE
          SET aucm_return = confirm_addition(aucm_request->prsnl_id,"",aucm_request->context_name)
          IF (aucm_return="Y")
           EXECUTE dm_add_user_ctxt_map  WITH replace("REQUEST","AUCM_REQUEST"), replace("REPLY",
            "AUCM_REPLY")
           IF ((aucm_reply->status="F"))
            CALL clear(1,1)
            SET width = 132
            CALL box(1,1,7,132)
            CALL text(3,50,"Error Ocurred")
            CALL text(10,3,aucm_reply->status_msg)
            CALL text(11,3,"Press Enter to continue.")
            CALL accept(11,28,"P;E"," ")
            CALL clear(1,1)
            SET dm_err->err_ind = 0
            SET aucm_insert_validate = 1
           ELSE
            CALL clear(7,1)
            CALL text(7,3,concat("The context_name ",aucm_request->context_name,
              " was successfully added to user ",aucm_search->list[1].prsnl_nff))
            CALL text(8,3,"Press Enter to continue.")
            CALL accept(8,28,"P;E"," ")
            SET aucm_insert_validate = 1
           ENDIF
          ELSEIF (aucm_return="N")
           SET aucm_insert_validate = 0
          ELSEIF (aucm_return="X")
           SET aucm_insert_validte = 1
          ENDIF
         ENDIF
        ELSEIF (aucm_return="Y")
         SET aucm_insert_validate = 1
         CALL chg_usr_cntxt_map(cnvtreal(aucm_search->list[1].prsnl_id))
        ELSEIF (aucm_return="N")
         SET aucm_insert_validate = 0
        ELSEIF (aucm_return="X")
         SET aucm_insert_validate = 1
        ENDIF
       ELSEIF (aucm_return="N")
        SET aucm_insert_validate = 0
       ELSEIF (aucm_return="X")
        SET aucm_insert_validate = 1
       ENDIF
      ELSE
       CALL clear(20,1)
       CALL text(20,3,concat("The last name ",aucm_request->prsnl_nlk,
         " is not a valid millennium account."))
       CALL text(21,3,"Press Enter to continue.")
       CALL accept(21,28,"P;E"," ")
       CALL clear(20,1)
      ENDIF
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE view_usr_cntxt_map(null)
   SET dm_err->eproc = "View current context mapping"
   CALL disp_msg(" ",dm_err->logfile,0)
   SET message = nowindow
   CALL clear(1,1)
   SET width = 132
   CALL box(1,1,5,132)
   CALL text(3,55,"View current context mapping")
   CALL text(7,3,"View current context mapping by [C]ontext or [U]ser: ")
   CALL accept(7,56,"P(1);CU","C"
    WHERE curaccept IN ("U", "C"))
   IF (curaccept="C")
    CALL text(9,3,"Generating report...")
    SELECT INTO "NL:"
     FROM dm_refchg_prsnl_ctx_r dr
     WHERE dr.active_ind=1
      AND cnvtdatetime(curdate,curtime3) BETWEEN dr.beg_effective_dt_tm AND dr.end_effective_dt_tm
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    CALL clear(9,3)
    CALL text(9,3,"Generating report...")
    IF (curqual > 0)
     SELECT INTO mine
      context_name = substring(1,24,dr.context_name), name_full_formatted = substring(1,50,p
       .name_full_formatted), position = trim(cv.display),
      username = substring(1,25,p.username), env_id = cnvtstring(dcma_env->env_id), env_name =
      dcma_env->env_name,
      generated = format(cnvtdatetime(curdate,curtime3),";;Q")
      FROM prsnl p,
       dm_refchg_prsnl_ctx_r dr,
       code_value cv
      WHERE dr.prsnl_id=p.person_id
       AND dr.active_ind=1
       AND p.active_ind=1
       AND cnvtdatetime(curdate,curtime3) BETWEEN p.beg_effective_dt_tm AND p.end_effective_dt_tm
       AND cnvtdatetime(curdate,curtime3) BETWEEN dr.beg_effective_dt_tm AND dr.end_effective_dt_tm
       AND p.position_cd=cv.code_value
      ORDER BY context_name, username
      HEAD REPORT
       col 0, "", row + 1,
       col 30, "View Current Context-Mapping by CONTEXT_NAME", row + 2,
       col 30, "Generated on ", generated,
       row + 1, col 20, "Environment Name: ",
       env_name, col 60, "Environment ID: ",
       env_id, row + 2
      HEAD context_name
       col 0, "CONTEXT NAME: ", col 14,
       context_name, row + 1, col 2,
       "USERNAME", col 28, "POSITION",
       col 68, "NAME", row + 1
      DETAIL
       col 2, username, col 28,
       position, col 68, name_full_formatted,
       row + 1
      FOOT  context_name
       row + 2
      WITH nocounter, formfeed = none, maxrow = 1
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
    ELSE
     CALL clear(9,3)
     CALL text(9,3,"No active context mappings were found")
     CALL text(10,3,"Press Enter to continue.")
     CALL accept(10,28,"P;E"," ")
    ENDIF
   ELSEIF (curaccept="U")
    CALL text(9,3,"Generating report...")
    SELECT INTO "NL:"
     FROM dm_refchg_prsnl_ctx_r dr
     WHERE dr.active_ind=1
      AND cnvtdatetime(curdate,curtime3) BETWEEN dr.beg_effective_dt_tm AND dr.end_effective_dt_tm
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    CALL clear(9,3)
    CALL text(9,3,"Generating report...")
    IF (curqual > 0)
     SELECT INTO mine
      context_name = substring(1,24,dr.context_name), name_full_formatted = substring(1,50,p
       .name_full_formatted), position = cv.display,
      username = substring(1,25,p.username), env_id = cnvtstring(dcma_env->env_id), env_name =
      dcma_env->env_name,
      generated = format(cnvtdatetime(curdate,curtime3),";;Q")
      FROM prsnl p,
       dm_refchg_prsnl_ctx_r dr,
       code_value cv
      WHERE dr.prsnl_id=p.person_id
       AND dr.active_ind=1
       AND p.active_ind=1
       AND cnvtdatetime(curdate,curtime3) BETWEEN p.beg_effective_dt_tm AND p.end_effective_dt_tm
       AND cnvtdatetime(curdate,curtime3) BETWEEN dr.beg_effective_dt_tm AND dr.end_effective_dt_tm
       AND p.position_cd=cv.code_value
      ORDER BY username
      HEAD REPORT
       col 0, "", row + 1,
       col 30, "View Current Context-Mapping by USER", row + 2,
       col 30, "Generated on ", generated,
       row + 1, col 20, "Environment Name: ",
       env_name, col 60, "Environment ID: ",
       env_id, row + 2, col 0,
       "USERNAME", col 26, "CONTEXT",
       col 75, "POSITION", col 116,
       "NAME", row + 1
      DETAIL
       col 0, username, col 26,
       context_name, col 75, position,
       col 116, name_full_formatted, row + 1
      WITH nocounter, maxcol = 175, formfeed = none,
       maxrow = 1
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
    ELSE
     CALL clear(9,3)
     CALL text(9,3,"No active context mappings were found")
     CALL text(10,3,"Press Enter to continue.")
     CALL accept(10,28,"P;E"," ")
    ENDIF
   ENDIF
   SET message = window
 END ;Subroutine
 SUBROUTINE rmv_usr_cntxt_map(null)
   SET dm_err->eproc = "Remove user-context mapping"
   CALL disp_msg(" ",dm_err->logfile,0)
   SET help = off
   FREE RECORD rucm_request
   RECORD rucm_request(
     1 prsnl_id = f8
     1 list[*]
       2 prsnl_id = f8
     1 user_input = vc
     1 context_name = vc
     1 nff = vc
   )
   FREE RECORD rucm_reply
   RECORD rucm_reply(
     1 status = c1
     1 status_msg = vc
   )
   DECLARE rucm_insert_validate = i2 WITH protect, noconstant(0)
   DECLARE rucm_list = i4
   DECLARE rucm_i = i4
   SET rucm_insert_validate = 0
   SET rucm_list = 0
   SET stat = alterlist(rucm_request->list,rucm_list)
   SET rucm_i = 0
   CALL validate_cclseclogin(null)
   CALL clear(1,1)
   SET width = 132
   CALL box(1,1,5,132)
   CALL text(3,55,"Remove user-context mapping")
   SELECT INTO "NL:"
    FROM dm_refchg_prsnl_ctx_r pcr
    WHERE pcr.active_ind=1
     AND cnvtdatetime(curdate,curtime3) BETWEEN pcr.beg_effective_dt_tm AND pcr.end_effective_dt_tm
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (curqual=0)
    CALL text(7,3,"There are no active user-context mappings to remove.")
    CALL text(8,3,"Press Enter to continue.")
    CALL accept(8,28,"P;E"," ")
    SET rucm_insert_validate = 1
   ENDIF
   WHILE (rucm_insert_validate=0)
    SET rucm_request->user_input = display_user_list("")
    IF ((rucm_request->user_input="0"))
     SET rucm_insert_validate = 1
    ELSEIF (isnumeric(rucm_request->user_input)=0)
     CALL clear(20,1)
     CALL text(20,3,"Error: Please choose a user from the list.")
     CALL pause(3)
    ELSE
     SET rucm_request->prsnl_id = cnvtreal(rucm_request->user_input)
     SELECT INTO "NL:"
      FROM dm_refchg_prsnl_ctx_r dr,
       prsnl p
      WHERE (dr.prsnl_id=rucm_request->prsnl_id)
       AND dr.active_ind=1
       AND cnvtdatetime(curdate,curtime3) BETWEEN dr.beg_effective_dt_tm AND dr.end_effective_dt_tm
       AND dr.prsnl_id=p.person_id
      DETAIL
       rucm_request->context_name = dr.context_name, rucm_request->nff = p.name_full_formatted
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
     SET rucm_request->user_input = confirm_removal(rucm_request->prsnl_id,rucm_request->context_name
      )
     IF ((rucm_request->user_input="X"))
      SET rucm_insert_validate = 1
     ELSEIF ((rucm_request->user_input="N"))
      SET rucm_insert_validate = 0
     ELSEIF ((rucm_request->user_input="Y"))
      EXECUTE dm_del_user_ctxt_map  WITH replace("REQUEST","RUCM_REQUEST"), replace("REPLY",
       "RUCM_REPLY")
      IF ((rucm_reply->status="F"))
       CALL clear(1,1)
       SET width = 132
       CALL box(1,1,7,132)
       CALL text(3,50,"Error Ocurred")
       CALL text(10,3,rucm_reply->status_msg)
       CALL pause(5)
       CALL clear(1,1)
       SET dm_err->err_ind = 0
      ELSE
       SELECT INTO "NL:"
        FROM dm_refchg_prsnl_ctx_r dr
        WHERE (dr.context_name=rucm_request->context_name)
         AND dr.active_ind=1
         AND cnvtdatetime(curdate,curtime3) BETWEEN dr.beg_effective_dt_tm AND dr.end_effective_dt_tm
         AND (dr.prsnl_id != rucm_request->prsnl_id)
        DETAIL
         rucm_list = (rucm_list+ 1), stat = alterlist(rucm_request->list,rucm_list), rucm_request->
         list[rucm_list].prsnl_id = dr.prsnl_id
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_program
       ENDIF
       IF (rucm_list > 0)
        CALL clear(7,1)
        CALL text(7,3,concat("User, ",rucm_request->nff," was unmapped from context ",trim(
           rucm_request->context_name,3)))
        CALL text(8,3,concat(trim(cnvtstring(rucm_list),3),
          " other user(s) are also mapped to the context name ",trim(rucm_request->context_name,3)))
        CALL text(9,3,"Do you want to remove the context mappings for them as well? [Y]es or [N]o:")
        CALL accept(9,79,"P(1);CU"," "
         WHERE curaccept IN ("Y", "N"))
        IF (curaccept="Y")
         FOR (rucm_i = 1 TO rucm_list)
           SET rucm_request->prsnl_id = rucm_request->list[rucm_i].prsnl_id
           CALL clear(7,1)
           EXECUTE dm_del_user_ctxt_map  WITH replace("REQUEST","RUCM_REQUEST"), replace("REPLY",
            "RUCM_REPLY")
           IF ((rucm_reply->status="F"))
            CALL clear(10,1)
            CALL text(10,50,"Error Ocurred")
            CALL text(12,3,rucm_reply->status_msg)
            CALL pause(5)
            CALL clear(10,1)
            SET dm_err->err_ind = 0
           ENDIF
         ENDFOR
         CALL clear(7,1)
         CALL text(8,3,concat(trim(cnvtstring(rucm_list),3),
           " other user(s) also mapped to the context name ",trim(rucm_request->context_name,3),
           " were also removed"))
         CALL text(9,3,"Press Enter to continue.")
         CALL accept(9,28,"P;E"," ")
         SET rucm_insert_validate = 1
        ELSE
         SET rucm_insert_validate = 1
        ENDIF
       ELSE
        CALL clear(7,1)
        CALL text(7,3,concat("User, ",rucm_request->nff," was unmapped from context ",trim(
           rucm_request->context_name,3)))
        CALL text(8,3,"Press Enter to continue.")
        CALL accept(8,28,"P;E"," ")
        SET rucm_insert_validate = 1
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE chg_usr_cntxt_map(prsnl_id)
   SET help = off
   SET dm_err->eproc = "Change user-context mapping"
   CALL disp_msg(" ",dm_err->logfile,0)
   FREE RECORD cucm_request
   RECORD cucm_request(
     1 prsnl_id = f8
     1 context_name = vc
     1 old_context = vc
     1 nff = vc
     1 list[*]
       2 prsnl_id = f8
   )
   FREE RECORD cucm_reply
   RECORD cucm_reply(
     1 status = c1
     1 status_msg = vc
   )
   DECLARE cucm_insert_validate = i2 WITH protect, noconstant(0)
   DECLARE cucm_insert_validate_cntxt = i2 WITH protect, noconstant(0)
   DECLARE cucm_user_input = vc
   DECLARE cucm_text = vc
   DECLARE cucm_list = i4
   DECLARE cucm_len = i4
   DECLARE cucm_from_add_usr = i2
   SET cucm_insert_validate = 0
   SET cucm_user_input = ""
   SET cucm_list = 0
   SET cucm_len = 0
   SET stat = alterlist(cucm_request->list,cucm_list)
   CALL validate_cclseclogin(null)
   CALL clear(1,1)
   SET width = 132
   CALL box(1,1,5,132)
   CALL text(3,55,"Change user-context mapping")
   IF (prsnl_id > 0)
    SET cucm_from_add_usr = 1
   ELSE
    SET cucm_from_add_usr = 0
    SELECT INTO "NL:"
     FROM dm_refchg_prsnl_ctx_r pcr
     WHERE pcr.active_ind=1
      AND cnvtdatetime(curdate,curtime3) BETWEEN pcr.beg_effective_dt_tm AND pcr.end_effective_dt_tm
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    IF (curqual=0)
     CALL text(7,3,"There are no active user-context mappings to change.")
     CALL text(8,3,"Press Enter to continue.")
     CALL accept(8,28,"P;E"," ")
     SET cucm_insert_validate = 1
    ENDIF
   ENDIF
   WHILE (cucm_insert_validate=0)
     IF (cucm_from_add_usr=0)
      SET cucm_user_input = display_user_list("")
      SET cucm_request->prsnl_id = cnvtreal(cucm_user_input)
     ELSE
      SET cucm_request->prsnl_id = prsnl_id
     ENDIF
     SELECT INTO "NL:"
      pcr.context_name, p.name_full_formatted
      FROM dm_refchg_prsnl_ctx_r pcr,
       prsnl p
      WHERE (pcr.prsnl_id=cucm_request->prsnl_id)
       AND (p.person_id=cucm_request->prsnl_id)
       AND pcr.active_ind=1
       AND cnvtdatetime(curdate,curtime3) BETWEEN pcr.beg_effective_dt_tm AND pcr.end_effective_dt_tm
      DETAIL
       cucm_request->old_context = pcr.context_name, cucm_request->nff = p.name_full_formatted
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
     IF (cucm_user_input="0")
      SET cucm_insert_validate = 1
     ELSE
      IF (cucm_from_add_usr=0)
       SET cucm_user_input = confirm_person(cucm_request->prsnl_id)
      ELSE
       SET cucm_user_input = "Y"
      ENDIF
      IF (cucm_user_input="Y")
       CALL display_context_list("ALL")
       CALL clear(7,1)
       CALL text(7,3,concat("User: ",cucm_request->nff))
       SET cucm_request->context_name = enter_context_name(cucm_request->old_context)
       IF ((cucm_request->context_name="LARGER_THAN_24_CHARACTERS"))
        SET cucm_insert_validate = 1
       ELSE
        SET cucm_return = confirm_addition(cucm_request->prsnl_id,cucm_request->old_context,
         cucm_request->context_name)
        IF (cucm_return="Y")
         EXECUTE dm_add_user_ctxt_map  WITH replace("REQUEST","CUCM_REQUEST"), replace("REPLY",
          "CUCM_REPLY")
         IF ((cucm_reply->status="F"))
          CALL clear(1,1)
          SET width = 132
          CALL box(1,1,7,132)
          CALL text(3,50,"Error Ocurred")
          CALL text(10,3,cucm_reply->status_msg)
          CALL text(11,3,"Press Enter to continue.")
          CALL accept(11,28,"P;E"," ")
          CALL clear(1,1)
          SET dm_err->err_ind = 0
          SET aucm_insert_validate = 1
         ELSE
          SELECT INTO "nl:"
           FROM dm_refchg_prsnl_ctx_r pcr
           WHERE pcr.active_ind=1
            AND cnvtdatetime(curdate,curtime3) BETWEEN pcr.beg_effective_dt_tm AND pcr
           .end_effective_dt_tm
            AND (pcr.context_name=cucm_request->old_context)
            AND (pcr.prsnl_id != cucm_request->prsnl_id)
           DETAIL
            cucm_list = (cucm_list+ 1), stat = alterlist(cucm_request->list,cucm_list), cucm_request
            ->list[cucm_list].prsnl_id = pcr.prsnl_id
           WITH nocounter
          ;end select
          IF (check_error(dm_err->eproc)=1)
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           GO TO exit_program
          ENDIF
          IF (cucm_list > 0)
           CALL clear(7,1)
           CALL text(7,3,concat("User, ",trim(cucm_request->nff,3)," was changed from context ",trim(
              cucm_request->old_context,3)," to context ",
             trim(cucm_request->context_name,3)))
           CALL text(8,3,concat(trim(cnvtstring(cucm_list),3),
             " other user(s) are also mapped to the context name, ",trim(cucm_request->old_context,3)
             ))
           SET cucm_text = concat("Do you want to change the context mappings for them to ",trim(
             cucm_request->context_name,3),"? [Y]es or [N]o:")
           SET cucm_len = (size(cucm_text,1)+ 4)
           CALL text(9,3,cucm_text)
           CALL accept(9,cucm_len,"P(1);CU"," "
            WHERE curaccept IN ("Y", "N"))
           IF (curaccept="Y")
            FOR (cucm_i = 1 TO cucm_list)
              SET cucm_request->prsnl_id = cucm_request->list[cucm_i].prsnl_id
              EXECUTE dm_add_user_ctxt_map  WITH replace("REQUEST","CUCM_REQUEST"), replace("REPLY",
               "CUCM_REPLY")
              IF ((cucm_reply->status="F"))
               CALL clear(1,1)
               SET width = 132
               CALL box(1,1,7,132)
               CALL text(3,50,"Error Ocurred")
               CALL text(10,3,cucm_reply->status_msg)
               CALL pause(5)
               CALL clear(1,1)
               SET dm_err->err_ind = 0
              ENDIF
            ENDFOR
            CALL clear(7,1)
            CALL text(7,3,concat(trim(cnvtstring(cucm_list),3),
              " other user(s) had their context name successfuly changed to ",trim(cucm_request->
               context_name,3)))
            CALL text(8,3,"Press Enter to continue.")
            CALL accept(8,28,"P;E"," ")
            SET cucm_insert_validate = 1
           ELSE
            SET cucm_insert_validate = 1
           ENDIF
          ELSEIF (cucm_list=0)
           CALL clear(7,1)
           CALL text(7,3,concat("User, ",trim(cucm_request->nff,3)," was changed from context ",trim(
              cucm_request->old_context,3)," to context ",
             trim(cucm_request->context_name,3)))
           CALL text(8,3,"Press Enter to continue.")
           CALL accept(8,28,"P;E"," ")
           SET cucm_insert_validate = 1
          ENDIF
         ENDIF
        ELSEIF (cucm_return="N")
         SET cucm_insert_validate = 0
        ELSEIF (cucm_return="X")
         SET cucm_insert_validate = 1
        ENDIF
       ENDIF
      ELSEIF (cucm_user_input="N")
       SET cucm_insert_validate = 0
      ELSEIF (cucm_user_input="X")
       SET cucm_insert_validate = 1
      ENDIF
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE updt_lgd_rows_cntxt(null)
   SET help = off
   SET dm_err->eproc = "Update previously logged rows with CONTEXT_NAME"
   CALL disp_msg(" ",dm_err->logfile,0)
   FREE RECORD ulrc_request
   RECORD ulrc_request(
     1 target_env_id = f8
     1 qual[*]
       2 prsnl_id = f8
       2 context_name = vc
   )
   FREE RECORD ulrc_reply
   RECORD ulrc_reply(
     1 status = c1
     1 status_msg = vc
   )
   DECLARE ulrc_cnt = i4 WITH protect, noconstant(0)
   DECLARE ulrc_insert_validate_env = i2 WITH protect, noconstant(0)
   DECLARE ulrc_prsnl_name = vc
   SET ulrc_insert_validate = 0
   WHILE (ulrc_insert_validate_env=0)
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,5,132)
     CALL text(3,35,"Update previously logged rows with CONTEXT_NAME")
     CALL text(7,3,"Please input a target environment id (0 to exit): ")
     CALL clear(20,1)
     CALL text(23,05,"HELP: Press <SHIFT><F5>     ")
     SET help =
     SELECT INTO "nl:"
      de.environment_id, de.environment_name
      FROM dm_environment de
      WHERE de.environment_id IN (
      (SELECT
       der.child_env_id
       FROM dm_env_reltn der
       WHERE (parent_env_id=dcma_env->env_id)
        AND der.relationship_type="REFERENCE MERGE"))
      ORDER BY de.environment_id
     ;end select
     CALL accept(7,70,"N(15);CU","0"
      WHERE cnvtreal(curaccept) >= 0)
     SET help = off
     IF (curaccept="0")
      SET ulrc_insert_validate_env = 1
     ELSE
      SELECT INTO "nl:"
       FROM dm_environment de
       WHERE de.environment_id IN (
       (SELECT
        der.child_env_id
        FROM dm_env_reltn der
        WHERE (der.parent_env_id=dcma_env->env_id)
         AND der.relationship_type="REFERENCE MERGE"))
        AND (de.environment_id != dcma_env->env_id)
        AND de.environment_id=cnvtreal(curaccept)
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_program
      ENDIF
      IF (curqual > 0)
       SET help = off
       SET ulrc_insert_validate_env = 1
       SET ulrc_request->target_env_id = cnvtreal(curaccept)
       SELECT DISTINCT INTO "nl:"
        dm.updt_id
        FROM dm_chg_log dm
        WHERE (dm.target_env_id=ulrc_request->target_env_id)
         AND dm.log_type IN ("REFCHG", "NORDDS")
         AND updt_id > 0
         AND ((dm.context_name="") OR (dm.context_name = null))
        HEAD REPORT
         ulrc_cnt = 0
        DETAIL
         ulrc_cnt = (ulrc_cnt+ 1)
         IF (mod(ulrc_cnt,100)=1)
          stat = alterlist(ulrc_request->qual,(ulrc_cnt+ 99))
         ENDIF
         ulrc_request->qual[ulrc_cnt].prsnl_id = dm.updt_id
        FOOT REPORT
         stat = alterlist(ulrc_request->qual,ulrc_cnt)
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_program
       ENDIF
       FOR (ulrc_cntxt_cnt = 1 TO ulrc_cnt)
         CALL clear(10,1)
         SET width = 132
         CALL box(1,1,5,132)
         CALL text(3,55,"Inserting context")
         CALL text(10,3,
          "Please enter context_name for PERSON:                                                 :")
         CALL text(11,90,"(Leave blank to skip)")
         SELECT INTO "nl:"
          FROM prsnl p
          WHERE (p.person_id=ulrc_request->qual[ulrc_cntxt_cnt].prsnl_id)
          DETAIL
           ulrc_prsnl_name = p.name_full_formatted
          WITH nocounter
         ;end select
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          GO TO exit_program
         ENDIF
         CALL text(10,41,cnvtstring(ulrc_request->qual[ulrc_cntxt_cnt].prsnl_id))
         CALL text(10,57,ulrc_prsnl_name)
         CALL accept(10,90,"P(24);CUH","")
         SET ulrc_request->qual[ulrc_cntxt_cnt].context_name = curaccept
       ENDFOR
       EXECUTE dm_map_prev_dcl_rows  WITH replace("REQUEST","ULRC_REQUEST"), replace("REPLY",
        "ULRC_REPLY")
       IF ((ulrc_reply->status="F"))
        CALL clear(1,1)
        SET width = 132
        CALL box(1,1,7,132)
        CALL text(3,50,"Error Ocurred")
        CALL text(10,3,ulrc_reply->status_msg)
        CALL pause(5)
        CALL clear(1,1)
        SET dm_err->err_ind = 0
       ENDIF
      ELSE
       CALL clear(20,1)
       CALL text(20,3,"Invalid environment ID")
       CALL pause(3)
       CALL clear(20,1)
      ENDIF
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE chg_grp_cntxt_map(null)
   DECLARE chg_grp_exclude = vc
   DECLARE chg_insert_validate = i4
   DECLARE chg_grp_list = i4
   DECLARE cgcm_i = i4
   DECLARE cgcm_input = vc
   SET ctxt_exclude = ""
   SET chg_grp_list = 0
   SET dm_err->eproc = "Change Group Context Mapping"
   FREE RECORD cgcm_request
   RECORD cgcm_request(
     1 context_name = vc
     1 prsnl_id = f8
     1 qual[*]
       2 prsnl_id = f8
   )
   FREE RECORD cgcm_reply
   RECORD cgcm_reply(
     1 status = c1
     1 status_msg = vc
   )
   SET stat = alterlist(cgcm_request->qual,chg_grp_list)
   SET cgcm_request->context_name = ""
   SET cgcm_request->prsnl_id = 0.0
   CALL clear(1,1)
   SET width = 132
   CALL box(1,1,5,132)
   CALL text(3,55,"Change group-context mapping")
   SELECT INTO "NL:"
    FROM dm_refchg_prsnl_ctx_r pcr
    WHERE pcr.active_ind=1
     AND cnvtdatetime(curdate,curtime3) BETWEEN pcr.beg_effective_dt_tm AND pcr.end_effective_dt_tm
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (curqual=0)
    CALL text(7,3,"There are no active group-context mappings to change.")
    CALL text(8,3,"Press Enter to continue.")
    CALL accept(8,28,"P;E"," ")
    SET chg_insert_validate = 1
   ENDIF
   WHILE (chg_insert_validate=0)
     CALL display_context_list("")
     CALL clear(7,1)
     CALL text(7,3,"Please choose a group-context mapping to change (0 to exit): ")
     CALL text(23,5,
      "<Page Up>, <Page Dn> to see more items; <Up>, <Down> to highlight; <Enter> to select item")
     CALL accept(7,65,"P(24);CUF","0")
     SET help = off
     SET chg_grp_exclude = trim(curaccept,3)
     IF (chg_grp_exclude != "0")
      SET cgcm_request->context_name = trim(enter_context_name(chg_grp_exclude),3)
      IF ((cgcm_request->context_name="LARGER_THAN_24_CHARACTERS"))
       SET cgcm_input = "X"
      ELSE
       SET cgcm_input = confirm_addition(0.0,chg_grp_exclude,cgcm_request->context_name)
      ENDIF
      IF (cgcm_input="Y")
       SELECT INTO "NL:"
        FROM dm_refchg_prsnl_ctx_r pcr
        WHERE pcr.context_name=chg_grp_exclude
         AND pcr.active_ind=1
         AND cnvtdatetime(curdate,curtime3) BETWEEN pcr.beg_effective_dt_tm AND pcr
        .end_effective_dt_tm
        DETAIL
         chg_grp_list = (chg_grp_list+ 1), stat = alterlist(cgcm_request->qual,chg_grp_list),
         cgcm_request->qual[chg_grp_list].prsnl_id = pcr.prsnl_id
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_program
       ENDIF
       FOR (cgcm_i = 1 TO chg_grp_list)
         SET cgcm_request->prsnl_id = cgcm_request->qual[cgcm_i].prsnl_id
         EXECUTE dm_add_user_ctxt_map  WITH replace("REQUEST","CGCM_REQUEST"), replace("REPLY",
          "CGCM_REPLY")
         IF ((cgcm_reply->status="F"))
          CALL clear(1,1)
          SET width = 132
          CALL box(1,1,7,132)
          CALL text(3,50,"Error Ocurred")
          CALL text(10,3,cgcm_reply->status_msg)
          CALL pause(5)
          CALL clear(1,1)
          SET dm_err->err_ind = 0
         ENDIF
       ENDFOR
       CALL clear(7,1)
       CALL text(7,3,concat("Users with a context_name of ",chg_grp_exclude,
         " were changed to context_name ",cgcm_request->context_name))
       CALL text(8,3,"Press Enter to continue.")
       CALL accept(8,28,"P;E"," ")
       SET chg_insert_validate = 1
      ELSEIF (cgcm_input="N")
       SET chg_insert_validate = 0
      ELSEIF (cgcm_input="X")
       SET chg_insert_validate = 1
      ENDIF
     ELSE
      SET chg_insert_validate = 1
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE rmv_grp_cntxt_map(null)
   DECLARE rgcm_userinput = vc
   DECLARE rmv_insert_validate = i4
   DECLARE rmv_grp_list = i4
   DECLARE rgcm_i = i4
   SET rmv_grp_exclude = ""
   SET rmv_grp_list = 0
   FREE RECORD rgcm_request
   RECORD rgcm_request(
     1 context_name = vc
     1 prsnl_id = f8
     1 qual[*]
       2 prsnl_id = f8
   )
   FREE RECORD rgcm_reply
   RECORD rgcm_reply(
     1 status = c1
     1 status_msg = vc
   )
   CALL clear(1,1)
   SET width = 132
   CALL box(1,1,5,132)
   CALL text(3,55,"Remove group-context mapping")
   SELECT INTO "NL:"
    FROM dm_refchg_prsnl_ctx_r pcr
    WHERE pcr.active_ind=1
     AND cnvtdatetime(curdate,curtime3) BETWEEN pcr.beg_effective_dt_tm AND pcr.end_effective_dt_tm
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (curqual=0)
    CALL text(7,3,"There are no active group-context mappings to remove.")
    CALL text(8,3,"Press Enter to continue.")
    CALL accept(8,28,"P;E"," ")
    SET rmv_insert_validate = 1
   ENDIF
   WHILE (rmv_insert_validate=0)
     CALL display_context_list("")
     CALL clear(7,1)
     CALL text(7,3,"Please choose a group-context mapping to remove (0 to exit): ")
     CALL text(23,5,
      "<Page Up>, <Page Dn> to see more items; <Up>, <Down> to highlight; <Enter> to select item")
     CALL accept(7,66,"P(24);CUF","0")
     SET help = off
     SET rgcm_request->context_name = curaccept
     IF ((rgcm_request->context_name != "0"))
      SELECT INTO "NL:"
       FROM dm_refchg_prsnl_ctx_r pcr
       WHERE pcr.context_name=trim(rgcm_request->context_name,3)
        AND pcr.active_ind=1
        AND cnvtdatetime(curdate,curtime3) BETWEEN pcr.beg_effective_dt_tm AND pcr
       .end_effective_dt_tm
       DETAIL
        rmv_grp_list = (rmv_grp_list+ 1), stat = alterlist(rgcm_request->qual,rmv_grp_list),
        rgcm_request->qual[rmv_grp_list].prsnl_id = pcr.prsnl_id
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_program
      ENDIF
      IF (curqual=0)
       CALL text(9,3,concat("The context name ",rgcm_request->context_name,
         " does not have any active users mapped to it."))
       CALL text(10,3,"Press Enter to continue.")
       CALL accept(10,28,"P;E"," ")
       SET rgcm_userinput = "X"
      ELSE
       SET rgcm_userinput = confirm_removal(0.0,rgcm_request->context_name)
      ENDIF
      IF (rgcm_userinput="Y")
       FOR (rgcm_i = 1 TO size(rgcm_request->qual,5))
         SET rgcm_request->prsnl_id = rgcm_request->qual[rgcm_i].prsnl_id
         EXECUTE dm_del_user_ctxt_map  WITH replace("REQUEST","RGCM_REQUEST"), replace("REPLY",
          "RGCM_REPLY")
         IF ((rgcm_reply->status="F"))
          CALL clear(1,1)
          SET width = 132
          CALL box(1,1,7,132)
          CALL text(3,50,"Error Ocurred")
          CALL text(10,3,rgcm_reply->status_msg)
          CALL pause(5)
          CALL clear(1,1)
          SET dm_err->err_ind = 0
         ENDIF
       ENDFOR
       CALL clear(7,1)
       CALL text(7,3,concat("Users with a context_name of ",trim(rgcm_request->context_name,3),
         " were removed."))
       CALL text(8,3,"Press Enter to continue.")
       CALL accept(8,28,"P;E"," ")
       SET rmv_insert_validate = 1
      ELSEIF (rgcm_userinput="N")
       SET rmv_insert_validate = 0
      ELSEIF (rgcm_userinput="X")
       SET rmv_insert_validate = 1
      ENDIF
     ELSE
      SET rmv_insert_validate = 1
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE view_hist_cntxt_map(null)
   SET dm_err->eproc = "View historical context mapping"
   CALL disp_msg(" ",dm_err->logfile,0)
   SET help = off
   DECLARE user_input = vc
   DECLARE chosen_id = vc
   DECLARE chosen_ctxt = vc
   CALL clear(1,1)
   SET width = 132
   CALL box(1,1,5,132)
   CALL text(3,55,"View historical context mapping")
   CALL text(7,3,"View historical context mapping by [C]ontext or [U]ser: ")
   CALL accept(7,60,"P(1);CU","C"
    WHERE curaccept IN ("U", "C"))
   SET user_input = curaccept
   CALL clear(7,1)
   SELECT INTO "NL:"
    FROM dm_refchg_prsnl_ctx_r cr
    WHERE cr.dm_refchg_prsnl_ctx_r_id > 0
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (curqual=0)
    CALL text(7,3,"There is no historical context mapping data to display.")
    CALL text(8,3,"Press Enter to continue.")
    CALL accept(8,28,"P;E"," ")
    SET user_input = "X"
   ENDIF
   IF (user_input="C")
    CALL display_context_list("ALL")
    CALL text(7,3,"Enter a context_name you want to view ")
    CALL text(23,5,
     "<Page Up>, <Page Dn> to see more items; <Up>, <Down> to highlight; <Enter> to select item")
    CALL accept(7,50,"P(24);CUF")
    SET help = off
    SET chosen_ctxt = trim(curaccept,3)
    CALL text(9,3,"Generating report...")
    SELECT INTO "NL:"
     FROM dm_refchg_prsnl_ctx_r cr
     WHERE cr.context_name=chosen_ctxt
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL clear(8,1)
     CALL text(9,3,concat("Data was not found for the chosen context name ",chosen_ctxt))
     CALL text(10,3,"Press Enter to continue.")
     CALL accept(10,28,"P;E"," ")
    ELSE
     SET message = nowindow
     SELECT INTO mine
      context_name = substring(1,24,dr.context_name), name_full_formatted = substring(1,50,p
       .name_full_formatted), user_name = trim(p.username),
      begin_date = dr.beg_effective_dt_tm, end_date = dr.end_effective_dt_tm, position = trim(cv
       .display),
      mod_nff = concat(trim(p2.username,3)," - ",trim(substring(1,50,p2.name_full_formatted),3)),
      env_id = cnvtstring(dcma_env->env_id), env_name = dcma_env->env_name,
      generated = format(cnvtdatetime(curdate,curtime3),"DD-MMM-YYYY HH:MM:SS;;D")
      FROM prsnl p,
       dm_refchg_prsnl_ctx_r dr,
       code_value cv,
       prsnl p2
      WHERE p.person_id=dr.prsnl_id
       AND dr.context_name=chosen_ctxt
       AND p.position_cd=cv.code_value
       AND p2.person_id=dr.updt_id
      ORDER BY name_full_formatted, begin_date DESC
      HEAD REPORT
       col 30, "View Historical Context-Mapping for ", context_name,
       row + 2, col 30, "GENERATED ON ",
       generated, row + 1, col 20,
       "ENVIRONMENT NAME: ", env_name, col 60,
       "ENVIRONMENT ID: ", env_id, row + 2
      HEAD context_name
       col 0, "NAME", col 50,
       "USERNAME", col 72, "ACTIVE",
       col 80, "BEGIN DATE", col 101,
       "END DATE", row + 1
      DETAIL
       col 0, name_full_formatted, col 50,
       user_name, col 72
       IF (dr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
        "*"
       ENDIF
       col 80, begin_date, col 101,
       end_date, row + 1
       IF (dr.updt_id=0)
        col 5, "Last Modified By: Data Not Captured"
       ELSE
        col 5, "Last Modified By: ", mod_nff
       ENDIF
       row + 2
      FOOT  context_name
       row + 2
      WITH nocounter, format(date,"DD-MMM-YYYY HH:MM:SS;;D")
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
    ENDIF
   ELSEIF (user_input="U")
    SET chosen_id = display_user_list("ALL")
    IF (cnvtreal(chosen_id) > 0)
     CALL clear(8,1)
     CALL text(9,3,"Generating report...")
     SELECT INTO "NL:"
      FROM dm_refchg_prsnl_ctx_r cr
      WHERE cr.prsnl_id=cnvtreal(chosen_id)
      WITH nocounter
     ;end select
     IF (curqual=0)
      CALL clear(8,1)
      CALL text(9,3,concat("The millenium user id entered ",chosen_id," is not valid millenium user."
        ))
      CALL text(10,3,"Press Enter to continue.")
      CALL accept(10,28,"P;E"," ")
     ELSE
      SET message = nowindow
      SELECT INTO mine
       context_name = substring(1,24,dr.context_name), name_full_formatted = substring(1,50,p
        .name_full_formatted), begin_date = dr.beg_effective_dt_tm,
       end_date = dr.end_effective_dt_tm, position = cv.display, mod_nff = concat(trim(p2.username,3),
        " - ",trim(substring(1,50,p2.name_full_formatted),3)),
       env_id = cnvtstring(dcma_env->env_id), env_name = dcma_env->env_name, generated = format(
        cnvtdatetime(curdate,curtime3),"DD-MMM-YYYY HH:MM:SS;;D")
       FROM prsnl p,
        dm_refchg_prsnl_ctx_r dr,
        code_value cv,
        prsnl p2
       WHERE dr.prsnl_id=p.person_id
        AND dr.prsnl_id=cnvtreal(chosen_id)
        AND p.position_cd=cv.code_value
        AND p2.person_id=dr.updt_id
       ORDER BY begin_date DESC
       HEAD REPORT
        col 30, "View Historical Context-Mapping for ", name_full_formatted,
        row + 2, col 30, "Generated on ",
        generated, row + 1, col 20,
        "Environment Name: ", env_name, col 60,
        "Environment ID: ", env_id, row + 2,
        col 0, "Context Name", col 72,
        "ACTIVE", col 80, "BEGIN DATE",
        col 101, "END DATE", row + 1
       DETAIL
        col 0, context_name, col 72
        IF (dr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
         "*"
        ENDIF
        col 80, begin_date, col 101,
        end_date, row + 1
        IF (dr.updt_id=0)
         col 5, "Last Modified By: Data Not Captured"
        ELSE
         col 5, "Last Modified By: ", mod_nff
        ENDIF
        row + 1
       WITH nocounter, format(date,"DD-MMM-YYYY HH:MM:SS;;D")
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_program
      ENDIF
     ENDIF
    ELSE
     CALL clear(5,1)
    ENDIF
   ENDIF
   SET message = window
 END ;Subroutine
 SUBROUTINE validate_cclseclogin(null)
   IF ((validate(xxcclseclogin->loggedin,- (99)) != - (99)))
    IF ((xxcclseclogin->loggedin != 1))
     CALL text(22,3,
      "In order to perform this action, you are required to be logged in securely to the Millennium database"
      )
     CALL text(23,3,"Press Enter to continue to login prompt.")
     CALL accept(23,45,"P;E"," ")
     CALL clear(1,1)
     CALL parser("cclseclogin go")
     IF ((xxcclseclogin->loggedin != 1))
      SET message = nowindow
      SET dm_err->eproc = "User/Group-context Settings"
      SET dm_err->emsg = "User not logged in cclseclogin"
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      GO TO exit_program
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE display_user_list(last_name)
   IF (trim(last_name,3) > " "
    AND trim(last_name,3) != "ALL")
    SET help = pos(8,1,14,130)
    SET help =
    SELECT INTO "NL:"
     person_id = substring(1,15,concat(trim(cnvtstring(p.person_id),3),".0")), name = substring(1,45,
      trim(p.name_full_formatted,3)), position = substring(1,20,trim(c.display,3)),
     username = substring(1,20,trim(p.username,3))
     FROM prsnl p,
      code_value c
     WHERE p.name_last_key=patstring(last_name)
      AND c.code_value=p.position_cd
      AND p.active_ind=1
      AND p.username > " "
     ORDER BY p.name_full_formatted, c.display
     WITH nocounter
    ;end select
    CALL clear(7,1)
    CALL text(7,3,concat(trim(cnvtstring(aucm_search->cnt)),
      " users were found.  Please select one person (0 to exit):"))
    CALL text(23,5,
     "<Page Up>, <Page Dn> to see more items; <Up>, <Down> to highlight; <Enter> to select item")
    CALL accept(7,70,"P(15);CUF","0")
    SET help = off
    RETURN(curaccept)
   ELSEIF (trim(last_name,3)="ALL")
    SET help = pos(8,1,14,130)
    SET help =
    SELECT DISTINCT INTO "NL:"
     person_id = substring(1,15,concat(trim(cnvtstring(p.person_id),3),".0")), name = substring(1,45,
      trim(p.name_full_formatted,3)), position = substring(1,20,trim(c.display,3)),
     username = substring(1,20,trim(p.username,3))
     FROM prsnl p,
      code_value c,
      dm_refchg_prsnl_ctx_r pcr
     WHERE pcr.prsnl_id=p.person_id
      AND c.code_value=p.position_cd
     ORDER BY p.name_full_formatted, c.display
     WITH nocounter
    ;end select
    CALL clear(7,1)
    CALL text(7,3,"Please select one person (0 to exit):")
    CALL text(23,5,
     "<Page Up>, <Page Dn> to see more items; <Up>, <Down> to highlight; <Enter> to select item")
    CALL accept(7,42,"P(15);CUF","0")
    SET help = off
    RETURN(curaccept)
   ELSEIF (trim(last_name,3)="")
    SET help = pos(8,1,14,130)
    SET help =
    SELECT INTO "NL:"
     person_id = substring(1,15,concat(trim(cnvtstring(p.person_id),3),".0")), name = substring(1,40,
      trim(p.name_full_formatted,3)), position = substring(1,20,trim(c.display,3)),
     username = substring(1,15,trim(p.username,3)), context_name = substring(1,24,trim(pcr
       .context_name,3))
     FROM prsnl p,
      code_value c,
      dm_refchg_prsnl_ctx_r pcr
     WHERE pcr.prsnl_id=p.person_id
      AND pcr.active_ind=1
      AND cnvtdatetime(curdate,curtime3) BETWEEN pcr.beg_effective_dt_tm AND pcr.end_effective_dt_tm
      AND c.code_value=p.position_cd
     ORDER BY p.name_full_formatted, c.display
     WITH nocounter
    ;end select
    CALL clear(7,1)
    CALL text(7,3,"Please select one person (0 to exit):")
    CALL text(23,5,
     "<Page Up>, <Page Dn> to see more items; <Up>, <Down> to highlight; <Enter> to select item")
    CALL accept(7,42,"P(15);CUF","0")
    SET help = off
    RETURN(curaccept)
   ENDIF
 END ;Subroutine
 SUBROUTINE display_context_list(ex_ctxt)
   DECLARE list_ndx = i4
   DECLARE ctxt_list_cnt = i4
   DECLARE rs_item_list = vc
   FREE RECORD dcl_ctxt
   RECORD dcl_ctxt(
     1 qual[*]
       2 ctx_name = c24
   )
   SET list_ndx = 0
   IF (ex_ctxt="ALL")
    SET help =
    SELECT DISTINCT INTO "NL:"
     context = substring(1,24,cr.context_name)
     FROM dm_refchg_prsnl_ctx_r cr
     WHERE cr.dm_refchg_prsnl_ctx_r_id > 0
     ORDER BY context
     WITH nocounter
    ;end select
   ELSE
    SET help =
    SELECT DISTINCT INTO "NL:"
     context = substring(1,24,cr.context_name)
     FROM dm_refchg_prsnl_ctx_r cr
     WHERE cr.active_ind=1
      AND cr.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
      AND cr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     ORDER BY context
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE enter_context_name(old_ctxt)
   DECLARE dcn_validate = i4
   SET ecn_validate = 0
   CALL clear(8,1)
   CALL display_context_list("ALL")
   WHILE (ecn_validate=0)
    IF (trim(old_ctxt) > " ")
     CALL text(8,3,concat("Old CONTEXT_NAME: ",old_ctxt))
     CALL text(9,3,"New CONTEXT_NAME: ")
     CALL text(12,20,"** 'ALL' is not a valid context_name")
     CALL text(13,20,"** 'NULL' is not a valid context_name")
     CALL text(14,20,"** ':' is not allowed in the context_name")
     CALL text(23,5,"HELP: Press <SHIFT><F5>  ")
     CALL accept(9,21,"P(24);CU")
    ELSE
     CALL text(8,3,"New CONTEXT_NAME: ")
     CALL text(12,20,"** 'ALL' is not a valid context_name")
     CALL text(13,20,"** 'NULL' is not a valid context_name")
     CALL text(14,20,"** ':' is not allowed in the context_name")
     CALL text(23,5,"HELP: Press <SHIFT><F5>  ")
     CALL accept(8,21,"P(24);CU")
    ENDIF
    IF (((curaccept="ALL") OR (((findstring(":",curaccept) > 0) OR (((curaccept="NULL") OR (trim(
     curaccept)="")) )) )) )
     CALL clear(20,1)
     CALL text(23,5,"ERROR: Please enter a valid context name.")
     CALL text(24,3,"Press Enter to continue.")
     CALL accept(24,28,"P;E"," ")
     CALL clear(20,1)
    ELSEIF (curaccept=old_ctxt)
     CALL clear(20,1)
     CALL text(23,5,"ERROR: Please enter a new context name.")
     CALL text(24,3,"[E]nter to continue or e[X]it")
     CALL accept(24,35,"P;CU"," "
      WHERE curaccept IN ("E", "X"))
     CALL clear(20,1)
     IF (curaccept="X")
      SET ecn_validate = 1
      RETURN("LARGER_THAN_24_CHARACTERS")
     ENDIF
    ELSE
     SET ecn_validate = 1
    ENDIF
   ENDWHILE
   SET help = off
   RETURN(curaccept)
 END ;Subroutine
 SUBROUTINE confirm_person(person_id)
   DECLARE cp_name = vc
   DECLARE cp_user_name = vc
   DECLARE cp_prsnl_id = f8
   DECLARE cp_position = vc
   SET cp_prsnl_id = person_id
   SELECT INTO "NL:"
    p.person_id, p.name_full_formatted, p.username,
    c.display
    FROM prsnl p,
     code_value c
    WHERE p.person_id=cp_prsnl_id
     AND c.code_value=p.position_cd
    DETAIL
     cp_name = p.name_full_formatted, cp_user_name = p.username, cp_position = c.display
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   CALL clear(7,1)
   CALL text(7,3,concat("The person you selected is: ",trim(cp_name,3)))
   CALL text(8,3,concat("Username: ",trim(cp_user_name,3)))
   CALL text(9,3,concat("Position: ",trim(cp_position,3)))
   CALL text(10,3,"Continue with this user? ([Y]es/[N]o/e[X]it):")
   CALL accept(10,49,"P;CU","Y"
    WHERE curaccept IN ("Y", "N", "X"))
   RETURN(curaccept)
 END ;Subroutine
 SUBROUTINE confirm_removal(person_id,context_name)
   DECLARE cr_name = vc
   DECLARE cr_user_name = vc
   DECLARE cr_prsnl_id = f8
   DECLARE cr_position = vc
   SET cr_prsnl_id = person_id
   IF (cr_prsnl_id > 0)
    SELECT INTO "NL:"
     p.person_id, p.name_full_formatted, p.username,
     c.display
     FROM prsnl p,
      code_value c
     WHERE p.person_id=cr_prsnl_id
      AND c.code_value=p.position_cd
     DETAIL
      cr_name = p.name_full_formatted, cr_user_name = p.username, cr_position = c.display
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    CALL clear(7,1)
    CALL text(7,3,concat("The person you selected is: ",trim(cr_name,3)))
    CALL text(8,3,concat("Username: ",trim(cr_user_name,3)))
    CALL text(9,3,concat("Position: ",trim(cr_position,3)))
    CALL text(10,3,concat("Context_Name: ",trim(context_name,3)))
    CALL text(11,3,
     "Are you sure you want to remove the context name associated with this user? ([Y]es/[N]o/e[X]it):"
     )
    CALL accept(11,100,"P;CU"," "
     WHERE curaccept IN ("Y", "N", "X"))
   ELSE
    CALL clear(7,1)
    CALL text(7,3,concat("The context_name you selected is: ",trim(context_name,3)))
    CALL text(8,3,"Are you sure you want to remove this context_name? ([Y]es/[N]o/e[X]it):")
    CALL accept(8,75,"P;CU"," "
     WHERE curaccept IN ("Y", "N", "X"))
   ENDIF
   RETURN(curaccept)
 END ;Subroutine
 SUBROUTINE confirm_addition(person_id,old_context_name,new_context_name)
   DECLARE cr_name = vc
   DECLARE cr_user_name = vc
   DECLARE cr_prsnl_id = f8
   DECLARE cr_position = vc
   DECLARE cr_line = i4
   SET cr_prsnl_id = person_id
   SET cr_line = 7
   IF (cr_prsnl_id > 0)
    SELECT INTO "NL:"
     p.person_id, p.name_full_formatted, p.username,
     c.display
     FROM prsnl p,
      code_value c
     WHERE p.person_id=cr_prsnl_id
      AND c.code_value=p.position_cd
     DETAIL
      cr_name = p.name_full_formatted, cr_user_name = p.username, cr_position = c.display
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
   ENDIF
   CALL clear(cr_line,1)
   IF (cr_prsnl_id > 0)
    CALL text(cr_line,3,concat("The person you selected is: ",trim(cr_name,3)))
    SET cr_line = (cr_line+ 1)
    CALL text(cr_line,3,concat("Username: ",trim(cr_user_name,3)))
    SET cr_line = (cr_line+ 1)
    CALL text(cr_line,3,concat("Position: ",trim(cr_position,3)))
    SET cr_line = (cr_line+ 1)
   ENDIF
   IF (trim(old_context_name,3)="")
    CALL text(cr_line,3,concat("Context_Name: ",trim(new_context_name,3)))
    SET cr_line = (cr_line+ 1)
    CALL text(cr_line,3,
     "Are you sure you want to add the context name to this user? ([Y]es/[N]o/e[X]it):")
    CALL accept(cr_line,87,"P;CU"," "
     WHERE curaccept IN ("Y", "N", "X"))
   ELSE
    CALL text(cr_line,3,concat("Old Context Name: ",trim(old_context_name)))
    SET cr_line = (cr_line+ 1)
    CALL text(cr_line,3,concat("New Context Name: ",trim(new_context_name)))
    SET cr_line = (cr_line+ 1)
    CALL text(cr_line,3,"Are you sure you want to change the context name? ([Y]es/[N]o/e[X]it):")
    CALL accept(cr_line,75,"P;CU"," "
     WHERE curaccept IN ("Y", "N", "X"))
   ENDIF
   RETURN(curaccept)
 END ;Subroutine
 SUBROUTINE modify_context(person_id)
   DECLARE mc_ctxt_name = vc
   SELECT INTO "NL:"
    FROM dm_refchg_prsnl_ctx_r pcr
    WHERE pcr.prsnl_id=person_id
     AND pcr.active_ind=1
     AND pcr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pcr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    DETAIL
     mc_ctxt_name = pcr.context_name
    WITH nocounter
   ;end select
   IF (curqual=1)
    CALL clear(7,1)
    CALL text(7,3,concat("User ",trim(aucm_search->list[1].prsnl_nff),
      " already has a context name mapped."))
    CALL text(8,3,concat("Currently mapped to context: ",trim(mc_ctxt_name)))
    CALL text(9,3,"Do you want to change their context name? ([Y]es/[N]o/e[X]it): ")
    CALL accept(9,66,"P;CU","Y"
     WHERE curaccept IN ("Y", "N", "X"))
    RETURN(curaccept)
   ELSE
    RETURN("Z")
   ENDIF
 END ;Subroutine
#exit_program
 SET message = nowindow
 IF ((dm_err->err_ind=1))
  CALL disp_msg("Errors occurred during execution, check logfile for details",dm_err->logfile,1)
 ELSE
  CALL disp_msg("DM_CONTEXT_MERGE_ADM has finished",dm_err->logfile,0)
 ENDIF
END GO
