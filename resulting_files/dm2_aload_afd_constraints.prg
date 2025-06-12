CREATE PROGRAM dm2_aload_afd_constraints
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
 DECLARE dac_get_pkgdir(dgp_pkg=i4,dgp_pkg_loc=vc(ref)) = i2
 DECLARE dac_chk_batchover(dcb_batchcnt=i4(ref)) = i2
 DECLARE dac_pop_coldic_rec(dpcr_tab_in=vc) = i2
 DECLARE dac_prelim(dp_pkg=i4,dp_loc_ret=vc(ref),dp_batch_ret=i4(ref)) = i2
 DECLARE load_package_schema_csv(lpsc_eid=f8,lpsc_pkg_int=i4) = i2
 DECLARE determine_admin_load_method(dalm_pkg_in=i4,dalm_meth_out=i2(ref)) = i2
 DECLARE dac_parse_load_data_csv(pldc_pkg_in=f8,pldc_load_all_ind=i2) = i2
 DECLARE dac_load_cload(lc_pkg_in=f8) = i2
 DECLARE dac_aload_method_override_val = vc WITH protect, noconstant("NOT SET")
 DECLARE dac_aload_csv_file_loc = vc WITH protect, noconstant("")
 DECLARE ic_cnt = i4 WITH protect, noconstant(0)
 DECLARE init_csvcontentrow(ic_init_value=vc) = i2
 IF (validate(dac_ocd_txt_data->pkg,- (1)) < 0)
  FREE RECORD dac_ocd_txt_data
  RECORD dac_ocd_txt_data(
    1 pkg = i4
    1 file = vc
    1 archive_date = dq8
    1 type[*]
      2 name = vc
      2 rows = i4
  )
  SET dac_ocd_txt_data->file = "DM2NOTSET"
  SET dac_ocd_txt_data->pkg = 0
  SET dac_ocd_txt_data->archive_date = 0
 ENDIF
 IF (validate(dac_col_list->tbl,"-x")="-x"
  AND validate(dac_col_list->tbl,"-y")="-y")
  FREE RECORD dac_col_list
  RECORD dac_col_list(
    1 tbl = vc
    1 col[*]
      2 col_name = vc
      2 col_type = vc
  )
 ENDIF
 IF ((validate(csvcontent->csv_txt_version,- (1))=- (1))
  AND (validate(csvcontent->csv_txt_version,- (2))=- (2)))
  FREE RECORD csvcontent
  RECORD csvcontent(
    1 csv_txt_version = i4
    1 csv_packaging_field_cnt = i4
    1 csv_installation_field_cnt = i4
    1 prev_sch_inst_on_pkg = i4
    1 qual[*]
      2 table_name = vc
      2 filename = vc
      2 fileversion = vc
      2 loadscript = vc
      2 row_count = vc
      2 passive_ind = vc
      2 owner = vc
  )
 ENDIF
 SUBROUTINE init_csvcontentrow(ic_init_value)
   SET ic_cnt = 0
   SET ic_cnt = (size(csvcontent->qual,5)+ 1)
   SET stat = alterlist(csvcontent->qual,ic_cnt)
   SET csvcontent->qual[ic_cnt].table_name = ic_init_value
   SET csvcontent->qual[ic_cnt].filename = ic_init_value
   SET csvcontent->qual[ic_cnt].fileversion = ic_init_value
   SET csvcontent->qual[ic_cnt].loadscript = ic_init_value
   SET csvcontent->qual[ic_cnt].row_count = ic_init_value
   SET csvcontent->qual[ic_cnt].passive_ind = ic_init_value
   SET csvcontent->qual[ic_cnt].owner = ic_init_value
 END ;Subroutine
 SUBROUTINE dac_pop_coldic_rec(dpcr_tab_in)
   DECLARE dpcr_cnt = i4 WITH protect, noconstant(0)
   DECLARE dpcr_idx = i4 WITH protect, noconstant(0)
   DECLARE dcpr_col_oradef_ind = i2 WITH protect, noconstant(0)
   DECLARE dcpr_col_ccldef_ind = i2 WITH protect, noconstant(0)
   DECLARE dpcr_data_type = vc WITH protect, noconstant("")
   SET stat = alterlist(dac_col_list->col,0)
   SET dac_col_list->tbl = ""
   SET dac_col_list->tbl = cnvtupper(dpcr_tab_in)
   SET dm_err->eproc = concat("Get list of columns in dictionary for ",dac_col_list->tbl)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   FOR (dpcr_idx = 1 TO size(columns_1->list_1,5))
     SET dcpr_col_oradef_ind = 0
     SET dcpr_col_ccldef_ind = 0
     SET dpcr_data_type = ""
     IF (dm2_table_column_exists("",dac_col_list->tbl,columns_1->list_1[dpcr_idx].field_name,0,1,
      2,dcpr_col_oradef_ind,dcpr_col_ccldef_ind,dpcr_data_type)=0)
      RETURN(0)
     ENDIF
     IF (dcpr_col_ccldef_ind=1)
      SET dpcr_cnt = (dpcr_cnt+ 1)
      SET stat = alterlist(dac_col_list->col,dpcr_cnt)
      SET dac_col_list->col[dpcr_cnt].col_name = columns_1->list_1[dpcr_idx].field_name
      SET dac_col_list->col[dpcr_cnt].col_type = substring(1,1,dpcr_data_type)
     ENDIF
   ENDFOR
   IF (size(dac_col_list->col,5)=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("No rows identified according to dictionary for ",dac_col_list->tbl)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dac_col_list)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dac_chk_batchover(dcb_batchcnt)
   DECLARE dcb_batch_qual = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_ALOAD"
     AND d.info_name="BATCH_SIZE"
    DETAIL
     dcb_batch_qual = d.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(dcb_batch_qual)
   ENDIF
   SET dcb_batchcnt = dcb_batch_qual
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dac_get_pkgdir(dgp_pkg,dgp_pkg_loc)
   DECLARE dgp_text = vc WITH protect, noconstant("")
   DECLARE dgp_num = i4 WITH protect, noconstant(0)
   SET dgp_text = cnvtlower(trim(logical("cer_ocd"),3))
   IF (cursys="AXP")
    SET dgp_num = findstring("]",dgp_text)
    IF (dgp_num > 0)
     SET dgp_text = substring(1,(dgp_num - 1),dgp_text)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(dgp_num)
    CALL echo(dgp_text)
   ENDIF
   IF (cursys="AIX")
    SET dgp_pkg_loc = concat(dgp_text,"/",trim(format(dgp_pkg,"######;P0"),3),"/")
   ELSEIF (cursys="WIN")
    SET dgp_pkg_loc = concat(dgp_text,"\",trim(format(dgp_pkg,"######;P0"),3),"\")
   ELSE
    SET dgp_pkg_loc = concat(dgp_text,trim(format(dgp_pkg,"######;P0"),3),"]")
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dac_prelim(dp_pkg,dp_loc_ret,dp_batch_ret)
   DECLARE dp_loc_hold = vc WITH protect, noconstant("")
   DECLARE dp_batch_hold = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Get pkg directory."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (dac_get_pkgdir(dp_pkg,dp_loc_hold)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Check if batch cnt should be overwritten"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF (dac_chk_batchover(dp_batch_hold)=0)
    RETURN(0)
   ENDIF
   SET dp_loc_ret = dp_loc_hold
   SET dp_batch_ret = dp_batch_hold
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dac_build_col_list(null)
  DECLARE dbcl_cnt = i4 WITH protect, noconstant(0)
  FOR (dbcl_cnt = 1 TO size(dac_col_list->col,5))
   CASE (dac_col_list->col[dbcl_cnt].col_type)
    OF "C":
     CALL dm2_push_cmd(concat("dcv.",dac_col_list->col[dbcl_cnt].col_name," = ",
       "evaluate(requestin->list_0[d.seq].",dac_col_list->col[dbcl_cnt].col_name,
       ",'::DM2NULLVALUE::',","null, requestin->list_0[d.seq].",dac_col_list->col[dbcl_cnt].col_name,
       ")"),0)
    OF "Q":
     CALL dm2_push_cmd(concat("dcv.",dac_col_list->col[dbcl_cnt].col_name," = ",
       "evaluate(requestin->list_0[d.seq].",dac_col_list->col[dbcl_cnt].col_name,
       ",'::DM2NULLVALUE::',","null, cnvtdatetime(requestin->list_0[d.seq].",dac_col_list->col[
       dbcl_cnt].col_name,"))"),0)
    OF "I":
     CALL dm2_push_cmd(concat("dcv.",dac_col_list->col[dbcl_cnt].col_name," = ",
       "evaluate(requestin->list_0[d.seq].",dac_col_list->col[dbcl_cnt].col_name,
       ",'::DM2NULLVALUE::',","null, cnvtint(requestin->list_0[d.seq].",dac_col_list->col[dbcl_cnt].
       col_name,"))"),0)
    OF "F":
     CALL dm2_push_cmd(concat("dcv.",dac_col_list->col[dbcl_cnt].col_name," = ",
       "evaluate(requestin->list_0[d.seq].",dac_col_list->col[dbcl_cnt].col_name,
       ",'::DM2NULLVALUE::',","null, cnvtreal(requestin->list_0[d.seq].",dac_col_list->col[dbcl_cnt].
       col_name,"))"),0)
    ELSE
     SET dm_err->err_ind = 1
     SET dm_err->emsg = concat("Column Name:",dac_col_list->col[dbcl_cnt].col_name,". Data_Type:",
      dac_col_list->col[dbcl_cnt].col_type," is not recognizable by load script.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
   ENDCASE
   IF (dbcl_cnt != size(dac_col_list->col,5))
    CALL dm2_push_cmd(",",0)
   ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE load_package_schema_csv(lpsc_eid,lpsc_pkg_int)
   DECLARE lpsc_cnt = i4 WITH protect, noconstant(0)
   DECLARE lpsc_script_call = vc WITH protect, noconstant("")
   DECLARE lpsc_script_log_op = vc WITH protect, noconstant("")
   SET dip_ccl_load_ind = 1
   SET ocd_op->cur_op = olo_load_ccl_file
   SET ocd_op->pre_op = olo_none
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc = "Entering LOAD_PACKAGE_SCHEMA_CSV."
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   CALL start_status(dm_err->eproc,lpsc_eid,lpsc_pkg_int)
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF (log_package_op(ocd_op->cur_op,ols_running,dm_err->eproc,lpsc_eid,lpsc_pkg_int)=0)
    RETURN(0)
   ENDIF
   FOR (lpsc_cnt = 1 TO size(csvcontent->qual,5))
     IF (((cnvtupper(csvcontent->qual[lpsc_cnt].owner)=currdbuser) OR (cnvtupper(csvcontent->qual[
      lpsc_cnt].owner)="ALL")) )
      SET lpsc_script_log_op = concat("Load Script:",csvcontent->qual[lpsc_cnt].loadscript," OCD:",
       trim(cnvtstring(lpsc_pkg_int)))
      IF (findfile(concat(dac_aload_csv_file_loc,csvcontent->qual[lpsc_cnt].filename))=0)
       DELETE  FROM dm_ocd_log d
        WHERE d.environment_id=lpsc_eid
         AND d.project_type="INSTALL LOG"
         AND d.ocd=lpsc_pkg_int
        WITH nocounter
       ;end delete
       COMMIT
       SET dm_err->eproc = concat("Installation Failed. Package schema CSV file ",
        dac_aload_csv_file_loc,csvcontent->qual[lpsc_cnt].filename," not found in CER_OCD.")
       CALL log_package_op(ocd_op->cur_op,ols_error,dm_err->eproc,lpsc_eid,lpsc_pkg_int)
       CALL end_status(dm_err->eproc,lpsc_eid,lpsc_pkg_int)
       SET dm_err->err_ind = 1
       RETURN(0)
      ENDIF
      IF (checkprg(csvcontent->qual[lpsc_cnt].loadscript)=0)
       DELETE  FROM dm_ocd_log d
        WHERE d.environment_id=lpsc_eid
         AND d.project_type="INSTALL LOG"
         AND d.ocd=lpsc_pkg_int
        WITH nocounter
       ;end delete
       COMMIT
       SET dm_err->eproc = concat("Installation Failed. Executable script ",csvcontent->qual[lpsc_cnt
        ].loadscript," not found in dictionary.")
       CALL log_package_op(ocd_op->cur_op,ols_error,dm_err->eproc,lpsc_eid,lpsc_pkg_int)
       CALL end_status(dm_err->eproc,lpsc_eid,lpsc_pkg_int)
       SET dm_err->err_ind = 1
       RETURN(0)
      ENDIF
      IF ((csvcontent->qual[lpsc_cnt].loadscript IN ("DM2_ALOAD_DM_FLAGS",
      "DM2_ALOAD_OCD_README_COMP")))
       SET lpsc_script_call = concat(" execute ",csvcontent->qual[lpsc_cnt].loadscript," ",build(
         lpsc_pkg_int),',"',
        csvcontent->qual[lpsc_cnt].filename,'",',csvcontent->qual[lpsc_cnt].passive_ind,",",
        csvcontent->qual[lpsc_cnt].row_count,
        " go")
      ELSE
       SET lpsc_script_call = concat(" execute ",csvcontent->qual[lpsc_cnt].loadscript," ",build(
         lpsc_pkg_int),',"',
        csvcontent->qual[lpsc_cnt].filename,'",',csvcontent->qual[lpsc_cnt].row_count," go")
      ENDIF
      SET dm_err->eproc = concat("EXECUTING LOAD SCRIPT:",lpsc_script_call)
      CALL log_package_op(lpsc_script_log_op,ols_start,dm_err->eproc,lpsc_eid,lpsc_pkg_int)
      CALL dm2_push_cmd(lpsc_script_call,1)
      IF ((dm_err->err_ind=1))
       CALL log_package_op(ocd_op->cur_op,ols_error,dm_err->eproc,lpsc_eid,lpsc_pkg_int)
       CALL log_package_op(lpsc_script_log_op,ols_error,dm_err->eproc,lpsc_eid,lpsc_pkg_int)
       CALL end_status(dm_err->eproc,lpsc_eid,lpsc_pkg_int)
       RETURN(0)
      ENDIF
      CALL log_package_op(lpsc_script_log_op,ols_complete,lpsc_script_call,lpsc_eid,lpsc_pkg_int)
     ENDIF
   ENDFOR
   SET dm_err->eproc = "Operation Successful. CSV Load Scripts included successfully."
   IF (log_package_op(ocd_op->cur_op,ols_complete,dm_err->eproc,lpsc_eid,lpsc_pkg_int)=0)
    RETURN(0)
   ENDIF
   CALL end_status(dm_err->eproc,lpsc_eid,lpsc_pkg_int)
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    SET dm_err->eproc = "Leaving LOAD_PACKAGE_SCHEMA_CSV."
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE determine_admin_load_method(dalm_pkg_in,dalm_meth_out)
   IF (dac_aload_method_override_val="NOT SET")
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain="DM2_INSTALL_PKG"
      AND d.info_name="ADMIN_LOAD_METHOD"
     DETAIL
      dac_aload_method_override_val = d.info_char
     WITH nocounter
    ;end select
    IF (check_error("Determining admin load method.")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
    IF (dac_aload_method_override_val="0"
     AND currdbuser != "V500")
     SET dm_err->eproc = concat("Evaluating admin load method override for current database user ",
      currdbuser)
     SET dm_err->emsg = concat("Cannot force use of .ccl file for current database user.")
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dac_aload_method_override_val="0")
    SET dalm_meth_out = 0
    RETURN(1)
   ENDIF
   IF (dac_parse_load_data_csv(dalm_pkg_in,1)=0)
    RETURN(0)
   ENDIF
   IF ((csvcontent->csv_txt_version >= 1))
    SET dalm_meth_out = 1
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dac_parse_load_data_csv(pldc_pkg_in,pldc_load_all_ind)
   DECLARE pldc_txt_file = vc WITH protect, noconstant("")
   DECLARE pldc_txt = vc WITH protect, noconstant("")
   DECLARE pldc_num1 = i4 WITH protect, noconstant(0)
   DECLARE pldc_num2 = i4 WITH protect, noconstant(0)
   DECLARE pldc_cnt = i4 WITH protect, noconstant(0)
   DECLARE pldc_abs_end = i4 WITH protect, noconstant(0)
   DECLARE pldc_rep_cnt = i4 WITH protect, noconstant(0)
   DECLARE pldc_line = vc WITH protect, noconstant("")
   DECLARE pldc_str = vc WITH protect, noconstant("")
   SET pldc_txt = cnvtlower(trim(logical("cer_ocd"),3))
   SET pldc_num1 = findstring("]",pldc_txt)
   IF (pldc_num1 > 0)
    SET pldc_txt = substring(1,(pldc_num1 - 1),pldc_txt)
   ENDIF
   IF ((dm2_sys_misc->cur_os="AXP"))
    SET pldc_txt_file = concat(pldc_txt,trim(format(pldc_pkg_in,"######;P0"),3),"]")
   ELSEIF ((dm2_sys_misc->cur_os="WIN"))
    SET pldc_txt_file = concat(pldc_txt,"\",trim(format(pldc_pkg_in,"######;P0"),3),"\")
   ELSE
    SET pldc_txt_file = concat(pldc_txt,"/",trim(format(pldc_pkg_in,"######;P0"),3),"/")
   ENDIF
   SET dac_aload_csv_file_loc = pldc_txt_file
   SET pldc_txt_file = concat(pldc_txt_file,"ocd_schema_",trim(cnvtstring(pldc_pkg_in),3),".txt")
   SET dm_err->eproc = concat("Check for existence of ",pldc_txt_file)
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   IF ( NOT (findfile(pldc_txt_file)))
    SET dm_err->emsg = concat(pldc_txt_file," not found. Unable to open.")
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET stat = alterlist(csvcontent->qual,0)
   SET csvcontent->csv_txt_version = 0
   SET csvcontent->csv_packaging_field_cnt = 0
   SET csvcontent->csv_installation_field_cnt = 7
   FREE DEFINE rtl2
   SET logical pldc_file value(pldc_txt_file)
   DEFINE rtl2 "pldc_file"
   SET dm_err->eproc = "Read the .TXT file for CsvContent."
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    DETAIL
     pldc_num2 = 0, pldc_num1 = 0, pldc_line = trim(check(r.line," "))
     IF (findstring("$ALOAD$DM2ALOADVERSION,",pldc_line) > 0)
      pldc_num1 = (findstring(",",pldc_line)+ 1), csvcontent->csv_txt_version = cnvtint(substring(
        pldc_num1,(textlen(pldc_line) - (pldc_num1 - 1)),pldc_line))
     ELSEIF (findstring("$ALOAD$DM2ALOADFIELDCNT,",pldc_line) > 0)
      pldc_num1 = (findstring(",",pldc_line)+ 1), csvcontent->csv_packaging_field_cnt = cnvtint(
       substring(pldc_num1,(textlen(pldc_line) - (pldc_num1 - 1)),pldc_line))
     ELSEIF (((((findstring("$ALOAD$",pldc_line) > 0) OR (((findstring("$ALOAD2$",pldc_line) > 0) OR
     (((findstring("$ALOAD3$",pldc_line) > 0) OR (findstring("$ALOAD4$",pldc_line) > 0)) )) ))
      AND pldc_load_all_ind=1) OR (((findstring("$CLOAD$",pldc_line) > 0) OR (findstring(
      "$ALOAD$DM_TABLE_RELATIONSHIPS",pldc_line) > 0)) )) )
      CALL init_csvcontentrow("DM2PNOTSET"), pldc_cnt = size(csvcontent->qual,5), pldc_rep_cnt = 0,
      pldc_num1 = 0, pldc_abs_end = least(csvcontent->csv_installation_field_cnt,csvcontent->
       csv_packaging_field_cnt)
      IF (findstring("$ALOAD$",pldc_line) > 0)
       pldc_num2 = (findstring("$ALOAD$",pldc_line)+ 6)
      ELSEIF (findstring("$ALOAD2$",pldc_line) > 0)
       pldc_num2 = (findstring("$ALOAD2$",pldc_line)+ 7)
      ELSEIF (findstring("$ALOAD3$",pldc_line) > 0)
       pldc_num2 = (findstring("$ALOAD3$",pldc_line)+ 7)
      ELSEIF (findstring("$CLOAD$",pldc_line) > 0)
       pldc_num2 = (findstring("$CLOAD$",pldc_line)+ 6)
      ELSEIF (findstring("$ALOAD4$",pldc_line) > 0)
       pldc_num2 = (findstring("$ALOAD4$",pldc_line)+ 7)
      ENDIF
      WHILE (pldc_rep_cnt < pldc_abs_end)
        pldc_rep_cnt = (pldc_rep_cnt+ 1), pldc_num1 = pldc_num2, pldc_num2 = findstring(",",pldc_line,
         (pldc_num1+ 1),0)
        IF (pldc_num2=0)
         pldc_str = substring((pldc_num1+ 1),(textlen(pldc_line) - pldc_num1),pldc_line)
        ELSE
         pldc_str = substring((pldc_num1+ 1),((pldc_num2 - pldc_num1) - 1),pldc_line)
        ENDIF
        IF ((dm_err->debug_flag > 0))
         CALL echo("*****"),
         CALL echo(pldc_line),
         CALL echo(pldc_str),
         CALL echo(pldc_num1),
         CALL echo(pldc_num2),
         CALL echo(pldc_abs_end)
        ENDIF
        CASE (pldc_rep_cnt)
         OF 1:
          csvcontent->qual[pldc_cnt].table_name = pldc_str
         OF 2:
          csvcontent->qual[pldc_cnt].filename = pldc_str
         OF 3:
          csvcontent->qual[pldc_cnt].fileversion = pldc_str
         OF 4:
          csvcontent->qual[pldc_cnt].loadscript = pldc_str
         OF 5:
          csvcontent->qual[pldc_cnt].row_count = pldc_str
         OF 6:
          csvcontent->qual[pldc_cnt].passive_ind = pldc_str
         OF 7:
          csvcontent->qual[pldc_cnt].owner = cnvtupper(pldc_str)
        ENDCASE
      ENDWHILE
      IF ((csvcontent->qual[pldc_cnt].owner="DM2PNOTSET"))
       csvcontent->qual[pldc_cnt].owner = "V500"
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error("Parsing .txt file for CSVCONTENT.")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echorecord(csvcontent)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dac_load_cload(lc_pkg_in)
   IF (dac_parse_load_data_csv(lc_pkg_in,0)=0)
    RETURN(0)
   ENDIF
 END ;Subroutine
 IF (check_logfile("dm2_aload_cons",".log","dm2_aload_afd_constraints")=0)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Starting dm2_aload_afd_constraints"
 CALL disp_msg(" ",dm_err->logfile,0)
 DECLARE daac_pkg = i4 WITH protect, noconstant( $1)
 DECLARE daac_file = vc WITH protect, noconstant( $2)
 DECLARE daac_expected_rows = i4 WITH protect, noconstant( $3)
 DECLARE daac_batch = i4 WITH protect, noconstant(0)
 DECLARE daac_file_loc_ret = vc WITH protect, noconstant("")
 IF (dac_prelim(daac_pkg,daac_file_loc_ret,daac_batch)=0)
  GO TO exit_program
 ENDIF
 IF (daac_batch=0)
  SET daac_batch = 5000
 ENDIF
 IF (daac_expected_rows > 0)
  EXECUTE dm2_dbimport concat(daac_file_loc_ret,daac_file), "dm2_aload_sch_cons", daac_batch
  CALL echo(concat(daac_file_loc_ret,daac_file))
 ENDIF
 IF ((dm_err->err_ind=0))
  SET dm_err->eproc = "Remove extraneous DM_AFD_CONSTRAINTS rows"
  IF ((dm_err->debug_flag > 0))
   CALL disp_msg(" ",dm_err->logfile,0)
  ENDIF
  DELETE  FROM dm_afd_constraints a
   WHERE a.alpha_feature_nbr=daac_pkg
    AND a.owner=currdbuser
    AND  NOT ( EXISTS (
   (SELECT
    "x"
    FROM dm_afd_tables b
    WHERE b.owner=a.owner
     AND b.alpha_feature_nbr=a.alpha_feature_nbr
     AND b.table_name=a.table_name
     AND b.updt_dt_tm=a.updt_dt_tm)))
   WITH nocounter
  ;end delete
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ROLLBACK
   GO TO exit_program
  ENDIF
  COMMIT
 ELSE
  GO TO exit_program
 ENDIF
#exit_program
 IF ((dm_err->err_ind=0))
  SET dm_err->eproc = "Dm2_aload_afd_constraints completed."
 ELSE
  CALL parser(";x",1)
 ENDIF
 CALL final_disp_msg("dm2_aload_afd_constraints")
END GO
