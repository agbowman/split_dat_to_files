CREATE PROGRAM dm2_gather_index_stats:dba
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
 IF ((validate(drd_min_est_pct,- (1.0))=- (1.0))
  AND (validate(drd_min_est_pct,- (2.0))=- (2.0)))
  DECLARE drd_min_est_pct = f8 WITH protect, constant(0.000001)
 ENDIF
 IF ((validate(table_stats->tbl_cnt,- (1))=- (1))
  AND (validate(table_stats->tbl_cnt,- (2))=- (2)))
  FREE RECORD table_stats
  RECORD table_stats(
    1 owner = vc
    1 table_name = vc
    1 gather_option = vc
    1 stale_pct_threshold = f8
    1 rows_to_sample = i4
    1 rows_to_sample_min = i4
    1 level = vc
    1 cascade = vc
    1 index_degree = i4
    1 table_degree = i4
    1 tbl_cnt = i4
    1 stats_cnt[*]
      2 owner = vc
      2 tabname = vc
      2 monitoring = vc
      2 global_stats = vc
      2 last_analyzed = dq8
      2 num_rows = f8
      2 table_mods = f8
      2 inserts = f8
      2 updates = f8
      2 deletes = f8
      2 last_mod_dt_tm = dq8
      2 mod_trunc_ind = i2
      2 stale_pct = f8
      2 stale_ind = i2
      2 est_pct = f8
      2 gather_ind = i2
      2 method_opt = vc
      2 block_sample = vc
      2 valid_tspace_ind = i2
      2 initial_gather_ind = i2
    1 stats_retry_cnt = i2
    1 stats_retry[*]
      2 object_type = vc
      2 object_name = vc
  )
  SET table_stats->index_degree = - (1)
  SET table_stats->table_degree = - (1)
  SET table_stats->rows_to_sample_min = 5000
  SET table_stats->rows_to_sample = 100000
 ENDIF
 IF ((validate(hist_columns->column_cnt,- (1))=- (1))
  AND (validate(hist_columns->column_cnt,- (2))=- (2)))
  FREE RECORD hist_columns
  RECORD hist_columns(
    1 column_cnt = i4
    1 columns[*]
      2 column_name = vc
      2 method_opt = vc
  )
 ENDIF
 IF ((validate(index_list->index_cnt,- (1))=- (1))
  AND (validate(index_list->index_cnt,- (2))=- (2)))
  FREE RECORD index_list
  RECORD index_list(
    1 index_cnt = i4
    1 est_pct = f8
    1 est_pct_override_ind = i2
    1 unique_est_pct = f8
    1 unique_est_pct_override_ind = i2
    1 owner = vc
    1 table_name = vc
    1 qual[*]
      2 index_name = vc
      2 unique_ind = i2
      2 est_pct = f8
  )
  SET index_list->est_pct = - (1.0)
  SET index_list->unique_est_pct = drd_min_est_pct
 ENDIF
 IF ((validate(table_override_list->cnt,- (1))=- (1))
  AND (validate(table_override_list->cnt,- (2))=- (2)))
  FREE RECORD table_override_list
  RECORD table_override_list(
    1 cnt = i4
    1 qual[*]
      2 owner = vc
      2 table_name = vc
      2 est_percent = f8
  )
 ENDIF
 IF ((validate(hist_list->table_cnt,- (1))=- (1))
  AND (validate(hist_list->table_cnt,- (2))=- (2)))
  FREE RECORD hist_list
  RECORD hist_list(
    1 table_cnt = i4
    1 table_list[*]
      2 table_name = vc
      2 column_cnt = i4
      2 column_list[*]
        3 column_name = vc
        3 method_opt = vc
  )
 ENDIF
 IF ((validate(low_pct_tables->tbl_cnt,- (1))=- (1))
  AND (validate(low_pct_tables->tbl_cnt,- (2))=- (2)))
  FREE RECORD low_pct_tables
  RECORD low_pct_tables(
    1 tbl_cnt = i4
    1 tbl_list[*]
      2 tbl_name = vc
      2 owner = vc
      2 own_tab_key = vc
  )
 ENDIF
 IF ((validate(index_override_list->index_cnt,- (1))=- (1))
  AND (validate(index_override_list->index_cnt,- (2))=- (2)))
  FREE RECORD index_override_list
  RECORD index_override_list(
    1 index_cnt = i4
    1 qual[*]
      2 owner = vc
      2 table_name = vc
      2 index_name = vc
      2 est_percent = f8
  )
 ENDIF
 DECLARE dri_fill_table_stats(null) = i2
 DECLARE dri_enable_table_monitoring(null) = null
 DECLARE dri_fill_index_list(dril_owner=vc,dril_table_name=vc) = i2
 DECLARE dri_get_ind_est_perc(null) = i2
 DECLARE dri_fill_regather_list(null) = i2
 DECLARE dri_regather_maint(drm_object_type=vc,drm_regather_ind=i2,drm_object_name=vc,drm_msg=vc) =
 i2
 DECLARE dri_fill_histogram_list(null) = i2
 DECLARE dri_get_parallel_degree(null) = i2
 DECLARE dri_get_rows_to_sample(null) = i2
 DECLARE dm_ora_pre_stat(i_table_name=vc,i_owner=vc,i_pub_status=vc(ref)) = i2
 DECLARE dm_ora_post_stat(i_table_name=vc,i_owner=vc) = i2
 DECLARE dm_ora_fin_clean(i_table_name=vc,i_owner=vc,i_pub_status=vc) = i2
 DECLARE dm2_get_program_details(null) = vc
 SUBROUTINE dm2_get_program_details(null)
   DECLARE dgpd_param_num = i2 WITH protect, noconstant(1)
   DECLARE dgpd_param_type = vc WITH protect, noconstant("")
   DECLARE dgpd_param_cnt = i2 WITH protect, noconstant(0)
   DECLARE dgpd_details = vc WITH protect, noconstant("~")
   WHILE (dgpd_param_num)
    IF (assign(dgpd_param_type,reflect(parameter(dgpd_param_num,0)))="")
     SET dgpd_param_cnt = (dgpd_param_num - 1)
     SET dgpd_param_num = 0
     IF (dgpd_param_cnt=0)
      RETURN("")
     ELSE
      RETURN(substring(3,size(dgpd_details),dgpd_details))
     ENDIF
    ELSE
     SET dgpd_details = build(dgpd_details,",")
     IF (substring(1,1,dgpd_param_type)="C")
      SET dgpd_details = build(dgpd_details,'"',parameter(dgpd_param_num,0),'"')
     ELSE
      SET dgpd_details = build(dgpd_details,parameter(dgpd_param_num,0))
     ENDIF
    ENDIF
    SET dgpd_param_num = (dgpd_param_num+ 1)
   ENDWHILE
 END ;Subroutine
 DECLARE dm2_process_log_row(process_name=vc,action_type=vc,prev_log_id=f8,ignore_errors=i2) = i2
 DECLARE dm2_process_log_dtl_row(dpldr_event_log_id=f8,ignore_errors=i2) = i2
 DECLARE dm2_process_log_add_detail_text(detail_type=vc,detail_text=vc) = null
 DECLARE dm2_process_log_add_detail_date(detail_type=vc,detail_date=dq8) = null
 DECLARE dm2_process_log_add_detail_number(detail_type=vc,detail_number=f8) = null
 DECLARE dpl_upd_dped_last_status(dudls_event_id=f8,dudls_text=vc,dudls_number=f8,dudls_date=dq8) =
 i2
 DECLARE dpl_ui_chk(duc_process_name=vc) = i2
 IF ((validate(dm2_process_rs->cnt,- (1))=- (1))
  AND (validate(dm2_process_rs->cnt,- (2))=- (2)))
  FREE RECORD dm2_process_rs
  RECORD dm2_process_rs(
    1 dbase_name = vc
    1 table_exists_ind = i2
    1 filled_ind = i2
    1 dm_process_id = f8
    1 process_name = vc
    1 cnt = i4
    1 qual[*]
      2 dm_process_id = f8
      2 process_name = vc
      2 program_name = vc
      2 action_type = vc
      2 search_string = vc
  )
  FREE RECORD dm2_process_event_rs
  RECORD dm2_process_event_rs(
    1 dm_process_event_id = f8
    1 status = vc
    1 message = vc
    1 ui_allowed_ind = i2
    1 install_plan_id = f8
    1 begin_dt_tm = dq8
    1 end_dt_tm = dq8
    1 detail_cnt = i4
    1 itinerary_key = vc
    1 itinerary_process_event_id = f8
    1 details[*]
      2 detail_type = vc
      2 detail_number = f8
      2 detail_text = vc
      2 detail_date = dq8
  )
  SET dm2_process_event_rs->ui_allowed_ind = 0
 ENDIF
 IF (validate(dpl_index_monitoring,"X")="X"
  AND validate(dpl_index_monitoring,"Y")="Y")
  DECLARE dpl_username = vc WITH protect, constant(curuser)
  DECLARE dpl_no_prev_id = f8 WITH protect, constant(0.0)
  DECLARE dpl_success = vc WITH protect, constant("SUCCESS")
  DECLARE dpl_failure = vc WITH protect, constant("FAILURE")
  DECLARE dpl_failed = vc WITH protect, constant("FAILED")
  DECLARE dpl_complete = vc WITH protect, constant("COMPLETE")
  DECLARE dpl_executing = vc WITH protect, constant("EXECUTING")
  DECLARE dpl_paused = vc WITH protect, constant("PAUSED")
  DECLARE dpl_confirmation = vc WITH protect, constant("CONFIRMATION")
  DECLARE dpl_decline = vc WITH protect, constant("DECLINE")
  DECLARE dpl_stopped = vc WITH protect, constant("STOPPED")
  DECLARE dpl_statistics = vc WITH protect, constant("DATABASE STATISTICS GATHERING")
  DECLARE dpl_cbo = vc WITH protect, constant("CBO IMPLEMENTER")
  DECLARE dpl_db_services = vc WITH protect, constant("DATABASE SERVICES")
  DECLARE dpl_package_install = vc WITH protect, constant("PACKAGE INSTALL")
  DECLARE dpl_install_runner = vc WITH protect, constant("INSTALL RUNNER")
  DECLARE dpl_background_runner = vc WITH protect, constant("BACKGROUND RUNNER")
  DECLARE dpl_install_monitor = vc WITH protect, constant("INSTALL MONITOR")
  DECLARE dpl_status_change = vc WITH protect, constant("STATUS CHANGE")
  DECLARE dpl_notnull_validate = vc WITH protect, constant("NOTNULL_VALIDATION")
  DECLARE dpl_process_queue_runner = vc WITH protect, constant("DM_PROCESS_QUEUE RUNNER")
  DECLARE dpl_process_queue_single = vc WITH protect, constant("DM_PROCESS_QUEUE SINGLE")
  DECLARE dpl_process_queue_wrapper = vc WITH protect, constant("DM_PROCESS_QUEUE WRAPPER")
  DECLARE dpl_routine_tasks = vc WITH protect, constant("ROUTINE TASKS")
  DECLARE dpl_coalesce = vc WITH protect, constant("INDEX COALESCING")
  DECLARE dpl_custom_user_mgmt = vc WITH protect, constant("CUSTOM USERS MANAGEMENT")
  DECLARE dpl_xnt_clinical_ranges = vc WITH protect, constant(
   "ESTABLISH EXTRACT & TRANSFORM(XNT) CLINICAL RANGES")
  DECLARE dpl_cbo_stats = vc WITH protect, constant("CBO STATISTICS MANAGEMENT")
  DECLARE dpl_oragen3 = vc WITH protect, constant("ORAGEN3")
  DECLARE dpl_cap_desired_schema = vc WITH protect, constant("CAPTURE DESIRED SCHEMA")
  DECLARE dpl_app_desired_schema = vc WITH protect, constant("APPLY DESIRED SCHEMA")
  DECLARE dpl_ccl_grant = vc WITH protect, constant("CCL GRANTS")
  DECLARE dpl_plan_control = vc WITH protect, constant("PLAN CONTROL")
  DECLARE dpl_cleanup_stats_rows = vc WITH protect, constant("CLEANUP STATS ROWS")
  DECLARE dpl_index_monitoring = vc WITH protect, constant("INDEX MONITORING")
  DECLARE dpl_admin_upgrade = vc WITH protect, constant("ADMIN UPGRADE")
  DECLARE dpl_execution = vc WITH protect, constant("EXECUTION")
  DECLARE dpl_enable_table_monitoring = vc WITH protect, constant("TABLE MONITORING ENABLE")
  DECLARE dpl_table_stats_gathering = vc WITH protect, constant("GATHER TABLE STATS")
  DECLARE dpl_index_stats_gathering = vc WITH protect, constant("GATHER INDEX STATS")
  DECLARE dpl_system_stats_gathering = vc WITH protect, constant("GATHER SYSTEM STATS")
  DECLARE dpl_schema_stats_gathering = vc WITH protect, constant("GATHER SCHEMA STATS")
  DECLARE dpl_itinerary_event = vc WITH protect, constant("ITINERARY EVENT")
  DECLARE dpl_alter_index_monitoring = vc WITH protect, constant("ALTER_INDEX_MONITORING")
  DECLARE dpl_cbo_reset_script_manual = vc WITH protect, constant("CBO RESET SCRIPT MANUAL")
  DECLARE dpl_cbo_reset_script_recompile = vc WITH protect, constant("CBO RESET SCRIPT RECOMPILE")
  DECLARE dpl_cbo_reset_query_manual = vc WITH protect, constant("CBO RESET QUERY MANUAL")
  DECLARE dpl_cbo_reset_all = vc WITH protect, constant("CBO RESET ALL")
  DECLARE dpl_cbo_enable = vc WITH protect, constant("CBO ENABLED")
  DECLARE dpl_cbo_disable = vc WITH protect, constant("CBO DISABLE")
  DECLARE dpl_cbo_monitoring_init = vc WITH protect, constant("CBO MONITORING INITIATED")
  DECLARE dpl_cbo_monitoring_complete = vc WITH protect, constant("CBO MONITORING COMPLETE")
  DECLARE dpl_cbo_tuning_change = vc WITH protect, constant("CBO TUNING CHANGE")
  DECLARE dpl_cbo_tuning_nochange = vc WITH protect, constant("CBO TUNING NOCHANGE")
  DECLARE dpl_data_dump = vc WITH protect, constant("CBO DATA DUMP")
  DECLARE dpl_data_dump_purge = vc WITH protect, constant("CBO DATA DUMP PURGE")
  DECLARE dpl_activate_all = vc WITH protect, constant("ACTIVATE ALL SERVICES")
  DECLARE dpl_instance_activation = vc WITH protect, constant("ACTIVATE SERVICES BY INSTANCE")
  DECLARE dpl_tns_deployment = vc WITH protect, constant("TNS DEPLOYMENT")
  DECLARE dpl_svc_reg_upd = vc WITH protect, constant("REGISTRY SERVER UPDATE")
  DECLARE dpl_notification = vc WITH protect, constant("NOTIFICATION")
  DECLARE dpl_auditlog = vc WITH protect, constant("AUDITLOG")
  DECLARE dpl_snapshot = vc WITH protect, constant("SNAPSHOT")
  DECLARE dpl_purge = vc WITH protect, constant("CUSTOM-DELETE")
  DECLARE dpl_table = vc WITH protect, constant("TABLE")
  DECLARE dpl_index = vc WITH protect, constant("INDEX")
  DECLARE dpl_system = vc WITH protect, constant("SYSTEM")
  DECLARE dpl_schema = vc WITH protect, constant("SCHEMA")
  DECLARE dpl_cmd = vc WITH protect, constant("COMMAND")
  DECLARE dpl_est_pct = vc WITH protect, constant("ESTIMATE PERCENT")
  DECLARE dpl_owner = vc WITH protect, constant("OWNER")
  DECLARE dpl_method_opt = vc WITH protect, constant("METHOD OPT")
  DECLARE dpl_num_attempts = vc WITH protect, constant("NUM ATTEMPTS")
  DECLARE dpl_dm_sql_id = vc WITH protect, constant("DM_SQL_ID")
  DECLARE dpl_script_name = vc WITH protect, constant("SCRIPT NAME")
  DECLARE dpl_query_nbr = vc WITH protect, constant("QUERY_NBR")
  DECLARE dpl_query_nbr_text = vc WITH protect, constant("QUERY_NBR_TEXT")
  DECLARE dpl_sqltext_hash_value = vc WITH protect, constant("SQLTEXT_HASH_VALUE")
  DECLARE dpl_host_name = vc WITH protect, constant("HOST NAME")
  DECLARE dpl_inst_name = vc WITH protect, constant("INSTANCE NAME")
  DECLARE dpl_oracle_version = vc WITH protect, constant("ORACLE VERSION")
  DECLARE dpl_constraint = vc WITH protect, constant("CONSTRAINT")
  DECLARE dpl_column = vc WITH protect, constant("COLUMN")
  DECLARE dpl_proc_queue_runner_type = vc WITH protect, constant("DM_PROCESS_QUEUE RUNNER TYPE")
  DECLARE dpl_dpq_id = vc WITH protect, constant("DM_PROCESS_QUEUE_ID")
  DECLARE dpl_level = vc WITH protect, constant("LEVEL")
  DECLARE dpl_step_number = vc WITH protect, constant("STEP_NUMBER")
  DECLARE dpl_step_name = vc WITH protect, constant("STEP_NAME")
  DECLARE dpl_install_mode = vc WITH protect, constant("INSTALL_MODE")
  DECLARE dpl_parent_step_name = vc WITH protect, constant("PARENT_STEP_NAME")
  DECLARE dpl_parent_level_number = vc WITH protect, constant("PARENT_LEVEL_NUMBER")
  DECLARE dpl_configuration_changed = vc WITH protect, constant("CONFIGURATION CHANGED")
  DECLARE dpl_instsched_used = vc WITH protect, constant("INSTALLATION SCHEDULER USED")
  DECLARE dpl_silmode = vc WITH protect, constant("SILENT MODE USED")
  DECLARE dpl_audsid = vc WITH protect, constant("AUDSID")
  DECLARE dpl_logfilemain = vc WITH protect, constant("LOGFILE:MAIN")
  DECLARE dpl_logfilerunner = vc WITH protect, constant("LOGFILE:RUNNER")
  DECLARE dpl_logfilebackground = vc WITH protect, constant("LOGFILE:BACKGROUND")
  DECLARE dpl_logfilemonitor = vc WITH protect, constant("LOGFILE:MONITOR")
  DECLARE dpl_unattended = vc WITH protect, constant("UNATTENDED_IND")
  DECLARE dpl_itinerary_key = vc WITH protect, constant("ITINERARY_KEY")
  DECLARE dpl_report = vc WITH protect, constant("REPORT")
  DECLARE dpl_actionreq = vc WITH protect, constant("ACTIONREQ")
  DECLARE dpl_progress = vc WITH protect, constant("PROGRESS")
  DECLARE dpl_warning = vc WITH protect, constant("WARNING")
  DECLARE dpl_execution_dpe_id = vc WITH protect, constant("EXECUTION_DPE_ID")
  DECLARE dpl_itinerary_dpe_id = vc WITH protect, constant("ITINERARY_DPE_ID")
  DECLARE dpl_itinerary_key_name = vc WITH protect, constant("ITINERARY_KEY_NAME")
  DECLARE dpl_audit_name = vc WITH protect, constant("AUDIT_NAME")
  DECLARE dpl_audit_type = vc WITH protect, constant("AUDIT_TYPE")
  DECLARE dpl_sample = vc WITH protect, constant("SAMPLE")
  DECLARE dpl_drivergen_runner = vc WITH protect, constant("DM2_ADS_DRIVER_GEN:AUDSID")
  DECLARE dpl_childest_runner = vc WITH protect, constant("DM2_ADS_CHILDEST_GEN:AUDSID")
  DECLARE dpl_ads_runner = vc WITH protect, constant("DM2_ADS_RUNNER:AUDSID")
  DECLARE dpl_byconfig = vc WITH protect, constant("BYCONFIG")
  DECLARE dpl_full = vc WITH protect, constant("ALL")
  DECLARE dpl_interval = vc WITH protect, constant("EVERYNTH")
  DECLARE dpl_intervalpct = vc WITH protect, constant("EVERYNTHPCT")
  DECLARE dpl_recent = vc WITH protect, constant("RECENT")
  DECLARE dpl_none = vc WITH protect, constant("NONE")
  DECLARE dpl_custom = vc WITH protect, constant("CUSTOM")
  DECLARE dpl_static = vc WITH protect, constant("STATIC")
  DECLARE dpl_nomove = vc WITH protect, constant("NOMOVE")
  DECLARE dpl_multiple = vc WITH protect, constant("MULTIPLE")
  DECLARE dpl_driverkeygen = vc WITH protect, constant("DRIVERKEYGEN")
  DECLARE dpl_childestgen = vc WITH protect, constant("CHILDESTGEN")
  DECLARE dpl_define = vc WITH protect, constant("DEFINE")
  DECLARE dpl_invalid_schema = vc WITH protect, constant("INVALID - SCHEMA")
  DECLARE dpl_invalid_stats = vc WITH protect, constant("INVALID - STATS")
  DECLARE dpl_invalid_table = vc WITH protect, constant("INVALID - TABLE")
  DECLARE dpl_invalid_data = vc WITH protect, constant("INVALID - NO SAMPLE METADATA")
  DECLARE dpl_custom_table = vc WITH protect, constant("CUSTOM TABLE")
  DECLARE dpl_new_table = vc WITH protect, constant("NEW TABLE")
  DECLARE dpl_ready = vc WITH protect, constant("READY")
  DECLARE dpl_needsbuild = vc WITH protect, constant("NEEDSBUILD")
  DECLARE dpl_incomplete = vc WITH protect, constant("INCOMPLETE")
  DECLARE dpl_new = vc WITH protect, constant("NEW")
  DECLARE dpl_config_extract_id = vc WITH protect, constant("CONFIG_EXTRACT_ID")
  DECLARE dpl_dynselect_holder = vc WITH protect, constant("<<DYNBYCONFIG>>")
  DECLARE dpl_tgtdblink_holder = vc WITH protect, constant("<<TGTDBLINK>>")
  DECLARE dpl_ads_metadata = vc WITH protect, constant("DM2_ADS_METADATA")
  DECLARE dpl_ads_scramble_method = vc WITH protect, constant("DM2_SCRAMBLE_METHOD")
  DECLARE dpl_act = vc WITH protect, constant("ACTIVITY")
  DECLARE dpl_ref = vc WITH protect, constant("REFERENCE")
  DECLARE dpl_ref_mix = vc WITH protect, constant("REFERENCE-MIXED")
  DECLARE dpl_act_mix = vc WITH protect, constant("ACTIVITY-MIXED")
  DECLARE dpl_mix = vc WITH protect, constant("MIXED")
  DECLARE dpl_action = vc WITH protect, constant("ACTION")
  DECLARE dpl_grant_method = vc WITH protect, constant("GRANT METHOD")
  DECLARE dpl_script = vc WITH protect, constant("SCRIPT NAME")
  DECLARE dpl_query = vc WITH protect, constant("QUERY NUMBER")
  DECLARE dpl_name = vc WITH protect, constant("USER NAME")
  DECLARE dpl_email = vc WITH protect, constant("EMAIL ADDRESS")
  DECLARE dpl_reason = vc WITH protect, constant("REASON FOR ACTION")
  DECLARE dpl_sr_nbr = vc WITH protect, constant("SR NUMBER")
  DECLARE dpl_sql_id = vc WITH protect, constant("SQL ID")
  DECLARE dpl_grant_exists = vc WITH protect, constant("GRANT EXISTS")
  DECLARE dpl_bl_exists = vc WITH protect, constant("BASELINE EXISTS")
  DECLARE dpl_grant_str = vc WITH protect, constant("GRANT OUTSTRING")
  DECLARE dpl_grant_cmd = vc WITH protect, constant("GRANT COMMAND")
  DECLARE dpl_bl_query_nbr = vc WITH protect, constant("BASELINE QUERY NUMBER")
  DECLARE dpl_bl_sql_handle = vc WITH protect, constant("BASELINE SQL HANDLE")
  DECLARE dpl_bl_sql_text = vc WITH protect, constant("BASELINE SQL TEXT")
  DECLARE dpl_bl_creator = vc WITH protect, constant("BASELINE CREATOR")
  DECLARE dpl_bl_desc = vc WITH protect, constant("BASELINE DESCRIPTION")
  DECLARE dpl_bl_enabled = vc WITH protect, constant("BASELINE ENABLED")
  DECLARE dpl_bl_accepted = vc WITH protect, constant("BASELINE ACCEPTED")
  DECLARE dpl_bl_plan_name = vc WITH protect, constant("BASELINE PLAN NAME")
  DECLARE dpl_bl_created = vc WITH protect, constant("BASELINE CREATED DT/TM")
  DECLARE dpl_bl_last_mod = vc WITH protect, constant("BASELINE LAST MODIFIED DT/TM")
  DECLARE dpl_bl_last_exec = vc WITH protect, constant("BASELINE LAST EXECUTED DT/TM")
 ENDIF
 DECLARE dgis_err_ind = i2 WITH protect, noconstant(0)
 DECLARE dgis_err_emsg = vc WITH protect, noconstant("")
 DECLARE dgis_err_eproc = vc WITH protect, noconstant("")
 DECLARE dclcom1 = vc WITH protect, noconstant("")
 DECLARE dgis_beg_time = dq8 WITH protect, noconstant(0.0)
 DECLARE dgis_end_time = dq8 WITH protect, noconstant(0.0)
 DECLARE dgis_analy_time = f8 WITH protect, noconstant(0.0)
 DECLARE dgis_info_exists = i4 WITH protect, noconstant(0)
 DECLARE dgis_found = i4 WITH protect, noconstant(0)
 DECLARE gather_mode = vc WITH protect, noconstant("")
 DECLARE owner = vc WITH protect, noconstant("")
 DECLARE object_name = vc WITH protect, noconstant("")
 DECLARE estimate_percent = f8 WITH protect, noconstant(0.0)
 DECLARE dgis_log_id = f8 WITH protect, noconstant(0.0)
 DECLARE dgis_err_ind = i2 WITH protect, noconstant(0)
 DECLARE dgis_table_name = vc WITH protect, noconstant("")
 DECLARE dgis_publish_val = vc WITH protect, noconstant("NOTSET")
 DECLARE dgis_force_str = vc WITH protect, noconstant(" ")
 IF ((validate(dm2_runstats_ind,- (1))=- (1))
  AND (validate(dm2_runstats_ind,- (2))=- (2)))
  DECLARE dm2_runstats_ind = i2 WITH protect, noconstant(0)
 ENDIF
 DECLARE dgis_cclversion = i4 WITH protect, noconstant(0)
 DECLARE dgis_force_val = vc WITH protect, noconstant("DM2NOTSET")
 IF (check_logfile("dm2_gather_index_st",".log","DM2_GATHER_INDEX_STATS LOGFILE")=0)
  GO TO exit_script
 ENDIF
 SET dgis_err_ind = dm_err->err_ind
 SET dgis_err_emsg = dm_err->emsg
 SET dgis_err_eproc = dm_err->eproc
 SET dm_err->eproc = "Beginning dm2_gather_index_stats"
 CALL disp_msg(" ",dm_err->logfile,0)
 SET dm_err->eproc = "Verifying and storing input parameters."
 SET gather_mode = trim(cnvtupper( $1),3)
 SET owner = trim(cnvtupper( $2),3)
 SET object_name = trim(cnvtupper( $3),3)
 SET estimate_percent = cnvtreal( $4)
 SET dgis_cclversion = (((cnvtint(currev) * 10000)+ (cnvtint(currevminor) * 100))+ cnvtint(
  currevminor2))
 IF ((dm_err->debug_flag > 1))
  CALL echo("Input Parameters:")
  CALL echo(concat("gather_mode:",build(gather_mode)))
  CALL echo(concat("owner:",build(owner)))
  CALL echo(concat("object_name:",build(object_name)))
  CALL echo(concat("estimate_percent:",build(estimate_percent)))
 ENDIF
 IF (check_error(dm_err->eproc)=1)
  SET dm_err->emsg =
  "Parameter usage: dm2_gather_index_stats  '<mode>','<owner>','<index/table_name>',<estimate_percent>"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Validating <estimate_percent> input parameter."
 IF ( NOT (((estimate_percent > 0.0
  AND estimate_percent <= 100.0) OR ((estimate_percent=- (1.0)))) ))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Estimate percent must be greater than 0, or -1 for AUTO_SAMPLE_SIZE."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Validating <mode> input parameter."
 IF ( NOT (gather_mode IN ("INDEX", "TABLE")))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Valid values are 'INDEX', 'TABLE'"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_script
 ENDIF
 IF ( NOT (dri_get_parallel_degree(null)))
  GO TO exit_script
 ENDIF
 IF (dm2_get_rdbms_version(null)=0)
  GO TO exit_script
 ENDIF
 IF ((dm2_rdbms_version->level1 > 10))
  SET dgis_force_val = "TRUE"
  SET dgis_force_str = " ,force=>true "
 ENDIF
 IF (gather_mode="INDEX")
  SET dm_err->eproc = concat("Calling SYS.DBMS_STATS.GATHER_INDEX_STATS for ",object_name)
  CALL disp_msg(" ",dm_err->logfile,0)
  SET dclcom1 = concat(^RDB ASIS("begin SYS.DBMS_STATS.GATHER_INDEX_STATS(ownname=>'^,owner,
   "',indname=>'",object_name,"',estimate_percent=>",
   evaluate(estimate_percent,- (1.0),"SYS.DBMS_STATS.AUTO_SAMPLE_SIZE",build(estimate_percent)),
   evaluate(table_stats->index_degree,- (1)," ",concat(" ,degree=>",build(table_stats->index_degree))
    ),dgis_force_str,'); end;") go')
  SET dm2_process_event_rs->status = dpl_executing
  SET dm_err->eproc = "Selecting table_name from dba_indexes"
  SELECT INTO "nl:"
   FROM dba_indexes di
   WHERE di.index_name=object_name
    AND di.owner=owner
   DETAIL
    dgis_table_name = di.table_name
   WITH nocounter, maxqual(di,1)
  ;end select
  IF (check_error(dm_err->eproc))
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_script
  ENDIF
  CALL dm2_process_log_add_detail_text(dpl_table,dgis_table_name)
  CALL dm2_process_log_add_detail_text(dpl_index,object_name)
  CALL dm2_process_log_add_detail_text(dpl_owner,owner)
  CALL dm2_process_log_add_detail_number(dpl_est_pct,estimate_percent)
  CALL dm2_process_log_add_detail_text(dpl_cmd,dclcom1)
  IF (trim(dgis_table_name)="")
   CALL dm2_process_log_add_detail_text("GATHER_BYPASS_REASON","INDEX NAME NO LONGER EXISTS")
  ENDIF
  CALL dm2_process_log_row(dpl_statistics,dpl_index_stats_gathering,dpl_no_prev_id,1)
  SET dgis_log_id = dm2_process_event_rs->dm_process_event_id
  IF ((dm_err->debug_flag >= 1))
   SET dgis_beg_time = cnvtdatetime(curdate,curtime3)
  ENDIF
  IF (trim(dgis_table_name) > "")
   IF (dm_ora_pre_stat(dgis_table_name,owner,dgis_publish_val)=0)
    SET dgis_err_ind = 1
    SET dm_err->err_ind = 0
   ENDIF
   IF (dgis_err_ind != 1)
    IF (dgis_cclversion >= 80506)
     IF ((table_stats->index_degree=- (1)))
      IF ((dm2_rdbms_version->level1 > 10))
       DECLARE gather_index_stats(ownname=vc,indname=vc,estimate_percent=f8,force=i4) = null WITH sql
        = "SYS.DBMS_STATS.GATHER_INDEX_STATS", parameter
       CALL gather_index_stats(owner,object_name,evaluate(estimate_percent,- (1.0),0.0,
         estimate_percent),cnvtbool(true))
      ELSE
       DECLARE gather_index_stats(ownname=vc,indname=vc,estimate_percent=f8) = null WITH sql =
       "SYS.DBMS_STATS.GATHER_INDEX_STATS", parameter
       CALL gather_index_stats(owner,object_name,evaluate(estimate_percent,- (1.0),0.0,
         estimate_percent))
      ENDIF
     ELSE
      IF ((dm2_rdbms_version->level1 > 10))
       DECLARE gather_index_stats(ownname=vc,indname=vc,estimate_percent=f8,degree=i4,force=i4) =
       null WITH sql = "SYS.DBMS_STATS.GATHER_INDEX_STATS", parameter
       CALL gather_index_stats(owner,object_name,evaluate(estimate_percent,- (1.0),0.0,
         estimate_percent),table_stats->index_degree,cnvtbool(true))
      ELSE
       DECLARE gather_index_stats(ownname=vc,indname=vc,estimate_percent=f8,degree=i4) = null WITH
       sql = "SYS.DBMS_STATS.GATHER_INDEX_STATS", parameter
       CALL gather_index_stats(owner,object_name,evaluate(estimate_percent,- (1.0),0.0,
         estimate_percent),table_stats->index_degree)
      ENDIF
     ENDIF
    ELSE
     CALL dm2_push_cmd(dclcom1,1)
    ENDIF
    IF (check_error(dm_err->eproc)=1)
     IF ((dm_err->debug_flag >= 1))
      SET dgis_end_time = cnvtdatetime(curdate,curtime3)
      SET dgis_analy_time = datetimediff(dgis_end_time,dgis_beg_time,5)
      SET dm_err->eproc = build("Stats Gather time for index: ",object_name,"=",dgis_analy_time,
       " seconds.")
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     SET dgis_err_ind = 1
     SET dm_err->err_ind = 0
    ENDIF
    IF (dgis_err_ind != 1)
     IF (dm_ora_post_stat(dgis_table_name,owner)=0)
      SET dgis_err_ind = 1
      SET dm_err->err_ind = 0
     ENDIF
    ENDIF
   ENDIF
  ENDIF
  SET dm2_process_event_rs->status = evaluate(dgis_err_ind,1,dpl_failure,dpl_success)
  SET dm2_process_event_rs->message = evaluate(dgis_err_ind,1,dm_err->emsg,"")
  CALL dm2_process_log_row(dpl_statistics,dpl_index_stats_gathering,dgis_log_id,1)
  IF (dgis_err_ind)
   GO TO exit_script
  ENDIF
  IF ((dm_err->debug_flag >= 1))
   SET dgis_end_time = cnvtdatetime(curdate,curtime3)
   SET dgis_analy_time = datetimediff(dgis_end_time,dgis_beg_time,5)
   SET dm_err->eproc = build("Stats Gather time for index: ",object_name,"=",dgis_analy_time,
    " seconds.")
   CALL disp_msg(" ",dm_err->logfile,0)
  ENDIF
 ELSEIF (gather_mode="TABLE")
  SET index_list->est_pct = estimate_percent
  IF (dri_fill_index_list(owner,object_name)=0)
   GO TO exit_script
  ENDIF
  SET dgis_table_name = object_name
  IF (dm_ora_pre_stat(object_name,owner,dgis_publish_val)=0)
   GO TO exit_script
  ENDIF
  FOR (dgis_iter = 1 TO index_list->index_cnt)
    IF ((dm_err->debug_flag >= 1))
     SET dgis_beg_time = cnvtdatetime(curdate,curtime3)
    ENDIF
    SET dclcom1 = concat(^RDB ASIS("begin SYS.DBMS_STATS.GATHER_INDEX_STATS(ownname=>'^,owner,
     "',indname=>'",index_list->qual[dgis_iter].index_name,"',estimate_percent=>",
     build(index_list->qual[dgis_iter].est_pct),evaluate(table_stats->index_degree,- (1)," ",concat(
       " ,degree=>",build(table_stats->index_degree))),dgis_force_str,'); end;") go')
    SET dm2_process_event_rs->status = dpl_executing
    CALL dm2_process_log_add_detail_text(dpl_index,index_list->qual[dgis_iter].index_name)
    CALL dm2_process_log_add_detail_text(dpl_table,object_name)
    CALL dm2_process_log_add_detail_text(dpl_owner,owner)
    CALL dm2_process_log_add_detail_number(dpl_est_pct,index_list->qual[dgis_iter].est_pct)
    CALL dm2_process_log_add_detail_text(dpl_cmd,dclcom1)
    CALL dm2_process_log_row(dpl_statistics,dpl_index_stats_gathering,dpl_no_prev_id,1)
    SET dgis_log_id = dm2_process_event_rs->dm_process_event_id
    IF (dgis_cclversion >= 80506)
     IF ((table_stats->index_degree=- (1)))
      IF ((dm2_rdbms_version->level1 > 10))
       DECLARE gather_index_stats(ownname=vc,indname=vc,estimate_percent=f8,force=i4) = null WITH sql
        = "SYS.DBMS_STATS.GATHER_INDEX_STATS", parameter
       CALL gather_index_stats(owner,index_list->qual[dgis_iter].index_name,index_list->qual[
        dgis_iter].est_pct,cnvtbool(true))
      ELSE
       DECLARE gather_index_stats(ownname=vc,indname=vc,estimate_percent=f8) = null WITH sql =
       "SYS.DBMS_STATS.GATHER_INDEX_STATS", parameter
       CALL gather_index_stats(owner,index_list->qual[dgis_iter].index_name,index_list->qual[
        dgis_iter].est_pct)
      ENDIF
     ELSE
      IF ((dm2_rdbms_version->level1 > 10))
       DECLARE gather_index_stats(ownname=vc,indname=vc,estimate_percent=f8,degree=i4,force=i4) =
       null WITH sql = "SYS.DBMS_STATS.GATHER_INDEX_STATS", parameter
       CALL gather_index_stats(owner,index_list->qual[dgis_iter].index_name,index_list->qual[
        dgis_iter].est_pct,table_stats->index_degree,cnvtbool(true))
      ELSE
       DECLARE gather_index_stats(ownname=vc,indname=vc,estimate_percent=f8,degree=i4) = null WITH
       sql = "SYS.DBMS_STATS.GATHER_INDEX_STATS", parameter
       CALL gather_index_stats(owner,index_list->qual[dgis_iter].index_name,index_list->qual[
        dgis_iter].est_pct,table_stats->index_degree)
      ENDIF
     ENDIF
    ELSE
     CALL dm2_push_cmd(dclcom1,1)
    ENDIF
    IF (check_error(dm_err->eproc)=1)
     IF ((dm_err->debug_flag >= 1))
      SET dgis_end_time = cnvtdatetime(curdate,curtime3)
      SET dgis_analy_time = datetimediff(dgis_end_time,dgis_beg_time,5)
      SET dm_err->eproc = build("Stats Gather time for index: ",index_list->qual[dgis_iter].
       index_name,"=",dgis_analy_time," seconds.")
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
    ENDIF
    SET dm2_process_event_rs->status = evaluate(dm_err->err_ind,1,dpl_failure,dpl_success)
    SET dm2_process_event_rs->message = evaluate(dm_err->err_ind,1,dm_err->emsg,"")
    SET dm_err->err_ind = 0
    CALL dm2_process_log_row(dpl_statistics,dpl_index_stats_gathering,dgis_log_id,1)
  ENDFOR
  IF (dm_ora_post_stat(object_name,owner)=0)
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 CALL dm_ora_fin_clean(dgis_table_name,owner,dgis_publish_val)
 SET dm_err->eproc = "Ending dm2_gather_index_stats."
 CALL final_disp_msg("dm2_gather_index_st")
 SET dm_err->err_ind = dgis_err_ind
 SET dm_err->emsg = dgis_err_emsg
 SET dm_err->eproc = dgis_err_eproc
 SUBROUTINE dpl_upd_dped_last_status(dudls_event_id,dudls_text,dudls_number,dudls_date)
   DECLARE dudls_emsg = vc WITH protect, noconstant(dm_err->emsg)
   DECLARE dudls_eproc = vc WITH protect, noconstant(dm_err->eproc)
   DECLARE dudls_err_ind = i4 WITH protect, noconstant(dm_err->err_ind)
   IF (dudls_err_ind=1)
    SET dm_err->err_ind = 0
   ENDIF
   IF ((dm2_process_event_rs->ui_allowed_ind=0))
    RETURN(1)
   ENDIF
   SET dm_err->eproc = concat("Existance check for Event_Id",build(dudls_event_id))
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_process_event d
    WHERE d.dm_process_event_id=dudls_event_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET dm_err->eproc =
    "Unable to find the event_id in DM_PROCESS_EVENT. Bypass inserting of new details."
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   CALL dm2_process_log_add_detail_text("LAST_STATUS_MESSAGE",dudls_text)
   SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_date = dudls_date
   SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_number = dudls_number
   CALL dm2_process_log_dtl_row(dudls_event_id,1)
   IF (dudls_err_ind=1)
    SET dm_err->err_ind = dudls_err_ind
    SET dm_err->eproc = dudls_eproc
    SET dm_err->emsg = dudls_emsg
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpl_ui_chk(duc_process_name)
   DECLARE duc_event_col_exists = i2 WITH protect, noconstant(0)
   DECLARE duc_col_oradef_ind = i2 WITH protect, noconstant(0)
   DECLARE duc_col_ccldef_ind = i2 WITH protect, noconstant(0)
   DECLARE duc_data_type = vc WITH protect, noconstant("")
   IF ((dm2_process_event_rs->ui_allowed_ind >= 0)
    AND currdbuser="V500"
    AND (dm2_process_rs->dbase_name=currdbname))
    IF ((dm_err->debug_flag > 0))
     CALL echo(concat("Unattended install previously set:",build(dm2_process_event_rs->ui_allowed_ind
        )))
    ENDIF
    RETURN(1)
   ELSE
    IF ( NOT (currdbuser IN ("V500", "STATS", "CERN_DBSTATS")))
     SET dm2_process_event_rs->ui_allowed_ind = 0
     SET dm2_process_rs->table_exists_ind = 0
     SET dm2_process_rs->dbase_name = currdbname
     SET dm2_process_rs->filled_ind = 0
     IF ((dm_err->debug_flag > 0))
      CALL echo(concat("Unattended install not allowed. Current user is not V500. Current user is ",
        currdbuser))
     ENDIF
     RETURN(1)
    ENDIF
    SET dm2_process_event_rs->ui_allowed_ind = 1
    IF ( NOT (duc_process_name IN (dpl_notification, dpl_package_install, dpl_install_runner,
    dpl_background_runner, dpl_install_monitor)))
     SET dm2_process_event_rs->ui_allowed_ind = 0
     IF ((dm_err->debug_flag > 0))
      CALL echo(concat("Unattended install not allowed for ",duc_process_name))
     ENDIF
    ENDIF
    IF ((((dm2_process_rs->table_exists_ind=0)) OR ((dm2_process_rs->dbase_name != currdbname))) )
     SET dm2_process_rs->dbase_name = currdbname
     SET dm2_process_rs->filled_ind = 0
     SET duc_event_col_exists = 0
     SET duc_col_oradef_ind = 0
     SET dm_err->eproc = "Existance check for INSTALL_PLAN_ID and DETAIL_DT_TM"
     SELECT INTO "nl:"
      FROM dm2_user_tab_cols utc
      WHERE utc.table_name IN ("DM_PROCESS_EVENT", "DM_PROCESS_EVENT_DTL")
       AND utc.column_name IN ("INSTALL_PLAN_ID", "DETAIL_DT_TM")
      DETAIL
       IF (utc.table_name="DM_PROCESS_EVENT"
        AND utc.column_name="INSTALL_PLAN_ID")
        duc_col_oradef_ind = (duc_col_oradef_ind+ 1)
       ELSEIF (utc.table_name="DM_PROCESS_EVENT_DTL"
        AND utc.column_name="DETAIL_DT_TM")
        duc_col_oradef_ind = (duc_col_oradef_ind+ 1)
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (duc_col_oradef_ind=2)
      SET duc_col_ccldef_ind = 0
      SET duc_col_oradef_ind = 0
      IF (dm2_table_column_exists("","DM_PROCESS_EVENT","INSTALL_PLAN_ID",0,1,
       1,duc_col_oradef_ind,duc_col_ccldef_ind,duc_data_type)=0)
       RETURN(0)
      ENDIF
      IF (duc_col_ccldef_ind=1)
       SET duc_event_col_exists = (duc_event_col_exists+ 1)
      ENDIF
      SET duc_col_ccldef_ind = 0
      SET duc_col_oradef_ind = 0
      IF (dm2_table_column_exists("","DM_PROCESS_EVENT_DTL","DETAIL_DT_TM",0,1,
       1,duc_col_oradef_ind,duc_col_ccldef_ind,duc_data_type)=0)
       RETURN(0)
      ENDIF
      IF (duc_col_ccldef_ind=1)
       SET duc_event_col_exists = (duc_event_col_exists+ 1)
      ENDIF
     ENDIF
     IF (duc_event_col_exists < 2)
      IF ((dm_err->debug_flag > 0))
       CALL echo("Unattended install not allowed. Required schema does not yet exist")
      ENDIF
      SET dm2_process_event_rs->ui_allowed_ind = 0
      SET dm2_process_rs->table_exists_ind = 0
     ELSE
      SET dm2_process_rs->table_exists_ind = 1
     ENDIF
    ENDIF
    IF ((dm2_process_rs->table_exists_ind=1))
     SET dm_err->eproc = "Existance check for DM_CLINICAL_SEQ"
     SELECT INTO "nl:"
      FROM dba_sequences
      WHERE sequence_owner="V500"
       AND sequence_name="DM_CLINICAL_SEQ"
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (curqual=0)
      IF ((dm_err->debug_flag > 0))
       CALL echo("Unattended install not allowed. Required sequence does not yet exist")
      ENDIF
      SET dm2_process_event_rs->ui_allowed_ind = 0
      SET dm2_process_rs->table_exists_ind = 0
     ENDIF
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("Unattended install allowed:",build(dm2_process_event_rs->ui_allowed_ind)))
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_process_log_dtl_row(dpldr_event_log_id,ignore_errors)
   IF ((dm2_process_rs->table_exists_ind=0))
    RETURN(1)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dm2_process_event_rs)
   ENDIF
   IF ((dm2_process_event_rs->detail_cnt > 0))
    SET dm_err->eproc = "Removing logging detail from dm_process_event_dtl."
    DELETE  FROM dm_process_event_dtl dtl,
      (dummyt d  WITH seq = value(dm2_process_event_rs->detail_cnt))
     SET dtl.seq = 0
     PLAN (d)
      JOIN (dtl
      WHERE dtl.dm_process_event_id=dpldr_event_log_id
       AND (dtl.detail_type=dm2_process_event_rs->details[d.seq].detail_type))
     WITH nocounter
    ;end delete
    IF (dpl_check_error(null))
     RETURN((1 - dm_err->err_ind))
    ENDIF
    SET dm_err->eproc = "Inserting logging detail into dm_process_event_dtl."
    INSERT  FROM dm_process_event_dtl dped,
      (dummyt d  WITH seq = value(dm2_process_event_rs->detail_cnt))
     SET dped.dm_process_event_dtl_id = seq(dm_clinical_seq,nextval), dped.dm_process_event_id =
      dpldr_event_log_id, dped.detail_type = dm2_process_event_rs->details[d.seq].detail_type,
      dped.detail_number = dm2_process_event_rs->details[d.seq].detail_number, dped.detail_text =
      dm2_process_event_rs->details[d.seq].detail_text, dped.detail_dt_tm = cnvtdatetime(
       dm2_process_event_rs->details[d.seq].detail_date)
     PLAN (d)
      JOIN (dped)
     WITH nocounter
    ;end insert
    IF (dpl_check_error(null))
     RETURN((1 - dm_err->err_ind))
    ENDIF
    COMMIT
   ENDIF
   SET dm2_process_event_rs->status = ""
   SET dm2_process_event_rs->message = ""
   SET dm2_process_event_rs->detail_cnt = 0
   SET dm2_process_event_rs->end_dt_tm = cnvtdatetime("01-JAN-1900")
   SET dm2_process_event_rs->begin_dt_tm = cnvtdatetime("01-JAN-1900")
   SET stat = alterlist(dm2_process_event_rs->details,0)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_process_log_row(process_name,action_type,prev_log_id,ignore_errors)
   IF (dpl_ui_chk(process_name)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_process_rs->table_exists_ind=0))
    RETURN(1)
   ENDIF
   DECLARE dplr_search = i4 WITH protect, noconstant(0)
   DECLARE dplr_event_id = f8 WITH protect, noconstant(prev_log_id)
   DECLARE dplr_stack = vc WITH protect, constant(dm2_get_program_stack(null))
   DECLARE dplr_process_name = vc WITH protect, constant(evaluate(dm2_process_rs->process_name,"",
     process_name,dm2_process_rs->process_name))
   DECLARE dplr_program_details = vc WITH protect, constant(curprog)
   DECLARE dplr_search_string = vc WITH protect, constant(build(dplr_process_name,"#",curprog,"#",
     action_type))
   SET dm2_process_rs->process_name = dplr_process_name
   IF ( NOT (dm2_process_rs->filled_ind))
    SET dm_err->eproc = "Querying for list of logged processes from dm_process."
    SELECT INTO "nl:"
     FROM dm_process dp
     HEAD REPORT
      dm2_process_rs->filled_ind = 1, dm2_process_rs->cnt = 0, stat = alterlist(dm2_process_rs->qual,
       0)
     DETAIL
      dm2_process_rs->cnt = (dm2_process_rs->cnt+ 1)
      IF (mod(dm2_process_rs->cnt,10)=1)
       stat = alterlist(dm2_process_rs->qual,(dm2_process_rs->cnt+ 9))
      ENDIF
      dm2_process_rs->qual[dm2_process_rs->cnt].dm_process_id = dp.dm_process_id, dm2_process_rs->
      qual[dm2_process_rs->cnt].process_name = dp.process_name, dm2_process_rs->qual[dm2_process_rs->
      cnt].program_name = dp.program_name,
      dm2_process_rs->qual[dm2_process_rs->cnt].action_type = dp.action_type, dm2_process_rs->qual[
      dm2_process_rs->cnt].search_string = build(dp.process_name,"#",dp.program_name,"#",dp
       .action_type)
     FOOT REPORT
      stat = alterlist(dm2_process_rs->qual,dm2_process_rs->cnt)
     WITH nocounter, nullreport
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (prev_log_id=0)
    IF ( NOT (assign(dplr_search,locateval(dplr_search,1,dm2_process_rs->cnt,dplr_search_string,
      dm2_process_rs->qual[dplr_search].search_string))))
     SET dm_err->eproc = "Getting next sequence for new process from dm_clinical_seq."
     SELECT INTO "nl:"
      id = seq(dm_clinical_seq,nextval)
      FROM dual
      DETAIL
       dm2_process_rs->dm_process_id = id
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = "Inserting new process into dm_process."
     INSERT  FROM dm_process dp
      SET dp.dm_process_id = dm2_process_rs->dm_process_id, dp.process_name = dm2_process_rs->
       process_name, dp.program_name = curprog,
       dp.action_type = action_type
      WITH nocounter
     ;end insert
     IF (dpl_check_error(null))
      RETURN((1 - dm_err->err_ind))
     ENDIF
     COMMIT
     SET dm2_process_rs->cnt = (dm2_process_rs->cnt+ 1)
     SET stat = alterlist(dm2_process_rs->qual,dm2_process_rs->cnt)
     SET dm2_process_rs->qual[dm2_process_rs->cnt].dm_process_id = dm2_process_rs->dm_process_id
     SET dm2_process_rs->qual[dm2_process_rs->cnt].process_name = dm2_process_rs->process_name
     SET dm2_process_rs->qual[dm2_process_rs->cnt].program_name = curprog
     SET dm2_process_rs->qual[dm2_process_rs->cnt].action_type = action_type
     SET dm2_process_rs->qual[dm2_process_rs->cnt].search_string = dplr_search_string
     SET dplr_search = dm2_process_rs->cnt
    ENDIF
    SET dm2_process_rs->dm_process_id = dm2_process_rs->qual[dplr_search].dm_process_id
    SET dm_err->eproc = "Getting next sequence for log row."
    SELECT INTO "nl:"
     id = seq(dm_clinical_seq,nextval)
     FROM dual
     DETAIL
      dplr_event_id = id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Inserting logging row into dm_process_event."
    INSERT  FROM dm_process_event dpe
     SET dpe.dm_process_event_id = dplr_event_id, dpe.install_plan_id = dm2_process_event_rs->
      install_plan_id, dpe.dm_process_id = dm2_process_rs->dm_process_id,
      dpe.program_stack = dplr_stack, dpe.program_details = dplr_program_details, dpe.begin_dt_tm =
      IF (process_name=dpl_package_install
       AND action_type=dpl_itinerary_event) cnvtdatetime(dm2_process_event_rs->begin_dt_tm)
      ELSE cnvtdatetime(curdate,curtime3)
      ENDIF
      ,
      dpe.username = dpl_username, dpe.event_status = dm2_process_event_rs->status, dpe.message_txt
       = dm2_process_event_rs->message
     WITH nocounter
    ;end insert
    IF (dpl_check_error(null))
     RETURN((1 - dm_err->err_ind))
    ENDIF
    IF (action_type=dpl_auditlog
     AND process_name IN (dpl_package_install, dpl_install_monitor, dpl_background_runner,
    dpl_install_runner))
     IF ((dir_ui_misc->dm_process_event_id > 0))
      CALL dm2_process_log_add_detail_number(dpl_execution_dpe_id,dir_ui_misc->dm_process_event_id)
     ENDIF
     IF ((dm2_process_event_rs->itinerary_process_event_id > 0))
      CALL dm2_process_log_add_detail_number(dpl_itinerary_dpe_id,dm2_process_event_rs->
       itinerary_process_event_id)
     ENDIF
     IF (trim(dm2_process_event_rs->itinerary_key) > "")
      CALL dm2_process_log_add_detail_text(dpl_itinerary_key_name,dm2_process_event_rs->itinerary_key
       )
     ENDIF
    ENDIF
    IF ((dm2_process_event_rs->detail_cnt > 0))
     SET dm_err->eproc = "Inserting logging detail into dm_process_event_dtl."
     INSERT  FROM dm_process_event_dtl dped,
       (dummyt d  WITH seq = value(dm2_process_event_rs->detail_cnt))
      SET dped.dm_process_event_dtl_id = seq(dm_clinical_seq,nextval), dped.dm_process_event_id =
       dplr_event_id, dped.detail_type = dm2_process_event_rs->details[d.seq].detail_type,
       dped.detail_number = dm2_process_event_rs->details[d.seq].detail_number, dped.detail_text =
       dm2_process_event_rs->details[d.seq].detail_text, dped.detail_dt_tm = cnvtdatetime(
        dm2_process_event_rs->details[d.seq].detail_date)
      PLAN (d)
       JOIN (dped)
      WITH nocounter
     ;end insert
    ENDIF
    IF (dpl_check_error(null))
     RETURN((1 - dm_err->err_ind))
    ENDIF
    COMMIT
   ELSE
    SET dm_err->eproc = "Updating existing logging row in dm_process_event."
    UPDATE  FROM dm_process_event dpe
     SET dpe.end_dt_tm =
      IF (cnvtdatetime(dm2_process_event_rs->end_dt_tm)=cnvtdatetime("01-JAN-1900")
       AND process_name=dpl_package_install
       AND action_type=dpl_itinerary_event) dpe.end_dt_tm
      ELSEIF (cnvtdatetime(dm2_process_event_rs->end_dt_tm) > cnvtdatetime("01-JAN-1900")
       AND process_name=dpl_package_install
       AND action_type=dpl_itinerary_event) cnvtdatetime(dm2_process_event_rs->end_dt_tm)
      ELSE cnvtdatetime(curdate,curtime3)
      ENDIF
      , dpe.begin_dt_tm =
      IF (cnvtdatetime(dm2_process_event_rs->begin_dt_tm)=cnvtdatetime("01-JAN-1900")
       AND process_name=dpl_package_install
       AND action_type=dpl_itinerary_event) dpe.begin_dt_tm
      ELSEIF (cnvtdatetime(dm2_process_event_rs->begin_dt_tm) > cnvtdatetime("01-JAN-1900")
       AND process_name=dpl_package_install
       AND action_type=dpl_itinerary_event) cnvtdatetime(dm2_process_event_rs->begin_dt_tm)
      ELSEIF (process_name=dpl_package_install
       AND action_type=dpl_itinerary_event) cnvtdatetime(curdate,curtime3)
      ELSE dpe.begin_dt_tm
      ENDIF
      , dpe.event_status = evaluate(dm2_process_event_rs->status,"",dpe.event_status,
       dm2_process_event_rs->status),
      dpe.message_txt = evaluate(dm2_process_event_rs->message,"",dpe.message_txt,
       dm2_process_event_rs->message), dpe.program_details = dplr_program_details
     WHERE dpe.dm_process_event_id=dplr_event_id
     WITH nocounter
    ;end update
    IF (dpl_check_error(null))
     RETURN((1 - dm_err->err_ind))
    ENDIF
    COMMIT
   ENDIF
   SET dm2_process_event_rs->dm_process_event_id = dplr_event_id
   SET dm2_process_event_rs->status = ""
   SET dm2_process_event_rs->message = ""
   SET dm2_process_event_rs->detail_cnt = 0
   SET dm2_process_event_rs->end_dt_tm = 0
   SET dm2_process_event_rs->begin_dt_tm = 0
   SET dm2_process_event_rs->install_plan_id = 0.0
   SET stat = alterlist(dm2_process_event_rs->details,0)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpl_check_error(null)
   IF (check_error(dm_err->eproc))
    ROLLBACK
    IF ( NOT (ignore_errors))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ELSE
     SET dm_err->err_ind = 0
     CALL echo("The above error is ignorable.")
    ENDIF
   ENDIF
   IF (dm_err->err_ind)
    SET dm2_process_event_rs->status = ""
    SET dm2_process_event_rs->message = ""
    SET dm2_process_event_rs->detail_cnt = 0
    SET stat = alterlist(dm2_process_event_rs->details,0)
    SET dm2_process_event_rs->dm_process_event_id = 0.0
   ENDIF
   RETURN(dm_err->err_ind)
 END ;Subroutine
 SUBROUTINE dm2_process_log_add_detail_text(detail_type,detail_text)
   SET dm2_process_event_rs->detail_cnt = (dm2_process_event_rs->detail_cnt+ 1)
   SET stat = alterlist(dm2_process_event_rs->details,dm2_process_event_rs->detail_cnt)
   SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_type = detail_type
   SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_text = detail_text
 END ;Subroutine
 SUBROUTINE dm2_process_log_add_detail_date(detail_type,detail_date)
   SET dm2_process_event_rs->detail_cnt = (dm2_process_event_rs->detail_cnt+ 1)
   SET stat = alterlist(dm2_process_event_rs->details,dm2_process_event_rs->detail_cnt)
   SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_type = detail_type
   SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_date = detail_date
 END ;Subroutine
 SUBROUTINE dm2_process_log_add_detail_number(detail_type,detail_number)
   SET dm2_process_event_rs->detail_cnt = (dm2_process_event_rs->detail_cnt+ 1)
   SET stat = alterlist(dm2_process_event_rs->details,dm2_process_event_rs->detail_cnt)
   SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_type = detail_type
   SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_number = detail_number
 END ;Subroutine
 SUBROUTINE dri_fill_histogram_list(null)
   DECLARE dfhl_info_exists = i2 WITH protect, noconstant(0)
   IF (dm2_table_and_ccldef_exists("DM_INFO",dfhl_info_exists)=0)
    RETURN(0)
   ENDIF
   IF (dfhl_info_exists=0)
    SET dm_err->eproc = "Unable to populate histogram list.  DM_INFO does not exist."
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Selecting histogram columns from dm_info."
   SELECT INTO "nl:"
    curr_table = build(substring(1,(findstring(":",di.info_name) - 1),di.info_name)), curr_column =
    build(substring((findstring(":",di.info_name)+ 1),size(di.info_name),di.info_name))
    FROM dm_info di
    WHERE di.info_domain="DM2_RUNSTATS:HISTOGRAM_COLUMN"
     AND di.info_number=1
     AND di.info_name=patstring(concat(table_stats->table_name,":*"))
    ORDER BY di.info_name
    HEAD REPORT
     hist_list->table_cnt = 0, stat = alterlist(hist_list->table_list,hist_list->table_cnt)
    HEAD curr_table
     hist_list->table_cnt = (hist_list->table_cnt+ 1)
     IF (mod(hist_list->table_cnt,10)=1)
      stat = alterlist(hist_list->table_list,(hist_list->table_cnt+ 9))
     ENDIF
     hist_list->table_list[hist_list->table_cnt].table_name = curr_table
    HEAD curr_column
     hist_list->table_list[hist_list->table_cnt].column_cnt = (hist_list->table_list[hist_list->
     table_cnt].column_cnt+ 1), stat = alterlist(hist_list->table_list[hist_list->table_cnt].
      column_list,hist_list->table_list[hist_list->table_cnt].column_cnt), hist_list->table_list[
     hist_list->table_cnt].column_list[hist_list->table_list[hist_list->table_cnt].column_cnt].
     column_name = curr_column,
     hist_list->table_list[hist_list->table_cnt].column_list[hist_list->table_list[hist_list->
     table_cnt].column_cnt].method_opt = di.info_char
    FOOT REPORT
     stat = alterlist(hist_list->table_list,hist_list->table_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(hist_list)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dri_fill_regather_list(null)
   DECLARE dtrl_info_exists = i2 WITH protect, noconstant(0)
   IF (dm2_table_and_ccldef_exists("DM_INFO",dtrl_info_exists)=0)
    RETURN(0)
   ENDIF
   IF (dtrl_info_exists=0)
    SET dm_err->eproc = "Unable to populate regather list.  DM_INFO does not exist."
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Selecting from dm_info to get re-gather candidates."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2-RUNSTATS:GATHER-RESET-*"
     AND di.info_number=1
    HEAD REPORT
     table_stats->stats_retry_cnt = 0, stat = alterlist(table_stats->stats_retry,table_stats->
      stats_retry_cnt)
    DETAIL
     table_stats->stats_retry_cnt = (table_stats->stats_retry_cnt+ 1), stat = alterlist(table_stats->
      stats_retry,table_stats->stats_retry_cnt)
     IF (di.info_domain="DM2-RUNSTATS:GATHER-RESET-TABLE")
      table_stats->stats_retry[table_stats->stats_retry_cnt].object_type = "TABLE"
     ELSEIF (di.info_domain="DM2-RUNSTATS:GATHER-RESET-INDEX")
      table_stats->stats_retry[table_stats->stats_retry_cnt].object_type = "INDEX"
     ENDIF
     table_stats->stats_retry[table_stats->stats_retry_cnt].object_name = di.info_name
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dri_regather_maint(drm_object_type,drm_regather_ind,drm_object_name,drm_msg)
   DECLARE drm_info_exists = i2 WITH protect, noconstant(0)
   IF (dm2_table_and_ccldef_exists("DM_INFO",drm_info_exists)=0)
    RETURN(0)
   ENDIF
   IF (drm_info_exists=0)
    SET dm_err->eproc = "Unable to insert/update regather data.  DM_INFO does not exist."
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Selecting row from dm_info to update/insert."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=concat("DM2-RUNSTATS:GATHER-RESET-",drm_object_type)
     AND di.info_name=drm_object_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    IF (drm_regather_ind=1)
     SET dm_err->eproc = "Inserting new row for re-gather."
     INSERT  FROM dm_info di
      SET di.info_domain = concat("DM2-RUNSTATS:GATHER-RESET-",drm_object_type), di.info_name =
       drm_object_name, di.info_char = drm_msg,
       di.info_date = sysdate, di.info_number = drm_regather_ind
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN(0)
     ENDIF
     COMMIT
    ENDIF
   ELSE
    SET dm_err->eproc = "Updating dm_info row."
    UPDATE  FROM dm_info di
     SET di.info_number = drm_regather_ind, di.info_char = evaluate(drm_regather_ind,1,drm_msg,di
       .info_char), di.updt_dt_tm = sysdate,
      di.updt_cnt = evaluate(drm_regather_ind,1,(di.updt_cnt+ 1),0), di.updt_id = evaluate(
       drm_regather_ind,1,(di.updt_id+ 1),di.updt_id)
     WHERE di.info_domain=concat("DM2-RUNSTATS:GATHER-RESET-",drm_object_type)
      AND di.info_name=drm_object_name
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ENDIF
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dri_get_ind_est_perc(null)
   DECLARE dgiep_info_exists = i2 WITH protect, noconstant(0)
   IF ((index_list->est_pct=- (1.0)))
    SET index_list->est_pct = 10.0
    IF (dm2_table_and_ccldef_exists("DM_INFO",dgiep_info_exists)=0)
     RETURN(0)
    ENDIF
    IF (dgiep_info_exists=1)
     SET dm_err->eproc = "Determining index estimate percent from dm_info."
     SELECT INTO "nl:"
      FROM dm_info di
      WHERE "DM2_GATHER_INDEX_STATS"=di.info_domain
       AND di.info_name="ESTIMATE_PERCENT*"
       AND di.info_number BETWEEN 0 AND 100
      DETAIL
       CASE (di.info_name)
        OF "ESTIMATE_PERCENT":
         index_list->est_pct = di.info_number,index_list->est_pct_override_ind = 1
        OF "ESTIMATE_PERCENT-UNIQUE":
         index_list->unique_est_pct = di.info_number,index_list->unique_est_pct_override_ind = 1
       ENDCASE
      WITH nocounter, nullreport
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dri_fill_index_list(dril_owner,dril_table_name)
   DECLARE dfil_info_exists = i2 WITH protect, noconstant(0)
   IF (dri_get_ind_est_perc(null)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Querying for list of indexes from dm2_dba_indexes."
   SELECT INTO "nl:"
    FROM dm2_dba_indexes dbi
    WHERE dbi.owner=patstring(dril_owner)
     AND dbi.table_name=patstring(dril_table_name)
    HEAD REPORT
     index_list->index_cnt = 0, stat = alterlist(index_list->qual,index_list->index_cnt), index_list
     ->table_name = dril_table_name,
     index_list->owner = dril_owner
    DETAIL
     index_list->index_cnt = (index_list->index_cnt+ 1), stat = alterlist(index_list->qual,index_list
      ->index_cnt), index_list->qual[index_list->index_cnt].index_name = dbi.index_name,
     index_list->qual[index_list->index_cnt].unique_ind = evaluate(dbi.uniqueness,"UNIQUE",1,0)
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dm2_runstats_ind)
    IF (dm2_table_and_ccldef_exists("DM_INFO",dfil_info_exists)=0)
     RETURN(0)
    ENDIF
    IF (dfil_info_exists=1)
     SET dm_err->eproc = "Selecting indexes with overrides in dm_info."
     SELECT INTO "nl:"
      curr_owner = substring(1,30,substring(1,(findstring(".",di.info_name) - 1),di.info_name)),
      curr_table = substring(1,30,substring((findstring(".",di.info_name)+ 1),(findstring(":",di
         .info_name) - (findstring(".",di.info_name)+ 1)),di.info_name)), curr_index = substring(1,30,
       substring((findstring(":",di.info_name)+ 1),size(di.info_name),di.info_name))
      FROM dm_info di
      WHERE "DM2_RUNSTATS:OVERRIDE_INDEX"=di.info_domain
       AND di.info_name=patstring(concat(dril_owner,".",dril_table_name,":*"))
      ORDER BY di.info_name
      HEAD REPORT
       index_override_list->index_cnt = 0, stat = alterlist(index_override_list->qual,
        index_override_list->index_cnt)
      DETAIL
       index_override_list->index_cnt = (index_override_list->index_cnt+ 1)
       IF (mod(index_override_list->index_cnt,10)=1)
        stat = alterlist(index_override_list->qual,(index_override_list->index_cnt+ 9))
       ENDIF
       index_override_list->qual[index_override_list->index_cnt].owner = curr_owner,
       index_override_list->qual[index_override_list->index_cnt].table_name = curr_table,
       index_override_list->qual[index_override_list->index_cnt].index_name = curr_index,
       index_override_list->qual[index_override_list->index_cnt].est_percent = di.info_number
      FOOT REPORT
       stat = alterlist(index_override_list->qual,index_override_list->index_cnt)
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_script
     ENDIF
     IF ((dm_err->debug_flag > 0))
      CALL echorecord(index_override_list)
     ENDIF
    ENDIF
   ENDIF
   FOR (dgis_iter = 1 TO index_list->index_cnt)
    SET index_list->qual[dgis_iter].est_pct = index_list->est_pct
    IF (dm2_runstats_ind)
     IF (index_list->qual[dgis_iter].unique_ind)
      SET index_list->qual[dgis_iter].est_pct = index_list->unique_est_pct
     ENDIF
     SET dgis_found = 0
     FOR (dgis_iter2 = 1 TO index_override_list->index_cnt)
       IF ((index_list->qual[dgis_iter].index_name=patstring(index_override_list->qual[dgis_iter2].
        index_name)))
        SET dgis_found = dgis_iter2
       ENDIF
     ENDFOR
     IF (dgis_found > 0)
      SET index_list->qual[dgis_iter].est_pct = evaluate(index_override_list->qual[dgis_found].
       est_percent,- (1.0),index_list->est_pct,index_override_list->qual[dgis_found].est_percent)
     ENDIF
    ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dri_fill_table_stats(null)
   DECLARE dfts_info_exists = i4 WITH protect, noconstant(0)
   DECLARE dfts_iter = i4 WITH protect, noconstant(0)
   DECLARE dfts_tmp = i4 WITH protect, noconstant(0)
   DECLARE dfts_num = i4 WITH protect, noconstant(0)
   DECLARE dfts_method_opt = vc WITH protect, noconstant("for all columns size auto")
   DECLARE dfts_block_sample = vc WITH protect, noconstant("true")
   DECLARE dfts_initial_stats = vc WITH protect, noconstant("DM2_RUNSTATS_INITIAL_STATS_ONLY")
   DECLARE dfts_beg_time = dq8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
   DECLARE dfts_end_time = i4 WITH protect, noconstant(360)
   DECLARE dfts_continue_ind = i2 WITH protect, noconstant(0)
   DECLARE dfts_parent = vc WITH protect, noconstant("")
   IF (dm2_table_and_ccldef_exists("DM_INFO",dfts_info_exists)=0)
    RETURN(0)
   ENDIF
   IF (dfts_info_exists=1)
    SET dm_err->eproc = "Checking for override value for stale threshold percent in dm_info."
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE "DM2_RUNSTATS"=di.info_domain
      AND "DB_STALE_PCT_THRESH"=di.info_name
     DETAIL
      table_stats->stale_pct_threshold = greatest(0.0,least(100.0,di.info_number))
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Determining value for rows to sample from dm_info."
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE "DM2_RUNSTATS"=di.info_domain
      AND "DB_ROWS_TO_SAMPLE_MIN"=di.info_name
     DETAIL
      table_stats->rows_to_sample_min = greatest(2500,cnvtint(di.info_number))
     WITH nocounter, nullreport
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ( NOT (dri_get_rows_to_sample(null)))
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Selecting tables with overrides in dm_info."
    SELECT INTO "nl:"
     curr_owner = substring(1,30,substring(1,(findstring(".",di.info_name) - 1),di.info_name)),
     curr_table = substring(1,30,substring((findstring(".",di.info_name)+ 1),size(di.info_name),di
       .info_name))
     FROM dm_info di
     WHERE "DM2_RUNSTATS:OVERRIDE_TABLE"=di.info_domain
     HEAD REPORT
      table_override_list->cnt = 0, stat = alterlist(table_override_list->qual,table_override_list->
       cnt)
     DETAIL
      table_override_list->cnt = (table_override_list->cnt+ 1)
      IF (mod(table_override_list->cnt,10)=1)
       stat = alterlist(table_override_list->qual,(table_override_list->cnt+ 9))
      ENDIF
      table_override_list->qual[table_override_list->cnt].owner = curr_owner, table_override_list->
      qual[table_override_list->cnt].table_name = curr_table, table_override_list->qual[
      table_override_list->cnt].est_percent = di.info_number
     FOOT REPORT
      stat = alterlist(table_override_list->qual,table_override_list->cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dri_fill_histogram_list(null)=0)
    RETURN(0)
   ENDIF
   IF (dm2_get_rdbms_version(null)=0)
    GO TO exit_script
   ENDIF
   IF (dr_use_auto_sample_size_ind=0
    AND (dm2_rdbms_version->level1 >= 9)
    AND (table_stats->gather_option != "LIST_STALE"))
    SET dm_err->eproc = "Querying for tables to be gathered at low percentage from DBA_TABLES"
    SELECT INTO "nl:"
     FROM dm_user_tables_actual_stats dt
     WHERE dt.table_name=patstring(table_stats->table_name)
      AND ((dt.num_rows = null) OR ((dt.num_rows=- (1))))
      AND nullind(dt.tablespace_name)=0
     DETAIL
      low_pct_tables->tbl_cnt = (low_pct_tables->tbl_cnt+ 1)
      IF ((low_pct_tables->tbl_cnt > dfts_tmp))
       dfts_tmp = (dfts_tmp+ 100), stat = alterlist(low_pct_tables->tbl_list,dfts_tmp)
      ENDIF
      low_pct_tables->tbl_list[low_pct_tables->tbl_cnt].owner = table_stats->owner, low_pct_tables->
      tbl_list[low_pct_tables->tbl_cnt].tbl_name = dt.table_name, low_pct_tables->tbl_list[
      low_pct_tables->tbl_cnt].own_tab_key = build(table_stats->owner,".",dt.table_name)
     FOOT REPORT
      stat = alterlist(low_pct_tables->tbl_list,low_pct_tables->tbl_cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    FOR (dfts_iter = 1 TO low_pct_tables->tbl_cnt)
     IF ((program_stack_rs->qual[1].name="DM2_ROUTINE_TASKS"))
      SET dfts_parent = dpq_routine_tasks
     ELSE
      SET dfts_parent = dpq_statistics
     ENDIF
     IF (dpq_check_end_time(dfts_beg_time,dfts_parent,dfts_continue_ind)=0)
      RETURN(0)
     ELSEIF ( NOT (dfts_continue_ind))
      SET dm_err->eproc = "End time window reached, ending dri_fill_table_stats"
      SET dfts_iter = (low_pct_tables->tbl_cnt+ 1)
     ELSE
      SET dm_err->eproc = "Checking for existence of initial_stats_only row from dm_info"
      SELECT INTO "nl:"
       FROM dm_info di
       WHERE di.info_domain=dfts_initial_stats
        AND di.info_name=concat(low_pct_tables->tbl_list[dfts_iter].owner,".",low_pct_tables->
        tbl_list[dfts_iter].tbl_name)
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc))
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      IF ( NOT (curqual))
       SET dm_err->eproc = "Inserting initial_stats_only row into dm_info"
       INSERT  FROM dm_info di
        SET di.info_domain = dfts_initial_stats, di.info_name = concat(low_pct_tables->tbl_list[
          dfts_iter].owner,".",low_pct_tables->tbl_list[dfts_iter].tbl_name)
        WITH nocounter
       ;end insert
       IF (check_error(dm_err->eproc))
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       COMMIT
      ENDIF
      EXECUTE dm2_flexstats "TABLE", value(table_stats->owner), value(low_pct_tables->tbl_list[
       dfts_iter].tbl_name),
      drd_min_est_pct, value(dfts_method_opt), value(dfts_block_sample),
      "FALSE"
      SET dm_err->err_ind = 0
     ENDIF
    ENDFOR
    SET low_pct_tables->tbl_cnt = 0
    SET stat = alterlist(low_pct_tables->tbl_list,0)
    SET dfts_tmp = 0
    SET dm_err->eproc = "Querying for past and current initial_stats_only rows from DM_INFO"
    SELECT INTO "nl:"
     owner = substring(1,30,substring(1,(findstring(".",di.info_name) - 1),di.info_name)), tabname =
     substring(1,30,substring((findstring(".",di.info_name)+ 1),textlen(di.info_name),di.info_name))
     FROM dm_info di
     WHERE di.info_domain=dfts_initial_stats
     DETAIL
      low_pct_tables->tbl_cnt = (low_pct_tables->tbl_cnt+ 1)
      IF ((low_pct_tables->tbl_cnt > dfts_tmp))
       dfts_tmp = (dfts_tmp+ 100), stat = alterlist(low_pct_tables->tbl_list,dfts_tmp)
      ENDIF
      low_pct_tables->tbl_list[low_pct_tables->tbl_cnt].owner = owner, low_pct_tables->tbl_list[
      low_pct_tables->tbl_cnt].tbl_name = tabname, low_pct_tables->tbl_list[low_pct_tables->tbl_cnt].
      own_tab_key = build(owner,".",tabname)
     FOOT REPORT
      stat = alterlist(low_pct_tables->tbl_list,low_pct_tables->tbl_cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc =
   "Selecting tables to gather statistics on from dm2_dba_tables/user_tab_modifications."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    tablespace_null_ind_col = nullind(u.tablespace_name)
    FROM dm_user_tables_actual_stats u,
     user_tab_modifications atm
    WHERE u.table_name=patstring(table_stats->table_name)
     AND outerjoin(u.table_name)=atm.table_name
    ORDER BY u.table_name
    HEAD REPORT
     table_cnt = 0, stat = alterlist(table_stats->stats_cnt,table_cnt), found = 0
    DETAIL
     table_cnt = (table_cnt+ 1)
     IF (mod(table_cnt,50)=1)
      stat = alterlist(table_stats->stats_cnt,(table_cnt+ 49))
     ENDIF
     table_stats->stats_cnt[table_cnt].owner = trim(table_stats->owner), table_stats->stats_cnt[
     table_cnt].tabname = trim(u.table_name), table_stats->stats_cnt[table_cnt].monitoring = trim(u
      .monitoring),
     table_stats->stats_cnt[table_cnt].global_stats = trim(u.global_stats), table_stats->stats_cnt[
     table_cnt].last_analyzed = u.last_analyzed, table_stats->stats_cnt[table_cnt].num_rows = u
     .num_rows,
     table_stats->stats_cnt[table_cnt].table_mods = nullval(((atm.inserts+ atm.updates)+ atm.deletes),
      0.0), table_stats->stats_cnt[table_cnt].inserts = nullval(atm.inserts,0.0), table_stats->
     stats_cnt[table_cnt].updates = nullval(atm.updates,0.0),
     table_stats->stats_cnt[table_cnt].deletes = nullval(atm.deletes,0.0), table_stats->stats_cnt[
     table_cnt].last_mod_dt_tm = nullval(atm.timestamp,0.0), table_stats->stats_cnt[table_cnt].
     mod_trunc_ind = evaluate(atm.truncated,"YES",1,0),
     table_stats->stats_cnt[table_cnt].valid_tspace_ind = (1 - tablespace_null_ind_col)
     IF ((table_stats->gather_option IN ("GATHER_STALE", "LIST_STALE")))
      IF ((table_stats->stats_cnt[table_cnt].monitoring != "YES"))
       table_stats->stats_cnt[table_cnt].stale_pct = 0
      ELSE
       IF (locateval(dfts_num,1,low_pct_tables->tbl_cnt,build(table_stats->stats_cnt[table_cnt].owner,
         ".",table_stats->stats_cnt[table_cnt].tabname),low_pct_tables->tbl_list[dfts_num].
        own_tab_key)
        AND (program_stack_rs->qual[1].name="DM2_ROUTINE_TASKS"))
        table_stats->stats_cnt[table_cnt].stale_pct = 100, table_stats->stats_cnt[table_cnt].
        initial_gather_ind = 1
       ELSEIF ((table_stats->stats_cnt[table_cnt].num_rows=0)
        AND (table_stats->stats_cnt[table_cnt].table_mods > 0))
        table_stats->stats_cnt[table_cnt].stale_pct = 100
       ELSEIF ((table_stats->stats_cnt[table_cnt].deletes > table_stats->stats_cnt[table_cnt].inserts
       ))
        table_stats->stats_cnt[table_cnt].stale_pct = 0
       ELSEIF ((table_stats->stats_cnt[table_cnt].num_rows=0)
        AND (table_stats->stats_cnt[table_cnt].table_mods=0))
        table_stats->stats_cnt[table_cnt].stale_pct = 0
       ELSE
        table_stats->stats_cnt[table_cnt].stale_pct = least(100,round((((table_stats->stats_cnt[
          table_cnt].inserts+ table_stats->stats_cnt[table_cnt].updates)/ table_stats->stats_cnt[
          table_cnt].num_rows) * 100),0))
       ENDIF
      ENDIF
     ENDIF
     IF ((table_stats->stats_cnt[table_cnt].stale_pct >= table_stats->stale_pct_threshold))
      table_stats->stats_cnt[table_cnt].stale_ind = 1
     ENDIF
     CASE (table_stats->gather_option)
      OF "GATHER_STALE":
       table_stats->stats_cnt[table_cnt].gather_ind = table_stats->stats_cnt[table_cnt].stale_ind
      OF "GATHER":
       table_stats->stats_cnt[table_cnt].gather_ind = 1
      OF "LIST_STALE":
       table_stats->stats_cnt[table_cnt].gather_ind = table_stats->stats_cnt[table_cnt].stale_ind
     ENDCASE
     IF ((table_stats->stats_cnt[table_cnt].valid_tspace_ind=0))
      table_stats->stats_cnt[table_cnt].gather_ind = 0
     ENDIF
     IF ((table_stats->stats_cnt[table_cnt].num_rows > 0))
      table_stats->stats_cnt[table_cnt].est_pct = round(least(100,((table_stats->rows_to_sample/
        table_stats->stats_cnt[table_cnt].num_rows) * 100)),6)
     ELSE
      table_stats->stats_cnt[table_cnt].est_pct = 10
     ENDIF
     table_stats->stats_cnt[table_cnt].block_sample = dfts_block_sample, table_stats->stats_cnt[
     table_cnt].method_opt = dfts_method_opt, found = 0
     FOR (dfts_iter = 1 TO table_override_list->cnt)
       IF ((table_stats->stats_cnt[table_cnt].owner=table_override_list->qual[dfts_iter].owner)
        AND (table_stats->stats_cnt[table_cnt].tabname=patstring(table_override_list->qual[dfts_iter]
        .table_name)))
        found = dfts_iter
       ENDIF
     ENDFOR
     IF (found > 0
      AND (table_override_list->qual[found].est_percent != - (1.0)))
      table_stats->stats_cnt[table_cnt].est_pct = table_override_list->qual[found].est_percent
     ENDIF
     IF (assign(found,locateval(found,1,hist_list->table_cnt,table_stats->stats_cnt[table_cnt].
       tabname,hist_list->table_list[found].table_name)))
      FOR (dfts_iter = 1 TO hist_list->table_list[found].column_cnt)
        table_stats->stats_cnt[table_cnt].method_opt = concat(table_stats->stats_cnt[table_cnt].
         method_opt,", for columns ",hist_list->table_list[found].column_list[dfts_iter].method_opt,
         " ",hist_list->table_list[found].column_list[dfts_iter].column_name)
      ENDFOR
     ENDIF
    FOOT REPORT
     table_stats->tbl_cnt = table_cnt, stat = alterlist(table_stats->stats_cnt,table_cnt)
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag >= 1))
    CALL echorecord(table_stats)
   ENDIF
   IF ((table_stats->tbl_cnt=0))
    SET dm_err->eproc = concat("NO TABLES MATCH '",table_stats->owner,".",table_stats->table_name,
     "' - STATS COULD NOT BE RETURNED")
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dri_enable_table_monitoring(null)
   DECLARE detm_attempt = i2 WITH protect, noconstant(0)
   DECLARE detm_count = i4 WITH protect, noconstant(0)
   DECLARE detm_error_ind = i2 WITH protect, noconstant(0)
   DECLARE detm_command = vc WITH protect, noconstant("")
   DECLARE detm_error_cnt = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Enable table monitoring..."
   CALL disp_msg("",dm_err->logfile,0)
   IF ((table_stats->owner IN ("SYS", "SYSTEM")))
    SET dm_err->eproc = concat("Tabled Monitoring bypassed for ",build(table_stats->owner))
    CALL disp_msg("",dm_err->logfile,0)
   ELSE
    FOR (detm_count = 1 TO table_stats->tbl_cnt)
      SET detm_error_ind = 0
      SET detm_attempt = 1
      IF ((table_stats->stats_cnt[detm_count].monitoring="NO")
       AND (table_stats->stats_cnt[detm_count].valid_tspace_ind=1))
       WHILE ((detm_attempt != - (1))
        AND detm_attempt <= cnvtint(dm2_db_options->table_monitoring_maxretry))
         IF ((dm_err->debug_flag >= 2))
          SET dm_err->eproc = concat("Enable monitoring for table ",trim(table_stats->stats_cnt[
            detm_count].tabname)," attempt ",cnvtstring(detm_attempt))
          CALL disp_msg("",dm_err->logfile,0)
         ENDIF
         SET detm_command = concat('RDB ASIS("ALTER TABLE ',table_stats->stats_cnt[detm_count].owner,
          ".",table_stats->stats_cnt[detm_count].tabname,' MONITORING ") go')
         IF (dm2_push_cmd(detm_command,1)=0)
          IF (((findstring("ORA-00054",dm_err->emsg) > 0) OR (findstring("ORA-30006",dm_err->emsg) >
          0)) )
           SET detm_attempt = (detm_attempt+ 1)
           CALL pause(5)
          ELSE
           SET detm_attempt = - (1)
           SET detm_error_ind = 1
          ENDIF
          SET dm_err->err_ind = 0
          SET dm_err->eproc = "The error above is warning only."
          CALL disp_msg("",dm_err->logfile,0)
         ELSE
          SET detm_attempt = - (1)
         ENDIF
       ENDWHILE
       IF (detm_attempt > cnvtint(dm2_db_options->table_monitoring_maxretry))
        SET detm_attempt = cnvtint(dm2_db_options->table_monitoring_maxretry)
        SET detm_error_ind = 1
       ENDIF
       CALL dm2_process_log_add_detail_text(dpl_owner,table_stats->stats_cnt[detm_count].owner)
       CALL dm2_process_log_add_detail_text(dpl_table,table_stats->stats_cnt[detm_count].tabname)
       CALL dm2_process_log_add_detail_text(dpl_cmd,detm_command)
       CALL dm2_process_log_add_detail_number(dpl_num_attempts,cnvtreal(detm_attempt))
       SET dm2_process_event_rs->status = evaluate(detm_error_ind,1,dpl_failure,dpl_success)
       SET dm2_process_event_rs->message = evaluate(detm_error_ind,1,dm_err->emsg,"")
       CALL dm2_process_log_row(dpl_statistics,dpl_enable_table_monitoring,dpl_no_prev_id,1)
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE dri_get_parallel_degree(null)
   SET dm_err->eproc = "Determining Parallelism Degree from dm_info."
   SELECT INTO "nl"
    FROM dm_info di
    WHERE di.info_domain="DM2_RUNSTATS:DEGREE"
     AND di.info_number BETWEEN 1 AND 10
    DETAIL
     CASE (di.info_name)
      OF "TABLE":
       table_stats->table_degree = cnvtint(di.info_number)
      OF "INDEX":
       table_stats->index_degree = cnvtint(di.info_number)
     ENDCASE
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dri_get_rows_to_sample(null)
   SET dm_err->eproc = "Determining value for rows to sample from dm_info."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_RUNSTATS"
     AND di.info_name="DB_ROWS_TO_SAMPLE"
    DETAIL
     table_stats->rows_to_sample = greatest(table_stats->rows_to_sample_min,least(10000000,cnvtint(di
        .info_number)))
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm_ora_pre_stat(i_table_name,i_owner,i_pub_status)
   DECLARE dops_table_name = vc WITH protect, noconstant(trim(i_table_name,3))
   DECLARE dops_owner = vc WITH protect, noconstant(trim(i_owner,3))
   IF ((dm2_rdbms_version->level1=0))
    IF (dm2_get_rdbms_version(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm2_rdbms_version->level1 > 10))
    DECLARE get_prefs(i_p=vc,i_o=vc,i_t=vc) = c5 WITH sql = "sys.dbms_stats.get_prefs"
    DECLARE set_table_prefs(ownname=vc,tabname=vc,pname=vc,pvalue=vc) = null WITH sql =
    "SYS.DBMS_STATS.SET_TABLE_PREFS", parameter
    DECLARE delete_pending_stats(ownname=vc,tabname=vc) = null WITH sql =
    "SYS.DBMS_STATS.DELETE_PENDING_STATS", parameter
    SET dm_err->eproc = "Obtaining current PUBLISH status"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     y = get_prefs("PUBLISH",dops_owner,dops_table_name)
     FROM dual
     DETAIL
      i_pub_status = cnvtupper(y)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF (i_pub_status="TRUE")
     SET dm_err->eproc = concat("Setting PUBLISH to FALSE for ",dops_table_name)
     CALL set_table_prefs(dops_owner,dops_table_name,"PUBLISH","FALSE")
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    SET dm_err->eproc = concat("Delete Pending Stats for ",dops_table_name)
    CALL delete_pending_stats(dops_owner,dops_table_name)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm_ora_post_stat(i_table_name,i_owner)
   DECLARE dopos_table_name = vc WITH protect, noconstant(trim(i_table_name,3))
   DECLARE dopos_owner = vc WITH protect, noconstant(trim(i_owner,3))
   DECLARE export_pending_stats(ownname=vc,tabname=vc,stattab=vc,statid=vc) = null WITH sql =
   "SYS.DBMS_STATS.EXPORT_PENDING_STATS", parameter
   IF ((dm2_rdbms_version->level1=0))
    IF (dm2_get_rdbms_version(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm2_rdbms_version->level1 > 10))
    SET dm_err->eproc = concat("Export Pending Stats for ",dopos_table_name)
    CALL export_pending_stats(dopos_owner,dopos_table_name,"DM_STAT_TABLE","ACTUAL")
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm_ora_fin_clean(i_table_name,i_owner,i_pub_status)
   DECLARE dofc_table_name = vc WITH protect, noconstant(trim(i_table_name,3))
   DECLARE dofc_owner = vc WITH protect, noconstant(trim(i_owner,3))
   DECLARE dofc_err_ind = i2 WITH protect, noconstant(0)
   DECLARE set_table_prefs(ownname=vc,tabname=vc,pname=vc,pvalue=vc) = null WITH sql =
   "SYS.DBMS_STATS.SET_TABLE_PREFS", parameter
   SET dofc_err_ind = dm_err->err_ind
   SET dm_err->err_ind = 0
   IF ((dm2_rdbms_version->level1=0))
    IF (dm2_get_rdbms_version(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm2_rdbms_version->level1 > 10))
    IF (i_pub_status="TRUE")
     SET dm_err->eproc = concat("Setting PUBLISH to TRUE for ",dofc_table_name)
     CALL set_table_prefs(dofc_owner,dofc_table_name,"PUBLISH","TRUE")
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF (dofc_err_ind != 0)
    SET dm_err->err_ind = dofc_err_ind
   ENDIF
   RETURN(1)
 END ;Subroutine
END GO
