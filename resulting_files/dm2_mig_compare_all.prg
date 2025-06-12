CREATE PROGRAM dm2_mig_compare_all
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
 IF ((validate(dm2_compare_rec->tbl_cnt,- (1))=- (1))
  AND (validate(dm2_compare_rec->tbl_cnt,- (2))=- (2)))
  RECORD dm2_compare_rec(
    1 chkpt_1_setup_dt = dq8
    1 chkpt_2_arch_dt = dq8
    1 src_data_link = vc
    1 hrsback = f8
    1 v500_views_ind = i2
    1 max_mm_rows = i4
    1 max_retry_secs = i4
    1 mm_retry_secs = i4
    1 rows_to_sample = i4
    1 restart_compare_ind = i2
    1 tbl_cnt = i4
    1 tab[*]
      2 owner = vc
      2 table_name = vc
      2 compare_table = i2
      2 table_exists_ind = i2
      2 tbl_chkpt_dminfo_dt = dq8
      2 ora_mod_dt = dq8
      2 last_analyzed = dq8
      2 tbl_monitoring = i2
      2 matched_ind = i2
      2 datecol = vc
      2 cmp_dt_tm = dq8
      2 cmp_cnt = i4
      2 object_id = vc
      2 skip_reason = vc
      2 src_view_name = vc
      2 tgt_view_name = vc
      2 cmp_view_name = vc
      2 union_view_name = vc
      2 nkeycol_cnt = i2
      2 nkeycols[*]
        3 column_name = vc
        3 data_type = vc
      2 keycol_cnt = i2
      2 keycols[*]
        3 column_name = vc
        3 data_type = vc
      2 orig_mm_cnt = i4
      2 curr_mm_cnt = i4
      2 mm_rec[*]
        3 recrow_match_ind = i2
        3 reccol[*]
          4 colval_char = vc
          4 colval_num = f8
          4 colval_dt = dq8
      2 chosen_key_column = vc
      2 row_cnt = i4
      2 rows[*]
        3 unique_id = f8
        3 match_ind = i2
      2 match_row_cnt = i4
      2 bottom_ptr = f8
      2 top_ptr = f8
    1 max_row_cnt = i4
    1 total_row_cnt = i4
  )
  SET dm2_compare_rec->src_data_link = "DM2NOTSET"
  SET dm2_compare_rec->hrsback = - (1)
  SET dm2_compare_rec->max_mm_rows = 20
  SET dm2_compare_rec->max_retry_secs = 180
 ENDIF
 DECLARE dcd_num = i4 WITH protect, noconstant(0)
 DECLARE dcd_get_input_data(null) = i2
 DECLARE dcd_validate_datecols(null) = i2
 DECLARE dcd_validate_uniqueidx(notnull_ind=i2) = i2
 DECLARE dcd_generate_mig_views(null) = i2
 DECLARE dcd_validate_prompt(null) = i2
 SUBROUTINE dcd_get_input_data(null)
   DECLARE done = i2 WITH protect, noconstant(0)
   DECLARE dcd_acceptdefault = vc WITH protect, noconstant("M")
   SET width = 132
   SET message = window
   IF ((dm2_compare_rec->src_data_link="DM2NOTSET"))
    DECLARE dcd_dblink = vc WITH protect, noconstant("DM2NOTSET")
    WHILE ( NOT (done))
      CALL clear(1,1)
      CALL box(1,1,5,131)
      CALL text(2,2,"Please provide the database link for the source database:")
      IF (dcd_dblink != "DM2NOTSET")
       CALL text(2,60,dcd_dblink)
      ENDIF
      CALL text(4,2,"(M)odify, (C)ontinue, (Q)uit: ")
      CALL accept(4,33,"A;CU",dcd_acceptdefault
       WHERE curaccept IN ("M", "C", "Q"))
      CASE (curaccept)
       OF "M":
        CALL accept(2,60,"P(15);CU")
        SET dm_err->eproc = "Verifying DB LINK exists"
        SELECT INTO "nl:"
         FROM dba_db_links ddl
         WHERE ddl.db_link=patstring(concat(trim(curaccept),"*"))
        ;end select
        IF (check_error(dm_err->eproc) != 0)
         RETURN(0)
        ENDIF
        IF (curqual=0)
         CALL clear(1,1)
         CALL box(1,1,5,131)
         CALL text(2,2,"The database link given was not found.")
         CALL text(4,2,"(R)etry,(Q)uit: ")
         CALL accept(4,18,"A;cu","R"
          WHERE curaccept IN ("R", "Q"))
         IF (curaccept="Q")
          RETURN(0)
         ENDIF
        ELSE
         SET dcd_dblink = trim(curaccept)
         SET dcd_acceptdefault = "C"
        ENDIF
       OF "C":
        IF (dcd_dblink="DM2NOTSET")
         CALL clear(1,1)
         CALL box(1,1,5,131)
         CALL text(2,2,"You must enter a value for the source database link.")
         CALL text(4,2,"(R)etry,(Q)uit: ")
         CALL accept(4,18,"A;cu","R"
          WHERE curaccept IN ("R", "Q"))
         IF (curaccept="Q")
          RETURN(0)
         ENDIF
        ELSE
         SET dm2_compare_rec->src_data_link = dcd_dblink
         SET done = true
        ENDIF
       OF "Q":
        RETURN(0)
      ENDCASE
    ENDWHILE
   ENDIF
   SET done = false
   SET dcd_acceptdefault = "M"
   IF ((dm2_compare_rec->hrsback=- (1)))
    DECLARE dcd_hrsback = i4 WITH protect, noconstant(- (1))
    WHILE ( NOT (done))
      CALL clear(1,1)
      CALL box(1,1,7,131)
      CALL text(2,2,
       "Please provide the number of hours back the comparison process should look for recently updated data."
       )
      CALL text(4,2,"Hours Back:")
      IF ((dcd_hrsback != - (1)))
       CALL text(4,14,cnvtstring(dcd_hrsback))
      ENDIF
      CALL text(6,2,"(M)odify, (C)ontinue, (Q)uit: ")
      CALL accept(6,33,"A;CU",dcd_acceptdefault
       WHERE curaccept IN ("M", "C", "Q"))
      CASE (curaccept)
       OF "M":
        CALL accept(4,14,"9(4);",1
         WHERE curaccept > 0)
        SET dcd_hrsback = curaccept
        SET dcd_acceptdefault = "C"
       OF "C":
        SET dm2_compare_rec->hrsback = dcd_hrsback
        SET done = true
       OF "Q":
        RETURN(0)
      ENDCASE
    ENDWHILE
   ENDIF
   SET done = false
   SET dcd_acceptdefault = "M"
   IF ((dm2_compare_rec->tbl_cnt=0))
    DECLARE dcd_own_name = vc WITH protect, noconstant("")
    DECLARE dcd_tbl_name = vc WITH protect, noconstant("")
    WHILE ( NOT (done))
      CALL clear(1,1)
      CALL box(1,1,8,131)
      CALL text(2,2,"Please provide the owner and table name that should be compared.")
      CALL text(4,2,"Owner Name:")
      CALL text(4,14,dcd_own_name)
      CALL text(5,2,"Table Name:")
      CALL text(5,14,dcd_tbl_name)
      CALL text(7,2,"(M)odify, (C)ontinue, (Q)uit: ")
      CALL accept(7,33,"A;CU",dcd_acceptdefault
       WHERE curaccept IN ("M", "C", "Q"))
      CASE (curaccept)
       OF "M":
        CALL accept(4,14,"P(20);cu")
        SET dcd_own_name = curaccept
        CALL accept(5,14,"P(20);cu")
        SET dcd_tbl_name = curaccept
        SET dcd_acceptdefault = "C"
       OF "C":
        SET stat = alterlist(dm2_compare_rec->tab,1)
        SET dm2_compare_rec->tbl_cnt = 1
        SET dm2_compare_rec->tab[1].owner = dcd_own_name
        SET dm2_compare_rec->tab[1].table_name = dcd_tbl_name
        SET dm2_compare_rec->tab[1].datecol = "DM2NOTSET"
        SET dm2_compare_rec->tab[1].nkeycol_cnt = - (1)
        SET done = true
       OF "Q":
        RETURN(0)
      ENDCASE
    ENDWHILE
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcd_validate_datecols(null)
   SET width = 132
   SET message = window
   RECORD dcd_datecols(
     1 list[*]
       2 columns = vc
   )
   DECLARE done = i2 WITH protect, noconstant(0)
   DECLARE dcd_acceptdefault = vc WITH protect, noconstant("M")
   FOR (i = 1 TO dm2_compare_rec->tbl_cnt)
     IF ((dm2_compare_rec->tab[i].datecol="DM2NOTSET"))
      SET stat = initrec(dcd_datecols)
      SET dm_err->eproc = concat("Validating Date Columns for ",dm2_compare_rec->tab[i].table_name)
      SELECT INTO "nl:"
       dtc.column_name
       FROM dba_tab_columns dtc
       WHERE (dtc.table_name=dm2_compare_rec->tab[i].table_name)
        AND (dtc.owner=dm2_compare_rec->tab[i].owner)
        AND dtc.data_type="DATE"
        AND  EXISTS (
       (SELECT
        1
        FROM dba_ind_columns dic
        WHERE dic.column_name=dtc.column_name
         AND dic.table_owner=dtc.owner
         AND dic.table_name=dtc.table_name
         AND dic.column_position=1))
       HEAD REPORT
        tmp = 0, cnt = 0
       DETAIL
        cnt = (cnt+ 1)
        IF (cnt > tmp)
         tmp = (tmp+ 10), stat = alterlist(dcd_datecols->list,tmp)
        ENDIF
        dcd_datecols->list[cnt].columns = dtc.column_name
       FOOT REPORT
        stat = alterlist(dcd_datecols->list,cnt)
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc) != 0)
       RETURN(0)
      ENDIF
      IF (curqual=0)
       SET dm2_compare_rec->tab[i].skip_reason = "Indexed date column not specified for table."
      ELSE
       SET done = false
       SET dcd_acceptdefault = "M"
       SET help =
       SELECT
        column = substring(1,30,dcd_datecols->list[d.seq].columns)
        FROM (dummyt d  WITH seq = value(size(dcd_datecols->list,5)))
       ;end select
       DECLARE dcd_datecol = vc WITH protect, noconstant("DM2NOTSET")
       WHILE ( NOT (done))
         CALL clear(1,1)
         CALL box(1,1,7,131)
         CALL text(2,2,concat("Please provide the driver date column for ",dm2_compare_rec->tab[i].
           owner,".",dm2_compare_rec->tab[i].table_name,":"))
         CALL text(4,2,"Column Name:")
         IF (dcd_datecol != "DM2NOTSET")
          CALL text(4,14,dcd_datecol)
         ENDIF
         CALL text(6,2,"(M)odify, (C)ontinue, (Q)uit: ")
         CALL accept(6,33,"A;CU",dcd_acceptdefault
          WHERE curaccept IN ("M", "C", "Q"))
         CASE (curaccept)
          OF "M":
           CALL accept(4,14,"P(30);CF")
           SET dcd_datecol = curaccept
           SET dcd_acceptdefault = "C"
          OF "C":
           SET dm2_compare_rec->tab[i].datecol = dcd_datecol
           SET done = true
          OF "Q":
           RETURN(0)
         ENDCASE
       ENDWHILE
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcd_validate_uniqueidx(notnull_ind)
   RECORD dcd_ind_cols(
     1 col_cnt = i2
     1 columns[*]
       2 col_name = vc
       2 data_type = vc
   )
   SET dm_err->eproc = "Getting Unique Key Columns"
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SELECT
    IF (notnull_ind=1)
     PLAN (d
      WHERE (dm2_compare_rec->tab[d.seq].nkeycol_cnt=- (1)))
      JOIN (dic
      WHERE (dic.table_owner=dm2_compare_rec->tab[d.seq].owner)
       AND (dic.table_name=dm2_compare_rec->tab[d.seq].table_name)
       AND ((dic.index_name IN (
      (SELECT
       di.index_name
       FROM dba_indexes di
       WHERE di.uniqueness="UNIQUE"
        AND (di.owner=dm2_compare_rec->tab[d.seq].owner)
        AND (di.table_name=dm2_compare_rec->tab[d.seq].table_name)
        AND  EXISTS (
       (SELECT
        1
        FROM dba_ind_columns dic2,
         dm2_dba_notnull_cols ddnc
        WHERE dic2.index_name=di.index_name
         AND dic2.index_owner=di.owner
         AND ddnc.column_name=dic2.column_name
         AND ddnc.owner=dic2.table_owner
         AND ddnc.table_name=dic2.table_name))))) OR (dic.column_name="DM2_MIG_SEQ_ID")) )
      JOIN (dtc
      WHERE dtc.table_name=dic.table_name
       AND dtc.column_name=dic.column_name
       AND dtc.owner=dic.table_owner
       AND (dtc.table_name=dm2_compare_rec->tab[d.seq].table_name)
       AND (dtc.owner=dm2_compare_rec->tab[d.seq].owner))
      JOIN (ao
      WHERE ao.object_name=dtc.table_name
       AND ao.object_type="TABLE"
       AND ao.owner=dtc.owner)
    ELSE
     PLAN (d
      WHERE (dm2_compare_rec->tab[d.seq].nkeycol_cnt=- (1)))
      JOIN (dic
      WHERE (dic.table_owner=dm2_compare_rec->tab[d.seq].owner)
       AND (dic.table_name=dm2_compare_rec->tab[d.seq].table_name)
       AND dic.index_name IN (
      (SELECT
       di.index_name
       FROM dba_indexes di
       WHERE di.uniqueness="UNIQUE"
        AND (di.owner=dm2_compare_rec->tab[d.seq].owner)
        AND (di.table_name=dm2_compare_rec->tab[d.seq].table_name))))
      JOIN (dtc
      WHERE dtc.table_name=dic.table_name
       AND dtc.column_name=dic.column_name
       AND dtc.owner=dic.table_owner
       AND (dtc.table_name=dm2_compare_rec->tab[d.seq].table_name)
       AND (dtc.owner=dm2_compare_rec->tab[d.seq].owner))
      JOIN (ao
      WHERE ao.object_name=dtc.table_name
       AND ao.object_type="TABLE"
       AND ao.owner=dtc.owner)
    ENDIF
    INTO "nl:"
    FROM dba_tab_columns dtc,
     dba_ind_columns dic,
     all_objects ao,
     (dummyt d  WITH seq = value(dm2_compare_rec->tbl_cnt))
    ORDER BY dic.table_owner, dic.table_name, dic.index_name DESC,
     dic.column_position
    HEAD dic.table_owner
     row + 0
    HEAD dic.table_name
     dm2_compare_rec->tab[d.seq].keycol_cnt = 9999, dm2_compare_rec->tab[d.seq].object_id =
     cnvtstring(ao.object_id)
    HEAD dic.index_name
     tmp = 0, stat = initrec(dcd_ind_cols)
    DETAIL
     dcd_ind_cols->col_cnt = (dcd_ind_cols->col_cnt+ 1)
     IF ((dcd_ind_cols->col_cnt > tmp))
      tmp = (tmp+ 10), stat = alterlist(dcd_ind_cols->columns,tmp)
     ENDIF
     dcd_ind_cols->columns[dcd_ind_cols->col_cnt].col_name = dic.column_name, dcd_ind_cols->columns[
     dcd_ind_cols->col_cnt].data_type = dtc.data_type
    FOOT  dic.index_name
     IF ((dcd_ind_cols->col_cnt < dm2_compare_rec->tab[d.seq].keycol_cnt))
      stat = alterlist(dm2_compare_rec->tab[d.seq].keycols,dcd_ind_cols->col_cnt), dm2_compare_rec->
      tab[d.seq].keycol_cnt = dcd_ind_cols->col_cnt
      FOR (i = 1 TO dcd_ind_cols->col_cnt)
       dm2_compare_rec->tab[d.seq].keycols[i].column_name = dcd_ind_cols->columns[i].col_name,
       dm2_compare_rec->tab[d.seq].keycols[i].data_type = dcd_ind_cols->columns[i].data_type
      ENDFOR
     ENDIF
    FOOT  dic.table_name
     IF ((dm2_compare_rec->tab[d.seq].keycol_cnt=9999))
      dm2_compare_rec->tab[d.seq].keycol_cnt = 0
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    RETURN(0)
   ENDIF
   FOR (i = 1 TO dm2_compare_rec->tbl_cnt)
     IF ((dm2_compare_rec->tab[i].keycol_cnt=0))
      SET dm2_compare_rec->tab[i].skip_reason = "A valid unique index was not found."
     ENDIF
   ENDFOR
   SET dm_err->eproc = "Populating column list."
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   DECLARE dcd_start = i4 WITH protect, noconstant(1)
   DECLARE dcd_top = i4 WITH protect, noconstant(0)
   SET dcd_top = (ceil((cnvtreal(dm2_compare_rec->tbl_cnt)/ 50)) * 50)
   SET stat = alterlist(dm2_compare_rec->tab,dcd_top)
   FOR (i = (dm2_compare_rec->tbl_cnt+ 1) TO dcd_top)
    SET dm2_compare_rec->tab[i].table_name = dm2_compare_rec->tab[dm2_compare_rec->tbl_cnt].
    table_name
    SET dm2_compare_rec->tab[i].owner = dm2_compare_rec->tab[dm2_compare_rec->tbl_cnt].owner
   ENDFOR
   SELECT INTO "nl:"
    FROM dba_tab_columns dtc,
     (dummyt d  WITH seq = value((dcd_top/ 50)))
    PLAN (d
     WHERE (dm2_compare_rec->tbl_cnt > 0)
      AND assign(dcd_start,evaluate(d.seq,1,1,(dcd_start+ 50))))
     JOIN (dtc
     WHERE expand(dcd_num,dcd_start,(dcd_start+ 49),dtc.table_name,dm2_compare_rec->tab[dcd_num].
      table_name,
      dtc.owner,dm2_compare_rec->tab[dcd_num].owner)
      AND  NOT (dtc.data_type IN ("LONG", "CLOB", "BLOB", "LONG RAW", "RAW")))
    ORDER BY dtc.owner, dtc.table_name
    HEAD dtc.owner
     row + 0
    HEAD dtc.table_name
     tmp = 0, x = locateval(dcd_num,1,dm2_compare_rec->tbl_cnt,dtc.table_name,dm2_compare_rec->tab[
      dcd_num].table_name,
      dtc.owner,dm2_compare_rec->tab[dcd_num].owner), dm2_compare_rec->tab[x].nkeycol_cnt = 0
    DETAIL
     IF (locateval(dcd_num,1,dm2_compare_rec->tab[x].keycol_cnt,dtc.column_name,dm2_compare_rec->tab[
      x].keycols[dcd_num].column_name)=0)
      dm2_compare_rec->tab[x].nkeycol_cnt = (dm2_compare_rec->tab[x].nkeycol_cnt+ 1)
      IF ((dm2_compare_rec->tab[x].nkeycol_cnt > tmp))
       tmp = (tmp+ 10), stat = alterlist(dm2_compare_rec->tab[x].nkeycols,tmp)
      ENDIF
      dm2_compare_rec->tab[x].nkeycols[dm2_compare_rec->tab[x].nkeycol_cnt].column_name = dtc
      .column_name, dm2_compare_rec->tab[x].nkeycols[dm2_compare_rec->tab[x].nkeycol_cnt].data_type
       = dtc.data_type
     ENDIF
    FOOT  dtc.table_name
     stat = alterlist(dm2_compare_rec->tab[x].nkeycols,dm2_compare_rec->tab[x].nkeycol_cnt)
    WITH nocounter
   ;end select
   SET stat = alterlist(dm2_compare_rec->tab,dm2_compare_rec->tbl_cnt)
   IF (check_error(dm_err->eproc) != 0)
    RETURN(0)
   ELSEIF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Error retrieving column info."
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcd_generate_mig_views(null)
   DECLARE dcd_key_columns = vc WITH protect, noconstant("")
   DECLARE dcd_nkey_columns = vc WITH protect, noconstant("")
   DECLARE dcd_null_keys = vc WITH protect, noconstant("")
   DECLARE dcd_null_nkeys = vc WITH protect, noconstant("")
   FOR (i = 1 TO dm2_compare_rec->tbl_cnt)
     IF ((((dm2_compare_rec->tab[i].owner != "V500")) OR ((dm2_compare_rec->v500_views_ind=1)))
      AND (dm2_compare_rec->tab[i].skip_reason=""))
      IF (textlen(dm2_compare_rec->tab[i].object_id) > 13)
       SET dm2_compare_rec->tab[i].skip_reason = "Object_id too long to create view"
      ELSE
       SET dcd_key_columns = dm2_compare_rec->tab[i].keycols[1].column_name
       SET dcd_null_keys = concat("null as ",dm2_compare_rec->tab[i].keycols[1].column_name)
       FOR (j = 2 TO dm2_compare_rec->tab[i].keycol_cnt)
        SET dcd_key_columns = concat(dcd_key_columns,", ",dm2_compare_rec->tab[i].keycols[j].
         column_name)
        SET dcd_null_keys = concat(dcd_null_keys,", null as ",dm2_compare_rec->tab[i].keycols[j].
         column_name)
       ENDFOR
       IF ((dm2_compare_rec->tab[1].nkeycol_cnt > 0))
        SET dcd_nkey_columns = dm2_compare_rec->tab[i].nkeycols[1].column_name
        SET dcd_null_nkeys = concat("null as ",dm2_compare_rec->tab[i].nkeycols[1].column_name)
        FOR (j = 2 TO dm2_compare_rec->tab[i].nkeycol_cnt)
         SET dcd_nkey_columns = concat(dcd_nkey_columns,", ",dm2_compare_rec->tab[i].nkeycols[j].
          column_name)
         SET dcd_null_nkeys = concat(dcd_null_nkeys,", null as ",dm2_compare_rec->tab[i].nkeycols[j].
          column_name)
        ENDFOR
       ENDIF
       SET dm_err->eproc = concat("Creating dm2migc",dm2_compare_rec->tab[i].object_id)
       CALL dm2_push_cmd(concat("rdb asis(^CREATE OR REPLACE VIEW DM2MIGC",dm2_compare_rec->tab[i].
         object_id," AS SELECT ^)"),0)
       CALL dm2_push_cmd(concat("asis(^ ",dcd_key_columns,", ",dcd_nkey_columns,
         ", -1 as dm2migrectype ^)"),0)
       CALL dm2_push_cmd(concat("asis(^FROM ",dm2_compare_rec->tab[i].owner,".",dm2_compare_rec->tab[
         i].table_name,"@",
         dm2_compare_rec->src_data_link," ^)"),0)
       IF ((dm2_compare_rec->tab[i].datecol != ""))
        CALL dm2_push_cmd(concat("asis(^ WHERE ",dm2_compare_rec->tab[i].datecol," >   ^)"),0)
        CALL dm2_push_cmd(concat("asis(^( (SYSDATE - INTERVAL '",trim(cnvtstring(curutcdiff)),
          "' second) - INTERVAL '",trim(cnvtstring(dm2_compare_rec->hrsback)),"' HOUR )^)"),0)
       ENDIF
       CALL dm2_push_cmd("asis(^MINUS^)",0)
       CALL dm2_push_cmd(concat("asis(^SELECT ",dcd_key_columns,", ",dcd_nkey_columns,
         ", -1 as dm2migrectype ^)"),0)
       CALL dm2_push_cmd(concat("asis(^FROM ",dm2_compare_rec->tab[i].owner,".",dm2_compare_rec->tab[
         i].table_name,"^)"),0)
       IF ((dm2_compare_rec->tab[i].datecol != ""))
        CALL dm2_push_cmd(concat("asis(^ WHERE ",dm2_compare_rec->tab[i].datecol," > ^)"),0)
        CALL dm2_push_cmd(concat("asis(^((SYSDATE - INTERVAL '",trim(cnvtstring(curutcdiff)),
          "' second) - INTERVAL '",trim(cnvtstring(dm2_compare_rec->hrsback)),"' HOUR )^)"),0)
       ENDIF
       CALL dm2_push_cmd("asis(^ UNION^)",0)
       CALL dm2_push_cmd(concat("asis(^ select ",dcd_null_keys,", ",dcd_null_nkeys,
         ", count(1) as dm2migrectype ^)"),0)
       CALL dm2_push_cmd(concat("asis(^FROM ",dm2_compare_rec->tab[i].owner,".",dm2_compare_rec->tab[
         i].table_name,"@",
         dm2_compare_rec->src_data_link," ^)"),0)
       IF ((dm2_compare_rec->tab[i].datecol != ""))
        CALL dm2_push_cmd(concat("asis(^WHERE ",dm2_compare_rec->tab[i].datecol," >^)"),0)
        CALL dm2_push_cmd(concat("asis(^ ((SYSDATE - INTERVAL '",trim(cnvtstring(curutcdiff)),
          "' second) - INTERVAL '",trim(cnvtstring(dm2_compare_rec->hrsback)),"' HOUR ) ^) "),0)
       ENDIF
       CALL dm2_push_cmd(asis("go"),1)
       SET dm2_compare_rec->tab[i].cmp_view_name = concat("DM2MIGC",dm2_compare_rec->tab[i].object_id
        )
       IF (check_error(dm_err->eproc) != 0)
        RETURN(0)
       ENDIF
       SET dm_err->eproc = concat("Creating dm2migs",dm2_compare_rec->tab[i].object_id)
       CALL dm2_push_cmd(concat("rdb asis(^CREATE OR REPLACE VIEW DM2MIGS",dm2_compare_rec->tab[i].
         object_id," AS ^)"),0)
       CALL dm2_push_cmd(concat("asis(^ SELECT ",dcd_key_columns,", ",dcd_nkey_columns," FROM ",
         dm2_compare_rec->tab[i].owner,".",dm2_compare_rec->tab[i].table_name,"@",dm2_compare_rec->
         src_data_link,
         "^) go"),1)
       SET dm2_compare_rec->tab[i].src_view_name = concat("DM2MIGS",dm2_compare_rec->tab[i].object_id
        )
       IF (check_error(dm_err->eproc) != 0)
        RETURN(0)
       ENDIF
       SET dm_err->eproc = concat("Creating dm2migt",dm2_compare_rec->tab[i].object_id)
       CALL dm2_push_cmd(concat("rdb asis(^CREATE OR REPLACE VIEW DM2MIGT",dm2_compare_rec->tab[i].
         object_id," AS ^)"),0)
       CALL dm2_push_cmd(concat("asis(^ SELECT ",dcd_key_columns,", ",dcd_nkey_columns," FROM ",
         dm2_compare_rec->tab[i].owner,".",dm2_compare_rec->tab[i].table_name,"^) go"),1)
       SET dm2_compare_rec->tab[i].tgt_view_name = concat("DM2MIGT",dm2_compare_rec->tab[i].object_id
        )
       IF (check_error(dm_err->eproc) != 0)
        RETURN(0)
       ENDIF
       SET dm_err->eproc = concat("Creating dm2migu",dm2_compare_rec->tab[i].object_id)
       CALL dm2_push_cmd(concat("rdb asis(^CREATE OR REPLACE VIEW DM2MIGU",dm2_compare_rec->tab[i].
         object_id," AS ^)"),0)
       CALL dm2_push_cmd(concat("asis(^ SELECT 'SOURCE' AS SOURCE, A.* FROM ",dm2_compare_rec->tab[i]
         .src_view_name," A"," UNION ALL SELECT 'TARGET' AS TARGET, B.* FROM ",dm2_compare_rec->tab[i
         ].tgt_view_name,
         " B^) go"),1)
       SET dm2_compare_rec->tab[i].union_view_name = concat("DM2MIGU",dm2_compare_rec->tab[i].
        object_id)
       IF (check_error(dm_err->eproc) != 0)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   EXECUTE oragen3 "DM2MIG*"
   IF ((dm_err->err_ind != 0))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dcd_validate_prompt(null)
   DECLARE dvp_sample_exists_ind = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Determining if mismatch sample exists from dm_info."
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_MIG_MISMATCH"
    DETAIL
     dvp_sample_exists_ind = 1
    WITH nocounter, maxqual(di,1)
   ;end select
   IF (check_error(dm_err->eproc))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET width = 132
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,24,131)
   CALL text(2,2,"Data Validation")
   IF (dvp_sample_exists_ind)
    CALL text(4,2,"Mismatched row data was found from a previous comparison.")
    CALL text(5,2,"(C)ontinue with previous sample, (R)estart with new sample, or (Q)uit: ")
    CALL accept(5,73,"A;CU","C"
     WHERE curaccept IN ("R", "C", "Q"))
    IF (curaccept="Q")
     SET message = nowindow
     CALL clear(1,1)
     RETURN(0)
    ENDIF
    SET dm2_compare_rec->restart_compare_ind = evaluate(curaccept,"R",1,0)
   ENDIF
   IF (((dm2_compare_rec->restart_compare_ind) OR ( NOT (dvp_sample_exists_ind))) )
    CALL text(7,2,"How many rows would you like to compare?")
    CALL accept(7,43,"99999999;",1000
     WHERE curaccept > 0)
    SET dm2_compare_rec->rows_to_sample = curaccept
   ENDIF
   SET message = nowindow
   CALL clear(1,1)
   RETURN(1)
 END ;Subroutine
 DECLARE dmca_file_name = vc WITH protect, constant("ccluserdir:dm2migcmpall.dat")
 IF (check_logfile("dm2_mig_compare_all",".log","dm2_mig_compare_all_gen LOGFILE")=0)
  GO TO exit_script
 ENDIF
 SET dm_err->eproc = "Checking for dm2migcmpall.dat"
 IF (findfile(dmca_file_name) != 1)
  EXECUTE dm2_mig_compare_all_gen
 ENDIF
 SET dm2_compare_rec->src_data_link = "REF_DATA_LINK"
 SET dm2_compare_rec->hrsback = - (1)
 EXECUTE dm2_compare_data_filelist "ccluserdir:dm2migcmpall.dat"
#exit_script
 IF ((dm_err->err_ind=0))
  SET dm_err->eproc = "Dm2_mig_compare_all completed successfully."
 ELSE
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
 ENDIF
 CALL final_disp_msg("dm2_mig_compare_all")
END GO
