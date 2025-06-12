CREATE PROGRAM dm_rmc_mover_main:dba
 SET trace progcachesize 255
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
 DECLARE fill_rs(type=vc,info=vc) = i4 WITH public
 DECLARE check_xlat_backfill(i_src_env_id=f8,i_tgt_env_id=f8,i_mock_env_id=f8) = i2
 DECLARE dm2_rdds_get_tgt_id(s_gmti_tgt_rs=vc(ref)) = i2
 DECLARE drmm_breakup_string(sbr_rs_reply=vc(ref)) = vc
 IF (validate(perm_tbl_cnt,- (1)) < 0)
  DECLARE perm_tbl_cnt = i4
  DECLARE temp_tbl_cnt = i4
  DECLARE perm_cs_cnt = i4
  DECLARE temp_cs_cnt = i4
  RECORD dm2_ref_data_doc(
    1 pre_link_name = vc
    1 post_link_name = vc
    1 mock_target_id = f8
    1 env_source_id = f8
    1 env_target_id = f8
    1 tbl_cnt = i4
    1 tbl_qual[*]
      2 table_name = vc
      2 r_table_name = vc
      2 mergeable_ind = i2
      2 reference_ind = i2
      2 version_ind = i2
      2 version_type = vc
      2 user_gen_date_ind = i2
      2 merge_ui_query = vc
      2 merge_ui_query_ni = i4
      2 suffix = vc
      2 merge_delete_ind = i2
      2 delete_select_ind = i2
      2 skip_seqmatch_ind = i2
      2 custom_script = vc
      2 insert_only_ind = i2
      2 update_only_ind = i2
      2 active_ind_ind = i2
      2 effective_col_ind = i2
      2 beg_col_name = vc
      2 end_col_name = vc
      2 lob_process_type = vc
      2 col_cnt = i4
      2 long_ind = i2
      2 check_dual_build_ind = i2
      2 overrule_nomv06_ind = i2
      2 cur_state_flag = i4
      2 pk_where_hash = f8
      2 del_pk_where_hash = f8
      2 ptam_match_hash = f8
      2 root_col_name = vc
      2 pre_scan_ind = i2
      2 col_qual[*]
        3 column_name = vc
        3 unique_ident_ind = i4
        3 exception_flg = i4
        3 constant_value = vc
        3 parent_entity_col = vc
        3 sequence_name = vc
        3 root_entity_name = vc
        3 root_entity_attr = vc
        3 merge_delete_ind = i2
        3 internal_col_id = i4
        3 data_type = vc
        3 data_length = vc
        3 binary_long_ind = i2
        3 pk_ind = i2
        3 code_set = i4
        3 base62_re_name = vc
        3 nullable = c1
        3 check_null = i2
        3 check_space = i2
        3 translated = i2
        3 idcd_ind = i2
        3 r_tgt_flag = i4
        3 in_tgt_flag = i2
        3 data_default = vc
        3 db_data_type = vc
        3 db_data_length = i4
        3 data_default_ni = i2
        3 db_data_type_tgt = vc
        3 defining_attribute_ind = i2
        3 version_nbr_child_ind = i2
        3 parent_table = vc
        3 parent_pk_col = vc
        3 parent_vers_col = vc
        3 child_fk_col = vc
        3 execution_flag = i4
        3 object_name = vc
        3 masked_object_name = vc
        3 ccl_data_type = vc
        3 parm_cnt = i4
        3 parm_list[*]
          4 column_name = vc
        3 pk_required_ind = i2
        3 trailing_space_cnt = i4
        3 long_encoded_cnt = i4
        3 long_encoded_qual[*]
          4 check_str = vc
          4 encoded_type = vc
        3 trailing_space_cnt = i4
        3 7circ_cnt = i4
        3 7circ_qual[*]
          4 other_tab_name = vc
          4 other_id_col = vc
          4 other_name_col = vc
          4 7id_col = vc
          4 7name_col = vc
      2 parent_flag = i4
      2 child_flag = i4
      2 parent_qual[*]
        3 child_name = vc
        3 parent_id_col = vc
        3 parent_tab_col = vc
        3 in_src_ind = i2
        3 parent_r_col = vc
      2 filter_string = vc
      2 circular_cnt = i4
      2 circ_qual[*]
        3 circ_table_name = vc
        3 circ_id_col_name = vc
        3 circ_pe_name_col = vc
        3 circular_type = i4
        3 pe_name_col = vc
        3 id_col = vc
      2 other_circ_cnt = i4
      2 other_circ_qual[*]
        3 other_id_col = vc
        3 other_name_col = vc
        3 7id_col = vc
        3 7name_col = vc
        3 7tab_name = vc
    1 cs_cnt = i4
    1 cs_qual[*]
      2 code_set = i4
      2 merge_ui_query = vc
      2 merge_ui_query_ni = i2
      2 cdf_meaning_dup_ind = i2
      2 display_dup_ind = i2
      2 display_key_dup_ind = i2
      2 active_ind_dup_ind = i2
      2 definition_dup_ind = i2
  )
  FREE RECORD global_mover_rec
  RECORD global_mover_rec(
    1 cbc_ind = i2
    1 refchg_buffer = i4
    1 loop_back_ind = i2
    1 force_drop_ind = i2
    1 auto_cutover_ind = i2
    1 context_ind = i2
    1 ctxts_to_pull = vc
    1 ctxt_to_set = vc
    1 default_ctxt = vc
    1 one_pass_ind = i2
    1 refchg_upd_cnt = i4
    1 invalid_xlat_ind = i2
    1 ptam_ind = i2
    1 xlat_to_function = vc
    1 xlat_from_function = vc
    1 xlat_funct_nbr = f8
    1 reset_xcptn_ind = i2
    1 md_row_limit = i4
    1 ccl_stmt = vc
    1 qual[*]
      2 pattern_cki = vc
    1 tier_cnt = i4
    1 tier_qual[*]
      2 table_name = vc
      2 tier_value = i4
    1 prefdir_cnt = i4
    1 prefdir_qual[*]
      2 preference = vc
    1 exact_prefdir_cnt = i4
    1 exact_prefdir_qual[*]
      2 preference = vc
    1 circ_nomv_excl_cnt = i4
    1 circ_nomv_qual[*]
      2 log_type = vc
  )
  SET dm2_ref_data_doc->env_target_id = - (1)
  SET dm2_ref_data_doc->env_source_id = - (1)
  SET dm2_ref_data_doc->mock_target_id = - (1)
  FREE RECORD missing_xlats
  RECORD missing_xlats(
    1 qual[*]
      2 table_name = vc
      2 column_name = vc
      2 missing_value = f8
      2 processed_ind = i2
      2 orphan_ind = i2
      2 tier_value = i4
  )
  FREE RECORD pk_where_parm
  RECORD pk_where_parm(
    1 qual[*]
      2 check_cnt = i2
      2 table_name = vc
      2 source_pk_where_ok_ind = i2
      2 target_pk_where_function = vc
      2 col_qual[*]
        3 col_name = vc
      2 target_col_qual[*]
        3 col_name = vc
  )
  FREE RECORD filter_parm
  RECORD filter_parm(
    1 qual[*]
      2 table_name = vc
      2 col_qual[*]
        3 col_name = vc
  )
  FREE RECORD cur_state_tabs
  RECORD cur_state_tabs(
    1 total = i4
    1 qual[*]
      2 table_name = vc
      2 parent_tab_col = vc
      2 parent_cnt = i4
      2 parent_qual[*]
        3 parent_table = vc
        3 top_level_parent = vc
  )
 ENDIF
 IF ((validate(dm2_rdds_curdb_schema->col_cnt,- (1))=- (1)))
  FREE RECORD dm2_rdds_curdb_schema
  RECORD dm2_rdds_curdb_schema(
    1 same_count = i4
    1 ccl_same_cnt = i4
    1 ddl_exist_flag = c1
    1 appl_id = vc
    1 table_name = vc
    1 col_cnt = i4
    1 col[*]
      2 column_name = vc
      2 data_type = vc
      2 data_length = f8
  )
  SET dm2_rdds_curdb_schema->appl_id = "NOT SET"
 ENDIF
 FREE RECORD dmda_breakup_str
 RECORD dmda_breakup_str(
   1 str_text = vc
   1 str_delim = vc
   1 str_delim_ind = i4
   1 str_limit = i4
   1 substr[*]
     2 str = vc
 )
 SUBROUTINE fill_rs(type,info)
   FREE RECORD fill_rs_reply
   RECORD fill_rs_reply(
     1 error_flag = i4
   )
   FREE RECORD fill_rs_request
   RECORD fill_rs_request(
     1 info = vc
     1 type = vc
   )
   SET fill_rs_request->info = info
   SET fill_rs_request->type = type
   EXECUTE dm_fill_rs  WITH replace("REQUEST","FILL_RS_REQUEST"), replace("ERROR_REPLY",
    "FILL_RS_REPLY"), replace("REPLY","DM2_REF_DATA_DOC")
   IF ((fill_rs_reply->error_flag=1))
    RETURN(- (1))
   ELSEIF ((fill_rs_reply->error_flag=- (2)))
    RETURN(- (2))
   ELSE
    IF (type="TABLE")
     RETURN(temp_tbl_cnt)
    ELSE
     CALL echo(temp_cs_cnt)
     RETURN(temp_cs_cnt)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE check_xlat_backfill(i_src_env_id,i_tgt_env_id,i_mock_env_id)
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
   DECLARE cxb_xlat_cnt = i4 WITH protect, noconstant(0)
   DECLARE cxb_seq_cnt = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Checking for translation backfill event."
   SELECT INTO "nl:"
    cnt = count(DISTINCT d.event_detail1_txt)
    FROM dm_rdds_event_detail d
    WHERE d.dm_rdds_event_log_id IN (
    (SELECT
     d2.dm_rdds_event_log_id
     FROM dm_rdds_event_log d2
     WHERE d2.rdds_event_key="TRANSLATIONBACKFILLFINISHED"
      AND d2.cur_environment_id=i_mock_env_id
      AND d2.paired_environment_id=i_src_env_id))
    DETAIL
     cxb_xlat_cnt = cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (cxb_xlat_cnt >= 30)
    RETURN(1)
   ENDIF
   IF (cxb_xlat_cnt=0)
    SELECT INTO "nl:"
     cnt = count(DISTINCT dcd.sequence_name)
     FROM dm_columns_doc dcd,
      dm_tables_doc dtd
     WHERE ((dtd.reference_ind=1) OR (dtd.table_name IN (
     (SELECT
      rt.table_name
      FROM dm_rdds_refmrg_tables rt))))
      AND dtd.table_name=dtd.full_table_name
      AND dtd.table_name=dcd.table_name
      AND dcd.table_name=dcd.root_entity_name
      AND dcd.column_name=dcd.root_entity_attr
      AND trim(dcd.sequence_name) > " "
      AND dcd.sequence_name IS NOT null
      AND  NOT ( EXISTS (
     (SELECT
      "x"
      FROM dm_info di2
      WHERE sqlpassthru("dcd.table_name like di2.info_char and dcd.column_name like di2.info_name ")
       AND di2.info_domain="RDDS IGNORE COL LIST:*")))
     DETAIL
      cxb_seq_cnt = cnt
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET stat = alterlist(auto_ver_request->qual,1)
    IF (cxb_seq_cnt > 0)
     SET auto_ver_request->qual[1].event_reason = cnvtstring(cxb_seq_cnt)
    ELSE
     SET auto_ver_request->qual[1].event_reason = ""
    ENDIF
    SET auto_ver_request->qual[1].rdds_event = "Translation Backfill Finished"
    SET auto_ver_request->qual[1].cur_environment_id = i_mock_env_id
    SET auto_ver_request->qual[1].paired_environment_id = i_src_env_id
    SET dm_err->eproc = "Checking dm_info for DONE2 rows."
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain=concat("MERGE",trim(cnvtstring(i_src_env_id,20)),trim(cnvtstring(
        i_mock_env_id,20)),"SEQMATCHDONE2")
     HEAD REPORT
      cxb_xlat_cnt = 0
     DETAIL
      cxb_xlat_cnt = (cxb_xlat_cnt+ 1)
      IF (mod(cxb_xlat_cnt,10)=1)
       stat = alterlist(auto_ver_request->qual[1].detail_qual,(cxb_xlat_cnt+ 9))
      ENDIF
      auto_ver_request->qual[1].detail_qual[cxb_xlat_cnt].event_detail1_txt = di.info_name
     FOOT REPORT
      stat = alterlist(auto_ver_request->qual[1].detail_qual,cxb_xlat_cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (cxb_xlat_cnt > 0)
     EXECUTE dm_rmc_auto_verify_setup
     IF ((auto_ver_reply->status="F"))
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET stat = initrec(auto_ver_request)
      SET stat = initrec(auto_ver_reply)
      RETURN(0)
     ENDIF
    ENDIF
    SET stat = initrec(auto_ver_request)
    SET stat = initrec(auto_ver_reply)
   ENDIF
   IF (cxb_xlat_cnt < 30)
    SET dm_err->eproc = "Checking for translation backfill event in reverse direction."
    SELECT INTO "nl:"
     cnt = count(DISTINCT d.event_detail1_txt)
     FROM dm_rdds_event_detail d
     WHERE d.dm_rdds_event_log_id IN (
     (SELECT
      d2.dm_rdds_event_log_id
      FROM dm_rdds_event_log d2
      WHERE d2.rdds_event_key="TRANSLATIONBACKFILLFINISHED"
       AND d2.cur_environment_id=i_src_env_id
       AND d2.paired_environment_id=i_mock_env_id))
     DETAIL
      cxb_xlat_cnt = cnt
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (cxb_xlat_cnt >= 30)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_rdds_get_tgt_id(s_gmti_tgt_rs)
   SET dm_err->eproc = "GET TARGET ENVIRONMENT ID"
   CALL disp_msg(" ",dm_err->logfile,0)
   DECLARE drgmti_return_val = i2
   SET drgmti_return_val = 1
   IF ((s_gmti_tgt_rs->env_target_id=- (1)))
    SELECT INTO "NL:"
     FROM dm_info d
     WHERE d.info_domain="DATA MANAGEMENT"
      AND d.info_name="DM_ENV_ID"
     DETAIL
      s_gmti_tgt_rs->env_target_id = d.info_number
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET drgmti_return_val = 0
     RETURN(drgmti_return_val)
    ELSEIF (curqual=0)
     SET drgmti_return_val = 0
     SET dm_err->emsg = "INVALID TARGET ENV_ID OF ZERO FOUND"
     SET dm_err->user_action = "PLEASE RUN DM_SET_ENV_ID"
     RETURN(drgmti_return_val)
    ENDIF
   ENDIF
   IF ((s_gmti_tgt_rs->mock_target_id=- (1)))
    SET s_gmti_tgt_rs->mock_target_id = drmmi_get_mock_id(s_gmti_tgt_rs->env_target_id)
    IF ((s_gmti_tgt_rs->mock_target_id < 0))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET drgmti_return_val = 0
     RETURN(drgmti_return_val)
    ENDIF
   ENDIF
   RETURN(drgmti_return_val)
 END ;Subroutine
 SUBROUTINE drmm_breakup_string(sbr_rs_reply)
   DECLARE dbs_substr = vc
   DECLARE dbs_delim_pos = i4
   DECLARE dbs_str_remain = vc
   DECLARE dbs_delim_len = i4
   DECLARE dbs_substr_cnt = i4 WITH noconstant(0)
   SET dbs_str_remain = sbr_rs_reply->str_text
   SET dbs_delim_len = size(sbr_rs_reply->str_delim,1)
   CASE (sbr_rs_reply->str_delim_ind)
    OF 0:
     IF ((substring(1,dbs_delim_len,dbs_str_remain)=sbr_rs_reply->str_delim))
      SET dbs_str_remain = substring((dbs_delim_len+ 1),size(dbs_str_remain,1),dbs_str_remain)
     ENDIF
    OF 1:
     IF ((substring(((size(dbs_str_remain,1) - dbs_delim_len)+ 1),dbs_delim_len,dbs_str_remain)=
     sbr_rs_reply->str_delim))
      SET dbs_str_remain = substring(1,(size(dbs_str_remain,1) - dbs_delim_len),dbs_str_remain)
     ENDIF
    OF 2:
     CALL echo(substring(1,dbs_delim_len,dbs_str_remain))
     IF ((substring(1,dbs_delim_len,dbs_str_remain)=sbr_rs_reply->str_delim))
      SET dbs_str_remain = substring((dbs_delim_len+ 1),size(dbs_str_remain,1),dbs_str_remain)
      CALL echo(dbs_str_remain)
     ENDIF
     CALL echo(substring(((size(dbs_str_remain,1) - dbs_delim_len)+ 1),dbs_delim_len,dbs_str_remain))
     IF ((substring(((size(dbs_str_remain,1) - dbs_delim_len)+ 1),dbs_delim_len,dbs_str_remain)=
     sbr_rs_reply->str_delim))
      SET dbs_str_remain = substring(1,(size(dbs_str_remain,1) - dbs_delim_len),dbs_str_remain)
     ENDIF
   ENDCASE
   WHILE ((size(dbs_str_remain,1) >= sbr_rs_reply->str_limit))
     SET dbs_substr = substring(1,sbr_rs_reply->str_limit,dbs_str_remain)
     IF (dbs_delim_len > 0)
      SET dbs_delim_pos = findstring(sbr_rs_reply->str_delim,dbs_substr,1,1)
      IF (dbs_delim_pos > 0)
       CASE (sbr_rs_reply->str_delim_ind)
        OF 0:
         SET dbs_substr = substring(1,((dbs_delim_pos+ dbs_delim_len) - 1),dbs_str_remain)
         SET dbs_str_remain = substring((dbs_delim_pos+ dbs_delim_len),size(dbs_str_remain,1),
          dbs_str_remain)
        OF 1:
         SET dbs_substr = substring(1,(dbs_delim_pos - 1),dbs_str_remain)
         SET dbs_str_remain = substring(dbs_delim_pos,size(dbs_str_remain,1),dbs_str_remain)
        OF 2:
         SET dbs_substr = substring(1,(dbs_delim_pos - 1),dbs_str_remain)
         SET dbs_str_remain = substring((dbs_delim_pos+ dbs_delim_len),size(dbs_str_remain,1),
          dbs_str_remain)
       ENDCASE
      ELSE
       SET stat = alterlist(sbr_rs_reply->substr,0)
       RETURN("F")
      ENDIF
     ELSE
      SET dbs_str_remain = substring(sbr_rs_reply->str_limit,size(dbs_str_remain,1),dbs_str_remain)
     ENDIF
     SET dbs_substr_cnt = (dbs_substr_cnt+ 1)
     SET stat = alterlist(sbr_rs_reply->substr,dbs_substr_cnt)
     SET sbr_rs_reply->substr[dbs_substr_cnt].str = dbs_substr
   ENDWHILE
   SET dbs_substr_cnt = (dbs_substr_cnt+ 1)
   SET stat = alterlist(sbr_rs_reply->substr,dbs_substr_cnt)
   SET sbr_rs_reply->substr[dbs_substr_cnt].str = dbs_str_remain
   RETURN("S")
 END ;Subroutine
 IF ((validate(sx_request->cnt,- (99))=- (99)))
  FREE RECORD sx_request
  RECORD sx_request(
    1 cnt = i4
    1 stmt[*]
      2 str = vc
  ) WITH protect
 ENDIF
 IF ((validate(sx_reply->row_count,- (99))=- (99)))
  FREE RECORD sx_reply
  RECORD sx_reply(
    1 row_count = i4
  ) WITH protect
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
 IF (validate(dm_batch_list_req->dblg_owner,"XYZ")="XYZ"
  AND validate(dm_batch_list_req->dblg_owner,"ABC")="ABC")
  FREE RECORD dm_batch_list_req
  RECORD dm_batch_list_req(
    1 dblg_owner = vc
    1 dblg_table = vc
    1 dblg_table_id = vc
    1 dblg_column = vc
    1 dblg_where = vc
    1 dblg_mode = vc
    1 dblg_num_cnt = i4
  )
 ENDIF
 IF (validate(dm_batch_list_rep->status_msg,"XYZ")="XYZ"
  AND validate(dm_batch_list_rep->status_msg,"ABC")="ABC")
  FREE RECORD dm_batch_list_rep
  RECORD dm_batch_list_rep(
    1 status = c1
    1 status_msg = vc
    1 list[*]
      2 batch_num = i4
      2 max_value = vc
  )
 ENDIF
 DECLARE seqmatch_xlats(i_sequence_name=vc,i_source_env_id=f8,i_table_name=vc) = vc
 DECLARE app_task_backfill(i_atb_source_env_id=f8) = vc
 DECLARE seqmatch_event_chk(i_source_id=f8,i_target_id=f8,i_sequence_name=vc) = vc
 DECLARE add_src_done_2(i_src_id=f8,i_tgt_id=f8,i_tgt_mock_id=f8,i_sequence=vc) = vc
 DECLARE cs93_xlat_backfill(cxb_source_id=f8) = vc
 DECLARE cs93_fix_done2(cfd_source_id=f8,cfd_target_id=f8,cfd_mock_id=f8,cfd_db_link=vc,
  cfd_seqmatch_value=f8) = vc
 DECLARE cs93_create_seqmatch(ccs_rec=vc(ref)) = vc
 SUBROUTINE seqmatch_xlats(i_sequence_name,i_source_env_id,i_table_name)
   SET dm_err->eproc = concat("Start Xlat Backfill",format(cnvtdatetime(curdate,curtime3),cclfmt->
     mediumdatetime))
   CALL disp_msg("",dm_err->logfile,0)
   DECLARE sx_table_suffix = vc
   DECLARE sx_live_table_name = vc
   DECLARE sx_sequence_name = vc
   DECLARE sx_target_id = f8
   DECLARE sx_t_id1 = f8
   DECLARE sx_db_link = vc
   DECLARE sx_seq_match_domain = vc
   DECLARE sx_src_seq_match_domain = vc WITH protect, noconstant("")
   DECLARE sx_seq_match_num = f8
   DECLARE sx_val_loop = i4
   DECLARE sx_dmt_source = vc
   DECLARE sx_filter_name = vc
   DECLARE sx_filter = vc
   DECLARE sx_col_loop = i4
   DECLARE sx_next_seq = f8
   DECLARE sx_continue_ind = i2
   DECLARE sx_insert_limit = i4
   DECLARE sx_asd2_ret = vc WITH protect, noconstant("")
   DECLARE sx_sec_ret = vc WITH protect, noconstant("")
   DECLARE sx_tbl_allrow_cnt = f8 WITH protect, noconstant(0.0)
   DECLARE sx_tbl_fltr_cnt = f8 WITH protect, noconstant(0.0)
   DECLARE sx_range_start = vc WITH protect, noconstant("")
   DECLARE sx_range_end = vc WITH protect, noconstant("")
   DECLARE sx_range_idx = i4 WITH protect, noconstant(0)
   DECLARE sx_seq_match_num_src = f8 WITH protect, noconstant(0.0)
   DECLARE sx_s_col_name = vc
   DECLARE sx_t_col_name = vc
   DECLARE sx_s_table_name = vc
   DECLARE sx_dmt_s = vc
   DECLARE sx_atb_return = vc
   FREE RECORD sx_tbl_list
   RECORD sx_tbl_list(
     1 cnt = i4
     1 qual[*]
       2 table_name = vc
       2 column_name = vc
       2 suffix = vc
       2 val_cnt = i4
       2 values[*]
         3 source_val = f8
   )
   FREE RECORD sx_filter_columns
   RECORD sx_filter_columns(
     1 cnt = i4
     1 qual[*]
       2 column_name = vc
   )
   IF (trim(i_sequence_name) <= "")
    IF (trim(i_table_name) > "")
     IF (cnvtupper(i_table_name)="*$R")
      SET sx_table_suffix = substring((size(i_table_name) - 5),4,i_table_name)
      SELECT INTO "nl:"
       FROM dm_tables_doc dtd
       WHERE dtd.table_suffix=sx_table_suffix
        AND dtd.full_table_name=dtd.table_name
       DETAIL
        sx_live_table_name = dtd.table_name
       WITH nocounter
      ;end select
      IF (check_error("Obtaining live table name") != 0)
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ENDIF
      IF (curqual=0)
       CALL echo("*****************************************************************")
       CALL echo("")
       CALL echo("Error: seqmatch_xlats():Live table name could not be obtained from ")
       CALL echo("table_name passed in.")
       CALL echo("")
       CALL echo("*****************************************************************")
       RETURN("F")
      ENDIF
     ELSE
      SET sx_live_table_name = cnvtupper(i_table_name)
     ENDIF
     IF (cnvtupper(sx_live_table_name)="APPLICATION_TASK")
      SET sx_atb_return = app_task_backfill(i_source_env_id)
      RETURN(sx_atb_return)
     ENDIF
     SELECT INTO "nl:"
      dcd.sequence_name
      FROM dm_columns_doc dcd,
       dm_tables_doc dtd
      WHERE dtd.table_name=sx_live_table_name
       AND ((dtd.reference_ind=1) OR (dtd.table_name IN (
      (SELECT
       rt.table_name
       FROM dm_rdds_refmrg_tables rt))))
       AND dtd.table_name IN (
      (SELECT
       ut.table_name
       FROM user_tables ut))
       AND dtd.table_name=dtd.full_table_name
       AND dtd.table_name=dcd.table_name
       AND dcd.table_name=dcd.root_entity_name
       AND dcd.column_name=dcd.root_entity_attr
       AND  NOT (dtd.table_name IN (
      (SELECT
       cv.display
       FROM code_value cv
       WHERE cv.code_set=4001912
        AND cv.cdf_meaning="NORDDSTRG"
        AND cv.active_ind=1)))
       AND  NOT ( EXISTS (
      (SELECT
       "x"
       FROM dm_info di
       WHERE di.info_domain="RDDS IGNORE COL LIST:*"
        AND sqlpassthru(" dcd.column_name like di.info_name and dcd.table_name like di.info_char"))))
      DETAIL
       sx_sequence_name = dcd.sequence_name
      WITH nocounter
     ;end select
     IF (check_error("Obtaining sequence name") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     IF (curqual=0)
      RETURN("S")
     ENDIF
    ELSE
     CALL echo("*****************************************************************")
     CALL echo("")
     CALL echo("Error: seqmatch_xlats():sequence_name and table_name passed in")
     CALL echo("were not filled out.")
     CALL echo("")
     CALL echo("*****************************************************************")
     RETURN("F")
    ENDIF
   ELSE
    SET sx_sequence_name = i_sequence_name
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="DM_ENV_ID"
    DETAIL
     sx_t_id1 = di.info_number
    WITH nocounter
   ;end select
   IF (check_error("Obtaining target id") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF (curqual=0)
    CALL echo("*****************************************************************")
    CALL echo("")
    CALL echo("Error: seqmatch_xlats():no dm_info row found to obtain target_id")
    CALL echo("")
    CALL echo("*****************************************************************")
    RETURN("F")
   ENDIF
   SET sx_db_link = build("@MERGE",cnvtstring(i_source_env_id,20,0),cnvtstring(sx_t_id1,20,0))
   SET sx_target_id = drmmi_get_mock_id(sx_t_id1)
   IF (sx_target_id < 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   SET sx_seq_match_domain = build("MERGE",cnvtstring(i_source_env_id,20,0),cnvtstring(sx_target_id,
     20,0),"SEQMATCH")
   SET sx_src_seq_match_domain = build("MERGE",cnvtstring(sx_target_id,20,0),cnvtstring(
     i_source_env_id,20,0),"SEQMATCH")
   SET sx_dmt_source = build("DM_MERGE_TRANSLATE",sx_db_link)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=sx_seq_match_domain
     AND di.info_name=sx_sequence_name
    DETAIL
     sx_seq_match_num = di.info_number
    WITH nocounter
   ;end select
   IF (check_error("Obtaining sequence match value") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF (sx_seq_match_num <= 0)
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain=concat(trim(sx_seq_match_domain),"DONE2")
      AND di.info_name=sx_sequence_name
     WITH nocounter
    ;end select
    IF (check_error("Checking DONE2 sequence row") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    IF (curqual=0)
     INSERT  FROM dm_info di
      SET di.info_domain = concat(trim(sx_seq_match_domain),"DONE2"), di.info_name = sx_sequence_name,
       di.info_number = 0,
       di.updt_task = 4310001, di.updt_id = reqinfo->updt_id, di.updt_cnt = 0,
       di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (check_error("Inserting 0 sequence row in dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ELSE
      IF (sx_sequence_name="REFERENCE_SEQ")
       SET sx_sec_ret = cs93_fix_done2(i_source_env_id,sx_t_id1,sx_target_id,sx_db_link,0.0)
       IF (sx_sec_ret="F")
        SET dm_err->err_ind = 1
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        RETURN("F")
       ENDIF
      ENDIF
      COMMIT
      SET sx_sec_ret = seqmatch_event_chk(i_source_env_id,sx_t_id1,sx_sequence_name)
      IF (sx_sec_ret="F")
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ENDIF
      SET sx_asd2_ret = add_src_done_2(i_source_env_id,sx_t_id1,sx_target_id,sx_sequence_name)
      IF (sx_asd2_ret="F")
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ENDIF
      RETURN("S")
     ENDIF
    ELSE
     RETURN("S")
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM (parser(concat("dm_info",sx_db_link)) di)
    WHERE di.info_domain=concat(sx_src_seq_match_domain,"DONE2")
     AND di.info_name=sx_sequence_name
    DETAIL
     sx_seq_match_num_src = di.info_number
    WITH nocounter
   ;end select
   IF (check_error("Obtaining sequence match value") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF (curqual > 0)
    IF (sx_sequence_name="REFERENCE_SEQ")
     SET sx_sec_ret = cs93_fix_done2(i_source_env_id,sx_t_id1,sx_target_id,sx_db_link,
      sx_seq_match_num_src)
     IF (sx_sec_ret="F")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain=concat(trim(sx_seq_match_domain),"DONE2")
      AND di.info_name=sx_sequence_name
     WITH nocounter
    ;end select
    IF (check_error("Checking DONE2 sequence row") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    IF (curqual=0)
     UPDATE  FROM dm_info di
      SET di.info_domain = concat(trim(sx_seq_match_domain),"DONE2"), di.updt_task = 4310001, di
       .updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE di.info_domain=sx_seq_match_domain
       AND di.info_name=sx_sequence_name
      WITH nocounter
     ;end update
     IF (check_error("Updating sequence done2 row in dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     INSERT  FROM dm_info di
      SET di.info_domain = sx_seq_match_domain, di.info_name = sx_sequence_name, di.info_number = 0,
       di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_task = 4310001
      WITH nocounter
     ;end insert
     IF (check_error("Updating old sequence row in dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     COMMIT
     SET sx_sec_ret = seqmatch_event_chk(i_source_env_id,sx_t_id1,sx_sequence_name)
     IF (sx_sec_ret="F")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     RETURN("S")
    ELSE
     UPDATE  FROM dm_info di
      SET di.info_number = sx_seq_match_num, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di
       .updt_task = 4310001
      WHERE di.info_domain=concat(trim(sx_seq_match_domain),"DONE2")
       AND di.info_name=sx_sequence_name
      WITH nocounter
     ;end update
     IF (check_error("Updating sequence done2 row in dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     UPDATE  FROM dm_info di
      SET di.info_number = 0, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_task = 4310001
      WHERE di.info_domain=sx_seq_match_domain
       AND di.info_name=sx_sequence_name
      WITH nocounter
     ;end update
     IF (check_error("Updating old sequence row in dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     COMMIT
     SET sx_sec_ret = seqmatch_event_chk(i_source_env_id,sx_t_id1,sx_sequence_name)
     IF (sx_sec_ret="F")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     RETURN("S")
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    dcd.table_name, dcd.column_name
    FROM dm_columns_doc dcd,
     dm_tables_doc dtd
    WHERE ((dtd.reference_ind=1) OR (dtd.table_name IN (
    (SELECT
     rt.table_name
     FROM dm_rdds_refmrg_tables rt))))
     AND dtd.table_name=dtd.full_table_name
     AND dtd.table_name=dcd.table_name
     AND ((dcd.table_name=dcd.root_entity_name
     AND dcd.column_name=dcd.root_entity_attr) OR (((dcd.table_name="DCP_FORMS_REF"
     AND dcd.column_name="DCP_FORMS_REF_ID") OR (dcd.table_name="DCP_SECTION_REF"
     AND dcd.column_name="DCP_SECTION_REF_ID")) ))
     AND list(dcd.table_name,dcd.column_name) IN (
    (SELECT
     utc.table_name, utc.column_name
     FROM user_tab_columns utc))
     AND dcd.sequence_name=sx_sequence_name
     AND  NOT (dtd.table_name IN (
    (SELECT
     cv.display
     FROM code_value cv
     WHERE cv.code_set=4001912
      AND cv.cdf_meaning="NORDDSTRG"
      AND cv.active_ind=1)))
     AND  NOT (dtd.table_name IN (
    (SELECT
     d.info_name
     FROM dm_info d
     WHERE d.info_domain="RDDS BACKFILL EXCLUSION")))
     AND list(dcd.table_name,dcd.column_name) IN (
    (SELECT
     utc2.table_name, utc2.column_name
     FROM (parser(build("user_tab_columns",sx_db_link)) utc2)))
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM dm_info di
     WHERE di.info_domain="RDDS IGNORE COL LIST:*"
      AND sqlpassthru(" dcd.column_name like di.info_name and dcd.table_name like di.info_char"))))
    HEAD REPORT
     sx_tbl_list->cnt = 0
    DETAIL
     sx_tbl_list->cnt = (sx_tbl_list->cnt+ 1)
     IF (mod(sx_tbl_list->cnt,10)=1)
      stat = alterlist(sx_tbl_list->qual,(sx_tbl_list->cnt+ 9))
     ENDIF
     sx_tbl_list->qual[sx_tbl_list->cnt].table_name = dcd.table_name, sx_tbl_list->qual[sx_tbl_list->
     cnt].column_name = dcd.column_name, sx_tbl_list->qual[sx_tbl_list->cnt].suffix = dtd
     .table_suffix
    FOOT REPORT
     stat = alterlist(sx_tbl_list->qual,sx_tbl_list->cnt)
    WITH nocounter
   ;end select
   IF (check_error("Obtaining tables associated with the current sequence") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF ((sx_tbl_list->cnt > 0))
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="RDDS CONFIGURATION"
      AND di.info_name="RXLAT_BELOW_SEQ_FILL"
     DETAIL
      sx_insert_limit = di.info_number
     WITH nocounter
    ;end select
    IF (check_error("Logging creation in dm_chg_log_audit") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    IF (curqual=0)
     SET sx_insert_limit = 100000
    ENDIF
    FOR (sx_val_loop = 1 TO sx_tbl_list->cnt)
      SELECT INTO "NL:"
       y = seq(dm_merge_audit_seq,nextval)
       FROM dual
       DETAIL
        sx_next_seq = y
       WITH nocounter
      ;end select
      IF (check_error("Popping a new value from DM_MERGE_AUDIT_SEQ") != 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ENDIF
      SET dm_err->eproc = concat("Start Table: ",sx_tbl_list->qual[sx_val_loop].table_name," ",format
       (cnvtdatetime(curdate,curtime3),cclfmt->mediumdatetime))
      CALL disp_msg("",dm_err->logfile,0)
      UPDATE  FROM dm_chg_log_audit dcla
       SET dcla.log_id = 0, dcla.action = "CREATEXLAT", dcla.table_name = sx_tbl_list->qual[
        sx_val_loop].table_name,
        dcla.text = concat("Backfill translations below seqmatch for sequence: ",sx_sequence_name,
         ", working on table ",cnvtstring(sx_val_loop)," of ",
         cnvtstring(sx_tbl_list->cnt),": ",sx_tbl_list->qual[sx_val_loop].table_name), dcla
        .updt_applctx = cnvtreal(currdbhandle), dcla.updt_cnt = 0,
        dcla.updt_dt_tm = sysdate, dcla.updt_id = reqinfo->updt_id, dcla.updt_task = reqinfo->
        updt_task,
        dcla.audit_dt_tm = sysdate
       WHERE dcla.dm_chg_log_audit_id=sx_next_seq
       WITH nocounter
      ;end update
      IF (check_error("Updating creation in dm_chg_log_audit") != 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ELSE
       COMMIT
      ENDIF
      IF (curqual=0)
       INSERT  FROM dm_chg_log_audit dcla
        SET dcla.dm_chg_log_audit_id = sx_next_seq, dcla.log_id = 0, dcla.action = "CREATEXLAT",
         dcla.table_name = sx_tbl_list->qual[sx_val_loop].table_name, dcla.text = concat(
          "Backfill translations below seqmatch for sequence: ",sx_sequence_name,
          ", working on table ",cnvtstring(sx_val_loop)," of ",
          cnvtstring(sx_tbl_list->cnt),": ",sx_tbl_list->qual[sx_val_loop].table_name), dcla
         .updt_applctx = cnvtreal(currdbhandle),
         dcla.updt_cnt = 0, dcla.updt_dt_tm = sysdate, dcla.updt_id = reqinfo->updt_id,
         dcla.updt_task = reqinfo->updt_task, dcla.audit_dt_tm = sysdate
        WITH nocounter
       ;end insert
      ENDIF
      IF (check_error("Logging creation in dm_chg_log_audit") != 0)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ELSE
       COMMIT
      ENDIF
      SET sx_filter_name = concat("REFCHG_FILTER_",sx_tbl_list->qual[sx_val_loop].suffix,"*")
      CALL echo(sx_filter_name)
      SELECT INTO "nl:"
       FROM user_objects uo
       WHERE uo.object_name=patstring(sx_filter_name)
        AND  NOT ( EXISTS (
       (SELECT
        di.info_name
        FROM dm_info di
        WHERE di.info_domain="RDDS BACKFILL FILTER EXCLUSION"
         AND (di.info_name=sx_tbl_list->qual[sx_val_loop].table_name))))
       DETAIL
        sx_filter_name = uo.object_name, sx_filter = uo.object_name
       WITH nocounter
      ;end select
      IF (check_error("Obtaining Filter") != 0)
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ENDIF
      IF (curqual=0)
       SET sx_filter = "1"
      ELSE
       SET sx_filter_name = concat("declare ",sx_filter_name,"()=i2 go")
       CALL parser(sx_filter_name)
       SELECT INTO "nl:"
        dr.column_name
        FROM dm_refchg_filter_parm dr
        WHERE (dr.table_name=sx_tbl_list->qual[sx_val_loop].table_name)
         AND dr.active_ind=1
        ORDER BY dr.parm_nbr
        HEAD REPORT
         sx_filter_columns->cnt = 0
        DETAIL
         sx_filter_columns->cnt = (sx_filter_columns->cnt+ 1), stat = alterlist(sx_filter_columns->
          qual,sx_filter_columns->cnt), sx_filter_columns->qual[sx_filter_columns->cnt].column_name
          = dr.column_name
        WITH nocounter
       ;end select
       IF (check_error("Obtaining columns for the filter") != 0)
        SET dm_err->err_ind = 1
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        RETURN("F")
       ENDIF
       IF (curqual > 0)
        SET sx_filter = concat(sx_filter,"('ADD'")
        FOR (sx_col_loop = 1 TO sx_filter_columns->cnt)
          SET sx_filter = concat(sx_filter,",t.",sx_filter_columns->qual[sx_col_loop].column_name,
           ",t.",sx_filter_columns->qual[sx_col_loop].column_name)
        ENDFOR
        SET sx_filter = concat(sx_filter,")")
       ELSE
        SET sx_filter = "1"
       ENDIF
      ENDIF
      SET sx_s_col_name = build("s.",sx_tbl_list->qual[sx_val_loop].column_name)
      SET sx_t_col_name = build("t.",sx_tbl_list->qual[sx_val_loop].column_name)
      SET sx_s_table_name = build(sx_tbl_list->qual[sx_val_loop].table_name,sx_db_link)
      SET sx_dmt_s = build("dm_merge_translate",sx_db_link)
      SET sx_continue_ind = 0
      SET sx_request->cnt = 1
      SET stat = alterlist(sx_request->stmt,sx_request->cnt)
      SET sx_reply->row_count = 0
      SET sx_tbl_fltr_cnt = 0
      SELECT INTO "nl:"
       cnt = count(*)
       FROM (parser(sx_tbl_list->qual[sx_val_loop].table_name) t)
       WHERE parser(concat("t.",sx_tbl_list->qual[sx_val_loop].column_name,
         " between 1 and sx_seq_match_num"))
        AND parser(concat(sx_filter," = 1"))
       DETAIL
        sx_tbl_fltr_cnt = cnt
       WITH nocounter
      ;end select
      IF (check_error(concat("Finding number of rows for table: ",sx_tbl_list->qual[sx_val_loop].
        table_name)) != 0)
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ENDIF
      SELECT INTO "nl:"
       cnt = count(ti.parent_entity_id)
       FROM dm_refchg_invalid_xlat ti
       WHERE (ti.parent_entity_name=sx_tbl_list->qual[sx_val_loop].table_name)
        AND ti.parent_entity_id BETWEEN 1 AND sx_seq_match_num
       DETAIL
        sx_tbl_fltr_cnt = (sx_tbl_fltr_cnt+ cnt)
       WITH nocounter
      ;end select
      IF (check_error(concat("Finding number of rows for table: ",sx_tbl_list->qual[sx_val_loop].
        table_name)) != 0)
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ENDIF
      IF (sx_tbl_fltr_cnt > sx_insert_limit)
       SET dm_batch_list_req->dblg_num_cnt = ceil((sx_tbl_fltr_cnt/ cnvtreal(sx_insert_limit)))
       SET dm_batch_list_req->dblg_where = concat(" where ",sx_tbl_list->qual[sx_val_loop].
        column_name," between 1 and ",cnvtstring(sx_seq_match_num)," and ",
        replace(sx_filter,"t.","")," = 1")
      ELSEIF (sx_tbl_fltr_cnt < sx_insert_limit
       AND sx_filter != "1")
       SET sx_tbl_allrow_cnt = 0
       SELECT INTO "nl:"
        cnt = count(*)
        FROM (parser(sx_tbl_list->qual[sx_val_loop].table_name) t)
        WHERE parser(concat("t.",sx_tbl_list->qual[sx_val_loop].column_name,
          " between 1 and sx_seq_match_num"))
        DETAIL
         sx_tbl_allrow_cnt = cnt
        WITH nocounter
       ;end select
       IF (check_error(concat("Finding number of rows for table: ",sx_tbl_list->qual[sx_val_loop].
         table_name)) != 0)
        SET dm_err->err_ind = 1
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        RETURN("F")
       ENDIF
       SELECT INTO "nl:"
        cnt = count(ti.parent_entity_id)
        FROM dm_refchg_invalid_xlat ti
        WHERE (ti.parent_entity_name=sx_tbl_list->qual[sx_val_loop].table_name)
         AND ti.parent_entity_id BETWEEN 1 AND sx_seq_match_num
        DETAIL
         sx_tbl_allrow_cnt = (sx_tbl_allrow_cnt+ cnt)
        WITH nocounter
       ;end select
       IF (check_error(concat("Finding number of rows for table: ",sx_tbl_list->qual[sx_val_loop].
         table_name)) != 0)
        SET dm_err->err_ind = 1
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        RETURN("F")
       ENDIF
       IF (sx_tbl_allrow_cnt > sx_insert_limit)
        SET dm_batch_list_req->dblg_num_cnt = ceil((sx_tbl_allrow_cnt/ cnvtreal(sx_insert_limit)))
        SET dm_batch_list_req->dblg_where = concat(" where ",sx_tbl_list->qual[sx_val_loop].
         column_name," between 1 and ",cnvtstring(sx_seq_match_num))
       ELSE
        SET stat = alterlist(dm_batch_list_rep->list,1)
        SET dm_batch_list_rep->list[1].max_value = cnvtstring(sx_seq_match_num,20,0)
        SET dm_batch_list_req->dblg_num_cnt = 1
        SET sx_continue_ind = 1
       ENDIF
      ELSE
       CALL echo("sx_tbl_allrow_cnt < sx_insert_limit")
       SET stat = alterlist(dm_batch_list_rep->list,1)
       SET dm_batch_list_rep->list[1].max_value = cnvtstring(sx_seq_match_num,20,0)
       SET dm_batch_list_req->dblg_num_cnt = 1
       SET sx_continue_ind = 1
      ENDIF
      IF (sx_continue_ind=0)
       SET dm_batch_list_req->dblg_owner = "V500"
       SET dm_batch_list_req->dblg_table = sx_tbl_list->qual[sx_val_loop].table_name
       SET dm_batch_list_req->dblg_column = sx_tbl_list->qual[sx_val_loop].column_name
       SET dm_batch_list_req->dblg_mode = "BATCH"
       EXECUTE dm_get_batch_list
       IF ((dm_batch_list_rep->status="F"))
        SET dm_err->err_ind = 1
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        RETURN("F")
       ENDIF
      ENDIF
      FOR (sx_range_idx = 1 TO size(dm_batch_list_rep->list,5))
        IF (sx_range_idx=1)
         SET sx_range_start = "1"
        ELSE
         SET sx_range_start = cnvtstring(dm_batch_list_rep->list[(sx_range_idx - 1)].max_value,20,0)
        ENDIF
        IF (sx_range_idx=size(dm_batch_list_rep->list,5))
         SET sx_range_end = cnvtstring(sx_seq_match_num,20,0)
        ELSE
         SET sx_range_end = cnvtstring(dm_batch_list_rep->list[sx_range_idx].max_value,20,0)
        ENDIF
        SELECT INTO "NL:"
         y = seq(dm_merge_audit_seq,nextval)
         FROM dual
         DETAIL
          sx_next_seq = y
         WITH nocounter
        ;end select
        IF (check_error("Popping a new value from DM_MERGE_AUDIT_SEQ") != 0)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         ROLLBACK
         RETURN("F")
        ENDIF
        CALL echo(sx_tbl_list->qual[sx_val_loop].table_name)
        UPDATE  FROM dm_chg_log_audit dcla
         SET dcla.log_id = 0, dcla.action = "CREATEXLAT", dcla.table_name = sx_tbl_list->qual[
          sx_val_loop].table_name,
          dcla.text = concat("Backfill translations for sequence: ",sx_sequence_name,", table: ",
           sx_tbl_list->qual[sx_val_loop].table_name," batch: ",
           cnvtstring(sx_range_idx)," of ",cnvtstring(dm_batch_list_req->dblg_num_cnt)), dcla
          .updt_applctx = cnvtreal(currdbhandle), dcla.updt_cnt = 0,
          dcla.updt_dt_tm = sysdate, dcla.updt_id = reqinfo->updt_id, dcla.updt_task = reqinfo->
          updt_task,
          dcla.audit_dt_tm = sysdate
         WHERE dcla.dm_chg_log_audit_id=sx_next_seq
         WITH nocounter
        ;end update
        IF (check_error("Logging creation in dm_chg_log_audit") != 0)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         ROLLBACK
         RETURN("F")
        ELSE
         COMMIT
        ENDIF
        IF (curqual=0)
         INSERT  FROM dm_chg_log_audit dcla
          SET dcla.dm_chg_log_audit_id = sx_next_seq, dcla.log_id = 0, dcla.action = "CREATEXLAT",
           dcla.table_name = sx_tbl_list->qual[sx_val_loop].table_name, dcla.text = concat(
            "Backfill translations for sequence: ",sx_sequence_name,", table: ",sx_tbl_list->qual[
            sx_val_loop].table_name," batch: ",
            cnvtstring(sx_range_idx)," of ",cnvtstring(dm_batch_list_req->dblg_num_cnt)), dcla
           .updt_applctx = cnvtreal(currdbhandle),
           dcla.updt_cnt = 0, dcla.updt_dt_tm = sysdate, dcla.updt_id = reqinfo->updt_id,
           dcla.updt_task = reqinfo->updt_task, dcla.audit_dt_tm = sysdate
          WITH nocounter
         ;end insert
        ENDIF
        IF (check_error("Logging creation in dm_chg_log_audit") != 0)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         ROLLBACK
         RETURN("F")
        ELSE
         COMMIT
        ENDIF
        SET sx_continue_ind = 0
        WHILE (sx_continue_ind=0)
          SET sx_request->stmt[1].str = concat(
           " rdb asis(^insert /*+ CCL<DM_RMC_SEQMATCH_XLATS:S> */ ","into dm_merge_translate dmt ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,
           " ( dmt.from_value, dmt.table_name, dmt.env_source_id, dmt.env_target_id, dmt.to_value, ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,
           "  dmt.status_flg, dmt.updt_dt_tm ) ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,
           " (select from_value, table_name, env_source_id, env_target_id, to_value, ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,
           "  status_flg, updt_dt_tm from ( ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(" select ",
            sx_t_col_name," from_value , "))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("'",sx_tbl_list->qual[
            sx_val_loop].table_name,"'"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,build(" table_name , ",
            i_source_env_id," env_source_id, ",sx_target_id))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(" env_target_id, ",
            sx_t_col_name," to_value ,3 status_flg,sysdate updt_dt_tm "))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("   from ",sx_tbl_list
            ->qual[sx_val_loop].table_name," t "))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("    where ",
            sx_t_col_name," between ",sx_range_start," and ",
            sx_range_end))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("    and ",sx_filter,
            " = 1"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," union ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," select ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,
           " ti.parent_entity_id from_value,")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,
           " ti.parent_entity_name table_name,")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,build(i_source_env_id,
            " env_source_id,"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,build(sx_target_id,
            " env_target_id,"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,
           " ti.parent_entity_id to_value,")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," 3 status_flg,")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," sysdate updt_dt_tm")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,
           "  from dm_refchg_invalid_xlat ti ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            " where ti.parent_entity_name = '",sx_tbl_list->qual[sx_val_loop].table_name,"'"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            " and ti.parent_entity_id between ",sx_range_start," and ",sx_range_end))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," minus ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," select from_value, ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("'",sx_tbl_list->qual[
            sx_val_loop].table_name,"'"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,build(" , ",i_source_env_id,
            " , ",sx_target_id))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            " , from_value ,3,sysdate "))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,"  from dm_merge_translate")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            " where table_name  = '",sx_tbl_list->qual[sx_val_loop].table_name,"'"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and env_source_id = ",cnvtstring(i_source_env_id,20,2)))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and env_target_id = ",cnvtstring(sx_target_id,20,2)))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and from_value  between ",sx_range_start," and ",sx_range_end))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," minus ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," select to_value, ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("'",sx_tbl_list->qual[
            sx_val_loop].table_name,"'"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,build(" , ",i_source_env_id,
            " , ",sx_target_id))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            " , to_value ,3,sysdate "))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,"  from dm_merge_translate")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(" where table_name = '",
            sx_tbl_list->qual[sx_val_loop].table_name,"'"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and env_source_id = ",cnvtstring(i_source_env_id,20,2)))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and env_target_id = ",cnvtstring(sx_target_id,20,2)))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and to_value  between ",sx_range_start," and ",sx_range_end))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," minus ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," select from_value, ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("'",sx_tbl_list->qual[
            sx_val_loop].table_name,"'"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,build(" , ",i_source_env_id,
            " , ",sx_target_id))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            " , from_value ,3,sysdate "))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("  from ",sx_dmt_s))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(" where table_name = '",
            sx_tbl_list->qual[sx_val_loop].table_name,"'"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and env_source_id = ",cnvtstring(sx_target_id,20,2)))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and env_target_id = ",cnvtstring(i_source_env_id,20,2)))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and from_value  between ",sx_range_start," and ",sx_range_end))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," minus ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str," select to_value, ")
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("'",sx_tbl_list->qual[
            sx_val_loop].table_name,"'"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,build(" , ",i_source_env_id,
            " , ",sx_target_id))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            " , to_value ,3,sysdate "))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat("  from ",sx_dmt_s))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(" where table_name = '",
            sx_tbl_list->qual[sx_val_loop].table_name,"'"))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and env_source_id = ",cnvtstring(sx_target_id,20,2)))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and env_target_id = ",cnvtstring(i_source_env_id,20,2)))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(
            "   and to_value  between ",sx_range_start," and ",sx_range_end))
          SET sx_request->stmt[1].str = concat(sx_request->stmt[1].str,concat(" ) where rownum <= ",
            cnvtstring(sx_insert_limit),")^) go "))
          EXECUTE dm_rmc_seqmatch_xlats_child  WITH replace("REQUEST","SX_REQUEST"), replace("REPLY",
           "SX_REPLY")
          IF ((sx_reply->row_count < sx_insert_limit))
           SET sx_continue_ind = 1
          ENDIF
          IF (check_error("Inserting translations into dm_merge_translate") != 0)
           SET dm_err->err_ind = 1
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           ROLLBACK
           RETURN("F")
          ELSE
           COMMIT
          ENDIF
        ENDWHILE
      ENDFOR
    ENDFOR
   ENDIF
   IF (sx_sequence_name="REFERENCE_SEQ")
    SET sx_sec_ret = cs93_fix_done2(i_source_env_id,sx_t_id1,sx_target_id,sx_db_link,sx_seq_match_num
     )
    IF (sx_sec_ret="F")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=concat(trim(sx_seq_match_domain),"DONE2")
     AND di.info_name=sx_sequence_name
    WITH nocounter
   ;end select
   IF (check_error("Checking DONE2 sequence row") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF (curqual=0)
    UPDATE  FROM dm_info
     SET info_domain = concat(trim(sx_seq_match_domain),"DONE2"), updt_task = 4310001
     WHERE info_domain=sx_seq_match_domain
      AND info_name=sx_sequence_name
     WITH nocounter
    ;end update
    IF (check_error("Updating sequence row in dm_info") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ELSE
     INSERT  FROM dm_info di
      SET di.info_domain = sx_seq_match_domain, di.info_name = sx_sequence_name, di.info_number = 0,
       di.updt_task = reqinfo->updt_task, di.updt_id = reqinfo->updt_id, di.updt_cnt = 0,
       di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (check_error("Inserting 0 sequence row in dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     COMMIT
     SET sx_sec_ret = seqmatch_event_chk(i_source_env_id,sx_t_id1,sx_sequence_name)
     IF (sx_sec_ret="F")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     SET sx_asd2_ret = add_src_done_2(i_source_env_id,sx_t_id1,sx_target_id,sx_sequence_name)
     IF (sx_asd2_ret="F")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     RETURN("S")
    ENDIF
   ELSE
    UPDATE  FROM dm_info di
     SET di.info_number = 0
     WHERE di.info_domain=sx_seq_match_domain
      AND di.info_name=sx_sequence_name
     WITH nocounter
    ;end update
    IF (check_error("Updating sequence row in dm_info") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ELSE
     COMMIT
     SET sx_sec_ret = seqmatch_event_chk(i_source_env_id,sx_t_id1,sx_sequence_name)
     IF (sx_sec_ret="F")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     SET sx_asd2_ret = add_src_done_2(i_source_env_id,sx_t_id1,sx_target_id,sx_sequence_name)
     IF (sx_asd2_ret="F")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     RETURN("S")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE app_task_backfill(i_atb_source_env_id)
   DECLARE atb_target_id = f8
   DECLARE atb_cur_env_id = f8
   DECLARE atb_db_link = vc
   DECLARE atb_app_task_src = vc
   DECLARE atb_dmt_src = vc
   DECLARE atb_table_name = vc WITH constant("APPLICATION_TASK")
   DECLARE atb_insert_limit = i4 WITH constant(100000)
   DECLARE i_domain = vc
   DECLARE atb_next_seq = f8 WITH noconstant(0.0)
   DECLARE atb_app_task_col_cnt = i4 WITH noconstant(0)
   DECLARE atb_parser_cnt = i4 WITH noconstant(0)
   DECLARE atb_continue_ind = i2 WITH noconstant(1)
   DECLARE atb_sec_ret = vc WITH protect, noconstant("")
   DECLARE atb_asd2_ret = vc WITH protect, noconstant("")
   DECLARE atb_src_domain = vc WITH protect, noconstant("")
   DECLARE atb_seqmatch_domain = vc WITH protect, noconstant("")
   DECLARE atb_src_number = f8 WITH protect, noconstant(0.0)
   FREE RECORD atb_rs_parser
   RECORD atb_rs_parser(
     1 stmt[*]
       2 str = vc
   )
   FREE RECORD atb_rs_parser_reply
   RECORD atb_rs_parser_reply(
     1 row_count = i4
   )
   FREE RECORD atb_app_task_rs
   RECORD atb_app_task_rs(
     1 qual[*]
       2 notnull_ind = i4
       2 column_name = vc
   )
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="DM_ENV_ID"
    DETAIL
     atb_cur_env_id = di.info_number
    WITH nocounter
   ;end select
   IF (check_error("Obtaining target id") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   SET atb_db_link = build("@MERGE",cnvtstring(i_atb_source_env_id,20,0),cnvtstring(atb_cur_env_id,20,
     0))
   SET atb_app_task_src = concat("APPLICATION_TASK",atb_db_link)
   SET atb_dmt_src = concat("DM_MERGE_TRANSLATE",atb_db_link)
   SET atb_target_id = drmmi_get_mock_id(atb_cur_env_id)
   IF (atb_target_id < 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   SET i_domain = build("MERGE",cnvtstring(i_atb_source_env_id,20,0),cnvtstring(atb_target_id,20,0),
    "SEQMATCHDONE2")
   SET atb_src_domain = build("MERGE",cnvtstring(atb_target_id,20,0),cnvtstring(i_atb_source_env_id,
     20,0),"SEQMATCHDONE2")
   SET atb_seqmatch_domain = build("MERGE",cnvtstring(i_atb_source_env_id,20,0),cnvtstring(
     atb_target_id,20,0),"SEQMATCH")
   SELECT INTO "NL:"
    y = seq(dm_merge_audit_seq,nextval)
    FROM dual
    DETAIL
     atb_next_seq = y
    WITH nocounter
   ;end select
   IF (check_error("Popping a new value from DM_MERGE_AUDIT_SEQ") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   UPDATE  FROM dm_chg_log_audit dcla
    SET dcla.log_id = 0, dcla.action = "CREATEXLAT", dcla.table_name = atb_table_name,
     dcla.text = "Backfill translations in custom ranges for table APPLICATION_TASK", dcla
     .updt_applctx = cnvtreal(currdbhandle), dcla.updt_cnt = 0,
     dcla.updt_dt_tm = sysdate, dcla.updt_id = reqinfo->updt_id, dcla.updt_task = reqinfo->updt_task,
     dcla.audit_dt_tm = sysdate
    WHERE dcla.dm_chg_log_audit_id=atb_next_seq
    WITH nocounter
   ;end update
   IF (check_error("Inserting DM_CHG_LOG_AUDIT row for APPLICATION_TASK") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF (curqual=0)
    INSERT  FROM dm_chg_log_audit dcla
     SET dcla.dm_chg_log_audit_id = atb_next_seq, dcla.log_id = 0, dcla.action = "CREATEXLAT",
      dcla.table_name = atb_table_name, dcla.text =
      "Backfill translations in custom ranges for table APPLICATION_TASK", dcla.updt_applctx =
      cnvtreal(currdbhandle),
      dcla.updt_cnt = 0, dcla.updt_dt_tm = sysdate, dcla.updt_id = reqinfo->updt_id,
      dcla.updt_task = reqinfo->updt_task, dcla.audit_dt_tm = sysdate
     WITH nocounter
    ;end insert
    IF (check_error("Inserting DM_CHG_LOG_AUDIT row for APPLICATION_TASK") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=i_domain
     AND di.info_name=atb_table_name
    WITH nocounter
   ;end select
   IF (check_error("Checking if DONE2 row exists for APPLICATION_TASK") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ELSEIF (curqual=0)
    SELECT INTO "NL:"
     FROM user_tab_columns ut,
      (parser(concat("user_tab_columns",atb_db_link)) utc)
     PLAN (ut
      WHERE ut.table_name=atb_table_name)
      JOIN (utc
      WHERE utc.table_name=atb_table_name
       AND utc.column_name=ut.column_name)
     DETAIL
      atb_app_task_col_cnt = (atb_app_task_col_cnt+ 1), stat = alterlist(atb_app_task_rs->qual,
       atb_app_task_col_cnt), atb_app_task_rs->qual[atb_app_task_col_cnt].column_name = trim(ut
       .column_name,3),
      atb_app_task_rs->qual[atb_app_task_col_cnt].notnull_ind = 0
     WITH nocounter
    ;end select
    IF (check_error("Gathering apptask columns that exist in source and target") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    SELECT INTO "nl:"
     FROM dm2_user_notnull_cols unc,
      (dummyt dt  WITH seq = value(atb_app_task_col_cnt))
     PLAN (unc
      WHERE unc.table_name=atb_table_name)
      JOIN (dt
      WHERE (atb_app_task_rs->qual[dt.seq].column_name=unc.column_name))
     DETAIL
      atb_app_task_rs->qual[dt.seq].notnull_ind = 1
     WITH nocounter
    ;end select
    IF (check_error("Gathering not nullible columns on apptask") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    SELECT INTO "nl:"
     FROM (parser(concat("dm_info",atb_db_link)) di)
     WHERE di.info_domain=atb_src_domain
      AND di.info_name=atb_table_name
     DETAIL
      atb_src_number = di.info_number
     WITH nocounter
    ;end select
    IF (check_error("Obtaining sequence match value") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    IF (curqual > 0)
     INSERT  FROM dm_info di
      SET di.info_domain = i_domain, di.info_name = atb_table_name, di.updt_task = 4310001,
       di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.info_number = atb_src_number
      WITH nocounter
     ;end insert
     IF (check_error("Updating sequence row in dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     UPDATE  FROM dm_info di
      SET di.info_number = 0, di.updt_task = 4310001, di.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE di.info_domain=atb_seqmatch_domain
       AND di.info_name=atb_table_name
      WITH nocounter
     ;end update
     IF (check_error("Updating sequence row in dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     IF (curqual=0)
      INSERT  FROM dm_info di
       SET di.info_number = 0, di.updt_task = 4310001, di.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        di.info_domain = atb_seqmatch_domain, di.info_name = atb_table_name
       WITH nocounter
      ;end insert
      IF (check_error("Updating sequence row in dm_info") != 0)
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ENDIF
     ENDIF
     COMMIT
     SET sx_sec_ret = seqmatch_event_chk(i_atb_source_env_id,atb_cur_env_id,atb_table_name)
     IF (sx_sec_ret="F")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     RETURN("S")
    ENDIF
    SET stat = alterlist(atb_rs_parser->stmt,8)
    SET atb_rs_parser->stmt[1].str = " rdb insert into dm_merge_translate dmt"
    SET atb_rs_parser->stmt[2].str =
    " (dmt.from_value, dmt.table_name, dmt.env_source_id, dmt.env_target_id, dmt.to_value, "
    SET atb_rs_parser->stmt[3].str = "  dmt.status_flg, dmt.updt_dt_tm) "
    SET atb_rs_parser->stmt[4].str = build(' (select at.task_number, "',atb_table_name,'", ',
     i_atb_source_env_id,", ")
    SET atb_rs_parser->stmt[5].str = build(atb_target_id,", at.task_number, 3, sysdate")
    SET atb_rs_parser->stmt[6].str = concat("from application_task at, ",atb_app_task_src," ats")
    SET atb_rs_parser->stmt[7].str = "where ((at.task_number between 113000 and 113999) "
    SET atb_rs_parser->stmt[8].str = "or (at.task_number between 117000 and 118999)) and "
    SET atb_parser_cnt = 8
    FOR (i = 1 TO size(atb_app_task_rs->qual,5))
      SET atb_parser_cnt = (atb_parser_cnt+ 1)
      SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
      IF ((atb_app_task_rs->qual[i].notnull_ind=0))
       SET atb_rs_parser->stmt[atb_parser_cnt].str = concat("((at.",atb_app_task_rs->qual[i].
        column_name," = ats.",atb_app_task_rs->qual[i].column_name,")")
       SET atb_parser_cnt = (atb_parser_cnt+ 1)
       SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
       SET atb_rs_parser->stmt[atb_parser_cnt].str = concat(" or (at.",atb_app_task_rs->qual[i].
        column_name," is NULL and ats.",atb_app_task_rs->qual[i].column_name," is NULL))")
      ELSE
       SET atb_rs_parser->stmt[atb_parser_cnt].str = concat("at.",atb_app_task_rs->qual[i].
        column_name," = ats.",atb_app_task_rs->qual[i].column_name)
      ENDIF
      IF (i < size(atb_app_task_rs->qual,5))
       SET atb_rs_parser->stmt[atb_parser_cnt].str = concat(atb_rs_parser->stmt[atb_parser_cnt].str,
        " and ")
      ENDIF
    ENDFOR
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = "  minus "
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build('  select from_value, "',atb_table_name,'", ',
     i_atb_source_env_id,", ")
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build("    ",atb_target_id,
     ", from_value, 3, sysdate")
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = concat(
     'from dm_merge_translate where table_name = "',atb_table_name,'"')
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build(" and env_source_id = ",i_atb_source_env_id)
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build(" and env_target_id = ",atb_target_id)
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = concat(
     " and ((from_value >= 113000 and from_value <= 113999) ","or (from_value >= 117000 and ")
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = " from_value <= 118999))"
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = "  minus "
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build('  select to_value, "',atb_table_name,'", ',
     i_atb_source_env_id,", ")
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build("    ",atb_target_id,", to_value, 3, sysdate"
     )
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = concat(
     'from dm_merge_translate where table_name = "',atb_table_name,'"')
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build(" and env_source_id = ",i_atb_source_env_id)
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build(" and env_target_id = ",atb_target_id)
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str =
    " and ((to_value >= 113000 and to_value <= 113999) or (to_value >= 117000 and "
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = " to_value <= 118999))"
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = "  minus "
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build('  select from_value, "',atb_table_name,'", ',
     i_atb_source_env_id,", ")
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build("    ",atb_target_id,
     ", from_value, 3, sysdate")
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build("from dm_merge_translate",atb_db_link,
     ' where table_name = "',atb_table_name,'"')
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build(" and env_source_id = ",atb_target_id)
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build(" and env_target_id = ",i_atb_source_env_id)
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = concat(
     " and ((from_value >= 113000 and from_value <= 113999) ","or (from_value >= 117000 and ")
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = " from_value <= 118999))"
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = "  minus "
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build('  select to_value, "',atb_table_name,'", ',
     i_atb_source_env_id,", ")
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build("    ",atb_target_id,", to_value, 3, sysdate"
     )
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = concat("from dm_merge_translate",atb_db_link,
     ' where table_name = "',atb_table_name,'"')
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build(" and env_source_id = ",atb_target_id)
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = build(" and env_target_id = ",i_atb_source_env_id)
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str =
    " and ((to_value >= 113000 and to_value <= 113999) or (to_value >= 117000 and "
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = " to_value <= 118999))"
    SET atb_parser_cnt = (atb_parser_cnt+ 1)
    SET stat = alterlist(atb_rs_parser->stmt,atb_parser_cnt)
    SET atb_rs_parser->stmt[atb_parser_cnt].str = ") go"
    WHILE (atb_continue_ind=1)
      EXECUTE dm_rmc_seqmatch_xlats_child  WITH replace("REQUEST","ATB_RS_PARSER"), replace("REPLY",
       "ATB_RS_PARSER_REPLY")
      IF ((atb_rs_parser_reply->row_count < atb_insert_limit))
       SET atb_continue_ind = 0
      ELSE
       SET atb_continue_ind = 1
      ENDIF
      IF (check_error("Error during APPLICATION_TASK translation backfill") != 0)
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ENDIF
    ENDWHILE
    INSERT  FROM dm_info di
     SET di.info_domain = i_domain, di.info_name = "APPLICATION_TASK", di.info_number = 0,
      di.updt_task = 4310001, di.updt_id = reqinfo->updt_id, di.updt_cnt = 0,
      di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (check_error("app__task_backfill - Inserting 0 sequence row in dm_info") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ELSE
     COMMIT
     SET atb_sec_ret = seqmatch_event_chk(i_atb_source_env_id,atb_cur_env_id,"APPLICATION_TASK")
     IF (atb_sec_ret="F")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     SET atb_asd2_ret = add_src_done_2(i_atb_source_env_id,atb_cur_env_id,atb_target_id,
      "APPLICATION_TASK")
     IF (atb_asd2_ret="F")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     RETURN("S")
    ENDIF
   ELSEIF (curqual > 0)
    RETURN("S")
   ENDIF
 END ;Subroutine
 SUBROUTINE seqmatch_event_chk(i_source_id,i_target_id,i_sequence_name)
   DECLARE sec_link_name = vc WITH protect, noconstant("")
   DECLARE sec_done_ind = i2 WITH protect, noconstant(0)
   DECLARE sec_drel_row = f8 WITH protect, noconstant(0.0)
   DECLARE sec_drel_value = i4 WITH protect, noconstant(0)
   IF (validate(sec_lck_reply->status,"X")="X")
    FREE RECORD sec_lck_reply
    RECORD sec_lck_reply(
      1 status = c1
      1 status_msg = vc
    )
   ENDIF
   IF ((validate(sx_seq->cnt,- (9999)) != - (9999)))
    SET sec_drel_value = sx_seq->cnt
   ENDIF
   SET sec_lck_reply->status = "Z"
   SET sec_link_name = build(cnvtstring(i_source_id,20),cnvtstring(i_target_id,20))
   WHILE (sec_done_ind=0)
     SELECT INTO "nl:"
      FROM dm_rdds_event_log drel
      WHERE drel.rdds_event_key="TRANSLATIONBACKFILLFINISHED"
       AND drel.cur_environment_id=i_target_id
       AND drel.paired_environment_id=i_source_id
       AND  EXISTS (
      (SELECT
       "x"
       FROM dm_rdds_event_detail dred
       WHERE dred.dm_rdds_event_log_id=drel.dm_rdds_event_log_id
        AND dred.event_detail1_txt=i_sequence_name))
      DETAIL
       sec_drel_row = drel.dm_rdds_event_log_id
      WITH nocounter
     ;end select
     IF (check_error("Determining if Translation Backfill event row exists") != 0)
      RETURN("F")
     ENDIF
     IF (sec_drel_row=0)
      SELECT INTO "nl:"
       FROM dm_rdds_event_log drel
       WHERE drel.rdds_event_key="TRANSLATIONBACKFILLFINISHED"
        AND drel.cur_environment_id=i_target_id
        AND drel.paired_environment_id=i_source_id
       DETAIL
        sec_drel_row = drel.dm_rdds_event_log_id
       WITH nocounter, maxqual(drel,1)
      ;end select
      IF (check_error("Determining if Translation Backfill event row exists") != 0)
       RETURN("F")
      ENDIF
     ENDIF
     IF (sec_drel_row > 0)
      UPDATE  FROM dm_rdds_event_detail dred
       SET dred.updt_dt_tm = cnvtdatetime(curdate,curtime3)
       WHERE dred.dm_rdds_event_log_id=sec_drel_row
        AND dred.event_detail1_txt=i_sequence_name
       WITH nocounter
      ;end update
      IF (check_error("Attempting to update event detail row") != 0)
       RETURN("F")
      ENDIF
      IF (curqual=0)
       INSERT  FROM dm_rdds_event_detail dred
        SET dred.dm_rdds_event_detail_id = seq(dm_seq,nextval), dred.dm_rdds_event_log_id =
         sec_drel_row, dred.event_detail1_txt = i_sequence_name,
         dred.event_detail_value = 0.0, dred.updt_applctx = reqinfo->updt_applctx, dred.updt_cnt = 0,
         dred.updt_dt_tm = cnvtdatetime(curdate,curtime3), dred.updt_id = reqinfo->updt_id, dred
         .updt_task = 4310001
        WITH nocounter
       ;end insert
       IF (check_error("Attempting to insert new event detail row") != 0)
        RETURN("F")
       ENDIF
      ENDIF
      COMMIT
      SET sec_done_ind = 1
     ELSE
      CALL get_lock(concat("SEQMATCH_EVENT_",sec_link_name),"SEQMATCH EVENT LOG ROW",0,sec_lck_reply)
      IF ((sec_lck_reply->status="F"))
       SET dm_err->emsg = "Error while obtaining lock"
       RETURN("F")
      ELSEIF ((sec_lck_reply->status="S"))
       COMMIT
       SET stat = alterlist(auto_ver_request->qual,1)
       IF (sec_drel_value > 0)
        SET auto_ver_request->qual[1].event_reason = cnvtstring(sec_drel_value)
       ELSE
        SET auto_ver_request->qual[1].event_reason = ""
       ENDIF
       SET auto_ver_request->qual[1].rdds_event = "Translation Backfill Finished"
       SET auto_ver_request->qual[1].cur_environment_id = i_target_id
       SET auto_ver_request->qual[1].paired_environment_id = i_source_id
       SET stat = alterlist(auto_ver_request->qual[1].detail_qual,1)
       SET auto_ver_request->qual[1].detail_qual[1].event_detail1_txt = i_sequence_name
       SET auto_ver_request->qual[1].detail_qual[1].event_value = 0
       EXECUTE dm_rmc_auto_verify_setup
       IF ((auto_ver_reply->status="F"))
        SET dm_err->emsg = "Error while writing event row for Translation Backfill"
        CALL remove_lock(concat("SEQMATCH_EVENT_",sec_link_name),"SEQMATCH EVENT LOG ROW",
         currdbhandle,sec_lck_reply)
        IF ((sec_lck_reply->status="F"))
         SET dm_err->emsg = "Error while releasing lock"
        ENDIF
        RETURN("F")
       ENDIF
       CALL remove_lock(concat("SEQMATCH_EVENT_",sec_link_name),"SEQMATCH EVENT LOG ROW",currdbhandle,
        sec_lck_reply)
       IF ((sec_lck_reply->status="F"))
        SET dm_err->emsg = "Error while releasing lock"
        RETURN("F")
       ENDIF
       COMMIT
       SET sec_done_ind = 1
      ELSEIF ((sec_lck_reply->status="Z"))
       CALL pause(10)
      ENDIF
     ENDIF
   ENDWHILE
   RETURN("S")
 END ;Subroutine
 SUBROUTINE add_src_done_2(i_src_id,i_tgt_id,i_tgt_mock_id,i_sequence)
   DECLARE asd_merge_link = vc WITH protect, noconstant("")
   DECLARE asd_domain = vc WITH protect, noconstant("")
   DECLARE asd_sec_ret = vc WITH protect, noconstant("")
   DECLARE asd_targ_nbr = f8 WITH protect, noconstant(0.0)
   DECLARE asd_src_domain = vc WITH protect, noconstant("")
   SET asd_merge_link = build("@MERGE",cnvtstring(i_src_id,20,0),cnvtstring(i_tgt_id,20,0))
   SET asd_domain = build("MERGE",cnvtstring(i_tgt_mock_id,20,0),cnvtstring(i_src_id,20,0),"SEQMATCH"
    )
   SET asd_src_domain = build("MERGE",cnvtstring(i_src_id,20,0),cnvtstring(i_tgt_mock_id,20,0),
    "SEQMATCH")
   IF (i_tgt_id != i_tgt_mock_id)
    RETURN("S")
   ENDIF
   SELECT INTO "nl:"
    FROM (parser(concat("dm_info",asd_merge_link)) di)
    WHERE di.info_domain=concat(trim(asd_domain),"DONE2")
     AND info_name=i_sequence
    WITH nocounter
   ;end select
   IF (check_error("Obtaining done2 row from target") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF (curqual > 0)
    RETURN("S")
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain IN (asd_src_domain, concat(asd_src_domain,"DONE2"))
     AND di.info_name=i_sequence
    DETAIL
     IF (di.info_number > asd_targ_nbr)
      asd_targ_nbr = di.info_number
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error("Obtaining sequence match value from target") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   INSERT  FROM (parser(concat("dm_info",asd_merge_link)) di)
    SET di.info_domain = concat(trim(asd_domain),"DONE2"), di.info_number = asd_targ_nbr, di
     .updt_task = 4310001,
     di.info_name = i_sequence
    WITH nocounter
   ;end insert
   IF (check_error("Updating sequence row in dm_info") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   SELECT INTO "nl:"
    FROM (parser(concat("dm_info",asd_merge_link)) di)
    WHERE di.info_domain=asd_domain
     AND di.info_name=i_sequence
    WITH nocounter
   ;end select
   IF (check_error("Obtaining sequence match value") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF (curqual > 0)
    UPDATE  FROM (parser(concat("dm_info",asd_merge_link)) di)
     SET di.info_number = 0, di.updt_task = reqinfo->updt_task, di.updt_id = reqinfo->updt_id,
      di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->
      updt_applctx
     WHERE di.info_domain=asd_domain
      AND di.info_name=i_sequence
     WITH nocounter
    ;end update
    IF (check_error("Inserting 0 sequence row in dm_info") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
   ELSE
    INSERT  FROM (parser(concat("dm_info",asd_merge_link)) di)
     SET di.info_number = 0, di.updt_task = reqinfo->updt_task, di.updt_id = reqinfo->updt_id,
      di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->
      updt_applctx,
      di.info_domain = asd_domain, di.info_name = i_sequence
     WITH nocounter
    ;end insert
    IF (check_error("Inserting 0 sequence row in dm_info") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
   ENDIF
   COMMIT
   SET asd_sec_ret = seqmatch_event_chk(i_tgt_id,i_src_id,i_sequence)
   IF (asd_sec_ret="F")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE cs93_xlat_backfill(cxb_source_id)
   DECLARE cxb_target_id = f8 WITH protect, noconstant(0.0)
   DECLARE cxb_cur_env_id = f8 WITH protect, noconstant(0.0)
   DECLARE cxb_db_link = vc WITH protect, noconstant(" ")
   DECLARE cxb_cv_src = vc WITH protect, noconstant(" ")
   DECLARE cxb_dmt_src = vc WITH protect, noconstant(" ")
   DECLARE cxb_table_name = vc WITH protect, constant("CODE_VALUE")
   DECLARE cxb_domain = vc WITH protect, noconstant(" ")
   DECLARE cxb_info_name = vc WITH protect, constant("CODESET93")
   DECLARE cxb_next_seq = f8 WITH protect, noconstant(0.0)
   DECLARE cxb_sec_ret = vc WITH protect, noconstant("")
   DECLARE cxb_src_domain = vc WITH protect, noconstant("")
   DECLARE cxb_seqmatch_domain = vc WITH protect, noconstant("")
   DECLARE cxb_src_number = f8 WITH protect, noconstant(0.0)
   DECLARE cxb_seqmatch_val = f8 WITH protect, noconstant(0.0)
   DECLARE cxb_done2_src_val = f8 WITH protect, noconstant(0.0)
   DECLARE cxb_row_cnt = f8 WITH protect, noconstant(0.0)
   DECLARE cxb_batch = i4 WITH protect, noconstant(0)
   DECLARE cxb_loop = i4 WITH protect, noconstant(0)
   DECLARE cxb_batch_limit = f8 WITH protect, noconstant(0.0)
   FREE RECORD cxb_rs_parser
   RECORD cxb_rs_parser(
     1 stmt[*]
       2 str = vc
   )
   FREE RECORD cxb_rs_parser_reply
   RECORD cxb_rs_parser_reply(
     1 row_count = i4
   )
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="DM_ENV_ID"
    DETAIL
     cxb_cur_env_id = di.info_number
    WITH nocounter
   ;end select
   IF (check_error("Obtaining target id") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   SET cxb_db_link = build("@MERGE",cnvtstring(cxb_source_id,20),cnvtstring(cxb_cur_env_id,20))
   SET cxb_cv_src = concat("CODE_VALUE",cxb_db_link)
   SET cxb_dmt_src = concat("DM_MERGE_TRANSLATE",cxb_db_link)
   SET cxb_target_id = drmmi_get_mock_id(cxb_cur_env_id)
   IF (cxb_target_id < 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   SET cxb_domain = build("MERGE",cnvtstring(cxb_source_id),cnvtstring(cxb_target_id),"SEQMATCHDONE2"
    )
   SET cxb_src_domain = build("MERGE",cnvtstring(cxb_target_id),cnvtstring(cxb_source_id),
    "SEQMATCHDONE2")
   SET cxb_seqmatch_domain = build("MERGE",cnvtstring(cxb_source_id),cnvtstring(cxb_target_id),
    "SEQMATCH")
   SELECT INTO "NL:"
    FROM (parser(concat("dm_info",cxb_db_link)) di)
    WHERE di.info_name="REFERENCE_SEQ"
     AND di.info_domain=cxb_src_domain
    DETAIL
     cxb_done2_src_val = di.info_number
    WITH nocounter
   ;end select
   IF (check_error("Querying for remote REFERENCE_SEQ DONE2 row")=1)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   SELECT INTO "NL:"
    y = seq(dm_merge_audit_seq,nextval)
    FROM dual
    DETAIL
     cxb_next_seq = y
    WITH nocounter
   ;end select
   IF (check_error("Popping a new value from DM_MERGE_AUDIT_SEQ") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   UPDATE  FROM dm_chg_log_audit dcla
    SET dcla.log_id = 0, dcla.action = "CREATEXLAT", dcla.table_name = cxb_table_name,
     dcla.text = "Backfill translations in CODE_SET 93 for table CODE_VALUE", dcla.updt_applctx =
     cnvtreal(currdbhandle), dcla.updt_cnt = 0,
     dcla.updt_dt_tm = sysdate, dcla.updt_id = reqinfo->updt_id, dcla.updt_task = reqinfo->updt_task,
     dcla.audit_dt_tm = sysdate
    WHERE dcla.dm_chg_log_audit_id=cxb_next_seq
    WITH nocounter
   ;end update
   IF (check_error("Updating DM_CHG_LOG_AUDIT row for CODE_VALUE") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF (curqual=0)
    INSERT  FROM dm_chg_log_audit dcla
     SET dcla.dm_chg_log_audit_id = cxb_next_seq, dcla.log_id = 0, dcla.action = "CREATEXLAT",
      dcla.table_name = cxb_table_name, dcla.text =
      "Backfill translations in CODE_SET 93 for table CODE_VALUE", dcla.updt_applctx = cnvtreal(
       currdbhandle),
      dcla.updt_cnt = 0, dcla.updt_dt_tm = sysdate, dcla.updt_id = reqinfo->updt_id,
      dcla.updt_task = reqinfo->updt_task, dcla.audit_dt_tm = sysdate
     WITH nocounter
    ;end insert
    IF (check_error("Inserting DM_CHG_LOG_AUDIT row for CODE_VALUE") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=cxb_domain
     AND di.info_name=cxb_info_name
    WITH nocounter
   ;end select
   IF (check_error("Checking if DONE2 row exists for CODE_SET 93") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ELSEIF (curqual=0)
    SELECT INTO "nl:"
     FROM (parser(concat("dm_info",cxb_db_link)) di)
     WHERE di.info_domain=cxb_src_domain
      AND di.info_name=cxb_info_name
     DETAIL
      cxb_src_number = di.info_number
     WITH nocounter
    ;end select
    IF (check_error("Querying for remote CODESET93 DONE2 row") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    IF (curqual > 0)
     SET cxb_sec_ret = cs93_fix_done2(cxb_source_id,cxb_cur_env_id,cxb_target_id,cxb_db_link,
      cxb_src_number)
     IF (cxb_sec_ret="F")
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     COMMIT
     RETURN("S")
    ENDIF
    SELECT INTO "NL:"
     FROM dm_info di
     WHERE di.info_domain=cxb_seqmatch_domain
      AND di.info_name=cxb_info_name
     DETAIL
      cxb_seqmatch_val = di.info_number
     WITH nocounter
    ;end select
    IF (check_error("Querying for local CODESET93 SEQMATCH") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    IF (cxb_done2_src_val > cxb_seqmatch_val)
     SET cxb_seqmatch_val = cxb_done2_src_val
     UPDATE  FROM dm_info d
      SET info_number = cxb_seqmatch_val
      WHERE info_domain=cxb_seqmatch_domain
       AND info_name=cxb_info_name
      WITH nocounter
     ;end update
     IF (check_error("Updating local CODESET93 SEQMATCH to be correct") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     cnt = count(*)
     FROM code_value c
     WHERE c.code_set=93
      AND c.code_value <= cxb_seqmatch_val
     DETAIL
      cxb_row_cnt = cnt
     WITH nocounter
    ;end select
    IF (check_error("Gathering count of CODESET93 to use for NTILE")=1)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    SELECT INTO "nl:"
     cnt = count(*)
     FROM dm_refchg_invalid_xlat t1
     WHERE t1.parent_entity_name="CODE_VALUE"
      AND t1.parent_entity_id <= cxb_seqmatch_val
     DETAIL
      cxb_row_cnt = (cxb_row_cnt+ cnt)
     WITH nocounter
    ;end select
    IF (check_error("Gathering count of CODESET93 to use for NTILE")=1)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="RDDS CONFIGURATION"
      AND di.info_name="RXLAT_BELOW_SEQ_FILL"
     DETAIL
      cxb_batch_limit = di.info_number
     WITH nocounter
    ;end select
    IF (check_error("Querying for backfill batch size") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    IF (curqual=0)
     SET cxb_batch_limit = 50000.0
    ENDIF
    SET cxb_batch = ceil((cxb_row_cnt/ cxb_batch_limit))
    SET cxb_row_cnt = 1.0
    IF (cxb_batch > 1)
     DELETE  FROM dm_info d
      WHERE info_domain="CODESET93"
       AND info_name=patstring("CODESET93*")
      WITH nocounter
     ;end delete
     IF (check_error("Removing CODSET93 Ntile rows from DM_INFO")=1)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     CALL parser("rdb asis(^ insert into dm_info (info_domain, info_name, info_number) ^)",0)
     CALL parser("asis(^(select 'CODSET93','CODESET93'||to_char(bin,'FM00000'), max(code_value)^)",0)
     CALL parser(concat("asis(^ from (select code_value, ntile(",trim(cnvtstring(cxb_batch)),
       ") over (order by code_value) bin ^)"),0)
     CALL parser(concat(
       "asis(^ from (select code_value from code_value where code_set = 93 and code_value < ",trim(
        cnvtstring(cxb_seqmatch_val,20,1)),"^)"),0)
     CALL parser(
      "asis(^ union select t1.parent_entity_id code_value from dm_refchg_invalid_xlat t1 ^)",0)
     CALL parser(concat(
       "asis(^ where t1.parent_entity_name = 'CODE_VALUE' and t1.parent_entity_id < ",trim(cnvtstring
        (cxb_seqmatch_val,20,1)),"^)"),0)
     CALL parser("asis (^ order by code_value) group by bin) ^) go",1)
     IF (check_error("Performing NTILE statement for CODESET93")=1)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
     SET cxb_batch = 0
     SELECT INTO "NL:"
      FROM dm_info d
      WHERE d.info_domain="CODESET93"
       AND info_name=patstring("CODESET93*")
      ORDER BY d.info_number
      DETAIL
       cxb_batch = (cxb_batch+ 1), stat = alterlist(dm_batch_list_rep->list,cxb_batch),
       dm_batch_list_rep->list[cxb_batch].batch_num = cxb_batch,
       dm_batch_list_rep->list[cxb_batch].max_value = cnvtstring(d.info_number,20,1)
      WITH nocounter
     ;end select
     IF (check_error("Querying CODESET93 NTILE data in DM_INFO")=1)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
    ELSE
     SET cxb_batch = 1
     SET stat = alterlist(dm_batch_list_rep->list,1)
     SET dm_batch_list_rep->list[1].batch_num = 1
     SET dm_batch_list_rep->list[1].max_value = cnvtstring(cxb_seqmatch_val,20,1)
    ENDIF
    SET stat = alterlist(cxb_rs_parser->stmt,40)
    FOR (cxb_loop = 1 TO cxb_batch)
      SET cxb_rs_parser->stmt[1].str = " rdb insert into dm_merge_translate dmt"
      SET cxb_rs_parser->stmt[2].str =
      " (dmt.from_value, dmt.table_name, dmt.env_source_id, dmt.env_target_id, dmt.to_value, "
      SET cxb_rs_parser->stmt[3].str = "  dmt.status_flg, dmt.updt_dt_tm) "
      SET cxb_rs_parser->stmt[4].str = build(' (select cv.code_value, "',cxb_table_name,'", ',
       cxb_source_id,", ")
      SET cxb_rs_parser->stmt[5].str = build(cxb_target_id,", cv.code_value, 3, sysdate")
      SET cxb_rs_parser->stmt[6].str = concat("from code_value cv")
      SET cxb_rs_parser->stmt[7].str = concat("where cv.code_set = 93 and cv.code_value between ",
       trim(cnvtstring(cxb_row_cnt,20,2))," and ",dm_batch_list_rep->list[cxb_loop].max_value)
      SET cxb_rs_parser->stmt[8].str =
      " union select ti.parent_entity_id from_value, ti.parent_entity_name table_name, "
      SET cxb_rs_parser->stmt[9].str = concat(trim(cnvtstring(cxb_source_id,20,2))," env_source_id, ",
       trim(cnvtstring(cxb_target_id,20,2))," env_target_id, ")
      SET cxb_rs_parser->stmt[10].str =
      "ti.parent_entity_id to_value, 3 status_flg, sysdate updt_dt_tm "
      SET cxb_rs_parser->stmt[11].str = concat(
       'from dm_refchg_invalid_xlat ti where ti.parent_entity_name = "',cxb_table_name,
       '" and ti.parent_entity_id between ',trim(cnvtstring(cxb_row_cnt,20,2))," and ",
       dm_batch_list_rep->list[cxb_loop].max_value)
      SET cxb_rs_parser->stmt[16].str = "  minus "
      SET cxb_rs_parser->stmt[17].str = build('  select from_value, "',cxb_table_name,'", ',
       cxb_source_id,", ")
      SET cxb_rs_parser->stmt[18].str = build("    ",cxb_target_id,", from_value, 3, sysdate")
      SET cxb_rs_parser->stmt[19].str = concat('from dm_merge_translate where table_name = "',
       cxb_table_name,'"')
      SET cxb_rs_parser->stmt[20].str = build(" and env_source_id = ",cxb_source_id)
      SET cxb_rs_parser->stmt[21].str = concat(" and env_target_id = ",trim(cnvtstring(cxb_target_id,
         20,2))," and from_value between ",trim(cnvtstring(cxb_row_cnt,20,2))," and ",
       dm_batch_list_rep->list[cxb_loop].max_value)
      SET cxb_rs_parser->stmt[22].str = "  minus "
      SET cxb_rs_parser->stmt[23].str = build('  select to_value, "',cxb_table_name,'", ',
       cxb_source_id,", ")
      SET cxb_rs_parser->stmt[24].str = build("    ",cxb_target_id,", to_value, 3, sysdate")
      SET cxb_rs_parser->stmt[25].str = concat('from dm_merge_translate where table_name = "',
       cxb_table_name,'"')
      SET cxb_rs_parser->stmt[26].str = build(" and env_source_id = ",cxb_source_id)
      SET cxb_rs_parser->stmt[27].str = concat(" and env_target_id = ",trim(cnvtstring(cxb_target_id,
         20,2))," and to_value between ",trim(cnvtstring(cxb_row_cnt,20,2))," and ",
       dm_batch_list_rep->list[cxb_loop].max_value)
      SET cxb_rs_parser->stmt[28].str = "  minus "
      SET cxb_rs_parser->stmt[29].str = build('  select from_value, "',cxb_table_name,'", ',
       cxb_source_id,", ")
      SET cxb_rs_parser->stmt[30].str = build("    ",cxb_target_id,", from_value, 3, sysdate")
      SET cxb_rs_parser->stmt[31].str = build("from dm_merge_translate",cxb_db_link,
       ' where table_name = "',cxb_table_name,'"')
      SET cxb_rs_parser->stmt[32].str = build(" and env_source_id = ",cxb_target_id)
      SET cxb_rs_parser->stmt[33].str = concat(" and env_target_id = ",trim(cnvtstring(cxb_source_id,
         20,2))," and from_value between ",trim(cnvtstring(cxb_row_cnt,20,2))," and ",
       dm_batch_list_rep->list[cxb_loop].max_value)
      SET cxb_rs_parser->stmt[34].str = "  minus "
      SET cxb_rs_parser->stmt[35].str = build('  select to_value, "',cxb_table_name,'", ',
       cxb_source_id,", ")
      SET cxb_rs_parser->stmt[36].str = build("    ",cxb_target_id,", to_value, 3, sysdate")
      SET cxb_rs_parser->stmt[37].str = concat("from dm_merge_translate",cxb_db_link,
       ' where table_name = "',cxb_table_name,'"')
      SET cxb_rs_parser->stmt[38].str = build(" and env_source_id = ",cxb_target_id)
      SET cxb_rs_parser->stmt[39].str = concat(" and env_target_id = ",trim(cnvtstring(cxb_source_id,
         20,2))," and to_value between ",trim(cnvtstring(cxb_row_cnt,20,2))," and ",
       dm_batch_list_rep->list[cxb_loop].max_value)
      SET cxb_rs_parser->stmt[40].str = ") go"
      EXECUTE dm_rmc_seqmatch_xlats_child  WITH replace("REQUEST","CXB_RS_PARSER"), replace("REPLY",
       "CXB_RS_PARSER_REPLY")
      IF (check_error("Error during CODESET 93 translation backfill") != 0)
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ENDIF
      SET cxb_row_cnt = cnvtreal(dm_batch_list_rep->list[cxb_loop].max_value)
    ENDFOR
    SET cxb_sec_ret = cs93_fix_done2(cxb_source_id,cxb_cur_env_id,cxb_target_id,cxb_db_link,
     cxb_seqmatch_val)
    IF (cxb_sec_ret="F")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    COMMIT
    RETURN("S")
   ELSEIF (curqual > 0)
    COMMIT
    RETURN("S")
   ENDIF
 END ;Subroutine
 SUBROUTINE cs93_fix_done2(cfd_source_id,cfd_target_id,cfd_mock_id,cfd_db_link,cfd_seqmatch_value)
   DECLARE cfd_target_seqmatch = vc WITH protect, noconstant("")
   DECLARE cfd_target_done2 = vc WITH protect, noconstant("")
   DECLARE cfd_source_seqmatch = vc WITH protect, noconstant("")
   DECLARE cfd_source_done2 = vc WITH protect, noconstant("")
   DECLARE cfd_info_name = vc WITH protect, constant("CODESET93")
   DECLARE cfd_value = f8 WITH protect, noconstant(0.0)
   SET cfd_target_seqmatch = concat("MERGE",trim(cnvtstring(cfd_source_id,20)),trim(cnvtstring(
      cfd_mock_id,20)),"SEQMATCH")
   SET cfd_target_done2 = concat(cfd_target_seqmatch,"DONE2")
   SET cfd_source_seqmatch = concat("MERGE",trim(cnvtstring(cfd_mock_id,20)),trim(cnvtstring(
      cfd_source_id,20)),"SEQMATCH")
   SET cfd_source_done2 = concat(cfd_source_seqmatch,"DONE2")
   SELECT INTO "NL:"
    FROM dm_info di
    WHERE di.info_domain=cfd_target_seqmatch
     AND di.info_name=cfd_info_name
    DETAIL
     cfd_value = di.info_number
    WITH nocounter
   ;end select
   IF (check_error("Querying sequence row in dm_info") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_domain = cfd_target_seqmatch, di.info_name = cfd_info_name, di.info_number = 0.0,
      di.updt_task = 4310001, di.updt_id = reqinfo->updt_id, di.updt_cnt = 0,
      di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (check_error("Inserting sequence row in dm_info") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
   ELSEIF (cfd_value > 0.0)
    UPDATE  FROM dm_info di
     SET info_number = 0.0, di.updt_task = 4310001, di.updt_id = reqinfo->updt_id,
      di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->
      updt_applctx
     WHERE di.info_domain=cfd_target_seqmatch
      AND di.info_name=cfd_info_name
     WITH nocounter
    ;end update
    IF (check_error("Updating sequence row in dm_info") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
   ENDIF
   SET cfd_value = 0.0
   SELECT INTO "NL:"
    FROM dm_info di
    WHERE di.info_domain=cfd_target_done2
     AND di.info_name=cfd_info_name
    DETAIL
     cfd_value = di.info_number
    WITH nocounter
   ;end select
   IF (check_error("Querying DONE2 row in dm_info") != 0)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_domain = cfd_target_done2, di.info_name = cfd_info_name, di.info_number =
      cfd_seqmatch_value,
      di.updt_task = 4310001, di.updt_id = reqinfo->updt_id, di.updt_cnt = 0,
      di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (check_error("Inserting done2 row in dm_info") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
   ELSEIF (cfd_value != cfd_seqmatch_value)
    UPDATE  FROM dm_info di
     SET info_number = cfd_seqmatch_value, di.updt_task = 4310001, di.updt_id = reqinfo->updt_id,
      di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->
      updt_applctx
     WHERE di.info_domain=cfd_target_done2
      AND di.info_name=cfd_info_name
     WITH nocounter
    ;end update
    IF (check_error("Updating done2 row in dm_info") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
   ENDIF
   IF (cfd_target_id=cfd_mock_id)
    SET cfd_value = 0.0
    SELECT INTO "NL:"
     FROM (parser(concat("dm_Info",cfd_db_link)) di)
     WHERE di.info_domain=cfd_source_seqmatch
      AND di.info_name=cfd_info_name
     DETAIL
      cfd_value = di.info_number
     WITH nocounter
    ;end select
    IF (check_error("Querying sequence row in remote dm_info") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    IF (curqual=0)
     INSERT  FROM (parser(concat("dm_Info",cfd_db_link)) di)
      SET di.info_domain = cfd_source_seqmatch, di.info_name = cfd_info_name, di.info_number = 0.0,
       di.updt_task = 4310001, di.updt_id = reqinfo->updt_id, di.updt_cnt = 0,
       di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (check_error("Inserting sequence row in remote dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
    ELSEIF (cfd_value > 0.0)
     UPDATE  FROM (parser(concat("dm_Info",cfd_db_link)) di)
      SET info_number = 0.0, di.updt_task = 4310001, di.updt_id = reqinfo->updt_id,
       di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->
       updt_applctx
      WHERE di.info_domain=cfd_source_seqmatch
       AND di.info_name=cfd_info_name
      WITH nocounter
     ;end update
     IF (check_error("Updating sequence row in remote dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
    ENDIF
    SET cfd_value = 0.0
    SELECT INTO "NL:"
     FROM (parser(concat("dm_Info",cfd_db_link)) di)
     WHERE di.info_domain=cfd_source_done2
      AND di.info_name=cfd_info_name
     DETAIL
      cfd_value = di.info_number
     WITH nocounter
    ;end select
    IF (check_error("Querying done2 row in remote dm_info") != 0)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
    IF (curqual=0)
     INSERT  FROM (parser(concat("dm_Info",cfd_db_link)) di)
      SET di.info_domain = cfd_source_done2, di.info_name = cfd_info_name, di.info_number =
       cfd_seqmatch_value,
       di.updt_task = 4310001, di.updt_id = reqinfo->updt_id, di.updt_cnt = 0,
       di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (check_error("Inserting done2 row in remote dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
    ELSEIF (cfd_value != cfd_seqmatch_value)
     UPDATE  FROM (parser(concat("dm_Info",cfd_db_link)) di)
      SET info_number = cfd_seqmatch_value, di.updt_task = 4310001, di.updt_id = reqinfo->updt_id,
       di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->
       updt_applctx
      WHERE di.info_domain=cfd_source_done2
       AND di.info_name=cfd_info_name
      WITH nocounter
     ;end update
     IF (check_error("Updating done2 row in remote dm_info") != 0)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN("F")
     ENDIF
    ENDIF
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE cs93_create_seqmatch(ccs_rec)
   DECLARE ccs_loop = i4 WITH protect, noconstant(0)
   SELECT INTO "NL:"
    FROM dm_info d
    WHERE d.info_domain="DATA MANAGEMENT"
     AND d.info_name="DM_ENV_ID"
    DETAIL
     ccs_rec->env_id = d.info_number
    WITH nocounter
   ;end select
   IF (check_error("Querying for local environment id")=1)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   SET ccs_rec->mock_id = drmmi_get_mock_id(ccs_rec->env_id)
   IF (check_error("Obtaining MOCK_ID")=1)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   SELECT INTO "NL:"
    FROM dm_env_reltn d
    WHERE (d.child_env_id=ccs_rec->env_id)
     AND d.relationship_type="REFERENCE MERGE"
     AND d.post_link_name > " "
    DETAIL
     ccs_rec->env_cnt = (ccs_rec->env_cnt+ 1), stat = alterlist(ccs_rec->env_qual,ccs_rec->env_cnt),
     ccs_rec->env_qual[ccs_rec->env_cnt].parent_env_id = d.parent_env_id,
     ccs_rec->env_qual[ccs_rec->env_cnt].db_link = d.post_link_name, ccs_rec->env_qual[ccs_rec->
     env_cnt].done2_name = concat("MERGE",trim(cnvtstring(d.parent_env_id,20)),trim(cnvtstring(
        ccs_rec->mock_id,20)),"SEQMATCHDONE2")
    WITH nocounter
   ;end select
   IF (check_error("Looking for all parent relationships")=1)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN("F")
   ENDIF
   IF ((ccs_rec->env_cnt > 0))
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = ccs_rec->env_cnt),
      dm_info di
     PLAN (d)
      JOIN (di
      WHERE di.info_name="REFERENCE_SEQ"
       AND (di.info_domain=ccs_rec->env_qual[d.seq].done2_name))
     DETAIL
      ccs_rec->env_qual[d.seq].done2_value = di.info_number, ccs_rec->env_qual[d.seq].done2_exist_ind
       = 1, ccs_rec->ref_seq_cnt = (ccs_rec->ref_seq_cnt+ 1)
     WITH nocounter
    ;end select
    IF (check_error("Looking for REFERENCE_SEQ DONE2 rows")=1)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN("F")
    ENDIF
   ENDIF
   FOR (ccs_loop = 1 TO ccs_rec->env_cnt)
     IF ((ccs_rec->env_qual[ccs_loop].done2_exist_ind=1))
      SELECT INTO "NL:"
       FROM dm_info di
       WHERE di.info_domain=concat("MERGE",trim(cnvtstring(ccs_rec->env_qual[ccs_loop].parent_env_id,
          20)),trim(cnvtstring(ccs_rec->mock_id,20)),"SEQMATCH")
        AND di.info_name="CODESET93"
       WITH nocounter
      ;end select
      IF (check_error("Querying for CODESET93 SEQMATCH row")=1)
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN("F")
      ENDIF
      IF (curqual=0)
       INSERT  FROM dm_info di
        SET di.info_domain = concat("MERGE",trim(cnvtstring(ccs_rec->env_qual[ccs_loop].parent_env_id,
            20)),trim(cnvtstring(ccs_rec->mock_id,20)),"SEQMATCH"), di.info_name = "CODESET93", di
         .info_number = ccs_rec->env_qual[ccs_loop].done2_value,
         di.updt_task = reqinfo->updt_task, di.updt_id = reqinfo->updt_id, di.updt_cnt = 0,
         di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = reqinfo->updt_applctx
        WITH nocounter
       ;end insert
       IF (check_error("Inserting CODESET93 SEQMATCH row")=1)
        SET dm_err->err_ind = 1
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        ROLLBACK
        RETURN("F")
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   COMMIT
   RETURN("S")
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
 DECLARE drmm_get_col_string(sbr_pk_where=vc,sbr_log_id=f8,sbr_tbl_name=vc,sbr_tbl_suffix=vc,
  sbr_db_link=vc) = i4
 DECLARE drmm_get_ptam_match_query(sbr_log_id=f8,sbr_tab_name=vc,sbr_tab_suffix=vc,sbr_db_link=vc) =
 null
 DECLARE drmm_get_ptam_match_result(sbr_log_id=f8,sbr_src_env_id=f8,sbr_tgt_env_id=f8,sbr_db_link=vc,
  sbr_local_ind=i2,
  sbr_trans_type=vc) = f8
 DECLARE drmm_get_pk_where(sbr_tab_name=vc,sbr_tab_suffix=vc,sbr_delete_ind=i2,sbr_db_link=vc) = vc
 DECLARE drmm_get_exploded_pkw(sbr_tab_name=vc,sbr_tab_suffix=vc,sbr_db_link=vc) = vc
 DECLARE drmm_get_func_name(sbr_prefix=vc,sbr_db_link=vc) = vc
 DECLARE drmm_get_cust_col_string(sbr_pk_where=vc,sbr_tbl_name=vc,sbr_col_name=vc,sbr_tbl_suffix=vc,
  sbr_db_link=vc) = i4
 IF ( NOT (validate(col_string_parm,0)))
  FREE RECORD col_string_parm
  RECORD col_string_parm(
    1 total = i4
    1 qual[*]
      2 table_name = vc
      2 col_qual[*]
        3 column_name = vc
        3 in_src_ind = i2
  ) WITH protect
 ENDIF
 SUBROUTINE drmm_get_col_string(sbr_pk_where,sbr_log_id,sbr_tbl_name,sbr_tbl_suffix,sbr_db_link)
   DECLARE dgcs_tab_name = vc WITH protect, noconstant("")
   DECLARE dgcs_tab_suffix = vc WITH protect, noconstant("")
   DECLARE dgcs_src_tab_name = vc WITH protect, noconstant("")
   DECLARE dgcs_col_pos = i4 WITH protect, noconstant(0)
   DECLARE dgcs_num = i4 WITH protect, noconstant(0)
   DECLARE dgcs_func_prefix = vc WITH protect, noconstant("")
   DECLARE dgcs_func_name = vc WITH protect, noconstant("")
   DECLARE dgcs_loop = i4 WITH protect, noconstant(0)
   DECLARE dgcs_dcl_tab_name = vc WITH protect, noconstant("")
   DECLARE dgcs_db_link = vc WITH protect, noconstant(" ")
   DECLARE dgcs_stmt_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgcs_stmt_idx = i4 WITH protect, noconstant(0)
   DECLARE dgcs_qual_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgcs_col_loop = i4 WITH protect, noconstant(0)
   DECLARE dgcs_utc_name = vc WITH protect, noconstant("")
   DECLARE dgcs_pos = i4 WITH protect, noconstant(0)
   DECLARE dgcs_miss_ind = i2 WITH protect, noconstant(0)
   IF ( NOT (validate(parse_rs,0)))
    FREE RECORD parse_rs
    RECORD parse_rs(
      1 stmt[*]
        2 str = vc
    ) WITH protect
   ENDIF
   DECLARE dm2_context_control_wrapper() = i2
   IF (sbr_db_link > " ")
    SET dgcs_db_link = sbr_db_link
   ENDIF
   IF (sbr_log_id > 0.0)
    SET dgcs_dcl_tab_name = concat("DM_CHG_LOG",dgcs_db_link)
    SELECT INTO "nl:"
     dm2_context_control_wrapper("RDDS_COL_STRING",d.col_string)
     FROM (parser(dgcs_dcl_tab_name) d)
     WHERE d.log_id=sbr_log_id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(- (1))
    ENDIF
   ELSE
    SET dgcs_tab_name = sbr_tbl_name
    SET dgcs_tab_suffix = sbr_tbl_suffix
    SET dgcs_col_pos = locateval(dgcs_num,1,col_string_parm->total,dgcs_tab_name,col_string_parm->
     qual[dgcs_num].table_name)
    IF (dgcs_col_pos=0)
     SET dgcs_col_pos = (col_string_parm->total+ 1)
     SET stat = alterlist(col_string_parm->qual,dgcs_col_pos)
     SET col_string_parm->total = dgcs_col_pos
     SET col_string_parm->qual[dgcs_col_pos].table_name = dgcs_tab_name
     SELECT INTO "nl:"
      FROM dm_colstring_parm d
      WHERE d.table_name=dgcs_tab_name
      ORDER BY d.parm_nbr
      HEAD REPORT
       parm_cnt = 0
      DETAIL
       parm_cnt = (parm_cnt+ 1), stat = alterlist(col_string_parm->qual[dgcs_col_pos].col_qual,
        parm_cnt), col_string_parm->qual[dgcs_col_pos].col_qual[parm_cnt].column_name = d.column_name
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(- (1))
     ENDIF
    ENDIF
    IF (dgcs_db_link > "")
     FOR (dgcs_col_loop = 1 TO size(col_string_parm->qual[dgcs_col_pos].col_qual,5))
       SET col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_col_loop].in_src_ind = 0
     ENDFOR
     SET dgcs_utc_name = concat("USER_TAB_COLUMNS",dgcs_db_link)
     SELECT INTO "nl:"
      FROM (parser(dgcs_utc_name) utc)
      WHERE (utc.table_name=col_string_parm->qual[dgcs_col_pos].table_name)
       AND expand(dgcs_num,1,size(col_string_parm->qual[dgcs_col_pos].col_qual,5),utc.column_name,
       col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_num].column_name)
       AND  NOT (column_name IN ("KEY1", "KEY2", "KEY3"))
      DETAIL
       dgcs_pos = 0, dgcs_pos = locateval(dgcs_num,1,size(col_string_parm->qual[dgcs_col_pos].
         col_qual,5),utc.column_name,col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_num].
        column_name)
       IF (dgcs_pos > 0)
        col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_pos].in_src_ind = 1
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(- (1))
     ENDIF
     SELECT DISTINCT INTO "nl:"
      dpwp.column_name
      FROM dm_pk_where_parm dpwp
      WHERE (dpwp.table_name=col_string_parm->qual[dgcs_col_pos].table_name)
      DETAIL
       dgcs_pos = 0, dgcs_pos = locateval(dgcs_num,1,size(col_string_parm->qual[dgcs_col_pos].
         col_qual,5),dpwp.column_name,col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_num].
        column_name)
       IF ((col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_pos].in_src_ind=0))
        dgcs_miss_ind = 1
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(- (1))
     ENDIF
     IF (dgcs_miss_ind=1)
      SET dm_err->err_ind = 1
      SET dm_err->emsg = concat(
       "PK_WHERE or PTAM_MATCH_QUERY is going to use a column that does not exist in source.")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(- (2))
     ENDIF
    ENDIF
    SET dgcs_func_prefix = concat("REFCHG_COLSTRING_",dgcs_tab_suffix)
    SET dgcs_func_name = drmm_get_func_name(dgcs_func_prefix," ")
    IF (check_error(dm_err->eproc)=1)
     RETURN(- (1))
    ENDIF
    IF (dgcs_func_name="")
     SET dm_err->emsg = concat("A col_string function is not built: ",dgcs_func_prefix)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     RETURN(- (1))
    ENDIF
    CALL parser(concat("declare ",dgcs_func_name,"() = c4000 go"),1)
    SET dgcs_stmt_cnt = (size(col_string_parm->qual[dgcs_col_pos].col_qual,5)+ 4)
    SET stat = alterlist(parse_rs->stmt,dgcs_stmt_cnt)
    SET dgcs_qual_cnt = 0
    SET dgcs_stmt_idx = 1
    SET dgcs_src_tab_name = concat(dgcs_tab_name,dgcs_db_link)
    SET parse_rs->stmt[dgcs_stmt_idx].str =
    "select into 'nl:' dm2_context_control_wrapper('RDDS_COL_STRING',"
    SET dgcs_stmt_idx = (dgcs_stmt_idx+ 1)
    SET parse_rs->stmt[dgcs_stmt_idx].str = concat(dgcs_func_name,"(")
    FOR (dgcs_loop = 1 TO size(col_string_parm->qual[dgcs_col_pos].col_qual,5))
      SET dgcs_stmt_idx = (dgcs_stmt_idx+ 1)
      IF (dgcs_loop != 1)
       SET parse_rs->stmt[dgcs_stmt_idx].str = ","
      ELSE
       SET parse_rs->stmt[dgcs_stmt_idx].str = " "
      ENDIF
      IF (dgcs_db_link > "")
       IF ((col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_loop].in_src_ind=0))
        SET parse_rs->stmt[dgcs_stmt_idx].str = concat(parse_rs->stmt[dgcs_stmt_idx].str,"NULL")
       ELSE
        SET parse_rs->stmt[dgcs_stmt_idx].str = concat(parse_rs->stmt[dgcs_stmt_idx].str,"t",
         dgcs_tab_suffix,".",col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_loop].column_name)
       ENDIF
      ELSE
       SET parse_rs->stmt[dgcs_stmt_idx].str = concat(parse_rs->stmt[dgcs_stmt_idx].str,"t",
        dgcs_tab_suffix,".",col_string_parm->qual[dgcs_col_pos].col_qual[dgcs_loop].column_name)
      ENDIF
    ENDFOR
    SET dgcs_stmt_idx = (dgcs_stmt_idx+ 1)
    SET parse_rs->stmt[dgcs_stmt_idx].str = concat(")) from ",dgcs_src_tab_name," t",dgcs_tab_suffix)
    SET dgcs_stmt_idx = (dgcs_stmt_idx+ 1)
    SET parse_rs->stmt[dgcs_stmt_idx].str = concat(" ",sbr_pk_where,
     " detail dgcs_qual_cnt = dgcs_qual_cnt + 1 with nocounter,notrim, maxqual(t",dgcs_tab_suffix,
     ",1) go")
    EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","PARSE_RS")
    SET stat = initrec(parse_rs)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(- (1))
    ENDIF
    IF (dgcs_qual_cnt=0)
     CALL echo(concat("The pk_where: ",sbr_pk_where," did not return any rows."))
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drmm_get_ptam_match_query(sbr_log_id,sbr_tab_name,sbr_tab_suffix,sbr_db_link)
   DECLARE dgpq_dcl_tab_name = vc WITH protect, noconstant(" ")
   DECLARE dgpq_func_name = vc WITH protect, noconstant("")
   DECLARE dgpq_func_prefix = vc WITH protect, noconstant("")
   DECLARE dgpq_db_link = vc WITH protect, noconstant(" ")
   DECLARE dm2_context_control_wrapper() = i2
   DECLARE sys_context() = c4000
   IF ( NOT (validate(parse_rs,0)))
    FREE RECORD parse_rs
    RECORD parse_rs(
      1 stmt[*]
        2 str = vc
    ) WITH protect
   ENDIF
   IF (sbr_db_link > " ")
    SET dgpq_db_link = sbr_db_link
   ENDIF
   IF (sbr_log_id > 0.0)
    SET dgpq_dcl_tab_name = concat("DM_CHG_LOG",dgpq_db_link)
    SELECT INTO "nl:"
     dm2_context_control_wrapper("RDDS_PTAM_MATCH_QUERY",d.ptam_match_query)
     FROM (parser(dgpq_dcl_tab_name) d)
     WHERE d.log_id=sbr_log_id
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN
    ENDIF
   ELSE
    SET dgpq_func_prefix = concat("REFCHG_GEN_PK_PTAM_",sbr_tab_suffix)
    SET dgpq_func_name = drmm_get_func_name(dgpq_func_prefix," ")
    IF (check_error(dm_err->eproc)=1)
     RETURN
    ENDIF
    IF (dgpq_func_name="")
     SET dm_err->emsg = concat("A function is not built: ",dgpq_func_prefix)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     RETURN
    ENDIF
    CALL parser(concat("declare ",dgpq_func_name,"() = c2000 go"),1)
    SET stat = alterlist(parse_rs->stmt,3)
    SET parse_rs->stmt[1].str =
    "SELECT into 'nl:' sbr_ind = dm2_context_control_wrapper('RDDS_PTAM_MATCH_QUERY',"
    SET parse_rs->stmt[2].str = concat(dgpq_func_name,
     "(0,1,SYS_CONTEXT('CERNER','RDDS_COL_STRING',4000),'",dgpq_db_link,"')) from dual")
    SET parse_rs->stmt[3].str = " with nocounter go"
    EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","PARSE_RS")
    SET stat = initrec(parse_rs)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN
    ENDIF
   ENDIF
   RETURN
 END ;Subroutine
 SUBROUTINE drmm_get_ptam_match_result(sbr_log_id,sbr_src_env_id,sbr_tgt_env_id,sbr_db_link,
  sbr_local_ind,sbr_xlat_type)
   DECLARE dgpr_ptam_result = f8 WITH protect, noconstant(0.0)
   DECLARE dgpr_src_str = vc WITH protect, noconstant(" ")
   DECLARE dgpr_tgt_str = vc WITH protect, noconstant(" ")
   DECLARE dgpr_db_link = vc WITH protect, noconstant(" ")
   DECLARE dgpr_xlat_type = vc WITH protect, noconstant(" ")
   DECLARE refchg_run_ptam() = f8
   DECLARE sys_context() = c2000
   IF (sbr_db_link > " ")
    SET dgpr_db_link = sbr_db_link
   ENDIF
   IF (sbr_xlat_type > " ")
    SET dgpr_xlat_type = sbr_xlat_type
   ENDIF
   IF (sbr_log_id > 0.0)
    SET dgpq_dcl_tab_name = concat("DM_CHG_LOG",dgpr_db_link)
    SELECT INTO "nl:"
     FROM (parser(dgpq_dcl_tab_name) d)
     WHERE d.log_id=sbr_log_id
     DETAIL
      dgpr_ptam_result = d.ptam_match_result
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ELSE
    SET dgpr_src_str = concat(trim(cnvtstring(sbr_src_env_id)),".0")
    SET dgpr_tgt_str = concat(trim(cnvtstring(sbr_tgt_env_id)),".0")
    SELECT INTO "nl:"
     ptam_result = refchg_run_ptam(replace(replace(replace(replace(replace(sys_context("CERNER",
            "RDDS_PTAM_MATCH_QUERY",2000),"<SOURCE_ID>",dgpr_src_str),"<TARGET_ID>",dgpr_tgt_str),
         "<DB_LINK>",concat("'",dgpr_db_link,"'")),"<LOCAL_IND>",trim(cnvtstring(sbr_local_ind))),
       "<XLAT_TYPE>",concat("'",dgpr_xlat_type,"'")))
     FROM dual
     DETAIL
      dgpr_ptam_result = ptam_result
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(dgpr_ptam_result)
 END ;Subroutine
 SUBROUTINE drmm_get_pk_where(sbr_tab_name,sbr_tab_suffix,sbr_delete_ind,sbr_db_link)
   DECLARE dgpw_dcl_tab_name = vc WITH protect, noconstant(" ")
   DECLARE dgpw_func_name = vc WITH protect, noconstant("")
   DECLARE dgpw_func_prefix = vc WITH protect, noconstant("")
   DECLARE dgpw_pk_where = vc WITH protect, noconstant(" ")
   DECLARE dgpw_db_link = vc WITH protect, noconstant(" ")
   DECLARE dm2_context_control_wrapper() = i2
   DECLARE sys_context() = c4000
   IF ( NOT (validate(parse_rs,0)))
    FREE RECORD parse_rs
    RECORD parse_rs(
      1 stmt[*]
        2 str = vc
    ) WITH protect
   ENDIF
   IF (sbr_db_link > " ")
    SET dgpw_db_link = sbr_db_link
   ENDIF
   SET dgpw_func_prefix = concat("REFCHG_GEN_PK_PTAM_",sbr_tab_suffix)
   SET dgpw_func_name = drmm_get_func_name(dgpw_func_prefix," ")
   IF (dgpw_func_name="")
    SET dm_err->emsg = concat("A col_string function is not built: ",dgpw_func_prefix)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN("")
   ENDIF
   CALL parser(concat("declare ",dgpw_func_name,"() = c2000 go"),1)
   SET stat = alterlist(parse_rs->stmt,4)
   SET parse_rs->stmt[1].str = "SELECT into 'nl:' dgpw_pkw = "
   SET parse_rs->stmt[2].str = concat(dgpw_func_name,"(1,",trim(cnvtstring(sbr_delete_ind)),
    ",SYS_CONTEXT('CERNER','RDDS_COL_STRING',4000),'",dgpw_db_link,
    "') from dual")
   SET parse_rs->stmt[3].str = "detail dgpw_pk_where = dgpw_pkw "
   SET parse_rs->stmt[4].str = "with nocounter go"
   EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","PARSE_RS")
   SET stat = initrec(parse_rs)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("")
   ENDIF
   RETURN(dgpw_pk_where)
 END ;Subroutine
 SUBROUTINE drmm_get_func_name(sbr_prefix,sbr_db_link)
   DECLARE dgfn_func_name = vc WITH protect, noconstant("")
   DECLARE dgfn_uo_tab = vc WITH protect, noconstant("")
   DECLARE dgfn_prefix = vc WITH protect, noconstant("")
   SET dgfn_uo_tab = concat("USER_OBJECTS",sbr_db_link)
   SET dgfn_prefix = concat(sbr_prefix,"*")
   SELECT INTO "nl:"
    FROM (parser(dgfn_uo_tab) uo)
    WHERE uo.object_name=patstring(dgfn_prefix)
    DETAIL
     dgfn_func_name = uo.object_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("")
   ENDIF
   RETURN(dgfn_func_name)
 END ;Subroutine
 SUBROUTINE drmm_get_cust_col_string(sbr_pk_where,sbr_tbl_name,sbr_col_name,sbr_tbl_suffix,
  sbr_db_link)
   DECLARE dgcs_tab_name = vc WITH protect, noconstant("")
   DECLARE dgcs_tab_suffix = vc WITH protect, noconstant("")
   DECLARE dgcs_src_tab_name = vc WITH protect, noconstant("")
   DECLARE dgcs_col_pos = i4 WITH protect, noconstant(0)
   DECLARE dgcs_num = i4 WITH protect, noconstant(0)
   DECLARE dgcs_func_prefix = vc WITH protect, noconstant("")
   DECLARE dgcs_func_name = vc WITH protect, noconstant("")
   DECLARE dgcs_loop = i4 WITH protect, noconstant(0)
   DECLARE dgcs_dcl_tab_name = vc WITH protect, noconstant("")
   DECLARE dgcs_db_link = vc WITH protect, noconstant(" ")
   DECLARE dgcs_stmt_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgcs_stmt_idx = i4 WITH protect, noconstant(0)
   DECLARE dgcs_qual_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgcs_col_loop = i4 WITH protect, noconstant(0)
   DECLARE dgcs_utc_name = vc WITH protect, noconstant("")
   DECLARE dgcs_pos = i4 WITH protect, noconstant(0)
   DECLARE dgcs_miss_ind = i2 WITH protect, noconstant(0)
   DECLARE dgcs_col_name = vc WITH protect, noconstant("")
   DECLARE dgcs_type = vc WITH protect, noconstant("")
   IF ( NOT (validate(parse_rs,0)))
    FREE RECORD parse_rs
    RECORD parse_rs(
      1 stmt[*]
        2 str = vc
    ) WITH protect
   ENDIF
   DECLARE dm2_context_control_wrapper() = i2
   IF (sbr_db_link > " ")
    SET dgcs_db_link = sbr_db_link
   ENDIF
   SET dgcs_tab_name = sbr_tbl_name
   SET dgcs_tab_suffix = sbr_tbl_suffix
   SET dgcs_col_name = sbr_col_name
   IF (dgcs_db_link > "")
    SET dgcs_utc_name = concat("USER_TAB_COLUMNS",dgcs_db_link)
   ELSE
    SET dgcs_utc_name = "USER_TAB_COLUMNS"
   ENDIF
   SELECT INTO "nl:"
    FROM (parser(dgcs_utc_name) utc)
    WHERE utc.table_name=dgcs_tab_name
     AND utc.column_name=dgcs_col_name
    DETAIL
     dgcs_type = utc.data_type
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   IF (curqual=0)
    CALL disp_msg("The column being asked for does not exist in source.",dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   IF ( NOT (dgcs_type IN ("DATE", "FLOAT", "NUMBER", "CHAR", "VARCHAR2")))
    CALL disp_msg("The column being asked has an incompatible data_type.",dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   SET dgcs_func_name = "REFCHG_CUST_COLSTRING"
   CALL parser(concat("declare ",dgcs_func_name,"() = c4000 go"),1)
   SET stat = alterlist(parse_rs->stmt,5)
   SET dgcs_qual_cnt = 0
   SET dgcs_stmt_idx = 1
   SET dgcs_src_tab_name = concat(dgcs_tab_name,dgcs_db_link)
   SET parse_rs->stmt[dgcs_stmt_idx].str =
   "select into 'nl:' dm2_context_control_wrapper('RDDS_CUST_COL_STRING',"
   SET dgcs_stmt_idx = (dgcs_stmt_idx+ 1)
   SET parse_rs->stmt[dgcs_stmt_idx].str = concat(dgcs_func_name,"(")
   SET dgcs_stmt_idx = (dgcs_stmt_idx+ 1)
   SET parse_rs->stmt[dgcs_stmt_idx].str = concat("'",dgcs_col_name,"','",dgcs_type,"',")
   IF (dgcs_type IN ("VARCHAR2", "CHAR"))
    SET parse_rs->stmt[dgcs_stmt_idx].str = concat(parse_rs->stmt[dgcs_stmt_idx].str,
     "0.0,cnvtdatetime(curdate,curtime3),","t",dgcs_tab_suffix,".",
     dgcs_col_name)
   ELSEIF (dgcs_type IN ("FLOAT", "NUMBER"))
    SET parse_rs->stmt[dgcs_stmt_idx].str = concat(parse_rs->stmt[dgcs_stmt_idx].str,"t",
     dgcs_tab_suffix,".",dgcs_col_name,
     ",cnvtdatetime(curdate,curtime3),'ABC'")
   ELSE
    SET parse_rs->stmt[dgcs_stmt_idx].str = concat(parse_rs->stmt[dgcs_stmt_idx].str,"0.0,t",
     dgcs_tab_suffix,".",dgcs_col_name,
     ",'ABC'")
   ENDIF
   SET dgcs_stmt_idx = (dgcs_stmt_idx+ 1)
   SET parse_rs->stmt[dgcs_stmt_idx].str = concat(")) from ",dgcs_src_tab_name," t",dgcs_tab_suffix)
   SET dgcs_stmt_idx = (dgcs_stmt_idx+ 1)
   SET parse_rs->stmt[dgcs_stmt_idx].str = concat(" ",sbr_pk_where,
    " detail dgcs_qual_cnt = dgcs_qual_cnt + 1 with nocounter,notrim, maxqual(t",dgcs_tab_suffix,
    ",1) go")
   EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","PARSE_RS")
   SET stat = initrec(parse_rs)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(- (1))
   ENDIF
   IF (dgcs_qual_cnt=0)
    CALL echo(concat("The pk_where: ",sbr_pk_where," did not return any rows."))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drmm_get_exploded_pkw(sbr_tab_name,sbr_tab_suffix,sbr_db_link)
   DECLARE dgep_dcl_tab_name = vc WITH protect, noconstant(" ")
   DECLARE dgep_func_name = vc WITH protect, noconstant("")
   DECLARE dgep_func_prefix = vc WITH protect, noconstant("")
   DECLARE dgep_pk_where = vc WITH protect, noconstant(" ")
   DECLARE dgep_db_link = vc WITH protect, noconstant(" ")
   DECLARE dm2_context_control_wrapper() = i2
   DECLARE sys_context() = c4000
   IF ( NOT (validate(parse_rs,0)))
    FREE RECORD parse_rs
    RECORD parse_rs(
      1 stmt[*]
        2 str = vc
    ) WITH protect
   ENDIF
   IF (sbr_db_link > " ")
    SET dgep_db_link = sbr_db_link
   ENDIF
   SET dgep_func_prefix = concat("REFCHG_GEN_PK_PTAM_",sbr_tab_suffix)
   SET dgep_func_name = drmm_get_func_name(dgep_func_prefix," ")
   IF (dgep_func_name="")
    SET dm_err->emsg = concat("A col_string function is not built: ",dgep_func_prefix)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN("")
   ENDIF
   CALL parser(concat("declare ",dgep_func_name,"() = c2000 go"),1)
   SET stat = alterlist(parse_rs->stmt,4)
   SET parse_rs->stmt[1].str = "SELECT into 'nl:' dgep_pkw = "
   SET parse_rs->stmt[2].str = concat(dgep_func_name,
    "(1,0,SYS_CONTEXT('CERNER','RDDS_COL_STRING',4000),'",dgep_db_link,"',0) from dual")
   SET parse_rs->stmt[3].str = "detail dgep_pk_where = dgep_pkw "
   SET parse_rs->stmt[4].str = "with nocounter go"
   EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","PARSE_RS")
   SET stat = initrec(parse_rs)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("")
   ENDIF
   RETURN(dgep_pk_where)
 END ;Subroutine
 DECLARE pk_where_info(i_table_name=vc,i_table_suffix=vc,i_alias=vc,i_dblink=vc,i_rs_data=vc(ref)) =
 vc
 DECLARE filter_info(i_table_name=vc,i_table_suffix=vc,i_alias=vc,i_dblink=vc,i_rs_data=vc(ref)) = vc
 DECLARE call_ins_log(i_table_name=vc,i_pk_where=vc,i_log_type=vc,i_delete_ind=i2,i_updt_id=f8,
  i_updt_task=i4,i_updt_applctx=i4,i_ctx_str=vc,i_envid=f8,i_pkw_vers_id=f8,
  i_dblink=vc) = vc
 DECLARE call_ins_dcl(i_table_name=vc,i_pk_where=vc,i_log_type=vc,i_delete_ind=i2,i_updt_id=f8,
  i_updt_task=i4,i_updt_applctx=i4,i_ctx_str=vc,i_envid=f8,i_spass_log_id=f8,
  i_dblink=vc,i_pk_hash=f8,i_ptam_hash=f8) = vc
 IF ((validate(proc_refchg_ins_log_args->has_vers_id,- (99))=- (99))
  AND (validate(proc_refchg_ins_log_args->has_vers_id,- (100))=- (100)))
  FREE RECORD proc_refchg_ins_log_args
  RECORD proc_refchg_ins_log_args(
    1 has_vers_id = i2
  )
  SET proc_refchg_ins_log_args->has_vers_id = - (1)
 ENDIF
 SUBROUTINE pk_where_info(i_table_name,i_table_suffix,i_alias,i_dblink,i_rs_data)
   DECLARE pwi_qual = i4 WITH protect, noconstant(0)
   DECLARE pwi_idx1 = i4 WITH protect, noconstant(0)
   DECLARE pwi_idx2 = i4 WITH protect, noconstant(0)
   DECLARE pwi_size = i4 WITH protect, noconstant(0)
   DECLARE pwi_temp = vc
   SET pwi_size = size(i_rs_data->data,5)
   SET pwi_idx1 = locateval(pwi_idx2,1,pwi_size,trim(i_table_name),i_rs_data->data[pwi_idx2].
    table_name)
   IF (pwi_idx1=0)
    SET pwi_idx1 = (pwi_size+ 1)
    SET stat = alterlist(i_rs_data->data,pwi_idx1)
    SET i_rs_data->data[pwi_idx1].table_name = trim(i_table_name)
   ENDIF
   SET pwi_temp = build("REFCHG_PK_WHERE_",i_table_suffix,"*")
   SET dm_err->eproc = concat("Verify that ",trim(pwi_temp)," function for ",trim(i_table_name),
    " exists in the domain")
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM (parser(concat("user_objects",trim(i_dblink))) uo)
    WHERE uo.object_name=patstring(pwi_temp)
     AND (uo.last_ddl_time=
    (SELECT
     max(o.last_ddl_time)
     FROM (parser(concat("user_objects",trim(i_dblink))) o)
     WHERE o.object_name=patstring(pwi_temp)))
    DETAIL
     i_rs_data->data[pwi_idx1].pkw_function = uo.object_name, i_rs_data->data[pwi_idx1].pkw_declare
      = concat("declare ",trim(uo.object_name),trim(i_dblink),"() = c2000 go")
    WITH nocounter
   ;end select
   SET pwi_qual = curqual
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("F")
   ENDIF
   IF (pwi_qual=0)
    SET dm_err->emsg = concat(trim(pwi_temp)," does not exist in current domain")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET i_rs_data->data[pwi_idx1].pkw_check_ind = 1
    RETURN("E")
   ENDIF
   SET dm_err->eproc = concat("Obtaining parameters for ",trim(pwi_temp))
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM (parser(concat("dm_refchg_pkw_parm",trim(i_dblink))) drp)
    WHERE drp.table_name=trim(i_table_name)
    ORDER BY drp.parm_nbr
    HEAD REPORT
     count = 0, i_rs_data->data[pwi_idx1].pkw_iu_str = concat(i_rs_data->data[pwi_idx1].pkw_function,
      trim(i_dblink),"('INS/UPD'"), i_rs_data->data[pwi_idx1].pkw_del_str = concat(i_rs_data->data[
      pwi_idx1].pkw_function,trim(i_dblink),"('DELETE'")
    DETAIL
     count = (count+ 1), stat = alterlist(i_rs_data->data[pwi_idx1].pkw,count), i_rs_data->data[
     pwi_idx1].pkw[count].parm_name = trim(drp.column_name)
     IF (trim(i_alias) > "")
      i_rs_data->data[pwi_idx1].pkw_iu_str = concat(i_rs_data->data[pwi_idx1].pkw_iu_str,",",trim(
        i_alias),".",trim(drp.column_name)), i_rs_data->data[pwi_idx1].pkw_del_str = concat(i_rs_data
       ->data[pwi_idx1].pkw_del_str,",",trim(i_alias),".",trim(drp.column_name))
     ELSE
      i_rs_data->data[pwi_idx1].pkw_iu_str = concat(i_rs_data->data[pwi_idx1].pkw_iu_str,",",trim(drp
        .column_name)), i_rs_data->data[pwi_idx1].pkw_del_str = concat(i_rs_data->data[pwi_idx1].
       pkw_del_str,",",trim(drp.column_name))
     ENDIF
    FOOT REPORT
     i_rs_data->data[pwi_idx1].pkw_iu_str = concat(i_rs_data->data[pwi_idx1].pkw_iu_str,")"),
     i_rs_data->data[pwi_idx1].pkw_del_str = concat(i_rs_data->data[pwi_idx1].pkw_del_str,")")
    WITH nocounter
   ;end select
   SET pwi_qual = curqual
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("F")
   ENDIF
   IF (pwi_qual=0)
    SET dm_err->emsg = "Could not obtain parameters for pk_where function"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("P")
   ENDIF
   SET i_rs_data->data[pwi_idx1].pkw_check_ind = 1
   RETURN("S")
 END ;Subroutine
 SUBROUTINE filter_info(i_table_name,i_table_suffix,i_alias,i_dblink,i_rs_data)
   DECLARE fi_qual = i4 WITH protect, noconstant(0)
   DECLARE fi_idx1 = i4 WITH protect, noconstant(0)
   DECLARE fi_idx2 = i4 WITH protect, noconstant(0)
   DECLARE fi_size = i4 WITH protect, noconstant(0)
   DECLARE fi_temp = vc
   SET fi_size = size(i_rs_data->data,5)
   SET fi_idx1 = locateval(fi_idx2,1,fi_size,trim(i_table_name),i_rs_data->data[fi_idx2].table_name)
   IF (fi_idx1=0)
    SET fi_idx1 = (fi_size+ 1)
    SET stat = alterlist(i_rs_data->data,fi_idx1)
    SET i_rs_data->data[fi_idx1].table_name = trim(i_table_name)
   ENDIF
   SET fi_temp = build("REFCHG_FILTER_",i_table_suffix,"*")
   SET dm_err->eproc = concat("Verify that ",trim(fi_temp)," function for ",trim(i_table_name),
    " exists in the domain")
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM (parser(concat("user_objects",trim(i_dblink))) uo)
    WHERE uo.object_name=patstring(fi_temp)
     AND (uo.last_ddl_time=
    (SELECT
     max(o.last_ddl_time)
     FROM (parser(concat("user_objects",trim(i_dblink))) o)
     WHERE o.object_name=patstring(fi_temp)))
    DETAIL
     i_rs_data->data[fi_idx1].filter_function = uo.object_name, i_rs_data->data[fi_idx1].
     filter_declare = concat("declare ",trim(uo.object_name),trim(i_dblink),"() = i2 go")
    WITH nocounter
   ;end select
   SET fi_qual = curqual
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("F")
   ENDIF
   IF (fi_qual=0)
    SET dm_err->eproc = concat(trim(fi_temp)," function for ",trim(i_table_name),
     " does not exists in the domain")
    CALL disp_msg(" ",dm_err->logfile,0)
    SET i_rs_data->data[fi_idx1].filter_check_ind = 1
    RETURN("E")
   ENDIF
   SET dm_err->eproc = concat("Obtaining parameters for ",trim(fi_temp))
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM (parser(concat("dm_refchg_filter_parm",trim(i_dblink))) drp)
    WHERE drp.table_name=trim(i_table_name)
     AND drp.active_ind=1
    ORDER BY drp.parm_nbr
    HEAD REPORT
     count = 0, i_rs_data->data[fi_idx1].filter_add_str = concat(i_rs_data->data[fi_idx1].
      filter_function,trim(i_dblink),"('ADD'"), i_rs_data->data[fi_idx1].filter_upd_str = concat(
      i_rs_data->data[fi_idx1].filter_function,trim(i_dblink),"('UPD'"),
     i_rs_data->data[fi_idx1].filter_del_str = concat(i_rs_data->data[fi_idx1].filter_function,trim(
       i_dblink),"('DEL'")
    DETAIL
     count = (count+ 1), stat = alterlist(i_rs_data->data[fi_idx1].filter,count), i_rs_data->data[
     fi_idx1].filter[count].parm_name = trim(drp.column_name)
     IF (trim(i_alias) > "")
      i_rs_data->data[fi_idx1].filter_add_str = concat(i_rs_data->data[fi_idx1].filter_add_str,",",
       trim(i_alias),".",trim(drp.column_name),
       ",",trim(i_alias),".",trim(drp.column_name)), i_rs_data->data[fi_idx1].filter_upd_str = concat
      (i_rs_data->data[fi_idx1].filter_upd_str,",",trim(i_alias),".",trim(drp.column_name),
       ",",trim(i_alias),".",trim(drp.column_name)), i_rs_data->data[fi_idx1].filter_del_str = concat
      (i_rs_data->data[fi_idx1].filter_del_str,",",trim(i_alias),".",trim(drp.column_name),
       ",",trim(i_alias),".",trim(drp.column_name))
     ELSE
      i_rs_data->data[fi_idx1].filter_add_str = concat(i_rs_data->data[fi_idx1].filter_add_str,",",
       trim(drp.column_name),",",trim(drp.column_name)), i_rs_data->data[fi_idx1].filter_upd_str =
      concat(i_rs_data->data[fi_idx1].filter_upd_str,",",trim(drp.column_name),",",trim(drp
        .column_name)), i_rs_data->data[fi_idx1].filter_del_str = concat(i_rs_data->data[fi_idx1].
       filter_del_str,",",trim(drp.column_name),",",trim(drp.column_name))
     ENDIF
    FOOT REPORT
     i_rs_data->data[fi_idx1].filter_add_str = concat(i_rs_data->data[fi_idx1].filter_add_str,")"),
     i_rs_data->data[fi_idx1].filter_upd_str = concat(i_rs_data->data[fi_idx1].filter_upd_str,")"),
     i_rs_data->data[fi_idx1].filter_del_str = concat(i_rs_data->data[fi_idx1].filter_del_str,")")
    WITH nocounter
   ;end select
   SET fi_qual = curqual
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("F")
   ENDIF
   IF (fi_qual=0)
    SET dm_err->emsg = "Could not obtain parameters for filter function"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN("P")
   ENDIF
   SET i_rs_data->data[fi_idx1].filter_check_ind = 1
   RETURN("S")
 END ;Subroutine
 SUBROUTINE call_ins_log(i_table_name,i_pk_where,i_log_type,i_delete_ind,i_updt_id,i_updt_task,
  i_updt_applctx,i_ctx_str,i_envid,i_pkw_vers_id,i_dblink)
   DECLARE cil_delete_ind_str = vc
   DECLARE cil_updt_id_str = vc
   DECLARE cil_updt_task_str = vc
   DECLARE cil_updt_applctx_str = vc
   DECLARE cil_ctx_str = vc
   DECLARE cil_envid_str = vc
   DECLARE cil_pkw_vers_id_str = vc
   DECLARE cil_pkw = vc
   SET cil_pk = replace_carrot_symbol(i_pk_where)
   FREE RECORD dat_stmt
   RECORD dat_stmt(
     1 stmt[5]
       2 str = vc
   )
   IF (trim(i_ctx_str) > "")
    SET cil_ctx_str = trim(i_ctx_str)
   ELSE
    SET cil_ctx_str = "NULL"
   ENDIF
   IF (i_envid=0)
    SET cil_envid_str = "NULL"
   ELSE
    SET cil_envid_str = trim(cnvtstring(i_envid))
   ENDIF
   SET cil_delete_ind_str = trim(cnvtstring(i_delete_ind))
   SET cil_updt_id_str = trim(cnvtstring(i_updt_id))
   SET cil_updt_task_str = trim(cnvtstring(i_updt_task))
   SET cil_updt_applctx_str = trim(cnvtstring(i_updt_applctx))
   SET cil_pkw_vers_id_str = trim(cnvtstring(i_pkw_vers_id))
   SET dat_stmt->stmt[1].str = concat("RDB ASIS(^ BEGIN proc_refchg_ins_log",trim(i_dblink),"('",
    i_table_name,"',^)")
   SET dat_stmt->stmt[2].str = concat("ASIS(^ ",cil_pk,",^)")
   SET dat_stmt->stmt[3].str = concat("ASIS(^ dbms_utility.get_hash_value(",cil_pk,",0,1073741824.0)",
    ",'",i_log_type,
    "',",cil_delete_ind_str,",",cil_updt_id_str,",",
    cil_updt_task_str,",",cil_updt_applctx_str,"^)")
   SET dat_stmt->stmt[4].str = concat("ASIS(^,'",cil_ctx_str,"',",cil_envid_str,"^)")
   SET dm_err->eproc = "Checking to see if we should use i_pkw_vers_id"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF ((proc_refchg_ins_log_args->has_vers_id=- (1)))
    SELECT INTO "nl:"
     FROM (parser(concat("user_arguments",trim(i_dblink))) ua)
     WHERE ua.object_name="PROC_REFCHG_INS_LOG"
      AND ua.argument_name="I_DM_REFCHG_PKW_VERS_ID"
     DETAIL
      proc_refchg_ins_log_args->has_vers_id = 1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN("F")
    ENDIF
    IF (curqual=0)
     SET proc_refchg_ins_log_args->has_vers_id = 0
    ENDIF
   ENDIF
   IF ((proc_refchg_ins_log_args->has_vers_id=1))
    SET dat_stmt->stmt[5].str = concat("ASIS(^,",cil_pkw_vers_id_str,"); END; ^) go")
   ELSE
    SET dat_stmt->stmt[5].str = concat("ASIS(^","); END; ^) go")
   ENDIF
   CALL echo(dat_stmt->stmt[1].str)
   CALL echo(dat_stmt->stmt[2].str)
   CALL echo(dat_stmt->stmt[3].str)
   CALL echo(dat_stmt->stmt[4].str)
   CALL echo(dat_stmt->stmt[5].str)
   EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","DAT_STMT")
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("F")
   ELSE
    COMMIT
    RETURN("S")
   ENDIF
 END ;Subroutine
 SUBROUTINE call_ins_dcl(i_table_name,i_pk_where,i_log_type,i_delete_ind,i_updt_id,i_updt_task,
  i_updt_applctx,i_ctx_str,i_envid,i_spass_log_id,i_dblink,i_pk_hash,i_ptam_hash)
   DECLARE cil_delete_ind_str = vc
   DECLARE cil_updt_id_str = vc
   DECLARE cil_updt_task_str = vc
   DECLARE cil_updt_applctx_str = vc
   DECLARE cil_ctx_str = vc
   DECLARE cil_envid_str = vc
   DECLARE cil_spass_log_id = vc
   DECLARE cil_pk = vc
   DECLARE cil_db_link = vc
   DECLARE cil_table_name = vc
   DECLARE cil_pk_hash = vc
   DECLARE cil_ptam_hash = vc
   DECLARE cil_ptam_result = vc
   DECLARE cil_log_type = vc
   DECLARE cid_delete_ind = i2
   DECLARE cid_updt_id = f8
   DECLARE cid_updt_task = i4
   DECLARE cid_updt_applctx = i4
   DECLARE cid_i_envid = f8
   DECLARE cid_i_pk_where = vc
   DECLARE cid_ptam_str_ind = i2 WITH protect, noconstant(0)
   SET cid_delete_ind = i_delete_ind
   SET cid_updt_id = i_updt_id
   SET cid_updt_task = i_updt_task
   SET cid_updt_applctx = i_updt_applctx
   SET cid_i_envid = i_envid
   SET cid_i_pk_where = i_pk_where
   SET cil_pk = replace_carrot_symbol(cid_i_pk_where)
   FREE RECORD dat_stmt
   RECORD dat_stmt(
     1 stmt[5]
       2 str = vc
   )
   IF (trim(i_ctx_str) > "")
    SET cil_ctx_str = trim(i_ctx_str)
   ELSE
    SET cil_ctx_str = "NULL"
   ENDIF
   IF (cid_i_envid=0)
    SET cil_envid_str = "NULL"
   ELSE
    SET cil_envid_str = trim(cnvtstring(cid_i_envid))
   ENDIF
   IF (i_spass_log_id=0)
    SET cil_spass_log_id = "NULL"
   ELSE
    SET cil_spass_log_id = trim(cnvtstring(i_spass_log_id))
   ENDIF
   SET cil_delete_ind_str = trim(cnvtstring(cid_delete_ind))
   SET cil_updt_id_str = trim(cnvtstring(cid_updt_id))
   SET cil_updt_task_str = trim(cnvtstring(cid_updt_task))
   SET cil_updt_applctx_str = trim(cnvtstring(cid_updt_applctx))
   SET cil_spass_log_id = trim(cnvtstring(i_spass_log_id))
   SET cil_db_link = trim(i_dblink)
   SET cil_table_name = trim(i_table_name)
   SET cil_pk_hash = trim(cnvtstring(i_pk_hash))
   SET cil_ptam_hash = trim(cnvtstring(i_ptam_hash))
   SET cil_log_type = trim(i_log_type)
   SELECT INTO "nl:"
    FROM (parser(concat("user_source",cil_db_link)) uo)
    WHERE uo.name="PROC_REFCHG_INS_DCL"
    DETAIL
     IF (cnvtlower(uo.text)="*i_ptam_match_result_str*")
      cid_ptam_str_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("F")
   ENDIF
   IF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "PROC_REFCHG_INS_DCL was not found"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("F")
   ELSE
    SET cil_ptam_result = cnvtstring(drmm_get_ptam_match_result(0.0,0.0,0.0,"",1,
      "FROM"))
    SET dat_stmt->stmt[1].str = concat("RDB ASIS(^ BEGIN proc_refchg_ins_dcl",trim(cil_db_link),"('",
     cil_table_name,"',^)")
    SET dat_stmt->stmt[2].str = concat("ASIS(^ ",cil_pk,",^)")
    SET dat_stmt->stmt[3].str = concat("ASIS(^ dbms_utility.get_hash_value(",cil_pk,
     ",0,1073741824.0)",",'",cil_log_type,
     "',",cil_delete_ind_str,",",cil_updt_id_str,",",
     cil_updt_task_str,",",cil_updt_applctx_str,"^)")
    SET dat_stmt->stmt[4].str = concat("ASIS(^,'",cil_ctx_str,"',",cil_envid_str,
     ",sys_context('CERNER','RDDS_PTAM_MATCH_QUERY',2000),",
     cil_ptam_result,",sys_context('CERNER','RDDS_COL_STRING',4000)",",",cil_pk_hash,",",
     cil_ptam_hash,",",cil_spass_log_id)
    IF (cid_ptam_str_ind=1)
     SET dat_stmt->stmt[4].str = concat(dat_stmt->stmt[4].str,
      ",sys_context('CERNER','RDDS_PTAM_MATCH_RESULT_STR',4000)^)")
    ELSE
     SET dat_stmt->stmt[4].str = concat(dat_stmt->stmt[4].str,"^)")
    ENDIF
    SET dat_stmt->stmt[5].str = concat("ASIS(^","); END; ^) go")
    CALL echo(dat_stmt->stmt[1].str)
    CALL echo(dat_stmt->stmt[2].str)
    CALL echo(dat_stmt->stmt[3].str)
    CALL echo(dat_stmt->stmt[4].str)
    CALL echo(dat_stmt->stmt[5].str)
    EXECUTE dm_rmc_pkw_parse1  WITH replace("REQUEST","DAT_STMT")
   ENDIF
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN("F")
   ELSE
    COMMIT
    RETURN("S")
   ENDIF
 END ;Subroutine
 IF ((validate(drwdr_request->from_value,- (1.0))=- (1.0)))
  FREE RECORD drwdr_request
  RECORD drwdr_request(
    1 table_name = vc
    1 log_type = vc
    1 col_name = vc
    1 from_value = f8
    1 source_env_id = f8
    1 target_env_id = f8
    1 dclei_ind = i2
    1 dcl_excep_id = f8
  )
  FREE RECORD drwdr_reply
  RECORD drwdr_reply(
    1 dcle_id = f8
    1 error_ind = i2
  )
 ENDIF
 IF ( NOT (validate(drfdx_request,0)))
  FREE RECORD drfdx_request
  RECORD drfdx_request(
    1 exception_id = f8
    1 target_env_id = f8
    1 db_link = vc
    1 exclude_str = vc
  )
  FREE RECORD drfdx_reply
  RECORD drfdx_reply(
    1 err_ind = i2
    1 emsg = vc
    1 total = i4
    1 row[*]
      2 log_id = f8
      2 table_name = vc
      2 log_type = vc
      2 pk_where = vc
      2 updt_dt_tm = f8
      2 updt_task = i4
      2 updt_id = f8
      2 context_name = vc
      2 current_context_ind = i2
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
 DECLARE replace_delim_vals(rcs_string=vc,rcs_size=i4) = vc
 DECLARE replace_char(rc_string=vc) = vc
 SUBROUTINE replace_delim_vals(rcs_string,rcs_size)
   DECLARE rcs_start_idx = i4
   DECLARE rcs_pos = i4
   DECLARE rcs_return = vc
   DECLARE rcs_temp_val = vc
   DECLARE rcs_concat = vc
   DECLARE rcs_size_diff = i4
   CALL echo(rcs_string)
   SET rcs_temp_val = rcs_string
   IF (rcs_size > 0)
    SET rcs_size_diff = (rcs_size - size(rcs_temp_val))
   ENDIF
   IF (findstring("^",rcs_temp_val,0,0) > 0)
    IF (findstring('"',rcs_temp_val,0,0) > 0)
     IF (findstring("'",rcs_temp_val,0,0) > 0)
      SET rcs_start_idx = 1
      SET rcs_pos = findstring("^",rcs_temp_val,1,0)
      WHILE (rcs_pos > 0)
        IF (rcs_start_idx=1)
         IF (rcs_pos=1)
          SET rcs_return = "char(94)"
         ELSE
          SET rcs_return = concat("concat(^",substring(rcs_start_idx,(rcs_pos - 1),rcs_temp_val),
           "^,char(94)")
         ENDIF
        ELSE
         SET rcs_return = concat(rcs_return,",^",substring(rcs_start_idx,(rcs_pos - rcs_start_idx),
           rcs_temp_val),"^,char(94)")
        ENDIF
        SET rcs_start_idx = (rcs_pos+ 1)
        SET rcs_pos = findstring("^",rcs_temp_val,rcs_start_idx,0)
        CALL echo(rcs_return)
      ENDWHILE
      IF (rcs_start_idx <= size(rcs_temp_val))
       SET rcs_pos = findstring("^",rcs_temp_val,1,1)
       IF (rcs_size_diff > 0)
        SET rcs_return = concat(rcs_return,",^",substring(rcs_start_idx,(size(rcs_temp_val) - rcs_pos
          ),rcs_temp_val),fillstring(value(rcs_size_diff)," "),"^)")
       ELSE
        SET rcs_return = concat(rcs_return,",^",substring(rcs_start_idx,(size(rcs_temp_val) - rcs_pos
          ),rcs_temp_val),"^)")
       ENDIF
      ENDIF
      CALL echo(rcs_return)
      RETURN(rcs_return)
     ELSE
      SET rcs_return = concat("'",rcs_temp_val,fillstring(value(rcs_size_diff)," "),"'")
      RETURN(rcs_return)
     ENDIF
    ELSE
     SET rcs_return = concat('"',rcs_temp_val,fillstring(value(rcs_size_diff)," "),'"')
     RETURN(rcs_return)
    ENDIF
   ELSE
    SET rcs_return = concat("^",rcs_temp_val,fillstring(value(rcs_size_diff)," "),"^")
    RETURN(rcs_return)
   ENDIF
 END ;Subroutine
 SUBROUTINE replace_char(rc_string)
   DECLARE rc_return = vc
   DECLARE rc_char_pos = i4
   DECLARE rc_char_loop = i2
   DECLARE rc_delim_val = vc
   DECLARE rc_last_ind = i2
   DECLARE rc_only_ind = i2
   SET rc_return = rc_string
   SET rc_only_ind = 0
   SET rc_last_ind = 0
   SET rc_char_ind = 0
   SET rc_char_loop = 0
   WHILE (rc_char_loop=0)
    SET rc_char_pos = findstring(char(0),rc_return,0,0)
    IF (rc_char_pos > 0)
     IF (rc_char_ind=0)
      IF (findstring("'",rc_return,0,0)=0)
       SET rc_delim_val = "'"
      ELSEIF (findstring('"',rc_return,0,0)=0)
       SET rc_delim_val = '"'
      ELSEIF (findstring("^",rc_return,0,0)=0)
       SET rc_delim_val = "^"
      ENDIF
     ENDIF
     IF (rc_char_pos=size(rc_return)
      AND rc_char_pos=1)
      SET rc_return = "char(0)"
      SET rc_last_ind = 1
      SET rc_only_ind = 1
     ELSEIF (rc_char_pos=size(rc_return)
      AND rc_char_pos != 1)
      SET rc_last_ind = 1
      IF (rc_char_ind=0)
       IF (rc_delim_val="'")
        SET rc_return = concat("'",substring(1,(rc_char_pos - 1),rc_return),"',char(0)")
       ELSEIF (rc_delim_val='"')
        SET rc_return = concat('"',substring(1,(rc_char_pos - 1),rc_return),'",char(0)')
       ELSEIF (rc_delim_val="^")
        SET rc_return = concat("^",substring(1,(rc_char_pos - 1),rc_return),"^,char(0)")
       ENDIF
      ELSE
       IF (substring((rc_char_pos - 1),1,rc_return)=rc_delim_val)
        IF (rc_delim_val="'")
         SET rc_return = concat(substring(1,(rc_char_pos - 3),rc_return),",char(0)")
        ELSEIF (rc_delim_val='"')
         SET rc_return = concat(substring(1,(rc_char_pos - 3),rc_return),",char(0)")
        ELSEIF (rc_delim_val="^")
         SET rc_return = concat(substring(1,(rc_char_pos - 3),rc_return),",char(0)")
        ENDIF
       ELSE
        IF (rc_delim_val="'")
         SET rc_return = concat(substring(1,(rc_char_pos - 1),rc_return),"',char(0)")
        ELSEIF (rc_delim_val='"')
         SET rc_return = concat(substring(1,(rc_char_pos - 1),rc_return),'",char(0)')
        ELSEIF (rc_delim_val="^")
         SET rc_return = concat(substring(1,(rc_char_pos - 1),rc_return),"^,char(0)")
        ENDIF
       ENDIF
      ENDIF
     ELSEIF (rc_char_pos=1)
      IF (rc_delim_val="'")
       SET rc_return = concat("char(0),'",substring((rc_char_pos+ 1),size(rc_return),rc_return))
      ELSEIF (rc_delim_val='"')
       SET rc_return = concat('char(0),"',substring((rc_char_pos+ 1),size(rc_return),rc_return))
      ELSEIF (rc_delim_val="^")
       SET rc_return = concat("char(0),^",substring((rc_char_pos+ 1),size(rc_return),rc_return))
      ENDIF
     ELSE
      IF (rc_char_ind=0)
       IF (rc_delim_val="'")
        SET rc_return = concat("'",substring(1,(rc_char_pos - 1),rc_return),"',char(0),'",substring((
          rc_char_pos+ 1),size(rc_return),rc_return))
       ELSEIF (rc_delim_val='"')
        SET rc_return = concat('"',substring(1,(rc_char_pos - 1),rc_return),'",char(0),"',substring((
          rc_char_pos+ 1),size(rc_return),rc_return))
       ELSEIF (rc_delim_val="^")
        SET rc_return = concat("^",substring(1,(rc_char_pos - 1),rc_return),"^,char(0),^",substring((
          rc_char_pos+ 1),size(rc_return),rc_return))
       ENDIF
      ELSE
       IF (substring((rc_char_pos - 1),1,rc_return)=rc_delim_val)
        IF (rc_delim_val="'")
         SET rc_return = concat(substring(1,(rc_char_pos - 3),rc_return),",char(0),'",substring((
           rc_char_pos+ 1),size(rc_return),rc_return))
        ELSEIF (rc_delim_val='"')
         SET rc_return = concat(substring(1,(rc_char_pos - 3),rc_return),',char(0),"',substring((
           rc_char_pos+ 1),size(rc_return),rc_return))
        ELSEIF (rc_delim_val="^")
         SET rc_return = concat(substring(1,(rc_char_pos - 3),rc_return),",char(0),^",substring((
           rc_char_pos+ 1),size(rc_return),rc_return))
        ENDIF
       ELSE
        IF (rc_delim_val="'")
         SET rc_return = concat(substring(1,(rc_char_pos - 1),rc_return),"',char(0),'",substring((
           rc_char_pos+ 1),size(rc_return),rc_return))
        ELSEIF (rc_delim_val='"')
         SET rc_return = concat(substring(1,(rc_char_pos - 1),rc_return),'",char(0),"',substring((
           rc_char_pos+ 1),size(rc_return),rc_return))
        ELSEIF (rc_delim_val="^")
         SET rc_return = concat(substring(1,(rc_char_pos - 1),rc_return),"^,char(0),^",substring((
           rc_char_pos+ 1),size(rc_return),rc_return))
        ENDIF
       ENDIF
      ENDIF
     ENDIF
     SET rc_char_ind = 1
    ELSE
     SET rc_char_loop = 1
    ENDIF
   ENDWHILE
   IF (rc_last_ind=0)
    SET rc_return = concat(rc_return,rc_delim_val)
   ENDIF
   IF (rc_char_ind=1
    AND rc_only_ind=0)
    SET rc_return = concat("CONCAT(",rc_return,")")
   ENDIF
   RETURN(rc_return)
 END ;Subroutine
 DECLARE replace_delim_vals(rcs_string=vc,rcs_size=i4) = vc
 DECLARE replace_char(rc_string=vc) = vc
 SUBROUTINE replace_delim_vals(rcs_string,rcs_size)
   DECLARE rcs_start_idx = i4
   DECLARE rcs_pos = i4
   DECLARE rcs_return = vc
   DECLARE rcs_temp_val = vc
   DECLARE rcs_concat = vc
   DECLARE rcs_size_diff = i4
   CALL echo(rcs_string)
   SET rcs_temp_val = rcs_string
   IF (rcs_size > 0)
    SET rcs_size_diff = (rcs_size - size(rcs_temp_val))
   ENDIF
   IF (findstring("^",rcs_temp_val,0,0) > 0)
    IF (findstring('"',rcs_temp_val,0,0) > 0)
     IF (findstring("'",rcs_temp_val,0,0) > 0)
      SET rcs_start_idx = 1
      SET rcs_pos = findstring("^",rcs_temp_val,1,0)
      WHILE (rcs_pos > 0)
        IF (rcs_start_idx=1)
         IF (rcs_pos=1)
          SET rcs_return = "char(94)"
         ELSE
          SET rcs_return = concat("concat(^",substring(rcs_start_idx,(rcs_pos - 1),rcs_temp_val),
           "^,char(94)")
         ENDIF
        ELSE
         SET rcs_return = concat(rcs_return,",^",substring(rcs_start_idx,(rcs_pos - rcs_start_idx),
           rcs_temp_val),"^,char(94)")
        ENDIF
        SET rcs_start_idx = (rcs_pos+ 1)
        SET rcs_pos = findstring("^",rcs_temp_val,rcs_start_idx,0)
        CALL echo(rcs_return)
      ENDWHILE
      IF (rcs_start_idx <= size(rcs_temp_val))
       SET rcs_pos = findstring("^",rcs_temp_val,1,1)
       IF (rcs_size_diff > 0)
        SET rcs_return = concat(rcs_return,",^",substring(rcs_start_idx,(size(rcs_temp_val) - rcs_pos
          ),rcs_temp_val),fillstring(value(rcs_size_diff)," "),"^)")
       ELSE
        SET rcs_return = concat(rcs_return,",^",substring(rcs_start_idx,(size(rcs_temp_val) - rcs_pos
          ),rcs_temp_val),"^)")
       ENDIF
      ENDIF
      CALL echo(rcs_return)
      RETURN(rcs_return)
     ELSE
      SET rcs_return = concat("'",rcs_temp_val,fillstring(value(rcs_size_diff)," "),"'")
      RETURN(rcs_return)
     ENDIF
    ELSE
     SET rcs_return = concat('"',rcs_temp_val,fillstring(value(rcs_size_diff)," "),'"')
     RETURN(rcs_return)
    ENDIF
   ELSE
    SET rcs_return = concat("^",rcs_temp_val,fillstring(value(rcs_size_diff)," "),"^")
    RETURN(rcs_return)
   ENDIF
 END ;Subroutine
 SUBROUTINE replace_char(rc_string)
   DECLARE rc_return = vc
   DECLARE rc_char_pos = i4
   DECLARE rc_char_loop = i2
   DECLARE rc_delim_val = vc
   DECLARE rc_last_ind = i2
   DECLARE rc_only_ind = i2
   SET rc_return = rc_string
   SET rc_only_ind = 0
   SET rc_last_ind = 0
   SET rc_char_ind = 0
   SET rc_char_loop = 0
   WHILE (rc_char_loop=0)
    SET rc_char_pos = findstring(char(0),rc_return,0,0)
    IF (rc_char_pos > 0)
     IF (rc_char_ind=0)
      IF (findstring("'",rc_return,0,0)=0)
       SET rc_delim_val = "'"
      ELSEIF (findstring('"',rc_return,0,0)=0)
       SET rc_delim_val = '"'
      ELSEIF (findstring("^",rc_return,0,0)=0)
       SET rc_delim_val = "^"
      ENDIF
     ENDIF
     IF (rc_char_pos=size(rc_return)
      AND rc_char_pos=1)
      SET rc_return = "char(0)"
      SET rc_last_ind = 1
      SET rc_only_ind = 1
     ELSEIF (rc_char_pos=size(rc_return)
      AND rc_char_pos != 1)
      SET rc_last_ind = 1
      IF (rc_char_ind=0)
       IF (rc_delim_val="'")
        SET rc_return = concat("'",substring(1,(rc_char_pos - 1),rc_return),"',char(0)")
       ELSEIF (rc_delim_val='"')
        SET rc_return = concat('"',substring(1,(rc_char_pos - 1),rc_return),'",char(0)')
       ELSEIF (rc_delim_val="^")
        SET rc_return = concat("^",substring(1,(rc_char_pos - 1),rc_return),"^,char(0)")
       ENDIF
      ELSE
       IF (substring((rc_char_pos - 1),1,rc_return)=rc_delim_val)
        IF (rc_delim_val="'")
         SET rc_return = concat(substring(1,(rc_char_pos - 3),rc_return),",char(0)")
        ELSEIF (rc_delim_val='"')
         SET rc_return = concat(substring(1,(rc_char_pos - 3),rc_return),",char(0)")
        ELSEIF (rc_delim_val="^")
         SET rc_return = concat(substring(1,(rc_char_pos - 3),rc_return),",char(0)")
        ENDIF
       ELSE
        IF (rc_delim_val="'")
         SET rc_return = concat(substring(1,(rc_char_pos - 1),rc_return),"',char(0)")
        ELSEIF (rc_delim_val='"')
         SET rc_return = concat(substring(1,(rc_char_pos - 1),rc_return),'",char(0)')
        ELSEIF (rc_delim_val="^")
         SET rc_return = concat(substring(1,(rc_char_pos - 1),rc_return),"^,char(0)")
        ENDIF
       ENDIF
      ENDIF
     ELSEIF (rc_char_pos=1)
      IF (rc_delim_val="'")
       SET rc_return = concat("char(0),'",substring((rc_char_pos+ 1),size(rc_return),rc_return))
      ELSEIF (rc_delim_val='"')
       SET rc_return = concat('char(0),"',substring((rc_char_pos+ 1),size(rc_return),rc_return))
      ELSEIF (rc_delim_val="^")
       SET rc_return = concat("char(0),^",substring((rc_char_pos+ 1),size(rc_return),rc_return))
      ENDIF
     ELSE
      IF (rc_char_ind=0)
       IF (rc_delim_val="'")
        SET rc_return = concat("'",substring(1,(rc_char_pos - 1),rc_return),"',char(0),'",substring((
          rc_char_pos+ 1),size(rc_return),rc_return))
       ELSEIF (rc_delim_val='"')
        SET rc_return = concat('"',substring(1,(rc_char_pos - 1),rc_return),'",char(0),"',substring((
          rc_char_pos+ 1),size(rc_return),rc_return))
       ELSEIF (rc_delim_val="^")
        SET rc_return = concat("^",substring(1,(rc_char_pos - 1),rc_return),"^,char(0),^",substring((
          rc_char_pos+ 1),size(rc_return),rc_return))
       ENDIF
      ELSE
       IF (substring((rc_char_pos - 1),1,rc_return)=rc_delim_val)
        IF (rc_delim_val="'")
         SET rc_return = concat(substring(1,(rc_char_pos - 3),rc_return),",char(0),'",substring((
           rc_char_pos+ 1),size(rc_return),rc_return))
        ELSEIF (rc_delim_val='"')
         SET rc_return = concat(substring(1,(rc_char_pos - 3),rc_return),',char(0),"',substring((
           rc_char_pos+ 1),size(rc_return),rc_return))
        ELSEIF (rc_delim_val="^")
         SET rc_return = concat(substring(1,(rc_char_pos - 3),rc_return),",char(0),^",substring((
           rc_char_pos+ 1),size(rc_return),rc_return))
        ENDIF
       ELSE
        IF (rc_delim_val="'")
         SET rc_return = concat(substring(1,(rc_char_pos - 1),rc_return),"',char(0),'",substring((
           rc_char_pos+ 1),size(rc_return),rc_return))
        ELSEIF (rc_delim_val='"')
         SET rc_return = concat(substring(1,(rc_char_pos - 1),rc_return),'",char(0),"',substring((
           rc_char_pos+ 1),size(rc_return),rc_return))
        ELSEIF (rc_delim_val="^")
         SET rc_return = concat(substring(1,(rc_char_pos - 1),rc_return),"^,char(0),^",substring((
           rc_char_pos+ 1),size(rc_return),rc_return))
        ENDIF
       ENDIF
      ENDIF
     ENDIF
     SET rc_char_ind = 1
    ELSE
     SET rc_char_loop = 1
    ENDIF
   ENDWHILE
   IF (rc_last_ind=0)
    SET rc_return = concat(rc_return,rc_delim_val)
   ENDIF
   IF (rc_char_ind=1
    AND rc_only_ind=0)
    SET rc_return = concat("CONCAT(",rc_return,")")
   ENDIF
   RETURN(rc_return)
 END ;Subroutine
 DECLARE drdm_create_pk_where(dcpw_cnt=i4,dcpw_table_cnt=i4,dcpw_type=vc) = vc
 DECLARE drdm_add_pkw_col(dapc_cnt=i4,dapc_table_cnt=i4,dapc_col_cnt=i4,dapc_pk_str=vc,
  dapc_col_null_ind=i2,
  dapc_ts_ind=i2) = vc
 SUBROUTINE drdm_create_pk_where(dcpw_cnt,dcpw_table_cnt,dcpw_type)
   DECLARE dcpw_pkw_col_cnt = i4
   DECLARE dcpw_pk_str = vc
   DECLARE dcpw_suffix = vc
   DECLARE dcpw_tbl_loop = i4
   DECLARE dcpw_col_nullind = i2
   DECLARE dcpw_col_loop = i4
   DECLARE dcpw_error_ind = i2
   DECLARE dcpw_col_str = vc WITH protect, noconstant("")
   DECLARE dcpw_col_str_vc = vc WITH protect, noconstant("")
   DECLARE dcpw_ts_ind = i2 WITH protect, noconstant(0)
   DECLARE dcpw_col_len = i4 WITH protect, noconstant(0)
   DECLARE dcpw_col_diff = i4 WITH protect, noconstant(0)
   SET dcpw_suffix = dm2_rdds_get_tbl_alias(dm2_ref_data_doc->tbl_qual[dcpw_table_cnt].suffix)
   IF ((validate(cust_cs_rows->trailing_space_ind,- (5))=- (5))
    AND (validate(cust_cs_rows->trailing_space_ind,- (6))=- (6)))
    SET dcpw_ts_ind = 0
   ELSE
    SET dcpw_ts_ind = 1
   ENDIF
   SET mdr_pk_cnt = 0
   SET mdr_pk_str = ""
   IF (dcpw_type="MD")
    FOR (dcpw_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[dcpw_table_cnt].col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[dcpw_table_cnt].col_qual[dcpw_col_loop].merge_delete_ind=1))
       CALL parser(concat("set dcpw_col_nullind = cust_cs_rows->qual[dcpw_cnt].",dm2_ref_data_doc->
         tbl_qual[dcpw_table_cnt].col_qual[dcpw_col_loop].column_name,"_NULLIND go"),1)
       SET dcpw_pkw_col_cnt = (dcpw_pkw_col_cnt+ 1)
       IF (dcpw_pkw_col_cnt=1)
        SET dcpw_pk_str = "WHERE "
       ELSE
        SET dcpw_pk_str = concat(dcpw_pk_str," AND ")
       ENDIF
       SET dcpw_pk_str = drdm_add_pkw_col(dcpw_cnt,dcpw_table_cnt,dcpw_col_loop,dcpw_pk_str,
        dcpw_col_nullind,
        dcpw_ts_ind)
      ENDIF
    ENDFOR
   ELSEIF (dcpw_type="UI")
    FOR (dcpw_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[dcpw_table_cnt].col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[dcpw_table_cnt].col_qual[dcpw_col_loop].unique_ident_ind=1))
       CALL parser(concat("set dcpw_col_nullind = cust_cs_rows->qual[dcpw_cnt].",dm2_ref_data_doc->
         tbl_qual[dcpw_table_cnt].col_qual[dcpw_col_loop].column_name,"_NULLIND go"),1)
       SET dcpw_pkw_col_cnt = (dcpw_pkw_col_cnt+ 1)
       IF (dcpw_pkw_col_cnt=1)
        SET dcpw_pk_str = "WHERE "
       ELSE
        SET dcpw_pk_str = concat(dcpw_pk_str," AND ")
       ENDIF
       SET dcpw_pk_str = drdm_add_pkw_col(dcpw_cnt,dcpw_table_cnt,dcpw_col_loop,dcpw_pk_str,
        dcpw_col_nullind,
        dcpw_ts_ind)
      ENDIF
    ENDFOR
   ELSEIF (dcpw_type IN ("ALG5", "ALG7"))
    FOR (dcpw_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[dcpw_table_cnt].col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[dcpw_table_cnt].col_qual[dcpw_col_loop].exception_flg=12))
       CALL parser(concat("set dcpw_col_nullind = cust_cs_rows->qual[dcpw_cnt].",dm2_ref_data_doc->
         tbl_qual[dcpw_table_cnt].col_qual[dcpw_col_loop].column_name,"_NULLIND go"),1)
       SET dcpw_pkw_col_cnt = (dcpw_pkw_col_cnt+ 1)
       IF (dcpw_pkw_col_cnt=1)
        SET dcpw_pk_str = "WHERE "
       ELSE
        SET dcpw_pk_str = concat(dcpw_pk_str," AND ")
       ENDIF
       SET dcpw_pk_str = drdm_add_pkw_col(dcpw_cnt,dcpw_table_cnt,dcpw_col_loop,dcpw_pk_str,
        dcpw_col_nullind,
        dcpw_ts_ind)
      ENDIF
    ENDFOR
    IF (dcpw_type="ALG5")
     SET dcpw_pk_str = concat(dcpw_pk_str," and ",dcpw_suffix,".",dm2_ref_data_doc->tbl_qual[
      dcpw_table_cnt].beg_col_name,
      " <= cnvtdatetime(curdate,curtime3) and ",dm2_ref_data_doc->tbl_qual[dcpw_table_cnt].
      end_col_name," > cnvtdatetime(curdate,curtime3) ")
    ENDIF
   ELSE
    FOR (dcpw_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[dcpw_table_cnt].col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[dcpw_table_cnt].col_qual[dcpw_col_loop].pk_ind=1))
       CALL parser(concat("set dcpw_col_nullind = cust_cs_rows->qual[dcpw_cnt].",dm2_ref_data_doc->
         tbl_qual[dcpw_table_cnt].col_qual[dcpw_col_loop].column_name,"_NULLIND go"),1)
       SET dcpw_pkw_col_cnt = (dcpw_pkw_col_cnt+ 1)
       IF (dcpw_pkw_col_cnt=1)
        SET dcpw_pk_str = "WHERE "
       ELSE
        SET dcpw_pk_str = concat(dcpw_pk_str," AND ")
       ENDIF
       SET dcpw_pk_str = drdm_add_pkw_col(dcpw_cnt,dcpw_table_cnt,dcpw_col_loop,dcpw_pk_str,
        dcpw_col_nullind,
        dcpw_ts_ind)
      ENDIF
    ENDFOR
   ENDIF
   IF (dcpw_error_ind=0)
    RETURN(dcpw_pk_str)
   ELSE
    RETURN("")
   ENDIF
 END ;Subroutine
 SUBROUTINE drdm_add_pkw_col(dapc_cnt,dapc_table_cnt,dapc_col_cnt,dapc_pk_str,dapc_col_nullind,
  dapc_ts_ind)
   DECLARE dapc_suffix = vc
   DECLARE dapc_col_name = vc WITH protect, noconstant(" ")
   DECLARE dapc_float = f8 WITH protect, noconstant(0.0)
   DECLARE dapc_float_str = vc WITH protect, noconstant(" ")
   DECLARE dapc_col_str = vc WITH protect, noconstant(" ")
   DECLARE dapc_col_len = i4 WITH protect, noconstant(0)
   DECLARE dapc_ret = vc WITH protect, noconstant(" ")
   SET dapc_suffix = dm2_rdds_get_tbl_alias(dm2_ref_data_doc->tbl_qual[dapc_table_cnt].suffix)
   SET dapc_col_name = dm2_ref_data_doc->tbl_qual[dapc_table_cnt].col_qual[dapc_col_cnt].column_name
   SET dapc_ret = dapc_pk_str
   IF (dapc_col_nullind=1)
    SET dapc_ret = concat(dapc_ret," ",dapc_suffix,".",dapc_col_name,
     " is NULL ")
   ELSEIF ((dm2_ref_data_doc->tbl_qual[dapc_table_cnt].col_qual[dapc_col_cnt].data_type="F8"))
    CALL parser(concat("set dapc_float = cust_cs_rows->qual[dapc_cnt].",dapc_col_name," go"),1)
    IF (dapc_float=round(dapc_float,0))
     SET dapc_float_str = concat(trim(cnvtstring(dapc_float,20)),".0")
    ELSE
     SET dapc_float_str = build(dapc_float)
    ENDIF
    CALL parser(concat("set dapc_ret = concat(dapc_ret, ' ",dapc_suffix,".",dapc_col_name,
      " =', dapc_float_str) go"),1)
   ELSEIF ((dm2_ref_data_doc->tbl_qual[dapc_table_cnt].col_qual[dapc_col_cnt].data_type IN ("I4",
   "I2")))
    CALL parser(concat("set dapc_ret = concat(dapc_ret, ' ",dapc_suffix,".",dapc_col_name," =',",
      "trim(cnvtstring(cust_cs_rows->qual[dapc_cnt].",dapc_col_name,")),'.0') go"),1)
   ELSEIF ((dm2_ref_data_doc->tbl_qual[dapc_table_cnt].col_qual[dapc_col_cnt].data_type IN ("VC",
   "C*")))
    SET dapc_col_str = ""
    CALL parser(concat("set dapc_col_str = cust_cs_rows->qual[dapc_cnt].",dapc_col_name," go"),1)
    IF (dapc_ts_ind=1)
     IF ((dm2_ref_data_doc->tbl_qual[dapc_table_cnt].col_qual[dapc_col_cnt].data_type="VC"))
      CALL parser(concat("set dapc_col_len = cust_cs_rows->qual[dapc_cnt].",dapc_col_name,"_len go"),
       1)
      SET dapc_col_diff = (dapc_col_len - size(dapc_col_str))
     ELSE
      SET dapc_col_len = 0
      SET dapc_col_diff = 0
     ENDIF
    ELSE
     SET dapc_col_len = 0
     SET dapc_col_diff = 0
    ENDIF
    SET dapc_col_str = replace_char(dapc_col_str)
    IF (findstring("char(0)",dapc_col_str,0,0)=0)
     SET dapc_col_str = concat(replace_delim_vals(dapc_col_str,dapc_col_len))
    ELSE
     IF (dcp_col_diff=0)
      SET dapc_col_str = dapc_col_str
     ELSE
      SET dapc_col_str = concat(substring(1,(size(dapc_col_str) - 1),dapc_col_str),"^",fillstring(
        value(rcs_size_diff)," "),"^)")
     ENDIF
    ENDIF
    IF (((findstring(char(42),dapc_col_str) > 0) OR (((findstring(char(63),dapc_col_str) > 0) OR (
    findstring(char(92),dapc_col_str) > 0)) )) )
     SET dapc_col_str = concat("nopatstring(",dapc_col_str,")")
    ENDIF
    SET dapc_ret = concat(dapc_ret," ",dapc_suffix,".",dapc_col_name,
     "=",dapc_col_str)
   ELSEIF ((dm2_ref_data_doc->tbl_qual[dapc_table_cnt].col_qual[dapc_col_cnt].data_type="DQ8"))
    CALL parser(concat("set dapc_ret = concat(dapc_ret,' ",dapc_suffix,".",dapc_col_name,
      " =  cnvtdatetime('",
      ",trim(build(cust_cs_rows->qual[dapc_cnt].",dapc_col_name,")),","')') go"),1)
   ELSE
    SET dapc_error_ind = 1
    CALL disp_msg(concat("An unknown datatype was found when trying to create pk_where: ",
      dm2_ref_data_doc->tbl_qual[dapc_table_cnt].col_qual[dapc_col_cnt].data_type),dm_err->logfile,1)
   ENDIF
   RETURN(dapc_ret)
 END ;Subroutine
 IF (validate(drdm_sequence->qual_cnt,- (1)) < 0)
  FREE RECORD drdm_sequence
  RECORD drdm_sequence(
    1 qual[*]
      2 seq_name = vc
      2 seq_val = f8
      2 seqmatch_ind = i2
    1 qual_cnt = i4
  )
 ENDIF
 IF (validate(dm2_rdds_rec->mode,"NONE")="NONE")
  FREE RECORD dm2_rdds_rec
  RECORD dm2_rdds_rec(
    1 mode = vc
    1 main_process = vc
  )
 ENDIF
 IF (validate(select_merge_translate_rec->type,"NONE")="NONE")
  FREE RECORD select_merge_translate_rec
  RECORD select_merge_translate_rec(
    1 type = vc
    1 to_opt_ind = i2
    1 from_opt_ctxt = vc
  )
 ENDIF
 IF (validate(tpc_pkw_vers_id->data[1].dm_refchg_pkw_vers_id,- (1)) < 0)
  FREE RECORD tpc_pkw_vers_id
  RECORD tpc_pkw_vers_id(
    1 data[*]
      2 table_name = vc
      2 dm_refchg_pkw_vers_id = f8
  )
 ENDIF
 IF ((validate(multi_col_pk->table_cnt,- (1))=- (1))
  AND (validate(multi_col_pk->table_cnt,- (2))=- (2)))
  FREE RECORD multi_col_pk
  RECORD multi_col_pk(
    1 table_cnt = i4
    1 qual[*]
      2 table_name = vc
      2 column_name = vc
  )
 ENDIF
 IF (validate(drmm_hold_exception->qual[1].dcl_excep_id,- (1)) < 0)
  FREE RECORD drmm_hold_exception
  RECORD drmm_hold_exception(
    1 value_cnt = i4
    1 qual[*]
      2 dcl_excep_id = f8
      2 table_name = vc
      2 column_name = vc
      2 from_value = f8
      2 log_type = vc
  )
 ENDIF
 IF ((validate(drdm_debug_row_ind,- (1))=- (1)))
  DECLARE drdm_debug_row_ind = i2 WITH protect, noconstant(0)
 ENDIF
 DECLARE merge_audit(action=vc,text=vc,audit_type=i4) = null
 DECLARE parse_statements(parser_cnt=i4) = null
 DECLARE insert_merge_translate(sbr_from=f8,sbr_to=f8,sbr_table=vc) = i2
 DECLARE select_merge_translate(sbr_f_value=vc,sbr_t_name=vc) = vc
 DECLARE drcm_get_xlat(dgx_f_value=vc,dgx_t_name=vc) = f8
 DECLARE rdds_del_except(sbr_table_name=vc,sbr_value=f8) = null
 DECLARE dm2_rdds_get_tbl_alias(sbr_tbl_suffix=vc) = vc
 DECLARE dm2_get_rdds_tname(sbr_tname=vc) = vc
 DECLARE trigger_proc_call(tpc_table_name=vc,tpc_pk_where=vc,tpc_context=vc,tpc_col_name=vc,tpc_value
  =f8) = i2
 DECLARE filter_proc_call(fpc_table_name=vc,fpc_pk_where=vc,fpc_updt_applctx=f8) = i2
 DECLARE replace_carrot_symbol(rcs_string=vc) = vc
 DECLARE replace_apostrophe(rcs_string=vc) = vc
 DECLARE log_md_scommit(lms_tab_name=vc,lms_tbl_cnt=i4,lms_log_type=vc,lms_chg_cnt=i4) = i4
 DECLARE load_merge_del(lmd_cnt=i4,lmd_log_type=vc,lmd_chg_cnt=i4) = i2
 DECLARE orphan_child_tab(sbr_table_name=vc,sbr_log_type=vc,sbr_col_name=vc,sbr_from_value=f8) = i2
 DECLARE drcm_validate(sbr_dv_t_name=vc,sbr_dv_pk_where=vc,sbr_dv_table_cnt=i4) = i2
 DECLARE find_nvld_value(fnv_value=vc,fnv_table=vc,fnv_from_value=vc) = vc
 DECLARE check_backfill(i_source_id=f8,i_table_name=vc,i_tbl_pos=i4) = c1
 DECLARE redirect_to_start_row(rsr_drdm_chg_rs=vc(ref),rsr_log_pos=i4,rsr_next_row=i4(ref),
  rsr_max_size=i4(ref)) = i4
 DECLARE get_multi_col_pk(null) = i2
 DECLARE find_original_log_row(i_drdm_chg_rs=vc(ref),i_log_pos=i4) = i4
 DECLARE fill_cur_state_rs(fcs_tab_name=vc) = i4
 DECLARE drdm_hash_validate(sbr_dv_t_name=vc,sbr_dv_pk_where=vc,sbr_dv_table_cnt=i4,sbr_dv_pkw_hash=
  f8,sbr_dv_ptam_hash=f8,
  sbr_dv_delete_ind=i2,sbr_updt_applctx=f8) = f8
 DECLARE trigger_proc_dcl(tpd_log_id=f8,tpd_table_name=vc,tpd_pk_str=vc,tpd_delete_ind=i2,
  tpd_sp_log_id=f8,
  tpd_log_type=vc,tpd_context=vc) = f8
 DECLARE add_single_pass_dcl_row(i_table_name=vc,i_pk_string=vc,i_single_pass_log_id=f8,
  i_context_name=vc) = f8
 DECLARE reset_exceptions(re_tab_name=vc,re_tgt_env_id=f8,re_from_value=f8,re_data=vc(ref)) = i2
 DECLARE fill_hold_excep_rs(null) = null
 DECLARE check_concurrent_snapshot(sbr_ccs_mode=c1,sbr_ccs_cur_appl_id=vc) = i2
 DECLARE dm2_get_appl_status(gas_appl_id=vc) = c1
 DECLARE load_grouper(lg_cnt=i4,lg_log_type=vc,lg_chg_cnt=i4) = i2
 DECLARE remove_cached_xlat(rcx_tab_name=vc,rcx_from_value=f8) = i2
 DECLARE add_xlat_ctxt_r(axc_tab_name=vc,axc_from_value=f8,axc_to_value=f8,axc_ctxt=vc) = i2
 DECLARE drcm_block_ptam_circ(dbp_rec=vc(ref),dbp_tbl_cnt=i4,dbp_pk_col=vc,dbp_pk_col_value=f8) =
 null
 DECLARE drcm_get_pk_str(dgps_rec=vc(ref),dgps_tab_name=vc) = vc
 DECLARE drcm_load_bulk_dcle(dlbd_tab_name=vc,dlbd_tbl_cnt=i4,dlbd_log_type=vc,dlbd_chg_cnt=i4) = i4
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
 SUBROUTINE drcm_get_xlat(dgx_f_value,dgx_t_name)
   DECLARE dgx_tbl_pos = i4 WITH protect, noconstant(0)
   DECLARE dgx_loop = i4 WITH protect, noconstant(0)
   DECLARE dgx_cur_table = i4 WITH protect, noconstant(0)
   DECLARE dgx_exception_flg = i4 WITH protect, noconstant(0)
   DECLARE dgx_return_val = vc WITH protect, noconstant("")
   DECLARE dgx_zero_ind = i2 WITH protect, noconstant(0)
   DECLARE dgx_mult_pk_pos = i4 WITH protect, noconstant(0)
   DECLARE dgx_mult_pk_idx = i4 WITH protect, noconstant(0)
   DECLARE dgx_xlat_func = vc WITH protect, noconstant("")
   DECLARE dgx_xlat_ret = f8 WITH protect, noconstant(0.0)
   DECLARE dgx_find_nvld_ret = vc WITH protect, noconstant("")
   DECLARE dgx_dtxc_text = vc WITH protect, noconstant("")
   SET dgx_xlat_ret = - (1.5)
   IF (dgx_t_name != "RDDS:MOVE AS IS")
    SET dgx_tbl_pos = locateval(dgx_loop,1,dm2_ref_data_doc->tbl_cnt,dgx_t_name,dm2_ref_data_doc->
     tbl_qual[dgx_loop].table_name)
    IF (cnvtreal(dgx_f_value) <= 0)
     RETURN(cnvtreal(dgx_f_value))
    ENDIF
    IF (dgx_tbl_pos=0)
     SET dgx_cur_table = temp_tbl_cnt
     SET dgx_tbl_pos = fill_rs("TABLE",dgx_t_name)
     SET temp_tbl_cnt = dgx_cur_table
     IF ((dgx_tbl_pos=- (1)))
      CALL disp_msg("Table can't be created from remote mover",dm_err->logfile,1)
     ENDIF
     IF ((dgx_tbl_pos=- (2)))
      SET drmm_ddl_rollback_ind = 1
      RETURN(dgx_xlat_ret)
     ENDIF
    ENDIF
    IF (dgx_tbl_pos <= 0)
     RETURN(dgx_xlat_ret)
    ENDIF
    IF ((dm2_ref_data_doc->tbl_qual[dgx_tbl_pos].mergeable_ind=0))
     RETURN(dgx_xlat_ret)
    ENDIF
    IF ((dm2_ref_data_doc->tbl_qual[dgx_tbl_pos].skip_seqmatch_ind != 1))
     FOR (dgx_loop = 1 TO dm2_ref_data_doc->tbl_qual[dgx_tbl_pos].col_cnt)
       IF ((dm2_ref_data_doc->tbl_qual[dgx_tbl_pos].col_qual[dgx_loop].pk_ind=1)
        AND (dm2_ref_data_doc->tbl_qual[dgx_tbl_pos].col_qual[dgx_loop].root_entity_name=dgx_t_name))
        SET dgx_exception_flg = dm2_ref_data_doc->tbl_qual[dgx_tbl_pos].col_qual[dgx_loop].
        exception_flg
       ENDIF
     ENDFOR
    ENDIF
    IF ((((dm2_ref_data_doc->tbl_qual[dgx_tbl_pos].skip_seqmatch_ind != 1)) OR ((dm2_ref_data_doc->
    tbl_qual[dgx_tbl_pos].table_name="APPLICATION_TASK"))) )
     SET dgx_return_val = check_backfill(dm2_ref_data_doc->env_source_id,dgx_t_name,dgx_tbl_pos)
     IF (dgx_return_val="F"
      AND dgx_exception_flg != 1)
      RETURN(dgx_xlat_ret)
     ENDIF
    ENDIF
   ENDIF
   IF ((((global_mover_rec->xlat_from_function != "XLAT_FROM_*")) OR ((global_mover_rec->
   xlat_to_function != "XLAT_TO_*"))) )
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="RDDS ENV PAIR"
      AND d.info_name=concat(cnvtstring(dm2_ref_data_doc->env_source_id,20),"::",cnvtstring(
       dm2_ref_data_doc->env_target_id,20))
     DETAIL
      global_mover_rec->xlat_to_function = concat("XLAT_TO_",cnvtstring(d.info_number,20)),
      global_mover_rec->xlat_from_function = concat("XLAT_FROM_",cnvtstring(d.info_number,20)),
      global_mover_rec->xlat_funct_nbr = d.info_number
     WITH nocounter
    ;end select
    IF (check_error("Get xlat functions") != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm2_ref_data_reply->error_ind = 1
     SET dm2_ref_data_reply->error_msg = dm_err->emsg
     SET dm_err->err_ind = 0
    ENDIF
    IF (curqual != 1)
     SET dm_err->emsg = "Error getting XLAT functions"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm2_ref_data_reply->error_ind = 1
     SET dm2_ref_data_reply->error_msg = dm_err->emsg
     SET dm_err->err_ind = 0
     RETURN(dgx_xlat_ret)
    ELSE
     CALL parser(concat("declare ",global_mover_rec->xlat_to_function,"() = f8 go"),1)
     CALL parser(concat("declare ",global_mover_rec->xlat_from_function,"() = f8 go"),1)
    ENDIF
   ENDIF
   IF ((drdm_chg->log[drdm_log_loop].delete_ind=1))
    CALL parser(concat("RDB ASIS(^ BEGIN DM2_CONTEXT_CONTROL('MVR_DEL_LOOKUP','YES'); END; ^) GO"),1)
   ENDIF
   IF (findstring(".0",dgx_f_value,1,0) > 0)
    SET dgx_zero_ind = 1
   ELSE
    SET dgx_zero_ind = 0
   ENDIF
   SET dgx_mult_pk_pos = locateval(dgx_mult_pk_idx,1,multi_col_pk->table_cnt,dgx_t_name,multi_col_pk
    ->qual[dgx_mult_pk_idx].table_name)
   IF ((select_merge_translate_rec->type != "TO"))
    IF (dgx_mult_pk_pos > 0)
     SET dgx_find_nvld_ret = find_nvld_value("0",dgx_t_name,dgx_f_value)
    ENDIF
    IF (dgx_zero_ind=0)
     SET dgx_xlat_func = concat(global_mover_rec->xlat_from_function,'("',dgx_t_name,'",',trim(
       dgx_f_value),
      ".0,",cnvtstring(dgx_exception_flg))
    ELSE
     SET dgx_xlat_func = concat(global_mover_rec->xlat_from_function,'("',dgx_t_name,'",',trim(
       dgx_f_value),
      ",",cnvtstring(dgx_exception_flg))
    ENDIF
    IF ((global_mover_rec->cbc_ind=1)
     AND trim(select_merge_translate_rec->from_opt_ctxt) > "")
     SET dgx_xlat_func = concat(dgx_xlat_func,',"',select_merge_translate_rec->from_opt_ctxt,'"')
    ENDIF
    SET dgx_xlat_func = concat(dgx_xlat_func,")")
    SELECT INTO "nl:"
     result1 = parser(dgx_xlat_func)
     FROM dual
     DETAIL
      dgx_xlat_ret = round(result1,2)
     WITH nocounter
    ;end select
   ELSE
    IF (dgx_mult_pk_pos > 0)
     SET dgx_find_nvld_ret = find_nvld_value(dgx_f_value,dgx_t_name,"0")
    ENDIF
    IF (dgx_zero_ind=0)
     SET dgx_xlat_func = concat(global_mover_rec->xlat_to_function,'("',dgx_t_name,'",',trim(
       dgx_f_value),
      ".0,",cnvtstring(dgx_exception_flg),",",cnvtstring(select_merge_translate_rec->to_opt_ind),")")
    ELSE
     SET dgx_xlat_func = concat(global_mover_rec->xlat_to_function,'("',dgx_t_name,'",',trim(
       dgx_f_value),
      ",",cnvtstring(dgx_exception_flg),",",cnvtstring(select_merge_translate_rec->to_opt_ind),")")
    ENDIF
    SELECT INTO "nl:"
     result1 = parser(dgx_xlat_func)
     FROM dual
     DETAIL
      dgx_xlat_ret = round(result1,2)
     WITH nocounter
    ;end select
   ENDIF
   IF (drdm_debug_row_ind=1)
    DECLARE sys_context() = c2000
    SELECT INTO "nl:"
     y = sys_context("CERNER","RDDS_XLAT_CACHE_TEST")
     FROM dual
     DETAIL
      dgx_dtxc_text = y
     WITH nocounter
    ;end select
    CALL echo(dgx_dtxc_text)
    CALL parser("rdb asis(^BEGIN DM2_CONTEXT_CONTROL('RDDS_XLAT_CACHE_TEST',''); END;^) GO",1)
   ENDIF
   CALL parser(concat("RDB ASIS(^ BEGIN DM2_CONTEXT_CONTROL('MVR_DEL_LOOKUP','NO'); END; ^) GO"),1)
   IF (check_error("Call xlat PL/SQL") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = dm_err->emsg
    SET dm_err->err_ind = 0
   ENDIF
   RETURN(dgx_xlat_ret)
 END ;Subroutine
 SUBROUTINE select_merge_translate(sbr_f_value,sbr_t_name)
   DECLARE sbr_return_val = vc
   DECLARE drdm_dmt_scr = vc
   DECLARE except_tab = vc
   DECLARE smt_loop = i4
   DECLARE smt_tbl_pos = i4
   DECLARE smt_cur_table = i4
   DECLARE smt_xlat_env_tgt_id = f8
   DECLARE smt_src_tab_name = vc
   DECLARE sbr_return_val2 = vc
   DECLARE new_col_var = vc
   DECLARE smt_parent_drdm_row = i2 WITH protect, noconstant(0)
   DECLARE smt_xlat_ret = f8 WITH protect, noconstant(0.0)
   DECLARE smt_zero_ind = i2 WITH protect, noconstant(0)
   DECLARE smt_mult_pk_pos = i4 WITH protect, noconstant(0)
   DECLARE smt_mult_pk_idx = i4 WITH protect, noconstant(0)
   DECLARE smt_vld_trans = f8 WITH protect, noconstant(0.0)
   SET sbr_return_val = "No Trans"
   SET except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   SET smt_xlat_env_tgt_id = dm2_ref_data_doc->mock_target_id
   IF (cnvtreal(sbr_f_value) <= 0)
    RETURN(sbr_f_value)
   ENDIF
   IF (findstring(".0",sbr_f_value,1,0) > 0)
    SET smt_zero_ind = 1
   ELSE
    SET smt_zero_ind = 0
   ENDIF
   SET smt_xlat_ret = drcm_get_xlat(sbr_f_value,sbr_t_name)
   SET smt_mult_pk_pos = locateval(smt_mult_pk_idx,1,multi_col_pk->table_cnt,sbr_t_name,multi_col_pk
    ->qual[smt_mult_pk_idx].table_name)
   IF (sbr_t_name != "RDDS:MOVE AS IS")
    SET smt_tbl_pos = locateval(smt_loop,1,dm2_ref_data_doc->tbl_cnt,sbr_t_name,dm2_ref_data_doc->
     tbl_qual[smt_loop].table_name)
    IF (smt_tbl_pos=0)
     SET smt_cur_table = temp_tbl_cnt
     SET smt_tbl_pos = fill_rs("TABLE",sbr_t_name)
     SET temp_tbl_cnt = smt_cur_table
     IF ((smt_tbl_pos=- (1)))
      CALL disp_msg("Table can't be created from remote mover",dm_err->logfile,1)
     ENDIF
     IF ((smt_tbl_pos=- (2)))
      SET drmm_ddl_rollback_ind = 1
      RETURN(sbr_return_val)
     ENDIF
    ENDIF
    IF (smt_tbl_pos <= 0)
     RETURN(sbr_return_val)
    ENDIF
    IF ((dm2_ref_data_doc->tbl_qual[smt_tbl_pos].mergeable_ind=0))
     RETURN(sbr_return_val)
    ENDIF
    SET new_col_var = dm2_ref_data_doc->tbl_qual[smt_tbl_pos].root_col_name
   ENDIF
   IF ((smt_xlat_ret=- (1.4)))
    IF ((select_merge_translate_rec->type="TO"))
     SET sbr_return_val = "No Source"
    ELSE
     SET sbr_return_val = "No Trans"
    ENDIF
   ELSEIF ((smt_xlat_ret=- (1.5)))
    SET sbr_return_val = "No Trans"
   ELSEIF ((smt_xlat_ret=- (1.6)))
    IF ((global_mover_rec->ptam_ind=1))
     SET sbr_return_val = "NOMV21"
     IF (smt_zero_ind=0)
      CALL orphan_child_tab(sbr_t_name,"NOMV21",new_col_var,cnvtreal(concat(trim(sbr_f_value),".0")))
     ELSE
      CALL orphan_child_tab(sbr_t_name,"NOMV21",new_col_var,cnvtreal(sbr_f_value))
     ENDIF
     SET smt_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
     SET drdm_chg->log[smt_parent_drdm_row].chg_log_reason_txt = concat(
      "Invalid translation found for table ",sbr_t_name," column ",new_col_var," with a value of ",
      sbr_return_val," in TARGET. Row will be blocked from merging.")
     SET drdm_chg->log[smt_parent_drdm_row].chg_log_reason_txt = concat(drdm_chg->log[
      smt_parent_drdm_row].chg_log_reason_txt," ",drcm_get_pk_str(dm2_ref_data_doc,drdm_chg->log[
       smt_parent_drdm_row].table_name))
    ELSE
     SET smt_src_tab_name = dm2_get_rdds_tname("DM_MERGE_TRANSLATE")
     SET sbr_return_val = "No Trans"
     IF (smt_mult_pk_pos > 0)
      SET drdm_parser->statement[1].frag = "select into 'nl:' from dm_merge_translate dm "
      SET drdm_parser->statement[2].frag =
      "where dm.env_source_id = dm2_ref_data_doc->env_source_id and "
      SET drdm_parser->statement[3].frag = "dm.env_target_id = smt_xlat_env_tgt_id and "
      IF ( NOT (sbr_t_name IN ("PRSNL", "PERSON")))
       SET drdm_parser->statement[4].frag = "dm.table_name = sbr_t_name and "
      ELSE
       SET drdm_parser->statement[4].frag = 'dm.table_name in ("PRSNL", "PERSON") and'
      ENDIF
      SET drdm_parser->statement[5].frag = "dm.from_value = cnvtreal(sbr_f_value) "
      SET drdm_parser->statement[6].frag = "detail "
      SET drdm_parser->statement[7].frag = "smt_vld_trans = dm.to_value go"
      CALL parse_statements(7)
      IF (smt_vld_trans=0.0)
       SET drdm_parser->statement[1].frag = concat("select into 'nl:' from ",smt_src_tab_name," dm ")
       SET drdm_parser->statement[2].frag = "where dm.env_source_id = smt_xlat_env_tgt_id and "
       SET drdm_parser->statement[3].frag = "dm.env_target_id = dm2_ref_data_doc->env_source_id and "
       IF ( NOT (sbr_t_name IN ("PRSNL", "PERSON")))
        SET drdm_parser->statement[4].frag = "dm.table_name = sbr_t_name and "
       ELSE
        SET drdm_parser->statement[4].frag = 'dm.table_name in ("PRSNL", "PERSON") and'
       ENDIF
       SET drdm_parser->statement[5].frag = "dm.to_value = cnvtreal(sbr_f_value) "
       SET drdm_parser->statement[6].frag = "detail "
       SET drdm_parser->statement[7].frag = "smt_vld_trans = dm.from_value go"
       CALL parse_statements(7)
      ENDIF
      IF (smt_vld_trans > 0.0)
       SET sbr_return_val = find_nvld_value(concat(trim(cnvtstring(smt_vld_trans,20)),".0"),
        sbr_t_name,"0")
      ENDIF
     ENDIF
     IF (sbr_return_val="No Trans")
      SET drdm_parser->statement[1].frag = "delete from dm_merge_translate dm "
      SET drdm_parser->statement[2].frag =
      "where dm.env_source_id = dm2_ref_data_doc->env_source_id and "
      SET drdm_parser->statement[3].frag = "dm.env_target_id = smt_xlat_env_tgt_id and "
      IF ( NOT (sbr_t_name IN ("PRSNL", "PERSON")))
       SET drdm_parser->statement[4].frag = "dm.table_name = sbr_t_name and "
      ELSE
       SET drdm_parser->statement[4].frag = 'dm.table_name in ("PRSNL", "PERSON") and'
      ENDIF
      IF ((select_merge_translate_rec->type != "TO"))
       SET drdm_parser->statement[5].frag = "dm.from_value = cnvtreal(sbr_f_value) go"
      ELSE
       SET drdm_parser->statement[5].frag = "dm.to_value = cnvtreal(sbr_f_value) go"
      ENDIF
      CALL parse_statements(5)
      SET drdm_parser->statement[1].frag = concat("delete from ",smt_src_tab_name," dm ")
      SET drdm_parser->statement[2].frag = "where dm.env_source_id = smt_xlat_env_tgt_id and "
      SET drdm_parser->statement[3].frag = "dm.env_target_id = dm2_ref_data_doc->env_source_id and "
      IF ( NOT (sbr_t_name IN ("PRSNL", "PERSON")))
       SET drdm_parser->statement[4].frag = "dm.table_name = sbr_t_name and "
      ELSE
       SET drdm_parser->statement[4].frag = 'dm.table_name in ("PRSNL", "PERSON") and'
      ENDIF
      IF ((select_merge_translate_rec->type != "TO"))
       SET drdm_parser->statement[5].frag = "dm.to_value = cnvtreal(sbr_f_value) go"
      ELSE
       SET drdm_parser->statement[5].frag = "dm.from_value = cnvtreal(sbr_f_value) go"
      ENDIF
      CALL parse_statements(5)
      IF ((select_merge_translate_rec->type != "TO"))
       IF (remove_cached_xlat(sbr_t_name,cnvtreal(sbr_f_value))=0)
        SET drdm_error_out_ind = 1
        SET dm_err->emsg = "Error removing xlat from cache."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        SET dm2_ref_data_reply->error_ind = 1
        SET dm2_ref_data_reply->error_msg = dm_err->emsg
        RETURN(sbr_return_val)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET sbr_return_val = concat(trim(cnvtstring(smt_xlat_ret,20)),".0")
   ENDIF
   IF (isnumeric(sbr_return_val))
    IF ((drdm_chg->log[drdm_log_loop].delete_ind=0))
     CALL rdds_del_except(sbr_t_name,cnvtreal(sbr_f_value))
     IF (drmm_ddl_rollback_ind=1)
      SET sbr_return_val = "No Trans"
     ENDIF
    ENDIF
   ENDIF
   RETURN(sbr_return_val)
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
   DECLARE imt_parent_drdm_row = i2 WITH protect, noconstant(0)
   DECLARE imt_xlat_ret = f8 WITH protect, noconstant(0.0)
   DECLARE imt_tmp_smt_type = vc WITH protect, noconstant(" ")
   DECLARE imt_tmp_smt_opt = i2 WITH protect, noconstant(0)
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
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("sbr_to:",trim(cnvtstring(sbr_to,20))))
    CALL echo(concat("sbr_table:",sbr_table))
   ENDIF
   SET imt_tmp_smt_type = select_merge_translate_rec->type
   SET imt_tmp_smt_opt = select_merge_translate_rec->to_opt_ind
   SET select_merge_translate_rec->type = "TO"
   SET select_merge_translate_rec->to_opt_ind = 1
   SET imt_xlat_ret = drcm_get_xlat(trim(cnvtstring(sbr_to,20,2)),sbr_table)
   SET select_merge_translate_rec->type = imt_tmp_smt_type
   SET select_merge_translate_rec->to_opt_ind = imt_tmp_smt_opt
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET no_insert_update = 1
    SET drdm_error_out_ind = 1
    SET dm_err->err_ind = 0
    RETURN(0)
   ENDIF
   IF (((imt_xlat_ret > 0) OR ((imt_xlat_ret=- (1.4)))) )
    SET imt_return = 1
   ENDIF
   IF (imt_return=0)
    INSERT  FROM dm_merge_translate dm
     SET dm.from_value = sbr_from, dm.to_value = sbr_to, dm.table_name = sbr_table,
      dm.env_source_id = dm2_ref_data_doc->env_source_id, dm.status_flg = (drdm_chg->log[
      drdm_log_loop].status_flg+ 100), dm.log_id = drdm_chg->log[drdm_log_loop].log_id,
      dm.updt_dt_tm = cnvtdatetime(curdate,curtime3), dm.env_target_id = imt_xlat_env_tgt_id, dm
      .updt_applctx = cnvtreal(currdbhandle)
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     IF (((findstring("ORA-00001:",dm_err->emsg) > 0) OR (findstring("ORA-02049:",dm_err->emsg) > 0
     )) )
      SET drmm_ddl_rollback_ind = 1
      RETURN(0)
     ELSE
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET nodelete_ind = 1
      SET no_insert_update = 1
      SET drdm_error_out_ind = 1
      SET dm_err->err_ind = 0
      RETURN(0)
     ENDIF
    ELSE
     DELETE  FROM dm_refchg_invalid_xlat drix
      WHERE drix.parent_entity_id=sbr_to
       AND drix.parent_entity_name=sbr_table
      WITH nocounter
     ;end delete
     IF (check_error(dm_err->eproc)=1)
      IF (((findstring("ORA-00001:",dm_err->emsg) > 0) OR (findstring("ORA-02049:",dm_err->emsg) > 0
      )) )
       SET drmm_ddl_rollback_ind = 1
       RETURN(0)
      ELSE
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET nodelete_ind = 1
       SET no_insert_update = 1
       SET drdm_error_out_ind = 1
       SET dm_err->err_ind = 0
       RETURN(0)
      ENDIF
     ENDIF
     IF (nvp_commit_ind=1
      AND (global_mover_rec->one_pass_ind=0))
      COMMIT
     ENDIF
    ENDIF
    CALL rdds_del_except(sbr_table,sbr_from)
   ELSE
    ROLLBACK
    SET drwdr_reply->dcle_id = 0
    SET drwdr_reply->error_ind = 0
    SET drwdr_request->table_name = sbr_table
    SET drwdr_request->log_type = "NOMV60"
    SET drwdr_request->col_name = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[imt_pk_pos].
    column_name
    SET drwdr_request->from_value = sbr_from
    SET drwdr_request->source_env_id = dm2_ref_data_doc->env_source_id
    SET drwdr_request->target_env_id = dm2_ref_data_doc->env_target_id
    SET drwdr_request->dclei_ind = drmm_excep_flag
    EXECUTE dm_rmc_write_dcle_rows  WITH replace("REQUEST","DRWDR_REQUEST"), replace("REPLY",
     "DRWDR_REPLY")
    IF ((drwdr_reply->error_ind=1))
     IF (((findstring("ORA-00001:",dm_err->emsg) > 0) OR (findstring("ORA-02049:",dm_err->emsg) > 0
     )) )
      SET drmm_ddl_rollback_ind = 1
      RETURN(0)
     ELSE
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET nodelete_ind = 1
      SET no_insert_update = 1
      SET drdm_error_out_ind = 1
      SET dm_err->err_ind = 0
      RETURN(0)
     ENDIF
    ENDIF
    IF ((drwdr_reply->dcle_id > 0))
     SET imt_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
     IF ((drdm_chg->log[imt_parent_drdm_row].dm_chg_log_exception_id=0))
      SET drdm_chg->log[imt_parent_drdm_row].dm_chg_log_exception_id = drwdr_reply->dcle_id
     ENDIF
     SET drdm_chg->log[imt_parent_drdm_row].chg_log_reason_txt = concat("Translation for table ",
      sbr_table," column ",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[imt_pk_pos].column_name,
      " source value ",
      trim(cnvtstring(sbr_from,20,2))," and target value ",trim(cnvtstring(sbr_to,20,2)),
      " could not be stored in target because of existing translation for target value ",trim(
       cnvtstring(sbr_to,20,2)))
    ENDIF
    COMMIT
    SET drdm_mini_loop_status = "NOMV60"
    SET drdm_chg->log[drdm_log_loop].chg_log_reason_txt = concat("Translation for table ",sbr_table,
     " column ",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[imt_pk_pos].column_name,
     " source value ",
     trim(cnvtstring(sbr_from,20,2))," and target value ",trim(cnvtstring(sbr_to,20,2)),
     " could not be stored in target because of existing translation for target value ",trim(
      cnvtstring(sbr_to,20,2)))
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
 SUBROUTINE merge_audit(action,text,audit_type)
   DECLARE aud_seq = i4
   DECLARE ma_log_id = f8
   DECLARE ma_next_seq = f8
   DECLARE ma_del_ind = i2
   DECLARE ma_table_name = vc
   IF (drdm_log_level=1
    AND  NOT (action IN ("INSERT", "UPDATE", "FAILREASON", "BATCH END", "WAITING",
   "BATCH START", "DELETE")))
    RETURN(null)
   ELSE
    SET ma_del_ind = 0
    SET ma_log_id = drdm_chg->log[drdm_log_loop].log_id
    IF (temp_tbl_cnt <= 0)
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
     SET nodelete_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
     RETURN(0)
    ELSE
     UPDATE  FROM dm_chg_log_audit dm
      SET dm.audit_dt_tm = cnvtdatetime(curdate,curtime3), dm.log_id = ma_log_id, dm.action = action,
       dm.text = substring(1,1000,text), dm.table_name = ma_table_name, dm.updt_dt_tm = cnvtdatetime(
        curdate,curtime3),
       dm.updt_applctx = cnvtreal(currdbhandle)
      WHERE dm.dm_chg_log_audit_id=ma_next_seq
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      SET nodelete_ind = 1
      IF (((findstring("ORA-00001:",dm_err->emsg) > 0) OR (findstring("ORA-02049:",dm_err->emsg) > 0
      )) )
       SET drmm_ddl_rollback_ind = 1
       RETURN(0)
      ELSE
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET drdm_error_out_ind = 1
       SET dm_err->err_ind = 0
       RETURN(0)
      ENDIF
     ENDIF
     IF (curqual=0)
      INSERT  FROM dm_chg_log_audit dm
       SET dm.audit_dt_tm = cnvtdatetime(curdate,curtime3), dm.log_id = ma_log_id, dm.action = action,
        dm.text = substring(1,1000,text), dm.table_name = ma_table_name, dm.dm_chg_log_audit_id =
        ma_next_seq,
        dm.updt_dt_tm = cnvtdatetime(curdate,curtime3), dm.updt_applctx = cnvtreal(currdbhandle)
       WITH nocounter
      ;end insert
      IF (check_error(dm_err->eproc)=1)
       SET nodelete_ind = 1
       IF (((findstring("ORA-00001:",dm_err->emsg) > 0) OR (findstring("ORA-02049:",dm_err->emsg) > 0
       )) )
        SET drmm_ddl_rollback_ind = 1
        RETURN(0)
       ELSE
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        SET drdm_error_out_ind = 1
        SET dm_err->err_ind = 0
        RETURN(0)
       ENDIF
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
 SUBROUTINE rdds_del_except(sbr_table_name,sbr_value)
   DECLARE except_tab = vc
   DECLARE der_idx = i4
   DECLARE der_pos = i4
   DECLARE der_loop = i4
   DECLARE der_start = i4
   DECLARE der_reset = i2 WITH protect, noconstant(0)
   DECLARE der_parent_drdm_row = i4 WITH protect, noconstant(0)
   DECLARE der_tab_pos = i4 WITH protect, noconstant(0)
   DECLARE der_circ_loop = i4 WITH protect, noconstant(0)
   DECLARE der_circ_pos = i4 WITH protect, noconstant(0)
   DECLARE der_temp_pos = i4 WITH protect, noconstant(0)
   DECLARE der_pe_name_val = vc WITH protect, noconstant("")
   DECLARE der_last_pe_col = vc WITH protect, noconstant("")
   DECLARE der_pe_id_pos = i4 WITH protect, noconstant(0)
   DECLARE der_new_loop = i4 WITH protect, noconstant(0)
   DECLARE der_log_type_str = vc WITH protect, noconstant("")
   SET except_tab = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   FREE RECORD circ_ref
   RECORD circ_ref(
     1 cnt = i4
     1 qual[*]
       2 circ_table_name = vc
       2 circ_id_col = vc
       2 circ_pe_col = vc
       2 circ_root_col = vc
       2 excptn_cnt = i4
       2 excptn_qual[*]
         3 value = f8
       2 circ_val_cnt = i4
       2 circ_val_qual[*]
         3 circ_value = f8
   )
   IF ((drdm_chg->log[drdm_log_loop].table_name=sbr_table_name))
    SET der_tab_pos = locateval(der_tab_pos,1,dm2_ref_data_doc->tbl_cnt,sbr_table_name,
     dm2_ref_data_doc->tbl_qual[der_tab_pos].table_name)
    IF ((dm2_ref_data_doc->tbl_qual[der_tab_pos].circular_cnt > 0))
     FOR (der_circ_loop = 1 TO dm2_ref_data_doc->tbl_qual[der_tab_pos].circular_cnt)
       IF ((dm2_ref_data_doc->tbl_qual[der_tab_pos].circ_qual[der_circ_loop].circular_type=2))
        IF ((dm2_ref_data_doc->tbl_qual[der_tab_pos].circ_qual[der_circ_loop].pe_name_col !=
        der_last_pe_col))
         SET der_last_pe_col = dm2_ref_data_doc->tbl_qual[der_tab_pos].circ_qual[der_circ_loop].
         pe_name_col
         CALL drmm_get_col_string(drdm_chg->log[drdm_log_loop].pk_where,0.0,dm2_ref_data_doc->
          tbl_qual[der_tab_pos].table_name,dm2_ref_data_doc->tbl_qual[der_tab_pos].suffix,
          dm2_ref_data_doc->post_link_name)
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          SET nodelete_ind = 1
          SET no_insert_update = 1
          SET drdm_error_out_ind = 1
          SET dm_err->err_ind = 0
          RETURN(null)
         ENDIF
         SELECT INTO "NL:"
          col_val = refchg_colstring_get_col(sys_context("CERNER","RDDS_COL_STRING",4000),
           dm2_ref_data_doc->tbl_qual[der_tab_pos].circ_qual[der_circ_loop].pe_name_col,4,0," ",
           0,0,"FROM")
          FROM dual
          DETAIL
           der_pe_name_val = col_val
          WITH nocounter
         ;end select
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          SET nodelete_ind = 1
          SET no_insert_update = 1
          SET drdm_error_out_ind = 1
          SET dm_err->err_ind = 0
          RETURN(null)
         ENDIF
         SET der_pe_id_pos = locateval(der_pe_id_pos,1,dm2_ref_data_doc->tbl_qual[der_tab_pos].
          col_cnt,dm2_ref_data_doc->tbl_qual[der_tab_pos].circ_qual[der_circ_loop].pe_name_col,
          dm2_ref_data_doc->tbl_qual[der_tab_pos].col_qual[der_pe_id_pos].parent_entity_col)
         SELECT INTO "NL:"
          der_y_name = evaluate_pe_name(dm2_ref_data_doc->tbl_qual[der_tab_pos].table_name,
           dm2_ref_data_doc->tbl_qual[der_tab_pos].col_qual[der_pe_id_pos].column_name,
           dm2_ref_data_doc->tbl_qual[der_tab_pos].circ_qual[der_circ_loop].pe_name_col,
           der_pe_name_val)
          FROM dual
          DETAIL
           der_pe_name_val = der_y_name
          WITH nocounter
         ;end select
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          SET nodelete_ind = 1
          SET no_insert_update = 1
          SET drdm_error_out_ind = 1
          SET dm_err->err_ind = 0
          RETURN(null)
         ENDIF
        ENDIF
        IF ((der_pe_name_val=dm2_ref_data_doc->tbl_qual[der_tab_pos].circ_qual[der_circ_loop].
        circ_table_name))
         IF (locateval(der_new_loop,1,circ_ref->cnt,dm2_ref_data_doc->tbl_qual[der_tab_pos].
          circ_qual[der_circ_loop].circ_table_name,circ_ref->qual[der_new_loop].circ_table_name,
          dm2_ref_data_doc->tbl_qual[der_tab_pos].circ_qual[der_circ_loop].circ_id_col_name,circ_ref
          ->qual[der_new_loop].circ_id_col,dm2_ref_data_doc->tbl_qual[der_tab_pos].circ_qual[
          der_circ_loop].circ_pe_name_col,circ_ref->qual[der_new_loop].circ_pe_col)=0)
          SET circ_ref->cnt = (circ_ref->cnt+ 1)
          SET stat = alterlist(circ_ref->qual,circ_ref->cnt)
          SET circ_ref->qual[circ_ref->cnt].circ_table_name = dm2_ref_data_doc->tbl_qual[der_tab_pos]
          .circ_qual[der_circ_loop].circ_table_name
          SET circ_ref->qual[circ_ref->cnt].circ_id_col = dm2_ref_data_doc->tbl_qual[der_tab_pos].
          circ_qual[der_circ_loop].circ_id_col_name
          SET circ_ref->qual[circ_ref->cnt].circ_pe_col = dm2_ref_data_doc->tbl_qual[der_tab_pos].
          circ_qual[der_circ_loop].circ_pe_name_col
          FOR (der_circ_pos = 1 TO drmm_hold_exception->value_cnt)
            IF ((drmm_hold_exception->qual[der_circ_pos].table_name=der_pe_name_val))
             SET circ_ref->qual[circ_ref->cnt].excptn_cnt = (circ_ref->qual[circ_ref->cnt].excptn_cnt
             + 1)
             SET stat = alterlist(circ_ref->qual[circ_ref->cnt].excptn_qual,circ_ref->qual[circ_ref->
              cnt].excptn_cnt)
             SET circ_ref->qual[circ_ref->cnt].excptn_qual[circ_ref->qual[circ_ref->cnt].excptn_cnt].
             value = drmm_hold_exception->qual[der_circ_pos].from_value
            ENDIF
          ENDFOR
         ENDIF
        ENDIF
       ELSE
        IF (locateval(der_new_loop,1,circ_ref->cnt,dm2_ref_data_doc->tbl_qual[der_tab_pos].circ_qual[
         der_circ_loop].circ_table_name,circ_ref->qual[der_new_loop].circ_table_name,
         dm2_ref_data_doc->tbl_qual[der_tab_pos].circ_qual[der_circ_loop].circ_id_col_name,circ_ref->
         qual[der_new_loop].circ_id_col,dm2_ref_data_doc->tbl_qual[der_tab_pos].circ_qual[
         der_circ_loop].circ_pe_name_col,circ_ref->qual[der_new_loop].circ_pe_col)=0)
         SET circ_ref->cnt = (circ_ref->cnt+ 1)
         SET stat = alterlist(circ_ref->qual,circ_ref->cnt)
         SET circ_ref->qual[circ_ref->cnt].circ_table_name = dm2_ref_data_doc->tbl_qual[der_tab_pos].
         circ_qual[der_circ_loop].circ_table_name
         SET circ_ref->qual[circ_ref->cnt].circ_id_col = dm2_ref_data_doc->tbl_qual[der_tab_pos].
         circ_qual[der_circ_loop].circ_id_col_name
         SET circ_ref->qual[circ_ref->cnt].circ_pe_col = dm2_ref_data_doc->tbl_qual[der_tab_pos].
         circ_qual[der_circ_loop].circ_pe_name_col
         FOR (der_circ_pos = 1 TO drmm_hold_exception->value_cnt)
           IF ((drmm_hold_exception->qual[der_circ_pos].table_name=dm2_ref_data_doc->tbl_qual[
           der_tab_pos].circ_qual[der_circ_loop].circ_table_name))
            SET circ_ref->qual[circ_ref->cnt].excptn_cnt = (circ_ref->qual[circ_ref->cnt].excptn_cnt
            + 1)
            SET stat = alterlist(circ_ref->qual[circ_ref->cnt].excptn_qual,circ_ref->qual[circ_ref->
             cnt].excptn_cnt)
            SET circ_ref->qual[circ_ref->cnt].excptn_qual[circ_ref->qual[circ_ref->cnt].excptn_cnt].
            value = drmm_hold_exception->qual[der_circ_pos].from_value
           ENDIF
         ENDFOR
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   FOR (der_circ_loop = 1 TO circ_ref->cnt)
     SET der_circ_pos = locateval(der_circ_pos,1,dm2_ref_data_doc->tbl_cnt,circ_ref->qual[
      der_circ_loop].circ_table_name,dm2_ref_data_doc->tbl_qual[der_circ_pos].table_name)
     IF (der_circ_pos=0)
      SET der_temp_pos = temp_tbl_cnt
      SET der_circ_pos = fill_rs("TABLE",circ_ref->qual[der_circ_loop].circ_table_name)
      IF ((der_circ_pos=- (1)))
       CALL disp_msg("Table can't be created from remote mover",dm_err->logfile,1)
       RETURN(null)
      ELSEIF ((der_circ_pos=- (2)))
       SET drdm_log_loop = redirect_to_start_row(drdm_chg,drdm_log_loop,drdm_next_row_pos,
        drdm_max_rs_size)
       SET drmm_ddl_rollback_ind = 1
       SET der_circ_pos = temp_tbl_cnt
       SET temp_tbl_cnt = der_temp_pos
       RETURN(null)
      ELSE
       SET temp_tbl_cnt = der_temp_pos
      ENDIF
     ENDIF
     SET circ_ref->qual[der_circ_loop].circ_root_col = dm2_ref_data_doc->tbl_qual[der_circ_pos].
     root_col_name
   ENDFOR
   FOR (der_circ_loop = 1 TO circ_ref->cnt)
     SET der_pe_name_val = dm2_get_rdds_tname(circ_ref->qual[der_circ_loop].circ_table_name)
     SET der_last_pe_col = concat('select into "NL:" ',circ_ref->qual[der_circ_loop].circ_root_col,
      " from ",der_pe_name_val," d where ",
      circ_ref->qual[der_circ_loop].circ_id_col," = ",trim(cnvtstring(sbr_value,20,1)))
     IF ((circ_ref->qual[der_circ_loop].circ_pe_col > " "))
      IF (sbr_table_name IN ("PRSNL", "PERSON"))
       SET der_last_pe_col = concat(der_last_pe_col,' and evaluate_pe_name("',circ_ref->qual[
        der_circ_loop].circ_table_name,'","',circ_ref->qual[der_circ_loop].circ_id_col,
        '","',circ_ref->qual[der_circ_loop].circ_pe_col,'",d.',circ_ref->qual[der_circ_loop].
        circ_pe_col,") in ('PRSNL','PERSON')")
      ELSE
       SET der_last_pe_col = concat(der_last_pe_col,' and evaluate_pe_name("',circ_ref->qual[
        der_circ_loop].circ_table_name,'","',circ_ref->qual[der_circ_loop].circ_id_col,
        '","',circ_ref->qual[der_circ_loop].circ_pe_col,'",d.',circ_ref->qual[der_circ_loop].
        circ_pe_col,") = '",
        sbr_table_name,"'")
      ENDIF
     ENDIF
     CALL parser(der_last_pe_col,0)
     CALL parser(concat(" detail circ_ref->qual[",trim(cnvtstring(der_circ_loop)),
       "].circ_val_cnt = circ_ref->qual[",trim(cnvtstring(der_circ_loop)),"].circ_val_cnt + 1 "),0)
     CALL parser(concat(" stat = alterlist(circ_ref->qual[",trim(cnvtstring(der_circ_loop)),
       "].circ_val_qual, circ_ref->qual[",trim(cnvtstring(der_circ_loop)),"].circ_val_cnt)"),0)
     CALL parser(concat(" circ_ref->qual[",trim(cnvtstring(der_circ_loop)),
       "].circ_val_qual[circ_ref->qual[",trim(cnvtstring(der_circ_loop)),
       "].circ_val_cnt].circ_value =  d.",
       circ_ref->qual[der_circ_loop].circ_root_col," go"),1)
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET nodelete_ind = 1
      SET no_insert_update = 1
      SET drdm_error_out_ind = 1
      SET dm_err->err_ind = 0
      RETURN(null)
     ENDIF
   ENDFOR
   IF ((global_mover_rec->reset_xcptn_ind=1))
    SET der_reset = reset_exceptions(sbr_table_name,dm2_ref_data_doc->env_target_id,sbr_value,
     circ_ref)
    IF (der_reset=0)
     SET nodelete_ind = 1
     SET no_insert_update = 1
     SET drdm_error_out_ind = 1
     SET dm_err->err_ind = 0
     RETURN(null)
    ENDIF
   ENDIF
   UPDATE  FROM (parser(except_tab) d)
    SET d.log_type = "DELETE"
    WHERE (d.target_env_id=dm2_ref_data_doc->env_target_id)
     AND d.table_name=sbr_table_name
     AND d.from_value=sbr_value
     AND d.log_type != "DELETE"
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET no_insert_update = 1
    SET drdm_error_out_ind = 1
    SET dm_err->err_ind = 0
    RETURN(null)
   ENDIF
   IF (curqual > 0)
    SET der_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
    SET drdm_chg->log[der_parent_drdm_row].dm_chg_log_exception_id = 0.0
   ENDIF
   IF ((global_mover_rec->circ_nomv_excl_cnt=0))
    SET der_log_type_str = "e.log_type != 'DELETE'"
   ELSE
    FOR (der_new_loop = 1 TO global_mover_rec->circ_nomv_excl_cnt)
      IF (der_new_loop=1)
       SET der_log_type_str = concat("e.log_type in ('",global_mover_rec->circ_nomv_qual[der_new_loop
        ].log_type,"'")
      ELSE
       SET der_log_type_str = concat(der_log_type_str,",'",global_mover_rec->circ_nomv_qual[
        der_new_loop].log_type,"'")
      ENDIF
    ENDFOR
    SET der_log_type_str = concat(der_log_type_str,")")
   ENDIF
   FOR (der_circ_loop = 1 TO circ_ref->cnt)
    FOR (der_new_loop = 1 TO circ_ref->qual[der_circ_loop].circ_val_cnt)
      IF (der_new_loop=1)
       SET der_last_pe_col = " e.from_value in ("
      ELSE
       SET der_last_pe_col = concat(der_last_pe_col,", ")
      ENDIF
      SET der_last_pe_col = concat(der_last_pe_col,trim(cnvtstring(circ_ref->qual[der_circ_loop].
         circ_val_qual[der_new_loop].circ_value,20,1)))
      IF ((der_new_loop=circ_ref->qual[der_circ_loop].circ_val_cnt))
       SET der_last_pe_col = concat(der_last_pe_col,")")
      ENDIF
    ENDFOR
    IF ((circ_ref->qual[der_circ_loop].circ_val_cnt > 0))
     IF ((circ_ref->qual[der_circ_loop].excptn_cnt > 0))
      UPDATE  FROM (parser(except_tab) e)
       SET e.log_type = "DELETE"
       WHERE (e.target_env_id=dm2_ref_data_doc->env_target_id)
        AND (e.table_name=circ_ref->qual[der_circ_loop].circ_table_name)
        AND (e.column_name=circ_ref->qual[der_circ_loop].circ_root_col)
        AND parser(der_log_type_str)
        AND parser(der_last_pe_col)
        AND  NOT (expand(der_new_loop,1,circ_ref->qual[der_circ_loop].excptn_cnt,e.from_value,
        circ_ref->qual[der_circ_loop].excptn_qual[der_new_loop].value))
       WITH nocounter
      ;end update
     ELSE
      UPDATE  FROM (parser(except_tab) e)
       SET e.log_type = "DELETE"
       WHERE (e.target_env_id=dm2_ref_data_doc->env_target_id)
        AND (e.column_name=circ_ref->qual[der_circ_loop].circ_root_col)
        AND parser(der_log_type_str)
        AND (e.table_name=circ_ref->qual[der_circ_loop].circ_table_name)
        AND parser(der_last_pe_col)
       WITH nocounter
      ;end update
     ENDIF
    ENDIF
   ENDFOR
   SET der_start = 1
   SET der_idx = 1
   WHILE (der_idx > 0)
    SET der_idx = locateval(der_loop,der_start,size(missing_xlats->qual,5),sbr_value,missing_xlats->
     qual[der_loop].missing_value)
    IF (der_idx > 0)
     IF ((missing_xlats->qual[der_idx].table_name=sbr_table_name)
      AND (missing_xlats->qual[der_idx].processed_ind=0)
      AND (drdm_chg->log[drdm_log_loop].single_pass_log_id > 0))
      IF (size(missing_xlats->qual,5)=der_idx)
       SET stat = alterlist(missing_xlats->qual,(der_idx - 1))
      ELSE
       FOR (der_pos = (der_idx+ 1) TO size(missing_xlats->qual,5))
         SET missing_xlats->qual[(der_pos - 1)].table_name = missing_xlats->qual[der_pos].table_name
         SET missing_xlats->qual[(der_pos - 1)].column_name = missing_xlats->qual[der_pos].
         column_name
         SET missing_xlats->qual[(der_pos - 1)].missing_value = missing_xlats->qual[der_pos].
         missing_value
       ENDFOR
       SET stat = alterlist(missing_xlats->qual,(size(missing_xlats->qual,5) - 1))
      ENDIF
      SET der_idx = 0
     ELSE
      SET der_start = (der_idx+ 1)
     ENDIF
    ENDIF
   ENDWHILE
   SET der_start = 1
   SET der_idx = 1
   WHILE (der_idx > 0)
    SET der_idx = locateval(der_loop,der_start,drmm_hold_exception->value_cnt,sbr_value,
     drmm_hold_exception->qual[der_loop].from_value,
     sbr_table_name,drmm_hold_exception->qual[der_loop].table_name)
    IF (der_idx > 0)
     IF ((drmm_hold_exception->value_cnt=der_idx))
      SET stat = alterlist(drmm_hold_exception->qual,(der_idx - 1))
      SET drmm_hold_exception->value_cnt = (drmm_hold_exception->value_cnt - 1)
     ELSE
      SET drmm_hold_exception->qual[der_idx].dcl_excep_id = drmm_hold_exception->qual[
      drmm_hold_exception->value_cnt].dcl_excep_id
      SET drmm_hold_exception->qual[der_idx].table_name = drmm_hold_exception->qual[
      drmm_hold_exception->value_cnt].table_name
      SET drmm_hold_exception->qual[der_idx].column_name = drmm_hold_exception->qual[
      drmm_hold_exception->value_cnt].column_name
      SET drmm_hold_exception->qual[der_idx].from_value = drmm_hold_exception->qual[
      drmm_hold_exception->value_cnt].from_value
      SET drmm_hold_exception->qual[der_idx].log_type = drmm_hold_exception->qual[drmm_hold_exception
      ->value_cnt].log_type
      SET stat = alterlist(drmm_hold_exception->qual,(size(drmm_hold_exception->qual,5) - 1))
      SET drmm_hold_exception->value_cnt = (drmm_hold_exception->value_cnt - 1)
     ENDIF
     SET der_idx = 0
     SET der_start = (der_idx+ 1)
    ENDIF
   ENDWHILE
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
 SUBROUTINE dm2_rdds_get_tbl_alias(sbr_tbl_suffix)
   DECLARE sbr_rgta_rtn = vc
   SET sbr_rgta_rtn = build("t",sbr_tbl_suffix)
   RETURN(sbr_rgta_rtn)
 END ;Subroutine
 SUBROUTINE trigger_proc_call(tpc_table_name,tpc_pk_where_in,tpc_context,tpc_col_name,tpc_value)
   DECLARE tpc_pk_where_vc = vc
   DECLARE tpc_pktbl_cnt = i4
   DECLARE tpc_tbl_loop = i4
   DECLARE tpc_suffix = vc
   DECLARE tpc_pk_proc_name = vc
   DECLARE tpc_proc_name = vc
   DECLARE tpc_src_tab_name = vc
   DECLARE tpc_uo_tname = vc
   DECLARE tpc_pkw_tab_name = vc
   DECLARE tpc_parser_cnt = i4
   DECLARE tpc_row_cnt = i4
   DECLARE tpc_row_loop = i4
   DECLARE tpc_validate_ret = i2
   DECLARE tpc_all_filtered = i2
   DECLARE tpc_last_pk_where = vc
   DECLARE tpc_parent_drdm_row = i2 WITH protect, noconstant(0)
   FREE RECORD tpc_pkw_rs
   RECORD tpc_pkw_rs(
     1 qual[*]
       2 pkw = vc
       2 invalid_ind = i2
   )
   SET tpc_pk_where_vc = tpc_pk_where_in
   SET tpc_proc_name = ""
   SET tpc_pktbl_cnt = 0
   SET tpc_pktbl_cnt = locateval(tpc_tbl_loop,1,size(pk_where_parm->qual,5),tpc_table_name,
    pk_where_parm->qual[tpc_tbl_loop].table_name)
   IF (tpc_pktbl_cnt=0)
    SET tpc_pktbl_cnt = (size(pk_where_parm->qual,5)+ 1)
    SET stat = alterlist(pk_where_parm->qual,tpc_pktbl_cnt)
    SET pk_where_parm->qual[tpc_pktbl_cnt].table_name = tpc_table_name
    SET tpc_tbl_loop = 0
    SET tpc_pkw_tab_name = "DM_REFCHG_PKW_PARM"
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
     SET tpc_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
     SET drdm_chg->log[tpc_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
     RETURN(- (1))
    ENDIF
   ENDIF
   IF (size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5)=0)
    CALL disp_msg(concat("No entries in DM_REFCHG_PKW_PARM for table: ",tpc_table_name),dm_err->
     logfile,1)
    SET drdm_error_out_ind = 1
    SET tpc_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
    SET drdm_chg->log[tpc_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
    RETURN(- (1))
   ENDIF
   SET temp_tbl_cnt = locateval(tpc_tbl_loop,1,dm2_ref_data_doc->tbl_cnt,tpc_table_name,
    dm2_ref_data_doc->tbl_qual[tpc_tbl_loop].table_name)
   IF (temp_tbl_cnt=0)
    SET temp_tbl_cnt = fill_rs("TABLE",tpc_table_name)
    IF ((temp_tbl_cnt=- (1)))
     CALL disp_msg("Table can't be created from remote mover",dm_err->logfile,1)
     SET tpc_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
     SET drdm_chg->log[tpc_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
     RETURN(- (1))
    ENDIF
    IF ((temp_tbl_cnt=- (2)))
     RETURN(- (2))
    ENDIF
   ENDIF
   SET tpc_suffix = concat("t",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix)
   IF (tpc_pk_where_vc="")
    SET tpc_pk_where_vc = concat("WHERE t",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix,".",
     tpc_col_name," = tpc_value")
   ENDIF
   SET tpc_pk_proc_name = concat("REFCHG_PK_WHERE_",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix,
    "*")
   SET tpc_uo_tname = "USER_OBJECTS"
   SELECT INTO "NL:"
    FROM (parser(tpc_uo_tname) u)
    WHERE u.object_name=patstring(tpc_pk_proc_name)
    DETAIL
     tpc_proc_name = u.object_name
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET tpc_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
    SET drdm_chg->log[tpc_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
    RETURN(- (1))
   ENDIF
   IF (tpc_proc_name="")
    SET dm_err->emsg = concat("A trigger procedure is not built: ",tpc_pk_proc_name)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET drdm_error_out_ind = 1
    SET tpc_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
    SET drdm_chg->log[tpc_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
    RETURN(- (1))
   ENDIF
   CALL parser(concat("declare ",tpc_proc_name,"() = c2000 go"),1)
   SET tpc_src_tab_name = dm2_get_rdds_tname(tpc_table_name)
   SET tpc_row_cnt = 0
   SET drdm_parser->statement[1].frag = concat('select into "nl:" pkw = ',tpc_proc_name,'("INS/UPD"')
   SET tpc_parser_cnt = 2
   FOR (tpc_tbl_loop = 1 TO size(pk_where_parm->qual[tpc_pktbl_cnt].col_qual,5))
     SET drdm_parser->statement[tpc_parser_cnt].frag = " , "
     SET tpc_parser_cnt = (tpc_parser_cnt+ 1)
     SET drdm_parser->statement[tpc_parser_cnt].frag = concat(tpc_suffix,".",pk_where_parm->qual[
      tpc_pktbl_cnt].col_qual[tpc_tbl_loop].col_name)
     SET tpc_parser_cnt = (tpc_parser_cnt+ 1)
   ENDFOR
   SET drdm_parser->statement[tpc_parser_cnt].frag = ")"
   SET tpc_parser_cnt = (tpc_parser_cnt+ 1)
   SET drdm_parser->statement[tpc_parser_cnt].frag = concat("from ",tpc_src_tab_name," ",tpc_suffix)
   SET tpc_parser_cnt = (tpc_parser_cnt+ 1)
   SET drdm_parser->statement[tpc_parser_cnt].frag = tpc_pk_where_vc
   SET tpc_parser_cnt = (tpc_parser_cnt+ 1)
   SET drdm_parser->statement[tpc_parser_cnt].frag = concat("detail tpc_row_cnt = tpc_row_cnt + 1 ",
    " stat = alterlist(tpc_pkw_rs->qual,tpc_row_cnt)")
   SET tpc_parser_cnt = (tpc_parser_cnt+ 1)
   SET drdm_parser->statement[tpc_parser_cnt].frag =
   "tpc_pkw_rs->qual[tpc_row_cnt].pkw = pkw with nocounter go"
   CALL parse_statements(tpc_parser_cnt)
   IF (nodelete_ind=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET tpc_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
    SET drdm_chg->log[tpc_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
    RETURN(- (1))
   ENDIF
   IF (tpc_row_cnt=0)
    RETURN(- (3))
   ENDIF
   FOR (tpc_row_loop = 1 TO tpc_row_cnt)
     IF ((tpc_pkw_rs->qual[tpc_row_loop].pkw != tpc_last_pk_where))
      IF (drdm_debug_row_ind=1)
       CALL echo("***PK_WHERE generated by target triggers:***")
       CALL echo(tpc_pkw_rs->qual[tpc_row_loop].pkw)
      ENDIF
      SET tpc_validate_ret = drcm_validate(tpc_table_name,tpc_pkw_rs->qual[tpc_row_loop].pkw,
       temp_tbl_cnt)
      IF (tpc_validate_ret < 0)
       IF ((tpc_validate_ret != - (4)))
        SET dm_err->emsg = concat("The PK_WHERE created by target procedure failed validation: ",
         tpc_pkw_rs->qual[tpc_row_loop].pkw)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        SET drdm_error_out_ind = 1
        SET tpc_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
        SET drdm_chg->log[tpc_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
        RETURN(- (1))
       ELSE
        SET tpc_pkw_rs->qual[tpc_row_loop].invalid_ind = 1
        SET tpc_all_filtered = 1
       ENDIF
      ENDIF
      IF ((tpc_pkw_rs->qual[tpc_row_loop].invalid_ind=0))
       SET tpc_all_filtered = 0
       IF (call_ins_log(tpc_table_name,tpc_pkw_rs->qual[tpc_row_loop].pkw,"REFCHG",0,reqinfo->updt_id,
        reqinfo->updt_task,reqinfo->updt_applctx,tpc_context,dm2_ref_data_doc->env_target_id,0.0,
        dm2_ref_data_doc->post_link_name)="F")
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        SET tpc_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
        SET drdm_chg->log[tpc_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
        RETURN(- (1))
       ENDIF
      ENDIF
      SET tpc_last_pk_where = tpc_pkw_rs->qual[tpc_row_loop].pkw
     ENDIF
   ENDFOR
   IF (tpc_all_filtered=1)
    RETURN(- (4))
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE filter_proc_call(fpc_table_name,fpc_pk_where,fpc_updt_applctx)
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
   DECLARE fpc_cur_state_flag = i4 WITH protect, noconstant(0)
   DECLARE fpc_cs_pos = i4 WITH protect, noconstant(0)
   DECLARE fpc_parent_drdm_row = i4 WITH protect, noconstant(0)
   DECLARE fpc_pkw_vc = vc WITH protect, noconstant("")
   DECLARE fpc_temp_cnt = i4 WITH protect, noconstant(0)
   DECLARE fpc_par_pos = i4 WITH protect, noconstant(0)
   DECLARE fpc_temp_pkw = vc WITH protect, noconstant("")
   DECLARE fpc_qual = i4 WITH protect, noconstant(0)
   DECLARE fpc_test_tab_name = vc WITH protect, noconstant(" ")
   DECLARE fpc_parent_tab_name = vc WITH protect, noconstant(" ")
   SET fpc_filter_pos = locateval(fpc_loop,1,size(filter_parm->qual,5),fpc_table_name,filter_parm->
    qual[fpc_loop].table_name)
   IF (fpc_filter_pos=0)
    SET fpc_filter_pos = (size(filter_parm->qual,5)+ 1)
    SET fpc_col_cnt = 0
    SET fpc_filter_tab_name = dm2_get_rdds_tname("DM_REFCHG_FILTER_PARM")
    SET fpc_test_tab_name = dm2_get_rdds_tname("DM_REFCHG_FILTER_TEST")
    SET fpc_parent_tab_name = dm2_get_rdds_tname("DM_REFCHG_FILTER")
    SELECT INTO "NL:"
     FROM (parser(fpc_filter_tab_name) d)
     WHERE d.table_name=fpc_table_name
      AND d.active_ind=1
      AND  EXISTS (
     (SELECT
      "x"
      FROM (parser(fpc_test_tab_name) t)
      WHERE t.table_name=d.table_name
       AND t.active_ind=1))
      AND  EXISTS (
     (SELECT
      "x"
      FROM (parser(fpc_parent_tab_name) f)
      WHERE f.table_name=d.table_name
       AND f.active_ind=1))
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
    IF ((temp_tbl_cnt=- (1)))
     CALL disp_msg("Table can't be created from remote mover",dm_err->logfile,1)
     RETURN(1)
    ENDIF
    IF ((temp_tbl_cnt=- (2)))
     SET temp_tbl_cnt = locateval(fpc_tbl_loop,1,dm2_ref_data_doc->tbl_cnt,fpc_table_name,
      dm2_ref_data_doc->tbl_qual[fpc_tbl_loop].table_name)
    ENDIF
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
   ENDIF
   SET fpc_pkw_vc = fpc_pk_where
   FREE RECORD fpc_cs_rows
   CALL parser("record fpc_cs_rows (",0)
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
   CALL parser(") go",0)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET fpc_error_ind = 1
   ENDIF
   SET fpc_suffix = concat("t",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix)
   SET fpc_src_tab_name = dm2_get_rdds_tname(fpc_table_name)
   SET fpc_cur_state_flag = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].cur_state_flag
   IF (fpc_cur_state_flag > 0
    AND fpc_updt_applctx != 4310001.0)
    SET fpc_cs_pos = fill_cur_state_rs(fpc_table_name)
    IF (fpc_cs_pos=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("ERROR: Couldn't not gather current state information for table ",
      fpc_table_name,".")
     SET fpc_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
     SET drdm_chg->log[fpc_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
     RETURN(- (1.0))
    ENDIF
    IF (trim(cur_state_tabs->qual[fpc_cs_pos].parent_tab_col) > " ")
     FOR (fpc_loop = 1 TO cur_state_tabs->qual[fpc_cs_pos].parent_cnt)
       IF (findstring(cur_state_tabs->qual[fpc_cs_pos].parent_qual[fpc_loop].parent_table,fpc_pkw_vc,
        1,1) > 0)
        RETURN(1)
       ENDIF
     ENDFOR
    ELSE
     RETURN(1)
    ENDIF
   ENDIF
   SET fpc_row_cnt = 0
   CALL parser("select distinct into 'NL:' ",0)
   FOR (fpc_tbl_loop = 1 TO size(filter_parm->qual[fpc_filter_pos].col_qual,5))
     IF (fpc_tbl_loop > 1)
      CALL parser(" , ",0)
     ENDIF
     CALL parser(concat("var",cnvtstring(fpc_tbl_loop)," = nullind(",fpc_suffix,".",
       filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name,")"),0)
     CALL parser(concat(",",fpc_suffix,".",filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].
       col_name),0)
   ENDFOR
   CALL parser(concat("from ",fpc_src_tab_name," ",fpc_suffix," ",
     fpc_pkw_vc),0)
   IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].filter_string != ""))
    SET dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].filter_string = replace(dm2_ref_data_doc->tbl_qual[
     temp_tbl_cnt].filter_string,"<MERGE LINK>",dm2_ref_data_doc->post_link_name,0)
    CALL parser(concat(" and ",replace(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].filter_string,
       "<SUFFIX>",fpc_suffix,0)),0)
   ENDIF
   CALL parser(concat(
     " detail  fpc_row_cnt = fpc_row_cnt + 1 stat = alterlist(fpc_cs_rows->qual, fpc_row_cnt) "),0)
   FOR (fpc_tbl_loop = 1 TO size(filter_parm->qual[fpc_filter_pos].col_qual,5))
    CALL parser(concat(" fpc_cs_rows->qual[fpc_row_cnt].",filter_parm->qual[fpc_filter_pos].col_qual[
      fpc_tbl_loop].col_name," = ",fpc_suffix,".",
      filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name),0)
    CALL parser(concat(" fpc_cs_rows->qual[fpc_row_cnt].",filter_parm->qual[fpc_filter_pos].col_qual[
      fpc_tbl_loop].col_name,"_NULLIND = var",cnvtstring(fpc_tbl_loop)),0)
   ENDFOR
   CALL parser("with nocounter go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET fpc_error_ind = 0
   ENDIF
   IF (fpc_row_cnt=0)
    RETURN(1)
   ENDIF
   IF (fpc_proc_name > " ")
    SET fpc_proc_name = dm2_get_rdds_tname(fpc_proc_name)
    CALL parser(concat(" declare ",fpc_proc_name,"() = i2 go"),1)
    FOR (fpc_row_loop = 1 TO fpc_row_cnt)
      SET drdm_parser->statement[1].frag = concat("select into 'NL:' ret_val = ",fpc_proc_name,
       "('UPD'")
      SET drdm_parser_cnt = 2
      FOR (fpc_tbl_loop = 1 TO size(filter_parm->qual[fpc_filter_pos].col_qual,5))
        CALL parser(concat("set fpc_col_nullind = fpc_cs_rows->qual[fpc_row_loop].",filter_parm->
          qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name,"_NULLIND go"),1)
        IF (fpc_col_nullind=1)
         SET drdm_parser->statement[drdm_parser_cnt].frag = ", NULL, NULL "
        ELSE
         SET fpc_col_pos = locateval(fpc_col_loop,1,dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt,
          filter_parm->qual[fpc_filter_pos].col_qual[fpc_tbl_loop].col_name,dm2_ref_data_doc->
          tbl_qual[temp_tbl_cnt].col_qual[fpc_col_loop].column_name)
         IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fpc_col_pos].data_type IN ("F8")))
          CALL parser(concat("set fpc_f8_var = fpc_cs_rows->qual[fpc_row_loop].",filter_parm->qual[
            fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," go"),1)
          IF (fpc_f8_var=round(fpc_f8_var,0))
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(",",trim(cnvtstring(fpc_f8_var,
              20,2))," , ",trim(cnvtstring(fpc_f8_var,20,2)))
          ELSE
           SET drdm_parser->statement[drdm_parser_cnt].frag = build(",",fpc_f8_var,",",fpc_f8_var)
          ENDIF
         ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fpc_col_pos].data_type IN ("Q8",
         "DQ8")))
          CALL parser(concat("set fpc_f8_var = fpc_cs_rows->qual[fpc_row_loop].",filter_parm->qual[
            fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" ,cnvtdatetime(",trim(cnvtstring
            (fpc_f8_var,20)),".0),cnvtdatetime(",trim(cnvtstring(fpc_f8_var,20)),".0)")
         ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[fpc_col_pos].data_type IN ("I4",
         "I2")))
          CALL parser(concat("set fpc_i4_var = fpc_cs_rows->qual[fpc_row_loop].",filter_parm->qual[
            fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," go"),1)
          SET drdm_parser->statement[drdm_parser_cnt].frag = concat(",",cnvtstring(fpc_i4_var)," , ",
           cnvtstring(fpc_i4_var))
         ELSE
          CALL parser(concat("set fpc_vc_var = fpc_cs_rows->qual[fpc_row_loop].",filter_parm->qual[
            fpc_filter_pos].col_qual[fpc_tbl_loop].col_name," go"),1)
          IF (fpc_vc_var=char(0))
           SET drdm_parser->statement[drdm_parser_cnt].frag = ",char(0) , char(0)"
          ELSE
           SET fpc_vc_var = replace_apostrophe(fpc_vc_var)
           SET fpc_vc_var = concat("'",fpc_vc_var,"'")
           SET drdm_parser->statement[drdm_parser_cnt].frag = concat(",",fpc_vc_var," , ",fpc_vc_var)
          ENDIF
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
 SUBROUTINE replace_apostrophe(rcs_string)
   DECLARE rcs_start_idx = i4
   DECLARE rcs_pos = i4
   DECLARE rcs_return = vc
   DECLARE rcs_concat = vc
   SET rcs_start_idx = 1
   SET rcs_pos = findstring("'",rcs_string,1,0)
   IF (rcs_pos != 0)
    WHILE (rcs_pos > 0)
      IF (rcs_start_idx=1)
       IF (rcs_pos=1)
        SET rcs_return = "chr(39)"
       ELSE
        SET rcs_return = concat('"',substring(rcs_start_idx,(rcs_pos - 1),rcs_string),'"||chr(39)')
       ENDIF
      ELSE
       SET rcs_return = concat(rcs_return,'||"',substring(rcs_start_idx,(rcs_pos - rcs_start_idx),
         rcs_string),'"||chr(39)')
      ENDIF
      SET rcs_start_idx = (rcs_pos+ 1)
      SET rcs_pos = findstring("'",rcs_string,rcs_start_idx,0)
    ENDWHILE
    IF (rcs_start_idx <= size(rcs_string))
     SET rcs_pos = findstring('"',rcs_string,1,1)
     SET rcs_return = concat(rcs_return,'||"',substring(rcs_start_idx,(size(rcs_string) - rcs_pos),
       rcs_string),'"')
    ENDIF
   ELSE
    SET rcs_return = rcs_string
   ENDIF
   RETURN(rcs_return)
 END ;Subroutine
 SUBROUTINE log_md_scommit(lms_tab_name,lms_tbl_cnt,lms_log_type,lms_chg_cnt)
   DECLARE lms_top_tbl = i4 WITH noconstant(0)
   DECLARE lms_con = i4 WITH noconstant(1)
   DECLARE lms_t_alias = vc
   DECLARE lms_pk_col = vc
   DECLARE lms_src_parent_table = vc
   DECLARE lms_p_size = i4 WITH noconstant(0)
   DECLARE lms_parent_table = vc
   DECLARE lms_parent_id_col = vc
   DECLARE lms_parent_tab_col = vc
   DECLARE lms_parent_value = f8
   DECLARE lms_pk_where = vc
   DECLARE lms_parent_loc = i4
   DECLARE lms_parent_loop = i4
   DECLARE lms_parent_cnt = i4
   DECLARE lms_temp_cnt = i4
   DECLARE lms_p_tab_name = vc
   DECLARE lms_p_t_suffix = vc
   DECLARE lms_child_idx = i4 WITH noconstant(0)
   DECLARE lms_child_idx2 = i4 WITH noconstant(0)
   DECLARE lms_parent_table_pp = vc
   DECLARE lms_pk_col_value = f8
   DECLARE lms_child_cnt = i4
   DECLARE lms_log_child = vc
   DECLARE lms_log_type_idx = i4 WITH protect, noconstant(0)
   DECLARE ll_child_return = i4
   DECLARE lms_other_col_val = f8
   DECLARE lms_source_tab_name = vc
   FREE RECORD lms_parent_vals
   RECORD lms_parent_vals(
     1 qual[*]
       2 value = f8
   )
   FREE RECORD lms_pk
   RECORD lms_pk(
     1 list[*]
       2 table_name = vc
       2 pk_where = vc
   )
   FREE RECORD lms_gc_pk
   RECORD lms_gc_pk(
     1 list[*]
       2 table_name = vc
       2 pk_where = vc
   )
   FREE RECORD lms_fv
   RECORD lms_fv(
     1 fv_cnt = i4
     1 list[*]
       2 table_name = vc
       2 from_value = f8
       2 column_name = vc
   )
   CALL echo("log_md_scommit")
   ROLLBACK
   CALL fill_hold_excep_rs(null)
   SET lms_pk_where = drdm_chg->log[lms_chg_cnt].pk_where
   IF (lms_log_type="ORPHAN")
    SET lms_log_child = "CHLDOR"
   ELSE
    SET lms_log_child = lms_log_type
   ENDIF
   IF ((dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].child_flag=0))
    SET dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].child_flag = 1
   ENDIF
   IF ((dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].parent_flag=0))
    SET dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].parent_flag = 1
   ENDIF
   FOR (lms_lp_col = 1 TO dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_cnt)
     IF ((dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_qual[lms_lp_col].pk_ind=1)
      AND (dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].table_name=dm2_ref_data_doc->tbl_qual[lms_tbl_cnt]
     .col_qual[lms_lp_col].root_entity_name)
      AND (dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_qual[lms_lp_col].column_name=dm2_ref_data_doc
     ->tbl_qual[lms_tbl_cnt].col_qual[lms_lp_col].root_entity_attr))
      SET lms_pk_col = dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_qual[lms_lp_col].column_name
      SET lms_top_tbl = (lms_top_tbl+ 1)
     ENDIF
   ENDFOR
   IF (lms_log_type="NOMV1C")
    SET ll_child_return = drcm_load_bulk_dcle(lms_tab_name,lms_tbl_cnt,lms_log_type,lms_chg_cnt)
    RETURN(ll_child_return)
   ENDIF
   IF (lms_top_tbl=1
    AND (dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].merge_delete_ind=1))
    CALL load_merge_del(lms_tbl_cnt,lms_log_child,lms_chg_cnt)
    IF ((dm_err->err_ind=1))
     RETURN(- (1))
    ENDIF
   ENDIF
   IF ((dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].version_ind=1)
    AND (dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].version_type IN ("ALG5", "ALG6", "ALG7")))
    CALL load_grouper(lms_tbl_cnt,lms_log_child,lms_chg_cnt)
    IF ((dm_err->err_ind=1))
     RETURN(- (1))
    ENDIF
   ENDIF
   CALL echo(build("child flag =",dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].child_flag))
   CALL echo(build("parent flag =",dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].parent_flag))
   IF ((dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].parent_flag=1)
    AND (dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].child_flag=1)
    AND size(trim(lms_pk_col)) > 0
    AND  NOT ((dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].version_type IN ("ALG5", "ALG6", "ALG7")))
    AND (dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].merge_delete_ind=0))
    CALL parser('select into "NL:"',0)
    CALL parser(concat(" from ",dm2_get_rdds_tname(dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].table_name
       )," t",dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].suffix),0)
    CALL parser(lms_pk_where,0)
    CALL parser(concat(" detail lms_pk_col_value = t",dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].suffix,
      ".",lms_pk_col," with nocounter go"),1)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm2_ref_data_reply->error_ind = 1
     SET dm2_ref_data_reply->error_msg = dm_err->emsg
    ELSE
     CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].table_name,lms_log_child,
      lms_pk_col,lms_pk_col_value)
     COMMIT
     IF (locateval(lms_log_type_idx,1,global_mover_rec->circ_nomv_excl_cnt,lms_log_child,
      global_mover_rec->circ_nomv_qual[lms_log_type_idx].log_type)=0)
      CALL drcm_block_ptam_circ(dm2_ref_data_doc,lms_tbl_cnt,lms_pk_col,lms_pk_col_value)
      IF ((dm_err->err_ind=1))
       RETURN(- (1))
      ENDIF
     ENDIF
    ENDIF
    SET lms_source_tab_name = dm2_get_rdds_tname(dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].table_name)
    IF ((dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].table_name="DCP_FORMS_REF"))
     SELECT INTO "NL:"
      FROM (parser(lms_source_tab_name) d)
      WHERE d.dcp_form_instance_id=lms_pk_col_value
      DETAIL
       lms_other_col_val = d.dcp_forms_ref_id
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(- (1))
     ENDIF
     CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].table_name,lms_log_child,
      "DCP_FORMS_REF_ID",lms_other_col_val)
     COMMIT
     SET stat = initrec(drmm_hold_exception)
    ENDIF
    IF ((dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].table_name="DCP_SECTION_REF"))
     SELECT INTO "NL:"
      FROM (parser(lms_source_tab_name) d)
      WHERE d.dcp_section_instance_id=lms_pk_col_value
      DETAIL
       lms_other_col_val = d.dcp_section_ref_id
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(- (1))
     ENDIF
     CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].table_name,lms_log_child,
      "DCP_SECTION_REF_ID",lms_other_col_val)
     COMMIT
     SET stat = initrec(drmm_hold_exception)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE load_merge_del(lmd_cnt,lmd_log_type,lmd_chg_cnt)
   DECLARE lmd_alias = vc
   DECLARE lmd_loop = i4
   DECLARE lms_src_fv = vc
   DECLARE lmd_temp_cnt = i4
   DECLARE lmd_qual_cnt = i4
   DECLARE lms_d_cnt = i4 WITH noconstant(0)
   DECLARE lmd_log_type_idx = i4 WITH protect, noconstant(0)
   SET lms_src_fv = dm2_get_rdds_tname(dm2_ref_data_doc->tbl_qual[lmd_cnt].table_name)
   SET lmd_alias = concat(" t",dm2_ref_data_doc->tbl_qual[lmd_cnt].suffix)
   FREE RECORD cust_cs_rows
   CALL parser("record cust_cs_rows (",0)
   CALL parser(" 1 trailing_space_ind = i2")
   CALL parser(" 1 qual[*]",0)
   FOR (lmd_loop = 1 TO dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_cnt)
     IF ((dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_qual[lmd_loop].merge_delete_ind=1))
      CALL parser(concat(" 2 ",dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_qual[lmd_loop].column_name,
        " = ",dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_qual[lmd_loop].data_type),0)
      CALL parser(concat(" 2 ",dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_qual[lmd_loop].column_name,
        "_NULLIND = i2 "),0)
      IF ((dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_qual[lmd_loop].data_type IN ("VC", "C*")))
       CALL parser(concat(" 2 ",dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_qual[lmd_loop].
         column_name,"_LEN = i4 "),0)
      ENDIF
     ENDIF
   ENDFOR
   CALL parser(") go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   SET lmd_temp_cnt = 0
   CALL parser("select into 'nl:'",0)
   FOR (lmd_loop = 1 TO dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_cnt)
     IF ((dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_qual[lmd_loop].merge_delete_ind=1))
      IF (lmd_temp_cnt > 0)
       CALL parser(" , ",0)
      ENDIF
      SET lmd_temp_cnt = (lmd_temp_cnt+ 1)
      CALL parser(concat("var",cnvtstring(lmd_loop)," = nullind(",lmd_alias,".",
        dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_qual[lmd_loop].column_name,")"),0)
      IF ((dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_qual[lmd_loop].data_type IN ("VC", "C*")))
       CALL parser(concat(", ts",cnvtstring(lmd_loop)," = length(",lmd_alias,".",
         dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_qual[lmd_loop].column_name,")"),0)
      ENDIF
     ENDIF
   ENDFOR
   CALL parser(concat(" from  ",lms_src_fv," ",lmd_alias),0)
   CALL parser(drdm_chg->log[lmd_chg_cnt].pk_where,0)
   CALL parser("head report cust_cs_rows->trailing_space_ind = 1",0)
   CALL parser(
    " detail lmd_qual_cnt = lmd_qual_cnt + 1 stat = alterlist(cust_cs_rows->qual, lmd_qual_cnt) ",0)
   FOR (lmd_loop = 1 TO dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_cnt)
     IF ((dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_qual[lmd_loop].merge_delete_ind=1))
      CALL parser(concat("cust_cs_rows->qual[lmd_qual_cnt].",dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].
        col_qual[lmd_loop].column_name," = ",lmd_alias,".",
        dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_qual[lmd_loop].column_name),0)
      CALL parser(concat("cust_cs_rows->qual[lmd_qual_cnt].",dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].
        col_qual[lmd_loop].column_name,"_NULLIND = var",trim(cnvtstring(lmd_loop))),0)
      IF ((dm2_ref_data_doc->tbl_qual[lms_tbl_cnt].col_qual[lmd_loop].data_type IN ("VC", "C*")))
       CALL parser(concat("cust_cs_rows->qual[lmd_qual_cnt].",dm2_ref_data_doc->tbl_qual[lms_tbl_cnt]
         .col_qual[lmd_loop].column_name,"_LEN = ts",trim(cnvtstring(lmd_loop))),0)
      ENDIF
     ENDIF
   ENDFOR
   CALL parser(" with nocounter go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   SET lms_pk_where = drdm_create_pk_where(lmd_qual_cnt,lms_tbl_cnt,"MD")
   IF (lms_pk_where="")
    CALL disp_msg("There was an error creating the PK_WHERE string",dm_err->logfile,0)
    RETURN(- (1))
   ENDIF
   CALL parser("select into 'nl:'",0)
   CALL parser(concat("from ",lms_src_fv,lmd_alias),0)
   CALL parser(concat(lms_pk_where," detail"),0)
   FOR (lms_lp_cnt = 1 TO dm2_ref_data_doc->tbl_qual[lmd_cnt].col_cnt)
     IF ((dm2_ref_data_doc->tbl_qual[lmd_cnt].col_qual[lms_lp_cnt].pk_ind=1)
      AND (dm2_ref_data_doc->tbl_qual[lmd_cnt].col_qual[lms_lp_cnt].root_entity_attr=dm2_ref_data_doc
     ->tbl_qual[lmd_cnt].col_qual[lms_lp_cnt].column_name)
      AND (dm2_ref_data_doc->tbl_qual[lmd_cnt].col_qual[lms_lp_cnt].root_entity_name=dm2_ref_data_doc
     ->tbl_qual[lmd_cnt].table_name))
      CALL parser(" lms_d_cnt = lms_d_cnt +1",0)
      CALL parser("stat = alterlist(lms_fv->list, lms_d_cnt)",0)
      CALL parser(concat("lms_fv->list[lms_d_cnt].table_name = '",dm2_ref_data_doc->tbl_qual[lmd_cnt]
        .table_name,"'"),0)
      CALL parser(concat("lms_fv->list[lms_d_cnt].column_name = '",dm2_ref_data_doc->tbl_qual[lmd_cnt
        ].col_qual[lms_lp_cnt].column_name,"'"),0)
      CALL parser(build("lms_fv->list[lms_d_cnt].from_value = ",lmd_alias,".",dm2_ref_data_doc->
        tbl_qual[lmd_cnt].col_qual[lms_lp_cnt].column_name),0)
     ENDIF
   ENDFOR
   CALL parser("with nocounter,notrim go",1)
   SET lms_fv->fv_cnt = lms_d_cnt
   CALL echorecord(lms_fv)
   FOR (lms_lp_pp = 1 TO lms_d_cnt)
     CALL orphan_child_tab(lms_fv->list[lms_lp_pp].table_name,lmd_log_type,lms_fv->list[lms_lp_pp].
      column_name,lms_fv->list[lms_lp_pp].from_value)
     COMMIT
     IF (locateval(lmd_log_type_idx,1,global_mover_rec->circ_nomv_excl_cnt,lmd_log_type,
      global_mover_rec->circ_nomv_qual[lmd_log_type_idx].log_type)=0)
      CALL drcm_block_ptam_circ(dm2_ref_data_doc,lmd_cnt,lms_fv->list[lms_lp_pp].column_name,lms_fv->
       list[lms_lp_pp].from_value)
      IF ((dm_err->err_ind=1))
       RETURN(- (1))
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE drcm_load_bulk_dcle(dlbd_tab_name,dlbd_tbl_cnt,dlbd_log_type,dlbd_chg_cnt)
   DECLARE dlbd_pk_col = vc WITH protect, noconstant(" ")
   DECLARE dlbd_suffix = vc WITH protect, noconstant(" ")
   DECLARE dlbd_pk_where = vc WITH protect, noconstant(" ")
   SET dlbd_pk_where = drdm_chg->log[dlbd_chg_cnt].pk_where
   SET dlbd_pk_col = dm2_ref_data_doc->tbl_qual[dlbd_tbl_cnt].root_col_name
   SET dlbd_suffix = concat("t",dm2_ref_data_doc->tbl_qual[dlbd_tbl_cnt].suffix)
   SET dm_err->eproc = "Bulk updating DM_CHG_LOG_EXCEPTION rows"
   CALL parser(concat("update into dm_chg_log_exception",dm2_ref_data_doc->post_link_name," d"),0)
   CALL parser(" set log_type = dlbd_log_type,",0)
   CALL parser(" d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_id=reqinfo->updt_id,",0)
   CALL parser(
    " d.updt_cnt = d.updt_cnt + 1, d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->updt_applctx",
    0)
   CALL parser(" where d.table_name = dlbd_tab_name and d.column_name = dlbd_pk_col",0)
   CALL parser("    and d.target_env_id = dm2_ref_data_doc->env_target_id",0)
   CALL parser(concat(" and exists (select 'x' from ",dlbd_tab_name,dm2_ref_data_doc->post_link_name,
     " ",dlbd_suffix),0)
   CALL parser(dlbd_pk_where,0)
   CALL parser(concat(" and d.from_value = ",dlbd_suffix,".",dlbd_pk_col,")"),0)
   CALL parser(" with nocounter go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = dm_err->emsg
    RETURN(- (1))
   ENDIF
   SET dm_err->eproc = "Bulk inserting DM_CHG_LOG_EXCEPTION rows"
   CALL parser(concat("insert into dm_chg_log_exception",dm2_ref_data_doc->post_link_name," d"),0)
   CALL parser("( d.log_type, d.updt_dt_tm, d.updt_id, d.updt_task, d.updt_applctx, d.table_name, ",0
    )
   CALL parser(" d.column_name, d.from_value, d.target_env_id, d.dm_chg_log_exception_id)",0)
   CALL parser(" (select dlbd_log_type, cnvtdatetime(curdate,curtime3), reqinfo->updt_id, ",0)
   CALL parser(concat(" reqinfo->updt_task, reqinfo->updt_applctx, dlbd_tab_name, dlbd_pk_col,",
     dlbd_suffix,".",dlbd_pk_col,","),0)
   CALL parser(" dm2_ref_data_doc->env_target_id, seq(rdds_source_clinical_seq,nextval) ",0)
   CALL parser(concat(" from ",dlbd_tab_name,dm2_ref_data_doc->post_link_name," ",dlbd_suffix),0)
   CALL parser(dlbd_pk_where,0)
   CALL parser(concat(" and not exists (select 'x' from dm_chg_log_exception",dm2_ref_data_doc->
     post_link_name," d2"),0)
   CALL parser(" where d2.table_name = dlbd_tab_name and d2.column_name = dlbd_pk_col",0)
   CALL parser("    and d2.target_env_id = dm2_ref_data_doc->env_target_id",0)
   CALL parser(concat(" and ",dlbd_suffix,".",dlbd_pk_col," = d2.from_value)"),0)
   CALL parser(") with nocounter go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = dm_err->emsg
    RETURN(- (1))
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE orphan_child_tab(sbr_table_name,sbr_log_type,sbr_col_name,sbr_from_value)
   DECLARE oct_tab_cnt = i4
   DECLARE oct_tab_loop = i4
   DECLARE oct_col_cnt = i4
   DECLARE oct_pk_value = f8
   DECLARE oct_excptn_tab = vc
   DECLARE oct_col_name = vc
   DECLARE oct_m_flag = i2 WITH noconstant(1)
   DECLARE oct_parent_drdm_row = i2 WITH protect, noconstant(0)
   CALL echo("Orphan_child_tab")
   IF (sbr_col_name=""
    AND sbr_from_value=0.0)
    SET oct_m_flag = 0
   ENDIF
   IF (oct_m_flag=0)
    IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name != sbr_table_name))
     SET oct_tab_cnt = locateval(oct_tab_loop,1,size(dm2_ref_data_doc->tbl_qual,5),sbr_table_name,
      dm2_ref_data_doc->tbl_qual[oct_tab_loop].table_name)
     IF (oct_tab_cnt=0)
      SET dm_err->emsg = "The table name could not be found in the meta-data record structure"
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
    SET oct_col_name = dm2_ref_data_doc->tbl_qual[oct_tab_cnt].col_qual[oct_col_cnt].column_name
   ELSE
    SET oct_pk_value = sbr_from_value
    SET oct_col_name = sbr_col_name
   ENDIF
   SET drwdr_reply->dcle_id = 0
   SET drwdr_reply->error_ind = 0
   SET drwdr_request->table_name = sbr_table_name
   SET drwdr_request->log_type = sbr_log_type
   SET drwdr_request->col_name = oct_col_name
   SET drwdr_request->from_value = oct_pk_value
   SET drwdr_request->source_env_id = dm2_ref_data_doc->env_source_id
   SET drwdr_request->target_env_id = dm2_ref_data_doc->env_target_id
   SET drwdr_request->dclei_ind = drmm_excep_flag
   EXECUTE dm_rmc_write_dcle_rows  WITH replace("REQUEST","DRWDR_REQUEST"), replace("REPLY",
    "DRWDR_REPLY")
   IF ((drwdr_reply->error_ind=1))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET drdm_error_out_ind = 1
    SET dm_err->err_ind = 0
   ENDIF
   IF ((drwdr_reply->dcle_id > 0))
    SET oct_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
    IF ((drdm_chg->log[oct_parent_drdm_row].dm_chg_log_exception_id=0))
     SET drdm_chg->log[oct_parent_drdm_row].dm_chg_log_exception_id = drwdr_reply->dcle_id
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drcm_validate(sbr_dv_t_name,sbr_dv_pk_where,sbr_dv_table_cnt)
   DECLARE dv_col_loop = i4
   DECLARE dv_dummy_cnt = i4
   DECLARE dv_md_col_cnt = i4
   DECLARE dv_pkw_col_cnt = i4
   DECLARE dv_pk_col_cnt = i4
   DECLARE dv_and_cnt = i4
   DECLARE dv_and_pos = i4
   DECLARE dv_end_ind = i2
   DECLARE dv_fix_ind = i2
   DECLARE dv_qual_cnt = i4
   DECLARE dv_pk_where_stmt = vc
   DECLARE dv_type = vc
   DECLARE dv_ret_cnt = i4
   DECLARE dv_col_value = vc
   DECLARE dv_delim_start = i4
   DECLARE dv_delim_stop = i4
   DECLARE dv_delim_pos1 = i4
   DECLARE dv_delim_pos2 = i4
   DECLARE dv_delim_pos3 = i4
   DECLARE dv_delim_val = vc
   DECLARE dv_filter_ret = i2
   DECLARE dv_sc_ind = i2
   DECLARE dv_str1_pos = i4
   DECLARE dv_str2_pos = i4
   DECLARE dv_str3_pos = i4
   DECLARE dv_str4_pos = i4
   DECLARE dv_uc_pk_where = vc
   DECLARE dv_src_tab_name = vc
   DECLARE ver_tab_ind = i2
   DECLARE dv_t_suff_str = vc
   SET dv_t_suff_str = concat(" AND t",dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].suffix)
   SET dv_qual_cnt = 0
   SET dv_filter_ret = filter_proc_call(sbr_dv_t_name,sbr_dv_pk_where)
   IF (dv_filter_ret=0)
    RETURN(- (4))
   ENDIF
   IF (sbr_dv_t_name="SEG_GRP_SEQ_R")
    SET dv_uc_pk_where = cnvtupper(sbr_dv_pk_where)
    SET dv_str1_pos = findstring("(SELECT",dv_uc_pk_where,1)
    SET dv_str2_pos = findstring("SEGMENT_REFERENCE",dv_uc_pk_where,dv_str1_pos)
    SET dv_str3_pos = findstring("(SELECT",dv_uc_pk_where,dv_str2_pos)
    SET dv_str4_pos = findstring("SEGMENT_REFERENCE",dv_uc_pk_where,dv_str3_pos)
    IF (dv_str4_pos=0)
     RETURN(- (2))
    ELSE
     SET dv_src_tab_name = dm2_get_rdds_tname("SEGMENT_REFERENCE")
     SET drdm_chg->log[drdm_log_loop].pk_where = replace(cnvtupper(drdm_chg->log[drdm_log_loop].
       pk_where),"SEGMENT_REFERENCE",dv_src_tab_name,0)
     RETURN(drdm_log_loop)
    ENDIF
   ENDIF
   IF ((dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].merge_delete_ind=1))
    FOR (dv_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].col_qual[dv_col_loop].merge_delete_ind=1))
       SET dv_md_col_cnt = (dv_md_col_cnt+ 1)
       IF (((findstring(concat(dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].col_qual[dv_col_loop].
         column_name," "),sbr_dv_pk_where,1,0) > 0) OR (findstring(concat(dm2_ref_data_doc->tbl_qual[
         sbr_dv_table_cnt].col_qual[dv_col_loop].column_name,"="),sbr_dv_pk_where,1,0) > 0)) )
        SET dv_pkw_col_cnt = (dv_pkw_col_cnt+ 1)
       ENDIF
      ENDIF
    ENDFOR
    IF (dv_md_col_cnt=0)
     CALL disp_msg(concat("There were no MD columns defined for the current table: ",sbr_dv_t_name),
      dm_err->logfile,1)
     RETURN(- (1))
    ENDIF
    IF (dv_pkw_col_cnt=dv_md_col_cnt)
     SET dv_and_cnt = 0
     SET dv_and_pos = 0
     WHILE (dv_end_ind=0)
       SET dv_dummy_cnt = 0
       SET dv_dummy_cnt = findstring(dv_t_suff_str,sbr_dv_pk_where,dv_and_pos,0)
       IF (dv_dummy_cnt=0)
        SET dv_end_ind = 1
       ELSE
        SET dv_and_cnt = (dv_and_cnt+ 1)
        SET dv_and_pos = (dv_dummy_cnt+ 3)
       ENDIF
     ENDWHILE
     IF (dv_and_cnt > 0)
      SET dv_and_position = 0
      SET dv_dummy_cnt = 1
      WHILE (dv_dummy_cnt > 0)
       SET dv_dummy_cnt = findstring("=",sbr_dv_pk_where,dv_and_position,0)
       IF (dv_dummy_cnt > 0)
        SET dv_delim_pos1 = findstring("'",sbr_dv_pk_where,dv_dummy_cnt,0)
        SET dv_delim_pos2 = findstring('"',sbr_dv_pk_where,dv_dummy_cnt,0)
        SET dv_delim_pos3 = findstring("^",sbr_dv_pk_where,dv_dummy_cnt,0)
        IF (dv_delim_pos1=0)
         SET dv_delim_pos1 = size(sbr_dv_pk_where)
        ENDIF
        IF (dv_delim_pos2=0)
         SET dv_delim_pos2 = size(sbr_dv_pk_where)
        ENDIF
        IF (dv_delim_pos3=0)
         SET dv_delim_pos3 = size(sbr_dv_pk_where)
        ENDIF
        IF (dv_delim_pos1 < dv_delim_pos2)
         IF (dv_delim_pos1 < dv_delim_pos3)
          SET dv_delim_val = "'"
          SET dv_delim_start = dv_delim_pos1
         ELSE
          SET dv_delim_val = "^"
          SET dv_delim_start = dv_delim_pos3
         ENDIF
        ELSE
         IF (dv_delim_pos2 < dv_delim_pos3)
          SET dv_delim_val = '"'
          SET dv_delim_start = dv_delim_pos2
         ELSE
          SET dv_delim_val = "^"
          SET dv_delim_start = dv_delim_pos3
         ENDIF
        ENDIF
        IF (dv_delim_start < size(sbr_dv_pk_where))
         SET dv_delim_stop = findstring(dv_delim_val,sbr_dv_pk_where,(dv_delim_start+ 1),0)
         IF (dv_delim_stop > 0)
          SET dv_col_value = substring((dv_delim_start+ 1),(dv_delim_stop - (dv_delim_start+ 1)),
           sbr_dv_pk_where)
          IF (findstring(dv_t_suff_str,dv_col_value,0,0) > 0)
           SET dv_and_cnt = (dv_and_cnt - 1)
          ENDIF
          SET dv_and_position = (dv_delim_stop+ 1)
         ELSE
          SET dv_fix_ind = 1
         ENDIF
        ELSE
         SET dv_and_position = dv_delim_start
        ENDIF
       ENDIF
      ENDWHILE
     ENDIF
     IF ((dv_and_cnt != (dv_md_col_cnt - 1)))
      SET dv_fix_ind = 1
     ENDIF
    ELSE
     SET dv_fix_ind = 1
    ENDIF
    IF (dv_fix_ind=1)
     RETURN(- (1))
    ELSE
     SET dv_ret_cnt = drdm_log_loop
    ENDIF
   ELSE
    SET dv_pkw_col_cnt = 0
    FOR (dv_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].col_cnt)
     IF ((((dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].table_name="DCP_FORMS_REF")) OR ((
     dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].table_name="DCP_SECTION_REF"))) )
      SET ver_tab_ind = 1
     ELSEIF ((dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].version_ind=1))
      IF ((((dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].version_type="ALG1")) OR ((((
      dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].version_type="ALG3")) OR ((((dm2_ref_data_doc->
      tbl_qual[sbr_dv_table_cnt].version_type="ALG3D")) OR ((dm2_ref_data_doc->tbl_qual[
      sbr_dv_table_cnt].version_type="ALG4"))) )) )) )
       SET ver_tab_ind = 1
      ENDIF
     ENDIF
     IF (ver_tab_ind=1)
      IF ((dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].col_qual[dv_col_loop].unique_ident_ind=1))
       SET dv_pk_col_cnt = (dv_pk_col_cnt+ 1)
       IF (((findstring(concat(dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].col_qual[dv_col_loop].
         column_name," "),sbr_dv_pk_where,1,0) > 0) OR (findstring(concat(dm2_ref_data_doc->tbl_qual[
         sbr_dv_table_cnt].col_qual[dv_col_loop].column_name,"="),sbr_dv_pk_where,1,0) > 0)) )
        SET dv_pkw_col_cnt = (dv_pkw_col_cnt+ 1)
       ENDIF
      ENDIF
     ELSE
      IF ((dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].col_qual[dv_col_loop].pk_ind=1))
       SET dv_pk_col_cnt = (dv_pk_col_cnt+ 1)
       IF (((findstring(concat(dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].col_qual[dv_col_loop].
         column_name," "),sbr_dv_pk_where,1,0) > 0) OR (findstring(concat(dm2_ref_data_doc->tbl_qual[
         sbr_dv_table_cnt].col_qual[dv_col_loop].column_name,"="),sbr_dv_pk_where,1,0) > 0)) )
        SET dv_pkw_col_cnt = (dv_pkw_col_cnt+ 1)
       ENDIF
      ENDIF
     ENDIF
    ENDFOR
    IF (dv_pk_col_cnt=0)
     CALL disp_msg(concat("There were no PK columns defined for the current table: ",sbr_dv_t_name),
      dm_err->logfile,1)
     RETURN(- (5))
    ENDIF
    IF (dv_pkw_col_cnt=dv_pk_col_cnt)
     SET dv_and_cnt = 0
     SET dv_and_pos = 0
     WHILE (dv_end_ind=0)
       SET dv_dummy_cnt = 0
       SET dv_dummy_cnt = findstring(dv_t_suff_str,sbr_dv_pk_where,dv_and_pos,0)
       IF (dv_dummy_cnt=0)
        SET dv_end_ind = 1
       ELSE
        SET dv_and_cnt = (dv_and_cnt+ 1)
        SET dv_and_pos = (dv_dummy_cnt+ 3)
       ENDIF
     ENDWHILE
     IF (dv_and_cnt > 0)
      SET dv_and_position = 0
      SET dv_dummy_cnt = 1
      WHILE (dv_dummy_cnt > 0)
       SET dv_dummy_cnt = findstring("=",sbr_dv_pk_where,dv_and_position,0)
       IF (dv_dummy_cnt > 0)
        SET dv_delim_pos1 = findstring("'",sbr_dv_pk_where,dv_dummy_cnt,0)
        SET dv_delim_pos2 = findstring('"',sbr_dv_pk_where,dv_dummy_cnt,0)
        SET dv_delim_pos3 = findstring("^",sbr_dv_pk_where,dv_dummy_cnt,0)
        IF (dv_delim_pos1=0)
         SET dv_delim_pos1 = size(sbr_dv_pk_where)
        ENDIF
        IF (dv_delim_pos2=0)
         SET dv_delim_pos2 = size(sbr_dv_pk_where)
        ENDIF
        IF (dv_delim_pos3=0)
         SET dv_delim_pos3 = size(sbr_dv_pk_where)
        ENDIF
        IF (dv_delim_pos1 < dv_delim_pos2)
         IF (dv_delim_pos1 < dv_delim_pos3)
          SET dv_delim_val = "'"
          SET dv_delim_start = dv_delim_pos1
         ELSE
          SET dv_delim_val = "^"
          SET dv_delim_start = dv_delim_pos3
         ENDIF
        ELSE
         IF (dv_delim_pos2 < dv_delim_pos3)
          SET dv_delim_val = '"'
          SET dv_delim_start = dv_delim_pos2
         ELSE
          SET dv_delim_val = "^"
          SET dv_delim_start = dv_delim_pos3
         ENDIF
        ENDIF
        IF (dv_delim_start < size(sbr_dv_pk_where))
         SET dv_delim_stop = findstring(dv_delim_val,sbr_dv_pk_where,(dv_delim_start+ 1),0)
         IF (dv_delim_stop > 0)
          SET dv_col_value = substring((dv_delim_start+ 1),(dv_delim_stop - (dv_delim_start+ 1)),
           sbr_dv_pk_where)
          IF (findstring(dv_t_suff_str,dv_col_value,0,0) > 0)
           SET dv_and_cnt = (dv_and_cnt - 1)
          ENDIF
          SET dv_and_position = (dv_delim_stop+ 1)
         ELSE
          SET dv_fix_ind = 1
         ENDIF
        ELSE
         SET dv_and_position = dv_delim_start
        ENDIF
       ENDIF
      ENDWHILE
     ENDIF
     IF ((dv_and_cnt != (dv_pk_col_cnt - 1)))
      SET dv_fix_ind = 1
     ENDIF
    ELSE
     SET dv_fix_ind = 1
    ENDIF
    IF (dv_fix_ind=1)
     RETURN(- (2))
    ELSE
     SET dv_ret_cnt = drdm_log_loop
    ENDIF
   ENDIF
   RETURN(dv_ret_cnt)
 END ;Subroutine
 SUBROUTINE find_nvld_value(fnv_value,fnv_table,fnv_from_value)
   DECLARE fnv_return = vc
   DECLARE fnv_from_tab = vc
   DECLARE fnv_find_val = vc
   DECLARE fnv_tbl_name = vc
   DECLARE fnv_loc = i4
   DECLARE fnv_idx = i4
   IF (fnv_value != "0"
    AND fnv_from_value="0")
    SET fnv_from_tab = "dm_refchg_invalid_xlat"
    SET fnv_find_val = fnv_value
    SET fnv_tbl_name = trim(fnv_table)
   ELSEIF (fnv_value="0"
    AND fnv_from_value != "0")
    SET fnv_from_tab = concat("dm_refchg_invalid_xlat",dm2_ref_data_doc->post_link_name)
    SET fnv_tbl_name = concat(trim(fnv_table),dm2_ref_data_doc->post_link_name)
    SET fnv_find_val = fnv_from_value
   ENDIF
   SELECT
    IF (fnv_table IN ("PERSON", "PRSNL"))
     WHERE parent_entity_name IN ("PERSON", "PRSNL")
      AND parent_entity_id=cnvtreal(fnv_find_val)
    ELSE
     WHERE parent_entity_name=fnv_table
      AND parent_entity_id=cnvtreal(fnv_find_val)
    ENDIF
    INTO "nl:"
    FROM (parser(fnv_from_tab))
    WITH nocounter
   ;end select
   IF (check_error("Checking for invalid translation")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    SET drdm_error_out_ind = 1
   ENDIF
   IF (curqual != 0)
    IF ((multi_col_pk->table_cnt > 0))
     SET fnv_loc = locateval(fnv_idx,1,multi_col_pk->table_cnt,trim(fnv_table),multi_col_pk->qual[
      fnv_idx].table_name)
     IF (fnv_loc != 0)
      SELECT INTO "nl:"
       FROM (parser(fnv_tbl_name) d)
       WHERE parser(concat("d.",trim(multi_col_pk->qual[fnv_idx].column_name)," =",fnv_find_val))
       WITH nocounter
      ;end select
      IF (check_error("Checking for invalid translation")=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 1
       SET drdm_error_out_ind = 1
      ENDIF
      IF (curqual=0)
       SET fnv_return = "No Trans"
      ELSE
       SET fnv_return = fnv_find_val
       DELETE  FROM (parser(fnv_from_tab))
        WHERE parent_entity_name=fnv_table
         AND parent_entity_id=cnvtreal(fnv_find_val)
        WITH nocounter
       ;end delete
       IF (check_error("Checking for invalid translation")=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        SET dm_err->err_ind = 1
        SET drdm_error_out_ind = 1
       ENDIF
      ENDIF
     ELSE
      SET fnv_return = "No Trans"
     ENDIF
    ELSE
     SET fnv_return = "No Trans"
    ENDIF
   ELSE
    SET fnv_return = fnv_find_val
   ENDIF
   RETURN(fnv_return)
 END ;Subroutine
 SUBROUTINE check_backfill(i_source_id,i_table_name,i_tbl_pos)
   DECLARE cb_ret_val = c1 WITH protect, noconstant("F")
   DECLARE cb_loop = i4 WITH protect
   DECLARE cb_seq_name = vc WITH protect
   DECLARE cb_seq_num = f8 WITH protect
   DECLARE cb_cur_table = i4 WITH protect
   DECLARE cb_info_domain = vc WITH protect
   DECLARE cb_pause_ind = i2 WITH protect, noconstant(1)
   DECLARE cb_seq_loop = i4 WITH protect
   DECLARE cb_rdb_handle = f8 WITH protect
   DECLARE cb_seq_val = i4 WITH protect
   DECLARE cb_refchg_type = vc WITH protect, noconstant("")
   DECLARE cb_refchg_status = vc WITH protect, noconstant("")
   IF (i_table_name="REF_TEXT_RELTN")
    SET cb_seq_name = "REFERENCE_SEQ"
   ELSE
    FOR (cb_loop = 1 TO dm2_ref_data_doc->tbl_qual[i_tbl_pos].col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[i_tbl_pos].col_qual[cb_loop].pk_ind=1)
       AND (dm2_ref_data_doc->tbl_qual[i_tbl_pos].col_qual[cb_loop].root_entity_name=i_table_name))
       IF (i_table_name="APPLICATION_TASK")
        SET cb_seq_name = "APPLICATION_TASK"
       ELSE
        SET cb_seq_name = dm2_ref_data_doc->tbl_qual[i_tbl_pos].col_qual[cb_loop].sequence_name
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF (cb_seq_name="")
    CALL disp_msg("Check_Backfill: No Valid sequence was found",dm_err->logfile,1)
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = "No Valid sequence was found"
    SET dm_err->err_ind = 0
    CALL merge_audit("FAILREASON","No Valid sequence was found",3)
    RETURN(cb_ret_val)
   ENDIF
   SET cb_seq_val = locateval(cb_seq_loop,1,size(drdm_sequence->qual,5),cb_seq_name,drdm_sequence->
    qual[cb_seq_loop].seq_name)
   IF (cb_seq_val=0
    AND i_table_name != "APPLICATION_TASK")
    SELECT
     IF ((dm2_rdds_rec->mode="OS"))
      WHERE d.info_domain="MERGE00SEQMATCH"
       AND d.info_name=cb_seq_name
     ELSE
      WHERE d.info_domain=concat("MERGE",trim(cnvtstring(dm2_ref_data_doc->env_source_id,20)),trim(
        cnvtstring(dm2_ref_data_doc->mock_target_id,20)),"SEQMATCH")
       AND d.info_name=cb_seq_name
     ENDIF
     INTO "NL:"
     FROM dm_info d
     DETAIL
      cb_seq_num = d.info_number
     WITH nocounter
    ;end select
    IF (check_error(concat("CHECK_BACKFILL: ",dm_err->eproc))=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm2_ref_data_reply->error_ind = 1
     SET dm2_ref_data_reply->error_msg = dm_err->emsg
     SET dm_err->err_ind = 0
     RETURN(cb_ret_val)
    ENDIF
    IF (((curqual=0) OR ((cb_seq_num=- (1)))) )
     SET cb_cur_table = temp_tbl_cnt
     ROLLBACK
     SET drmm_ddl_rollback_ind = 1
     EXECUTE dm2_noupdt_seq_match cb_seq_name, dm2_ref_data_doc->env_source_id
     SET temp_tbl_cnt = cb_cur_table
     IF ((dm_err->err_ind=1))
      CALL disp_msg(concat("CHECK_BACKFILL: ",dm_err->emsg),dm_err->logfile,1)
      SET dm2_ref_data_reply->error_ind = 1
      SET dm2_ref_data_reply->error_msg = dm_err->emsg
      SET dm_err->err_ind = 1
      SET drdm_error_ind = 1
      RETURN(cb_ret_val)
     ENDIF
     SELECT
      IF ((dm2_rdds_rec->mode="OS"))
       WHERE d.info_domain="MERGE00SEQMATCH"
        AND d.info_name=cb_seq_name
      ELSE
       WHERE d.info_domain=concat("MERGE",trim(cnvtstring(dm2_ref_data_doc->env_source_id,20)),trim(
         cnvtstring(dm2_ref_data_doc->mock_target_id,20)),"SEQMATCH")
        AND d.info_name=cb_seq_name
      ENDIF
      INTO "NL:"
      FROM dm_info d
      DETAIL
       cb_seq_num = d.info_number
      WITH nocounter
     ;end select
     IF (check_error(concat("CHECK_BACKFILL: ",dm_err->eproc))=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm2_ref_data_reply->error_ind = 1
      SET dm2_ref_data_reply->error_msg = dm_err->emsg
      RETURN(cb_ret_val)
     ENDIF
     IF (curqual=0)
      SET drdm_error_out_ind = 1
      SET dm2_ref_data_reply->error_ind = 1
      SET dm2_ref_data_reply->error_msg =
      "CHECK_BACKFILL: A sequence match could not be found in DM_INFO"
      CALL disp_msg("A sequence match could not be found in DM_INFO",dm_err->logfile,1)
      RETURN("F")
     ENDIF
    ENDIF
    SET drdm_sequence->qual_cnt = (drdm_sequence->qual_cnt+ 1)
    SET stat = alterlist(drdm_sequence->qual,drdm_sequence->qual_cnt)
    SET drdm_sequence->qual[drdm_sequence->qual_cnt].seq_name = cb_seq_name
    SET drdm_sequence->qual[drdm_sequence->qual_cnt].seq_val = cb_seq_num
    SET cb_seq_val = drdm_sequence->qual_cnt
   ELSE
    IF (i_table_name="APPLICATION_TASK")
     IF (cb_seq_val=0)
      SET drdm_sequence->qual_cnt = (drdm_sequence->qual_cnt+ 1)
      SET stat = alterlist(drdm_sequence->qual,drdm_sequence->qual_cnt)
      SET drdm_sequence->qual[drdm_sequence->qual_cnt].seq_name = "APPLICATION_TASK"
      SET drdm_sequence->qual[drdm_sequence->qual_cnt].seq_val = 0
      SET cb_seq_val = drdm_sequence->qual_cnt
     ENDIF
     SET cb_seq_num = 0
    ELSE
     SET cb_seq_num = drdm_sequence->qual[cb_seq_val].seq_val
    ENDIF
   ENDIF
   IF (cb_seq_num=0)
    IF ((drdm_sequence->qual[cb_seq_val].seqmatch_ind=0))
     SELECT INTO "nl"
      FROM dm_info di
      WHERE di.info_domain=concat("MERGE",trim(cnvtstring(dm2_ref_data_doc->env_source_id,20)),trim(
        cnvtstring(dm2_ref_data_doc->mock_target_id,20)),"SEQMATCHDONE2")
       AND di.info_name=cb_seq_name
      WITH nocounter
     ;end select
     IF (check_error(concat("CHECK_BACKFILL: ",dm_err->eproc))=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm2_ref_data_reply->error_ind = 1
      SET dm2_ref_data_reply->error_msg = dm_err->emsg
      RETURN(cb_ret_val)
     ENDIF
     IF (curqual != 0)
      SET cb_ret_val = "S"
      SET drdm_sequence->qual[cb_seq_val].seqmatch_ind = 1
      RETURN(cb_ret_val)
     ENDIF
    ELSEIF ((drdm_sequence->qual[cb_seq_val].seqmatch_ind=1))
     SET cb_ret_val = "S"
     RETURN(cb_ret_val)
    ENDIF
   ENDIF
   SET cb_info_domain = concat("XLAT BACKFILL",trim(cnvtstring(i_source_id,20)),trim(cnvtstring(
      dm2_ref_data_doc->mock_target_id,20)))
   WHILE (cb_pause_ind=1)
     SET cb_pause_ind = 0
     ROLLBACK
     SET drl_reply->status = ""
     SET drl_reply->status_msg = ""
     CALL get_lock(cb_info_domain,cb_seq_name,0,drl_reply)
     IF ((drl_reply->status="F"))
      CALL disp_msg(drl_reply->status_msg,dm_err->logfile,1)
      SET dm2_ref_data_reply->error_ind = 1
      SET dm2_ref_data_reply->error_msg = drl_reply->status_msg
      RETURN(cb_ret_val)
     ELSEIF ((drl_reply->status="Z"))
      SET cb_pause_ind = 1
     ELSE
      COMMIT
     ENDIF
     IF (cb_pause_ind=1)
      CALL echo("")
      CALL echo("")
      CALL echo("**************BACKFILL IN PROGRESS. WAIT 60 SECONDS AND TRY AGAIN***************")
      CALL echo("")
      CALL echo("")
      CALL disp_msg("********BACKFILL IN PROGRESS. WAIT 60 SECONDS AND TRY AGAIN*********",dm_err->
       logfile,0)
      CALL pause(60)
      SELECT
       IF ((dm2_rdds_rec->mode="OS"))
        WHERE d.info_domain="MERGE00SEQMATCH"
         AND d.info_name=cb_seq_name
       ELSE
        WHERE d.info_domain=concat("MERGE",trim(cnvtstring(dm2_ref_data_doc->env_source_id,20)),trim(
          cnvtstring(dm2_ref_data_doc->mock_target_id,20)),"SEQMATCH")
         AND d.info_name=cb_seq_name
       ENDIF
       INTO "NL:"
       FROM dm_info d
       DETAIL
        cb_seq_num = d.info_number
       WITH nocounter
      ;end select
      IF (check_error(concat("CHECK_BACKFILL: ",dm_err->eproc))=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm2_ref_data_reply->error_ind = 1
       SET dm2_ref_data_reply->error_msg = dm_err->emsg
       RETURN(cb_ret_val)
      ENDIF
      IF (cb_seq_num=0)
       SET cb_ret_val = "S"
       RETURN(cb_ret_val)
      ENDIF
     ENDIF
   ENDWHILE
   SET dm_err->eproc = "Gathering information from dm_refchg_process."
   SELECT INTO "nl:"
    FROM dm_refchg_process d
    WHERE d.rdbhandle_value=cnvtreal(currdbhandle)
    DETAIL
     cb_refchg_type = d.refchg_type, cb_refchg_status = d.refchg_status
    WITH nocounter
   ;end select
   IF (check_error(concat("CHECK_BACKFILL: ",dm_err->eproc))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = dm_err->emsg
    RETURN(cb_ret_val)
   ENDIF
   CALL add_tracking_row(i_source_id,cb_refchg_type,"XLAT BCKFLL RUNNING")
   IF (cb_seq_name="APPLICATION_TASK")
    CALL seqmatch_xlats("",i_source_id,"APPLICATION_TASK")
   ELSE
    CALL seqmatch_xlats(cb_seq_name,i_source_id,"")
   ENDIF
   CALL add_tracking_row(i_source_id,cb_refchg_type,cb_refchg_status)
   SET drl_reply->status = ""
   SET drl_reply->status_msg = ""
   CALL remove_lock(cb_info_domain,cb_seq_name,currdbhandle,drl_reply)
   COMMIT
   IF (check_error(concat("CHECK_BACKFILL: ",dm_err->eproc))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = dm_err->emsg
    RETURN(cb_ret_val)
   ENDIF
   IF (cb_seq_name != "APPLICATION_TASK")
    SET drdm_sequence->qual[cb_seq_val].seq_val = 0
   ENDIF
   SET cb_ret_val = "S"
   RETURN(cb_ret_val)
 END ;Subroutine
 SUBROUTINE redirect_to_start_row(rsr_drdm_chg,rsr_log_pos,rsr_next_row,rsr_max_size)
   DECLARE rsr_done_ind = i2
   DECLARE rsr_cur_pos = i4
   DECLARE rsr_loop = i4
   DECLARE rsr_size = i4
   DECLARE rsr_eraseable = i2
   DECLARE rsr_next_pos = i4
   SET rsr_size = size(rsr_drdm_chg->log,5)
   IF (rsr_log_pos > drdm_log_cnt)
    SET rsr_eraseable = 1
   ENDIF
   WHILE (rsr_done_ind=0)
     SET rsr_cur_pos = 0
     FOR (rsr_loop = 1 TO rsr_size)
       IF (rsr_log_pos <= drdm_log_cnt)
        IF ((rsr_drdm_chg->log[rsr_loop].next_to_process=rsr_log_pos)
         AND rsr_loop <= drdm_log_cnt)
         SET rsr_cur_pos = rsr_loop
         SET rsr_loop = rsr_size
        ENDIF
       ELSE
        IF ((rsr_drdm_chg->log[rsr_loop].next_to_process=rsr_log_pos)
         AND (rsr_drdm_chg->log[rsr_loop].table_name > ""))
         SET rsr_cur_pos = rsr_loop
         SET rsr_loop = rsr_size
        ENDIF
       ENDIF
     ENDFOR
     IF (rsr_cur_pos > 0)
      SET rsr_log_pos = rsr_cur_pos
      IF ((rsr_drdm_chg->log[rsr_log_pos].commit_ind=1))
       SET rsr_log_pos = rsr_drdm_chg->log[rsr_log_pos].next_to_process
       SET rsr_done_ind = 1
      ENDIF
     ELSE
      SET rsr_done_ind = 1
     ENDIF
   ENDWHILE
   SET drdm_mini_loop_status = ""
   SET drdm_no_trans_ind = 1
   SET nodelete_ind = 1
   SET no_insert_update = 1
   SET stat = alterlist(missing_xlats->qual,0)
   SET drmm_ddl_rollback_ind = 1
   IF (rsr_next_row > rsr_max_size)
    SET rsr_max_size = (rsr_max_size+ 10)
    SET stat = alterlist(rsr_drdm_chg->log,rsr_max_size)
   ENDIF
   CALL reinitialize_drdm(rsr_next_row)
   IF (rsr_eraseable=1
    AND rsr_log_pos <= drdm_log_cnt)
    SET rsr_done_ind = 0
    SET rsr_next_pos = rsr_log_pos
    WHILE (rsr_done_ind=0)
     SET rsr_drdm_chg->log[rsr_next_pos].exploded_ind = 0
     IF ((rsr_drdm_chg->log[rsr_next_pos].next_to_process=0))
      SET rsr_done_ind = 1
     ELSE
      SET rsr_next_pos = rsr_drdm_chg->log[rsr_next_pos].next_to_process
     ENDIF
    ENDWHILE
   ENDIF
   SET rsr_drdm_chg->log[rsr_next_row].next_to_process = rsr_log_pos
   SET rsr_next_row = (rsr_next_row+ 1)
   RETURN((rsr_next_row - 1))
 END ;Subroutine
 SUBROUTINE get_multi_col_pk(null)
  IF ((multi_col_pk->table_cnt=0))
   SET dm_err->eproc = "Obtaining a list of tables with multi-column pk"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="RDDS ROOT ENTITY MULTI COLUMN PK"
    HEAD REPORT
     multi_col_pk->table_cnt = 0
    DETAIL
     multi_col_pk->table_cnt = (multi_col_pk->table_cnt+ 1), stat = alterlist(multi_col_pk->qual,
      multi_col_pk->table_cnt), multi_col_pk->qual[multi_col_pk->table_cnt].table_name = di.info_name,
     multi_col_pk->qual[multi_col_pk->table_cnt].column_name = di.info_char
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE find_original_log_row(i_drdm_chg_rs,i_pos)
   DECLARE folr_done_ind = i2 WITH protect, noconstant(0)
   DECLARE folr_pos = i4 WITH protect, noconstant(i_pos)
   WHILE (folr_done_ind=0)
    SET folr_done_ind = i_drdm_chg_rs->log[folr_pos].commit_ind
    IF (folr_done_ind=0)
     SET folr_pos = i_drdm_chg_rs->log[folr_pos].next_to_process
     IF (folr_pos=0)
      SET folr_pos = i_pos
      SET folr_done_ind = 1
     ENDIF
    ENDIF
   ENDWHILE
   RETURN(folr_pos)
 END ;Subroutine
 SUBROUTINE add_single_pass_dcl_row(i_table_name,i_pk_string,i_single_pass_log_id,i_context_name)
   DECLARE v_tpd_log_id = f8 WITH protect, noconstant(0.0)
   DECLARE v_dcl = vc WITH protect, constant(dm2_get_rdds_tname("DM_CHG_LOG"))
   SET v_tpd_log_id = trigger_proc_dcl(0.0,i_table_name,i_pk_string,0,i_single_pass_log_id,
    "PROCES",i_context_name)
   IF (v_tpd_log_id > 0)
    UPDATE  FROM (parser(v_dcl) d)
     SET d.rdbhandle = currdbhandle, d.single_pass_log_id = i_single_pass_log_id, d.log_type =
      "PROCES",
      d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE d.log_id=v_tpd_log_id
      AND d.log_type != "PROCES"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET v_tpd_log_id = - (1)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   RETURN(v_tpd_log_id)
 END ;Subroutine
 SUBROUTINE fill_cur_state_rs(fcsr_tab_name)
   DECLARE fcsr_tab_pos = i4 WITH protect, noconstant(0)
   DECLARE fcsr_num = i4 WITH protect, noconstant(0)
   DECLARE fcsr_cnt = i4 WITH protect, noconstant(0)
   DECLARE fcsr_pkw = vc
   DECLARE fcsr_str1_pos = i4
   DECLARE fcsr_str2_pos = i4
   DECLARE fcsr_str3_pos = i4
   DECLARE fcsr_done_end = i2
   DECLARE fcsr_open_cnt = i4
   DECLARE fcsr_close_cnt = i4
   DECLARE fcsr_temp = i4 WITH protect, noconstant(0)
   DECLARE fcsr_temp2 = i4 WITH protect, noconstant(0)
   DECLARE fcsr_delim1 = i4
   DECLARE fcsr_delim2 = i4
   SET fcsr_tab_pos = locateval(fcsr_num,1,cur_state_tabs->total,fcsr_tab_name,cur_state_tabs->qual[
    fcsr_num].table_name)
   IF (fcsr_tab_pos > 0)
    RETURN(fcsr_tab_pos)
   ENDIF
   SET cur_state_tabs->total = (cur_state_tabs->total+ 1)
   SET stat = alterlist(cur_state_tabs->qual,cur_state_tabs->total)
   SET cur_state_tabs->qual[cur_state_tabs->total].table_name = fcsr_tab_name
   SET dm_err->eproc = "Gathering current state PE info."
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="RDDS CURRENT STATE TABLES"
     AND d.info_name=patstring(concat(fcsr_tab_name,"*"))
    HEAD REPORT
     fcsr_cnt = 0
    DETAIL
     cur_state_tabs->qual[cur_state_tabs->total].parent_tab_col = d.info_char, fcsr_cnt = (fcsr_cnt+
     1), stat = alterlist(cur_state_tabs->qual[cur_state_tabs->total].parent_qual,fcsr_cnt),
     fcsr_temp = findstring(":",d.info_name), fcsr_temp2 = findstring(":",d.info_name,(fcsr_temp+ 1))
     IF (fcsr_temp2 > 0)
      cur_state_tabs->qual[cur_state_tabs->total].parent_qual[fcsr_cnt].parent_table = substring((
       fcsr_temp+ 1),(fcsr_temp2 - (fcsr_temp+ 1)),d.info_name)
     ELSE
      cur_state_tabs->qual[cur_state_tabs->total].parent_qual[fcsr_cnt].parent_table = substring((
       fcsr_temp+ 1),(size(trim(d.info_name),1) - fcsr_temp),d.info_name)
     ENDIF
     fcsr_temp = findstring(":",d.info_name,1,1), cur_state_tabs->qual[cur_state_tabs->total].
     parent_qual[fcsr_cnt].top_level_parent = substring((fcsr_temp+ 1),(size(trim(d.info_name),1) -
      fcsr_temp),d.info_name)
    FOOT REPORT
     cur_state_tabs->qual[cur_state_tabs->total].parent_cnt = fcsr_cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET fcsr_tab_pos = cur_state_tabs->total
   RETURN(fcsr_tab_pos)
 END ;Subroutine
 SUBROUTINE drdm_hash_validate(sbr_dv_t_name,sbr_dv_pk_where,sbr_dv_table_cnt,sbr_dv_pkw_hash,
  sbr_dv_ptam_hash,sbr_dv_delete_ind,sbr_updt_applctx)
   DECLARE dv_ret_cnt = i4
   DECLARE dhv_pk_where = vc WITH protect, noconstant("")
   DECLARE dhv_filter_ret = i4 WITH protect, noconstant(0)
   IF (((sbr_dv_delete_ind=0
    AND (sbr_dv_pkw_hash != dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].pk_where_hash)) OR (
   sbr_dv_delete_ind=1
    AND (sbr_dv_pkw_hash != dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].del_pk_where_hash))) )
    RETURN(- (1))
   ENDIF
   IF ((sbr_dv_ptam_hash != dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].ptam_match_hash))
    RETURN(- (2))
   ENDIF
   SET dhv_pk_where = sbr_dv_pk_where
   IF ((((dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].version_ind=0)) OR ((dm2_ref_data_doc->
   tbl_qual[sbr_dv_table_cnt].version_ind=1)
    AND  NOT ((dm2_ref_data_doc->tbl_qual[sbr_dv_table_cnt].version_type IN ("ALG1", "ALG3", "ALG3D",
   "ALG4", "ALG5",
   "ALG6", "ALG7"))))) )
    SET dhv_filter_ret = filter_proc_call(sbr_dv_t_name,dhv_pk_where,sbr_updt_applctx)
    IF (dhv_filter_ret=0)
     RETURN(- (4))
    ENDIF
   ENDIF
   RETURN(drdm_log_loop)
 END ;Subroutine
 SUBROUTINE fill_hold_excep_rs(null)
  FOR (i = 1 TO drmm_hold_exception->value_cnt)
    SET drwdr_reply->dcle_id = 0
    SET drwdr_reply->error_ind = 0
    SET drwdr_request->table_name = drmm_hold_exception->qual[i].table_name
    SET drwdr_request->log_type = drmm_hold_exception->qual[i].log_type
    SET drwdr_request->col_name = drmm_hold_exception->qual[i].column_name
    SET drwdr_request->from_value = drmm_hold_exception->qual[i].from_value
    SET drwdr_request->source_env_id = dm2_ref_data_doc->env_source_id
    SET drwdr_request->target_env_id = dm2_ref_data_doc->env_target_id
    SET drwdr_request->dclei_ind = drmm_excep_flag
    SET drwdr_request->dcl_excep_id = drmm_hold_exception->qual[i].dcl_excep_id
    EXECUTE dm_rmc_write_dcle_rows  WITH replace("REQUEST","DRWDR_REQUEST"), replace("REPLY",
     "DRWDR_REPLY")
    SET drwdr_request->dcl_excep_id = 0
  ENDFOR
  SET stat = initrec(drmm_hold_exception)
 END ;Subroutine
 SUBROUTINE trigger_proc_dcl(tpd_log_id,tpd_table_name,tpd_pk_str,tpd_delete_ind,tpd_sp_log_id,
  tpd_log_type,tpd_context)
   DECLARE tpd_pk_where = vc WITH protect, noconstant("")
   DECLARE tpd_tbl_loop = i4 WITH protect, noconstant(0)
   DECLARE tpd_suffix = vc WITH protect, noconstant("")
   DECLARE tpd_src_tab_name = vc WITH protect, noconstant("")
   DECLARE tpd_all_filtered = i2 WITH protect, noconstant(0)
   DECLARE tpd_last_pk_where = vc WITH protect, noconstant("")
   DECLARE tpd_parent_drdm_row = i4 WITH protect, noconstant(0)
   DECLARE tpd_dcl_tab_name = vc WITH protect, noconstant("")
   DECLARE tpd_cnt = i4 WITH protect, noconstant(0)
   DECLARE tpd_idx = i4 WITH protect, noconstant(0)
   DECLARE tpd_where_str = vc WITH protect, noconstant("")
   DECLARE tpd_qual = i4 WITH protect, noconstant(0)
   DECLARE tpd_filter_ind = i2 WITH protect, noconstant(0)
   DECLARE tpd_status = vc WITH protect, noconstant("")
   DECLARE tpd_pkw_hash = f8 WITH protect, noconstant(0.0)
   DECLARE tpd_ptam_result = f8 WITH protect, noconstant(0.0)
   DECLARE tpd_currval = f8 WITH protect, noconstant(0.0)
   DECLARE tpd_new_currval = f8 WITH protect, noconstant(0.0)
   DECLARE tpd_dcl_tab = vc WITH protect, noconstant("")
   DECLARE tpd_new_log_id = f8 WITH protect, noconstant(0.0)
   DECLARE tpd_reason_str = vc WITH protect, noconstant("")
   DECLARE tpd_ins_cnt = i4 WITH protect, noconstant(0)
   DECLARE tpd_pk_where_hash = f8 WITH protect, noconstant(0.0)
   DECLARE tpd_context_str = vc WITH protect, noconstant("")
   DECLARE tpd_log_type_str = vc WITH protect, noconstant("")
   DECLARE tpd_temp_cnt = i4 WITH protect, noconstant(0)
   DECLARE tpd_tbl_cnt = i4 WITH protect, noconstant(0)
   DECLARE tpd_pkw_value = f8 WITH protect, noconstant(0.0)
   DECLARE tpd_par_pos = i4 WITH protect, noconstant(0)
   DECLARE tpd_par_name = vc WITH protect, noconstant("")
   DECLARE tpd_cur_state_flag = i4 WITH protect, noconstant(0)
   DECLARE tpd_cs_pos = i4 WITH protect, noconstant(0)
   DECLARE tpd_loop = i4 WITH protect, noconstant(0)
   DECLARE tpd_temp_pkw = vc WITH protect, noconstant("")
   DECLARE tpd_prsn_cnt = i4 WITH protect, noconstant(0)
   DECLARE tpd_prsn_tab = vc WITH protect, noconstant("")
   DECLARE tpd_curqual = i4 WITH protect, noconstant(0)
   DECLARE tpd_colstr_ret = i4 WITH protect, noconstant(0)
   DECLARE tpd_curstate_flag_2_quals = i2 WITH protect, noconstant(0)
   DECLARE tpd_curstate_log_type = vc WITH protect, noconstant("")
   FREE RECORD tpd_pkw_rs
   RECORD tpd_pkw_rs(
     1 qual[*]
       2 pkw = vc
       2 log_id = f8
       2 invalid_ind = i2
       2 table_name = vc
       2 table_suffix = vc
       2 skip_filter_ind = i2
   )
   SET tpd_temp_cnt = temp_tbl_cnt
   SET tpd_tbl_cnt = locateval(tpd_tbl_loop,1,dm2_ref_data_doc->tbl_cnt,tpd_table_name,
    dm2_ref_data_doc->tbl_qual[tpd_tbl_loop].table_name)
   IF (tpd_tbl_cnt=0)
    SET tpd_tbl_cnt = fill_rs("TABLE",tpd_table_name)
    IF ((tpd_tbl_cnt=- (1)))
     CALL disp_msg("Table can't be created from remote mover",dm_err->logfile,1)
     SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
     SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
     RETURN(- (1.0))
    ENDIF
    IF ((tpd_tbl_cnt=- (2)))
     RETURN(- (2.0))
    ENDIF
   ENDIF
   SET temp_tbl_cnt = tpd_temp_cnt
   SET tpd_suffix = dm2_ref_data_doc->tbl_qual[tpd_tbl_cnt].suffix
   SET tpd_src_tab_name = dm2_get_rdds_tname(tpd_table_name)
   SET tpd_cur_state_flag = dm2_ref_data_doc->tbl_qual[tpd_tbl_cnt].cur_state_flag
   IF (tpd_cur_state_flag > 0)
    SET tpd_cs_pos = fill_cur_state_rs(tpd_table_name)
    IF (tpd_cs_pos=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("ERROR: Couldn't not gather current state information for table ",
      tpd_table_name,".")
     SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
     SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
     RETURN(- (1.0))
    ENDIF
   ENDIF
   IF (tpd_delete_ind=1)
    SET stat = alterlist(tpd_pkw_rs->qual,1)
    SET tpd_pkw_rs->qual[1].log_id = tpd_log_id
    SET tpd_pkw_rs->qual[1].pkw = "NO PK_WHERE"
    SET tpd_pkw_rs->qual[1].table_name = tpd_table_name
    SET tpd_pkw_rs->qual[1].table_suffix = tpd_suffix
   ELSEIF (tpd_log_id > 0.0)
    IF (tpd_pk_str="")
     SET tpd_dcl_tab_name = dm2_get_rdds_tname("DM_CHG_LOG")
     SELECT INTO "nl:"
      FROM (parser(tpd_dcl_tab_name) d)
      WHERE d.log_id=tpd_log_id
      HEAD REPORT
       tpd_cnt = 0
      DETAIL
       tpd_pk_where = replace(replace(d.pk_where,"<MERGE_LINK>",dm2_ref_data_doc->post_link_name,0),
        "<VERS_CLAUSE>"," 1=1 ",0)
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
      SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
      RETURN(- (1.0))
     ENDIF
    ELSE
     SET tpd_pk_where = tpd_pk_str
    ENDIF
    CALL parser("select into 'nl:'",0)
    CALL parser(concat("from ",tpd_src_tab_name," t",tpd_suffix),0)
    CALL parser(concat(tpd_pk_where," head report tpd_cnt = 0"),0)
    CALL parser("detail",0)
    CALL parser("tpd_cnt = tpd_cnt+1",0)
    CALL parser("stat = alterlist(tpd_pkw_rs->qual, tpd_cnt)",0)
    CALL parser(concat(
      ^tpd_pkw_rs->qual[tpd_cnt].pkw = concat('WHERE t', tpd_suffix, '.rowid = "', t^,tpd_suffix,
      ^.rowid, '"')^),0)
    CALL parser("tpd_pkw_rs->qual[tpd_cnt].table_name = tpd_table_name ",0)
    CALL parser("tpd_pkw_rs->qual[tpd_cnt].table_suffix = tpd_suffix ",0)
    CALL parser("with nocounter, notrim go",1)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
     SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
     RETURN(- (1.0))
    ENDIF
   ELSE
    IF (tpd_table_name="PRSNL")
     SET tpd_prsn_tab = dm2_get_rdds_tname("PERSON")
     SELECT INTO "nl:"
      FROM (parser(tpd_prsn_tab) p)
      WHERE parser(tpd_pk_str)
      WITH nocounter
     ;end select
     SET tpd_curqual = curqual
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
      SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
      RETURN(- (1.0))
     ENDIF
     IF (tpd_curqual > 0)
      SET stat = alterlist(tpd_pkw_rs->qual,2)
      SET tpd_pkw_rs->qual[1].pkw = concat("WHERE ",tpd_pk_str)
      SET tpd_pkw_rs->qual[1].table_name = "PERSON"
      SET tpd_pkw_rs->qual[1].table_suffix = "4859"
      SET tpd_pkw_rs->qual[1].skip_filter_ind = 1
      SET tpd_pkw_rs->qual[2].pkw = concat("WHERE ",tpd_pk_str)
      SET tpd_pkw_rs->qual[2].table_name = tpd_table_name
      SET tpd_pkw_rs->qual[2].table_suffix = tpd_suffix
      SET tpd_temp_cnt = temp_tbl_cnt
      SET tpd_prsn_cnt = locateval(tpd_tbl_loop,1,dm2_ref_data_doc->tbl_cnt,"PERSON",dm2_ref_data_doc
       ->tbl_qual[tpd_tbl_loop].table_name)
      IF (tpd_prsn_cnt=0)
       SET tpd_prsn_cnt = fill_rs("TABLE","PERSON")
       IF ((tpd_prsn_cnt=- (1)))
        CALL disp_msg("Table can't be created from remote mover",dm_err->logfile,1)
        SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
        SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
        RETURN(- (1.0))
       ENDIF
       IF ((tpd_prsn_cnt=- (2)))
        RETURN(- (2.0))
       ENDIF
      ENDIF
      SET temp_tbl_cnt = tpd_temp_cnt
     ELSE
      SET stat = alterlist(tpd_pkw_rs->qual,1)
      SET tpd_pkw_rs->qual[1].pkw = concat("WHERE ",tpd_pk_str)
      SET tpd_pkw_rs->qual[1].table_name = tpd_table_name
      SET tpd_pkw_rs->qual[1].table_suffix = tpd_suffix
     ENDIF
    ELSE
     SET stat = alterlist(tpd_pkw_rs->qual,1)
     SET tpd_pkw_rs->qual[1].pkw = concat("WHERE ",tpd_pk_str)
     SET tpd_pkw_rs->qual[1].table_name = tpd_table_name
     SET tpd_pkw_rs->qual[1].table_suffix = tpd_suffix
    ENDIF
   ENDIF
   IF (size(tpd_pkw_rs->qual,5)=0)
    RETURN(- (3.0))
   ENDIF
   SET tpd_all_filtered = 1
   SET tpd_reason_str = "This row was replaced with the following log_id(s):"
   SET tpd_ins_cnt = 0
   SET dm_err->eproc = "Getting current sequence value."
   SELECT INTO "nl:"
    tpd_val = seq(rdds_source_clinical_seq,currval)
    FROM dual
    DETAIL
     tpd_currval = tpd_val
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
    SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
    RETURN(- (1.0))
   ENDIF
   FOR (tpd_idx = 1 TO size(tpd_pkw_rs->qual,5))
     SET tpd_tbl_cnt = locateval(tpd_tbl_loop,1,dm2_ref_data_doc->tbl_cnt,tpd_pkw_rs->qual[tpd_idx].
      table_name,dm2_ref_data_doc->tbl_qual[tpd_tbl_loop].table_name)
     IF (tpd_delete_ind=1)
      SET tpd_pk_where_hash = dm2_ref_data_doc->tbl_qual[tpd_tbl_cnt].del_pk_where_hash
     ELSE
      SET tpd_pk_where_hash = dm2_ref_data_doc->tbl_qual[tpd_tbl_cnt].pk_where_hash
     ENDIF
     IF ((tpd_pkw_rs->qual[tpd_idx].log_id > 0.0))
      SET tpd_colstr_ret = drmm_get_col_string(" ",tpd_pkw_rs->qual[tpd_idx].log_id,tpd_pkw_rs->qual[
       tpd_idx].table_name,tpd_pkw_rs->qual[tpd_idx].table_suffix,dm2_ref_data_doc->post_link_name)
     ELSE
      SET tpd_colstr_ret = drmm_get_col_string(tpd_pkw_rs->qual[tpd_idx].pkw,0.0,tpd_pkw_rs->qual[
       tpd_idx].table_name,tpd_pkw_rs->qual[tpd_idx].table_suffix,dm2_ref_data_doc->post_link_name)
     ENDIF
     IF (check_error(dm_err->eproc)=1)
      CALL echo(build("tpd_colstr_ret:",tpd_colstr_ret))
      IF ((tpd_colstr_ret=- (2)))
       SET dm_err->err_ind = 0
      ENDIF
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
      SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
      RETURN(- (1.0))
     ENDIF
     SET tpd_pk_where = drmm_get_pk_where(tpd_pkw_rs->qual[tpd_idx].table_name,tpd_pkw_rs->qual[
      tpd_idx].table_suffix,tpd_delete_ind,dm2_ref_data_doc->post_link_name)
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
      SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
      RETURN(- (1.0))
     ENDIF
     IF (tpd_pk_where != tpd_last_pk_where)
      SET tpd_last_pk_where = tpd_pk_where
      IF (drdm_debug_row_ind=1)
       CALL echo("***PK_WHERE generated:***")
       CALL echo(tpd_pk_where)
      ENDIF
      IF (tpd_log_id=0.0
       AND (tpd_pkw_rs->qual[tpd_idx].table_name != "PERSON"))
       SET tpd_where_str = replace(tpd_pk_where,"<MERGE_LINK>",dm2_ref_data_doc->post_link_name,0)
       IF (tpd_cur_state_flag > 0)
        IF (tpd_cur_state_flag=2)
         FOR (tpd_loop = 1 TO cur_state_tabs->qual[tpd_cs_pos].parent_cnt)
           IF (findstring(cur_state_tabs->qual[tpd_cs_pos].parent_qual[tpd_loop].parent_table,
            tpd_where_str,1,1) > 0)
            SET tpd_curstate_flag_2_quals = 1
            SET tpd_temp_cnt = temp_tbl_cnt
            SET tpd_par_pos = locateval(tpd_tbl_loop,1,dm2_ref_data_doc->tbl_cnt,cur_state_tabs->
             qual[tpd_cs_pos].parent_qual[tpd_loop].top_level_parent,dm2_ref_data_doc->tbl_qual[
             tpd_tbl_loop].table_name)
            IF (tpd_par_pos=0)
             SET tpd_par_pos = fill_rs("TABLE",cur_state_tabs->qual[tpd_cs_pos].parent_qual[tpd_loop]
              .top_level_parent)
             IF ((tpd_par_pos=- (1)))
              CALL disp_msg("Table can't be created from remote mover",dm_err->logfile,1)
              SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
              SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
              RETURN(- (1.0))
             ENDIF
             IF ((tpd_par_pos=- (2)))
              RETURN(- (2.0))
             ENDIF
             SET temp_tbl_cnt = tpd_temp_cnt
             SET tpd_loop = cur_state_tabs->qual[tpd_cs_pos].parent_cnt
            ENDIF
           ENDIF
         ENDFOR
        ELSE
         SET tpd_temp_cnt = temp_tbl_cnt
         SET tpd_par_pos = locateval(tpd_tbl_loop,1,dm2_ref_data_doc->tbl_cnt,cur_state_tabs->qual[
          tpd_cs_pos].parent_qual[1].top_level_parent,dm2_ref_data_doc->tbl_qual[tpd_tbl_loop].
          table_name)
         IF (tpd_par_pos=0)
          SET tpd_par_pos = fill_rs("TABLE",cur_state_tabs->qual[tpd_cs_pos].parent_qual[1].
           top_level_parent)
          IF ((tpd_par_pos=- (1)))
           CALL disp_msg("Table can't be created from remote mover",dm_err->logfile,1)
           SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
           SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
           RETURN(- (1.0))
          ENDIF
          IF ((tpd_par_pos=- (2)))
           RETURN(- (2.0))
          ENDIF
         ENDIF
         SET temp_tbl_cnt = tpd_temp_cnt
        ENDIF
        IF (tpd_par_pos > 0)
         IF ((((dm2_ref_data_doc->tbl_qual[tpd_par_pos].version_ind=1)) OR ((dm2_ref_data_doc->
         tbl_qual[tpd_par_pos].table_name IN ("DCP_SECTION_REF", "DCP_FORMS_REF")))) )
          SET tpd_loop = 1
         ELSE
          SET tpd_loop = 3
         ENDIF
        ELSE
         SET tpd_loop = 3
        ENDIF
        SET tpd_temp_pkw = tpd_where_str
        WHILE (tpd_loop <= 3
         AND tpd_qual=0)
          IF (tpd_loop=1)
           SET tpd_where_str = replace(tpd_temp_pkw,"<VERS_CLAUSE>"," ACTIVE_IND = 1 ",0)
          ELSEIF (tpd_loop=2)
           IF ((dm2_ref_data_doc->tbl_qual[tpd_par_pos].effective_col_ind=1))
            SET tpd_where_str = replace(tpd_temp_pkw,"<VERS_CLAUSE>",concat(dm2_ref_data_doc->
              tbl_qual[tpd_par_pos].beg_col_name,"<= cnvtdatetime(curdate,curtime3) and ",
              dm2_ref_data_doc->tbl_qual[tpd_par_pos].end_col_name,
              ">= cnvtdatetime(curdate,curtime3) "),0)
           ELSE
            SET tpd_loop = 3
            SET tpd_where_str = replace(tpd_temp_pkw,"<VERS_CLAUSE>"," 1 = 1 ",0)
           ENDIF
          ELSE
           SET tpd_where_str = replace(tpd_temp_pkw,"<VERS_CLAUSE>"," 1 = 1 ",0)
          ENDIF
          CALL parser("select into 'nl:'",0)
          CALL parser(concat(" from ",tpd_src_tab_name," t",tpd_pkw_rs->qual[tpd_idx].table_suffix),0
           )
          CALL parser(concat(tpd_where_str," with nocounter,notrim go"),1)
          SET tpd_qual = curqual
          IF (check_error(dm_err->eproc)=1)
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
           SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
           RETURN(- (1.0))
          ENDIF
          SET tpd_loop = (tpd_loop+ 1)
        ENDWHILE
       ENDIF
       SET tpd_where_str = concat(tpd_where_str," AND ",tpd_pk_str)
       CALL parser("select into 'nl:'",0)
       CALL parser(concat(" from ",tpd_src_tab_name," t",tpd_pkw_rs->qual[tpd_idx].table_suffix),0)
       CALL parser(concat(tpd_where_str," with nocounter,notrim go"),1)
       SET tpd_qual = curqual
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
        SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
        RETURN(- (1.0))
       ENDIF
       IF (tpd_qual=0)
        CALL disp_msg(concat("Failed attempting to create pk_where for ",tpd_pk_str,
          ". The pk_where created: ",tpd_where_str,"does not qualify on the needed row."),dm_err->
         logfile,1)
        SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
        SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = concat(
         "Failed attempting to create required pk_where for ",tpd_pk_str,". The pk_where created: ",
         tpd_where_str,"does not qualify on the needed row.")
        RETURN(- (5.0))
       ENDIF
      ENDIF
      CALL drmm_get_ptam_match_query(0.0,tpd_pkw_rs->qual[tpd_idx].table_name,tpd_pkw_rs->qual[
       tpd_idx].table_suffix,dm2_ref_data_doc->post_link_name)
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
       SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
       RETURN(- (1.0))
      ENDIF
      IF (tpd_delete_ind=0
       AND (tpd_pkw_rs->qual[tpd_idx].skip_filter_ind != 1))
       IF ((((dm2_ref_data_doc->tbl_qual[tpd_tbl_cnt].version_ind=0)) OR ((dm2_ref_data_doc->
       tbl_qual[tpd_tbl_cnt].version_ind=1)
        AND  NOT ((dm2_ref_data_doc->tbl_qual[tpd_tbl_cnt].version_type IN ("ALG1", "ALG3", "ALG3D",
       "ALG4", "ALG5",
       "ALG6"))))) )
        SET tpd_filter_ind = filter_proc_call(tpd_pkw_rs->qual[tpd_idx].table_name,replace(
          tpd_pk_where,"<MERGE_LINK>",dm2_ref_data_doc->post_link_name,0),0.0)
       ELSE
        SET tpd_filter_ind = 1
       ENDIF
      ELSE
       SET tpd_filter_ind = 1
      ENDIF
      IF (tpd_filter_ind=1)
       IF (tpd_log_id=0
        AND ((tpd_cur_state_flag=1) OR (tpd_curstate_flag_2_quals=1)) )
        SET tpd_curstate_log_type = "REFCHG"
       ELSE
        SET tpd_curstate_log_type = tpd_log_type
       ENDIF
       IF ((tpd_pkw_rs->qual[tpd_idx].skip_filter_ind != 1))
        SET tpd_all_filtered = 0
       ENDIF
       SET tpd_status = call_ins_dcl(tpd_pkw_rs->qual[tpd_idx].table_name,tpd_pk_where,
        tpd_curstate_log_type,tpd_delete_ind,reqinfo->updt_id,
        reqinfo->updt_task,reqinfo->updt_applctx,tpd_context,dm2_ref_data_doc->env_target_id,
        tpd_sp_log_id,
        dm2_ref_data_doc->post_link_name,tpd_pk_where_hash,dm2_ref_data_doc->tbl_qual[tpd_tbl_cnt].
        ptam_match_hash)
       IF (tpd_status="F")
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
        SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
        RETURN(- (1.0))
       ENDIF
       IF (tpd_log_id=0
        AND ((tpd_cur_state_flag=1) OR (tpd_curstate_flag_2_quals=1)) )
        SELECT INTO "nl:"
         tpd_val = seq(rdds_source_clinical_seq,currval)
         FROM dual
         DETAIL
          tpd_currval = tpd_val
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
         SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
         RETURN(- (1.0))
        ENDIF
        SET tpd_pk_where = concat(tpd_pk_where," AND ",tpd_pk_str)
        SET tpd_status = call_ins_dcl(tpd_pkw_rs->qual[tpd_idx].table_name,tpd_pk_where,tpd_log_type,
         tpd_delete_ind,reqinfo->updt_id,
         reqinfo->updt_task,reqinfo->updt_applctx,tpd_context,dm2_ref_data_doc->env_target_id,
         tpd_sp_log_id,
         dm2_ref_data_doc->post_link_name,tpd_pk_where_hash,dm2_ref_data_doc->tbl_qual[tpd_tbl_cnt].
         ptam_match_hash)
        IF (tpd_status="F")
         CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
         SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
         SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
         RETURN(- (1.0))
        ENDIF
       ENDIF
       SELECT INTO "nl:"
        tpd_val = seq(rdds_source_clinical_seq,currval)
        FROM dual
        DETAIL
         tpd_new_currval = tpd_val
        WITH nocounter
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
        SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
        RETURN(- (1.0))
       ENDIF
       IF (tpd_new_currval=tpd_currval)
        DECLARE dm_get_hash_value() = f8
        SELECT INTO "nl:"
         pkw_value = dm_get_hash_value(tpd_pk_where,0,1073741824.0)
         FROM dual
         DETAIL
          tpd_pkw_value = pkw_value
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
         SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
         SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
         RETURN(- (1.0))
        ENDIF
        SET tpd_dcl_tab = dm2_get_rdds_tname("DM_CHG_LOG")
        SET dm_err->eproc = "Searching for single pass DCL row."
        IF (tpd_context="")
         SET tpd_context_str = "d.context_name is null"
        ELSE
         SET tpd_context_str = "d.context_name = tpd_context"
        ENDIF
        IF (tpd_log_type="REFCHG")
         SET tpd_log_type_str = "d.log_type IN ('REFCHG','NORDDS')"
        ELSE
         SET tpd_log_type_str = "d.log_type IN('REFCHG','PROCES','NORDDS')"
        ENDIF
        SELECT INTO "nl:"
         d.log_id
         FROM (parser(tpd_dcl_tab) d)
         WHERE (d.table_name=tpd_pkw_rs->qual[tpd_idx].table_name)
          AND d.delete_ind=tpd_delete_ind
          AND ((d.target_env_id+ 0)=dm2_ref_data_doc->env_target_id)
          AND parser(tpd_context_str)
          AND d.pk_where=tpd_pk_where
          AND parser(tpd_log_type_str)
          AND d.pk_where_value=tpd_pkw_value
         DETAIL
          tpd_new_log_id = d.log_id
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
         SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
         SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
         RETURN(- (1.0))
        ENDIF
       ELSE
        SET tpd_new_log_id = tpd_new_currval
        SET tpd_currval = tpd_new_currval
       ENDIF
       IF (tpd_log_id > 0.0)
        IF (tpd_ins_cnt=0)
         SET tpd_reason_str = concat(tpd_reason_str," ",trim(cnvtstring(tpd_new_log_id,20)))
        ELSE
         SET tpd_reason_str = concat(tpd_reason_str,",",trim(cnvtstring(tpd_new_log_id,20)))
        ENDIF
        SET tpd_ins_cnt = (tpd_ins_cnt+ 1)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   IF (tpd_all_filtered=1)
    RETURN(- (4.0))
   ELSE
    IF (tpd_sp_log_id=0.0)
     SET tpd_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
     SET drdm_chg->log[tpd_parent_drdm_row].chg_log_reason_txt = tpd_reason_str
    ENDIF
    RETURN(tpd_new_log_id)
   ENDIF
 END ;Subroutine
 SUBROUTINE reset_exceptions(re_tab_name,re_tgt_env_id,re_from_value,re_data)
   DECLARE re_dcle_name = vc WITH protect, noconstant("")
   DECLARE re_dcl_name = vc WITH protect, noconstant("")
   DECLARE re_xcptn_id = f8 WITH protect, noconstant(0.0)
   DECLARE re_tab_str = vc WITH protect, noconstant("")
   DECLARE re_parent_drdm_row = i4 WITH protect, noconstant(0)
   DECLARE re_idx = i4 WITH protect, noconstant(0)
   DECLARE re_circ_loop = i4 WITH protect, noconstant(0)
   DECLARE re_where_str = vc WITH protect, noconstant(" ")
   DECLARE re_loop = i4 WITH protect, noconstant(0)
   DECLARE re_new_loop = i4 WITH protect, noconstant(0)
   DECLARE re_orig_tab = vc WITH protect, noconstant("")
   DECLARE re_circ_tab_pos = i4 WITH protect, noconstant(0)
   DECLARE re_last_pe_name = vc WITH protect, noconstant("")
   DECLARE re_circ_name_pos = i4 WITH protect, noconstant(0)
   DECLARE re_log_type_str = vc WITH protect, noconstant("")
   FREE RECORD re_multi
   RECORD re_multi(
     1 cnt = i4
     1 qual[*]
       2 dcle_id = f8
   )
   SET re_dcle_name = dm2_get_rdds_tname("DM_CHG_LOG_EXCEPTION")
   SET re_orig_tab = re_tab_name
   IF (re_tab_name IN ("PERSON", "PRSNL"))
    SET re_tab_str = "d.table_name IN('PERSON','PRSNL')"
   ELSE
    SET re_tab_str = "d.table_name = re_tab_name"
   ENDIF
   SET dm_err->eproc = "Querying for dm_chg_log_exception row."
   SELECT INTO "nl:"
    FROM (parser(re_dcle_name) d)
    WHERE parser(re_tab_str)
     AND d.log_type != "DELETE"
     AND d.target_env_id=re_tgt_env_id
     AND d.from_value=re_from_value
    DETAIL
     re_xcptn_id = d.dm_chg_log_exception_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    SET re_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
    SET drdm_chg->log[re_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
    RETURN(0)
   ENDIF
   IF (re_xcptn_id > 0.0)
    SET dm_err->eproc = "Calling dm_rmc_find_dcl_xcptn"
    SET stat = initrec(drfdx_reply)
    SET drfdx_request->exclude_str = ""
    FOR (re_circ_loop = 1 TO re_data->cnt)
      IF ((drfdx_request->exclude_str=""))
       SET drfdx_request->exclude_str = concat(" table_name not in ('",re_data->qual[re_circ_loop].
        circ_table_name,"'")
      ELSE
       SET re_circ_name_pos = findstring(concat("'",re_data->qual[re_circ_loop].circ_table_name,"'"),
        drfdx_request->exclude_str,1,0)
       IF (re_circ_name_pos=0)
        SET drfdx_request->exclude_str = concat(drfdx_request->exclude_str,", '",re_data->qual[
         re_circ_loop].circ_table_name,"'")
       ENDIF
      ENDIF
    ENDFOR
    IF (findstring(",",drfdx_request->exclude_str,1,0)=0)
     SET drfdx_request->exclude_str = ""
    ELSE
     SET drfdx_request->exclude_str = concat(drfdx_request->exclude_str,")")
    ENDIF
    SET drfdx_request->exception_id = re_xcptn_id
    SET drfdx_request->target_env_id = re_tgt_env_id
    SET drfdx_request->db_link = dm2_ref_data_doc->post_link_name
    EXECUTE dm_rmc_find_dcl_xcptn  WITH replace("REQUEST","DRFDX_REQUEST"), replace("REPLY",
     "DRFDX_REPLY")
    IF ((drfdx_reply->err_ind=1))
     CALL disp_msg(drfdx_reply->emsg,dm_err->logfile,drfdx_reply->err_ind)
     SET re_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
     SET drdm_chg->log[re_parent_drdm_row].chg_log_reason_txt = drfdx_reply->emsg
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Resetting related dm_chg_log rows to REFCHG."
    SET re_dcl_name = dm2_get_rdds_tname("DM_CHG_LOG")
    IF ((drfdx_reply->total > 0))
     UPDATE  FROM (parser(re_dcl_name) d),
       (dummyt d2  WITH seq = value(drfdx_reply->total))
      SET d.log_type = "REFCHG", d.dm_chg_log_exception_id = 0.0, d.chg_log_reason_txt = "",
       d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      PLAN (d2
       WHERE (drfdx_reply->row[d2.seq].current_context_ind=1))
       JOIN (d
       WHERE (d.log_id=drfdx_reply->row[d2.seq].log_id))
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      SET re_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
      SET drdm_chg->log[re_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   IF ((global_mover_rec->circ_nomv_excl_cnt=0))
    SET re_log_type_str = "e.log_type != 'DELETE'"
   ELSE
    FOR (re_circ_loop = 1 TO global_mover_rec->circ_nomv_excl_cnt)
      IF (re_circ_loop=1)
       SET re_log_type_str = concat("e.log_type in ('",global_mover_rec->circ_nomv_qual[re_circ_loop]
        .log_type,"'")
      ELSE
       SET re_log_type_str = concat(re_log_type_str,",'",global_mover_rec->circ_nomv_qual[
        re_circ_loop].log_type,"'")
      ENDIF
    ENDFOR
    SET re_log_type_str = concat(re_log_type_str,")")
   ENDIF
   FOR (re_circ_loop = 1 TO re_data->cnt)
     SET re_multi->cnt = 0
     SET stat = alterlist(re_multi->qual,0)
     SET dm_err->eproc = "Querying for circular dm_chg_log_exception row."
     FOR (re_loop = 1 TO re_data->qual[re_circ_loop].circ_val_cnt)
       IF (re_loop=1)
        SET re_where_str = " e.from_value in ("
       ELSE
        SET re_where_str = concat(re_where_str,", ")
       ENDIF
       SET re_where_str = concat(re_where_str,trim(cnvtstring(re_data->qual[re_circ_loop].
          circ_val_qual[re_loop].circ_value,20,1)))
       IF ((re_loop=re_data->qual[re_circ_loop].circ_val_cnt))
        SET re_where_str = concat(re_where_str,")")
       ENDIF
     ENDFOR
     IF ((re_data->qual[re_circ_loop].circ_val_cnt > 0))
      IF ((re_data->qual[re_circ_loop].excptn_cnt > 0))
       SELECT INTO "nl:"
        FROM (parser(re_dcle_name) e)
        WHERE (e.table_name=re_data->qual[re_circ_loop].circ_table_name)
         AND (e.column_name=re_data->qual[re_circ_loop].circ_root_col)
         AND parser(re_log_type_str)
         AND e.target_env_id=re_tgt_env_id
         AND parser(re_where_str)
         AND  NOT (expand(re_new_loop,1,re_data->qual[re_circ_loop].excptn_cnt,e.from_value,re_data->
         qual[re_circ_loop].excptn_qual[re_new_loop].value))
        DETAIL
         re_multi->cnt = (re_multi->cnt+ 1), stat = alterlist(re_multi->qual,re_multi->cnt), re_multi
         ->qual[re_multi->cnt].dcle_id = e.dm_chg_log_exception_id
        WITH nocounter
       ;end select
      ELSE
       SELECT INTO "nl:"
        FROM (parser(re_dcle_name) e)
        WHERE (e.table_name=re_data->qual[re_circ_loop].circ_table_name)
         AND (e.column_name=re_data->qual[re_circ_loop].circ_root_col)
         AND parser(re_log_type_str)
         AND e.target_env_id=re_tgt_env_id
         AND parser(re_where_str)
        DETAIL
         re_multi->cnt = (re_multi->cnt+ 1), stat = alterlist(re_multi->qual,re_multi->cnt), re_multi
         ->qual[re_multi->cnt].dcle_id = e.dm_chg_log_exception_id
        WITH nocounter
       ;end select
      ENDIF
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       SET re_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
       SET drdm_chg->log[re_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
       RETURN(0)
      ENDIF
     ENDIF
     SET re_circ_tab_pos = locateval(re_circ_tab_pos,1,dm2_ref_data_doc->tbl_cnt,re_data->qual[
      re_circ_loop].circ_table_name,dm2_ref_data_doc->tbl_qual[re_circ_tab_pos].table_name)
     SET drfdx_request->exclude_str = ""
     SET re_last_pe_name = ""
     FOR (re_loop = 1 TO dm2_ref_data_doc->tbl_qual[re_circ_tab_pos].circular_cnt)
       IF ((dm2_ref_data_doc->tbl_qual[re_circ_tab_pos].circ_qual[re_loop].circular_type=2))
        IF ((dm2_ref_data_doc->tbl_qual[re_circ_tab_pos].circ_qual[re_loop].pe_name_col !=
        re_last_pe_name))
         SET re_last_pe_name = dm2_ref_data_doc->tbl_qual[re_circ_tab_pos].circ_qual[re_loop].
         pe_name_col
         IF ((drfdx_request->exclude_str=""))
          SET drfdx_request->exclude_str = concat(" table_name not in ('",dm2_ref_data_doc->tbl_qual[
           re_circ_tab_pos].circ_qual[re_loop].circ_table_name,"'")
         ELSE
          SET re_circ_name_pos = findstring(concat("'",dm2_ref_data_doc->tbl_qual[re_circ_tab_pos].
            circ_qual[re_loop].circ_table_name,"'"),drfdx_request->exclude_str,1,0)
          IF (re_circ_name_pos=0)
           SET drfdx_request->exclude_str = concat(drfdx_request->exclude_str,", '",dm2_ref_data_doc
            ->tbl_qual[re_circ_tab_pos].circ_qual[re_loop].circ_table_name,"'")
          ENDIF
         ENDIF
        ENDIF
       ELSE
        IF ((drfdx_request->exclude_str=""))
         SET drfdx_request->exclude_str = concat(" table_name not in ('",dm2_ref_data_doc->tbl_qual[
          re_circ_tab_pos].circ_qual[re_loop].circ_table_name,"'")
        ELSE
         SET re_circ_name_pos = findstring(concat("'",dm2_ref_data_doc->tbl_qual[re_circ_tab_pos].
           circ_qual[re_loop].circ_table_name,"'"),drfdx_request->exclude_str,1,0)
         IF (re_circ_name_pos=0)
          SET drfdx_request->exclude_str = concat(drfdx_request->exclude_str,", '",dm2_ref_data_doc->
           tbl_qual[re_circ_tab_pos].circ_qual[re_loop].circ_table_name,"'")
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
     IF (findstring(",",drfdx_request->exclude_str,1,0)=0)
      SET drfdx_request->exclude_str = ""
     ELSE
      SET drfdx_request->exclude_str = concat(drfdx_request->exclude_str,")")
     ENDIF
     FOR (re_loop = 1 TO re_multi->cnt)
       IF ((re_multi->qual[re_loop].dcle_id > 0.0))
        SET dm_err->eproc = "Calling dm_rmc_find_dcl_xcptn"
        SET stat = initrec(drfdx_reply)
        SET drfdx_request->exception_id = re_multi->qual[re_loop].dcle_id
        SET drfdx_request->target_env_id = re_tgt_env_id
        SET drfdx_request->db_link = dm2_ref_data_doc->post_link_name
        EXECUTE dm_rmc_find_dcl_xcptn  WITH replace("REQUEST","DRFDX_REQUEST"), replace("REPLY",
         "DRFDX_REPLY")
        IF ((drfdx_reply->err_ind=1))
         CALL disp_msg(drfdx_reply->emsg,dm_err->logfile,drfdx_reply->err_ind)
         SET re_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
         SET drdm_chg->log[re_parent_drdm_row].chg_log_reason_txt = drfdx_reply->emsg
         RETURN(0)
        ENDIF
        SET dm_err->eproc = "Resetting related dm_chg_log rows to REFCHG."
        SET re_dcl_name = dm2_get_rdds_tname("DM_CHG_LOG")
        IF ((drfdx_reply->total > 0))
         UPDATE  FROM (parser(re_dcl_name) d),
           (dummyt d2  WITH seq = value(drfdx_reply->total))
          SET d.log_type = "REFCHG", d.dm_chg_log_exception_id = 0.0, d.chg_log_reason_txt = "",
           d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
          PLAN (d2
           WHERE (drfdx_reply->row[d2.seq].current_context_ind=1))
           JOIN (d
           WHERE (d.log_id=drfdx_reply->row[d2.seq].log_id))
          WITH nocounter
         ;end update
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
          SET re_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
          SET drdm_chg->log[re_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
          RETURN(0)
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE check_concurrent_snapshot(sbr_ccs_mode,sbr_ccs_cur_appl_id)
   DECLARE ccs_appl_id = vc WITH protect, noconstant(" ")
   DECLARE ccs_appl_status = vc WITH protect, noconstant(" ")
   IF (cnvtupper(sbr_ccs_mode)="I")
    SET dm_err->eproc = "Determining if another upgrade process is running."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DM2 INSTALL PROCESS"
      AND di.info_name="CONCURRENCY CHECKPOINT"
     DETAIL
      ccs_appl_id = di.info_char
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual > 0)
     IF (ccs_appl_id=sbr_ccs_cur_appl_id)
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
      SET ccs_appl_status = dm2_get_appl_status(ccs_appl_id)
      IF (ccs_appl_status="E")
       RETURN(0)
      ELSE
       IF (ccs_appl_status="A")
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
    SET dm_err->eproc = "Inserting concurrency row in dm_info."
    CALL disp_msg(" ",dm_err->logfile,0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2 INSTALL PROCESS", di.info_name = "CONCURRENCY CHECKPOINT", di
      .info_char = sbr_ccs_cur_appl_id,
      di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = 0, di.updt_cnt = 0,
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
 SUBROUTINE dm2_get_appl_status(gas_appl_id)
   DECLARE gas_error_status = c1 WITH protect, constant("E")
   DECLARE gas_active_status = c1 WITH protect, constant("A")
   DECLARE gas_inactive_status = c1 WITH protect, constant("I")
   DECLARE gas_text = vc WITH protect, noconstant(" ")
   DECLARE gas_currdblink = vc WITH protect, noconstant(cnvtupper(trim(currdblink,3)))
   DECLARE gas_appl_id_cvt = vc WITH protect, noconstant(" ")
   IF (cnvtupper(gas_appl_id)="-15301")
    RETURN(gas_active_status)
   ENDIF
   SELECT INTO "nl:"
    FROM gv$session s
    WHERE s.audsid=cnvtint(gas_appl_id)
    WITH nocounter
   ;end select
   IF (check_error("Selecting from gv$session in subroutine DM2_GET_APPL_STATUS")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(gas_error_status)
   ELSEIF (curqual=0)
    SELECT INTO "nl:"
     FROM v$session s
     WHERE s.audsid=cnvtint(gas_appl_id)
     WITH nocounter
    ;end select
    IF (check_error("Selecting from v$session in subroutine DM2_GET_APPL_STATUS")=1)
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
 SUBROUTINE load_grouper(lg_cnt,lg_log_type,lg_chg_cnt)
   DECLARE lg_alias = vc WITH protect, noconstant("")
   DECLARE lg_loop = i4 WITH protect, noconstant(0)
   DECLARE lg_src_fv = vc WITH protect, noconstant("")
   DECLARE lg_temp_cnt = i4 WITH protect, noconstant(0)
   DECLARE lg_qual_cnt = i4 WITH protect, noconstant(0)
   DECLARE lg_d_cnt = i4 WITH protect, noconstant(0)
   DECLARE lg_log_type_idx = i4 WITH protect, noconstant(0)
   SET lg_src_fv = dm2_get_rdds_tname(dm2_ref_data_doc->tbl_qual[lg_cnt].table_name)
   SET lg_alias = concat(" t",dm2_ref_data_doc->tbl_qual[lg_cnt].suffix)
   FREE RECORD cust_cs_rows
   CALL parser("record cust_cs_rows (",0)
   CALL parser(" 1 trailing_space_ind = i2")
   CALL parser(" 1 qual[*]",0)
   FOR (lg_loop = 1 TO dm2_ref_data_doc->tbl_qual[lg_cnt].col_cnt)
     IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].version_type IN ("ALG5", "ALG7")))
      IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].exception_flg=12))
       CALL parser(concat(" 2 ",dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].column_name,
         " = ",dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].data_type),0)
       CALL parser(concat(" 2 ",dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].column_name,
         "_NULLIND = i2 "),0)
       IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].data_type IN ("VC", "C*")))
        CALL parser(concat(" 2 ",dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].column_name,
          "_LEN = i4 "),0)
       ENDIF
      ENDIF
     ELSEIF ((dm2_ref_data_doc->tbl_qual[lg_cnt].version_type="ALG6"))
      IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].unique_ident_ind=1))
       CALL parser(concat(" 2 ",dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].column_name,
         " = ",dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].data_type),0)
       CALL parser(concat(" 2 ",dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].column_name,
         "_NULLIND = i2 "),0)
       IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].data_type IN ("VC", "C*")))
        CALL parser(concat(" 2 ",dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].column_name,
          "_LEN = i4 "),0)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   CALL parser(") go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   SET lg_temp_cnt = 0
   CALL parser("select into 'nl:'",0)
   FOR (lg_loop = 1 TO dm2_ref_data_doc->tbl_qual[lg_cnt].col_cnt)
     IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].version_type IN ("ALG5", "ALG7")))
      IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].exception_flg=12))
       IF (lg_temp_cnt > 0)
        CALL parser(" , ",0)
       ENDIF
       SET lg_temp_cnt = (lg_temp_cnt+ 1)
       CALL parser(concat("var",cnvtstring(lg_loop)," = nullind(",lg_alias,".",
         dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].column_name,")"),0)
       IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].data_type IN ("VC", "C*")))
        CALL parser(concat(", ts",cnvtstring(lg_loop)," = length(",lg_alias,".",
          dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].column_name,")"),0)
       ENDIF
      ENDIF
     ELSEIF ((dm2_ref_data_doc->tbl_qual[lg_cnt].version_type="ALG6"))
      IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].unique_ident_ind=1))
       IF (lg_temp_cnt > 0)
        CALL parser(" , ",0)
       ENDIF
       SET lg_temp_cnt = (lg_temp_cnt+ 1)
       CALL parser(concat("var",cnvtstring(lg_loop)," = nullind(",lg_alias,".",
         dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].column_name,")"),0)
       IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].data_type IN ("VC", "C*")))
        CALL parser(concat(", ts",cnvtstring(lg_loop)," = length(",lg_alias,".",
          dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].column_name,")"),0)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   CALL parser(concat(" from  ",lg_src_fv," ",lg_alias),0)
   CALL parser(drdm_chg->log[lg_chg_cnt].pk_where,0)
   CALL parser("head report cust_cs_rows->trailing_space_ind = 1",0)
   CALL parser(
    " detail lg_qual_cnt = lg_qual_cnt + 1 stat = alterlist(cust_cs_rows->qual, lg_qual_cnt) ",0)
   FOR (lg_loop = 1 TO dm2_ref_data_doc->tbl_qual[lg_cnt].col_cnt)
     IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].version_type IN ("ALG5", "ALG7")))
      IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].exception_flg=12))
       CALL parser(concat("cust_cs_rows->qual[lg_qual_cnt].",dm2_ref_data_doc->tbl_qual[lg_cnt].
         col_qual[lg_loop].column_name," = ",lg_alias,".",
         dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].column_name),0)
       CALL parser(concat("cust_cs_rows->qual[lg_qual_cnt].",dm2_ref_data_doc->tbl_qual[lg_cnt].
         col_qual[lg_loop].column_name,"_NULLIND = var",trim(cnvtstring(lg_loop))),0)
       IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].data_type IN ("VC", "C*")))
        CALL parser(concat("cust_cs_rows->qual[lg_qual_cnt].",dm2_ref_data_doc->tbl_qual[lg_cnt].
          col_qual[lg_loop].column_name,"_LEN = ts",trim(cnvtstring(lg_loop))),0)
       ENDIF
      ENDIF
     ELSEIF ((dm2_ref_data_doc->tbl_qual[lg_cnt].version_type="ALG6"))
      IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].unique_ident_ind=1))
       CALL parser(concat("cust_cs_rows->qual[lg_qual_cnt].",dm2_ref_data_doc->tbl_qual[lg_cnt].
         col_qual[lg_loop].column_name," = ",lg_alias,".",
         dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].column_name),0)
       CALL parser(concat("cust_cs_rows->qual[lg_qual_cnt].",dm2_ref_data_doc->tbl_qual[lg_cnt].
         col_qual[lg_loop].column_name,"_NULLIND = var",trim(cnvtstring(lg_loop))),0)
       IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lg_loop].data_type IN ("VC", "C*")))
        CALL parser(concat("cust_cs_rows->qual[lg_qual_cnt].",dm2_ref_data_doc->tbl_qual[lg_cnt].
          col_qual[lg_loop].column_name,"_LEN = ts",trim(cnvtstring(lg_loop))),0)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   CALL parser(" with nocounter, notrim go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].version_type="ALG5"))
    SET lms_pk_where = drdm_create_pk_where(lg_qual_cnt,lg_cnt,"ALG5")
   ELSEIF ((dm2_ref_data_doc->tbl_qual[lg_cnt].version_type="ALG6"))
    SET lms_pk_where = drdm_create_pk_where(lg_qual_cnt,lg_cnt,"UI")
   ELSEIF ((dm2_ref_data_doc->tbl_qual[lg_cnt].version_type="ALG7"))
    SET lms_pk_where = drdm_create_pk_where(lg_qual_cnt,lg_cnt,"ALG7")
   ENDIF
   IF (lms_pk_where="")
    CALL disp_msg("There was an error creating the PK_WHERE string",dm_err->logfile,0)
    SET dm_err->err_ind = 1
    RETURN(- (1))
   ENDIF
   IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].version_type IN ("ALG5", "ALG7")))
    CALL parser("select into 'nl:'",0)
    CALL parser(concat("from ",lg_src_fv,lg_alias),0)
    CALL parser(concat(lms_pk_where," detail"),0)
    FOR (lms_lp_cnt = 1 TO dm2_ref_data_doc->tbl_qual[lg_cnt].col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lms_lp_cnt].pk_ind=1)
       AND (dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lms_lp_cnt].root_entity_attr=dm2_ref_data_doc
      ->tbl_qual[lg_cnt].col_qual[lms_lp_cnt].column_name)
       AND (dm2_ref_data_doc->tbl_qual[lg_cnt].col_qual[lms_lp_cnt].root_entity_name=dm2_ref_data_doc
      ->tbl_qual[lg_cnt].table_name))
       CALL parser(" lg_d_cnt = lg_d_cnt +1",0)
       CALL parser("stat = alterlist(lms_fv->list, lg_d_cnt)",0)
       CALL parser(concat("lms_fv->list[lg_d_cnt].table_name = '",dm2_ref_data_doc->tbl_qual[lg_cnt].
         table_name,"'"),0)
       CALL parser(concat("lms_fv->list[lg_d_cnt].column_name = '",dm2_ref_data_doc->tbl_qual[lg_cnt]
         .col_qual[lms_lp_cnt].column_name,"'"),0)
       CALL parser(build("lms_fv->list[lg_d_cnt].from_value = ",lg_alias,".",dm2_ref_data_doc->
         tbl_qual[lg_cnt].col_qual[lms_lp_cnt].column_name),0)
      ENDIF
    ENDFOR
    CALL parser("with nocounter, notrim go",1)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(- (1))
    ENDIF
   ELSEIF ((dm2_ref_data_doc->tbl_qual[lg_cnt].version_type="ALG6"))
    CALL parser("select into 'nl:'",0)
    CALL parser(concat("from ",lg_src_fv,lg_alias),0)
    CALL parser(lms_pk_where,0)
    CALL parser(concat(" and ",lg_alias,".active_ind = 1 and ",lg_alias,".",
      dm2_ref_data_doc->tbl_qual[lg_cnt].beg_col_name," <= cnvtdatetime(curdate,curtime3)"),0)
    CALL parser(concat(" and ",lg_alias,".",dm2_ref_data_doc->tbl_qual[lg_cnt].end_col_name,
      " >= cnvtdatetime(curdate,curtime3)"),0)
    CALL parser(" detail ",0)
    CALL parser(" lg_d_cnt = lg_d_cnt +1",0)
    CALL parser("stat = alterlist(lms_fv->list, lg_d_cnt)",0)
    CALL parser(concat("lms_fv->list[lg_d_cnt].table_name = '",dm2_ref_data_doc->tbl_qual[lg_cnt].
      table_name,"'"),0)
    CALL parser(concat("lms_fv->list[lg_d_cnt].column_name = '",dm2_ref_data_doc->tbl_qual[lg_cnt].
      root_col_name,"'"),0)
    CALL parser(build("lms_fv->list[lg_d_cnt].from_value = ",lg_alias,".",dm2_ref_data_doc->tbl_qual[
      lg_cnt].root_col_name),0)
    CALL parser("with nocounter, notrim go",1)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(- (1))
    ENDIF
    IF (lg_d_cnt=0)
     CALL parser("select into 'nl:'",0)
     CALL parser(concat("from ",lg_src_fv,lg_alias),0)
     CALL parser(lms_pk_where,0)
     CALL parser(concat(" and ",lg_alias,".active_ind = 1 and ",lg_alias,".",
       dm2_ref_data_doc->tbl_qual[lg_cnt].end_col_name," <= cnvtdatetime(curdate,curtime3)"),0)
     CALL parser(concat(" order by ",lg_alias,".",dm2_ref_data_doc->tbl_qual[lg_cnt].end_col_name,
       " desc "),0)
     CALL parser(" detail ",0)
     CALL parser(" lg_d_cnt = lg_d_cnt +1",0)
     CALL parser("stat = alterlist(lms_fv->list, lg_d_cnt)",0)
     CALL parser(concat("lms_fv->list[lg_d_cnt].table_name = '",dm2_ref_data_doc->tbl_qual[lg_cnt].
       table_name,"'"),0)
     CALL parser(concat("lms_fv->list[lg_d_cnt].column_name = '",dm2_ref_data_doc->tbl_qual[lg_cnt].
       root_col_name,"'"),0)
     CALL parser(build("lms_fv->list[lg_d_cnt].from_value = ",lg_alias,".",dm2_ref_data_doc->
       tbl_qual[lg_cnt].root_col_name),0)
     CALL parser("with nocounter, notrim, maxrec = 1 go",1)
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(- (1))
     ENDIF
    ENDIF
    IF (lg_d_cnt=0)
     CALL parser("select into 'nl:'",0)
     CALL parser(concat("from ",lg_src_fv,lg_alias),0)
     CALL parser(lms_pk_where,0)
     CALL parser(concat(" and ",lg_alias,".active_ind = 0 and ",lg_alias,".",
       dm2_ref_data_doc->tbl_qual[lg_cnt].beg_col_name," <= cnvtdatetime(curdate,curtime3)"),0)
     CALL parser(concat(" and ",lg_alias,".",dm2_ref_data_doc->tbl_qual[lg_cnt].end_col_name,
       " >= cnvtdatetime(curdate,curtime3)"),0)
     CALL parser(" detail ",0)
     CALL parser(" lg_d_cnt = lg_d_cnt +1",0)
     CALL parser("stat = alterlist(lms_fv->list, lg_d_cnt)",0)
     CALL parser(concat("lms_fv->list[lg_d_cnt].table_name = '",dm2_ref_data_doc->tbl_qual[lg_cnt].
       table_name,"'"),0)
     CALL parser(concat("lms_fv->list[lg_d_cnt].column_name = '",dm2_ref_data_doc->tbl_qual[lg_cnt].
       root_col_name,"'"),0)
     CALL parser(build("lms_fv->list[lg_d_cnt].from_value = ",lg_alias,".",dm2_ref_data_doc->
       tbl_qual[lg_cnt].root_col_name),0)
     CALL parser("with nocounter, notrim go",1)
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(- (1))
     ENDIF
    ENDIF
    IF (lg_d_cnt=0)
     CALL parser("select into 'nl:'",0)
     CALL parser(concat("from ",lg_src_fv,lg_alias),0)
     CALL parser(lms_pk_where,0)
     CALL parser(concat(" and ",lg_alias,".active_ind = 0 and ",lg_alias,".",
       dm2_ref_data_doc->tbl_qual[lg_cnt].end_col_name," <= cnvtdatetime(curdate,curtime3)"),0)
     CALL parser(concat(" order by ",lg_alias,".",dm2_ref_data_doc->tbl_qual[lg_cnt].end_col_name,
       " desc "),0)
     CALL parser(" detail ",0)
     CALL parser(" lg_d_cnt = lg_d_cnt +1",0)
     CALL parser("stat = alterlist(lms_fv->list, lg_d_cnt)",0)
     CALL parser(concat("lms_fv->list[lg_d_cnt].table_name = '",dm2_ref_data_doc->tbl_qual[lg_cnt].
       table_name,"'"),0)
     CALL parser(concat("lms_fv->list[lg_d_cnt].column_name = '",dm2_ref_data_doc->tbl_qual[lg_cnt].
       root_col_name,"'"),0)
     CALL parser(build("lms_fv->list[lg_d_cnt].from_value = ",lg_alias,".",dm2_ref_data_doc->
       tbl_qual[lg_cnt].root_col_name),0)
     CALL parser("with nocounter, notrim, maxrec = 1 go",1)
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(- (1))
     ENDIF
    ENDIF
    CALL parser("select into 'nl:'",0)
    CALL parser(concat("from ",lg_src_fv,lg_alias),0)
    CALL parser(lms_pk_where,0)
    CALL parser(concat(" and ",lg_alias,".active_ind = 1 and ",lg_alias,".",
      dm2_ref_data_doc->tbl_qual[lg_cnt].beg_col_name," >= cnvtdatetime(curdate,curtime3)"),0)
    CALL parser(" detail ",0)
    CALL parser(" lg_d_cnt = lg_d_cnt +1",0)
    CALL parser("stat = alterlist(lms_fv->list, lg_d_cnt)",0)
    CALL parser(concat("lms_fv->list[lg_d_cnt].table_name = '",dm2_ref_data_doc->tbl_qual[lg_cnt].
      table_name,"'"),0)
    CALL parser(concat("lms_fv->list[lg_d_cnt].column_name = '",dm2_ref_data_doc->tbl_qual[lg_cnt].
      root_col_name,"'"),0)
    CALL parser(build("lms_fv->list[lg_d_cnt].from_value = ",lg_alias,".",dm2_ref_data_doc->tbl_qual[
      lg_cnt].root_col_name),0)
    CALL parser("with nocounter, notrim go",1)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(- (1))
    ENDIF
    IF (lg_d_cnt=0)
     CALL parser("select into 'nl:'",0)
     CALL parser(concat("from ",lg_src_fv,lg_alias),0)
     CALL parser(lms_pk_where,0)
     CALL parser(concat(" and ",lg_alias,".active_ind = 0 and ",lg_alias,".",
       dm2_ref_data_doc->tbl_qual[lg_cnt].beg_col_name," >= cnvtdatetime(curdate,curtime3)"),0)
     CALL parser(" detail ",0)
     CALL parser(" lg_d_cnt = lg_d_cnt +1",0)
     CALL parser("stat = alterlist(lms_fv->list, lg_d_cnt)",0)
     CALL parser(concat("lms_fv->list[lg_d_cnt].table_name = '",dm2_ref_data_doc->tbl_qual[lg_cnt].
       table_name,"'"),0)
     CALL parser(concat("lms_fv->list[lg_d_cnt].column_name = '",dm2_ref_data_doc->tbl_qual[lg_cnt].
       root_col_name,"'"),0)
     CALL parser(build("lms_fv->list[lg_d_cnt].from_value = ",lg_alias,".",dm2_ref_data_doc->
       tbl_qual[lg_cnt].root_col_name),0)
     CALL parser("with nocounter, notrim go",1)
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(- (1))
     ENDIF
    ENDIF
   ENDIF
   SET lms_fv->fv_cnt = lg_d_cnt
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(lms_fv)
   ENDIF
   FOR (lms_lp_pp = 1 TO lg_d_cnt)
     CALL orphan_child_tab(lms_fv->list[lms_lp_pp].table_name,lg_log_type,lms_fv->list[lms_lp_pp].
      column_name,lms_fv->list[lms_lp_pp].from_value)
     COMMIT
     IF (locateval(lg_log_type_idx,1,global_mover_rec->circ_nomv_excl_cnt,lg_log_type,
      global_mover_rec->circ_nomv_qual[lg_log_type_idx].log_type)=0)
      CALL drcm_block_ptam_circ(dm2_ref_data_doc,lg_cnt,lms_fv->list[lms_lp_pp].column_name,lms_fv->
       list[lms_lp_pp].from_value)
      IF ((dm_err->err_ind=1))
       RETURN(- (1))
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE remove_cached_xlat(rcx_tab_name,rcx_from_value)
   DECLARE rcx_sql_call = vc
   SET rcx_sql_call = concat("begin rdds_xlat.remove_cache_item('",rcx_tab_name,"', ",cnvtstring(
     rcx_from_value,20),"); end;")
   CALL parser(concat("RDB ASIS(^",rcx_sql_call,"^) go"),1)
   IF (check_error("Error removing cached xlat") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE add_xlat_ctxt_r(axc_tab_name,axc_from_value,axc_to_value,axc_ctxt)
   DECLARE axc_found_ind = i2 WITH protect, noconstant(0)
   DECLARE axc_ctxt_found_ind = i2 WITH protect, noconstant(0)
   DECLARE axc_retry_cnt = i4 WITH protect, noconstant(0)
   DECLARE axc_retry_limit = i4 WITH protect, constant(4)
   WHILE (axc_retry_cnt <= axc_retry_limit)
     SET axc_found_ind = 0
     SET axc_ctxt_found_ind = 0
     SELECT INTO "NL:"
      FROM dm_refchg_xlat_ctxt_r r
      WHERE r.table_name=axc_tab_name
       AND r.from_value=axc_from_value
       AND r.to_value=axc_to_value
      DETAIL
       axc_found_ind = 1
       IF (r.context_name=axc_ctxt)
        axc_ctxt_found_ind = 1
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error("Error querying DM_REFCHG_XLAT_CTXT_R") != 0)
      SET axc_retry_cnt = (axc_retry_limit+ 1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(1)
     ENDIF
     IF (axc_found_ind=1
      AND axc_ctxt_found_ind=0)
      INSERT  FROM dm_refchg_xlat_ctxt_r r
       SET dm_refchg_xlat_ctxt_r_id = seq(dm_clinical_seq,nextval), r.table_name = axc_tab_name, r
        .from_value = axc_from_value,
        r.to_value = axc_to_value, r.context_name = axc_ctxt
       WITH nocounter
      ;end insert
      IF (check_error("Error querying DM_REFCHG_XLAT_CTXT_R") != 0)
       IF (axc_retry_cnt <= axc_retry_limit
        AND ((findstring("ORA-00001:",dm_err->emsg) > 0) OR (findstring("ORA-02049:",dm_err->emsg) >
       0)) )
        SET dm_err->user_action =
        "No action required.  Retrying ADD_XLAT_CTXT_R logic because of constraint violation."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        SET dm_err->user_action = ""
        SET dm_err->err_ind = 0
        SET axc_retry_cnt = (axc_retry_cnt+ 1)
       ELSE
        SET axc_retry_cnt = (axc_retry_limit+ 1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(1)
       ENDIF
      ELSE
       SET axc_retry_cnt = (axc_retry_limit+ 1)
      ENDIF
     ELSE
      SET axc_retry_cnt = (axc_retry_limit+ 1)
     ENDIF
   ENDWHILE
   RETURN(0)
 END ;Subroutine
 SUBROUTINE drcm_block_ptam_circ(dbp_rec,dbp_tbl_cnt,dbp_pk_col,dbp_pk_col_value)
   DECLARE dbp_idx_pos = i4 WITH protect, noconstant(0)
   DECLARE dbp_last_col_name = vc WITH protect, noconstant("")
   DECLARE dbp_last_col_value = vc WITH protect, noconstant("")
   DECLARE dbp_circ_loop = i4 WITH protect, noconstant(0)
   DECLARE dbp_to_value = f8 WITH protect, noconstant(0)
   DECLARE dbp_temp_tab = i4 WITH protect, noconstant(0)
   SET dbp_to_value = drcm_get_xlat(cnvtstring(dbp_pk_col_value,20,1),dbp_rec->tbl_qual[dbp_tbl_cnt].
    table_name)
   IF (check_error("Error looking for translation in DRCM_BLOCK_PTAM_CIRC") != 0)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(null)
   ENDIF
   IF (dbp_to_value < 0.0)
    RETURN(null)
   ENDIF
   FOR (dbp_circ_loop = 1 TO dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_cnt)
    IF ((dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[dbp_circ_loop].other_name_col > " "))
     IF ((dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[dbp_circ_loop].other_id_col !=
     dbp_last_col_name))
      SET dbp_last_col_name = dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[dbp_circ_loop].
      other_id_col
      CALL parser(concat("set dbp_last_col_value = RS_",dbp_rec->tbl_qual[dbp_tbl_cnt].suffix,
        "->from_values.",dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[dbp_circ_loop].other_name_col,
        " go"),1)
      SELECT INTO "NL"
       y = evaluate_pe_name(dbp_rec->tbl_qual[dbp_tbl_cnt].table_name,dbp_rec->tbl_qual[dbp_tbl_cnt].
        other_circ_qual[dbp_circ_loop].other_id_col,dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[
        dbp_circ_loop].other_name_col,dbp_last_col_value)
       FROM dual
       DETAIL
        dbp_last_col_value = y
       WITH nocounter
      ;end select
      IF (check_error("Error calling EVALUATE_PE_NAME") != 0)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(null)
      ENDIF
     ENDIF
     IF ((dbp_last_col_value=dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[dbp_circ_loop].7tab_name)
     )
      SET dbp_idx_pos = locateval(dbp_idx_pos,1,dbp_rec->tbl_cnt,dbp_last_col_value,dbp_rec->
       tbl_qual[dbp_idx_pos].table_name)
      IF (dbp_idx_pos=0)
       SET dbp_temp_tab = temp_tbl_cnt
       SET dbp_idx_pos = fill_rs("TABLE",dbp_last_col_value)
       SET temp_tbl_cnt = dbp_temp_tab
       IF ((dbp_idx_pos=- (1)))
        CALL disp_msg("Table can't be created from remote mover",dm_err->logfile,1)
        ROLLBACK
        SET dm_err->err_ind = 1
        RETURN(null)
       ELSEIF ((dbp_idx_pos=- (2)))
        SET drmm_ddl_rollback_ind = 1
        SET dm_err->err_ind = 1
        RETURN(null)
       ELSE
        SET dbp_idx_pos = locateval(dbp_idx_pos,1,dbp_rec->tbl_cnt,dbp_last_col_value,dbp_rec->
         tbl_qual[dbp_idx_pos].table_name)
       ENDIF
      ENDIF
      CALL parser(concat("delete from ",dbp_rec->tbl_qual[dbp_idx_pos].r_table_name," d"),0)
      CALL parser(concat("where d.",dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[dbp_circ_loop].
        7id_col," = dbp_to_value"),0)
      IF ((dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[dbp_circ_loop].7name_col > " "))
       CALL parser(concat(" and evaluate_pe_name('",dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[
         dbp_circ_loop].7tab_name,"','",dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[dbp_circ_loop]
         .7id_col,"','",
         dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[dbp_circ_loop].7name_col,"',d.",dbp_rec->
         tbl_qual[dbp_tbl_cnt].other_circ_qual[dbp_circ_loop].7name_col,
         ") = dbp_rec->tbl_qual[dbp_tbl_cnt].table_name"),0)
      ENDIF
      CALL parser("with nocounter go",1)
     ENDIF
    ELSE
     SET dbp_idx_pos = locateval(dbp_idx_pos,1,dbp_rec->tbl_cnt,dbp_rec->tbl_qual[dbp_tbl_cnt].
      other_circ_qual[dbp_circ_loop].7tab_name,dbp_rec->tbl_qual[dbp_idx_pos].table_name)
     IF (dbp_idx_pos=0)
      SET dbp_temp_tab = temp_tbl_cnt
      SET dbp_idx_pos = fill_rs("TABLE",dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[dbp_circ_loop]
       .7tab_name)
      SET temp_tbl_cnt = dbp_temp_tab
      IF ((dbp_idx_pos=- (1)))
       CALL disp_msg("Table can't be created from remote mover",dm_err->logfile,1)
       ROLLBACK
       SET dm_err->err_ind = 1
       RETURN(null)
      ELSEIF ((dbp_idx_pos=- (2)))
       SET drmm_ddl_rollback_ind = 1
       SET dm_err->err_ind = 1
       RETURN(null)
      ELSE
       SET dbp_idx_pos = locateval(dbp_idx_pos,1,dbp_rec->tbl_cnt,dbp_rec->tbl_qual[dbp_tbl_cnt].
        other_circ_qual[dbp_circ_loop].7tab_name,dbp_rec->tbl_qual[dbp_idx_pos].table_name)
      ENDIF
     ENDIF
     CALL parser(concat("delete from ",dbp_rec->tbl_qual[dbp_idx_pos].r_table_name," d"),0)
     CALL parser(concat("where d.",dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[dbp_circ_loop].
       7id_col," = dbp_to_value"),0)
     IF ((dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[dbp_circ_loop].7name_col > " "))
      CALL parser(concat(" and evaluate_pe_name('",dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[
        dbp_circ_loop].7tab_name,"','",dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[dbp_circ_loop].
        7id_col,"','",
        dbp_rec->tbl_qual[dbp_tbl_cnt].other_circ_qual[dbp_circ_loop].7name_col,"',d.",dbp_rec->
        tbl_qual[dbp_tbl_cnt].other_circ_qual[dbp_circ_loop].7name_col,
        ") = dbp_rec->tbl_qual[dbp_tbl_cnt].table_name"),0)
     ENDIF
     CALL parser("with nocounter go",1)
    ENDIF
    IF (check_error("Error removing circular $R row") != 0)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(null)
    ENDIF
   ENDFOR
   COMMIT
 END ;Subroutine
 SUBROUTINE drcm_get_pk_str(dgps_rec,dgps_tab_name)
   DECLARE dgps_tab_idx = i4 WITH protect, noconstant(0)
   DECLARE dgps_col_loop = i4 WITH protect, noconstant(0)
   DECLARE dgps_col_val = vc WITH protect, noconstant("")
   DECLARE dgps_ret_str = vc WITH protect, noconstant("")
   SET dgps_tab_idx = locateval(dgps_tab_idx,1,dgps_rec->tbl_cnt,dgps_tab_name,dgps_rec->tbl_qual[
    dgps_tab_idx].table_name)
   FOR (dgps_col_loop = 1 TO dgps_rec->tbl_qual[dgps_tab_idx].col_cnt)
     IF ((dgps_rec->tbl_qual[dgps_tab_idx].col_qual[dgps_col_loop].pk_ind=1))
      IF ((dgps_rec->tbl_qual[dgps_tab_idx].col_qual[dgps_col_loop].check_null=1))
       SET dgps_col_val = "<NULL>"
      ELSE
       IF ((dgps_rec->tbl_qual[dgps_tab_idx].col_qual[dgps_col_loop].data_type="DQ8"))
        CALL parser(concat("set dgps_col_val=format(cnvtdatetime(RS_",dgps_rec->tbl_qual[dgps_tab_idx
          ].suffix,"->FROM_VALUES.",dgps_rec->tbl_qual[dgps_tab_idx].col_qual[dgps_col_loop].
          column_name,"), ';;Q') go"),1)
       ELSEIF ((dgps_rec->tbl_qual[dgps_tab_idx].col_qual[dgps_col_loop].data_type="F8"))
        CALL parser(concat("set dgps_col_val = cnvtstring(RS_",dgps_rec->tbl_qual[dgps_tab_idx].
          suffix,"->FROM_VALUES.",dgps_rec->tbl_qual[dgps_tab_idx].col_qual[dgps_col_loop].
          column_name,", 20,1) go"),1)
       ELSEIF ((dgps_rec->tbl_qual[dgps_tab_idx].col_qual[dgps_col_loop].data_type="I*"))
        CALL parser(concat("set dgps_col_val = cnvtstring(RS_",dgps_rec->tbl_qual[dgps_tab_idx].
          suffix,"->FROM_VALUES.",dgps_rec->tbl_qual[dgps_tab_idx].col_qual[dgps_col_loop].
          column_name,") go"),1)
       ELSE
        CALL parser(concat("set dgps_col_val = RS_",dgps_rec->tbl_qual[dgps_tab_idx].suffix,
          "->FROM_VALUES.",dgps_rec->tbl_qual[dgps_tab_idx].col_qual[dgps_col_loop].column_name," go"
          ),1)
       ENDIF
      ENDIF
      IF (dgps_ret_str <= " ")
       SET dgps_ret_str = concat("The primary key values of this row are: ",dgps_rec->tbl_qual[
        dgps_tab_idx].col_qual[dgps_col_loop].column_name,"=",dgps_col_val)
      ELSE
       SET dgps_ret_str = concat(dgps_ret_str,", ",dgps_rec->tbl_qual[dgps_tab_idx].col_qual[
        dgps_col_loop].column_name,"=",dgps_col_val)
      ENDIF
     ENDIF
   ENDFOR
   RETURN(dgps_ret_str)
 END ;Subroutine
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
 DECLARE dm2_rdds_chk_rel_val_rows(sbr_src_env_id=f8,sbr_tgt_env_id=f8,sbr_source_dblink=vc) = vc
 DECLARE dm2_check_xlat_seqmatch(dcx_src_env_id=f8,dcx_tgt_env_id=f8,dcx_dblink=vc) = vc
 DECLARE dm2_write_info_domain(wid_prefix=vc,wid_first_env_id=f8,wid_secnd_env_id=f8,wid_suffix=vc)
  = vc
 DECLARE dm2_rdds_init_display(null) = null
 DECLARE dm2_check_dmt_xlat(dcdx_src_env_id=f8,dcdx_tgt_env_id=f8,dcdx_dblink=vc) = vc
 SUBROUTINE dm2_rdds_chk_rel_val_rows(sbr_src_env_id,sbr_tgt_env_id,sbr_source_dblink)
   DECLARE sbr_tgt_missing_flg = i2
   DECLARE sbr_src_missing_flg = i2
   DECLARE sbr_src_table = vc
   DECLARE sbr_return_string = vc
   DECLARE sbr_info_char_tgt = vc
   DECLARE sbr_info_char_src = vc
   DECLARE sbr_info_domain = vc
   SET sbr_tgt_missing_flg = 0
   SET sbr_src_missing_flg = 0
   SET sbr_return_string = ""
   SET sbr_info_char_tgt = ""
   SET sbr_info_char_src = ""
   SET sbr_info_domain = dm2_write_info_domain("MERGE",sbr_src_env_id,sbr_tgt_env_id," ")
   SET sbr_src_table = concat("DM_INFO",trim(sbr_source_dblink))
   SET dm_err->eproc = "Performing Relationship Validation"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (((trim(sbr_source_dblink)="") OR (((sbr_src_env_id=0) OR (sbr_tgt_env_id=0)) )) )
    SET dm_err->err_ind = 1
    SET dm_err->emsg =
    "INVALID DATABASE LINK, OR SOURCE_ID, OR TARGET_ID FOR THE GIVEN SOURCE/TARGET RELATIONSHIP"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
   SELECT INTO "NL:"
    d.info_char
    FROM dm_info d
    WHERE d.info_name="RELATIONSHIP VALIDATION"
     AND d.info_domain=sbr_info_domain
    DETAIL
     sbr_info_char_tgt = d.info_char
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(sbr_return_string)
   ENDIF
   IF (curqual=0)
    SET sbr_tgt_missing_flg = 1
   ENDIF
   SET sbr_info_domain = dm2_write_info_domain("MERGE",sbr_tgt_env_id,sbr_src_env_id," ")
   SELECT INTO "NL:"
    FROM (parser(sbr_src_table) d)
    WHERE d.info_name="RELATIONSHIP VALIDATION"
     AND d.info_domain=sbr_info_domain
    DETAIL
     sbr_info_char_src = d.info_char
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(sbr_return_string)
   ENDIF
   IF (curqual=0)
    SET sbr_src_missing_flg = 1
   ENDIF
   IF (sbr_tgt_missing_flg=0
    AND sbr_src_missing_flg=0)
    SET sbr_return_string = "BOTH_FOUND"
    IF (sbr_info_char_tgt != sbr_info_char_src)
     SET sbr_return_string = "MISMATCH_FOUND"
    ENDIF
   ELSEIF (sbr_tgt_missing_flg=1
    AND sbr_src_missing_flg=1)
    SET sbr_return_string = "NONE_FOUND"
   ELSEIF (sbr_tgt_missing_flg=1
    AND sbr_src_missing_flg=0)
    SET sbr_return_string = "TGT_MISSING"
   ELSEIF (sbr_tgt_missing_flg=0
    AND sbr_src_missing_flg=1)
    SET sbr_return_string = "SRC_MISSING"
   ENDIF
   SET dm_err->eproc = concat("Relationship Validation Results: ",sbr_return_string)
   CALL disp_msg(" ",dm_err->logfile,0)
   RETURN(sbr_return_string)
 END ;Subroutine
 SUBROUTINE dm2_check_xlat_seqmatch(dcx_src_env_id,dcx_tgt_env_id,dcx_dblink)
   DECLARE sbr_return_var = vc
   DECLARE sbr_xlats_flg = i2
   DECLARE sbr_chk_table_name = vc
   DECLARE sbr_dm_info_domain = vc
   SET sbr_dm_info_domain = ""
   SET sbr_return_var = ""
   SET sbr_xlats_flg = 0
   SET sbr_chk_table_name = ""
   SET dm_err->eproc = "Checking for Translations and Sequence Matches"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (((trim(dcx_dblink)="") OR (((dcx_src_env_id=0) OR (dcx_tgt_env_id=0)) )) )
    SET dm_err->err_ind = 1
    SET dm_err->emsg =
    "INVALID DATABASE LINK OR SOURCE_ID OR TARGET_ID FOR THE GIVEN SOURCE/TARGET RELATIONSHIP"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(sbr_return_var)
   ENDIF
   SET sbr_dm_info_domain = dm2_write_info_domain("MERGE",dcx_src_env_id,dcx_tgt_env_id,"SEQMATCH")
   SET dm_err->eproc = "Checking for Sequence Matches in Target"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "NL:"
    FROM dm_info d
    WHERE d.info_domain=sbr_dm_info_domain
    WITH maxqual(d,1)
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(sbr_return_var)
   ENDIF
   IF (curqual > 0)
    SET sbr_xlats_flg = 1
    SET dm_err->eproc = "Sequence Matches found in target"
    CALL disp_msg(" ",dm_err->logfile,0)
   ELSE
    SET sbr_chk_table_name = concat("DM_INFO",trim(dcx_dblink))
    SET sbr_dm_info_domain = dm2_write_info_domain("MERGE",dcx_tgt_env_id,dcx_src_env_id,"SEQMATCH")
    SET dm_err->eproc = "Checking for Reverse Sequence Matches in Source"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "NL:"
     FROM (parser(sbr_chk_table_name) d)
     WHERE d.info_domain=sbr_dm_info_domain
     WITH maxqual(d,1)
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(sbr_return_var)
    ENDIF
    IF (curqual > 0)
     SET sbr_xlats_flg = 1
     SET dm_err->eproc = "Reverse Sequence Matches found in source"
     CALL disp_msg(" ",dm_err->logfile,0)
    ELSE
     SET dm_err->eproc = "Checking for Translations in Target. May take several minutes."
     CALL disp_msg(" ",dm_err->logfile,0)
     SELECT INTO "NL:"
      FROM dm_merge_translate d
      WHERE d.env_source_id=dcx_src_env_id
       AND d.env_target_id=dcx_tgt_env_id
       AND d.table_name > " "
       AND d.from_value > 0
      WITH maxqual(d,1)
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(sbr_return_var)
     ENDIF
     IF (curqual > 0)
      SET sbr_xlats_flg = 1
      SET dm_err->eproc = "Translations found in target"
      CALL disp_msg(" ",dm_err->logfile,0)
     ELSE
      SET sbr_chk_table_name = concat("DM_MERGE_TRANSLATE",trim(dcx_dblink))
      SET dm_err->eproc = "Checking for Reverse Translations in Source. May take several minutes."
      CALL disp_msg(" ",dm_err->logfile,0)
      SELECT INTO "NL:"
       FROM (parser(sbr_chk_table_name) d)
       WHERE d.env_source_id=dcx_tgt_env_id
        AND d.env_target_id=dcx_src_env_id
        AND d.table_name > " "
        AND d.from_value > 0
       WITH maxqual(d,1)
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(sbr_return_var)
      ENDIF
      IF (curqual > 0)
       SET sbr_xlats_flg = 1
       SET dm_err->eproc = "Reverse translations found in source"
       CALL disp_msg(" ",dm_err->logfile,0)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF ((dm_err->err_ind != 1))
    IF (sbr_xlats_flg=0)
     SET sbr_return_var = "NONE_FOUND"
    ELSEIF (sbr_xlats_flg=1)
     SET sbr_return_var = "XLAT_FOUND"
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Relationship Validation Results: ",sbr_return_var)
   CALL disp_msg(" ",dm_err->logfile,0)
   RETURN(sbr_return_var)
 END ;Subroutine
 SUBROUTINE dm2_check_dmt_xlat(dcdx_src_env_id,dcdx_tgt_env_id,dcdx_dblink)
   DECLARE sbr_return_var = vc WITH protect, noconstant("")
   DECLARE sbr_xlats_flg = i2 WITH protect, noconstant(0)
   DECLARE sbr_chk_table_name = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Checking for Translations"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (((trim(dcdx_dblink)="") OR (((dcdx_src_env_id=0) OR (dcdx_tgt_env_id=0)) )) )
    SET dm_err->err_ind = 1
    SET dm_err->emsg =
    "INVALID DATABASE LINK OR SOURCE_ID OR TARGET_ID FOR THE GIVEN SOURCE/TARGET RELATIONSHIP"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(sbr_return_var)
   ENDIF
   SET dm_err->eproc = "Checking for Translations in Target. May take several minutes."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "NL:"
    FROM dm_merge_translate d
    WHERE d.env_source_id=dcdx_src_env_id
     AND d.env_target_id=dcdx_tgt_env_id
     AND d.table_name > " "
     AND d.from_value > 0
    WITH maxqual(d,1), nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(sbr_return_var)
   ENDIF
   IF (curqual > 0)
    SET sbr_xlats_flg = 1
    SET dm_err->eproc = "Translations found in target"
    CALL disp_msg(" ",dm_err->logfile,0)
   ELSE
    SET sbr_chk_table_name = concat("DM_MERGE_TRANSLATE",trim(dcdx_dblink))
    SET dm_err->eproc = "Checking for Reverse Translations in Source. May take several minutes."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "NL:"
     FROM (parser(sbr_chk_table_name) d)
     WHERE d.env_source_id=dcdx_tgt_env_id
      AND d.env_target_id=dcdx_src_env_id
      AND d.table_name > " "
      AND d.from_value > 0
     WITH maxqual(d,1), nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(sbr_return_var)
    ENDIF
    IF (curqual > 0)
     SET sbr_xlats_flg = 1
     SET dm_err->eproc = "Reverse translations found in source"
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
   ENDIF
   IF ((dm_err->err_ind != 1))
    IF (sbr_xlats_flg=0)
     SET sbr_return_var = "NONE_FOUND"
    ELSEIF (sbr_xlats_flg=1)
     SET sbr_return_var = "XLAT_FOUND"
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Relationship Validation Results: ",sbr_return_var)
   CALL disp_msg(" ",dm_err->logfile,0)
   RETURN(sbr_return_var)
 END ;Subroutine
 SUBROUTINE dm2_write_info_domain(wid_prefix,wid_first_env_id,wid_secnd_env_id,wid_suffix)
   DECLARE wid_return_string = vc
   SET wid_return_string = build(wid_prefix,trim(cnvtstring(wid_first_env_id)),trim(cnvtstring(
      wid_secnd_env_id)),wid_suffix)
   RETURN(wid_return_string)
 END ;Subroutine
 SUBROUTINE dm2_rdds_init_display(null)
   SET message = window
   SET curaccept = ""
   SET width = 132
   CALL clear(1,1)
 END ;Subroutine
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
 DECLARE dci_get_rdds_identifier(null) = vc
 DECLARE dci_set_rdds_identifier(dsri_ident=vc) = null
 SUBROUTINE dci_get_rdds_identifier(null)
   DECLARE sys_context() = c4000
   DECLARE dgri_ora_version = i2 WITH protect, noconstant(0)
   DECLARE dgri_ident = vc WITH protect, noconstant("")
   DECLARE dgri_temp_err = i2 WITH protect, noconstant(0)
   DECLARE dgri_temp_emsg = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Get CLIENT_IDENTIFIER."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dgri_temp_err = dm_err->err_ind
   SET dgri_temp_emsg = dm_err->emsg
   SET dm_err->err_ind = 0
   SELECT INTO "nl:"
    FROM product_component_version p
    WHERE cnvtupper(p.product)="ORACLE*"
    DETAIL
     dgri_ora_version = cnvtint(substring(1,(findstring(".",p.version) - 1),p.version))
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dgri_ident = "NULL"
    SET dm_err->emsg = concat("Error while obtaining Oracle version.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ELSEIF (dgri_ora_version >= 9)
    SELECT INTO "nl:"
     y = sys_context("USERENV","CLIENT_IDENTIFIER")
     FROM dual
     DETAIL
      dgri_ident = y
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET dgri_ident = "NULL"
     SET dm_err->emsg = concat("Error while obtaining CLIENT_IDENTIFIER.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ELSEIF (((dgri_ident="") OR (dgri_ident=" ")) )
     SET dgri_ident = "NULL"
    ENDIF
   ELSE
    SET dgri_ident = "NULL"
   ENDIF
   SET dm_err->err_ind = dgri_temp_err
   SET dm_err->emsg = dgri_temp_emsg
   RETURN(dgri_ident)
 END ;Subroutine
 SUBROUTINE dci_set_rdds_identifier(dsri_ident)
   DECLARE sys_context() = c4000
   DECLARE dsri_ora_version = i2 WITH protect, noconstant(0)
   DECLARE dsri_temp_err = i2 WITH protect, noconstant(0)
   DECLARE dsri_temp_emsg = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Set CLIENT_IDENTIFIER."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dsri_temp_err = dm_err->err_ind
   SET dsri_temp_emsg = dm_err->emsg
   SET dm_err->err_ind = 0
   SELECT INTO "nl:"
    FROM product_component_version p
    WHERE cnvtupper(p.product)="ORACLE*"
    DETAIL
     dsri_ora_version = cnvtint(substring(1,(findstring(".",p.version) - 1),p.version))
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->emsg = concat("Error while obtaining Oracle version.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ELSEIF (dsri_ora_version >= 9)
    IF (dsri_ident="NULL")
     RDB asis ( "begin dbms_session.clear_identifier; end;" )
     END ;Rdb
    ELSE
     CALL parser(concat(^rdb asis("begin dbms_session.set_identifier('^,dsri_ident,^'); end;") go^),1
      )
    ENDIF
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->emsg = concat("Error while setting CLIENT_IDENTIFIER.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ENDIF
   ENDIF
   SET dm_err->err_ind = dsri_temp_err
   SET dm_err->emsg = dsri_temp_emsg
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
 IF (validate(parsed_task_data->request_definition,"-99")="-99")
  FREE RECORD task_info
  RECORD task_info(
    1 process_name = vc
    1 environment_id = f8
    1 qual[*]
      2 error_text = vc
      2 log_file = vc
      2 task_desc = vc
      2 task_level = i4
      2 task_name = vc
      2 task_reply = vc
      2 task_request = vc
    1 total = i4
    1 detail_cnt = i4
    1 detail_qual[*]
      2 event_detail1_txt = vc
      2 event_detail2_txt = vc
      2 event_detail3_txt = vc
      2 event_value = f8
  ) WITH protect
 ENDIF
 IF (validate(parsed_task_data->request_definition,"-99")="-99")
  FREE RECORD parsed_task_data
  RECORD parsed_task_data(
    1 request_definition = vc
    1 var_qual[*]
      2 variable_declaration = vc
    1 var_cnt = i2
    1 set_qual[*]
      2 set_command = vc
    1 set_cnt = i2
    1 reply_definition = vc
    1 error_ind_item = vc
    1 error_msg_item = vc
    1 error_type = vc
    1 no_err_result = vc
  ) WITH protect
 ENDIF
 DECLARE drtq_insert_task_process(i_task_info=vc(ref),i_new_proc_ind=i2) = c1
 DECLARE drtq_update_task_process(i_drtq_id=f8,i_log_file=vc,i_task_status=vc,i_error_text=vc) = c1
 DECLARE drtq_delete_task_process(i_process_name=vc) = c1
 DECLARE drtq_reset_task_process(i_process_name=vc) = c1
 DECLARE drtq_check_task_process(i_process_name=vc) = i2
 DECLARE drtq_parse_task_data(i_task_request=vc,i_task_reply=vc,i_parsed_task_data=vc(ref)) = c1
 DECLARE drtq_extract_val_string(i_tag=vc,io_tagged_str=vc(ref)) = vc
 DECLARE drtq_view_task_process(i_process_name=vc) = null
 SUBROUTINE drtq_insert_task_process(i_task_info,i_new_proc_ind)
   DECLARE ditp_retry_cnt = i2 WITH protect, noconstant(3)
   IF (i_new_proc_ind=1)
    SET stat = alterlist(auto_ver_request->qual,1)
    SET auto_ver_request->qual[1].rdds_event = "Task Queue Started"
    SET auto_ver_request->qual[1].event_reason = cnvtupper(i_task_info->process_name)
    SET auto_ver_request->qual[1].cur_environment_id = i_task_info->environment_id
    SET auto_ver_request->qual[1].paired_environment_id = 0
    SET stat = alterlist(auto_ver_request->qual[1].detail_qual,i_task_info->detail_cnt)
    FOR (i = 1 TO i_task_info->detail_cnt)
      SET auto_ver_request->qual[1].detail_qual[i].event_detail1_txt = i_task_info->detail_qual[i].
      event_detail1_txt
      SET auto_ver_request->qual[1].detail_qual[i].event_detail2_txt = i_task_info->detail_qual[i].
      event_detail2_txt
      SET auto_ver_request->qual[1].detail_qual[i].event_detail3_txt = i_task_info->detail_qual[i].
      event_detail3_txt
      SET auto_ver_request->qual[1].detail_qual[i].event_value = i_task_info->detail_qual[i].
      event_value
    ENDFOR
    EXECUTE dm_rmc_auto_verify_setup
    IF ((auto_ver_reply->status="F"))
     SET dm_err->err_ind = 1
     SET dm_err->emsg = auto_ver_reply->status_msg
     ROLLBACK
     RETURN("F")
    ENDIF
    SET stat = initrec(auto_ver_request)
    SET stat = initrec(auto_ver_reply)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="TASK_RETRY_CNT"
    DETAIL
     ditp_retry_cnt = di.info_number
    WITH nocounter
   ;end select
   IF (check_error("While retrieving override TASK_RETRY_CNT value from DM_INFO") > 0)
    RETURN("F")
   ENDIF
   FOR (ditp_cnt = 1 TO i_task_info->total)
    INSERT  FROM dm_refchg_task_queue drtq
     SET drtq.dm_refchg_task_queue_id = seq(dm_clinical_seq,nextval), drtq.begin_dt_tm = cnvtdatetime
      (curdate,curtime3), drtq.create_dt_tm = cnvtdatetime(curdate,curtime3),
      drtq.error_text = i_task_info->qual[ditp_cnt].error_text, drtq.log_file = i_task_info->qual[
      ditp_cnt].log_file, drtq.process_name = cnvtupper(i_task_info->process_name),
      drtq.rdbhandle_value = - (1), drtq.task_desc = i_task_info->qual[ditp_cnt].task_desc, drtq
      .task_level = i_task_info->qual[ditp_cnt].task_level,
      drtq.task_reply = i_task_info->qual[ditp_cnt].task_reply, drtq.task_request = i_task_info->
      qual[ditp_cnt].task_request, drtq.task_name = i_task_info->qual[ditp_cnt].task_name,
      drtq.task_status = "QUEUED", drtq.task_retry_cnt = ditp_retry_cnt, drtq.updt_id = reqinfo->
      updt_id,
      drtq.updt_task = reqinfo->updt_task, drtq.updt_applctx = reqinfo->updt_applctx, drtq.updt_cnt
       = 0,
      drtq.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
    IF (check_error("While inserting new row into DM_REFCHG_TASK_QUEUE") > 0)
     ROLLBACK
     RETURN("F")
    ENDIF
   ENDFOR
   COMMIT
   RETURN("S")
 END ;Subroutine
 SUBROUTINE drtq_update_task_process(i_drtq_id,i_log_file,i_task_status,i_error_text)
   IF ( NOT (i_task_status IN ("FINISHED", "READY", "RUNNING", "ERROR")))
    CALL disp_msg(concat("'",i_task_status,"' is not a valid task status"),dm_err->logfile,1)
    RETURN("F")
   ELSE
    UPDATE  FROM dm_refchg_task_queue drtq
     SET drtq.task_status = i_task_status, drtq.log_file = i_log_file, drtq.rdbhandle_value =
      cnvtreal(currdbhandle),
      drtq.error_text = i_error_text, drtq.begin_dt_tm =
      IF (i_task_status="RUNNING") cnvtdatetime(curdate,curtime3)
      ELSE drtq.begin_dt_tm
      ENDIF
      , drtq.end_dt_tm =
      IF (i_task_status="FINISHED") cnvtdatetime(curdate,curtime3)
      ELSE drtq.end_dt_tm
      ENDIF
     WHERE drtq.dm_refchg_task_queue_id=i_drtq_id
     WITH nocounter
    ;end update
    IF (check_error(concat("While updating DM_REFCHG_TASK_QUEUE where dm_refchg_task_queue_id = ",
      trim(cnvtstring(i_drtq_id)))) > 0)
     ROLLBACK
     RETURN("F")
    ELSE
     COMMIT
     RETURN("S")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE drtq_delete_task_process(i_process_name)
   DECLARE ddtp_process_name = vc WITH protect, constant(cnvtupper(i_process_name))
   DELETE  FROM dm_refchg_task_queue drtq
    WHERE drtq.process_name=ddtp_process_name
    WITH nocounter
   ;end delete
   IF (check_error(concat("While deleting from DM_REFCHG_TASK_QUEUE where process_name = ",
     ddtp_process_name)) > 0)
    ROLLBACK
    RETURN("F")
   ELSE
    COMMIT
    RETURN("S")
   ENDIF
 END ;Subroutine
 SUBROUTINE drtq_reset_task_process(i_process_name)
   DECLARE drtp_min_lvl = i4 WITH protect, noconstant(0)
   DECLARE drtp_process_name = vc WITH protect, constant(cnvtupper(i_process_name))
   DECLARE drtp_retry_cnt = i2 WITH protect, noconstant(3)
   SELECT INTO "nl:"
    x = min(drtq.task_level)
    FROM dm_refchg_task_queue drtq
    WHERE drtq.process_name=drtp_process_name
     AND drtq.task_status="ERROR"
    DETAIL
     drtp_min_lvl = x
    WITH nocounter
   ;end select
   IF (check_error(concat("While selecting the lowest error task level from ",
     "DM_REFCHG_TASK_QUEUE where process_name = ",drtp_process_name)) > 0)
    RETURN("F")
   ENDIF
   IF (drtp_min_lvl > 0)
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="TASK_RETRY_CNT"
     DETAIL
      drtp_retry_cnt = di.info_number
     WITH nocounter
    ;end select
    IF (check_error("While retrieving override TASK_RETRY_CNT value from DM_INFO") > 0)
     RETURN("F")
    ENDIF
    UPDATE  FROM dm_refchg_task_queue drtq
     SET drtq.task_status = "QUEUED", drtq.task_retry_cnt = drtp_retry_cnt
     WHERE drtq.process_name=drtp_process_name
      AND drtq.task_status="ERROR"
      AND drtq.task_level=drtp_min_lvl
     WITH nocounter
    ;end update
    IF (check_error(concat('While resetting DM_REFCHG_TASK_QUEUE "Error" rows where process_name = ',
      drtp_process_name)) > 0)
     ROLLBACK
     RETURN("F")
    ELSE
     COMMIT
    ENDIF
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE drtq_check_task_process(i_process_name)
   DECLARE dctp_process_name = vc WITH protect, constant(cnvtupper(i_process_name))
   FREE RECORD dctp_tasks
   RECORD dctp_tasks(
     1 qual[*]
       2 task_status = vc
       2 rdbhandle_value = f8
     1 total = i4
   )
   SELECT INTO "nl:"
    FROM dm_refchg_task_queue drtq
    WHERE drtq.process_name=dctp_process_name
    DETAIL
     dctp_tasks->total = (dctp_tasks->total+ 1), stat = alterlist(dctp_tasks->qual,dctp_tasks->total),
     dctp_tasks->qual[dctp_tasks->total].task_status = drtq.task_status,
     dctp_tasks->qual[dctp_tasks->total].rdbhandle_value = drtq.rdbhandle_value
    WITH nocounter
   ;end select
   IF (check_error(concat("While querying DM_REFCHG_TASK_QUEUE where process_name = ",
     dctp_process_name)) > 0)
    RETURN(- (1))
   ELSEIF ((dctp_tasks->total=0))
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(dctp_tasks->total))
    PLAN (d
     WHERE (dctp_tasks->qual[d.seq].task_status != "FINISHED"))
    WITH nocounter
   ;end select
   IF (check_error(concat(
     'While checking for task_statuses other than "FINISHED" for process_name = ',dctp_process_name))
    > 0)
    RETURN(- (1))
   ELSEIF (curqual=0)
    RETURN(2)
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(dctp_tasks->total)),
     gv$session g
    PLAN (d
     WHERE (dctp_tasks->qual[d.seq].task_status != "FINISHED"))
     JOIN (g
     WHERE (g.audsid=dctp_tasks->qual[d.seq].rdbhandle_value))
    WITH nocounter
   ;end select
   IF (curqual=0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(dctp_tasks->total)),
      v$session v
     PLAN (d
      WHERE (dctp_tasks->qual[d.seq].task_status != "FINISHED"))
      JOIN (v
      WHERE (v.audsid=dctp_tasks->qual[d.seq].rdbhandle_value))
     WITH nocounter
    ;end select
   ENDIF
   IF (check_error(concat("While checking for actively running tasks for process_name = ",
     dctp_process_name)) > 0)
    RETURN(- (1))
   ELSEIF (curqual=0)
    RETURN(3)
   ELSE
    RETURN(4)
   ENDIF
 END ;Subroutine
 SUBROUTINE drtq_parse_task_data(i_task_request,i_task_reply,i_parsed_task_data)
   DECLARE dptd_temp_str = vc WITH protect, noconstant("")
   DECLARE dptd_val_str = vc WITH protect, noconstant("")
   SET dptd_val_str = drtq_extract_val_string("VAR_DEF",i_task_request)
   WHILE (dptd_val_str > "")
     SET parsed_task_data->var_cnt = (parsed_task_data->var_cnt+ 1)
     SET stat = alterlist(parsed_task_data->var_qual,parsed_task_data->var_cnt)
     SET parsed_task_data->var_qual[parsed_task_data->var_cnt].variable_declaration = dptd_val_str
     SET dptd_val_str = drtq_extract_val_string("VAR_DEF",i_task_request)
   ENDWHILE
   SET dptd_val_str = drtq_extract_val_string("VAL_SET",i_task_request)
   WHILE (dptd_val_str > "")
     SET parsed_task_data->set_cnt = (parsed_task_data->set_cnt+ 1)
     SET stat = alterlist(parsed_task_data->set_qual,parsed_task_data->set_cnt)
     SET parsed_task_data->set_qual[parsed_task_data->set_cnt].set_command = dptd_val_str
     SET dptd_val_str = drtq_extract_val_string("VAL_SET",i_task_request)
   ENDWHILE
   SET parsed_task_data->request_definition = drtq_extract_val_string("REC_DEF",i_task_request)
   SET parsed_task_data->error_ind_item = drtq_extract_val_string("ERR_IND",i_task_reply)
   SET parsed_task_data->error_msg_item = drtq_extract_val_string("ERR_MSG",i_task_reply)
   SET parsed_task_data->error_type = drtq_extract_val_string("ERR_TYPE",i_task_reply)
   SET parsed_task_data->no_err_result = drtq_extract_val_string("NO_ERR_RESULT",i_task_reply)
   SET parsed_task_data->reply_definition = drtq_extract_val_string("REC_DEF",i_task_reply)
   IF (check_error("While parsing the task_request and task_reply data") > 0)
    RETURN("F")
   ELSE
    RETURN("S")
   ENDIF
 END ;Subroutine
 SUBROUTINE drtq_extract_val_string(i_tag,io_tagged_str)
   DECLARE devs_start = i4 WITH protect, noconstant(0)
   DECLARE devs_end = i4 WITH protect, noconstant(0)
   DECLARE devs_len = i4 WITH protect, noconstant(0)
   DECLARE devs_val_str = vc WITH protect, noconstant("")
   SET devs_start = findstring(concat("<",i_tag,">"),io_tagged_str)
   IF (devs_start=0)
    RETURN("")
   ENDIF
   SET devs_end = findstring(concat("</",i_tag,">"),io_tagged_str,devs_start)
   IF (devs_end=0)
    RETURN("")
   ENDIF
   SET devs_len = size(i_tag,1)
   SET devs_val_str = substring(((devs_start+ devs_len)+ 2),(devs_end - ((devs_start+ devs_len)+ 2)),
    io_tagged_str)
   SET io_tagged_str = concat(substring(1,(devs_start - 1),io_tagged_str),substring(((devs_end+
     devs_len)+ 3),(size(io_tagged_str,1) - ((devs_end+ devs_len)+ 2)),io_tagged_str))
   RETURN(devs_val_str)
 END ;Subroutine
 SUBROUTINE drtq_view_task_process(i_process_name)
   DECLARE dvtp_temp_str = vc WITH protect, noconstant("")
   DECLARE dvtp_temp_int = i2 WITH protect, noconstant(0)
   DECLARE dvtp_spacer_str = vc WITH protect, constant(fillstring(60,"-"))
   DECLARE dvtp_ndx = i2 WITH protect, noconstant(0)
   DECLARE dvtp_refresh = c1 WITH protect, noconstant("R")
   DECLARE dvtp_process_name = vc WITH protect, constant(cnvtupper(i_process_name))
   DECLARE dvtp_header = vc WITH protect, constant(concat("*** RDDS ",dvtp_process_name,
     " STATUS REPORT ***"))
   DECLARE dvtp_header_offset = i2 WITH protect, constant(ceil(((129 - size(dvtp_header,1))/ 2)))
   FREE RECORD dvtp_tasks
   RECORD dvtp_tasks(
     1 completed_count = i2
     1 error_count = i2
     1 total = i4
   )
   SET message = window
   SET accept = time(30)
   WHILE (dvtp_refresh="R")
     UPDATE  FROM dm_refchg_task_queue d
      SET d.task_status = "QUEUED", d.task_retry_cnt = (d.task_retry_cnt - 1), d.rdbhandle_value =
       - (1),
       d.log_file = null, d.begin_dt_tm = null, d.end_dt_tm = null,
       d.updt_id = reqinfo->updt_id, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_applctx =
       reqinfo->updt_applctx,
       d.updt_task = reqinfo->updt_task, d.updt_cnt = (d.updt_cnt+ 1)
      WHERE d.task_status="RUNNING"
       AND d.task_retry_cnt > 0
       AND  NOT ( EXISTS (
      (SELECT
       "x"
       FROM gv$session gv
       WHERE gv.audsid=d.rdbhandle_value)))
       AND  NOT ( EXISTS (
      (SELECT
       "x"
       FROM v$session v
       WHERE v.audsid=d.rdbhandle_value)))
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN
     ELSE
      COMMIT
     ENDIF
     IF (curqual > 0)
      UPDATE  FROM dm_refchg_task_queue d
       SET d.task_status = "ERROR", d.error_text =
        "Task has failed on all retries, session id remains inactive"
       WHERE d.task_status="QUEUED"
        AND (d.rdbhandle_value=- (1))
        AND d.task_retry_cnt=0
       WITH nocounter
      ;end update
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       ROLLBACK
       RETURN
      ELSE
       COMMIT
      ENDIF
     ENDIF
     SELECT INTO "nl:"
      drtq.task_status, y = count(drtq.task_status)
      FROM dm_refchg_task_queue drtq
      WHERE drtq.process_name=dvtp_process_name
      GROUP BY drtq.task_status
      HEAD REPORT
       dvtp_tasks->total = 0, dvtp_tasks->error_count = 0, dvtp_tasks->completed_count = 0
      DETAIL
       dvtp_tasks->total = (dvtp_tasks->total+ y)
       IF (drtq.task_status="FINISHED")
        dvtp_tasks->completed_count = y
       ENDIF
       IF (drtq.task_status="ERROR")
        dvtp_tasks->error_count = y
       ENDIF
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN
     ENDIF
     CALL clear(1,1)
     SET width = 132
     CALL text(1,dvtp_header_offset,dvtp_header)
     CALL text(3,1,concat("Report Created: ",format(cnvtdatetime(curdate,curtime3),
        "DD-MMM-YYYY HH:MM;;D")," (list will auto-refresh every 30 seconds)"))
     CALL text(5,1,concat("Tasks Completed: ",trim(cnvtstring(dvtp_tasks->completed_count)),
       " out of ",trim(cnvtstring(dvtp_tasks->total))," total"))
     CALL text(6,1,concat("Number of Tasks with Errors: ",trim(cnvtstring(dvtp_tasks->error_count))))
     CALL text(8,1,"Tasks currently in progress (up to 12 tasks will be displayed):")
     CALL text(9,1,"Task Description")
     CALL text(9,101,"Execution Start Time")
     CALL text(10,1,fillstring(120,"-"))
     IF ((dvtp_tasks->total=0))
      CALL text(15,20,concat("No tasks have been detected for ",dvtp_process_name,"."))
     ELSE
      SELECT INTO "nl:"
       FROM dm_refchg_task_queue drtq
       WHERE drtq.process_name=dvtp_process_name
        AND drtq.task_status="RUNNING"
       ORDER BY drtq.task_level
       HEAD REPORT
        dvtp_ndx = 11
       DETAIL
        CALL text(dvtp_ndx,1,drtq.task_desc),
        CALL text(dvtp_ndx,104,format(drtq.begin_dt_tm,"DD-MMM-YYYY HH:MM;;D")), dvtp_ndx = (dvtp_ndx
        + 1)
       WITH nocounter, maxqual(drtq,12)
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN
      ENDIF
     ENDIF
     CALL text(23,1,fillstring(120,"-"))
     CALL text(24,1,"Command Options:")
     SET accept = nopatcheck
     IF ((dvtp_tasks->error_count > 0))
      CALL text(24,20,"(R)efresh, (V)iew All Task Details , View (E)rror Details, e(X)it")
      CALL accept(24,18,"P;CU","R"
       WHERE curaccept IN ("R", "V", "E", "X"))
     ELSE
      CALL text(24,20,"(R)efresh, (V)iew All Task Details , e(X)it")
      CALL accept(24,18,"P;CU","R"
       WHERE curaccept IN ("R", "V", "X"))
     ENDIF
     SET accept = patcheck
     SET dvtp_refresh = curaccept
     IF (dvtp_refresh="V")
      SELECT
       task_level = drtq.task_level, task_description = drtq.task_desc, task_status = drtq
       .task_status,
       start_time = format(drtq.begin_dt_tm,"DD-MMM-YYYY HH:MM;;D"), end_time = format(drtq.end_dt_tm,
        "DD-MMM-YYYY HH:MM;;D")
       FROM dm_refchg_task_queue drtq
       WHERE drtq.process_name=dvtp_process_name
       ORDER BY drtq.task_level
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN
      ENDIF
      SET dvtp_refresh = "R"
     ELSEIF (dvtp_refresh="E")
      SELECT
       FROM dm_refchg_task_queue drtq
       WHERE process_name=dvtp_process_name
        AND task_status="ERROR"
       HEAD REPORT
        col dvtp_header_offset, dvtp_header, row + 2,
        col 0, "Report Created:", dvtp_temp_str = format(cnvtdatetime(curdate,curtime3),
         "DD-MMM-YYYY HH:MM;;D"),
        col + 1, dvtp_temp_str, row + 2,
        col 0, "Tasks Completed: ", dvtp_temp_str = trim(cnvtstring(dvtp_tasks->completed_count)),
        col + 1, dvtp_temp_str, " out of ",
        dvtp_temp_str = trim(cnvtstring(dvtp_tasks->total)), col + 1, dvtp_temp_str,
        " total", row + 2, col 0,
        "The following tasks are in a failed status:", row + 1, col 0,
        dvtp_spacer_str
       DETAIL
        row + 2, col 0, "Task Description:",
        col 18, drtq.task_desc, row + 1,
        "Log File Name:", col 18, drtq.log_file,
        row + 1, "Error Message:", dvtp_ndx = 1,
        dvtp_temp_int = size(trim(drtq.error_text),1), dvtp_temp_str = trim(substring(dvtp_ndx,100,
          drtq.error_text)), col 18,
        dvtp_temp_str, dvtp_ndx = (dvtp_ndx+ 100)
        WHILE (dvtp_ndx < dvtp_temp_int)
          row + 1, dvtp_temp_str = trim(substring(dvtp_ndx,100,drtq.error_text)), col 18,
          dvtp_temp_str, dvtp_ndx = (dvtp_ndx+ 100)
        ENDWHILE
        row + 2, col 0, dvtp_spacer_str
       FOOT REPORT
        row + 2, col 52, "*** END OF REPORT ***"
       WITH nocounter, formfeed = none
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN
      ENDIF
      SET dvtp_refresh = "R"
     ENDIF
   ENDWHILE
   SET accept = time(0)
   SET message = nowindow
 END ;Subroutine
 DECLARE drcr_get_relationship_type(null) = i2
 DECLARE drcr_get_ptam_config(i_source_env_id=f8,i_target_env_id=f8) = i2
 DECLARE drcr_get_cutover_config(i_source_env_id=f8,i_target_env_id=f8) = i2
 DECLARE drcr_get_dual_build_config(i_source_env_id=f8,i_target_env_id=f8) = i2
 DECLARE drcr_get_full_circle_config(i_source_env_id=f8,i_target_env_id=f8) = i2
 DECLARE drcr_check_all_config(i_config_info_rec=vc(ref)) = null
 DECLARE drcr_get_config_text(i_config_type=vc,i_config_setting=i2) = vc
 DECLARE drcr_check_cbc_setup(i_source_env_id=f8,i_target_env_id=f8,ccs_msg=vc(ref)) = null
 IF ((validate(drcr_reltn_type_list->count,- (1))=- (1)))
  FREE RECORD drcr_reltn_type_list
  RECORD drcr_reltn_type_list(
    1 qual[*]
      2 type = vc
    1 source_env_id = f8
    1 target_env_id = f8
    1 count = i2
  )
 ENDIF
 IF ((validate(drcr_config_info->config_complete_ind,- (1))=- (1)))
  FREE RECORD drcr_config_info
  RECORD drcr_config_info(
    1 source_env_id = f8
    1 target_env_id = f8
    1 config_complete_ind = i2
    1 error_ind = i2
    1 error_msg = vc
  )
 ENDIF
 IF ((validate(drcr_ccs_info->cbc_ind,- (1))=- (1)))
  FREE RECORD drcr_ccs_info
  RECORD drcr_ccs_info(
    1 cbc_ind = i2
    1 return_ind = i2
    1 return_msg = vc
  )
 ENDIF
 SUBROUTINE drcr_get_relationship_type(null)
   DECLARE dgrt_relationship_type = vc WITH protect, noconstant("NOT CONFIGURED")
   DECLARE dgrt_ndx = i2 WITH protect, noconstant(0)
   DECLARE dgrt_return = i2 WITH protect, noconstant(- (1))
   SELECT INTO "nl:"
    FROM dm_env_reltn der
    WHERE (der.parent_env_id=drcr_reltn_type_list->source_env_id)
     AND (der.child_env_id=drcr_reltn_type_list->target_env_id)
     AND expand(dgrt_ndx,1,drcr_reltn_type_list->count,der.relationship_type,drcr_reltn_type_list->
     qual[dgrt_ndx].type)
    DETAIL
     dgrt_relationship_type = der.relationship_type
    WITH nocounter
   ;end select
   SET dgrt_return = (locateval(dgrt_ndx,1,drcr_reltn_type_list->count,dgrt_relationship_type,
    drcr_reltn_type_list->qual[dgrt_ndx].type) - 1)
   RETURN(dgrt_return)
 END ;Subroutine
 SUBROUTINE drcr_get_ptam_config(i_source_env_id,i_target_env_id)
   SET stat = initrec(drcr_reltn_type_list)
   SET drcr_reltn_type_list->source_env_id = i_source_env_id
   SET drcr_reltn_type_list->target_env_id = i_target_env_id
   SET stat = alterlist(drcr_reltn_type_list->qual,2)
   SET drcr_reltn_type_list->count = 2
   SET drcr_reltn_type_list->qual[1].type = "NO PENDING TARGET AS MASTER"
   SET drcr_reltn_type_list->qual[2].type = "PENDING TARGET AS MASTER"
   RETURN(drcr_get_relationship_type(null))
 END ;Subroutine
 SUBROUTINE drcr_get_cutover_config(i_source_env_id,i_target_env_id)
   SET stat = initrec(drcr_reltn_type_list)
   SET drcr_reltn_type_list->source_env_id = i_source_env_id
   SET drcr_reltn_type_list->target_env_id = i_target_env_id
   SET stat = alterlist(drcr_reltn_type_list->qual,2)
   SET drcr_reltn_type_list->count = 2
   SET drcr_reltn_type_list->qual[1].type = "AUTO CUTOVER"
   SET drcr_reltn_type_list->qual[2].type = "PLANNED CUTOVER"
   RETURN(drcr_get_relationship_type(null))
 END ;Subroutine
 SUBROUTINE drcr_get_dual_build_config(i_source_env_id,i_target_env_id)
   SET stat = initrec(drcr_reltn_type_list)
   SET drcr_reltn_type_list->source_env_id = i_source_env_id
   SET drcr_reltn_type_list->target_env_id = i_target_env_id
   SET stat = alterlist(drcr_reltn_type_list->qual,2)
   SET drcr_reltn_type_list->count = 2
   SET drcr_reltn_type_list->qual[1].type = "ALLOW DUAL BUILD"
   SET drcr_reltn_type_list->qual[2].type = "BLOCK DUAL BUILD"
   RETURN(drcr_get_relationship_type(null))
 END ;Subroutine
 SUBROUTINE drcr_get_full_circle_config(i_source_env_id,i_target_env_id)
   SET stat = initrec(drcr_reltn_type_list)
   SET drcr_reltn_type_list->source_env_id = i_source_env_id
   SET drcr_reltn_type_list->target_env_id = i_target_env_id
   SET stat = alterlist(drcr_reltn_type_list->qual,1)
   SET drcr_reltn_type_list->count = 1
   SET drcr_reltn_type_list->qual[1].type = "RDDS MOVER CHANGES NOT LOGGED"
   RETURN((drcr_get_relationship_type(null)+ 1))
 END ;Subroutine
 SUBROUTINE drcr_check_all_config(i_config_info_rec)
  IF (drcr_get_cutover_config(i_config_info_rec->source_env_id,i_config_info_rec->target_env_id) >= 0
  )
   IF (drcr_get_dual_build_config(i_config_info_rec->source_env_id,i_config_info_rec->target_env_id)
    >= 0)
    SET i_config_info_rec->config_complete_ind = 1
    IF (drcr_get_full_circle_config(i_config_info_rec->source_env_id,i_config_info_rec->target_env_id
     )=1)
     IF ((drcr_get_ptam_config(i_config_info_rec->source_env_id,i_config_info_rec->target_env_id)=- (
     1)))
      SET i_config_info_rec->config_complete_ind = 0
     ENDIF
    ENDIF
   ENDIF
  ENDIF
  IF (check_error(dm_err->eproc) != 0)
   SET i_config_info_rec->error_ind = 1
   SET i_config_info_rec->error_msg = dm_err->emsg
  ELSE
   IF ((i_config_info_rec->config_complete_ind=0))
    SET i_config_info_rec->error_msg = concat(
     "The process is unable to proceed because one or more of the required mover ",
     'configurations have not been setup.  Please go to the "Configure RDDS Settings" option under the "Manage RDDS ',
     'Post Domain Copy" option in the DM_MERGE_DOMAIN_ADM script.')
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE drcr_get_config_text(i_config_type,i_config_setting)
   IF ((i_config_setting=- (1)))
    RETURN("Not Configured")
   ELSE
    CASE (trim(cnvtupper(i_config_type)))
     OF "PTAM":
      IF (i_config_setting=0)
       RETURN("NO PENDING TARGET AS MASTER")
      ELSE
       RETURN("PENDING TARGET AS MASTER")
      ENDIF
     OF "DUAL BUILD":
      IF (i_config_setting=0)
       RETURN("ALLOW DUAL BUILD")
      ELSE
       RETURN("BLOCK DUAL BUILD")
      ENDIF
     OF "CUTOVER":
      IF (i_config_setting=0)
       RETURN("AUTO CUTOVER")
      ELSE
       RETURN("PLANNED CUTOVER")
      ENDIF
     ELSE
      RETURN("Unknown Configuration Type")
    ENDCASE
   ENDIF
 END ;Subroutine
 SUBROUTINE drcr_check_cbc_setup(i_source_env_id,i_target_env_id,ccs_msg)
   DECLARE dccs_ctp = vc WITH protect, noconstant("")
   SET drcr_ccs_info->return_ind = 0
   SET drcr_ccs_info->cbc_ind = 0
   SET drcr_ccs_info->return_msg = ""
   SELECT INTO "NL:"
    FROM dm_info d
    WHERE d.info_domain="RDDS CONFIGURATION"
     AND d.info_name="CUTOVER BY CONTEXT"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET drcr_ccs_info->return_msg = dm_err->emsg
    SET drcr_ccs_info->return_ind = 1
    RETURN(null)
   ENDIF
   IF (curqual=0)
    SET drcr_ccs_info->return_ind = 0
    SET drcr_ccs_info->cbc_ind = 0
    RETURN(null)
   ELSE
    SET drcr_ccs_info->cbc_ind = 1
   ENDIF
   SELECT INTO "NL:"
    FROM dm_info d
    WHERE d.info_domain="RDDS CONTEXT"
     AND d.info_name="CONTEXTS TO PULL"
    DETAIL
     dccs_ctp = d.info_char
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    SET drcr_ccs_info->return_msg = dm_err->emsg
    SET drcr_ccs_info->return_ind = 1
    RETURN(null)
   ENDIF
   IF (((findstring("::",dccs_ctp,1,0) > 0) OR (cnvtupper(dccs_ctp)="ALL")) )
    SELECT INTO "NL:"
     FROM dm_info d
     WHERE d.info_domain="RDDS CONTEXT"
      AND d.info_name="CONTEXT GROUP_IND"
      AND d.info_number=0
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     SET drcr_ccs_info->return_msg = dm_err->emsg
     SET drcr_ccs_info->return_ind = 1
     RETURN(null)
    ENDIF
    IF (curqual=0)
     SET drcr_ccs_info->return_msg = concat(
      "The RDDS mover configuration must be set up to maintain contexts that are being pulled, ",
      "in order for cutover by context to be used.  Please correct the setup through DM_MERGE_DOMAIN_ADM."
      )
     SET drcr_ccs_info->return_ind = 1
     RETURN(null)
    ENDIF
   ELSE
    SELECT INTO "NL:"
     FROM dm_info d
     WHERE d.info_domain="RDDS CONTEXT"
      AND d.info_name="CONTEXT GROUP_IND"
      AND d.info_number=1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     SET drcr_ccs_info->return_msg = dm_err->emsg
     SET drcr_ccs_info->return_ind = 1
     RETURN(null)
    ENDIF
    IF (curqual=0)
     SET drcr_ccs_info->return_msg = concat(
      "When only pulling 1 context, the CONTEXT GROUP_IND row must be set to 1.  Please use DM_MERGE_DOMAIN_ADM to setup ",
      "the context information for the merge, so that it is performed correctly.")
     SET drcr_ccs_info->return_ind = 1
     RETURN(null)
    ENDIF
   ENDIF
   SET dccs_ctp = concat("::",dccs_ctp,"::")
   IF (((findstring("::NULL::",cnvtupper(dccs_ctp),1,0) > 0) OR (findstring("::ALL::",cnvtupper(
     dccs_ctp),1,0) > 0)) )
    SELECT INTO "NL:"
     FROM dm_info d
     WHERE d.info_domain="RDDS CONTEXT"
      AND d.info_name="DEFAULT CONTEXT"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     SET drcr_ccs_info->return_msg = dm_err->emsg
     SET drcr_ccs_info->return_ind = 1
     RETURN(null)
    ENDIF
    IF (curqual=0)
     SET drcr_ccs_info->return_msg = concat(
      "The RDDS mover configuration must have a default context supplied if pulling NULL or ALL. ",
      "Please correct the setup through DM_MERGE_DOMAIN_ADM.")
     SET drcr_ccs_info->return_ind = 1
     RETURN(null)
    ENDIF
   ENDIF
   SELECT INTO "NL:"
    FROM user_objects u
    WHERE u.object_name IN ("DM_RDDS_DMT_DEL", "DM_RDDS_DMT_INS", "DM_RDDS_DMT_UPD")
     AND u.object_type="TRIGGER"
     AND status="VALID"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (curqual != 3)
    SET drcr_ccs_info->return_msg =
    "One of the DM_MERGE_TRANSLATE triggers is missing.  Please run DM_RMC_CREATE_DMT_TRIG to create the triggers."
    SET drcr_ccs_info->return_ind = 1
   ENDIF
   RETURN(null)
 END ;Subroutine
 IF (validate(dm_load_reply->status,"$")="$")
  RECORD dm_load_reply(
    1 status = c1
    1 status_msg = vc
    1 ins_meaning = vc
    1 description = vc
    1 run_time_flag = i4
    1 run_order = i4
    1 ins_table_name = vc
  )
 ENDIF
 IF (validate(dm_load_request->file_name,"-+")="-+")
  RECORD dm_load_request(
    1 file_name = vc
  )
 ENDIF
 IF (validate(dm_run_reply->status,"$")="$")
  RECORD dm_run_reply(
    1 status = c1
    1 status_msg = vc
    1 log_file = vc
    1 ins_meaning = vc
  )
 ENDIF
 IF (validate(dm_run_request->ins_meaning,"-+")="-+")
  RECORD dm_run_request(
    1 ins_meaning = vc
    1 diagnostic_ind = i2
    1 where_clause = vc
  )
 ENDIF
 IF (validate(dm_get_reply->status,"$")="$")
  RECORD dm_get_reply(
    1 status = vc
    1 status_msg = vc
    1 ins_cnt = i4
    1 ins_qual[*]
      2 ins_meaning = vc
      2 ins_status = vc
      2 ins_message = vc
      2 ins_log_file = vc
  )
 ENDIF
 IF ((validate(dm_get_request->run_cnt,- (99))=- (99)))
  RECORD dm_get_request(
    1 run_cnt = i4
    1 table_name = vc
    1 run_qual[*]
      2 run_time_flag = i4
  )
 ENDIF
 DECLARE replace_delim_vals(rcs_string=vc,rcs_size=i4) = vc
 DECLARE replace_char(rc_string=vc) = vc
 SUBROUTINE replace_delim_vals(rcs_string,rcs_size)
   DECLARE rcs_start_idx = i4
   DECLARE rcs_pos = i4
   DECLARE rcs_return = vc
   DECLARE rcs_temp_val = vc
   DECLARE rcs_concat = vc
   DECLARE rcs_size_diff = i4
   CALL echo(rcs_string)
   SET rcs_temp_val = rcs_string
   IF (rcs_size > 0)
    SET rcs_size_diff = (rcs_size - size(rcs_temp_val))
   ENDIF
   IF (findstring("^",rcs_temp_val,0,0) > 0)
    IF (findstring('"',rcs_temp_val,0,0) > 0)
     IF (findstring("'",rcs_temp_val,0,0) > 0)
      SET rcs_start_idx = 1
      SET rcs_pos = findstring("^",rcs_temp_val,1,0)
      WHILE (rcs_pos > 0)
        IF (rcs_start_idx=1)
         IF (rcs_pos=1)
          SET rcs_return = "char(94)"
         ELSE
          SET rcs_return = concat("concat(^",substring(rcs_start_idx,(rcs_pos - 1),rcs_temp_val),
           "^,char(94)")
         ENDIF
        ELSE
         SET rcs_return = concat(rcs_return,",^",substring(rcs_start_idx,(rcs_pos - rcs_start_idx),
           rcs_temp_val),"^,char(94)")
        ENDIF
        SET rcs_start_idx = (rcs_pos+ 1)
        SET rcs_pos = findstring("^",rcs_temp_val,rcs_start_idx,0)
        CALL echo(rcs_return)
      ENDWHILE
      IF (rcs_start_idx <= size(rcs_temp_val))
       SET rcs_pos = findstring("^",rcs_temp_val,1,1)
       IF (rcs_size_diff > 0)
        SET rcs_return = concat(rcs_return,",^",substring(rcs_start_idx,(size(rcs_temp_val) - rcs_pos
          ),rcs_temp_val),fillstring(value(rcs_size_diff)," "),"^)")
       ELSE
        SET rcs_return = concat(rcs_return,",^",substring(rcs_start_idx,(size(rcs_temp_val) - rcs_pos
          ),rcs_temp_val),"^)")
       ENDIF
      ENDIF
      CALL echo(rcs_return)
      RETURN(rcs_return)
     ELSE
      SET rcs_return = concat("'",rcs_temp_val,fillstring(value(rcs_size_diff)," "),"'")
      RETURN(rcs_return)
     ENDIF
    ELSE
     SET rcs_return = concat('"',rcs_temp_val,fillstring(value(rcs_size_diff)," "),'"')
     RETURN(rcs_return)
    ENDIF
   ELSE
    SET rcs_return = concat("^",rcs_temp_val,fillstring(value(rcs_size_diff)," "),"^")
    RETURN(rcs_return)
   ENDIF
 END ;Subroutine
 SUBROUTINE replace_char(rc_string)
   DECLARE rc_return = vc
   DECLARE rc_char_pos = i4
   DECLARE rc_char_loop = i2
   DECLARE rc_delim_val = vc
   DECLARE rc_last_ind = i2
   DECLARE rc_only_ind = i2
   SET rc_return = rc_string
   SET rc_only_ind = 0
   SET rc_last_ind = 0
   SET rc_char_ind = 0
   SET rc_char_loop = 0
   WHILE (rc_char_loop=0)
    SET rc_char_pos = findstring(char(0),rc_return,0,0)
    IF (rc_char_pos > 0)
     IF (rc_char_ind=0)
      IF (findstring("'",rc_return,0,0)=0)
       SET rc_delim_val = "'"
      ELSEIF (findstring('"',rc_return,0,0)=0)
       SET rc_delim_val = '"'
      ELSEIF (findstring("^",rc_return,0,0)=0)
       SET rc_delim_val = "^"
      ENDIF
     ENDIF
     IF (rc_char_pos=size(rc_return)
      AND rc_char_pos=1)
      SET rc_return = "char(0)"
      SET rc_last_ind = 1
      SET rc_only_ind = 1
     ELSEIF (rc_char_pos=size(rc_return)
      AND rc_char_pos != 1)
      SET rc_last_ind = 1
      IF (rc_char_ind=0)
       IF (rc_delim_val="'")
        SET rc_return = concat("'",substring(1,(rc_char_pos - 1),rc_return),"',char(0)")
       ELSEIF (rc_delim_val='"')
        SET rc_return = concat('"',substring(1,(rc_char_pos - 1),rc_return),'",char(0)')
       ELSEIF (rc_delim_val="^")
        SET rc_return = concat("^",substring(1,(rc_char_pos - 1),rc_return),"^,char(0)")
       ENDIF
      ELSE
       IF (substring((rc_char_pos - 1),1,rc_return)=rc_delim_val)
        IF (rc_delim_val="'")
         SET rc_return = concat(substring(1,(rc_char_pos - 3),rc_return),",char(0)")
        ELSEIF (rc_delim_val='"')
         SET rc_return = concat(substring(1,(rc_char_pos - 3),rc_return),",char(0)")
        ELSEIF (rc_delim_val="^")
         SET rc_return = concat(substring(1,(rc_char_pos - 3),rc_return),",char(0)")
        ENDIF
       ELSE
        IF (rc_delim_val="'")
         SET rc_return = concat(substring(1,(rc_char_pos - 1),rc_return),"',char(0)")
        ELSEIF (rc_delim_val='"')
         SET rc_return = concat(substring(1,(rc_char_pos - 1),rc_return),'",char(0)')
        ELSEIF (rc_delim_val="^")
         SET rc_return = concat(substring(1,(rc_char_pos - 1),rc_return),"^,char(0)")
        ENDIF
       ENDIF
      ENDIF
     ELSEIF (rc_char_pos=1)
      IF (rc_delim_val="'")
       SET rc_return = concat("char(0),'",substring((rc_char_pos+ 1),size(rc_return),rc_return))
      ELSEIF (rc_delim_val='"')
       SET rc_return = concat('char(0),"',substring((rc_char_pos+ 1),size(rc_return),rc_return))
      ELSEIF (rc_delim_val="^")
       SET rc_return = concat("char(0),^",substring((rc_char_pos+ 1),size(rc_return),rc_return))
      ENDIF
     ELSE
      IF (rc_char_ind=0)
       IF (rc_delim_val="'")
        SET rc_return = concat("'",substring(1,(rc_char_pos - 1),rc_return),"',char(0),'",substring((
          rc_char_pos+ 1),size(rc_return),rc_return))
       ELSEIF (rc_delim_val='"')
        SET rc_return = concat('"',substring(1,(rc_char_pos - 1),rc_return),'",char(0),"',substring((
          rc_char_pos+ 1),size(rc_return),rc_return))
       ELSEIF (rc_delim_val="^")
        SET rc_return = concat("^",substring(1,(rc_char_pos - 1),rc_return),"^,char(0),^",substring((
          rc_char_pos+ 1),size(rc_return),rc_return))
       ENDIF
      ELSE
       IF (substring((rc_char_pos - 1),1,rc_return)=rc_delim_val)
        IF (rc_delim_val="'")
         SET rc_return = concat(substring(1,(rc_char_pos - 3),rc_return),",char(0),'",substring((
           rc_char_pos+ 1),size(rc_return),rc_return))
        ELSEIF (rc_delim_val='"')
         SET rc_return = concat(substring(1,(rc_char_pos - 3),rc_return),',char(0),"',substring((
           rc_char_pos+ 1),size(rc_return),rc_return))
        ELSEIF (rc_delim_val="^")
         SET rc_return = concat(substring(1,(rc_char_pos - 3),rc_return),",char(0),^",substring((
           rc_char_pos+ 1),size(rc_return),rc_return))
        ENDIF
       ELSE
        IF (rc_delim_val="'")
         SET rc_return = concat(substring(1,(rc_char_pos - 1),rc_return),"',char(0),'",substring((
           rc_char_pos+ 1),size(rc_return),rc_return))
        ELSEIF (rc_delim_val='"')
         SET rc_return = concat(substring(1,(rc_char_pos - 1),rc_return),'",char(0),"',substring((
           rc_char_pos+ 1),size(rc_return),rc_return))
        ELSEIF (rc_delim_val="^")
         SET rc_return = concat(substring(1,(rc_char_pos - 1),rc_return),"^,char(0),^",substring((
           rc_char_pos+ 1),size(rc_return),rc_return))
        ENDIF
       ENDIF
      ENDIF
     ENDIF
     SET rc_char_ind = 1
    ELSE
     SET rc_char_loop = 1
    ENDIF
   ENDWHILE
   IF (rc_last_ind=0)
    SET rc_return = concat(rc_return,rc_delim_val)
   ENDIF
   IF (rc_char_ind=1
    AND rc_only_ind=0)
    SET rc_return = concat("CONCAT(",rc_return,")")
   ENDIF
   RETURN(rc_return)
 END ;Subroutine
 DECLARE drdm_create_pk_where(dcpw_cnt=i4,dcpw_table_cnt=i4,dcpw_type=vc) = vc
 DECLARE drdm_add_pkw_col(dapc_cnt=i4,dapc_table_cnt=i4,dapc_col_cnt=i4,dapc_pk_str=vc,
  dapc_col_null_ind=i2,
  dapc_ts_ind=i2) = vc
 SUBROUTINE drdm_create_pk_where(dcpw_cnt,dcpw_table_cnt,dcpw_type)
   DECLARE dcpw_pkw_col_cnt = i4
   DECLARE dcpw_pk_str = vc
   DECLARE dcpw_suffix = vc
   DECLARE dcpw_tbl_loop = i4
   DECLARE dcpw_col_nullind = i2
   DECLARE dcpw_col_loop = i4
   DECLARE dcpw_error_ind = i2
   DECLARE dcpw_col_str = vc WITH protect, noconstant("")
   DECLARE dcpw_col_str_vc = vc WITH protect, noconstant("")
   DECLARE dcpw_ts_ind = i2 WITH protect, noconstant(0)
   DECLARE dcpw_col_len = i4 WITH protect, noconstant(0)
   DECLARE dcpw_col_diff = i4 WITH protect, noconstant(0)
   SET dcpw_suffix = dm2_rdds_get_tbl_alias(dm2_ref_data_doc->tbl_qual[dcpw_table_cnt].suffix)
   IF ((validate(cust_cs_rows->trailing_space_ind,- (5))=- (5))
    AND (validate(cust_cs_rows->trailing_space_ind,- (6))=- (6)))
    SET dcpw_ts_ind = 0
   ELSE
    SET dcpw_ts_ind = 1
   ENDIF
   SET mdr_pk_cnt = 0
   SET mdr_pk_str = ""
   IF (dcpw_type="MD")
    FOR (dcpw_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[dcpw_table_cnt].col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[dcpw_table_cnt].col_qual[dcpw_col_loop].merge_delete_ind=1))
       CALL parser(concat("set dcpw_col_nullind = cust_cs_rows->qual[dcpw_cnt].",dm2_ref_data_doc->
         tbl_qual[dcpw_table_cnt].col_qual[dcpw_col_loop].column_name,"_NULLIND go"),1)
       SET dcpw_pkw_col_cnt = (dcpw_pkw_col_cnt+ 1)
       IF (dcpw_pkw_col_cnt=1)
        SET dcpw_pk_str = "WHERE "
       ELSE
        SET dcpw_pk_str = concat(dcpw_pk_str," AND ")
       ENDIF
       SET dcpw_pk_str = drdm_add_pkw_col(dcpw_cnt,dcpw_table_cnt,dcpw_col_loop,dcpw_pk_str,
        dcpw_col_nullind,
        dcpw_ts_ind)
      ENDIF
    ENDFOR
   ELSEIF (dcpw_type="UI")
    FOR (dcpw_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[dcpw_table_cnt].col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[dcpw_table_cnt].col_qual[dcpw_col_loop].unique_ident_ind=1))
       CALL parser(concat("set dcpw_col_nullind = cust_cs_rows->qual[dcpw_cnt].",dm2_ref_data_doc->
         tbl_qual[dcpw_table_cnt].col_qual[dcpw_col_loop].column_name,"_NULLIND go"),1)
       SET dcpw_pkw_col_cnt = (dcpw_pkw_col_cnt+ 1)
       IF (dcpw_pkw_col_cnt=1)
        SET dcpw_pk_str = "WHERE "
       ELSE
        SET dcpw_pk_str = concat(dcpw_pk_str," AND ")
       ENDIF
       SET dcpw_pk_str = drdm_add_pkw_col(dcpw_cnt,dcpw_table_cnt,dcpw_col_loop,dcpw_pk_str,
        dcpw_col_nullind,
        dcpw_ts_ind)
      ENDIF
    ENDFOR
   ELSEIF (dcpw_type IN ("ALG5", "ALG7"))
    FOR (dcpw_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[dcpw_table_cnt].col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[dcpw_table_cnt].col_qual[dcpw_col_loop].exception_flg=12))
       CALL parser(concat("set dcpw_col_nullind = cust_cs_rows->qual[dcpw_cnt].",dm2_ref_data_doc->
         tbl_qual[dcpw_table_cnt].col_qual[dcpw_col_loop].column_name,"_NULLIND go"),1)
       SET dcpw_pkw_col_cnt = (dcpw_pkw_col_cnt+ 1)
       IF (dcpw_pkw_col_cnt=1)
        SET dcpw_pk_str = "WHERE "
       ELSE
        SET dcpw_pk_str = concat(dcpw_pk_str," AND ")
       ENDIF
       SET dcpw_pk_str = drdm_add_pkw_col(dcpw_cnt,dcpw_table_cnt,dcpw_col_loop,dcpw_pk_str,
        dcpw_col_nullind,
        dcpw_ts_ind)
      ENDIF
    ENDFOR
    IF (dcpw_type="ALG5")
     SET dcpw_pk_str = concat(dcpw_pk_str," and ",dcpw_suffix,".",dm2_ref_data_doc->tbl_qual[
      dcpw_table_cnt].beg_col_name,
      " <= cnvtdatetime(curdate,curtime3) and ",dm2_ref_data_doc->tbl_qual[dcpw_table_cnt].
      end_col_name," > cnvtdatetime(curdate,curtime3) ")
    ENDIF
   ELSE
    FOR (dcpw_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[dcpw_table_cnt].col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[dcpw_table_cnt].col_qual[dcpw_col_loop].pk_ind=1))
       CALL parser(concat("set dcpw_col_nullind = cust_cs_rows->qual[dcpw_cnt].",dm2_ref_data_doc->
         tbl_qual[dcpw_table_cnt].col_qual[dcpw_col_loop].column_name,"_NULLIND go"),1)
       SET dcpw_pkw_col_cnt = (dcpw_pkw_col_cnt+ 1)
       IF (dcpw_pkw_col_cnt=1)
        SET dcpw_pk_str = "WHERE "
       ELSE
        SET dcpw_pk_str = concat(dcpw_pk_str," AND ")
       ENDIF
       SET dcpw_pk_str = drdm_add_pkw_col(dcpw_cnt,dcpw_table_cnt,dcpw_col_loop,dcpw_pk_str,
        dcpw_col_nullind,
        dcpw_ts_ind)
      ENDIF
    ENDFOR
   ENDIF
   IF (dcpw_error_ind=0)
    RETURN(dcpw_pk_str)
   ELSE
    RETURN("")
   ENDIF
 END ;Subroutine
 SUBROUTINE drdm_add_pkw_col(dapc_cnt,dapc_table_cnt,dapc_col_cnt,dapc_pk_str,dapc_col_nullind,
  dapc_ts_ind)
   DECLARE dapc_suffix = vc
   DECLARE dapc_col_name = vc WITH protect, noconstant(" ")
   DECLARE dapc_float = f8 WITH protect, noconstant(0.0)
   DECLARE dapc_float_str = vc WITH protect, noconstant(" ")
   DECLARE dapc_col_str = vc WITH protect, noconstant(" ")
   DECLARE dapc_col_len = i4 WITH protect, noconstant(0)
   DECLARE dapc_ret = vc WITH protect, noconstant(" ")
   SET dapc_suffix = dm2_rdds_get_tbl_alias(dm2_ref_data_doc->tbl_qual[dapc_table_cnt].suffix)
   SET dapc_col_name = dm2_ref_data_doc->tbl_qual[dapc_table_cnt].col_qual[dapc_col_cnt].column_name
   SET dapc_ret = dapc_pk_str
   IF (dapc_col_nullind=1)
    SET dapc_ret = concat(dapc_ret," ",dapc_suffix,".",dapc_col_name,
     " is NULL ")
   ELSEIF ((dm2_ref_data_doc->tbl_qual[dapc_table_cnt].col_qual[dapc_col_cnt].data_type="F8"))
    CALL parser(concat("set dapc_float = cust_cs_rows->qual[dapc_cnt].",dapc_col_name," go"),1)
    IF (dapc_float=round(dapc_float,0))
     SET dapc_float_str = concat(trim(cnvtstring(dapc_float,20)),".0")
    ELSE
     SET dapc_float_str = build(dapc_float)
    ENDIF
    CALL parser(concat("set dapc_ret = concat(dapc_ret, ' ",dapc_suffix,".",dapc_col_name,
      " =', dapc_float_str) go"),1)
   ELSEIF ((dm2_ref_data_doc->tbl_qual[dapc_table_cnt].col_qual[dapc_col_cnt].data_type IN ("I4",
   "I2")))
    CALL parser(concat("set dapc_ret = concat(dapc_ret, ' ",dapc_suffix,".",dapc_col_name," =',",
      "trim(cnvtstring(cust_cs_rows->qual[dapc_cnt].",dapc_col_name,")),'.0') go"),1)
   ELSEIF ((dm2_ref_data_doc->tbl_qual[dapc_table_cnt].col_qual[dapc_col_cnt].data_type IN ("VC",
   "C*")))
    SET dapc_col_str = ""
    CALL parser(concat("set dapc_col_str = cust_cs_rows->qual[dapc_cnt].",dapc_col_name," go"),1)
    IF (dapc_ts_ind=1)
     IF ((dm2_ref_data_doc->tbl_qual[dapc_table_cnt].col_qual[dapc_col_cnt].data_type="VC"))
      CALL parser(concat("set dapc_col_len = cust_cs_rows->qual[dapc_cnt].",dapc_col_name,"_len go"),
       1)
      SET dapc_col_diff = (dapc_col_len - size(dapc_col_str))
     ELSE
      SET dapc_col_len = 0
      SET dapc_col_diff = 0
     ENDIF
    ELSE
     SET dapc_col_len = 0
     SET dapc_col_diff = 0
    ENDIF
    SET dapc_col_str = replace_char(dapc_col_str)
    IF (findstring("char(0)",dapc_col_str,0,0)=0)
     SET dapc_col_str = concat(replace_delim_vals(dapc_col_str,dapc_col_len))
    ELSE
     IF (dcp_col_diff=0)
      SET dapc_col_str = dapc_col_str
     ELSE
      SET dapc_col_str = concat(substring(1,(size(dapc_col_str) - 1),dapc_col_str),"^",fillstring(
        value(rcs_size_diff)," "),"^)")
     ENDIF
    ENDIF
    IF (((findstring(char(42),dapc_col_str) > 0) OR (((findstring(char(63),dapc_col_str) > 0) OR (
    findstring(char(92),dapc_col_str) > 0)) )) )
     SET dapc_col_str = concat("nopatstring(",dapc_col_str,")")
    ENDIF
    SET dapc_ret = concat(dapc_ret," ",dapc_suffix,".",dapc_col_name,
     "=",dapc_col_str)
   ELSEIF ((dm2_ref_data_doc->tbl_qual[dapc_table_cnt].col_qual[dapc_col_cnt].data_type="DQ8"))
    CALL parser(concat("set dapc_ret = concat(dapc_ret,' ",dapc_suffix,".",dapc_col_name,
      " =  cnvtdatetime('",
      ",trim(build(cust_cs_rows->qual[dapc_cnt].",dapc_col_name,")),","')') go"),1)
   ELSE
    SET dapc_error_ind = 1
    CALL disp_msg(concat("An unknown datatype was found when trying to create pk_where: ",
      dm2_ref_data_doc->tbl_qual[dapc_table_cnt].col_qual[dapc_col_cnt].data_type),dm_err->logfile,1)
   ENDIF
   RETURN(dapc_ret)
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
 DECLARE rdds_init_ora_context(rioc_context_name=vc) = i2
 SUBROUTINE rdds_init_ora_context(rioc_context_name)
   DECLARE sys_context() = c4000
   DECLARE dm2_context_control_wrapper() = i2
   DECLARE rioc_context_value = vc WITH protect, noconstant(" ")
   SELECT INTO "nl:"
    v_str = sys_context("CERNER",rioc_context_name,4000)
    FROM dual
    DETAIL
     rioc_context_value = v_str
    WITH nocounter
   ;end select
   IF (check_error(build2("Retrieve oracle context ",rioc_context_value))=1)
    RETURN(0)
   ENDIF
   IF (daf_is_blank(rioc_context_value))
    SELECT INTO "nl:"
     v_ret = dm2_context_control_wrapper(rioc_context_name,"ABC")
     FROM dual
     DETAIL
      stat = v_ret
     WITH nocounter
    ;end select
    IF (check_error(build2("Initialize oracle context ",rioc_context_name," to non-nullable value"))=
    1)
     RETURN(0)
    ENDIF
    SELECT INTO "nl:"
     v_ret = dm2_context_control_wrapper(rioc_context_name,null)
     FROM dual
     DETAIL
      stat = v_ret
     WITH nocounter
    ;end select
    IF (check_error(build2("Initialize oracle context ",rioc_context_name," to null value"))=1)
     RETURN(0)
    ENDIF
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
 SET dm_err->eproc = "Starting dm2_ref_data_mover_main"
 IF (check_logfile("dm_rmc_mover",".log","DM_RMC_MOVER_MAIN LOG")=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to Create Log File"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_main
 ENDIF
 DECLARE drdm_get_merge_del_rows(sbr_t_name=vc,sbr_pk_where=vc,sbr_tbl_cnt=i4,sbr_sp_val=f8,
  sbr_orig_explode=i4,
  gmdr_ps_data=vc(ref)) = i4
 DECLARE find_next_commit(fnc_log_loop=i4) = i4
 DECLARE drdm_get_child_rows(sbr_t_name=vc,sbr_pk_where=vc,sbr_dv_table_cnt=i4,sbr_next_row=i4) = i4
 DECLARE reprocess_move(spm_log_loop=i4,spm_log_cnt=i4) = i4
 DECLARE add_missing_xlats(amx_log_loop=i4,amx_rs_size=i4) = i4
 DECLARE reinitialize_drdm(rd_log_loop=i4) = null
 DECLARE drdm_dcle_proc(null) = null
 DECLARE reset_holdng_rows(null) = i4
 DECLARE create_ccl_def(null) = i4
 DECLARE check_for_cutover(null) = i2
 DECLARE insert_noxlat(sbr_table_name=vc,sbr_column_name=vc,sbr_value=f8,sbr_orphan_ind=i2) = i2
 DECLARE del_chg_log(sbr_table_name=vc,sbr_log_type=vc,sbr_target_id=f8) = null
 DECLARE drdm_get_versioned_row(sbr_t_name=vc,sbr_pk_where=vc,sbr_tbl_cnt=i4) = i2
 DECLARE drmm_updt_nomv00(sbr_drdm_pos=i4,sbr_context_string=vc) = i2
 DECLARE drmm_cur_state_explode(sbr_log_pos=i4) = vc
 DECLARE drmm_hash_backfill(sbr_log_pos=i4,sbr_tbl_cnt=i4) = vc
 DECLARE drmm_upd_dmt_status_flg(sbr_dead_ind=i2) = i2
 DECLARE drmm_get_context_name(dgcn_src_ctxt=vc) = vc
 DECLARE drmm_check_vers_pk(dcvp_tab_name=vc,dcvp_col_name=vc,dcvp_pk_val=f8,dcvp_data_doc=vc(ref))
  = i2
 DECLARE merge_audit_cnt = i4
 DECLARE drdm_min_batch = f8
 DECLARE drdm_any_translated = i2
 DECLARE simple_loop = i4
 DECLARE drdm_parser_cnt = i4
 DECLARE drd_data_type = vc
 DECLARE drdm_info_name = vc
 DECLARE sel_min = i2
 DECLARE perm_col_cnt = i4
 DECLARE rw_cnt = i4
 DECLARE temp_col_cnt = i4
 DECLARE tbl_loop = i4
 DECLARE has_data = i2
 DECLARE this_log_id = f8
 DECLARE drdm_log_cnt = i4
 DECLARE pk_qual_cnt = i4
 DECLARE drdm_tot_cnt = i4
 DECLARE drdm_last_row = i2
 DECLARE drdm_cur_log = f8
 DECLARE drdm_cur_info = f8
 DECLARE rollbk_error_cnt = i4
 DECLARE drdm_log_loop = i4
 DECLARE main_prsr_cnt = i4
 DECLARE main_go_ind = i2
 DECLARE drdm_max_batch = f8
 DECLARE drdm_error_out_ind = i2
 DECLARE drdm_row_gap_cnt = i4
 DECLARE drdm_info_start = i2
 DECLARE drdm_debug_row_ind = i2
 DECLARE drdm_row_start = f8
 DECLARE drdm_log_level = i2
 DECLARE drdm_tier_mat_ind = i2
 DECLARE drdm_except_tab = vc
 DECLARE dyn_prog_name = vc
 DECLARE drdm_stop_time = f8
 DECLARE drdm_start_time = f8
 DECLARE drdm_active_ind_merge = i2
 DECLARE nvp_commit_ind = i2
 DECLARE long_blob_tab = i2
 DECLARE drdm_mover_ind = i2
 DECLARE drdmm_srch_str = vc
 DECLARE rs_valid_ind = f8
 DECLARE drdm_tgt_tran_num = f8
 DECLARE drdm_src_tran_num = f8
 DECLARE drdm_src_info_tab = vc
 DECLARE drdm_tran_check_flg = i2
 DECLARE nodelete_ind = i2
 DECLARE nodelete_msg = vc
 DECLARE drdm_complete_ind = i2
 DECLARE drdm_max_rs_size = i4
 DECLARE drdm_next_row_pos = i4
 DECLARE drdm_eraseable_ind = i2
 DECLARE drdm_mini_loop_status = vc
 DECLARE drdm_no_trans_ind = i2
 DECLARE current_merges = i4
 DECLARE fail_merges = i4
 DECLARE drdm_batch_size = i4
 DECLARE drdmv_source_tab = vc
 DECLARE drdmv_suffix = vc
 DECLARE drdm_child_cnt = i4
 DECLARE drdm_missing_cnt = i4
 DECLARE drdm_md_loop = i4
 DECLARE drdm_first_md_ndx = i4
 DECLARE seq_call_script = vc
 DECLARE drdm_next_tab = vc
 DECLARE drdm_proc_call_ind = i2
 DECLARE drdm_tpc_tab_name = vc
 DECLARE drdm_tpc_pk_where = vc
 DECLARE drdm_tpc_context = vc
 DECLARE drdm_top_level_ind = i2
 DECLARE drdm_tl_id_col = vc
 DECLARE drdm_tl_tab_name = vc
 DECLARE drdm_tl_name_col = vc
 DECLARE drdm_tl_id_val = f8
 DECLARE drdm_tl_name_val = vc
 DECLARE drdm_tl_pk_where = vc
 DECLARE drdm_tl_col_pos = i4
 DECLARE drdm_no_insert_ind = i2
 DECLARE drdm_tl_col_name = vc
 DECLARE dt_tm_name = vc
 DECLARE drdm_pair_size = i4
 DECLARE drdm_oracle_context = vc
 DECLARE drdm_filter_string = vc
 DECLARE drdm_context_active_ind = i2
 DECLARE drdm_context_string = vc
 DECLARE drdm_num_contexts = i4
 DECLARE drdm_context_null_ind = i2
 DECLARE drdm_where_stmt = vc
 DECLARE drdm_null_found_ind = i2
 DECLARE drdm_additional_context_ind = i2
 DECLARE drdm_timeout_cnt = i2
 DECLARE drdm_exp_idx = i4
 DECLARE drdm_dcl_qual = f8
 DECLARE cutover_flag = i2 WITH noconstant(0)
 DECLARE drcm_src_version = i4 WITH noconstant(0)
 DECLARE drcm_tgt_version = i4 WITH noconstant(0)
 DECLARE drcm_warning_ind = i2 WITH noconstant(0)
 DECLARE num_day_k = i4 WITH noconstant(0)
 DECLARE drcm_src_version = i4 WITH noconstant(0)
 DECLARE drcm_lo_bd = i4 WITH noconstant(0)
 DECLARE drcm_up_bd = i4 WITH noconstant(0)
 DECLARE drcm_src_info = vc
 DECLARE rhr_return_value = i4 WITH noconstant(0)
 DECLARE drdm_valid_rows_cnt = i4
 DECLARE drdm_default_context = vc
 DECLARE drdm_default_context_ind = i2
 DECLARE drdm_use_context_set_ind = i2
 DECLARE drdm_all_found_ind = i2
 DECLARE drmm_ret_val = i2
 DECLARE drdm_mover_string = vc
 DECLARE length() = i4
 DECLARE drdm_where_deletes_stmt = vc
 DECLARE drmm_event_reason = vc
 DECLARE drmm_open_event_reason = vc
 DECLARE drmm_alt_source_event = vc
 DECLARE drmm_alt_source_env_id = f8
 DECLARE gvr_ind = i2
 DECLARE drmm_user_src_tab = vc
 DECLARE drmm_open_event_dt_tm = f8 WITH protect, noconstant(0.0)
 DECLARE drmm_cur_env_name = vc WITH protect, noconstant("")
 DECLARE drmm_src_blocking_id_ind = i2 WITH protect, noconstant(1)
 DECLARE drmm_utc_src = vc
 DECLARE ptam_ind = i2 WITH protect, noconstant(0)
 DECLARE drdm_filter_ret = i4 WITH protect, noconstant(0)
 DECLARE evaluate_pe_name() = c255
 SET seq_call_script = "MOVER"
 DECLARE avr_detail_size = i4
 DECLARE drmm_ddl_rollback_ind = i2
 DECLARE drmm_cur_process = vc WITH protect, noconstant("")
 DECLARE drmm_rows_processed_ind = i2 WITH protect, noconstant(0)
 DECLARE dm_auto_cut_ind = i2 WITH noconstant(0)
 DECLARE drmm_sc_cnt = i4 WITH protect, noconstant(0)
 DECLARE drmm_sc_pos = i4 WITH protect, noconstant(0)
 DECLARE drmm_sc_explode_ind = i2 WITH protect, noconstant(1)
 DECLARE drmm_tier_rdbhandle = f8 WITH protect, noconstant(0.0)
 DECLARE drmm_tier_done = i2 WITH protect, noconstant(0)
 DECLARE drmm_tier_setup_flag = i2 WITH protect, noconstant(0)
 DECLARE drst_event_reason = vc WITH noconstant("")
 DECLARE drmm_max_tier = i4 WITH protect, noconstant(0)
 DECLARE drmm_cur_tier = i4 WITH protect, noconstant(0)
 DECLARE drmm_batch_qual = i4 WITH protect, noconstant(0)
 DECLARE drmm_tier_stmt = vc WITH protect, noconstant("")
 DECLARE drmm_next_row = i4 WITH protect, noconstant(0)
 DECLARE drmm_nomv00_ind = i2 WITH protect, noconstant(0)
 DECLARE drmm_excep_flag = i2 WITH noconstant(1)
 DECLARE drmm_reason_flag = i2 WITH noconstant(1)
 DECLARE drdm_utc_src = vc
 DECLARE drmm_cs_xpld_type = vc WITH protect, noconstant("")
 DECLARE drmm_backfill_type = vc WITH protect, noconstant("")
 DECLARE drdm_proc_dcl_id = f8 WITH protect, noconstant(0.0)
 DECLARE drmm_del_ctx_stmt = vc WITH protect, noconstant("")
 DECLARE drmm_log_loop = i4 WITH protect, noconstant(0)
 DECLARE drmm_log_type_stmt = vc WITH protect, noconstant("")
 DECLARE drmm_client_ident = vc WITH protect, noconstant("")
 DECLARE drmm_udb_cnt = i4 WITH protect, noconstant(0)
 DECLARE drmm_brkup_cnt = i4 WITH protect, noconstant(0)
 DECLARE drmm_breakup_str_ret = vc WITH protect, noconstant("")
 DECLARE drcm_avr_size = i4 WITH protect, noconstant(0)
 DECLARE drcm_rdbh_vcnt = i4 WITH noconstant(0)
 DECLARE drcm_table_list = vc WITH noconstant("")
 DECLARE drcm_log_file = vc WITH noconstant("")
 DECLARE drcm_process = vc WITH noconstant("")
 DECLARE drcm_find_rdb = i4 WITH noconstant(0)
 DECLARE rlp = i4 WITH noconstant(0)
 DECLARE lpc = i4 WITH noconstant(0)
 DECLARE drmm_prescan_idx = i4 WITH protect, noconstant(0)
 DECLARE drmm_auto_cut_flag = i4 WITH protect, noconstant(0)
 DECLARE drmm_start_ind = i2 WITH protect, noconstant(0)
 DECLARE drmm_ctxt_stmt = vc WITH protect, noconstant("")
 FREE RECORD drcm_rdbh_val
 RECORD drcm_rdbh_val(
   1 list[*]
     2 value = f8
     2 table_str = vc
     2 log_file = vc
     2 process = vc
     2 qual_ind = i2
 )
 IF (validate(dm_mover_run,"X")="X")
  DECLARE dm_mover_run = vc
  SET dm_mover_run = "Interactive mover"
 ENDIF
 IF (validate(dm_get_seq_val,"X")="X")
  DECLARE dm_get_seq_val = vc
  SET dm_get_seq_val = "Automatic match via mover"
 ENDIF
 IF (validate(drdm_proc_tab,"VALID")="VALID")
  DECLARE drdm_proc_tab = vc
  SET drdm_proc_tab = ""
 ENDIF
 DECLARE drdm_ref_type = c15 WITH constant("REFERENCE MERGE")
 DECLARE drdm_log_type = c6 WITH constant("REFCHG")
 DECLARE drdm_nordds = c6 WITH constant("NORDDS")
 SET dm_err->eproc = "Validating Input"
 IF (((reflect(parameter(1,0)) != "I*"
  AND reflect(parameter(1,0)) != "F*") OR (((reflect(parameter(2,0)) != "I*"
  AND reflect(parameter(2,0)) != "F*") OR (reflect(parameter(3,0)) != "I*"
  AND reflect(parameter(3,0)) != "F*")) )) )
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat("Expected syntax:  dm2_ref_data_mover_main <Source Environment_ID>",
   ", <Batch Start value>, <Start Log_ID>")
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_main
 ENDIF
 IF (( $1 < 1))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "The Source Environment ID specified must be positive."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_main
 ENDIF
 SET dm2_ref_data_doc->env_source_id = cnvtreal( $1)
 IF (( $2 > 0)
  AND ( $3 > 0))
  SET dm_err->err_ind = 1
  SET dm_err->emsg =
  "Expected syntax: You must specify either a Start Batch ID or a Start Log ID. Not both."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_main
 ENDIF
 IF (dm2_rdds_get_tgt_id(dm2_ref_data_doc)=0)
  GO TO exit_main
 ENDIF
 IF (drrm_check_mig(1,"") > 0)
  SET dm_err->eproc = "Checking for migration status."
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat("It has been detected that a database migration is in progress.  ",
   "There is an RDDS project strategy that allows for movers to run during a migration, but it requires an acknowledgement ",
   "of the strategy through DM_MERGE_DOMAIN_ADM.  Please use that to start movers.")
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_main
 ENDIF
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_main
 ENDIF
 IF (drrm_check_freeze(dm2_ref_data_doc->env_target_id)=1)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat(
   "There is currently a migration schema freeze in place.  Movers will not be ",
   "allowed to start.  Please work with the integration architect to know when schema freeze will be over."
   )
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_main
 ENDIF
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_main
 ENDIF
 IF (dm2_get_rdbms_version(null)=0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_main
 ENDIF
 IF ((dm2_rdbms_version->level1 >= 12))
  CALL parser("rdb alter session set temp_undo_enabled = false go",1)
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   GO TO exit_main
  ENDIF
 ENDIF
 IF (check_xlat_backfill(dm2_ref_data_doc->env_source_id,dm2_ref_data_doc->env_target_id,
  dm2_ref_data_doc->mock_target_id)=0)
  SET dm_err->eproc = "Checking for translation backfill rows."
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat(
   "It has been detected that all sequence match rows have not had their translations backfilled. ",
   "We require that the translation backfill process be performed prior to data mover execution. ",
   'This process is run from the "Manage RDDS Post Domain Copy" sub-menu found on the main menu of the ',
   "DM_MERGE_DOMAIN_ADM tool.")
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_main
 ENDIF
 CALL drcr_check_cbc_setup(dm2_ref_data_doc->env_source_id,dm2_ref_data_doc->env_target_id,
  drcr_ccs_info)
 IF ((drcr_ccs_info->return_ind=1))
  SET dm_err->eproc = "Checking cutover by context setup requirements."
  SET dm_err->err_ind = 1
  SET dm_err->emsg = drcr_ccs_info->return_msg
  CALL disp_msg(dm_err->eproc,dm_err->logfile,1)
  GO TO exit_main
 ENDIF
 SET global_mover_rec->cbc_ind = drcr_ccs_info->cbc_ind
 SET dm_err->eproc = "Defining Record Structures"
 FREE RECORD child_merge_audit
 RECORD child_merge_audit(
   1 num[5000]
     2 action = vc
     2 text = vc
 )
 FREE RECORD fail_merge_audit
 RECORD fail_merge_audit(
   1 num[100]
     2 action = vc
     2 text = vc
 )
 FREE RECORD dm2_ref_data_reply
 RECORD dm2_ref_data_reply(
   1 error_ind = i2
   1 error_msg = vc
   1 qual[*]
     2 table_name = vc
     2 from_value = f8
     2 to_value = f8
 )
 FREE RECORD drdm_parser
 RECORD drdm_parser(
   1 statement[1100]
     2 frag = vc
 )
 FREE RECORD drdm_log_types
 RECORD drdm_log_types(
   1 cnt = i4
   1 qual[5]
     2 type = vc
 )
 SET drdm_log_types->cnt = 5
 SET drdm_log_types->qual[1].type = "OLDVER*"
 SET drdm_log_types->qual[2].type = "ORPHAN*"
 SET drdm_log_types->qual[3].type = "BADLOG*"
 SET drdm_log_types->qual[4].type = "NOMV*"
 SET drdm_log_types->qual[5].type = "CHLD*"
 FREE RECORD drdm_chg
 IF (( $3 > 0))
  SET trace = recpersist
 ENDIF
 RECORD drdm_chg(
   1 log[*]
     2 log_id = f8
     2 table_name = vc
     2 pk_where = vc
     2 delete_ind = i2
     2 updt_cnt = i4
     2 pk_where_value = f8
     2 next_to_process = i4
     2 commit_ind = i2
     2 md_delete_ind = i2
     2 validate_ind = i2
     2 par_location = i4
     2 status_flg = i4
     2 reprocess_ind = i2
     2 context_name = vc
     2 md_context_name = vc
     2 updt_dt_tm = f8
     2 process_flg = i4
     2 src_cntxt_name = vc
     2 exploded_ind = i2
     2 blocking_log_id = f8
     2 dm_chg_log_exception_id = f8
     2 chg_log_reason_txt = vc
     2 single_pass_log_id = f8
     2 single_pass_value = f8
     2 pkw_vers_id = f8
     2 updt_applctx = f8
     2 pk_where_hash = f8
     2 ptam_match_hash = f8
     2 ptam_match_result = f8
     2 ptam_match_result_str = vc
     2 ptam_str_tspace_cnt = i4
 )
 IF (( $3 > 0))
  SET trace = norecpersist
 ENDIF
 IF (( $3 > 0))
  SET drdm_debug_row_ind = 1
  SET drdm_row_start =  $3
  SET trace = rdbbind
  SET trace = rdbdebug
  SET trace = echoinput
  SET trace = echoinput2
  SET message = information
  SET trace = callecho
 ENDIF
 FREE RECORD drdm_contexts
 RECORD drdm_contexts(
   1 qual[*]
     2 values = vc
 )
 FREE RECORD rudc_request
 RECORD rudc_request(
   1 source_env_id = f8
 )
 FREE RECORD drc_request
 RECORD drc_request(
   1 num_cutover_processes = i4
   1 source_env_id = f8
 )
 FREE RECORD drc_reply
 RECORD drc_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD drmm_reply
 RECORD drmm_reply(
   1 status = c1
   1 status_msg = vc
 )
 FREE RECORD drmm_dmt_reply
 RECORD drmm_dmt_reply(
   1 status = c1
   1 status_msg = vc
 )
 FREE RECORD drmm_sc_parents
 RECORD drmm_sc_parents(
   1 sc_parent_cnt = i4
   1 parent[*]
     2 table_name = vc
 )
 FREE RECORD drmm_sc_xpld_request
 RECORD drmm_sc_xpld_request(
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
 RECORD drmm_sc_xpld_reply(
   1 status = vc
   1 message = vc
 )
 FREE RECORD drvc_request
 RECORD drvc_request(
   1 current_env_id = f8
   1 paired_env_id = f8
 )
 FREE RECORD drvc_reply
 RECORD drvc_reply(
   1 target_version_nbr = i4
   1 source_version_nbr = i4
   1 valid_status_ind = i2
   1 message = vc
 )
 FREE RECORD drmm_logtypes
 RECORD drmm_logtypes(
   1 qual[*]
     2 types = vc
 )
 FREE RECORD drmm_prescan_data
 RECORD drmm_prescan_data(
   1 cnt = i4
   1 qual[*]
     2 log_id = f8
 )
 IF (curgroup != 0)
  CALL disp_msg("User Group 0 required to run the RDDS mover.",dm_err->logfile,1)
  SET dm_err->err_ind = 1
  GO TO exit_main
 ENDIF
 SET drmm_client_ident = dci_get_rdds_identifier(null)
 CALL dci_set_rdds_identifier("RDDS MOVER")
 SET stat = alterlist(drmm_logtypes->qual,2)
 SET drmm_logtypes->qual[1].types = drdm_nordds
 SET drmm_logtypes->qual[2].types = drdm_log_type
 SET drvc_request->current_env_id = dm2_ref_data_doc->env_target_id
 SET drvc_request->paired_env_id = dm2_ref_data_doc->env_source_id
 EXECUTE dm_rdds_version_check  WITH replace("REQUEST","DRVC_REQUEST"), replace("REPLY","DRVC_REPLY")
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_main
 ENDIF
 IF ((drvc_reply->valid_status_ind=0))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat("The program will exit because ",drvc_reply->message)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_main
 ENDIF
 SET cutover_flag = 1
 IF (create_ccl_def(null) != 0)
  SET dm_err->eproc = "ORAGEN3 failed on $R table"
  CALL disp_msg("",dm_err->logfile,0)
  SET dm_err->err_ind = 1
  GO TO exit_main
 ENDIF
 SET dm_err->eproc = "Checking configuration statuses"
 SET drcr_config_info->source_env_id = dm2_ref_data_doc->env_source_id
 SET drcr_config_info->target_env_id = dm2_ref_data_doc->env_target_id
 CALL drcr_check_all_config(drcr_config_info)
 IF ((((drcr_config_info->error_ind=1)) OR ((drcr_config_info->config_complete_ind=0))) )
  CALL disp_msg(drcr_config_info->error_msg,dm_err->logfile,1)
  SET dm_err->err_ind = 1
  GO TO exit_main
 ENDIF
 SELECT INTO "NL:"
  FROM dm_info di
  WHERE di.info_domain="RDDS CONFIGURATION:CIRCULAR NOMV EXCLUSION"
  DETAIL
   global_mover_rec->circ_nomv_excl_cnt = (global_mover_rec->circ_nomv_excl_cnt+ 1), stat = alterlist
   (global_mover_rec->circ_nomv_qual,global_mover_rec->circ_nomv_excl_cnt), global_mover_rec->
   circ_nomv_qual[global_mover_rec->circ_nomv_excl_cnt].log_type = di.info_name
  WITH nocounter
 ;end select
 IF (check_error("Gather Circular Exclusion LOG_TYPEs") != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO done
 ENDIF
 SET global_mover_rec->auto_cutover_ind = 0
 SELECT INTO "NL:"
  FROM dm_env_reltn der
  WHERE (der.child_env_id=dm2_ref_data_doc->env_target_id)
   AND (der.parent_env_id=dm2_ref_data_doc->env_source_id)
   AND der.relationship_type IN ("AUTO CUTOVER", "PLANNED CUTOVER")
  DETAIL
   IF (der.relationship_type="AUTO CUTOVER")
    global_mover_rec->auto_cutover_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (check_error("Check AUTO CUTOVER") != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO done
 ENDIF
 SET dm_err->eproc = "Determining open events for alternate source environments."
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "NL:"
  FROM dm_rdds_event_log drel
  WHERE drel.rdds_event="Begin Reference Data Sync"
   AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
   AND (drel.cur_environment_id=dm2_ref_data_doc->env_target_id)
   AND (drel.paired_environment_id != dm2_ref_data_doc->env_source_id)
   AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
  (SELECT
   cur_environment_id, paired_environment_id, event_reason
   FROM dm_rdds_event_log
   WHERE (cur_environment_id=dm2_ref_data_doc->env_target_id)
    AND (paired_environment_id != dm2_ref_data_doc->env_source_id)
    AND rdds_event="End Reference Data Sync"
    AND rdds_event_key="ENDREFERENCEDATASYNC")))
  DETAIL
   drmm_alt_source_event = drel.event_reason, drmm_alt_source_env_id = drel.paired_environment_id
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_main
 ENDIF
 IF (curqual > 0)
  SET dm_err->emsg = concat("Event ",drmm_alt_source_event," is currently open for source ",trim(
    cnvtstring(drmm_alt_source_env_id,20,1)),". You cannot start a mover while this event is open.")
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET dm_err->err_ind = 1
  GO TO exit_main
 ENDIF
 SET drmm_auto_cut_flag = drtq_check_task_process("SCHEDULED AUTO-CUTOVER")
 IF (drmm_auto_cut_flag=4)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "There is currently a scheduled auto cutover that has not finished."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET dm_err->err_ind = 0
  GO TO exit_main
 ELSEIF (drmm_auto_cut_flag=3)
  SELECT INTO "NL:"
   FROM dm_refchg_task_queue r
   WHERE r.process_name="SCHEDULED AUTO-CUTOVER"
    AND  NOT (r.task_status IN ("FINISHED", "QUEUED"))
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_main
  ENDIF
  IF (curqual > 0)
   SET dm_err->err_ind = 1
   SET dm_err->emsg = "There is currently a scheduled auto cutover that has not finished."
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   SET dm_err->err_ind = 0
   GO TO exit_main
  ENDIF
 ENDIF
 SET dm_err->eproc = "Determining open events for current source environment."
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "NL:"
  FROM dm_rdds_event_log drel
  WHERE drel.rdds_event="Begin Reference Data Sync"
   AND drel.rdds_event_key="BEGINREFERENCEDATASYNC"
   AND (drel.cur_environment_id=dm2_ref_data_doc->env_target_id)
   AND (drel.paired_environment_id=dm2_ref_data_doc->env_source_id)
   AND  NOT (list(drel.cur_environment_id,drel.paired_environment_id,drel.event_reason) IN (
  (SELECT
   cur_environment_id, paired_environment_id, event_reason
   FROM dm_rdds_event_log
   WHERE (cur_environment_id=dm2_ref_data_doc->env_target_id)
    AND (paired_environment_id=dm2_ref_data_doc->env_source_id)
    AND rdds_event="End Reference Data Sync"
    AND rdds_event_key="ENDREFERENCEDATASYNC")))
  DETAIL
   drmm_open_event_dt_tm = drel.event_dt_tm
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_main
 ENDIF
 IF (curqual=0)
  IF ((global_mover_rec->auto_cutover_ind=1))
   SET dm_err->err_ind = 1
   SET dm_err->emsg = "There must be an open RDDS event to run movers."
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_main
  ELSE
   SET dm_err->err_ind = 1
   SET dm_err->emsg = "There must be an open RDDS event to run movers in PLANNED mode."
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_main
  ENDIF
 ENDIF
 SET dm_err->eproc = "Determining XLAT_* functions"
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="RDDS ENV PAIR"
   AND d.info_name=concat(cnvtstring(dm2_ref_data_doc->env_source_id,20,0),"::",cnvtstring(
    dm2_ref_data_doc->env_target_id,20,0))
  DETAIL
   global_mover_rec->xlat_from_function = concat("XLAT_FROM_",cnvtstring(d.info_number,20,0)),
   global_mover_rec->xlat_to_function = concat("XLAT_TO_",cnvtstring(d.info_number,20,0)),
   global_mover_rec->xlat_funct_nbr = d.info_number
  WITH nocounter
 ;end select
 IF (check_error("Get xlat functions") != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO done
 ENDIF
 IF (curqual != 1)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Error finding XLAT_* functions, no dm_info row exists"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO done
 ELSE
  CALL parser(concat("declare ",global_mover_rec->xlat_from_function,"()=f8 go"),1)
  CALL parser(concat("declare ",global_mover_rec->xlat_to_function,"()=f8 go"),1)
 ENDIF
 SET dm_err->eproc =
 "Determining if we are running in a PTAM environment and verifying pre-reqs have been met"
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM dm_env_reltn der
  WHERE (der.parent_env_id=dm2_ref_data_doc->env_source_id)
   AND (der.child_env_id=dm2_ref_data_doc->env_target_id)
   AND der.relationship_type="PENDING TARGET AS MASTER"
  DETAIL
   global_mover_rec->ptam_ind = 1
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_main
 ENDIF
 IF ((global_mover_rec->ptam_ind=1))
  SELECT INTO "NL:"
   FROM dm_rdds_event_log drel
   WHERE drel.rdds_event_key="ENDPTAMMATCHHASHBACKFILL"
    AND (drel.cur_environment_id=dm2_ref_data_doc->env_target_id)
    AND (drel.paired_environment_id=dm2_ref_data_doc->env_source_id)
    AND drel.event_dt_tm > cnvtdatetime(drmm_open_event_dt_tm)
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_main
  ENDIF
  IF (curqual=0)
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DATA MANAGEMENT"
     AND d.info_name="DM_ENV_NAME"
    DETAIL
     drmm_cur_env_name = d.info_char
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_main
   ENDIF
   SET dm_err->emsg = concat(
    "Before the movers can be started, the DM_CHG_LOG in target needs to be ",
    "checked to ensure its rows are in ",
    " the correct form for the Pending Target as Master environment ",drmm_cur_env_name)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   CALL merge_audit("FAILREASON",dm_err->emsg,3)
   SET dm_err->err_ind = 1
   GO TO exit_main
  ENDIF
 ENDIF
 IF (get_multi_col_pk(null)=0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET dm_err->err_ind = 1
  GO TO exit_main
 ENDIF
 SET dm_err->eproc = "Checking if exceptions should be reset."
 SET global_mover_rec->reset_xcptn_ind = 1
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="RDDS CONFIGURATION"
   AND di.info_name=concat("CHILDEXCPTN",trim(cnvtstring(dm2_ref_data_doc->env_source_id,20,0)),trim(
    cnvtstring(dm2_ref_data_doc->env_target_id,20,0)))
  DETAIL
   global_mover_rec->reset_xcptn_ind = di.info_number
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_main
 ENDIF
 SET drmm_tier_done = 0
 WHILE (drmm_tier_done=0)
   SET dm_err->eproc = "Checking dm_info for tiering information."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="RDDS TIER LIST"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_main
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = "Checking if another mover is creating tiers."
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="RDDS TIERING SETUP"
      AND d.info_name="MASTER LOCK"
     DETAIL
      drmm_tier_rdbhandle = d.info_number
     WITH nocounter, forupdate(d)
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
    ENDIF
    IF (curqual=1)
     SET dm_err->eproc = "Querying gv$session for tiering rdbhandle."
     SELECT INTO "nl:"
      FROM gv$session gv
      WHERE gv.audsid=drmm_tier_rdbhandle
       AND gv.audsid != cnvtreal(currdbhandle)
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_main
     ENDIF
     IF (curqual=1)
      ROLLBACK
      SET dm_err->eproc = "Pause 60 seconds before checking the tier setup again."
      CALL disp_msg("",dm_err->logfile,0)
      CALL pause(60)
     ELSE
      SET dm_err->eproc = "Updating Tier Locking row"
      UPDATE  FROM dm_info di
       SET di.info_number = cnvtreal(currdbhandle)
       WHERE di.info_domain="RDDS TIERING SETUP"
        AND di.info_name="MASTER LOCK"
       WITH nocounter
      ;end update
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_main
      ENDIF
      COMMIT
      SET drmm_tier_setup_flag = 1
     ENDIF
    ELSE
     SET dm_err->eproc = "Inserting Tier Locking row into dm_info."
     INSERT  FROM dm_info di
      SET di.info_domain = "RDDS TIERING SETUP", di.info_name = "MASTER LOCK", di.info_number =
       cnvtreal(currdbhandle)
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      SET dm_err->err_ind = 0
      SET dm_err->eproc = "Pause 60 seconds before checking the tier setup again."
      CALL disp_msg("",dm_err->logfile,0)
      CALL pause(60)
     ELSE
      COMMIT
      SET drmm_tier_setup_flag = 1
     ENDIF
    ENDIF
    IF (drmm_tier_setup_flag=1)
     SET drst_event_reason = "Mover Run"
     SET dm_err->eproc = "Executing dm_rmc_setup_tier."
     EXECUTE dm_rmc_setup_tier
     SET dm_err->eproc = "Deleting Tier Locking row from dm_info."
     DELETE  FROM dm_info di
      WHERE di.info_domain="RDDS TIERING SETUP"
       AND di.info_name="MASTER LOCK"
      WITH nocounter
     ;end delete
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ENDIF
     COMMIT
     SET drmm_tier_done = 1
    ENDIF
   ELSE
    SET drmm_tier_done = 1
   ENDIF
 ENDWHILE
 SET dm_err->eproc = "Gathering tiering information from dm_info."
 SELECT INTO "NL:"
  FROM dm_info d
  WHERE d.info_domain="RDDS TIER LIST"
  DETAIL
   global_mover_rec->tier_cnt = (global_mover_rec->tier_cnt+ 1)
   IF (mod(global_mover_rec->tier_cnt,10)=1)
    stat = alterlist(global_mover_rec->tier_qual,(global_mover_rec->tier_cnt+ 9))
   ENDIF
   global_mover_rec->tier_qual[global_mover_rec->tier_cnt].table_name = d.info_name, global_mover_rec
   ->tier_qual[global_mover_rec->tier_cnt].tier_value = d.info_number
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_main
 ENDIF
 SET stat = alterlist(auto_ver_request->qual,1)
 SET auto_ver_request->qual[1].rdds_event = "Starting RDDS Mover"
 SET auto_ver_request->qual[1].cur_environment_id = dm2_ref_data_doc->env_target_id
 SET auto_ver_request->qual[1].paired_environment_id = dm2_ref_data_doc->env_source_id
 SET auto_ver_request->qual[1].event_reason = dm_mover_run
 SET avr_detail_size = size(auto_ver_request->qual[1].detail_qual,5)
 SELECT INTO "nl:"
  FROM gv$session g
  WHERE g.audsid=cnvtreal(currdbhandle)
  DETAIL
   drmm_cur_process = g.process
  WITH nocounter
 ;end select
 SET stat = alterlist(auto_ver_request->qual[1].detail_qual,(avr_detail_size+ 1))
 SET avr_detail_size = (avr_detail_size+ 1)
 SET auto_ver_request->qual[1].detail_qual[avr_detail_size].event_detail1_txt = "PROCESS"
 SET auto_ver_request->qual[1].detail_qual[avr_detail_size].event_detail2_txt = drmm_cur_process
 IF (drdm_proc_tab != "")
  SET stat = alterlist(auto_ver_request->qual[1].detail_qual,(avr_detail_size+ 1))
  SET avr_detail_size = (avr_detail_size+ 1)
  SET auto_ver_request->qual[1].detail_qual[avr_detail_size].event_detail1_txt = "TABLE MOVER"
  SET auto_ver_request->qual[1].detail_qual[avr_detail_size].event_detail2_txt = drdm_proc_tab
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="RDDS DCL PROCESSING"
   AND d.info_name="REFCHG ROW BUFFER"
  DETAIL
   global_mover_rec->refchg_buffer = d.info_number
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_main
 ENDIF
 IF (curqual=0)
  SET global_mover_rec->refchg_buffer = 5
  INSERT  FROM dm_info d
   SET d.info_number = global_mover_rec->refchg_buffer, d.info_domain = "RDDS DCL PROCESSING", d
    .info_name = "REFCHG ROW BUFFER"
  ;end insert
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_main
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET dm_err->eproc = "Getting Context Info"
 SET drdm_active_ind_merge = 0
 SET drdm_mover_ind = 1
 SELECT INTO "NL:"
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="RDDS ACTIVE_IND MERGE"
  DETAIL
   drdm_active_ind_merge = d.info_number
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_main
 ENDIF
 IF (curqual=0)
  SET drdm_active_ind_merge = 1
  INSERT  FROM dm_info d
   SET d.info_domain = "DATA MANAGEMENT", d.info_name = "RDDS ACTIVE_IND MERGE", d.info_number = 1
   WITH nocounter
  ;end insert
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_main
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET drdm_all_found_ind = 0
 SET drdm_context_active_ind = 1
 IF (drdm_context_active_ind != 1)
  SET drdm_filter_string = " AND 1 = 1"
  SET stat = alterlist(drdm_contexts->qual,1)
  SET drdm_contexts->qual[1].values = "ALL"
 ELSE
  SET drdm_context_string = ""
  SELECT INTO "NL:"
   FROM dm_info d
   WHERE d.info_domain="RDDS CONTEXT"
    AND d.info_name="CONTEXTS TO PULL"
   DETAIL
    drdm_context_string = d.info_char, global_mover_rec->ctxts_to_pull = d.info_char
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_main
  ENDIF
  IF (drdm_context_string="")
   SET dm_err->err_ind = 1
   SET dm_err->emsg = "No context to pull set.  Please use DM_MERGE_DOMAIN_ADM to setup contexts."
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_main
  ELSEIF (drdm_context_string="ALL")
   SET drdm_filter_string = " AND 1 = 1"
   SET stat = alterlist(drdm_contexts->qual,1)
   SET drdm_contexts->qual[1].values = "ALL"
  ELSE
   SET drdm_num_contexts = parse_contexts(drdm_context_string,"::",drdm_contexts)
   IF (drdm_num_contexts=1
    AND (drdm_contexts->qual[1].values="NULL"))
    SET drdm_filter_string = " AND d.context_name is NULL"
    SET stat = alterlist(drdm_contexts->qual,1)
    SET drdm_contexts->qual[1].values = "NULL"
   ELSE
    SET drdm_filter_string = " AND (d.context_name in ("
    SET drdm_null_found_ind = 0
    SET drdm_additional_context_ind = 0
    FOR (simple_loop = 1 TO drdm_num_contexts)
      IF ((drdm_contexts->qual[simple_loop].values="NULL"))
       SET drdm_null_found_ind = 1
      ELSEIF ((drdm_contexts->qual[simple_loop].values="ALL"))
       SET drdm_all_found_ind = 1
      ELSE
       IF (drdm_additional_context_ind=0)
        SET drdm_filter_string = concat(drdm_filter_string,"'",drdm_contexts->qual[simple_loop].
         values,"'")
        SET drdm_additional_context_ind = 1
       ELSE
        SET drdm_filter_string = concat(drdm_filter_string,",'",drdm_contexts->qual[simple_loop].
         values,"'")
       ENDIF
      ENDIF
    ENDFOR
    SET drdm_filter_string = concat(drdm_filter_string,")")
    IF (drdm_null_found_ind=1)
     SET drdm_filter_string = concat(drdm_filter_string," OR d.context_name is NULL")
    ENDIF
    SET drdm_filter_string = concat(drdm_filter_string,")")
   ENDIF
  ENDIF
  SET stat = initrec(dmda_breakup_str)
  SET dmda_breakup_str->str_text = drdm_context_string
  SET dmda_breakup_str->str_delim = "::"
  SET dmda_breakup_str->str_delim_ind = 2
  SET dmda_breakup_str->str_limit = 250
  SET drmm_breakup_str_ret = drmm_breakup_string(dmda_breakup_str)
  SET drmm_brkup_cnt = 0
  IF (drmm_breakup_str_ret="S")
   FOR (drmm_brkup_cnt = 1 TO size(dmda_breakup_str->substr,5))
     SET stat = alterlist(auto_ver_request->qual[1].detail_qual,(avr_detail_size+ 1))
     SET avr_detail_size = (avr_detail_size+ 1)
     SET auto_ver_request->qual[1].detail_qual[avr_detail_size].event_detail1_txt =
     "CONTEXTS TO PULL"
     SET auto_ver_request->qual[1].detail_qual[avr_detail_size].event_detail2_txt = dmda_breakup_str
     ->substr[drmm_brkup_cnt].str
   ENDFOR
  ELSE
   SET dm_err->err_ind = 1
   SET dm_err->err_msg = "Unable to break up CONTEXTS TO PULL into smaller strings"
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_main
  ENDIF
 ENDIF
 IF (drdm_all_found_ind=1)
  SET drdm_filter_string = " AND 1 = 1"
  SET stat = alterlist(drdm_contexts->qual,1)
  SET drdm_contexts->qual[1].values = "ALL"
 ENDIF
 SET global_mover_rec->context_ind = 0
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="RDDS CONTEXT"
   AND d.info_name="CONTEXT GROUP_IND"
  DETAIL
   global_mover_rec->context_ind = d.info_number
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_main
 ENDIF
 SET stat = alterlist(auto_ver_request->qual[1].detail_qual,(avr_detail_size+ 1))
 SET avr_detail_size = (avr_detail_size+ 1)
 SET auto_ver_request->qual[1].detail_qual[avr_detail_size].event_detail1_txt = "CONTEXT GROUP_IND"
 SET auto_ver_request->qual[1].detail_qual[avr_detail_size].event_value = global_mover_rec->
 context_ind
 IF ((global_mover_rec->context_ind=1))
  SELECT INTO "nl:"
   FROM dm_info d
   WHERE d.info_domain="RDDS CONTEXT"
    AND d.info_name="CONTEXT TO SET"
   DETAIL
    drdm_oracle_context = d.info_char, global_mover_rec->ctxt_to_set = d.info_char
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_main
  ENDIF
  IF ((global_mover_rec->ctxt_to_set="ALL")
   AND drdm_context_active_ind=1)
   SET dm_err->err_ind = 1
   SET dm_err->emsg =
   "Illegal Context Setup. 'ALL' is not a valid CONTEXT TO SET.  Please use DM_MERGE_DOMAIN_ADM to setup contexts."
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_main
  ELSEIF (locateval(simple_loop,1,drdm_num_contexts,global_mover_rec->ctxt_to_set,drdm_contexts->
   qual[simple_loop].values) > 0
   AND size(drdm_contexts->qual,5) > 1)
   SET dm_err->err_ind = 1
   SET dm_err->emsg = concat("Illegal Context Setup. When pulling multiple contexts, CONTEXT TO SET",
    " cannot be identical to a pulled context .  Please use DM_MERGE_DOMAIN_ADM to setup contexts.")
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_main
  ELSE
   IF (trim(global_mover_rec->ctxt_to_set) > " ")
    CALL parser(concat("RDB ASIS(^ BEGIN DM2_CONTEXT_CONTROL('RDDS_CONTEXT','",global_mover_rec->
      ctxt_to_set,"'); END; ^) GO"),1)
   ELSE
    CALL parser(concat("RDB ASIS(^ BEGIN DM2_CONTEXT_CONTROL('RDDS_CONTEXT',''); END; ^) GO"),1)
   ENDIF
   SET stat = initrec(dmda_breakup_str)
   SET dmda_breakup_str->str_text = global_mover_rec->ctxt_to_set
   SET dmda_breakup_str->str_delim = "::"
   SET dmda_breakup_str->str_delim_ind = 2
   SET dmda_breakup_str->str_limit = 250
   SET drmm_breakup_str_ret = drmm_breakup_string(dmda_breakup_str)
   SET drmm_brkup_cnt = 0
   IF (drmm_breakup_str_ret="S")
    FOR (drmm_brkup_cnt = 1 TO size(dmda_breakup_str->substr,5))
      SET stat = alterlist(auto_ver_request->qual[1].detail_qual,(avr_detail_size+ 1))
      SET avr_detail_size = (avr_detail_size+ 1)
      SET auto_ver_request->qual[1].detail_qual[avr_detail_size].event_detail1_txt = "CONTEXT TO SET"
      SET auto_ver_request->qual[1].detail_qual[avr_detail_size].event_detail2_txt = dmda_breakup_str
      ->substr[drmm_brkup_cnt].str
    ENDFOR
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->err_msg = "Unable to break up CONTEXT TO SET into smaller strings"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_main
   ENDIF
  ENDIF
 ENDIF
 SET drdm_default_context_ind = 0
 IF (drdm_context_active_ind=1)
  SET drdm_use_context_set_ind = 0
  IF ((global_mover_rec->context_ind=0))
   IF (((drdm_all_found_ind=1) OR (((drdm_null_found_ind=1) OR (((drdm_context_string="ALL") OR (
   drdm_context_string="NULL")) )) )) )
    SET drdm_default_context_ind = 1
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="RDDS CONTEXT"
      AND di.info_name="DEFAULT CONTEXT"
     DETAIL
      drdm_default_context = di.info_char, global_mover_rec->default_ctxt = di.info_char
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_main
    ENDIF
    SET avr_detail_size = (avr_detail_size+ 1)
    SET stat = alterlist(auto_ver_request->qual[1].detail_qual,avr_detail_size)
    SET auto_ver_request->qual[1].detail_qual[avr_detail_size].event_detail1_txt = "DEFAULT CONTEXT"
    SET auto_ver_request->qual[1].detail_qual[avr_detail_size].event_detail2_txt = global_mover_rec->
    default_ctxt
   ENDIF
  ELSE
   SET drdm_use_context_set_ind = 1
  ENDIF
 ELSE
  SET global_mover_rec->default_ctxt = "NULL"
 ENDIF
 SELECT INTO "NL:"
  FROM dm_info d
  WHERE d.info_domain="RDDS VERSION REQ OVERRIDE"
   AND d.info_name="MANUAL OVERRIDE"
  DETAIL
   ioverrideind = 1
   IF (ioverrideind=1)
    avr_detail_size = (avr_detail_size+ 1), stat = alterlist(auto_ver_request->qual[1].detail_qual,
     avr_detail_size), auto_ver_request->qual[1].detail_qual[avr_detail_size].event_detail1_txt =
    "RDDS VERSION REQ OVERRIDE",
    auto_ver_request->qual[1].detail_qual[avr_detail_size].event_detail2_txt =
    "MANUAL OVERRIDE CREATED BY", auto_ver_request->qual[1].detail_qual[avr_detail_size].event_value
     = d.updt_id
   ENDIF
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_main
 ENDIF
 EXECUTE dm_rmc_auto_verify_setup
 IF ((auto_ver_reply->status="F"))
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET stat = initrec(auto_ver_request)
  SET stat = initrec(auto_ver_reply)
  SET dm_err->err_ind = 1
  GO TO exit_main
 ELSE
  COMMIT
  SET drmm_start_ind = 1
  SET stat = initrec(auto_ver_request)
  SET stat = initrec(auto_ver_reply)
 ENDIF
 IF (((drdm_context_string="") OR (drdm_num_contexts=1))
  AND drdm_context_active_ind=1)
  SET drdm_use_context_set_ind = 1
 ENDIF
 SELECT INTO "NL:"
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="RDDS BATCH SIZE"
  DETAIL
   drdm_batch_size = d.info_number
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_main
 ENDIF
 IF (curqual=0)
  SET drdm_batch_size = 200
  INSERT  FROM dm_info d
   SET d.info_domain = "DATA MANAGEMENT", d.info_name = "RDDS BATCH SIZE", d.info_number =
    drdm_batch_size
   WITH nocounter
  ;end insert
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_main
  ELSE
   COMMIT
  ENDIF
 ELSEIF (((drdm_batch_size < 1) OR (drdm_batch_size > 4000)) )
  SET drdm_batch_size = 200
  UPDATE  FROM dm_info d
   SET d.info_number = drdm_batch_size
   WHERE d.info_domain="DATA MANAGEMENT"
    AND d.info_name="RDDS BATCH SIZE"
   WITH nocounter
  ;end update
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_main
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET dm_err->eproc = "Gathering MD row limit value"
 SELECT INTO "NL:"
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="MD ROW LIMIT"
  DETAIL
   global_mover_rec->md_row_limit = di.info_number
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_main
 ENDIF
 IF ((global_mover_rec->md_row_limit=0))
  SET global_mover_rec->md_row_limit = 5000
 ENDIF
 SET global_mover_rec->one_pass_ind = 0
 SELECT INTO "NL:"
  FROM dm_info d
  WHERE d.info_domain="RDDS CONFIGURATION"
   AND d.info_name="MOVER MODE"
   AND d.info_char="SINGLE PASS"
  DETAIL
   global_mover_rec->one_pass_ind = 1
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_main
 ENDIF
 SET drdm_error_out_ind = 0
 SET dm_err->eproc = "Starting dm2_ref_data_mover_main"
 CALL disp_msg(" ",dm_err->logfile,0)
 CALL echo(build("START = ",curmem))
 SET rollbk_error_cnt = 0
 SET sel_min = 0
 SET rw_cnt = 0
 SET drdm_any_translated = 1
 SET dm_err->eproc = "Selecting target domain and filling RS"
 CALL disp_msg(" ",dm_err->logfile,0)
 SET drdm_chg_log = 0
 SELECT INTO "NL:"
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="RDDS LOG LEVEL"
  DETAIL
   drdm_log_level = d.info_number
  WITH nocounter
 ;end select
 IF (curqual=0)
  INSERT  FROM dm_info d
   SET d.info_domain = "DATA MANAGEMENT", d.info_name = "RDDS LOG LEVEL", d.info_number = 1
  ;end insert
  COMMIT
  SET drdm_log_level = 0
 ENDIF
 SELECT INTO "NL:"
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="CKI PATTERN MATCH*"
  DETAIL
   simple_loop = (simple_loop+ 1), stat = alterlist(global_mover_rec->qual,simple_loop),
   global_mover_rec->qual[simple_loop].pattern_cki = d.info_char
  WITH nocounter
 ;end select
 SET simple_loop = 0
 IF ((dm2_rdds_rec->main_process=""))
  SET dm2_rdds_rec->main_process = "MOVER"
 ENDIF
 SET dm2_rdds_rec->mode = "DATABASE"
 SELECT INTO "NL:"
  FROM dm_env_reltn der
  WHERE (der.child_env_id=dm2_ref_data_doc->env_target_id)
   AND der.relationship_type=drdm_ref_type
   AND (der.parent_env_id=dm2_ref_data_doc->env_source_id)
  DETAIL
   dm2_ref_data_doc->pre_link_name = der.pre_link_name, dm2_ref_data_doc->post_link_name = der
   .post_link_name
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM dm_env_reltn der
  WHERE (der.child_env_id=dm2_ref_data_doc->mock_target_id)
   AND der.relationship_type="RDDS MOVER CHANGES NOT LOGGED"
   AND (der.parent_env_id=dm2_ref_data_doc->env_source_id)
  DETAIL
   global_mover_rec->loop_back_ind = 1
  WITH nocounter
 ;end select
 IF ((dm2_ref_data_doc->pre_link_name="")
  AND (dm2_ref_data_doc->post_link_name="")
  AND currdb="ORACLE")
  SET dm2_ref_data_doc->post_link_name = concat("@MERGE",trim(cnvtstring( $1,20,0)),trim(cnvtstring(
     dm2_ref_data_doc->env_target_id,20,0)))
 ENDIF
 IF (dm2_rdds_chk_rel_val_rows(dm2_ref_data_doc->env_source_id,dm2_ref_data_doc->env_target_id,
  dm2_ref_data_doc->post_link_name) != "BOTH_FOUND")
  SET dm_err->emsg = concat("Source/target relationship not validated.  Please start movers via",
   " dm_merge_domain_adm so relationship validation will occur.")
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET dm_err->err_ind = 1
  GO TO exit_main
 ENDIF
 SET global_mover_rec->invalid_xlat_ind = 1
 SELECT INTO "nl:"
  seq(rdds_source_clinical_seq,nextval)
  FROM dual
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_main
 ENDIF
 SET dguc_request->local_tables_ind = 1
 SET dguc_request->what_tables = "*"
 SET dguc_request->is_ref_ind = 1
 SET dguc_request->is_mrg_ind = 0
 SET dguc_request->only_special_ind = 0
 SET dguc_request->current_remote_db = 1
 SET dguc_request->db_link = dm2_ref_data_doc->post_link_name
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
 EXECUTE dm_get_unique_columns
 IF (check_for_cutover(null)=1)
  GO TO done
 ENDIF
 SET dm_err->eproc =
 "Determining if Single Commit Explode has occured or if event opened on earlier code version."
 CALL disp_msg(" ",dm_err->logfile,0)
 CALL add_tracking_row(dm2_ref_data_doc->env_source_id,"MOVER PROCESS","MOVER RUNNING")
 IF ((dm2_rdds_rec->mode="DATABASE")
  AND (global_mover_rec->loop_back_ind=1))
  EXECUTE dm2_set_context "FIRE_REFCHG_TRG_MVR", trim(cnvtstring(dm2_ref_data_doc->env_source_id,30))
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_main
  ENDIF
 ENDIF
 SET drdmm_srch_str = dm2_get_rdds_tname("DM_CHG_LOG")
 SET dm_err->eproc = "Getting max tier value from dm_info."
 SELECT INTO "nl:"
  y = max(di.info_number)
  FROM dm_info di
  WHERE di.info_domain="RDDS TIER LIST"
  DETAIL
   drmm_max_tier = y
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_main
 ENDIF
 SET drdm_start_time = cnvtdatetime(curdate,curtime3)
 SET drdm_tot_cnt = 0
 SET dm_err->eproc = "Gathering PrefDir information from dm_info."
 SELECT INTO "NL:"
  FROM dm_info d
  WHERE d.info_domain="RDDS PREFDIR LIST"
  DETAIL
   global_mover_rec->prefdir_cnt = (global_mover_rec->prefdir_cnt+ 1)
   IF (mod(global_mover_rec->prefdir_cnt,10)=1)
    stat = alterlist(global_mover_rec->prefdir_qual,(global_mover_rec->prefdir_cnt+ 9))
   ENDIF
   global_mover_rec->prefdir_qual[global_mover_rec->prefdir_cnt].preference = d.info_name
  FOOT REPORT
   stat = alterlist(global_mover_rec->prefdir_qual,global_mover_rec->prefdir_cnt)
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_main
 ENDIF
 SELECT INTO "NL:"
  FROM dm_info d
  WHERE d.info_domain="RDDS PREFDIR EXACT MATCH LIST"
  DETAIL
   global_mover_rec->exact_prefdir_cnt = (global_mover_rec->exact_prefdir_cnt+ 1), stat = alterlist(
    global_mover_rec->exact_prefdir_qual,global_mover_rec->exact_prefdir_cnt), global_mover_rec->
   exact_prefdir_qual[global_mover_rec->exact_prefdir_cnt].preference = d.info_name
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_main
 ENDIF
 CALL echo(build("PK = ",curmem))
 SET drdmm_srch_str = dm2_get_rdds_tname("DM_CHG_LOG")
 SET drdm_info_name = concat("MERGE",trim(cnvtstring(dm2_ref_data_doc->env_source_id,20,0)),trim(
   cnvtstring(dm2_ref_data_doc->env_target_id,20,0)))
 IF (drdm_proc_tab != "")
  SET drdm_info_name = concat("TAB",drdm_info_name)
 ENDIF
 SET drdm_dcl_qual = 1
 UPDATE  FROM (parser(drdmm_srch_str) dcl)
  SET dcl.log_type = "REFCHG"
  WHERE dcl.log_type IN ("PROCES", "REPORT")
   AND dcl.rdbhandle=currdbhandle
   AND (dcl.target_env_id=dm2_ref_data_doc->env_target_id)
  WITH nocounter
 ;end update
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_main
 ENDIF
 COMMIT
 IF (drmm_upd_dmt_status_flg(1) != 1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET dm_err->err_ind = 1
  GO TO exit_main
 ENDIF
 SET dm_err->eproc = "Reset dm_chg_log rows from orphaned mover processs"
 CALL disp_msg("",dm_err->logfile,0)
 SELECT DISTINCT INTO "nl:"
  d.rdbhandle, d.table_name
  FROM (parser(drdmm_srch_str) d)
  WHERE d.log_type IN ("PROCES", "REPORT")
   AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
   AND  NOT (d.rdbhandle IN (
  (SELECT
   audsid
   FROM v$session)))
  ORDER BY d.rdbhandle, d.table_name
  HEAD d.rdbhandle
   drcm_rdbh_vcnt = (drcm_rdbh_vcnt+ 1)
   IF (mod(drcm_rdbh_vcnt,25)=1)
    stat = alterlist(drcm_rdbh_val->list,(drcm_rdbh_vcnt+ 24))
   ENDIF
   drcm_rdbh_val->list[drcm_rdbh_vcnt].value = cnvtreal(d.rdbhandle), drcm_rdbh_val->list[
   drcm_rdbh_vcnt].log_file = "Log file not found", drcm_rdbh_val->list[drcm_rdbh_vcnt].process =
   "PID not found",
   drcm_rdbh_val->list[drcm_rdbh_vcnt].qual_ind = 0
  HEAD d.table_name
   drcm_rdbh_val->list[drcm_rdbh_vcnt].table_str = build(drcm_rdbh_val->list[drcm_rdbh_vcnt].
    table_str,d.table_name,", ")
  FOOT REPORT
   stat = alterlist(drcm_rdbh_val->list,drcm_rdbh_vcnt)
  WITH nocounter
 ;end select
 IF (check_error("Check if any dm_chg_log rows are in process")=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_main
 ENDIF
 SELECT INTO "nl:"
  FROM (parser(drdmm_srch_str) d)
  WHERE d.log_type IN ("REPORT", "PROCES")
   AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
   AND expand(rlp,1,drcm_rdbh_vcnt,cnvtreal(d.rdbhandle),drcm_rdbh_val->list[rlp].value)
  DETAIL
   drcm_find_rdb = 0, drcm_find_rdb = locateval(rlp,1,drcm_rdbh_vcnt,cnvtreal(d.rdbhandle),
    drcm_rdbh_val->list[rlp].value)
   IF (drcm_find_rdb > 0)
    drcm_rdbh_val->list[drcm_find_rdb].qual_ind = 1
   ENDIF
  WITH nocounter, forupdatewait(d)
 ;end select
 IF (check_error("Check if any dm_chg_log rows are in process")=1)
  SET dm_err->eproc = "Lock DCL rows that are in REPORT and PROCES to be updated"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_main
 ENDIF
 IF (curqual > 0)
  UPDATE  FROM (parser(drdmm_srch_str) d)
   SET d.log_type = "REFCHG", d.rdbhandle = null, d.updt_dt_tm = sysdate
   WHERE expand(rlp,1,drcm_rdbh_vcnt,cnvtreal(d.rdbhandle),drcm_rdbh_val->list[rlp].value)
    AND d.log_type IN ("REPORT", "PROCES")
    AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
   WITH nocounter
  ;end update
  IF (check_error("Check if any dm_chg_log rows are in process")=1)
   ROLLBACK
   SET dm_err->eproc = "Update DCL rows to REFCHG from REPORT and PROCES"
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_main
  ENDIF
  COMMIT
 ELSEIF (curqual=0)
  SET stat = alterlist(drcm_rdbh_val->list,0)
  SET drcm_rdbh_vcnt = 0
 ENDIF
 SELECT INTO "nl:"
  FROM dm_refchg_process drp
  WHERE  NOT (drp.rdbhandle_value IN (
  (SELECT
   g.audsid
   FROM gv$session g)))
   AND drp.refchg_status="MOVER RUNNING"
   AND (drp.env_source_id=dm2_ref_data_doc->env_source_id)
  DETAIL
   drcm_find_rdb = 0
   IF (drcm_rdbh_vcnt > 0)
    drcm_find_rdb = locateval(rlp,1,drcm_rdbh_vcnt,drp.rdbhandle_value,drcm_rdbh_val->list[rlp].value
     )
   ENDIF
   IF (drcm_find_rdb=0)
    drcm_rdbh_vcnt = (drcm_rdbh_vcnt+ 1), stat = alterlist(drcm_rdbh_val->list,drcm_rdbh_vcnt),
    drcm_find_rdb = drcm_rdbh_vcnt
   ENDIF
   drcm_rdbh_val->list[drcm_find_rdb].value = drp.rdbhandle_value, drcm_rdbh_val->list[drcm_find_rdb]
   .log_file = drp.log_file, drcm_rdbh_val->list[drcm_find_rdb].process = drp.process_name,
   drcm_rdbh_val->list[drcm_find_rdb].qual_ind = 1
  FOOT REPORT
   stat = alterlist(drcm_rdbh_val->list,drcm_rdbh_vcnt)
  WITH nocounter, forupdatewait(drp)
 ;end select
 IF (check_error(dm_err->eproc)=1)
  ROLLBACK
  SET dm_err->eproc = "Lock orphaned dm_rechg_process rows"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO done
 ENDIF
 DELETE  FROM dm_refchg_process drp
  WHERE drp.refchg_status="MOVER RUNNING"
   AND (drp.env_source_id=dm2_ref_data_doc->env_source_id)
   AND expand(rlp,1,drcm_rdbh_vcnt,drp.rdbhandle_value,drcm_rdbh_val->list[rlp].value)
  WITH nocounter
 ;end delete
 IF (check_error(dm_err->eproc)=1)
  ROLLBACK
  SET dm_err->eproc = "Delete orphaned dm_rechg_process rows"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO done
 ENDIF
 COMMIT
 SET drcm_avr_size = size(auto_ver_request->qual,5)
 FOR (lpc = 1 TO drcm_rdbh_vcnt)
   IF ((drcm_rdbh_val->list[lpc].qual_ind=1))
    SET drcm_avr_size = (drcm_avr_size+ 1)
    SET stat = alterlist(auto_ver_request->qual,drcm_avr_size)
    SET auto_ver_request->qual[drcm_avr_size].rdds_event = "Orphaned Mover"
    SET auto_ver_request->qual[drcm_avr_size].cur_environment_id = dm2_ref_data_doc->env_target_id
    SET auto_ver_request->qual[drcm_avr_size].paired_environment_id = dm2_ref_data_doc->env_source_id
    SET stat = alterlist(auto_ver_request->qual[drcm_avr_size].detail_qual,1)
    SET auto_ver_request->qual[drcm_avr_size].detail_qual[1].event_detail1_txt = drcm_rdbh_val->list[
    lpc].log_file
    SET auto_ver_request->qual[drcm_avr_size].detail_qual[1].event_detail2_txt = drcm_rdbh_val->list[
    lpc].process
    SET auto_ver_request->qual[drcm_avr_size].detail_qual[1].event_detail3_txt = substring(1,512,
     drcm_rdbh_val->list[lpc].table_str)
   ENDIF
 ENDFOR
 IF (drcm_avr_size > 0)
  EXECUTE dm_rmc_auto_verify_setup
  IF ((auto_ver_reply->status != "S"))
   ROLLBACK
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO done
  ENDIF
 ENDIF
 COMMIT
 SET stat = initrec(auto_ver_request)
 SET stat = initrec(auto_ver_reply)
 SET drdm_max_batch = 0
 IF ( NOT (rdds_init_ora_context("CCL STMT")
  AND rdds_init_ora_context("CUSTOM_PL_SQL")
  AND rdds_init_ora_context("RDDS_COL_STRING")
  AND rdds_init_ora_context("RDDS_CUST_COL_STRING")
  AND rdds_init_ora_context("RDDS_PTAM_MATCH_QUERY")
  AND rdds_init_ora_context("RDDS_PTAM_MATCH_RESULT_STR")))
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO done
 ENDIF
#rerun
 SET drdm_log_loop = 0
 SET main_prsr_cnt = 0
 SET main_go_ind = 0
 SET drdm_stop_time = cnvtdatetime("01-JAN-1800 00:00:00")
 SELECT INTO "NL:"
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="RDDS STOP TIME"
  DETAIL
   drdm_stop_time = cnvtdatetime(d.info_date)
  WITH nocounter
 ;end select
 CALL echo(build("drdm_start_time = ",format(drdm_start_time,";;q")))
 CALL echo(build("drdm_stop_time = ",format(drdm_stop_time,";;q")))
 IF (drdm_stop_time >= drdm_start_time)
  SET dm_err->eproc = concat("Mover stopped by user request at: ",format(drdm_stop_time,";;q"))
  CALL disp_msg(" ",dm_err->logfile,0)
  GO TO exit_main
 ENDIF
 IF (drdm_debug_row_ind=0)
  CALL reset_holdng_rows(null)
 ENDIF
 SET rw_cnt = 0
#try_again
 IF (drdm_debug_row_ind=1)
  IF ((dm2_rdds_rec->mode="OS"))
   SET drdm_where_stmt = " log_id=drdm_row_start and log_type not in ('MERGED') "
   SET drdm_where_stmt = concat(drdm_where_stmt,drdm_filter_string)
  ELSE
   SET drdm_where_stmt = " log_id=drdm_row_start and log_type not in ('MERGED') "
   SET drdm_where_stmt = concat(drdm_where_stmt,
    " and target_env_id + 0 = value(dm2_ref_data_doc->env_target_id)",drdm_filter_string)
  ENDIF
  SELECT INTO "nl:"
   null_check = nullind(d.context_name), l1 = length(d.ptam_match_result_str)
   FROM (parser(drdmm_srch_str) d)
   WHERE parser(drdm_where_stmt)
   HEAD REPORT
    drdm_log_cnt = 0, stat = alterlist(drdm_chg->log,1)
   DETAIL
    drdm_log_cnt = (drdm_log_cnt+ 1), drdm_chg->log[drdm_log_cnt].pk_where_value = d.pk_where_value,
    drdm_chg->log[drdm_log_cnt].log_id = d.log_id,
    drdm_chg->log[drdm_log_cnt].pk_where = replace(d.pk_where,"<MERGE_LINK>",dm2_ref_data_doc->
     post_link_name,0), drdm_chg->log[drdm_log_cnt].table_name = d.table_name, drdm_chg->log[
    drdm_log_cnt].delete_ind = d.delete_ind,
    drdm_chg->log[drdm_log_cnt].updt_cnt = d.updt_cnt, drdm_chg->log[drdm_log_cnt].next_to_process =
    (drdm_log_cnt+ 1), drdm_chg->log[drdm_log_cnt].commit_ind = 1,
    drdm_chg->log[drdm_log_cnt].md_delete_ind = 0, drdm_chg->log[drdm_log_cnt].process_flg = 1,
    drdm_chg->log[drdm_log_cnt].status_flg = 0,
    drdm_chg->log[drdm_log_cnt].src_cntxt_name = d.context_name, drdm_chg->log[drdm_log_cnt].
    exploded_ind = 0, drdm_chg->log[drdm_log_cnt].pkw_vers_id = d.dm_refchg_pkw_vers_id,
    drdm_chg->log[drdm_log_cnt].updt_applctx = d.updt_applctx, drdm_chg->log[drdm_log_cnt].
    pk_where_hash = d.pk_where_hash, drdm_chg->log[drdm_log_cnt].ptam_match_hash = d.ptam_match_hash,
    drdm_chg->log[drdm_log_cnt].ptam_match_result = d.ptam_match_result, drdm_chg->log[drdm_log_cnt].
    ptam_match_result_str = d.ptam_match_result_str, drdm_chg->log[drdm_log_cnt].ptam_str_tspace_cnt
     = (l1 - size(drdm_chg->log[drdm_log_cnt].ptam_match_result_str)),
    drdm_chg->log[drdm_log_cnt].single_pass_log_id = 0, drdm_chg->log[drdm_log_cnt].single_pass_value
     = 0, drdm_chg->log[drdm_log_cnt].md_context_name = "",
    drdm_chg->log[drdm_log_cnt].context_name = drmm_get_context_name(drdm_chg->log[drdm_log_cnt].
     src_cntxt_name)
    IF (d.delete_ind=0)
     drdm_chg->log[drdm_log_cnt].validate_ind = 1
    ENDIF
   FOOT REPORT
    stat = alterlist(drdm_chg->log,drdm_log_cnt)
   WITH nocounter
  ;end select
  IF (drdm_log_cnt > 0)
   SET drdm_chg->log[drdm_log_cnt].next_to_process = 0
   SET drdm_max_rs_size = drdm_log_cnt
   SET drdm_eraseable_ind = 0
   SET drdm_next_row_pos = (drdm_log_cnt+ 1)
  ENDIF
  IF (check_error(dm_err->eproc)=1)
   IF (findstring("ORA-01555",dm_err->emsg,1,0) > 0)
    IF (rollbk_error_cnt=3)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_main
    ELSE
     SET rollbk_error_cnt = (rollbk_error_cnt+ 1)
     GO TO rerun
    ENDIF
   ELSE
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_main
   ENDIF
  ELSE
   SET rollbk_error_cnt = 0
  ENDIF
  IF (curqual=0)
   CALL disp_msg("The debug row entered is not a valid row.",dm_err->logfile,1)
   GO TO exit_main
  ELSE
   CALL merge_audit("BATCH START","A new batch of dm_chg_log rows was gathered for processing",3)
   SET dm_err->eproc = "Updating debug row to PROCES."
   UPDATE  FROM (parser(drdmm_srch_str) d)
    SET d.log_type = "PROCES"
    WHERE (d.log_id=drdm_chg->log[drdm_log_cnt].log_id)
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc)=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    GO TO exit_main
   ELSE
    COMMIT
   ENDIF
  ENDIF
 ELSE
  SET dm_err->eproc = "Getting dm_chg_log info"
  SET drdm_log_cnt = 0
  FOR (b_cnt = 1 TO size(drdm_chg->log,5))
    CALL reinitialize_drdm(b_cnt)
  ENDFOR
  SET drdm_timeout_cnt = 0
  WHILE (drdm_timeout_cnt < 5)
    SET drdm_where_stmt = "d.target_env_id  = dm2_ref_data_doc->env_target_id"
    IF (drdm_proc_tab > "")
     SET drdm_where_stmt = concat(drdm_where_stmt," and d.table_name = drdm_proc_tab ")
    ENDIF
    SET drdm_dcl_qual = 0
    SET drdm_where_deletes_stmt = concat(drdm_where_stmt," and d.delete_ind = 1 ")
    SET drdm_where_stmt = concat(drdm_where_stmt," and d.delete_ind = 0 ")
    FOR (drmm_ctx_loop = 1 TO size(drdm_contexts->qual,5))
      SET drmm_del_ctx_stmt = drdm_where_deletes_stmt
      IF ((drdm_contexts->qual[drmm_ctx_loop].values="NULL"))
       SET drmm_del_ctx_stmt = concat(drmm_del_ctx_stmt," and d.context_name IS NULL ")
      ELSEIF ((drdm_contexts->qual[drmm_ctx_loop].values="ALL"))
       SET drmm_del_ctx_stmt = concat(drmm_del_ctx_stmt," and 1 = 1 ")
      ELSE
       SET drmm_del_ctx_stmt = concat(drmm_del_ctx_stmt,
        " and d.context_name = drdm_contexts->qual[drmm_ctx_loop].values ")
      ENDIF
      FOR (drmm_log_loop = 1 TO size(drmm_logtypes->qual,5))
        SET drmm_log_type_stmt = drmm_del_ctx_stmt
        SET drmm_log_type_stmt = concat(drmm_log_type_stmt,
         " and d.log_type = drmm_logtypes->qual[drmm_log_loop].types ")
        SELECT INTO "nl:"
         null_check = nullind(d.context_name), l1 = length(d.ptam_match_result_str)
         FROM (parser(drdmm_srch_str) d)
         WHERE parser(drmm_log_type_stmt)
         HEAD REPORT
          drdm_log_cnt = 0, stat = alterlist(drdm_chg->log,drdm_batch_size)
         DETAIL
          drdm_log_cnt = (drdm_log_cnt+ 1), drdm_chg->log[drdm_log_cnt].pk_where_value = d
          .pk_where_value, drdm_chg->log[drdm_log_cnt].log_id = d.log_id,
          drdm_chg->log[drdm_log_cnt].pk_where = replace(d.pk_where,"<MERGE_LINK>",dm2_ref_data_doc->
           post_link_name,0), drdm_chg->log[drdm_log_cnt].table_name = d.table_name, drdm_chg->log[
          drdm_log_cnt].delete_ind = d.delete_ind,
          drdm_chg->log[drdm_log_cnt].updt_cnt = d.updt_cnt, drdm_chg->log[drdm_log_cnt].
          next_to_process = (drdm_log_cnt+ 1), drdm_chg->log[drdm_log_cnt].commit_ind = 1,
          drdm_chg->log[drdm_log_cnt].md_delete_ind = 0, drdm_chg->log[drdm_log_cnt].process_flg = 1,
          drdm_chg->log[drdm_log_cnt].status_flg = 0,
          drdm_chg->log[drdm_log_cnt].src_cntxt_name = d.context_name, drdm_chg->log[drdm_log_cnt].
          exploded_ind = 0, drdm_chg->log[drdm_log_cnt].md_context_name = "",
          drdm_chg->log[drdm_log_cnt].pkw_vers_id = d.dm_refchg_pkw_vers_id, drdm_chg->log[
          drdm_log_cnt].updt_applctx = d.updt_applctx, drdm_chg->log[drdm_log_cnt].pk_where_hash = d
          .pk_where_hash,
          drdm_chg->log[drdm_log_cnt].ptam_match_hash = d.ptam_match_hash, drdm_chg->log[drdm_log_cnt
          ].ptam_match_result = d.ptam_match_result, drdm_chg->log[drdm_log_cnt].
          ptam_match_result_str = d.ptam_match_result_str,
          drdm_chg->log[drdm_log_cnt].ptam_str_tspace_cnt = (l1 - size(drdm_chg->log[drdm_log_cnt].
           ptam_match_result_str)), drdm_chg->log[drdm_log_cnt].single_pass_log_id = 0, drdm_chg->
          log[drdm_log_cnt].single_pass_value = 0,
          drdm_chg->log[drdm_log_cnt].context_name = drmm_get_context_name(drdm_chg->log[drdm_log_cnt
           ].src_cntxt_name), drdm_chg->log[drdm_log_cnt].validate_ind = 0
         FOOT REPORT
          stat = alterlist(drdm_chg->log,drdm_log_cnt)
         WITH nocounter, maxqual(d,value(drdm_batch_size)), forupdatewait(d)
        ;end select
        SET drdm_dcl_qual = curqual
        IF (check_error("Obtaining delete DCL rows to process")=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
         ROLLBACK
        ENDIF
        IF (drdm_dcl_qual > 0)
         SET drmm_ctx_loop = size(drdm_contexts->qual,5)
         SET drmm_log_loop = size(drmm_logtypes->qual,5)
        ENDIF
      ENDFOR
    ENDFOR
    IF (drdm_dcl_qual=0
     AND (dm_err->err_ind=0))
     SET drmm_batch_qual = 0
     SET drmm_cur_tier = 1
     SET drmm_tier_done = 0
     WHILE (drmm_tier_done=0)
       IF (drmm_cur_tier <= drmm_max_tier
        AND drdm_proc_tab="")
        SET drmm_tier_stmt = concat(drdm_where_stmt,
         " and d.table_name IN( select di.info_name from dm_info di where ",
         " di.info_domain = 'RDDS TIER LIST' and info_number = drmm_cur_tier ) ")
        FOR (drmm_ctx_loop = 1 TO size(drdm_contexts->qual,5))
          SET drmm_ctxt_stmt = drmm_tier_stmt
          IF ((drdm_contexts->qual[drmm_ctx_loop].values="NULL"))
           SET drmm_ctxt_stmt = concat(drmm_ctxt_stmt," and d.context_name IS NULL ")
          ELSEIF ((drdm_contexts->qual[drmm_ctx_loop].values="ALL"))
           SET drmm_ctxt_stmt = concat(drmm_ctxt_stmt," and 1 = 1 ")
          ELSE
           SET drmm_ctxt_stmt = concat(drmm_ctxt_stmt,
            " and d.context_name = drdm_contexts->qual[drmm_ctx_loop].values ")
          ENDIF
          FOR (drmm_log_loop = 1 TO size(drmm_logtypes->qual,5))
            SET drmm_log_type_stmt = drmm_ctxt_stmt
            SET drmm_log_type_stmt = concat(drmm_log_type_stmt,
             " and d.log_type = drmm_logtypes->qual[drmm_log_loop].types ")
            SELECT INTO "nl:"
             null_check = nullind(d.context_name), l1 = length(d.ptam_match_result_str)
             FROM (parser(drdmm_srch_str) d)
             WHERE parser(drmm_log_type_stmt)
             HEAD REPORT
              drdm_log_cnt = 0, stat = alterlist(drdm_chg->log,drdm_batch_size)
             DETAIL
              drdm_log_cnt = (drdm_log_cnt+ 1), drdm_chg->log[drdm_log_cnt].pk_where_value = d
              .pk_where_value, drdm_chg->log[drdm_log_cnt].log_id = d.log_id,
              drdm_chg->log[drdm_log_cnt].pk_where = replace(d.pk_where,"<MERGE_LINK>",
               dm2_ref_data_doc->post_link_name,0), drdm_chg->log[drdm_log_cnt].table_name = d
              .table_name, drdm_chg->log[drdm_log_cnt].delete_ind = d.delete_ind,
              drdm_chg->log[drdm_log_cnt].updt_cnt = d.updt_cnt, drdm_chg->log[drdm_log_cnt].
              next_to_process = (drdm_log_cnt+ 1), drdm_chg->log[drdm_log_cnt].commit_ind = 1,
              drdm_chg->log[drdm_log_cnt].md_delete_ind = 0, drdm_chg->log[drdm_log_cnt].process_flg
               = 1, drdm_chg->log[drdm_log_cnt].status_flg = 0,
              drdm_chg->log[drdm_log_cnt].src_cntxt_name = d.context_name, drdm_chg->log[drdm_log_cnt
              ].exploded_ind = 0, drdm_chg->log[drdm_log_cnt].md_context_name = "",
              drdm_chg->log[drdm_log_cnt].pkw_vers_id = d.dm_refchg_pkw_vers_id, drdm_chg->log[
              drdm_log_cnt].updt_applctx = d.updt_applctx, drdm_chg->log[drdm_log_cnt].pk_where_hash
               = d.pk_where_hash,
              drdm_chg->log[drdm_log_cnt].ptam_match_hash = d.ptam_match_hash, drdm_chg->log[
              drdm_log_cnt].ptam_match_result = d.ptam_match_result, drdm_chg->log[drdm_log_cnt].
              ptam_match_result_str = d.ptam_match_result_str,
              drdm_chg->log[drdm_log_cnt].ptam_str_tspace_cnt = (l1 - size(drdm_chg->log[drdm_log_cnt
               ].ptam_match_result_str)), drdm_chg->log[drdm_log_cnt].single_pass_log_id = 0,
              drdm_chg->log[drdm_log_cnt].single_pass_value = 0,
              drdm_chg->log[drdm_log_cnt].context_name = drmm_get_context_name(drdm_chg->log[
               drdm_log_cnt].src_cntxt_name)
              IF (d.delete_ind=0)
               drdm_chg->log[drdm_log_cnt].validate_ind = 1
              ELSE
               drdm_chg->log[drdm_log_cnt].validate_ind = 0
              ENDIF
             FOOT REPORT
              stat = alterlist(drdm_chg->log,drdm_log_cnt), drmm_batch_qual = drdm_log_cnt
             WITH nocounter, maxqual(d,value(drdm_batch_size)), forupdatewait(d)
            ;end select
            IF (check_error("Obtaining DCL rows to process")=1)
             CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
             ROLLBACK
             SET drmm_tier_done = 1
            ELSE
             IF (drmm_batch_qual > 0)
              SET drmm_tier_done = 1
              SET drmm_log_loop = size(drmm_logtypes->qual,5)
              SET drmm_ctx_loop = size(drdm_contexts->qual,5)
             ENDIF
            ENDIF
          ENDFOR
        ENDFOR
        SET drmm_cur_tier = (drmm_cur_tier+ 1)
       ELSE
        FOR (drmm_ctx_loop = 1 TO size(drdm_contexts->qual,5))
          SET drmm_tier_stmt = drdm_where_stmt
          IF ((drdm_contexts->qual[drmm_ctx_loop].values="NULL"))
           SET drmm_tier_stmt = concat(drmm_tier_stmt," and d.context_name IS NULL ")
          ELSEIF ((drdm_contexts->qual[drmm_ctx_loop].values="ALL"))
           SET drmm_tier_stmt = concat(drmm_tier_stmt," and 1 = 1 ")
          ELSE
           SET drmm_tier_stmt = concat(drmm_tier_stmt,
            " and d.context_name = drdm_contexts->qual[drmm_ctx_loop].values ")
          ENDIF
          FOR (drmm_log_loop = 1 TO size(drmm_logtypes->qual,5))
            SET drmm_log_type_stmt = drmm_tier_stmt
            SET drmm_log_type_stmt = concat(drmm_log_type_stmt,
             " and d.log_type = drmm_logtypes->qual[drmm_log_loop].types ")
            SELECT INTO "nl:"
             null_check = nullind(d.context_name), l1 = length(d.ptam_match_result_str)
             FROM (parser(drdmm_srch_str) d)
             WHERE parser(drmm_log_type_stmt)
             HEAD REPORT
              drdm_log_cnt = 0, stat = alterlist(drdm_chg->log,drdm_batch_size)
             DETAIL
              drdm_log_cnt = (drdm_log_cnt+ 1), drdm_chg->log[drdm_log_cnt].pk_where_value = d
              .pk_where_value, drdm_chg->log[drdm_log_cnt].log_id = d.log_id,
              drdm_chg->log[drdm_log_cnt].pk_where = replace(d.pk_where,"<MERGE_LINK>",
               dm2_ref_data_doc->post_link_name,0), drdm_chg->log[drdm_log_cnt].table_name = d
              .table_name, drdm_chg->log[drdm_log_cnt].delete_ind = d.delete_ind,
              drdm_chg->log[drdm_log_cnt].updt_cnt = d.updt_cnt, drdm_chg->log[drdm_log_cnt].
              next_to_process = (drdm_log_cnt+ 1), drdm_chg->log[drdm_log_cnt].commit_ind = 1,
              drdm_chg->log[drdm_log_cnt].md_delete_ind = 0, drdm_chg->log[drdm_log_cnt].process_flg
               = 1, drdm_chg->log[drdm_log_cnt].status_flg = 0,
              drdm_chg->log[drdm_log_cnt].src_cntxt_name = d.context_name, drdm_chg->log[drdm_log_cnt
              ].exploded_ind = 0, drdm_chg->log[drdm_log_cnt].pkw_vers_id = d.dm_refchg_pkw_vers_id,
              drdm_chg->log[drdm_log_cnt].updt_applctx = d.updt_applctx, drdm_chg->log[drdm_log_cnt].
              pk_where_hash = d.pk_where_hash, drdm_chg->log[drdm_log_cnt].ptam_match_hash = d
              .ptam_match_hash,
              drdm_chg->log[drdm_log_cnt].ptam_match_result = d.ptam_match_result, drdm_chg->log[
              drdm_log_cnt].ptam_match_result_str = d.ptam_match_result_str, drdm_chg->log[
              drdm_log_cnt].ptam_str_tspace_cnt = (l1 - size(drdm_chg->log[drdm_log_cnt].
               ptam_match_result_str)),
              drdm_chg->log[drdm_log_cnt].md_context_name = "", drdm_chg->log[drdm_log_cnt].
              context_name = drmm_get_context_name(drdm_chg->log[drdm_log_cnt].src_cntxt_name)
              IF (d.delete_ind=0)
               drdm_chg->log[drdm_log_cnt].validate_ind = 1
              ELSE
               drdm_chg->log[drdm_log_cnt].validate_ind = 0
              ENDIF
             FOOT REPORT
              stat = alterlist(drdm_chg->log,drdm_log_cnt), drmm_batch_qual = drdm_log_cnt
             WITH nocounter, maxqual(d,value(drdm_batch_size)), forupdatewait(d)
            ;end select
            IF (check_error("Obtaining DCL rows to process")=1)
             CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
             ROLLBACK
             SET drmm_tier_done = 1
            ELSE
             IF (drmm_batch_qual > 0)
              SET drmm_tier_done = 1
              SET drmm_ctx_loop = size(drdm_contexts->qual,5)
              SET drmm_log_loop = size(drmm_logtypes->qual,5)
             ENDIF
            ENDIF
          ENDFOR
        ENDFOR
        SET drmm_tier_done = 1
       ENDIF
     ENDWHILE
     SET drdm_dcl_qual = drmm_batch_qual
    ENDIF
    IF (check_error("While selecting rows from the dm_chg_log ")=1)
     ROLLBACK
     IF (((findstring("ORA-02049",dm_err->emsg,1,0) > 0) OR (findstring("ORA-01555",dm_err->emsg,1,0)
      > 0)) )
      SET drdm_timeout_cnt = (drdm_timeout_cnt+ 1)
      IF (drdm_timeout_cnt=5)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       GO TO exit_main
      ELSE
       SET dm_err->err_ind = 0
       SET dm_err->emsg = ""
       SET dm_err->eproc =
       "Distributed Timeout occured when selecting from DM_CHG_LOG. Attempting to re-try query again."
       CALL disp_msg(" ",dm_err->logfile,0)
      ENDIF
     ELSE
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      GO TO exit_main
     ENDIF
    ELSE
     SET drdm_timeout_cnt = 5
    ENDIF
  ENDWHILE
  IF (drdm_log_cnt > 0)
   SET drdm_chg->log[drdm_log_cnt].next_to_process = 0
   SET drdm_max_rs_size = drdm_log_cnt
   SET drdm_eraseable_ind = 0
   SET drdm_next_row_pos = (drdm_log_cnt+ 1)
   CALL merge_audit("BATCH START","A new batch of dm_chg_log rows was gathered for processing",3)
  ENDIF
  IF (drdm_dcl_qual=0
   AND drdm_proc_tab="")
   SET rhr_return_value = 0
   SET rhr_return_value = reset_holdng_rows(null)
   IF (rhr_return_value != 0)
    GO TO try_again
   ENDIF
  ENDIF
  IF (drdm_dcl_qual=0
   AND drdm_proc_tab=""
   AND (global_mover_rec->auto_cutover_ind=1))
   SET stat = alterlist(auto_ver_request->qual,1)
   SET auto_ver_request->qual[1].rdds_event = "Move Finished"
   SET auto_ver_request->qual[1].cur_environment_id = dm2_ref_data_doc->env_target_id
   SET auto_ver_request->qual[1].paired_environment_id = dm2_ref_data_doc->env_source_id
   EXECUTE dm_rmc_auto_verify_setup
   IF (drmm_rows_processed_ind=0)
    SET dm_err->eproc = "There are no more rows to be MERGED, and Auto Cutover has already been run."
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
    GO TO exit_main
   ENDIF
   SET dm_err->eproc = "Querying for 'UNPROCESSED' rows on dm_refchg_rtable_reset"
   SELECT INTO "nl:"
    v_cnt = count(*)
    FROM dm_refchg_rtable_reset r
    WHERE r.reset_status IN ("UNPROCESSED", "SEVERE")
    DETAIL
     drmm_udb_cnt = v_cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->eproc,dm_err->logfile,dm_err->err_ind)
    GO TO exit_main
   ENDIF
   IF (drmm_udb_cnt > 0)
    SET stat = alterlist(auto_ver_request->qual,1)
    SET auto_ver_request->qual[1].rdds_event = "Auto Cutover Dual Build Issues"
    SET auto_ver_request->qual[1].cur_environment_id = dm2_ref_data_doc->env_target_id
    SET auto_ver_request->qual[1].paired_environment_id = dm2_ref_data_doc->env_source_id
    SET stat = alterlist(auto_ver_request->qual[1].detail_qual,1)
    SET avr_detail_size = 1
    SET auto_ver_request->qual[1].detail_qual[1].event_detail1_txt = "Number of Unprocessed Rows"
    SET auto_ver_request->qual[1].detail_qual[1].event_value = drmm_udb_cnt
    EXECUTE dm_rmc_auto_verify_setup
    IF ((auto_ver_reply->status="F"))
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_main
    ELSE
     COMMIT
    ENDIF
    SET dm_err->eproc = "Checking for unacknowledged dual build."
    SET dm_err->emsg = concat(
     "There are unacknowledged dual build changes detected which are preventing Auto-Cutover.  ",
     "Access the RDDS menu option 'Acknowledge Database Integrity Concerns for Cutover' to accept dual build risks ",
     "to proceed with Auto-Cutover.")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_main
   ENDIF
   SELECT INTO "NL:"
    FROM dm_refchg_process drp
    WHERE drp.rdbhandle_value IN (
    (SELECT
     audsid
     FROM gv$session))
     AND (drp.env_source_id=dm2_ref_data_doc->env_source_id)
     AND ((drp.refchg_type="CUTOVER PROCESS*") OR (drp.refchg_type="MOVER PROCESS"
     AND drp.refchg_status="DUPLICATE CHECKING"))
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET dm_err->eproc = "CUTOVER process is running, the mover won't attemp to cutover now"
    CALL disp_msg("",dm_err->logfile,0)
    GO TO done
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="RDDS AUTO LOCK"
     AND d.info_name="RDDS AUTO LOCK"
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM dm_info d
     SET d.info_domain = "RDDS AUTO LOCK", d.info_name = "RDDS AUTO LOCK"
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->err_ind = 0
     SET dm_err->eproc =
     "Another instance of the mover has already started the Auto Cutover process."
     CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
     GO TO exit_main
    ELSE
     COMMIT
    ENDIF
   ELSE
    SET dm_err->eproc = "There are no more rows to be MERGED"
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
    GO TO exit_main
   ENDIF
   CALL add_tracking_row(dm2_ref_data_doc->env_source_id,"MOVER PROCESS","DUPLICATE CHECKING")
   SET drc_request->num_cutover_processes = 1
   SELECT INTO "nl:"
    d.info_number
    FROM dm_info d
    WHERE d.info_domain="RDDS CONFIGURATION"
     AND d.info_name="AUTO CUTOVER PROCESS"
    DETAIL
     drc_request->num_cutover_processes = d.info_number
    WITH nocounter
   ;end select
   SET drc_request->source_env_id = dm2_ref_data_doc->env_source_id
   SET dm_auto_cut_ind = 1
   DELETE  FROM dm_info di
    WHERE di.info_domain=concat("RDDS CUTOVER::",trim(cnvtstring(drc_request->source_env_id,20,0)))
     AND (di.info_number=- (1))
    WITH nocounter
   ;end delete
   COMMIT
   SET stat = alterlist(auto_ver_request->qual,1)
   SET auto_ver_request->qual[1].rdds_event = "Auto-Cutover Started"
   SET auto_ver_request->qual[1].cur_environment_id = dm2_ref_data_doc->env_target_id
   SET auto_ver_request->qual[1].paired_environment_id = dm2_ref_data_doc->env_source_id
   SET stat = alterlist(auto_ver_request->qual[1].detail_qual,1)
   SET avr_detail_size = 1
   SET auto_ver_request->qual[1].detail_qual[1].event_detail1_txt = "PROCESS"
   SET auto_ver_request->qual[1].detail_qual[1].event_detail2_txt = drmm_cur_process
   EXECUTE dm_rmc_auto_verify_setup
   IF ((auto_ver_reply->status="F"))
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_main
   ELSE
    COMMIT
   ENDIF
   EXECUTE dm_rmc_cutover drc_request->source_env_id, drc_request->num_cutover_processes, " "
   SET dm_err->eproc = "There are no more rows to be MERGED."
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   CALL drdm_dcle_proc(null)
   GO TO done
  ELSEIF (drdm_dcl_qual=0)
   SET dm_err->eproc = "There are no more rows to be MERGED."
   IF (drdm_proc_tab="")
    SET stat = alterlist(auto_ver_request->qual,1)
    SET auto_ver_request->qual[1].rdds_event = "Move Finished"
    SET auto_ver_request->qual[1].cur_environment_id = dm2_ref_data_doc->env_target_id
    SET auto_ver_request->qual[1].paired_environment_id = dm2_ref_data_doc->env_source_id
    EXECUTE dm_rmc_auto_verify_setup
   ENDIF
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   CALL drdm_dcle_proc(null)
   GO TO done
  ELSE
   UPDATE  FROM (parser(drdmm_srch_str) d)
    SET d.log_type = "PROCES", d.rdbhandle = currdbhandle
    WHERE expand(drdm_exp_idx,1,drdm_log_cnt,d.log_id,drdm_chg->log[drdm_exp_idx].log_id)
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    GO TO exit_main
   ELSE
    COMMIT
   ENDIF
   CALL add_tracking_row(dm2_ref_data_doc->env_source_id,"MOVER PROCESS","MOVER RUNNING")
   SET drmm_rows_processed_ind = 1
  ENDIF
 ENDIF
 SET rw_cnt = 0
 CALL echo(build("Chg Log = ",curmem))
 SET drdm_complete_ind = 0
 SET drdm_log_loop = 1
 WHILE (drdm_complete_ind=0)
   IF ((global_mover_rec->cbc_ind=1))
    SET select_merge_translate_rec->from_opt_ctxt = drdm_chg->log[drdm_log_loop].context_name
    CALL parser(concat("RDB ASIS(^ BEGIN DM2_CONTEXT_CONTROL('RDDS_MOVER_CONTEXT','",drdm_chg->log[
      drdm_log_loop].context_name,"'); END; ^) GO"),1)
   ENDIF
   SET drmm_ddl_rollback_ind = 0
   SET drdm_no_trans_ind = 0
   SET nodelete_ind = 0
   SET no_insert_update = 0
   SET temp_tbl_cnt = locateval(simple_loop,1,size(dm2_ref_data_doc->tbl_qual,5),drdm_chg->log[
    drdm_log_loop].table_name,dm2_ref_data_doc->tbl_qual[simple_loop].table_name)
   IF ((drdm_chg->log[drdm_log_loop].validate_ind=1))
    SET temp_tbl_cnt = locateval(simple_loop,1,size(dm2_ref_data_doc->tbl_qual,5),drdm_chg->log[
     drdm_log_loop].table_name,dm2_ref_data_doc->tbl_qual[simple_loop].table_name)
    IF (temp_tbl_cnt=0)
     SET temp_tbl_cnt = fill_rs("TABLE",drdm_chg->log[drdm_log_loop].table_name)
     IF ((temp_tbl_cnt=- (1)))
      CALL disp_msg("Table can't be created from remote mover",dm_err->logfile,1)
      ROLLBACK
      CALL del_chg_log(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name,"HOLDNG",dm2_ref_data_doc
       ->env_target_id)
      SET drdm_chg->log[drdm_log_loop].process_flg = 5
      COMMIT
     ENDIF
     IF ((temp_tbl_cnt=- (2)))
      SET drdm_log_loop = redirect_to_start_row(drdm_chg,drdm_log_loop,drdm_next_row_pos,
       drdm_max_rs_size)
     ENDIF
    ENDIF
    IF (temp_tbl_cnt > 0)
     IF ((((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].mergeable_ind=0)) OR ((dm2_ref_data_doc->
     tbl_qual[temp_tbl_cnt].reference_ind=0))) )
      CALL echo("The table is not mergeable so it will not be merged")
     ELSE
      SET drdm_valid_rows_cnt = 0
      IF ((drdm_chg->log[drdm_log_loop].pk_where_hash=0.0)
       AND (drdm_chg->log[drdm_log_loop].delete_ind=0)
       AND (dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].cur_state_flag != 1))
       SET drmm_backfill_type = drmm_hash_backfill(drdm_log_loop,temp_tbl_cnt)
       IF (drmm_backfill_type > "")
        ROLLBACK
        CALL del_chg_log(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name,drmm_backfill_type,
         dm2_ref_data_doc->env_target_id)
        SET drdm_chg->log[drdm_log_loop].process_flg = 5
        SET drdm_valid_rows_cnt = - (1)
        COMMIT
       ENDIF
      ENDIF
      IF ((drdm_valid_rows_cnt != - (1)))
       SET drdm_proc_call_ind = 0
       SET dm_err->eproc = concat("Validating the DM_CHG_LOG row  ",trim(cnvtstring(drdm_chg->log[
          drdm_log_loop].log_id,20,1)))
       SET drdm_valid_rows_cnt = drdm_hash_validate(drdm_chg->log[drdm_log_loop].table_name,drdm_chg
        ->log[drdm_log_loop].pk_where,temp_tbl_cnt,drdm_chg->log[drdm_log_loop].pk_where_hash,
        drdm_chg->log[drdm_log_loop].ptam_match_hash,
        drdm_chg->log[drdm_log_loop].delete_ind,drdm_chg->log[drdm_log_loop].updt_applctx)
       IF (drdm_log_loop != drdm_valid_rows_cnt)
        SET drdm_chg->log[drdm_log_loop].process_flg = 5
        IF (drdm_valid_rows_cnt < 0)
         IF (drdm_valid_rows_cnt IN (- (1), - (2))
          AND drdm_no_insert_ind=0)
          IF (drdm_valid_rows_cnt IN (- (1), - (2)))
           SET drdm_tpc_tab_name = drdm_chg->log[drdm_log_loop].table_name
           SET drdm_tpc_pk_where = drdm_chg->log[drdm_log_loop].pk_where
           SET drdm_tpc_context = drdm_chg->log[drdm_log_loop].context_name
          ENDIF
          SET drdm_proc_dcl_id = trigger_proc_dcl(drdm_chg->log[drdm_log_loop].log_id,
           drdm_tpc_tab_name,"",drdm_chg->log[drdm_log_loop].delete_ind,0.0,
           "REFCHG",drdm_chg->log[drdm_log_loop].src_cntxt_name)
         ENDIF
        ENDIF
        IF ((drdm_proc_dcl_id=- (1.0)))
         ROLLBACK
         CALL del_chg_log(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name,"NOMV49",
          dm2_ref_data_doc->env_target_id)
         COMMIT
        ELSEIF ((drdm_proc_dcl_id=- (3.0)))
         ROLLBACK
         CALL del_chg_log(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name,"NO SRC",
          dm2_ref_data_doc->env_target_id)
         COMMIT
        ELSEIF ((((drdm_proc_dcl_id=- (4.0))) OR ((drdm_valid_rows_cnt=- (4)))) )
         ROLLBACK
         CALL log_md_scommit(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name,temp_tbl_cnt,
          "NOMV11",drdm_log_loop)
         CALL del_chg_log(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name,"NOMV11",
          dm2_ref_data_doc->env_target_id)
         COMMIT
        ELSE
         IF ((drdm_valid_rows_cnt=- (1)))
          SET drdm_chg->log[drdm_log_loop].chg_log_reason_txt = concat(drdm_chg->log[drdm_log_loop].
           chg_log_reason_txt," because the PK_WHERE is in an incorrect form.")
         ELSE
          SET drdm_chg->log[drdm_log_loop].chg_log_reason_txt = concat(drdm_chg->log[drdm_log_loop].
           chg_log_reason_txt," because the PTAM_MATCH_QUERY is in an incorrect form.")
         ENDIF
         CALL del_chg_log(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name,"BADLOG",
          dm2_ref_data_doc->env_target_id)
         COMMIT
        ENDIF
        SET temp_tbl_cnt = - (2)
        IF (drdm_log_loop=0)
         SET drdm_complete_ind = 1
         CALL merge_audit("BATCH END",concat("The end of a batch was reached at log_id ",trim(
            cnvtstring(drdm_chg->log[drdm_log_loop].log_id,20,1))),1)
        ENDIF
       ENDIF
      ENDIF
      SET temp_tbl_cnt = locateval(simple_loop,1,size(dm2_ref_data_doc->tbl_qual,5),drdm_chg->log[
       drdm_log_loop].table_name,dm2_ref_data_doc->tbl_qual[simple_loop].table_name)
      IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].cur_state_flag > 0)
       AND drdm_log_loop != 0
       AND drdm_valid_rows_cnt > 0)
       SET drmm_cs_xpld_type = drmm_cur_state_explode(drdm_log_loop)
       IF (drmm_cs_xpld_type="NOMV57")
        COMMIT
       ENDIF
       IF (drmm_cs_xpld_type="-2")
        SET drdm_log_loop = redirect_to_start_row(drdm_chg,drdm_log_loop,drdm_next_row_pos,
         drdm_max_rs_size)
        SET drdm_valid_rows_cnt = - (1)
       ELSEIF (drmm_cs_xpld_type > "")
        ROLLBACK
        CALL del_chg_log(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name,drmm_cs_xpld_type,
         dm2_ref_data_doc->env_target_id)
        SET drdm_chg->log[drdm_log_loop].process_flg = 5
        SET drdm_valid_rows_cnt = - (1)
        COMMIT
       ENDIF
      ENDIF
      IF (drdm_log_loop != 0
       AND drdm_valid_rows_cnt > 0)
       SET temp_tbl_cnt = locateval(simple_loop,1,size(dm2_ref_data_doc->tbl_qual,5),drdm_chg->log[
        drdm_log_loop].table_name,dm2_ref_data_doc->tbl_qual[simple_loop].table_name)
       IF ((((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].merge_delete_ind=1)) OR ((drdm_chg->log[
       drdm_log_loop].table_name="SEG_GRP_SEQ_R"))) )
        SET dm_err->eproc = concat("Exploding an MD row  ",trim(cnvtstring(drdm_chg->log[
           drdm_log_loop].log_id,20,1)))
        SET drdm_related_rows_cnt = drdm_get_merge_del_rows(drdm_chg->log[drdm_log_loop].table_name,
         drdm_chg->log[drdm_log_loop].pk_where,temp_tbl_cnt,drdm_chg->log[drdm_log_loop].
         single_pass_value,drdm_chg->log[drdm_log_loop].process_flg,
         drmm_prescan_data)
        IF (drdm_related_rows_cnt > 0)
         SET drmm_prescan_idx = locateval(drmm_prescan_idx,1,drmm_prescan_data->cnt,drdm_chg->log[
          drdm_log_loop].log_id,drmm_prescan_data->qual[drmm_prescan_idx].log_id)
         IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].pre_scan_ind=1)
          AND (drdm_chg->log[drdm_log_loop].process_flg != 7)
          AND drmm_prescan_idx=0)
          SET drdm_chg->log[drdm_log_loop].process_flg = 7
         ELSE
          IF ((drdm_chg->log[drdm_related_rows_cnt].process_flg=6))
           SET drdm_chg->log[drdm_log_loop].process_flg = 5
          ELSE
           SET drdm_chg->log[drdm_log_loop].process_flg = 4
          ENDIF
         ENDIF
         SET drdm_chg->log[drdm_log_loop].validate_ind = 0
         SET drdm_log_loop = drdm_related_rows_cnt
        ELSEIF ((drdm_related_rows_cnt=- (2)))
         SELECT INTO "nl:"
          FROM dm_refchg_filter_test rft
          WHERE (rft.table_name=dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name)
           AND rft.active_ind=1
          DETAIL
           drdm_mover_string = rft.mover_string
          WITH nocounter
         ;end select
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          GO TO exit_main
         ENDIF
         IF (drdm_mover_string != "")
          SET drdm_chg->log[drdm_log_loop].process_flg = 5
          CALL del_chg_log(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name,"NOMV11",
           dm2_ref_data_doc->env_target_id)
          COMMIT
         ELSE
          SET drdm_chg->log[drdm_log_loop].process_flg = 5
          CALL del_chg_log(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name,"NO SRC",
           dm2_ref_data_doc->env_target_id)
          COMMIT
         ENDIF
        ELSEIF ((drdm_related_rows_cnt=- (3)))
         SET drdm_chg->log[drdm_log_loop].process_flg = 5
         CALL del_chg_log(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name,"NOMV1C",
          dm2_ref_data_doc->env_target_id)
         COMMIT
        ELSE
         SET drdm_chg->log[drdm_log_loop].process_flg = 5
         SET nodelete_ind = 1
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET drdm_valid_rows_cnt = drdm_log_loop
   ENDIF
   IF (temp_tbl_cnt > 0)
    IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].mergeable_ind != 0)
     AND (dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].reference_ind != 0))
     IF (drdm_log_loop != 0
      AND drdm_valid_rows_cnt > 0
      AND (drdm_chg->log[drdm_log_loop].validate_ind=1))
      SET gvr_ind = 0
      IF ((((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name="DCP_FORMS_REF")) OR ((
      dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name="DCP_SECTION_REF"))) )
       SET gvr_ind = 1
      ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].version_ind=1))
       IF ((((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].version_type="ALG1")) OR ((((dm2_ref_data_doc
       ->tbl_qual[temp_tbl_cnt].version_type="ALG3")) OR ((((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt]
       .version_type="ALG3D")) OR ((((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].version_type="ALG4"))
        OR ((((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].version_type="ALG5")) OR ((((dm2_ref_data_doc
       ->tbl_qual[temp_tbl_cnt].version_type="ALG6")) OR ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
       version_type="ALG7"))) )) )) )) )) )) )
        SET gvr_ind = 1
       ENDIF
      ENDIF
      IF (gvr_ind=1)
       SET drdm_vt_rows_cnt = drdm_get_versioned_row(drdm_chg->log[drdm_log_loop].table_name,drdm_chg
        ->log[drdm_log_loop].pk_where,temp_tbl_cnt)
       IF (drdm_vt_rows_cnt != drdm_log_loop)
        IF ((drdm_vt_rows_cnt=- (1)))
         SET drdm_complete_ind = 1
         SET drdm_chg->log[drdm_log_loop].process_flg = 5
         SET drdm_log_loop = 0
        ELSEIF ((drdm_vt_rows_cnt=- (2)))
         SET drdm_chg->log[drdm_log_loop].process_flg = 5
         CALL del_chg_log(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name,"NO SRC",
          dm2_ref_data_doc->env_target_id)
         COMMIT
        ELSEIF ((drdm_vt_rows_cnt=- (3)))
         SET drdm_chg->log[drdm_log_loop].process_flg = 5
         CALL del_chg_log(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name,"NOMV44",
          dm2_ref_data_doc->env_target_id)
         COMMIT
        ELSE
         IF ((drdm_chg->log[drdm_log_loop].process_flg != 6))
          SET drdm_chg->log[drdm_log_loop].process_flg = 4
         ELSE
          SET drdm_chg->log[drdm_log_loop].process_flg = 5
         ENDIF
         SET drdm_filter_ret = filter_proc_call(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name,
          drdm_chg->log[drdm_vt_rows_cnt].pk_where,drdm_chg->log[drdm_log_loop].updt_applctx)
         IF (drdm_filter_ret=0
          AND drdm_error_out_ind != 1)
          ROLLBACK
          SET drdm_chg->log[drdm_log_loop].process_flg = 5
          CALL log_md_scommit(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name,temp_tbl_cnt,
           "NOMV11",drdm_vt_rows_cnt)
          CALL del_chg_log(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name,"NOMV11",
           dm2_ref_data_doc->env_target_id)
          COMMIT
         ELSEIF (drdm_error_out_ind=1)
          SET temp_tbl_cnt = - (2)
         ELSE
          SET drdm_chg->log[drdm_log_loop].validate_ind = 0
          SET drdm_log_loop = drdm_vt_rows_cnt
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
     IF ((drdm_chg->log[drdm_log_loop].process_flg IN (1, 2, 3, 6))
      AND (drdm_chg->log[drdm_log_loop].delete_ind=0))
      SET temp_tbl_cnt = locateval(simple_loop,1,size(dm2_ref_data_doc->tbl_qual,5),drdm_chg->log[
       drdm_log_loop].table_name,dm2_ref_data_doc->tbl_qual[simple_loop].table_name)
      IF (temp_tbl_cnt=0)
       SET temp_tbl_cnt = fill_rs("TABLE",drdm_chg->log[drdm_log_loop].table_name)
       IF ((temp_tbl_cnt=- (1)))
        CALL disp_msg("Table can't be created from remote mover",dm_err->logfile,1)
        ROLLBACK
        CALL del_chg_log(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name,"HOLDNG",
         dm2_ref_data_doc->env_target_id)
        COMMIT
        SET drdm_chg->log[drdm_log_loop].process_flg = 5
       ENDIF
       IF ((temp_tbl_cnt=- (2)))
        SET drdm_log_loop = redirect_to_start_row(drdm_chg,drdm_log_loop,drdm_next_row_pos,
         drdm_max_rs_size)
       ENDIF
      ENDIF
      IF (temp_tbl_cnt > 0
       AND (drdm_chg->log[drdm_log_loop].exploded_ind=0))
       SET drdm_child_cnt = drdm_get_child_rows(drdm_chg->log[drdm_log_loop].table_name,drdm_chg->
        log[drdm_log_loop].pk_where,temp_tbl_cnt,drdm_chg->log[drdm_log_loop].next_to_process)
       IF (drdm_child_cnt != drdm_log_loop)
        IF ((drdm_child_cnt=- (1)))
         SET drdm_complete_ind = 1
         SET drdm_chg->log[drdm_log_loop].process_flg = 5
         SET drdm_log_loop = 0
        ELSEIF ((drdm_child_cnt=- (2)))
         SET drdm_log_loop = redirect_to_start_row(drdm_chg,drdm_log_loop,drdm_next_row_pos,
          drdm_max_rs_size)
         SET temp_tbl_cnt = - (2)
        ELSE
         IF ((drdm_chg->log[drdm_log_loop].process_flg != 6))
          SET drdm_chg->log[drdm_log_loop].process_flg = 2
         ENDIF
         SET drdm_chg->log[drdm_log_loop].next_to_process = drdm_child_cnt
         SET drdm_chg->log[drdm_log_loop].exploded_ind = 1
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ELSE
     SET drdm_valid_rows_cnt = drdm_log_loop
    ENDIF
   ENDIF
   IF (drdm_log_loop != 0
    AND drdm_valid_rows_cnt > 0
    AND (temp_tbl_cnt != - (2)))
    IF (drdm_log_loop > drdm_log_cnt)
     SET drdm_eraseable_ind = 1
    ENDIF
    IF ((drdm_chg->log[drdm_log_loop].process_flg != 5))
     SET nvp_commit_ind = 1
     SET rec_found = 0
     SET temp_tbl_cnt = 0
     DECLARE drdm_tab_name = vc
     SET drdm_tab_name = drdm_chg->log[drdm_log_loop].table_name
     DECLARE tab_size = i4
     SET tab_size = size(dm2_ref_data_doc->tbl_qual,5)
     SET temp_tbl_cnt = locateval(simple_loop,1,tab_size,drdm_tab_name,dm2_ref_data_doc->tbl_qual[
      simple_loop].table_name)
     IF (temp_tbl_cnt != 0)
      SET rec_found = 1
     ENDIF
     IF (rec_found=0)
      SET temp_tbl_cnt = fill_rs("TABLE",drdm_chg->log[drdm_log_loop].table_name)
      IF ((temp_tbl_cnt=- (1)))
       CALL disp_msg("Table can't be created from remote mover",dm_err->logfile,1)
       ROLLBACK
       CALL del_chg_log(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name,"HOLDNG",dm2_ref_data_doc
        ->env_target_id)
       COMMIT
       SET drdm_chg->log[drdm_log_loop].process_flg = 5
      ENDIF
     ENDIF
     IF ((temp_tbl_cnt=- (2)))
      CALL echo("Table was changed (DDL), the row will be reprocessed")
     ELSEIF (temp_tbl_cnt <= 0)
      CALL disp_msg("ERROR: Could not find table in table level metadata",dm_err->logfile,1)
      SET dm_err->err_ind = 0
     ELSEIF ((((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].mergeable_ind=0)) OR ((dm2_ref_data_doc->
     tbl_qual[temp_tbl_cnt].reference_ind=0))) )
      CALL echo("The table is not reference or is not mergeable so it will not be merged")
      SET drdmm_srch_str = dm2_get_rdds_tname("DM_CHG_LOG")
      IF (drdm_debug_row_ind=1)
       UPDATE  FROM (parser(drdmm_srch_str) d)
        SET d.log_type = "NOMV00", d.updt_cnt = (d.updt_cnt+ 1), d.rdbhandle = null,
         d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
        WHERE (d.log_id=drdm_chg->log[drdm_log_loop].log_id)
        WITH nocounter
       ;end update
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_main
       ELSE
        COMMIT
       ENDIF
      ELSE
       SET dm_err->eproc = "Updating rows to NOMV00."
       SET drmm_next_row = drmm_updt_nomv00(drdm_log_loop,drdm_filter_string)
       IF (drmm_next_row < 0)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_main
       ELSE
        IF (drdm_next_row_pos > drdm_max_rs_size)
         SET drdm_max_rs_size = (drdm_max_rs_size+ 10)
         SET stat = alterlist(drdm_chg->log,drdm_max_rs_size)
        ENDIF
        CALL reinitialize_drdm(drdm_next_row_pos)
        SET drdm_chg->log[drdm_next_row_pos].next_to_process = drmm_next_row
        SET drdm_log_loop = drdm_next_row_pos
        SET drdm_next_row_pos = (drdm_next_row_pos+ 1)
        SET drmm_nomv00_ind = 1
       ENDIF
      ENDIF
     ELSEIF ((drdm_chg->log[drdm_log_loop].process_flg IN (1, 2, 3, 6, 8)))
      CALL parser(concat("set rs_valid_ind = validate(RS_",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
        suffix,"->log_id, -1) go"),1)
      IF ((rs_valid_ind != - (1)))
       CALL echo("This RS is already created")
       SET perm_col_cnt = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt
      ELSE
       CALL parser(concat("free record RS_",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].suffix," go"),1)
       SET drdm_parser->statement[1].frag = concat("record RS_",dm2_ref_data_doc->tbl_qual[
        temp_tbl_cnt].suffix)
       SET drdm_parser->statement[2].frag = concat("(1 log_id = f8 ","1 audit_sequence = i4 ",
        "1 from_table_name = vc ","1 from_values ")
       SET temp_col_cnt = 0
       SET drdm_parser_cnt = 2
       SET perm_col_cnt = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt
       WHILE (temp_col_cnt < perm_col_cnt)
         SET temp_col_cnt = (temp_col_cnt+ 1)
         CALL parser(build("set drd_data_type = ",
           "value(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[temp_col_cnt].data_type) go"),1)
         FREE SET drdm_col_name
         DECLARE drdm_col_name = vc
         CALL parser(build("set drdm_col_name = ",
           "value(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[temp_col_cnt].column_name) go"),1
          )
         SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
         SET drdm_parser->statement[((drdm_parser_cnt+ perm_col_cnt)+ 1)].frag = concat(" 2 ",
          drdm_col_name," = ",value(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[temp_col_cnt].
           data_type)," ")
         SET drdm_parser->statement[drdm_parser_cnt].frag = concat(" 2 ",value(dm2_ref_data_doc->
           tbl_qual[temp_tbl_cnt].col_qual[temp_col_cnt].column_name)," = ",value(dm2_ref_data_doc->
           tbl_qual[temp_tbl_cnt].col_qual[temp_col_cnt].data_type)," ")
       ENDWHILE
       SET drdm_parser_cnt = (drdm_parser_cnt+ 1)
       SET drdm_parser->statement[(perm_col_cnt+ 3)].frag = concat(" 1 to_table_name = vc ",
        "1 to_values ")
       SET drdm_parser->statement[((perm_col_cnt * 2)+ 4)].frag = ") go"
       FOR (simple_loop = 1 TO ((perm_col_cnt * 2)+ 4))
         IF (simple_loop=drdm_parser_cnt)
          SET drdm_go_ind = 1
         ELSE
          SET drdm_go_ind = 0
         ENDIF
         CALL parser(drdm_parser->statement[simple_loop].frag,drdm_go_ind)
         SET drdm_parser->statement[simple_loop].frag = ""
       ENDFOR
       SET dm_err->eproc = concat("Creating dm2_ref_data RS",cnvtstring(drdm_chg->log[drdm_log_loop].
         log_id,20,0))
       CALL disp_msg(" ",dm_err->logfile,0)
      ENDIF
     ENDIF
    ENDIF
    IF (temp_tbl_cnt > 0
     AND drmm_nomv00_ind=0)
     IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].mergeable_ind=0))
      CALL echo("The table is reference not mergeable so it will not be merged")
      ROLLBACK
      SET drdmm_srch_str = dm2_get_rdds_tname("DM_CHG_LOG")
      IF (drdm_debug_row_ind=1)
       UPDATE  FROM (parser(drdmm_srch_str) d)
        SET d.log_type = "NOMV00", d.updt_cnt = (d.updt_cnt+ 1), d.rdbhandle = null,
         d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
        WHERE (d.log_id=drdm_chg->log[drdm_log_loop].log_id)
        WITH nocounter
       ;end update
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_main
       ELSE
        COMMIT
       ENDIF
      ELSE
       SET dm_err->eproc = "Updating rows to NOMV00."
       SET drmm_next_row = drmm_updt_nomv00(drdm_log_loop,drdm_filter_string)
       IF (drmm_next_row < 0)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_main
       ELSE
        IF (drdm_next_row_pos > drdm_max_rs_size)
         SET drdm_max_rs_size = (drdm_max_rs_size+ 10)
         SET stat = alterlist(drdm_chg->log,drdm_max_rs_size)
        ENDIF
        CALL reinitialize_drdm(drdm_next_row_pos)
        SET drdm_chg->log[drdm_next_row_pos].next_to_process = drmm_next_row
        SET drdm_log_loop = drdm_next_row_pos
        SET drdm_next_row_pos = (drdm_next_row_pos+ 1)
       ENDIF
      ENDIF
     ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].reference_ind=0))
      CALL echo("The table is not reference so it will not be merged")
      SET drdmm_srch_str = dm2_get_rdds_tname("DM_CHG_LOG")
      IF (drdm_debug_row_ind=1)
       UPDATE  FROM (parser(drdmm_srch_str) d)
        SET d.log_type = "NOMV00", d.updt_cnt = (d.updt_cnt+ 1), d.rdbhandle = null,
         d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
        WHERE (d.log_id=drdm_chg->log[drdm_log_loop].log_id)
        WITH nocounter
       ;end update
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_main
       ELSE
        COMMIT
       ENDIF
      ELSE
       SET dm_err->eproc = "Updating rows to NOMV00."
       SET drmm_next_row = drmm_updt_nomv00(drdm_log_loop,drdm_filter_string)
       IF (drmm_next_row < 0)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_main
       ELSE
        IF (drdm_next_row_pos > drdm_max_rs_size)
         SET drdm_max_rs_size = (drdm_max_rs_size+ 10)
         SET stat = alterlist(drdm_chg->log,drdm_max_rs_size)
        ENDIF
        CALL reinitialize_drdm(drdm_next_row_pos)
        SET drdm_chg->log[drdm_next_row_pos].next_to_process = drmm_next_row
        SET drdm_log_loop = drdm_next_row_pos
        SET drdm_next_row_pos = (drdm_next_row_pos+ 1)
       ENDIF
      ENDIF
     ELSE
      SET perm_col_cnt = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt
      SET drdm_tot_cnt = (drdm_tot_cnt+ 1)
      CALL echo("%%%%%%%%%%%%%%%%%%%%%%%")
      CALL echo(drdm_tot_cnt)
      CALL echo("%%%%%%%%%%%%%%%%%%%%%%%")
      IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].mergeable_ind=1)
       AND (drdm_chg->log[drdm_log_loop].process_flg IN (1, 2, 3, 6, 8)))
       SET drdm_no_trans_ind = 0
       IF ((drdm_chg->log[drdm_log_loop].delete_ind=1))
        EXECUTE dm_rmc_mover_main_child
       ELSEIF ((drdm_chg->log[drdm_log_loop].table_name="CODE_VALUE"))
        EXECUTE dm_rmc_mover_0619
       ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].merge_delete_ind=1)
        AND (dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].insert_only_ind=1))
        CALL merge_audit("FAILREASON",
         "This table is listed as Target as Master, so the Merge Delete will not occur",3)
        UPDATE  FROM (parser(drdmm_srch_str) d)
         SET d.log_type = "NOMV09", d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_cnt = (d
          .updt_cnt+ 1)
         WHERE (d.log_id=drdm_chg->log[drdm_log_loop].log_id)
        ;end update
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         ROLLBACK
        ELSE
         IF ((drdm_chg->log[drdm_log_loop].commit_ind=1))
          COMMIT
         ENDIF
        ENDIF
       ELSE
        EXECUTE dm_rmc_mover_main_child
       ENDIF
      ENDIF
      IF (drmm_ddl_rollback_ind=1)
       SET drdm_mini_loop_status = ""
       SET drdm_no_trans_ind = 1
       SET nodelete_ind = 1
       SET no_insert_update = 1
       SET stat = alterlist(missing_xlats->qual,0)
       SET drmm_prescan_data->cnt = 0
       SET stat = alterlist(drmm_prescan_data->qual,0)
      ENDIF
      SET dm_err->err_ind = 0
      IF (drdm_error_out_ind=1)
       SET drdm_complete_ind = 1
       ROLLBACK
      ENDIF
      IF (drdm_mini_loop_status != ""
       AND nodelete_ind=0
       AND drdm_no_trans_ind=0
       AND (drdm_chg->log[drdm_log_loop].process_flg IN (1, 3, 4)))
       CALL del_chg_log(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name,drdm_mini_loop_status,
        dm2_ref_data_doc->env_target_id)
       SET drdm_mini_loop_status = ""
      ENDIF
      IF (drdm_error_out_ind != 1
       AND nodelete_ind=0
       AND (drdm_chg->log[drdm_log_loop].process_flg IN (1, 4, 6))
       AND (drdm_chg->log[drdm_log_loop].commit_ind=1)
       AND drdm_no_trans_ind=0)
       COMMIT
       IF (create_ccl_def(null) != 0)
        SET drdm_complete_ind = 1
        SET drdm_error_out_ind = 1
        CALL disp_msg("Trying to ORAGEN3 $R tables",dm_err->logfile,1)
       ENDIF
      ENDIF
      IF (((drdm_no_trans_ind=1) OR (nodelete_ind=1)) )
       IF (drdm_mini_loop_status IN ("ORPHAN", "OLDVER", "BADLOG", "NOMV*", "CHLD*"))
        IF ((global_mover_rec->one_pass_ind=0))
         ROLLBACK
        ENDIF
        IF ((((drdm_chg->log[drdm_log_loop].process_flg != 6)) OR (drdm_mini_loop_status IN ("NOMV*",
        "CHLD*"))) )
         SET nodelete_ind = 0
         CALL del_chg_log(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name,drdm_mini_loop_status,
          dm2_ref_data_doc->env_target_id)
         IF (drdm_error_out_ind != 1
          AND nodelete_ind=0)
          COMMIT
         ENDIF
        ENDIF
       ENDIF
       SET drdm_missing_cnt = size(missing_xlats->qual,5)
       IF (drdm_missing_cnt > 0)
        SET drdm_next_tab = ""
        IF ((drdm_chg->log[drdm_log_loop].next_to_process > 0))
         SET drdm_next_tab = drdm_chg->log[drdm_chg->log[drdm_log_loop].next_to_process].table_name
        ENDIF
        IF ((((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].merge_delete_ind=1)
         AND (drdm_chg->log[drdm_log_loop].table_name=drdm_next_tab)
         AND (drdm_chg->log[drdm_log_loop].delete_ind != 1)) OR ((dm2_ref_data_doc->tbl_qual[
        temp_tbl_cnt].merge_delete_ind=1)
         AND (drdm_chg->log[drdm_log_loop].next_to_process=0)
         AND (drdm_chg->log[drdm_log_loop].delete_ind != 1))) )
         IF ((drdm_chg->log[drdm_log_loop].process_flg=8))
          IF ((drdm_chg->log[drdm_chg->log[drdm_log_loop].next_to_process].process_flg=7))
           SET drdm_chg->log[drdm_chg->log[drdm_log_loop].next_to_process].validate_ind = 1
           SET drmm_prescan_idx = locateval(drmm_prescan_idx,1,drmm_prescan_data->cnt,drdm_chg->log[
            drdm_chg->log[drdm_log_loop].next_to_process].log_id,drmm_prescan_data->qual[
            drmm_prescan_idx].log_id)
           IF (drmm_prescan_idx=0)
            SET drmm_prescan_data->cnt = (drmm_prescan_data->cnt+ 1)
            SET stat = alterlist(drmm_prescan_data->qual,drmm_prescan_data->cnt)
            SET drmm_prescan_data->qual[drmm_prescan_data->cnt].log_id = drdm_chg->log[drdm_chg->log[
            drdm_log_loop].next_to_process].log_id
           ENDIF
           SET drdm_log_loop = add_missing_xlats(drdm_log_loop,drdm_missing_cnt)
           IF (drmm_ddl_rollback_ind=1)
            SET drdm_log_loop = redirect_to_start_row(drdm_chg,drdm_log_loop,drdm_next_row_pos,
             drdm_max_rs_size)
           ENDIF
          ELSE
           CALL echo("Continue processing pre-scan MD set")
          ENDIF
         ELSE
          SET drdm_log_loop = add_missing_xlats(drdm_log_loop,drdm_missing_cnt)
          IF (drmm_ddl_rollback_ind=1)
           SET drdm_log_loop = redirect_to_start_row(drdm_chg,drdm_log_loop,drdm_next_row_pos,
            drdm_max_rs_size)
          ENDIF
         ENDIF
        ELSE
         SET drdm_log_loop = add_missing_xlats(drdm_log_loop,drdm_missing_cnt)
         IF (drmm_ddl_rollback_ind=1)
          SET drdm_log_loop = redirect_to_start_row(drdm_chg,drdm_log_loop,drdm_next_row_pos,
           drdm_max_rs_size)
         ENDIF
        ENDIF
       ELSE
        IF ((drdm_chg->log[drdm_log_loop].process_flg=8)
         AND  NOT (drdm_mini_loop_status IN ("ORPHAN", "OLDVER", "BADLOG", "NOMV*", "CHLD*")))
         IF ((drdm_chg->log[drdm_chg->log[drdm_log_loop].next_to_process].process_flg=7)
          AND (drdm_chg->log[drdm_log_loop].process_flg=8))
          SET drdm_chg->log[drdm_chg->log[drdm_log_loop].next_to_process].validate_ind = 1
          SET drmm_prescan_idx = locateval(drmm_prescan_idx,1,drmm_prescan_data->cnt,drdm_chg->log[
           drdm_chg->log[drdm_log_loop].next_to_process].log_id,drmm_prescan_data->qual[
           drmm_prescan_idx].log_id)
          IF (drmm_prescan_idx=0)
           SET drmm_prescan_data->cnt = (drmm_prescan_data->cnt+ 1)
           SET stat = alterlist(drmm_prescan_data->qual,drmm_prescan_data->cnt)
           SET drmm_prescan_data->qual[drmm_prescan_data->cnt].log_id = drdm_chg->log[drdm_chg->log[
           drdm_log_loop].next_to_process].log_id
          ENDIF
         ELSE
          CALL echo("Continue processing pre-scan MD set")
         ENDIF
        ELSE
         ROLLBACK
         IF (create_ccl_def(null) != 0)
          SET drdm_complete_ind = 1
          SET drdm_error_out_ind = 1
          CALL disp_msg("Trying to ORAGEN3 $R tables",dm_err->logfile,1)
         ENDIF
         IF (drmm_ddl_rollback_ind=0)
          SET drdm_log_loop = find_next_commit(drdm_log_loop)
         ENDIF
        ENDIF
       ENDIF
       SET nodelete_ind = 0
       SET drdm_no_trans_ind = 0
       SET drdm_mini_loop_status = ""
      ELSE
       IF ((drdm_chg->log[drdm_log_loop].process_flg=8)
        AND  NOT (drdm_mini_loop_status IN ("ORPHAN", "OLDVER", "BADLOG", "NOMV*", "CHLD*")))
        IF ((drdm_chg->log[drdm_chg->log[drdm_log_loop].next_to_process].process_flg=7)
         AND (drdm_chg->log[drdm_log_loop].process_flg=8))
         SET drdm_chg->log[drdm_chg->log[drdm_log_loop].next_to_process].validate_ind = 1
         SET drmm_prescan_idx = locateval(drmm_prescan_idx,1,drmm_prescan_data->cnt,drdm_chg->log[
          drdm_chg->log[drdm_log_loop].next_to_process].log_id,drmm_prescan_data->qual[
          drmm_prescan_idx].log_id)
         IF (drmm_prescan_idx=0)
          SET drmm_prescan_data->cnt = (drmm_prescan_data->cnt+ 1)
          SET stat = alterlist(drmm_prescan_data->qual,drmm_prescan_data->cnt)
          SET drmm_prescan_data->qual[drmm_prescan_data->cnt].log_id = drdm_chg->log[drdm_chg->log[
          drdm_log_loop].next_to_process].log_id
         ENDIF
        ELSE
         CALL echo("Continue processing pre-scan MD set")
        ENDIF
       ENDIF
      ENDIF
     ENDIF
     IF ((((drdm_chg->log[drdm_log_loop].next_to_process=0)) OR (drdm_log_loop=0)) )
      SET drdm_complete_ind = 1
      CALL merge_audit("BATCH END",concat("The end of a batch was reached at log_id ",trim(cnvtstring
         (drdm_chg->log[drdm_log_loop].log_id,20,1))),1)
      ROLLBACK
      CALL del_chg_log(drdm_chg->log[drdm_log_loop].table_name,"HOLDNG",dm2_ref_data_doc->
       env_target_id)
      COMMIT
      SET stat = alterlist(missing_xlats->qual,0)
      SET drmm_prescan_data->cnt = 0
      SET stat = alterlist(drmm_prescan_data->qual,0)
     ELSE
      IF (drdm_log_loop <= drdm_log_cnt
       AND (drdm_chg->log[drdm_log_loop].next_to_process <= drdm_log_cnt))
       CALL del_chg_log(drdm_chg->log[drdm_log_loop].table_name,"HOLDNG",dm2_ref_data_doc->
        env_target_id)
       COMMIT
      ENDIF
      IF (drmm_ddl_rollback_ind=0)
       SET temp_tbl_cnt = locateval(simple_loop,1,dm2_ref_data_doc->tbl_cnt,drdm_chg->log[
        drdm_log_loop].table_name,dm2_ref_data_doc->tbl_qual[simple_loop].table_name)
       IF (temp_tbl_cnt != 0)
        IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].child_flag=2)
         AND (drdm_chg->log[drdm_log_loop].next_to_process <= drdm_log_cnt))
         CALL del_chg_log(drdm_chg->log[drdm_log_loop].table_name,"HOLDNG",dm2_ref_data_doc->
          env_target_id)
         COMMIT
        ENDIF
       ENDIF
      ENDIF
      IF (drdm_log_loop <= drdm_log_cnt
       AND (drdm_chg->log[drdm_log_loop].next_to_process <= drdm_log_cnt))
       SET stat = alterlist(missing_xlats->qual,0)
       SET drmm_prescan_data->cnt = 0
       SET stat = alterlist(drmm_prescan_data->qual,0)
      ENDIF
      SET drdm_log_loop = drdm_chg->log[drdm_log_loop].next_to_process
      IF (drdm_log_loop <= drdm_log_cnt
       AND drdm_eraseable_ind=1)
       IF (drdm_log_loop <= drdm_log_cnt)
        SET temp_tbl_cnt = locateval(simple_loop,1,dm2_ref_data_doc->tbl_cnt,drdm_chg->log[
         drdm_log_loop].table_name,dm2_ref_data_doc->tbl_qual[simple_loop].table_name)
        IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].parent_flag=2)
         AND (dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].child_flag=1)
         AND (dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].merge_delete_ind=0))
         SET drdm_chg->log[drdm_log_loop].process_flg = 1
        ENDIF
        IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].parent_flag != 2))
         SET drdm_eraseable_ind = 0
         SET drdm_next_row_pos = (drdm_log_cnt+ 1)
        ENDIF
       ENDIF
      ENDIF
      IF (drdm_debug_row_ind != 1)
       SET drdm_stop_time = cnvtdatetime("01-JAN-1800 00:00:00")
       SELECT INTO "NL:"
        FROM dm_info d
        WHERE d.info_domain="DATA MANAGEMENT"
         AND d.info_name="RDDS STOP TIME"
        DETAIL
         drdm_stop_time = cnvtdatetime(d.info_date)
        WITH nocounter
       ;end select
       IF (drdm_stop_time >= drdm_start_time)
        SET dm_err->eproc = concat("Mover stopped by user request at: ",format(drdm_stop_time,";;q"))
        CALL disp_msg(" ",dm_err->logfile,0)
        ROLLBACK
        UPDATE  FROM (parser(drdmm_srch_str) dcl)
         SET dcl.log_type = "REFCHG"
         WHERE dcl.log_type IN ("PROCES", "REPORT")
          AND (dcl.target_env_id=dm2_ref_data_doc->env_target_id)
          AND dcl.rdbhandle=currdbhandle
        ;end update
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         GO TO exit_main
        ENDIF
        COMMIT
        SET drdm_complete_ind = 1
       ENDIF
      ENDIF
     ENDIF
    ELSEIF ((((temp_tbl_cnt=- (2))) OR (drmm_nomv00_ind=1)) )
     SET drmm_nomv00_ind = 0
     IF ((drdm_chg->log[drdm_log_loop].next_to_process=0))
      SET drdm_complete_ind = 1
      CALL merge_audit("BATCH END",concat("The end of a batch was reached at log_id ",trim(cnvtstring
         (drdm_chg->log[drdm_log_loop].log_id,20,1))),1)
      IF ((drdm_chg->log[drdm_log_loop].table_name > ""))
       ROLLBACK
       CALL del_chg_log(drdm_chg->log[drdm_log_loop].table_name,"HOLDNG",dm2_ref_data_doc->
        env_target_id)
       COMMIT
      ENDIF
     ELSE
      SET drdm_log_loop = drdm_chg->log[drdm_log_loop].next_to_process
     ENDIF
    ELSEIF ((temp_tbl_cnt=- (1)))
     IF ((drdm_chg->log[drdm_log_loop].next_to_process=0))
      SET drdm_complete_ind = 1
     ELSE
      SET drdm_log_loop = drdm_chg->log[drdm_log_loop].next_to_process
     ENDIF
    ENDIF
   ELSE
    IF ((drdm_chg->log[drdm_log_loop].next_to_process=0))
     SET drdm_complete_ind = 1
     CALL merge_audit("BATCH END",concat("The end of a batch was reached at log_id ",trim(cnvtstring(
         drdm_chg->log[drdm_log_loop].log_id,20,1))),1)
     ROLLBACK
     CALL del_chg_log(drdm_chg->log[drdm_log_loop].table_name,"HOLDNG",dm2_ref_data_doc->
      env_target_id)
     COMMIT
    ELSE
     SET drdm_log_loop = drdm_chg->log[drdm_log_loop].next_to_process
    ENDIF
   ENDIF
 ENDWHILE
 IF (drdm_error_out_ind=1)
  GO TO exit_main
 ENDIF
 DECLARE dmyvb = i4
 FOR (dmyvb = 1 TO perm_tbl_cnt)
   SET dm2_ref_data_doc->tbl_qual[dmyvb].delete_select_ind = 0
 ENDFOR
 IF (drdm_debug_row_ind=1)
  SET dm_err->eproc = "Finished processing the debug row."
  CALL disp_msg(" ",dm_err->logfile,0)
  ROLLBACK
  GO TO done
 ELSE
  CALL drdm_dcle_proc(null)
 ENDIF
 SET has_data = 0
 SET drdm_log_cnt = 0
 IF (drmm_upd_dmt_status_flg(0) != 1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_main
 ENDIF
 GO TO rerun
 SUBROUTINE drdm_dcle_proc(null)
   DECLARE drdm_exception_time = f8
   DECLARE drdm_wait_time = f8
   DECLARE drdm_rhr_return_value = i4
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="RDDS DCL PROCESSING"
     AND d.info_name="EXCEPTION WAIT TIME"
    DETAIL
     drdm_wait_time = d.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_main
   ENDIF
   IF (curqual=0)
    SET drdm_wait_time = 5
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="RDDS DCL PROCESSING"
     AND d.info_name="EXCEPTION LOG TIME"
    DETAIL
     drdm_exception_time = d.info_date
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_main
   ENDIF
   IF (curqual > 0
    AND drdm_exception_time <= cnvtlookbehind(concat(cnvtstring(drdm_wait_time),"H"),sysdate))
    ROLLBACK
    UPDATE  FROM dm_info d
     SET d.info_date = sysdate
     WHERE d.info_domain="RDDS DCL PROCESSING"
      AND d.info_name="EXCEPTION LOG TIME"
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_main
    ENDIF
    COMMIT
    SET uo_tbl_name = dm2_get_rdds_tname("USER_OBJECTS")
    SET ui_tbl_name = dm2_get_rdds_tname("USER_INDEXES")
    SELECT INTO "nl:"
     FROM (parser(uo_tbl_name) uo),
      (parser(ui_tbl_name) ui)
     WHERE uo.object_name="DM_REFCHG_COALESCE"
      AND ui.index_name="XIE4DM_CHG_LOG"
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_main
    ENDIF
    IF (curqual > 0)
     CALL parser(concat("RDB ASIS(^ BEGIN dm_refchg_coalesce",dm2_ref_data_doc->post_link_name,
       "('XIE4DM_CHG_LOG'); END; ^) GO"))
    ENDIF
    EXECUTE dm2_rdds_find_orphans
    EXECUTE dm2_rdds_find_nologs
    SET drdm_rhr_return_value = reset_holdng_rows(null)
    SET dm_get_request->run_cnt = 1
    SET stat = alterlist(dm_get_request->run_qual,dm_get_request->run_cnt)
    SET dm_get_request->run_qual[1].run_time_flag = 2
    EXECUTE dm_rmc_get_ins_set
    IF ((dm_get_reply->status="F"))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     GO TO exit_main
    ENDIF
   ELSEIF (curqual=0)
    ROLLBACK
    INSERT  FROM dm_info d
     SET d.info_date = sysdate, d.info_domain = "RDDS DCL PROCESSING", d.info_name =
      "EXCEPTION LOG TIME"
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_main
    ENDIF
    COMMIT
    EXECUTE dm2_rdds_find_orphans
    EXECUTE dm2_rdds_find_nologs
    SET drdm_rhr_return_value = reset_holdng_rows(null)
    SET dm_get_request->run_cnt = 1
    SET stat = alterlist(dm_get_request->run_qual,dm_get_request->run_cnt)
    SET dm_get_request->run_qual[1].run_time_flag = 2
    EXECUTE dm_rmc_get_ins_set
    IF ((dm_get_reply->status="F"))
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 1
     GO TO exit_main
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE drdm_get_merge_del_rows(sbr_t_name,sbr_pk_where,sbr_tbl_cnt,sbr_sp_value,sbr_orig_explode,
  gmdr_ps_data)
   DECLARE gmdr_col_loop = i4
   DECLARE gmdr_table_suffix = vc
   DECLARE gmdr_s_tab_name = vc
   DECLARE gmdr_qual_cnt = i4
   DECLARE gmdr_pk_where_stmt = vc
   DECLARE gmdr_rtm_rs_size = i4
   DECLARE gmdr_temp_cnt = i4
   DECLARE gmdr_top_level = i4
   DECLARE gmdr_xlat_return = vc
   DECLARE gmdr_pk_value = f8
   DECLARE gmdr_new_seq = f8
   DECLARE gmdr_found_ind = i2 WITH protect, noconstant(0)
   DECLARE gmdr_prescan_idx = i4 WITH protect, noconstant(0)
   DECLARE gmdr_par_pos = i4 WITH protect, noconstant(0)
   SET gmdr_table_suffix = dm2_rdds_get_tbl_alias(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].suffix)
   SET gmdr_s_tab_name = dm2_get_rdds_tname(sbr_t_name)
   SET gmdr_top_level = 0
   FREE RECORD cust_cs_rows
   CALL parser("record cust_cs_rows (",0)
   CALL parser(" 1 trailing_space_ind = i2")
   CALL parser(" 1 qual[*]",0)
   FOR (gmdr_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt)
     IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gmdr_col_loop].pk_ind=1))
      IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gmdr_col_loop].root_entity_name=
      dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].table_name)
       AND (dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gmdr_col_loop].root_entity_attr=
      dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gmdr_col_loop].column_name))
       SET gmdr_top_level = gmdr_col_loop
      ENDIF
      CALL parser(concat(" 2 ",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gmdr_col_loop].
        column_name," = ",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gmdr_col_loop].data_type),
       0)
      CALL parser(concat(" 2 ",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gmdr_col_loop].
        column_name,"_NULLIND = i2 "),0)
      IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gmdr_col_loop].data_type IN ("VC", "C*"))
      )
       CALL parser(concat(" 2 ",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gmdr_col_loop].
         column_name,"_LEN = i4 "),0)
      ENDIF
     ENDIF
   ENDFOR
   CALL parser(") go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   SET gmdr_temp_cnt = 0
   CALL parser("select into 'nl:'",0)
   FOR (gmdr_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt)
     IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gmdr_col_loop].pk_ind=1))
      IF (gmdr_temp_cnt > 0)
       CALL parser(" , ",0)
      ENDIF
      SET gmdr_temp_cnt = (gmdr_temp_cnt+ 1)
      CALL parser(concat("var",cnvtstring(gmdr_col_loop)," = nullind(",gmdr_table_suffix,".",
        dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gmdr_col_loop].column_name,")"),0)
      IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gmdr_col_loop].data_type IN ("VC", "C*"))
      )
       CALL parser(concat(", ts",cnvtstring(gmdr_col_loop)," = length(",gmdr_table_suffix,".",
         dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gmdr_col_loop].column_name,")"),0)
      ENDIF
     ENDIF
   ENDFOR
   CALL parser(concat(" from  ",gmdr_s_tab_name," ",gmdr_table_suffix),0)
   CALL parser(sbr_pk_where,0)
   IF (gmdr_top_level != 0)
    CALL parser(concat(" and ",gmdr_table_suffix,".",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].
      col_qual[gmdr_top_level].column_name," != 0 "),0)
   ENDIF
   FOR (gmdr_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt)
     IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gmdr_col_loop].exception_flg=13))
      CALL parser(concat(" order by ",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gmdr_col_loop]
        .column_name),0)
     ENDIF
   ENDFOR
   IF (sbr_sp_value > 0.0)
    SET gmdr_qual_cnt = (gmdr_qual_cnt+ 1)
    SET stat = alterlist(cust_cs_rows->qual,gmdr_qual_cnt)
    SET gmdr_found_ind = 0
   ENDIF
   IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].filter_string != ""))
    SET dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].filter_string = replace(dm2_ref_data_doc->tbl_qual[
     sbr_tbl_cnt].filter_string,"<MERGE LINK>",dm2_ref_data_doc->post_link_name,0)
    CALL parser(concat(" and ",replace(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].filter_string,
       "<SUFFIX>",gmdr_table_suffix,0)),0)
   ENDIF
   CALL parser("head report cust_cs_rows->trailing_space_ind = 1",0)
   CALL parser(" detail ",0)
   IF (sbr_sp_value > 0.0)
    CALL parser(concat("  if(gmdr_found_ind = 0 and ",gmdr_table_suffix,".",dm2_ref_data_doc->
      tbl_qual[sbr_tbl_cnt].col_qual[gmdr_top_level].column_name," = sbr_sp_value)"),0)
    CALL parser("   gmdr_found_ind = 1",0)
    FOR (gmdr_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gmdr_col_loop].pk_ind=1))
       CALL parser(concat("cust_cs_rows->qual[1].",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[
         gmdr_col_loop].column_name," = ",gmdr_table_suffix,".",
         dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gmdr_col_loop].column_name),0)
       CALL parser(concat("cust_cs_rows->qual[1].",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[
         gmdr_col_loop].column_name,"_NULLIND = var",trim(cnvtstring(gmdr_col_loop))),0)
       IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gmdr_col_loop].data_type IN ("VC", "C*")
       ))
        CALL parser(concat("cust_cs_rows->qual[1].",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[
          gmdr_col_loop].column_name,"_LEN = ts",trim(cnvtstring(gmdr_col_loop))),0)
       ENDIF
      ENDIF
    ENDFOR
    CALL parser("  else ",0)
   ENDIF
   CALL parser(
    " gmdr_qual_cnt = gmdr_qual_cnt + 1 stat = alterlist(cust_cs_rows->qual, gmdr_qual_cnt) ",0)
   FOR (gmdr_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt)
     IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gmdr_col_loop].pk_ind=1))
      CALL parser(concat("cust_cs_rows->qual[gmdr_qual_cnt].",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt]
        .col_qual[gmdr_col_loop].column_name," = ",gmdr_table_suffix,".",
        dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gmdr_col_loop].column_name),0)
      CALL parser(concat("cust_cs_rows->qual[gmdr_qual_cnt].",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt]
        .col_qual[gmdr_col_loop].column_name,"_NULLIND = var",trim(cnvtstring(gmdr_col_loop))),0)
      IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gmdr_col_loop].data_type IN ("VC", "C*"))
      )
       CALL parser(concat("cust_cs_rows->qual[gmdr_qual_cnt].",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt
         ].col_qual[gmdr_col_loop].column_name,"_LEN = ts",trim(cnvtstring(gmdr_col_loop))),0)
      ENDIF
     ENDIF
   ENDFOR
   IF (sbr_sp_value > 0.0)
    CALL parser("  endif",0)
   ENDIF
   CALL parser(" with nocounter, notrim go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   IF (curqual=0)
    RETURN(- (2))
   ENDIF
   IF ((gmdr_qual_cnt >= global_mover_rec->md_row_limit))
    SET gdmr_parent_pos = find_original_log_row(drdm_chg,drdm_log_loop)
    SET drdm_chg->log[gdmr_parent_pos].chg_log_reason_txt = concat(
     "Too large of a merge delete data set found in source. ",trim(cnvtstring(gmdr_qual_cnt)),
     " rows were qualified on.")
    ROLLBACK
    IF (textlen(trim(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].root_col_name,3)) > 0)
     CALL log_md_scommit(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].table_name,sbr_tbl_cnt,"NOMV1C",
      drdm_log_loop)
    ENDIF
    RETURN(- (3))
   ENDIF
   IF (sbr_sp_value > 0.0
    AND gmdr_found_ind=0)
    FOR (gmdr_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gmdr_col_loop].pk_ind=1))
       CALL parser(concat("set cust_cs_rows->qual[1].",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].
         col_qual[gmdr_col_loop].column_name," = ","cust_cs_rows->qual[gmdr_qual_cnt].",
         dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gmdr_col_loop].column_name,
         " go"),1)
       CALL parser(concat("set cust_cs_rows->qual[1].",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].
         col_qual[gmdr_col_loop].column_name,"_NULLIND = cust_cs_rows->qual[gmdr_qual_cnt].",
         dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gmdr_col_loop].column_name,"_NULLIND go"),1
        )
       IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gmdr_col_loop].data_type IN ("VC", "C*")
       ))
        CALL parser(concat("set cust_cs_rows->qual[1].",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].
          col_qual[gmdr_col_loop].column_name,"_LEN = cust_cs_rows->qual[gmdr_qual_cnt].",
          dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gmdr_col_loop].column_name,"_LEN go"),1)
       ENDIF
      ENDIF
    ENDFOR
    SET gmdr_qual_cnt = (gmdr_qual_cnt - 1)
    SET stat = alterlist(cust_cs_rows->qual,gmdr_qual_cnt)
   ENDIF
   FOR (gmdr_col_loop = 1 TO gmdr_qual_cnt)
    SET gmdr_pk_where_stmt = drdm_create_pk_where(gmdr_col_loop,sbr_tbl_cnt,"PK")
    IF (gmdr_pk_where_stmt != "")
     IF (drdm_next_row_pos > drdm_max_rs_size)
      SET drdm_max_rs_size = (drdm_max_rs_size+ 10)
      SET stat = alterlist(drdm_chg->log,drdm_max_rs_size)
     ENDIF
     CALL reinitialize_drdm(drdm_next_row_pos)
     IF (gmdr_col_loop=1)
      SET drdm_chg->log[drdm_next_row_pos].md_delete_ind = 1
      SET gmdr_rtm_rs_size = drdm_next_row_pos
     ELSE
      SET drdm_chg->log[drdm_next_row_pos].md_delete_ind = 0
     ENDIF
     IF (gmdr_col_loop < gmdr_qual_cnt)
      SET drdm_chg->log[drdm_next_row_pos].next_to_process = (drdm_next_row_pos+ 1)
     ELSE
      SET drdm_chg->log[drdm_next_row_pos].next_to_process = drdm_log_loop
     ENDIF
     SET drdm_chg->log[drdm_next_row_pos].table_name = sbr_t_name
     SET drdm_chg->log[drdm_next_row_pos].pk_where = gmdr_pk_where_stmt
     SET drdm_chg->log[drdm_next_row_pos].delete_ind = drdm_chg->log[drdm_log_loop].delete_ind
     SET drdm_chg->log[drdm_next_row_pos].md_context_name = drdm_chg->log[drdm_log_loop].
     md_context_name
     SET drdm_chg->log[drdm_next_row_pos].src_cntxt_name = drdm_chg->log[drdm_log_loop].
     src_cntxt_name
     SET drdm_chg->log[drdm_next_row_pos].context_name = drmm_get_context_name(drdm_chg->log[
      drdm_next_row_pos].src_cntxt_name)
     SET drdm_chg->log[drdm_next_row_pos].commit_ind = 0
     IF (gmdr_top_level > 0)
      SET drdm_chg->log[drdm_next_row_pos].reprocess_ind = 1
     ENDIF
     SET gmdr_prescan_idx = locateval(gmdr_prescan_idx,1,gmdr_ps_data->cnt,drdm_chg->log[
      drdm_log_loop].log_id,gmdr_ps_data->qual[gmdr_prescan_idx].log_id)
     IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].pre_scan_ind=1)
      AND sbr_orig_explode != 7
      AND gmdr_prescan_idx=0)
      SET drdm_chg->log[drdm_next_row_pos].process_flg = 8
     ELSE
      IF ((drdm_chg->log[drdm_log_loop].process_flg=6))
       SET drdm_chg->log[drdm_next_row_pos].process_flg = 6
      ELSE
       SET drdm_chg->log[drdm_next_row_pos].process_flg = 2
      ENDIF
     ENDIF
     SET drdm_chg->log[drdm_next_row_pos].validate_ind = 0
     SET drdm_chg->log[drdm_next_row_pos].log_id = drdm_chg->log[drdm_log_loop].log_id
     SET drdm_chg->log[drdm_next_row_pos].updt_cnt = drdm_chg->log[drdm_log_loop].updt_cnt
     SET drdm_chg->log[drdm_next_row_pos].updt_applctx = drdm_chg->log[drdm_log_loop].updt_applctx
     SET drdm_chg->log[drdm_next_row_pos].pk_where_hash = drdm_chg->log[drdm_log_loop].pk_where_hash
     SET drdm_chg->log[drdm_next_row_pos].ptam_match_hash = drdm_chg->log[drdm_log_loop].
     ptam_match_hash
     SET drdm_chg->log[drdm_next_row_pos].ptam_match_result = drdm_chg->log[drdm_log_loop].
     ptam_match_result
     SET drdm_chg->log[drdm_next_row_pos].ptam_match_result_str = drdm_chg->log[drdm_log_loop].
     ptam_match_result_str
     SET drdm_chg->log[drdm_next_row_pos].ptam_str_tspace_cnt = drdm_chg->log[drdm_log_loop].
     ptam_str_tspace_cnt
     SET drdm_next_row_pos = (drdm_next_row_pos+ 1)
    ELSE
     RETURN(- (1))
    ENDIF
   ENDFOR
   RETURN(gmdr_rtm_rs_size)
 END ;Subroutine
 SUBROUTINE find_next_commit(fnc_log_loop)
   DECLARE fnc_done_ind = i2
   DECLARE fnc_return_pos = i4
   DECLARE fnc_ndx_pos = i4
   DECLARE fnc_loop = i4
   SET fnc_done_ind = 0
   SET fnc_return_pos = 0
   WHILE (fnc_done_ind=0)
     IF ((((drdm_chg->log[fnc_log_loop].commit_ind=1)) OR ((drdm_chg->log[fnc_log_loop].
     next_to_process=0))) )
      IF ((drdm_chg->log[fnc_log_loop].next_to_process != 0))
       SET fnc_ndx_pos = locateval(fnc_loop,1,size(dm2_ref_data_doc->tbl_qual,5),drdm_chg->log[
        fnc_log_loop].table_name,dm2_ref_data_doc->tbl_qual[fnc_loop].table_name)
       IF ((dm2_ref_data_doc->tbl_qual[fnc_ndx_pos].child_flag=0))
        SET dm2_ref_data_doc->tbl_qual[fnc_ndx_pos].child_flag = 1
       ENDIF
       IF ((dm2_ref_data_doc->tbl_qual[fnc_ndx_pos].child_flag=1))
        IF ((drdm_chg->log[fnc_log_loop].process_flg=6))
         SET fnc_log_loop = drdm_chg->log[fnc_log_loop].next_to_process
        ELSE
         SET fnc_return_pos = fnc_log_loop
         SET fnc_done_ind = 1
        ENDIF
       ENDIF
      ELSE
       SET fnc_return_pos = fnc_log_loop
       SET fnc_done_ind = 1
      ENDIF
     ELSE
      SET fnc_log_loop = drdm_chg->log[fnc_log_loop].next_to_process
     ENDIF
   ENDWHILE
   RETURN(fnc_return_pos)
 END ;Subroutine
 SUBROUTINE drdm_get_child_rows(sbr_t_name,sbr_pk_where,sbr_tbl_cnt,sbr_next_row)
   DECLARE gcr_col_loop = i4
   DECLARE gcr_table_suffix = vc
   DECLARE gcr_s_tab_name = vc
   DECLARE gcr_qual_cnt = i4
   DECLARE gcr_pk_where_stmt = vc
   DECLARE gcr_rtm_rs_size = i4
   DECLARE gcr_loop = i4
   DECLARE gcr_child_cnt = i4
   DECLARE gcr_child_loop = i4
   DECLARE gcr_child_tbl_cnt = i4
   DECLARE gcr_user_tab = vc
   DECLARE gcr_p_table_suffix = vc
   DECLARE gcr_p_tab_source = vc
   DECLARE gcr_col_pass_cnt = i4
   DECLARE gcr_row_qual_ind = i2
   SET gcr_rtm_rs_size = drdm_log_loop
   SET gcr_user_tab = dm2_get_rdds_tname("USER_TABLES")
   SET gcr_p_tab_source = dm2_get_rdds_tname(sbr_t_name)
   SET gcr_p_table_suffix = dm2_rdds_get_tbl_alias(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].suffix)
   IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].parent_flag=0))
    SET dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].parent_flag = 1
   ENDIF
   RETURN(gcr_rtm_rs_size)
 END ;Subroutine
 SUBROUTINE add_missing_xlats(amx_log_loop,amx_rs_size)
   DECLARE amx_loop = i4
   DECLARE amx_ndx_search = i4
   DECLARE amx_tab_size = i4
   DECLARE amx_tab_pos = i4
   DECLARE amx_return_pos = i4
   DECLARE amx_return_ind = i2
   DECLARE amx_pk_where_stmt = vc
   DECLARE amx_suffix = vc
   DECLARE amx_first_added_ind = i2
   DECLARE amx_s_tab_name = vc
   DECLARE amx_temp_cnt = i4
   DECLARE amx_qual_cnt = i4
   DECLARE amx_badrow_ind = i4
   DECLARE amx_action_ind = i2
   DECLARE amx_dcp_val = f8
   DECLARE amx_next_tab_name = vc
   DECLARE amx_next_tab_pos = i4
   DECLARE amx_temp_pos = i4
   DECLARE amx_last_unprocessed_idx = i4
   DECLARE amx_spc_return = i4
   DECLARE amx_parent_drdm_row = i2 WITH protect, noconstant(0)
   DECLARE amx_parent_tab_pos = i2 WITH protect, noconstant(0)
   DECLARE amx_s_tab_name = vc WITH protect, noconstant("")
   DECLARE amx_select_str = vc WITH protect, noconstant("")
   DECLARE amx_pk_str = vc WITH protect, noconstant("")
   DECLARE amx_ui_list = vc WITH protect, noconstant("")
   DECLARE amx_pk_acteff_ind = i2 WITH protect, noconstant(0)
   DECLARE amx_null_str = vc WITH protect, noconstant("")
   DECLARE amx_tier_idx = i4 WITH protect, noconstant(0)
   DECLARE amx_tier_loc = i4 WITH protect, noconstant(0)
   DECLARE amx_mx_cnt = i4 WITH protect, noconstant(0)
   DECLARE amx_last_pos = i4 WITH protect, noconstant(0)
   DECLARE amx_max_tier = i4 WITH protect, noconstant(0)
   DECLARE amx_miss_chld_val = f8 WITH protect, noconstant(0.0)
   SET amx_return_pos = amx_log_loop
   IF ((global_mover_rec->one_pass_ind=1))
    SET amx_return_ind = 0
    SET amx_action_ind = 0
    FOR (amx_loop = 1 TO amx_rs_size)
      IF ((missing_xlats->qual[amx_loop].processed_ind=0))
       SET amx_last_unprocessed_idx = amx_loop
       SET amx_tab_size = size(dm2_ref_data_doc->tbl_qual,5)
       SET amx_tab_pos = locateval(amx_ndx_search,1,amx_tab_size,missing_xlats->qual[amx_loop].
        table_name,dm2_ref_data_doc->tbl_qual[amx_ndx_search].table_name)
       SET amx_s_tab_name = dm2_get_rdds_tname(dm2_ref_data_doc->tbl_qual[amx_tab_pos].table_name)
       IF ((dm2_ref_data_doc->tbl_qual[amx_tab_pos].filter_string > " "))
        CALL parser(concat("select into 'nl:' from ",amx_s_tab_name," a where "),0)
        CALL parser(concat(" a.",missing_xlats->qual[amx_loop].column_name,
          " = missing_xlats->qual[amx_loop].missing_value "),0)
        CALL parser(concat(" and ",replace(replace(dm2_ref_data_doc->tbl_qual[amx_tab_pos].
            filter_string,"<SUFFIX>","a",0),"<MERGE LINK>",dm2_ref_data_doc->post_link_name,0)),0)
        CALL parser(" with nocounter go",1)
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(amx_return_pos)
        ENDIF
        IF (curqual=0)
         SET missing_xlats->qual[amx_loop].processed_ind = 1
         ROLLBACK
         SET drwdr_reply->dcle_id = 0
         SET drwdr_reply->error_ind = 0
         SET drwdr_request->table_name = missing_xlats->qual[amx_loop].table_name
         SET drwdr_request->log_type = "NOMV11"
         SET drwdr_request->col_name = missing_xlats->qual[amx_loop].column_name
         SET drwdr_request->from_value = missing_xlats->qual[amx_loop].missing_value
         SET drwdr_request->source_env_id = dm2_ref_data_doc->env_source_id
         SET drwdr_request->target_env_id = dm2_ref_data_doc->env_target_id
         SET drwdr_request->dclei_ind = drmm_excep_flag
         EXECUTE dm_rmc_write_dcle_rows  WITH replace("REQUEST","DRWDR_REQUEST"), replace("REPLY",
          "DRWDR_REPLY")
         IF ((drwdr_reply->error_ind=1))
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          RETURN(amx_return_pos)
         ENDIF
         SET drwdr_reply->dcle_id = 0
         SET drwdr_reply->error_ind = 0
         SET amx_parent_drdm_row = find_original_log_row(drdm_chg,amx_log_loop)
         SET amx_parent_tab_pos = locateval(amx_ndx_search,1,amx_tab_size,drdm_chg->log[
          amx_parent_drdm_row].table_name,dm2_ref_data_doc->tbl_qual[amx_ndx_search].table_name)
         IF ((dm2_ref_data_doc->tbl_qual[amx_parent_tab_pos].root_col_name > " "))
          SET drwdr_request->table_name = drdm_chg->log[amx_parent_drdm_row].table_name
          SET drwdr_request->log_type = "CHLD11"
          SET drwdr_request->col_name = dm2_ref_data_doc->tbl_qual[amx_parent_tab_pos].root_col_name
          CALL parser(concat("set amx_miss_chld_val = RS_",dm2_ref_data_doc->tbl_qual[
            amx_parent_tab_pos].suffix,"->from_Values.",dm2_ref_data_doc->tbl_qual[amx_parent_tab_pos
            ].root_col_name," go"),1)
          SET drwdr_request->from_value = amx_miss_chld_val
          SET drwdr_request->source_env_id = dm2_ref_data_doc->env_source_id
          SET drwdr_request->target_env_id = dm2_ref_data_doc->env_target_id
          SET drwdr_request->dclei_ind = drmm_excep_flag
          EXECUTE dm_rmc_write_dcle_rows  WITH replace("REQUEST","DRWDR_REQUEST"), replace("REPLY",
           "DRWDR_REPLY")
          IF ((drwdr_reply->error_ind=1))
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           RETURN(amx_return_pos)
          ENDIF
          IF ((drwdr_reply->dcle_id > 0))
           IF ((drdm_chg->log[amx_parent_drdm_row].dm_chg_log_exception_id=0))
            SET drdm_chg->log[amx_parent_drdm_row].dm_chg_log_exception_id = drwdr_reply->dcle_id
           ENDIF
          ENDIF
         ENDIF
         COMMIT
         IF (((drdm_next_row_pos+ 1) > drdm_max_rs_size))
          SET drdm_max_rs_size = (drdm_max_rs_size+ 10)
          SET stat = alterlist(drdm_chg->log,drdm_max_rs_size)
         ENDIF
         CALL reinitialize_drdm(drdm_next_row_pos)
         SET amx_return_pos = drdm_next_row_pos
         SET drdm_chg->log[amx_return_pos].next_to_process = amx_log_loop
         SET stat = alterlist(missing_xlats->qual,0)
         RETURN(amx_return_pos)
        ENDIF
       ENDIF
       IF ((((dm2_ref_data_doc->tbl_qual[amx_tab_pos].table_name IN ("DCP_FORMS_REF",
       "DCP_SECTION_REF"))) OR ((dm2_ref_data_doc->tbl_qual[amx_tab_pos].version_ind=1)
        AND (dm2_ref_data_doc->tbl_qual[amx_tab_pos].version_type IN ("ALG1", "ALG3", "ALG3D", "ALG4",
       "ALG5",
       "ALG6", "ALG7")))) )
        SET amx_qual_cnt = drmm_check_vers_pk(missing_xlats->qual[amx_loop].table_name,missing_xlats
         ->qual[amx_loop].column_name,missing_xlats->qual[amx_loop].missing_value,dm2_ref_data_doc)
        IF (amx_qual_cnt=0)
         SET missing_xlats->qual[amx_loop].processed_ind = 1
         ROLLBACK
         SET drwdr_reply->dcle_id = 0
         SET drwdr_reply->error_ind = 0
         SET drwdr_request->table_name = missing_xlats->qual[amx_loop].table_name
         SET drwdr_request->log_type = "OLDVER"
         SET drwdr_request->col_name = missing_xlats->qual[amx_loop].column_name
         SET drwdr_request->from_value = missing_xlats->qual[amx_loop].missing_value
         SET drwdr_request->source_env_id = dm2_ref_data_doc->env_source_id
         SET drwdr_request->target_env_id = dm2_ref_data_doc->env_target_id
         SET drwdr_request->dclei_ind = drmm_excep_flag
         EXECUTE dm_rmc_write_dcle_rows  WITH replace("REQUEST","DRWDR_REQUEST"), replace("REPLY",
          "DRWDR_REPLY")
         IF ((drwdr_reply->error_ind=1))
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          RETURN(amx_return_pos)
         ENDIF
         SET drwdr_reply->dcle_id = 0
         SET drwdr_reply->error_ind = 0
         SET amx_parent_drdm_row = find_original_log_row(drdm_chg,amx_log_loop)
         SET amx_parent_tab_pos = locateval(amx_ndx_search,1,amx_tab_size,drdm_chg->log[
          amx_parent_drdm_row].table_name,dm2_ref_data_doc->tbl_qual[amx_ndx_search].table_name)
         FOR (i = 1 TO dm2_ref_data_doc->tbl_qual[amx_parent_tab_pos].col_cnt)
           IF ((dm2_ref_data_doc->tbl_qual[amx_parent_tab_pos].col_qual[i].pk_ind=1))
            IF ((dm2_ref_data_doc->tbl_qual[amx_parent_tab_pos].col_qual[i].root_entity_name=
            dm2_ref_data_doc->tbl_qual[amx_parent_tab_pos].table_name)
             AND (dm2_ref_data_doc->tbl_qual[amx_parent_tab_pos].col_qual[i].root_entity_attr=
            dm2_ref_data_doc->tbl_qual[amx_parent_tab_pos].col_qual[i].column_name))
             SET drwdr_request->table_name = drdm_chg->log[amx_parent_drdm_row].table_name
             SET drwdr_request->log_type = "CHLDOV"
             SET drwdr_request->col_name = dm2_ref_data_doc->tbl_qual[amx_parent_tab_pos].col_qual[i]
             .column_name
             CALL parser(concat("set amx_miss_chld_val = RS_",dm2_ref_data_doc->tbl_qual[
               amx_parent_tab_pos].suffix,"->from_Values.",dm2_ref_data_doc->tbl_qual[
               amx_parent_tab_pos].col_qual[i].column_name," go"),1)
             SET drwdr_request->from_value = amx_miss_chld_val
             SET drwdr_request->source_env_id = dm2_ref_data_doc->env_source_id
             SET drwdr_request->target_env_id = dm2_ref_data_doc->env_target_id
             SET drwdr_request->dclei_ind = drmm_excep_flag
             EXECUTE dm_rmc_write_dcle_rows  WITH replace("REQUEST","DRWDR_REQUEST"), replace("REPLY",
              "DRWDR_REPLY")
             IF ((drwdr_reply->error_ind=1))
              CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
              RETURN(amx_return_pos)
             ENDIF
             IF ((drwdr_reply->dcle_id > 0))
              IF ((drdm_chg->log[amx_parent_drdm_row].dm_chg_log_exception_id=0))
               SET drdm_chg->log[amx_parent_drdm_row].dm_chg_log_exception_id = drwdr_reply->dcle_id
              ENDIF
             ENDIF
            ENDIF
           ENDIF
         ENDFOR
         COMMIT
         IF (((drdm_next_row_pos+ 1) > drdm_max_rs_size))
          SET drdm_max_rs_size = (drdm_max_rs_size+ 10)
          SET stat = alterlist(drdm_chg->log,drdm_max_rs_size)
         ENDIF
         CALL reinitialize_drdm(drdm_next_row_pos)
         SET amx_return_pos = drdm_next_row_pos
         SET drdm_chg->log[amx_return_pos].next_to_process = amx_log_loop
         SET stat = alterlist(missing_xlats->qual,0)
         RETURN(amx_return_pos)
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
    FOR (amx_mx_cnt = 1 TO size(missing_xlats->qual,5))
      SET amx_tier_loc = locateval(amx_tier_idx,1,global_mover_rec->tier_cnt,missing_xlats->qual[
       amx_mx_cnt].table_name,global_mover_rec->tier_qual[amx_tier_idx].table_name)
      IF (amx_tier_loc=0)
       SET missing_xlats->qual[amx_mx_cnt].tier_value = 100
      ELSE
       SET missing_xlats->qual[amx_mx_cnt].tier_value = global_mover_rec->tier_qual[amx_tier_loc].
       tier_value
      ENDIF
      IF ((missing_xlats->qual[amx_mx_cnt].processed_ind=0)
       AND (missing_xlats->qual[amx_mx_cnt].tier_value >= amx_max_tier))
       SET amx_last_pos = amx_mx_cnt
       SET amx_max_tier = missing_xlats->qual[amx_mx_cnt].tier_value
      ENDIF
    ENDFOR
    IF ((dm_err->debug_flag > 0))
     CALL echorecord(missing_xlats)
    ENDIF
    FOR (amx_mx_cnt = 1 TO 100)
      FOR (amx_loop = 1 TO amx_rs_size)
        IF ((missing_xlats->qual[amx_loop].tier_value=amx_mx_cnt))
         IF ((missing_xlats->qual[amx_loop].processed_ind=0))
          SET amx_action_ind = 1
          SET amx_tab_size = size(dm2_ref_data_doc->tbl_qual,5)
          SET amx_tab_pos = locateval(amx_ndx_search,1,amx_tab_size,missing_xlats->qual[amx_loop].
           table_name,dm2_ref_data_doc->tbl_qual[amx_ndx_search].table_name)
          SET amx_suffix = dm2_rdds_get_tbl_alias(dm2_ref_data_doc->tbl_qual[amx_tab_pos].suffix)
          IF (amx_badrow_ind != 1)
           ROLLBACK
           SET amx_pk_str = concat(missing_xlats->qual[amx_loop].column_name," = ",trim(cnvtstring(
              missing_xlats->qual[amx_loop].missing_value,20,0)),".0")
           SET amx_new_log_id = add_single_pass_dcl_row(missing_xlats->qual[amx_loop].table_name,
            amx_pk_str,drdm_chg->log[amx_log_loop].log_id,drdm_chg->log[amx_log_loop].src_cntxt_name)
           IF (amx_new_log_id < 0)
            SET amx_badrow_ind = 1
            ROLLBACK
            IF ((amx_new_log_id=- (2)))
             SET drmm_ddl_rollback_ind = 1
             RETURN(amx_log_loop)
            ELSE
             SET drwdr_reply->dcle_id = 0
             SET drwdr_reply->error_ind = 0
             SET drwdr_request->table_name = missing_xlats->qual[amx_loop].table_name
             IF ((amx_new_log_id=- (1)))
              SET drwdr_request->log_type = "NOMV49"
             ELSEIF ((amx_new_log_id=- (4)))
              SET drwdr_request->log_type = "NOMV11"
             ELSEIF ((amx_new_log_id=- (5)))
              SET drwdr_request->log_type = "NOMV62"
             ENDIF
             SET drwdr_request->col_name = missing_xlats->qual[amx_loop].column_name
             SET drwdr_request->from_value = missing_xlats->qual[amx_loop].missing_value
             SET drwdr_request->source_env_id = dm2_ref_data_doc->env_source_id
             SET drwdr_request->target_env_id = dm2_ref_data_doc->env_target_id
             SET drwdr_request->dclei_ind = drmm_excep_flag
             EXECUTE dm_rmc_write_dcle_rows  WITH replace("REQUEST","DRWDR_REQUEST"), replace("REPLY",
              "DRWDR_REPLY")
             IF ((drwdr_reply->error_ind=1))
              CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
              RETURN(amx_return_pos)
             ENDIF
             IF ((drwdr_reply->dcle_id > 0))
              SET amx_parent_drdm_row = find_original_log_row(drdm_chg,amx_log_loop)
              IF ((drdm_chg->log[amx_parent_drdm_row].dm_chg_log_exception_id=0))
               SET drdm_chg->log[amx_parent_drdm_row].dm_chg_log_exception_id = drwdr_reply->dcle_id
              ENDIF
             ENDIF
             COMMIT
             SET stat = alterlist(missing_xlats->qual,0)
            ENDIF
            SET amx_loop = amx_rs_size
            SET amx_mx_cnt = 100
           ELSE
            IF (((drdm_next_row_pos+ 1) > drdm_max_rs_size))
             SET drdm_max_rs_size = (drdm_max_rs_size+ 10)
             SET stat = alterlist(drdm_chg->log,drdm_max_rs_size)
            ENDIF
            CALL reinitialize_drdm(drdm_next_row_pos)
            IF (amx_first_added_ind=0)
             SET amx_return_pos = drdm_next_row_pos
             SET drdm_chg->log[drdm_next_row_pos].next_to_process = (drdm_next_row_pos+ 1)
             SET drdm_next_row_pos = (drdm_next_row_pos+ 1)
             CALL reinitialize_drdm(drdm_next_row_pos)
            ENDIF
            IF (amx_loop=amx_last_pos)
             SET drdm_chg->log[drdm_next_row_pos].next_to_process = find_original_log_row(drdm_chg,
              amx_log_loop)
             IF ((drdm_chg->log[drdm_chg->log[drdm_next_row_pos].next_to_process].delete_ind=0))
              SET drdm_chg->log[drdm_chg->log[drdm_next_row_pos].next_to_process].validate_ind = 1
             ENDIF
            ELSE
             SET drdm_chg->log[drdm_next_row_pos].next_to_process = (drdm_next_row_pos+ 1)
            ENDIF
            SET drdm_chg->log[drdm_next_row_pos].table_name = missing_xlats->qual[amx_loop].
            table_name
            SET drdm_chg->log[drdm_next_row_pos].validate_ind = 1
            SET amx_dcl_src = dm2_get_rdds_tname("DM_CHG_LOG")
            SELECT INTO "nl:"
             l1 = length(d.ptam_match_result_str)
             FROM (parser(amx_dcl_src) d)
             WHERE d.log_id=amx_new_log_id
             DETAIL
              drdm_chg->log[drdm_next_row_pos].pk_where_hash = d.pk_where_hash, drdm_chg->log[
              drdm_next_row_pos].ptam_match_hash = d.ptam_match_hash, drdm_chg->log[drdm_next_row_pos
              ].ptam_match_result = d.ptam_match_result,
              drdm_chg->log[drdm_next_row_pos].ptam_match_result_str = d.ptam_match_result_str,
              drdm_chg->log[drdm_next_row_pos].ptam_str_tspace_cnt = (l1 - size(drdm_chg->log[
               drdm_next_row_pos].ptam_match_result_str)), drdm_chg->log[drdm_next_row_pos].updt_cnt
               = d.updt_cnt,
              drdm_chg->log[drdm_next_row_pos].pk_where = replace(d.pk_where,"<MERGE_LINK>",
               dm2_ref_data_doc->post_link_name,0)
             WITH nocounter
            ;end select
            IF (check_error(dm_err->eproc)=1)
             CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
             SET amx_bad_row_ind = 1
            ENDIF
            SET drdm_chg->log[drdm_next_row_pos].log_id = amx_new_log_id
            SET drdm_chg->log[drdm_next_row_pos].single_pass_log_id = drdm_chg->log[amx_log_loop].
            log_id
            SET drdm_chg->log[drdm_next_row_pos].single_pass_value = missing_xlats->qual[amx_loop].
            missing_value
            SET drdm_chg->log[drdm_next_row_pos].md_context_name = drdm_chg->log[amx_log_loop].
            md_context_name
            SET drdm_chg->log[drdm_next_row_pos].src_cntxt_name = drdm_chg->log[amx_log_loop].
            src_cntxt_name
            SET drdm_chg->log[drdm_next_row_pos].context_name = drmm_get_context_name(drdm_chg->log[
             drdm_next_row_pos].src_cntxt_name)
            SET drdm_chg->log[drdm_next_row_pos].commit_ind = 1
            SET drdm_chg->log[drdm_next_row_pos].delete_ind = 0
            SET drdm_chg->log[drdm_next_row_pos].process_flg = 1
            SET drdm_chg->log[drdm_next_row_pos].par_location = 0
            SET drdm_chg->log[drdm_next_row_pos].md_delete_ind = 0
            SET drdm_chg->log[drdm_next_row_pos].status_flg = 1
            SET drdm_next_row_pos = (drdm_next_row_pos+ 1)
            SET missing_xlats->qual[amx_loop].processed_ind = 1
            SET amx_first_added_ind = 1
           ENDIF
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
    ENDFOR
    IF (amx_badrow_ind=1)
     IF (((drdm_next_row_pos+ 1) > drdm_max_rs_size))
      SET drdm_max_rs_size = (drdm_max_rs_size+ 10)
      SET stat = alterlist(drdm_chg->log,drdm_max_rs_size)
     ENDIF
     CALL reinitialize_drdm(drdm_next_row_pos)
     SET amx_return_pos = drdm_next_row_pos
     SET drdm_chg->log[amx_return_pos].next_to_process = amx_log_loop
    ENDIF
    IF (amx_action_ind=0)
     IF ((amx_log_loop < drdm_chg->log[amx_log_loop].next_to_process))
      SET amx_tab_pos = locateval(amx_loop,1,size(dm2_ref_data_doc->tbl_qual,5),drdm_chg->log[
       amx_log_loop].table_name,dm2_ref_data_doc->tbl_qual[amx_loop].table_name)
      IF (amx_tab_pos=0)
       SET amx_temp_pos = temp_tbl_cnt
       SET amx_tab_pos = fill_rs("TABLE",drdm_chg->log[amx_log_loop].table_name)
       SET temp_tbl_cnt = amx_temp_pos
      ENDIF
      IF ((temp_tbl_cnt=- (2)))
       SET drmm_ddl_rollback_ind = 1
       RETURN(amx_log_loop)
      ENDIF
      IF ((drdm_chg->log[amx_log_loop].table_name=drdm_chg->log[drdm_chg->log[amx_log_loop].
      next_to_process].table_name)
       AND (((dm2_ref_data_doc->tbl_qual[amx_tab_pos].merge_delete_ind=1)) OR ((drdm_chg->log[
      amx_log_loop].table_name="SEG_GRP_SEQ_R"))) )
       SET amx_return_pos = find_next_commit(amx_log_loop)
      ELSE
       SET amx_next_tab_pos = locateval(amx_loop,1,size(dm2_ref_data_doc->tbl_qual,5),drdm_chg->log[
        drdm_chg->log[amx_log_loop].next_to_process].table_name,dm2_ref_data_doc->tbl_qual[amx_loop].
        table_name)
       IF (amx_next_tab_pos=0)
        SET amx_temp_pos = temp_tbl_cnt
        SET amx_next_tab_pos = fill_rs("TABLE",drdm_chg->log[drdm_chg->log[amx_log_loop].
         next_to_process].table_name)
        SET temp_tbl_cnt = amx_temp_pos
       ENDIF
       IF ((temp_tbl_cnt=- (2)))
        SET drmm_ddl_rollback_ind = 1
        RETURN(amx_log_loop)
       ENDIF
       SET amx_return_pos = amx_log_loop
      ENDIF
     ELSE
      SET amx_return_pos = amx_log_loop
     ENDIF
    ENDIF
   ELSE
    ROLLBACK
    FOR (amx_loop = 1 TO amx_rs_size)
      CALL insert_noxlat(missing_xlats->qual[amx_loop].table_name,missing_xlats->qual[amx_loop].
       column_name,missing_xlats->qual[amx_loop].missing_value,missing_xlats->qual[amx_loop].
       orphan_ind)
    ENDFOR
    COMMIT
    SET stat = alterlist(missing_xlats->qual,0)
    SET amx_return_pos = find_next_commit(amx_log_loop)
   ENDIF
   IF (drdm_debug_row_ind=1)
    CALL echorecord(drdm_chg)
   ENDIF
   RETURN(amx_return_pos)
 END ;Subroutine
 SUBROUTINE reprocess_move(spm_log_loop,spm_log_cnt)
   DECLARE spm_loop = i4
   DECLARE spm_init_val = i4
   SET spm_loop = size(drdm_chg->log,5)
   SET spm_init_val = spm_log_loop
   WHILE (spm_loop > spm_log_cnt)
    IF ((drdm_chg->log[spm_loop].process_flg=6)
     AND (drdm_chg->log[spm_loop].reprocess_ind=1))
     SET drdm_chg->log[spm_loop].next_to_process = spm_log_loop
     SET drdm_chg->log[spm_loop].reprocess_ind = 0
     SET spm_log_loop = spm_loop
    ENDIF
    SET spm_loop = (spm_loop - 1)
   ENDWHILE
   IF (spm_init_val=spm_log_loop)
    WHILE ((drdm_chg->log[spm_init_val].next_to_process != 0)
     AND (drdm_chg->log[spm_init_val].next_to_process <= drdm_log_loop))
      SET spm_init_val = drdm_chg->log[spm_init_val].next_to_process
    ENDWHILE
    SET drdm_chg->log[spm_log_loop].next_to_process = drdm_chg->log[spm_init_val].next_to_process
   ENDIF
   RETURN(spm_log_loop)
 END ;Subroutine
 SUBROUTINE reinitialize_drdm(rd_log_loop)
   SET drdm_chg->log[rd_log_loop].log_id = 0.0
   SET drdm_chg->log[rd_log_loop].table_name = ""
   SET drdm_chg->log[rd_log_loop].pk_where = ""
   SET drdm_chg->log[rd_log_loop].delete_ind = 0
   SET drdm_chg->log[rd_log_loop].updt_cnt = 0
   SET drdm_chg->log[rd_log_loop].pk_where_value = 0.0
   SET drdm_chg->log[rd_log_loop].next_to_process = 0
   SET drdm_chg->log[rd_log_loop].commit_ind = 0
   SET drdm_chg->log[rd_log_loop].md_delete_ind = 0
   SET drdm_chg->log[rd_log_loop].validate_ind = 0
   SET drdm_chg->log[rd_log_loop].par_location = 0
   SET drdm_chg->log[rd_log_loop].status_flg = 0
   SET drdm_chg->log[rd_log_loop].reprocess_ind = 0
   SET drdm_chg->log[rd_log_loop].process_flg = 0
   SET drdm_chg->log[rd_log_loop].context_name = ""
   SET drdm_chg->log[rd_log_loop].md_context_name = ""
   SET drdm_chg->log[rd_log_loop].src_cntxt_name = ""
   SET drdm_chg->log[rd_log_loop].exploded_ind = 0
   SET drdm_chg->log[rd_log_loop].dm_chg_log_exception_id = 0
   SET drdm_chg->log[rd_log_loop].chg_log_reason_txt = ""
   SET drdm_chg->log[rd_log_loop].blocking_log_id = 0
   SET drdm_chg->log[rd_log_loop].single_pass_log_id = 0.0
   SET drdm_chg->log[rd_log_loop].single_pass_value = 0.0
   SET drdm_chg->log[rd_log_loop].pkw_vers_id = 0.0
   SET drdm_chg->log[rd_log_loop].updt_applctx = 0.0
   SET drdm_chg->log[rd_log_loop].pk_where_hash = 0.0
   SET drdm_chg->log[rd_log_loop].ptam_match_hash = 0.0
   SET drdm_chg->log[rd_log_loop].ptam_match_result = 0.0
   SET drdm_chg->log[rd_log_loop].ptam_match_result_str = ""
   SET drdm_chg->log[rd_log_loop].ptam_str_tspace_cnt = 0
   RETURN(null)
 END ;Subroutine
 SUBROUTINE reset_holdng_rows(null)
   DECLARE rhr_cnt = i4 WITH protect, noconstant(0)
   DECLARE rhr_loop_cnt = i2 WITH protect, noconstant(0)
   DECLARE rhr_context_cnt = i2 WITH protect
   DECLARE drdm_loop = i2 WITH protect, noconstant(0)
   DECLARE rhr_logtype_cnt = i2 WITH protect, noconstant(1)
   DECLARE rhr_tab_name = vc WITH protect
   DECLARE s_log_type = vc WITH protect
   DECLARE s_delete_ind = vc WITH protect
   DECLARE s_context_name = vc WITH protect
   DECLARE rhr_delay_time = i4 WITH protect, noconstant(0)
   SET rhr_cnt = 0
   SET rhr_loop_cnt = 0
   SET rhr_tab_name = dm2_get_rdds_tname("DM_CHG_LOG")
   SET rhr_context_cnt = size(drdm_contexts->qual,5)
   SELECT INTO "NL:"
    FROM dm_info i
    WHERE i.info_domain="RDDS DCL PROCESSING"
     AND i.info_name="EXCEPTION RESET TIME"
    DETAIL
     rhr_delay_time = cnvtint(i.info_number)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_main
   ENDIF
   IF (curqual=0)
    SET rhr_delay_time = 240
   ENDIF
   FOR (drdm_loop = 1 TO rhr_context_cnt)
     FOR (rhr_logtype_cnt = 1 TO 3)
       SET rhr_loop_cnt = 0
       IF (rhr_logtype_cnt=1)
        SET s_log_type = "d.log_type = 'HOLDNG'"
        SET s_delete_ind = "d.delete_ind = 1"
       ELSEIF (rhr_logtype_cnt=2)
        SET s_log_type = "d.log_type = 'HOLDNG'"
        SET s_delete_ind = "d.delete_ind = 0"
       ELSE
        SET s_log_type = "d.log_type = 'NOMV14'"
        SET s_delete_ind = "d.delete_ind = 0"
       ENDIF
       IF ((drdm_contexts->qual[drdm_loop].values="ALL"))
        SET s_context_name = "1=1"
       ELSEIF ((drdm_contexts->qual[drdm_loop].values="NULL"))
        SET s_context_name = "d.context_name IS NULL"
       ELSE
        SET s_context_name = concat("d.context_name = drdm_contexts->qual[drdm_loop].values")
       ENDIF
       WHILE (rhr_loop_cnt=0)
         CALL parser(concat("update into ",rhr_tab_name," d"),0)
         CALL parser(' set d.log_type = "REFCHG", d.updt_dt_tm = cnvtdatetime(curdate,curtime3)',0)
         CALL parser(concat("where ",s_log_type),0)
         CALL parser(" and d.target_env_id = dm2_ref_data_doc->env_target_id",0)
         CALL parser(concat(" and ",s_delete_ind),0)
         CALL parser(concat(" and ",s_context_name),0)
         CALL parser(concat(' and d.updt_dt_tm <= cnvtlookbehind("',trim(cnvtstring(rhr_delay_time)),
           ',MIN",cnvtdatetime(curdate,curtime3))'),0)
         CALL parser("with nocounter, maxqual(d,3000) go",1)
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          ROLLBACK
          GO TO exit_main
         ELSE
          COMMIT
         ENDIF
         IF (curqual=0)
          SET rhr_loop_cnt = 1
         ELSE
          SET rhr_cnt = (rhr_cnt+ 1)
         ENDIF
       ENDWHILE
     ENDFOR
   ENDFOR
   RETURN(rhr_cnt)
 END ;Subroutine
 SUBROUTINE create_ccl_def(null)
   FREE RECORD ccd_tables
   RECORD ccd_tables(
     1 list[*]
       2 r_tab_name = vc
   )
   DECLARE ccd_tab_cnt = i4
   DECLARE ccd_error_ind = i2
   DECLARE v_appl_id = vc
   DECLARE v_pause_cnt = i2
   DECLARE v_insert_ind = i2
   DECLARE ccd_create_row_ind = i2 WITH protect, noconstant(0)
   DECLARE ccd_cnt = i2 WITH protect, noconstant(0)
   DECLARE ccd_cnt2 = i2 WITH protect, noconstant(0)
   DECLARE ccd_temp_tab_cnt = i2 WITH protect, noconstant(0)
   DECLARE ccd_eproc = vc WITH protect, noconstant("")
   SET ccd_error_ind = 0
   SET ccd_tab_cnt = 0
   SET ccd_eproc = dm_err->eproc
   SET dm_err->eproc = "Subroutine Create_CCL_Def"
   FOR (ccd_cnt = 1 TO 3)
     SET ccd_temp_tab_cnt = 0
     FOR (ccd_cnt2 = 1 TO dm2_ref_data_doc->tbl_cnt)
       SELECT INTO "nl:"
        FROM dtable dt
        WHERE (dt.table_name=dm2_ref_data_doc->tbl_qual[ccd_cnt2].r_table_name)
        WITH nocounter
       ;end select
       IF (check_error("Checking for ccl def from dtable") != 0)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        SET drc_reply->status_data.status = "F"
        SET ccd_error_ind = 1
        RETURN(ccd_error_ind)
       ENDIF
       IF (curqual=0
        AND (dm2_ref_data_doc->tbl_qual[ccd_cnt2].mergeable_ind=1))
        SET drl_reply->status = ""
        SET drl_reply->status_msg = ""
        CALL get_lock("RDDS $R CREATION",dm2_ref_data_doc->tbl_qual[ccd_cnt2].r_table_name,0,
         drl_reply)
        IF ((drl_reply->status="F"))
         CALL disp_msg(drl_reply->status_msg,dm_err->logfile,1)
         SET drc_reply->status_data.status = "F"
         SET ccd_error_ind = 1
         CALL remove_lock("RDDS $R CREATION",dm2_ref_data_doc->tbl_qual[ccd_cnt2].r_table_name,
          currdbhandle,drl_reply)
         RETURN(ccd_error_ind)
        ELSEIF ((drl_reply->status="S"))
         SET ccd_create_row_ind = 1
        ELSE
         SET ccd_create_row_ind = 0
        ENDIF
        IF (ccd_create_row_ind=1)
         EXECUTE oragen3 dm2_ref_data_doc->tbl_qual[ccd_cnt2].r_table_name
         IF (check_error(dm_err->eproc)=1)
          CALL remove_lock("RDDS $R CREATION",dm2_ref_data_doc->tbl_qual[ccd_cnt2].r_table_name,
           currdbhandle,drl_reply)
          CALL disp_msg("",dm_err->logfile,1)
          SET ccd_error_ind = 1
          RETURN(ccd_error_ind)
         ENDIF
         SET drl_reply->status = ""
         SET drl_reply->status_msg = ""
         CALL remove_lock("RDDS $R CREATION",dm2_ref_data_doc->tbl_qual[ccd_cnt2].r_table_name,
          currdbhandle,drl_reply)
         IF ((drl_reply->status="F"))
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          SET drc_reply->status_data.status = "F"
          SET ccd_error_ind = 1
          RETURN(ccd_error_ind)
         ELSE
          COMMIT
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
     FOR (ccd_cnt2 = 1 TO dm2_ref_data_doc->tbl_cnt)
       IF ((dm2_ref_data_doc->tbl_qual[ccd_cnt2].mergeable_ind=1))
        SELECT INTO "nl:"
         FROM dtable dt
         WHERE (dt.table_name=dm2_ref_data_doc->tbl_qual[ccd_cnt2].r_table_name)
         DETAIL
          ccd_temp_tab_cnt = (ccd_temp_tab_cnt+ 1)
         WITH nocounter
        ;end select
        IF (check_error("Checking for ccl def from dtable") != 0)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         SET drc_reply->status_data.status = "F"
         SET ccd_error_ind = 1
         RETURN(ccd_error_ind)
        ENDIF
       ELSE
        SET ccd_temp_tab_cnt = (ccd_temp_tab_cnt+ 1)
       ENDIF
     ENDFOR
     IF ((ccd_temp_tab_cnt=dm2_ref_data_doc->tbl_cnt))
      SET ccd_cnt = 3
     ELSEIF (ccd_cnt=3)
      CALL disp_msg("There were three unscuccesful attempts to oragen all necessary $R tables ",
       dm_err->logfile,1)
      SET dm_err->err_ind = 1
      SET drc_reply->status_data.status = "F"
      SET ccd_error_ind = 1
     ELSE
      CALL pause(20)
     ENDIF
   ENDFOR
   SET dm_err->eproc = ccd_eproc
   RETURN(ccd_error_ind)
 END ;Subroutine
 SUBROUTINE check_for_cutover(null)
   SET dm_err->eproc = "Validation for running movers"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_refchg_process d
    WHERE d.refchg_type="CUTOVER PROCESS*"
     AND  EXISTS (
    (SELECT
     "x"
     FROM gv$session g
     WHERE g.audsid=d.rdbhandle_value))
    WITH nocounter
   ;end select
   IF (check_error("Check if any CUTOVER PROCESS is running for this source environment") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   IF (curqual > 0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg =
    "There is currently a CUTOVER in process for this environment. The movers will not start."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE del_chg_log(sbr_table_name,sbr_log_type,sbr_target_id)
   DECLARE dcl_parent_drdm_row = i4 WITH protect, noconstant(0)
   DECLARE dcl_reason_txt = vc WITH protect, noconstant("")
   FREE RECORD dcl_rec_parse
   RECORD dcl_rec_parse(
     1 qual[*]
       2 parse_stmts = vc
   )
   SET stat = alterlist(dcl_rec_parse->qual,9)
   DECLARE sbr_tname_flex = vc
   DECLARE sbr_flex_pos = i4
   DECLARE sbr_look_ahead = vc WITH noconstant(build(global_mover_rec->refchg_buffer,"MIN"))
   SET drdm_any_translated = 1
   SET dm_err->eproc = concat("Updating DM_CHG_LOG Table for log_id: ",trim(cnvtstring(drdm_chg->log[
      drdm_log_loop].log_id,20,1)))
   SET sbr_tname_flex = dm2_get_rdds_tname("DM_CHG_LOG")
   IF ((drdm_chg->log[drdm_log_loop].par_location > 0))
    SET sbr_flex_pos = drdm_chg->log[drdm_log_loop].par_location
   ELSE
    SET sbr_flex_pos = drdm_log_loop
   ENDIF
   SET dcl_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
   IF (sbr_log_type IN ("HOLDNG", "MERGED", "NOMV00"))
    SET dcl_reason_txt = ""
   ELSE
    SET dcl_reason_txt = substring(1,2000,drdm_chg->log[dcl_parent_drdm_row].chg_log_reason_txt)
   ENDIF
   SET dcl_rec_parse->qual[1].parse_stmts = concat(" update into ",sbr_tname_flex," d1 ")
   SET dcl_rec_parse->qual[2].parse_stmts = " set d1.log_type = sbr_log_type, "
   SET dcl_rec_parse->qual[3].parse_stmts = " d1.rdbhandle = NULL, "
   SET dcl_rec_parse->qual[4].parse_stmts = "d1.updt_dt_tm = cnvtdatetime(curdate,curtime3),"
   IF (drmm_src_blocking_id_ind=1)
    SET dcl_rec_parse->qual[5].parse_stmts =
    " d1.blocking_log_id = drdm_chg->log[drdm_log_loop].blocking_log_id,"
   ENDIF
   IF (drmm_excep_flag=1
    AND drmm_reason_flag=1)
    SET dcl_rec_parse->qual[6].parse_stmts =
    " d1.dm_chg_log_exception_id = drdm_chg->log[dcl_parent_drdm_row].dm_chg_log_exception_id,"
    SET dcl_rec_parse->qual[7].parse_stmts = " d1.chg_log_reason_txt = dcl_reason_txt,"
    SET dcl_rec_parse->qual[8].parse_stmts = concat(" d1.updt_cnt = d1.updt_cnt + 1 where",
     " d1.log_id = drdm_chg->log[drdm_log_loop].log_id ")
    IF (sbr_log_type="HOLDNG")
     SET dcl_rec_parse->qual[9].parse_stmts = " and d1.log_type = 'PROCES' with nocounter go"
    ELSE
     SET dcl_rec_parse->qual[9].parse_stmts = " with nocounter go"
     SET global_mover_rec->refchg_upd_cnt = (global_mover_rec->refchg_upd_cnt+ 1)
    ENDIF
   ELSE
    SET dcl_rec_parse->qual[6].parse_stmts = concat(" d1.updt_cnt = d1.updt_cnt + 1 where",
     " d1.log_id = drdm_chg->log[drdm_log_loop].log_id ")
    IF (sbr_log_type="HOLDNG")
     SET dcl_rec_parse->qual[7].parse_stmts = " and d1.log_type = 'PROCES' with nocounter go"
    ELSE
     SET dcl_rec_parse->qual[7].parse_stmts = " with nocounter go"
     SET global_mover_rec->refchg_upd_cnt = (global_mover_rec->refchg_upd_cnt+ 1)
    ENDIF
   ENDIF
   EXECUTE dm_rdds_parse_stmts  WITH replace("REQUEST","DCL_REC_PARSE")
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET drdm_error_out_ind = 1
    SET dm_err->err_ind = 0
   ENDIF
   IF (drdm_log_loop <= drdm_log_cnt)
    SET stat = initrec(drmm_hold_exception)
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE insert_noxlat(sbr_table_name,sbr_column_name,sbr_value,sbr_orphan_ind)
   DECLARE inx_parent_drdm_row = i2 WITH protect, noconstant(0)
   SET drwdr_reply->dcle_id = 0
   SET drwdr_reply->error_ind = 0
   SET drwdr_request->table_name = sbr_table_name
   IF (sbr_orphan_ind=1)
    SET drwdr_request->log_type = "ORPHAN"
   ELSE
    SET drwdr_request->log_type = "NOXLAT"
   ENDIF
   SET drwdr_request->col_name = sbr_column_name
   SET drwdr_request->from_value = sbr_value
   SET drwdr_request->source_env_id = dm2_ref_data_doc->env_source_id
   SET drwdr_request->target_env_id = dm2_ref_data_doc->env_target_id
   SET drwdr_request->dclei_ind = drmm_excep_flag
   EXECUTE dm_rmc_write_dcle_rows  WITH replace("REQUEST","DRWDR_REQUEST"), replace("REPLY",
    "DRWDR_REPLY")
   IF ((drwdr_reply->error_ind=1))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET nodelete_ind = 1
    SET no_insert_update = 1
    SET drdm_error_out_ind = 1
    RETURN(1)
   ENDIF
   IF ((drwdr_reply->dcle_id > 0))
    SET inx_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
    IF (drdm_chg->log[inx_parent_drdm_row].dm_chg_log_exception_id)
     SET drdm_chg->log[inx_parent_drdm_row].dm_chg_log_exception_id = drwdr_reply->dcle_id
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE drdm_get_versioned_row(sbr_t_name,sbr_pk_where,sbr_tbl_cnt)
   DECLARE gvr_index_var = i2
   DECLARE gvr_loop_done = i2
   DECLARE gvr_qual_cnt = i4
   DECLARE gvr_pk_where_stmt = vc
   DECLARE gvr_col_loop = i4
   DECLARE gvr_tab_suffix = vc
   DECLARE gvr_s_tab_name = vc
   DECLARE gvr_qual_cnt = i4
   DECLARE gvr_pk_where_stmt = vc
   DECLARE gvr_rtm_rs_size = i4
   DECLARE gvr_temp_cnt = i4
   DECLARE gvr_act_num = i2
   DECLARE gvr_eff_num = i2
   DECLARE gvr_updt_num = i2
   DECLARE gvr_parent_drdm_row = i2 WITH protect, noconstant(0)
   DECLARE gvr_pk_col = vc WITH protect, noconstant("")
   DECLARE gvr_pk_val = f8 WITH protect, noconstant(0.0)
   DECLARE gvr_cntr = i4 WITH protect, noconstant(1)
   DECLARE dgv_parse_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgv_eff_parse = i4 WITH protect, noconstant(0)
   FREE RECORD dgv_rec_parse
   RECORD dgv_rec_parse(
     1 qual[*]
       2 parse_stmts = vc
   )
   SET gvr_tab_suffix = dm2_rdds_get_tbl_alias(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].suffix)
   SET gvr_s_tab_name = dm2_get_rdds_tname(sbr_t_name)
   FREE RECORD cust_cs_rows
   CALL parser("record cust_cs_rows (",0)
   CALL parser(" 1 qual[*]",0)
   FOR (gvr_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt)
     IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gvr_col_loop].pk_ind=1))
      SET gvr_pk_col = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gvr_col_loop].column_name
      CALL parser(concat(" 2 ",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gvr_col_loop].
        column_name," = ",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gvr_col_loop].data_type),0
       )
      CALL parser(concat(" 2 ",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gvr_col_loop].
        column_name,"_NULLIND = i2 "),0)
     ENDIF
   ENDFOR
   CALL parser(") go",1)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(- (1))
   ENDIF
   IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].version_type != "ALG5"))
    SET gvr_temp_cnt = 0
    SET gvr_qual_cnt = 0
    CALL parser(" select into 'nl:'",0)
    FOR (gvr_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gvr_col_loop].pk_ind=1))
       IF (gvr_temp_cnt > 0)
        CALL parser(" , ",0)
       ENDIF
       SET gvr_temp_cnt = (gvr_temp_cnt+ 1)
       CALL parser(concat("var",cnvtstring(gvr_col_loop)," = nullind(",gvr_tab_suffix,".",
         dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gvr_col_loop].column_name,")"),0)
      ENDIF
    ENDFOR
    CALL parser(concat(" from ",gvr_s_tab_name," ",gvr_tab_suffix),0)
    CALL parser(concat(sbr_pk_where," with nocounter, notrim go"),1)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(- (1))
    ENDIF
    IF (curqual=0)
     RETURN(- (2))
    ENDIF
    IF ((( NOT ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].version_type IN ("ALG6", "ALG7")))) OR ((
    dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].version_type="ALG7")
     AND (dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].effective_col_ind=0))) )
     SET gvr_updt_num = locateval(gvr_index_var,1,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt,
      "UPDT_DT_TM",dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[gvr_index_var].column_name)
     SET gvr_temp_cnt = 0
     CALL parser(" select into 'nl:'",0)
     FOR (gvr_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt)
       IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gvr_col_loop].pk_ind=1))
        IF (gvr_temp_cnt > 0)
         CALL parser(" , ",0)
        ENDIF
        SET gvr_temp_cnt = (gvr_temp_cnt+ 1)
        CALL parser(concat("var",cnvtstring(gvr_col_loop)," = nullind(",gvr_tab_suffix,".",
          dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gvr_col_loop].column_name,")"),0)
       ENDIF
     ENDFOR
     CALL parser(concat(" from  ",gvr_s_tab_name," ",gvr_tab_suffix),0)
     CALL parser(concat(sbr_pk_where," and ",gvr_tab_suffix,".active_ind = 1"),0)
     IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].filter_string > " "))
      CALL parser(concat(" and ",replace(replace(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].
          filter_string,"<SUFFIX>",gvr_tab_suffix,0),"<MERGE LINK>",dm2_ref_data_doc->post_link_name,
         0)),0)
     ENDIF
     CALL parser(
      " detail gvr_qual_cnt = gvr_qual_cnt + 1 stat = alterlist(cust_cs_rows->qual, gvr_qual_cnt) ",0
      )
     FOR (gvr_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt)
       IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gvr_col_loop].pk_ind=1))
        CALL parser(concat("cust_cs_rows->qual[gvr_qual_cnt].",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt
          ].col_qual[gvr_col_loop].column_name," = ",gvr_tab_suffix,".",
          dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gvr_col_loop].column_name),0)
        CALL parser(concat("cust_cs_rows->qual[gvr_qual_cnt].",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt
          ].col_qual[gvr_col_loop].column_name,"_NULLIND = var",trim(cnvtstring(gvr_col_loop))),0)
       ENDIF
     ENDFOR
     CALL parser(" with nocounter, notrim go",1)
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(- (1))
     ENDIF
     IF (size(cust_cs_rows->qual,5)=1)
      SET gvr_loop_done = 1
     ELSEIF (size(cust_cs_rows->qual,5) > 1)
      IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].version_type != "ALG7"))
       FOR (i = 1 TO size(cust_cs_rows->qual,5))
         CALL parser(concat("set gvr_pk_val = cust_cs_rows->qual[i].",gvr_pk_col," go"))
         SET drwdr_reply->dcle_id = 0
         SET drwdr_reply->error_ind = 0
         SET drwdr_request->table_name = sbr_t_name
         SET drwdr_request->log_type = "NOMV44"
         SET drwdr_request->col_name = gvr_pk_col
         SET drwdr_request->from_value = gvr_pk_val
         SET drwdr_request->source_env_id = dm2_ref_data_doc->env_source_id
         SET drwdr_request->target_env_id = dm2_ref_data_doc->env_target_id
         SET drwdr_request->dclei_ind = drmm_excep_flag
         EXECUTE dm_rmc_write_dcle_rows  WITH replace("REQUEST","DRWDR_REQUEST"), replace("REPLY",
          "DRWDR_REPLY")
         IF ((drwdr_reply->error_ind=1))
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          RETURN(- (3))
         ENDIF
       ENDFOR
       SET gvr_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
       SET drdm_chg->log[gvr_parent_drdm_row].dm_chg_log_exception_id = drwdr_reply->dcle_id
       SET drdm_chg->log[gvr_parent_drdm_row].chg_log_reason_txt = concat(
        "Multiple values found in SOURCE in a versioned table ",sbr_pk_where," AND ACTIVE_IND = 1")
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(- (3))
      ELSE
       SET gvr_loop_done = 1
      ENDIF
     ENDIF
     IF (gvr_loop_done=0
      AND (dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].effective_col_ind=1))
      SET gvr_temp_cnt = 0
      SET gvr_qual_cnt = 0
      CALL parser(" select into 'nl:'",0)
      FOR (gvr_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt)
        IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gvr_col_loop].pk_ind=1))
         IF (gvr_temp_cnt > 0)
          CALL parser(" , ",0)
         ENDIF
         SET gvr_temp_cnt = (gvr_temp_cnt+ 1)
         CALL parser(concat("var",cnvtstring(gvr_col_loop)," = nullind(",gvr_tab_suffix,".",
           dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gvr_col_loop].column_name,")"),0)
        ENDIF
      ENDFOR
      CALL parser(concat(" from  ",gvr_s_tab_name," ",gvr_tab_suffix),0)
      CALL parser(concat(sbr_pk_where," and ",gvr_tab_suffix,".",dm2_ref_data_doc->tbl_qual[
        sbr_tbl_cnt].beg_col_name,
        "<= cnvtdatetime(curdate,curtime3)"),0)
      CALL parser(concat(" and ",gvr_tab_suffix,".",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].
        end_col_name,">= cnvtdatetime(curdate,curtime3)"),0)
      IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].filter_string > " "))
       CALL parser(concat(" and ",replace(replace(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].
           filter_string,"<SUFFIX>",gvr_tab_suffix,0),"<MERGE LINK>",dm2_ref_data_doc->post_link_name,
          0)),0)
      ENDIF
      CALL parser(
       " detail gvr_qual_cnt = gvr_qual_cnt + 1 stat = alterlist(cust_cs_rows->qual, gvr_qual_cnt) ",
       0)
      FOR (gvr_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt)
        IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gvr_col_loop].pk_ind=1))
         CALL parser(concat("cust_cs_rows->qual[gvr_qual_cnt].",dm2_ref_data_doc->tbl_qual[
           sbr_tbl_cnt].col_qual[gvr_col_loop].column_name," = ",gvr_tab_suffix,".",
           dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gvr_col_loop].column_name),0)
         CALL parser(concat("cust_cs_rows->qual[gvr_qual_cnt].",dm2_ref_data_doc->tbl_qual[
           sbr_tbl_cnt].col_qual[gvr_col_loop].column_name,"_NULLIND = var",trim(cnvtstring(
             gvr_col_loop))),0)
        ENDIF
      ENDFOR
      CALL parser(" with nocounter, notrim go",1)
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(- (1))
      ENDIF
      IF (size(cust_cs_rows->qual,5)=1)
       SET gvr_loop_done = 1
      ELSEIF (size(cust_cs_rows->qual,5) > 1)
       FOR (i = 1 TO size(cust_cs_rows->qual,5))
         CALL parser(concat("set gvr_pk_val = cust_cs_rows->qual[i].",gvr_pk_col," go"))
         SET drwdr_reply->dcle_id = 0
         SET drwdr_reply->error_ind = 0
         SET drwdr_request->table_name = sbr_t_name
         SET drwdr_request->log_type = "NOMV44"
         SET drwdr_request->col_name = gvr_pk_col
         SET drwdr_request->from_value = gvr_pk_val
         SET drwdr_request->source_env_id = dm2_ref_data_doc->env_source_id
         SET drwdr_request->target_env_id = dm2_ref_data_doc->env_target_id
         SET drwdr_request->dclei_ind = drmm_excep_flag
         EXECUTE dm_rmc_write_dcle_rows  WITH replace("REQUEST","DRWDR_REQUEST"), replace("REPLY",
          "DRWDR_REPLY")
         IF ((drwdr_reply->error_ind=1))
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          RETURN(- (3))
         ENDIF
       ENDFOR
       SET gvr_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
       SET drdm_chg->log[gvr_parent_drdm_row].dm_chg_log_exception_id = drwdr_reply->dcle_id
       SET drdm_chg->log[gvr_parent_drdm_row].chg_log_reason_txt = concat(
        "Multiple values found in SOURCE in a versioned table ",sbr_pk_where," AND EFFECTIVE")
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(- (3))
      ENDIF
     ENDIF
     IF (gvr_loop_done=0
      AND gvr_updt_num > 0)
      SET gvr_temp_cnt = 0
      SET gvr_qual_cnt = 0
      CALL parser(" select into 'nl:'",0)
      FOR (gvr_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt)
        IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gvr_col_loop].pk_ind=1))
         IF (gvr_temp_cnt > 0)
          CALL parser(" , ",0)
         ENDIF
         SET gvr_temp_cnt = (gvr_temp_cnt+ 1)
         CALL parser(concat("var",cnvtstring(gvr_col_loop)," = nullind(",gvr_tab_suffix,".",
           dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gvr_col_loop].column_name,")"),0)
        ENDIF
      ENDFOR
      CALL parser(concat(" from  ",gvr_s_tab_name," ",gvr_tab_suffix),0)
      CALL parser(sbr_pk_where,0)
      IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].filter_string > " "))
       CALL parser(concat(" and ",replace(replace(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].
           filter_string,"<SUFFIX>",gvr_tab_suffix,0),"<MERGE LINK>",dm2_ref_data_doc->post_link_name,
          0)),0)
      ENDIF
      CALL parser(" order by updt_dt_tm desc",0)
      CALL parser(
       " detail gvr_qual_cnt = gvr_qual_cnt + 1 stat = alterlist(cust_cs_rows->qual, gvr_qual_cnt) ",
       0)
      FOR (gvr_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt)
        IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gvr_col_loop].pk_ind=1))
         CALL parser(concat("cust_cs_rows->qual[gvr_qual_cnt].",dm2_ref_data_doc->tbl_qual[
           sbr_tbl_cnt].col_qual[gvr_col_loop].column_name," = ",gvr_tab_suffix,".",
           dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gvr_col_loop].column_name),0)
         CALL parser(concat("cust_cs_rows->qual[gvr_qual_cnt].",dm2_ref_data_doc->tbl_qual[
           sbr_tbl_cnt].col_qual[gvr_col_loop].column_name,"_NULLIND = var",trim(cnvtstring(
             gvr_col_loop))),0)
        ENDIF
      ENDFOR
      CALL parser(" with maxrec=1, nocounter, notrim go",1)
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(- (1))
      ENDIF
      IF (size(cust_cs_rows->qual,5) > 0)
       SET gvr_loop_done = 1
      ENDIF
     ENDIF
     IF (gvr_loop_done=0)
      RETURN(- (2))
     ENDIF
    ELSE
     SET gvr_temp_cnt = 0
     SET dgv_parse_cnt = 1
     SET stat = alterlist(dgv_rec_parse->qual,dgv_parse_cnt)
     SET dgv_rec_parse->qual[dgv_parse_cnt].parse_stmts = " select into 'nl:'"
     FOR (gvr_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt)
       IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gvr_col_loop].pk_ind=1))
        IF (gvr_temp_cnt > 0)
         SET dgv_parse_cnt = (dgv_parse_cnt+ 1)
         SET stat = alterlist(dgv_rec_parse->qual,dgv_parse_cnt)
         SET dgv_rec_parse->qual[dgv_parse_cnt].parse_stmts = " , "
        ENDIF
        SET gvr_temp_cnt = (gvr_temp_cnt+ 1)
        SET dgv_parse_cnt = (dgv_parse_cnt+ 1)
        SET stat = alterlist(dgv_rec_parse->qual,dgv_parse_cnt)
        SET dgv_rec_parse->qual[dgv_parse_cnt].parse_stmts = concat("var",cnvtstring(gvr_col_loop),
         " = nullind(",gvr_tab_suffix,".",
         dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gvr_col_loop].column_name,")")
       ENDIF
     ENDFOR
     SET dgv_parse_cnt = (dgv_parse_cnt+ 1)
     SET stat = alterlist(dgv_rec_parse->qual,dgv_parse_cnt)
     SET dgv_rec_parse->qual[dgv_parse_cnt].parse_stmts = concat(" from  ",gvr_s_tab_name," ",
      gvr_tab_suffix)
     SET dgv_parse_cnt = (dgv_parse_cnt+ 1)
     SET stat = alterlist(dgv_rec_parse->qual,dgv_parse_cnt)
     SET dgv_rec_parse->qual[dgv_parse_cnt].parse_stmts = sbr_pk_where
     IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].filter_string > " "))
      SET dgv_parse_cnt = (dgv_parse_cnt+ 1)
      SET stat = alterlist(dgv_rec_parse->qual,dgv_parse_cnt)
      SET dgv_rec_parse->qual[dgv_parse_cnt].parse_stmts = concat(" and ",replace(replace(
         dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].filter_string,"<SUFFIX>",gvr_tab_suffix,0),
        "<MERGE LINK>",dm2_ref_data_doc->post_link_name,0))
     ENDIF
     SET dgv_parse_cnt = (dgv_parse_cnt+ 1)
     SET dgv_eff_parse = dgv_parse_cnt
     SET stat = alterlist(dgv_rec_parse->qual,dgv_parse_cnt)
     SET dgv_rec_parse->qual[dgv_parse_cnt].parse_stmts = concat(" and ",gvr_tab_suffix,
      ".active_ind = 1 and ",gvr_tab_suffix,".",
      dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].beg_col_name,"<= cnvtdatetime(curdate,curtime3)")
     SET dgv_parse_cnt = (dgv_parse_cnt+ 1)
     SET stat = alterlist(dgv_rec_parse->qual,dgv_parse_cnt)
     SET dgv_rec_parse->qual[dgv_parse_cnt].parse_stmts = concat(" and ",gvr_tab_suffix,".",
      dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].end_col_name,">= cnvtdatetime(curdate,curtime3)")
     SET dgv_parse_cnt = (dgv_parse_cnt+ 1)
     SET stat = alterlist(dgv_rec_parse->qual,dgv_parse_cnt)
     SET dgv_rec_parse->qual[dgv_parse_cnt].parse_stmts =
     " detail gvr_qual_cnt = gvr_qual_cnt + 1 stat = alterlist(cust_cs_rows->qual, gvr_qual_cnt) "
     FOR (gvr_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt)
       IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gvr_col_loop].pk_ind=1))
        SET dgv_parse_cnt = (dgv_parse_cnt+ 1)
        SET stat = alterlist(dgv_rec_parse->qual,dgv_parse_cnt)
        SET dgv_rec_parse->qual[dgv_parse_cnt].parse_stmts = concat(
         "cust_cs_rows->qual[gvr_qual_cnt].",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[
         gvr_col_loop].column_name," = ",gvr_tab_suffix,".",
         dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gvr_col_loop].column_name)
        SET dgv_parse_cnt = (dgv_parse_cnt+ 1)
        SET stat = alterlist(dgv_rec_parse->qual,dgv_parse_cnt)
        SET dgv_rec_parse->qual[dgv_parse_cnt].parse_stmts = concat(
         "cust_cs_rows->qual[gvr_qual_cnt].",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[
         gvr_col_loop].column_name,"_NULLIND = var",trim(cnvtstring(gvr_col_loop)))
       ENDIF
     ENDFOR
     SET dgv_parse_cnt = (dgv_parse_cnt+ 1)
     SET stat = alterlist(dgv_rec_parse->qual,dgv_parse_cnt)
     SET dgv_rec_parse->qual[dgv_parse_cnt].parse_stmts = " with nocounter, notrim go"
     EXECUTE dm_rdds_parse_stmts  WITH replace("REQUEST","DGV_REC_PARSE")
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(- (1))
     ENDIF
     IF (size(cust_cs_rows->qual,5) > 1
      AND (dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].version_type="ALG6"))
      FOR (i = 1 TO size(cust_cs_rows->qual,5))
        CALL parser(concat("set gvr_pk_val = cust_cs_rows->qual[i].",gvr_pk_col," go"))
        SET drwdr_reply->dcle_id = 0
        SET drwdr_reply->error_ind = 0
        SET drwdr_request->table_name = sbr_t_name
        SET drwdr_request->log_type = "NOMV44"
        SET drwdr_request->col_name = gvr_pk_col
        SET drwdr_request->from_value = gvr_pk_val
        SET drwdr_request->source_env_id = dm2_ref_data_doc->env_source_id
        SET drwdr_request->target_env_id = dm2_ref_data_doc->env_target_id
        SET drwdr_request->dclei_ind = drmm_excep_flag
        EXECUTE dm_rmc_write_dcle_rows  WITH replace("REQUEST","DRWDR_REQUEST"), replace("REPLY",
         "DRWDR_REPLY")
        IF ((drwdr_reply->error_ind=1))
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(- (1))
        ENDIF
      ENDFOR
      SET gvr_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
      SET drdm_chg->log[gvr_parent_drdm_row].dm_chg_log_exception_id = drwdr_reply->dcle_id
      SET drdm_chg->log[gvr_parent_drdm_row].chg_log_reason_txt = concat(
       "Multiple values found in SOURCE in a versioned table ",sbr_pk_where,
       " AND ACTIVE_IND = 1 AND EFFECTIVE")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(- (3))
     ELSEIF (size(cust_cs_rows->qual,5)=0)
      SET dgv_rec_parse->qual[dgv_eff_parse].parse_stmts = concat(" and ",gvr_tab_suffix,
       ".active_ind = 1 and ",gvr_tab_suffix,".",
       dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].end_col_name,"<= cnvtdatetime(curdate,curtime3)")
      SET dgv_rec_parse->qual[(dgv_eff_parse+ 1)].parse_stmts = concat(" order by ",gvr_tab_suffix,
       ".",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].end_col_name," desc ")
      SET dgv_rec_parse->qual[dgv_parse_cnt].parse_stmts = " with maxrec = 1, nocounter, notrim go"
      EXECUTE dm_rdds_parse_stmts  WITH replace("REQUEST","DGV_REC_PARSE")
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(- (1))
      ENDIF
      SET gvr_cntr = 1
     ENDIF
     IF (size(cust_cs_rows->qual,5)=0)
      SET dgv_rec_parse->qual[dgv_eff_parse].parse_stmts = concat(" and ",gvr_tab_suffix,
       ".active_ind = 0 and ",gvr_tab_suffix,".",
       dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].beg_col_name,"<= cnvtdatetime(curdate,curtime3)")
      SET dgv_rec_parse->qual[(dgv_eff_parse+ 1)].parse_stmts = concat(" and ",gvr_tab_suffix,".",
       dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].end_col_name," >= cnvtdatetime(curdate,curtime3) ")
      IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].version_type="ALG6"))
       SET dgv_rec_parse->qual[dgv_parse_cnt].parse_stmts = " with nocounter, notrim go"
      ELSE
       SET dgv_rec_parse->qual[(dgv_eff_parse+ 1)].parse_stmts = concat(dgv_rec_parse->qual[(
        dgv_eff_parse+ 1)].parse_stmts," order by ",gvr_tab_suffix,".",dm2_ref_data_doc->tbl_qual[
        sbr_tbl_cnt].beg_col_name,
        " desc ")
       SET dgv_rec_parse->qual[dgv_parse_cnt].parse_stmts = " with maxrec = 1, nocounter, notrim go"
      ENDIF
      EXECUTE dm_rdds_parse_stmts  WITH replace("REQUEST","DGV_REC_PARSE")
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(- (1))
      ENDIF
      IF (size(cust_cs_rows->qual,5) > 1)
       FOR (i = 1 TO size(cust_cs_rows->qual,5))
         CALL parser(concat("set gvr_pk_val = cust_cs_rows->qual[i].",gvr_pk_col," go"))
         SET drwdr_reply->dcle_id = 0
         SET drwdr_reply->error_ind = 0
         SET drwdr_request->table_name = sbr_t_name
         SET drwdr_request->log_type = "NOMV44"
         SET drwdr_request->col_name = gvr_pk_col
         SET drwdr_request->from_value = gvr_pk_val
         SET drwdr_request->source_env_id = dm2_ref_data_doc->env_source_id
         SET drwdr_request->target_env_id = dm2_ref_data_doc->env_target_id
         SET drwdr_request->dclei_ind = drmm_excep_flag
         EXECUTE dm_rmc_write_dcle_rows  WITH replace("REQUEST","DRWDR_REQUEST"), replace("REPLY",
          "DRWDR_REPLY")
         IF ((drwdr_reply->error_ind=1))
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          RETURN(- (1))
         ENDIF
       ENDFOR
       SET gvr_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
       SET drdm_chg->log[gvr_parent_drdm_row].dm_chg_log_exception_id = drwdr_reply->dcle_id
       SET drdm_chg->log[gvr_parent_drdm_row].chg_log_reason_txt = concat(
        "Multiple values found in SOURCE in a versioned table ",sbr_pk_where,
        " AND ACTIVE_IND = 0 AND EFFECTIVE")
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(- (3))
      ELSEIF (size(cust_cs_rows->qual,5)=0)
       SET dgv_rec_parse->qual[dgv_eff_parse].parse_stmts = concat(" and ",gvr_tab_suffix,
        ".active_ind = 0 and ",gvr_tab_suffix,".",
        dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].end_col_name,"<= cnvtdatetime(curdate,curtime3)")
       SET dgv_rec_parse->qual[(dgv_eff_parse+ 1)].parse_stmts = concat(" order by ",gvr_tab_suffix,
        ".",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].end_col_name," desc ")
       SET dgv_rec_parse->qual[dgv_parse_cnt].parse_stmts = " with maxrec = 1, nocounter, notrim go"
       EXECUTE dm_rdds_parse_stmts  WITH replace("REQUEST","DGV_REC_PARSE")
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(- (1))
       ENDIF
       SET gvr_cntr = 1
      ENDIF
     ENDIF
     SET dgv_rec_parse->qual[dgv_eff_parse].parse_stmts = concat(" and ",gvr_tab_suffix,
      ".active_ind = 1 and ",gvr_tab_suffix,".",
      dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].beg_col_name,">= cnvtdatetime(curdate,curtime3)")
     SET dgv_rec_parse->qual[(dgv_eff_parse+ 1)].parse_stmts = " and 1 = 1 "
     SET dgv_rec_parse->qual[dgv_parse_cnt].parse_stmts = " with nocounter, notrim go"
     EXECUTE dm_rdds_parse_stmts  WITH replace("REQUEST","DGV_REC_PARSE")
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(- (1))
     ENDIF
     IF (size(cust_cs_rows->qual,5)=0)
      SET dgv_rec_parse->qual[dgv_eff_parse].parse_stmts = concat(" and ",gvr_tab_suffix,
       ".active_ind = 0 and ",gvr_tab_suffix,".",
       dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].beg_col_name,">= cnvtdatetime(curdate,curtime3)")
      SET dgv_rec_parse->qual[(dgv_eff_parse+ 1)].parse_stmts = concat(" order by ",gvr_tab_suffix,
       ".",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].beg_col_name," asc ")
      SET dgv_rec_parse->qual[dgv_parse_cnt].parse_stmts = " with maxrec = 1, nocounter, notrim go"
      EXECUTE dm_rdds_parse_stmts  WITH replace("REQUEST","DGV_REC_PARSE")
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(- (1))
      ENDIF
     ENDIF
    ENDIF
    FOR (dgv_parse_cnt = 1 TO size(cust_cs_rows->qual,5))
     SET gvr_pk_where_stmt = drdm_create_pk_where(dgv_parse_cnt,sbr_tbl_cnt,"PK")
     IF (gvr_pk_where_stmt != "")
      IF (drdm_next_row_pos > drdm_max_rs_size)
       SET drdm_max_rs_size = (drdm_max_rs_size+ 10)
       SET stat = alterlist(drdm_chg->log,drdm_max_rs_size)
      ENDIF
      CALL reinitialize_drdm(drdm_next_row_pos)
      IF (dgv_parse_cnt=1)
       SET gvr_rtm_rs_size = drdm_next_row_pos
       SET drdm_chg->log[drdm_next_row_pos].md_delete_ind = 1
      ELSE
       SET drdm_chg->log[drdm_next_row_pos].md_delete_ind = 0
      ENDIF
      IF (dgv_parse_cnt < gvr_qual_cnt)
       SET drdm_chg->log[drdm_next_row_pos].next_to_process = (drdm_next_row_pos+ 1)
      ELSE
       SET drdm_chg->log[drdm_next_row_pos].next_to_process = drdm_log_loop
      ENDIF
      SET drdm_chg->log[drdm_next_row_pos].table_name = sbr_t_name
      SET drdm_chg->log[drdm_next_row_pos].pk_where = gvr_pk_where_stmt
      SET drdm_chg->log[drdm_next_row_pos].delete_ind = drdm_chg->log[drdm_log_loop].delete_ind
      SET drdm_chg->log[drdm_next_row_pos].md_context_name = drdm_chg->log[drdm_log_loop].
      md_context_name
      SET drdm_chg->log[drdm_next_row_pos].src_cntxt_name = drdm_chg->log[drdm_log_loop].
      src_cntxt_name
      SET drdm_chg->log[drdm_next_row_pos].context_name = drmm_get_context_name(drdm_chg->log[
       drdm_next_row_pos].src_cntxt_name)
      SET drdm_chg->log[drdm_next_row_pos].commit_ind = 0
      SET drdm_chg->log[drdm_next_row_pos].reprocess_ind = 1
      IF ((drdm_chg->log[drdm_log_loop].process_flg=6))
       SET drdm_chg->log[drdm_next_row_pos].process_flg = 6
      ELSE
       SET drdm_chg->log[drdm_next_row_pos].process_flg = 2
      ENDIF
      SET drdm_chg->log[drdm_next_row_pos].validate_ind = 0
      SET drdm_chg->log[drdm_next_row_pos].log_id = drdm_chg->log[drdm_log_loop].log_id
      SET drdm_chg->log[drdm_next_row_pos].updt_cnt = drdm_chg->log[drdm_log_loop].updt_cnt
      SET drdm_chg->log[drdm_next_row_pos].updt_applctx = drdm_chg->log[drdm_log_loop].updt_applctx
      SET drdm_chg->log[drdm_next_row_pos].pk_where_hash = drdm_chg->log[drdm_log_loop].pk_where_hash
      SET drdm_chg->log[drdm_next_row_pos].ptam_match_hash = drdm_chg->log[drdm_log_loop].
      ptam_match_hash
      SET drdm_chg->log[drdm_next_row_pos].ptam_match_result = drdm_chg->log[drdm_log_loop].
      ptam_match_result
      SET drdm_chg->log[drdm_next_row_pos].ptam_match_result_str = drdm_chg->log[drdm_log_loop].
      ptam_match_result_str
      SET drdm_chg->log[drdm_next_row_pos].ptam_str_tspace_cnt = drdm_chg->log[drdm_log_loop].
      ptam_str_tspace_cnt
      SET drdm_next_row_pos = (drdm_next_row_pos+ 1)
     ELSE
      RETURN(- (1))
     ENDIF
    ENDFOR
   ELSE
    SET gvr_temp_cnt = 0
    SET gvr_qual_cnt = 0
    CALL parser(" select into 'nl:'",0)
    FOR (gvr_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gvr_col_loop].pk_ind=1))
       IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gvr_col_loop].root_entity_name=
       dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].table_name)
        AND (dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gvr_col_loop].root_entity_attr=
       dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gvr_col_loop].column_name))
        SET gvr_top_level = gvr_col_loop
       ENDIF
       IF (gvr_temp_cnt > 0)
        CALL parser(" , ",0)
       ENDIF
       SET gvr_temp_cnt = (gvr_temp_cnt+ 1)
       CALL parser(concat("var",cnvtstring(gvr_col_loop)," = nullind(",gvr_tab_suffix,".",
         dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gvr_col_loop].column_name,")"),0)
      ENDIF
    ENDFOR
    CALL parser(concat(" from  ",gvr_s_tab_name," ",gvr_tab_suffix),0)
    CALL parser(sbr_pk_where,0)
    IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].filter_string > " "))
     CALL parser(concat(" and ",replace(replace(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].filter_string,
         "<SUFFIX>",gvr_tab_suffix,0),"<MERGE LINK>",dm2_ref_data_doc->post_link_name,0)),0)
    ENDIF
    CALL parser(
     " detail gvr_qual_cnt = gvr_qual_cnt + 1 stat = alterlist(cust_cs_rows->qual, gvr_qual_cnt) ",0)
    CALL parser(" gvr_loop_done = 1 ",0)
    FOR (gvr_col_loop = 1 TO dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt)
      IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gvr_col_loop].pk_ind=1))
       CALL parser(concat("cust_cs_rows->qual[gvr_qual_cnt].",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt]
         .col_qual[gvr_col_loop].column_name," = ",gvr_tab_suffix,".",
         dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[gvr_col_loop].column_name),0)
       CALL parser(concat("cust_cs_rows->qual[gvr_qual_cnt].",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt]
         .col_qual[gvr_col_loop].column_name,"_NULLIND = var",trim(cnvtstring(gvr_col_loop))),0)
      ENDIF
    ENDFOR
    CALL parser(" with nocounter, notrim go",1)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(- (1))
    ENDIF
    IF (gvr_loop_done=0)
     RETURN(- (2))
    ENDIF
    FOR (gvr_col_loop = 1 TO gvr_qual_cnt)
     SET gvr_pk_where_stmt = drdm_create_pk_where(gvr_col_loop,sbr_tbl_cnt,"PK")
     IF (gvr_pk_where_stmt != "")
      IF (drdm_next_row_pos > drdm_max_rs_size)
       SET drdm_max_rs_size = (drdm_max_rs_size+ 10)
       SET stat = alterlist(drdm_chg->log,drdm_max_rs_size)
      ENDIF
      CALL reinitialize_drdm(drdm_next_row_pos)
      IF (gvr_col_loop=1)
       SET drdm_chg->log[drdm_next_row_pos].md_delete_ind = 1
       SET gvr_rtm_rs_size = drdm_next_row_pos
      ELSE
       SET drdm_chg->log[drdm_next_row_pos].md_delete_ind = 0
      ENDIF
      IF (gvr_col_loop < gvr_qual_cnt)
       SET drdm_chg->log[drdm_next_row_pos].next_to_process = (drdm_next_row_pos+ 1)
      ELSE
       SET drdm_chg->log[drdm_next_row_pos].next_to_process = drdm_log_loop
      ENDIF
      SET drdm_chg->log[drdm_next_row_pos].table_name = sbr_t_name
      SET drdm_chg->log[drdm_next_row_pos].pk_where = gvr_pk_where_stmt
      SET drdm_chg->log[drdm_next_row_pos].delete_ind = drdm_chg->log[drdm_log_loop].delete_ind
      SET drdm_chg->log[drdm_next_row_pos].md_context_name = drdm_chg->log[drdm_log_loop].
      md_context_name
      SET drdm_chg->log[drdm_next_row_pos].src_cntxt_name = drdm_chg->log[drdm_log_loop].
      src_cntxt_name
      SET drdm_chg->log[drdm_next_row_pos].context_name = drmm_get_context_name(drdm_chg->log[
       drdm_next_row_pos].src_cntxt_name)
      SET drdm_chg->log[drdm_next_row_pos].commit_ind = 0
      IF (gvr_top_level > 0)
       SET drdm_chg->log[drdm_next_row_pos].reprocess_ind = 1
      ENDIF
      IF ((drdm_chg->log[drdm_log_loop].process_flg=6))
       SET drdm_chg->log[drdm_next_row_pos].process_flg = 6
      ELSE
       SET drdm_chg->log[drdm_next_row_pos].process_flg = 2
      ENDIF
      SET drdm_chg->log[drdm_next_row_pos].validate_ind = 0
      SET drdm_chg->log[drdm_next_row_pos].log_id = drdm_chg->log[drdm_log_loop].log_id
      SET drdm_chg->log[drdm_next_row_pos].updt_cnt = drdm_chg->log[drdm_log_loop].updt_cnt
      SET drdm_chg->log[drdm_next_row_pos].updt_applctx = drdm_chg->log[drdm_log_loop].updt_applctx
      SET drdm_chg->log[drdm_next_row_pos].pk_where_hash = drdm_chg->log[drdm_log_loop].pk_where_hash
      SET drdm_chg->log[drdm_next_row_pos].ptam_match_hash = drdm_chg->log[drdm_log_loop].
      ptam_match_hash
      SET drdm_chg->log[drdm_next_row_pos].ptam_match_result = drdm_chg->log[drdm_log_loop].
      ptam_match_result
      SET drdm_chg->log[drdm_next_row_pos].ptam_match_result_str = drdm_chg->log[drdm_log_loop].
      ptam_match_result_str
      SET drdm_chg->log[drdm_next_row_pos].ptam_str_tspace_cnt = drdm_chg->log[drdm_log_loop].
      ptam_str_tspace_cnt
      SET drdm_next_row_pos = (drdm_next_row_pos+ 1)
     ELSE
      RETURN(- (1))
     ENDIF
    ENDFOR
   ENDIF
   RETURN(gvr_rtm_rs_size)
 END ;Subroutine
 SUBROUTINE drmm_updt_nomv00(sbr_log_pos,sbr_context_string)
   DECLARE dun_context_string = vc WITH protect, noconstant("")
   DECLARE dun_tab_name = vc WITH protect, noconstant("")
   DECLARE dun_updt_done = i2 WITH protect, noconstant(0)
   DECLARE dun_rdbhandle = f8 WITH protect, noconstant(0.0)
   DECLARE dun_lock_ind = i2 WITH protect, noconstant(0)
   DECLARE dun_dcl_name = vc WITH protect, noconstant("")
   DECLARE dun_done = i2 WITH protect, noconstant(0)
   DECLARE dun_batch_size = i4 WITH protect, noconstant(10000)
   DECLARE dun_next_idx = i4 WITH protect, noconstant(0)
   DECLARE dun_cur_idx = i4 WITH protect, noconstant(0)
   DECLARE dun_return_val = i4 WITH protect, noconstant(0)
   DECLARE dun_rs_cleanup_done = i2 WITH protect, noconstant(0)
   DECLARE dun_where_stmt = vc WITH protect, noconstant("")
   DECLARE dun_del_ind = i2 WITH protect, noconstant(0)
   SET dun_context_string = sbr_context_string
   SET dun_table_name = drdm_chg->log[sbr_log_pos].table_name
   SET dun_updt_done = 0
   WHILE (dun_updt_done=0)
     SET dm_err->eproc = "Checking if another mover is performing NOMV00 update."
     SELECT INTO "nl:"
      FROM dm_info d
      WHERE d.info_domain="RDDS NOMV00 UPDATE"
       AND d.info_name=dun_table_name
      DETAIL
       dun_rdbhandle = d.info_number
      WITH nocounter, forupdate(d)
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm_err->err_ind = 0
     ENDIF
     IF (curqual=1)
      SET dm_err->eproc = "Querying gv$session for NOMV00 update rdbhandle."
      SELECT INTO "nl:"
       FROM gv$session gv
       WHERE gv.audsid=dun_rdbhandle
        AND gv.audsid != cnvtreal(currdbhandle)
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(- (1))
      ENDIF
      IF (curqual=1)
       ROLLBACK
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        GO TO exit_main
       ENDIF
       COMMIT
       SET dm_err->eproc = "Pause 60 seconds before checking the NOMV00 update again."
       CALL disp_msg("",dm_err->logfile,0)
       CALL pause(60)
      ELSE
       SET dm_err->eproc = "Updating NOMV00 Update locking row"
       UPDATE  FROM dm_info di
        SET di.info_number = cnvtreal(currdbhandle)
        WHERE di.info_domain="RDDS NOMV00 UPDATE"
         AND di.info_name=dun_table_name
        WITH nocounter
       ;end update
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(- (1))
       ENDIF
       COMMIT
       SET dun_lock_ind = 1
      ENDIF
     ELSE
      SET dm_err->eproc = "Inserting NOMV00 Update Locking row into dm_info."
      INSERT  FROM dm_info di
       SET di.info_domain = "RDDS NOMV00 UPDATE", di.info_name = dun_table_name, di.info_number =
        cnvtreal(currdbhandle)
       WITH nocounter
      ;end insert
      IF (check_error(dm_err->eproc)=1)
       SET dm_err->err_ind = 0
       SET dm_err->eproc = "Pause 60 seconds before checking the NOMV00 update again."
       CALL disp_msg("",dm_err->logfile,0)
       CALL pause(60)
      ELSE
       COMMIT
       SET dun_lock_ind = 1
      ENDIF
     ENDIF
     IF (dun_lock_ind=1)
      SELECT INTO "nl:"
       FROM dm_info di
       WHERE di.info_domain="DATA MANAGEMENT"
        AND di.info_name="NOMV00 UPDATE BATCH SIZE"
       DETAIL
        dun_batch_size = di.info_number
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(- (1))
      ENDIF
      SET dm_err->eproc = "Updating DCL rows to NOMV00."
      SET dun_dcl_name = dm2_get_rdds_tname("DM_CHG_LOG")
      SET dun_where_stmt = concat(
       " d.log_type IN('REFCHG','PROCES','NORDDS') and d.table_name = dun_table_name ",
       dun_context_string,
       " and d.target_env_id = dm2_ref_data_doc->env_target_id and d.delete_ind = dun_del_ind")
      SET dun_done = 0
      WHILE (dun_done=0)
        UPDATE  FROM (parser(dun_dcl_name) d)
         SET d.log_type = "NOMV00"
         WHERE parser(dun_where_stmt)
         WITH nocounter, maxqual(d,value(dun_batch_size))
        ;end update
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(- (1))
        ENDIF
        COMMIT
        IF (curqual=0)
         SET dun_done = 1
        ENDIF
      ENDWHILE
      SET dun_del_ind = 1
      SET dun_done = 0
      WHILE (dun_done=0)
        UPDATE  FROM (parser(dun_dcl_name) d)
         SET d.log_type = "NOMV00"
         WHERE parser(dun_where_stmt)
         WITH nocounter, maxqual(d,value(dun_batch_size))
        ;end update
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(- (1))
        ENDIF
        COMMIT
        IF (curqual=0)
         SET dun_done = 1
        ENDIF
      ENDWHILE
      SET dun_cur_idx = sbr_log_pos
      SET dun_next_idx = drdm_chg->log[dun_cur_idx].next_to_process
      WHILE (dun_rs_cleanup_done=0
       AND dun_next_idx != 0)
        IF ((drdm_chg->log[dun_next_idx].table_name=dun_table_name))
         SET dun_cur_idx = dun_next_idx
         SET dun_next_idx = drdm_chg->log[dun_cur_idx].next_to_process
        ELSE
         SET dun_rs_cleanup_done = 1
        ENDIF
      ENDWHILE
      SET dun_return_val = dun_next_idx
      SET dm_err->eproc = "Deleting NOMV00 Update locking row from dm_info."
      DELETE  FROM dm_info di
       WHERE di.info_domain="RDDS NOMV00 UPDATE"
        AND di.info_name=dun_table_name
       WITH nocounter
      ;end delete
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ENDIF
      COMMIT
      SET dun_updt_done = 1
     ENDIF
   ENDWHILE
   RETURN(dun_return_val)
 END ;Subroutine
 SUBROUTINE drmm_cur_state_explode(sbr_log_pos)
   DECLARE dcse_tbl_pos = i4 WITH protect, noconstant(0)
   DECLARE dcse_tab_name = vc WITH protect, noconstant("")
   DECLARE dcse_num = i4 WITH protect, noconstant(0)
   DECLARE dcse_pkw = vc WITH protect, noconstant("")
   DECLARE dcse_col_loop = i4 WITH protect, noconstant(0)
   DECLARE dcse_parser_cnt = i4 WITH protect, noconstant(0)
   DECLARE dcse_temp = i4 WITH protect, noconstant(0)
   DECLARE dcse_table_suffix = vc WITH protect, noconstant("")
   DECLARE dcse_total = i4 WITH protect, noconstant(0)
   DECLARE dcse_row_type = vc WITH protect, noconstant("")
   DECLARE dcse_status = vc WITH protect, noconstant("")
   DECLARE dcse_log_type = c6 WITH protect
   DECLARE dcse_currval = f8 WITH protect, noconstant(0.0)
   DECLARE dcse_new_currval = f8 WITH protect, noconstant(0.0)
   DECLARE dcse_single_pass_ind = i2 WITH protect, noconstant(0)
   DECLARE dcse_dcl_tab = vc WITH protect, noconstant(" ")
   DECLARE dcse_log_id = f8 WITH protect, noconstant(0.0)
   DECLARE dcse_next_row_pos = i4 WITH protect, noconstant(0)
   DECLARE dcse_reason_str = vc WITH protect, noconstant("")
   DECLARE dcse_context_str = vc WITH protect, noconstant(" ")
   DECLARE dcse_pe_pos = i4 WITH protect, noconstant(0)
   DECLARE dcse_pe_col = vc WITH protect, noconstant(" ")
   DECLARE dcse_pe_val = vc WITH protect, noconstant(" ")
   DECLARE dcse_parent_drdm_row = i4 WITH protect, noconstant(0)
   DECLARE dcse_next_row_temp = i4 WITH protect, noconstant(0)
   DECLARE dcse_par_pos = i4 WITH protect, noconstant(0)
   DECLARE dcse_top_level = vc WITH protect, noconstant("")
   DECLARE dcse_temp_cnt = i4 WITH protect, noconstant(0)
   DECLARE dcse_pkw_value = f8 WITH protect, noconstant(0.0)
   DECLARE length() = i4
   IF (validate(drcse_request->table_name,"a")="a"
    AND validate(drcse_request->table_name,"b")="b")
    FREE RECORD drcse_request
    RECORD drcse_request(
      1 table_name = vc
      1 tbl_pos = i4
      1 pk_where = vc
      1 source_ind = i2
      1 top_level_pos = i4
    )
    FREE RECORD drcse_reply
    RECORD drcse_reply(
      1 status = c1
      1 total = i4
      1 qual[*]
        2 pk_where = vc
    )
   ENDIF
   SET dm_err->eproc = "Beginning drmm_cur_state_explode sub."
   SET drcse_request->table_name = drdm_chg->log[sbr_log_pos].table_name
   SET dcse_tab_name = drdm_chg->log[sbr_log_pos].table_name
   SET drcse_request->tbl_pos = locateval(dcse_num,1,dm2_ref_data_doc->tbl_cnt,dcse_tab_name,
    dm2_ref_data_doc->tbl_qual[dcse_num].table_name)
   SET drcse_request->pk_where = drdm_chg->log[sbr_log_pos].pk_where
   SET drcse_request->source_ind = 1
   SET stat = initrec(drcse_reply)
   SET dcse_table_suffix = concat("t",dm2_ref_data_doc->tbl_qual[dcse_tbl_pos].suffix)
   IF ((drcse_request->tbl_pos=0))
    CALL echo(concat("Table ",dcse_tab_name," doesn't exist in table level meta-data."))
    SET dcse_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
    SET drdm_chg->log[dcse_parent_drdm_row].chg_log_reason_txt = concat("Table ",dcse_tab_name,
     " doesn't exist in table level meta-data.")
    RETURN("NOMV58")
   ENDIF
   IF ((drdm_chg->log[sbr_log_pos].updt_applctx=4310001.0))
    RETURN("")
   ENDIF
   SET dcse_pe_pos = fill_cur_state_rs(dcse_tab_name)
   IF (dcse_pe_pos=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("ERROR: Couldn't not gather current state information for table ",
     dcse_tab_name,".")
    SET dcse_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
    SET drdm_chg->log[dcse_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
    RETURN("NOMV58")
   ENDIF
   SET dm_err->eproc = "Setting Colstring and PTAM_MATCH_QUERY contexts"
   CALL drmm_get_col_string(" ",drdm_chg->log[sbr_log_pos].log_id,dcse_tab_name,dm2_ref_data_doc->
    tbl_qual[dcse_tbl_pos].suffix,dm2_ref_data_doc->post_link_name)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    SET dcse_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
    SET drdm_chg->log[dcse_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
    RETURN("NOMV58")
   ENDIF
   IF ((dm2_ref_data_doc->tbl_qual[drcse_request->tbl_pos].cur_state_flag=2))
    SET dcse_pe_col = cur_state_tabs->qual[dcse_pe_pos].parent_tab_col
    DECLARE refchg_colstring_get_col() = c30
    DECLARE sys_context() = c4000
    SELECT INTO "nl:"
     v_str = refchg_colstring_get_col(sys_context("CERNER","RDDS_COL_STRING",4000),dcse_pe_col,4,0,"",
      0,0,"FROM")
     FROM dual
     DETAIL
      dcse_pe_val = v_str
     WITH nocounter
    ;end select
    SET dcse_par_pos = locateval(dcse_num,1,cur_state_tabs->qual[dcse_pe_pos].parent_cnt,dcse_pe_val,
     cur_state_tabs->qual[dcse_pe_pos].parent_qual[dcse_num].parent_table)
    IF (dcse_par_pos=0)
     RETURN("")
    ELSE
     SET dcse_top_level = cur_state_tabs->qual[dcse_pe_pos].parent_qual[dcse_par_pos].
     top_level_parent
    ENDIF
   ELSE
    SET dcse_top_level = cur_state_tabs->qual[dcse_pe_pos].parent_qual[1].top_level_parent
   ENDIF
   IF ((drdm_chg->log[sbr_log_pos].single_pass_log_id > 0))
    SET dcse_log_type = "PROCES"
    SET dcse_single_pass_ind = 1
   ELSE
    SET dcse_log_type = "REFCHG"
   ENDIF
   SET dcse_temp_cnt = temp_tbl_cnt
   SET dcse_par_pos = locateval(dcse_num,1,dm2_ref_data_doc->tbl_cnt,dcse_top_level,dm2_ref_data_doc
    ->tbl_qual[dcse_num].table_name)
   IF (dcse_par_pos=0)
    SET dcse_par_pos = fill_rs("TABLE",dcse_top_level)
    IF ((dcse_par_pos=- (1)))
     CALL disp_msg("Table can't be created from remote mover",dm_err->logfile,1)
     SET dcse_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
     SET drdm_chg->log[dcse_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
     RETURN("NOMV58")
    ENDIF
    IF ((dcse_par_pos=- (2)))
     RETURN("-2")
    ENDIF
   ENDIF
   SET temp_tbl_cnt = dcse_temp_cnt
   SET drcse_request->top_level_pos = dcse_par_pos
   SET drcse_request->source_ind = 1
   SET stat = initrec(drcse_reply)
   EXECUTE dm_rmc_cur_state_explode  WITH replace("REQUEST","DRCSE_REQUEST"), replace("REPLY",
    "DRCSE_REPLY")
   IF ((drcse_reply->status != "S"))
    CALL echo("Error occurred while attempting current state explode.")
    SET dcse_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
    SET drdm_chg->log[dcse_parent_drdm_row].chg_log_reason_txt =
    "Error occurred while attempting current state explode."
    RETURN("NOMV58")
   ENDIF
   IF ((drcse_reply->total=0))
    RETURN("NO SRC")
   ENDIF
   CALL drmm_get_ptam_match_query(drdm_chg->log[sbr_log_pos].log_id,dcse_tab_name,dm2_ref_data_doc->
    tbl_qual[dcse_tbl_pos].suffix,dm2_ref_data_doc->post_link_name)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    SET dcse_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
    SET drdm_chg->log[dcse_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
    RETURN("NOMV58")
   ENDIF
   SET dcse_reason_str = "This row was replaced with the log_id(s): "
   SELECT INTO "nl:"
    dcse_val = seq(rdds_source_clinical_seq,currval)
    FROM dual
    DETAIL
     dcse_currval = dcse_val
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    SET dcse_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
    SET drdm_chg->log[dcse_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
    RETURN("NOMV58")
   ENDIF
   FOR (dcse_temp = 1 TO drcse_reply->total)
     SET dcse_status = call_ins_dcl(dcse_tab_name,drcse_reply->qual[dcse_temp].pk_where,dcse_log_type,
      0,reqinfo->updt_id,
      reqinfo->updt_task,4310001,drdm_chg->log[sbr_log_pos].src_cntxt_name,dm2_ref_data_doc->
      env_target_id,drdm_chg->log[sbr_log_pos].single_pass_log_id,
      dm2_ref_data_doc->post_link_name,drdm_chg->log[sbr_log_pos].pk_where_hash,drdm_chg->log[
      sbr_log_pos].ptam_match_hash)
     IF (dcse_status="F")
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      SET dcse_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
      SET drdm_chg->log[dcse_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
      RETURN("NOMV58")
     ENDIF
     SELECT INTO "nl:"
      dcse_val = seq(rdds_source_clinical_seq,currval)
      FROM dual
      DETAIL
       dcse_new_currval = dcse_val
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      SET dcse_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
      SET drdm_chg->log[dcse_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
      RETURN("NOMV58")
     ENDIF
     IF (dcse_new_currval=dcse_currval)
      SET dcse_dcl_tab = dm2_get_rdds_tname("DM_CHG_LOG")
      SET dm_err->eproc = "Searching for single pass DCL row."
      IF ((drdm_chg->log[sbr_log_pos].src_cntxt_name > " "))
       SET dcse_context_str = " d.context_name = drdm_chg->log[sbr_log_pos].src_cntxt_name"
      ELSE
       SET dcse_context_str = " d.context_name is null "
      ENDIF
      DECLARE dm_get_hash_value() = f8
      SELECT INTO "nl:"
       pkw_value = dm_get_hash_value(drcse_reply->qual[dcse_temp].pk_where,0,1073741824.0)
       FROM dual
       DETAIL
        dcse_pkw_value = pkw_value
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       SET dcse_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
       SET drdm_chg->log[dcse_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
       RETURN("NOMV58")
      ENDIF
      SELECT INTO "nl:"
       d.log_id
       FROM (parser(dcse_dcl_tab) d)
       WHERE d.table_name=dcse_tab_name
        AND d.delete_ind=0
        AND (d.target_env_id=dm2_ref_data_doc->env_target_id)
        AND d.log_type IN ("REFCHG", "PROCES", "NORDDS")
        AND parser(dcse_context_str)
        AND (d.pk_where=drcse_reply->qual[dcse_temp].pk_where)
        AND d.pk_where_value=dcse_pkw_value
       DETAIL
        dcse_log_id = d.log_id
       WITH nocounter, maxqual(d,1), forupdatewait
      ;end select
      IF (check_error(dm_err->eproc)=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       SET dcse_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
       SET drdm_chg->log[dcse_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
       RETURN("NOMV58")
      ENDIF
     ELSE
      SET dcse_log_id = dcse_new_currval
     ENDIF
     IF (dcse_single_pass_ind=1)
      IF (dcse_new_currval=dcse_currval)
       UPDATE  FROM (parser(dcse_dcl_tab) d)
        SET d.rdbhandle = currdbhandle, d.log_type = "PROCES", d.single_pass_log_id = drdm_chg->log[
         sbr_log_pos].single_pass_log_id
        WHERE d.log_id=dcse_log_id
        WITH nocounter
       ;end update
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        SET dcse_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
        SET drdm_chg->log[dcse_parent_drdm_row].chg_log_reason_xt = dm_err->emsg
        ROLLBACK
        RETURN("NOMV58")
       ENDIF
      ENDIF
      IF (drdm_next_row_pos > drdm_max_rs_size)
       SET drdm_max_rs_size = (drdm_max_rs_size+ 10)
       SET stat = alterlist(drdm_chg->log,drdm_max_rs_size)
      ENDIF
      CALL reinitialize_drdm(drdm_next_row_pos)
      IF (dcse_temp=1)
       SET dcse_next_row_temp = drdm_chg->log[drdm_log_loop].next_to_process
       SET drdm_chg->log[drdm_log_loop].next_to_process = drdm_next_row_pos
      ENDIF
      IF ((dcse_temp < drcse_reply->total))
       SET drdm_chg->log[drdm_next_row_pos].next_to_process = (drdm_next_row_pos+ 1)
      ELSE
       SET drdm_chg->log[drdm_next_row_pos].next_to_process = dcse_next_row_temp
      ENDIF
      SET drdm_chg->log[drdm_next_row_pos].log_id = dcse_log_id
      SET drdm_chg->log[drdm_next_row_pos].table_name = dcse_tab_name
      SET drdm_chg->log[drdm_next_row_pos].pk_where = drcse_reply->qual[dcse_temp].pk_where
      SET drdm_chg->log[drdm_next_row_pos].delete_ind = drdm_chg->log[drdm_log_loop].delete_ind
      SET drdm_chg->log[drdm_next_row_pos].md_context_name = drdm_chg->log[drdm_log_loop].
      md_context_name
      SET drdm_chg->log[drdm_next_row_pos].src_cntxt_name = drdm_chg->log[drdm_log_loop].
      src_cntxt_name
      SET drdm_chg->log[drdm_next_row_pos].context_name = drmm_get_context_name(drdm_chg->log[
       drdm_next_row_pos].src_cntxt_name)
      SET drdm_chg->log[drdm_next_row_pos].commit_ind = 1
      SET drdm_chg->log[drdm_next_row_pos].process_flg = 1
      SET drdm_chg->log[drdm_next_row_pos].status_flg = 1
      SET drdm_chg->log[drdm_next_row_pos].validate_ind = 1
      SET drdm_chg->log[drdm_next_row_pos].updt_cnt = drdm_chg->log[drdm_log_loop].updt_cnt
      SET drdm_chg->log[drdm_next_row_pos].updt_applctx = 4310001
      SET drdm_chg->log[drdm_next_row_pos].pk_where_hash = drdm_chg->log[drdm_log_loop].pk_where_hash
      SET drdm_chg->log[drdm_next_row_pos].ptam_match_hash = drdm_chg->log[drdm_log_loop].
      ptam_match_hash
      SET drdm_chg->log[drdm_next_row_pos].ptam_match_result = drdm_chg->log[drdm_log_loop].
      ptam_match_result
      SET drdm_chg->log[drdm_next_row_pos].ptam_match_result_str = drdm_chg->log[drdm_log_loop].
      ptam_match_result_str
      SET drdm_chg->log[drdm_next_row_pos].ptam_str_tspace_cnt = drdm_chg->log[drdm_log_loop].
      ptam_str_tspace_cnt
      SET drdm_chg->log[drdm_next_row_pos].single_pass_value = drdm_chg->log[drdm_log_loop].
      single_pass_value
      SET drdm_next_row_pos = (drdm_next_row_pos+ 1)
     ENDIF
     IF (dcse_temp != 1)
      SET dcse_reason_str = concat(dcse_reason_str,",")
     ENDIF
     SET dcse_reason_str = concat(dcse_reason_str," ",trim(cnvtstring(dcse_log_id,20,1)))
     SET dcse_currval = dcse_new_currval
     COMMIT
   ENDFOR
   SET drdm_chg->log[drdm_log_loop].chg_log_reason_txt = concat(dcse_reason_str,
    " for the purpose of RDDS Current State processing.")
   RETURN("NOMV57")
 END ;Subroutine
 SUBROUTINE drmm_hash_backfill(sbr_log_pos,sbr_tbl_cnt)
   DECLARE dhb_vers_id = f8 WITH protect, noconstant(0.0)
   DECLARE dhb_vers_template = vc WITH protect, noconstant("")
   DECLARE dhb_tab_name = vc WITH protect, noconstant("")
   DECLARE dhb_vers_tab_name = vc WITH protect, noconstant("")
   DECLARE dhb_ptam_result = f8 WITH protect, noconstant(0.0)
   DECLARE dhb_dcl_tab_name = vc WITH protect, noconstant("")
   DECLARE dhb_ind = i4 WITH protect, noconstant(0)
   DECLARE dhb_cs_pos = i4 WITH protect, noconstant(0)
   DECLARE dhb_parent_drdm_row = i4 WITH protect, noconstant(0)
   DECLARE dhb_loop = i4 WITH protect, noconstant(0)
   FREE RECORD dhb_request
   RECORD dhb_request(
     1 table_name = vc
     1 pk_string = vc
   ) WITH protect
   FREE RECORD dhb_reply
   RECORD dhb_reply(
     1 status = vc
     1 err_msg = vc
   ) WITH protect
   DECLARE sys_context() = c4000
   SET dm_err->eproc = "Beginning drmm_hash_backfill sub."
   SET dhb_vers_id = drdm_chg->log[sbr_log_pos].pkw_vers_id
   SET dhb_tab_name = drdm_chg->log[sbr_log_pos].table_name
   SET dhb_vers_tab_name = dm2_get_rdds_tname("DM_REFCHG_PKW_VERS")
   SET dhb_vers_template = drdm_chg->log[sbr_log_pos].pk_where
   IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].cur_state_flag=2))
    SET dhb_cs_pos = fill_cur_state_rs(dhb_tab_name)
    IF (dhb_cs_pos=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("ERROR: Couldn't not gather current state information for table ",
      dhb_tab_name,".")
     SET dhb_parent_drdm_row = find_original_log_row(drdm_chg,drdm_log_loop)
     SET drdm_chg->log[dhb_parent_drdm_row].chg_log_reason_txt = dm_err->emsg
     RETURN("NOMV99")
    ENDIF
    FOR (dhb_loop = 1 TO cur_state_tabs->qual[dhb_cs_pos].parent_cnt)
      IF (findstring(cur_state_tabs->qual[dhb_cs_pos].parent_qual[dhb_loop].parent_table,
       dhb_vers_template,1,1) > 0)
       RETURN("")
      ENDIF
    ENDFOR
   ENDIF
   SET dhb_ind = drmm_get_col_string(drdm_chg->log[sbr_log_pos].pk_where,0.0,dm2_ref_data_doc->
    tbl_qual[sbr_tbl_cnt].table_name,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].suffix,dm2_ref_data_doc
    ->post_link_name)
   IF (dhb_ind < 0)
    SET drdm_chg->log[sbr_log_pos].chg_log_reason_txt = dm_err->emsg
    RETURN("NOMV99")
   ELSEIF (dhb_ind=0)
    RETURN("NO SRC")
   ENDIF
   IF (dhb_vers_id > 0)
    SET dm_err->eproc = "Gathering pkw_vers template."
    SELECT INTO "nl:"
     FROM (parser(dhb_vers_tab_name) d)
     WHERE d.dm_refchg_pkw_vers_id=dhb_vers_id
     DETAIL
      dhb_vers_template = d.pkw_format
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET drdm_chg->log[sbr_log_pos].chg_log_reason_txt = dm_err->emsg
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN("NOMV99")
    ENDIF
   ENDIF
   SET dhb_request->table_name = dhb_tab_name
   SET dhb_request->pk_string = dhb_vers_template
   SET dm_err->eproc = "Calling dm_rmc_correct_pk_hash to compare pk_where templates."
   EXECUTE dm_rmc_correct_pk_hash  WITH replace("DRC_REQUEST","DHB_REQUEST"), replace("DRC_REPLY",
    "DHB_REPLY")
   IF ((dhb_reply->status="S"))
    SET dhb_dcl_tab_name = dm2_get_rdds_tname("DM_CHG_LOG")
    SET drdm_chg->log[sbr_log_pos].pk_where_hash = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].
    pk_where_hash
    CALL drmm_get_ptam_match_query(0.0,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].table_name,
     dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].suffix,dm2_ref_data_doc->post_link_name)
    IF ((dm_err->err_ind=1))
     SET drdm_chg->log[sbr_log_pos].chg_log_reason_txt = dm_err->emsg
     RETURN("NOMV99")
    ENDIF
    SET dhb_ptam_result = drmm_get_ptam_match_result(0.0,0.0,0.0," ",1,
     "FROM")
    IF (dhb_ptam_result <= 0)
     SET drdm_chg->log[sbr_log_pos].chg_log_reason_txt =
     "Incorrect PTAM_MATCH_RESULT returned during backfill."
     RETURN("NOMV99")
    ENDIF
    SET drdm_chg->log[sbr_log_pos].ptam_match_result = dhb_ptam_result
    SET drdm_chg->log[sbr_log_pos].ptam_match_hash = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].
    ptam_match_hash
    DECLARE sys_context() = c4000
    SET dm_err->eproc = "Updating row with new PTAM values."
    CALL parser(concat(^RDB ASIS("BEGIN dm_update_dcl('^,dm2_ref_data_doc->post_link_name,^', ")^),0)
    CALL parser(build('ASIS("',drdm_chg->log[sbr_log_pos].log_id,
      ^,sys_context('CERNER','RDDS_COL_STRING',4000),sys_context('CERNER','RDDS_PTAM_MATCH_QUERY',2000),")^
      ),0)
    CALL parser(build('ASIS("',dhb_ptam_result,",",drdm_chg->log[sbr_log_pos].pk_where_hash,",",
      drdm_chg->log[sbr_log_pos].ptam_match_hash,'); END; ") go'),1)
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     SET drdm_chg->log[sbr_log_pos].chg_log_reason_txt = dm_err->emsg
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN("NOMV99")
    ENDIF
   ELSEIF (check_error(dm_err->eproc)=0)
    DECLARE sys_context() = c4000
    SET dm_err->eproc = "Updating row with col_string value."
    CALL parser(concat(^RDB ASIS("BEGIN dm_update_dcl('^,dm2_ref_data_doc->post_link_name,^', ")^),0)
    CALL parser(build('ASIS("',drdm_chg->log[sbr_log_pos].log_id,
      ^,sys_context('CERNER','RDDS_COL_STRING',4000),null,0.0,0.0,0.0); END; ") go^),1)
    IF (check_error(dm_err->eproc)=1)
     ROLLBACK
     SET drdm_chg->log[sbr_log_pos].chg_log_reason_txt = dm_err->emsg
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN("NOMV99")
    ENDIF
   ELSE
    SET drdm_chg->log[sbr_log_pos].chg_log_reason_txt = dhb_reply->err_msg
    RETURN("NOMV99")
   ENDIF
   COMMIT
   RETURN("")
 END ;Subroutine
 SUBROUTINE drmm_upd_dmt_status_flg(sbr_dead_ind)
   IF (sbr_dead_ind=1)
    UPDATE  FROM dm_merge_translate dmt
     SET dmt.status_flg = (dmt.status_flg - 100)
     WHERE dmt.status_flg >= 100
      AND  NOT (dmt.updt_applctx IN (
     (SELECT
      cnvtreal(audsid)
      FROM gv$session)))
     WITH nocounter
    ;end update
   ELSE
    UPDATE  FROM dm_merge_translate dmt
     SET dmt.status_flg = (dmt.status_flg - 100)
     WHERE dmt.status_flg >= 100
      AND dmt.updt_applctx=cnvtreal(currdbhandle)
     WITH nocounter
    ;end update
   ENDIF
   IF (check_error("Updating status of commited translations") != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    ROLLBACK
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drmm_get_context_name(dgcn_src_ctxt)
   DECLARE dgcn_ctxt_name = vc
   IF (trim(dgcn_src_ctxt) <= " "
    AND (global_mover_rec->context_ind=0))
    SET dgcn_ctxt_name = global_mover_rec->default_ctxt
   ELSEIF ((global_mover_rec->context_ind=1))
    SET dgcn_ctxt_name = global_mover_rec->ctxt_to_set
   ELSE
    SET dgcn_ctxt_name = dgcn_src_ctxt
   ENDIF
   RETURN(dgcn_ctxt_name)
 END ;Subroutine
 SUBROUTINE drmm_check_vers_pk(dcvp_tab_name,dcvp_col_name,dcvp_pk_val,dcvp_data_doc)
   DECLARE dcvp_ret = i2 WITH protect, noconstant(0)
   DECLARE dcvp_ui_list = vc WITH protect, noconstant(" ")
   DECLARE dcvp_tab_pos = i4 WITH protect, noconstant(0)
   DECLARE dcvp_idx = i4 WITH protect, noconstant(0)
   DECLARE dcvp_s_tab_name = vc WITH protect, noconstant(" ")
   DECLARE dcvp_updt_pos = i4 WITH protect, noconstant(0)
   DECLARE dcvp_curqual = i4 WITH protect, noconstant(0)
   FREE RECORD dcvp_str
   RECORD dcvp_str(
     1 cnt = i4
     1 qual[*]
       2 vers_str = vc
       2 order_by_str = vc
       2 with_str = vc
       2 query_ind = i2
   )
   SET dcvp_tab_pos = locateval(dcvp_idx,1,dcvp_data_doc->tbl_cnt,dcvp_tab_name,dcvp_data_doc->
    tbl_qual[dcvp_idx].table_name)
   SET dcvp_s_tab_name = dm2_get_rdds_tname(dcvp_tab_name)
   SET dcvp_pk_str = concat(" a.",dcvp_col_name," = dcvp_pk_val ")
   SET dcvp_updt_pos = locateval(dcvp_idx,1,dcvp_data_doc->tbl_qual[dcvp_tab_pos].col_cnt,
    "UPDT_DT_TM",dcvp_data_doc->tbl_qual[dcvp_tab_pos].col_qual[dcvp_idx].column_name)
   SET dcvp_ui_list = ""
   FOR (dcvp_idx = 1 TO dcvp_data_doc->tbl_qual[dcvp_tab_pos].col_cnt)
     IF ((((dcvp_data_doc->tbl_qual[dcvp_tab_pos].col_qual[dcvp_idx].unique_ident_ind=1)
      AND  NOT ((dcvp_data_doc->tbl_qual[dcvp_tab_pos].version_type IN ("ALG5", "ALG7")))) OR ((
     dcvp_data_doc->tbl_qual[dcvp_tab_pos].version_type IN ("ALG5", "ALG7"))
      AND (dcvp_data_doc->tbl_qual[dcvp_tab_pos].col_qual[dcvp_idx].exception_flg=12))) )
      IF ((dcvp_data_doc->tbl_qual[dcvp_tab_pos].col_qual[dcvp_idx].db_data_type IN ("NUMBER",
      "FLOAT")))
       IF ((dcvp_data_doc->tbl_qual[dcvp_tab_pos].col_qual[dcvp_idx].data_type="F*"))
        SET amx_null_str = "-123888.4321"
       ELSEIF ((dcvp_data_doc->tbl_qual[dcvp_tab_pos].col_qual[dcvp_idx].data_type="I*"))
        SET amx_null_str = "-123888"
       ENDIF
      ELSEIF ((dcvp_data_doc->tbl_qual[dcvp_tab_pos].col_qual[dcvp_idx].db_data_type="DATE"))
       SET amx_null_str = "cnvtdatetime(cnvtdate(07231882),215212)"
      ELSE
       SET amx_null_str = "'null_vaLue_CHeck_894.3'"
      ENDIF
      IF (size(dcvp_ui_list,1) > 1)
       SET dcvp_ui_list = concat(dcvp_ui_list,",nullval(<alias>.",dcvp_data_doc->tbl_qual[
        dcvp_tab_pos].col_qual[dcvp_idx].column_name,",",amx_null_str,
        ")")
      ELSE
       SET dcvp_ui_list = concat("nullval(<alias>.",dcvp_data_doc->tbl_qual[dcvp_tab_pos].col_qual[
        dcvp_idx].column_name,",",amx_null_str,")")
      ENDIF
     ENDIF
   ENDFOR
   CASE (dcvp_data_doc->tbl_qual[dcvp_tab_pos].version_type)
    OF "ALG1":
    OF "ALG3":
     SET dcvp_str->cnt = (dcvp_str->cnt+ 1)
     SET stat = alterlist(dcvp_str->qual,dcvp_str->cnt)
     SET dcvp_str->qual[dcvp_str->cnt].vers_str = " a.active_ind = 1 "
     SET dcvp_str->qual[dcvp_str->cnt].with_str = " with nocounter go"
     SET dcvp_str->qual[dcvp_str->cnt].query_ind = 1
     IF ((dcvp_data_doc->tbl_qual[dcvp_tab_pos].effective_col_ind=1))
      SET dcvp_str->cnt = (dcvp_str->cnt+ 1)
      SET stat = alterlist(dcvp_str->qual,dcvp_str->cnt)
      SET dcvp_str->qual[dcvp_str->cnt].vers_str = concat(" a.",dcvp_data_doc->tbl_qual[dcvp_tab_pos]
       .beg_col_name," <= cnvtdatetime(curdate,curtime3) and a.",dcvp_data_doc->tbl_qual[dcvp_tab_pos
       ].end_col_name," >= cnvtdatetime(curdate,curtime3)")
      SET dcvp_str->qual[dcvp_str->cnt].with_str = " with nocounter go"
     ENDIF
     IF (dcvp_updt_pos > 0)
      SET dcvp_str->cnt = (dcvp_str->cnt+ 1)
      SET stat = alterlist(dcvp_str->qual,dcvp_str->cnt)
      SET dcvp_str->qual[dcvp_str->cnt].vers_str = " "
      SET dcvp_str->qual[dcvp_str->cnt].order_by_str = " order by updt_dt_tm desc "
      SET dcvp_str->qual[dcvp_str->cnt].with_str = "with maxrec=1, nocounter go"
     ENDIF
    OF "ALG5":
     SET dcvp_str->cnt = (dcvp_str->cnt+ 1)
     SET stat = alterlist(dcvp_str->qual,dcvp_str->cnt)
     SET dcvp_str->qual[dcvp_str->cnt].vers_str = concat(" a.",dcvp_data_doc->tbl_qual[dcvp_tab_pos].
      beg_col_name," <= cnvtdatetime(curdate,curtime3) and a.",dcvp_data_doc->tbl_qual[dcvp_tab_pos].
      end_col_name," >= cnvtdatetime(curdate,curtime3)")
     SET dcvp_str->qual[dcvp_str->cnt].with_str = " with nocounter go"
     SET dcvp_str->qual[dcvp_str->cnt].query_ind = 1
    OF "ALG6":
    OF "ALG7":
     IF ((dcvp_data_doc->tbl_qual[dcvp_tab_pos].effective_col_ind=0))
      SET dcvp_str->cnt = (dcvp_str->cnt+ 1)
      SET stat = alterlist(dcvp_str->qual,dcvp_str->cnt)
      SET dcvp_str->qual[dcvp_str->cnt].vers_str = " a.active_ind = 1 "
      SET dcvp_str->qual[dcvp_str->cnt].with_str = " with nocounter go"
      SET dcvp_str->qual[dcvp_str->cnt].query_ind = 1
      IF (dcvp_updt_pos > 0)
       SET dcvp_str->cnt = (dcvp_str->cnt+ 1)
       SET stat = alterlist(dcvp_str->qual,dcvp_str->cnt)
       SET dcvp_str->qual[dcvp_str->cnt].vers_str = " "
       SET dcvp_str->qual[dcvp_str->cnt].order_by_str = " order by updt_dt_tm desc "
       SET dcvp_str->qual[dcvp_str->cnt].with_str = "with maxrec=1, nocounter go"
      ENDIF
     ELSE
      SET dcvp_str->cnt = (dcvp_str->cnt+ 1)
      SET stat = alterlist(dcvp_str->qual,dcvp_str->cnt)
      SET dcvp_str->qual[dcvp_str->cnt].vers_str = concat(" a.active_ind = 1 and a.",dcvp_data_doc->
       tbl_qual[dcvp_tab_pos].beg_col_name," <= cnvtdatetime(curdate,curtime3) and a.",dcvp_data_doc
       ->tbl_qual[dcvp_tab_pos].end_col_name," >= cnvtdatetime(curdate,curtime3)")
      SET dcvp_str->qual[dcvp_str->cnt].with_str = " with nocounter go"
      SET dcvp_str->qual[dcvp_str->cnt].query_ind = 1
      SET dcvp_str->cnt = (dcvp_str->cnt+ 1)
      SET stat = alterlist(dcvp_str->qual,dcvp_str->cnt)
      SET dcvp_str->qual[dcvp_str->cnt].vers_str = concat(" a.active_ind = 1 and a.",dcvp_data_doc->
       tbl_qual[dcvp_tab_pos].end_col_name," < cnvtdatetime(curdate,curtime3)")
      SET dcvp_str->qual[dcvp_str->cnt].order_by_str = concat(" order by ",dcvp_data_doc->tbl_qual[
       dcvp_tab_pos].end_col_name," desc")
      SET dcvp_str->qual[dcvp_str->cnt].with_str = " with maxrec = 1, nocounter go"
      SET dcvp_str->cnt = (dcvp_str->cnt+ 1)
      SET stat = alterlist(dcvp_str->qual,dcvp_str->cnt)
      SET dcvp_str->qual[dcvp_str->cnt].vers_str = concat(" a.active_ind = 0 and a.",dcvp_data_doc->
       tbl_qual[dcvp_tab_pos].beg_col_name," <= cnvtdatetime(curdate,curtime3) and a.",dcvp_data_doc
       ->tbl_qual[dcvp_tab_pos].end_col_name," >= cnvtdatetime(curdate,curtime3)")
      IF ((dcvp_data_doc->tbl_qual[dcvp_tab_pos].version_type="ALG7"))
       SET dcvp_str->qual[dcvp_str->cnt].order_by_str = concat(" order by ",dcvp_data_doc->tbl_qual[
        dcvp_tab_pos].beg_col_name," desc")
       SET dcvp_str->qual[dcvp_str->cnt].with_str = " with maxrec = 1, nocounter go"
      ELSE
       SET dcvp_str->qual[dcvp_str->cnt].with_str = " with nocounter go"
      ENDIF
      SET dcvp_str->cnt = (dcvp_str->cnt+ 1)
      SET stat = alterlist(dcvp_str->qual,dcvp_str->cnt)
      SET dcvp_str->qual[dcvp_str->cnt].vers_str = concat(" a.active_ind = 0 and a.",dcvp_data_doc->
       tbl_qual[dcvp_tab_pos].end_col_name," < cnvtdatetime(curdate,curtime3)")
      SET dcvp_str->qual[dcvp_str->cnt].order_by_str = concat(" order by ",dcvp_data_doc->tbl_qual[
       dcvp_tab_pos].end_col_name," desc")
      SET dcvp_str->qual[dcvp_str->cnt].with_str = " with maxrec = 1, nocounter go"
      SET dcvp_str->cnt = (dcvp_str->cnt+ 1)
      SET stat = alterlist(dcvp_str->qual,dcvp_str->cnt)
      SET dcvp_str->qual[dcvp_str->cnt].vers_str = concat(" a.active_ind = 1 and a.",dcvp_data_doc->
       tbl_qual[dcvp_tab_pos].beg_col_name," > cnvtdatetime(curdate,curtime3)")
      SET dcvp_str->qual[dcvp_str->cnt].with_str = " with nocounter go"
      SET dcvp_str->qual[dcvp_str->cnt].query_ind = 1
      SET dcvp_str->cnt = (dcvp_str->cnt+ 1)
      SET stat = alterlist(dcvp_str->qual,dcvp_str->cnt)
      SET dcvp_str->qual[dcvp_str->cnt].vers_str = concat(" a.active_ind = 0 and a.",dcvp_data_doc->
       tbl_qual[dcvp_tab_pos].beg_col_name," > cnvtdatetime(curdate,curtime3)")
      SET dcvp_str->qual[dcvp_str->cnt].order_by_str = concat(" order by ",dcvp_data_doc->tbl_qual[
       dcvp_tab_pos].beg_col_name," asc")
      SET dcvp_str->qual[dcvp_str->cnt].with_str = " with maxrec = 1, nocounter go"
     ENDIF
   ENDCASE
   FOR (dcvp_idx = 1 TO dcvp_str->cnt)
     IF (((dcvp_curqual=0) OR ((dcvp_str->qual[dcvp_idx].query_ind=1))) )
      CALL parser(concat("select into 'nl:' from ",dcvp_s_tab_name," a where "),0)
      IF ((dm2_ref_data_doc->tbl_qual[amx_tab_pos].filter_string > " "))
       CALL parser(concat(replace(replace(dm2_ref_data_doc->tbl_qual[amx_tab_pos].filter_string,
           "<SUFFIX>","a",0),"<MERGE LINK>",dm2_ref_data_doc->post_link_name,0)," and "),0)
      ENDIF
      IF ((dcvp_str->qual[dcvp_idx].vers_str > " "))
       CALL parser(concat(dcvp_str->qual[dcvp_idx].vers_str," and "))
      ENDIF
      CALL parser(concat(" list(",replace(dcvp_ui_list,"<alias>","a",0),") in "),0)
      CALL parser(concat("(select ",replace(dcvp_ui_list,"<alias>","b",0)," from ",dcvp_s_tab_name,
        " b where "),0)
      CALL parser(replace(dcvp_pk_str,"a.","b.",0),0)
      CALL parser(")",0)
      IF ((dcvp_str->qual[dcvp_idx].order_by_str > " "))
       CALL parser(dcvp_str->qual[dcvp_idx].order_by_str,0)
      ENDIF
      CALL parser(concat(" detail if(",dcvp_pk_str,") dcvp_ret = 1 endif"),0)
      CALL parser(dcvp_str->qual[dcvp_idx].with_str,1)
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
     IF (dcvp_curqual=0)
      SET dcvp_curqual = curqual
     ENDIF
     IF (dcvp_ret=1)
      SET dcvp_idx = dcvp_str->cnt
     ENDIF
   ENDFOR
   RETURN(dcvp_ret)
 END ;Subroutine
#done
 IF (drdm_debug_row_ind=0)
  UPDATE  FROM dm_info d
   SET d.info_number = 1, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WHERE d.info_domain="DATA MANAGEMENT"
    AND d.info_name=drdm_info_name
   WITH nocounter
  ;end update
  COMMIT
 ENDIF
#exit_main
 IF (drmm_upd_dmt_status_flg(1) != 1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
 ENDIF
 EXECUTE dm2_set_context "FIRE_REFCHG_TRG_MVR", "YES"
 EXECUTE dm2_set_context "RDDS_CONTEXT", "NULL"
 CALL delete_tracking_row(null)
 IF (drmm_start_ind=1)
  SET stat = alterlist(auto_ver_request->qual,1)
  SET auto_ver_request->qual[1].rdds_event = "Stopping RDDS Mover"
  SET auto_ver_request->qual[1].cur_environment_id = dm2_ref_data_doc->env_target_id
  SET auto_ver_request->qual[1].paired_environment_id = dm2_ref_data_doc->env_source_id
  SET stat = alterlist(auto_ver_request->qual[1].detail_qual,2)
  SET auto_ver_request->qual[1].detail_qual[1].event_detail1_txt = "PROCESS"
  SET auto_ver_request->qual[1].detail_qual[1].event_detail2_txt = drmm_cur_process
  SET auto_ver_request->qual[1].detail_qual[2].event_detail1_txt = "Session Row Count"
  SET auto_ver_request->qual[1].detail_qual[2].event_detail2_txt = cnvtstring(global_mover_rec->
   refchg_upd_cnt)
  IF (drdm_stop_time < drdm_start_time)
   SET stat = alterlist(auto_ver_request->qual[1].detail_qual,3)
   SET auto_ver_request->qual[1].detail_qual[3].event_detail1_txt = "Logfile"
   SET auto_ver_request->qual[1].detail_qual[3].event_detail2_txt = dm_err->logfile
  ENDIF
  EXECUTE dm_rmc_auto_verify_setup
  IF ((auto_ver_reply->status="F"))
   CALL disp_msg("Adding event to dm_rdds_event_log",dm_err->logfile,1)
   SET stat = initrec(auto_ver_request)
   SET stat = initrec(auto_ver_reply)
  ELSE
   COMMIT
   SET stat = initrec(auto_ver_request)
   SET stat = initrec(auto_ver_reply)
  ENDIF
 ENDIF
 IF (drmm_client_ident > " ")
  CALL dci_set_rdds_identifier(drmm_client_ident)
 ENDIF
 IF ((dm_err->err_ind=0)
  AND drmm_rows_processed_ind=0
  AND drdm_debug_row_ind=0
  AND (dm_err->logfile="dm_rmc_mover*"))
  SET stat = remove(dm_err->logfile)
 ENDIF
END GO
