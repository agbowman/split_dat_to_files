CREATE PROGRAM dm_single_commit_explode:dba
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
 DECLARE add_tracking_row(i_source_id=f8,i_refchg_type=vc,i_refchg_status=vc) = null
 DECLARE delete_tracking_row(null) = null
 DECLARE move_long(i_from_table=vc,i_to_table=vc,i_column_name=vc,i_pk_str=vc,i_source_env_id=f8,
  i_status_flag=i4) = null
 DECLARE get_reg_tab_name(i_r_tab_name=vc,i_suffix=vc) = vc
 DECLARE dcc_find_val(i_delim_str=vc,i_delim_val=vc,i_val_rec=vc(ref)) = i2
 DECLARE move_circ_long(i_from_table=vc,i_from_rtable=vc,i_from_pk=vc,i_from_prev_pk=vc,i_from_fk=vc,
  i_from_pe_col=vc,i_circ_table=vc,i_circ_column_name=vc,i_circ_fk_col=vc,i_circ_long_col=vc,
  i_source_env_id=f8,i_status_flag=i4) = null
 IF ((validate(table_data->counter,- (1))=- (1)))
  FREE RECORD table_data
  RECORD table_data(
    1 counter = i4
    1 qual[*]
      2 table_name = vc
      2 table_suffix = vc
  ) WITH protect
 ENDIF
 SUBROUTINE add_tracking_row(i_source_id,i_refchg_type,i_refchg_status)
   DECLARE var_process = vc
   DECLARE var_sid = f8
   DECLARE var_serial_num = f8
   SELECT INTO "nl:"
    process, sid, serial#
    FROM v$session vs
    WHERE audsid=cnvtreal(currdbhandle)
    DETAIL
     var_process = vs.process, var_sid = vs.sid, var_serial_num = vs.serial#
    WITH maxqual(vs,1)
   ;end select
   UPDATE  FROM dm_refchg_process
    SET refchg_type = i_refchg_type, refchg_status = i_refchg_status, last_action_dt_tm = sysdate,
     updt_cnt = (updt_cnt+ 1), updt_id = reqinfo->updt_id, updt_applctx = reqinfo->updt_applctx,
     updt_task = reqinfo->updt_task, updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE rdbhandle_value=cnvtreal(currdbhandle)
   ;end update
   COMMIT
   IF (curqual=0)
    INSERT  FROM dm_refchg_process
     SET dm_refchg_process_id = seq(dm_clinical_seq,nextval), env_source_id = i_source_id,
      rdbhandle_value = cnvtreal(currdbhandle),
      process_name = var_process, log_file = dm_err->logfile, last_action_dt_tm = sysdate,
      refchg_type = i_refchg_type, refchg_status = i_refchg_status, updt_cnt = 0,
      updt_id = reqinfo->updt_id, updt_applctx = reqinfo->updt_applctx, updt_task = reqinfo->
      updt_task,
      updt_dt_tm = cnvtdatetime(curdate,curtime3), session_sid = var_sid, serial_number =
      var_serial_num
    ;end insert
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE delete_tracking_row(null)
  DELETE  FROM dm_refchg_process
   WHERE rdbhandle_value=cnvtreal(currdbhandle)
   WITH nocounter
  ;end delete
  COMMIT
 END ;Subroutine
 SUBROUTINE move_long(i_from_table,i_to_table,i_column_name,i_pk_str,i_source_env_id,i_status_flag)
   RECORD long_col(
     1 data[*]
       2 pk_str = vc
       2 long_str = vc
   )
   SET s_rdds_where_iu_str =
   " rdds_delete_ind = 0 and rdds_source_env_id = i_source_env_id and rdds_status_flag = i_status_flag"
   DECLARE long_str = vc
   CALL parser(" select into 'nl:' ",0)
   CALL parser(concat("        bloblen = textlen(l.",trim(i_column_name),")"),0)
   CALL parser(concat("        , pk_str=",i_pk_str),0)
   CALL parser(concat("   from ",trim(i_from_table)," l "),0)
   CALL parser(concat(" where ",s_rdds_where_iu_str),0)
   CALL parser(" head report ",0)
   CALL parser("   outbuf = fillstring(32767,' ') ",0)
   CALL parser("   long_cnt = 0 ",0)
   CALL parser(" detail ",0)
   CALL parser("   retlen = 0 ",0)
   CALL parser("   offset = 0 ",0)
   CALL parser("   long_str = ' ' ",0)
   CALL parser(concat("   retlen = blobget(outbuf,offset,l.",trim(i_column_name),") "),0)
   CALL parser("   while (retlen > 0) ",0)
   CALL parser("     if (long_str = ' ') ",0)
   CALL parser("       long_str = notrim(outbuf) ",0)
   CALL parser("     else ",0)
   CALL parser("       long_str = notrim(concat(long_str,substring(1,retlen,outbuf))) ",0)
   CALL parser("     endif ",0)
   CALL parser("     offset = offset + retlen ",0)
   CALL parser(concat("     retlen = blobget(outbuf,offset,l.",trim(i_column_name),") "),0)
   CALL parser("   endwhile ",0)
   CALL parser("   long_cnt=long_cnt + 1",0)
   CALL parser("   if (mod(long_cnt,50) = 1)",0)
   CALL parser("     stat = alterlist(long_col->data,long_cnt+49)",0)
   CALL parser("   endif",0)
   CALL parser("   long_col->data[long_cnt].pk_str = pk_str",0)
   CALL parser("   long_col->data[long_cnt].long_str = trim(long_str,5)",0)
   CALL parser(" foot report",0)
   CALL parser("   stat = alterlist(long_col->data,long_cnt)",0)
   CALL parser(" with nocounter,rdbarrayfetch=1 ",0)
   CALL parser(" go",1)
   FOR (lc_ndx = 1 TO size(long_col->data,5))
     CALL parser(concat("update from ",trim(i_to_table)," set ",trim(i_column_name)),0)
     CALL parser("= long_col->data[lc_ndx].long_str where ",0)
     CALL parser(long_col->data[lc_ndx].pk_str,0)
     CALL parser(" go",1)
   ENDFOR
 END ;Subroutine
 SUBROUTINE get_reg_tab_name(i_r_tab_name,i_suffix)
   DECLARE s_suffix = vc
   DECLARE s_tab_name = vc
   IF (i_suffix > " ")
    SET s_suffix = i_suffix
   ELSE
    SET s_suffix = substring((size(i_r_tab_name) - 5),4,i_r_tab_name)
   ENDIF
   SELECT INTO "nl:"
    dtd.table_name
    FROM dm_rdds_tbl_doc dtd
    WHERE dtd.table_suffix=s_suffix
     AND dtd.table_name=dtd.full_table_name
    DETAIL
     s_tab_name = dtd.table_name
    WITH nocounter
   ;end select
   RETURN(s_tab_name)
 END ;Subroutine
 SUBROUTINE dcc_find_val(i_delim_str,i_delim_val,i_val_rec)
   DECLARE dfv_temp_delim_str = vc WITH constant(concat(i_delim_val,i_delim_str,i_delim_val)),
   protect
   DECLARE dfv_temp_str = vc WITH noconstant(""), protect
   DECLARE dfv_return = i2 WITH noconstant(0), protect
   IF (size(trim(i_delim_str),1) > 0)
    FOR (i = 1 TO i_val_rec->len)
      IF (size(trim(i_val_rec->values[i].str),1) > 0)
       SET dfv_temp_str = concat(i_delim_val,i_val_rec->values[i].str,i_delim_val)
       IF (findstring(dfv_temp_str,dfv_temp_delim_str) > 0)
        SET dfv_return = 1
        RETURN(dfv_return)
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   RETURN(dfv_return)
 END ;Subroutine
 SUBROUTINE move_circ_long(i_from_table,i_from_rtable,i_from_pk,i_from_prev_pk,i_from_fk,
  i_from_pe_col,i_circ_table,i_circ_column_name,i_circ_fk_col,i_circ_long_col,i_source_env_id,
  i_status_flag)
   DECLARE mcl_rdds_iu_str = vc WITH protect, noconstant("")
   DECLARE move_circ_lc_ndx = i4 WITH protect, noconstant(0)
   DECLARE move_circ_long_str = vc WITH protect, noconstant("")
   DECLARE evaluate_pe_name() = c255
   RECORD long_col(
     1 data[*]
       2 long_pk = f8
       2 long_col_fk = f8
       2 long_str = vc
   )
   SET mcl_rdds_iu_str =
   " r.rdds_delete_ind = 0 and r.rdds_source_env_id = i_source_env_id and r.rdds_status_flag = i_status_flag"
   CALL parser(" select into 'nl:' ",0)
   CALL parser(concat("        bloblen = textlen(l.",trim(i_circ_long_col),")"),0)
   CALL parser(concat("   from ",trim(i_circ_table)," l, ",trim(i_from_table)," t, "),0)
   CALL parser(concat("         ",trim(i_from_rtable)," r "),0)
   CALL parser(concat(" where l.",trim(i_circ_column_name)," = t.",i_from_fk),0)
   CALL parser(concat("    and t.",i_from_pk," = r.",i_from_prev_pk),0)
   CALL parser(concat("    and r.",i_from_pk," != r.",i_from_prev_pk),0)
   IF (i_from_pe_col > "")
    CALL parser(concat("    and evaluate_pe_name('",i_from_table,"', '",i_from_fk,"','",
      i_from_pe_col,"', r.",i_from_pe_col,") = '",i_circ_table,
      "'"),0)
   ENDIF
   CALL parser(concat("    and l.",i_circ_column_name," > 0"),0)
   CALL parser(concat("    and ",mcl_rdds_iu_str),0)
   CALL parser(" head report ",0)
   CALL parser("   outbuf = fillstring(32767,' ') ",0)
   CALL parser("   long_cnt = 0 ",0)
   CALL parser(" detail ",0)
   CALL parser("   retlen = 0 ",0)
   CALL parser("   offset = 0 ",0)
   CALL parser("   move_circ_long_str = ' ' ",0)
   CALL parser(concat("   retlen = blobget(outbuf,offset,l.",trim(i_circ_long_col),") "),0)
   CALL parser("   while (retlen > 0) ",0)
   CALL parser("     if (move_circ_long_str = ' ') ",0)
   CALL parser("       move_circ_long_str = notrim(outbuf) ",0)
   CALL parser("     else ",0)
   CALL parser(
    "       move_circ_long_str = notrim(concat(move_circ_long_str,substring(1,retlen,outbuf))) ",0)
   CALL parser("     endif ",0)
   CALL parser("     offset = offset + retlen ",0)
   CALL parser(concat("     retlen = blobget(outbuf,offset,l.",trim(i_circ_long_col),") "),0)
   CALL parser("   endwhile ",0)
   CALL parser("   long_cnt=long_cnt + 1",0)
   CALL parser("   if (mod(long_cnt,50) = 1)",0)
   CALL parser("     stat = alterlist(long_col->data,long_cnt+49)",0)
   CALL parser("   endif",0)
   CALL parser(concat("   long_col->data[long_cnt].long_pk = t.",i_from_pk),0)
   CALL parser("   long_col->data[long_cnt].long_str = trim(move_circ_long_str,5)",0)
   CALL parser(concat("   long_col->data[long_cnt].long_col_fk = r.",i_from_fk),0)
   CALL parser(" foot report",0)
   CALL parser("   stat = alterlist(long_col->data,long_cnt)",0)
   CALL parser(" with nocounter,rdbarrayfetch=1 ",0)
   CALL parser(" go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   FOR (move_circ_lc_ndx = 1 TO size(long_col->data,5))
     CALL parser(concat("update from ",trim(i_circ_table)," t set ",trim(i_circ_long_col)),0)
     CALL parser("= long_col->data[move_circ_lc_ndx].long_str where ",0)
     CALL parser(concat("t.",i_circ_column_name," = ",trim(cnvtstring(long_col->data[move_circ_lc_ndx
         ].long_col_fk,20,2))),0)
     CALL parser(" go",1)
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(null)
     ENDIF
   ENDFOR
 END ;Subroutine
 DECLARE rs_cnt = i4
 DECLARE dsce_batch_size = i4
 DECLARE dcl_cnt = i4
 DECLARE dsce_return = i4
 DECLARE dsce_t_cnt = i4
 DECLARE dsce_tgt_cnt = i4
 DECLARE dsce_batch_loop = i4
 DECLARE dsce_processed_tbl_cnt = i4
 DECLARE dsce_i = i4
 DECLARE dsce_dcla_seq = f8
 DECLARE dsce_trg_cnt = i4
 DECLARE root_ndx1 = i4
 DECLARE dsce_pause_ind = i2
 DECLARE dsce_rdbhandle = f8
 DECLARE dsce_wait_time = i4
 DECLARE dsce_explode_limit = f8
 DECLARE dsce_sc_cnt = i4
 DECLARE dsce_idx = i4
 DECLARE dsce_idx1 = i4
 DECLARE dsce_t = i4
 DECLARE dsce_rows_left = i4
 DECLARE dsce_tname = vc
 DECLARE tbl_ready_to_process = c1 WITH constant("^")
 DECLARE tbl_processing = c1 WITH constant("&")
 DECLARE tbl_complete = c1 WITH constant("%")
 DECLARE tbl_failed = c1 WITH constant("!")
 DECLARE dsce_info_domain = vc WITH constant("SC-EXPLODE-INPROCESS")
 FREE RECORD dsce_root_tables
 RECORD dsce_root_tables(
   1 root_cnt = i4
   1 qual[*]
     2 table_name = vc
     2 root_ind = i2
     2 processed_root_recs = i4
     2 finished = i2
 )
 FREE RECORD dsce_rows
 RECORD dsce_rows(
   1 current_cnt = i4
   1 total_cnt = i4
 )
 FREE RECORD dsce_environment
 RECORD dsce_environment(
   1 source_env = f8
   1 qual[*]
     2 target_env = f8
 )
 FREE RECORD dsce_dcl_rows
 RECORD dsce_dcl_rows(
   1 qual[*]
     2 parent_table_name = vc
     2 target_env_id = f8
     2 updt_id = i4
     2 updt_task = i4
     2 updt_applctx = i4
     2 context_name = vc
     2 pk_where = vc
     2 dblink = vc
     2 commit_ind = i2
     2 log_type = vc
     2 log_id = f8
     2 ctxt_ind = i2
 )
 FREE RECORD dsce_child_tabs
 RECORD dsce_child_tabs(
   1 qual[*]
     2 table_name = vc
     2 table_suffix = vc
 )
 FREE RECORD dsce_drop_trgs
 RECORD dsce_drop_trgs(
   1 qual[*]
     2 tnmae = vc
 )
 FREE RECORD dsce_drop_proc
 RECORD dsce_drop_proc(
   1 qual[*]
     2 pname = vc
 )
 FREE RECORD dsce_reply
 RECORD dsce_reply(
   1 status = vc
   1 message = vc
 )
 FREE RECORD my_err
 RECORD my_err(
   1 err_ind = i2
 )
 FREE RECORD invalid_local
 RECORD invalid_local(
   1 data[*]
     2 name = vc
 )
 DECLARE trigger_error_cleanup(null) = null
 DECLARE insert_dcla(dcla_table=vc,dcla_msg=vc) = null
 DECLARE is_error(null) = i4
 DECLARE cleanup_dead_sessions(null) = null
 DECLARE set_table_error(ste_table_name,ste_prefix_char,ste_eproc) = null
 DECLARE set_session_tbl(sst_table) = null
 IF (check_logfile("dm_sc_explode",".log","dm_sc_explode LOG")=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Single Commit Explode failed: Unable to Create Log File"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program_dsce
 ENDIF
 SET dm_err->eproc = "SC BACKFILL - find current environment"
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM dm_info a
  WHERE a.info_name="DM_ENV_ID"
   AND a.info_domain="DATA MANAGEMENT"
  DETAIL
   dsce_environment->source_env = a.info_number
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  SET dm_err->emsg = "Error finding current environment"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program_dsce
 ENDIF
 SELECT INTO "nl:"
  FROM dm_refchg_process drp
  WHERE drp.refchg_type="DCL Version Backfill"
   AND drp.rdbhandle_value IN (
  (SELECT
   gv.audsid
   FROM gv$session gv))
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  SET dm_err->emsg = "Error selecting from dm_refchg_process."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program_dsce
 ENDIF
 IF (curqual > 0)
  SET dm_err->emsg =
  "The DCL Version Backfill is running, it must finish running before the explode can run."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program_dsce
 ELSE
  CALL add_tracking_row(dsce_environment->source_env,"SC Explode","Process")
 ENDIF
 SET dm_err->eproc = "SC BACKFILL - find target environment for source"
 CALL disp_msg(" ",dm_err->logfile,0)
 SET rs_cnt = 0
 SELECT INTO "nl:"
  FROM dm_env_reltn der
  WHERE (der.parent_env_id=dsce_environment->source_env)
   AND der.relationship_type="REFERENCE MERGE"
  DETAIL
   rs_cnt = (rs_cnt+ 1), stat = alterlist(dsce_environment->qual,rs_cnt), dsce_environment->qual[
   rs_cnt].target_env = der.child_env_id
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  SET dm_err->emsg = "Error finding target environments"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program_dsce
 ENDIF
 SET dm_err->eproc = "SC BACKFILL - Check for Open Event"
 CALL disp_msg(" ",dm_err->logfile,0)
 SET dsce_return = check_open_event(dsce_environment->source_env,0.0)
 IF (dsce_return != 1)
  SET dm_err->emsg =
  "There is no open event. An open event is required to run the single commit backfill"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program_dsce
 ENDIF
 SELECT INTO "nl:"
  FROM dm_refchg_tab_r drtr
  WHERE findstring(tbl_complete,drtr.parent_table) != 1
   AND findstring(tbl_complete,drtr.child_table) != 1
  WITH nocounter, maxqual(drtr,1)
 ;end select
 IF (check_error(dm_err->eproc)=1)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Error checking for un-exploded tables."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program_dsce
 ENDIF
 IF (curqual=0)
  SET dm_err->eproc =
  "All tables are already marked as exploded.  Writting single commit explode done row."
  CALL disp_msg("",dm_err->logfile,0)
  SET stat = alterlist(auto_ver_request->qual,1)
  SET auto_ver_request->qual[1].rdds_event = "End Single Commit Backfill"
  SET auto_ver_request->qual[1].cur_environment_id = dsce_environment->source_env
  SET auto_ver_request->qual[1].event_reason = ""
  EXECUTE dm_rmc_auto_verify_setup
  IF ((auto_ver_reply->status="F"))
   ROLLBACK
   SET dm_err->err_ind = 1
   SET dm_err->eproc = "Error inserting 'End Single commit Backfill' into dm_rdds_event_log"
   SET dm_err->emsg = auto_ver_reply->status_msg
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program_dsce
  ENDIF
  COMMIT
  CALL delete_tracking_row(null)
  GO TO exit_program_dsce_end
 ENDIF
 UPDATE  FROM dm_refchg_tab_r drtr
  SET drtr.parent_table = replace(drtr.parent_table,tbl_failed,tbl_ready_to_process), drtr
   .child_table = replace(drtr.child_table,tbl_failed,tbl_ready_to_process)
  WHERE findstring(tbl_failed,drtr.parent_table)=1
   AND findstring(tbl_failed,drtr.child_table)=1
  WITH nocounter
 ;end update
 IF (check_error(dm_err->eproc)=1)
  SET dm_err->emsg = "Error updating tables from error status to masked status."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program_dsce
 ENDIF
 COMMIT
 SET dsce_sc_cnt = 0
 SELECT DISTINCT INTO "NL:"
  drtr.child_table
  FROM dm_refchg_tab_r drtr
  WHERE 1=1
  ORDER BY drtr.child_table
  DETAIL
   dsce_sc_cnt = (dsce_sc_cnt+ 1), stat = alterlist(dsce_child_tabs->qual,dsce_sc_cnt),
   dsce_child_tabs->qual[dsce_sc_cnt].table_name = replace(replace(replace(drtr.child_table,
      tbl_ready_to_process,""),tbl_processing,""),tbl_complete,"")
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  SET dm_err->emsg = "Error getting a list of all child tables in single commit."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program_dsce
 ENDIF
 SELECT INTO "NL:"
  dcd.table_suffix
  FROM dm_tables_doc dcd
  WHERE expand(root_ndx1,1,size(dsce_child_tabs->qual,5),dcd.table_name,dsce_child_tabs->qual[
   root_ndx1].table_name)
  DETAIL
   dsce_idx = locateval(dsce_idx1,1,size(dsce_child_tabs->qual,5),dcd.table_name,dsce_child_tabs->
    qual[dsce_idx1].table_name), dsce_child_tabs->qual[dsce_idx].table_suffix = concat("REFCHG",dcd
    .table_suffix)
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  SET dm_err->emsg = "Error getting a list of all child table suffixes in single commit."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program_dsce
 ENDIF
 SET dm_err->eproc = "SC BACKFILL - Mask DM_REFCHG_TAB_R parent_table and child_table columns"
 CALL disp_msg(" ",dm_err->logfile,0)
 SET dsce_pause_ind = 1
 SET dsce_wait_time = 0
 WHILE (dsce_pause_ind=1)
   SET dsce_pause_ind = 0
   SELECT INTO "NL:"
    FROM dm_info d
    WHERE d.info_domain="SINGLE COMMIT EXPLODE"
     AND d.info_name="MASTER LOCK"
    DETAIL
     dsce_rdbhandle = d.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->emsg = "Error checking for trigger regen lock"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
   IF (curqual > 0)
    SELECT INTO "NL:"
     FROM gv$session gv
     WHERE gv.audsid=dsce_rdbhandle
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->emsg = "Error checking for trigger regen lock"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program_dsce
    ENDIF
    IF (curqual=0)
     DELETE  FROM dm_info
      WHERE info_domain="SINGLE COMMIT EXPLODE"
       AND info_name="MASTER LOCK"
      WITH nocounter
     ;end delete
     IF (check_error(dm_err->eproc)=1)
      SET dm_err->emsg = "Error checking for trigger regen lock"
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program_dsce
     ENDIF
     COMMIT
     SET dsce_pause_ind = 1
    ELSE
     SET dsce_wait_time = (dsce_wait_time+ 1)
     IF (dsce_wait_time=120)
      SET dm_err->emsg =
      "2 hours has elasped another process is regenerating triggers, now exiting please try again later"
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program_dsce
     ELSE
      SET dsce_pause_ind = 1
      CALL disp_msg(
       "****Another SC Explode process is regenerating triggers. Wait 60 secs try again.****",dm_err
       ->logfile,1)
      CALL pause(60)
     ENDIF
    ENDIF
   ELSE
    INSERT  FROM dm_info
     SET info_domain = "SINGLE COMMIT EXPLODE", info_name = "MASTER LOCK", info_number = cnvtreal(
       currdbhandle)
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->emsg = "Error checking for trigger regen lock"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program_dsce
    ENDIF
    COMMIT
    UPDATE  FROM dm_refchg_tab_r drtr
     SET drtr.parent_table = concat(tbl_ready_to_process,drtr.parent_table), drtr.child_table =
      concat(tbl_ready_to_process,drtr.child_table)
     WHERE findstring(tbl_ready_to_process,drtr.parent_table) != 1
      AND findstring(tbl_processing,drtr.parent_table) != 1
      AND findstring(tbl_complete,drtr.parent_table) != 1
      AND findstring(tbl_failed,drtr.parent_table) != 1
      AND findstring(tbl_ready_to_process,drtr.child_table) != 1
      AND findstring(tbl_processing,drtr.child_table) != 1
      AND findstring(tbl_complete,drtr.child_table) != 1
      AND findstring(tbl_failed,drtr.child_table) != 1
     WITH nocounter, forupdatewait(drtr)
    ;end update
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->emsg = "Error querying dm_refchg_tab_r"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program_dsce
    ENDIF
    IF (curqual > 0)
     COMMIT
     SET dm_err->eproc = "SC BACKFILL - Regenerating RDDS triggers"
     CALL disp_msg(" ",dm_err->logfile,0)
     EXECUTE dm2_add_old_dcl_triggers "*", "REFCHG"
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
        stat = alterlist(invalid_local->data,(trig_cnt+ 9))
       ENDIF
       invalid_local->data[trig_cnt].name = d1.object_name
      FOOT REPORT
       stat = alterlist(invalid_local->data,trig_cnt)
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      SET dm_err->emsg = "Error checking invalid triggers"
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      CALL trigger_error_cleanup(null)
      GO TO exit_program_dsce
     ENDIF
     FOR (t_ndx = 1 TO size(invalid_local->data,5))
       CALL parser(concat("RDB ASIS(^alter trigger ",invalid_local->data[t_ndx].name," compile^) go")
        )
     ENDFOR
     SELECT INTO "NL:"
      FROM dm2_user_objects d1
      WHERE d1.object_name="REFCHG*"
       AND d1.object_type="TRIGGER"
       AND d1.status != "VALID"
       AND d1.object_name != "REFCHG*MC*"
      WITH nocounter, maxqual(d1,1)
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      SET dm_err->emsg = "Error compiling invalid triggers"
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      CALL trigger_error_cleanup(null)
      GO TO exit_program_dsce
     ENDIF
     IF (curqual=0)
      SET dm_err->eproc = "Triggers regenerated successfully."
      SET dsce_return = 0
     ELSE
      SET dm_err->eproc = "Error regenerating RDDS related triggers."
      SET dsce_return = 1
     ENDIF
     IF (dsce_return=1)
      CALL trigger_error_cleanup(null)
      GO TO exit_program_dsce
     ENDIF
     IF (size(dsce_child_tabs->qual,5) > 0)
      SET dm_err->eproc = "SC BACKFILL - Dropping single commit triggers and procedures"
      CALL disp_msg(" ",dm_err->logfile,0)
      SELECT INTO "NL:"
       ut.trigger_name
       FROM user_triggers ut,
        (dummyt dt  WITH seq = size(dsce_child_tabs->qual,5))
       PLAN (ut)
        JOIN (dt
        WHERE ut.triggering_event="INSERT OR UPDATE OR DELETE"
         AND (ut.table_name=dsce_child_tabs->qual[dt.seq].table_name)
         AND (ut.trigger_name=dsce_child_tabs->qual[dt.seq].table_suffix))
       DETAIL
        dsce_trg_cnt = (dsce_trg_cnt+ 1), stat = alterlist(dsce_drop_trgs->qual,dsce_trg_cnt),
        dsce_drop_trgs->qual[dsce_trg_cnt].tnmae = ut.trigger_name
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       SET dm_err->emsg = "Error querying user_triggers"
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       CALL trigger_error_cleanup(null)
       GO TO exit_program_dsce
      ENDIF
      FOR (dsce_trg_cnt = 1 TO size(dsce_drop_trgs->qual,5))
       CALL parser(concat("rdb drop trigger ",dsce_drop_trgs->qual[dsce_trg_cnt].tnmae," go"),1)
       IF (check_error(dm_err->eproc)=1)
        SET dm_err->emsg = concat("Error dropping trigger ",dsce_drop_trgs->qual[dsce_trg_cnt].tnmae)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        CALL trigger_error_cleanup(null)
        GO TO exit_program_dsce
       ENDIF
      ENDFOR
     ENDIF
     SET dsce_trg_cnt = 0
     SELECT INTO "NL:"
      uo.object_name
      FROM user_objects uo
      WHERE uo.object_type="PROCEDURE"
       AND uo.object_name IN ("PROC_REFCHG*_1", "PROC_REFCHG*_2")
      DETAIL
       dsce_trg_cnt = (dsce_trg_cnt+ 1), stat = alterlist(dsce_drop_proc->qual,dsce_trg_cnt),
       dsce_drop_proc->qual[dsce_trg_cnt].pname = uo.object_name
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      SET dm_err->emsg = "Error querying user_objects"
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      CALL trigger_error_cleanup(null)
      GO TO exit_program_dsce
     ENDIF
     FOR (dsce_trg_cnt = 1 TO size(dsce_drop_proc->qual,5))
      CALL parser(concat("rdb drop procedure ",dsce_drop_proc->qual[dsce_trg_cnt].pname," go"),1)
      IF (check_error(dm_err->eproc)=1)
       SET dm_err->emsg = concat("Error dropping procedure ",dsce_drop_proc->qual[dsce_trg_cnt].pname
        )
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       CALL trigger_error_cleanup(null)
       GO TO exit_program_dsce
      ENDIF
     ENDFOR
     DELETE  FROM dm_info
      WHERE info_domain="SINGLE COMMIT EXPLODE"
       AND info_name="MASTER LOCK"
      WITH nocounter
     ;end delete
     IF (check_error(dm_err->eproc)=1)
      SET dm_err->emsg = concat("Error removing trigger lock dm_info row.")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      CALL trigger_error_cleanup(null)
      GO TO exit_program_dsce
     ENDIF
     COMMIT
    ELSE
     DELETE  FROM dm_info
      WHERE info_domain="SINGLE COMMIT EXPLODE"
       AND info_name="MASTER LOCK"
      WITH nocounter
     ;end delete
     IF (check_error(dm_err->eproc)=1)
      SET dm_err->emsg = concat("Error deleting dm_info row")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program_dsce
     ENDIF
     COMMIT
    ENDIF
   ENDIF
 ENDWHILE
 SET dm_err->eproc = "SC BACKFILL - Find the highest dm_chg_log.log_id"
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "NL:"
  FROM dm_info d
  WHERE d.info_domain="DM RDDS DCL MAX LOG ID"
   AND d.info_name="EXPLODE LIMIT"
  DETAIL
   dsce_explode_limit = d.info_number
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  SET dm_err->emsg = "Error querying dm_info for explode limit"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program_dsce
 ENDIF
 IF (curqual=0)
  SELECT INTO "NL:"
   y = seq(dm_clinical_seq,nextval)
   FROM dual
   DETAIL
    dsce_explode_limit = y
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   SET dm_err->emsg = "Error finding explode limit into DM_INFO"
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program_dsce
  ENDIF
  INSERT  FROM dm_info
   SET info_domain = "DM RDDS DCL MAX LOG ID", info_name = "EXPLODE LIMIT", info_number =
    dsce_explode_limit
   WITH nocounter
  ;end insert
  IF (check_error(dm_err->eproc)=1)
   SET dm_err->emsg = "Error inserting explode limit into DM_INFO"
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program_dsce
  ENDIF
  COMMIT
 ENDIF
 SET dm_err->eproc = "SC BACKFILL - Find the single commit explode backfill batch size"
 SELECT INTO "NL:"
  d.info_number
  FROM dm_info d
  WHERE info_domain="DM_RDDS_SC_BACKFILL"
   AND info_name="BATCH SIZE"
  DETAIL
   dsce_batch_size = d.info_number
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  SET dm_err->emsg = "Error querying dm_info"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program_dsce
 ENDIF
 IF (curqual=0)
  INSERT  FROM dm_info
   SET info_domain = "DM_RDDS_SC_BACKFILL", info_name = "BATCH SIZE", info_number = 500
   WITH nocounter
  ;end insert
  IF (check_error(dm_err->eproc)=1)
   SET dm_err->emsg = "Error inserting batch size into DM_INFO"
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program_dsce
  ENDIF
  COMMIT
  SET dsce_batch_size = 500
 ENDIF
 SELECT DISTINCT INTO "NL:"
  drtr.parent_table
  FROM dm_refchg_tab_r drtr
  WHERE drtr.process_type != "MOVER ONLY"
  ORDER BY substring(2,30,drtr.parent_table)
  DETAIL
   dsce_t_cnt = (dsce_t_cnt+ 1), stat = alterlist(dsce_root_tables->qual,dsce_t_cnt),
   dsce_root_tables->qual[dsce_t_cnt].table_name = replace(drtr.parent_table,tbl_ready_to_process,""),
   dsce_root_tables->qual[dsce_t_cnt].table_name = replace(dsce_root_tables->qual[dsce_t_cnt].
    table_name,tbl_complete,""), dsce_root_tables->qual[dsce_t_cnt].table_name = replace(
    dsce_root_tables->qual[dsce_t_cnt].table_name,tbl_processing,""), dsce_root_tables->qual[
   dsce_t_cnt].root_ind = 1
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  SET dm_err->emsg = "Error marking non-root level tables in dm_refcht_tab_r"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program_dsce
 ENDIF
 SET dsce_root_tables->root_cnt = dsce_t_cnt
 IF (size(dsce_root_tables->qual,5) > 0)
  SELECT INTO "NL:"
   drtr.parent_table
   FROM dm_refchg_tab_r drtr,
    (dummyt d  WITH seq = size(dsce_root_tables->qual,5))
   PLAN (drtr)
    JOIN (d
    WHERE drtr.process_type != "MOVER ONLY"
     AND ((drtr.child_table=concat(tbl_ready_to_process,dsce_root_tables->qual[d.seq].table_name))
     OR (((drtr.child_table=concat(tbl_processing,dsce_root_tables->qual[d.seq].table_name)) OR (((
    drtr.child_table=concat(tbl_complete,dsce_root_tables->qual[d.seq].table_name)) OR (drtr
    .child_table=concat(tbl_failed,dsce_root_tables->qual[d.seq].table_name))) )) )) )
   DETAIL
    dsce_root_tables->qual[d.seq].root_ind = 0, dsce_root_tables->root_cnt = (dsce_root_tables->
    root_cnt - 1)
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   SET dm_err->emsg = "Error marking non-root level tables in dm_refchg_tab_r"
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program_dsce
  ENDIF
 ENDIF
 CALL cleanup_dead_sessions(null)
 SELECT INTO "NL:"
  FROM dm_refchg_tab_r drtr,
   (dummyt dt  WITH seq = size(dsce_root_tables->qual,5))
  PLAN (drtr)
   JOIN (dt
   WHERE drtr.parent_table=concat(tbl_ready_to_process,dsce_root_tables->qual[dt.seq].table_name)
    AND (dsce_root_tables->qual[dt.seq].root_ind=1)
    AND drtr.process_type != "MOVER ONLY")
  DETAIL
   dsce_rows_left = (dsce_rows_left+ 1)
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  SET dm_err->eproc = "Finding next table to process"
  CALL set_table_error(dsce_tname,tbl_ready_to_process,dm_err->eproc)
 ENDIF
 WHILE (dsce_rows_left > 0)
  SET dsce_i = 1
  FOR (dsce_i = 1 TO size(dsce_root_tables->qual,5))
    IF ((dsce_root_tables->qual[dsce_i].root_ind=1))
     SET dm_err->eproc = concat("SC BACKFILL - ",dsce_root_tables->qual[dsce_i].table_name)
     CALL disp_msg(" ",dm_err->logfile,0)
     SET my_err->err_ind = 0
     UPDATE  FROM dm_refchg_tab_r drtr
      SET drtr.parent_table = replace(drtr.parent_table,tbl_ready_to_process,tbl_processing), drtr
       .child_table = replace(drtr.child_table,tbl_ready_to_process,tbl_processing)
      WHERE drtr.parent_table=concat(tbl_ready_to_process,dsce_root_tables->qual[dsce_i].table_name)
      WITH nocounter, forupdatewait(drtr)
     ;end update
     IF (curqual > 0)
      COMMIT
      SET dsce_tname = dsce_root_tables->qual[dsce_i].table_name
      CALL set_session_tbl(dsce_tname)
      IF ((my_err->err_ind=0))
       SET dsce_rows->current_cnt = 0
       SET dsce_batch_loop = 0
       UPDATE  FROM dm_refchg_tab_r drtr
        SET drtr.parent_table = replace(drtr.parent_table,tbl_ready_to_process,tbl_processing), drtr
         .child_table = replace(drtr.child_table,tbl_ready_to_process,tbl_processing)
        WHERE drtr.parent_table=concat(tbl_ready_to_process,dsce_tname)
        WITH nocounter
       ;end update
       IF (check_error(dm_err->eproc)=1)
        SET dm_err->eproc = concat("Error updating next table ",dsce_tname," to process state")
        CALL set_table_error(dsce_tname,tbl_ready_to_process,dm_err->eproc)
       ENDIF
       COMMIT
       IF ((my_err->err_ind=0))
        SELECT INTO "NL:"
         x = count(*)
         FROM dm_chg_log dcl
         WHERE dcl.table_name=dsce_tname
          AND expand(dsce_tgt_cnt,1,size(dsce_environment->qual,5),(dcl.target_env_id+ 0),
          dsce_environment->qual[dsce_tgt_cnt].target_env)
          AND dcl.log_type IN ("REFCHG", "MERGED", "NORDDS")
          AND dcl.delete_ind=0
          AND dcl.updt_applctx != 4310001
          AND dcl.log_id < dsce_explode_limit
         DETAIL
          dsce_rows->total_cnt = x
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         SET dm_err->eproc = concat("Error getting count of ",dsce_tname," rows from the dm_chg_log")
         CALL set_table_error(dsce_tname,tbl_processing,dm_err->eproc)
        ENDIF
       ENDIF
       WHILE (dsce_batch_loop=0
        AND (my_err->err_ind=0))
         SET dcl_cnt = 0
         SELECT INTO "NL:"
          dcl.pk_where, dcl.log_type, dcl.context_name,
          dcl.target_env_id, y = nullind(dcl.context_name)
          FROM dm_chg_log dcl
          WHERE dcl.table_name=dsce_tname
           AND expand(dsce_tgt_cnt,1,size(dsce_environment->qual,5),(dcl.target_env_id+ 0),
           dsce_environment->qual[dsce_tgt_cnt].target_env)
           AND dcl.log_type IN ("REFCHG", "MERGED", "NORDDS")
           AND dcl.delete_ind=0
           AND dcl.updt_applctx != 4310001.0
           AND dcl.log_id < dsce_explode_limit
          ORDER BY dcl.target_env_id, dcl.context_name, dcl.log_type,
           dcl.pk_where
          HEAD dcl.pk_where
           dcl_cnt = (dcl_cnt+ 1), stat = alterlist(dsce_dcl_rows->qual,dcl_cnt), dsce_dcl_rows->
           qual[dcl_cnt].parent_table_name = dcl.table_name,
           dsce_dcl_rows->qual[dcl_cnt].target_env_id = dcl.target_env_id, dsce_dcl_rows->qual[
           dcl_cnt].updt_id = dcl.updt_id, dsce_dcl_rows->qual[dcl_cnt].updt_task = dcl.updt_task,
           dsce_dcl_rows->qual[dcl_cnt].updt_applctx = dcl.updt_applctx, dsce_dcl_rows->qual[dcl_cnt]
           .ctxt_ind = y, dsce_dcl_rows->qual[dcl_cnt].context_name = dcl.context_name,
           dsce_dcl_rows->qual[dcl_cnt].pk_where = dcl.pk_where, dsce_dcl_rows->qual[dcl_cnt].
           log_type = dcl.log_type, dsce_dcl_rows->qual[dcl_cnt].commit_ind = 1,
           dsce_dcl_rows->qual[dcl_cnt].dblink = ""
          WITH maxrec = value(dsce_batch_size)
         ;end select
         SET dsce_dcl_curqual = dcl_cnt
         IF (check_error(dm_err->eproc)=1)
          SET dm_err->eproc = concat("Error getting batch of ",dsce_tname," rows from the dm_chg_log"
           )
          CALL set_table_error(dsce_tname,tbl_processing,dm_err->eproc)
         ENDIF
         IF (dsce_dcl_curqual=0
          AND (my_err->err_ind=0))
          SET dsce_batch_loop = 1
          UPDATE  FROM dm_refchg_tab_r drtr
           SET drtr.parent_table = replace(drtr.parent_table,tbl_processing,tbl_complete), drtr
            .child_table = replace(drtr.child_table,tbl_processing,tbl_complete)
           WHERE drtr.parent_table=concat(tbl_processing,dsce_tname)
           WITH nocounter
          ;end update
          IF (check_error(dm_err->eproc)=1)
           SET dm_err->eproc = concat("Error updating ",dsce_tname,
            " to finished status in DM_REFCHG_TAB_R ")
           CALL set_table_error(dsce_tname,tbl_processing,dm_err->eproc)
          ELSE
           COMMIT
          ENDIF
          SET dsce_processed_tbl_cnt = 0
          IF ((my_err->err_ind=0))
           SELECT DISTINCT INTO "NL:"
            drtr.parent_table
            FROM dm_refchg_tab_r drtr
            WHERE findstring(tbl_complete,drtr.parent_table)=1
             AND process_type != "MOVER ONLY"
             AND  NOT (drtr.parent_table IN (
            (SELECT
             d.child_table
             FROM dm_refchg_tab_r d
             WHERE d.process_type != "MOVER ONLY")))
            WITH nocounter
           ;end select
           IF (check_error(dm_err->eproc)=1)
            SET dm_err->eproc = "Error determining number of root tables processed"
            CALL set_table_error(dsce_tname,tbl_complete,dm_err->eproc)
           ELSE
            SET dsce_processed_tbl_cnt = curqual
            SET dsce_msg = concat("Root table ",trim(cnvtstring(dsce_processed_tbl_cnt))," of ",trim(
              cnvtstring(dsce_root_tables->root_cnt))," has been processed")
            CALL insert_dcla(dsce_tname,dsce_msg)
            IF (check_error(dm_err->eproc)=1)
             SET dm_err->eproc = "Error determining number of root tables processed"
             CALL set_table_error(dsce_tname,tbl_complete,dm_err->eproc)
            ENDIF
           ENDIF
          ENDIF
          IF ((dsce_processed_tbl_cnt=dsce_root_tables->root_cnt)
           AND (my_err->err_ind=0))
           UPDATE  FROM dm_refchg_tab_r drtr
            SET drtr.parent_table = replace(replace(drtr.parent_table,tbl_processing,tbl_complete),
              tbl_ready_to_process,tbl_complete), drtr.child_table = replace(replace(drtr.child_table,
               tbl_processing,tbl_complete),tbl_ready_to_process,tbl_complete)
            WHERE ((findstring(tbl_ready_to_process,drtr.parent_table)=1) OR (findstring(
             tbl_processing,drtr.parent_table)=1))
            WITH nocounter
           ;end update
           IF (check_error(dm_err->eproc)=1)
            SET dm_err->eproc = "Updating remaining tables to a finished status."
            CALL set_table_error(dsce_tname,tbl_complete,dm_err->eproc)
           ELSE
            COMMIT
           ENDIF
           IF ((my_err->err_ind=0))
            SET stat = alterlist(auto_ver_request->qual,1)
            SET auto_ver_request->qual[1].rdds_event = "End Single Commit Backfill"
            SET auto_ver_request->qual[1].cur_environment_id = dsce_environment->source_env
            SET auto_ver_request->qual[1].event_reason = ""
            EXECUTE dm_rmc_auto_verify_setup
            IF ((auto_ver_reply->status="F"))
             ROLLBACK
             SET dm_err->eproc =
             "Error inserting 'End Single Commit Backfill' into dm_rdds_event_log"
             SET dm_err->emsg = auto_ver_reply->status_msg
             CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
             UPDATE  FROM dm_refchg_tab_r drtr
              SET drtr.parent_table = replace(drtr.parent_table,tbl_complete,tbl_failed), drtr
               .child_table = replace(drtr.child_table,tbl_complete,tbl_failed)
              WHERE drtr.parent_table=concat(tbl_complete,dsce_tname)
              WITH nocounter
             ;end update
             IF (check_error(dm_err->eproc)=1)
              SET dm_err->eproc =
              "ERROR: Updating table to error status, Explode may have terminated incorrectly"
              CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
              GO TO exit_program_dsce
             ENDIF
             COMMIT
            ELSE
             SELECT INTO "NL:"
              FROM dm_rdds_event_log el
              WHERE el.rdds_event_key="ENDSINGLECOMMITBACKFILL"
               AND (el.cur_environment_id=dsce_environment->source_env)
              WITH nocounter
             ;end select
             IF (check_error(dm_err->eproc)=1)
              ROLLBACK
              SET dm_err->eproc =
              "WARNING: Checking for dm_rdds_event_log_row, Explode may have terminated incorrectly"
              CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
              UPDATE  FROM dm_refchg_tab_r drtr
               SET drtr.parent_table = replace(drtr.parent_table,tbl_complete,tbl_failed), drtr
                .child_table = replace(drtr.child_table,tbl_complete,tbl_failed)
               WHERE drtr.parent_table=concat(tbl_complete,dsce_tname)
               WITH nocounter
              ;end update
              IF (check_error(dm_err->eproc)=1)
               SET dm_err->eproc = "WARNING: Explode may not have finished successfully"
               CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
              ENDIF
              COMMIT
              GO TO exit_program_dsce
             ELSEIF (curqual=0)
              ROLLBACK
              SET dm_err->eproc =
              "WARNING: Explode did not write END EVENT rows to dm_rdds_event_log"
              CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
              UPDATE  FROM dm_refchg_tab_r drtr
               SET drtr.parent_table = replace(drtr.parent_table,tbl_complete,tbl_failed), drtr
                .child_table = replace(drtr.child_table,tbl_complete,tbl_failed)
               WHERE drtr.parent_table=concat(tbl_complete,dsce_tname)
               WITH nocounter
              ;end update
              IF (check_error(dm_err->eproc)=1)
               SET dm_err->eproc =
               "WARNING: Explode may not have finished, unable to update previous table to ERROR state"
               CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
              ENDIF
              COMMIT
              GO TO exit_program_dsce
             ENDIF
            ENDIF
            COMMIT
           ENDIF
          ENDIF
         ELSE
          IF ((my_err->err_ind=0))
           IF (checkprg(cnvtupper("dm_rdds_explode_parent_dcl"))=0)
            SET dm_err->eproc = "The object for DM_RDDS_EXPLODE_PARENT_DCL does not exist"
            CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
            GO TO exit_program_dsce
           ENDIF
           EXECUTE dm_rdds_explode_parent_dcl  WITH replace("REQUEST","DSCE_DCL_ROWS"), replace(
            "REPLY","DSCE_REPLY"), replace("REQUEST_ROWS","DSCE_ROWS")
           IF ((dsce_reply->status != "S"))
            ROLLBACK
            CALL set_table_error(dsce_tname,tbl_processing,tbl_failed)
           ENDIF
          ENDIF
         ENDIF
       ENDWHILE
      ENDIF
     ENDIF
    ENDIF
    CALL del_my_session_tbl(dsce_root_tables->qual[dsce_i].table_name)
    CALL cleanup_dead_sessions(null)
    SET dsce_rows_left = 0
    SELECT INTO "NL:"
     FROM dm_refchg_tab_r drtr,
      (dummyt dt  WITH seq = size(dsce_root_tables->qual,5))
     PLAN (drtr)
      JOIN (dt
      WHERE drtr.parent_table=concat(tbl_ready_to_process,dsce_root_tables->qual[dt.seq].table_name)
       AND (dsce_root_tables->qual[dt.seq].root_ind=1)
       AND drtr.process_type != "MOVER ONLY")
     DETAIL
      dsce_rows_left = (dsce_rows_left+ 1)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->eproc = "Finding if tables to process remain"
     CALL set_table_error(dsce_root_tables->qual[dsce_i].table_name,tbl_ready_to_process,dm_err->
      eproc)
    ENDIF
  ENDFOR
 ENDWHILE
 SUBROUTINE trigger_error_cleanup(null)
   SET dm_err->emsg = "Error occurred during regenerating triggers procedure"
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   UPDATE  FROM dm_refchg_tab_r drtr
    SET drtr.parent_table = replace(drtr.parent_table,tbl_ready_to_process,""), drtr.child_table =
     replace(drtr.child_table,tbl_ready_to_process,"")
    WHERE findstring(tbl_ready_to_process,drtr.parent_table)=1
     AND findstring(tbl_ready_to_process,drtr.child_table)=1
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->eproc = "Error unmasking dm_refchg_tab_r"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program_dsce
   ELSE
    COMMIT
   ENDIF
   DELETE  FROM dm_info
    WHERE info_domain="SINGLE COMMIT EXPLODE"
     AND info_name="MASTER LOCK"
    WITH nocounter
   ;end delete
   COMMIT
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->eproc = "Error removing locking dm_info row for single commit explode"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program_dsce
   ELSE
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE is_error(null)
  IF (((findstring("ORA-01652",dm_err->emsg) > 0) OR (((findstring("ORA-01653",dm_err->emsg) > 0) OR
  (((findstring("ORA-01654",dm_err->emsg) > 0) OR (((findstring("ORA-01630",dm_err->emsg) > 0) OR (((
  findstring("ORA-01631",dm_err->emsg) > 0) OR (findstring("ORA-01632",dm_err->emsg) > 0)) )) )) ))
  )) )
   SET dm_err->eproc =
   "Oracle error occured: unable to extend table space or # max extents were reached"
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  ELSE
   SET dm_err->err_ind = 0
   SET my_err->err_ind = 1
  ENDIF
  RETURN(dm_err->err_ind)
 END ;Subroutine
 SUBROUTINE cleanup_dead_sessions(null)
   DECLARE dead_rs_cnt = i4
   DECLARE dead_for_cnt = i4
   FREE RECORD dead_sessions
   RECORD dead_sessions(
     1 qual[*]
       2 rdbhandle = f8
       2 really_dead = i2
       2 table_name = vc
   )
   SELECT INTO "NL:"
    info_number
    FROM dm_info di
    WHERE di.info_domain=dsce_info_domain
     AND  NOT (di.info_number IN (
    (SELECT
     gv.audsid
     FROM gv$session gv)))
    DETAIL
     dead_rs_cnt = (dead_rs_cnt+ 1), stat = alterlist(dead_sessions->qual,dead_rs_cnt), dead_sessions
     ->qual[dead_rs_cnt].rdbhandle = di.info_number,
     dead_sessions->qual[dead_rs_cnt].really_dead = 1, dead_sessions->qual[dead_rs_cnt].table_name =
     di.info_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->eproc = "Error finding tables stuck in processing state"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program_dsce
   ENDIF
   IF (curqual > 0)
    SELECT INTO "NL:"
     FROM v$session vs,
      (dummyt dt  WITH seq = size(dead_sessions->qual,5))
     PLAN (dt)
      JOIN (vs
      WHERE (vs.audsid=dead_sessions->qual[dt.seq].rdbhandle))
     DETAIL
      dead_sessions->qual[dead_rs_cnt].really_dead = 0
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->eproc = "Verifying if session is active"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program_dsce
    ENDIF
   ENDIF
   FOR (dead_for_cnt = 1 TO size(dead_sessions->qual,5))
     IF ((dead_sessions->qual[dead_for_cnt].really_dead=1))
      UPDATE  FROM dm_refchg_tab_r drtr
       SET drtr.parent_table = replace(drtr.parent_table,tbl_processing,tbl_ready_to_process), drtr
        .child_table = replace(drtr.child_table,tbl_processing,tbl_ready_to_process)
       WHERE drtr.parent_table=concat(tbl_processing,dead_sessions->qual[dead_for_cnt].table_name)
       WITH nocounter
      ;end update
      IF (check_error(dm_err->eproc)=1)
       SET dm_err->eproc = "Error updating tables stuck in processing state"
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_program_dsce
      ENDIF
      DELETE  FROM dm_info di
       WHERE di.info_domain=dsce_info_domain
        AND (di.info_name=dead_sessions->qual[dead_rs_cnt].table_name)
        AND (di.info_number=dead_sessions->qual[dead_rs_cnt].rdbhandle)
       WITH nocounter
      ;end delete
      IF (check_error(dm_err->eproc)=1)
       ROLLBACK
       SET dm_err->eproc = "Error deleting tables stuck in processing state"
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_program_dsce
      ELSE
       COMMIT
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE del_my_session_tbl(dms_tbl_name)
   IF (dms_tbl_name="NONE")
    DELETE  FROM dm_info di
     WHERE di.info_domain=dsce_info_domain
      AND di.info_number=cnvtreal(currdbhandle)
     WITH nocounter
    ;end delete
    IF (check_error(dm_err->emsg)=1)
     SET dm_err->eproc = "Error deleting current session information"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program_dsce_end
    ENDIF
   ELSE
    DELETE  FROM dm_info di
     WHERE di.info_domain=dsce_info_domain
      AND di.info_name=dms_tbl_name
      AND di.info_number=cnvtreal(currdbhandle)
     WITH nocounter
    ;end delete
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->eproc = "Error deleting current session tables"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program_dsce
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE set_session_tbl(sst_table)
  UPDATE  FROM dm_info di
   SET di.info_name = cnvtupper(sst_table)
   WHERE di.info_domain=dsce_info_domain
    AND di.info_number=cnvtreal(currdbhandle)
   WITH nocounter
  ;end update
  IF (check_error(dm_err->eproc)=1)
   SET dm_err->eproc = "Error setting session table."
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   CALL set_table_error(sst_table,tbl_processing,dm_err->eproc)
  ELSE
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_name = cnvtupper(sst_table), di.info_domain = dsce_info_domain, di.info_number =
      cnvtreal(currdbhandle)
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->eproc = "Error setting session table."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     CALL set_table_error(sst_table,tbl_processing,dm_err->eproc)
    ENDIF
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE set_table_error(ste_table_name,ste_prefix_char,ste_eproc)
   IF (is_error(null)=1)
    UPDATE  FROM dm_refchg_tab_r drtr
     SET drtr.parent_table = replace(drtr.parent_table,ste_prefix_char,tbl_failed), drtr.child_table
       = replace(drtr.child_table,ste_prefix_char,tbl_failed)
     WHERE drtr.parent_table=concat(ste_prefix_char,ste_table_name)
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->eproc = "Updating table to error status"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program_dsce
    ENDIF
    SET dm_err->eproc = ste_eproc
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program_dsce
   ELSEIF ((my_err->err_ind=1))
    UPDATE  FROM dm_refchg_tab_r drtr
     SET drtr.parent_table = replace(drtr.parent_table,ste_prefix_char,tbl_failed), drtr.child_table
       = replace(drtr.child_table,ste_prefix_char,tbl_failed)
     WHERE drtr.parent_table=concat(ste_prefix_char,ste_table_name)
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->eproc = "Updating table to error status"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program_dsce
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE insert_dcla(dcla_table,dcla_msg)
  SELECT INTO "NL:"
   y = seq(dm_merge_audit_seq,nextval)
   FROM dual
   DETAIL
    dsce_dcla_seq = y
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   SET dm_err->emsg = "Getting next value from DM_MERGE_AUDIT_SEQ"
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  ELSE
   UPDATE  FROM dm_chg_log_audit dcla
    SET dcla.dm_chg_log_audit_id = dsce_dcla_seq, dcla.log_id = 0, dcla.action = "CMIT BCKFL",
     dcla.table_name = dcla_table, dcla.text = dcla_msg, dcla.updt_task = 4310001,
     dcla.updt_cnt = 0, dcla.updt_dt_tm = cnvtdatetime(curdate,curtime3), dcla.updt_id = 0,
     dcla.updt_applctx = 0, audit_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE dcla.dm_chg_log_audit_id=dsce_dcla_seq
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->eproc = "Error updating explode status into dm_chg_log_audit"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
   IF (curqual=0)
    INSERT  FROM dm_chg_log_audit dcla
     SET dcla.dm_chg_log_audit_id = dsce_dcla_seq, dcla.log_id = 0, dcla.action = "CMIT BCKFL",
      dcla.table_name = dcla_table, dcla.text = dcla_msg, dcla.updt_task = 4310001,
      dcla.updt_cnt = 0, dcla.updt_dt_tm = cnvtdatetime(curdate,curtime3), dcla.updt_id = 0,
      dcla.updt_applctx = 0, audit_dt_tm = cnvtdatetime(curdate,curtime3)
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->eproc = "Error inserting explode status into dm_chg_log_audit"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ELSE
     COMMIT
    ENDIF
   ELSE
    COMMIT
   ENDIF
  ENDIF
 END ;Subroutine
#exit_program_dsce
 IF ((dm_err->err_ind=0))
  SET dsce_return = regen_trigs(null)
 ENDIF
 CALL delete_tracking_row(null)
 CALL del_my_session_tbl("NONE")
#exit_program_dsce_end
 CALL parser("free define oraclesystem go",1)
 SET message = nowindow
 SET dm_err->eproc = "DATABASE CONNECTION REMOVED. RE-ENTER CCL TO ESTABLISH NEW CONNECTION."
 CALL disp_msg("",dm_err->logfile,0)
END GO
