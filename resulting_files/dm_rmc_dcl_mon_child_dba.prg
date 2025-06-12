CREATE PROGRAM dm_rmc_dcl_mon_child:dba
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
 DECLARE parse_contexts(pc_context_str=vc,pc_delim=vc,pc_context_rs=vc(ref)) = i4
 SUBROUTINE parse_contexts(pc_context_str,pc_delim,pc_context_rs)
   DECLARE pc_delim_len = i4
   DECLARE pc_str_len = i4
   DECLARE pc_start = i4
   DECLARE pc_pos = i4
   DECLARE pc_num_found = i4
   SET pc_delim_len = size(pc_delim)
   SET pc_str_len = size(pc_context_str)
   SET pc_start = 1
   SET pc_pos = findstring(pc_delim,pc_context_str,pc_start)
   SET pc_num_found = 0
   WHILE (pc_pos > 0)
     SET pc_num_found = (pc_num_found+ 1)
     SET stat = alterlist(pc_context_rs->qual,pc_num_found)
     SET pc_context_rs->qual[pc_num_found].values = substring(pc_start,(pc_pos - pc_start),
      pc_context_str)
     SET pc_start = (pc_pos+ pc_delim_len)
     SET pc_pos = findstring(pc_delim,pc_context_str,pc_start)
   ENDWHILE
   IF (pc_start <= pc_str_len)
    SET pc_num_found = (pc_num_found+ 1)
    SET stat = alterlist(pc_context_rs->qual,pc_num_found)
    SET pc_context_rs->qual[pc_num_found].values = substring(pc_start,((pc_str_len - pc_start)+ 1),
     pc_context_str)
   ENDIF
   RETURN(pc_num_found)
 END ;Subroutine
 DECLARE drdc_wrap_menu_lines(dwml_str=vc,dwml_cur_row_pos=i4,dwml_cur_col_pos=i4,
  dwml_multi_line_buffer=vc,dwml_max_lines=i4,
  dwml_max_col=i4) = i4
 DECLARE drdc_get_name(dgn_name=vc,dgn_file=vc) = vc
 DECLARE drdc_file_success(dfs_name=vc,dfs_file_name=vc,dfs_error_ind=i2) = null
 IF ((validate(dclm_rs->cur_id,- (123.0))=- (123.0)))
  FREE RECORD dclm_rs
  RECORD dclm_rs(
    1 cur_id = f8
    1 cur_name = vc
    1 src_id = f8
    1 src_name = vc
    1 oe_name = vc
    1 db_link = vc
    1 refresh_time = vc
    1 cur_tier = i4
    1 del_row_ind = i2
    1 max_tier = i4
    1 num_procs = i4
    1 nomv_ind = i2
    1 mover_stale_ind = i2
    1 cycle_time = vc
    1 cur_rs_pos = i4
    1 max_lines = i4
    1 no_qual_msg = vc
    1 ctp_str = vc
    1 cts_str = vc
    1 group_ind = i2
    1 cnt = i4
    1 qual[*]
      2 table_name = vc
      2 log_type = vc
      2 row_cnt = i4
      2 context_name = vc
      2 nomv_ind = i2
    1 reporting_cnt = i4
    1 reporting_qual[*]
      2 log_type = vc
    1 context_cnt = i4
    1 context_qual[*]
      2 values = vc
    1 audit_cnt = i4
    1 audit_qual[*]
      2 log_type = vc
    1 non_ctxt_cnt = i4
    1 non_ctxt_qual[*]
      2 values = vc
  )
 ENDIF
 IF ((validate(dclm_all->cur_id,- (123.0))=- (123.0)))
  FREE RECORD dclm_all
  RECORD dclm_all(
    1 cur_id = f8
    1 cur_name = vc
    1 src_id = f8
    1 src_name = vc
    1 oe_name = vc
    1 db_link = vc
    1 refresh_time = vc
    1 cur_rs_pos = i4
    1 max_lines = i4
    1 no_qual_msg = vc
    1 cnt = i4
    1 qual[*]
      2 table_name = vc
      2 log_type = vc
      2 row_cnt = i4
      2 context_name = vc
      2 nomv_ind = i2
    1 audit_cnt = i4
    1 audit_qual[*]
      2 log_type = vc
    1 type_cnt = i4
    1 lt_qual[*]
      2 log_type = vc
      2 lt_cnt = i4
  )
 ENDIF
 IF ((validate(dclm_issues->cur_id,- (123.0))=- (123.0)))
  FREE RECORD dclm_issues
  RECORD dclm_issues(
    1 cur_id = f8
    1 cur_name = vc
    1 src_id = f8
    1 src_name = vc
    1 oe_name = vc
    1 db_link = vc
    1 refresh_time = vc
    1 max_lines = i4
    1 cur_rs_pos = i4
    1 ctp_str = vc
    1 sort_flag = i4
    1 cur_flag = i4
    1 context_cnt = i4
    1 context_qual[*]
      2 values = vc
    1 lt_cnt = i4
    1 lt_qual[*]
      2 log_type = vc
      2 inv_ind = i2
      2 log_msg = vc
      2 child_type = vc
      2 log_type_sum = i4
      2 child_cnt_sum = i4
      2 tab_cnt = i4
      2 tab_qual[*]
        3 table_name = vc
        3 row_cnt = i4
  )
 ENDIF
 SUBROUTINE drdc_wrap_menu_lines(dwml_str,dwml_cur_row_pos,dwml_cur_col_pos,dwml_multi_line_buffer,
  dwml_max_lines,dwml_max_col)
   DECLARE dwml_temp_str = vc WITH protect, noconstant("")
   DECLARE dwml_done_ind = i2 WITH protect, noconstant(0)
   DECLARE dwml_partial_str = vc WITH protect, noconstant("")
   DECLARE dwml_stop_pos = i4 WITH protect, noconstant(0)
   DECLARE dwml_line_cnt = i4 WITH protect, noconstant(0)
   DECLARE dwml_max_val = i4 WITH protect, noconstant(0)
   SET dwml_max_val = dwml_max_col
   IF (dwml_max_val=0)
    SET dwml_max_val = 132
   ENDIF
   SET dwml_temp_str = dwml_str
   SET dwml_done_ind = 0
   WHILE (dwml_done_ind=0)
     IF (size(dwml_temp_str) < dwml_max_val)
      SET dwml_partial_str = dwml_temp_str
      SET dwml_done_ind = 1
     ELSE
      SET dwml_partial_str = substring(1,value(dwml_max_val),dwml_temp_str)
      SET dwml_stop_pos = findstring(" ",dwml_partial_str,1,1)
      IF (dwml_stop_pos=0)
       SET dwml_stop_pos = dwml_max_val
      ENDIF
      SET dwml_partial_str = substring(1,dwml_stop_pos,dwml_temp_str)
      IF (dwml_multi_line_buffer >= " ")
       SET dwml_temp_str = concat(dwml_multi_line_buffer,substring((dwml_stop_pos+ 1),(size(
          dwml_temp_str) - dwml_stop_pos),dwml_temp_str))
      ELSE
       SET dwml_temp_str = substring((dwml_stop_pos+ 1),(size(dwml_temp_str) - dwml_stop_pos),
        dwml_temp_str)
      ENDIF
     ENDIF
     IF (((dwml_line_cnt+ 1)=dwml_max_lines)
      AND dwml_done_ind=0
      AND dwml_max_lines > 0)
      SET dwml_partial_str = concat(substring(1,(dwml_max_val - 3),dwml_partial_str),"...")
      SET dwml_done_ind = 1
     ENDIF
     CALL text(dwml_cur_row_pos,dwml_cur_col_pos,dwml_partial_str)
     SET dwml_cur_row_pos = (dwml_cur_row_pos+ 1)
     SET dwml_line_cnt = (dwml_line_cnt+ 1)
   ENDWHILE
   RETURN(dwml_cur_row_pos)
 END ;Subroutine
 SUBROUTINE drdc_get_name(dgn_name,dgn_file)
   SET dm_err->eproc = "Getting report file name"
   DECLARE dgn_file_name = vc WITH protect, noconstant("")
   DECLARE dgn_done_ind = i2 WITH protect, noconstant(0)
   DECLARE dgn_title = vc WITH protect, noconstant("")
   SET dgn_title = concat("*** ",dgn_name," ***")
   WHILE (dgn_done_ind=0)
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,4,132)
     CALL text(3,(66 - ceil((size(dgn_title)/ 2))),dgn_title)
     CALL text(6,3,concat("Please enter a file name for the ",dgn_name,
       " report to extract into. (0 to exit): "))
     CALL accept(7,15,"P(30);CU",value(dgn_file))
     SET dgn_file_name = curaccept
     SET dgn_file_name = cnvtlower(dgn_file_name)
     IF (dgn_file_name="0")
      RETURN("-1")
      CALL text(20,3,"No extract will be made")
      CALL pause(3)
      SET dgn_done_ind = 1
     ENDIF
     IF (findstring(".",dgn_file_name)=0)
      SET dgn_file_name = concat(dgn_file_name,".csv")
      SET dgn_done_ind = 1
     ENDIF
     IF (substring(findstring(".",dgn_file_name),size(dgn_file_name,1),dgn_file_name) != ".csv")
      CALL text(20,3,"Invalid file type, file extension must be .csv")
      CALL pause(3)
     ELSE
      SET dgn_done_ind = 1
     ENDIF
   ENDWHILE
   RETURN(dgn_file_name)
 END ;Subroutine
 SUBROUTINE drdc_file_success(dfs_name,dfs_file_name,dfs_error_ind)
   DECLARE dfs_title = vc WITH protect, noconstant("")
   DECLARE dfs_pos = i4 WITH protect, noconstant(0)
   SET dfs_title = concat("*** ",dfs_name," ***")
   IF (dfs_error_ind=0)
    CALL clear(1,1)
    SET width = 132
    CALL box(1,1,4,132)
    CALL text(3,(66 - ceil((size(dfs_title)/ 2))),dfs_title)
    CALL text(6,3,"Report complete!")
    CALL text(7,3,
     "For optimal viewing, the following file needs to be moved from CCLUSERDIR to a PC:")
    CALL text(8,3,"-----------------------------")
    CALL text(9,3,dfs_file_name)
    CALL text(10,3,"-----------------------------")
    CALL text(12,3,"Press enter to return:")
    CALL accept(12,26,"X;CUS","E")
   ELSE
    CALL clear(1,1)
    SET width = 132
    CALL box(1,1,4,132)
    CALL text(3,(66 - ceil((size(dfs_title)/ 2))),dfs_title)
    CALL text(6,3,"Report was not successful.  The following error occurred!")
    SET dfs_pos = drdc_wrap_menu_lines(dm_err->emsg,7,3,"   ",0,
     120)
    CALL text((dfs_pos+ 1),3,"Press enter to return:")
    CALL accept((dfs_pos+ 1),26,"X;CUS","E")
   ENDIF
   RETURN(null)
 END ;Subroutine
 DECLARE dclmc_ctxt_loop = i4 WITH protect, noconstant(0)
 DECLARE dclmc_done_ind = i2 WITH protect, noconstant(0)
 DECLARE dclmc_loop1 = i4 WITH protect, noconstant(0)
 DECLARE dclmc_loop2 = i4 WITH protect, noconstant(0)
 DECLARE dclmc_sort_ind = i2 WITH protect, noconstant(0)
 DECLARE dclmc_cntx_str = vc WITH protect, noconstant("")
 DECLARE dclmc_tier_str = vc WITH protect, noconstant("")
 DECLARE dclmc_all_found_ind = i2 WITH protect, noconstant(0)
 DECLARE dclmc_del_qual = i4 WITH protect, noconstant(0)
 DECLARE dclmc_del_cnt = i4 WITH protect, noconstant(0)
 DECLARE dclmc_del_query_ind = i2 WITH protect, noconstant(0)
 DECLARE dclmc_cnxt_str = vc WITH protect, noconstant("")
 IF ((validate(dclmc_menu_ind,- (1))=- (1)))
  DECLARE dclmc_menu_ind = i2 WITH protect, noconstant(0)
 ENDIF
 DECLARE dclmc_set_tier_str(sts_tier=i4) = vc
 FREE RECORD dclmc_parse
 RECORD dclmc_parse(
   1 stmt[*]
     2 str = vc
 )
 FREE RECORD dclm_contexts
 RECORD dclm_contexts(
   1 cnt = i4
   1 qual[*]
     2 values = vc
 )
 SET dm_err->eproc = "Starting dm_rmc_dcl_mon_child"
 IF (check_logfile("dm_rmc_dcl_mon",".log","DM_RMC_DCL_MON LOG")=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to Create Log File"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_mon_child
 ENDIF
 SET stat = alterlist(dclmc_parse->stmt,15)
 IF ((dclm_rs->cur_id=0.0))
  SET dm_err->eproc = "Getting current environment_id."
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="DATA MANAGEMENT"
    AND di.info_name="DM_ENV_ID"
   DETAIL
    dclm_rs->cur_id = di.info_number
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_mon_child
  ENDIF
  IF (curqual=0)
   SET dm_err->err_ind = 1
   SET dm_err->emsg = "No local environment_id set.  Please use DM_SET_ENV_ID to set one."
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_mon_child
  ENDIF
 ENDIF
 IF ((dclm_rs->src_id=0.0))
  SET dm_err->eproc = "Getting environment_id of open event."
  SELECT INTO "NL:"
   FROM dm_rdds_event_log d
   WHERE (d.cur_environment_id=dclm_rs->cur_id)
    AND d.rdds_event_key="BEGINREFERENCEDATASYNC"
    AND  NOT (list(d.paired_environment_id,d.event_reason) IN (
   (SELECT
    d1.paired_environment_id, d1.event_reason
    FROM dm_rdds_event_log d1
    WHERE (d1.cur_environment_id=dclm_rs->cur_id)
     AND d1.rdds_event_key="ENDREFERENCEDATASYNC")))
   DETAIL
    dclm_rs->src_id = d.paired_environment_id, dclm_rs->oe_name = concat(trim(d.event_reason),"(",
     format(d.event_dt_tm,"dd-mmm-yy HH:MM:SS;;q"),")")
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_mon_child
  ENDIF
  IF (curqual=0)
   SET dm_err->err_ind = 1
   SET dm_err->emsg = concat("No open event detected for target environment ",dclm_rs->cur_name,
    ". The monitoring report will not run.")
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_mon_child
  ENDIF
 ENDIF
 IF ((((dclm_rs->src_name <= " ")) OR ((dclm_rs->cur_name <= " "))) )
  SET dm_err->eproc = "Getting getting source environment name."
  SELECT INTO "NL:"
   FROM dm_environment d
   WHERE d.environment_id IN (dclm_rs->src_id, dclm_rs->cur_id)
   DETAIL
    IF ((d.environment_id=dclm_rs->cur_id))
     dclm_rs->cur_name = d.environment_name
    ELSE
     dclm_rs->src_name = d.environment_name
    ENDIF
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_mon_child
  ENDIF
 ENDIF
 IF ((dclm_rs->cur_name <= " "))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "No environment_id in DM_ENVIORNMENT.  Please use DM_SET_ENV_ID to set one."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_mon_child
 ELSEIF ((dclm_rs->src_name <= " "))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat("No environment_id in DM_ENVIORNMENT for source environment_id ",trim(
    cnvtstring(dclm_rs->src_id)))
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_mon_child
 ENDIF
 IF ((dclm_rs->db_link <= " "))
  SET dm_err->eproc = "Getting database link to source."
  SELECT INTO "NL:"
   FROM dm_env_reltn d
   WHERE (d.child_env_id=dclm_rs->cur_id)
    AND (d.parent_env_id=dclm_rs->src_id)
    AND d.relationship_type="REFERENCE MERGE"
    AND d.post_link_name > " "
    AND d.post_link_name IS NOT null
   DETAIL
    dclm_rs->db_link = d.post_link_name
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_mon_child
  ENDIF
  IF (curqual=0)
   SET dm_err->err_ind = 1
   SET dm_err->emsg = concat("No database link found to the source environment ",dclm_rs->src_name,
    ". The monitoring report will not run.")
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_mon_child
  ENDIF
 ENDIF
 IF ((dclm_rs->ctp_str <= " "))
  SET dm_err->eproc = "Getting mover context information."
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="RDDS CONTEXT"
    AND di.info_name IN ("CONTEXTS TO PULL", "CONTEXT TO SET", "CONTEXT GROUP_IND")
   DETAIL
    IF (di.info_name="CONTEXTS TO PULL")
     dclm_rs->ctp_str = trim(di.info_char)
    ELSEIF (di.info_name="CONTEXT TO SET")
     dclm_rs->cts_str = trim(di.info_char)
    ELSE
     dclm_rs->group_ind = di.info_number
    ENDIF
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_mon_child
  ENDIF
  IF (((curqual=0) OR ((dclm_rs->ctp_str <= " "))) )
   SET dm_err->err_ind = 1
   SET dm_err->emsg = "No mover context information found. The monitoring report will not run."
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_mon_child
  ENDIF
 ENDIF
 IF ((dclm_rs->ctp_str >= " ")
  AND (dclm_rs->context_cnt=0))
  SET dm_err->eproc = "Parsing apart contexts to pull."
  SET dclm_contexts->cnt = parse_contexts(dclm_rs->ctp_str,"::",dclm_contexts)
  FOR (dclmc_loop1 = 1 TO dclm_contexts->cnt)
    IF ((dclm_contexts->qual[dclmc_loop1].values="ALL"))
     SET dclmc_all_found_ind = 1
    ENDIF
  ENDFOR
  IF (dclmc_all_found_ind=1)
   SET dclm_contexts->cnt = 1
   SET stat = alterlist(dclm_contexts->qual,1)
   SET dclm_contexts->qual[1].values = "ALL"
  ENDIF
  IF ((dclm_contexts->cnt > 1))
   SET stat = alterlist(dclm_contexts->qual,(dclm_contexts->cnt+ 1))
   FOR (dclmc_loop1 = 1 TO (dclm_contexts->cnt - 1))
     FOR (dclmc_loop2 = 1 TO (dclm_contexts->cnt - 1))
       IF ((dclm_contexts->qual[dclmc_loop2].values > dclm_contexts->qual[(dclmc_loop2+ 1)].values))
        SET dclm_contexts->qual[(dclm_contexts->cnt+ 1)].values = dclm_contexts->qual[dclmc_loop2].
        values
        SET dclm_contexts->qual[dclmc_loop2].values = dclm_contexts->qual[(dclmc_loop2+ 1)].values
        SET dclm_contexts->qual[(dclmc_loop2+ 1)].values = dclm_contexts->qual[(dclm_contexts->cnt+ 1
        )].values
       ENDIF
     ENDFOR
   ENDFOR
  ENDIF
  SET stat = alterlist(dclm_rs->context_qual,dclm_contexts->cnt)
  SET dclm_rs->context_cnt = dclm_contexts->cnt
  FOR (dclm_loop1 = 1 TO dclm_contexts->cnt)
    SET dclm_rs->context_qual[dclm_loop1].values = dclm_contexts->qual[dclm_loop1].values
  ENDFOR
 ENDIF
 IF ((dclm_rs->max_tier=0))
  SET dm_err->eproc = "Getting max tier."
  SELECT INTO "nl:"
   y = max(d.info_number)
   FROM dm_info d
   WHERE d.info_domain="RDDS TIER LIST"
   DETAIL
    dclm_rs->max_tier = y
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_mon_child
  ENDIF
 ENDIF
 IF ((dclm_rs->audit_cnt=0))
  SET dm_err->eproc = "Getting auditable log_types."
  SELECT INTO "NL:"
   FROM dm_info d
   WHERE d.info_domain="RDDS CONFIGURATION:AUDITABLE NOMV"
    AND d.info_number=1
   DETAIL
    dclm_rs->audit_cnt = (dclm_rs->audit_cnt+ 1), stat = alterlist(dclm_rs->audit_qual,dclm_rs->
     audit_cnt), dclm_rs->audit_qual[dclm_rs->audit_cnt].log_type = d.info_name
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_mon_child
  ENDIF
 ENDIF
 IF ((dclm_rs->reporting_cnt=0))
  SET dm_err->eproc = "Getting monitoring log_types."
  SELECT INTO "NL:"
   FROM dm_info d
   WHERE d.info_domain="RDDS CONFIGURATION:DCL MONITOR LOG_TYPE"
   ORDER BY info_number
   DETAIL
    dclm_rs->reporting_cnt = (dclm_rs->reporting_cnt+ 1), stat = alterlist(dclm_rs->reporting_qual,
     dclm_rs->reporting_cnt), dclm_rs->reporting_qual[dclm_rs->reporting_cnt].log_type = d.info_name
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_mon_child
  ENDIF
  IF (curqual=0)
   SET dclm_rs->reporting_cnt = 4
   SET stat = alterlist(dclm_rs->reporting_qual,4)
   SET dclm_rs->reporting_qual[1].log_type = "HOLDNG"
   SET dclm_rs->reporting_qual[2].log_type = "PROCES"
   SET dclm_rs->reporting_qual[3].log_type = "REFCHG"
   SET dclm_rs->reporting_qual[4].log_type = "NORDDS"
  ENDIF
 ENDIF
 IF ((dclm_rs->max_lines=0))
  SET dclm_rs->max_lines = 15
 ENDIF
 IF ((dclm_rs->del_row_ind=1))
  SET dclmc_tier_str = dclmc_set_tier_str(0)
  SET dclmc_del_query_ind = 1
 ELSE
  SET dclmc_tier_str = dclmc_set_tier_str(dclm_rs->cur_tier)
 ENDIF
 SET dclm_rs->cnt = 0
 SET stat = alterlist(dclm_rs->qual,0)
 SET dclm_rs->no_qual_msg = " "
 SET dclm_rs->refresh_time = concat("As of ",format(cnvtdatetime(curdate,curtime3),
   "dd-mmm-yy HH:MM:SS;;q")," (auto refresh in 30 sec)")
 SET dm_err->eproc = "Querying for DCL rows"
 WHILE (dclmc_done_ind=0)
   IF (dclmc_menu_ind=1)
    CALL text(24,1,fillstring(132," "))
    IF ((dclm_rs->cur_tier=0))
     CALL text(24,1,"Gathering DM_CHG_LOG Delete data...")
    ELSEIF ((dclm_rs->cur_tier=999))
     CALL text(24,1,concat("Gathering DM_CHG_LOG non-Delete data. Level ",trim(cnvtstring((dclm_rs->
         max_tier+ 1)))," of ",trim(cnvtstring((dclm_rs->max_tier+ 1))),"..."))
    ELSE
     CALL text(24,1,concat("Gathering DM_CHG_LOG non-Delete data. Level ",trim(cnvtstring(dclm_rs->
         cur_tier))," of ",trim(cnvtstring((dclm_rs->max_tier+ 1))),"..."))
    ENDIF
   ENDIF
   FOR (dclmc_loop1 = 1 TO dclm_rs->reporting_cnt)
     FOR (dclmc_ctxt_loop = 1 TO dclm_rs->context_cnt)
       IF ((dclm_rs->context_qual[dclmc_ctxt_loop].values="ALL"))
        SET dclmc_cnxt_str = " 1 = 1"
       ELSEIF ((dclm_rs->context_qual[dclmc_ctxt_loop].values="NULL"))
        SET dclmc_cnxt_str = " r.context_name is NULL"
       ELSE
        SET dclmc_cnxt_str = concat(" r.context_name = '",dclm_rs->context_qual[dclmc_ctxt_loop].
         values,"'")
       ENDIF
       SET dclmc_parse->stmt[1].str = concat("select into 'nl:' r.table_name, amount = count(*), ",
        " ctxt = nullval(r.context_name,'<NULL>')")
       SET dclmc_parse->stmt[2].str = concat("from DM_CHG_LOG",dclm_rs->db_link," r")
       SET dclmc_parse->stmt[3].str = concat("where r.target_env_id = ",trim(cnvtstring(dclm_rs->
          cur_id,20,1)))
       SET dclmc_parse->stmt[4].str = concat(" and r.log_type = '",dclm_rs->reporting_qual[
        dclmc_loop1].log_type,"'")
       SET dclmc_parse->stmt[5].str = concat(" and ",dclmc_cnxt_str)
       IF ( NOT ((dclm_rs->cur_tier IN (0, 999)))
        AND dclmc_del_query_ind=0)
        SET dclmc_parse->stmt[6].str =
        " and exists(select 'X' from dm_info where info_domain='RDDS TIER LIST' "
        SET dclmc_parse->stmt[7].str = concat(" and info_number in ",dclmc_tier_str,
         " and info_name=r.table_name)"," and r.delete_ind = 0")
       ELSE
        SET dclmc_parse->stmt[6].str = " and "
        SET dclmc_parse->stmt[7].str = dclmc_tier_str
       ENDIF
       SET dclmc_parse->stmt[8].str =
       " group by r.table_name, r.context_name order by r.context_name, r.table_Name"
       SET dclmc_parse->stmt[9].str = " detail dclm_rs->cnt = dclm_rs->cnt + 1 "
       SET dclmc_parse->stmt[10].str =
       " if(mod(dclm_rs->cnt, 10) = 1) stat = alterlist(dclm_rs->qual, dclm_rs->cnt + 9)"
       SET dclmc_parse->stmt[11].str =
       " endif dclm_rs->qual[dclm_rs->cnt]->table_name = r.table_name"
       SET dclmc_parse->stmt[12].str = concat(" dclm_rs->qual[dclm_rs->cnt]->log_type  = '",dclm_rs->
        reporting_qual[dclmc_loop1].log_type,"'")
       SET dclmc_parse->stmt[13].str = " dclm_rs->qual[dclm_rs->cnt]->row_cnt = amount"
       SET dclmc_parse->stmt[14].str =
       " dclm_rs->qual[dclm_rs->cnt]->context_name = substring(1,25,ctxt)"
       SET dclmc_parse->stmt[15].str = " with nocounter go"
       EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","DCLMC_PARSE")
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_mon_child
       ENDIF
     ENDFOR
   ENDFOR
   IF ((((dclm_rs->cur_tier=0)) OR (dclmc_del_query_ind=1)) )
    SET dclmc_del_qual = size(dclm_rs->qual,5)
    SET dclmc_del_cnt = dclm_rs->cnt
    IF ((dclm_rs->cnt=0))
     SET dclm_rs->del_row_ind = 0
    ELSE
     SET dclm_rs->del_row_ind = 1
    ENDIF
   ENDIF
   IF ((dclm_rs->cnt < dclm_rs->max_lines)
    AND (((dclm_rs->cur_tier != 999)) OR (dclmc_del_query_ind=1)) )
    IF ((dclm_rs->cur_tier > 0)
     AND dclmc_del_query_ind=0)
     SET dclm_rs->cnt = dclmc_del_cnt
     SET stat = alterlist(dclm_rs->qual,dclmc_del_qual)
    ENDIF
    IF (dclmc_del_query_ind=1)
     SET dclmc_del_query_ind = 0
    ELSE
     IF (((dclm_rs->cur_tier+ 1) <= dclm_rs->max_tier))
      SET dclm_rs->cur_tier = (dclm_rs->cur_tier+ 1)
     ELSE
      SET dclm_rs->cur_tier = 999
     ENDIF
    ENDIF
    SET dclmc_tier_str = dclmc_set_tier_str(dclm_rs->cur_tier)
   ELSE
    SET stat = alterlist(dclm_rs->qual,dclm_rs->cnt)
    SET dclmc_done_ind = 1
   ENDIF
 ENDWHILE
 IF ((dclm_rs->cur_tier=999)
  AND (dclm_rs->cnt=0))
  SET dclm_rs->no_qual_msg =
  "There are no rows in the source change log for the LOG_TYPEs being reported within the contexts that are being merged."
  IF ((dclm_rs->context_qual[1].values != "ALL"))
   SET dm_err->eproc = "Check for other contexts in DCL"
   SELECT DISTINCT INTO "NL:"
    ctxt = nullval(d.context_name,"NULL")
    FROM (parser(concat("dm_chg_log",dclm_rs->db_link)) d)
    WHERE (d.target_env_id=dclm_rs->cur_id)
    ORDER BY d.context_name
    DETAIL
     dclmc_loop1 = locateval(dclmc_loop2,1,dclm_rs->context_cnt,ctxt,dclm_rs->context_qual[
      dclmc_loop2].values)
     IF (dclmc_loop1=0
      AND locateval(dclmc_loop2,1,dclm_rs->non_ctxt_cnt,ctxt,dclm_rs->non_ctxt_qual[dclmc_loop2].
      values)=0)
      dclm_rs->non_ctxt_cnt = (dclm_rs->non_ctxt_cnt+ 1), stat = alterlist(dclm_rs->non_ctxt_qual,
       dclm_rs->non_ctxt_cnt), dclm_rs->non_ctxt_qual[dclm_rs->non_ctxt_cnt].values = ctxt
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_mon_child
   ENDIF
   SET dm_err->eproc = "Check additional contexts for rows that can be reported on"
   IF ((dclm_rs->non_ctxt_cnt > 0))
    FOR (dclmc_loop2 = 1 TO dclm_rs->non_ctxt_cnt)
      IF ((dclm_rs->non_ctxt_qual[dclmc_loop2].values="NULL"))
       SELECT INTO "NL:"
        FROM (parser(concat("DM_CHG_LOG",dclm_rs->db_link)) r)
        WHERE r.context_name = null
         AND (r.target_env_id=dclm_rs->cur_id)
         AND expand(dclmc_loop1,1,dclm_rs->reporting_cnt,r.log_type,dclm_rs->reporting_qual[
         dclmc_loop1].log_type)
        WITH nocounter, maxqual(r,1)
       ;end select
      ELSE
       SELECT INTO "NL:"
        FROM (parser(concat("DM_CHG_LOG",dclm_rs->db_link)) r)
        WHERE (r.context_name=dclm_rs->non_ctxt_qual[dclmc_loop2].values)
         AND (r.target_env_id=dclm_rs->cur_id)
         AND expand(dclmc_loop1,1,dclm_rs->reporting_cnt,r.log_type,dclm_rs->reporting_qual[
         dclmc_loop1].log_type)
        WITH nocounter, maxqual(r,1)
       ;end select
      ENDIF
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_mon_child
      ENDIF
      IF (curqual > 0)
       SET dclmc_loop2 = dclm_rs->non_ctxt_cnt
      ENDIF
    ENDFOR
    IF (curqual=0)
     SET dclm_rs->no_qual_msg = concat(dclm_rs->no_qual_msg,
      "  Additional contexts exist in the source change log that are NOT currently being merged, ",
      "but no rows exist in the LOG_TYPEs being reported on, for those remaining contexts.")
    ELSE
     SET dclm_rs->no_qual_msg = concat(dclm_rs->no_qual_msg,
      "  Additional contexts exist in the source change log that are NOT currently being merged.",
      "  There is at least 1 row for the LOG_TYPEs being reported for the following contexts:")
     FOR (dclmc_loop1 = 1 TO dclm_rs->non_ctxt_cnt)
      CALL echo(concat("NON_CTXT_CNT",trim(cnvtstring(dclmc_loop1)),": ",dclm_rs->non_ctxt_qual[
        dclmc_loop1].values))
      IF (dclmc_loop1 > 1)
       SET dclm_rs->no_qual_msg = concat(dclm_rs->no_qual_msg,", ",dclm_rs->non_ctxt_qual[dclmc_loop1
        ].values)
      ELSE
       SET dclm_rs->no_qual_msg = concat(dclm_rs->no_qual_msg," ",dclm_rs->non_ctxt_qual[dclmc_loop1]
        .values)
      ENDIF
     ENDFOR
    ENDIF
   ELSE
    SET dclm_rs->no_qual_msg = concat(dclm_rs->no_qual_msg,
     "  All contexts in the source change log are currently being merged.")
   ENDIF
  ELSE
   SET dclm_rs->no_qual_msg =
   "There are no rows in the source change log for the LOG_TYPEs being reported."
  ENDIF
 ENDIF
 SET dm_err->eproc = "Query for number of mover processes"
 SELECT INTO "NL:"
  cnt = count(*)
  FROM dm_refchg_process d
  WHERE d.refchg_type="MOVER PROCESS"
   AND  NOT (d.refchg_status IN ("WRITING HANG FILE", "ORPHANED MOVER", "HANGING MOVER"))
   AND (d.env_source_id=dclm_rs->src_id)
   AND d.rdbhandle_value IN (
  (SELECT
   audsid
   FROM gv$session))
  DETAIL
   dclm_rs->num_procs = cnt
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_mon_child
 ENDIF
 SET dm_err->eproc = "Checking for auditable rows"
 SET dclm_rs->nomv_ind = 0
 IF ((dclm_rs->audit_cnt > 0))
  SELECT INTO "NL:"
   FROM (parser(concat("DM_CHG_LOG",dclm_rs->db_link)) d)
   WHERE (d.target_env_id=dclm_rs->cur_id)
    AND expand(dclmc_loop1,1,dclm_rs->audit_cnt,d.log_type,dclm_rs->audit_qual[dclmc_loop1].log_type)
   DETAIL
    dclm_rs->nomv_ind = 1
   WITH nocounter, maxqual(d,1)
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_mon_child
  ENDIF
 ENDIF
 SET dm_err->eproc = "Checking last cycle time"
 SELECT INTO "NL:"
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="RDDS STOP TIME"
  DETAIL
   dclm_rs->cycle_time = concat(trim(cnvtstring(datetimediff(cnvtdatetime(curdate,curtime3),d
       .info_date,4)))," minutes ago")
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_mon_child
 ENDIF
 SET dm_err->eproc = "Checking mover issues."
 SET dclm_rs->mover_stale_ind = 0
 SELECT INTO "NL:"
  FROM dm_refchg_process d
  WHERE d.refchg_type="MOVER PROCESS"
   AND d.rdbhandle_value IN (
  (SELECT
   audsid
   FROM gv$session))
   AND d.last_action_dt_tm <= cnvtlookbehind("1,H",sysdate)
  DETAIL
   dclm_rs->mover_stale_ind = 1
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_mon_child
 ENDIF
 SUBROUTINE dclmc_set_tier_str(sts_tier)
   DECLARE sts_tier_list = vc WITH protect, noconstant("")
   DECLARE sts_loop = i4 WITH protect, noconstant(0)
   CASE (sts_tier)
    OF 0:
     SET sts_tier_list = "r.delete_ind = 1"
    OF 999:
     SET sts_tier_list = "r.delete_ind = 0"
    ELSE
     SET sts_tier_list = "(1"
     FOR (sts_loop = 2 TO sts_tier)
       SET sts_tier_list = build(sts_tier_list,",",sts_loop)
     ENDFOR
     SET sts_tier_list = build(sts_tier_list,")")
   ENDCASE
   RETURN(sts_tier_list)
 END ;Subroutine
#exit_mon_child
END GO
