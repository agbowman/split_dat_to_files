CREATE PROGRAM dm_rmc_manage_ins_set:dba
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
 IF (check_logfile("dm_rmc_manage_is",".log","dm_rmc_manage_ins_set LOG FILE...") != 1)
  SET dm_err->err_ind = 1
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_manage
 ENDIF
 DECLARE drmis_main(dm_rs=vc(ref)) = null
 DECLARE drmis_load_is(dli_rs=vc(ref)) = null
 DECLARE drmis_del_is(ddi_rs=vc(ref)) = null
 DECLARE drmis_run_is(dri_rs=vc(ref)) = i2
 DECLARE drmis_view_is(dvi_rs=vc(ref)) = null
 DECLARE drmis_show_details(dsd_rs=vc(ref),dsd_rec=vc(ref),dsd_pos=i4) = null
 DECLARE drmis_check_error_gui(dce_rs=vc(ref),ceg_proc=vc,ceg_menu_screen=vc,ceg_add_info=vc(ref)) =
 i2
 DECLARE drmis_disp_header(ddh_rs=vc(ref),ddh_screen=vc) = null
 DECLARE drmis_sort_rec(dsr_rec=vc(ref),dsr_option=vc) = null
 FREE RECORD drmis_master
 RECORD drmis_master(
   1 cur_env_id = f8
   1 cur_env_name = vc
 )
 FREE RECORD drmis_add_info
 RECORD drmis_add_info(
   1 cnt = i4
   1 qual[*]
     2 data = vc
 )
 SET dm_err->eproc = "Starting DM_RMC_MANAGE_INS_SET..."
 CALL drmis_main(drmis_master)
 SUBROUTINE drmis_main(dm_rs)
   DECLARE dm_done_ind = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Starting DRMIS_MAIN subroutine..."
   WHILE (dm_done_ind=0)
     SET message = window
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,5,132)
     IF ((dm_rs->cur_env_id=0.0))
      SELECT INTO "NL:"
       FROM dm_info di,
        dm_environment de
       WHERE di.info_domain="DATA MANAGEMENT"
        AND di.info_name="DM_ENV_ID"
        AND de.environment_id=di.info_number
       DETAIL
        dm_rs->cur_env_id = di.info_number, dm_rs->cur_env_name = de.environment_name
       WITH nocounter
      ;end select
      IF (drmis_check_error_gui(dm_rs,dm_err->eproc,"MANAGE INSTRUCTION SET",drmis_add_info) != 0)
       RETURN(null)
      ENDIF
     ENDIF
     CALL drmis_disp_header(dm_rs,"*** MANAGE INSTRUCTION SET ***")
     CALL text(7,3,"Please choose from the following options:")
     CALL text(9,3,"0 Exit")
     CALL text(10,3,"1 Load Instruction Set")
     CALL text(11,3,"2 Delete Instruction Set")
     CALL text(12,3,"3 Run Instruction Set")
     CALL text(13,3,"4 View Instruction Sets")
     SET accept = nopatcheck
     CALL accept(7,50,"9",0
      WHERE curaccept IN (1, 2, 3, 4, 0))
     SET accept = patcheck
     CASE (curaccept)
      OF 1:
       CALL drmis_load_is(dm_rs)
      OF 2:
       CALL drmis_del_is(dm_rs)
      OF 3:
       SET dm_done_ind = drmis_run_is(dm_rs)
      OF 4:
       CALL drmis_view_is(dm_rs)
      OF 0:
       SET dm_done_ind = 1
     ENDCASE
     IF ((dm_err->err_ind=1))
      SET dm_err->err_ind = 0
     ENDIF
   ENDWHILE
   SET message = nowindow
 END ;Subroutine
 SUBROUTINE drmis_load_is(dli_rs)
   DECLARE dli_done_ind = i2 WITH protect, noconstant(0)
   DECLARE dli_file_name = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Starting DRMIS_LOAD_IS subroutine..."
   WHILE (dli_done_ind=0)
     SET message = window
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,5,132)
     CALL drmis_disp_header(dli_rs,"*** LOAD INSTRUCTION SET ***")
     CALL text(7,3,
      "Please input the file path where the instruction set file is located (0 to Exit):")
     SET accept = nopatcheck
     CALL accept(8,30,"P(70);C")
     SET accept = patcheck
     SET dli_file_name = trim(curaccept)
     IF (dli_file_name="0")
      SET dli_done_ind = 1
     ELSE
      SET dm_load_request->file_name = dli_file_name
      EXECUTE dm_rmc_load_ins_set
      SET drmis_add_info->cnt = 4
      SET stat = alterlist(drmis_add_info->qual,4)
      SET drmis_add_info->qual[1].data = concat("Instruction Name: ",dm_load_reply->ins_meaning)
      IF (size(dm_load_reply->description) > 110)
       SET drmis_add_info->qual[2].data = concat("Description: ",substring(1,110,dm_load_reply->
         description),"...")
      ELSE
       SET drmis_add_info->qual[2].data = concat("Description: ",dm_load_reply->description)
      ENDIF
      SET drmis_add_info->qual[3].data = concat("Run Time Flag: ",trim(cnvtstring(dm_load_reply->
         run_time_flag)))
      SET drmis_add_info->qual[4].data = concat("Table Name: ",dm_load_reply->ins_table_name)
      IF (drmis_check_error_gui(dli_rs,dm_err->eproc,"*** LOAD INSTRUCTION SET ***",drmis_add_info)
       != 0)
       SET stat = initrec(drmis_add_info)
       RETURN(null)
      ELSE
       CALL text(10,3,drmis_add_info->qual[1].data)
       CALL text(11,3,drmis_add_info->qual[2].data)
       CALL text(12,3,drmis_add_info->qual[3].data)
       CALL text(13,3,drmis_add_info->qual[4].data)
       CALL text(15,3,
        "The instruction set has been successfully uploaded. Press enter to return to main menu.")
       CALL accept(15,91,"P;E"," ")
       SET dli_done_ind = 1
      ENDIF
     ENDIF
   ENDWHILE
   SET message = nowindow
   SET stat = initrec(drmis_add_info)
 END ;Subroutine
 SUBROUTINE drmis_del_is(ddi_rs)
   DECLARE ddi_done_ind = i2 WITH protect, noconstant(0)
   DECLARE ddi_ins_meaning = vc WITH protect, noconstant("")
   DECLARE ddi_ins_cnt = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Starting DRMIS_DEL_IS subroutine..."
   WHILE (ddi_done_ind=0)
     SET message = window
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,5,132)
     CALL drmis_disp_header(ddi_rs,"*** DELETE INSTRUCTION SET ***")
     SELECT INTO "NL:"
      cnt = count(*)
      FROM dm_refchg_instruction d
      DETAIL
       ddi_ins_cnt = cnt
      WITH nocounter
     ;end select
     IF (drmis_check_error_gui(ddi_rs,dm_err->eproc,"*** DELETE INSTRUCTION SET ***",drmis_add_info)
      != 0)
      RETURN(null)
     ENDIF
     IF (ddi_ins_cnt=0)
      CALL text(15,3,"The are no instruction sets to be removed. Press enter to return to main menu."
       )
      CALL accept(15,82,"P;E"," ")
      SET ddi_done_ind = 1
     ELSE
      CALL text(7,3,"Please input the instruction set name that you want to delete.")
      CALL text(8,3,"(0 to Exit):")
      SET help =
      SELECT INTO "nl:"
       instruction_name = di.ins_meaning
       FROM dm_refchg_instruction di
       WHERE ((1=1) UNION (
       (SELECT
        "0"
        FROM dual
        WHERE 1=1)))
      ;end select
      SET accept = nopatcheck
      CALL accept(8,16,"P(50);CF","0")
      SET accept = patcheck
      SET ddi_ins_meaning = trim(curaccept)
      SET help = off
      IF (ddi_ins_meaning="0")
       SET ddi_done_ind = 1
      ELSE
       CALL text(12,3,concat("Are you sure you want to remove the '",ddi_ins_meaning,
         "' instruction set? (Y/N):"))
       CALL accept(12,(66+ size(ddi_ins_meaning)),"P;CU","Y"
        WHERE curaccept IN ("Y", "N"))
       IF (curaccept="Y")
        EXECUTE dm_rmc_del_ins_set ddi_ins_meaning
        IF (drmis_check_error_gui(ddi_rs,dm_err->eproc,"*** DELETE INSTRUCTION SET ***",
         drmis_add_info) != 0)
         RETURN(null)
        ELSE
         CALL text(15,3,
          "The instruction set has been successfully removed. Press enter to return to main menu.")
         CALL accept(15,90,"P;E"," ")
         SET ddi_done_ind = 1
        ENDIF
       ENDIF
      ENDIF
     ENDIF
   ENDWHILE
   SET message = nowindow
 END ;Subroutine
 SUBROUTINE drmis_run_is(dri_rs)
   DECLARE dri_done_ind = i2 WITH protect, noconstant(0)
   DECLARE dri_ins_meaning = vc WITH protect, noconstant("")
   DECLARE dri_ins_cnt = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Starting DRMIS_RUN_IS subroutine..."
   WHILE (dri_done_ind=0)
     SET message = window
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,5,132)
     CALL drmis_disp_header(dri_rs,"*** RUN INSTRUCTION SET ***")
     SELECT INTO "NL:"
      cnt = count(*)
      FROM dm_refchg_instruction d
      DETAIL
       dri_ins_cnt = cnt
      WITH nocounter
     ;end select
     IF (drmis_check_error_gui(dri_rs,dm_err->eproc,"*** RUN INSTRUCTION SET ***",drmis_add_info) !=
     0)
      RETURN(0)
     ENDIF
     IF (dri_ins_cnt=0)
      CALL text(15,3,"The are no instruction sets to be ran. Press enter to return to main menu.")
      CALL accept(15,78,"P;E"," ")
      SET dri_done_ind = 1
     ELSE
      CALL text(7,3,"Please input the instruction set name that you want to run.")
      CALL text(8,3,"(0 to Exit):")
      SET help =
      SELECT INTO "nl:"
       instruction_name = di.ins_meaning
       FROM dm_refchg_instruction di
       WHERE ((1=1) UNION (
       (SELECT
        "0"
        FROM dual
        WHERE 1=1)))
      ;end select
      SET accept = nopatcheck
      CALL accept(8,16,"P(50);CF","0")
      SET accept = patcheck
      SET dri_ins_meaning = trim(curaccept)
      SET help = off
      IF (dri_ins_meaning="0")
       SET dri_done_ind = 1
      ELSE
       CALL text(12,3,concat(
         "Would you like to run this instruction set in diagnostic mode, so that no commits are ",
         "issued during the run?"))
       CALL text(13,87,"[(Y)es / (N)o / e(X)it]")
       CALL accept(12,112,"P;CU","Y"
        WHERE curaccept IN ("Y", "N", "X"))
       IF (curaccept="Y")
        SET dm_run_request->diagnostic_ind = 1
       ELSEIF (curaccept="N")
        SET dm_run_request->diagnostic_ind = 0
       ELSE
        SET dri_done_ind = 1
       ENDIF
       IF (dri_done_ind=0)
        SET dm_run_request->ins_meaning = dri_ins_meaning
        IF ((dm_run_request->diagnostic_ind=1))
         SET message = nowindow
        ENDIF
        EXECUTE dm_rmc_run_ins_set
        IF ((dm_run_request->diagnostic_ind=1))
         SET message = window
         CALL clear(1,1)
         SET width = 132
         CALL box(1,1,5,132)
         CALL drmis_disp_header(dri_rs,"*** RUN INSTRUCTION SET ***")
        ENDIF
        SET drmis_add_info->cnt = 2
        SET stat = alterlist(drmis_add_info->qual,2)
        SET drmis_add_info->qual[1].data = concat("Instruction Name: ",dm_run_reply->ins_meaning)
        SET drmis_add_info->qual[2].data = concat("Log File: ",dm_run_reply->log_file)
        IF (drmis_check_error_gui(dri_rs,dm_err->eproc,"*** RUN INSTRUCTION SET ***",drmis_add_info)
         != 0)
         SET dm_run_request->diagnostic_ind = 0
         SET stat = initrec(drmis_add_info)
         RETURN(0)
        ELSE
         CALL text(15,3,drmis_add_info->qual[1].data)
         CALL text(16,3,drmis_add_info->qual[2].data)
         IF ((dm_run_reply->status="S"))
          IF ((dm_run_request->diagnostic_ind=1))
           CALL text(17,3,concat("The instruction set has been successfully ran. ",
             "Press enter to exit the menu to perform testing."))
           CALL text(18,3,concat(
             "You can now exit the menu to perform necessary validation.  Issue a 'COMMIT GO' ",
             "if you want to keep"))
           CALL text(19,3,concat(
             "the changes made by the instruction set.  Issue a 'ROLLBACK GO' if you do not ",
             "want to keep the changes."))
           CALL accept(17,99,"P;E"," ")
          ELSE
           CALL text(17,3,
            "The instruction set has been successfully ran. Press enter to return to the main menu.")
           CALL accept(17,89,"P;E"," ")
          ENDIF
         ELSE
          SET dm_run_request->diagnostic_ind = 0
          CALL text(17,3,substring(1,128,dm_run_reply->status_msg))
          CALL text(18,3,"Press enter to return to the main menu.")
          CALL accept(18,43,"P;E"," ")
         ENDIF
         SET dri_done_ind = 1
        ENDIF
       ENDIF
      ENDIF
     ENDIF
   ENDWHILE
   SET message = nowindow
   SET stat = initrec(drmis_add_info)
   RETURN(dm_run_request->diagnostic_ind)
 END ;Subroutine
 SUBROUTINE drmis_view_is(dvi_rs)
   FREE RECORD dvi_rec
   RECORD dvi_rec(
     1 ins_cnt = i4
     1 ins_qual[*]
       2 ins_meaning = vc
       2 run_time_flag = i4
       2 run_time_mean = vc
       2 description = vc
       2 auth_ind = i2
       2 last_pass_dt_tm = dq8
       2 last_fail_dt_tm = dq8
       2 last_upload_dt_tm = dq8
       2 event_cnt = i4
       2 event_qual[*]
         3 event_dt_tm = dq8
         3 event_name = vc
         3 diagnostic_ind = i2
         3 detail_msg = vc
         3 log_file = vc
   )
   DECLARE dvi_idx = i4 WITH protect, noconstant(0)
   DECLARE dvi_event_idx = i4 WITH protect, noconstant(0)
   DECLARE dvi_loop = i4 WITH protect, noconstant(0)
   DECLARE dvi_disp_line = vc WITH protect, noconstant("")
   DECLARE dvi_max_loop = i4 WITH protect, noconstant(0)
   DECLARE dvi_min_loop = i4 WITH protect, noconstant(0)
   DECLARE dvi_done_ind = i2 WITH protect, noconstant(0)
   DECLARE dvi_accept = vc WITH protect, noconstant("")
   DECLARE dvi_rs_pos = i4 WITH protect, noconstant(0)
   DECLARE dvi_sort_string = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Starting DRMIS_VIEW_IS subroutine..."
   SET message = window
   CALL clear(1,1)
   SET width = 132
   CALL box(1,1,5,132)
   CALL drmis_disp_header(dvi_rs,"*** VIEW INSTRUCTION SETS ***")
   SELECT INTO "NL:"
    FROM dm_refchg_instruction d
    WHERE 1=1
    DETAIL
     dvi_rec->ins_cnt = (dvi_rec->ins_cnt+ 1), stat = alterlist(dvi_rec->ins_qual,dvi_rec->ins_cnt),
     dvi_rec->ins_qual[dvi_rec->ins_cnt].ins_meaning = d.ins_meaning,
     dvi_rec->ins_qual[dvi_rec->ins_cnt].run_time_flag = d.run_time_flag
     IF (d.run_time_flag=0)
      dvi_rec->ins_qual[dvi_rec->ins_cnt].run_time_mean = "None"
     ELSEIF (d.run_time_flag=1)
      dvi_rec->ins_qual[dvi_rec->ins_cnt].run_time_mean = "Beg Event"
     ELSEIF (d.run_time_flag=2)
      dvi_rec->ins_qual[dvi_rec->ins_cnt].run_time_mean = "Mover"
     ELSEIF (d.run_time_flag=3)
      dvi_rec->ins_qual[dvi_rec->ins_cnt].run_time_mean = "Cutover"
     ELSEIF (d.run_time_flag=4)
      dvi_rec->ins_qual[dvi_rec->ins_cnt].run_time_mean = "Cutover"
     ELSEIF (d.run_time_flag=5)
      dvi_rec->ins_qual[dvi_rec->ins_cnt].run_time_mean = "End Event"
     ELSE
      dvi_rec->ins_qual[dvi_rec->ins_cnt].run_time_mean = "Unknown"
     ENDIF
     dvi_rec->ins_qual[dvi_rec->ins_cnt].description = d.description, dvi_rec->ins_qual[dvi_rec->
     ins_cnt].auth_ind = d.authorized_ind
    WITH nocounter
   ;end select
   IF (drmis_check_error_gui(dvi_rs,dm_err->eproc,"*** VIEW INSTRUCTION SETS ***",drmis_add_info) !=
   0)
    RETURN(null)
   ENDIF
   SELECT INTO "NL:"
    FROM dm_rdds_event_log l,
     dm_rdds_event_detail d
    WHERE (l.cur_environment_id=dvi_rs->cur_env_id)
     AND l.rdds_event_key IN ("INSTRUCTIONSETDELETED", "INSTRUCTIONSETUPLOADED",
    "INSTRUCTIONSETRUNSUCCESS", "INSTRUCTIONSETRUNFAILED")
     AND d.dm_rdds_event_log_id=outerjoin(l.dm_rdds_event_log_id)
    ORDER BY l.event_reason, l.dm_rdds_event_log_id DESC, d.event_detail_value
    HEAD l.event_reason
     dvi_idx = locateval(dvi_idx,1,dvi_rec->ins_cnt,l.event_reason,dvi_rec->ins_qual[dvi_idx].
      ins_meaning)
     IF (dvi_idx=0)
      dvi_rec->ins_cnt = (dvi_rec->ins_cnt+ 1), stat = alterlist(dvi_rec->ins_qual,dvi_rec->ins_cnt),
      dvi_rec->ins_qual[dvi_rec->ins_cnt].ins_meaning = l.event_reason,
      dvi_rec->ins_qual[dvi_rec->ins_cnt].run_time_flag = 0, dvi_rec->ins_qual[dvi_rec->ins_cnt].
      run_time_mean = "N/A", dvi_rec->ins_qual[dvi_rec->ins_cnt].description = "N/A",
      dvi_rec->ins_qual[dvi_rec->ins_cnt].auth_ind = 0, dvi_idx = dvi_rec->ins_cnt
     ENDIF
    HEAD l.dm_rdds_event_log_id
     dvi_rec->ins_qual[dvi_idx].event_cnt = (dvi_rec->ins_qual[dvi_idx].event_cnt+ 1), stat =
     alterlist(dvi_rec->ins_qual[dvi_idx].event_qual,dvi_rec->ins_qual[dvi_idx].event_cnt),
     dvi_event_idx = dvi_rec->ins_qual[dvi_idx].event_cnt
    DETAIL
     dvi_rec->ins_qual[dvi_idx].event_qual[dvi_event_idx].event_name = l.rdds_event, dvi_rec->
     ins_qual[dvi_idx].event_qual[dvi_event_idx].event_dt_tm = l.event_dt_tm
     IF (l.rdds_event_key="INSTRUCTIONSETRUNSUCCESS")
      IF ((((dvi_rec->ins_qual[dvi_idx].last_pass_dt_tm=0.0)) OR ((dvi_rec->ins_qual[dvi_idx].
      last_pass_dt_tm < dvi_rec->ins_qual[dvi_idx].event_qual[dvi_event_idx].event_dt_tm))) )
       dvi_rec->ins_qual[dvi_idx].last_pass_dt_tm = l.event_dt_tm
      ENDIF
     ENDIF
     IF (l.rdds_event_key="INSTRUCTIONSETUPLOADED")
      IF ((((dvi_rec->ins_qual[dvi_idx].last_upload_dt_tm=0.0)) OR ((dvi_rec->ins_qual[dvi_idx].
      last_upload_dt_tm < dvi_rec->ins_qual[dvi_idx].event_qual[dvi_event_idx].event_dt_tm))) )
       dvi_rec->ins_qual[dvi_idx].last_upload_dt_tm = l.event_dt_tm
      ENDIF
     ENDIF
     IF (l.rdds_event_key="INSTRUCTIONSETRUNFAILED")
      IF ((((dvi_rec->ins_qual[dvi_idx].last_fail_dt_tm=0.0)) OR ((dvi_rec->ins_qual[dvi_idx].
      last_fail_dt_tm < dvi_rec->ins_qual[dvi_idx].event_qual[dvi_event_idx].event_dt_tm))) )
       dvi_rec->ins_qual[dvi_idx].last_fail_dt_tm = l.event_dt_tm
      ENDIF
     ENDIF
     IF (d.event_detail1_txt="DIAGNOSTIC MODE")
      dvi_rec->ins_qual[dvi_idx].event_qual[dvi_event_idx].diagnostic_ind = 1
     ELSEIF (d.event_detail1_txt="INS_SET_INFO")
      IF ((dvi_rec->ins_qual[dvi_idx].event_qual[dvi_event_idx].detail_msg > " "))
       dvi_rec->ins_qual[dvi_idx].event_qual[dvi_event_idx].detail_msg = concat(dvi_rec->ins_qual[
        dvi_idx].event_qual[dvi_event_idx].detail_msg," ",d.event_detail3_txt)
      ELSE
       dvi_rec->ins_qual[dvi_idx].event_qual[dvi_event_idx].detail_msg = trim(d.event_detail3_txt,3)
      ENDIF
     ELSE
      IF ((dvi_rec->ins_qual[dvi_idx].event_qual[dvi_event_idx].detail_msg > " "))
       dvi_rec->ins_qual[dvi_idx].event_qual[dvi_event_idx].detail_msg = concat(d.event_detail3_txt,
        " ",dvi_rec->ins_qual[dvi_idx].event_qual[dvi_event_idx].detail_msg)
      ELSE
       dvi_rec->ins_qual[dvi_idx].event_qual[dvi_event_idx].detail_msg = trim(d.event_detail3_txt,3)
      ENDIF
      dvi_rec->ins_qual[dvi_idx].event_qual[dvi_event_idx].log_file = d.event_detail1_txt
     ENDIF
    WITH nocounter
   ;end select
   IF (drmis_check_error_gui(dvi_rs,dm_err->eproc,"*** VIEW INSTRUCTION SETS ***",drmis_add_info) !=
   0)
    RETURN(null)
   ENDIF
   CALL drmis_sort_rec(dvi_rec,"N")
   SET dvi_sort_string = notrim(" Sorted by Instruction Name ")
   CALL text(7,1,"No.")
   CALL text(7,5,"INSTRUCTION NAME")
   CALL text(7,57,"RUN TIME")
   CALL text(7,67,"LAST ADDED DT_TM")
   CALL text(7,89,"LAST PASS DT_TM")
   CALL text(7,111,"LAST FAIL DT_TM")
   SET dvi_min_loop = 1
   IF ((dvi_rec->ins_cnt > 14))
    SET dvi_max_loop = 14
   ELSE
    SET dvi_max_loop = dvi_rec->ins_cnt
   ENDIF
   WHILE (dvi_done_ind=0)
     SET message = window
     CALL clear(1,1)
     SET width = 132
     CALL box(1,1,5,132)
     CALL text(5,85,dvi_sort_string)
     CALL drmis_disp_header(dvi_rs,"*** VIEW INSTRUCTION SETS ***")
     CALL text(7,1,"No.")
     CALL text(7,5,"INSTRUCTION NAME")
     CALL text(7,57,"RUN TIME")
     CALL text(7,68,"LAST UPLOAD DT_TM")
     CALL text(7,90,"LAST PASS DT_TM")
     CALL text(7,112,"LAST FAIL DT_TM")
     CALL text(8,1,fillstring(132,"-"))
     IF (dvi_min_loop > 1)
      CALL text(8,85," More data up... ")
     ENDIF
     FOR (dvi_loop = 1 TO ((dvi_max_loop - dvi_min_loop)+ 1))
       SET dvi_rs_pos = ((dvi_min_loop - 1)+ dvi_loop)
       CALL text((dvi_loop+ 8),1,trim(cnvtstring(dvi_rs_pos)))
       CALL text((dvi_loop+ 8),5,dvi_rec->ins_qual[dvi_rs_pos].ins_meaning)
       CALL text((dvi_loop+ 8),57,dvi_rec->ins_qual[dvi_rs_pos].run_time_mean)
       IF ((dvi_rec->ins_qual[dvi_rs_pos].last_upload_dt_tm=0.0))
        CALL text((dvi_loop+ 8),68,"N/A")
       ELSE
        CALL text((dvi_loop+ 8),68,format(dvi_rec->ins_qual[dvi_rs_pos].last_upload_dt_tm,
          "DD-MMM-YYYY HH:MM:SS;;D"))
       ENDIF
       IF ((dvi_rec->ins_qual[dvi_rs_pos].last_pass_dt_tm=0.0))
        CALL text((dvi_loop+ 8),90,"N/A")
       ELSE
        CALL text((dvi_loop+ 8),90,format(dvi_rec->ins_qual[dvi_rs_pos].last_pass_dt_tm,
          "DD-MMM-YYYY HH:MM:SS;;D"))
       ENDIF
       IF ((dvi_rec->ins_qual[dvi_rs_pos].last_fail_dt_tm=0.0))
        CALL text((dvi_loop+ 8),112,"N/A")
       ELSE
        CALL text((dvi_loop+ 8),112,format(dvi_rec->ins_qual[dvi_rs_pos].last_fail_dt_tm,
          "DD-MMM-YYYY HH:MM:SS;;D"))
       ENDIF
     ENDFOR
     CALL text(23,1,fillstring(132,"-"))
     IF ((dvi_max_loop < dvi_rec->ins_cnt))
      CALL text(23,85," More data down... ")
     ENDIF
     CALL text(24,1,concat("Command Options: __ (",trim(cnvtstring(dvi_min_loop))," - ",trim(
        cnvtstring(dvi_max_loop)),
       " for instruction detail), (E)xit, Sort by (N)ame, (R)un time, (U)pload date, (P)ass date, (F)ail date"
       ))
     CALL video(n)
     SET accept = scroll
     CALL accept(24,18,"XXX;CUS")
     CASE (curscroll)
      OF 0:
       SET dvi_accept = curaccept
       IF (dvi_accept="E")
        SET dvi_done_ind = 1
       ELSEIF (dvi_accept="N")
        CALL drmis_sort_rec(dvi_rec,"N")
        SET dvi_sort_string = notrim(" Sorted by Instruction Name ")
       ELSEIF (dvi_accept="R")
        CALL drmis_sort_rec(dvi_rec,"R")
        SET dvi_sort_string = notrim(" Sorted by Run Time ")
       ELSEIF (dvi_accept="U")
        CALL drmis_sort_rec(dvi_rec,"U")
        SET dvi_sort_string = notrim(" Sorted by Upload date ")
       ELSEIF (dvi_accept="P")
        CALL drmis_sort_rec(dvi_rec,"P")
        SET dvi_sort_string = notrim(" Sorted by Pass date ")
       ELSEIF (dvi_accept="F")
        CALL drmis_sort_rec(dvi_rec,"F")
        SET dvi_sort_string = notrim(" Sorted by Fail date ")
       ELSEIF (isnumeric(dvi_accept)=1)
        IF (cnvtint(dvi_accept) >= dvi_min_loop
         AND cnvtint(dvi_accept) <= dvi_max_loop)
         CALL drmis_show_details(dvi_rs,dvi_rec,cnvtint(dvi_accept))
        ELSE
         CALL text(24,1,fillstring(132," "))
         CALL text(24,1,"Invalid Entry, Try again.")
         CALL pause(3)
        ENDIF
       ELSE
        CALL text(24,1,fillstring(132," "))
        CALL text(24,1,"Invalid Entry, Try again.")
        CALL pause(3)
       ENDIF
      OF 1:
      OF 6:
       IF ((dvi_max_loop < dvi_rec->ins_cnt))
        SET dvi_min_loop = (dvi_max_loop+ 1)
        IF ((dvi_rec->ins_cnt > (dvi_min_loop+ 13)))
         SET dvi_max_loop = (dvi_min_loop+ 13)
        ELSE
         SET dvi_max_loop = dvi_rec->ins_cnt
        ENDIF
       ENDIF
      OF 2:
      OF 5:
       IF (dvi_min_loop > 1
        AND dvi_min_loop <= 15)
        SET dvi_min_loop = 1
        IF ((dvi_rec->ins_cnt > 14))
         SET dvi_max_loop = 14
        ELSE
         SET dvi_max_loop = dvi_rec->ins_cnt
        ENDIF
       ELSEIF (dvi_min_loop > 15)
        SET dvi_min_loop = (dvi_min_loop - 14)
        SET dvi_max_loop = (dvi_min_loop+ 13)
       ENDIF
     ENDCASE
   ENDWHILE
   SET message = nowindow
 END ;Subroutine
 SUBROUTINE drmis_show_details(dsd_rs,dsd_rec,dsd_pos)
   DECLARE dsd_loop = i4 WITH protect, noconstant(0)
   DECLARE dsd_temp_str = vc WITH protect, noconstant("")
   SET dm_err->eproc = "Starting DRMIS_VIEW_IS subroutine..."
   SET message = nowindow
   SELECT INTO mine
    FROM dual d
    HEAD REPORT
     col 45, "*** VIEW INSTRUCTION SET DETAIL ***", row + 1,
     col 1, "DESCRIPTION: ", col 14,
     dsd_rec->ins_qual[dsd_pos].description, row + 1
    DETAIL
     row + 1, col 1, "EVENT NAME",
     col 29, "EVENT_DT_TM", col 51,
     "DIAGNOSTIC", col 63, "LOG_FILE",
     col 95, "DETAIL_MESSAGE"
     FOR (dsd_loop = 1 TO dsd_rec->ins_qual[dsd_pos].event_cnt)
       row + 1, col 1, dsd_rec->ins_qual[dsd_pos].event_qual[dsd_loop].event_name,
       col 29, dsd_temp_str = format(dsd_rec->ins_qual[dsd_pos].event_qual[dsd_loop].event_dt_tm,
        "DD-MMM-YYYY HH:MM:SS;;D"), dsd_temp_str,
       col 55
       IF ((dsd_rec->ins_qual[dsd_pos].event_qual[dsd_loop].event_name IN (
       "Instruction Set Run Success", "Instruction Set Run Failed")))
        IF ((dsd_rec->ins_qual[dsd_pos].event_qual[dsd_loop].diagnostic_ind=1))
         "Yes"
        ELSE
         "No"
        ENDIF
       ENDIF
       col 63, dsd_rec->ins_qual[dsd_pos].event_qual[dsd_loop].log_file, col 95,
       dsd_rec->ins_qual[dsd_pos].event_qual[dsd_loop].detail_msg
     ENDFOR
    WITH nocounter, maxcol = 4000
   ;end select
   IF (drmis_check_error_gui(dsd_rs,dm_err->eproc,"*** VIEW INSTRUCTION SET DETAIL ***",
    drmis_add_info) != 0)
    RETURN(null)
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drmis_sort_rec(dsr_rec,dsr_option)
   DECLARE dsr_loop = i4 WITH protect, noconstant(0)
   DECLARE dsr_loop1 = i4 WITH protect, noconstant(0)
   DECLARE dsr_loop2 = i4 WITH protect, noconstant(0)
   IF (dsr_option="N"
    AND (dsr_rec->ins_cnt > 1))
    SET stat = alterlist(dsr_rec->ins_qual,(dsr_rec->ins_cnt+ 1))
    FOR (dsr_loop1 = 1 TO (dsr_rec->ins_cnt - 1))
      FOR (dsr_loop2 = 1 TO (dsr_rec->ins_cnt - 1))
        IF ((dsr_rec->ins_qual[dsr_loop2].ins_meaning > dsr_rec->ins_qual[(dsr_loop2+ 1)].ins_meaning
        ))
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].ins_meaning = dsr_rec->ins_qual[dsr_loop2].
         ins_meaning
         SET dsr_rec->ins_qual[dsr_loop2].ins_meaning = dsr_rec->ins_qual[(dsr_loop2+ 1)].ins_meaning
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].ins_meaning = dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)]
         .ins_meaning
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].run_time_flag = dsr_rec->ins_qual[dsr_loop2].
         run_time_flag
         SET dsr_rec->ins_qual[dsr_loop2].run_time_flag = dsr_rec->ins_qual[(dsr_loop2+ 1)].
         run_time_flag
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].run_time_flag = dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1
         )].run_time_flag
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].run_time_mean = dsr_rec->ins_qual[dsr_loop2].
         run_time_mean
         SET dsr_rec->ins_qual[dsr_loop2].run_time_mean = dsr_rec->ins_qual[(dsr_loop2+ 1)].
         run_time_mean
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].run_time_mean = dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1
         )].run_time_mean
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].description = dsr_rec->ins_qual[dsr_loop2].
         description
         SET dsr_rec->ins_qual[dsr_loop2].description = dsr_rec->ins_qual[(dsr_loop2+ 1)].description
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].description = dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)]
         .description
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].auth_ind = dsr_rec->ins_qual[dsr_loop2].
         auth_ind
         SET dsr_rec->ins_qual[dsr_loop2].auth_ind = dsr_rec->ins_qual[(dsr_loop2+ 1)].auth_ind
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].auth_ind = dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].
         auth_ind
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].last_pass_dt_tm = dsr_rec->ins_qual[dsr_loop2].
         last_pass_dt_tm
         SET dsr_rec->ins_qual[dsr_loop2].last_pass_dt_tm = dsr_rec->ins_qual[(dsr_loop2+ 1)].
         last_pass_dt_tm
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].last_pass_dt_tm = dsr_rec->ins_qual[(dsr_rec->ins_cnt
         + 1)].last_pass_dt_tm
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].last_fail_dt_tm = dsr_rec->ins_qual[dsr_loop2].
         last_fail_dt_tm
         SET dsr_rec->ins_qual[dsr_loop2].last_fail_dt_tm = dsr_rec->ins_qual[(dsr_loop2+ 1)].
         last_fail_dt_tm
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].last_fail_dt_tm = dsr_rec->ins_qual[(dsr_rec->ins_cnt
         + 1)].last_fail_dt_tm
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].last_upload_dt_tm = dsr_rec->ins_qual[dsr_loop2
         ].last_upload_dt_tm
         SET dsr_rec->ins_qual[dsr_loop2].last_upload_dt_tm = dsr_rec->ins_qual[(dsr_loop2+ 1)].
         last_upload_dt_tm
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].last_upload_dt_tm = dsr_rec->ins_qual[(dsr_rec->
         ins_cnt+ 1)].last_upload_dt_tm
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_cnt = dsr_rec->ins_qual[dsr_loop2].
         event_cnt
         SET dsr_rec->ins_qual[dsr_loop2].event_cnt = dsr_rec->ins_qual[(dsr_loop2+ 1)].event_cnt
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].event_cnt = dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].
         event_cnt
         SET stat = alterlist(dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual,dsr_rec->ins_qual[(
          dsr_rec->ins_cnt+ 1)].event_cnt)
         FOR (dsr_loop = 1 TO dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_cnt)
           SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].event_dt_tm = dsr_rec->
           ins_qual[dsr_loop2].event_qual[dsr_loop].event_dt_tm
           SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].event_name = dsr_rec->
           ins_qual[dsr_loop2].event_qual[dsr_loop].event_name
           SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].diagnostic_ind = dsr_rec
           ->ins_qual[dsr_loop2].event_qual[dsr_loop].diagnostic_ind
           SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].detail_msg = dsr_rec->
           ins_qual[dsr_loop2].event_qual[dsr_loop].detail_msg
           SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].log_file = dsr_rec->
           ins_qual[dsr_loop2].event_qual[dsr_loop].log_file
         ENDFOR
         SET stat = alterlist(dsr_rec->ins_qual[dsr_loop2].event_qual,dsr_rec->ins_qual[dsr_loop2].
          event_cnt)
         FOR (dsr_loop = 1 TO dsr_rec->ins_qual[dsr_loop2].event_cnt)
           SET dsr_rec->ins_qual[dsr_loop2].event_qual[dsr_loop].event_dt_tm = dsr_rec->ins_qual[(
           dsr_loop2+ 1)].event_qual[dsr_loop].event_dt_tm
           SET dsr_rec->ins_qual[dsr_loop2].event_qual[dsr_loop].event_name = dsr_rec->ins_qual[(
           dsr_loop2+ 1)].event_qual[dsr_loop].event_name
           SET dsr_rec->ins_qual[dsr_loop2].event_qual[dsr_loop].diagnostic_ind = dsr_rec->ins_qual[(
           dsr_loop2+ 1)].event_qual[dsr_loop].diagnostic_ind
           SET dsr_rec->ins_qual[dsr_loop2].event_qual[dsr_loop].detail_msg = dsr_rec->ins_qual[(
           dsr_loop2+ 1)].event_qual[dsr_loop].detail_msg
           SET dsr_rec->ins_qual[dsr_loop2].event_qual[dsr_loop].log_file = dsr_rec->ins_qual[(
           dsr_loop2+ 1)].event_qual[dsr_loop].log_file
         ENDFOR
         SET stat = alterlist(dsr_rec->ins_qual[(dsr_loop2+ 1)].event_qual,dsr_rec->ins_qual[(
          dsr_loop2+ 1)].event_cnt)
         FOR (dsr_loop = 1 TO dsr_rec->ins_qual[(dsr_loop2+ 1)].event_cnt)
           SET dsr_rec->ins_qual[(dsr_loop2+ 1)].event_qual[dsr_loop].event_dt_tm = dsr_rec->
           ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].event_dt_tm
           SET dsr_rec->ins_qual[(dsr_loop2+ 1)].event_qual[dsr_loop].event_name = dsr_rec->ins_qual[
           (dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].event_name
           SET dsr_rec->ins_qual[(dsr_loop2+ 1)].event_qual[dsr_loop].diagnostic_ind = dsr_rec->
           ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].diagnostic_ind
           SET dsr_rec->ins_qual[(dsr_loop2+ 1)].event_qual[dsr_loop].detail_msg = dsr_rec->ins_qual[
           (dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].detail_msg
           SET dsr_rec->ins_qual[(dsr_loop2+ 1)].event_qual[dsr_loop].log_file = dsr_rec->ins_qual[(
           dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].log_file
         ENDFOR
        ENDIF
      ENDFOR
    ENDFOR
   ELSEIF (dsr_option="R"
    AND (dsr_rec->ins_cnt > 0))
    SET stat = alterlist(dsr_rec->ins_qual,(dsr_rec->ins_cnt+ 1))
    FOR (dsr_loop1 = 1 TO (dsr_rec->ins_cnt - 1))
      FOR (dsr_loop2 = 1 TO (dsr_rec->ins_cnt - 1))
        IF ((dsr_rec->ins_qual[dsr_loop2].run_time_flag > dsr_rec->ins_qual[(dsr_loop2+ 1)].
        run_time_flag))
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].ins_meaning = dsr_rec->ins_qual[dsr_loop2].
         ins_meaning
         SET dsr_rec->ins_qual[dsr_loop2].ins_meaning = dsr_rec->ins_qual[(dsr_loop2+ 1)].ins_meaning
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].ins_meaning = dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)]
         .ins_meaning
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].run_time_flag = dsr_rec->ins_qual[dsr_loop2].
         run_time_flag
         SET dsr_rec->ins_qual[dsr_loop2].run_time_flag = dsr_rec->ins_qual[(dsr_loop2+ 1)].
         run_time_flag
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].run_time_flag = dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1
         )].run_time_flag
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].run_time_mean = dsr_rec->ins_qual[dsr_loop2].
         run_time_mean
         SET dsr_rec->ins_qual[dsr_loop2].run_time_mean = dsr_rec->ins_qual[(dsr_loop2+ 1)].
         run_time_mean
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].run_time_mean = dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1
         )].run_time_mean
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].description = dsr_rec->ins_qual[dsr_loop2].
         description
         SET dsr_rec->ins_qual[dsr_loop2].description = dsr_rec->ins_qual[(dsr_loop2+ 1)].description
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].description = dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)]
         .description
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].auth_ind = dsr_rec->ins_qual[dsr_loop2].
         auth_ind
         SET dsr_rec->ins_qual[dsr_loop2].auth_ind = dsr_rec->ins_qual[(dsr_loop2+ 1)].auth_ind
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].auth_ind = dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].
         auth_ind
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].last_pass_dt_tm = dsr_rec->ins_qual[dsr_loop2].
         last_pass_dt_tm
         SET dsr_rec->ins_qual[dsr_loop2].last_pass_dt_tm = dsr_rec->ins_qual[(dsr_loop2+ 1)].
         last_pass_dt_tm
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].last_pass_dt_tm = dsr_rec->ins_qual[(dsr_rec->ins_cnt
         + 1)].last_pass_dt_tm
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].last_fail_dt_tm = dsr_rec->ins_qual[dsr_loop2].
         last_fail_dt_tm
         SET dsr_rec->ins_qual[dsr_loop2].last_fail_dt_tm = dsr_rec->ins_qual[(dsr_loop2+ 1)].
         last_fail_dt_tm
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].last_fail_dt_tm = dsr_rec->ins_qual[(dsr_rec->ins_cnt
         + 1)].last_fail_dt_tm
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].last_upload_dt_tm = dsr_rec->ins_qual[dsr_loop2
         ].last_upload_dt_tm
         SET dsr_rec->ins_qual[dsr_loop2].last_upload_dt_tm = dsr_rec->ins_qual[(dsr_loop2+ 1)].
         last_upload_dt_tm
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].last_upload_dt_tm = dsr_rec->ins_qual[(dsr_rec->
         ins_cnt+ 1)].last_upload_dt_tm
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_cnt = dsr_rec->ins_qual[dsr_loop2].
         event_cnt
         SET dsr_rec->ins_qual[dsr_loop2].event_cnt = dsr_rec->ins_qual[(dsr_loop2+ 1)].event_cnt
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].event_cnt = dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].
         event_cnt
         SET stat = alterlist(dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual,dsr_rec->ins_qual[(
          dsr_rec->ins_cnt+ 1)].event_cnt)
         FOR (dsr_loop = 1 TO dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_cnt)
           SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].event_dt_tm = dsr_rec->
           ins_qual[dsr_loop2].event_qual[dsr_loop].event_dt_tm
           SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].event_name = dsr_rec->
           ins_qual[dsr_loop2].event_qual[dsr_loop].event_name
           SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].diagnostic_ind = dsr_rec
           ->ins_qual[dsr_loop2].event_qual[dsr_loop].diagnostic_ind
           SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].detail_msg = dsr_rec->
           ins_qual[dsr_loop2].event_qual[dsr_loop].detail_msg
           SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].log_file = dsr_rec->
           ins_qual[dsr_loop2].event_qual[dsr_loop].log_file
         ENDFOR
         SET stat = alterlist(dsr_rec->ins_qual[dsr_loop2].event_qual,dsr_rec->ins_qual[dsr_loop2].
          event_cnt)
         FOR (dsr_loop = 1 TO dsr_rec->ins_qual[dsr_loop2].event_cnt)
           SET dsr_rec->ins_qual[dsr_loop2].event_qual[dsr_loop].event_dt_tm = dsr_rec->ins_qual[(
           dsr_loop2+ 1)].event_qual[dsr_loop].event_dt_tm
           SET dsr_rec->ins_qual[dsr_loop2].event_qual[dsr_loop].event_name = dsr_rec->ins_qual[(
           dsr_loop2+ 1)].event_qual[dsr_loop].event_name
           SET dsr_rec->ins_qual[dsr_loop2].event_qual[dsr_loop].diagnostic_ind = dsr_rec->ins_qual[(
           dsr_loop2+ 1)].event_qual[dsr_loop].diagnostic_ind
           SET dsr_rec->ins_qual[dsr_loop2].event_qual[dsr_loop].detail_msg = dsr_rec->ins_qual[(
           dsr_loop2+ 1)].event_qual[dsr_loop].detail_msg
           SET dsr_rec->ins_qual[dsr_loop2].event_qual[dsr_loop].log_file = dsr_rec->ins_qual[(
           dsr_loop2+ 1)].event_qual[dsr_loop].log_file
         ENDFOR
         SET stat = alterlist(dsr_rec->ins_qual[(dsr_loop2+ 1)].event_qual,dsr_rec->ins_qual[(
          dsr_loop2+ 1)].event_cnt)
         FOR (dsr_loop = 1 TO dsr_rec->ins_qual[(dsr_loop2+ 1)].event_cnt)
           SET dsr_rec->ins_qual[(dsr_loop2+ 1)].event_qual[dsr_loop].event_dt_tm = dsr_rec->
           ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].event_dt_tm
           SET dsr_rec->ins_qual[(dsr_loop2+ 1)].event_qual[dsr_loop].event_name = dsr_rec->ins_qual[
           (dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].event_name
           SET dsr_rec->ins_qual[(dsr_loop2+ 1)].event_qual[dsr_loop].diagnostic_ind = dsr_rec->
           ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].diagnostic_ind
           SET dsr_rec->ins_qual[(dsr_loop2+ 1)].event_qual[dsr_loop].detail_msg = dsr_rec->ins_qual[
           (dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].detail_msg
           SET dsr_rec->ins_qual[(dsr_loop2+ 1)].event_qual[dsr_loop].log_file = dsr_rec->ins_qual[(
           dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].log_file
         ENDFOR
        ENDIF
      ENDFOR
    ENDFOR
   ELSEIF (dsr_option="U"
    AND (dsr_rec->ins_cnt > 0))
    SET stat = alterlist(dsr_rec->ins_qual,(dsr_rec->ins_cnt+ 1))
    FOR (dsr_loop1 = 1 TO (dsr_rec->ins_cnt - 1))
      FOR (dsr_loop2 = 1 TO (dsr_rec->ins_cnt - 1))
        IF (cnvtdatetime(dsr_rec->ins_qual[dsr_loop2].last_upload_dt_tm) < cnvtdatetime(dsr_rec->
         ins_qual[(dsr_loop2+ 1)].last_upload_dt_tm))
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].ins_meaning = dsr_rec->ins_qual[dsr_loop2].
         ins_meaning
         SET dsr_rec->ins_qual[dsr_loop2].ins_meaning = dsr_rec->ins_qual[(dsr_loop2+ 1)].ins_meaning
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].ins_meaning = dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)]
         .ins_meaning
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].run_time_flag = dsr_rec->ins_qual[dsr_loop2].
         run_time_flag
         SET dsr_rec->ins_qual[dsr_loop2].run_time_flag = dsr_rec->ins_qual[(dsr_loop2+ 1)].
         run_time_flag
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].run_time_flag = dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1
         )].run_time_flag
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].run_time_mean = dsr_rec->ins_qual[dsr_loop2].
         run_time_mean
         SET dsr_rec->ins_qual[dsr_loop2].run_time_mean = dsr_rec->ins_qual[(dsr_loop2+ 1)].
         run_time_mean
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].run_time_mean = dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1
         )].run_time_mean
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].description = dsr_rec->ins_qual[dsr_loop2].
         description
         SET dsr_rec->ins_qual[dsr_loop2].description = dsr_rec->ins_qual[(dsr_loop2+ 1)].description
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].description = dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)]
         .description
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].auth_ind = dsr_rec->ins_qual[dsr_loop2].
         auth_ind
         SET dsr_rec->ins_qual[dsr_loop2].auth_ind = dsr_rec->ins_qual[(dsr_loop2+ 1)].auth_ind
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].auth_ind = dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].
         auth_ind
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].last_pass_dt_tm = dsr_rec->ins_qual[dsr_loop2].
         last_pass_dt_tm
         SET dsr_rec->ins_qual[dsr_loop2].last_pass_dt_tm = dsr_rec->ins_qual[(dsr_loop2+ 1)].
         last_pass_dt_tm
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].last_pass_dt_tm = dsr_rec->ins_qual[(dsr_rec->ins_cnt
         + 1)].last_pass_dt_tm
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].last_fail_dt_tm = dsr_rec->ins_qual[dsr_loop2].
         last_fail_dt_tm
         SET dsr_rec->ins_qual[dsr_loop2].last_fail_dt_tm = dsr_rec->ins_qual[(dsr_loop2+ 1)].
         last_fail_dt_tm
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].last_fail_dt_tm = dsr_rec->ins_qual[(dsr_rec->ins_cnt
         + 1)].last_fail_dt_tm
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].last_upload_dt_tm = dsr_rec->ins_qual[dsr_loop2
         ].last_upload_dt_tm
         SET dsr_rec->ins_qual[dsr_loop2].last_upload_dt_tm = dsr_rec->ins_qual[(dsr_loop2+ 1)].
         last_upload_dt_tm
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].last_upload_dt_tm = dsr_rec->ins_qual[(dsr_rec->
         ins_cnt+ 1)].last_upload_dt_tm
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_cnt = dsr_rec->ins_qual[dsr_loop2].
         event_cnt
         SET dsr_rec->ins_qual[dsr_loop2].event_cnt = dsr_rec->ins_qual[(dsr_loop2+ 1)].event_cnt
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].event_cnt = dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].
         event_cnt
         SET stat = alterlist(dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual,dsr_rec->ins_qual[(
          dsr_rec->ins_cnt+ 1)].event_cnt)
         FOR (dsr_loop = 1 TO dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_cnt)
           SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].event_dt_tm = dsr_rec->
           ins_qual[dsr_loop2].event_qual[dsr_loop].event_dt_tm
           SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].event_name = dsr_rec->
           ins_qual[dsr_loop2].event_qual[dsr_loop].event_name
           SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].diagnostic_ind = dsr_rec
           ->ins_qual[dsr_loop2].event_qual[dsr_loop].diagnostic_ind
           SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].detail_msg = dsr_rec->
           ins_qual[dsr_loop2].event_qual[dsr_loop].detail_msg
           SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].log_file = dsr_rec->
           ins_qual[dsr_loop2].event_qual[dsr_loop].log_file
         ENDFOR
         SET stat = alterlist(dsr_rec->ins_qual[dsr_loop2].event_qual,dsr_rec->ins_qual[dsr_loop2].
          event_cnt)
         FOR (dsr_loop = 1 TO dsr_rec->ins_qual[dsr_loop2].event_cnt)
           SET dsr_rec->ins_qual[dsr_loop2].event_qual[dsr_loop].event_dt_tm = dsr_rec->ins_qual[(
           dsr_loop2+ 1)].event_qual[dsr_loop].event_dt_tm
           SET dsr_rec->ins_qual[dsr_loop2].event_qual[dsr_loop].event_name = dsr_rec->ins_qual[(
           dsr_loop2+ 1)].event_qual[dsr_loop].event_name
           SET dsr_rec->ins_qual[dsr_loop2].event_qual[dsr_loop].diagnostic_ind = dsr_rec->ins_qual[(
           dsr_loop2+ 1)].event_qual[dsr_loop].diagnostic_ind
           SET dsr_rec->ins_qual[dsr_loop2].event_qual[dsr_loop].detail_msg = dsr_rec->ins_qual[(
           dsr_loop2+ 1)].event_qual[dsr_loop].detail_msg
           SET dsr_rec->ins_qual[dsr_loop2].event_qual[dsr_loop].log_file = dsr_rec->ins_qual[(
           dsr_loop2+ 1)].event_qual[dsr_loop].log_file
         ENDFOR
         SET stat = alterlist(dsr_rec->ins_qual[(dsr_loop2+ 1)].event_qual,dsr_rec->ins_qual[(
          dsr_loop2+ 1)].event_cnt)
         FOR (dsr_loop = 1 TO dsr_rec->ins_qual[(dsr_loop2+ 1)].event_cnt)
           SET dsr_rec->ins_qual[(dsr_loop2+ 1)].event_qual[dsr_loop].event_dt_tm = dsr_rec->
           ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].event_dt_tm
           SET dsr_rec->ins_qual[(dsr_loop2+ 1)].event_qual[dsr_loop].event_name = dsr_rec->ins_qual[
           (dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].event_name
           SET dsr_rec->ins_qual[(dsr_loop2+ 1)].event_qual[dsr_loop].diagnostic_ind = dsr_rec->
           ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].diagnostic_ind
           SET dsr_rec->ins_qual[(dsr_loop2+ 1)].event_qual[dsr_loop].detail_msg = dsr_rec->ins_qual[
           (dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].detail_msg
           SET dsr_rec->ins_qual[(dsr_loop2+ 1)].event_qual[dsr_loop].log_file = dsr_rec->ins_qual[(
           dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].log_file
         ENDFOR
        ENDIF
      ENDFOR
    ENDFOR
   ELSEIF (dsr_option="P"
    AND (dsr_rec->ins_cnt > 0))
    SET stat = alterlist(dsr_rec->ins_qual,(dsr_rec->ins_cnt+ 1))
    FOR (dsr_loop1 = 1 TO (dsr_rec->ins_cnt - 1))
      FOR (dsr_loop2 = 1 TO (dsr_rec->ins_cnt - 1))
        IF (cnvtdatetime(dsr_rec->ins_qual[dsr_loop2].last_pass_dt_tm) < cnvtdatetime(dsr_rec->
         ins_qual[(dsr_loop2+ 1)].last_pass_dt_tm))
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].ins_meaning = dsr_rec->ins_qual[dsr_loop2].
         ins_meaning
         SET dsr_rec->ins_qual[dsr_loop2].ins_meaning = dsr_rec->ins_qual[(dsr_loop2+ 1)].ins_meaning
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].ins_meaning = dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)]
         .ins_meaning
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].run_time_flag = dsr_rec->ins_qual[dsr_loop2].
         run_time_flag
         SET dsr_rec->ins_qual[dsr_loop2].run_time_flag = dsr_rec->ins_qual[(dsr_loop2+ 1)].
         run_time_flag
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].run_time_flag = dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1
         )].run_time_flag
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].run_time_mean = dsr_rec->ins_qual[dsr_loop2].
         run_time_mean
         SET dsr_rec->ins_qual[dsr_loop2].run_time_mean = dsr_rec->ins_qual[(dsr_loop2+ 1)].
         run_time_mean
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].run_time_mean = dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1
         )].run_time_mean
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].description = dsr_rec->ins_qual[dsr_loop2].
         description
         SET dsr_rec->ins_qual[dsr_loop2].description = dsr_rec->ins_qual[(dsr_loop2+ 1)].description
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].description = dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)]
         .description
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].auth_ind = dsr_rec->ins_qual[dsr_loop2].
         auth_ind
         SET dsr_rec->ins_qual[dsr_loop2].auth_ind = dsr_rec->ins_qual[(dsr_loop2+ 1)].auth_ind
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].auth_ind = dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].
         auth_ind
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].last_pass_dt_tm = dsr_rec->ins_qual[dsr_loop2].
         last_pass_dt_tm
         SET dsr_rec->ins_qual[dsr_loop2].last_pass_dt_tm = dsr_rec->ins_qual[(dsr_loop2+ 1)].
         last_pass_dt_tm
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].last_pass_dt_tm = dsr_rec->ins_qual[(dsr_rec->ins_cnt
         + 1)].last_pass_dt_tm
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].last_fail_dt_tm = dsr_rec->ins_qual[dsr_loop2].
         last_fail_dt_tm
         SET dsr_rec->ins_qual[dsr_loop2].last_fail_dt_tm = dsr_rec->ins_qual[(dsr_loop2+ 1)].
         last_fail_dt_tm
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].last_fail_dt_tm = dsr_rec->ins_qual[(dsr_rec->ins_cnt
         + 1)].last_fail_dt_tm
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].last_upload_dt_tm = dsr_rec->ins_qual[dsr_loop2
         ].last_upload_dt_tm
         SET dsr_rec->ins_qual[dsr_loop2].last_upload_dt_tm = dsr_rec->ins_qual[(dsr_loop2+ 1)].
         last_upload_dt_tm
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].last_upload_dt_tm = dsr_rec->ins_qual[(dsr_rec->
         ins_cnt+ 1)].last_upload_dt_tm
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_cnt = dsr_rec->ins_qual[dsr_loop2].
         event_cnt
         SET dsr_rec->ins_qual[dsr_loop2].event_cnt = dsr_rec->ins_qual[(dsr_loop2+ 1)].event_cnt
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].event_cnt = dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].
         event_cnt
         SET stat = alterlist(dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual,dsr_rec->ins_qual[(
          dsr_rec->ins_cnt+ 1)].event_cnt)
         FOR (dsr_loop = 1 TO dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_cnt)
           SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].event_dt_tm = dsr_rec->
           ins_qual[dsr_loop2].event_qual[dsr_loop].event_dt_tm
           SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].event_name = dsr_rec->
           ins_qual[dsr_loop2].event_qual[dsr_loop].event_name
           SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].diagnostic_ind = dsr_rec
           ->ins_qual[dsr_loop2].event_qual[dsr_loop].diagnostic_ind
           SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].detail_msg = dsr_rec->
           ins_qual[dsr_loop2].event_qual[dsr_loop].detail_msg
           SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].log_file = dsr_rec->
           ins_qual[dsr_loop2].event_qual[dsr_loop].log_file
         ENDFOR
         SET stat = alterlist(dsr_rec->ins_qual[dsr_loop2].event_qual,dsr_rec->ins_qual[dsr_loop2].
          event_cnt)
         FOR (dsr_loop = 1 TO dsr_rec->ins_qual[dsr_loop2].event_cnt)
           SET dsr_rec->ins_qual[dsr_loop2].event_qual[dsr_loop].event_dt_tm = dsr_rec->ins_qual[(
           dsr_loop2+ 1)].event_qual[dsr_loop].event_dt_tm
           SET dsr_rec->ins_qual[dsr_loop2].event_qual[dsr_loop].event_name = dsr_rec->ins_qual[(
           dsr_loop2+ 1)].event_qual[dsr_loop].event_name
           SET dsr_rec->ins_qual[dsr_loop2].event_qual[dsr_loop].diagnostic_ind = dsr_rec->ins_qual[(
           dsr_loop2+ 1)].event_qual[dsr_loop].diagnostic_ind
           SET dsr_rec->ins_qual[dsr_loop2].event_qual[dsr_loop].detail_msg = dsr_rec->ins_qual[(
           dsr_loop2+ 1)].event_qual[dsr_loop].detail_msg
           SET dsr_rec->ins_qual[dsr_loop2].event_qual[dsr_loop].log_file = dsr_rec->ins_qual[(
           dsr_loop2+ 1)].event_qual[dsr_loop].log_file
         ENDFOR
         SET stat = alterlist(dsr_rec->ins_qual[(dsr_loop2+ 1)].event_qual,dsr_rec->ins_qual[(
          dsr_loop2+ 1)].event_cnt)
         FOR (dsr_loop = 1 TO dsr_rec->ins_qual[(dsr_loop2+ 1)].event_cnt)
           SET dsr_rec->ins_qual[(dsr_loop2+ 1)].event_qual[dsr_loop].event_dt_tm = dsr_rec->
           ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].event_dt_tm
           SET dsr_rec->ins_qual[(dsr_loop2+ 1)].event_qual[dsr_loop].event_name = dsr_rec->ins_qual[
           (dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].event_name
           SET dsr_rec->ins_qual[(dsr_loop2+ 1)].event_qual[dsr_loop].diagnostic_ind = dsr_rec->
           ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].diagnostic_ind
           SET dsr_rec->ins_qual[(dsr_loop2+ 1)].event_qual[dsr_loop].detail_msg = dsr_rec->ins_qual[
           (dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].detail_msg
           SET dsr_rec->ins_qual[(dsr_loop2+ 1)].event_qual[dsr_loop].log_file = dsr_rec->ins_qual[(
           dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].log_file
         ENDFOR
        ENDIF
      ENDFOR
    ENDFOR
   ELSEIF (dsr_option="F"
    AND (dsr_rec->ins_cnt > 0))
    SET stat = alterlist(dsr_rec->ins_qual,(dsr_rec->ins_cnt+ 1))
    FOR (dsr_loop1 = 1 TO (dsr_rec->ins_cnt - 1))
      FOR (dsr_loop2 = 1 TO (dsr_rec->ins_cnt - 1))
        IF (cnvtdatetime(dsr_rec->ins_qual[dsr_loop2].last_fail_dt_tm) < cnvtdatetime(dsr_rec->
         ins_qual[(dsr_loop2+ 1)].last_fail_dt_tm))
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].ins_meaning = dsr_rec->ins_qual[dsr_loop2].
         ins_meaning
         SET dsr_rec->ins_qual[dsr_loop2].ins_meaning = dsr_rec->ins_qual[(dsr_loop2+ 1)].ins_meaning
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].ins_meaning = dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)]
         .ins_meaning
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].run_time_flag = dsr_rec->ins_qual[dsr_loop2].
         run_time_flag
         SET dsr_rec->ins_qual[dsr_loop2].run_time_flag = dsr_rec->ins_qual[(dsr_loop2+ 1)].
         run_time_flag
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].run_time_flag = dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1
         )].run_time_flag
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].run_time_mean = dsr_rec->ins_qual[dsr_loop2].
         run_time_mean
         SET dsr_rec->ins_qual[dsr_loop2].run_time_mean = dsr_rec->ins_qual[(dsr_loop2+ 1)].
         run_time_mean
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].run_time_mean = dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1
         )].run_time_mean
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].description = dsr_rec->ins_qual[dsr_loop2].
         description
         SET dsr_rec->ins_qual[dsr_loop2].description = dsr_rec->ins_qual[(dsr_loop2+ 1)].description
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].description = dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)]
         .description
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].auth_ind = dsr_rec->ins_qual[dsr_loop2].
         auth_ind
         SET dsr_rec->ins_qual[dsr_loop2].auth_ind = dsr_rec->ins_qual[(dsr_loop2+ 1)].auth_ind
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].auth_ind = dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].
         auth_ind
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].last_pass_dt_tm = dsr_rec->ins_qual[dsr_loop2].
         last_pass_dt_tm
         SET dsr_rec->ins_qual[dsr_loop2].last_pass_dt_tm = dsr_rec->ins_qual[(dsr_loop2+ 1)].
         last_pass_dt_tm
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].last_pass_dt_tm = dsr_rec->ins_qual[(dsr_rec->ins_cnt
         + 1)].last_pass_dt_tm
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].last_fail_dt_tm = dsr_rec->ins_qual[dsr_loop2].
         last_fail_dt_tm
         SET dsr_rec->ins_qual[dsr_loop2].last_fail_dt_tm = dsr_rec->ins_qual[(dsr_loop2+ 1)].
         last_fail_dt_tm
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].last_fail_dt_tm = dsr_rec->ins_qual[(dsr_rec->ins_cnt
         + 1)].last_fail_dt_tm
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].last_upload_dt_tm = dsr_rec->ins_qual[dsr_loop2
         ].last_upload_dt_tm
         SET dsr_rec->ins_qual[dsr_loop2].last_upload_dt_tm = dsr_rec->ins_qual[(dsr_loop2+ 1)].
         last_upload_dt_tm
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].last_upload_dt_tm = dsr_rec->ins_qual[(dsr_rec->
         ins_cnt+ 1)].last_upload_dt_tm
         SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_cnt = dsr_rec->ins_qual[dsr_loop2].
         event_cnt
         SET dsr_rec->ins_qual[dsr_loop2].event_cnt = dsr_rec->ins_qual[(dsr_loop2+ 1)].event_cnt
         SET dsr_rec->ins_qual[(dsr_loop2+ 1)].event_cnt = dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].
         event_cnt
         SET stat = alterlist(dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual,dsr_rec->ins_qual[(
          dsr_rec->ins_cnt+ 1)].event_cnt)
         FOR (dsr_loop = 1 TO dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_cnt)
           SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].event_dt_tm = dsr_rec->
           ins_qual[dsr_loop2].event_qual[dsr_loop].event_dt_tm
           SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].event_name = dsr_rec->
           ins_qual[dsr_loop2].event_qual[dsr_loop].event_name
           SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].diagnostic_ind = dsr_rec
           ->ins_qual[dsr_loop2].event_qual[dsr_loop].diagnostic_ind
           SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].detail_msg = dsr_rec->
           ins_qual[dsr_loop2].event_qual[dsr_loop].detail_msg
           SET dsr_rec->ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].log_file = dsr_rec->
           ins_qual[dsr_loop2].event_qual[dsr_loop].log_file
         ENDFOR
         SET stat = alterlist(dsr_rec->ins_qual[dsr_loop2].event_qual,dsr_rec->ins_qual[dsr_loop2].
          event_cnt)
         FOR (dsr_loop = 1 TO dsr_rec->ins_qual[dsr_loop2].event_cnt)
           SET dsr_rec->ins_qual[dsr_loop2].event_qual[dsr_loop].event_dt_tm = dsr_rec->ins_qual[(
           dsr_loop2+ 1)].event_qual[dsr_loop].event_dt_tm
           SET dsr_rec->ins_qual[dsr_loop2].event_qual[dsr_loop].event_name = dsr_rec->ins_qual[(
           dsr_loop2+ 1)].event_qual[dsr_loop].event_name
           SET dsr_rec->ins_qual[dsr_loop2].event_qual[dsr_loop].diagnostic_ind = dsr_rec->ins_qual[(
           dsr_loop2+ 1)].event_qual[dsr_loop].diagnostic_ind
           SET dsr_rec->ins_qual[dsr_loop2].event_qual[dsr_loop].detail_msg = dsr_rec->ins_qual[(
           dsr_loop2+ 1)].event_qual[dsr_loop].detail_msg
           SET dsr_rec->ins_qual[dsr_loop2].event_qual[dsr_loop].log_file = dsr_rec->ins_qual[(
           dsr_loop2+ 1)].event_qual[dsr_loop].log_file
         ENDFOR
         SET stat = alterlist(dsr_rec->ins_qual[(dsr_loop2+ 1)].event_qual,dsr_rec->ins_qual[(
          dsr_loop2+ 1)].event_cnt)
         FOR (dsr_loop = 1 TO dsr_rec->ins_qual[(dsr_loop2+ 1)].event_cnt)
           SET dsr_rec->ins_qual[(dsr_loop2+ 1)].event_qual[dsr_loop].event_dt_tm = dsr_rec->
           ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].event_dt_tm
           SET dsr_rec->ins_qual[(dsr_loop2+ 1)].event_qual[dsr_loop].event_name = dsr_rec->ins_qual[
           (dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].event_name
           SET dsr_rec->ins_qual[(dsr_loop2+ 1)].event_qual[dsr_loop].diagnostic_ind = dsr_rec->
           ins_qual[(dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].diagnostic_ind
           SET dsr_rec->ins_qual[(dsr_loop2+ 1)].event_qual[dsr_loop].detail_msg = dsr_rec->ins_qual[
           (dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].detail_msg
           SET dsr_rec->ins_qual[(dsr_loop2+ 1)].event_qual[dsr_loop].log_file = dsr_rec->ins_qual[(
           dsr_rec->ins_cnt+ 1)].event_qual[dsr_loop].log_file
         ENDFOR
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE drmis_check_error_gui(dce_rs,ceg_proc,ceg_menu_screen,ceg_add_info)
   DECLARE ceg_error = i4 WITH protect, noconstant(0)
   DECLARE ceg_size = i4 WITH protect, noconstant(0)
   DECLARE ceg_loop = i4 WITH protect, noconstant(0)
   DECLARE ceg_line_nbr = i4 WITH protect, noconstant(0)
   SET ceg_error = check_error(ceg_proc)
   IF (ceg_error != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    SET message = window
    SET width = 132
    CALL clear(1,1)
    CALL box(1,1,5,132)
    CALL drmis_disp_header(dce_rs,ceg_menu_screen)
    IF ((ceg_add_info->cnt > 0))
     SET ceg_line_nbr = 6
     FOR (ceg_loop = 1 TO ceg_add_info->cnt)
      SET ceg_line_nbr = (ceg_line_nbr+ 1)
      CALL text(ceg_line_nbr,3,ceg_add_info->qual[ceg_loop].data)
     ENDFOR
    ELSE
     SET ceg_line_nbr = 7
    ENDIF
    SET ceg_line_nbr = (ceg_line_nbr+ 2)
    IF (ceg_line_nbr > 19)
     SET ceg_line_nbr = 19
    ENDIF
    SET ceg_size = size(dm_err->emsg)
    CALL text(ceg_line_nbr,3,trim(substring(1,125,dm_err->emsg)))
    IF (ceg_size > 125)
     SET ceg_line_nbr = (ceg_line_nbr+ 1)
     CALL text(ceg_line_nbr,3,trim(substring(126,125,dm_err->emsg)))
    ENDIF
    CALL text((ceg_line_nbr+ 2),3,"Press ENTER to continue")
    CALL accept((ceg_line_nbr+ 2),28,"P;E"," ")
    SET message = nowindow
   ENDIF
   RETURN(dm_err->err_ind)
 END ;Subroutine
 SUBROUTINE drmis_disp_header(ddh_rs,ddh_screen)
   CALL text(3,floor(((132 - size(ddh_screen))/ 2)),ddh_screen)
   CALL text(4,75,"ENVIRONMENT ID:")
   CALL text(4,20,"ENVIRONMENT NAME:")
   CALL text(4,95,cnvtstring(ddh_rs->cur_env_id))
   CALL text(4,40,ddh_rs->cur_env_name)
   RETURN(null)
 END ;Subroutine
#exit_manage
END GO
