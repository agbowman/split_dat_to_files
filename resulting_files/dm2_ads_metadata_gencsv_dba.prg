CREATE PROGRAM dm2_ads_metadata_gencsv:dba
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
 IF ((validate(dads_list->table_cnt,- (1))=- (1))
  AND (validate(dads_list->table_cnt,- (2))=- (2)))
  FREE RECORD dads_list
  RECORD dads_list(
    01 config_id = f8
    01 config_name = vc
    01 table_cnt = i4
    01 config_pct = f8
    01 config_method = vc
    01 pct_override = f8
    01 method_override = vc
    01 preserve_ind = i2
    01 last_msg = vc
    01 config_status = vc
    01 driverkey_status = vc
    01 config_updt_dt_tm = dq8
    01 driverkey_updt_dt_tm = dq8
    01 config_cnt = i4
    01 config_qual[*]
      02 config_id = f8
      02 config_name = vc
      02 config_pct = f8
      02 config_method = vc
      02 last_msg = vc
      02 last_config_phase = vc
      02 config_status = vc
      02 driverkey_status = vc
      02 config_updt_dt_tm = dq8
      02 driverkey_updt_dt_tm = dq8
    01 extract_cnt = i4
    01 extract_qual[*]
      02 extract_id = f8
      02 owner_name = vc
      02 table_name = vc
      02 table_extract_nbr = i4
      02 table_extract_instance_nbr = i2
      02 full_key = vc
      02 table_exists_ind = i2
      02 active_ind = i2
      02 driver_table_name = vc
      02 data_class_type = vc
      02 extract_method = vc
      02 driver_table_ind = i2
      02 driver_keycol_name = vc
      02 driver_rankcol_name = vc
      02 expimp_parent_table_name = vc
      02 expimp_level_nbr = i4
      02 parent_table_name = vc
      02 skip_ind = i2
      02 valid_stats_ind = i2
      02 driver_extract_id = f8
      02 status = vc
      02 message = vc
      02 tgt_sample_pct = f8
      02 tgt_sample_method = vc
      02 src_num_rows = f8
      02 row_sample = f8
      02 sum_row_sample = f8
      02 estimated_sample_pct = i4
      02 dpq_id = f8
      02 apply_where_ind = i2
      02 begin_dt_tm = dq8
      02 end_dt_tm = dq8
      02 where_clause = vc
      02 table_comment = vc
      02 dupdel_skip_ind = i2
      02 updt_id = f8
      02 updt_task = i4
      02 updt_cnt = i4
      02 updt_dt_tm = dq8
      02 updt_applctx = i4
    01 driver_cnt = i4
    01 sort_field1 = vc
    01 sort_value1 = vc
    01 filter_criteria = vc
  )
  SET dads_list->config_status = "DM2NOTSET"
  SET dads_list->method_override = "DM2NOTSET"
  SET dads_list->pct_override = 0
  SET dads_list->driverkey_status = "DM2NOTSET"
  SET dads_list->sort_field1 = "DM2NOTSET"
  SET dads_list->sort_value1 = "DM2NOTSET"
  SET dads_list->filter_criteria = "DM2NOTSET"
 ENDIF
 IF ((validate(dar_extract_details->config_id,- (1))=- (1))
  AND (validate(dar_extract_details->config_id,- (2))=- (2)))
  FREE RECORD dar_extract_details
  RECORD dar_extract_details(
    01 config_id = f8
    01 owner_name = vc
    01 table_name = vc
    01 table_extract_nbr = i4
    01 table_extract_instance_nbr = i2
    01 full_key = vc
    01 extract_id = f8
    01 parent_table_name = vc
    01 driver_keycol_name = vc
    01 driver_rankcol_name = vc
    01 driver_table_ind = i2
    01 apply_where_ind = i2
    01 status = vc
    01 message = vc
    01 src_num_rows = f8
    01 src_last_analyzed_dt_tm = dq8
    01 src_avg_row_length = i4
    01 row_sample = f8
    01 tgt_sample_pct = f8
    01 tgt_sample_method = vc
    01 tgt_rank_val = f8
    01 tgt_mod_val = i4
    01 rand_val = i4
    01 begin_end_dt_tm = dq8
    01 end_dt_tm = dq8
    01 driver_extract_id = f8
    01 where_clause = vc
  )
 ENDIF
 DECLARE dar_populate_dse_rs(null) = i2
 DECLARE dar_check_ads_execution(dcse_already_running=i2(ref)) = i2
 DECLARE dar_get_ads_config(null) = i2
 DECLARE dar_get_config_data(dgcsd_config_id=f8) = i2
 DECLARE dar_get_config_dtl(dgscd_config_id=f8,dgscd_table=vc(ref)) = i2
 DECLARE dar_get_config_list(dgcs_exclude_cust_ind=i2) = i2
 DECLARE dar_get_extract_list(dgel_driverkey_ind=i2,dgel_table=vc,dgel_table_extract_nbr=i4,
  dgel_ref_link_ind=i2) = i2
 DECLARE dar_scr_dads_list(dsdl_mode=i2) = i2
 DECLARE dar_get_rpt_details(dgrd_config_id=f8) = i2
 DECLARE dar_get_extract_details(dged_config_extract_id=f8) = i2
 DECLARE dar_get_non_standard_tables(dgnst_config_id=f8) = i2
 DECLARE dar_cleanup_stranded_ads_procs(null) = i2
 DECLARE dar_sync_config_status(dscs_config_id=f8) = i2
 DECLARE dar_common_menu(dcm_start_line=i4,dcm_title=vc) = i2
 DECLARE dar_get_sort_criteria(dgsc_filter_ind=i2) = i2
 DECLARE dar_clear_dads_list(null) = i2
 DECLARE dar_disp_error_msg(null) = i2
 DECLARE dar_add_rpt_to_event_dtl(dard_type_in=vc,dard_rpt_in=vc) = i2
 SUBROUTINE dar_check_ads_execution(dcae_already_running)
   SET dm_err->eproc = "Retrieving statuses of various ADS processes from dm_ads_config"
   CALL disp_msg("",dm_err->logfile,0)
   SET dcse_already_running = 0
   SELECT INTO "nl:"
    FROM dm_ads_config dac
    WHERE dac.config_status=dpl_executing
    DETAIL
     dcae_already_running = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dcae_already_running = 0
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dar_get_config_list(dgcs_exclude_cust_ind)
   DECLARE dgcl_cnt = i4 WITH protect, noconstant(0)
   SET dm_err->eproc =
   "Populating the dads_list->config record structure with list of configurations from dm_ads_config"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT DISTINCT INTO "nl:"
    FROM dm_ads_config dac
    WHERE dac.dm_ads_config_id > 0
     AND dac.sample_method != dpl_purge
    ORDER BY dac.config_name
    HEAD REPORT
     dads_list->config_cnt = 0, stat = alterlist(dads_list->config_qual,dads_list->config_cnt)
    DETAIL
     dads_list->config_cnt = (dads_list->config_cnt+ 1)
     IF (mod(dads_list->config_cnt,10)=1)
      stat = alterlist(dads_list->config_qual,(dads_list->config_cnt+ 9))
     ENDIF
     dads_list->config_qual[dads_list->config_cnt].config_id = dac.dm_ads_config_id, dads_list->
     config_qual[dads_list->config_cnt].config_name = trim(dac.config_name), dads_list->config_qual[
     dads_list->config_cnt].config_pct = dac.sample_percent_nbr,
     dads_list->config_qual[dads_list->config_cnt].config_method = trim(dac.sample_method), dads_list
     ->config_qual[dads_list->config_cnt].config_status = dac.config_status, dads_list->config_qual[
     dads_list->config_cnt].config_updt_dt_tm = dac.updt_dt_tm
    FOOT REPORT
     stat = alterlist(dads_list->config_qual,dads_list->config_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag=511))
    CALL echorecord(dads_list)
   ENDIF
   FOR (dgcl_cnt = 1 TO dads_list->config_cnt)
     IF (dar_sync_config_status(dads_list->config_qual[dgcl_cnt].config_id)=0)
      RETURN(0)
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dar_get_ads_config(null)
   DECLARE dgac_invalid = i2 WITH protect, noconstant(0)
   DECLARE dgac_config_name = vc WITH protect, noconstant("")
   DECLARE dgac_config_idx = i4 WITH protect, noconstant(0)
   DECLARE dgac_continue = i2 WITH protect, noconstant(0)
   DECLARE dgac_line = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Obtaining Sample Configuration ID"
   CALL disp_msg("",dm_err->logfile,0)
   SET dgac_continue = 1
   SET dm_err->eproc = "Verifying at least one ADS config exists"
   IF (dar_get_config_list(0)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Obtaining Sample Config ID from user"
   WHILE (dgac_continue=1)
     SET message = window
     CALL clear(1,1)
     CALL box(1,1,3,132)
     CALL text(2,2,"ACTIVITY DATA SAMPLE MENU [CONFIGURATION SELECTION]")
     CALL text(2,70,"DATE/TIME: ")
     CALL text(2,80,format(cnvtdatetime(curdate,curtime3),";;Q"))
     IF ((dads_list->config_cnt=0))
      CALL text(5,5,
       "No Sample configurations currently exist in this domain. Press <Enter> to Continue")
      CALL accept(5,90,"p;cu"," "
       WHERE curaccept IN (" "))
      SET dads_list->config_id = 0
      SET dgac_continue = 0
     ELSE
      IF (dgac_invalid=1)
       CALL text(5,2,build(dads_list->config_id," is an Invalid Sample Configuration. Please Retry.")
        )
       SET dgac_invalid = 0
      ENDIF
      CALL text(7,2,"Sample Configuration Name: ")
      SET help = pos(9,2,10,128)
      SET help =
      SELECT INTO "nl:"
       sample_name = substring(1,30,dads_list->config_qual[t.seq].config_name), status = substring(1,
        11,dads_list->config_qual[t.seq].config_status), method = substring(1,12,dads_list->
        config_qual[t.seq].config_method),
       pct = substring(1,9,format(dads_list->config_qual[t.seq].config_pct,"##.######;;")),
       last_modified = substring(1,14,format(dads_list->config_qual[t.seq].config_updt_dt_tm,
         "DD-MMM-YYYY;;D"))
       FROM (dummyt t  WITH seq = value(dads_list->config_cnt))
       ORDER BY dads_list->config_qual[t.seq].config_name
       WITH nocounter
      ;end select
      CALL accept(7,30,"P(30);CUF")
      SET help = off
      SET dgac_config_name = trim(curaccept)
      SET dgac_line = ((7+ dads_list->config_cnt)+ 3)
      CALL text(dgac_line,2,"(C)ontinue, (S)elect, (B)ack :")
      CALL accept(dgac_line,34,"p;cu","C"
       WHERE curaccept IN ("C", "S", "B"))
      SET message = nowindow
      CASE (curaccept)
       OF "B":
        SET dads_list->config_id = 0
        SET dgac_continue = 0
       OF "C":
        SET dm_err->eproc = "Verifying that Sample Configuration exists"
        SET dgac_config_idx = locateval(dgac_config_idx,1,dads_list->config_cnt,dgac_config_name,
         dads_list->config_qual[dgac_config_idx].config_name)
        IF (dgac_config_idx > 0)
         SET dads_list->config_id = dads_list->config_qual[dgac_config_idx].config_id
         SET dads_list->config_name = dads_list->config_qual[dgac_config_idx].config_name
         SET dgac_continue = 0
        ELSE
         SET dgac_invalid = 1
        ENDIF
       OF "S":
        SET dgac_continue = 1
      ENDCASE
     ENDIF
   ENDWHILE
   IF (check_error(dm_err->eproc)=1)
    CALL dar_disp_error_msg(null)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dar_get_config_data(dgcd_config_id)
   IF (dar_cleanup_stranded_ads_procs(dgcd_config_id)=0)
    RETURN(0)
   ENDIF
   IF (dar_sync_config_status(dgcd_config_id)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Retrieving sample configuration data from dm_ads_config for: ",build(
     dgcd_config_id))
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_ads_config dac
    WHERE dac.dm_ads_config_id=dgcd_config_id
    DETAIL
     dads_list->config_name = trim(dac.config_name), dads_list->config_pct = dac.sample_percent_nbr,
     dads_list->config_method = trim(dac.sample_method),
     dads_list->config_status = dac.config_status, dads_list->config_updt_dt_tm = cnvtdatetime(dac
      .updt_dt_tm), dads_list->pct_override = 0,
     dads_list->method_override = ""
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("No Information found for Sample Configuration: ",build(dgcd_config_id)
     )
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dads_list)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dar_get_config_dtl(dgcd_config_id,dgcd_table)
   DECLARE dgcd_continue = i2 WITH protect, noconstant(1)
   DECLARE dgcd_help_msg = vc WITH protect, noconstant("")
   DECLARE dgcd_pos = i4 WITH protect, noconstant(0)
   DECLARE dgcd_temp_str = vc WITH protect, noconstant("")
   SET dgcd_temp_str = "*"
   SET dm_err->eproc = concat("Obtaining sample configuration details from user for: ",build(
     dgcd_config_id))
   CALL disp_msg("",dm_err->logfile,0)
   WHILE (dgcd_continue=1)
     SET message = window
     CALL clear(1,1)
     CALL box(1,1,3,132)
     CALL text(2,2,"ACTIVITY DATA SAMPLE MENU [DRIVER TABLE SELECTION]")
     CALL text(2,70,"DATE/TIME: ")
     CALL text(2,80,format(cnvtdatetime(curdate,curtime3),"DD-MMM-YYYY HH:MM:SS;;D"))
     CALL text(5,2,"Sample Name: ")
     CALL text(5,18,dads_list->config_name)
     CALL text(6,2,"Sample Method: ")
     CALL text(6,18,dads_list->config_method)
     CALL text(6,40,"Sample Percent: ")
     CALL text(6,65,build(dads_list->config_pct))
     CALL text(9,2,"Driver Table Name (Wildcards allowed): ")
     CALL text(10,2,"Method: ")
     CALL text(11,2,"Percent Override: ")
     SET accept = nopatcheck
     CALL accept(9,45,"P(20);C",dgcd_temp_str)
     SET dgcd_temp_str = curaccept
     SET dgcd_help_msg = concat(value(dpl_interval),",",value(dpl_recent),",",value(dpl_full))
     SET help = pos(7,60,10,60)
     SET help = fix(value(dgcd_help_msg))
     CALL accept(10,45,"A(15);CUF",dads_list->method_override
      WHERE curaccept IN (dpl_interval, dpl_recent, dpl_full))
     SET help = off
     SET dads_list->method_override = curaccept
     CALL accept(11,45,"N(4);",dads_list->pct_override
      WHERE cnvtreal(curaccept) >= 0.0
       AND cnvtreal(curaccept) <= 100.0)
     SET dads_list->pct_override = cnvtreal(curaccept)
     CALL text(13,2,"(C)ontinue, (M)odify, (B)ack to Config Selection :")
     CALL accept(13,55,"p;cu","M"
      WHERE curaccept IN ("C", "M", "B"))
     SET message = nowindow
     CASE (curaccept)
      OF "B":
       IF (dar_get_ads_config(null)=0)
        RETURN(0)
       ENDIF
       IF ((dads_list->config_id=0))
        SET dm_err->emsg = "No Config ID was provided"
        SET dm_err->err_ind = 1
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
       IF (dar_get_config_data(dads_list->config_id)=0)
        RETURN(0)
       ENDIF
      OF "C":
       IF (trim(dgcd_temp_str)="")
        SET dgcd_table = "*"
       ELSE
        SET dm2scramble->mode_ind = 1
        SET dgcd_pos = findstring("*",dgcd_temp_str,1,0)
        IF (dgcd_pos > 0)
         SET dm2scramble->in_text = cnvtupper(substring(1,(dgcd_pos - 1),dgcd_temp_str))
         IF (ds_scramble(null)=0)
          RETURN(0)
         ENDIF
         SET dgcd_temp_str = build(dm2scramble->out_text)
         SET dgcd_temp_str = replace(check(dgcd_temp_str," ")," ","",0)
         SET dgcd_table = build(dgcd_temp_str,"*")
        ELSE
         SET dm2scramble->in_text = dgcd_temp_str
         IF (ds_scramble(null)=0)
          RETURN(0)
         ENDIF
         SET dgcd_temp_str = build(dm2scramble->out_text)
         SET dgcd_temp_str = replace(check(dgcd_temp_str," ")," ","",0)
         SET dgcd_table = dgcd_temp_str
        ENDIF
       ENDIF
       SET dgcd_continue = 0
      OF "M":
       SET dgcd_continue = 1
     ENDCASE
   ENDWHILE
   IF (check_error(dm_err->eproc)=1)
    CALL dar_disp_error_msg(null)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dar_get_sort_criteria(dgsc_filter_ind)
   DECLARE dgsc_continue = i2 WITH protect, noconstant(1)
   DECLARE dgsc_help_msg = vc WITH protect, noconstant("")
   DECLARE dgsc_sort_field = vc WITH protect, noconstant("")
   DECLARE dgsc_sort_value = vc WITH protect, noconstant("")
   DECLARE dgsc_filter_value = vc WITH protect, noconstant("")
   SET dgsc_table = "*"
   SET dm_err->eproc = "Obtaining sort criteria from user"
   CALL disp_msg("",dm_err->logfile,0)
   WHILE (dgsc_continue=1)
     SET message = window
     CALL clear(1,1)
     CALL box(1,1,3,132)
     CALL text(2,2,"ACTIVITY DATA SAMPLE MENU [REPORTING CRITERIA]")
     CALL text(2,70,"DATE/TIME: ")
     CALL text(2,80,format(cnvtdatetime(curdate,curtime3),"DD-MMM-YYYY HH:MM:SS;;D"))
     CALL text(5,2,"Sort Field: ")
     SET help = pos(5,60,15,60)
     SET help = fix(
      "TABLE NAME,DRIVER TABLE NAME,SAMPLE METHOD,TABLESPACE NAME,SOURCE NUM ROWS,TARGET NUM ROWS,TGT/SRC PERCENT"
      )
     CALL accept(5,18,"P(20);CUF",dgsc_sort_field
      WHERE curaccept IN ("TABLE NAME", "DRIVER TABLE NAME", "SAMPLE METHOD", "TABLESPACE NAME",
      "SOURCE NUM ROWS",
      "TARGET NUM ROWS", "TGT/SRC PERCENT"))
     SET help = off
     SET dgsc_sort_field = curaccept
     CALL text(6,2,"Sort Value: ")
     SET help = pos(6,60,10,60)
     SET help = fix("ASC,DESC")
     CALL accept(6,18,"P(15);CUF",dgsc_sort_value
      WHERE curaccept IN ("ASC", "DESC"))
     SET help = off
     SET dgsc_sort_value = curaccept
     IF (dgsc_filter_ind=1)
      CALL text(6,2,"Status Filter: ")
      SET dgsc_help_msg = concat("*","ALL","BYCONFIG","EVERYNTHPCT","MULTIPLE")
      SET help = pos(7,60,10,60)
      SET help = fix("*,ALL,BYCONFIG,EVERYNTHPCT,MULTIPLE")
      CALL accept(7,18,"P(15);CUF",dgsc_filter_value
       WHERE curaccept IN ("*", "ALL", "BYCONFIG", "EVERYNTHPCT", "MULTIPLE"))
      SET help = off
      SET dgsc_filter_value = curaccept
     ENDIF
     CALL text(10,2,"(C)ontinue, (M)odify, (B)ack :")
     CALL accept(10,34,"p;cu","M"
      WHERE curaccept IN ("C", "M", "B"))
     SET message = nowindow
     CASE (curaccept)
      OF "B":
       SET dgsc_continue = 0
      OF "C":
       SET dads_list->sort_field1 = evaluate(dgsc_sort_field,"TABLE NAME","table_name",
        "DRIVER TABLE NAME","driver_table_name",
        "SAMPLE METHOD","sample_method","SOURCE NUM ROWS","src_num_rows","TARGET NUM ROWS",
        "tgt_num_rows","TGT/SRC PERCENT","src_tgt_pct","TABLESPACE NAME","tablespace_name")
       SET dads_list->sort_value1 = dgsc_sort_value
       SET dgsc_continue = 0
      OF "M":
       SET dgsc_continue = 1
     ENDCASE
   ENDWHILE
   IF (check_error(dm_err->eproc)=1)
    CALL dar_disp_error_msg(null)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dar_get_extract_list(dgel_driverkey_ind,dgel_table,dgel_table_extract_nbr,
  dgel_ref_link_ind)
   DECLARE dgel_cnt = i4 WITH protect, noconstant(0)
   DECLARE dgel_table_name = vc WITH protect, noconstant("")
   IF (dgel_ref_link_ind=1)
    SET dgel_table_name = "dm_ads_extract@ref_data_link"
   ELSE
    SET dgel_table_name = "dm_ads_extract"
   ENDIF
   SET dm_err->eproc = "Populating the dads_list record structure from dm_ads_extract"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT
    IF (dgel_driverkey_ind=1)
     WHERE dae.driver_table_ind=1
      AND dae.table_name=patstring(dgel_table)
    ELSEIF (dgel_table_extract_nbr > 0)
     WHERE dae.table_name=patstring(dgel_table)
      AND dae.table_extract_nbr=dgel_table_extract_nbr
    ELSE
    ENDIF
    DISTINCT INTO "nl:"
    dae.owner_name, dae.table_name, dae.table_extract_nbr
    FROM (parser(concat("dm_ads_extract",evaluate(dgel_ref_link_ind,1,"@ref_data_link",""))) dae)
    HEAD REPORT
     dgel_cnt = 0, stat = alterlist(dads_list->extract_qual,dgel_cnt)
    DETAIL
     dgel_cnt = (dgel_cnt+ 1)
     IF (mod(dgel_cnt,10)=1)
      stat = alterlist(dads_list->extract_qual,(dgel_cnt+ 9))
     ENDIF
     dads_list->extract_qual[dgel_cnt].extract_id = dae.dm_ads_extract_id, dads_list->extract_qual[
     dgel_cnt].owner_name = trim(dae.owner_name), dads_list->extract_qual[dgel_cnt].table_name = trim
     (dae.table_name),
     dads_list->extract_qual[dgel_cnt].table_extract_nbr = dae.table_extract_nbr, dads_list->
     extract_qual[dgel_cnt].table_extract_instance_nbr = dae.table_extract_instance_nbr, dads_list->
     extract_qual[dgel_cnt].active_ind = dae.active_ind,
     dads_list->extract_qual[dgel_cnt].driver_table_name = trim(dae.driver_table_name), dads_list->
     extract_qual[dgel_cnt].data_class_type = trim(dae.data_class_type), dads_list->extract_qual[
     dgel_cnt].extract_method = trim(dae.extract_method),
     dads_list->extract_qual[dgel_cnt].driver_table_ind = dae.driver_table_ind, dads_list->
     extract_qual[dgel_cnt].driver_keycol_name = dae.driver_keycol_name, dads_list->extract_qual[
     dgel_cnt].driver_rankcol_name = dae.driver_rankcol_name,
     dads_list->extract_qual[dgel_cnt].apply_where_ind = dae.apply_where_ind, dads_list->
     extract_qual[dgel_cnt].expimp_parent_table_name = dae.expimp_parent_table_name, dads_list->
     extract_qual[dgel_cnt].expimp_level_nbr = dae.expimp_level_nbr,
     dads_list->extract_qual[dgel_cnt].where_clause = dae.where_clause, dads_list->extract_qual[
     dgel_cnt].table_comment = dae.table_comment, dads_list->extract_qual[dgel_cnt].dupdel_skip_ind
      = dae.dupdel_skip_ind,
     dads_list->extract_qual[dgel_cnt].updt_id = dae.updt_id, dads_list->extract_qual[dgel_cnt].
     updt_task = dae.updt_task, dads_list->extract_qual[dgel_cnt].updt_cnt = dae.updt_cnt,
     dads_list->extract_qual[dgel_cnt].updt_dt_tm = cnvtdatetime(dae.updt_dt_tm), dads_list->
     extract_qual[dgel_cnt].updt_applctx = dae.updt_applctx, dads_list->extract_qual[dgel_cnt].status
      = dpl_ready,
     dads_list->extract_qual[dgel_cnt].full_key = concat(trim(dae.owner_name),trim(dae.table_name),
      cnvtstring(dae.table_extract_nbr)), dads_list->extract_qual[dgel_cnt].row_sample = - (1),
     dads_list->extract_qual[dgel_cnt].dpq_id = 0,
     dads_list->extract_qual[dgel_cnt].table_exists_ind = 0
     IF (dae.extract_method=dpl_byconfig)
      IF ((dads_list->method_override > "")
       AND (dads_list->method_override != "DM2NOTSET"))
       dads_list->extract_qual[dgel_cnt].tgt_sample_method = dads_list->method_override
      ELSE
       dads_list->extract_qual[dgel_cnt].tgt_sample_method = dads_list->config_method
      ENDIF
      IF ((dads_list->pct_override > 0))
       dads_list->extract_qual[dgel_cnt].tgt_sample_pct = dads_list->pct_override
      ELSE
       dads_list->extract_qual[dgel_cnt].tgt_sample_pct = dads_list->config_pct
      ENDIF
     ELSE
      dads_list->extract_qual[dgel_cnt].tgt_sample_method = dae.extract_method, dads_list->
      extract_qual[dgel_cnt].tgt_sample_pct = dads_list->config_pct
     ENDIF
    FOOT REPORT
     dads_list->extract_cnt = dgel_cnt, stat = alterlist(dads_list->extract_qual,dads_list->
      extract_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag=511))
    CALL echorecord(dads_list)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dar_scr_dads_list(dsdl_mode)
   DECLARE dsdl_iter = i4 WITH protect, noconstant(0)
   SET dm2scramble->mode_ind = dsdl_mode
   FOR (dsdl_iter = 1 TO dads_list->extract_cnt)
     SET dm_err->eproc = concat(evaluate(dsdl_mode,1,"Scrambling","Unscrambling"),
      " desired fields for ",dads_list->extract_qual[dsdl_iter].full_key)
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     SET dm2scramble->in_text = dads_list->extract_qual[dsdl_iter].table_name
     IF (ds_scramble(null)=0)
      RETURN(0)
     ENDIF
     SET dads_list->extract_qual[dsdl_iter].table_name = build(dm2scramble->out_text)
     SET dm2scramble->out_text = ""
     SET dm2scramble->in_text = dads_list->extract_qual[dsdl_iter].driver_table_name
     IF (ds_scramble(null)=0)
      RETURN(0)
     ENDIF
     SET dads_list->extract_qual[dsdl_iter].driver_table_name = build(dm2scramble->out_text)
     SET dm2scramble->out_text = ""
     SET dm2scramble->in_text = dads_list->extract_qual[dsdl_iter].table_comment
     IF (ds_scramble(null)=0)
      RETURN(0)
     ENDIF
     SET dads_list->extract_qual[dsdl_iter].table_comment = build(dm2scramble->out_text)
     SET dm2scramble->out_text = ""
     SET dm2scramble->in_text = dads_list->extract_qual[dsdl_iter].driver_keycol_name
     IF (ds_scramble(null)=0)
      RETURN(0)
     ENDIF
     SET dads_list->extract_qual[dsdl_iter].driver_keycol_name = build(dm2scramble->out_text)
     SET dm2scramble->out_text = ""
     SET dm2scramble->in_text = dads_list->extract_qual[dsdl_iter].driver_rankcol_name
     IF (ds_scramble(null)=0)
      RETURN(0)
     ENDIF
     SET dads_list->extract_qual[dsdl_iter].driver_rankcol_name = build(dm2scramble->out_text)
     SET dm2scramble->out_text = ""
     SET dm2scramble->in_text = dads_list->extract_qual[dsdl_iter].where_clause
     IF (ds_scramble(null)=0)
      RETURN(0)
     ENDIF
     SET dads_list->extract_qual[dsdl_iter].where_clause = build(dm2scramble->out_text)
     SET dm2scramble->out_text = ""
     SET dm2scramble->in_text = dads_list->extract_qual[dsdl_iter].expimp_parent_table_name
     IF (ds_scramble(null)=0)
      RETURN(0)
     ENDIF
     SET dads_list->extract_qual[dsdl_iter].expimp_parent_table_name = build(dm2scramble->out_text)
     SET dm2scramble->out_text = ""
     SET dads_list->extract_qual[dsdl_iter].table_name = replace(check(dads_list->extract_qual[
       dsdl_iter].table_name," ")," ","",0)
     SET dads_list->extract_qual[dsdl_iter].driver_table_name = replace(check(dads_list->
       extract_qual[dsdl_iter].driver_table_name," ")," ","",0)
     SET dads_list->extract_qual[dsdl_iter].extract_method = replace(check(dads_list->extract_qual[
       dsdl_iter].extract_method," ")," ","",0)
     SET dads_list->extract_qual[dsdl_iter].data_class_type = replace(check(dads_list->extract_qual[
       dsdl_iter].data_class_type," ")," ","",0)
     SET dads_list->extract_qual[dsdl_iter].driver_keycol_name = replace(check(dads_list->
       extract_qual[dsdl_iter].driver_keycol_name," ")," ","",0)
     SET dads_list->extract_qual[dsdl_iter].driver_rankcol_name = replace(check(dads_list->
       extract_qual[dsdl_iter].driver_rankcol_name," ")," ","",0)
     SET dads_list->extract_qual[dsdl_iter].expimp_parent_table_name = replace(check(dads_list->
       extract_qual[dsdl_iter].expimp_parent_table_name," ")," ","",0)
     SET dads_list->extract_qual[dsdl_iter].where_clause = check(dads_list->extract_qual[dsdl_iter].
      where_clause," ")
   ENDFOR
   IF ((dm_err->debug_flag=511))
    CALL echorecord(dads_list)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dar_get_extract_details(dged_config_extract_id)
   DECLARE dged_cnt = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = concat("Retrieving data from dm_ads_config_extract for: ",build(
     dged_config_extract_id))
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_ads_config_extract dace,
     dm_ads_extract dae
    PLAN (dace
     WHERE dace.dm_ads_config_extract_id=dged_config_extract_id)
     JOIN (dae
     WHERE dace.dm_ads_extract_id=dae.dm_ads_extract_id)
    DETAIL
     dar_extract_details->config_id = dace.dm_ads_config_id, dar_extract_details->extract_id = dae
     .dm_ads_extract_id, dar_extract_details->owner_name = trim(dae.owner_name),
     dar_extract_details->table_name = trim(dae.table_name), dar_extract_details->parent_table_name
      = trim(dae.driver_table_name), dar_extract_details->table_extract_nbr = dae.table_extract_nbr,
     dar_extract_details->table_extract_instance_nbr = dae.table_extract_instance_nbr,
     dar_extract_details->status = dace.status_txt, dar_extract_details->full_key = concat(trim(dae
       .owner_name),trim(dae.table_name),cnvtstring(dae.table_extract_nbr)),
     dar_extract_details->driver_table_ind = dae.driver_table_ind, dar_extract_details->
     driver_keycol_name = trim(dae.driver_keycol_name), dar_extract_details->driver_rankcol_name =
     trim(dae.driver_keycol_name)
     IF (trim(dae.driver_rankcol_name) != "")
      dar_extract_details->driver_rankcol_name = trim(dae.driver_rankcol_name)
     ELSE
      dar_extract_details->driver_rankcol_name = dar_extract_details->driver_keycol_name
     ENDIF
     dar_extract_details->tgt_sample_method = trim(dace.target_sample_method), dar_extract_details->
     tgt_sample_pct = dace.target_sample_percent_nbr, dar_extract_details->row_sample = dace
     .row_sample_nbr,
     dar_extract_details->apply_where_ind = dae.apply_where_ind
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = concat("Extract Information not found for config_extract_id: ",build(
      dged_config_extract_id))
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dar_extract_details)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dar_cleanup_stranded_ads_procs(dscs_config_id)
   SET dm_err->eproc = concat("Cleaning up stranded config processes for: ",build(dscs_config_id))
   CALL disp_msg("",dm_err->logfile,0)
   IF (dpq_cleanup_stranded_procs(dpl_sample,10000)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Updating stranded rows in dm_ads_config_extract for: ",build(
     dscs_config_id))
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   UPDATE  FROM dm_ads_config_extract dace
    SET dace.status_txt = dpl_failed
    WHERE dace.status_txt=dpl_executing
     AND  NOT (dace.dm_process_queue_id IN (
    (SELECT
     dpq.dm_process_queue_id
     FROM dm_process_queue dpq
     WHERE dpq.process_status=dpq_executing)))
    WITH nocounter
   ;end update
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ROLLBACK
    RETURN(0)
   ENDIF
   IF (drr_cleanup_dm_info_runners(null)=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dar_sync_config_status(dscs_config_id)
   DECLARE dscs_config_status = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dscs_config_method = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dscs_cur_status = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dscs_old_err_ind = i2 WITH protect, noconstant(0)
   DECLARE dscs_old_err_msg = vc WITH protect, noconstant("")
   DECLARE dscs_old_err_eproc = vc WITH protect, noconstant("")
   DECLARE dscs_ndx = i4 WITH protect, noconstant(0)
   DECLARE dscs_pos = i4 WITH protect, noconstant(0)
   DECLARE dscs_msg = vc WITH protect, noconstant("")
   SET dm_err->eproc = concat("Syncing Status between currently running sample processes for: ",build
    (dscs_config_id))
   CALL disp_msg("",dm_err->logfile,0)
   SET dscs_old_err_ind = dm_err->err_ind
   SET dscs_old_err_msg = dm_err->emsg
   SET dscs_old_err_eproc = dm_err->eproc
   SET dm_err->err_ind = 0
   SET dm_err->emsg = ""
   SET dm_err->eproc = concat("Retrieve current status for: ",build(dscs_config_id))
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_ads_config dac
    WHERE dac.dm_ads_config_id=dscs_config_id
    DETAIL
     dscs_cur_status = dac.config_status, dscs_config_method = dac.sample_method
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = concat("Getting runner rows from dm_info for: ",build(dscs_config_id))
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM2_ADS*AUDSID"
     AND di.info_number=1
    DETAIL
     IF (di.info_domain=dpl_drivergen_runner)
      dscs_config_status = dpl_executing
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dscs_config_status != dpl_executing)
    SET dm_err->eproc = concat("Searching for any non-executing rows in dm_ads_config_extract for: ",
     build(dscs_config_id))
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    SELECT INTO "nl:"
     FROM dm_ads_config_extract dace
     WHERE dace.dm_ads_config_id=dscs_config_id
     DETAIL
      CASE (dace.status_txt)
       OF dpl_failed:
        dscs_config_status = dpl_failed,dscs_msg = dace.message_txt
       OF dpl_ready:
        IF (dscs_config_status != dpl_failed)
         dscs_config_status = dpl_needsbuild
        ENDIF
       OF dpl_incomplete:
        IF (dscs_config_status != dpl_failed
         AND dscs_config_status != dpl_needsbuild)
         dscs_config_status = dpl_incomplete, dscs_msg = dace.message_txt
        ENDIF
       OF dpl_complete:
        IF (dscs_config_status="DM2NOTSET")
         dscs_config_status = dpl_complete
        ENDIF
      ENDCASE
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (curqual=0)
     IF (dscs_config_method=dpl_custom)
      SELECT INTO "nl:"
       FROM dm_ads_config_driver dacd
       WHERE dacd.dm_ads_config_id=dscs_config_id
       WITH nocounter
      ;end select
      IF (check_error(dm_err->eproc)=1)
       SET dm_err->err_ind = 1
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      IF (curqual=0)
       SET dscs_config_status = dpl_needsbuild
      ELSE
       SET dscs_config_status = dpl_complete
      ENDIF
     ELSE
      SET dscs_config_status = dpl_needsbuild
     ENDIF
    ENDIF
   ENDIF
   IF (dscs_config_status != "DM2NOTSET")
    IF (dscs_config_status != dscs_cur_status)
     SET dm_err->eproc = concat("Updating statuses in dm_ads_config for: ",build(dscs_config_id))
     IF ((dm_err->debug_flag > 0))
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
     UPDATE  FROM dm_ads_config dac
      SET dac.config_status = evaluate(dscs_config_status,"DM2NOTSET",dac.config_status,
        dscs_config_status), dac.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE dac.dm_ads_config_id=dscs_config_id
      WITH nocounter
     ;end update
     IF (check_error(dm_err->eproc)=1)
      SET dm_err->err_ind = 1
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      ROLLBACK
      RETURN(0)
     ENDIF
     COMMIT
    ENDIF
    IF ((dscs_config_id=dads_list->config_id))
     SET dads_list->config_status = dscs_config_status
     SET dads_list->last_msg = dscs_msg
    ENDIF
    SET dscs_pos = locateval(dscs_ndx,1,dads_list->config_cnt,dscs_config_id,dads_list->config_qual[
     dscs_ndx].config_id)
    IF (dscs_pos > 0)
     SET dads_list->config_qual[dscs_pos].config_status = dscs_config_status
     SET dads_list->config_qual[dscs_pos].last_msg = dscs_msg
    ENDIF
   ENDIF
   SET dm_err->err_ind = dscs_old_err_ind
   SET dm_err->emsg = dscs_old_err_msg
   SET dm_err->eproc = dscs_old_err_eproc
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dar_common_menu(dcm_start_line,dcm_title)
   IF ((dads_list->config_id > 0))
    IF (dar_get_config_data(dads_list->config_id)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET message = window
   CALL clear(1,1)
   CALL box(1,1,3,132)
   CALL box(1,1,24,132)
   CALL text(dcm_start_line,2,build("ACTIVITY DATA SAMPLE MENU [",dcm_title,"]"))
   CALL text(dcm_start_line,70,"DATE/TIME: ")
   CALL text(dcm_start_line,80,format(cnvtdatetime(curdate,curtime3),"DD-MMM-YYYY HH:MM:SS;;D"))
   SET dcm_start_line = (dcm_start_line+ 3)
   CALL text(dcm_start_line,2,"Sample Name: ")
   CALL text(dcm_start_line,50,"Sample Status: ")
   CALL text(dcm_start_line,80,"Last Sample Status Dt/Tm: ")
   CALL text(dcm_start_line,18,dads_list->config_name)
   CALL text(dcm_start_line,65,dads_list->config_status)
   CALL text(dcm_start_line,108,format(dads_list->config_updt_dt_tm,";;Q"))
   SET dcm_start_line = (dcm_start_line+ 1)
   CALL text(dcm_start_line,2,"Sample Method: ")
   CALL text(dcm_start_line,18,dads_list->config_method)
   SET dcm_start_line = (dcm_start_line+ 1)
   CALL text(dcm_start_line,2,"Sample Percent: ")
   CALL text(dcm_start_line,18,build(dads_list->config_pct))
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dar_clear_dads_list(null)
   SET dm_err->eproc = "Clearing up the dads_list record structure"
   CALL disp_msg("",dm_err->logfile,0)
   SET dads_list->config_id = 0.0
   SET dads_list->config_name = ""
   SET dads_list->config_pct = 0
   SET dads_list->config_method = ""
   SET dads_list->config_status = ""
   SET dads_list->config_updt_dt_tm = cnvtdatetime("01-JAN-1900 00:00:00")
   SET dads_list->pct_override = 0
   SET dads_list->method_override = ""
   SET stat = alterlist(dads_list->extract_qual,0)
   SET stat = alterlist(dads_list->config_qual,0)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dar_disp_error_msg(null)
   SET message = nowindow
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   RETURN(null)
 END ;Subroutine
 SUBROUTINE dar_add_rpt_to_event_dtl(dard_type_in,dard_rpt_in)
   DECLARE dard_line_cnt = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = concat("Write ",dard_rpt_in," to DM_PROCESS_EVENT_DTL")
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg(" ",dm_err->logfile,0)
   ENDIF
   FREE DEFINE rtl2
   FREE SET dard_file_loc
   IF (validate(drrr_responsefile_in_use,- (1))=1)
    SET logical dard_file_loc value(concat(dard_rpt_in))
   ELSE
    SET logical dard_file_loc value(concat("ccluserdir:",dard_rpt_in))
   ENDIF
   DEFINE rtl2 "dard_file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    HEAD REPORT
     dard_line_cnt = 0, dm2_process_event_rs->detail_cnt = 0, dm2_process_event_rs->detail_cnt = (
     dm2_process_event_rs->detail_cnt+ 1),
     stat = alterlist(dm2_process_event_rs->details,dm2_process_event_rs->detail_cnt),
     dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_type = "REPORT_NAME",
     dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_text = dard_type_in,
     dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_number = cnvtreal(
      dir_ui_misc->dm_process_event_id)
    DETAIL
     dard_line_cnt = (dard_line_cnt+ 1), dm2_process_event_rs->detail_cnt = (dm2_process_event_rs->
     detail_cnt+ 1), stat = alterlist(dm2_process_event_rs->details,dm2_process_event_rs->detail_cnt),
     dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_type = "BODY",
     dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_text = trim(substring(1,
       1500,r.line)), dm2_process_event_rs->details[dm2_process_event_rs->detail_cnt].detail_number
      = dard_line_cnt
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET dm2_process_event_rs->status = dpl_complete
   IF (dm2_process_log_row(dpl_sample,dpl_report,dpl_no_prev_id,1)=0)
    RETURN(0)
   ENDIF
   FREE DEFINE rtl
   FREE SET dard_file_loc
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dar_continue_prompt(null)
   DECLARE dcp_cont = i2 WITH protect, noconstant(1)
   DECLARE dcp_var = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dcp_rs = vc WITH protect, noconstant("DM2NOTSET")
   DECLARE dcp_err_ind = i2 WITH protect, noconstant(0)
   IF ((validate(dm2_no_cont_debug,- (1))=- (1))
    AND (validate(dm2_no_cont_debug,- (2))=- (2)))
    SET dcp_err_ind = dm_err->err_ind
    SET dm_err->err_ind = 0
    WHILE (dcp_cont=1)
      SET message = window
      SET width = 132
      CALL clear(1,1)
      CALL box(1,1,20,131)
      CALL text(2,2,concat("Most Recent eproc: ",dm_err->eproc))
      CALL text(3,2,concat("Most Recent emsg (if any): ",dm_err->emsg))
      CALL text(4,2,"Echo variable:")
      CALL accept(4,30,"P(30);C",dcp_var
       WHERE dcp_var > " ")
      SET dcp_var = curaccept
      IF (dcp_var != "DM2NOTSET")
       SET message = nowindow
       CALL parser(concat("call echo(",dcp_var,") go"))
       SET message = window
      ENDIF
      CALL text(4,2,"Echo Record Structure:")
      CALL accept(4,30,"P(30);C",dcp_rs
       WHERE dcp_rs > " ")
      SET dcp_rs = curaccept
      IF (dcp_rs != "DM2NOTSET")
       SET message = nowindow
       CALL parser(concat("call echorecord(",dcp_rs,") go"))
       SET message = window
      ENDIF
      CALL text(4,2,concat("Do you want to continue?","[Y]es or [N]o or [R]epeat:"))
      CALL accept(4,55,"A;cu","Y"
       WHERE curaccept IN ("Y", "N", "R"))
      IF (curaccept="N")
       CALL clear(1,1)
       SET dcp_cont = 0
       SET message = nowindow
       RETURN(0)
      ELSEIF (curaccept="Y")
       SET dcp_cont = 0
      ELSEIF (curaccept="R")
       SET dcp_cont = 1
      ENDIF
    ENDWHILE
    CALL clear(1,1)
    SET message = nowindow
    IF (check_error("Debug Continue prompt")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
    ENDIF
    SET dm_err->err_ind = dcp_err_ind
   ENDIF
   RETURN(1)
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
 IF ((validate(dm2scramble->method_flag,- (99))=- (99))
  AND validate(dm2scramble->method_flag,511)=511)
  FREE RECORD dm2scramble
  RECORD dm2scramble(
    01 method_flag = i2
    01 mode_ind = i2
    01 in_text = vc
    01 out_text = vc
  )
  SET dm2scramble->method_flag = 0
 ENDIF
 DECLARE ds_scramble_init(null) = i2
 DECLARE ds_scramble(null) = i2
 SUBROUTINE ds_scramble_init(null)
   SET dm_err->eproc = "Initializing scramble dm_info data"
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=dpl_ads_metadata
     AND di.info_name=dpl_ads_scramble_method
    DETAIL
     dm2scramble->method_flag = di.info_number
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = "Inserting scramble initialization row into dm_info"
    INSERT  FROM dm_info di
     SET di.info_domain = dpl_ads_metadata, di.info_name = dpl_ads_scramble_method, di.info_number =
      dm2scramble->method_flag
     WITH nocounter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE ds_scramble(null)
   DECLARE dss_cnt = i4 WITH protect, noconstant(0)
   DECLARE dss_char = vc WITH protect, noconstant("")
   DECLARE dss_init = i2 WITH protect, noconstant(0)
   DECLARE dss_num = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = concat("Beginning scramble operation with Method: ",build(dm2scramble->
     method_flag)," and Mode: ",build(dm2scramble->mode_ind))
   IF ((dm_err->debug_flag=511))
    CALL echo(build2("Input Text: ",dm2scramble->in_text))
   ENDIF
   IF ((dm2scramble->method_flag=0)
    AND (dm2scramble->in_text > ""))
    SET dm2scramble->out_text = ""
    IF ((dm2scramble->mode_ind=1))
     SET dm_err->eproc = "Encrypting In-Text"
     FOR (dss_cnt = 1 TO textlen(dm2scramble->in_text))
      SET dss_num = ichar(substring(dss_cnt,1,dm2scramble->in_text))
      IF (dss_num < 255
       AND dss_num > 0)
       IF (((dss_num > 43
        AND dss_num < 58) OR (((dss_num > 64
        AND dss_num < 91) OR (dss_num > 96
        AND dss_num < 123)) )) )
        SET dss_char = notrim(char((dss_num+ 1)))
        IF (dss_init=1)
         SET dm2scramble->out_text = dss_char
         SET dss_init = 0
        ELSE
         SET dm2scramble->out_text = notrim(concat(dm2scramble->out_text,dss_char))
        ENDIF
       ELSE
        IF (dss_init=1)
         SET dm2scramble->out_text = substring(dss_cnt,1,dm2scramble->in_text)
         SET dss_init = 0
        ELSE
         SET dm2scramble->out_text = notrim(concat(dm2scramble->out_text,substring(dss_cnt,1,
            dm2scramble->in_text)))
        ENDIF
       ENDIF
      ENDIF
     ENDFOR
    ELSEIF ((dm2scramble->mode_ind=0))
     SET dm_err->eproc = "Decrypting In-Text"
     SET dss_init = 1
     FOR (dss_cnt = 1 TO textlen(dm2scramble->in_text))
      SET dss_num = ichar(substring(dss_cnt,1,dm2scramble->in_text))
      IF (dss_num < 255
       AND dss_num > 0)
       IF (((dss_num > 44
        AND dss_num < 59) OR (((dss_num > 65
        AND dss_num < 92) OR (dss_num > 97
        AND dss_num < 124)) )) )
        SET dss_char = notrim(char((dss_num - 1)))
        IF (dss_init=1)
         SET dm2scramble->out_text = dss_char
         SET dss_init = 0
        ELSE
         SET dm2scramble->out_text = notrim(concat(dm2scramble->out_text,dss_char))
        ENDIF
       ELSE
        IF (dss_init=1)
         SET dm2scramble->out_text = substring(dss_cnt,1,dm2scramble->in_text)
         SET dss_init = 0
        ELSE
         SET dm2scramble->out_text = notrim(concat(dm2scramble->out_text,substring(dss_cnt,1,
            dm2scramble->in_text)))
        ENDIF
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   ELSE
    SET dm2scramble->out_text = dm2scramble->in_text
   ENDIF
   SET dm2scramble->out_text = check(dm2scramble->out_text," ")
   IF ((dm_err->debug_flag=511))
    CALL echo(build2("Output Text: ",dm2scramble->out_text))
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE damg_loc = vc WITH protect, noconstant("")
 DECLARE damg_dae_file = vc WITH protect, noconstant("dm2_ads_metadata_load_dae")
 FREE RECORD damg_csv_details
 RECORD damg_csv_details(
   1 line_cnt = i4
   1 lines[*]
     2 table_name = vc
     2 line_str = vc
 )
 DECLARE damg_create_csv_file(dccf_file_type=vc,dccf_loc=vc,dccf_file_name=vc) = i2
 IF ( NOT (check_logfile("dm2_ads_gencsv",".log","dm2_ads_metadata_gencsv LOGFILE")))
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Beginning dm2_ads_metadata_gencsv"
 CALL disp_msg("",dm_err->logfile,0)
 SET damg_loc = trim(logical("cer_install"))
 IF (ds_scramble_init(null)=0)
  GO TO exit_program
 ENDIF
 EXECUTE dm2_ads_set_expimp_lvls "UPDATE"
 IF ((dm_err->err_ind=1))
  GO TO exit_program
 ENDIF
 IF (damg_create_csv_file("EXTRACT",damg_loc,damg_dae_file)=0)
  GO TO exit_program
 ENDIF
 SUBROUTINE damg_create_csv_file(dccf_file_type,dccf_loc,dccf_file_name)
   DECLARE dccf_file = vc WITH protect, noconstant("")
   DECLARE dccf_col_list = vc WITH protect, noconstant("")
   DECLARE dccf_cnt = i4 WITH protect, noconstant(0)
   DECLARE dccf_str = vc WITH protect, noconstant("")
   DECLARE dccf_scr_str = vc WITH protect, noconstant("")
   DECLARE dccf_invalid_ind = i2 WITH protect, noconstant(0)
   DECLARE dccf_invalid_msg = vc WITH protect, noconstant("")
   DECLARE dccf_iter = i4 WITH protect, noconstant(0)
   DECLARE dccf_continue_loop = i2 WITH protect, noconstant(0)
   SET dccf_file = build(dccf_loc,evaluate(cursys2,"AXP",build(dccf_file_name,".csv"),build("/",
      dccf_file_name,".csv")))
   IF (dm2_findfile(dccf_file) > 0)
    IF ((dm2_sys_misc->cur_os="AXP"))
     SET dccf_cmd = concat("del ",dccf_file,";*")
    ELSE
     SET dccf_cmd = concat("rm ",dccf_file)
    ENDIF
    IF (dm2_push_dcl(dccf_cmd)=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET dm_err->eproc = concat("Populating damg_csv_details for ",dccf_file_name," csv file")
   CALL disp_msg("",dm_err->logfile,0)
   CASE (dccf_file_type)
    OF "EXTRACT":
     SET dccf_col_list = concat(
      "owner_name,table_name,table_extract_nbr,table_extract_instance_nbr,active_ind,driver_table_name,",
      "data_class_type,extract_method,driver_table_ind,driver_keycol_name,driver_rankcol_name,",
      "apply_where_ind,expimp_parent_table_name,expimp_level_nbr,where_clause,table_comment,",
      "updt_id,updt_dt_tm,updt_task,updt_applctx,updt_cnt,dupdel_skip_ind")
     IF (dar_get_extract_list(0,"*",- (1),0)=0)
      RETURN(0)
     ENDIF
     FOR (dccf_iter = 1 TO dads_list->extract_cnt)
       SET dccf_invalid_ind = 0
       IF ((dads_list->extract_qual[dccf_iter].active_ind=1))
        SET dm_err->eproc = "Validating current csv row"
        IF ( NOT (cnvtupper(dads_list->extract_qual[dccf_iter].extract_method) IN (dpl_full,
        dpl_byconfig, dpl_static, dpl_intervalpct, dpl_nomove)))
         SET dccf_invalid_ind = 1
         SET dccf_invalid_msg = concat("Invalid Extract Method. Valid values: ",dpl_full,", ",
          dpl_byconfig,", ",
          dpl_static,", ",dpl_intervalpct,", ",dpl_nomove)
        ELSEIF ( NOT (cnvtupper(dads_list->extract_qual[dccf_iter].data_class_type) IN (dpl_act,
        dpl_ref, dpl_ref_mix, dpl_act_mix, dpl_mix)))
         SET dccf_invalid_ind = 1
         SET dccf_invalid_msg = concat("Invalid Data Class Type. Valid values: ",dpl_act,", ",dpl_ref,
          ", ",
          dpl_ref_mix,", ",dpl_act_mix,", ",dpl_mix)
        ELSEIF (cnvtupper(dads_list->extract_qual[dccf_iter].extract_method) IN (dpl_byconfig,
        dpl_static)
         AND cnvtint(dads_list->extract_qual[dccf_iter].apply_where_ind)=0)
         SET dccf_invalid_ind = 1
         SET dccf_invalid_msg = concat("Apply_where_ind MUST be set for extract methods: ",
          dpl_byconfig,", ",dpl_static)
        ELSEIF (cnvtupper(dads_list->extract_qual[dccf_iter].extract_method) IN (dpl_full,
        dpl_intervalpct)
         AND cnvtint(dads_list->extract_qual[dccf_iter].apply_where_ind)=1)
         SET dccf_invalid_ind = 1
         SET dccf_invalid_msg = concat("Apply_where_ind CANNOT be set for extract methods: ",dpl_full,
          ", ",dpl_intervalpct)
        ELSEIF (((trim(dads_list->extract_qual[dccf_iter].extract_method)="") OR (trim(dads_list->
         extract_qual[dccf_iter].where_clause)=""))
         AND cnvtint(dads_list->extract_qual[dccf_iter].apply_where_ind)=1)
         SET dccf_invalid_ind = 1
         SET dccf_invalid_msg =
         "Invalid extract_method/where clause for extract with apply_where_ind = 1"
        ELSEIF (cnvtint(dads_list->extract_qual[dccf_iter].active_ind)=1
         AND cnvtint(dads_list->extract_qual[dccf_iter].expimp_level_nbr)=999)
         SET dccf_invalid_ind = 1
         SET dccf_invalid_msg =
         "Active Extracts must have a valid expimp level number (between 0 and 19)"
        ELSEIF (cnvtint(dads_list->extract_qual[dccf_iter].expimp_level_nbr) > 19)
         SET dccf_invalid_ind = 1
         SET dccf_invalid_msg =
         "Active Extracts must have a valid expimp level number (between 0 and 19)"
        ENDIF
       ENDIF
       IF (dccf_invalid_ind=1)
        SET dm_err->err_ind = 1
        SET dm_err->eproc = build("Current DM_ADS_EXTRACT Extract ID - (",dads_list->extract_qual[
         dccf_iter].extract_id,") is Invalid")
        SET dm_err->emsg = dccf_invalid_msg
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
     ENDFOR
     IF (dar_scr_dads_list(1)=0)
      RETURN(0)
     ENDIF
     SET damg_csv_details->line_cnt = 0
     SET stat = alterlist(damg_csv_details->lines,damg_csv_details->line_cnt)
     FOR (dccf_iter = 1 TO dads_list->extract_cnt)
       SET dads_list->extract_qual[dccf_iter].table_name = replace(check(dads_list->extract_qual[
         dccf_iter].table_name," ")," ","",0)
       SET dads_list->extract_qual[dccf_iter].driver_table_name = replace(check(dads_list->
         extract_qual[dccf_iter].driver_table_name," ")," ","",0)
       SET dads_list->extract_qual[dccf_iter].extract_method = replace(check(dads_list->extract_qual[
         dccf_iter].extract_method," ")," ","",0)
       SET dads_list->extract_qual[dccf_iter].data_class_type = replace(check(dads_list->
         extract_qual[dccf_iter].data_class_type," ")," ","",0)
       SET dads_list->extract_qual[dccf_iter].driver_keycol_name = replace(check(dads_list->
         extract_qual[dccf_iter].driver_keycol_name," ")," ","",0)
       SET dads_list->extract_qual[dccf_iter].driver_rankcol_name = replace(check(dads_list->
         extract_qual[dccf_iter].driver_rankcol_name," ")," ","",0)
       SET dads_list->extract_qual[dccf_iter].expimp_parent_table_name = replace(check(dads_list->
         extract_qual[dccf_iter].expimp_parent_table_name," ")," ","",0)
       SET dads_list->extract_qual[dccf_iter].where_clause = check(dads_list->extract_qual[dccf_iter]
        .where_clause," ")
       WHILE (findstring("  ",dads_list->extract_qual[dccf_iter].where_clause,1,0) > 0)
         SET dads_list->extract_qual[dccf_iter].where_clause = replace(dads_list->extract_qual[
          dccf_iter].where_clause,"  "," ",0)
       ENDWHILE
       SET dads_list->extract_qual[dccf_iter].table_comment = check(dads_list->extract_qual[dccf_iter
        ].table_comment," ")
       SET dm_err->eproc = "Adding current extract row to CSV record structure"
       IF ((dm_err->debug_flag > 0))
        CALL disp_msg("",dm_err->logfile,0)
       ENDIF
       SET damg_csv_details->line_cnt = (damg_csv_details->line_cnt+ 1)
       IF (mod(damg_csv_details->line_cnt,10)=1)
        SET stat = alterlist(damg_csv_details->lines,(damg_csv_details->line_cnt+ 9))
       ENDIF
       SET damg_csv_details->lines[damg_csv_details->line_cnt].table_name = trim(dads_list->
        extract_qual[dccf_iter].table_name)
       SET damg_csv_details->lines[damg_csv_details->line_cnt].line_str = build(dads_list->
        extract_qual[dccf_iter].owner_name,",",check(dads_list->extract_qual[dccf_iter].table_name,
         " "),",",dads_list->extract_qual[dccf_iter].table_extract_nbr,
        ",",dads_list->extract_qual[dccf_iter].table_extract_instance_nbr,",",dads_list->
        extract_qual[dccf_iter].active_ind,",",
        check(dads_list->extract_qual[dccf_iter].driver_table_name," "),",",dads_list->extract_qual[
        dccf_iter].data_class_type,",",dads_list->extract_qual[dccf_iter].extract_method,
        ",",dads_list->extract_qual[dccf_iter].driver_table_ind,",",check(dads_list->extract_qual[
         dccf_iter].driver_keycol_name," "),",",
        check(dads_list->extract_qual[dccf_iter].driver_rankcol_name," "),",",dads_list->
        extract_qual[dccf_iter].apply_where_ind,",",check(dads_list->extract_qual[dccf_iter].
         expimp_parent_table_name," "),
        ",",dads_list->extract_qual[dccf_iter].expimp_level_nbr,",",check(dads_list->extract_qual[
         dccf_iter].where_clause," "),",",
        dads_list->extract_qual[dccf_iter].table_comment,",",dads_list->extract_qual[dccf_iter].
        updt_id,",",format(dads_list->extract_qual[dccf_iter].updt_dt_tm,";;q"),
        ",",dads_list->extract_qual[dccf_iter].updt_task,",",dads_list->extract_qual[dccf_iter].
        updt_applctx,",",
        dads_list->extract_qual[dccf_iter].updt_cnt,",",dads_list->extract_qual[dccf_iter].
        dupdel_skip_ind)
     ENDFOR
   ENDCASE
   IF ((dm_err->debug_flag=511))
    CALL echorecord(damg_csv_details)
   ENDIF
   SET dm_err->eproc = concat("Generating ",dccf_file_name," csv file into cer_install")
   CALL disp_msg("",dm_err->logfile,0)
   SELECT INTO value(dccf_file)
    FROM dummyt d
    DETAIL
     col 0, dccf_col_list, row + 1
     FOR (dccf_cnt = 1 TO damg_csv_details->line_cnt)
       col 0, damg_csv_details->lines[dccf_cnt].line_str, row + 1
     ENDFOR
    WITH nocounter, maxcol = 1000, formfeed = none,
     format = variable
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_program
 SET dm_err->eproc = "Ending dm2_ads_metadata_gencsv."
 CALL final_disp_msg("dm2_ads_gencsv")
END GO
