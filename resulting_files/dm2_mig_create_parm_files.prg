CREATE PROGRAM dm2_mig_create_parm_files
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
 IF (validate(rdisk->qual[1].disk_name,"")=""
  AND validate(rdisk->qual[1].disk_name,"Z")="Z")
  FREE RECORD rdisk
  RECORD rdisk(
    1 disk_cnt = i4
    1 qual[*]
      2 disk_name = vc
      2 volume_label = vc
      2 vg_name = vc
      2 pp_size_mb = f8
      2 total_space_mb = f8
      2 free_space_mb = f8
      2 new_free_space_mb = f8
      2 root_ind = i2
      2 used_ind = vc
      2 data_tspace = i2
      2 index_tspace = i2
      2 datafile_dir_exists = i2
      2 mwc_flag = i2
      2 alloc_unit_b = f8
      2 block_size_b = f8
  )
  SET rdisk->disk_cnt = 0
 ENDIF
 IF (validate(pv_lv_list->qual[1].pv_name,"")=""
  AND validate(pv_lv_list->qual[1].pv_name,"Z")="Z")
  FREE RECORD pv_lv_list
  RECORD pv_lv_list(
    1 cnt = i4
    1 pv[*]
      2 pv_name = vc
      2 lv[*]
        3 lv_name = vc
  )
 ENDIF
 IF (validate(pv_mwc_list->pv[1].pv_name,"")=""
  AND validate(pv_mwc_list->pv[1].pv_name,"Z")="Z")
  FREE RECORD pv_mwc_list
  RECORD pv_mwc_list(
    1 cnt = i4
    1 pv[*]
      2 pv_name = vc
      2 mwc_flag = i2
  )
 ENDIF
 IF ((validate(autopop_screen->top_line,- (1))=- (1))
  AND (validate(autopop_screen->top_line,- (2))=- (2)))
  FREE RECORD autopop_screen
  RECORD autopop_screen(
    1 top_line = i4
    1 bottom_line = i4
    1 cur_line = i4
    1 max_scroll = i4
    1 max_value = i4
    1 disk_cnt = i4
    1 remain_space_add = f8
    1 user_bytes = f8
    1 disk[*]
      2 volume_label = vc
      2 disk_name = vc
      2 vg_name = vc
      2 disk_idx = i4
      2 lv_filename = vc
      2 free_disk_space_mb = f8
      2 pp_size_mb = f8
      2 pps_to_add = f8
      2 space_to_add = f8
      2 disk_tspace_rel_key = i4
      2 cont_size_mb = f8
      2 delete_ind = i4
      2 disk_full_ind = i2
      2 orig_disk_space_mb = f8
      2 mwc_flag = i2
      2 alloc_unit_b = f8
      2 block_size_b = f8
  )
 ENDIF
 IF ((validate(rvg->vg_cnt,- (1))=- (1))
  AND (validate(rvg->vg_cnt,- (2))=- (2)))
  FREE RECORD rvg
  RECORD rvg(
    1 vg_cnt = i2
    1 qual[*]
      2 vg_name = vc
      2 psize = i4
      2 ttl_pps = f8
      2 free_pps = f8
      2 free_mb = f8
  )
  SET rvg->vg_cnt = 0
 ENDIF
 IF (validate(dos_sys_filename,"X")="X"
  AND validate(dos_sys_filename,"Y")="Y")
  DECLARE dos_sys_filename = vc WITH public, noconstant("DM2NOTSET")
  IF ((dm2_sys_misc->cur_db_os="AXP"))
   SET dos_sys_filename = logical("sys$sysdevice")
  ENDIF
 ENDIF
 IF ((validate(dor_flex_cmd->dfc_cnt,- (1))=- (1))
  AND (validate(dor_flex_cmd->dfc_cnt,- (2))=- (2)))
  RECORD dor_flex_cmd(
    1 dfc_cnt = i4
    1 cmd[*]
      2 flex_cmd_file = vc
      2 flex_cmd = vc
      2 flex_output = vc
      2 flex_out_file = vc
      2 flex_cmd_type = vc
      2 flex_local = i2
      2 flex_rmt_user = vc
      2 flex_rmt_node = vc
  )
 ENDIF
 DECLARE dm2_find_dir(sbr_dir_name=vc) = i2
 DECLARE dm2_find_queue(sbr_que_name=vc) = i2
 DECLARE dm2_get_mnt_disk_info_axp(sbr_outfile=vc) = i2
 DECLARE convert_blocks_to_bytes(cbb_block_in=f8) = f8
 DECLARE convert_bytes(byte_value=f8,from_flag=c1,to_flag=c1) = f8 WITH public
 DECLARE dm2_get_vg_disk_info_aix(null) = i4 WITH public
 DECLARE dm2_parse_aix_vg_disk_file(sbr_dsk_fname=vc) = i4 WITH public
 DECLARE dm2_parse_hpux_disk_file(sbr_dsk_fname=vc) = i4 WITH public
 DECLARE dm2_assign_disk(agd_size_in=f8,agd_last_disk_ndx=i4) = i4
 DECLARE dm2_create_dir(sbr_new_dir=vc,sbr_new_dir_type=vc) = i2
 DECLARE dm2_get_vgs(null) = i2
 DECLARE dm2_get_novg_disk_info_aix(null) = i2
 DECLARE dm2_get_nomnt_disk_info_axp(null) = i2
 DECLARE dm2_extend_vg(dev_vg_name=vc,dev_disk_name=vc) = i2
 DECLARE dm2_make_vg(dmv_vg_name=vc,dmv_psize=i4,dmv_disk_name=vc) = i2
 DECLARE dm2_init_mount_disk(dim_disk_name=vc,dim_vol_lbl=vc) = vc
 DECLARE dm2_get_mwc_flag(dgm_disk_name=vc) = i2
 DECLARE dm2_sub_space_from_disk(dss_disk_ndx=i4,dss_file_size=f8) = i2
 DECLARE dm2_aix_remove_lv(sbr_arl_db_name=vc) = i2
 DECLARE dm2_rename_login_default(sbr_rld_mode=vc) = i2
 DECLARE dm2_delete_dir(ddd_dir=vc) = i2
 DECLARE dm2_reduce_vg(drv_vg_name=vc,drv_disk_name=vc) = i2
 DECLARE get_space_rounded(space_add_in=f8,pp_size_in=f8) = f8
 DECLARE dm2_parse_aix_vg(dpa_fname=vc,dpa_rvg_idx=i4) = i2
 DECLARE dm2_check_cluster_lic(null) = i2
 DECLARE dos_get_lv_for_pv(dglp_file=vc) = i2
 DECLARE dos_get_sys_dev(dgsd_file=vc) = i2
 DECLARE dos_get_mwc_value(dgmv_file=vc,dgmv_mode=i2) = i2
 DECLARE dor_get_diskgroup_info(null) = i2
 DECLARE dor_load_rdisk_into_rvg(dlrir_os=vc) = i2
 DECLARE dor_init_flex_cmds(null) = i2
 DECLARE dor_add_flex_cmd(dafc_local=i2,dafc_rmt_user=vc,dafc_rmt_node=vc,dafc_cmd_file=vc,dafc_cmd=
  vc,
  dafc_out_file=vc,dafc_cmd_type=vc) = i2
 DECLARE dm2_dismount_disk(ddd_vol_label=vc) = i2
 DECLARE dor_exec_flex_cmd(null) = i2
 DECLARE dm2_parse_mnt_disk_info_axp(dpmdia_outfile=vc) = i2
 DECLARE dor_flex_chmod_file(dfcf_file=vc,dfcf_ssh_str=vc) = i2
 SUBROUTINE dor_flex_chmod_file(dfcf_file,dfcf_ssh_str)
   DECLARE dfcf_str = vc WITH protect, noconstant(" ")
   DECLARE dfcf_stat = i2 WITH protect, noconstant(0)
   SET dfcf_str = concat(dfcf_ssh_str," chmod 777 ",dfcf_file," > ",trim(logical("ccluserdir")),
    "/dfcf_outfile.out 2>&1")
   SET dfcf_stat = 0
   SET dfcf_stat = dcl(dfcf_str,textlen(dfcf_str),dfcf_stat)
   IF ((dm_err->debug_flag > 0))
    CALL echo(dfcf_str)
   ENDIF
   IF (dfcf_stat != 1)
    IF (parse_errfile(concat(trim(logical("ccluserdir")),"/dfcf_outfile.out"))=0)
     RETURN(0)
    ENDIF
    SET dm_err->err_ind = 1
    SET dm_err->emsg = dm_err->errtext
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dor_exec_flex_cmd(null)
   DECLARE defc_stat = i2 WITH protect, noconstant(0)
   DECLARE defc_cnt = i2 WITH protect, noconstant(0)
   DECLARE defc_str = vc WITH protect, noconstant("")
   DECLARE defc_ssh_str = vc WITH protect, noconstant("")
   IF ((dm_err->debug_flag > 5))
    CALL echorecord(dor_flex_cmd)
   ENDIF
   FOR (defc_cnt = 1 TO dor_flex_cmd->dfc_cnt)
     IF ((dor_flex_cmd->cmd[defc_cnt].flex_local=0))
      SET defc_ssh_str = concat("ssh ",dor_flex_cmd->cmd[defc_cnt].flex_rmt_user,"@",dor_flex_cmd->
       cmd[defc_cnt].flex_rmt_node," ")
     ELSE
      SET defc_ssh_str = " "
     ENDIF
     IF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type IN ("EF", "EFRO")))
      IF (dor_flex_chmod_file(dor_flex_cmd->cmd[defc_cnt].flex_cmd_file,defc_ssh_str)=0)
       RETURN(0)
      ENDIF
     ENDIF
     IF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type IN ("EF", "EFRO", "EFO")))
      IF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type="EFRO"))
       IF ((dor_flex_cmd->cmd[defc_cnt].flex_local=1))
        SET defc_str = concat(". ",dor_flex_cmd->cmd[defc_cnt].flex_cmd_file," > ",trim(logical(
           "ccluserdir")),"/defc_outfile.out")
       ELSE
        SET defc_str = concat(defc_ssh_str," ",dor_flex_cmd->cmd[defc_cnt].flex_cmd_file)
       ENDIF
      ELSEIF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type="EF"))
       SET defc_str = concat(". ",dor_flex_cmd->cmd[defc_cnt].flex_cmd_file)
      ELSEIF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type="EFO"))
       IF ((dor_flex_cmd->cmd[defc_cnt].flex_local=1))
        SET defc_str = concat("su - oracle -c ",dor_flex_cmd->cmd[defc_cnt].flex_cmd_file)
       ELSE
        SET defc_str = concat(defc_ssh_str," ",dor_flex_cmd->cmd[defc_cnt].flex_cmd_file)
       ENDIF
      ENDIF
      SET defc_stat = 0
      SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
      IF ((dm_err->debug_flag > 0))
       CALL echo(defc_str)
      ENDIF
      IF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type="EFRO"))
       IF (parse_errfile(concat(trim(logical("ccluserdir")),"/defc_outfile.out"))=0)
        RETURN(0)
       ENDIF
       SET dor_flex_cmd->cmd[defc_cnt].flex_output = dm_err->errtext
      ENDIF
     ENDIF
     IF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type IN ("EC")))
      IF (findstring("update_reg",dor_flex_cmd->cmd[defc_cnt].flex_cmd,1,0) > 0)
       IF (drr_exec_update_reg(dor_flex_cmd->cmd[defc_cnt].flex_cmd)=0)
        RETURN(0)
       ENDIF
      ELSE
       IF ((dor_flex_cmd->cmd[defc_cnt].flex_out_file=""))
        SET dor_flex_cmd->cmd[defc_cnt].flex_out_file = concat(trim(logical("ccluserdir")),
         "/defc_outfile.out")
       ENDIF
       IF ((dor_flex_cmd->cmd[defc_cnt].flex_out_file="*:APPEND"))
        SET defc_stat = 0
        SET defc_str = concat(defc_ssh_str," ",dor_flex_cmd->cmd[defc_cnt].flex_cmd," >> ",substring(
          1,(findstring(":",dor_flex_cmd->cmd[defc_cnt].flex_out_file,1,1) - 1),dor_flex_cmd->cmd[
          defc_cnt].flex_out_file),
         " 2>&1")
        IF ((dm_err->debug_flag > 0))
         CALL echo(defc_str)
        ENDIF
        SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
       ELSEIF ((dor_flex_cmd->cmd[defc_cnt].flex_out_file="noout"))
        SET defc_stat = 0
        SET defc_str = concat(defc_ssh_str," ",dor_flex_cmd->cmd[defc_cnt].flex_cmd)
        IF ((dm_err->debug_flag > 0))
         CALL echo(defc_str)
        ENDIF
        SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
       ELSE
        SET defc_stat = 0
        SET defc_str = concat(defc_ssh_str," ",dor_flex_cmd->cmd[defc_cnt].flex_cmd," > ",
         dor_flex_cmd->cmd[defc_cnt].flex_out_file,
         " 2>&1")
        IF ((dm_err->debug_flag > 0))
         CALL echo(defc_str)
        ENDIF
        SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
        IF (parse_errfile(dor_flex_cmd->cmd[defc_cnt].flex_out_file)=0)
         RETURN(0)
        ENDIF
        SET dor_flex_cmd->cmd[defc_cnt].flex_output = dm_err->errtext
       ENDIF
      ENDIF
     ENDIF
     IF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type IN ("EFORO")))
      IF ((dor_flex_cmd->cmd[defc_cnt].flex_local=1))
       SET defc_str = concat("su - oracle -c ",dor_flex_cmd->cmd[defc_cnt].flex_cmd_file)
      ELSE
       SET defc_str = concat(defc_ssh_str," ",dor_flex_cmd->cmd[defc_cnt].flex_cmd_file)
      ENDIF
      IF ((dor_flex_cmd->cmd[defc_cnt].flex_out_file=""))
       SET dor_flex_cmd->cmd[defc_cnt].flex_out_file = concat(trim(logical("ccluserdir")),
        "/defc_outfile.out")
      ENDIF
      SET defc_stat = 0
      SET defc_str = concat(defc_str," "," > ",dor_flex_cmd->cmd[defc_cnt].flex_out_file," 2>&1")
      IF ((dm_err->debug_flag > 0))
       CALL echo(defc_str)
      ENDIF
      SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
      IF (parse_errfile(dor_flex_cmd->cmd[defc_cnt].flex_out_file)=0)
       RETURN(0)
      ENDIF
      SET dor_flex_cmd->cmd[defc_cnt].flex_output = dm_err->errtext
     ENDIF
     IF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type IN ("EFRF")))
      SET defc_stat = 0
      IF ((dor_flex_cmd->cmd[defc_cnt].flex_local=0))
       SET defc_str = concat(defc_ssh_str," ",dor_flex_cmd->cmd[defc_cnt].flex_cmd_file," > ",
        dor_flex_cmd->cmd[defc_cnt].flex_out_file,
        " 2>&1")
      ELSE
       SET defc_str = concat(dor_flex_cmd->cmd[defc_cnt].flex_cmd_file," > ",dor_flex_cmd->cmd[
        defc_cnt].flex_out_file," 2>&1")
      ENDIF
      IF ((dm_err->debug_flag > 0))
       CALL echo(defc_str)
      ENDIF
      SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
      IF (defc_stat != 1)
       SET dm_err->err_ind = 1
       SET dm_err->emsg = concat("Error returned from:",defc_str)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      IF ((dor_flex_cmd->cmd[defc_cnt].flex_local=0))
       SET defc_str = concat("/usr/bin/scp ",dor_flex_cmd->cmd[defc_cnt].flex_rmt_user,"@",
        dor_flex_cmd->cmd[defc_cnt].flex_rmt_node,":",
        dor_flex_cmd->cmd[defc_cnt].flex_out_file," ",trim(logical("ccluserdir")),"/")
       IF ((dm_err->debug_flag > 0))
        CALL echo(defc_str)
       ENDIF
       SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
       IF (defc_stat != 1)
        SET dm_err->err_ind = 1
        SET dm_err->emsg = concat("Error returned from:",defc_str)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
     IF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type IN ("RCPBACK")))
      SET defc_str = concat("/usr/bin/scp ",dor_flex_cmd->cmd[defc_cnt].flex_rmt_user,"@",
       dor_flex_cmd->cmd[defc_cnt].flex_rmt_node,":",
       dor_flex_cmd->cmd[defc_cnt].flex_out_file," ",trim(logical("ccluserdir")),"/")
      IF ((dm_err->debug_flag > 0))
       CALL echo(defc_str)
      ENDIF
      SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
      IF (defc_stat != 1)
       SET dm_err->err_ind = 1
       SET dm_err->emsg = concat("Error returned from:",defc_str)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
     IF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type IN ("ECRF")))
      SET defc_stat = 0
      IF ((dor_flex_cmd->cmd[defc_cnt].flex_local=0))
       SET defc_str = concat(defc_ssh_str," ",dor_flex_cmd->cmd[defc_cnt].flex_cmd," > ",dor_flex_cmd
        ->cmd[defc_cnt].flex_out_file,
        " 2>&1")
      ELSE
       SET defc_str = concat(dor_flex_cmd->cmd[defc_cnt].flex_cmd," > ",dor_flex_cmd->cmd[defc_cnt].
        flex_out_file," 2>&1")
      ENDIF
      IF ((dm_err->debug_flag > 0))
       CALL echo(defc_str)
      ENDIF
      SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
      IF (defc_stat != 1)
       SET dm_err->err_ind = 1
       SET dm_err->emsg = concat("Error returned from:",defc_str)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      IF ((dor_flex_cmd->cmd[defc_cnt].flex_local=0))
       SET defc_str = concat("/usr/bin/scp ",dor_flex_cmd->cmd[defc_cnt].flex_rmt_user,"@",
        dor_flex_cmd->cmd[defc_cnt].flex_rmt_node,":",
        dor_flex_cmd->cmd[defc_cnt].flex_out_file," ",dor_flex_cmd->cmd[defc_cnt].flex_cmd_file)
       IF ((dm_err->debug_flag > 0))
        CALL echo(defc_str)
       ENDIF
       SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
       IF (defc_stat != 1)
        SET dm_err->err_ind = 1
        SET dm_err->emsg = concat("Error returned from:",defc_str)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
     IF ((dor_flex_cmd->cmd[defc_cnt].flex_cmd_type IN ("RCP")))
      IF ((dor_flex_cmd->cmd[defc_cnt].flex_local=0))
       SET defc_str = concat("/usr/bin/scp ",dor_flex_cmd->cmd[defc_cnt].flex_cmd_file," ",
        dor_flex_cmd->cmd[defc_cnt].flex_rmt_user,"@",
        dor_flex_cmd->cmd[defc_cnt].flex_rmt_node,":",dor_flex_cmd->cmd[defc_cnt].flex_out_file)
       IF ((dm_err->debug_flag > 0))
        CALL echo(defc_str)
       ENDIF
       SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
       IF (defc_stat != 1)
        SET dm_err->err_ind = 1
        SET dm_err->emsg = concat("Error returned from:",defc_str)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       IF (dor_flex_chmod_file(dor_flex_cmd->cmd[defc_cnt].flex_out_file,defc_ssh_str)=0)
        RETURN(0)
       ENDIF
      ELSE
       SET defc_str = concat("cp ",dor_flex_cmd->cmd[defc_cnt].flex_cmd_file," ",dor_flex_cmd->cmd[
        defc_cnt].flex_out_file)
       IF ((dm_err->debug_flag > 0))
        CALL echo(defc_str)
       ENDIF
       SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
       IF (defc_stat != 1)
        SET dm_err->err_ind = 1
        SET dm_err->emsg = concat("Error returned from:",defc_str)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
     IF ((dm_err->debug_flag > 722))
      SET defc_str = concat("cat ",trim(logical("ccluserdir")),"/defc_outfile.out")
      SET defc_stat = 0
      SET defc_stat = dcl(defc_str,textlen(defc_str),defc_stat)
     ENDIF
     SET dor_flex_cmd->cmd[defc_cnt].flex_output = trim(dor_flex_cmd->cmd[defc_cnt].flex_output,3)
   ENDFOR
   IF ((dm_err->debug_flag > 5))
    CALL echorecord(dor_flex_cmd)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dor_add_flex_cmd(dafc_local,dafc_rmt_user,dafc_rmt_node,dafc_cmd_file,dafc_cmd,
  dafc_out_file,dafc_cmd_type)
   SET dor_flex_cmd->dfc_cnt = (dor_flex_cmd->dfc_cnt+ 1)
   SET stat = alterlist(dor_flex_cmd->cmd,dor_flex_cmd->dfc_cnt)
   SET dor_flex_cmd->cmd[dor_flex_cmd->dfc_cnt].flex_cmd_file = dafc_cmd_file
   IF (dafc_local=0)
    SET dor_flex_cmd->cmd[dor_flex_cmd->dfc_cnt].flex_cmd = concat('"',dafc_cmd,'"')
    IF (findstring("echo $\?",dor_flex_cmd->cmd[dor_flex_cmd->dfc_cnt].flex_cmd,1,1) > 0)
     SET dor_flex_cmd->cmd[dor_flex_cmd->dfc_cnt].flex_cmd = replace(dor_flex_cmd->cmd[dor_flex_cmd->
      dfc_cnt].flex_cmd,"echo $?","echo \$?",0)
    ENDIF
   ELSE
    SET dor_flex_cmd->cmd[dor_flex_cmd->dfc_cnt].flex_cmd = dafc_cmd
   ENDIF
   SET dor_flex_cmd->cmd[dor_flex_cmd->dfc_cnt].flex_out_file = dafc_out_file
   SET dor_flex_cmd->cmd[dor_flex_cmd->dfc_cnt].flex_cmd_type = dafc_cmd_type
   SET dor_flex_cmd->cmd[dor_flex_cmd->dfc_cnt].flex_local = dafc_local
   SET dor_flex_cmd->cmd[dor_flex_cmd->dfc_cnt].flex_rmt_user = dafc_rmt_user
   SET dor_flex_cmd->cmd[dor_flex_cmd->dfc_cnt].flex_rmt_node = dafc_rmt_node
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dor_init_flex_cmds(null)
   SET dor_flex_cmd->dfc_cnt = 0
   SET stat = alterlist(dor_flex_cmd->cmd,0)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_find_dir(sbr_dir_name)
   DECLARE dfd_cmd_txt = vc WITH protect, noconstant(" ")
   DECLARE dfd_err_str = vc WITH protect, noconstant(" ")
   DECLARE dfd_err_str2 = vc WITH protect, noconstant(" ")
   DECLARE dfd_tmp_err_ind = i2 WITH protect, noconstant(0)
   DECLARE dfd_err_str3 = vc WITH protect, noconstant("")
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dfd_cmd_txt = concat("dir ",sbr_dir_name)
    SET dfd_err_str = "directory not found"
    SET dfd_err_str2 = "no files found"
    SET dfd_err_str3 = "error in device name"
   ELSE
    SET dfd_cmd_txt = concat("test -d ",sbr_dir_name,";echo $?")
    SET dfd_err_str = "0"
   ENDIF
   SET dm_err->disp_dcl_err_ind = 0
   CALL dm2_push_dcl(dfd_cmd_txt)
   SET dm_err->disp_dcl_err_ind = 1
   IF ((dm_err->err_ind=1))
    SET dm_err->err_ind = 0
    SET dfd_tmp_err_ind = 1
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    IF (findstring(dfd_err_str,dm_err->errtext,1,0) > 0)
     SET dm_err->eproc = concat("Directory ",sbr_dir_name," not found.")
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     RETURN(0)
    ELSEIF (findstring(dfd_err_str2,dm_err->errtext,1,0) > 0)
     SET dm_err->eproc = concat("Directory ",sbr_dir_name," exists with no files in directory.")
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     RETURN(1)
    ELSEIF (findstring(dfd_err_str3,dm_err->errtext,1,0) > 0)
     SET dm_err->eproc = concat("Directory device ",sbr_dir_name," does not exist.")
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     RETURN(0)
    ELSEIF (dfd_tmp_err_ind=1)
     SET dm_err->eproc = concat("Find directory  ",sbr_dir_name)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     RETURN(0)
    ENDIF
   ELSE
    IF (cnvtint(dm_err->errtext)=0)
     SET dm_err->eproc = concat("Directory ",sbr_dir_name," found.")
     IF ((dm_err->debug_flag > 1))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
     ENDIF
     RETURN(1)
    ELSE
     SET dm_err->eproc = concat("Directory ",sbr_dir_name," not found.")
     IF ((dm_err->debug_flag > 1))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
     ENDIF
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_find_queue(sbr_que_name)
   DECLARE dfd_cmd_txt = vc WITH protect, noconstant(" ")
   DECLARE dfd_err_str = vc WITH protect, noconstant(" ")
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dfd_cmd_txt = concat("sho queue ",sbr_que_name)
    SET dfd_err_str = "no such queue"
   ELSE
    RETURN(0)
   ENDIF
   IF (dm2_push_dcl(dfd_cmd_txt)=0)
    RETURN(0)
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(dm_err->errtext)
   ENDIF
   IF (findstring("idle",dm_err->errtext,1,0) > 0)
    RETURN(1)
   ELSE
    SET dm_err->eproc = concat("Make sure que ",sbr_que_name," is idle.")
    SET dm_err->emsg = dm_err->errtext
    CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dos_get_sys_dev(dgsd_file)
   DECLARE dgsd_device_name = vc WITH protect, noconstant("")
   DECLARE dgsd_start = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Gather system device name"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SET logical dgsd_sys_dev dgsd_file
   FREE DEFINE rtl
   DEFINE rtl "dgsd_sys_dev"
   SELECT INTO "nl:"
    t.line
    FROM rtlt t
    WHERE t.line > " "
    DETAIL
     dgsd_start = (findstring('"SYS$SYSDEVICE" = "',t.line)+ 19)
     IF ((dm_err->debug_flag > 1))
      CALL echo(t.line)
     ENDIF
     IF (dgsd_start > 0)
      dgsd_device_name = substring(dgsd_start,(findstring('"',t.line,(dgsd_start+ 1),1) - dgsd_start),
       t.line)
     ENDIF
     IF ((dm_err->debug_flag > 1))
      CALL echo(dgsd_device_name)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dgsd_device_name="")
    SET dm_err->eproc = concat("Could not gather system device name from file:",dgsd_file)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
   ENDIF
   SET dos_sys_filename = dgsd_device_name
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dos_get_mwc_value(dgmv_file,dgmv_mode)
   DECLARE dgmv_cmd = vc WITH protect, noconstant("")
   DECLARE dgmv_stat = i2 WITH protect, noconstant(0)
   DECLARE dgmv_cnt = i2 WITH protect, noconstant(0)
   IF (dgmv_mode=1)
    SET dgmv_cmd = concat(
     ^a=`lsvg -o | awk -v b="" '{b=sprintf("%s| %s ",b,$1)}END{print b}' | sed 's/^,
     "^| //g'`;for i in `lspv | egrep ",^"($a)" | awk '{print $1}'`;do lqueryvg -p /dev/$i -X | ^,
     ^echo $i `awk '{print" "$1}'` ;done >> ^,dgmv_file)
    IF ((dm_err->debug_flag > 0))
     CALL echo(concat("MWC command:",dgmv_cmd))
    ENDIF
    SET dm_err->eproc = "Gather MWC values"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SET dgmv_stat = dcl(dgmv_cmd,textlen(dgmv_cmd),dgmv_stat)
    IF (dgmv_stat=1)
     IF ((dm_err->debug_flag > 0))
      CALL echo(build("pv mwc listing file =",dgmv_file))
     ENDIF
    ELSE
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ENDIF
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->eproc = concat("Validate that ",dgmv_file," exists")
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    IF (findfile(dgmv_file)=0)
     SET dm_err->emsg = concat(dgmv_file," does not exist, unable to obtain MWC information")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Load MWC values"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SET logical mwc_disk_info dgmv_file
   FREE DEFINE rtl
   DEFINE rtl "mwc_disk_info"
   SELECT INTO "nl:"
    t.line
    FROM rtlt t
    WHERE t.line > " "
    DETAIL
     dgmv_cnt = (dgmv_cnt+ 1)
     IF (mod(dgmv_cnt,10)=1)
      stat = alterlist(pv_mwc_list->pv,(dgmv_cnt+ 9))
     ENDIF
     pv_mwc_list->pv[dgmv_cnt].pv_name = substring(1,(findstring(" ",t.line) - 1),t.line),
     pv_mwc_list->pv[dgmv_cnt].mwc_flag = evaluate(cnvtint(substring((findstring(" ",t.line)+ 1),1,t
        .line)),1,0,1)
     IF ((pv_mwc_list->pv[dgmv_cnt].mwc_flag=0))
      pv_mwc_list->pv[dgmv_cnt].mwc_flag = 1
     ELSE
      pv_mwc_list->pv[dgmv_cnt].mwc_flag = 0
     ENDIF
    FOOT REPORT
     pv_mwc_list->cnt = dgmv_cnt, stat = alterlist(pv_mwc_list->pv,dgmv_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dos_get_lv_for_pv(dglp_file)
   DECLARE dglp_cmd = vc WITH protect, noconstant("")
   DECLARE dglp_rtl_file = vc WITH protect, noconstant("")
   DECLARE dglp_pv_cnt = i4 WITH protect, noconstant(0)
   DECLARE dglp_lv_cnt = i4 WITH protect, noconstant(0)
   DECLARE dglp_stat = i4 WITH protect, noconstant(0)
   SET dglp_rtl_file = concat("ccluserdir:",dglp_file)
   SET logical aix_disk_info dglp_rtl_file
   FREE DEFINE rtl
   DEFINE rtl "aix_disk_info"
   SET dm_err->eproc = "Parse list of PVs and related LVs"
   IF ((dm_err->debug_flag > 1))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    t.line
    FROM rtlt t
    WHERE t.line > " "
    DETAIL
     IF (findstring(":",t.line) > 0)
      dglp_pv_cnt = (dglp_pv_cnt+ 1), stat = alterlist(pv_lv_list->pv,dglp_pv_cnt), pv_lv_list->pv[
      dglp_pv_cnt].pv_name = substring(1,(findstring(":",t.line) - 1),t.line),
      dglp_lv_cnt = 0
     ELSE
      IF ( NOT (findstring("LV NAME",t.line)))
       dglp_lv_cnt = (dglp_lv_cnt+ 1), stat = alterlist(pv_lv_list->pv[dglp_pv_cnt].lv,dglp_lv_cnt),
       pv_lv_list->pv[dglp_pv_cnt].lv[dglp_lv_cnt].lv_name = substring(1,(findstring(" ",t.line) - 1),
        t.line)
      ENDIF
     ENDIF
    FOOT REPORT
     pv_lv_list->cnt = dglp_pv_cnt
    WITH nocounter, maxcol = 500
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(pv_lv_list)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_parse_mnt_disk_info_axp(dpmdia_outfile)
   DECLARE axp_rtl_file = vc WITH public, noconstant("")
   DECLARE disk_vg_hold = vc WITH public, noconstant("")
   DECLARE axp_count_hold = i4 WITH public, noconstant(0)
   DECLARE spot_end = i4 WITH public, noconstant(0)
   DECLARE spot = i4 WITH public, noconstant(0)
   SET axp_rtl_file = concat("ccluserdir:",dpmdia_outfile)
   SET logical axp_disk_info axp_rtl_file
   FREE DEFINE rtl
   DEFINE rtl "axp_disk_info"
   SET dm_err->eproc = "Parse list of mounted disks"
   SELECT INTO "nl:"
    t.line
    FROM rtlt t
    WHERE t.line > " "
    HEAD REPORT
     axp_count_hold = 0
    DETAIL
     axp_count_hold = (axp_count_hold+ 1), stat = alterlist(rdisk->qual,axp_count_hold), spot =
     findstring(",",t.line,1),
     disk_name_hold = substring(1,(spot - 1),t.line), rdisk->qual[axp_count_hold].disk_name =
     disk_name_hold
     IF (disk_name_hold=dos_sys_filename)
      rdisk->qual[axp_count_hold].root_ind = 1
     ELSE
      rdisk->qual[axp_count_hold].root_ind = 0
     ENDIF
     disk_vg_hold = substring((spot+ 2),(textlen(t.line) - spot),t.line), spot = findstring(",",
      disk_vg_hold), disk_vg_hold = substring(1,(spot - 1),disk_vg_hold),
     rdisk->qual[axp_count_hold].volume_label = disk_vg_hold, spot = 0, spot = findstring(
      "Free Space:",t.line,1),
     spot_end = findstring("Total Space:",t.line,1), disk_free_space_mb = substring(spot,((spot_end
       - spot) - 1),t.line), spot = 0,
     spot = findstring(":",disk_free_space_mb,1), disk_free_space_mb = substring((spot+ 2),(textlen(
       disk_free_space_mb) - spot),disk_free_space_mb), rdisk->qual[axp_count_hold].free_space_mb =
     convert_bytes(convert_blocks_to_bytes(cnvtreal(disk_free_space_mb)),"b","m"),
     rdisk->qual[axp_count_hold].new_free_space_mb = rdisk->qual[axp_count_hold].free_space_mb, spot
      = 0, disk_free_space_mb = "",
     spot = findstring("Total Space:",t.line,1), disk_free_space_mb = substring(spot,(textlen(t.line)
       - spot),t.line), spot = 0,
     spot = findstring(":",disk_free_space_mb,1), disk_free_space_mb = substring((spot+ 2),(textlen(
       disk_free_space_mb) - spot),disk_free_space_mb), rdisk->qual[axp_count_hold].total_space_mb =
     convert_bytes(convert_blocks_to_bytes(cnvtreal(disk_free_space_mb)),"b","m")
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    SET message = nowindow
    CALL echorecord(rdisk)
    SET message = window
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_get_mnt_disk_info_axp(sbr_outfile)
   SET dm_err->eproc = "Get list of mounted disks"
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE dcl_str = vc WITH protect, noconstant(" ")
   SET dcl_str = concat("@cer_install:dm2_get_mnt_disk_info.com ",sbr_outfile)
   IF ( NOT (dm2_push_dcl(dcl_str)))
    RETURN(0)
   ENDIF
   IF (dm2_parse_mnt_disk_info_axp(sbr_outfile)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_get_vg_disk_info_aix(null)
   DECLARE dcl_str = vc WITH protect, noconstant(" ")
   DECLARE dcl_stat = i2 WITH protect, noconstant(0)
   DECLARE dcl_temp_file = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Get list of disks in a volume group"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET dm_err->eproc = "DM2_GET_VG_DISK_INFO_AIX: Get unique filename for disk list"
   IF (get_unique_file("dm2_disk_aix_info",".dat"))
    SET dcl_temp_file = dm_err->unique_fname
   ELSE
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AIX"))
    SET dm_err->eproc = "DM2_GET_VG_DISK_INFO_AIX: Get list of disks in a volume group"
    SET dcl_str = concat(^a=`lsvg -o | awk -v b="" '{b=sprintf("%s| %s ",b,$1)}^,
     "END{print b}' | sed 's/^| //g'`",
     ^;for i in `lspv | egrep "($a)" | awk '{print $1}'`;do lspv $i >> ^,dcl_temp_file,";done")
    SET dcl_stat = dcl(dcl_str,textlen(dcl_str),dcl_stat)
    IF (dcl_stat=1)
     IF ((dm_err->debug_flag > 0))
      CALL echo(build("disk_file =",dcl_temp_file))
     ENDIF
     IF ( NOT (dm2_parse_aix_vg_disk_file(dcl_temp_file)))
      RETURN(0)
     ELSE
      RETURN(1)
     ENDIF
    ELSE
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ENDIF
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->eproc = "DM2_GET_VG_DISK_INFO_AIX: Use VGDISPLAY to get list of Volume Groups."
    SET dcl_str = concat("vgdisplay > ",dm_err->unique_fname," 2>/dev/null")
    SET dcl_stat = 0
    SET dcl_stat = dcl(dcl_str,textlen(dcl_str),dcl_stat)
    IF (dcl_stat=0)
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ENDIF
     RETURN(0)
    ELSE
     IF ((dm_err->debug_flag > 0))
      CALL echo(build("disk_file =",dcl_temp_file))
     ENDIF
    ENDIF
    IF (dm2_parse_hpux_disk_file(dcl_temp_file)=0)
     RETURN(0)
    ELSE
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dor_load_rdisk_into_rvg(dlrir_os)
   DECLARE dlrir_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlrir_vg_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlrir_ndx = i4 WITH protect, noconstant(0)
   SET rvg->vg_cnt = 0
   SET stat = alterlist(rvg->qual,rvg->vg_cnt)
   FOR (dlrir_cnt = 1 TO rdisk->disk_cnt)
     IF ( NOT ((rdisk->qual[dlrir_cnt].vg_name IN ("rootvg", "/dev/vg00"))))
      IF (dlrir_cnt > 0
       AND locateval(dlrir_ndx,1,rvg->vg_cnt,rdisk->qual[dlrir_cnt].vg_name,rvg->qual[dlrir_ndx].
       vg_name) > 0)
       SET rvg->qual[dlrir_ndx].ttl_pps = (rvg->qual[dlrir_ndx].ttl_pps+ (rdisk->qual[dlrir_ndx].
       total_space_mb/ rdisk->qual[dlrir_ndx].pp_size_mb))
       SET rvg->qual[dlrir_ndx].free_pps = (rvg->qual[dlrir_ndx].free_pps+ (rdisk->qual[dlrir_cnt].
       free_space_mb/ rdisk->qual[dlrir_cnt].pp_size_mb))
       SET rvg->qual[dlrir_ndx].free_mb = (rvg->qual[dlrir_ndx].free_mb+ rdisk->qual[dlrir_cnt].
       free_space_mb)
      ELSE
       SET rvg->vg_cnt = (rvg->vg_cnt+ 1)
       SET stat = alterlist(rvg->qual,rvg->vg_cnt)
       IF (dlrir_os="HPX")
        SET rvg->qual[rvg->vg_cnt].vg_name = substring(6,(textlen(rdisk->qual[dlrir_cnt].vg_name) - 5
         ),rdisk->qual[dlrir_cnt].vg_name)
       ELSE
        SET rvg->qual[rvg->vg_cnt].vg_name = rdisk->qual[dlrir_cnt].vg_name
       ENDIF
       SET rvg->qual[rvg->vg_cnt].psize = rdisk->qual[dlrir_cnt].pp_size_mb
       SET rvg->qual[rvg->vg_cnt].ttl_pps = (rdisk->qual[dlrir_cnt].total_space_mb/ rdisk->qual[
       dlrir_cnt].pp_size_mb)
       SET rvg->qual[rvg->vg_cnt].free_pps = (rdisk->qual[dlrir_cnt].free_space_mb/ rdisk->qual[
       dlrir_cnt].pp_size_mb)
       SET rvg->qual[rvg->vg_cnt].free_mb = rdisk->qual[dlrir_cnt].free_space_mb
      ENDIF
     ENDIF
   ENDFOR
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(rdisk)
    CALL echorecord(rvg)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dor_get_diskgroup_info(null)
   SET stat = alterlist(rdisk->qual,0)
   SET rdisk->disk_cnt = 0
   SET dm_err->eproc = "Loading ASM diskgroups."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM v$asm_diskgroup v
    WHERE v.state IN ("CONNECTED", "MOUNTED")
    DETAIL
     rdisk->disk_cnt = (rdisk->disk_cnt+ 1), stat = alterlist(rdisk->qual,rdisk->disk_cnt), rdisk->
     qual[rdisk->disk_cnt].disk_name = v.name,
     rdisk->qual[rdisk->disk_cnt].total_space_mb = v.total_mb, rdisk->qual[rdisk->disk_cnt].
     free_space_mb = v.free_mb, rdisk->qual[rdisk->disk_cnt].new_free_space_mb = v.free_mb,
     rdisk->qual[rdisk->disk_cnt].alloc_unit_b = v.allocation_unit_size, rdisk->qual[rdisk->disk_cnt]
     .block_size_b = v.block_size
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(rdisk)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE convert_blocks_to_bytes(cbb_block_in)
   DECLARE cbb_bytes_per_block = f8 WITH public, noconstant(0.0)
   DECLARE cbb_return = f8 WITH public, noconstant(0.0)
   SET cbb_bytes_per_block = 512.0
   SET cbb_return = (cbb_block_in * cbb_bytes_per_block)
   RETURN(cbb_return)
 END ;Subroutine
 SUBROUTINE convert_bytes(byte_value,from_flag,to_flag)
   DECLARE mbyte_factor = f8 WITH constant(1048576.0)
   DECLARE kbyte_factor = f8 WITH constant(1024.0)
   DECLARE temp_byte_value = f8 WITH noconstant(0.0)
   CASE (from_flag)
    OF "m":
     SET byte_value = (byte_value * kbyte_factor)
    OF "k":
     SET byte_value = byte_value
    OF "b":
     SET byte_value = (byte_value/ kbyte_factor)
   ENDCASE
   CASE (to_flag)
    OF "b":
     SET temp_byte_value = byte_value
     SET temp_byte_value = (temp_byte_value * kbyte_factor)
    OF "m":
     SET temp_byte_value = byte_value
     SET temp_byte_value = (byte_value/ kbyte_factor)
    OF "k":
     SET temp_byte_value = byte_value
   ENDCASE
   SET temp_byte_value = dm2ceil(temp_byte_value)
   RETURN(temp_byte_value)
 END ;Subroutine
 SUBROUTINE dm2_assign_disk(agd_size_in,agd_last_disk_ndx)
   DECLARE agd_disk_ndx_ret = i4 WITH noconstant(0)
   DECLARE agd_disk_ndx = i4 WITH noconstant(0)
   DECLARE agd_disk_cnt = i4 WITH noconstant(0)
   DECLARE agd_size_check = f8 WITH noconstant(0.0)
   DECLARE agd_start_pt = i4 WITH noconstant(0)
   DECLARE agd_end_pt = i4 WITH noconstant(0)
   DECLARE agd_start_over = i4 WITH noconstant(0)
   IF ((dm_err->debug_flag > 1))
    SET dm_err->eproc = build("Assign file to disk: size_in=",agd_size_in,"; last_disk_ndx=",
     agd_last_disk_ndx)
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (agd_last_disk_ndx=size(autopop_screen->disk,5))
    SET agd_start_pt = 1
   ELSE
    SET agd_start_pt = (agd_last_disk_ndx+ 1)
   ENDIF
   SET agd_end_pt = size(autopop_screen->disk,5)
   SET agd_disk_cnt = agd_start_pt
   WHILE (agd_start_over < 2
    AND agd_disk_ndx_ret=0)
     IF ((dm_err->debug_flag > 3))
      CALL echo("*************************BEGINWHILE********************")
      CALL echo(agd_disk_cnt)
      CALL echo(agd_end_pt)
      CALL echo(agd_start_over)
      CALL echo(agd_size_check)
      CALL echo(autopop_screen->disk[agd_disk_cnt].free_disk_space_mb)
      CALL echo(autopop_screen->disk[agd_disk_cnt].disk_name)
      CALL echo(agd_disk_ndx_ret)
      CALL echo("*************************BEGINWHILEx********************")
     ENDIF
     SET agd_size_check = 0.0
     IF ((dir_storage_misc->tgt_storage_type IN ("ASM", "AXP")))
      SET agd_size_check = agd_size_in
     ELSE
      SET agd_size_check = get_space_rounded(cnvtreal(agd_size_in),autopop_screen->disk[agd_disk_cnt]
       .pp_size_mb)
     ENDIF
     IF ((dm_err->debug_flag > 3))
      CALL echo("Autopop Values")
      CALL echo(autopop_screen->disk[agd_disk_cnt].free_disk_space_mb)
      CALL echo(agd_size_check)
     ENDIF
     IF ((autopop_screen->disk[agd_disk_cnt].free_disk_space_mb > agd_size_check))
      SET agd_disk_ndx_ret = agd_disk_cnt
      IF ((dm_err->debug_flag > 3))
       CALL echo(agd_disk_ndx_ret)
      ENDIF
     ENDIF
     IF (agd_disk_cnt=agd_end_pt
      AND agd_disk_ndx_ret=0)
      IF (agd_start_over=0)
       IF (agd_start_pt != 1)
        SET agd_disk_cnt = 1
        SET agd_end_pt = agd_last_disk_ndx
        SET agd_start_over = (agd_start_over+ 1)
       ELSE
        SET agd_start_over = 2
       ENDIF
      ELSE
       SET agd_start_over = 2
      ENDIF
     ELSE
      IF (((agd_disk_cnt+ 1) > size(autopop_screen->disk,5)))
       SET agd_disk_cnt = size(autopop_screen->disk,5)
      ELSE
       SET agd_disk_cnt = (agd_disk_cnt+ 1)
      ENDIF
     ENDIF
     IF ((dm_err->debug_flag > 3))
      CALL echo("*************************ENDWHILE********************")
      CALL echo(agd_disk_cnt)
      CALL echo(agd_end_pt)
      CALL echo(agd_start_over)
      CALL echo(agd_size_check)
      CALL echo(autopop_screen->disk[agd_disk_cnt].free_disk_space_mb)
      CALL echo(autopop_screen->disk[agd_disk_cnt].disk_name)
      CALL echo(agd_disk_ndx_ret)
      CALL echo("*************************ENDWHILEx********************")
     ENDIF
   ENDWHILE
   RETURN(agd_disk_ndx_ret)
 END ;Subroutine
 SUBROUTINE dm2_sub_space_from_disk(dss_disk_ndx,dss_file_size)
   SET dm_err->eproc =
   "Substract dfile size from selected disk and reset autopop_screen disk free space."
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dir_storage_misc->tgt_storage_type="RAW"))
    SET dss_file_size = get_space_rounded(cnvtreal(dss_file_size),autopop_screen->disk[dss_disk_ndx].
     pp_size_mb)
   ENDIF
   SET autopop_screen->disk[dss_disk_ndx].free_disk_space_mb = (autopop_screen->disk[dss_disk_ndx].
   free_disk_space_mb - dss_file_size)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE get_space_rounded(space_add_in,pp_size_in)
   DECLARE space_add_out = f8 WITH public, noconstant(0.0)
   IF ((dm_err->debug_flag > 1))
    SET dm_err->eproc = build("In get_space_rounded subroutine")
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET space_add_out = 0.0
   IF (mod(cnvtint(space_add_in),cnvtint(pp_size_in)) > 0)
    SET space_add_out = (space_add_in+ (cnvtint(pp_size_in) - mod(cnvtint(space_add_in),cnvtint(
      pp_size_in))))
   ELSE
    SET space_add_out = space_add_in
   ENDIF
   RETURN(space_add_out)
 END ;Subroutine
 SUBROUTINE dm2_parse_aix_vg_disk_file(sbr_dsk_fname)
   DECLARE disk_str = vc WITH public
   FREE RECORD dm2parse
   RECORD dm2parse(
     1 attr1 = vc
     1 attr1sep = vc
     1 attr2 = vc
     1 attr2sep = vc
     1 attr3 = vc
     1 attr3sep = vc
     1 attr4 = vc
     1 attr4sep = vc
     1 attr5 = vc
     1 attr5sep = vc
     1 qual[*]
       2 attr1val = vc
       2 attr2val = vc
       2 attr3val = vc
       2 attr4val = vc
       2 attr5val = vc
   ) WITH public
   SET dm2parse->attr1 = "PHYSICAL VOLUME:"
   SET dm2parse->attr1sep = " "
   SET dm2parse->attr2 = "VOLUME GROUP:"
   SET dm2parse->attr2sep = " "
   SET dm2parse->attr3 = "PP SIZE:"
   SET dm2parse->attr3sep = " "
   SET dm2parse->attr4 = "TOTAL PPs:"
   SET dm2parse->attr4sep = " "
   SET dm2parse->attr5 = "FREE PPs:"
   SET dm2parse->attr5sep = " "
   SET dm_err->eproc = build("Parsing list of aix disks in volume groups")
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dm2parse_output(5,sbr_dsk_fname,"H"))
    IF ((dm_err->debug_flag > 1))
     CALL echorecord(dm2parse)
    ENDIF
    SET stat = alterlist(rdisk->qual,size(dm2parse->qual,5))
    FOR (ts_cnt_var = 1 TO size(dm2parse->qual,5))
      SET end_pos = findstring(" ",dm2parse->qual[ts_cnt_var].attr1val)
      IF (end_pos > 1)
       SET rdisk->qual[ts_cnt_var].disk_name = substring(1,(end_pos - 1),dm2parse->qual[ts_cnt_var].
        attr1val)
       SET end_pos = 0
      ENDIF
      IF (trim(dm2parse->qual[ts_cnt_var].attr2val,3) > " ")
       SET rdisk->qual[ts_cnt_var].vg_name = trim(dm2parse->qual[ts_cnt_var].attr2val,3)
       IF (cnvtupper(rdisk->qual[ts_cnt_var].vg_name)="ROOTVG")
        SET rdisk->qual[ts_cnt_var].root_ind = 1
       ELSE
        SET rdisk->qual[ts_cnt_var].root_ind = 0
       ENDIF
      ENDIF
      SET end_pos = findstring(" ",dm2parse->qual[ts_cnt_var].attr3val)
      IF (end_pos > 1)
       SET rdisk->qual[ts_cnt_var].pp_size_mb = cnvtreal(substring(1,(end_pos - 1),dm2parse->qual[
         ts_cnt_var].attr3val))
       SET end_pos = 0
      ENDIF
      SET start_pos = findstring("(",dm2parse->qual[ts_cnt_var].attr4val)
      SET end_pos = findstring("m",dm2parse->qual[ts_cnt_var].attr4val)
      IF (start_pos > 0
       AND end_pos > 0)
       SET rdisk->qual[ts_cnt_var].total_space_mb = cnvtreal(substring((start_pos+ 1),((end_pos -
         start_pos) - 2),dm2parse->qual[ts_cnt_var].attr4val))
       SET start_pos = 0
       SET end_pos = 0
      ENDIF
      SET start_pos = findstring("(",dm2parse->qual[ts_cnt_var].attr5val)
      SET end_pos = findstring("m",dm2parse->qual[ts_cnt_var].attr5val)
      IF (start_pos > 0
       AND end_pos > 0)
       SET rdisk->qual[ts_cnt_var].free_space_mb = cnvtreal(substring((start_pos+ 1),((end_pos -
         start_pos) - 2),dm2parse->qual[ts_cnt_var].attr5val))
       SET rdisk->qual[ts_cnt_var].new_free_space_mb = rdisk->qual[ts_cnt_var].free_space_mb
       SET start_pos = 0
       SET end_pos = 0
      ENDIF
    ENDFOR
   ELSE
    RETURN(0)
   ENDIF
   IF (size(rdisk->qual,5) > 0)
    SET rdisk->disk_cnt = size(rdisk->qual,5)
    SET rdisk_filled = "Y"
    SET dm_err->eproc = build("Disk file parsed successfully")
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ELSE
    CALL clear(23,1,130)
    SET dm_err->eproc = build("Parsing disk file.  RDISK not filled.")
    SET dm_err->err_ind = 1
    CALL disp_msg(" ",dm_err->logfile,1)
    CALL text(23,2,"Unable to load system disk information - exiting application.")
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_parse_hpux_disk_file(sbr_dsk_fname)
   DECLARE disk_str = vc WITH public
   FREE RECORD dm2parse
   RECORD dm2parse(
     1 attr1 = vc
     1 attr1sep = vc
     1 attr2 = vc
     1 attr2sep = vc
     1 attr3 = vc
     1 attr3sep = vc
     1 attr4 = vc
     1 attr4sep = vc
     1 qual[*]
       2 attr1val = vc
       2 attr2val = vc
       2 attr3val = vc
       2 attr4val = vc
   )
   SET dm2parse->attr1 = "VG Name"
   SET dm2parse->attr1sep = " "
   SET dm2parse->attr2 = "PE Size (Mbytes)"
   SET dm2parse->attr2sep = " "
   SET dm2parse->attr3 = "Total PE"
   SET dm2parse->attr3sep = " "
   SET dm2parse->attr4 = "Free PE"
   SET dm2parse->attr4sep = " "
   IF (dm2parse_output(4,sbr_dsk_fname,"V"))
    SET stat = alterlist(rdisk->qual,size(dm2parse->qual,5))
    FOR (ts_cnt_var = 1 TO size(dm2parse->qual,5))
      SET rdisk->qual[ts_cnt_var].disk_name = dm2parse->qual[ts_cnt_var].attr1val
      SET rdisk->qual[ts_cnt_var].vg_name = rdisk->qual[ts_cnt_var].disk_name
      IF (cnvtupper(rdisk->qual[ts_cnt_var].disk_name)="/DEV/VG00")
       SET rdisk->qual[ts_cnt_var].root_ind = 1
      ELSE
       SET rdisk->qual[ts_cnt_var].root_ind = 0
      ENDIF
      SET rdisk->qual[ts_cnt_var].pp_size_mb = cnvtreal(dm2parse->qual[ts_cnt_var].attr2val)
      SET rdisk->qual[ts_cnt_var].total_space_mb = cnvtreal(dm2parse->qual[ts_cnt_var].attr3val)
      SET rdisk->qual[ts_cnt_var].free_space_mb = cnvtreal(dm2parse->qual[ts_cnt_var].attr4val)
      SET rdisk->qual[ts_cnt_var].new_free_space_mb = rdisk->qual[ts_cnt_var].free_space_mb
      SET rdisk->qual[ts_cnt_var].total_space_mb = (rdisk->qual[ts_cnt_var].pp_size_mb * rdisk->qual[
      ts_cnt_var].total_space_mb)
      SET rdisk->qual[ts_cnt_var].free_space_mb = (rdisk->qual[ts_cnt_var].pp_size_mb * rdisk->qual[
      ts_cnt_var].free_space_mb)
      SET rdisk->qual[ts_cnt_var].new_free_space_mb = (rdisk->qual[ts_cnt_var].pp_size_mb * rdisk->
      qual[ts_cnt_var].new_free_space_mb)
    ENDFOR
   ELSE
    RETURN(0)
   ENDIF
   IF (size(rdisk->qual,5) > 0)
    SET rdisk->disk_cnt = size(rdisk->qual,5)
    SET rdisk_filled = "Y"
    SET dm_err->eproc = build("Disk file parsed successfully")
    CALL disp_msg(" ",dm_err->logfile,0)
    RETURN(1)
   ELSE
    CALL clear(23,1,130)
    SET dm_err->eproc = build("Parsing disk file.  RDISK not filled.")
    SET dm_err->err_ind = 1
    CALL disp_msg(" ",dm_err->logfile,1)
    CALL text(23,2,"Unable to load system disk information - exiting application.")
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_create_dir(sbr_new_dir,sbr_new_dir_type)
   DECLARE dcd_cmd_txt = vc WITH protect, noconstant(" ")
   DECLARE dcd_stat = i2 WITH protect, noconstant(0)
   DECLARE dcd_strip_txt1 = vc WITH protect, noconstant("")
   DECLARE dcd_strip_txt2 = vc WITH protect, noconstant("")
   DECLARE dcd_num_hold = i2 WITH protect, noconstant(0)
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dcd_cmd_txt = concat("create/dir ",sbr_new_dir)
   ELSE
    SET dcd_cmd_txt = concat("mkdir ",sbr_new_dir)
   ENDIF
   CALL dm2_push_dcl(dcd_cmd_txt)
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF (sbr_new_dir_type="DB")
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dcd_num_hold = findstring(".",sbr_new_dir,1,1)
     SET dcd_strip_txt1 = substring(1,(dcd_num_hold - 1),sbr_new_dir)
     SET dcd_strip_txt2 = substring((dcd_num_hold+ 1),((findstring("]",sbr_new_dir,1,1) -
      dcd_num_hold) - 1),sbr_new_dir)
     SET dcd_cmd_txt = concat("set file/prot=(s:rwed,o:rwed,g:rwed,w:rwe) ",dcd_strip_txt1,"]",
      dcd_strip_txt2,".dir")
     CALL dm2_push_dcl(dcd_cmd_txt)
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_delete_dir(ddd_dir)
   DECLARE ddd_cmd_txt = vc WITH protect, noconstant(" ")
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET ddd_cmd_txt = concat("del ",trim(ddd_dir),";")
   ENDIF
   IF (dm2_push_dcl(ddd_cmd_txt)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_get_novg_disk_info_aix(null)
   IF ((dm_err->debug_flag > 0))
    SET message = nowindow
   ENDIF
   SET dm_err->eproc = "Get list of disks not in volume group and store them in rDisk."
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE dgn_cmd = vc WITH protect, noconstant(" ")
   DECLARE dgn_drive = vc WITH protect, noconstant(" ")
   SET dgn_cmd = "lspv | grep vpath"
   IF (dm2_push_dcl(dgn_cmd)=0)
    IF ((dm_err->err_ind=1))
     IF ((dm_err->emsg > " "))
      RETURN(0)
     ELSE
      SET dm_err->eproc = "Message reported when getting vpath is okay - process continuing"
      CALL disp_msg(" ",dm_err->logfile,0)
      SET dm_err->err_ind = 0
     ENDIF
    ENDIF
   ELSE
    SET dgn_drive = "vpath"
   ENDIF
   IF (dgn_drive != "vpath")
    SET dgn_cmd = "lspv | grep hdisk"
    IF (dm2_push_dcl(dgn_cmd)=0)
     IF ((dm_err->err_ind=1))
      IF ((dm_err->emsg > " "))
       RETURN(0)
      ELSE
       SET dm_err->eproc = "Message reported when getting hdisk is okay - process continuing"
       CALL disp_msg(" ",dm_err->logfile,0)
       SET dm_err->err_ind = 0
      ENDIF
     ENDIF
    ELSE
     SET dgn_drive = "hdisk"
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("dgn_drive =",dgn_drive))
   ENDIF
   IF (dgn_drive=" ")
    SET message = nowidnow
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Get list of disks not in volume group and store them in rDisk."
    SET dm_err->emsg =
    "Cerner currently recognizes only VPATH and HDISK disk names.  Unable to find a recognized storage disk name."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dgn_drive="hdisk")
    SET dgn_cmd = "lspv | grep hdisk | grep None"
   ELSE
    SET dgn_cmd = "lspv | grep vpath | grep None"
   ENDIF
   IF (dm2_push_dcl(dgn_cmd)=0)
    IF ((dm_err->err_ind=1))
     IF ((dm_err->emsg > " "))
      RETURN(0)
     ELSE
      SET dm_err->eproc = "Message reported when getting list of disks is okay - process continuing"
      CALL disp_msg("",dm_err->logfile,0)
      SET dm_err->err_ind = 0
      RETURN(1)
     ENDIF
    ENDIF
   ENDIF
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(dm_err->errfile)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    HEAD REPORT
     end_pos = 0
    DETAIL
     end_pos = 0, end_pos = findstring(" ",r.line)
     IF (end_pos > 0)
      rdisk->disk_cnt = (rdisk->disk_cnt+ 1), stat = alterlist(rdisk->qual,rdisk->disk_cnt), rdisk->
      qual[rdisk->disk_cnt].disk_name = substring(1,(end_pos - 1),r.line)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(concat("Get list of disks not in volume group.")) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    SET message = window
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_get_vgs(null)
   SET dm_err->eproc = "Get list of volume groups."
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE dgv_cmd = vc WITH protect, noconstant(" ")
   SET rvg->vg_cnt = 0
   SET stat = alterlist(rvg->qual,0)
   IF ((dm2_sys_misc->cur_os="AIX"))
    SET dgv_cmd = "lsvg -o"
   ELSE
    SET dgv_cmd = 'vgdisplay|grep "VG Name"|cut -d/ -f3'
   ENDIF
   IF (dm2_push_dcl(dgv_cmd)=0)
    RETURN(0)
   ENDIF
   FREE DEFINE rtl
   FREE SET file_loc
   SET logical file_loc value(dm_err->errfile)
   DEFINE rtl logical("file_loc")
   SELECT INTO "nl:"
    r.line
    FROM rtlt r
    DETAIL
     IF (trim(r.line) != "rootvg")
      rvg->vg_cnt = (rvg->vg_cnt+ 1), stat = alterlist(rvg->qual,rvg->vg_cnt), rvg->qual[rvg->vg_cnt]
      .vg_name = trim(r.line)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error("Get list of volume groups.") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   FOR (dgv_i = 1 TO rvg->vg_cnt)
     IF ((dm2_sys_misc->cur_os="AIX"))
      SET dgv_cmd = concat("lsvg ",trim(rvg->qual[dgv_i].vg_name))
     ELSE
      SET dgv_cmd = concat("vgdisplay ",trim(rvg->qual[dgv_i].vg_name))
     ENDIF
     IF (dm2_push_dcl(dgv_cmd)=0)
      RETURN(0)
     ENDIF
     IF (dm2_parse_aix_vg(dm_err->errfile,dgv_i)=0)
      RETURN(0)
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_parse_aix_vg(dpa_fname,dpa_rvg_idx)
   SET dm_err->eproc = build("Parsing volume group's infomation")
   CALL disp_msg(" ",dm_err->logfile,0)
   FREE RECORD dm2parse
   RECORD dm2parse(
     1 attr1 = vc
     1 attr1sep = vc
     1 attr2 = vc
     1 attr2sep = vc
     1 attr3 = vc
     1 attr3sep = vc
     1 qual[*]
       2 attr1val = vc
       2 attr2val = vc
       2 attr3val = vc
   ) WITH public
   IF ((dm2_sys_misc->cur_os="AIX"))
    SET dm2parse->attr1 = "PP SIZE:"
    SET dm2parse->attr1sep = " "
    SET dm2parse->attr2 = "TOTAL PPs:"
    SET dm2parse->attr2sep = " "
    SET dm2parse->attr3 = "FREE PPs:"
    SET dm2parse->attr3sep = " "
   ELSE
    SET dm2parse->attr1 = "PE Size (Mbytes)"
    SET dm2parse->attr1sep = " "
    SET dm2parse->attr2 = "Total PE"
    SET dm2parse->attr2sep = " "
    SET dm2parse->attr3 = "Free PE"
    SET dm2parse->attr3sep = " "
   ENDIF
   IF (dm2parse_output(3,dpa_fname,"H"))
    IF (size(dm2parse->qual,5)=1)
     SET dpa_i = 1
     IF ((dm2_sys_misc->cur_os="AIX"))
      SET end_pos = findstring(" ",dm2parse->qual[dpa_i].attr1val)
      IF (end_pos > 1)
       SET rvg->qual[dpa_rvg_idx].psize = cnvtreal(substring(1,(end_pos - 1),dm2parse->qual[dpa_i].
         attr1val))
       SET end_pos = 0
      ENDIF
      SET end_pos = findstring(" ",dm2parse->qual[dpa_i].attr2val)
      IF (end_pos > 1)
       SET rvg->qual[dpa_rvg_idx].ttl_pps = cnvtreal(substring(1,(end_pos - 1),dm2parse->qual[dpa_i].
         attr2val))
       SET end_pos = 0
      ENDIF
      SET end_pos = findstring(" ",dm2parse->qual[dpa_i].attr3val)
      IF (end_pos > 1)
       SET rvg->qual[dpa_rvg_idx].free_pps = cnvtreal(substring(1,(end_pos - 1),dm2parse->qual[dpa_i]
         .attr3val))
       SET end_pos = 0
      ENDIF
      SET start_pos = findstring("(",dm2parse->qual[dpa_i].attr3val)
      SET end_pos = findstring("m",dm2parse->qual[dpa_i].attr3val)
      IF (start_pos > 0
       AND end_pos > 0)
       SET rvg->qual[dpa_rvg_idx].free_mb = cnvtreal(substring((start_pos+ 1),((end_pos - start_pos)
          - 2),dm2parse->qual[dpa_i].attr3val))
       SET start_pos = 0
       SET end_pos = 0
      ENDIF
     ELSE
      SET rvg->qual[dpa_rvg_idx].psize = cnvtreal(dm2parse->qual[dpa_i].attr1val)
      SET rvg->qual[dpa_rvg_idx].ttl_pps = cnvtreal(dm2parse->qual[dpa_i].attr2val)
      SET rvg->qual[dpa_rvg_idx].free_pps = cnvtreal(dm2parse->qual[dpa_i].attr3val)
      SET rvg->qual[dpa_rvg_idx].free_mb = (rvg->qual[dpa_rvg_idx].free_pps * rvg->qual[dpa_rvg_idx].
      psize)
     ENDIF
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat(
      "Parse VG information failed.  Multiple lines of information found for VG ",rvg->qual[
      dpa_rvg_idx].vg_name)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_get_nomnt_disk_info_axp(null)
   SET dm_err->eproc = "Get list of not mounted disks"
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE dgn_dcl_str = vc WITH protect, noconstant(" ")
   DECLARE dgn_rtl_file = vc WITH protect, noconstant("")
   DECLARE dgn_spot = i4 WITH protect, noconstant(0)
   FREE RECORD dgn_disks
   RECORD dgn_disks(
     1 disk_cnt = i4
     1 disk[*]
       2 disk_name = vc
       2 remote_ind = i2
   )
   SET dgn_dcl_str = "@cer_install:dm2_get_nomnt_disk_info.com"
   IF ( NOT (dm2_push_dcl(dgn_dcl_str)))
    RETURN(0)
   ENDIF
   SET dgn_rtl_file = "ccluserdir:dm2_disk_list.tmp"
   SET logical axp_disk_info dgn_rtl_file
   FREE DEFINE rtl
   DEFINE rtl "axp_disk_info"
   SELECT INTO "nl:"
    t.line
    FROM rtlt t
    WHERE t.line > " "
    DETAIL
     dgn_disks->disk_cnt = (dgn_disks->disk_cnt+ 1), stat = alterlist(dgn_disks->disk,dgn_disks->
      disk_cnt), dgn_spot = 0,
     dgn_spot = findstring(" ",t.line,1)
     IF (dgn_spot > 0)
      dgn_disks->disk[dgn_disks->disk_cnt].disk_name = substring(1,(dgn_spot - 1),t.line)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   FOR (dgn_i = 1 TO dgn_disks->disk_cnt)
     SET dgn_dcl_str = concat("sho device ",dgn_disks->disk[dgn_i].disk_name," /out=disk_info.tmp")
     IF ( NOT (dm2_push_dcl(dgn_dcl_str)))
      RETURN(0)
     ENDIF
     SET dgn_rtl_file = "ccluserdir:disk_info.tmp"
     SET logical axp_disk_info dgn_rtl_file
     FREE DEFINE rtl
     DEFINE rtl "axp_disk_info"
     SELECT INTO "nl:"
      t.line
      FROM rtlt t
      WHERE t.line > " "
      DETAIL
       dgn_spot = 0, dgn_spot = findstring("REMOTE MOUNT",cnvtupper(t.line),1)
       IF (dgn_spot > 0)
        dgn_disks->disk[dgn_i].remote_ind = 1
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error("filter out disks that are remote mount") != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
   ENDFOR
   SET rdisk->disk_cnt = size(rdisk->qual,5)
   SELECT INTO "nl:"
    dgn_disks->disk[d.seq].disk_name
    FROM (dummyt d  WITH seq = value(dgn_disks->disk_cnt))
    WHERE (dgn_disks->disk[d.seq].remote_ind=0)
    DETAIL
     rdisk->disk_cnt = (rdisk->disk_cnt+ 1), stat = alterlist(rdisk->qual,rdisk->disk_cnt), rdisk->
     qual[rdisk->disk_cnt].disk_name = dgn_disks->disk[d.seq].disk_name
    WITH nocounter
   ;end select
   IF (check_error("Populate rDisk with not mounted disks") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(dgn_disks)
    CALL echorecord(rdisk)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_make_vg(dmv_vg_name,dmv_psize,dmv_disk_name)
   IF ((dm_err->debug_flag > 0))
    SET message = nowindow
   ENDIF
   SET dm_err->eproc = concat("Create new volume group ",dmv_vg_name," with disks ",dmv_disk_name)
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE dmv_cmd = vc WITH protect, noconstant(" ")
   IF (substring(1,1,dmv_disk_name)="v")
    SET dmv_cmd = "mkvg4vp"
   ELSEIF (substring(1,1,dmv_disk_name)="h")
    SET dmv_cmd = "mkvg"
   ENDIF
   SET dmv_cmd = concat(dmv_cmd," -B -f -y ",dmv_vg_name," -s ",cnvtstring(dmv_psize),
    " ",dmv_disk_name)
   IF (dm2_push_dcl(dmv_cmd)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    SET message = window
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_extend_vg(dev_vg_name,dev_disk_name)
   IF ((dm_err->debug_flag > 0))
    SET message = nowindow
   ENDIF
   SET dm_err->eproc = concat("Extend existing volume group ",dev_vg_name," with disk ",dev_disk_name
    )
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE dev_cmd = vc WITH protect, noconstant(" ")
   IF (substring(1,1,dev_disk_name)="v")
    SET dev_cmd = "extendvg4vp"
   ELSEIF (substring(1,1,dev_disk_name)="h")
    SET dev_cmd = "extendvg"
   ENDIF
   SET dev_cmd = concat(dev_cmd," -f ",dev_vg_name," ",dev_disk_name)
   IF (dm2_push_dcl(dev_cmd)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    SET message = window
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_reduce_vg(drv_vg_name,drv_disk_name)
   SET dm_err->eproc = concat("Reduce existing volume group ",drv_vg_name," with disk ",drv_disk_name
    )
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE drv_del_vg = i2 WITH protect, noconstant(0)
   SET width = 132
   SET message = window
   CALL clear(1,1)
   CALL text(1,1,dm_err->eproc)
   CALL text(2,1,"Would you like to (C)ontinue or (Q)uit?")
   CALL accept(2,60,"P;CU","C"
    WHERE curaccept IN ("C", "Q"))
   IF (curaccept="Q")
    SET dm_err->emsg = "User choose to quit the program."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET message = nowindow
   DECLARE drv_cmd = vc WITH protect, noconstant(" ")
   SET drv_cmd = concat("reducevg ",drv_vg_name," ",drv_disk_name)
   IF (dm2_push_dcl(drv_cmd)=0)
    RETURN(0)
   ENDIF
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(dm_err->errfile)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    DETAIL
     IF ( NOT (drv_del_vg))
      drv_del_vg = findstring("ldeletepv",r.line)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(concat("Parsing error file ",dm_err->errfile))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (drv_del_vg)
    IF ((dm_err->debug_flag > 0))
     SET message = nowindow
     CALL echo(concat("vg ",drv_vg_name," was deleted."))
     SET message = window
    ENDIF
    SET dpf_existing_vg_ind = 0
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_init_mount_disk(dim_disk_name,dim_vol_lbl)
   SET dm_err->eproc = concat("Mount disk ",trim(dim_disk_name)," on vol_lable ",dim_vol_lbl)
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE dimd_cmd = vc WITH protect, noconstant(" ")
   DECLARE dimd_fnd = i2 WITH protect, noconstant(0)
   IF ((dm2_create_dom->dbtype != "ADMIN"))
    WHILE (dim_vol_lbl="dm2_not_set")
      SET width = 132
      SET message = window
      CALL clear(1,1)
      CALL text(2,1,concat("Please enter volume label to mount disk ",dim_disk_name,":"))
      CALL accept(2,60,"P(20);cu")
      SET dim_vol_lbl = curaccept
      SET dimd_fnd = 0
      SET dimd_fnd = locateval(dimd_fnd,1,size(rdisk->qual,5),dim_vol_lbl,rdisk->qual[dimd_fnd].
       volume_label)
      IF (dimd_fnd)
       CALL text(4,1,concat("The volume lable name ",dim_vol_lbl,
         " is used.  Please enter a different name."))
       CALL text(6,1,"Would you like to (C)ontinue or (Q)uit?")
       CALL accept(6,60,"P;CU","C"
        WHERE curaccept IN ("C", "Q"))
       IF (curaccept="Q")
        SET dm_err->emsg = "User choose to quit the program."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN("ERROR")
       ENDIF
       SET dim_vol_lbl = "dm2_not_set"
      ENDIF
      SET message = nowindow
    ENDWHILE
   ELSE
    SET dimd_fnd = 1
    WHILE (dimd_fnd)
      SET dimd_fnd = 0
      SET dimd_fnd = locateval(dimd_fnd,1,size(rdisk->qual,5),dim_vol_lbl,rdisk->qual[dimd_fnd].
       volume_label)
      IF (dimd_fnd)
       SET dim_vol_lbl = build("ADMIN",dpf_admin_lbl_cnt)
       SET dpf_admin_lbl_cnt = (dpf_admin_lbl_cnt+ 1)
      ENDIF
    ENDWHILE
   ENDIF
   SET width = 132
   SET message = window
   CALL clear(1,1)
   CALL text(1,1,concat("Initialize and Mount disk ",trim(dim_disk_name)," on vol_lable ",dim_vol_lbl
     ))
   CALL text(2,1,"Would you like to (C)ontinue or (Q)uit?")
   CALL accept(2,60,"P;CU","C"
    WHERE curaccept IN ("C", "Q"))
   IF (curaccept="Q")
    SET message = nowindow
    SET dm_err->emsg = "User choose to quit the program."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("ERROR")
   ENDIF
   SET message = nowindow
   SET dimd_cmd = concat("$init/head=65536/clus=16/own=[500,0]/nohigh ",trim(dim_disk_name)," ",
    dim_vol_lbl)
   IF (dm2_push_dcl(dimd_cmd)=0)
    RETURN("ERROR")
   ENDIF
   IF (dm2_check_cluster_lic(null))
    SET dimd_cmd = concat("$mount/clus/win=28/noassist ",trim(dim_disk_name)," ",dim_vol_lbl," ",
     dim_vol_lbl)
   ELSE
    IF ((dm_err->err_ind=0))
     SET dimd_cmd = concat("$mount/sys/win=28/noassist ",trim(dim_disk_name)," ",dim_vol_lbl," ",
      dim_vol_lbl)
    ELSE
     RETURN("ERROR")
    ENDIF
   ENDIF
   IF (dm2_push_dcl(dimd_cmd)=0)
    RETURN("ERROR")
   ENDIF
   RETURN(dim_vol_lbl)
 END ;Subroutine
 SUBROUTINE dm2_check_cluster_lic(null)
   SET dm_err->eproc = "Checking if vmscluster license is loaded on the system."
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE dcc_cmd = vc WITH protect, noconstant(" ")
   DECLARE dcc_str = vc WITH protect, noconstant(" ")
   DECLARE dcc_find = i2 WITH protect, noconstant(0)
   SET dcc_cmd = "$show license vmscluster"
   SET dcc_str = "%SHOW-I-NOLICMATCH, no licenses match search criteria"
   IF (dm2_push_dcl(dcc_cmd)=0)
    RETURN(0)
   ENDIF
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(dm_err->errfile)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    HEAD REPORT
     dcc_find = 0
    DETAIL
     IF (dcc_find=0)
      dcc_find = findstring(dcc_str,r.line)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error("Checking if vmscluster license is loaded on the system.") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dcc_find > 0)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_dismount_disk(ddd_vol_label)
   SET dm_err->eproc = concat("Dismount disk ",ddd_vol_label)
   CALL disp_msg("",dm_err->logfile,0)
   SET width = 132
   SET message = window
   CALL clear(1,1)
   CALL text(1,1,dm_err->eproc)
   CALL text(2,1,"Would you like to (C)ontinue or (Q)uit?")
   CALL accept(2,60,"P;CU","C"
    WHERE curaccept IN ("C", "Q"))
   IF (curaccept="Q")
    SET dm_err->emsg = "User choose to quit the program."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET message = nowindow
   DECLARE ddd_cmd = vc WITH protect, noconstant(" ")
   SET ddd_cmd = concat("dismount ",ddd_vol_label)
   IF (dm2_push_dcl(ddd_cmd)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_get_mwc_flag(dgm_disk_name)
   SET dm_err->eproc = concat("Get mirror-write consistency for disk ",trim(dgm_disk_name))
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   DECLARE dgm_cmd = vc WITH protect, noconstant(" ")
   DECLARE dgm_str = vc WITH protect, noconstant(" ")
   SET dgm_cmd = concat("lqueryvg -p /dev/",trim(dgm_disk_name)," -X")
   IF (dm2_push_dcl(dgm_cmd)=0)
    RETURN("e")
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN("e")
   ENDIF
   FREE DEFINE rtl
   FREE SET file_loc
   SET logical file_loc value(dm_err->errfile)
   DEFINE rtl "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtlt r
    HEAD REPORT
     end_pos = 0
    DETAIL
     end_pos = findstring(" ",r.line)
     IF (end_pos > 0)
      dgm_str = substring(1,(end_pos - 1),r.line)
      IF ((dm_err->debug_flag > 0))
       CALL echo(dgm_str)
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(concat("Get mirror-write consistency for disk ",trim(dgm_disk_name))) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("e")
   ENDIF
   IF (dgm_str="0")
    RETURN("y")
   ELSE
    RETURN("n")
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_aix_remove_lv(sbr_arl_db_name)
   DECLARE sbr_arl_outfile = vc WITH noconstant("dm2_not_set")
   DECLARE sbr_arl_rmlv_str = vc WITH noconstant("dm2_not_set")
   SET dm_err->eproc = "Removing raw logical volumes associated with the database."
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (get_unique_file("dm2_rmlv_cmd",".out")=0)
    RETURN(0)
   ENDIF
   SET sbr_arl_outfile = dm_err->unique_fname
   IF ((dm2_sys_misc->cur_os="AIX"))
    SET sbr_arl_rmlv_str = concat("cd /dev; ls ",char(42),cnvtlower(sbr_arl_db_name),char(42),
     " | while read a; do if [ -b $a ]; then rmlv -f $a >> ",
     sbr_arl_outfile,"; fi; done 2>&1")
   ELSE
    SET sbr_arl_rmlv_str = concat(
     "vgdisplay|grep 'VG Name'|cut -d/ -f3 |while read a; do ls /dev/$a/",char(42),cnvtlower(
      sbr_arl_db_name),char(42)," | while read z; do if [ -b $z ]; then lvremove -f $z >> ",
     sbr_arl_outfile,"; fi; done; done 2>&1")
   ENDIF
   IF (dm2_push_dcl(sbr_arl_rmlv_str)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_rename_login_default(sbr_rld_mode)
   DECLARE sbr_rld_backup = vc WITH constant("BACKUP")
   DECLARE sbr_rld_restore = vc WITH constant("RESTORE")
   DECLARE sbr_rld_bkup_name = vc WITH public, constant("login_save.ccl")
   DECLARE sbr_rld_real_name = vc WITH public, constant("login_default.ccl")
   DECLARE sbr_rld_cmd_str = vc WITH public, noconstant("dm2_not_set")
   DECLARE sbr_rld_ccludir = vc WITH public, noconstant("dm2_not_set")
   CASE (cnvtupper(sbr_rld_mode))
    OF sbr_rld_backup:
     IF ((dm2_sys_misc->cur_os="AXP"))
      IF (findfile(concat("CCLUSERDIR:",sbr_rld_real_name))=0)
       SET dm_err->eproc = "No login_default.ccl file found in CCLUSERDIR."
       RETURN(1)
      ENDIF
      SET sbr_rld_cmd_str = concat("rename CCLUSERDIR:",sbr_rld_real_name," CCLUSERDIR:",
       sbr_rld_bkup_name)
     ELSE
      IF (findfile(concat("$CCLUSERDIR/",sbr_rld_real_name))=0)
       SET dm_err->eproc = "No login_default.ccl file found in CCLUSERDIR."
       RETURN(1)
      ENDIF
      SET sbr_rld_cmd_str = concat("mv -f $CCLUSERDIR/",sbr_rld_real_name," $CCLUSERDIR/",
       sbr_rld_bkup_name)
     ENDIF
    OF sbr_rld_restore:
     IF ((dm2_sys_misc->cur_os="AXP"))
      IF (findfile(concat("CCLUSERDIR:",sbr_rld_bkup_name))=0)
       SET dm_err->eproc = "No login_save.ccl file found in CCLUSERDIR."
       RETURN(1)
      ENDIF
      SET sbr_rld_cmd_str = concat("rename CCLUSERDIR:",sbr_rld_bkup_name," CCLUSERDIR:",
       sbr_rld_real_name)
     ELSE
      IF (findfile(concat("$CCLUSERDIR/",sbr_rld_bkup_name))=0)
       SET dm_err->eproc = "No login_save.ccl file found in CCLUSERDIR."
       RETURN(1)
      ENDIF
      SET sbr_rld_cmd_str = concat("mv -f $CCLUSERDIR/",sbr_rld_bkup_name," $CCLUSERDIR/",
       sbr_rld_real_name)
     ENDIF
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "DM2_RENAME_LOGIN_DEFAULT: validating mode."
     SET dm_err->emsg = concat("Invalid mode of operation: <",sbr_rld_mode,">")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
   ENDCASE
   IF (dm2_push_dcl(sbr_rld_cmd_str)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 IF ((validate(drr_search_rep_rec->elem_cnt,- (1))=- (1))
  AND (validate(drr_search_rep_rec->elem_cnt,- (2))=- (2)))
  RECORD drr_search_rep_rec(
    1 elem_cnt = i2
    1 elems[*]
      2 search_val = vc
      2 temp_search_val = vc
      2 replace_val = vc
      2 calc_param = vc
  )
  SET drr_search_rep_rec->elem_cnt = 0
 ENDIF
 IF ((validate(drr_cmd_rec->cmd_cnt,- (1))=- (1))
  AND (validate(drr_cmd_rec->cmd_cnt,- (2))=- (2)))
  RECORD drr_cmd_rec(
    1 cmd_cnt = i4
    1 cmds[*]
      2 text = vc
    1 src_filename = vc
    1 tgt_filename = vc
    1 action_type = vc
  )
  SET drr_cmd_rec->cmd_cnt = 0
 ENDIF
 IF ((validate(disk_rec->disk_cnt,- (1))=- (1))
  AND (validate(disk_rec->disk_cnt,- (2))=- (2)))
  RECORD disk_rec(
    1 disk_cnt = i2
    1 qual[*]
      2 disk_name = vc
      2 disk_vg = vc
      2 mwc_flag = c1
  )
  SET disk_rec->disk_cnt = 0
 ENDIF
 IF ((validate(drr_delim_txt_rec->txt_elem_cnt,- (1))=- (1))
  AND (validate(drr_delim_txt_rec->txt_elem_cnt,- (2))=- (2)))
  RECORD drr_delim_txt_rec(
    1 orig_txt = vc
    1 sep_char = vc
    1 txt_elem_cnt = i2
    1 qual[*]
      2 txt_elem = vc
  )
  SET drr_delim_txt_rec->orig_txt = "not_set"
  SET drr_delim_txt_rec->sep_char = "not_set"
  SET drr_delim_txt_rec->txt_elem_cnt = 0
 ENDIF
 DECLARE drr_search_replace(null) = i2
 DECLARE drr_calc_replace_val(sbr_elem_idx=i2) = i2
 DECLARE drr_replace_calcdisk(sbr_elem_idx=i2) = i2
 DECLARE drr_replace_mwc(sbr_elem_idx=i2) = i2
 DECLARE drr_replace_calcpartition(sbr_elem_idx=i2) = i2
 DECLARE drr_get_dfile_idx(sbr_dfile_tag=vc) = i4
 DECLARE drr_get_inner_val(sbr_full_str=vc,sbr_beg_sym=vc,sbr_end_sym=vc,sbr_strip_sym_ind=i2) = vc
 DECLARE drr_load_cmds_from_file(dlcf_fname=vc) = i2
 DECLARE drr_reset_cmd_rec(null) = null
 DECLARE drr_perform_cmd_action(null) = i2
 DECLARE drr_write_cmds_to_file(null) = i2
 DECLARE drr_exec_cmd_file(null) = i2
 DECLARE drr_exec_cmd_lines(null) = i2
 DECLARE drr_parse_delim_txt(null) = i2
 DECLARE drr_reset_search_rep_rec(null) = null
 DECLARE dm2_push_compile(sbr_dpc_file=vc) = i2
 DECLARE drr_exec_update_reg(sbr_deur_updtreg_cmd=vc) = i2
 SUBROUTINE drr_search_replace(null)
   SET dm_err->eproc = "Beginning drr_search_replace."
   DECLARE cr_cnt = i4 WITH protect, noconstant(0)
   DECLARE srr_cnt = i4 WITH protect, noconstant(0)
   DECLARE dsr_calc_str_loc = i2 WITH protect, noconstant(0)
   DECLARE dsr_substr_len = i4 WITH protect, noconstant(0)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(drr_search_rep_rec)
   ENDIF
   FOR (cr_cnt = 1 TO drr_cmd_rec->cmd_cnt)
     FOR (srr_cnt = 1 TO drr_search_rep_rec->elem_cnt)
       IF (findstring("<=",drr_search_rep_rec->elems[srr_cnt].search_val,1,0) > 0)
        SET dsr_calc_str_loc = findstring(drr_search_rep_rec->elems[srr_cnt].search_val,drr_cmd_rec->
         cmds[cr_cnt].text,1,0)
        WHILE (dsr_calc_str_loc > 0)
          SET dsr_substr_len = ((textlen(drr_cmd_rec->cmds[cr_cnt].text) - dsr_calc_str_loc)+ 1)
          SET drr_search_rep_rec->elems[srr_cnt].temp_search_val = drr_get_inner_val(substring(
            dsr_calc_str_loc,dsr_substr_len,drr_cmd_rec->cmds[cr_cnt].text),"<=","=>",0)
          IF (drr_calc_replace_val(srr_cnt)=0)
           RETURN(0)
          ENDIF
          SET drr_cmd_rec->cmds[cr_cnt].text = replace(drr_cmd_rec->cmds[cr_cnt].text,
           drr_search_rep_rec->elems[srr_cnt].temp_search_val,drr_search_rep_rec->elems[srr_cnt].
           replace_val,1)
          SET dsr_calc_str_loc = findstring(drr_search_rep_rec->elems[srr_cnt].search_val,drr_cmd_rec
           ->cmds[cr_cnt].text,1,0)
        ENDWHILE
       ELSE
        SET drr_cmd_rec->cmds[cr_cnt].text = replace(drr_cmd_rec->cmds[cr_cnt].text,
         drr_search_rep_rec->elems[srr_cnt].search_val,drr_search_rep_rec->elems[srr_cnt].replace_val,
         0)
       ENDIF
     ENDFOR
   ENDFOR
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(drr_cmd_rec)
   ENDIF
 END ;Subroutine
 SUBROUTINE drr_calc_replace_val(sbr_elem_idx)
   DECLARE crv_temp_val = vc WITH protect, noconstant(" ")
   DECLARE crv_dfile_idx = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Calculating replace value."
   SET drr_search_rep_rec->elems[sbr_elem_idx].calc_param = drr_get_inner_val(drr_search_rep_rec->
    elems[sbr_elem_idx].temp_search_val,"(",")",1)
   IF (size(drr_search_rep_rec->elems[sbr_elem_idx].calc_param,1) != 5)
    SET dm_err->emsg = concat("The template contained an invalid DFILE tag <",drr_search_rep_rec->
     elems[sbr_elem_idx].calc_param,">.")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET crv_dfile_idx = drr_get_dfile_idx(drr_search_rep_rec->elems[sbr_elem_idx].calc_param)
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   CASE (drr_search_rep_rec->elems[sbr_elem_idx].search_val)
    OF "<=calcdisk(":
     SET drr_search_rep_rec->elems[sbr_elem_idx].replace_val = dm2_dfile_rec->qual[crv_dfile_idx].
     disk_name
    OF "<=calcpartition(":
     IF ((dm_err->debug_flag > 0))
      CALL echo(build("partition_data::",dm2_dfile_rec->qual[crv_dfile_idx].dfile_size_adj_mb,"::",
        dm2_create_dom->psize))
     ENDIF
     SET drr_search_rep_rec->elems[sbr_elem_idx].replace_val = format((dm2_dfile_rec->qual[
      crv_dfile_idx].dfile_size_adj_mb/ dm2_create_dom->psize),";L;I")
    OF "<=calcmwc(":
     SET drr_search_rep_rec->elems[sbr_elem_idx].replace_val = build(dm2_dfile_rec->qual[
      crv_dfile_idx].mwc_flag)
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("An unsupported calc function call ",drr_search_rep_rec->elems[
      sbr_elem_idx].temp_search_val," was found.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
   ENDCASE
   IF ((dm_err->debug_flag > 0))
    CALL echo(dm_err->asterisk_line)
    CALL echo(concat("SR_vals:",drr_search_rep_rec->elems[sbr_elem_idx].search_val,"^",
      drr_search_rep_rec->elems[sbr_elem_idx].temp_search_val,"^",
      drr_search_rep_rec->elems[sbr_elem_idx].replace_val,"^",drr_search_rep_rec->elems[sbr_elem_idx]
      .calc_param))
    CALL echo(dm_err->asterisk_line)
   ENDIF
   IF (check_error("Error detected while calculating replacement values.")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_get_dfile_idx(sbr_dfile_tag)
  DECLARE gdi_dfile_idx = i4 WITH protect, noconstant(0)
  IF ((sbr_dfile_tag=dm2_dfile_rec->cur_dfile_tag))
   RETURN(dm2_dfile_rec->cur_dfile_idx)
  ELSE
   SET gdi_dfile_idx = locateval(gdi_dfile_idx,1,dm2_dfile_rec->dfile_cnt,sbr_dfile_tag,dm2_dfile_rec
    ->qual[gdi_dfile_idx].dfile_tag)
   IF (gdi_dfile_idx=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Could not locate data file tag ",sbr_dfile_tag,
     " in memory. Verify tag ",
     "exists in the datafile template corresponding to this type of install.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm2_dfile_rec->cur_dfile_tag = sbr_dfile_tag
   SET dm2_dfile_rec->cur_dfile_idx = gdi_dfile_idx
   RETURN(gdi_dfile_idx)
  ENDIF
 END ;Subroutine
 SUBROUTINE drr_get_inner_val(sbr_full_str,sbr_beg_sym,sbr_end_sym,sbr_strip_sym_ind)
   DECLARE giv_beg_sym_len = i2 WITH protect, noconstant(0)
   DECLARE giv_end_sym_len = i2 WITH protect, noconstant(0)
   DECLARE giv_return_str = vc WITH protect, noconstant(" ")
   DECLARE giv_beg_sym_loc = i2 WITH protect, noconstant(0)
   DECLARE giv_end_sym_loc = i2 WITH protect, noconstant(0)
   SET giv_beg_sym_len = textlen(sbr_beg_sym)
   SET giv_end_sym_len = textlen(sbr_end_sym)
   SET giv_beg_sym_loc = findstring(sbr_beg_sym,sbr_full_str,1,0)
   SET giv_end_sym_loc = findstring(sbr_end_sym,sbr_full_str,1,0)
   IF (sbr_strip_sym_ind=1)
    SET giv_beg_pos = (giv_beg_sym_loc+ giv_beg_sym_len)
    SET giv_substr_len = (giv_end_sym_loc - giv_beg_pos)
   ELSE
    SET giv_beg_pos = giv_beg_sym_loc
    SET giv_substr_len = ((giv_end_sym_loc+ giv_end_sym_len) - giv_beg_pos)
   ENDIF
   SET giv_return_str = substring(giv_beg_pos,giv_substr_len,sbr_full_str)
   RETURN(giv_return_str)
 END ;Subroutine
 SUBROUTINE drr_load_cmds_from_file(dlcf_fname)
   SET dm_err->eproc = "Load each line in file into drr_cmd_rec record structure."
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE dlcf_pname = vc WITH protect, noconstant(" ")
   DECLARE dlcf_name = vc WITH protect, noconstant(" ")
   IF (cursys="AIX")
    SET dlcf_pname = concat("$cer_install/",dlcf_fname)
    SET dlcf_name = concat("cer_install:",dlcf_fname)
   ELSEIF (cursys="AXP")
    SET dlcf_pname = concat("cer_install:",dlcf_fname)
    SET dlcf_name = concat("cer_install:",dlcf_fname)
   ENDIF
   IF (dm2_findfile(dlcf_pname)=0)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ELSE
     SET dm_err->eproc = "Checking for template driver file."
     SET dm_err->emsg = concat("Template driver file ",dlcf_pname," not found.")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(dlcf_name)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    DETAIL
     drr_cmd_rec->cmd_cnt = (drr_cmd_rec->cmd_cnt+ 1), stat = alterlist(drr_cmd_rec->cmds,drr_cmd_rec
      ->cmd_cnt), drr_cmd_rec->cmds[drr_cmd_rec->cmd_cnt].text = trim(r.line)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(drr_cmd_rec)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_reset_cmd_rec(null)
   SET drr_cmd_rec->cmd_cnt = 0
   SET stat = alterlist(drr_cmd_rec->cmds,0)
   SET drr_cmd_rec->src_filename = ""
   SET drr_cmd_rec->tgt_filename = ""
   SET drr_cmd_rec->action_type = ""
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(drr_cmd_rec)
   ENDIF
 END ;Subroutine
 SUBROUTINE drr_perform_cmd_action(null)
   SET dm_err->eproc = concat("Performing command actions for ",drr_cmd_rec->src_filename,".")
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF ((drr_cmd_rec->action_type IN ("CF", "CFE", "CFO", "CFP")))
    IF (drr_write_cmds_to_file(null)=0)
     RETURN(0)
    ENDIF
    IF ((drr_cmd_rec->action_type IN ("CFE", "CFO")))
     IF (drr_exec_cmd_file(null)=0)
      RETURN(0)
     ENDIF
    ELSEIF ((drr_cmd_rec->action_type="CFP"))
     IF (dm2_push_compile(drr_cmd_rec->tgt_filename)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ELSEIF ((drr_cmd_rec->action_type="E"))
    IF (drr_exec_cmd_lines(null)=0)
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Executing template commands."
    SET dm_err->emsg = concat("Invalid action type: <",drr_cmd_rec->action_type,">.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Finished performing command actions for ",drr_cmd_rec->src_filename,
    ".")
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_write_cmds_to_file(null)
   DECLARE sbr_wcf_trim_text = vc WITH protect, noconstant(" ")
   SELECT INTO value(drr_cmd_rec->tgt_filename)
    d.seq
    FROM (dummyt d  WITH seq = drr_cmd_rec->cmd_cnt)
    DETAIL
     sbr_wcf_trim_text = trim(drr_cmd_rec->cmds[d.seq].text), col 0, sbr_wcf_trim_text
     IF ((d.seq < drr_cmd_rec->cmd_cnt))
      row + 1
     ENDIF
    WITH nocounter, maxrow = 1, format = variable,
     noformfeed
   ;end select
   IF (check_error(concat("Error writing ",drr_cmd_rec->tgt_filename,"."))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_exec_cmd_file(null)
   DECLARE dec_exec_file = vc WITH public, noconstant("NOT_SET")
   DECLARE dec_chmod_str = vc WITH public, noconstant("NOT_SET")
   IF (cursys="AIX")
    IF ((drr_cmd_rec->action_type="CFO"))
     SET dec_exec_file = concat("su - oracle -c ",trim(logical("CCLUSERDIR")),"/",drr_cmd_rec->
      tgt_filename)
    ELSE
     SET dec_exec_file = concat(trim(logical("CCLUSERDIR")),"/",drr_cmd_rec->tgt_filename)
    ENDIF
    SET dec_chmod_str = concat("chmod 777 $CCLUSERDIR/",drr_cmd_rec->tgt_filename)
   ELSE
    SET dec_chmod_str = concat("set file/prot =(s:RWED, o:RWED, g:RWED, w:RWED) CCLUSERDIR:",
     drr_cmd_rec->tgt_filename)
    SET dec_exec_file = concat("@CCLUSERDIR:",drr_cmd_rec->tgt_filename)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc = concat("drr_exec_cmd_file changing permissions for ",dec_exec_file,".")
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (dm2_push_dcl(dec_chmod_str)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc = concat("drr_exec_cmd_file now executing ",dec_exec_file,".")
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (findstring("restore",cnvtlower(drr_cmd_rec->tgt_filename)) > 0)
    SET dm_err->eproc =
    "Restoring database backup files.  This process may take as much as 30 minutes to complete."
    SET dm_err->user_action =
    "For information on monitoring the restore process, see the Installation Guide."
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (dm2_push_dcl(dec_exec_file)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_exec_cmd_lines(null)
   DECLARE sbr_ecl_idx = i4 WITH public, noconstant(0)
   DECLARE sbr_ecl_cmd_txt = vc WITH protect, noconstant("DM2_NOT_SET")
   DECLARE sbr_ecl_err_str = vc WITH protect, noconstant("DM2_NOT_SET")
   DECLARE sbr_ecl_err_str2 = vc WITH protect, noconstant("DM2_NOT_SET")
   DECLARE sbr_ecl_tmp_err_ind = i2 WITH protect, noconstant(0)
   IF (cursys="AIX")
    SET sbr_ecl_err_str = "does not exist"
   ELSEIF (cursys="AXP")
    SET sbr_ecl_err_str = "directory not found"
    SET sbr_ecl_err_str2 = "no files found"
   ENDIF
   FOR (sbr_ecl_idx = 1 TO drr_cmd_rec->cmd_cnt)
     SET sbr_ecl_tmp_err_ind = 0
     IF (findstring("update_reg",drr_cmd_rec->cmds[sbr_ecl_idx].text,1,0) > 0)
      IF (drr_exec_update_reg(drr_cmd_rec->cmds[sbr_ecl_idx].text)=0)
       RETURN(0)
      ENDIF
     ELSE
      CALL dm2_push_dcl(drr_cmd_rec->cmds[sbr_ecl_idx].text)
     ENDIF
     IF ((dm_err->err_ind=1))
      SET dm_err->err_ind = 0
      SET sbr_ecl_tmp_err_ind = 1
     ENDIF
     IF (parse_errfile(dm_err->errfile)=0)
      RETURN(0)
     ENDIF
     IF (findstring(sbr_ecl_err_str,dm_err->errtext,1,0) > 0)
      CALL echo("found the error string")
      SET dm_err->eproc = "A file or directory was not found.  This is an acceptable error."
      CALL disp_msg(" ",dm_err->logfile,0)
      RETURN(1)
     ELSEIF (findstring(sbr_ecl_err_str2,dm_err->errtext,1,0) > 0)
      SET dm_err->eproc = "A file or directory was not found.  This is an acceptable error."
      CALL disp_msg(" ",dm_err->logfile,0)
      RETURN(1)
     ELSEIF (sbr_ecl_tmp_err_ind=1)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_parse_delim_txt(null)
   SET dm_err->eproc = "Parse text to get elements seperated by delimiter."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   DECLARE dpd_end_str = i2 WITH protect, noconstant(0)
   DECLARE dpd_beg_pos = i2 WITH protect, noconstant(0)
   DECLARE dpd_end_pos = i2 WITH protect, noconstant(0)
   DECLARE dpd_final_pos = i2 WITH protect, noconstant(0)
   SET drr_delim_txt_rec->txt_elem_cnt = 0
   SET stat = alterlist(drr_delim_txt_rec->qual,0)
   SET dpd_final_pos = size(drr_delim_txt_rec->orig_txt)
   SET dpd_beg_pos = 1
   SET dpd_end_pos = findstring(drr_delim_txt_rec->sep_char,drr_delim_txt_rec->orig_txt)
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("beg_pos =",dpd_beg_pos))
    CALL echo(build("end_pos =",dpd_end_pos))
    CALL echo(build("final_pos =",dpd_final_pos))
    CALL echo(build("orig_txt =",drr_delim_txt_rec->orig_txt))
   ENDIF
   IF (dpd_end_pos=0)
    IF ((dm_err->debug_flag > 0))
     CALL echo("No delimiter found.")
    ENDIF
    RETURN(1)
   ENDIF
   WHILE (dpd_end_str != 1)
     SET drr_delim_txt_rec->txt_elem_cnt = (drr_delim_txt_rec->txt_elem_cnt+ 1)
     SET stat = alterlist(drr_delim_txt_rec->qual,drr_delim_txt_rec->txt_elem_cnt)
     IF (dpd_end_pos=dpd_final_pos)
      SET drr_delim_txt_rec->qual[drr_delim_txt_rec->txt_elem_cnt].txt_elem = substring(dpd_beg_pos,(
       (dpd_end_pos - dpd_beg_pos)+ 1),drr_delim_txt_rec->orig_txt)
      SET dpd_end_str = 1
     ELSE
      SET drr_delim_txt_rec->qual[drr_delim_txt_rec->txt_elem_cnt].txt_elem = substring(dpd_beg_pos,(
       dpd_end_pos - dpd_beg_pos),drr_delim_txt_rec->orig_txt)
      SET dpd_beg_pos = (dpd_end_pos+ 1)
      SET dpd_end_pos = findstring(drr_delim_txt_rec->sep_char,drr_delim_txt_rec->orig_txt,
       dpd_beg_pos)
      IF (dpd_end_pos=0)
       SET dpd_end_pos = dpd_final_pos
      ENDIF
     ENDIF
   ENDWHILE
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(drr_delim_txt_rec)
   ENDIF
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_reset_search_rep_rec(null)
   SET drr_search_rep_rec->elem_cnt = 0
   SET dm_err->eproc = "Resetting drr_search_rep_rec."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET stat = alterlist(drr_search_rep_rec->elems,0)
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(drr_search_rep_rec)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_push_compile(sbr_dpc_file)
   DECLARE sbr_dpc_full_path = vc WITH public, noconstant("dm2_not_set")
   IF (cursys="AIX")
    SET sbr_dpc_full_path = build(logical("CCLUSERDIR"),"/",sbr_dpc_file)
   ELSE
    SET sbr_dpc_full_path = build("CCLUSERDIR:",sbr_dpc_file)
   ENDIF
   IF (dm2_findfile(sbr_dpc_full_path)=0)
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ELSE
     SET dm_err->eproc = concat("Checking for ",sbr_dpc_full_path,".")
     SET dm_err->emsg = concat("CCL file ",sbr_dpc_full_path," not found.")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo("*")
    CALL echo(concat("dm2_push_compile compiling: ",sbr_dpc_full_path))
    CALL echo("*")
   ENDIF
   CALL compile(sbr_dpc_full_path)
   IF (check_error(concat("Error executing ",sbr_dpc_full_path,".")) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_exec_update_reg(sbr_deur_updtreg_cmd)
   DECLARE sbr_deur_lreg_cmd = vc WITH public, noconstant("not_set")
   DECLARE sbr_deur_dcl_stat = i4 WITH public, noconstant(0)
   SET dm_err->eproc = "Importing registry updates with update_reg."
   SET dm_err->errfile = dm_err->unique_fname
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (cursys="AIX")
    SET sbr_deur_lreg_cmd = concat("lreg -getp \\dbinstance\\",dm2_create_dom->dname,"1 database",
     " > ",dm2_install_schema->ccluserdir,
     dm_err->errfile," 2>&1")
   ELSE
    SET sbr_deur_lreg_cmd = concat("pipe lreg -getp \dbinstance\",dm2_create_dom->dname,
     "1 database ;show symbol lreg_result"," > ccluserdir:",dm_err->errfile)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo("*")
    CALL echo(concat("call dcl executing: ",sbr_deur_updtreg_cmd))
    CALL echo("*")
   ENDIF
   CALL dcl(sbr_deur_updtreg_cmd,size(sbr_deur_updtreg_cmd),sbr_deur_dcl_stat)
   CALL dcl(sbr_deur_lreg_cmd,size(sbr_deur_lreg_cmd),sbr_deur_dcl_stat)
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   IF (findstring(cnvtlower(dm2_create_dom->dname),trim(cnvtlower(dm_err->errtext)))=0)
    SET dm_err->emsg = "Registry update failed.  Database instance not defined."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_add_sr_data(sbr_search_val_str,sbr_replace_val_str)
   SET drr_search_rep_rec->elem_cnt = (drr_search_rep_rec->elem_cnt+ 1)
   SET stat = alterlist(drr_search_rep_rec->elems,drr_search_rep_rec->elem_cnt)
   SET drr_search_rep_rec->elems[drr_search_rep_rec->elem_cnt].search_val = sbr_search_val_str
   SET drr_search_rep_rec->elems[drr_search_rep_rec->elem_cnt].replace_val = sbr_replace_val_str
 END ;Subroutine
 DECLARE dmr_get_node_name(null) = i2
 DECLARE dmr_get_queue_contents(batch_queue=vc) = i2
 DECLARE dmr_check_directory(directory=vc) = i2
 DECLARE dmr_get_unique_file_name(directory=vc,file_prefix=vc,file_suffix=vc) = i2
 DECLARE dmr_fill_email_list(null) = i2
 DECLARE dmr_send_email(subject=vc,address_list=vc,file_name=vc) = i2
 DECLARE dmr_get_user_list(null) = i2
 DECLARE dmr_verify_v500_user(exists_ind=i2(ref)) = i2
 DECLARE dmr_initialize_mig_data(null) = null
 DECLARE dmr_prompt_connect_data(dpcd_db_type=vc,dpcd_db_user=vc,dpcd_cnct_opt=vc) = i2
 DECLARE dmr_prompt_retrieve_mig_data(dprmd_adm_db_ind=i2,dprmd_src_db_ind=i2,dprmd_tgt_db_ind=i2,
  dprmd_sys_db_ind=i2) = i2
 DECLARE dmr_chk_mig_ora_version(dcmov_error_flag=i2(ref)) = i2
 DECLARE dmr_issue_summary_screen(diss_src_db_ind=i2,diss_tgt_db_ind=i2,diss_msg=vc) = i2
 DECLARE dmr_load_mig_data(null) = i2
 DECLARE dmr_store_off_mig_data(null) = i2
 DECLARE dmr_get_gg_dir(null) = i2
 DECLARE dmr_set_gg_files(dsgf_report_capture=i2,dsgf_report_delivery=i2) = null
 DECLARE dmr_directory_prompt(mode) = i2
 DECLARE dmr_check_batch_queue(dcbq_queue_name=vc,dcbq_queue_fnd_ret=i2(ref)) = i2
 DECLARE dmr_setup_batch_queue(dsbq_queue_name=vc) = i2
 DECLARE dmr_validate_src_and_tgt(dvst_src_ind=i2,dvst_tgt_ind=i2) = i2
 DECLARE dmr_stop_job(job_type=vc,job_mode=i2) = i2
 DECLARE dmr_get_storage_type(dgst_storage_ret=vc(ref)) = i2
 DECLARE dmr_load_managed_tables(dlmt_mng_ret=vc(ref)) = i2
 DECLARE dmr_mig_setup_gg_dir(null) = i2
 DECLARE dmr_load_di_filter(null) = i2
 DECLARE dmr_get_di_filter(null) = i2
 DECLARE dmr_create_di_macro(dcdm_in_dir=vc,dcdm_gg_version=i2) = i2
 DECLARE dmr_get_db_info(dgd_db_name=vc(ref),dgd_created_date=f8(ref)) = i2
 IF (validate(dmr_batch_queue,"X")="X"
  AND validate(dmr_batch_queue,"Y")="Y")
  DECLARE dmr_batch_queue = vc WITH public, constant(cnvtlower(build("migration$",logical(
      "environment"))))
 ENDIF
 FREE RECORD dmr_node
 RECORD dmr_node(
   1 cnt = i4
   1 qual[*]
     2 node_name = vc
     2 instance_number = f8
     2 instance_name = vc
 )
 IF ((validate(dmr_queue->cnt,- (1))=- (1))
  AND validate(dmr_queue->cnt,1)=1)
  FREE RECORD dmr_queue
  RECORD dmr_queue(
    1 cnt = i4
    1 qual[*]
      2 entry = i4
      2 jobname = vc
      2 username = vc
      2 status = vc
  )
 ENDIF
 IF ((validate(dmr_emails->cnt,- (1))=- (1))
  AND validate(dmr_emails->cnt,1)=1)
  FREE RECORD dmr_emails
  RECORD dmr_emails(
    1 change_ind = i2
    1 email_list = vc
    1 cnt = i4
    1 qual[*]
      2 email_address = vc
  )
 ENDIF
 IF ((validate(dmr_user_list->cnt,- (1))=- (1))
  AND validate(dmr_user_list->cnt,1)=1)
  FREE RECORD dmr_user_list
  RECORD dmr_user_list(
    1 change_ind = i2
    1 cnt = i4
    1 qual[*]
      2 user = vc
  )
 ENDIF
 IF ((validate(dmr_expimp->prompt_done,- (1))=- (1))
  AND validate(dmr_expimp->prompt_done,99)=99)
  FREE RECORD dmr_expimp
  RECORD dmr_expimp(
    1 prompt_done = i2
    1 mode = vc
    1 process = vc
    1 step = vc
    1 step_ready = i2
    1 src_ora_home = vc
    1 src_nls_lang = vc
    1 src_ksh_loc = vc
    1 tgt_ora_home = vc
    1 tgt_nls_lang = vc
    1 tgt_file_loc = vc
    1 ora_username = vc
    1 user_prefix = vc
    1 file_prefix = vc
    1 export_prefix = vc
    1 sqlplus_prefix = vc
    1 import_prefix = vc
    1 nohup_prefix = vc
    1 exp_utility_location = vc
    1 imp_utility_location = vc
    1 read_only_mode = i2
    1 data_chunk_size = f8
    1 diff_ora_version = i2
    1 stg_v500_p_word = vc
    1 stg_v500_cnct_str = vc
    1 stg_db_name = vc
    1 stg_node_name = vc
    1 stg_created_date = f8
    1 expimp_user_cnt = i2
    1 users[*]
      2 expimp_user = vc
  )
  SET dmr_expimp->data_chunk_size = 1000000.0
 ENDIF
 IF (validate(dmr_mig_data->dm2_mig_log,"X")="X"
  AND validate(dmr_mig_data->dm2_mig_log,"Z")="Z")
  FREE RECORD dmr_mig_data
  RECORD dmr_mig_data(
    1 dm2_mig_log = vc
    1 adm_cdba_pwd = vc
    1 adm_cdba_cnct_str = vc
    1 cur_db_type = vc
    1 tgt_v500_pwd = vc
    1 tgt_v500_cnct_str = vc
    1 tgt_sys_pwd = vc
    1 tgt_sys_cnct_str = vc
    1 tgt_storage_type = vc
    1 src_storage_type = vc
    1 src_v500_pwd = vc
    1 src_v500_cnct_str = vc
    1 src_sys_pwd = vc
    1 src_sys_cnct_str = vc
    1 src_db_name = vc
    1 src_created_date = f8
    1 src_db_os = vc
    1 src_ora_version = vc
    1 src_ora_level1 = i2
    1 src_ora_level2 = i2
    1 src_ora_level3 = i2
    1 src_ora_level4 = i2
    1 src_node_cnt = i4
    1 src_nodes[*]
      2 node_name = vc
      2 instance_number = f8
      2 instance_name = vc
    1 tgt_db_name = vc
    1 tgt_created_date = f8
    1 tgt_db_os = vc
    1 tgt_ora_version = vc
    1 tgt_ora_level1 = i2
    1 tgt_ora_level2 = i2
    1 tgt_ora_level3 = i2
    1 tgt_ora_level4 = i2
    1 tgt_node_cnt = i4
    1 tgt_nodes[*]
      2 node_name = vc
      2 instance_number = f8
      2 instance_name = vc
    1 report_all = i2
    1 report_capture = i2
    1 report_delivery = i2
    1 cap_dir = vc
    1 cap_mgr_rpt = vc
    1 cap_rpt = vc
    1 cap_err_rpt = vc
    1 del_dir = vc
    1 del_mgr_rpt = vc
    1 del_rpt = vc
    1 del_err_rpt = vc
    1 gg_capture_dir = vc
    1 gg_delivery_dir = vc
  )
  CALL dmr_initialize_mig_data(null)
 ENDIF
 IF ((validate(dmr_di_filter->cnt,- (1))=- (1))
  AND validate(dmr_di_filter->cnt,1)=1)
  RECORD dmr_di_filter(
    1 cnt = i4
    1 qual[*]
      2 name = vc
  )
 ENDIF
 SUBROUTINE dmr_initialize_mig_data(null)
   IF (cursys="AXP")
    SET dmr_mig_data->dm2_mig_log = logical("cer_install")
   ELSE
    SET dmr_mig_data->dm2_mig_log = concat(trim(logical("cer_install")),"/")
   ENDIF
   SET dmr_mig_data->adm_cdba_pwd = "DM2NOTSET"
   SET dmr_mig_data->cur_db_type = "DM2NOTSET"
   SET dmr_mig_data->adm_cdba_cnct_str = "DM2NOTSET"
   SET dmr_mig_data->tgt_v500_pwd = "DM2NOTSET"
   SET dmr_mig_data->tgt_v500_cnct_str = "DM2NOTSET"
   SET dmr_mig_data->src_v500_pwd = "DM2NOTSET"
   SET dmr_mig_data->src_v500_cnct_str = "DM2NOTSET"
   SET dmr_mig_data->src_sys_pwd = "DM2NOTSET"
   SET dmr_mig_data->src_sys_cnct_str = "DM2NOTSET"
   SET dmr_mig_data->src_db_name = "DM2NOTSET"
   SET dmr_mig_data->src_created_date = 0.0
   SET dmr_mig_data->src_db_os = "DM2NOTSET"
   SET dmr_mig_data->src_ora_version = "DM2NOTSET"
   SET stat = alterlist(dmr_mig_data->src_nodes,0)
   SET dmr_mig_data->src_node_cnt = 0
   SET dmr_mig_data->tgt_db_name = "DM2NOTSET"
   SET dmr_mig_data->tgt_created_date = 0.0
   SET dmr_mig_data->tgt_db_os = "DM2NOTSET"
   SET dmr_mig_data->tgt_ora_version = "DM2NOTSET"
   SET stat = alterlist(dmr_mig_data->tgt_nodes,0)
   SET dmr_mig_data->tgt_node_cnt = 0
   SET dmr_mig_data->report_all = 0
   SET dmr_mig_data->report_capture = 0
   SET dmr_mig_data->report_delivery = 0
   SET dmr_mig_data->cap_dir = "DM2NOTSET"
   SET dmr_mig_data->cap_mgr_rpt = "DM2NOTSET"
   SET dmr_mig_data->cap_rpt = "DM2NOTSET"
   SET dmr_mig_data->cap_err_rpt = "DM2NOTSET"
   SET dmr_mig_data->del_dir = "DM2NOTSET"
   SET dmr_mig_data->del_mgr_rpt = "DM2NOTSET"
   SET dmr_mig_data->del_rpt = "DM2NOTSET"
   SET dmr_mig_data->del_err_rpt = "DM2NOTSET"
 END ;Subroutine
 SUBROUTINE dmr_get_db_info(dgdi_db_name,dgdi_created_date)
   SET dm_err->eproc = "Get databse name and created date"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM v$database v
    DETAIL
     dgdi_db_name = trim(cnvtupper(currdbname)), dgdi_created_date = v.created
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_load_mig_data(null)
   DECLARE dlmd_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlmd_file = vc WITH protect, noconstant(concat(dmr_mig_data->dm2_mig_log,
     "dm2_mig_config.txt"))
   FREE RECORD dlmd_cmd
   RECORD dlmd_cmd(
     1 qual[*]
       2 rs_item = vc
       2 rs_item_value = vc
   )
   IF (dm2_findfile(dlmd_file)=0)
    RETURN(1)
   ENDIF
   SET dm_err->eproc = concat("Attempting to access ",dlmd_file)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET logical dlmd_config_file dlmd_file
   FREE DEFINE rtl
   DEFINE rtl "dlmd_config_file"
   SELECT INTO "nl:"
    t.line
    FROM rtlt t
    WHERE t.line > " "
    DETAIL
     dlmd_cnt = (dlmd_cnt+ 1), stat = alterlist(dlmd_cmd->qual,dlmd_cnt), dlmd_cmd->qual[dlmd_cnt].
     rs_item = substring(1,(findstring(",",t.line,1,0) - 1),t.line),
     dlmd_cmd->qual[dlmd_cnt].rs_item_value = substring((findstring(",",t.line,1,0)+ 1),(size(t.line)
       - findstring(",",t.line,1,0)),t.line)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dlmd_cmd)
   ENDIF
   SET dlmd_cnt = 0
   FOR (dlmd_cnt = 1 TO size(dlmd_cmd->qual,5))
     IF (findstring("_pwd",dlmd_cmd->qual[dlmd_cnt].rs_item,1,1)=0)
      CALL parser(concat("set dmr_mig_data->",dlmd_cmd->qual[dlmd_cnt].rs_item," = ",dlmd_cmd->qual[
        dlmd_cnt].rs_item_value," go"),1)
     ELSE
      CALL parser(concat("set dmr_mig_data->",dlmd_cmd->qual[dlmd_cnt].rs_item," = ",dlmd_cmd->qual[
        dlmd_cnt].rs_item_value," go"),1)
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_store_off_mig_data(null)
   DECLARE dsomd_file = vc WITH protect, noconstant(concat(dmr_mig_data->dm2_mig_log,
     "dm2_mig_config.txt"))
   SET dm_err->eproc = concat("Checking if ",dsomd_file," exists.")
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (dm2_findfile(dsomd_file) > 0)
    SET dm_err->eproc = concat("Attempting to remove ",dsomd_file)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    IF (remove(dsomd_file)=0)
     SET dm_err->emsg = concat("Unable to remove ",dsomd_file)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   SET logical dsomd_config_file dsomd_file
   SET dm_err->eproc = concat("Creating ",dsomd_file)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO dsomd_config_file
    DETAIL
     IF ((dmr_mig_data->adm_cdba_pwd != "DM2NOTSET"))
      CALL print(concat('adm_cdba_pwd,"',dmr_mig_data->adm_cdba_pwd,'"')), row + 1
     ENDIF
     IF ((dmr_mig_data->adm_cdba_cnct_str != "DM2NOTSET"))
      CALL print(concat('adm_cdba_cnct_str,"',dmr_mig_data->adm_cdba_cnct_str,'"')), row + 1
     ENDIF
     IF ((dmr_mig_data->src_v500_pwd != "DM2NOTSET"))
      CALL print(concat('src_v500_pwd,"',dmr_mig_data->src_v500_pwd,'"')), row + 1
     ENDIF
     IF ((dmr_mig_data->src_v500_cnct_str != "DM2NOTSET"))
      CALL print(concat('src_v500_cnct_str,"',dmr_mig_data->src_v500_cnct_str,'"')), row + 1
     ENDIF
     IF ((dmr_mig_data->src_sys_pwd != "DM2NOTSET"))
      CALL print(concat('src_sys_pwd,"',dmr_mig_data->src_sys_pwd,'"')), row + 1
     ENDIF
     IF ((dmr_mig_data->src_sys_cnct_str != "DM2NOTSET"))
      CALL print(concat('src_sys_cnct_str,"',dmr_mig_data->src_sys_cnct_str,'"')), row + 1
     ENDIF
     IF ((dmr_mig_data->tgt_v500_pwd != "DM2NOTSET"))
      CALL print(concat('tgt_v500_pwd,"',dmr_mig_data->tgt_v500_pwd,'"')), row + 1
     ENDIF
     IF ((dmr_mig_data->tgt_v500_cnct_str != "DM2NOTSET"))
      CALL print(concat('tgt_v500_cnct_str,"',dmr_mig_data->tgt_v500_cnct_str,'"')), row + 1
     ENDIF
    WITH nocounter, maxcol = 500, format = variable,
     formfeed = none, maxrow = 1
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_chk_mig_ora_version(dcmov_error_flag)
   SET dcmov_error_flag = 0
   IF ((dmr_mig_data->tgt_ora_level1 < dmr_mig_data->src_ora_level1))
    SET dcmov_error_flag = 1
    RETURN(1)
   ELSEIF ((dmr_mig_data->tgt_ora_level1 > dmr_mig_data->src_ora_level1))
    RETURN(1)
   ELSE
    IF ((dmr_mig_data->tgt_ora_level2 < dmr_mig_data->src_ora_level2))
     SET dcmov_error_flag = 1
     RETURN(1)
    ELSEIF ((dmr_mig_data->tgt_ora_level2 > dmr_mig_data->src_ora_level2))
     RETURN(1)
    ELSE
     IF ((dmr_mig_data->tgt_ora_level3 < dmr_mig_data->src_ora_level3))
      SET dcmov_error_flag = 1
      RETURN(1)
     ELSEIF ((dmr_mig_data->tgt_ora_level3 > dmr_mig_data->src_ora_level3))
      RETURN(1)
     ELSE
      IF ((dmr_mig_data->tgt_ora_level4 < dmr_mig_data->src_ora_level4))
       SET dcmov_error_flag = 1
       RETURN(1)
      ELSEIF ((dmr_mig_data->tgt_ora_level4 > dmr_mig_data->src_ora_level4))
       RETURN(1)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   SET dcmov_error_flag = 0
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_prompt_connect_data(dpcd_db_type,dpcd_db_user,dpcd_cnct_opt)
   DECLARE dpcd_db_pwd = vc WITH protect, noconstant("")
   DECLARE dpcd_cnct_str = vc WITH protect, noconstant("")
   IF ( NOT (dpcd_db_type IN ("ADMIN", "TARGET", "SOURCE")))
    SET dm_err->emsg = concat("Database Type ",dpcd_db_type,
     " is invalid. Type must be ADMIN, TARGET or SOURCE")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((dpcd_db_type="ADMIN"
    AND dpcd_db_user != "CDBA") OR (((dpcd_db_type="TARGET"
    AND  NOT (dpcd_db_user IN ("V500", "SYS"))) OR (dpcd_db_type="SOURCE"
    AND  NOT (dpcd_db_user IN ("V500", "SYS")))) )) )
    SET dm_err->emsg = concat("Database Username ",dpcd_db_user,
     " is invalid. User must be CDBA, V500 or SYS")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ( NOT (dpcd_cnct_opt IN ("CO", "PC")))
    SET dm_err->emsg = concat("Connect option ",dpcd_cnct_opt,
     " is invalid. Connect option must be PC or CO.")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dpcd_cnct_opt="CO")
    CASE (dpcd_db_type)
     OF "TARGET":
      IF (dpcd_db_user="SYS")
       SET dpcd_db_pwd = dmr_mig_data->tgt_sys_pwd
       SET dpcd_cnct_str = dmr_mig_data->tgt_sys_cnct_str
      ELSE
       SET dpcd_db_pwd = dmr_mig_data->tgt_v500_pwd
       SET dpcd_cnct_str = dmr_mig_data->tgt_v500_cnct_str
      ENDIF
     OF "SOURCE":
      IF (dpcd_db_user="SYS")
       SET dpcd_db_pwd = dmr_mig_data->src_sys_pwd
       SET dpcd_cnct_str = dmr_mig_data->src_sys_cnct_str
      ELSE
       SET dpcd_db_pwd = dmr_mig_data->src_v500_pwd
       SET dpcd_cnct_str = dmr_mig_data->src_v500_cnct_str
      ENDIF
     OF "ADMIN":
      SET dpcd_db_pwd = dmr_mig_data->adm_cdba_pwd
      SET dpcd_cnct_str = dmr_mig_data->adm_cdba_cnct_str
    ENDCASE
    IF (dpcd_db_pwd IN ("", "DM2NOTSET"))
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
     SET dm_err->emsg = "Password must be supplied with CO option"
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dpcd_cnct_str IN ("", "DM2NOTSET"))
     IF ((dm_err->err_ind=1))
      RETURN(0)
     ENDIF
     SET dm_err->emsg = "Connect string must be supplied with CO option"
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(dpcd_db_type)
    CALL echo(dpcd_db_user)
   ENDIF
   SET dm2_force_connect_string = 1
   SET dm2_install_schema->dbase_name = dpcd_db_type
   SET dm2_install_schema->u_name = dpcd_db_user
   SET dm2_install_schema->p_word = dpcd_db_pwd
   SET dm2_install_schema->connect_str = dpcd_cnct_str
   EXECUTE dm2_connect_to_dbase dpcd_cnct_opt
   SET dm2_force_connect_string = 0
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET dmr_mig_data->cur_db_type = dpcd_db_type
   IF (dpcd_cnct_opt="PC")
    IF (dpcd_db_type="ADMIN")
     SET dmr_mig_data->adm_cdba_pwd = dm2_install_schema->p_word
     SET dmr_mig_data->adm_cdba_cnct_str = dm2_install_schema->connect_str
     SET dm2_install_schema->cdba_p_word = dm2_install_schema->p_word
     SET dm2_install_schema->cdba_connect_str = dm2_install_schema->connect_str
    ELSEIF (dpcd_db_type="SOURCE")
     IF (dpcd_db_user="V500")
      SET dmr_mig_data->src_v500_pwd = dm2_install_schema->p_word
      SET dmr_mig_data->src_v500_cnct_str = dm2_install_schema->connect_str
      SET dm2_install_schema->src_v500_p_word = dm2_install_schema->p_word
      SET dm2_install_schema->src_v500_connect_str = dm2_install_schema->connect_str
     ELSE
      SET dmr_mig_data->src_sys_pwd = dm2_install_schema->p_word
      SET dmr_mig_data->src_sys_cnct_str = dm2_install_schema->connect_str
     ENDIF
    ELSEIF (dpcd_db_type="TARGET")
     IF (dpcd_db_user="V500")
      SET dmr_mig_data->tgt_v500_pwd = dm2_install_schema->p_word
      SET dmr_mig_data->tgt_v500_cnct_str = dm2_install_schema->connect_str
      SET dm2_install_schema->v500_p_word = dm2_install_schema->p_word
      SET dm2_install_schema->v500_connect_str = dm2_install_schema->connect_str
     ELSE
      SET dmr_mig_data->tgt_sys_pwd = dm2_install_schema->p_word
      SET dmr_mig_data->tgt_sys_cnct_str = dm2_install_schema->connect_str
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_prompt_retrieve_mig_data(dprmd_adm_db_ind,dprmd_src_db_ind,dprmd_tgt_db_ind,
  dprmd_sys_db_ind)
   DECLARE dprmd_db = vc WITH protect, noconstant("")
   DECLARE dprmd_confirm = i2 WITH protect, noconstant(0)
   DECLARE dprmd_cnt = i4 WITH protect, noconstant(0)
   DECLARE dprmd_error_ret = i2 WITH protect, noconstant(0)
   DECLARE dprmd_storage_type = vc WITH protect, noconstant("")
   IF ((( NOT (dprmd_adm_db_ind IN (0, 1))) OR ((( NOT (dprmd_src_db_ind IN (0, 1))) OR ((( NOT (
   dprmd_tgt_db_ind IN (0, 1))) OR ( NOT (dprmd_sys_db_ind IN (0, 1)))) )) )) )
    SET dm_err->emsg =
    "Invalid parameter value. Please verify that correct values are being used for available parameters."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dmr_load_mig_data(null)=0)
    RETURN(0)
   ENDIF
   IF (dprmd_adm_db_ind=1)
    IF ((((dmr_mig_data->adm_cdba_pwd="DM2NOTSET")) OR ((dmr_mig_data->adm_cdba_cnct_str="DM2NOTSET")
    )) )
     IF (dmr_prompt_connect_data("ADMIN","CDBA","PC")=0)
      RETURN(0)
     ENDIF
     SET dprmd_db = "ADMIN"
    ENDIF
   ENDIF
   IF (dprmd_src_db_ind=1)
    IF ((((dmr_mig_data->src_v500_pwd="DM2NOTSET")) OR ((dmr_mig_data->src_v500_cnct_str="DM2NOTSET")
    )) )
     IF (dmr_prompt_connect_data("SOURCE","V500","PC")=0)
      RETURN(0)
     ENDIF
     SET dprmd_db = "SOURCE"
     SET dprmd_confirm = 1
    ENDIF
    IF ((((dmr_mig_data->src_db_name="DM2NOTSET")) OR ((((dmr_mig_data->src_created_date=0.0)) OR (((
    (dmr_mig_data->src_db_os="DM2NOTSET")) OR ((((dmr_mig_data->src_ora_version="DM2NOTSET")) OR ((
    dmr_mig_data->src_node_cnt=0))) )) )) )) )
     IF (dprmd_db != "SOURCE")
      IF (dmr_prompt_connect_data("SOURCE","V500","CO")=0)
       RETURN(0)
      ENDIF
      SET dprmd_db = "SOURCE"
     ENDIF
     IF (dmr_get_db_info(dmr_mig_data->src_db_name,dmr_mig_data->src_created_date)=0)
      RETURN(0)
     ENDIF
     SET dmr_mig_data->src_db_os = dm2_sys_misc->cur_db_os
     IF (dm2_get_rdbms_version(null)=0)
      RETURN(0)
     ENDIF
     SET dmr_mig_data->src_ora_version = dm2_rdbms_version->version
     SET dmr_mig_data->src_ora_level1 = dm2_rdbms_version->level1
     SET dmr_mig_data->src_ora_level2 = dm2_rdbms_version->level2
     SET dmr_mig_data->src_ora_level3 = dm2_rdbms_version->level3
     SET dmr_mig_data->src_ora_level4 = dm2_rdbms_version->level4
     IF (dmr_get_node_name(null)=0)
      RETURN(0)
     ENDIF
     SET dmr_mig_data->src_node_cnt = dmr_node->cnt
     SET stat = alterlist(dmr_mig_data->src_nodes,dmr_node->cnt)
     FOR (dprmd_cnt = 1 TO dmr_node->cnt)
       SET dmr_mig_data->src_nodes[dprmd_cnt].node_name = cnvtlower(dmr_node->qual[dprmd_cnt].
        node_name)
       SET dmr_mig_data->src_nodes[dprmd_cnt].instance_number = dmr_node->qual[dprmd_cnt].
       instance_number
       SET dmr_mig_data->src_nodes[dprmd_cnt].instance_name = cnvtlower(dmr_node->qual[dprmd_cnt].
        instance_name)
     ENDFOR
     SET dprmd_storage_type = ""
     IF (dmr_get_storage_type(dprmd_storage_type)=0)
      RETURN(0)
     ENDIF
     SET dmr_mig_data->src_storage_type = dprmd_storage_type
    ENDIF
    IF ((((dmr_mig_data->src_sys_pwd="DM2NOTSET")) OR ((dmr_mig_data->src_sys_cnct_str="DM2NOTSET")
    ))
     AND dprmd_sys_db_ind=1)
     IF (dmr_prompt_connect_data("SOURCE","SYS","PC")=0)
      RETURN(0)
     ENDIF
     SET dprmd_db = "SOURCE"
    ENDIF
   ENDIF
   IF (dprmd_tgt_db_ind=1)
    IF ((((dmr_mig_data->tgt_v500_pwd="DM2NOTSET")) OR ((dmr_mig_data->tgt_v500_cnct_str="DM2NOTSET")
    )) )
     IF (dmr_prompt_connect_data("TARGET","V500","PC")=0)
      RETURN(0)
     ENDIF
     SET dprmd_db = "TARGET"
     SET dprmd_confirm = 1
    ENDIF
    IF ((((dmr_mig_data->tgt_db_name="DM2NOTSET")) OR ((((dmr_mig_data->tgt_created_date=0.0)) OR (((
    (dmr_mig_data->tgt_db_os="DM2NOTSET")) OR ((((dmr_mig_data->tgt_ora_version="DM2NOTSET")) OR ((
    dmr_mig_data->tgt_node_cnt=0))) )) )) )) )
     IF (dprmd_db != "TARGET")
      IF (dmr_prompt_connect_data("TARGET","V500","CO")=0)
       RETURN(0)
      ENDIF
      SET dprmd_db = "TARGET"
     ENDIF
     IF (dmr_get_db_info(dmr_mig_data->tgt_db_name,dmr_mig_data->tgt_created_date)=0)
      RETURN(0)
     ENDIF
     SET dmr_mig_data->tgt_db_os = dm2_sys_misc->cur_db_os
     IF (dm2_get_rdbms_version(null)=0)
      RETURN(0)
     ENDIF
     SET dmr_mig_data->tgt_ora_version = dm2_rdbms_version->version
     SET dmr_mig_data->tgt_ora_level1 = dm2_rdbms_version->level1
     SET dmr_mig_data->tgt_ora_level2 = dm2_rdbms_version->level2
     SET dmr_mig_data->tgt_ora_level3 = dm2_rdbms_version->level3
     SET dmr_mig_data->tgt_ora_level4 = dm2_rdbms_version->level4
     IF (dmr_get_node_name(null)=0)
      RETURN(0)
     ENDIF
     SET dmr_mig_data->tgt_node_cnt = dmr_node->cnt
     SET stat = alterlist(dmr_mig_data->tgt_nodes,dmr_node->cnt)
     FOR (dprmd_cnt = 1 TO dmr_node->cnt)
       SET dmr_mig_data->tgt_nodes[dprmd_cnt].node_name = cnvtlower(dmr_node->qual[dprmd_cnt].
        node_name)
       SET dmr_mig_data->tgt_nodes[dprmd_cnt].instance_number = dmr_node->qual[dprmd_cnt].
       instance_number
       SET dmr_mig_data->tgt_nodes[dprmd_cnt].instance_name = cnvtlower(dmr_node->qual[dprmd_cnt].
        instance_name)
     ENDFOR
     SET dprmd_storage_type = ""
     IF (dmr_get_storage_type(dprmd_storage_type)=0)
      RETURN(0)
     ENDIF
     SET dmr_mig_data->tgt_storage_type = dprmd_storage_type
    ENDIF
   ENDIF
   IF (dmr_chk_mig_ora_version(dprmd_error_ret)=0)
    RETURN(0)
   ENDIF
   IF (dprmd_src_db_ind=1)
    IF ((dmr_mig_data->src_ora_level1 < 9))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Check SOURCE Oracle version."
     SET dm_err->emsg = concat("SOURCE database Oracle version (",dmr_mig_data->src_ora_version,
      ") has to be 9 and higher.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dprmd_tgt_db_ind=1)
    IF ((dmr_mig_data->tgt_ora_level1 < 9))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Check Target Oracle version."
     SET dm_err->emsg = concat("Target database Oracle version (",dmr_mig_data->tgt_ora_version,
      ") has to be 9 and higher.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dmr_mig_data->tgt_db_os="AXP"))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Check Target domain OS."
     SET dm_err->emsg = "Target database can not be VMS."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dprmd_src_db_ind=1
    AND dprmd_tgt_db_ind=1
    AND validate(dm2_skip_create_date_check,0) != 1)
    IF ((dmr_mig_data->tgt_created_date < dmr_mig_data->src_created_date))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Compare Source created date with Target created date."
     SET dm_err->emsg =
     "Target database created date may not be lower than Source database created date."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dprmd_error_ret=1)
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Compare Source oracle version with Target oracle version."
     SET dm_err->emsg = concat("Target oracle version ",dmr_mig_data->tgt_ora_version,
      " can not be lower than Source oracle version ",dmr_mig_data->src_ora_version)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dmr_mig_data)
   ENDIF
   IF (dprmd_confirm=1)
    IF (dmr_issue_summary_screen(dprmd_src_db_ind,dprmd_tgt_db_ind,"")=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_issue_summary_screen(diss_src_db_ind,diss_tgt_db_ind,diss_msg)
   DECLARE diss_node_list = vc WITH protect, noconstant("")
   DECLARE diss_cnt = i4 WITH protect, noconstant(0)
   DECLARE diss_row_cnt = i4 WITH protect, noconstant(0)
   DECLARE diss_col_num = i4 WITH protect, noconstant(0)
   DECLARE diss_length = i4 WITH protect, noconstant(0)
   DECLARE diss_rows_max = i4 WITH protect, constant(21)
   DECLARE diss_col_max = i4 WITH protect, constant(40)
   SET diss_col_num = 2
   SET message = window
   CALL clear(1,1)
   CALL text(1,1,"DATABASE MIGRATION SUMMARY SCREEN")
   IF (diss_src_db_ind=1)
    CALL text(3,diss_col_num,"SOURCE")
    CALL text(4,diss_col_num,concat("Database Name : ",trim(dmr_mig_data->src_db_name)))
    CALL text(5,diss_col_num,concat("Database Create Date : ",format(dmr_mig_data->src_created_date,
       "mm-dd-yyyy;;d")))
    CALL text(6,diss_col_num,concat("Database Operating System : ",trim(dmr_mig_data->src_db_os)))
    CALL text(7,diss_col_num,concat("Database Oracle Version : ",trim(dmr_mig_data->src_ora_version))
     )
    CALL text(8,diss_col_num,"Database Nodes : ")
    SET diss_node_list = ""
    FOR (diss_cnt = 1 TO dmr_mig_data->src_node_cnt)
      IF ((dmr_mig_data->src_node_cnt > 1)
       AND diss_cnt != 1)
       SET diss_node_list = concat(diss_node_list,", ",dmr_mig_data->src_nodes[diss_cnt].node_name)
      ELSE
       SET diss_node_list = dmr_mig_data->src_nodes[diss_cnt].node_name
      ENDIF
    ENDFOR
    SET diss_cnt = 0
    SET diss_row_cnt = 9
    WHILE (diss_cnt < size(diss_node_list)
     AND diss_row_cnt < diss_rows_max)
      IF (size(diss_node_list) < diss_col_max)
       CALL text(diss_row_cnt,(diss_col_num+ 2),trim(substring((diss_cnt+ 1),diss_col_max,
          diss_node_list)))
       SET diss_length = diss_col_max
      ELSE
       SET diss_length = findstring(",",substring((diss_cnt+ 1),diss_col_max,diss_node_list),(
        diss_cnt+ 1),1)
       IF (diss_length=0)
        SET diss_length = diss_col_max
       ENDIF
       CALL text(diss_row_cnt,(diss_col_num+ 2),trim(substring((diss_cnt+ 1),diss_length,
          diss_node_list)))
      ENDIF
      SET diss_cnt = (diss_cnt+ diss_length)
      SET diss_row_cnt = (diss_row_cnt+ 1)
    ENDWHILE
   ENDIF
   IF (diss_tgt_db_ind=1)
    SET diss_col_num = evaluate(diss_src_db_ind,1,60,2)
    CALL text(3,diss_col_num,"TARGET")
    CALL text(4,diss_col_num,concat("Database Name : ",trim(dmr_mig_data->tgt_db_name)))
    CALL text(5,diss_col_num,concat("Database Create Date : ",format(dmr_mig_data->tgt_created_date,
       "mm-dd-yyyy;;d")))
    CALL text(6,diss_col_num,concat("Database Operating System : ",trim(dmr_mig_data->tgt_db_os)))
    CALL text(7,diss_col_num,concat("Database Oracle Version : ",trim(dmr_mig_data->tgt_ora_version))
     )
    CALL text(8,diss_col_num,"Database Nodes : ")
    SET diss_node_list = ""
    FOR (diss_cnt = 1 TO dmr_mig_data->tgt_node_cnt)
      IF ((dmr_mig_data->tgt_node_cnt > 1)
       AND diss_cnt != 1)
       SET diss_node_list = concat(diss_node_list,", ",dmr_mig_data->tgt_nodes[diss_cnt].node_name)
      ELSE
       SET diss_node_list = dmr_mig_data->tgt_nodes[diss_cnt].node_name
      ENDIF
    ENDFOR
    SET diss_cnt = 0
    SET diss_row_cnt = 9
    WHILE (diss_cnt < size(diss_node_list)
     AND diss_row_cnt < diss_rows_max)
      IF (size(diss_node_list) < diss_col_max)
       CALL text(diss_row_cnt,(diss_col_num+ 2),trim(substring((diss_cnt+ 1),diss_col_max,
          diss_node_list)))
       SET diss_length = diss_col_max
      ELSE
       SET diss_length = findstring(",",substring((diss_cnt+ 1),diss_col_max,diss_node_list),(
        diss_cnt+ 1),1)
       IF (diss_length=0)
        SET diss_length = diss_col_max
       ENDIF
       CALL text(diss_row_cnt,(diss_col_num+ 2),trim(substring((diss_cnt+ 1),diss_length,
          diss_node_list)))
      ENDIF
      SET diss_cnt = (diss_cnt+ diss_length)
      SET diss_row_cnt = (diss_row_cnt+ 1)
    ENDWHILE
   ENDIF
   CALL video(r)
   CALL text(22,2,"PLEASE PREVIEW ALL THE VALUES BEFORE CONTINUING!")
   IF (diss_msg > "")
    CALL text(23,2,diss_msg)
   ENDIF
   CALL video(n)
   CALL text(24,2,"Enter 'C' to continue or 'Q' to quit (C or Q) :")
   CALL accept(24,50,"p;cu"," "
    WHERE curaccept IN ("C", "Q"))
   SET message = nowindow
   IF (curaccept="Q")
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Prompt for Summary Information."
    SET dm_err->emsg = "User elected to quit at Database Migration Summary Screen."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curaccept="C")
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE dmr_get_node_name(null)
   IF ((dmr_node->cnt > 0))
    SET dmr_node->cnt = 0
    SET stat = alterlist(dmr_node->qual,0)
   ENDIF
   SET dm_err->eproc = "Determining all the node names that database resides on"
   SELECT INTO "nl:"
    FROM v$thread vt,
     gv$instance vi
    PLAN (vt)
     JOIN (vi
     WHERE vt.thread#=vi.thread#)
    ORDER BY vi.instance_number
    DETAIL
     dmr_node->cnt = (dmr_node->cnt+ 1)
     IF (mod(dmr_node->cnt,10)=1)
      stat = alterlist(dmr_node->qual,(dmr_node->cnt+ 9))
     ENDIF
     dmr_node->qual[dmr_node->cnt].instance_name = vi.instance_name, dmr_node->qual[dmr_node->cnt].
     instance_number = vi.instance_number, dmr_node->qual[dmr_node->cnt].node_name = vi.host_name
    FOOT REPORT
     stat = alterlist(dmr_node->qual,dmr_node->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 4))
    CALL echorecord(dmr_node)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_get_queue_contents(batch_queue)
   DECLARE dgqc_temp_line = vc WITH protect, noconstant("")
   DECLARE dgqc_field_num = i4 WITH protect, noconstant(1)
   DECLARE dgqc_start_pos = i4 WITH protect, noconstant(1)
   DECLARE dgqc_end_pos = i4 WITH protect, noconstant(1)
   DECLARE dgqc_continue = i4 WITH protect, noconstant(1)
   DECLARE dgqc_iter = i4 WITH protect, noconstant(0)
   IF (dm2_push_dcl(concat("SHOW QUEUE ",batch_queue))=0)
    RETURN(0)
   ENDIF
   FREE DEFINE rtl
   DEFINE rtl build("CCLUSERDIR:",dm_err->errfile)
   SET dm_err->eproc = "Parsing queue contents."
   SELECT INTO "nl:"
    r.line
    FROM rtlt r
    HEAD REPORT
     dmr_queue->cnt = 0, stat = alterlist(dmr_queue->qual,0)
    DETAIL
     dgqc_temp_line = trim(r.line,3)
     FOR (dgqc_iter = 1 TO 5)
       dgqc_temp_line = replace(dgqc_temp_line,"  "," ",0)
     ENDFOR
     dgqc_start_pos = 1, dgqc_continue = 1
     IF (dgqc_temp_line != ""
      AND dgqc_temp_line != "Entry*"
      AND dgqc_temp_line != "-----*"
      AND dgqc_temp_line != "Batch queue*")
      WHILE (dgqc_continue=1)
        IF (dgqc_field_num <= 3
         AND findstring(" ",dgqc_temp_line,dgqc_start_pos) > 0)
         dgqc_end_pos = least(findstring(" ",dgqc_temp_line,dgqc_start_pos),(size(dgqc_temp_line)+ 1)
          )
        ELSE
         dgqc_end_pos = (size(dgqc_temp_line)+ 1)
        ENDIF
        CASE (dgqc_field_num)
         OF 1:
          dmr_queue->cnt = (dmr_queue->cnt+ 1),stat = alterlist(dmr_queue->qual,dmr_queue->cnt),
          dmr_queue->qual[dmr_queue->cnt].entry = cnvtint(substring(dgqc_start_pos,(dgqc_end_pos -
            dgqc_start_pos),dgqc_temp_line))
         OF 2:
          dmr_queue->qual[dmr_queue->cnt].jobname = substring(dgqc_start_pos,(dgqc_end_pos -
           dgqc_start_pos),dgqc_temp_line)
         OF 3:
          dmr_queue->qual[dmr_queue->cnt].username = substring(dgqc_start_pos,(dgqc_end_pos -
           dgqc_start_pos),dgqc_temp_line)
         OF 4:
          dmr_queue->qual[dmr_queue->cnt].status = substring(dgqc_start_pos,(dgqc_end_pos -
           dgqc_start_pos),dgqc_temp_line)
        ENDCASE
        dgqc_start_pos = (dgqc_end_pos+ 1), dgqc_field_num = (dgqc_field_num+ 1)
        IF (dgqc_start_pos >= size(dgqc_temp_line))
         dgqc_continue = 0
        ENDIF
        IF (dgqc_field_num=5)
         dgqc_field_num = 1, dgqc_continue = 0
        ENDIF
      ENDWHILE
     ENDIF
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dmr_queue)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_check_directory(directory)
   IF (get_unique_file("dm2wrtprvtst",".dat")=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Determining if ",directory," is valid with write privs.")
   SELECT INTO value(build(directory,cnvtlower(dm_err->unique_fname)))
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     row + 1, "This is a test of writing to ", directory
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    IF (dm2_push_dcl(concat("DELETE ",directory,cnvtlower(dm_err->unique_fname),";",char(42)))=0)
     RETURN(0)
    ENDIF
   ELSE
    IF (dm2_push_dcl(concat("rm ",directory,cnvtlower(dm_err->unique_fname)))=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_get_unique_file_name(directory,file_prefix,file_suffix)
   DECLARE dgufn_continue = i2 WITH protect, noconstant(1)
   DECLARE dgufn_file_name = vc WITH protect, noconstant("")
   DECLARE dgufn_unique_tempstr = vc WITH protect, noconstant("")
   SET dm_err->eproc = concat("Getting unique file name using directory: ",directory," prefix: ",
    file_prefix," and ext: ",
    file_suffix)
   IF (textlen(concat(file_prefix,file_suffix)) > 24)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Combination of file prefix and extension exceeded length limit of 24."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   WHILE (dgufn_continue=1)
     SET dgufn_unique_tempstr = substring(1,6,cnvtstring((datetimediff(cnvtdatetime(curdate,curtime3),
        cnvtdatetime(curdate,000000)) * 864000)))
     IF (directory > "")
      SET dgufn_file_name = build(directory,file_prefix,dgufn_unique_tempstr,file_suffix)
     ELSE
      SET dgufn_file_name = build(file_prefix,dgufn_unique_tempstr,file_suffix)
     ENDIF
     IF (findfile(dgufn_file_name)=0)
      SET dgufn_continue = 0
      SET dm_err->unique_fname = dgufn_file_name
     ENDIF
   ENDWHILE
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   CALL echo(concat("**Unique filename = ",dm_err->unique_fname))
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_fill_email_list(null)
   SET dm_err->eproc = "Querying for list of email addresses from dm_info."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_MIG_EMAILS"
    ORDER BY di.info_name
    HEAD REPORT
     dmr_emails->change_ind = 0, dmr_emails->cnt = 0, stat = alterlist(dmr_emails->qual,dmr_emails->
      cnt),
     dmr_emails->email_list = ""
    DETAIL
     dmr_emails->cnt = (dmr_emails->cnt+ 1), stat = alterlist(dmr_emails->qual,dmr_emails->cnt),
     dmr_emails->qual[dmr_emails->cnt].email_address = di.info_name
     IF ((dmr_emails->cnt=1))
      dmr_emails->email_list = di.info_name
     ELSE
      dmr_emails->email_list = concat(dmr_emails->email_list,",",di.info_name)
     ENDIF
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_send_email(subject,address_list,file_name)
   IF (((trim(subject)="") OR (((trim(address_list)="") OR (trim(file_name)="")) )) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Verifying input parameters."
    SET dm_err->emsg = "Input parameters can not be blank."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    IF (dm2_push_dcl(concat('MAIL/SUBJECT="',build(subject),'" ',build(file_name),' "',
      build(address_list),'"'))=0)
     RETURN(0)
    ENDIF
   ELSEIF ((dm2_sys_misc->cur_os IN ("AIX", "LNX")))
    IF (dm2_push_dcl(concat('mail -s "',subject,'" "',address_list,'" < ',
      file_name))=0)
     RETURN(0)
    ENDIF
   ELSEIF ((dm2_sys_misc->cur_os="HPX"))
    IF (dm2_push_dcl(concat('mailx -s "',subject,'" "',address_list,'" < ',
      file_name))=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_get_user_list(null)
   SET dm_err->eproc = "Querying for list of users from dm_info."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_MIG_USER"
    ORDER BY di.info_name
    HEAD REPORT
     dmr_user_list->cnt = 0, stat = alterlist(dmr_user_list->qual,0), dmr_user_list->change_ind = 0
    DETAIL
     dmr_user_list->cnt = (dmr_user_list->cnt+ 1), stat = alterlist(dmr_user_list->qual,dmr_user_list
      ->cnt), dmr_user_list->qual[dmr_user_list->cnt].user = di.info_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_verify_v500_user(exists_ind)
   SET dm_err->eproc = "Querying for list of users from dm_info."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_MIG_USER"
     AND di.info_name="V500"
    HEAD REPORT
     exists_ind = 0
    DETAIL
     exists_ind = 1
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_get_gg_dir(null)
   DECLARE dggd_cap_dir = vc WITH protect, noconstant("/ggcapture")
   DECLARE dggd_del_dir = vc WITH protect, noconstant("/ggdelivery")
   SET dmr_mig_data->report_all = 0
   SET dmr_mig_data->report_capture = 0
   SET dmr_mig_data->report_delivery = 0
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dggd_cap_dir = "GGCAPTURE:[000000]"
    SET dggd_del_dir = "GGDELIVERY:[000000]"
   ENDIF
   IF (dm2_find_dir(dggd_cap_dir)=1)
    SET dmr_mig_data->report_capture = 1
   ELSEIF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF (dm2_find_dir(dggd_del_dir)=1)
    SET dmr_mig_data->report_delivery = 1
   ELSEIF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF ((dmr_mig_data->report_delivery=1)
    AND (dmr_mig_data->report_capture=1))
    SET dmr_mig_data->report_all = 1
   ENDIF
   CALL dmr_set_gg_files(dmr_mig_data->report_capture,dmr_mig_data->report_delivery)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_set_gg_files(dsgf_report_capture,dsgf_report_delivery)
   SET dmr_mig_data->cap_dir = "DM2NOTSET"
   SET dmr_mig_data->cap_mgr_rpt = "DM2NOTSET"
   SET dmr_mig_data->cap_rpt = "DM2NOTSET"
   SET dmr_mig_data->cap_err_rpt = "DM2NOTSET"
   SET dmr_mig_data->del_dir = "DM2NOTSET"
   SET dmr_mig_data->del_mgr_rpt = "DM2NOTSET"
   SET dmr_mig_data->del_rpt = "DM2NOTSET"
   SET dmr_mig_data->del_err_rpt = "DM2NOTSET"
   IF ((dm2_sys_misc->cur_os="AXP")
    AND dsgf_report_capture=1)
    SET dmr_mig_data->cap_dir = "GGCAPTURE:[000000]"
    SET dmr_mig_data->cap_mgr_rpt = "GGCAPTURE:[DIRRPT]$MGR.$RPT"
    SET dmr_mig_data->cap_rpt = "GGCAPTURE:[DIRRPT]$CAPTURE.$RPT"
    SET dmr_mig_data->cap_err_rpt = "GGCAPTURE:[000000]GGSERR.LOG"
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP")
    AND dsgf_report_delivery=1)
    SET dmr_mig_data->del_dir = "GGDELIVERY:[000000]"
    SET dmr_mig_data->del_mgr_rpt = "GGDELIVERY:[DIRRPT]$MGR.$RPT"
    SET dmr_mig_data->del_rpt = "GGDELIVERY:[DIRRPT]$DELIVERY.$RPT"
    SET dmr_mig_data->del_err_rpt = "GGDELIVERY:[000000]GGSERR.LOG"
   ENDIF
   IF ((dm2_sys_misc->cur_os IN ("AIX", "HPX", "LNX"))
    AND dsgf_report_capture=1)
    SET dmr_mig_data->cap_dir = "/ggcapture"
    SET dmr_mig_data->cap_mgr_rpt = "/ggcapture/dirrpt/mgr.rpt"
    SET dmr_mig_data->cap_rpt = "/ggcapture/dirrpt/capture.rpt"
    SET dmr_mig_data->cap_err_rpt = "/ggcapture/ggserr.log"
   ENDIF
   IF ((dm2_sys_misc->cur_os IN ("AIX", "HPX", "LNX"))
    AND dsgf_report_delivery=1)
    SET dmr_mig_data->del_dir = "/ggdelivery"
    SET dmr_mig_data->del_mgr_rpt = "/ggdelivery/dirrpt/mgr.rpt"
    SET dmr_mig_data->del_rpt = "/ggdelivery/dirrpt/delivery.rpt"
    SET dmr_mig_data->del_err_rpt = "/ggdelivery/ggserr.log"
   ENDIF
 END ;Subroutine
 SUBROUTINE dmr_directory_prompt(mode)
   DECLARE ddp_dir_acceptable_ind = i2 WITH protect, noconstant(0)
   DECLARE ddp_src_ora_home_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE ddp_tgt_ora_home_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE ddp_src_file_loc_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE ddp_tgt_file_loc_exists_ind = i2 WITH protect, noconstant(0)
   IF ( NOT (dm2_find_dir(evaluate(dm2_sys_misc->cur_os,"AXP","GGDELIVERY:[DIRTMP]",
     "/ggdelivery/dirtmp"))))
    SET dmr_expimp->src_ksh_loc = " "
   ELSE
    SET dmr_expimp->src_ksh_loc = evaluate(dm2_sys_misc->cur_os,"AXP","GGDELIVERY:[DIRTMP]",
     "/ggdelivery/dirtmp")
   ENDIF
   SET dm_err->eproc = "Gathering existing bulk data move rows from dm_info."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_MIG_BULK_DATA_MOVE"
     AND di.info_name IN ("SOURCE_ORACLE_HOME", "TARGET_ORACLE_HOME", "LOCAL_DIR", "TARGET_DB_DIR")
    DETAIL
     CASE (di.info_name)
      OF "SOURCE_ORACLE_HOME":
       dmr_expimp->src_ora_home = di.info_char,ddp_src_ora_home_exists_ind = 1
      OF "TARGET_ORACLE_HOME":
       dmr_expimp->tgt_ora_home = di.info_char,ddp_tgt_ora_home_exists_ind = 1
      OF "LOCAL_DIR":
       dmr_expimp->src_ksh_loc = di.info_char,ddp_src_file_loc_exists_ind = 1
      OF "TARGET_DB_DIR":
       dmr_expimp->tgt_file_loc = di.info_char,ddp_tgt_file_loc_exists_ind = 1
     ENDCASE
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (mode=2)
    RETURN(1)
   ENDIF
   IF ((dmr_mig_data->src_ora_version != dmr_mig_data->tgt_ora_version))
    SET dmr_expimp->diff_ora_version = 1
   ENDIF
   SET dm_err->eproc = "Display Create Export/Import Files Prompts."
   CALL disp_msg("",dm_err->logfile,0)
   SET width = 132
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,24,131)
   CALL text(2,2,"Database Migration Default Directory Locations")
   CALL text(6,2,concat("Oracle Home for Oracle ",trim(cnvtstring(dmr_mig_data->src_ora_level1)),
     " on node ",dmr_mig_data->tgt_nodes[1].node_name))
   CALL text(7,2,concat("(compatible with SOURCE database Oracle ",trim(dmr_mig_data->src_ora_version
      ),"):"))
   CALL accept(7,60,"P(50);C",dmr_expimp->src_ora_home
    WHERE  NOT (curaccept=" "))
   SET dmr_expimp->src_ora_home = trim(curaccept)
   IF (substring(size(dmr_expimp->src_ora_home),1,dmr_expimp->src_ora_home)="/")
    SET dmr_expimp->src_ora_home = replace(dmr_expimp->src_ora_home,"/","",2)
   ENDIF
   IF (ddp_src_ora_home_exists_ind)
    SET dm_err->eproc = "Updating existing SOURCE_ORACLE_HOME row in dm_info."
    UPDATE  FROM dm_info di
     SET di.info_char = dmr_expimp->src_ora_home
     WHERE di.info_domain="DM2_MIG_BULK_DATA_MOVE"
      AND di.info_name="SOURCE_ORACLE_HOME"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->eproc = "Inserting new SOURCE_ORACLE_HOME row into dm_info."
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_MIG_BULK_DATA_MOVE", di.info_name = "SOURCE_ORACLE_HOME", di.info_char
       = dmr_expimp->src_ora_home
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   CALL text(9,2,concat("Oracle Home for Oracle ",trim(cnvtstring(dmr_mig_data->tgt_ora_level1)),
     " on node ",dmr_mig_data->tgt_nodes[1].node_name))
   CALL text(10,2,concat("(compatible with TARGET database Oracle ",trim(dmr_mig_data->
      tgt_ora_version),"):"))
   IF ((dmr_expimp->diff_ora_version=1))
    CALL accept(10,60,"P(50);C",dmr_expimp->tgt_ora_home
     WHERE  NOT (curaccept=" "))
    SET dmr_expimp->tgt_ora_home = trim(curaccept)
    IF (substring(size(dmr_expimp->tgt_ora_home),1,dmr_expimp->tgt_ora_home)="/")
     SET dmr_expimp->tgt_ora_home = replace(dmr_expimp->tgt_ora_home,"/","",2)
    ENDIF
   ELSE
    SET dmr_expimp->tgt_ora_home = dmr_expimp->src_ora_home
    CALL text(10,60,dmr_expimp->tgt_ora_home)
   ENDIF
   IF (ddp_tgt_ora_home_exists_ind)
    SET dm_err->eproc = "Updating existing TARGET_ORACLE_HOME row in dm_info."
    UPDATE  FROM dm_info di
     SET di.info_char = dmr_expimp->tgt_ora_home
     WHERE di.info_domain="DM2_MIG_BULK_DATA_MOVE"
      AND di.info_name="TARGET_ORACLE_HOME"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->eproc = "Inserting new TARGET_ORACLE_HOME row into dm_info."
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_MIG_BULK_DATA_MOVE", di.info_name = "TARGET_ORACLE_HOME", di.info_char
       = dmr_expimp->tgt_ora_home
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   CALL text(12,2,concat("Local Directory Location:"))
   CALL text(13,4,"(where ksh/par files will be created on this node)")
   SET ddp_dir_acceptable_ind = 1
   WHILE (ddp_dir_acceptable_ind)
    IF ((dm2_sys_misc->cur_os="AXP"))
     CALL accept(12,29,"P(60);CU",dmr_expimp->src_ksh_loc
      WHERE curaccept != ""
       AND substring(size(trim(curaccept)),1,trim(curaccept))="]")
    ELSE
     CALL accept(12,29,"P(60);C",dmr_expimp->src_ksh_loc
      WHERE curaccept != ""
       AND substring(1,1,curaccept)="/")
    ENDIF
    IF ((curaccept != dmr_expimp->src_ksh_loc))
     SET dmr_expimp->src_ksh_loc = curaccept
     IF (substring(size(dmr_expimp->src_ksh_loc),1,dmr_expimp->src_ksh_loc)="/")
      SET dmr_expimp->src_ksh_loc = replace(dmr_expimp->src_ksh_loc,"/","",2)
     ENDIF
     IF (dm2_find_dir(dmr_expimp->src_ksh_loc))
      SET ddp_dir_acceptable_ind = 0
      CALL clear(23,1,129)
     ELSE
      CALL text(23,2,"The directory entered does not exist.")
     ENDIF
    ELSE
     SET ddp_dir_acceptable_ind = 0
    ENDIF
   ENDWHILE
   IF (ddp_src_file_loc_exists_ind)
    SET dm_err->eproc = "Updating existing LOCAL_DIR row in dm_info."
    UPDATE  FROM dm_info di
     SET di.info_char = dmr_expimp->src_ksh_loc
     WHERE di.info_domain="DM2_MIG_BULK_DATA_MOVE"
      AND di.info_name="LOCAL_DIR"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->eproc = "Inserting new LOCAL_DIR row into dm_info."
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_MIG_BULK_DATA_MOVE", di.info_name = "LOCAL_DIR", di.info_char =
      dmr_expimp->src_ksh_loc
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   CALL text(15,2,concat("Target Database Node Directory Location:"))
   CALL text(16,4,"(where ksh files will be copied to and executed from)")
   CALL accept(15,44,"P(60);C",dmr_expimp->tgt_file_loc
    WHERE curaccept != ""
     AND substring(1,1,curaccept)="/")
   SET dmr_expimp->tgt_file_loc = curaccept
   IF (substring(size(dmr_expimp->tgt_file_loc),1,dmr_expimp->tgt_file_loc)="/")
    SET dmr_expimp->tgt_file_loc = replace(dmr_expimp->tgt_file_loc,"/","",2)
   ENDIF
   IF (ddp_tgt_file_loc_exists_ind)
    SET dm_err->eproc = "Updating existing TARGET_DB_DIR row in dm_info."
    UPDATE  FROM dm_info di
     SET di.info_char = dmr_expimp->tgt_file_loc
     WHERE di.info_domain="DM2_MIG_BULK_DATA_MOVE"
      AND di.info_name="TARGET_DB_DIR"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->eproc = "Inserting new TARGET_DB_DIR row into dm_info."
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_MIG_BULK_DATA_MOVE", di.info_name = "TARGET_DB_DIR", di.info_char =
      dmr_expimp->tgt_file_loc
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   CALL text(23,2,"Enter 'C' to continue or 'Q' to quit (C or Q): ")
   CALL accept(23,50,"P;CU"," "
    WHERE curaccept IN ("C", "Q"))
   IF (curaccept="Q")
    ROLLBACK
    RETURN(0)
   ELSE
    COMMIT
    SET message = nowindow
    CALL clear(1,1)
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE dmr_setup_batch_queue(dsbq_queue_name)
   DECLARE dsbq_env_name = vc WITH protect, noconstant(" ")
   DECLARE dsbq_cmd = vc WITH protect, noconstant(" ")
   DECLARE dsbq_start_pos = i4 WITH protect, noconstant(0)
   DECLARE dsbq_end_pos = i4 WITH protect, noconstant(0)
   DECLARE dsbq_domain_user = vc WITH protect, noconstant(" ")
   DECLARE dsbq_err_str = vc WITH protect, constant("no such queue")
   DECLARE dsbq_queue_fnd_ret = i2 WITH protect, noconstant(0)
   DECLARE dsbq_job_limit_str = vc WITH protect, noconstant(" ")
   DECLARE dsbq_job_limit = i2 WITH protect, noconstant(1)
   DECLARE dsbq_job_limit_accept = i2 WITH protect, noconstant(0)
   DECLARE dsbq_job_limit_fnd = i2 WITH protect, noconstant(0)
   DECLARE dsbq_temp_line = vc WITH protect, noconstant(" ")
   IF ((dm2_sys_misc->cur_os != "AXP"))
    RETURN(1)
   ENDIF
   IF (((dsbq_queue_name=" ") OR (dsbq_queue_name="")) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating input batch queue name."
    SET dm_err->emsg = "Invalid batch queue name."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dsbq_env_name = logical("environment")
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("Environment Name = ",dsbq_env_name))
   ENDIF
   IF (((dsbq_env_name=" ") OR (dsbq_env_name="")) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating environment name."
    SET dm_err->emsg = "Invalid environment name."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dsbq_cmd = concat("lreg -getp environment\",dsbq_env_name,
    " LocalUserName ;show symbol LREG_RESULT")
   IF ((dm_err->debug_flag > 0))
    CALL echo("*")
    CALL echo(concat("call dcl executing: ",dsbq_cmd))
    CALL echo("*")
   ENDIF
   SET dm_err->disp_dcl_err_ind = 0
   IF (dm2_push_dcl(dsbq_cmd)=0)
    IF ((dm_err->err_ind=1))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   SET dm_err->errtext = replace(dm_err->errtext,'LREG_RESULT = "',"",0)
   SET dm_err->errtext = replace(dm_err->errtext,'"',"",1)
   IF (findstring("%DCL-W-UNDSYM",dm_err->errtext) > 0)
    SET dsbq_domain_user = " "
   ELSE
    SET dsbq_domain_user = trim(dm_err->errtext,3)
   ENDIF
   IF (dsbq_domain_user=" ")
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Retreiving domain user from registry."
    SET dm_err->emsg = "Unable to retrieive domain user from registry."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (cnvtupper(curuser) != cnvtupper(dsbq_domain_user))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Making sure current user is the domain user."
    SET dm_err->emsg = "Current user is not the domain user."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dmr_check_batch_queue(dsbq_queue_name,dsbq_queue_fnd_ret)=0)
    RETURN(0)
   ENDIF
   IF (dsbq_queue_fnd_ret=1)
    SET dsbq_job_limit = 0
    SET dsbq_job_limit_fnd = 0
    IF (dm2_push_dcl(concat("SHOW QUEUE /full ",dsbq_queue_name))=0)
     RETURN(0)
    ENDIF
    FREE DEFINE rtl
    DEFINE rtl build("CCLUSERDIR:",dm_err->errfile)
    SET dm_err->eproc = "Parsing queue contents for job_limit."
    SELECT INTO "nl:"
     r.line
     FROM rtlt r
     DETAIL
      dsbq_temp_line = trim(r.line,3)
      FOR (dgqc_iter = 1 TO 5)
        dsbq_temp_line = replace(dsbq_temp_line,"  "," ",0)
      ENDFOR
      dsbq_start_pos = findstring("JOB_LIMIT",cnvtupper(dsbq_temp_line),1)
      IF (dsbq_start_pos > 0)
       dsbq_job_limit_fnd = 1, dsbq_end_pos = findstring(" ",dsbq_temp_line,dsbq_start_pos)
       IF (dsbq_end_pos > 0)
        dsbq_job_limit_str = trim(substring((dsbq_start_pos+ 10),(dsbq_end_pos - (dsbq_start_pos+ 10)
          ),dsbq_temp_line),3),
        CALL cancel(1)
       ELSE
        dm_err->err_ind = 1, dm_err->emsg = "Failed to parse out job_limit from queue data",
        CALL cancel(1)
       ENDIF
      ENDIF
     WITH nocounter, nullreport
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (((dsbq_job_limit_fnd=0) OR (isnumeric(dsbq_job_limit_str) != 1)) )
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Failed to parse out job_limit for queue data."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     SET dsbq_job_limit = cnvtint(dsbq_job_limit_str)
    ENDIF
   ENDIF
   SET message = window
   SET width = 132
   CALL clear(1,1)
   CALL video(n)
   CALL text(2,1,"Provide a job limit (1-20) for migration batch queue (0 to Quit): ")
   CALL accept(2,67,"99",dsbq_job_limit
    WHERE curaccept BETWEEN 0 AND 20)
   SET dsbq_job_limit_accept = curaccept
   SET message = nowindow
   IF (dsbq_job_limit_accept=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Migration Batch Queue Job Limit Prompt."
    SET dm_err->emsg = "User choose to Quit."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dsbq_queue_fnd_ret=0)
    SET dsbq_cmd = concat(build("init/queue/batch/start/job_limit=",dsbq_job_limit_accept)," ",
     dsbq_queue_name)
    IF ((dm_err->debug_flag > 0))
     CALL echo("*")
     CALL echo(concat("call dcl executing: ",dsbq_cmd))
     CALL echo("*")
    ENDIF
    IF (dm2_push_dcl(dsbq_cmd)=0)
     RETURN(0)
    ENDIF
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echo(concat("Results of create queue command: ",dm_err->errtext))
    ENDIF
   ELSEIF (dsbq_queue_fnd_ret=1
    AND dsbq_job_limit_accept != dsbq_job_limit)
    SET dsbq_cmd = concat(build("set queue/job_limit=",dsbq_job_limit_accept)," ",dsbq_queue_name)
    IF ((dm_err->debug_flag > 0))
     CALL echo("*")
     CALL echo(concat("call dcl executing: ",dsbq_cmd))
     CALL echo("*")
    ENDIF
    IF (dm2_push_dcl(dsbq_cmd)=0)
     RETURN(0)
    ENDIF
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echo(concat("Results of create queue command: ",dm_err->errtext))
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_check_batch_queue(dcbq_queue_name,dcbq_queue_fnd_ret)
   DECLARE dcbq_env_name = vc WITH protect, noconstant(" ")
   DECLARE dcbq_cmd = vc WITH protect, noconstant(" ")
   DECLARE dcbq_start_pos = i4 WITH protect, noconstant(0)
   DECLARE dcbq_end_pos = i4 WITH protect, noconstant(0)
   DECLARE dcbq_domain_user = vc WITH protect, noconstant(" ")
   DECLARE dcbq_err_str = vc WITH protect, constant("no such queue")
   SET dcbq_queue_fnd_ret = 0
   IF ((dm2_sys_misc->cur_os != "AXP"))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating current operating system is AXP."
    SET dm_err->emsg = "Invalid current operating system."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((dcbq_queue_name=" ") OR (dcbq_queue_name="")) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating input batch queue name."
    SET dm_err->emsg = "Invalid batch queue name."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dcbq_cmd = concat("sho queue /full ",dcbq_queue_name)
   SET dm_err->disp_dcl_err_ind = 0
   IF (dm2_push_dcl(dcbq_cmd)=0)
    IF ((dm_err->err_ind=1))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   IF (findstring(dcbq_err_str,cnvtlower(dm_err->errtext),1,0) > 0)
    SET dcbq_queue_fnd_ret = 0
   ELSEIF (findstring(cnvtlower(dcbq_queue_name),cnvtlower(dm_err->errtext),1,0)=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Determining if queue ",dcbq_queue_name," exists.")
    SET dm_err->emsg = dm_err->errtext
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    SET dcbq_queue_fnd_ret = 1
   ENDIF
   IF (dcbq_queue_fnd_ret=1)
    IF (findstring("idle",cnvtlower(dm_err->errtext),1,0)=0
     AND findstring("executing",cnvtlower(dm_err->errtext),1,0)=0)
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Make sure queue ",dcbq_queue_name,
      " is idle or is currently executing jobs.")
     SET dm_err->emsg = dm_err->errtext
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_validate_src_and_tgt(dvst_src_ind,dvst_tgt_ind)
   DECLARE dvsat_db = vc WITH protect, noconstant("")
   DECLARE dvsat_cnt = i4 WITH protect, noconstant(0)
   DECLARE dvsat_str = vc WITH protect, noconstant("")
   IF (dvst_src_ind=1)
    IF (dmr_prompt_connect_data("SOURCE","V500","PC")=0)
     RETURN(0)
    ENDIF
    SET dvsat_db = "SOURCE"
    IF (dmr_get_db_info(dmr_mig_data->src_db_name,dmr_mig_data->src_created_date)=0)
     RETURN(0)
    ENDIF
    SET dmr_mig_data->src_db_os = dm2_sys_misc->cur_db_os
    IF (dm2_get_rdbms_version(null)=0)
     RETURN(0)
    ENDIF
    SET dmr_mig_data->src_ora_version = dm2_rdbms_version->version
    SET dmr_mig_data->src_ora_level1 = dm2_rdbms_version->level1
    SET dmr_mig_data->src_ora_level2 = dm2_rdbms_version->level2
    SET dmr_mig_data->src_ora_level3 = dm2_rdbms_version->level3
    SET dmr_mig_data->src_ora_level4 = dm2_rdbms_version->level4
    SET dvsat_str = ""
    IF (dmr_get_storage_type(dvsat_str)=0)
     RETURN(0)
    ENDIF
    SET dmr_mig_data->src_storage_type = dvsat_str
    IF (dmr_get_node_name(null)=0)
     RETURN(0)
    ENDIF
    SET dmr_mig_data->src_node_cnt = dmr_node->cnt
    SET stat = alterlist(dmr_mig_data->src_nodes,dmr_node->cnt)
    FOR (dvsat_cnt = 1 TO dmr_node->cnt)
      SET dmr_mig_data->src_nodes[dvsat_cnt].node_name = cnvtlower(dmr_node->qual[dvsat_cnt].
       node_name)
      SET dmr_mig_data->src_nodes[dvsat_cnt].instance_number = dmr_node->qual[dvsat_cnt].
      instance_number
      SET dmr_mig_data->src_nodes[dvsat_cnt].instance_name = cnvtlower(dmr_node->qual[dvsat_cnt].
       instance_name)
    ENDFOR
   ENDIF
   IF (dvst_tgt_ind=1)
    IF (dmr_prompt_connect_data("TARGET","V500","PC")=0)
     RETURN(0)
    ENDIF
    SET dvsat_db = "TARGET"
    SET dm_err->eproc = "Get databse name and created date"
    IF (dmr_get_db_info(dmr_mig_data->tgt_db_name,dmr_mig_data->tgt_created_date)=0)
     RETURN(0)
    ENDIF
    SET dmr_mig_data->tgt_db_os = dm2_sys_misc->cur_db_os
    IF (dm2_get_rdbms_version(null)=0)
     RETURN(0)
    ENDIF
    SET dmr_mig_data->tgt_ora_version = dm2_rdbms_version->version
    SET dmr_mig_data->tgt_ora_level1 = dm2_rdbms_version->level1
    SET dmr_mig_data->tgt_ora_level2 = dm2_rdbms_version->level2
    SET dmr_mig_data->tgt_ora_level3 = dm2_rdbms_version->level3
    SET dmr_mig_data->tgt_ora_level4 = dm2_rdbms_version->level4
    SET dvsat_str = ""
    IF (dmr_get_storage_type(dvsat_str)=0)
     RETURN(0)
    ENDIF
    SET dmr_mig_data->tgt_storage_type = dvsat_str
    IF (dmr_get_node_name(null)=0)
     RETURN(0)
    ENDIF
    SET dmr_mig_data->tgt_node_cnt = dmr_node->cnt
    SET stat = alterlist(dmr_mig_data->tgt_nodes,dmr_node->cnt)
    FOR (dvsat_cnt = 1 TO dmr_node->cnt)
      SET dmr_mig_data->tgt_nodes[dvsat_cnt].node_name = cnvtlower(dmr_node->qual[dvsat_cnt].
       node_name)
      SET dmr_mig_data->tgt_nodes[dvsat_cnt].instance_number = dmr_node->qual[dvsat_cnt].
      instance_number
      SET dmr_mig_data->tgt_nodes[dvsat_cnt].instance_name = cnvtlower(dmr_node->qual[dvsat_cnt].
       instance_name)
    ENDFOR
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dmr_mig_data)
   ENDIF
   IF (dmr_issue_summary_screen(dvst_src_ind,dvst_tgt_ind,"")=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_stop_job(job_type,job_mode)
   DECLARE dsj_found_ind = i2 WITH protect, noconstant(0)
   DECLARE dsj_iter = i4 WITH protect, noconstant(0)
   DECLARE dsj_info_name = vc WITH protect, noconstant("")
   IF ((dm_err->debug_flag=722))
    CALL echorecord(dmr_mig_data)
   ENDIF
   IF ((((dmr_mig_data->report_all=1)) OR ((dmr_mig_data->report_capture=1))) )
    SET dsj_info_name = "STOP_CAPTURE_MONITORING"
   ELSEIF ((dmr_mig_data->report_delivery=1))
    SET dsj_info_name = "STOP_DELIVERY_MONITORING"
   ELSE
    IF (job_mode=1)
     SET message = nowindow
    ENDIF
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Checking execution status"
    SET dm_err->emsg = "GGDELIVERY or GGCAPTURE do not exist. Unable to stop job."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    IF (dmr_get_queue_contents(dmr_batch_queue)=0)
     RETURN(0)
    ENDIF
    FOR (dsj_iter = 1 TO dmr_queue->cnt)
      IF ((dmr_queue->qual[dsj_iter].jobname=evaluate(job_type,"ARCH","DM2_MIG_COPY_ARCHIVELOGS",
       "MON","DM2_MIG_MONITORING")))
       SET dsj_found_ind = 1
      ENDIF
    ENDFOR
   ELSE
    IF (dm2_push_dcl("ps -ef | grep dm2_mig_monitoring.ksh")=0)
     RETURN(0)
    ENDIF
    FREE DEFINE rtl
    DEFINE rtl build("CCLUSERDIR:",dm_err->errfile)
    SET dm_err->eproc = "Determining if there were any results obtainted from the ps command."
    SELECT INTO "nl:"
     FROM rtlt r
     DETAIL
      IF (trim(r.line,3) != "* grep *")
       dsj_found_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dsj_found_ind)
    SET dm_err->eproc = concat("Determining if STOP row exists for ",job_type," from dm_info.")
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DM2_MIG_DATA"
      AND di.info_name=value(evaluate(job_type,"ARCH","STOP_ARCHIVE_COPY","MON",dsj_info_name))
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET dm_err->eproc = concat("Inserting STOP row for ",job_type," into dm_info.")
     INSERT  FROM dm_info di
      SET di.info_domain = "DM2_MIG_DATA", di.info_name = value(evaluate(job_type,"ARCH",
         "STOP_ARCHIVE_COPY","MON",dsj_info_name))
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     COMMIT
    ENDIF
    IF (job_mode=1)
     CALL text(21,10,
      "The job has been marked for deletion. Please monitor with Status of Job menu option. Press <enter> to continue."
      )
     CALL accept(21,122,"A;CH"," ")
     CALL clear(21,2,129)
    ENDIF
   ELSE
    IF (job_mode=1)
     CALL text(21,10,"No matching jobs were found.  Press <enter> to continue.")
     CALL accept(21,67,"A;CH"," ")
     CALL clear(21,2,129)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_get_storage_type(dgst_storage_ret)
  IF ((dm2_sys_misc->cur_db_os="AXP"))
   SET dgst_storage_ret = "AXP"
  ELSE
   SET dm_err->eproc = "Determine target storage type from dba_data_files"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_data_files ddf
    WHERE ddf.tablespace_name="SYSTEM"
     AND ddf.file_name=patstring("/dev/*")
    DETAIL
     dgst_storage_ret = "RAW"
    WITH nocounter, maxqual = 1
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dgst_storage_ret = "ASM"
   ENDIF
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_load_managed_tables(dlmt_mng_ret)
   DECLARE dlmt_dm_info_exists = i2 WITH protect, noconstant(0)
   SET dlmt_mng_ret = "'DM_STAT_TABLE','PLAN_TABLE','DM_CONSTRAINT_EXCEPTIONS'"
   IF (dm2_table_and_ccldef_exists("DM_INFO",dlmt_dm_info_exists)=0)
    RETURN(0)
   ENDIF
   IF (dlmt_dm_info_exists=1)
    SET dm_err->eproc = "Loading list of managed tables from dm_info."
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DM2_MIGRATION"
      AND di.info_name="MANAGED TABLES"
     DETAIL
      dlmt_mng_ret = di.info_char
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_mig_setup_gg_dir(null)
   DECLARE dmsgd_gg_cap_dir_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE dmsgd_gg_del_dir_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE dmsgd_gg_cap_loc = vc WITH protect, noconstant("")
   DECLARE dmsgd_gg_del_loc = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Determining if Directory setup row already exists in dm_info."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_MIG_GG_DATA"
     AND di.info_name IN ("GG_CAP_DIR", "GG_DEL_DIR")
    DETAIL
     IF (di.info_name="GG_CAP_DIR")
      dmsgd_gg_cap_loc = di.info_char, dmsgd_gg_cap_dir_exists_ind = 1
     ELSE
      dmsgd_gg_del_loc = di.info_char, dmsgd_gg_del_dir_exists_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET width = 132
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,24,131)
   CALL text(2,2,"Database Migration Capture/Delivery Directory Locations")
   CALL text(6,2,concat("Capture Directory Location:"))
   IF ((dm2_sys_misc->cur_os="AXP"))
    CALL accept(6,29,"P(90);CU",dmsgd_gg_cap_loc
     WHERE curaccept != ""
      AND substring(size(trim(curaccept)),1,trim(curaccept))="]")
   ELSE
    CALL accept(6,29,"P(90);C",dmsgd_gg_cap_loc
     WHERE curaccept != ""
      AND substring(1,1,curaccept)="/")
   ENDIF
   SET dmsgd_gg_cap_loc = curaccept
   IF (substring(size(dmsgd_gg_cap_loc),1,dmsgd_gg_cap_loc)="/")
    SET dmsgd_gg_cap_loc = trim(replace(dmsgd_gg_cap_loc,"/","",2),3)
   ENDIF
   IF (dmsgd_gg_cap_dir_exists_ind)
    SET dm_err->eproc = "Updating existing Capture DIR row in dm_info."
    UPDATE  FROM dm_info di
     SET di.info_char = dmsgd_gg_cap_loc
     WHERE di.info_domain="DM2_MIG_GG_DATA"
      AND di.info_name="GG_CAP_DIR"
     WITH nocounter
    ;end update
   ELSE
    SET dm_err->eproc = "Inserting new Capture DIR row into dm_info."
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_MIG_GG_DATA", di.info_name = "GG_CAP_DIR", di.info_char =
      dmsgd_gg_cap_loc
     WITH nocounter
    ;end insert
   ENDIF
   IF (check_error(dm_err->eproc))
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   COMMIT
   CALL text(8,2,concat("Delivery Directory Location:"))
   IF ((dm2_sys_misc->cur_os="AXP"))
    CALL accept(8,30,"P(90);CU",dmsgd_gg_del_loc
     WHERE curaccept != ""
      AND substring(size(trim(curaccept)),1,trim(curaccept))="]")
   ELSE
    CALL accept(8,30,"P(90);C",dmsgd_gg_del_loc
     WHERE curaccept != ""
      AND substring(1,1,curaccept)="/")
   ENDIF
   SET dmsgd_gg_del_loc = curaccept
   IF (substring(size(dmsgd_gg_del_loc),1,dmsgd_gg_del_loc)="/")
    SET dmsgd_gg_del_loc = trim(replace(dmsgd_gg_del_loc,"/","",2),3)
   ENDIF
   IF (dmsgd_gg_del_dir_exists_ind)
    SET dm_err->eproc = "Updating existing Delivery DIR row in dm_info."
    UPDATE  FROM dm_info di
     SET di.info_char = dmsgd_gg_del_loc
     WHERE di.info_domain="DM2_MIG_GG_DATA"
      AND di.info_name="GG_DEL_DIR"
     WITH nocounter
    ;end update
   ELSE
    SET dm_err->eproc = "Inserting new Delivery DIR row into dm_info."
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2_MIG_GG_DATA", di.info_name = "GG_DEL_DIR", di.info_char =
      dmsgd_gg_del_loc
     WITH nocounter
    ;end insert
   ENDIF
   IF (check_error(dm_err->eproc))
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_load_di_filter(null)
   DECLARE dldf_cnt = i4 WITH protect, noconstant(0)
   SET dldf_cnt = 0
   SET dmr_di_filter->cnt = 19
   SET stat = alterlist(dmr_di_filter->qual,dmr_di_filter->cnt)
   SET dmr_di_filter->qual[1].name = "STATS LOCK"
   SET dmr_di_filter->qual[2].name = "QUEUE DBSTATS LOCK"
   SET dmr_di_filter->qual[3].name = "FREQUENT STATS GATHER LOCK"
   SET dmr_di_filter->qual[4].name = "DM2_DBSTATS_ADJUSTMENT"
   SET dmr_di_filter->qual[5].name = "DM_HIGHLOW_MOD"
   SET dmr_di_filter->qual[6].name = "DM_HIGHLOW_MOD_HISTOGRAM"
   SET dmr_di_filter->qual[7].name = "DM2 INSTALL PROCESS"
   SET dmr_di_filter->qual[8].name = "DM2_UTC_SCHEMA_RUNNER"
   SET dmr_di_filter->qual[9].name = "DM2_MIG_DI_FILTER"
   SET dmr_di_filter->qual[10].name = "DM2_BACKGROUND_RUNNER"
   SET dmr_di_filter->qual[11].name = "DM2_INSTALL_RUNNER"
   SET dmr_di_filter->qual[12].name = "DM2_SCHEMA_RUNNER"
   SET dmr_di_filter->qual[13].name = "DM2_README_RUNNER"
   SET dmr_di_filter->qual[14].name = "DM2_SET_READY_TO_RUN"
   SET dmr_di_filter->qual[15].name = "DM2_INSTALL_PKG"
   SET dmr_di_filter->qual[16].name = "DM2_INSTALL_MONITOR"
   SET dmr_di_filter->qual[17].name = "DM2_FLEX_SCHED_USAGE"
   SET dmr_di_filter->qual[18].name = "DM2GDBS%"
   SET dmr_di_filter->qual[19].name = "DM2_MIG_STATUS_MARKER"
   SET dm_err->eproc = "Remove DM_INFO info name filter rows."
   CALL disp_msg("",dm_err->logfile,0)
   DELETE  FROM dm_info di
    WHERE di.info_domain="DM2_MIG_DI_FILTER"
     AND expand(dldf_cnt,1,dmr_di_filter->cnt,di.info_name,dmr_di_filter->qual[dldf_cnt].name)
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Add DM_INFO info name filter rows."
   CALL disp_msg("",dm_err->logfile,0)
   INSERT  FROM dm_info di,
     (dummyt d  WITH seq = value(size(dmr_di_filter->qual,5)))
    SET di.info_domain = "DM2_MIG_DI_FILTER", di.info_name = dmr_di_filter->qual[d.seq].name, di
     .updt_dt_tm = cnvtdatetime(curdate,curtime3)
    PLAN (d
     WHERE d.seq > 0)
     JOIN (di)
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_get_di_filter(null)
   DECLARE dgdf_fail_ind = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Get DM_INFO info name filter rows."
   CALL disp_msg("",dm_err->logfile,0)
   SET dmr_di_filter->cnt = 0
   SET stat = alterlist(dmr_di_filter->qual,dmr_di_filter->cnt)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_MIG_DI_FILTER"
    DETAIL
     IF (findstring("%",di.info_name,1,0) > 0)
      IF (((findstring("%",di.info_name,1,0) != findstring("%",di.info_name,1,1)) OR (findstring(
       "%",di.info_name,1,0) != size(trim(di.info_name)))) )
       dgdf_fail_ind = 1
      ENDIF
     ENDIF
     dmr_di_filter->cnt = (dmr_di_filter->cnt+ 1), stat = alterlist(dmr_di_filter->qual,dmr_di_filter
      ->cnt), dmr_di_filter->qual[dmr_di_filter->cnt].name = di.info_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dgdf_fail_ind=1)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid name value."
    SET dm_err->eproc = "Verify DM_INFO filter rows."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dmr_di_filter->cnt=0))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("No DM_INFO filter rows found.")
    SET dm_err->eproc = "Verify DM_INFO filter rows."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmr_create_di_macro(dcdm_in_dir,dcdm_gg_version)
   DECLARE dcdm_fname = vc WITH protect, noconstant("")
   DECLARE dcdm_parm_loc = vc WITH protect, noconstant("")
   DECLARE dmuss_locndx = i4 WITH protect, noconstant(0)
   DECLARE dcdm_name = vc WITH protect, noconstant("")
   DECLARE dcdm_cmd = vc WITH protect, noconstant("")
   DECLARE dcdm_delim = vc WITH protect, noconstant("")
   IF (dcdm_gg_version > 11)
    SET dcdm_delim = "'"
   ELSE
    SET dcdm_delim = '"'
   ENDIF
   SET dm_err->eproc = "Create DM_INFO delivery filter macro."
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((dmr_di_filter->cnt=0))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("No DM_INFO filter rows found.")
    SET dm_err->eproc = "Verify DM_INFO filter rows."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(dmr_di_filter)
   ENDIF
   SET dcdm_parm_loc = dcdm_in_dir
   IF (dm2_find_dir(dcdm_parm_loc)=0)
    SET message = window
    CALL clear(1,1)
    CALL box(1,1,15,120)
    CALL text(3,2,"Enter Delivery parameter file directory location :")
    CALL accept(3,70,"P(30);C",dcdm_parm_loc
     WHERE curaccept != "")
    SET dcdm_parm_loc = trim(curaccept)
    SET message = nowindow
   ENDIF
   IF (dm2_find_dir(dcdm_parm_loc)=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Delivery parm directory entered [",dcdm_parm_loc,"] does not exist.")
    SET dm_err->eproc = "Verify delivery parm directory exists."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (substring(size(dcdm_parm_loc),1,dcdm_parm_loc) != "/")
    SET dcdm_parm_loc = concat(trim(dcdm_parm_loc),"/")
   ENDIF
   SET dcdm_fname = concat(trim(dcdm_parm_loc),"difilter.mac")
   SELECT INTO value(dcdm_fname)
    FROM (dummyt d  WITH d.seq = 1)
    DETAIL
     col 0,
     CALL print("MACRO #difilter"), row + 1,
     col 0,
     CALL print("BEGIN"), row + 1,
     col 0,
     CALL print("FILTER ( &"), row + 1
     FOR (dmuss_locndx = 1 TO dmr_di_filter->cnt)
       IF (dmuss_locndx=1)
        dcdm_cmd = "      ("
       ELSE
        dcdm_cmd = "  AND ("
       ENDIF
       IF (findstring("%",dmr_di_filter->qual[dmuss_locndx].name) > 0)
        dcdm_name = trim(replace(dmr_di_filter->qual[dmuss_locndx].name,"%","")), dcdm_cmd = concat(
         dcdm_cmd,"@STRNCMP(INFO_DOMAIN, ",dcdm_delim,dcdm_name,dcdm_delim,
         ", ",trim(cnvtstring(size(dcdm_name))),") <> 0) &")
       ELSE
        dcdm_name = trim(dmr_di_filter->qual[dmuss_locndx].name), dcdm_cmd = concat(dcdm_cmd,
         "@STRCMP (INFO_DOMAIN, ",dcdm_delim,dcdm_name,dcdm_delim,
         ") <> 0) &")
       ENDIF
       col 0,
       CALL print(dcdm_cmd), row + 1
     ENDFOR
     col 0,
     CALL print(")"), row + 1,
     col 0,
     CALL print("END;"), row + 1
    WITH nocounter, maxrow = 1, format = lfstream,
     noformfeed, maxcol = 2000
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 IF ((validate(dum_utc_data->uptime_run_id,- (999))=- (999)))
  FREE RECORD dum_utc_data
  RECORD dum_utc_data(
    1 schema_date = dq8
    1 uptime_run_id = f8
    1 downtime_run_id = f8
    1 appl_id = vc
    1 in_process = i2
    1 status = vc
    1 status_desc = vc
    1 schema_changed = i2
    1 offset = i4
    1 dst_ind = i2
    1 mig_utc_pkg_instll_ind = i2
  )
  SET dum_utc_data->uptime_run_id = 0.0
  SET dum_utc_data->downtime_run_id = 0.0
  SET dum_utc_data->appl_id = "DM2NOTSET"
  SET dum_utc_data->in_process = 0
  SET dum_utc_data->status = "DM2NOTSET"
  SET dum_utc_data->status_desc = "DM2NOTSET"
  SET dum_utc_data->schema_changed = 0
  SET dum_utc_data->offset = 0
  SET dum_utc_data->dst_ind = 0
  SET dum_utc_data->mig_utc_pkg_instll_ind = 0
 ENDIF
 IF ((validate(dus_dst_accept->cnt,- (999))=- (999)))
  FREE RECORD dus_dst_accept
  RECORD dus_dst_accept(
    1 cnt = i4
    1 start_year = i4
    1 end_year = i4
    1 method = vc
    1 qual[*]
      2 year = vc
      2 start_dt_tm = dq8
      2 end_dt_tm = dq8
  )
  SET dus_dst_accept->method = "DM2NOTSET"
 ENDIF
 IF ((validate(dus_user_list->own_cnt,- (1))=- (1))
  AND (validate(dus_user_list->own_cnt,- (2))=- (2)))
  FREE RECORD dus_user_list
  RECORD dus_user_list(
    1 own_cnt = i2
    1 own[*]
      2 owner_name = vc
    1 cnt = i2
    1 qual[*]
      2 owner_name = vc
      2 table_name = vc
  )
  SET dus_user_list->own_cnt = 0
  SET dus_user_list->cnt = 0
 ENDIF
 IF ((validate(dum_utc_invalid_tables->cnt,- (999))=- (999)))
  FREE RECORD dum_utc_invalid_tables
  RECORD dum_utc_invalid_tables(
    1 cnt = i4
    1 qual[*]
      2 table_name = vc
  )
  SET dum_utc_invalid_tables->cnt = 0
 ENDIF
 IF ((validate(dus_std_convert_list->tbl_cnt,- (999))=- (999)))
  FREE RECORD dus_std_convert_list
  RECORD dus_std_convert_list(
    1 tbl_cnt = i2
    1 tbl[*]
      2 table_name = vc
      2 col_cnt = i4
      2 col[*]
        3 column_name = vc
        3 no_convert_ind = i2
  )
  SET dus_std_convert_list->tbl_cnt = 0
 ENDIF
 IF ((validate(dus_date_cols->cnt,- (999))=- (999)))
  FREE RECORD dus_date_cols
  RECORD dus_date_cols(
    1 cnt = i4
    1 qual[*]
      2 tbl_name = vc
      2 col_name = vc
      2 tbl_col_name = vc
      2 dt_type_flag = i2
  )
  SET dus_date_cols->cnt = 0
 ENDIF
 IF ((validate(dus_adm_date_cols->cnt,- (999))=- (999)))
  FREE RECORD dus_adm_date_cols
  RECORD dus_adm_date_cols(
    1 cnt = i4
    1 qual[*]
      2 tbl_name = vc
      2 col_name = vc
      2 tbl_col_name = vc
      2 dt_type_flag = i2
  )
  SET dus_adm_date_cols->cnt = 0
 ENDIF
 IF ((validate(dus_v500_cust->tbl_cnt,- (999))=- (999)))
  FREE RECORD dus_v500_cust
  RECORD dus_v500_cust(
    1 tbl_cnt = i4
    1 tbl[*]
      2 table_name = vc
  )
  SET dus_v500_cust->tbl_cnt = 0
 ENDIF
 DECLARE dum_check_concurrent_snapshot(dcc_mode=c1) = i2
 DECLARE dum_generate_schema_execution_script(dgs_run_id=f8,dgs_pswd=vc,dgs_constr=vc,dgs_file_name=
  vc(ref)) = i2
 DECLARE dum_stop_conversion_runner(dsc_appl_id=vc) = i2
 DECLARE dum_cleanup_stranded_appl_id(null) = i2
 DECLARE dum_check_for_new_run_id(dcf_run_id=f8,dcf_new_id_fnd=i2(ref),dcf_dbname=vc) = i2
 DECLARE dum_auto_dst_date(dadd_beg_year=i4,dadd_end_year=i4) = i2
 DECLARE dum_gen_auto_dst_file(null) = i2
 DECLARE dum_disp_dst_rpt(null) = i2
 DECLARE dum_set_timezone(dst_timezone_name=vc(ref)) = i2
 DECLARE dum_fill_user_list(dful_dbname=vc) = i2
 DECLARE ducm_status_chk(dsc_dbname=vc) = i2
 DECLARE dus_load_spec_cols(dlsc_dbname=vc) = i2
 DECLARE dum_mng_spec_cols(dmsc_dbname=vc) = i2
 DECLARE dum_load_date_columns(dldc_mode=vc,dldc_dbname=vc) = i2
 DECLARE dum_fill_v500_cust(dfvc_dbname=vc) = i2
 DECLARE dum_cust_incl_abort_gen(dciag_tgt_dbname=vc,dciag_src_orcl_ver=vc,dciag_tgt_orcl_ver=vc) =
 i2
 DECLARE dum_daylight_offset = i4 WITH protect, noconstant(0)
 DECLARE dum_offset_sign = c1 WITH protect, noconstant(" ")
 SUBROUTINE dum_check_concurrent_snapshot(dcc_mode)
   DECLARE dcc_appl_id = vc WITH protect, noconstant(" ")
   DECLARE dcc_appl_status = vc WITH protect, noconstant(" ")
   IF (cnvtupper(dcc_mode)="I")
    SET dm_err->eproc = "Determining if another upgrade process is running."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DM2 INSTALL PROCESS"
      AND di.info_name="CONCURRENCY CHECKPOINT"
     DETAIL
      dcc_appl_id = di.info_char
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual > 0)
     IF ((dcc_appl_id=dum_utc_data->appl_id))
      SET dm_err->eproc = "Deleting concurrency row from dm_info - same application is restart mode."
      CALL disp_msg(" ",dm_err->logfile,0)
      DELETE  FROM dm_info di
       WHERE di.info_domain="DM2 INSTALL PROCESS"
        AND di.info_name="CONCURRENCY CHECKPOINT"
       WITH nocounter
      ;end delete
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN(0)
      ELSE
       COMMIT
      ENDIF
     ELSE
      SET dm_err->eproc = "Determining if upgrade process found in dm_info is still active."
      CALL disp_msg(" ",dm_err->logfile,0)
      SET dcc_appl_status = dm2_get_appl_status(dcc_appl_id)
      IF (dcc_appl_status="E")
       RETURN(0)
      ELSE
       IF (dcc_appl_status="A")
        SET dm_err->err_ind = 1
        SET dm_err->emsg = "Another upgrade process is currently taking a schema snapshot."
        SET dm_err->eproc = "Determining if upgrade process found in dm_info is still active."
        SET dm_err->user_action = "Please wait until other process completes and try again."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        RETURN(0)
       ELSE
        SET dm_err->eproc = "Deleting concurrency row from dm_info - process inactive."
        CALL disp_msg(" ",dm_err->logfile,0)
        DELETE  FROM dm_info di
         WHERE di.info_domain="DM2 INSTALL PROCESS"
          AND di.info_name="CONCURRENCY CHECKPOINT"
         WITH nocounter
        ;end delete
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         ROLLBACK
         RETURN(0)
        ELSE
         COMMIT
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    SET is_snapshot_dt_tm = cnvtdatetime(curdate,curtime3)
    IF ((dm_err->debug_flag > 0))
     CALL echo(build("Time of snapshot = ",format(is_snapshot_dt_tm,"mm/dd/yyyy hh:mm:ss;;d")))
    ENDIF
    SET dm_err->eproc = "Inserting concurrency row in dm_info."
    CALL disp_msg(" ",dm_err->logfile,0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2 INSTALL PROCESS", di.info_name = "CONCURRENCY CHECKPOINT", di
      .info_char = currdbhandle,
      di.info_date = cnvtdatetime(is_snapshot_dt_tm), di.updt_applctx = 0, di.updt_cnt = 0,
      di.updt_id = 0, di.updt_task = 0
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ELSE
    SET dm_err->eproc = "Deleting concurrency row from dm_info."
    CALL disp_msg(" ",dm_err->logfile,0)
    DELETE  FROM dm_info di
     WHERE di.info_domain="DM2 INSTALL PROCESS"
      AND di.info_name="CONCURRENCY CHECKPOINT"
     WITH nocounter
    ;end delete
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_generate_schema_execution_script(dgs_run_id,dgs_pswd,dgs_constr,dgs_file_name)
   DECLARE dgs_file_loc = vc WITH protect, noconstant(" ")
   DECLARE dgs_str1 = vc WITH protect, noconstant(" ")
   DECLARE dgs_str2 = vc WITH protect, noconstant(" ")
   DECLARE dgs_str3 = vc WITH protect, noconstant(" ")
   DECLARE dgs_str4 = vc WITH protect, noconstant(" ")
   DECLARE dgs_str5 = vc WITH protect, noconstant(" ")
   DECLARE dgs_str6 = vc WITH protect, constant(logical("cer_exe"))
   DECLARE dgs_debug_flag = vc WITH protect, noconstant(" ")
   DECLARE dgs_rdbdebug_flag = i2 WITH protect, noconstant(0)
   DECLARE dgs_rdbbind_flag = i2 WITH protect, noconstant(0)
   SET dgs_rdbdebug_flag = trace("RDBDEBUG")
   SET dgs_rdbbind_flag = trace("RDBBIND")
   IF (cursys="AIX")
    SET dgs_file_name = build("ccluserdir:dm2_utc_main_runner_runid",cnvtint(dgs_run_id),".ksh")
   ELSEIF (cursys="AXP")
    SET dgs_file_name = build("ccluserdir:dm2_utc_main_runner_runid",cnvtint(dgs_run_id),".com")
   ENDIF
   SET dgs_debug_flag = cnvtstring(dm_err->debug_flag)
   SET dm_err->eproc = concat("Generate script ",dgs_file_name)
   CALL disp_msg("",dm_err->logfile,0)
   FREE SET dgs_file_loc
   SET logical dgs_file_loc value(dgs_file_name)
   SELECT INTO dgs_file_loc
    FROM (dummyt t  WITH seq = 1)
    DETAIL
     dgs_str1 = concat("Executing schema for run id ",cnvtstring(dgs_run_id)), dgs_str2 =
     "free define oraclesystem go"
     IF (dgs_constr > " ")
      dgs_str3 = concat("define oraclesystem 'v500/",dgs_pswd,"@",dgs_constr,"' go")
     ELSE
      dgs_str3 = concat("define oraclesystem 'v500/",dgs_pswd,"' go")
     ENDIF
     dgs_str4 = concat("execute dm2_utc_execute_schema ",cnvtstring(dgs_run_id)," go")
     IF (cursys="AIX")
      col 0, "#!/usr/bin/ksh", row + 1,
      col 0, "#", row + 1,
      dgs_str5 = concat("# ",trim(dgs_str1)), col 0, dgs_str5,
      row + 1, col 0, "#",
      row + 1, col 0, ". $cer_mgr/",
      CALL print(trim(cnvtlower(logical("environment")))), "_environment.ksh", row + 1,
      col 0, "ccl <<!", row + 1,
      col 0, dgs_str2, row + 1,
      col 0, dgs_str3, row + 1,
      col 0, "set dm2_debug_flag = ", dgs_debug_flag,
      " go", row + 1
      IF (dgs_rdbdebug_flag=1)
       col 0, "set trace rdbdebug go", row + 1
      ENDIF
      IF (dgs_rdbbind_flag=1)
       col 0, "set trace rdbbind go", row + 1
      ENDIF
      row + 1, col 0, "set dm2_utc_process_option = '",
      dm2_install_schema->process_option, "' go", row + 1,
      col 0, dgs_str4, row + 1,
      col 0, dgs_str2, row + 1,
      col 0, "exit", row + 1,
      col 0, "!", row + 1,
      col 0, "sleep 30"
     ELSEIF (cursys="AXP")
      col 0, "$!", row + 1,
      dgs_str5 = concat("$! ",trim(dgs_str1)), col 0, dgs_str5,
      row + 1, col 0, "$!",
      row + 1, col 0, '$CCL :== "$CER_EXE:CCLORA.EXE"',
      row + 1, col 0, "$CCL",
      row + 1, col 0, dgs_str2,
      row + 1, col 0, dgs_str3,
      row + 1, col 0, "set dm2_debug_flag = ",
      dgs_debug_flag, " go", row + 1
      IF (dgs_rdbdebug_flag=1)
       col 0, "set trace rdbdebug go", row + 1
      ENDIF
      IF (dgs_rdbbind_flag=1)
       col 0, "set trace rdbbind go", row + 1
      ENDIF
      row + 1, col 0, "set dm2_utc_process_option = '",
      dm2_install_schema->process_option, "' go", row + 1,
      col 0, dgs_str4, row + 1,
      col 0, "exit", row + 1,
      col 0, "$WAIT 00:00:30"
     ENDIF
    FOOT REPORT
     row + 0
    WITH nocounter, maxrow = 1, format = variable,
     formfeed = none
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_stop_conversion_runner(dsc_appl_id)
   SET dm_err->eproc = concat("Stop conversion runners ",dsc_appl_id)
   CALL disp_msg("",dm_err->logfile,0)
   DECLARE dsc_runner_active = i2 WITH protect, noconstant(0)
   DECLARE dsc_app_str = vc WITH protect, noconstant(" ")
   DECLARE dsc_app_status = c1 WITH protect, noconstant(" ")
   IF ( NOT (dsc_appl_id IN ("ALL", "PARALLEL", "MAIN")))
    SET dsc_app_status = dm2_get_appl_status(dsc_appl_id)
    IF (dsc_app_status="I")
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Stop conversion runners ",dsc_appl_id)
     SET dm_err->emsg = concat("Application ID ",dsc_appl_id," passed in is inactive.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (dsc_app_status="E")
     RETURN(0)
    ENDIF
   ENDIF
   IF (dsc_appl_id="ALL")
    SET dm_err->eproc = "Get application ids need to be inactivated for all UTC conversion runners."
    SELECT INTO "nl:"
     d.info_name
     FROM dm_info d
     WHERE d.info_domain="DM2_UTC_SCHEMA_RUNNER"
     HEAD REPORT
      row + 0
     DETAIL
      dsc_app_str = concat(dsc_app_str,"'",trim(d.info_name),"',")
     FOOT REPORT
      dsc_app_str = replace(dsc_app_str,",","",2)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (curqual=0)
     RETURN(1)
    ENDIF
    SET dm_err->eproc = "Inactivate application ids for all UTC conversion runners."
    UPDATE  FROM dm_info di
     SET di.info_number = 0
     WHERE di.info_domain="DM2_UTC_SCHEMA_RUNNER"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ELSEIF (dsc_appl_id="PARALLEL")
    SET dm_err->eproc =
    "Get application ids need to be inactivated for parallel UTC conversion runners."
    SELECT INTO "nl:"
     d.info_name
     FROM dm_info d
     WHERE d.info_domain="DM2_UTC_SCHEMA_RUNNER"
      AND d.info_char="PARALLEL_RUNNER"
     HEAD REPORT
      row + 0
     DETAIL
      dsc_app_str = concat(dsc_app_str,"'",trim(d.info_name),"',")
     FOOT REPORT
      dsc_app_str = replace(dsc_app_str,",","",2)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (curqual=0)
     RETURN(1)
    ENDIF
    SET dm_err->eproc = "Inactivate application ids for parallel UTC conversion runners."
    UPDATE  FROM dm_info di
     SET di.info_number = 0
     WHERE di.info_domain="DM2_UTC_SCHEMA_RUNNER"
      AND di.info_char="PARALLEL_RUNNER"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ELSEIF (dsc_appl_id="MAIN")
    SET dm_err->eproc = "Get application ids need to be inactivated for main UTC conversion runners."
    SELECT INTO "nl:"
     d.info_name
     FROM dm_info d
     WHERE d.info_domain="DM2_UTC_SCHEMA_RUNNER"
      AND d.info_char="MAIN_RUNNER"
     HEAD REPORT
      row + 0
     DETAIL
      dsc_app_str = concat(dsc_app_str,"'",trim(d.info_name),"',")
     FOOT REPORT
      dsc_app_str = replace(dsc_app_str,",","",2)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (curqual=0)
     RETURN(1)
    ENDIF
    SET dm_err->eproc = "Inactivate application ids for main UTC conversion runners."
    UPDATE  FROM dm_info di
     SET di.info_number = 0
     WHERE di.info_domain="DM2_UTC_SCHEMA_RUNNER"
      AND di.info_char="MAIN_RUNNER"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ELSE
    SET dm_err->eproc = "Get application id need to be inactivated."
    SELECT INTO "nl:"
     d.info_name
     FROM dm_info d
     WHERE d.info_domain="DM2_UTC_SCHEMA_RUNNER"
      AND d.info_name=dsc_appl_id
     HEAD REPORT
      row + 0
     DETAIL
      dsc_app_str = concat(dsc_app_str,"'",trim(d.info_name),"',")
     FOOT REPORT
      dsc_app_str = replace(dsc_app_str,",","",2)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (curqual=0)
     RETURN(1)
    ENDIF
    SET dm_err->eproc = concat("Inactivate application id ",dsc_appl_id,".")
    UPDATE  FROM dm_info di
     SET di.info_number = 0
     WHERE di.info_domain="DM2_UTC_SCHEMA_RUNNER"
      AND di.info_name=dsc_appl_id
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   SET dsc_runner_active = 1
   WHILE (dsc_runner_active=1)
     IF (dum_cleanup_stranded_appl_id(null)=0)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = concat("Verify application id ",dsc_app_str," have been removed.")
     SELECT INTO "nl:"
      FROM dm_info di
      WHERE di.info_domain="DM2_UTC_SCHEMA_RUNNER"
       AND parser(concat("di.info_name in (",dsc_app_str,")"))
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (curqual > 0)
      CALL echo("**************************************************")
      CALL echo(
       "Waiting on current DDL operations the conversion runner(s) is working on to finish executing..."
       )
      CALL echo("**************************************************")
      CALL pause(15)
     ELSE
      SET dsc_runner_active = 0
     ENDIF
   ENDWHILE
   IF (dsc_appl_id IN ("ALL", "PARALLEL", "MAIN"))
    SET dm_err->eproc = concat("Stopped ",dsc_appl_id," UTC conversion runners successfully.")
   ELSE
    SET dm_err->eproc = concat("Stopped UTC conversion runner with application id ",dsc_appl_id,
     " successfully.")
   ENDIF
   CALL disp_msg("",dm_err->logfile,0)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_cleanup_stranded_appl_id(null)
   SET dm_err->eproc = "Remove inactive application id for UTC Conversion runners."
   CALL disp_msg("",dm_err->logfile,0)
   FREE RECORD dcs_app
   RECORD dcs_app(
     1 cnt = i4
     1 qual[*]
       2 app_id = vc
       2 active_ind = i2
   )
   DECLARE dcs_app_status = c1 WITH protect, noconstant(" ")
   DECLARE dcs_inactive_fnd = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Query dm_info for a distinct list of application ids."
   SELECT DISTINCT INTO "nl:"
    di.info_name
    FROM dm_info di
    WHERE di.info_domain="DM2_UTC_SCHEMA_RUNNER"
    HEAD REPORT
     dcs_app->cnt = 0
    DETAIL
     dcs_app->cnt = (dcs_app->cnt+ 1)
     IF (mod(dcs_app->cnt,10)=1)
      stat = alterlist(dcs_app->qual,(dcs_app->cnt+ 9))
     ENDIF
     dcs_app->qual[dcs_app->cnt].app_id = trim(di.info_name), dcs_app->qual[dcs_app->cnt].active_ind
      = 0
    FOOT REPORT
     stat = alterlist(dcs_app->qual,dcs_app->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   FOR (dcs_i = 1 TO dcs_app->cnt)
    SET dcs_app_status = dm2_get_appl_status(dcs_app->qual[dcs_i].app_id)
    IF (dcs_app_status="A")
     SET dcs_app->qual[dcs_i].active_ind = 1
    ELSEIF (dcs_app_status="I")
     SET dcs_inactive_fnd = 1
    ELSEIF (dcs_app_status="E")
     RETURN(0)
    ENDIF
   ENDFOR
   IF (dcs_inactive_fnd=1)
    SET dm_err->eproc = "Delete inactive application id from DM_INFO table."
    DELETE  FROM dm_info di,
      (dummyt t  WITH seq = value(dcs_app->cnt))
     SET di.seq = 1
     PLAN (t
      WHERE (dcs_app->qual[t.seq].active_ind=0))
      JOIN (di
      WHERE di.info_domain="DM2_UTC_SCHEMA_RUNNER"
       AND (di.info_name=dcs_app->qual[t.seq].app_id))
     WITH nocounter
    ;end delete
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_check_for_new_run_id(dcf_run_id,dcf_new_id_fnd,dcf_dbname)
   DECLARE dcf_max_run_id = f8 WITH protect, noconstant(0.0)
   SET dcf_new_id_fnd = 0
   SET dm_err->eproc = build("Find max run_id that is greater than ",dcf_run_id,
    " in DM2_DDL_OPS table.")
   SELECT
    IF ((dm2_install_schema->process_option="MIGRATION/UTC"))
     FROM dm2_ddl_ops@ref_data_link d
     ORDER BY d.run_id
    ELSE
     FROM dm2_ddl_ops d
     WHERE d.run_id > dcf_run_id
     ORDER BY d.run_id
    ENDIF
    INTO "nl:"
    HEAD REPORT
     row + 0
    FOOT REPORT
     dcf_max_run_id = d.run_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dm_err->eproc = "Determine if new_run_id is found."
    SELECT INTO "nl:"
     FROM dm2_admin_dm_info di
     WHERE di.info_domain=patstring(cnvtupper(build(dcf_dbname,"_UTC_DATA")))
      AND di.info_name="POST_UTC_RUN_IDS"
      AND di.info_number >= dcf_max_run_id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET dcf_new_id_fnd = 1
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_auto_dst_date(dadd_beg_year,dadd_end_year)
   DECLARE dadd_spr_beg_month = vc WITH protect, constant("MAR")
   DECLARE dadd_spr_end_month = i2 WITH protect, constant(6)
   DECLARE dadd_fall_beg_month = vc WITH protect, constant("SEP")
   DECLARE dadd_fall_end_month = i2 WITH protect, constant(12)
   DECLARE dadd_continue = i2 WITH protect, noconstant(0)
   DECLARE dadd_loop = i2 WITH protect, noconstant(0)
   DECLARE dadd_fnd_dst_beg = i2 WITH protect, noconstant(0)
   DECLARE dadd_fnd_dst_end = i2 WITH protect, noconstant(0)
   DECLARE dadd_temp_year = i2 WITH protect, noconstant(0)
   DECLARE dadd_beg_date = dq8 WITH protect, noconstant(0.0)
   DECLARE dadd_end_date = dq8 WITH protect, noconstant(0.0)
   DECLARE dadd_hr1 = i2 WITH protect, noconstant(0)
   DECLARE dadd_hr2 = i2 WITH protect, noconstant(0)
   SET dus_dst_accept->cnt = 0
   SET stat = alterlist(dus_dst_accept->qual,0)
   SET dus_dst_accept->start_year = dadd_beg_year
   SET dus_dst_accept->end_year = dadd_end_year
   SET dus_dst_accept->method = "AUTO_DETECT"
   SET dadd_continue = 1
   SET dadd_temp_year = dadd_beg_year
   SET dm_err->eproc = "Auto detecting DST datetime range."
   IF ((dm_err->debug_flag > 0))
    SET message = nowindow
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   WHILE (dadd_continue=1)
     IF ((dm_err->debug_flag > 0))
      CALL echo("-----------------------------------------------------------------")
      CALL echo(concat(trim(cnvtstring(dadd_temp_year)),"..."))
     ENDIF
     SET dadd_loop = 1
     SET dadd_fnd_dst_beg = 0
     SET dadd_beg_date = cnvtdatetime(build("01-",trim(dadd_spr_beg_month),"-",dadd_temp_year,
       " 00:00:00"))
     WHILE (dadd_loop=1)
      IF (cnvtdatetimeutc(dadd_beg_date,3)=cnvtdatetimeutc(cnvtlookahead("1,H",cnvtdatetimeutc(
         dadd_beg_date,0)),3))
       SET dadd_fnd_dst_beg = 1
       SET dadd_loop = 0
       IF ((dm_err->debug_flag > 0))
        CALL echo(concat("  Local Start Date: ",format(cnvtdatetime(dadd_beg_date),";;q")))
        CALL echo(concat("  Local Start Date (UTC): ",format(cnvtdatetimeutc(dadd_beg_date,3),";;q"))
         )
        CALL echo(concat("  Local Start Date +1 hour (UTC): ",format(cnvtdatetimeutc(cnvtlookahead(
             "1,H",cnvtdatetimeutc(dadd_beg_date,0)),3),";;q")))
       ENDIF
       SET dadd_beg_date = cnvtlookahead("1,H",cnvtdatetimeutc(dadd_beg_date,0))
      ENDIF
      IF (dadd_fnd_dst_beg=0)
       SET dadd_beg_date = cnvtlookahead("1,H",cnvtdatetimeutc(dadd_beg_date,0))
       IF (month(dadd_beg_date)=dadd_spr_end_month)
        SET dadd_loop = 0
       ENDIF
      ENDIF
     ENDWHILE
     SET dadd_loop = 1
     SET dadd_fnd_dst_end = 0
     SET dadd_end_date = cnvtdatetime(build("02-",trim(dadd_fall_beg_month),"-",dadd_temp_year,
       " 00:00:00"))
     IF (dadd_fnd_dst_beg=1)
      WHILE (dadd_loop=1)
        SET dadd_hr1 = hour(cnvtdatetimeutc(cnvtlookahead("1,H",cnvtdatetimeutc(dadd_end_date,0)),3))
        SET dadd_hr2 = hour(cnvtdatetimeutc(dadd_end_date,3))
        IF (((dadd_hr1 - dadd_hr2)=2))
         SET dadd_fnd_dst_end = 1
         SET dadd_loop = 0
         IF ((dm_err->debug_flag > 0))
          CALL echo(concat("  Local End Date: ",format(cnvtdatetime(dadd_end_date),";;q")))
          CALL echo(concat("  Local End Date (UTC): ",format(cnvtdatetimeutc(dadd_end_date,3),";;q"))
           )
          CALL echo(concat("  Local End Date +1 hour (UTC): ",format(cnvtdatetimeutc(cnvtlookahead(
               "1,H",cnvtdatetimeutc(dadd_end_date,0)),3),";;q")))
         ENDIF
         SET dadd_end_date = cnvtlookahead("1,H",cnvtdatetimeutc(dadd_end_date,0))
         SET dadd_end_date = cnvtlookbehind("1,S",cnvtdatetimeutc(dadd_end_date,0))
        ENDIF
        IF (dadd_fnd_dst_end=0)
         SET dadd_end_date = cnvtlookahead("1,H",cnvtdatetimeutc(dadd_end_date,0))
         IF (month(dadd_end_date)=dadd_fall_end_month)
          SET dadd_loop = 0
         ENDIF
        ENDIF
      ENDWHILE
     ENDIF
     IF (dadd_fnd_dst_beg=1
      AND dadd_fnd_dst_end=1)
      SET dus_dst_accept->cnt = (dus_dst_accept->cnt+ 1)
      SET stat = alterlist(dus_dst_accept->qual,dus_dst_accept->cnt)
      SET dus_dst_accept->qual[dus_dst_accept->cnt].year = trim(cnvtstring(dadd_temp_year))
      SET dus_dst_accept->qual[dus_dst_accept->cnt].start_dt_tm = dadd_beg_date
      SET dus_dst_accept->qual[dus_dst_accept->cnt].end_dt_tm = dadd_end_date
      IF ((dm_err->debug_flag > 0))
       CALL echo(concat(trim(cnvtstring(dadd_temp_year)),"...DST starts at ",format(cnvtdatetime(
           dadd_beg_date),";;q")," and ends at ",format(cnvtdatetime(dadd_end_date),";;q")))
      ENDIF
     ELSEIF (dadd_fnd_dst_beg=0
      AND dadd_fnd_dst_end=0)
      IF ((dm_err->debug_flag > 0))
       CALL echo(concat(trim(cnvtstring(dadd_temp_year)),"...did not observe DST during this year"))
      ENDIF
     ELSE
      SET dm_err->err_ind = 1
      SET dm_err->emsg = concat("Failed to find DST end datetime for year ",trim(cnvtstring(
         dadd_temp_year))," when DST begin datetime is found.")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (dadd_temp_year=dadd_end_year)
      SET dadd_continue = 0
     ELSE
      SET dadd_temp_year = (dadd_temp_year+ 1)
     ENDIF
   ENDWHILE
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(dus_dst_accept)
   ENDIF
   IF ((dus_dst_accept->cnt > 0))
    IF (dum_gen_auto_dst_file(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_gen_auto_dst_file(null)
   DECLARE dgadf_file_name = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dgadf_str = vc WITH protect, noconstant("")
   IF (get_unique_file("dm2_utc_dst_input",".dat")=0)
    RETURN(0)
   ENDIF
   SET dgadf_file_name = concat(dm2_install_schema->ccluserdir,dm_err->unique_fname)
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("file_name = ",dgadf_file_name))
   ENDIF
   SET dm_err->eproc = concat("Generate file ",dgadf_file_name,".")
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO value(dgadf_file_name)
    FROM (dummyt t  WITH seq = 1)
    HEAD REPORT
     cnt = 0
    DETAIL
     col 0, "YEAR,START_DT_TM,END_DT_TM", row + 1
     FOR (cnt = 1 TO dus_dst_accept->cnt)
       dgadf_str = concat(dus_dst_accept->qual[cnt].year,",",format(cnvtdatetime(dus_dst_accept->
          qual[cnt].start_dt_tm),"DD-MMM-YYYY HH:MM:SS;;D"),",",format(cnvtdatetime(dus_dst_accept->
          qual[cnt].end_dt_tm),"DD-MMM-YYYY HH:MM:SS;;D"))
       IF ((dm_err->debug_flag > 0))
        CALL echo(dgadf_str)
       ENDIF
       col 0, dgadf_str, row + 1
     ENDFOR
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_disp_dst_rpt(dddr_timezone_name)
   DECLARE dddr_str = vc WITH protect, noconstant(" ")
   SET dm_err->eproc = "UTC Conversion Daylight Savings Time Setting Confirmation"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO mine
    FROM (dummyt d  WITH seq = value(dus_dst_accept->cnt))
    ORDER BY dus_dst_accept->qual[d.seq].year
    HEAD REPORT
     col 0, "UTC Conversion Daylight Savings Time Setting Confirmation", row + 2,
     col 0, "TIME ZONE : ", col 13,
     dddr_timezone_name, col 50, "STANDARD OFFSET : ",
     dddr_str = concat(dum_offset_sign,format(cnvttime(abs(dum_utc_data->offset)),"HH:MM;;M")), col
     68, dddr_str,
     row + 2, col 0,
     "Please scroll through each Daylight Savings Time (DST) begin and end date/times and review for accuracy.",
     row + 2, col 0, "YEAR",
     col 10, "DST Begin Date Time", col 40,
     "DST End Date Time", row + 1
    DETAIL
     col 0, dus_dst_accept->qual[d.seq].year, dddr_str = format(dus_dst_accept->qual[d.seq].
      start_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D"),
     col 10, dddr_str, dddr_str = format(dus_dst_accept->qual[d.seq].end_dt_tm,
      "DD-MMM-YYYY HH:MM:SS;;D"),
     col 40, dddr_str, row + 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_set_timezone(dst_timezone_name)
   SET dst_timezone_name = datetimezonebyindex(curtimezonesys,dum_utc_data->offset,
    dum_daylight_offset)
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("dst_timezone_name = ",dst_timezone_name))
   ENDIF
   IF (dst_timezone_name=" "
    AND (dum_utc_data->offset=0))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Failed to retrieve Time Zone Name."
    SET dm_err->emsg =
    "Problem with ccl version or the curtimezonesys variable does not have a valid timezone index."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    SET dum_utc_data->offset = ((dum_utc_data->offset/ 1000)/ 60)
    IF ((dum_utc_data->offset < 0))
     SET dum_offset_sign = "-"
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL echo(build("offset = ",dum_utc_data->offset))
     CALL echo(concat(dum_offset_sign,format(cnvttime(abs(dum_utc_data->offset)),"HH:MM;;M")))
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_fill_user_list(dful_dbname)
   DECLARE dum_pos = i4 WITH protect, noconstant(0)
   DECLARE dum_loc = i4 WITH protect, noconstant(0)
   DECLARE dum_own_name = vc WITH protect, noconstant(" ")
   DECLARE dum_tbl_name = vc WITH protect, noconstant(" ")
   SET dus_user_list->own_cnt = 1
   SET stat = alterlist(dus_user_list->own,dus_user_list->own_cnt)
   SET dus_user_list->own[dus_user_list->own_cnt].owner_name = "V500"
   SET dm_err->eproc = "Loading Non-V500 Users and tables from dm_info."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info di
    WHERE di.info_domain=patstring(cnvtupper(build(dful_dbname,
       "_UTC_DATA - NON-V500 USERS AND TABLES LIST")))
    DETAIL
     dum_loc = findstring("/",di.info_name,1,1)
     IF (dum_loc=0)
      dm_err->err_ind = 1, dm_err->emsg =
      "Missing / in dm2_admin_dm_info row. Valid dm2_admin_dm_info row format is USER/TABLE.",
      CALL cancel(1)
     ENDIF
     dum_own_name = substring(1,(dum_loc - 1),di.info_name), dum_tbl_name = substring((dum_loc+ 1),
      size(di.info_name),di.info_name), dum_pos = 0,
     dum_pos = locateval(dum_pos,1,dus_user_list->own_cnt,trim(cnvtupper(dum_own_name)),dus_user_list
      ->own[dum_pos].owner_name)
     IF (dum_pos=0)
      dus_user_list->own_cnt = (dus_user_list->own_cnt+ 1), stat = alterlist(dus_user_list->own,
       dus_user_list->own_cnt), dus_user_list->own[dus_user_list->own_cnt].owner_name = dum_own_name
     ENDIF
     dus_user_list->cnt = (dus_user_list->cnt+ 1), stat = alterlist(dus_user_list->qual,dus_user_list
      ->cnt), dus_user_list->qual[dus_user_list->cnt].owner_name = dum_own_name,
     dus_user_list->qual[dus_user_list->cnt].table_name = dum_tbl_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(dus_user_list)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ducm_status_chk(dsc_dbname)
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info di
    WHERE di.info_domain=patstring(cnvtupper(build(dsc_dbname,"_UTC_DATA")))
     AND di.info_name="SOURCE*"
    DETAIL
     dsc_info_name = di.info_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) > 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Check for Source Environment/Database ADMIN dm_info row."
    SET dm_err->emsg = "Info_name for Source Environment/Database ADMIN dm_info row does not exist."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dus_load_spec_cols(dlsc_dbname)
   DECLARE dls_tbl_name = vc WITH protect, noconstant(" ")
   DECLARE dls_col_name = vc WITH protect, noconstant(" ")
   DECLARE dls_pos = i4 WITH protect, noconstant(0)
   DECLARE dls_tbl_idx = i4 WITH protect, noconstant(0)
   DECLARE dls_col_cnt = i4 WITH protect, noconstant(0)
   SET dus_std_convert_list->tbl_cnt = 0
   SET stat = alterlist(dus_std_convert_list->tbl,dus_std_convert_list->tbl_cnt)
   SET dm_err->eproc =
   "Load V500 table/columns requiring special conversion logic from ADMIN DM_INFO table to record."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info i
    WHERE i.info_domain=patstring(cnvtupper(build(dlsc_dbname,"_UTC_DATA - APPLY STD CONVERSION ONLY"
       )))
    HEAD REPORT
     dls_tbl_idx = 0
    DETAIL
     dls_pos = findstring("/",i.info_name,1,1), dls_tbl_name = substring(1,(dls_pos - 1),i.info_name),
     dls_col_name = substring((dls_pos+ 1),size(i.info_name),i.info_name),
     dls_tbl_idx = 0, dls_tbl_idx = locateval(dls_tbl_idx,1,dus_std_convert_list->tbl_cnt,
      dls_tbl_name,dus_std_convert_list->tbl[dls_tbl_idx].table_name)
     IF (dls_tbl_idx=0)
      dus_std_convert_list->tbl_cnt = (dus_std_convert_list->tbl_cnt+ 1)
      IF (mod(dus_std_convert_list->tbl_cnt,10)=1)
       stat = alterlist(dus_std_convert_list->tbl,(dus_std_convert_list->tbl_cnt+ 9))
      ENDIF
      dus_std_convert_list->tbl[dus_std_convert_list->tbl_cnt].table_name = dls_tbl_name,
      dus_std_convert_list->tbl[dus_std_convert_list->tbl_cnt].col_cnt = 1, stat = alterlist(
       dus_std_convert_list->tbl[dus_std_convert_list->tbl_cnt].col,1),
      dus_std_convert_list->tbl[dus_std_convert_list->tbl_cnt].col[1].column_name = dls_col_name,
      dus_std_convert_list->tbl[dus_std_convert_list->tbl_cnt].col[1].no_convert_ind = i.info_number
     ELSE
      dus_std_convert_list->tbl[dls_tbl_idx].col_cnt = (dus_std_convert_list->tbl[dls_tbl_idx].
      col_cnt+ 1), dls_col_cnt = dus_std_convert_list->tbl[dls_tbl_idx].col_cnt, stat = alterlist(
       dus_std_convert_list->tbl[dls_tbl_idx].col,dls_col_cnt),
      dus_std_convert_list->tbl[dls_tbl_idx].col[dls_col_cnt].column_name = dls_col_name,
      dus_std_convert_list->tbl[dls_tbl_idx].col[dls_col_cnt].no_convert_ind = i.info_number
     ENDIF
    FOOT REPORT
     stat = alterlist(dus_std_convert_list->tbl,dus_std_convert_list->tbl_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(dus_std_convert_list)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_mng_spec_cols(dmsc_dbname)
   FREE RECORD load_excl_cols
   RECORD load_excl_cols(
     1 cnt = i4
     1 qual[*]
       2 tbl_col_name = vc
       2 info_char = vc
       2 info_num = i2
   )
   DECLARE dmsc_idx = i4 WITH protect, noconstant(0)
   SET stat = alterlist(load_excl_cols->qual,0)
   SET load_excl_cols->cnt = 0
   SET dm_err->eproc = "Load Admin master V500 table/columns exclusions from ADMIN DM_INFO."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info di
    WHERE di.info_domain=patstring(cnvtupper(build(dmsc_dbname,"_UTC_DATA - MASTER DATE COLUMN LIST")
      ))
     AND di.info_number != 1
    HEAD REPORT
     load_excl_cols->cnt = 0
    DETAIL
     load_excl_cols->cnt = (load_excl_cols->cnt+ 1)
     IF (mod(load_excl_cols->cnt,1000)=1)
      stat = alterlist(load_excl_cols->qual,(load_excl_cols->cnt+ 999))
     ENDIF
     load_excl_cols->qual[load_excl_cols->cnt].tbl_col_name = di.info_name, load_excl_cols->qual[
     load_excl_cols->cnt].info_num = 1, load_excl_cols->qual[load_excl_cols->cnt].info_char =
     "LOADED FROM CSV"
    FOOT REPORT
     stat = alterlist(load_excl_cols->qual,load_excl_cols->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((load_excl_cols->cnt=0))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Verify load of Admin master date list.")
    SET dm_err->emsg = build("Admin master date list does not include any exclusion dates.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Load V500 table/columns exclusions from ADMIN DM_INFO."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info di
    WHERE di.info_domain=patstring(cnvtupper(build(dmsc_dbname,
       "_UTC_DATA - APPLY STD CONVERSION ONLY")))
    HEAD REPORT
     dmsc_idx = 0
    DETAIL
     dmsc_idx = 0, dmsc_idx = locateval(dmsc_idx,1,load_excl_cols->cnt,cnvtupper(di.info_name),
      load_excl_cols->qual[dmsc_idx].tbl_col_name)
     IF (dmsc_idx > 0)
      IF (di.info_number != 1)
       dm_err->err_ind = 1, dm_err->emsg = concat("Invalid Admin DM_INFO row for ",di.info_name,
        "Info_number should always be 1."),
       CALL cancel(1)
      ENDIF
     ELSE
      IF (cnvtupper(di.info_char) != "LOADED FROM CSV")
       load_excl_cols->cnt = (load_excl_cols->cnt+ 1), stat = alterlist(load_excl_cols->qual,
        load_excl_cols->cnt), load_excl_cols->qual[load_excl_cols->cnt].tbl_col_name = di.info_name,
       load_excl_cols->qual[load_excl_cols->cnt].info_num = di.info_number
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(load_excl_cols)
   ENDIF
   SET dm_err->eproc = "Deleting Exclusion rows from Admin DM_INFO."
   CALL disp_msg(" ",dm_err->logfile,0)
   DELETE  FROM dm2_admin_dm_info i
    WHERE i.info_domain=patstring(cnvtupper(build(dmsc_dbname,"_UTC_DATA - APPLY STD CONVERSION ONLY"
       )))
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc) != 0)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Inserting Exclusion rows into Admin DM_INFO."
   CALL disp_msg(" ",dm_err->logfile,0)
   INSERT  FROM dm2_admin_dm_info di,
     (dummyt d  WITH seq = value(size(load_excl_cols->qual,5)))
    SET di.info_domain = patstring(cnvtupper(build(dmsc_dbname,
        "_UTC_DATA - APPLY STD CONVERSION ONLY"))), di.info_name = load_excl_cols->qual[d.seq].
     tbl_col_name, di.info_number = load_excl_cols->qual[d.seq].info_num,
     di.info_char = load_excl_cols->qual[d.seq].info_char, di.updt_dt_tm = cnvtdatetime(curdate,
      curtime3)
    PLAN (d)
     JOIN (di
     WHERE (load_excl_cols->qual[d.seq].tbl_col_name=di.info_name))
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_load_date_columns(dldc_mode,dldc_dbname)
   DECLARE dvdc_csv_loc = vc WITH public, constant(concat(dm2_install_schema->cer_install,
     "dm2_date_column_list.csv"))
   DECLARE dvdc_1st_comma_pos = i2 WITH protect, noconstant(0)
   DECLARE dvdc_2nd_comma_pos = i2 WITH protect, noconstant(0)
   DECLARE dvdc_tbl_name = vc WITH protect, noconstant(" ")
   DECLARE dvdc_col_name = vc WITH protect, noconstant(" ")
   DECLARE dvdc_dt_type_flag = i2 WITH protect, noconstant(0)
   DECLARE dvdc_csv_rows = i4 WITH protect, noconstant(0)
   DECLARE dvdc_adm_rows_fnd = i2 WITH protect, noconstant(0)
   DECLARE dvdc_tbl_col_name = vc WITH protect, noconstant(" ")
   DECLARE dvdc_col_missing_cnt = i4 WITH protect, noconstant(0)
   DECLARE dvdc_col_mismatch_cnt = i4 WITH protect, noconstant(0)
   DECLARE dvdc_col_exists_cnt = i4 WITH protect, noconstant(0)
   DECLARE dvdc_col_missing_adm_cnt = i4 WITH protect, noconstant(0)
   DECLARE dvdc_idx = i4 WITH protect, noconstant(0)
   DECLARE dvdc_loop = i4 WITH protect, noconstant(0)
   DECLARE dvdc_tbl_fnd = i4 WITH protect, noconstant(0)
   DECLARE dvdc_col_fnd = i4 WITH protect, noconstant(0)
   SET stat = alterlist(dus_date_cols->qual,0)
   SET dus_date_cols->cnt = 0
   IF ( NOT (dldc_mode IN ("V", "C", "I", "U")))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Verify load date columns mode entered."
    SET dm_err->emsg = concat("Mode ",dldc_mode," is not valid. Valid modes are V, C, I and U.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dldc_mode IN ("C", "I", "U")
    AND size(trim(dldc_dbname,3))=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Verify load date columns database name entered."
    SET dm_err->emsg = concat("Database name [",trim(dldc_dbname),
     "] is not valid. Must specify value for check/insert/update mode.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Managing master date columns (",evaluate(dldc_mode,"V","VERIFY","C",
     "CHECK",
     "I","INSERT","UPDATE")," Mode).")
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dm2_findfile(dvdc_csv_loc)=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Verify file ",dvdc_csv_loc," exists.")
    SET dm_err->emsg = concat(dvdc_csv_loc," is not found.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Load master date column list from csv ",dvdc_csv_loc," into memory.")
   CALL disp_msg(" ",dm_err->logfile,0)
   FREE DEFINE rtl
   FREE SET file_loc
   SET logical file_loc value(dvdc_csv_loc)
   DEFINE rtl "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtlt r
    HEAD REPORT
     dus_date_cols->cnt = 0
    DETAIL
     dvdc_csv_rows = (dvdc_csv_rows+ 1)
     IF (r.line != "TABLE_NAME,COLUMN_NAME,DATE_TYPE_FLAG"
      AND findstring(",",r.line,1,0) != findstring(",",r.line,1,1))
      dvdc_1st_comma_pos = findstring(",",r.line,1,0), dvdc_tbl_name = trim(cnvtupper(substring(1,(
         dvdc_1st_comma_pos - 1),r.line)),3), dvdc_2nd_comma_pos = findstring(",",r.line,1,1),
      dvdc_col_name = trim(cnvtupper(substring((dvdc_1st_comma_pos+ 1),((dvdc_2nd_comma_pos -
         dvdc_1st_comma_pos) - 1),r.line)),3), dvdc_dt_type_flag = cnvtint(substring((
        dvdc_2nd_comma_pos+ 1),size(r.line),r.line)), dvdc_tbl_col_name = trim(build(dvdc_tbl_name,
        "/",dvdc_col_name)),
      dvdc_idx = 0, dvdc_idx = locateval(dvdc_idx,1,dus_date_cols->cnt,dvdc_tbl_col_name,
       dus_date_cols->qual[dvdc_idx].tbl_col_name)
      IF (dvdc_idx=0)
       dus_date_cols->cnt = (dus_date_cols->cnt+ 1)
       IF (mod(dus_date_cols->cnt,1000)=1)
        stat = alterlist(dus_date_cols->qual,(dus_date_cols->cnt+ 999))
       ENDIF
       dus_date_cols->qual[dus_date_cols->cnt].tbl_name = dvdc_tbl_name, dus_date_cols->qual[
       dus_date_cols->cnt].col_name = dvdc_col_name, dus_date_cols->qual[dus_date_cols->cnt].
       dt_type_flag = dvdc_dt_type_flag,
       dus_date_cols->qual[dus_date_cols->cnt].tbl_col_name = dvdc_tbl_col_name
      ENDIF
     ENDIF
     IF ((dm_err->debug_flag > 4))
      CALL echo(r.line)
     ENDIF
    FOOT REPORT
     stat = alterlist(dus_date_cols->qual,dus_date_cols->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 3))
    CALL echorecord(dus_date_cols)
   ENDIF
   IF ((dus_date_cols->cnt=0))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Verify load of CSV master date list.")
    SET dm_err->emsg = build("CSV file empty.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (((dvdc_csv_rows - 1) != dus_date_cols->cnt))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat(
     "Verify number of rows in CSV matches with the count loaded into record structure.")
    SET dm_err->emsg = build("CSV content invalid or duplicates exist.  CSV count:",(dvdc_csv_rows -
     1)," Record structure count: ",dus_date_cols->cnt)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dldc_mode="V")
    RETURN(1)
   ENDIF
   IF (dldc_mode IN ("C", "I", "U"))
    SET dm_err->eproc = "Load master date column list from ADMIN DM_INFO into memory."
    CALL disp_msg("",dm_err->logfile,0)
    SET stat = alterlist(dus_adm_date_cols->qual,0)
    SET dus_adm_date_cols->cnt = 0
    SELECT INTO "nl:"
     FROM dm2_admin_dm_info di
     WHERE di.info_domain=patstring(cnvtupper(build(dldc_dbname,"_UTC_DATA - MASTER DATE COLUMN LIST"
        )))
     HEAD REPORT
      dus_adm_date_cols->cnt = 0
     DETAIL
      dus_adm_date_cols->cnt = (dus_adm_date_cols->cnt+ 1)
      IF (mod(dus_adm_date_cols->cnt,1000)=1)
       stat = alterlist(dus_adm_date_cols->qual,(dus_adm_date_cols->cnt+ 999))
      ENDIF
      dus_adm_date_cols->qual[dus_adm_date_cols->cnt].tbl_col_name = di.info_name, dus_adm_date_cols
      ->qual[dus_adm_date_cols->cnt].tbl_name = substring(1,(findstring("/",di.info_name,1,1) - 1),di
       .info_name), dus_adm_date_cols->qual[dus_adm_date_cols->cnt].col_name = substring((findstring(
        "/",di.info_name,1,1)+ 1),size(di.info_name),di.info_name),
      dus_adm_date_cols->qual[dus_adm_date_cols->cnt].dt_type_flag = di.info_number
     FOOT REPORT
      stat = alterlist(dus_adm_date_cols->qual,dus_adm_date_cols->cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 2))
     CALL echorecord(dus_adm_date_cols)
    ENDIF
   ENDIF
   IF (dldc_mode IN ("C", "U"))
    IF ((dus_adm_date_cols->cnt=0))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Verify context of master list."
     SET dm_err->emsg = "CHECK and UPDATE mode requires existence of Admin master date list rows."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    FOR (dvdc_loop = 1 TO dus_date_cols->cnt)
      SET dvdc_idx = 0
      SET dvdc_idx = locateval(dvdc_idx,1,dus_adm_date_cols->cnt,dus_date_cols->qual[dvdc_loop].
       tbl_col_name,dus_adm_date_cols->qual[dvdc_idx].tbl_col_name)
      IF (dvdc_idx > 0)
       IF ((dus_date_cols->qual[dvdc_loop].dt_type_flag != dus_adm_date_cols->qual[dvdc_idx].
       dt_type_flag)
        AND (((dus_date_cols->qual[dvdc_loop].dt_type_flag=1)) OR ((dus_adm_date_cols->qual[dvdc_idx]
       .dt_type_flag=1))) )
        SET dm_err->eproc = concat("[UTC Conversion] Table/column date type flag mismatch [",trim(
          dus_date_cols->qual[dvdc_loop].tbl_col_name),"; csv - ",trim(cnvtstring(dus_date_cols->
           qual[dvdc_loop].dt_type_flag)),", admin - ",
         trim(cnvtstring(dus_adm_date_cols->qual[dvdc_idx].dt_type_flag)),"].")
        CALL disp_msg("",dm_err->logfile,0)
        SET dvdc_col_mismatch_cnt = (dvdc_col_mismatch_cnt+ 1)
       ENDIF
      ELSE
       SET dm_err->eproc = concat("[UTC Conversion] Table/column missing [",dus_date_cols->qual[
        dvdc_loop].tbl_col_name,"].")
       CALL disp_msg("",dm_err->logfile,0)
       SET dvdc_col_missing_cnt = (dvdc_col_missing_cnt+ 1)
       IF (dldc_mode="U")
        SET dm_err->eproc = concat("Check db existence of missing master date table/column [",
         dus_date_cols->qual[dvdc_loop].tbl_col_name,"].")
        CALL disp_msg("",dm_err->logfile,0)
        SELECT INTO "nl:"
         FROM user_tab_columns uc
         WHERE (uc.table_name=dus_date_cols->qual[dvdc_loop].tbl_name)
          AND (uc.column_name=dus_date_cols->qual[dvdc_loop].col_name)
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
        IF (curqual > 0)
         SET dm_err->eproc = concat("[UTC Conversion] Table/column ",trim(dus_date_cols->qual[
           dvdc_loop].tbl_col_name)," already exists in database.")
         CALL disp_msg("",dm_err->logfile,0)
         SET dvdc_col_exists_cnt = (dvdc_col_exists_cnt+ 1)
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
    IF (dldc_mode="C")
     IF (((dvdc_col_mismatch_cnt > 0) OR (dvdc_col_missing_cnt > 0)) )
      SET dm_err->err_ind = 1
      SET dm_err->eproc = "Verify master date list csv file and Admin master date list match."
      SET dm_err->emsg = concat("Table/columns missing or mismatch on date type flag.  [Missing: ",
       trim(cnvtstring(dvdc_col_missing_cnt)),"  Mismatch: ",trim(cnvtstring(dvdc_col_mismatch_cnt)),
       "].  Review logfile for complete list of missing/mismatch table/columns.")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF ((dus_adm_date_cols->cnt > dus_date_cols->cnt))
      SET dm_err->err_ind = 1
      SET dm_err->eproc = "Verify context of master list."
      SET dm_err->emsg = concat("CHECK mode requires the master date list count in csv file (",trim(
        cnvtstring(dus_date_cols->cnt)),") to match count of Admin master date list (",trim(
        cnvtstring(dus_adm_date_cols->cnt)),").")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    IF (dldc_mode="U"
     AND ((dvdc_col_mismatch_cnt > 0) OR (dvdc_col_exists_cnt > 0)) )
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Verify master date list csv file and Admin master date list match."
     SET dm_err->emsg = concat(
      "Table/columns mismatch on date type flag or already exist in database.  [Mismatch: ",trim(
       cnvtstring(dvdc_col_mismatch_cnt)),"  Exists in DB: ",trim(cnvtstring(dvdc_col_exists_cnt)),
      "].  Review logfile for complete list of missing/mismatch table/columns.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dldc_mode="C")
     IF (dus_load_spec_cols(dldc_dbname)=0)
      RETURN(0)
     ENDIF
     FOR (dvdc_loop = 1 TO dus_date_cols->cnt)
       IF ((dus_date_cols->qual[dvdc_loop].dt_type_flag != 1))
        SET dvdc_tbl_fnd = 0
        SET dvdc_tbl_fnd = locateval(dvdc_tbl_fnd,1,dus_std_convert_list->tbl_cnt,dus_date_cols->
         qual[dvdc_loop].tbl_name,dus_std_convert_list->tbl[dvdc_tbl_fnd].table_name)
        IF (dvdc_tbl_fnd > 0)
         SET dvdc_col_fnd = 0
         SET dvdc_col_fnd = locateval(dvdc_col_fnd,1,dus_std_convert_list->tbl[dvdc_tbl_fnd].col_cnt,
          dus_date_cols->qual[dvdc_loop].col_name,dus_std_convert_list->tbl[dvdc_tbl_fnd].col[
          dvdc_col_fnd].column_name)
        ENDIF
        IF (((dvdc_tbl_fnd=0) OR (dvdc_col_fnd=0)) )
         SET dm_err->eproc = concat(
          "[UTC Conversion] Table/column exclusion date missing from Admin exclusions [",
          dus_date_cols->qual[dvdc_loop].tbl_col_name,"].")
         CALL disp_msg("",dm_err->logfile,0)
         SET dvdc_col_missing_adm_cnt = (dvdc_col_missing_adm_cnt+ 1)
        ENDIF
       ENDIF
     ENDFOR
     IF (dvdc_col_missing_adm_cnt > 0)
      SET dm_err->err_ind = 1
      SET dm_err->eproc =
      "Verify master date exclusions from csv file and Admin exclusion date list match."
      SET dm_err->emsg = concat("Table/columns missing from Admin exclusions.  [Missing: ",trim(
        cnvtstring(dvdc_col_missing_adm_cnt)),
       "].  Review logfile for complete list of Admin exclusions missing table/columns.")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF (dldc_mode="I"
    AND (dus_adm_date_cols->cnt > 0))
    SET dm_err->eproc =
    "Insert mode on restart.  Skipping work to complete initial load of Admin DM_INFO master date column list."
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (((dldc_mode="I"
    AND (dus_adm_date_cols->cnt=0)) OR (dldc_mode="U")) )
    IF (dldc_mode="U")
     SET dm_err->eproc = "Deleting Master Date Columns into Admin DM_INFO."
     CALL disp_msg(" ",dm_err->logfile,0)
     DELETE  FROM dm2_admin_dm_info i
      WHERE i.info_domain=patstring(cnvtupper(build(dldc_dbname,"_UTC_DATA - MASTER DATE COLUMN LIST"
         )))
      WITH nocounter
     ;end delete
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
    SET dm_err->eproc = "Inserting Master Date Columns into Admin DM_INFO."
    CALL disp_msg(" ",dm_err->logfile,0)
    INSERT  FROM dm2_admin_dm_info di,
      (dummyt d  WITH seq = value(size(dus_date_cols->qual,5)))
     SET di.info_domain = patstring(cnvtupper(build(dldc_dbname,"_UTC_DATA - MASTER DATE COLUMN LIST"
         ))), di.info_name = dus_date_cols->qual[d.seq].tbl_col_name, di.info_number = dus_date_cols
      ->qual[d.seq].dt_type_flag,
      di.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     PLAN (d)
      JOIN (di
      WHERE (dus_date_cols->qual[d.seq].tbl_col_name=di.info_name))
     WITH nocounter, rdbarrayinsert = 100
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    COMMIT
    IF (dum_mng_spec_cols(dldc_dbname)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_fill_v500_cust(dfvc_dbname)
   DECLARE dfvc_pos = i4 WITH protect, noconstant(0)
   DECLARE dfvc_loc = i4 WITH protect, noconstant(0)
   DECLARE dfvc_own_name = vc WITH protect, noconstant(" ")
   DECLARE dfvc_tbl_name = vc WITH protect, noconstant(" ")
   SET dm_err->eproc = "Loading V500 Custom tables from ADMIN DM_INFO."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info i
    WHERE i.info_domain=patstring(cnvtupper(build(dfvc_dbname,"_UTC_DATA - V500 CUST TABLES LIST")))
    DETAIL
     dus_v500_cust->tbl_cnt = (dus_v500_cust->tbl_cnt+ 1), stat = alterlist(dus_v500_cust->tbl,
      dus_v500_cust->tbl_cnt), dus_v500_cust->tbl[dus_v500_cust->tbl_cnt].table_name = i.info_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(dus_v500_cust)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dum_cust_incl_abort_gen(dciag_tgt_dbname,dciag_src_orcl_ver,dciag_tgt_orcl_ver)
   DECLARE dciag_fname = vc WITH protect, noconstant("")
   DECLARE dciag_parm_loc = vc WITH protect, noconstant("")
   DECLARE dciag_iter = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Create utc delivery custom tables inclusion abort file for custom tables."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dciag_parm_loc = "/ggdelivery/dirprm"
   IF (dm2_find_dir(dciag_parm_loc)=0)
    SET message = window
    CALL clear(1,1)
    CALL box(1,1,15,120)
    CALL text(3,2,"Enter Delivery parameter file directory location :")
    CALL accept(3,70,"P(30);C",dciag_parm_loc
     WHERE curaccept != "")
    SET dciag_parm_loc = trim(curaccept)
    SET message = nowindow
   ENDIF
   IF (dm2_find_dir(dciag_parm_loc)=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Delivery parm directory entered [",dciag_parm_loc,"] does not exist.")
    SET dm_err->eproc = "Verify delivery parm directory exists."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (substring(size(dciag_parm_loc),1,dciag_parm_loc) != "/")
    SET dciag_parm_loc = concat(trim(dciag_parm_loc),"/")
   ENDIF
   SET dciag_fname = concat(trim(dciag_parm_loc),"custtbls_abort.mac")
   SELECT INTO value(dciag_fname)
    FROM dummyt d
    HEAD REPORT
     col 0,
     CALL print("MACRO #custtbls_abort"), row + 1,
     col 0,
     CALL print("BEGIN"), row + 1
    DETAIL
     IF ((dus_v500_cust->tbl_cnt > 0))
      IF (dciag_src_orcl_ver < 12
       AND dciag_tgt_orcl_ver > 11)
       FOR (dciag_iter = 1 TO dus_v500_cust->tbl_cnt)
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE ALTER OBJTYPE TABLE OBJNAME ",dciag_tgt_dbname,
          ".V500.",trim(dus_v500_cust->tbl[dciag_iter].table_name),
          ^ INSTRWORDS '" ADD "' EVENTACTIONS (DISCARD, ABORT) &^)), row + 1,
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE CREATE OBJTYPE TABLE OBJNAME ",dciag_tgt_dbname,
          ".V500.",trim(dus_v500_cust->tbl[dciag_iter].table_name)," EVENTACTIONS (DISCARD, ABORT) &"
          )), row + 1,
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE DROP OBJTYPE TABLE OBJNAME ",dciag_tgt_dbname,
          ".V500.",trim(dus_v500_cust->tbl[dciag_iter].table_name)," EVENTACTIONS (DISCARD, ABORT) &"
          )), row + 1
       ENDFOR
      ELSE
       FOR (dciag_iter = 1 TO dus_v500_cust->tbl_cnt)
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE ALTER OBJTYPE TABLE OBJNAME V500.",trim(
           dus_v500_cust->tbl[dciag_iter].table_name),
          ^ INSTRWORDS '" ADD "' EVENTACTIONS (DISCARD, ABORT) &^)), row + 1,
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE CREATE OBJTYPE TABLE OBJNAME V500.",trim(
           dus_v500_cust->tbl[dciag_iter].table_name)," EVENTACTIONS (DISCARD, ABORT) &")), row + 1,
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE DROP OBJTYPE TABLE OBJNAME V500.",trim(
           dus_v500_cust->tbl[dciag_iter].table_name)," EVENTACTIONS (DISCARD, ABORT) &")), row + 1
       ENDFOR
      ENDIF
     ENDIF
     IF ((dus_user_list->cnt > 0))
      IF (dciag_src_orcl_ver < 12
       AND dciag_tgt_orcl_ver > 11)
       FOR (dciag_iter = 1 TO dus_user_list->cnt)
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE ALTER OBJTYPE TABLE OBJNAME ",dciag_tgt_dbname,".",
          trim(dus_user_list->qual[dciag_iter].owner_name),".",
          trim(dus_user_list->qual[dciag_iter].table_name),
          ^ INSTRWORDS '" ADD "' EVENTACTIONS (DISCARD, ABORT) &^)), row + 1,
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE CREATE OBJTYPE TABLE OBJNAME ",dciag_tgt_dbname,".",
          trim(dus_user_list->qual[dciag_iter].owner_name),".",
          trim(dus_user_list->qual[dciag_iter].table_name)," EVENTACTIONS (DISCARD, ABORT) &")), row
          + 1,
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE DROP OBJTYPE TABLE OBJNAME ",dciag_tgt_dbname,".",
          trim(dus_user_list->qual[dciag_iter].owner_name),".",
          trim(dus_user_list->qual[dciag_iter].table_name)," EVENTACTIONS (DISCARD, ABORT) &")), row
          + 1
       ENDFOR
      ELSE
       FOR (dciag_iter = 1 TO dus_user_list->cnt)
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE ALTER OBJTYPE TABLE OBJNAME ",trim(dus_user_list->
           qual[dciag_iter].owner_name),".",trim(dus_user_list->qual[dciag_iter].table_name),
          ^ INSTRWORDS '" ADD "' EVENTACTIONS (DISCARD, ABORT) &^)), row + 1,
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE CREATE OBJTYPE TABLE OBJNAME ",trim(dus_user_list->
           qual[dciag_iter].owner_name),".",trim(dus_user_list->qual[dciag_iter].table_name),
          " EVENTACTIONS (DISCARD, ABORT) &")), row + 1,
         col 0,
         CALL print(concat("INCLUDE MAPPED OPTYPE DROP OBJTYPE TABLE OBJNAME ",trim(dus_user_list->
           qual[dciag_iter].owner_name),".",trim(dus_user_list->qual[dciag_iter].table_name),
          " EVENTACTIONS (DISCARD, ABORT) &")), row + 1
       ENDFOR
      ENDIF
     ENDIF
    FOOT REPORT
     IF (dciag_src_orcl_ver < 12
      AND dciag_tgt_orcl_ver > 11)
      col 0,
      CALL print(concat("INCLUDE MAPPED OPTYPE CREATE OBJTYPE TABLE OBJNAME ",dciag_tgt_dbname,
       ".V500.DM2_MIG_FAKE_BATCH"," EVENTACTIONS (DISCARD, ABORT) ")), row + 1
     ELSE
      col 0,
      CALL print(concat("INCLUDE MAPPED OPTYPE CREATE OBJTYPE TABLE OBJNAME V500.DM2_MIG_FAKE_BATCH",
       " EVENTACTIONS (DISCARD, ABORT) ")), row + 1
     ENDIF
     col 0,
     CALL print("END;"), row + 1
    WITH nocounter, maxrow = 1, format = lfstream,
     noformfeed, maxcol = 2000
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE dmcpf_logfile_prefix = vc WITH protect, constant("dm2_mig_create_parm")
 DECLARE dmcpf_tmp_disk_name = vc WITH protect, noconstant("")
 DECLARE dmcpf_logoptions_str = vc WITH protect, noconstant("")
 DECLARE dmcpf_sqlexec_str = vc WITH protect, noconstant("")
 DECLARE dmcpf_cnt = i4 WITH protect, noconstant(0)
 DECLARE dmcpf_cmd = vc WITH protect, noconstant("")
 DECLARE dmcpf_v500_exist = i2 WITH protect, noconstant(0)
 DECLARE dmcpf_tgt_hostname = vc WITH protect, noconstant("NOT_SET")
 DECLARE dmcpf_nlslang = vc WITH protect, noconstant("")
 DECLARE dmcpf_src_asm_pw = vc WITH protect, noconstant(" ")
 DECLARE dmcpf_src_asm_cs = vc WITH protect, noconstant(" ")
 DECLARE dmcpf_src_cnnt_str = vc WITH protect, noconstant(" ")
 DECLARE dmcpf_tgt_cnnt_str = vc WITH protect, noconstant(" ")
 DECLARE dmcpf_src_txt_file = vc WITH protect, constant("dm2_mig_capture.txt")
 DECLARE dmcpf_src_mgr_txt_file = vc WITH protect, constant("dm2_mig_capture_mgr.txt")
 DECLARE dmcpf_tgt_txt_file = vc WITH protect, constant("dm2_mig_delivery.txt")
 DECLARE dmcpf_tgt_otxt_file = vc WITH protect, constant("dm2_mig_delivo.txt")
 DECLARE dmcpf_tgt_chtxt_file = vc WITH protect, constant("dm2_mig_delivch.txt")
 DECLARE dmcpf_tgt_ditxt_file = vc WITH protect, constant("dm2_mig_delivdi.txt")
 DECLARE dmcpf_tgt_cytxt_file = vc WITH protect, constant("dm2_mig_delivcy.txt")
 DECLARE dmcpf_tgt_cetxt_file = vc WITH protect, constant("dm2_mig_delivce.txt")
 DECLARE dmcpf_tgt_macro_file = vc WITH protect, constant("dm2_mig_batches_macro.txt")
 DECLARE dmcpf_tgt_camacro_file = vc WITH protect, constant("dm2_mig_custtblsa_macro.txt")
 DECLARE dmcpf_tgt_trgmacro_file = vc WITH protect, constant("dm2_mig_trig_macro.txt")
 DECLARE dmcpf_tgt_mgr_txt_file = vc WITH protect, constant("dm2_mig_delivery_mgr.txt")
 DECLARE dmcpf_src_pmp_txt_file = vc WITH protect, constant("dm2_mig_cappump.txt")
 DECLARE dmcpf_capture_dir = vc WITH protect, noconstant("/ggcapture/dirprm")
 DECLARE dmcpf_delivery_dir = vc WITH protect, noconstant("/ggdelivery/dirprm")
 DECLARE dmcpf_global_file = vc WITH protect, constant("GLOBALS")
 DECLARE dmcpf_cap_dir = vc WITH protect, noconstant("/ggcapture/")
 DECLARE dmcpf_del_dir = vc WITH protect, noconstant("/ggdelivery/")
 DECLARE dmcpf_src_prm_file = vc WITH protect, constant("capture.prm")
 DECLARE dmcpf_src_mgr_prm_file = vc WITH protect, constant("mgr.prm")
 DECLARE dmcpf_tgt_prm_file = vc WITH protect, constant("delivery.prm")
 DECLARE dmcpf_tgt_oprm_file = vc WITH protect, constant("delivo.prm")
 DECLARE dmcpf_tgt_chprm_file = vc WITH protect, constant("delivch.prm")
 DECLARE dmcpf_tgt_diprm_file = vc WITH protect, constant("delivdi.prm")
 DECLARE dmcpf_tgt_cyprm_file = vc WITH protect, constant("delivcy.prm")
 DECLARE dmcpf_tgt_ceprm_file = vc WITH protect, constant("delivce.prm")
 DECLARE dmcpf_tgt_macroprm_file = vc WITH protect, constant("batches.mac")
 DECLARE dmcpf_tgt_macrocaprm_file = vc WITH protect, constant("custtbls_abort.mac")
 DECLARE dmcpf_tgt_macrotrgprm_file = vc WITH protect, constant("dm2_mig_trig_macro.mac")
 DECLARE dmcpf_tgt_mgr_prm_file = vc WITH protect, constant("mgr.prm")
 DECLARE dmcpf_src_pmp_prm_file = vc WITH protect, constant("cappump.prm")
 DECLARE dmcpf_mngd_tables = vc WITH protect, noconstant("")
 DECLARE dmcpf_gg_cap_loc = vc WITH protect, noconstant("")
 DECLARE dmcpf_gg_del_loc = vc WITH protect, noconstant("")
 DECLARE dmcpf_src_dbname = vc WITH protect, noconstant("")
 DECLARE dmcpf_tmp_status = vc WITH protect, noconstant("")
 DECLARE dmcpf_tgt_dbname = vc WITH protect, noconstant("")
 DECLARE dmcpf_pos = i4 WITH protect, noconstant(0)
 DECLARE dmcpf_loc = i4 WITH protect, noconstant(0)
 DECLARE dmcpf_own_name = vc WITH protect, noconstant(" ")
 DECLARE dmcpf_goldengate_version = i2 WITH protect, noconstant(0)
 DECLARE dmcpf_target_db_version = i2 WITH protect, noconstant(0)
 DECLARE dmcpf_line_nbr = i2 WITH protect, noconstant(2)
 DECLARE dmcpf_glb_cnt = i2 WITH protect, noconstant(0)
 DECLARE dmcpf_gg_adm_pwd = vc WITH protect, noconstant("")
 DECLARE dmcpf_db_name = vc WITH protect, noconstant("")
 FREE RECORD dmcpf_excl_tables
 RECORD dmcpf_excl_tables(
   1 cnt = i4
   1 tbl[*]
     2 tbl_str = vc
 )
 SET dmcpf_excl_tables->cnt = 0
 FREE RECORD dmcpf_delivs
 RECORD dmcpf_delivs(
   1 cnt = i4
   1 deliv[*]
     2 name = vc
 )
 SET dmcpf_delivs->cnt = 0
 FREE RECORD dmcpf_excl_tables_ddl_incl
 RECORD dmcpf_excl_tables_ddl_incl(
   1 cnt = i4
   1 tbl[*]
     2 tbl_str = vc
 )
 SET dmcpf_excl_tables_ddl_incl->cnt = 0
 DECLARE dmcpf_search_replace(dsr_fname=vc) = i2
 DECLARE dmcpf_write_cmds_to_file(null) = i2
 DECLARE dmcpf_cappump_used = i2 WITH protect, noconstant(0)
 DECLARE dmcpf_get_nlslang(dgn_nlslang_out=vc(ref)) = i2
 DECLARE dmcpf_utc_in_progress = i2 WITH protect, noconstant(- (1))
 DECLARE dmcpf_accept_option = vc WITH protect, noconstant("")
 DECLARE dmcpf_get_gg_dir(dggd_line_nbr=i2,dggd_dir_type=vc,dmcpf_dir_name=vc(ref)) = i2
 DECLARE dmcpf_get_con_str(dgcs_db_name=vc(ref)) = i2
 SET width = 132
 IF (check_logfile(dmcpf_logfile_prefix,".log","dm2_mig_create_parm_files")=0)
  GO TO exit_program
 ENDIF
 IF ((dm2_sys_misc->cur_os="AXP"))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "VMS is unsupported for goldengate monitoring."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (dmr_prompt_retrieve_mig_data(0,1,0,0)=0)
  GO TO exit_program
 ENDIF
 SET dm2_install_schema->dbase_name = '"TARGET"'
 SET dm2_install_schema->u_name = "V500"
 SET dm2_force_connect_string = 1
 EXECUTE dm2_connect_to_dbase "PO"
 SET dm2_force_connect_string = 0
 IF ((dm_err->err_ind=1))
  GO TO exit_program
 ENDIF
 SET dmr_mig_data->tgt_v500_pwd = dm2_install_schema->p_word
 SET dmr_mig_data->tgt_v500_cnct_str = dm2_install_schema->connect_str
 IF ((((dmr_mig_data->cur_db_type != "SOURCE")) OR (currdbuser != "V500")) )
  IF (dmr_prompt_connect_data("SOURCE","V500","CO")=0)
   GO TO exit_program
  ENDIF
 ENDIF
 SET message = window
 CALL clear(1,1)
 CALL box(1,1,15,120)
 SET dmcpf_line_nbr = 2
 CALL text(dmcpf_line_nbr,2,"Name of the TARGET database host:")
 CALL accept(dmcpf_line_nbr,40,"P(50);C")
 SET dmcpf_tgt_hostname = trim(cnvtlower(curaccept),3)
 SET dmcpf_line_nbr = (dmcpf_line_nbr+ 1)
 CALL text(dmcpf_line_nbr,2,"Major Version of Target Database:")
 SET help = fix("19,12,11,10,9")
 CALL accept(dmcpf_line_nbr,40,"P(2);CFU"," "
  WHERE build(curaccept) IN ("19", "12", "11", "10", "9"))
 SET dmcpf_target_db_version = cnvtint(curaccept)
 SET help = off
 SET dmcpf_line_nbr = (dmcpf_line_nbr+ 1)
 IF (dmcpf_target_db_version > 11)
  CALL text(dmcpf_line_nbr,2,"Name of the TARGET pluggable database:")
 ELSE
  CALL text(dmcpf_line_nbr,2,"Name of the TARGET database:")
 ENDIF
 CALL accept(dmcpf_line_nbr,41,"P(9);CU")
 SET dmcpf_tgt_dbname = trim(cnvtupper(curaccept),3)
 SET dmcpf_line_nbr = (dmcpf_line_nbr+ 1)
 CALL text(dmcpf_line_nbr,2,"Version of Goldengate:")
 SET help = fix("19,18,11,10")
 CALL accept(dmcpf_line_nbr,41,"P(2);CFU"," "
  WHERE build(curaccept) IN ("19", "18", "11", "10"))
 SET dmcpf_goldengate_version = cnvtint(curaccept)
 SET dmcpf_line_nbr = (dmcpf_line_nbr+ 1)
 CALL text(dmcpf_line_nbr,2,"What connect string should be used for the Capture Process?")
 IF ((dmr_mig_data->src_ora_level1 > 11))
  IF (dmcpf_get_con_str(dmcpf_db_name)=0)
   GO TO exit_program
  ELSE
   CALL accept(dmcpf_line_nbr,64,"P(30);CU",dmcpf_db_name
    WHERE trim(curaccept) != "")
  ENDIF
 ELSE
  CALL accept(dmcpf_line_nbr,64,"P(30);CU",dmr_mig_data->src_v500_cnct_str
   WHERE trim(curaccept) != "")
 ENDIF
 SET dmcpf_src_cnnt_str = trim(curaccept)
 IF ((dmr_mig_data->src_ora_level1 > 11))
  SET dmcpf_line_nbr = (dmcpf_line_nbr+ 1)
  CALL text(dmcpf_line_nbr,2,"Enter source DB password for CERNGG_MIG user :")
  CALL accept(dmcpf_line_nbr,64,"P(30);CU",dmcpf_gg_adm_pwd
   WHERE trim(curaccept) != "")
  SET dmcpf_gg_adm_pwd = trim(cnvtlower(curaccept))
 ENDIF
 SET dmcpf_line_nbr = (dmcpf_line_nbr+ 1)
 CALL text(dmcpf_line_nbr,2,"What connect string should be used for the Delivery Process?")
 CALL accept(dmcpf_line_nbr,64,"P(30);CU",dmr_mig_data->tgt_v500_cnct_str
  WHERE trim(curaccept) != "")
 SET dmcpf_tgt_cnnt_str = trim(curaccept)
 IF ((dmr_mig_data->src_ora_level1 <= 11))
  IF ((dmr_mig_data->src_storage_type="ASM"))
   SET dmcpf_line_nbr = (dmcpf_line_nbr+ 1)
   CALL text(dmcpf_line_nbr,2,"Enter Source ASM password for SYS user :")
   CALL accept(dmcpf_line_nbr,64,"P(30);C",dmcpf_src_asm_pw
    WHERE trim(curaccept) != "")
   SET dmcpf_src_asm_pw = trim(curaccept)
   SET dmcpf_line_nbr = (dmcpf_line_nbr+ 1)
   CALL text(dmcpf_line_nbr,2,"Enter Source ASM connect string (ex. ORCL_ASM1):")
   CALL accept(dmcpf_line_nbr,64,"P(30);CU",dmcpf_src_asm_cs
    WHERE trim(curaccept) != "")
   SET dmcpf_src_asm_cs = trim(curaccept)
  ENDIF
 ENDIF
 SET dmcpf_line_nbr = (dmcpf_line_nbr+ 1)
 CALL text(dmcpf_line_nbr,2,
  "Will Goldengate Capture and Delivery processes reside on the same node? (Y/N):")
 CALL accept(dmcpf_line_nbr,82,"P;CU","N"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="N")
  SET dmcpf_cappump_used = 1
 ENDIF
 SET dmcpf_line_nbr = (dmcpf_line_nbr+ 1)
 IF (dmcpf_get_gg_dir(dmcpf_line_nbr,"Capture",dmcpf_capture_dir)=0)
  GO TO exit_program
 ENDIF
 SET dmcpf_line_nbr = (dmcpf_line_nbr+ 1)
 IF (dmcpf_get_gg_dir(dmcpf_line_nbr,"Delivery",dmcpf_delivery_dir)=0)
  GO TO exit_program
 ENDIF
 CALL clear(1,1)
 SET message = nowindow
 SET dm_err->eproc = "Check for UTC Conversion context row."
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="DM2_MIG_UTC_IND"
  DETAIL
   IF (d.info_name="YES")
    dmcpf_utc_in_progress = 1
   ELSE
    dmcpf_utc_in_progress = 0
   ENDIF
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ELSEIF ((dmcpf_utc_in_progress=- (1)))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat("No DM_INFO rows exist for UTC Conversion context.")
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (dmcpf_utc_in_progress=0)
  SET dm_err->eproc = "UTC Conversion is not part of Migration."
  CALL disp_msg(" ",dm_err->logfile,0)
 ELSE
  SET dm_err->eproc = "UTC Conversion is part of Migration."
  CALL disp_msg(" ",dm_err->logfile,0)
 ENDIF
 SET dm_err->eproc = "Retrieving GG Capture and Delivery Directory paths for GG node."
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DM2_MIG_GG_DATA"
   AND di.info_name IN ("GG_CAP_DIR", "GG_DEL_DIR")
  DETAIL
   IF (di.info_name="GG_CAP_DIR")
    dmcpf_gg_cap_loc = trim(di.info_char,3)
   ELSE
    dmcpf_gg_del_loc = trim(di.info_char,3)
   ENDIF
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ELSEIF (((size(trim(dmcpf_gg_cap_loc,3))=0) OR (size(trim(dmcpf_gg_del_loc,3))=0)) )
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat("No DM_INFO rows exist for Capture/Delivery Directories path.")
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (substring(size(trim(dmcpf_gg_cap_loc,3)),1,dmcpf_gg_cap_loc)="/")
  SET dmcpf_gg_cap_loc = trim(replace(dmcpf_gg_cap_loc,"/","",2),3)
 ENDIF
 IF (substring(size(trim(dmcpf_gg_del_loc,3)),1,dmcpf_gg_del_loc)="/")
  SET dmcpf_gg_del_loc = trim(replace(dmcpf_gg_del_loc,"/","",2),3)
 ENDIF
 IF (dmcpf_get_nlslang(dmcpf_nlslang)=0)
  GO TO exit_program
 ENDIF
 SET drr_cmd_rec->tgt_filename = concat(dmcpf_cap_dir,dmcpf_global_file)
 IF (dmcpf_goldengate_version=11)
  SET stat = alterlist(drr_cmd_rec->cmds,3)
  SET drr_cmd_rec->cmds[1].text = "SYSLOG NONE"
  SET drr_cmd_rec->cmds[2].text = "GGSCHEMA GGDDL"
  SET drr_cmd_rec->cmds[3].text = "ALLOWNONVALIDATEDKEYS"
  SET dmcpf_glb_cnt = 3
 ELSEIF (dmcpf_goldengate_version >= 18
  AND (dmr_mig_data->src_ora_level1=11)
  AND dmcpf_target_db_version >= 11)
  SET stat = alterlist(drr_cmd_rec->cmds,5)
  SET drr_cmd_rec->cmds[1].text = "GGSCHEMA GGDDL"
  SET drr_cmd_rec->cmds[2].text = "ALLOWNONVALIDATEDKEYS"
  SET drr_cmd_rec->cmds[3].text = "ENABLE_HEARTBEAT_TABLE"
  SET drr_cmd_rec->cmds[4].text = "HEARTBEATTABLE V500.GG_HEARTBEAT"
  SET drr_cmd_rec->cmds[5].text = "ALLOWNULLABLEKEYS"
  SET dmcpf_glb_cnt = 5
 ELSEIF (dmcpf_goldengate_version >= 18
  AND (dmr_mig_data->src_ora_level1 > 11)
  AND dmcpf_target_db_version > 11)
  SET stat = alterlist(drr_cmd_rec->cmds,4)
  SET drr_cmd_rec->cmds[1].text = "ALLOWNONVALIDATEDKEYS"
  SET drr_cmd_rec->cmds[2].text = "ENABLE_HEARTBEAT_TABLE"
  SET drr_cmd_rec->cmds[3].text = "HEARTBEATTABLE V500.GG_HEARTBEAT"
  SET drr_cmd_rec->cmds[4].text = "ALLOWNULLABLEKEYS"
  SET dmcpf_glb_cnt = 4
 ENDIF
 SET drr_cmd_rec->cmd_cnt = dmcpf_glb_cnt
 IF (dmcpf_write_cmds_to_file(null)=0)
  GO TO exit_program
 ENDIF
 CALL dm2_push_dcl(concat("mv ",dmcpf_cap_dir,"globals.dat ",dmcpf_cap_dir,"GLOBALS"))
 CALL drr_reset_cmd_rec(null)
 SET drr_cmd_rec->tgt_filename = concat(dmcpf_del_dir,dmcpf_global_file)
 IF (dmcpf_goldengate_version=11)
  SET stat = alterlist(drr_cmd_rec->cmds,2)
  SET drr_cmd_rec->cmds[1].text = "SYSLOG NONE"
  SET drr_cmd_rec->cmds[2].text = "ALLOWNONVALIDATEDKEYS"
  SET dmcpf_glb_cnt = 2
 ELSEIF (dmcpf_goldengate_version >= 18)
  SET stat = alterlist(drr_cmd_rec->cmds,4)
  SET drr_cmd_rec->cmds[1].text = "ALLOWNONVALIDATEDKEYS"
  SET drr_cmd_rec->cmds[2].text = "ENABLE_HEARTBEAT_TABLE"
  SET drr_cmd_rec->cmds[3].text = "HEARTBEATTABLE V500.GG_HEARTBEAT"
  SET drr_cmd_rec->cmds[4].text = "ALLOWNULLABLEKEYS"
  SET dmcpf_glb_cnt = 4
 ENDIF
 SET drr_cmd_rec->cmd_cnt = dmcpf_glb_cnt
 IF (dmcpf_write_cmds_to_file(null)=0)
  GO TO exit_program
 ENDIF
 CALL dm2_push_dcl(concat("mv ",dmcpf_del_dir,"globals.dat ",dmcpf_del_dir,"GLOBALS"))
 CALL drr_reset_cmd_rec(null)
 SET dmcpf_cnt = 0
 SET dmcpf_delivs->cnt = 6
 SET stat = alterlist(dmcpf_delivs->deliv,dmcpf_delivs->cnt)
 SET dmcpf_delivs->deliv[1].name = "DELIVERY"
 SET dmcpf_delivs->deliv[2].name = "DELIVO"
 SET dmcpf_delivs->deliv[3].name = "DELIVCH"
 SET dmcpf_delivs->deliv[4].name = "DELIVDI"
 SET dmcpf_delivs->deliv[5].name = "DELIVCY"
 SET dmcpf_delivs->deliv[6].name = "DELIVCE"
 SET dm_err->eproc = build("Delete default DELIVERY names from ADMIN DM_INFO.")
 CALL disp_msg("",dm_err->logfile,0)
 DELETE  FROM dm2_admin_dm_info di
  WHERE di.info_domain="DM2MIG_DELDATA_NAME"
   AND expand(dmcpf_cnt,1,dmcpf_delivs->cnt,di.info_name,dmcpf_delivs->deliv[dmcpf_cnt].name)
  WITH nocounter
 ;end delete
 IF (check_error(dm_err->eproc)=1)
  ROLLBACK
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = build("Insert default DELIVERY names into ADMIN DM_INFO.")
 CALL disp_msg("",dm_err->logfile,0)
 INSERT  FROM dm2_admin_dm_info di,
   (dummyt d  WITH seq = value(size(dmcpf_delivs->deliv,5)))
  SET di.info_domain = "DM2MIG_DELDATA_NAME", di.info_name = dmcpf_delivs->deliv[d.seq].name, di
   .updt_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (d
   WHERE d.seq > 0)
   JOIN (di)
  WITH nocounter
 ;end insert
 IF (check_error(dm_err->eproc)=1)
  ROLLBACK
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 COMMIT
 IF (dmr_verify_v500_user(dmcpf_v500_exist)=0)
  GO TO exit_program
 ENDIF
 IF (dmcpf_v500_exist=1)
  IF (dmr_get_user_list(null)=0)
   GO TO exit_program
  ENDIF
 ELSE
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "V500 user does not exist."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Verify files needed exists."
 CALL disp_msg("",dm_err->logfile,0)
 IF (dm2_findfile(concat(dm2_install_schema->cer_install,dmcpf_src_txt_file))=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat(dmcpf_src_txt_file," is not found.")
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (dm2_findfile(concat(dm2_install_schema->cer_install,dmcpf_src_mgr_txt_file))=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat(dmcpf_src_mgr_txt_file," is not found.")
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (dm2_findfile(concat(dm2_install_schema->cer_install,dmcpf_src_pmp_txt_file))=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat(dmcpf_src_pmp_txt_file," is not found.")
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Find excluded tables"
 CALL disp_msg("",dm_err->logfile,0)
 SELECT INTO "nl:"
  d.info_name
  FROM dm_info d
  WHERE d.info_domain IN ("DM2_MIG_EXCL", "DM2_MIG_NONGG_REP")
  DETAIL
   dmcpf_excl_tables->cnt = (dmcpf_excl_tables->cnt+ 1)
   IF (mod(dmcpf_excl_tables->cnt,10)=1)
    stat = alterlist(dmcpf_excl_tables->tbl,(dmcpf_excl_tables->cnt+ 9))
   ENDIF
   dmcpf_excl_tables->tbl[dmcpf_excl_tables->cnt].tbl_str = concat("tableexclude ",trim(cnvtlower(d
      .info_name)),";")
  FOOT REPORT
   stat = alterlist(dmcpf_excl_tables->tbl,dmcpf_excl_tables->cnt)
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET dmcpf_mngd_tables = ""
 IF (dmr_load_managed_tables(dmcpf_mngd_tables)=0)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Find excluded managed tables"
 CALL disp_msg("",dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM dba_tables dt
  WHERE parser(concat(" dt.table_name in (",dmcpf_mngd_tables,")"))
   AND dt.owner IN (
  (SELECT
   info_name
   FROM dm_info d
   WHERE ((d.info_domain="DM2_MIG_USER") OR (d.info_domain="DM2_MIG_DT_USER"
    AND d.info_char="1")) ))
  DETAIL
   dmcpf_excl_tables->cnt = (dmcpf_excl_tables->cnt+ 1), stat = alterlist(dmcpf_excl_tables->tbl,
    dmcpf_excl_tables->cnt), dmcpf_excl_tables->tbl[dmcpf_excl_tables->cnt].tbl_str = cnvtlower(
    concat("tableexclude ",trim(dt.owner),".",trim(dt.table_name),";"))
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET dmcpf_excl_tables->cnt = (dmcpf_excl_tables->cnt+ 1)
 SET stat = alterlist(dmcpf_excl_tables->tbl,dmcpf_excl_tables->cnt)
 SET dmcpf_excl_tables->tbl[dmcpf_excl_tables->cnt].tbl_str = "tableexclude v500.dm_prg_tmp*;"
 IF ((dm_err->debug_flag > 2))
  CALL echorecord(dmcpf_excl_tables)
 ENDIF
 SET dmcpf_src_dbname = dmr_mig_data->src_db_name
 CALL drr_add_sr_data("<NLSLANG>",dmcpf_nlslang)
 IF ((dmr_mig_data->src_ora_level1 > 11))
  CALL drr_add_sr_data("<=GG_DB_CONNECT=>",concat("userid c##cerngg_mig@",dmcpf_db_name,", password ",
    dmcpf_gg_adm_pwd))
  CALL drr_add_sr_data("<=INTEGRATED_EXTRACT_OPTIONS=>",
   "TRANLOGOPTIONS INTEGRATEDPARAMS (_LOGMINER_READ_BUFFERS 256)")
  CALL drr_add_sr_data("<=DDLOPTIONS=>","ddloptions report")
  CALL drr_add_sr_data("<=ASM_CONNECTION_INFO=>","")
 ELSE
  CALL drr_add_sr_data("<=GG_DB_CONNECT=>",concat("userid v500@",dmcpf_src_cnnt_str,", password ",
    dmr_mig_data->src_v500_pwd))
  CALL drr_add_sr_data("<=INTEGRATED_EXTRACT_OPTIONS=>","")
  CALL drr_add_sr_data("<=DDLOPTIONS=>","ddloptions addtrandata, report")
  IF ((dmr_mig_data->src_storage_type="ASM"))
   CALL drr_add_sr_data("<=ASM_CONNECTION_INFO=>",concat("tranlogoptions asmuser SYS@",
     dmcpf_src_asm_cs,", asmpassword ",dmcpf_src_asm_pw))
  ENDIF
 ENDIF
 IF (dmcpf_cappump_used=1)
  CALL drr_add_sr_data("<=TRAILLOC=>",build(dmcpf_gg_cap_loc,"/dirdat/aa "))
 ELSE
  CALL drr_add_sr_data("<=TRAILLOC=>",build(dmcpf_gg_del_loc,"/dirdat/aa "))
 ENDIF
 IF (dmcpf_goldengate_version < 12
  AND dmcpf_target_db_version > 11)
  CALL drr_add_sr_data("<=GETUPDATEBEFORES=>","GETUPDATEBEFORES")
 ELSE
  CALL drr_add_sr_data("<=GETUPDATEBEFORES=>","--GETUPDATEBEFORES")
 ENDIF
 IF (dmcpf_goldengate_version < 12
  AND dmcpf_target_db_version > 11)
  CALL drr_add_sr_data("<=NOCOMPRESSDELETES=>","NOCOMPRESSDELETES")
 ELSE
  CALL drr_add_sr_data("<=NOCOMPRESSDELETES=>","--NOCOMPRESSDELETES")
 ENDIF
 IF (dmcpf_goldengate_version > 11
  AND dmcpf_target_db_version > 11)
  CALL drr_add_sr_data("<=LOGALLSUPCOLS=>","LOGALLSUPCOLS")
 ELSE
  CALL drr_add_sr_data("<=LOGALLSUPCOLS=>","--LOGALLSUPCOLS")
 ENDIF
 IF (dmcpf_goldengate_version > 11)
  CALL drr_add_sr_data("<=MAXCOMMIT=>","--THREADOPTIONS MAXCOMMITPROPAGATIONDELAY 30000")
 ELSE
  CALL drr_add_sr_data("<=MAXCOMMIT=>","THREADOPTIONS MAXCOMMITPROPAGATIONDELAY 30000")
 ENDIF
 IF ((dmr_mig_data->src_ora_level1 > 11))
  CALL drr_add_sr_data("<=INTEGRATED=>",
   "DBOPTIONS integratedparams(_array_operation N) NOSUPPRESSTRIGGERS")
  CALL drr_add_sr_data("<=SOURCECATALOG=>",concat("sourcecatalog(",dmcpf_src_dbname,")"))
 ELSE
  CALL drr_add_sr_data("<=INTEGRATED=>","--Not Integrated")
  CALL drr_add_sr_data("<=SOURCECATALOG=>","--sourcecatalognotrequired")
 ENDIF
 IF ((dmr_mig_data->src_node_cnt > 1))
  FOR (dmcpf_cnt = 1 TO dmr_mig_data->src_node_cnt)
    IF ((dmr_mig_data->src_nodes[dmcpf_cnt].instance_number > 1))
     SET dmcpf_sqlexec_str = concat(dmcpf_sqlexec_str,char(10),'SQLEXEC " BEGIN & ',char(10),
      "MERGE INTO V500.DM_INFO@DM2MIGINST",
      trim(cnvtstring(dmr_mig_data->src_nodes[dmcpf_cnt].instance_number))," d & ",char(10),
      "USING DUAL ON (d.info_domain = 'DM2_MIG_INSTANCE_HEARTBEAT' and d.info_name = 'INSTANCE",trim(
       cnvtstring(dmr_mig_data->src_nodes[dmcpf_cnt].instance_number)),
      "') & ",char(10),"WHEN NOT MATCHED THEN & ",char(10),
      "    INSERT (d.info_domain,d.info_name) VALUES ('DM2_MIG_INSTANCE_HEARTBEAT', 'INSTANCE",
      trim(cnvtstring(dmr_mig_data->src_nodes[dmcpf_cnt].instance_number)),"')& ",char(10),
      "WHEN MATCHED THEN & ",char(10),
      "    UPDATE SET d.updt_cnt = d.updt_cnt + 1; & ",char(10),"commit; &  ",char(10),
      'END;" every 15 seconds ')
    ENDIF
  ENDFOR
  CALL drr_add_sr_data("<=SQLEXEC=>",dmcpf_sqlexec_str)
 ENDIF
 CALL drr_add_sr_data("<=GG_CAP_DIR=>",dmcpf_gg_cap_loc)
 IF (dmcpf_search_replace(concat(dm2_install_schema->cer_install,dmcpf_src_txt_file))=0)
  GO TO exit_program
 ENDIF
 SET drr_cmd_rec->tgt_filename = concat(dmcpf_capture_dir,dmcpf_src_prm_file)
 CALL echorecord(drr_cmd_rec)
 IF (dmcpf_write_cmds_to_file(null)=0)
  GO TO exit_program
 ENDIF
 IF (dmcpf_cappump_used=1)
  CALL drr_reset_cmd_rec(null)
  CALL drr_reset_search_rep_rec(null)
  CALL drr_add_sr_data("<=RMTHOST=>",concat("rmthost ",dmcpf_tgt_hostname," mgrport 7826"))
  CALL drr_add_sr_data("<=GG_DEL_DIR=>",dmcpf_gg_del_loc)
  IF ((dmr_mig_data->src_ora_level1 > 11))
   CALL drr_add_sr_data("<=SOURCECATALOG=>",concat("sourcecatalog(",dmcpf_src_dbname,")"))
  ELSE
   CALL drr_add_sr_data("<=SOURCECATALOG=>","")
  ENDIF
  IF (dmcpf_search_replace(concat(dm2_install_schema->cer_install,dmcpf_src_pmp_txt_file))=0)
   GO TO exit_program
  ENDIF
  SET drr_cmd_rec->tgt_filename = concat(dmcpf_capture_dir,dmcpf_src_pmp_prm_file)
  IF (dmcpf_write_cmds_to_file(null)=0)
   GO TO exit_program
  ENDIF
 ENDIF
 CALL drr_reset_cmd_rec(null)
 CALL drr_reset_search_rep_rec(null)
 IF (dmcpf_cappump_used=1)
  CALL drr_add_sr_data("<=PURGEEXTRACTS=>",concat("purgeoldextracts ",trim(dmcpf_gg_cap_loc,3),
    "/dirdat/aa, usecheckpoints, minkeephours 120"))
 ENDIF
 CALL drr_add_sr_data("<=GG_CAP_DIR=>",dmcpf_gg_cap_loc)
 IF (dmcpf_goldengate_version > 11)
  CALL drr_add_sr_data("<=DOWNCRITICAL=>","--downcritical")
 ELSE
  CALL drr_add_sr_data("<=DOWNCRITICAL=>","downcritical")
 ENDIF
 IF (dmcpf_search_replace(concat(dm2_install_schema->cer_install,dmcpf_src_mgr_txt_file))=0)
  GO TO exit_program
 ENDIF
 SET drr_cmd_rec->tgt_filename = concat(dmcpf_capture_dir,dmcpf_src_mgr_prm_file)
 IF (dmcpf_write_cmds_to_file(null)=0)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Find manual excluded tables for DDL inclusion"
 CALL disp_msg("",dm_err->logfile,0)
 SELECT INTO "nl:"
  d.info_name
  FROM dm_info d
  WHERE d.info_domain="DM2_MIG_EXCL"
   AND d.info_number=15
   AND d.info_char="1"
  DETAIL
   dmcpf_excl_tables_ddl_incl->cnt = (dmcpf_excl_tables_ddl_incl->cnt+ 1)
   IF (mod(dmcpf_excl_tables_ddl_incl->cnt,10)=1)
    stat = alterlist(dmcpf_excl_tables_ddl_incl->tbl,(dmcpf_excl_tables_ddl_incl->cnt+ 9))
   ENDIF
   IF ((dmr_mig_data->src_ora_level1=11)
    AND dmcpf_target_db_version > 11)
    dmcpf_excl_tables_ddl_incl->tbl[dmcpf_excl_tables_ddl_incl->cnt].tbl_str = concat(
     "INCLUDE ALL OBJNAME ",dmcpf_tgt_dbname,".",trim(cnvtlower(d.info_name))," &")
   ELSE
    dmcpf_excl_tables_ddl_incl->tbl[dmcpf_excl_tables_ddl_incl->cnt].tbl_str = concat(
     "INCLUDE ALL OBJNAME ",trim(cnvtlower(d.info_name))," &")
   ENDIF
  FOOT REPORT
   stat = alterlist(dmcpf_excl_tables_ddl_incl->tbl,dmcpf_excl_tables_ddl_incl->cnt)
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF ((dm_err->debug_flag > 2))
  CALL echorecord(dmcpf_excl_tables_ddl_incl)
 ENDIF
 SET dm_err->eproc = "Verify files needed exists."
 CALL disp_msg("",dm_err->logfile,0)
 IF (dm2_findfile(concat(dm2_install_schema->cer_install,dmcpf_tgt_txt_file))=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat(dmcpf_tgt_txt_file," is not found.")
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (dm2_findfile(concat(dm2_install_schema->cer_install,dmcpf_tgt_mgr_txt_file))=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat(dmcpf_tgt_mgr_txt_file," is not found.")
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (dm2_findfile(concat(dm2_install_schema->cer_install,dmcpf_tgt_macro_file))=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat(dmcpf_tgt_macro_file," is not found.")
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (dm2_findfile(concat(dm2_install_schema->cer_install,dmcpf_tgt_camacro_file))=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat(dmcpf_tgt_camacro_file," is not found.")
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (dm2_findfile(concat(dm2_install_schema->cer_install,dmcpf_tgt_trgmacro_file))=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat(dmcpf_tgt_trgmacro_file," is not found.")
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 CALL drr_reset_cmd_rec(null)
 CALL drr_reset_search_rep_rec(null)
 CALL drr_add_sr_data("<NLSLANG>",dmcpf_nlslang)
 CALL drr_add_sr_data("<TARGET_CONNECT_STRING>",dmcpf_tgt_cnnt_str)
 CALL drr_add_sr_data("<TARGET_V500_PASSWORD>",dmr_mig_data->tgt_v500_pwd)
 CALL drr_add_sr_data("<=GG_DEL_DIR=>",dmcpf_gg_del_loc)
 IF ((((dmr_mig_data->src_ora_level1 > 11)) OR (dmcpf_target_db_version > 11)) )
  CALL drr_add_sr_data("<=INTEGRATED=>",
   "DBOPTIONS integratedparams(_array_operation N) NOSUPPRESSTRIGGERS")
 ELSE
  CALL drr_add_sr_data("<=INTEGRATED=>","--Not Integrated")
 ENDIF
 IF ((dmr_mig_data->src_ora_level1 <= 11)
  AND dmcpf_target_db_version <= 11)
  CALL drr_add_sr_data("<=PDB=>","")
  CALL drr_add_sr_data("<=SOURCECATALOG=>","--sourcecatalognotrequired")
 ELSEIF ((dmr_mig_data->src_ora_level1 > 11)
  AND dmcpf_target_db_version > 11)
  CALL drr_add_sr_data("<=PDB=>","")
  CALL drr_add_sr_data("<=SOURCECATALOG=>",concat("sourcecatalog(",dmcpf_src_dbname,")"))
 ELSE
  CALL drr_add_sr_data("<=PDB=>",concat(dmcpf_tgt_dbname,"."))
  CALL drr_add_sr_data("<=SOURCECATALOG=>","--sourcecatalognotrequired")
 ENDIF
 IF (dmcpf_search_replace(concat(dm2_install_schema->cer_install,dmcpf_tgt_txt_file))=0)
  GO TO exit_program
 ENDIF
 SET drr_cmd_rec->tgt_filename = concat(dmcpf_delivery_dir,dmcpf_tgt_prm_file)
 IF (dmcpf_write_cmds_to_file(null)=0)
  GO TO exit_program
 ENDIF
 CALL drr_reset_cmd_rec(null)
 CALL drr_add_sr_data("<=GG_DEL_DIR=>",dmcpf_gg_del_loc)
 IF ((dmr_mig_data->src_ora_level1 <= 11)
  AND dmcpf_target_db_version <= 11)
  CALL drr_add_sr_data("<=PDB=>","")
  CALL drr_add_sr_data("<=SOURCECATALOG=>","--sourcecatalognotrequired")
 ELSEIF ((dmr_mig_data->src_ora_level1 > 11)
  AND dmcpf_target_db_version > 11)
  CALL drr_add_sr_data("<=SOURCECATALOG=>",concat("sourcecatalog(",dmcpf_src_dbname,")"))
  CALL drr_add_sr_data("<=PDB=>","")
 ELSE
  CALL drr_add_sr_data("<=SOURCECATALOG=>","--sourcecatalognotrequired")
  CALL drr_add_sr_data("<=PDB=>",concat(dmcpf_tgt_dbname,"."))
 ENDIF
 IF (dmcpf_search_replace(concat(dm2_install_schema->cer_install,dmcpf_tgt_otxt_file))=0)
  GO TO exit_program
 ENDIF
 SET drr_cmd_rec->tgt_filename = concat(dmcpf_delivery_dir,dmcpf_tgt_oprm_file)
 IF (dmcpf_write_cmds_to_file(null)=0)
  GO TO exit_program
 ENDIF
 CALL drr_reset_cmd_rec(null)
 CALL drr_add_sr_data("<=GG_DEL_DIR=>",dmcpf_gg_del_loc)
 IF ((dmr_mig_data->src_ora_level1 <= 11)
  AND dmcpf_target_db_version <= 11)
  CALL drr_add_sr_data("<=PDB=>","")
  CALL drr_add_sr_data("<=SOURCECATALOG=>","--sourcecatalognotrequired")
 ELSEIF ((dmr_mig_data->src_ora_level1 > 11)
  AND dmcpf_target_db_version > 11)
  CALL drr_add_sr_data("<=SOURCECATALOG=>",concat("sourcecatalog(",dmcpf_src_dbname,")"))
  CALL drr_add_sr_data("<=PDB=>","")
 ELSE
  CALL drr_add_sr_data("<=SOURCECATALOG=>","--sourcecatalognotrequired")
  CALL drr_add_sr_data("<=PDB=>",concat(dmcpf_tgt_dbname,"."))
 ENDIF
 IF (dmcpf_search_replace(concat(dm2_install_schema->cer_install,dmcpf_tgt_chtxt_file))=0)
  GO TO exit_program
 ENDIF
 SET drr_cmd_rec->tgt_filename = concat(dmcpf_delivery_dir,dmcpf_tgt_chprm_file)
 IF (dmcpf_write_cmds_to_file(null)=0)
  GO TO exit_program
 ENDIF
 CALL drr_reset_cmd_rec(null)
 CALL drr_add_sr_data("<=GG_DEL_DIR=>",dmcpf_gg_del_loc)
 IF ((dmr_mig_data->src_ora_level1 <= 11)
  AND dmcpf_target_db_version <= 11)
  CALL drr_add_sr_data("<=PDB=>","")
  CALL drr_add_sr_data("<=SOURCECATALOG=>","--sourcecatalognotrequired")
 ELSEIF ((dmr_mig_data->src_ora_level1 > 11)
  AND dmcpf_target_db_version > 11)
  CALL drr_add_sr_data("<=SOURCECATALOG=>",concat("sourcecatalog(",dmcpf_src_dbname,")"))
  CALL drr_add_sr_data("<=PDB=>","")
 ELSE
  CALL drr_add_sr_data("<=SOURCECATALOG=>","--sourcecatalognotrequired")
  CALL drr_add_sr_data("<=PDB=>",concat(dmcpf_tgt_dbname,"."))
 ENDIF
 IF (dmcpf_search_replace(concat(dm2_install_schema->cer_install,dmcpf_tgt_ditxt_file))=0)
  GO TO exit_program
 ENDIF
 SET drr_cmd_rec->tgt_filename = concat(dmcpf_delivery_dir,dmcpf_tgt_diprm_file)
 IF (dmcpf_write_cmds_to_file(null)=0)
  GO TO exit_program
 ENDIF
 CALL drr_reset_cmd_rec(null)
 CALL drr_add_sr_data("<=GG_DEL_DIR=>",dmcpf_gg_del_loc)
 IF ((dmr_mig_data->src_ora_level1 <= 11)
  AND dmcpf_target_db_version <= 11)
  CALL drr_add_sr_data("<=PDB=>","")
  CALL drr_add_sr_data("<=SOURCECATALOG=>","--sourcecatalognotrequired")
 ELSEIF ((dmr_mig_data->src_ora_level1 > 11)
  AND dmcpf_target_db_version > 11)
  CALL drr_add_sr_data("<=SOURCECATALOG=>",concat("sourcecatalog(",dmcpf_src_dbname,")"))
  CALL drr_add_sr_data("<=PDB=>","")
 ELSE
  CALL drr_add_sr_data("<=SOURCECATALOG=>","--sourcecatalognotrequired")
  CALL drr_add_sr_data("<=PDB=>",concat(dmcpf_tgt_dbname,"."))
 ENDIF
 IF (dmcpf_search_replace(concat(dm2_install_schema->cer_install,dmcpf_tgt_cytxt_file))=0)
  GO TO exit_program
 ENDIF
 SET drr_cmd_rec->tgt_filename = concat(dmcpf_delivery_dir,dmcpf_tgt_cyprm_file)
 IF (dmcpf_write_cmds_to_file(null)=0)
  GO TO exit_program
 ENDIF
 CALL drr_reset_cmd_rec(null)
 CALL drr_add_sr_data("<=GG_DEL_DIR=>",dmcpf_gg_del_loc)
 IF ((dmr_mig_data->src_ora_level1 <= 11)
  AND dmcpf_target_db_version <= 11)
  CALL drr_add_sr_data("<=PDB=>","")
  CALL drr_add_sr_data("<=SOURCECATALOG=>","--sourcecatalognotrequired")
 ELSEIF ((dmr_mig_data->src_ora_level1 > 11)
  AND dmcpf_target_db_version > 11)
  CALL drr_add_sr_data("<=SOURCECATALOG=>",concat("sourcecatalog(",dmcpf_src_dbname,")"))
  CALL drr_add_sr_data("<=PDB=>","")
 ELSE
  CALL drr_add_sr_data("<=SOURCECATALOG=>","--sourcecatalognotrequired")
  CALL drr_add_sr_data("<=PDB=>",concat(dmcpf_tgt_dbname,"."))
 ENDIF
 IF (dmcpf_search_replace(concat(dm2_install_schema->cer_install,dmcpf_tgt_cetxt_file))=0)
  GO TO exit_program
 ENDIF
 SET drr_cmd_rec->tgt_filename = concat(dmcpf_delivery_dir,dmcpf_tgt_ceprm_file)
 IF (dmcpf_write_cmds_to_file(null)=0)
  GO TO exit_program
 ENDIF
 CALL drr_reset_cmd_rec(null)
 CALL drr_reset_search_rep_rec(null)
 IF ((dmr_mig_data->src_ora_level1 <= 11)
  AND dmcpf_target_db_version <= 11)
  CALL drr_add_sr_data("<=PDB=>","")
  CALL drr_add_sr_data("<=SOURCECATALOG=>","--sourcecatalognotrequired")
 ELSEIF ((dmr_mig_data->src_ora_level1 > 11)
  AND dmcpf_target_db_version > 11)
  CALL drr_add_sr_data("<=PDB=>","")
  CALL drr_add_sr_data("<=SOURCECATALOG=>",concat("sourcecatalog(",dmcpf_src_dbname,")"))
 ELSE
  CALL drr_add_sr_data("<=PDB=>",concat(dmcpf_tgt_dbname,"."))
  CALL drr_add_sr_data("<=SOURCECATALOG=>","--sourcecatalognotrequired")
 ENDIF
 IF (dmcpf_search_replace(concat(dm2_install_schema->cer_install,dmcpf_tgt_macro_file))=0)
  GO TO exit_program
 ENDIF
 SET drr_cmd_rec->tgt_filename = concat(dmcpf_delivery_dir,dmcpf_tgt_macroprm_file)
 IF (dmcpf_write_cmds_to_file(null)=0)
  GO TO exit_program
 ENDIF
 CALL drr_reset_cmd_rec(null)
 CALL drr_reset_search_rep_rec(null)
 IF (dmcpf_search_replace(concat(dm2_install_schema->cer_install,dmcpf_tgt_trgmacro_file))=0)
  GO TO exit_program
 ENDIF
 SET drr_cmd_rec->tgt_filename = concat(dmcpf_delivery_dir,dmcpf_tgt_macrotrgprm_file)
 IF (dmcpf_write_cmds_to_file(null)=0)
  GO TO exit_program
 ENDIF
 CALL drr_reset_cmd_rec(null)
 CALL drr_reset_search_rep_rec(null)
 IF ((dmr_mig_data->src_ora_level1 <= 11)
  AND dmcpf_target_db_version <= 11)
  CALL drr_add_sr_data("<=PDB=>","")
  CALL drr_add_sr_data("<=SOURCECATALOG=>","--sourcecatalognotrequired")
 ELSEIF ((dmr_mig_data->src_ora_level1 > 11)
  AND dmcpf_target_db_version > 11)
  CALL drr_add_sr_data("<=PDB=>","")
  CALL drr_add_sr_data("<=SOURCECATALOG=>",concat("sourcecatalog(",dmcpf_src_dbname,")"))
 ELSE
  CALL drr_add_sr_data("<=PDB=>",concat(dmcpf_tgt_dbname,"."))
  CALL drr_add_sr_data("<=SOURCECATALOG=>","--sourcecatalognotrequired")
 ENDIF
 IF (dmcpf_search_replace(concat(dm2_install_schema->cer_install,dmcpf_tgt_camacro_file))=0)
  GO TO exit_program
 ENDIF
 SET drr_cmd_rec->tgt_filename = concat(dmcpf_delivery_dir,dmcpf_tgt_macrocaprm_file)
 IF (dmcpf_write_cmds_to_file(null)=0)
  GO TO exit_program
 ENDIF
 IF (dmcpf_utc_in_progress=1)
  IF (dum_fill_user_list(dmcpf_tgt_dbname)=0)
   GO TO exit_program
  ENDIF
  IF (dum_fill_v500_cust(dmcpf_tgt_dbname)=0)
   GO TO exit_program
  ENDIF
  IF ((((dus_v500_cust->tbl_cnt > 0)) OR ((dus_user_list->cnt > 0))) )
   IF (dum_cust_incl_abort_gen(dmcpf_tgt_dbname,dmr_mig_data->src_ora_level1,dmcpf_target_db_version)
   =0)
    GO TO exit_program
   ENDIF
  ENDIF
 ENDIF
 IF (dmr_load_di_filter(null)=0)
  GO TO exit_program
 ENDIF
 IF (dmr_get_di_filter(null)=0)
  GO TO exit_program
 ENDIF
 IF (dmr_create_di_macro(dmcpf_delivery_dir,dmcpf_goldengate_version)=0)
  GO TO exit_program
 ENDIF
 CALL drr_reset_cmd_rec(null)
 CALL drr_reset_search_rep_rec(null)
 IF (dmcpf_goldengate_version > 11)
  CALL drr_add_sr_data("<=DOWNCRITICAL=>","--downcritical")
 ELSE
  CALL drr_add_sr_data("<=DOWNCRITICAL=>","downcritical")
 ENDIF
 IF (dmcpf_search_replace(concat(dm2_install_schema->cer_install,dmcpf_tgt_mgr_txt_file))=0)
  GO TO exit_program
 ENDIF
 SET drr_cmd_rec->tgt_filename = concat(dmcpf_delivery_dir,dmcpf_tgt_mgr_prm_file)
 IF (dmcpf_write_cmds_to_file(null)=0)
  GO TO exit_program
 ENDIF
 GO TO exit_program
 SUBROUTINE dmcpf_search_replace(dsr_fname)
   SET dm_err->eproc = concat("replace tokens in ",dsr_fname," and insert into drr_cmd_rec")
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE dsr_cnt = i4 WITH protect, noconstant(0)
   DECLARE dsr_excl_tbl = i4 WITH protect, noconstant(0)
   DECLARE dsr_user = i4 WITH protect, noconstant(0)
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(drr_search_rep_rec)
   ENDIF
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(dsr_fname)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    DETAIL
     IF (findstring("<=TABLEEXCLUDE=>",trim(r.line),1,0) > 0)
      FOR (dsr_excl_tbl = 1 TO dmcpf_excl_tables->cnt)
        drr_cmd_rec->cmd_cnt = (drr_cmd_rec->cmd_cnt+ 1)
        IF (mod(drr_cmd_rec->cmd_cnt,10)=1)
         stat = alterlist(drr_cmd_rec->cmds,(drr_cmd_rec->cmd_cnt+ 9))
        ENDIF
        drr_cmd_rec->cmds[drr_cmd_rec->cmd_cnt].text = dmcpf_excl_tables->tbl[dsr_excl_tbl].tbl_str
      ENDFOR
     ELSEIF (findstring("<=TABLEEXCLUDE_DDLINCLUDE=>",trim(r.line),1,0) > 0)
      FOR (dsr_excl_tbl = 1 TO dmcpf_excl_tables_ddl_incl->cnt)
        drr_cmd_rec->cmd_cnt = (drr_cmd_rec->cmd_cnt+ 1)
        IF (mod(drr_cmd_rec->cmd_cnt,10)=1)
         stat = alterlist(drr_cmd_rec->cmds,(drr_cmd_rec->cmd_cnt+ 9))
        ENDIF
        drr_cmd_rec->cmds[drr_cmd_rec->cmd_cnt].text = dmcpf_excl_tables_ddl_incl->tbl[dsr_excl_tbl].
        tbl_str
      ENDFOR
     ELSEIF (((findstring("<=DELIV500_AC_EVENTACTION_ABORT=>",trim(r.line),1,0) > 0) OR (findstring(
      "<=DELIV500_CT_EVENTACTION_ABORT=>",trim(r.line),1,0) > 0)) )
      IF (dmcpf_utc_in_progress=1)
       FOR (dsr_user = 1 TO dmr_user_list->cnt)
         IF ((dmr_user_list->qual[dsr_user].user="V500"))
          drr_cmd_rec->cmd_cnt = (drr_cmd_rec->cmd_cnt+ 1)
          IF (mod(drr_cmd_rec->cmd_cnt,10)=1)
           stat = alterlist(drr_cmd_rec->cmds,(drr_cmd_rec->cmd_cnt+ 9))
          ENDIF
          IF (findstring("<=DELIV500_AC_EVENTACTION_ABORT=>",trim(r.line),1,0) > 0)
           IF ((dmr_mig_data->src_ora_level1=11)
            AND dmcpf_target_db_version > 11)
            drr_cmd_rec->cmds[drr_cmd_rec->cmd_cnt].text = concat(
             "INCLUDE MAPPED OPTYPE ALTER OBJTYPE TABLE OBJNAME ",dmcpf_tgt_dbname,".",dmr_user_list
             ->qual[dsr_user].user,^.* INSTRWORDS '" ADD " " NULL "' EVENTACTIONS (DISCARD, ABORT) &^
             )
           ELSE
            drr_cmd_rec->cmds[drr_cmd_rec->cmd_cnt].text = concat(
             "INCLUDE MAPPED OPTYPE ALTER OBJTYPE TABLE OBJNAME ",dmr_user_list->qual[dsr_user].user,
             ^.* INSTRWORDS '" ADD " " NULL "' EVENTACTIONS (DISCARD, ABORT) &^)
           ENDIF
          ELSE
           IF ((dmr_mig_data->src_ora_level1=11)
            AND dmcpf_target_db_version > 11)
            drr_cmd_rec->cmds[drr_cmd_rec->cmd_cnt].text = concat(
             "INCLUDE MAPPED OPTYPE CREATE OBJTYPE TABLE OBJNAME ",dmcpf_tgt_dbname,".",dmr_user_list
             ->qual[dsr_user].user,".* INSTR 'CREATE TABLE' EVENTACTIONS (DISCARD, ABORT) &")
           ELSE
            drr_cmd_rec->cmds[drr_cmd_rec->cmd_cnt].text = concat(
             "INCLUDE MAPPED OPTYPE CREATE OBJTYPE TABLE OBJNAME  ",dmr_user_list->qual[dsr_user].
             user,".* INSTR 'CREATE TABLE' EVENTACTIONS (DISCARD, ABORT) &")
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
     ELSEIF (findstring("<=AC_V500_EVENTACTION_ABORT=>",trim(r.line),1,0) > 0)
      IF (dmcpf_utc_in_progress=1)
       drr_cmd_rec->cmd_cnt = (drr_cmd_rec->cmd_cnt+ 1)
       IF (mod(drr_cmd_rec->cmd_cnt,10)=1)
        stat = alterlist(drr_cmd_rec->cmds,(drr_cmd_rec->cmd_cnt+ 9))
       ENDIF
       IF ((dmr_mig_data->src_ora_level1=11)
        AND dmcpf_target_db_version > 11)
        drr_cmd_rec->cmds[drr_cmd_rec->cmd_cnt].text = concat(
         "INCLUDE MAPPED OPTYPE ALTER OBJTYPE TABLE OBJNAME ",dmcpf_tgt_dbname,".V500.*",
         ^ INSTRWORDS '" ADD " " NULL "' EVENTACTIONS (DISCARD, ABORT);^)
       ELSE
        drr_cmd_rec->cmds[drr_cmd_rec->cmd_cnt].text = concat(
         "INCLUDE MAPPED OPTYPE ALTER OBJTYPE TABLE OBJNAME V500.*",
         ^ INSTRWORDS '" ADD " " NULL "' EVENTACTIONS (DISCARD, ABORT);^)
       ENDIF
      ELSE
       drr_cmd_rec->cmd_cnt = (drr_cmd_rec->cmd_cnt+ 1)
       IF (mod(drr_cmd_rec->cmd_cnt,10)=1)
        stat = alterlist(drr_cmd_rec->cmds,(drr_cmd_rec->cmd_cnt+ 9))
       ENDIF
       IF (dmcpf_goldengate_version > 11)
        IF (dmcpf_target_db_version > 11)
         drr_cmd_rec->cmds[drr_cmd_rec->cmd_cnt].text = concat(
          "INCLUDE MAPPED OPTYPE ALTER OBJTYPE TABLE OBJNAME ",dmcpf_tgt_dbname,".V500.*",
          ^ INSTRWORDS '" ADD " " NULL "' EVENTACTIONS (LOG INFO);^)
        ELSE
         drr_cmd_rec->cmds[drr_cmd_rec->cmd_cnt].text = concat(
          "INCLUDE MAPPED OPTYPE ALTER OBJTYPE TABLE OBJNAME V500.*",
          ^ INSTRWORDS '" ADD " " NULL "' EVENTACTIONS (LOG INFO);^)
        ENDIF
       ELSE
        drr_cmd_rec->cmds[drr_cmd_rec->cmd_cnt].text = concat(
         "INCLUDE MAPPED OPTYPE ALTER OBJTYPE TABLE OBJNAME V500.*",
         ^ INSTRWORDS '" ADD " " NULL "' EVENTACTIONS (LOG);^)
       ENDIF
      ENDIF
     ELSEIF (findstring("<=RDDS_AC_EVENTACTION_ABORT=>",trim(r.line),1,0) > 0)
      IF (dmcpf_utc_in_progress=1)
       drr_cmd_rec->cmd_cnt = (drr_cmd_rec->cmd_cnt+ 1)
       IF (mod(drr_cmd_rec->cmd_cnt,10)=1)
        stat = alterlist(drr_cmd_rec->cmds,(drr_cmd_rec->cmd_cnt+ 9))
       ENDIF
       IF ((dmr_mig_data->src_ora_level1=11)
        AND dmcpf_target_db_version > 11)
        drr_cmd_rec->cmds[drr_cmd_rec->cmd_cnt].text = concat(
         "INCLUDE MAPPED OPTYPE ALTER OBJTYPE TABLE OBJNAME ",dmcpf_tgt_dbname,".V500.*",
         " INSTRCOMMENTS 'DM2MIG RDDS SOURCE DDL ONLY' EVENTACTIONS (DISCARD, ABORT) &")
       ELSE
        drr_cmd_rec->cmds[drr_cmd_rec->cmd_cnt].text = concat(
         "INCLUDE MAPPED OPTYPE ALTER OBJTYPE TABLE OBJNAME V500.*",
         " INSTRCOMMENTS 'DM2MIG RDDS SOURCE DDL ONLY' EVENTACTIONS (DISCARD, ABORT) &")
       ENDIF
      ENDIF
     ELSEIF (findstring("<=TABLE=>",trim(r.line),1,0) > 0)
      FOR (dsr_user = 1 TO dmr_user_list->cnt)
        drr_cmd_rec->cmd_cnt = (drr_cmd_rec->cmd_cnt+ 1)
        IF (mod(drr_cmd_rec->cmd_cnt,10)=1)
         stat = alterlist(drr_cmd_rec->cmds,(drr_cmd_rec->cmd_cnt+ 9))
        ENDIF
        drr_cmd_rec->cmds[drr_cmd_rec->cmd_cnt].text = concat("table ",dmr_user_list->qual[dsr_user].
         user,".*;")
      ENDFOR
     ELSEIF (findstring("<=MAPUSER=>",trim(r.line),1,0) > 0)
      FOR (dsr_user = 1 TO dmr_user_list->cnt)
        drr_cmd_rec->cmd_cnt = (drr_cmd_rec->cmd_cnt+ 1)
        IF (mod(drr_cmd_rec->cmd_cnt,10)=1)
         stat = alterlist(drr_cmd_rec->cmds,(drr_cmd_rec->cmd_cnt+ 9))
        ENDIF
        drr_cmd_rec->cmds[drr_cmd_rec->cmd_cnt].text = concat("map ",dmr_user_list->qual[dsr_user].
         user,".*, target ",dmr_user_list->qual[dsr_user].user,".*;")
      ENDFOR
     ELSEIF (findstring("<=LOGOPTIONS=>",trim(r.line),1,0) > 0)
      IF ((dm_err->debug_flag > 0))
       CALL echo("Skipping LOGOPTIONS line for UNIX.")
      ENDIF
     ELSEIF (dmcpf_cappump_used=0
      AND findstring("<=PURGEEXTRACTS=>",trim(r.line),1,0) > 0)
      IF ((dm_err->debug_flag > 0))
       CALL echo("Skipping PURGEEXTRACTS line for no CAPPUMP files.")
      ENDIF
     ELSEIF ((dmr_mig_data->src_node_cnt=1)
      AND findstring("<=SQLEXEC=>",trim(r.line),1,0) > 0)
      IF ((dm_err->debug_flag > 0))
       CALL echo("Skipping SQLEXEC line for Single Instance database.")
      ENDIF
     ELSEIF ((dmr_mig_data->src_storage_type != "ASM")
      AND findstring("<=ASM_CONNECTION_INFO=>",trim(r.line),1,0) > 0)
      IF ((dm_err->debug_flag > 0))
       CALL echo("Skipping ASM_CONNECTION_INFO line for non ASM Source storage.")
      ENDIF
     ELSE
      dmcpf_cmd = trim(r.line)
      FOR (dsr_cnt = 1 TO drr_search_rep_rec->elem_cnt)
        IF (findstring(drr_search_rep_rec->elems[dsr_cnt].search_val,dmcpf_cmd,1,0) > 0)
         dmcpf_cmd = replace(dmcpf_cmd,drr_search_rep_rec->elems[dsr_cnt].search_val,
          drr_search_rep_rec->elems[dsr_cnt].replace_val,0)
         IF ((dm_err->debug_flag > 1))
          CALL echo(dmcpf_cmd)
         ENDIF
        ENDIF
      ENDFOR
      drr_cmd_rec->cmd_cnt = (drr_cmd_rec->cmd_cnt+ 1)
      IF (mod(drr_cmd_rec->cmd_cnt,10)=1)
       stat = alterlist(drr_cmd_rec->cmds,(drr_cmd_rec->cmd_cnt+ 9))
      ENDIF
      drr_cmd_rec->cmds[drr_cmd_rec->cmd_cnt].text = dmcpf_cmd
     ENDIF
    FOOT REPORT
     stat = alterlist(drr_cmd_rec->cmds,drr_cmd_rec->cmd_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(drr_cmd_rec)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmcpf_get_gg_dir(dggd_line_nbr,dggd_dir_type,dggd_dir_name)
   DECLARE dggd_dir_size = i2 WITH protect, noconstant(0)
   CALL text(dggd_line_nbr,2,concat(dggd_dir_type," parameter file directory location :"))
   CALL accept(dggd_line_nbr,64,"P(30);C",dggd_dir_name
    WHERE curaccept != "")
   SET dggd_dir_name = trim(curaccept)
   SET dggd_dir_size = size(dggd_dir_name)
   IF (substring(dggd_dir_size,1,dggd_dir_name) != "/")
    SET dggd_dir_name = concat(dggd_dir_name,"/")
   ENDIF
   IF (dm2_find_dir(dggd_dir_name)=0)
    CALL clear(1,1)
    SET message = nowindow
    SET dm_err->err_ind = 1
    SET dm_err->emsg = dm_err->eproc
    SET dm_err->eproc = "Verify parm directory exists"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmcpf_get_nlslang(dgn_nlslang_out)
   DECLARE drem_language = vc WITH protect, noconstant("")
   DECLARE drem_territory = vc WITH protect, noconstant("")
   DECLARE drem_characterset = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Determining character set from v$nls_parameters."
   SELECT INTO "nl:"
    FROM v$nls_parameters p
    WHERE p.parameter IN ("NLS_LANGUAGE", "NLS_TERRITORY", "NLS_CHARACTERSET")
    DETAIL
     CASE (p.parameter)
      OF "NLS_LANGUAGE":
       drem_language = p.value
      OF "NLS_TERRITORY":
       drem_territory = p.value
      OF "NLS_CHARACTERSET":
       drem_characterset = p.value
     ENDCASE
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dgn_nlslang_out = concat(drem_language,"_",drem_territory,".",drem_characterset)
   IF ((dm_err->debug_flag > 0))
    CALL echo(dgn_nlslang_out)
   ENDIF
   IF (((drem_language < " ") OR (((drem_territory < " ") OR (drem_characterset < " ")) )) )
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Unable to obtain NLS_CHARACTERSET."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmcpf_write_cmds_to_file(null)
   DECLARE dwc_trim_text = vc WITH protect, noconstant(" ")
   SELECT INTO value(drr_cmd_rec->tgt_filename)
    d.seq
    FROM (dummyt d  WITH seq = drr_cmd_rec->cmd_cnt)
    DETAIL
     dwc_trim_text = trim(drr_cmd_rec->cmds[d.seq].text), col 0, dwc_trim_text
     IF ((d.seq < drr_cmd_rec->cmd_cnt))
      row + 1
     ENDIF
    WITH nocounter, maxrow = 1, format = lfstream,
     noformfeed, maxcol = 2000
   ;end select
   IF (check_error(concat("Error writing ",drr_cmd_rec->tgt_filename,"."))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dmcpf_get_con_str(dgcs_db_name)
   SELECT INTO "nl:"
    FROM v$database v
    DETAIL
     dgcs_db_name = trim(cnvtupper(v.name))
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_program
 SET message = nowindow
 SET dm_err->eproc = "DM2_MIG_CREATE_PARM_FILES completed successfully"
 CALL final_disp_msg(dmcpf_logfile_prefix)
END GO
