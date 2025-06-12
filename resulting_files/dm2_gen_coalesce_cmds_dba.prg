CREATE PROGRAM dm2_gen_coalesce_cmds:dba
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
 DECLARE dpq_process_queue_row(null) = i2
 DECLARE dpq_update_queue_row(duqr_success=i2(ref)) = i2
 DECLARE dpq_cleanup_old_procs(dcop_proc_type=vc,dcop_maxcommit=i4) = i2
 DECLARE dpq_execute_command(dec_success=i2(ref)) = i2
 DECLARE dpq_populate_queue_rows(dpqr_proc_type=vc) = i2
 DECLARE dpq_lock_queue_row(dlqr_success=i2(ref)) = i2
 DECLARE dpq_check_end_time(dcet_beg_dt_tm=dq8,dcet_proc=vc,dcet_continue_ind=i2(ref)) = i2
 DECLARE dpq_manage_end_time(dmet_prompt_ind=i2,dmet_proc_type=vc,dmet_end_time=i4) = i2
 DECLARE dpq_remove_procs(drp_proc_type=vc,drp_status=vc,drp_maxcommit=i4) = i2
 IF ((validate(dpq_process_queue->dm_process_queue_id,- (1))=- (1))
  AND (validate(dpq_process_queue->dm_process_queue_id,- (2))=- (2)))
  FREE RECORD dpq_process_queue
  RECORD dpq_process_queue(
    1 dm_process_queue_id = f8
    1 process_type = vc
    1 op_type = vc
    1 owner_name = vc
    1 object_type = vc
    1 object_name = vc
    1 operation_txt = vc
    1 process_status = vc
    1 message_txt = vc
    1 op_method = vc
    1 priority = i4
    1 routine_tasks_ind = i2
  )
 ENDIF
 IF ((validate(dpq_proc_list->proc_cnt,- (1))=- (1))
  AND (validate(dpq_proc_list->proc_cnt,- (2))=- (2)))
  FREE RECORD dpq_proc_list
  RECORD dpq_proc_list(
    1 proc_cnt = i4
    1 qual[*]
      2 dm_process_queue_id = f8
      2 process_type = vc
      2 operation_txt = vc
      2 op_method = vc
  )
  DECLARE dpq_statistics = vc WITH protect, constant("STATISTICS")
  DECLARE dpq_freq_statistics = vc WITH protect, constant("STATISTICS_FREQ_GATHER")
  DECLARE dpq_notnull_validate = vc WITH protect, constant("NOTNULL_VALIDATION")
  DECLARE dpq_routine_tasks = vc WITH protect, constant("ROUTINE_TASKS")
  DECLARE dpq_index_coalesce = vc WITH protect, constant("INDEX_COALESCE")
  DECLARE dpq_clinical_ranges = vc WITH protect, constant("CLINICAL_RANGES")
  DECLARE dpq_gather = vc WITH protect, constant("GATHER")
  DECLARE dpq_validate = vc WITH protect, constant("VALIDATE")
  DECLARE dpq_coalesce = vc WITH protect, constant("COALESCE")
  DECLARE dpq_queued = vc WITH protect, constant("QUEUED")
  DECLARE dpq_executing = vc WITH protect, constant("EXECUTING")
  DECLARE dpq_failure = vc WITH protect, constant("FAILURE")
  DECLARE dpq_success = vc WITH protect, constant("SUCCESS")
  DECLARE dpq_table = vc WITH protect, constant("TABLE")
  DECLARE dpq_index = vc WITH protect, constant("INDEX")
  DECLARE dpq_schema = vc WITH protect, constant("SCHEMA")
  DECLARE dpq_constraint = vc WITH protect, constant("CONSTRAINT")
  DECLARE dpq_db = vc WITH protect, constant("DB")
  DECLARE dpq_dcl = vc WITH protect, constant("DCL")
 ENDIF
 SUBROUTINE dpq_process_queue_row(null)
   SET dm_err->eproc = "Validating inputs for dpq_process_queue_row"
   IF ("" IN (trim(dpq_process_queue->process_type), trim(dpq_process_queue->op_type), trim(
    dpq_process_queue->owner_name), trim(dpq_process_queue->object_type), trim(dpq_process_queue->
    object_name),
   trim(dpq_process_queue->operation_txt)))
    SET dm_err->emsg =
    "Must populate PROC_TYPE, OP_TYPE, owner_name, OBJECT_TYPE, operation_txt and OBJECT_NAME"
    CALL disp_msg(dm_err->eproc,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Checking for an existing row from dm_process_queue."
   SELECT INTO "nl:"
    FROM dm_process_queue dpq
    WHERE (dpq.process_type=dpq_process_queue->process_type)
     AND (dpq.op_type=dpq_process_queue->op_type)
     AND (dpq.owner_name=dpq_process_queue->owner_name)
     AND (dpq.object_type=dpq_process_queue->object_type)
     AND (dpq.object_name=dpq_process_queue->object_name)
    DETAIL
     dpq_process_queue->dm_process_queue_id = dpq.dm_process_queue_id, dpq_process_queue->
     process_status = dpq.process_status
    WITH nocounter, maxqual(dpq,1)
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual
    AND (dpq_process_queue->process_status != dpq_executing))
    SET dm_err->eproc = "Updating dm_process_queue row."
    UPDATE  FROM dm_process_queue dpq
     SET dpq.process_status = dpq_queued, dpq.operation_txt = dpq_process_queue->operation_txt, dpq
      .op_method = dpq_process_queue->op_method,
      dpq.message_txt = "", dpq.audsid = "", dpq.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      dpq.priority = evaluate(dpq_process_queue->priority,0,dpq.priority,dpq_process_queue->priority),
      dpq.routine_tasks_ind = dpq_process_queue->routine_tasks_ind
     WHERE (dpq.dm_process_queue_id=dpq_process_queue->dm_process_queue_id)
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    COMMIT
   ELSEIF (curqual
    AND (dpq_process_queue->process_status=dpq_executing))
    UPDATE  FROM dm_process_queue dpq
     SET dpq.updt_dt_tm = cnvtdatetime(curdate,curtime3), dpq.priority = evaluate(dpq_process_queue->
       priority,0,dpq.priority,dpq_process_queue->priority), dpq.routine_tasks_ind =
      dpq_process_queue->routine_tasks_ind
     WHERE (dpq.dm_process_queue_id=dpq_process_queue->dm_process_queue_id)
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    COMMIT
   ELSE
    SET dm_err->eproc = "Selecting new dm_process_queue_id from dual"
    SELECT INTO "nl:"
     new_id = seq(dm_clinical_seq,nextval)
     FROM dual d
     DETAIL
      dpq_process_queue->dm_process_queue_id = new_id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Inserting dm_process_queue row."
    INSERT  FROM dm_process_queue dpq
     SET dpq.process_type = dpq_process_queue->process_type, dpq.dm_process_queue_id =
      dpq_process_queue->dm_process_queue_id, dpq.op_type = dpq_process_queue->op_type,
      dpq.owner_name = dpq_process_queue->owner_name, dpq.object_type = dpq_process_queue->
      object_type, dpq.object_name = dpq_process_queue->object_name,
      dpq.operation_txt = dpq_process_queue->operation_txt, dpq.op_method = dpq_process_queue->
      op_method, dpq.process_status = dpq_queued,
      dpq.priority = evaluate(dpq_process_queue->priority,0,100,dpq_process_queue->priority), dpq
      .routine_tasks_ind = dpq_process_queue->routine_tasks_ind, dpq.gen_dt_tm = cnvtdatetime(curdate,
       curtime3),
      dpq.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpq_update_queue_row(duqr_success)
   SET dm_err->eproc = "Updating dm_process_queue row"
   SET duqr_success = 0
   UPDATE  FROM dm_process_queue dpq
    SET dpq.process_status = dpq_process_queue->process_status, dpq.message_txt = evaluate(trim(
       dpq_process_queue->message_txt),"",dpq.message_txt,dpq_process_queue->message_txt), dpq.audsid
      = "",
     dpq.end_dt_tm = cnvtdatetime(curdate,curtime3), dpq.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (dpq.dm_process_queue_id=dpq_process_queue->dm_process_queue_id)
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc))
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (curqual)
    SET duqr_success = 1
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpq_cleanup_old_procs(dcop_proc_type,dcop_maxcommit)
   DECLARE dcop_continue_ind = i2 WITH protect, noconstant(1)
   DECLARE dcop_tmp_where_clause = vc WITH protect, noconstant("")
   IF (dcop_proc_type=dpq_routine_tasks)
    SET dcop_tmp_where_clause = "dpq.routine_tasks_ind = 1"
   ELSE
    SET dcop_tmp_where_clause = "dpq.process_type = value(dcop_proc_type)"
   ENDIF
   SET dm_err->eproc = "Updating queued rows from DM_PROCESS_QUEUE"
   WHILE (dcop_continue_ind)
     UPDATE  FROM dm_process_queue dpq
      SET dpq.process_status = dpq_queued, dpq.priority = sqlpassthru(
        "least(dpq.priority + 1, floor(dpq.priority/10)*10 + 9)"), dpq.message_txt = ""
      WHERE parser(dcop_tmp_where_clause)
       AND ((dpq.process_status=dpq_failure) OR (dpq.process_status=dpq_executing
       AND (( NOT (dpq.audsid IN (
      (SELECT
       cnvtstring(gvs.audsid)
       FROM gv$session gvs)))) OR (dpq.audsid=currdbhandle)) ))
      WITH nocounter, maxqual(dpq,value(dcop_maxcommit))
     ;end update
     IF (check_error(dm_err->eproc))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN(0)
     ENDIF
     SET dcop_continue_ind = curqual
     COMMIT
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpq_lock_queue_row(dlqr_success)
   SET dlqr_success = 0
   SET dm_err->eproc = "Attempting to update DM_PROCESS_QUEUE row to executing."
   UPDATE  FROM dm_process_queue dpq
    SET dpq.process_status = dpq_executing, dpq.begin_dt_tm = cnvtdatetime(curdate,curtime3), dpq
     .audsid = currdbhandle
    WHERE (dpq.dm_process_queue_id=dpq_process_queue->dm_process_queue_id)
     AND dpq.process_status=dpq_queued
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ELSEIF (curqual)
    SET dlqr_success = 1
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpq_populate_queue_rows(dpqr_proc_type)
   DECLARE dpqr_tmp = i4 WITH protect, noconstant(0)
   DECLARE dpqr_tmp_where_clause = vc WITH protect, noconstant("")
   IF (dpqr_proc_type=dpq_routine_tasks)
    SET dpqr_tmp_where_clause = "dpq.routine_tasks_ind = 1"
   ELSE
    SET dpqr_tmp_where_clause = "dpq.process_type = value(dpqr_proc_type)"
   ENDIF
   IF (validate(dpqrs_exec_ind,- (1))=1)
    IF ( NOT (validate(dpqrs_dpq_id,- (1)) <= 0.0))
     SET dpqr_tmp_where_clause = concat(dpqr_tmp_where_clause,
      " and dpq.dm_process_queue_id = value(dpqrs_dpq_id)")
    ELSE
     SET dm_err->eproc =
     "DPQ_POPULATE_QUEUE_ROWS was called via dm2_process_queue_runner_single with no valid dpq_id"
     CALL disp_msg(" ",dm_err->logfile,0)
     RETURN(1)
    ENDIF
   ENDIF
   SET dpq_proc_list->proc_cnt = 0
   SET stat = alterlist(dpq_proc_list->qual,0)
   SET dm_err->eproc = "Loading operations to run from DM_PROCESS_QUEUE"
   SELECT INTO "nl:"
    FROM dm_process_queue dpq
    WHERE dpq.process_status=dpq_queued
     AND parser(dpqr_tmp_where_clause)
    ORDER BY dpq.priority, dpq.gen_dt_tm
    DETAIL
     dpq_proc_list->proc_cnt = (dpq_proc_list->proc_cnt+ 1)
     IF ((dpq_proc_list->proc_cnt > dpqr_tmp))
      dpqr_tmp = (dpqr_tmp+ 50), stat = alterlist(dpq_proc_list->qual,dpqr_tmp)
     ENDIF
     dpq_proc_list->qual[dpq_proc_list->proc_cnt].dm_process_queue_id = dpq.dm_process_queue_id,
     dpq_proc_list->qual[dpq_proc_list->proc_cnt].process_type = dpq.process_type, dpq_proc_list->
     qual[dpq_proc_list->proc_cnt].operation_txt = dpq.operation_txt,
     dpq_proc_list->qual[dpq_proc_list->proc_cnt].op_method = dpq.op_method
    FOOT REPORT
     stat = alterlist(dpq_proc_list->qual,dpq_proc_list->proc_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpq_execute_command(dec_success)
   SET dm_err->eproc = "Validating inputs for dpq_execute_command"
   IF ("" IN (trim(dpq_process_queue->op_method), trim(dpq_process_queue->operation_txt)))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "DPQ_EXECUTE_COMMAND was called with no operation_txt or op_method"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dpq_process_queue->process_status = dpq_failure
    SET dpq_process_queue->message_txt = dm_err->emsg
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Executing operation_txt: ",dpq_process_queue->op_method,":",
    dpq_process_queue->operation_txt)
   IF ((dpq_process_queue->op_method=dpq_db))
    SET dec_success = dm2_push_cmd(dpq_process_queue->operation_txt,1)
    IF (dm_err->err_ind)
     SET dec_success = 0
    ENDIF
   ELSEIF ((dpq_process_queue->op_method=dpq_dcl))
    SET dec_success = dm2_push_dcl(dpq_process_queue->operation_txt)
    IF (dm_err->err_ind)
     SET dec_success = 0
    ENDIF
   ENDIF
   IF (dec_success)
    SET dpq_process_queue->process_status = dpq_success
    SET dpq_process_queue->message_txt = ""
   ELSE
    SET dpq_process_queue->process_status = dpq_failure
    SET dpq_process_queue->message_txt = dm_err->emsg
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpq_check_end_time(dcet_beg_dt_tm,dcet_proc,dcet_continue_ind)
   DECLARE dcet_tgt_end_time = dq8 WITH protect, noconstant(cnvtdatetime(curdate,cnvttime(360)))
   DECLARE dcet_fallout_ind = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Selecting end_time from DM_INFO"
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain IN ("DM_PROCESS_QUEUE_RUNNER_END_TIME", "DM_PROCESS_QUEUE_RUNNER_FALLOUT")
     AND di.info_name=dcet_proc
    DETAIL
     IF (di.info_domain="DM_PROCESS_QUEUE_RUNNER_FALLOUT")
      dcet_fallout_ind = 1
     ELSE
      IF ((di.info_number=- (1)))
       dcet_tgt_end_time = datetimeadd(cnvtdatetime(curdate,curtime3),1)
      ELSE
       dcet_tgt_end_time = cnvtdatetime(curdate,cnvttime(di.info_number))
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dcet_beg_dt_tm > dcet_tgt_end_time)
    SET dcet_tgt_end_time = datetimeadd(dcet_tgt_end_time,1)
   ENDIF
   IF (((cnvtdatetime(curdate,curtime3) > dcet_tgt_end_time) OR (dcet_fallout_ind=1)) )
    IF (dcet_fallout_ind=1)
     SET dm_err->eproc =
     "Ending dm2_process_queue_runner because Fallout Indicator row was found in dm_info"
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SET dcet_continue_ind = 0
   ELSE
    SET dcet_continue_ind = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpq_manage_end_time(dmet_prompt_ind,dmet_proc_type,dmet_end_time)
   DECLARE dmet_new_end_time = i4 WITH protect, noconstant(dmet_end_time)
   DECLARE dmet_update_ind = i2 WITH protect, noconstant(0)
   DECLARE dmet_menu_select = vc WITH protect, noconstant("M")
   IF (dmet_prompt_ind)
    SET dmet_new_end_time = 360
   ENDIF
   SET dm_err->eproc = "Checking for existence of end_time row from DM_INFO"
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM_PROCESS_QUEUE_RUNNER_END_TIME"
     AND di.info_name=dmet_proc_type
    DETAIL
     IF (dmet_prompt_ind)
      dmet_new_end_time = di.info_number
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    SET dmet_update_ind = curqual
   ENDIF
   WHILE (true)
    IF (dmet_prompt_ind)
     SET message = window
     SET width = 132
     CALL clear(1,1)
     CALL box(1,1,24,131)
     CALL text(2,2,concat(dmet_proc_type,notrim(" job menu")))
     CALL text(5,10,concat("Input the hour you want the ",dmet_proc_type,
       " job to stop at (0-23) [use -1 for no end time]:"))
     CALL text(6,10,concat("Hours:",evaluate(dmet_new_end_time,- (1),"Unlimited",cnvtstring(floor((
          dmet_new_end_time/ 60))))))
     CALL text(7,10,concat("Input the minutes you want the ",dmet_proc_type,notrim(
        " job to stop at (0-59):")))
     CALL text(8,10,concat("Minutes:",cnvtstring(evaluate(dmet_new_end_time,- (1),0,mod(
          dmet_new_end_time,60)))))
     CALL text(10,10,"(C)ontinue, (M)odify, (Q)uit:")
     CALL accept(10,41,"A;CU",dmet_menu_select
      WHERE curaccept IN ("C", "M", "Q"))
     SET dmet_menu_select = curaccept
     IF (dmet_menu_select="C")
      SET message = nowindow
      CALL clear(1,1)
     ENDIF
    ELSE
     SET dmet_menu_select = "C"
    ENDIF
    CASE (dmet_menu_select)
     OF "Q":
      RETURN(1)
     OF "C":
      IF (dmet_update_ind)
       SET dm_err->eproc = "Updating end_time row into DM_INFO"
       UPDATE  FROM dm_info di
        SET di.info_number = dmet_new_end_time
        WHERE di.info_domain="DM_PROCESS_QUEUE_RUNNER_END_TIME"
         AND di.info_name=dmet_proc_type
        WITH nocounter
       ;end update
       IF (check_error(dm_err->eproc))
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        RETURN(0)
       ELSE
        COMMIT
       ENDIF
      ELSE
       SET dm_err->eproc = "Inserting end_time row into DM_INFO"
       INSERT  FROM dm_info di
        SET di.info_domain = "DM_PROCESS_QUEUE_RUNNER_END_TIME", di.info_name = dmet_proc_type, di
         .info_number = dmet_new_end_time
        WITH nocounter
       ;end insert
       IF (check_error(dm_err->eproc))
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        RETURN(0)
       ELSE
        COMMIT
       ENDIF
      ENDIF
      RETURN(1)
     OF "M":
      SET dmet_menu_select = "C"
      CALL accept(6,16,"NN;",evaluate(dmet_new_end_time,- (1),- (1),floor((dmet_new_end_time/ 60)))
       WHERE curaccept BETWEEN - (1) AND 23)
      SET dmet_new_end_time = evaluate(curaccept,- (1),- (1),(60 * curaccept))
      IF ((dmet_new_end_time != - (1)))
       CALL accept(8,18,"99;",0
        WHERE curaccept BETWEEN 0 AND 59)
       SET dmet_new_end_time = (dmet_new_end_time+ curaccept)
      ENDIF
    ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE dpq_remove_procs(drp_proc_type,drp_status,drp_maxcommit)
   DECLARE drp_continue_ind = i2 WITH protect, noconstant(1)
   DECLARE drp_tmp_where_clause = vc WITH protect, noconstant("")
   IF (drp_proc_type=dpq_routine_tasks)
    SET drp_tmp_where_clause = "dpq.routine_tasks_ind = 1"
   ELSE
    SET drp_tmp_where_clause = "dpq.process_type = value(drp_proc_type)"
   ENDIF
   SET dm_err->eproc = concat("Clearing out ",drp_proc_type," rows with status of ",drp_status)
   CALL disp_msg("",dm_err->logfile,0)
   WHILE (drp_continue_ind)
     DELETE  FROM dm_process_queue dpq
      WHERE dpq.process_status=drp_status
       AND parser(drp_tmp_where_clause)
      WITH nocounter, maxqual(dpq,value(drp_maxcommit))
     ;end delete
     IF (check_error(dm_err->eproc))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN(0)
     ENDIF
     COMMIT
     SET drp_continue_ind = curqual
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dpq_cleanup_stranded_procs(dcsp_proc_type,dcsp_maxcommit)
   DECLARE dcsp_continue_ind = i2 WITH protect, noconstant(1)
   DECLARE dcsp_tmp_where_clause = vc WITH protect, noconstant("")
   IF (dcsp_proc_type=dpq_routine_tasks)
    SET dcsp_tmp_where_clause = "dpq.routine_tasks_ind = 1"
   ELSE
    SET dcsp_tmp_where_clause = "dpq.process_type = value(dcsp_proc_type)"
   ENDIF
   SET dm_err->eproc = "Updating stranded rows from DM_PROCESS_QUEUE"
   WHILE (dcsp_continue_ind)
     UPDATE  FROM dm_process_queue dpq
      SET dpq.process_status = dpq_failure, dpq.priority = sqlpassthru(
        "least(dpq.priority + 1, floor(dpq.priority/10)*10 + 9)")
      WHERE parser(dcsp_tmp_where_clause)
       AND dpq.process_status=dpq_executing
       AND (( NOT (dpq.audsid IN (
      (SELECT
       cnvtstring(gvs.audsid)
       FROM gv$session gvs)))) OR (dpq.audsid=currdbhandle))
      WITH nocounter, maxqual(dpq,value(dcsp_maxcommit))
     ;end update
     IF (check_error(dm_err->eproc))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN(0)
     ENDIF
     SET dcsp_continue_ind = curqual
     COMMIT
   ENDWHILE
   RETURN(1)
 END ;Subroutine
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
 IF (validate(drr_flex_sched->sched_set_up,8)=8
  AND validate(drr_flex_sched->sched_set_up,9)=9)
  FREE RECORD drr_flex_sched
  RECORD drr_flex_sched(
    1 sched_set_up = i2
    1 status = i2
    1 max_runners = i2
    1 runner_time_limit = i2
    1 readme_time_periods = i2
    1 schema_time_periods = i2
    1 readme_schedule[*]
      2 time_period = vc
      2 start_time = f8
      2 end_time = f8
      2 num_of_runners = i2
      2 start_time_hh = i2
      2 start_time_am_pm = c2
      2 end_time_hh = i2
      2 end_time_am_pm = c2
      2 start_time_hhmm = f8
      2 end_time_hhmm = f8
    1 schema_schedule[*]
      2 time_period = vc
      2 start_time = f8
      2 end_time = f8
      2 num_of_runners = i2
      2 start_time_hh = i2
      2 start_time_am_pm = c2
      2 end_time_hh = i2
      2 end_time_am_pm = c2
      2 start_time_hhmm = f8
      2 end_time_hhmm = f8
    1 pkg_using_schedule = i2
    1 pkg_number = vc
    1 pkg_install_mode = vc
    1 num_sched_runners = i2
    1 num_active_runners = i2
    1 num_stopping_runners = i2
    1 tot_num_runners = i2
    1 num_runners_to_stop = i2
    1 num_runners_to_start = i2
  )
  SET drr_flex_sched->sched_set_up = 0
  SET drr_flex_sched->status = 0
  SET drr_flex_sched->max_runners = 10
  SET drr_flex_sched->runner_time_limit = - (1)
  SET drr_flex_sched->readme_time_periods = 0
  SET drr_flex_sched->schema_time_periods = 0
  SET drr_flex_sched->pkg_using_schedule = 0
  SET drr_flex_sched->pkg_number = "DM2NOTSET"
  SET drr_flex_sched->pkg_install_mode = "DM2NOTSET"
  SET drr_flex_sched->num_sched_runners = 0
  SET drr_flex_sched->num_active_runners = 0
  SET drr_flex_sched->num_stopping_runners = 0
  SET drr_flex_sched->tot_num_runners = 0
  SET drr_flex_sched->num_runners_to_stop = 0
  SET drr_flex_sched->num_runners_to_start = 0
 ENDIF
 IF (validate(drr_runner_misc->mode,"X")="X"
  AND validate(drr_runner_misc->mode,"Y")="Y")
  FREE RECORD drr_runner_misc
  RECORD drr_runner_misc(
    1 mode = vc
    1 runner_identifier = vc
  )
  SET drr_runner_misc->mode = "DM2NOTSET"
  SET drr_runner_misc->runner_identifier = "DM2NOTSET"
 ENDIF
 DECLARE time_periods = i2
 DECLARE drr_submit_background_process(dsbp_user=vc,dsbp_pword=vc,dsbp_cnnect_str=vc,dsbp_queue_name=
  vc,dsbp_process_type=vc,
  dsbp_plan_id=f8,dsbp_install_mode=vc) = i2
 DECLARE drr_get_process_status(dgps_process_type=vc,dgps_plan_id=f8,dgps_status_out=i2(ref)) = i2
 DECLARE drr_cleanup_process_event() = i2
 DECLARE drr_cleanup_dm_info_runners() = i2
 DECLARE drr_cleanup_dm_info_sched_usage() = i2
 DECLARE drr_stop_installs_using_flex_sched() = i2
 DECLARE drr_stop_runners(dsr_mode=vc,dsr_number=i2) = i2
 DECLARE drr_start_runners(dstr_num_runners=i2,dstr_user=vc,dstr_pword=vc,dstr_cnnect_str=vc,
  dstr_queue_name=vc) = i2
 DECLARE drr_get_flexible_schedule() = i2
 DECLARE drr_use_flexible_schedule(dufs_prompt_ind=i2,dufs_pkg_number=vc,dufs_install_mode=vc,
  dufs_sel_ret=vc(ref)) = i2
 DECLARE drr_maintain_runners(dmr_user=vc,dmr_pword=vc,dmr_cnnect_str=vc,dmr_queue_name=vc,dm_process
  =vc) = i2
 DECLARE drr_check_pkg_appl_status(dcpas_appl_id=vc,dcpas_pkg_status=i2(ref)) = i2
 DECLARE drr_check_runner_status(dcrs_runner_type=vc,dcrs_appl_id=vc,dcrs_status=i2(ref)) = i2
 DECLARE drr_insert_runner_row(dirr_runner_type=vc,dirr_appl_id=vc,dirr_desc=vc,dirr_status=i2,
  dirr_plan_id=f8) = i2
 DECLARE drr_assign_file_to_installs(dafi_detail_type=vc,dafi_file_name=vc,dafi_event_id=f8) = i2
 DECLARE drr_remove_runner_row(drrr_runner_type=vc,drrr_appl_id=vc) = i2
 DECLARE drr_modify_install_status(dmis_plan_id=f8,dmis_appl_id=vc,dmis_status=i2,dmis_reason=vc,
  dmis_requester=vc) = i2
 DECLARE drr_rr_insert_runner_row(drirr_runner_identifier=vc,drirr_appl_id=vc) = i2
 DECLARE drr_rr_check_runner_status(drcrs_runner_identifier=vc,drcrs_appl_id=vc,drcrs_status=i2(ref))
  = i2
 DECLARE drr_rr_cleanup_dm_info_runners(null) = i2
 DECLARE drr_rr_remove_runner_row(drrrr_runner_identifier=vc,drrrr_appl_id=vc) = i2
 DECLARE drr_rr_maintain_runners(drmr_user=vc,drmr_pword=vc,drmr_cnnct_str=vc,drmr_runners=i2,
  drmr_runner_identifier=vc) = i2
 DECLARE drr_rr_start_runners(drstr_num_runners=i2,drstr_user=vc,drstr_pword=vc,drstr_cnnct_str=vc,
  drstr_identifier=vc) = i2
 DECLARE drr_cleanup_adm_dm_info_runners(dcadir_dblink=vc) = i2
 DECLARE drr_chk_active_runners(dcar_dblink=vc,dcar_count=i4(ref)) = i2
 SET modify curaliasreuse 1
 SUBROUTINE drr_submit_background_process(dsbp_user,dsbp_pword,dsbp_cnnct_str,dsbp_queue_name,
  dsbp_process_type,dsbp_plan_id,dsbp_install_mode)
   DECLARE dsbp_connect_string = vc WITH protect, noconstant(" ")
   DECLARE dsbp_file_name = vc WITH protect, noconstant(" ")
   DECLARE dsbp_logfile_name = vc WITH protect, noconstant(" ")
   DECLARE dsbp_exec_cmd = vc WITH protect, noconstant(" ")
   DECLARE dsbp_chmod_cmd = vc WITH protect, noconstant(" ")
   DECLARE dsbp_loop_cnt = i2 WITH protect, noconstant(0)
   DECLARE dsbp_debug_flag = vc WITH protect, noconstant("0")
   DECLARE dsbp_stat = i4 WITH protect, noconstant(0)
   DECLARE dsbp_file_prefix = vc WITH protect, noconstant(" ")
   DECLARE dsbp_plan_id_str = vc WITH protect, noconstant(trim(cnvtstring(abs(dsbp_plan_id))))
   DECLARE dsbp_pkg_install_mode = vc WITH protect, noconstant(" ")
   DECLARE dsbp_mtr_install_mode = vc WITH protect, noconstant(" ")
   IF (((dsbp_user=" ") OR (dsbp_pword=" ")) )
    SET dm_err->err_ind = 1
    SET dm_err->emsg =
    "Invalid database connection information for subroutine drr_submit_background_process"
    SET dm_err->eproc = "Validating connection information passed into subroutine."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (dsbp_cnnct_str > " "
    AND dsbp_cnnct_str != "NONE")
    SET dsbp_connect_string = build("'",dsbp_user,"/",dsbp_pword,"@",
     dsbp_cnnct_str,"'")
   ELSE
    SET dsbp_connect_string = build("'",dsbp_user,"/",dsbp_pword,"'")
   ENDIF
   SET dsbp_debug_flag = cnvtstring(dm_err->debug_flag)
   IF (dsbp_process_type=dpl_package_install)
    SET dsbp_file_prefix = "dm2obb"
   ELSEIF (dsbp_process_type=dpl_install_monitor)
    SET dsbp_file_prefix = "dm2obm"
   ELSEIF (dsbp_process_type=dpl_admin_upgrade)
    SET dsbp_file_prefix = "dm2ob_admupg"
   ENDIF
   IF (get_unique_file(concat(dsbp_file_prefix,dsbp_plan_id_str),".log")=0)
    RETURN(0)
   ENDIF
   SET dsbp_logfile_name = dm_err->unique_fname
   SET dsbp_file_name = replace(dsbp_logfile_name,".log",".ksh",0)
   IF (dsbp_process_type=dpl_package_install)
    SET dsbp_file_prefix = "dm2obb"
   ELSEIF (dsbp_process_type=dpl_install_monitor)
    SET dsbp_file_prefix = "dm2obm"
   ELSEIF (dsbp_process_type=dpl_admin_upgrade)
    SET dsbp_file_prefix = "dm2ob_admupg"
   ENDIF
   SET dsbp_pkg_install_mode = dsbp_install_mode
   SET dsbp_mtr_install_mode = dsbp_install_mode
   IF (((dsbp_install_mode="*ABG"
    AND dsbp_process_type=dpl_package_install) OR (dsbp_process_type=dpl_admin_upgrade)) )
    IF (dir_get_debug_trace_data(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dsbp_install_mode="*ABG")
    SET dsbp_mtr_install_mode = replace(dsbp_install_mode,"ABG","",2)
   ELSE
    SET dsbp_pkg_install_mode = concat(dsbp_install_mode,"BG")
   ENDIF
   SET dm_err->eproc = "Creating job to execute background process."
   SELECT INTO trim(dsbp_file_name)
    DETAIL
     col 0, "#!/usr/bin/ksh", row + 1,
     col 0, "# Executing Background Runner...", row + 1,
     col 0, "#", row + 1,
     col 0, ". $cer_mgr/",
     CALL print(trim(cnvtlower(logical("environment")))),
     "_environment.ksh", row + 1, col 0,
     "ccl <<!", row + 1, col 0,
     "SET TRACE NORANGECACHE 0 go", row + 1, col 0,
     "free define oraclesystem go", row + 1, col 0,
     "define oraclesystem ", dsbp_connect_string, " go"
     IF (((dsbp_install_mode="*ABG"
      AND dsbp_process_type=dpl_package_install) OR (dsbp_process_type=dpl_admin_upgrade)) )
      IF ((dir_ui_misc->debug_level > 0))
       row + 1, col 0, "set dm2_debug_flag = ",
       dir_ui_misc->debug_level, " go"
      ENDIF
      IF ((dir_ui_misc->trace_flag=1))
       row + 1, col 0, "set trace rdbdebug go",
       row + 1, col 0, "set trace rdbbind go",
       row + 1, col 0, "set trace rdbbind2 go"
      ENDIF
     ELSE
      row + 1, col 0, "set dm2_debug_flag = ",
      dsbp_debug_flag, " go"
     ENDIF
     row + 1
     IF (dsbp_process_type=dpl_admin_upgrade)
      col 0, "declare dm2_admin_upgrade_os_session_logfile = vc with public,noconstant('",
      dsbp_logfile_name,
      "') go"
     ELSE
      col 0, "declare dm2_package_os_session_logfile = vc with public,noconstant('",
      dsbp_logfile_name,
      "') go"
     ENDIF
     row + 1
     IF (dsbp_process_type=dpl_package_install)
      col 0, "ocd_incl_Schema2 ", dsbp_plan_id_str,
      ", '", dsbp_pkg_install_mode, "' go"
     ELSEIF (dsbp_process_type=dpl_install_monitor)
      col 0, "dm2_install_monitor ", dsbp_plan_id_str,
      ",'", dsbp_mtr_install_mode, "' go"
     ELSEIF (dsbp_process_type=dpl_admin_upgrade)
      col 0, "dm_ocd_setup_admin go"
     ENDIF
     row + 1, col 0, "exit",
     row + 1, col 0, "!",
     row + 1, col 0, "sleep 30"
    WITH nocounter, maxrow = 1, format = variable,
     formfeed = none
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dsbp_chmod_cmd = concat("chmod 777 $CCLUSERDIR/",dsbp_file_name)
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc = concat("drr_submit_background_process changing permissions for ",
     dsbp_file_name,".")
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (dm2_push_dcl(dsbp_chmod_cmd)=0)
    RETURN(0)
   ENDIF
   SET dsbp_exec_cmd = concat("nohup ","$CCLUSERDIR/",dsbp_file_name," > $CCLUSERDIR/",
    dsbp_logfile_name,
    " 2>&1 &")
   SET dm_err->eproc = concat("Executing ",trim(dsbp_file_name)," - results will be logged to ",trim(
     dsbp_logfile_name),".")
   CALL disp_msg(" ",dm_err->logfile,0)
   CALL dcl(dsbp_exec_cmd,size(dsbp_exec_cmd),dsbp_stat)
   IF (dsbp_stat=0)
    IF (parse_errfile(dsbp_logfile_name)=0)
     RETURN(0)
    ENDIF
    SET dm_err->disp_msg_emsg = dm_err->errtext
    SET dm_err->emsg = dm_err->disp_msg_emsg
    SET dm_err->eproc = concat("dm2_push_dcl executing: ",dsbp_exec_cmd)
    SET dm_err->err_ind = 1
    CALL disp_msg("dm_err->disp_msg_emsg",dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dsbp_exec_cmd = concat("ps -ef | grep ",dsbp_file_name," | grep -v grep")
   SET dm_err->disp_dcl_err_ind = 0
   IF (dm2_push_dcl(dsbp_exec_cmd)=0)
    IF ((dm_err->err_ind=1))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   IF (findstring(dsbp_file_name,dm_err->errtext)=0)
    SET dm_err->disp_msg_emsg = "Unable to locate process for this job."
    SET dm_err->emsg = dm_err->disp_msg_emsg
    SET dm_err->eproc = concat("Validating ",trim(dsbp_file_name)," was successfully executed.")
    SET dm_err->err_ind = 1
    CALL disp_msg("dm_err->disp_msg_emsg",dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_get_process_status(dgps_process_type,dgps_plan_id,dgps_status_out)
   DECLARE dgps_dm_info_exists = i2 WITH protect, noconstant(0)
   IF (dm2_table_and_ccldef_exists("DM_INFO",dgps_dm_info_exists)=0)
    RETURN(0)
   ENDIF
   IF (dgps_dm_info_exists != 1)
    SET dm_err->eproc = "DM_INFO does not exist. Setting status to execute by default."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET dgps_status_out = 1
    RETURN(1)
   ENDIF
   IF (drr_cleanup_dm_info_runners(null)=0)
    RETURN(0)
   ENDIF
   SET dgps_status_out = 0
   SET dm_err->eproc = "Query for process status"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain=cnvtupper(dgps_process_type)
     AND d.info_char=trim(cnvtstring(dgps_plan_id))
    DETAIL
     dgps_status_out = d.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_assign_file_to_installs(dafi_detail_type,dafi_file_name,dafi_event_id)
   DECLARE dfsi_cnt = i4 WITH protect, noconstant(0)
   DECLARE dsfi_ndx = i4 WITH protect, noconstant(0)
   DECLARE dfsi_optimizer_hint = vc WITH protect, noconstant("")
   SET dfsi_optimizer_hint = concat(" LEADING(DP DPE)","INDEX(DP XAK1DM_PROCESS)",
    "INDEX(DPE XIE1DM_PROCESS_EVENT)")
   FREE RECORD dsfi_id
   RECORD dsfi_id(
     1 id_cnt = i4
     1 qual[*]
       2 event_id = f8
       2 found = i2
   )
   IF (drr_cleanup_dm_info_runners(null)=0)
    RETURN(0)
   ENDIF
   IF (dafi_event_id=0)
    SET dm_err->eproc = "Gather any active Package Install event ids"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dm_process dp,
      dm_process_event dpe
     WHERE dp.dm_process_id=dpe.dm_process_id
      AND dp.process_name=dpl_package_install
      AND dp.action_type=dpl_execution
      AND (( NOT (dpe.event_status IN (dpl_failed, dpl_complete, dpl_failure, dpl_success))) OR (dpe
     .event_status = null))
     DETAIL
      dsfi_id->id_cnt = (dsfi_id->id_cnt+ 1), stat = alterlist(dsfi_id->qual,dsfi_id->id_cnt),
      dsfi_id->qual[dsfi_id->id_cnt].event_id = dpe.dm_process_event_id
     WITH nocounter, orahintcbo(value(dfsi_optimizer_hint))
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF ((dsfi_id->id_cnt=0))
     RETURN(1)
    ENDIF
   ELSE
    SET dsfi_id->id_cnt = (dsfi_id->id_cnt+ 1)
    SET stat = alterlist(dsfi_id->qual,dsfi_id->id_cnt)
    SET dsfi_id->qual[dsfi_id->id_cnt].event_id = dafi_event_id
   ENDIF
   SET dm_err->eproc = "Query for event details"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_process_event_dtl dped,
     (dummyt d  WITH seq = value(dsfi_id->id_cnt))
    PLAN (d
     WHERE d.seq > 0)
     JOIN (dped
     WHERE (dped.dm_process_event_id=dsfi_id->qual[d.seq].event_id)
      AND dped.detail_type=cnvtupper(dafi_detail_type))
    DETAIL
     dsfi_id->qual[d.seq].found = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dsfi_id)
   ENDIF
   IF (locateval(dsfi_ndx,1,dsfi_id->id_cnt,0,dsfi_id->qual[dsfi_ndx].found) > 0)
    FOR (dsfi_cnt = 1 TO dsfi_id->id_cnt)
      IF ((dsfi_id->qual[dsfi_cnt].found=0))
       CALL dm2_process_log_add_detail_text(cnvtupper(dafi_detail_type),dafi_file_name)
       SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_number = 0
       SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_date = cnvtdatetime
       (curdate,curtime3)
       IF (dm2_process_log_dtl_row(dsfi_id->qual[dsfi_cnt].event_id,0)=0)
        RETURN(0)
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_cleanup_dm_info_runners(null)
   DECLARE dcdir_dm_info_fnd_ind = i2 WITH protect, noconstant(0)
   DECLARE dcdir_applx = i4 WITH protect, noconstant(0)
   FREE RECORD dcdir_appl_rs
   RECORD dcdir_appl_rs(
     1 cnt = i4
     1 qual[*]
       2 appl_id = vc
   )
   IF (dm2_table_and_ccldef_exists("DM_INFO",dcdir_dm_info_fnd_ind)=0)
    RETURN(0)
   ENDIF
   IF (dcdir_dm_info_fnd_ind=0)
    IF ((dm_err->debug_flag > 0))
     CALL echo(
      "DM_INFO table not found in dm2_user_tables, bypassing dm2_cleanup_dm_info_runners logic...")
    ENDIF
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Getting a distinct list of appl ids attached to a runner..."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT DISTINCT INTO "nl:"
    di.info_name
    FROM dm_info di
    WHERE di.info_domain IN ("DM2_BACKGROUND_RUNNER", "DM2_INSTALL_RUNNER", "DM2_SCHEMA_RUNNER",
    "DM2_README_RUNNER", "DM2_SET_READY_TO_RUN",
    "DM2_INSTALL_PKG", "DM2_INSTALL_MONITOR", "DM2_ADS_DRIVER_GEN:AUDSID",
    "DM2_ADS_CHILDEST_GEN:AUDSID")
    HEAD REPORT
     dcdir_applx = 0
    DETAIL
     dcdir_applx = (dcdir_applx+ 1)
     IF (mod(dcdir_applx,10)=1)
      stat = alterlist(dcdir_appl_rs->qual,(dcdir_applx+ 9))
     ENDIF
     dcdir_appl_rs->qual[dcdir_applx].appl_id = trim(di.info_name,3)
    FOOT REPORT
     dcdir_appl_rs->cnt = dcdir_applx, stat = alterlist(dcdir_appl_rs->qual,dcdir_applx)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dcdir_appl_rs->cnt > 0))
    SET dcdir_applx = 1
    WHILE ((dcdir_applx <= dcdir_appl_rs->cnt))
     CASE (dm2_get_appl_status(value(dcdir_appl_rs->qual[dcdir_applx].appl_id)))
      OF "I":
       IF ((dm_err->debug_flag > 1))
        CALL echo(concat("Application Id ",dcdir_appl_rs->qual[dcdir_applx].appl_id," is not active."
          ))
       ENDIF
       DELETE  FROM dm_info di
        WHERE di.info_domain IN ("DM2_BACKGROUND_RUNNER", "DM2_INSTALL_RUNNER", "DM2_SCHEMA_RUNNER",
        "DM2_README_RUNNER", "DM2_SET_READY_TO_RUN",
        "DM2_INSTALL_PKG", "DM2_INSTALL_MONITOR", "DM2_ADS_DRIVER_GEN:AUDSID",
        "DM2_ADS_CHILDEST_GEN:AUDSID")
         AND (di.info_name=dcdir_appl_rs->qual[dcdir_applx].appl_id)
        WITH nocounter
       ;end delete
       IF (check_error("Removing dm_info runner row(s) - appl id no longer active.")=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ELSE
        COMMIT
       ENDIF
      OF "A":
       IF ((dm_err->debug_flag > 1))
        CALL echo(concat("Application Id ",dcdir_appl_rs->qual[dcdir_applx].appl_id," is active."))
       ENDIF
      OF "E":
       IF ((dm_err->debug_flag > 1))
        CALL echo("Error Detected in dm2_get_appl_status")
       ENDIF
       RETURN(0)
     ENDCASE
     SET dcdir_applx = (dcdir_applx+ 1)
    ENDWHILE
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo("********** No Application Ids Detected **********")
    ENDIF
   ENDIF
   IF (dpl_ui_chk(dm2_process_rs->process_name)=0)
    RETURN(0)
   ENDIF
   IF ((((dm2_process_event_rs->ui_allowed_ind=1)) OR ((dm2_process_rs->process_name=dpl_sample))) )
    IF (drr_cleanup_process_event(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_cleanup_process_event(null)
   DECLARE dcpe_cnt = i4 WITH protect, noconstant(0)
   DECLARE dcpe_ndx = i4 WITH protect, noconstant(0)
   DECLARE dcpe_optimize_hint = vc WITH protect, noconstant("")
   DECLARE dcpe_optimize_hint1 = vc WITH protect, noconstant("")
   SET dcpe_optimize_hint = concat(" LEADING(DP DPE DPED)","INDEX(DP XAK1DM_PROCESS)",
    "INDEX(DPE XIE1DM_PROCESS_EVENT)","INDEX(DPED XIE1DM_PROCESS_EVENT_DTL) ")
   SET dcpe_optimize_hint1 = concat(" LEADING(DP DPE)","INDEX(DP XAK1DM_PROCESS)",
    "INDEX(DPE XIE1DM_PROCESS_EVENT)")
   IF (dpl_ui_chk(dm2_process_rs->process_name)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_process_event_rs->ui_allowed_ind=0)
    AND (dm2_process_rs->process_name != dpl_sample))
    RETURN(1)
   ENDIF
   FREE RECORD dcpe_appl
   RECORD dcpe_appl(
     1 cnt = i4
     1 qual[*]
       2 appl_id = vc
       2 plan_id = f8
       2 event_id = f8
       2 process_name = vc
       2 active_ind = i2
   )
   SET dm_err->eproc = "Getting distinct list of active processes in DM_PROCESS_EVENT..."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_process dp,
     dm_process_event dpe,
     dm_process_event_dtl dped
    WHERE dp.dm_process_id=dpe.dm_process_id
     AND dpe.dm_process_event_id=dped.dm_process_event_id
     AND dp.process_name IN (dpl_package_install, dpl_background_runner, dpl_install_runner,
    dpl_install_monitor, dpl_sample)
     AND (( NOT (dpe.event_status IN (dpl_failed, dpl_complete, dpl_failure, dpl_success))) OR (dpe
    .event_status = null))
     AND dped.detail_type=dpl_audsid
    HEAD REPORT
     dcpe_appl->cnt = 0, stat = alterlist(dcpe_appl->qual,dcpe_appl->cnt)
    DETAIL
     dcpe_appl->cnt = (dcpe_appl->cnt+ 1), stat = alterlist(dcpe_appl->qual,dcpe_appl->cnt),
     dcpe_appl->qual[dcpe_appl->cnt].appl_id = dped.detail_text,
     dcpe_appl->qual[dcpe_appl->cnt].plan_id = dpe.install_plan_id, dcpe_appl->qual[dcpe_appl->cnt].
     event_id = dpe.dm_process_event_id, dcpe_appl->qual[dcpe_appl->cnt].process_name = dp
     .process_name,
     dcpe_appl->qual[dcpe_appl->cnt].active_ind = 1
    WITH nocounter, nullreport, orahintcbo(value(dcpe_optimize_hint))
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dcpe_appl)
   ENDIF
   IF ((dcpe_appl->cnt > 0))
    FOR (dcpe_cnt = 1 TO dcpe_appl->cnt)
      IF ((dcpe_appl->qual[dcpe_cnt].active_ind=1))
       CASE (dm2_get_appl_status(value(dcpe_appl->qual[dcpe_cnt].appl_id)))
        OF "I":
         IF ((dm_err->debug_flag > 1))
          CALL echo(concat("Application Id for event ",dcpe_appl->qual[dcpe_cnt].appl_id,
            " is not active."))
         ENDIF
         SET dm_err->eproc = "Mark appl_id for event as inactive"
         SELECT INTO "nl:"
          FROM (dummyt d  WITH seq = value(dcpe_appl->cnt))
          PLAN (d
           WHERE d.seq > 0
            AND (dcpe_appl->qual[d.seq].appl_id=dcpe_appl->qual[dcpe_cnt].appl_id))
          DETAIL
           dcpe_appl->qual[d.seq].active_ind = 0
          WITH nocounter
         ;end select
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          RETURN(0)
         ENDIF
        OF "A":
         IF ((dm_err->debug_flag > 1))
          CALL echo(concat("Application Id for event ",dcpe_appl->qual[dcpe_cnt].appl_id,
            " is active."))
         ENDIF
        OF "E":
         IF ((dm_err->debug_flag > 1))
          CALL echo("Error Detected in drr_cleanup_process_event")
         ENDIF
         RETURN(0)
       ENDCASE
      ENDIF
    ENDFOR
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo("********** No active processes found in DM_PROCESS_EVENT **********")
    ENDIF
    RETURN(1)
   ENDIF
   IF (locateval(dcpe_ndx,1,dcpe_appl->cnt,0,dcpe_appl->qual[dcpe_ndx].active_ind) > 0)
    SET dm_err->eproc = "Marking DM_PROCESS_EVENT rows as inactive"
    UPDATE  FROM dm_process_event dpe,
      (dummyt d  WITH seq = value(dcpe_appl->cnt))
     SET dpe.event_status = dpl_failed, dpe.message_txt = concat(dpe.message_txt,
       ": ACTIVE STATUS FOUND WITHOUT ACTIVE EVENT PROCESS")
     PLAN (d
      WHERE (dcpe_appl->qual[d.seq].active_ind=0))
      JOIN (dpe
      WHERE (dpe.dm_process_event_id=dcpe_appl->qual[d.seq].event_id)
       AND (( NOT (dpe.event_status IN (dpl_complete, dpl_failed))) OR (dpe.event_status = null))
       AND dpe.begin_dt_tm IS NOT null
       AND dpe.begin_dt_tm > cnvtdatetime("01-JAN-1900"))
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
    IF (locateval(dcpe_ndx,1,dcpe_appl->cnt,dpl_package_install,dcpe_appl->qual[dcpe_ndx].
     process_name) > 0)
     FOR (dcpe_cnt = 1 TO dcpe_appl->cnt)
       IF ((dcpe_appl->qual[dcpe_ndx].process_name=dpl_package_install)
        AND (dcpe_appl->qual[dcpe_ndx].active_ind=0))
        SET dm_err->eproc =
        "Mark any package installs as inactive for package installs without active events "
        UPDATE  FROM dm_process_event dpe1
         SET dpe1.event_status = dpl_failed, dpe1.message_txt = concat(dpe1.message_txt,
           ": ACTIVE STATUS FOUND WITHOUT ACTIVE EVENT PROCESS")
         WHERE dpe1.dm_process_event_id IN (
         (SELECT
          dpe.dm_process_event_id
          FROM dm_process dp,
           dm_process_event dpe
          WHERE dp.process_name=dpl_package_install
           AND action_type=dpl_itinerary_event
           AND (dpe.install_plan_id=dcpe_appl->qual[dcpe_ndx].plan_id)
           AND (( NOT (dpe.event_status IN (dpl_complete, dpl_failed, dpl_success, dpl_failure))) OR
          (dpe.event_status = null))
           AND dpe.begin_dt_tm IS NOT null
           AND dpe.begin_dt_tm > cnvtdatetime("01-JAN-1900")
          WITH orahintcbo(value(dcpe_optimize_hint1))))
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
     ENDFOR
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_cleanup_dm_info_sched_usage(null)
   DECLARE dcdisu_applx = i4 WITH protect, noconstant(0)
   FREE RECORD dcdisu_appl_rs
   RECORD dcdisu_appl_rs(
     1 cnt = i4
     1 qual[*]
       2 appl_id = vc
   )
   SET dm_err->eproc =
   "Getting a distinct list of appl ids attached to a package install using installation schedule..."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT DISTINCT INTO "nl:"
    di.info_char
    FROM dm_info di
    WHERE di.info_domain="DM2_FLEX_SCHED_USAGE"
    HEAD REPORT
     dcdisu_applx = 0
    DETAIL
     dcdisu_applx = (dcdisu_applx+ 1)
     IF (mod(dcdisu_applx,10)=1)
      stat = alterlist(dcdisu_appl_rs->qual,(dcdisu_applx+ 9))
     ENDIF
     dcdisu_appl_rs->qual[dcdisu_applx].appl_id = trim(di.info_char,3)
    FOOT REPORT
     dcdisu_appl_rs->cnt = dcdisu_applx, stat = alterlist(dcdisu_appl_rs->qual,dcdisu_applx)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dcdisu_appl_rs->cnt > 0))
    SET dcdisu_applx = 1
    WHILE ((dcdisu_applx <= dcdisu_appl_rs->cnt))
     CASE (dm2_get_appl_status(value(dcdisu_appl_rs->qual[dcdisu_applx].appl_id)))
      OF "I":
       IF ((dm_err->debug_flag > 1))
        CALL echo(build("Application Id ",dcdisu_appl_rs->qual[dcdisu_applx].appl_id,
          " is not active."))
       ENDIF
       DELETE  FROM dm_info di
        WHERE di.info_domain="DM2_FLEX_SCHED_USAGE"
         AND (di.info_char=dcdisu_appl_rs->qual[dcdisu_applx].appl_id)
        WITH nocounter
       ;end delete
       IF (check_error("Removing dm_info pkg row(s) - appl id no longer active.")=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ELSE
        COMMIT
       ENDIF
      OF "A":
       IF ((dm_err->debug_flag > 1))
        CALL echo(concat("Application Id ",dcdisu_appl_rs->qual[dcdisu_applx].appl_id," is active."))
       ENDIF
      OF "E":
       IF ((dm_err->debug_flag > 1))
        CALL echo("Error Detected in dm2_get_appl_status")
       ENDIF
       RETURN(0)
     ENDCASE
     SET dcdisu_applx = (dcdisu_applx+ 1)
    ENDWHILE
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo("********** No Application Ids Detected **********")
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_stop_installs_using_flex_sched(null)
   DECLARE dsiufs_cnt = i4 WITH protect, noconstant(0)
   FREE RECORD dsiufs_work
   RECORD dsiufs_work(
     1 cnt = i4
     1 qual[*]
       2 plan_id = f8
       2 appl_id = vc
   )
   SET dm_err->eproc = "Stopping (inactivating) all package installs using installation schedule..."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_FLEX_SCHED_USAGE"
     AND di.info_number > 0
    DETAIL
     dsiufs_work->cnt = (dsiufs_work->cnt+ 1), stat = alterlist(dsiufs_work->qual,dsiufs_work->cnt),
     dsiufs_work->qual[dsiufs_work->cnt].plan_id = abs(cnvtreal(di.info_name)),
     dsiufs_work->qual[dsiufs_work->cnt].appl_id = di.info_char
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    FOR (dsiufs_cnt = 1 TO dsiufs_work->cnt)
     IF (drr_modify_install_status(dsiufs_work->qual[dsiufs_cnt].plan_id,dsiufs_work->qual[dsiufs_cnt
      ].appl_id,0,concat("User ",curuser," requested stop of all Installs"),"STOP ALL INSTALLS")=0)
      RETURN(0)
     ENDIF
     IF ((dnotify->status=1)
      AND (dm2_process_event_rs->ui_allowed_ind=1))
      SET dnotify->process = "INSTALLPLAN"
      SET dnotify->plan_id = abs(dsiufs_work->qual[dsiufs_cnt].plan_id)
      SET dnotify->install_status = "STOPPED"
      SET dnotify->event = "Stopping All Active Install Plans"
      SET dnotify->msgtype = dpl_warning
      CALL dn_add_body_text(concat("User ",curuser,
        " has requested all Install Plans using the Installation ","Scheduler to Stop at ",format(
         cnvtdatetime(curdate,curtime3),";;q")),1)
      CALL dn_add_body_text(" ",0)
      CALL dn_add_body_text(concat("Install Plan ",trim(cnvtstring(dsiufs_work->qual[dsiufs_cnt].
          plan_id))," has been stopped"),0)
      SET dm2_process_event_rs->begin_dt_tm = cnvtdatetime(curdate,curtime3)
      SET dm2_process_event_rs->end_dt_tm = cnvtdatetime(curdate,curtime3)
      SET dm2_process_event_rs->install_plan_id = abs(dsiufs_work->qual[dsiufs_cnt].plan_id)
      SET dm2_process_event_rs->status = dpl_complete
      CALL dm2_process_log_add_detail_text(dpl_audit_name,"EMAIL:STOP_FLEXSCHED_INSTALL")
      CALL dm2_process_log_add_detail_text(dpl_audit_type,dpl_progress)
      IF (dn_notify(null)=0)
       RETURN(0)
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_modify_install_status(dmis_plan_id,dmis_appl_id,dmis_status,dmis_reason,
  dmis_requester)
   DECLARE dmis_cur_status = i2 WITH protect, noconstant(- (1))
   DECLARE dmis_cur_applid = vc WITH protect, noconstant("")
   DECLARE dmis_msg = vc WITH protect, noconstant("")
   DECLARE dmis_event_id = f8 WITH protect, noconstant(0.0)
   DECLARE dmis_status_changed_ind = i2 WITH protect, noconstant(0)
   IF (drr_get_process_status("DM2_INSTALL_PKG",dmis_plan_id,dmis_cur_status)=0)
    RETURN(0)
   ENDIF
   IF (dmis_cur_status=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Install in a Stop status. Exiting.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Obtain current appl_id for plan_id ",build(dmis_plan_id))
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_INSTALL_PKG"
     AND cnvtreal(di.info_char)=dmis_plan_id
    DETAIL
     dmis_cur_applid = di.info_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dmis_cur_status != dmis_status)
    SET dm_err->eproc = concat("Update DM2_INSTALL_PKG status for plan_id ",build(dmis_plan_id),
     " to ",build(dmis_status))
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
    ENDIF
    UPDATE  FROM dm_info di
     SET di.info_number = dmis_status, di.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)
       )
     WHERE di.info_domain="DM2_INSTALL_PKG"
      AND di.info_name=dmis_cur_applid
      AND cnvtreal(di.info_char)=dmis_plan_id
      AND di.info_number != dmis_status
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual > 0)
     SET dmis_status_changed_ind = 1
    ELSE
     SET dm_err->eproc = concat("Install status for ",build(dmis_plan_id)," already set to ",build(
       dmis_status))
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
     ENDIF
     RETURN(1)
    ENDIF
    IF (dmis_status_changed_ind=1)
     SET dm_err->eproc = concat("Update install status for plan_id ",build(dmis_plan_id)," to ",build
      (dmis_status))
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
     ENDIF
     UPDATE  FROM dm_info di
      SET di.info_number = dmis_status, di.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3
         ))
      WHERE di.info_domain="DM2_FLEX_SCHED_USAGE"
       AND di.info_name=dmis_cur_applid
       AND di.info_char=trim(cnvtstring(dmis_plan_id))
       AND di.info_number != dmis_status
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (dpl_ui_chk(dpl_package_install)=0)
      RETURN(0)
     ENDIF
     IF ((dm2_process_event_rs->ui_allowed_ind=1))
      SET dm_err->eproc = "Query for the process event id"
      IF ((dm_err->debug_flag > 0))
       CALL disp_msg("",dm_err->logfile,0)
      ENDIF
      SELECT INTO "nl:"
       FROM dm_process dp,
        dm_process_event dpe,
        dm_process_event_dtl dped
       WHERE dp.dm_process_id=dpe.dm_process_id
        AND dpe.dm_process_event_id=dped.dm_process_event_id
        AND dp.process_name=dpl_package_install
        AND dp.action_type=dpl_execution
        AND dped.detail_type="AUDSID"
        AND dped.detail_text=dmis_appl_id
        AND dpe.install_plan_id=dmis_plan_id
       DETAIL
        dmis_event_id = dpe.dm_process_event_id
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      CASE (dmis_status)
       OF 2:
        SET dmis_msg = "PAUSED"
       OF 0:
        SET dmis_msg = "STOPPED"
       OF 1:
        SET dmis_msg = "EXECUTING"
      ENDCASE
      SET dm_err->eproc = "Update the process event for the event status change"
      IF ((dm_err->debug_flag > 0))
       CALL disp_msg("",dm_err->logfile,0)
      ENDIF
      UPDATE  FROM dm_process_event dpe1
       SET dpe1.event_status = dmis_msg
       WHERE dpe1.dm_process_event_id=dmis_event_id
       WITH nocounter
      ;end update
      IF (check_error(dm_err->eproc)=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      IF (dmis_status=2)
       SET dm_err->eproc = "Update status change reason"
       IF ((dm_err->debug_flag > 0))
        CALL disp_msg("",dm_err->logfile,0)
       ENDIF
       UPDATE  FROM dm_process_event_dtl dtl
        SET dtl.detail_text = dmis_reason
        WHERE dtl.dm_process_event_id=dmis_event_id
         AND dtl.detail_type="LAST_STATUS_MESSAGE"
        WITH nocounter
       ;end update
       IF (check_error(dm_err->eproc)=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       IF (curqual=0)
        CALL dm2_process_log_add_detail_text("LAST_STATUS_MESSAGE",dmis_reason)
        SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_date =
        cnvtdatetime(curdate,curtime3)
        IF (dm2_process_log_dtl_row(dmis_event_id,0)=0)
         ROLLBACK
         RETURN(0)
        ENDIF
       ENDIF
      ENDIF
      COMMIT
      SET dm_err->eproc = "Log installation status change event"
      IF ((dm_err->debug_flag > 0))
       CALL disp_msg("",dm_err->logfile,0)
      ENDIF
      SET dm2_process_event_rs->begin_dt_tm = cnvtdatetime(curdate,curtime3)
      SET dm2_process_event_rs->end_dt_tm = cnvtdatetime(curdate,curtime3)
      SET dm2_process_event_rs->install_plan_id = dmis_plan_id
      SET dm2_process_event_rs->status = dpl_complete
      CALL dm2_process_log_add_detail_text(dpl_audit_name,"MODIFY_INSTALL_STATUS")
      CALL dm2_process_log_add_detail_text(dpl_audit_type,dpl_progress)
      CALL dm2_process_log_add_detail_text("NEW_STATUS",cnvtstring(dmis_status))
      CALL dm2_process_log_add_detail_text("OLD_STATUS",cnvtstring(dmis_cur_status))
      CALL dm2_process_log_add_detail_text("MENU_NAME",dmis_requester)
      CALL dm2_process_log_add_detail_text("STATUS_CHANGE_REASON",dmis_reason)
      IF (dm2_process_log_row(dpl_package_install,dpl_auditlog,dpl_no_prev_id,0)=0)
       RETURN(0)
      ENDIF
      CALL dpl_upd_dped_last_status(dmis_event_id,dmis_reason,0.0,cnvtdatetime(curdate,curtime3))
     ENDIF
    ENDIF
    IF (dmis_status IN (0, 2))
     IF (drr_stop_runners("ALL",0)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_stop_runners(dsr_mode,dsr_number)
   IF ( NOT (cnvtupper(dsr_mode) IN ("ALL", "LONG_RUNNING", "NUM_RUNNERS")))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid input mode for subroutine drr_stop_runners"
    SET dm_err->eproc = "Validating input mode."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (dsr_mode IN ("LONG_RUNNING", "NUM_RUNNERS")
    AND dsr_number=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid input number for subroutine drr_stop_runners"
    SET dm_err->eproc = "Validating input number."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   DECLARE dsr_applx = i4 WITH protect, noconstant(0)
   DECLARE dsr_interval = vc WITH protect, noconstant(" ")
   FREE RECORD dsr_appl_rs
   RECORD dsr_appl_rs(
     1 cnt = i4
     1 qual[*]
       2 appl_id = vc
   )
   IF (cnvtupper(dsr_mode)="ALL")
    SET dm_err->eproc = "Stopping (inactivating) all runners..."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    UPDATE  FROM dm_info di
     SET di.info_number = 0, di.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3))
     WHERE di.info_domain IN ("DM2_BACKGROUND_RUNNER", "DM2_INSTALL_RUNNER", "DM2_SCHEMA_RUNNER",
     "DM2_README_RUNNER")
      AND di.info_number=1
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ELSEIF (cnvtupper(dsr_mode)="LONG_RUNNING")
    SET dsr_interval = build(dsr_number,"H")
    SET dm_err->eproc = concat(
     "Getting a distinct list of appl ids attached to runners that have been running longer than ",
     trim(cnvtstring(dsr_number),3)," hour(s)...")
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SELECT DISTINCT INTO "nl:"
     di.info_name
     FROM dm_info di
     WHERE di.info_domain IN ("DM2_BACKGROUND_RUNNER", "DM2_INSTALL_RUNNER", "DM2_SCHEMA_RUNNER",
     "DM2_README_RUNNER")
      AND di.info_number=1
      AND di.info_date <= cnvtdatetimeutc(cnvtdatetime(cnvtlookbehind(dsr_interval)))
     HEAD REPORT
      dsr_applx = 0
     DETAIL
      dsr_applx = (dsr_applx+ 1)
      IF (mod(dsr_applx,10)=1)
       stat = alterlist(dsr_appl_rs->qual,(dsr_applx+ 9))
      ENDIF
      dsr_appl_rs->qual[dsr_applx].appl_id = trim(di.info_name,3)
     FOOT REPORT
      dsr_appl_rs->cnt = dsr_applx, stat = alterlist(dsr_appl_rs->qual,dsr_appl_rs->cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dsr_appl_rs->cnt > 0))
     SET dm_err->eproc = concat(
      "Stopping (inactivating) all runners that have been running longer than ",trim(cnvtstring(
        dsr_number),3)," hour(s)...")
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     UPDATE  FROM dm_info di,
       (dummyt d  WITH seq = value(dsr_appl_rs->cnt))
      SET di.info_number = 0, di.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3))
      PLAN (d)
       JOIN (di
       WHERE di.info_domain IN ("DM2_BACKGROUND_RUNNER", "DM2_INSTALL_RUNNER", "DM2_SCHEMA_RUNNER",
       "DM2_README_RUNNER")
        AND (di.info_name=dsr_appl_rs->qual[d.seq].appl_id))
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
   ELSE
    SET dm_err->eproc = concat("Getting the ",trim(cnvtstring(dsr_number))," oldest runner(s).")
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    SELECT DISTINCT INTO "nl:"
     di.info_name
     FROM dm_info di
     WHERE di.info_domain IN ("DM2_BACKGROUND_RUNNER", "DM2_INSTALL_RUNNER", "DM2_SCHEMA_RUNNER",
     "DM2_README_RUNNER")
      AND di.info_number=1
     ORDER BY di.info_date
     HEAD REPORT
      dsr_applx = 0
     DETAIL
      IF (dsr_applx < dsr_number)
       dsr_applx = (dsr_applx+ 1)
       IF (mod(dsr_applx,10)=1)
        stat = alterlist(dsr_appl_rs->qual,(dsr_applx+ 9))
       ENDIF
       dsr_appl_rs->qual[dsr_applx].appl_id = trim(di.info_name,3)
      ENDIF
     FOOT REPORT
      dsr_appl_rs->cnt = dsr_applx, stat = alterlist(dsr_appl_rs->qual,dsr_appl_rs->cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 2))
     CALL echorecord(dsr_appl_rs)
    ENDIF
    IF ((dsr_appl_rs->cnt > 0))
     SET dm_err->eproc = concat("Stopping the ",trim(cnvtstring(dsr_number))," oldest runner(s).")
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     UPDATE  FROM dm_info di,
       (dummyt d  WITH seq = value(dsr_appl_rs->cnt))
      SET di.info_number = 0, di.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3))
      PLAN (d)
       JOIN (di
       WHERE di.info_domain IN ("DM2_BACKGROUND_RUNNER", "DM2_INSTALL_RUNNER", "DM2_SCHEMA_RUNNER",
       "DM2_README_RUNNER")
        AND (di.info_name=dsr_appl_rs->qual[d.seq].appl_id))
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
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_start_runners(dstr_num_runners,dstr_user,dstr_pword,dstr_cnnct_str,dstr_queue_name)
   DECLARE dstr_connect_string = vc WITH protect, noconstant(" ")
   DECLARE dstr_file_name = vc WITH protect, noconstant(" ")
   DECLARE dstr_logfile_name = vc WITH protect, noconstant(" ")
   DECLARE dstr_exec_cmd = vc WITH protect, noconstant(" ")
   DECLARE dstr_chmod_cmd = vc WITH protect, noconstant(" ")
   DECLARE dstr_loop_cnt = i2 WITH protect, noconstant(0)
   DECLARE dstr_debug_flag = vc WITH protect, noconstant("0")
   DECLARE dstr_stat = i4 WITH protect, noconstant(0)
   IF (dstr_num_runners <= 0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid input number for subroutine drr_start_runners"
    SET dm_err->eproc = "Validating input number - number of runners to start."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (((dstr_user=" ") OR (dstr_pword=" ")) )
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid database connection information for subroutine drr_start_runners"
    SET dm_err->eproc = "Validating connection information passed into subroutine."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (dstr_cnnct_str > " "
    AND dstr_cnnct_str != "NONE")
    SET dstr_connect_string = build("'",dstr_user,"/",dstr_pword,"@",
     dstr_cnnct_str,"'")
   ELSE
    SET dstr_connect_string = build("'",dstr_user,"/",dstr_pword,"'")
   ENDIF
   IF ((dir_ui_misc->auto_install_ind=1))
    IF (dir_get_debug_trace_data(null)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET dstr_debug_flag = cnvtstring(dm_err->debug_flag)
   FOR (dstr_loop_cnt = 1 TO dstr_num_runners)
     IF (get_unique_file("dm2_bckgrnd_runner_",".log")=0)
      RETURN(0)
     ENDIF
     SET dstr_logfile_name = dm_err->unique_fname
     SET dstr_file_name = replace(dstr_logfile_name,".log",".ksh",0)
     SET dm_err->eproc = "Creating job to execute background runner."
     SELECT INTO trim(dstr_file_name)
      DETAIL
       col 0, "#!/usr/bin/ksh", row + 1,
       col 0, "# Executing Background Runner...", row + 1,
       col 0, "#", row + 1,
       col 0, ". $cer_mgr/",
       CALL print(trim(cnvtlower(logical("environment")))),
       "_environment.ksh", row + 1, col 0,
       "ccl <<!", row + 1, col 0,
       "SET TRACE NORANGECACHE 0 go", row + 1, col 0,
       "free define oraclesystem go", row + 1, col 0,
       "define oraclesystem ", dstr_connect_string, " go"
       IF ((dir_ui_misc->auto_install_ind=1))
        IF ((dir_ui_misc->debug_level > 0))
         row + 1, col 0, "set dm2_debug_flag = ",
         dir_ui_misc->debug_level, " go"
        ENDIF
        IF ((dir_ui_misc->trace_flag=1))
         row + 1, col 0, "set trace rdbdebug go",
         row + 1, col 0, "set trace rdbbind go",
         row + 1, col 0, "set trace rdbbind2 go"
        ENDIF
       ELSE
        row + 1, col 0, "set dm2_debug_flag = ",
        dstr_debug_flag, " go"
       ENDIF
       row + 1, col 0, "dm2_background_runner '",
       dstr_user, "', '", dstr_pword,
       "', '", dstr_cnnct_str, "', 'PACKAGE' go",
       row + 1, col 0, "exit",
       row + 1, col 0, "!",
       row + 1, col 0, "sleep 30"
      WITH nocounter, maxrow = 1, format = variable,
       formfeed = none
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET dstr_chmod_cmd = concat("chmod 777 $CCLUSERDIR/",dstr_file_name)
     IF ((dm_err->debug_flag > 0))
      SET dm_err->eproc = concat("drr_start_runners changing permissions for ",dstr_file_name,".")
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     IF (dm2_push_dcl(dstr_chmod_cmd)=0)
      RETURN(0)
     ENDIF
     SET dstr_exec_cmd = concat("nohup ","$CCLUSERDIR/",dstr_file_name," > $CCLUSERDIR/",
      dstr_logfile_name,
      " 2>&1 &")
     SET dm_err->eproc = concat("Executing ",trim(dstr_file_name)," - results will be logged to ",
      trim(dstr_logfile_name),".")
     CALL disp_msg(" ",dm_err->logfile,0)
     CALL dcl(dstr_exec_cmd,size(dstr_exec_cmd),dstr_stat)
     IF (dstr_stat=0)
      IF (parse_errfile(dstr_logfile_name)=0)
       RETURN(0)
      ENDIF
      SET dm_err->disp_msg_emsg = dm_err->errtext
      SET dm_err->emsg = dm_err->disp_msg_emsg
      SET dm_err->eproc = concat("dm2_push_dcl executing: ",dstr_exec_cmd)
      SET dm_err->err_ind = 1
      CALL disp_msg("dm_err->disp_msg_emsg",dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET dstr_exec_cmd = concat("ps -ef | grep ",dstr_file_name," | grep -v grep")
     SET dm_err->disp_dcl_err_ind = 0
     IF (dm2_push_dcl(dstr_exec_cmd)=0)
      IF ((dm_err->err_ind=1))
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
     IF (parse_errfile(dm_err->errfile)=0)
      RETURN(0)
     ENDIF
     IF (findstring(dstr_file_name,dm_err->errtext)=0)
      SET dm_err->disp_msg_emsg = "Unable to locate process for this job."
      SET dm_err->emsg = dm_err->disp_msg_emsg
      SET dm_err->eproc = concat("Validating ",trim(dstr_file_name)," was successfully executed.")
      SET dm_err->err_ind = 1
      CALL disp_msg("dm_err->disp_msg_emsg",dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF ((dm_err->debug_flag < 3))
      IF (remove(dstr_file_name)=0)
       SET dm_err->err_ind = 1
       SET dm_err->emsg = concat("Could not remove ",dstr_file_name," from ccluserdir.")
       SET dm_err->eproc = "Removing background ksh/com file from ccluserdir."
       CALL disp_msg((dm_err - emsg),dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_get_flexible_schedule(null)
   DECLARE dgfs_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgfs_idx = i4 WITH protect, noconstant(0)
   DECLARE dgfs_time_period = vc WITH protect, noconstant(" ")
   DECLARE dgfs_process = vc WITH protect, noconstant(" ")
   SET stat = alterlist(drr_flex_sched->readme_schedule,0)
   SET stat = alterlist(drr_flex_sched->schema_schedule,0)
   SET drr_flex_sched->readme_time_periods = 0
   SET drr_flex_sched->schema_time_periods = 0
   SET dm_err->eproc = "Getting installation schedule data..."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   INSERT  FROM dm_info di
    (di.info_domain, di.info_name, di.info_date,
    di.info_char, di.info_number)(SELECT
     "DM2_FLEXIBLE_SCHEDULE_README", do.info_name, do.info_date,
     do.info_char, do.info_number
     FROM dm_info do
     WHERE do.info_domain="DM2_FLEXIBLE_SCHEDULE"
      AND  NOT (do.info_name IN ("STATUS", "RUNNER TIME LIMIT")))
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   INSERT  FROM dm_info di
    (di.info_domain, di.info_name, di.info_date,
    di.info_char, di.info_number)(SELECT
     "DM2_FLEXIBLE_SCHEDULE_SCHEMA", do.info_name, do.info_date,
     do.info_char, do.info_number
     FROM dm_info do
     WHERE do.info_domain="DM2_FLEXIBLE_SCHEDULE"
      AND  NOT (do.info_name IN ("STATUS", "RUNNER TIME LIMIT")))
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   DELETE  FROM dm_info di
    WHERE di.info_domain="DM2_FLEXIBLE_SCHEDULE"
     AND  NOT (di.info_name IN ("STATUS", "RUNNER TIME LIMIT"))
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   COMMIT
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_FLEXIBLE_SCHEDULE*"
    ORDER BY di.info_domain, di.updt_cnt
    HEAD di.info_domain
     dgfs_cnt = 0, dgfs_process = substring(23,textlen(di.info_domain),di.info_domain)
    DETAIL
     IF (di.info_name="STATUS")
      drr_flex_sched->sched_set_up = 1, drr_flex_sched->status = evaluate(cnvtupper(di.info_char),
       "ON",1,0)
     ENDIF
     IF (di.info_name="RUNNER TIME LIMIT")
      drr_flex_sched->runner_time_limit = di.info_number
     ENDIF
     IF (di.info_name="TIME PERIOD*")
      dgfs_time_period = trim(cnvtupper(substring(1,(findstring("-",di.info_name) - 1),di.info_name))
       )
      IF (dgfs_process="README")
       dgfs_idx = 0
       IF (dgfs_cnt > 0)
        dgfs_idx = locateval(dgfs_idx,1,dgfs_cnt,dgfs_time_period,drr_flex_sched->readme_schedule[
         dgfs_idx].time_period)
       ENDIF
       IF (dgfs_idx=0)
        dgfs_cnt = (dgfs_cnt+ 1)
        IF (mod(dgfs_cnt,5)=1)
         stat = alterlist(drr_flex_sched->readme_schedule,(dgfs_cnt+ 4))
        ENDIF
        dgfs_idx = dgfs_cnt
       ENDIF
       drr_flex_sched->readme_schedule[dgfs_idx].time_period = dgfs_time_period
       IF (findstring("START",cnvtupper(di.info_name)) > 0)
        drr_flex_sched->readme_schedule[dgfs_idx].start_time = di.info_number
       ELSEIF (findstring("END",cnvtupper(di.info_name)) > 0)
        drr_flex_sched->readme_schedule[dgfs_idx].end_time = di.info_number
       ELSE
        drr_flex_sched->readme_schedule[dgfs_idx].num_of_runners = di.info_number
       ENDIF
      ELSEIF (dgfs_process="SCHEMA")
       dgfs_idx = 0
       IF (dgfs_cnt > 0)
        dgfs_idx = locateval(dgfs_idx,1,dgfs_cnt,dgfs_time_period,drr_flex_sched->schema_schedule[
         dgfs_idx].time_period)
       ENDIF
       IF (dgfs_idx=0)
        dgfs_cnt = (dgfs_cnt+ 1)
        IF (mod(dgfs_cnt,5)=1)
         stat = alterlist(drr_flex_sched->schema_schedule,(dgfs_cnt+ 4))
        ENDIF
        dgfs_idx = dgfs_cnt
       ENDIF
       drr_flex_sched->schema_schedule[dgfs_idx].time_period = dgfs_time_period
       IF (findstring("START",cnvtupper(di.info_name)) > 0)
        drr_flex_sched->schema_schedule[dgfs_idx].start_time = di.info_number
       ELSEIF (findstring("END",cnvtupper(di.info_name)) > 0)
        drr_flex_sched->schema_schedule[dgfs_idx].end_time = di.info_number
       ELSE
        drr_flex_sched->schema_schedule[dgfs_idx].num_of_runners = di.info_number
       ENDIF
      ENDIF
     ENDIF
    FOOT  di.info_domain
     IF (dgfs_process="README")
      drr_flex_sched->readme_time_periods = dgfs_cnt, stat = alterlist(drr_flex_sched->
       readme_schedule,drr_flex_sched->readme_time_periods)
     ELSEIF (dgfs_process="SCHEMA")
      drr_flex_sched->schema_time_periods = dgfs_cnt, stat = alterlist(drr_flex_sched->
       schema_schedule,drr_flex_sched->schema_time_periods)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET drr_flex_sched->sched_set_up = 0
    SET drr_flex_sched->status = 0
   ENDIF
   IF ((drr_flex_sched->runner_time_limit=- (1)))
    SET drr_flex_sched->runner_time_limit = 10
   ENDIF
   IF ((dm_err->debug_flag > 3))
    CALL echorecord(drr_flex_sched)
   ENDIF
   IF ((dm_err->debug_flag > 622))
    SET message = nowindow
    CALL disp_msg(" ",dm_err->logfile,0)
    CALL echorecord(drr_flex_sched)
    SET message = window
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_use_flexible_schedule(dufs_prompt_ind,dufs_pkg_number,dufs_install_mode,dufs_sel_ret)
   DECLARE dufs_line_cnt = i4 WITH protect, noconstant(0)
   DECLARE dufs_choice = vc WITH protect, noconstant(" ")
   DECLARE dufs_idx = i2 WITH protect, noconstant(0)
   DECLARE dufs_hold_time = vc WITH protect, noconstant("")
   SET dufs_sel_ret = ""
   IF ((( NOT (dufs_prompt_ind IN (0, 1))) OR (((dufs_install_mode=" ") OR (dufs_pkg_number=" ")) ))
   )
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid input for subroutine drr_use_flexible_schedule"
    SET dm_err->eproc = "Validating information passed into subroutine."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((drr_flex_sched->pkg_number="DM2NOTSET"))
    SET drr_flex_sched->pkg_number = dufs_pkg_number
   ENDIF
   IF ((drr_flex_sched->pkg_install_mode="DM2NOTSET"))
    SET drr_flex_sched->pkg_install_mode = dufs_install_mode
   ENDIF
   IF (currdb != "ORACLE")
    SET dm_err->eproc =
    "Package will not attempt to use installation schedule because RDBMS is not Oracle"
    CALL disp_msg(" ",dm_err->logfile,0)
    SET drr_flex_sched->pkg_using_schedule = 0
    RETURN(1)
   ENDIF
   IF ( NOT ((drr_flex_sched->pkg_install_mode IN ("BATCHUP", "BATCHPRECYCLE", "BATCHDOWN",
   "BATCHPOST", "BATCHEXPRESS"))))
    SET dm_err->eproc = "Package will not attempt to use installation schedule due to install mode."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET drr_flex_sched->pkg_using_schedule = 0
    RETURN(1)
   ENDIF
   IF (drr_cleanup_dm_info_sched_usage(null)=0)
    RETURN(0)
   ENDIF
   IF (drr_get_flexible_schedule(null)=0)
    RETURN(0)
   ENDIF
   IF ((drr_flex_sched->status=0))
    SET dm_err->eproc =
    "Package will not use installation schedule because it's not set up or currently turned on."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET drr_flex_sched->pkg_using_schedule = 0
    RETURN(1)
   ENDIF
   IF (dm2_rr_toolset_usage(null)=0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm2_rr_misc->dm2_toolset_usage="N"))
    SET dm_err->eproc =
    "Package will not use installation schedule because old dm tools being used for readme processing"
    CALL disp_msg(" ",dm_err->logfile,0)
    SET drr_flex_sched->pkg_using_schedule = 0
    RETURN(1)
   ENDIF
   IF (dufs_prompt_ind=1)
    WHILE ( NOT (dufs_choice IN ("C", "Q")))
      SET message = window
      SET width = 132
      CALL clear(1,1)
      CALL video(n)
      CALL text(2,1,"Installation Scheduler: ",w)
      CALL text(4,1,concat("Please confirm Installation Scheduler configuration:"))
      CALL text(6,1,concat("Status:",evaluate(drr_flex_sched->status,0,"OFF","ON")))
      CALL text(6,12,"README(R) SCHEMA(S)")
      CALL text(9,1,"(R)")
      SET dufs_line_cnt = 8
      CALL text(dufs_line_cnt,5,"Time Slot")
      CALL text(dufs_line_cnt,18,"Start Time")
      CALL text(dufs_line_cnt,34,"End Time")
      CALL text(dufs_line_cnt,49,"Num Runners")
      FOR (dufs_idx = 1 TO drr_flex_sched->readme_time_periods)
        SET dufs_line_cnt = (dufs_line_cnt+ 1)
        SET drr_flex_sched->readme_schedule[dufs_idx].time_period = cnvtstring(dufs_idx)
        SET drr_flex_sched->readme_schedule[dufs_idx].start_time_hhmm = drr_flex_sched->
        readme_schedule[dufs_idx].start_time
        SET dufs_hold_time = cnvtupper(format(drr_flex_sched->readme_schedule[dufs_idx].
          start_time_hhmm,"HH;;s"))
        SET drr_flex_sched->readme_schedule[dufs_idx].start_time_hh = cnvtint(trim(replace(replace(
            dufs_hold_time,"AM","",0),"PM","",0),3))
        IF ((drr_flex_sched->readme_schedule[dufs_idx].start_time_hh=0))
         SET drr_flex_sched->readme_schedule[dufs_idx].start_time_hh = 12
        ENDIF
        IF (findstring("AM",dufs_hold_time) > 0)
         SET drr_flex_sched->readme_schedule[dufs_idx].start_time_am_pm = "AM"
        ELSE
         SET drr_flex_sched->readme_schedule[dufs_idx].start_time_am_pm = "PM"
        ENDIF
        SET drr_flex_sched->readme_schedule[dufs_idx].end_time_hhmm = drr_flex_sched->
        readme_schedule[dufs_idx].end_time
        SET dufs_hold_time = cnvtupper(format(drr_flex_sched->readme_schedule[dufs_idx].end_time_hhmm,
          "HH;;s"))
        SET drr_flex_sched->readme_schedule[dufs_idx].end_time_hh = cnvtint(trim(replace(replace(
            dufs_hold_time,"AM","",0),"PM","",0),3))
        IF ((drr_flex_sched->readme_schedule[dufs_idx].end_time_hh=0))
         SET drr_flex_sched->readme_schedule[dufs_idx].end_time_hh = 12
        ENDIF
        IF (findstring("AM",dufs_hold_time) > 0)
         SET drr_flex_sched->readme_schedule[dufs_idx].end_time_am_pm = "AM"
        ELSE
         SET drr_flex_sched->readme_schedule[dufs_idx].end_time_am_pm = "PM"
        ENDIF
        SET drr_flex_sched->readme_schedule[dufs_idx].num_of_runners = drr_flex_sched->
        readme_schedule[dufs_idx].num_of_runners
        CALL text(dufs_line_cnt,5,cnvtstring(dufs_idx))
        CALL text(dufs_line_cnt,19,cnvtstring(drr_flex_sched->readme_schedule[dufs_idx].start_time_hh
          ))
        CALL text(dufs_line_cnt,22,drr_flex_sched->readme_schedule[dufs_idx].start_time_am_pm)
        CALL text(dufs_line_cnt,34,cnvtstring(drr_flex_sched->readme_schedule[dufs_idx].end_time_hh))
        CALL text(dufs_line_cnt,37,drr_flex_sched->readme_schedule[dufs_idx].end_time_am_pm)
        CALL text(dufs_line_cnt,49,cnvtstring(drr_flex_sched->readme_schedule[dufs_idx].
          num_of_runners))
      ENDFOR
      SET dufs_line_cnt = (dufs_line_cnt+ 1)
      CALL text(dufs_line_cnt,1,"(S)")
      FOR (dufs_idx = 1 TO drr_flex_sched->schema_time_periods)
        IF (dufs_idx != 1)
         SET dufs_line_cnt = (dufs_line_cnt+ 1)
        ENDIF
        SET drr_flex_sched->schema_schedule[dufs_idx].time_period = cnvtstring(dufs_idx)
        SET drr_flex_sched->schema_schedule[dufs_idx].start_time_hhmm = drr_flex_sched->
        schema_schedule[dufs_idx].start_time
        SET dufs_hold_time = cnvtupper(format(drr_flex_sched->schema_schedule[dufs_idx].
          start_time_hhmm,"HH;;s"))
        SET drr_flex_sched->schema_schedule[dufs_idx].start_time_hh = cnvtint(trim(replace(replace(
            dufs_hold_time,"AM","",0),"PM","",0),3))
        IF ((drr_flex_sched->schema_schedule[dufs_idx].start_time_hh=0))
         SET drr_flex_sched->schema_schedule[dufs_idx].start_time_hh = 12
        ENDIF
        IF (findstring("AM",dufs_hold_time) > 0)
         SET drr_flex_sched->schema_schedule[dufs_idx].start_time_am_pm = "AM"
        ELSE
         SET drr_flex_sched->schema_schedule[dufs_idx].start_time_am_pm = "PM"
        ENDIF
        SET drr_flex_sched->schema_schedule[dufs_idx].end_time_hhmm = drr_flex_sched->
        schema_schedule[dufs_idx].end_time
        SET dufs_hold_time = cnvtupper(format(drr_flex_sched->schema_schedule[dufs_idx].end_time_hhmm,
          "HH;;s"))
        SET drr_flex_sched->schema_schedule[dufs_idx].end_time_hh = cnvtint(trim(replace(replace(
            dufs_hold_time,"AM","",0),"PM","",0),3))
        IF ((drr_flex_sched->schema_schedule[dufs_idx].end_time_hh=0))
         SET drr_flex_sched->schema_schedule[dufs_idx].end_time_hh = 12
        ENDIF
        IF (findstring("AM",dufs_hold_time) > 0)
         SET drr_flex_sched->schema_schedule[dufs_idx].end_time_am_pm = "AM"
        ELSE
         SET drr_flex_sched->schema_schedule[dufs_idx].end_time_am_pm = "PM"
        ENDIF
        SET drr_flex_sched->schema_schedule[dufs_idx].num_of_runners = drr_flex_sched->
        schema_schedule[dufs_idx].num_of_runners
        CALL text(dufs_line_cnt,5,cnvtstring(dufs_idx))
        CALL text(dufs_line_cnt,19,cnvtstring(drr_flex_sched->schema_schedule[dufs_idx].start_time_hh
          ))
        CALL text(dufs_line_cnt,22,drr_flex_sched->schema_schedule[dufs_idx].start_time_am_pm)
        CALL text(dufs_line_cnt,34,cnvtstring(drr_flex_sched->schema_schedule[dufs_idx].end_time_hh))
        CALL text(dufs_line_cnt,37,drr_flex_sched->schema_schedule[dufs_idx].end_time_am_pm)
        CALL text(dufs_line_cnt,49,cnvtstring(drr_flex_sched->schema_schedule[dufs_idx].
          num_of_runners))
      ENDFOR
      SET dufs_line_cnt = (dufs_line_cnt+ 2)
      CALL text(dufs_line_cnt,1,concat("(C)ontinue with above schedule, (M)odify, (Q)uit :"))
      CALL accept(dufs_line_cnt,53,"A;cu"," "
       WHERE curaccept IN ("Q", "C", "M"))
      SET dufs_choice = curaccept
      SET dufs_sel_ret = dufs_choice
      SET message = nowindow
      IF (dufs_choice="M")
       EXECUTE dm2_flexible_schedule_menu
       IF ((dm_err->err_ind > 0))
        RETURN(0)
       ENDIF
       IF (drr_get_flexible_schedule(null)=0)
        RETURN(0)
       ENDIF
      ENDIF
    ENDWHILE
   ENDIF
   IF ((drr_flex_sched->status=1))
    SET dm_err->eproc =
    "Determining if DM_INFO row to denote the package is using the installation schedule exists..."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    UPDATE  FROM dm_info di
     SET di.info_date = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)), di.info_char = currdbhandle,
      di.info_number = 1,
      di.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)), di.updt_applctx = 0, di
      .updt_cnt = 0,
      di.updt_id = 0, di.updt_task = reqinfo->updt_task
     WHERE di.info_domain="DM2_FLEX_SCHED_USAGE"
      AND (di.info_name=drr_flex_sched->pkg_number)
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (curqual=0)
     SET dm_err->eproc =
     "Inserting DM_INFO row to denote the package is using the installation schedule..."
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     INSERT  FROM dm_info di
      SET di.info_domain = "DM2_FLEX_SCHED_USAGE", di.info_name = drr_flex_sched->pkg_number, di
       .info_date = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)),
       di.info_char = currdbhandle, di.info_number = 1, di.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(
         curdate,curtime3)),
       di.updt_applctx = 0, di.updt_cnt = 0, di.updt_id = 0,
       di.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      ROLLBACK
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
    ELSE
     COMMIT
    ENDIF
    SET drr_flex_sched->pkg_using_schedule = 1
   ELSE
    SET drr_flex_sched->pkg_using_schedule = 0
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_maintain_runners(dmr_user,dmr_pword,dmr_cnnct_str,dmr_queue_name,dm_process)
   DECLARE dmr_curtime_hhmm = f8 WITH protect, noconstant(0.0)
   DECLARE dmr_cnt = i4 WITH protect, noconstant(0)
   DECLARE dmr_env_name = vc WITH protect, noconstant(" ")
   DECLARE dmr_time_fnd_ind = i2 WITH protect, noconstant(0)
   DECLARE dmr_process_status = i2 WITH protect, noconstant(0)
   SET drr_flex_sched->num_sched_runners = 0
   SET drr_flex_sched->num_active_runners = 0
   SET drr_flex_sched->num_runners_to_stop = 0
   SET drr_flex_sched->num_runners_to_start = 0
   SET drr_flex_sched->num_stopping_runners = 0
   SET drr_flex_sched->tot_num_runners = 0
   IF (((dmr_user=" ") OR (dmr_pword=" ")) )
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid database connection information for subroutine drr_maintain_runners"
    SET dm_err->eproc = "Validating connection information passed into subroutine."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((drr_flex_sched->pkg_using_schedule=1)
    AND (dm2_process_event_rs->ui_allowed_ind=1))
    IF (drr_get_process_status("DM2_INSTALL_MONITOR",abs(cnvtreal(drr_flex_sched->pkg_number)),
     dmr_process_status)=0)
     RETURN(0)
    ENDIF
    IF (dmr_process_status=0)
     IF (drr_submit_background_process(dm2_install_schema->u_name,dm2_install_schema->p_word,
      dm2_install_schema->connect_str,dmr_queue_name,dpl_install_monitor,
      cnvtreal(drr_flex_sched->pkg_number),drr_flex_sched->pkg_install_mode)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF (drr_cleanup_dm_info_runners(null)=0)
    RETURN(0)
   ENDIF
   IF (drr_get_flexible_schedule(null)=0)
    RETURN(0)
   ENDIF
   IF (drr_stop_runners("LONG_RUNNING",drr_flex_sched->runner_time_limit)=0)
    RETURN(0)
   ENDIF
   SET dmr_curtime_hhmm = curtime
   IF ((dm_err->debug_flag > 2))
    CALL echo(build("CUrrent time in HHMM = ",dmr_curtime_hhmm))
   ENDIF
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc =
    "Determining how many runners should be running based on installation schedule..."
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (dm_process="README")
    SET time_periods = drr_flex_sched->readme_time_periods
   ELSEIF (dm_process="SCHEMA")
    SET time_periods = drr_flex_sched->schema_time_periods
   ENDIF
   FOR (dmr_cnt = 1 TO time_periods)
    IF (dm_process="README")
     SET curalias schedule drr_flex_sched->readme_schedule[dmr_cnt]
    ELSEIF (dm_process="SCHEMA")
     SET curalias schedule drr_flex_sched->schema_schedule[dmr_cnt]
    ENDIF
    IF ((schedule->start_time=schedule->end_time))
     SET drr_flex_sched->num_sched_runners = schedule->num_of_runners
     SET dmr_cnt = time_periods
     SET dmr_time_fnd_ind = 1
    ELSEIF ((schedule->start_time < schedule->end_time))
     IF ((dmr_curtime_hhmm >= schedule->start_time)
      AND (dmr_curtime_hhmm < schedule->end_time))
      SET drr_flex_sched->num_sched_runners = schedule->num_of_runners
      SET dmr_cnt = time_periods
      SET dmr_time_fnd_ind = 1
     ENDIF
    ELSE
     IF ((((dmr_curtime_hhmm >= schedule->start_time)
      AND dmr_curtime_hhmm < 2400) OR (dmr_curtime_hhmm >= 0000
      AND (dmr_curtime_hhmm < schedule->end_time))) )
      SET drr_flex_sched->num_sched_runners = schedule->num_of_runners
      SET dmr_cnt = time_periods
      SET dmr_time_fnd_ind = 1
     ENDIF
    ENDIF
   ENDFOR
   IF (dmr_time_fnd_ind=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Number of runners could not be retrieved for current time."
    SET dm_err->eproc = "Retrieving number of runners to execute from installation schedule."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ELSE
    IF ((dm_err->debug_flag > 0))
     SET dm_err->eproc = concat(trim(cnvtstring(drr_flex_sched->num_sched_runners)),
      " runner(s) should be running.")
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Determining how many runners are actively running..."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_BACKGROUND_RUNNER"
    DETAIL
     IF (di.info_number=1)
      drr_flex_sched->num_active_runners = (drr_flex_sched->num_active_runners+ 1)
     ELSE
      drr_flex_sched->num_stopping_runners = (drr_flex_sched->num_stopping_runners+ 1)
     ENDIF
     drr_flex_sched->tot_num_runners = (drr_flex_sched->tot_num_runners+ 1)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc = concat(trim(cnvtstring(drr_flex_sched->num_active_runners)),
     " runner(s) currently running.")
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF ((drr_flex_sched->tot_num_runners=drr_flex_sched->num_sched_runners))
    IF ((dm_err->debug_flag > 0))
     SET dm_err->eproc =
     "Currently running the specified number of runners from installation schedule..."
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    RETURN(1)
   ENDIF
   IF ((drr_flex_sched->tot_num_runners > drr_flex_sched->num_sched_runners))
    IF ((drr_flex_sched->num_active_runners=0))
     IF ((dm_err->debug_flag > 0))
      SET dm_err->eproc = concat(
       "No active runners to stop at this time: All existing runners have been marked to stop.")
      CALL disp_msg(" ",dm_err->logfile,0)
      RETURN(1)
     ENDIF
    ELSEIF ((drr_flex_sched->num_active_runners < drr_flex_sched->tot_num_runners))
     IF ((drr_flex_sched->num_active_runners <= drr_flex_sched->num_sched_runners))
      SET drr_flex_sched->num_runners_to_stop = drr_flex_sched->num_active_runners
      IF ((dm_err->debug_flag > 0))
       SET dm_err->eproc = concat("Need to stop ",trim(cnvtstring(drr_flex_sched->num_runners_to_stop
          ))," active runner(s)...")
       CALL disp_msg(" ",dm_err->logfile,0)
      ENDIF
      IF (drr_stop_runners("NUM_RUNNERS",drr_flex_sched->num_runners_to_stop)=0)
       RETURN(0)
      ENDIF
     ELSE
      SET drr_flex_sched->num_runners_to_stop = (drr_flex_sched->num_active_runners - (drr_flex_sched
      ->num_sched_runners - drr_flex_sched->num_stopping_runners))
      IF ((dm_err->debug_flag > 0))
       SET dm_err->eproc = concat("Need to stop ",trim(cnvtstring(drr_flex_sched->num_runners_to_stop
          ))," active runner(s)...")
       CALL disp_msg(" ",dm_err->logfile,0)
      ENDIF
      IF (drr_stop_runners("NUM_RUNNERS",drr_flex_sched->num_runners_to_stop)=0)
       RETURN(0)
      ENDIF
     ENDIF
    ELSEIF ((drr_flex_sched->num_active_runners=drr_flex_sched->tot_num_runners))
     SET drr_flex_sched->num_runners_to_stop = (drr_flex_sched->num_active_runners - drr_flex_sched->
     num_sched_runners)
     IF ((dm_err->debug_flag > 0))
      SET dm_err->eproc = concat("Need to stop ",trim(cnvtstring(drr_flex_sched->num_runners_to_stop)
        )," active runner(s)...")
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     IF (drr_stop_runners("NUM_RUNNERS",drr_flex_sched->num_runners_to_stop)=0)
      RETURN(0)
     ENDIF
    ENDIF
   ELSE
    SET drr_flex_sched->num_runners_to_start = (drr_flex_sched->num_sched_runners - drr_flex_sched->
    tot_num_runners)
    IF ((dm_err->debug_flag > 0))
     SET dm_err->eproc = concat("Need to start ",trim(cnvtstring(drr_flex_sched->num_runners_to_start
        ))," runner(s)...")
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    IF (drr_start_runners(drr_flex_sched->num_runners_to_start,dmr_user,dmr_pword,dmr_cnnct_str,
     dmr_queue_name)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
   SET curalias schedule off
 END ;Subroutine
 SUBROUTINE drr_check_pkg_appl_status(dcpas_appl_id,dcpas_pkg_status)
   SET dm_err->eproc =
   "Determining if appl id attached to a package install using installation schedule is active."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_FLEX_SCHED_USAGE"
     AND di.info_char=dcpas_appl_id
     AND di.info_number=1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dcpas_pkg_status = 1
   ELSE
    SET dcpas_pkg_status = 0
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_check_runner_status(dcrs_runner_type,dcrs_appl_id,dcrs_status)
   SET dm_err->eproc = "Evaluating whether the runner has been marked to stop."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET dcrs_status = 0
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=dcrs_runner_type
     AND di.info_name=dcrs_appl_id
    DETAIL
     dcrs_status = di.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_insert_runner_row(dirr_runner_type,dirr_appl_id,dirr_desc,dirr_status,dirr_plan_id)
   DECLARE dirr_process_name = vc WITH protect, noconstant("NOTSET")
   CASE (dirr_runner_type)
    OF "DM2_INSTALL_RUNNER":
     SET dirr_process_name = dpl_install_runner
    OF "DM2_BACKGROUND_RUNNER":
     SET dirr_process_name = dpl_background_runner
    OF "DM2_INSTALL_PKG":
     SET dirr_process_name = dpl_package_install
    OF "DM2_INSTALL_MONITOR":
     SET dirr_process_name = dpl_install_monitor
    OF "DM2_ADS_DRIVER_GEN:AUDSID":
     SET dirr_process_name = dpl_sample
    OF "DM2_ADS_CHILDEST_GEN:AUDSID":
     SET dirr_process_name = dpl_sample
    OF "DM2_ADS_RUNNER:AUDSID":
     SET dirr_process_name = dpl_sample
   ENDCASE
   IF (dpl_ui_chk(dirr_process_name)=0)
    RETURN(0)
   ENDIF
   IF (drr_cleanup_dm_info_runners(null)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_process_event_rs->ui_allowed_ind=1)
    AND dirr_process_name != "NOTSET")
    SET dm2_process_event_rs->install_plan_id = dirr_plan_id
    SET dm2_process_event_rs->status = dpl_executing
    CALL dm2_process_log_add_detail_text(dpl_logfilemain,dm_err->logfile)
    SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_date = cnvtdatetime(
     curdate,curtime3)
    CALL dm2_process_log_add_detail_text(dpl_audsid,currdbhandle)
    CASE (dirr_process_name)
     OF dpl_install_runner:
      CALL dm2_process_log_add_detail_number("BACKGROUND_IND",0.0)
      CALL dm2_process_log_add_detail_number("SCHEDULER_IND",0.0)
     OF dpl_background_runner:
      CALL dm2_process_log_add_detail_number("BACKGROUND_IND",1.0)
      CALL dm2_process_log_add_detail_number("SCHEDULER_IND",1.0)
     OF dpl_install_monitor:
      CALL dm2_process_log_add_detail_number("BACKGROUND_IND",1.0)
    ENDCASE
    SET dm2_process_rs->process_name = dirr_process_name
    CALL dm2_process_log_row(dirr_process_name,dpl_execution,dpl_no_prev_id,1)
    SET dir_ui_misc->dm_process_event_id = dm2_process_event_rs->dm_process_event_id
    SET dm2_process_event_rs->begin_dt_tm = cnvtdatetime(curdate,curtime3)
    SET dm2_process_event_rs->end_dt_tm = cnvtdatetime(curdate,curtime3)
    SET dm2_process_event_rs->install_plan_id = dirr_plan_id
    SET dm2_process_event_rs->status = dpl_complete
    CALL dm2_process_log_add_detail_text(dpl_audit_name,concat(dirr_process_name,"-STARTED"))
    CALL dm2_process_log_add_detail_text(dpl_audit_type,dpl_progress)
    IF (dm2_process_log_row(dpl_package_install,dpl_auditlog,dpl_no_prev_id,0)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dirr_process_name=dpl_sample)
    SET dm2_process_event_rs->status = dpl_executing
    CALL dm2_process_log_add_detail_text(dpl_logfilemain,dm_err->logfile)
    SET dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_date = cnvtdatetime(
     curdate,curtime3)
    CALL dm2_process_log_add_detail_text(dpl_audsid,currdbhandle)
    SET dm2_process_rs->process_name = dirr_process_name
    CALL dm2_process_log_row(dirr_process_name,dpl_execution,dpl_no_prev_id,1)
    SET dir_ui_misc->dm_process_event_id = dm2_process_event_rs->dm_process_event_id
   ENDIF
   SET dm_err->eproc = concat("Determining if DM_INFO runner row for ",trim(dirr_runner_type,3),
    " and appl id ",trim(dirr_appl_id,3)," exists.")
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=dirr_runner_type
     AND di.info_name=dirr_appl_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = concat("Inserting DM_INFO runner row for ",trim(dirr_runner_type,3),
     " and appl id ",trim(dirr_appl_id,3),"...")
    CALL disp_msg(" ",dm_err->logfile,0)
    INSERT  FROM dm_info di
     SET di.info_domain = dirr_runner_type, di.info_name = dirr_appl_id, di.info_date =
      cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)),
      di.info_char =
      IF (dirr_runner_type IN ("DM2_INSTALL_PKG", "DM2_INSTALL_MONITOR")) trim(cnvtstring(
         dirr_plan_id))
      ELSE dirr_desc
      ENDIF
      , di.info_number = dirr_status, di.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)),
      di.updt_applctx = 0, di.updt_cnt = 0, di.updt_id = 0,
      di.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
   ELSE
    SET dm_err->eproc = concat("Updating DM_INFO runner row for ",trim(dirr_runner_type,3),
     " and appl id ",trim(dirr_appl_id,3),"...")
    CALL disp_msg(" ",dm_err->logfile,0)
    UPDATE  FROM dm_info di
     SET di.info_date = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)), di.info_char =
      IF (dirr_runner_type IN ("DM2_INSTALL_PKG", "DM2_INSTALL_MONITOR")) trim(cnvtstring(
         dirr_plan_id))
      ELSE dirr_desc
      ENDIF
      , di.info_number = dirr_status,
      di.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)), di.updt_applctx = 0, di
      .updt_cnt = 0,
      di.updt_id = 0, di.updt_task = reqinfo->updt_task
     WHERE di.info_domain=dirr_runner_type
      AND di.info_name=dirr_appl_id
     WITH nocounter
    ;end update
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_remove_runner_row(drrr_runner_type,drrr_appl_id)
   DECLARE drrr_process_name = vc WITH protect, noconstant("")
   DECLARE drrr_install_plan_number = f8 WITH protect, noconstant(0.0)
   DECLARE drrr_err_ind = i2 WITH protect, noconstant(0)
   DECLARE drrr_emsg = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE drrr_eproc = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE drrr_optimizer_hint = vc WITH protect, noconstant("")
   SET drrr_err_ind = dm_err->err_ind
   SET drrr_emsg = dm_err->emsg
   SET drrr_eproc = dm_err->eproc
   SET dm_err->err_ind = 0
   SET dm_err->emsg = ""
   SET dm_err->eproc = ""
   SET drrr_optimizer_hint = concat(" LEADING(DP DPE )","INDEX(DP XAK1DM_PROCESS)",
    "INDEX(DPE XIE1DM_PROCESS_EVENT)")
   CASE (drrr_runner_type)
    OF "DM2_INSTALL_RUNNER":
     SET drrr_process_name = dpl_install_runner
    OF "DM2_BACKGROUND_RUNNER":
     SET drrr_process_name = dpl_background_runner
    OF "DM2_INSTALL_PKG":
     SET drrr_process_name = dpl_package_install
    OF "DM2_INSTALL_MONITOR":
     SET drrr_process_name = dpl_install_monitor
    OF "DM2_ADS_DRIVER_GEN:AUDSID":
     SET drrr_process_name = dpl_sample
    OF "DM2_ADS_CHILDEST_GEN:AUDSID":
     SET drrr_process_name = dpl_sample
    OF "DM2_ADS_RUNNER:AUDSID":
     SET drrr_process_name = dpl_sample
   ENDCASE
   IF (drrr_process_name=dpl_sample)
    IF ((((dm_err->err_ind=0)) OR ((dm_err->debug_flag > 0))) )
     SET dm_err->eproc = "Update process event to appropriate status"
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    UPDATE  FROM dm_process_event dpe
     SET dpe.event_status = evaluate(drrr_err_ind,1,"FAILED","COMPLETE"), dpe.message_txt = evaluate(
       drrr_err_ind,1,substring(1,1900,drrr_emsg),"Removed runner row")
     WHERE (dpe.dm_process_event_id=dir_ui_misc->dm_process_event_id)
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   CALL dpl_ui_chk(drrr_process_name)
   IF ((dm2_process_event_rs->ui_allowed_ind=1))
    IF ((((dm_err->err_ind=0)) OR ((dm_err->debug_flag > 0))) )
     SET dm_err->eproc = "Update process event to appropriate status"
    ENDIF
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    UPDATE  FROM dm_process_event dpe
     SET dpe.event_status = evaluate(drrr_err_ind,1,"FAILED","COMPLETE"), dpe.message_txt = evaluate(
       drrr_err_ind,1,substring(1,1900,drrr_emsg),"Removed runner row")
     WHERE (dpe.dm_process_event_id=dir_ui_misc->dm_process_event_id)
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ELSE
     COMMIT
    ENDIF
    IF (drrr_err_ind=1
     AND drrr_process_name=dpl_package_install)
     IF ((dm_err->err_ind=0))
      SET dm_err->eproc = "Obtain the Install_Plan_Id for the AudSid"
      IF ((dm_err->debug_flag > 0))
       CALL disp_msg("",dm_err->logfile,0)
      ENDIF
      SELECT INTO "nl:"
       FROM dm_info di
       WHERE di.info_domain="DM2_INSTALL_PKG"
        AND di.info_name=drrr_appl_id
       DETAIL
        drrr_install_plan_number = cnvtreal(di.info_char)
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ENDIF
     ENDIF
     IF (curqual > 0)
      IF ((dm_err->err_ind=0))
       SET dm_err->eproc = "Update the event status for the removed runners"
       IF ((dm_err->debug_flag > 0))
        CALL disp_msg("",dm_err->logfile,0)
       ENDIF
       UPDATE  FROM dm_process_event dpe1
        SET dpe1.event_status = dpl_failed, dpe1.message_txt = dm_err->emsg
        WHERE dpe1.dm_process_event_id IN (
        (SELECT
         dpe.dm_process_event_id
         FROM dm_process dp,
          dm_process_event dpe
         WHERE dp.dm_process_id=dpe.dm_process_id
          AND dp.process_name=dpl_package_install
          AND dp.action_type=dpl_itinerary_event
          AND dpe.install_plan_id=drrr_install_plan_number
          AND (( NOT (dpe.event_status IN (dpl_success, dpl_complete, dpl_failure, dpl_failed))) OR (
         dpe.event_status = null))
          AND dpe.begin_dt_tm > cnvtdatetime("01-JAN-1900")
          AND dpe.begin_dt_tm IS NOT null
         WITH orahintcbo(value(drrr_optimizer_hint))))
        WITH nocounter
       ;end update
       IF (check_error(dm_err->eproc)=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ELSE
        COMMIT
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    IF ((dm_err->err_ind=0))
     SET dm_err->eproc = "Obtain the Install_Plan_Id from DM_PROCESS_EVENT"
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     SELECT INTO "nl:"
      FROM dm_process_event dpe
      WHERE (dpe.dm_process_event_id=dir_ui_misc->dm_process_event_id)
      DETAIL
       drrr_install_plan_number = dpe.install_plan_id
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ENDIF
    ENDIF
    IF ((dm_err->err_ind=0))
     IF (curqual > 0)
      SET dm2_process_event_rs->begin_dt_tm = cnvtdatetime(curdate,curtime3)
      SET dm2_process_event_rs->end_dt_tm = cnvtdatetime(curdate,curtime3)
      SET dm2_process_event_rs->install_plan_id = drrr_install_plan_number
      SET dm2_process_event_rs->status = dpl_complete
      CALL dm2_process_log_add_detail_text(dpl_audit_name,concat(drrr_process_name,evaluate(
         drrr_err_ind,0,"-COMPLETE","-FAILED")))
      CALL dm2_process_log_add_detail_text(dpl_audit_type,dpl_progress)
      CALL dm2_process_log_row(dpl_package_install,dpl_auditlog,dpl_no_prev_id,0)
     ENDIF
    ENDIF
   ENDIF
   IF ((dm_err->err_ind=0))
    SET dm_err->eproc = concat("Remove DM_INFO runner row for ",trim(drrr_runner_type,3),
     " and appl id ",trim(drrr_appl_id,3))
    CALL disp_msg(" ",dm_err->logfile,0)
    DELETE  FROM dm_info di
     WHERE di.info_domain=drrr_runner_type
      AND di.info_name=drrr_appl_id
     WITH nocounter
    ;end delete
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   SET dm_err->err_ind = drrr_err_ind
   SET dm_err->emsg = drrr_emsg
   SET dm_err->eproc = drrr_eproc
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_rr_insert_runner_row(drirr_runner_identifier,drirr_appl_id)
   IF (drr_rr_cleanup_dm_info_runners(null)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Determining if Admin DM_INFO runner row for ",trim(
     drirr_runner_identifier,3)," and appl id ",trim(drirr_appl_id,3)," exists.")
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info di
    WHERE di.info_domain=drirr_runner_identifier
     AND di.info_name=drirr_appl_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = concat("Inserting Admin DM_INFO runner row for ",trim(drirr_runner_identifier,
      3)," and appl id ",trim(drirr_appl_id,3),"...")
    CALL disp_msg(" ",dm_err->logfile,0)
    INSERT  FROM dm2_admin_dm_info di
     SET di.info_domain = drirr_runner_identifier, di.info_name = drirr_appl_id, di.info_date =
      cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)),
      di.info_number = 1, di.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)), di
      .updt_applctx = 0,
      di.updt_cnt = 0, di.updt_id = 0, di.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
   ELSE
    SET dm_err->eproc = concat("Updating Admin DM_INFO runner row for ",trim(drirr_runner_identifier,
      3)," and appl id ",trim(drirr_appl_id,3),"...")
    CALL disp_msg(" ",dm_err->logfile,0)
    UPDATE  FROM dm2_admin_dm_info di
     SET di.info_date = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)), di.info_number = 1, di
      .updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)),
      di.updt_applctx = 0, di.updt_cnt = 0, di.updt_id = 0,
      di.updt_task = reqinfo->updt_task
     WHERE di.info_domain=drirr_runner_identifier
      AND di.info_name=drirr_appl_id
     WITH nocounter
    ;end update
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    COMMIT
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_rr_check_runner_status(drcrs_runner_identifier,drcrs_appl_id,drcrs_status)
   SET dm_err->eproc = concat("Evaluating whether main/runner session (",drcrs_runner_identifier,
    ") has been marked to stop.")
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET drcrs_status = 0
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info di
    WHERE di.info_domain=drcrs_runner_identifier
     AND di.info_name=drcrs_appl_id
    DETAIL
     drcrs_status = di.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_rr_cleanup_dm_info_runners(null)
   DECLARE drcdir_applx = i4 WITH protect, noconstant(0)
   FREE RECORD drcdir_appl_rs
   RECORD drcdir_appl_rs(
     1 cnt = i4
     1 qual[*]
       2 appl_id = vc
   )
   SET dm_err->eproc = "Getting a distinct list of appl ids attached to a replicate runner..."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT DISTINCT INTO "nl:"
    di.info_name
    FROM dm2_admin_dm_info di
    WHERE di.info_domain IN ("RR_RUNNER*", "RR_MAIN*")
    HEAD REPORT
     drcdir_applx = 0
    DETAIL
     drcdir_applx = (drcdir_applx+ 1)
     IF (mod(drcdir_applx,10)=1)
      stat = alterlist(drcdir_appl_rs->qual,(drcdir_applx+ 9))
     ENDIF
     drcdir_appl_rs->qual[drcdir_applx].appl_id = trim(di.info_name,3)
    FOOT REPORT
     drcdir_appl_rs->cnt = drcdir_applx, stat = alterlist(drcdir_appl_rs->qual,drcdir_applx)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((drcdir_appl_rs->cnt > 0))
    SET drcdir_applx = 1
    WHILE ((drcdir_applx <= drcdir_appl_rs->cnt))
     CASE (dm2_get_appl_status(value(drcdir_appl_rs->qual[drcdir_applx].appl_id)))
      OF "I":
       IF ((dm_err->debug_flag > 1))
        CALL echo(concat("Application Id ",drcdir_appl_rs->qual[drcdir_applx].appl_id,
          " is not active."))
       ENDIF
       DELETE  FROM dm2_admin_dm_info di
        WHERE di.info_domain IN ("RR_RUNNER*", "RR_MAIN*")
         AND (di.info_name=drcdir_appl_rs->qual[drcdir_applx].appl_id)
        WITH nocounter
       ;end delete
       IF (check_error("Removing Admin dm_info runner row(s) - appl id no longer active.")=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ELSE
        COMMIT
       ENDIF
      OF "A":
       IF ((dm_err->debug_flag > 1))
        CALL echo(concat("Application Id ",drcdir_appl_rs->qual[drcdir_applx].appl_id," is active."))
       ENDIF
      OF "E":
       IF ((dm_err->debug_flag > 1))
        CALL echo("Error Detected in dm2_get_appl_status")
       ENDIF
       RETURN(0)
     ENDCASE
     SET drcdir_applx = (drcdir_applx+ 1)
    ENDWHILE
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo("********** No Application Ids Detected **********")
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_rr_remove_runner_row(drrrr_runner_identifier,drrrr_appl_id)
   DECLARE drrrr_err_ind = i2 WITH protect, noconstant(0)
   DECLARE drrrr_emsg = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE drrrr_eproc = vc WITH protect, noconstant("DM2NOTSET")
   SET drrrr_err_ind = dm_err->err_ind
   SET drrrr_emsg = dm_err->emsg
   SET drrrr_eproc = dm_err->eproc
   SET dm_err->err_ind = 0
   SET dm_err->emsg = ""
   SET dm_err->eproc = ""
   SET dm_err->eproc = concat("Remove Admin DM_INFO runner row for ",trim(drrrr_runner_identifier,3),
    " and appl id ",trim(drrrr_appl_id,3))
   CALL disp_msg(" ",dm_err->logfile,0)
   DELETE  FROM dm2_admin_dm_info di
    WHERE di.info_domain=drrrr_runner_identifier
     AND di.info_name=drrrr_appl_id
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ELSE
    COMMIT
   ENDIF
   SET dm_err->err_ind = drrrr_err_ind
   SET dm_err->emsg = drrrr_emsg
   SET dm_err->eproc = drrrr_eproc
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_rr_maintain_runners(drmr_user,drmr_pword,drmr_cnnct_str,drmr_runners,
  drmr_runner_identifier)
   DECLARE drmr_active_runners = i2 WITH protect, noconstant(0)
   DECLARE drmr_stopping_runners = i2 WITH protect, noconstant(0)
   DECLARE drmr_total_runners = i2 WITH protect, noconstant(0)
   DECLARE drmr_num_runners_to_start = i2 WITH protect, noconstant(0)
   IF (drr_rr_cleanup_dm_info_runners(null)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    SET dm_err->eproc = concat(trim(cnvtstring(drmr_runners))," runner(s) should be running.")
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SET dm_err->eproc = "Determining how many background runners are running..."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm2_admin_dm_info di
    WHERE di.info_domain=drmr_runner_identifier
    DETAIL
     IF (di.info_number=1)
      drmr_active_runners = (drmr_active_runners+ 1)
     ELSE
      drmr_stopping_runners = (drmr_stopping_runners+ 1)
     ENDIF
     drmr_total_runners = (drmr_total_runners+ 1)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echo(concat("Total Runners:    ",trim(cnvtstring(drmr_total_runners))))
    CALL echo(concat("Active Runners:   ",trim(cnvtstring(drmr_active_runners))))
    CALL echo(concat("Stopping Runners: ",trim(cnvtstring(drmr_stopping_runners))))
   ENDIF
   IF (drmr_stopping_runners > 0)
    SET dm_err->eproc = "Validating status of replicate background runners."
    SET dm_err->emsg = "Background runners have been marked to stop, exiting process."
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (drmr_total_runners=drmr_runners)
    IF ((dm_err->debug_flag > 0))
     SET dm_err->eproc = "Currently running the specified number of runners..."
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    RETURN(1)
   ENDIF
   IF (drmr_total_runners < drmr_runners)
    SET drmr_num_runners_to_start = (drmr_runners - drmr_total_runners)
    IF ((dm_err->debug_flag > 0))
     SET dm_err->eproc = concat("Need to start ",trim(cnvtstring(drmr_num_runners_to_start)),
      " runner(s)...")
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    IF (drr_rr_start_runners(drmr_num_runners_to_start,drmr_user,drmr_pword,drmr_cnnct_str,
     drmr_runner_identifier)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_rr_start_runners(drstr_num_runners,drstr_user,drstr_pword,drstr_cnnct_str,
  drstr_identifier)
   DECLARE drstr_connect_string = vc WITH protect, noconstant(" ")
   DECLARE drstr_file_name = vc WITH protect, noconstant(" ")
   DECLARE drstr_logfile_name = vc WITH protect, noconstant(" ")
   DECLARE drstr_exec_cmd = vc WITH protect, noconstant(" ")
   DECLARE drstr_chmod_cmd = vc WITH protect, noconstant(" ")
   DECLARE drstr_loop_cnt = i2 WITH protect, noconstant(0)
   DECLARE drstr_debug_flag = vc WITH protect, noconstant("0")
   DECLARE drstr_stat = i4 WITH protect, noconstant(0)
   DECLARE drstr_logfile_ident = vc WITH protect, noconstant(" ")
   DECLARE drstr_name = vc WITH protect, noconstant(" ")
   IF (drstr_num_runners <= 0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid input number for subroutine drr_rr_start_runners"
    SET dm_err->eproc = "Validating input number - number of runners to start."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (((drstr_user=" ") OR (((drstr_pword=" ") OR (drstr_identifier=" ")) )) )
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid input for subroutine drr_start_runners"
    SET dm_err->eproc = "Validating input passed into subroutine."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (drstr_cnnct_str > " "
    AND drstr_cnnct_str != "NONE")
    SET drstr_connect_string = build("'",drstr_user,"/",drstr_pword,"@",
     drstr_cnnct_str,"'")
   ELSE
    SET drstr_connect_string = build("'",drstr_user,"/",drstr_pword,"'")
   ENDIF
   CALL echo(concat("connect string = ",drstr_connect_string))
   SET drstr_debug_flag = cnvtstring(dm_err->debug_flag)
   FOR (drstr_loop_cnt = 1 TO drstr_num_runners)
     IF (findstring("ccluserdir",drrr_misc_data->active_dir,1,1) > 0)
      SET drstr_name = "dm2_rrr_bckgrnd_"
     ELSE
      SET drstr_name = "dm2_rrr_background_"
     ENDIF
     IF (get_unique_file(drstr_name,".ksh")=0)
      RETURN(0)
     ENDIF
     SET drstr_logfile_name = replace(dm_err->unique_fname,".ksh",".log",0)
     SET drstr_logfile_ident = replace(dm_err->unique_fname,drstr_name,"",0)
     SET drstr_logfile_ident = build("'",trim(replace(drstr_logfile_ident,".log","",0),3),"'")
     SET drstr_file_name = dm_err->unique_fname
     SET drstr_logfile_name = build(drrr_misc_data->active_dir,drstr_logfile_name)
     SET dm_err->eproc = concat("Creating job (",drstr_file_name,") to execute background runner.")
     SELECT INTO trim(drstr_file_name)
      DETAIL
       col 0, "#!/usr/bin/ksh", row + 1,
       col 0, "# Executing Replicate/Refresh Background Runner...", row + 1,
       col 0, "#", row + 1,
       col 0, ". $cer_mgr/",
       CALL print(trim(cnvtlower(logical("environment")))),
       "_environment.ksh", row + 1, col 0,
       "ccl <<!", row + 1, col 0,
       "free define oraclesystem go", row + 1, col 0,
       "define oraclesystem ", drstr_connect_string, " go",
       row + 1, col 0, "set dm2_debug_flag = ",
       drstr_debug_flag, " go", row + 1,
       col 0, "set dm2_rrr_log_identifier = ", drstr_logfile_ident,
       " go", row + 1, col 0,
       "dm2_background_runner '", drstr_user, "', '",
       drstr_pword, "', '", drstr_cnnct_str,
       "', '", drstr_identifier, "' go",
       row + 1, col 0, "exit",
       row + 1, col 0, "!",
       row + 1, col 0, "sleep 30"
      WITH nocounter, maxrow = 1, format = variable,
       formfeed = none
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET drstr_chmod_cmd = concat("chmod 777 $CCLUSERDIR/",drstr_file_name)
     IF ((dm_err->debug_flag > 0))
      SET dm_err->eproc = concat("drr_rr_start_runners changing permissions for ",drstr_file_name,"."
       )
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     IF (dm2_push_dcl(drstr_chmod_cmd)=0)
      RETURN(0)
     ENDIF
     SET drstr_exec_cmd = concat("nohup ","$CCLUSERDIR/",drstr_file_name," > ",drstr_logfile_name,
      " 2>&1 &")
     CALL echo(concat("exec_cmd = ",drstr_exec_cmd))
     SET dm_err->eproc = concat("Executing ",trim(drstr_file_name)," - results will be logged to ",
      trim(drstr_logfile_name),".")
     CALL disp_msg(" ",dm_err->logfile,0)
     CALL dcl(drstr_exec_cmd,size(drstr_exec_cmd),drstr_stat)
     IF (drstr_stat=0)
      IF (parse_errfile(drstr_logfile_name)=0)
       RETURN(0)
      ENDIF
      SET dm_err->disp_msg_emsg = dm_err->errtext
      SET dm_err->emsg = dm_err->disp_msg_emsg
      SET dm_err->eproc = concat("dm2_push_dcl executing: ",drstr_exec_cmd)
      SET dm_err->err_ind = 1
      CALL disp_msg("dm_err->disp_msg_emsg",dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET drstr_exec_cmd = concat("ps -ef | grep ",drstr_file_name," | grep -v grep")
     SET dm_err->disp_dcl_err_ind = 0
     IF (dm2_push_dcl(drstr_exec_cmd)=0)
      IF ((dm_err->err_ind=1))
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
     IF (parse_errfile(dm_err->errfile)=0)
      RETURN(0)
     ENDIF
     IF (findstring(drstr_file_name,dm_err->errtext)=0)
      SET dm_err->disp_msg_emsg = "Unable to locate process for this job."
      SET dm_err->emsg = dm_err->disp_msg_emsg
      SET dm_err->eproc = concat("Validating ",trim(drstr_file_name)," was successfully executed.")
      SET dm_err->err_ind = 1
      CALL disp_msg("dm_err->disp_msg_emsg",dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF ((dm_err->debug_flag < 3))
      IF (remove(drstr_file_name)=0)
       SET dm_err->err_ind = 1
       SET dm_err->emsg = concat("Could not remove ",drstr_file_name," from ccluserdir.")
       SET dm_err->eproc = "Removing replicate/refresh background ksh file from ccluserdir."
       CALL disp_msg((dm_err - emsg),dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_cleanup_adm_dm_info_runners(dcadir_dblink)
   DECLARE dcadir_dm_info_fnd_ind = i2 WITH protect, noconstant(0)
   DECLARE dcadir_applx = i4 WITH protect, noconstant(0)
   DECLARE dcadir_appl_status = vc WITH protect, noconstant("")
   RECORD dcadir_appl_rs(
     1 cnt = i4
     1 qual[*]
       2 appl_id = vc
   )
   SET dm_err->eproc = "Getting a distinct list of admin appl ids attached to a runner."
   IF ((dm_err->debug_flag > 1))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT DISTINCT INTO "nl:"
    di.info_name
    FROM (value(concat("DM_INFO@",dcadir_dblink)) di)
    WHERE di.info_domain IN ("DM2_ADMIN_RUNNER")
    HEAD REPORT
     dcadir_applx = 0
    DETAIL
     dcadir_applx = (dcadir_applx+ 1)
     IF (mod(dcadir_applx,10)=1)
      stat = alterlist(dcadir_appl_rs->qual,(dcadir_applx+ 9))
     ENDIF
     dcadir_appl_rs->qual[dcadir_applx].appl_id = trim(di.info_name,3)
    FOOT REPORT
     dcadir_appl_rs->cnt = dcadir_applx, stat = alterlist(dcadir_appl_rs->qual,dcadir_applx)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dcadir_appl_rs->cnt > 0))
    SET dcadir_applx = 1
    WHILE ((dcadir_applx <= dcadir_appl_rs->cnt))
      IF (dir_get_adm_appl_status(dcadir_dblink,value(dcadir_appl_rs->qual[dcadir_applx].appl_id),
       dcadir_appl_status)=0)
       RETURN(0)
      ENDIF
      CASE (dcadir_appl_status)
       OF "INACTIVE":
        IF ((dm_err->debug_flag > 1))
         CALL echo(concat("Admin Application Id is",dcadir_appl_rs->qual[dcadir_applx].appl_id,
           " is not active."))
        ENDIF
        SET dm_err->eproc = "Removing dm_info runner row(s) - admin appl id no longer active.."
        IF ((dm_err->debug_flag > 1))
         CALL disp_msg(" ",dm_err->logfile,0)
        ENDIF
        DELETE  FROM (value(concat("DM_INFO@",dcadir_dblink)) di)
         WHERE di.info_domain IN ("DM2_ADMIN_RUNNER")
          AND (di.info_name=dcadir_appl_rs->qual[dcadir_applx].appl_id)
         WITH nocounter
        ;end delete
        IF (check_error(dm_err->eproc)=1)
         ROLLBACK
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ELSE
         COMMIT
        ENDIF
       OF "ACTIVE":
        IF ((dm_err->debug_flag > 1))
         CALL echo(concat("Admin Application Id is",dcadir_appl_rs->qual[dcadir_applx].appl_id,
           " is active."))
        ENDIF
      ENDCASE
      SET dcadir_applx = (dcadir_applx+ 1)
    ENDWHILE
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo("********** No Application Ids Detected **********")
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_chk_active_runners(dcar_dblink,dcar_count_ind)
   SET dcar_count_ind = 0
   IF (drr_cleanup_dm_info_runners(null)=0)
    RETURN(0)
   ENDIF
   IF (drr_cleanup_adm_dm_info_runners(dcar_dblink)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Check for active background runners"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain IN ("DM2_SCHEMA_RUNNER", "DM2_README_RUNNER")
    WITH nocounter, maxqual(di,1)
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dcar_count_ind = 1
   ELSE
    SET dm_err->eproc = "Check for active admin background runners"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (value(concat("DM_INFO@",dcar_dblink)) di)
     WHERE di.info_domain IN ("DM2_ADMIN_RUNNER")
     WITH nocounter, maxqual(di,1)
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF (curqual > 0)
     SET dcar_count_ind = 1
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE dgcc_log_id = f8 WITH protect, noconstant(0.0)
 DECLARE dgcc_err_ind = i2 WITH protect, noconstant(0)
 DECLARE dgcc_table_loop = i4 WITH protect, noconstant(0)
 DECLARE dgcc_index_loop = i4 WITH protect, noconstant(0)
 DECLARE dgcc_table_cnt = i4 WITH protect, noconstant(0)
 DECLARE dgcc_last_run_dt_tm = dq8 WITH protect, noconstant(0.0)
 DECLARE dgcc_current_run_dt_tm = dq8 WITH protect, noconstant(0.0)
 FREE RECORD dgcc_tables
 RECORD dgcc_tables(
   1 tables[*]
     2 table_name = vc
     2 indexes[*]
       3 index_name = vc
       3 has_dpq_row_ind = i2
 )
 IF (check_logfile("dm2_gen_coal_cmds",".log","dm2_gen_coalesce_cmds")=0)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Beginning dm2_gen_coalesce_cmds"
 CALL disp_msg("",dm_err->logfile,0)
 SET dm2_process_rs->process_name = dpl_coalesce
 SET dm2_process_event_rs->status = dpl_executing
 IF (dm2_process_log_row(dpl_coalesce,dpl_execution,dpl_no_prev_id,1)=0)
  GO TO exit_program
 ENDIF
 SET dgcc_log_id = dm2_process_event_rs->dm_process_event_id
 SET dm_err->eproc = "Looking for persistant date/time of last run"
 CALL disp_msg("",dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DM2_PERSIST_LAST_ANALYZED"
   AND di.info_name="DM2_GEN_COALESCE_CMDS LAST RUN"
  DETAIL
   dgcc_last_run_dt_tm = di.info_date
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ELSEIF (curqual=0)
  SET dm_err->eproc = "Creating last run date/time row for the current date"
  CALL disp_msg("",dm_err->logfile,0)
  SET dgcc_last_run_dt_tm = cnvtdatetime(curdate,curtime3)
  INSERT  FROM dm_info di
   SET di.info_domain = "DM2_PERSIST_LAST_ANALYZED", di.info_name = "DM2_GEN_COALESCE_CMDS LAST RUN",
    di.info_date = cnvtdatetime(dgcc_last_run_dt_tm),
    di.updt_task = reqinfo->updt_task, di.updt_id = reqinfo->updt_id, di.updt_applctx = reqinfo->
    updt_applctx,
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
 ENDIF
 SET dgcc_current_run_dt_tm = cnvtdatetime(curdate,curtime3)
 SET dm_err->eproc = "Building list of tables whose statistics have been gathered"
 CALL disp_msg("",dm_err->logfile,0)
 SELECT INTO "nl:"
  dped2.detail_text
  FROM dm_process_event dpe,
   dm_process_event_dtl dped,
   dm_process_event_dtl dped2
  PLAN (dpe
   WHERE (dpe.dm_process_id=
   (SELECT
    dp.dm_process_id
    FROM dm_process dp
    WHERE dp.action_type="GATHER TABLE STATS"))
    AND dpe.event_status="SUCCESS"
    AND dpe.end_dt_tm > cnvtdatetime(dgcc_last_run_dt_tm))
   JOIN (dped
   WHERE dped.dm_process_event_id=dpe.dm_process_event_id
    AND dped.detail_type="OWNER"
    AND dped.detail_text="V500")
   JOIN (dped2
   WHERE dped2.dm_process_event_id=dpe.dm_process_event_id
    AND dped2.detail_type="TABLE"
    AND dped2.detail_text != patstring("*$R"))
  ORDER BY dped2.detail_text
  HEAD dped2.detail_text
   dgcc_table_cnt = (dgcc_table_cnt+ 1)
   IF (mod(dgcc_table_cnt,50)=1)
    stat = alterlist(dgcc_tables->tables,(dgcc_table_cnt+ 49))
   ENDIF
   dgcc_tables->tables[dgcc_table_cnt].table_name = dped2.detail_text
  FOOT REPORT
   stat = alterlist(dgcc_tables->tables,dgcc_table_cnt)
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (dgcc_table_cnt > 0)
  SET dm_err->eproc = "Building list of indexes for coalescing"
  CALL disp_msg("",dm_err->logfile,0)
  SELECT INTO "nl:"
   FROM user_indexes ui,
    (dummyt d  WITH seq = value(dgcc_table_cnt))
   PLAN (d)
    JOIN (ui
    WHERE (ui.table_name=dgcc_tables->tables[d.seq].table_name)
     AND ui.index_type="NORMAL")
   ORDER BY d.seq
   HEAD REPORT
    cclrpt_indexcnt = 0
   HEAD d.seq
    cclrpt_indexcnt = 0
   DETAIL
    cclrpt_indexcnt = (cclrpt_indexcnt+ 1), stat = alterlist(dgcc_tables->tables[d.seq].indexes,
     cclrpt_indexcnt), dgcc_tables->tables[d.seq].indexes[cclrpt_indexcnt].index_name = ui.index_name
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_program
  ENDIF
  SELECT INTO "nl:"
   dpq.object_name
   FROM dm_process_queue dpq
   PLAN (dpq
    WHERE dpq.op_type=dpq_coalesce
     AND dpq.process_type=dpq_index_coalesce
     AND dpq.owner_name="V500"
     AND dpq.object_type=dpq_index
     AND dpq.op_method=dpq_db)
   HEAD REPORT
    cclrpt_lvalidx = 0, cclrpt_tableloop = 0, cclrpt_indexidx = 0
   DETAIL
    FOR (cclrpt_tableloop = 1 TO dgcc_table_cnt)
     cclrpt_indexidx = locateval(cclrpt_lvalidx,1,size(dgcc_tables->tables[cclrpt_tableloop].indexes,
       5),dpq.object_name,dgcc_tables->tables[cclrpt_tableloop].indexes[cclrpt_lvalidx].index_name),
     IF (cclrpt_indexidx > 0)
      dgcc_tables->tables[cclrpt_tableloop].indexes[cclrpt_lvalidx].has_dpq_row_ind = 1,
      cclrpt_tableloop = (dgcc_table_cnt+ 1)
     ENDIF
    ENDFOR
   WITH nocounter
  ;end select
  FOR (dgcc_table_loop = 1 TO dgcc_table_cnt)
    FOR (dgcc_index_loop = 1 TO size(dgcc_tables->tables[dgcc_table_loop].indexes,5))
      IF ((dgcc_tables->tables[dgcc_table_loop].indexes[dgcc_index_loop].has_dpq_row_ind=0))
       SET dpq_process_queue->process_type = dpq_index_coalesce
       SET dpq_process_queue->op_type = dpq_coalesce
       SET dpq_process_queue->owner_name = "V500"
       SET dpq_process_queue->object_type = dpq_index
       SET dpq_process_queue->op_method = dpq_db
       SET dpq_process_queue->object_name = dgcc_tables->tables[dgcc_table_loop].indexes[
       dgcc_index_loop].index_name
       SET dpq_process_queue->operation_txt = concat("EXECUTE DAC_COALESCE_INDEX '",dgcc_tables->
        tables[dgcc_table_loop].indexes[dgcc_index_loop].index_name,"' GO")
       SET dpq_process_queue->priority = 400
       SET dpq_process_queue->routine_tasks_ind = 1
       IF (dpq_process_queue_row(null)=0)
        GO TO exit_program
       ENDIF
      ENDIF
    ENDFOR
  ENDFOR
 ENDIF
 SET dm_err->eproc = "Updating persistant run date/time"
 CALL disp_msg("",dm_err->logfile,0)
 UPDATE  FROM dm_info di
  SET di.info_date = cnvtdatetime(dgcc_current_run_dt_tm), di.updt_dt_tm = cnvtdatetime(curdate,
    curtime3), di.updt_task = reqinfo->updt_task,
   di.updt_id = reqinfo->updt_id, di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = (di.updt_cnt
   + 1)
  WHERE di.info_domain="DM2_PERSIST_LAST_ANALYZED"
   AND di.info_name="DM2_GEN_COALESCE_CMDS LAST RUN"
  WITH nocounter
 ;end update
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
#exit_program
 FREE RECORD dgcc_tables
 SET dm2_process_event_rs->status = evaluate(dm_err->err_ind,1,dpl_failure,dpl_success)
 SET dm2_process_event_rs->message = evaluate(dm_err->err_ind,1,dm_err->emsg,"")
 SET dgcc_err_ind = dm_err->err_ind
 SET dm_err->err_ind = 0
 CALL dm2_process_log_row(dpl_notnull_validate,dpl_execution,dgcc_log_id,1)
 SET dm2_process_rs->process_name = ""
 SET dm_err->err_ind = dgcc_err_ind
 SET dm_err->eproc = "Ending dm2_gen_coalesce_cmds"
 CALL final_disp_msg("dm2_gen_coalesce_cmds")
END GO
