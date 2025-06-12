CREATE PROGRAM dm2_calc_tspace_needs:dba
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
 DECLARE check_concurrent_snapshot(sbr_ccs_mode=c1) = i2
 DECLARE dir_row_count(rrc_table_name=vc,rrc_row_cnt=f8(ref)) = i2
 DECLARE dm2_get_appl_status(gas_appl_id=vc) = c1
 DECLARE dir_row_count(rrc_table_name=vc,rrc_row_cnt=f8(ref)) = i2
 DECLARE dir_ddl_token_replacement(ddtr_text_str=vc(ref)) = i2
 DECLARE dm2_fill_seq_list(alias=vc,col_name=vc) = vc
 DECLARE dir_add_silmode_entry(entry_name=vc,entry_filename=vc) = i2
 DECLARE dm2_cleanup_stranded_appl() = i2
 DECLARE dir_setup_batch_queue(dsbq_queue_name=vc) = i2
 DECLARE dir_sea_sch_files(directory=vc,file_prefix=vc,schema_date=vc(ref)) = i2
 DECLARE dm2_val_sch_date_str(sbr_datestr=vc) = i2
 DECLARE dm2_fill_sch_except(sbr_dfse_from=vc) = i2
 DECLARE dm2_push_adm_maint(sbr_maint_str=vc) = i2
 DECLARE dm2_setup_dbase_env(null) = i2
 DECLARE dm2_get_suffixed_tablename(tbl_name=vc) = i2
 DECLARE prompt_for_host(sbr_host_db=vc) = i2
 DECLARE dm2_val_file_prefix(sbr_file_prefix=vc) = i2
 DECLARE dm2_toolset_usage(null) = i2
 DECLARE dir_get_obsolete_objects(null) = i2
 DECLARE dir_find_data_file(dfdf_file_found=i2(ref)) = i2
 DECLARE dir_dm2_tables_tspace_assign(null) = i2
 DECLARE dir_get_debug_trace_data(null) = i2
 DECLARE dir_managed_ddl_setup(dmds_runid=f8) = i2
 DECLARE dir_perform_wait_interval(null) = i2
 DECLARE dir_get_storage_type(dgst_db_link=vc) = i2
 DECLARE dir_check_in_parse(dcp_owner=vc,dcp_table_name=vc,dcp_in_parse_ind=i2(ref),dcp_ret_msg=vc(
   ref)) = i2
 DECLARE dir_get_ddl_gen_retry(dgr_retry_ceiling=i2(ref)) = i2
 DECLARE dir_load_users_pwds(dlup_user_pwd=vc) = i2
 DECLARE dir_check_dm_ocd_setup_admin(dcdosa_requires_execution=i2(ref),dcdosa_install_mode=vc) = i2
 DECLARE dir_check_for_package(dcfp_valid_ind=i2(ref),dcfp_env_id=f8(ref)) = i2
 DECLARE dir_get_dg_data(dgdd_assign_dg_ind=i2,dgdd_dg_override=vc,dgdd_dg_out=vc(ref)) = i2
 DECLARE dir_submit_jobs(dsj_plan_id=f8,dsj_install_mode=vc,dsj_user=vc,dsj_pword=vc,dsj_cnnct_str=vc,
  dsj_queue_name=vc,dsj_background_ind=i2) = i2
 DECLARE dir_get_adm_appl_status(dgaps_dblink=vc,dgaps_audsid=vc,dgaps_status=vc(ref)) = i2
 DECLARE dir_upd_adm_upgrade_info(null) = i2
 DECLARE dir_get_custom_constraints(null) = i2
 DECLARE dir_alert_killed_appl(daka_load_ind=i2,daka_fmt_appl_id=vc,daka_kill_ind=i2(ref)) = i2
 DECLARE dir_get_admin_db_link(dgadl_report_fail_ind=i2,dgadl_admin_db_link=vc(ref),dgadl_fail_ind=i2
  (ref)) = i2
 IF (validate(dm2_db_options->lob_build_ind," ")=" ")
  FREE RECORD dm2_db_options
  RECORD dm2_db_options(
    1 load_ind = i2
    1 dm2_toolset_usage = vc
    1 cursor_commit_cnt = vc
    1 new_tspace_type = vc
    1 dmt_freelist_grp = vc
    1 lob_storage_bp = vc
    1 lob_pctversion = vc
    1 lob_build_ind = vc
    1 lob_chunk = vc
    1 lob_cache = vc
    1 lob_securefile_ind = vc
    1 lob_retention = vc
    1 lob_maxsize = vc
    1 table_monitoring = vc
    1 table_monitoring_maxretry = vc
    1 db_optimizer_category = vc
    1 dbstats_gather_method = vc
    1 cbf_maxrangegroups = vc
    1 resource_busy_maxretry = vc
    1 dbstats_chk_rpt = vc
    1 readme_space_calc = vc
    1 recompile_after_alter_tbl = vc
    1 add_nn_col_nobf_ind = vc
    1 create_index_invisible = vc
    1 use_initprm_assign_dg_ind = vc
    1 assign_dg_override = vc
    1 degree_of_parallel_max = vc
    1 degree_of_parallel = vc
  )
  SET dm2_db_options->load_ind = 0
  SET dm2_db_options->dm2_toolset_usage = "NOT_SET"
  SET dm2_db_options->cursor_commit_cnt = "NOT_SET"
  SET dm2_db_options->dmt_freelist_grp = "NOT_SET"
  SET dm2_db_options->lob_pctversion = "NOT_SET"
  SET dm2_db_options->lob_chunk = "NOT_SET"
  SET dm2_db_options->lob_cache = "NOT_SET"
  SET dm2_db_options->lob_build_ind = "NOT_SET"
  SET dm2_db_options->new_tspace_type = "NOT_SET"
  SET dm2_db_options->lob_storage_bp = "NOT_SET"
  SET dm2_db_options->table_monitoring = "NOT_SET"
  SET dm2_db_options->table_monitoring_maxretry = "NOT_SET"
  SET dm2_db_options->db_optimizer_category = "NOT_SET"
  SET dm2_db_options->dbstats_gather_method = "NOT_SET"
  SET dm2_db_options->cbf_maxrangegroups = "NOT_SET"
  SET dm2_db_options->resource_busy_maxretry = "NOT_SET"
  SET dm2_db_options->dbstats_chk_rpt = "NOT_SET"
  SET dm2_db_options->readme_space_calc = "NOT_SET"
  SET dm2_db_options->recompile_after_alter_tbl = "NOT_SET"
  SET dm2_db_options->add_nn_col_nobf_ind = "NOT_SET"
  SET dm2_db_options->create_index_invisible = "NOT_SET"
  SET dm2_db_options->lob_securefile_ind = "NOT_SET"
  SET dm2_db_options->lob_retention = "NOT_SET"
  SET dm2_db_options->lob_maxsize = "NOT_SET"
  SET dm2_db_options->use_initprm_assign_dg_ind = "NOT_SET"
  SET dm2_db_options->assign_dg_override = "NOT_SET"
  SET dm2_db_options->degree_of_parallel_max = "NOT_SET"
  SET dm2_db_options->degree_of_parallel = "NOT_SET"
 ENDIF
 IF (validate(dm2_table->full_table_name," ")=" ")
  FREE RECORD dm2_table
  RECORD dm2_table(
    1 full_table_name = vc
    1 suffixed_table_name = vc
    1 table_suffix = vc
  )
  SET dm2_table->full_table_name = " "
  SET dm2_table->suffixed_table_name = " "
  SET dm2_table->table_suffix = " "
 ENDIF
 IF (validate(dm2_common1->snapshot_id,5)=5)
  FREE RECORD dm2_common1
  RECORD dm2_common1(
    1 snapshot_id = i2
  )
  SET dm2_common1->snapshot_id = 0
 ENDIF
 IF (validate(dm2_sch_except->tcnt,- (1)) < 0)
  FREE RECORD dm2_sch_except
  RECORD dm2_sch_except(
    1 tcnt = i4
    1 tbl[*]
      2 tbl_name = vc
    1 seq_cnt = i4
    1 seq[*]
      2 seq_name = vc
  )
  SET dm2_sch_except->tcnt = 0
  SET dm2_sch_except->seq_cnt = 0
 ENDIF
 IF ((validate(dm2_install_rec->snapshot_dt_tm,- (1))=- (1)))
  FREE RECORD dm2_install_rec
  RECORD dm2_install_rec(
    1 snapshot_dt_tm = f8
  )
 ENDIF
 IF (validate(dir_install_misc->ddl_failed_ind,1)=1
  AND validate(dir_install_misc->ddl_failed_ind,2)=2)
  FREE RECORD dir_install_misc
  RECORD dir_install_misc(
    1 ddl_failed_ind = i2
  )
  SET dir_install_misc->ddl_failed_ind = 0
 ENDIF
 IF ((validate(dir_silmode_requested_ind,- (1))=- (1))
  AND (validate(dir_silmode_requested_ind,- (2))=- (2)))
  DECLARE dir_silmode_requested_ind = i2 WITH public, noconstant(0)
 ENDIF
 IF (validate(dir_silmode->cnt,1)=1
  AND validate(dir_silmode->cnt,2)=2)
  FREE RECORD dir_silmode
  RECORD dir_silmode(
    1 cnt = i4
    1 qual[*]
      2 name = vc
      2 filename = vc
  )
  SET dir_silmode->cnt = 0
 ENDIF
 IF (validate(dir_batch_queue,"X")="X"
  AND validate(dir_batch_queue,"Y")="Y")
  DECLARE dir_batch_queue = vc WITH public, constant(cnvtlower(build("INSTALL$",logical("environment"
      ))))
 ENDIF
 IF (validate(dm_ocd_setup_admin_data->dm_ocd_setup_admin_date,1.0)=1.0
  AND validate(dm_ocd_setup_admin_data->dm_ocd_setup_admin_date,2.0)=2.0)
  FREE RECORD dm_ocd_setup_admin_data
  RECORD dm_ocd_setup_admin_data(
    1 dm_ocd_setup_admin_date = dq8
    1 dm2_create_system_defs = dq8
    1 dm2_set_adm_cbo = f8
  )
 ENDIF
 IF ((validate(dir_obsolete_objects->tbl_cnt,- (2))=- (2))
  AND (validate(dir_obsolete_objects->tbl_cnt,- (1))=- (1)))
  FREE RECORD dir_obsolete_objects
  RECORD dir_obsolete_objects(
    1 tbl_cnt = i4
    1 tbl[*]
      2 table_name = vc
    1 ind_cnt = i4
    1 ind[*]
      2 index_name = vc
    1 con_cnt = i4
    1 con[*]
      2 constraint_name = vc
  )
 ENDIF
 IF ((validate(dir_dropped_objects->obj_cnt,- (1))=- (1))
  AND (validate(dir_dropped_objects->obj_cnt,- (2))=- (2)))
  FREE RECORD dir_dropped_objects
  RECORD dir_dropped_objects(
    1 obj_cnt = i4
    1 rpt_drp_obj_ind = i2
    1 obj[*]
      2 table_name = vc
      2 name = vc
      2 type = vc
      2 reason = vc
  )
 ENDIF
 IF ((validate(dir_env_maint_rs->src_env_id,- (1))=- (1))
  AND (validate(dir_env_maint_rs->src_env_id,- (2))=- (2)))
  FREE RECORD dir_env_maint_rs
  RECORD dir_env_maint_rs(
    1 src_env_id = f8
    1 tgt_env_id = f8
    1 tgt_hist_fnd = i2
    1 process = vc
  )
  SET dir_env_maint_rs->src_env_id = 0
  SET dir_env_maint_rs->tgt_env_id = 0
  SET dir_env_maint_rs->tgt_hist_fnd = 0
  SET dir_env_maint_rs->process = "DM2NOTSET"
 ENDIF
 IF (validate(dir_tools_tspaces->data_tspace,"X")="X"
  AND validate(dir_tools_tspaces->data_tspace,"Y")="Y")
  FREE RECORD dir_tools_tspaces
  RECORD dir_tools_tspaces(
    1 data_tspace = vc
    1 index_tspace = vc
    1 lob_tspace = vc
  )
  SET dir_tools_tspaces->data_tspace = "NONE"
  SET dir_tools_tspaces->index_tspace = "NONE"
  SET dir_tools_tspaces->lob_tspace = "NONE"
 ENDIF
 IF (validate(dir_managed_ddl->setup_complete,1)=1
  AND validate(dir_managed_ddl->setup_complete,2)=2)
  FREE RECORD dir_managed_ddl
  RECORD dir_managed_ddl(
    1 setup_complete = i2
    1 managed_ddl_ind = i2
    1 oraversion = vc
    1 priority_cnt = i4
    1 priorities[*]
      2 priority = i4
    1 table_cnt = i4
    1 tables[*]
      2 table_name = vc
  )
  SET dir_managed_ddl->setup_complete = 0
  SET dir_managed_ddl->managed_ddl_ind = 0
  SET dir_managed_ddl->oraversion = "DM2NOTSET"
  SET dir_managed_ddl->priority_cnt = 0
  SET dir_managed_ddl->table_cnt = 0
 ENDIF
 IF (validate(dir_ui_misc->dm_process_event_id,1)=1
  AND validate(dir_ui_misc->dm_process_event_id,2)=2)
  FREE RECORD dir_ui_misc
  RECORD dir_ui_misc(
    1 dm_process_event_id = f8
    1 parent_script_name = vc
    1 background_ind = i2
    1 install_status = i2
    1 auto_install_ind = i2
    1 tspace_dg = vc
    1 debug_level = i4
    1 trace_flag = i2
  )
 ENDIF
 IF (validate(dir_storage_misc->src_storage_type,"x")="x"
  AND validate(dir_storage_misc->src_storage_type,"y")="y")
  FREE RECORD dir_storage_misc
  RECORD dir_storage_misc(
    1 src_storage_type = vc
    1 tgt_storage_type = vc
    1 cur_storage_type = vc
  )
  SET dir_storage_misc->src_storage_type = "DM2NOTSET"
  SET dir_storage_misc->tgt_storage_type = "DM2NOTSET"
  SET dir_storage_misc->cur_storage_type = "DM2NOTSET"
 ENDIF
 IF (validate(dir_db_users_pwds->cnt,1)=1
  AND validate(dir_db_users_pwds->cnt,2)=2)
  FREE RECORD dir_db_users_pwds
  RECORD dir_db_users_pwds(
    1 cnt = i4
    1 qual[*]
      2 user = vc
      2 pwd = vc
  )
  SET dir_db_users_pwds->cnt = 0
 ENDIF
 IF (validate(dir_custom_constraints->con_cnt,1)=1
  AND validate(dir_custom_constraints->con_cnt,2)=2)
  FREE RECORD dir_custom_constraints
  RECORD dir_custom_constraints(
    1 con_cnt = i4
    1 con[*]
      2 constraint_name = vc
  )
  SET dir_custom_constraints->con_cnt = 0
 ENDIF
 IF (validate(dir_killed_appl->appl_cnt,1)=1
  AND validate(dir_killed_appl->appl_cnt,2)=2)
  FREE RECORD dir_killed_appl
  RECORD dir_killed_appl(
    1 appl_cnt = i4
    1 appl[*]
      2 appl_id = vc
  )
  SET dir_killed_appl->appl_cnt = 0
 ENDIF
 IF (validate(dm2_dft_extsize,- (1)) < 0)
  DECLARE dm2_dft_extsize = i4 WITH public, constant(163840)
  DECLARE dm2_dft_clin_tspace = vc WITH public, constant("D_A_SMALL")
  DECLARE dm2_dft_clin_itspace = vc WITH public, constant("I_A_SMALL")
  DECLARE dm2_dft_clin_ltspace = vc WITH public, constant("L_A_SMALL")
 ENDIF
 IF (validate(dir_kill_clause,"z")="z"
  AND validate(dir_kill_clause,"y")="y")
  DECLARE dir_kill_clause = vc WITH public, constant(
   "Session was killed by V500.DM2MONPKG.KILL_IF_BLOCKING procedure.")
 ENDIF
 SUBROUTINE dir_dm2_tables_tspace_assign(null)
   IF ((dir_tools_tspaces->data_tspace != "NONE")
    AND (dir_tools_tspaces->index_tspace != "NONE")
    AND (dir_tools_tspaces->lob_tspace != "NONE"))
    RETURN(1)
   ENDIF
   IF ((dir_tools_tspaces->data_tspace="NONE"))
    SET dm_err->eproc =
    "Determining data_tspace from dm2_user_tables for DM2_DDL_OPS1/DM2_DDL_OPS_LOG1."
    SELECT INTO "nl:"
     FROM dm2_user_tables dut
     WHERE dut.table_name IN ("DM2_DDL_OPS1", "DM2_DDL_OPS_LOG1")
     ORDER BY dut.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->data_tspace = dut.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_tools_tspaces->data_tspace="NONE"))
    SET dm_err->eproc = "Determining data_tspace from dm2_user_tables for DM_INFO/DM_ENVIRONMENT."
    SELECT INTO "nl:"
     FROM dm2_user_tables dut
     WHERE dut.table_name IN ("DM_INFO", "DM_ENVIRONMENT")
     ORDER BY dut.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->data_tspace = dut.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_tools_tspaces->data_tspace="NONE"))
    SET dm_err->eproc = "Determining data_tspace from dm2_user_tablespaces."
    SELECT INTO "nl:"
     FROM dm2_user_tablespaces dut
     WHERE dut.tablespace_name IN ("D_TOOLKIT", "D_SYS_MGMT", "D_A_SMALL")
     ORDER BY dut.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->data_tspace = dut.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_tools_tspaces->data_tspace="NONE"))
    RETURN(1)
   ENDIF
   IF ((dir_tools_tspaces->index_tspace="NONE"))
    SET dm_err->eproc =
    "Determining index_tspace from dm2_user_indexes for DM2_DDL_OPS1/DM2_DDL_OPS_LOG1."
    SELECT INTO "nl:"
     FROM dm2_user_indexes dui
     WHERE dui.table_name IN ("DM2_DDL_OPS1", "DM2_DDL_OPS_LOG1")
     ORDER BY dui.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->index_tspace = dui.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_tools_tspaces->index_tspace="NONE"))
    SET dm_err->eproc = "Determining index_tspace from dm2_user_indexes for DM_INFO/DM_ENVIRONMENT."
    SELECT INTO "nl:"
     FROM dm2_user_indexes dui
     WHERE dui.table_name IN ("DM_INFO", "DM_ENVIRONMENT")
     ORDER BY dui.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->index_tspace = dui.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_tools_tspaces->index_tspace="NONE"))
    SET dm_err->eproc = "Determining index_tspace from dm2_user_tablespaces."
    SELECT INTO "nl:"
     FROM dm2_user_tablespaces dut
     WHERE dut.tablespace_name IN ("I_TOOLKIT", "I_SYS_MGMT", "I_A_SMALL")
     ORDER BY dut.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->index_tspace = dut.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_tools_tspaces->index_tspace="NONE"))
    RETURN(1)
   ENDIF
   IF ((dir_tools_tspaces->lob_tspace="NONE"))
    SET dir_tools_tspaces->lob_tspace = dir_tools_tspaces->data_tspace
    SET dm_err->eproc = "Determining lob_tspace from dm2_user_tablespaces."
    SELECT INTO "nl:"
     FROM dm2_user_tablespaces dut
     WHERE dut.tablespace_name IN ("L_SYS_MGMT", "L_A_SMALL")
     ORDER BY dut.tablespace_name
     HEAD REPORT
      dir_tools_tspaces->lob_tspace = dut.tablespace_name
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_debug_trace_data(null)
   SET dir_ui_misc->debug_level = 0
   SET dir_ui_misc->trace_flag = 0
   SET dm_err->eproc = "Query for debug flag/level"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info i
    WHERE i.info_domain="DM2_AUTO_INSTALL"
     AND i.info_name="DEBUG_FLAG"
    DETAIL
     dir_ui_misc->debug_level = i.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Query for trace status"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info i
    WHERE i.info_domain="DM2_AUTO_INSTALL"
     AND i.info_name="TRACE_FLAG"
    DETAIL
     IF (i.info_char="ON")
      dir_ui_misc->trace_flag = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_obsolete_objects(null)
   SET dm_err->eproc = "Selecting obsolete tables and indexes from dm_info."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE "OBSOLETE_OBJECT"=di.info_domain
    ORDER BY di.info_name
    HEAD REPORT
     dir_obsolete_objects->tbl_cnt = 0, stat = alterlist(dir_obsolete_objects->tbl,
      dir_obsolete_objects->tbl_cnt), dir_obsolete_objects->ind_cnt = 0,
     stat = alterlist(dir_obsolete_objects->ind,dir_obsolete_objects->ind_cnt)
    DETAIL
     CASE (build(di.info_char))
      OF "TABLE":
       dir_obsolete_objects->tbl_cnt = (dir_obsolete_objects->tbl_cnt+ 1),
       IF (mod(dir_obsolete_objects->tbl_cnt,10)=1)
        stat = alterlist(dir_obsolete_objects->tbl,(dir_obsolete_objects->tbl_cnt+ 9))
       ENDIF
       ,dir_obsolete_objects->tbl[dir_obsolete_objects->tbl_cnt].table_name = di.info_name
      OF "INDEX":
       dir_obsolete_objects->ind_cnt = (dir_obsolete_objects->ind_cnt+ 1),
       IF (mod(dir_obsolete_objects->ind_cnt,10)=1)
        stat = alterlist(dir_obsolete_objects->ind,(dir_obsolete_objects->ind_cnt+ 9))
       ENDIF
       ,dir_obsolete_objects->ind[dir_obsolete_objects->ind_cnt].index_name = di.info_name
     ENDCASE
    FOOT REPORT
     stat = alterlist(dir_obsolete_objects->tbl,dir_obsolete_objects->tbl_cnt), stat = alterlist(
      dir_obsolete_objects->ind,dir_obsolete_objects->ind_cnt)
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Selecting obsolete constraints from dm_info."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE "OBSOLETE_CONSTRAINT"=di.info_domain
    ORDER BY di.info_name
    HEAD REPORT
     dir_obsolete_objects->con_cnt = 0, stat = alterlist(dir_obsolete_objects->con,
      dir_obsolete_objects->con_cnt)
    DETAIL
     dir_obsolete_objects->con_cnt = (dir_obsolete_objects->con_cnt+ 1)
     IF (mod(dir_obsolete_objects->con_cnt,10)=1)
      stat = alterlist(dir_obsolete_objects->con,(dir_obsolete_objects->con_cnt+ 9))
     ENDIF
     dir_obsolete_objects->con[dir_obsolete_objects->con_cnt].constraint_name = di.info_name
    FOOT REPORT
     stat = alterlist(dir_obsolete_objects->con,dir_obsolete_objects->con_cnt)
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(dir_obsolete_objects)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_fill_sch_except(sbr_dfse_from)
   IF ( NOT (cnvtupper(sbr_dfse_from) IN ("REMOTE", "LOCAL")))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid from table indicator (should be either REMOTE or LOCAL)."
    SET dm_err->eproc = "Building exception list of tables"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm2_sch_except->tcnt=0))
    IF (dm2_set_autocommit(1)=0)
     RETURN(0)
    ENDIF
    IF (cnvtupper(sbr_dfse_from)="REMOTE")
     SELECT INTO "nl:"
      t.table_name
      FROM dm2_src_tables t
      WHERE ((t.table_name IN ("DM2_DDL_OPS*", "DM2_TSPACE_SIZE*", "DM2_TSPACE_OBJ_SIZE*")) OR (t
      .table_name="DM_STAT_TABLE"))
      DETAIL
       dm2_sch_except->tcnt = (dm2_sch_except->tcnt+ 1), stat = alterlist(dm2_sch_except->tbl,
        dm2_sch_except->tcnt), dm2_sch_except->tbl[dm2_sch_except->tcnt].tbl_name = t.table_name
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      t.table_name
      FROM dm2_user_tables t
      WHERE ((t.table_name IN ("DM2_DDL_OPS*", "DM2_TSPACE_SIZE*", "DM2_TSPACE_OBJ_SIZE*")) OR (t
      .table_name="DM_STAT_TABLE"))
      DETAIL
       dm2_sch_except->tcnt = (dm2_sch_except->tcnt+ 1), stat = alterlist(dm2_sch_except->tbl,
        dm2_sch_except->tcnt), dm2_sch_except->tbl[dm2_sch_except->tcnt].tbl_name = t.table_name
      WITH nocounter
     ;end select
    ENDIF
    IF (check_error("Determining tables that should be in dm2_sch_except record structure")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dm2_set_autocommit(0)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm2_sch_except->seq_cnt=0))
    SET dm2_sch_except->seq_cnt = 1
    SET stat = alterlist(dm2_sch_except->seq,1)
    SET dm2_sch_except->seq[1].seq_name = "DM_SEQ"
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_val_sch_date_str(sbr_datestr)
   DECLARE bad_sd_ind = i2 WITH protect, noconstant(0)
   DECLARE cnvt_datestr = vc WITH protect, noconstant(cnvtupper(sbr_datestr))
   IF (textlen(cnvt_datestr) != 11)
    SET bad_sd_ind = 1
   ELSEIF (substring(3,1,cnvt_datestr) != "-")
    SET bad_sd_ind = 1
   ELSEIF (substring(7,1,cnvt_datestr) != "-")
    SET bad_sd_ind = 1
   ELSEIF (cnvtint(substring(1,2,cnvt_datestr)) > 31)
    SET bad_sd_ind = 1
   ELSEIF (cnvtint(substring(1,2,cnvt_datestr)) <= 0)
    SET bad_sd_ind = 1
   ELSEIF (cnvtint(substring(8,4,cnvt_datestr)) <= 0)
    SET bad_sd_ind = 1
   ENDIF
   IF (bad_sd_ind=1)
    SET dm_err->eproc = "Validating schema date"
    SET dm_err->err_ind = 1
    SET dm_err->user_action =
    'Please specify a valid date in the format "DD-MON-YYYY", e.g. "15-JAN-2002" '
    CALL disp_msg(concat('Invalid schema date of "',sbr_datestr,'" was passed in'),dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_ddl_token_replacement(ddtr_text_str)
   DECLARE ddtr_pword = vc WITH protect, noconstant("NONE")
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("Before token replacement",ddtr_text_str))
   ENDIF
   IF (currdbuser="CDBA")
    IF ( NOT ((dm2_install_schema->cdba_p_word="NONE")))
     SET ddtr_pword = dm2_install_schema->cdba_p_word
    ENDIF
   ELSE
    IF ( NOT ((dm2_install_schema->v500_p_word="NONE")))
     SET ddtr_pword = dm2_install_schema->v500_p_word
    ENDIF
   ENDIF
   SET ddtr_text_str = replace(ddtr_text_str,"%DCL1%","",0)
   SET ddtr_text_str = replace(ddtr_text_str,"%DCL2%","",0)
   SET ddtr_text_str = replace(ddtr_text_str,"%DCL3%","",0)
   SET ddtr_text_str = replace(ddtr_text_str,"%FLOC%",dm2_install_schema->cer_install,0)
   SET ddtr_text_str = replace(ddtr_text_str,"%FLOC2%",dm2_install_schema->ccluserdir,0)
   IF ((dm2_install_schema->servername != "NONE"))
    SET ddtr_text_str = replace(ddtr_text_str,"%SNAME%",dm2_install_schema->servername,0)
   ENDIF
   SET ddtr_text_str = replace(ddtr_text_str,"%UNAME%",trim(currdbuser),0)
   IF (ddtr_pword != "NONE")
    SET ddtr_text_str = replace(ddtr_text_str,"%PWD%",ddtr_pword,0)
   ENDIF
   SET ddtr_text_str = replace(ddtr_text_str,"%DBASE%",trim(validate(currdbname," ")),0)
   IF ( NOT ((dm2_install_schema->src_v500_p_word="NONE")))
    SET ddtr_text_str = replace(ddtr_text_str,"%SRCPWD%",dm2_install_schema->src_v500_p_word,0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("After token replacement",ddtr_text_str))
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE check_concurrent_snapshot(sbr_ccs_mode)
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
     IF ((ccs_appl_id=dm2_install_schema->appl_id))
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
    SET dm2_install_rec->snapshot_dt_tm = cnvtdatetime(curdate,curtime3)
    IF ((dm_err->debug_flag > 0))
     CALL echo(build("Time of snapshot = ",format(dm2_install_rec->snapshot_dt_tm,
        "mm/dd/yyyy hh:mm:ss;;d")))
    ENDIF
    SET dm_err->eproc = "Inserting concurrency row in dm_info."
    CALL disp_msg(" ",dm_err->logfile,0)
    INSERT  FROM dm_info di
     SET di.info_domain = "DM2 INSTALL PROCESS", di.info_name = "CONCURRENCY CHECKPOINT", di
      .info_char = dm2_install_schema->appl_id,
      di.info_date = cnvtdatetime(dm2_install_rec->snapshot_dt_tm), di.updt_dt_tm = cnvtdatetime(
       curdate,curtime3), di.updt_applctx = 0,
      di.updt_cnt = 0, di.updt_id = 0, di.updt_task = 0
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
 SUBROUTINE dir_row_count(rrc_table_name,rrc_row_cnt)
   DECLARE rrc_local_row_cnt = f8 WITH protect, noconstant(0.0)
   SET dm_err->eproc = concat("Retrieving row count for table ",trim(rrc_table_name),".")
   SELECT INTO "nl:"
    FROM dm_user_tables_actual_stats t
    WHERE t.table_name=rrc_table_name
    DETAIL
     rrc_local_row_cnt = t.num_rows
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET rrc_row_cnt = 0.0
   ELSE
    SET rrc_row_cnt = rrc_local_row_cnt
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_setup_dbase_env(null)
   DECLARE max_env_id = f8 WITH protect, noconstant(0.0)
   DECLARE new_env_id = f8 WITH protect, noconstant(0.0)
   DECLARE dsdes_connect_str = vc WITH protect, noconstant(" ")
   IF (currdb="ORACLE")
    SET dsdes_cnnct_str = cnvtlower(build("v500","/",dm2_install_schema->v500_p_word,"@",
      dm2_install_schema->v500_connect_str))
   ELSE
    SET dsdes_cnnct_str = build("v500","/",dm2_install_schema->v500_p_word,"/",dm2_install_schema->
     v500_connect_str)
   ENDIF
   SET dm_err->eproc = "Determining if environment already set up."
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_environment e
    WHERE cnvtupper(e.environment_name)=cnvtupper(dm2_install_schema->target_env_name)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = "Determining next environment id."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (currdb="ORACLE")
     SELECT INTO "nl:"
      y = seq(dm_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_env_id = cnvtreal(y)
      WITH format, nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF ((dm_err->debug_flag > 0))
      CALL echo(dm_err->asterisk_line)
      CALL echo(build("new_env_id=",new_env_id))
      CALL echo(dm_err->asterisk_line)
     ENDIF
    ELSE
     SELECT INTO "nl:"
      FROM dm_environment e
      FOOT REPORT
       max_env_id = max(e.environment_id)
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET new_env_id = (max_env_id+ 1)
     IF ((dm_err->debug_flag > 0))
      CALL echo(dm_err->asterisk_line)
      CALL echo(build("max_env_id=",max_env_id))
      CALL echo(build("new_env_id=",new_env_id))
      CALL echo(dm_err->asterisk_line)
     ENDIF
    ENDIF
    SET dm_err->eproc = concat("Inserting dm_environment row for database ",dm2_install_schema->
     target_dbase_name,".")
    CALL disp_msg(" ",dm_err->logfile,0)
    SET adm_maint_str = concat("insert into dm_environment de ",
     " set de.environment_id =  new_env_id ",
     ", de.environment_name =  cnvtupper(dm2_install_schema->target_env_name)",
     ", de.database_name = ' '",", de.admin_dbase_link_name = 'ADMIN1'",
     ", de.schema_version = 0.0",", de.from_schema_version = 0.0",
     ", de.v500_connect_string = dsdes_cnnct_str",", de.volume_group = 'N/A'",
     ", de.root_dir_name = 'N/A'",
     ", de.target_operating_system = dm2_sys_misc->cur_db_os ",", de.updt_applctx = 0 ",
     ", de.updt_dt_tm = cnvtdatetime(curdate,curtime3) ",", de.updt_cnt = 0 ",", de.updt_id = 0 ",
     ", de.updt_task = 0 ","  with nocounter go")
    IF (dm2_push_adm_maint(adm_maint_str)=0)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ELSE
    SET dm_err->eproc = "Updating environment id with current information."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET adm_maint_str = concat("update from dm_environment de ",
     "set  de.admin_dbase_link_name = 'ADMIN1'",", de.schema_version = 0.0",
     ", de.from_schema_version = 0.0",", de.v500_connect_string =  dsdes_cnnct_str",
     ", de.updt_dt_tm = cnvtdatetime(curdate,curtime3) ",", de.updt_cnt = 0 ",", de.updt_id = 0 ",
     ", de.updt_task = 0 ",
     "  where de.environment_name = cnvtupper(dm2_install_schema->target_env_name) ",
     "  with nocounter go")
    IF (dm2_push_adm_maint(adm_maint_str)=0)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Prompt to confirm environment name"
   CALL disp_msg(" ",dm_err->logfile,0)
   EXECUTE dm_set_env_id
   SET message = nowindow
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Determining if 'INHOUSE DOMAIN' dm_info row exists."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="INHOUSE DOMAIN"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (curqual > 0)
    SET dm_err->eproc = "Deleting 'INHOUSE DOMAIN' row from dm_info."
    CALL disp_msg(" ",dm_err->logfile,0)
    DELETE  FROM dm_info di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="INHOUSE DOMAIN"
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
 SUBROUTINE prompt_for_host(sbr_host_db)
   DECLARE pfah_choice = vc WITH protect, noconstant(" ")
   SET message = window
   SET width = 132
   CALL clear(1,1)
   CALL video(n)
   CALL text(2,1,concat("Creating a database connection to the ",cnvtupper(sbr_host_db)," database: "
     ),w)
   IF (currdb IN ("ORACLE", "DB2UDB"))
    CALL text(4,1,
     ">>> In the Host Name field, type the database server system's host name or IP address.")
   ELSE
    CALL text(4,1,
     ">>> In the Host Name field, type the database's server name (include named instance).")
   ENDIF
   CALL box(6,5,8,120)
   CALL text(7,7,"Host Name: ")
   CALL text(10,1,">>> Enter 'C' to continue or 'Q' to quit (C or Q) :")
   CALL accept(7,18,"P(100);C"," "
    WHERE  NOT (curaccept=" "))
   SET dm2_install_schema->hostname = trim(curaccept,3)
   CALL accept(10,53,"A;cu","C"
    WHERE curaccept IN ("Q", "C"))
   SET pfah_choice = curaccept
   SET message = nowindow
   IF (pfah_choice="Q")
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_val_file_prefix(sbr_file_prefix)
   DECLARE sbr_vfp_sch_date_fmt = f8 WITH protect
   DECLARE sbr_vfp_dir = vc WITH protect
   IF ((dm2_install_schema->process_option="DDL GEN"))
    SET dm2_install_schema->schema_prefix = ""
    SET dm2_install_schema->file_prefix = sbr_file_prefix
   ELSEIF (findstring("-",sbr_file_prefix) IN (0, 1))
    SET dm2_install_schema->schema_prefix = "dm2o"
    SET dm2_install_schema->file_prefix = sbr_file_prefix
   ELSE
    IF ((dm2_install_schema->process_option IN ("ADMIN CREATE", "ADMIN UPGRADE")))
     SET dm2_install_schema->schema_prefix = "dm2a"
    ELSE
     SET dm2_install_schema->schema_prefix = "dm2c"
    ENDIF
    IF (dm2_val_sch_date_str(sbr_file_prefix)=0)
     RETURN(0)
    ELSE
     SET sbr_vfp_sch_date_fmt = cnvtdate2(sbr_file_prefix,"DD-MMM-YYYY")
     SET dm2_install_schema->file_prefix = cnvtalphanum(format(sbr_vfp_sch_date_fmt,"MM/DD/YYYY;;D"))
    ENDIF
   ENDIF
   IF ((((dm2_install_schema->schema_prefix="dm2o")) OR ((dm2_install_schema->process_option IN (
   "DDL GEN", "INHOUSE")))) )
    SET sbr_vfp_dir = dm2_install_schema->ccluserdir
    SET dm2_install_schema->schema_loc = "ccluserdir"
   ELSE
    SET sbr_vfp_dir = dm2_install_schema->cer_install
    SET dm2_install_schema->schema_loc = "cer_install"
   ENDIF
   IF ((dm2_install_schema->schema_prefix="dm2a"))
    IF (findfile(build(sbr_vfp_dir,cnvtlower(trim(dm2_install_schema->schema_prefix)),cnvtlower(trim(
        dm2_install_schema->file_prefix)),"_t.csv"))=0)
     SET dm_err->emsg = concat("CSV Schema files not found for file prefix ",sbr_file_prefix," in ",
      sbr_vfp_dir)
     SET dm_err->eproc = "File Prefix Validation"
     SET dm_err->user_action = "CSV Schema files not found.  Please enter a valid file prefix."
     RETURN(0)
    ENDIF
   ELSE
    IF (findfile(build(sbr_vfp_dir,cnvtlower(trim(dm2_install_schema->schema_prefix)),cnvtlower(trim(
        dm2_install_schema->file_prefix)),cnvtlower(dm2_sch_file->qual[1].file_suffix),".dat"))=0)
     SET dm_err->emsg = concat("Schema files not found for file prefix ",sbr_file_prefix," in ",
      sbr_vfp_dir)
     SET dm_err->eproc = "File Prefix Validation"
     SET dm_err->user_action = "Schema files not found.  Please enter a valid file prefix."
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_toolset_usage(null)
   DECLARE dtu_use_dm2_toolset = i2
   DECLARE dtu_use_dm_toolset = i2
   SET dtu_use_dm2_toolset = 1
   SET dtu_use_dm_toolset = 2
   SET dm_err->eproc = "Determining if DM_INFO exists."
   SELECT INTO "nl:"
    FROM user_tab_columns utc
    WHERE utc.table_name="DM_INFO"
    WITH nocounter
   ;end select
   SET dm_err->ecode = error(dm_err->emsg,1)
   IF ((dm_err->ecode != 0))
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF (curqual > 0
    AND checkdic("DM_INFO","T",0)=2)
    SET dm_err->eproc = "Determining if database option exists."
    FREE RECORD dtu_db_option
    RECORD dtu_db_option(
      1 info_char = vc
      1 info_date = dq8
    )
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain=concat("DM2_",trim(currdb),"_DB_OPTION")
      AND d.info_name="DM2_TOOLSET_USAGE"
     DETAIL
      dtu_db_option->info_char = d.info_char, dtu_db_option->info_date = d.info_date
     WITH nocounter
    ;end select
    SET dm_err->ecode = error(dm_err->emsg,1)
    IF ((dm_err->ecode != 0))
     SET dm_err->err_ind = 1
     FREE RECORD dtu_db_option
     RETURN(0)
    ENDIF
    IF (curqual=1)
     IF ((dtu_db_option->info_char IN ("Y", "N"))
      AND (dtu_db_option->info_date=cnvtdatetime("22-JUN-1996 00:00:00")))
      IF ((dtu_db_option->info_char="Y"))
       FREE RECORD dtu_db_option
       IF ((dm_err->debug_flag > 0))
        CALL echo("Using DM2 toolset because database option designates dm2 toolset usage")
       ENDIF
       RETURN(dtu_use_dm2_toolset)
      ELSE
       FREE RECORD dtu_db_option
       IF ((dm_err->debug_flag > 0))
        CALL echo("Using DM toolset because database option designates dm toolset usage")
       ENDIF
       RETURN(dtu_use_dm_toolset)
      ENDIF
     ELSE
      IF ((dtu_db_option->info_char != "CERNER_DEFAULT"))
       IF ((dm_err->debug_flag > 0))
        CALL echo("Not using the database option because it is not set up correctly.")
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo("Defaulting to DM2 toolset")
   ENDIF
   RETURN(dtu_use_dm2_toolset)
 END ;Subroutine
 SUBROUTINE dm2_get_suffixed_tablename(tbl_name)
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   DECLARE dm2_str = vc WITH protect, noconstant(" ")
   SET dm2_str = concat("select into 'nl:'"," from dm_tables_doc dtd ",
    " where dtd.table_name = cnvtupper('",tbl_name,"')",
    " detail"," dm2_table->suffixed_table_name = dtd.suffixed_table_name",
    " dm2_table->table_suffix = dtd.table_suffix"," dm2_table->full_table_name = dtd.full_table_name",
    " with nocounter",
    " go")
   IF ( NOT (dm2_push_cmd(dm2_str,1)))
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_push_adm_maint(sbr_maint_str)
   DECLARE adm_maint_err = i4 WITH protect, noconstant(1)
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   SET adm_maint_err = dm2_push_cmd(sbr_maint_str,1)
   IF (adm_maint_err=0)
    ROLLBACK
   ELSE
    COMMIT
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
   RETURN(adm_maint_err)
 END ;Subroutine
 SUBROUTINE dm2_get_appl_status(gas_appl_id)
   DECLARE gas_error_status = c1 WITH protect, constant("E")
   DECLARE gas_active_status = c1 WITH protect, constant("A")
   DECLARE gas_inactive_status = c1 WITH protect, constant("I")
   DECLARE gas_text = vc WITH protect, noconstant(" ")
   DECLARE gas_currdblink = vc WITH protect, noconstant(cnvtupper(trim(currdblink,3)))
   DECLARE gas_appl_id_cvt = vc WITH protect, noconstant(" ")
   IF (currdb="DB2UDB")
    SET gas_appl_id_cvt = replace(trim(gas_appl_id,3),"*","\*",0)
    SELECT INTO "nl:"
     FROM dm2_user_views
     WHERE view_name="DM2_SNAP_APPL_INFO"
     WITH nocounter
    ;end select
    IF (check_error("Selecting from dm2_user_views in subroutine DM2_GET_APPL_STATUS")=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ENDIF
    IF (curqual=0)
     SET gas_text = concat("RDB ASIS (^ ","CREATE VIEW DM2_SNAP_APPL_INFO AS ",
      " ( SELECT * FROM TABLE(SNAPSHOT_APPL_INFO('",gas_currdblink,"',-1 )) AS SNAPSHOT_APPL_INFO )",
      " ^) GO ")
     IF (dm2_push_cmd(gas_text,1) != 1)
      ROLLBACK
      RETURN(gas_error_status)
     ELSE
      COMMIT
      EXECUTE oragen3 "DM2_SNAP_APPL_INFO"
      IF ((dm_err->err_ind=1))
       RETURN(gas_error_status)
      ENDIF
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     FROM dtable
     WHERE table_name="DM2_SNAP_APPL_INFO"
     WITH nocounter
    ;end select
    IF (check_error("Selecting from dtable in subroutine DM2_GET_APPL_STATUS")=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ENDIF
    IF (curqual != 1)
     EXECUTE oragen3 "DM2_SNAP_APPL_INFO"
     IF ((dm_err->err_ind=1))
      RETURN(gas_error_status)
     ENDIF
    ENDIF
    SET gas_text = concat('select into "nl:" from DM2_SNAP_APPL_INFO where appl_id = "',
     gas_appl_id_cvt,'" with nocounter go')
    IF (dm2_push_cmd(gas_text,1) != 1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ENDIF
    IF (curqual=1)
     RETURN(gas_active_status)
    ELSE
     RETURN(gas_inactive_status)
    ENDIF
   ELSEIF (currdb="SQLSRV")
    DECLARE gas_str_loc1 = i4 WITH protect, noconstant(0)
    DECLARE gas_str_loc2 = i4 WITH protect, noconstant(0)
    DECLARE gas_str_loc3 = i4 WITH protect, noconstant(0)
    DECLARE gas_spid = i4 WITH protect, noconstant(0)
    DECLARE gas_login_date = vc WITH protect, noconstant(" ")
    DECLARE gas_login_time = i4 WITH protect, noconstant(0)
    SET gas_str_loc1 = findstring("-",trim(gas_appl_id,3),1,0)
    SET gas_str_loc2 = findstring(" ",trim(gas_appl_id,3),1,1)
    SET gas_str_loc3 = findstring(":",trim(gas_appl_id,3),1,1)
    IF (((gas_str_loc1=0) OR (((gas_str_loc2=0) OR (gas_str_loc3=0)) )) )
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Invalid application handle"
     SET dm_err->eproc =
     "Parsing through application handle to determine spid and login date and time"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ELSE
     SET gas_spid = cnvtint(build(substring(1,(gas_str_loc1 - 1),trim(gas_appl_id,3))))
     SET gas_login_date = cnvtupper(cnvtalphanum(substring((gas_str_loc1+ 1),(gas_str_loc2 -
        gas_str_loc1),trim(gas_appl_id,3))))
     SET gas_login_time = cnvtint(cnvtalphanum(substring(gas_str_loc2,(gas_str_loc3 - gas_str_loc2),
        trim(gas_appl_id,3))))
    ENDIF
    SELECT INTO "nl:"
     FROM sysprocesses p
     WHERE p.spid=gas_spid
      AND p.login_time=cnvtdatetime(cnvtdate2(gas_login_date,"DDMMMYYYY"),gas_login_time)
     WITH nocounter
    ;end select
    IF (check_error("Selecting from sysprocesses in subroutine DM2_GET_APPL_STATUS")=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ELSEIF (curqual=0)
     RETURN(gas_inactive_status)
    ELSE
     RETURN(gas_active_status)
    ENDIF
   ELSE
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
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_fill_seq_list(alias,col_name)
   DECLARE in_clause = vc WITH protect, noconstant("")
   SET in_clause = concat(alias,".",col_name," IN ('DM_PLAN_ID_SEQ', 'REPORT_SEQUENCE','DM_SEQ') ")
   RETURN(in_clause)
 END ;Subroutine
 SUBROUTINE dir_add_silmode_entry(entry_name,entry_filename)
   SET dir_silmode->cnt = (dir_silmode->cnt+ 1)
   SET stat = alterlist(dir_silmode->qual,dir_silmode->cnt)
   SET dir_silmode->qual[dir_silmode->cnt].name = entry_name
   SET dir_silmode->qual[dir_silmode->cnt].filename = entry_filename
 END ;Subroutine
 SUBROUTINE dm2_cleanup_stranded_appl(null)
   DECLARE dcsa_applx = i4 WITH protect, noconstant(0)
   DECLARE dcsa_fmt_appl_id = vc WITH protect, noconstant(" ")
   DECLARE dcsa_error_msg = vc WITH protect, noconstant(" ")
   DECLARE dcsa_load_ind = i2 WITH protect, noconstant(1)
   DECLARE dcsa_kill_ind = i2 WITH protect, noconstant(0)
   FREE RECORD dcsa_appl_rs
   RECORD dcsa_appl_rs(
     1 dcsa_appl_cnt = i4
     1 dcsa_appl[*]
       2 dcsa_appl_id = vc
   )
   SELECT INTO "nl:"
    FROM dm2_user_tables ut
    WHERE ut.table_name="DM2_DDL_OPS_LOG*"
    WITH nocounter
   ;end select
   IF (check_error("Find_Stranded_Runner - DDL_OPS_LOG table existence check")=true)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(false)
   ENDIF
   IF (curqual=0)
    CALL echo(
     "dm2_ddl_ops_log table not found in dm2_user_tables, bypassing dm2_cleanup_stranded_appl logic..."
     )
    RETURN(1)
   ELSE
    IF ((dm_err->debug_flag > 1))
     CALL echo("Curqual from user_tables for dm2_ddl_ops_log* returned != 0")
    ENDIF
   ENDIF
   SELECT DISTINCT INTO "nl:"
    ddol_appl_id = ddol.appl_id
    FROM dm2_ddl_ops_log ddol
    WHERE ddol.status IN ("RUNNING", null)
     AND ddol.op_type != "*(REMOTE)*"
    HEAD REPORT
     dcsa_applx = 0
    DETAIL
     dcsa_applx = (dcsa_applx+ 1)
     IF (mod(dcsa_applx,10)=1)
      stat = alterlist(dcsa_appl_rs->dcsa_appl,(dcsa_applx+ 9))
     ENDIF
     dcsa_appl_rs->dcsa_appl[dcsa_applx].dcsa_appl_id = ddol_appl_id
    FOOT REPORT
     dcsa_appl_rs->dcsa_appl_cnt = dcsa_applx, stat = alterlist(dcsa_appl_rs->dcsa_appl,dcsa_applx)
    WITH nocounter
   ;end select
   IF (check_error("Find_Stranded_Runner - Select")=true)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(false)
   ENDIF
   IF ((dcsa_appl_rs->dcsa_appl_cnt > 0))
    SET dcsa_applx = 1
    WHILE ((dcsa_applx <= dcsa_appl_rs->dcsa_appl_cnt))
      SET dcsa_fmt_appl_id = dcsa_appl_rs->dcsa_appl[dcsa_applx].dcsa_appl_id
      CASE (dm2_get_appl_status(value(dcsa_appl_rs->dcsa_appl[dcsa_applx].dcsa_appl_id)))
       OF "I":
        IF (dir_alert_killed_appl(dcsa_load_ind,dcsa_fmt_appl_id,dcsa_kill_ind)=0)
         RETURN(0)
        ENDIF
        SET dcsa_load_ind = 0
        IF (dcsa_kill_ind=1)
         SET dcsa_error_msg = dir_kill_clause
        ELSE
         SET dcsa_error_msg = concat("Application ID ",trim(dcsa_fmt_appl_id)," is no longer active."
          )
        ENDIF
        UPDATE  FROM dm2_ddl_ops_log ddol
         SET ddol.status = "ERROR", ddol.error_msg =
          "IMPORT operation set to ERROR since session executing no longer exists.", ddol.end_dt_tm
           = cnvtdatetime(curdate,curtime3)
         WHERE ddol.appl_id=dcsa_fmt_appl_id
          AND ddol.status="RUNNING"
          AND ddol.op_type="IMPORT*"
          AND ddol.op_type != "*(REMOTE)*"
        ;end update
        UPDATE  FROM dm2_ddl_ops_log ddol
         SET ddol.status = "ERROR", ddol.error_msg = dcsa_error_msg, ddol.end_dt_tm = cnvtdatetime(
           curdate,curtime3)
         WHERE ddol.appl_id=dcsa_fmt_appl_id
          AND ddol.status IN (null, "RUNNING")
          AND ddol.op_type != "*(REMOTE)*"
        ;end update
        IF (check_error("Find_Stranded_Processes - Update")=true)
         ROLLBACK
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(false)
        ELSE
         COMMIT
        ENDIF
       OF "A":
        IF ((dm_err->debug_flag > 0))
         CALL echo(build("Application Id ",dcsa_fmt_appl_id," is active."))
        ENDIF
       OF "E":
        IF ((dm_err->debug_flag > 0))
         CALL echo("Error Detected in dm2_get_appl_status")
        ENDIF
        RETURN(false)
      ENDCASE
      SET dcsa_applx = (dcsa_applx+ 1)
    ENDWHILE
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo("********** No Application Ids Detected **********")
    ENDIF
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE dir_alert_killed_appl(daka_load_ind,daka_fmt_appl_id,daka_kill_ind)
   DECLARE daka_audsid = vc WITH protect, noconstant(" ")
   DECLARE daka_audsid_start = i4 WITH protect, noconstant(0)
   DECLARE daka_audsid_end = i4 WITH protect, noconstant(0)
   DECLARE daka_applx = i4 WITH protect, noconstant(0)
   DECLARE daka_info_exists = i4 WITH protect, noconstant(0)
   SET daka_kill_ind = 0
   IF (daka_load_ind=1)
    IF (dm2_table_and_ccldef_exists("DM_INFO",daka_info_exists)=0)
     RETURN(0)
    ELSEIF (daka_info_exists=0)
     RETURN(1)
    ENDIF
    SELECT DISTINCT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="DM2MONPKG_LOGGER"
      AND d.updt_dt_tm BETWEEN cnvtdatetime((curdate - 7),curtime3) AND cnvtdatetime(curdate,curtime3
      )
      AND d.info_char="*AUDSID:*"
     HEAD REPORT
      dir_killed_appl->appl_cnt = 0
     DETAIL
      daka_audsid_start = findstring("AUDSID:",d.info_char,1,0), daka_audsid_end = findstring(",",d
       .info_char,daka_audsid_start,0)
      IF (daka_audsid_end=0)
       daka_audsid = substring(daka_audsid_start,((size(d.info_char)+ 1) - daka_audsid_start),d
        .info_char)
      ELSE
       daka_audsid = substring(daka_audsid_start,(daka_audsid_end - daka_audsid_start),d.info_char)
      ENDIF
      daka_audsid = trim(replace(daka_audsid,"AUDSID:","",0),3)
      IF (isnumeric(daka_audsid))
       dir_killed_appl->appl_cnt += 1
       IF (mod(dir_killed_appl->appl_cnt,10)=1)
        stat = alterlist(dir_killed_appl->appl,(dir_killed_appl->appl_cnt+ 9))
       ENDIF
       dir_killed_appl->appl[dir_killed_appl->appl_cnt].appl_id = daka_audsid
      ENDIF
     FOOT REPORT
      stat = alterlist(dir_killed_appl->appl,dir_killed_appl->appl_cnt)
     WITH nocounter
    ;end select
    IF (check_error("Obtain killed application IDs.")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dir_killed_appl->appl_cnt > 0))
    SET daka_applx = locateval(daka_applx,1,dir_killed_appl->appl_cnt,daka_fmt_appl_id,
     dir_killed_appl->appl[daka_applx].appl_id)
    IF (daka_applx > 0)
     SET daka_kill_ind = 1
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(dir_killed_appl)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_setup_batch_queue(dsbq_queue_name)
   DECLARE dsbq_env_name = vc WITH protect, noconstant(" ")
   DECLARE dsbq_cmd = vc WITH protect, noconstant(" ")
   DECLARE dsbq_start_pos = i4 WITH protect, noconstant(0)
   DECLARE dsbq_end_pos = i4 WITH protect, noconstant(0)
   DECLARE dsbq_domain_user = vc WITH protect, noconstant(" ")
   DECLARE dsbq_err_str = vc WITH protect, constant("no such queue")
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
   SET dsbq_cmd = concat("sho queue /full ",dsbq_queue_name)
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
   IF (findstring(dsbq_err_str,cnvtlower(dm_err->errtext),1,0) > 0)
    SET dsbq_queue_fnd = 0
   ELSEIF (findstring(cnvtlower(dsbq_queue_name),cnvtlower(dm_err->errtext),1,0)=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Determining if queue ",dsbq_queue_name," exists.")
    SET dm_err->emsg = dm_err->errtext
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    SET dsbq_queue_fnd = 1
   ENDIF
   IF (dsbq_queue_fnd=1)
    IF (findstring("idle",cnvtlower(dm_err->errtext),1,0)=0
     AND findstring("executing",cnvtlower(dm_err->errtext),1,0)=0)
     SET dm_err->err_ind = 1
     SET dm_err->eproc = concat("Make sure queue ",dsbq_queue_name,
      " is idle or is currently executing jobs.")
     SET dm_err->emsg = dm_err->errtext
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    SET dsbq_cmd = concat("init/queue/batch/start/job_limit=20 ",dsbq_queue_name)
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
 SUBROUTINE dir_sea_sch_files(directory,file_prefix,schema_date)
   DECLARE dgns_dcl_find = vc WITH protect, noconstant("")
   DECLARE dgns_err_str = vc WITH protect, noconstant("")
   SET schema_date = "01-JAN-1800"
   IF ( NOT (file_prefix IN ("dm2a", "dm2o", "dm2c")))
    SET dm_err->eproc = "Validating file_prefix."
    SET dm_err->emsg = "file_prefix must be IN ('dm2a', 'dm2o', 'dm2c')"
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    IF (file_prefix="dm2a")
     SET dgns_dcl_find = concat("dir/columns=1  ",build(directory),file_prefix,"%%%2*")
    ELSE
     SET dgns_dcl_find = concat("dir/columns=1  ",build(directory),file_prefix,"*")
    ENDIF
    SET dgns_err_str = "no files found"
   ELSEIF ((dm2_sys_misc->cur_os="WIN"))
    IF (file_prefix="dm2a")
     SET dgns_dcl_find = concat("dir ",build(directory),"\",file_prefix,"???3????_*")
    ELSE
     SET dgns_dcl_find = concat("dir ",build(directory),"\",file_prefix,"*")
    ENDIF
    SET dgns_err_str = "file not found"
   ELSE
    IF (file_prefix="dm2a")
     IF ((dm2_sys_misc->cur_os="LNX"))
      SET dgns_dcl_find = concat("ls -t ",build(directory),"/",file_prefix,"???4* | wc -w")
     ELSE
      SET dgns_dcl_find = concat("ls -t ",build(directory),"/",file_prefix,"???1* | wc -w")
     ENDIF
    ELSE
     SET dgns_dcl_find = concat("ls -t ",build(directory),"/",file_prefix,"* | wc -w")
    ENDIF
    SET dgns_err_str = "0"
   ENDIF
   IF (dm2_push_dcl(dgns_dcl_find)=0)
    IF (findstring(dgns_err_str,cnvtlower(dm_err->errtext)) > 0)
     SET dm_err->eproc = "Find schema date."
     SET dm_err->emsg = "No schema date was found."
     SET dm_err->err_ind = 0
     RETURN(1)
    ENDIF
    RETURN(0)
   ELSE
    IF ((dm2_sys_misc->cur_os IN ("AIX", "HPX", "LNX")))
     IF (file_prefix="dm2a")
      IF ((dm2_sys_misc->cur_os="LNX"))
       SET dgns_dcl_find = concat("ls -l ",build(directory),"/",file_prefix,"???4* ")
      ELSE
       SET dgns_dcl_find = concat("ls -l ",build(directory),"/",file_prefix,"???1* ")
      ENDIF
     ELSE
      SET dgns_dcl_find = concat("ls - ",build(directory),"/",file_prefix,"* ")
     ENDIF
     SET dm_err->eproc = "Building list of schema files to gather schema date"
     IF (dm2_push_dcl(dgns_dcl_find)=0)
      RETURN(0)
     ENDIF
    ENDIF
    FREE DEFINE rtl
    FREE SET file_loc
    SET logical file_loc value(dm_err->errfile)
    DEFINE rtl "file_loc"
    SELECT INTO "nl:"
     r.line
     FROM rtlt r
     HEAD REPORT
      compare_date = cnvtdate("01011800"), stripped_date = cnvtdate("01011800")
     DETAIL
      IF ((dm2_sys_misc->cur_os="AXP"))
       starting_pos = findstring(cnvtupper(file_prefix),r.line)
      ELSE
       starting_pos = findstring(file_prefix,r.line)
      ENDIF
      stripped_date = cnvtdate(substring((starting_pos+ 4),8,r.line))
      IF (stripped_date > compare_date)
       schema_date = format(stripped_date,"DD-MMM-YYYY;;d"), compare_date = stripped_date
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_list_of_files(dglf_prefix)
   DECLARE dglf_str = vc WITH protect
   SET dm_err->eproc = "Getting help list of schema files to select from."
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET dglf_str = concat("dir/version=1/columns=1 cer_install:",dglf_prefix,"*_h.dat ")
   ELSEIF ((dm2_sys_misc->cur_os="WIN"))
    SET dglf_str = concat("dir ",dm2_install_schema->cer_install,"\",dglf_prefix,"*_h.dat /B")
   ELSE
    SET dglf_str = concat('find $cer_install -name "',dglf_prefix,'*_h.dat" -print')
   ENDIF
   IF (dm2_push_dcl(value(dglf_str))=0)
    RETURN(0)
   ENDIF
   FREE DEFINE rtl
   FREE SET file_loc
   SET logical file_loc value(dm_err->errfile)
   DEFINE rtl "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtlt r
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET message = nowindow
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_find_data_file(dfdf_file_found)
   DECLARE dtd_data_file = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Finding data files"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dba_data_files ddf
    DETAIL
     dtd_data_file = ddf.file_name
    WITH maxqual(ddf,1), nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dfdf_file_found = findfile(dtd_data_file)
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("file found ind =",dfdf_file_found))
    CALL echo(build("file name =",dtd_data_file))
   ENDIF
   IF (dfdf_file_found=0)
    SET dm_err->eproc = "Datafile not visible at operating system level"
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_managed_ddl_setup(dmds_runid)
   DECLARE dmds_rowcnt = f8 WITH protect, noconstant(0.0)
   DECLARE dmds_ndx = i4 WITH protect, noconstant(0)
   DECLARE dmds_priority = i4 WITH protect, noconstant(0)
   SET dir_managed_ddl->setup_complete = 0
   IF (dm2_get_rdbms_version(null)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Check if Managed DDL oracle version"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_MANAGED_DDL_ORAVER"
    DETAIL
     IF (d.info_name=build(dm2_rdbms_version->level1,".",dm2_rdbms_version->level2,".",
      dm2_rdbms_version->level3,
      ".",dm2_rdbms_version->level4))
      dir_managed_ddl->oraversion = d.info_name, dir_managed_ddl->managed_ddl_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dir_managed_ddl->managed_ddl_ind=1))
    SET dm_err->eproc = "Check for row_cnt override for Managed DDL"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="DM2_MANAGED_DDL_ROWCNT"
     DETAIL
      dmds_rowcnt = d.info_number
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dmds_rowcnt > 0.0)
     SET dm_err->eproc = concat("Managed DDL Rowcnt Override: ",build(dmds_rowcnt))
     CALL disp_msg("",dm_err->logfile,0)
    ELSE
     SET dmds_rowcnt = 10000
    ENDIF
    SET dm_err->eproc = "Load Managed DDL Priorities"
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm2_ddl_ops_log d,
      dm_dba_tables_actual_stats t
     WHERE d.run_id=dmds_runid
      AND d.op_type IN (
     (SELECT
      di.info_name
      FROM dm_info di
      WHERE di.info_domain="DM2_MANAGED_DDL_OP_TYPE"))
      AND d.table_name != "DM*"
      AND d.table_name=t.table_name
      AND t.num_rows > dmds_rowcnt
      AND (( EXISTS (
     (SELECT
      "x"
      FROM dm_info di
      WHERE di.info_domain="DM2_MIXED_TABLE-EXPORT-REFERENCE"
       AND di.info_name=d.table_name))) OR ( EXISTS (
     (SELECT
      "x"
      FROM dm_tables_doc dtd
      WHERE dtd.reference_ind=0
       AND dtd.table_name=d.table_name))))
      AND ((d.status != "COMPLETE") OR (d.status = null))
     ORDER BY d.priority, d.table_name
     HEAD d.priority
      dmds_ndx = 0, dmds_priority = d.priority
      IF ((dir_managed_ddl->priority_cnt > 0))
       dmds_ndx = locateval(dmds_ndx,1,dir_managed_ddl->priority_cnt,dmds_priority,dir_managed_ddl->
        priorities[dmds_ndx].priority)
      ENDIF
      IF (dmds_ndx=0)
       dir_managed_ddl->priority_cnt = (dir_managed_ddl->priority_cnt+ 1)
       IF (mod(dir_managed_ddl->priority_cnt,100)=1)
        stat = alterlist(dir_managed_ddl->priorities,(dir_managed_ddl->priority_cnt+ 99))
       ENDIF
       dir_managed_ddl->priorities[dir_managed_ddl->priority_cnt].priority = d.priority
      ENDIF
     HEAD d.table_name
      dmds_ndx = 0
      IF ((dir_managed_ddl->table_cnt > 0))
       dmds_ndx = locateval(dmds_ndx,1,dir_managed_ddl->table_cnt,d.table_name,dir_managed_ddl->
        tables[dmds_ndx].table_name)
      ENDIF
      IF (dmds_ndx=0)
       dir_managed_ddl->table_cnt = (dir_managed_ddl->table_cnt+ 1)
       IF (mod(dir_managed_ddl->table_cnt,100)=1)
        stat = alterlist(dir_managed_ddl->tables,(dir_managed_ddl->table_cnt+ 99))
       ENDIF
       dir_managed_ddl->tables[dir_managed_ddl->table_cnt].table_name = d.table_name
      ENDIF
     FOOT REPORT
      stat = alterlist(dir_managed_ddl->tables,dir_managed_ddl->table_cnt), stat = alterlist(
       dir_managed_ddl->priorities,dir_managed_ddl->priority_cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET dir_managed_ddl->managed_ddl_ind = 0
    ENDIF
   ENDIF
   SET dir_managed_ddl->setup_complete = 1
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dir_managed_ddl)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_perform_wait_interval(null)
   DECLARE dpwi_pause_interval = i4 WITH protect, noconstant(1)
   SET dm_err->eproc = "Obtain pause interval"
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_INSTALL_PKG"
     AND d.info_name="PAUSE_INTERVAL"
    DETAIL
     dpwi_pause_interval = d.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Pausing for ",build(dpwi_pause_interval)," minutes.")
   CALL disp_msg("",dm_err->logfile,0)
   CALL pause((dpwi_pause_interval * 60))
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_storage_type(dgst_db_link)
   IF ((dm2_sys_misc->cur_db_os="AXP"))
    SET dir_storage_misc->cur_storage_type = "AXP"
    SET dir_storage_misc->tgt_storage_type = "AXP"
    SET dir_storage_misc->src_storage_type = "AXP"
   ELSE
    IF (dgst_db_link > " "
     AND dgst_db_link != "DM2NOTSET")
     SET dm_err->eproc = "Determine source storage type from dba_data_files"
     CALL disp_msg("",dm_err->logfile,0)
     SELECT INTO "nl:"
      FROM (parser(concat("dba_data_files@",dgst_db_link)) ddf)
      WHERE ddf.tablespace_name="SYSTEM"
       AND ddf.file_name=patstring("/dev/*")
      DETAIL
       dir_storage_misc->src_storage_type = "RAW"
      WITH nocounter, maxqual = 1
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (curqual=0)
      SET dir_storage_misc->src_storage_type = "ASM"
     ENDIF
    ENDIF
    SET dm_err->eproc = "Determine target storage type from dba_data_files"
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dba_data_files ddf
     WHERE ddf.tablespace_name="SYSTEM"
     DETAIL
      IF (ddf.file_name=patstring("/dev/*"))
       dir_storage_misc->cur_storage_type = "RAW", dir_storage_misc->tgt_storage_type = "RAW"
      ELSEIF (ddf.file_name=patstring("+*"))
       dir_storage_misc->cur_storage_type = "ASM", dir_storage_misc->tgt_storage_type = "ASM"
      ELSE
       dir_storage_misc->cur_storage_type = "RAW", dir_storage_misc->tgt_storage_type = "RAW"
      ENDIF
     WITH nocounter, maxqual = 1
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dir_storage_misc)
   ENDIF
   IF (validate(dm2_tgt_storage_type,"XXX") IN ("RAW", "ASM"))
    SET dir_storage_misc->cur_storage_type = dm2_tgt_storage_type
    SET dir_storage_misc->tgt_storage_type = dm2_tgt_storage_type
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dir_storage_misc)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_check_dm_ocd_setup_admin(dcdosa_requires_execution,dcdosa_install_mode)
   DECLARE dcdosa_compare_date = vc WITH protect, noconstant("")
   DECLARE dcdosa_cer_install = vc WITH protect, noconstant("")
   DECLARE dcdosa_schema_date = i4 WITH protect, noconstant(0)
   DECLARE dcdosa_dm_info_dm_ocd_setup_admin_date = dq8 WITH protect, noconstant(0.0)
   DECLARE dcdosa_dm_info_dm2_create_system_defs_date = dq8 WITH protect, noconstant(0.0)
   DECLARE dcdosa_dm_info_schema_date = i4 WITH protect, noconstant(0)
   DECLARE dcdosa_dm_info_dm2_set_adm_cbo_date = dq8 WITH protect, noconstant(0.0)
   SET dcdosa_requires_execution = 0
   IF (currdb != "ORACLE")
    SET dm_err->eproc = "Admin Setup Bypassed - Database must be on Oracle to perform Admin setup."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    RETURN(1)
   ELSEIF ( NOT ((dm2_sys_misc->cur_os IN ("HPX", "AIX", "AXP", "LNX", "WIN"))))
    SET dm_err->eproc =
    "Admin Setup Bypassed - o/s must be HPX, AIX, VMS, LNX or WIN to perform Admin Setup."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    RETURN(1)
   ELSEIF ( NOT (dcdosa_install_mode IN ("UPTIME", "BATCHUP", "PREVIEW", "BATCHPREVIEW", "EXPRESS",
   "BATCHEXPRESS")))
    SET dm_err->eproc = "Checking install mode"
    SET dm_err->eproc = concat("Admin Setup Bypassed - Install mode needs to be ",
     " UPTIME, BATCHUP, PREVIEW, BATCHPREVIEW, EXPRESS or BATCHEXPRESS to perform Admin Setup.")
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    RETURN(1)
   ENDIF
   IF (dm2_get_rdbms_version(null)=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(build("clinical database version : ",dm2_rdbms_version->level1))
   ENDIF
   SET dm_err->eproc = "Selecting dm_info rows."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM_OCD_SETUP_ADMIN COMPLETE"
     AND di.info_name IN ("SCHEMA_DATE", "DM_OCD_SETUP_ADMIN_DATE", "DM2_CREATE_SYSTEM_DEFS_DATE",
    "DM2_SET_ADM_CBO_DATE")
    HEAD REPORT
     dcdosa_dm_info_schema_date = 0, dcdosa_dm_info_dm_ocd_setup_admin_date = 0.0,
     dcdosa_dm_info_dm2_create_system_defs_date = 0.0,
     dcdosa_dm_info_dm2_set_adm_cbo_date = 0.0
    DETAIL
     CASE (di.info_name)
      OF "SCHEMA_DATE":
       dcdosa_dm_info_schema_date = cnvtdate2(di.info_char,"DD-MMM-YYYY")
      OF "DM_OCD_SETUP_ADMIN_DATE":
       dcdosa_dm_info_dm_ocd_setup_admin_date = cnvtdatetime(di.info_char)
      OF "DM2_CREATE_SYSTEM_DEFS_DATE":
       dcdosa_dm_info_dm2_create_system_defs_date = cnvtdatetime(di.info_char)
      OF "DM2_SET_ADM_CBO_DATE":
       dcdosa_dm_info_dm2_set_adm_cbo_date = cnvtdatetime(di.info_char)
     ENDCASE
    WITH nocounter, nullreport
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Finding newest schema file."
   CALL disp_msg("",dm_err->logfile,0)
   SET dcdosa_cer_install = cnvtlower(trim(logical("cer_install"),3))
   IF (dcfr_sea_csv_files(dcdosa_cer_install,"dm2a",dcdosa_compare_date)=0)
    RETURN(0)
   ELSE
    IF (dcdosa_compare_date="01-JAN-1800")
     SET dm_err->eproc = "Searching for Schema files."
     SET dm_err->emsg = "No schema files present in cer_install."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     SET dcdosa_schema_date = cnvtdate2(dcdosa_compare_date,"DD-MMM-YYYY")
    ENDIF
   ENDIF
   SET dm_err->eproc = "Selecting date/timestamps from dprotect."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dprotect dp
    WHERE dp.object="P"
     AND dp.object_name IN ("DM_OCD_SETUP_ADMIN", "DM2_CREATE_SYSTEM_DEFS", "DM2_SET_ADM_CBO")
    DETAIL
     CASE (dp.object_name)
      OF "DM_OCD_SETUP_ADMIN":
       dm_ocd_setup_admin_data->dm_ocd_setup_admin_date = cnvtdatetime(dp.datestamp,dp.timestamp)
      OF "DM2_CREATE_SYSTEM_DEFS":
       dm_ocd_setup_admin_data->dm2_create_system_defs = cnvtdatetime(dp.datestamp,dp.timestamp)
      OF "DM2_SET_ADM_CBO":
       dm_ocd_setup_admin_data->dm2_set_adm_cbo = cnvtdatetime(dp.datestamp,dp.timestamp)
     ENDCASE
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echo(build("dcdosa_dm_info_schema_date:",dcdosa_dm_info_schema_date))
    CALL echo(build("dcdosa_schema_date:",dcdosa_schema_date))
    CALL echo(build("dcdosa_dm_info_dm_ocd_setup_admin_date:",dcdosa_dm_info_dm_ocd_setup_admin_date)
     )
    CALL echo(build("dm_ocd_setup_admin_data->dm_ocd_setup_admin_date:",dm_ocd_setup_admin_data->
      dm_ocd_setup_admin_date))
    CALL echo(build("dcdosa_dm_info_dm2_create_system_defs_date:",
      dcdosa_dm_info_dm2_create_system_defs_date))
    CALL echo(build("dm_ocd_setup_admin_data->dm2_create_system_defs:",dm_ocd_setup_admin_data->
      dm2_create_system_defs))
    CALL echo(build("dcdosa_dm_info_dm2_set_adm_cbo_date:",dcdosa_dm_info_dm2_set_adm_cbo_date))
    CALL echo(build("dm_ocd_setup_admin_data->dm2_set_adm_cbo:",dm_ocd_setup_admin_data->
      dm2_set_adm_cbo))
   ENDIF
   IF ((dm2_rdbms_version->level1 < 11))
    IF (((dcdosa_dm_info_schema_date < dcdosa_schema_date) OR ((((
    dcdosa_dm_info_dm_ocd_setup_admin_date < dm_ocd_setup_admin_data->dm_ocd_setup_admin_date)) OR ((
    dcdosa_dm_info_dm2_create_system_defs_date < dm_ocd_setup_admin_data->dm2_create_system_defs)))
    )) )
     SET dcdosa_requires_execution = 1
     RETURN(1)
    ENDIF
   ELSE
    IF (((dcdosa_dm_info_schema_date < dcdosa_schema_date) OR ((((
    dcdosa_dm_info_dm_ocd_setup_admin_date < dm_ocd_setup_admin_data->dm_ocd_setup_admin_date)) OR (
    (((dcdosa_dm_info_dm2_create_system_defs_date < dm_ocd_setup_admin_data->dm2_create_system_defs))
     OR ((dcdosa_dm_info_dm2_set_adm_cbo_date < dm_ocd_setup_admin_data->dm2_set_adm_cbo))) )) )) )
     SET dcdosa_requires_execution = 1
    ENDIF
    RETURN(1)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_check_for_package(dcfp_valid_ind,dcfp_env_id)
   SET dcfp_valid_ind = 0
   SET dcfp_env_id = 0.0
   IF (currdbuser != "V500")
    IF ((dm_err->debug_flag > 1))
     CALL echo("Bypassing check for package history.")
    ENDIF
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Find environment id."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info i
    WHERE i.info_domain="DATA MANAGEMENT"
     AND i.info_name="DM_ENV_ID"
    DETAIL
     dcfp_env_id = i.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dcfp_valid_ind = 0
    RETURN(1)
   ENDIF
   SET dm_err->eproc = build("Look for package history for environment id :",dcfp_env_id)
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_ocd_log l
    WHERE l.environment_id=dcfp_env_id
    WITH nocounter, maxqual(l,1)
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dcfp_valid_ind = 0
   ELSE
    SET dcfp_valid_ind = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_dg_data(dgdd_assign_dg_ind,dgdd_dg_override,dgdd_dg_out)
   DECLARE dgdd_dskgrp_name = vc WITH protect, noconstant("")
   DECLARE dgdd_dskgrp_state = vc WITH protect, noconstant("")
   DECLARE dgdd_chck = i2 WITH protect, noconstant(1)
   SET dm_err->eproc = "Get diskgroup information"
   CALL disp_msg("",dm_err->logfile,0)
   SET dgdd_dg_out = "NOT_SET"
   IF ((dm_err->debug_flag >= 2))
    CALL echo(build("Use initprm assign dg ind->",dgdd_assign_dg_ind))
    CALL echo(build("Diskgroup override->",dgdd_dg_override))
   ENDIF
   IF (dgdd_dg_override != "NOT_SET")
    SET dm_err->eproc = "Query for state of disk group "
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM v$asm_diskgroup v
     WHERE v.name=dgdd_dg_override
     DETAIL
      dgdd_dskgrp_state = cnvtupper(v.state)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dgdd_dskgrp_state IN ("MOUNTED", "CONNECTED"))
     SET dgdd_dg_out = dgdd_dg_override
     SET dgdd_chck = 0
    ENDIF
   ENDIF
   IF (dgdd_assign_dg_ind=1
    AND dgdd_chck=1)
    SET dm_err->eproc = "Query for disk group using db_create_file_dest"
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM v$parameter v
     WHERE v.name="db_create_file_dest"
     DETAIL
      dgdd_dskgrp_name = cnvtupper(v.value)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (findstring("+",dgdd_dskgrp_name,1,0) > 0)
     SET dgdd_dskgrp_name = trim(replace(dgdd_dskgrp_name,"+","",1),3)
    ENDIF
    SET dm_err->eproc = "Query to validate diskgroup"
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM v$asm_diskgroup v
     WHERE v.name=dgdd_dskgrp_name
     DETAIL
      dgdd_dskgrp_state = cnvtupper(v.state)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dgdd_dskgrp_state IN ("MOUNTED", "CONNECTED"))
     SET dgdd_dg_out = dgdd_dskgrp_name
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag >= 2))
    CALL echo(build("Determined diskgroup->",dgdd_dg_out))
   ENDIF
   IF (dgdd_dg_out != "NOT_SET")
    SET dir_ui_misc->tspace_dg = dgdd_dg_out
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_submit_jobs(dsj_plan_id,dsj_install_mode,dsj_user,dsj_pword,dsj_cnnct_str,
  dsj_queue_name,dsj_background_ind)
   DECLARE dsj_wait_time_minutes = i2 WITH protect, noconstant(15)
   DECLARE dsj_wait_timestamp = f8 WITH protect, noconstant(0.0)
   DECLARE dsj_wait_for_start = i2 WITH protect, noconstant(0)
   FREE RECORD dsj_request
   RECORD dsj_request(
     1 plan_id = f8
     1 install_mode = vc
   )
   FREE RECORD dsj_reply
   RECORD dsj_reply(
     1 install_status = vc
     1 event = vc
     1 install_mode_ret = vc
     1 message = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET dsj_request->plan_id = dsj_plan_id
   SET dsj_request->install_mode = "CURRENT"
   SET dsj_wait_timestamp = cnvtdatetime(curdate,curtime3)
   SET dm_err->eproc = "Get the status of auto installation"
   CALL disp_msg(" ",dm_err->logfile,0)
   EXECUTE dm2_auto_install_status  WITH replace("REQUEST",dsj_request), replace("REPLY",dsj_reply)
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ELSE
    IF ((dsj_reply->install_status="EXECUTING"))
     SET dm_err->eproc = "Checking the status of the auto install process"
     SET dm_err->emsg = concat("Active package install running for ",dsj_reply->install_mode_ret)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "submit the package install to background"
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (drr_submit_background_process(dsj_user,dsj_pword,dsj_cnnct_str,dsj_queue_name,
    dpl_package_install,
    dsj_plan_id,dsj_install_mode)=0)
    RETURN(0)
   ENDIF
   IF (dsj_install_mode="*ABG")
    SET dsj_install_mode = replace(dsj_install_mode,"ABG","",2)
   ENDIF
   SET dm_err->eproc = "Waiting for background installation process to begin."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET dm_err->eproc = "Check for wait time override"
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_SUBMIT_TIME_WAIT"
     AND d.info_name="MINUTES"
    DETAIL
     dsj_wait_time_minutes = d.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dsj_wait_for_start = 1
   WHILE (dsj_wait_for_start=1)
     IF (drr_cleanup_dm_info_runners(null)=0)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = "Wait for install to begin execution."
     SELECT INTO "nl:"
      FROM dm_process dp,
       dm_process_event dpe,
       dm_process_event_dtl dped1,
       dm_process_event_dtl dped2
      PLAN (dpe
       WHERE dpe.install_plan_id=dsj_plan_id
        AND dpe.begin_dt_tm >= cnvtdatetime(dsj_wait_timestamp))
       JOIN (dp
       WHERE dp.dm_process_id=dpe.dm_process_id
        AND dp.process_name=dpl_package_install
        AND dp.action_type=dpl_execution)
       JOIN (dped1
       WHERE dpe.dm_process_event_id=dped1.dm_process_event_id
        AND dped1.detail_type="INSTALL_MODE"
        AND dped1.detail_text=dsj_install_mode)
       JOIN (dped2
       WHERE dped1.dm_process_event_id=dped2.dm_process_event_id
        AND dped2.detail_type="UNATTENDED_IND")
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
     IF (curqual > 0)
      SET dsj_wait_for_start = 0
     ENDIF
     IF (datetimediff(cnvtdatetimeutc(cnvtdatetime(curdate,curtime3)),cnvtdatetimeutc(cnvtdatetime(
        dsj_wait_timestamp)),4) > dsj_wait_time_minutes
      AND dsj_wait_for_start=1)
      SET dm_err->err_ind = 1
      SET dm_err->emsg = "Wait time expired. Unable to detect background install process."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     CALL pause(5)
   ENDWHILE
   IF (drr_submit_background_process(dsj_user,dsj_pword,dsj_cnnct_str,dsj_queue_name,
    dpl_install_monitor,
    dsj_plan_id,dsj_install_mode)=0)
    RETURN(0)
   ENDIF
   IF (dsj_background_ind=0)
    SET width = 132
    SET message = window
    CALL clear(1,1)
    CALL text(1,1,concat("The ",dsj_install_mode,
      " Installation is now submitted as a background process."))
    CALL text(3,1,"This session/connection is no longer required.")
    CALL text(5,1,"Notification emails about Installation events will be sent as they occur.")
    CALL text(8,1,concat("To monitor, stop or pause the execution of the background ",
      dsj_install_mode," Installation process,"))
    CALL text(9,1,"you can execute the following in CCL:")
    CALL text(11,1,"ccl> dm2_install_plan_menu go ")
    CALL text(13,3,"Enter 'C' to continue.")
    CALL accept(13,34,"p;cduh"," "
     WHERE curaccept IN ("C"))
    CALL clear(1,1)
    SET message = nowindow
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_check_in_parse(dcp_owner,dcp_table_name,dcp_in_parse_ind,dcp_ret_msg)
   SET dcp_in_parse_ind = 0
   SET dcp_ret_msg = ""
   SET dm_err->eproc = concat("Check if ",dcp_table_name," table is involved in a hard parse event.")
   SELECT INTO "nl:"
    FROM dm2_objects_in_parse d
    WHERE d.to_owner=dcp_owner
     AND d.to_name=dcp_table_name
    DETAIL
     dcp_in_parse_ind = 1, dcp_ret_msg = concat("Encountered parse event against ",trim(dcp_owner),
      ".",dcp_table_name,". SQL_ID = ",
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
 SUBROUTINE dir_get_ddl_gen_retry(dgr_retry_ceiling)
   DECLARE dgr_di_exists = i2 WITH protect, noconstant(0)
   SET dgr_retry_ceiling = 10
   IF (dm2_table_and_ccldef_exists("DM_INFO",dgr_di_exists)=0)
    RETURN(0)
   ENDIF
   IF (dgr_di_exists=1)
    SET dm_err->eproc = "Check for retry ceiling override."
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="DM2_DDL_GEN"
      AND d.info_name="RETRY CEILING"
     DETAIL
      dgr_retry_ceiling = d.info_number
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dgr_retry_ceiling <= 0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Retry ceiling is invalid (must be greater than zero)."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_load_users_pwds(dlup_users_for_pwd)
   DECLARE dlup_user = vc WITH protect, noconstant("")
   DECLARE dlup_notfnd = vc WITH protect, constant("<not_found>")
   DECLARE dlup_num = i4 WITH protect, noconstant(1)
   DECLARE dlup_idx = i2 WITH protect, noconstant(0)
   DECLARE dlup_choice = vc WITH protect, noconstant("")
   IF (size(dlup_users_for_pwd)=0)
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Loading users into record structure for password prompt."
    SET dm_err->emsg = "No user specified."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Loading users into record structure for password prompt."
   CALL disp_msg(" ",dm_err->logfile,0)
   WHILE (dlup_user != dlup_notfnd)
     SET dlup_user = piece(dlup_users_for_pwd,",",dlup_num,dlup_notfnd)
     SET dlup_num = (dlup_num+ 1)
     IF (dlup_user != dlup_notfnd)
      SET dlup_idx = locateval(dlup_idx,1,dir_db_users_pwds->cnt,dlup_user,dir_db_users_pwds->qual[
       dlup_idx].user)
      IF (dlup_idx=0)
       SET dir_db_users_pwds->cnt = (dir_db_users_pwds->cnt+ 1)
       SET stat = alterlist(dir_db_users_pwds->qual,dir_db_users_pwds->cnt)
       SET dir_db_users_pwds->qual[dir_db_users_pwds->cnt].user = dlup_user
       CALL clear(1,1)
       CALL text(6,2,concat("Please enter password for user ",dir_db_users_pwds->qual[
         dir_db_users_pwds->cnt].user,": "))
       CALL text(10,1,"Enter 'C' to continue or 'Q' to exit process. (C or Q): ")
       CALL accept(6,50,"P(30);C"," "
        WHERE  NOT (curaccept=" "))
       SET dir_db_users_pwds->qual[dir_db_users_pwds->cnt].pwd = build(curaccept)
       CALL accept(10,60,"A;cu"," "
        WHERE curaccept IN ("Q", "C"))
       SET dlup_choice = curaccept
       IF (dlup_choice="Q")
        SET message = nowindow
        SET dm_err->err_ind = 1
        SET dm_err->emsg = "User quit process.  "
        SET dm_err->eproc = "Prompting for database user password."
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
   ENDWHILE
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dir_db_users_pwds)
   ENDIF
   IF ((dir_db_users_pwds->cnt=0))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating user/password list."
    SET dm_err->emsg = "Database user/password not loaded into memory."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_adm_appl_status(dgaps_dblink,dgaps_audsid,dgaps_status)
   SET dgaps_status = "ACTIVE"
   IF (cnvtupper(dgaps_audsid)="-15301")
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    FROM (value(concat("GV$SESSION@",dgaps_dblink)) s)
    WHERE s.audsid=cnvtint(dgaps_audsid)
    WITH nocounter
   ;end select
   IF (check_error("Selecting from gv$session in subroutine dir_get_adm_appl_status")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SELECT INTO "nl:"
     FROM (value(concat("V$SESSION@",dgaps_dblink)) s)
     WHERE s.audsid=cnvtint(dgaps_audsid)
     WITH nocounter
    ;end select
    IF (check_error("Selecting from v$session in subroutine dir_get_adm_appl_status")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     SET dgaps_status = "INACTIVE"
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_upd_adm_upgrade_info(null)
   DECLARE duaui_schema_date = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Deleting from dm_info for dm_ocd_setup_admin."
   CALL disp_msg(" ",dm_err->logfile,0)
   DELETE  FROM dm_info di
    WHERE di.info_domain="DM_OCD_SETUP_ADMIN COMPLETE"
     AND di.info_name IN ("SCHEMA_DATE", "DM_OCD_SETUP_ADMIN_DATE", "DM2_CREATE_SYSTEM_DEFS_DATE",
    "DM2_SET_ADM_CBO_DATE")
    WITH nocounter
   ;end delete
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   IF (dcfr_sea_csv_files(cnvtlower(trim(logical("cer_install"),3)),"dm2a",duaui_schema_date)=0)
    RETURN(0)
   ELSE
    IF (duaui_schema_date="01-JAN-1800")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("Schema Date: ",duaui_schema_date))
   ENDIF
   SET dm_err->eproc = "Selecting date/timestamps from dprotect."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dprotect dp
    WHERE dp.object="P"
     AND dp.object_name IN ("DM_OCD_SETUP_ADMIN", "DM2_CREATE_SYSTEM_DEFS", "DM2_SET_ADM_CBO")
    DETAIL
     CASE (dp.object_name)
      OF "DM_OCD_SETUP_ADMIN":
       dm_ocd_setup_admin_data->dm_ocd_setup_admin_date = cnvtdatetime(dp.datestamp,dp.timestamp)
      OF "DM2_CREATE_SYSTEM_DEFS":
       dm_ocd_setup_admin_data->dm2_create_system_defs = cnvtdatetime(dp.datestamp,dp.timestamp)
      OF "DM2_SET_ADM_CBO":
       dm_ocd_setup_admin_data->dm2_set_adm_cbo = cnvtdatetime(dp.datestamp,dp.timestamp)
     ENDCASE
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Inserting schema_date row into dm_info."
   CALL disp_msg(" ",dm_err->logfile,0)
   INSERT  FROM dm_info di
    SET di.info_domain = "DM_OCD_SETUP_ADMIN COMPLETE", di.info_name = "SCHEMA_DATE", di.info_char =
     duaui_schema_date,
     di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = 0, di.updt_cnt = 0,
     di.updt_id = 0, di.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Inserting dm_ocd_setup_admin_date row into dm_info."
   CALL disp_msg(" ",dm_err->logfile,0)
   INSERT  FROM dm_info di
    SET di.info_domain = "DM_OCD_SETUP_ADMIN COMPLETE", di.info_name = "DM_OCD_SETUP_ADMIN_DATE", di
     .info_char = format(dm_ocd_setup_admin_data->dm_ocd_setup_admin_date,"DD-MMM-YYYY HH:MM:SS;;q"),
     di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = 0, di.updt_cnt = 0,
     di.updt_id = 0, di.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Inserting dm2_create_system_defs_date row into dm_info."
   CALL disp_msg(" ",dm_err->logfile,0)
   INSERT  FROM dm_info di
    SET di.info_domain = "DM_OCD_SETUP_ADMIN COMPLETE", di.info_name = "DM2_CREATE_SYSTEM_DEFS_DATE",
     di.info_char = format(dm_ocd_setup_admin_data->dm2_create_system_defs,"DD-MMM-YYYY HH:MM:SS;;q"),
     di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = 0, di.updt_cnt = 0,
     di.updt_id = 0, di.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Inserting dm2_set_adm_cbo_date row into dm_info."
   CALL disp_msg(" ",dm_err->logfile,0)
   INSERT  FROM dm_info di
    SET di.info_domain = "DM_OCD_SETUP_ADMIN COMPLETE", di.info_name = "DM2_SET_ADM_CBO_DATE", di
     .info_char = format(dm_ocd_setup_admin_data->dm2_set_adm_cbo,"DD-MMM-YYYY HH:MM:SS;;q"),
     di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_applctx = 0, di.updt_cnt = 0,
     di.updt_id = 0, di.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_custom_constraints(null)
   DECLARE dgcc_constraint_index = i2 WITH protect, noconstant(0)
   SET dir_custom_constraints->con_cnt = 0
   SET stat = initrec(dir_custom_constraints)
   SET dm_err->eproc = "Retrieving custom constraints"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_CUSTOM_CONSTRAINTS"
    DETAIL
     dgcc_constraint_index = (dgcc_constraint_index+ 1)
     IF (mod(dgcc_constraint_index,10)=1)
      stat = alterlist(dir_custom_constraints->con,(dgcc_constraint_index+ 9))
     ENDIF
     dir_custom_constraints->con[dgcc_constraint_index].constraint_name = di.info_name
    FOOT REPORT
     stat = alterlist(dir_custom_constraints->con,dgcc_constraint_index), dir_custom_constraints->
     con_cnt = dgcc_constraint_index
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dgcc_constraint_index=0)
    SET stat = alterlist(dir_custom_constraints->con,2)
    SET dir_custom_constraints->con[1].constraint_name = "CUCIM_ACQUIRED_STUDY"
    SET dir_custom_constraints->con[2].constraint_name = "CUCIM_SERIES"
    SET dir_custom_constraints->con_cnt = 2
   ELSE
    SET dgcc_constraint_index = 0
    IF (locateval(dgcc_constraint_index,1,dir_custom_constraints->con_cnt,"CUCIM_ACQUIRED_STUDY",
     dir_custom_constraints->con[dgcc_constraint_index].constraint_name)=0)
     SET dir_custom_constraints->con_cnt = (dir_custom_constraints->con_cnt+ 1)
     SET stat = alterlist(dir_custom_constraints->con,dir_custom_constraints->con_cnt)
     SET dir_custom_constraints->con[dir_custom_constraints->con_cnt].constraint_name =
     "CUCIM_ACQUIRED_STUDY"
    ENDIF
    SET dgcc_constraint_index = 0
    IF (locateval(dgcc_constraint_index,1,dir_custom_constraints->con_cnt,"CUCIM_SERIES",
     dir_custom_constraints->con[dgcc_constraint_index].constraint_name)=0)
     SET dir_custom_constraints->con_cnt = (dir_custom_constraints->con_cnt+ 1)
     SET stat = alterlist(dir_custom_constraints->con,dir_custom_constraints->con_cnt)
     SET dir_custom_constraints->con[dir_custom_constraints->con_cnt].constraint_name =
     "CUCIM_SERIES"
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dir_get_admin_db_link(dgadl_report_fail_ind,dgadl_admin_db_link,dgadl_fail_ind)
   DECLARE dgadl_admin_env_id = f8 WITH protect, noconstant(0.0)
   DECLARE dgadl_admin_link_match = i2 WITH protect, noconstant(0)
   SET dgadl_fail_ind = 0
   SET dm_err->eproc = "Obtain Admin database link name"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_environment de,
     dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="DM_ENV_ID"
     AND de.environment_id=di.info_number
    DETAIL
     dgadl_admin_db_link = de.admin_dbase_link_name, dgadl_admin_env_id = de.environment_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (textlen(dgadl_admin_db_link)=0)
    SET dgadl_fail_ind = 1
    IF (dgadl_report_fail_ind=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Admin database link is not valued in DM_ENVIRONMENT.admin_dbase_link_name."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dgadl_fail_ind=0)
    SET dm_err->eproc = "Validate Admin database link name"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (parser(concat("cdba.dm_environment@",dgadl_admin_db_link)) de)
     WHERE de.environment_id=dgadl_admin_env_id
     DETAIL
      IF (cnvtupper(dgadl_admin_db_link)=cnvtupper(de.admin_dbase_link_name))
       dgadl_admin_link_match = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->err_ind = 0
    ENDIF
    IF (dgadl_admin_link_match=0)
     SET dgadl_fail_ind = 1
     IF (dgadl_report_fail_ind=0)
      SET dm_err->err_ind = 1
      SET dm_err->emsg =
      "Admin database link does not exist in database or is causing data inconsistency when used."
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 IF ((validate(dmt_min_ext_size,- (1))=- (1)))
  DECLARE dmt_min_ext_size = f8 WITH public, constant(163840.0)
 ENDIF
 IF ((validate(dm2_block_size,- (1))=- (1))
  AND (validate(dm2_block_size,- (2))=- (2)))
  IF (currdb="ORACLE")
   DECLARE dm2_block_size = f8 WITH public, constant(8192.0)
  ELSEIF (currdb="DB2UDB")
   DECLARE dm2_block_size = f8 WITH public, constant(16384.0)
  ELSE
   DECLARE dm2_block_size = f8 WITH public, constant(8192.0)
  ENDIF
 ENDIF
 IF ((validate(rtspace->rtspace_cnt,- (1))=- (1)))
  FREE RECORD rtspace
  RECORD rtspace(
    1 dbname = vc
    1 tmp_table_name = vc
    1 rtspace_cnt = i4
    1 sql_size_mb = f8
    1 sql_filegrowth_mb = f8
    1 install_type = vc
    1 install_type_value = vc
    1 mode = vc
    1 ddl_report_fname = vc
    1 commands_written_ind = i2
    1 database_remote = i2
    1 unique_nbr = vc
    1 temp_tspace_name = vc
    1 temp_tspace_file_type = vc
    1 temp_tspace_ttl_mb = i4
    1 temp_tspace_reserved_pct = i4
    1 temp_tspace_reserved_mb = i4
    1 temp_tspace_ttl_needed_mb = i4
    1 temp_tspace_ratio = f8
    1 temp_tspace_indexlist[*]
      2 tbl_name = vc
      2 ind_name = vc
      2 size_mb = i4
    1 qual[*]
      2 tspace_name = vc
      2 chunk_size = f8
      2 chunks_needed = i4
      2 ext_mgmt = c1
      2 tspace_id = i4
      2 cur_bytes_allocated = f8
      2 bytes_needed = f8
      2 user_bytes_to_add = f8
      2 final_bytes_to_add = f8
      2 new_ind = i2
      2 extend_ind = i2
      2 init_ext = f8
      2 next_ext = f8
      2 cont_complete_ind = i4
      2 cont_cnt = i4
      2 ct_err_msg = vc
      2 ct_err_ind = i2
      2 asm_disk_group = vc
      2 commands[*]
        3 cmd_type = vc
        3 cmd = vc
        3 lv_file = vc
        3 lv_exist_chk = i2
      2 cont[*]
        3 volume_label = vc
        3 disk_name = vc
        3 disk_idx = i4
        3 vg_name = vc
        3 pp_size_mb = f8
        3 pps_to_add = f8
        3 add_ext_ind = c1
        3 cont_tspace_rel_key = i4
        3 space_to_add = f8
        3 delete_ind = i2
        3 cont_size_mb = f8
        3 lv_file = vc
        3 new_ind = i2
        3 mwc_flag = i2
      2 temp_ind = i2
      2 user_tspace_ind = i2
  )
  SET rtspace->install_type = "DM2NOTSET"
  SET rtspace->install_type_value = "DM2NOTSET"
  SET rtspace->mode = "DM2NOTSET"
  SET rtspace->ddl_report_fname = "DM2NOTSET"
  SET rtspace->unique_nbr = ""
 ENDIF
 IF ((validate(ddtsp->tsp_cnt,- (1))=- (1)))
  FREE RECORD ddtsp
  RECORD ddtsp(
    1 nonstd_ind = i2
    1 nonstd_tgt_ind = i2
    1 tsp_cnt = i4
    1 qual[*]
      2 tspace_name = vc
      2 ext_mgmt = c1
      2 alloc_type = vc
      2 seg_space_mgmt = vc
      2 bigfile = c3
      2 nonstd_ind = i2
      2 nonstd_tgt_ind = i2
      2 lmt_ora8_ind = i2
      2 lmt_uniform_ind = i2
      2 lmt_and_not_assm = i2
      2 lmt_bigfile = i2
      2 datafile_not_ae = i2
      2 datafile_not_unlimited = i2
      2 datafile_not_assm = i2
      2 lmt_and_not_ae = i2
  )
  SET ddtsp->nonstd_ind = 0
  SET ddtsp->nonstd_tgt_ind = 0
 ENDIF
 IF ((validate(dm2_ind_tspace_assign->cnt,- (1))=- (1)))
  FREE SET dm2_ind_tspace_assign
  RECORD dm2_ind_tspace_assign(
    1 cnt = i4
    1 qual[*]
      2 table_name = vc
      2 index_tspace = vc
      2 index_tspace_cnt = i4
      2 tspace_cnt = i4
      2 tspace[*]
        3 tspace_name = vc
        3 ind_cnt = i4
  )
  SET dm2_ind_tspace_assign->cnt = 0
 ENDIF
 IF ((validate(das_dtp->dtp_cnt,- (1))=- (1)))
  FREE RECORD das_dtp
  RECORD das_dtp(
    1 dtp_cnt = i4
    1 qual[*]
      2 tname = vc
      2 prec_cnt = i2
      2 prec[*]
        3 precedence = i2
        3 data_tspace = vc
        3 data_extent_size = f8
        3 ind_tspace = vc
        3 index_extent_size = f8
        3 long_tspace = vc
  )
  SET das_dtp->dtp_cnt = 0
 ENDIF
 IF ((validate(dtr_tspace_misc->recalc_space_needs,- (1))=- (1))
  AND (validate(dtr_tspace_misc->recalc_space_needs,- (2))=- (2)))
  FREE RECORD dtr_tspace_misc
  RECORD dtr_tspace_misc(
    1 recalc_space_needs = i2
    1 gen_id = f8
  )
  SET dtr_tspace_misc->recalc_space_needs = 0
  SET dtr_tspace_misc->gen_id = 0.0
 ENDIF
 IF ((validate(dtrt->cnt,- (1))=- (1)))
  FREE RECORD dtrt
  RECORD dtrt(
    1 cnt = i4
    1 qual[*]
      2 tspace_name = vc
  )
  SET dtrt->cnt = 0
 ENDIF
 IF ((validate(dcs_long_tspace->tspace_count,- (1))=- (1)))
  FREE SET dcs_long_tspace
  RECORD dcs_long_tspace(
    1 tspace_count = i4
    1 tspace[*]
      2 tspace_name = vc
      2 bytes = f8
      2 tbl_cnt = i4
      2 tbl[*]
        3 table_name = vc
        3 column_name = vc
  )
  SET dcs_long_tspace->tspace_count = 0
 ENDIF
 DECLARE dtr_lob_size = f8 WITH protect, constant(163840.0)
 DECLARE dtr_load_tspaces(dlt_process=vc) = i2
 DECLARE dtr_rpt_nonstd_tspace(drnt_file=vc,drnt_mode=i2) = i2
 DECLARE dtr_find_tspace(dft_tspace=vc) = i2
 DECLARE dtr_eval_nonstd_tgt_tspace(sbr_tsp_idx=i4) = i2
 DECLARE d2tr_get_man_inst_type_val(null) = i2
 DECLARE dm2_adj_size(d_adj_size=f8,d_adj_mult=f8) = f8
 DECLARE dm2_adj_init_next_ext(daine_data_to_move=vc,daine_table_type=i2,daine_table_name=vc,
  daine_init_ext=f8(ref),daine_next_ext=f8(ref)) = null
 DECLARE dtr_load_clin_tspaces(null) = i2
 SUBROUTINE dm2_adj_size(d_adj_size,d_adj_mult)
   DECLARE das_ceil_factor = f8 WITH protect, noconstant(0.0)
   DECLARE das_ret = f8 WITH protect, noconstant(0.0)
   IF (d_adj_mult > 0.0)
    SET das_ceil_factor = dm2ceil((d_adj_size/ d_adj_mult))
    SET das_ret = (d_adj_mult * das_ceil_factor)
   ELSE
    SET das_ret = d_adj_size
   ENDIF
   RETURN(das_ret)
 END ;Subroutine
 SUBROUTINE d2tr_get_man_inst_type_val(null)
   DECLARE dgmitv_info_num_hold = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Getting Manual Install_Type_Value from DM_INFO."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_TSPACE_SIZE-MAX VALUE"
     AND d.info_name="MANUAL"
    DETAIL
     dgmitv_info_num_hold = d.info_number
    WITH forupdatewait(d)
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   CASE (curqual)
    OF 1:
     SET rtspace->install_type_value = cnvtstring((dgmitv_info_num_hold+ 1))
     SET dm_err->eproc = concat("Updating Manual Install_Type_Value in DM_INFO to:",rtspace->
      install_type_value)
     CALL disp_msg("",dm_err->logfile,0)
     UPDATE  FROM dm_info d
      SET d.info_number = cnvtint(rtspace->install_type_value)
      WHERE d.info_domain="DM2_TSPACE_SIZE-MAX VALUE"
       AND d.info_name="MANUAL"
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
    OF 0:
     SET rtspace->install_type_value = "1"
     SET dm_err->eproc = "Inserting Manual Install_Type_Value into DM_INFO."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
     INSERT  FROM dm_info d
      SET d.info_domain = "DM2_TSPACE_SIZE-MAX VALUE", d.info_name = "MANUAL", d.info_number =
       cnvtint(rtspace->install_type_value)
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc) != 0)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN(0)
     ELSE
      COMMIT
     ENDIF
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_find_tspace(dft_tspace)
   DECLARE dft_idx = i4 WITH protect, noconstant(0)
   SET dft_idx = locateval(dft_idx,1,ddtsp->tsp_cnt,dft_tspace,ddtsp->qual[dft_idx].tspace_name)
   RETURN(dft_idx)
 END ;Subroutine
 SUBROUTINE dtr_rpt_nonstd_tspace(drnt_file,drnt_mode)
   DECLARE drnt_nonstd_found = i2 WITH protect, noconstant(0)
   SELECT
    IF (drnt_mode=0)
     FROM (dummyt d  WITH seq = ddtsp->tsp_cnt)
     WHERE (ddtsp->qual[d.seq].nonstd_tgt_ind=1)
    ELSE
     FROM (dummyt d  WITH seq = ddtsp->tsp_cnt)
     WHERE (ddtsp->qual[d.seq].nonstd_ind=1)
    ENDIF
    INTO value(drnt_file)
    HEAD REPORT
     row + 2,
     CALL center("Unsupported Tablespace Configuration Report",1,126), row + 2,
     col 1,
     "The following tablespaces have been found with an unsupported configuration in the current database.",
     row + 2
    DETAIL
     col 1, "Tablespace Name:", col 20,
     ddtsp->qual[d.seq].tspace_name, row + 1, col 11,
     "Issue:"
     IF ((ddtsp->qual[d.seq].lmt_ora8_ind=1))
      col 20, "Tablespace is locally managed on Oracle 8", row + 1,
      drnt_nonstd_found = 1
     ENDIF
     IF ((ddtsp->qual[d.seq].lmt_uniform_ind=1))
      col 20, "Tablespace is locally managed with uniform extents", row + 1,
      drnt_nonstd_found = 1
     ENDIF
     IF ((ddtsp->qual[d.seq].lmt_and_not_assm=1))
      col 20, "Tablespace is locally managed without automatic segment-space management", row + 1,
      drnt_nonstd_found = 1
     ENDIF
     IF ((ddtsp->qual[d.seq].datafile_not_ae=1))
      col 20, "Tablespace contains datafiles that are not autoextensible", row + 1,
      drnt_nonstd_found = 1
     ENDIF
     IF (ddtsp->qual[d.seq].datafile_not_unlimited)
      col 20, "Tablespace contains datafiles defined with a limited maxsize (not UNLIMITED)", row + 1,
      drnt_nonstd_found = 1
     ENDIF
     row + 2
    FOOT REPORT
     IF (drnt_nonstd_found=0)
      col 1, "No unsupported tablespaces returned.", row + 1
     ENDIF
    WITH nocounter, format = variable, nullreport,
     formfeed = none, maxcol = 512, append
   ;end select
   IF (check_error("Displaying Unsupported Tablespace Configuration Report") != 0)
    CALL disp_msg(" ",dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_eval_nonstd_tgt_tspace(sbr_tsp_idx)
  IF ((ddtsp->qual[sbr_tsp_idx].nonstd_ind=1))
   SET ddtsp->qual[sbr_tsp_idx].nonstd_tgt_ind = 1
   SET ddtsp->nonstd_tgt_ind = 1
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_adj_init_next_ext(daine_data_to_move,daine_table_type,daine_table_name,daine_init_ext,
  daine_next_ext)
   IF (daine_next_ext=0.0)
    SET daine_init_ext = 0.0
   ENDIF
   IF (daine_data_to_move="REF"
    AND daine_table_type=0
    AND daine_init_ext > 0.0)
    SET daine_init_ext = dmt_min_ext_size
   ENDIF
   IF (((daine_data_to_move="REF"
    AND daine_table_type IN (1, 2)) OR (daine_data_to_move="ALL"))
    AND daine_init_ext > 0.0
    AND (daine_init_ext > (5 * dm2_block_size)))
    SET daine_init_ext = dm2_adj_size(daine_init_ext,(5 * dm2_block_size))
   ENDIF
   IF (daine_data_to_move="REF"
    AND daine_table_type=0
    AND daine_next_ext > 0.0)
    SET daine_next_ext = dmt_min_ext_size
   ENDIF
   IF (((daine_data_to_move="REF"
    AND daine_table_type IN (1, 2)) OR (daine_data_to_move="ALL"))
    AND daine_next_ext > 0.0
    AND (daine_next_ext > (5 * dm2_block_size)))
    SET daine_next_ext = dm2_adj_size(daine_next_ext,(5 * dm2_block_size))
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE dtr_load_tspaces(dlt_process)
   DECLARE dlt_fatal_error = i2 WITH protect, noconstant(0)
   DECLARE dlt_ndx = i2 WITH protect, noconstant(0)
   DECLARE dlt_31g = f8 WITH protect, noconstant((((31.0 * 1024.0) * 1024.0) * 1024.0))
   IF (dm2_get_rdbms_version(null)=0)
    GO TO exit_script
   ENDIF
   SET dm_err->eproc = "Load tablespace content."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT
    IF (dlt_process="CLIN COPY")
     FROM dm2_dba_tablespaces dbt
    ELSEIF (dlt_process="REPORT")
     FROM dm2_dba_tablespaces dbt
     WHERE dbt.tablespace_name != "SYSTEM"
      AND  NOT (dbt.contents IN ("UNDO", "TEMPORARY"))
    ELSEIF ( NOT (currdbuser IN ("V500", "CDBA")))
     FROM dm2_dba_tablespaces dbt
     WHERE ((dbt.status = null) OR (dbt.status != "OFFLINE"))
    ELSE
     FROM dm2_dba_tablespaces dbt
     WHERE ((dbt.status = null) OR (dbt.status != "OFFLINE"))
      AND substring(1,2,dbt.tablespace_name) IN ("D_", "I_", "L_")
    ENDIF
    INTO "nl:"
    HEAD REPORT
     ddtsp->nonstd_ind = 0, ddtsp->nonstd_tgt_ind = 0, ddtsp->tsp_cnt = 0
    DETAIL
     IF (dlt_fatal_error=0)
      ddtsp->tsp_cnt = (ddtsp->tsp_cnt+ 1)
      IF (mod(ddtsp->tsp_cnt,50)=1)
       stat = alterlist(ddtsp->qual,(ddtsp->tsp_cnt+ 49))
      ENDIF
      CASE (trim(dbt.extent_management))
       OF "DICTIONARY":
        ddtsp->qual[ddtsp->tsp_cnt].ext_mgmt = "D"
       OF "LOCAL":
        ddtsp->qual[ddtsp->tsp_cnt].ext_mgmt = "L"
       ELSE
        ddtsp->qual[ddtsp->tsp_cnt].ext_mgmt = " ",
        IF (currdb="ORACLE")
         dlt_fatal_error = 1
        ENDIF
      ENDCASE
      ddtsp->qual[ddtsp->tsp_cnt].tspace_name = trim(dbt.tablespace_name), ddtsp->qual[ddtsp->tsp_cnt
      ].alloc_type = trim(dbt.allocation_type), ddtsp->qual[ddtsp->tsp_cnt].seg_space_mgmt = dbt
      .segment_space_management,
      ddtsp->qual[ddtsp->tsp_cnt].nonstd_ind = 0, ddtsp->qual[ddtsp->tsp_cnt].nonstd_tgt_ind = 0,
      ddtsp->qual[ddtsp->tsp_cnt].lmt_ora8_ind = 0,
      ddtsp->qual[ddtsp->tsp_cnt].lmt_uniform_ind = 0, ddtsp->qual[ddtsp->tsp_cnt].lmt_and_not_assm
       = 0, ddtsp->qual[ddtsp->tsp_cnt].lmt_uniform_ind = 0,
      ddtsp->qual[ddtsp->tsp_cnt].lmt_bigfile = 0, ddtsp->qual[ddtsp->tsp_cnt].datafile_not_assm = 0,
      ddtsp->qual[ddtsp->tsp_cnt].datafile_not_unlimited = 0,
      ddtsp->qual[ddtsp->tsp_cnt].lmt_and_not_ae = 0
      IF ((ddtsp->qual[ddtsp->tsp_cnt].ext_mgmt="L")
       AND (dm2_rdbms_version->level1=8))
       ddtsp->qual[ddtsp->tsp_cnt].nonstd_ind = 1, ddtsp->qual[ddtsp->tsp_cnt].lmt_ora8_ind = 1,
       ddtsp->nonstd_ind = 1
      ENDIF
      IF ((ddtsp->qual[ddtsp->tsp_cnt].ext_mgmt="L")
       AND (ddtsp->qual[ddtsp->tsp_cnt].alloc_type="UNIFORM"))
       ddtsp->qual[ddtsp->tsp_cnt].nonstd_ind = 1, ddtsp->qual[ddtsp->tsp_cnt].lmt_uniform_ind = 1,
       ddtsp->nonstd_ind = 1
      ENDIF
      IF ((ddtsp->qual[ddtsp->tsp_cnt].ext_mgmt="L")
       AND (ddtsp->qual[ddtsp->tsp_cnt].seg_space_mgmt != "AUTO"))
       ddtsp->qual[ddtsp->tsp_cnt].lmt_and_not_assm = 1, ddtsp->qual[ddtsp->tsp_cnt].nonstd_ind = 1,
       ddtsp->nonstd_ind = 1
      ENDIF
      IF ((ddtsp->qual[ddtsp->tsp_cnt].ext_mgmt="L")
       AND dbt.bigfile="YES")
       ddtsp->qual[ddtsp->tsp_cnt].lmt_bigfile = 1, ddtsp->qual[ddtsp->tsp_cnt].nonstd_ind = 1, ddtsp
       ->nonstd_ind = 1
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(ddtsp->qual,ddtsp->tsp_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 10))
    CALL echorecord(ddtsp)
   ENDIF
   IF (dlt_fatal_error=1)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Unknown extent_management value returned from dm2_dba_tablespaces"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dir_storage_misc->tgt_storage_type="ASM"))
    SET dm_err->eproc = "Load datafile content."
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SELECT
     IF ((dm2_install_schema->process_option="CLIN COPY"))
      FROM dm2_dba_data_files dbt
     ELSE
      FROM dm2_dba_data_files dbt
      WHERE substring(1,2,dbt.tablespace_name) IN ("D_", "I_", "L_")
       AND ((dbt.autoextensible="NO") OR (dbt.maxbytes < dlt_31g))
     ENDIF
     INTO "nl:"
     ORDER BY dbt.tablespace_name
     HEAD dbt.tablespace_name
      dlt_ndx = locateval(dlt_ndx,1,ddtsp->tsp_cnt,dbt.tablespace_name,ddtsp->qual[dlt_ndx].
       tspace_name)
      IF (dlt_ndx > 0)
       IF (dbt.autoextensible="NO")
        ddtsp->qual[dlt_ndx].nonstd_ind = 1, ddtsp->qual[dlt_ndx].datafile_not_ae = 1, ddtsp->
        nonstd_ind = 1
       ENDIF
       IF (dbt.maxbytes < dlt_31g)
        ddtsp->qual[dlt_ndx].nonstd_ind = 1, ddtsp->qual[dlt_ndx].datafile_not_unlimited = 1, ddtsp->
        nonstd_ind = 1
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dtr_load_clin_tspaces(null)
   DECLARE dlt_ndx = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Load 'clinical' tablespace content."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT DISTINCT INTO "nl:"
    tspace_name = d.data_tablespace
    FROM dm_ts_precedence d
    WHERE ((d.owner="V500") UNION (
    (SELECT DISTINCT
     tspace_name = i.index_tablespace
     FROM dm_ts_precedence i
     WHERE ((i.owner="V500") UNION (
     (SELECT DISTINCT
      tspace_name = l.long_tablespace
      FROM dm_ts_precedence l
      WHERE l.owner="V500"))) )))
    ORDER BY tspace_name
    HEAD REPORT
     dtrt->cnt = 0
    DETAIL
     dtrt->cnt = (dtrt->cnt+ 1)
     IF (mod(dtrt->cnt,50)=1)
      stat = alterlist(dtrt->qual,(dtrt->cnt+ 49))
     ENDIF
     dtrt->qual[dtrt->cnt].tspace_name = trim(tspace_name)
    FOOT REPORT
     stat = alterlist(dtrt->qual,dtrt->cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Load 'clinical' tablespace mapping content."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT DISTINCT INTO "nl:"
    d.info_char
    FROM dm_info d
    WHERE d.info_domain="DM2_TABLESPACE_MAPPING"
    ORDER BY d.info_char
    DETAIL
     dtrt->cnt = (dtrt->cnt+ 1), stat = alterlist(dtrt->qual,dtrt->cnt), dtrt->qual[dtrt->cnt].
     tspace_name = trim(d.info_char)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echorecord(dtrt)
   ENDIF
   RETURN(1)
 END ;Subroutine
 IF (validate(cur_sch->tbl_cnt,- (1)) < 0)
  FREE RECORD cur_sch
  RECORD cur_sch(
    1 rdbms = vc
    1 mviews_active_ind = i2
    1 dm_info_exists_ind = i2
    1 tbl_cnt = i4
    1 tbl[*]
      2 tbl_name = vc
      2 tspace_name = vc
      2 long_tspace = vc
      2 long_tspace_ni = i2
      2 pct_increase = f8
      2 pct_used = f8
      2 pct_free = f8
      2 init_ext = f8
      2 next_ext = f8
      2 capture_ind = i2
      2 schema_date = dq8
      2 schema_instance = i4
      2 bytes_allocated = f8
      2 bytes_used = f8
      2 row_cnt = f8
      2 ext_mgmt = c1
      2 lext_mgmt = c1
      2 max_ext = f8
      2 reference_ind = i2
      2 mview_flag = i2
      2 mview_exists_ind = i2
      2 mview_syn_status = vc
      2 ddl_excl_ind = i2
      2 rowdeps_ind = i2
      2 tbl_col_cnt = i4
      2 partitioned_ind = i2
      2 tbl_col[*]
        3 col_name = vc
        3 col_seq = i4
        3 data_type = vc
        3 data_length = i4
        3 data_default = vc
        3 data_default_ni = i2
        3 nullable = c1
        3 bytes_allocated = f8
        3 bytes_used = f8
        3 virtual_column = vc
        3 hidden_column = vc
      2 ind_cnt = i4
      2 ind_tspace = vc
      2 ind_tspace_ni = i2
      2 ind[*]
        3 ind_name = vc
        3 full_ind_name = vc
        3 tspace_name = vc
        3 tspace_name_ni = i2
        3 pct_increase = f8
        3 pct_free = f8
        3 init_ext = f8
        3 next_ext = f8
        3 unique_ind = i2
        3 bytes_allocated = f8
        3 bytes_used = f8
        3 index_type = vc
        3 ind_col_cnt = i4
        3 pk_change_ind = i2
        3 ext_mgmt = c1
        3 max_ext = f8
        3 visibility = vc
        3 ind_col[*]
          4 col_name = vc
          4 col_position = i2
        3 ddl_excl_ind = i2
        3 partitioned_ind = i2
        3 cur_cons_idx = i4
        3 cur_tmp_cons_idx = i4
      2 cons_cnt = i4
      2 cons[*]
        3 cons_name = vc
        3 full_cons_name = vc
        3 cons_type = c1
        3 r_constraint_name = vc
        3 orig_r_cons_name = vc
        3 parent_table = vc
        3 status_ind = i2
        3 parent_table_columns = vc
        3 delete_rule = vc
        3 cons_col_cnt = i4
        3 cons_col[*]
          4 col_name = vc
          4 col_position = i2
        3 fk_cnt = i4
        3 fk[*]
          4 tbl_ndx = i4
          4 cons_ndx = i4
    1 tspace_cnt = i4
    1 tspace[*]
      2 tspace_name = vc
      2 initial_extent = f8
      2 next_extent = f8
      2 ext_mgmt = c1
      2 pct_increase = f8
      2 tspace_type = vc
      2 tspace_type_ni = i2
      2 pagesize = i4
      2 nodegroup = vc
      2 nodegroup_ni = i2
      2 bufferpool_name = vc
      2 bufferpool_name_ni = i2
    1 sequence_cnt = i4
    1 sequence[*]
      2 seq_name = vc
      2 min_val = f8
      2 max_val = f8
      2 cycle_flag = c1
      2 increment_by = f8
      2 last_number = f8
      2 capture_ind = i2
  )
  SET cur_sch->tbl_cnt = 0
 ENDIF
 IF (validate(tgtsch->tbl_cnt,- (1)) < 0)
  FREE RECORD tgtsch
  RECORD tgtsch(
    1 source_rdbms = vc
    1 schema_date = dq8
    1 alpha_feature_nbr = i4
    1 diff_ind = i2
    1 warn_ind = i2
    1 tbl_cnt = i4
    1 ddl_excl_ind = i2
    1 tbl[*]
      2 tbl_name = vc
      2 longlob_col_cnt = i4
      2 gtt_flag = i2
      2 last_analyzed_dt_tm = dq8
      2 orig_tbl_name = vc
      2 full_tbl_name = vc
      2 suff_tbl_name = vc
      2 new_ind = i2
      2 diff_ind = i2
      2 warn_ind = i2
      2 combine_ind = i2
      2 reference_ind = i4
      2 child_tbl_ind = i2
      2 tspace_name = vc
      2 cur_idx = i4
      2 row_cnt = f8
      2 cur_bytes_allocated = f8
      2 cur_bytes_used = f8
      2 pct_increase = f8
      2 pct_used = f8
      2 pct_free = f8
      2 init_ext = f8
      2 next_ext = f8
      2 size = f8
      2 ind_size = f8
      2 long_size = f8
      2 total_space = f8
      2 free_space = f8
      2 schema_date = dq8
      2 schema_instance = i4
      2 alpha_feature_nbr = i4
      2 feature_number = i4
      2 updt_dt_tm = dq8
      2 long_tspace = vc
      2 dext_mgmt = c1
      2 iext_mgmt = c1
      2 lext_mgmt = c1
      2 ttspace_new_ind = i2
      2 itspace_new_ind = i2
      2 ltspace_new_ind = i2
      2 table_suffix = vc
      2 logical_rowid_column_ind = i2
      2 bytes_allocated = f8
      2 bytes_used = f8
      2 afd_schema_instance = i4
      2 pull_from_afd = i2
      2 rowid_col_fnd = i2
      2 xrid_ind_fnd = i2
      2 ttsp_set_ind = i2
      2 itsp_set_ind = i2
      2 ltsp_set_ind = i2
      2 new_lob_col_ind = i2
      2 ttspace_assignment_choice = vc
      2 itspace_assignment_choice = vc
      2 ltspace_assignment_choice = vc
      2 tbl_col_cnt = i4
      2 max_ext = f8
      2 ind_rename_cnt = i4
      2 ind_replace_cnt = i4
      2 ddl_excl_ind = i2
      2 clu_idx = i2
      2 rowdeps_ind = i2
      2 metadata_loc_flg = i2
      2 part_ind = i2
      2 part_active_ind = i2
      2 partitioning_type = vc
      2 subpartitioning_type = vc
      2 partition_count = i4
      2 subpartition_count = i4
      2 interval = vc
      2 autolist = vc
      2 indexing_off_ind = i2
      2 row_mvmnt_ind = i2
      2 part_col_cnt = i4
      2 part_col[*]
        3 column_name = vc
        3 position = i2
      2 subpart_col_cnt = i4
      2 subpart_col[*]
        3 column_name = vc
        3 position = i2
      2 part_tsp_cnt = i4
      2 part_tsp[*]
        3 tablespace_name = vc
      2 subpart_tsp_cnt = i4
      2 subpart_tsp[*]
        3 tablespace_name = vc
      2 part_cnt = i4
      2 part[*]
        3 template_ind = i2
        3 indexing_off_ind = i2
        3 partition_name = vc
        3 subpartition_name = vc
        3 high_value = vc
        3 partition_position = i2
        3 subpartition_position = i2
        3 tablespace_name = vc
      2 ind_rename[*]
        3 cur_ind_name = vc
        3 temp_ind_name = vc
        3 final_ind_name = vc
        3 drop_cur_ind = i2
        3 drop_temp_ind = i2
        3 rename_cur_ind = i2
        3 rename_temp_ind = i2
        3 cur_ind_tspace_name = vc
        3 cur_ind_idx = i4
        3 drop_early_ind = i2
        3 ddl_excl_ind = i2
        3 rename_with_drop_ind = i2
      2 ind_replace[*]
        3 ind_name = vc
        3 temp_ind_name = vc
      2 ind_rebuild_cnt = i4
      2 ind_rebuild[*]
        3 initial_ind_name = vc
        3 interm_ind_name = vc
        3 final_ind_name = vc
        3 cons_name = vc
      2 tbl_col[*]
        3 col_name = vc
        3 col_seq = i4
        3 data_type = vc
        3 data_length = i4
        3 data_default = vc
        3 data_default_ni = i2
        3 nullable = c1
        3 new_ind = i2
        3 diff_dtype_ind = i2
        3 diff_dlength_ind = i2
        3 diff_nullable_ind = i2
        3 null_to_notnull_ind = i2
        3 diff_default_ind = i2
        3 cur_idx = i4
        3 size = f8
        3 diff_backfill = i2
        3 backfill_op_exists = i2
        3 virtual_column = vc
        3 part_ind = i2
        3 part_active_ind = i2
        3 lob_part_cnt = i4
        3 lob_part[*]
          4 template_ind = i2
          4 partition_name = vc
          4 subpartition_name = vc
          4 partition_position = i2
          4 subpartition_position = i2
          4 tablespace_name = vc
      2 ind_tspace = vc
      2 ind_cnt = i4
      2 ind[*]
        3 ind_name = vc
        3 full_ind_name = vc
        3 pct_increase = f8
        3 pct_free = f8
        3 init_ext = f8
        3 next_ext = f8
        3 size = f8
        3 unique_ind = i2
        3 cur_bytes_allocated = f8
        3 cur_bytes_used = f8
        3 bytes_allocated = f8
        3 bytes_used = f8
        3 index_type = vc
        3 ind_col_cnt = i4
        3 pk_ind = i2
        3 visibility_change_ind = i2
        3 part_ind = i2
        3 rebuild_ind = i2
        3 part_active_ind = i2
        3 partitioning_type = vc
        3 subpartitioning_type = vc
        3 partition_count = i4
        3 subpartition_count = i4
        3 interval = vc
        3 autolist = vc
        3 locality = vc
        3 partial_ind = i2
        3 part_col_cnt = i4
        3 part_col[*]
          4 column_name = vc
          4 position = i2
        3 part_tsp_cnt = i4
        3 part_tsp[*]
          4 tablespace_name = vc
        3 subpart_tsp_cnt = i4
        3 subpart_tsp[*]
          4 tablespace_name = vc
        3 part_cnt = i4
        3 part[*]
          4 partition_name = vc
          4 subpartition_name = vc
          4 high_value = vc
          4 partition_position = i2
          4 subpartition_position = i2
          4 tablespace_name = vc
        3 ind_col[*]
          4 col_name = vc
          4 col_position = i2
        3 new_ind = i2
        3 drop_ind = i2
        3 diff_name_ind = i2
        3 diff_unique_ind = i2
        3 diff_col_ind = i2
        3 diff_cons_ind = i2
        3 diff_type_ind = i2
        3 build_ind = i2
        3 cur_idx = i4
        3 rename_ind = i2
        3 replace_ind = i2
        3 temp_ind = i2
        3 tspace_name = vc
        3 ext_mgmt = c1
        3 max_ext = f8
        3 ddl_excl_ind = i2
      2 ind_drop_cnt = i4
      2 ind_drop[*]
        3 ind_name = vc
      2 cons_cnt = i4
      2 cons[*]
        3 cons_name = vc
        3 full_cons_name = vc
        3 cons_type = c1
        3 parent_table = vc
        3 status_ind = i2
        3 parent_table_columns = vc
        3 r_constraint_name = vc
        3 index_idx = i4
        3 delete_rule = vc
        3 cons_col_cnt = i4
        3 cons_col[*]
          4 col_name = vc
          4 col_position = i2
        3 new_ind = i2
        3 drop_ind = i2
        3 diff_name_ind = i2
        3 diff_col_ind = i2
        3 diff_status_ind = i2
        3 diff_parent_ind = i2
        3 diff_ind_ind = i2
        3 build_ind = i2
        3 cur_idx = i4
        3 fk_cnt = i4
        3 ddl_excl_ind = i2
      2 cons_drop_cnt = i4
      2 cons_drop[*]
        3 cons_name = vc
        3 cons_type = c1
        3 cur_cons_idx = i4
        3 ddl_excl_ind = i2
      2 mview_flag = i2
      2 mview_cc_build_ind = i2
      2 mview_build_ind = i2
      2 mview_log_cnt = i2
      2 mview_logs[*]
        3 table_name = vc
      2 mview_piece_cnt = i2
      2 mview_piece[*]
        3 txt = vc
    1 tspace_cnt = i4
    1 tspace[*]
      2 tspace_name = vc
      2 initial_extent = f8
      2 next_extent = f8
      2 pct_increase = f8
      2 new_ind = i2
      2 cur_idx = i4
      2 tspace_type = vc
      2 tspace_type_ni = i2
      2 pagesize = i4
      2 nodegroup = vc
      2 nodegroup_ni = i2
      2 bufferpool_name = vc
      2 bufferpool_name_ni = i2
      2 bytes_free_reqd = f8
      2 min_total_bytes = f8
    1 backfill_ops_cnt = i4
    1 backfill_ops[*]
      2 op_id = f8
      2 gen_dt_tm = dq8
      2 status = vc
      2 reset_backfill = i2
      2 delete_row = i2
      2 table_name = vc
      2 tgt_tbl_idx = i4
      2 col_cnt = i4
      2 col[*]
        3 tgt_col_idx = i4
        3 col_name = vc
      2 backfill_method = vc
    1 sequence_cnt = i4
    1 sequence[*]
      2 seq_name = vc
      2 min_val = f8
      2 max_val = f8
      2 cycle_flag = c1
      2 increment_by = f8
      2 last_number = f8
      2 new_ind = i2
      2 diff_ind = i2
    1 tspace_diff_ind = i2
    1 user_cnt = i4
    1 user[*]
      2 new_ind = i2
      2 diff_ind = i2
      2 user_name = vc
      2 instance = i4
      2 cur_instance = i4
      2 pull_from_admin = i2
      2 default_tspace = vc
      2 default_tspace_size = f8
      2 temp_tspace = vc
      2 temp_tspace_size = f8
      2 priv_cnt = i4
      2 privs[*]
        3 priv_name = vc
      2 quota_cnt = i4
      2 quota[*]
        3 tspace_name = vc
    1 clu_cnt = i4
    1 clu[*]
      2 cluster_name = vc
      2 table_name = vc
      2 cluster_tsp_name = vc
      2 index_name = vc
      2 cluster_index_tsp_name = vc
      2 col_list_def = vc
      2 new_ind = i2
      2 clucol_cnt = i4
      2 clucol[*]
        3 column_name = vc
        3 data_type = vc
        3 data_length = i4
        3 col_pos = i2
  )
  SET tgtsch->tbl_cnt = 0
  SET tgtsch->backfill_ops_cnt = 0
  SET tgtsch->user_cnt = 0
  SET tgtsch->tspace_cnt = 0
 ENDIF
 DECLARE open_sch_files(sbr_for_modify=i4) = i4
 DECLARE create_sch_files(null) = i4
 DECLARE close_sch_files(null) = i4
 DECLARE copy_sch_files(null) = i4
 DECLARE open_sch_file(sbr_osf_modind=i4,sbr_osf_fname=vc,sbr_osf_rndx=i4) = i4
 DECLARE val_sch_file_ver(sbr_vsf_rndx=i4) = i4
 DECLARE make_sch_file_defs(sbr_msf_rndx=i4) = i4
 DECLARE del_sch_file(sbr_dsf_ffname=vc,sbr_dsf_fname=vc) = i4
 DECLARE del_sch_files(null) = i2
 DECLARE copy_sch_file(sbr_src_fname=vc,sbr_tgt_fname=vc) = i4
 DECLARE check_sch_files(null) = i4
 DECLARE prep_sch_file(rec_ndx=i4) = i4
 DECLARE gen_sch_files(null) = i4
 DECLARE dsfi_load_schema_file_defs(dsfi_schema_set=vc) = i4
 DECLARE dsfi_load_schema_files(dlsf_desc=vc,dlsf_process_option=vc) = i2
 DECLARE dsfi_pop_dmheader(sfidx=i4) = null
 DECLARE dsfi_pop_dmtable(sfidx=i4) = null
 DECLARE dsfi_pop_dmcolumn(sfidx=i4) = null
 DECLARE dsfi_pop_dmindex(sfidx=i4) = null
 DECLARE dsfi_pop_dmindcol(sfidx=i4) = null
 DECLARE dsfi_pop_dmcons(sfidx=i4) = null
 DECLARE dsfi_pop_dmconscol(sfidx=i4) = null
 DECLARE dsfi_pop_dmseq(sfidx=i4) = null
 DECLARE dsfi_pop_dmtbldoc(sfidx=i4) = null
 DECLARE dsfi_pop_dmcoldoc(sfidx=i4) = null
 DECLARE dsfi_pop_dmtdprec(sfidx=i4) = null
 DECLARE dsfi_pop_dmtspace(sfidx=i4) = null
 IF ((validate(dm2_sch_file->file_cnt,- (1))=- (1)))
  RECORD dm2_sch_file(
    1 sf_ver = i4
    1 file_cnt = i4
    1 src_dir_osfmt = vc
    1 dest_dir_cclfmt = vc
    1 dest_dir_osfmt = vc
    1 ending_punct = vc
    1 file_prefix = vc
    1 qual[*]
      2 file_suffix = vc
      2 table_name = vc
      2 db_name = vc
      2 size = vc
      2 data_size = vc
      2 key_size = vc
      2 db_key = vc
      2 key_cnt = i4
      2 kqual[*]
        3 key_col = vc
      2 data_cnt = i4
      2 dqual[*]
        3 data_col = vc
  )
  SET dm2_sch_file->sf_ver = 1
  CASE (dm2_sys_misc->cur_os)
   OF "AXP":
    SET dm2_sch_file->ending_punct = " "
   OF "WIN":
    SET dm2_sch_file->ending_punct = "\"
   ELSE
    SET dm2_sch_file->ending_punct = "/"
  ENDCASE
  IF (dsfi_load_schema_file_defs("TABLE_INFO") != 1)
   SET dm_err->err_ind = 1
  ENDIF
 ENDIF
 SUBROUTINE create_sch_files(null)
   DECLARE csf_concurrency_cnt = i4 WITH noconstant(0)
   DECLARE sch_file_status = i4
   DECLARE di_insert_ind = i2 WITH noconstant(0)
   DECLARE pause_length = i2 WITH noconstant(60)
   DECLARE csf_done_ind = i2 WITH noconstant(0)
   DECLARE csf_retry_cnt = i2 WITH noconstant(0)
   DECLARE csf_skip_ind = i2 WITH noconstant(0)
   SET dm2_sch_file->dest_dir_osfmt = build(logical(dm2_sch_file->dest_dir_cclfmt),dm2_sch_file->
    ending_punct)
   WHILE (csf_done_ind=0
    AND (dm_err->err_ind=0))
     SET csf_done_ind = 1
     SET csf_skip_ind = 0
     IF ((dm2_sch_file->qual[1].table_name != "DMTSPACE"))
      WHILE (csf_concurrency_cnt < 2
       AND (dm_err->err_ind=0))
        IF (dm2_set_autocommit(1)=1)
         SELECT INTO "nl:"
          FROM dm_info d
          WHERE d.info_domain="DM2 TOOLS"
           AND d.info_name="CREATING SCHEMA FILES"
          WITH nocounter
         ;end select
         IF (curqual > 0)
          SET csf_concurrency_cnt = (csf_concurrency_cnt+ 1)
          IF (csf_concurrency_cnt=2)
           SET dm_err->emsg =
           "Another process is currently generating schema file definitions, please try again later."
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           SET dm_err->err_ind = 1
          ELSE
           SET dm_err->eproc = concat(
            "Another process is currently generating schema file definitions.  Pausing ",trim(
             cnvtstring(pause_length))," seconds before trying again. Please wait.")
           CALL disp_msg(" ",dm_err->logfile,0)
           CALL pause(pause_length)
          ENDIF
         ELSE
          IF (check_error("Checking for concurrency row in dm_info ")=1)
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          ENDIF
          SET csf_concurrency_cnt = 2
         ENDIF
        ENDIF
      ENDWHILE
     ENDIF
     IF ((dm_err->err_ind=0))
      SET sch_file_status = check_sch_files(null)
      CASE (sch_file_status)
       OF 0:
        SET dm_err->err_ind = 1
       OF 1:
        SET dm_err->eproc = "ALL CORE SCHEMA FILE COMPONENTS EXIST"
        CALL disp_msg(" ",dm_err->logfile,0)
        FOR (csf_file_cnt = 1 TO dm2_sch_file->file_cnt)
          IF (prep_sch_file(csf_file_cnt)=0)
           SET dm_err->err_ind = 1
           SET csf_file_cnt = dm2_sch_file->file_cnt
          ENDIF
        ENDFOR
       OF 2:
        IF ((dm2_sch_file->qual[1].table_name != "DMTSPACE"))
         SET dm_err->eproc = "INSERT CONCURRENCY ROW INTO DM_INFO"
         CALL disp_msg(" ",dm_err->logfile,0)
         INSERT  FROM dm_info d
          SET d.info_domain = "DM2 TOOLS", d.info_name = "CREATING SCHEMA FILES", d.info_date = null,
           d.info_char = " ", d.info_number = 0.0, d.info_long_id = 0.0,
           d.updt_applctx = 0, d.updt_task = 0.0, d.updt_cnt = 0,
           d.updt_id = 0.0, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
          WITH nocounter
         ;end insert
         IF (check_error("Inserting dm_info row for concurrency ")=1)
          IF (findstring("ORA-00001",dm_err->emsg,1,0) > 0)
           SET csf_retry_cnt = (csf_retry_cnt+ 1)
           IF (csf_retry_cnt < 2)
            SET dm_err->err_ind = 0
            SET csf_done_ind = 0
            SET csf_skip_ind = 1
            SET dm_err->eproc = concat(
             "Another process is currently generating schema file definitions.  Pausing ",trim(
              cnvtstring(pause_length))," seconds before trying again. Please wait.")
            CALL disp_msg(" ",dm_err->logfile,0)
            CALL pause(pause_length)
           ELSE
            SET dm_err->emsg =
            "Another process is currently generating schema file definitions, please try again later."
            CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           ENDIF
          ELSE
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           ROLLBACK
          ENDIF
         ELSE
          COMMIT
          SET di_insert_ind = 1
         ENDIF
        ENDIF
        IF ((dm_err->err_ind=0)
         AND csf_skip_ind=0)
         SET dm_err->eproc = "REGENERATE CORE SCHEMA FILE COMPONENTS"
         CALL disp_msg(" ",dm_err->logfile,0)
         CALL gen_sch_files(null)
        ENDIF
      ENDCASE
     ENDIF
   ENDWHILE
   IF (di_insert_ind=1)
    SET dm_err->eproc = "REMOVE CONCURRENCY ROW FROM DM_INFO"
    CALL disp_msg(" ",dm_err->logfile,0)
    DELETE  FROM dm_info d
     WHERE d.info_domain="DM2 TOOLS"
      AND d.info_name="CREATING SCHEMA FILES"
     WITH nocounter
    ;end delete
    COMMIT
    IF ((dm_err->err_ind=0))
     IF (check_error("Deleting dm_info row for concurrency ")=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ENDIF
    ENDIF
   ENDIF
   CALL dm2_set_autocommit(0)
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE open_sch_file(sbr_osf_modind,sbr_osf_fname,sbr_osf_rndx)
   DECLARE osf_tempstr = vc WITH noconstant(" ")
   IF (dm2_push_cmd(concat("free define ",dm2_sch_file->qual[sbr_osf_rndx].db_name," go"),1)=0)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   CALL dm2_push_cmd(concat("define ",dm2_sch_file->qual[sbr_osf_rndx].db_name," is ",build("'",
      sbr_osf_fname,"'")),0)
   IF (sbr_osf_modind=1)
    CALL dm2_push_cmd(" with modify",0)
    SET osf_tempstr = " with modify"
   ENDIF
   IF (dm2_push_cmd(" go",1)=0)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE open_sch_files(sbr_for_modify)
   DECLARE file_name_for_open = vc
   DECLARE dsfi = i4 WITH public, noconstant(0)
   FOR (dsfi = 1 TO dm2_sch_file->file_cnt)
     SET file_name_for_open = build(dm2_sch_file->dest_dir_cclfmt,":",cnvtlower(dm2_sch_file->
       file_prefix),cnvtlower(dm2_sch_file->qual[dsfi].file_suffix),".dat")
     IF (val_sch_file_ver(dsfi)=0)
      IF ((dm_err->err_ind=1))
       RETURN(0)
      ELSEIF (make_sch_file_defs(dsfi)=0)
       SET dm_err->err_ind = 1
       RETURN(0)
      ENDIF
     ENDIF
     IF ((dm_err->debug_flag=1))
      SET dm_err->eproc = concat("Opening ",file_name_for_open)
      CALL disp_msg(" ",dm_err->logfile,0)
     ENDIF
     IF (open_sch_file(sbr_for_modify,file_name_for_open,dsfi)=0)
      SET dm_err->err_ind = 1
      RETURN(0)
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE val_sch_file_ver(sbr_vsf_rndx)
   DECLARE vsfv_datacnt = i4 WITH noconstant(0)
   DECLARE vsfv_keycnt = i4 WITH noconstant(0)
   DECLARE vsfv_match_col_ind = i2 WITH noconstant(0)
   DECLARE vsfv_match_db_ind = i2 WITH noconstant(0)
   DECLARE vsfv_temp_str = vc WITH noconstant("")
   SELECT INTO "nl:"
    d.table_name
    FROM dtable d
    WHERE (d.file_name=dm2_sch_file->qual[sbr_vsf_rndx].db_name)
     AND (d.table_name=dm2_sch_file->qual[sbr_vsf_rndx].table_name)
    DETAIL
     vsfv_match_db_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(concat("Checking for ",dm2_sch_file->qual[sbr_vsf_rndx].table_name,
     " in CCL dictionary"))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    l.attr_name
    FROM dtableattr a,
     dtableattrl l
    WHERE (a.table_name=dm2_sch_file->qual[sbr_vsf_rndx].table_name)
     AND l.structtype="F"
     AND btest(l.stat,11)=0
    HEAD REPORT
     start_pos = 0, end_pos = 0, x = 0,
     y = 0
    DETAIL
     FOR (x = 1 TO dm2_sch_file->qual[sbr_vsf_rndx].data_cnt)
      end_pos = findstring("=",dm2_sch_file->qual[sbr_vsf_rndx].dqual[x].data_col),
      IF (trim(l.attr_name,3)=substring(1,(end_pos - 1),dm2_sch_file->qual[sbr_vsf_rndx].dqual[x].
       data_col))
       end_pos = 0
       IF (trim(l.attr_name,3)="FILLER")
        start_pos = findstring("FILLER = c",dm2_sch_file->qual[sbr_vsf_rndx].dqual[x].data_col),
        start_pos = (start_pos+ 10), end_pos = findstring(" CCL(FILLER)",dm2_sch_file->qual[
         sbr_vsf_rndx].dqual[x].data_col)
        IF (l.len=cnvtint(substring(start_pos,(end_pos - start_pos),dm2_sch_file->qual[sbr_vsf_rndx].
          dqual[x].data_col)))
         vsfv_datacnt = (vsfv_datacnt+ 1), x = dm2_sch_file->qual[sbr_vsf_rndx].data_cnt
        ENDIF
       ELSE
        vsfv_datacnt = (vsfv_datacnt+ 1), x = dm2_sch_file->qual[sbr_vsf_rndx].data_cnt
       ENDIF
      ENDIF
     ENDFOR
     FOR (y = 1 TO dm2_sch_file->qual[sbr_vsf_rndx].key_cnt)
      end_pos = findstring("=",dm2_sch_file->qual[sbr_vsf_rndx].kqual[y].key_col),
      IF (trim(l.attr_name,3)=substring(1,(end_pos - 1),dm2_sch_file->qual[sbr_vsf_rndx].kqual[y].
       key_col))
       end_pos = 0, vsfv_keycnt = (vsfv_keycnt+ 1), y = dm2_sch_file->qual[sbr_vsf_rndx].key_cnt
      ENDIF
     ENDFOR
    WITH nocounter
   ;end select
   IF (check_error(concat("Checking for columns on ",dm2_sch_file->qual[sbr_vsf_rndx].table_name,
     " in CCL dictionary"))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
    CALL echo(build("dm_err->err_ind = ",dm_err->err_ind))
   ENDIF
   IF ((vsfv_datacnt=dm2_sch_file->qual[sbr_vsf_rndx].data_cnt)
    AND (vsfv_keycnt=dm2_sch_file->qual[sbr_vsf_rndx].key_cnt))
    SET vsfv_match_col_ind = 1
   ENDIF
   IF (vsfv_match_col_ind=1
    AND vsfv_match_db_ind=1)
    RETURN(1)
   ELSE
    CALL disp_msg(concat(dm2_sch_file->qual[sbr_vsf_rndx].table_name,
      " definition not correct in CCL dictionary"),dm_err->logfile,0)
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE make_sch_file_defs(sbr_msf_rndx)
   DECLARE current_db = vc
   DECLARE msfd_estr = vc
   DECLARE msfd_ret_val = i2 WITH noconstant(0)
   DECLARE drop_needed = i2 WITH noconstant(0)
   IF ((dm_err->debug_flag=1))
    SET dm_err->eproc = concat("Making CCL definition for ",dm2_sch_file->qual[sbr_msf_rndx].
     table_name)
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dtable d
    WHERE (d.table_name=dm2_sch_file->qual[sbr_msf_rndx].table_name)
    DETAIL
     drop_needed = 1, current_db = d.file_name
    WITH nocounter
   ;end select
   IF (drop_needed=1)
    IF (dm2_push_cmd(concat("drop table ",dm2_sch_file->qual[sbr_msf_rndx].table_name," go"),1)=0)
     RETURN(0)
    ENDIF
    IF (dm2_push_cmd(concat("drop ddlrecord ",dm2_sch_file->qual[sbr_msf_rndx].table_name,
      " from database ",current_db," WITH DEPS_DELETED go"),1)=0)
     RETURN(0)
    ENDIF
    IF (dm2_push_cmd(concat("drop database ",current_db," with deps_deleted go"),1)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET drop_needed = 0
   SELECT INTO "nl:"
    FROM dfile d
    WHERE (d.file_name=dm2_sch_file->qual[sbr_msf_rndx].db_name)
    DETAIL
     drop_needed = 1
    WITH nocounter
   ;end select
   IF (drop_needed=1)
    IF (dm2_push_cmd(concat("drop database ",dm2_sch_file->qual[sbr_msf_rndx].db_name,
      " with deps_deleted go"),1)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dm2_push_cmd(concat("create database ",dm2_sch_file->qual[sbr_msf_rndx].db_name,
     " organization(indexed) format(variable) size(",dm2_sch_file->qual[sbr_msf_rndx].size,") ",
     dm2_sch_file->qual[sbr_msf_rndx].db_key," go"),1)=0)
    RETURN(0)
   ENDIF
   CALL dm2_push_cmd(concat("create ddlrecord ",dm2_sch_file->qual[sbr_msf_rndx].table_name,
     " from database ",dm2_sch_file->qual[sbr_msf_rndx].db_name," table ",
     dm2_sch_file->qual[sbr_msf_rndx].table_name),0)
   CALL dm2_push_cmd(" 1 key1 ",0)
   FOR (i = 1 TO dm2_sch_file->qual[sbr_msf_rndx].key_cnt)
     CALL dm2_push_cmd(concat(" 2 ",dm2_sch_file->qual[sbr_msf_rndx].kqual[i].key_col),0)
   ENDFOR
   CALL dm2_push_cmd(" 1 data ",0)
   FOR (i = 1 TO dm2_sch_file->qual[sbr_msf_rndx].data_cnt)
     CALL dm2_push_cmd(concat(" 2 ",dm2_sch_file->qual[sbr_msf_rndx].dqual[i].data_col),0)
   ENDFOR
   IF (dm2_push_cmd(concat("end table ",dm2_sch_file->qual[sbr_msf_rndx].table_name," go"),1)=0)
    RETURN(0)
   ENDIF
   SET msfd_estr = concat("Making def for ",dm2_sch_file->qual[sbr_msf_rndx].table_name)
   SET msfd_ret_val = val_sch_file_ver(sbr_msf_rndx)
   IF (msfd_ret_val=0)
    IF ((dm_err->err_ind=0))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = msfd_estr
     CALL disp_msg(" ",dm_err->logfile,1)
    ENDIF
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE close_sch_files(null)
   FOR (close_cnt = 1 TO dm2_sch_file->file_cnt)
     IF (dm2_push_cmd(concat("free define ",dm2_sch_file->qual[close_cnt].db_name," go"),1)=0)
      SET dm_err->err_ind = 1
      RETURN(0)
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE copy_sch_files(null)
  DECLARE target_name = vc
  FOR (csfi = 1 TO dm2_sch_file->file_cnt)
    SET target_name = build(dm2_sch_file->file_prefix,cnvtlower(dm2_sch_file->qual[csfi].file_suffix)
     )
    IF ( NOT ((dm2_sys_misc->cur_os IN ("AXP"))))
     IF (del_sch_file(build(dm2_sch_file->dest_dir_osfmt,target_name,".dat"))=0)
      SET dm_err->err_ind = 1
      RETURN(0)
     ENDIF
     IF (del_sch_file(build(dm2_sch_file->dest_dir_osfmt,target_name,".idx"))=0)
      SET dm_err->err_ind = 1
      RETURN(0)
     ENDIF
    ENDIF
    IF (copy_sch_file(build(dm2_sch_file->src_dir_osfmt,target_name,".dat"),build(dm2_sch_file->
      dest_dir_osfmt,target_name,".dat"))=0)
     SET dm_err->err_ind = 1
     RETURN(0)
    ENDIF
    IF ( NOT ((dm2_sys_misc->cur_os IN ("AXP"))))
     IF (copy_sch_file(build(dm2_sch_file->src_dir_osfmt,target_name,".idx"),build(dm2_sch_file->
       dest_dir_osfmt,target_name,".idx"))=0)
      SET dm_err->err_ind = 1
      RETURN(0)
     ENDIF
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE del_sch_file(sbr_dsf_fname)
  IF ((dm2_sys_misc->cur_os="WIN"))
   IF (findfile(sbr_dsf_fname)=1)
    IF (dm2_push_dcl(concat("del ",sbr_dsf_fname))=0)
     RETURN(0)
    ENDIF
   ENDIF
  ELSEIF ((dm2_sys_misc->cur_os="AXP"))
   IF (findfile(sbr_dsf_fname)=1)
    IF (dm2_push_dcl(concat("del ",sbr_dsf_fname,";\*"))=0)
     RETURN(0)
    ENDIF
   ENDIF
  ELSE
   IF (findfile(sbr_dsf_fname)=1)
    IF (dm2_push_dcl(concat("rm ",sbr_dsf_fname))=0)
     RETURN(0)
    ENDIF
   ENDIF
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE copy_sch_file(sbr_src_fname,sbr_tgt_fname)
  IF ((dm2_sys_misc->cur_os IN ("HPX", "AIX", "LNX")))
   IF (dm2_push_dcl(concat("cp ",sbr_src_fname," ",sbr_tgt_fname))=0)
    RETURN(0)
   ENDIF
   IF (dm2_push_dcl(concat("chmod 777 ",sbr_tgt_fname))=0)
    RETURN(0)
   ENDIF
  ELSE
   IF (dm2_push_dcl(concat("copy ",sbr_src_fname," ",sbr_tgt_fname))=0)
    RETURN(0)
   ENDIF
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE check_sch_files(null)
   DECLARE csf_file_name = vc WITH noconstant("")
   DECLARE csf_val_ver_ind = i2 WITH noconstant(0)
   FOR (csf_file_cnt = 1 TO dm2_sch_file->file_cnt)
     SET csf_file_name = concat(dm2_install_schema->ccluserdir,dm2_sch_file->qual[csf_file_cnt].
      table_name)
     IF ((dm2_sys_misc->cur_os="AXP"))
      IF ( NOT (findfile(concat(trim(csf_file_name,3),".dat"))))
       RETURN(2)
      ENDIF
     ELSE
      IF ( NOT (findfile(concat(trim(csf_file_name,3),".dat"))))
       RETURN(2)
      ELSEIF ( NOT (findfile(concat(trim(csf_file_name,3),".idx"))))
       RETURN(2)
      ENDIF
     ENDIF
     IF (val_sch_file_ver(csf_file_cnt)=0)
      IF ((dm_err->err_ind=1))
       RETURN(0)
      ELSE
       SET csf_val_ver_ind = 1
      ENDIF
     ENDIF
   ENDFOR
   IF (csf_val_ver_ind=1)
    RETURN(2)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE prep_sch_file(rec_ndx)
   DECLARE psf_target_name = vc
   DECLARE psf_target_name2 = vc
   DECLARE psf_estr = vc
   DECLARE psf_fext = vc
   IF ((dm2_sys_misc->cur_os IN ("HPX", "AIX", "LNX")))
    SET psf_fext = ".dat/.idx"
   ELSEIF ((dm2_sys_misc->cur_os="WIN"))
    SET psf_fext = ".dat/.idx"
   ELSE
    SET psf_fext = ".dat"
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("dm2_sch_file->dest_dir_osfmt=",dm2_sch_file->dest_dir_osfmt))
    CALL echo(build("size(dm2_sch_file->dest_dir_osfmt,1)=",size(dm2_sch_file->dest_dir_osfmt,1)))
    CALL echo(concat("dm2_sch_file->file_prefix=",dm2_sch_file->file_prefix))
    CALL echo(concat("dm2_sch_file->qual[rec_ndx]->file_suffix=",dm2_sch_file->qual[rec_ndx].
      file_suffix))
   ENDIF
   SET psf_target_name = build(dm2_sch_file->dest_dir_osfmt,cnvtlower(dm2_sch_file->file_prefix),
    cnvtlower(dm2_sch_file->qual[rec_ndx].file_suffix),".dat")
   IF ((dm_err->debug_flag > 0))
    CALL echo(concat("psf_target_name=",psf_target_name))
   ENDIF
   IF ((dm2_sys_misc->cur_os != "AXP"))
    SET psf_target_name2 = build(dm2_sch_file->dest_dir_osfmt,cnvtlower(dm2_sch_file->file_prefix),
     cnvtlower(dm2_sch_file->qual[rec_ndx].file_suffix),".idx")
   ENDIF
   IF ((dm2_sys_misc->cur_os IN ("HPX", "AIX", "WIN", "LNX")))
    IF (del_sch_file(psf_target_name)=0)
     RETURN(0)
    ENDIF
    IF (del_sch_file(psf_target_name2)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (copy_sch_file(concat(dm2_install_schema->ccluserdir,cnvtlower(build(dm2_sch_file->qual[rec_ndx
       ].table_name,".dat"))),psf_target_name)=0)
    RETURN(0)
   ENDIF
   IF ((dm2_sys_misc->cur_os != "AXP"))
    IF (copy_sch_file(concat(dm2_install_schema->ccluserdir,cnvtlower(build(dm2_sch_file->qual[
        rec_ndx].table_name,".idx"))),psf_target_name2)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (open_sch_file(1,build(dm2_sch_file->dest_dir_cclfmt,":",cnvtlower(dm2_sch_file->file_prefix),
     cnvtlower(dm2_sch_file->qual[rec_ndx].file_suffix),".dat"),rec_ndx)=0)
    RETURN(0)
   ENDIF
   IF (dm2_push_cmd(concat("delete from ",dm2_sch_file->qual[rec_ndx].table_name," where 1=1 go"),1)=
   0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gen_sch_files(null)
   DECLARE gsf_fext = vc
   IF ((dm2_sys_misc->cur_os IN ("HPX", "AIX", "LNX")))
    SET gsf_fext = ".dat/.idx"
   ELSEIF ((dm2_sys_misc->cur_os="WIN"))
    SET gsf_fext = ".dat/.idx"
   ELSE
    SET gsf_fext = ".dat"
   ENDIF
   FOR (gsf_cnt = 1 TO dm2_sch_file->file_cnt)
     IF ((dm2_sys_misc->cur_os != "AXP"))
      IF (del_sch_file(concat(dm2_install_schema->ccluserdir,cnvtlower(build(dm2_sch_file->qual[
          gsf_cnt].table_name,".dat"))))=0)
       RETURN(0)
      ENDIF
      IF (del_sch_file(concat(dm2_install_schema->ccluserdir,cnvtlower(build(dm2_sch_file->qual[
          gsf_cnt].table_name,".idx"))))=0)
       RETURN(0)
      ENDIF
     ENDIF
     IF (dm2_push_cmd(concat('select into table "',dm2_sch_file->qual[gsf_cnt].table_name,'"',
       " key1=fillstring(",dm2_sch_file->qual[gsf_cnt].key_size,
       '," "),'," data=fillstring(",dm2_sch_file->qual[gsf_cnt].data_size,'," ") ',
       " from dummyt order key1 with organization=indexed GO"),1)=0)
      RETURN(0)
     ENDIF
     IF (dm2_push_cmd(concat("drop table ",dm2_sch_file->qual[gsf_cnt].table_name," go"),1)=0)
      RETURN(0)
     ENDIF
     IF (dm2_push_cmd(concat("drop ddlrecord ",dm2_sch_file->qual[gsf_cnt].table_name,
       " from database ",dm2_sch_file->qual[gsf_cnt].table_name," with deps_deleted go"),1)=0)
      RETURN(0)
     ENDIF
     IF (dm2_push_cmd(concat("drop database ",dm2_sch_file->qual[gsf_cnt].table_name,
       " with deps_deleted go"),1)=0)
      RETURN(0)
     ENDIF
     IF (make_sch_file_defs(gsf_cnt)=0)
      RETURN(0)
     ENDIF
     IF (prep_sch_file(gsf_cnt)=0)
      RETURN(0)
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsfi_load_schema_file_defs(dsfi_schema_set)
  CASE (cnvtupper(dsfi_schema_set))
   OF "TABLE_INFO":
    SET dm2_sch_file->file_cnt = 11
    SET stat = alterlist(dm2_sch_file->qual,dm2_sch_file->file_cnt)
    CALL dsf_pop_dmheader(1)
    CALL dsf_pop_dmtable(2)
    CALL dsf_pop_dmcolumn(3)
    CALL dsf_pop_dmindex(4)
    CALL dsf_pop_dmindcol(5)
    CALL dsf_pop_dmcons(6)
    CALL dsf_pop_dmconscol(7)
    CALL dsf_pop_dmseq(8)
    CALL dsf_pop_dmtbldoc(9)
    CALL dsf_pop_dmcoldoc(10)
    CALL dsf_pop_dmtsprec(11)
   OF "TSPACE":
    SET dm2_sch_file->file_cnt = 1
    SET stat = alterlist(dm2_sch_file->qual,dm2_sch_file->file_cnt)
    CALL dsf_pop_dmtspace(1)
  ENDCASE
  RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmheader(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_h"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMHEADER"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1058"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1028"
   SET dm2_sch_file->qual[dsfcnt].key_size = "30"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 30)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 1
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "DESCRIPTION = c30 CCL(DESCRIPTION)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 4
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "SOURCE_RDBMS = c20 CCL(SOURCE_RDBMS)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "ADMIN_LOAD_IND = i4 CCL(ADMIN_LOAD_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "SF_VERSION = i4 CCL(SF_VERSION)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col = "FILLER = c1000 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmtable(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_t"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMTABLE"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1208"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1178"
   SET dm2_sch_file->qual[dsfcnt].key_size = "30"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 30)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 1
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "TABLE_NAME = c30  CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 21
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "TABLESPACE_NAME = c30 CCL(TABLESPACE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "INDEX_TSPACE = c30 CCL(INDEX_TSPACE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "INDEX_TSPACE_NI = i2 CCL(INDEX_TSPACE_NI)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col = "LONG_TSPACE = c30 CCL(LONG_TSPACE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[5].data_col = "LONG_TSPACE_NI = i2 CCL(LONG_TSPACE_NI)"
   SET dm2_sch_file->qual[dsfcnt].dqual[6].data_col = "INIT_EXT = f8 CCL(INIT_EXT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[7].data_col = "NEXT_EXT = f8 CCL(NEXT_EXT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[8].data_col = "PCT_INCREASE = f8 CCL(PCT_INCREASE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[9].data_col = "PCT_USED = f8 CCL(PCT_USED)"
   SET dm2_sch_file->qual[dsfcnt].dqual[10].data_col = "PCT_FREE = f8 CCL(PCT_FREE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[11].data_col = "BYTES_ALLOCATED = f8 CCL(BYTES_ALLOCATED)"
   SET dm2_sch_file->qual[dsfcnt].dqual[12].data_col = "BYTES_USED = f8 CCL(BYTES_USED)"
   SET dm2_sch_file->qual[dsfcnt].dqual[13].data_col = "SCHEMA_DATE = dq8 CCL(SCHEMA_DATE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[14].data_col =
   "ALPHA_FEATURE_NBR = i4 CCL(ALPHA_FEATURE_NBR)"
   SET dm2_sch_file->qual[dsfcnt].dqual[15].data_col = "FEATURE_NUMBER = i4 CCL(FEATURE_NUMBER)"
   SET dm2_sch_file->qual[dsfcnt].dqual[16].data_col = "UPDT_DT_TM = dq8 CCL(UPDT_DT_TM)"
   SET dm2_sch_file->qual[dsfcnt].dqual[17].data_col = "SCHEMA_INSTANCE = i4 CCL(SCHEMA_INSTANCE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[18].data_col = "TSPACE_TYPE = c1 CCL(TSPACE_TYPE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[19].data_col = "LONG_TSPACE_TYPE = c1 CCL(LONG_TSPACE_TYPE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[20].data_col = "MAX_EXT = f8 CCL(MAX_EXT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[21].data_col = "FILLER = c990 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmcolumn(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_tc"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMCOLUMN"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1343"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1283"
   SET dm2_sch_file->qual[dsfcnt].key_size = "60"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 60)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 2
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "TABLE_NAME = c30 CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].kqual[2].key_col = "COLUMN_NAME = c30 CCL(COLUMN_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 9
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "COLUMN_SEQ = i4 CCL(COLUMN_SEQ)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "DATA_TYPE = c18 CCL(DATA_TYPE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "DATA_LENGTH = i4 CCL(DATA_LENGTH)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col = "NULLABLE = c1 CCL(NULLABLE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[5].data_col = "DATA_DEFAULT = c254 CCL(DATA_DEFAULT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[6].data_col = "DATA_DEFAULT_NI = i2 CCL(DATA_DEFAULT_NI)"
   SET dm2_sch_file->qual[dsfcnt].dqual[7].data_col = "DATA_DEFAULT2 = c500 CCL(DATA_DEFAULT2)"
   SET dm2_sch_file->qual[dsfcnt].dqual[8].data_col = "VIRTUAL_COLUMN = c3 CCL(VIRTUAL_COLUMN)"
   SET dm2_sch_file->qual[dsfcnt].dqual[9].data_col = "FILLER = c497 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmindex(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_i"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMINDEX"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1140"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1080"
   SET dm2_sch_file->qual[dsfcnt].key_size = "60"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 60)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 2
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "TABLE_NAME =  c30 CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].kqual[2].key_col = "INDEX_NAME = c30 CCL(INDEX_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 13
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "FULL_IND_NAME = c30 CCL(FULL_IND_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "PCT_INCREASE = f8 CCL(PCT_INCREASE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "PCT_FREE = f8 CCL(PCT_FREE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col = "INIT_EXT = f8 CCL(INIT_EXT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[5].data_col = "NEXT_EXT = f8 CCL(NEXT_EXT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[6].data_col = "UNIQUE_IND = i2 CCL(UNIQUE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[7].data_col = "BYTES_ALLOCATED = f8 CCL(BYTES_ALLOCATED)"
   SET dm2_sch_file->qual[dsfcnt].dqual[8].data_col = "BYTES_USED = f8 CCL(BYTES_USED)"
   SET dm2_sch_file->qual[dsfcnt].dqual[9].data_col = "TSPACE_NAME = c30 CCL(TSPACE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[10].data_col = "TSPACE_TYPE = c1 CCL(TSPACE_TYPE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[11].data_col = "INDEX_TYPE = c30 CCL(INDEX_TYPE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[12].data_col = "MAX_EXT = f8 CCL(MAX_EXT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[13].data_col = "FILLER = c931 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmindcol(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_ic"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMINDCOL"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1094"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1034"
   SET dm2_sch_file->qual[dsfcnt].key_size = "60"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 60)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 2
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "INDEX_NAME = c30 CCL(INDEX_NAME)"
   SET dm2_sch_file->qual[dsfcnt].kqual[2].key_col = "COLUMN_NAME = c30 CCL(COLUMN_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 3
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "TABLE_NAME = c30 CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "COLUMN_POSITION = i4 CCL(COLUMN_POSITION)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "FILLER = c1000 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmcons(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_c"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMCONS"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1408"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1348"
   SET dm2_sch_file->qual[dsfcnt].key_size = "60"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 60)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 2
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "TABLE_NAME = c30 CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].kqual[2].key_col = "CONSTRAINT_NAME = c30 CCL(CONSTRAINT_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 8
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "FULL_CONS_NAME = c30 CCL(FULL_CONS_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "CONSTRAINT_TYPE = c1 CCL(CONSTRAINT_TYPE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "STATUS_IND = i2 CCL(STATUS_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col =
   "R_CONSTRAINT_NAME = c30 CCL(R_CONSTRAINT_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[5].data_col =
   "PARENT_TABLE_NAME = c30 CCL(PARENT_TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[6].data_col =
   "PARENT_TABLE_COLUMNS = c255 CCL(PARENT_TABLE_COLUMNS)"
   SET dm2_sch_file->qual[dsfcnt].dqual[7].data_col = "DELETE_RULE = c9 CCL(DELETE_RULE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[8].data_col = "FILLER = c991 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmconscol(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_cc"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMCONSCOL"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1094"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1034"
   SET dm2_sch_file->qual[dsfcnt].key_size = "60"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 60)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 2
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "CONSTRAINT_NAME = c30 CCL(CONSTRAINT_NAME)"
   SET dm2_sch_file->qual[dsfcnt].kqual[2].key_col = "COLUMN_NAME = c30 CCL(COLUMN_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 3
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "TABLE_NAME = c30 CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "POSITION =  i4 CCL(POSITION)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "FILLER = c1000 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmseq(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_sq"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMSEQ"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1079"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1049"
   SET dm2_sch_file->qual[dsfcnt].key_size = "30"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 30)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 1
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "SEQUENCE_NAME = c30 CCL(SEQUENCE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 9
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "MIN_VALUE = f8  CCL(MIN_VALUE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "MAX_VALUE = f8 CCL(MAX_VALUE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "INCREMENT_BY = f8 CCL(INCREMENT_BY)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col = "CYCLE_FLAG = c1 CCL(CYCLE_FLAG)"
   SET dm2_sch_file->qual[dsfcnt].dqual[5].data_col = "LAST_NUMBER = f8 CCL(LAST_NUMBER)"
   SET dm2_sch_file->qual[dsfcnt].dqual[6].data_col = "ALPHA_FEATURE_NBR = i4 CCL(ALPHA_FEATURE_NBR)"
   SET dm2_sch_file->qual[dsfcnt].dqual[7].data_col = "FEATURE_NUMBER = i4 CCL(FEATURE_NUMBER)"
   SET dm2_sch_file->qual[dsfcnt].dqual[8].data_col = "UPDT_DT_TM = dq8 CCL(UPDT_DT_TM)"
   SET dm2_sch_file->qual[dsfcnt].dqual[9].data_col = "FILLER = c1000 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmtbldoc(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_td"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMTBLDOC"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "2041"
   SET dm2_sch_file->qual[dsfcnt].data_size = "2011"
   SET dm2_sch_file->qual[dsfcnt].key_size = "30"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 30)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 1
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "TABLE_NAME = c30 CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 20
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col =
   "DATA_MODEL_SECTION = c80 CCL(DATA_MODEL_SECTION)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "DESCRIPTION = c80 CCL(DESCRIPTION)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "DEFINITION = c500 CCL(DEFINITION)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col = "STATIC_ROWS = i4 CCL(STATIC_ROWS)"
   SET dm2_sch_file->qual[dsfcnt].dqual[5].data_col = "UPDT_CNT = i4 CCL(UPDT_CNT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[6].data_col = "REFERENCE_IND = i2 CCL(REFERENCE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[7].data_col = "HUMAN_REQD_IND = i2 CCL(HUMAN_REQD_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[8].data_col = "DROP_IND = i2 CCL(DROP_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[9].data_col = "TABLE_SUFFIX = c4 CCL(TABLE_SUFFIX)"
   SET dm2_sch_file->qual[dsfcnt].dqual[10].data_col = "FULL_TABLE_NAME = c30 CCL(FULL_TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[11].data_col =
   "SUFFIXED_TABLE_NAME = c18 CCL(SUFFIXED_TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[12].data_col = "DEFAULT_ROW_IND = i2 CCL(DEFAULT_ROW_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[13].data_col =
   "PERSON_CMB_TRIGGER_TYPE = c10 CCL(PERSON_CMB_TRIGGER_TYPE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[14].data_col =
   "ENCNTR_CMB_TRIGGER_TYPE = c10 CCL(ENCNTR_CMB_TRIGGER_TYPE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[15].data_col = "MERGE_UI_QUERY = c255 CCL(MERGE_UI_QUERY)"
   SET dm2_sch_file->qual[dsfcnt].dqual[16].data_col = "MERGEABLE_IND  = i2 CCL(MERGEABLE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[17].data_col = "MERGE_DELETE_IND = i2 CCL(MERGE_DELETE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[18].data_col = "MERGE_ACTIVE_IND = i2 CCL(MERGE_ACTIVE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[19].data_col = "DATA_DISP_FLAG = i2 CCL(DATA_DISP_FLAG)"
   SET dm2_sch_file->qual[dsfcnt].dqual[20].data_col = "FILLER = c1000 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmcoldoc(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_cd"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMCOLDOC"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "2043"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1983"
   SET dm2_sch_file->qual[dsfcnt].key_size = "60"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 60)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 2
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "TABLE_NAME = c30 CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].kqual[2].key_col = "COLUMN_NAME = c30 CCL(COLUMN_NAME)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 19
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "SEQUENCE_NAME = c30 CCL(SEQUENCE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "CODE_SET = i4 CCL(CODE_SET)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "DESCRIPTION = c80 CCL(DESCRIPTION)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col = "DEFINITION = c500 CCL(DEFINITION)"
   SET dm2_sch_file->qual[dsfcnt].dqual[5].data_col = "FLAG_IND = i2 CCL(FLAG_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[6].data_col = "UPDT_CNT = i4 CCL(UPDT_CNT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[7].data_col = "UNIQUE_IDENT_IND = i2 CCL(UNIQUE_IDENT_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[8].data_col = "ROOT_ENTITY_NAME = c30 CCL(ROOT_ENTITY_NAME)"
   SET dm2_sch_file->qual[dsfcnt].dqual[9].data_col = "ROOT_ENTITY_ATTR = c30 CCL(ROOT_ENTITY_ATTR)"
   SET dm2_sch_file->qual[dsfcnt].dqual[10].data_col = "CONSTANT_VALUE = c255 CCL(CONSTANT_VALUE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[11].data_col =
   "PARENT_ENTITY_COL = c30 CCL(PARENT_ENTITY_COL)"
   SET dm2_sch_file->qual[dsfcnt].dqual[12].data_col = "EXCEPTION_FLG = i4 CCL(EXCEPTION_FLG)"
   SET dm2_sch_file->qual[dsfcnt].dqual[13].data_col =
   "DEFINING_ATTRIBUTE_IND = i2 CCL(DEFINING_ATTRIBUTE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[14].data_col =
   "MERGE_UPDATEABLE_IND = i2 CCL(MERGE_UPDATEABLE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[15].data_col = "NLS_COL_IND = i2 CCL(NLS_COL_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[16].data_col =
   "ABSOLUTE_DATE_IND = i2 CCL(ABSOLUTE_DATE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[17].data_col = "MERGE_DELETE_IND = I2 CCL(MERGE_DELETE_IND)"
   SET dm2_sch_file->qual[dsfcnt].dqual[18].data_col = "TZ_RULE_FLAG = I2 CCL(TZ_RULE_FLAG)"
   SET dm2_sch_file->qual[dsfcnt].dqual[19].data_col = "FILLER = c1000 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmtsprec(dsfcnt)
   SET dm2_sch_file->qual[dsfcnt].file_suffix = "_tp"
   SET dm2_sch_file->qual[dsfcnt].table_name = "DMTSPREC"
   SET dm2_sch_file->qual[dsfcnt].db_name = build(dm2_sch_file->qual[dsfcnt].table_name,dm2_sch_file
    ->sf_ver)
   SET dm2_sch_file->qual[dsfcnt].size = "1152"
   SET dm2_sch_file->qual[dsfcnt].data_size = "1118"
   SET dm2_sch_file->qual[dsfcnt].key_size = "34"
   SET dm2_sch_file->qual[dsfcnt].db_key = "unique key 1 (0, 34)"
   SET dm2_sch_file->qual[dsfcnt].key_cnt = 2
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].kqual,dm2_sch_file->qual[dsfcnt].key_cnt)
   SET dm2_sch_file->qual[dsfcnt].kqual[1].key_col = "TABLE_NAME = c30 CCL(TABLE_NAME)"
   SET dm2_sch_file->qual[dsfcnt].kqual[2].key_col = "PRECEDENCE = i4 CCL(PRECEDENCE)"
   SET dm2_sch_file->qual[dsfcnt].data_cnt = 8
   SET stat = alterlist(dm2_sch_file->qual[dsfcnt].dqual,dm2_sch_file->qual[dsfcnt].data_cnt)
   SET dm2_sch_file->qual[dsfcnt].dqual[1].data_col = "DATA_TABLESPACE = c30 CCL(DATA_TABLESPACE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[2].data_col = "DATA_EXTENT_SIZE = f8 CCL(DATA_EXTENT_SIZE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[3].data_col = "INDEX_TABLESPACE = c30 CCL(INDEX_TABLESPACE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[4].data_col = "INDEX_EXTENT_SIZE = f8 CCL(INDEX_EXTENT_SIZE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[5].data_col = "LONG_TABLESPACE = c30 CCL(LONG_TABLESPACE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[6].data_col = "LONG_EXTENT_SIZE = f8 CCL(LONG_EXTENT_SIZE)"
   SET dm2_sch_file->qual[dsfcnt].dqual[7].data_col = "UPDT_CNT = i4 CCL(UPDT_CNT)"
   SET dm2_sch_file->qual[dsfcnt].dqual[8].data_col = "FILLER = c1000 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsf_pop_dmtspace(dsfcnt)
   SET dm2_sch_file->qual[1].file_suffix = "_ts"
   SET dm2_sch_file->qual[1].table_name = "DMTSPACE"
   SET dm2_sch_file->qual[1].db_name = build(dm2_sch_file->qual[1].table_name,dm2_sch_file->sf_ver)
   SET dm2_sch_file->qual[1].size = "1056"
   SET dm2_sch_file->qual[1].data_size = "1026"
   SET dm2_sch_file->qual[1].key_size = "30"
   SET dm2_sch_file->qual[1].db_key = "unique key 1 (0, 30)"
   SET dm2_sch_file->qual[1].key_cnt = 1
   SET stat = alterlist(dm2_sch_file->qual[1].kqual,dm2_sch_file->qual[1].key_cnt)
   SET dm2_sch_file->qual[1].kqual[1].key_col = "TSPACE_NAME = c30  CCL(TSPACE_NAME)"
   SET dm2_sch_file->qual[1].data_cnt = 4
   SET stat = alterlist(dm2_sch_file->qual[1].dqual,dm2_sch_file->qual[1].data_cnt)
   SET dm2_sch_file->qual[1].dqual[1].data_col = "BYTES_NEEDED = f8  CCL(BYTES_NEEDED)"
   SET dm2_sch_file->qual[1].dqual[2].data_col = "EXT_MGMT = c10 CCL(EXT_MGMT)"
   SET dm2_sch_file->qual[1].dqual[3].data_col = "UPDT_DT_TM = dq8 CCL(UPDT_DT_TM)"
   SET dm2_sch_file->qual[1].dqual[4].data_col = "FILLER = c1000 CCL(FILLER)"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dsfi_load_schema_files(dlsf_desc,dlsf_process_option)
   DECLARE dlsf_tbl_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlsf_max_tc_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlsf_max_i_cnt = i2 WITH protect, noconstant(0)
   DECLARE dlsf_max_ic_cnt = i2 WITH protect, noconstant(0)
   DECLARE dlsf_max_c_cnt = i2 WITH protect, noconstant(0)
   DECLARE dlsf_max_cc_cnt = i2 WITH protect, noconstant(0)
   DECLARE dlsf_tc_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlsf_ind_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlsf_icol_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlsf_cons_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlsf_ccol_cnt = i4 WITH protect, noconstant(0)
   IF ((cur_sch->tbl_cnt <= 0))
    SET dm_err->eproc = "NO TABLES IN CURRENT SCHEMA"
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "No tables found for the schema snapshot."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   FOR (dlsf_tbl_cnt = 1 TO value(cur_sch->tbl_cnt))
     SET cur_sch->tbl[dlsf_tbl_cnt].capture_ind = 1
   ENDFOR
   SET dm_err->eproc = "POPULATE DMHEADER SCHEMA FILE WITH HEADER INFO"
   CALL disp_msg(" ",dm_err->logfile,0)
   INSERT  FROM dmheader dh
    SET dh.description = dlsf_desc, dh.admin_load_ind = 0, dh.source_rdbms = currdb,
     dh.sf_version = 1
    WITH nocounter
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "POPULATE DMTABLE SCHEMA FILE WITH TABLE INFO"
   CALL disp_msg(" ",dm_err->logfile,0)
   INSERT  FROM dmtable t,
     (dummyt d  WITH seq = value(cur_sch->tbl_cnt))
    SET t.seq = 1, t.table_name = cur_sch->tbl[d.seq].tbl_name, t.tablespace_name = cur_sch->tbl[d
     .seq].tspace_name,
     t.index_tspace = dm2_dft_clin_itspace, t.index_tspace_ni = 0, t.long_tspace = cur_sch->tbl[d.seq
     ].long_tspace,
     t.long_tspace_ni = cur_sch->tbl[d.seq].long_tspace_ni, t.init_ext = cur_sch->tbl[d.seq].init_ext,
     t.next_ext = cur_sch->tbl[d.seq].next_ext,
     t.pct_increase = cur_sch->tbl[d.seq].pct_increase, t.pct_used = cur_sch->tbl[d.seq].pct_used, t
     .pct_free = cur_sch->tbl[d.seq].pct_free,
     t.bytes_allocated = cur_sch->tbl[d.seq].bytes_allocated, t.bytes_used = cur_sch->tbl[d.seq].
     bytes_used, t.schema_date = cur_sch->tbl[d.seq].schema_date,
     t.schema_instance = cur_sch->tbl[d.seq].schema_instance, t.alpha_feature_nbr = 0, t
     .feature_number = 0,
     t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.tspace_type = cur_sch->tbl[d.seq].ext_mgmt, t
     .long_tspace_type = cur_sch->tbl[d.seq].lext_mgmt,
     t.max_ext = cur_sch->tbl[d.seq].max_ext
    PLAN (d
     WHERE (cur_sch->tbl[d.seq].capture_ind=1))
     JOIN (t
     WHERE (cur_sch->tbl[d.seq].tbl_name=t.table_name))
    WITH nocounter, outerjoin = d, dontexist
   ;end insert
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "POPULATE DMCOLUMN SCHEMA FILE WITH COLUMN INFO"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(cur_sch->tbl_cnt))
    PLAN (d)
    DETAIL
     IF ((cur_sch->tbl[d.seq].tbl_col_cnt > dlsf_max_tc_cnt))
      dlsf_max_tc_cnt = cur_sch->tbl[d.seq].tbl_col_cnt
     ENDIF
     dlsf_tc_cnt = (dlsf_tc_cnt+ cur_sch->tbl[d.seq].tbl_col_cnt)
    WITH nocounter
   ;end select
   IF (dlsf_max_tc_cnt > 0)
    INSERT  FROM dmcolumn tc,
      (dummyt d  WITH seq = value(cur_sch->tbl_cnt)),
      (dummyt d2  WITH seq = value(dlsf_max_tc_cnt))
     SET tc.seq = 1, tc.table_name = cur_sch->tbl[d.seq].tbl_name, tc.column_name = cur_sch->tbl[d
      .seq].tbl_col[d2.seq].col_name,
      tc.column_seq = cur_sch->tbl[d.seq].tbl_col[d2.seq].col_seq, tc.data_type = cur_sch->tbl[d.seq]
      .tbl_col[d2.seq].data_type, tc.data_length = cur_sch->tbl[d.seq].tbl_col[d2.seq].data_length,
      tc.nullable = cur_sch->tbl[d.seq].tbl_col[d2.seq].nullable, tc.data_default = cur_sch->tbl[d
      .seq].tbl_col[d2.seq].data_default, tc.data_default_ni = cur_sch->tbl[d.seq].tbl_col[d2.seq].
      data_default_ni,
      tc.data_default2 = cur_sch->tbl[d.seq].tbl_col[d2.seq].data_default, tc.virtual_column =
      cur_sch->tbl[d.seq].tbl_col[d2.seq].virtual_column
     PLAN (d
      WHERE (cur_sch->tbl[d.seq].capture_ind=1))
      JOIN (d2
      WHERE (d2.seq <= cur_sch->tbl[d.seq].tbl_col_cnt))
      JOIN (tc
      WHERE (cur_sch->tbl[d.seq].tbl_name=tc.table_name)
       AND (cur_sch->tbl[d.seq].tbl_col[d2.seq].col_name=tc.column_name))
     WITH nocounter, outerjoin = d2, dontexist
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ELSE
    SET dm_err->err_ind = 1
    CALL disp_msg("No column information found for tables.",dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "POPULATE DMINDEX SCHEMA FILE WITH INDEX INFO"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(cur_sch->tbl_cnt))
    PLAN (d)
    DETAIL
     IF ((cur_sch->tbl[d.seq].ind_cnt > dlsf_max_i_cnt))
      dlsf_max_i_cnt = cur_sch->tbl[d.seq].ind_cnt
     ENDIF
     dlsf_ind_cnt = (dlsf_ind_cnt+ cur_sch->tbl[d.seq].ind_cnt)
    WITH nocounter
   ;end select
   IF (dlsf_max_i_cnt > 0)
    INSERT  FROM dmindex i,
      (dummyt d  WITH seq = value(cur_sch->tbl_cnt)),
      (dummyt d2  WITH seq = value(dlsf_max_i_cnt))
     SET i.seq = 1, i.table_name = cur_sch->tbl[d.seq].tbl_name, i.index_name = cur_sch->tbl[d.seq].
      ind[d2.seq].ind_name,
      i.full_ind_name = cur_sch->tbl[d.seq].ind[d2.seq].full_ind_name, i.pct_increase = cur_sch->tbl[
      d.seq].ind[d2.seq].pct_increase, i.pct_free = cur_sch->tbl[d.seq].ind[d2.seq].pct_free,
      i.init_ext = cur_sch->tbl[d.seq].ind[d2.seq].init_ext, i.next_ext = cur_sch->tbl[d.seq].ind[d2
      .seq].next_ext, i.bytes_allocated = cur_sch->tbl[d.seq].ind[d2.seq].bytes_allocated,
      i.bytes_used = cur_sch->tbl[d.seq].ind[d2.seq].bytes_used, i.unique_ind = cur_sch->tbl[d.seq].
      ind[d2.seq].unique_ind, i.tspace_name = cur_sch->tbl[d.seq].ind[d2.seq].tspace_name,
      i.tspace_type = cur_sch->tbl[d.seq].ind[d2.seq].ext_mgmt, i.index_type = cur_sch->tbl[d.seq].
      ind[d2.seq].index_type, i.max_ext = cur_sch->tbl[d.seq].ind[d2.seq].max_ext
     PLAN (d
      WHERE (cur_sch->tbl[d.seq].capture_ind=1))
      JOIN (d2
      WHERE (d2.seq <= cur_sch->tbl[d.seq].ind_cnt))
      JOIN (i
      WHERE (cur_sch->tbl[d.seq].tbl_name=i.table_name)
       AND (cur_sch->tbl[d.seq].ind[d2.seq].ind_name=i.index_name))
     WITH nocounter, outerjoin = d2, dontexist
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "POPULATE DMINDCOL SCHEMA FILE WITH INDEX COLUMN INFO"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     d.seq
     FROM (dummyt d  WITH seq = value(cur_sch->tbl_cnt)),
      (dummyt d2  WITH seq = value(dlsf_max_i_cnt))
     PLAN (d)
      JOIN (d2
      WHERE (d2.seq <= cur_sch->tbl[d.seq].ind_cnt))
     DETAIL
      IF ((cur_sch->tbl[d.seq].ind[d2.seq].ind_col_cnt > dlsf_max_ic_cnt))
       dlsf_max_ic_cnt = cur_sch->tbl[d.seq].ind[d2.seq].ind_col_cnt
      ENDIF
      dlsf_icol_cnt = (dlsf_icol_cnt+ cur_sch->tbl[d.seq].ind[d2.seq].ind_col_cnt)
     WITH nocounter
    ;end select
    IF (dlsf_max_ic_cnt > 0)
     INSERT  FROM dmindcol ic,
       (dummyt d  WITH seq = value(cur_sch->tbl_cnt)),
       (dummyt d2  WITH seq = value(dlsf_max_i_cnt)),
       (dummyt d3  WITH seq = value(dlsf_max_ic_cnt))
      SET ic.seq = 1, ic.table_name = cur_sch->tbl[d.seq].tbl_name, ic.index_name = cur_sch->tbl[d
       .seq].ind[d2.seq].ind_name,
       ic.column_name = cur_sch->tbl[d.seq].ind[d2.seq].ind_col[d3.seq].col_name, ic.column_position
        = cur_sch->tbl[d.seq].ind[d2.seq].ind_col[d3.seq].col_position
      PLAN (d
       WHERE (cur_sch->tbl[d.seq].capture_ind=1))
       JOIN (d2
       WHERE (d2.seq <= cur_sch->tbl[d.seq].ind_cnt))
       JOIN (d3
       WHERE (d3.seq <= cur_sch->tbl[d.seq].ind[d2.seq].ind_col_cnt))
       JOIN (ic
       WHERE (cur_sch->tbl[d.seq].tbl_name=ic.table_name)
        AND (cur_sch->tbl[d.seq].ind[d2.seq].ind_name=ic.index_name)
        AND (cur_sch->tbl[d.seq].ind[d2.seq].ind_col[d3.seq].col_name=ic.column_name))
      WITH nocounter, outerjoin = d3, dontexist
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ELSE
     SET dm_err->err_ind = 1
     CALL disp_msg("No column information found for indexes.",dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = "POPULATE DMCONS SCHEMA FILE WITH CONSTRAINT INFO"
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(cur_sch->tbl_cnt))
    PLAN (d)
    DETAIL
     IF ((cur_sch->tbl[d.seq].cons_cnt > dlsf_max_c_cnt))
      dlsf_max_c_cnt = cur_sch->tbl[d.seq].cons_cnt
     ENDIF
     dlsf_cons_cnt = (dlsf_cons_cnt+ cur_sch->tbl[d.seq].cons_cnt)
    WITH nocounter
   ;end select
   IF (dlsf_max_c_cnt > 0)
    INSERT  FROM dmcons c,
      (dummyt d  WITH seq = value(cur_sch->tbl_cnt)),
      (dummyt d2  WITH seq = value(dlsf_max_c_cnt))
     SET c.seq = 1, c.table_name = cur_sch->tbl[d.seq].tbl_name, c.constraint_name = cur_sch->tbl[d
      .seq].cons[d2.seq].cons_name,
      c.full_cons_name = cur_sch->tbl[d.seq].cons[d2.seq].full_cons_name, c.constraint_type = cur_sch
      ->tbl[d.seq].cons[d2.seq].cons_type, c.status_ind = cur_sch->tbl[d.seq].cons[d2.seq].status_ind,
      c.r_constraint_name = cur_sch->tbl[d.seq].cons[d2.seq].r_constraint_name, c.parent_table_name
       = cur_sch->tbl[d.seq].cons[d2.seq].parent_table, c.parent_table_columns = cur_sch->tbl[d.seq].
      cons[d2.seq].parent_table_columns,
      c.delete_rule = cur_sch->tbl[d.seq].cons[d2.seq].delete_rule
     PLAN (d
      WHERE (cur_sch->tbl[d.seq].capture_ind=1))
      JOIN (d2
      WHERE (d2.seq <= cur_sch->tbl[d.seq].cons_cnt))
      JOIN (c
      WHERE (cur_sch->tbl[d.seq].tbl_name=c.table_name)
       AND (cur_sch->tbl[d.seq].cons[d2.seq].cons_name=c.constraint_name))
     WITH nocounter, outerjoin = d2, dontexist
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "POPULATE DMCONSCOL SCHEMA FILE WITH CONSTRAINT COLUMN INFO"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     d.seq
     FROM (dummyt d  WITH seq = value(cur_sch->tbl_cnt)),
      (dummyt d2  WITH seq = value(dlsf_max_c_cnt))
     PLAN (d)
      JOIN (d2
      WHERE (d2.seq <= cur_sch->tbl[d.seq].cons_cnt))
     DETAIL
      IF ((cur_sch->tbl[d.seq].cons[d2.seq].cons_col_cnt > dlsf_max_cc_cnt))
       dlsf_max_cc_cnt = cur_sch->tbl[d.seq].cons[d2.seq].cons_col_cnt
      ENDIF
      dlsf_ccol_cnt = (dlsf_ccol_cnt+ cur_sch->tbl[d.seq].cons[d2.seq].cons_col_cnt)
     WITH nocounter
    ;end select
    IF (dlsf_max_cc_cnt > 0)
     INSERT  FROM dmconscol cc,
       (dummyt d  WITH seq = value(cur_sch->tbl_cnt)),
       (dummyt d2  WITH seq = value(dlsf_max_c_cnt)),
       (dummyt d3  WITH seq = value(dlsf_max_cc_cnt))
      SET cc.seq = 1, cc.table_name = cur_sch->tbl[d.seq].tbl_name, cc.constraint_name = cur_sch->
       tbl[d.seq].cons[d2.seq].cons_name,
       cc.column_name = cur_sch->tbl[d.seq].cons[d2.seq].cons_col[d3.seq].col_name, cc.position =
       cur_sch->tbl[d.seq].cons[d2.seq].cons_col[d3.seq].col_position
      PLAN (d
       WHERE (cur_sch->tbl[d.seq].capture_ind=1))
       JOIN (d2
       WHERE (d2.seq <= cur_sch->tbl[d.seq].cons_cnt))
       JOIN (d3
       WHERE (d3.seq <= cur_sch->tbl[d.seq].cons[d2.seq].cons_col_cnt))
       JOIN (cc
       WHERE (cur_sch->tbl[d.seq].tbl_name=cc.table_name)
        AND (cur_sch->tbl[d.seq].cons[d2.seq].cons_name=cc.constraint_name)
        AND (cur_sch->tbl[d.seq].cons[d2.seq].cons_col[d3.seq].col_name=cc.column_name))
      WITH nocounter, outerjoin = d3, dontexist
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
    ELSE
     SET dm_err->err_ind = 1
     CALL disp_msg("No column information found for constraints.",dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE del_sch_files(null)
   DECLARE dsf_cnt = i4 WITH protect, noconstant(0)
   DECLARE dsf_name = vc WITH protect, noconstant("")
   FOR (dsf_cnt = 1 TO dm2_sch_file->file_cnt)
     SET dsf_name = build(dm2_sch_file->file_prefix,cnvtlower(dm2_sch_file->qual[dsf_cnt].file_suffix
       ))
     IF (del_sch_file(build(dm2_sch_file->dest_dir_osfmt,dsf_name,".dat"))=0)
      SET dm_err->err_ind = 1
      RETURN(0)
     ENDIF
     IF ((dm2_sys_misc->cur_os != "AXP"))
      IF (del_sch_file(build(dm2_sch_file->dest_dir_osfmt,dsf_name,".idx"))=0)
       SET dm_err->err_ind = 1
       RETURN(0)
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
#end_sch_files_inc
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 IF ( NOT (validate(rb_data,0)))
  FREE SET rb_data
  RECORD rb_data(
    1 in_house = i2
    1 batch_dt_tm = dq8
    1 env_id = f8
    1 execution = vc
    1 manual_readme_id = f8
    1 low_proj_name = vc
    1 high_proj_name = vc
    1 readme[*]
      2 id = i4
      2 instance = i4
      2 name = vc
      2 description = vc
      2 ocd = i4
      2 driver_table = vc
      2 driver_count = i4
      2 estimated_time = f8
      2 skip = i2
      2 execution = vc
    1 inactive[*]
      2 name = vc
      2 instance = i4
  )
 ENDIF
 IF ( NOT (validate(readme_error,0)))
  FREE SET readme_error
  RECORD readme_error(
    1 readme[*]
      2 readme_id = f8
      2 instance = i4
      2 description = vc
      2 message = vc
      2 ocd = i4
      2 options = vc
  )
 ENDIF
 IF (validate(dm2_rr_misc->dm2_toolset_usage," ")=" "
  AND validate(dm2_rr_misc->dm2_toolset_usage,"1")="1")
  FREE RECORD dm2_rr_misc
  RECORD dm2_rr_misc(
    1 dm2_toolset_usage = vc
    1 readme_errors_ind = i2
    1 env_id = f8
    1 batch_dt_tm = dq8
    1 process_type = c2
    1 package_number = i4
    1 execution = vc
    1 manual_readme_id = f8
    1 low_proj_name = vc
    1 high_proj_name = vc
  )
  SET dm2_rr_misc->dm2_toolset_usage = "NOT_SET"
  SET dm2_rr_misc->readme_errors_ind = 0
  SET dm2_rr_misc->env_id = 0.0
  SET dm2_rr_misc->batch_dt_tm = cnvtdatetimeutc("01-JAN-1800")
  SET dm2_rr_misc->process_type = ""
  SET dm2_rr_misc->package_number = 0
  SET dm2_rr_misc->execution = "NOT_SET"
  SET dm2_rr_misc->low_proj_name = ""
  SET dm2_rr_misc->high_proj_name = ""
 ENDIF
 IF ((validate(dm2_rr_spcchk->readme_cnt,- (1))=- (1))
  AND (validate(dm2_rr_spcchk->readme_cnt,- (2))=- (2)))
  FREE SET dm2_rr_spcchk
  RECORD dm2_rr_spcchk(
    1 space_needed = i2
    1 preup_space_needed = i2
    1 readme_cnt = i4
    1 readme_list[*]
      2 readme_id = f8
      2 spcchk_readme_id = f8
      2 script = vc
      2 tbl_cnt = i4
      2 tbl_list[*]
        3 table_name = vc
        3 large_data_loaded = i2
        3 insert_row_cnt = f8
        3 col_updt_cnt = i4
        3 col_updt[*]
          4 update_row_cnt = f8
          4 column_name = vc
  )
  SET dm2_rr_spcchk->readme_cnt = 0
  SET dm2_rr_spcchk->preup_space_needed = 0
  SET dm2_rr_spcchk->space_needed = 0
 ENDIF
 IF ((validate(dm2_rr_spc_needs->tbl_cnt,- (1))=- (1))
  AND (validate(dm2_rr_spc_needs->tbl_cnt,- (2))=- (2)))
  FREE SET dm2_rr_spc_needs
  RECORD dm2_rr_spc_needs(
    1 space_needed = i2
    1 tbl_cnt = i4
    1 tbl[*]
      2 table_name = vc
      2 skip_ind = i2
      2 large_data_loaded = i2
      2 insert_row_cnt = f8
      2 col_updt_cnt = i4
      2 col_updt[*]
        3 update_row_cnt = f8
        3 column_name = vc
      2 tgt_idx = i4
      2 cur_idx = i4
      2 space_needed = f8
      2 ind_cnt = i4
      2 ind[*]
        3 ind_name = vc
        3 tgt_idx = i4
        3 cur_idx = i4
        3 space_needed = f8
  )
  SET dm2_rr_spc_needs->tbl_cnt = 0
 ENDIF
 IF (validate(drr_readmes_to_run->readme_cnt,0)=0
  AND validate(drr_readmes_to_run->readme_cnt,1)=1)
  FREE RECORD drr_readmes_to_run
  RECORD drr_readmes_to_run(
    1 readme_cnt = i4
    1 readme[*]
      2 readme_id = f8
      2 instance = i4
      2 name = vc
      2 description = c50
      2 ocd = i4
      2 execution = vc
      2 execution_order = vc
      2 category = vc
      2 driver_table = vc
      2 execution_time = f8
      2 status = vc
      2 start_dt_tm = dq8
      2 end_dt_tm = dq8
      2 skip = i2
      2 driver_count = i4
      2 estimated_time = f8
      2 spchk_readme_cnt = i4
      2 spchk_readme[*]
        3 readme_id = f8
        3 instance = i4
        3 ocd = i4
        3 execution = vc
        3 script = vc
        3 skip = i2
    1 timer_readme_cnt = i4
    1 timer_readme[*]
      2 parent_readme_id = f8
      2 readme_id = f8
      2 instance = i4
      2 ocd = i4
      2 execution = vc
      2 script = vc
      2 skip = i2
    1 inactive_cnt = i4
    1 inactive[*]
      2 name = vc
      2 instance = i4
  )
 ENDIF
 IF ((validate(dm2_rr_defined,- (1))=- (1))
  AND (validate(dm2_rr_defined,- (2))=- (2)))
  DECLARE dm2_rr_defined = i2 WITH public, constant(1)
  DECLARE dm2_rr_error = i2 WITH public, constant(0)
  DECLARE dm2_rr_warning = i2 WITH public, constant(1)
  DECLARE dm2_rr_info = i2 WITH public, constant(2)
  DECLARE dm2_rr_readme = vc WITH public, constant("README")
  DECLARE dm2_rr_dbimport = vc WITH public, constant("DBIMPORT")
  DECLARE dm2_rr_oracle = vc WITH public, constant("ORACLE")
  DECLARE dm2_rr_oracle_ref = vc WITH public, constant("ORACLEREF")
  DECLARE dm2_rr_ccl_dbimport = vc WITH public, constant("CCLDBIMPORT")
  DECLARE dm2_rr_tbl_import = vc WITH public, constant("TABLEIMPORT")
  DECLARE dm2_rr_readme_rback = vc WITH public, constant("README:RBACK")
  DECLARE dm2_rr_running = vc WITH public, constant("RUNNING")
  DECLARE dm2_rr_done = vc WITH public, constant("SUCCESS")
  DECLARE dm2_rr_failed = vc WITH public, constant("FAILED")
  DECLARE dm2_rr_reset = vc WITH public, constant("RESET")
  DECLARE dm2_rr_pre_schema_up = vc WITH public, constant("PREUP")
  DECLARE dm2_rr_post_schema_up = vc WITH public, constant("POSTUP")
  DECLARE dm2_rr_post_schema_up2 = vc WITH public, constant("POSTUP2")
  DECLARE dm2_rr_pre_cycle = vc WITH public, constant("PRECYCLE")
  DECLARE dm2_rr_pre_schema_down = vc WITH public, constant("PREDOWN")
  DECLARE dm2_rr_post_schema_down = vc WITH public, constant("POSTDOWN")
  DECLARE dm2_rr_uptime = vc WITH public, constant("UP")
  DECLARE dm2_rr_timer = vc WITH public, constant("RDMTIMER")
 ENDIF
 IF (validate(drr_killed_appl->appl_cnt,1)=1
  AND validate(drr_killed_appl->appl_cnt,2)=2)
  FREE RECORD drr_killed_appl
  RECORD drr_killed_appl(
    1 appl_cnt = i4
    1 appl[*]
      2 appl_id = vc
  )
  SET drr_killed_appl->appl_cnt = 0
 ENDIF
 DECLARE dm2_rr_toolset_usage(null) = i2
 DECLARE dm2_rr_clean_stranded_readmes(drcsr_env_id=f8) = i2
 DECLARE drr_load_readmes_to_run(null) = i2
 DECLARE drr_load_space_chk_readmes(dlscr_execution=vc,dlscr_spcchk_flag=i2(ref)) = i2
 DECLARE drr_load_timing_readmes(null) = i2
 DECLARE drr_alert_killed_appl(daka_load_ind=i2,daka_fmt_appl_id=vc,daka_kill_ind=i2(ref)) = i2
 SUBROUTINE dm2_rr_toolset_usage(null)
   DECLARE drtu_found_ind = i2 WITH protect, noconstant(0)
   IF ((dm2_rr_misc->dm2_toolset_usage != "NOT_SET"))
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Determining if DM_INFO exists."
   IF ((dm_err->debug_flag > 0))
    CALL echo(dm_err->eproc)
   ENDIF
   IF (dm2_table_and_ccldef_exists("DM_INFO",drtu_found_ind)=0)
    RETURN(0)
   ENDIF
   IF (drtu_found_ind=0)
    SET dm2_rr_misc->dm2_toolset_usage = "Y"
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Check for DM_README_TOOLSET row."
   IF ((dm_err->debug_flag > 0))
    CALL echo(dm_err->eproc)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DATA MANAGEMENT"
     AND d.info_name="DM_README_TOOLSET"
    WITH nocounter
   ;end select
   SET dm_err->ecode = error(dm_err->emsg,1)
   IF ((dm_err->ecode != 0))
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dm2_rr_misc->dm2_toolset_usage = "N"
   ELSEIF (curqual=0)
    SET dm2_rr_misc->dm2_toolset_usage = "Y"
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_rr_clean_stranded_readmes(drcsr_env_id)
   DECLARE rcsr_cnt = i4 WITH protect, noconstant(0)
   DECLARE rcsr_fmt_appl_id = vc WITH protect, noconstant(" ")
   DECLARE rcsr_error_msg = vc WITH protect, noconstant(" ")
   DECLARE rcsr_load_ind = i2 WITH protect, noconstant(1)
   DECLARE rcsr_kill_ind = i2 WITH protect, noconstant(0)
   FREE RECORD rcsr_appl_rs
   RECORD rcsr_appl_rs(
     1 rcsr_appl_cnt = i4
     1 rcsr_appl[*]
       2 rcsr_appl_id = vc
       2 rcsr_validity = vc
   )
   SET dm_err->eproc = "Get distinct application ids."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT DISTINCT INTO "nl:"
    l.appl_ident
    FROM dm_ocd_log l
    WHERE l.environment_id=drcsr_env_id
     AND l.project_type=dm2_rr_readme
     AND ((l.status=dm2_rr_running) OR (l.status=null))
    HEAD REPORT
     rcsr_cnt = 0
    DETAIL
     rcsr_cnt = (rcsr_cnt+ 1)
     IF (mod(rcsr_cnt,10)=1)
      stat = alterlist(rcsr_appl_rs->rcsr_appl,(rcsr_cnt+ 9))
     ENDIF
     IF (isnumeric(l.appl_ident)=0)
      rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_validity = "INVALID"
     ELSE
      rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_validity = "VALID"
     ENDIF
     rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_appl_id = l.appl_ident
    FOOT REPORT
     rcsr_appl_rs->rcsr_appl_cnt = rcsr_cnt, stat = alterlist(rcsr_appl_rs->rcsr_appl,rcsr_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((rcsr_appl_rs->rcsr_appl_cnt > 0))
    SET rcsr_cnt = 0
    FOR (rcsr_cnt = 1 TO rcsr_appl_rs->rcsr_appl_cnt)
      IF ((rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_validity="INVALID"))
       SET rcsr_error_msg = "Session executing readme is no longer active"
       SET dm_err->eproc = "Update stranded readme process to failed."
       IF ((dm_err->debug_flag > 0))
        CALL disp_msg(" ",dm_err->logfile,0)
       ENDIF
       UPDATE  FROM dm_ocd_log l
        SET l.status = dm2_rr_failed, l.message = rcsr_error_msg, l.start_dt_tm = evaluate(nullind(l
           .start_dt_tm),1,cnvtdatetime(curdate,curtime3),l.start_dt_tm)
        WHERE l.environment_id=drcsr_env_id
         AND l.project_type=dm2_rr_readme
         AND ((l.status=dm2_rr_running) OR (l.status = null))
         AND ((l.appl_ident = null) OR ((l.appl_ident=rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_appl_id)
        ))
        WITH nocounter
       ;end update
       IF (check_error(dm_err->eproc)=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
        RETURN(0)
       ELSE
        COMMIT
       ENDIF
      ELSE
       CASE (dm2_get_appl_status(value(rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_appl_id)))
        OF "I":
         SET dm_err->eproc = "Update inactive readme process to failed."
         SET rcsr_fmt_appl_id = rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_appl_id
         IF (drr_alert_killed_appl(rcsr_load_ind,rcsr_fmt_appl_id,rcsr_kill_ind)=0)
          RETURN(0)
         ENDIF
         SET rcsr_load_ind = 0
         IF (rcsr_kill_ind=1)
          SET rcsr_error_msg = dir_kill_clause
         ELSE
          SET rcsr_error_msg = "Session executing readme is no longer active."
         ENDIF
         IF ((dm_err->debug_flag > 0))
          CALL disp_msg(" ",dm_err->logfile,0)
         ENDIF
         UPDATE  FROM dm_ocd_log l
          SET l.status = dm2_rr_failed, l.message = rcsr_error_msg, l.start_dt_tm = evaluate(nullind(
             l.start_dt_tm),1,cnvtdatetime(curdate,curtime3),l.start_dt_tm)
          WHERE l.environment_id=drcsr_env_id
           AND l.appl_ident=value(rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_appl_id)
           AND l.project_type=dm2_rr_readme
           AND ((l.status=dm2_rr_running) OR (l.status = null))
          WITH nocounter
         ;end update
         IF (check_error(dm_err->eproc)=1)
          ROLLBACK
          CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
          RETURN(0)
         ELSE
          COMMIT
         ENDIF
        OF "A":
         IF ((dm_err->debug_flag > 0))
          CALL echo(build("Application Id ",rcsr_appl_rs->rcsr_appl[rcsr_cnt].rcsr_appl_id,
            " is active."))
         ENDIF
        OF "E":
         IF ((dm_err->debug_flag > 0))
          CALL echo("Error Detected in dm2_get_appl_status")
         ENDIF
         RETURN(0)
       ENDCASE
      ENDIF
    ENDFOR
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo("********** No application IDs associated with stranded readmes **********")
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_load_readmes_to_run(null)
   DECLARE dlrr_cnt = i4 WITH protect, noconstant(0)
   FREE RECORD drr_readmes_on_pkg
   RECORD drr_readmes_on_pkg(
     1 cnt = i4
     1 qual[*]
       2 readme_id = f8
       2 instance = i4
       2 ocd = f8
       2 skip = i2
       2 run_once_ind = i2
       2 name = vc
       2 description = c50
       2 execution = vc
       2 category = vc
       2 driver_table = vc
       2 execution_time = f8
       2 skip = i2
       2 driver_count = i4
       2 estimated_time = f8
   )
   IF ((drr_readmes_to_run->readme_cnt > 0))
    SET drr_readmes_to_run->readme_cnt = 0
    SET stat = alterlist(drr_readmes_to_run->readme,0)
   ENDIF
   IF ((drr_readmes_to_run->inactive_cnt > 0))
    SET drr_readmes_to_run->inactive_cnt = 0
    SET stat = alterlist(drr_readmes_to_run->inactive,0)
   ENDIF
   IF ( NOT ((dm2_rr_misc->process_type IN ("PI", "IH", "MM"))))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating process type."
    SET dm_err->emsg = "Unrecognized process type."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm2_rr_misc->env_id=0))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating environment ID."
    SET dm_err->emsg = "Invalid environment_id."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm2_rr_misc->process_type="PI"))
    IF ((dm2_rr_misc->package_number=0))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validating package number."
     SET dm_err->emsg =
     "Package number or batch number was 0.  Cannot process readmes for package install."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ELSEIF ( NOT ((dm2_rr_misc->execution IN ("ALL", "PREUP", "POSTUP", "POSTUP2", "PRECYCLE",
    "PREDOWN", "POSTDOWN", "UP"))))
     SET dm_err->err_ind = 1
     SET dm_err->eproc = "Validating process type."
     SET dm_err->emsg = "Unrecognized process type.  Cannot process readmes."
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ELSEIF ((dm2_rr_misc->process_type="IH")
    AND ((cnvtint(dm2_rr_misc->low_proj_name) < 0) OR (cnvtint(dm2_rr_misc->high_proj_name) <= 0)) )
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating inhouse project range."
    SET dm_err->emsg = "Invalid project range.  Cannot process inhouse readmes."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ELSEIF ((dm2_rr_misc->process_type="MM")
    AND  NOT ((dm2_rr_misc->execution IN ("ALL", "PREUP", "POSTUP", "PREDOWN", "POSTDOWN",
   "UP"))))
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating process type."
    SET dm_err->emsg = "Unrecognized process type.  Cannot process readmes."
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET rdm_cnt = 0
   SET inactive_cnt = 0
   IF ((dm2_rr_misc->process_type="PI"))
    SET dm_err->eproc = "Gathering list of readmes on plan..."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_ocd_readme o
     WHERE (o.ocd=dm2_rr_misc->package_number)
     ORDER BY o.readme_id
     DETAIL
      rdm_cnt = (rdm_cnt+ 1)
      IF (mod(rdm_cnt,100)=1)
       stat = alterlist(drr_readmes_on_pkg->qual,(rdm_cnt+ 99))
      ENDIF
      drr_readmes_on_pkg->qual[rdm_cnt].readme_id = o.readme_id, drr_readmes_on_pkg->qual[rdm_cnt].
      name = trim(cnvtstring(o.readme_id),3), drr_readmes_on_pkg->qual[rdm_cnt].ocd = o.ocd,
      drr_readmes_on_pkg->qual[rdm_cnt].instance = o.instance
     FOOT REPORT
      stat = alterlist(drr_readmes_on_pkg->qual,rdm_cnt), drr_readmes_on_pkg->cnt = rdm_cnt
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF ((drr_readmes_on_pkg->cnt=0))
     SET dm_err->eproc = "No readmes found to run."
     CALL disp_msg("",dm_err->logfile,0)
     RETURN(1)
    ENDIF
    SELECT INTO "nl:"
     FROM dm_readme r,
      dm_ocd_readme o,
      dm_alpha_features_env a,
      (dummyt d  WITH seq = value(drr_readmes_on_pkg->cnt))
     PLAN (d)
      JOIN (r
      WHERE r.owner=currdbuser
       AND (r.readme_id=drr_readmes_on_pkg->qual[d.seq].readme_id)
       AND (r.instance > drr_readmes_on_pkg->qual[d.seq].instance))
      JOIN (o
      WHERE o.readme_id=r.readme_id
       AND o.ocd > 0
       AND o.instance=r.instance)
      JOIN (a
      WHERE a.alpha_feature_nbr=o.ocd
       AND (a.environment_id=dm2_rr_misc->env_id)
       AND  NOT (a.inst_mode IN ("PREVIEW", "BATCHPREVIEW")))
     ORDER BY r.readme_id, r.instance DESC
     HEAD r.readme_id
      IF (r.active_ind=0)
       CALL echo(concat("Instance ",build(r.instance)," from ",build(o.ocd)," for readme ",
        build(o.readme_id)," will be skipped due to being inactive on highest instance.")),
       drr_readmes_on_pkg->qual[d.seq].skip = 1
      ELSE
       CALL echo(concat("Replacing Instance ",build(drr_readmes_on_pkg->qual[d.seq].instance),
        " with instance ",build(r.instance)," from ",
        build(o.ocd)," for readme ",build(o.readme_id))), drr_readmes_on_pkg->qual[d.seq].instance =
       r.instance, drr_readmes_on_pkg->qual[d.seq].ocd = o.ocd
      ENDIF
     FOOT  r.readme_id
      row + 0
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Marking completed readmes as SKIPPED."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_ocd_log l,
      (dummyt d  WITH seq = value(drr_readmes_on_pkg->cnt))
     PLAN (d)
      JOIN (l
      WHERE (l.environment_id=dm2_rr_misc->env_id)
       AND l.project_type=dm2_rr_readme
       AND (l.project_name=drr_readmes_on_pkg->qual[d.seq].name)
       AND (l.ocd=drr_readmes_on_pkg->qual[d.seq].ocd)
       AND l.status=dm2_rr_done
       AND l.active_ind=1)
     DETAIL
      drr_readmes_on_pkg->qual[d.seq].skip = 1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Loading readme metadata."
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_readme r,
      (dummyt d  WITH seq = value(drr_readmes_on_pkg->cnt))
     PLAN (d
      WHERE (drr_readmes_on_pkg->qual[d.seq].skip=0))
      JOIN (r
      WHERE (drr_readmes_on_pkg->qual[d.seq].readme_id=r.readme_id)
       AND (drr_readmes_on_pkg->qual[d.seq].instance=r.instance)
       AND r.owner=currdbuser)
     ORDER BY r.readme_id
     HEAD r.readme_id
      drr_readmes_on_pkg->qual[d.seq].readme_id = r.readme_id, drr_readmes_on_pkg->qual[d.seq].
      instance = r.instance, drr_readmes_on_pkg->qual[d.seq].name = trim(cnvtstring(r.readme_id),3),
      drr_readmes_on_pkg->qual[d.seq].execution = cnvtupper(trim(r.execution,3)), drr_readmes_on_pkg
      ->qual[d.seq].description = r.description, drr_readmes_on_pkg->qual[d.seq].driver_table =
      cnvtupper(trim(r.driver_table,3)),
      drr_readmes_on_pkg->qual[d.seq].execution_time = r.execution_time, drr_readmes_on_pkg->qual[d
      .seq].run_once_ind = r.run_once_ind, drr_readmes_on_pkg->qual[d.seq].estimated_time = 0,
      drr_readmes_on_pkg->qual[d.seq].driver_count = 0, drr_readmes_on_pkg->qual[d.seq].skip =
      evaluate(r.active_ind,0,1,0)
      IF ((drr_readmes_on_pkg->qual[d.seq].skip=1))
       CALL echo(concat("Skipping inactive readme ",build(r.readme_id)," instance ",build(r.instance)
        ))
      ENDIF
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Skipping RUN ONCE Readmes"
    CALL disp_msg(" ",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM dm_ocd_log l,
      (dummyt d  WITH seq = value(drr_readmes_on_pkg->cnt))
     PLAN (d
      WHERE (drr_readmes_on_pkg->qual[d.seq].skip=0)
       AND (drr_readmes_on_pkg->qual[d.seq].run_once_ind=1))
      JOIN (l
      WHERE (l.environment_id=dm2_rr_misc->env_id)
       AND l.project_type=dm2_rr_readme
       AND (l.project_name=drr_readmes_on_pkg->qual[d.seq].name)
       AND l.status=dm2_rr_done
       AND l.active_ind=1
       AND (l.project_instance=drr_readmes_on_pkg->qual[d.seq].instance))
     DETAIL
      drr_readmes_on_pkg->qual[d.seq].skip = 1
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF ((dm_err->debug_flag > 1))
     CALL echorecord(drr_readmes_on_pkg)
    ENDIF
    SET rdm_cnt = 0
    FOR (dlrr_cnt = 1 TO drr_readmes_on_pkg->cnt)
      IF ((((dm2_rr_misc->execution != "ALL")
       AND (drr_readmes_on_pkg->qual[dlrr_cnt].execution=dm2_rr_misc->execution)) OR ((dm2_rr_misc->
      execution="ALL")
       AND (drr_readmes_on_pkg->qual[dlrr_cnt].execution IN ("PREUP", "POSTUP", "POSTUP2", "PRECYCLE",
      "PREDOWN",
      "POSTDOWN", "UP")))) )
       IF ((drr_readmes_on_pkg->qual[dlrr_cnt].skip=1)
        AND (drr_readmes_on_pkg->qual[dlrr_cnt].run_once_ind=1))
        CALL echo(concat("Skip run once readme:",drr_readmes_on_pkg->qual[dlrr_cnt].name))
       ELSE
        SET rdm_cnt = (rdm_cnt+ 1)
        SET stat = alterlist(drr_readmes_to_run->readme,rdm_cnt)
        SET drr_readmes_to_run->readme[rdm_cnt].readme_id = drr_readmes_on_pkg->qual[dlrr_cnt].
        readme_id
        SET drr_readmes_to_run->readme[rdm_cnt].instance = drr_readmes_on_pkg->qual[dlrr_cnt].
        instance
        SET drr_readmes_to_run->readme[rdm_cnt].name = drr_readmes_on_pkg->qual[dlrr_cnt].name
        SET drr_readmes_to_run->readme[rdm_cnt].execution = drr_readmes_on_pkg->qual[dlrr_cnt].
        execution
        SET drr_readmes_to_run->readme[rdm_cnt].description = drr_readmes_on_pkg->qual[dlrr_cnt].
        description
        SET drr_readmes_to_run->readme[rdm_cnt].ocd = drr_readmes_on_pkg->qual[dlrr_cnt].ocd
        SET drr_readmes_to_run->readme[rdm_cnt].driver_table = drr_readmes_on_pkg->qual[dlrr_cnt].
        driver_table
        SET drr_readmes_to_run->readme[rdm_cnt].execution_time = drr_readmes_on_pkg->qual[dlrr_cnt].
        execution_time
        SET drr_readmes_to_run->readme[rdm_cnt].estimated_time = drr_readmes_on_pkg->qual[dlrr_cnt].
        estimated_time
        SET drr_readmes_to_run->readme[rdm_cnt].driver_count = drr_readmes_on_pkg->qual[dlrr_cnt].
        driver_count
        SET drr_readmes_to_run->readme[rdm_cnt].skip = drr_readmes_on_pkg->qual[dlrr_cnt].skip
        SET drr_readmes_to_run->readme_cnt = rdm_cnt
       ENDIF
      ENDIF
    ENDFOR
    IF ((dm_err->debug_flag > 1))
     CALL echorecord(drr_readmes_to_run)
    ENDIF
    IF ((drr_readmes_to_run->readme_cnt=0))
     SET dm_err->eproc = "No readmes found to run."
     CALL disp_msg("",dm_err->logfile,0)
     RETURN(1)
    ENDIF
    SET rdm_cnt = 0
    FOR (rdm_cnt = 1 TO drr_readmes_to_run->readme_cnt)
      IF ((drr_readmes_to_run->readme[rdm_cnt].skip=0))
       CALL echo(concat("Readme ",build(drr_readmes_to_run->readme[rdm_cnt].readme_id)," will run."))
      ENDIF
    ENDFOR
   ELSEIF ((dm2_rr_misc->process_type="IH"))
    SET dm_err->eproc = "Getting list of readmes for inhouse processing."
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     r.readme_id
     FROM dm_project_status_env s,
      dm_readme r
     PLAN (s
      WHERE (s.environment_id=dm2_rr_misc->env_id)
       AND s.proj_type=dm2_rr_readme
       AND cnvtint(s.proj_name) > 0
       AND s.proj_name BETWEEN dm2_rr_misc->low_proj_name AND dm2_rr_misc->high_proj_name
       AND s.dm_status = null)
      JOIN (r
      WHERE r.readme_id=cnvtint(s.proj_name)
       AND r.instance=s.source_set_instance
       AND r.owner=currdbuser)
     ORDER BY r.readme_id, r.instance DESC
     HEAD r.readme_id
      IF (r.active_ind)
       rdm_cnt = (rdm_cnt+ 1)
       IF (mod(rdm_cnt,10)=1)
        stat = alterlist(drr_readmes_to_run->readme,(rdm_cnt+ 9))
       ENDIF
       drr_readmes_to_run->readme[rdm_cnt].readme_id = r.readme_id, drr_readmes_to_run->readme[
       rdm_cnt].instance = r.instance, drr_readmes_to_run->readme[rdm_cnt].name = trim(cnvtstring(r
         .readme_id),3),
       drr_readmes_to_run->readme[rdm_cnt].execution = cnvtupper(trim(r.execution,3)),
       drr_readmes_to_run->readme[rdm_cnt].description = trim(r.description,3), drr_readmes_to_run->
       readme[rdm_cnt].driver_table = cnvtupper(trim(r.driver_table,3)),
       drr_readmes_to_run->readme[rdm_cnt].execution_time = r.execution_time, drr_readmes_to_run->
       readme[rdm_cnt].estimated_time = 0, drr_readmes_to_run->readme[rdm_cnt].driver_count = 0
       IF ((drr_readmes_to_run->readme[rdm_cnt].execution IN ("PRESPCHK", "POSTSPCHK", "RDMTIMER")))
        drr_readmes_to_run->readme[rdm_cnt].skip = 1
       ENDIF
      ELSE
       inactive_cnt = (inactive_cnt+ 1)
       IF (mod(inactive_cnt,10)=1)
        stat = alterlist(drr_readmes_to_run->inactive,(inactive_cnt+ 9))
       ENDIF
       drr_readmes_to_run->inactive[inactive_cnt].name = trim(cnvtstring(r.readme_id),3),
       drr_readmes_to_run->inactive[inactive_cnt].instance = r.instance
      ENDIF
     FOOT REPORT
      stat = alterlist(drr_readmes_to_run->inactive,inactive_cnt), stat = alterlist(
       drr_readmes_to_run->readme,rdm_cnt), drr_readmes_to_run->readme_cnt = rdm_cnt,
      drr_readmes_to_run->inactive_cnt = inactive_cnt
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ELSEIF ((dm2_rr_misc->process_type="MM"))
    SET dm_err->eproc = "Gathering list of readmes to run..."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (validate(doc->source_ocd_cnt,- (1)) > 0)
     SELECT INTO "nl:"
      FROM dm_ocd_readme o,
       dm_readme r,
       (dummyt d  WITH seq = value(doc->source_ocd_cnt))
      PLAN (d)
       JOIN (o
       WHERE (o.ocd=doc->qual[d.seq].ocd_nbr))
       JOIN (r
       WHERE r.readme_id=o.readme_id
        AND r.instance=o.instance
        AND  NOT ( EXISTS (
       (SELECT
        l.project_name
        FROM dm_ocd_log l,
         dm_readme x
        WHERE x.readme_id=r.readme_id
         AND x.run_once_ind=1
         AND (l.environment_id=dm2_rr_misc->env_id)
         AND l.project_type=dm2_rr_readme
         AND l.ocd > 0
         AND l.project_name=trim(cnvtstring(x.readme_id),3)
         AND l.project_instance >= r.instance
         AND l.status=dm2_rr_done
         AND l.active_ind=1))))
      ORDER BY r.readme_id, r.instance DESC, o.ocd DESC
      HEAD REPORT
       row + 0
      HEAD r.readme_id
       IF (r.active_ind=1
        AND (r.execution=dm2_rr_misc->execution))
        rdm_cnt = (rdm_cnt+ 1)
        IF (mod(rdm_cnt,10)=1)
         stat = alterlist(drr_readmes_to_run->readme,(rdm_cnt+ 9))
        ENDIF
        drr_readmes_to_run->readme[rdm_cnt].readme_id = r.readme_id, drr_readmes_to_run->readme[
        rdm_cnt].instance = r.instance, drr_readmes_to_run->readme[rdm_cnt].name = trim(cnvtstring(r
          .readme_id),3),
        drr_readmes_to_run->readme[rdm_cnt].description = r.description, drr_readmes_to_run->readme[
        rdm_cnt].ocd = o.ocd, drr_readmes_to_run->readme[rdm_cnt].driver_table = cnvtupper(trim(r
          .driver_table,3)),
        drr_readmes_to_run->readme[rdm_cnt].execution_time = r.execution_time, drr_readmes_to_run->
        readme[rdm_cnt].estimated_time = 0, drr_readmes_to_run->readme[rdm_cnt].driver_count = 0
       ENDIF
      FOOT REPORT
       stat = alterlist(drr_readmes_to_run->readme,rdm_cnt), drr_readmes_to_run->readme_cnt = rdm_cnt
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
     SET dm_err->eproc = "Marking completed readmes as SKIPPED."
     CALL disp_msg(" ",dm_err->logfile,0)
     SELECT INTO "nl:"
      l.status
      FROM dm_ocd_log l,
       (dummyt d  WITH seq = value(rdm_cnt))
      PLAN (d)
       JOIN (l
       WHERE (l.environment_id=dm2_rr_misc->env_id)
        AND l.project_type=dm2_rr_readme
        AND (l.project_name=drr_readmes_to_run->readme[d.seq].name)
        AND (l.ocd=drr_readmes_to_run->readme[d.seq].ocd)
        AND l.status=dm2_rr_done
        AND l.active_ind=1)
      DETAIL
       drr_readmes_to_run->readme[d.seq].skip = 1
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
      RETURN(0)
     ENDIF
    ELSE
     SELECT INTO "nl:"
      status = decode(l.seq,l.status,"NOT RUN"), start_dt_tm = decode(l.seq,l.start_dt_tm,
       cnvtdatetime(curdate,curtime)), end_dt_tm = decode(l.seq,l.end_dt_tm,cnvtdatetime(curdate,
        curtime))
      FROM dm_alpha_features_env a,
       dm_ocd_readme o,
       dm_readme r,
       dm_ocd_log l,
       dummyt d
      PLAN (a
       WHERE (a.environment_id=dm2_rr_misc->env_id)
        AND a.curr_migration_ind=1)
       JOIN (o
       WHERE o.ocd=a.alpha_feature_nbr)
       JOIN (r
       WHERE r.readme_id=o.readme_id
        AND r.instance=o.instance
        AND  NOT ( EXISTS (
       (SELECT
        m.project_name
        FROM dm_ocd_log m,
         dm_readme x
        WHERE x.readme_id=r.readme_id
         AND x.run_once_ind=1
         AND (m.environment_id=dm2_rr_misc->env_id)
         AND m.project_type=dm2_rr_readme
         AND m.project_name=trim(cnvtstring(x.readme_id),3)
         AND m.status=dm2_rr_done
         AND m.ocd != o.ocd))))
       JOIN (d)
       JOIN (l
       WHERE (l.environment_id=dm2_rr_misc->env_id)
        AND l.project_type=dm2_rr_readme
        AND trim(cnvtstring(r.readme_id),3)=l.project_name
        AND l.ocd=o.ocd
        AND l.project_instance=r.instance)
      ORDER BY r.readme_id, r.instance DESC, o.ocd DESC
      HEAD r.readme_id
       IF (r.active_ind=1)
        rdm_cnt = (rdm_cnt+ 1)
        IF (mod(rdm_cnt,10)=1)
         stat = alterlist(drr_readmes_to_run->readme,(rdm_cnt+ 9))
        ENDIF
        drr_readmes_to_run->readme[rdm_cnt].readme_id = r.readme_id, drr_readmes_to_run->readme[
        rdm_cnt].instance = r.instance, drr_readmes_to_run->readme[rdm_cnt].description = trim(r
         .description),
        drr_readmes_to_run->readme[rdm_cnt].ocd = o.ocd, drr_readmes_to_run->readme[rdm_cnt].
        execution = cnvtupper(trim(r.execution,3)), drr_readmes_to_run->readme[rdm_cnt].driver_table
         = cnvtupper(trim(r.driver_table,3)),
        drr_readmes_to_run->readme[rdm_cnt].execution_time = r.execution_time, drr_readmes_to_run->
        readme[rdm_cnt].status = status, drr_readmes_to_run->readme[rdm_cnt].start_dt_tm =
        start_dt_tm,
        drr_readmes_to_run->readme[rdm_cnt].end_dt_tm = end_dt_tm, drr_readmes_to_run->readme[rdm_cnt
        ].estimated_time = 0, drr_readmes_to_run->readme[rdm_cnt].driver_count = 0
       ENDIF
      FOOT REPORT
       stat = alterlist(drr_readmes_to_run->readme,rdm_cnt), drr_readmes_to_run->readme_cnt = rdm_cnt
      WITH nocounter, outerjoin = d
     ;end select
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag >= 2))
    CALL echorecord(drr_readmes_to_run)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_load_space_chk_readmes(dlscr_execution,dlscr_spcchk_flag)
   DECLARE dlscr_dyn_where = vc WITH protect, noconstant("")
   IF (dlscr_execution="ALL")
    SET dlscr_dyn_where = "r.execution in ('PRESPCHK', 'POSTSPCHK')"
   ELSE
    SET dlscr_dyn_where = concat('r.execution = "',trim(dlscr_execution),'"')
   ENDIF
   SET dm_err->eproc = "Find readmes that require space check."
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_readme r,
     dm_ocd_readme o,
     dm_alpha_features_env a,
     (dummyt d  WITH seq = value(drr_readmes_to_run->readme_cnt))
    PLAN (d
     WHERE (drr_readmes_to_run->readme[d.seq].skip=0))
     JOIN (r
     WHERE (r.parent_readme_id=drr_readmes_to_run->readme[d.seq].readme_id)
      AND parser(dlscr_dyn_where)
      AND r.owner=currdbuser)
     JOIN (o
     WHERE o.readme_id=r.readme_id
      AND o.ocd > 0
      AND o.instance=r.instance)
     JOIN (a
     WHERE a.alpha_feature_nbr=o.ocd
      AND (a.environment_id=dm2_rr_misc->env_id))
    ORDER BY r.readme_id, r.instance DESC, o.ocd DESC
    HEAD r.readme_id
     IF (r.active_ind=1)
      dlscr_spcchk_flag = 1, drr_readmes_to_run->readme[d.seq].spchk_readme_cnt = (drr_readmes_to_run
      ->readme[d.seq].spchk_readme_cnt+ 1), stat = alterlist(drr_readmes_to_run->readme[d.seq].
       spchk_readme,drr_readmes_to_run->readme[d.seq].spchk_readme_cnt),
      drr_readmes_to_run->readme[d.seq].spchk_readme[drr_readmes_to_run->readme[d.seq].
      spchk_readme_cnt].readme_id = r.readme_id, drr_readmes_to_run->readme[d.seq].spchk_readme[
      drr_readmes_to_run->readme[d.seq].spchk_readme_cnt].instance = r.instance, drr_readmes_to_run->
      readme[d.seq].spchk_readme[drr_readmes_to_run->readme[d.seq].spchk_readme_cnt].ocd = o.ocd,
      drr_readmes_to_run->readme[d.seq].spchk_readme[drr_readmes_to_run->readme[d.seq].
      spchk_readme_cnt].execution = r.execution, drr_readmes_to_run->readme[d.seq].spchk_readme[
      drr_readmes_to_run->readme[d.seq].spchk_readme_cnt].script = cnvtupper(r.script),
      drr_readmes_to_run->readme[d.seq].spchk_readme[drr_readmes_to_run->readme[d.seq].
      spchk_readme_cnt].skip = 0
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_load_timing_readmes(null)
   SET dm_err->eproc = "Gathering timing readme data"
   CALL disp_msg("",dm_err->logfile,0)
   SET timer_cnt = 0
   IF ((drr_readmes_to_run->timer_readme_cnt > 0))
    SET drr_readmes_to_run->timer_readme_cnt = 0
    SET stat = alterlist(drr_readmes_to_run->timer_readme,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_ocd_readme o,
     dm_readme r
    PLAN (o
     WHERE (o.ocd=dm2_rr_misc->package_number))
     JOIN (r
     WHERE r.owner=currdbuser
      AND r.readme_id=o.readme_id
      AND r.instance=o.instance
      AND r.execution="RDMTIMER")
    ORDER BY r.readme_id, r.instance DESC, o.ocd DESC
    HEAD REPORT
     row + 0
    HEAD r.readme_id
     IF (r.active_ind=1)
      timer_cnt = (timer_cnt+ 1)
      IF (mod(timer_cnt,10)=1)
       stat = alterlist(drr_readmes_to_run->timer_readme,(timer_cnt+ 9))
      ENDIF
      drr_readmes_to_run->timer_readme[timer_cnt].readme_id = r.readme_id
      IF (r.parent_readme_id > 0)
       drr_readmes_to_run->timer_readme[timer_cnt].parent_readme_id = r.parent_readme_id
      ELSE
       drr_readmes_to_run->timer_readme[timer_cnt].parent_readme_id = 0
      ENDIF
      drr_readmes_to_run->timer_readme[timer_cnt].instance = r.instance, drr_readmes_to_run->
      timer_readme[timer_cnt].ocd = o.ocd, drr_readmes_to_run->timer_readme[timer_cnt].execution = r
      .execution,
      drr_readmes_to_run->timer_readme[timer_cnt].script = cnvtupper(r.script), drr_readmes_to_run->
      timer_readme[timer_cnt].skip = 0
     ENDIF
    FOOT REPORT
     stat = alterlist(drr_readmes_to_run->timer_readme,timer_cnt), drr_readmes_to_run->
     timer_readme_cnt = timer_cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Find highest instance of timing readmes"
   CALL disp_msg("",dm_err->logfile,0)
   IF ((drr_readmes_to_run->timer_readme_cnt=0))
    SET dm_err->eproc = "No Category 8 readmes found to run."
    CALL disp_msg("",dm_err->logfile,0)
    RETURN(1)
   ELSE
    SELECT INTO "nl:"
     FROM dm_readme r,
      dm_ocd_readme o,
      dm_alpha_features_env a,
      (dummyt d  WITH seq = value(drr_readmes_to_run->timer_readme_cnt))
     PLAN (d)
      JOIN (r
      WHERE (r.readme_id=drr_readmes_to_run->timer_readme[d.seq].readme_id)
       AND (r.instance > drr_readmes_to_run->timer_readme[d.seq].instance))
      JOIN (o
      WHERE o.readme_id=r.readme_id
       AND o.ocd > 0
       AND o.instance=r.instance)
      JOIN (a
      WHERE a.alpha_feature_nbr=o.ocd
       AND (a.environment_id=dm2_rr_misc->env_id))
     ORDER BY r.readme_id, r.instance DESC
     HEAD r.readme_id
      IF (r.active_ind=0)
       drr_readmes_to_run->timer_readme[d.seq].skip = 1
      ELSE
       drr_readmes_to_run->timer_readme[d.seq].instance = r.instance, drr_readmes_to_run->
       timer_readme[d.seq].ocd = o.ocd
      ENDIF
     FOOT  r.readme_id
      row + 0
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    SET dm_err->eproc = "Update skip flag on timing readmes"
    CALL disp_msg("",dm_err->logfile,0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(drr_readmes_to_run->timer_readme_cnt)),
      (dummyt d2  WITH seq = value(drr_readmes_to_run->readme_cnt))
     PLAN (d
      WHERE (drr_readmes_to_run->timer_readme[d.seq].parent_readme_id > 0))
      JOIN (d2
      WHERE (drr_readmes_to_run->timer_readme[d.seq].parent_readme_id=drr_readmes_to_run->readme[d2
      .seq].readme_id))
     DETAIL
      drr_readmes_to_run->timer_readme[d.seq].skip = drr_readmes_to_run->readme[d2.seq].skip
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag >= 2))
    CALL echorecord(drr_readmes_to_run)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE drr_alert_killed_appl(daka_load_ind,daka_fmt_appl_id,daka_kill_ind)
   DECLARE daka_audsid = vc WITH protect, noconstant(" ")
   DECLARE daka_audsid_start = i4 WITH protect, noconstant(0)
   DECLARE daka_audsid_end = i4 WITH protect, noconstant(0)
   DECLARE daka_applx = i4 WITH protect, noconstant(0)
   DECLARE daka_info_exists = i4 WITH protect, noconstant(0)
   SET daka_kill_ind = 0
   IF (daka_load_ind=1)
    IF (dm2_table_and_ccldef_exists("DM_INFO",daka_info_exists)=0)
     RETURN(0)
    ELSEIF (daka_info_exists=0)
     RETURN(1)
    ENDIF
    SELECT DISTINCT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="DM2MONPKG_LOGGER"
      AND d.updt_dt_tm BETWEEN cnvtdatetime((curdate - 7),curtime3) AND cnvtdatetime(curdate,curtime3
      )
      AND d.info_char="*AUDSID:*"
     HEAD REPORT
      drr_killed_appl->appl_cnt = 0
     DETAIL
      daka_audsid_start = findstring("AUDSID:",d.info_char,1,0), daka_audsid_end = findstring(",",d
       .info_char,daka_audsid_start,0)
      IF (daka_audsid_end=0)
       daka_audsid = substring(daka_audsid_start,((size(d.info_char)+ 1) - daka_audsid_start),d
        .info_char)
      ELSE
       daka_audsid = substring(daka_audsid_start,(daka_audsid_end - daka_audsid_start),d.info_char)
      ENDIF
      daka_audsid = trim(replace(daka_audsid,"AUDSID:","",0),3)
      IF (isnumeric(daka_audsid))
       drr_killed_appl->appl_cnt += 1
       IF (mod(drr_killed_appl->appl_cnt,10)=1)
        stat = alterlist(drr_killed_appl->appl,(drr_killed_appl->appl_cnt+ 9))
       ENDIF
       drr_killed_appl->appl[drr_killed_appl->appl_cnt].appl_id = daka_audsid
      ENDIF
     FOOT REPORT
      stat = alterlist(drr_killed_appl->appl,drr_killed_appl->appl_cnt)
     WITH nocounter
    ;end select
    IF (check_error("Obtain killed application IDs.")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((drr_killed_appl->appl_cnt > 0))
    SET daka_applx = locateval(daka_applx,1,drr_killed_appl->appl_cnt,daka_fmt_appl_id,
     drr_killed_appl->appl[daka_applx].appl_id)
    IF (daka_applx > 0)
     SET daka_kill_ind = 1
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(drr_killed_appl)
   ENDIF
   RETURN(1)
 END ;Subroutine
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
 IF (check_logfile("dm2_calc_tspace_needs",".log","DM2_CALC_TSPACE_NEEDS LOG FILE")=0)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Begin DM2_CALC_TSPACE_NEEDS"
 CALL disp_msg(" ",dm_err->logfile,0)
 DECLARE est_tblsp_cnt = i4 WITH protect, noconstant(0)
 DECLARE dctn_rts_cnt = i4 WITH protect, noconstant(0)
 DECLARE rtspace_cnt = i4 WITH protect, noconstant(0)
 DECLARE space_need_cnt = i4 WITH protect, noconstant(0)
 DECLARE coal_cnt = i4 WITH protect, noconstant(0)
 DECLARE dm2_new_tspace_ind = i2 WITH protect, noconstant(0)
 DECLARE dctn_new_extra = f8 WITH protect, constant(1048576.0)
 DECLARE space_need_flag = i4 WITH protect, noconstant(0)
 DECLARE dts_install_value = vc WITH protect
 DECLARE dtx_install_type = vc WITH protect
 DECLARE coal_stat = vc WITH protect
 DECLARE dctn_dts_exist = c1 WITH protect
 DECLARE ddd_idx = i4 WITH protect, noconstant(0)
 DECLARE ddd_cnt = i4 WITH protect, noconstant(0)
 DECLARE dctn_chunk_needed = i4 WITH protect, noconstant(0)
 DECLARE dctn_free_chunk = i4 WITH protect, noconstant(0)
 DECLARE dctn_tot_free_chunk = i4 WITH protect, noconstant(0)
 DECLARE dctn_lidx = i4 WITH protect, noconstant(0)
 DECLARE lmt_64k = f8 WITH protect, constant(65536.0)
 DECLARE dctn_load_rtspace(dlr_new_ind=i2) = null WITH protect
 DECLARE dctn_disp_window(null) = null WITH protect
 DECLARE dctn_check_status(null) = i2 WITH protect
 DECLARE dctn_warn_msg(null) = null WITH protect
 DECLARE dctn_noadd(null) = i2 WITH protect
 DECLARE sub_load_rec_to_rtspace(slr_new_ind=i2,srl_tspace=vc,slr_size=f8) = null WITH protect
 DECLARE dctn_load_tspace(null) = i2
 DECLARE sub_load_tgt_to_rtspace(rtsp_seq,rtsp_type,rtsp_tspname) = null
 DECLARE dctn_check_dmt_tspace(null) = i2
 DECLARE dctn_check_new_tspace(null) = i2
 DECLARE set_cur_tspace_rec(sct_otype=c1,sct_tcuridx=i4,sct_icuridx=i4,sct_t=i4,sct_i=i4) = null
 DECLARE dctn_reset_tgtsch(null) = i2
 DECLARE set_tspace_rec(tsp_ind=c1,tbl_seq=i4) = null
 DECLARE sub_set_tsp_chunk_size(stcs_tbl_seq=i4,stcs_tsp_seq=i4) = null
 DECLARE sub_set_rts_chunk_size(stcs_tbl_seq=i4,stcs_tsp_seq=i4) = null
 DECLARE debug_disp_rtspace_tspace_rec(null) = null
 IF ((dm_err->debug_flag > 5))
  CALL echorecord(dtr_tspace_misc)
 ENDIF
 IF ((dtr_tspace_misc->recalc_space_needs=1))
  IF (dctn_reset_tgtsch(null)=0)
   GO TO exit_program
  ENDIF
  SET stat = alterlist(rtspace->qual,0)
  SET rtspace->rtspace_cnt = 0
  SET stat = alterlist(tspace_rec->tsp,0)
  SET tspace_rec->tsp_rec_cnt = 0
  IF (dtr_load_tspaces(dm2_install_schema->process_option)=0)
   GO TO exit_program
  ENDIF
 ENDIF
 IF (dctn_load_tspace(null)=0)
  GO TO exit_program
 ENDIF
 IF (dctn_check_dmt_tspace(null)=0)
  GO TO exit_program
 ENDIF
 IF (dctn_check_new_tspace(null)=0)
  GO TO exit_program
 ENDIF
 IF ((dm_err->debug_flag > 5))
  CALL echorecord(tspace_rec)
 ENDIF
 IF (currdb="ORACLE"
  AND (tspace_rec->tsp_rec_cnt > 0))
  FOR (coal_cnt = 1 TO tspace_rec->tsp_rec_cnt)
    SET coal_stat = concat("rdb alter tablespace ",tspace_rec->tsp[coal_cnt].tsp_name," coalesce go")
    IF (dm2_push_cmd(coal_stat,1)=0)
     GO TO exit_program
    ENDIF
    IF ((ddtsp->nonstd_tgt_ind=1))
     SET space_need_cnt = (space_need_cnt+ 1)
     SET tspace_rec->tsp[coal_cnt].final_bytes_to_add = tspace_rec->tsp[coal_cnt].cur_bytes
    ENDIF
  ENDFOR
  IF ((ddtsp->nonstd_tgt_ind=0))
   SELECT INTO "nl:"
    FROM dm2_dba_free_space db,
     (dummyt dt  WITH seq = value(tspace_rec->tsp_rec_cnt))
    PLAN (dt)
     JOIN (db
     WHERE (db.tablespace_name=tspace_rec->tsp[dt.seq].tsp_name))
    ORDER BY db.tablespace_name
    HEAD db.tablespace_name
     fin_flag = 0, byte_tot = 0, dctn_free_chunk = 0,
     dctn_tot_free_chunk = 0
     IF ((dm_err->debug_flag > 2))
      CALL echo(concat("Working on tablespace - ",db.tablespace_name))
     ENDIF
     dctn_chunk_needed = dm2ceil((tspace_rec->tsp[dt.seq].cur_bytes/ tspace_rec->tsp[dt.seq].
      chunk_size))
     IF ((dm_err->debug_flag > 2))
      CALL echo(build("cur bytes = ",tspace_rec->tsp[dt.seq].cur_bytes)),
      CALL echo(build("chunk size = ",tspace_rec->tsp[dt.seq].chunk_size)),
      CALL echo(build("chunk needed = ",dctn_chunk_needed))
     ENDIF
    DETAIL
     dctn_free_chunk = dm2floor((db.bytes/ tspace_rec->tsp[dt.seq].chunk_size)), dctn_tot_free_chunk
      = (dctn_tot_free_chunk+ dctn_free_chunk)
     IF ((dm_err->debug_flag > 2))
      CALL echo(build("datafile bytes = ",db.bytes)),
      CALL echo(build("chunk size = ",tspace_rec->tsp[dt.seq].chunk_size)),
      CALL echo(build("free chunk = ",dctn_free_chunk)),
      CALL echo(build("tot free chunk = ",dctn_tot_free_chunk))
     ENDIF
    FOOT  db.tablespace_name
     IF (dctn_chunk_needed <= dctn_tot_free_chunk)
      tspace_rec->tsp[dt.seq].final_bytes_to_add = 0
     ELSE
      space_need_cnt = (space_need_cnt+ 1), tspace_rec->tsp[dt.seq].final_bytes_to_add = (((
      dctn_chunk_needed - dctn_tot_free_chunk) * tspace_rec->tsp[dt.seq].chunk_size)+ dctn_new_extra)
     ENDIF
     IF ((dm_err->debug_flag > 2))
      CALL echo(build("final bytes to add = ",tspace_rec->tsp[dt.seq].final_bytes_to_add))
     ENDIF
    WITH nocounter, outerjoin = dt
   ;end select
   IF (check_error("Load dm2_dba_free_space into memory")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
  ENDIF
 ENDIF
 IF ((dm_err->debug_flag > 0))
  CALL echo(build("need cnt  =",space_need_cnt))
 ENDIF
 IF (((space_need_cnt > 0) OR (size(rtspace->qual,5) > 0)) )
  SET dtd_space_needs_ind = 1
  SET dctn_dts_exist = dm2_table_exists("DM2_TSPACE_SIZE")
  CASE (dctn_dts_exist)
   OF "E":
    GO TO exit_program
   OF "N":
    SET dm_err->err_ind = 0
    SET dm_err->eproc = "Table DM2_TSPACE_SIZE not found"
    CALL disp_msg(" ",dm_err->logfile,0)
  ENDCASE
  CALL dctn_load_rtspace(0)
  IF ((dm_err->err_ind=1))
   GO TO exit_program
  ENDIF
  IF (size(rtspace->qual,5)=0)
   SET dm_err->eproc = "There is not table in rTspace"
   CALL disp_msg(" ",dm_err->logfile,0)
   GO TO exit_program
  ENDIF
  IF ( NOT ((dm2_install_schema->process_option IN ("ADMIN CREATE", "NONPROD CREATE")))
   AND dctn_dts_exist="F"
   AND (ddtsp->nonstd_tgt_ind=0))
   IF ((dm2_install_schema->schema_prefix="dm2o"))
    SET dtx_install_type = "PACKAGE"
    SET dts_install_value = dm2_install_schema->file_prefix
   ELSEIF ((dm2_install_schema->schema_prefix="MANUAL"))
    SET dtx_install_type = "MANUAL"
    SET dts_install_value = "MANUAL"
   ELSE
    SET dtx_install_type = "SCHEMA_DATE"
    SET dts_install_value = format(cnvtdate2(dm2_install_schema->file_prefix,"MMDDYYYY"),
     "DD-MMM-YYYY;;D")
   ENDIF
   SET rtspace->install_type = dtx_install_type
   SET rtspace->install_type_value = dts_install_value
   FOR (dts_del_cnt = 1 TO value(size(rtspace->qual,5)))
    DELETE  FROM dm2_tspace_size dt
     WHERE dt.install_type=dtx_install_type
      AND dt.install_type_value=dts_install_value
      AND (dt.tspace_name=rtspace->qual[dts_del_cnt].tspace_name)
     WITH nocounter
    ;end delete
    IF (check_error("Delete from dm2_tspace_size")=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     GO TO exit_program
    ENDIF
   ENDFOR
   INSERT  FROM dm2_tspace_size dt,
     (dummyt r  WITH seq = value(size(rtspace->qual,5)))
    SET dt.bytes_needed = rtspace->qual[r.seq].bytes_needed, dt.new_ind = rtspace->qual[r.seq].
     new_ind, dt.tspace_name = rtspace->qual[r.seq].tspace_name,
     dt.install_type = dtx_install_type, dt.install_type_value = dts_install_value, dt
     .extent_size_bytes =
     IF ((rtspace->qual[r.seq].ext_mgmt="D")) dmt_min_ext_size
     ELSE 0
     ENDIF
     ,
     dt.updt_dt_tm = cnvtdatetime(curdate,curtime), dt.extent_management = rtspace->qual[r.seq].
     ext_mgmt, dt.chunk_size = rtspace->qual[r.seq].chunk_size
    PLAN (r
     WHERE (rtspace->qual[r.seq].bytes_needed > 0))
     JOIN (dt)
    WITH nocounter
   ;end insert
   IF (check_error("Insert into dm2_tspace_size")=1)
    ROLLBACK
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   COMMIT
  ENDIF
 ENDIF
 IF ((dm_err->debug_flag > 0))
  CALL debug_disp_rtspace_tspace_rec(null)
 ENDIF
 SUBROUTINE dctn_reset_tgtsch(null)
   DECLARE drt_cnt = i4 WITH protect, noconstant(0)
   DECLARE drt_ndx = i4 WITH protect, noconstant(0)
   FREE RECORD drt_tspace
   RECORD drt_tspace(
     1 qual[*]
       2 ts_name = vc
   )
   SET dm_err->eproc = "Find existing tablespace for compare in Target Schema"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm2_user_tablespaces u,
     (dummyt d  WITH seq = size(rtspace->qual,5))
    PLAN (d
     WHERE (rtspace->qual[d.seq].new_ind=1))
     JOIN (u
     WHERE (rtspace->qual[d.seq].tspace_name=u.tablespace_name))
    DETAIL
     drt_cnt = (drt_cnt+ 1)
     IF (mod(drt_cnt,10)=1)
      stat = alterlist(drt_tspace->qual,(drt_cnt+ 9))
     ENDIF
     drt_tspace->qual[drt_cnt].ts_name = u.tablespace_name
    FOOT REPORT
     stat = alterlist(drt_tspace->qual,drt_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 5))
    CALL echorecord(drt_tspace)
   ENDIF
   IF (size(drt_tspace->qual,5) > 0)
    FOR (drt_cnt = 1 TO value(tgtsch->tbl_cnt))
      SET drt_ndx = 0
      IF ((tgtsch->tbl[drt_cnt].ttspace_new_ind=1))
       SET drt_ndx = locateval(drt_ndx,1,size(drt_tspace->qual,5),tgtsch->tbl[drt_cnt].tspace_name,
        drt_tspace->qual[drt_ndx].ts_name)
       IF (drt_ndx > 0)
        SET tgtsch->tbl[drt_cnt].ttspace_new_ind = 0
        IF ((dm_err->debug_flag > 0))
         CALL echo(concat("Setting new_ind to zero for Table Tspace:",tgtsch->tbl[drt_cnt].
           tspace_name))
        ENDIF
       ENDIF
      ENDIF
      IF ((tgtsch->tbl[drt_cnt].itspace_new_ind=1))
       SET drt_ndx = locateval(drt_ndx,1,size(drt_tspace->qual,5),tgtsch->tbl[drt_cnt].ind_tspace,
        drt_tspace->qual[drt_ndx].ts_name)
       IF (drt_ndx > 0)
        SET tgtsch->tbl[drt_cnt].itspace_new_ind = 0
        IF ((dm_err->debug_flag > 0))
         CALL echo(concat("Setting new_ind to zero for Index Tspace:",tgtsch->tbl[drt_cnt].ind_tspace
           ))
        ENDIF
       ENDIF
      ENDIF
      IF ((tgtsch->tbl[drt_cnt].ltspace_new_ind=1))
       SET drt_ndx = locateval(drt_ndx,1,size(drt_tspace->qual,5),tgtsch->tbl[drt_cnt].long_tspace,
        drt_tspace->qual[drt_ndx].ts_name)
       IF (drt_ndx > 0)
        SET tgtsch->tbl[drt_cnt].ltspace_new_ind = 0
        IF ((dm_err->debug_flag > 0))
         CALL echo(concat("Setting new_ind to zero for Long Tspace:",tgtsch->tbl[drt_cnt].long_tspace
           ))
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
    IF ((dm_err->debug_flag > 10))
     CALL echorecord(tgtsch)
    ENDIF
   ENDIF
   FREE RECORD drt_tspace
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dctn_load_rtspace(dlr_new_ind)
   DECLARE dlr_idx = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "load the tablespace in temp record structure to rTspace"
   SET rtspace_cnt = size(rtspace->qual,5)
   FOR (dlr_lpcnt = 1 TO tspace_rec->tsp_rec_cnt)
     IF ((tspace_rec->tsp[dlr_lpcnt].final_bytes_to_add > 0))
      SET dlr_idx = 0
      SET dlr_idx = locateval(dlr_idx,1,rtspace_cnt,tspace_rec->tsp[dlr_lpcnt].tsp_name,rtspace->
       qual[dlr_idx].tspace_name)
      IF (dlr_idx=0)
       CALL sub_load_rec_to_rtspace(dlr_new_ind,tspace_rec->tsp[dlr_lpcnt].tsp_name,tspace_rec->tsp[
        dlr_lpcnt].final_bytes_to_add,tspace_rec->tsp[dlr_lpcnt].ext_mgmt,tspace_rec->tsp[dlr_lpcnt].
        chunk_size)
      ELSE
       SET rtspace->qual[dlr_idx].bytes_needed = (rtspace->qual[dlr_idx].bytes_needed+ tspace_rec->
       tsp[dlr_idx].final_bytes_to_add)
       IF ((rtspace->qual[dlr_idx].chunk_size < tspace_rec->tsp[dlr_idx].chunk_size))
        SET rtspace->qual[dlr_idx].chunk_size = tspace_rec->tsp[dlr_idx].chunk_size
       ENDIF
       SET rtspace->qual[dlr_idx].chunks_needed = dm2floor((rtspace->qual[dlr_idx].bytes_needed/
        rtspace->qual[dlr_idx].chunk_size))
      ENDIF
     ENDIF
   ENDFOR
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE sub_load_rec_to_rtspace(slr_new_ind,slr_tspace,slr_size,slr_ext_mgmt,slr_chunk_size)
   SET rtspace_cnt = (rtspace_cnt+ 1)
   SET rtspace->rtspace_cnt = rtspace_cnt
   SET stat = alterlist(rtspace->qual,rtspace_cnt)
   SET rtspace->qual[rtspace_cnt].tspace_name = slr_tspace
   SET rtspace->qual[rtspace_cnt].new_ind = slr_new_ind
   SET rtspace->qual[rtspace_cnt].ext_mgmt = slr_ext_mgmt
   SET rtspace->qual[rtspace_cnt].bytes_needed = slr_size
   SET rtspace->qual[rtspace_cnt].chunk_size = slr_chunk_size
   SET rtspace->qual[rtspace_cnt].chunks_needed = dm2floor((rtspace->qual[rtspace_cnt].bytes_needed/
    rtspace->qual[rtspace_cnt].chunk_size))
 END ;Subroutine
 SUBROUTINE dctn_load_tspace(null)
   DECLARE dlt_inx_num = i4 WITH protect, noconstant(0)
   DECLARE dlt_tsprec_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlt_rtspec = i4 WITH protect, noconstant(0)
   DECLARE dlt_icuridx = i4 WITH protect, noconstant(0)
   DECLARE dlt_tcuridx = i4 WITH protect, noconstant(0)
   DECLARE dlt_t = i4 WITH protect, noconstant(0)
   DECLARE dlt_i = i4 WITH protect, noconstant(0)
   DECLARE dlt_curtbl = i4 WITH protect, noconstant(0)
   DECLARE dlt_curind = i4 WITH protect, noconstant(0)
   DECLARE dlt_tspace_cnt = i4 WITH protect, noconstant(0)
   DECLARE dlt_inx_rtspace_num = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "load existing tspace into record structures"
   IF ((tgtsch->diff_ind > 0))
    FOR (dlt_tsp = 1 TO value(tgtsch->tbl_cnt))
      IF ((((tgtsch->tbl[dlt_tsp].diff_ind=1)) OR ((tgtsch->tbl[dlt_tsp].new_ind=1))) )
       SET dlt_inx_num = 0
       IF ((tgtsch->tbl[dlt_tsp].size > 0))
        IF ((tgtsch->tbl[dlt_tsp].ttspace_new_ind=0))
         SET dlt_inx_num = locateval(dlt_inx_num,1,dlt_tsprec_cnt,tgtsch->tbl[dlt_tsp].tspace_name,
          tspace_rec->tsp[dlt_inx_num].tsp_name)
         IF (dlt_inx_num=0)
          CALL set_tspace_rec("T",dlt_tsp)
         ELSE
          SET tspace_rec->tsp[dlt_inx_num].cur_bytes = (tspace_rec->tsp[dlt_inx_num].cur_bytes+
          tgtsch->tbl[dlt_tsp].size)
          IF ((tspace_rec->tsp[dlt_inx_num].ext_mgmt="D")
           AND (tspace_rec->tsp[dlt_inx_num].chunk_size < tgtsch->tbl[dlt_tsp].next_ext))
           SET tspace_rec->tsp[dlt_inx_num].chunk_size = tgtsch->tbl[dlt_tsp].next_ext
          ENDIF
         ENDIF
        ELSEIF ((tgtsch->tbl[dlt_tsp].ttspace_new_ind=1)
         AND (tgtsch->tbl[dlt_tsp].tspace_name IN ("D_*", "I_*", "L_*")))
         SET dlt_inx_num = locateval(dlt_inx_num,1,dlt_rtspec,tgtsch->tbl[dlt_tsp].tspace_name,
          rtspace->qual[dlt_inx_num].tspace_name)
         IF (dlt_inx_num=0)
          CALL sub_load_tgt_to_rtspace(dlt_tsp,"T","")
         ELSE
          SET rtspace->qual[dlt_inx_num].bytes_needed = (rtspace->qual[dlt_inx_num].bytes_needed+
          tgtsch->tbl[dlt_tsp].size)
          IF ((rtspace->qual[dlt_inx_num].ext_mgmt="D")
           AND (rtspace->qual[dlt_inx_num].chunk_size < tgtsch->tbl[dlt_tsp].next_ext))
           SET rtspace->qual[dlt_inx_num].chunk_size = tgtsch->tbl[dlt_tsp].next_ext
          ENDIF
         ENDIF
        ENDIF
       ENDIF
       SET dlt_inx_num = 0
       IF ((tgtsch->tbl[dlt_tsp].ind_size > 0))
        IF ((tgtsch->tbl[dlt_tsp].itspace_new_ind=0))
         SET dlt_inx_num = locateval(dlt_inx_num,1,dlt_tsprec_cnt,tgtsch->tbl[dlt_tsp].ind_tspace,
          tspace_rec->tsp[dlt_inx_num].tsp_name)
         IF (dlt_inx_num=0)
          CALL set_tspace_rec("I",dlt_tsp)
         ELSE
          SET tspace_rec->tsp[dlt_inx_num].cur_bytes = (tspace_rec->tsp[dlt_inx_num].cur_bytes+
          tgtsch->tbl[dlt_tsp].ind_size)
          CALL sub_set_tsp_chunk_size(dlt_tsp,dlt_inx_num)
         ENDIF
        ELSEIF ((tgtsch->tbl[dlt_tsp].itspace_new_ind=1)
         AND (tgtsch->tbl[dlt_tsp].ind_tspace IN ("D_*", "I_*", "L_*")))
         SET dlt_inx_num = locateval(dlt_inx_num,1,dlt_rtspec,tgtsch->tbl[dlt_tsp].ind_tspace,rtspace
          ->qual[dlt_inx_num].tspace_name)
         IF (dlt_inx_num=0)
          CALL sub_load_tgt_to_rtspace(dlt_tsp,"I","")
         ELSE
          SET rtspace->qual[dlt_inx_num].bytes_needed = (rtspace->qual[dlt_inx_num].bytes_needed+
          tgtsch->tbl[dlt_tsp].ind_size)
          CALL sub_set_rts_chunk_size(dlt_tsp,dlt_inx_num)
         ENDIF
        ENDIF
       ENDIF
       SET dlt_inx_num = 0
       IF ((tgtsch->tbl[dlt_tsp].long_size > 0))
        IF ((tgtsch->tbl[dlt_tsp].ltspace_new_ind=0))
         SET dlt_inx_num = locateval(dlt_inx_num,1,dlt_tsprec_cnt,tgtsch->tbl[dlt_tsp].long_tspace,
          tspace_rec->tsp[dlt_inx_num].tsp_name)
         IF (dlt_inx_num=0)
          CALL set_tspace_rec("L",dlt_tsp)
         ELSE
          SET tspace_rec->tsp[dlt_inx_num].cur_bytes = (tspace_rec->tsp[dlt_inx_num].cur_bytes+
          tgtsch->tbl[dlt_tsp].long_size)
         ENDIF
        ELSEIF ((tgtsch->tbl[dlt_tsp].ltspace_new_ind=1)
         AND (tgtsch->tbl[dlt_tsp].long_tspace IN ("D_*", "I_*", "L_*")))
         SET dlt_inx_num = locateval(dlt_inx_num,1,dlt_rtspec,tgtsch->tbl[dlt_tsp].long_tspace,
          rtspace->qual[dlt_inx_num].tspace_name)
         IF (dlt_inx_num=0)
          CALL sub_load_tgt_to_rtspace(dlt_tsp,"L","")
         ELSE
          SET rtspace->qual[dlt_inx_num].bytes_needed = (rtspace->qual[dlt_inx_num].bytes_needed+
          tgtsch->tbl[dlt_tsp].long_size)
         ENDIF
        ENDIF
       ENDIF
       SET dlt_curtbl = tgtsch->tbl[dlt_tsp].cur_idx
       FOR (dlt_i = 1 TO tgtsch->tbl[dlt_tsp].ind_cnt)
        IF ((tgtsch->tbl[dlt_tsp].ind[dlt_i].build_ind=0)
         AND (tgtsch->tbl[dlt_tsp].ind[dlt_i].size > 0))
         SET dlt_inx_num = 0
         SET dlt_curind = tgtsch->tbl[dlt_tsp].ind[dlt_i].cur_idx
         SET dlt_inx_num = locateval(dlt_inx_num,1,dlt_tsprec_cnt,cur_sch->tbl[dlt_curtbl].ind[
          dlt_curind].tspace_name,tspace_rec->tsp[dlt_inx_num].tsp_name)
         IF (dlt_inx_num=0)
          SET dlt_tsprec_cnt = (dlt_tsprec_cnt+ 1)
          SET tspace_rec->tsp_rec_cnt = dlt_tsprec_cnt
          SET stat = alterlist(tspace_rec->tsp,dlt_tsprec_cnt)
          SET tspace_rec->tsp[dlt_tsprec_cnt].ext_mgmt = cur_sch->tbl[dlt_curtbl].ind[dlt_curind].
          ext_mgmt
          SET tspace_rec->tsp[dlt_tsprec_cnt].tsp_name = cur_sch->tbl[dlt_curtbl].ind[dlt_curind].
          tspace_name
          SET tspace_rec->tsp[dlt_tsprec_cnt].cur_bytes = tgtsch->tbl[dlt_tsp].ind[dlt_i].size
          SET tspace_rec->tsp[dlt_tsprec_cnt].tsp_type = "I"
          SET tspace_rec->tsp[dlt_tsprec_cnt].new_ind = 0
          SET tspace_rec->tsp[dlt_tsprec_cnt].chunk_size = cur_sch->tbl[dlt_curtbl].ind[dlt_curind].
          next_ext
         ELSE
          SET tspace_rec->tsp[dlt_tsprec_cnt].cur_bytes = (tspace_rec->tsp[dlt_tsprec_cnt].cur_bytes
          + tgtsch->tbl[dlt_tsp].ind[dlt_i].size)
          CALL sub_set_tsp_chunk_size(dlt_tsp,dlt_inx_num)
         ENDIF
         IF ((dm_err->debug_flag > 1))
          CALL echo(concat("Load tspace for index not rebuilt =",tgtsch->tbl[dlt_tsp].ind[dlt_i].
            ind_name,"/",cur_sch->tbl[dlt_curtbl].ind[dlt_curind].tspace_name))
          CALL echo(build("index size =",tgtsch->tbl[dlt_tsp].ind[dlt_i].size))
          CALL echo(build("cur_bytes =",tspace_rec->tsp[dlt_tsprec_cnt].cur_bytes))
          CALL echo(build("chunk_size =",tspace_rec->tsp[dlt_tsprec_cnt].chunk_size))
         ENDIF
        ENDIF
        IF ((tgtsch->tbl[dlt_tsp].ind[dlt_i].build_ind=1)
         AND (tgtsch->tbl[dlt_tsp].ind[dlt_i].part_ind=1))
         IF ((tgtsch->tbl[dlt_tsp].ind[dlt_i].part_tsp_cnt > 0))
          FOR (dlt_ptsp_cnt = 1 TO tgtsch->tbl[dlt_tsp].ind[dlt_i].part_tsp_cnt)
           SET dlt_inx_num = 0
           IF (size(tgtsch->tbl[dlt_tsp].ind[dlt_i].part_tsp[dlt_ptsp_cnt].tablespace_name,1) != 0)
            SET dlt_inx_num = locateval(dlt_inx_num,1,ddtsp->tsp_cnt,tgtsch->tbl[dlt_tsp].ind[dlt_i].
             part_tsp[dlt_ptsp_cnt].tablespace_name,ddtsp->qual[dlt_inx_num].tspace_name)
            IF (dlt_inx_num=0)
             SET dlt_inx_rtspace_num = 0
             SET dlt_inx_rtspace_num = locateval(dlt_inx_rtspace_num,1,dlt_rtspec,tgtsch->tbl[dlt_tsp
              ].ind[dlt_i].part_tsp[dlt_ptsp_cnt].tablespace_name,rtspace->qual[dlt_inx_rtspace_num].
              tspace_name)
             IF (dlt_inx_rtspace_num=0)
              CALL sub_load_tgt_to_rtspace(dlt_tsp,"I",tgtsch->tbl[dlt_tsp].ind[dlt_i].part_tsp[
               dlt_ptsp_cnt].tablespace_name)
             ENDIF
            ENDIF
           ENDIF
          ENDFOR
         ENDIF
         IF ((tgtsch->tbl[dlt_tsp].ind[dlt_i].subpart_tsp_cnt > 0))
          FOR (dlt_sptsp_cnt = 1 TO tgtsch->tbl[dlt_tsp].ind[dlt_i].subpart_tsp_cnt)
            IF (size(tgtsch->tbl[dlt_tsp].ind[dlt_i].subpart_tsp[dlt_sptsp_cnt].tablespace_name,1)
             != 0)
             SET dlt_inx_num = 0
             SET dlt_inx_num = locateval(dlt_inx_num,1,ddtsp->tsp_cnt,tgtsch->tbl[dlt_tsp].ind[dlt_i]
              .subpart_tsp[dlt_sptsp_cnt].tablespace_name,ddtsp->qual[dlt_inx_num].tspace_name)
             IF (dlt_inx_num=0)
              SET dlt_inx_rtspace_num = 0
              SET dlt_inx_rtspace_num = locateval(dlt_inx_rtspace_num,1,dlt_rtspec,tgtsch->tbl[
               dlt_tsp].ind[dlt_i].subpart_tsp[dlt_sptsp_cnt].tablespace_name,rtspace->qual[
               dlt_inx_rtspace_num].tspace_name)
              IF (dlt_inx_rtspace_num=0)
               CALL sub_load_tgt_to_rtspace(dlt_tsp,"I",tgtsch->tbl[dlt_tsp].ind[dlt_i].subpart_tsp[
                dlt_sptsp_cnt].tablespace_name)
              ENDIF
             ENDIF
            ENDIF
          ENDFOR
         ENDIF
         IF ((tgtsch->tbl[dlt_tsp].ind[dlt_i].part_cnt > 0))
          FOR (dlt_pcnt = 1 TO tgtsch->tbl[dlt_tsp].ind[dlt_i].part_cnt)
           CALL echo(build("Part[] of tspace",size(tgtsch->tbl[dlt_tsp].ind[dlt_i].part[dlt_pcnt].
              tablespace_name,1)))
           IF (size(tgtsch->tbl[dlt_tsp].ind[dlt_i].part[dlt_pcnt].tablespace_name,1) != 0)
            SET dlt_inx_num = 0
            SET dlt_inx_num = locateval(dlt_inx_num,1,ddtsp->tsp_cnt,tgtsch->tbl[dlt_tsp].ind[dlt_i].
             part[dlt_pcnt].tablespace_name,ddtsp->qual[dlt_inx_num].tspace_name)
            IF (dlt_inx_num=0)
             SET dlt_inx_rtspace_num = 0
             SET dlt_inx_rtspace_num = locateval(dlt_inx_rtspace_num,1,dlt_rtspec,tgtsch->tbl[dlt_tsp
              ].ind[dlt_i].part[dlt_pcnt].tablespace_name,rtspace->qual[dlt_inx_rtspace_num].
              tspace_name)
             IF (dlt_inx_rtspace_num=0)
              CALL sub_load_tgt_to_rtspace(dlt_tsp,"I",tgtsch->tbl[dlt_tsp].ind[dlt_i].part[dlt_pcnt]
               .tablespace_name)
             ENDIF
            ENDIF
           ENDIF
          ENDFOR
         ENDIF
        ENDIF
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
   IF ((dm2_rr_spc_needs->space_needed > 0))
    FOR (dlt_t = 1 TO dm2_rr_spc_needs->tbl_cnt)
      IF ((dm2_rr_spc_needs->tbl[dlt_t].space_needed > 0)
       AND (dm2_rr_spc_needs->tbl[dlt_t].cur_idx > 0))
       SET dlt_tcuridx = dm2_rr_spc_needs->tbl[dlt_t].cur_idx
       SET dlt_inx_num = 0
       SET dlt_inx_num = locateval(dlt_inx_num,1,dlt_tsprec_cnt,cur_sch->tbl[dlt_tcuridx].tspace_name,
        tspace_rec->tsp[dlt_inx_num].tsp_name)
       IF (dlt_inx_num=0)
        CALL set_cur_tspace_rec("T",dlt_tcuridx,0,dlt_t,0)
       ELSE
        SET tspace_rec->tsp[dlt_inx_num].cur_bytes = (tspace_rec->tsp[dlt_inx_num].cur_bytes+
        dm2_rr_spc_needs->tbl[dlt_t].space_needed)
        IF ((tspace_rec->tsp[dlt_inx_num].ext_mgmt="D")
         AND (tspace_rec->tsp[dlt_inx_num].chunk_size < cur_sch->tbl[dlt_tcuridx].next_ext))
         SET tspace_rec->tsp[dlt_inx_num].chunk_size = cur_sch->tbl[dlt_tcuridx].next_ext
        ENDIF
       ENDIF
       FOR (dlt_i = 1 TO dm2_rr_spc_needs->tbl[dlt_t].ind_cnt)
         IF ((dm2_rr_spc_needs->tbl[dlt_t].ind[dlt_i].space_needed > 0)
          AND (dm2_rr_spc_needs->tbl[dlt_t].ind[dlt_i].cur_idx > 0))
          SET dlt_icuridx = dm2_rr_spc_needs->tbl[dlt_t].ind[dlt_i].cur_idx
          SET dlt_inx_num = 0
          SET dlt_inx_num = locateval(dlt_inx_num,1,dlt_tsprec_cnt,cur_sch->tbl[dlt_tcuridx].ind[
           dlt_icuridx].tspace_name,tspace_rec->tsp[dlt_inx_num].tsp_name)
          IF (dlt_inx_num=0)
           CALL set_cur_tspace_rec("I",dlt_tcuridx,dlt_icuridx,dlt_t,dlt_i)
          ELSE
           SET tspace_rec->tsp[dlt_inx_num].cur_bytes = (tspace_rec->tsp[dlt_inx_num].cur_bytes+
           dm2_rr_spc_needs->tbl[dlt_t].ind[dlt_i].space_needed)
           IF ((tspace_rec->tsp[dlt_inx_num].ext_mgmt="D")
            AND (tspace_rec->tsp[dlt_inx_num].chunk_size < cur_sch->tbl[dlt_tcuridx].ind[dlt_icuridx]
           .next_ext))
            SET tspace_rec->tsp[dlt_inx_num].chunk_size = cur_sch->tbl[dlt_tcuridx].ind[dlt_icuridx].
            next_ext
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
   IF ((tgtsch->tspace_cnt > 0))
    FOR (dlt_tspace_cnt = 1 TO tgtsch->tspace_cnt)
      IF ((tgtsch->tspace[dlt_tspace_cnt].new_ind=1))
       CALL sub_load_tgt_to_rtspace(dlt_tspace_cnt,"X","")
      ENDIF
    ENDFOR
   ENDIF
   SET stat = alterlist(tspace_rec->tsp,dlt_tsprec_cnt)
   SET tspace_rec->tsp_rec_cnt = dlt_tsprec_cnt
   SET stat = alterlist(rtspace->qual,dlt_rtspec)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE sub_load_tgt_to_rtspace(rtsp_seq,rtsp_type,rtsp_tspname)
   SET dlt_rtspec = (dlt_rtspec+ 1)
   SET rtspace->rtspace_cnt = dlt_rtspec
   SET stat = alterlist(rtspace->qual,dlt_rtspec)
   IF (rtsp_type="T")
    SET rtspace->qual[dlt_rtspec].tspace_name = tgtsch->tbl[rtsp_seq].tspace_name
    SET rtspace->qual[dlt_rtspec].ext_mgmt = tgtsch->tbl[rtsp_seq].dext_mgmt
    SET rtspace->qual[dlt_rtspec].bytes_needed = tgtsch->tbl[rtsp_seq].size
   ELSEIF (rtsp_type="I")
    SET rtspace->qual[dlt_rtspec].tspace_name = tgtsch->tbl[rtsp_seq].ind_tspace
    SET rtspace->qual[dlt_rtspec].ext_mgmt = tgtsch->tbl[rtsp_seq].iext_mgmt
    SET rtspace->qual[dlt_rtspec].bytes_needed = tgtsch->tbl[rtsp_seq].ind_size
   ELSEIF (rtsp_type="L")
    SET rtspace->qual[dlt_rtspec].tspace_name = tgtsch->tbl[rtsp_seq].long_tspace
    SET rtspace->qual[dlt_rtspec].ext_mgmt = tgtsch->tbl[rtsp_seq].lext_mgmt
    SET rtspace->qual[dlt_rtspec].bytes_needed = tgtsch->tbl[rtsp_seq].long_size
   ELSEIF (rtsp_type="X")
    SET rtspace->qual[dlt_rtspec].tspace_name = tgtsch->tspace[rtsp_seq].tspace_name
    SET rtspace->qual[dlt_rtspec].ext_mgmt = dm2_db_options->new_tspace_type
    SET rtspace->qual[dlt_rtspec].bytes_needed = tgtsch->tspace[rtsp_seq].min_total_bytes
    IF ((dm2_db_options->new_tspace_type="L"))
     SET rtspace->qual[dlt_rtspec].chunk_size = lmt_64k
    ELSEIF ((dm2_db_options->new_tspace_type="D"))
     SET rtspace->qual[dlt_rtspec].chunk_size = dmt_min_ext_size
    ENDIF
    IF ((tgtsch->tspace[rtsp_seq].tspace_type="TEMPORARY"))
     SET rtspace->qual[dlt_rtspec].temp_ind = 1
    ELSE
     SET rtspace->qual[dlt_rtspec].temp_ind = 0
    ENDIF
   ENDIF
   IF (rtsp_type="T")
    SET rtspace->qual[dlt_rtspec].chunk_size = tgtsch->tbl[rtsp_seq].next_ext
   ELSEIF (rtsp_type="I")
    CALL sub_set_rts_chunk_size(rtsp_seq,dlt_rtspec)
   ENDIF
   IF (rtsp_tspname != "")
    SET rtspace->qual[dlt_rtspec].tspace_name = rtsp_tspname
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echo(build("chunck size =",rtspace->qual[dlt_rtspec].chunk_size))
   ENDIF
   SET rtspace->qual[dlt_rtspec].new_ind = 1
 END ;Subroutine
 SUBROUTINE set_tspace_rec(tsp_ind,tbl_seq)
   SET dlt_tsprec_cnt = (dlt_tsprec_cnt+ 1)
   SET tspace_rec->tsp_rec_cnt = dlt_tsprec_cnt
   SET stat = alterlist(tspace_rec->tsp,dlt_tsprec_cnt)
   IF (tsp_ind="T")
    SET tspace_rec->tsp[dlt_tsprec_cnt].tsp_name = tgtsch->tbl[tbl_seq].tspace_name
    SET tspace_rec->tsp[dlt_tsprec_cnt].cur_bytes = (tspace_rec->tsp[dlt_tsprec_cnt].cur_bytes+
    tgtsch->tbl[tbl_seq].size)
    SET tspace_rec->tsp[dlt_tsprec_cnt].ext_mgmt = tgtsch->tbl[tbl_seq].dext_mgmt
   ELSEIF (tsp_ind="I")
    SET tspace_rec->tsp[dlt_tsprec_cnt].ext_mgmt = tgtsch->tbl[tbl_seq].iext_mgmt
    SET tspace_rec->tsp[dlt_tsprec_cnt].tsp_name = tgtsch->tbl[tbl_seq].ind_tspace
    SET tspace_rec->tsp[dlt_tsprec_cnt].cur_bytes = (tspace_rec->tsp[dlt_tsprec_cnt].cur_bytes+
    tgtsch->tbl[tbl_seq].ind_size)
   ELSEIF (tsp_ind="L")
    SET tspace_rec->tsp[dlt_tsprec_cnt].ext_mgmt = tgtsch->tbl[tbl_seq].lext_mgmt
    SET tspace_rec->tsp[dlt_tsprec_cnt].tsp_name = tgtsch->tbl[tbl_seq].long_tspace
    SET tspace_rec->tsp[dlt_tsprec_cnt].cur_bytes = (tspace_rec->tsp[dlt_tsprec_cnt].cur_bytes+
    tgtsch->tbl[tbl_seq].long_size)
   ENDIF
   SET tspace_rec->tsp[dlt_tsprec_cnt].tsp_type = tsp_ind
   SET tspace_rec->tsp[dlt_tsprec_cnt].new_ind = 0
   IF (tsp_ind="T")
    SET tspace_rec->tsp[dlt_tsprec_cnt].chunk_size = tgtsch->tbl[tbl_seq].next_ext
   ELSEIF (tsp_ind="I")
    CALL sub_set_tsp_chunk_size(tbl_seq,dlt_tsprec_cnt)
   ENDIF
 END ;Subroutine
 SUBROUTINE dctn_check_dmt_tspace(null)
   DECLARE dcdt_tsp_cnt = i4 WITH protect, noconstant(0)
   DECLARE dcdt_init_ext = f8 WITH protect, noconstant(0.0)
   DECLARE dcdt_alter_cmd = vc WITH protect, noconstant(" ")
   IF (currdb != "ORACLE")
    RETURN(1)
   ENDIF
   FOR (dcdt_tsp_cnt = 1 TO tspace_rec->tsp_rec_cnt)
     IF ((tspace_rec->tsp[dcdt_tsp_cnt].ext_mgmt="D")
      AND (tspace_rec->tsp[dcdt_tsp_cnt].tsp_name="I_*"))
      SET dm_err->eproc = concat("Retreiving tablespace information for tablespace ",tspace_rec->tsp[
       dcdt_tsp_cnt].tsp_name)
      SET dcdt_init_ext = 0.0
      SELECT INTO "nl:"
       FROM dm2_user_tablespaces u
       WHERE (u.tablespace_name=tspace_rec->tsp[dcdt_tsp_cnt].tsp_name)
       DETAIL
        dcdt_init_ext = u.initial_extent
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ELSEIF (curqual=0)
       SET dm_err->err_ind = 1
       SET dm_err->emsg = "Tablespace information not found"
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      IF (dcdt_init_ext > dmt_min_ext_size)
       SET dm_err->eproc = concat("Altering initial extent size to ",trim(cnvtstring(dmt_min_ext_size
          ))," for tablespace ",tspace_rec->tsp[dcdt_tsp_cnt].tsp_name)
       CALL disp_msg(" ",dm_err->logfile,0)
       SET dcdt_alter_cmd = concat("rdb alter tablespace ",tspace_rec->tsp[dcdt_tsp_cnt].tsp_name,
        " default storage (initial ",trim(cnvtstring(dmt_min_ext_size)),") go")
       IF (dm2_push_cmd(dcdt_alter_cmd,1)=0)
        ROLLBACK
        RETURN(0)
       ELSE
        COMMIT
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dctn_check_new_tspace(null)
   DECLARE dcnt_tsp_cnt = i4 WITH protect, noconstant(0)
   IF (currdb != "ORACLE")
    RETURN(1)
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echo(concat("Looping through new tablespaces in rtspace to check that bytes needed is in ",
      "multiples of chunk size..."))
   ENDIF
   IF ((dm_err->debug_flag > 5))
    CALL echorecord(rtspace)
   ENDIF
   FOR (dcnt_tsp_cnt = 1 TO rtspace->rtspace_cnt)
    IF ((rtspace->qual[dcnt_tsp_cnt].new_ind=1))
     IF ((dm_err->debug_flag > 2))
      CALL echo(concat("Working on new tablespace = ",rtspace->qual[dcnt_tsp_cnt].tspace_name))
      CALL echo(concat("  ext mgmt = ",rtspace->qual[dcnt_tsp_cnt].ext_mgmt))
     ENDIF
     IF ((rtspace->qual[dcnt_tsp_cnt].bytes_needed < rtspace->qual[dcnt_tsp_cnt].chunk_size))
      IF ((dm_err->debug_flag > 2))
       CALL echo(build("  old bytes needed = ",rtspace->qual[dcnt_tsp_cnt].bytes_needed))
       CALL echo(build("  chunk size = ",rtspace->qual[dcnt_tsp_cnt].chunk_size))
      ENDIF
      SET rtspace->qual[dcnt_tsp_cnt].bytes_needed = (rtspace->qual[dcnt_tsp_cnt].chunk_size+
      dctn_new_extra)
      IF ((dm_err->debug_flag > 2))
       CALL echo(build("  new bytes needed = ",rtspace->qual[dcnt_tsp_cnt].bytes_needed))
      ENDIF
     ELSEIF ((rtspace->qual[dcnt_tsp_cnt].bytes_needed > rtspace->qual[dcnt_tsp_cnt].chunk_size))
      IF ((dm_err->debug_flag > 2))
       CALL echo(build("  old bytes needed = ",rtspace->qual[dcnt_tsp_cnt].bytes_needed))
       CALL echo(build("  chunk size = ",rtspace->qual[dcnt_tsp_cnt].chunk_size))
      ENDIF
      SET rtspace->qual[dcnt_tsp_cnt].bytes_needed = ((dm2ceil((rtspace->qual[dcnt_tsp_cnt].
       bytes_needed/ rtspace->qual[dcnt_tsp_cnt].chunk_size)) * rtspace->qual[dcnt_tsp_cnt].
      chunk_size)+ dctn_new_extra)
      IF ((dm_err->debug_flag > 2))
       CALL echo(build("  new bytes needed = ",rtspace->qual[dcnt_tsp_cnt].bytes_needed))
      ENDIF
     ELSE
      IF ((dm_err->debug_flag > 2))
       CALL echo(build("  old bytes needed = ",rtspace->qual[dcnt_tsp_cnt].bytes_needed))
       CALL echo(build("  chunk size = ",rtspace->qual[dcnt_tsp_cnt].chunk_size))
      ENDIF
      SET rtspace->qual[dcnt_tsp_cnt].bytes_needed = (rtspace->qual[dcnt_tsp_cnt].bytes_needed+
      dctn_new_extra)
      IF ((dm_err->debug_flag > 2))
       CALL echo(build("  new bytes needed = ",rtspace->qual[dcnt_tsp_cnt].bytes_needed))
      ENDIF
     ENDIF
    ENDIF
    SET rtspace->qual[dcnt_tsp_cnt].chunks_needed = dm2floor((rtspace->qual[dcnt_tsp_cnt].
     bytes_needed/ rtspace->qual[dcnt_tsp_cnt].chunk_size))
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE debug_disp_rtspace_tspace_rec(null)
   DECLARE ddt_log = vc
   SET dctn_log = build(dm2_install_schema->schema_prefix,dm2_install_schema->file_prefix,
    "_calc_tsp.log")
   SELECT INTO value(dctn_log)
    d.seq
    FROM (dummyt d  WITH seq = value(rtspace->rtspace_cnt))
    HEAD REPORT
     "table count = ", rtspace->rtspace_cnt, row + 1,
     "Current Database = ", currdb, row + 1,
     "rTspace"
    DETAIL
     row + 1, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", row + 1,
     "table number = ", d.seq, row + 1,
     "tablespace_name = ", rtspace->qual[d.seq].tspace_name, row + 1,
     "bytes needed  = ", rtspace->qual[d.seq].bytes_needed, row + 1,
     "tablespace management = ", rtspace->qual[d.seq].ext_mgmt, row + 1,
     "final_bytes_to_add = ", rtspace->qual[d.seq].final_bytes_to_add, row + 1,
     "new_ind = ", rtspace->qual[d.seq].new_ind, row + 1,
     "chunk size=", rtspace->qual[d.seq].chunk_size
    WITH nocounter
   ;end select
   SELECT INTO value(dctn_log)
    d.seq
    FROM (dummyt d  WITH seq = value(tspace_rec->tsp_rec_cnt))
    HEAD REPORT
     row + 1, ";*************************************;", row + 1,
     "table count = ", tspace_rec->tsp_rec_cnt, row + 1,
     "Current Database = ", currdb, row + 1,
     "tspace_rec"
    DETAIL
     row + 1, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", row + 1,
     "table number = ", d.seq, row + 1,
     "tablespace_name = ", tspace_rec->tsp[d.seq].tsp_name, row + 1,
     "tablespace management = ", tspace_rec->tsp[d.seq].ext_mgmt, row + 1,
     "final_bytes_to_add = ", tspace_rec->tsp[d.seq].final_bytes_to_add, row + 1,
     "warn_flag = ", tspace_rec->tsp[d.seq].warn_flag, row + 1,
     "tablespace type = ", tspace_rec->tsp[d.seq].tsp_type, row + 1,
     "chunk size =", tspace_rec->tsp[d.seq].chunk_size
    WITH nocounter, append
   ;end select
   IF ((dir_ui_misc->dm_process_event_id > 0))
    CALL drr_assign_file_to_installs("RPT:CALCTSPACE",dctn_log,dir_ui_misc->dm_process_event_id)
   ENDIF
 END ;Subroutine
 SUBROUTINE sub_set_tsp_chunk_size(stcs_tbl_seq,stcs_tsp_seq)
   FOR (dltlp = 1 TO tgtsch->tbl[stcs_tbl_seq].ind_cnt)
     IF ((tgtsch->tbl[stcs_tbl_seq].ind[dltlp].size > 0))
      IF ((tspace_rec->tsp[stcs_tsp_seq].chunk_size < tgtsch->tbl[stcs_tbl_seq].ind[dltlp].next_ext))
       SET tspace_rec->tsp[stcs_tsp_seq].chunk_size = tgtsch->tbl[stcs_tbl_seq].ind[dltlp].next_ext
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE sub_set_rts_chunk_size(stcs_tbl_seq,stcs_tsp_seq)
   FOR (dltlp = 1 TO tgtsch->tbl[stcs_tbl_seq].ind_cnt)
     IF ((tgtsch->tbl[stcs_tbl_seq].ind[dltlp].build_ind=1))
      IF ((rtspace->qual[stcs_tsp_seq].chunk_size < tgtsch->tbl[stcs_tbl_seq].ind[dltlp].next_ext))
       SET rtspace->qual[stcs_tsp_seq].chunk_size = tgtsch->tbl[stcs_tbl_seq].ind[dltlp].next_ext
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE set_cur_tspace_rec(sct_otype,sct_tcuridx,sct_icuridx,sct_t,sct_i)
   SET dlt_tsprec_cnt = (dlt_tsprec_cnt+ 1)
   SET tspace_rec->tsp_rec_cnt = dlt_tsprec_cnt
   SET stat = alterlist(tspace_rec->tsp,dlt_tsprec_cnt)
   IF (sct_otype="T")
    SET tspace_rec->tsp[dlt_tsprec_cnt].tsp_name = cur_sch->tbl[sct_tcuridx].tspace_name
    SET tspace_rec->tsp[dlt_tsprec_cnt].cur_bytes = (tspace_rec->tsp[dlt_tsprec_cnt].cur_bytes+
    dm2_rr_spc_needs->tbl[sct_t].space_needed)
    SET tspace_rec->tsp[dlt_tsprec_cnt].ext_mgmt = cur_sch->tbl[sct_tcuridx].ext_mgmt
    SET tspace_rec->tsp[dlt_tsprec_cnt].chunk_size = cur_sch->tbl[sct_tcuridx].next_ext
   ELSEIF (sct_otype="I")
    SET tspace_rec->tsp[dlt_tsprec_cnt].ext_mgmt = cur_sch->tbl[sct_tcuridx].ind[sct_icuridx].
    ext_mgmt
    SET tspace_rec->tsp[dlt_tsprec_cnt].tsp_name = cur_sch->tbl[sct_tcuridx].ind[sct_icuridx].
    tspace_name
    SET tspace_rec->tsp[dlt_tsprec_cnt].cur_bytes = (tspace_rec->tsp[dlt_tsprec_cnt].cur_bytes+
    dm2_rr_spc_needs->tbl[sct_t].ind[sct_i].space_needed)
    SET tspace_rec->tsp[dlt_tsprec_cnt].chunk_size = cur_sch->tbl[sct_tcuridx].ind[sct_icuridx].
    next_ext
   ENDIF
   SET tspace_rec->tsp[dlt_tsprec_cnt].tsp_type = sct_otype
   SET tspace_rec->tsp[dlt_tsprec_cnt].new_ind = 0
 END ;Subroutine
#exit_program
 SET message = nowindow
 SET dm_err->eproc = "...end DM2_CALC_TSPACE_NEEDS"
 CALL final_disp_msg("dm2_calc_tspace_needs")
END GO
