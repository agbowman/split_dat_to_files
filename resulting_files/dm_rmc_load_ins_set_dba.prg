CREATE PROGRAM dm_rmc_load_ins_set:dba
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
 IF (check_logfile("dm_rmc_load_ins",".log","dm_rmc_load_ins_set LOG FILE...") != 1)
  SET dm_err->err_ind = 1
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_load
 ENDIF
 DECLARE drlis_file_ind = i2 WITH protect, noconstant(0)
 DECLARE drlis_temp = vc WITH protect, noconstant("")
 DECLARE drlis_run_time = i4 WITH protect, noconstant(0)
 DECLARE drlis_ins_meaning = vc WITH protect, noconstant("")
 DECLARE drlis_description = vc WITH protect, noconstant("")
 DECLARE drlis_table_name = vc WITH protect, noconstant("")
 DECLARE drlis_ltr_id = f8 WITH protect, noconstant(0.0)
 DECLARE drlis_ins_id = f8 WITH protect, noconstant(0.0)
 DECLARE drlis_authorized_ind = i2 WITH protect, noconstant(0)
 DECLARE drlis_loop = i4 WITH protect, noconstant(0)
 DECLARE drlis_run_order = i4 WITH protect, noconstant(0)
 DECLARE drlis_env_id = f8 WITH protect, noconstant(0.0)
 IF ( NOT (validate(drlis_ovr_upload_ind)))
  DECLARE drlis_ovr_upload_ind = i2 WITH protect, noconstant(0)
 ENDIF
 DECLARE drlis_extract_tag(det_start_tag=vc,det_stop_tag=vc,det_rs=vc(ref)) = vc
 DECLARE sys_context() = c4000
 FREE RECORD drlis_ins
 RECORD drlis_ins(
   1 cnt = i4
   1 qual[*]
     2 line = vc
 ) WITH protect
 SET modify maxvarlen 268435456
 SET dm_err->eproc = "Starting DM_RMC_LOAD_INS_SET..."
 SET dm_load_reply->ins_meaning = "N/A"
 SET dm_load_reply->description = "N/A"
 SET dm_load_reply->ins_table_name = "N/A"
 IF ((dm_load_request->file_name > " "))
  SET drlis_file_ind = findfile(value(dm_load_request->file_name),4)
  IF (drlis_file_ind=0)
   SET dm_err->err_ind = 1
   SET dm_err->emsg = concat("The ",dm_load_request->file_name,
    " file could not be found, or script did not have read access on it.")
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_load
  ENDIF
 ELSE
  SET dm_err->err_ind = 1
  SET dm_err->emsg = concat("The DM_LOAD_REQUEST->FILE_NAME item did not contain a file_name.")
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_load
 ENDIF
 SET dm_load_request->file_name = replace(dm_load_request->file_name,"CCLUSERDIR:","")
 SET dm_err->eproc = "Reading file contents into record structure"
 SET logical drlis_fname value(dm_load_request->file_name)
 FREE DEFINE rtl2
 DEFINE rtl2 "drlis_fname"
 SELECT INTO "NL:"
  t.line
  FROM rtl2t t
  HEAD REPORT
   stat = alterlist(drlis_ins->qual,10), drlis_ins->cnt = 0
  DETAIL
   drlis_temp = t.line
   IF (size(trim(drlis_temp)) > 0)
    drlis_ins->cnt = (drlis_ins->cnt+ 1)
    IF (mod(drlis_ins->cnt,10)=1
     AND (drlis_ins->cnt >= 10))
     stat = alterlist(drlis_ins->qual,(drlis_ins->cnt+ 9))
    ENDIF
    drlis_ins->qual[drlis_ins->cnt].line = t.line
   ENDIF
  FOOT REPORT
   stat = alterlist(drlis_ins->qual,drlis_ins->cnt)
  WITH nocounter, maxcol = 32768
 ;end select
 IF (check_error("Reading file") != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_load
 ENDIF
 SET dm_err->eproc = "Searching for embedded tags"
 SET drlis_temp = drlis_extract_tag("<INS_RUN_TIME>","</INS_RUN_TIME>",drlis_ins)
 IF (drlis_temp="RDDS_NO_TAG_ERROR")
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "The INS_RUN_TIME embedded tag, was not found in the file."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_load
 ELSEIF (isnumeric(drlis_temp) IN (1, 2))
  IF (cnvtint(drlis_temp) IN (0, 1, 2, 3, 4,
  5, 6))
   SET drlis_run_time = cnvtint(drlis_temp)
   SET dm_load_reply->run_time_flag = drlis_run_time
  ELSE
   SET dm_err->err_ind = 1
   SET dm_err->emsg = "The value embedded between the INS_RUN_TIME tags, was not between 0 and 6"
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_load
  ENDIF
 ELSE
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "The value embedded between the INS_RUN_TIME tags, was not numeric"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_load
 ENDIF
 SET drlis_temp = drlis_extract_tag("<INS_MEANING>","</INS_MEANING>",drlis_ins)
 IF (((drlis_temp="RDDS_NO_TAG_ERROR") OR (drlis_temp <= " ")) )
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "The INS_MEANING embedded tag, was not found in the file or was blank."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_load
 ELSEIF (size(drlis_temp) > 50)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "The INS_MEANING embedded tag, should be under 50 characters in length."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_load
 ELSE
  SET drlis_ins_meaning = drlis_temp
  SET dm_load_reply->ins_meaning = drlis_ins_meaning
 ENDIF
 SET drlis_temp = drlis_extract_tag("<DESCRIPTION>","</DESCRIPTION>",drlis_ins)
 IF (((drlis_temp="RDDS_NO_TAG_ERROR") OR (drlis_temp <= " ")) )
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "The DESCRIPTION embedded tag, was not found in the file or was blank."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_load
 ELSEIF (size(drlis_temp) > 500)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "The DESCRIPTION embedded tag, should be under 500 characters in length."
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_load
 ELSE
  SET drlis_description = drlis_temp
  SET dm_load_reply->description = drlis_description
 ENDIF
 SET drlis_temp = drlis_extract_tag("<INS_TABLE_NAME>","</INS_TABLE_NAME>",drlis_ins)
 IF (drlis_temp != "RDDS_NO_TAG_ERROR")
  IF (((size(drlis_temp) > 30) OR (size(drlis_temp)=0)) )
   SET dm_err->err_ind = 1
   SET dm_err->emsg =
   "The INS_TABLE_NAME embedded tag, should be a TABLE_NAME under 30 characters in length."
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_load
  ELSE
   SET drlis_table_name = drlis_temp
   SET dm_load_reply->ins_table_name = drlis_table_name
  ENDIF
 ENDIF
 SET drlis_temp = drlis_extract_tag("<INS_RUN_ORDER>","</INS_RUN_ORDER>",drlis_ins)
 IF (drlis_temp="RDDS_NO_TAG_ERROR")
  SET drlis_run_order = - (100)
 ELSEIF (isnumeric(drlis_temp) IN (1, 2))
  SET drlis_run_order = cnvtint(drlis_temp)
  SET dm_load_reply->run_order = drlis_run_order
 ELSE
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "The value embedded between the INS_RUN_ORDER tags, was not numeric"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_load
 ENDIF
 SELECT INTO "NL:"
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="DM_ENV_ID"
  DETAIL
   drlis_env_id = d.info_number
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc) != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_load
 ENDIF
 SELECT INTO "nl:"
  v_str = sys_context("CERNER","RDDS_AUTHORIZED_IND",4000)
  FROM dual
  DETAIL
   IF (isnumeric(v_str) IN (1, 2))
    drlis_authorized_ind = cnvtint(v_str)
   ELSE
    drlis_authorized_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc) != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_load
 ENDIF
 IF (drlis_authorized_ind > 0
  AND drlis_ovr_upload_ind=0)
  SELECT INTO "nl:"
   FROM dm_rdds_event_log l
   WHERE l.rdds_event_key="INSTRUCTIONSETDELETED"
    AND l.cur_environment_id=drlis_env_id
    AND l.event_reason=drlis_ins_meaning
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc) != 0)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_load
  ELSEIF (curqual > 0)
   SET dm_err->eproc = concat("Instruction Set ",drlis_ins_meaning,
    " has been removed and will not be uploaded again.")
   CALL disp_msg(" ",dm_err->logfile,0)
   GO TO exit_load
  ENDIF
 ENDIF
 SET dm_err->eproc = "Loading instruction information into tables"
 SELECT INTO "NL:"
  FROM dm_refchg_instruction d
  WHERE d.ins_meaning=drlis_ins_meaning
  DETAIL
   drlis_ltr_id = d.instruction_text_id, drlis_ins_id = d.dm_refchg_instruction_id
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc) != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_load
 ENDIF
 IF (drlis_ins_id=0.0)
  SELECT INTO "NL:"
   y = seq(dm_clinical_seq,nextval)
   FROM dual d
   DETAIL
    drlis_ins_id = y
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc) != 0)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_load
  ENDIF
 ENDIF
 IF (drlis_ltr_id=0.0)
  SELECT INTO "NL:"
   y = seq(long_data_seq,nextval)
   FROM dual d
   DETAIL
    drlis_ltr_id = y
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc) != 0)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_load
  ENDIF
 ENDIF
 SET drlis_temp = ""
 FOR (drlis_loop = 1 TO drlis_ins->cnt)
   SET drlis_temp = concat(drlis_temp,drlis_ins->qual[drlis_loop].line,char(10))
 ENDFOR
 SET dm_err->eproc = "Update/Insert data into LONG_TEXT_REFERENCE"
 UPDATE  FROM long_text_reference
  SET parent_entity_id = drlis_ins_id, parent_entity_name = "DM_REFCHG_INSTRUCTION", long_text =
   drlis_temp,
   updt_cnt = (updt_cnt+ 1), updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = reqinfo->updt_id
  WHERE long_text_id=drlis_ltr_id
  WITH nocounter
 ;end update
 IF (check_error(dm_err->eproc) != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_load
 ENDIF
 IF (curqual=0)
  INSERT  FROM long_text_reference
   SET parent_entity_id = drlis_ins_id, parent_entity_name = "DM_REFCHG_INSTRUCTION", long_text =
    drlis_temp,
    updt_cnt = 0, updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = reqinfo->updt_id,
    long_text_id = drlis_ltr_id
   WITH nocounter
  ;end insert
  IF (check_error(dm_err->eproc) != 0)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_load
  ENDIF
 ENDIF
 SET dm_err->eproc = "Update/Insert data into DM_REFCHG_INSTRUCTION"
 UPDATE  FROM dm_refchg_instruction
  SET ins_meaning = drlis_ins_meaning, description = drlis_description, run_time_flag =
   drlis_run_time,
   run_order = evaluate(drlis_run_order,- (100),null,drlis_run_order), table_name = drlis_table_name,
   instruction_text_id = drlis_ltr_id,
   authorized_ind = drlis_authorized_ind, updt_cnt = (updt_cnt+ 1), updt_id = reqinfo->updt_id,
   updt_dt_tm = cnvtdatetime(curdate,curtime3)
  WHERE dm_refchg_instruction_id=drlis_ins_id
  WITH nocounter
 ;end update
 IF (check_error(dm_err->eproc) != 0)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_load
 ENDIF
 IF (curqual=0)
  INSERT  FROM dm_refchg_instruction
   SET ins_meaning = drlis_ins_meaning, description = drlis_description, run_time_flag =
    drlis_run_time,
    run_order = evaluate(drlis_run_order,- (100),null,drlis_run_order), table_name = drlis_table_name,
    instruction_text_id = drlis_ltr_id,
    authorized_ind = drlis_authorized_ind, updt_cnt = 0, updt_id = reqinfo->updt_id,
    updt_dt_tm = cnvtdatetime(curdate,curtime3), dm_refchg_instruction_id = drlis_ins_id
   WITH nocounter
  ;end insert
  IF (check_error(dm_err->eproc) != 0)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   GO TO exit_load
  ENDIF
 ENDIF
 SET dm_err->eproc = "Logging event information"
 SET stat = alterlist(auto_ver_request->qual,1)
 SET auto_ver_request->qual[1].rdds_event = "Instruction Set Uploaded"
 SET auto_ver_request->qual[1].paired_environment_id = 0.0
 SET auto_ver_request->qual[1].event_reason = drlis_ins_meaning
 SET auto_ver_request->qual[1].cur_environment_id = drlis_env_id
 EXECUTE dm_rmc_auto_verify_setup
 IF ((auto_ver_reply->status="F"))
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET stat = initrec(auto_ver_request)
  SET stat = initrec(auto_ver_reply)
  SET dm_err->err_ind = 1
  GO TO exit_load
 ELSE
  SET stat = initrec(auto_ver_request)
  SET stat = initrec(auto_ver_reply)
 ENDIF
 SUBROUTINE drlis_extract_tag(det_start_tag,det_stop_tag,det_rs)
   DECLARE det_loop = i4 WITH protect, noconstant(0)
   DECLARE det_start_line = i4 WITH protect, noconstant(0)
   DECLARE det_stop_line = i4 WITH protect, noconstant(0)
   DECLARE det_start_pos = i4 WITH protect, noconstant(0)
   DECLARE det_stop_pos = i4 WITH protect, noconstant(0)
   DECLARE det_temp_pos = i4 WITH protect, noconstant(0)
   DECLARE det_temp = vc WITH protect, noconstant("")
   FOR (det_loop = 1 TO det_rs->cnt)
     SET det_temp_pos = findstring(det_start_tag,cnvtupper(det_rs->qual[det_loop].line),1,0)
     IF (det_temp_pos > 0)
      SET det_start_pos = det_temp_pos
      SET det_start_line = det_loop
     ENDIF
     SET det_temp_pos = findstring(det_stop_tag,cnvtupper(det_rs->qual[det_loop].line),1,0)
     IF (det_temp_pos > 0)
      SET det_stop_pos = det_temp_pos
      SET det_stop_line = det_loop
     ENDIF
   ENDFOR
   IF (det_start_pos > 0
    AND det_stop_pos > 0)
    IF (det_start_line != det_stop_line)
     FOR (det_loop = det_start_line TO det_stop_line)
       IF (det_loop=det_start_line)
        SET det_temp = substring((det_start_pos+ size(det_start_tag)),size(det_rs->qual[det_loop].
          line),det_rs->qual[det_loop].line)
       ELSEIF (det_loop=det_stop_line)
        SET det_temp = concat(det_temp,substring(1,(det_stop_pos - 1),det_rs->qual[det_loop].line))
       ELSE
        SET det_temp = concat(det_temp,det_rs->qual[det_loop].line)
       ENDIF
     ENDFOR
    ELSE
     SET det_temp = substring((det_start_pos+ size(det_start_tag)),((det_stop_pos - det_start_pos) -
      size(det_start_tag)),det_rs->qual[det_start_line].line)
    ENDIF
   ELSE
    RETURN("RDDS_NO_TAG_ERROR")
   ENDIF
   RETURN(det_temp)
 END ;Subroutine
#exit_load
 IF ((dm_err->err_ind=1))
  ROLLBACK
  SET dm_load_reply->status = "F"
  SET dm_load_reply->status_msg = dm_err->emsg
 ELSE
  SET dm_load_reply->status = "S"
  COMMIT
 ENDIF
END GO
