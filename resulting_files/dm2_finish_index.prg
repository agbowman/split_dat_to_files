CREATE PROGRAM dm2_finish_index
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
 DECLARE ddf_autosuccess_init(null) = i2
 DECLARE ddf_check_lock(dcl_process=vc,dcl_object=vc,dcl_process_code=i2,dcl_lock_available_ind=i2(
   ref)) = i2
 DECLARE ddf_get_lock(dgl_process=vc,dgl_object=vc,dgl_process_code=i2,dgl_lock_obtained_ind=i2(ref))
  = i2
 DECLARE ddf_release_lock(drl_process=vc,drl_object=vc,drl_process_code=i2) = i2
 DECLARE ddf_get_audsid_list(dgal_process=vc,dgal_object=vc,dgal_process_code=i2) = i2
 DECLARE ddf_clean_dpq(dcd_process_type=vc,dcd_obj_name=vc) = i2
 DECLARE ddf_clean_dst(dcd_statid=vc) = i2
 DECLARE ddf_clean_dpe(dcd_process_name=vc,dcd_program_name=vc) = i2
 DECLARE ddf_check_in_parse(dcp_owner=vc,dcp_table_name=vc,dcp_in_parse_ind=i2(ref),dcp_ret_msg=vc(
   ref)) = i2
 DECLARE ddf_get_publish_retry(dcp_retry_ceiling=i2(ref)) = i2
 DECLARE ddf_check_wait_pref(dcwp_pref_set_ind=i2(ref),dcwp_adb_ind=i2) = i2
 DECLARE ddf_get_object_id(dgoi_owner=vc,dgoi_table_name=vc,dgoi_object_id=f8(ref)) = i2
 DECLARE ddf_get_context_pkg_data(null) = i2
 DECLARE ddf_context_lock_maint(dclm_mode=vc,dclm_process=vc,dclm_process_code=i2,dclm_owner=vc,
  dclm_table_name=vc,
  dclm_object_id=f8,dclm_lock_ind=i2(ref)) = i2
 IF (validate(dgdt_prefs->in_object_type,"X")="X"
  AND validate(dgdt_prefs->in_object_type,"Y")="Y")
  FREE RECORD dgdt_prefs
  RECORD dgdt_prefs(
    1 in_object_type = vc
    1 in_object_owner = vc
    1 in_object_name = vc
    1 in_table_name = vc
    1 in_mode = vc
    1 in_object_id = vc
    1 table_owner = vc
    1 object_exists_ind = i2
    1 custom_prefs = vc
    1 di_exclusion = vc
    1 autosuccess_ind = i2
    1 context_lock_ind = i2
    1 context_lock_schema = vc
    1 method_opt_size254_ind_def = vc
    1 method_opt_size254_nonind_def = vc
    1 est_pct = vc
    1 est_pct_idx = vc
    1 method_opt = vc
    1 method_opt_dped = vc
    1 degree = vc
    1 degree_idx = vc
    1 cascade = vc
    1 publish = vc
    1 wait_time_pref_active = i2
    1 stale_pct = vc
    1 block_sample = vc
    1 granularity = vc
    1 granularity_idx = vc
    1 no_invalidate = vc
    1 no_invalidate_idx = vc
    1 di_est_pct = vc
    1 di_est_pct_idx = vc
    1 di_method_opt = vc
    1 di_degree = vc
    1 di_degree_idx = vc
    1 di_cascade = vc
    1 di_publish = vc
    1 di_stale_pct = vc
    1 di_block_sample = vc
    1 di_granularity = vc
    1 di_granularity_idx = vc
    1 di_no_invalidate = vc
    1 di_no_invalidate_idx = vc
    1 col_cnt = i2
    1 cols[*]
      2 column_name = vc
      2 data_type = vc
      2 method_opt = vc
      2 di_method_opt = vc
  )
  SET dgdt_prefs->autosuccess_ind = - (1)
  SET dgdt_prefs->context_lock_ind = - (1)
  SET dgdt_prefs->context_lock_schema = "DM2NOTSET"
  SET dgdt_prefs->in_object_type = "DM2NOTSET"
  SET dgdt_prefs->in_object_owner = "DM2NOTSET"
  SET dgdt_prefs->in_object_name = "DM2NOTSET"
  SET dgdt_prefs->in_table_name = "DM2NOTSET"
  SET dgdt_prefs->custom_prefs = "DM2NOTSET"
  SET dgdt_prefs->di_exclusion = "DM2NOTSET"
  SET dgdt_prefs->est_pct = "DM2NOTSET"
  SET dgdt_prefs->method_opt = "DM2NOTSET"
  SET dgdt_prefs->degree = "DM2NOTSET"
  SET dgdt_prefs->cascade = "DM2NOTSET"
  SET dgdt_prefs->publish = "DM2NOTSET"
  SET dgdt_prefs->stale_pct = "DM2NOTSET"
  SET dgdt_prefs->block_sample = "DM2NOTSET"
  SET dgdt_prefs->granularity = "DM2NOTSET"
  SET dgdt_prefs->no_invalidate = "DM2NOTSET"
  SET dgdt_prefs->est_pct_idx = "DM2NOTSET"
  SET dgdt_prefs->degree_idx = "DM2NOTSET"
  SET dgdt_prefs->granularity_idx = "DM2NOTSET"
  SET dgdt_prefs->no_invalidate_idx = "DM2NOTSET"
  SET dgdt_prefs->di_est_pct = "DM2NOTSET"
  SET dgdt_prefs->di_method_opt = "DM2NOTSET"
  SET dgdt_prefs->di_degree = "DM2NOTSET"
  SET dgdt_prefs->di_cascade = "DM2NOTSET"
  SET dgdt_prefs->di_publish = "DM2NOTSET"
  SET dgdt_prefs->di_stale_pct = "DM2NOTSET"
  SET dgdt_prefs->di_block_sample = "DM2NOTSET"
  SET dgdt_prefs->di_granularity = "DM2NOTSET"
  SET dgdt_prefs->di_no_invalidate = "DM2NOTSET"
  SET dgdt_prefs->di_est_pct_idx = "DM2NOTSET"
  SET dgdt_prefs->di_degree_idx = "DM2NOTSET"
  SET dgdt_prefs->di_granularity_idx = "DM2NOTSET"
  SET dgdt_prefs->di_no_invalidate_idx = "DM2NOTSET"
 ENDIF
 IF (validate(ddf_audsids->cnt,0)=0
  AND validate(ddf_audsids->cnt,1)=1)
  FREE RECORD ddf_audsids
  RECORD ddf_audsids(
    1 cnt = i4
    1 active_audsid_str = vc
    1 active_audsid_cnt = i4
    1 qual[*]
      2 audsid = vc
      2 active_ind = i2
  )
 ENDIF
 SUBROUTINE ddf_autosuccess_init(null)
   DECLARE ddfai_info_exists = i2 WITH protect, noconstant(0)
   DECLARE ddfai_cclversion = i4 WITH protect, constant((((cnvtint(currev) * 10000)+ (cnvtint(
     currevminor) * 100))+ cnvtint(currevminor2)))
   IF ((dgdt_prefs->autosuccess_ind=- (1)))
    IF (ddfai_cclversion < 80506)
     SET dm_err->eproc = "CCL Version 8.5.6 or higher required to run dm2*dbstats* scripts."
     SET dgdt_prefs->autosuccess_ind = 1
     CALL disp_msg(" ",dm_err->logfile,0)
     RETURN(1)
    ENDIF
    SET dm_err->eproc = "Check for DM_INFO CCL definition"
    IF (checkdic("DM_INFO","T",0)=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg =
     "CCL Definition not found for DM_INFO for statistics processing. Auto-successing..."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Check for DM_INFO table existance"
    SELECT INTO "nl:"
     FROM dba_objects d
     WHERE d.object_name="DM_INFO"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (curqual=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "No DM_INFO object found for statistics processing. Auto-successing..."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dm2_get_rdbms_version(null)=0)
     RETURN(0)
    ENDIF
    IF ((dm2_rdbms_version->level1 < 11))
     SET dm_err->eproc = "Oracle version < 11g, Auto-successing...."
     SET dgdt_prefs->autosuccess_ind = 1
     CALL disp_msg(" ",dm_err->logfile,0)
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_get_audsid_list(dgal_process,dgal_object,dgal_process_code)
   DECLARE dgal_audsid_list = vc WITH protect, noconstant("")
   DECLARE dgal_str = vc WITH protect, noconstant("")
   DECLARE dgal_notfnd = vc WITH protect, constant("<not_found>")
   DECLARE dgal_num = i4 WITH protect, noconstant(1)
   SET ddf_audsids->cnt = 0
   SET ddf_audsids->active_audsid_str = ""
   SET ddf_audsids->active_audsid_cnt = 0
   SET stat = alterlist(ddf_audsids->qual,ddf_audsids->cnt)
   SET dm_err->eproc = concat("Getting list of audsids from dm_info for ",dgal_process,":",
    dgal_object)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=cnvtupper(dgal_process)
     AND di.info_name=patstring(cnvtupper(dgal_object))
     AND di.info_number=dgal_process_code
    DETAIL
     dgal_audsid_list = di.info_char
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    WHILE (dgal_str != dgal_notfnd)
     SET dgal_str = piece(dgal_audsid_list,",",dgal_num,dgal_notfnd)
     IF (dgal_str != dgal_notfnd)
      SET ddf_audsids->cnt = (ddf_audsids->cnt+ 1)
      SET stat = alterlist(ddf_audsids->qual,ddf_audsids->cnt)
      SET ddf_audsids->qual[ddf_audsids->cnt].audsid = dgal_str
      SET dgal_num = (dgal_num+ 1)
     ENDIF
    ENDWHILE
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(ddf_audsids)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_check_lock(dcl_process,dcl_object,dcl_process_code,dcl_lock_available_ind)
   DECLARE dcl_audsid_list = vc WITH protect, noconstant("")
   DECLARE dcl_num = i4 WITH protect, noconstant(0)
   SET dcl_lock_available_ind = 0
   IF (ddf_get_audsid_list(dcl_process,dcl_object,dcl_process_code)=0)
    RETURN(0)
   ENDIF
   IF ((ddf_audsids->cnt > 0))
    FOR (dcl_num = 1 TO ddf_audsids->cnt)
      IF (dar_get_appl_status(ddf_audsids->qual[dcl_num].audsid)="A")
       IF ((ddf_audsids->qual[dcl_num].audsid != currdbhandle))
        SET ddf_audsids->qual[dcl_num].active_ind = 1
        SET ddf_audsids->active_audsid_cnt = (ddf_audsids->active_audsid_cnt+ 1)
        IF ((ddf_audsids->active_audsid_cnt=1))
         SET ddf_audsids->active_audsid_str = ddf_audsids->qual[dcl_num].audsid
        ELSE
         SET ddf_audsids->active_audsid_str = concat(ddf_audsids->active_audsid_str,",",ddf_audsids->
          qual[dcl_num].audsid)
        ENDIF
       ENDIF
      ELSE
       SET ddf_audsids->qual[dcl_num].active_ind = 0
      ENDIF
    ENDFOR
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(ddf_audsids)
    ENDIF
    IF ((ddf_audsids->active_audsid_cnt > 0))
     SET dm_err->eproc = "Update lock row in dm_info with active audsid list"
     UPDATE  FROM dm_info di
      SET di.info_char = ddf_audsids->active_audsid_str
      WHERE di.info_domain=cnvtupper(dcl_process)
       AND di.info_name=patstring(cnvtupper(dcl_object))
       AND di.info_number=dcl_process_code
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
    ELSE
     SET dm_err->eproc = "Delete lock row in dm_info"
     DELETE  FROM dm_info di
      WHERE di.info_domain=cnvtupper(dcl_process)
       AND di.info_name=patstring(cnvtupper(dcl_object))
       AND di.info_number=dcl_process_code
      WITH nocounter
     ;end delete
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
     SET dcl_lock_available_ind = 1
    ENDIF
    COMMIT
   ELSE
    SET dcl_lock_available_ind = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_get_lock(dgl_process,dgl_object,dgl_process_code,dgl_lock_obtained_ind)
   SET dgl_lock_obtained_ind = 0
   SET dm_err->eproc = concat("Inserting/Updating dm_info run_lock row for ",dgl_process,":",
    dgl_object)
   CALL disp_msg(" ",dm_err->logfile,10)
   SET dm_err->eproc = "Merge lock row in dm_info with current audsid"
   MERGE INTO dm_info d
   USING DUAL ON (d.info_domain=cnvtupper(dgl_process)
    AND d.info_name=cnvtupper(dgl_object)
    AND d.info_number=dgl_process_code)
   WHEN MATCHED THEN
   (UPDATE
    SET d.info_char = concat(d.info_char,",",currdbhandle)
    WHERE 1=1
   ;end update
   )
   WHEN NOT MATCHED THEN
   (INSERT  FROM d
    (info_domain, info_name, info_number,
    info_char)
    VALUES(cnvtupper(dgl_process), cnvtupper(dgl_object), dgl_process_code,
    currdbhandle)
    WITH nocounter
   ;end insert
   )
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    IF (findstring("ORA-00001",dm_err->emsg) > 0)
     SET dm_err->eproc = concat(
      "Bypass Oracle error ORA-00001.  Will retry obtaining dm_info run_lock row for ",dgl_object)
     CALL disp_msg(" ",dm_err->logfile,0)
     SET dgl_lock_obtained_ind = 0
     SET dm_err->err_ind = 0
     SET dm_err->emsg = " "
     RETURN(1)
    ELSE
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   COMMIT
   IF (curqual > 0)
    SET dgl_lock_obtained_ind = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_release_lock(drl_process,drl_object,drl_process_code)
   DECLARE drl_num = i4 WITH protect, noconstant(0)
   IF (ddf_get_audsid_list(drl_process,drl_object,drl_process_code)=0)
    RETURN(0)
   ENDIF
   IF ((ddf_audsids->cnt > 0))
    FOR (drl_num = 1 TO ddf_audsids->cnt)
      IF (dar_get_appl_status(ddf_audsids->qual[drl_num].audsid)="A"
       AND (ddf_audsids->qual[drl_num].audsid != currdbhandle))
       SET ddf_audsids->qual[drl_num].active_ind = 1
       SET ddf_audsids->active_audsid_cnt = (ddf_audsids->active_audsid_cnt+ 1)
       IF ((ddf_audsids->active_audsid_cnt=1))
        SET ddf_audsids->active_audsid_str = ddf_audsids->qual[drl_num].audsid
       ELSE
        SET ddf_audsids->active_audsid_str = concat(ddf_audsids->active_audsid_str,",",ddf_audsids->
         qual[drl_num].audsid)
       ENDIF
      ELSE
       SET ddf_audsids->qual[drl_num].active_ind = 0
      ENDIF
    ENDFOR
   ENDIF
   IF ((ddf_audsids->active_audsid_cnt > 0))
    SET dm_err->eproc = concat("Updating dm_info run_lock row for ",drl_process,":",drl_object)
    CALL disp_msg(" ",dm_err->logfile,10)
    UPDATE  FROM dm_info di
     SET di.info_char = ddf_audsids->active_audsid_str
     WHERE di.info_domain=cnvtupper(drl_process)
      AND di.info_name=cnvtupper(drl_object)
      AND di.info_number=drl_process_code
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->eproc = concat("Deleting dm_info run_lock row for ",drl_process,":",drl_object)
    CALL disp_msg(" ",dm_err->logfile,10)
    DELETE  FROM dm_info di
     WHERE di.info_domain=cnvtupper(drl_process)
      AND di.info_name=cnvtupper(drl_object)
      AND di.info_number=drl_process_code
     WITH nocounter
    ;end delete
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ENDIF
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_clean_dpq(dcd_process_type,dcd_obj_name)
   SET dm_err->eproc = concat("Clean up dm_process_queue rows for ",dcd_process_type,":",dcd_obj_name
    )
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dm_err->eproc = concat("Retrieve dm_process_queue rows for ",dcd_process_type,":",dcd_obj_name
    )
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_process_queue dpq
    WHERE dpq.process_type=dcd_process_type
     AND dpq.object_name=patstring(dcd_obj_name)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = concat("No rows found in dm_process_queue for ",dcd_process_type,":",
     dcd_obj_name)
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   SET dm_err->eproc = concat("Non-Existent Objects: Clean up dm_process_queue rows for ",
    dcd_process_type,":",dcd_obj_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   DELETE  FROM dm_process_queue q
    WHERE q.process_type=dcd_process_type
     AND q.object_name=patstring(dcd_obj_name)
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM dba_objects d
     WHERE d.owner=q.owner_name
      AND d.object_name=q.object_name
      AND d.object_type=q.object_type)))
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   COMMIT
   SET dm_err->eproc = concat("Successful Operations: Clean up dm_process_queue rows for ",
    dcd_process_type,":",dcd_obj_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   DELETE  FROM dm_process_queue q
    WHERE q.process_type=dcd_process_type
     AND q.object_name=patstring(dcd_obj_name)
     AND q.process_status="SUCCESS"
     AND  NOT ( EXISTS (
    (SELECT
     "X"
     FROM dm_stat_table d,
      dba_objects o
     WHERE sqlpassthru("d.statid like 'DMSTG%'")
      AND sqlpassthru("d.statid = decode(o.object_type,'INDEX','DMSTG_I'||o.object_id,'DMSTG_T')")
      AND d.c1=o.object_name
      AND d.c5=o.owner
      AND d.type IN ("T", "I")
      AND sqlpassthru("d.type = decode(o.object_type,'INDEX','I','TABLE','T')")
      AND o.object_type IN ("TABLE", "INDEX")
      AND q.process_type=dcd_process_type
      AND q.owner_name=d.c5
      AND q.object_type IN ("TABLE", "INDEX")
      AND q.object_name=d.c1
      AND q.owner_name=o.owner
      AND q.object_name=o.object_name
      AND q.object_type=o.object_type)))
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_clean_dst(dcd_statid)
   FREE RECORD dst_list
   RECORD dst_list(
     1 cnt = i4
     1 qual[*]
       2 statid = vc
       2 obj_name = vc
       2 owner = vc
       2 obj_exists = i2
   )
   SET dm_err->eproc = concat("Clean up dm_stat_table rows for ",dcd_statid)
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dcd_statid="GOLDAVG")
    SET dm_err->eproc = "Deleting ALL GOLDAVG rows from dm_stat_table"
    CALL disp_msg(" ",dm_err->logfile,0)
    DELETE  FROM dm_stat_table dst
     WHERE dst.statid="GOLDAVG"
     WITH nocounter
    ;end delete
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ENDIF
    COMMIT
    RETURN(1)
   ENDIF
   SET dm_err->eproc = concat("Retrieve dm_stat_table rows for ",dcd_statid)
   SELECT DISTINCT INTO "nl:"
    dst.statid, dst.c1, dst.c5
    FROM dm_stat_table dst
    WHERE dst.statid=patstring(dcd_statid)
    HEAD REPORT
     dst_list->cnt = 0, stat = alterlist(dst_list->qual,0)
    DETAIL
     dst_list->cnt = (dst_list->cnt+ 1), stat = alterlist(dst_list->qual,dst_list->cnt), dst_list->
     qual[dst_list->cnt].statid = dst.statid,
     dst_list->qual[dst_list->cnt].obj_name = dst.c1, dst_list->qual[dst_list->cnt].owner = dst.c5,
     dst_list->qual[dst_list->cnt].obj_exists = 0
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dst_list->cnt=0))
    SET dm_err->eproc = concat("No rows found in dm_stat_table for ",dcd_statid)
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Verifying existence of objects in dm_stat_table"
   SELECT INTO "nl:"
    FROM dba_objects do,
     (dummyt d  WITH seq = value(dst_list->cnt))
    PLAN (d
     WHERE d.seq > 0)
     JOIN (do
     WHERE (do.owner=dst_list->qual[d.seq].owner)
      AND (do.object_name=dst_list->qual[d.seq].obj_name))
    DETAIL
     IF ((dst_list->qual[d.seq].statid=patstring("DMSTG_I*")))
      IF (replace(dst_list->qual[d.seq].statid,"DMSTG_I","",0)=trim(cnvtstring(do.object_id)))
       dst_list->qual[d.seq].obj_exists = 1
      ENDIF
     ELSE
      dst_list->qual[d.seq].obj_exists = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dst_list)
   ENDIF
   SET dm_err->eproc = concat("Delete dm_stat_table rows for ",dcd_statid)
   DELETE  FROM dm_stat_table dst,
     (dummyt d  WITH seq = value(dst_list->cnt))
    SET dst.seq = 1
    PLAN (d
     WHERE d.seq > 0
      AND (dst_list->qual[d.seq].obj_exists=0))
     JOIN (dst
     WHERE (dst.statid=dst_list->qual[d.seq].statid)
      AND (dst.c1=dst_list->qual[d.seq].obj_name)
      AND (dst.c5=dst_list->qual[d.seq].owner))
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_clean_dpe(dcd_process_name,dcd_program_name)
   DECLARE forndx1 = i4 WITH protect, noconstant(0)
   DECLARE forndx2 = i4 WITH protect, noconstant(0)
   IF ((validate(dpe_list->cnt,- (1))=- (1))
    AND (validate(dpe_list->cnt,- (2))=- (2)))
    FREE RECORD dpe_list
    RECORD dpe_list(
      1 cnt = i4
      1 qual[*]
        2 dp_id = f8
        2 program_name = vc
        2 dpe_cnt = i4
        2 qual2[*]
          3 dpe_id = f8
          3 owner = vc
          3 obj_name = vc
          3 dpe_status = vc
          3 dpe_audsid = vc
          3 dpe_current_ind = i2
    )
   ENDIF
   SET dm_err->eproc = concat("Clean up dm_process_event rows for ",dcd_process_name,":",
    dcd_program_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dm_err->eproc = concat("Retrieve dm_process rows for ",dcd_process_name,":",dcd_program_name)
   SELECT INTO "nl:"
    FROM dm_process dp,
     dm_process_event dpe,
     dm_process_event_dtl dped
    PLAN (dp
     WHERE dp.process_name=dcd_process_name
      AND dp.program_name=patstring(dcd_program_name))
     JOIN (dpe
     WHERE dpe.dm_process_id=dp.dm_process_id
      AND dpe.event_status="EXECUTING")
     JOIN (dped
     WHERE dped.dm_process_event_id=dpe.dm_process_event_id)
    ORDER BY dp.dm_process_id, dpe.dm_process_event_id
    HEAD REPORT
     dpe_list->cnt = 0, stat = alterlist(dpe_list->qual,0)
    HEAD dp.dm_process_id
     dpe_list->cnt = (dpe_list->cnt+ 1), stat = alterlist(dpe_list->qual,dpe_list->cnt), dpe_list->
     qual[dpe_list->cnt].dp_id = dp.dm_process_id,
     dpe_list->qual[dpe_list->cnt].program_name = dp.program_name
    HEAD dpe.dm_process_event_id
     dpe_list->qual[dpe_list->cnt].dpe_cnt = (dpe_list->qual[dpe_list->cnt].dpe_cnt+ 1), stat =
     alterlist(dpe_list->qual[dpe_list->cnt].qual2,dpe_list->qual[dpe_list->cnt].dpe_cnt), dpe_list->
     qual[dpe_list->cnt].qual2[dpe_list->qual[dpe_list->cnt].dpe_cnt].dpe_id = dpe
     .dm_process_event_id,
     dpe_list->qual[dpe_list->cnt].qual2[dpe_list->qual[dpe_list->cnt].dpe_cnt].dpe_status = dpe
     .event_status
    DETAIL
     IF (dped.detail_type=dpl_owner)
      dpe_list->qual[dpe_list->cnt].qual2[dpe_list->qual[dpe_list->cnt].dpe_cnt].owner = dped
      .detail_text
     ENDIF
     IF (dped.detail_type IN (dpl_table, "TABLE_NAME", dpl_index, "INDEX_NAME"))
      dpe_list->qual[dpe_list->cnt].qual2[dpe_list->qual[dpe_list->cnt].dpe_cnt].obj_name = dped
      .detail_text
     ENDIF
     IF (dped.detail_type=dpl_audsid)
      dpe_list->qual[dpe_list->cnt].qual2[dpe_list->qual[dpe_list->cnt].dpe_cnt].dpe_audsid = dped
      .detail_text
     ENDIF
     dpe_list->qual[dpe_list->cnt].qual2[dpe_list->qual[dpe_list->cnt].dpe_cnt].dpe_current_ind = 0
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dpe_list->cnt=0))
    SET dm_err->eproc = concat("No rows found in dm_process table for ",dcd_process_name,":",
     dcd_program_name)
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dpe_list)
   ENDIF
   FOR (forndx1 = 1 TO dpe_list->cnt)
     FOR (forndx2 = 1 TO dpe_list->qual[forndx1].dpe_cnt)
       IF ((dpe_list->qual[forndx1].qual2[forndx2].dpe_status=dpl_executing))
        IF ((dpe_list->qual[forndx1].qual2[forndx2].dpe_audsid > " "))
         IF (dar_get_appl_status(dpe_list->qual[forndx1].qual2[forndx2].dpe_audsid)="A")
          SET dpe_list->qual[forndx1].qual2[forndx2].dpe_current_ind = 1
         ENDIF
        ELSE
         IF ((dpe_list->qual[forndx1].program_name=patstring("DM2_GATHER_DBSTATS*")))
          SET dm_err->eproc = concat("Checking dm_process_queue row for: ",dpe_list->qual[forndx1].
           qual2[forndx2].owner,":",dpe_list->qual[forndx1].qual2[forndx2].obj_name)
          SELECT INTO "nl:"
           FROM dm_process_queue dpq
           WHERE dpq.process_type=dpq_statistics
            AND dpq.op_type=dpq_gather
            AND (dpq.owner_name=dpe_list->qual[forndx1].qual2[forndx2].owner)
            AND (dpq.object_name=dpe_list->qual[forndx1].qual2[forndx2].obj_name)
           DETAIL
            IF (dpq.process_status=dpq_executing)
             dpe_list->qual[forndx1].qual2[forndx2].dpe_current_ind = 1
            ENDIF
           WITH nocounter
          ;end select
          IF (check_error(dm_err->eproc)=1)
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           RETURN(0)
          ENDIF
         ELSEIF ((dpe_list->qual[forndx1].program_name=patstring("DM2_PUBLISH_DBSTATS*")))
          SET dm_err->eproc = concat("Checking dm_stat_table row for: ",dpe_list->qual[forndx1].
           qual2[forndx2].owner,":",dpe_list->qual[forndx1].qual2[forndx2].obj_name)
          SELECT INTO "nl:"
           FROM dm_stat_table dst
           WHERE dst.statid=patstring("DMSTG*")
            AND (dst.c5=dpe_list->qual[forndx1].qual2[forndx2].owner)
            AND (dst.c1=dpe_list->qual[forndx1].qual2[forndx2].obj_name)
           DETAIL
            dpe_list->qual[forndx1].qual2[forndx2].dpe_current_ind = 1
           WITH nocounter
          ;end select
          IF (check_error(dm_err->eproc)=1)
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           RETURN(0)
          ENDIF
         ELSE
          SET dpe_list->qual[forndx1].qual2[forndx2].dpe_current_ind = 1
         ENDIF
        ENDIF
        IF ((dpe_list->qual[forndx1].qual2[forndx2].dpe_current_ind=0))
         SET dm_err->eproc = concat("Update dm_process_event rows for dm_process_event_id: ",trim(
           cnvtstring(dpe_list->qual[forndx1].qual2[forndx2].dpe_id)))
         CALL disp_msg(" ",dm_err->logfile,0)
         UPDATE  FROM dm_process_event dpe
          SET dpe.event_status = dpl_failure, dpe.end_dt_tm = cnvtdatetime(curdate,curtime3), dpe
           .message_txt =
           "Status updated to FAILURE by dm2_cleanup_dbstats_rows due to orphaned session",
           dpe.updt_dt_tm = cnvtdatetime(curdate,curtime3)
          WHERE (dpe.dm_process_event_id=dpe_list->qual[forndx1].qual2[forndx2].dpe_id)
           AND dpe.event_status=dpl_executing
          WITH nocounter
         ;end update
         IF (check_error(dm_err->eproc) != 0)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          ROLLBACK
          RETURN(0)
         ENDIF
         COMMIT
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_check_in_parse(dcp_owner,dcp_table_name,dcp_in_parse_ind,dcp_ret_msg)
   SET dcp_in_parse_ind = 0
   SET dcp_ret_msg = ""
   SET dm_err->eproc = "Check if object being published is involved in a hard parse event"
   SELECT INTO "nl:"
    FROM dm2_objects_in_parse d
    WHERE d.to_owner=dcp_owner
     AND d.to_name=dcp_table_name
    DETAIL
     dcp_in_parse_ind = 1, dcp_ret_msg = concat("Encountered parse event against ",dcp_owner,".",
      dcp_table_name,". SQL_ID = ",
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
 SUBROUTINE ddf_get_publish_retry(dcp_retry_ceiling)
   SET dcp_retry_ceiling = 10
   SET dm_err->eproc = "Check for retry ceiling override"
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2GDBS:PUBLISH_RETRY"
     AND d.info_name="RETRY CEILING"
    DETAIL
     dcp_retry_ceiling = d.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_check_wait_pref(dcwp_pref_set_ind,dcwp_adb_ind)
   DECLARE dcwp_set_pref_value = i2 WITH protect, noconstant(0)
   DECLARE dcwp_cur_pref_value = i2 WITH protect, noconstant(0)
   DECLARE dcwp_pref_available_ind = i2 WITH protect, noconstant(0)
   DECLARE get_dbms_stat_prefs(pname=vc) = c255 WITH sql = "SYS.DBMS_STATS.GET_PREFS", parameter
   DECLARE set_dbms_stat_prefs(pname=vc,pvalue=vc) = null WITH sql =
   "SYS.DBMS_STATS.SET_GLOBAL_PREFS", parameter
   SET dcwp_pref_set_ind = 0
   IF ((dm2_rdbms_version->level1=0))
    IF (dm2_get_rdbms_version(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((((dm2_rdbms_version->level1 > 11)) OR ((((dm2_rdbms_version->level1=11)
    AND (dm2_rdbms_version->level2 > 2)) OR ((((dm2_rdbms_version->level1=11)
    AND (dm2_rdbms_version->level2=2)
    AND (dm2_rdbms_version->level3 > 0)) OR ((dm2_rdbms_version->level1=11)
    AND (dm2_rdbms_version->level2=2)
    AND (dm2_rdbms_version->level3=0)
    AND (dm2_rdbms_version->level4 >= 4))) )) )) )
    CALL echo("11204 or higher")
   ELSE
    SET dcwp_pref_set_ind = 0
    SET dm_err->eproc = concat("WAIT_TIME_TO_UPDATE_STATS pref not available (ORAVER)")
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   IF (dcwp_adb_ind=0)
    SET dm_err->eproc = "Check if wait pref available"
    SELECT INTO "nl:"
     dcwp_sel_cnt = count(*)
     FROM (sys.optstat_hist_control$ o)
     WHERE o.sname="WAIT_TIME_TO_UPDATE_STATS"
     DETAIL
      IF (dcwp_sel_cnt > 0)
       dcwp_pref_available_ind = 1
      ELSE
       dcwp_pref_available_ind = 0
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dcwp_pref_available_ind=0)
    SET dcwp_pref_set_ind = 0
    SET dm_err->eproc = concat("WAIT_TIME_TO_UPDATE_STATS pref not available (NOT SET)")
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Check for wait pref override"
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2GDBS:GLOBAL_PREF"
     AND d.info_name="WAIT_TIME_TO_UPDATE_STATS"
    DETAIL
     dcwp_set_pref_value = d.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dcwp_cur_pref_value = - (1)
   SET dm_err->eproc = "Check value of wait pref"
   SELECT INTO "nl:"
    dcwp_sel_pref_value = get_dbms_stat_prefs("WAIT_TIME_TO_UPDATE_STATS")
    FROM dual
    DETAIL
     dcwp_cur_pref_value = cnvtint(dcwp_sel_pref_value)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dcwp_cur_pref_value != dcwp_set_pref_value)
    SET dm_err->eproc = concat("Setting wait preference to ",cnvtstring(dcwp_set_pref_value))
    CALL set_dbms_stat_prefs("WAIT_TIME_TO_UPDATE_STATS",cnvtstring(dcwp_set_pref_value))
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = concat("WAIT_TIME_TO_UPDATE_STATS set to ",cnvtstring(dcwp_set_pref_value))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET dcwp_pref_set_ind = 1
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_get_object_id(dgoi_owner,dgoi_table_name,dgoi_object_id)
   SET dm_err->eproc = concat("Query to retrieve object id for table_name :",dgoi_table_name)
   IF ((dm_err->debug_flag > 5))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dba_objects d
    WHERE d.owner=dgoi_owner
     AND d.object_name=dgoi_table_name
     AND d.object_type="TABLE"
    DETAIL
     dgoi_object_id = d.object_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_get_context_pkg_data(null)
   DECLARE dgcpd_pkg_qry_cnt = i2 WITH protect, noconstant(0)
   DECLARE dgcpd_pkg_valid_cnt = i2 WITH protect, noconstant(0)
   DECLARE dgcpd_contxt_cnt = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Check for CERADM.SD_DB_PROCESS_CONTEXT_MGR package exists or not"
   IF ((dm_err->debug_flag > 5))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dba_objects o
    WHERE o.owner="CERADM"
     AND o.object_name="SD_DB_PROCESS_CONTEXT_MGR"
     AND o.object_type IN ("PACKAGE", "PACKAGE BODY")
    DETAIL
     dgcpd_pkg_qry_cnt = (dgcpd_pkg_qry_cnt+ 1)
     IF (o.status="VALID")
      dgcpd_pkg_valid_cnt = (dgcpd_pkg_valid_cnt+ 1)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dgcpd_pkg_valid_cnt=2)
    SET dgdt_prefs->context_lock_schema = "CERADM"
    SET dgdt_prefs->context_lock_ind = 1
   ELSEIF (dgcpd_pkg_qry_cnt > 0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid CERADM.SD_DB_PROCESS_CONTEXT_MGR package exists"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dgdt_prefs->context_lock_schema="CERADM"))
    SET dm_err->eproc = "Query for SD_DB_PROCESS_CONTEXT schema context owner "
    IF ((dm_err->debug_flag > 5))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     dgcpd_tmp_cntxt_cnt = count(*)
     FROM dba_context dc
     WHERE dc.package="SD_DB_PROCESS_CONTEXT_MGR"
      AND dc.namespace="SD_DB_PROCESS_CONTEXT"
      AND (dc.schema=dgdt_prefs->context_lock_schema)
      AND dc.type="ACCESSED GLOBALLY"
     DETAIL
      dgcpd_contxt_cnt = dgcpd_tmp_cntxt_cnt
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dgcpd_contxt_cnt=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Invalid SD_DB_PROCESS_CONTEXT schema context owner"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dgdt_prefs->context_lock_ind=- (1)))
    SET dgcpd_pkg_qry_cnt = 0
    SET dgcpd_pkg_valid_cnt = 0
    SET dm_err->eproc = "Check if V500.SD_DB_PROCESS_CONTEXT_MGR package exists or not"
    IF ((dm_err->debug_flag > 5))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dba_objects o
     WHERE o.owner="V500"
      AND o.object_name="SD_DB_PROCESS_CONTEXT_MGR"
      AND o.object_type IN ("PACKAGE", "PACKAGE BODY")
     DETAIL
      dgcpd_pkg_qry_cnt = (dgcpd_pkg_qry_cnt+ 1)
      IF (o.status="VALID")
       dgcpd_pkg_valid_cnt = (dgcpd_pkg_valid_cnt+ 1)
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dgcpd_pkg_valid_cnt=2)
     SET dgdt_prefs->context_lock_schema = "V500"
     SET dgdt_prefs->context_lock_ind = 1
    ELSEIF (dgcpd_pkg_qry_cnt > 0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Invalid V500.SD_DB_PROCESS_CONTEXT_MGR package exists"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dgdt_prefs->context_lock_ind=- (1)))
    IF ((dm_err->debug_flag > 5))
     CALL echo("Old locking mechanism in use i.e via dm_info")
    ENDIF
    SET dgdt_prefs->context_lock_ind = 0
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ddf_context_lock_maint(dclm_mode,dclm_process,dclm_process_code,dclm_owner,
  dclm_table_name,dclm_object_id,dclm_lock_ind)
   DECLARE check_context_sd(chkc_process=vc,chkc_key=vc,chkc_value=vc,chkc_what=i2) = i2 WITH sql =
   "CERADM.SD_DB_PROCESS_CONTEXT_MGR.check_context", parameter
   DECLARE check_context_v500(chkc_process=vc,chkc_key=vc,chkc_value=vc,chkc_what=i2) = i2 WITH sql
    = "V500.SD_DB_PROCESS_CONTEXT_MGR.check_context", parameter
   DECLARE set_context_sd(sc_process=vc,sc_key=vc,sc_value=vc) = null WITH sql =
   "CERADM.SD_DB_PROCESS_CONTEXT_MGR.set_context", parameter
   DECLARE set_context_v500(sc_process=vc,sc_key=vc,sc_value=vc) = null WITH sql =
   "V500.SD_DB_PROCESS_CONTEXT_MGR.set_context", parameter
   DECLARE clear_context_sd(clrc_process=vc,clrc_key=vc) = null WITH sql =
   "CERADM.SD_DB_PROCESS_CONTEXT_MGR.clear_context", parameter
   DECLARE clear_context_v500(clrc_process=vc,clrc_key=vc) = null WITH sql =
   "V500.SD_DB_PROCESS_CONTEXT_MGR.clear_context", parameter
   DECLARE dclm_get_session_id() = c30 WITH sql = "dbms_session.unique_session_id", parameter
   DECLARE dclm_session_id = vc WITH protect, noconstant("")
   DECLARE dclm_sql_cmd = vc WITH protect, noconstant("")
   DECLARE dclm_context_val = i2 WITH protect, noconstant(0)
   DECLARE dclm_process_name = vc WITH protect, noconstant("")
   DECLARE dclm_pkg_owner = vc WITH protect, noconstant("")
   DECLARE dclm_obj_id_str = vc WITH protect, noconstant("")
   IF ((dgdt_prefs->context_lock_ind=- (1)))
    IF (ddf_get_context_pkg_data(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dgdt_prefs->context_lock_ind=1))
    IF (dclm_object_id=0.0)
     IF (ddf_get_object_id(dclm_owner,dclm_table_name,dclm_object_id)=0)
      RETURN(0)
     ENDIF
    ENDIF
    SET dclm_obj_id_str = trim(cnvtstring(dclm_object_id))
    SET dm_err->eproc = "Query to retrieve session id "
    IF ((dm_err->debug_flag > 5))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     dclm_session_id_tmp = dclm_get_session_id()
     FROM dual
     DETAIL
      dclm_session_id = dclm_session_id_tmp
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET dclm_process_name = build(dclm_process,dclm_process_code)
   ENDIF
   IF (dclm_mode="CHECK")
    IF ((dgdt_prefs->context_lock_ind=1))
     SET dm_err->eproc = concat("check if context lock exists for ",dclm_owner,".",dclm_table_name)
     IF ((dm_err->debug_flag > 5))
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     SELECT
      IF ((dgdt_prefs->context_lock_schema="CERADM"))
       dclm_tmp_val = check_context_sd(dclm_process_name,dclm_session_id,dclm_obj_id_str,2)
      ELSE
       dclm_tmp_val = check_context_v500(dclm_process_name,dclm_session_id,dclm_obj_id_str,2)
      ENDIF
      INTO "nl:"
      FROM dual
      DETAIL
       dclm_context_val = dclm_tmp_val
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (dclm_context_val > 0)
      SET dclm_lock_ind = 0
     ELSE
      SET dclm_lock_ind = 1
     ENDIF
    ELSE
     IF (ddf_check_lock("STATS LOCK",dclm_table_name,dclm_process_code,dclm_lock_ind)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF (dclm_mode="GET")
    IF ((dgdt_prefs->context_lock_ind=1))
     SET dm_err->eproc = concat("Get context lock  for ",dclm_owner,".",dclm_table_name)
     IF ((dm_err->debug_flag > 5))
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     IF ((dgdt_prefs->context_lock_schema="CERADM"))
      CALL set_context_sd(dclm_process_name,dclm_session_id,dclm_obj_id_str)
     ELSE
      CALL set_context_v500(dclm_process_name,dclm_session_id,dclm_obj_id_str)
     ENDIF
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = concat("check if context lock obtained for ",dclm_owner,".",dclm_table_name)
     IF ((dm_err->debug_flag > 5))
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     SELECT
      IF ((dgdt_prefs->context_lock_schema="CERADM"))
       dclm_tmp_val = check_context_sd(dclm_process_name,dclm_session_id,dclm_obj_id_str,1)
      ELSE
       dclm_tmp_val = check_context_v500(dclm_process_name,dclm_session_id,dclm_obj_id_str,1)
      ENDIF
      INTO "nl:"
      FROM dual
      DETAIL
       dclm_context_val = dclm_tmp_val
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (dclm_context_val=1)
      SET dclm_lock_ind = 1
     ELSE
      SET dclm_lock_ind = 0
     ENDIF
    ELSE
     IF (ddf_get_lock("STATS LOCK",dclm_table_name,dclm_process_code,dclm_lock_ind)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF (dclm_mode="RELEASE")
    IF ((dgdt_prefs->context_lock_ind=1))
     SET dm_err->eproc = concat("Release context lock on ",dclm_owner,".",dclm_table_name)
     IF ((dm_err->debug_flag > 5))
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     IF ((dgdt_prefs->context_lock_schema="CERADM"))
      CALL clear_context_sd(dclm_process_name,dclm_session_id)
     ELSE
      CALL clear_context_v500(dclm_process_name,dclm_session_id)
     ENDIF
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF ((dm_err->err_ind=0))
      SET dclm_lock_ind = 1
     ELSE
      SET dclm_lock_ind = 0
      SET dm_err->emsg = concat("Unable to release lock on object:",dclm_owner,".",dclm_table_name)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ELSE
     IF (ddf_release_lock("STATS LOCK",dclm_table_name,dclm_process_code)=0)
      RETURN(0)
     ENDIF
     SET dclm_lock_ind = 0
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE dar_get_appl_status(gas_appl_id=vc) = c1
 SUBROUTINE dar_get_appl_status(gas_appl_id)
   DECLARE gas_error_status = c1 WITH protect, constant("E")
   DECLARE gas_active_status = c1 WITH protect, constant("A")
   DECLARE gas_inactive_status = c1 WITH protect, constant("I")
   IF (cnvtupper(gas_appl_id)="-15301")
    RETURN(gas_active_status)
   ENDIF
   SELECT INTO "nl:"
    FROM gv$session s
    WHERE s.audsid=cnvtint(gas_appl_id)
    WITH nocounter
   ;end select
   IF (check_error("Selecting from gv$session in subroutine dar_get_appl_status")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(gas_error_status)
   ELSEIF (curqual=0)
    SELECT INTO "nl:"
     FROM v$session s
     WHERE s.audsid=cnvtint(gas_appl_id)
     WITH nocounter
    ;end select
    IF (check_error("Selecting from v$session in subroutine dar_get_appl_status")=1)
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
 END ;Subroutine
 IF (check_logfile("dm2_fi",".log","dm2_finish_index LOGFILE")=0)
  GO TO exit_program
 ENDIF
 DECLARE dci_obj_id = f8 WITH protect, noconstant(- (1))
 DECLARE dci_special_stats_ind = i2 WITH protect, noconstant(0)
 DECLARE dci_table_owner = vc WITH protect, noconstant("")
 DECLARE dci_table_name = vc WITH protect, noconstant("")
 DECLARE dci_index_owner = vc WITH protect, noconstant("")
 DECLARE dci_index_name = vc WITH protect, noconstant("")
 DECLARE dci_ind_statid = vc WITH protect, noconstant("")
 DECLARE dci_special_statid = vc WITH protect, noconstant("")
 DECLARE dci_pub_status = vc WITH protect, noconstant("")
 DECLARE dci_altered_pref_true_ind = i2 WITH protect, noconstant(0)
 DECLARE dci_altered_pref_false_ind = i2 WITH protect, noconstant(0)
 DECLARE dci_cnt = i2 WITH protect, noconstant(0)
 DECLARE dci_last_analyzed = dq8 WITH protect
 DECLARE dci_lock_available_ind = i2 WITH protect, noconstant(0)
 DECLARE dci_lock_obtained_ind = i2 WITH protect, noconstant(0)
 DECLARE dci_retry_ind = i2 WITH protect, noconstant(1)
 DECLARE dci_retry_count = i2 WITH protect, noconstant(0)
 DECLARE dci_retry_ceiling = i4 WITH protect, noconstant(0)
 DECLARE dci_object_id = f8 WITH protect, noconstant(0.0)
 DECLARE dci_skip_alter_ind = i4 WITH protect, noconstant(0)
 DECLARE dfi_stats_gather_to_dict_ind = i2 WITH protect, noconstant(0)
 DECLARE dfi_cmd = vc WITH protect, noconstant(" ")
 DECLARE dfi_degree = vc WITH protect, noconstant(" ")
 DECLARE dfi_visible_ind = vc WITH protect, noconstant(" ")
 DECLARE set_table_prefs(ownname=vc,tabname=vc,pname=vc,pvalue=vc) = null WITH sql =
 "SYS.DBMS_STATS.SET_TABLE_PREFS", parameter
 DECLARE gather_index_stats(ownname=vc,indname=vc,estimate_percent=f8,degree=vc,force=i4) = null
 WITH sql = "SYS.DBMS_STATS.GATHER_INDEX_STATS", parameter
 SET dci_table_owner =  $1
 SET dci_table_name =  $2
 SET dci_index_owner =  $3
 SET dci_index_name =  $4
 SET dm_err->eproc = concat("Beginning dm2_finish_index for ",dci_index_owner,".",dci_index_name)
 CALL disp_msg(" ",dm_err->logfile,0)
 SET dci_cnt = 0
 SET dm_err->eproc = concat("Check if index ",dci_index_owner,".",dci_index_name,
  " exists and if has statistics")
 IF ((dm_err->debug_flag > 0))
  CALL disp_msg(" ",dm_err->logfile,0)
 ENDIF
 SELECT INTO "nl:"
  qrychk_last_anal = nullcheck(d.last_analyzed,cnvtdatetime(cnvtdate("01011900"),0),nullind(d
    .last_analyzed))
  FROM dba_indexes d
  WHERE d.owner=dci_index_owner
   AND d.index_name=dci_index_name
   AND d.table_owner=dci_table_owner
   AND d.table_name=dci_table_name
  DETAIL
   dci_cnt = 1, dci_last_analyzed = cnvtdatetime(qrychk_last_anal)
  WITH nocounter
 ;end select
 IF (dci_cnt=0)
  SET dm_err->emsg = concat("Index does not exist: ",dci_index_owner,".",dci_index_name,". Exiting.")
  SET dm_err->err_ind = 1
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (((cnvtdatetime(dci_last_analyzed) > cnvtdatetime(cnvtdate("01011900"),0)) OR ((dm_err->
 debug_flag=17222))) )
  IF ((dm_err->debug_flag=17222))
   SET dm_err->eproc = "Informational: Bypassing statistics work since debug flag bypass is set"
   CALL disp_msg(" ",dm_err->logfile,0)
  ELSE
   SET dm_err->eproc = concat(
    "Informational: Bypassing statistics work since last_analyzed is valued as ",format(cnvtdatetime(
      dci_last_analyzed),";;Q"))
   CALL disp_msg(" ",dm_err->logfile,0)
  ENDIF
 ELSE
  SET dm_err->eproc = "Retrieving retry override from DM_INFO"
  IF ((dm_err->debug_flag > 0))
   CALL disp_msg(" ",dm_err->logfile,0)
  ENDIF
  SELECT INTO "nl:"
   FROM dm_info d
   WHERE d.info_domain="DM2GDBS:INSTALL_PREFS"
    AND d.info_name="STATS_LOCK_RETRY"
   HEAD REPORT
    dci_retry_ceiling = 500
   DETAIL
    dci_retry_ceiling = d.info_number
   WITH nocounter, nullreport
  ;end select
  IF (check_error(dm_err->eproc) != 0)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
  IF ((dgdt_prefs->context_lock_ind=- (1)))
   IF (ddf_get_context_pkg_data(null)=0)
    GO TO exit_program
   ENDIF
  ENDIF
  IF ((dgdt_prefs->context_lock_ind=1))
   IF (ddf_get_object_id(dci_table_owner,dci_table_name,dci_object_id)=0)
    GO TO exit_program
   ENDIF
  ENDIF
  SET dci_retry_ind = 1
  WHILE (dci_retry_ind=1)
    IF (ddf_context_lock_maint("CHECK","STAT",1,dci_table_owner,dci_table_name,
     dci_object_id,dci_lock_available_ind)=0)
     GO TO exit_program
    ENDIF
    IF (dci_lock_available_ind=1)
     IF (ddf_context_lock_maint("GET","STAT",2,dci_table_owner,dci_table_name,
      dci_object_id,dci_lock_obtained_ind)=0)
      GO TO exit_program
     ENDIF
     IF (dci_lock_obtained_ind=1)
      SET dci_retry_ind = 0
     ENDIF
    ENDIF
    IF (dci_lock_obtained_ind=0)
     IF (dci_retry_count > dci_retry_ceiling)
      SET dm_err->err_ind = 1
      SET dm_err->emsg = concat("Unable to obtain gather stats lock for Index: ",dci_index_owner,".",
       dci_index_name," on ",
       dci_table_owner,".",dci_table_name)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ELSE
      SET dm_err->eproc = concat("Waiting to obtain gather stats lock for ",dci_index_owner,".",
       dci_index_name)
      CALL disp_msg(" ",dm_err->logfile,0)
      CALL pause(30)
      SET dci_retry_count = (dci_retry_count+ 1)
     ENDIF
    ENDIF
  ENDWHILE
  SET dci_cnt = 0
  SET dm_err->eproc = concat("Check if index ",dci_index_owner,".",dci_index_name,
   " has pending statistics")
  IF ((dm_err->debug_flag > 0))
   CALL disp_msg(" ",dm_err->logfile,0)
  ENDIF
  SELECT INTO "nl:"
   qrychk_ind_cnt = count(*)
   FROM dba_ind_pending_stats d
   WHERE d.owner=dci_index_owner
    AND d.index_name=dci_index_name
    AND d.table_owner=dci_table_owner
    AND d.table_name=dci_table_name
   DETAIL
    dci_cnt = qrychk_ind_cnt
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
  IF (dci_cnt=0)
   SET dm_err->eproc = concat("Get the object_id of index ",dci_index_owner,".",dci_index_name)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dba_objects o
    WHERE o.owner=dci_index_owner
     AND o.object_name=dci_index_name
     AND o.object_type="INDEX"
    DETAIL
     dci_obj_id = o.object_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   SET dm_err->eproc = concat("Check if there are pending stats stored for index ",dci_index_owner,
    ".",dci_index_name," in table dm_stat_table")
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET dci_special_statid = concat("DM2_INSTALL_BCK",trim(cnvtstring(dci_obj_id)))
   SELECT INTO "nl:"
    dci_pending_stats_count = count(*)
    FROM dm_stat_table d
    WHERE d.statid=dci_special_statid
     AND d.type="I"
     AND d.c5=dci_index_owner
     AND d.c1=dci_index_name
    DETAIL
     IF (dci_pending_stats_count > 0)
      dci_special_stats_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (dci_special_stats_ind=0)
    EXECUTE dm2_alter_dbstats_session "IND"
    IF ((dm_err->err_ind=1))
     GO TO exit_program
    ENDIF
    SET dm_err->eproc = build("Gathering Index statistics for (",dci_index_owner,".",dci_index_name,
     ")")
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    CALL gather_index_stats(concat('"',dci_index_owner,'"'),concat('"',dci_index_name,'"'),0,1,
     cnvtbool(true))
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    SET dci_pub_status = "TRUE"
    SET dm_err->eproc = concat("Check publish preference for ",dci_table_owner,".",dci_table_name)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dba_tab_stat_prefs d
     WHERE d.owner=dci_table_owner
      AND d.table_name=dci_table_name
      AND trim(cnvtupper(d.preference_name))="PUBLISH"
     DETAIL
      dci_pub_status = trim(cnvtupper(d.preference_value))
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    IF (dci_pub_status="TRUE")
     SET dfi_stats_gather_to_dict_ind = 1
    ENDIF
    IF (dfi_stats_gather_to_dict_ind=0)
     SET dm_err->eproc = concat("Find pending statistics for index ",dci_index_owner,".",
      dci_index_name)
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     SELECT INTO "nl:"
      qrychk_ind_cnt = count(*)
      FROM dba_ind_pending_stats d
      WHERE d.owner=dci_index_owner
       AND d.index_name=dci_index_name
       AND d.table_owner=dci_table_owner
       AND d.table_name=dci_table_name
      DETAIL
       dci_cnt = qrychk_ind_cnt
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
     IF (dci_cnt=0)
      SET dm_err->err_ind = 1
      SET dm_err->emsg = concat("Failed to find pending statistics for index ",dci_index_owner,".",
       dci_index_name)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
    ENDIF
   ENDIF
  ENDIF
  IF (dfi_stats_gather_to_dict_ind=0)
   IF (dci_pub_status="")
    SET dci_pub_status = "TRUE"
    SET dm_err->eproc = concat("Check publish preference for ",dci_table_owner,".",dci_table_name)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dba_tab_stat_prefs d
     WHERE d.owner=dci_table_owner
      AND d.table_name=dci_table_name
      AND trim(cnvtupper(d.preference_name))="PUBLISH"
     DETAIL
      dci_pub_status = trim(cnvtupper(d.preference_value))
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
   ENDIF
   IF (dci_pub_status="FALSE")
    SET dm_err->eproc = concat("Set publish preference for ",dci_table_owner,".",dci_table_name,
     " to TRUE")
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    CALL set_table_prefs(concat('"',dci_table_owner,'"'),concat('"',dci_table_name,'"'),"PUBLISH",
     "TRUE")
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    SET dci_altered_pref_true_ind = 1
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Encountered unhandled condition for ",dci_index_owner,".",
     dci_index_name)
    SET dm_err->user_action = concat(
     "There are pending statistics, no last_analyzed value, yet publish is set to TRUE.",
     " Scenario needs explanation.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (dci_altered_pref_true_ind=1)
    IF (dci_special_stats_ind=0)
     SET dm_err->eproc = concat("Get STATID for ",dci_table_owner,".",dci_table_name)
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     SELECT INTO "nl:"
      FROM dba_objects d
      WHERE d.owner=dci_index_owner
       AND d.object_name=dci_index_name
       AND d.object_type="INDEX"
      DETAIL
       dci_ind_statid = concat("DM2INSTALL_",trim(cnvtstring(d.object_id,20)))
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
     IF ((dm_err->debug_flag > 0))
      CALL echo(dci_ind_statid)
     ENDIF
     EXECUTE dm2_export_dbstats_pending dci_table_owner, dci_table_name, dci_ind_statid
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_program
     ENDIF
    ELSE
     SET dci_ind_statid = dci_special_statid
    ENDIF
    EXECUTE dm2_publish_dbstats_ind dci_index_owner, dci_index_name, dci_ind_statid
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    SET dm_err->eproc = concat("Set publish preference for ",dci_table_owner,".",dci_table_name,
     " to FALSE")
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    CALL set_table_prefs(concat('"',dci_table_owner,'"'),concat('"',dci_table_name,'"'),"PUBLISH",
     "FALSE")
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
    SET dci_altered_pref_false_ind = 1
   ENDIF
  ENDIF
 ENDIF
 SET dm_err->eproc = concat("Check visibility status and degree for  ",dci_index_owner,".",
  dci_index_name)
 IF ((dm_err->debug_flag > 0))
  CALL disp_msg(" ",dm_err->logfile,0)
 ENDIF
 SELECT INTO "nl:"
  d.degree, d.visibility
  FROM dba_indexes d
  WHERE d.owner=dci_index_owner
   AND d.index_name=dci_index_name
  DETAIL
   dfi_degree = d.degree, dfi_visible_ind = d.visibility
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (curqual > 0)
  IF ((validate(ddr_ddl_req->ddl_cnt,- (1)) != - (1)))
   IF ((ddr_ddl_req->ddl_process="DRR_INSTALL_IV_INDEX")
    AND cnvtupper(substring(1,3,dci_index_name))="XDR")
    SET dci_skip_alter_ind = 1
   ENDIF
  ENDIF
  IF (((cnvtint(dfi_degree) > 1) OR (dfi_degree="DEFAULT")) )
   IF (dm2_push_cmd(concat('rdb asis(^ alter index "',dci_index_owner,'"."',dci_index_name,
     '" NOPARALLEL ^) go '),1)=0)
    GO TO exit_program
   ENDIF
  ENDIF
  IF (dci_skip_alter_ind=0)
   IF (dfi_visible_ind != "VISIBLE")
    SET dm_err->eproc = concat("Altering ",dci_index_owner,".",dci_index_name," to visible")
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    IF (dm2_push_cmd(concat('rdb asis(^ alter index "',dci_index_owner,'"."',dci_index_name,
      '" visible ^) go '),1)=0)
     GO TO exit_program
    ENDIF
   ENDIF
  ENDIF
 ENDIF
#exit_program
 IF (dci_altered_pref_true_ind=1
  AND dci_altered_pref_false_ind=0
  AND (dm_err->err_ind=1))
  CALL set_table_prefs(concat('"',dci_table_owner,'"'),concat('"',dci_table_name,'"'),"PUBLISH",
   "FALSE")
 ENDIF
 IF (dci_lock_obtained_ind=1)
  SET dci_err_ind = dm_err->err_ind
  SET dci_emsg = dm_err->emsg
  SET dm_err->err_ind = 0
  CALL ddf_context_lock_maint("RELEASE","STAT",2,dci_table_owner,dci_table_name,
   dci_object_id,dci_lock_obtained_ind)
  SET dm_err->err_ind = dci_err_ind
  SET dm_err->emsg = dci_emsg
 ENDIF
 SET dm_err->eproc = "Ending dm2_finish_index"
 CALL final_disp_msg("dm2_fi")
END GO
