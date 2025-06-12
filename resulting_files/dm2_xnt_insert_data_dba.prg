CREATE PROGRAM dm2_xnt_insert_data:dba
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
 DECLARE dxrc_update_detail(dud_xntr_detail_id=f8,dud_xntr_status=vc,dud_commit_ind=i2) = i2
 DECLARE dxrc_rollback_extract(dre_extract_id=f8,dre_detail_id=f8,dre_commit_ind=i2) = i2
 DECLARE dxrc_update_job(duj_job_id=f8,duj_status=vc,duj_status_msg=vc,duj_commit_ind=i2) = i2
 DECLARE dxrc_update_extract(due_extract_id=f8,due_status=vc,due_status_msg=vc,due_commit_ind=i2) =
 i2
 DECLARE dxrc_check_stop_time(dcst_start_time=f8) = i2
 DECLARE dxrc_requeue_errors(dre_job_error_id=f8,dre_extract_error_id=f8) = i2
 SUBROUTINE dxrc_update_detail(dud_xntr_detail_id,dud_xntr_status,dud_commit_ind)
   DECLARE dud_prev_err_ind = i2 WITH protect, noconstant
   SET dud_xntr_status = cnvtupper(dud_xntr_status)
   SET dud_prev_err_ind = dm_err->err_ind
   SET dm_err->err_ind = 0
   IF (dud_xntr_status IN ("ERROR", "FINISHED"))
    UPDATE  FROM dm_xntr_detail d
     SET d.status = dud_xntr_status, d.status_msg = evaluate(dud_xntr_status,"FINISHED",
       "Detail work completed successfully","ERROR",dm_err->emsg), d.end_dt_tm = cnvtdatetime(curdate,
       curtime3),
      d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_applctx = reqinfo->updt_applctx, d
      .updt_task = reqinfo->updt_task,
      d.updt_cnt = (d.updt_cnt+ 1), d.updt_id = reqinfo->updt_id
     WHERE d.dm_xntr_detail_id=dud_xntr_detail_id
     WITH nocounter
    ;end update
   ELSEIF (dud_xntr_status="RUNNING")
    UPDATE  FROM dm_xntr_detail d
     SET d.status = dud_xntr_status, d.start_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      d.updt_applctx = reqinfo->updt_applctx, d.updt_task = reqinfo->updt_task, d.updt_cnt = (d
      .updt_cnt+ 1),
      d.updt_id = reqinfo->updt_id
     WHERE d.dm_xntr_detail_id=dud_xntr_detail_id
     WITH nocounter
    ;end update
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->emsg = build("Invalid status passed into DXRC_UPDATE_DETAIL: ",dud_xntr_status)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   IF (check_error("Updating DM_XNTR_DETAIL") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(1)
   ELSE
    SET dm_err->err_ind = dud_prev_err_ind
   ENDIF
   IF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = build("No row found in DM_XNTR_DETAIL for ID: ",dud_xntr_detail_id)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   IF (dud_commit_ind=1)
    COMMIT
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dxrc_rollback_extract(dre_extract_id,dre_detail_id,dre_commit_ind)
   DECLARE dre_tab_loop = i4 WITH protect, noconstant(0)
   DECLARE dre_msg = vc WITH protect, noconstant("")
   DECLARE dre_mismatch_cnt = i4 WITH protect, noconstant(0)
   DECLARE dre_orig_e_ind = i4 WITH protect, noconstant(0)
   DECLARE dre_err_msg = vc WITH protect, noconstant(" ")
   FREE RECORD dre_tab_list
   RECORD dre_tab_list(
     1 table_cnt = i4
     1 table_qual[*]
       2 table_name = vc
       2 delete_cnt = i4
   )
   ROLLBACK
   SET dre_orig_e_ind = dm_err->err_ind
   SET dm_err->err_ind = 0
   SET dre_msg = dm_err->emsg
   SELECT INTO "NL:"
    FROM dm_xntr_extract d
    WHERE d.dm_xntr_extract_id=dre_extract_id
    WITH nocounter
   ;end select
   IF (check_error("Validating DM_XNTR_EXTRACT_ID") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   IF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = build("No row found in DM_XNTR_EXTRACT for ID: ",dre_extract_id)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   IF (dre_detail_id > 0)
    SET dm_err->emsg = dre_msg
    IF (dxrc_update_detail(dre_detail_id,"ERROR",dre_commit_ind)=1)
     RETURN(1)
    ENDIF
   ENDIF
   SELECT DISTINCT INTO "NL:"
    d.table_name
    FROM dm_xntr_extract_row_data d
    WHERE d.extract_id=dre_extract_id
    DETAIL
     dre_tab_list->table_cnt = (dre_tab_list->table_cnt+ 1), stat = alterlist(dre_tab_list->
      table_qual,dre_tab_list->table_cnt), dre_tab_list->table_qual[dre_tab_list->table_cnt].
     table_name = d.table_name
    WITH nocounter
   ;end select
   IF (check_error("Gathering table names from DM_XNTR_EXTRACT_ROW_DATA") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   IF ((dre_tab_list->table_cnt > 0))
    FOR (dre_tab_loop = 1 TO dre_tab_list->table_cnt)
      DELETE  FROM (parser(dre_tab_list->table_qual[dre_tab_loop].table_name) d)
       WHERE d.rowid IN (
       (SELECT
        d1.new_rowid
        FROM dm_xntr_extract_row_data d1
        WHERE d1.extract_id=dre_extract_id
         AND (d1.table_name=dre_tab_list->table_qual[dre_tab_loop].table_name)))
       WITH nocounter
      ;end delete
      IF (check_error(build("Deleting data from ",dre_tab_list->table_qual[dre_tab_loop].table_name))
       != 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN(1)
      ENDIF
      SET dre_tab_list->table_qual[dre_tab_loop].delete_cnt = curqual
      UPDATE  FROM dm_xntr_extract_cnt d
       SET d.deleted_row_cnt = dre_tab_list->table_qual[dre_tab_loop].delete_cnt, d.updt_cnt = (d
        .updt_cnt+ 1), d.updt_applctx = reqinfo->updt_applctx,
        d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task, d.updt_dt_tm = cnvtdatetime(
         curdate,curtime3)
       WHERE dm_xntr_extract_id=dre_extract_id
        AND (retrieved_row_cnt=dre_tab_list->table_qual[dre_tab_loop].delete_cnt)
        AND (table_name=dre_tab_list->table_qual[dre_tab_loop].table_name)
       WITH nocounter
      ;end update
      IF (check_error("Recording delete in DM_XNTR_EXTRACT_CNT") != 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN(1)
      ENDIF
      IF (curqual=0)
       SET dm_err->err_ind = 1
       SET dm_err->emsg = "Could not update the DM_XNTR_EXTRACT_CNT table"
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN(1)
      ENDIF
    ENDFOR
    SELECT INTO "NL:"
     cnt = count(*)
     FROM dm_xntr_extract_cnt d
     WHERE d.dm_xntr_extract_id=dre_extract_id
      AND d.deleted_row_cnt != d.retrieved_row_cnt
     DETAIL
      dre_mismatch_cnt = cnt
     WITH nocounter
    ;end select
    IF (check_error("Looking for mismatched rows in DM_XNTR_EXTRACT_CNT") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(1)
    ENDIF
    IF (dre_mismatch_cnt > 0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "There were inserts reported in DM_XNTR_EXTRACT_CNT that weren't deleted."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(1)
    ENDIF
   ENDIF
   SET dre_err_msg = evaluate(dre_detail_id,0.0,dre_msg,concat(
     "An error occured during the transform: ",trim(cnvtstring(dre_detail_id,20),3)))
   IF (dxrc_update_extract(dre_extract_id,"ERROR",dre_err_msg,dre_commit_ind) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Deleting rows that were rolled back from dm_xntr_extract_row_data."
   DELETE  FROM dm_xntr_extract_row_data d
    WHERE d.extract_id=dre_extract_id
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(1)
   ENDIF
   IF (dre_commit_ind=1)
    COMMIT
   ENDIF
   SET dm_err->err_ind = dre_orig_e_ind
   SET dm_err->emsg = dre_msg
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dxrc_update_job(duj_job_id,duj_status,duj_status_msg,duj_commit_ind)
   DECLARE duj_prev_err_ind = i2 WITH protect, noconstant
   SET duj_status = cnvtupper(duj_status)
   SET duj_prev_err_ind = dm_err->err_ind
   SET dm_err->err_ind = 0
   IF (duj_status IN ("ERROR", "FINISHED"))
    UPDATE  FROM dm_xntr_job d
     SET d.status = duj_status, d.status_msg = duj_status_msg, d.job_end_dt_tm = cnvtdatetime(curdate,
       curtime3),
      d.audit_sid = null, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_applctx = reqinfo->
      updt_applctx,
      d.updt_task = reqinfo->updt_task, d.updt_cnt = (d.updt_cnt+ 1), d.updt_id = reqinfo->updt_id
     WHERE d.dm_xntr_job_id=duj_job_id
     WITH nocounter
    ;end update
   ELSEIF (duj_status="RUNNING")
    UPDATE  FROM dm_xntr_job d
     SET d.status = duj_status, d.status_msg = null, d.job_start_dt_tm = cnvtdatetime(curdate,
       curtime3),
      d.audit_sid = currdbhandle, d.log_file = dm_err->logfile, d.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      d.updt_applctx = reqinfo->updt_applctx, d.updt_task = reqinfo->updt_task, d.updt_cnt = (d
      .updt_cnt+ 1),
      d.updt_id = reqinfo->updt_id
     WHERE d.dm_xntr_job_id=duj_job_id
     WITH nocounter
    ;end update
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->emsg = build("Invalid status passed into DXRC_UPDATE_JOB: ",duj_status)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   IF (check_error("Updating DM_XNTR_JOB") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(1)
   ELSE
    SET dm_err->err_ind = duj_prev_err_ind
   ENDIF
   IF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = build("No row found in DM_XNTR_JOB for ID: ",duj_job_id)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   IF (duj_commit_ind=1)
    COMMIT
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dxrc_update_extract(due_extract_id,due_status,due_status_msg,due_commit_ind)
   DECLARE due_prev_err_ind = i2 WITH protect, noconstant
   FREE RECORD due_stmt
   RECORD due_stmt(
     1 stmt[*]
       2 str = vc
   )
   SET due_status = cnvtupper(due_status)
   SET due_prev_err_ind = dm_err->err_ind
   SET dm_err->err_ind = 0
   IF (due_status IN ("ERROR", "FINISHED"))
    UPDATE  FROM dm_xntr_extract d
     SET d.status = due_status, d.status_msg = due_status_msg, d.extract_stop_dt_tm = cnvtdatetime(
       curdate,curtime3),
      d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_applctx = reqinfo->updt_applctx, d
      .updt_task = reqinfo->updt_task,
      d.updt_cnt = (d.updt_cnt+ 1), d.updt_id = reqinfo->updt_id
     WHERE d.dm_xntr_extract_id=due_extract_id
     WITH nocounter
    ;end update
   ELSEIF (due_status="RETRIEVE")
    UPDATE  FROM dm_xntr_extract d
     SET d.status = due_status, d.status_msg = null, d.extract_start_dt_tm = cnvtdatetime(curdate,
       curtime3),
      d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_applctx = reqinfo->updt_applctx, d
      .updt_task = reqinfo->updt_task,
      d.updt_cnt = (d.updt_cnt+ 1), d.updt_id = reqinfo->updt_id
     WHERE d.dm_xntr_extract_id=due_extract_id
     WITH nocounter
    ;end update
   ELSEIF (due_status IN ("PARSE", "INSERT", "SYNCHRONIZE"))
    SET stat = alterlist(due_stmt->stmt,1)
    SET due_stmt->stmt[1].str = concat("rdb asis(^ BEGIN XNTR_UPDATE_EXTRACT_AUTON('",due_status,
     "','",due_status_msg,"',",
     trim(cnvtstring(due_extract_id,20),3),",'",format(cnvtdatetime(curdate,curtime3),";;q"),
     "'); END; ^) go")
    EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","DUE_STMT")
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->emsg = build("Invalid status passed into DXRC_UPDATE_EXTRACT: ",due_status)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   IF (check_error("Updating DM_XNTR_EXTRACT") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(1)
   ELSE
    SET dm_err->err_ind = due_prev_err_ind
   ENDIF
   IF (due_commit_ind=1)
    COMMIT
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dxrc_check_stop_time(dcst_start_time)
   DECLARE dcst_stop_ind = i2 WITH protect, noconstant(0)
   SELECT INTO "NL:"
    cnt = count(*)
    FROM dm_info d
    WHERE d.info_domain="DATA MANAGEMENT"
     AND d.info_name="XNTR STOP TIME"
     AND d.info_date > cnvtdatetime(dcst_start_time)
    DETAIL
     dcst_stop_ind = cnt
    WITH nocounter
   ;end select
   IF (check_error("Checking Stop Time") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   RETURN(dcst_stop_ind)
 END ;Subroutine
 SUBROUTINE dxrc_requeue_errors(dre_job_error_id,dre_extract_error_id)
   FREE RECORD dre_requeue
   RECORD dre_requeue(
     1 cnt = i4
     1 qual[*]
       2 job_id = f8
   )
   DECLARE dre_loop = i4 WITH protect, noconstant(0)
   IF (dre_job_error_id=0.0
    AND dre_extract_error_id=0.0)
    SELECT INTO "NL:"
     FROM dm_xntr_job d
     WHERE d.status="ERROR"
     DETAIL
      dre_requeue->cnt = (dre_requeue->cnt+ 1), stat = alterlist(dre_requeue->qual,dre_requeue->cnt),
      dre_requeue->qual[dre_requeue->cnt].job_id = d.dm_xntr_job_id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
   ELSEIF (dre_job_error_id > 0.0)
    SET stat = alterlist(dre_requeue->qual,1)
    SET dre_requeue->cnt = 1
    SET dre_requeue->qual[1].job_id = dre_job_error_id
   ELSEIF (dre_extract_error_id > 0.0)
    SELECT INTO "NL:"
     FROM dm_xntr_job d
     WHERE d.status="ERROR"
      AND d.dm_xntr_job_id IN (
     (SELECT
      dm_xntr_job_id
      FROM dm_xntr_extract
      WHERE dm_xntr_extract_id=dre_extract_error_id))
     DETAIL
      dre_requeue->cnt = (dre_requeue->cnt+ 1), stat = alterlist(dre_requeue->qual,dre_requeue->cnt),
      dre_requeue->qual[dre_requeue->cnt].job_id = d.dm_xntr_job_id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(1)
    ENDIF
   ENDIF
   IF ((dre_requeue->cnt=0))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Could not identify any errors"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   DELETE  FROM dm_xntr_detail d
    WHERE d.dm_xntr_extract_id IN (
    (SELECT
     e.dm_xntr_extract_id
     FROM dm_xntr_extract e
     WHERE expand(dre_loop,1,dre_requeue->cnt,e.dm_xntr_job_id,dre_requeue->qual[dre_loop].job_id)
      AND e.status != "FINISHED"))
    WITH nocounter, expand = 1
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   DELETE  FROM dm_xntr_extract_cnt d
    WHERE d.dm_xntr_extract_id IN (
    (SELECT
     e.dm_xntr_extract_id
     FROM dm_xntr_extract e
     WHERE expand(dre_loop,1,dre_requeue->cnt,e.dm_xntr_job_id,dre_requeue->qual[dre_loop].job_id)
      AND e.status != "FINISHED"))
    WITH nocounter, expand = 1
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   DELETE  FROM dm_xntr_extract d
    WHERE expand(dre_loop,1,dre_requeue->cnt,d.dm_xntr_job_id,dre_requeue->qual[dre_loop].job_id)
     AND d.status != "FINISHED"
    WITH nocounter, expand = 1
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   UPDATE  FROM dm_xntr_job j
    SET j.status = "QUEUED", j.status_msg = null, j.audit_sid = null,
     j.job_start_dt_tm = null, j.job_end_dt_tm = null, j.log_file = null,
     j.updt_id = reqinfo->updt_id, j.updt_cnt = (j.updt_cnt+ 1), j.updt_applctx = reqinfo->
     updt_applctx,
     j.updt_task = reqinfo->updt_task, j.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE expand(dre_loop,1,dre_requeue->cnt,j.dm_xntr_job_id,dre_requeue->qual[dre_loop].job_id)
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   COMMIT
   RETURN(0)
 END ;Subroutine
 FREE RECORD dxid_data
 RECORD dxid_data(
   1 table_cnt = i4
   1 table_qual[*]
     2 table_name = vc
     2 table_suffix = vc
     2 table_level = i4
     2 proc_name = vc
     2 exists_ind = i2
 )
 FREE RECORD dxid_request
 RECORD dxid_request(
   1 stmt[*]
     2 str = vc
 )
 SET stat = alterlist(dxid_request->stmt,1)
 DECLARE dxid_extract_id = f8 WITH protect, noconstant(0.0)
 DECLARE dxid_return = i2 WITH protect, noconstant(0)
 DECLARE dxid_loop = i4 WITH protect, noconstant(0)
 DECLARE dxid_loop1 = i4 WITH protect, noconstant(0)
 DECLARE dxid_loop2 = i4 WITH protect, noconstant(0)
 DECLARE dxid_qual_cnt = i4 WITH protect, noconstant(0)
 DECLARE get_level(i_table_name=vc) = i4 WITH sql = "XNTR_PARSE_XML_PKG.GET_LEVEL", parameter
 IF (check_logfile("dm2_xnt_insert_data",".log","DM2_XNT_INSERT_DATA Log...") != 1)
  SET dm_err->err_ind = 1
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_dxid
 ENDIF
 SET dm_err->eproc = "Starting script to insert XML data into live tables"
 IF (reflect(parameter(1,0)) != "I*"
  AND reflect(parameter(1,0)) != "F*")
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Expected syntax: dm2_xnt_insert_data <extract_id>"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_dxid
 ELSE
  SET dxid_extract_id =  $1
 ENDIF
 SET dm_err->eproc = "Getting table list to work on for given extract"
 SELECT DISTINCT INTO "NL:"
  d.table_name, tbl_lvl = get_level(d.table_name)
  FROM dm_xnt_row_gttd d
  WHERE d.file_id=dxid_extract_id
  HEAD REPORT
   dxid_data->table_cnt = 0
  DETAIL
   dxid_data->table_cnt = (dxid_data->table_cnt+ 1)
   IF (mod(dxid_data->table_cnt,10)=1)
    stat = alterlist(dxid_data->table_qual,(dxid_data->table_cnt+ 9))
   ENDIF
   dxid_data->table_qual[dxid_data->table_cnt].table_name = d.table_name, dxid_data->table_qual[
   dxid_data->table_cnt].table_level = tbl_lvl
  FOOT REPORT
   stat = alterlist(dxid_data->table_qual,dxid_data->table_cnt)
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc) != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_dxid
 ENDIF
 IF ((dxid_data->table_cnt=0))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat("No rows were found in DM_XNT_ROW_GTTD for EXTRACT_ID ",trim(cnvtstring(
     dxid_extract_id,20)))
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_dxid
 ENDIF
 SET dm_err->eproc = "Sorting tables in descending order by table level"
 SET stat = alterlist(dxid_data->table_qual,(dxid_data->table_cnt+ 1))
 FOR (dxid_loop1 = 1 TO (dxid_data->table_cnt - 1))
   FOR (dxid_loop2 = 1 TO (dxid_data->table_cnt - 1))
     IF ((dxid_data->table_qual[dxid_loop2].table_level < dxid_data->table_qual[(dxid_loop2+ 1)].
     table_level))
      SET dxid_data->table_qual[(dxid_data->table_cnt+ 1)].table_name = dxid_data->table_qual[
      dxid_loop2].table_name
      SET dxid_data->table_qual[(dxid_data->table_cnt+ 1)].table_level = dxid_data->table_qual[
      dxid_loop2].table_level
      SET dxid_data->table_qual[dxid_loop2].table_name = dxid_data->table_qual[(dxid_loop2+ 1)].
      table_name
      SET dxid_data->table_qual[dxid_loop2].table_level = dxid_data->table_qual[(dxid_loop2+ 1)].
      table_level
      SET dxid_data->table_qual[(dxid_loop2+ 1)].table_name = dxid_data->table_qual[(dxid_data->
      table_cnt+ 1)].table_name
      SET dxid_data->table_qual[(dxid_loop2+ 1)].table_level = dxid_data->table_qual[(dxid_data->
      table_cnt+ 1)].table_level
     ENDIF
   ENDFOR
 ENDFOR
 SET stat = alterlist(dxid_data->table_qual,dxid_data->table_cnt)
 SET dxid_qual_cnt = 0
 SELECT INTO "NL:"
  FROM dm_info d
  WHERE d.info_domain="DM_TABLES_DOC_TABLE_SUFFIX"
   AND expand(dxid_loop1,1,dxid_data->table_cnt,d.info_name,dxid_data->table_qual[dxid_loop1].
   table_name)
  DETAIL
   dxid_loop = locateval(dxid_loop2,1,dxid_data->table_cnt,d.info_name,dxid_data->table_qual[
    dxid_loop2].table_name), dxid_qual_cnt = (dxid_qual_cnt+ 1), dxid_data->table_qual[dxid_loop].
   table_suffix = d.info_char,
   dxid_data->table_qual[dxid_loop].proc_name = concat("XNTR_INS_",d.info_char)
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc) != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_dxid
 ENDIF
 IF ((dxid_qual_cnt != dxid_data->table_cnt))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Not all necessary table suffixes were found in DM_INFO"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_dxid
 ENDIF
 SELECT INTO "NL:"
  FROM user_objects u
  WHERE u.status="VALID"
   AND u.object_type="PROCEDURE"
   AND expand(dxid_loop1,1,dxid_data->table_cnt,u.object_name,dxid_data->table_qual[dxid_loop1].
   proc_name)
  DETAIL
   dxid_loop = locateval(dxid_loop2,1,dxid_data->table_cnt,u.object_name,dxid_data->table_qual[
    dxid_loop2].proc_name), dxid_data->table_qual[dxid_loop].exists_ind = 1
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc) != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_dxid
 ENDIF
 FOR (dxid_loop1 = 1 TO dxid_data->table_cnt)
   IF ((dxid_data->table_qual[dxid_loop1].exists_ind=0))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "One or more procedures are missing"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_dxid
   ENDIF
 ENDFOR
 FOR (dxid_loop1 = 1 TO dxid_data->table_cnt)
   INSERT  FROM dm_xntr_extract_cnt d
    SET d.dm_xntr_extract_cnt_id = seq(dm_clinical_seq,nextval), d.dm_xntr_extract_id =
     dxid_extract_id, d.table_name = dxid_data->table_qual[dxid_loop1].table_name,
     d.deleted_row_cnt = 0, d.retrieved_row_cnt = 0, d.updt_id = reqinfo->updt_id,
     d.retrieved_row_cnt = 0, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_task = reqinfo->
     updt_task,
     d.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_dxid
   ENDIF
   SET dxid_request->stmt[1].str = concat("RDB ASIS(^ begin ",dxid_data->table_qual[dxid_loop1].
    proc_name,"(",trim(cnvtstring(dxid_extract_id,20)),".0); END; ^) go")
   EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","DXID_REQUEST")
   IF (check_error(concat("Inserting data into live table ",dxid_data->table_qual[dxid_loop1].
     table_name)) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_dxid
   ENDIF
 ENDFOR
 COMMIT
#exit_dxid
END GO
