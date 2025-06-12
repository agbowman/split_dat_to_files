CREATE PROGRAM dm_rmc_pk_where:dba
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
 DECLARE cl_parse_cnt = i4
 SET cl_parse_cnt = 0
 IF (validate(dm2_cl_trg_rec->refchg_context_chk,"NO")="NO")
  FREE RECORD dm2_cl_trg_rec
  RECORD dm2_cl_trg_rec(
    1 refchg_context_chk = vc
    1 refchg_mvr_context_chk = vc
  )
  SET dm2_cl_trg_rec->refchg_context_chk =
  "(NVL(SYS_CONTEXT('CERNER','FIRE_REFCHG_TRG'),'DM2NULLVAL')!='NO')"
  SET dm2_cl_trg_rec->refchg_mvr_context_chk = concat(
   "((NVL(SYS_CONTEXT('CERNER','FIRE_REFCHG_TRG_MVR'),'DM2NULLVAL')!='NO')AND ",
   "(NVL(SYS_CONTEXT('CERNER','FIRE_REFCHG_TRG_MVR'),'DM2NULLVAL')!=to_char(envid_tbl(ct))))")
 ENDIF
 IF ((validate(dm2_cl_trg_updt_cols->tbl_cnt,- (1))=- (1)))
  IF ((validate(dm2_cl_trg_updt_cols->tbl_cnt,- (5))=- (5)))
   FREE RECORD dm2_cl_trg_updt_cols
   RECORD dm2_cl_trg_updt_cols(
     1 tbl_cnt = i4
     1 qual[*]
       2 tname = vc
       2 updt_task_exist_ind = i2
       2 updt_id_exist_ind = i2
       2 updt_applctx_exist_ind = i2
   )
  ENDIF
 ENDIF
 IF ((validate(cl_hold_buff->bg_err,- (1))=- (1)))
  FREE RECORD cl_hold_buffer
  RECORD cl_hold_buffer(
    1 bg_err = i2
    1 bg_hold[*]
      2 bg_buffer = vc
  )
 ENDIF
 IF ( NOT (validate(dcltr_circ)))
  FREE RECORD dcltr_circ
  RECORD dcltr_circ(
    1 tbl_cnt = i4
    1 tbl_qual[*]
      2 table_name = vc
      2 pk_col = vc
      2 circ_cnt = i4
      2 circ_qual[*]
        3 circ_tab = vc
        3 circ_id_col = vc
        3 circ_name_col = vc
        3 circ_exist_ind = i2
        3 circ_r_tab = vc
        3 fk_name_col = vc
        3 fk_id_col = vc
        3 fk_exist_ind = i2
  )
 ENDIF
 DECLARE refchg_trg_bld_std_when(s_rtbsw_trigger_type=vc,s_rtbsw_br_flg=i2,s_rtbsw_updt_task_exist=i2,
  s_rtbsw_flex=vc) = i2 WITH public
 DECLARE cl_push(p_text=vc) = null WITH public
 DECLARE dm2_trg_updt_cols_check(s_table_name=vc) = i2 WITH public
 DECLARE dm2_cl_trg_updt_cols(s_ctuc_tname=vc) = i2 WITH public
 DECLARE rc_push(p_text=vc) = null WITH public
 DECLARE flex_push(rc_cl_flex=vc,flex_text=vc) = null WITH public
 DECLARE binsearch_refchg(i_key=vc) = i4 WITH public
 DECLARE dcltr_get_circ_tab(dgct_table_name=vc) = i2
 SUBROUTINE refchg_trg_bld_std_when(s_rtbsw_trigger_type,s_rtbsw_br_flg,s_rtbsw_updt_task_exist,
  s_rtbsw_flex)
   DECLARE s_rtbsw_return_int = i2
   SET s_rtbsw_return_int = 1
   IF (currdb="ORACLE")
    CALL flex_push(s_rtbsw_flex,concat('ASIS(" when ( ',dm2_cl_trg_rec->refchg_context_chk,'")'))
    IF (s_rtbsw_trigger_type IN ("UPD", "ADD")
     AND s_rtbsw_updt_task_exist=1)
     CALL flex_push(s_rtbsw_flex,concat('ASIS(" and new.updt_task not in ( 15301)")'))
    ENDIF
    IF (s_rtbsw_br_flg=1)
     CALL flex_push(s_rtbsw_flex,concat('ASIS(" and ( ',dm2_cl_trg_rec->refchg_mvr_context_chk,'")'))
    ENDIF
   ENDIF
   RETURN(s_rtbsw_return_int)
 END ;Subroutine
 SUBROUTINE cl_push(p_text)
   SET cl_parse_cnt = (cl_parse_cnt+ 1)
   IF (mod(cl_parse_cnt,100)=1)
    SET stat = alterlist(cl_hold_buffer->bg_hold,(cl_parse_cnt+ 99))
   ENDIF
   SET cl_hold_buffer->bg_hold[cl_parse_cnt].bg_buffer = p_text
 END ;Subroutine
 SUBROUTINE rc_push(p_text)
   SET rc_parse_cnt = (rc_parse_cnt+ 1)
   IF (mod(rc_parse_cnt,100)=1)
    SET stat = alterlist(rc_hold_buffer->bg_hold,(rc_parse_cnt+ 99))
   ENDIF
   SET rc_hold_buffer->bg_hold[rc_parse_cnt].bg_buffer = p_text
 END ;Subroutine
 SUBROUTINE flex_push(rc_cl_flex,flex_text)
   IF (rc_cl_flex="RC")
    CALL rc_push(flex_text)
   ELSEIF (rc_cl_flex="CL")
    CALL cl_push(flex_text)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_trg_updt_cols_check(s_table_name)
   SET dm2_cl_trg_updt_cols->tbl_cnt = (dm2_cl_trg_updt_cols->tbl_cnt+ 1)
   SET stat = alterlist(dm2_cl_trg_updt_cols->qual,dm2_cl_trg_updt_cols->tbl_cnt)
   SET dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].tname = s_table_name
   SET dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_task_exist_ind = 0
   SET dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_id_exist_ind = 0
   SET dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_applctx_exist_ind = 0
   SELECT INTO "nl:"
    FROM dtableattr dta,
     dtableattrl dtal
    PLAN (dta
     WHERE dta.table_name=s_table_name)
     JOIN (dtal
     WHERE dtal.structtype="F"
      AND btest(dtal.stat,11)=0
      AND dtal.attr_name IN ("UPDT_TASK", "UPDT_ID", "UPDT_APPLCTX"))
    DETAIL
     IF (dtal.attr_name="UPDT_TASK")
      dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_task_exist_ind = 1
     ELSEIF (dtal.attr_name="UPDT_ID")
      dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_id_exist_ind = 1
     ELSEIF (dtal.attr_name="UPDT_APPLCTX")
      dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_applctx_exist_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(- (1))
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_cl_trg_updt_cols(s_ctuc_tname)
   DECLARE s_dctuc_return_int = i2
   DECLARE s_where_str = vc
   SET dm2_cl_trg_updt_cols->tbl_cnt = 0
   SET s_dctuc_return_int = 0
   SET stat = alterlist(dm2_cl_trg_updt_cols->qual,0)
   IF (s_ctuc_tname=char(42))
    SET s_where_str = "1=1"
   ELSE
    SET s_where_str = "ut.table_name = patstring(s_ctuc_tname)"
   ENDIF
   SELECT INTO "nl:"
    FROM user_tab_columns utc
    WHERE utc.table_name IN (
    (SELECT
     ut.table_name
     FROM user_tables ut
     WHERE parser(s_where_str)))
    ORDER BY utc.table_name
    HEAD REPORT
     stat = alterlist(dm2_cl_trg_updt_cols->qual,10)
    HEAD utc.table_name
     dm2_cl_trg_updt_cols->tbl_cnt = (dm2_cl_trg_updt_cols->tbl_cnt+ 1)
     IF (mod(dm2_cl_trg_updt_cols->tbl_cnt,10)=1
      AND (dm2_cl_trg_updt_cols->tbl_cnt != 1))
      stat = alterlist(dm2_cl_trg_updt_cols->qual,(dm2_cl_trg_updt_cols->tbl_cnt+ 9))
     ENDIF
     dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].tname = utc.table_name,
     dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_task_exist_ind = 0,
     dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_id_exist_ind = 0,
     dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_applctx_exist_ind = 0
    DETAIL
     IF (utc.column_name="UPDT_TASK")
      dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_task_exist_ind = 1
     ENDIF
     IF (utc.column_name="UPDT_ID")
      dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_id_exist_ind = 1
     ENDIF
     IF (utc.column_name="UPDT_APPLCTX")
      dm2_cl_trg_updt_cols->qual[dm2_cl_trg_updt_cols->tbl_cnt].updt_applctx_exist_ind = 1
     ENDIF
    FOOT REPORT
     stat = alterlist(dm2_cl_trg_updt_cols->qual,dm2_cl_trg_updt_cols->tbl_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=0)
    IF ((dm_err->debug_flag != 0))
     CALL echo(concat("Obtained column information for: ",cnvtstring(dm2_cl_trg_updt_cols->tbl_cnt),
       " table/s"))
    ENDIF
    RETURN(s_dctuc_return_int)
   ELSE
    SET s_dctuc_return_int = 1
   ENDIF
   RETURN(s_dctuc_return_int)
 END ;Subroutine
 SUBROUTINE binsearch_refchg(i_key)
   DECLARE v_low = i4 WITH noconstant(0)
   DECLARE v_mid = i4 WITH noconstant(0)
   DECLARE v_high = i4
   SET v_high = size(refchg_tab_r->child,5)
   IF (v_high > 0)
    WHILE (((v_high - v_low) > 1))
     SET v_mid = cnvtint(((v_high+ v_low)/ 2))
     IF ((i_key <= refchg_tab_r->child[v_mid].child_table))
      SET v_high = v_mid
     ELSE
      SET v_low = v_mid
     ENDIF
    ENDWHILE
    IF (trim(i_key,3)=trim(refchg_tab_r->child[v_high].child_table,3))
     RETURN(v_high)
    ELSE
     RETURN(0)
    ENDIF
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE dcltr_get_circ_tab(dgct_table_name)
   DECLARE dgct_info_name = vc WITH protect, noconstant(" ")
   DECLARE dgct_temp = vc WITH protect, noconstant(" ")
   DECLARE dgct_idx = i4 WITH protect, noconstant(0)
   DECLARE dgct_col_pos = i4 WITH protect, noconstant(0)
   DECLARE dgct_col_pos2 = i4 WITH protect, noconstant(0)
   DECLARE dgct_start = i4 WITH protect, noconstant(0)
   DECLARE dgct_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgct_temp2 = vc WITH protect, noconstant(" ")
   DECLARE dgct_tab_pos = i4 WITH protect, noconstant(0)
   DECLARE dgct_temp_tab = vc WITH protect, noconstant(" ")
   DECLARE dgct_num = i4 WITH protect, noconstant(0)
   FREE RECORD dgct_tabs
   RECORD dgct_tabs(
     1 cnt = i4
     1 qual[*]
       2 table_name = vc
       2 column_name = vc
       2 suffix = vc
       2 r_table_name = vc
       2 val_table_name = vc
       2 exist_ind = i2
   )
   SET dgct_info_name = concat(dgct_table_name,":*")
   SET dgct_start = (dcltr_circ->tbl_cnt+ 1)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="RDDS 7 CIRCULAR:*"
     AND di.info_name=patstring(dgct_info_name)
    ORDER BY di.info_name
    HEAD di.info_name
     dgct_col_pos = findstring(":",di.info_name), dgct_temp = substring(1,(dgct_col_pos - 1),di
      .info_name), dgct_idx = locateval(dgct_idx,1,dcltr_circ->tbl_cnt,dgct_temp,dcltr_circ->
      tbl_qual[dgct_idx].table_name)
     IF (dgct_idx=0)
      dcltr_circ->tbl_cnt = (dcltr_circ->tbl_cnt+ 1), stat = alterlist(dcltr_circ->tbl_qual,
       dcltr_circ->tbl_cnt), dgct_idx = dcltr_circ->tbl_cnt,
      dcltr_circ->tbl_qual[dgct_idx].table_name = dgct_temp
     ENDIF
    DETAIL
     dgct_col_pos = findstring(":",di.info_domain), dgct_col_pos2 = findstring(":",di.info_domain,(
      dgct_col_pos+ 1)), dgct_temp = substring((dgct_col_pos+ 1),((dgct_col_pos2 - dgct_col_pos) - 1),
      di.info_domain),
     dgct_temp2 = substring((dgct_col_pos2+ 1),30,di.info_domain), dgct_tab_pos = locateval(
      dgct_tab_pos,1,dgct_tabs->cnt,dgct_temp,dgct_tabs->qual[dgct_tab_pos].table_name,
      dgct_temp2,dgct_tabs->qual[dgct_tab_pos].column_name)
     IF (dgct_tab_pos=0)
      dgct_tabs->cnt = (dgct_tabs->cnt+ 1), stat = alterlist(dgct_tabs->qual,dgct_tabs->cnt),
      dgct_tabs->qual[dgct_tabs->cnt].table_name = dgct_temp,
      dgct_tabs->qual[dgct_tabs->cnt].column_name = dgct_temp2, dgct_tabs->qual[dgct_tabs->cnt].
      val_table_name = dgct_tabs->qual[dgct_tabs->cnt].table_name
     ENDIF
     dgct_cnt = locateval(dgct_cnt,1,dcltr_circ->tbl_qual[dgct_idx].circ_cnt,dgct_temp,dcltr_circ->
      tbl_qual[dgct_idx].circ_qual[dgct_cnt].circ_tab,
      dgct_temp2,dcltr_circ->tbl_qual[dgct_idx].circ_qual[dgct_cnt].circ_id_col)
     IF (dgct_cnt=0)
      dcltr_circ->tbl_qual[dgct_idx].circ_cnt = (dcltr_circ->tbl_qual[dgct_idx].circ_cnt+ 1),
      dgct_cnt = dcltr_circ->tbl_qual[dgct_idx].circ_cnt, stat = alterlist(dcltr_circ->tbl_qual[
       dgct_idx].circ_qual,dgct_cnt),
      dcltr_circ->tbl_qual[dgct_idx].circ_qual[dgct_cnt].circ_tab = dgct_temp, dcltr_circ->tbl_qual[
      dgct_idx].circ_qual[dgct_cnt].circ_id_col = dgct_temp2, dcltr_circ->tbl_qual[dgct_idx].
      circ_qual[dgct_cnt].circ_name_col = di.info_char,
      dgct_col_pos = findstring(":",di.info_name,1), dgct_col_pos2 = findstring(":",di.info_name,(
       dgct_col_pos+ 1))
      IF (dgct_col_pos2 > 0)
       dcltr_circ->tbl_qual[dgct_idx].circ_qual[dgct_cnt].fk_id_col = substring((dgct_col_pos+ 1),((
        dgct_col_pos2 - dgct_col_pos) - 1),di.info_name), dcltr_circ->tbl_qual[dgct_idx].circ_qual[
       dgct_cnt].fk_name_col = substring((dgct_col_pos2+ 1),(size(trim(di.info_name)) - dgct_col_pos2
        ),di.info_name)
      ELSE
       dcltr_circ->tbl_qual[dgct_idx].circ_qual[dgct_cnt].fk_id_col = substring((dgct_col_pos+ 1),(
        size(trim(di.info_name)) - dgct_col_pos),di.info_name)
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(- (1))
   ELSEIF (curqual=0)
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_tables_doc_local d
    WHERE expand(dgct_cnt,1,dgct_tabs->cnt,d.table_name,dgct_tabs->qual[dgct_cnt].table_name)
     AND d.table_name=d.full_table_name
    DETAIL
     FOR (dgct_idx = 1 TO dgct_tabs->cnt)
       IF ((d.table_name=dgct_tabs->qual[dgct_idx].table_name))
        dgct_tabs->qual[dgct_idx].suffix = d.table_suffix
       ENDIF
     ENDFOR
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(- (1))
   ENDIF
   FOR (dgct_idx = 1 TO dgct_tabs->cnt)
     SET dgct_tabs->qual[dgct_idx].r_table_name = cutover_tab_name(dgct_tabs->qual[dgct_idx].
      table_name,dgct_tabs->qual[dgct_idx].suffix)
   ENDFOR
   SELECT INTO "nl:"
    FROM user_tables ut
    WHERE expand(dgct_cnt,1,dgct_tabs->cnt,ut.table_name,dgct_tabs->qual[dgct_cnt].r_table_name)
    DETAIL
     FOR (dgct_idx = 1 TO dgct_tabs->cnt)
       IF ((ut.table_name=dgct_tabs->qual[dgct_idx].r_table_name))
        dgct_tabs->qual[dgct_idx].val_table_name = ut.table_name
       ENDIF
     ENDFOR
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(- (1))
   ENDIF
   SELECT INTO "nl:"
    FROM user_tab_columns utc
    WHERE expand(dgct_num,1,dgct_tabs->cnt,utc.table_name,dgct_tabs->qual[dgct_num].val_table_name,
     utc.column_name,dgct_tabs->qual[dgct_num].column_name)
    DETAIL
     dgct_cnt = locateval(dgct_cnt,1,dgct_tabs->cnt,utc.table_name,dgct_tabs->qual[dgct_cnt].
      val_table_name,
      utc.column_name,dgct_tabs->qual[dgct_cnt].column_name), dgct_tabs->qual[dgct_cnt].exist_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(- (1))
   ENDIF
   IF ((dcltr_circ->tbl_cnt >= dgct_start))
    SELECT INTO "nl:"
     FROM dm_columns_doc_local d
     WHERE expand(dgct_cnt,dgct_start,dcltr_circ->tbl_cnt,d.table_name,dcltr_circ->tbl_qual[dgct_cnt]
      .table_name)
      AND d.table_name=d.root_entity_name
      AND d.column_name=d.root_entity_attr
      AND  EXISTS (
     (SELECT
      "x"
      FROM user_tab_columns u
      WHERE u.table_name=d.table_name
       AND u.column_name=d.column_name))
     DETAIL
      dgct_cnt = locateval(dgct_cnt,dgct_start,dcltr_circ->tbl_cnt,d.table_name,dcltr_circ->tbl_qual[
       dgct_cnt].table_name), dcltr_circ->tbl_qual[dgct_cnt].pk_col = d.column_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     RETURN(- (1))
    ENDIF
   ENDIF
   FOR (dgct_idx = dgct_start TO dcltr_circ->tbl_cnt)
     FOR (dgct_cnt = 1 TO dcltr_circ->tbl_qual[dgct_idx].circ_cnt)
       SET dgct_tab_pos = locateval(dgct_tab_pos,1,dgct_tabs->cnt,dcltr_circ->tbl_qual[dgct_idx].
        circ_qual[dgct_cnt].circ_tab,dgct_tabs->qual[dgct_tab_pos].table_name,
        dcltr_circ->tbl_qual[dgct_idx].circ_qual[dgct_cnt].circ_id_col,dgct_tabs->qual[dgct_tab_pos].
        column_name)
       SET dcltr_circ->tbl_qual[dgct_idx].circ_qual[dgct_cnt].circ_r_tab = dgct_tabs->qual[
       dgct_tab_pos].r_table_name
       SET dcltr_circ->tbl_qual[dgct_idx].circ_qual[dgct_cnt].circ_exist_ind = dgct_tabs->qual[
       dgct_tab_pos].exist_ind
       IF ((dcltr_circ->tbl_qual[dgct_idx].circ_qual[dgct_cnt].fk_name_col > " "))
        SELECT INTO "nl:"
         FROM user_tab_columns utc
         WHERE (utc.table_name=dcltr_circ->tbl_qual[dgct_idx].table_name)
          AND (utc.column_name=dcltr_circ->tbl_qual[dgct_idx].circ_qual[dgct_cnt].fk_name_col)
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         RETURN(- (1))
        ELSEIF (curqual > 0)
         SET dcltr_circ->tbl_qual[dgct_idx].circ_qual[dgct_cnt].fk_exist_ind = 1
        ENDIF
       ELSE
        SET dcltr_circ->tbl_qual[dgct_idx].circ_qual[dgct_cnt].fk_exist_ind = 1
       ENDIF
     ENDFOR
   ENDFOR
   RETURN(1)
 END ;Subroutine
 FREE RECORD dyn_ui_search
 RECORD dyn_ui_search(
   1 qual[*]
     2 pk_value = f8
     2 other = vc
 )
 IF (validate(drdm_sequence->qual[1].seq_val,- (1)) < 0)
  FREE RECORD drdm_sequence
  RECORD drdm_sequence(
    1 qual[*]
      2 seq_name = vc
      2 seq_val = f8
  )
 ENDIF
 IF (validate(dm2_rdds_rec->mode,"NONE")="NONE")
  FREE RECORD dm2_rdds_rec
  RECORD dm2_rdds_rec(
    1 mode = vc
    1 main_process = vc
  )
 ENDIF
 IF (validate(ui_query_rec->table_name,"NONE")="NONE")
  FREE RECORD ui_query_rec
  RECORD ui_query_rec(
    1 table_name = vc
    1 dom = vc
    1 usage = vc
    1 qual[*]
      2 qtype = vc
      2 where_clause = vc
      2 cqual[*]
        3 query_idx = i2
      2 other_pk_col[*]
        3 col_name = vc
  )
  FREE RECORD ui_query_eval_rec
  RECORD ui_query_eval_rec(
    1 qual[*]
      2 root_entity_attr = f8
      2 additional_attr = vc
  )
 ENDIF
 IF (validate(select_merge_translate_rec->type,"NONE")="NONE")
  FREE RECORD select_merge_translate_rec
  RECORD select_merge_translate_rec(
    1 type = vc
  )
 ENDIF
 DECLARE find_p_e_col(sbr_p_e_name=vc,sbr_p_e_col=i4) = vc
 DECLARE dm_translate(sbr_tbl_name=vc,sbr_col_name=vc,sbr_from_val=vc) = vc
 DECLARE dm_trans2(sbr_tbl_name=vc,sbr_col_name=vc,sbr_from_val=vc,sbr_src_ind=i2) = vc
 DECLARE dm_trans3(sbr_tbl_name=vc,sbr_col_name=vc,sbr_from_val=f8,sbr_src_ind=i2,sbr_pe_tbl_name=vc)
  = vc
 DECLARE insert_update_row(iur_temp_tbl_cnt=i4,iur_perm_col_cnt=i4) = i2
 DECLARE query_target(qt_temp_tbl_cnt=i4,qt_perm_col_cnt=i4) = f8 WITH public
 DECLARE merge_audit(action=vc,text=vc,audit_type=i4) = null
 DECLARE parse_statements(parser_cnt=i4) = null
 DECLARE insert_merge_translate(sbr_from=f8,sbr_to=f8,sbr_table=vc) = i2
 DECLARE select_merge_translate(sbr_f_value=vc,sbr_t_name=vc) = vc
 DECLARE del_chg_log(sbr_table_name=vc,sbr_log_type=vc,sbr_target_id=f8) = null
 DECLARE report_missing(sbr_table_name=vc,sbr_column_name=vc,sbr_value=f8) = vc
 DECLARE rdds_del_except(sbr_table_name=vc,sbr_value=f8) = null
 DECLARE version_exception(sbr_table_name=vc,sbr_column_name=vc,sbr_value=f8) = null
 DECLARE orphan_child_tab(sbr_table_name=vc,sbr_log_type=vc) = i2
 DECLARE dm2_rdds_get_tbl_alias(sbr_tbl_suffix=vc) = vc
 DECLARE dm2_get_rdds_tname(sbr_tname=vc) = vc
 DECLARE exec_ui_query(exec_tbl_cnt=i4,exec_perm_col_cnt=i4) = f8 WITH public
 DECLARE evaluate_exec_ui_query(sbr_current_qual=i4,eval_tbl_cnt=i4,eval_perm_col_cnt=i4) = f8 WITH
 public
 DECLARE insert_noxlat(sbr_table_name=vc,sbr_column_name=vc,sbr_value=f8,sbr_orphan_ind=i2) = i2
 DECLARE add_rs_values(sbr_table_name=vc,sbr_column_name=vc,sbr_value=f8) = i4
 DECLARE trigger_proc_call(tpc_table_name=vc,tpc_pk_where=vc,tpc_context=vc,tpc_col_name=vc,tpc_value
  =f8) = i2
 DECLARE filter_proc_call(fpc_table_name=vc,fpc_pk_where=vc) = i2
 DECLARE replace_carrot_symbol(rcs_string=vc) = vc
 SUBROUTINE query_target(qt_temp_tbl_cnt,qt_perm_col_cnt)
   DECLARE sbr_active_value = i2
   DECLARE sbr_effective_date = f8
   DECLARE sbr_end_effective_date = f8
   DECLARE sbr_returned_value = f8
   DECLARE sbr_cur_date = f8
   DECLARE sbr_rec_size = i4
   DECLARE sbr_null_beg_ind = i2
   DECLARE sbr_null_end_ind = i2
   SET sbr_cur_date = cnvtdatetime(curdate,curtime3)
   SET sbr_table_name = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name
   SET drdm_return_var = 0
   IF ((dm2_ref_data_doc->tbl_qual[qt_temp_tbl_cnt].merge_delete_ind=1))
    RETURN(- (3))
   ELSE
    SET dm_err->eproc = "Query Target"
    CALL echo("")
    CALL echo("")
    CALL echo("*******************QUERY TARGET***************************")
    CALL echo("")
    CALL echo("")
    SET sbr_rec_size = 1
    SET stat = alterlist(ui_query_rec->qual,sbr_rec_size)
    SET ui_query_rec->table_name = sbr_table_name
    SET ui_query_rec->usage = ""
    SET ui_query_rec->dom = "TO"
    SET ui_query_rec->qual[sbr_rec_size].qtype = "UIONLY"
    IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].active_ind_ind=1))
     SET sbr_rec_size = (sbr_rec_size+ 1)
     SET stat = alterlist(ui_query_rec->qual,sbr_rec_size)
     SET sbr_active_value = cnvtreal(get_value(sbr_table_name,"ACTIVE_IND","FROM"))
     IF (sbr_active_value=1)
      SET ui_query_rec->qual[sbr_rec_size].qtype = "ACTIVE"
     ELSE
      SET ui_query_rec->qual[sbr_rec_size].qtype = "INACTIVE"
     ENDIF
    ENDIF
    IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].effective_col_ind=1))
     SET sbr_null_beg_ind = get_nullind(sbr_table_name,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
      beg_col_name)
     SET sbr_null_end_ind = get_nullind(sbr_table_name,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
      end_col_name)
     IF (((sbr_null_beg_ind=1) OR (sbr_null_end_ind=1)) )
      SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].effective_col_ind = 0
     ELSE
      SET sbr_rec_size = (sbr_rec_size+ 1)
      SET stat = alterlist(ui_query_rec->qual,sbr_rec_size)
      CALL parser(concat("set sbr_effective_date = RS_",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
        suffix,"->from_values.",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].beg_col_name," go "),1)
      CALL parser(concat("set sbr_end_effective_date = RS_",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
        suffix,"->from_values.",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].end_col_name," go "),1)
      IF (sbr_effective_date <= sbr_cur_date
       AND sbr_end_effective_date >= sbr_cur_date)
       SET ui_query_rec->qual[sbr_rec_size].qtype = "EFFECTIVE"
      ELSE
       SET ui_query_rec->qual[sbr_rec_size].qtype = "END_EFFECTIVE"
      ENDIF
     ENDIF
     IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].active_ind_ind=1)
      AND (dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].effective_col_ind=1))
      SET sbr_rec_size = (sbr_rec_size+ 1)
      SET stat = alterlist(ui_query_rec->qual,sbr_rec_size)
      SET ui_query_rec->qual[sbr_rec_size].qtype = "COMBO"
      SET stat = alterlist(ui_query_rec->qual[sbr_rec_size].cqual,2)
      SET ui_query_rec->qual[sbr_rec_size].cqual[1].query_idx = 2
      SET ui_query_rec->qual[sbr_rec_size].cqual[2].query_idx = 3
     ENDIF
    ENDIF
    SET sbr_returned_value = exec_ui_query(qt_temp_tbl_cnt,qt_perm_col_cnt)
    SET stat = alterlist(ui_query_rec->qual[sbr_rec_size].other_pk_col,0)
    RETURN(sbr_returned_value)
   ENDIF
 END ;Subroutine
 SUBROUTINE exec_ui_query(exec_tbl_cnt,exec_perm_col_cnt)
   DECLARE sbr_while_loop = i2
   DECLARE sbr_done_select = i2
   DECLARE sbr_loop = i2
   DECLARE sbr_other_loop = i2
   DECLARE query_cnt = i4
   DECLARE sbr_eff_date = f8
   DECLARE sbr_end_eff_date = f8
   DECLARE sbr_cur_date = f8
   DECLARE query_return = f8
   DECLARE rs_tab_prefix = vc
   DECLARE sbr_domain = vc
   DECLARE add_ndx = i4
   DECLARE ndx_loop = i4
   DECLARE add_col_name = vc
   DECLARE add_d_type = vc
   DECLARE euq_ord_col = vc
   SET rs_tab_prefix = concat("RS_",dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].suffix)
   SET sbr_cur_date = cnvtdatetime(curdate,curtime3)
   SET euq_ord_col = ""
   FOR (sbr_loop = 1 TO size(ui_query_eval_rec->qual,5))
     SET ui_query_eval_rec->qual[sbr_loop].additional_attr = ""
   ENDFOR
   SET sbr_loop = 1
   SET sbr_done_select = 0
   IF ((ui_query_rec->dom="FROM"))
    SET sbr_domain = "FROM"
   ELSE
    SET sbr_domain = "TO"
   ENDIF
   WHILE (sbr_loop <= size(ui_query_rec->qual,5)
    AND sbr_done_select=0)
     SET stat = alterlist(ui_query_eval_rec->qual,0)
     SET query_cnt = 0
     IF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].merge_ui_query_ni=1))
      IF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].root_entity_name=
      dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].table_name)
       AND (dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].root_entity_attr=
      dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].column_name)
       AND (dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].pk_ind=1))
       SET drdm_parser->statement[1].frag = concat("select into 'NL:' dc.",value(dm2_ref_data_doc->
         tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].root_entity_attr))
      ELSE
       SET drdm_parser->statement[1].frag = "select into 'NL:' "
      ENDIF
      SET drdm_parser->statement[2].frag = concat(" from ",value(ui_query_rec->table_name)," dc ",
       " where ")
      SET drdm_parser_cnt = 3
      FOR (drdm_loop_cnt = 1 TO exec_perm_col_cnt)
        IF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[drdm_loop_cnt].unique_ident_ind=1))
         SET no_unique_ident = 1
         IF (drdm_parser_cnt > 3)
          SET drdm_parser->statement[drdm_parser_cnt].frag = " and "
          SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
         ENDIF
         SET drdm_col_name = dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[drdm_loop_cnt].
         column_name
         SET drdm_from_con = concat(rs_tab_prefix,"->",sbr_domain,"_values.",drdm_col_name)
         IF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[drdm_loop_cnt].check_null=1))
          IF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[drdm_loop_cnt].data_type IN ("DQ8",
          "F8", "I4", "I2")))
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = NULL")
          ELSE
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" (dc.",drdm_col_name,
            " = null or ",drdm_col_name," = ' ')")
          ENDIF
          SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
         ELSEIF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[drdm_loop_cnt].check_space=1))
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" (dc.",drdm_col_name,
           " = ' ' or ",drdm_col_name," = null)")
          SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
         ELSE
          CASE (dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[drdm_loop_cnt].data_type)
           OF "DQ8":
            SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name,
             " =  cnvtdatetime(",drdm_from_con,")")
            SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           ELSE
            SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = ",
             drdm_from_con)
            SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
          ENDCASE
         ENDIF
        ENDIF
      ENDFOR
      IF (no_unique_ident=0)
       SET insert_update_reason = "There were no unique_ident_ind's for log_id "
       SET no_insert_update = 1
       SET dm2_ref_data_reply->error_ind = 1
       SET dm2_ref_data_reply->error_msg = concat(dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].
        custom_script,": There were no unique_ident_ind's")
       RETURN(- (2))
      ENDIF
      SET sbr_current_date = cnvtdatetime(curdate,curtime3)
      CASE (ui_query_rec->qual[sbr_loop].qtype)
       OF "UIONLY":
       OF patstring("ORDER*",0):
        SET ui_query_rec->qual[sbr_loop].where_clause = ""
       OF "ACTIVE":
        SET ui_query_rec->qual[sbr_loop].where_clause = " AND dc.ACTIVE_IND = 1"
       OF "INACTIVE":
        SET ui_query_rec->qual[sbr_loop].where_clause = " AND dc.ACTIVE_IND = 0"
       OF "EFFECTIVE":
        SET ui_query_rec->qual[sbr_loop].where_clause = concat(" AND dc.",dm2_ref_data_doc->tbl_qual[
         temp_tbl_cnt].beg_col_name,"<=  cnvtdatetime(sbr_cur_date) AND dc.",dm2_ref_data_doc->
         tbl_qual[temp_tbl_cnt].end_col_name,">= cnvtdatetime(sbr_cur_date)")
       OF "END_EFFECTIVE":
        SET ui_query_rec->qual[sbr_loop].where_clause = concat(" AND dc.",dm2_ref_data_doc->tbl_qual[
         temp_tbl_cnt].beg_col_name,">=  cnvtdatetime(sbr_cur_date) OR dc.",dm2_ref_data_doc->
         tbl_qual[temp_tbl_cnt].end_col_name,"<= cnvtdatetime(sbr_cur_date)")
       OF "COMBO":
        FOR (sbr_other_loop = 1 TO size(ui_query_rec->qual[sbr_loop].cqual,5))
          SET ui_query_rec->qual[sbr_loop].where_clause = concat(ui_query_rec->qual[sbr_loop].
           where_clause,ui_query_rec->qual[ui_query_rec->qual[sbr_loop].cqual[sbr_other_loop].
           query_idx].where_clause)
        ENDFOR
      ENDCASE
      IF ((ui_query_rec->qual[sbr_loop].where_clause != ""))
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(ui_query_rec->qual[sbr_loop].
        where_clause)
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ENDIF
      IF ((ui_query_rec->qual[sbr_loop].qtype="ORDER:*"))
       SET euq_ord_col = substring((findstring(":",ui_query_rec->qual[sbr_loop].qtype,1,0)+ 1),(size(
         ui_query_rec->qual[sbr_loop].qtype) - findstring(":",ui_query_rec->qual[sbr_loop].qtype,1,0)
        ),ui_query_rec->qual[sbr_loop].qtype)
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" ORDER BY dc.",euq_ord_col)
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ENDIF
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" head report",
       " stat = alterlist(ui_query_eval_rec->qual, 10)"," query_cnt = 0")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" detail query_cnt = query_cnt + 1 ")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(
       "if (mod(query_cnt,10) = 1 and query_cnt != 1)")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(
       " stat = alterlist(ui_query_eval_rec->qual, query_cnt + 9)")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" endif")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      IF ((dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].root_entity_name=
      dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].table_name)
       AND (dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].root_entity_attr=
      dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].column_name)
       AND (dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].pk_ind=1))
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(
        "ui_query_eval_rec->qual[query_cnt]->root_entity_attr = dc.",value(dm2_ref_data_doc->
         tbl_qual[exec_tbl_cnt].col_qual[temp_col_cnt].root_entity_attr))
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ENDIF
      IF (size(ui_query_rec->qual[sbr_loop].other_pk_col,5) > 0)
       IF ((ui_query_rec->qual[sbr_loop].other_pk_col[1].col_name != ""))
        SET add_col_name = ui_query_rec->qual[sbr_loop].other_pk_col[1].col_name
        SET add_ndx = locateval(ndx_loop,1,dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_cnt,
         add_col_name,dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[ndx_loop].column_name)
        IF (add_ndx > 0)
         SET add_d_type = dm2_ref_data_doc->tbl_qual[exec_tbl_cnt].col_qual[add_ndx].data_type
         IF ( NOT (add_d_type IN ("VC", "C*")))
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(
           " ui_query_eval_rec->qual[query_cnt]->additional_attr = cnvtstring(dc.",add_col_name,")")
         ELSE
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(
           " ui_query_eval_rec->qual[query_cnt]->additional_attr = dc.",add_col_name)
         ENDIF
         SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        ENDIF
       ENDIF
      ENDIF
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" foot report",
       " stat = alterlist(ui_query_eval_rec->qual, query_cnt)"," with nocounter go")
      CALL parse_statements(drdm_parser_cnt)
      IF (nodelete_ind=1)
       SET query_return = - (1)
       SET sbr_done_select = 1
      ELSEIF ((query_return != - (1)))
       SET query_return = evaluate_exec_ui_query(query_cnt,exec_tbl_cnt,exec_perm_col_cnt)
      ENDIF
      IF ((((query_return=- (3))) OR (query_return >= 0)) )
       SET sbr_done_select = 1
      ELSE
       SET sbr_loop = (sbr_loop+ 1)
      ENDIF
     ENDIF
   ENDWHILE
   IF ((query_return=- (2))
    AND (ui_query_rec->usage != "VERSION"))
    SET insert_update_reason = "Multiple values returned with unique indicator query for log_id "
    SET no_insert_update = 1
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = "NOMV06"
    SET drdm_mini_loop_status = "NOMV06"
    ROLLBACK
    CALL orphan_child_tab(sbr_table_name,"NOMV06")
    COMMIT
   ENDIF
   RETURN(query_return)
 END ;Subroutine
 SUBROUTINE evaluate_exec_ui_query(sbr_current_qual,eval_tbl_cnt,eval_perm_col_cnt)
   DECLARE sbr_eval_loop = i4
   DECLARE sbr_trans_val = vc
   DECLARE sbr_table_name = vc
   DECLARE sbr_root_entity_attr_val = f8
   DECLARE sbr_not_translated_count = i4
   DECLARE sbr_value_pos = i4
   DECLARE sbr_temp_pk_value = f8
   SET sbr_table_name = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name
   SET sbr_eval_loop = 1
   SET sbr_not_translated_count = 0
   IF (sbr_current_qual=0)
    RETURN(- (3))
   ELSEIF (sbr_current_qual=1)
    IF ((((ui_query_rec->usage="VERSION")
     AND sbr_temp_pk_value != 0) OR ((ui_query_rec->usage != "VERSION"))) )
     SET sbr_temp_pk_value = ui_query_eval_rec->qual[sbr_eval_loop].root_entity_attr
     SET select_merge_translate_rec->type = "TO"
     SET sbr_trans_val = select_merge_translate(cnvtstring(sbr_temp_pk_value),sbr_table_name)
     SET select_merge_translate_rec->type = "FROM"
     IF (sbr_trans_val="No Trans")
      SET sbr_root_entity_attr_val = value(ui_query_eval_rec->qual[sbr_eval_loop].root_entity_attr)
      RETURN(sbr_root_entity_attr_val)
     ELSE
      IF ((ui_query_rec->usage="VERSION"))
       SET sbr_root_entity_attr_val = value(ui_query_eval_rec->qual[sbr_eval_loop].root_entity_attr)
       RETURN(sbr_root_entity_attr_val)
      ELSE
       RETURN(- (3))
      ENDIF
     ENDIF
    ELSE
     SET sbr_root_entity_attr_val = value(ui_query_eval_rec->qual[sbr_eval_loop].root_entity_attr)
     RETURN(sbr_root_entity_attr_val)
    ENDIF
   ELSE
    IF ((ui_query_rec->usage="VERSION"))
     RETURN(- (2))
    ELSE
     FOR (sbr_eval_loop = 1 TO sbr_current_qual)
       SET sbr_temp_pk_value = ui_query_eval_rec->qual[sbr_eval_loop].root_entity_attr
       SET select_merge_translate_rec->type = "TO"
       SET sbr_trans_val = select_merge_translate(cnvtstring(sbr_temp_pk_value),sbr_table_name)
       IF (sbr_trans_val="No Trans")
        SET sbr_not_translated_count = (sbr_not_translated_count+ 1)
        SET sbr_val_pos = sbr_eval_loop
       ENDIF
     ENDFOR
     SET select_merge_translate_rec->type = "FROM"
     IF (sbr_not_translated_count=0)
      RETURN(- (3))
     ELSEIF (sbr_not_translated_count=1)
      SET current_qual = ui_query_eval_rec->qual[sbr_val_pos].root_entity_attr
      RETURN(current_qual)
     ELSE
      RETURN(- (2))
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE insert_update_row(iur_temp_tbl_cnt,iur_perm_col_cnt)
   DECLARE first_where = i2
   DECLARE active_in = i2
   DECLARE drdm_col_name = vc
   DECLARE drdm_table_name = vc
   DECLARE p_tab_ind = i2
   DECLARE sbr_data_type = vc
   DECLARE no_update_ind = i2
   DECLARE non_key_ind = i2
   DECLARE pk_cnt = i4
   DECLARE iur_tgt_pk_where = vc
   DECLARE iur_del_loop = i4
   DECLARE iur_del_ind = i2
   DECLARE iur_child_loop = i4
   DECLARE iur_child_pk_cnt = i4
   DECLARE src_pk_where = vc
   DECLARE iur_tbl_alias = vc
   SET iur_del_ind = 0
   SET drdm_table_name = concat("RS_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix)
   SET dm_err->eproc = concat("Inserting or Updating Row ",cnvtstring(drdm_chg->log[drdm_log_loop].
     log_id))
   CALL echo("")
   CALL echo("")
   CALL echo("*******************INSERTING OR UPDATING ROW******************")
   CALL echo("")
   CALL echo("")
   IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].merge_delete_ind=1)
    AND (drdm_chg->log[drdm_log_loop].md_delete_ind=1))
    IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].parent_flag=2))
     SET drdm_parser_cnt = 1
     FOR (iur_child_loop = 1 TO size(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].parent_qual,5))
       SET drdm_parser->statement[1].frag = concat("delete from ",dm2_ref_data_doc->tbl_qual[
        iur_temp_tbl_cnt].parent_qual[iur_child_loop].child_name," where ")
       IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].parent_qual[iur_child_loop].parent_tab_col
        != ""))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat(dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].parent_qual[iur_child_loop].parent_tab_col," = '",dm2_ref_data_doc->
         tbl_qual[iur_temp_tbl_cnt].table_name,"' and ")
       ENDIF
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(dm2_ref_data_doc->tbl_qual[
        iur_temp_tbl_cnt].parent_qual[iur_child_loop].parent_id_col," in (select ")
       FOR (iur_del_loop = 1 TO perm_col_cnt)
         IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].pk_ind=1))
          SET iur_child_pk_cnt = (iur_child_pk_cnt+ 1)
          IF (iur_child_pk_cnt=1)
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" c.",dm2_ref_data_doc->
            tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name)
          ENDIF
         ENDIF
       ENDFOR
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" from ",dm2_ref_data_doc->tbl_qual[
        iur_temp_tbl_cnt].table_name," c where ")
       FOR (iur_del_loop = 1 TO perm_col_cnt)
         IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].merge_delete_ind=1)
         )
          IF (iur_del_ind=1)
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = " and "
          ENDIF
          IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="DQ8"))
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
            iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, rs_",
            dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
            tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
          ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="VC"
          ))
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
            iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, evaluate(",
            trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
              check_space)),", 1, ' ', 0,rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,
            "->to_values.",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
            column_name,
            "))")
          ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="C*"
          ))
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
            iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, evaluate(",
            trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
              check_space)),", 1, ' ', 0,notrim(rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].
            suffix,"->to_values.",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop]
            .column_name,
            ")))")
          ELSE
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
            iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, rs_",
            dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
            tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
          ENDIF
          SET iur_del_ind = 1
         ENDIF
       ENDFOR
       FOR (iur_del_loop = 1 TO perm_col_cnt)
         IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].pk_ind=1)
          AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name=dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].root_entity_name)
          AND dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name
          AND dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].root_entity_attr)
          SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" and c.",dm2_ref_data_doc->
           tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," != 0 ")
         ENDIF
       ENDFOR
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = ") with nocounter go"
       IF (iur_del_ind=1
        AND iur_child_pk_cnt=1)
        CALL parse_statements(drdm_parser_cnt)
        IF (drdm_mini_loop_status="NOMV08")
         CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV08")
         COMMIT
         RETURN(1)
        ENDIF
       ENDIF
     ENDFOR
     SET iur_del_ind = 0
     SET iur_child_pk_cnt = 0
    ENDIF
    SET drdm_parser->statement[1].frag = concat("delete from ",dm2_ref_data_doc->tbl_qual[
     iur_temp_tbl_cnt].table_name," c where ")
    SET drdm_parser_cnt = 1
    FOR (iur_del_loop = 1 TO perm_col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].merge_delete_ind=1))
       IF (iur_del_ind=1)
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = " and "
       ENDIF
       IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="DQ8"))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, rs_",
         dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
         tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
       ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="VC"))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, evaluate(",
         trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
           check_space)),", 1, ' ', 0,rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,
         "->to_values.",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
         column_name,
         "))")
       ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="C*"))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, evaluate(",
         trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
           check_space)),", 1, ' ', 0,notrim(rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,
         "->to_values.",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
         column_name,
         ")))")
       ELSE
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, rs_",
         dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
         tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
       ENDIF
       SET iur_del_ind = 1
      ENDIF
    ENDFOR
    FOR (iur_del_loop = 1 TO perm_col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].pk_ind=1)
       AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name=dm2_ref_data_doc->tbl_qual[
      iur_temp_tbl_cnt].col_qual[iur_del_loop].root_entity_name)
       AND dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name
       AND dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].root_entity_attr)
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" and c.",dm2_ref_data_doc->
        tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," != 0 ")
      ENDIF
    ENDFOR
    SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
    SET drdm_parser->statement[drdm_parser_cnt].frag = "with nocounter go"
    CALL parse_statements(drdm_parser_cnt)
    IF (drdm_mini_loop_status="NOMV08")
     CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV08")
     COMMIT
     RETURN(1)
    ENDIF
   ENDIF
   SET iur_del_ind = 0
   IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].merge_delete_ind=1))
    IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].parent_flag=2))
     SET drdm_parser_cnt = 1
     FOR (iur_child_loop = 1 TO size(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].parent_qual,5))
       SET drdm_parser->statement[1].frag = concat("delete from ",dm2_ref_data_doc->tbl_qual[
        iur_temp_tbl_cnt].parent_qual[iur_child_loop].child_name," where ")
       IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].parent_qual[iur_child_loop].parent_tab_col
        != ""))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat(dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].parent_qual[iur_child_loop].parent_tab_col," = '",dm2_ref_data_doc->
         tbl_qual[iur_temp_tbl_cnt].table_name,"' and ")
       ENDIF
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(dm2_ref_data_doc->tbl_qual[
        iur_temp_tbl_cnt].parent_qual[iur_child_loop].parent_id_col," = ")
       FOR (iur_del_loop = 1 TO perm_col_cnt)
         IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].pk_ind=1))
          IF (iur_del_ind >= 1)
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = " and "
          ENDIF
          IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="DQ8"))
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",
            dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
          ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="VC"
          ))
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, evaluate(",trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].
              col_qual[iur_del_loop].check_space)),", 1, ' ', 0,rs_",
            dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
            tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,"))")
          ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="C*"
          ))
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, evaluate(",trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].
              col_qual[iur_del_loop].check_space)),", 1, ' ', 0,notrim(rs_",
            dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
            tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")))")
          ELSE
           SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" evaluate(",trim(cnvtstring(
              dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
            ", 1, NULL, 0, rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",
            dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
          ENDIF
          SET iur_del_ind = (iur_del_ind+ 1)
         ENDIF
       ENDFOR
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = " with nocounter go"
       IF (iur_del_ind=1)
        CALL parse_statements(drdm_parser_cnt)
        IF (drdm_mini_loop_status="NOMV08")
         CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV08")
         COMMIT
         RETURN(1)
        ENDIF
       ENDIF
     ENDFOR
     SET iur_del_ind = 0
    ENDIF
    SET drdm_parser->statement[1].frag = concat("delete from ",dm2_ref_data_doc->tbl_qual[
     iur_temp_tbl_cnt].table_name," c where ")
    SET drdm_parser_cnt = 1
    FOR (iur_del_loop = 1 TO perm_col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].pk_ind=1))
       IF (iur_del_ind=1)
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = " and "
       ENDIF
       IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="DQ8"))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, rs_",
         dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
         tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
       ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="VC"))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, evaluate(",
         trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
           check_space)),", 1, ' ', 0,rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,
         "->to_values.",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
         column_name,
         "))")
       ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].data_type="C*"))
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, evaluate(",
         trim(cnvtstring(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
           check_space)),", 1, ' ', 0,notrim(rs_",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,
         "->to_values.",dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].
         column_name,
         ")))")
       ELSE
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat("c.",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," =evaluate(",trim(cnvtstring(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].check_null)),
         ", 1, NULL, 0, rs_",
         dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix,"->to_values.",dm2_ref_data_doc->
         tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name,")")
       ENDIF
       SET iur_del_ind = 1
      ENDIF
    ENDFOR
    FOR (iur_del_loop = 1 TO perm_col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].pk_ind=1)
       AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name=dm2_ref_data_doc->tbl_qual[
      iur_temp_tbl_cnt].col_qual[iur_del_loop].root_entity_name)
       AND dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name
       AND dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].root_entity_attr)
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" and c.",dm2_ref_data_doc->
        tbl_qual[iur_temp_tbl_cnt].col_qual[iur_del_loop].column_name," != 0 ")
      ENDIF
    ENDFOR
    SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
    SET drdm_parser->statement[drdm_parser_cnt].frag = "with nocounter go"
    CALL parse_statements(drdm_parser_cnt)
    IF (drdm_mini_loop_status="NOMV08")
     CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV08")
     COMMIT
     RETURN(1)
    ENDIF
   ENDIF
   IF (nodelete_ind=1)
    RETURN(1)
   ENDIF
   SET p_tab_ind = 0
   SET first_where = 0
   SET no_update_ind = 0
   SET short_string = ""
   SET drdm_parser->statement[1].frag = concat("select into 'NL:' from ",value(dm2_ref_data_doc->
     tbl_qual[iur_temp_tbl_cnt].table_name)," dc where ")
   SET drdm_parser_cnt = 2
   IF ((((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].merge_delete_ind=0)) OR ((dm2_ref_data_doc->
   tbl_qual[iur_temp_tbl_cnt].lob_process_type="LOB_LOB"))) )
    SET pk_cnt = 0
    FOR (ins_upd_loop = 1 TO iur_perm_col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].pk_ind=1))
       SET pk_cnt = (pk_cnt+ 1)
       SET sbr_data_type = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].
       data_type
       SET drdm_col_name = value(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].
        column_name)
       SET drdm_from_con = concat(drdm_table_name,"->To_values.",drdm_col_name)
       IF (drdm_parser_cnt > 2)
        SET iur_tgt_pk_where = concat(iur_tgt_pk_where," and ")
        SET drdm_parser->statement[drdm_parser_cnt].frag = " and "
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       ENDIF
       IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].check_null=1)
        AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].nullable="Y"))
        IF (sbr_data_type IN ("DQ8", "I4", "F8", "I2"))
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = null")
        ELSE
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" (dc.",drdm_col_name,
          " = null or dc.",drdm_col_name," = ' ')")
        ENDIF
        SET iur_tgt_pk_where = concat(iur_tgt_pk_where,drdm_parser->statement[drdm_parser_cnt].frag)
       ELSEIF (sbr_data_type="DQ8")
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name,
         " = cnvtdatetime(",drdm_from_con,")")
        SET iur_tgt_pk_where = concat(iur_tgt_pk_where,drdm_parser->statement[drdm_parser_cnt].frag)
       ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].check_space=1))
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" (dc.",drdm_col_name,
         " = null or dc.",drdm_col_name," = ' ')")
        SET iur_tgt_pk_where = concat(iur_tgt_pk_where,drdm_parser->statement[drdm_parser_cnt].frag)
       ELSE
        SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = ",
         drdm_from_con)
        SET iur_tgt_pk_where = concat(iur_tgt_pk_where,drdm_parser->statement[drdm_parser_cnt].frag)
       ENDIF
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ELSE
       SET non_key_ind = 1
      ENDIF
    ENDFOR
    IF (pk_cnt=0)
     SET nodelete_ind = 1
     SET dm_err->emsg = "The table has no primary_key information, check to see if it is mergeable."
    ELSE
     SET drdm_parser->statement[drdm_parser_cnt].frag = " go"
     CALL parse_statements(drdm_parser_cnt)
    ENDIF
   ENDIF
   IF (curqual > 0
    AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].merge_delete_ind=0))
    IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].insert_only_ind=1))
     CALL merge_audit("FAILREASON",
      "This table is marked as insert only, so this row will not be updated.",3)
     RETURN(0)
    ELSE
     IF (new_seq_ind=1
      AND drdm_override_ind=0)
      SET no_update_ind = 1
      CALL merge_audit("FAILREASON",
       "A new sequence was created for the table, but the sequence value already exists in the target table",
       3)
      SET nodelete_ind = 1
      SET drdm_mini_loop_status = "NOMV99"
     ELSE
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name != "PERSON")
       AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name != "PERSON4859"))
       IF (non_key_ind=1)
        SET drdm_parser->statement[1].frag = concat("update into ",dm2_ref_data_doc->tbl_qual[
         iur_temp_tbl_cnt].table_name,"  dc set ")
        SET drdm_parser_cnt = 2
        FOR (update_loop = 1 TO iur_perm_col_cnt)
          IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].db_data_type !=
          "*LOB"))
           IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].pk_ind=0))
            IF (drdm_parser_cnt > 2)
             SET drdm_parser->statement[drdm_parser_cnt].frag = ", "
             SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
            ENDIF
            SET drdm_col_name = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].
            column_name
            SET drdm_from_con = concat(drdm_table_name,"->to_values.",drdm_col_name)
            IF (drdm_col_name="ACTIVE_IND")
             IF (drdm_active_ind_merge=0)
              CALL parser(concat("set active_in = ",drdm_table_name,"->from_values.active_ind go"),1)
              IF (((active_in=0) OR ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[
              update_loop].exception_flg=8))) )
               IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].check_null=1)
                AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].nullable="Y")
               )
                SET drdm_parser->statement[drdm_parser_cnt].frag = " dc.ACTIVE_IND = null"
               ELSE
                SET drdm_parser->statement[drdm_parser_cnt].frag = " dc.ACTIVE_IND = active_in"
               ENDIF
              ELSE
               IF (((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_cnt - pk_cnt)=1))
                SET no_update_ind = 1
               ELSE
                IF (drdm_parser_cnt=2)
                 SET drdm_parser_cnt = (drdm_parser_cnt - 1)
                ELSE
                 SET drdm_parser_cnt = (drdm_parser_cnt - 2)
                ENDIF
               ENDIF
              ENDIF
             ELSE
              IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].check_null=1)
               AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].nullable="Y"))
               SET drdm_parser->statement[drdm_parser_cnt].frag = " dc.ACTIVE_IND = null"
              ELSE
               SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.ACTIVE_IND = ",
                drdm_from_con)
              ENDIF
             ENDIF
            ELSEIF (drdm_col_name="UPDT_TASK")
             SET drdm_parser->statement[drdm_parser_cnt].frag = " dc.UPDT_TASK = 4310001"
            ELSEIF (drdm_col_name="UPDT_DT_TM")
             SET drdm_parser->statement[drdm_parser_cnt].frag =
             " dc.UPDT_DT_TM = cnvtdatetime(curdate, curtime3)"
            ELSEIF (drdm_col_name="UPDT_CNT")
             SET drdm_parser->statement[drdm_parser_cnt].frag = "dc.UPDT_CNT = dc.UPDT_CNT + 1"
            ELSE
             IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].check_null=1)
              AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].nullable="Y"))
              SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name,
               " = null")
             ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].data_type=
             "DQ8"))
              SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name,
               " = cnvtdatetime(",drdm_from_con,")")
             ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[update_loop].check_space=
             1))
              SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = ' '"
               )
             ELSE
              SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = ",
               drdm_from_con)
             ENDIF
            ENDIF
            SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
           ENDIF
          ENDIF
        ENDFOR
        IF (no_update_ind=0)
         SET drdm_parser->statement[drdm_parser_cnt].frag = " where "
         SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
         SET drdm_parser->statement[drdm_parser_cnt].frag = iur_tgt_pk_where
         SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        ENDIF
        SET current_merges = (current_merges+ 1)
        SET child_merge_audit->num[current_merges].action = "UPDATE"
        SET child_merge_audit->num[current_merges].text = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt
        ].table_name
       ENDIF
       SET ins_ind = 0
      ELSE
       SET p_tab_ind = 1
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET ins_ind = 1
    SET drdm_parser->statement[1].frag = concat("insert into ",dm2_ref_data_doc->tbl_qual[
     iur_temp_tbl_cnt].table_name," dc set ")
    SET drdm_parser_cnt = 2
    FOR (insert_loop = 1 TO iur_perm_col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].db_data_type != "*LOB")
      )
       SET drdm_col_name = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].
       column_name
       SET drdm_from_con = concat(drdm_table_name,"->to_values.",drdm_col_name)
       IF (drdm_parser_cnt > 2)
        SET drdm_parser->statement[drdm_parser_cnt].frag = ", "
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       ENDIF
       IF (drdm_col_name="UPDT_TASK")
        SET drdm_parser->statement[drdm_parser_cnt].frag = " dc.UPDT_TASK = 4310001"
       ELSEIF (drdm_col_name="UPDT_DT_TM")
        SET drdm_parser->statement[drdm_parser_cnt].frag =
        " dc.UPDT_DT_TM = cnvtdatetime(curdate, curtime3)"
       ELSEIF (drdm_col_name="UPDT_CNT")
        SET drdm_parser->statement[drdm_parser_cnt].frag = "dc.UPDT_CNT = 0"
       ELSE
        IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].check_null=1)
         AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].nullable="Y"))
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = null ")
        ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].data_type="DQ8"))
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name,
          " = cnvtdatetime(",drdm_from_con,")")
        ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].check_space=1))
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = ' '")
        ELSE
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",drdm_col_name," = ",
          drdm_from_con)
        ENDIF
       ENDIF
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ENDIF
    ENDFOR
    SET current_merges = (current_merges+ 1)
    SET child_merge_audit->num[current_merges].action = "INSERT"
    SET child_merge_audit->num[current_merges].text = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].
    table_name
   ENDIF
   SET drdm_parser->statement[drdm_parser_cnt].frag = " go"
   IF (p_tab_ind=0
    AND no_update_ind=0)
    IF (ins_ind=0
     AND non_key_ind=0)
     CALL echo("No update will be done on this table because there are no non-key columns")
    ELSE
     CALL parse_statements(drdm_parser_cnt)
     IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].lob_process_type="LOB_LOB"))
      SET drdm_parser->statement[1].frag = concat("update into ",dm2_ref_data_doc->tbl_qual[
       iur_temp_tbl_cnt].table_name," dc set ")
      SET drdm_parser_cnt = 2
      FOR (insert_loop = 1 TO iur_perm_col_cnt)
        IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[insert_loop].db_data_type="*LOB"))
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" dc.",dm2_ref_data_doc->tbl_qual[
          iur_temp_tbl_cnt].col_qual[insert_loop].column_name," = (select ")
         SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" ",dm2_rdds_get_tbl_alias(
           dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix),".",dm2_ref_data_doc->tbl_qual[
          iur_temp_tbl_cnt].col_qual[insert_loop].column_name)
         SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
        ENDIF
      ENDFOR
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" from ",dm2_get_rdds_tname(
        dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name)," ",dm2_rdds_get_tbl_alias(
        dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].suffix)," where ")
      SET iur_tbl_alias = concat(" ",dm2_rdds_get_tbl_alias(dm2_ref_data_doc->tbl_qual[
        iur_temp_tbl_cnt].suffix))
      SET src_pk_where = " "
      SET pk_cnt = 0
      SET iur_perm_col_cnt = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_cnt
      FOR (ins_upd_loop = 1 TO iur_perm_col_cnt)
        IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].pk_ind=1))
         SET pk_cnt = (pk_cnt+ 1)
         SET sbr_data_type = dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].
         data_type
         SET drdm_col_name = value(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop
          ].column_name)
         SET drdm_from_con = concat(drdm_table_name,"->from_values.",drdm_col_name)
         IF (pk_cnt > 1)
          SET iur_tgt_pk_where = concat(src_pk_where," and ")
         ENDIF
         IF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].check_null=1)
          AND (dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].nullable="Y"))
          IF (sbr_data_type IN ("DQ8", "I4", "F8", "I2"))
           SET src_pk_where = concat(src_pk_where,iur_tbl_alias,".",drdm_col_name," = null")
          ELSE
           SET src_pk_where = concat(src_pk_where," (",iur_tbl_alias,".",drdm_col_name,
            " = null or ",iur_tbl_alias,".",drdm_col_name," = ' ')")
          ENDIF
         ELSEIF (sbr_data_type="DQ8")
          SET src_pk_where = concat(src_pk_where,iur_tbl_alias,".",drdm_col_name," = cnvtdatetime(",
           drdm_from_con,")")
         ELSEIF ((dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].col_qual[ins_upd_loop].check_space=1))
          SET src_pk_where = concat(src_pk_where," (",iur_tbl_alias,".",drdm_col_name,
           iur_tbl_alias,".",drdm_col_name," = ' ')")
         ELSE
          SET src_pk_where = concat(src_pk_where,iur_tbl_alias,".",drdm_col_name," = ",
           drdm_from_con)
         ENDIF
        ENDIF
      ENDFOR
      IF (pk_cnt=0)
       SET nodelete_ind = 1
       SET dm_err->emsg =
       "The table has no primary_key information, check to see if it is mergeable."
       RETURN(1)
      ENDIF
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(src_pk_where,")")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" where ",iur_tgt_pk_where,
       " with nocounter go")
      CALL parse_statements(drdm_parser_cnt)
     ENDIF
    ENDIF
   ENDIF
   FREE SET first_where
   FREE SET p_tab_ind
   FREE SET active_in
   FREE SET drdm_table_name
   IF (nodelete_ind=1)
    IF ((dm_err->ecode=288))
     SET drdm_mini_loop_status = "NOMV02"
     CALL merge_audit("FAILREASON","The row recieved a constraint violation when merged into target",
      1)
     CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV02")
     COMMIT
    ELSEIF ((dm_err->ecode=284))
     IF (findstring("ORA-20500:",dm_err->emsg) > 0)
      SET drdm_mini_loop_status = "NOMV01"
      CALL merge_audit("FAILREASON","The row is related to a person that has been combined away",1)
      CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV01")
      COMMIT
     ENDIF
     IF (findstring("ORA-20100:",dm_err->emsg) > 0)
      SET drdm_mini_loop_status = "NOMV08"
      CALL merge_audit("FAILREASON","The row is trying to update the default row in target",1)
      CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[iur_temp_tbl_cnt].table_name,"NOMV08")
      COMMIT
     ENDIF
    ENDIF
    SET dm2_ref_data_reply->error_msg = dm_err->emsg
    SET dm2_ref_data_reply->error_ind = 1
    RETURN(1)
   ELSE
    SET drdm_chg->log[drdm_log_loop].reprocess_ind = 0
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE parse_statements(drdm_parser_cnt)
   FOR (parse_loop = 1 TO drdm_parser_cnt)
     IF (parse_loop=drdm_parser_cnt)
      SET drdm_go_ind = 1
     ELSE
      SET drdm_go_ind = 0
     ENDIF
     IF ((drdm_parser->statement[parse_loop].frag=""))
      CALL echo("")
      CALL echo("")
      CALL echo("A DYNAMIC STATEMENT WAS IMPROPERLY LOADED")
      CALL echo("")
      CALL echo("")
     ENDIF
     CALL parser(drdm_parser->statement[parse_loop].frag,drdm_go_ind)
     SET drdm_parser->statement[parse_loop].frag = ""
     IF (check_error(dm_err->eproc)=1)
      IF (findstring("ORA-20100:",dm_err->emsg) > 0)
       SET drdm_mini_loop_status = "NOMV08"
       CALL merge_audit("FAILREASON",
        "The row is trying to update/insert/delete the default row in target",1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
      ELSE
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
       SET nodelete_ind = 1
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE dm_translate(sbr_tbl_name,sbr_col_name,sbr_from_val)
   DECLARE to_val = vc
   DECLARE index_var = i4
   DECLARE dt_temp_tbl_cnt = i4
   DECLARE dt_temp_col_cnt = i4
   SET to_val = "NOXLAT"
   SET dt_temp_tbl_cnt = locateval(index_var,1,perm_tbl_cnt,sbr_tbl_name,dm2_ref_data_doc->tbl_qual[
    index_var].table_name)
   SET dt_temp_col_cnt = locateval(index_var,1,perm_col_cnt,sbr_col_name,dm2_ref_data_doc->tbl_qual[
    dt_temp_tbl_cnt].col_qual[index_var].column_name)
   SET to_val = select_merge_translate(sbr_from_val,dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].
    col_qual[dt_temp_col_cnt].root_entity_name)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
   ENDIF
   IF (to_val="No Trans")
    SET to_val = report_missing(dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt]
     .root_entity_name,dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].
     root_entity_attr,cnvtreal(sbr_from_val))
   ENDIF
   RETURN(to_val)
 END ;Subroutine
 SUBROUTINE dm_trans2(sbr_tbl_name,sbr_col_name,sbr_from_val,sbr_src_ind)
   DECLARE to_val = vc
   DECLARE index_var = i4
   DECLARE dt_temp_tbl_cnt = i4
   DECLARE dt_temp_col_cnt = i4
   IF (sbr_src_ind=0)
    SET to_val = "NOXLAT"
    SET dt_temp_tbl_cnt = locateval(index_var,1,perm_tbl_cnt,sbr_tbl_name,dm2_ref_data_doc->tbl_qual[
     index_var].table_name)
    SET dt_temp_col_cnt = locateval(index_var,1,perm_col_cnt,sbr_col_name,dm2_ref_data_doc->tbl_qual[
     dt_temp_tbl_cnt].col_qual[index_var].column_name)
    IF ((dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].exception_flg=1))
     RETURN(sbr_from_val)
    ELSE
     IF ((dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].root_entity_name IN (
     "", " ")))
      SET to_val = "BADLOG"
     ELSE
      IF ((dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].root_entity_name=
      "PERSON")
       AND (dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].table_name != "PRSNL"))
       SET dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].root_entity_name =
       "PRSNL"
      ENDIF
      SET to_val = select_merge_translate(sbr_from_val,dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].
       col_qual[dt_temp_col_cnt].root_entity_name)
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
      ENDIF
      IF (to_val != "No Trans"
       AND findstring(".0",to_val)=0)
       SET to_val = concat(to_val,".0")
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET to_val = sbr_from_val
   ENDIF
   SET dt_root_tbl_cnt = locateval(index_var,1,perm_tbl_cnt,dm2_ref_data_doc->tbl_qual[
    dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].root_entity_name,dm2_ref_data_doc->tbl_qual[index_var]
    .table_name)
   IF ((dm2_ref_data_doc->tbl_qual[dt_root_tbl_cnt].mergeable_ind=0))
    SET to_val = "NOMV04"
   ENDIF
   IF (to_val="No Trans")
    SET to_val = report_missing(dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt]
     .root_entity_name,dm2_ref_data_doc->tbl_qual[dt_temp_tbl_cnt].col_qual[dt_temp_col_cnt].
     root_entity_attr,cnvtreal(sbr_from_val))
   ENDIF
   RETURN(to_val)
 END ;Subroutine
 SUBROUTINE select_merge_translate(sbr_f_value,sbr_t_name)
   DECLARE sbr_return_val = vc
   DECLARE drdm_dmt_scr = vc
   DECLARE except_tab = vc
   DECLARE smt_loop = i4
   DECLARE smt_tbl_pos = i4
   DECLARE smt_seq_name = vc
   DECLARE smt_seq_num = f8
   DECLARE smt_cur_table = i4
   DECLARE smt_seq_loop = i4
   DECLARE smt_seq_val = i4
   DECLARE smt_xlat_env_tgt_id = f8
   SET smt_xlat_env_tgt_id = dm2_ref_data_doc->mock_target_id
   SET sbr_return_val = "No Trans"
   SET except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   SET smt_tbl_pos = locateval(smt_loop,1,dm2_ref_data_doc->tbl_cnt,sbr_t_name,dm2_ref_data_doc->
    tbl_qual[smt_loop].table_name)
   IF (smt_tbl_pos=0)
    SET smt_cur_table = temp_tbl_cnt
    SET smt_tbl_pos = fill_rs("TABLE",sbr_t_name)
    SET temp_tbl_cnt = smt_cur_table
   ENDIF
   IF (smt_tbl_pos=0)
    RETURN(sbr_return_val)
   ENDIF
   IF ((dm2_ref_data_doc->tbl_qual[smt_tbl_pos].skip_seqmatch_ind != 1))
    IF (sbr_t_name="REF_TEXT_RELTN")
     SET smt_seq_name = "REFERENCE_SEQ"
    ELSE
     FOR (smt_loop = 1 TO dm2_ref_data_doc->tbl_qual[smt_tbl_pos].col_cnt)
       IF ((dm2_ref_data_doc->tbl_qual[smt_tbl_pos].col_qual[smt_loop].pk_ind=1)
        AND (dm2_ref_data_doc->tbl_qual[smt_tbl_pos].col_qual[smt_loop].root_entity_name=sbr_t_name))
        SET smt_seq_name = dm2_ref_data_doc->tbl_qual[smt_tbl_pos].col_qual[smt_loop].sequence_name
       ENDIF
     ENDFOR
    ENDIF
    IF (smt_seq_name="")
     CALL disp_msg("No Valid sequence was found",dm_err->logfile,1)
     SET dm2_ref_data_reply->error_ind = 1
     SET dm2_ref_data_reply->error_msg = "No Valid sequence was found"
     SET dm_err->err_ind = 0
     CALL merge_audit("FAILREASON","No Valid sequence was found",3)
     RETURN(sbr_return_val)
    ENDIF
    SET smt_seq_val = locateval(smt_seq_loop,1,size(drdm_sequence->qual,5),smt_seq_name,drdm_sequence
     ->qual[smt_seq_loop].seq_name)
    IF (smt_seq_val=0)
     SELECT
      IF ((dm2_rdds_rec->mode="OS"))
       WHERE d.info_domain="MERGE00SEQMATCH"
        AND d.info_name=smt_seq_name
      ELSE
       WHERE d.info_domain=concat("MERGE",trim(cnvtstring(dm2_ref_data_doc->env_source_id)),trim(
         cnvtstring(smt_xlat_env_tgt_id)),"SEQMATCH")
        AND d.info_name=smt_seq_name
      ENDIF
      INTO "NL:"
      FROM dm_info d
      DETAIL
       smt_seq_num = d.info_number
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm2_ref_data_reply->error_ind = 1
      SET dm2_ref_data_reply->error_msg = dm_err->emsg
      SET dm_err->err_ind = 0
     ENDIF
     IF (((curqual=0) OR ((smt_seq_num=- (1)))) )
      SET smt_cur_table = temp_tbl_cnt
      EXECUTE dm2_find_sequence_match smt_seq_name, dm2_ref_data_doc->env_source_id
      SET temp_tbl_cnt = smt_cur_table
      IF ((dm_err->err_ind=1))
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm2_ref_data_reply->error_ind = 1
       SET dm2_ref_data_reply->error_msg = dm_err->emsg
       SET dm_err->err_ind = 1
       SET drdm_error_ind = 1
       RETURN(sbr_return_val)
      ENDIF
      SELECT
       IF ((dm2_rdds_rec->mode="OS"))
        WHERE d.info_domain="MERGE00SEQMATCH"
         AND d.info_name=smt_seq_name
       ELSE
        WHERE d.info_domain=concat("MERGE",trim(cnvtstring(dm2_ref_data_doc->env_source_id)),trim(
          cnvtstring(smt_xlat_env_tgt_id)),"SEQMATCH")
         AND d.info_name=smt_seq_name
       ENDIF
       INTO "NL:"
       FROM dm_info d
       DETAIL
        smt_seq_num = d.info_number
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm2_ref_data_reply->error_ind = 1
       SET dm2_ref_data_reply->error_msg = dm_err->emsg
      ENDIF
      IF (curqual=0)
       SET drdm_error_out_ind = 1
       SET dm2_ref_data_reply->error_ind = 1
       SET dm2_ref_data_reply->error_msg = "A sequence match could not be found in DM_INFO"
       CALL disp_msg("A sequence match could not be found in DM_INFO",dm_err->logfile,1)
       RETURN("No Trans")
      ENDIF
     ENDIF
     SET stat = alterlist(drdm_sequence->qual,(size(drdm_sequence->qual,5)+ 1))
     SET drdm_sequence->qual[size(drdm_sequence->qual,5)].seq_name = smt_seq_name
     SET drdm_sequence->qual[size(drdm_sequence->qual,5)].seq_val = smt_seq_num
    ELSE
     SET smt_seq_num = drdm_sequence->qual[smt_seq_val].seq_val
    ENDIF
   ELSE
    SET smt_seq_num = 0
   ENDIF
   IF (cnvtreal(sbr_f_value) <= smt_seq_num)
    RETURN(sbr_f_value)
   ELSE
    SELECT
     IF ( NOT (sbr_t_name IN ("PRSNL", "PERSON"))
      AND (select_merge_translate_rec->type != "TO"))
      WHERE dm.from_value=cnvtreal(sbr_f_value)
       AND dm.table_name=sbr_t_name
       AND (dm.env_source_id=dm2_ref_data_doc->env_source_id)
       AND dm.env_target_id=smt_xlat_env_tgt_id
     ELSEIF (sbr_t_name IN ("PRSNL", "PERSON")
      AND (select_merge_translate_rec->type != "TO"))
      WHERE dm.from_value=cnvtreal(sbr_f_value)
       AND dm.table_name IN ("PRSNL", "PERSON")
       AND (dm.env_source_id=dm2_ref_data_doc->env_source_id)
       AND dm.env_target_id=smt_xlat_env_tgt_id
     ELSEIF ( NOT (sbr_t_name IN ("PRSNL", "PERSON"))
      AND (select_merge_translate_rec->type="TO"))
      WHERE dm.to_value=cnvtreal(sbr_f_value)
       AND dm.table_name=sbr_t_name
       AND (dm.env_source_id=dm2_ref_data_doc->env_source_id)
       AND dm.env_target_id=smt_xlat_env_tgt_id
     ELSEIF (sbr_t_name IN ("PRSNL", "PERSON")
      AND (select_merge_translate_rec->type="TO"))
      WHERE dm.to_value=cnvtreal(sbr_f_value)
       AND dm.table_name IN ("PRSNL", "PERSON")
       AND (dm.env_source_id=dm2_ref_data_doc->env_source_id)
       AND dm.env_target_id=smt_xlat_env_tgt_id
     ELSE
     ENDIF
     INTO "NL:"
     FROM dm_merge_translate dm
     DETAIL
      IF ((select_merge_translate_rec->type="TO"))
       sbr_return_val = cnvtstring(dm.from_value)
      ELSE
       sbr_return_val = cnvtstring(dm.to_value)
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm2_ref_data_reply->error_ind = 1
     SET dm2_ref_data_reply->error_msg = dm_err->emsg
     SET dm_err->err_ind = 0
    ENDIF
    IF (sbr_return_val="No Trans"
     AND (global_mover_rec->loop_back_ind=1))
     SET source_table_name = dm2_get_rdds_tname("DM_MERGE_TRANSLATE")
     SELECT
      IF ( NOT (sbr_t_name IN ("PRSNL", "PERSON"))
       AND (select_merge_translate_rec->type != "TO"))
       WHERE dm.to_value=cnvtreal(sbr_f_value)
        AND dm.table_name=sbr_t_name
        AND dm.env_source_id=smt_xlat_env_tgt_id
        AND (dm.env_target_id=dm2_ref_data_doc->env_source_id)
      ELSEIF (sbr_t_name IN ("PRSNL", "PERSON")
       AND (select_merge_translate_rec->type != "TO"))
       WHERE dm.to_value=cnvtreal(sbr_f_value)
        AND dm.table_name IN ("PRSNL", "PERSON")
        AND dm.env_source_id=smt_xlat_env_tgt_id
        AND (dm.env_target_id=dm2_ref_data_doc->env_source_id)
      ELSEIF ( NOT (sbr_t_name IN ("PRSNL", "PERSON"))
       AND (select_merge_translate_rec->type="TO"))
       WHERE dm.from_value=cnvtreal(sbr_f_value)
        AND dm.table_name=sbr_t_name
        AND dm.env_source_id=smt_xlat_env_tgt_id
        AND (dm.env_target_id=dm2_ref_data_doc->env_source_id)
      ELSEIF (sbr_t_name IN ("PRSNL", "PERSON")
       AND (select_merge_translate_rec->type="TO"))
       WHERE dm.from_value=cnvtreal(sbr_f_value)
        AND dm.table_name IN ("PRSNL", "PERSON")
        AND dm.env_source_id=smt_xlat_env_tgt_id
        AND (dm.env_target_id=dm2_ref_data_doc->env_source_id)
      ELSE
      ENDIF
      INTO "NL:"
      FROM (parser(source_table_name) dm)
      DETAIL
       IF ((select_merge_translate_rec->type != "TO"))
        sbr_return_val = cnvtstring(dm.from_value)
       ELSE
        sbr_return_val = cnvtstring(dm.to_value)
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm2_ref_data_reply->error_ind = 1
      SET dm2_ref_data_reply->error_msg = dm_err->emsg
      SET dm_err->err_ind = 0
     ENDIF
    ENDIF
   ENDIF
   IF (sbr_return_val != "No Trans")
    CALL rdds_del_except(sbr_t_name,cnvtreal(sbr_f_value))
   ENDIF
   RETURN(sbr_return_val)
 END ;Subroutine
 SUBROUTINE del_chg_log(sbr_table_name,sbr_log_type,sbr_target_id)
   FREE RECORD dcl_rec_parse
   RECORD dcl_rec_parse(
     1 qual[*]
       2 parse_stmts = vc
   )
   SET stat = alterlist(dcl_rec_parse->qual,3)
   DECLARE sbr_tname_flex = vc
   DECLARE sbr_flex_pos = i4
   DECLARE sbr_look_ahead = vc WITH noconstant(build(global_mover_rec->refchg_buffer,"MIN"))
   SET drdm_any_translated = 1
   SET dm_err->eproc = "Updating DM_CHG_LOG Table drdm_chg->log[drdm_log_loop].log_id"
   SET update_cnt = 0
   SET sbr_tname_flex = dm2_get_rdds_tname("DM_CHG_LOG")
   SET dcl_rec_parse->qual[1].parse_stmts = concat("select into 'nl:' from ",sbr_tname_flex)
   SET dcl_rec_parse->qual[2].parse_stmts = " d where log_id = drdm_chg->log[drdm_log_loop].log_id"
   SET dcl_rec_parse->qual[3].parse_stmts = " detail update_cnt = d.updt_cnt with nocounter go"
   EXECUTE dm_rdds_parse_stmts  WITH replace("REQUEST","DCL_REC_PARSE")
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
    SET nodelete_ind = 1
   ENDIF
   SET stat = alterlist(dcl_rec_parse->qual,0)
   SET stat = alterlist(dcl_rec_parse->qual,8)
   IF ((((update_cnt=drdm_chg->log[drdm_log_loop].updt_cnt)) OR (sbr_log_type="REFCHG")) )
    IF ((drdm_chg->log[drdm_log_loop].par_location > 0))
     SET sbr_flex_pos = drdm_chg->log[drdm_log_loop].par_location
    ELSE
     SET sbr_flex_pos = drdm_log_loop
    ENDIF
    SET dcl_rec_parse->qual[1].parse_stmts = concat(" update into ",sbr_tname_flex,
     " d1, (dummyt d with seq = size(drdm_pair_info->qual)) ")
    SET dcl_rec_parse->qual[2].parse_stmts = " set d1.log_type = sbr_log_type, "
    SET dcl_rec_parse->qual[3].parse_stmts = " d1.rdbhandle = NULL, "
    IF (sbr_log_type="REFCHG")
     SET dcl_rec_parse->qual[4].parse_stmts = concat(
      " d1.updt_dt_tm = cnvtlookahead(sbr_look_ahead, cnvtdatetime(curdate,curtime3)),")
    ELSE
     SET dcl_rec_parse->qual[4].parse_stmts = "d1.updt_dt_tm = cnvtdatetime(curdate,curtime3),"
    ENDIF
    SET dcl_rec_parse->qual[5].parse_stmts = concat(" d1.updt_cnt = d1.updt_cnt + 1 plan d where",
     " drdm_pair_info->qual[d.seq].log_id > 0 ")
    SET dcl_rec_parse->qual[6].parse_stmts = concat(" join d1 where d1.log_id = ",
     " drdm_pair_info->qual[d.seq].log_id")
    IF (sbr_log_type="REFCHG")
     SET dcl_rec_parse->qual[7].parse_stmts = " and d1.log_type = 'PROCES'"
    ELSE
     SET dcl_rec_parse->qual[7].parse_stmts = concat(" and d1.updt_cnt = ",
      " drdm_pair_info->qual[d.seq].updt_cnt")
    ENDIF
    SET dcl_rec_parse->qual[8].parse_stmts = " with nocounter go"
    EXECUTE dm_rdds_parse_stmts  WITH replace("REQUEST","DCL_REC_PARSE")
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
    ENDIF
   ELSE
    SET nodelete_msg = concat("Could not process log_id ",trim(cnvtstring(drdm_chg->log[drdm_log_loop
       ].log_id)),
     " because it has been updated since the mover picked it up. It will be merged next pass.")
    CALL echo("")
    CALL echo("")
    CALL echo(nodelete_msg)
    CALL echo("")
    CALL echo("")
    CALL merge_audit("FAILREASON",nodelete_msg,1)
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE insert_merge_translate(sbr_from,sbr_to,sbr_table)
   DECLARE imt_seq_name = vc
   DECLARE imt_seq_num = f8
   DECLARE imt_seq_loop = i4
   DECLARE imt_seq_cnt = i4
   DECLARE imt_rs_cnt = i4
   DECLARE imt_return = i2
   DECLARE imt_except_tab = vc
   DECLARE imt_pk_pos = i4
   DECLARE imt_xlat_env_tgt_id = f8
   SET imt_xlat_env_tgt_id = dm2_ref_data_doc->mock_target_id
   SET imt_return = 0
   SET dm_err->eproc = "Inserting Translation"
   IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].skip_seqmatch_ind=0))
    FOR (imt_seq_loop = 1 TO size(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual,5))
      IF ((sbr_table=dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[imt_seq_loop].root_entity_name
      )
       AND (dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[imt_seq_loop].pk_ind=1))
       SET imt_pk_pos = imt_seq_loop
       SET imt_seq_name = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[imt_seq_loop].
       sequence_name
      ENDIF
    ENDFOR
    SET imt_seq_cnt = locateval(imt_seq_loop,1,size(drdm_sequence->qual,5),imt_seq_name,drdm_sequence
     ->qual[imt_seq_loop].seq_name)
    SET imt_seq_num = drdm_sequence->qual[imt_seq_cnt].seq_val
    IF (sbr_to < imt_seq_num)
     SET imt_return = 1
    ENDIF
   ENDIF
   SELECT INTO "NL:"
    FROM dm_merge_translate dmt
    WHERE dmt.to_value=sbr_to
     AND concat(dmt.table_name,"")=sbr_table
     AND (dmt.env_source_id=dm2_ref_data_doc->env_source_id)
     AND dmt.env_target_id=imt_xlat_env_tgt_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET no_insert_update = 1
    SET dm_err->err_ind = 0
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET imt_return = 1
   ENDIF
   IF (imt_return=0)
    INSERT  FROM dm_merge_translate dm
     SET dm.from_value = sbr_from, dm.to_value = sbr_to, dm.table_name = sbr_table,
      dm.env_source_id = dm2_ref_data_doc->env_source_id, dm.status_flg = drdm_chg->log[drdm_log_loop
      ].status_flg, dm.log_id = drdm_chg->log[drdm_log_loop].log_id,
      dm.updt_dt_tm = cnvtdatetime(curdate,curtime3), dm.env_target_id = imt_xlat_env_tgt_id
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET nodelete_ind = 1
     SET no_insert_update = 1
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
    ELSE
     IF (nvp_commit_ind=1
      AND (global_mover_rec->one_pass_ind=0))
      COMMIT
     ENDIF
    ENDIF
    CALL rdds_del_except(sbr_table,sbr_from)
   ELSE
    ROLLBACK
    SET imt_except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
    IF (sbr_table IN ("DCP_FORMS_REF", "DCP_SECTION_REF"))
     UPDATE  FROM (parser(imt_except_tab) d)
      SET d.log_type = "BADTRN"
      WHERE d.table_name=sbr_table
       AND d.from_value=sbr_from
       AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
      WITH nocounter
     ;end update
    ELSE
     UPDATE  FROM (parser(imt_except_tab) d)
      SET d.log_type = "BADTRN"
      WHERE d.table_name=sbr_table
       AND (d.column_name=dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[imt_pk_pos].column_name)
       AND d.from_value=sbr_from
       AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
      WITH nocounter
     ;end update
    ENDIF
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET nodelete_ind = 1
     SET no_insert_update = 1
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
    ENDIF
    IF (curqual=0)
     IF (sbr_table IN ("DCP_FORMS_REF", "DCP_SECTION_REF"))
      INSERT  FROM (parser(imt_except_tab) d)
       SET d.log_type = "BADTRN", d.table_name = sbr_table, d.from_value = sbr_from,
        d.target_env_id = dm2_ref_data_doc->env_target_id
       WITH nocounter
      ;end insert
     ELSE
      INSERT  FROM (parser(imt_except_tab) d)
       SET d.log_type = "BADTRN", d.table_name = sbr_table, d.column_name = dm2_ref_data_doc->
        tbl_qual[temp_tbl_cnt].col_qual[imt_pk_pos].column_name,
        d.from_value = sbr_from, d.target_env_id = dm2_ref_data_doc->env_target_id
       WITH nocounter
      ;end insert
     ENDIF
    ENDIF
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET nodelete_ind = 1
     SET no_insert_update = 1
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
    ELSE
     COMMIT
    ENDIF
    SET nodelete_ind = 1
    SET no_insert_update = 1
    SET fail_merges = (fail_merges+ 1)
    SET fail_merge_audit->num[fail_merges].action = "FAILREASON"
    SET fail_merge_audit->num[fail_merges].text = "Preventing a 2 into 1 translation"
    CALL merge_audit(fail_merge_audit->num[fail_merges].action,fail_merge_audit->num[fail_merges].
     text,1)
    IF (drdm_error_out_ind=1)
     ROLLBACK
    ENDIF
   ENDIF
   RETURN(imt_return)
 END ;Subroutine
 SUBROUTINE find_p_e_col(sbr_p_e_name,sbr_p_e_col)
   DECLARE p_e_name = vc
   DECLARE r_e_name = vc
   DECLARE p_e_col = vc
   DECLARE tbl_loop = i4
   DECLARE kickout = i4
   DECLARE p_e_tbl_pos = i4
   DECLARE p_e_col_pos = i4
   DECLARE p_e_where_str = vc
   DECLARE pk_pos = i4
   DECLARE temp_name = vc
   DECLARE mult_cnt = i4
   DECLARE pk_num = i4
   DECLARE good_pk = i4
   DECLARE pk_name = vc
   DECLARE id_ind = i2
   DECLARE info_alias = vc
   DECLARE i_domain = vc
   DECLARE i_name = vc
   DECLARE p_e_dummy_cnt = i4
   DECLARE temp_r_e_name = vc
   SET p_e_name = "INVALIDTABLE"
   SET r_e_name = sbr_p_e_name
   SET info_alias = ""
   SET id_ind = 0
   SET pk_num = 0
   SET pk_name = ""
   SET good_pk = 0
   WHILE (p_e_name != r_e_name)
     SET p_e_name = r_e_name
     SET r_e_name = "INVALIDTABLE"
     SET pk_pos = 0
     SET pk_pos = locateval(tbl_loop,1,dguc_reply->rs_tbl_cnt,p_e_name,dguc_reply->dtd_hold[tbl_loop]
      .tbl_name)
     IF (pk_pos=0)
      SELECT INTO "NL:"
       FROM dtable d
       WHERE d.table_name=p_e_name
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET i_domain = concat("RDDS_PE_ABBREV:",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name)
       SET i_name = concat(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[sbr_p_e_col].
        parent_entity_col,":",p_e_name)
       SELECT INTO "NL:"
        FROM dm_info d
        WHERE d.info_domain="RDDS_PE_ABBREVIATIONS"
         AND d.info_name=p_e_name
        DETAIL
         info_alias = d.info_char
        WITH nocounter
       ;end select
       SELECT INTO "NL:"
        FROM dm_info d
        WHERE d.info_domain=i_domain
         AND d.info_name=i_name
        DETAIL
         info_alias = d.info_char
        WITH nocounter
       ;end select
       IF (info_alias="")
        SET p_e_name = "INVALIDTABLE"
        SET r_e_name = p_e_name
        CALL echo("Parent_entity_col could not be found")
       ELSE
        SET p_e_name = info_alias
        SET pk_pos = locateval(tbl_loop,1,dguc_reply->rs_tbl_cnt,p_e_name,dguc_reply->dtd_hold[
         tbl_loop].tbl_name)
        IF (pk_pos=0)
         SET p_e_name = "INVALIDTABLE"
         SET r_e_name = p_e_name
         CALL echo("Parent_entity_col could not be found")
        ENDIF
       ENDIF
      ELSE
       CALL echo(concat("The following table is activity: ",p_e_name))
       SET p_e_name = "INVALIDTABLE"
       SET r_e_name = p_e_name
      ENDIF
     ENDIF
     IF (pk_pos != 0)
      IF ((dguc_reply->dtd_hold[tbl_loop].pk_cnt > 1))
       FOR (mult_cnt = 1 TO dguc_reply->dtd_hold[tbl_loop].pk_cnt)
         IF ((((dguc_reply->dtd_hold[tbl_loop].pk_hold[mult_cnt].pk_name="*ID")) OR ((((dguc_reply->
         dtd_hold[tbl_loop].pk_hold[mult_cnt].pk_name="*CD")) OR ((dguc_reply->dtd_hold[tbl_loop].
         pk_hold[mult_cnt].pk_name="CODE_VALUE"))) )) )
          IF ((dguc_reply->dtd_hold[tbl_loop].pk_hold[mult_cnt].pk_name="*ID"))
           SET id_ind = 1
          ENDIF
          SET pk_num = (pk_num+ 1)
          SET good_pk = mult_cnt
         ENDIF
       ENDFOR
       IF (pk_num > 1)
        IF (id_ind=1)
         CALL echo("This Parent_Entity Table has more than a single Primary Key")
         SET p_e_name = "INVALIDTABLE"
         SET r_e_name = p_e_name
        ELSE
         SET pk_name = dguc_reply->dtd_hold[tbl_loop].pk_hold[good_pk].pk_name
        ENDIF
       ELSE
        SET pk_name = dguc_reply->dtd_hold[tbl_loop].pk_hold[good_pk].pk_name
       ENDIF
      ELSE
       SET pk_name = dguc_reply->dtd_hold[tbl_loop].pk_hold[1].pk_name
      ENDIF
      IF (p_e_name != "INVALIDTABLE")
       SET p_e_col = pk_name
       SET p_e_tbl_pos = 0
       SET p_e_tbl_pos = locateval(tbl_loop,1,dm2_ref_data_doc->tbl_cnt,p_e_name,dm2_ref_data_doc->
        tbl_qual[tbl_loop].table_name)
       IF (p_e_tbl_pos=0)
        SET p_e_dummy_cnt = temp_tbl_cnt
        SET p_e_tbl_pos = fill_rs("TABLE",p_e_name)
        SET temp_tbl_cnt = p_e_dummy_cnt
        IF (p_e_tbl_pos=0)
         CALL echo("Information not found for table level meta-data")
         SET p_e_name = "INVALIDTABLE"
         SET r_e_name = p_e_name
        ELSE
         SET temp_r_e_name = r_e_name
         FOR (p_e_dummy_cnt = 1 TO dm2_ref_data_doc->tbl_qual[p_e_tbl_pos].col_cnt)
           IF ((dm2_ref_data_doc->tbl_qual[p_e_tbl_pos].col_qual[p_e_dummy_cnt].column_name=p_e_col))
            SET r_e_name = dm2_ref_data_doc->tbl_qual[p_e_tbl_pos].col_qual[p_e_dummy_cnt].
            root_entity_name
           ENDIF
         ENDFOR
         IF (temp_r_e_name=r_e_name)
          CALL echo("Information not found for table level meta-data")
          SET p_e_name = "INVALIDTABLE"
          SET r_e_name = p_e_name
         ENDIF
        ENDIF
       ENDIF
       IF (p_e_tbl_pos != 0)
        SET p_e_col_pos = 0
        SET p_e_col_pos = locateval(tbl_loop,1,dm2_ref_data_doc->tbl_qual[p_e_tbl_pos].col_cnt,
         p_e_col,dm2_ref_data_doc->tbl_qual[p_e_tbl_pos].col_qual[tbl_loop].column_name)
        IF (p_e_col_pos=0)
         CALL echo("Information not found in dm_columns_doc for column")
         SET p_e_name = "INVALIDTABLE"
         SET r_e_name = p_e_name
        ELSE
         SET r_e_name = dm2_ref_data_doc->tbl_qual[p_e_tbl_pos].col_qual[p_e_col_pos].
         root_entity_name
        ENDIF
       ENDIF
       SET kickout = (kickout+ 1)
       IF (kickout=5)
        CALL echo("Searched through 5 Parent_entity_columns")
        SET p_e_name = "INVALIDTABLE"
        SET r_e_name = p_e_name
       ENDIF
      ENDIF
     ENDIF
   ENDWHILE
   IF (p_e_name="INVALIDTABLE")
    ROLLBACK
    SET drdm_mini_loop_status = "NOMV99"
    CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name,"NOMV99")
    COMMIT
   ENDIF
   RETURN(p_e_name)
 END ;Subroutine
 SUBROUTINE merge_audit(action,text,audit_type)
   DECLARE aud_seq = i4
   DECLARE ma_log_id = f8
   DECLARE ma_next_seq = f8
   DECLARE ma_del_ind = i2
   DECLARE ma_table_name = vc
   IF (drdm_log_level=1
    AND  NOT (action IN ("INSERT", "UPDATE", "FAILREASON", "BATCH END")))
    RETURN(null)
   ELSE
    SET ma_del_ind = 0
    SET ma_log_id = drdm_chg->log[drdm_log_loop].log_id
    IF (temp_tbl_cnt=0)
     SET ma_table_name = "NONE"
    ELSE
     SET ma_table_name = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name
    ENDIF
    IF ((((global_mover_rec->one_pass_ind=1)
     AND audit_type=1) OR ((global_mover_rec->one_pass_ind=0)
     AND audit_type < 3)) )
     ROLLBACK
    ENDIF
    SELECT INTO "NL:"
     y = seq(dm_merge_audit_seq,nextval)
     FROM dual
     DETAIL
      ma_next_seq = y
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
     SET drdm_error_out_ind = 1
    ELSE
     UPDATE  FROM dm_chg_log_audit dm
      SET dm.audit_dt_tm = cnvtdatetime(curdate,curtime3), dm.log_id = ma_log_id, dm.action = action,
       dm.text = text, dm.table_name = ma_table_name, dm.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE dm.dm_chg_log_audit_id=ma_next_seq
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm_err->err_ind = 0
      SET drdm_error_out_ind = 1
     ENDIF
     IF (curqual=0)
      INSERT  FROM dm_chg_log_audit dm
       SET dm.audit_dt_tm = cnvtdatetime(curdate,curtime3), dm.log_id = ma_log_id, dm.action = action,
        dm.text = text, dm.table_name = ma_table_name, dm.dm_chg_log_audit_id = ma_next_seq,
        dm.updt_dt_tm = cnvtdatetime(curdate,curtime3)
       WITH nocounter
      ;end insert
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
       SET drdm_error_out_ind = 1
      ENDIF
     ENDIF
    ENDIF
    IF ((((global_mover_rec->one_pass_ind=1)
     AND audit_type=1) OR ((global_mover_rec->one_pass_ind=0)
     AND audit_type < 3)) )
     IF (drdm_error_out_ind=0)
      COMMIT
     ENDIF
    ENDIF
    RETURN(1)
   ENDIF
   FREE SET aud_seq
   FREE SET ma_log_id
 END ;Subroutine
 SUBROUTINE report_missing(sbr_table_name,sbr_column_name,sbr_value)
   DECLARE except_tab = vc
   DECLARE except_log_type = vc
   DECLARE missing_cnt = i4
   DECLARE source_tab_name = vc
   DECLARE insert_log_type = vc
   SET except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   SET source_tab_name = dm2_get_rdds_tname(sbr_table_name)
   SET except_log_type = "NOXLAT"
   IF (sbr_table_name IN ("DCP_FORMS_REF", "DCP_SECTION_REF"))
    SET sbr_column_name = ""
   ENDIF
   SELECT
    IF (sbr_table_name IN ("DCP_FORMS_REF", "DCP_SECTION_REF"))
     WHERE (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.table_name=sbr_table_name
      AND d.from_value=sbr_value
    ELSE
     WHERE (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.table_name=sbr_table_name
      AND d.column_name=sbr_column_name
      AND d.from_value=sbr_value
    ENDIF
    INTO "NL:"
    FROM (parser(except_tab) d)
    DETAIL
     except_log_type = d.log_type
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET no_insert_update = 1
    SET drdm_error_out_ind = 1
    SET dm_err->err_ind = 0
   ELSE
    IF (curqual=0)
     CALL parser(concat("select into 'NL:' from ",source_tab_name," r "),0)
     IF (sbr_table_name="DCP_FORMS_REF")
      CALL parser(" where r.dcp_forms_ref_id = sbr_value or r.dcp_form_instance_id = sbr_value ",0)
     ELSEIF (sbr_table_name="DCP_SECTION_REF")
      CALL parser(" where r.dcp_section_ref_id = sbr_value or r.dcp_section_instance_id = sbr_value ",
       0)
     ELSE
      CALL parser(concat(" where r.",sbr_column_name," = sbr_value"),0)
     ENDIF
     CALL parser(" with nocounter go",1)
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET nodelete_ind = 1
      SET no_insert_update = 1
      SET drdm_error_out_ind = 1
      SET dm_err->err_ind = 0
     ELSE
      IF (curqual=0)
       SET except_log_type = "ORPHAN"
       INSERT  FROM (parser(except_tab) d)
        SET d.log_type = "ORPHAN", d.table_name = sbr_table_name, d.column_name = sbr_column_name,
         d.from_value = sbr_value, d.target_env_id = dm2_ref_data_doc->env_target_id
        WITH nocounter
       ;end insert
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        SET nodelete_ind = 1
        SET no_insert_update = 1
        SET drdm_error_out_ind = 1
        SET dm_err->err_ind = 0
       ENDIF
      ENDIF
     ENDIF
     SET missing_cnt = add_rs_values(sbr_table_name,sbr_column_name,sbr_value)
     IF (missing_cnt > 0)
      IF (except_log_type="ORPHAN")
       SET missing_xlats->qual[missing_cnt].orphan_ind = 1
       SET missing_xlats->qual[missing_cnt].processed_ind = 1
      ELSE
       SET missing_xlats->qual[missing_cnt].orphan_ind = 0
       SET missing_xlats->qual[missing_cnt].processed_ind = 0
      ENDIF
     ENDIF
     RETURN(except_log_type)
    ELSE
     IF (except_log_type IN ("ORPHAN", "OLDVER", "NOMV*"))
      RETURN(except_log_type)
     ELSE
      CALL parser(concat("select into 'NL:' from ",source_tab_name," r "),0)
      IF (sbr_table_name="DCP_FORMS_REF")
       CALL parser(" where r.dcp_forms_ref_id = sbr_value or r.dcp_form_instance_id = sbr_value ",0)
      ELSEIF (sbr_table_name="DCP_SECTION_REF")
       CALL parser(
        " where r.dcp_section_ref_id = sbr_value or r.dcp_section_instance_id = sbr_value ",0)
      ELSE
       CALL parser(concat(" where r.",sbr_column_name," = sbr_value"),0)
      ENDIF
      CALL parser(" with nocounter go",1)
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET nodelete_ind = 1
       SET no_insert_update = 1
       SET drdm_error_out_ind = 1
       SET dm_err->err_ind = 0
      ELSE
       IF (curqual=0)
        UPDATE  FROM (parser(except_tab) d)
         SET d.log_type = "ORPHAN"
         WHERE d.table_name=sbr_table_name
          AND d.from_value=sbr_value
          AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
         WITH nocounter
        ;end update
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         SET nodelete_ind = 1
         SET no_insert_update = 1
         SET drdm_error_out_ind = 1
         SET dm_err->err_ind = 0
        ENDIF
        RETURN("ORPHAN")
       ELSE
        SET missing_cnt = add_rs_values(sbr_table_name,sbr_column_name,sbr_value)
        IF (missing_cnt > 0)
         SET missing_xlats->qual[missing_cnt].processed_ind = 0
         SET missing_xlats->qual[missing_cnt].orphan_ind = 0
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   RETURN(except_log_type)
 END ;Subroutine
 SUBROUTINE version_exception(sbr_table_name,sbr_column_name,sbr_value)
   DECLARE except_tab = vc
   DECLARE except_log_type = vc
   IF ((global_mover_rec->one_pass_ind=0))
    ROLLBACK
   ENDIF
   SET except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   IF (sbr_table_name IN ("DCP_FORMS_REF", "DCP_SECTION_REF"))
    SET sbr_column_name = ""
   ENDIF
   SELECT
    IF (sbr_table_name IN ("DCP_FORMS_REF", "DCP_SECTION_REF"))
     WHERE (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.table_name=sbr_table_name
      AND d.from_value=sbr_value
    ELSE
     WHERE (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.table_name=sbr_table_name
      AND d.column_name=sbr_column_name
      AND d.from_value=sbr_value
    ENDIF
    INTO "NL:"
    FROM (parser(except_tab) d)
    DETAIL
     except_log_type = d.log_type
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET no_insert_update = 1
    SET drdm_error_out_ind = 1
    SET dm_err->err_ind = 0
   ELSE
    IF (curqual=0)
     INSERT  FROM (parser(except_tab) d)
      SET d.log_type = "OLDVER", d.table_name = sbr_table_name, d.column_name = sbr_column_name,
       d.from_value = sbr_value, d.target_env_id = dm2_ref_data_doc->env_target_id
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET nodelete_ind = 1
      SET no_insert_update = 1
      SET drdm_error_out_ind = 1
      SET dm_err->err_ind = 0
     ELSE
      IF ((global_mover_rec->one_pass_ind=0))
       COMMIT
      ENDIF
     ENDIF
    ELSEIF (except_log_type != "OLDVER")
     UPDATE  FROM (parser(except_tab) d)
      SET d.log_type = "OLDVER"
      WHERE d.table_name=sbr_table_name
       AND d.column_name=sbr_column_name
       AND d.from_value=sbr_value
       AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET nodelete_ind = 1
      SET no_insert_update = 1
      SET drdm_error_out_ind = 1
      SET dm_err->err_ind = 0
     ELSE
      IF ((global_mover_rec->one_pass_ind=0))
       COMMIT
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE rdds_del_except(sbr_table_name,sbr_value)
   DECLARE except_tab = vc
   SET except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   DELETE  FROM (parser(except_tab) d)
    WHERE (d.target_env_id=dm2_ref_data_doc->env_target_id)
     AND d.table_name=sbr_table_name
     AND d.from_value=sbr_value
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET no_insert_update = 1
    SET drdm_error_out_ind = 1
    SET dm_err->err_ind = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_get_rdds_tname(sbr_tname)
   DECLARE return_tname = vc
   IF ((dm2_rdds_rec->mode="OS"))
    SET return_tname = concat(trim(substring(1,28,sbr_tname)),"$F")
   ELSEIF ((dm2_rdds_rec->main_process="EXTRACTOR")
    AND (dm2_rdds_rec->mode="DATABASE"))
    SET return_tname = sbr_tname
   ELSEIF ((dm2_rdds_rec->main_process="MOVER")
    AND (dm2_rdds_rec->mode="DATABASE"))
    SET return_tname = concat(dm2_ref_data_doc->pre_link_name,sbr_tname,dm2_ref_data_doc->
     post_link_name)
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "The main_process and/or mode were invalid"
   ENDIF
   RETURN(return_tname)
 END ;Subroutine
 SUBROUTINE orphan_child_tab(sbr_table_name,sbr_log_type)
   DECLARE oct_tab_cnt = i4
   DECLARE oct_tab_loop = i4
   DECLARE oct_col_cnt = i4
   DECLARE oct_pk_value = f8
   DECLARE oct_excptn_tab = vc
   DECLARE oct_col_name = vc
   IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name != sbr_table_name))
    SET oct_tab_cnt = locateval(oct_tab_loop,1,size(dm2_ref_data_doc->tbl_qual,5),sbr_table_name,
     dm2_ref_data_doc->tbl_qual[oct_tab_loop].table_name)
    IF (oct_tab_cnt=0)
     SET dm_err->err_msg = "The table name could not be found in the meta-data record structure"
     SET nodelete_ind = 1
    ENDIF
   ELSE
    SET oct_tab_cnt = temp_tbl_cnt
   ENDIF
   SET oct_col_cnt = 0
   FOR (oct_tab_loop = 1 TO size(dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual,5))
     IF ((dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual[oct_tab_loop].pk_ind=1)
      AND (dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual[oct_tab_loop].root_entity_name=
     sbr_table_name))
      SET oct_col_cnt = oct_tab_loop
     ENDIF
   ENDFOR
   IF (oct_col_cnt=0)
    RETURN(0)
   ENDIF
   CALL parser(concat("set oct_pk_value = RS_",dm2_ref_data_doc->tbl_qual[oct_tab_cnt].suffix,
     "->from_values.",dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual[oct_col_cnt].column_name,
     " go "),1)
   SET oct_excptn_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   IF (sbr_table_name IN ("DCP_SECTION_REF", "DCP_FORMS_REF"))
    SELECT INTO "NL:"
     FROM (parser(oct_excptn_tab) d)
     WHERE d.table_name=sbr_table_name
      AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.from_value=oct_pk_value
     DETAIL
      oct_col_name = d.column_name
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "NL:"
     FROM (parser(oct_excptn_tab) d)
     WHERE d.table_name=sbr_table_name
      AND (d.column_name=dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual[oct_col_cnt].column_name)
      AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.from_value=oct_pk_value
     WITH nocounter
    ;end select
    SET oct_col_name = dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual[oct_col_cnt].column_name
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET drdm_error_out_ind = 1
    SET dm_err->err_ind = 0
   ENDIF
   IF (curqual=0)
    INSERT  FROM (parser(oct_excptn_tab) d)
     SET d.table_name = sbr_table_name, d.column_name = dm2_ref_data_doc->tbl_qual[oct_tab_cnt].
      col_qual[oct_col_cnt].column_name, d.target_env_id = dm2_ref_data_doc->env_target_id,
      d.from_value = oct_pk_value, d.log_type = sbr_log_type
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET nodelete_ind = 1
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
    ENDIF
   ELSE
    UPDATE  FROM (parser(oct_excptn_tab) d)
     SET d.log_type = sbr_log_type
     WHERE d.table_name=sbr_table_name
      AND d.column_name=oct_col_name
      AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
      AND d.from_value=oct_pk_value
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET nodelete_ind = 1
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_rdds_get_tbl_alias(sbr_tbl_suffix)
   DECLARE sbr_rgta_rtn = vc
   SET sbr_rgta_rtn = build("t",sbr_tbl_suffix)
   RETURN(sbr_rgta_rtn)
 END ;Subroutine
 SUBROUTINE insert_noxlat(sbr_table_name,sbr_column_name,sbr_value,sbr_orphan_ind)
   DECLARE inx_except_tab = vc
   DECLARE inx_log_type = vc
   DECLARE inx_col_name = vc
   SET inx_except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   IF (sbr_table_name IN ("DCP_SECTION_REF", "DCP_FORMS_REF"))
    SELECT INTO "NL:"
     FROM (parser(inx_except_tab) d)
     WHERE d.table_name=sbr_table_name
      AND d.from_value=sbr_value
      AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
     DETAIL
      inx_col_name = d.column_name
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "NL:"
     FROM (parser(inx_except_tab) d)
     WHERE d.table_name=sbr_table_name
      AND d.column_name=sbr_column_name
      AND d.from_value=sbr_value
      AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
     WITH nocounter
    ;end select
    SET inx_col_name = sbr_column_name
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET no_insert_update = 1
    RETURN(1)
   ENDIF
   IF (curqual=0)
    IF (sbr_orphan_ind=1)
     SET inx_log_type = "ORPHAN"
    ELSE
     SET inx_log_type = "NOXLAT"
    ENDIF
    INSERT  FROM (parser(inx_except_tab) d)
     SET d.log_type = inx_log_type, d.table_name = sbr_table_name, d.column_name = sbr_column_name,
      d.from_value = sbr_value, d.target_env_id = dm2_ref_data_doc->env_target_id
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET nodelete_ind = 1
     SET no_insert_update = 1
     SET drdm_error_out_ind = 1
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE add_rs_values(sbr_table_name,sbr_column_name,sbr_value)
   DECLARE arv_loop = i4
   DECLARE arv_cnt = i4
   DECLARE arv_found = i2
   SET arv_cnt = size(missing_xlats->qual,5)
   SET arv_found = 0
   FOR (arv_loop = 1 TO arv_cnt)
     IF ((missing_xlats->qual[arv_loop].table_name=sbr_table_name)
      AND (missing_xlats->qual[arv_loop].column_name=sbr_column_name)
      AND (missing_xlats->qual[arv_loop].missing_value=sbr_value))
      SET arv_found = 1
     ENDIF
   ENDFOR
   IF (arv_found=0)
    SET arv_cnt = (arv_cnt+ 1)
    SET stat = alterlist(missing_xlats->qual,arv_cnt)
    SET missing_xlats->qual[arv_cnt].table_name = sbr_table_name
    SET missing_xlats->qual[arv_cnt].column_name = sbr_column_name
    SET missing_xlats->qual[arv_cnt].missing_value = sbr_value
    RETURN(arv_cnt)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm_trans3(sbr_tbl_name,sbr_col_name,sbr_from_val,sbr_src_ind,sbr_pe_tbl_name)
   DECLARE to_val = vc
   DECLARE index_var = i4
   DECLARE dt3_temp_tbl_cnt = i4
   DECLARE dt3_temp_col_cnt = i4
   DECLARE dt3_from_con = vc
   DECLARE dt3_domain = vc
   DECLARE dt3_name = vc
   DECLARE dt3_find = i4
   DECLARE dt3_pk_column = vc
   DECLARE dt3_pk_tab_name = vc
   DECLARE dt3_root_tbl_cnt = i4
   IF (sbr_from_val=0)
    RETURN("0")
   ENDIF
   IF (sbr_src_ind=0)
    SET to_val = "NOXLAT"
    SET dt3_temp_tbl_cnt = locateval(index_var,1,perm_tbl_cnt,sbr_tbl_name,dm2_ref_data_doc->
     tbl_qual[index_var].table_name)
    SET dt3_temp_col_cnt = locateval(index_var,1,perm_col_cnt,sbr_col_name,dm2_ref_data_doc->
     tbl_qual[dt3_temp_tbl_cnt].col_qual[index_var].column_name)
    IF ((dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].col_qual[dt3_temp_col_cnt].exception_flg=1))
     RETURN(cnvtstring(sbr_from_val))
    ELSE
     IF ((dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].col_qual[dt3_temp_col_cnt].root_entity_name
      IN ("", " ")))
      IF (sbr_pe_tbl_name != ""
       AND sbr_pe_tbl_name != " ")
       SET dt3_pk_tab_name = find_p_e_col(sbr_pe_tbl_name,dt3_temp_col_cnt)
      ELSE
       SET dt3_pk_tab_name = "INVALIDTABLE"
       SET dt3_domain = concat("RDDS_PE_ABBREV:",sbr_tbl_name)
       SET dt3_name = concat(sbr_col_name,":",dt3_pk_tab_name)
       SELECT INTO "NL:"
        FROM dm_info d
        WHERE d.info_domain=dt3_domain
         AND d.info_name=dt3_name
        DETAIL
         dt3_pk_tab_name = d.info_char
        WITH nocounter
       ;end select
      ENDIF
      IF (dt3_pk_tab_name != "")
       IF (dt3_pk_tab_name != "INVALIDTABLE")
        IF (dt3_pk_tab_name="PERSON")
         SET dt3_pk_tab_name = "PRSNL"
        ENDIF
        SET to_val = select_merge_translate(cnvtstring(sbr_from_val),dt3_pk_tab_name)
       ENDIF
      ENDIF
      IF (to_val="No Trans")
       SET dt3_root_tbl_cnt = locateval(index_var,1,perm_tbl_cnt,dt3_pk_tab_name,dm2_ref_data_doc->
        tbl_qual[index_var].table_name)
       IF ((dm2_ref_data_doc->tbl_qual[dt3_root_tbl_cnt].mergeable_ind=0))
        SET to_val = "NOMV04"
       ELSE
        SET dt3_find = locateval(dt3_find,1,size(dm2_ref_data_doc->tbl_qual,5),dt3_pk_tab_name,
         dm2_ref_data_doc->tbl_qual[dt3_find].table_name)
        FOR (dt3_i = 1 TO size(dm2_ref_data_doc->tbl_qual[dt3_find].col_qual,5))
          IF ((dm2_ref_data_doc->tbl_qual[dt3_find].col_qual[dt3_i].pk_ind=1)
           AND (dm2_ref_data_doc->tbl_qual[dt3_find].col_qual[dt3_i].column_name=dm2_ref_data_doc->
          tbl_qual[dt3_find].col_qual[dt3_i].root_entity_attr)
           AND (dm2_ref_data_doc->tbl_qual[dt3_find].col_qual[dt3_i].root_entity_name=
          dm2_ref_data_doc->tbl_qual[dt3_find].table_name))
           SET dt3_pk_column = dm2_ref_data_doc->tbl_qual[dt3_find].col_qual[dt3_i].column_name
          ENDIF
        ENDFOR
        SET to_val = report_missing(dt3_pk_tab_name,dt3_pk_column,sbr_from_val)
       ENDIF
      ELSE
       IF (findstring(".0",to_val)=0)
        SET to_val = concat(to_val,".0")
       ENDIF
      ENDIF
     ELSE
      IF ((dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].col_qual[dt3_temp_col_cnt].root_entity_name=
      "PERSON")
       AND (dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].table_name != "PRSNL"))
       SET dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].col_qual[dt3_temp_col_cnt].root_entity_name
        = "PRSNL"
      ENDIF
      SET to_val = select_merge_translate(cnvtstring(sbr_from_val),dm2_ref_data_doc->tbl_qual[
       dt3_temp_tbl_cnt].col_qual[dt3_temp_col_cnt].root_entity_name)
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
      ENDIF
      IF (to_val="No Trans")
       SET dt3_root_tbl_cnt = locateval(index_var,1,perm_tbl_cnt,dm2_ref_data_doc->tbl_qual[
        dt3_temp_tbl_cnt].col_qual[dt3_temp_col_cnt].root_entity_name,dm2_ref_data_doc->tbl_qual[
        index_var].table_name)
       IF ((dm2_ref_data_doc->tbl_qual[dt3_root_tbl_cnt].mergeable_ind=0))
        SET to_val = "NOMV04"
       ELSE
        SET to_val = report_missing(dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].col_qual[
         dt3_temp_col_cnt].root_entity_name,dm2_ref_data_doc->tbl_qual[dt3_temp_tbl_cnt].col_qual[
         dt3_temp_col_cnt].root_entity_attr,sbr_from_val)
       ENDIF
      ELSE
       IF (findstring(".0",to_val)=0)
        SET to_val = concat(to_val,".0")
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET to_val = cnvtstring(sbr_from_val)
   ENDIF
   RETURN(to_val)
 END ;Subroutine
 SUBROUTINE trigger_proc_call(tpc_table_name,tpc_pk_where,tpc_context,tpc_col_name,tpc_value)
   DECLARE tpc_pk_where_vc = vc
   DECLARE tpc_pktbl_cnt = i4
   DECLARE tpc_tbl_loop = i4
   DECLARE tpc_error_ind = i2
   DECLARE tpc_col_loop = i4
   DECLARE tpc_col_pos = i4
   DECLARE tpc_suffix = vc
   DECLARE tpc_pk_proc_name = vc
   DECLARE tpc_proc_name = vc
   DECLARE tpc_f8_var = f8
   DECLARE tpc_i4_var = i4
   DECLARE tpc_vc_var = vc
   DECLARE tpc_row_cnt = i4
   DECLARE tpc_row_loop = i4
   DECLARE tpc_src_tab_name = vc
   DECLARE tpc_main_proc = vc
   DECLARE tpc_uo_tname = vc
   DECLARE tpc_pkw_tab_name = vc
   SET tpc_pk_where_vc = tpc_pk_where
   SET tpc_proc_name = ""
   SET tpc_pktbl_cnt = 0
   SET tpc_pktbl_cnt = locateval(tpc_tbl_loop,1,size(pk_where_parm->qual,5),tpc_table_name,
    pk_where_parm->qual[tpc_tbl_loop].table_name)
   IF (tpc_pktbl_cnt=0)
    SET tpc_pktbl_cnt = (size(pk_where_parm->qual,5)+ 1)
    SET stat = alterlist(pk_where_parm->qual,tpc_pktbl_cnt)
    SET pk_where_parm->qual[tpc_pktbl_cnt].table_name = tpc_table_name
    SET tpc_tbl_loop = 0
    SET tpc_pkw_tab_name = dm2_get_rdds_tname("DM_REFCHG_PKW_PARM")
    SELECT INTO "NL:"
     FROM (parser(tpc_pkw_tab_name) d)
     WHERE d.table_name=tpc_table_name
     ORDER BY parm_nbr
     DETAIL
      tpc_tbl_loop = (tpc_tbl_loop+ 1), stat = alterlist(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,
       tpc_tbl_loop), pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name = d
      .column_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET tpc_error_ind = 1
    ENDIF
   ENDIF
   SET temp_tbl_cnt = locateval(tpc_tbl_loop,1,dm2_ref_data_doc->tbl_cnt,tpc_table_name,
    dm2_ref_data_doc->tbl_qual[tpc_tbl_loop].table_name)
   IF (temp_tbl_cnt=0)
    SET temp_tbl_cnt = fill_rs("TABLE",tpc_table_name)
   ENDIF
   FREE RECORD cust_cs_rows
   CALL parser("record cust_cs_rows (",0)
   CALL parser(" 1 qual[*]",0)
   FOR (tpc_tbl_loop = 1 TO size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5))
     SET tpc_col_pos = locateval(tpc_col_loop,1,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt,
      pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name,dm2_ref_data_doc->tbl_qual[
      temp_tbl_cnt].col_qual[tpc_col_loop].column_name)
     CALL parser(concat(" 2 ",pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name,
       " = ",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[tpc_col_pos].data_type),0)
     CALL parser(concat(" 2 ",pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name,
       "_NULLIND = i2 "),0)
   ENDFOR
   CALL parser(") go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET tpc_error_ind = 1
   ENDIF
   SET tpc_suffix = concat("t",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix)
   IF (tpc_pk_where_vc="")
    SET tpc_pk_where_vc = concat("WHERE t",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix,".",
     tpc_col_name," = tpc_value")
   ENDIF
   IF (((size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5) != 1) OR ((pk_where_parm->qual[
   tpc_pktbl_cnt].col_qual[1].col_name != tpc_col_name))) )
    SET tpc_src_tab_name = dm2_get_rdds_tname(tpc_table_name)
    SET tpc_row_cnt = 0
    CALL parser("select into 'NL:' ",0)
    FOR (tpc_tbl_loop = 1 TO size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5))
     IF (tpc_tbl_loop > 1)
      CALL parser(" , ",0)
     ENDIF
     CALL parser(concat("var",cnvtstring(tpc_tbl_loop)," = nullind(",tpc_suffix,".",
       pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name,")"),0)
    ENDFOR
    CALL parser(concat("from ",tpc_src_tab_name," ",tpc_suffix," ",
      tpc_pk_where_vc,
      " detail  tpc_row_cnt = tpc_row_cnt + 1 stat = alterlist(cust_cs_rows->qual, tpc_row_cnt) "),0)
    FOR (tpc_tbl_loop = 1 TO size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5))
     CALL parser(concat(" cust_cs_rows->qual[tpc_row_cnt].",pk_where_parm->qual[tpc_pktbl_cnt].
       col_qual[tpc_tbl_loop].col_name," = ",tpc_suffix,".",
       pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name),0)
     CALL parser(concat(" cust_cs_rows->qual[tpc_row_cnt].",pk_where_parm->qual[tpc_pktbl_cnt].
       col_qual[tpc_tbl_loop].col_name,"_NULLIND = var",cnvtstring(tpc_tbl_loop)),0)
    ENDFOR
    CALL parser("with nocounter go",1)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET tpc_error_ind = 1
    ENDIF
    IF (tpc_row_cnt=0)
     RETURN(0)
    ENDIF
   ELSE
    SET tpc_row_cnt = 1
    SET stat = alterlist(cust_cs_rows->qual,1)
    CALL parser(concat("set cust_cs_rows->qual[1].",tpc_col_name," = tpc_value go"),0)
   ENDIF
   SET tpc_pk_proc_name = concat("REFCHG_PK_WHERE_",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix,
    "*")
   SET tpc_uo_tname = dm2_get_rdds_tname("USER_OBJECTS")
   SELECT INTO "NL:"
    FROM (parser(tpc_uo_tname) u)
    WHERE u.object_name=patstring(tpc_pk_proc_name)
    DETAIL
     tpc_proc_name = u.object_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET tpc_error_ind = 1
   ENDIF
   IF (tpc_proc_name="")
    SET dm_err->emsg = concat("A trigger procedure is not built: ",tpc_pk_proc_name)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET drdm_error_out_ind = 1
    RETURN(1)
   ELSE
    SET tpc_main_proc = dm2_get_rdds_tname("PROC_REFCHG_INS_LOG")
    SET tpc_proc_name = dm2_get_rdds_tname(tpc_proc_name)
    FOR (tpc_row_loop = 1 TO tpc_row_cnt)
      SET drdm_parser->statement[1].frag = concat("RDB ASIS(^ BEGIN ",tpc_main_proc,"('",
       tpc_table_name,"',^)")
      SET drdm_parser->statement[2].frag = concat(" ASIS (^",tpc_proc_name,"('INS/UPD'^)")
      SET drdm_parser_cnt = 3
      FOR (tpc_tbl_loop = 1 TO size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5))
        CALL parser(concat("set tpc_col_nullind = cust_cs_rows->qual[tpc_row_loop].",pk_where_parm->
          qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name,"_NULLIND go"),1)
        IF (tpc_col_nullind=1)
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^ , NULL ^)")
         SET drdm_parser->statement[((drdm_parser_cnt+ 2)+ size(pk_where_parm->qual[tpc_pktbl_cnt].
          col_qual,5))].frag = concat("ASIS (^ , NULL ^)")
        ELSE
         SET tpc_col_pos = locateval(tpc_col_loop,1,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt,
          pk_where_parm->qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name,dm2_ref_data_doc->
          tbl_qual[temp_tbl_cnt].col_qual[tpc_col_loop].column_name)
         IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[tpc_col_pos].data_type IN ("F8")))
          CALL parser(concat("set tpc_f8_var = cust_cs_rows->qual[tpc_row_loop].",pk_where_parm->
            qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^ , ",cnvtstring(
            tpc_f8_var,15),"^)")
          SET drdm_parser->statement[((drdm_parser_cnt+ 2)+ size(pk_where_parm->qual[tpc_pktbl_cnt].
           col_qual,5))].frag = concat("ASIS (^ , ",cnvtstring(tpc_f8_var,15),"^)")
         ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[tpc_col_pos].data_type IN ("Q8",
         "DQ8")))
          CALL parser(concat("set tpc_f8_var = cust_cs_rows->qual[tpc_row_loop].",pk_where_parm->
            qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^ ,to_date('",format(
            tpc_f8_var,"DD-MMM-YYYY HH:MM:SS;;D"),"','DD-MON-YYYY HH24:MI:SS')^)")
          SET drdm_parser->statement[((drdm_parser_cnt+ 2)+ size(pk_where_parm->qual[tpc_pktbl_cnt].
           col_qual,5))].frag = concat("ASIS (^ ,to_date('",format(tpc_f8_var,
            "DD-MMM-YYYY HH:MM:SS;;D"),"','DD-MON-YYYY HH24:MI:SS')^)")
         ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[tpc_col_pos].data_type IN ("I4",
         "I2")))
          CALL parser(concat("set tpc_i4_var = cust_cs_rows->qual[tpc_row_loop].",pk_where_parm->
            qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^ , ",cnvtstring(
            tpc_i4_var),"^)")
          SET drdm_parser->statement[((drdm_parser_cnt+ 2)+ size(pk_where_parm->qual[tpc_pktbl_cnt].
           col_qual,5))].frag = concat("ASIS (^ , ",cnvtstring(tpc_i4_var),"^)")
         ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[tpc_col_pos].data_type="C*"))
          CALL parser(concat("declare tpc_c_var = C",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
            col_qual[tpc_col_pos].data_length," go"),1)
          CALL parser(concat("set tpc_c_var = cust_cs_rows->qual[tpc_row_loop].",pk_where_parm->qual[
            tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^ , '",tpc_c_var,"'^)")
          SET drdm_parser->statement[((drdm_parser_cnt+ 2)+ size(pk_where_parm->qual[tpc_pktbl_cnt].
           col_qual,5))].frag = concat("ASIS (^ , '",tpc_c_var,"'^)")
         ELSE
          CALL parser(concat("set tpc_vc_var = cust_cs_rows->qual[tpc_row_loop].",pk_where_parm->
            qual[tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name," go"),1)
          SET tpc_vc_var = replace_carrot_symbol(tpc_vc_var)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^ , ",tpc_vc_var,"^)")
          SET drdm_parser->statement[((drdm_parser_cnt+ 2)+ size(pk_where_parm->qual[tpc_pktbl_cnt].
           col_qual,5))].frag = concat("ASIS (^ , ",tpc_vc_var,"^)")
         ENDIF
        ENDIF
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ENDFOR
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat(
       "ASIS (^), dbms_utility.get_hash_value(^)")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^",tpc_proc_name,
       "('INS/UPD'^)")
      SET drdm_parser_cnt = ((drdm_parser_cnt+ 1)+ size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5
       ))
      SET drdm_parser->statement[drdm_parser_cnt].frag = "ASIS (^),0,1073741824.0), ^)"
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^'REFCHG',0,",cnvtstring(
        reqinfo->updt_id,15),",",cnvtstring(reqinfo->updt_task),",",
       cnvtstring(reqinfo->updt_applctx),", ^)")
      SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      SET drdm_parser->statement[drdm_parser_cnt].frag = concat("ASIS (^'",tpc_context,"',",
       cnvtstring(dm2_ref_data_doc->env_target_id,15),"); END; ^) GO")
      CALL parse_statements(drdm_parser_cnt)
      IF (nodelete_ind=1)
       SET tpc_error_ind = 1
       SET tpc_row_loop = tpc_row_cnt
      ENDIF
    ENDFOR
   ENDIF
   RETURN(tpc_error_ind)
 END ;Subroutine
 SUBROUTINE filter_proc_call(fpc_table_name,fpc_pk_where)
   DECLARE fpc_loop = i4
   DECLARE fpc_filter_pos = i4
   DECLARE fpc_col_cnt = i4
   DECLARE fpc_tbl_loop = i4
   DECLARE fpc_col_loop = i4
   DECLARE fpc_col_pos = i4
   DECLARE fpc_error_ind = i2
   DECLARE fpc_suffix = vc
   DECLARE fpc_row_cnt = i4
   DECLARE fpc_row_loop = i4
   DECLARE fpc_col_nullind = i2
   DECLARE fpc_proc_name = vc
   DECLARE fpc_filter_proc_name = vc
   DECLARE fpc_src_tab_name = vc
   DECLARE fpc_f8_var = f8
   DECLARE fpc_i4_var = i4
   DECLARE fpc_vc_var = vc
   DECLARE fpc_return_var = i2
   DECLARE fpc_uo_tname = vc
   DECLARE fpc_filter_tab_name = vc
   SET fpc_filter_pos = locateval(fpc_loop,1,size(filter_parm->qual,5),fpc_table_name,filter_parm->
    qual[fpc_loop].table_name)
   IF (fpc_filter_pos=0)
    SET fpc_filter_pos = (size(filter_parm->qual,5)+ 1)
    SET fpc_col_cnt = 0
    SET fpc_filter_tab_name = dm2_get_rdds_tname("DM_REFCHG_FILTER_PARM")
    SELECT INTO "NL:"
     FROM (parser(fpc_filter_tab_name) d)
     WHERE d.table_name=fpc_table_name
      AND d.active_ind=1
     ORDER BY d.parm_nbr
     HEAD REPORT
      stat = alterlist(filter_parm->qual,fpc_filter_pos), filter_parm->qual[fpc_filter_pos].
      table_name = fpc_table_name
     DETAIL
      fpc_col_cnt = (fpc_col_cnt+ 1), stat = alterlist(filter_parm->qual[fpc_filter_pos].col_qual,
       fpc_col_cnt), filter_parm->qual[fpc_filter_pos].col_qual[fpc_col_cnt].col_name = d.column_name
     WITH nocounter
    ;end select
    IF (curqual=0)
     RETURN(1)
    ENDIF
   ENDIF
   SET temp_tbl_cnt = locateval(fpc_tbl_loop,1,dm2_ref_data_doc->tbl_cnt,fpc_table_name,
    dm2_ref_data_doc->tbl_qual[fpc_tbl_loop].table_name)
   IF (temp_tbl_cnt=0)
    SET temp_tbl_cnt = fill_rs("TABLE",fpc_table_name)
   ENDIF
   FREE RECORD cust_cs_rows
   CALL parser("record cust_cs_rows (",0)
   CALL parser(" 1 qual[*]",0)
   FOR (fpc_tbl_loop = 1 TO size(filter_parm->qual[fpc_filter_pos].col_qual,5))
     SET fpc_col_pos = locateval(fpc_col_loop,1,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt,
      filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name,dm2_ref_data_doc->tbl_qual[
      temp_tbl_cnt].col_qual[fpc_col_loop].column_name)
     CALL parser(concat(" 2 ",filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," = ",
       dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fpc_col_pos].data_type),0)
     CALL parser(concat(" 2 ",filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name,
       "_NULLIND = i2 "),0)
   ENDFOR
   CALL parser(") go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET fpc_error_ind = 1
   ENDIF
   SET fpc_suffix = concat("t",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix)
   SET fpc_row_cnt = 0
   SET fpc_src_tab_name = dm2_get_rdds_tname(fpc_table_name)
   CALL parser("select into 'NL:' ",0)
   FOR (fpc_tbl_loop = 1 TO size(filter_parm->qual[fpc_filter_pos].col_qual,5))
    IF (fpc_tbl_loop > 1)
     CALL parser(" , ",0)
    ENDIF
    CALL parser(concat("var",cnvtstring(fpc_tbl_loop)," = nullind(",fpc_suffix,".",
      filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name,")"),0)
   ENDFOR
   CALL parser(concat("from ",fpc_src_tab_name," ",fpc_suffix," ",
     fpc_pk_where,
     " detail  fpc_row_cnt = fpc_row_cnt + 1 stat = alterlist(cust_cs_rows->qual, fpc_row_cnt) "),0)
   FOR (fpc_tbl_loop = 1 TO size(filter_parm->qual[fpc_filter_pos].col_qual,5))
    CALL parser(concat(" cust_cs_rows->qual[fpc_row_cnt].",filter_parm->qual[fpc_filter_pos].
      col_qual[fpc_tbl_loop].col_name," = ",fpc_suffix,".",
      filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name),0)
    CALL parser(concat(" cust_cs_rows->qual[fpc_row_cnt].",filter_parm->qual[fpc_filter_pos].
      col_qual[fpc_tbl_loop].col_name,"_NULLIND = var",cnvtstring(fpc_tbl_loop)),0)
   ENDFOR
   CALL parser("with nocounter go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET fpc_error_ind = 0
   ENDIF
   IF (fpc_row_cnt=0)
    RETURN(1)
   ENDIF
   SET fpc_uo_tname = dm2_get_rdds_tname("USER_OBJECTS")
   SET fpc_proc_name = ""
   SET fpc_filter_proc_name = concat("REFCHG_FILTER_",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix,
    "*")
   SELECT INTO "NL:"
    FROM (parser(fpc_uo_tname) u)
    WHERE u.object_name=patstring(fpc_filter_proc_name)
    DETAIL
     fpc_proc_name = u.object_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET fpc_error_ind = 1
   ENDIF
   IF (fpc_proc_name="")
    SET dm_err->emsg = concat("A filter procedure is not built: ",fpc_filter_proc_name)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET drdm_error_out_ind = 1
    RETURN(1)
   ELSE
    SET fpc_proc_name = dm2_get_rdds_tname(fpc_proc_name)
    CALL parser(concat(" declare ",fpc_proc_name,"() = i2 go"),0)
    FOR (fpc_row_loop = 1 TO fpc_row_cnt)
      SET drdm_parser->statement[1].frag = concat("select into 'NL:' ret_val = ",fpc_proc_name,
       "('UPD'")
      SET drdm_parser_cnt = 2
      FOR (fpc_tbl_loop = 1 TO size(filter_parm->qual[fpc_filter_pos].col_qual,5))
        CALL parser(concat("set fpc_col_nullind = cust_cs_rows->qual[fpc_row_loop].",filter_parm->
          qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name,"_NULLIND go"),1)
        IF (fpc_col_nullind=1)
         SET drdm_parser->statement[drdm_parser_cnt].frag = ", NULL, NULL "
        ELSE
         SET fpc_col_pos = locateval(fpc_col_loop,1,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt,
          filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name,dm2_ref_data_doc->
          tbl_qual[temp_tbl_cnt].col_qual[fpc_col_loop].column_name)
         IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fpc_col_pos].data_type IN ("F8")))
          CALL parser(concat("set fpc_f8_var = cust_cs_rows->qual[fpc_row_loop].",filter_parm->qual[
            fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(",",cnvtstring(fpc_f8_var,15),
           " , ",cnvtstring(fpc_f8_var,15))
         ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fpc_col_pos].data_type IN ("Q8",
         "DQ8")))
          CALL parser(concat("set fpc_f8_var = cust_cs_rows->qual[fpc_row_loop].",filter_parm->qual[
            fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" ,to_date('",format(fpc_f8_var,
            "DD-MMM-YYYY SS:MM:SS;;D"),"','DD-MON-YYYY HH24:MI:SS'),","to_date('",format(fpc_f8_var,
            "DD-MMM-YYYY SS:MM:SS;;D"),
           "','DD-MON-YYYY HH24:MI:SS')")
         ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fpc_col_pos].data_type IN ("I4",
         "I2")))
          CALL parser(concat("set fpc_i4_var = cust_cs_rows->qual[fpc_row_loop].",filter_parm->qual[
            fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(",",cnvtstring(fpc_i4_var)," , ",
           cnvtstring(fpc_i4_var))
         ELSE
          CALL parser(concat("set fpc_vc_var = cust_cs_rows->qual[fpc_row_loop].",filter_parm->qual[
            fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," go"),1)
          SET fpc_vc_var = replace(fpc_vc_var,"'","''",0)
          SET fpc_vc_var = concat("'",fpc_vc_var,"'")
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(",",fpc_vc_var," , ",fpc_vc_var)
         ENDIF
        ENDIF
        SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
      ENDFOR
      SET drdm_parser->statement[drdm_parser_cnt].frag =
      ") from dual detail fpc_return_var = ret_val with nocounter go"
      CALL parse_statements(drdm_parser_cnt)
      IF (nodelete_ind=1)
       SET fpc_error_ind = 1
       SET fpc_row_loop = fpc_row_cnt
      ENDIF
      IF (fpc_return_var=0)
       SET fpc_row_loop = fpc_row_cnt
      ENDIF
    ENDFOR
   ENDIF
   RETURN(fpc_return_var)
 END ;Subroutine
 SUBROUTINE replace_carrot_symbol(rcs_string)
   DECLARE rcs_start_idx = i4
   DECLARE rcs_pos = i4
   DECLARE rcs_return = vc
   DECLARE rcs_temp_val = vc
   DECLARE rcs_concat = vc
   SET rcs_temp_val = replace(rcs_string,"'",'"',0)
   SET rcs_start_idx = 1
   SET rcs_pos = findstring("^",rcs_temp_val,1,0)
   IF (rcs_pos=0)
    SET rcs_return = concat("'",rcs_temp_val,"'")
   ELSE
    WHILE (rcs_pos > 0)
      IF (rcs_start_idx=1)
       IF (rcs_pos=1)
        SET rcs_return = "chr(94)"
       ELSE
        SET rcs_return = concat("'",substring(rcs_start_idx,(rcs_pos - 1),rcs_temp_val),"'||chr(94)")
       ENDIF
      ELSE
       SET rcs_return = concat(rcs_return,"||'",substring(rcs_start_idx,(rcs_pos - rcs_start_idx),
         rcs_temp_val),"'||chr(94)")
      ENDIF
      SET rcs_start_idx = (rcs_pos+ 1)
      SET rcs_pos = findstring("^",rcs_temp_val,rcs_start_idx,0)
    ENDWHILE
    IF (rcs_start_idx <= size(rcs_temp_val))
     SET rcs_pos = findstring("^",rcs_temp_val,1,1)
     SET rcs_return = concat(rcs_return,"||'",substring(rcs_start_idx,(size(rcs_temp_val) - rcs_pos),
       rcs_temp_val),"'")
    ENDIF
   ENDIF
   RETURN(rcs_return)
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
 DECLARE drcdv_check_version(drcdv_prefix=vc,drcdv_object_name=vc,drcdv_version_num=i4) = i2
 SUBROUTINE drcdv_check_version(drcdv_prefix,drcdv_object_name,drcdv_version_num)
   DECLARE drcdv_object_vers_str = vc WITH protect, noconstant(" ")
   DECLARE drcdv_line_text = vc WITH protect, noconstant(" ")
   DECLARE drcdv_start_pos = i4 WITH protect, noconstant(0)
   DECLARE drcdv_idx = i4 WITH protect, noconstant(0)
   SELECT INTO "NL:"
    u.text
    FROM user_source u
    WHERE u.name=drcdv_object_name
     AND u.text=patstring(concat("*",drcdv_prefix,"*"))
    DETAIL
     drcdv_line_text = u.text
    WITH nocounter
   ;end select
   IF (curqual=0)
    RETURN(false)
   ENDIF
   SET drcdv_start_pos = (findstring(drcdv_prefix,drcdv_line_text,1,0)+ size(drcdv_prefix))
   FOR (drcdv_idx = drcdv_start_pos TO size(drcdv_line_text))
     IF (isnumeric(substring(drcdv_idx,1,drcdv_line_text))=1)
      IF (daf_is_blank(drcdv_object_vers_str)=true)
       SET drcdv_object_vers_str = substring(drcdv_idx,1,drcdv_line_text)
      ELSE
       SET drcdv_object_vers_str = concat(drcdv_object_vers_str,substring(drcdv_idx,1,drcdv_line_text
         ))
      ENDIF
     ELSE
      IF (daf_is_not_blank(drcdv_object_vers_str)=true)
       SET drcdv_idx = (size(drcdv_line_text)+ 1)
      ENDIF
     ENDIF
   ENDFOR
   IF (cnvtint(drcdv_object_vers_str)=drcdv_version_num)
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
 END ;Subroutine
 DECLARE daclt_sub_rtn_execute_flg = i2
 SET daclt_sub_rtn_execute_flg = 0
 IF ((((dm2_install_schema->curprog != "DM2_ADD_REFCHG_LOG_TRIGGERS")) OR (size(dm2_cl_trg_updt_cols
  ->qual,5)=0)) )
  SET daclt_sub_rtn_execute_flg = 1
 ENDIF
 FREE RECORD rs_dtd_reply
 RECORD rs_dtd_reply(
   1 rs_tbl_cnt = i4
   1 dtd_hold[*]
     2 tbl_name = vc
     2 process_ind = i2
     2 updt_id_exist = i2
     2 updt_task_exist = i2
     2 tbl_suffix = vc
     2 mrg_del_ind = i2
     2 vers134_ind = i2
     2 ref_ind = i2
     2 mrg_ind = i2
     2 mrg_act_ind = i2
     2 trig_text[3]
       3 trig_name = vc
     2 pk_cnt = i4
     2 pk_hold[*]
       3 pk_datatype = vc
       3 pk_where = vc
       3 pk_name = vc
       3 trans_ind = i2
     2 del_cnt = i4
     2 del_hold[*]
       3 del_datatype = vc
       3 del_where = vc
       3 trans_ind = i2
       3 del_name = vc
     2 filter_function = vc
     2 filter_parm[*]
       3 column_name = vc
       3 data_type = vc
     2 filter_str[*]
       3 add_str = vc
       3 upd_str = vc
       3 del_str = vc
       3 statement_ind = i2
     2 pkw_function = vc
     2 pk_where_parm[*]
       3 column_name = vc
     2 pkw_vers_id = f8
 )
 FREE RECORD stmt_buffer
 RECORD stmt_buffer(
   1 err_ind = i2
   1 data[*]
     2 stmt = vc
 )
 FREE RECORD se_reply
 RECORD se_reply(
   1 err_ind = i2
 )
 DECLARE cl_move_over(i_dguc_reply=vc(ref),i_table_name=vc,i_log_type=vc,i_refchg_tab_r_find=i2,
  i_local_ind=i2) = null
 DECLARE generate_pk_where_str_ora(i_dtd_ndx=i4,o_parm_list=vc(ref),io_iu_pk_where=vc(ref),
  io_del_pk_where=vc(ref),i_local_ind=i2) = null
 DECLARE create_pk_where_function_ora(i_dtd_ndx=i4,io_drop_cnt=i4(ref),io_stmt_cnt=i4(ref),
  i_local_ind=i2) = null
 DECLARE stmt_push(io_cnt=i4(ref),p_text=vc) = null
 DECLARE create_ptam_function_ora(sbr_trg_data_rs=vc(ref),i_trg_ndx=i4,io_drop_cnt=i4(ref),
  io_stmt_cnt=i4(ref)) = i4
 DECLARE create_pkw_function_ora(sbr_trg_data_rs=vc(ref),i_trg_ndx=i4,io_drop_cnt=i4(ref),io_stmt_cnt
  =i4(ref)) = i4
 DECLARE create_colstring_function_ora(sbr_trg_data_rs=vc(ref),i_trg_ndx=i4,io_drop_cnt=i4(ref),
  io_stmt_cnt=i4(ref)) = i4
 DECLARE create_input_parm_ora(i_col_name=vc,i_col_cnt=i4) = vc
 SUBROUTINE cl_move_over(i_dguc_reply,i_table_name,i_log_type,i_refchg_tab_r_find,i_local_ind)
   FREE RECORD rs_dtd_trans
   RECORD rs_dtd_trans(
     1 dtd_hold[*]
       2 pk_hold[*]
         3 trans_ind = i2
   )
   FREE RECORD order_pk
   RECORD order_pk(
     1 ord_hold[*]
       2 ord_datatype = vc
       2 ord_where = vc
       2 trans_ind = i2
       2 ord_name = vc
   )
   DECLARE ac_suf_tbl_name = vc
   DECLARE keep_id_cnt = i4
   DECLARE updt_idx = i4 WITH protect, noconstant(0)
   DECLARE s_load_cnt = i4
   DECLARE s_del_size_hold = i4
   DECLARE s_dtd_name = vc
   DECLARE s_dcd_name = vc
   SET s_dtd_name = "DM_TABLES_DOC_LOCAL"
   SET s_dcd_name = "DM_COLUMNS_DOC_LOCAL"
   SET stat = alterlist(rs_dtd_reply->dtd_hold,size(i_dguc_reply->dtd_hold,5))
   SET final_cnt = 0
   SET updt_idx = 0
   SET stat = alterlist(rs_dtd_trans->dtd_hold,size(i_dguc_reply->dtd_hold,5))
   SET ac_suf_tbl_name = i_table_name
   IF (daclt_sub_rtn_execute_flg=1)
    IF (dm2_cl_trg_updt_cols(ac_suf_tbl_name) != 0)
     SET dm_err->err_ind = 1
     GO TO exit_program
    ENDIF
   ENDIF
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = value(i_dguc_reply->rs_tbl_cnt)),
     dm_info i,
     (dummyt dt  WITH seq = 100)
    PLAN (d)
     JOIN (dt
     WHERE (dt.seq <= i_dguc_reply->dtd_hold[d.seq].pk_cnt))
     JOIN (i
     WHERE i.info_domain=concat("RDDS TRANS COLUMN:",i_dguc_reply->dtd_hold[d.seq].tbl_name)
      AND (i.info_name=i_dguc_reply->dtd_hold[d.seq].pk_hold[dt.seq].pk_name))
    DETAIL
     IF (size(rs_dtd_trans->dtd_hold[d.seq].pk_hold,5)=0)
      stat = alterlist(rs_dtd_trans->dtd_hold[d.seq].pk_hold,i_dguc_reply->dtd_hold[d.seq].pk_cnt)
     ENDIF
     rs_dtd_trans->dtd_hold[d.seq].pk_hold[dt.seq].trans_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   SET dtd_ndx = 0
   SET dm_err->eproc = concat("Getting tables with Merge_Delete_Ind = 1.")
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = i_dguc_reply->rs_tbl_cnt)
    DETAIL
     final_cnt = (final_cnt+ 1), rs_dtd_reply->dtd_hold[final_cnt].tbl_suffix = i_dguc_reply->
     dtd_hold[d.seq].tbl_suffix, updt_idx = 0,
     updt_idx = locateval(updt_idx,1,dm2_cl_trg_updt_cols->tbl_cnt,i_dguc_reply->dtd_hold[d.seq].
      tbl_name,dm2_cl_trg_updt_cols->qual[updt_idx].tname)
     IF (updt_idx > 0)
      rs_dtd_reply->dtd_hold[final_cnt].updt_id_exist = dm2_cl_trg_updt_cols->qual[updt_idx].
      updt_id_exist_ind, rs_dtd_reply->dtd_hold[final_cnt].updt_task_exist = dm2_cl_trg_updt_cols->
      qual[updt_idx].updt_task_exist_ind
     ELSE
      rs_dtd_reply->dtd_hold[final_cnt].updt_id_exist = 0, rs_dtd_reply->dtd_hold[final_cnt].
      updt_task_exist = 0
     ENDIF
     rs_dtd_reply->dtd_hold[final_cnt].tbl_name = i_dguc_reply->dtd_hold[d.seq].tbl_name, stat =
     alterlist(rs_dtd_reply->dtd_hold[final_cnt].pk_hold,i_dguc_reply->dtd_hold[d.seq].pk_cnt)
     IF (size(rs_dtd_trans->dtd_hold[d.seq].pk_hold,5)=0)
      stat = alterlist(rs_dtd_trans->dtd_hold[d.seq].pk_hold,i_dguc_reply->dtd_hold[d.seq].pk_cnt)
     ENDIF
     dtd_col_cnt = 0, pk_loop_cnt = 0, keep_id_cnt = 0
     FOR (pk_loop_cnt = 1 TO i_dguc_reply->dtd_hold[d.seq].pk_cnt)
       IF (((findstring("_ID",i_dguc_reply->dtd_hold[d.seq].pk_hold[pk_loop_cnt].pk_name)) OR (((
       findstring("_CD",i_dguc_reply->dtd_hold[d.seq].pk_hold[pk_loop_cnt].pk_name)) OR ((((
       i_dguc_reply->dtd_hold[d.seq].pk_hold[pk_loop_cnt].pk_name="CODE_VALUE")) OR ((rs_dtd_trans->
       dtd_hold[d.seq].pk_hold[pk_loop_cnt].trans_ind=1))) )) )) )
        keep_id_cnt = (keep_id_cnt+ 1)
       ENDIF
     ENDFOR
     pk_loop_cnt = 0
     IF (keep_id_cnt > 0)
      FOR (pk_loop_cnt = 1 TO i_dguc_reply->dtd_hold[d.seq].pk_cnt)
        IF ((((i_dguc_reply->dtd_hold[d.seq].pk_hold[pk_loop_cnt].pk_name IN ("*_ID", "*_CD",
        "CODE_VALUE"))) OR ((rs_dtd_trans->dtd_hold[d.seq].pk_hold[pk_loop_cnt].trans_ind=1))) )
         dtd_col_cnt = (dtd_col_cnt+ 1), rs_dtd_reply->dtd_hold[final_cnt].pk_hold[dtd_col_cnt].
         pk_name = i_dguc_reply->dtd_hold[d.seq].pk_hold[pk_loop_cnt].pk_name, rs_dtd_reply->
         dtd_hold[final_cnt].pk_hold[dtd_col_cnt].trans_ind = 1,
         rs_dtd_reply->dtd_hold[final_cnt].pk_hold[dtd_col_cnt].pk_datatype = i_dguc_reply->dtd_hold[
         d.seq].pk_hold[pk_loop_cnt].pk_datatype
         IF (dtd_col_cnt=1)
          rs_dtd_reply->dtd_hold[final_cnt].pk_hold[dtd_col_cnt].pk_where = concat("WHERE ",
           dm2_rdds_get_tbl_alias(rs_dtd_reply->dtd_hold[final_cnt].tbl_suffix),".",trim(rs_dtd_reply
            ->dtd_hold[final_cnt].pk_hold[dtd_col_cnt].pk_name))
         ELSE
          rs_dtd_reply->dtd_hold[final_cnt].pk_hold[dtd_col_cnt].pk_where = concat(" AND ",
           dm2_rdds_get_tbl_alias(rs_dtd_reply->dtd_hold[final_cnt].tbl_suffix),".",trim(rs_dtd_reply
            ->dtd_hold[final_cnt].pk_hold[dtd_col_cnt].pk_name))
         ENDIF
        ENDIF
      ENDFOR
      pk_loop_cnt = 0
      FOR (pk_loop_cnt = 1 TO i_dguc_reply->dtd_hold[d.seq].pk_cnt)
        IF ( NOT ((i_dguc_reply->dtd_hold[d.seq].pk_hold[pk_loop_cnt].pk_name IN ("*_ID", "*_CD",
        "CODE_VALUE")))
         AND (rs_dtd_trans->dtd_hold[d.seq].pk_hold[pk_loop_cnt].trans_ind=0))
         IF ((dtd_col_cnt=i_dguc_reply->dtd_hold[d.seq].pk_cnt))
          pk_loop_cnt = i_dguc_reply->dtd_hold[d.seq].pk_cnt
         ELSE
          dtd_col_cnt = (dtd_col_cnt+ 1), rs_dtd_reply->dtd_hold[final_cnt].pk_hold[dtd_col_cnt].
          pk_name = i_dguc_reply->dtd_hold[d.seq].pk_hold[pk_loop_cnt].pk_name, rs_dtd_reply->
          dtd_hold[final_cnt].pk_hold[dtd_col_cnt].pk_datatype = i_dguc_reply->dtd_hold[d.seq].
          pk_hold[pk_loop_cnt].pk_datatype
          IF (dtd_col_cnt=1)
           rs_dtd_reply->dtd_hold[final_cnt].pk_hold[dtd_col_cnt].pk_where = concat("WHERE ",
            dm2_rdds_get_tbl_alias(i_dguc_reply->dtd_hold[d.seq].tbl_suffix),".",trim(i_dguc_reply->
             dtd_hold[d.seq].pk_hold[pk_loop_cnt].pk_name))
          ELSE
           rs_dtd_reply->dtd_hold[final_cnt].pk_hold[dtd_col_cnt].pk_where = concat(" AND ",
            dm2_rdds_get_tbl_alias(i_dguc_reply->dtd_hold[d.seq].tbl_suffix),".",trim(i_dguc_reply->
             dtd_hold[d.seq].pk_hold[pk_loop_cnt].pk_name))
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
      rs_dtd_reply->dtd_hold[final_cnt].pk_cnt = i_dguc_reply->dtd_hold[d.seq].pk_cnt, rs_dtd_reply->
      dtd_hold[final_cnt].mrg_del_ind = 1
     ELSE
      rs_dtd_reply->dtd_hold[final_cnt].mrg_del_ind = 0
      FOR (pk_loop_cnt = 1 TO i_dguc_reply->dtd_hold[d.seq].pk_cnt)
        dtd_col_cnt = (dtd_col_cnt+ 1), rs_dtd_reply->dtd_hold[final_cnt].pk_hold[dtd_col_cnt].
        pk_name = i_dguc_reply->dtd_hold[d.seq].pk_hold[pk_loop_cnt].pk_name, rs_dtd_reply->dtd_hold[
        final_cnt].pk_hold[dtd_col_cnt].pk_datatype = i_dguc_reply->dtd_hold[d.seq].pk_hold[
        pk_loop_cnt].pk_datatype
        IF (dtd_col_cnt=1)
         rs_dtd_reply->dtd_hold[final_cnt].pk_hold[dtd_col_cnt].pk_where = concat("WHERE ",
          dm2_rdds_get_tbl_alias(i_dguc_reply->dtd_hold[d.seq].tbl_suffix),".",trim(i_dguc_reply->
           dtd_hold[d.seq].pk_hold[pk_loop_cnt].pk_name))
        ELSE
         rs_dtd_reply->dtd_hold[final_cnt].pk_hold[dtd_col_cnt].pk_where = concat(" AND ",
          dm2_rdds_get_tbl_alias(i_dguc_reply->dtd_hold[d.seq].tbl_suffix),".",trim(i_dguc_reply->
           dtd_hold[d.seq].pk_hold[pk_loop_cnt].pk_name))
        ENDIF
      ENDFOR
      rs_dtd_reply->dtd_hold[final_cnt].pk_cnt = i_dguc_reply->dtd_hold[d.seq].pk_cnt
     ENDIF
    FOOT REPORT
     rs_dtd_reply->rs_tbl_cnt = i_dguc_reply->rs_tbl_cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (i_refchg_tab_r_find=1)
    SET single_commit_table_name = "*"
   ELSE
    SET single_commit_table_name = ac_suf_tbl_name
   ENDIF
   SELECT INTO "NL:"
    duc.table_name, duc.column_name, duc.data_type
    FROM user_tab_columns duc
    WHERE list(duc.table_name,duc.column_name) IN (
    (SELECT
     dcd.table_name, dcd.column_name
     FROM (parser(s_dtd_name) dtd),
      (parser(s_dcd_name) dcd)
     WHERE dcd.merge_delete_ind=1
      AND dtd.merge_delete_ind=1
      AND dcd.table_name=dtd.table_name))
     AND table_name=patstring(single_commit_table_name)
    ORDER BY duc.table_name
    HEAD duc.table_name
     del_ndx = 0, del_ndx = locateval(del_ndx,1,rs_dtd_reply->rs_tbl_cnt,duc.table_name,rs_dtd_reply
      ->dtd_hold[del_ndx].tbl_name)
     IF (del_ndx > 0)
      stat = alterlist(rs_dtd_reply->dtd_hold[del_ndx].del_hold,0)
     ENDIF
     del_col_cnt = 0, rs_dtd_reply->dtd_hold[del_ndx].mrg_del_ind = 2
    DETAIL
     IF (del_ndx > 0)
      del_col_cnt = (del_col_cnt+ 1)
      IF (mod(del_col_cnt,10)=1)
       stat = alterlist(rs_dtd_reply->dtd_hold[del_ndx].del_hold,(del_col_cnt+ 9))
      ENDIF
      rs_dtd_reply->dtd_hold[del_ndx].del_hold[del_col_cnt].del_name = duc.column_name
      IF ((rs_dtd_reply->dtd_hold[del_ndx].del_hold[del_col_cnt].del_name IN ("*_ID", "*_CD",
      "CODE_VALUE")))
       rs_dtd_reply->dtd_hold[del_ndx].mrg_del_ind = 1
      ENDIF
      rs_dtd_reply->dtd_hold[del_ndx].del_hold[del_col_cnt].del_datatype = duc.data_type
      IF (del_col_cnt=1)
       rs_dtd_reply->dtd_hold[del_ndx].del_hold[del_col_cnt].del_where = concat("WHERE ",
        dm2_rdds_get_tbl_alias(i_dguc_reply->dtd_hold[del_ndx].tbl_suffix),".",trim(duc.column_name))
      ELSE
       rs_dtd_reply->dtd_hold[del_ndx].del_hold[del_col_cnt].del_where = concat(" AND ",
        dm2_rdds_get_tbl_alias(i_dguc_reply->dtd_hold[del_ndx].tbl_suffix),".",trim(duc.column_name))
      ENDIF
     ENDIF
    FOOT  duc.table_name
     IF (del_ndx > 0)
      stat = alterlist(rs_dtd_reply->dtd_hold[del_ndx].del_hold,del_col_cnt)
     ENDIF
     IF (del_col_cnt > 0)
      rs_dtd_reply->dtd_hold[del_ndx].del_cnt = del_col_cnt
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   SET dm_err->eproc = "Loading UI information for versioning tables."
   CALL disp_msg(dm_err->eproc,dm_err->logfile,dm_err->err_ind)
   SELECT INTO "NL:"
    duc.table_name, duc.column_name, duc.data_type
    FROM user_tab_columns duc
    WHERE list(duc.table_name,duc.column_name) IN (
    (SELECT
     dcd.table_name, dcd.column_name
     FROM (parser(s_dcd_name) dcd)
     WHERE ((dcd.table_name IN (
     (SELECT
      cv.display
      FROM code_value cv
      WHERE cv.code_set=255351.0
       AND cv.cdf_meaning IN ("ALG1", "ALG3", "ALG3D", "ALG4")
       AND cv.active_ind=1))) OR (dcd.table_name IN ("DCP_SECTION_REF", "DCP_FORMS_REF")))
      AND dcd.unique_ident_ind=1))
    ORDER BY duc.table_name
    HEAD duc.table_name
     del_ndx = 0, del_ndx = locateval(del_ndx,1,rs_dtd_reply->rs_tbl_cnt,duc.table_name,rs_dtd_reply
      ->dtd_hold[del_ndx].tbl_name)
     IF (del_ndx > 0)
      stat = alterlist(rs_dtd_reply->dtd_hold[del_ndx].del_hold,0)
     ENDIF
     del_col_cnt = 0, rs_dtd_reply->dtd_hold[del_ndx].mrg_del_ind = 2, rs_dtd_reply->dtd_hold[del_ndx
     ].vers134_ind = 1
    DETAIL
     IF (del_ndx > 0)
      del_col_cnt = (del_col_cnt+ 1)
      IF (mod(del_col_cnt,10)=1)
       stat = alterlist(rs_dtd_reply->dtd_hold[del_ndx].del_hold,(del_col_cnt+ 9))
      ENDIF
      rs_dtd_reply->dtd_hold[del_ndx].del_hold[del_col_cnt].del_name = duc.column_name
      IF ((rs_dtd_reply->dtd_hold[del_ndx].del_hold[del_col_cnt].del_name IN ("*_ID", "*_CD",
      "CODE_VALUE")))
       rs_dtd_reply->dtd_hold[del_ndx].mrg_del_ind = 1
      ENDIF
      rs_dtd_reply->dtd_hold[del_ndx].del_hold[del_col_cnt].del_datatype = duc.data_type
      IF (del_col_cnt=1)
       rs_dtd_reply->dtd_hold[del_ndx].del_hold[del_col_cnt].del_where = concat("WHERE ",
        dm2_rdds_get_tbl_alias(i_dguc_reply->dtd_hold[del_ndx].tbl_suffix),".",trim(duc.column_name))
      ELSE
       rs_dtd_reply->dtd_hold[del_ndx].del_hold[del_col_cnt].del_where = concat(" AND ",
        dm2_rdds_get_tbl_alias(i_dguc_reply->dtd_hold[del_ndx].tbl_suffix),".",trim(duc.column_name))
      ENDIF
     ENDIF
    FOOT  duc.table_name
     IF (del_ndx > 0)
      stat = alterlist(rs_dtd_reply->dtd_hold[del_ndx].del_hold,del_col_cnt)
     ENDIF
     IF (del_col_cnt > 0)
      rs_dtd_reply->dtd_hold[del_ndx].del_cnt = del_col_cnt
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    GO TO exit_program
   ENDIF
   SET dm_err->eproc = concat("Loading Reference/Mergeable Ind.")
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SELECT INTO "NL:"
    FROM (parser(s_dtd_name) dtd)
    WHERE dtd.table_name=patstring(ac_suf_tbl_name)
     AND dtd.reference_ind=1
    ORDER BY dtd.table_name
    DETAIL
     del_ndx = 0, del_ndx = locateval(del_ndx,1,rs_dtd_reply->rs_tbl_cnt,dtd.table_name,rs_dtd_reply
      ->dtd_hold[del_ndx].tbl_name), rs_dtd_reply->dtd_hold[del_ndx].ref_ind = dtd.reference_ind,
     rs_dtd_reply->dtd_hold[del_ndx].mrg_ind = dtd.mergeable_ind
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = value(rs_dtd_reply->rs_tbl_cnt)),
     dm_info i,
     (dummyt dt  WITH seq = 100)
    PLAN (d)
     JOIN (dt
     WHERE (dt.seq <= rs_dtd_reply->dtd_hold[d.seq].del_cnt)
      AND (rs_dtd_reply->dtd_hold[d.seq].del_hold[dt.seq].trans_ind=0))
     JOIN (i
     WHERE i.info_domain=concat("RDDS TRANS COLUMN:",rs_dtd_reply->dtd_hold[d.seq].tbl_name)
      AND (i.info_name=rs_dtd_reply->dtd_hold[d.seq].del_hold[dt.seq].del_name))
    DETAIL
     rs_dtd_reply->dtd_hold[d.seq].del_hold[dt.seq].trans_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (i_log_type="REFCHG")
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = size(rs_dtd_reply->dtd_hold,5))
     DETAIL
      s_load_cnt = 0, s_del_size_hold = 0, s_del_size_hold = size(rs_dtd_reply->dtd_hold[d.seq].
       del_hold,5),
      stat = alterlist(order_pk->ord_hold,s_del_size_hold)
      IF (s_del_size_hold > 0)
       FOR (del_cnt = 1 TO s_del_size_hold)
         IF ((((rs_dtd_reply->dtd_hold[d.seq].del_hold[del_cnt].del_name IN ("*_ID", "*_CD",
         "CODE_VALUE"))) OR ((rs_dtd_reply->dtd_hold[d.seq].del_hold[del_cnt].trans_ind=1))) )
          s_load_cnt = (s_load_cnt+ 1), order_pk->ord_hold[s_load_cnt].ord_name = rs_dtd_reply->
          dtd_hold[d.seq].del_hold[del_cnt].del_name, order_pk->ord_hold[s_load_cnt].ord_datatype =
          rs_dtd_reply->dtd_hold[d.seq].del_hold[del_cnt].del_datatype,
          order_pk->ord_hold[s_load_cnt].ord_where = rs_dtd_reply->dtd_hold[d.seq].del_hold[del_cnt].
          del_where, order_pk->ord_hold[s_load_cnt].trans_ind = 1
         ENDIF
       ENDFOR
       IF (s_load_cnt != s_del_size_hold)
        FOR (del_cnt = 1 TO s_del_size_hold)
          IF ( NOT ((rs_dtd_reply->dtd_hold[d.seq].del_hold[del_cnt].del_name IN ("*_ID", "*_CD",
          "CODE_VALUE")))
           AND (rs_dtd_reply->dtd_hold[d.seq].del_hold[del_cnt].trans_ind=0))
           s_load_cnt = (s_load_cnt+ 1), order_pk->ord_hold[s_load_cnt].ord_name = rs_dtd_reply->
           dtd_hold[d.seq].del_hold[del_cnt].del_name, order_pk->ord_hold[s_load_cnt].ord_datatype =
           rs_dtd_reply->dtd_hold[d.seq].del_hold[del_cnt].del_datatype,
           order_pk->ord_hold[s_load_cnt].ord_where = rs_dtd_reply->dtd_hold[d.seq].del_hold[del_cnt]
           .del_where, order_pk->ord_hold[s_load_cnt].trans_ind = 0
          ENDIF
        ENDFOR
       ENDIF
       s_load_cnt = 0
       FOR (s_load_cnt = 1 TO s_del_size_hold)
         rs_dtd_reply->dtd_hold[d.seq].del_hold[s_load_cnt].del_name = "", rs_dtd_reply->dtd_hold[d
         .seq].del_hold[s_load_cnt].del_datatype = "", rs_dtd_reply->dtd_hold[d.seq].del_hold[
         s_load_cnt].del_where = "",
         rs_dtd_reply->dtd_hold[d.seq].del_hold[s_load_cnt].trans_ind = 0, rs_dtd_reply->dtd_hold[d
         .seq].del_hold[s_load_cnt].trans_ind = order_pk->ord_hold[s_load_cnt].trans_ind,
         rs_dtd_reply->dtd_hold[d.seq].del_hold[s_load_cnt].del_name = order_pk->ord_hold[s_load_cnt]
         .ord_name,
         rs_dtd_reply->dtd_hold[d.seq].del_hold[s_load_cnt].del_datatype = order_pk->ord_hold[
         s_load_cnt].ord_datatype
         IF (s_load_cnt=1)
          rs_dtd_reply->dtd_hold[d.seq].del_hold[s_load_cnt].del_where = concat("WHERE ",
           dm2_rdds_get_tbl_alias(rs_dtd_reply->dtd_hold[d.seq].tbl_suffix),".",trim(order_pk->
            ord_hold[s_load_cnt].ord_name))
         ELSE
          rs_dtd_reply->dtd_hold[d.seq].del_hold[s_load_cnt].del_where = concat(" AND ",
           dm2_rdds_get_tbl_alias(rs_dtd_reply->dtd_hold[d.seq].tbl_suffix),".",trim(order_pk->
            ord_hold[s_load_cnt].ord_name))
         ENDIF
       ENDFOR
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE create_pk_where_function_ora(i_dtd_ndx,io_drop_cnt,io_stmt_cnt,i_local_ind)
   DECLARE s_parm_list = vc
   DECLARE s_func_name = vc
   DECLARE s_drop_func_name = vc
   FREE RECORD iu_pk_where
   RECORD iu_pk_where(
     1 data[*]
       2 str = vc
   )
   FREE RECORD del_pk_where
   RECORD del_pk_where(
     1 data[*]
       2 str = vc
   )
   CALL generate_pk_where_str_ora(i_dtd_ndx,s_parm_list,iu_pk_where,del_pk_where,i_local_ind)
   IF (i_local_ind=0)
    SET s_func_name = concat("REFCHG_PK_WHERE_",rs_dtd_reply->dtd_hold[i_dtd_ndx].tbl_suffix,"_1")
    SET s_drop_func_name = ""
    SELECT INTO "NL:"
     uo.object_name
     FROM user_objects uo
     WHERE uo.object_name=patstring(concat("REFCHG_PK_WHERE_",rs_dtd_reply->dtd_hold[i_dtd_ndx].
       tbl_suffix,"*"))
      AND uo.object_type="FUNCTION"
     DETAIL
      IF (uo.object_name=concat("REFCHG_PK_WHERE_",rs_dtd_reply->dtd_hold[i_dtd_ndx].tbl_suffix,"_1")
      )
       s_drop_func_name = uo.object_name, s_func_name = concat("REFCHG_PK_WHERE_",rs_dtd_reply->
        dtd_hold[i_dtd_ndx].tbl_suffix,"_2")
      ELSE
       s_drop_func_name = uo.object_name, s_func_name = concat("REFCHG_PK_WHERE_",rs_dtd_reply->
        dtd_hold[i_dtd_ndx].tbl_suffix,"_1")
      ENDIF
     WITH nocounter
    ;end select
   ELSE
    SET s_func_name = concat("REFCHG_PK_WHERE_LOCAL_",rs_dtd_reply->dtd_hold[i_dtd_ndx].tbl_suffix)
   ENDIF
   SET rs_dtd_reply->dtd_hold[i_dtd_ndx].pkw_function = s_func_name
   IF (daf_is_not_blank(s_drop_func_name))
    SET io_drop_cnt = (io_drop_cnt+ 1)
    IF (mod(io_drop_cnt,50)=1)
     SET stat = alterlist(drop_func->data,(io_drop_cnt+ 49))
    ENDIF
    SET drop_func->data[io_drop_cnt].stmt = concat("drop function ",s_drop_func_name)
   ENDIF
   CALL stmt_push(io_stmt_cnt,concat('RDB ASIS("create or replace function ',rs_dtd_reply->dtd_hold[
     i_dtd_ndx].pkw_function,'")'))
   CALL stmt_push(io_stmt_cnt,concat('ASIS("(',s_parm_list,') return varchar2 as ")'))
   CALL stmt_push(io_stmt_cnt,'ASIS("  v_pk_where_hold dm_chg_log.pk_where%TYPE; ")')
   CALL stmt_push(io_stmt_cnt,'ASIS("begin ")')
   CALL stmt_push(io_stmt_cnt,^ASIS("  if i_type = 'INS/UPD' then ")^)
   CALL stmt_push(io_stmt_cnt,'ASIS("      select ")')
   FOR (pk_ndx = 1 TO size(iu_pk_where->data,5))
     CALL stmt_push(io_stmt_cnt,iu_pk_where->data[pk_ndx].str)
   ENDFOR
   CALL stmt_push(io_stmt_cnt,'ASIS(" into v_pk_where_hold from dual;")')
   CALL stmt_push(io_stmt_cnt,^ASIS("  elsif i_type = 'DELETE' then ")^)
   CALL stmt_push(io_stmt_cnt,'ASIS("      select ")')
   FOR (pk_ndx = 1 TO size(del_pk_where->data,5))
     CALL stmt_push(io_stmt_cnt,del_pk_where->data[pk_ndx].str)
   ENDFOR
   CALL stmt_push(io_stmt_cnt,'ASIS(" into v_pk_where_hold from dual;")')
   CALL stmt_push(io_stmt_cnt,'ASIS("  end if; ")')
   CALL stmt_push(io_stmt_cnt,'ASIS("  return(v_pk_where_hold); ")')
   CALL stmt_push(io_stmt_cnt,'ASIS("end; ")')
   CALL stmt_push(io_stmt_cnt,"end go")
   SET stat = alterlist(stmt_buffer->data,v_stmt_cnt)
   EXECUTE dm2_stmt_exe "FUNCTION", rs_dtd_reply->dtd_hold[i_dtd_ndx].pkw_function WITH replace(
    "REQUEST","STMT_BUFFER"), replace("REPLY","SE_REPLY")
   SET io_stmt_cnt = 0
   IF ((se_reply->err_ind=1))
    SET dm_err->emsg = "Error occurred in dm2_stmt_exe."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
 END ;Subroutine
 SUBROUTINE generate_pk_where_str_ora(i_dtd_ndx,o_parm_list,io_iu_pk_where,io_del_pk_where,
  i_local_ind)
   DECLARE s_temp_pk = vc
   DECLARE s_temp_pkn = vc
   DECLARE s_temp_type = vc
   DECLARE s_temp_trans_ind = i2
   DECLARE s_temp_pe_name = vc
   DECLARE s_cur_parm = vc
   DECLARE s_base1 = vc
   DECLARE s_base2 = vc
   DECLARE s_upto_id_cnt = i4
   DECLARE s_type = vc
   DECLARE s_pk_where_cnt = i4 WITH noconstant(0)
   DECLARE s_parm_cnt = i4
   DECLARE s_concat_ind = i2
   DECLARE s_temp_str = vc
   DECLARE s_insert_pkw_parm_pe_col = vc
   DECLARE s_insert_ndx = i4
   DECLARE s_dcd_name = vc
   DECLARE gpso_parm = vc
   DECLARE gpso_cnt = i4
   DECLARE gpso_idx = i4
   SET s_dcd_name = "DM_COLUMNS_DOC_LOCAL"
   SET o_parm_list = "i_type varchar2"
   FOR (type_ndx = 1 TO 2)
     SET s_concat_ind = 0
     SET s_pk_where_cnt = 0
     IF (type_ndx=1)
      SET s_type = "INS/UPD"
     ELSE
      SET s_type = "DELETE"
     ENDIF
     IF (type_ndx=1)
      SET s_parm_cnt = 0
      IF (i_local_ind=0)
       DELETE  FROM dm_refchg_pkw_parm drpp
        WHERE (drpp.table_name=rs_dtd_reply->dtd_hold[i_dtd_ndx].tbl_name)
       ;end delete
      ENDIF
     ENDIF
     IF ((((rs_dtd_reply->dtd_hold[i_dtd_ndx].del_cnt=0)) OR (type_ndx=2
      AND (rs_dtd_reply->dtd_hold[i_dtd_ndx].vers134_ind=1))) )
      SET s_upto_id_cnt = rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_cnt
     ELSE
      SET s_upto_id_cnt = rs_dtd_reply->dtd_hold[i_dtd_ndx].del_cnt
     ENDIF
     FOR (where_ndx = 1 TO s_upto_id_cnt)
       IF (size(rs_dtd_reply->dtd_hold[i_dtd_ndx].del_hold,5) > 0
        AND  NOT (type_ndx=2
        AND (rs_dtd_reply->dtd_hold[i_dtd_ndx].vers134_ind=1)))
        SET s_temp_pk = rs_dtd_reply->dtd_hold[i_dtd_ndx].del_hold[where_ndx].del_where
        SET s_temp_pkn = rs_dtd_reply->dtd_hold[i_dtd_ndx].del_hold[where_ndx].del_name
        SET s_temp_type = rs_dtd_reply->dtd_hold[i_dtd_ndx].del_hold[where_ndx].del_datatype
        SET s_temp_trans_ind = rs_dtd_reply->dtd_hold[i_dtd_ndx].del_hold[where_ndx].trans_ind
       ELSE
        SET s_temp_pk = rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_hold[where_ndx].pk_where
        SET s_temp_pkn = rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_hold[where_ndx].pk_name
        SET s_temp_type = rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_hold[where_ndx].pk_datatype
        SET s_temp_trans_ind = rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_hold[where_ndx].trans_ind
       ENDIF
       SET s_temp_pe_name = " "
       SET s_insert_pkw_parm_pe_col = " "
       SELECT
        IF (size(rs_dtd_reply->dtd_hold[i_dtd_ndx].del_hold,5) > 0
         AND  NOT (type_ndx=2
         AND (rs_dtd_reply->dtd_hold[i_dtd_ndx].vers134_ind=1)))
         WHERE (dcd.table_name=rs_dtd_reply->dtd_hold[i_dtd_ndx].tbl_name)
          AND (dcd.column_name=rs_dtd_reply->dtd_hold[i_dtd_ndx].del_hold[where_ndx].del_name)
          AND  NOT (dcd.parent_entity_col IN ("", " "))
        ELSE
         WHERE (dcd.table_name=rs_dtd_reply->dtd_hold[i_dtd_ndx].tbl_name)
          AND (dcd.column_name=rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_hold[where_ndx].pk_name)
          AND  NOT (dcd.parent_entity_col IN ("", " "))
        ENDIF
        INTO "nl:"
        dcd.parent_entity_col
        FROM (parser(s_dcd_name) dcd)
        DETAIL
         s_insert_pkw_parm_pe_col = dcd.parent_entity_col, s_temp_pe_name = concat("i_",substring(1,
           28,dcd.parent_entity_col))
        WITH nocounter
       ;end select
       SET loop_cnt = 0
       IF (type_ndx=1
        AND daf_is_not_blank(s_insert_pkw_parm_pe_col)
        AND locateval(s_insert_ndx,1,size(rs_dtd_reply->dtd_hold[i_dtd_ndx].del_hold,5),
        s_insert_pkw_parm_pe_col,rs_dtd_reply->dtd_hold[i_dtd_ndx].del_hold[s_insert_ndx].del_name)=0
        AND locateval(s_insert_ndx,1,size(rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_hold,5),
        s_insert_pkw_parm_pe_col,rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_hold[s_insert_ndx].pk_name)=0)
        SELECT INTO "NL:"
         FROM dm_refchg_pkw_parm
         WHERE column_name=s_insert_pkw_parm_pe_col
          AND (table_name=rs_dtd_reply->dtd_hold[i_dtd_ndx].tbl_name)
         WITH nocounter
        ;end select
        SET gpso_cnt = curqual
        IF (gpso_cnt=0)
         SET s_parm_cnt = (s_parm_cnt+ 1)
         SET stat = alterlist(rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_where_parm,s_parm_cnt)
         SET rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_where_parm[s_parm_cnt].column_name =
         s_insert_pkw_parm_pe_col
         SET o_parm_list = concat(o_parm_list,",i_",substring(1,28,s_insert_pkw_parm_pe_col),
          " VARCHAR2")
         IF (i_local_ind=0)
          INSERT  FROM dm_refchg_pkw_parm
           SET parm_nbr = s_parm_cnt, column_name = s_insert_pkw_parm_pe_col, table_name =
            rs_dtd_reply->dtd_hold[i_dtd_ndx].tbl_name
           WITH nocounter
          ;end insert
         ENDIF
        ENDIF
       ENDIF
       IF (daf_is_blank(s_temp_pe_name))
        SET s_temp_pe_name = "''''||' '||''''"
       ELSE
        SET s_temp_pe_name = concat("dm_refchg_breakup_str(",s_temp_pe_name,")")
       ENDIF
       SET s_cur_parm = concat("i_",substring(1,28,s_temp_pkn))
       CASE (s_temp_type)
        OF "VARCHAR":
        OF "ROWID":
        OF "VARCHAR2":
        OF "CHAR":
         IF (((type_ndx=1) OR (type_ndx=2
          AND (rs_dtd_reply->dtd_hold[i_dtd_ndx].vers134_ind=1))) )
          SET gpso_parm = concat(",",s_cur_parm," ",s_temp_type)
          IF (findstring(gpso_parm,o_parm_list)=0)
           SET o_parm_list = concat(o_parm_list,",",s_cur_parm," ",s_temp_type)
          ENDIF
          IF (locateval(gpso_idx,1,size(rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_where_parm,5),s_temp_pkn,
           rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_where_parm[gpso_idx].column_name)=0)
           SET s_parm_cnt = (s_parm_cnt+ 1)
           SET stat = alterlist(rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_where_parm,s_parm_cnt)
           SET rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_where_parm[s_parm_cnt].column_name = s_temp_pkn
           IF (i_local_ind=0)
            SELECT INTO "NL:"
             FROM dm_refchg_pkw_parm
             WHERE column_name=s_temp_pkn
              AND (table_name=rs_dtd_reply->dtd_hold[i_dtd_ndx].tbl_name)
             WITH nocounter
            ;end select
            SET gpso_cnt = curqual
            IF (gpso_cnt=0)
             INSERT  FROM dm_refchg_pkw_parm
              SET parm_nbr = s_parm_cnt, column_name = s_temp_pkn, table_name = rs_dtd_reply->
               dtd_hold[i_dtd_ndx].tbl_name
             ;end insert
            ENDIF
           ENDIF
          ENDIF
         ENDIF
         SET s_pk_where_cnt = (s_pk_where_cnt+ 1)
         IF (s_type="INS/UPD")
          SET stat = alterlist(io_iu_pk_where->data,s_pk_where_cnt)
         ELSE
          SET stat = alterlist(io_del_pk_where->data,s_pk_where_cnt)
         ENDIF
         SET s_base1 = concat(s_temp_pk,"'||decode(",s_cur_parm,
          ",null,' is null',chr(0),'=char(0)','='||dm_refchg_breakup_str(",s_cur_parm,
          ")")
         SET s_base2 = concat(s_temp_pk,"'||decode(",s_cur_parm,
          ",null,' is null',chr(0),'=char(0)','='||dm_refchg_breakup_str(",s_cur_parm,
          "))")
         IF (where_ndx != s_upto_id_cnt)
          IF ((rs_dtd_reply->dtd_hold[i_dtd_ndx].mrg_del_ind=1)
           AND s_type="DELETE")
           SET io_del_pk_where->data[s_pk_where_cnt].str = concat(^ASIS("''''||'^,s_base2,
            "||''''||','||",'")')
          ELSE
           SET s_temp_str = concat(^ASIS(" '^,s_base1,")||",'")')
           IF (s_type="INS/UPD")
            SET io_iu_pk_where->data[s_pk_where_cnt].str = s_temp_str
           ELSE
            SET io_del_pk_where->data[s_pk_where_cnt].str = s_temp_str
           ENDIF
          ENDIF
         ELSE
          IF ((rs_dtd_reply->dtd_hold[i_dtd_ndx].mrg_del_ind=1)
           AND s_type="DELETE")
           IF (s_concat_ind=0)
            SET io_del_pk_where->data[s_pk_where_cnt].str = concat(^ASIS(" '^,s_base2,'")')
           ELSE
            SET io_del_pk_where->data[s_pk_where_cnt].str = concat(^ASIS("''''||'^,s_base2,
             ^||''''||')'")^)
           ENDIF
          ELSE
           IF (s_upto_id_cnt > 1
            AND size(rs_dtd_reply->dtd_hold[i_dtd_ndx].del_hold,5) > 0)
            SET s_temp_str = concat(^ASIS(" ' '|| '^,s_base1,')")')
            IF (s_type="INS/UPD")
             SET io_iu_pk_where->data[s_pk_where_cnt].str = s_temp_str
            ELSE
             SET io_del_pk_where->data[s_pk_where_cnt].str = s_temp_str
            ENDIF
           ELSE
            SET s_temp_str = concat(^ASIS("  '^,s_base1,')")')
            IF (s_type="INS/UPD")
             SET io_iu_pk_where->data[s_pk_where_cnt].str = s_temp_str
            ELSE
             SET io_del_pk_where->data[s_pk_where_cnt].str = s_temp_str
            ENDIF
           ENDIF
          ENDIF
         ENDIF
        OF "DATE":
         IF (((type_ndx=1) OR (type_ndx=2
          AND (rs_dtd_reply->dtd_hold[i_dtd_ndx].vers134_ind=1))) )
          SET gpso_parm = concat(",",s_cur_parm," ",s_temp_type)
          IF (findstring(gpso_parm,o_parm_list)=0)
           SET o_parm_list = concat(o_parm_list,",",s_cur_parm," ",s_temp_type)
          ENDIF
          IF (locateval(gpso_idx,1,size(rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_where_parm,5),s_temp_pkn,
           rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_where_parm[gpso_idx].column_name)=0)
           SET s_parm_cnt = (s_parm_cnt+ 1)
           SET stat = alterlist(rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_where_parm,s_parm_cnt)
           SET rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_where_parm[s_parm_cnt].column_name = s_temp_pkn
           IF (i_local_ind=0)
            SELECT INTO "NL:"
             FROM dm_refchg_pkw_parm
             WHERE column_name=s_temp_pkn
              AND (table_name=rs_dtd_reply->dtd_hold[i_dtd_ndx].tbl_name)
             WITH nocounter
            ;end select
            SET gpso_cnt = curqual
            IF (gpso_cnt=0)
             INSERT  FROM dm_refchg_pkw_parm
              SET parm_nbr = s_parm_cnt, column_name = s_temp_pkn, table_name = rs_dtd_reply->
               dtd_hold[i_dtd_ndx].tbl_name
             ;end insert
            ENDIF
           ENDIF
          ENDIF
         ENDIF
         SET s_pk_where_cnt = (s_pk_where_cnt+ 1)
         IF (s_type="INS/UPD")
          SET stat = alterlist(io_iu_pk_where->data,s_pk_where_cnt)
         ELSE
          SET stat = alterlist(io_del_pk_where->data,s_pk_where_cnt)
         ENDIF
         SET s_base1 = concat("'||decode(to_char(",s_cur_parm,
          "),null,' is null ',' = cnvtdatetime('||''''||to_char(",s_cur_parm,")||''''||')')")
         SET s_base2 = concat(" ''''||'",s_temp_pk,"'||decode(to_char(",s_cur_parm,
          "),null,' is null ',' = cnvtdatetime('||'",
          char(94),"'||to_char(",s_cur_parm,")||'",char(94),
          "'||')')||''''")
         IF (where_ndx != s_upto_id_cnt)
          IF ((rs_dtd_reply->dtd_hold[i_dtd_ndx].mrg_del_ind=1)
           AND s_type="DELETE")
           SET io_del_pk_where->data[s_pk_where_cnt].str = concat('ASIS("',s_base2,^||','||")^)
          ELSE
           SET s_temp_str = concat(^ASIS(" '^,s_temp_pk," ",s_base1,'||")')
           IF (s_type="INS/UPD")
            SET io_iu_pk_where->data[s_pk_where_cnt].str = s_temp_str
           ELSE
            SET io_del_pk_where->data[s_pk_where_cnt].str = s_temp_str
           ENDIF
          ENDIF
         ELSE
          IF ((rs_dtd_reply->dtd_hold[i_dtd_ndx].mrg_del_ind=1)
           AND s_type="DELETE")
           SET io_del_pk_where->data[s_pk_where_cnt].str = concat('ASIS("',s_base2,^||')'")^)
          ELSE
           SET s_temp_str = concat(^ASIS(" '^,s_temp_pk,s_base1,'")')
           IF (s_type="INS/UPD")
            SET io_iu_pk_where->data[s_pk_where_cnt].str = s_temp_str
           ELSE
            SET io_del_pk_where->data[s_pk_where_cnt].str = s_temp_str
           ENDIF
          ENDIF
         ENDIF
        ELSE
         IF (((type_ndx=1) OR (type_ndx=2
          AND (rs_dtd_reply->dtd_hold[i_dtd_ndx].vers134_ind=1))) )
          SET gpso_parm = concat(",",s_cur_parm," ",s_temp_type)
          IF (findstring(gpso_parm,o_parm_list)=0)
           SET o_parm_list = concat(o_parm_list,",",s_cur_parm," ",s_temp_type)
          ENDIF
          IF (locateval(gpso_idx,1,size(rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_where_parm,5),s_temp_pkn,
           rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_where_parm[gpso_idx].column_name)=0)
           SET s_parm_cnt = (s_parm_cnt+ 1)
           SET stat = alterlist(rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_where_parm,s_parm_cnt)
           SET rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_where_parm[s_parm_cnt].column_name = s_temp_pkn
           IF (i_local_ind=0)
            SELECT INTO "NL:"
             FROM dm_refchg_pkw_parm
             WHERE column_name=s_temp_pkn
              AND (table_name=rs_dtd_reply->dtd_hold[i_dtd_ndx].tbl_name)
             WITH nocounter
            ;end select
            SET gpso_cnt = curqual
            IF (gpso_cnt=0)
             INSERT  FROM dm_refchg_pkw_parm
              SET parm_nbr = s_parm_cnt, column_name = s_temp_pkn, table_name = rs_dtd_reply->
               dtd_hold[i_dtd_ndx].tbl_name
             ;end insert
            ENDIF
           ENDIF
          ENDIF
         ENDIF
         SET s_pk_where_cnt = (s_pk_where_cnt+ 1)
         IF (s_type="INS/UPD")
          SET stat = alterlist(io_iu_pk_where->data,s_pk_where_cnt)
         ELSE
          SET stat = alterlist(io_del_pk_where->data,s_pk_where_cnt)
         ENDIF
         IF (s_temp_trans_ind=1
          AND s_type="DELETE"
          AND (((rs_dtd_reply->dtd_hold[i_dtd_ndx].mrg_del_ind=1)) OR ((rs_dtd_reply->dtd_hold[
         i_dtd_ndx].vers134_ind=1))) )
          SET s_base1 = concat("''''||'",s_temp_pk,"='||''''||',dm_trans3('||''''||'",rs_dtd_reply->
           dtd_hold[i_dtd_ndx].tbl_name,"'||''''||','||''''||'",
           s_temp_pkn,"'||''''||','||decode(to_char(",s_cur_parm,"),null,' null ',decode(trunc(",
           s_cur_parm,
           ") - ",s_cur_parm,",0,to_char(",s_cur_parm,")||'.0',to_char(",
           s_cur_parm,")))||', <SOURCE_IND>,'||",s_temp_pe_name,"||')")
          IF (where_ndx != s_upto_id_cnt)
           IF (s_concat_ind=0)
            SET s_concat_ind = 1
            SET io_del_pk_where->data[s_pk_where_cnt].str = concat(^ASIS(" 'CONCAT('||^,s_base1,
             ",'||",'")')
           ELSE
            SET io_del_pk_where->data[s_pk_where_cnt].str = concat('ASIS(" ',s_base1,",'||",'")')
           ENDIF
          ELSE
           IF (s_concat_ind=0)
            SET s_concat_ind = 1
            SET io_del_pk_where->data[s_pk_where_cnt].str = concat(^ASIS(" 'CONCAT('||^,s_base1,
             ^)'")^)
           ELSE
            SET io_del_pk_where->data[s_pk_where_cnt].str = concat('ASIS("',s_base1,^)'")^)
           ENDIF
          ENDIF
         ELSE
          SET s_base2 = concat("'",s_temp_pk,"'||decode(to_char(",s_cur_parm,
           "),null,' is null ',' ='||decode(trunc(",
           s_cur_parm,") - ",s_cur_parm,",0,to_char(",s_cur_parm,
           ")||'.0',to_char(",s_cur_parm,")))")
          IF (where_ndx != s_upto_id_cnt)
           IF ((rs_dtd_reply->dtd_hold[i_dtd_ndx].mrg_del_ind=1)
            AND s_type="DELETE")
            SET io_del_pk_where->data[s_pk_where_cnt].str = concat(^ASIS(" ''''||^,s_base2,
             ^||''''||','||")^)
           ELSE
            SET s_temp_str = concat('ASIS(" ',s_base2,'||")')
            IF (s_type="INS/UPD")
             SET io_iu_pk_where->data[s_pk_where_cnt].str = s_temp_str
            ELSE
             SET io_del_pk_where->data[s_pk_where_cnt].str = s_temp_str
            ENDIF
           ENDIF
          ELSE
           IF ((rs_dtd_reply->dtd_hold[i_dtd_ndx].mrg_del_ind=1)
            AND s_type="DELETE")
            SET io_del_pk_where->data[s_pk_where_cnt].str = concat(^ASIS(" ''''||^,s_base2,
             ^||''''||')'")^)
           ELSE
            SET s_temp_str = concat('ASIS(" ',s_base2,'")')
            IF (s_type="INS/UPD")
             SET io_iu_pk_where->data[s_pk_where_cnt].str = s_temp_str
            ELSE
             SET io_del_pk_where->data[s_pk_where_cnt].str = s_temp_str
            ENDIF
           ENDIF
          ENDIF
         ENDIF
       ENDCASE
     ENDFOR
     IF (type_ndx=1
      AND (rs_dtd_reply->dtd_hold[i_dtd_ndx].tbl_name="SEG_GRP_SEQ_R"))
      SET o_parm_list = concat(o_parm_list,",","I_SEG_CD"," ","NUMBER")
      SET s_parm_cnt = (s_parm_cnt+ 1)
      IF (i_local_ind=0)
       SET dm_err->eproc = "Inserting SEG_GRP_SEQ_R info into DM_REFCHG_PKW_PARM."
       CALL disp_msg(" ",dm_err->logfile,dm_err->err_ind)
       INSERT  FROM dm_refchg_pkw_parm drpp
        SET drpp.parm_nbr = s_parm_cnt, drpp.column_name = "SEG_CD", drpp.table_name = rs_dtd_reply->
         dtd_hold[i_dtd_ndx].tbl_name
        WITH nocounter
       ;end insert
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        GO TO exit_program
       ENDIF
      ENDIF
      SET stat = alterlist(rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_where_parm,s_parm_cnt)
      SET rs_dtd_reply->dtd_hold[i_dtd_ndx].pk_where_parm[s_parm_cnt].column_name = "SEG_CD"
      SET io_iu_pk_where->data[s_pk_where_cnt].str = concat(
       ^ASIS("'where t3292.seg_cd in(select sr.seg_cd from segment_reference sr where sr.seg_grp_cd = (^,
       "(select sr2.seg_grp_cd from segment_reference sr2 where sr2.seg_cd = '",
       "||decode(trunc(i_seg_cd) - i_seg_cd,0,to_char(i_seg_cd) ||","'.0',to_char(i_seg_cd))",
       ^||')))' ")^)
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE stmt_push(io_cnt,i_text)
   SET io_cnt = (io_cnt+ 1)
   IF (mod(io_cnt,30)=1)
    SET stat = alterlist(stmt_buffer->data,(io_cnt+ 29))
   ENDIF
   SET stmt_buffer->data[io_cnt].stmt = i_text
 END ;Subroutine
 SUBROUTINE create_ptam_function_ora(sbr_trg_data_rs,i_trg_ndx,io_drop_cnt,io_stmt_cnt)
   DECLARE s_tab_name = vc WITH protect, noconstant(" ")
   DECLARE s_func_name = vc WITH protect, noconstant(" ")
   DECLARE s_drop_func_name = vc WITH protect, noconstant(" ")
   DECLARE s_ptam_template = vc WITH protect, noconstant(" ")
   DECLARE cpfo_ndx = i4 WITH protect, noconstant(0)
   DECLARE s_ptam_func_name = vc WITH protect, noconstant(" ")
   DECLARE s_col_name = vc WITH protect, noconstant(" ")
   DECLARE s_idx = i4 WITH protect, noconstant(0)
   DECLARE s_parm_name = vc WITH protect, noconstant(" ")
   DECLARE s_cust_idx = i4 WITH protect, noconstant(0)
   DECLARE s_cust_ind = i2 WITH protect, noconstant(0)
   DECLARE s_cust_parm_ind = i2 WITH protect, noconstant(0)
   DECLARE s_cust_name = vc WITH protect, noconstant(" ")
   DECLARE s_func_exist_ind = i2 WITH protect, noconstant(0)
   FREE RECORD cpfo_parm
   RECORD cpfo_parm(
     1 parm_cnt = i4
     1 qual[*]
       2 parm_name = vc
   ) WITH protect
   SET s_tab_name = sbr_trg_data_rs->qual[i_trg_ndx].table_name
   SET s_ptam_func_name = concat("PTAM_MATCH_QUERY_",sbr_trg_data_rs->qual[i_trg_ndx].table_suffix)
   SET s_func_name = concat("REFCHG_PTAM_MATCH_",sbr_trg_data_rs->qual[i_trg_ndx].table_suffix,"_1")
   SET s_drop_func_name = ""
   SET dm_err->eproc = "Determining ptam_match function name."
   SELECT INTO "NL:"
    uo.object_name
    FROM user_objects uo
    WHERE uo.object_name=patstring(concat("REFCHG_PTAM_MATCH_",sbr_trg_data_rs->qual[i_trg_ndx].
      table_suffix,"*"))
     AND uo.object_type="FUNCTION"
    DETAIL
     s_func_exist_ind = 1
     IF (uo.object_name=concat("REFCHG_PTAM_MATCH_",sbr_trg_data_rs->qual[i_trg_ndx].table_suffix,
      "_1"))
      s_drop_func_name = uo.object_name, s_func_name = concat("REFCHG_PTAM_MATCH_",sbr_trg_data_rs->
       qual[i_trg_ndx].table_suffix,"_2")
     ELSE
      s_drop_func_name = uo.object_name, s_func_name = concat("REFCHG_PTAM_MATCH_",sbr_trg_data_rs->
       qual[i_trg_ndx].table_suffix,"_1")
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   IF ((sbr_trg_data_rs->qual[i_trg_ndx].ptam_skip_recreate_ind=1)
    AND s_func_exist_ind=1)
    SET sbr_trg_data_rs->qual[i_trg_ndx].ptam_match_function = s_drop_func_name
   ELSE
    SET sbr_trg_data_rs->qual[i_trg_ndx].ptam_match_function = s_func_name
    SET sbr_trg_data_rs->qual[i_trg_ndx].ptam_skip_recreate_ind = 0
    IF (daf_is_not_blank(s_drop_func_name))
     SET io_drop_cnt = (io_drop_cnt+ 1)
     IF (mod(io_drop_cnt,50)=1)
      SET stat = alterlist(drop_func->data,(io_drop_cnt+ 49))
     ENDIF
     SET drop_func->data[io_drop_cnt].stmt = concat("drop function ",s_drop_func_name)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Gathering PTAM match parms."
   SELECT INTO "nl:"
    dpwp.column_name
    FROM dm_pk_where_parm dpwp
    WHERE dpwp.table_name=s_tab_name
     AND dpwp.function_type="PTAM_MATCH"
     AND dpwp.delete_ind=1
    ORDER BY dpwp.parm_nbr, dpwp.column_name
    HEAD REPORT
     parm_cnt = 0
    DETAIL
     parm_cnt = (parm_cnt+ 1), stat = alterlist(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,parm_cnt),
     sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[parm_cnt].column_name = cnvtupper(dpwp.column_name),
     sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[parm_cnt].data_type = cnvtupper(dpwp.data_type),
     sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[parm_cnt].exist_ind = dpwp.exist_ind, sbr_trg_data_rs
     ->qual[i_trg_ndx].ptam_parm[parm_cnt].trans_ind = dpwp.trans_ind
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   SET dm_err->eproc = concat("Gathering custom pl/sql info for table ",s_tab_name)
   SELECT INTO "nl:"
    FROM dm_refchg_sql_obj drso
    WHERE drso.active_ind=1
     AND drso.execution_flag IN (1, 2)
     AND drso.table_name=s_tab_name
     AND expand(s_idx,1,size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,5),drso.column_name,
     sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[s_idx].column_name)
    DETAIL
     cpfo_ndx = locateval(s_idx,1,size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,5),drso.column_name,
      sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[s_idx].column_name), sbr_trg_data_rs->qual[i_trg_ndx
     ].ptam_parm[cpfo_ndx].object_name = drso.object_name, sbr_trg_data_rs->qual[i_trg_ndx].
     ptam_parm[cpfo_ndx].all_exist_ind = 1,
     s_cust_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   IF (s_cust_ind=1)
    SELECT INTO "nl:"
     FROM dm_refchg_sql_obj_parm drsop
     WHERE drsop.active_ind=1
      AND expand(s_idx,1,size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,5),drsop.object_name,
      sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[s_idx].object_name)
     ORDER BY drsop.object_name, drsop.parm_nbr
     HEAD drsop.object_name
      cpfo_ndx = locateval(s_idx,1,size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,5),drsop
       .object_name,sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[s_idx].object_name), parm_cnt = 0
     DETAIL
      parm_cnt = (parm_cnt+ 1), stat = alterlist(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx]
       .custom_parm,parm_cnt), sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].custom_parm[
      parm_cnt].parm_name = drsop.column_name,
      s_cust_idx = locateval(s_idx,1,size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,5),drsop
       .column_name,sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[s_idx].column_name)
      IF (s_cust_idx=0)
       sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].all_exist_ind = 0
      ENDIF
     FOOT  drsop.object_name
      IF ((sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].all_exist_ind=1))
       s_cust_parm_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(- (1))
    ENDIF
    SET s_cust_ind = s_cust_parm_ind
   ENDIF
   SET dm_err->eproc = concat("Gathering RE/PE info for table ",s_tab_name)
   SELECT INTO "nl:"
    dcdl.root_entity_name, dcdl.parent_entity_col
    FROM dm_columns_doc_local dcdl
    WHERE dcdl.table_name=s_tab_name
     AND expand(s_idx,1,size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,5),dcdl.column_name,
     sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[s_idx].column_name)
    DETAIL
     cpfo_ndx = locateval(s_idx,1,size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,5),dcdl.column_name,
      sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[s_idx].column_name), sbr_trg_data_rs->qual[i_trg_ndx
     ].ptam_parm[cpfo_ndx].re_name = cnvtupper(dcdl.root_entity_name), sbr_trg_data_rs->qual[
     i_trg_ndx].ptam_parm[cpfo_ndx].pe_col = cnvtupper(dcdl.parent_entity_col),
     sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].xcptn_flag = dcdl.exception_flg
     IF ((sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].trans_ind=1))
      sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].cnst_val = dcdl.constant_value
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   SET dm_err->eproc = concat("Checking for base62 columns for table ",s_tab_name)
   SELECT INTO "nl:"
    FROM dm_refchg_attribute dra
    WHERE dra.attribute_name="BASE62 NUMERIC VALUE"
     AND dra.table_name=s_tab_name
     AND expand(s_idx,1,size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,5),dra.column_name,
     sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[s_idx].column_name)
    DETAIL
     cpfo_ndx = locateval(s_idx,1,size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,5),dra.column_name,
      sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[s_idx].column_name), sbr_trg_data_rs->qual[i_trg_ndx
     ].ptam_parm[cpfo_ndx].base62_re_name = dra.attribute_char
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   SET dm_err->eproc = concat("Gathering pk_template for table ",s_tab_name)
   SELECT INTO "nl:"
    dpw.ptam_match_query
    FROM dm_pk_where dpw
    WHERE dpw.table_name=s_tab_name
     AND dpw.delete_ind=1
    DETAIL
     s_ptam_template = dpw.ptam_match_query, sbr_trg_data_rs->qual[i_trg_ndx].ptam_hash = dpw
     .ptam_match_hash
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   IF ((sbr_trg_data_rs->qual[i_trg_ndx].ptam_skip_recreate_ind=1))
    RETURN(1)
   ENDIF
   CALL stmt_push(io_stmt_cnt,concat('RDB ASIS("create or replace function ',sbr_trg_data_rs->qual[
     i_trg_ndx].ptam_match_function,'(")'))
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,5))
    SET s_parm_name = substring(1,28,sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].column_name
     )
    IF (cpfo_ndx=1)
     CALL stmt_push(io_stmt_cnt,concat('ASIS("i_',s_parm_name," ",sbr_trg_data_rs->qual[i_trg_ndx].
       ptam_parm[cpfo_ndx].data_type,'")'))
    ELSE
     CALL stmt_push(io_stmt_cnt,concat('ASIS(",i_',s_parm_name," ",sbr_trg_data_rs->qual[i_trg_ndx].
       ptam_parm[cpfo_ndx].data_type,'")'))
    ENDIF
   ENDFOR
   CALL stmt_push(io_stmt_cnt,
    ^ASIS(",i_db_link varchar2 default ' ') return varchar2 as v_ptam_match dm_chg_log.ptam_match_query%TYPE; ")^
    )
   CALL stmt_push(io_stmt_cnt,'ASIS("v_temp_str varchar2(4000); begin ")')
   CALL stmt_push(io_stmt_cnt,concat('ASIS("  select ',s_ptam_template,
     ' into v_ptam_match from dual; ")'))
   CALL stmt_push(io_stmt_cnt,'ASIS("  return(v_ptam_match);")')
   CALL stmt_push(io_stmt_cnt,'ASIS("end; ")')
   CALL stmt_push(io_stmt_cnt,"end go")
   SET stat = alterlist(stmt_buffer->data,io_stmt_cnt)
   EXECUTE dm2_stmt_exe "FUNCTION", sbr_trg_data_rs->qual[i_trg_ndx].ptam_match_function WITH replace
   ("REQUEST","STMT_BUFFER"), replace("REPLY","SE_REPLY")
   SET io_stmt_cnt = 0
   IF ((se_reply->err_ind=1))
    SET dm_err->emsg = "Error occurred in dm2_stmt_exe."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   CALL stmt_push(io_stmt_cnt,concat('RDB ASIS("create or replace function ',s_ptam_func_name,'(")'))
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,5))
    SET s_parm_name = substring(1,28,sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].column_name
     )
    IF (cpfo_ndx=1)
     CALL stmt_push(io_stmt_cnt,concat('ASIS("i_',s_parm_name," ",sbr_trg_data_rs->qual[i_trg_ndx].
       ptam_parm[cpfo_ndx].data_type,'")'))
    ELSE
     CALL stmt_push(io_stmt_cnt,concat('ASIS(",i_',s_parm_name," ",sbr_trg_data_rs->qual[i_trg_ndx].
       ptam_parm[cpfo_ndx].data_type,'")'))
    ENDIF
   ENDFOR
   CALL stmt_push(io_stmt_cnt,
    'ASIS(",i_src_id number,i_tgt_id number,i_db_link varchar2,i_local_ind number ")')
   CALL stmt_push(io_stmt_cnt,^ASIS(",i_xlat_type varchar2 default 'FROM'")^)
   CALL stmt_push(io_stmt_cnt,
    'ASIS(") return number as v_ptam_result number; v_temp_str varchar2(2000); ")')
   CALL stmt_push(io_stmt_cnt,'ASIS("v_match_str varchar(4000); v_mapping_nbr number; begin ")')
   CALL stmt_push(io_stmt_cnt,'ASIS("if i_local_ind = 1 then ")')
   CALL stmt_push(io_stmt_cnt,'ASIS("   v_temp_str := ")')
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,5))
     IF ((sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].exist_ind=1))
      IF (cpfo_ndx=1)
       CALL stmt_push(io_stmt_cnt,concat(^ASIS("'^,sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[
         cpfo_ndx].column_name,^='||")^))
      ELSE
       CALL stmt_push(io_stmt_cnt,concat(^ASIS("||'::'||'^,sbr_trg_data_rs->qual[i_trg_ndx].
         ptam_parm[cpfo_ndx].column_name,^='||")^))
      ENDIF
      IF (daf_is_not_blank(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].cnst_val))
       CALL stmt_push(io_stmt_cnt,concat(^ASIS("'^,sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[
         cpfo_ndx].cnst_val,^'")^))
      ELSE
       SET s_parm_name = substring(1,28,sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].
        column_name)
       IF ((sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].data_type IN ("VARCHAR", "CHAR",
       "VARCHAR2")))
        CALL stmt_push(io_stmt_cnt,concat('ASIS("nvl(i_',s_parm_name,^,'!NL!')")^))
       ELSEIF ((sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].data_type="DATE"))
        CALL stmt_push(io_stmt_cnt,concat('ASIS("nvl(to_char(i_',s_parm_name,
          ^,'DD-MON-YYYY HH24:MI:SS','nls_date_language=american'),'!NL!')")^))
       ELSE
        CALL stmt_push(io_stmt_cnt,concat('ASIS("nvl(to_char(i_',s_parm_name,
          ^,'TM9','nls_numeric_characters=''.,'''),'!NL!')")^))
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   CALL stmt_push(io_stmt_cnt,'ASIS("; else   ")')
   IF (s_cust_ind=1)
    CALL stmt_push(io_stmt_cnt,
     'ASIS("   select di.info_number into v_mapping_nbr from dm_info di where di.info_domain = ")')
    CALL stmt_push(io_stmt_cnt,
     ^ASIS("'RDDS ENV PAIR' and di.info_name = i_src_id||'::'||i_tgt_id; ")^)
   ENDIF
   CALL stmt_push(io_stmt_cnt,'ASIS(" v_match_str := ")')
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,5))
     SET s_col_name = sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].column_name
     SET s_parm_name = substring(1,28,s_col_name)
     IF ((sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].exist_ind=1))
      IF (cpfo_ndx=1)
       CALL stmt_push(io_stmt_cnt,concat(^ASIS("'select ''^,s_col_name,^=''||")^))
      ELSE
       CALL stmt_push(io_stmt_cnt,concat(^ASIS("||''::''||''^,s_col_name,^=''||")^))
      ENDIF
      IF (daf_is_not_blank(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].object_name)
       AND (sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].all_exist_ind=1))
       CALL stmt_push(io_stmt_cnt,'ASIS(" nvl( ")')
       CALL stmt_push(io_stmt_cnt,'ASIS(" to_char(")')
       CALL stmt_push(io_stmt_cnt,concat(^ASIS("'||replace('^,sbr_trg_data_rs->qual[i_trg_ndx].
         ptam_parm[cpfo_ndx].object_name,
         ^','::SOURCE TARGET MAPPING::',to_char(v_mapping_nbr))||'(2")^))
       FOR (s_cust_idx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].custom_parm,5
        ))
         SET s_cust_name = substring(1,28,sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].
          custom_parm[s_cust_idx].parm_name)
         CALL stmt_push(io_stmt_cnt,concat('ASIS(",:c',trim(cnvtstring(s_cust_idx)),'")'))
         SET cpfo_parm->parm_cnt = (cpfo_parm->parm_cnt+ 1)
         SET stat = alterlist(cpfo_parm->qual,cpfo_parm->parm_cnt)
         SET cpfo_parm->qual[cpfo_parm->parm_cnt].parm_name = concat("i_",s_cust_name)
       ENDFOR
       CALL stmt_push(io_stmt_cnt,'ASIS(") ")')
       CALL stmt_push(io_stmt_cnt,'ASIS(")")')
       CALL stmt_push(io_stmt_cnt,^ASIS(",''!NL!'')")^)
      ELSEIF ((((sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].trans_ind=0)
       AND daf_is_blank(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].base62_re_name)) OR ((
      sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].xcptn_flag=1))) )
       SET cpfo_parm->parm_cnt = (cpfo_parm->parm_cnt+ 1)
       SET stat = alterlist(cpfo_parm->qual,cpfo_parm->parm_cnt)
       SET cpfo_parm->qual[cpfo_parm->parm_cnt].parm_name = concat("i_",s_parm_name)
       IF ((sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].data_type IN ("VARCHAR", "CHAR",
       "VARCHAR2")))
        CALL stmt_push(io_stmt_cnt,concat('ASIS("nvl(:p',trim(cnvtstring(cpfo_ndx)),^,''!NL!'')")^))
       ELSEIF ((sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].data_type="DATE"))
        CALL stmt_push(io_stmt_cnt,concat('ASIS("nvl(to_char(:p',trim(cnvtstring(cpfo_ndx)),
          ^,''DD-MON-YYYY HH24:MI:SS'',''nls_date_language=american''),''!NL!'')")^))
       ELSE
        CALL stmt_push(io_stmt_cnt,concat('ASIS("nvl(to_char(:p',trim(cnvtstring(cpfo_ndx)),
          ^,''TM9'',''nls_numeric_characters=''''.,''''''),''!NL!'')")^))
       ENDIF
      ELSEIF (daf_is_not_blank(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].cnst_val))
       CALL stmt_push(io_stmt_cnt,concat(^ASIS("''^,sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[
         cpfo_ndx].cnst_val,^''")^))
      ELSEIF (daf_is_not_blank(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].base62_re_name))
       CALL stmt_push(io_stmt_cnt,'ASIS("nvl(dm_refchg_b10tob62(REFCHG_TRANS(")')
       CALL stmt_push(io_stmt_cnt,concat(^ASIS("''^,sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[
         cpfo_ndx].base62_re_name,"'',dm_refchg_b62tob10(:p",trim(cnvtstring(cpfo_ndx)),"),:s",
         trim(cnvtstring(cpfo_ndx)),",:t",trim(cnvtstring(cpfo_ndx)),",:x",trim(cnvtstring(cpfo_ndx)),
         ^)),''!NL!'')")^))
       SET cpfo_parm->parm_cnt = (cpfo_parm->parm_cnt+ 4)
       SET stat = alterlist(cpfo_parm->qual,cpfo_parm->parm_cnt)
       SET cpfo_parm->qual[(cpfo_parm->parm_cnt - 3)].parm_name = concat("i_",s_parm_name)
       SET cpfo_parm->qual[(cpfo_parm->parm_cnt - 2)].parm_name = "i_src_id"
       SET cpfo_parm->qual[(cpfo_parm->parm_cnt - 1)].parm_name = "i_tgt_id"
       SET cpfo_parm->qual[cpfo_parm->parm_cnt].parm_name = "i_xlat_type"
      ELSE
       CALL stmt_push(io_stmt_cnt,'ASIS("nvl(to_char(REFCHG_TRANS(")')
       IF (daf_is_not_blank(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].re_name))
        CALL stmt_push(io_stmt_cnt,concat(^ASIS("''^,sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[
          cpfo_ndx].re_name,"'',:p",trim(cnvtstring(cpfo_ndx)),",:s",
          trim(cnvtstring(cpfo_ndx)),",:t",trim(cnvtstring(cpfo_ndx)),",:x",trim(cnvtstring(cpfo_ndx)
           ),
          ^)),''!NL!'')")^))
        SET cpfo_parm->parm_cnt = (cpfo_parm->parm_cnt+ 4)
        SET stat = alterlist(cpfo_parm->qual,cpfo_parm->parm_cnt)
        SET cpfo_parm->qual[(cpfo_parm->parm_cnt - 3)].parm_name = concat("i_",s_parm_name)
        SET cpfo_parm->qual[(cpfo_parm->parm_cnt - 2)].parm_name = "i_src_id"
        SET cpfo_parm->qual[(cpfo_parm->parm_cnt - 1)].parm_name = "i_tgt_id"
        SET cpfo_parm->qual[cpfo_parm->parm_cnt].parm_name = "i_xlat_type"
       ELSE
        CALL stmt_push(io_stmt_cnt,concat(^ASIS("EVALUATE_PE_NAME(''^,s_tab_name,"'',''",s_col_name,
          "'',''",
          sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].pe_col,"'',:e",trim(cnvtstring(
            cpfo_ndx)),"),:p",trim(cnvtstring(cpfo_ndx)),
          ",:s",trim(cnvtstring(cpfo_ndx)),",:t",trim(cnvtstring(cpfo_ndx)),",:x",
          trim(cnvtstring(cpfo_ndx)),^)),''!NL!'')")^))
        SET cpfo_parm->parm_cnt = (cpfo_parm->parm_cnt+ 5)
        SET stat = alterlist(cpfo_parm->qual,cpfo_parm->parm_cnt)
        SET cpfo_parm->qual[(cpfo_parm->parm_cnt - 4)].parm_name = concat("i_",trim(substring(1,28,
           sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].pe_col)))
        SET cpfo_parm->qual[(cpfo_parm->parm_cnt - 3)].parm_name = concat("i_",s_parm_name)
        SET cpfo_parm->qual[(cpfo_parm->parm_cnt - 2)].parm_name = "i_src_id"
        SET cpfo_parm->qual[(cpfo_parm->parm_cnt - 1)].parm_name = "i_tgt_id"
        SET cpfo_parm->qual[cpfo_parm->parm_cnt].parm_name = "i_xlat_type"
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   CALL stmt_push(io_stmt_cnt,^ASIS(" from dual'; ")^)
   CALL stmt_push(io_stmt_cnt,'ASIS(" execute immediate v_match_str into v_temp_str using ")')
   FOR (cpfo_ndx = 1 TO cpfo_parm->parm_cnt)
     IF (cpfo_ndx=1)
      CALL stmt_push(io_stmt_cnt,concat('ASIS("',cpfo_parm->qual[cpfo_ndx].parm_name,'")'))
     ELSE
      CALL stmt_push(io_stmt_cnt,concat('ASIS(", ',cpfo_parm->qual[cpfo_ndx].parm_name,'")'))
     ENDIF
   ENDFOR
   CALL stmt_push(io_stmt_cnt,'ASIS("; ")')
   CALL stmt_push(io_stmt_cnt,'ASIS("  end  if; ")')
   CALL stmt_push(io_stmt_cnt,'ASIS("dbms_output.put_line (v_temp_str); ")')
   CALL stmt_push(io_stmt_cnt,
    'ASIS(" select dbms_utility.get_hash_value(v_temp_str, 0, 1073741824) into v_ptam_result from dual; ")'
    )
   CALL stmt_push(io_stmt_cnt,
    ^ASIS("  dm2_context_control('RDDS_PTAM_MATCH_RESULT_STR', v_temp_str);")^)
   CALL stmt_push(io_stmt_cnt,'ASIS("  return(v_ptam_result);")')
   CALL stmt_push(io_stmt_cnt,'ASIS("end; ")')
   CALL stmt_push(io_stmt_cnt,"end go")
   SET stat = alterlist(stmt_buffer->data,v_stmt_cnt)
   EXECUTE dm2_stmt_exe "FUNCTION", s_ptam_func_name WITH replace("REQUEST","STMT_BUFFER"), replace(
    "REPLY","SE_REPLY")
   SET io_stmt_cnt = 0
   IF ((se_reply->err_ind=1))
    SET dm_err->emsg = "Error occurred in dm2_stmt_exe."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE create_pkw_function_ora(sbr_trg_data_rs,i_trg_ndx,io_drop_cnt,io_stmt_cnt)
   DECLARE s_tab_name = vc WITH protect, noconstant(" ")
   DECLARE s_tab_suffix = vc WITH protect, noconstant(" ")
   DECLARE s_iu_func_name = vc WITH protect, noconstant(" ")
   DECLARE s_d_func_name = vc WITH protect, noconstant(" ")
   DECLARE s_drop_func_name = vc WITH protect, noconstant(" ")
   DECLARE s_iu_pkw_template = vc WITH protect, noconstant(" ")
   DECLARE s_d_pkw_template = vc WITH protect, noconstant(" ")
   DECLARE cpfo_ndx = i4 WITH protect, noconstant(0)
   DECLARE s_col_name = vc WITH protect, noconstant(" ")
   DECLARE s_parm_name = vc WITH protect, noconstant(" ")
   DECLARE s_idx = i4 WITH protect, noconstant(0)
   DECLARE s_idx2 = i4 WITH protect, noconstant(0)
   DECLARE s_func_exist_ind = i2 WITH protect, noconstant(0)
   DECLARE s_d_func_exist_ind = i2 WITH protect, noconstant(0)
   SET s_tab_name = sbr_trg_data_rs->qual[i_trg_ndx].table_name
   SET s_tab_suffix = sbr_trg_data_rs->qual[i_trg_ndx].table_suffix
   SET s_iu_func_name = concat("REFCHG_PKW_",s_tab_suffix,"_1")
   SET s_drop_func_name = ""
   SET dm_err->eproc = "Determining insert/update function name."
   SELECT INTO "NL:"
    uo.object_name
    FROM user_objects uo
    WHERE uo.object_name=patstring(concat("REFCHG_PKW_",s_tab_suffix,"*"))
     AND uo.object_type="FUNCTION"
    DETAIL
     s_func_exist_ind = 1
     IF (uo.object_name=concat("REFCHG_PKW_",s_tab_suffix,"_1"))
      s_drop_func_name = uo.object_name, s_iu_func_name = concat("REFCHG_PKW_",s_tab_suffix,"_2")
     ELSE
      s_drop_func_name = uo.object_name, s_iu_func_name = concat("REFCHG_PKW_",s_tab_suffix,"_1")
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   IF ((sbr_trg_data_rs->qual[i_trg_ndx].pkw_skip_recreate_ind=1)
    AND s_func_exist_ind=1)
    SET sbr_trg_data_rs->qual[i_trg_ndx].pkw_function = s_drop_func_name
   ELSE
    SET sbr_trg_data_rs->qual[i_trg_ndx].pkw_function = s_iu_func_name
    SET sbr_trg_data_rs->qual[i_trg_ndx].pkw_skip_recreate_ind = 0
    IF (daf_is_not_blank(s_drop_func_name))
     SET io_drop_cnt = (io_drop_cnt+ 1)
     IF (mod(io_drop_cnt,50)=1)
      SET stat = alterlist(drop_func->data,(io_drop_cnt+ 49))
     ENDIF
     SET drop_func->data[io_drop_cnt].stmt = concat("drop function ",s_drop_func_name)
    ENDIF
   ENDIF
   SET s_d_func_name = concat("REFCHG_DEL_PKW_",s_tab_suffix,"_1")
   SET s_drop_func_name = ""
   SET dm_err->eproc = "Determining delete function name."
   SELECT INTO "NL:"
    uo.object_name
    FROM user_objects uo
    WHERE uo.object_name=patstring(concat("REFCHG_DEL_PKW_",s_tab_suffix,"*"))
     AND uo.object_type="FUNCTION"
    DETAIL
     s_d_func_exist_ind = 1
     IF (uo.object_name=concat("REFCHG_DEL_PKW_",s_tab_suffix,"_1"))
      s_drop_func_name = uo.object_name, s_d_func_name = concat("REFCHG_DEL_PKW_",s_tab_suffix,"_2")
     ELSE
      s_drop_func_name = uo.object_name, s_d_func_name = concat("REFCHG_DEL_PKW_",s_tab_suffix,"_1")
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   IF ((sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_skip_recreate_ind=1)
    AND s_d_func_exist_ind=1)
    SET sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_function = s_drop_func_name
   ELSE
    SET sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_function = s_d_func_name
    SET sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_skip_recreate_ind = 0
    IF (daf_is_not_blank(s_drop_func_name))
     SET io_drop_cnt = (io_drop_cnt+ 1)
     IF (mod(io_drop_cnt,50)=1)
      SET stat = alterlist(drop_func->data,(io_drop_cnt+ 49))
     ENDIF
     SET drop_func->data[io_drop_cnt].stmt = concat("drop function ",s_drop_func_name)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Gathering REFCHG_PKW parms."
   SELECT INTO "nl:"
    dpwp.column_name
    FROM dm_pk_where_parm dpwp
    WHERE dpwp.table_name=s_tab_name
     AND dpwp.function_type="PK_WHERE"
     AND dpwp.delete_ind=0
    ORDER BY dpwp.parm_nbr, dpwp.column_name
    HEAD REPORT
     parm_cnt = 0
    DETAIL
     parm_cnt = (parm_cnt+ 1), stat = alterlist(sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm,parm_cnt),
     sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm[parm_cnt].column_name = cnvtupper(dpwp.column_name),
     sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm[parm_cnt].data_type = cnvtupper(dpwp.data_type),
     sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm[parm_cnt].nullable = "Y"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   SET dm_err->eproc = "Gathering REFCHG_DEL_PKW parms."
   SELECT INTO "nl:"
    dpwp.column_name
    FROM dm_pk_where_parm dpwp
    WHERE dpwp.table_name=s_tab_name
     AND dpwp.function_type="PK_WHERE"
     AND dpwp.delete_ind=1
    ORDER BY dpwp.parm_nbr, dpwp.column_name
    HEAD REPORT
     parm_cnt = 0
    DETAIL
     parm_cnt = (parm_cnt+ 1), stat = alterlist(sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm,
      parm_cnt), sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm[parm_cnt].column_name = cnvtupper(dpwp
      .column_name),
     sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm[parm_cnt].data_type = cnvtupper(dpwp.data_type),
     sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm[parm_cnt].nullable = "Y", sbr_trg_data_rs->qual[
     i_trg_ndx].del_pkw_parm[parm_cnt].exist_ind = dpwp.exist_ind
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   SET dm_err->eproc = "Gathering nullable information."
   SELECT INTO "nl:"
    FROM dm2_user_notnull_cols dunc
    WHERE dunc.table_name=s_tab_name
    DETAIL
     s_idx2 = 0, s_idx2 = locateval(s_idx,1,size(sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm,5),
      dunc.column_name,sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm[s_idx].column_name)
     IF (s_idx2 > 0)
      sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm[s_idx2].nullable = "N"
     ENDIF
     s_idx2 = 0, s_idx2 = locateval(s_idx,1,size(sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm,5),dunc
      .column_name,sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm[s_idx].column_name)
     IF (s_idx2 > 0)
      sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm[s_idx2].nullable = "N"
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   SET dm_err->eproc = concat("Gathering pk_template for table ",s_tab_name)
   SELECT INTO "nl:"
    dpw.pk_where
    FROM dm_pk_where dpw
    WHERE dpw.table_name=s_tab_name
    DETAIL
     IF (dpw.delete_ind=0)
      s_iu_pkw_template = dpw.pk_where, sbr_trg_data_rs->qual[i_trg_ndx].pkw_hash = dpw.pk_where_hash
     ELSE
      s_d_pkw_template = dpw.pk_where, sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_hash = dpw
      .pk_where_hash
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   IF ((sbr_trg_data_rs->qual[i_trg_ndx].pkw_skip_recreate_ind=0))
    CALL stmt_push(io_stmt_cnt,concat('RDB ASIS("create or replace function ',sbr_trg_data_rs->qual[
      i_trg_ndx].pkw_function,'(")'))
    FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm,5))
     SET s_parm_name = substring(1,28,sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm[cpfo_ndx].column_name
      )
     IF (cpfo_ndx=1)
      CALL stmt_push(io_stmt_cnt,concat('ASIS("i_',s_parm_name," ",sbr_trg_data_rs->qual[i_trg_ndx].
        pkw_parm[cpfo_ndx].data_type,'")'))
     ELSE
      CALL stmt_push(io_stmt_cnt,concat('ASIS(",i_',s_parm_name," ",sbr_trg_data_rs->qual[i_trg_ndx].
        pkw_parm[cpfo_ndx].data_type,'")'))
     ENDIF
    ENDFOR
    CALL stmt_push(io_stmt_cnt,
     ^ASIS(",i_db_link varchar2 default ' ',i_cs_pk_ind number default 1) ")^)
    CALL stmt_push(io_stmt_cnt,
     'ASIS(" return varchar2 as v_iu_pk_where dm_chg_log.pk_where%TYPE; ")')
    CALL stmt_push(io_stmt_cnt,'ASIS(" begin ")')
    CALL stmt_push(io_stmt_cnt,concat('ASIS("  select ',s_iu_pkw_template,
      ' into v_iu_pk_where from dual; ")'))
    CALL stmt_push(io_stmt_cnt,'ASIS("  return(v_iu_pk_where);")')
    CALL stmt_push(io_stmt_cnt,'ASIS("end; ")')
    CALL stmt_push(io_stmt_cnt,"end go")
    SET stat = alterlist(stmt_buffer->data,v_stmt_cnt)
    EXECUTE dm2_stmt_exe "FUNCTION", sbr_trg_data_rs->qual[i_trg_ndx].pkw_function WITH replace(
     "REQUEST","STMT_BUFFER"), replace("REPLY","SE_REPLY")
    SET io_stmt_cnt = 0
    IF ((se_reply->err_ind=1))
     SET dm_err->emsg = "Error occurred in dm2_stmt_exe."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(- (1))
    ENDIF
   ENDIF
   IF ((sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_skip_recreate_ind=1))
    RETURN(1)
   ENDIF
   CALL stmt_push(io_stmt_cnt,concat('RDB ASIS("create or replace function ',sbr_trg_data_rs->qual[
     i_trg_ndx].del_pkw_function,'(")'))
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm,5))
    SET s_parm_name = substring(1,28,sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm[cpfo_ndx].
     column_name)
    IF (cpfo_ndx=1)
     CALL stmt_push(io_stmt_cnt,concat('ASIS("i_',s_parm_name," ",sbr_trg_data_rs->qual[i_trg_ndx].
       del_pkw_parm[cpfo_ndx].data_type,'")'))
    ELSE
     CALL stmt_push(io_stmt_cnt,concat('ASIS(",i_',s_parm_name," ",sbr_trg_data_rs->qual[i_trg_ndx].
       del_pkw_parm[cpfo_ndx].data_type,'")'))
    ENDIF
   ENDFOR
   CALL stmt_push(io_stmt_cnt,^ASIS(",i_db_link varchar2 default ' ') ")^)
   CALL stmt_push(io_stmt_cnt,'ASIS(" return varchar2 as v_d_pk_where dm_chg_log.pk_where%TYPE; ")')
   CALL stmt_push(io_stmt_cnt,'ASIS(" begin ")')
   CALL stmt_push(io_stmt_cnt,concat('ASIS("   select ',s_d_pkw_template,
     ' into v_d_pk_where from dual; ")'))
   CALL stmt_push(io_stmt_cnt,'ASIS("  return(v_d_pk_where);")')
   CALL stmt_push(io_stmt_cnt,'ASIS("end; ")')
   CALL stmt_push(io_stmt_cnt,"end go")
   SET stat = alterlist(stmt_buffer->data,v_stmt_cnt)
   EXECUTE dm2_stmt_exe "FUNCTION", sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_function WITH replace(
    "REQUEST","STMT_BUFFER"), replace("REPLY","SE_REPLY")
   SET io_stmt_cnt = 0
   IF ((se_reply->err_ind=1))
    SET dm_err->emsg = "Error occurred in dm2_stmt_exe."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE create_colstring_function_ora(sbr_trg_data_rs,i_trg_ndx,io_drop_cnt,io_stmt_cnt)
   DECLARE s_tab_name = vc WITH protect, noconstant(" ")
   DECLARE s_tab_suffix = vc WITH protect, noconstant(" ")
   DECLARE s_func_name = vc WITH protect, noconstant(" ")
   DECLARE s_drop_func_name = vc WITH protect, noconstant(" ")
   DECLARE cpfo_ndx = i4 WITH protect, noconstant(0)
   DECLARE s_column_name = vc WITH protect, noconstant(" ")
   DECLARE s_parm_name = vc WITH protect, noconstant(" ")
   DECLARE ccfo_cnt = i4 WITH protect, noconstant(0)
   SET s_tab_name = sbr_trg_data_rs->qual[i_trg_ndx].table_name
   SET s_tab_suffix = sbr_trg_data_rs->qual[i_trg_ndx].table_suffix
   IF ((daclt_trg_data->qual[i_trg_ndx].version_match_ind=1))
    SELECT INTO "nl:"
     cnt = count(*)
     FROM dm_colstring_parm d
     WHERE d.table_name=s_tab_name
      AND d.updt_dt_tm > cnvtdatetime((curdate - 1),curtime3)
     DETAIL
      ccfo_cnt = cnt
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(- (1))
    ENDIF
    IF (ccfo_cnt=0)
     SET daclt_trg_data->qual[i_trg_ndx].colstring_skip_recreate_ind = 1
    ENDIF
   ENDIF
   SET s_func_name = concat("REFCHG_COLSTRING_",s_tab_suffix,"_1")
   SET s_drop_func_name = ""
   SET dm_err->eproc = "Determining colstring function name."
   SELECT INTO "NL:"
    uo.object_name
    FROM user_objects uo
    WHERE uo.object_name=patstring(concat("REFCHG_COLSTRING_",s_tab_suffix,"*"))
     AND uo.object_type="FUNCTION"
    DETAIL
     IF (uo.object_name=concat("REFCHG_COLSTRING_",s_tab_suffix,"_1"))
      s_drop_func_name = uo.object_name, s_func_name = concat("REFCHG_COLSTRING_",s_tab_suffix,"_2")
     ELSE
      s_drop_func_name = uo.object_name, s_func_name = concat("REFCHG_COLSTRING_",s_tab_suffix,"_1")
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   IF ((daclt_trg_data->qual[i_trg_ndx].colstring_skip_recreate_ind=1))
    SET sbr_trg_data_rs->qual[i_trg_ndx].colstring_function = s_drop_func_name
   ELSE
    SET sbr_trg_data_rs->qual[i_trg_ndx].colstring_function = s_func_name
    IF (daf_is_not_blank(s_drop_func_name))
     SET io_drop_cnt = (io_drop_cnt+ 1)
     IF (mod(io_drop_cnt,50)=1)
      SET stat = alterlist(drop_func->data,(io_drop_cnt+ 49))
     ENDIF
     SET drop_func->data[io_drop_cnt].stmt = concat("drop function ",s_drop_func_name)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Gathering COLSTRING parms."
   SELECT INTO "nl:"
    dcp.column_name
    FROM dm_colstring_parm dcp
    WHERE dcp.table_name=s_tab_name
    ORDER BY dcp.parm_nbr, dcp.column_name
    HEAD REPORT
     parm_cnt = 0
    DETAIL
     parm_cnt = (parm_cnt+ 1), stat = alterlist(sbr_trg_data_rs->qual[i_trg_ndx].colstring_parm,
      parm_cnt), sbr_trg_data_rs->qual[i_trg_ndx].colstring_parm[parm_cnt].column_name = cnvtupper(
      dcp.column_name),
     sbr_trg_data_rs->qual[i_trg_ndx].colstring_parm[parm_cnt].data_type = cnvtupper(dcp.data_type)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   IF ((sbr_trg_data_rs->qual[i_trg_ndx].colstring_skip_recreate_ind=0))
    CALL stmt_push(io_stmt_cnt,concat('RDB ASIS("create or replace function ',sbr_trg_data_rs->qual[
      i_trg_ndx].colstring_function,'(")'))
    FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].colstring_parm,5))
     SET s_parm_name = create_input_parm_ora(sbr_trg_data_rs->qual[i_trg_ndx].colstring_parm[cpfo_ndx
      ].column_name,cpfo_ndx)
     IF (cpfo_ndx=1)
      CALL stmt_push(io_stmt_cnt,concat('ASIS("',s_parm_name," ",sbr_trg_data_rs->qual[i_trg_ndx].
        colstring_parm[cpfo_ndx].data_type,'")'))
     ELSE
      CALL stmt_push(io_stmt_cnt,concat('ASIS(",',s_parm_name," ",sbr_trg_data_rs->qual[i_trg_ndx].
        colstring_parm[cpfo_ndx].data_type,'")'))
     ENDIF
    ENDFOR
    CALL stmt_push(io_stmt_cnt,
     'ASIS(") return varchar2 as v_colstring dm_chg_log.col_string%TYPE; begin ")')
    CALL stmt_push(io_stmt_cnt,'ASIS("  select  substr(")')
    FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].colstring_parm,5))
      SET s_column_name = sbr_trg_data_rs->qual[i_trg_ndx].colstring_parm[cpfo_ndx].column_name
      SET s_parm_name = create_input_parm_ora(s_column_name,cpfo_ndx)
      IF (cpfo_ndx > 1)
       CALL stmt_push(io_stmt_cnt,'ASIS("||")')
      ENDIF
      CALL stmt_push(io_stmt_cnt,concat(^ASIS("'<^,s_column_name,^>'||")^))
      IF ((sbr_trg_data_rs->qual[i_trg_ndx].colstring_parm[cpfo_ndx].data_type IN ("CHAR", "VARCHAR",
      "VARCHAR2", "ROWID")))
       CALL stmt_push(io_stmt_cnt,concat('ASIS("decode(',s_parm_name,",null,'!NL!',replace(replace(",
         s_parm_name,^,'<','!&lt!'),'>','!&gt!'))||")^))
      ELSEIF ((sbr_trg_data_rs->qual[i_trg_ndx].colstring_parm[cpfo_ndx].data_type IN ("DATE")))
       CALL stmt_push(io_stmt_cnt,concat('ASIS("decode(to_char(',s_parm_name,"),null,'!NL!',to_char(",
         s_parm_name,^,'DD-MON-YYYY HH24:MI:SS'))||")^))
      ELSE
       CALL stmt_push(io_stmt_cnt,concat('ASIS("decode(to_char(',s_parm_name,"),null,'!NL!',to_char(",
         s_parm_name,'))||")'))
      ENDIF
      CALL stmt_push(io_stmt_cnt,concat(^ASIS("'</^,s_column_name,^>'")^))
    ENDFOR
    CALL stmt_push(io_stmt_cnt,'ASIS(",1,4000) into v_colstring from dual;")')
    CALL stmt_push(io_stmt_cnt,'ASIS("  return(v_colstring);")')
    CALL stmt_push(io_stmt_cnt,'ASIS("end; ")')
    CALL stmt_push(io_stmt_cnt,"end go")
    SET stat = alterlist(stmt_buffer->data,v_stmt_cnt)
    EXECUTE dm2_stmt_exe "FUNCTION", sbr_trg_data_rs->qual[i_trg_ndx].colstring_function WITH replace
    ("REQUEST","STMT_BUFFER"), replace("REPLY","SE_REPLY")
    SET io_stmt_cnt = 0
    IF ((se_reply->err_ind=1))
     SET dm_err->emsg = "Error occurred in dm2_stmt_exe."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET s_func_name = concat("REFCHG_GEN_PK_PTAM_",s_tab_suffix,"_1")
   SET s_drop_func_name = ""
   SET dm_err->eproc = "Determining pk/ptam colstring function name."
   SELECT INTO "NL:"
    uo.object_name
    FROM user_objects uo
    WHERE uo.object_name=patstring(concat("REFCHG_GEN_PK_PTAM_",s_tab_suffix,"*"))
     AND uo.object_type="FUNCTION"
    DETAIL
     IF (uo.object_name=concat("REFCHG_GEN_PK_PTAM_",s_tab_suffix,"_1"))
      s_drop_func_name = uo.object_name, s_func_name = concat("REFCHG_GEN_PK_PTAM_",s_tab_suffix,"_2"
       )
     ELSE
      s_drop_func_name = uo.object_name, s_func_name = concat("REFCHG_GEN_PK_PTAM_",s_tab_suffix,"_1"
       )
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   IF ((daclt_trg_data->qual[i_trg_ndx].colstring_skip_recreate_ind=1)
    AND (daclt_trg_data->qual[i_trg_ndx].pkw_skip_recreate_ind=1)
    AND (daclt_trg_data->qual[i_trg_ndx].del_pkw_skip_recreate_ind=1)
    AND (daclt_trg_data->qual[i_trg_ndx].ptam_skip_recreate_ind=1))
    SET sbr_trg_data_rs->qual[i_trg_ndx].pk_ptam_function = s_drop_func_name
    RETURN(1)
   ELSE
    IF (daf_is_not_blank(s_drop_func_name))
     SET io_drop_cnt = (io_drop_cnt+ 1)
     IF (mod(io_drop_cnt,50)=1)
      SET stat = alterlist(drop_func->data,(io_drop_cnt+ 49))
     ENDIF
     SET drop_func->data[io_drop_cnt].stmt = concat("drop function ",s_drop_func_name)
    ENDIF
    SET sbr_trg_data_rs->qual[i_trg_ndx].pk_ptam_function = s_func_name
   ENDIF
   CALL stmt_push(io_stmt_cnt,concat('RDB ASIS("create or replace function ',s_func_name,
     '(pk_where_ind number, delete_ind number, i_colstring dm_chg_log.col_string%TYPE")'))
   CALL stmt_push(io_stmt_cnt,
    ^ASIS(",i_db_link varchar2 default ' ',i_cs_pk_ind number default 1) ")^)
   CALL stmt_push(io_stmt_cnt,'ASIS(" return varchar2 as v_where dm_chg_log.pk_where%TYPE; ")')
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm,5))
     CALL stmt_push(io_stmt_cnt,concat('ASIS(" v_pkw_col',format(cpfo_ndx,"##;P0"),
       ' varchar2(4000);")'))
   ENDFOR
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm,5))
     CALL stmt_push(io_stmt_cnt,concat('ASIS(" v_dpkw_col',format(cpfo_ndx,"##;P0"),
       ' varchar2(4000);")'))
   ENDFOR
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,5))
     CALL stmt_push(io_stmt_cnt,concat('ASIS(" v_ptam_col',format(cpfo_ndx,"##;P0"),
       ' varchar2(4000);")'))
   ENDFOR
   CALL stmt_push(io_stmt_cnt,'ASIS("begin ")')
   CALL stmt_push(io_stmt_cnt,'ASIS("if pk_where_ind = 1 and delete_ind = 0 then ")')
   CALL stmt_push(io_stmt_cnt,'ASIS("  if ")')
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm,5))
     IF (cpfo_ndx=1)
      CALL stmt_push(io_stmt_cnt,concat(^ASIS("   instr(i_colstring, '<^,sbr_trg_data_rs->qual[
        i_trg_ndx].pkw_parm[cpfo_ndx].column_name,">',1) > 0 and instr(i_colstring, '</",
        sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm[cpfo_ndx].column_name,^>',1) > 0 ")^))
     ELSE
      CALL stmt_push(io_stmt_cnt,concat(^ASIS("   and instr(i_colstring, '<^,sbr_trg_data_rs->qual[
        i_trg_ndx].pkw_parm[cpfo_ndx].column_name,">',1) > 0 and instr(i_colstring, '</",
        sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm[cpfo_ndx].column_name,^>',1) > 0 ")^))
     ENDIF
   ENDFOR
   CALL stmt_push(io_stmt_cnt,'ASIS(" then ")')
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm,5))
     SET s_column_name = sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm[cpfo_ndx].column_name
     CALL stmt_push(io_stmt_cnt,concat('ASIS("    v_pkw_col',format(cpfo_ndx,"##;P0"),':= ")'))
     CALL stmt_push(io_stmt_cnt,concat(^ASIS(" substr(i_colstring,instr(i_colstring,'<^,s_column_name,
       ">',1)+",trim(cnvtstring((size(s_column_name,1)+ 2))),",instr(i_colstring,'</",
       s_column_name,">',1)-(instr(i_colstring,'<",s_column_name,">',1)+",trim(cnvtstring((size(
          s_column_name,1)+ 2))),
       ')); ")'))
   ENDFOR
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm,5))
    IF (cpfo_ndx=1)
     CALL stmt_push(io_stmt_cnt,concat('ASIS("  select ',sbr_trg_data_rs->qual[i_trg_ndx].
       pkw_function,'(")'))
    ELSE
     CALL stmt_push(io_stmt_cnt,'ASIS(",")')
    ENDIF
    IF ((sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm[cpfo_ndx].data_type IN ("CHAR", "VARCHAR",
    "VARCHAR2", "ROWID")))
     CALL stmt_push(io_stmt_cnt,concat('ASIS("decode(v_pkw_col',format(cpfo_ndx,"##;P0"),
       ",'!NL!',null,'char(0)',chr(0),replace(replace(v_pkw_col",format(cpfo_ndx,"##;P0"),
       ^,'!&lt!','<'),'!&gt!','>'))")^))
    ELSEIF ((sbr_trg_data_rs->qual[i_trg_ndx].pkw_parm[cpfo_ndx].data_type="DATE"))
     CALL stmt_push(io_stmt_cnt,concat('ASIS("to_date(decode(v_pkw_col',format(cpfo_ndx,"##;P0"),
       ",'!NL!',null,v_pkw_col",format(cpfo_ndx,"##;P0"),^),'DD-MON-YYYY HH24:MI:SS') ")^))
    ELSE
     CALL stmt_push(io_stmt_cnt,concat('ASIS("decode(v_pkw_col',format(cpfo_ndx,"##;P0"),
       ",'!NL!',null,v_pkw_col",format(cpfo_ndx,"##;P0"),') ")'))
    ENDIF
   ENDFOR
   CALL stmt_push(io_stmt_cnt,'ASIS(",i_db_link, i_cs_pk_ind) into v_where from dual; ")')
   CALL stmt_push(io_stmt_cnt,
    ^ASIS(" else raise_application_error(-20205,'Error constructing pk_where from colstring.'); ")^)
   CALL stmt_push(io_stmt_cnt,'ASIS(" end if; ")')
   CALL stmt_push(io_stmt_cnt,'ASIS("elsif pk_where_ind = 1 and delete_ind = 1 then ")')
   CALL stmt_push(io_stmt_cnt,'ASIS("  if ")')
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm,5))
     IF (cpfo_ndx=1)
      CALL stmt_push(io_stmt_cnt,concat(^ASIS("   instr(i_colstring, '<^,sbr_trg_data_rs->qual[
        i_trg_ndx].del_pkw_parm[cpfo_ndx].column_name,">',1) > 0 and instr(i_colstring, '</",
        sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm[cpfo_ndx].column_name,^>',1) > 0 ")^))
     ELSE
      CALL stmt_push(io_stmt_cnt,concat(^ASIS("   and instr(i_colstring, '<^,sbr_trg_data_rs->qual[
        i_trg_ndx].del_pkw_parm[cpfo_ndx].column_name,">',1) > 0 and instr(i_colstring, '</",
        sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm[cpfo_ndx].column_name,^>',1) > 0 ")^))
     ENDIF
   ENDFOR
   CALL stmt_push(io_stmt_cnt,'ASIS(" then ")')
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm,5))
     SET s_column_name = sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm[cpfo_ndx].column_name
     CALL stmt_push(io_stmt_cnt,concat('ASIS("    v_dpkw_col',format(cpfo_ndx,"##;P0"),':= ")'))
     CALL stmt_push(io_stmt_cnt,concat(^ASIS(" substr(i_colstring,instr(i_colstring,'<^,s_column_name,
       ">',1)+",trim(cnvtstring((size(s_column_name,1)+ 2))),",instr(i_colstring,'</",
       s_column_name,">',1)-(instr(i_colstring,'<",s_column_name,">',1)+",trim(cnvtstring((size(
          s_column_name,1)+ 2))),
       ')); ")'))
   ENDFOR
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm,5))
    IF (cpfo_ndx=1)
     CALL stmt_push(io_stmt_cnt,concat('ASIS("  select ',sbr_trg_data_rs->qual[i_trg_ndx].
       del_pkw_function,'(")'))
    ELSE
     CALL stmt_push(io_stmt_cnt,'ASIS(",")')
    ENDIF
    IF ((sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm[cpfo_ndx].data_type IN ("CHAR", "VARCHAR",
    "VARCHAR2", "ROWID")))
     CALL stmt_push(io_stmt_cnt,concat('ASIS("decode(v_dpkw_col',format(cpfo_ndx,"##;P0"),
       ",'!NL!',null,'char(0)',chr(0),replace(replace(v_dpkw_col",format(cpfo_ndx,"##;P0"),
       ^,'!&lt!','<'),'!&gt!','>'))")^))
    ELSEIF ((sbr_trg_data_rs->qual[i_trg_ndx].del_pkw_parm[cpfo_ndx].data_type="DATE"))
     CALL stmt_push(io_stmt_cnt,concat('ASIS("to_date(decode(v_dpkw_col',format(cpfo_ndx,"##;P0"),
       ",'!NL!',null,v_dpkw_col",format(cpfo_ndx,"##;P0"),^),'DD-MON-YYYY HH24:MI:SS') ")^))
    ELSE
     CALL stmt_push(io_stmt_cnt,concat('ASIS("decode(v_dpkw_col',format(cpfo_ndx,"##;P0"),
       ",'!NL!',null,v_dpkw_col",format(cpfo_ndx,"##;P0"),') ")'))
    ENDIF
   ENDFOR
   CALL stmt_push(io_stmt_cnt,'ASIS(",i_db_link) into v_where from dual; ")')
   CALL stmt_push(io_stmt_cnt,
    ^ASIS(" else raise_application_error(-20205,'Error constructing del pk_where from colstring.'); ")^
    )
   CALL stmt_push(io_stmt_cnt,'ASIS(" end if; ")')
   CALL stmt_push(io_stmt_cnt,'ASIS("else ")')
   CALL stmt_push(io_stmt_cnt,'ASIS("  if ")')
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,5))
     IF (cpfo_ndx=1)
      CALL stmt_push(io_stmt_cnt,concat(^ASIS("   instr(i_colstring, '<^,sbr_trg_data_rs->qual[
        i_trg_ndx].ptam_parm[cpfo_ndx].column_name,">',1) > 0 and instr(i_colstring, '</",
        sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].column_name,^>',1) > 0 ")^))
     ELSE
      CALL stmt_push(io_stmt_cnt,concat(^ASIS("   and instr(i_colstring, '<^,sbr_trg_data_rs->qual[
        i_trg_ndx].ptam_parm[cpfo_ndx].column_name,">',1) > 0 and instr(i_colstring, '</",
        sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].column_name,^>',1) > 0 ")^))
     ENDIF
   ENDFOR
   CALL stmt_push(io_stmt_cnt,'ASIS(" then ")')
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,5))
     SET s_column_name = sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].column_name
     CALL stmt_push(io_stmt_cnt,concat('ASIS("    v_ptam_col',format(cpfo_ndx,"##;P0"),':= ")'))
     CALL stmt_push(io_stmt_cnt,concat(^ASIS(" substr(i_colstring,instr(i_colstring,'<^,s_column_name,
       ">',1)+",trim(cnvtstring((size(s_column_name,1)+ 2))),",instr(i_colstring,'</",
       s_column_name,">',1)-(instr(i_colstring,'<",s_column_name,">',1)+",trim(cnvtstring((size(
          s_column_name,1)+ 2))),
       ')); ")'))
   ENDFOR
   FOR (cpfo_ndx = 1 TO size(sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm,5))
    IF (cpfo_ndx=1)
     CALL stmt_push(io_stmt_cnt,concat('ASIS("  select ',sbr_trg_data_rs->qual[i_trg_ndx].
       ptam_match_function,'(")'))
    ELSE
     CALL stmt_push(io_stmt_cnt,'ASIS(",")')
    ENDIF
    IF ((sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].data_type IN ("CHAR", "VARCHAR",
    "VARCHAR2", "ROWID")))
     CALL stmt_push(io_stmt_cnt,concat('ASIS("decode(v_ptam_col',format(cpfo_ndx,"##;P0"),
       ",'!NL!',null,'char(0)',chr(0),replace(replace(v_ptam_col",format(cpfo_ndx,"##;P0"),
       ^,'!&lt!','<'),'!&gt!','>'))")^))
    ELSEIF ((sbr_trg_data_rs->qual[i_trg_ndx].ptam_parm[cpfo_ndx].data_type="DATE"))
     CALL stmt_push(io_stmt_cnt,concat('ASIS("to_date(decode(v_ptam_col',format(cpfo_ndx,"##;P0"),
       ",'!NL!',null,v_ptam_col",format(cpfo_ndx,"##;P0"),^),'DD-MON-YYYY HH24:MI:SS') ")^))
    ELSE
     CALL stmt_push(io_stmt_cnt,concat('ASIS("decode(v_ptam_col',format(cpfo_ndx,"##;P0"),
       ",'!NL!',null,v_ptam_col",format(cpfo_ndx,"##;P0"),') ")'))
    ENDIF
   ENDFOR
   CALL stmt_push(io_stmt_cnt,'ASIS(",i_db_link) into v_where from dual; ")')
   CALL stmt_push(io_stmt_cnt,
    ^ASIS(" else raise_application_error(-20205,'Error constructing ptam_match from colstring.'); ")^
    )
   CALL stmt_push(io_stmt_cnt,'ASIS(" end if; ")')
   CALL stmt_push(io_stmt_cnt,'ASIS(" end if; ")')
   CALL stmt_push(io_stmt_cnt,'ASIS("  return(v_where);")')
   CALL stmt_push(io_stmt_cnt,'ASIS("end; ")')
   CALL stmt_push(io_stmt_cnt,"end go")
   SET stat = alterlist(stmt_buffer->data,v_stmt_cnt)
   EXECUTE dm2_stmt_exe "FUNCTION", s_func_name WITH replace("REQUEST","STMT_BUFFER"), replace(
    "REPLY","SE_REPLY")
   SET io_stmt_cnt = 0
   IF ((se_reply->err_ind=1))
    SET dm_err->emsg = "Error occurred in dm2_stmt_exe."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE create_input_parm_ora(i_col_name,i_col_cnt)
   DECLARE s_col_parm = vc
   IF (size(i_col_name,1) < 25)
    SET s_col_parm = concat("i_",i_col_name)
   ELSE
    SET s_col_parm = build("i_",substring(1,25,i_col_name),format(i_col_cnt,"###;P0"))
   ENDIF
   RETURN(s_col_parm)
 END ;Subroutine
 IF (check_logfile("dm_rmc_pk_where",".log","DM_RMC_PK_WHERE...") != 1)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to Create Log File"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 DECLARE v_drop_cnt = i4 WITH noconstant(0)
 DECLARE v_stmt_cnt = i4 WITH noconstant(0)
 DECLARE v_pkw_parm_cnt = i2 WITH protect, noconstant(0)
 FREE RECORD drpw_dguc_request
 RECORD drpw_dguc_request(
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
 FREE RECORD drpw_dguc_reply
 RECORD drpw_dguc_reply(
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
 SET drpw_dguc_request->what_tables = request->table_name
 SET drpw_dguc_request->local_tables_ind = request->local_ind
 SET drpw_dguc_request->is_ref_ind = 1
 SET dm_err->eproc = "dm_rmc_pk_where: calling dm_get_unique_columns"
 CALL disp_msg("",dm_err->logfile,0)
 EXECUTE dm_get_unique_columns  WITH replace("DGUC_REQUEST","DRPW_DGUC_REQUEST"), replace(
  "DGUC_REPLY","DRPW_DGUC_REPLY")
 IF ((drpw_dguc_reply->dguc_err_ind=1))
  SET reply->error_ind = 1
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Error returned from dm_get_unique_columns, view log_file for details."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (size(drpw_dguc_reply->dtd_hold,5) > 0)
  SET dm_err->eproc =
  "dm_rmc_pk_where: transferring column data to record struct for trigger generation"
  CALL disp_msg("",dm_err->logfile,0)
  CALL cl_move_over(drpw_dguc_reply,request->table_name,"REFCHG",0,request->local_ind)
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   SET reply->error_ind = 1
   GO TO exit_program
  ENDIF
 ELSE
  SET reply->error_ind = 1
  SET dm_err->err_ind = 1
  SET dm_err->emsg =
  "Requested table(s) not found in dguc_reply after return from dm_get_unique_columns."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "dm_rmc_pk_where: generating new pk_where function"
 CALL disp_msg("",dm_err->logfile,0)
 CALL create_pk_where_function_ora(1,v_drop_cnt,v_stmt_cnt,request->local_ind)
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET reply->error_ind = 1
  GO TO exit_program
 ENDIF
 SET reply->function_name = rs_dtd_reply->dtd_hold[1].pkw_function
 SET v_pkw_parm_count = size(rs_dtd_reply->dtd_hold[1].pk_where_parm,5)
 SET stat = alterlist(reply->parms,v_pkw_parm_count)
 FOR (s_idx = 1 TO v_pkw_parm_count)
   SET reply->parms[s_idx].column_name = rs_dtd_reply->dtd_hold[1].pk_where_parm[s_idx].column_name
 ENDFOR
#exit_program
END GO
