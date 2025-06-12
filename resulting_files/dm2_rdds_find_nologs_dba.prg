CREATE PROGRAM dm2_rdds_find_nologs:dba
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
 DECLARE get_target_location_cd(loc_code=f8) = f8 WITH public
 DECLARE get_target_resource_cd(rec_code=f8) = f8 WITH public
 DECLARE get_target_task_ref_cd(tr_code=f8) = f8 WITH public
 DECLARE get_target_event_cd(tr_code=f8) = f8 WITH public
 DECLARE get_target_image_class_cd(imc_code=f8) = f8 WITH public
 DECLARE get_target_catalog_cd(source_cat_code=f8) = f8 WITH public
 DECLARE get_target_pchart_comp_cd(pchart_code=f8) = f8 WITH public
 DECLARE get_target_dta(dta_code=f8) = f8 WITH public
 DECLARE get_target_oefields(oe_code=f8) = f8 WITH public
 DECLARE get_value(sbr_table=vc,sbr_column=vc,sbr_origin=vc) = vc WITH public
 DECLARE get_nullind(sbr_table=vc,sbr_column=vc) = i2 WITH public
 DECLARE put_value(sbr_table=vc,sbr_column=vc,sbr_value=vc) = null
 DECLARE get_translates(sbr_table=vc) = null
 DECLARE is_translated(sbr_table=vc,sbr_column=vc) = i2
 DECLARE get_seq(sbr_table=vc,sbr_column=vc) = f8
 DECLARE get_col_pos(sbr_table=vc,sbr_column=vc) = i4
 DECLARE get_primary_key(sbr_table=vc) = vc WITH public
 DECLARE check_ui_exist(sbr_table_name=vc) = i2
 DECLARE check_sec_trans(sbr_table_name=vc,sbr_col_name=vc) = null
 DECLARE evaluate_rpt_missing(erm_missing_val=vc) = null
 DECLARE get_err_val(null) = i4
 DECLARE sbr_err_val = i4
 DECLARE inc_prelink = vc
 DECLARE inc_postlink = vc
 FREE RECORD rdds_exception
 RECORD rdds_exception(
   1 qual[*]
     2 tab_col_name = vc
     2 tru_tab_name = vc
     2 tru_col_name = vc
 )
 SUBROUTINE get_target_location_cd(loc_cd)
   DECLARE ui_loc_cd = vc
   DECLARE ui_cnt = i4
   DECLARE source_parent_ind = i2
   DECLARE to_par = f8
   DECLARE to_active = i2
   DECLARE mult_cnt = i4
   DECLARE mult_loop = i4
   DECLARE trans_ref = vc
   DECLARE par_cdf = vc
   DECLARE alt_par_cdf = vc
   DECLARE unknown_ind = i2
   DECLARE second_try_ind = i2
   DECLARE mult_loop = i4
   DECLARE sbr_any_trans = i2
   DECLARE new_cv_ind = i2
   DECLARE gtl_cur_dt_tm = f8
   DECLARE gtl_beg_dt_tm = f8
   DECLARE gtl_end_dt_tm = f8
   DECLARE gtl_addl_cnt = i4
   DECLARE gtl_done_ind = i2
   DECLARE gtl_spec_q_ind = i2
   DECLARE gtl_loop = i4
   DECLARE gtl_eval_ret = f8
   DECLARE gtl_nopar_trans = i2
   SET gtl_spec_quer_ind = 0
   SET gtl_nopar_trans = 0
   FREE RECORD target_query
   RECORD target_query(
     1 from_clause = vc
     1 plan_stmts[*]
       2 p_clause = vc
     1 join1_stmts[*]
       2 j1_clause = vc
     1 join2_stmts[*]
       2 j2_clause = vc
     1 detail_stmts[*]
       2 d_clause = vc
     1 addl_stmts[*]
       2 a_clause = vc
   )
   FREE RECORD mult_loc
   RECORD mult_loc(
     1 qual[*]
       2 src_cd1 = f8
       2 src_cd2 = f8
       2 trans_ind1 = i2
       2 trans_ind2 = i2
       2 tgt_cd1 = f8
       2 tgt_cd2 = f8
       2 tgt_val = vc
       2 tgt_cnt = i4
       2 sec_try = i2
   )
   SET to_active = 0
   SET to_par = 0
   SET ui_cnt = 0
   SET source_parent_ind = 0
   SET unknown_ind = 0
   SET gt_select = dm2_get_rdds_tname("CODE_VALUE")
   SET stat = alterlist(target_query->addl_stmts,1)
   SET target_query->addl_stmts[1].a_clause = " and cv2.active_ind = cv.active_ind "
   IF (get_nullind("CODE_VALUE","BEGIN_EFFECTIVE_DT_TM")=0
    AND get_nullind("CODE_VALUE","END_EFFECTIVE_DT_TM")=0)
    SET stat = alterlist(target_query->addl_stmts,3)
    SET gtl_cur_dt_tm = cnvtdatetime(curdate,curtime3)
    SET gtl_beg_dt_tm = rs_0619->from_values.begin_effective_dt_tm
    SET gtl_end_dt_tm = rs_0619->from_values.end_effective_dt_tm
    IF (gtl_beg_dt_tm < gtl_cur_dt_tm
     AND gtl_end_dt_tm > gtl_cur_dt_tm)
     SET target_query->addl_stmts[2].a_clause = concat(
      " and cv.begin_effective_dt_tm < cnvtdatetime(gtl_cur_dt_Tm) ",
      " and cv.end_effective_dt_tm > cnvtdatetime(gtl_cur_dt_tm) ")
     SET target_query->addl_stmts[3].a_clause = concat(
      " and cv.begin_effective_dt_tm < cnvtdatetime(gtl_cur_dt_Tm) ",
      " and cv.end_effective_dt_tm > cnvtdatetime(gtl_cur_dt_tm) and cv2.active_ind = cv.active_ind "
      )
    ELSE
     SET target_query->addl_stmts[2].a_clause = concat(
      " and (cv.begin_effective_dt_tm > cnvtdatetime(gtl_cur_dt_Tm) ",
      " or cv.end_effective_dt_tm < cnvtdatetime(gtl_cur_dt_tm)) ")
     SET target_query->addl_stmts[3].a_clause = concat(
      " and (cv.begin_effective_dt_tm > cnvtdatetime(gtl_cur_dt_Tm) ",
      " or cv.end_effective_dt_tm < cnvtdatetime(gtl_cur_dt_tm)) and cv2.active_ind = cv.active_ind "
      )
    ENDIF
   ENDIF
   CASE (rs_0619->from_values.cdf_meaning)
    OF "NURSEUNIT":
    OF "AMBULATORY":
     SET gt_lgselect = dm2_get_rdds_tname("NURSE_UNIT")
     CALL parser("select into 'nl:' from ",0)
     CALL parser(concat(gt_lgselect," l "),0)
     CALL parser(" where l.location_cd = loc_cd",0)
     CALL parser(" detail mult_cnt = mult_cnt + 1 ",0)
     CALL parser(" stat = alterlist(mult_loc->qual, mult_cnt) ",0)
     CALL parser(concat(" mult_loc->qual[mult_cnt].src_cd1 = l.loc_building_cd ",
       " mult_loc->qual[mult_cnt].src_cd2 = l.loc_facility_cd "),0)
     CALL parser(" with nocounter go",1)
    OF "ROOM":
     SET gt_lgselect = dm2_get_rdds_tname("ROOM")
     CALL parser("select into 'nl:' from ",0)
     CALL parser(concat(gt_lgselect," l "),0)
     CALL parser(" where l.location_cd = loc_cd",0)
     CALL parser(" detail mult_cnt = mult_cnt + 1 ",0)
     CALL parser(" stat = alterlist(mult_loc->qual, mult_cnt) ",0)
     CALL parser(" mult_loc->qual[mult_cnt].src_cd1 = l.loc_nurse_unit_cd ",0)
     CALL parser(" with nocounter go",1)
    OF "BED":
     SET gt_lgselect = dm2_get_rdds_tname("BED")
     CALL parser("select into 'nl:' from ",0)
     CALL parser(concat(gt_lgselect," l "),0)
     CALL parser(" where l.location_cd = loc_cd",0)
     CALL parser(" detail mult_cnt = mult_cnt + 1 ",0)
     CALL parser(" stat = alterlist(mult_loc->qual, mult_cnt) ",0)
     CALL parser(" mult_loc->qual[mult_cnt].src_cd1 = l.loc_room_cd ",0)
     CALL parser(" with nocounter go",1)
    OF "FACILITY":
    OF "ACTASGNROOT":
    OF "APPTROOT":
    OF "BBOWNERROOT":
    OF "COLLROOT":
    OF "CSLOGIN":
    OF "CSTRACK":
    OF "FOLLOWUPAMB":
    OF "HIMROOT":
    OF "HIS":
    OF "INVGRP":
    OF "INVVIEW":
    OF "LAB":
    OF "MMGRPROOT":
    OF "PATLISTROOT":
    OF "PLREMOTE":
    OF "PTTRACKROOT":
    OF "PTTRACKVIEW":
    OF "ROUNDSROOT":
    OF "RXLOCGROUP":
    OF "SPECCOLLROOT":
    OF "SPECTRKROOT":
    OF "SRVAREA":
    OF "STORAGERACK":
    OF "STORAGEROOT":
    OF "STORTRKROOT":
    OF "TRANSPORT":
    OF "TSKGRPROOT":
    OF "SHFTASGNROOT":
     CALL echo("No source work needs to be done for this CDF_Meaning")
     SET mult_cnt = 1
     SET stat = alterlist(mult_loc->qual,mult_cnt)
    ELSE
     IF ((rs_0619->from_values.cdf_meaning IN ("ANCILSURG", "APPTLOC", "HIM", "PHARM", "RAD")))
      SET par_cdf = "BUILDING"
      SET alt_par_cdf = ""
     ELSEIF ((rs_0619->from_values.cdf_meaning="BBINVAREA"))
      SET par_cdf = "BBOWNERROOT"
      SET alt_par_cdf = ""
     ELSEIF ((rs_0619->from_values.cdf_meaning="BUILDING"))
      SET par_cdf = "FACILITY"
      SET alt_par_cdf = ""
     ELSEIF ((rs_0619->from_values.cdf_meaning IN ("CHECKOUT", "WAITROOM")))
      SET par_cdf = "AMBULATORY"
      SET alt_par_cdf = ""
     ELSEIF ((rs_0619->from_values.cdf_meaning="COLLRTE"))
      SET par_cdf = "COLLRUN"
      SET alt_par_cdf = ""
     ELSEIF ((rs_0619->from_values.cdf_meaning="COLLRUN"))
      SET par_cdf = "COLLROOT"
      SET alt_par_cdf = ""
     ELSEIF ((rs_0619->from_values.cdf_meaning="INVLOC"))
      SET par_cdf = "BUILDING"
      SET alt_par_cdf = "ANCILSURG"
     ELSEIF ((rs_0619->from_values.cdf_meaning="INVLOCATOR"))
      SET par_cdf = "INVLOC"
      SET alt_par_cdf = ""
     ELSEIF ((rs_0619->from_values.cdf_meaning="PTTRACK"))
      SET par_cdf = "PTTRACKROOT"
      SET alt_par_cdf = ""
     ELSEIF ((rs_0619->from_values.cdf_meaning="STORAGESHELF"))
      SET par_cdf = "STORAGEUNIT"
      SET alt_par_cdf = ""
     ELSEIF ((rs_0619->from_values.cdf_meaning="STORAGEUNIT"))
      SET par_cdf = "STORAGEROOT"
      SET alt_par_cdf = ""
     ELSE
      SET par_cdf = ""
      SET alt_par_cdf = ""
      SET unknown_ind = 1
     ENDIF
     SET gt_lgselect = dm2_get_rdds_tname("LOCATION_GROUP")
     CALL parser("select into 'nl:' from ",0)
     IF (par_cdf="")
      CALL parser(concat(gt_lgselect," l "),0)
      CALL parser(" plan l where l.child_loc_cd = loc_cd",0)
     ELSE
      CALL parser(concat(gt_lgselect," l, ",gt_select," c"),0)
      CALL parser(" plan l where l.child_loc_cd = loc_cd",0)
      CALL parser(" join c where l.parent_loc_cd = c.code_value and c.cdf_meaning = par_cdf",0)
     ENDIF
     CALL parser(" detail mult_cnt = mult_cnt + 1 ",0)
     CALL parser(" stat = alterlist(mult_loc->qual, mult_cnt) ",0)
     CALL parser(
      " mult_loc->qual[mult_cnt].src_cd1=l.parent_loc_cd mult_loc->qual[mult_cnt].src_cd2=l.root_loc_cd",
      0)
     CALL parser(" with nocounter go",1)
     IF (mult_cnt=0
      AND alt_par_cdf != "")
      CALL parser("select into 'nl:' from ",0)
      CALL parser(concat(gt_lgselect," l, ",gt_select," c"),0)
      CALL parser(" plan l where l.child_loc_cd = loc_cd",0)
      CALL parser(" join c where l.parent_loc_cd = c.code_value and c.cdf_meaning = alt_par_cdf",0)
      CALL parser(" detail mult_cnt = mult_cnt + 1 ",0)
      CALL parser(" stat = alterlist(mult_loc->qual, mult_cnt) ",0)
      CALL parser(" mult_loc->qual[mult_cnt].src_cd1 = l.parent_loc_cd ",0)
      CALL parser(" mult_loc->qual[mult_cnt].src_cd2 = l.root_loc_cd with nocounter go",1)
     ENDIF
   ENDCASE
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
    SET nodelete_ind = 1
    RETURN(- (20))
   ENDIF
   IF (mult_cnt=0)
    IF (unknown_ind=0)
     RETURN(- (17))
    ENDIF
   ENDIF
   FOR (mult_loop = 1 TO mult_cnt)
    IF ((mult_loc->qual[mult_loop].src_cd1 > 0))
     SET trans_ref = select_merge_translate(cnvtstring(mult_loc->qual[mult_loop].src_cd1),
      "CODE_VALUE")
     IF (trans_ref != "No Trans")
      SET mult_loc->qual[mult_loop].tgt_cd1 = cnvtreal(trans_ref)
      SET mult_loc->qual[mult_loop].trans_ind1 = 1
     ELSE
      SET rpt_missing = report_missing("CODE_VALUE","CODE_VALUE",mult_loc->qual[mult_loop].src_cd1)
      IF (rpt_missing="ORPHAN")
       RETURN(- (21))
      ENDIF
      IF (rpt_missing="NOMV*")
       RETURN(- (22))
      ENDIF
     ENDIF
    ELSE
     SET mult_loc->qual[mult_loop].tgt_cd1 = 0
     SET mult_loc->qual[mult_loop].trans_ind1 = 1
    ENDIF
    IF ((mult_loc->qual[mult_loop].src_cd2 > 0))
     SET trans_ref = select_merge_translate(cnvtstring(mult_loc->qual[mult_loop].src_cd2),
      "CODE_VALUE")
     IF (trans_ref != "No Trans")
      SET mult_loc->qual[mult_loop].tgt_cd2 = cnvtreal(trans_ref)
      SET mult_loc->qual[mult_loop].trans_ind2 = 1
     ELSE
      SET rpt_missing = report_missing("CODE_VALUE","CODE_VALUE",mult_loc->qual[mult_loop].src_cd2)
      IF (rpt_missing="ORPHAN")
       RETURN(- (21))
      ENDIF
      IF (rpt_missing="NOMV*")
       RETURN(- (22))
      ENDIF
     ENDIF
    ELSE
     SET mult_loc->qual[mult_loop].tgt_cd2 = 0
     SET mult_loc->qual[mult_loop].trans_ind2 = 1
    ENDIF
   ENDFOR
   FOR (mult_loop = 1 TO mult_cnt)
     IF ((mult_loc->qual[mult_loop].trans_ind1=1)
      AND (mult_loc->qual[mult_loop].trans_ind2=1))
      SET sbr_any_trans = 1
     ENDIF
   ENDFOR
   IF (sbr_any_trans=0)
    RETURN(- (1))
   ENDIF
   FOR (mult_loop = 1 TO mult_cnt)
     SET ui_cnt = 0
     SET ui_loc_cd = ""
     IF ((mult_loc->qual[mult_loop].trans_ind1=1)
      AND (mult_loc->qual[mult_loop].trans_ind2=1))
      CASE (rs_0619->from_values.cdf_meaning)
       OF "NURSEUNIT":
       OF "AMBULATORY":
        SET gtl_spec_q_ind = 1
        SET target_query->from_clause = concat("select into 'nl:' from code_value cv, nurse_unit l, ",
         gt_select," cv2 ")
        SET stat = alterlist(target_query->plan_stmts,1)
        SET target_query->plan_stmts[1].p_clause = " plan cv2 where cv2.code_value = loc_cd"
        SET stat = alterlist(target_query->join1_stmts,2)
        SET target_query->join1_stmts[1].j1_clause =
        " join cv where cv2.display = cv.display and cv2.display_key = cv.display_key "
        SET target_query->join1_stmts[2].j1_clause =
        " and cv2.cdf_meaning = cv.cdf_meaning and cv.code_set = 220 "
        SET stat = alterlist(target_query->join2_stmts,2)
        SET target_query->join2_stmts[1].j2_clause =
        " join l where cv.code_value = l.location_cd and l.loc_building_cd = mult_loc->qual[mult_loop].tgt_cd1"
        SET target_query->join2_stmts[2].j2_clause =
        " and l.loc_facility_cd = mult_loc->qual[mult_loop].tgt_cd2"
        SET stat = alterlist(target_query->detail_stmts,2)
        SET target_query->detail_stmts[1].d_clause =
        " detail ui_cnt = ui_cnt + 1 stat = alterlist(ui_query_eval_rec->qual, ui_cnt) "
        SET target_query->detail_stmts[2].d_clause =
        " ui_query_eval_rec->qual[ui_cnt].root_entity_attr = cv.code_value with nocounter go "
       OF "ROOM":
        SET gtl_spec_q_ind = 1
        SET target_query->from_clause = concat("select into 'nl:' from code_value cv, room l, ",
         gt_select," cv2 ")
        SET stat = alterlist(target_query->plan_stmts,1)
        SET target_query->plan_stmts[1].p_clause = " plan cv2 where cv2.code_value = loc_cd"
        SET stat = alterlist(target_query->join1_stmts,3)
        SET target_query->join1_stmts[1].j1_clause =
        " join cv where cv2.display = cv.display and cv2.display_key = cv.display_key "
        SET target_query->join1_stmts[2].j1_clause =
        " and cv2.cdf_meaning = cv.cdf_meaning and (cv.description = cv2.description  or "
        SET target_query->join1_stmts[3].j1_clause =
        " (cv.description = null and cv2.description = null)) and cv.code_set = 220 "
        SET stat = alterlist(target_query->join2_stmts,1)
        SET target_query->join2_stmts[1].j2_clause =
        " join l where cv.code_value=l.location_cd and l.loc_nurse_unit_cd=mult_loc->qual[mult_loop].tgt_cd1"
        SET stat = alterlist(target_query->detail_stmts,2)
        SET target_query->detail_stmts[1].d_clause =
        " detail ui_cnt = ui_cnt + 1 stat = alterlist(ui_query_eval_rec->qual, ui_cnt) "
        SET target_query->detail_stmts[2].d_clause =
        " ui_query_eval_rec->qual[ui_cnt].root_entity_attr = cv.code_value with nocounter go "
       OF "BED":
        SET gtl_spec_q_ind = 1
        SET target_query->from_clause = concat("select into 'nl:' from code_value cv, bed l, ",
         gt_select," cv2 ")
        SET stat = alterlist(target_query->plan_stmts,1)
        SET target_query->plan_stmts[1].p_clause = " plan cv2 where cv2.code_value = loc_cd"
        SET stat = alterlist(target_query->join1_stmts,2)
        SET target_query->join1_stmts[1].j1_clause =
        " join cv where cv2.display = cv.display and cv2.display_key = cv.display_key "
        SET target_query->join1_stmts[2].j1_clause =
        " and cv2.cdf_meaning = cv.cdf_meaning and cv.code_set = 220 "
        SET stat = alterlist(target_query->join2_stmts,1)
        SET target_query->join2_stmts[1].j2_clause =
        " join l where cv.code_value = l.location_cd and l.loc_room_cd=mult_loc->qual[mult_loop].tgt_cd1"
        SET stat = alterlist(target_query->detail_stmts,2)
        SET target_query->detail_stmts[1].d_clause =
        " detail ui_cnt = ui_cnt + 1 stat = alterlist(ui_query_eval_rec->qual, ui_cnt) "
        SET target_query->detail_stmts[2].d_clause =
        " ui_query_eval_rec->qual[ui_cnt].root_entity_attr = cv.code_value with nocounter go "
       OF "FACILITY":
       OF "CSTRACK":
       OF "CSLOGIN":
        SET gtl_spec_q_ind = 1
        SET target_query->from_clause = concat("select into 'nl:' from code_value cv, ",gt_select,
         " cv2 ")
        SET stat = alterlist(target_query->plan_stmts,1)
        SET target_query->plan_stmts[1].p_clause = " plan cv2 where cv2.code_value = loc_cd"
        SET stat = alterlist(target_query->join1_stmts,3)
        SET target_query->join1_stmts[1].j1_clause =
        " join cv where cv2.display = cv.display and cv2.display_key = cv.display_key "
        SET target_query->join1_stmts[2].j1_clause =
        " and cv2.cdf_meaning = cv.cdf_meaning and (cv2.description = cv.description "
        SET target_query->join1_stmts[3].j1_clause =
        " or (cv2.description = null and cv.description = null)) and cv.code_set = 220 "
        SET stat = alterlist(target_query->detail_stmts,2)
        SET target_query->detail_stmts[1].d_clause =
        " detail ui_cnt = ui_cnt + 1 stat = alterlist(ui_query_eval_rec->qual, ui_cnt) "
        SET target_query->detail_stmts[2].d_clause =
        " ui_query_eval_rec->qual[ui_cnt].root_entity_attr = cv.code_value with nocounter go "
       OF "ACTASGNROOT":
       OF "APPTROOT":
       OF "BBOWNERROOT":
       OF "COLLROOT":
       OF "FOLLOWUPAMB":
       OF "HIMROOT":
       OF "HIS":
       OF "INVGRP":
       OF "INVVIEW":
       OF "LAB":
       OF "MMGRPROOT":
       OF "PATLISTROOT":
       OF "PLREMOTE":
       OF "PTTRACKROOT":
       OF "PTTRACKVIEW":
       OF "ROUNDSROOT":
       OF "RXLOCGROUP":
       OF "SPECCOLLROOT":
       OF "SPECTRKROOT":
       OF "STORAGEROOT":
       OF "STORTRKROOT":
       OF "SRVAREA":
       OF "STORAGERACK":
       OF "TSKGRPROOT":
       OF "TRANSPORT":
        SET gtl_spec_q_ind = 1
        SET target_query->from_clause = concat("select into 'nl:' from code_value cv, ",gt_select,
         " cv2 ")
        SET stat = alterlist(target_query->plan_stmts,1)
        SET target_query->plan_stmts[1].p_clause = " plan cv2 where cv2.code_value = loc_cd"
        SET stat = alterlist(target_query->join1_stmts,2)
        SET target_query->join1_stmts[1].j1_clause =
        " join cv where cv2.display = cv.display and cv2.display_key = cv.display_key "
        SET target_query->join1_stmts[2].j1_clause =
        " and cv2.cdf_meaning = cv.cdf_meaning and cv.code_set = 220 "
        SET stat = alterlist(target_query->detail_stmts,2)
        SET target_query->detail_stmts[1].d_clause =
        " detail ui_cnt = ui_cnt + 1 stat = alterlist(ui_query_eval_rec->qual, ui_cnt) "
        SET target_query->detail_stmts[2].d_clause =
        " ui_query_eval_rec->qual[ui_cnt].root_entity_attr = cv.code_value with nocounter go "
       ELSE
        IF (unknown_ind=1
         AND (mult_loc->qual[mult_loop].tgt_cd1=0))
         SET gtl_spec_q_ind = 1
         SET target_query->from_clause = concat("select into 'nl:' from code_value cv, ",gt_select,
          " cv2 ")
         SET stat = alterlist(target_query->plan_stmts,1)
         SET target_query->plan_stmts[1].p_clause = " plan cv2 where cv2.code_value = loc_cd"
         SET stat = alterlist(target_query->join1_stmts,2)
         SET target_query->join1_stmts[1].j1_clause =
         " join cv where cv2.display = cv.display and cv2.display_key = cv.display_key "
         SET target_query->join1_stmts[2].j1_clause =
         " and cv2.cdf_meaning = cv.cdf_meaning and cv2.description = cv.description and cv.code_set = 220 "
         SET stat = alterlist(target_query->detail_stmts,2)
         SET target_query->detail_stmts[1].d_clause =
         " detail ui_cnt = ui_cnt + 1 stat = alterlist(ui_query_eval_rec->qual, ui_cnt) "
         SET target_query->detail_stmts[2].d_clause =
         " ui_query_eval_rec->qual[ui_cnt].root_entity_attr = cv.code_value with nocounter go "
        ELSE
         SET target_query->from_clause = concat("select into 'nl:' from code_value cv, ",gt_select,
          " cv2, location_group l ")
         SET stat = alterlist(target_query->plan_stmts,1)
         SET target_query->plan_stmts[1].p_clause = " plan cv2 where cv2.code_value = loc_cd"
         SET stat = alterlist(target_query->join1_stmts,2)
         SET target_query->join1_stmts[1].j1_clause =
         " join cv where cv2.display = cv.display and cv2.display_key = cv.display_key "
         SET target_query->join1_stmts[2].j1_clause =
         " and cv2.cdf_meaning = cv.cdf_meaning and cv.code_set = 220 "
         SET stat = alterlist(target_query->join2_stmts,2)
         SET target_query->join2_stmts[1].j2_clause =
         " join l where l.child_loc_cd=cv.code_value and l.parent_loc_cd=mult_loc->qual[mult_loop].tgt_cd1"
         SET target_query->join2_stmts[2].j2_clause =
         " and l.root_loc_cd = mult_loc->qual[mult_loop].tgt_cd2"
         SET stat = alterlist(target_query->detail_stmts,2)
         SET target_query->detail_stmts[1].d_clause =
         " detail ui_cnt = ui_cnt + 1 stat = alterlist(ui_query_eval_rec->qual, ui_cnt) "
         SET target_query->detail_stmts[2].d_clause =
         " ui_query_eval_rec->qual[ui_cnt].root_entity_attr = cv.code_value with nocounter go "
         SET gtl_addl_cnt = 0
         SET ui_cnt = 0
         SET stat = alterlist(ui_query_eval_rec->qual,0)
         CALL parser(target_query->from_clause,0)
         FOR (gtl_loop = 1 TO size(target_query->plan_stmts,5))
           CALL parser(target_query->plan_stmts[gtl_loop].p_clause,0)
         ENDFOR
         FOR (gtl_loop = 1 TO size(target_query->join1_stmts,5))
           CALL parser(target_query->join1_stmts[gtl_loop].j1_clause,0)
         ENDFOR
         FOR (gtl_loop = 1 TO size(target_query->join2_stmts,5))
           CALL parser(target_query->join2_stmts[gtl_loop].j2_clause,0)
         ENDFOR
         FOR (gtl_loop = 1 TO size(target_query->detail_stmts,5))
           CALL parser(target_query->detail_stmts[gtl_loop].d_clause,0)
         ENDFOR
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          SET dm_err->err_ind = 0
          SET nodelete_ind = 1
          RETURN(- (20))
         ENDIF
         IF (((size(ui_query_eval_rec->qual,5) > 0) OR (mult_loop=mult_cnt)) )
          SET gtl_eval_ret = evaluate_exec_ui_query(ui_cnt,temp_tbl_cnt,perm_col_cnt)
          IF ((gtl_eval_ret=- (3)))
           RETURN(0)
          ELSEIF (gtl_eval_ret > 0)
           RETURN(gtl_eval_ret)
          ELSEIF ((gtl_eval_ret=- (2)))
           IF (gtl_addl_cnt=size(target_query->addl_stmts,5))
            RETURN(- (19))
           ELSE
            SET gtl_addl_cnt = (gtl_addl_cnt+ 1)
            SET ui_cnt = 0
            SET stat = alterlist(ui_query_eval_rec->qual,0)
            CALL parser(target_query->from_clause,0)
            FOR (gtl_loop = 1 TO size(target_query->plan_stmts,5))
              CALL parser(target_query->plan_stmts[gtl_loop].p_clause,0)
            ENDFOR
            FOR (gtl_loop = 1 TO size(target_query->join1_stmts,5))
              CALL parser(target_query->join1_stmts[gtl_loop].j1_clause,0)
            ENDFOR
            IF (gtl_addl_cnt > 0)
             CALL parser(target_query->addl_stmts[gtl_addl_cnt].a_clause,0)
            ENDIF
            FOR (gtl_loop = 1 TO size(target_query->join2_stmts,5))
              CALL parser(target_query->join2_stmts[gtl_loop].j2_clause,0)
            ENDFOR
            FOR (gtl_loop = 1 TO size(target_query->detail_stmts,5))
              CALL parser(target_query->detail_stmts[gtl_loop].d_clause,0)
            ENDFOR
            IF (check_error(dm_err->eproc)=1)
             CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
             SET dm_err->err_ind = 0
             SET nodelete_ind = 1
             RETURN(- (20))
            ENDIF
            IF (((size(ui_query_eval_rec->qual,5) > 0) OR (mult_loop=mult_cnt)) )
             SET gtl_eval_ret = evaluate_exec_ui_query(ui_cnt,temp_tbl_cnt,perm_col_cnt)
             IF ((gtl_eval_ret=- (3)))
              RETURN(0)
             ELSEIF (gtl_eval_ret > 0)
              RETURN(gtl_eval_ret)
             ELSEIF ((gtl_eval_ret=- (2)))
              RETURN(- (19))
             ELSE
              RETURN(- (20))
             ENDIF
            ENDIF
           ENDIF
          ELSE
           RETURN(- (20))
          ENDIF
         ENDIF
        ENDIF
      ENDCASE
      SET mult_loc->qual[mult_loop].tgt_cnt = ui_cnt
      SET mult_loc->qual[mult_loop].tgt_val = ui_loc_cd
     ELSE
      SET gtl_nopar_trans = 1
     ENDIF
   ENDFOR
   IF (gtl_spec_q_ind=1)
    SET mult_loop = 1
    SET gtl_done_ind = 0
    SET gtl_addl_cnt = 0
    SET stat = alterlist(ui_query_eval_rec->qual,0)
    WHILE (gtl_done_ind=0)
      SET ui_cnt = 0
      SET stat = alterlist(ui_query_eval_rec->qual,0)
      CALL parser(target_query->from_clause,0)
      FOR (gtl_loop = 1 TO size(target_query->plan_stmts,5))
        CALL parser(target_query->plan_stmts[gtl_loop].p_clause,0)
      ENDFOR
      FOR (gtl_loop = 1 TO size(target_query->join1_stmts,5))
        CALL parser(target_query->join1_stmts[gtl_loop].j1_clause,0)
      ENDFOR
      IF (gtl_addl_cnt > 0)
       CALL parser(target_query->addl_stmts[gtl_addl_cnt].a_clause,0)
      ENDIF
      FOR (gtl_loop = 1 TO size(target_query->join2_stmts,5))
        CALL parser(target_query->join2_stmts[gtl_loop].j2_clause,0)
      ENDFOR
      FOR (gtl_loop = 1 TO size(target_query->detail_stmts,5))
        CALL parser(target_query->detail_stmts[gtl_loop].d_clause,0)
      ENDFOR
      IF (check_error(dm_err->eproc)=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET dm_err->err_ind = 0
       SET nodelete_ind = 1
       RETURN(- (20))
      ENDIF
      SET gtl_eval_ret = evaluate_exec_ui_query(ui_cnt,temp_tbl_cnt,perm_col_cnt)
      IF (gtl_addl_cnt=size(target_query->addl_stmts,5))
       SET gtl_done_ind = 1
      ELSE
       IF ((gtl_eval_ret=- (2)))
        SET gtl_addl_cnt = (gtl_addl_cnt+ 1)
       ELSE
        SET gtl_done_ind = 1
       ENDIF
      ENDIF
    ENDWHILE
    IF ((gtl_eval_ret=- (3)))
     RETURN(0)
    ELSEIF (gtl_eval_ret > 0)
     RETURN(gtl_eval_ret)
    ELSE
     RETURN(- (19))
    ENDIF
   ELSE
    IF (gtl_nopar_trans=1)
     RETURN(- (1))
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE get_target_catalog_cd(source_cat_code)
   DECLARE ui_cat_cd = f8
   DECLARE ui_cat_cnt = i4
   SET ui_cat_cnt = 0
   SET inc_prelink = dm2_ref_data_doc->pre_link_name
   SET inc_postlink = dm2_ref_data_doc->post_link_name
   SET gt_select = dm2_get_rdds_tname("ORDER_CATALOG")
   SET stat = alterlist(ui_query_eval_rec->qual,0)
   SET ui_cat_cnt = 0
   SELECT INTO "NL:"
    oct.catalog_cd
    FROM order_catalog oct,
     (parser(gt_select) oc)
    PLAN (oc
     WHERE oc.catalog_cd=source_cat_code)
     JOIN (oct
     WHERE oc.primary_mnemonic=oct.primary_mnemonic)
    DETAIL
     ui_cat_cnt = (ui_cat_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,ui_cat_cnt),
     ui_query_eval_rec->qual[ui_cat_cnt].root_entity_attr = oct.catalog_cd
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
    SET nodelete_ind = 1
    RETURN(- (20))
   ENDIF
   SET ui_cat_cd = evaluate_exec_ui_query(ui_cat_cnt,temp_tbl_cnt,perm_col_cnt)
   IF ((ui_cat_cd=- (1)))
    RETURN(- (20))
   ELSEIF ((ui_cat_cd=- (2)))
    SET ui_cat_cnt = 0
    SET stat = alterlist(ui_query_eval_rec->qual,0)
    SELECT INTO "NL:"
     oct.catalog_cd
     FROM order_catalog oct,
      (parser(gt_select) oc)
     PLAN (oc
      WHERE oc.catalog_cd=source_cat_code)
      JOIN (oct
      WHERE oc.primary_mnemonic=oct.primary_mnemonic
       AND oct.active_ind=oc.active_ind)
     DETAIL
      ui_cat_cnt = (ui_cat_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,ui_cat_cnt),
      ui_query_eval_rec->qual[ui_cat_cnt].root_entity_attr = oct.catalog_cd
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
     SET nodelete_ind = 1
     RETURN(- (20))
    ENDIF
    SET ui_cat_cd = evaluate_exec_ui_query(ui_cat_cnt,temp_tbl_cnt,perm_col_cnt)
    IF ((ui_cat_cd=- (1)))
     RETURN(- (20))
    ELSEIF ((ui_cat_cd=- (2)))
     RETURN(- (3))
    ELSEIF ((ui_cat_cd=- (3)))
     RETURN(0)
    ELSE
     RETURN(ui_cat_cd)
    ENDIF
   ELSEIF ((ui_cat_cd=- (3)))
    RETURN(0)
   ELSE
    RETURN(ui_cat_cd)
   ENDIF
 END ;Subroutine
 SUBROUTINE get_target_event_cd(tr_code)
   DECLARE ui_es_cd = f8
   DECLARE ui_es_cnt = i4
   DECLARE gt_select = vc
   DECLARE cv_select = vc
   SET ui_es_cnt = 0
   SET inc_prelink = dm2_ref_data_doc->pre_link_name
   SET inc_postlink = dm2_ref_data_doc->post_link_name
   SET gt_select = dm2_get_rdds_tname("V500_EVENT_CODE")
   SET cv_select = dm2_get_rdds_tname("CODE_VALUE")
   SET stat = alterlist(ui_query_eval_rec->qual,0)
   SET ui_es_cnt = 0
   SELECT INTO "NL:"
    es.event_cd
    FROM v500_event_code es,
     (parser(gt_select) es1)
    PLAN (es1
     WHERE es1.event_cd=tr_code)
     JOIN (es
     WHERE ((es1.event_cd_disp=es.event_cd_disp) OR (es1.event_cd_disp=null
      AND es.event_cd_disp=null))
      AND ((es1.event_cd_descr=es.event_cd_descr) OR (es1.event_cd_descr=null
      AND es.event_cd_descr=null))
      AND ((es1.event_set_name=es.event_set_name) OR (es1.event_set_name=null
      AND es.event_set_name=null)) )
    DETAIL
     ui_es_cnt = (ui_es_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,ui_es_cnt),
     ui_query_eval_rec->qual[ui_es_cnt].root_entity_attr = es.event_cd
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
    SET nodelete_ind = 1
    RETURN(- (20))
   ENDIF
   SET ui_es_cd = evaluate_exec_ui_query(ui_es_cnt,temp_tbl_cnt,perm_col_cnt)
   IF ((ui_es_cd=- (1)))
    RETURN(- (20))
   ELSEIF ((ui_es_cd=- (2)))
    SET ui_es_cnt = 0
    SET stat = alterlist(ui_query_eval_rec->qual,0)
    SELECT INTO "NL:"
     es.event_cd
     FROM v500_event_code es,
      (parser(gt_select) es1),
      code_value cv,
      (parser(cv_select) cv1)
     PLAN (cv1
      WHERE cv1.code_value=tr_code)
      JOIN (es1
      WHERE es1.event_cd=cv1.code_value)
      JOIN (es
      WHERE ((es1.event_cd_disp=es.event_cd_disp) OR (es1.event_cd_disp=null
       AND es.event_cd_disp=null))
       AND ((es1.event_cd_descr=es.event_cd_descr) OR (es1.event_cd_descr=null
       AND es.event_cd_descr=null))
       AND ((es1.event_set_name=es.event_set_name) OR (es1.event_set_name=null
       AND es.event_set_name=null)) )
      JOIN (cv
      WHERE cv.code_value=es.event_cd
       AND cv.active_ind=cv1.active_ind)
     DETAIL
      ui_es_cnt = (ui_es_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,ui_es_cnt),
      ui_query_eval_rec->qual[ui_es_cnt].root_entity_attr = cv.code_value
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
     SET nodelete_ind = 1
     RETURN(- (20))
    ENDIF
    SET ui_es_cd = evaluate_exec_ui_query(ui_es_cnt,temp_tbl_cnt,perm_col_cnt)
    IF ((ui_es_cd=- (1)))
     RETURN(- (20))
    ELSEIF ((ui_es_cd=- (2)))
     RETURN(- (18))
    ELSEIF ((ui_es_cd=- (3)))
     RETURN(0)
    ELSE
     RETURN(ui_es_cd)
    ENDIF
   ELSEIF ((ui_es_cd=- (3)))
    RETURN(0)
   ELSE
    RETURN(ui_es_cd)
   ENDIF
 END ;Subroutine
 SUBROUTINE get_target_pchart_comp_cd(pchart_code)
   DECLARE ui_cat_cd = f8
   DECLARE ui_cat_cnt = i4
   SET ui_cat_cnt = 0
   SET inc_prelink = dm2_ref_data_doc->pre_link_name
   SET inc_postlink = dm2_ref_data_doc->post_link_name
   SET gt_select = dm2_get_rdds_tname("CODE_VALUE")
   SET stat = alterlist(ui_query_eval_rec->qual,0)
   SET ui_cat_cnt = 0
   SELECT INTO "nl:"
    c.code_value
    FROM (parser(gt_select) cv),
     code_value c
    PLAN (cv
     WHERE cv.code_value=pchart_code)
     JOIN (c
     WHERE cv.definition=c.definition
      AND cv.cdf_meaning=c.cdf_meaning)
    DETAIL
     ui_cat_cnt = (ui_cat_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,ui_cat_cnt),
     ui_query_eval_rec->qual[ui_cat_cnt].root_entity_attr = c.code_value
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
    SET nodelete_ind = 1
    RETURN(- (20))
   ENDIF
   SET ui_cat_cd = evaluate_exec_ui_query(ui_cat_cnt,temp_tbl_cnt,perm_col_cnt)
   IF ((ui_cat_cd=- (1)))
    RETURN(- (20))
   ELSEIF ((ui_cat_cd=- (2)))
    SET ui_cat_cnt = 0
    SET stat = alterlist(ui_query_eval_rec->qual,0)
    SELECT INTO "nl:"
     c.code_value
     FROM (parser(gt_select) cv),
      code_value c
     PLAN (cv
      WHERE cv.code_value=pchart_code)
      JOIN (c
      WHERE cv.definition=c.definition
       AND cv.cdf_meaning=c.cdf_meaning
       AND cv.active_ind=c.active_ind)
     DETAIL
      ui_cat_cnt = (ui_cat_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,ui_cat_cnt),
      ui_query_eval_rec->qual[ui_cat_cnt].root_entity_attr = c.code_value
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
     SET nodelete_ind = 1
     RETURN(- (20))
    ENDIF
    SET ui_cat_cd = evaluate_exec_ui_query(ui_cat_cnt,temp_tbl_cnt,perm_col_cnt)
    IF ((ui_cat_cd=- (1)))
     RETURN(- (20))
    ELSEIF ((ui_cat_cd=- (2)))
     RETURN(- (4))
    ELSEIF ((ui_cat_cd=- (3)))
     RETURN(0)
    ELSE
     RETURN(ui_cat_cd)
    ENDIF
   ELSEIF ((ui_cat_cd=- (3)))
    RETURN(0)
   ELSE
    RETURN(ui_cat_cd)
   ENDIF
 END ;Subroutine
 SUBROUTINE get_target_resource_cd(rec_cd)
   DECLARE ui_rec_cd = f8
   DECLARE ui_rec_cnt = i4
   DECLARE cv_parent_ind = i2
   DECLARE source_parent_ind = i2
   DECLARE to_par = f8
   DECLARE to_active = i2
   DECLARE res_ins_ind = i2
   DECLARE res_mult_ind = i2
   FREE RECORD res_cd
   RECORD res_cd(
     1 qual[*]
       2 from_val = f8
       2 to_val = f8
       2 trans_ind = i2
       2 active_ind = i2
   )
   DECLARE res_rs_loop = i4
   DECLARE sbr_ret_value = vc
   DECLARE par_res_cnt = i4
   SET res_mult_ind = 0
   SET res_ins_ind = 0
   SET to_active = 0
   SET ui_rec_cd = 0
   SET to_par = 0
   SET ui_rec_cnt = 0
   SET source_parent_ind = 0
   SET cv_parent_ind = 0
   SET gt_select = dm2_get_rdds_tname("CODE_VALUE")
   SET gt_lgselect = dm2_get_rdds_tname("RESOURCE_GROUP")
   CALL parser("select into 'nl:' from ",0)
   CALL parser(concat(gt_lgselect," r"),0)
   CALL parser(" where r.child_service_resource_cd = rec_cd",0)
   CALL parser(" detail to_active = r.active_ind source_parent_ind = 1 with nocounter go",1)
   IF (curqual > 0)
    CALL parser("select into 'nl:'",0)
    CALL parser(concat("from ",gt_lgselect," r"),0)
    CALL parser("where r.child_service_resource_cd = rec_cd",0)
    CALL parser(" detail par_res_cnt = par_res_cnt + 1 stat=alterlist(res_cd->qual,par_res_cnt) ",0)
    CALL parser(" res_cd->qual[par_res_cnt].from_val=r.parent_service_resource_cd ",0)
    CALL parser(" res_cd->qual[par_res_cnt].active_ind = r.active_ind with nocounter go",1)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
     SET nodelete_ind = 1
     RETURN(- (20))
    ENDIF
    FOR (res_rs_loop = 1 TO par_res_cnt)
     SET sbr_ret_value = select_merge_translate(cnvtstring(res_cd->qual[res_rs_loop].from_val),
      "CODE_VALUE")
     IF (sbr_ret_value != "No Trans")
      SET res_cd->qual[res_rs_loop].to_val = cnvtreal(sbr_ret_value)
      SET res_cd->qual[res_rs_loop].trans_ind = 1
      SET cv_parent_ind = 1
     ELSE
      SET rpt_missing = report_missing("CODE_VALUE","CODE_VALUE",res_cd->qual[res_rs_loop].from_val)
      IF (rpt_missing="ORPHAN")
       RETURN(- (21))
      ENDIF
      IF (rpt_missing="NOMV*")
       RETURN(- (22))
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
   IF (source_parent_ind=1)
    IF (cv_parent_ind=0)
     RETURN(- (5))
    ELSE
     FOR (res_rs_loop = 1 TO par_res_cnt)
       IF ((res_cd->qual[res_rs_loop].trans_ind=1))
        SET stat = alterlist(ui_query_eval_rec->qual,0)
        SET ui_rec_cnt = 0
        SELECT INTO "NL:"
         FROM code_value cv,
          resource_group rg,
          (parser(gt_select) cv2)
         PLAN (cv2
          WHERE cv2.code_value=rec_cd
           AND cv2.code_set=221)
          JOIN (cv
          WHERE cv2.display_key=cv.display_key
           AND cv2.cdf_meaning=cv.cdf_meaning
           AND cv.code_set=221)
          JOIN (rg
          WHERE rg.child_service_resource_cd=cv.code_value
           AND (rg.parent_service_resource_cd=res_cd->qual[res_rs_loop].to_val))
         DETAIL
          ui_rec_cnt = (ui_rec_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,ui_rec_cnt),
          ui_query_eval_rec->qual[ui_rec_cnt].root_entity_attr = cv.code_value
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         SET dm_err->err_ind = 0
         SET nodelete_ind = 1
         RETURN(- (20))
        ENDIF
        SET ui_rec_cd = evaluate_exec_ui_query(ui_rec_cnt,temp_tbl_cnt,perm_col_cnt)
        IF ((ui_rec_cd=- (1)))
         RETURN(- (20))
        ELSEIF ((ui_rec_cd=- (2)))
         SET ui_rec_cnt = 0
         SET stat = alterlist(ui_query_eval_rec->qual,0)
         SELECT INTO "NL:"
          FROM code_value cv,
           resource_group rg,
           (parser(gt_select) cv2)
          PLAN (cv2
           WHERE cv2.code_value=rec_cd
            AND cv2.code_set=221)
           JOIN (cv
           WHERE cv2.display_key=cv.display_key
            AND cv2.cdf_meaning=cv.cdf_meaning
            AND cv.code_set=221)
           JOIN (rg
           WHERE rg.child_service_resource_cd=cv.code_value
            AND (rg.parent_service_resource_cd=res_cd->qual[res_rs_loop].to_val)
            AND (rg.active_ind=res_cd->qual[res_rs_loop].active_ind))
          DETAIL
           ui_rec_cnt = (ui_rec_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,ui_rec_cnt),
           ui_query_eval_rec->qual[ui_rec_cnt].root_entity_attr = cv.code_value
          WITH nocounter
         ;end select
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          SET dm_err->err_ind = 0
          SET nodelete_ind = 1
          RETURN(- (20))
         ENDIF
         SET ui_rec_cd = evaluate_exec_ui_query(ui_rec_cnt,temp_tbl_cnt,perm_col_cnt)
         IF ((ui_rec_cd=- (1)))
          RETURN(- (20))
         ELSEIF ((ui_rec_cd=- (2))
          AND res_rs_loop=par_res_cnt)
          RETURN(- (6))
         ELSEIF ((ui_rec_cd=- (2))
          AND res_rs_loop != par_res_cnt)
          SET res_mult_ind = 1
         ELSEIF ((ui_rec_cd=- (3))
          AND res_rs_loop=par_res_cnt)
          RETURN(0)
         ELSEIF ((ui_rec_cd=- (3))
          AND res_rs_loop != par_res_cnt)
          SET res_ins_ind = 1
         ELSE
          RETURN(ui_rec_cd)
         ENDIF
        ELSEIF ((ui_rec_cd=- (3))
         AND res_rs_loop=par_res_cnt)
         RETURN(0)
        ELSEIF ((ui_rec_cd=- (3))
         AND res_rs_loop != par_res_cnt)
         SET res_ins_ind = 1
        ELSE
         RETURN(ui_rec_cd)
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
   ELSE
    SET stat = alterlist(ui_query_eval_rec->qual,0)
    SET ui_rec_cnt = 0
    SELECT INTO "NL:"
     FROM code_value cv,
      (parser(gt_select) cv2)
     PLAN (cv2
      WHERE cv2.code_value=rec_cd
       AND cv2.code_set=221)
      JOIN (cv
      WHERE cv2.display_key=cv.display_key
       AND cv2.cdf_meaning=cv.cdf_meaning
       AND cv.code_set=221
       AND  NOT (cv.code_value IN (
      (SELECT
       r.child_service_resource_cd
       FROM resource_group r
       WHERE r.child_service_resource_cd=cv.code_value))))
     DETAIL
      ui_rec_cnt = (ui_rec_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,ui_rec_cnt),
      ui_query_eval_rec->qual[ui_rec_cnt].root_entity_attr = cv.code_value
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
     SET nodelete_ind = 1
     RETURN(- (20))
    ENDIF
    SET ui_rec_cd = evaluate_exec_ui_query(ui_rec_cnt,temp_tbl_cnt,perm_col_cnt)
    IF ((ui_rec_cd=- (1)))
     RETURN(- (20))
    ELSEIF ((ui_rec_cd=- (2)))
     SET ui_rec_cnt = 0
     SET stat = alterlist(ui_query_eval_rec->qual,0)
     SELECT INTO "NL:"
      FROM code_value cv,
       (parser(gt_select) cv2)
      PLAN (cv2
       WHERE cv2.code_value=rec_cd
        AND cv2.code_set=221)
       JOIN (cv
       WHERE cv2.display_key=cv.display_key
        AND cv2.cdf_meaning=cv.cdf_meaning
        AND cv.code_set=221
        AND cv.active_ind=cv2.active_ind
        AND  NOT (cv.code_value IN (
       (SELECT
        r.child_service_resource_cd
        FROM resource_group r
        WHERE r.child_service_resource_cd=cv.code_value))))
      DETAIL
       ui_rec_cnt = (ui_rec_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,ui_rec_cnt),
       ui_query_eval_rec->qual[ui_rec_cnt].root_entity_attr = cv.code_value
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm_err->err_ind = 0
      SET nodelete_ind = 1
      RETURN(- (20))
     ENDIF
     SET ui_rec_cd = evaluate_exec_ui_query(ui_rec_cnt,temp_tbl_cnt,perm_col_cnt)
     IF ((ui_rec_cd=- (1)))
      RETURN(- (20))
     ELSEIF ((ui_rec_cd=- (2)))
      RETURN(- (6))
     ELSEIF ((ui_rec_cd=- (3)))
      RETURN(0)
     ELSE
      RETURN(ui_rec_cd)
     ENDIF
    ELSEIF ((ui_rec_cd=- (3)))
     RETURN(0)
    ELSE
     RETURN(ui_rec_cd)
    ENDIF
   ENDIF
   IF (res_mult_ind=1)
    RETURN(- (6))
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE get_target_image_class_cd(imc_cd)
   DECLARE ui_imc_cd = f8
   DECLARE ui_imc_cnt = i4
   DECLARE cv_parent_ind = i2
   DECLARE source_parent_ind = i2
   DECLARE lib_cd = f8
   DECLARE par_cd = f8
   DECLARE no_par_ind = i2
   DECLARE lib_trans_ind = i2
   DECLARE par_trans_ind = i2
   DECLARE to_lib = f8
   DECLARE to_par = f8
   DECLARE vc_lib = vc
   DECLARE vc_par = vc
   SET par_trans_ind = 0
   SET lib_trans_ind = 0
   SET no_par_ind = 0
   SET par_cd = 0
   SET lib_cd = 0
   SET ui_imc_cnt = 0
   SET source_parent_ind = 0
   SET cv_parent_ind = 0
   SET gt_select = dm2_get_rdds_tname("CODE_VALUE")
   SET gt_lgselect = dm2_get_rdds_tname("IMAGE_CLASS_TYPE")
   CALL parser(concat("select into 'nl:' from ",gt_lgselect," i where i.image_class_type_cd = imc_cd"
     ),0)
   CALL parser(
    "detail lib_cd = i.lib_group_cd par_cd = i.parent_image_class_type_cd with nocounter go",1)
   IF (par_cd=imc_cd)
    SET no_par_ind = 1
    SET par_trans_ind = 1
   ENDIF
   SET vc_lib = select_merge_translate(cnvtstring(lib_cd),"CODE_VALUE")
   IF (vc_lib != "No Trans")
    SET to_lib = cnvtreal(vc_lib)
    SET lib_trans_ind = 1
   ELSE
    SET rpt_missing = report_missing("CODE_VALUE","CODE_VALUE",lib_cd)
    IF (rpt_missing="ORPHAN")
     RETURN(- (21))
    ENDIF
    IF (rpt_missing="NOMV*")
     RETURN(- (22))
    ENDIF
   ENDIF
   IF (no_par_ind=0)
    SET vc_par = select_merge_translate(cnvtstring(par_cd),"CODE_VALUE")
    IF (vc_par != "No Trans")
     SET to_par = cnvtreal(vc_par)
     SET par_trans_ind = 1
    ELSE
     SET rpt_missing = report_missing("CODE_VALUE","CODE_VALUE",par_cd)
     IF (rpt_missing="ORPHAN")
      RETURN(- (21))
     ENDIF
     IF (rpt_missing="NOMV*")
      RETURN(- (22))
     ENDIF
    ENDIF
   ENDIF
   IF (lib_trans_ind=1)
    IF (par_trans_ind=1)
     SET stat = alterlist(ui_query_eval_rec->qual,0)
     SET ui_imc_cnt = 0
     SELECT INTO "NL:"
      FROM code_value cv,
       (parser(gt_select) cv2)
      PLAN (cv2
       WHERE cv2.code_set=5503
        AND cv2.code_value=imc_cd)
       JOIN (cv
       WHERE cv.description=cv2.description
        AND cv.display_key=cv2.display_key
        AND cv.code_set=5503
        AND  EXISTS (
       (SELECT
        "x"
        FROM image_class_type ic
        WHERE ic.image_class_type_cd=cv.code_value
         AND ic.parent_image_class_type_cd=evaluate(no_par_ind,0,to_par,1,ic.image_class_type_cd)
         AND ic.lib_group_cd=to_lib)))
      DETAIL
       ui_imc_cnt = (ui_imc_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,ui_imc_cnt),
       ui_query_eval_rec->qual[ui_imc_cnt].root_entity_attr = cv.code_value
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm_err->err_ind = 0
      SET nodelete_ind = 1
      RETURN(- (20))
     ENDIF
    ELSE
     RETURN(- (7))
    ENDIF
   ELSE
    RETURN(- (8))
   ENDIF
   SET ui_imc_cd = evaluate_exec_ui_query(ui_imc_cnt,temp_tbl_cnt,perm_col_cnt)
   IF ((ui_imc_cd=- (1)))
    RETURN(- (20))
   ELSEIF ((ui_imc_cd=- (2)))
    SET stat = alterlist(ui_query_eval_rec->qual,0)
    SET ui_imc_cnt = 0
    SELECT INTO "NL:"
     FROM code_value cv,
      (parser(gt_select) cv2)
     PLAN (cv2
      WHERE cv2.code_set=5503
       AND cv2.code_value=imc_cd)
      JOIN (cv
      WHERE cv.description=cv2.description
       AND cv.display_key=cv2.display_key
       AND cv.code_set=5503
       AND cv.active_ind=cv2.active_ind
       AND  EXISTS (
      (SELECT
       "x"
       FROM image_class_type ic
       WHERE ic.image_class_type_cd=cv.code_value
        AND ic.parent_image_class_type_cd=evaluate(no_par_ind,0,to_par,1,ic.image_class_type_cd)
        AND ic.lib_group_cd=to_lib)))
     DETAIL
      ui_imc_cnt = (ui_imc_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,ui_imc_cnt),
      ui_query_eval_rec->qual[ui_imc_cnt].root_entity_attr = cv.code_value
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
     SET nodelete_ind = 1
     RETURN(- (20))
    ENDIF
    SET ui_imc_cd = evaluate_exec_ui_query(ui_imc_cnt,temp_tbl_cnt,perm_col_cnt)
    IF ((ui_imc_cd=- (1)))
     RETURN(- (20))
    ELSEIF ((ui_imc_cd=- (2)))
     RETURN(- (9))
    ELSEIF ((ui_imc_cd=- (3)))
     RETURN(0)
    ELSE
     RETURN(ui_imc_cd)
    ENDIF
   ELSEIF ((ui_imc_cd=- (3)))
    RETURN(0)
   ELSE
    RETURN(ui_imc_cd)
   ENDIF
 END ;Subroutine
 SUBROUTINE get_target_task_ref_cd(sbr_code)
   DECLARE ui_tr_cd = f8
   DECLARE ui_tr_cnt = i4
   DECLARE s_tr_gr_cd = f8
   DECLARE as_cd_cnt = i4
   DECLARE tr_gr_cd = f8
   DECLARE sbr_ret_val = vc
   SET ui_tr_cnt = 0
   SET inc_prelink = dm2_ref_data_doc->pre_link_name
   SET inc_postlink = dm2_ref_data_doc->post_link_name
   SET gt_select = dm2_get_rdds_tname("CODE_VALUE")
   SELECT INTO "NL:"
    cv.code_value
    FROM (parser(gt_select) cv)
    WHERE cv.code_set=16370
     AND (cv.display=rs_0619->from_values.definition)
    DETAIL
     ui_tr_cnt = (ui_tr_cnt+ 1), s_tr_gr_cd = cv.code_value
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
    SET nodelete_ind = 1
    RETURN(- (20))
   ENDIF
   IF (ui_tr_cnt=1)
    SET sbr_ret_val = select_merge_translate(cnvtstring(s_tr_gr_cd),"CODE_VALUE")
    IF (sbr_ret_val != "No Trans")
     SET tr_gr_cd = cnvtreal(sbr_ret_val)
    ELSE
     SET rpt_missing = report_missing("CODE_VALUE","CODE_VALUE",s_tr_gr_cd)
     IF (rpt_missing="ORPHAN")
      RETURN(- (21))
     ENDIF
     IF (rpt_missing="NOMV*")
      RETURN(- (22))
     ENDIF
     SET ui_tr_cnt = 0
    ENDIF
   ENDIF
   IF (ui_tr_cnt=0)
    RETURN(- (10))
   ELSEIF (ui_tr_cnt=1)
    SET stat = alterlist(ui_query_eval_rec->qual,0)
    SET as_cd_cnt = 0
    SELECT INTO "NL:"
     FROM track_reference tr
     WHERE tr.tracking_group_cd=tr_gr_cd
      AND (tr.description=rs_0619->from_values.description)
     DETAIL
      as_cd_cnt = (as_cd_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,as_cd_cnt),
      ui_query_eval_rec->qual[as_cd_cnt].root_entity_attr = tr.assoc_code_value
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
     SET nodelete_ind = 1
     RETURN(- (20))
    ENDIF
    SET ui_tr_cd = evaluate_exec_ui_query(as_cd_cnt,temp_tbl_cnt,perm_col_cnt)
    IF ((ui_tr_cd=- (1)))
     RETURN(- (20))
    ELSEIF ((ui_tr_cd=- (2)))
     SET stat = alterlist(ui_query_eval_rec->qual,0)
     SET as_cd_cnt = 0
     SELECT INTO "NL:"
      FROM track_reference tr
      WHERE tr.tracking_group_cd=tr_gr_cd
       AND (tr.description=rs_0619->from_values.description)
       AND (tr.active_ind=rs_0619->from_values.active_ind)
      DETAIL
       as_cd_cnt = (as_cd_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,as_cd_cnt),
       ui_query_eval_rec->qual[as_cd_cnt].root_entity_attr = tr.assoc_code_value
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm_err->err_ind = 0
      SET nodelete_ind = 1
      RETURN(- (20))
     ENDIF
     SET ui_tr_cd = evaluate_exec_ui_query(as_cd_cnt,temp_tbl_cnt,perm_col_cnt)
     IF ((ui_tr_cd=- (1)))
      RETURN(- (20))
     ELSEIF ((ui_tr_cd=- (2)))
      RETURN(- (12))
     ELSEIF ((ui_tr_cd=- (3)))
      RETURN(0)
     ELSE
      RETURN(ui_tr_cd)
     ENDIF
    ELSEIF ((ui_tr_cd=- (3)))
     RETURN(0)
    ELSE
     RETURN(ui_tr_cd)
    ENDIF
   ELSE
    RETURN(- (11))
   ENDIF
 END ;Subroutine
 SUBROUTINE get_target_dta(source_dta_code)
   DECLARE ui_dta_cd = f8
   DECLARE ui_cv_cnt = i4
   DECLARE ui_cv_cd = f8
   DECLARE src_act_cd = f8
   DECLARE src_act_cnt = i4
   DECLARE sbr_ret_val = vc
   SET src_act_cnt = 0
   SET ui_cv_cnt = 0
   SET inc_prelink = dm2_ref_data_doc->pre_link_name
   SET inc_postlink = dm2_ref_data_doc->post_link_name
   SET dta_select = dm2_get_rdds_tname("DISCRETE_TASK_ASSAY")
   SET cv_select = dm2_get_rdds_tname("CODE_VALUE")
   SELECT INTO "NL:"
    dta.activity_type_cd
    FROM (parser(dta_select) dta)
    WHERE dta.task_assay_cd=source_dta_code
    DETAIL
     src_act_cd = dta.activity_type_cd
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
    SET nodelete_ind = 1
    RETURN(- (20))
   ENDIF
   IF (src_act_cd > 0)
    SET sbr_ret_val = select_merge_translate(cnvtstring(src_act_cd),"CODE_VALUE")
    IF (sbr_ret_val != "No Trans")
     SET ui_dta_cd = cnvtreal(sbr_ret_val)
     SET src_act_cnt = 1
    ELSE
     SET rpt_missing = report_missing("CODE_VALUE","CODE_VALUE",src_act_cd)
     IF (rpt_missing="ORPHAN")
      RETURN(- (21))
     ENDIF
     IF (rpt_missing="NOMV*")
      RETURN(- (22))
     ENDIF
    ENDIF
   ELSE
    SET ui_dta_cd = 0
    SET src_act_cnt = 1
   ENDIF
   IF (src_act_cnt > 0)
    SET stat = alterlist(ui_query_eval_rec->qual,0)
    SET ui_cv_cnt = 0
    SELECT INTO "NL:"
     FROM code_value c,
      discrete_task_assay dta,
      (parser(cv_select) cv1)
     PLAN (cv1
      WHERE cv1.code_value=source_dta_code)
      JOIN (c
      WHERE c.display_key=cv1.display_key
       AND c.display=cv1.display
       AND c.code_set=cv1.code_set)
      JOIN (dta
      WHERE dta.task_assay_cd=c.code_value
       AND dta.activity_type_cd=ui_dta_cd)
     DETAIL
      ui_cv_cnt = (ui_cv_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,ui_cv_cnt),
      ui_query_eval_rec->qual[ui_cv_cnt].root_entity_attr = c.code_value
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
     SET nodelete_ind = 1
     RETURN(- (20))
    ENDIF
    SET ui_cv_cd = evaluate_exec_ui_query(ui_cv_cnt,temp_tbl_cnt,perm_col_cnt)
    IF ((ui_cv_cd=- (1)))
     RETURN(- (20))
    ELSEIF ((ui_cv_cd=- (2)))
     SET stat = alterlist(ui_query_eval_rec->qual,0)
     SET ui_cv_cnt = 0
     SELECT INTO "NL:"
      FROM code_value c,
       discrete_task_assay dta,
       (parser(cv_select) cv1)
      PLAN (cv1
       WHERE cv1.code_value=source_dta_code)
       JOIN (c
       WHERE c.display_key=cv1.display_key
        AND c.display=cv1.display
        AND c.code_set=cv1.code_set
        AND c.active_ind=cv1.active_ind)
       JOIN (dta
       WHERE dta.task_assay_cd=c.code_value
        AND dta.activity_type_cd=ui_dta_cd)
      DETAIL
       ui_cv_cnt = (ui_cv_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,ui_cv_cnt),
       ui_query_eval_rec->qual[ui_cv_cnt].root_entity_attr = c.code_value
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm_err->err_ind = 0
      SET nodelete_ind = 1
      RETURN(- (20))
     ENDIF
     SET ui_cv_cd = evaluate_exec_ui_query(ui_cv_cnt,temp_tbl_cnt,perm_col_cnt)
     IF ((ui_cv_cd=- (1)))
      RETURN(- (20))
     ELSEIF ((ui_cv_cd=- (2)))
      RETURN(- (14))
     ELSEIF ((ui_cv_cd=- (3)))
      RETURN(0)
     ELSE
      RETURN(ui_cv_cd)
     ENDIF
    ELSEIF ((ui_cv_cd=- (3)))
     RETURN(0)
    ELSE
     RETURN(ui_cv_cd)
    ENDIF
   ELSE
    RETURN(- (13))
   ENDIF
 END ;Subroutine
 SUBROUTINE get_target_oefields(source_oe_code)
   DECLARE ui_oe_cd = f8
   DECLARE ui_cv_cnt = i4
   DECLARE ui_cv_cd = f8
   DECLARE src_cat_cd = f8
   DECLARE src_cat_cnt = i4
   DECLARE sbr_ret_val = vc
   SET src_cat_cnt = 0
   SET ui_cv_cnt = 0
   SET inc_prelink = dm2_ref_data_doc->pre_link_name
   SET inc_postlink = dm2_ref_data_doc->post_link_name
   SET oe_select = dm2_get_rdds_tname("ORDER_ENTRY_FIELDS")
   SET cv_select = dm2_get_rdds_tname("CODE_VALUE")
   SELECT INTO "NL:"
    oe.catalog_type_cd
    FROM (parser(oe_select) oe)
    WHERE oe.oe_field_id=source_oe_code
    DETAIL
     src_cat_cd = oe.catalog_type_cd
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
    SET nodelete_ind = 1
    RETURN(- (20))
   ENDIF
   IF (src_cat_cd > 0)
    SET sbr_ret_val = select_merge_translate(cnvtstring(src_cat_cd),"CODE_VALUE")
    IF (sbr_ret_val != "No Trans")
     SET ui_oe_cd = cnvtreal(sbr_ret_val)
     SET src_cat_cnt = 1
    ELSE
     SET rpt_missing = report_missing("CODE_VALUE","CODE_VALUE",src_cat_cd)
     IF (rpt_missing="ORPHAN")
      RETURN(- (21))
     ENDIF
     IF (rpt_missing="NOMV*")
      RETURN(- (22))
     ENDIF
    ENDIF
   ELSE
    SET ui_oe_cd = 0
    SET src_cat_cnt = 1
   ENDIF
   IF (src_cat_cnt > 0)
    SET stat = alterlist(ui_query_eval_rec->qual,0)
    SET ui_cv_cnt = 0
    SELECT INTO "NL:"
     FROM code_value c,
      order_entry_fields oe,
      (parser(cv_select) c1)
     PLAN (c1
      WHERE c1.code_value=source_oe_code)
      JOIN (c
      WHERE c.display_key=c1.display_key
       AND c.code_set=c1.code_set)
      JOIN (oe
      WHERE oe.oe_field_id=c.code_value
       AND oe.catalog_type_cd=ui_oe_cd)
     DETAIL
      ui_cv_cnt = (ui_cv_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,ui_cv_cnt),
      ui_query_eval_rec->qual[ui_cv_cnt].root_entity_attr = c.code_value
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
     SET nodelete_ind = 1
     RETURN(- (20))
    ENDIF
    SET ui_cv_cd = evaluate_exec_ui_query(ui_cv_cnt,temp_tbl_cnt,perm_col_cnt)
    IF ((ui_cv_cd=- (1)))
     RETURN(- (20))
    ELSEIF ((ui_cv_cd=- (2)))
     SET stat = alterlist(ui_query_eval_rec->qual,0)
     SET ui_cv_cnt = 0
     SELECT INTO "NL:"
      FROM code_value c,
       order_entry_fields oe,
       (parser(cv_select) c1)
      PLAN (c1
       WHERE c1.code_value=source_oe_code)
       JOIN (c
       WHERE c.display_key=c1.display_key
        AND c.code_set=c1.code_set
        AND c.active_ind=c1.active_ind)
       JOIN (oe
       WHERE oe.oe_field_id=c.code_value
        AND oe.catalog_type_cd=ui_oe_cd)
      DETAIL
       ui_cv_cnt = (ui_cv_cnt+ 1), stat = alterlist(ui_query_eval_rec->qual,ui_cv_cnt),
       ui_query_eval_rec->qual[ui_cv_cnt].root_entity_attr = c.code_value
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm_err->err_ind = 0
      SET nodelete_ind = 1
      RETURN(- (20))
     ENDIF
     SET ui_cv_cd = evaluate_exec_ui_query(ui_cv_cnt,temp_tbl_cnt,perm_col_cnt)
     IF ((ui_cv_cd=- (1)))
      RETURN(- (20))
     ELSEIF ((ui_cv_cd=- (2)))
      RETURN(- (16))
     ELSEIF ((ui_cv_cd=- (3)))
      RETURN(0)
     ELSE
      RETURN(ui_cv_cd)
     ENDIF
    ELSEIF ((ui_cv_cd=- (3)))
     RETURN(0)
    ELSE
     RETURN(ui_cv_cd)
    ENDIF
   ELSE
    RETURN(- (15))
   ENDIF
 END ;Subroutine
 SUBROUTINE get_value(sbr_table,sbr_column,sbr_origin)
   DECLARE sbr_tbl_cnt = i4
   DECLARE sbr_col_cnt = i4
   DECLARE sbr_data_type = vc
   DECLARE sbr_loop = i4
   DECLARE sbr_rs_name = vc
   DECLARE sbr_return = vc
   DECLARE dyn_origin = vc
   DECLARE sbr_error_name = vc
   SET sbr_tbl_cnt = 0
   SET sbr_col_cnt = 0
   SET sbr_tbl_cnt = locateval(sbr_loop,1,size(dm2_ref_data_doc->tbl_qual,5),sbr_table,
    dm2_ref_data_doc->tbl_qual[sbr_loop].table_name)
   IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script != "")
    AND (dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script != " "))
    SET sbr_error_name = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script
   ELSE
    SET sbr_error_name = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].table_name
   ENDIF
   SET sbr_col_cnt = locateval(sbr_loop,1,size(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual,5),
    sbr_column,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name)
   IF (sbr_col_cnt=0)
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = concat(sbr_error_name,": The column",sbr_column,
     " doesn't exist.")
    RETURN("NO_COLUMN")
   ENDIF
   IF (cnvtupper(sbr_origin)="FROM")
    SET dyn_origin = "FROM"
   ELSEIF (cnvtupper(sbr_origin)="TO")
    SET dyn_origin = "TO"
   ELSE
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = concat(sbr_error_name,": Invalid origin passed in.")
    RETURN("INVALID_ORIGIN")
   ENDIF
   SET sbr_data_type = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_col_cnt].data_type
   SET sbr_rs_name = concat(" RS_",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].suffix)
   CASE (sbr_data_type)
    OF "VC":
     CALL parser(concat("set sbr_return = ",sbr_rs_name,"->",dyn_origin,"_values.",
       sbr_column," go"),1)
    OF "DQ8":
     CALL parser(concat("set sbr_return = cnvtstring(",sbr_rs_name,"->",dyn_origin,"_values.",
       sbr_column,") go"),1)
    OF "I4":
     CALL parser(concat("set sbr_return = cnvtstring(",sbr_rs_name,"->",dyn_origin,"_values.",
       sbr_column,") go"),1)
    OF "F8":
     CALL parser(concat("set sbr_return = cnvtstring(",sbr_rs_name,"->",dyn_origin,"_values.",
       sbr_column,") go"),1)
    ELSE
     CALL parser(concat("set sbr_return = ",sbr_rs_name,"->",dyn_origin,"_values.",
       sbr_column," go"),1)
   ENDCASE
   FREE SET sbr_tbl_cnt
   FREE SET sbr_col_cnt
   FREE SET sbr_data_type
   FREE SET sbr_loop
   FREE SET sbr_rs_name
   FREE SET dyn_origin
   FREE SET sbr_error_name
   RETURN(sbr_return)
 END ;Subroutine
 SUBROUTINE get_nullind(sbr_table,sbr_column)
   DECLARE sbr_tbl_cnt = i4
   DECLARE sbr_col_cnt = i4
   DECLARE sbr_data_type = vc
   DECLARE sbr_loop = i4
   DECLARE sbr_rs_name = vc
   DECLARE sbr_return = i2
   DECLARE sbr_error_name = vc
   SET sbr_tbl_cnt = 0
   SET sbr_col_cnt = 0
   SET sbr_tbl_cnt = locateval(sbr_loop,1,size(dm2_ref_data_doc->tbl_qual,5),sbr_table,
    dm2_ref_data_doc->tbl_qual[sbr_loop].table_name)
   IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script != "")
    AND (dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script != " "))
    SET sbr_error_name = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script
   ELSE
    SET sbr_error_name = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].table_name
   ENDIF
   SET sbr_col_cnt = locateval(sbr_loop,1,size(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual,5),
    sbr_column,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name)
   IF (sbr_col_cnt=0)
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = concat(sbr_error_name,
     ": The column passed in to the GET_NULLIND sub isn't valid.")
    RETURN(- (1))
   ENDIF
   SET sbr_return = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_col_cnt].check_null
   FREE SET sbr_tbl_cnt
   FREE SET sbr_col_cnt
   FREE SET sbr_data_type
   FREE SET sbr_loop
   FREE SET sbr_rs_name
   FREE SET sbr_error_name
   RETURN(sbr_return)
 END ;Subroutine
 SUBROUTINE put_value(sbr_table,sbr_column,sbr_value)
   DECLARE sbr_tbl_cnt = i4
   DECLARE sbr_col_cnt = i4
   DECLARE sbr_data_type = vc
   DECLARE sbr_loop = i4
   DECLARE sbr_rs_name = vc
   DECLARE sbr_error_name = vc
   SET sbr_tbl_cnt = 0
   SET sbr_col_cnt = 0
   IF (sbr_value="")
    SET sbr_value = "0"
   ENDIF
   SET sbr_tbl_cnt = locateval(sbr_loop,1,size(dm2_ref_data_doc->tbl_qual,5),sbr_table,
    dm2_ref_data_doc->tbl_qual[sbr_loop].table_name)
   IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script != "")
    AND (dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script != " "))
    SET sbr_error_name = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script
   ELSE
    SET sbr_error_name = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].table_name
   ENDIF
   SET sbr_col_cnt = locateval(sbr_loop,1,size(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual,5),
    sbr_column,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name)
   IF (sbr_col_cnt=0)
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = concat(sbr_error_name,":",sbr_column,
     " doesn't exist on this table.")
    RETURN("NO_COLUMN")
   ENDIF
   SET sbr_data_type = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_col_cnt].data_type
   SET sbr_rs_name = concat(" RS_",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].suffix)
   SET dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_col_cnt].translated = 1
   CASE (sbr_data_type)
    OF "VC":
     CALL parser(concat("set ",sbr_rs_name,"->to_values.",sbr_column," = '",
       sbr_value,"' go"),1)
    OF "DQ8":
     CALL parser(concat("set ",sbr_rs_name,"->to_values.",sbr_column," = ",
       sbr_value," go"),1)
    OF "I4":
     CALL parser(concat("set ",sbr_rs_name,"->to_values.",sbr_column," = ",
       sbr_value," go"),1)
    OF "F8":
     CALL parser(concat("set ",sbr_rs_name,"->to_values.",sbr_column," = cnvtreal(sbr_value) go"),1)
    ELSE
     CALL parser(concat("set ",sbr_rs_name,"->to_values.",sbr_column," = '",
       sbr_value,"' go"),1)
   ENDCASE
   FREE SET sbr_tbl_cnt
   FREE SET sbr_col_cnt
   FREE SET sbr_data_type
   FREE SET sbr_loop
   FREE SET sbr_rs_name
   FREE SET sbr_error_name
 END ;Subroutine
 SUBROUTINE is_translated(sbr_table,sbr_column)
   DECLARE sbr_tbl_cnt = i4
   DECLARE sbr_col_cnt = i4
   DECLARE sbr_loop = i4
   DECLARE sbr_trans_ind = i2
   DECLARE sbr_err_msg = vc
   DECLARE sbr_rpt_orphan_ind = i2
   DECLARE skip_for_orphan_ind = i2
   SET sbr_trans_ind = 1
   SET sbr_tbl_cnt = 0
   SET sbr_col_cnt = 0
   SET sbr_tbl_cnt = locateval(sbr_loop,1,size(dm2_ref_data_doc->tbl_qual,5),sbr_table,
    dm2_ref_data_doc->tbl_qual[sbr_loop].table_name)
   IF (sbr_tbl_cnt=0)
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = concat(sbr_table," is not a valid table name.")
    SET sbr_trans_ind = 0
   ELSE
    IF (sbr_column="ALL")
     SET sbr_rpt_orphan_ind = 0
     SET sbr_col_cnt = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt
     FOR (sbr_loop = 1 TO sbr_col_cnt)
       IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].idcd_ind=1))
        IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].translated=0))
         SET skip_for_orphan_ind = 0
         DECLARE it_col_value = vc
         DECLARE it_fnd = i4
         DECLARE it_srch = i4
         DECLARE it_parent_col = vc
         DECLARE it_i_domain = vc
         DECLARE it_i_name = vc
         DECLARE it_data_type = vc
         DECLARE it_col_pos = i4
         DECLARE it_mult_cnt = i4
         DECLARE it_table = vc
         DECLARE it_column = vc
         DECLARE it_from = f8
         DECLARE it_missing = vc
         IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[sbr_loop].parent_entity_col != ""))
          SET it_fnd = locateval(it_srch,1,size(rdds_exception->qual,5),dm2_ref_data_doc->tbl_qual[
           sbr_tbl_cnt].col_qual[sbr_loop].column_name,rdds_exception->qual[it_srch].tab_col_name)
          IF (it_fnd > 0)
           IF ((rdds_exception->qual[it_fnd].tru_tab_name="INVALID")
            AND (rdds_exception->qual[it_fnd].tru_col_name="INVALID"))
            SET it_table = ""
            SET it_column = ""
            SET it_from = 0
           ELSE
            SET it_table = rdds_exception->qual[it_fnd].tru_tab_name
            SET it_column = rdds_exception->qual[it_fnd].tru_col_name
            CALL parser(concat("set it_from = RS_",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].suffix,
              "->from_values.",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name,
              " go"),1)
           ENDIF
          ELSE
           SET it_col_value = value(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].
            parent_entity_col)
           CALL parser(concat("set it_from = RS_",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].suffix,
             "->from_values.",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name,
             " go"),1)
           SET it_col_pos = locateval(it_srch,1,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt,
            it_col_value,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[it_srch].column_name)
           IF (it_col_pos > 0)
            SET it_data_type = value(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[it_col_pos].
             data_type)
            IF (it_data_type IN ("VC", "C*"))
             SET it_fnd = 0
             SET it_fnd = locateval(it_srch,1,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt,
              it_col_value,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[it_srch].column_name)
             IF (it_fnd != 0)
              CALL parser(concat("set it_parent_col = cnvtupper(RS_",dm2_ref_data_doc->tbl_qual[
                sbr_tbl_cnt].suffix,"->from_values.",it_col_value,") go"),1)
              IF (it_parent_col != ""
               AND it_parent_col != " ")
               SET it_parent_col = find_p_e_col(it_parent_col,sbr_loop)
              ELSE
               SET it_i_domain = concat("RDDS_PE_ABBREV:",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].
                table_name)
               SET it_i_name = concat(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].
                column_name,":",it_parent_col)
               SELECT INTO "NL:"
                FROM dm_info d
                WHERE d.info_domain=it_i_domain
                 AND d.info_name=it_i_name
                DETAIL
                 it_parent_col = d.info_char
                WITH nocounter
               ;end select
              ENDIF
             ENDIF
            ENDIF
           ENDIF
           IF (it_parent_col != "INVALIDTABLE"
            AND it_parent_col != "")
            SET it_table = it_parent_col
            SET it_fnd = locateval(it_srch,1,dguc_reply->rs_tbl_cnt,it_table,dguc_reply->dtd_hold[
             it_srch].tbl_name)
            IF (it_fnd != 0)
             IF ((dguc_reply->dtd_hold[it_fnd].pk_cnt >= 1))
              SET it_srch = 0
              FOR (it_mult_cnt = 1 TO dguc_reply->dtd_hold[it_fnd].pk_cnt)
                IF ((((dguc_reply->dtd_hold[it_fnd].pk_hold[it_mult_cnt].pk_name="*ID")) OR ((((
                dguc_reply->dtd_hold[it_fnd].pk_hold[it_mult_cnt].pk_name="*CD")) OR ((dguc_reply->
                dtd_hold[it_fnd].pk_hold[it_mult_cnt].pk_name="CODE_VALUE"))) )) )
                 IF ((((dguc_reply->dtd_hold[it_fnd].pk_hold[it_mult_cnt].pk_name="*ID")) OR ((
                 dguc_reply->dtd_hold[it_fnd].pk_hold[it_mult_cnt].pk_name="CODE_VALUE"))) )
                  SET it_column = dguc_reply->dtd_hold[it_fnd].pk_hold[it_mult_cnt].pk_name
                  SET it_srch = (it_srch+ 1)
                 ENDIF
                ENDIF
              ENDFOR
             ENDIF
             IF (it_srch > 1)
              SET it_column = ""
             ENDIF
            ENDIF
           ENDIF
          ENDIF
         ELSEIF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].root_entity_name != ""))
          SET it_fnd = locateval(it_srch,1,size(rdds_exception->qual,5),dm2_ref_data_doc->tbl_qual[
           sbr_tbl_cnt].col_qual[sbr_loop].column_name,rdds_exception->qual[it_srch].tab_col_name)
          IF (it_fnd > 0)
           IF ((rdds_exception->qual[it_fnd].tru_tab_name="INVALID")
            AND (rdds_exception->qual[it_fnd].tru_col_name="INVALID"))
            SET it_table = ""
            SET it_column = ""
            SET it_from = 0
           ELSE
            SET it_table = rdds_exception->qual[it_fnd].tru_tab_name
            SET it_column = rdds_exception->qual[it_fnd].tru_col_name
            CALL parser(concat("set it_from = RS_",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].suffix,
              "->from_values.",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name,
              " go"),1)
           ENDIF
          ELSE
           SET it_table = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].root_entity_name
           SET it_column = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].
           root_entity_attr
           CALL parser(concat("set it_from = RS_",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].suffix,
             "->from_values.",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name,
             " go"),1)
          ENDIF
         ENDIF
         SET it_missing = ""
         IF (it_table != ""
          AND it_from != 0
          AND (((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].root_entity_name !=
         dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].table_name)) OR ((((dm2_ref_data_doc->tbl_qual[
         sbr_tbl_cnt].col_qual[sbr_loop].root_entity_attr != dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].
         col_qual[sbr_loop].column_name)) OR ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[
         sbr_loop].pk_ind != 1))) )) )
          SET it_srch = locateval(it_mult_cnt,1,size(dm2_ref_data_doc->tbl_qual,5),it_table,
           dm2_ref_data_doc->tbl_qual[it_mult_cnt].table_name)
          IF (it_srch=0)
           SET it_mult_cnt = temp_tbl_cnt
           SET it_srch = fill_rs("TABLE",it_table)
           SET temp_tbl_cnt = it_mult_cnt
          ENDIF
          IF ((((dm2_ref_data_doc->tbl_qual[it_srch].mergeable_ind=0)) OR ((dm2_ref_data_doc->
          tbl_qual[it_srch].reference_ind=0)
           AND  NOT ((dm2_ref_data_doc->tbl_qual[it_srch].table_name IN ("ACCESSION", "ADDRESS",
          "PHONE", "PERSON", "PERSON_NAME",
          "PERSON_ALIAS", "DCP_ENTITY_RELTN", "LONG_TEXT", "LONG_BLOB", "ACCOUNT",
          "AT_ACCT_RELTN"))))) )
           SET drdm_mini_loop_status = "NOMV04"
           SET it_missing = "NOMV04"
           CALL orphan_child_tab(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].table_name,"NOMV04","",0.0)
          ELSE
           SET it_missing = report_missing(trim(it_table),trim(it_column),it_from)
          ENDIF
         ENDIF
         IF (it_missing="ORPHAN")
          IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].defining_attribute_ind=1))
           SET sbr_rpt_orphan_ind = 1
           SET drdm_no_trans_ind = 1
           SET dm2_ref_data_reply->error_ind = 1
           SET dm2_ref_data_reply->error_msg = concat(it_missing," - ",dm2_ref_data_doc->tbl_qual[
            sbr_tbl_cnt].col_qual[sbr_loop].column_name)
           SET sbr_err_msg = concat(it_missing," - ",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].
            col_qual[sbr_loop].column_name)
           SET sbr_loop = sbr_col_cnt
          ELSE
           SET dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].translated = 1
           CALL parser(concat("set rs_",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].suffix,"->to_values.",
             dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name," = 0 go"),1)
           SET skip_for_orphan_ind = 1
          ENDIF
         ELSEIF (it_missing="OLDVER")
          SET dm2_ref_data_reply->error_ind = 1
          SET dm2_ref_data_reply->error_msg = it_missing
          SET sbr_err_msg = concat("This log_id ",
           "wasn't translated because there was no translation for the ",dm2_ref_data_doc->tbl_qual[
           sbr_tbl_cnt].col_qual[sbr_loop].column_name," column.")
          SET sbr_loop = sbr_col_cnt
         ELSEIF (it_missing="NOMV*")
          SET drdm_no_trans_ind = 1
          SET dm2_ref_data_reply->error_ind = 1
          SET dm2_ref_data_reply->error_msg = it_missing
          SET sbr_err_msg = concat("This log_id ",
           "wasn't translated because there was no translation for the ",dm2_ref_data_doc->tbl_qual[
           sbr_tbl_cnt].col_qual[sbr_loop].column_name," column.")
          SET sbr_loop = sbr_col_cnt
         ELSE
          SET drdm_no_trans_ind = 1
          IF (get_err_val(null)=0)
           SET dm2_ref_data_reply->error_ind = 1
           SET dm2_ref_data_reply->error_msg = concat("This log_id ",
            "wasn't translated because not all columns were translated.")
          ENDIF
          SET sbr_err_msg = concat("This log_id ",
           "wasn't translated because there was no translation for the ",dm2_ref_data_doc->tbl_qual[
           sbr_tbl_cnt].col_qual[sbr_loop].column_name," column.")
         ENDIF
         IF (skip_for_orphan_ind=0)
          CALL echo("")
          CALL echo("")
          CALL echo(sbr_err_msg)
          CALL echo("")
          CALL echo("")
          CALL merge_audit("FAILREASON",sbr_err_msg,2)
          IF (drdm_error_out_ind=1)
           ROLLBACK
          ENDIF
          SET sbr_trans_ind = 0
         ENDIF
        ENDIF
       ENDIF
       FREE SET it_col_value
       FREE SET it_fnd
       FREE SET it_srch
       FREE SET it_parent_col
       FREE SET it_i_domain
       FREE SET it_i_name
       FREE SET it_data_type
       FREE SET it_col_pos
       FREE SET it_mult_cnt
       FREE SET it_table
       FREE SET it_column
       FREE SET it_from
       FREE SET it_missing
     ENDFOR
     FOR (sbr_loop = 1 TO sbr_col_cnt)
       IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].exception_flg=9)
        AND (dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].translated=0))
        SET drdm_no_trans_ind = 1
        SET dm2_ref_data_reply->error_ind = 1
        SET dm2_ref_data_reply->error_msg = concat("This log_id ",
         "wasn't translated because not all columns were translated.")
        SET sbr_err_msg = concat("This log_id ",
         "wasn't translated because there was no translation for the ",dm2_ref_data_doc->tbl_qual[
         sbr_tbl_cnt].col_qual[sbr_loop].column_name," column.")
        SET sbr_trans_ind = 0
       ENDIF
     ENDFOR
    ELSEIF (sbr_column="UNIQUE")
     SET sbr_col_cnt = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt
     FOR (sbr_loop = 1 TO sbr_col_cnt)
       IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].unique_ident_ind=1))
        IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].idcd_ind=1))
         IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].translated=0))
          SET dm2_ref_data_reply->error_ind = 1
          SET dm2_ref_data_reply->error_msg = concat("This log_id ",
           "wasn't translated because of the ",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[
           sbr_loop].column_name," column.")
          SET sbr_trans_ind = 0
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
    ELSE
     SET sbr_col_cnt = locateval(sbr_loop,1,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt,
      sbr_column,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name)
     IF (sbr_col_cnt=0)
      SET dm2_ref_data_reply->error_ind = 1
      SET dm2_ref_data_reply->error_msg = concat(sbr_column," is not on the ",sbr_table," table.")
      SET sbr_trans_ind = 0
     ELSE
      IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_col_cnt].translated=0))
       SET sbr_trans_ind = 0
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   FREE SET sbr_tbl_cnt
   FREE SET sbr_col_cnt
   FREE SET sbr_loop
   RETURN(sbr_trans_ind)
 END ;Subroutine
 SUBROUTINE get_seq(sbr_table,sbr_column)
   DECLARE sbr_tbl_cnt = i4
   DECLARE sbr_col_cnt = i4
   DECLARE sbr_loop = i4
   DECLARE sbr_ret_val = f8
   DECLARE sbr_error_name = vc
   SET sbr_tbl_cnt = 0
   SET sbr_col_cnt = 0
   SET sbr_tbl_cnt = locateval(sbr_loop,1,size(dm2_ref_data_doc->tbl_qual,5),sbr_table,
    dm2_ref_data_doc->tbl_qual[sbr_loop].table_name)
   IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script != "")
    AND (dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script != " "))
    SET sbr_error_name = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script
   ELSE
    SET sbr_error_name = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].table_name
   ENDIF
   SET sbr_col_cnt = locateval(sbr_loop,1,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt,sbr_column,
    dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name)
   IF (sbr_col_cnt=0)
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = concat(sbr_error_name,":",sbr_column," is not on the ",
     sbr_table,
     " table.")
    CALL echo("")
    CALL echo("")
    CALL echo(dm2_ref_data_reply->error_msg)
    CALL echo("")
    CALL echo("")
    RETURN(- (1))
   ENDIF
   IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_col_cnt].sequence_name != ""))
    CALL parser("select into 'nl:' y = seq(",0)
    CALL parser(concat(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_col_cnt].sequence_name,
      ", nextval) from dual detail sbr_ret_val = y with nocounter go"),1)
    SET new_seq_ind = 1
   ELSE
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = concat(sbr_error_name,":",sbr_column,
     " does not have a valid sequence")
    CALL echo("")
    CALL echo("")
    CALL echo(dm2_ref_data_reply->error_msg)
    CALL echo("")
    CALL echo("")
    RETURN(- (1))
   ENDIF
   FREE SET sbr_tbl_cnt
   FREE SET sbr_col_cnt
   FREE SET sbr_loop
   FREE SET sbr_error_name
   RETURN(sbr_ret_val)
 END ;Subroutine
 SUBROUTINE get_col_pos(sbr_table,sbr_column)
   DECLARE sbr_tbl_cnt = i4
   DECLARE sbr_col_cnt = i4
   DECLARE sbr_loop = i4
   DECLARE sbr_error_name = vc
   SET sbr_tbl_cnt = 0
   SET sbr_col_cnt = 0
   SET sbr_tbl_cnt = locateval(sbr_loop,1,size(dm2_ref_data_doc->tbl_qual,5),sbr_table,
    dm2_ref_data_doc->tbl_qual[sbr_loop].table_name)
   IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script != "")
    AND (dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script != " "))
    SET sbr_error_name = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script
   ELSE
    SET sbr_error_name = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].table_name
   ENDIF
   SET sbr_col_cnt = locateval(sbr_loop,1,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt,sbr_column,
    dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name)
   IF (sbr_col_cnt=0)
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = concat(sbr_error_name,":",sbr_column," is not on the ",
     sbr_table,
     " table.")
   ENDIF
   FREE SET sbr_tbl_cnt
   FREE SET sbr_loop
   RETURN(sbr_col_cnt)
 END ;Subroutine
 SUBROUTINE get_primary_key(sbr_table)
   DECLARE sbr_col_cnt = i4
   DECLARE sbr_return = vc
   DECLARE sbr_tbl_cnt = i4
   DECLARE sbr_loop = i4
   SET sbr_return = ""
   SET sbr_tbl_cnt = 0
   SET sbr_col_cnt = 0
   SET sbr_tbl_cnt = locateval(sbr_loop,1,size(dm2_ref_data_doc->tbl_qual,5),sbr_table,
    dm2_ref_data_doc->tbl_qual[sbr_loop].table_name)
   IF (sbr_tbl_cnt=0)
    RETURN("")
   ENDIF
   SET sbr_col_cnt = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = value(sbr_col_cnt))
    DETAIL
     IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[d.seq].column_name=dm2_ref_data_doc->
     tbl_qual[sbr_tbl_cnt].col_qual[d.seq].root_entity_attr)
      AND (dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].table_name=dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt]
     .col_qual[d.seq].root_entity_name))
      sbr_return = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[d.seq].column_name
     ENDIF
    WITH nocounter
   ;end select
   FREE SET sbr_col_cnt
   FREE SET sbr_tbl_cnt
   FREE SET sbr_loop
   RETURN(sbr_return)
 END ;Subroutine
 SUBROUTINE check_ui_exist(sbr_table_name)
   DECLARE sbr_return = i2
   DECLARE sbr_tbl_cnt = i4
   DECLARE sbr_loop = i4
   DECLARE sbr_col_cnt = i4
   SET sbr_tbl_cnt = locateval(sbr_loop,1,size(dm2_ref_data_doc->tbl_qual,5),sbr_table_name,
    dm2_ref_data_doc->tbl_qual[sbr_loop].table_name)
   IF (sbr_tbl_cnt=0)
    RETURN(0)
   ENDIF
   SET sbr_return = 0
   SET sbr_col_cnt = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = value(sbr_col_cnt))
    DETAIL
     IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].unique_ident_ind=1))
      sbr_return = 1
     ENDIF
    WITH nocounter
   ;end select
   FREE SET sbr_col_cnt
   FREE SET sbr_tbl_cnt
   FREE SET sbr_loop
   RETURN(sbr_return)
 END ;Subroutine
 SUBROUTINE evaluate_rpt_missing(erm_missing_val)
   IF (erm_missing_val IN ("ORPHAN", "OLDVER", "BADLOG", "NOMV*"))
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = erm_missing_val
   ENDIF
 END ;Subroutine
 SUBROUTINE get_err_val(null)
  FOR (sbr_cust_loop = 1 TO drdm_log_types->cnt)
    IF ((dm2_ref_data_reply->error_msg=patstring(drdm_log_types->qual[sbr_cust_loop].type))
     AND sbr_err_val=0)
     SET sbr_err_val = sbr_cust_loop
    ENDIF
  ENDFOR
  RETURN(sbr_err_val)
 END ;Subroutine
 IF (validate(usi_request->newname,"/")="/")
  FREE RECORD usi_request
  RECORD usi_request(
    1 newname = vc
    1 tmp = vc
    1 temp1 = vc
    1 addtemp = f8
    1 fchr = f8
    1 ftmp = f8
    1 sqllen = i4
    1 qual[*]
      2 str_from = vc
      2 str_to = vc
  )
 ENDIF
 IF (validate(usi_reply->err_ind,2)=2)
  FREE RECORD usi_reply
  RECORD usi_reply(
    1 err_ind = i2
    1 err_msg = vc
  )
 ENDIF
 DECLARE drfn_quit = i2
 SET dm_err->eproc = "Finding rows w/ log_type = 'INSRC'"
 CALL disp_msg(" ",dm_err->logfile,0)
 SET drfn_quit = 0
 WHILE (drfn_quit=0)
   EXECUTE dm2_rdds_nologs_child
 ENDWHILE
#exit_nologs
 FREE SET drfn_quit
END GO
