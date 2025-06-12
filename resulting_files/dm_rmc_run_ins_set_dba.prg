CREATE PROGRAM dm_rmc_run_ins_set:dba
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
 IF (check_logfile("dm_rmc_run_ins",".log","dm_rmc_run_ins_set LOG FILE...") != 1)
  SET dm_err->err_ind = 1
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_run
 ENDIF
 DECLARE drris_file_name = vc WITH protect, noconstant("")
 DECLARE drris_output_file = vc WITH protect, noconstant("")
 DECLARE drris_id_val = f8 WITH protect, noconstant(0.0)
 DECLARE drris_long_data = vc WITH protect, noconstant("")
 DECLARE drris_break_pos = i4 WITH protect, noconstant(0)
 DECLARE drris_done_ind = i2 WITH protect, noconstant(0)
 DECLARE drris_loop = i4 WITH protect, noconstant(0)
 DECLARE drris_where_clause = vc WITH protect, noconstant("")
 DECLARE drris_error_ind = i2 WITH protect, noconstant(0)
 DECLARE drris_error_msg = vc WITH protect, noconstant("")
 DECLARE drris_tgt_id = f8 WITH protect, noconstant(0.0)
 DECLARE drris_src_id = f8 WITH protect, noconstant(0.0)
 DECLARE drris_db_link = vc WITH protect, noconstant("")
 DECLARE drris_schema_ind = i2 WITH protect, noconstant(0)
 DECLARE drris_detail_cnt = i4 WITH protect, noconstant(0)
 DECLARE drris_info_temp = vc WITH protect, noconstant("")
 DECLARE drris_temp_pos = i4 WITH protect, noconstant(0)
 DECLARE drris_temp_nbr = i4 WITH protect, noconstant(0)
 DECLARE drris_msg = vc WITH protect, noconstant("")
 DECLARE drris_check_schema(dcs_data=vc,dcs_db_link=vc,dcs_msg=vc(ref)) = i2
 FREE RECORD drris_ins
 RECORD drris_ins(
   1 cnt = i4
   1 qual[*]
     2 line = vc
 ) WITH protect
 FREE RECORD ins_set_info
 RECORD ins_set_info(
   1 info_str = vc
 ) WITH protect
 SET modify maxvarlen 268435456
 SET dm_err->eproc = "Starting DM_RMC_RUN_INS_SET..."
 SET dm_run_reply->log_file = "N/A"
 IF ((dm_run_request->ins_meaning <= " "))
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "There was no INS_MEANING value filled out in the dm_run_request structure."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_run
 ENDIF
 SET dm_run_reply->ins_meaning = dm_run_request->ins_meaning
 IF ((dm_run_request->where_clause <= " "))
  SET drris_where_clause = " 1 = 1 "
 ELSE
  SET drris_where_clause = dm_run_request->where_clause
 ENDIF
 SET dm_err->eproc = "Getting LONG data for instruction set"
 SELECT INTO "NL:"
  FROM long_text_reference l,
   dm_refchg_instruction i
  WHERE (i.ins_meaning=dm_run_request->ins_meaning)
   AND i.instruction_text_id > 0.0
   AND l.long_text_id=i.instruction_text_id
  HEAD REPORT
   outbuf = fillstring(32767," "), offset = 0, retlen = 0
  DETAIL
   drris_id_val = i.dm_refchg_instruction_id, retlen = blobget(outbuf,offset,l.long_text),
   drris_long_data = " "
   WHILE (retlen > 0)
     IF (drris_long_data=" ")
      drris_long_data = notrim(outbuf)
     ELSE
      drris_long_data = notrim(concat(notrim(drris_long_data),notrim(substring(1,retlen,outbuf))))
     ENDIF
     offset = (offset+ retlen), retlen = blobget(outbuf,offset,l.long_text)
   ENDWHILE
   drris_long_data = trim(drris_long_data,5)
  WITH nocounter, rdbarrayfetch = 1
 ;end select
 IF (check_error(dm_err->eproc) != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_run
 ENDIF
 IF (curqual=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat("No LONG_TEXT_REFERENCE data was found for INS_MEANING = '",
   dm_run_request->ins_meaning,"'.")
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_run
 ENDIF
 SET dm_err->eproc = "Gather environment information"
 SELECT INTO "NL:"
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="DM_ENV_ID"
  DETAIL
   drris_tgt_id = d.info_number
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc) != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_run
 ENDIF
 IF (curqual=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "No enviornment_id found, please run DM_SET_ENV_ID"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_run
 ENDIF
 SELECT INTO "NL:"
  FROM dm_rdds_event_log d
  WHERE d.cur_environment_id=drris_tgt_id
   AND d.rdds_event_key="BEGINREFERENCEDATASYNC"
   AND  NOT (list(d.paired_environment_id,d.event_reason) IN (
  (SELECT
   paired_environment_id, event_reason
   FROM dm_rdds_event_log
   WHERE cur_environment_id=drris_tgt_id
    AND rdds_event_key="ENDREFERENCEDATASYNC")))
  DETAIL
   drris_src_id = d.paired_environment_id
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc) != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_run
 ENDIF
 IF (curqual != 0)
  SELECT INTO "NL:"
   FROM dm_env_reltn d
   WHERE d.parent_env_id=drris_src_id
    AND d.child_env_id=drris_tgt_id
    AND d.relationship_type="REFERENCE MERGE"
    AND d.post_link_name > " "
   DETAIL
    drris_db_link = d.post_link_name
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc) != 0)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_run
  ENDIF
 ENDIF
 SET dm_err->eproc = "Check for schema requirements"
 SET drris_schema_ind = drris_check_schema(drris_long_data,drris_db_link,drris_msg)
 IF (check_error(dm_err->eproc) != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
 ELSE
  IF (drris_schema_ind=0)
   SET dm_run_reply->status = "Z"
   SET dm_run_reply->status_msg = drris_msg
   GO TO exit_run
  ENDIF
 ENDIF
 IF ((dm_err->err_ind=0))
  SET dm_err->eproc = "Moving LONG value to record structure so it can be written to file easier"
  WHILE (drris_done_ind=0)
   SET drris_break_pos = findstring(char(10),drris_long_data,1,0)
   IF (drris_break_pos > 0)
    SET drris_ins->cnt = (drris_ins->cnt+ 1)
    SET stat = alterlist(drris_ins->qual,drris_ins->cnt)
    SET drris_ins->qual[drris_ins->cnt].line = substring(1,(drris_break_pos - 1),drris_long_data)
    SET drris_long_data = substring((drris_break_pos+ 1),size(drris_long_data),drris_long_data)
   ELSE
    SET drris_ins->cnt = (drris_ins->cnt+ 1)
    SET stat = alterlist(drris_ins->qual,drris_ins->cnt)
    SET drris_ins->qual[drris_ins->cnt].line = drris_long_data
    SET drris_long_data = substring((drris_break_pos+ 1),size(drris_long_data),drris_long_data)
    SET drris_done_ind = 1
   ENDIF
  ENDWHILE
  FOR (drris_loop = 1 TO drris_ins->cnt)
   IF ((dm_run_request->diagnostic_ind=1))
    IF (findstring("COMMIT",cnvtupper(drris_ins->qual[drris_loop].line),1,0) > 0)
     SET drris_ins->qual[drris_loop].line = replace(cnvtupper(drris_ins->qual[drris_loop].line),
      "COMMIT",";",0)
    ENDIF
   ENDIF
   SET drris_ins->qual[drris_loop].line = replace(drris_ins->qual[drris_loop].line,
    "<RDDS_WHERE_CLAUSE>",drris_where_clause,0)
  ENDFOR
  SET dm_err->eproc = "Getting unique file name, and writing instructions to file."
  SET drris_file_name = substring(1,26,concat("temp_",trim(cnvtstring(drris_id_val,20)),trim(
     currdbhandle)))
  SET drris_output_file = concat(drris_file_name,".log")
  SET dm_run_reply->log_file = drris_output_file
  SET drris_file_name = concat(drris_file_name,".inc")
  SET stat = remove(value(drris_file_name))
  SELECT INTO value(drris_file_name)
   FROM dual
   DETAIL
    FOR (drris_loop = 1 TO drris_ins->cnt)
     drris_ins->qual[drris_loop].line,row + 1
    ENDFOR
   WITH nocounter, nullreport, format = variable,
    maxrow = 1, maxcol = 132, formfeed = none
  ;end select
  IF (check_error(dm_err->eproc) != 0)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_run
  ENDIF
  SET dm_err->eproc = "Including instruction set"
  CALL compile(value(drris_file_name),value(drris_output_file),1)
 ENDIF
 IF (check_error(dm_err->eproc) != 0)
  ROLLBACK
  SET drris_error_ind = 1
  SET drris_error_msg = dm_err->emsg
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET dm_err->err_ind = 0
  SET stat = alterlist(auto_ver_request->qual,1)
  SET auto_ver_request->qual[1].rdds_event = "Instruction Set Run Failed"
  SET auto_ver_request->qual[1].cur_environment_id = drris_tgt_id
  SET auto_ver_request->qual[1].paired_environment_id = drris_src_id
  SET auto_ver_request->qual[1].event_reason = dm_run_request->ins_meaning
  SET drris_detail_cnt = (drris_detail_cnt+ 1)
  SET stat = alterlist(auto_ver_request->qual[1].detail_qual,drris_detail_cnt)
  SET auto_ver_request->qual[1].detail_qual[drris_detail_cnt].event_detail1_txt = drris_output_file
  SET auto_ver_request->qual[1].detail_qual[drris_detail_cnt].event_detail3_txt = drris_error_msg
 ELSE
  SET stat = alterlist(auto_ver_request->qual,1)
  SET auto_ver_request->qual[1].rdds_event = "Instruction Set Run Success"
  SET auto_ver_request->qual[1].cur_environment_id = drris_tgt_id
  SET auto_ver_request->qual[1].paired_environment_id = drris_src_id
  SET auto_ver_request->qual[1].event_reason = dm_run_request->ins_meaning
 ENDIF
 IF ((dm_run_request->diagnostic_ind=1))
  SET drris_detail_cnt = (drris_detail_cnt+ 1)
  SET stat = alterlist(auto_ver_request->qual[1].detail_qual,drris_detail_cnt)
  SET auto_ver_request->qual[1].detail_qual[drris_detail_cnt].event_detail1_txt = "DIAGNOSTIC MODE"
 ENDIF
 IF ((ins_set_info->info_str > " "))
  IF (size(ins_set_info->info_str) > 500)
   WHILE (size(ins_set_info->info_str) > 500)
     SET drris_info_temp = substring(1,500,ins_set_info->info_str)
     SET drris_temp_pos = findstring(" ",drris_info_temp,1,1)
     IF (drris_temp_pos > 0)
      SET drris_temp_nbr = (drris_temp_nbr+ 1)
      SET drris_detail_cnt = (drris_detail_cnt+ 1)
      SET stat = alterlist(auto_ver_request->qual[1].detail_qual,drris_detail_cnt)
      SET auto_ver_request->qual[1].detail_qual[drris_detail_cnt].event_detail1_txt = "INS_SET_INFO"
      SET auto_ver_request->qual[1].detail_qual[drris_detail_cnt].event_value = drris_temp_nbr
      SET auto_ver_request->qual[1].detail_qual[drris_detail_cnt].event_detail3_txt = substring(1,(
       drris_temp_pos - 1),drris_info_temp)
      SET ins_set_info->info_str = substring((drris_temp_pos+ 1),size(ins_set_info->info_str),
       ins_set_info->info_str)
      IF ((dm_run_request->diagnostic_ind=1))
       CALL echo(auto_ver_request->qual[1].detail_qual[drris_detail_cnt].event_detail3_txt)
      ENDIF
     ELSE
      SET drris_temp_nbr = (drris_temp_nbr+ 1)
      SET drris_detail_cnt = (drris_detail_cnt+ 1)
      SET stat = alterlist(auto_ver_request->qual[1].detail_qual,drris_detail_cnt)
      SET auto_ver_request->qual[1].detail_qual[drris_detail_cnt].event_detail1_txt = "INS_SET_INFO"
      SET auto_ver_request->qual[1].detail_qual[drris_detail_cnt].event_value = drris_temp_nbr
      SET auto_ver_request->qual[1].detail_qual[drris_detail_cnt].event_detail3_txt = drris_info_temp
      SET ins_set_info->info_str = substring(501,size(ins_set_info->info_str),ins_set_info->info_str)
      IF ((dm_run_request->diagnostic_ind=1))
       CALL echo(auto_ver_request->qual[1].detail_qual[drris_detail_cnt].event_detail3_txt)
      ENDIF
     ENDIF
   ENDWHILE
   SET drris_temp_nbr = (drris_temp_nbr+ 1)
   SET drris_detail_cnt = (drris_detail_cnt+ 1)
   SET stat = alterlist(auto_ver_request->qual[1].detail_qual,drris_detail_cnt)
   SET auto_ver_request->qual[1].detail_qual[drris_detail_cnt].event_detail1_txt = "INS_SET_INFO"
   SET auto_ver_request->qual[1].detail_qual[drris_detail_cnt].event_value = drris_temp_nbr
   SET auto_ver_request->qual[1].detail_qual[drris_detail_cnt].event_detail3_txt = ins_set_info->
   info_str
   IF ((dm_run_request->diagnostic_ind=1))
    CALL echo(auto_ver_request->qual[1].detail_qual[drris_detail_cnt].event_detail3_txt)
   ENDIF
  ELSE
   SET drris_detail_cnt = (drris_detail_cnt+ 1)
   SET stat = alterlist(auto_ver_request->qual[1].detail_qual,drris_detail_cnt)
   SET auto_ver_request->qual[1].detail_qual[drris_detail_cnt].event_detail1_txt = "INS_SET_INFO"
   SET auto_ver_request->qual[1].detail_qual[drris_detail_cnt].event_detail3_txt = ins_set_info->
   info_str
   SET auto_ver_request->qual[1].detail_qual[drris_detail_cnt].event_value = 1
   IF ((dm_run_request->diagnostic_ind=1))
    CALL echo(auto_ver_request->qual[1].detail_qual[drris_detail_cnt].event_detail3_txt)
   ENDIF
  ENDIF
 ENDIF
 EXECUTE dm_rmc_auto_verify_setup
 IF ((auto_ver_reply->status="F"))
  ROLLBACK
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET stat = initrec(auto_ver_request)
  SET stat = initrec(auto_ver_reply)
  SET dm_err->err_ind = 1
  GO TO exit_run
 ELSE
  IF ((dm_run_request->diagnostic_ind=0))
   COMMIT
  ENDIF
  SET stat = initrec(auto_ver_request)
  SET stat = initrec(auto_ver_reply)
 ENDIF
 SUBROUTINE drris_check_schema(dcs_data,dcs_db_link,dcs_msg)
   DECLARE dcs_loop = i4 WITH protect, noconstant(0)
   DECLARE dcs_start_pos = i4 WITH protect, noconstant(0)
   DECLARE dcs_stop_pos = i4 WITH protect, noconstant(0)
   DECLARE dcs_temp_pos = i4 WITH protect, noconstant(0)
   DECLARE dcs_temp = vc WITH protect, noconstant("")
   DECLARE dcs_start_tag = vc WITH protect, noconstant("/*<SCHEMA_CHECK>")
   DECLARE dcs_stop_tag = vc WITH protect, noconstant("</SCHEMA_CHECK>*/")
   DECLARE dcs_temp = vc WITH protect, noconstant("")
   DECLARE dcs_return = i2 WITH protect, noconstant(0)
   FREE RECORD dcs_rec
   RECORD dcs_rec(
     1 cnt = i4
     1 qual[*]
       2 table_name = vc
       2 column_name = vc
       2 src_ind = vc
       2 full_str = vc
   ) WITH protect
   SET dcs_temp = replace(dcs_data,char(10),"",0)
   SET dcs_temp_pos = 1
   WHILE (dcs_loop=0)
    SET dcs_start_pos = findstring(dcs_start_tag,cnvtupper(dcs_temp),dcs_temp_pos,0)
    IF (dcs_start_pos > 0)
     SET dcs_stop_pos = findstring(dcs_stop_tag,cnvtupper(dcs_temp),(dcs_start_pos+ 1),0)
     IF (dcs_stop_pos=0)
      SET dcs_loop = 1
      SET dm_err->err_ind = 1
      SET dm_err->emsg = "Could not find value </SCHEMA_CHECK>*/ tag"
      SET dcs_return = 0
     ELSE
      SET dcs_temp_pos = (dcs_start_pos+ 1)
      SET dcs_rec->cnt = (dcs_rec->cnt+ 1)
      SET stat = alterlist(dcs_rec->qual,dcs_rec->cnt)
      SET dcs_rec->qual[dcs_rec->cnt].full_str = substring((dcs_start_pos+ size(dcs_start_tag)),((
       dcs_stop_pos - dcs_start_pos) - size(dcs_start_tag)),dcs_temp)
     ENDIF
    ELSE
     SET dcs_loop = 1
     SET dcs_return = 0
    ENDIF
   ENDWHILE
   IF ((dm_err->err_ind=1))
    RETURN(dcs_return)
   ELSEIF ((dcs_rec->cnt=0))
    RETURN(1)
   ENDIF
   FOR (dcs_loop = 1 TO dcs_rec->cnt)
     SET dcs_start_tag = "<TABLE_NAME>"
     SET dcs_stop_tag = "</TABLE_NAME>"
     SET dcs_start_pos = findstring(dcs_start_tag,cnvtupper(dcs_rec->qual[dcs_loop].full_str),1,0)
     IF (dcs_start_pos > 0)
      SET dcs_stop_pos = findstring(dcs_stop_tag,cnvtupper(dcs_rec->qual[dcs_loop].full_str),(
       dcs_start_pos+ 1),0)
      IF (dcs_stop_pos=0)
       SET dcs_loop = (dcs_rec->cnt+ 1)
       SET dm_err->err_ind = 1
       SET dm_err->emsg = "Could not find value </TABLE_NAME> tag"
       SET dcs_return = 0
      ELSE
       SET dcs_rec->qual[dcs_loop].table_name = substring((dcs_start_pos+ size(dcs_start_tag)),((
        dcs_stop_pos - dcs_start_pos) - size(dcs_start_tag)),dcs_rec->qual[dcs_loop].full_str)
      ENDIF
     ELSE
      SET dcs_loop = (dcs_rec->cnt+ 1)
      SET dm_err->err_ind = 1
      SET dm_err->emsg = "Could not find value <TABLE_NAME> tag"
      SET dcs_return = 0
     ENDIF
     IF ((dm_err->err_ind=0))
      SET dcs_start_tag = "<COLUMN_NAME>"
      SET dcs_stop_tag = "</COLUMN_NAME>"
      SET dcs_start_pos = findstring(dcs_start_tag,cnvtupper(dcs_rec->qual[dcs_loop].full_str),1,0)
      IF (dcs_start_pos > 0)
       SET dcs_stop_pos = findstring(dcs_stop_tag,cnvtupper(dcs_rec->qual[dcs_loop].full_str),(
        dcs_start_pos+ 1),0)
       IF (dcs_stop_pos=0)
        SET dcs_loop = (dcs_rec->cnt+ 1)
        SET dm_err->err_ind = 1
        SET dm_err->emsg = "Could not find value </COLUMN_NAME> tag"
        SET dcs_return = 0
       ELSE
        SET dcs_rec->qual[dcs_loop].column_name = substring((dcs_start_pos+ size(dcs_start_tag)),((
         dcs_stop_pos - dcs_start_pos) - size(dcs_start_tag)),dcs_rec->qual[dcs_loop].full_str)
       ENDIF
      ELSE
       SET dcs_loop = (dcs_rec->cnt+ 1)
       SET dm_err->err_ind = 1
       SET dm_err->emsg = "Could not find value <COLUMN_NAME> tag"
       SET dcs_return = 0
      ENDIF
     ENDIF
     IF ((dm_err->err_ind=0))
      SET dcs_start_tag = "<SOURCE_IND>"
      SET dcs_stop_tag = "</SOURCE_IND>"
      SET dcs_start_pos = findstring(dcs_start_tag,cnvtupper(dcs_rec->qual[dcs_loop].full_str),1,0)
      IF (dcs_start_pos > 0)
       SET dcs_stop_pos = findstring(dcs_stop_tag,cnvtupper(dcs_rec->qual[dcs_loop].full_str),(
        dcs_start_pos+ 1),0)
       IF (dcs_stop_pos=0)
        SET dcs_loop = (dcs_rec->cnt+ 1)
        SET dm_err->err_ind = 1
        SET dm_err->emsg = "Could not find value </SOURCE_IND> tag"
        SET dcs_return = 0
       ELSE
        SET dcs_rec->qual[dcs_loop].src_ind = substring((dcs_start_pos+ size(dcs_start_tag)),((
         dcs_stop_pos - dcs_start_pos) - size(dcs_start_tag)),dcs_rec->qual[dcs_loop].full_str)
       ENDIF
      ELSE
       SET dcs_loop = (dcs_rec->cnt+ 1)
       SET dm_err->err_ind = 1
       SET dm_err->emsg = "Could not find value <SOURCE_IND> tag"
       SET dcs_return = 0
      ENDIF
     ENDIF
   ENDFOR
   IF ((dm_err->err_ind=1))
    RETURN(dcs_return)
   ENDIF
   SET dcs_return = 1
   FOR (dcs_loop = 1 TO dcs_rec->cnt)
     IF ((dcs_rec->qual[dcs_loop].src_ind="1"))
      IF (dcs_db_link <= " ")
       SET dm_err->err_ind = 1
       SET dm_err->emsg =
       "There was no DB_LINK able to be found, and the instruction set requires checking schema in source."
       RETURN(0)
      ENDIF
      SET dcs_temp = dcs_db_link
     ELSE
      SET dcs_temp = ""
     ENDIF
     SELECT INTO "NL:"
      FROM (parser(concat("USER_TAB_COLS",dcs_temp)) d)
      WHERE d.table_name=cnvtupper(dcs_rec->qual[dcs_loop].table_name)
       AND d.column_name=cnvtupper(dcs_rec->qual[dcs_loop].column_name)
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dcs_return = 0
      SET dcs_loop = (dcs_rec->cnt+ 1)
     ENDIF
     IF (curqual=0)
      IF (dcs_msg="")
       SET dcs_msg = "The following schema was not found:"
      ENDIF
      SET dcs_msg = concat(dcs_msg," ",cnvtupper(dcs_rec->qual[dcs_loop].table_name),".",cnvtupper(
        dcs_rec->qual[dcs_loop].column_name))
      IF (dcs_temp > " ")
       SET dcs_msg = concat(dcs_msg," in source.")
      ELSE
       SET dcs_msg = concat(dcs_msg," in target.")
      ENDIF
      SET dcs_return = 0
     ENDIF
   ENDFOR
   RETURN(dcs_return)
 END ;Subroutine
#exit_run
 IF (drris_error_ind=1)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = drris_error_msg
 ENDIF
 IF ((dm_err->err_ind=1))
  SET dm_run_reply->status = "F"
  SET dm_run_reply->status_msg = dm_err->emsg
 ELSEIF ((dm_run_reply->status != "Z"))
  SET dm_run_reply->status = "S"
 ENDIF
END GO
